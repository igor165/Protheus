#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCOA165.CH'

//subir fonte novamente problema jira/robo expedicao


//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA165
Cadastro de Tabela de Classificadores de Receita e Despesa
@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PCOA165()
Local oBrowse

dbSelectArea("A1H")
dbSetOrder(1)

dbSelectArea("A1G")
dbSetOrder(1)

If cPaisLoc == "BRA"
	Imp_Tab()
EndIf

oBrowse := FWmBrowse():New()

oBrowse:SetAlias( 'A1G' )

oBrowse:SetDescription( STR0001 ) //Cadastro de Tabela de Classificadores de Receita e Despesa

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

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCOA165' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCOA165' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCOA165' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCOA165' OPERATION 5 ACCESS 0 //'Excluir'

ADD OPTION aRotina Title STR0011 Action 'VIEWDEF.PCOA165' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.PCOA165' OPERATION 9 ACCESS 0 //'Copiar'


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
Local oStruA1G := FWFormStruct(1,'A1G')
Local oStruA1H := FWFormStruct(1,'A1H')

Local oModel

oModel := MPFormModel():New('PCOA165')

oModel:AddFields('A1GMASTER',,oStruA1G)

oModel:AddGrid('A1HDETAIL','A1GMASTER',oStruA1H, /*bLinePre*/, /*bLinePost*/{ || A1HLPOS() }, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Define o número máximo de linhas que o model poderá receber, de acordo com a define GRIDMAXLIN.
oModel:GetModel("A1HDETAIL"):SetMaxLine(9999)

oModel:SetRelation('A1HDETAIL',{{'A1H_FILIAL','XFilial("A1H")'},{'A1H_CODTAB','A1G_CODTAB'}}, A1H->(IndexKey(1)) )

// Liga o controle de não repetição de linha
oModel:GetModel( 'A1HDETAIL' ):SetUniqueLine( { 'A1H_RADCHV', 'A1H_ITECHV' } )

oModel:SetDescription( STR0012 )  //'Classificadores de Receitas/Despesas'

oModel:GetModel('A1GMASTER'):SetDescription( STR0007 ) //"Tabela de Classificadores de Receita e Despesas (CabeÃ§alho) "
oModel:GetModel('A1HDETAIL'):SetDescription( STR0008 ) //"Itens da Tabela de Classificadores de Receita e Despesas"
 
oModel:GetModel( 'A1HDETAIL' ):SetOptional( .T. )


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

Local oStruA1G	:= FWFormStruct(2,'A1G')
Local oStruA1H	:= FWFormStruct(2,'A1H')
Local oModel	:= FWLoadModel('PCOa165')
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_A1G',oStruA1G,'A1GMASTER')

oView:AddGrid('VIEW_A1H',oStruA1H,'A1HDETAIL')

// Cria Folder na view
oView:CreateFolder( 'ITENS' )

// Cria pastas nas folders
oView:AddSheet( 'ITENS', 'XXXX', STR0013 )  //'Tabela Classificadores'

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'EMCIMA' 	,  20,,, 'ITENS', 'XXXX' )
oView:CreateHorizontalBox( 'EMBAIXO'	,  80,,, 'ITENS', 'XXXX' )

oView:CreateHorizontalBox( 'GERAL'  , 100,,, 'ITENS', 'YYYY' )

oView:SetOwnerView('VIEW_A1G','EMCIMA'		)
oView:SetOwnerView('VIEW_A1H','EMBAIXO'		)

oView:EnableTitleView('VIEW_A1G')
oView:EnableTitleView('VIEW_A1H')

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_A1H', 'A1H_ITETAB' )

oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} A1HLPOS
ValidaÃ§Ã£o 

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function A1HLPOS()
Local lRet		:= .T.
Local oModel	:= FWModelActive()

//----------------------------------------
// Valida 
//----------------------------------------
If oModel:GetModel( 'A1HDETAIL' ):IsEmpty()
	Help( , ,"A1HLPOS", ,STR0009,1,0,,,,,,{ STR0010 })	//"Cadastro da Tabela nÃ£o preenchido!" ### 
																//"Para solucionar efetue o cadastro dos registros referente a tabela"                    
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PcoVldCp
Validacao para listar os campos da tabela de movimento orçamentario

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PcoVldCp(cCampo)
Local lRet	  := .T.
Local aCpoX3 := { "AKD_CODPLA","AKD_VERSAO","AKD_CO","AKD_CLASSE","AKD_OPER","AKD_CC","AKD_ITCTB","AKD_CLVLR","AKD_UNIORC","AKD_ENT05","AKD_ENT06","AKD_ENT07","AKD_ENT08","AKD_ENT09","AKD_TPSALD" }
Default cCampo := M->A1G_CAMPO
 
If aScan(aCpoX3, {|x| AllTrim(x) == AllTrim(cCampo) } ) == 0
	Help( , ,"A1G_CAMPOINV", , STR0014 ,1,0,,,,,,{ STR0015 })	//"Campo inválido! Verifique."###"Digite campo da tabela de Mov. Orçamentario."
	lRet := .F.
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} Pco165X3
Consulta padrao especifica para listar os campos da tabel]a de movimento orçamentario

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function Pco165X3()

Local lRet	  := .T.
Local nOpcA   := 0
Local cVar	  := ReadVar()
Local nTam	  := Len(&cVar)
Local oDlgCons
Local oGetCons   
Local aSx3Fields := {}
Local nAt,nX
Local cCpoX3 := "AKD_CODPLA|AKD_VERSAO|AKD_CO|AKD_CLASSE|AKD_OPER|AKD_CC|AKD_ITCTB|AKD_CLVLR|AKD_UNIORC|AKD_ENT05|AKD_ENT06|AKD_ENT07|AKD_ENT08|AKD_ENT09|AKD_TPSALD"
Local oStruAKD	:= FWFormStruct(2,'AKD')
Local cCpoAnt   := &cVar

For nX := 1 to Len(oStruAKD:aFields)

		If ! ( AllTrim(oStruAKD:aFields[nX,1]) $ cCpoX3 )
			Loop
		EndIf

		aAdd(aSx3Fields, {Nil, Nil, Nil}) 
		aSX3Fields[Len(aSx3Fields)][1] := oStruAKD:aFields[nX,1]
		aSX3Fields[Len(aSx3Fields)][2] := PadR( oStruAKD:aFields[nX,3], 15)
		aSX3Fields[Len(aSx3Fields)][3] := oStruAKD:aFields[nX,4]
			
Next nX

Define MsDialog oDlgCons Title STR0016 From 000, 000 To 450, 800 PIXEL //"Consulta de campos Mov.Orçamentario"

	Define Font oFont Name 'Courier New' Size 0, -12		
	oGetCons := TCBrowse():New( 000, 000, 545, 200,, { STR0017, STR0018, STR0019},,;    //"Campos Mov.Orct."##"Título"##"Descrição"
	                            oDlgCons,,,,,{||},,oFont,,,,,.T./*lUpdate*/,,.T.,,.T./*lDesign*/,,, )  	

	oGetCons:SetArray(aSx3Fields)
	oGetCons:bLine := {||{	aSx3Fields[oGetCons:nAt,1],aSx3Fields[oGetCons:nAt,2],aSx3Fields[oGetCons:nAt,3]}} 	                            
	oGetCons:blDblClick := {||nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End()}

	@208,310 BUTTON STR0020 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 1, nAt := oGetCons:nAt, oDlgCons:End())	//"Confirmar"
	@208,360 BUTTON STR0021 SIZE 40,12 OF oDlgCons PIXEL ACTION (nOpcA := 0, oDlgCons:End())	//"Cancelar"

Activate MsDialog oDlgCons Centered

If nOpcA == 1 
	&cVar := aSx3Fields[nAt,1]
	&cVar += Space(nTam-Len(&cVar))
Else
	//recupera o que estava anteriormente
	&cVar := cCpoAnt
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
// Deixar sempre a carga das tabelas por ultimo, se nencessario implementar
// algo escrever o fonte acima deste comentario.
//
// Como estas cargas de tabela so eh valido para o Brasil não 
// faremos a inclusao das strings no arquivo.ch 
//
//-------------------------------------------------------------------

//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_Tab
Rotina auxiliar de Importação 

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_Tab()
Local lRet := .T.

If ! Imp_TabCE()
 	lRet := .F.
EndIf

If ! Imp_TabO1()
 	lRet := .F.
EndIf

If ! Imp_TabO2()
 	lRet := .F.
EndIf

If ! Imp_TabE1()
 	lRet := .F.
EndIf

If ! Imp_TabE2()
 	lRet := .F.
EndIf

If ! Imp_TabE3()
 	lRet := .F.
EndIf

If ! Imp_TabE4()
 	lRet := .F.
EndIf

If ! Imp_TabE5()
 	lRet := .F.
EndIf

If ! Imp_TabE6()
 	lRet := .F.
EndIf

If ! Imp_TabE7()
 	lRet := .F.
EndIf

If ! Imp_TabE9()
 	lRet := .F.
EndIf

If ! Imp_TabED()
 	lRet := .F.
EndIf

If ! Imp_TabTP()
 	lRet := .F.
EndIf

If ! Imp_TabF1()
 	lRet := .F.
EndIf

If ! Imp_TabF2()
 	lRet := .F.
EndIf

If ! Imp_TabF3()
 	lRet := .F.
EndIf

If ! Imp_TabF4()
 	lRet := .F.
EndIf

If ! Imp_TabF9()
 	lRet := .F.
EndIf

If ! Imp_TabFC()
 	lRet := .F.
EndIf

If ! Imp_TabSB()
 	lRet := .F.
EndIf

If ! Imp_TabDE()
 	lRet := .F.
EndIf

If ! Imp_TabGD()
 	lRet := .F.
EndIf

If ! Imp_TabMA()
 	lRet := .F.
EndIf

If ! Imp_TabFR()
 	lRet := .F.
EndIf

If ! Imp_TabSE()
 	lRet := .F.
EndIf

If ! Imp_TabCA()
 	lRet := .F.
EndIf

If ! Imp_TabUM()
 	lRet := .F.
EndIf

If ! Imp_TabDR()
 	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Tbl_Imp
Rotina auxiliar de Importação com gravação dos dados no modelo

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Tbl_Imp(cMaster, cDetail, aCpoMaster, aCpoDetail )
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
// Neste exemplo instanciamos o modelo de dados do fonte PCOA165
oModel := FWLoadModel( 'PCOA165' )

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
	
	AutoGrLog( STR0022 + ' [' + AllToChar( aErro[1] ) + ']' ) //"Id do formulário de origem:"
	AutoGrLog( STR0023 + ' [' + AllToChar( aErro[2] ) + ']' ) //"Id do campo de origem: " 
	AutoGrLog( STR0024 + ' [' + AllToChar( aErro[3] ) + ']' ) //"Id do formulário de erro: "
	AutoGrLog( STR0025 + ' [' + AllToChar( aErro[4] ) + ']' ) //"Id do campo de erro: "
	AutoGrLog( STR0026 + ' [' + AllToChar( aErro[5] ) + ']' ) //"Id do erro: "
	AutoGrLog( STR0027 + ' [' + AllToChar( aErro[6] ) + ']' ) //"Mensagem do erro: "
	AutoGrLog( STR0028 + ' [' + AllToChar( aErro[7] ) + ']' ) //"Mensagem da solução: "
	AutoGrLog( STR0029 + ' [' + AllToChar( aErro[8] ) + ']' ) //"Valor atribuído: "
	AutoGrLog( STR0030 + ' [' + AllToChar( aErro[9] ) + ']' ) //"Valor anterior: "
	If nItErro > 0
		AutoGrLog( STR0031 + ' [' + AllTrim( AllToChar( nItErro ) ) + ']' ) //"Erro no Item: "
	EndIf

	MostraErro()

EndIf

// Desativamos o Model
oModel:DeActivate()

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabCE
Rotina auxiliar de Importação - CATEGORIA ECONOMICA

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabCE()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"CE")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "CE"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "CATEGORIA ECONOMICA" } )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 1 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "CE" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "RECEITAS CORRENTES" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "CE" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "RECEITAS DE CAPITAL" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "CE" } )
	aAdd( aAux, { "A1H_ITECHV", "7" } )
	aAdd( aAux, { "A1H_CHVCNT", "RECEITAS CORRENTES INTRA ORÇAMENTARIAS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "CE" } )
	aAdd( aAux, { "A1H_ITECHV", "8" } )
	aAdd( aAux, { "A1H_CHVCNT", "RECEITAS DE CAPITAL INTRA ORÇAMENTARIAS" } )
	aAdd( aCposDet, aAux )

	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabO1
Rotina auxiliar de Importação - ORIGEM RECEITAS  CORRENTES / INTRA ORÇAMENTARIAS

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabO1()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"O1")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "O1"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ORIGEM RECEITAS  CORRENTES / INTRA ORÇAMENTARIAS"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 2 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "R" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "IMPOSTOS, TAXAS E CONTRIBUIÇÕES DE MELHORIA" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "R" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "RECEITA DE CONTRIBUIÇÕES" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "R" } )
	aAdd( aAux, { "A1H_ITECHV", "3" } )
	aAdd( aAux, { "A1H_CHVCNT", "RECEITA PATRIMONIAL" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "R" } )
	aAdd( aAux, { "A1H_ITECHV", "4" } )
	aAdd( aAux, { "A1H_CHVCNT", "RECEITA AGROPECUÁRIA" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0005" } )
	aAdd( aAux, { "A1H_RADCHV", "R" } )
	aAdd( aAux, { "A1H_ITECHV", "5" } )
	aAdd( aAux, { "A1H_CHVCNT", "RECEITA INDUSTRIAL" } )
	aAdd( aCposDet, aAux )
	
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0006" } )
	aAdd( aAux, { "A1H_RADCHV", "R" } )
	aAdd( aAux, { "A1H_ITECHV", "6" } )
	aAdd( aAux, { "A1H_CHVCNT", "RECEITA DE SERVIÇOS" } )
	aAdd( aCposDet, aAux )
	
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0007" } )
	aAdd( aAux, { "A1H_RADCHV", "R" } )
	aAdd( aAux, { "A1H_ITECHV", "7" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIAS CORRENTES" } )
	aAdd( aCposDet, aAux )
	
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0008" } )
	aAdd( aAux, { "A1H_RADCHV", "R" } )
	aAdd( aAux, { "A1H_ITECHV", "9" } )
	aAdd( aAux, { "A1H_CHVCNT", "OUTRAS RECEITAS CORRENTES" } )
	aAdd( aCposDet, aAux )
		
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabO2
Rotina auxiliar de Importação - ORIGEM RECEITA CAPITAL / INTRA ORÇAMENTARIA 

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabO2()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"O2")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "O2"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ORIGEM RECEITA CAPITAL / INTRA ORÇAMENTARIA"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 2 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "C" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "OPERAÇÕES DE CREDITO" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "C" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "ALIENAÇÃO DE BENS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "C" } )
	aAdd( aAux, { "A1H_ITECHV", "3" } )
	aAdd( aAux, { "A1H_CHVCNT", "AMORTIZAÇÃO DE EMPRÉSTIMO" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "C" } )
	aAdd( aAux, { "A1H_ITECHV", "4" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIAS DE CAPITAL" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0005" } )
	aAdd( aAux, { "A1H_RADCHV", "C" } )
	aAdd( aAux, { "A1H_ITECHV", "9" } )
	aAdd( aAux, { "A1H_CHVCNT", "OUTRAS RECEITAS DE CAPITAL" } )
	aAdd( aCposDet, aAux )
			
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabE1
Rotina auxiliar de Importação - ESPECIE RECEITAS CORRENTES 

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabE1()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"E1")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "E1"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE RECEITAS CORRENTES"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "E1" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "IMPOSTOS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "E1" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "TAXAS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "E1" } )
	aAdd( aAux, { "A1H_ITECHV", "3" } )
	aAdd( aAux, { "A1H_CHVCNT", "CONTRIBUIÇÕES DE MELHORIA" } )
	aAdd( aCposDet, aAux )

	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabE2
Rotina auxiliar de Importação - ESPECIE RECEITA CORRENTE CONTRIBUIÇÕES

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabE2()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"E2")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "E2"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE RECEITA CORRENTE CONTRIBUIÇÕES"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "E2" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "SOCIAIS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "E2" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "ECONÔMICAS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "E2" } )
	aAdd( aAux, { "A1H_ITECHV", "3" } )
	aAdd( aAux, { "A1H_CHVCNT", "PARA ENTID.PRIVADAS SERV.SOCIAL FORM.PROFISSIONAL" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "E2" } )
	aAdd( aAux, { "A1H_ITECHV", "4" } )
	aAdd( aAux, { "A1H_CHVCNT", "PARA CUSTEIO DE ILUMINAÇÃO PUBLICA" } )
	aAdd( aCposDet, aAux )
			
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabE3
Rotina auxiliar de Importação - ESPECIE RECEITA  CORRENTE PATRIMONIAL

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabE3()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"E3")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "E3"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE RECEITA  CORRENTE PATRIMONIAL"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "E3" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "EXPLORAÇÃO DE PATRIMÔNIO IMOBILIÁRIO DO ESTADO" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "E3" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "VALORES MOBILIÁRIOS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "E3" } )
	aAdd( aAux, { "A1H_ITECHV", "3" } )
	aAdd( aAux, { "A1H_CHVCNT", "CONCESSÕES / PERMISSÕES / AUTORIZAÇÃO OU LICENÇA" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "E3" } )
	aAdd( aAux, { "A1H_ITECHV", "4" } )
	aAdd( aAux, { "A1H_CHVCNT", "EXPLORAÇÃO DE RECURSOS NATURAIS" } )
	aAdd( aCposDet, aAux )
			

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "E3" } )
	aAdd( aAux, { "A1H_ITECHV", "5" } )
	aAdd( aAux, { "A1H_CHVCNT", "EXPLORAÇÃO DO PATRIMÔNIO INTANGÍVEL" } )
	aAdd( aCposDet, aAux )
	
	
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "E3" } )
	aAdd( aAux, { "A1H_ITECHV", "6" } )
	aAdd( aAux, { "A1H_CHVCNT", "CESSÃO DE DIREITOS" } )
	aAdd( aCposDet, aAux )
	
	
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "E3" } )
	aAdd( aAux, { "A1H_ITECHV", "9" } )
	aAdd( aAux, { "A1H_CHVCNT", "DEMAIS RECEITAS PATRIMONIAIS" } )
	aAdd( aCposDet, aAux )
						
			
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabE4
Rotina auxiliar de Importação - ESPECIE RECEITA CORRENTE AGROPECUÁRIA

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabE4()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"E4")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "E4"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE RECEITA CORRENTE AGROPECUÁRIA"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "E4" } )
	aAdd( aAux, { "A1H_ITECHV", "0" } )
	aAdd( aAux, { "A1H_CHVCNT", "AGROPECUÁRIA" } )
	aAdd( aCposDet, aAux )
			
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabE5
Rotina auxiliar de Importação - ESPECIE RECEITA CORRENTE INDUSTRIAL

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabE5()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"E5")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "E5"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE RECEITA CORRENTE INDUSTRIAL"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "E5" } )
	aAdd( aAux, { "A1H_ITECHV", "0" } )
	aAdd( aAux, { "A1H_CHVCNT", "INDUSTRIAL" } )
	aAdd( aCposDet, aAux )
			
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabE6
Rotina auxiliar de Importação - ESPECIE RECEITA CORRENTE SERVIÇOS

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabE6()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"E6")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "E6"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE RECEITA CORRENTE SERVIÇOS"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "E6" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "SERVIÇOS ADMINISTRATIVOS E GERAIS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "E6" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "SERVIÇOS E ATIVIDADES REF.NAVEGAÇÃO E TRANSPORTE" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "E6" } )
	aAdd( aAux, { "A1H_ITECHV", "3" } )
	aAdd( aAux, { "A1H_CHVCNT", "SERVIÇOS E ATIVIDADES REFERENTE A SAUDE" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "E6" } )
	aAdd( aAux, { "A1H_ITECHV", "4" } )
	aAdd( aAux, { "A1H_CHVCNT", "SERVIÇOS E ATIVIDADES FINANCEIRAS" } )
	aAdd( aCposDet, aAux )
		
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0005" } )
	aAdd( aAux, { "A1H_RADCHV", "E6" } )
	aAdd( aAux, { "A1H_ITECHV", "9" } )
	aAdd( aAux, { "A1H_CHVCNT", "OUTROS SERVIÇOS" } )
	aAdd( aCposDet, aAux )
				
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabE7
Rotina auxiliar de Importação - ESPECIE RECEITAS TRANSFERÊNCIA CORRENTES

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabE7()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"E7")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "E7"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE RECEITAS TRANSFERÊNCIA CORRENTES"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "E7" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIA DA UNIÃO E DE SUAS ENTIDADES" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "E7" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSF.DOS ESTADOS DISTR.FEDERAL E SUAS ENTIDADES" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "E7" } )
	aAdd( aAux, { "A1H_ITECHV", "3" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIA DOS MUNICÍPIOS E SUAS ENTIDADES" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "E7" } )
	aAdd( aAux, { "A1H_ITECHV", "4" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIA DE INSTITUIÇÕES PRIVADAS" } )
	aAdd( aCposDet, aAux )
		
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0005" } )
	aAdd( aAux, { "A1H_RADCHV", "E7" } )
	aAdd( aAux, { "A1H_ITECHV", "5" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIA DE OUTRAS INSTITUIÇÕES PUBLICAS" } )
	aAdd( aCposDet, aAux )	
		
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0006" } )
	aAdd( aAux, { "A1H_RADCHV", "E7" } )
	aAdd( aAux, { "A1H_ITECHV", "6" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIAS DO EXTERIOR" } )
	aAdd( aCposDet, aAux )	
		
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0007" } )
	aAdd( aAux, { "A1H_RADCHV", "E7" } )
	aAdd( aAux, { "A1H_ITECHV", "7" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIAS DE PESSOAS FÍSICAS" } )
	aAdd( aCposDet, aAux )	

		
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0008" } )
	aAdd( aAux, { "A1H_RADCHV", "E7" } )
	aAdd( aAux, { "A1H_ITECHV", "8" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIAS DE DEPÓSITOS NÃO IDENTIFICADOS" } )
	aAdd( aCposDet, aAux )	

	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet




//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabE9
Rotina auxiliar de Importação - ESPECIE OUTRAS RECEITAS CORRENTES

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabE9()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"E9")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "E9"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE OUTRAS RECEITAS CORRENTES"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "E9" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "MULTAS ADMINISTRATIVAS, CONTRATUAIS E JUDICIAIS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "E9" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "INDENIZAÇÕES, RESTITUIÇÕES E RESSARCIMENTOS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "E9" } )
	aAdd( aAux, { "A1H_ITECHV", "3" } )
	aAdd( aAux, { "A1H_CHVCNT", "BENS, DIREITOS E VALORES INCORP.AO PATRIM.PUBLICO" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "E9" } )
	aAdd( aAux, { "A1H_ITECHV", "9" } )
	aAdd( aAux, { "A1H_CHVCNT", "DEMAIS RECEITAS CORRENTES" } )
	aAdd( aCposDet, aAux )


	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabF1
Rotina auxiliar de Importação - ESPECIE RECEITA CAPITAL OPERAÇÃO CREDITO

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabF1()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"F1")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "F1"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE RECEITA CAPITAL OPERAÇÃO CREDITO"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "F1" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "INTERNAS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "F1" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "EXTERNAS" } )
	aAdd( aCposDet, aAux )
	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet
	
	

//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabF2
Rotina auxiliar de Importação - ESPECIE RECEITA CAPITAL ALIENAÇÃO DE BENS

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabF2()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"F2")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "F2"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE RECEITA CAPITAL ALIENAÇÃO DE BENS"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "F2" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "BENS MOVEIS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "F2" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "BENS IMOVEIS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "F2" } )
	aAdd( aAux, { "A1H_ITECHV", "3" } )
	aAdd( aAux, { "A1H_CHVCNT", "BENS INTANGÍVEIS " } )
	aAdd( aCposDet, aAux )

	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabF3
Rotina auxiliar de Importação - ESPECIE RECEITA CAPITAL AMORTIZAÇÃO DE EMPRÉSTIMO

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabF3()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"F3")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "F3"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE RECEITA CAPITAL AMORTIZAÇÃO DE EMPRÉSTIMO"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "F3" } )
	aAdd( aAux, { "A1H_ITECHV", "0" } )
	aAdd( aAux, { "A1H_CHVCNT", "AMORTIZAÇÕES" } )
	aAdd( aCposDet, aAux )


	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabF4
Rotina auxiliar de Importação - ESPECIE RECEITAS CAPITAL  TRANSFERÊNCIAS

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabF4()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"F4")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "F4"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE RECEITAS CAPITAL  TRANSFERÊNCIAS"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "F4" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIA DA UNIÃO E DE SUAS ENTIDADES" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "F4" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSF.DOS ESTADOS DISTR.FEDERAL E SUAS ENTIDADES" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "F4" } )
	aAdd( aAux, { "A1H_ITECHV", "3" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIAS DOS MUNICÍPIOS E DE SUAS ENTIDADES" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "F4" } )
	aAdd( aAux, { "A1H_ITECHV", "4" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIAS DE INSTITUICOES PRIVADAS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0005" } )
	aAdd( aAux, { "A1H_RADCHV", "F4" } )
	aAdd( aAux, { "A1H_ITECHV", "5" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIAS DE OUTRAS ENTIDADES PUBLICAS" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0006" } )
	aAdd( aAux, { "A1H_RADCHV", "F4" } )
	aAdd( aAux, { "A1H_ITECHV", "6" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIAS DO EXTERIOR" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0007" } )
	aAdd( aAux, { "A1H_RADCHV", "F4" } )
	aAdd( aAux, { "A1H_ITECHV", "7" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIAS DE PESSOAS FÍSICAS" } )
	aAdd( aCposDet, aAux )
	
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0008" } )
	aAdd( aAux, { "A1H_RADCHV", "F4" } )
	aAdd( aAux, { "A1H_ITECHV", "8" } )
	aAdd( aAux, { "A1H_CHVCNT", "TRANSFERÊNCIAS DE DEPÓSITOS NÃO IDENTIFICADOS" } )
	aAdd( aCposDet, aAux )
	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabF9
Rotina auxiliar de Importação - ESPECIE OUTRAS RECEITAS DE CAPITAL

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabF9()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"F9")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "F9"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ESPECIE OUTRAS RECEITAS DE CAPITAL"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 3 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "F9" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "INTEGRALIZAÇÃO DO CAPITAL SOCIAL" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "F9" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "RESULTADO DO BANCO CENTRAL" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "F9" } )
	aAdd( aAux, { "A1H_ITECHV", "3" } )
	aAdd( aAux, { "A1H_CHVCNT", "REMUNERAÇÃO DAS DISPONIBILIDADES DO TESOURO" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "F9" } )
	aAdd( aAux, { "A1H_ITECHV", "4" } )
	aAdd( aAux, { "A1H_CHVCNT", "RESGATE DE TÍTULOS DO TESOURO" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0005" } )
	aAdd( aAux, { "A1H_RADCHV", "F9" } )
	aAdd( aAux, { "A1H_ITECHV", "9" } )
	aAdd( aAux, { "A1H_CHVCNT", "DEMAIS RECEITAS DE CAPITAL" } )
	aAdd( aCposDet, aAux )
	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabTP
Rotina auxiliar de Importação - Tipo

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabTP()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"TP")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "TP"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "TIPO"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 8 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "TP" } )
	aAdd( aAux, { "A1H_ITECHV", "0" } )
	aAdd( aAux, { "A1H_CHVCNT", "NATUREZA AGREGADORA" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "TP" } )
	aAdd( aAux, { "A1H_ITECHV", "1" } )
	aAdd( aAux, { "A1H_CHVCNT", "RECEITA PRINCIPA" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "TP" } )
	aAdd( aAux, { "A1H_ITECHV", "2" } )
	aAdd( aAux, { "A1H_CHVCNT", "MULTA E JUROS DA RECEITA PRINCIPAL" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "TP" } )
	aAdd( aAux, { "A1H_ITECHV", "3" } )
	aAdd( aAux, { "A1H_CHVCNT", "DÍVIDA ATIVA DA RECEITA PRINCIPAL" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0005" } )
	aAdd( aAux, { "A1H_RADCHV", "TP" } )
	aAdd( aAux, { "A1H_ITECHV", "4" } )
	aAdd( aAux, { "A1H_CHVCNT", "MULTA E JUROS DA DÍVIDA ATIVA DA RECEITA PRINCIPAL" } )
	aAdd( aCposDet, aAux )
	
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0006" } )
	aAdd( aAux, { "A1H_RADCHV", "TP" } )
	aAdd( aAux, { "A1H_ITECHV", "5" } )
	aAdd( aAux, { "A1H_CHVCNT", "MULTA RECEITA PRINCIPAL QDO NÃO SE APLICAR TIPO 2" } )
	aAdd( aCposDet, aAux )
	
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0007" } )
	aAdd( aAux, { "A1H_RADCHV", "TP" } )
	aAdd( aAux, { "A1H_ITECHV", "6" } )
	aAdd( aAux, { "A1H_CHVCNT", "JUROS RECEITA PRINCIPAL QDO NÃO SE APLICAR TIPO 2" } )
	aAdd( aCposDet, aAux )
	
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0008" } )
	aAdd( aAux, { "A1H_RADCHV", "TP" } )
	aAdd( aAux, { "A1H_ITECHV", "7" } )
	aAdd( aAux, { "A1H_CHVCNT", "MULTAS DÍVIDA ATIVA QUANDO NÃO SE APLICAR O TIPO 4" } )
	aAdd( aCposDet, aAux )
	
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0009" } )
	aAdd( aAux, { "A1H_RADCHV", "TP" } )
	aAdd( aAux, { "A1H_ITECHV", "8" } )
	aAdd( aAux, { "A1H_CHVCNT", "JUROS DÍVIDA ATIVA QUANDO NÃO SE APLICAR O TIPO 4" } )
	aAdd( aCposDet, aAux )
	
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0010" } )
	aAdd( aAux, { "A1H_RADCHV", "TP" } )
	aAdd( aAux, { "A1H_ITECHV", "9" } )
	aAdd( aAux, { "A1H_CHVCNT", "DESDOBRAMENTO A SER CRIADO PELA SOF/MP" } )
	aAdd( aCposDet, aAux )
	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabFC
Rotina auxiliar de Importação - FUNCAO

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabFC()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}
Local aDadAux := {}
Local nX := 0

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"FC")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "FC"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "FUNCAO"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "2" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 7 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 2 } )

	//carrega os dados de acordo a tabela
	aAdd( aDadAux, { "FC","01","LEGISLATIVA" } )
	aAdd( aDadAux, { "FC","02","JUDICIÁRIA" } )
	aAdd( aDadAux, { "FC","03","ESSENCIAL À JUSTIÇA" } )
	aAdd( aDadAux, { "FC","04","ADMINISTRAÇÃO" } )
	aAdd( aDadAux, { "FC","05","DEFESA NACIONAL" } )
	aAdd( aDadAux, { "FC","06","SEGURANÇA PÚBLICA" } )
	aAdd( aDadAux, { "FC","07","RELAÇÕES EXTERIORES" } )
	aAdd( aDadAux, { "FC","08","ASSISTÊNCIA SOCIAL" } )
	aAdd( aDadAux, { "FC","09","PREVIDÊNCIA SOCIAL" } )
	aAdd( aDadAux, { "FC","10","SAÚDE" } )
	aAdd( aDadAux, { "FC","11","TRABALHO" } )
	aAdd( aDadAux, { "FC","12","EDUCAÇÃO" } )
	aAdd( aDadAux, { "FC","13","CULTURA" } )
	aAdd( aDadAux, { "FC","14","DIREITOS DA CIDADANIA" } )
	aAdd( aDadAux, { "FC","15","URBANISMO" } )
	aAdd( aDadAux, { "FC","16","HABITAÇÃO" } )
	aAdd( aDadAux, { "FC","17","SANEAMENTO" } )
	aAdd( aDadAux, { "FC","18","GESTÃO AMBIENTAL" } )
	aAdd( aDadAux, { "FC","19","CIÊNCIA E TECNOLOGIA" } )
	aAdd( aDadAux, { "FC","20","AGRICULTURA" } )
	aAdd( aDadAux, { "FC","21","ORGANIZAÇÃO AGRÁRIA" } )
	aAdd( aDadAux, { "FC","22","INDÚSTRIA" } )
	aAdd( aDadAux, { "FC","23","COMÉRCIO E SERVIÇOS" } )
	aAdd( aDadAux, { "FC","24","COMUNICAÇÕES" } )
	aAdd( aDadAux, { "FC","25","ENERGIA" } )
	aAdd( aDadAux, { "FC","26","TRANSPORTE" } )
	aAdd( aDadAux, { "FC","27","DESPORTO E LAZER" } )
	aAdd( aDadAux, { "FC","28","ENCARGOS ESPECIAIS" } )
	aAdd( aDadAux, { "FC","99","RESERVA DE CONTINGÊNCIA" } )

	aCposDet := {}

	For nX := 1 To Len(aDadAux)
		
		aAux := {}
		aAdd( aAux, { "A1H_ITETAB" , StrZero(nX, 4)} )
		aAdd( aAux, { "A1H_RADCHV", aDadAux[nX,1] } )
		aAdd( aAux, { "A1H_ITECHV", aDadAux[nX,2] } )
		aAdd( aAux, { "A1H_CHVCNT", aDadAux[nX,3] } )
		aAdd( aCposDet, aAux )
		
	Next

	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabSB
Rotina auxiliar de Importação - SUB FUNCAO

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabSB()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}
Local aDadAux := {}
Local nX := 0

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"SB")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "SB"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "SUB FUNCAO"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "2" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 9 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 3 } )

	//carrega os dados de acordo a tabela
	aAdd( aDadAux, { "SB","031","AÇÃO LEGISLATIVA" } )
	aAdd( aDadAux, { "SB","032","CONTROLE EXTERNO" } )
	aAdd( aDadAux, { "SB","061","AÇÃO JUDICIÁRIA" } )
	aAdd( aDadAux, { "SB","062","DEFESA DO INTERESSE PÚBLICO NO PROCESSO JUDICIÁRIO" } )
	aAdd( aDadAux, { "SB","091","DEFESA DA ORDEM JURÍDICA" } )
	aAdd( aDadAux, { "SB","092","REPRESENTAÇAO JUDICIAL E EXTRAJUDICIAL" } )
	aAdd( aDadAux, { "SB","121","PLANEJAMENTO E ORÇAMENTO" } )
	aAdd( aDadAux, { "SB","122","ADMINISTRAÇÃO GERAL" } )
	aAdd( aDadAux, { "SB","123","ADMINISTRAÇÃO FINANCEIRA" } )
	aAdd( aDadAux, { "SB","124","CONTROLE EXTERNO" } )
	aAdd( aDadAux, { "SB","125","NORMATIZAÇÃO E FISCALIZAÇÃO" } )
	aAdd( aDadAux, { "SB","126","TECNOLOGIA DA INFORMATIZAÇÃO" } )
	aAdd( aDadAux, { "SB","127","ORDENAMENTO TERRITORIAL" } )
	aAdd( aDadAux, { "SB","128","FORMAÇÃO DE RECURSOS HUMANOS" } )
	aAdd( aDadAux, { "SB","129","ADMINISTRAÇÃO DE RECEITAS" } )
	aAdd( aDadAux, { "SB","130","ADMINISTRAÇÃO DE CONCESSÕES" } )
	aAdd( aDadAux, { "SB","131","COMUNICAÇÃO SOCIAL" } )
	aAdd( aDadAux, { "SB","151","DEFESA AÉREA" } )
	aAdd( aDadAux, { "SB","152","DESFESA NAVAL" } )
	aAdd( aDadAux, { "SB","153","DEFESA TERRESTRE" } )
	aAdd( aDadAux, { "SB","181","POLICIAMENTO" } )
	aAdd( aDadAux, { "SB","182","DEFESA CIVIL" } )
	aAdd( aDadAux, { "SB","183","INFORMAÇÃO E INTELIGÊNCIA" } )
	aAdd( aDadAux, { "SB","211","RELAÇÕES DIPLOMÁTICAS" } )
	aAdd( aDadAux, { "SB","212","COOPERAÇÃO INTERNACIONAL" } )
	aAdd( aDadAux, { "SB","241","ASSISTÊNCIA AO IDOSO" } )
	aAdd( aDadAux, { "SB","242","ASSISTÊNCIA AO PORTADOR DE DEFICIÊNCIA" } )
	aAdd( aDadAux, { "SB","243","ASSISTÊNCIA À CRIANÇA E AO ADOSLESCENTE" } )
	aAdd( aDadAux, { "SB","244","ASSISTÊNCIA COMUNITÁRIA" } )
	aAdd( aDadAux, { "SB","271","PREVIDÊNCIA BÁSICA" } )
	aAdd( aDadAux, { "SB","272","PREVIDÊNCIA DO REGIME ESTATUTÁRIO" } )
	aAdd( aDadAux, { "SB","273","PREVIDÊNCIA COMPLEMENTAR" } )
	aAdd( aDadAux, { "SB","274","PREVIDÊNCIA ESPECIAL" } )
	aAdd( aDadAux, { "SB","301","ATENÇÃO BÁSICA" } )
	aAdd( aDadAux, { "SB","302","ASSISTÊNCIA HOSPITALAR E AMBULATORIAL" } )
	aAdd( aDadAux, { "SB","303","SUPORTE PROFILÁTICO E TERAPÊUTICO" } )
	aAdd( aDadAux, { "SB","304","VIGILÂNCIA SANITÁRIA" } )
	aAdd( aDadAux, { "SB","305","VIGILÂNCIA EPIDEMIOLÓGICA" } )
	aAdd( aDadAux, { "SB","306","ALIMENTAÇÃO E NUTRIÇÃO" } )
	aAdd( aDadAux, { "SB","331","PROTEÇÃO E BENEFÍCIOS AO TRABALHADOR" } )
	aAdd( aDadAux, { "SB","332","RELAÇÃO DE TRABALHO" } )
	aAdd( aDadAux, { "SB","333","EMPREGABILIDADE" } )
	aAdd( aDadAux, { "SB","334","FOMENTO AO TRABALHO" } )
	aAdd( aDadAux, { "SB","361","ENSINO FUNDAMENTAL" } )
	aAdd( aDadAux, { "SB","362","ENSINO MÉDIO" } )
	aAdd( aDadAux, { "SB","363","ENSINO PROFISSIONAL" } )
	aAdd( aDadAux, { "SB","364","ENSINO SUPERIOR" } )
	aAdd( aDadAux, { "SB","365","EDUCAÇÃO INFANTIL" } )
	aAdd( aDadAux, { "SB","366","EDUCAÇÃO DE JOVENS E ADULTOS" } )
	aAdd( aDadAux, { "SB","367","EDUCAÇÃO ESPECIAL" } )
	aAdd( aDadAux, { "SB","368","EDUCAÇÃO BÁSICA" } )
	aAdd( aDadAux, { "SB","391","PATRIMÔNIO HISTÓRICO, ARTÍSTICO E ARQUEOLÓGICO" } )
	aAdd( aDadAux, { "SB","392","DIFUSÃO CULTURAL" } )
	aAdd( aDadAux, { "SB","421","CUSTÓDIA E REINTEGRAÇÃO SOCIAL" } )
	aAdd( aDadAux, { "SB","422","DIREITOS INDIVIDUAIS, COLETIVOS E DIFUSOS" } )
	aAdd( aDadAux, { "SB","423","ASSISTÊNCIA AOS POVOS INDÍGENAS" } )
	aAdd( aDadAux, { "SB","451","INFRA-ESTRUTURA URBANA" } )
	aAdd( aDadAux, { "SB","452","SERVIÇOS URBNOS" } )
	aAdd( aDadAux, { "SB","453","TRANSPORTES COLETIVOS URBANOS" } )
	aAdd( aDadAux, { "SB","481","HABITAÇÃO RURAL" } )
	aAdd( aDadAux, { "SB","482","HABITAÇÃO URBANA" } )
	aAdd( aDadAux, { "SB","511","SANEAMENTO BÁSICO RURAL" } )
	aAdd( aDadAux, { "SB","512","SANEAMENTO BÁSICO URBANO" } )
	aAdd( aDadAux, { "SB","541","PRESERVAÇÃO E CONSERVAÇÃO AMBIENTAL" } )
	aAdd( aDadAux, { "SB","542","CONTROLE AMBIENTAL" } )
	aAdd( aDadAux, { "SB","543","RECUPERAÇÃO DE ÁREAS DEGRADADAS" } )
	aAdd( aDadAux, { "SB","544","RECURSOS HÍDRICOS" } )
	aAdd( aDadAux, { "SB","545","METEOROLOGIA" } )
	aAdd( aDadAux, { "SB","571","DESENVOLVIMENTO CIENTÍFICO" } )
	aAdd( aDadAux, { "SB","572","DESENVOLVIMENTO TECNOLÓGICO E ENGENHARIA" } )
	aAdd( aDadAux, { "SB","573","DIFUSÃO DO CONHECIMENTO CIENTÍFICO E TECNOLÓGICO" } )
	aAdd( aDadAux, { "SB","605","ABASTECIMENTO" } )
	aAdd( aDadAux, { "SB","606","EXTENSÃO RURAL" } )
	aAdd( aDadAux, { "SB","607","IRRIGAÇÃO" } )
	aAdd( aDadAux, { "SB","608","PROMOÇÃO DA PRODUÇÃO AGROPECUÁRIA" } )
	aAdd( aDadAux, { "SB","609","DEFESA AGROPECUÁRIA" } )
	aAdd( aDadAux, { "SB","631","REFORMA AGRÁRIA" } )
	aAdd( aDadAux, { "SB","632","COLONIZAÇÃO" } )
	aAdd( aDadAux, { "SB","661","PROMOÇÃO INDUSTRIAL" } )
	aAdd( aDadAux, { "SB","662","PRODUÇÃO INDUSTRIAL" } )
	aAdd( aDadAux, { "SB","663","MINERAÇÃO" } )
	aAdd( aDadAux, { "SB","664","PROPRIEDADE INDUSTRIAL" } )
	aAdd( aDadAux, { "SB","665","NORMALIZAÇÃO E QUALIDADE" } )
	aAdd( aDadAux, { "SB","691","PROMOÇÃO COMERCIAL" } )
	aAdd( aDadAux, { "SB","692","COMERCIALIZAÇÃO" } )
	aAdd( aDadAux, { "SB","693","COMÉRCIO EXTERIOR" } )
	aAdd( aDadAux, { "SB","694","SERVIÇOS FINANCEIROS" } )
	aAdd( aDadAux, { "SB","695","TURISMO" } )
	aAdd( aDadAux, { "SB","721","COMUNICAÇÕES POSTAIS" } )
	aAdd( aDadAux, { "SB","722","TELECOMUNICAÇÕES" } )
	aAdd( aDadAux, { "SB","751","CONSERVAÇÃO DE ENERGIA" } )
	aAdd( aDadAux, { "SB","752","ENERGIA ELÉTRICA" } )
	aAdd( aDadAux, { "SB","753","PETRÓLEO" } )
	aAdd( aDadAux, { "SB","754","ÁLCOOL" } )
	aAdd( aDadAux, { "SB","781","TRANSPORTE AÉREO" } )
	aAdd( aDadAux, { "SB","782","TRANSPORTE RODOVIÁRIO" } )
	aAdd( aDadAux, { "SB","783","TRANSPORTE FERROVIÁRIO" } )
	aAdd( aDadAux, { "SB","784","TRANSPORTE HIDROVIÁRIO" } )
	aAdd( aDadAux, { "SB","785","TRANSPORTES ESPECIAIS" } )
	aAdd( aDadAux, { "SB","811","DESPORTO DE RENDIMENTO" } )
	aAdd( aDadAux, { "SB","812","DESPORTO COMUNITÁRIO" } )
	aAdd( aDadAux, { "SB","813","LAZER" } )
	aAdd( aDadAux, { "SB","841","REFINANCIAMENTO DA DÍVIDA INTERNA" } )
	aAdd( aDadAux, { "SB","842","REFINANCIAMENTO DA DÍVIDA EXTERNA" } )
	aAdd( aDadAux, { "SB","843","SERVIÇO DA DÍVIDA INTERNA" } )
	aAdd( aDadAux, { "SB","844","SERVIÇO DA DÍVIDA EXTERNA" } )
	aAdd( aDadAux, { "SB","845","OUTRAS TRANSFERÊNCIAS" } )
	aAdd( aDadAux, { "SB","847","TRANSFERÊNCIAS PARA A EDUCAÇÃO BÁSICA" } )
	aAdd( aDadAux, { "SB","846","OUTROS ENCARGOS ESPECIAIS" } )
	aAdd( aDadAux, { "SB","997","RESERVA DE CONTIGÊNCIA PARA O RPPS" } )
	aAdd( aDadAux, { "SB","999","RESERVA DE CONTIGÊNCIA GERAL" } )

	aCposDet := {}

	For nX := 1 To Len(aDadAux)
		
		aAux := {}
		aAdd( aAux, { "A1H_ITETAB" , StrZero(nX, 4)} )
		aAdd( aAux, { "A1H_RADCHV", aDadAux[nX,1] } )
		aAdd( aAux, { "A1H_ITECHV", aDadAux[nX,2] } )
		aAdd( aAux, { "A1H_CHVCNT", aDadAux[nX,3] } )
		aAdd( aCposDet, aAux )
		
	Next

	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabDE
Rotina auxiliar de Importação - CATEGORIA ECONÔMICA DE DESPESAS

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabDE()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}
Local aDadAux := {}
Local nX := 0

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"DE")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "DE"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "CATEGORIA ECONÔMICA DE DESPESAS"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "2" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 20 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	//carrega os dados de acordo a tabela
	aAdd( aDadAux, { "DE","3","DESPESAS CORRENTES" } )
	aAdd( aDadAux, { "DE","4","DESPESAS DE CAPITAL" } )
	aAdd( aDadAux, { "DE","9","RESERVA DE CONTINGÊNCIA" } )

	aCposDet := {}

	For nX := 1 To Len(aDadAux)
		
		aAux := {}
		aAdd( aAux, { "A1H_ITETAB" , StrZero(nX, 4)} )
		aAdd( aAux, { "A1H_RADCHV", aDadAux[nX,1] } )
		aAdd( aAux, { "A1H_ITECHV", aDadAux[nX,2] } )
		aAdd( aAux, { "A1H_CHVCNT", aDadAux[nX,3] } )
		aAdd( aCposDet, aAux )
		
	Next

	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabGD
Rotina auxiliar de Importação - GRUPO DA DESPESA

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabGD()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}
Local aDadAux := {}
Local nX := 0

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"GD")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "GD"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "GRUPO DA DESPESA"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "2" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 21 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 1 } )

	//carrega os dados de acordo a tabela
	aAdd( aDadAux, { "GD","0","RESTOS A PAGAR" }  )
	aAdd( aDadAux, { "GD","1","PESSOAL E ENCARGOS SOCIAIS" }  )
	aAdd( aDadAux, { "GD","2","JUROS E ENCARGOS DA DÍVIDA" }  )
	aAdd( aDadAux, { "GD","3","OUTRAS DESPESAS CORRENTES" }  )
	aAdd( aDadAux, { "GD","4","INVESTIMENTOS" }  )
	aAdd( aDadAux, { "GD","5","INVERSÕES FINANCEIRAS" }  )
	aAdd( aDadAux, { "GD","6","AMORTIZAÇÃO DA DÍVIDA" }  )
	aAdd( aDadAux, { "GD","8","EXTRAORÇAMENTÁRIA" }  )
	aAdd( aDadAux, { "GD","9","RESERVA DE CONTINGÊNCIA" }  )


	aCposDet := {}

	For nX := 1 To Len(aDadAux)
		
		aAux := {}
		aAdd( aAux, { "A1H_ITETAB" , StrZero(nX, 4)} )
		aAdd( aAux, { "A1H_RADCHV", aDadAux[nX,1] } )
		aAdd( aAux, { "A1H_ITECHV", aDadAux[nX,2] } )
		aAdd( aAux, { "A1H_CHVCNT", aDadAux[nX,3] } )
		aAdd( aCposDet, aAux )
		
	Next

	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabMA
Rotina auxiliar de Importação - MODALIDADE DA APLICACAO

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabMA()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}
Local aDadAux := {}
Local nX := 0

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"MA")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "MA"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "MODALIDADE DA APLICACAO"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "2" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 22 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 2 } )

		//carrega os dados de acordo a tabela
	aAdd( aDadAux, { "MA","22","EXEC.ORÇAM. DELEGADA A UNIÃO" }  ) 
	aAdd( aDadAux, { "MA","30","TRANSF.A ESTADOS E AO DISTR. FEDERAL" }  ) 
	aAdd( aDadAux, { "MA","31","TRANSF.A ESTADOS E AO DISTR. FEDERAL-FUNDO A FUNDO" }  ) 
	aAdd( aDadAux, { "MA","32","EXEC.ORÇAM. DELEGADA A ESTADOS E AO DISTR. FEDERAL" }  ) 
	aAdd( aDadAux, { "MA","35","TRANSF.F A F (DO ART. 24) AOS ESTADOS E D.FEDERAL" }  ) 
	aAdd( aDadAux, { "MA","36","TRANSF.F A F (DO ART. 25)AOS ESTADOS E D.FEDERAL" }  ) 
	aAdd( aDadAux, { "MA","40","TRANSF.A MUNICÍPIOS" }  ) 
	aAdd( aDadAux, { "MA","41","TRANSF.A MUNICÍPIOS F A FUNDO " }  ) 
	aAdd( aDadAux, { "MA","42","EXEC.ORÇAM. DELEGADA A MUNICÍPIOS" }  ) 
	aAdd( aDadAux, { "MA","45","TRANSF.F A F AOS MUNICÍPIOS À CONTA DE REC.ART. 24" }  ) 
	aAdd( aDadAux, { "MA","46","TRANSF.F A F AOS MUNICÍPIOS À CONTA DE REC.ART. 25" }  ) 
	aAdd( aDadAux, { "MA","50","TRANSF.A INSTIT. PRIVADAS SEM FINS LUCRATIVOS" }  ) 
	aAdd( aDadAux, { "MA","60","TRANSF.A INSTIT. PRIVADAS COM FINS LUCRATIVOS" }  ) 
	aAdd( aDadAux, { "MA","67","EXEC.DE CONTRATO DE PARCERIA PÚBLICO PRIVADA" }  ) 
	aAdd( aDadAux, { "MA","70","TRANSF.A INSTIT. MULTIGOV." }  ) 
	aAdd( aDadAux, { "MA","71","TRANSF.A CONS.PÚBL.MED.CONTRATO DE RATEIO" }  ) 
	aAdd( aDadAux, { "MA","72","EXEC.ORÇAM. DELEGADA A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "MA","73","TRANSF.A CONS.PÚBL.MED.CONTR.RATEIO...ART. 24" }  ) 
	aAdd( aDadAux, { "MA","74","TRANSF.A CONS.PÚBL.MED.CONTR.RATEIO...ART. 25" }  ) 
	aAdd( aDadAux, { "MA","75","TRANSF.A INSTIT. MULTIGOV.CTA REC...ART. 24" }  ) 
	aAdd( aDadAux, { "MA","76","TRANSF.A INSTIT. MULTIGOV.CTA REC...ART. 25" }  ) 
	aAdd( aDadAux, { "MA","80","TRANSFERÊNCIAS AO EXTERIOR" }  ) 
	aAdd( aDadAux, { "MA","90","APLICAÇÕES DIRETAS" }  ) 
	aAdd( aDadAux, { "MA","91","APLIC.DIR. DECOR. DE OPER. ENTRE ÓRGÃOS,..." }  ) 
	aAdd( aDadAux, { "MA","92","APLIC.DIR. DE REC. RECEBIDOS DE OUTROS ENTES..." }  ) 
	aAdd( aDadAux, { "MA","93","APLIC.DIR. DECOR. DE OPER. DE ÓRGÃOS, FUNDOS..." }  ) 
	aAdd( aDadAux, { "MA","94","APLIC.DIR. DECOR. DE OPERAÇÕES DE ÓRGÃOS,FUNDOS..." }  ) 
	aAdd( aDadAux, { "MA","95","APLIC.DIR. À CONTA DE REC. DE QUE ... ART. 24 " }  ) 
	aAdd( aDadAux, { "MA","96","APLIC.DIR. À CONTA DE REC. DE QUE ....ART. 25 " }  ) 
	aAdd( aDadAux, { "MA","99","RESERVA DE CONTINGÊNCIA" } )

	aCposDet := {}

	For nX := 1 To Len(aDadAux)
		
		aAux := {}
		aAdd( aAux, { "A1H_ITETAB" , StrZero(nX, 4)} )
		aAdd( aAux, { "A1H_RADCHV", aDadAux[nX,1] } )
		aAdd( aAux, { "A1H_ITECHV", aDadAux[nX,2] } )
		aAdd( aAux, { "A1H_CHVCNT", aDadAux[nX,3] } )
		aAdd( aCposDet, aAux )
		
	Next

	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabED
Rotina auxiliar de Importação - ELEMENTO DA DESPESA

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabED()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}
Local aDadAux := {}
Local nX := 0

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"ED")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "ED"  } )
	aAdd( aCposCab, { "A1G_DESTAB", " ELEMENTO DA DESPESA"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "2" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 24 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 2 } )

	//carrega os dados de acordo a tabela
	aAdd( aDadAux, { "ED","01","APOSENTADORIAS, RESERVA REMUNERADA E REFORMAS" }  )
	aAdd( aDadAux, { "ED","03","PENSÕES" }  )
	aAdd( aDadAux, { "ED","04","CONTRATAÇÃO POR TEMPO DETERMINADO" }  )
	aAdd( aDadAux, { "ED","05","OUTROS BENEFÍCIOS PREVID.DO SERVIDOR OU MILITAR" }  )
	aAdd( aDadAux, { "ED","06","BENEFÍCIO MENSAL AO DEFICIENTE E AO IDOSO" }  )
	aAdd( aDadAux, { "ED","07","CONTRIBUIÇÕES A ENTIDADES FECHADAS DE PREVIDÊNCIA" }  )
	aAdd( aDadAux, { "ED","08","OUTROS BENEFÍCIOS ASSIST.DO SERVIDOR E DO MILITAR" }  )
	aAdd( aDadAux, { "ED","11","VENCIMENTOS E VANTAGENS FIXAS - PESSOAL CIVIL" }  )
	aAdd( aDadAux, { "ED","13","OBRIGAÇÕES PATRONAIS" }  )
	aAdd( aDadAux, { "ED","14","DIÁRIAS - PESSOAL CIVIL" }  )
	aAdd( aDadAux, { "ED","16","OUTRAS DESPESAS VARIÁVEIS - PESSOAL CIVIL" }  )
	aAdd( aDadAux, { "ED","21","JUROS SOBRE A DÍVIDA POR CONTRATO" }  )
	aAdd( aDadAux, { "ED","22","OUTROS ENCARGOS SOBRE A DÍVIDA POR CONTRATO" }  )
	aAdd( aDadAux, { "ED","23","JUROS, DESÁGIOS E DESCONTOS DA DÍVIDA MOBILIÁRIA" }  )
	aAdd( aDadAux, { "ED","24","OUTROS ENCARGOS SOBRE A DÍVIDA MOBILIÁRIA" }  )
	aAdd( aDadAux, { "ED","25","ENCARGOS SOBRE OPER.CRÉDITO POR ANTECIP.RECEITA" }  )
	aAdd( aDadAux, { "ED","30","MATERIAL DE CONSUMO" }  )
	aAdd( aDadAux, { "ED","32","MATERIAL,BEM OU SERVIÇO PARA DISTRIBUIÇÃO GRATUITA" }  )
	aAdd( aDadAux, { "ED","33","PASSAGENS E DESPESAS COM LOCOMOÇÃO" }  )
	aAdd( aDadAux, { "ED","35","SERVIÇOS DE CONSULTORIA" }  )
	aAdd( aDadAux, { "ED","36","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  )
	aAdd( aDadAux, { "ED","37","LOCAÇÃO DE MÃO DE OBRA" }  )
	aAdd( aDadAux, { "ED","38","ARRENDAMENTO MERCANTIL" }  )
	aAdd( aDadAux, { "ED","39","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  )
	aAdd( aDadAux, { "ED","40","SERVIÇOS TECN.INFORMAÇÃO E COM. - PESSOA JURÍDICA" }  )
	aAdd( aDadAux, { "ED","45","SUBVENÇÕES ECONÔMICAS" }  )
	aAdd( aDadAux, { "ED","46","AUXÍLIO ALIMENTAÇÃO" }  )
	aAdd( aDadAux, { "ED","47","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS-INTRA OFSS" }  )
	aAdd( aDadAux, { "ED","48","OUTROS AUXÍLIOS FINANCEIROS A PESSOA FÍSICA" }  )
	aAdd( aDadAux, { "ED","49","AUXÍLIO TRANSPORTE" }  )
	aAdd( aDadAux, { "ED","51","OBRAS E INSTALAÇÕES" }  )
	aAdd( aDadAux, { "ED","52","EQUIPAMENTOS E MATERIAL PERMANENTE" }  )
	aAdd( aDadAux, { "ED","61","AQUISIÇÃO DE IMÓVEIS" }  )
	aAdd( aDadAux, { "ED","65","CONSTITUIÇÃO OU AUMENTO DE CAPITAL DE EMPRESAS" }  )
	aAdd( aDadAux, { "ED","67","DEPÓSITOS COMPULSÓRIOS" }  )
	aAdd( aDadAux, { "ED","70","RATEIO PELA PARTICIPACAO EM CONSORCIO PUBLICO" }  )
	aAdd( aDadAux, { "ED","71","PRINCIPAL DA DÍVIDA CONTRATUAL RESGATADA" }  )
	aAdd( aDadAux, { "ED","72","PRINCIPAL DA DÍVIDA MOBILIÁRIA RESGATADO" }  )
	aAdd( aDadAux, { "ED","76","PRINCIPAL CORRIGIDO DÍVIDA MOBILIÁRIA REFINANCIADO" }  )
	aAdd( aDadAux, { "ED","77","PRINCIPAL CORRIGIDO DÍVIDA CONTRATUAL REFINANCIADO" }  )
	aAdd( aDadAux, { "ED","82","APORTE RECURSOS PARCEIRO PÚBLICO...DECORRENTE PPP" }  )
	aAdd( aDadAux, { "ED","83","CONTR. PPP, EXCETO SUBVENÇÕES ECON,APORTE FUNDO..." }  )
	aAdd( aDadAux, { "ED","91","SENTENÇAS JUDICIAIS" }  )
	aAdd( aDadAux, { "ED","92","DESPESAS DE EXERCÍCIOS ANTERIORES" }  )
	aAdd( aDadAux, { "ED","93","INDENIZAÇÕES E RESTITUIÇÕES" }  )
	aAdd( aDadAux, { "ED","94","INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS" }  )
	aAdd( aDadAux, { "ED","96","RESSARCIMENTO DE DESPESAS DE PESSOAL REQUISITADO" }  )
	aAdd( aDadAux, { "ED","99","RESERVA DE CONTINGÊNCIA" }  )	
	
	
	aCposDet := {}

	For nX := 1 To Len(aDadAux)
		
		aAux := {}
		aAdd( aAux, { "A1H_ITETAB" , StrZero(nX, 4)} )
		aAdd( aAux, { "A1H_RADCHV", aDadAux[nX,1] } )
		aAdd( aAux, { "A1H_ITECHV", aDadAux[nX,2] } )
		aAdd( aAux, { "A1H_CHVCNT", aDadAux[nX,3] } )
		aAdd( aCposDet, aAux )
		
	Next

	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabFR
Rotina auxiliar de Importação - FONTE DE RECURSO

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabFR()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}
Local aDadAux := {}
Local nX := 0

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"FR")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "FR"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "FONTE DE RECURSO"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "2" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 32 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 2 } )

	//carrega os dados de acordo a tabela
	aAdd( aDadAux, { "FR","01","TESOURO" }  ) 
	aAdd( aDadAux, { "FR","02","TRANSFERÊNCIAS E CONVÊNIOS ESTADUAIS - VINCULADOS" }  ) 
	aAdd( aDadAux, { "FR","03","RECURSOS PRÓPRIOS DE FUNDOS ESP.DESPESA - VINC." }  ) 
	aAdd( aDadAux, { "FR","04","RECURSOS PRÓPRIOS DA ADMINISTRAÇÃO INDIRETA" }  ) 
	aAdd( aDadAux, { "FR","05","TRANSFERÊNCIAS E CONVÊNIOS FEDERAIS - VINCULADOS" }  ) 
	aAdd( aDadAux, { "FR","06","OUTRAS FONTES DE RECURSOS" }  ) 
	aAdd( aDadAux, { "FR","07","OPERAÇÕES DE CRÉDITO" }  ) 
	aAdd( aDadAux, { "FR","08","EMENDAS PARLAMENTARES INDIVIDUAIS" }  ) 
	aAdd( aDadAux, { "FR","91","TESOURO - Exercícios Anteriores" }  ) 
	aAdd( aDadAux, { "FR","92","TRANSF.CONVÊNIOS ESTADUAIS-VINC.- Exerc.Anteriores" }  ) 
	aAdd( aDadAux, { "FR","93","REC.PRÓP.FUNDOS ESP.DESPESA-VINCULADOS - Ex.Anter." }  ) 
	aAdd( aDadAux, { "FR","94","REC.PRÓP.ADMINISTRAÇÃO INDIRETA-Exerc.Anteriores" }  ) 
	aAdd( aDadAux, { "FR","95","TRANSF. E CONVÊNIOS FEDERAIS-VINC.-Exerc.Anter." }  ) 
	aAdd( aDadAux, { "FR","96","OUTRAS FONTES DE RECURSOS-Exercícios Anteriores" }  ) 
	aAdd( aDadAux, { "FR","97","OPERAÇÕES DE CRÉDITO - Exercícios Anteriores" }  ) 
	aAdd( aDadAux, { "FR","98","EMENDAS PARLAMENTARES INDIVIDUAIS-Exerc.Anteriores" }  ) 
	
	aCposDet := {}

	For nX := 1 To Len(aDadAux)
		
		aAux := {}
		aAdd( aAux, { "A1H_ITETAB" , StrZero(nX, 4)} )
		aAdd( aAux, { "A1H_RADCHV", aDadAux[nX,1] } )
		aAdd( aAux, { "A1H_ITECHV", aDadAux[nX,2] } )
		aAdd( aAux, { "A1H_CHVCNT", aDadAux[nX,3] } )
		aAdd( aCposDet, aAux )
		
	Next

	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabSE
Rotina auxiliar de Importação - TABELA SE - ELEMENTO/SUB-ELEMENTO DA DESPESA

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabSE()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}
Local aDadAux := {}
Local nX := 0

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"SE")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "SE"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "ELEMENTO/SUB-ELEMENTO DA DESPESA"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "2" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 24 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 8 } )

	//carrega os dados de acordo a tabela
	aAdd( aDadAux, { "SE","31304100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","31704100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","31717000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","31737000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO - §§ 1º E 2º DO ART 24 DA LEI COMPLEMENTAR NO 141, DE 2012" }  ) 
	aAdd( aDadAux, { "SE","31747000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO - ART 25 DA LEI COMPLEMENTAR NO 141, DE 2012" }  ) 
	aAdd( aDadAux, { "SE","31800400","CONTRATAÇÃO POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","31900101","PROVENTOS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900106","13º SALÁRIO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900151","ADICIONAIS, VANTAGENS, GRATIFICAÇÕES E OUTROS COMPLEMENTOS DE PROVENTOS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900187","COMPLEMENTAÇÃO DE APOSENTADORIAS" }  ) 
	aAdd( aDadAux, { "SE","31900199","OUTRAS APOSENTADORIAS" }  ) 
	aAdd( aDadAux, { "SE","31900301","PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900303","13º SALÁRIO - PESSOAL CIVIL - PENSIONISTAS" }  ) 
	aAdd( aDadAux, { "SE","31900351","ADICIONAIS, VANTAGENS, GRATIFICAÇÕES E OUTROS COMPLEMENTOS DE PENSÕES - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900386","COMPLEMENTAÇÃO DE PENSÕES - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900399","OUTRAS PENSÕES" }  ) 
	aAdd( aDadAux, { "SE","31900401","PROFESSORES SUBSTITUTOS / VISITANTES" }  ) 
	aAdd( aDadAux, { "SE","31900402","13º SALÁRIO - CONTRATAÇÃO POR TEMPO DETERMINADO" }  ) 
	//aAdd( aDadAux, { "SE","31900402","PROFESSORES SUBSTITUTOS / VISITANTES" }  ) 
	aAdd( aDadAux, { "SE","31900403","FÉRIAS - CONTRATAÇÃO POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","31900411","SALÁRIOS - CONTRATO TEMPORÁRIO" }  ) 
	aAdd( aDadAux, { "SE","31900412","SALÁRIOS - CONTRATO TEMPORÁRIO" }  ) 
	aAdd( aDadAux, { "SE","31900413","13º SALÁRIO - CONTRATO TEMPORÁRIO" }  ) 
	aAdd( aDadAux, { "SE","31900414","FERIAS - ABONO CONSTITUCIONAL - CONTRATO TEMPORÁRIO" }  ) 
	aAdd( aDadAux, { "SE","31900415","OBRIGAÇÕES PATRONAIS - OUTRAS - CONTRATO TEMPORÁRIO" }  ) 
	aAdd( aDadAux, { "SE","31900416","OBRIGAÇÕES PATRONAIS - INSS - CONTRATO TEMPORÁRIO" }  ) 
	aAdd( aDadAux, { "SE","31900417","OBRIGAÇÕES PATRONAIS - FGTS - CONTRATO TEMPORÁRIO" }  ) 
	aAdd( aDadAux, { "SE","31900451","ADICIONAIS DE CONTRATO TEMPORÁRIO" }  ) 
	aAdd( aDadAux, { "SE","31900499","OUTRAS CONTRATAÇÕES POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","31900501","SALÁRIO FAMÍLIA - ATIVO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900502","SALÁRIO FAMÍLIA - INATIVO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900505","SALÁRIO FAMÍLIA - PENSIONISTA - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900509","SALÁRIOS FAMÍLIA - OUTROS" }  ) 
	aAdd( aDadAux, { "SE","31900510","AUXILIO RECLUSÃO ATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900511","AUXILIO RECLUSÃO INATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900551","AUXÍLIO DOENÇA" }  ) 
	aAdd( aDadAux, { "SE","31900521","AUXILIO RECLUSÃO - ATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900522","AUXILIO RECLUSÃO - INATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900523","SALÁRIO FAMÍLIA - ATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900525","SALÁRIO FAMÍLIA - INATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900527","SALÁRIO-FAMÍLIA PENSIONISTA CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900529","AUXÍLIO DOENÇA" }  ) 
	aAdd( aDadAux, { "SE","31900530","SALÁRIO MATERNIDADE" }  ) 
	aAdd( aDadAux, { "SE","31900554","AUXÍLIO ACIDENTE" }  ) 
	aAdd( aDadAux, { "SE","31900556","SALÁRIO MATERNIDADE" }  ) 
	aAdd( aDadAux, { "SE","31900561","ABONO ANUAL - 13º SALÁRIO" }  ) 
	aAdd( aDadAux, { "SE","31900598","OUTROS BENEFÍCIOS PREVIDENCIÁRIOS - CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31900599","OUTROS BENEFÍCIOS PREVIDENCIÁRIOS" }  ) 
	aAdd( aDadAux, { "SE","31900701","COMPLEMENTAÇÃO DE PREVIDÊNCIA" }  ) 
	aAdd( aDadAux, { "SE","31900702","SEGUROS" }  ) 
	aAdd( aDadAux, { "SE","31900704","CONTRIBUIÇÃO PATRONAL A ENTIDADES FECHADAS DE PREVIDÊNCIA - PDV" }  ) 
	aAdd( aDadAux, { "SE","31900711","CONTRIBUIÇÃO PATRONAL A ENTIDADES FECHADAS DE PREVIDÊNCIA" }  ) 
	aAdd( aDadAux, { "SE","31900798","OUTRAS CONTRIBUIÇÕES A ENTIDADES FECHADAS DE PREVIDÊNCIA" }  ) 
	aAdd( aDadAux, { "SE","31900799","OUTRAS CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","31901101","VENCIMENTOS E SALÁRIOS" }  ) 
	aAdd( aDadAux, { "SE","31901102","FÉRIAS CONVERTIDAS EM PECÚNIA" }  ) 
	aAdd( aDadAux, { "SE","31901104","ADICIONAL NOTURNO" }  ) 
	aAdd( aDadAux, { "SE","31901105","INCORPORAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","31901107","ABONO DE PERMANÊNCIA" }  ) 
	aAdd( aDadAux, { "SE","31901108","ADIANTAMENTO PECUNIÁRIO" }  ) 
	aAdd( aDadAux, { "SE","31901109","ADICIONAL DE PERICULOSIDADE" }  ) 
	aAdd( aDadAux, { "SE","31901110","ADICIONAL DE INSALUBRIDADE" }  ) 
	aAdd( aDadAux, { "SE","31901111","ADICIONAL DE ATIVIDADES PENOSAS" }  ) 
	aAdd( aDadAux, { "SE","31901131","GRATIFICAÇÕES POR EXERCÍCIO DE CARGO" }  ) 
	aAdd( aDadAux, { "SE","31901133","GRATIFICAÇÃO POR EXERCÍCIO DE FUNÇÕES" }  ) 
	aAdd( aDadAux, { "SE","31901137","GRATIFICAÇÃO POR TEMPO DE SERVIÇO" }  ) 
	aAdd( aDadAux, { "SE","31901142","FÉRIAS INDENIZADAS, VENCIDAS E PROPORCIONAIS" }  ) 
	aAdd( aDadAux, { "SE","31901143","13º SALÁRIO" }  ) 
	aAdd( aDadAux, { "SE","31901144","FÉRIAS - ABONO PECUNIÁRIO" }  ) 
	aAdd( aDadAux, { "SE","31901145","FÉRIAS - ABONO CONSTITUCIONAL" }  ) 
	aAdd( aDadAux, { "SE","31901146","FÉRIAS - PAGAMENTO ANTECIPADO" }  ) 
	aAdd( aDadAux, { "SE","31901147","LICENÇA PRÊMIO" }  ) 
	aAdd( aDadAux, { "SE","31901149","LICENÇA CAPACITAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","31901150","VENCIMENTOS E SALÁRIOS - PRORROGAÇÃO SALÁRIO MATERNIDADE" }  ) 
	aAdd( aDadAux, { "SE","31901151","OUTROS ADICIONAIS, VANTAGENS, GRATIFICAÇÕES E OUTROS COMPLEMENTOS DE SALÁRIOS" }  ) 
	aAdd( aDadAux, { "SE","31901160","REMUNERAÇÃO DOS AGENTES POLÍTICOS" }  ) 
	aAdd( aDadAux, { "SE","31901173","REMUNERAÇÃO PELA PARTICIPAÇÃO EM ÓRGÃOS DE DELIBERAÇÃO COLETIVA" }  ) 
	aAdd( aDadAux, { "SE","31901174","SUBSÍDIOS (EXCETO AGENTES POLÍTICOS)" }  ) 
	aAdd( aDadAux, { "SE","31901175","SUBSÍDIOS - AGENTES POLÍTICOS" }  ) 
	aAdd( aDadAux, { "SE","31901177","REMUNERAÇÃO DE PESSOAL EM DISPONIBILIDADE" }  ) 
	aAdd( aDadAux, { "SE","31901187","COMPLEMENTAÇÃO SALARIAL - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31901199","OUTRAS DESPESAS FIXAS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31901301","FGTS" }  ) 
	aAdd( aDadAux, { "SE","31901302","CONTRIBUIÇÕES PREVIDENCIÁRIAS - INSS" }  ) 
	aAdd( aDadAux, { "SE","31901308","CONTRIBUIÇÕES PREVIDENCIÁRIAS - RPPS - PESSOAL ATIVO" }  ) 
	aAdd( aDadAux, { "SE","31901311","FGTS - PDV" }  ) 
	aAdd( aDadAux, { "SE","31901318","PIS/PASEP SOBRE FOLHA DE PAGAMENTO" }  ) 
	aAdd( aDadAux, { "SE","31901340","ENCARGOS DE PESSOAL REQUISITADO DE OUTROS ENTES" }  ) 
	aAdd( aDadAux, { "SE","31901399","OUTRAS OBRIGAÇÕES PATRONAIS" }  ) 
	aAdd( aDadAux, { "SE","31901608","GRATIFICAÇÃO ELEITORAL" }  ) 
	aAdd( aDadAux, { "SE","31901632","SUBSTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","31901634","AVISO PRÉVIO" }  ) 
	aAdd( aDadAux, { "SE","31901636","ADICIONAL POR PLANTÃO HOSPITALAR" }  ) 
	aAdd( aDadAux, { "SE","31901644","SERVIÇOS EXTRAORDINÁRIOS" }  ) 
	aAdd( aDadAux, { "SE","31901645","PARTICIPAÇÃO A EMPREGADOS E ADMINISTRADORES" }  ) 
	aAdd( aDadAux, { "SE","31901676","AUXÍLIO MORADIA" }  ) 
	aAdd( aDadAux, { "SE","31901699","OUTRAS DESPESAS VARIÁVEIS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31906702","DEPÓSITOS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","31906799","OUTROS DEPÓSITOS COMPULSÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","31909101","PRECATÓRIOS - ATIVO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909106","SENTENÇAS JUDICIAIS DE PEQUENO VALOR" }  ) 
	aAdd( aDadAux, { "SE","31909108","SENTENÇA JUDICIAL - ATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909109","SENTENÇA JUDICIAL - INATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909110","SENTENÇA JUDICIAL - PENSIONISTA CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909114","SENTENÇA JUDICIAL NÃO TRANSITADA EM JULGADO - ATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909115","SENTENÇA JUDICIAL NÃO TRANSITADA EM JULGADO - INATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909116","SENTENÇA JUDICIAL NÃO TRANSITADA EM JULGADO - PENSIONISTA CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909120","DEPÓSITOS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","31909123","PRECATÓRIOS - INATIVO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909125","HONORÁRIOS SUCUMBENCIAIS DE PRECATÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","31909126","SENTENÇA JUDICIAL DE PEQUENO VALOR - ATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909128","SENTENÇA JUDICIAL DE PEQUENO VALOR - INATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909130","SENTENÇA JUDICIAL DE PEQUENO VALOR - PENSIONISTA CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909136","PRECATÓRIOS - PENSIONISTA - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909143","REQUISITÓRIOS COMPLEMENTARES - ATIVO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909145","REQUISITÓRIOS COMPLEMENTARES - INATIVO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909147","REQUISITÓRIOS COMPLEMENTARES - PENSIONISTAS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909151","PRECATÓRIOS - ATIVO - PESSOAL CIVIL - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","31909152","SENTENÇAS JUDICIAIS DE PEQUENO VALOR - ATIVO CIVIL -ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","31909153","PRECATÓRIOS - INATIVO - PESSOAL CIVIL - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","31909154","PRECATÓRIOS - PENSIONISTA - PESSOAL CIVIL - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","31909155","REQUISITÓRIOS COMPLEMENTARES - ATIVO - PESSOAL CIVIL - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","31909156","REQUISITÓRIOS COMPLEMENTARES - INATIVO - PESSOAL CIVIL - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","31909157","REQUISITÓRIOS COMPLEMENTARES - PENSIONISTAS - PESSOAL CIVIL - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","31909158","SENTENÇA JUDICIAL DE PEQUENO VALOR - INATIVO CIVIL - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","31909159","SENTENÇA JUDICIAL DE PEQUENO VALOR - PENSIONISTA CIVIL - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","31909160","OUTROS PRECATÓRIOS JUDICIAIS - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","31909197","OUTROS PRECATÓRIOS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","31909199","OUTRAS SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","31909201","ATIVO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909202","INATIVO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909203","PENSÕES DO RPPS E DO MILITAR" }  ) 
	aAdd( aDadAux, { "SE","31909204","OUTRAS DESPESAS VARIÁVEIS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909205","OBRIGAÇÕES PATRONAIS - ATIVO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909206","OBRIGAÇÕES PATRONAIS - INATIVO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909207","CONTRIBUIÇÃO A ENTIDADES FECHADAS DE PREVIDÊNCIA" }  ) 
	aAdd( aDadAux, { "SE","31909208","VENCIMENTOS E VANTAGENS FIXAS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909211","VENCIMENTOS E VANTAGENS FIXAS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909212","PENSIONISTA - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909213","OBRIGAÇÕES PATRONAIS" }  ) 
	aAdd( aDadAux, { "SE","31909216","OUTRAS DESPESAS VARIÁVEIS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909226","RESSARCIMENTO DE DESPESA DE PESSOAL REQUISITADO" }  ) 
	aAdd( aDadAux, { "SE","31909231","APOSENTADORIAS, RESERVA REMUNERADA E REFORMAS" }  ) 
	aAdd( aDadAux, { "SE","31909234","CONTRATAÇÃO POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","31909235","OUTROS BENEFÍCIOS PREVIDENCIÁRIOS DO SERVIDOR OU DO MILITAR" }  ) 
	aAdd( aDadAux, { "SE","31909259","PENSÕES ESPECIAIS" }  ) 
	aAdd( aDadAux, { "SE","31909291","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","31909294","INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS" }  ) 
	aAdd( aDadAux, { "SE","31909296","RESSARCIMENTO DE DESPESAS COM PESSOAL REQUISITADO" }  ) 
	aAdd( aDadAux, { "SE","31909298","INDENIZAÇÕES POR DEMISSÃO E COM PROGRAMAS DE INCENTIVOS À DEMISSÃO VOLUNTÁRIA - TRABALHADOR ATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909299","OUTRAS DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","31909401","INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS - ATIVO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909403","INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS - INATIVO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909413","INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS - PENSIONISTA CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909415","INDENIZAÇÕES POR DEMISSÃO" }  ) 
	aAdd( aDadAux, { "SE","31909416","INCENTIVO À DEMISSÃO VOLUNTÁRIA" }  ) 
	aAdd( aDadAux, { "SE","31909498","INDENIZAÇÕES POR DEMISSÃO E COM PROGRAMAS DE INCENTIVOS À DEMISSÃO VOLUNTÁRIA - TRABALHADOR ATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31909499","OUTRAS INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS " }  ) 
	aAdd( aDadAux, { "SE","31909500","INDENIZAÇÕES PELA EXECUÇÃO DE TRABALHOS DE CAMPO" }  ) 
	aAdd( aDadAux, { "SE","31909601","PESSOAL REQUISITADO DE OUTROS ÓRGÃOS DA MESMA ADMINISTRAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","31909602","PESSOAL REQUISITADO DE OUTROS ENTES" }  ) 
	aAdd( aDadAux, { "SE","31909699","OUTROS RESSARCIMENTOS DE DESPESAS DE PESSOAL REQUISITADO" }  ) 
	aAdd( aDadAux, { "SE","31910400","CONTRATAÇÃO POR TEMPO DETERMINADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31910401","PROFESSORES SUBSTITUTOS / VISITANTES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31910415","OBRIGAÇÕES PATRONAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31910499","OUTRAS CONTRATAÇÕES POR TEMPO DETERMINADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31910701","COMPLEMENTAÇÃO DE PREVIDÊNCIA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911303","CONTRIBUIÇÃO PATRONAL PARA O REGIME PRÓPRIO DE PREVIDÊNCIA - RPPS" }  ) 
	aAdd( aDadAux, { "SE","31911308","CONTRIBUIÇÕES PREVIDENCIÁRIAS - RPPS - PESSOAL ATIVO - PLANO PREVIDENCIÁRIO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911310","CONTRIBUIÇÕES PREVIDENCIÁRIAS - RPPS - PESSOAL INATIVO E PENSIONISTA - PLANO PREVIDENCIÁRIO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911311","CONTRIBUIÇÕES PREVIDENCIÁRIAS - RPPS - PESSOAL ATIVO - PLANO FINANCEIRO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911312","CONTRIBUIÇÕES PREVIDENCIÁRIAS - RPPS - PESSOAL INATIVO E PENSIONISTA - PLANO FINANCEIRO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911315","MULTAS" }  ) 
	aAdd( aDadAux, { "SE","31911317","JUROS" }  ) 
	aAdd( aDadAux, { "SE","31911320","ALÍQUOTA SUPLEMENTAR DE CONTRIBUIÇÃO PREVIDENCIÁRIA -  PESSOAL ATIVO - PLANO PREVIDENCIÁRIO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911321","ALÍQUOTA SUPLEMENTAR DE CONTRIBUIÇÃO PREVIDENCIÁRIA -  PESSOAL INATIVO E PENSIONISTA - PLANO PREVIDENCIÁRIO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911322","ALÍQUOTA SUPLEMENTAR DE CONTRIBUIÇÃO PREVIDENCIÁRIA -  PESSOAL ATIVO - PLANO FINANCEIRO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911323","ALÍQUOTA SUPLEMENTAR DE CONTRIBUIÇÃO PREVIDENCIÁRIA -  PESSOAL INATIVO E PENSIONISTA - PLANO FINANCEIRO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911340","ENCARGOS DE PESSOAL REQUISITADO DE OUTROS ENTES" }  ) 
	aAdd( aDadAux, { "SE","31911341","CONTRIBUIÇÃO PATRONAL DO EXERCÍCIO PARA O RPPS - PESSOAL CIVIL ATIVO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911342","CONTRIBUIÇÃO PATRONAL DO EXERCÍCIO PARA O RPPS - PESSOAL CIVIL INATIVO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911343","CONTRIBUIÇÃO PATRONAL DO EXERCÍCIO PARA O RPPS - PENSIONISTA CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911351","CONTRIBUIÇÃO PATRONAL DE EXERCÍCIOS ANTERIORES PARA O RPPS - PESSOAL CIVIL ATIVO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911352","CONTRIBUIÇÃO PATRONAL DE EXERCÍCIOS ANTERIORES PARA O RPPS - PESSOAL CIVIL INATIVO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911353","CONTRIBUIÇÃO PATRONAL DE EXERCÍCIOS ANTERIORES PARA O RPPS - PENSIONISTA CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911399","OUTRAS OBRIGAÇÕES PATRONAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31911600","OUTRAS DESPESAS VARIÁVEIS - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31916700","DEPÓSITOS COMPULSÓRIOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919101","PRECATÓRIOS - ATIVO - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919106","SENTENÇAS JUDICIAIS DE PEQUENO VALOR - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919123","PRECATÓRIOS - INATIVO - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919136","PRECATÓRIOS - PENSIONISTA - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919143","REQUISITÓRIOS COMPLEMENTARES- ATIVO - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919145","REQUISITÓRIOS COMPLEMENTARES- INATIVO - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919147","REQUISITÓRIOS COMPLEMENTARES- PENSIONISTAS - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919151","PRECATÓRIOS - ATIVO - PESSOAL CIVIL - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919152","SENTENÇAS JUDICIAIS DE PEQUENO VALOR - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919153","PRECATÓRIOS - INATIVO - PESSOAL CIVIL - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919154","PRECATÓRIOS - PENSIONISTA - PESSOAL CIVIL - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919155","REQUISITÓRIOS COMPLEMENTARES- ATIVO - PESSOAL CIVIL - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919156","REQUISITÓRIOS COMPLEMENTARES- INATIVO - PESSOAL CIVIL - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919157","REQUISITÓRIOS COMPLEMENTARES- PENSIONISTAS - PESSOAL CIVIL - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919161","OBRIGAÇÕES PATRONAIS DE PRECATÓRIOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919162","OBRIGAÇÕES PATRONAIS DE SENTENÇAS JUDICIAIS DE PEQUENO VALOR - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919163","OBRIGAÇÕES PATRONAIS DE SENTENÇAS JUDICIAIS - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919199","OUTRAS SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919201","ATIVO - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919202","INATIVO - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919204","OUTRAS DESPESAS VARIÁVEIS - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919205","CONTRIBUIÇÕES PREVIDENCIÁRIAS - RPPS - PESSOAL ATIVO DO PLANO PREVIDENCIÁRIO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919206","CONTRIBUIÇÕES PREVIDENCIÁRIAS - RPPS - PESSOAL INATIVO E PENSIONISTA DO PLANO PREVIDENCIÁRIO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919207","CONTRIBUIÇÕES PREVIDENCIÁRIAS - RPPS - PESSOAL ATIVO DO PLANO FINANCEIRO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919208","VENCIMENTOS E VANTAGENS FIXAS - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919209","ALÍQUOTA SUPLEMENTAR DE CONTRIBUIÇÃO PREVIDENCIÁRIA - PESSOAL ATIVO DO PLANO PREVIDENCIÁRIO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919210","ALÍQUOTA SUPLEMENTAR DE CONTRIBUIÇÃO PREVIDENCIÁRIA - PESSOAL INATIVO E PENSIONISTA DO PLANO PREVIDENCIÁRIO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919211","ALÍQUOTA SUPLEMENTAR DE CONTRIBUIÇÃO PREVIDENCIÁRIA - PESSOAL ATIVO DO PLANO FINANCEIRO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919212","PENSIONISTA - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919213","DEMAIS OBRIGAÇÕES PATRONAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919214","CONTRATAÇÃO POR TEMPO DETERMINADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919218","CONTRIBUIÇÕES PREVIDENCIÁRIAS - RPPS - PESSOAL INATIVO E PENSIONISTA DO PLANO FINANCEIRO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919222","ALÍQUOTA SUPLEMENTAR DE CONTRIBUIÇÃO PREVIDENCIÁRIA - PESSOAL INATIVO E PENSIONISTA DO PLANO FINANCEIRO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919226","RESSARCIMENTO DE DESPESA DE PESSOAL REQUISITADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919251","INDENIZAÇÕES TRABALHISTAS - OBRIGAÇÕES PATRONAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919291","SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919296","RESSARCIMENTO DE DESPESAS COM PESSOAL REQUISITADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919298","INDENIZAÇÕES POR DEMISSÃO E COM PROGRAMAS DE INCENTIVOS À DEMISSÃO VOLUNTÁRIA - TRABALHADOR  ATIVO CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919299","OUTRAS DESPESAS DE EXERCÍCIOS ANTERIORES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919401","INDENIZAÇÕES TRABALHISTAS - ATIVO - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919403","INDENIZAÇÕES TRABALHISTAS - INATIVO - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919413","INDENIZAÇÕES TRABALHISTAS - PENSIONISTA - PESSOAL CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919415","INDENIZAÇÕES POR DEMISSÃO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919416","INCENTIVO À DEMISSÃO VOLUNTÁRIA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919451","INDENIZAÇÕES TRABALHISTAS - OBRIGAÇÕES PATRONAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919498","INDENIZAÇÕES POR DEMISSÃO E COM PROGRAMAS DE INCENTIVOS À DEMISSÃO VOLUNTÁRIA - TRABALHADOR ATIVO CIVIL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919499","DIVERSAS INDENIZAÇÕES TRABALHISTAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919500","INDENIZAÇÕES PELA EXECUÇÃO DE TRABALHOS DE CAMPO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919601","PESSOAL REQUISITADO DE OUTROS ÓRGÃOS DA MESMA ADMINISTRAÇÃO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31919699","OUTROS RESSARCIMENTOS DE DESPESAS DE PESSOAL REQUISITADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","31950400","CONTRATAÇÃO POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","31950700","CONTRIBUIÇÃO A ENTIDADES FECHADAS DE PREVIDÊNCIA" }  ) 
	aAdd( aDadAux, { "SE","31951100","VENCIMENTOS E VANTAGENS FIXAS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31951300","OBRIGAÇÕES PATRONAIS" }  ) 
	aAdd( aDadAux, { "SE","31951600","OUTRAS DESPESAS VARIÁVEIS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31956700","DEPÓSITOS COMPULSÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","31959100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","31959200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","31959400","INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS" }  ) 
	aAdd( aDadAux, { "SE","31959498","INDENIZAÇÕES POR DEMISSÃO E COM PROGRAMAS DE INCENTIVOS À DEMISSÃO VOLUNTÁRIA - TRABALHADOR ATIVO CIVIL " }  ) 
	aAdd( aDadAux, { "SE","31959499","OUTRAS INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS" }  ) 
	aAdd( aDadAux, { "SE","31959600","RESSARCIMENTO DE DESPESAS DE PESSOAL REQUISITADO" }  ) 
	aAdd( aDadAux, { "SE","31960400","CONTRATAÇÃO POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","31960700","CONTRIBUIÇÃO A ENTIDADES FECHADAS DE PREVIDÊNCIA" }  ) 
	aAdd( aDadAux, { "SE","31961100","VENCIMENTOS E VANTAGENS FIXAS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31961300","OBRIGAÇÕES PATRONAIS" }  ) 
	aAdd( aDadAux, { "SE","31961600","OUTRAS DESPESAS VARIÁVEIS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","31966700","DEPÓSITOS COMPULSÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","31969100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","31969200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","31969400","INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS" }  ) 
	aAdd( aDadAux, { "SE","31969498","INDENIZAÇÕES POR DEMISSÃO E COM PROGRAMAS DE INCENTIVOS À DEMISSÃO VOLUNTÁRIA - TRABALHADOR ATIVO CIVIL " }  ) 
	aAdd( aDadAux, { "SE","31969499","OUTRAS INDENIZAÇÕES E RESTITUIÇÕES TRABALHISTAS" }  ) 
	aAdd( aDadAux, { "SE","31969600","RESSARCIMENTO DE DESPESAS DE PESSOAL REQUISITADO" }  ) 
	aAdd( aDadAux, { "SE","32717000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","32737000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO - §§ 1º E 2º DO ART 24 DA LEI COMPLEMENTAR NO 141, DE 2012" }  ) 
	aAdd( aDadAux, { "SE","32747000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO - ART 25 DA LEI COMPLEMENTAR NO 141, DE 2012”" }  ) 
	aAdd( aDadAux, { "SE","32902101","JUROS DA DÍVIDA CONTRATUAL" }  ) 
	aAdd( aDadAux, { "SE","32902102","JUROS DA DÍVIDA CONTRATADA COM GOVERNOS" }  ) 
	aAdd( aDadAux, { "SE","32902103","JUROS DA DÍVIDA CONTRATADA NO EXTERIOR" }  ) 
	aAdd( aDadAux, { "SE","32902112","VARIAÇÃO CAMBIAL DOS JUROS DA DÍVIDA CONTRATUAL" }  ) 
	aAdd( aDadAux, { "SE","32902199","OUTROS JUROS DA DÍVIDA CONTRATADA" }  ) 
	aAdd( aDadAux, { "SE","32902201","ENCARGOS DA DÍVIDA CONTRATUAL" }  ) 
	aAdd( aDadAux, { "SE","32902202","ENCARGOS DA DÍVIDA CONTRATADA COM GOVERNOS" }  ) 
	aAdd( aDadAux, { "SE","32902212","VARIAÇÃO CAMBIAL DOS ENCARGOS DA DÍVIDA CONTRATUAL" }  ) 
	aAdd( aDadAux, { "SE","32902299","DIVERSOS ENCARGOS DA DÍVIDA CONTRATADA" }  ) 
	aAdd( aDadAux, { "SE","32902301","JUROS DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32902302","DESÁGIOS" }  ) 
	aAdd( aDadAux, { "SE","32902303","DESCONTOS DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32902304","DESÁGIOS DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32902399","OUTROS JUROS, DESÁGIOS E DESCONTOS DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32902312","VARIAÇÃO CAMBIAL DOS JUROS DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32902400","OUTROS ENCARGOS SOBRE A DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32902401","ENCARGOS DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32902402","VARIAÇÃO CAMBIAL DOS ENCARGOS DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32902499","DIVERSOS ENCARGOS DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32902500","ENCARGOS SOBRE OPERAÇÕES DE CRÉDITO POR ANTECIPAÇÃO DA RECEITA" }  ) 
	aAdd( aDadAux, { "SE","32902501","ENCARGOS SOBRE ADIANTAMENTOS BANCÁRIOS" }  ) 
	aAdd( aDadAux, { "SE","32902599","DIVERSOS ENCARGOS" }  ) 
	aAdd( aDadAux, { "SE","32909100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","32909160","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","32909161","SENTENÇAS JUDICIAIS - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","32909199","OUTRAS SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","32909200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","32909201","JUROS DA DÍVIDA INTERNA" }  ) 
	aAdd( aDadAux, { "SE","32909202","ENCARGOS DA DÍVIDA INTERNA" }  ) 
	aAdd( aDadAux, { "SE","32909204","ENCARGOS DA DÍVIDA EXTERNA" }  ) 
	aAdd( aDadAux, { "SE","32909299","DIVERSOS JUROS E ENCARGOS DA DÍVIDA PÚBLICA" }  ) 
	aAdd( aDadAux, { "SE","32909300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","32912100","JUROS SOBRE A DÍVIDA POR CONTRATO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","32912102","JUROS DA DÍVIDA CONTRATADA COM GOVERNOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","32912199","OUTROS JUROS DA DÍVIDA CONTRATADA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","32912200","OUTROS ENCARGOS SOBRE A DÍVIDA POR CONTRATO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","32912202","ENCARGOS DA DÍVIDA CONTRATADA COM GOVERNOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","32912299","DIVERSOS ENCARGOS DA DÍVIDA CONTRATADA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","32952100","JUROS SOBRE A DÍVIDA POR CONTRATO" }  ) 
	aAdd( aDadAux, { "SE","32952200","OUTROS ENCARGOS SOBRE A DÍVIDA POR CONTRATO" }  ) 
	aAdd( aDadAux, { "SE","32952300","JUROS, DESÁGIOS E DESCONTOS DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32952400","OUTROS ENCARGOS SOBRE A DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32952500","ENCARGOS SOBRE OPERAÇÕES DE CRÉDITO POR ANTECIPAÇÃO DA RECEITA" }  ) 
	aAdd( aDadAux, { "SE","32959100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","32959200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","32959300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","32962100","JUROS SOBRE A DÍVIDA POR CONTRATO" }  ) 
	aAdd( aDadAux, { "SE","32962200","OUTROS ENCARGOS SOBRE A DÍVIDA POR CONTRATO" }  ) 
	aAdd( aDadAux, { "SE","32962300","JUROS, DESÁGIOS E DESCONTOS DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32962400","OUTROS ENCARGOS SOBRE A DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","32962500","ENCARGOS SOBRE OPERAÇÕES DE CRÉDITO POR ANTECIPAÇÃO DA RECEITA" }  ) 
	aAdd( aDadAux, { "SE","32969100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","32969200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","32969300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33200101","COMPENSAÇÃO PREVIDENCIÁRIA APOSENTADORIAS ENTRE RPPS E RGPS" }  ) 
	aAdd( aDadAux, { "SE","33200301","COMPENSAÇÃO PREVIDENCIÁRIA PENSÕES ENTRE RPPS E RGPS" }  ) 
	aAdd( aDadAux, { "SE","33204100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33209200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33221400","DIÁRIAS CIVIL" }  ) 
	aAdd( aDadAux, { "SE","33223000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33223500","SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","33223600","SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33223900","SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33300101","COMPENSAÇÃO PREVIDENCIÁRIA DE APOSENTADORIAS ENTRE RPPS LOCAL E RPPS DOS ESTADOS E DO DISTRITO FEDERAL" }  ) 
	aAdd( aDadAux, { "SE","33300301","COMPENSAÇÃO PREVIDENCIÁRIA DE PENSÕES ENTRE RPPS LOCAL E O RPPS DOS ESTADOS E DO DISTRITO FEDERAL" }  ) 
	aAdd( aDadAux, { "SE","33303009","AQUISIÇÃO DE MEDICAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","33303099","OUTROS MATERIAIS DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33304100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33304300","SUBVENÇÕES SOCIAIS" }  ) 
	aAdd( aDadAux, { "SE","33309200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33309300","INDENIZAÇÕES E RESTITUIÇÕES " }  ) 
	aAdd( aDadAux, { "SE","33314100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33319200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33321400","DIÁRIAS - CIVIL" }  ) 
	aAdd( aDadAux, { "SE","33321800","AUXÍLIO FINANCEIRO A ESTUDANTES" }  ) 
	aAdd( aDadAux, { "SE","33322000","AUXÍLIO FINANCEIRO A PESQUISADORES" }  ) 
	aAdd( aDadAux, { "SE","33323000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33323200","MATERIAL, BEM OU SERVIÇO PARA DISTRIBUIÇÃO GRATUITA" }  ) 
	aAdd( aDadAux, { "SE","33323300","PASSAGENS E DESPESAS COM LOCOMOÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33323500","SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","33323600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33323900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33324700","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","33329200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33329300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33354100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33359200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33364100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33369200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33400101","COMPENSAÇÃO PREVIDENCIÁRIA DE APOSENTADORIAS ENTRE RPPS LOCAL E RPPS DE OUTROS MUNICÍPIOS" }  ) 
	aAdd( aDadAux, { "SE","33400301","COMPENSAÇÃO PREVIDENCIÁRIA DE PENSÕES ENTRE RPPS LOCAL E O RPPS DE OUTROS MUNICÍPIOS" }  ) 
	aAdd( aDadAux, { "SE","33403009","AQUISIÇÃO DE MEDICAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","33403099","OUTROS MATERIAIS DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33404100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33404300","SUBVENÇÕES SOCIAIS" }  ) 
	aAdd( aDadAux, { "SE","33409100","SENTENÇAS JUDICIAIS " }  ) 
	aAdd( aDadAux, { "SE","33409200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33409300","INDENIZAÇÕES E RESTITUIÇÕES " }  ) 
	aAdd( aDadAux, { "SE","33414100","CONTRIBUIÇÕES " }  ) 
	aAdd( aDadAux, { "SE","33419200","DESPESAS DE EXERCÍCIOS ANTERIORES " }  ) 
	aAdd( aDadAux, { "SE","33421400","DIÁRIAS - CIVIL" }  ) 
	aAdd( aDadAux, { "SE","33421800","AUXÍLIO FINANCEIRO A ESTUDANTES" }  ) 
	aAdd( aDadAux, { "SE","33423000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33423300","PASSAGENS E DESPESAS COM LOCOMOÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33423500","SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","33423600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33423900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33424700","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","33429200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33429300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33454100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33459100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","33459200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33464100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33469100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","33469200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33501400","DIÁRIAS" }  ) 
	aAdd( aDadAux, { "SE","33501800","AUXÍLIO FINANCEIRO A ESTUDANTES" }  ) 
	aAdd( aDadAux, { "SE","33502000","AUXÍLIO FINANCEIRO A PESQUISADORES" }  ) 
	aAdd( aDadAux, { "SE","33503000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33503100","PREMIAÇÕES CULTURAIS, ARTÍSTICAS, CIENTÍFICAS, DESPORTIVAS E OUTRAS" }  ) 
	aAdd( aDadAux, { "SE","33503300","PASSAGENS E DESPESAS COM LOCOMOÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33503500","SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","33503600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33503900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33503901","TERMO DE COLABORAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33503902","TERMO DE FOMENTO" }  ) 
	aAdd( aDadAux, { "SE","33503903","ACORDO DE COOPERAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33503904","CONTRATO DE GESTÃO" }  ) 
	aAdd( aDadAux, { "SE","33503951","SERVIÇOS MÉDICO-HOSPITALARES PRESTADOS EM UNIDADES HOSPITALARES" }  ) 
	aAdd( aDadAux, { "SE","33503952","SERVIÇOS MÉDICO-HOSPITALARES PRESTADOS EM UNIDADES AMBULATORIAIS" }  ) 
	aAdd( aDadAux, { "SE","33503953","SERVIÇOS MÉDICO-HOSPITALARES PRESTADOS NA ATENÇÃO BÁSICA" }  ) 
	aAdd( aDadAux, { "SE","33503954","SERVIÇOS ODONTOLÓGICOS" }  ) 
	aAdd( aDadAux, { "SE","33503955","SERVIÇOS LABORATORIAIS" }  ) 
	aAdd( aDadAux, { "SE","33503956","OUTROS SERVIÇOS DE ASSISTÊNCIA À SAÚDE" }  ) 
	aAdd( aDadAux, { "SE","33503999","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33504100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33504300","SUBVENÇÕES SOCIAIS" }  ) 
	aAdd( aDadAux, { "SE","33504700","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","33509200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33604100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33604500","SUBVENÇÕES ECONÔMICAS" }  ) 
	aAdd( aDadAux, { "SE","33609200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33609300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33674500","SUBVENÇÕES ECONÔMICAS" }  ) 
	aAdd( aDadAux, { "SE","33678200","APORTE DE RECURSOS PELO PARCEIRO PÚBLICO EM FAVOR DO PARCEIRO PRIVADO DECORRENTE DE CONTRATO DE PARCERIA PÚBLICO-PRIVADA - PPP" }  ) 
	aAdd( aDadAux, { "SE","33678300","CONTRATO DE PPP, EXCETO SUBVENÇÕES ECONÔMICAS, APORTE E FUNDO GARANTIDOR" }  ) 
	aAdd( aDadAux, { "SE","33704100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33710400","CONTRATAÇÃO POR TEMPO DETERMINADO - PESSOAL CIVIL - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33710500","OUTROS BENEFÍCIOS PREVIDENCIÁRIOS - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33711300","OBRIGAÇÕES PATRONAIS - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33711400","DIÁRIAS - PESSOAL CIVIL - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33713000","MATERIAL DE CONSUMO - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33713300","PASSAGENS E DESPESAS COM LOCOMOÇÃO - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33713500","SERVIÇOS DE CONSULTORIA - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33713600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33713700","LOCAÇÃO DE MÃO DE OBRA - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33713800","ARRENDAMENTO MERCANTIL - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33713900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33714600","AUXÍLIO ALIMENTAÇÃO - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33714700","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33714900","AUXÍLIO TRANSPORTE - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33717000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","33719100","SENTENÇAS JUDICIAIS - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33719200","DESPESAS DE EXERCÍCIOS ANTERIORES - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33719300","INDENIZAÇÕES E RESTITUIÇÕES - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","33721400","DIÁRIAS - CIVIL" }  ) 
	aAdd( aDadAux, { "SE","33721800","AUXÍLIO FINANCEIRO A ESTUDANTES" }  ) 
	aAdd( aDadAux, { "SE","33723000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33723300","PASSAGENS E DESPESAS COM LOCOMOÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33723500","SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","33723600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33723900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33724700","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","33729200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33729300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33737000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","33747000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","33754100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33764100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33800400","CONTRATAÇÃO POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","33801400","DIÁRIAS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","33803000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33803300","PASSAGENS E DESPESAS COM LOCOMOÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33803400","OUTRAS DESPESAS DE PESSOAL DECORRENTES DE CONTRATOS DE TERCEIRIZAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33803500","SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","33803600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33803700","LOCAÇÃO DE MÃO DE OBRA" }  ) 
	aAdd( aDadAux, { "SE","33803900","OUTROS SERVIÇOS DE TERCEIROS -PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33804100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33809200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33900400","CONTRATAÇÃO POR TEMPO DETERMINADO - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","33900415","OBRIGAÇÕES PATRONAIS" }  ) 
	aAdd( aDadAux, { "SE","33900499","OUTRAS CONTRATAÇÕES POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","33900605","AUXÍLIO COM DESLOCAMENTO PARA EXAME FORA DO DOMICÍLIO" }  ) 
	aAdd( aDadAux, { "SE","33900699","OUTROS BENEFÍCIOS AO DEFICIENTE E AO IDOSO" }  ) 
	aAdd( aDadAux, { "SE","33900801","AUXÍLIO FUNERAL" }  ) 
	aAdd( aDadAux, { "SE","33900803","AUXILIO FUNERAL INATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","33900805","AUXÍLIO NATALIDADE" }  ) 
	aAdd( aDadAux, { "SE","33900807","AUXILIO NATALIDADE INATIVO CIVIL" }  ) 
	aAdd( aDadAux, { "SE","33900809","AUXÍLIO CRECHE" }  ) 
	aAdd( aDadAux, { "SE","33900811","AUXÍLIO SAÚDE" }  ) 
	aAdd( aDadAux, { "SE","33900813","AUXÍLIO FAMILIAR NO EXTERIOR" }  ) 
	aAdd( aDadAux, { "SE","33900814","AUXÍLIO DEFICIENTE" }  ) 
	aAdd( aDadAux, { "SE","33900815","AUXÍLIO ESCOLA" }  ) 
	aAdd( aDadAux, { "SE","33900818","AUXILIO NATALIDADE PENSIONISTA CIVIL" }  ) 
	aAdd( aDadAux, { "SE","33900846","AUXÍLIO ODONTOLÓGICO " }  ) 
	aAdd( aDadAux, { "SE","33900847","AUXÍLIO OFTALMOLÓGICO" }  ) 
	aAdd( aDadAux, { "SE","33900848","AUXÍLIO MEDICAMENTO" }  ) 
	aAdd( aDadAux, { "SE","33900855","AUXÍLIO CRECHE" }  ) 
	aAdd( aDadAux, { "SE","33900899","OUTROS BENEFÍCIOS ASSISTENCIAIS" }  ) 
	aAdd( aDadAux, { "SE","33901000","SEGURO DESEMPREGO E ABONO SALARIAL" }  ) 
	aAdd( aDadAux, { "SE","33901414","DIÁRIAS NO PAIS" }  ) 
	aAdd( aDadAux, { "SE","33901416","DIÁRIAS NO EXTERIOR" }  ) 
	aAdd( aDadAux, { "SE","33901800","AUXÍLIO FINANCEIRO A ESTUDANTE" }  ) 
	aAdd( aDadAux, { "SE","33901900","AUXÍLIO FARDAMENTO" }  ) 
	aAdd( aDadAux, { "SE","33902000","AUXÍLIO FINANCEIRO A PESQUISADORES" }  ) 
	aAdd( aDadAux, { "SE","33902700","ENCARGOS PELA HONRA DE AVAIS, GARANTIAS, SEGUROS E SIMILARES" }  ) 
	aAdd( aDadAux, { "SE","33902800","REMUNERAÇÃO DE COTAS DE FUNDOS AUTÁRQUICOS" }  ) 
	aAdd( aDadAux, { "SE","33902900","DISTRIBUIÇÃO DE RESULTADO DE EMPRESAS ESTATAIS DEPENDENTES" }  ) 
	aAdd( aDadAux, { "SE","33903001","COMBUSTÍVEIS E LUBRIFICANTES AUTOMOTIVOS" }  ) 
	aAdd( aDadAux, { "SE","33903002","COMBUSTÍVEIS E LUBRIFICANTES DE AVIAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33903003","COMBUSTÍVEIS E LUBRIFICANTES PARA OUTRAS FINALIDADES" }  ) 
	aAdd( aDadAux, { "SE","33903004","GÁS ENGARRAFADO" }  ) 
	aAdd( aDadAux, { "SE","33903005","EXPLOSIVOS E MUNIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33903006","ALIMENTOS PARA ANIMAIS" }  ) 
	aAdd( aDadAux, { "SE","33903007","GÊNEROS DE ALIMENTAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33903008","ANIMAIS PARA PESQUISAS E ABATE" }  ) 
	aAdd( aDadAux, { "SE","33903009","MATERIAL FARMACOLÓGICO" }  ) 
	aAdd( aDadAux, { "SE","33903010","MATERIAL ODONTOLÓGICO" }  ) 
	aAdd( aDadAux, { "SE","33903011","MATERIAL QUÍMICO" }  ) 
	aAdd( aDadAux, { "SE","33903012","MATERIAL DE COUDELARIA OU DE USO ZOOTÉCNICO" }  ) 
	aAdd( aDadAux, { "SE","33903013","MATERIAL DE CAÇA E PESCA" }  ) 
	aAdd( aDadAux, { "SE","33903014","MATERIAL EDUCATIVO E ESPORTIVO" }  ) 
	aAdd( aDadAux, { "SE","33903015","MATERIAL PARA FESTIVIDADES E HOMENAGENS" }  ) 
	aAdd( aDadAux, { "SE","33903016","MATERIAL DE EXPEDIENTE" }  ) 
	aAdd( aDadAux, { "SE","33903017","MATERIAL DE PROCESSAMENTO DE DADOS" }  ) 
	aAdd( aDadAux, { "SE","33903018","MATERIAIS E MEDICAMENTOS PARA USO VETERINÁRIO" }  ) 
	aAdd( aDadAux, { "SE","33903019","MATERIAL DE ACONDICIONAMENTO E EMBALAGEM" }  ) 
	aAdd( aDadAux, { "SE","33903020","MATERIAL DE CAMA, MESA E BANHO" }  ) 
	aAdd( aDadAux, { "SE","33903021","MATERIAL DE COPA E COZINHA" }  ) 
	aAdd( aDadAux, { "SE","33903022","MATERIAL DE LIMPEZA E PRODUTOS DE HIGIENIZAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33903023","UNIFORMES, TECIDOS E AVIAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","33903024","MATERIAL PARA MANUTENÇÃO DE BENS IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","33903025","MATERIAL PARA MANUTENÇÃO DE BENS MÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","33903026","MATERIAL ELÉTRICO E ELETRÔNICO" }  ) 
	aAdd( aDadAux, { "SE","33903028","MATERIAL DE PROTEÇÃO E SEGURANÇA" }  ) 
	aAdd( aDadAux, { "SE","33903029","MATERIAL PARA ÁUDIO, VÍDEO E FOTO" }  ) 
	aAdd( aDadAux, { "SE","33903030","MATERIAL PARA COMUNICAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33903031","SEMENTES, MUDAS DE PLANTAS E INSUMOS" }  ) 
	aAdd( aDadAux, { "SE","33903032","SUPRIMENTO DE AVIAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33903033","MATERIAL PARA PRODUÇÃO INDUSTRIAL" }  ) 
	aAdd( aDadAux, { "SE","33903034","SOBRESSALENTES, MÁQUINAS E MOTORES DE NAVIOS E EMBARCAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33903035","MATERIAL LABORATORIAL" }  ) 
	aAdd( aDadAux, { "SE","33903036","MATERIAL HOSPITALAR" }  ) 
	aAdd( aDadAux, { "SE","33903037","MEDICAMENTOS FORNECIDOS POR DECISÃO JUDICIAL" }  ) 
	aAdd( aDadAux, { "SE","33903039","MATERIAL PARA MANUTENÇÃO DE VEÍCULOS" }  ) 
	aAdd( aDadAux, { "SE","33903041","MATERIAL PARA UTILIZAÇÃO EM GRÁFICA" }  ) 
	aAdd( aDadAux, { "SE","33903042","FERRAMENTAS" }  ) 
	aAdd( aDadAux, { "SE","33903043","MATERIAL PARA REABILITAÇÃO PROFISSIONAL" }  ) 
	aAdd( aDadAux, { "SE","33903044","MATERIAL DE SINALIZAÇÃO VISUAL E AFINS" }  ) 
	aAdd( aDadAux, { "SE","33903045","MATERIAL TÉCNICO PARA SELEÇÃO E TREINAMENTO" }  ) 
	aAdd( aDadAux, { "SE","33903046","MATERIAL BIBLIOGRÁFICO NÃO IMOBILIZÁVEL" }  ) 
	aAdd( aDadAux, { "SE","33903047","AQUISIÇÃO DE SOFTWARES DE BASE" }  ) 
	aAdd( aDadAux, { "SE","33903048","BENS MÓVEIS NÃO ATIVÁVEIS - EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","33903050","BANDEIRAS, FLÂMULAS E INSÍGNIAS" }  ) 
	aAdd( aDadAux, { "SE","33903060","MATERIAL DIDÁTICO" }  ) 
	aAdd( aDadAux, { "SE","33903098","OUTROS MATERIAIS DE CONSUMO DECORRENTE DE DECISÃO JUDICIAL" }  ) 
	aAdd( aDadAux, { "SE","33903099","OUTROS MATERIAIS DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33903100","PREMIAÇÕES CULTURAIS, ARTÍSTICAS, CIENTÍFICAS, DESPORTIVAS E OUTRAS" }  ) 
	aAdd( aDadAux, { "SE","33903200","MATERIAL, BEM OU SERVIÇO PARA DISTRIBUIÇÃO GRATUITA" }  ) 
	aAdd( aDadAux, { "SE","33903202","MEDICAMENTOS PARA USO DOMICILIAR" }  ) 
	aAdd( aDadAux, { "SE","33903203","MATERIAL DESTINADO À ASSISTÊNCIA SOCIAL" }  ) 
	aAdd( aDadAux, { "SE","33903204","MATERIAL EDUCACIONAL E CULTURAL" }  ) 
	aAdd( aDadAux, { "SE","33903299","OUTROS MATERIAIS DE DISTRIBUIÇÃO GRATUITA" }  ) 
	aAdd( aDadAux, { "SE","33903301","PASSAGENS PARA O PAÍS" }  ) 
	aAdd( aDadAux, { "SE","33903302","PASSAGENS PARA O EXTERIOR" }  ) 
	aAdd( aDadAux, { "SE","33903308","PEDÁGIOS" }  ) 
	aAdd( aDadAux, { "SE","33903399","OUTRAS DESPESAS COM LOCOMOÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33903400","OUTRAS DESPESAS DE PESSOAL DECORRENTES DE CONTRATOS DE TERCEIRIZAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33903501","ASSESSORIA E CONSULTORIA TÉCNICA OU JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33903502","AUDITORIA EXTERNA" }  ) 
	aAdd( aDadAux, { "SE","33903599","OUTROS SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","33903601","CONDOMÍNIOS" }  ) 
	aAdd( aDadAux, { "SE","33903602","DIÁRIAS A COLABORADORES EVENTUAIS NO PAÍS" }  ) 
	aAdd( aDadAux, { "SE","33903603","DIÁRIAS A COLABORADORES EVENTUAIS NO EXTERIOR" }  ) 
	aAdd( aDadAux, { "SE","33903604","COMISSÕES E CORRETAGENS" }  ) 
	aAdd( aDadAux, { "SE","33903605","DIREITOS AUTORAIS" }  ) 
	aAdd( aDadAux, { "SE","33903606","SERVIÇOS TÉCNICOS PROFISSIONAIS" }  ) 
	aAdd( aDadAux, { "SE","33903607","ESTAGIÁRIOS" }  ) 
	aAdd( aDadAux, { "SE","33903608","BOLSA DE INICIAÇÃO AO TRABALHO" }  ) 
	aAdd( aDadAux, { "SE","33903611","PRÓ-LABORE A CONSULTORES EVENTUAIS" }  ) 
	aAdd( aDadAux, { "SE","33903613","CONFERÊNCIAS, EXPOSIÇÕES E ESPETÁCULOS" }  ) 
	aAdd( aDadAux, { "SE","33903614","ARMAZENAGEM" }  ) 
	aAdd( aDadAux, { "SE","33903615","LOCAÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","33903616","LOCAÇÃO DE BENS MÓVEIS E INTANGÍVEIS" }  ) 
	aAdd( aDadAux, { "SE","33903618","MANUTENÇÃO E CONSERVAÇÃO DE EQUIPAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","33903620","MANUTENÇÃO E CONSERVAÇÃO DE VEÍCULOS" }  ) 
	aAdd( aDadAux, { "SE","33903621","MANUTENÇÃO E CONSERVAÇÃO DE BENS MÓVEIS DE OUTRAS NATUREZAS" }  ) 
	aAdd( aDadAux, { "SE","33903622","MANUTENÇÃO E CONSERVAÇÃO DE BENS IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","33903623","FORNECIMENTO DE ALIMENTAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33903625","SERVIÇOS DE LIMPEZA E CONSERVAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33903626","SERVIÇOS DOMÉSTICOS" }  ) 
	aAdd( aDadAux, { "SE","33903627","SERVIÇOS DE COMUNICAÇÃO EM GERAL" }  ) 
	aAdd( aDadAux, { "SE","33903628","SERVIÇO DE SELEÇÃO E TREINAMENTO" }  ) 
	aAdd( aDadAux, { "SE","33903630","SERVIÇOS MÉDICOS E ODONTOLÓGICOS" }  ) 
	aAdd( aDadAux, { "SE","33903631","SERVIÇOS DE REABILITAÇÃO PROFISSIONAL" }  ) 
	aAdd( aDadAux, { "SE","33903632","SERVIÇOS DE ASSISTÊNCIA SOCIAL" }  ) 
	aAdd( aDadAux, { "SE","33903634","SERVIÇO DE PERÍCIAS MÉDICAS POR BENEFÍCIOS" }  ) 
	aAdd( aDadAux, { "SE","33903635","SERVIÇO DE APOIO ADMINISTRATIVO, TÉCNICO E OPERACIONAL" }  ) 
	aAdd( aDadAux, { "SE","33903636","SERVIÇO DE CONSERVAÇÃO E BENEFICIAMENTO DE MERCADORIAS" }  ) 
	aAdd( aDadAux, { "SE","33903637","CONFECÇÃO DE MATERIAL DE ACONDICIONAMENTO E EMBALAGEM" }  ) 
	aAdd( aDadAux, { "SE","33903638","CONFECÇÃO DE UNIFORMES, BANDEIRAS E FLÂMULAS" }  ) 
	aAdd( aDadAux, { "SE","33903639","FRETES E TRANSPORTES DE ENCOMENDAS" }  ) 
	aAdd( aDadAux, { "SE","33903640","ENCARGOS FINANCEIROS DEDUTÍVEIS - EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","33903641","MULTAS DEDUTÍVEIS - EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","33903642","JUROS" }  ) 
	aAdd( aDadAux, { "SE","33903643","ENCARGOS FINANCEIROS INDEDUTÍVEIS - EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","33903644","MULTAS INDEDUTÍVEIS - EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","33903645","JETONS E GRATIFICAÇÕES A CONSELHEIROS" }  ) 
	aAdd( aDadAux, { "SE","33903646","DIÁRIAS A CONSELHEIROS" }  ) 
	aAdd( aDadAux, { "SE","33903659","SERVIÇOS DE ÁUDIO, VÍDEO E FOTO" }  ) 
	aAdd( aDadAux, { "SE","33903699","OUTROS SERVIÇOS DE PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33903701","APOIO ADMINISTRATIVO, TÉCNICO E OPERACIONAL" }  ) 
	aAdd( aDadAux, { "SE","33903702","LIMPEZA E CONSERVAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33903703","VIGILÂNCIA OSTENSIVA" }  ) 
	aAdd( aDadAux, { "SE","33903704","MANUTENÇÃO E CONSERVAÇÃO DE BENS IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","33903705","SERVIÇOS DE COPA E COZINHA" }  ) 
	aAdd( aDadAux, { "SE","33903706","MANUTENÇÃO E CONSERVAÇÃO DE BENS MÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","33903799","OUTRAS LOCAÇÕES DE MÃO DE OBRA" }  ) 
	aAdd( aDadAux, { "SE","33903801","MÁQUINAS E APARELHOS" }  ) 
	aAdd( aDadAux, { "SE","33903803","VEÍCULOS RODOVIÁRIOS" }  ) 
	aAdd( aDadAux, { "SE","33903804","OUTROS BENS MÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","33903805","BENS IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","33903899","OUTROS ARRENDAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","33903901","ASSINATURAS DE PERIÓDICOS E ANUIDADES" }  ) 
	aAdd( aDadAux, { "SE","33903902","CONDOMÍNIOS" }  ) 
	aAdd( aDadAux, { "SE","33903903","COMISSÕES, CORRETAGENS E CUSTÓDIA" }  ) 
	aAdd( aDadAux, { "SE","33903904","DIREITOS AUTORAIS" }  ) 
	aAdd( aDadAux, { "SE","33903905","SERVIÇOS TÉCNICOS PROFISSIONAIS" }  ) 
	aAdd( aDadAux, { "SE","33903907","DESCONTOS FINANCEIROS CONCEDIDOS- EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","33903909","ARMAZENAGEM" }  ) 
	aAdd( aDadAux, { "SE","33903910","LOCAÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","33903912","LOCAÇÃO DE MÁQUINAS E EQUIPAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","33903914","LOCAÇÃO BENS MÓVEIS DE OUTRAS NATUREZAS E INTANGÍVEIS" }  ) 
	aAdd( aDadAux, { "SE","33903915","TRIBUTOS À CONTA DO LOCATÁRIO" }  ) 
	aAdd( aDadAux, { "SE","33903916","MANUTENÇÃO E CONSERVAÇÃO DE BENS IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","33903917","MANUTENÇÃO E CONSERVAÇÃO DE MÁQUINAS E EQUIPAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","33903919","MANUTENÇÃO E CONSERVAÇÃO DE VEÍCULOS" }  ) 
	aAdd( aDadAux, { "SE","33903920","MANUTENÇÃO E CONSERVAÇÃO DE BENS MÓVEIS DE OUTRAS NATUREZAS" }  ) 
	aAdd( aDadAux, { "SE","33903922","EXPOSIÇÕES, CONGRESSOS E CONFERÊNCIAS" }  ) 
	aAdd( aDadAux, { "SE","33903923","FESTIVIDADES E HOMENAGENS" }  ) 
	aAdd( aDadAux, { "SE","33903935","MULTAS DEDUTÍVEIS - EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","33903936","MULTAS INDEDUTÍVEIS - EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","33903937","JUROS" }  ) 
	aAdd( aDadAux, { "SE","33903938","ENCARGOS FINANCEIROS DEDUTÍVEIS - EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","33903939","ENCARGOS FINANCEIROS INDEDUTÍVEIS - EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","33903940","PROGRAMA DE ALIMENTAÇÃO DO TRABALHADOR" }  ) 
	aAdd( aDadAux, { "SE","33903941","FORNECIMENTO DE ALIMENTAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33903943","SERVIÇOS DE ENERGIA ELÉTRICA" }  ) 
	aAdd( aDadAux, { "SE","33903944","SERVIÇOS DE ÁGUA E ESGOTO" }  ) 
	aAdd( aDadAux, { "SE","33903945","SERVIÇOS DE GÁS" }  ) 
	aAdd( aDadAux, { "SE","33903946","SERVIÇOS DOMÉSTICOS" }  ) 
	aAdd( aDadAux, { "SE","33903947","SERVIÇOS DE COMUNICAÇÃO EM GERAL" }  ) 
	aAdd( aDadAux, { "SE","33903948","SERVIÇO DE SELEÇÃO E TREINAMENTO" }  ) 
	aAdd( aDadAux, { "SE","33903949","PRODUÇÕES JORNALÍSTICAS" }  ) 
	aAdd( aDadAux, { "SE","33903950","SERVIÇO MÉDICO-HOSPITALAR, ODONTOLÓGICO E LABORATORIAIS" }  ) 
	aAdd( aDadAux, { "SE","33903951","SERVIÇOS DE ANÁLISES E PESQUISAS CIENTÍFICAS" }  ) 
	aAdd( aDadAux, { "SE","33903952","SERVIÇOS DE REABILITAÇÃO PROFISSIONAL" }  ) 
	aAdd( aDadAux, { "SE","33903953","SERVIÇOS DE ASSISTÊNCIA SOCIAL" }  ) 
	aAdd( aDadAux, { "SE","33903954","SERVIÇOS DE CRECHES E ASSISTÊNCIA PRÉ-ESCOLAR" }  ) 
	aAdd( aDadAux, { "SE","33903956","SERVIÇOS DE PERÍCIAS MÉDICAS/ODONTOLÓGICAS PARA BENEFÍCIOS" }  ) 
	aAdd( aDadAux, { "SE","33903957","SERVIÇOS DE PROCESSAMENTO DE DADOS" }  ) 
	aAdd( aDadAux, { "SE","33903958","SERVIÇOS DE TELECOMUNICAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33903959","SERVIÇOS DE ÁUDIO, VÍDEO E FOTO" }  ) 
	aAdd( aDadAux, { "SE","33903961","SERVIÇOS DE SOCORRO E SALVAMENTO" }  ) 
	aAdd( aDadAux, { "SE","33903962","SERVIÇOS DE PRODUÇÃO INDUSTRIAL" }  ) 
	aAdd( aDadAux, { "SE","33903963","SERVIÇOS GRÁFICOS E EDITORIAIS" }  ) 
	aAdd( aDadAux, { "SE","33903964","SERVIÇOS DE PERÍCIAS MÉDICAS/ODONTOLÓGICAS PARA BENEFÍCIOS" }  ) 
	aAdd( aDadAux, { "SE","33903965","SERVIÇOS DE APOIO AO ENSINO" }  ) 
	aAdd( aDadAux, { "SE","33903966","SERVIÇOS JUDICIÁRIOS" }  ) 
	aAdd( aDadAux, { "SE","33903967","SERVIÇOS FUNERÁRIOS" }  ) 
	aAdd( aDadAux, { "SE","33903968","SERVIÇOS DE CONSERVAÇÃO E BENEFICIAMENTO DE MERCADORIAS" }  ) 
	aAdd( aDadAux, { "SE","33903969","SEGUROS EM GERAL" }  ) 
	aAdd( aDadAux, { "SE","33903970","CONFECÇÃO DE UNIFORMES, BANDEIRAS E FLÂMULAS" }  ) 
	aAdd( aDadAux, { "SE","33903971","CONFECÇÃO DE MATERIAL DE ACONDICIONAMENTO E EMBALAGEM" }  ) 
	aAdd( aDadAux, { "SE","33903972","VALE-TRANSPORTE" }  ) 
	aAdd( aDadAux, { "SE","33903973","TRANSPORTE DE SERVIDORES / EMPREGADOS" }  ) 
	aAdd( aDadAux, { "SE","33903974","FRETES E TRANSPORTES DE ENCOMENDAS" }  ) 
	aAdd( aDadAux, { "SE","33903975","CONTRATOS DE GESTÃO-LEI COMPLEMENTAR 846/98" }  ) 
	aAdd( aDadAux, { "SE","33903977","VIGILÂNCIA OSTENSIVA MONITORADA" }  ) 
	aAdd( aDadAux, { "SE","33903978","LIMPEZA E CONSERVAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33903979","SERVIÇO DE APOIO ADMINISTRATIVO, TÉCNICO E OPERACIONAL" }  ) 
	aAdd( aDadAux, { "SE","33903980","HOSPEDAGENS" }  ) 
	aAdd( aDadAux, { "SE","33903981","SERVIÇOS BANCÁRIOS" }  ) 
	aAdd( aDadAux, { "SE","33903983","SERVIÇOS DE CÓPIAS E REPRODUÇÃO DE DOCUMENTOS" }  ) 
	aAdd( aDadAux, { "SE","33903988","SERVIÇOS DE PUBLICIDADE E PROPAGANDA" }  ) 
	aAdd( aDadAux, { "SE","33903989","SERVIÇOS DECORRENTES DE DECISÃO JUDICIAL" }  ) 
	aAdd( aDadAux, { "SE","33903990","SERVIÇOS DE PUBLICIDADE LEGAL" }  ) 
	aAdd( aDadAux, { "SE","33903994","AQUISIÇÃO DE SOFTWARES DE APLICAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33903995","MANUTENÇÃO E CONSERVAÇÃO DE EQUIPAMENTOS DE PROCESSAMENTO DE DADOS" }  ) 
	aAdd( aDadAux, { "SE","33903996","OUTROS SERVIÇOS DE TERCEIRO PESSOA JURÍDICA - PAGAMENTO ANTECIPADO" }  ) 
	aAdd( aDadAux, { "SE","33903999","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33904001","LOCAÇÃO DE EQUIPAMENTOS DE TECNOLOGIA DA INFORMAÇÃO E COMUNICAÇÃO - TIC - ATIVOS DE REDE" }  ) 
	aAdd( aDadAux, { "SE","33904002","DESENVOLVIMENTO E MANUTENÇÃO DE SOFTWARE" }  ) 
	aAdd( aDadAux, { "SE","33904003","HOSPEDAGENS DE SISTEMAS" }  ) 
	aAdd( aDadAux, { "SE","33904004","COMUNICAÇÃO DE DADOS" }  ) 
	aAdd( aDadAux, { "SE","33904005","SERVIÇOS DE TELEFONIA FIXA E MÓVEL" }  ) 
	aAdd( aDadAux, { "SE","33904006","SUPORTE AO USUÁRIO TIC" }  ) 
	aAdd( aDadAux, { "SE","33904007","SUPORTE DE INFRAESTRUTURA DE TIC" }  ) 
	aAdd( aDadAux, { "SE","33904008","SERVIÇOS TÉCNICOS PROFISSIONAIS DE TIC" }  ) 
	aAdd( aDadAux, { "SE","33904009","MANUTENÇÃO E CONSERVAÇÃO DE EQUIPAMENTO TIC" }  ) 
	aAdd( aDadAux, { "SE","33904010","DIGITALIZAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33904011","OUTSOURCING DE IMPRESSÃO E SERVIÇOS RELACIONADOS A COMPUTAÇÃO EM NUVEM" }  ) 
	aAdd( aDadAux, { "SE","33904012","TREINAMENTO E CAPACITAÇÃO EM TIC" }  ) 
	aAdd( aDadAux, { "SE","33904013","TRATAMENTO DE DADOS" }  ) 
	aAdd( aDadAux, { "SE","33904014","CONTEÚDO DE WEB" }  ) 
	aAdd( aDadAux, { "SE","33904015","DESPESAS DE TELEPROCESSAMENTO" }  ) 
	aAdd( aDadAux, { "SE","33904016","LOCAÇÃO DE SOFTWARE                                     " }  ) 
	aAdd( aDadAux, { "SE","33904022","MANUTENÇÃO E CONSERVAÇÃO DE EQUIPAMENTOS DE TECNOLOGIA DA INFORMAÇÃO E COMUNICAÇÃO - TIC         " }  ) 
	aAdd( aDadAux, { "SE","33904024","TELEFONIA FIXA E MÓVEL - PACOTE DE COMUNICAÇÃO DE DADOS " }  ) 
	aAdd( aDadAux, { "SE","33904099","OUTROS SERVIÇOS DE TECNOLOGIA DA INFORMAÇÃO E COMUNICAÇÃO - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33904100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33904501","PARCELAS DAS CONTRAPRESTAÇÕES REFERENTES À REMUNERAÇÃO DO PARCEIRO" }  ) 
	aAdd( aDadAux, { "SE","33904599","OUTRAS SUBVENÇÕES ECONÔMICAS" }  ) 
	aAdd( aDadAux, { "SE","33904601","INDENIZAÇÃO AUXÍLIO ALIMENTAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33904702","IMPOSTO SOBRE A PROPRIEDADE PREDIAL E TERRITORIAL URBANA - IPTU" }  ) 
	aAdd( aDadAux, { "SE","33904703","IMPOSTO DE RENDA" }  ) 
	aAdd( aDadAux, { "SE","33904708","IMPOSTO SOBRE SERVIÇO DE QUALQUER NATUREZA - ISSQN" }  ) 
	aAdd( aDadAux, { "SE","33904712","CONTRIBUIÇÃO PARA O PIS/PASEP" }  ) 
	aAdd( aDadAux, { "SE","33904715","MULTAS" }  ) 
	aAdd( aDadAux, { "SE","33904718","CONTRIBUIÇÕES PREVIDENCIÁRIAS - SERVIÇOS DE TERCEIROS" }  ) 
	aAdd( aDadAux, { "SE","33904799","OUTRAS OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","33904800","OUTROS AUXÍLIOS FINANCEIROS A PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33904806","RESIDÊNCIA MÉDICA" }  ) 
	aAdd( aDadAux, { "SE","33904807","RESIDÊNCIA MULTIPROFISSIONAL EM SAÚDE" }  ) 
	aAdd( aDadAux, { "SE","33904899","DEMAIS AUXÍLIOS FINANCEIROS A PESSOAS FÍSICAS" }  ) 
	aAdd( aDadAux, { "SE","33904901","INDENIZAÇÃO AUXÍLIO TRANSPORTE" }  ) 
	aAdd( aDadAux, { "SE","33905900","PENSÕES ESPECIAIS " }  ) 
	aAdd( aDadAux, { "SE","33906700","DEPÓSITOS COMPULSÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","33908301","CONTRAPRESTAÇÕES REFERENTES À REMUNERAÇÃO DO PARCEIRO PRIVADO POR SERVIÇOS EM CONCESSÕES ADMINISTRATIVAS" }  ) 
	aAdd( aDadAux, { "SE","33908399","OUTRAS DESPESAS DECORRENTES DE CONTRATOS DE PPP, EXCETO SUBVENÇÕES ECONÔMICAS, APORTE E FUNDO GARANTIDOR" }  ) 
	aAdd( aDadAux, { "SE","33909101","SENTENÇAS PARA CRÉDITOS ALIMENTÍCIOS / SENTENÇAS JUDICIAIS TRANSITADAS EM JULGADO" }  ) 
	aAdd( aDadAux, { "SE","33909102","PRECATÓRIOS INCLUÍDOS NA LEI ORÇAMENTÁRIA" }  ) 
	aAdd( aDadAux, { "SE","33909103","LIMINARES EM MANDADOS DE SEGURANÇA" }  ) 
	aAdd( aDadAux, { "SE","33909104","SENTENÇAS INDENIZATÓRIAS" }  ) 
	aAdd( aDadAux, { "SE","33909105","SENTENÇAS PARA CRÉDITOS DE DÍVIDA ATIVA" }  ) 
	aAdd( aDadAux, { "SE","33909113","PRECATÓRIOS JUDICIAS" }  ) 
	aAdd( aDadAux, { "SE","33909114","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","33909115","SENTENÇAS JUDICIAIS DE PEQUENO VALOR" }  ) 
	aAdd( aDadAux, { "SE","33909120","DEPÓSITOS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","33909125","HONORÁRIOS SUCUMBENCIAIS DE PRECATÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","33909143","REQUISITÓRIOS COMPLEMENTARES" }  ) 
	aAdd( aDadAux, { "SE","33909151","SENTENÇAS PARA CRÉDITOS ALIMENTÍCIOS- ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","33909152","PRECATÓRIOS INCLUÍDOS NA LEI ORÇAMENTÁRIA - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","33909153","LIMINARES EM MANDADOS DE SEGURANÇA - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","33909154","SENTENÇAS INDENIZATÓRIAS - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","33909155","SENTENÇAS PARA CRÉDITOS DE DÍVIDA ATIVA - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","33909156","REQUISITÓRIOS COMPLEMENTARES - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","33909197","OUTROS PRECATÓRIOS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","33909199","DIVERSAS SENTENÇAS" }  ) 
	aAdd( aDadAux, { "SE","33909201","APOSENTADORIAS E REFORMAS" }  ) 
	aAdd( aDadAux, { "SE","33909203","PENSÕES" }  ) 
	aAdd( aDadAux, { "SE","33909204","CONTRATAÇÃO POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","33909205","OUTROS BENEFÍCIOS PREVIDENCIÁRIOS" }  ) 
	aAdd( aDadAux, { "SE","33909206","BENEFÍCIO MENSAL AO DEFICIENTE E AO IDOSO" }  ) 
	aAdd( aDadAux, { "SE","33909208","OUTROS BENEFÍCIOS ASSISTENCIAIS DO SERVIDOR E DO MILITAR" }  ) 
	aAdd( aDadAux, { "SE","33909214","DIÁRIAS - CIVIL" }  ) 
	aAdd( aDadAux, { "SE","33909218","AUXÍLIO FINANCEIRO A ESTUDANTES" }  ) 
	aAdd( aDadAux, { "SE","33909220","AUXÍLIO FINANCEIRO A PESQUISADORES" }  ) 
	aAdd( aDadAux, { "SE","33909230","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33909231","PREMIAÇÕES CULTURAIS, CIENTÍFICAS, ARTÍSTICAS, DESPORTIVAS E OUTRAS" }  ) 
	aAdd( aDadAux, { "SE","33909232","MATERIAL, BEM OU SERVIÇO DE DISTRIBUIÇÃO GRATUITA" }  ) 
	aAdd( aDadAux, { "SE","33909233","PASSAGENS E DESPESAS COM LOCOMOÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33909234","OUTRAS DESPESAS DE PESSOAL DECORRENTES DE CONTRATO DE TERCEIRIZAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33909235","SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","33909236","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33909237","LOCAÇÃO DE MÃO DE OBRA" }  ) 
	aAdd( aDadAux, { "SE","33909238","ARRENDAMENTO MERCANTIL" }  ) 
	aAdd( aDadAux, { "SE","33909239","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33909245","SUBVENÇÕES ECONÔMICAS" }  ) 
	aAdd( aDadAux, { "SE","33909246","AUXÍLIO ALIMENTAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33909247","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","33909248","OUTROS AUXÍLIOS FINANCEIROS A PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33909249","AUXÍLIO TRANSPORTE" }  ) 
	aAdd( aDadAux, { "SE","33909259","PENSÕES ESPECIAIS" }  ) 
	aAdd( aDadAux, { "SE","33909267","DEPÓSITOS COMPULSÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","33909291","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","33909293","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33909296","RESSARCIMENTO DE DESPESAS COM PESSOAL REQUISITADO" }  ) 
	aAdd( aDadAux, { "SE","33909299","OUTRAS DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33909301","INDENIZAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33909302","RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33909303","AJUDA DE CUSTO" }  ) 
	aAdd( aDadAux, { "SE","33909305","INDENIZAÇÃO DE TRANSPORTE" }  ) 
	aAdd( aDadAux, { "SE","33909307","INDENIZAÇÃO DE MORADIA" }  ) 
	aAdd( aDadAux, { "SE","33909308","RESSARCIMENTO ASSISTÊNCIA MÉDICA/ODONTOLÓGICA" }  ) 
	aAdd( aDadAux, { "SE","33909314","RESSARCIMENTO DE PASSAGENS E DESPESAS COM LOCOMOÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33909399","DIVERSAS INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33909500","INDENIZAÇÃO PELA EXECUÇÃO DE TRABALHOS DE CAMPO" }  ) 
	aAdd( aDadAux, { "SE","33910415","OBRIGAÇÕES PATRONAIS" }  ) 
	aAdd( aDadAux, { "SE","33910499","OUTRAS CONTRATAÇÕES POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","33912800","REMUNERAÇÃO DE COTAS DE FUNDOS AUTÁRQUICOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33912900","DISTRIBUIÇÃO DE RESULTADO DE EMPRESAS ESTATAIS DEPENDENTES" }  ) 
	aAdd( aDadAux, { "SE","33913000","MATERIAL DE CONSUMO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913001","COMBUSTÍVEIS E LUBRIFICANTES AUTOMOTIVOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913003","COMBUSTÍVEIS E LUBRIFICANTES PARA OUTRAS FINALIDADES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913004","GÁS ENGARRAFADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913005","EXPLOSIVOS E MUNIÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913006","ALIMENTOS PARA ANIMAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913007","GÊNEROS DE ALIMENTAÇÃO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913008","ANIMAIS PARA PESQUISAS E ABATE - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913009","MATERIAL FARMACOLÓGICO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913010","MATERIAL ODONTOLÓGICO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913011","MATERIAL QUÍMICO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913012","MATERIAL DE COUDELARIA OU DE USO ZOOTÉCNICO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913013","MATERIAL DE CAÇA E PESCA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913014","MATERIAL EDUCATIVO E ESPORTIVO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913015","MATERIAL PARA FESTIVIDADES E HOMENAGENS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913016","MATERIAL DE EXPEDIENTE - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913017","MATERIAL DE PROCESSAMENTO DE DADOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913018","MATERIAIS E MEDICAMENTOS PARA USO VETERINÁRIO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913019","MATERIAL DE ACONDICIONAMENTO E EMBALAGEM - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913020","MATERIAL DE CAMA, MESA E BANHO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913021","MATERIAL DE COPA E COZINHA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913022","MATERIAL DE LIMPEZA E HIGIENIZAÇÃO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913023","UNIFORMES, TECIDOS E AVIAMENTOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913024","MATERIAL PARA MANUTENÇÃO DE BENS IMÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913025","MATERIAL PARA MANUTENÇÃO DE BENS MÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913026","MATERIAL ELÉTRICO E ELETRÔNICO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913028","MATERIAL DE PROTEÇÃO E SEGURANÇA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913029","MATERIAL PARA ÁUDIO, VÍDEO E FOTO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913030","MATERIAL PARA COMUNICAÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913031","SEMENTES, MUDAS DE PLANTAS E INSUMOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913033","MATERIAL PARA PRODUÇÃO INDUSTRIAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913034","SOBRESSALENTES, MÁQUINAS E MOTORES DE NAVIOS E EMBARCAÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913035","MATERIAL LABORATORIAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913036","MATERIAL HOSPITALAR - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913039","MATERIAL PARA MANUTENÇÃO DE VEÍCULOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913041","MATERIAL PARA UTILIZAÇÃO EM GRÁFICA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913042","FERRAMENTAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913043","MATERIAL PARA REABILITAÇÃO PROFISSIONAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913044","MATERIAL DE SINALIZAÇÃO VISUAL E AFINS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913045","MATERIAL TÉCNICO PARA SELEÇÃO E TREINAMENTO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913046","MATERIAL BIBLIOGRÁFICO NÃO IMOBILIZÁVEL - INTRA OFSS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913047","AQUISIÇÃO DE SOFTWARES DE BASE - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913050","BANDEIRAS, FLÂMULAS E INSÍGNIAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913099","OUTROS MATERIAIS DE CONSUMO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913100","PREMIAÇÕES CULTURAIS, ARTÍSTICAS, CIENTÍFICAS, DESPORTIVAS E OUTRAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913200","MATERIAL, BEM OU SERVIÇO PARA DISTRIBUIÇÃO GRATUITA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913500","SERVIÇOS DE CONSULTORIA " }  ) 
	aAdd( aDadAux, { "SE","33913501","ASSESSORIA E CONSULTORIA TÉCNICA OU JURÍDICA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913502","AUDITORIA EXTERNA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913599","OUTROS SERVIÇOS DE CONSULTORIA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913701","APOIO ADMINISTRATIVO, TÉCNICO E OPERACIONAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913702","LIMPEZA E CONSERVAÇÃO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913703","VIGILÂNCIA OSTENSIVA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913704","MANUTENÇÃO E CONSERVAÇÃO DE BENS IMÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913705","SERVIÇOS DE COPA E COZINHA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913706","MANUTENÇÃO E CONSERVAÇÃO DE BENS MÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913799","OUTRAS LOCAÇÕES DE MÃO DE OBRA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913801","MÁQUINAS E APARELHOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913803","VEÍCULOS RODOVIÁRIOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913804","OUTROS BENS MÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913805","BENS IMÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913899","OUTROS ARRENDAMENTOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913901","ASSINATURAS DE PERIÓDICOS E ANUIDADES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913902","CONDOMÍNIOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913903","COMISSÕES, CORRETAGENS E CUSTÓDIA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913904","DIREITOS AUTORAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913905","SERVIÇOS TÉCNICOS PROFISSIONAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913909","ARMAZENAGEM - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913910","LOCAÇÃO DE IMÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913912","LOCAÇÃO DE MÁQUINAS E EQUIPAMENTOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913914","LOCAÇÃO BENS MÓVEIS DE OUTRAS NATUREZAS E INTANGÍVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913915","TRIBUTOS À CONTA DO LOCATÁRIO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913916","MANUTENÇÃO E CONSERVAÇÃO DE BENS IMÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913917","MANUTENÇÃO E CONSERVAÇÃO DE MÁQUINAS E EQUIPAMENTOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913919","MANUTENÇÃO E CONSERVAÇÃO DE VEÍCULOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913920","MANUTENÇÃO E CONSERVAÇÃO DE BENS MÓVEIS DE OUTRAS NATUREZAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913922","EXPOSIÇÕES, CONGRESSOS E CONFERÊNCIAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913923","FESTIVIDADES E HOMENAGENS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913937","JUROS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913940","PROGRAMA DE ALIMENTAÇÃO DO TRABALHADOR - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913941","FORNECIMENTO DE ALIMENTAÇÃO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913943","SERVIÇOS DE ENERGIA ELÉTRICA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913944","SERVIÇOS DE ÁGUA E ESGOTO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913945","SERVIÇOS DE GÁS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913946","SERVIÇOS DOMÉSTICOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913947","SERVIÇOS DE COMUNICAÇÃO EM GERAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913948","SERVIÇO DE SELEÇÃO E TREINAMENTO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913949","PRODUÇÕES JORNALÍSTICAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913950","SERVIÇO MÉDICO-HOSPITALAR, ODONTOLÓGICO E LABORATORIAIS" }  ) 
	aAdd( aDadAux, { "SE","33913951","SERVIÇOS DE ANÁLISES E PESQUISAS CIENTÍFICAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913952","SERVIÇOS DE REABILITAÇÃO PROFISSIONAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913953","SERVIÇOS DE ASSISTÊNCIA SOCIAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913954","SERVIÇOS DE CRECHES E ASSISTÊNCIA PRÉ-ESCOLAR - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913956","SERVIÇOS DE PERÍCIAS MÉDICAS PARA BENEFÍCIOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913957","SERVIÇOS DE PROCESSAMENTO DE DADOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913958","SERVIÇOS DE TELECOMUNICAÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913959","SERVIÇOS DE ÁUDIO, VÍDEO E FOTO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913961","SERVIÇOS DE SOCORRO E SALVAMENTO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913962","SERVIÇOS DE PRODUÇÃO INDUSTRIAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913963","SERVIÇOS GRÁFICOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913965","SERVIÇOS DE APOIO AO ENSINO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913966","SERVIÇOS JUDICIÁRIOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913967","SERVIÇOS FUNERÁRIOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913968","SERVIÇOS DE CONSERVAÇÃO E BENEFICIAMENTO DE MERCADORIAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913969","SEGUROS EM GERAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913970","CONFECÇÃO DE UNIFORMES, BANDEIRAS E FLÂMULAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913971","CONFECÇÃO DE MATERIAL DE ACONDICIONAMENTO E EMBALAGEM - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913972","VALE-TRANSPORTE - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913973","TRANSPORTE DE SERVIDORES / EMPREGADOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913974","FRETES E TRANSPORTES DE ENCOMENDAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913977","VIGILÂNCIA OSTENSIVA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913978","LIMPEZA E CONSERVAÇÃO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913979","SERVIÇO DE APOIO ADMINISTRATIVO, TÉCNICO E OPERACIONAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913980","HOSPEDAGENS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913983","SERVIÇOS DE CÓPIAS E REPRODUÇÃO DE DOCUMENTOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913988","SERVIÇOS DE PROPAGANDA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913990","SERVIÇOS DE PUBLICIDADE LEGAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913994","AQUISIÇÃO DE SOFTWARES DE APLICAÇÃO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913995","MANUTENÇÃO E CONSERVAÇÃO DE EQUIPAMENTOS DE PROCESSAMENTO DE DADOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913996","OUTROS SERVIÇOS DE TERCEIRO PESSOA JURÍDICA - PAGAMENTO ANTECIPADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33913999","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914000","SERVIÇOS DE TECNOLOGIA DA INFORMAÇÃO E COMUNICAÇÃO - PESSOA JURÍDICA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914001","LOCAÇÃO DE EQUIPAMENTOS E SOFTWARE - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914002","DESENVOLVIMENTO E MANUTENÇÃO DE SOFTWARE - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914003","HOSPEDAGENS DE SISTEMAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914004","COMUNICAÇÃO DE DADOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914005","SERVIÇOS DE TELEFONIA FIXA E MÓVEL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914006","SUPORTE AO USUÁRIO TIC - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914007","SUPORTE DE INFRAESTRUTURA DE TIC - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914008","SERVIÇOS TÉCNICOS PROFISSIONAIS DE TIC - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914009","MANUTENÇÃO E CONSERVAÇÃO DE EQUIPAMENTO TIC - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914010","DIGITALIZAÇÃO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914011","OUTSOURCING DE IMPRESSÃO E SERVIÇOS RELACIONADOS A COMPUTAÇÃO EM NUVEM - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914012","TREINAMENTO E CAPACITAÇÃO EM TIC - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914013","TRATAMENTO DE DADOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914014","CONTEÚDO DE WEB - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914015","DESPESAS DE TELEPROCESSAMENTO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914099","OUTROS SERVIÇOS DE TECNOLOGIA DA INFORMAÇÃO E COMUNICAÇÃO - PJ - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914700","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914718","CONTRIBUIÇÕES PREVIDENCIÁRIAS - SERVIÇOS DE TERCEIROS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33914790","IMPOSTO SOBRE PROPRIEDADE PREDIAL E TERRITORIAL URBANA - IPTU" }  ) 
	aAdd( aDadAux, { "SE","33914799","OUTRAS OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33916200","AQUISIÇÃO DE PRODUTOS PARA REVENDA" }  ) 
	aAdd( aDadAux, { "SE","33916700","DEPÓSITOS COMPULSÓRIOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919101","SENTENÇAS PARA CRÉDITOS ALIMENTÍCIOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919102","PRECATÓRIOS INCLUÍDOS NA LEI ORÇAMENTÁRIA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919103","LIMINARES EM MANDADOS DE SEGURANÇA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919104","SENTENÇAS INDENIZATÓRIAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919105","SENTENÇAS PARA CRÉDITOS DE DÍVIDA ATIVA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919114","SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919115","SENTENÇAS JUDICIAIS DE PEQUENO VALOR - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919143","REQUISITÓRIOS COMPLEMENTARES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919151","SENTENÇAS PARA CRÉDITOS ALIMENTÍCIOS- ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919152","PRECATÓRIOS INCLUÍDOS NA LEI ORÇAMENTÁRIA - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919153","LIMINARES EM MANDADOS DE SEGURANÇA - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919154","SENTENÇAS INDENIZATÓRIAS - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919155","SENTENÇAS PARA CRÉDITOS DE DÍVIDA ATIVA - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919156","REQUISITÓRIOS COMPLEMENTARES - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919199","OUTRAS SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919230","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33919233","PASSAGENS E DESPESAS COM LOCOMOÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33919239","SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33919247","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","33919291","SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919293","INDENIZAÇÕES E RESTITUIÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919299","OUTRAS DESPESAS CORRENTES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919300","INDENIZAÇÕES E RESTITUIÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919301","INDENIZAÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919302","RESTITUIÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919399","DIVERSAS INDENIZAÇÕES E RESTITUIÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919500","INDENIZAÇÃO PELA EXECUÇÃO DE TRABALHOS DE CAMPO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","33919600","RESSARCIMENTO DE DESPESAS DE PESSOAL REQUISITADO " }  ) 
	aAdd( aDadAux, { "SE","33919700","APORTE PARA COBERTURA DO DÉFICIT ATUARIAL DO RPPS" }  ) 
	aAdd( aDadAux, { "SE","33923000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33923500","SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","33923600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33923700","LOCAÇÃO DE MÃO DE OBRA" }  ) 
	aAdd( aDadAux, { "SE","33923800","ARRENDAMENTO MERCANTIL" }  ) 
	aAdd( aDadAux, { "SE","33923900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33924000","SERVIÇOS DE TECNOLOGIA DA INFORMAÇÃO E COMUNICAÇÃO - PJ" }  ) 
	aAdd( aDadAux, { "SE","33928300","CONTRATO DE PPP, EXCETO SUBVENÇÕES ECONÔMICAS, APORTE E FUNDO GARANTIDOR" }  ) 
	aAdd( aDadAux, { "SE","33933000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33933200","MATERIAL, BEM OU SERVIÇO PARA DISTRIBUIÇÃO GRATUITA" }  ) 
	aAdd( aDadAux, { "SE","33933900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33943000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33943200","MATERIAL, BEM OU SERVIÇO PARA DISTRIBUIÇÃO GRATUITA" }  ) 
	aAdd( aDadAux, { "SE","33943900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33950400","CONTRATAÇÃO POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","33950800","OUTROS BENEFÍCIOS ASSISTENCIAIS DO SERVIDOR E DO MILITAR" }  ) 
	aAdd( aDadAux, { "SE","33951400","DIÁRIAS - CIVIL" }  ) 
	aAdd( aDadAux, { "SE","33951800","AUXÍLIO FINANCEIRO A ESTUDANTES" }  ) 
	aAdd( aDadAux, { "SE","33952000","AUXÍLIO FINANCEIRO A PESQUISADORES" }  ) 
	aAdd( aDadAux, { "SE","33953000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33953100","PREMIAÇÕES CULTURAIS, ARTÍSTICAS, CIENTÍFICAS, DESPORTIVAS E OUTRAS" }  ) 
	aAdd( aDadAux, { "SE","33953200","MATERIAL, BEM OU SERVIÇO PARA DISTRIBUIÇÃO GRATUITA" }  ) 
	aAdd( aDadAux, { "SE","33953300","PASSAGENS E DESPESAS COM LOCOMOÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33953400","OUTRAS DESPESAS DE PESSOAL DECORRENTES DE CONTRATOS DE TERCEIRIZAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33953500","SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","33953600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33953700","LOCAÇÃO DE MÃO DE OBRA" }  ) 
	aAdd( aDadAux, { "SE","33953800","ARRENDAMENTO MERCANTIL" }  ) 
	aAdd( aDadAux, { "SE","33953900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33954100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33954500","SUBVENÇÕES ECONÔMICAS" }  ) 
	aAdd( aDadAux, { "SE","33954600","AUXÍLIO-ALIMENTAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33954700","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","33954800","OUTROS AUXÍLIOS FINANCEIROS A PESSOAS FÍSICAS" }  ) 
	aAdd( aDadAux, { "SE","33954900","AUXÍLIO-TRANSPORTE" }  ) 
	aAdd( aDadAux, { "SE","33956700","DEPÓSITOS COMPULSÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","33959100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","33959200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33959300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33959600","RESSARCIMENTO DE DESPESAS DE PESSOAL REQUISITADO" }  ) 
	aAdd( aDadAux, { "SE","33960400","CONTRATAÇÃO POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","33960800","OUTROS BENEFÍCIOS ASSISTENCIAIS DO SERVIDOR E DO MILITAR" }  ) 
	aAdd( aDadAux, { "SE","33961400","DIÁRIAS - CIVIL" }  ) 
	aAdd( aDadAux, { "SE","33961800","AUXÍLIO FINANCEIRO A ESTUDANTES" }  ) 
	aAdd( aDadAux, { "SE","33962000","AUXÍLIO FINANCEIRO A PESQUISADORES" }  ) 
	aAdd( aDadAux, { "SE","33963000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","33963100","PREMIAÇÕES CULTURAIS, ARTÍSTICAS, CIENTÍFICAS, DESPORTIVAS E OUTRAS" }  ) 
	aAdd( aDadAux, { "SE","33963200","MATERIAL, BEM OU SERVIÇO PARA DISTRIBUIÇÃO GRATUITA" }  ) 
	aAdd( aDadAux, { "SE","33963300","PASSAGENS E DESPESAS COM LOCOMOÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33963400","OUTRAS DESPESAS DE PESSOAL DECORRENTES DE CONTRATOS DE TERCEIRIZAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33963500","SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","33963600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","33963700","LOCAÇÃO DE MÃO DE OBRA" }  ) 
	aAdd( aDadAux, { "SE","33963800","ARRENDAMENTO MERCANTIL" }  ) 
	aAdd( aDadAux, { "SE","33963900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","33964100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33964500","SUBVENÇÕES ECONÔMICAS" }  ) 
	aAdd( aDadAux, { "SE","33964600","AUXÍLIO-ALIMENTAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","33964700","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","33964800","OUTROS AUXÍLIOS FINANCEIROS A PESSOAS FÍSICAS" }  ) 
	aAdd( aDadAux, { "SE","33964900","AUXÍLIO-TRANSPORTE" }  ) 
	aAdd( aDadAux, { "SE","33966700","DEPÓSITOS COMPULSÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","33969100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","33969200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","33969300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","33969600","RESSARCIMENTO DE DESPESAS DE PESSOAL REQUISITADO" }  ) 
	aAdd( aDadAux, { "SE","44204100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44204200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44225100","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44225200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44229200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","44229300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44304100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44304200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44314100","CONTRIBUIÇÕES " }  ) 
	aAdd( aDadAux, { "SE","44314200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44319200","DESPESAS DE EXERCÍCIOS ANTERIORES " }  ) 
	aAdd( aDadAux, { "SE","44322000","AUXÍLIO FINANCEIRO A PESQUISADORES" }  ) 
	aAdd( aDadAux, { "SE","44325100","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44325200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44329200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","44329300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44354100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44354200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44359200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","44364100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44364200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44369200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","44404100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44404200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44409200","DESPESAS DE EXERCÍCIOS ANTERIORES " }  ) 
	aAdd( aDadAux, { "SE","44414100","CONTRIBUIÇÕES " }  ) 
	aAdd( aDadAux, { "SE","44414200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44419200","DESPESAS DE EXERCÍCIOS ANTERIORES " }  ) 
	aAdd( aDadAux, { "SE","44421400","DIÁRIAS - CIVIL" }  ) 
	aAdd( aDadAux, { "SE","44425100","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44425200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44429200","DESPESAS DE EXERCÍCIO ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","44454100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44454200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44459200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","44464100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44464200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44469200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","44501400","DIÁRIAS - CIVIL" }  ) 
	aAdd( aDadAux, { "SE","44503000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","44503600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","44503900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","44503901","TERMO DE COLABORAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","44503902","TERMO DE FOMENTO" }  ) 
	aAdd( aDadAux, { "SE","44503903","ACORDO DE COOPERAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","44503904","CONTRATO DE GESTÃO" }  ) 
	aAdd( aDadAux, { "SE","44503999","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","44504100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44504200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44504700","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","44505100","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44505200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44604100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44604500","SUBVENÇÕES ECONÔMICAS" }  ) 
	aAdd( aDadAux, { "SE","44678200","APORTE DE RECURSOS PELO PARCEIRO PÚBLICO EM FAVOR DO PARCEIRO PRIVADO DECORRENTE DE CONTRATO DE PARCERIA PÚBLICO-PRIVADA - PPP" }  ) 
	aAdd( aDadAux, { "SE","44678300","DESPESAS DECORRENTES DE CONTRATO DE PARCERIA PÚBLICO-PRIVADA - PPP, EXCETO SUBVENÇÕES ECONÔMICAS, APORTE E FUNDO GARANTIDOR" }  ) 
	aAdd( aDadAux, { "SE","44704100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44704200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44717000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","44715200","EQUIPAMENTOS E MATERIAL PERMANENTE - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","44715100","OBRAS E INSTALAÇÕES - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","44716100","AQUISIÇÃO DE IMÓVEIS - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","44719100","SENTENÇAS JUDICIAIS - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","44719200","DESPESAS DE EXERCÍCIOS ANTERIORES - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","44719300","INDENIZAÇÕES E RESTITUIÇÕES - TRANSFERÊNCIAS A CONSÓRCIOS PÚBLICOS" }  ) 
	aAdd( aDadAux, { "SE","44721400","DIÁRIAS - CIVIL" }  ) 
	aAdd( aDadAux, { "SE","44723000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","44723600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","44723900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","44725100","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44725200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44729200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","44737000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","44747000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","44754100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44754200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44764100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44764200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44804100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44804200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","44805100","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44805200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44900400","CONTRATAÇÃO POR TEMPO DETERMINADO" }  ) 
	aAdd( aDadAux, { "SE","44901400","DIÁRIAS - PESSOAL CIVIL" }  ) 
	aAdd( aDadAux, { "SE","44901800","AUXÍLIO FINANCEIRO A ESTUDANTE" }  ) 
	aAdd( aDadAux, { "SE","44902000","AUXÍLIO FINANCEIRO A PESQUISADORES" }  ) 
	aAdd( aDadAux, { "SE","44903000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","44903300","PASSAGENS E DESPESAS COM LOCOMOÇÃO" }  ) 
	aAdd( aDadAux, { "SE","44903500","SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","44903600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","44903700","LOCAÇÃO DE MÃO DE OBRA" }  ) 
	aAdd( aDadAux, { "SE","44903900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","44904000","SERVIÇOS DE TECNOLOGIA DA INFORMAÇÃO E COMUNICAÇÃO - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","44904700","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","44905180","ESTUDOS E PROJETOS" }  ) 
	aAdd( aDadAux, { "SE","44905191","OBRAS EM ANDAMENTO" }  ) 
	aAdd( aDadAux, { "SE","44905192","INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44905193","BENFEITORIAS EM PROPRIEDADES DE TERCEIROS" }  ) 
	aAdd( aDadAux, { "SE","44905199","OUTRAS OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44905202","AERONAVES" }  ) 
	aAdd( aDadAux, { "SE","44905204","APARELHOS DE MEDIÇÃO E ORIENTAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","44905206","APARELHOS E EQUIPAMENTOS DE COMUNICAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","44905208","APARELHOS, EQUIPAMENTOS, UTENSÍLIOS MÉDICO-ODONTOLÓGICO, LABORATORIAL E HOSPITALAR" }  ) 
	aAdd( aDadAux, { "SE","44905210","APARELHOS E EQUIPAMENTOS PARA ESPORTES E DIVERSÕES" }  ) 
	aAdd( aDadAux, { "SE","44905212","APARELHOS E UTENSÍLIOS DOMÉSTICOS" }  ) 
	aAdd( aDadAux, { "SE","44905218","COLEÇÕES E MATERIAIS BIBLIOGRÁFICOS" }  ) 
	aAdd( aDadAux, { "SE","44905219","DISCOTECAS E FILMOTECAS" }  ) 
	aAdd( aDadAux, { "SE","44905220","EMBARCAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44905224","EQUIPAMENTO DE PROTEÇÃO, SEGURANÇA E SOCORRO" }  ) 
	aAdd( aDadAux, { "SE","44905226","INSTRUMENTOS MUSICAIS E ARTÍSTICOS" }  ) 
	aAdd( aDadAux, { "SE","44905228","MÁQUINAS E EQUIPAMENTOS DE NATUREZA INDUSTRIAL" }  ) 
	aAdd( aDadAux, { "SE","44905230","MÁQUINAS E EQUIPAMENTOS ENERGÉTICOS" }  ) 
	aAdd( aDadAux, { "SE","44905232","MÁQUINAS E EQUIPAMENTOS GRÁFICOS" }  ) 
	aAdd( aDadAux, { "SE","44905233","EQUIPAMENTOS PARA ÁUDIO, VÍDEO E FOTO" }  ) 
	aAdd( aDadAux, { "SE","44905234","MÁQUINAS, UTENSÍLIOS E EQUIPAMENTOS DIVERSOS" }  ) 
	aAdd( aDadAux, { "SE","44905235","EQUIPAMENTOS DE PROCESSAMENTO DE DADOS" }  ) 
	aAdd( aDadAux, { "SE","44905236","MÁQUINAS, INSTALAÇÕES E UTENSÍLIOS DE ESCRITÓRIO" }  ) 
	aAdd( aDadAux, { "SE","44905238","MÁQUINAS, FERRAMENTAS E UTENSÍLIOS DE OFICINA" }  ) 
	aAdd( aDadAux, { "SE","44905239","EQUIPAMENTOS E UTENSÍLIOS HIDRÁULICOS E ELÉTRICOS" }  ) 
	aAdd( aDadAux, { "SE","44905242","MOBILIÁRIO EM GERAL" }  ) 
	aAdd( aDadAux, { "SE","44905244","OBRAS DE ARTE E PEÇAS PARA EXPOSIÇÃO/MUSEU" }  ) 
	aAdd( aDadAux, { "SE","44905246","SEMOVENTES E EQUIPAMENTOS DE MONTARIA" }  ) 
	aAdd( aDadAux, { "SE","44905248","VEÍCULOS DIVERSOS " }  ) 
	aAdd( aDadAux, { "SE","44905251","PEÇAS NÃO INCORPORÁVEIS A IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","44905252","VEÍCULOS DE TRAÇÃO MECÂNICA" }  ) 
	aAdd( aDadAux, { "SE","44905257","ACESSÓRIOS PARA AUTOMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","44905287","MATERIAL DE CONSUMO DE USO DURADOURO" }  ) 
	aAdd( aDadAux, { "SE","44905299","OUTROS MATERIAIS PERMANENTES" }  ) 
	aAdd( aDadAux, { "SE","44906101","EDIFÍCIOS - REALIZAÇÃO DE OBRAS" }  ) 
	aAdd( aDadAux, { "SE","44906103","TERRENOS" }  ) 
	aAdd( aDadAux, { "SE","44906199","OUTRAS AQUISIÇÕES DE BENS IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","44906200","AQUISIÇÃO DE PRODUTOS PARA REVENDA" }  ) 
	aAdd( aDadAux, { "SE","44909100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","44909105","SENTENÇAS JUDICIAIS TRANSITADAS EM JULGADO" }  ) 
	aAdd( aDadAux, { "SE","44909160","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","44909161","SENTENÇAS JUDICIAIS - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","44909199","OUTRAS SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","44909201","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44909202","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44909214","DIÁRIAS - CIVIL" }  ) 
	aAdd( aDadAux, { "SE","44909230","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","44909235","SERVIÇOS DE CONSULTORIA" }  ) 
	aAdd( aDadAux, { "SE","44909236","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","44909237","LOCAÇÃO DE MÃO DE OBRA" }  ) 
	aAdd( aDadAux, { "SE","44909239","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","44909251","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44909252","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44909293","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44909299","OUTRAS DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","44909300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44909301","INDENIZAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44909302","RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44909399","DIVERSAS INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44913900","OUTROS SERVIÇOS DE TERCEIROS - PESSOA JURÍDICA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44914700","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","44915100","OBRAS E INSTALAÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915191","OBRAS EM ANDAMENTO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915192","INSTALAÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915193","BENFEITORIAS EM PROPRIEDADES DE TERCEIROS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915199","OUTRAS OBRAS E INSTALAÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915200","EQUIPAMENTOS E MATERIAL PERMANENTE - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915206","APARELHOS E EQUIPAMENTOS DE COMUNICAÇÃO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915212","APARELHOS E UTENSÍLIOS DOMÉSTICOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915218","COLEÇÕES E MATERIAIS BIBLIOGRÁFICOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915224","EQUIPAMENTO DE PROTEÇÃO, SEGURANÇA E SOCORRO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915232","MÁQUINAS E EQUIPAMENTOS GRÁFICOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915233","EQUIPAMENTOS PARA ÁUDIO, VÍDEO E FOTO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915234","MÁQUINAS, UTENSÍLIOS E EQUIPAMENTOS DIVERSOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915235","EQUIPAMENTOS DE PROCESSAMENTO DE DADOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915236","MÁQUINAS, INSTALAÇÕES E UTENSÍLIOS DE ESCRITÓRIO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915239","EQUIPAMENTOS E UTENSÍLIOS HIDRÁULICOS E ELÉTRICOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915242","MOBILIÁRIO EM GERAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915244","OBRAS DE ARTE E PEÇAS PARA EXPOSIÇÃO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915246","SEMOVENTES E EQUIPAMENTOS DE MONTARIA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915248","VEÍCULOS DIVERSOS  - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915251","PEÇAS NÃO INCORPORÁVEIS A IMÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915252","VEÍCULOS DE TRAÇÃO MECÂNICA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915257","ACESSÓRIOS PARA AUTOMÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44915299","OUTROS MATERIAIS PERMANENTES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44919100","SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44919105","SENTENÇAS JUDICIAIS TRANSITADAS EM JULGADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44919160","SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44919161","SENTENÇAS JUDICIAIS - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44919199","OUTRAS SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44919201","OBRAS E INSTALAÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44919202","EQUIPAMENTOS E MATERIAL PERMANENTE - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44919299","OUTRAS DESPESAS DE EXERCÍCIOS ANTERIORES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","44925100","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44925200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44926100","AQUISIÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","44929100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","44935100","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44935200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44936100","AQUISIÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","44945100","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44945200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44946100","AQUISIÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","44955100","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44955200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44956100","AQUISIÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","44959100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","44959200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","44959300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44965100","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","44965200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","44966100","AQUISIÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","44969100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","44969200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","44969300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","45304100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","45304200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","45314100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","45314200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","45326100","AQUISIÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","45326400","AQUISIÇÃO DE TÍTULOS REPRESENTATIVOS DE CAPITAL JÁ INTEGRALIZADO" }  ) 
	aAdd( aDadAux, { "SE","45326500","CONSTITUIÇÃO OU AUMENTO DE CAPITAL DE EMPRESA" }  ) 
	aAdd( aDadAux, { "SE","45326600","CONCESSÃO DE EMPRÉSTIMOS E FINANCIAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","45404100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","45404200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","45426400","AQUISIÇÃO DE TÍTULOS REPRESENTATIVOS DE CAPITAL JÁ INTEGRALIZADO" }  ) 
	aAdd( aDadAux, { "SE","45426600","CONCESSÃO DE EMPRÉSTIMOS E FINANCIAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","45504200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","45506600","CONCESSÃO DE EMPRÉSTIMOS E FINANCIAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","45678200","APORTE DE RECURSOS PELO PARCEIRO PÚBLICO EM FAVOR DO PARCEIRO PRIVADO - PPP" }  ) 
	aAdd( aDadAux, { "SE","45678300","DESPESAS DECORRENTES DE CONTRATO DE PARCERIA PÚBLICO-PRIVADA - PPP, EXCETO SUBVENÇÕES ECONÔMICAS, APORTE E FUNDO GARANTIDOR" }  ) 
	aAdd( aDadAux, { "SE","45704100","CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","45704200","AUXÍLIOS" }  ) 
	aAdd( aDadAux, { "SE","45717000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","45721400","DIÁRIAS - CIVIL" }  ) 
	aAdd( aDadAux, { "SE","45723000","MATERIAL DE CONSUMO" }  ) 
	aAdd( aDadAux, { "SE","45723600","OUTROS SERVIÇOS DE TERCEIROS - PESSOA FÍSICA" }  ) 
	aAdd( aDadAux, { "SE","45723900","OUTROS SERVIÇOS DE TERCEIROS -PESSOA JURÍDICA" }  ) 
	aAdd( aDadAux, { "SE","45725100","OBRAS E INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","45725200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","45729200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","45737000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","45747000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","45806600","CONCESSÃO DE EMPRÉSTIMOS E FINANCIAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","45905202","AERONAVES" }  ) 
	aAdd( aDadAux, { "SE","45905204","APARELHOS DE MEDIÇÃO E ORIENTAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","45905206","APARELHOS E EQUIPAMENTOS DE COMUNICAÇÃO" }  ) 
	aAdd( aDadAux, { "SE","45905208","APARELHOS, EQUIPAMENTOS, UTENSÍLIOS MÉDICO-ODONTOLÓGICO, LABORATORIAL E HOSPITALAR" }  ) 
	aAdd( aDadAux, { "SE","45905210","APARELHOS E EQUIPAMENTOS PARA ESPORTES E DIVERSÕES" }  ) 
	aAdd( aDadAux, { "SE","45905212","APARELHOS E UTENSÍLIOS DOMÉSTICOS" }  ) 
	aAdd( aDadAux, { "SE","45905218","COLEÇÕES E MATERIAIS BIBLIOGRÁFICOS" }  ) 
	aAdd( aDadAux, { "SE","45905219","DISCOTECAS E FILMOTECAS" }  ) 
	aAdd( aDadAux, { "SE","45905220","EMBARCAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","45905224","EQUIPAMENTO DE PROTEÇÃO, SEGURANÇA E SOCORRO" }  ) 
	aAdd( aDadAux, { "SE","45905226","INSTRUMENTOS MUSICAIS E ARTÍSTICOS" }  ) 
	aAdd( aDadAux, { "SE","45905228","MÁQUINAS E EQUIPAMENTOS DE NATUREZA INDUSTRIAL" }  ) 
	aAdd( aDadAux, { "SE","45905230","MÁQUINAS E EQUIPAMENTOS ENERGÉTICOS" }  ) 
	aAdd( aDadAux, { "SE","45905232","MÁQUINAS E EQUIPAMENTOS GRÁFICOS" }  ) 
	aAdd( aDadAux, { "SE","45905233","EQUIPAMENTOS PARA ÁUDIO, VÍDEO E FOTO" }  ) 
	aAdd( aDadAux, { "SE","45905234","MÁQUINAS, UTENSÍLIOS E EQUIPAMENTOS DIVERSOS" }  ) 
	aAdd( aDadAux, { "SE","45905235","EQUIPAMENTOS DE PROCESSAMENTO DE DADOS" }  ) 
	aAdd( aDadAux, { "SE","45905236","MÁQUINAS, INSTALAÇÕES E UTENSÍLIOS DE ESCRITÓRIO" }  ) 
	aAdd( aDadAux, { "SE","45905238","MÁQUINAS, FERRAMENTAS E UTENSÍLIOS DE OFICINA" }  ) 
	aAdd( aDadAux, { "SE","45905239","EQUIPAMENTOS E UTENSÍLIOS HIDRÁULICOS E ELÉTRICOS" }  ) 
	aAdd( aDadAux, { "SE","45905242","MOBILIÁRIO EM GERAL" }  ) 
	aAdd( aDadAux, { "SE","45905244","OBRAS DE ARTE E PEÇAS PARA EXPOSIÇÃO/MUSEU" }  ) 
	aAdd( aDadAux, { "SE","45905246","SEMOVENTES E EQUIPAMENTOS DE MONTARIA" }  ) 
	aAdd( aDadAux, { "SE","45905248","VEÍCULOS DIVERSOS " }  ) 
	aAdd( aDadAux, { "SE","45905251","PEÇAS NÃO INCORPORÁVEIS A IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","45905252","VEÍCULOS DE TRAÇÃO MECÂNICA" }  ) 
	aAdd( aDadAux, { "SE","45905257","ACESSÓRIOS PARA AUTOMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","45905287","MATERIAL DE CONSUMO DE USO DURADOURO" }  ) 
	aAdd( aDadAux, { "SE","45905299","OUTROS MATERIAIS PERMANENTES" }  ) 
	aAdd( aDadAux, { "SE","45906101","EDIFÍCIOS" }  ) 
	aAdd( aDadAux, { "SE","45906103","TERRENOS" }  ) 
	aAdd( aDadAux, { "SE","45906106","SALAS E ESCRITÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","45906191","OBRAS EM ANDAMENTO" }  ) 
	aAdd( aDadAux, { "SE","45906192","INSTALAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","45906199","OUTROS BENS IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","45906200","AQUISIÇÃO DE PRODUTOS PARA REVENDA" }  ) 
	aAdd( aDadAux, { "SE","45906300","AQUISIÇÃO DE TÍTULOS DE CRÉDITO" }  ) 
	aAdd( aDadAux, { "SE","45906400","AQUISIÇÃO TÍTULOS REPRESENTATIVOS DE CAPITAL JÁ INTEGRALIZADO" }  ) 
	aAdd( aDadAux, { "SE","45906501","EMPRESAS PÚBLICAS" }  ) 
	aAdd( aDadAux, { "SE","45906502","EMPRESAS DE ECONOMIA MISTA" }  ) 
	aAdd( aDadAux, { "SE","45906504","COTAS/AÇÕES DE FUNDOS" }  ) 
	aAdd( aDadAux, { "SE","45906599","OUTRAS EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","45906600","CONCESSÃO DE EMPRÉSTIMOS E FINANCIAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","45906700","DEPÓSITOS COMPULSÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","45908201","APORTE DE RECURSOS PARA OBRAS E AQUISIÇÃO DE BENS" }  ) 
	aAdd( aDadAux, { "SE","45908299","OUTROS APORTE DE RECURSOS PELO PARCEIRO PÚBLICO DECORRENTES DE PPP" }  ) 
	aAdd( aDadAux, { "SE","45908301","PARCELAS DAS CONTRAPRESTAÇÕES REF DESPESAS DE INCORPORAÇÃO DE CAPITAL" }  ) 
	aAdd( aDadAux, { "SE","45908399","OUTRAS DESPESAS REALIZADAS COM CONTRATO DE PARCERIA PÚBLICO-PRIVADA - PPP, EXCETO SUBVENÇÕES ECONÔMICAS, APORTE E FUNDO GARANTIDOR" }  ) 
	aAdd( aDadAux, { "SE","45908400","PARTICIPAÇÃO EM FUNDOS, ORGANISMOS OU ENTIDADES ASSEMELHADAS, NACIONAIS E INTERNACIONAIS" }  ) 
	aAdd( aDadAux, { "SE","45909100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","45909105","SENTENÇAS JUDICIAIS TRANSITADAS EM JULGADO" }  ) 
	aAdd( aDadAux, { "SE","45909160","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","45909161","SENTENÇAS JUDICIAIS - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","45909199","OUTRAS SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","45909201","AQUISIÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","45909202","AQUISIÇÃO DE BENS PARA REVENDA" }  ) 
	aAdd( aDadAux, { "SE","45909203","AQUISIÇÃO DE TÍTULOS DE CRÉDITO" }  ) 
	aAdd( aDadAux, { "SE","45909204","AQUISIÇÃO DE TÍTULOS REPRESENTATIVOS DE CAPITAL JÁ INTEGRALIZADO" }  ) 
	aAdd( aDadAux, { "SE","45909205","CONSTITUIÇÃO OU AUMENTO DE CAPITAL DE EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","45909206","CONCESSÃO DE EMPRÉSTIMOS E FINANCIAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","45909208","EMPRÉSTIMOS E FINANCIAMENTOS CONCEDIDOS" }  ) 
	aAdd( aDadAux, { "SE","45909261","AQUISIÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","45909262","AQUISIÇÃO DE PRODUTOS PARA REVENDA" }  ) 
	aAdd( aDadAux, { "SE","45909263","AQUISIÇÃO DE TÍTULOS DE CRÉDITO" }  ) 
	aAdd( aDadAux, { "SE","45909264","AQUISIÇÃO TÍTULOS REPRESENTATIVOS DE CAPITAL JÁ INTEGRALIZADO" }  ) 
	aAdd( aDadAux, { "SE","45909265","CONSTITUIÇÃO OU AUMENTO DE CAPITAL DE EMPRESAS" }  ) 
	aAdd( aDadAux, { "SE","45909266","CONCESSÃO DE EMPRÉSTIMOS E FINANCIAMENTOS" }  ) 
	aAdd( aDadAux, { "SE","45909267","DEPÓSITOS COMPULSÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","45909291","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","45909299","OUTRAS DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","45909300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","45914700","OBRIGAÇÕES TRIBUTÁRIAS E CONTRIBUTIVAS" }  ) 
	aAdd( aDadAux, { "SE","45916100","AQUISIÇÃO DE IMÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916101","EDIFÍCIOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916103","TERRENOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916106","SALAS E ESCRITÓRIOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916191","OBRAS EM ANDAMENTO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916192","INSTALAÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916199","OUTROS BENS IMÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916200","AQUISIÇÃO DE PRODUTOS PARA REVENDA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916300","AQUISIÇÃO DE TÍTULOS DE CRÉDITO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916400","AQUISIÇÃO TÍTULOS REPRESENTATIVOS DE CAPITAL JÁ INTEGRALIZADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916500","CONSTITUIÇÃO OU AUMENTO DE CAPITAL DE EMPRESAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916501","EMPRESAS PÚBLICAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916502","EMPRESAS DE ECONOMIA MISTA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916504","COTAS/AÇÕES DE FUNDOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916599","OUTRAS EMPRESAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916600","CONCESSÃO DE EMPRÉSTIMOS E FINANCIAMENTOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45916700","DEPÓSITOS COMPULSÓRIOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45918400","PARTICIPAÇÃO EM FUNDOS, ORGANISMOS OU ENTIDADES ASSEMELHADAS, NACIONAIS E INTERNACIONAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45919100","SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45919199","OUTRAS SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45919200","DESPESAS DE EXERCÍCIOS ANTERIORES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45919201","AQUISIÇÃO DE IMÓVEIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45919202","AQUISIÇÃO DE BENS PARA REVENDA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45919203","AQUISIÇÃO DE TÍTULOS DE CRÉDITO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45919204","AQUISIÇÃO DE TÍTULOS REPRESENTATIVOS DE CAPITAL JÁ INTEGRALIZADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45919205","CONSTITUIÇÃO OU AUMENTO DE CAPITAL DE EMPRESAS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45919206","CONCESSÃO DE EMPRÉSTIMOS E FINANCIAMENTOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45919208","EMPRÉSTIMOS E FINANCIAMENTOS CONCEDIDOS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45919299","OUTRAS DESPESAS DE EXERCÍCIOS ANTERIORES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45919300","INDENIZAÇÕES E RESTITUIÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","45925200","EQUIPAMENTOS E MATERIAL PERMANENTE" }  ) 
	aAdd( aDadAux, { "SE","45926100","AQUISIÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","45928300","DESPESAS DECORRENTES DE CONTRATO DE PPP, EXCETO SUBVENÇÕES ECONÔMICAS, APORTE E FUNDO GARANTIDOR" }  ) 
	aAdd( aDadAux, { "SE","45956100","AQUISIÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","45956700","DEPÓSITOS COMPULSÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","45959100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","45959200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","45959300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","45966100","AQUISIÇÃO DE IMÓVEIS" }  ) 
	aAdd( aDadAux, { "SE","45966700","DEPÓSITOS COMPULSÓRIOS" }  ) 
	aAdd( aDadAux, { "SE","45969100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","45969200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","45969300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","46717000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","46737000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","46747000","RATEIO PELA PARTICIPAÇÃO EM CONSÓRCIO PÚBLICO" }  ) 
	aAdd( aDadAux, { "SE","46907101","AMORTIZAÇÃO DA DÍVIDA CONTRATUAL" }  ) 
	aAdd( aDadAux, { "SE","46907102","AMORTIZAÇÃO DA DÍVIDA CONTRATADA COM GOVERNOS" }  ) 
	aAdd( aDadAux, { "SE","46907103","AMORTIZAÇÃO DA DÍVIDA CONTRATADA NO EXTERIOR" }  ) 
	aAdd( aDadAux, { "SE","46907112","VARIAÇÃO CAMBIAL DA DÍVIDA CONTRATUAL" }  ) 
	aAdd( aDadAux, { "SE","46907113","ATUALIZAÇÃO MONETÁRIA DA DÍVIDA CONTRATUAL" }  ) 
	aAdd( aDadAux, { "SE","46907199","OUTRAS AMORTIZAÇÕES DA DÍVIDA CONTRATADA" }  ) 
	aAdd( aDadAux, { "SE","46907200","PRINCIPAL DA DÍVIDA MOBILIÁRIA RESGATADO" }  ) 
	aAdd( aDadAux, { "SE","46907201","RESGATE DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","46907202","VARIAÇÃO CAMBIAL DÍVIDA MOBILIÁRIA RESGATADA" }  ) 
	aAdd( aDadAux, { "SE","46907203","ATUALIZAÇÃO MONETÁRIA DA DÍVIDA MOBILIÁRIA RESGATADA" }  ) 
	aAdd( aDadAux, { "SE","46907299","OUTROS PRINCIPAL DA DÍVIDA MOBILIÁRIA RESGATADO" }  ) 
	aAdd( aDadAux, { "SE","46907300","CORREÇÃO MONETÁRIA OU CAMBIAL DA DÍVIDA CONTRATUAL RESGATADA" }  ) 
	aAdd( aDadAux, { "SE","46907400","CORREÇÃO MONETÁRIA OU CAMBIAL DA DÍVIDA MOBILIÁRIA RESGATADA" }  ) 
	aAdd( aDadAux, { "SE","46907500","CORREÇÃO MONETÁRIA DA DÍVIDA DE OPERAÇÕES DE CRÉDITO POR ANTECIPAÇÃO DA RECEITA" }  ) 
	aAdd( aDadAux, { "SE","46907600","PRINCIPAL CORRIGIDO DA DÍVIDA MOBILIÁRIA REFINANCIADO" }  ) 
	aAdd( aDadAux, { "SE","46907601","REFINANCIAMENTO PRINCIPAL DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","46907602","VARIAÇÃO CAMBIAL DÍVIDA MOBILIÁRIA REFINANCIADA" }  ) 
	aAdd( aDadAux, { "SE","46907603","ATUALIZAÇÃO MONETÁRIA DÍVIDA MOBILIÁRIA REFINANCIADA" }  ) 
	aAdd( aDadAux, { "SE","46907699","OUTROS REFINANCIAMENTOS DA DÍVIDA MOBILIÁRIA" }  ) 
	aAdd( aDadAux, { "SE","46907701","AMORTIZAÇÃO DE DÍVIDA CONTRATADA E REFINANCIADA COM INSTITUIÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "SE","46907702","AMORTIZAÇÃO DE DIVIDA CONTRATADA REFINANCIADA COM GOVERNOS" }  ) 
	aAdd( aDadAux, { "SE","46907703","AMORTIZAÇÃO DE DIVIDA CONTRATADA REFINANCIADA NO EXTERIOR" }  ) 
	aAdd( aDadAux, { "SE","46907711","REFINANCIAMENTO DO PRINCIPAL DA DÍVIDA CONTRATUAL" }  ) 
	aAdd( aDadAux, { "SE","46907712","VARIAÇÃO CAMBIAL DA DÍVIDA CONTRATUAL REFINANCIADA" }  ) 
	aAdd( aDadAux, { "SE","46907713","ATUALIZAÇÃO MONETÁRIA DA DÍVIDA CONTRATUAL REFINANCIADA" }  ) 
	aAdd( aDadAux, { "SE","46907799","OUTROS VALORES DÍVIDA CONTRATUAL REFINANCIADA" }  ) 
	aAdd( aDadAux, { "SE","46909100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","46909160","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","46909161","SENTENÇAS JUDICIAIS - ANTERIORES A 05/05/2000" }  ) 
	aAdd( aDadAux, { "SE","46909199","OUTRAS SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","46909200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","46909201","PRINCIPAL DA DIVIDA POR CONTRATO" }  ) 
	aAdd( aDadAux, { "SE","46909202","PRINCIPAL DA DÍVIDA MOBILIARIA" }  ) 
	aAdd( aDadAux, { "SE","46909203","CORREÇÃO MONETÁRIA E CAMBIAL DA DÍVIDA POR CONTRATO" }  ) 
	aAdd( aDadAux, { "SE","46909204","CORREÇÃO MONETÁRIA E CAMBIAL DA DÍVIDA MOBILIARIA" }  ) 
	aAdd( aDadAux, { "SE","46909205","CORREÇÃO MONETÁRIA DE OPERAÇÃO DE CRÉDITO POR ANTECIPAÇÃO DA RECEITA" }  ) 
	aAdd( aDadAux, { "SE","46909299","OUTRAS AMORTIZAÇÕES DE DÍVIDA CONTRATADA E REFINANCIADA" }  ) 
	aAdd( aDadAux, { "SE","46909300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","46909301","INDENIZAÇÕES" }  ) 
	aAdd( aDadAux, { "SE","46909302","RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","46917102","AMORTIZAÇÃO DA DÍVIDA CONTRATUAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46917199","OUTRAS AMORTIZAÇÕES DA DÍVIDA CONTRATUAL - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46917200","PRINCIPAL DA DÍVIDA MOBILIÁRIA RESGATADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46917300","CORREÇÃO MONETÁRIA OU CAMBIAL DA DÍVIDA CONTRATUAL RESGATADA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46917400","CORREÇÃO MONETÁRIA OU CAMBIAL DA DÍVIDA MOBILIÁRIA RESGATADA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46917500","CORREÇÃO MONETÁRIA DA DÍVIDA DE OPERAÇÕES DE CRÉDITO POR ANTECIPAÇÃO DA RECEITA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46917600","PRINCIPAL CORRIGIDO DA DÍVIDA MOBILIÁRIA REFINANCIADO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46917702","AMORTIZAÇÃO DE DÍVIDA CONTRATUAL REFINANCIADA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46917799","OUTRAS AMORTIZAÇÕES DE DÍVIDA CONTRATADA E REFINANCIADA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919100","SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919160","SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919161","SENTENÇAS JUDICIAIS - ANTERIORES A 05/05/2000 - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919199","OUTRAS SENTENÇAS JUDICIAIS - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919200","DESPESAS DE EXERCÍCIOS ANTERIORES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919201","PRINCIPAL DA DIVIDA POR CONTRATO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919202","PRINCIPAL DA DÍVIDA MOBILIARIA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919203","CORREÇÃO MONETÁRIA E CAMBIAL DA DÍVIDA POR CONTRATO - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919204","CORREÇÃO MONETÁRIA E CAMBIAL DA DÍVIDA MOBILIARIA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919205","CORREÇÃO MONETÁRIA DE OPERAÇÃO DE CRÉDITO POR ANTECIPAÇÃO DA RECEITA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919299","OUTRAS AMORTIZAÇÕES DE DÍVIDA CONTRATADA E REFINANCIADA - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919300","INDENIZAÇÕES E RESTITUIÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919301","INDENIZAÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46919302","RESTITUIÇÕES - INTRA OFSS" }  ) 
	aAdd( aDadAux, { "SE","46957100","PRINCIPAL DA DÍVIDA CONTRATUAL RESGATADO" }  ) 
	aAdd( aDadAux, { "SE","46957300","CORREÇÃO MONETÁRIA OU CAMBIAL DA DÍVIDA CONTRATUAL RESGATADA" }  ) 
	aAdd( aDadAux, { "SE","46957700","PRINCIPAL CORRIGIDO DA DÍVIDA CONTRATUAL REFINANCIADO" }  ) 
	aAdd( aDadAux, { "SE","46959100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","46959200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","46959300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	aAdd( aDadAux, { "SE","46967100","PRINCIPAL DA DÍVIDA CONTRATUAL RESGATADO" }  ) 
	aAdd( aDadAux, { "SE","46967300","CORREÇÃO MONETÁRIA OU CAMBIAL DA DÍVIDA CONTRATUAL RESGATADA" }  ) 
	aAdd( aDadAux, { "SE","46967700","PRINCIPAL CORRIGIDO DA DÍVIDA CONTRATUAL REFINANCIADO" }  ) 
	aAdd( aDadAux, { "SE","46969100","SENTENÇAS JUDICIAIS" }  ) 
	aAdd( aDadAux, { "SE","46969200","DESPESAS DE EXERCÍCIOS ANTERIORES" }  ) 
	aAdd( aDadAux, { "SE","46969300","INDENIZAÇÕES E RESTITUIÇÕES" }  ) 
	
	
	aCposDet := {}

	For nX := 1 To Len(aDadAux)
		
		aAux := {}
		aAdd( aAux, { "A1H_ITETAB" , StrZero(nX, 4)} )
		aAdd( aAux, { "A1H_RADCHV", aDadAux[nX,1] } )
		aAdd( aAux, { "A1H_ITECHV", aDadAux[nX,2] } )
		If Len(aDadAux[nX,3]) <= 70
			aAdd( aAux, { "A1H_CHVCNT", aDadAux[nX,3] } )
		Else
			aAdd( aAux, { "A1H_CHVCNT", Subs(aDadAux[nX,3],1,67)+"..." } )
		EndIf
		
		aAdd( aCposDet, aAux )
		
	Next
	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabCA
Rotina auxiliar de Importação - TABELA CA - CODIGO DE APLICACAO

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabCA()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}
Local aDadAux := {}
Local nX := 0

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"CA")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "CA"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "CODIGO DE APLICACAO"} )
	aAdd( aCposCab, { "A1G_CLASSI" , "2" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 34 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 7 } )

	//carrega os dados de acordo a tabela
	aAdd( aDadAux, { "CA","1000000","GERAL TOTAL" }  ) 
	aAdd( aDadAux, { "CA","100XXXX","GERAL - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","1100000","GERAL" }  ) 
	aAdd( aDadAux, { "CA","1110000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","1200000","ALIENAÇÃO DE BENS" }  ) 
	aAdd( aDadAux, { "CA","1210000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","1300000","CIDE-CONTRIBUIÇÃO DE INTERVENÇÃO NO DOMÍNIO ECONÔMICO" }  ) 
	aAdd( aDadAux, { "CA","130XXXX","CIDE-CONTRIBUIÇÃO DE INTERVENÇÃO NO DOMÍNIO ECONÔMICO - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","1310000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","1400000","ROYALTIES DA EXPLORAÇÃO DO PETRÓLEO E GÁS NATURAL" }  ) 
	aAdd( aDadAux, { "CA","1410000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","2000000","EDUCAÇÃO" }  ) 
	aAdd( aDadAux, { "CA","200XXXX","EDUCAÇÃO - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2010000","OPERAÇÕES DE CRÉDITO VINCULADAS À EDUCAÇÃO - CRECHE " }  ) 
	aAdd( aDadAux, { "CA","201XXXX","OPERAÇÕES DE CRÉDITO VINCULADAS À EDUCAÇÃO - CRECHE - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2020000","OPERAÇÕES DE CRÉDITO VINCULADAS À EDUCAÇÃO - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","202XXXX","OPERAÇÕES DE CRÉDITO VINCULADAS À EDUCAÇÃO - PRÉ-ESCOLA - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2030000","OPERAÇÕES DE CRÉDITO VINCULADAS À EDUCAÇÃO - ENSINO FUDAMENTAL" }  ) 
	aAdd( aDadAux, { "CA","203XXXX","OPERAÇÕES DE CRÉDITO VINCULADAS À EDUCAÇÃO - ENSINO FUDAMENTAL - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2040000","ROYALTIES DO PETRÓLEO DESTINADOS À EDUCAÇÃO - CRECHE" }  ) 
	aAdd( aDadAux, { "CA","204XXXX","ROYALTIES DO PETRÓLEO DESTINADOS À EDUCAÇÃO - CRECHE - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2050000","ROYALTIES DO PETRÓLEO DESTINADOS À EDUCAÇÃO - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","205XXXX","ROYALTIES DO PETRÓLEO DESTINADOS À EDUCAÇÃO - PRÉ-ESCOLA - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2060000","ROYALTIES DO PETRÓLEO DESTINADOS À EDUCAÇÃO - ENSINO FUNDAMENTAL" }  ) 
	aAdd( aDadAux, { "CA","206XXXX","ROYALTIES DO PETRÓLEO DESTINADOS À EDUCAÇÃO - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2070000","RECEITA PELA PRESTAÇÃO DE SERVIÇOS EDUCACIONAIS " }  ) 
	aAdd( aDadAux, { "CA","207XXXX","RECEITA PELA PRESTAÇÃO DE SERVIÇOS EDUCACIONAIS - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2100000","EDUCAÇÃO INFANTIL" }  ) 
	aAdd( aDadAux, { "CA","210XXXX","EDUCAÇÃO INFANTI - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2110000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","2120000","EDUCAÇÃO INFANTIL - CRECHE" }  ) 
	aAdd( aDadAux, { "CA","212XXXX","EDUCAÇÃO INFANTIL - CRECHE - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2130000","EDUCAÇÃO INFANTIL - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","213XXXX","EDUCAÇÃO INFANTIL - PRÉ-ESCOLA - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2200000","ENSINO FUNDAMENTAL" }  ) 
	aAdd( aDadAux, { "CA","220XXXX","ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2210000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","2300000","ENSINO MÉDIO" }  ) 
	aAdd( aDadAux, { "CA","230XXXX","ENSINO MÉDIO - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2310000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","2320000","RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - ENSINO MÉDIO" }  ) 
	aAdd( aDadAux, { "CA","232XXXX","RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - ENSINO MÉDIO - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2330000","RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - ENSINO MÉDIO" }  ) 
//	aAdd( aDadAux, { "CA","2330000","RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - ENSINO MÉDIO - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2400000","EDUCAÇÃO ESPECIAL" }  ) 
	aAdd( aDadAux, { "CA","240XXXX","EDUCAÇÃO ESPECIAL - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2410000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","2420000","RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - EDUCAÇÃO ESPECIAL" }  ) 
	aAdd( aDadAux, { "CA","242XXXX","RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - EDUCAÇÃO ESPECIAL - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2430000","RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - EJA" }  ) 
	aAdd( aDadAux, { "CA","243XXXX","RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - EJA - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2500000","EDUCAÇÃO - FUNDEF" }  ) 
	aAdd( aDadAux, { "CA","2510000","EDUCAÇÃO - FUNDEF - MAGISTÉRIO" }  ) 
	aAdd( aDadAux, { "CA","2520000","EDUCAÇÃO - FUNDEF - OUTROS" }  ) 
	aAdd( aDadAux, { "CA","2530000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","2600000","EDUCAÇÃO - FUNDEB" }  ) 
	aAdd( aDadAux, { "CA","260XXXX","EDUCAÇÃO - FUNDEB - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2610000","EDUCAÇÃO - FUNDEB - MAGISTÉRIO" }  ) 
	aAdd( aDadAux, { "CA","2620000","EDUCAÇÃO - FUNDEB - OUTROS" }  ) 
	aAdd( aDadAux, { "CA","2630000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","264AAAA","EDUCAÇÃO - FUNDEB - MAGISTÉRIO - Ano Anterior" }  ) 
	aAdd( aDadAux, { "CA","265AAAA","EDUCAÇÃO - FUNDEB - OUTROS - Ano Anterior " }  ) 
	aAdd( aDadAux, { "CA","266AAAA","EDUCAÇÃO - FUNDEB - MAGISTÉRIO - Ano Anterior - CRECHE" }  ) 
	aAdd( aDadAux, { "CA","267AAAA","EDUCAÇÃO - FUNDEB - MAGISTÉRIO - Ano Anterior - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","268AAAA","EDUCAÇÃO - FUNDEB-OUTROS - Ano Anterior - CRECHE" }  ) 
	aAdd( aDadAux, { "CA","269AAAA","EDUCAÇÃO - FUNDEB - OUTROS - Ano Anterior - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","2710000","EDUCAÇÃO - FUNDEB - MAGISTÉRIO - CRECHE" }  ) 
	aAdd( aDadAux, { "CA","2720000","EDUCAÇÃO - FUNDEB - MAGISTÉRIO - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","2730000","EDUCAÇÃO - FUNDEB - OUTROS - CRECHE" }  ) 
	aAdd( aDadAux, { "CA","2740000","EDUCAÇÃO - FUNDEB - OUTROS - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","2750000","RECURSOS COMPLEMENTAÇÃO DO FUNDEB - MAGISTÉRIO - CRECHE" }  ) 
	aAdd( aDadAux, { "CA","2760000","RECURSOS COMPLEMENTAÇÃO DO FUNDEB - MAGISTÉRIO - PRÉ - ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","2770000","RECURSOS COMPLEMENTAÇÃO DO FUNDEB - MAGISTÉRIO - ENSINO FUDAMENTAL" }  ) 
	aAdd( aDadAux, { "CA","2800000","RECURSOS DO SALÁRIO EDUCAÇÃO - CRECHE" }  ) 
	aAdd( aDadAux, { "CA","280XXXX","RECURSOS DO SALÁRIO EDUCAÇÃO - CRECHE - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2810000","RECURSOS DO SALÁRIO EDUCAÇÃO - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","281XXXX","RECURSOS DO SALÁRIO EDUCAÇÃO - PRÉ-ESCOLA - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2820000","RECURSOS DO SALÁRIO EDUCAÇÃO - ENSINO FUNDAMENTAL" }  ) 
	aAdd( aDadAux, { "CA","282XXXX","RECURSOS DO SALÁRIO EDUCAÇÃO - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2830000","RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - CRECHE" }  ) 
	aAdd( aDadAux, { "CA","283XXXX","RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - CRECHE - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2840000","RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","284XXXX","RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - PRÉ-ESCOLA - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2850000","RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - ENSINO FUNDAMENTAL" }  ) 
	aAdd( aDadAux, { "CA","285XXXX","RECURSOS DO PROGRAMA NACIONAL DE ALIMENTAÇÃO ESCOLAR - PNAE - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2860000","RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - CRECHE" }  ) 
	aAdd( aDadAux, { "CA","286XXXX","RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - CRECHE - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2870000","RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","287XXXX","RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - PRÉ-ESCOLA - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2880000","RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - ENSINO FUNDAMENTAL" }  ) 
	aAdd( aDadAux, { "CA","288XXXX","RECURSOS DO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE ESCOLAR - PNATE - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2910000","RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - CRECHE" }  ) 
	aAdd( aDadAux, { "CA","291XXXX","RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - CRECHE - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2920000","RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","292XXXX","RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - PRÉ-ESCOLA - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2930000","RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - ENSINO FUNDAMENTAL" }  ) 
	aAdd( aDadAux, { "CA","293XXXX","RECURSOS DO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2940000","OUTRAS TRANSFERÊNCIAS DE RECURSOS DO FNDE - CRECHE" }  ) 
	aAdd( aDadAux, { "CA","294XXXX","OUTRAS TRANSFERÊNCIAS DE RECURSOS DO FNDE - CRECHE - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2950000","OUTRAS TRANSFERÊNCIAS DE RECURSOS DO FNDE - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","295XXXX","OUTRAS TRANSFERÊNCIAS DE RECURSOS DO FNDE - PRÉ-ESCOLA - Convênios/Entidades/Fundos " }  ) 
	aAdd( aDadAux, { "CA","2960000","OUTRAS TRANSFERÊNCIAS DE RECURSOS DO FNDE - ENSINO FUNDAMENTAL" }  ) 
	aAdd( aDadAux, { "CA","296XXXX","OUTRAS TRANSFERÊNCIAS DE RECURSOS DO FNDE - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos " }  ) 
	aAdd( aDadAux, { "CA","2970000","OUTROS RECURSOS DESTINADOS À EDUCAÇÃO - CRECHE " }  ) 
	aAdd( aDadAux, { "CA","297XXXX","OUTROS RECURSOS DESTINADOS À EDUCAÇÃO - CRECHE - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2980000","OUTROS RECURSOS DESTINADOS À EDUCAÇÃO - PRÉ-ESCOLA" }  ) 
	aAdd( aDadAux, { "CA","298XXXX","OUTROS RECURSOS DESTINADOS À EDUCAÇÃO - PRÉ-ESCOLA - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","2990000","OUTROS RECURSOS DESTINADOS À EDUCAÇÃO - ENSINO FUNDAMENTAL" }  ) 
	aAdd( aDadAux, { "CA","299XXXX","OUTROS RECURSOS DESTINADOS À EDUCAÇÃO  - ENSINO FUNDAMENTAL - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","3000000","SAÚDE" }  ) 
	aAdd( aDadAux, { "CA","300XXXX","SAÚDE - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","3010000","ATENÇÃO BÁSICA" }  ) 
	aAdd( aDadAux, { "CA","301XXXX","ATENÇÃO BÁSICA - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","3020000","ATENÇÃO DE MÉDIA E ALTA COMPLEXIDADE AMBULATORIAL E HOSPITALAR" }  ) 
	aAdd( aDadAux, { "CA","302XXXX","ATENÇÃO DE MÉDIA E ALTA COMPLEXIDADE AMBULATORIAL E HOSPITALAR - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","3030000","VIGILÂNCIA EM SAÚDE" }  ) 
	aAdd( aDadAux, { "CA","303XXXX","VIGILÂNCIA EM SAÚDE - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","3040000","ASSISTÊNCIA FARMACÊUTICA" }  ) 
	aAdd( aDadAux, { "CA","304XXXX","ASSISTÊNCIA FARMACÊUTICA - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","3050000","GESTÃO DO SUS" }  ) 
	aAdd( aDadAux, { "CA","305XXXX","GESTAO DO SUS - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","3070000","OUTROS PROGRAMAS FINANCIADOS POR TRANSFERÊNCIAS FUNDO A FUNDO" }  ) 
	aAdd( aDadAux, { "CA","307XXXX","OUTROS PROGRAMAS FINANCIADOS POR TRANSFERÊNCIAS FUNDO A FUNDO - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","3080000","CONVÊNIOS SUS" }  ) 
	aAdd( aDadAux, { "CA","308XXXX","CONVÊNIOS SUS - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","3090000","SERVIÇOS DE SAÚDE" }  ) 
	aAdd( aDadAux, { "CA","309XXXX","SERVIÇOS DE SAÚDE - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","3100000","SAÚDE–GERAL" }  ) 
	aAdd( aDadAux, { "CA","3110000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","3200000","SAÚDE - TAXAS" }  ) 
	aAdd( aDadAux, { "CA","3300000","SAÚDE - SERVIÇOS" }  ) 
	aAdd( aDadAux, { "CA","3400000","SAÚDE - OUTROS" }  ) 
	aAdd( aDadAux, { "CA","3500000","BLOCO DE CUSTEIO DAS AÇÕES E SERVIÇOS PÚBLICOS DE SAÚDE" }  ) 
	aAdd( aDadAux, { "CA","3510000","BLOCO DE CUSTEIO DAS AÇÕES E SERVIÇOS PÚBLICOS DE SAÚDE - Remuneração de Aplicação Financeira" }  ) 
	aAdd( aDadAux, { "CA","3600000","BLOCO DE INVESTIMENTOS NA REDE DE SERVIÇOS DE SAÚDE" }  ) 
	aAdd( aDadAux, { "CA","3610000","BLOCO DE INVESTIMENTOS NA REDE DE SERVIÇOS DE SAÚDE - Remuneração de Aplicação Financeira" }  ) 
	aAdd( aDadAux, { "CA","4000000","TRÂNSITO" }  ) 
	aAdd( aDadAux, { "CA","400XXXX","TRÂNSITO - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","4100000","TRÂNSITO - SINALIZAÇÃO" }  ) 
	aAdd( aDadAux, { "CA","4110000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","4200000","TRÂNSITO - ENGENHARIA DE TRÂNSITO" }  ) 
	aAdd( aDadAux, { "CA","4300000","TRÂNSITO - ENGENHARIA DE CAMPO" }  ) 
	aAdd( aDadAux, { "CA","4400000","TRÂNSITO - POLICIAMENTO" }  ) 
	aAdd( aDadAux, { "CA","4500000","TRÂNSITO - FISCALIZAÇÃO" }  ) 
	aAdd( aDadAux, { "CA","4600000","TRÂNSITO - EDUCAÇÃO DE TRÂNSITO" }  ) 
	aAdd( aDadAux, { "CA","4700000","TRÂNSITO - FUNSET" }  ) 
	aAdd( aDadAux, { "CA","5000000","ASSISTÊNCIA SOCIAL" }  ) 
	aAdd( aDadAux, { "CA","500XXXX","ASSISTÊNCIA SOCIAL - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","5100000","ASSISTÊNCIA SOCIAL - GERAL" }  ) 
	aAdd( aDadAux, { "CA","5110000","REMUNERAÇÃO DE APLICAÇÕES FINANCEIRAS" }  ) 
	aAdd( aDadAux, { "CA","6000000","REGIME PRÓPRIO DE PREVIDÊNCIA SOCIAL" }  ) 
	aAdd( aDadAux, { "CA","600XXXX","RPPS - Convênios/Entidades/Fundos" }  ) 
	aAdd( aDadAux, { "CA","6010000","REGIME PRÓPRIO DE PREVIDÊNCIA SOCIAL - PLANO FINANCEIRO" }  ) 
	aAdd( aDadAux, { "CA","6020000","REGIME PRÓPRIO DE PREVIDÊNCIA SOCIAL - PLANO PREVIDENCIÁRIO" }  ) 
	aAdd( aDadAux, { "CA","6100000","RPPS - CONTRIBUIÇÕES" }  ) 
	aAdd( aDadAux, { "CA","6110000","RPPS - CONTRIBUIÇÃO PATRONAL" }  ) 
	aAdd( aDadAux, { "CA","6120000","RPPS - CONTRIBUIÇÃO SEGURADOS" }  ) 
	aAdd( aDadAux, { "CA","6130000","RPPS - CONTRIBUIÇÕES - PLANO FINANCEIRO" }  ) 
	aAdd( aDadAux, { "CA","6140000","RPPS - CONTRIBUIÇÕES - PLANO PREVIDENCIÁRIO" }  ) 
	aAdd( aDadAux, { "CA","6150000","RPPS - CONTRIBUIÇÃO PATRONAL - PLANO FINANCEIRO" }  ) 
	aAdd( aDadAux, { "CA","6160000","RPPS - CONTRIBUIÇÃO PATRONAL - PLANO PREVIDENCIÁRIO" }  ) 
	aAdd( aDadAux, { "CA","6170000","RPPS - CONTRIBUIÇÃO SEGURADOS - PLANO FINANCEIRO" }  ) 
	aAdd( aDadAux, { "CA","6180000","RPPS - CONTRIBUIÇÃO SEGURADOS - PLANO PREVIDENCIÁRIO" }  ) 
	aAdd( aDadAux, { "CA","6200000","RPPS - COMPENSAÇÃO PREVIDENCIÁRIA" }  ) 
	aAdd( aDadAux, { "CA","6210000","RPPS - COMPENSAÇÃO PREVIDENCIÁRIA - PLANO FINANCEIRO" }  ) 
	aAdd( aDadAux, { "CA","6220000","RPPS - COMPENSAÇÃO PREVIDENCIÁRIA - PLANO PREVIDENCIÁRIO" }  ) 
	aAdd( aDadAux, { "CA","7000000","DESVINCULAÇÃO DE RECEITAS MUNICIPAIS - DRM" }  ) 

	aCposDet := {}

	For nX := 1 To Len(aDadAux)
		
		aAux := {}
		aAdd( aAux, { "A1H_ITETAB" , StrZero(nX, 4)} )
		aAdd( aAux, { "A1H_RADCHV", aDadAux[nX,1] } )
		aAdd( aAux, { "A1H_ITECHV", aDadAux[nX,2] } )
		If Len(aDadAux[nX,3]) <= 70
			aAdd( aAux, { "A1H_CHVCNT", aDadAux[nX,3] } )
		Else
			aAdd( aAux, { "A1H_CHVCNT", Subs(aDadAux[nX,3],1,67)+"..." } )		
		EndIf
		
		aAdd( aCposDet, aAux )
		
	Next
	
	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Imp_TabUM
Rotina auxiliar de Importação - CATEGORIA ECONOMICA

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function Imp_TabUM()
Local lRet := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAux := {}

dbSelectArea("A1G")
dbSetOrder(1)
//somente incluir se nao encontrado a tabela
If ! dbSeek(xFilial("A1G")+"UM")

	// Criamos um vetor com os dados de cabeçalho e outro para itens para facilitar o manuseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB" , "UM"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "UNIDADE MEDIDA PRODUTOS PPA" } )
	aAdd( aCposCab, { "A1G_CLASSI" , "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO" , 0 } )
	aAdd( aCposCab, { "A1G_DIGCPO" , 0 } )

	aCposDet := {}
	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0001" } )
	aAdd( aAux, { "A1H_RADCHV", "UM" } )
	aAdd( aAux, { "A1H_ITECHV", "UN" } )
	aAdd( aAux, { "A1H_CHVCNT", "UNIDADE" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0002" } )
	aAdd( aAux, { "A1H_RADCHV", "UM" } )
	aAdd( aAux, { "A1H_ITECHV", "%" } )
	aAdd( aAux, { "A1H_CHVCNT", "PERCENTUAL" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0003" } )
	aAdd( aAux, { "A1H_RADCHV", "UM" } )
	aAdd( aAux, { "A1H_ITECHV", "KM" } )
	aAdd( aAux, { "A1H_CHVCNT", "KILOMETRO" } )
	aAdd( aCposDet, aAux )

	aAux := {}
	aAdd( aAux, { "A1H_ITETAB" , "0004" } )
	aAdd( aAux, { "A1H_RADCHV", "UM" } )
	aAdd( aAux, { "A1H_ITECHV", "M2" } )
	aAdd( aAux, { "A1H_CHVCNT", "METRO QUADRADO" } )
	aAdd( aCposDet, aAux )

	If !Tbl_Imp('A1G', 'A1H', aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{ProtheUs.doc} Imp_TabDR
Rotina aUxiliar de ImportaCão - TABELA DR - DESDOBRAMENTO IDENT. DAS
PECULIARIDADES DA RECEITA 

@aUthor TOTVS
@since 23/09/2020
@version P12
/*/
//-------------------------------------------------------------------
Static FUnction Imp_TabDR()

Local lRet     := .T.
Local aCposCab := {}
Local aCposDet := {}
Local aAUx     := {}
Local aDadAUx  := {}
Local nX       := 0

A1G->(dbSetOrder(1))

//somente inclUir se nao encontrado a tabela
If ! A1G->(dbSeek(xFilial("A1G")+"DR"))
	// Criamos Um vetor com os dados de cabeCAlho e oUtro para itens para facilitar o manUseio dos dados
	aCposCab := {}
	aAdd( aCposCab, { "A1G_CODTAB", "DR"  } )
	aAdd( aCposCab, { "A1G_DESTAB", "DESDOBRAMENTO IDENT. DAS PECULIARIDADES DA RECEITA"} )
	aAdd( aCposCab, { "A1G_CLASSI", "1" } )
	aAdd( aCposCab, { "A1G_CAMPO" , "AKD_CO" } )
	aAdd( aCposCab, { "A1G_INICPO", 4 } )
	aAdd( aCposCab, { "A1G_DIGCPO", 4 } )

	//carrega os dados de acordo a tabela
	aAdd( aDadAUx, { "DR", "11120000", "IMPOSTOS SOBRE O PATRIMONIO" } )
	aAdd( aDadAUx, { "DR", "11120100", "IMPOSTO SOBRE A PROPRIEDADE TERRITORIAL RURAL" } )
	aAdd( aDadAUx, { "DR", "11120110", "IMPOSTO SOBRE A PROPRIEDADE TERRITORIAL RURAL - MUNICIPIOS CONVENIADOS" } )
	aAdd( aDadAUx, { "DR", "11130000", "IMPOSTOS SOBRE A RENDA E PROVENTOS DE QUALQUER NATUREZA" } )
	aAdd( aDadAUx, { "DR", "11130300", "IMPOSTO SOBRE A RENDA - RETIDO NA FONTE" } )
	aAdd( aDadAUx, { "DR", "11130310", "IMPOSTO SOBRE A RENDA - RETIDO NA FONTE - TRABALHO" } )
	aAdd( aDadAUx, { "DR", "11130320", "IMPOSTO SOBRE A RENDA - RETIDO NA FONTE - CAPITAL" } )
	aAdd( aDadAUx, { "DR", "11130340", "IMPOSTO SOBRE A RENDA - RETIDO NA FONTE - OUTROS RENDIMENTOS" } )
	aAdd( aDadAUx, { "DR", "11180000", "IMPOSTOS ESPECIFICOS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "11180100", "IMPOSTOS SOBRE O PATRIMONIO PARA ESTADOS, DF E MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "11180110", "IMPOSTO SOBRE A PROPRIEDADE PREDIAL E TERRITORIAL URBANA" } )
	aAdd( aDadAUx, { "DR", "11180140", "IMPOSTO SOBRE TRANSMISSAO (INTER VIVOS) DE BENS IMOVEIS E DE DIREITOS REAIS SOBRE IMOVEIS" } )
	aAdd( aDadAUx, { "DR", "11180200", "IMPOSTOS SOBRE A PRODUCAO, CIRCULACAO DE MERCADORIAS E SERVICOS" } )
	aAdd( aDadAUx, { "DR", "11180230", "IMPOSTO SOBRE SERVICOS DE QUALQUER NATUREZA" } )
	aAdd( aDadAUx, { "DR", "11180240", "ADICIONAL ISS - FUNDO MUNICIPAL DE COMBATE A POBREZA" } )
	aAdd( aDadAUx, { "DR", "11180250", "IMPOSTO SOBRE VENDAS A VAREJO DE COMBUSTIVEIS LIQUIDOS E GASOSOS (IVVC)" } )
	aAdd( aDadAUx, { "DR", "11190000", "OUTROS IMPOSTOS" } )
	aAdd( aDadAUx, { "DR", "11190100", "OUTROS IMPOSTOS" } )
	aAdd( aDadAUx, { "DR", "11190110", "OUTROS IMPOSTOS" } )
	aAdd( aDadAUx, { "DR", "11280000", "TAXAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "11280100", "TAXAS DE INSPECAO, CONTROLE E FISCALIZACAO" } )
	aAdd( aDadAUx, { "DR", "11280110", "TAXA DE FISCALIZACAO DE VIGILANCIA SANITARIA" } )
	aAdd( aDadAUx, { "DR", "11280190", "TAXAS DE INSPECAO, CONTROLE E FISCALIZACAO - OUTRAS" } )
	aAdd( aDadAUx, { "DR", "11280200", "TAXAS PELA PRESTACAO DE SERVICOS" } )
	aAdd( aDadAUx, { "DR", "11280230", "TAXA DE ESTUDO DE IMPACTO DE VIZINHANCA (EIV)" } )
	aAdd( aDadAUx, { "DR", "11280290", "TAXAS PELA PRESTACAO DE SERVICOS - OUTRAS" } )
	aAdd( aDadAUx, { "DR", "11380000", "CONTRIBUICAO DE MELHORIA - ESPECIFICA DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "11380100", "CONTRIBUICAO DE MELHORIA PARA EXPANSAO DA REDE DE AGUA POTAVEL E ESGOTO SANITARIO" } )
	aAdd( aDadAUx, { "DR", "11380110", "CONTRIBUICAO DE MELHORIA PARA EXPANSAO DA REDE DE AGUA POTAVEL E ESGOTO SANITARIO" } )
	aAdd( aDadAUx, { "DR", "11380200", "CONTRIBUICAO DE MELHORIA PARA EXPANSAO DA REDE DE ILUMINACAO PUBLICA NA CIDADE" } )
	aAdd( aDadAUx, { "DR", "11380210", "CONTRIBUICAO DE MELHORIA PARA EXPANSAO DA REDE DE ILUMINACAO PUBLICA NA CIDADE" } )
	aAdd( aDadAUx, { "DR", "11380300", "CONTRIBUICAO DE MELHORIA PARA EXPANSAO DE REDE DE ILUMINACAO PUBLICA RURAL" } )
	aAdd( aDadAUx, { "DR", "11380310", "CONTRIBUICAO DE MELHORIA PARA EXPANSAO DE REDE DE ILUMINACAO PUBLICA RURAL" } )
	aAdd( aDadAUx, { "DR", "11380400", "CONTRIBUICAO DE MELHORIA PARA PAVIMENTACAO E OBRAS COMPLEMENTARES" } )
	aAdd( aDadAUx, { "DR", "11380410", "CONTRIBUICAO DE MELHORIA PARA PAVIMENTACAO E OBRAS COMPLEMENTARES" } )
	aAdd( aDadAUx, { "DR", "11389900", "OUTRAS CONTRIBUICOES DE MELHORIA" } )
	aAdd( aDadAUx, { "DR", "11389910", "OUTRAS CONTRIBUICOES DE MELHORIA" } )
	aAdd( aDadAUx, { "DR", "12160000", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA" } )
	aAdd( aDadAUx, { "DR", "12160300", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - SERVIDORES CIVIS" } )
	aAdd( aDadAUx, { "DR", "12160310", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - SERVIDORES CIVIS" } )
	aAdd( aDadAUx, { "DR", "12160320", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - SERVIDORES CIVIS - PARCELAMENTOS" } )
	aAdd( aDadAUx, { "DR", "12160400", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - OUTROS BENEFICIARIOS" } )
	aAdd( aDadAUx, { "DR", "12160410", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - OUTROS BENEFICIARIOS" } )
	aAdd( aDadAUx, { "DR", "12160420", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - OUTROS BENEFICIARIOS - PARCELAMENTOS" } )
	aAdd( aDadAUx, { "DR", "12180000", "CONTRIBUICOES SOCIAIS ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "12180100", "CONTRIBUICAO DO SERVIDOR CIVIL PARA O PLANO DE SEGURIDADE SOCIAL - CPSSS - ESPECIFICA DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "12180110", "CPSSS DO SERVIDOR CIVIL ATIVO" } )
	aAdd( aDadAUx, { "DR", "12180120", "CPSSS DO SERVIDOR CIVIL INATIVO" } )
	aAdd( aDadAUx, { "DR", "12180130", "CPSSS DO SERVIDOR CIVIL - PENSIONISTAS" } )
	aAdd( aDadAUx, { "DR", "12180140", "CPSSS ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL ATIVO" } )
	aAdd( aDadAUx, { "DR", "12180150", "CPSSS ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL INATIVO" } )
	aAdd( aDadAUx, { "DR", "12180160", "CPSSS ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL - PENSIONISTAS" } )
	aAdd( aDadAUx, { "DR", "12180200", "CPSSS - PARCELAMENTOS - ESPECIFICO DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "12180210", "CPSSS - PARCELAMENTOS - DO SERVIDOR CIVIL ATIVO" } )
	aAdd( aDadAUx, { "DR", "12180220", "CPSSS - PARCELAMENTOS - DO SERVIDOR CIVIL INATIVO" } )
	aAdd( aDadAUx, { "DR", "12180230", "CPSSS - PARCELAMENTOS - PENSIONISTAS" } )
	aAdd( aDadAUx, { "DR", "12180240", "CPSSS - PARCELAMENTOS - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL ATIVO" } )
	aAdd( aDadAUx, { "DR", "12180250", "CPSSS - PARCELAMENTOS - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL INATIVO" } )
	aAdd( aDadAUx, { "DR", "12180260", "CPSSS - PARCELAMENTOS - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL - PENSIONISTAS" } )
	aAdd( aDadAUx, { "DR", "12180300", "CPSSS PATRONAL - SERVIDOR CIVIL - ESPECIFICA DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "12180310", "CPSSS PATRONAL - SERVIDOR CIVIL ATIVO" } )
	aAdd( aDadAUx, { "DR", "12180320", "CPSSS PATRONAL - SERVIDOR CIVIL INATIVO" } )
	aAdd( aDadAUx, { "DR", "12180330", "CPSSS PATRONAL - SERVIDOR CIVIL - PENSIONISTAS" } )
	aAdd( aDadAUx, { "DR", "12180340", "CPSSS PATRONAL - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL ATIVO" } )
	aAdd( aDadAUx, { "DR", "12180350", "CPSSS PATRONAL - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL INATIVO" } )
	aAdd( aDadAUx, { "DR", "12180360", "CPSSS PATRONAL - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL - PENSIONISTAS" } )
	aAdd( aDadAUx, { "DR", "12180400", "CPSSS PATRONAL - PARCELAMENTOS - ESPECIFICA DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "12180410", "CPSSS PATRONAL - PARCELAMENTOS - SERVIDOR CIVIL ATIVO" } )
	aAdd( aDadAUx, { "DR", "12180420", "CPSSS PATRONAL - PARCELAMENTOS - SERVIDOR CIVIL INATIVO" } )
	aAdd( aDadAUx, { "DR", "12180430", "CPSSS PATRONAL - PARCELAMENTOS - SERVIDOR CIVIL - PENSIONISTAS" } )
	aAdd( aDadAUx, { "DR", "12180440", "CPSSS PATRONAL - PARCELAMENTOS - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL ATIVO" } )
	aAdd( aDadAUx, { "DR", "12180450", "CPSSS PATRONAL - PARCELAMENTOS - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL INATIVO" } )
	aAdd( aDadAUx, { "DR", "12180460", "CPSSS PATRONAL - PARCELAMENTOS - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL - PENSIONISTAS" } )
	aAdd( aDadAUx, { "DR", "12190000", "OUTRAS CONTRIBUICOES SOCIAIS" } )
	aAdd( aDadAUx, { "DR", "12199900", "DEMAIS CONTRIBUICOES SOCIAIS" } )
	aAdd( aDadAUx, { "DR", "12199910", "DEMAIS CONTRIBUICOES SOCIAIS" } )
	aAdd( aDadAUx, { "DR", "12199920", "DEMAIS CONTRIBUICOES SOCIAIS - PARCELAMENTOS" } )
	aAdd( aDadAUx, { "DR", "12209900", "OUTRAS CONTRIBUICOES ECONOMICAS" } )
	aAdd( aDadAUx, { "DR", "12209910", "OUTRAS CONTRIBUICOES ECONOMICAS" } )
	aAdd( aDadAUx, { "DR", "12400010", "CONTRIBUICAO PARA O CUSTEIO DO SERVICO DE ILUMINACAO PUBLICA" } )
	aAdd( aDadAUx, { "DR", "13100100", "ALUGUEIS, ARRENDAMENTOS, FOROS, LAUDEMIOS, TARIFAS DE OCUPACAO" } )
	aAdd( aDadAUx, { "DR", "13100110", "ALUGUEIS E ARRENDAMENTOS" } )
	aAdd( aDadAUx, { "DR", "13100120", "FOROS, LAUDEMIOS E TARIFAS DE OCUPACAO" } )
	aAdd( aDadAUx, { "DR", "13100200", "CONCESSAO, PERMISSAO, AUTORIZACAO OU CESSAO DO DIREITO DE USO DE BENS IMOVEIS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "13100210", "CONCESSAO, PERMISSAO, AUTORIZACAO OU CESSAO DO DIREITO DE USO DE BENS IMOVEIS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "13109900", "OUTRAS RECEITAS IMOBILIARIAS" } )
	aAdd( aDadAUx, { "DR", "13109910", "OUTRAS RECEITAS IMOBILIARIAS" } )
	aAdd( aDadAUx, { "DR", "13210000", "JUROS E CORRECOES MONETARIAS" } )
	aAdd( aDadAUx, { "DR", "13210010", "REMUNERACAO DE DEPOSITOS BANCARIOS" } )
	aAdd( aDadAUx, { "DR", "13210020", "REMUNERACAO DE DEPOSITOS ESPECIAIS" } )
	aAdd( aDadAUx, { "DR", "13210030", "REMUNERACAO DE SALDOS DE RECURSOS NAO-DESEMBOLSADOS" } )
	aAdd( aDadAUx, { "DR", "13210040", "REMUNERACAO DOS RECURSOS DO REGIME PROPRIO DE PREVIDENCIA SOCIAL - RPPS" } )
	aAdd( aDadAUx, { "DR", "13210050", "JUROS DE TITULOS DE RENDA" } )
	aAdd( aDadAUx, { "DR", "13220000", "DIVIDENDOS" } )
	aAdd( aDadAUx, { "DR", "13220010", "DIVIDENDOS" } )
	aAdd( aDadAUx, { "DR", "13230000", "PARTICIPACOES" } )
	aAdd( aDadAUx, { "DR", "13230010", "PARTICIPACOES" } )
	aAdd( aDadAUx, { "DR", "13290000", "OUTROS VALORES MOBILIARIOS" } )
	aAdd( aDadAUx, { "DR", "13290010", "OUTROS VALORES MOBILIARIOS" } )
	aAdd( aDadAUx, { "DR", "13390000", "DEMAIS DELEGACOES DE SERVICOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "13399900", "OUTRAS DELEGACOES DE SERVICOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "13399910", "OUTRAS DELEGACOES DE SERVICOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "13490000", "EXPLORACAO DE OUTROS RECURSOS NATURAIS" } )
	aAdd( aDadAUx, { "DR", "13499900", "OUTRAS DELEGACOES PARA EXPLORACAO DE RECURSOS NATURAIS" } )
	aAdd( aDadAUx, { "DR", "13499910", "OUTRAS DELEGACOES PARA EXPLORACAO DE RECURSOS NATURAIS" } )
	aAdd( aDadAUx, { "DR", "13500100", "OUTORGA DE DIREITO DE USO OU DE EXPLORACAO DE CRIACAO PROTEGIDA - INSTITUICAO CIENTIFICA E TECNOLOGICA" } )
	aAdd( aDadAUx, { "DR", "13500110", "OUTORGA DE DIREITO DE USO OU DE EXPLORACAO DE CRIACAO PROTEGIDA - INSTITUICAO CIENTIFICA E TECNOLOGICA" } )
	aAdd( aDadAUx, { "DR", "13500200", "DIREITO DE USO DA IMAGEM E DE REPRODUCAO DOS BENS DO ACERVO PATRIMONIAL" } )
	aAdd( aDadAUx, { "DR", "13500210", "DIREITO DE USO DA IMAGEM E DE REPRODUCAO DOS BENS DO ACERVO PATRIMONIAL" } )
	aAdd( aDadAUx, { "DR", "13500400", "ROYALTIES PELA COMERCIALIZACAO DE PRODUTOS RESULTANTES DE CRIACAO PROTEGIDA" } )
	aAdd( aDadAUx, { "DR", "13500410", "ROYALTIES PELA COMERCIALIZACAO DE PRODUTOS RESULTANTES DE CRIACAO PROTEGIDA" } )
	aAdd( aDadAUx, { "DR", "13600100", "CESSAO DO DIREITO DE OPERACIONALIZACAO DE PAGAMENTOS" } )
	aAdd( aDadAUx, { "DR", "13600110", "CESSAO DO DIREITO DE OPERACIONALIZACAO DE PAGAMENTOS" } )
	aAdd( aDadAUx, { "DR", "13900010", "DEMAIS RECEITAS PATRIMONIAIS" } )
	aAdd( aDadAUx, { "DR", "14000010", "RECEITA AGROPECUARIA" } )
	aAdd( aDadAUx, { "DR", "15000010", "RECEITA INDUSTRIAL" } )
	aAdd( aDadAUx, { "DR", "16100100", "SERVICOS ADMINISTRATIVOS E COMERCIAIS GERAIS" } )
	aAdd( aDadAUx, { "DR", "16100110", "SERVICOS ADMINISTRATIVOS E COMERCIAIS GERAIS" } )
	aAdd( aDadAUx, { "DR", "16100200", "INSCRICAO EM CONCURSOS E PROCESSOS SELETIVOS" } )
	aAdd( aDadAUx, { "DR", "16100210", "INSCRICAO EM CONCURSOS E PROCESSOS SELETIVOS" } )
	aAdd( aDadAUx, { "DR", "16100300", "SERVICOS DE REGISTRO, CERTIFICACAO E FISCALIZACAO" } )
	aAdd( aDadAUx, { "DR", "16100310", "SERVICOS DE REGISTRO, CERTIFICACAO E FISCALIZACAO" } )
	aAdd( aDadAUx, { "DR", "16100400", "SERVICOS DE INFORMACAO E TECNOLOGIA" } )
	aAdd( aDadAUx, { "DR", "16100410", "SERVICOS DE INFORMACAO E TECNOLOGIA" } )
	aAdd( aDadAUx, { "DR", "16200100", "SERVICOS DE NAVEGACAO" } )
	aAdd( aDadAUx, { "DR", "16200110", "SERVICOS DE NAVEGACAO" } )
	aAdd( aDadAUx, { "DR", "16200200", "SERVICOS DE TRANSPORTE" } )
	aAdd( aDadAUx, { "DR", "16200210", "SERVICOS DE TRANSPORTE" } )
	aAdd( aDadAUx, { "DR", "16200300", "SERVICOS PORTUARIOS" } )
	aAdd( aDadAUx, { "DR", "16200310", "SERVICOS PORTUARIOS" } )
	aAdd( aDadAUx, { "DR", "16200400", "SERVICOS AEROPORTUARIOS" } )
	aAdd( aDadAUx, { "DR", "16200410", "TARIFA AEROPORTUARIA" } )
	aAdd( aDadAUx, { "DR", "16380000", "SERVICOS E ATIVIDADES REFERENTES A SAUDE - ESPECIFICO DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "16380100", "SERVICOS DE SAUDE - ESPECIFICO DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "16380110", "SERVICOS HOSPITALARES" } )
	aAdd( aDadAUx, { "DR", "16380120", "SERVICOS DE REGISTRO DE ANALISE E DE CONTROLE" } )
	aAdd( aDadAUx, { "DR", "16380130", "SERVICOS RADIOLOGICOS E LABORATORIAIS" } )
	aAdd( aDadAUx, { "DR", "16380140", "SERVICOS AMBULATORIAIS" } )
	aAdd( aDadAUx, { "DR", "16380190", "OUTROS SERVICOS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "16400100", "RETORNO DE OPERACOES, JUROS E ENCARGOS FINANCEIROS" } )
	aAdd( aDadAUx, { "DR", "16400110", "RETORNO DE OPERACOES, JUROS E ENCARGOS FINANCEIROS" } )
	aAdd( aDadAUx, { "DR", "16909900", "OUTROS SERVICOS" } )
	aAdd( aDadAUx, { "DR", "16909910", "OUTROS SERVICOS" } )
	aAdd( aDadAUx, { "DR", "17180000", "TRANSFERENCIAS DA UNIAO - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17180100", "PARTICIPACAO NA RECEITA DA UNIAO" } )
	aAdd( aDadAUx, { "DR", "17180120", "COTA-PARTE DO FUNDO DE PARTICIPACAO DOS MUNICIPIOS - COTA MENSAL" } )
	aAdd( aDadAUx, { "DR", "17180130", "COTA-PARTE DO FUNDO DE PARTICIPACAO DO MUNICIPIOS - 1% COTA ENTREGUE NO MES DE DEZEMBRO" } )
	aAdd( aDadAUx, { "DR", "17180140", "COTA-PARTE DO FUNDO DE PARTICIPACAO DOS MUNICIPIOS - 1% COTA ENTREGUE NO MES DE JULHO" } )
	aAdd( aDadAUx, { "DR", "17180150", "COTA-PARTE DO IMPOSTO SOBRE A PROPRIEDADE TERRITORIAL RURAL" } )
	aAdd( aDadAUx, { "DR", "17180180", "COTA-PARTE DO IMPOSTO SOBRE OPERACOES DE CREDITO, CAMBIO E SEGURO, OU RELATIVAS A TITULOS OU VALORES MOBILIARIOS - COMERCIALIZACAO DO OURO" } )
	aAdd( aDadAUx, { "DR", "17180200", "TRANSFERENCIA DA COMPENSACAO FINANCEIRA PELA EXPLORACAO DE RECURSOS NATURAIS" } )
	aAdd( aDadAUx, { "DR", "17180210", "COTA-PARTE DA COMPENSACAO FINANCEIRA DE RECURSOS HIDRICOS" } )
	aAdd( aDadAUx, { "DR", "17180220", "COTA-PARTE DA COMPENSACAO FINANCEIRA DE RECURSOS MINERAIS - CFEM" } )
	aAdd( aDadAUx, { "DR", "17180230", "COTA-PARTE ROYALTIES - COMPENSACAO FINANCEIRA PELA PRODUCAO DE PETROLEO - LEI N. 7.990/89" } )
	aAdd( aDadAUx, { "DR", "17180240", "COTA-PARTE ROYALTIES PELO EXCEDENTE DA PRODUCAO DO PETROLEO - LEI N. 9.478/97, ARTIGO 49, I E II" } )
	aAdd( aDadAUx, { "DR", "17180250", "COTA-PARTE ROYALTIES PELA PARTICIPACAO ESPECIAL - LEI N. 9.478/97, ARTIGO 50" } )
	aAdd( aDadAUx, { "DR", "17180260", "COTA-PARTE DO FUNDO ESPECIAL DO PETROLEO - FEP" } )
	aAdd( aDadAUx, { "DR", "17180290", "OUTRAS TRANSFERENCIAS DECORRENTES DE COMPENSACAO FINANCEIRA PELA EXPLORACAO DE RECURSOS NATURAIS" } )
	aAdd( aDadAUx, { "DR", "17180300", "TRANSFERENCIA DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS - BLOCO CUSTEIO DAS ACOES E SERVICOS PUBLICOS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "17180310", "TRANSFERENCIA DE RECURSOS DO SUS - ATENCAO BASICA" } )
	aAdd( aDadAUx, { "DR", "17180320", "TRANSFERENCIA DE RECURSOS DO SUS - ATENCAO DE MEDIA E ALTA COMPLEXIDADE AMBULATORIAL E HOSPITALAR" } )
	aAdd( aDadAUx, { "DR", "17180330", "TRANSFERENCIA DE RECURSOS DO SUS - VIGILANCIA EM SAUDE" } )
	aAdd( aDadAUx, { "DR", "17180340", "TRANSFERENCIA DE RECURSOS DO SUS - ASSISTENCIA FARMACEUTICA" } )
	aAdd( aDadAUx, { "DR", "17180350", "TRANSFERENCIA DE RECURSOS DO SUS - GESTAO DO SUS" } )
	aAdd( aDadAUx, { "DR", "17180390", "TRANSFERENCIA DE RECURSOS DO SUS - OUTROS PROGRAMAS FINANCIADOS POR TRANSFERENCIAS FUNDO A FUNDO" } )
	aAdd( aDadAUx, { "DR", "17180400", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS - BLOCO INVESTIMENTOS NA REDE DE SERVICOS PUBLICOS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "17180410", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS DESTINADOS A ATENCAO BASICA" } )
	aAdd( aDadAUx, { "DR", "17180420", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS DESTINADOS A ATENCAO ESPECIALIZADA" } )
	aAdd( aDadAUx, { "DR", "17180430", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS DESTINADOS A VIGILANCIA EM SAUDE" } )
	aAdd( aDadAUx, { "DR", "17180440", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS DESTINADOS A GESTAO E DESENVOLVIMENTO DE TECNOLOGIAS EM SAUDE NO SUS" } )
	aAdd( aDadAUx, { "DR", "17180450", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS DESTINADOS A GESTAO DO SUS" } )
	aAdd( aDadAUx, { "DR", "17180460", "OUTRAS TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS, NAO DETALHADAS ANTERIORMENTE" } )
	aAdd( aDadAUx, { "DR", "17180500", "TRANSFERENCIAS DE RECURSOS DO FUNDO NACIONAL DO DESENVOLVIMENTO DA EDUCACAO - FNDE" } )
	aAdd( aDadAUx, { "DR", "17180510", "TRANSFERENCIAS DO SALARIO-EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "17180520", "TRANSFERENCIAS DIRETAS DO FNDE REFERENTES AO PROGRAMA DINHEIRO DIRETO NA ESCOLA - PDDE" } )
	aAdd( aDadAUx, { "DR", "17180530", "TRANSFERENCIAS DIRETAS DO FNDE REFERENTES AO PROGRAMA NACIONAL DE ALIMENTACAO ESCOLAR - PNAE" } )
	aAdd( aDadAUx, { "DR", "17180540", "TRANSFERENCIAS DIRETAS DO FNDE REFERENTES AO PROGRAMA NACIONAL DE APOIO AO TRANSPORTE DO ESCOLAR - PNATE" } )
	aAdd( aDadAUx, { "DR", "17180550", "PROGRAMA NACIONAL DE INCLUSAO DE JOVENS - PROJOVEM URBANO" } )
	aAdd( aDadAUx, { "DR", "17180560", "PROGRAMA NACIONAL DE INCLUSAO DE JOVENS - PROJOVEM CAMPO" } )
	aAdd( aDadAUx, { "DR", "17180570", "PROGRAMA BRASIL ALFABETIZADO - PBA" } )
	aAdd( aDadAUx, { "DR", "17180580", "PROGRAMA DE APOIO AOS SISTEMAS DE ENSINO PARA ATENDIMENTO A EDUCACAO DE JOVENS E ADULTOS - PEJA" } )
	aAdd( aDadAUx, { "DR", "17180590", "OUTRAS TRANSFERENCIAS DIRETAS DO FUNDO NACIONAL DO DESENVOLVIMENTO DA EDUCACAO - FNDE" } )
	aAdd( aDadAUx, { "DR", "17180600", "TRANSFERENCIA FINANCEIRA DO ICMS - DESONERACAO - L.C. N. 87/96" } )
	aAdd( aDadAUx, { "DR", "17180610", "TRANSFERENCIA FINANCEIRA DO ICMS - DESONERACAO - L.C. N. 87/96" } )
	aAdd( aDadAUx, { "DR", "17180700", "TRANSFERENCIAS DA UNIAO A CONSORCIOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "17180710", "TRANSFERENCIAS DA UNIAO A CONSORCIOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "17180900", "TRANSFERENCIAS DE RECURSOS DE COMPLEMENTACAO DA UNIAO AO FUNDO DE MANUTENCAO E DESENVOLVIMENTO DA EDUCACAO BASICA E DE VALORIZACAO DOS PROFISSIONAIS DA EDUCACAO - FUNDEB" } )
	aAdd( aDadAUx, { "DR", "17180910", "TRANSFERENCIAS DE RECURSOS DA COMPLEMENTACAO DA UNIAO AO FUNDO DE MANUTENCAO E DESENVOLVIMENTO DA EDUCACAO BASICA E DE VALORIZACAO DOS PROFISSIONAIS DA EDUCACAO - FUNDEB" } )
	aAdd( aDadAUx, { "DR", "17181000", "TRANSFERENCIAS DE CONVENIOS DA UNIAO E DE SUAS ENTIDADES" } )
	aAdd( aDadAUx, { "DR", "17181010", "TRANSFERENCIAS DE CONVENIOS DA UNIAO PARA O SISTEMA UNICO DE SAUDE - SUS" } )
	aAdd( aDadAUx, { "DR", "17181020", "TRANSFERENCIAS DE CONVENIOS DA UNIAO DESTINADAS A PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "17181030", "TRANSFERENCIAS DE CONVENIOS DA UNIAO DESTINADAS A PROGRAMAS DE ASSISTENCIA SOCIAL" } )
	aAdd( aDadAUx, { "DR", "17181040", "TRANSFERENCIAS DE CONVENIOS DA UNIAO DESTINADAS A PROGRAMAS DE COMBATE A FOME" } )
	aAdd( aDadAUx, { "DR", "17181050", "TRANSFERENCIAS DE CONVENIOS DA UNIAO DESTINADAS A PROGRAMAS DE SANEAMENTO BASICO" } )
	aAdd( aDadAUx, { "DR", "17181090", "OUTRAS TRANSFERENCIAS DE CONVENIOS DA UNIAO" } )
	aAdd( aDadAUx, { "DR", "17181100", "OUTRAS TRANSFERENCIAS DE RECURSOS FUNDO A FUNDO" } )
	aAdd( aDadAUx, { "DR", "17181110", "TRANSFERENCIA DE RECURSOS DO FUNDO PENITENCIARIO NACIONAL - FUPEN" } )
	aAdd( aDadAUx, { "DR", "17181200", "TRANSFERENCIAS DE RECURSOS DO FUNDO NACIONAL DE ASSISTENCIA SOCIAL - FNAS" } )
	aAdd( aDadAUx, { "DR", "17181210", "TRANSFERENCIAS DE RECURSOS DO FUNDO NACIONAL DE ASSISTENCIA SOCIAL - FNAS" } )
	aAdd( aDadAUx, { "DR", "17181300", "TRANSFERENCIAS DECORRENTES DE DECISAO JUDICIAL (PRECATORIOS) RELATIVAS AO FUNDO DE MANUTENCAO E DESENVOLVIMENTO DO ENSINO FUNDAMENTAL E DE VALORIZACAO DO MAGISTERIO - FUNDEF" } )
	aAdd( aDadAUx, { "DR", "17181310", "TRANSFERENCIAS DECORRENTES DE DECISAO JUDICIAL (PRECATORIOS) RELATIVAS AO FUNDO DE MANUTENCAO E DESENVOLVIMENTO DO ENSINO FUNDAMENTAL E DE VALORIZACAO DO MAGISTERIO - FUNDEF" } )
	aAdd( aDadAUx, { "DR", "17189900", "OUTRAS TRANSFERENCIAS DA UNIAO" } )
	aAdd( aDadAUx, { "DR", "17189910", "OUTRAS TRANSFERENCIAS DA UNIAO" } )
	aAdd( aDadAUx, { "DR", "17280000", "TRANSFERENCIAS DOS ESTADOS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17280100", "PARTICIPACAO NA RECEITA DOS ESTADOS" } )
	aAdd( aDadAUx, { "DR", "17280110", "COTA-PARTE DO ICMS" } )
	aAdd( aDadAUx, { "DR", "17280120", "COTA-PARTE DO IPVA" } )
	aAdd( aDadAUx, { "DR", "17280130", "COTA-PARTE DO IPI - MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17280140", "COTA-PARTE DA CONTRIBUICAO DE INTERVENCAO NO DOMINIO ECONOMICO" } )
	aAdd( aDadAUx, { "DR", "17280150", "OUTRAS PARTICIPACOES NA RECEITA DOS ESTADOS" } )
	aAdd( aDadAUx, { "DR", "17280190", "OUTRAS TRANSFERENCIAS DOS ESTADOS" } )
	aAdd( aDadAUx, { "DR", "17280200", "TRANSFERENCIA DA COTA-PARTE DA COMPENSACAO FINANCEIRA (25%)" } )
	aAdd( aDadAUx, { "DR", "17280210", "COTA-PARTE DA COMPENSACAO FINANCEIRA DE RECURSOS HIDRICOS" } )
	aAdd( aDadAUx, { "DR", "17280220", "COTA-PARTE DA COMPENSACAO FINANCEIRA DE RECURSOS MINERAIS - CFEM" } )
	aAdd( aDadAUx, { "DR", "17280230", "COTA-PARTE ROYALTIES - COMPENSACAO FINANCEIRA PELA PRODUCAO DO PETROLEO - LEI N. 7.990/89, ARTIGO 9" } )
	aAdd( aDadAUx, { "DR", "17280290", "OUTRAS TRANSFERENCIAS DECORRENTES DE COMPENSACOES FINANCEIRAS" } )
	aAdd( aDadAUx, { "DR", "17280300", "TRANSFERENCIA DE RECURSOS DO ESTADO PARA PROGRAMAS DE SAUDE - REPASSE FUNDO A FUNDO" } )
	aAdd( aDadAUx, { "DR", "17280310", "TRANSFERENCIA DE RECURSOS DO ESTADO PARA PROGRAMAS DE SAUDE - REPASSE FUNDO A FUNDO" } )
	aAdd( aDadAUx, { "DR", "17280400", "TRANSFERENCIAS DE ESTADOS A CONSORCIOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "17280410", "TRANSFERENCIAS DE ESTADOS A CONSORCIOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "17280700", "TRANSFERENCIAS DE ESTADOS DESTINADAS A ASSISTENCIA SOCIAL" } )
	aAdd( aDadAUx, { "DR", "17280710", "TRANSFERENCIAS DE ESTADOS DESTINADAS A ASSISTENCIA SOCIAL" } )
	aAdd( aDadAUx, { "DR", "17281000", "TRANSFERENCIA DE CONVENIOS DOS ESTADOS E DO DISTRITO FEDERAL E DE SUAS ENTIDADES" } )
	aAdd( aDadAUx, { "DR", "17281010", "TRANSFERENCIAS DE CONVENIO DOS ESTADOS PARA O SISTEMA UNICO DE SAUDE - SUS" } )
	aAdd( aDadAUx, { "DR", "17281020", "TRANSFERENCIAS DE CONVENIO DOS ESTADOS DESTINADAS A PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "17281090", "OUTRAS TRANSFERENCIAS DE CONVENIO DOS ESTADOS" } )
	aAdd( aDadAUx, { "DR", "17289900", "OUTRAS TRANSFERENCIAS DOS ESTADOS" } )
	aAdd( aDadAUx, { "DR", "17289910", "OUTRAS TRANSFERENCIAS DOS ESTADOS" } )
	aAdd( aDadAUx, { "DR", "17380000", "TRANSFERENCIAS DOS MUNICIPIOS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17380100", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS" } )
	aAdd( aDadAUx, { "DR", "17380110", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS" } )
	aAdd( aDadAUx, { "DR", "17380200", "TRANSFERENCIAS DE MUNICIPIOS A CONSORCIOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "17380210", "TRANSFERENCIAS DE MUNICIPIOS A CONSORCIOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "17381000", "TRANSFERENCIA DE CONVENIOS DOS MUNICIPIOS E DE SUAS ENTIDADES" } )
	aAdd( aDadAUx, { "DR", "17381010", "TRANSFERENCIAS DE CONVENIO DOS MUNICIPIOS PARA O SISTEMA UNICO DE SAUDE - SUS" } )
	aAdd( aDadAUx, { "DR", "17381020", "TRANSFERENCIAS DE CONVENIO DOS MUNICIPIOS DESTINADAS A PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "17381090", "OUTRAS TRANSFERENCIAS DE CONVENIOS DOS MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17389900", "OUTRAS TRANSFERENCIAS DOS MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17389910", "OUTRAS TRANSFERENCIAS DOS MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17400010", "TRANSFERENCIAS DE INSTITUICOES PRIVADAS" } )
	aAdd( aDadAUx, { "DR", "17480000", "TRANSFERENCIAS DE INSTITUICOES PRIVADAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17480100", "TRANSFERENCIA DE CONVENIOS DE INSTITUICOES PRIVADAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17480110", "TRANSFERENCIAS DE CONVENIOS DE INSTITUICOES PRIVADAS PARA PROGRAMAS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "17480120", "TRANSFERENCIAS DE CONVENIOS DE INSTITUICOES PRIVADAS PARA PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "17480190", "OUTRAS TRANSFERENCIAS DE CONVENIOS DE INSTITUICOES PRIVADAS" } )
	aAdd( aDadAUx, { "DR", "17481000", "OUTRAS TRANSFERENCIA DE INSTITUICOES PRIVADAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - NAO ESPECIFICADAS ANTERIORMENTE" } )
	aAdd( aDadAUx, { "DR", "17481010", "OUTRAS TRANSFERENCIA DE INSTITUICOES PRIVADAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - NAO ESPECIFICADAS ANTERIORMENTE" } )
	aAdd( aDadAUx, { "DR", "17500010", "TRANSFERENCIAS DE OUTRAS INSTITUICOES PUBLICAS" } )
	aAdd( aDadAUx, { "DR", "17580000", "TRANSFERENCIAS DE OUTRAS INSTITUICOES PUBLICAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17580100", "TRANSFERENCIAS DE RECURSOS DO FUNDO DE MANUTENCAO E DESENVOLVIMENTO DA EDUCACAO BASICA E DE VALORIZACAO DOS PROFISSIONAIS DA EDUCACAO - FUNDEB" } )
	aAdd( aDadAUx, { "DR", "17580110", "TRANSFERENCIAS DE RECURSOS DO FUNDO DE MANUTENCAO E DESENVOLVIMENTO DA EDUCACAO BASICA E DE VALORIZACAO DOS PROFISSIONAIS DA EDUCACAO - FUNDEB" } )
	aAdd( aDadAUx, { "DR", "17589900", "OUTRAS TRANSFERENCIAS MULTIGOVERNAMENTAIS" } )
	aAdd( aDadAUx, { "DR", "17589910", "OUTRAS TRANSFERENCIAS MULTIGOVERNAMENTAIS" } )
	aAdd( aDadAUx, { "DR", "17600010", "TRANSFERENCIAS DO EXTERIOR" } )
	aAdd( aDadAUx, { "DR", "17680000", "TRANSFERENCIAS DO EXTERIOR - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17680100", "TRANSFERENCIA DE CONVENIOS DO EXTERIOR" } )
	aAdd( aDadAUx, { "DR", "17680110", "TRANSFERENCIA DE CONVENIOS DO EXTERIOR" } )
	aAdd( aDadAUx, { "DR", "17680120", "TRANSFERENCIA DE CONVENIOS DO EXTERIOR - PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "17680190", "OUTRAS TRANSFERENCIA DE CONVENIOS DO EXTERIOR - NAO ESPECIFICADAS ANTERIORMENTE" } )
	aAdd( aDadAUx, { "DR", "17780000", "TRANSFERENCIAS DE PESSOAS FISICAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17780100", "TRANSFERENCIAS DE PESSOAS FISICAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "17780110", "TRANSFERENCIAS DE PESSOAS FISICAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - PROGRAMAS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "17780120", "TRANSFERENCIAS DE PESSOAS FISICAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "17780190", "TRANSFERENCIAS DE PESSOAS FISICAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - NAO ESPECIFICADAS ANTERIORMENTE" } )
	aAdd( aDadAUx, { "DR", "17800010", "TRANSFERENCIAS PROVENIENTES DE DEPOSITOS NAO IDENTIFICADOS" } )
	aAdd( aDadAUx, { "DR", "19100100", "MULTAS PREVISTAS EM LEGISLACAO ESPECIFICA" } )
	aAdd( aDadAUx, { "DR", "19100110", "MULTAS PREVISTAS EM LEGISLACAO ESPECIFICA" } )
	aAdd( aDadAUx, { "DR", "19100600", "MULTAS POR DANOS AMBIENTAIS" } )
	aAdd( aDadAUx, { "DR", "19100610", "MULTAS ADMINISTRATIVAS POR DANOS AMBIENTAIS" } )
	aAdd( aDadAUx, { "DR", "19100620", "MULTAS JUDICIAIS POR DANOS AMBIENTAIS" } )
	aAdd( aDadAUx, { "DR", "19100800", "MULTAS DECORRENTES DE SENTENCAS JUDICIAIS" } )
	aAdd( aDadAUx, { "DR", "19100810", "MULTAS DECORRENTES DE SENTENCAS JUDICIAIS" } )
	aAdd( aDadAUx, { "DR", "19100900", "MULTAS E JUROS PREVISTOS EM CONTRATOS" } )
	aAdd( aDadAUx, { "DR", "19100910", "MULTAS E JUROS PREVISTOS EM CONTRATOS" } )
	aAdd( aDadAUx, { "DR", "19101300", "MULTAS PREVISTAS NA LEGISLACAO ANTICORRUPCAO" } )
	aAdd( aDadAUx, { "DR", "19101310", "MULTAS DA LEGISLACAO ANTICORRUPCAO ORIUNDAS DE PROCESSOS ADMINISTRATIVOS DE RESPONSABILIZACAO" } )
	aAdd( aDadAUx, { "DR", "19101320", "MULTAS DA LEGISLACAO ANTICORRUPCAO ORIUNDAS DE CELEBRACAO DE ACORDOS DE LENIENCIA" } )
	aAdd( aDadAUx, { "DR", "19210000", "INDENIZACOES" } )
	aAdd( aDadAUx, { "DR", "19210100", "INDENIZACOES POR DANOS CAUSADOS AO PATRIMONIO PUBLICO" } )
	aAdd( aDadAUx, { "DR", "19210110", "INDENIZACOES POR DANOS CAUSADOS AO PATRIMONIO PUBLICO" } )
	aAdd( aDadAUx, { "DR", "19210200", "INDENIZACAO POR POSSE OU OCUPACAO ILICITA DE BENS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "19210210", "INDENIZACAO POR POSSE OU OCUPACAO ILICITA DE BENS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "19210300", "INDENIZACAO POR SINISTRO" } )
	aAdd( aDadAUx, { "DR", "19210310", "INDENIZACAO POR SINISTRO" } )
	aAdd( aDadAUx, { "DR", "19220000", "RESTITUICOES" } )
	aAdd( aDadAUx, { "DR", "19220100", "RESTITUICAO DE CONVENIOS" } )
	aAdd( aDadAUx, { "DR", "19220110", "RESTITUICAO DE CONVENIOS - PRIMARIAS" } )
	aAdd( aDadAUx, { "DR", "19220120", "RESTITUICAO DE CONVENIOS - FINANCEIRAS" } )
	aAdd( aDadAUx, { "DR", "19220200", "RESTITUICAO DE BENEFICIOS NAO DESEMBOLSADOS" } )
	aAdd( aDadAUx, { "DR", "19220210", "RESTITUICAO DE BENEFICIOS NAO DESEMBOLSADOS" } )
	aAdd( aDadAUx, { "DR", "19220300", "RESTITUICAO DE BENEFICIOS PREVIDENCIARIOS" } )
	aAdd( aDadAUx, { "DR", "19220310", "RESTITUICAO DE BENEFICIOS PREVIDENCIARIOS" } )
	aAdd( aDadAUx, { "DR", "19220500", "RESTITUICAO DE CONTRIBUICOES PREVIDENCIARIAS COMPLEMENTARES" } )
	aAdd( aDadAUx, { "DR", "19220510", "RESTITUICAO DE CONTRIBUICOES PREVIDENCIARIAS COMPLEMENTARES" } )
	aAdd( aDadAUx, { "DR", "19220600", "RESTITUICAO DE DESPESAS DE EXERCICIOS ANTERIORES" } )
	aAdd( aDadAUx, { "DR", "19220610", "RESTITUICAO DE DESPESAS DE EXERCICIOS ANTERIORES" } )
	aAdd( aDadAUx, { "DR", "19220900", "RESTITUICAO DE RECURSOS DE FOMENTO" } )
	aAdd( aDadAUx, { "DR", "19220910", "RESTITUICAO DE RECURSOS DE FOMENTO" } )
	aAdd( aDadAUx, { "DR", "19221200", "RESTITUICAO DE DEPOSITOS DE SENTENCAS JUDICIAIS NAO SACADOS" } )
	aAdd( aDadAUx, { "DR", "19221210", "RESTITUICAO DE DEPOSITOS DE SENTENCAS JUDICIAIS NAO SACADOS" } )
	aAdd( aDadAUx, { "DR", "19280000", "INDENIZACOES, RESTITUICOES E RESSARCIMENTOS  - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "19280100", "INDENIZACOES - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "19280110", "INDENIZACOES - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "19280200", "RESTITUICOES - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "19280210", "RESTITUICOES DE RECURSOS RECEBIDOS DO SUS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "19280290", "OUTRAS RESTITUICOES - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - NAO ESPECIFICADAS ANTERIORMENTE" } )
	aAdd( aDadAUx, { "DR", "19280300", "RESSARCIMENTOS - ESPECIFICOS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "19280310", "RESSARCIMENTOS - ESPECIFICOS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "19300100", "BENS, DIREITOS E VALORES PERDIDOS EM FAVOR DO PODER PUBLICO" } )
	aAdd( aDadAUx, { "DR", "19300110", "BENS, DIREITOS E VALORES PERDIDOS EM FAVOR DO PODER PUBLICO" } )
	aAdd( aDadAUx, { "DR", "19300200", "ALIENACAO DE BENS APREENDIDOS" } )
	aAdd( aDadAUx, { "DR", "19300210", "ALIENACAO DE BENS E MERCADORIAS APREENDIDOS" } )
	aAdd( aDadAUx, { "DR", "19300220", "ALIENACAO DE BENS E MERCADORIAS ASSOCIADOS AO TRAFICO ILICITO DE ENTORPECENTES E DROGAS AFINS" } )
	aAdd( aDadAUx, { "DR", "19300300", "DEPOSITOS ABANDONADOS (DINHEIRO E/OU OBJETOS DE VALOR)" } )
	aAdd( aDadAUx, { "DR", "19300310", "DEPOSITOS ABANDONADOS (DINHEIRO E/OU OBJETOS DE VALOR)" } )
	aAdd( aDadAUx, { "DR", "19300500", "RECEITAS RECONHECIDAS POR FORCA DE DECISOES JUDICIAIS E DE TRIBUNAIS ADMINISTRATIVOS" } )
	aAdd( aDadAUx, { "DR", "19300510", "RECEITAS RECONHECIDAS POR FORCA DE DECISOES JUDICIAIS E DE TRIBUNAIS ADMINISTRATIVOS" } )
	aAdd( aDadAUx, { "DR", "19900100", "APORTES PERIODICOS PARA AMORTIZACAO DE DEFICIT ATUARIAL DO RPPS" } )
	aAdd( aDadAUx, { "DR", "19900110", "APORTES PERIODICOS PARA AMORTIZACAO DE DEFICIT ATUARIAL DO RPPS" } )
	aAdd( aDadAUx, { "DR", "19900300", "COMPENSACOES FINANCEIRAS ENTRE O REGIME GERAL E OS REGIMES PROPRIOS DE PREVIDENCIA DOS SERVIDORES" } )
	aAdd( aDadAUx, { "DR", "19900310", "COMPENSACOES FINANCEIRAS ENTRE O REGIME GERAL E OS REGIMES PROPRIOS DE PREVIDENCIA DOS SERVIDORES" } )
	aAdd( aDadAUx, { "DR", "19900600", "CONTRAPARTIDA DE SUBVENCOES OU SUBSIDIOS" } )
	aAdd( aDadAUx, { "DR", "19900610", "CONTRAPARTIDA DE SUBVENCOES OU SUBSIDIOS" } )
	aAdd( aDadAUx, { "DR", "19901100", "VARIACAO CAMBIAL" } )
	aAdd( aDadAUx, { "DR", "19901110", "VARIACAO CAMBIAL" } )
	aAdd( aDadAUx, { "DR", "19901200", "ENCARGOS LEGAIS PELA INSCRICAO EM DIVIDA ATIVA E RECEITAS DE ONUS DE SUCUMBENCIA" } )
	aAdd( aDadAUx, { "DR", "19901220", "ONUS DE SUCUMBENCIA" } )
	aAdd( aDadAUx, { "DR", "19909900", "OUTRAS RECEITAS" } )
	aAdd( aDadAUx, { "DR", "19909910", "OUTRAS RECEITAS - PRIMARIAS" } )
	aAdd( aDadAUx, { "DR", "19909920", "OUTRAS RECEITAS - FINANCEIRAS" } )
	aAdd( aDadAUx, { "DR", "21180000", "OPERACOES DE CREDITO - MERCADO INTERNO - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "21180100", "OPERACOES DE CREDITO INTERNAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "21180110", "OPERACOES DE CREDITO INTERNAS PARA PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "21180120", "OPERACOES DE CREDITO INTERNAS PARA PROGRAMAS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "21180130", "OPERACOES DE CREDITO INTERNAS PARA PROGRAMAS DE SANEAMENTO" } )
	aAdd( aDadAUx, { "DR", "21180140", "OPERACOES DE CREDITO INTERNAS PARA PROGRAMAS DE MEIO AMBIENTE" } )
	aAdd( aDadAUx, { "DR", "21180150", "OPERACOES DE CREDITO INTERNAS PARA PROGRAMAS DE MODERNIZACAO DA ADMINISTRACAO PUBLICA" } )
	aAdd( aDadAUx, { "DR", "21180160", "OPERACOES DE CREDITO INTERNAS PARA REFINANCIAMENTO DA DIVIDA CONTRATUAL" } )
	aAdd( aDadAUx, { "DR", "21180170", "OPERACOES DE CREDITO INTERNAS PARA PROGRAMAS DE MORADIA POPULAR" } )
	aAdd( aDadAUx, { "DR", "21190000", "OUTRAS OPERACOES DE CREDITO - MERCADO INTERNO" } )
	aAdd( aDadAUx, { "DR", "21190010", "OUTRAS OPERACOES DE CREDITO - MERCADO INTERNO" } )
	aAdd( aDadAUx, { "DR", "21280000", "OPERACAO DE CREDITO EXTERNAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "21280100", "OPERACOES DE CREDITO EXTERNAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "21280110", "OPERACOES DE CREDITO EXTERNAS PARA PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "21280120", "OPERACOES DE CREDITO EXTERNAS PARA PROGRAMAS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "21280130", "OPERACOES DE CREDITO EXTERNAS PARA PROGRAMAS DE SANEAMENTO" } )
	aAdd( aDadAUx, { "DR", "21280140", "OPERACOES DE CREDITO EXTERNAS PARA PROGRAMAS DE MEIO AMBIENTE" } )
	aAdd( aDadAUx, { "DR", "21280150", "OPERACOES DE CREDITO EXTERNAS PARA PROGRAMAS DE MODERNIZACAO DA ADMINISTRACAO PUBLICA" } )
	aAdd( aDadAUx, { "DR", "21280160", "OPERACOES DE CREDITO EXTERNAS PARA REFINANCIAMENTO DA DIVIDA CONTRATUAL" } )
	aAdd( aDadAUx, { "DR", "21290000", "OUTRAS OPERACOES DE CREDITO - MERCADO EXTERNO" } )
	aAdd( aDadAUx, { "DR", "21290010", "OUTRAS OPERACOES DE CREDITO - MERCADO EXTERNO" } )
	aAdd( aDadAUx, { "DR", "22130000", "ALIENACAO DE BENS MOVEIS E SEMOVENTES" } )
	aAdd( aDadAUx, { "DR", "22130010", "ALIENACAO DE BENS MOVEIS E SEMOVENTES" } )
	aAdd( aDadAUx, { "DR", "22180000", "ALIENACAO DE BENS MOVEIS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "22180100", "ALIENACAO DE TITULOS MOBILIARIOS" } )
	aAdd( aDadAUx, { "DR", "22180110", "ALIENACAO DE INVESTIMENTOS TEMPORARIOS" } )
	aAdd( aDadAUx, { "DR", "22180120", "ALIENACAO DE INVESTIMENTOS PERMANENTES" } )
	aAdd( aDadAUx, { "DR", "22200010", "ALIENACAO DE BENS IMOVEIS" } )
	aAdd( aDadAUx, { "DR", "22300010", "ALIENACAO DE BENS INTANGIVEIS" } )
	aAdd( aDadAUx, { "DR", "23000600", "AMORTIZACAO DE EMPRESTIMOS CONTRATUAIS" } )
	aAdd( aDadAUx, { "DR", "23000610", "AMORTIZACAO DE EMPRESTIMOS CONTRATUAIS" } )
	aAdd( aDadAUx, { "DR", "23000700", "AMORTIZACAO DE FINANCIAMENTOS" } )
	aAdd( aDadAUx, { "DR", "23000710", "AMORTIZACAO DE FINANCIAMENTOS" } )
	aAdd( aDadAUx, { "DR", "24180000", "TRANSFERENCIAS DA UNIAO" } )
	aAdd( aDadAUx, { "DR", "24180100", "TRANSFERENCIAS DA UNIAO A CONSORCIOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "24180110", "TRANSFERENCIAS DA UNIAO A CONSORCIOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "24180300", "TRANSFERENCIA DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS - BLOCO CUSTEIO DAS ACOES E SERVICOS PUBLICOS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "24180310", "TRANSFERENCIA DE RECURSOS DO SUS - ATENCAO BASICA" } )
	aAdd( aDadAUx, { "DR", "24180320", "TRANSFERENCIA DE RECURSOS DO SUS - ATENCAO DE MEDIA E ALTA COMPLEXIDADE AMBULATORIAL E HOSPITALAR" } )
	aAdd( aDadAUx, { "DR", "24180330", "TRANSFERENCIA DE RECURSOS DO SUS - VIGILANCIA EM SAUDE" } )
	aAdd( aDadAUx, { "DR", "24180340", "TRANSFERENCIA DE RECURSOS DO SUS - ASSISTENCIA FARMACEUTICA" } )
	aAdd( aDadAUx, { "DR", "24180350", "TRANSFERENCIA DE RECURSOS DO SUS - GESTAO DO SUS" } )
	aAdd( aDadAUx, { "DR", "24180390", "TRANSFERENCIA DE RECURSOS DO SUS - OUTROS PROGRAMAS FINANCIADOS POR TRANSFERENCIAS FUNDO A FUNDO" } )
	aAdd( aDadAUx, { "DR", "24180400", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS - BLOCO INVESTIMENTOS NA REDE DE SERVICOS PUBLICOS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "24180410", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS DESTINADOS A ATENCAO BASICA" } )
	aAdd( aDadAUx, { "DR", "24180420", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS DESTINADOS A ATENCAO ESPECIALIZADA" } )
	aAdd( aDadAUx, { "DR", "24180430", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS DESTINADOS A VIGILANCIA EM SAUDE" } )
	aAdd( aDadAUx, { "DR", "24180440", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS DESTINADOS A GESTAO E DESENVOLVIMENTO DE TECNOLOGIAS EM SAUDE NO SUS" } )
	aAdd( aDadAUx, { "DR", "24180450", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS DESTINADOS A GESTAO DO SUS" } )
	aAdd( aDadAUx, { "DR", "24180460", "OUTRAS TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS, NAO DETALHADAS ANTERIORMENTE" } )
	aAdd( aDadAUx, { "DR", "24180500", "TRANSFERENCIAS DE RECURSOS DESTINADOS A PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "24180510", "PROGRAMA DE APOIO AO TRANSPORTE ESCOLAR PARA EDUCACAO BASICA - CAMINHO DA ESCOLA" } )
	aAdd( aDadAUx, { "DR", "24180520", "PROGRAMA NACIONAL DE REESTRUTURACAO E AQUISICAO DE EQUIPAMENTOS PARA A REDE ESCOLAR PUBLICA DE EDUCACAO INFANTIL - PROINFANCIA" } )
	aAdd( aDadAUx, { "DR", "24180590", "OUTRAS TRANSFERENCIAS DESTINADAS A PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "24181000", "TRANSFERENCIA DE CONVENIOS DA UNIAO E DE SUAS ENTIDADES" } )
	aAdd( aDadAUx, { "DR", "24181010", "TRANSFERENCIAS DE CONVENIO DA UNIAO PARA O SISTEMA UNICO DE SAUDE - SUS" } )
	aAdd( aDadAUx, { "DR", "24181020", "TRANSFERENCIAS DE CONVENIO DA UNIAO DESTINADAS A PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "24181050", "TRANSFERENCIAS DE CONVENIOS DA UNIAO DESTINADAS A PROGRAMAS DE SANEAMENTO BASICO" } )
	aAdd( aDadAUx, { "DR", "24181060", "TRANSFERENCIAS DE CONVENIOS DA UNIAO DESTINADAS A PROGRAMAS DE MEIO AMBIENTE" } )
	aAdd( aDadAUx, { "DR", "24181070", "TRANSFERENCIAS DE CONVENIOS DA UNIAO DESTINADAS A PROGRAMAS DE INFRAESTRUTURA EM TRANSPORTE" } )
	aAdd( aDadAUx, { "DR", "24181090", "OUTRAS TRANSFERENCIAS DE CONVENIOS DA UNIAO" } )
	aAdd( aDadAUx, { "DR", "24181200", "TRANSFERENCIAS DE RECURSOS DO FUNDO NACIONAL DE ASSISTENCIA SOCIAL - FNAS" } )
	aAdd( aDadAUx, { "DR", "24181210", "TRANSFERENCIAS DE RECURSOS DO FUNDO NACIONAL DE ASSISTENCIA SOCIAL - FNAS" } )
	aAdd( aDadAUx, { "DR", "24189900", "OUTRAS TRANSFERENCIAS DA UNIAO" } )
	aAdd( aDadAUx, { "DR", "24189910", "OUTRAS TRANSFERENCIAS DA UNIAO" } )
	aAdd( aDadAUx, { "DR", "24280000", "TRANSFERENCIAS DOS ESTADOS, DISTRITO FEDERAL E DE SUAS ENTIDADES" } )
	aAdd( aDadAUx, { "DR", "24280100", "TRANSFERENCIAS DOS ESTADOS E DISTRITO FEDERAL A CONSORCIOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "24280110", "TRANSFERENCIAS DOS ESTADOS E DISTRITO FEDERAL A CONSORCIOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "24280300", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS" } )
	aAdd( aDadAUx, { "DR", "24280310", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS" } )
	aAdd( aDadAUx, { "DR", "24280500", "TRANSFERENCIAS DE RECURSOS DESTINADOS A PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "24280510", "TRANSFERENCIAS DE RECURSOS DESTINADOS A PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "24281000", "TRANSFERENCIAS DE CONVENIOS DOS ESTADOS E DO DISTRITO FEDERAL E DE SUAS ENTIDADES" } )
	aAdd( aDadAUx, { "DR", "24281010", "TRANSFERENCIAS DE CONVENIOS DOS ESTADOS PARA O SISTEMA UNICO DE SAUDE - SUS" } )
	aAdd( aDadAUx, { "DR", "24281020", "TRANSFERENCIAS DE CONVENIOS DOS ESTADOS DESTINADAS A PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "24281050", "TRANSFERENCIAS DE CONVENIOS DOS ESTADOS DESTINADAS A PROGRAMAS DE SANEAMENTO BASICO" } )
	aAdd( aDadAUx, { "DR", "24281060", "TRANSFERENCIAS DE CONVENIOS DOS ESTADOS DESTINADAS A PROGRAMAS DE MEIO AMBIENTE" } )
	aAdd( aDadAUx, { "DR", "24281070", "TRANSFERENCIAS DE CONVENIOS DOS ESTADOS DESTINADAS A PROGRAMAS DE INFRAESTRUTURA EM TRANSPORTE" } )
	aAdd( aDadAUx, { "DR", "24281090", "OUTRAS TRANSFERENCIAS DE CONVENIO DOS ESTADOS" } )
	aAdd( aDadAUx, { "DR", "24289900", "OUTRAS TRANSFERENCIAS DOS ESTADOS" } )
	aAdd( aDadAUx, { "DR", "24289910", "OUTRAS TRANSFERENCIAS DOS ESTADOS" } )
	aAdd( aDadAUx, { "DR", "24380000", "TRANSFERENCIAS DOS MUNICIPIOS E DE SUAS ENTIDADES" } )
	aAdd( aDadAUx, { "DR", "24380100", "TRANSFERENCIAS DE MUNICIPIOS A CONSORCIOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "24380110", "TRANSFERENCIAS DE MUNICIPIOS A CONSORCIOS PUBLICOS" } )
	aAdd( aDadAUx, { "DR", "24381000", "TRANSFERENCIAS DE CONVENIOS DOS MUNICIPIOS E DE SUAS ENTIDADES" } )
	aAdd( aDadAUx, { "DR", "24381010", "TRANSFERENCIAS DE CONVENIOS DOS MUNICIPIOS DESTINADOS A PROGRAMAS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "24381020", "TRANSFERENCIAS DE CONVENIOS DOS MUNICIPIOS DESTINADAS A PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "24381030", "TRANSFERENCIAS DE CONVENIOS DOS MUNICIPIOS DESTINADAS A PROGRAMAS DE SANEAMENTO" } )
	aAdd( aDadAUx, { "DR", "24381090", "OUTRAS TRANSFERENCIAS DE CONVENIOS DOS MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "24389900", "OUTRAS TRANSFERENCIAS DOS MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "24389910", "OUTRAS TRANSFERENCIAS DOS MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "24400010", "TRANSFERENCIAS DE INSTITUICOES PRIVADAS" } )
	aAdd( aDadAUx, { "DR", "24480000", "TRANSFERENCIAS DE INSTITUICOES PRIVADAS  - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "24480100", "TRANSFERENCIAS DE CONVENIOS DE INSTITUICOES PRIVADAS" } )
	aAdd( aDadAUx, { "DR", "24480110", "TRANSFERENCIAS DE CONVENIOS DE INSTITUICOES PRIVADAS DESTINADOS A PROGRAMAS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "24480120", "TRANSFERENCIAS DE CONVENIOS DE INSTITUICOES PRIVADAS DESTINADOS A PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "24480190", "OUTRAS TRANSFERENCIAS DE CONVENIOS DE INSTITUICOES PRIVADAS" } )
	aAdd( aDadAUx, { "DR", "24481000", "OUTRAS TRANSFERENCIAS DE INSTITUICOES PRIVADAS" } )
	aAdd( aDadAUx, { "DR", "24481010", "OUTRAS TRANSFERENCIAS DE INSTITUICOES PRIVADAS" } )
	aAdd( aDadAUx, { "DR", "24580000", "TRANSFERENCIAS DE OUTRAS INSTITUICOES PUBLICAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "24580100", "TRANSFERENCIAS DE OUTRAS INSTITUICOES PUBLICAS" } )
	aAdd( aDadAUx, { "DR", "24580110", "TRANSFERENCIAS DE OUTRAS INSTITUICOES PUBLICAS" } )
	aAdd( aDadAUx, { "DR", "24680000", "TRANSFERENCIAS DO EXTERIOR - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "24680100", "TRANSFERENCIAS DO EXTERIOR PARA PROGRAMAS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "24680110", "TRANSFERENCIAS DO EXTERIOR PARA PROGRAMAS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "24680120", "TRANSFERENCIAS DO EXTERIOR PARA PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "24680190", "OUTRAS TRANSFERENCIAS DO EXTERIOR NAO ESPECIFICADAS ANTERIORMENTE" } )
	aAdd( aDadAUx, { "DR", "24780000", "PROVENIENTES DE PESSOAS FISICAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "24780100", "TRANSFERENCIAS DE PESSOAS FISICAS PARA PROGRAMAS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "24780110", "TRANSFERENCIAS DE PESSOAS FISICAS PARA PROGRAMAS DE SAUDE" } )
	aAdd( aDadAUx, { "DR", "24780120", "TRANSFERENCIAS DE PESSOAS FISICAS PARA PROGRAMAS DE EDUCACAO" } )
	aAdd( aDadAUx, { "DR", "24780190", "OUTRAS TRANSFERENCIAS DE PESSOAS FISICAS NAO ESPECIFICADAS ANTERIORMENTE" } )
	aAdd( aDadAUx, { "DR", "24880000", "TRANSFERENCIAS PROVENIENTES DE DEPOSITO NAO IDENTIFICADOS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS" } )
	aAdd( aDadAUx, { "DR", "24880100", "TRANSFERENCIAS PROVENIENTES DE DEPOSITO NAO IDENTIFICADOS" } )
	aAdd( aDadAUx, { "DR", "24880110", "TRANSFERENCIAS PROVENIENTES DE DEPOSITO NAO IDENTIFICADOS" } )
	aAdd( aDadAUx, { "DR", "29100010", "INTEGRALIZACAO DE CAPITAL SOCIAL" } )
	aAdd( aDadAUx, { "DR", "29900010", "DEMAIS RECEITAS DE CAPITAL" } )
	aAdd( aDadAUx, { "DR", "29980000", "RECEITAS DE ALIENACAO DE CERTIFICADOS DE POTENCIAL ADICIONAL DE CONSTRUCAO - CEPAC" } )
	aAdd( aDadAUx, { "DR", "29980100", "DEMAIS RECEITAS DE CAPITAL ESPECIFICAS DE E/DF/M" } )
	aAdd( aDadAUx, { "DR", "29980110", "RECEITAS DE ALIENACAO DE CERTIFICADOS DE POTENCIAL ADICIONAL DE CONSTRUCAO - CEPAC" } )
	aAdd( aDadAUx, { "DR", "71120000", "IMPOSTOS SOBRE O PATRIMONIO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71120100", "IMPOSTO SOBRE A PROPRIEDADE TERRITORIAL RURAL - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71120110", "IMPOSTO SOBRE A PROPRIEDADE TERRITORIAL RURAL - MUNICIPIOS CONVENIADOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71130000", "IMPOSTOS SOBRE A RENDA E PROVENTOS DE QUALQUER NATUREZA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71130300", "IMPOSTO SOBRE A RENDA - RETIDO NA FONTE - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71130310", "IMPOSTO SOBRE A RENDA - RETIDO NA FONTE - TRABALHO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71130320", "IMPOSTO SOBRE A RENDA - RETIDO NA FONTE - CAPITAL - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71130340", "IMPOSTO SOBRE A RENDA - RETIDO NA FONTE - OUTROS RENDIMENTOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71180000", "IMPOSTOS - ESPECIFICOS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71180100", "IMPOSTOS SOBRE O PATRIMONIO PARA ESTADOS, DF E MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71180110", "IMPOSTO SOBRE A PROPRIEDADE PREDIAL E TERRITORIAL URBANA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71180140", "IMPOSTO SOBRE TRANSMISSAO (INTERVIVOS) DE BENS IMOVEIS E DE DIREITOS REAIS SOBRE IMOVEIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71180200", "IMPOSTOS SOBRE A PRODUCAO, CIRCULACAO DE MERCADORIAS E SERVICOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71180230", "IMPOSTO SOBRE SERVICOS DE QUALQUER NATUREZA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71180240", "ADICIONAL ISS - FUNDO MUNICIPAL DE COMBATE A POBREZA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71180250", "IMPOSTO SOBRE VENDAS A VAREJO DE COMBUSTIVEIS LIQUIDOS E GASOSOS (IVVC) - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71190000", "OUTROS IMPOSTOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71190100", "OUTROS IMPOSTOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71190110", "OUTROS IMPOSTOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71280000", "TAXAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71280100", "TAXAS DE INSPECAO, CONTROLE E FISCALIZACAO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71280110", "TAXA DE FISCALIZACAO DE VIGILANCIA SANITARIA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71280190", "TAXAS DE INSPECAO, CONTROLE E FISCALIZACAO - OUTRAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71280200", "TAXAS PELA PRESTACAO DE SERVICOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71280230", "TAXA DE ESTUDO DE IMPACTO DE VIZINHANCA (EIV) - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71280290", "TAXAS PELA PRESTACAO DE SERVICOS - OUTRAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71380000", "CONTRIBUICAO DE MELHORIA - ESPECIFICA DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71380100", "CONTRIBUICAO DE MELHORIA PARA EXPANSAO DA REDE DE AGUA POTAVEL E ESGOTO SANITARIO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71380110", "CONTRIBUICAO DE MELHORIA PARA EXPANSAO DA REDE DE AGUA POTAVEL E ESGOTO SANITARIO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71380200", "CONTRIBUICAO DE MELHORIA PARA EXPANSAO DA REDE DE ILUMINACAO PUBLICA NA CIDADE - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71380210", "CONTRIBUICAO DE MELHORIA PARA EXPANSAO DA REDE DE ILUMINACAO PUBLICA NA CIDADE - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71380300", "CONTRIBUICAO DE MELHORIA PARA EXPANSAO DE REDE DE ILUMINACAO PUBLICA RURAL - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71380310", "CONTRIBUICAO DE MELHORIA PARA EXPANSAO DE REDE DE ILUMINACAO PUBLICA RURAL - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71380400", "CONTRIBUICAO DE MELHORIA PARA PAVIMENTACAO E OBRAS COMPLEMENTARES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71380410", "CONTRIBUICAO DE MELHORIA PARA PAVIMENTACAO E OBRAS COMPLEMENTARES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71389900", "OUTRAS CONTRIBUICOES DE MELHORIA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "71389910", "OUTRAS CONTRIBUICOES DE MELHORIA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72160000", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72160300", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - SERVIDORES CIVIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72160310", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - SERVIDORES CIVIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72160320", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - SERVIDORES CIVIS - PARCELAMENTOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72160400", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - OUTROS BENEFICIARIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72160410", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - OUTROS BENEFICIARIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72160420", "CONTRIBUICAO PARA FUNDOS DE ASSISTENCIA MEDICA - OUTROS BENEFICIARIOS - PARCELAMENTOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180000", "CONTRIBUICOES SOCIAIS ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180300", "CPSSS PATRONAL - SERVIDOR CIVIL - ESPECIFICA DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180310", "CPSSS PATRONAL - SERVIDOR CIVIL ATIVO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180320", "CPSSS PATRONAL - SERVIDOR CIVIL INATIVO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180330", "CPSSS PATRONAL - SERVIDOR CIVIL - PENSIONISTAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180340", "CPSSS PATRONAL - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL ATIVO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180350", "CPSSS PATRONAL - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL INATIVO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180360", "CPSSS PATRONAL - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL - PENSIONISTAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180400", "CPSSS PATRONAL - PARCELAMENTOS - ESPECIFICA DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180410", "CPSSS PATRONAL - PARCELAMENTOS - SERVIDOR CIVIL ATIVO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180420", "CPSSS PATRONAL - PARCELAMENTOS - SERVIDOR CIVIL INATIVO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180430", "CPSSS PATRONAL - PARCELAMENTOS - SERVIDOR CIVIL - PENSIONISTAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180440", "CPSSS PATRONAL - PARCELAMENTOS - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL ATIVO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180450", "CPSSS PATRONAL - PARCELAMENTOS - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL INATIVO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72180460", "CPSSS PATRONAL - PARCELAMENTOS - ORIUNDA DE SENTENCAS JUDICIAIS - SERVIDOR CIVIL - PENSIONISTAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72190000", "OUTRAS CONTRIBUICOES SOCIAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72199900", "DEMAIS CONTRIBUICOES SOCIAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72199910", "DEMAIS CONTRIBUICOES SOCIAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72199920", "DEMAIS CONTRIBUICOES SOCIAIS - PARCELAMENTOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72209900", "OUTRAS CONTRIBUICOES ECONOMICAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72209910", "OUTRAS CONTRIBUICOES ECONOMICAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "72400010", "CONTRIBUICAO PARA O CUSTEIO DO SERVICO DE ILUMINACAO PUBLICA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73100100", "ALUGUEIS, ARRENDAMENTOS, FOROS, LAUDEMIOS, TARIFAS DE OCUPACAO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73100110", "ALUGUEIS E ARRENDAMENTOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73100120", "FOROS, LAUDEMIOS E TARIFAS DE OCUPACAO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73100200", "CONCESSAO, PERMISSAO, AUTORIZACAO OU CESSAO DO DIREITO DE USO DE BENS IMOVEIS PUBLICOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73100210", "CONCESSAO, PERMISSAO, AUTORIZACAO OU CESSAO DO DIREITO DE USO DE BENS IMOVEIS PUBLICOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73109900", "OUTRAS RECEITAS IMOBILIARIAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73109910", "OUTRAS RECEITAS IMOBILIARIAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73220000", "DIVIDENDOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73220010", "DIVIDENDOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73230000", "PARTICIPACOES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73230010", "PARTICIPACOES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73290000", "OUTROS VALORES MOBILIARIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73290010", "OUTROS VALORES MOBILIARIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73390000", "DEMAIS DELEGACOES DE SERVICOS PUBLICOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73399900", "OUTRAS DELEGACOES DE SERVICOS PUBLICOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73399910", "OUTRAS DELEGACOES DE SERVICOS PUBLICOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73490000", "EXPLORACAO DE OUTROS RECURSOS NATURAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73499900", "OUTRAS DELEGACOES PARA EXPLORACAO DE RECURSOS NATURAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73499910", "OUTRAS DELEGACOES PARA EXPLORACAO DE RECURSOS NATURAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73500100", "OUTORGA DE DIREITO DE USO OU DE EXPLORACAO DE CRIACAO PROTEGIDA - INSTITUICAO CIENTIFICA E TECNOLOGICA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73500110", "OUTORGA DE DIREITO DE USO OU DE EXPLORACAO DE CRIACAO PROTEGIDA - INSTITUICAO CIENTIFICA E TECNOLOGICA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73500200", "DIREITO DE USO DA IMAGEM E DE REPRODUCAO DOS BENS DO ACERVO PATRIMONIAL - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73500210", "DIREITO DE USO DA IMAGEM E DE REPRODUCAO DOS BENS DO ACERVO PATRIMONIAL - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73500400", "ROYALTIES PELA COMERCIALIZACAO DE PRODUTOS RESULTANTES DE CRIACAO PROTEGIDA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73500410", "ROYALTIES PELA COMERCIALIZACAO DE PRODUTOS RESULTANTES DE CRIACAO PROTEGIDA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "73900010", "DEMAIS RECEITAS PATRIMONIAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "74000010", "RECEITA AGROPECUARIA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "75000010", "RECEITA INDUSTRIAL - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76100100", "SERVICOS ADMINISTRATIVOS E COMERCIAIS GERAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76100110", "SERVICOS ADMINISTRATIVOS E COMERCIAIS GERAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76100200", "INSCRICAO EM CONCURSOS E PROCESSOS SELETIVOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76100210", "INSCRICAO EM CONCURSOS E PROCESSOS SELETIVOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76100300", "SERVICOS DE REGISTRO, CERTIFICACAO E FISCALIZACAO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76100310", "SERVICOS DE REGISTRO, CERTIFICACAO E FISCALIZACAO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76100400", "SERVICOS DE INFORMACAO E TECNOLOGIA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76100410", "SERVICOS DE INFORMACAO E TECNOLOGIA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76200100", "SERVICOS DE NAVEGACAO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76200110", "SERVICOS DE NAVEGACAO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76200200", "SERVICOS DE TRANSPORTE - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76200210", "SERVICOS DE TRANSPORTE - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76200300", "SERVICOS PORTUARIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76200310", "SERVICOS PORTUARIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76200400", "SERVICOS AEROPORTUARIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76200410", "TARIFA AEROPORTUARIA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76380000", "SERVICOS E ATIVIDADES REFERENTES A SAUDE - ESPECIFICO DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76380100", "SERVICOS DE SAUDE - ESPECIFICO DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76380110", "SERVICOS HOSPITALARES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76380120", "SERVICOS DE REGISTRO DE ANALISE E DE CONTROLE - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76380130", "SERVICOS RADIOLOGICOS E LABORATORIAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76380140", "SERVICOS AMBULATORIAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76380190", "OUTROS SERVICOS DE SAUDE - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76400100", "RETORNO DE OPERACOES, JUROS E ENCARGOS FINANCEIROS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76400110", "RETORNO DE OPERACOES, JUROS E ENCARGOS FINANCEIROS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76909900", "OUTROS SERVICOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "76909910", "OUTROS SERVICOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "77380000", "TRANSFERENCIAS DOS MUNICIPIOS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "77380100", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "77380110", "TRANSFERENCIAS DE RECURSOS DO SISTEMA UNICO DE SAUDE - SUS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "77381000", "TRANSFERENCIA DE CONVENIOS DOS MUNICIPIOS E DE SUAS ENTIDADES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "77381010", "TRANSFERENCIAS DE CONVENIO DOS MUNICIPIOS PARA O SISTEMA UNICO DE SAUDE - SUS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "77381020", "TRANSFERENCIAS DE CONVENIO DOS MUNICIPIOS DESTINADAS A PROGRAMAS DE EDUCACAO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "77381090", "OUTRAS TRANSFERENCIAS DE CONVENIOS DOS MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "77389900", "OUTRAS TRANSFERENCIAS DOS MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "77389910", "OUTRAS TRANSFERENCIAS DOS MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "77500010", "TRANSFERENCIAS DE OUTRAS INSTITUICOES PUBLICAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79100100", "MULTAS PREVISTAS EM LEGISLACAO ESPECIFICA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79100110", "MULTAS PREVISTAS EM LEGISLACAO ESPECIFICA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79100600", "MULTAS POR DANOS AMBIENTAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79100610", "MULTAS ADMINISTRATIVAS POR DANOS AMBIENTAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79100620", "MULTAS JUDICIAIS POR DANOS AMBIENTAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79100800", "MULTAS DECORRENTES DE SENTENCAS JUDICIAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79100810", "MULTAS DECORRENTES DE SENTENCAS JUDICIAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79100900", "MULTAS E JUROS PREVISTOS EM CONTRATOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79100910", "MULTAS E JUROS PREVISTOS EM CONTRATOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79210000", "INDENIZACOES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79210100", "INDENIZACOES POR DANOS CAUSADOS AO PATRIMONIO PUBLICO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79210110", "INDENIZACOES POR DANOS CAUSADOS AO PATRIMONIO PUBLICO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79210200", "INDENIZACAO POR POSSE OU OCUPACAO ILICITA DE BENS PUBLICOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79210210", "INDENIZACAO POR POSSE OU OCUPACAO ILICITA DE BENS PUBLICOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79210300", "INDENIZACAO POR SINISTRO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79210310", "INDENIZACAO POR SINISTRO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220000", "RESTITUICOES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220100", "RESTITUICAO DE CONVENIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220110", "RESTITUICAO DE CONVENIOS - PRIMARIAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220120", "RESTITUICAO DE CONVENIOS - FINANCEIRAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220200", "RESTITUICAO DE BENEFICIOS NAO DESEMBOLSADOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220210", "RESTITUICAO DE BENEFICIOS NAO DESEMBOLSADOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220300", "RESTITUICAO DE BENEFICIOS PREVIDENCIARIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220310", "RESTITUICAO DE BENEFICIOS PREVIDENCIARIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220500", "RESTITUICAO DE CONTRIBUICOES PREVIDENCIARIAS COMPLEMENTARES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220510", "RESTITUICAO DE CONTRIBUICOES PREVIDENCIARIAS COMPLEMENTARES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220600", "RESTITUICAO DE DESPESAS DE EXERCICIOS ANTERIORES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220610", "RESTITUICAO DE DESPESAS DE EXERCICIOS ANTERIORES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220900", "RESTITUICAO DE RECURSOS DE FOMENTO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79220910", "RESTITUICAO DE RECURSOS DE FOMENTO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79280000", "INDENIZACOES, RESTITUICOES E RESSARCIMENTOS  - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79280100", "INDENIZACOES - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79280110", "INDENIZACOES - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79280200", "RESTITUICOES - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79280210", "RESTITUICOES DE RECURSOS RECEBIDOS DO SUS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79280290", "OUTRAS RESTITUICOES - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - NAO ESPECIFICADAS ANTERIORMENTE - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79280300", "RESSARCIMENTOS - ESPECIFICOS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79280310", "RESSARCIMENTOS - ESPECIFICOS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79300100", "BENS, DIREITOS E VALORES PERDIDOS EM FAVOR DO PODER PUBLICO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79300110", "BENS, DIREITOS E VALORES PERDIDOS EM FAVOR DO PODER PUBLICO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79300200", "ALIENACAO DE BENS APREENDIDOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79300210", "ALIENACAO DE BENS E MERCADORIAS APREENDIDOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79300220", "ALIENACAO DE BENS E MERCADORIAS ASSOCIADOS AO TRAFICO ILICITO DE ENTORPECENTES E DROGAS AFINS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79300300", "DEPOSITOS ABANDONADOS (DINHEIRO E/OU OBJETOS DE VALOR) - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79300310", "DEPOSITOS ABANDONADOS (DINHEIRO E/OU OBJETOS DE VALOR) - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79300500", "RECEITAS RECONHECIDAS POR FORCA DE DECISOES JUDICIAIS E DE TRIBUNAIS ADMINISTRATIVOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79300510", "RECEITAS RECONHECIDAS POR FORCA DE DECISOES JUDICIAIS E DE TRIBUNAIS ADMINISTRATIVOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79900100", "APORTES PERIODICOS PARA AMORTIZACAO DE DEFICIT ATUARIAL DO RPPS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79900110", "APORTES PERIODICOS PARA AMORTIZACAO DE DEFICIT ATUARIAL DO RPPS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79900300", "COMPENSACOES FINANCEIRAS ENTRE O REGIME GERAL E OS REGIMES PROPRIOS DE PREVIDENCIA DOS SERVIDORES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79900310", "COMPENSACOES FINANCEIRAS ENTRE O REGIME GERAL E OS REGIMES PROPRIOS DE PREVIDENCIA DOS SERVIDORES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79900600", "CONTRAPARTIDA DE SUBVENCOES OU SUBSIDIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79900610", "CONTRAPARTIDA DE SUBVENCOES OU SUBSIDIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79901200", "ENCARGOS LEGAIS PELA INSCRICAO EM DIVIDA ATIVA E RECEITAS DE ONUS DE SUCUMBENCIA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79901220", "ONUS DE SUCUMBENCIA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79909900", "OUTRAS RECEITAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79909910", "OUTRAS RECEITAS - PRIMARIAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "79909920", "OUTRAS RECEITAS - FINANCEIRAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "81180000", "OPERACOES DE CREDITO - MERCADO INTERNO - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "81180100", "OPERACOES DE CREDITO INTERNAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "81180110", "OPERACOES DE CREDITO INTERNAS PARA PROGRAMAS DE EDUCACAO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "81180120", "OPERACOES DE CREDITO INTERNAS PARA PROGRAMAS DE SAUDE - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "81180130", "OPERACOES DE CREDITO INTERNAS PARA PROGRAMAS DE SANEAMENTO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "81180140", "OPERACOES DE CREDITO INTERNAS PARA PROGRAMAS DE MEIO AMBIENTE - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "81180150", "OPERACOES DE CREDITO INTERNAS PARA PROGRAMAS DE MODERNIZACAO DA ADMINISTRACAO PUBLICA - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "81180160", "OPERACOES DE CREDITO INTERNAS PARA REFINANCIAMENTO DA DIVIDA CONTRATUAL - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "81180170", "OPERACOES DE CREDITO INTERNAS PARA PROGRAMAS DE MORADIA POPULAR - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "81190000", "OUTRAS OPERACOES DE CREDITO - MERCADO INTERNO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "81190010", "OUTRAS OPERACOES DE CREDITO - MERCADO INTERNO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "82130000", "ALIENACAO DE BENS MOVEIS E SEMOVENTES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "82130010", "ALIENACAO DE BENS MOVEIS E SEMOVENTES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "82180000", "ALIENACAO DE BENS MOVEIS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "82180100", "ALIENACAO DE TITULOS MOBILIARIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "82180110", "ALIENACAO DE INVESTIMENTOS TEMPORARIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "82180120", "ALIENACAO DE INVESTIMENTOS PERMANENTES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "82200010", "ALIENACAO DE BENS IMOVEIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "82300010", "ALIENACAO DE BENS INTANGIVEIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "83000600", "AMORTIZACAO DE EMPRESTIMOS CONTRATUAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "83000610", "AMORTIZACAO DE EMPRESTIMOS CONTRATUAIS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "83000700", "AMORTIZACAO DE FINANCIAMENTOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "83000710", "AMORTIZACAO DE FINANCIAMENTOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "84380000", "TRANSFERENCIAS DOS MUNICIPIOS E DE SUAS ENTIDADES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "84381000", "TRANSFERENCIAS DE CONVENIOS DOS MUNICIPIOS E DE SUAS ENTIDADES - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "84381010", "TRANSFERENCIAS DE CONVENIOS DOS MUNICIPIOS DESTINADOS A PROGRAMAS DE SAUDE - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "84381020", "TRANSFERENCIAS DE CONVENIOS DOS MUNICIPIOS DESTINADAS A PROGRAMAS DE EDUCACAO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "84381030", "TRANSFERENCIAS DE CONVENIOS DOS MUNICIPIOS DESTINADAS A PROGRAMAS DE SANEAMENTO - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "84381090", "OUTRAS TRANSFERENCIAS DE CONVENIOS DOS MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "84389900", "OUTRAS TRANSFERENCIAS DOS MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "84389910", "OUTRAS TRANSFERENCIAS DOS MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "84580000", "TRANSFERENCIAS DE OUTRAS INSTITUICOES PUBLICAS - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "84580100", "TRANSFERENCIAS DE OUTRAS INSTITUICOES PUBLICAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "84580110", "TRANSFERENCIAS DE OUTRAS INSTITUICOES PUBLICAS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "89100010", "INTEGRALIZACAO DE CAPITAL SOCIAL - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "89900010", "DEMAIS RECEITAS DE CAPITAL - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "89980000", "RECEITAS DE ALIENACAO DE CERTIFICADOS DE POTENCIAL ADICIONAL DE CONSTRUCAO - CEPAC - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "89980100", "DEMAIS RECEITAS DE CAPITAL - ESPECIFICAS DE ESTADOS, DF, MUNICIPIOS - INTRA OFSS" } )
	aAdd( aDadAUx, { "DR", "89980110", "RECEITAS DE ALIENACAO DE CERTIFICADOS DE POTENCIAL ADICIONAL DE CONSTRUCAO - CEPAC - INTRA OFSS" } )

	aCposDet := {}

	For nX := 1 To Len(aDadAUx)		
		aAUx := {}
		aAdd( aAUx, { "A1H_ITETAB" , StrZero(nX, 4)} )
		aAdd( aAUx, { "A1H_RADCHV", aDadAUx[nX,1] } )
		aAdd( aAUx, { "A1H_ITECHV", aDadAUx[nX,2] } )
		If Len(aDadAUx[nX,3]) <= TamSx3("A1H_CHVCNT")[1]
			aAdd( aAUx, { "A1H_CHVCNT", aDadAUx[nX,3] } )
		Else
			aAdd( aAUx, { "A1H_CHVCNT", SUbs(aDadAUx[nX,3],1,TamSx3("A1H_CHVCNT")[1]-3)+"..." } )		
		EndIf
		
		aAdd( aCposDet, aAUx )	
	Next nX
	
	If !Tbl_Imp("A1G", "A1H", aCposCab, aCposDet )
		lRet := .F.
	EndIf

EndIf

RetUrn lRet