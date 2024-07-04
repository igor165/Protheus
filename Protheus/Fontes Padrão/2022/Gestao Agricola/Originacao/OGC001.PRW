#INCLUDE "OGC001.ch"
#include "protheus.ch"


/** {Protheus.doc} OGC001A
Rotina para consulta padrao da tabela de Ordens de Colheita do PIMS

@param: 	Nil
@return:	lRetorno - .t. - verdadeiro / .f. - falso
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Origina็ใo de Grใos
*/
Function OGC001A()
Local nOpcao     := 0

Private oDlg     := Nil
Private oBrowse  := Nil
Private aItens   := Array(1, 12)

Public __cCodigo := &( ReadVar() )

DEFINE MSDIALOG oDlg TITLE STR0001 PIXEL FROM 180,180 TO 550,700 //"Consulta Personalizada"

	oBrowse := TCBrowse():New( 01, 01, 260, 156, , {STR0002, STR0003, STR0004, STR0005, STR0006, STR0007, '', 'IDORDEM','IDTALHAO', 'HATALHAO', 'HAORDEM'} ,{50,50,50,50,50,50,50,50,50,50,50},oDlg,,,,,{|| nOpcao := oBrowse:nAt, oDlg:End() },,,,,,,.F.,,.T.,,.F.,,, ) //'Codigo'###'Data'###'Fazenda'###'Talhao'###'Variedade'###'Local'

	oBrowse:AddColumn( TCColumn():New( STR0008 	, { || aItens[oBrowse:nAt,1] }	,,,,"LEFT",,.F.,.T.,,,,.F.,) ) //'Ordem Colh.'
	oBrowse:AddColumn( TCColumn():New( STR0003   		, { || aItens[oBrowse:nAt,2] }	,,,,"LEFT",,.F.,.T.,,,,.F.,) ) //'Data'
	oBrowse:AddColumn( TCColumn():New( STR0009		, { || aItens[oBrowse:nAt,3] }	,,,,"LEFT",,.F.,.T.,,,,.F.,) ) //'Aglomerado'
	oBrowse:AddColumn( TCColumn():New( STR0004		, { || aItens[oBrowse:nAt,4] }	,,,,"LEFT",,.F.,.T.,,,,.F.,) ) //'Fazenda'
	oBrowse:AddColumn( TCColumn():New( STR0005 		, { || aItens[oBrowse:nAt,5] }	,,,,"LEFT",,.F.,.T.,,,,.F.,) ) //'Talhao'
	oBrowse:AddColumn( TCColumn():New( STR0006		, { || aItens[oBrowse:nAt,6] }	,,,,"LEFT",,.F.,.T.,,,,.F.,) ) //'Variedade'
	oBrowse:AddColumn( TCColumn():New( ' '      		, { || aItens[oBrowse:nAt,7] }	,,,,"LEFT",,.F.,.T.,,,,.F.,) )

	f001AItens( )

	TButton():New( 170, 012, STR0010		, oDlg,{|| nOpcao := oBrowse:nAt, oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Confirmar"
	TButton():New( 170, 054, STR0011			, oDlg,{|| nOpcao := 0,           oDlg:End() },40,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"
	TButton():New( 170, 132, STR0012 	, oDlg,{|| f001AItens( .t. )                 },50,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Mostrar Todas"
	TButton():New( 170, 184, STR0013	, oDlg,{|| f001AItens( .f. )                 },50,010,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Mostrar Minhas"

ACTIVATE DIALOG oDlg CENTERED

If nOpcao > 0
	__cCodigo := aItens[ nOpcao, 1 ]
EndIf

Return( .t. )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOGA010   บAutor  ณEquipe Agroindustria      บ Data ณ  12/07/2010 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para Cadastro de Produtores                          บฑฑ
ฑฑบ          ณ  Amarra entidades Cliente - Fornecedor                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณClientes Totvs                                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function f001AItens( lTodas )
Local aAreaAtu := GetArea()
Local cQuery   := ''
Local aTempo   := Array( 0 )
Local nX      := 1

cQuery += "Select"
cQuery += " V.NO_ORDCOLHEITA,"
cQuery += " V.DT_ORDEM,"
cQuery += " V.DE_UNI_ADM,"
cQuery += " V.DE_UPNIVEL1,"
cQuery += " V.CD_UPNIVEL3,"
cQuery += " V.DE_VARIEDADE "
cQuery += "From"
cQuery += " VW_ORDCOLH V "
cQuery += "Where"
cQuery += " V.FG_SITUACAO <> 'F' "
If .Not. lTodas
	cQuery += " And V.LOCAL = '" + SuperGetMv( "MV_ARM251B" , .f. , "#" ) + "'"
EndIf
cQuery += " Order by"
cQuery += " V.DE_UNI_ADM, V.DE_UPNIVEL1, V.CD_UPNIVEL3, V.DE_VARIEDADE"

dbUseArea(.t., 'TOPCONN', TCGenQry(,,cQuery),'TRB001', .f., .t.)
dbGoTop()
While .Not. Eof()

	aAdd( aTempo, {} )
	aAdd( aTempo[nX], NO_ORDCOLHEITA ) 												// [1] Codigo
	aAdd( aTempo[nX], DToC( SToD( DT_ORDEM ) ) ) 									// [2] Data
	aAdd( aTempo[nX], DE_UNI_ADM ) 													// [3] Aglomerado
	aAdd( aTempo[nX], DE_UPNIVEL1 ) 												// [4] Fazenda
	aAdd( aTempo[nX], CD_UPNIVEL3 ) 												// [5] Talhao
	aAdd( aTempo[nX], DE_VARIEDADE ) 												// [6] Variedade
	aAdd( aTempo[nX], '' ) 															// [7] Vazio

	nX++
	dbSkip()
EndDo
dbCloseArea()

aItens := aClone( aTempo )
oBrowse:SetArray( aItens )

RestArea( aAreaAtu )
Return( )


/** {Protheus.doc} OGC001E
Rotina para retorno do codigo e loja da entidade que representa a filial.

@param: 	cChvRet - Empresa/UN/Filial em que deseja consultar ( padrใo busca na empresa/UN/Filial atual )
@param: 	cInfRet - Informa็๕es de retorno solicitadas [ C = Codigo, L = Loja, A = Ambos ]
@param: 	cTipRet - Tipo do retorno [ A = Array, C = Caracter ]
@return:	xRetorno - Retorno conforme solicitado
@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Origina็ใo de Grใos
*/
Function OGC001E( cChvRet, cInfRet, cTipRet )
Local xRetorno	:= Nil
Local aAreaAtu	:= GetArea()
Local aAreaNJ0	:= NJ0->( GetArea() )

Default cInfRet	:= "A"
Default cTipRet	:= "C"
Default cChvRet	:= cEmpAnt + cFilAnt

dbSelectArea( "NJ0" )
dbSetOrder( 5 )
If dbSeek( xFilial( "NJ0" ) + cChvRet )

	Do Case
		Case cTipRet = "A"
			xRetorno := {}
		Case cTipRet = "C"
			xRetorno := ""
	EndCase

	Do Case
		Case cTipRet = "C" .And. cInfRet = "C"
			xRetorno := NJ0->( NJ0_CODIGO )
		Case cTipRet = "C" .And. cInfRet = "L"
			xRetorno := NJ0->( NJ0_LOJA )
		Case cTipRet = "C" .And. cInfRet = "A"
			xRetorno := NJ0->( NJ0_CODIGO ) + NJ0->( NJ0_LOJA )
		Case cTipRet = "A"
			aAdd( xRetorno, NJ0->( NJ0_CODIGO ) )
			aAdd( xRetorno, NJ0->( NJ0_LOJA   ) )
	EndCase

EndIf

RestArea( aAreaNJ0 )
RestArea( aAreaAtu )
Return( xRetorno )


/** {Protheus.doc} OGC001F
Rotina para calculo de tributacao sobre movimentacao

@param: 	cTipo 		- Tipo do Documento "E" Entrada e "S" Saida
@param: 	cTipoDoc 	- Tipo do Documento "N" Normal e "D" Devolucao e "B" Beneficiamento
@param: 	cCliFor 	- Codigo do Cliente ou Fornecedor
@param: 	cLojaCF 	- Loja do Cliente ou Fornecedor
@param: 	cTipoCF 	- Tipo se "C" Cliente ou "F" Fornecedor
@param: 	cCodPro 	- Codigo do Produto
@param: 	nQtdPro 	- Quantidade do Produto
@param: 	nVlrUni 	- Valor Unitario do Produto
@param: 	nVlrTot 	- Valor Total do Produto
@param: 	cTES 		- Tipo de Entrada/Saida

@return:	aRetorno 	- Array dos Impostos Calculados
@return:	aRetorno 	- Array[1,1] Codigo do Imposto Ex.: ICM
@return:	aRetorno 	- Array[1,2] Descri็ใo do Imposto Ex.: ICMS Substituto
@return:	aRetorno 	- Array[1,3] Base para Calculo do Imposto
@return:	aRetorno 	- Array[1,4] Aliquota para Calculo do Imposto
@return:	aRetorno 	- Array[1,5] Valor do Imposto

@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Origina็ใo de Grใos
*/
Function OGC001F( cTipo, cTipoDoc, cCliFor, cLojaCF, cTipoCF, cCodPro, nQtdPro, nVlrUni, nVlrTot, cTES )
Local aAreaAtu		:= GetArea()
Local aRetorno		:= {}
 
MaFisSave()
MaFisEnd()

If cTipo = "E"
	MaFisIni( cCliFor, cLojaCF, cTipoCF, cTipoDoc, Nil, MaFisRelImp( "MT100", { "SF1", "SD1" } ), , .t., NIL, NIL, NIL )
EndIf

If cTipo = "S"
	MaFisIni( cCliFor, cLojaCF, cTipoCF, cTipoDoc, "MATA461", , , .t., NIL, NIL, NIL )
EndIf

MaFisAdd( cCodPro, cTes, nQtdPro, nVlrUni, 0, "", "", 0, 0, 0, 0, 0, nVlrTot, 0 )

aAdd( aRetorno, MaFisNFCab() )
aAdd( aRetorno, MaFisRet( , "NF_BASEDUP" )   )

MaFisEnd()
MaFisRestore()

RestArea(aAreaAtu)
Return( aRetorno )


/** {Protheus.doc} OGC001R
Rotina para calculo de tributacao sobre movimentacao

@param: 	cCodCRP		- Codigo da Empresa/Filial que se deja obter a Entidade

@return:	aRetorno 	- Array[1] Codigo da Entidade
@return:	aRetorno 	- Array[2] Loja da Entidade

@author: 	Equipe Agroindustria
@since: 	08/06/2010
@Uso: 		SIGAAGR - Origina็ใo de Grใos
*/
Function OGC001R( cCodCRP )
Local aRetorno	:= {}

Default cCodCRP	:= cFilAnt

BeginSql Alias 'QryNJ0'
	Select NJ0.NJ0_CODIGO, NJ0.NJ0_LOJA
	From %table:NJ0% NJ0
	Where NJ0.NJ0_FILIAL = %xFilial:NJ0% And NJ0.NJ0_CODCRP = %exp:cCodCRP% And NJ0.%NotDel%
EndSql
If QryNJ0->( Eof() )
	MsgAlert( STR0014 ) //"Nใo existe nenhuma Entidade cadastrada para a Empresa/Filial!"
Else
	aRetorno := { QryNJ0->( NJ0_CODIGO ), QryNJ0->( NJ0_LOJA ) }
EndIf
QryNJ0->( dbCloseArea( ) )

Return( aRetorno )