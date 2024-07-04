#INCLUDE "JURA184.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA184
Parte Contraria

@author Rafael Telles de Macedo
@since 04/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA184()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0007 )
oBrowse:SetAlias( "NZ2" )
oBrowse:SetLocate()
oBrowse:Activate()

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu Funcional

@return aRotina - Estrutura
[n,1] Nome a aparecer no cabecalho
[n,2] Nome da Rotina associada
[n,3] Reservado
[n,4] Tipo de Transação a ser efetuada:
1 - Pesquisa e Posiciona em um Banco de Dados
2 - Simplesmente Mostra os Campos
3 - Inclui registros no Bancos de Dados
4 - Altera o registro corrente
5 - Remove o registro corrente do Banco de Dados
6 - Alteração sem inclusão de registros
7 - Cópia
8 - Imprimir
[n,5] Nivel de acesso
[n,6] Habilita Menu Funcional

@author Rafael Telles de Macedo
@since 04/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0001, "PesqBrw"        , 0, 1, 0, .T. } ) //"Pesquisar"
aAdd( aRotina, { STR0002, "VIEWDEF.JURA184", 0, 2, 0, NIL } ) //"Visualizar"
aAdd( aRotina, { STR0003, "VIEWDEF.JURA184", 0, 3, 0, NIL } ) //"Incluir"
aAdd( aRotina, { STR0004, "VIEWDEF.JURA184", 0, 4, 0, NIL } ) //"Alterar"
aAdd( aRotina, { STR0005, "VIEWDEF.JURA184", 0, 5, 0, NIL } ) //"Excluir"
aAdd( aRotina, { STR0006, "VIEWDEF.JURA184", 0, 8, 0, NIL } ) //"Imprimir"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Parte Contraria

@author Rafael Telles de Macedo
@since 04/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  := FWLoadModel( "JURA184" )
Local oStructNZ2 := FWFormStruct( 2, "NZ2" )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:AddField( "JURA184_VIEW", oStructNZ2, "NZ2MASTER"  )
oView:CreateHorizontalBox( "FORMFIELD", 100 )
oView:SetOwnerView( "JURA184_VIEW", "FORMFIELD" )
oView:SetDescription( STR0007 ) //"Partes Contrárias"
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Parte Contraria

@author Rafael Telles de Macedo
@since 04/12/2014
@version 1.0

@obs NZ2MASTER - Dados de Parte Contraria
/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel     := NIL
Local oStructNZ2 := FWFormStruct( 1, "NZ2" )

//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA184", /*Pre-Validacao*/, /*Pos-Validacao*/,{|oX| JA184CMT(oX) }/*Commit*/,/*Cancel*/)
oModel:AddFields( "NZ2MASTER", NIL, oStructNZ2, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 ) //"Modelo de Dados de Partes Contrárias"
oModel:GetModel( "NZ2MASTER" ):SetDescription( STR0007 ) //"Dados de Natureza Juridica"

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} J184VLDCGC
Permite preencher o campo CNPJ/CPF com 0.

@author Rafael Telles de Macedo
@since 04/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Function J184VLDCGC(cCGC)
Local lRet := .F.

cCGC := AllTrim(cCGC)

If Empty(cCGC)
	lRet := .T.
ElseIf cCGC == "00000000000"
	lRet := .T.
Elseif cCGC == "00000000000000"
	lRet := .T.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JUR184CGC
Verifica se o envolvido é pessoa física ou jurídica para inclusão de máscara
no campo de CNPJ/CPF
Uso no cadastro de Envolvidos

@Return cRet			Máscara para o campo de CNPJ/CPF

@author Rafael Telles de Macedo
@since 04/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Function JUR184CGC()
Local cRet   := ''
Local cTipo  := ""
Local oModel := FwModelActive()

If VALTYPE(oModel) == "O" .AND. oModel:GetID() == "JURA184" .AND. oModel:IsActive()
	cTipo  := FWFldGet('NZ2_TIPOP')
EndIf

If EMPTY(cTipo)
	cTipo := IIF( VALTYPE(M->NZ2_TIPOP) <> "U", M->NZ2_TIPOP, "" )
EndIf

cRet:= JURM1(cTipo)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA184CMT
Função utilizada no commit do modelo de partes contrárias,
para atualizar o cadastro em outros itens da NT9.

@Return lRet

@author André Spirigoni Pinto
@since 09/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA184CMT( oModel )
Local nOpc      := oModel:GetOperation()
Local lReturn   := .T.

//Realiza a Gravaca do Model
FwFormCommit( oModel )

//Realiza apenas quando for atualização do modelo
If ( nOpc == MODEL_OPERATION_UPDATE )
	Processa({|| J184Update(oModel) },STR0009) //"Atualização dos registros"
Endif

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} J184Update
Função que atualiza o cadastro de todas as partes contrárias quando
alguma campo é atualizado. Assim, os registros da NT9 ficam com a
mesma informação

@Return cRet			Máscara para o campo de CNPJ/CPF

@author André Spirigoni Pinto
@since 04/12/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Function J184Update(oModel)
Local aArea     := GetArea()
Local aAreaNT9  := NT9->( GetArea() )
Local cAlQry
Local cSql      := ""
Local nI
Local nQtd      := 0
//Campos de de/para da NT9 com a NZ2.
Local aCampNT9  := {"NT9_NOME","NT9_CGC","NT9_DDD","NT9_TELEFO","NT9_EMAIL","NT9_CMUNIC","NT9_RG","NT9_ESTADO","NT9_BAIRRO","NT9_INSCR","NT9_INSCRM","NT9_CESTCV","NT9_DTADM","NT9_DTNASC","NT9_DTDEMI","NT9_CTPS","NT9_SERIE","NT9_VLRUSA","NT9_PIS","NT9_CCRGDP","NT9_CFUNDP","NT9_TIPOP"}
Local aCampDest := {"NZ2_NOME","NZ2_CGC","NZ2_DDD","NZ2_TELEFO","NZ2_EMAIL","NZ2_CMUNIC","NZ2_RG","NZ2_ESTADO","NZ2_BAIRRO","","","","","","","","","","","","","NZ2_TIPOP"}

//Monta o sql que vai buscar todos os registros da NT9 que possuem a mesma parte contrária cadastrada
cSql := " SELECT NT9_FILIAL, NT9_COD FROM " + RetSqlName("NT9") + " NT9" + CRLF
cSql += " WHERE NT9_FILIAL = '" + oModel:GetValue('NZ2MASTER','NZ2_FILIAL') + "'" + CRLF
cSql += " AND NT9_ENTIDA = 'NZ2' AND NT9_CODENT = '" + oModel:GetValue('NZ2MASTER','NZ2_COD') + "'" + CRLF
cSql += " AND D_E_L_E_T_ = ' '" + CRLF
cSql += " AND EXISTS (SELECT 1 FROM " + RetSqlName("NSZ") + " NSZ" + CRLF
cSql += " WHERE NSZ_FILIAL = NT9.NT9_FILIAL AND NSZ_COD = NT9.NT9_CAJURI AND D_E_L_E_T_ = ' ' AND NSZ_SITUAC='1') " + CRLF

cSql := ChangeQuery(cSql, .F.)

cAlQry := GetNextAlias()
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),cAlQry,.T.,.T.)

NT9->( dbSetOrder( 1 ) )

While !(cAlQry)->( EOF() )
	NT9->( dbSeek( xFilial( 'NT9' ) + (cAlQry)->NT9_COD) )
	RecLock('NT9', .F.)
	For nI := 1 to len(aCampNT9)
		//Valida se existe um campo de de/para e se o campo da NZ2 foi atualizado.
		If !Empty(aCampDest[nI]) .And. oModel:IsFieldUpdated("NZ2MASTER",aCampDest[nI])
			//Valida se o campo foi alterado para não fazer a busca em todos.
			If NT9->&(aCampNT9[nI]) != oModel:GetValue("NZ2MASTER",aCampDest[nI])
				NT9->&(aCampNT9[nI]) := oModel:GetValue("NZ2MASTER",aCampDest[nI])
			Endif
		Endif
	Next
	MsUnlock()
	nQtd++

	IncProc(I18N(STR0010,{AllTrim(str(nQtd))} )) //"Registros alterados: #1"

	(cAlQry)->(dbSkip())
End

(cAlQry)->( dbcloseArea() )

NT9->( RestArea( aAreaNT9 ) )
RestArea( aArea )

Return .T.
