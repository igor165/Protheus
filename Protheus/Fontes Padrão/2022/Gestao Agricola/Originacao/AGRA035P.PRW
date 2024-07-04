#INCLUDE "AGRA035P.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

/** {Protheus.doc} ARMA035P
Rotina para Cadastro de Tabelas de Descontos Agricolas

@param: 	Nil
@author: 	Fabiane Schulze
@since: 	05/11/2013
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function AGRA035P( cCodigo )
Local aAreaAtu	:= GetArea()
Local aAreaDXX	:= DXX->( GetArea() )
Local oDlg		:= Nil
Local oTab		:= Nil
Local cTab		:= Space( TamSX3( "NNI_CODIGO" )[1] )
Local aUsu		:= {}
Local nAcao		:= 0
Local nX		:= 0

If Empty( cCodigo )
	Return( Nil )
EndIf

oDlg 	:= TDialog():New( 0, 0, 25, 455, STR0001+ cCodigo ,,,,,CLR_BLACK,CLR_WHITE,,,.t.) //"Copiar permissões da tabela: "
oTab 	:= TGet():New( 01, 01, { |u| If( PCount() > 0, cTab := u, cTab ) } , oDlg, 080, 010, "@!", { || ExistCpo( "NNI", cTab ) .And. cTab <> cCodigo }, CLR_RED, CLR_WHITE, , .f., , .t., , .f., { || .t. }, .f., .f., , .f., .f., "NNI" ,"cTab", , , , )
oTButt 	:= TButton():New( 01, 85, STR0002, oDlg, { || nAcao := 1, oDlg:End() }, 040, 010, , , .f., .t., .f., , .f., , , .f. ) //"Confirma"
oDlg:Activate( , , , .t., { | | .t. }, , { || } )

If nAcao = 0
	Return( Nil )
EndIf

dbSelectArea( "DXX" )
dbSetOrder( 2 )
If dbSeek( FWxFilial( "DXX" ) + cCodigo )
	While .Not. Eof() .And. DXX->( DXX_CODTAB ) = cCodigo
		aAdd( aUsu, { DXX_CODUSU, DXX_NOMUSU } )
		dbSkip()
	EndDo
EndIf

If dbSeek( FWxFilial( "DXX" ) + cTab )
	While .Not. Eof() .And. DXX->( DXX_CODTAB ) = cTab
		If RecLock( "DXX", .f. )
			dbDelete()
			MsUnLock()
		EndIf
		dbSkip()
	EndDo
EndIf

For nX := 1 to Len( aUsu )

	If RecLock( "DXX", .t. )
		DXX_FILIAL := FWxFilial( "DXX" )
		DXX_CODTAB := cTab
		DXX_CODUSU := aUsu[ nX, 1 ]
		DXX_NOMUSU := aUsu[ nX, 2 ]
		MsUnLock()
	EndIf

Next nX

MsgAlert( STR0003 )  //"Copia realizada com sucesso!"


RestArea( aAreaDXX )
RestArea( aAreaAtu )
Return( Nil )