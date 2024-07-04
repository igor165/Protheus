#Include 'OGX130.ch'
#Include 'Protheus.ch'

/**{Protheus.doc} OGX130
Validação na Inclusão de Títulos a receber
garantindo que o título a ser incluso já não exista
e também que esteja amarrado a um contrato.
@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	03/05/2013
@Uso: 		SIGAFIN - Financeiro
@Alterado Por: Marcelo R. Ferrari
Alterado em: 19/08/2014
**/
//Programa Original: ARMXPE14.PRW

Function OGX130A()
Local cPrefixo		:= 	M->( E1_PREFIXO )
Local cNumero		:= 	Alltrim( M->( E1_NUM ))
Local cNewParc		:= ""

If IsBlind()
	Return ( .t. )
EndIf

If Empty( cNumero )
	//Help( , , "Ajuda", ,"Favor informar o número do título!", 1, 0 )
	Help( , , STR0001, ,STR0002, 1, 0 )
	Return ( .f. )
EndIf

If cPrefixo $ "CTR|FX1|FX2|OP |OPA|OR |ORA"

	NJR->( dbSetOrder( 1 ) )
	If NJR->( dbSeek( xFilial( "NJR" ) + cNumero ) )

		BeginSql Alias "QryT1"
			Select
				Max( E1_PARCELA ) As UltPar
			From
				%Table:SE1% SE1 
			Where
				SE1.E1_FILIAL = %xFilial:SE1% And
				SE1.E1_PREFIXO = %Exp:cPrefixo% And
				SE1.E1_NUM = %Exp:cNumero% And
				SE1.%notDel%
		EndSql

		If .Not. QryT1->( Eof() )
			cNewParc	:= Soma1( QryT1->( UltPar ) )
		Else
			cNewParc	:= Soma1( Replicate( "0", TamSX3( "E1_PARCELA" )[1] ) )
		EndIf
		QryT1->( dbCloseArea() )

		M->( E1_PARCELA ) := cNewParc

	Else

		Help( , , STR0001, ,STR0003 + cNumero+ STR0004 , 1, 0 )
		Return ( .f. )

	EndIf

EndIf

Return ( .t. )