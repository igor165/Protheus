#INCLUDE "OGX006.ch"
#include "protheus.ch"


/** {Protheus.doc} OGX006A
Rotina para calculo do desconto baseado na tabela e percentual informado

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX006A( )
Local aAreaAtu		:= GetArea()
Local nX			:= 0
Local aAux			:= {}
Local aTabs			:= { 'DA3', 'DA4', 'DX5', 'DX6', 'NJH', 'NJF', 'NJG', 'SB1' } 

Local oRPCSrv		:= Nil
Local cRPCSrv 		:= '' 
Local nRPCPort		:= '' 
Local cRPCEnv		:= '' 
Local cRPCEmp		:= ''
Local cRPCFil		:= ''

//RPCSetType( 3 )
//RPCSetEnv( '99', '01', '', '', 'AGR', '', { 'NJH' } )

If .Not. SuperGetMV( 'MV_ARMRPCO', .f., .t. )
	Return( Nil )
EndIf

cRPCSrv 	:= SuperGetMV( 'MV_ARMRPCS', .f., '192.168.22.13' )
nRPCPort	:= SuperGetMV( 'MV_ARMRPCP', .f., 1155 )
cRPCEnv	:= GetEnvServer()
oRPCSrv 	:= FwRpc():New( cRPCSrv, nRPCPort, cRPCEnv )

If oRPCSrv:Connect( cRPCSrv, nRPCPort )
	cRPCEmp 	:= Substr( SuperGetMV( 'MV_ARMRPCE', .f., '9901' ), 1, 2 )
	cRPCFil 	:= Substr( SuperGetMV( 'MV_ARMRPCE', .f., '9901' ), 3, 2 )
	oRPCSrv:CallProc( 'RPCSetType', 3 )
	oRPCSrv:SetEnv( cRPCEmp, cRPCFil, 'AGR' )
Else
	Return( Nil )
EndIf

//aRegsON 	:= OGX006B( aTabs )
//aRegsOFF	:= oRPCSrv:CallProc("OGX006B", aTabs )

For nX := 1 to Len( aTabs )

	//If aRegsON[ nX ] < aRegsOFF[ nX ]
		/*
		* Necessario sincronizar esta tabela pois a tabela remota contem mais
		* registros que a tabela local
		*/
		aAux := oRPCSrv:CallProc("OGX006C", aTabs[ nX ] ) //Busca array com todos os registros da tabela
		OGX006D( aTabs[ nX ], aAux ) //Grava todos os registros na tabela

	//EndIf

Next nX

oRPCSrv:Disconnect()

RestArea( aAreaAtu )
Return( Nil )


/** {Protheus.doc} OGX006B
Rotina para calculo do desconto baseado na tabela e percentual informado

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX006B( aTabs )
Local aAreaAtu		:= GetArea()
Local aRegs			:= { }
Local nX			:= 0

Default aTabs		:= { } 

If Len( aTabs ) <= 0; Return( aRegs ); EndIf

For nX := 1 to Len( aTabs )

	dbSelectArea( aTabs[ nX ] )
	aAdd( aRegs, LastRec() )

Next nX

RestArea( aAreaAtu )
Return( aRegs )


/** {Protheus.doc} OGX006C
Rotina para calculo do desconto baseado na tabela e percentual informado

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX006C( cTab )
Local aAreaAtu		:= GetArea()
Local aCab			:= {}
Local aItens		:= {}
Local nX			:= 0
Local nY			:= 0

dbSelectArea( cTab )
For nX := 1 to FCount()
	aAdd( aCab, FieldName( nX ) )
Next nX

dbGoTop()
While .Not. Eof()

	nY ++
	aAdd( aItens, {} )
	For nX := 1 to FCount()
		aAdd( aItens[ nY ], &( FieldName( nX ) ) )
	Next nX

	dbSkip()
EndDo

RestArea( aAreaAtu )
Return( { aCab, aItens } )


/** {Protheus.doc} OGX006D
Rotina para calculo do desconto baseado na tabela e percentual informado

@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX006D( cTab, aAux )
Local aAreaAtu		:= GetArea()
Local aCab			:= {}
Local aItens		:= {}
Local nX			:= 0
Local nY			:= 0

If Len( aAux ) <= 0; Return( .f. ); EndIf

aCab		:= aAux[ 1 ]
aItens	:= aAux[ 2 ]

dbSelectArea( cTab )
dbCloseArea()
If ChkFile( cTab, .t. )
	Zap
Else
	Return( .f. )
EndIf

For nX := 1 to Len( aItens )

	RecLock( cTab, .t. )

	For nY := 1 to Len( aCab )
		&( aCab[ nY ] ) := aItens[ nX, nY ]
	Next nY	

	msUnLock()

Next nX

RestArea( aAreaAtu )
Return( .t. )


/** {Protheus.doc} OGX006E


@param: 	Nil
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGX006E( aPars )
Local cNewEmp	:= aPars[1]
Local cNewFil	:= aPars[2]
Local cTipo		:= aPars[3]
Local cCodigo	:= aPars[4]
Local cMsg		:= STR0001 + cCodigo 

FWLogMsg('INFO',, 'SIGAAGR', FunName(), '', '01',cMsg , 0, 0, {}) //"Iniciando Fechamento do Romaneio: "

RPCSetEnv( cNewEmp, cNewFil )

If cTipo $ "3"

	NJJ->( dbSetOrder( 4 ) )
	NJJ->( dbSeek( xFilial( "NJJ" ) + cCodigo ) )	

EndIf

If cTipo $ "6"

	NJJ->( dbSetOrder( 1 ) )
	NJJ->( dbSeek( xFilial( "NJJ" ) + cCodigo ) )	

EndIf

If cTipo $ "7"

	NJJ->( dbSetOrder( 4 ) )
	NJJ->( dbSeek( xFilial( "NJJ" ) + cCodigo ) )	

	If NJJ->( FieldPos( "NJJ_PROCDE" ) ) > 0

		NJJ->( dbSetOrder( 1 ) )
		If NJJ->( dbSeek( xFilial( "NJJ" ) + NJJ->( NJJ_PROCDE ) ) )

			If RecLock( "NJJ", .f. )
				NJJ->( NJJ_STATUS ) := "5"
				NJJ->( msUnLock() )
			Endif

		EndIf

	EndIf

EndIf

RPCClearEnv()

Return( Nil )
