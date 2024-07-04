#INCLUDE "JURA059.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PARMTYPE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} JURA059
Índice

@author Juliana Iwayama Velho
@since 06/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Function JURA059()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetDescription( STR0001 ) //"ìndice
oBrowse:SetAlias( "NW5" )
oBrowse:SetLocate()
JurSetLeg( oBrowse, "NW5" )
JurSetBSize( oBrowse )
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

@author Juliana Iwayama Velho
@since 06/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}
Local aCorr   := {}
Local aInd    := {}
Local lAnoMes := (SuperGetMV('MV_JVLHIST',, '2') == '1')

	aAdd( aRotina, { STR0002, "PesqBrw"        , 0, 1, 0, .T. } )  //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.JURA059", 0, 2, 0, NIL } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.JURA059", 0, 3, 0, NIL } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.JURA059", 0, 4, 0, NIL } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.JURA059", 0, 5, 0, NIL } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.JURA059", 0, 8, 0, NIL } ) //"Imprimir"
	aAdd( aRotina, { STR0010, "JA059CONFG"     , 0, 3, 0, NIL } ) //"Config. Inicial"

	If lAnoMes
		aAdd( aRotina, { STR0013, aCorr			   , 0, 1, 0, .T. } ) //"Correção Valores"
		aAdd( aCorr,   { STR0013, "Processa({|| JA059CALC(NW5->NW5_COD) },'" + STR0015 + "')"     , 0, 3, 0, NIL } ) //"Correção Valores"
		aAdd( aCorr,   { STR0014, "Processa({|| JA059CALC(NW5->NW5_COD,.T.) },'" + STR0015 + "')"     , 0, 3, 0, NIL } ) //"Recálculo"
	EndIf

	aAdd( aRotina, { STR0022, aInd			   , 0, 1, 0, .T. } ) //"Obter atualizações TOTVS"
	aAdd( aInd,    { STR0023, "Processa({|| JA216AtuAut(NW5->NW5_COD) })" , 0, 4, 0, NIL } ) //"Atualiza índice selecionado"
	aAdd( aInd,    { STR0024, "Processa({|| JA216AtuAut() })" , 0, 3, 0, NIL } ) //"Atualiza todos"

Return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
View de dados de Índice

@author Juliana Iwayama Velho
@since 06/01/10
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oView
Local oModel  	:= FWLoadModel( "JURA059" )
Local oStruct 	:= FWFormStruct( 2, "NW5" )
Local lNZWInDic := FWAliasInDic("NZW")

JurSetAgrp( "NW5",, oStruct )

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( "JURA059", oStruct, "NW5MASTER"  )
oView:CreateHorizontalBox( "NW5MASTER" , 100 )
oView:SetOwnerView( "JURA059", "NW5MASTER" )
If lNZWInDic
	oView:AddUserButton( STR0022, "BUDGET", {| oView | JA216AtuAut(NW5->NW5_DESC) } ) // "Obter atualizações TOTVS"
EndIf

oView:SetDescription( STR0001 )
oView:EnableControlBar( .T. )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de dados de Índice

@author Juliana Iwayama Velho
@since 06/01/10
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function Modeldef()
Local oModel  := NIL
Local oStruct := FWFormStruct( 1, "NW5" )
//-----------------------------------------
//Monta o modelo do formulário
//-----------------------------------------
oModel:= MPFormModel():New( "JURA059", /*Pre-Validacao*/, /*Pos-Validacao*/, /*Commit*/,/*Cancel*/)
oModel:AddFields( "NW5MASTER", NIL, oStruct, /*Pre-Validacao*/, /*Pos-Validacao*/ )
oModel:SetDescription( STR0008 )

oModel:GetModel( "NW5MASTER" ):SetDescription( STR0009 )

JurSetRules( oModel, "NW5MASTER",, "NW5" )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} JA059CONFG
Realiza a carga inicial da configuração de índices

@Return lRet	 	.T./.F. As informações são válidas ou não

@author Juliana Iwayama Velho
@since 05/03/10
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA059CONFG()
Local lRet     := .T.
Local aArea    := GetArea()
Local aAreaNW5 := NW5->( GetArea() )
Local oModel   := ModelDef()
Local aDados   := {}
Local aErro    := {}
Local nI       := 0
Local lExiste  := .F.

dbSelectArea( 'NW5' )
NW5->(dbSetOrder(1))
NW5->(dbGoTop())

aAdd( aDados, { '01', 'TJ'        , '2', '2' } )
aAdd( aDados, { '02', 'IGPM'      , '2', '2' } )
aAdd( aDados, { '03', 'TR'        , '2', '2' } )
aAdd( aDados, { '04', 'UFIR'      , '2', '2' } )
aAdd( aDados, { '05', 'SELIC'     , '2', '1' } )
aAdd( aDados, { '06', 'TRT02'     , '2', '2' } )
aAdd( aDados, { '07', 'UFESP'     , '2', '2' } )
aAdd( aDados, { '08', 'IPCA'      , '2', '2' } )
aAdd( aDados, { '09', 'IPCA-E'    , '2', '1' } )
aAdd( aDados, { '10', 'INPC'      , '2', '2' } )
aAdd( aDados, { '11', 'JF-CondGer', '2', '2' } )
aAdd( aDados, { '12', 'JF-CGSelic', '2', '1' } )
aAdd( aDados, { '13', 'JF-IndTrib', '2', '2' } )
aAdd( aDados, { '14', 'JF-ITSelic', '2', '1' } )
aAdd( aDados, { '15', 'JF-Previde', '2', '2' } )
aAdd( aDados, { '16', 'JF-Desapro', '2', '2' } )
aAdd( aDados, { '17', 'Selic-Fed' , '2', '2' } )
aAdd( aDados, { '18', 'INPC-IBGE' , '2', '1' } )
aAdd( aDados, { '19', 'IGPM-Acum' , '2', '1' } )
aAdd( aDados, { '20', 'IndebSelic', '2', '2' } )
aAdd( aDados, { '21', 'CondGSelic', '2', '2' } )
aAdd( aDados, { '22', 'UFIR-RJ'   , '2', '2' } )
aAdd( aDados, { '23', 'IPCA-Acum' , '2', '1' } )
aAdd( aDados, { '24', 'SelicAutSP', '2', '1' } )
aAdd( aDados, { '25', 'SelicSP'   , '2', '1' } )
aAdd( aDados, { '26', 'IPCA-AC18' , '2', '2' } )
aAdd( aDados, { '27', 'IGP-DI'    , '2', '1' } )
aAdd( aDados, { '28', 'SELIC-MG'  , '2', '1' } )
aAdd( aDados, { '29', 'IGP-DI-GO' , '2', '1' } )
aAdd( aDados, { '34', 'TJ-MG'     , '2', '1' } )
aAdd( aDados, { '39', 'TJ PR'     , '2', '2' } )
aAdd( aDados, { '40', 'TJ RJ'     , '2', '2' } )
aAdd( aDados, { '41', 'TJ ES'     , '2', '2' } )
aAdd( aDados, { '42', 'TJ DF'     , '2', '2' } )
aAdd( aDados, { '50', 'TJ-GO'     , '2', '1' } )
aAdd( aDados, { '51', 'TR e IPCAE', '2', '1' } )
aAdd( aDados, { '52', 'TJ-CE'     , '2', '1' } )

oModel:SetOperation( 3 ) // Operação deseja: 3 – Inclusão / 4 – Alteração / 5 - Exclusão

For nI := 1 To Len( aDados )
	If !(NW5->(dbSeek(xFilial("NW5") + aDados[nI][1] )))
		lExiste := .T.
		oModel:Activate() // Ativa o Model para cada iteração do loop.

		If !oModel:SetValue("NW5MASTER",'NW5_COD',aDados[nI][1]) .Or. !oModel:SetValue("NW5MASTER",'NW5_DESC',aDados[nI][2]) .Or.;
			!oModel:SetValue("NW5MASTER",'NW5_TIPO',aDados[nI][3]) .Or. !oModel:SetValue("NW5MASTER",'NW5_ATUTAB',aDados[nI][4])
			lRet := .F.
			JurMsgErro( STR0012 ) //Erro ao efetuar a carga de dados
			Exit
		EndIf

		If	lRet
			If ( lRet := oModel:VldData() )
				oModel:CommitData()
				If __lSX8
					ConfirmSX8()
				EndIf
			Else
				aErro := oModel:GetErrorMessage()
				JurMsgErro(aErro[6])
			EndIf
		EndIf

	 oModel:DeActivate()
	
	EndIf
Next

If !lExiste
	lRet := .F.
	JurMsgErro( STR0011 ) // Não é possivel realizar a carga inicial. Já existe configuração.
EndIf

RestArea(aAreaNW5)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA059CALC
Realiza a correção de valores

@param cIndic - Código do índice
@param lRecalculo - Realiza o recalculo?

@Return lRet	 	.T./.F. As informações são válidas ou não

@author André Spirigoni Pinto
@since 05/09/14
@version 1.0

/*/
//-------------------------------------------------------------------
Function JA059CALC(cIndic, lRecalculo)
Local aArea     := GetArea()
Local lRet      := .T.
Local aFormas   := {}
Local cFormas	:= '('
Local cAliasQry
Local cAliasPro
Local cQuery
Local cQryAux
Local cTabela
Local cChave
Local aCodigos  := {}
Local nI
Local aTables   := {}
Local lAuto     := JurAuto()

Default lRecalculo := .F.

If lAuto .or. ApMsgYesNo(STR0018) //"Este processo pode demorar vários minutos. Deseja continuar?"

	cAliasQry := GetNextAlias()
	cAliasPro := GetNextAlias()
	
	cQuery := "SELECT NW7_COD FROM " + RetSqlName("NW7") + CRLF
	cQuery += "WHERE NW7_FILIAL = '" + xFilial("NW7") + "'" + CRLF
	cQuery += "AND NW7_FORMUL LIKE '%,_" + cIndic + "_,%'" + CRLF
	cQuery += "AND D_E_L_E_T_ = ' '" + CRLF
	
	cQuery := ChangeQuery( cQuery )
	
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .T., .F. )
	
	//Monta lista de formas que usam o índice
	While !(cAliasQry)->(EOF())
		aAdd(aFormas,(cAliasQry)->NW7_COD)
		cFormas += "'" + (cAliasQry)->NW7_COD + "',"
		
		(cAliasQry)->( dbSkip() )
	End
	
	cFormas := Left(cFormas,Len(cFormas)-1) + ")"
	
	(cAliasQry)->(dbCloseArea())
	
	//Valida se existe alguma fórmula vinculada ao índice escolhido.
	if len(aFormas) > 0
	
		cQuery := "SELECT DISTINCT NW8_CTABEL,NW8_CFORMA FROM " + RetSqlName("NW8") + CRLF
		cQuery += "WHERE NW8_FILIAL = '" + xFilial("NW8") + "'" + CRLF
		cQuery += "AND D_E_L_E_T_ = ' '" + CRLF
		
		cQuery := ChangeQuery( cQuery )
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ) , cAliasQry, .T., .F. )
		
		//Executa as queries
		While !(cAliasQry)->(EOF())
			cTabela := (cAliasQry)->NW8_CTABEL
			
			If (cAliasQry)->NW8_CTABEL == "NSZ"
				cChave	:= (cAliasQry)->NW8_CTABEL + "_COD"
			Else
				cChave	:= (cAliasQry)->NW8_CTABEL + "_CAJURI"
			Endif
				
			cQryAux := "SELECT DISTINCT " + cChave + " CODIGO, " + cTabela + "_FILIAL FILIAL FROM " + RetSqlName(cTabela) + CRLF
			cQryAux += "WHERE " + (cAliasQry)->NW8_CFORMA + " IN " + cFormas + CRLF
			cQryAux += "AND " + cTabela + "_FILIAL = '" + xFilial(cTabela) + "'" + CRLF
			cQryAux += "AND D_E_L_E_T_ = ' '" + CRLF
			
			cQryAux := ChangeQuery( cQryAux )
			
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryAux ) , cAliasPro, .T., .F. )
			
			While !(cAliasPro)->(EOF())
				If aScan(aCodigos,{|x| x[1] == (cAliasPro)->CODIGO}) == 0
					aAdd(aCodigos,{(cAliasPro)->CODIGO, (cAliasPro)->FILIAL})
				Endif
				
				If aScan(aTables,cTabela) == 0
					aAdd(aTables,cTabela)
				Endif
				
				(cAliasPro)->( dbSkip() )
			End
			
			(cAliasQry)->( dbSkip() )
			
			(cAliasPro)->(dbCloseArea())
		
		End
		
		(cAliasQry)->(dbCloseArea())
		
		ProcRegua(Len(aCodigos))
		
		For nI := 1 to Len(aCodigos)
			JURA002( {aCodigos[nI]},aTables,.F.,,,,lRecalculo)
			IncProc(I18N(STR0017,{AllTrim(str(nI)),Alltrim(str(Len(aCodigos)))} )) //"Processando registro #1 de #2"
		Next
		
	Endif
	
	If !lAuto
		ApMsgInfo(STR0016)//"Operação concluída com sucesso."
	Endif

Endif

RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JA059NewInd()
Função utilizada para devolver o ultimo reigstro do banco
Uso Geral
@author Jorge Luis Branco Martins Junior
@since 13/04/16
@version 1.0
/*/
//-------------------------------------------------------------------
Function JA059NewInd()
Local aArea     := GetArea()
Local cNextCode := '61'
Local cAliasQry := GetNextAlias()

  BeginSql Alias cAliasQry    
	
    SELECT MAX(NW5_COD) NW5_MAX
      FROM %table:NW5% NW5
     WHERE NW5.NW5_FILIAL = %xFilial:NW5%
       AND NW5.%notDEL%
   		 		
  EndSql
  dbSelectArea(cAliasQry)

  if !Empty((cAliasQry)->NW5_MAX) .And. (cAliasQry)->NW5_MAX >= cNextCode
    cNextCode := PadL((Val((cAliasQry)->NW5_MAX) + 1),2,'0')
  Endif            
  
  (cAliasQry)->(dbCloseArea())  
	RestArea(aArea)

Return cNextCode
