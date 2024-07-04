#INCLUDE "OGX013.ch"
#include "protheus.ch"

/////////////////////////////////////////////////////////////////
////														 ////
////  FUNÇÕES ROMANEIO POR PRODUÇÃO                          ////
////														 ////
/////////////////////////////////////////////////////////////////

/** {Protheus.doc} OGX013
Rotina para movimentação de romaneio por produção
Realizar o controle de transação(Begin Transaction) na função que chama esta função

@param 	lEstorn, Logical, variavel logica se deve realizar o estorno(.t.) ou não(.f.)
@return Logical, retorna se a execução foi realizada com sucesso(.t.) ou se houve falha(.f.)
@author Agroindustria
@since 	29/09/2015
@Uso: 		SIGAAGR - Gestão Agrícola
*/
Function OGX013(lEstorn)
	Local aAreaAtu  := GetArea()
	Local lRetorno  := .t.

	Private cDocEst   := ""

	Default lEstorn     := .f.

	
	if NJJ->( NJJ_TIPO ) == "1" //entrada por produção

		MsgRun( STR0001, STR0002, {|| lRetorno := GeraSD3(lEstorn) } ) //"Gerando movimentação de Estoque..."###"Movimentando"

		If lRetorno
			dbSelectArea( "NJJ" )
			If RecLock( "NJJ", .f. )
				If .Not. lEstorn
					NJJ->( NJJ_DOCEST ) := cDocEst
					NJJ->( NJJ_STATUS ) := "3"
				else
					NJJ->( NJJ_DOCEST ) := ""
					NJJ->( NJJ_STATUS ) := "1"
				EndIf
				msUnLock()
			EndIf
		EndIf
	EndIf

	RestArea( aAreaAtu )

Return lRetorno

/** {Protheus.doc} GeraSD3
Rotina para criação de movimento no mata241

@param 	lEstorn, Logical, variavel logica se deve realizar o estorno(.t.) ou não(.f.)
@return Logical, retorna se a execução foi realizada com sucesso(.t.) ou se houve falha(.f.)
@author    Agroindustria
@since     29/09/2015
@Uso       SIGAAGR - Gestão Agrícola
@type function
*/
Static Function GeraSD3( lEstorn )
	Local lRetorno      := .t.
	Local cTM           := SuperGetMV( "MV_ARM251A", .f.) // tipo de movimentação para produção
	Local aCab          := {}
	Local aItem         := {}
	Local aItens        := {}
	Local aRetPe		:= {}

	Private lMsErroAuto := .f.

	Default lEstorn     := .f.

	If .Not. lEstorn
		dbSelectArea( "SF5" )
		SF5->( dbSetOrder( 1 ) )
		SF5->( dbSeek( xFilial( "SF5" ) + cTM ) )

		dbSelectArea( "SB1" )
		SB1->( dbSetOrder( 1 ) )
		SB1->( dbSeek( xFilial( "SB1" ) + NJJ->( NJJ_CODPRO  ) ) )

		aAdd( aCab,  {"D3_TM"       , cTM                       , Nil } )
		aAdd( aCab,  {"D3_EMISSAO"  , dDataBase                 , Nil } )
		aAdd( aItem, {'D3_COD'      , SB1->( B1_COD     )       , Nil } )
		aAdd( aItem, {'D3_UM'       , SB1->( B1_UM      )       , Nil } )
		aAdd( aItem, {'D3_LOCAL'    , NJJ->( NJJ_LOCAL  )       , Nil } )
		aAdd( aItem, {'D3_QUANT'    , NJJ->( NJJ_PSLIQU )       , Nil } )

		If SF5->( F5_VAL ) = "S"
			aAdd( aItem, {'D3_CUSTO1' , NJJ->( NJJ_PSLIQU ) * 1   , Nil } )
		EndIf

		If EXISTBLOCK ("OGX013GER")
			aRetPe := ExecBlock("OGX013GER",.F.,.F.,{aCab, aItem})

			If Len(aRetPe) == 2 .And. ValType(aRetPe[1]) == "A" .And. ValType(aRetPe[2]) == "A"
				aCab  := aRetPe[1]
				aItem := aRetPe[2]
			EndIf
		EndIf

		aAdd( aItens, aItem )

		MSExecAuto( { | x , y, z | Mata241( x, y, z ) }, aCab, aItens, 3 )

		If lMsErroAuto
			MostraErro( )
			lRetorno := .f.
		Else
			cDocEst := SD3->( D3_DOC )
		EndIf

	Else

		SD3->( dbSetOrder( 2 ) )
		If SD3->( dbSeek( xFilial( "SD3" ) + NJJ->( NJJ_DOCEST ) ) )
			MsExecAuto( {| x, y, z | MatA241( x, y, z ) }, {}, Nil, 6 )
			If lMsErroAuto
				MostraErro( )
				lRetorno := .f.
			EndIf
		Else
			Help( , , STR0003, , STR0004, 1, 0 ) //"AJUDA"###"Movimento de estoque nao localizado!"
			lRetorno := .f.
		EndIf

	EndIf

Return( lRetorno )

/** {Protheus.doc} OGX013EST
Rotina para estorno de movimento de produção

@param:     Nil
@return:    Nil
@author:    Agroindustria
@since:     29/09/2015
@Uso:       SIGAAGR - Gestão Agrícola
*/
Function OGX013EST(cDocEst)
	Local aAreaAtu  := GetArea()
	Local lRetorno  := .t.
	Local cAliasNJJ := GetNextAlias()

	If FindFunction("OGXUTOG") //Encontra a função
		If OGXUTOG()

			BeginSql Alias cAliasNJJ
				SELECT NJJ.NJJ_CODROM
				FROM %Table:NJJ% NJJ
				WHERE NJJ.%notDel%
				AND NJJ.NJJ_FILIAL  = %XFilial:NJJ%
				AND NJJ.NJJ_DOCEST  = %exp:cDocEst%
			EndSQL

			dbSelectArea(cAliasNJJ)
			(cAliasNJJ)->( DbGoTop() )
			If ! (cAliasNJJ)->( Eof() )

				dbSelectArea( "NJJ" )
				NJJ->( dbSetOrder( 1 ) )
				if NJJ->( dbSeek( xFilial( "NJJ" ) + (cAliasNJJ)->NJJ_CODROM ) )
					If RecLock( "NJJ", .f. )
						NJJ->(NJJ_DOCEST) := ""
						NJJ->(NJJ_STATUS) := "2"
						NJJ->(msUnLock())
					EndIf
				EndIf

			EndIf
			(cAliasNJJ)->( DbCloseArea() )

		endif
	endif
	RestArea( aAreaAtu )
Return(lRetorno)
