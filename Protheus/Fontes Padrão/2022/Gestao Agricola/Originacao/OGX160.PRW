#INCLUDE "OGX160.ch"
#include "protheus.ch"


/** {Protheus.doc} OGX160
Rotina chamada através do Ponto de Entrada de Validação do Numero da Nota Fiscal de Saida ( MATA620 )

@param: 	ParamIXB[1] - Numero da Nota Fiscal Infromado pelo Usuario
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Originação de Grãos
@Alterado Por: Marcelo R. Ferrari
@Alterado em: 20/08/2014
*/
//Programa Original: ARMXPE12 
Function OGX160( cNumero, cSerie )
Local lRetorno	:= .t.
Local nDigitos	:= SuperGetMv( "MV_ARMNFDG", .f., 0 )

If Len( AllTrim( cNumero ) ) < nDigitos
	lRetorno := .f.
	Alert( STR0001 + AllTrim( Str( nDigitos ) ) + STR0002 ) //"Numero da Nota Fiscal deve ter "###" digitos!"
EndIf

If lRetorno
	If .Not. Empty( cSerie ) .And. .Not. Empty( cNumero )
	      BeginSql Alias 'QrySF2'
	          Select Count( * ) As Total 
	          From %table:SF2% 
	          Where F2_FILIAL = %xFilial:SF2% And F2_SERIE = %exp:cSerie% And F2_DOC = %exp:cNumero% And %NotDel%
	      EndSql
	      If .Not. QrySF2->( Eof() ) .And. QrySF2->( Total ) > 0
	          Help(, , STR0003, , STR0004, 1, 0 ) //"Ajuda"###"Já existe um documento de saída com mesmo Número e Série. Favor verificar!"
	          lRetorno := .f.
	      EndIf
	      QrySF2->( dbCloseArea( ) )
	  EndIf
EndIf

If lRetorno
	If .Not. Empty( cSerie ) .And. .Not. Empty( cNumero )
	      BeginSql Alias 'QrySF1'
	          Select Count( * ) As Total 
	          From %table:SF1% 
	          Where F1_FILIAL = %xFilial:SF1% And F1_SERIE = %exp:cSerie% And F1_DOC = %exp:cNumero% And F1_FORMUL = 'S' And %NotDel%
	      EndSql
	      If .Not. QrySF1->( Eof() ) .And. QrySF1->( Total ) > 0
	          Help(, , STR0003, , STR0005, 1, 0 ) //"Ajuda"###"Já existe um documento de entrada com mesmo Número e Série. Favor verificar!"
	          lRetorno := .f.
	      EndIf
	      QrySF1->( dbCloseArea( ) )
	EndIf
EndIf

Return( lRetorno )