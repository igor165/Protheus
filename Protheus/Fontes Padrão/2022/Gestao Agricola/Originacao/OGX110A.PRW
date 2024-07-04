#INCLUDE "OGX110.ch"
#Include 'Protheus.ch'

/**{Protheus.doc} OGX110
Validação na Inclusão de Títulos a Pagar
garantindo que o título a ser incluso já não exista
e também que esteja amarrado a um contrato.
@param: 	Nil
@author: 	Fernando Pereira Leite
@since: 	03/05/2013
@Uso: 		SIGAFIN - Financeiro
@Alterado por: Marcelo R. Ferrari
@Data Alteração: 19/08/2014
**/

//Programa Original: ARMXPE15.PRW

Function OGX110A()
Local cPrefixo		:= 	M->( E2_PREFIXO )
Local cNumero		:= 	Alltrim( M->( E2_NUM ))
Local cNewParc		:= ""

If IsBlind()
	Return ( .t. )
EndIf

If Empty( cNumero )
	Help( , , STR0001, ,STR0002, 1, 0 ) //"Ajuda"###"Favor informar o número do título!"
	Return ( .f. )
EndIf

If cPrefixo $ "CTR|FX1|FX2|OP |OPA|OR |ORA"

	NJR->( dbSetOrder( 1 ) )
	If NJR->( dbSeek( xFilial( "NJR" ) + cNumero ) )

		BeginSql Alias "QryT1"
			Select
				Max( E2_PARCELA ) As UltPar
			From
				%Table:SE2% SE2 
			Where
				SE2.E2_FILIAL = %xFilial:SE2% And
				SE2.E2_PREFIXO = %Exp:cPrefixo% And
				SE2.E2_NUM = %Exp:cNumero% And
				SE2.%notDel%
		EndSql

		If .Not. QryT1->( Eof() )
			cNewParc	:= Soma1( QryT1->( UltPar ) )
		Else
			cNewParc	:= Soma1( Replicate( "0", TamSX3( "E2_PARCELA" )[1] ) )
		EndIf
		QryT1->( dbCloseArea() )

		M->( E2_PARCELA ) := cNewParc

	Else
		Help( , , STR0001, ,STR0003+ cNumero+STR0004, 1, 0 ) //"Ajuda"###"Contrato: "###" não localizado!"
		Return ( .f. )
	EndIf

EndIf

Return ( .t. )