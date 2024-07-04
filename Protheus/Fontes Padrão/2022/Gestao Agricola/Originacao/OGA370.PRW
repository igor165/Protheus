#INCLUDE "OGA370.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"


/** {Protheus.doc} OGA370
Rotina para inclusão de Ordens de Recebimento (Normal - Antecipada)

@param: 	Nil
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		SIGAARM - Originação de Grãos
*/
Function OGA370()
Local oMBrowse	:= Nil

oMBrowse := FWMBrowse():New()
oMBrowse:SetAlias( "NN5" )
oMBrowse:SetDescription( STR0001 ) //"Ordem de Recebimento"
oMBrowse:AddLegend( "NN5_STATUS='1'", "GREEN"	, STR0002 ) //"Programada"
oMBrowse:AddLegend( "NN5_STATUS='2'", "BLUE"	, STR0003 ) //"Parcialmente Executada"
oMBrowse:AddLegend( "NN5_STATUS='3'", "RED"		, STR0004 ) //"Totalmente Executada"
oMBrowse:DisableDetails()
oMBrowse:Activate()

Return( Nil )


/**  {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		OGA370 - Espécies
*/
Static Function MenuDef()
Local aRotina := {}

aAdd( aRotina, { STR0005 , 'PesqBrw'        , 0, 1, 0, .T. } ) //'Pesquisar'
aAdd( aRotina, { STR0006, 'ViewDef.OGA370', 0, 2, 0, Nil } ) //'Visualizar'
aAdd( aRotina, { STR0007   , 'ViewDef.OGA370', 0, 3, 0, Nil } ) //'Incluir'
aAdd( aRotina, { STR0008   , 'ViewDef.OGA370', 0, 5, 0, Nil } ) //'Excluir'
aAdd( aRotina, { STR0009  , 'ViewDef.OGA370', 0, 8, 0, Nil } ) //'Imprimir'
aAdd( aRotina, { STR0010    , 'ViewDef.OGA370', 0, 9, 0, Nil } ) //'Copiar'

Return( aRotina )


/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		OGA370 - Espécies
*/
Static Function ModelDef()
Local oStruNN5 := FWFormStruct( 1, "NN5" )
Local oStruNN6 := FWFormStruct( 1, "NN6" )
Local oModel := MPFormModel():New( "OGA370", , {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) } )

oStruNN5:SetProperty( "NN5_TIPO"   , MODEL_FIELD_INIT , {| x | x := "1" }  )
oStruNN5:SetProperty( "NN5_FORMA" , MODEL_FIELD_VALID  )
If NN5->(FieldPos("NN5_QTPAG0") > 0)
	oStruNN5:SetProperty( "NN5_QTPAG0", MODEL_FIELD_VALID  , {| x | ValQTPAG0( x ) } )
EndIf
If NN5->(FieldPos("NN5_QTPAG1") > 0)
	oStruNN5:SetProperty( "NN5_QTPAG1", MODEL_FIELD_VALID  , {| x | ValQTPAG1( x ) } )
EndIf
If NN5->(FieldPos("NN5_QTPAG2") > 0)
	oStruNN5:SetProperty( "NN5_QTPAG2", MODEL_FIELD_VALID  , {| x | ValQTPAG2( x ) } )
EndIf
If NN5->(FieldPos("NN5_QTDPAG") > 0)
	oStruNN5:SetProperty( "NN5_QTDPAG", MODEL_FIELD_VALID  , {| x | ValQTDPAG( x ) } )
EndIf
oStruNN6:RemoveField( "NN6_CODOPG" )

oModel:AddFields( "NN5UNICO", Nil, oStruNN5 )
oModel:GetModel( "NN5UNICO" ):SetDescription( STR0011 ) //"Dados da Ordem de Recebimento"

oModel:AddGrid( "NN6UNICO", "NN5UNICO", oStruNN6 )
oModel:GetModel( "NN6UNICO" ):SetDescription( STR0012 ) //"Dados dos Favorecidos"

oModel:SetDescription( STR0001 ) //"Ordem de Recebimento"
oModel:SetRelation( "NN6UNICO", { { "NN6_FILIAL", "xFilial( 'NN6' )" }, { "NN6_CODOPG", "NN5_CODOPG" } }, NN6->( IndexKey( 1 ) ) )

Return( oModel )


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		OGA370 - Espécies
*/
Static Function ViewDef()
Local oStruNN5	:= FWFormStruct( 2, "NN5" )
Local oStruNN6	:= FWFormStruct( 2, "NN6" )
Local oModel	:= FWLoadModel( "OGA370" )
Local oView		:= FWFormView():New()

oStruNN6:RemoveField( "NN6_CODOPG" )

oView:SetModel( oModel )

oView:AddField( "VIEW_NN5", oStruNN5, "NN5UNICO" )
oView:AddGrid( "VIEW_NN6", oStruNN6, "NN6UNICO" )

oView:AddIncrementField( "VIEW_NN6", "NN6_ITEM" )

oView:CreateVerticallBox( "TELANOVA" , 100 )
oView:CreateHorizontalBox( "SUPERIOR" , 50, "TELANOVA" )
oView:CreateHorizontalBox( "INFERIOR" , 50, "TELANOVA" )

oView:SetOwnerView( "VIEW_NN5", "SUPERIOR" )
oView:SetOwnerView( "VIEW_NN6", "INFERIOR" )

oView:EnableTitleView( "VIEW_NN5" )
oView:EnableTitleView( "VIEW_NN6" )

oView:SetCloseOnOk( {||.t.} )

Return( oView )



/** {Protheus.doc} ValQTPAG0


@param: 	oFields - Field do modelo de dados
@return:	Nil
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		ARMA251 - Romaneio de Compra
*/
Static Function ValQTPAG0( oNN5 )
Local lRetorno 		:= .t.
Local aAreaAtu		:= GetArea()
Local cForma		:= oNN5:GetValue( "NN5_FORMA" )
Local cCodCtr		:= oNN5:GetValue( "NN5_CODCTR" )
Local cCodFix		:= oNN5:GetValue( "NN5_CODFIX" )

Local nQtdOrd		:= 0

NJR->( dbSetOrder( 1 ) )
NJR->( dbSeek( xFilial( "NJR" ) + cCodCtr ) )

NN8->( dbSetOrder( 1 ) )
NN8->( dbSeek( xFilial( "NN8" ) + cCodCtr + cCodFix ) )

If cForma = "1" .And. Empty( cCodFix )

	Help( , , STR0013, , STR0014, 1, 0 ) //"AJUDA"###"Para OPs Normais é obrigatório a seleção de uma fixação!"
	lRetorno := .f.

ElseIf cForma = "1" .And. .Not. Empty( cCodFix )

	BeginSql Alias "QryNN5"
		Select
			Sum( NN5.NN5_QTPAG0 ) as NN5_QTPAG0
		From
			%table:NN5% NN5
		Where
			NN5.NN5_FILIAL = %xFilial:NN5% And 
			NN5.NN5_FORMA = %exp:cForma% And
			NN5.NN5_CODCTR = %exp:cCodCtr% And
			NN5.NN5_CODFIX = %exp:cCodFix% And
			NN5.%NotDel%
	EndSql
	nQtdOrd += QryNN5->( NN5_QTPAG0 )
	QryNN5->( dbCloseArea() )

EndIf

RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} ValQTPAG1


@param: 	oFields - Field do modelo de dados
@return:	Nil
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		ARMA251 - Romaneio de Compra
*/
Static Function ValQTPAG1( oNN5 )
Local lRetorno 		:= .t.
Local aAreaAtu		:= GetArea()
Local cForma		:= oNN5:GetValue( "NN5_FORMA" )
Local cCodCtr		:= oNN5:GetValue( "NN5_CODCTR" )
Local cCodFix		:= oNN5:GetValue( "NN5_CODFIX" )

Local nQtdOrd		:= 0

NJR->( dbSetOrder( 1 ) )
NJR->( dbSeek( xFilial( "NJR" ) + cCodCtr ) )

NN8->( dbSetOrder( 1 ) )
NN8->( dbSeek( xFilial( "NN8" ) + cCodCtr + cCodFix ) )

If cForma = "1" .And. Empty( cCodFix )

	Help( , , STR0013, , STR0016, 1, 0 ) //"AJUDA"###"Para ORs Normais é obrigatório a seleção de uma fixação!"
	lRetorno := .f.

ElseIf cForma = "1" .And. .Not. Empty( cCodFix )

	BeginSql Alias "QryNN5"
		Select
			Sum( NN5.NN5_QTPAG1 ) as NN5_QTPAG1
		From
			%table:NN5% NN5
		Where
			NN5.NN5_FILIAL = %xFilial:NN5% And 
			NN5.NN5_FORMA = %exp:cForma% And
			NN5.NN5_CODCTR = %exp:cCodCtr% And
			NN5.NN5_CODFIX = %exp:cCodFix% And
			NN5.%NotDel%
	EndSql
	nQtdOrd += QryNN5->( NN5_QTPAG1 )
	QryNN5->( dbCloseArea() )

EndIf

RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} ValQTPAG2


@param: 	oFields - Field do modelo de dados
@return:	Nil
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		ARMA251 - Romaneio de Compra
*/
Static Function ValQTPAG2( oNN5 )
Local lRetorno 		:= .t.
Local aAreaAtu		:= GetArea()
Local cForma		:= oNN5:GetValue( "NN5_FORMA" )
Local cCodCtr		:= oNN5:GetValue( "NN5_CODCTR" )
Local cCodFix		:= oNN5:GetValue( "NN5_CODFIX" )

Local nQtdOrd		:= 0

NJR->( dbSetOrder( 1 ) )
NJR->( dbSeek( xFilial( "NJR" ) + cCodCtr ) )

NN8->( dbSetOrder( 1 ) )
NN8->( dbSeek( xFilial( "NN8" ) + cCodCtr + cCodFix ) )

If cForma = "1" .And. Empty( cCodFix )

	Help( , , STR0013, , STR0016, 1, 0 ) //"AJUDA"###"Para ORs Normais é obrigatório a seleção de uma fixação!"
	lRetorno := .f.

ElseIf cForma = "1" .And. .Not. Empty( cCodFix )

	BeginSql Alias "QryNN5"
		Select
			Sum( NN5.NN5_QTPAG2 ) as NN5_QTPAG2
		From
			%table:NN5% NN5
		Where
			NN5.NN5_FILIAL = %xFilial:NN5% And 
			NN5.NN5_FORMA = %exp:cForma% And
			NN5.NN5_CODCTR = %exp:cCodCtr% And
			NN5.NN5_CODFIX = %exp:cCodFix% And
			NN5.%NotDel%
	EndSql
	nQtdOrd += QryNN5->( NN5_QTPAG2 )
	QryNN5->( dbCloseArea() )

EndIf

RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} ValQTDPAG


@param: 	oFields - Field do modelo de dados
@return:	Nil
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		ARMA251 - Romaneio de Compra
*/
Static Function ValQTDPAG( oNN5 )
Local lRetorno 		:= .t.
Local aAreaAtu		:= GetArea()

Local cForma		:= oNN5:GetValue( "NN5_FORMA" )
Local cCodCtr		:= oNN5:GetValue( "NN5_CODCTR" )
Local cCodFix		:= oNN5:GetValue( "NN5_CODFIX" )
Local nMoeda		:= oNN5:GetValue( "NN5_MOEDA" )
Local nQtdPag		:= oNN5:GetValue( "NN5_QTDPAG" )

Local nQtdOrd		:= 0

Local nVlrCrd		:= 0
Local nVlrExe		:= 0

NJR->( dbSetOrder( 1 ) )
NJR->( dbSeek( xFilial( "NJR" ) + cCodCtr ) )

NN8->( dbSetOrder( 1 ) )
NN8->( dbSeek( xFilial( "NN8" ) + cCodCtr + cCodFix ) )

If cForma = "1" .And. Empty( cCodFix )

	Help( , , STR0013, , STR0016, 1, 0 ) //"AJUDA"###"Para ORs Normais é obrigatório a seleção de uma fixação!"
	lRetorno := .f.

ElseIf cForma = "1" .And. .Not. Empty( cCodFix )

	BeginSql Alias "QryNN5"
		Select
			Sum( NN5.NN5_QTDPAG ) as NN5_QTDPAG
		From
			%table:NN5% NN5
		Where
			NN5.NN5_FILIAL = %xFilial:NN5% And 
			NN5.NN5_FORMA = %exp:cForma% And
			NN5.NN5_CODCTR = %exp:cCodCtr% And
			NN5.NN5_CODFIX = %exp:cCodFix% And
			NN5.%NotDel%
	EndSql
	nQtdOrd += QryNN5->( NN5_QTDPAG )
	QryNN5->( dbCloseArea() )

	If NN8->( NN8_QTDENT ) < nQtdOrd + nQtdPag
		Help( , , STR0013, , STR0017, 1, 0 ) //"AJUDA"###"Quantidade para Recebimento Superior a Quantidade da Entregue na Fixação!"
		lRetorno := .f.
	EndIf

ElseIf cForma = "2"

	nVlrCrd := ( ( NJR->( NJR_VLRTOT ) * NJR->( NJR_PERCRD )  ) / 100 )

	If NJR->( NJR_MOEDA ) == nMoeda
		nVlrExe	+= nValor
	Else
		nVlrExe += xMoeda( nValor, nMoeda, NJR->( NJR_MOEDA ), dDataBase )
	EndIf 

	BeginSql Alias "QryNN5"
		Select Sum( NN5.NN5_QTDPAG ) as NN5_QTDPAG
		From %table:NN5% NN5
		Where NN5.NN5_FILIAL = %xFilial:NN5% And NN5.NN5_FORMA = %exp:cForma% And NN5.NN5_CODCTR = %exp:cCodCtr% And NN5.%NotDel%	
	EndSql
	nQtdOrd += QryNN5->( NN5_QTDPAG )
	QryNN5->( dbCloseArea() )

	BeginSql Alias "QryNN5"
		Select NN5.NN5_MOEDA, Sum( NN5.NN5_VLRTOT ) as NN5_VLRTOT
		From %table:NN5% NN5
		Where NN5.NN5_FILIAL = %xFilial:NN5% And NN5.NN5_FORMA = %exp:cForma% And NN5.NN5_CODCTR = %exp:cCodCtr% And NN5.%NotDel%
		Group By NN5.NN5_MOEDA	
	EndSql
	QryNN5->( dbGotop() )
	While .Not. QryNN5->( Eof() )

		If NJR->( NJR_MOEDA ) == QryNN5->( NN5_MOEDA )
			nVlrExe	+= QryNN5->( NN5_VLRTOT )
		Else
			nVlrExe += xMoeda( QryNN5->( NN5_VLRTOT ), QryNN5->( NN5_MOEDA ), NJR->( NJR_MOEDA ), dDataBase )
		EndIf

		QryNN5->( dbSkip() )
	EndDo
	QryNN5->( dbCloseArea() )

	If nVlrCrd < nVlrExe
		Help( , , STR0013, , STR0018, 1, 0 ) //"AJUDA"###"Valor de Adiantamento Superior ao Credito do Contrato!"
		lRetorno := .f.
	EndIf

	If NJR->( NJR_QTDCTR ) < nQtdOrd
		Help( , , STR0013, , STR0019, 1, 0 ) //"AJUDA"###"Quantidade para Adiantamento Superior a Quantidade do Contrato!"
		lRetorno := .f.
	EndIf

EndIf

RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} PosModelo
Função que valida o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		OGA370 - Espécies
*/
Static Function PosModelo( oModel )
Local lRetorno		:= .t.
Local aAreaAtu		:= GetArea()
Local nOperation	:= oModel:GetOperation()

Local oNN5			:= oModel:GetModel( "NN5UNICO" )
Local cForma		:= oNN5:GetValue( "NN5_FORMA" )
Local cCodCtr		:= oNN5:GetValue( "NN5_CODCTR" )
Local cCodFix		:= oNN5:GetValue( "NN5_CODFIX" )
Local nMoeda		:= oNN5:GetValue( "NN5_MOEDA" )
Local nQtdOrd		:= oNN5:GetValue( "NN5_QTDPAG" )
Local nValor		:= oNN5:GetValue( "NN5_VLRTOT" )
Local cStatus		:= oNN5:GetValue( "NN5_STATUS" )

Local nVlrCrd		:= 0
Local nVlrExe		:= 0

If nOperation == MODEL_OPERATION_INSERT

	NJR->( dbSetOrder( 1 ) )
	NJR->( dbSeek( xFilial( "NJR" ) + cCodCtr ) )

	If cForma = "1" .And. Empty( cCodFix )

		Help( , , STR0013, , STR0016, 1, 0 ) //"AJUDA"###"Para ORs Normais é obrigatório a seleção de uma fixação!"
		lRetorno := .f.

	ElseIf cForma = "1" .And. .Not. Empty( cCodFix )

		NN8->( dbSetOrder( 1 ) )
		NN8->( dbSeek( xFilial( "NN8" ) + cCodCtr + cCodFix ) )

		BeginSql Alias "QryNN5"
			Select
				Sum( NN5.NN5_QTDPAG ) as NN5_QTDPAG
			From
				%table:NN5% NN5
			Where
				NN5.NN5_FILIAL = %xFilial:NN5% And 
				NN5.NN5_FORMA = %exp:cForma% And
				NN5.NN5_CODCTR = %exp:cCodCtr% And
				NN5.NN5_CODFIX = %exp:cCodFix% And
				NN5.%NotDel%
		EndSql
		nQtdOrd += QryNN5->( NN5_QTDPAG )
		QryNN5->( dbCloseArea() )

		If NN8->( NN8_QTDFIX ) < nQtdOrd
			Help( , , STR0013, , STR0020, 1, 0 ) //"AJUDA"###"Quantidade para Recebimento Superior a Quantidade da Fixação!"
			lRetorno := .f.
		EndIf

	ElseIf cForma = "2"
	
		NJR->( dbSetOrder( 1 ) )
		NJR->( dbSeek( xFilial( "NJR" ) + cCodCtr ) )
	
		nVlrCrd := ( ( NJR->( NJR_VLRTOT ) * NJR->( NJR_PERCRD )  ) / 100 )
	
		If NJR->( NJR_MOEDA ) == nMoeda
			nVlrExe	+= nValor
		Else
			nVlrExe += xMoeda( nValor, nMoeda, NJR->( NJR_MOEDA ), dDataBase )
		EndIf 
	
		BeginSql Alias "QryNN5"
			Select Sum( NN5.NN5_QTDPAG ) as NN5_QTDPAG
			From %table:NN5% NN5
			Where NN5.NN5_FILIAL = %xFilial:NN5% And NN5.NN5_FORMA = %exp:cForma% And NN5.NN5_CODCTR = %exp:cCodCtr% And NN5.%NotDel%	
		EndSql
		nQtdOrd += QryNN5->( NN5_QTDPAG )
		QryNN5->( dbCloseArea() )
	
		BeginSql Alias "QryNN5"
			Select NN5.NN5_MOEDA, Sum( NN5.NN5_VLRTOT ) as NN5_VLRTOT
			From %table:NN5% NN5
			Where NN5.NN5_FILIAL = %xFilial:NN5% And NN5.NN5_FORMA = %exp:cForma% And NN5.NN5_CODCTR = %exp:cCodCtr% And NN5.%NotDel%
			Group By NN5.NN5_MOEDA	
		EndSql
		QryNN5->( dbGotop() )
		While .Not. QryNN5->( Eof() )
	
			If NJR->( NJR_MOEDA ) == QryNN5->( NN5_MOEDA )
				nVlrExe	+= QryNN5->( NN5_VLRTOT )
			Else
				nVlrExe += xMoeda( QryNN5->( NN5_VLRTOT ), QryNN5->( NN5_MOEDA ), NJR->( NJR_MOEDA ), dDataBase )
			EndIf
	
			QryNN5->( dbSkip() )
		EndDo
		QryNN5->( dbCloseArea() )
	
		If nVlrCrd < nVlrExe
			Help( , , STR0013, , STR0018, 1, 0 ) //"AJUDA"###"Valor de Adiantamento Superior ao Credito do Contrato!"
			lRetorno := .f.
		EndIf
	
		If NJR->( NJR_QTDCTR ) < nQtdOrd
			Help( , , STR0013, , STR0019, 1, 0 ) //"AJUDA"###"Quantidade para Adiantamento Superior a Quantidade do Contrato!"
			lRetorno := .f.
		EndIf
	
	EndIf

EndIf

If nOperation == MODEL_OPERATION_DELETE

	If cStatus <> "1"
		Help( , , STR0013, , STR0021, 1, 0 ) //"AJUDA"###"Ordem de Recebimento ja -Executada-! Entre em contato com a Tesouraria."
		lRetorno := .f.
	EndIf

EndIf

RestArea( aAreaAtu )
Return( lRetorno )


/** {Protheus.doc} GrvModelo
Funcao para gravar dados adicionais e o modelo de dados

@param: 	oModel - Modelo de Dados
@return:	lRetorno - .t. ou .f.
@author: 	Ricardo Tomasi
@since: 	08/06/2010
@Uso: 		OGA370 - Ordem de Recebimento
*/
Static Function GrvModelo( oModel )
Local lRetorno 		:= .t.
Local nOperation	:= oModel:GetOperation()

Local oNN5			:= oModel:GetModel( "NN5UNICO" )
Local cCodigo		:= oNN5:GetValue( "NN5_CODOPG" )
Local cForma		:= oNN5:GetValue( "NN5_FORMA" )
Local cCodCtr		:= oNN5:GetValue( "NN5_CODCTR" )
Local cCodFix		:= oNN5:GetValue( "NN5_CODFIX" )
Local nMoeda		:= oNN5:GetValue( "NN5_MOEDA" ) 
Local dDtVencto	:= oNN5:GetValue( "NN5_DATVNC" )
Local cNatureza	:= oNN5:GetValue( "NN5_NATFIN" )

Local oNN6			:= oModel:GetModel( "NN6UNICO" )
Local cCodFav		:= ""
Local cLojFav		:= ""
Local nValor		:= 0
Local nVlrCrz		:= 0
Local cCssCrd		:= ""
Local cHistorico	:= ""

Local cPrefixo		:= PadR( "OR ", TamSX3( "E2_PREFIXO" )[1] )
Local cNumero		:= PadR( cCodigo, TamSX3( "E2_NUM" )[1] )
Local cParcela		:= ""
Local cTipTit		:= ""
Local cFornecedor	:= ""
Local cLoja			:= ""

Local aFina040		:= {}
Local nX			:= 0

Private lMsErroAuto	:= .f.

NJR->( dbSetOrder( 1 ) )
NJR->( dbSeek( xFilial( "NJR" ) + cCodCtr ) )

If nOperation == MODEL_OPERATION_INSERT

	If cForma = "1"

		BEGIN TRANSACTION
		   For nX := 1 to oNN6:Length()
		   	oNN6:GoLine( nX )
           
		   	cParcela	:= oNN6:GetValue( "NN6_ITEM" )
		   	cCodFav		:= oNN6:GetValue( "NN6_CODFAV" )
		   	cLojFav		:= oNN6:GetValue( "NN6_LOJFAV" )
		   	nValor		:= oNN6:GetValue( "NN6_VALOR" )
		   	cCssCrd		:= oNN6:GetValue( "NN6_CSSCRD" )
           
		   	NJ0->( dbSetOrder( 1 ) )
		   	NJ0->( dbSeek( xFilial( "NJ0" ) + cCodFav + cLojFav ) )
		   	cFornecedor := NJ0->( NJ0_CODCLI )
		   	cLoja 		:= NJ0->( NJ0_LOJCLI )
           
		   	cTipTit		:= "OR "
		   	nVlrCrz 	:= xMoeda( nValor, nMoeda, 1, dDataBase )
           
		   	cHistorico := STR0022 + cCodCtr + STR0023 + cCodFix //"Recto Contrato:"###", Fixação:"
		   	If .Not. Empty( cCssCrd )
		   		cHistorico += STR0024 + cCssCrd //", ao Favorecido da C.C.:"
		   	EndIf
           
		   	aFina040 := {}
		   	aAdd( aFina040, { "E1_PREFIXO" , cPrefixo					, Nil } )
		   	aAdd( aFina040, { "E1_NUM"     , cNumero					, Nil } )
		   	aAdd( aFina040, { "E1_PARCELA" , cParcela					, Nil } )
		   	aAdd( aFina040, { "E1_TIPO"    , cTipTit					, Nil } )
		   	aAdd( aFina040, { "E1_NATUREZ" , cNatureza					, Nil } )
		   	aAdd( aFina040, { "E1_CLIENTE" , cFornecedor				, Nil } )
		   	aAdd( aFina040, { "E1_LOJA"    , cLoja						, Nil } )
		   	aAdd( aFina040, { "E1_EMISSAO" , dDataBase					, Nil } )
		   	aAdd( aFina040, { "E1_VENCTO"  , dDtVencto					, Nil } )
		   	aAdd( aFina040, { "E1_VALOR"   , nValor						, Nil } )
		   	aAdd( aFina040, { "E1_MOEDA"   , nMoeda						, Nil } )
		   	aAdd( aFina040, { "E1_VLCRUZ"  , nVlrCrz					, Nil } )		
		   	aAdd( aFina040, { "E1_HIST"    , cHistorico				, Nil } )
		   	aAdd( aFina040, { "E1_CTROG"   , cCodCtr					, Nil } )
		   	aAdd( aFina040, { "E1_CODSAF"  , NJR->( NJR_CODSAF )		, Nil } )
		   	aAdd( aFina040, { "E1_ARMFIX"  , cCodFix					, Nil } )
		   	aAdd( aFina040, { "E1_ORIGEM"  , "OGA370"					, Nil } )
           
		   	MsExecAuto( { | x, y | Fina040( x, y ) }, aFina040, 3 )
		   	If lMsErroAuto
		   		DisarmTransaction()
		   		MostraErro()
		   		lRetorno := .f.
		   		Exit
		   	EndIf
		   Next nX
		END TRANSACTION

	EndIf

	If cForma = "2"
		BEGIN TRANSACTION
		   For nX := 1 to oNN6:Length()
		   	oNN6:GoLine( nX )
           
		   	cParcela		:= oNN6:GetValue( "NN6_ITEM" )
		   	cCodFav		:= oNN6:GetValue( "NN6_CODFAV" )
		   	cLojFav		:= oNN6:GetValue( "NN6_LOJFAV" )
		   	nValor			:= oNN6:GetValue( "NN6_VALOR" )
		   	cCssCrd		:= oNN6:GetValue( "NN6_CSSCRD" )
           
		   	NJ0->( dbSetOrder( 1 ) )
		   	NJ0->( dbSeek( xFilial( "NJ0" ) + cCodFav + cLojFav ) )
		   	cFornecedor 	:= NJ0->( NJ0_CODCLI )
		   	cLoja 			:= NJ0->( NJ0_LOJCLI )
           
		   	cTipTit		:= "ORA"
		   	nVlrCrz 		:= xMoeda( nValor, nMoeda, 1, dDataBase )
           
		   	cHistorico 	:= STR0025 + cCodCtr //"Adto Contrato:"
		   	If .Not. Empty( cCssCrd )
		   		cHistorico += STR0024 + cCssCrd //", ao Favorecido da C.C.:"
		   	EndIf
           
		   	aFina040 := {}
		   	aAdd( aFina040, { "E1_PREFIXO" , cPrefixo					, Nil } )
		   	aAdd( aFina040, { "E1_NUM"     , cNumero					, Nil } )
		   	aAdd( aFina040, { "E1_PARCELA" , cParcela					, Nil } )
		   	aAdd( aFina040, { "E1_TIPO"    , cTipTit					, Nil } )
		   	aAdd( aFina040, { "E1_NATUREZ" , cNatureza					, Nil } )
		   	aAdd( aFina040, { "E1_CLIENTE" , cFornecedor				, Nil } )
		   	aAdd( aFina040, { "E1_LOJA"    , cLoja						, Nil } )
		   	aAdd( aFina040, { "E1_EMISSAO" , dDataBase					, Nil } )
		   	aAdd( aFina040, { "E1_VENCTO"  , dDtVencto					, Nil } )
		   	aAdd( aFina040, { "E1_VALOR"   , nValor						, Nil } )
		   	aAdd( aFina040, { "E1_MOEDA"   , nMoeda						, Nil } )
		   	aAdd( aFina040, { "E1_VLCRUZ"  , nVlrCrz					, Nil } )		
		   	aAdd( aFina040, { "E1_HIST"    , cHistorico				, Nil } )
		   	aAdd( aFina040, { "E1_CTROG"   , cCodCtr					, Nil } )
		   	aAdd( aFina040, { "E1_ORIGEM"  , "OGA370"					, Nil } )
           
		   	MsExecAuto( { | x, y | Fina040( x, y ) }, aFina040, 3 )
		   	If lMsErroAuto
		   		DisarmTransaction()
		   		MostraErro()
		   		lRetorno := .f.
		   		Exit
		   	EndIf
           
		   Next nX
		END TRANSACTION
	EndIf

EndIf

If lRetorno
	FWFormCommit( oModel )
EndIf

Return( lRetorno )
