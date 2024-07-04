#include "protheus.ch"


/** {Protheus.doc} OGX003A
Rotina para calculo do desconto baseado na tabela e percentual informado

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX003A( cTabela, cCodDes, nPerDes, nQtdSbt, nQtdLiq )
Local aAreaAtu := GetArea()
Local nRetorno := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona Cabecalho da Tabela de Descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( 'NNI' )
dbSetOrder( 1 )
dbSeek( xFilial('NNI') + cTabela )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Posiciona Itens da Tabela de Descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( 'NNJ' )
dbSetOrder( 1 )
dbSeek( xFilial( 'NNJ' ) + cTabela + cCodDes )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ ¿
//³Posiciona Sub-Itens da Tabela de Descontos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ Ù
dbSelectArea( 'NNK' )
dbSetOrder( 1 )
dbSeek( xFilial( 'NNK' ) + cTabela + cCodDes )

While .Not. Eof() .And. NNK_FILIAL == xFilial( 'NNK' ) .And. NNK_CODTAB == cTabela .And. NNK_CODDES == cCodDes

	If NNK_PERPRO == 'S'
		If nPerDes > NNK_PERFIM
			nRetorno := Round( ( ( IIf( NNJ->( NNJ_INCIDE ) == 'A', nQtdSbt, nQtdLiq ) * ( nPerDes - NNK_PERFIM ) ) / 100 ), 0 )
		Else
			nRetorno := 0
		EndIf
	Else
		If nPerDes >= NNK_PERINI .And. nPerDes <= NNK_PERFIM
			nRetorno := Round( ( ( IIf( NNJ->( NNJ_INCIDE ) == 'A', nQtdSbt, nQtdLiq ) * NNK_PERDES ) / 100 ), 0 )
		EndIf
	EndIf

	If nPerDes == 0
		nRetorno := 0
	EndIf
	
	dbSkip()
EndDo

RestArea( aAreaAtu )
Return( nRetorno )


/** {Protheus.doc} OGX003B
Funcao auxiliar para o WHEN do campo percentual de desconto.
Quando utilizar integracao com equipamento de leitura o campo fica desabilitado.

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX003B( )
Local lRetorno	:= .t.
Local aAreaAtu	:= GetArea()
Local oModel	:= FwModelActive( )
Local cTabela	:= ""
Local cSeq		:= ""

If Type( "oModel" ) = "O"
	cTabela	:= oModel:GetModel( "NJJUNICO" ):GetValue( "NJJ_TABELA" )
	cSeq	:= oModel:GetModel( "NJKUNICO" ):GetValue( "NJK_ITEM" )
	
	dbSelectArea( "NNJ" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "NNJ" ) + cTabela + cSeq )
		If NNJ->( NNJ_MODAL ) = "0"
			lRetorno := .f.
		EndIf
	EndIf
EndIf

RestArea( aAreaAtu )
Return( lRetorno )