#include "protheus.ch"


/** {Protheus.doc} OGX215
Rotina chamada através do Ponto de Entrada em cada ação do Pedido de Venda ( MATA410 )
Autoriza todas as funcinalidades ( Incluir/ Alterar/ Excluir/ Copias )

@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
@Alterado por: Marcelo R. Ferrari
@Alterado em: 21/08/2014
**/

//Programa Original: ARMXPE11
Function OGX215()
Local lRetorno 	:= .t.
Local aAreaAtu 	:= GetArea()

	if TableInDic('N8H')
		// 	Verifica se o pv  que esta sendo excluido possui algum vinculo com as tabs. de extensçao do OG. 
		//	em caso afirmativo deleta da tabela de extenção
		lRetorno := fDelVinc( )
	else
		NJM->( dbSetOrder( 3 ) )
		If NJM->( dbSeek( xFilial( "SC5" ) + SC5->( C5_NUM ) ) )
		
			NJM->( RecLock( "NJM", .f. ) )
			NJM->( NJM_PEDIDO ) := Space( TamSX3( "NJM_PEDIDO" )[1] )
			NJM->( MsUnLock() )
		
		EndIf
	endIf

RestArea( aAreaAtu )
Return( lRetorno )

/** {Protheus.doc} fDelVinc
Rotina chamada através do Ponto de Entrada em cada ação do Pedido de Venda ( MATA410 )
Autoriza todas as funcinalidades ( Incluir/ Alterar/ Excluir/ Copias )

@author: 	Agro
@since: 	08/06/2010
@Uso: 		SIGAARM - Originação de Grãos
*/

Static Function fDelvinc()
	Local lRetorno 	:= .t.

	aSavSC5 := SC5->( GetArea() )
	aSavSC6 := SC6->( GetArea() )
	aSavNJM := NJM->( GetArea() )
	dbSelectArea( "N8H" ) // Cabecalho do PV
	N8H->( dbSetOrder( 1 ) )
	If dbSeek( xFilial( "N8H" ) + SC5->C5_NUM )

		dbSelectArea( "N8I" ) 		// Item do PV
		N8I-> ( dbSetOrder( 1 ))  	//N8I_FILIAL+N8I_NUM+N8I_ITEM+N8I_PRODUTO

		If dbSeek( xFilial( "N8I" ) + N8H->N8H_NUMPV)
			While .Not. N8I->( Eof() ) .And. N8I->( N8I_FILIAL+N8I_NUMPV) == FwxFilial("N8I") + N8H->N8H_NUMPV
			
				IF lRetorno .and. ! Empty( Alltrim (N8I->N8I_CODROM  )) 	// Indica que o item do pv. foi criado por um item do romaneio
					NJM->( dbSetOrder( 1 ) ) // NJM_FILIAL+NJM_CODROM+NJM_ITEROM   
					If NJM->( dbSeek( fwxFilial( "NJM" ) + N8I-> ( N8I_CODROM+N8I_ITEROM)  ) )
					                                                                                                                                   
						NJM->( RecLock( "NJM", .f. ) )
						NJM->( NJM_PEDIDO ) := Space( TamSX3( "NJM_PEDIDO" )[1] )
						NJM->( MsUnLock() )

					EndIf
				EndIF

				IF RecLock('N8I', .f. )    	//Deletando itens do PV
					N8I->(DbDelete() )
					N8I->(msUnLock() )
				Else
					lRetorno := .f.
					Exit
				EndIF
				N8I->( dBskip() )
			EndDO
		EndIF

		IF lRetorno
			IF RecLock('N8H', .f. )    	//Deletando Cab. do PV.
				N8H->(DbDelete() )
				N8H->(msUnLock() )
			Else
				lRetorno := .f.
			EndIF

		EndIF
	EndIF

	Restarea( aSavSC5 )
	Restarea( aSavSC6 )
	Restarea( aSavNJM )
	
Return( lRetorno )



