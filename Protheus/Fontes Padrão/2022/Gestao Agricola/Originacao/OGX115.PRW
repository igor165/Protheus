#include "protheus.ch"
#include "fwmvcdef.ch"

/**{Protheus.doc} OGX115
@param: 	Nil
@author: 	
@since: 	
@Uso: 		SIGAFIN - Financeiro
@Alterado por: Marcelo R. Ferrari
@Data Alteração: 19/08/2014
**/
//Programa Original: ARMXPE08.PRW
Function OGX115()
Local aAreaAtu 	:= GetArea()
Local lTodas	:= .t.
Local cCodigo	:= ""
Local cItem		:= ""

If SE2->( E2_TIPO ) = "OPA"

	cCodigo := PadR( SE2->( E2_NUM )    , TamSX3( "NN6_CODOPG" )[1] )
	cItem 	:= PadR( SE2->( E2_PARCELA ), TamSX3( "NN6_ITEM"   )[1] )

	dbSelectArea( "NN6" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "NN6" ) + cCodigo + cItem )
		If RecLock( "NN6" )
			NN6_STATUS := "2"
			MsUnLock()
		EndIf
	EndIf
	dbGotop()
	If dbSeek( xFilial( "NN6" ) + cCodigo )
		While .Not. Eof() .And. NN6_FILIAL = xFilial( "NN6" ) .And. NN6_CODOPG = cCodigo
			If NN6_STATUS = "1"
				lTodas := .f.
				Exit
			EndIf
			dbSkip()
		EndDo
	EndIf

	dbSelectArea( "NN5" )
	dbSetOrder( 1 )
	If dbSeek( xFilial( "NN5" ) + cCodigo )
		If RecLock( "NN5" )
			If Empty( NN5_DTEXEC )
				NN5_DTEXEC := dDataBase
			EndIf
			NN5_STATUS := IIf( lTodas, "3", "2" )
			MsUnLock()
		EndIf
	EndIf

EndIf

RestArea( aAreaAtu )
Return( Nil )