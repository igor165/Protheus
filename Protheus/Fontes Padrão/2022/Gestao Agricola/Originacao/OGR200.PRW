#INCLUDE "OGR200.CH"
#include "totvs.ch"

/** {Protheus.doc} OGR200
Controle Reservas

@param: 	Nil
@author: 	Vinícius Becher Pagung
@since: 	12/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
 */

Function OGR200()

	Local aAreaAtu 	:= GetArea()
	Local oReport		:= Nil
	Private cPergunta	:= "OGR200001"
							
	If TRepInUse()

		Pergunte( cPergunta, .f. )
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf

	RestArea( aAreaAtu )
Return( Nil )

/** {Protheus.doc} ReportDef
*
@param: 	Nil
@author: 	Vinícius Becher Pagung
@since: 	12/12/2014
@Uso: 		SIGAAGR - Originação de Grãos
**/

Static Function ReportDef()

Local oReport			:= Nil
Local oSection1		:= Nil
Local oSection2		:= Nil

oReport := TReport():New("OGR200", STR0001, cPergunta, {| oReport | PrintReport( oReport ) }, STR0002)

/*
Seção 01 - Cabeçalho
NJB->NJB_FILIAL
NJB->NJB_CODPRO
NJB_DESPRO(Posicione)
NJB->NJB_UM1PRO
NJB->NJB_CODTER
NJB_NOMTER(Posicione)
NJB_LOJTER
*/

oSection1 := TRSection():New( oReport, STR0001, { "NJB" } ) //Reservas
TRCell():New( oSection1, "NJB_FILIAL"	, "NJB")
TRCell():New( oSection1, "NJB_CODPRO"	, "NJB")
TRCell():New( oSection1, "NJB_DESPRO"	, "NJB")
TRCell():New( oSection1, "NJB_UM1PRO" , "NJB")
TRCell():New( oSection1, "NJB_CODTER"	, "NJB") 
TRCell():New( oSection1, "NJB_NOMTER"	, "NJB") 
TRCell():New( oSection1, "NJB_LOJTER"	, "NJB")


/*
Seção 02 - Detalhe das Reservas
NJB->NJB_DATRES 
NJB->NJB_CODENT
NJB_NOMENT(Posicione)
NJB->NJB_TIPRES
NJB->NJB_STATUS
NJB->NJB_AVALIA
NJB->NJB_DATLIB
NJB->NJB_CODROM
NJB->NJB_QTDTOT
NJB->NJB_QTDCRE
NJB->NJB_PERRET
NJB->NJB_QTDPRO
NJB->NJB_OBSLIB
*/

oSection2 := TRSection():New( oReport, STR0001, { "NJB" } ) //"Relatório de Reservas"
TRCell():New( oSection2, "DATRES"     ,      , "Dt.Res."  ,     , 12)
TRCell():New( oSection2, "NJB_CODENT" , "NJB", "Cod.Ent." ,     , 10)
TRCell():New( oSection2, "NJB_NOMENT" , "NJB",            ,     , 30)
TRCell():New( oSection2, "NJB_TIPRES" , "NJB", "Tip."     ,     ,  4)
TRCell():New( oSection2, "STATUS"     , 	   , "S"        ,"@!" ,  2)
TRCell():New( oSection2, "AVALIA"     , 	   , "A"        ,"@!" ,  2)
TRCell():New( oSection2, "DATLIB"     ,      , "Dt.Lib."  ,     , 12)
TRCell():New( oSection2, "NJB_CODROM" , "NJB",            ,     , 18)
TRCell():New( oSection2, "NJB_QTDTOT" , "NJB",            ,     , 20) 
TRCell():New( oSection2, "NJB_QTDCRE" , "NJB",            ,     , 20)
TRCell():New( oSection2, "NJB_PERRET" , "NJB", "% Ret"    ,     ,  6)
TRCell():New( oSection2, "NJB_QTDPRO" , "NJB",            ,     , 20)
TRCell():New( oSection2, "NJB_OBSLIB" , "NJB",            ,     , 25)

oBreak1 := TRBreak():New( oSection2, "", STR0003, .f. )//"Total -->"
TRFunction():New(oSection2:Cell("NJB_QTDTOT")	, Nil, "SUM" , oBreak1, , , , .f., .f. )
TRFunction():New(oSection2:Cell("NJB_QTDCRE")	, Nil, "SUM" , oBreak1, , , , .f., .f. )
TRFunction():New(oSection2:Cell("NJB_QTDPRO")	, Nil, "SUM" , oBreak1, , , , .f., .f. )

Return( oReport )

/** {Protheus.doc} PrintReport

@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	05/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
**/

Static Function PrintReport( oReport )

Local aAreaAtu	:= GetArea()
Local oS1			:= oReport:Section( 1 )
Local oS2			:= oReport:Section( 2 )

Local cDataDe		:= DtoS( mv_par11 )
local cDataAte	:= DtoS( mv_par12 )
Local cFiltroImp := ""

If oReport:Cancel()
	Return( Nil )
EndIf

cFiltro := " AND NJB.NJB_FILIAL  = '" + xFilial( 'NJB' ) + "'"
cFiltro += " AND NJB.NJB_CODENT >= '" + MV_PAR01 + "' "
cFiltro += " AND NJB.NJB_CODENT <= '" + MV_PAR03 + "' "
cFiltro += " AND NJB.NJB_LOJENT >= '" + MV_PAR02 + "' "
cFiltro += " AND NJB.NJB_LOJENT <= '" + MV_PAR04 + "' "
cFiltro += " AND NJB.NJB_CODTER >= '" + MV_PAR05 + "' "
cFiltro += " AND NJB.NJB_CODTER <= '" + MV_PAR07 + "' "
cFiltro += " AND NJB.NJB_LOJTER >= '" + MV_PAR06 + "' "
cFiltro += " AND NJB.NJB_LOJTER <= '" + MV_PAR08 + "' "
cFiltro += " AND NJB.NJB_CODPRO >= '" + MV_PAR09 + "' "
cFiltro += " AND NJB.NJB_CODPRO <= '" + MV_PAR10 + "' "
cFiltro += " AND NJB.NJB_DATRES >= '" + cDataDe  + "' "
cFiltro += " AND NJB.NJB_DATRES <= '" + cDataAte + "' "

If MV_PAR14 = 1 //Avaliada
	cFiltro += " AND NJB.NJB_AVALIA = '1' "
ElseIf MV_PAR14 = 2 //Não Avaliada
	cFiltro += " AND NJB.NJB_AVALIA = '0' "
EndIf

cFiltro += GetStatus()	
cFiltro := "%" + cFiltro + "%"

oS1:BeginQuery()
	
oS1:Init()
BeginSql Alias "QryAux"
	Select
		NJB.NJB_FILIAL,
		NJB.NJB_CODPRO,		
		NJB.NJB_UM1PRO,
		NJB.NJB_CODTER,
		NJB.NJB_LOJTER
	From
		%Table:NJB% NJB 
	Where
		NJB.%NotDel%
		%Exp:cFiltro% 
	Group By
		NJB.NJB_FILIAL,
		NJB.NJB_CODPRO,		
		NJB.NJB_UM1PRO,
		NJB.NJB_CODTER,
		NJB.NJB_LOJTER
EndSQL
oS1:EndQuery()

QryAux->( dbGoTop() )

/*******************************************************/
/********************** Filtro Impressão ***************/
/*******************************************************/

cFiltroImp += "     NJB.NJB_CODENT >= '" + MV_PAR01 + "' "
cFiltroImp += " AND NJB.NJB_CODENT <= '" + MV_PAR03 + "' "
cFiltroImp += " AND NJB.NJB_LOJENT >= '" + MV_PAR02 + "' "
cFiltroImp += " AND NJB.NJB_LOJENT <= '" + MV_PAR04 + "' "
cFiltroImp += " AND NJB.NJB_DATRES >= '" + cDataDe  + "' "
cFiltroImp += " AND NJB.NJB_DATRES <= '" + cDataAte + "' "

If MV_PAR14 = 1 //Avaliada
	cFiltroImp += " AND NJB.NJB_AVALIA = '1' "
ElseIf MV_PAR14 = 2 //Não Avaliada
	cFiltroImp += " AND NJB.NJB_AVALIA = '0' "
EndIf

cFiltroImp += GetStatus()	
cFiltroImp := "%" + cFiltroImp + "%"
/*******************************************************/

While .Not. QryAux->( Eof( ) )
	oS1:Init()
	
	oS1:Cell("NJB_DESPRO"):SetValue(Posicione('SB1',1,xFilial('SB1')+QryAux->NJB_CODPRO,'B1_DESC'))
	oS1:Cell("NJB_NOMTER"):SetValue(Posicione('NJ0',1,xFilial('NJ0')+QryAux->NJB_CODTER+QryAux->NJB_LOJTER,'NJ0_NOME'))    
	
	oS1:PrintLine()
	
	/************************************************************************************/
	/********************************  Detalhe reservas *********************************/
	/************************************************************************************/
	
	oS2:BeginQuery()
	oS2:Init()
	
	BeginSql Alias "QryNJB"
		Select 
			NJB.*
		From
			%Table:NJB% NJB
		Where
			NJB.%NotDel%
			AND NJB.NJB_FILIAL = %exp:QryAux->NJB_FILIAL%
			AND NJB.NJB_CODPRO = %exp:QryAux->NJB_CODPRO%
			AND NJB.NJB_UM1PRO = %exp:QryAux->NJB_UM1PRO%
			AND NJB.NJB_CODTER = %exp:QryAux->NJB_CODTER%
			AND NJB.NJB_LOJTER = %exp:QryAux->NJB_LOJTER%
			AND %exp:cFiltroImp%
		Order By
			NJB.NJB_DATRES,
			NJB.NJB_CODENT,
			NJB.NJB_CODROM			
	EndSQL			
	oS2:EndQuery()
	
	QryNJB->( dbGoTop() )
	oS2:Init()
	While .Not. QryNJB->(Eof())
		
		oS2:Cell("NJB_NOMENT"):SetValue(Posicione('NJ0',1,xFilial('NJ0')+QryNJB->NJB_CODENT+QryNJB->NJB_LOJENT,'NJ0_NOME'))	
		oS2:Cell("DATRES"):SetValue( FormatDate( QryNJB->NJB_DATRES ) )
		oS2:Cell("DATLIB"):SetValue( FormatDate( QryNJB->NJB_DATLIB ) )
		oS2:Cell("STATUS"):SetValue( GetAbrevStatus(QryNJB->NJB_STATUS) )
		oS2:Cell("AVALIA"):SetValue( GetAbrevAvalia(QryNJB->NJB_AVALIA) )
		
		oS2:PrintLine()
		
		QryNJB->( dbSkip() )
	EndDo
	QryNJB->( dbCloseArea() )
	oS2:Finish()	
	
	/**************************************************************************************/
		
	oS1:Finish()
			
	QryAux->( dbSkip() )	
EndDo
	
QryAux->( dbCloseArea() )
	
RestArea(aAreaAtu)
	
Return( )


/** {Protheus.doc} FormatDate

@param: 	pcDate - Recebe data no formato string AAAAMMDD
@author: 	Bruna Rocio
@since: 	08/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function FormatDate( pcDate )

	Local cDat := ""
	Local cDia := AllTrim(STRZERO(DAY(pcDate),2))
	Local cMes := AllTrim(STRZERO(MONTH(pcDate),2))
	Local cAno := AllTrim(STRZERO(YEAR(pcDate),4))
	cAno := SUBSTR(cAno,3,2)
	
	if !Empty(pcDate)
		cDat := cDia + "/" + cMes + "/" + cAno
	endif
	
Return ( cDat )

/** {Protheus.doc} GetAbrevStatus
Função para retornar a abreviação do status

@param: 	Nil
@author: 	Bruna Rocio
@since: 	07/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function GetAbrevStatus( pcSts )
	//0=Solicitado;1=Reservado;2=Liberado;3=Cancelado
	Local cSts := ""
	
	If pcSts = '0'
		cSts := 'S'
	ElseIf pcSts = '1'
		cSts := 'R'
	ElseIf pcSts = '2' 
		cSts := 'L'
	Else 
		cSts := 'C'	
	Endif

Return ( cSts )

/** {Protheus.doc} GetAbrevStatus
Função para retornar a abreviação da avaliação

@param: 	Nil
@author: 	Bruna Rocio
@since: 	07/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function GetAbrevAvalia( pcAva )
	//"0=Não;1=Sim" 
	Local cAva := ""
	
	If pcAva = '0'
		cAva := 'N'
	Else
		cAva := 'S'	
	Endif

Return ( cAva )

/** {Protheus.doc} GetStatus
Função para retornar os status selecionados no filtro

@param: 	Nil
@author: 	Bruna Rocio
@since: 	05/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function GetStatus()
		
	Local mvpar13	:= AllTrim( mv_par13 )
	Local aTipos	:= {}
	Local nX		:= 0
	Local cFiltro := ""
	Local cHifen  := "-"
	Local cPV     := ";"
	Local nPos    := 0
	Local nPosH   := 0
	Local nPosV   := 0
	Local cIni    := ""
	Local cFim    := ""
	Local nTam    := 0
	Local nY      := 0
	
	If AT(cHifen, mvpar13) > 0 .And. AT(cPV, mvpar13) > 0 
		nTam  := Len(mvpar13)
		nPosH := AT(cHifen, mvpar21)
		hPosV := AT(cPV, mvpar13)
		
		cIni := SUBSTR(mvpar13, 1, (nPosH + 1))
		cFim := SUBSTR(mvpar13, (nPosH + 1), (nPosH + 1))
		
		For nY := Val(cIni) To Val(cFim)
			
			cAux := cValToChar(nY)
			aAdd( aTipos, cAux )
		Next nY
		
		cIni := SUBSTR(mvpar13, nPosV + 1, nTam)
		
		If Len(cIni) > 0
			For nX := 1 to Len( cIni )
			
				cAux := substr( cIni, nX, 1 )
				If cAux $ "0123456789"
					aAdd( aTipos, cAux )
				EndIf
			
			Next nX
					
			For nX := 1 to Len( aTipos )
				
				If nX = 1
					cFiltro += " AND ( NJB_STATUS = '" + aTipos[nX] + "'"
				Else
					cFiltro += " OR NJB_STATUS = '" + aTipos[nX] + "'"
				Endif			
			Next nX
			
			cFiltro := cFiltro + " ) "
		EndIf	
			
	ElseIf AT(cHifen, mvpar13) > 0
		nTam := Len(mvpar13)
		nPos := AT(cHifen, mvpar13)
		cIni := SUBSTR(mvpar13, 1, (nTam - nPos))
		cFim := SUBSTR(mvpar13, (nPos + 1), nTam)
		
		cFiltro += " AND NJB_STATUS >= '" + cIni + "'"
		cFiltro += " AND NJB_STATUS <= '" + cFim + "'"
		
	ElseIf AT(cPV, mvpar13) > 0
		If Len(mvpar13) > 0
			For nX := 1 to Len( mvpar13 )
			
				cAux := substr( mvpar13, nX, 1 )
				If cAux $ "0123456789"
					aAdd( aTipos, cAux )
				EndIf
			
			Next nX
					
			For nX := 1 to Len( aTipos )
				
				If nX = 1
					cFiltro += " AND ( NJB_STATUS = '" + aTipos[nX] + "'"
				Else
					cFiltro += " OR NJB_STATUS = '" + aTipos[nX] + "'"
				Endif			
			Next nX
			
			cFiltro := cFiltro + " ) "
		EndIf	
	Endif
	
Return ( cFiltro )



