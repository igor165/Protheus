#INCLUDE "OGR262.CH"
#include "totvs.ch"

/** {Protheus.doc} OGR262
Extrato Armazenagem
@param: 	Nil
@author: 	Bruna Rocio
@since: 	05/01/2015
@Uso: 		SIGAAGR - Originação de Grãos
 */
Static __cPerg	:= "OGR262001" 
Static __aEnts := {} // Array de Entidades
	
Function OGR262()
 
	Local aAreaAtu 	:= GetArea()
	Local oReport		:= Nil

	If TRepInUse()

		Pergunte( __cPerg, .f. )
		oReport := ReportDef(__cPerg)
		oReport:PrintDialog()
	EndIf

	RestArea( aAreaAtu )
Return( Nil )

/** {Protheus.doc} ReportDef
*
@param: 	Nil
@author: 	Bruna Fagundes Rocio
@since: 	05/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
**/

Static Function ReportDef(__cPerg)

Local oReport			:= Nil
Local oSection1		:= Nil
Local oSection2		:= Nil
Local oSection3		:= Nil
Local oBreak2			:= Nil
Local oBreak1			:= Nil

oReport := TReport():New("OGR262", STR0001, __cPerg, {| oReport | PrintReport( oReport ) }, STR0002) 

/*
Seção 01 -   Cabeçalho
NKG_FILIAL  04
NKG_CODDEV  06
NKG_NOMDEV  40
NKG_LOJDEV  02
NKG_NLJDEV  25
NKG_CODSAF  15
NKG_CODPRO  15
NKG_DESPRO  30
NKG_UM1PRO  02
*/

oSection1 := TRSection():New( oReport, STR0003, { "NKG" } ) //Entidade
TRCell():New( oSection1, "NKG_FILIAL"	, "NKG")
TRCell():New( oSection1, "NKG_CODDEV"	, "NKG")
TRCell():New( oSection1, "NKG_NOMDEV"	, "NKG")
TRCell():New( oSection1, "NKG_NLJDEV"	, "NKG") 
TRCell():New( oSection1, "NKG_CODSAF"	, "NKG") 
TRCell():New( oSection1, "NKG_CODPRO"	, "NKG") 
TRCell():New( oSection1, "NKG_DESPRO"	, "NKG")
TRCell():New( oSection1, "NKG_UM1PRO"	, "NKG")

/*
Seção 02   -  Cobraça em Valor

Cobrança em Valor         // NKQ_TIPCOB = 0 

NKG_CODCTR  06
NKG_ITEMOV  08
NKG_CODROM  10
NKG_DOCSER  03
NKG_DOCNUM  09
NKG_DOCEMI  10
NKG_SERORI  03
NKG_NFORI   09
NKG_DATCAL  10
NKG_CODDES  03
NKG_DESDES  40
NKG_FATGER  07    // descrição
NKG_PERCOB  09    // descrição
NKG_DATINI  10
NKG_DATFIM  10
NKG_QTDPER  09
NKG_QTDBAS  12
NKG_VALTAR  15
NKG_UMTAR   02
NKG_QTDAJU  12
NKG_VALSER  12
NKG_STATUS  10
NKG_NFSER   09
NKG_SNFSER  03
*/


oSection2 := TRSection():New( oReport, STR0004, {"NKG"} ) //"Cálculo de Serviços"
TRCell():New( oSection2, "NKG_CODCTR" , "NKG",  "Contrat" ,     , 13)
TRCell():New( oSection2, "NKG_CODROM" , "NKG",            ,     , 25)
TRCell():New( oSection2, "NKG_DOCSER" , "NKG")
TRCell():New( oSection2, "NKG_DOCNUM" , "NKG",            ,     , 20) 
TRCell():New( oSection2, "DOCEMI" , ,"Trans."             ,     , 15)
TRCell():New( oSection2, "NKG_NFORI"  , "NKG",            ,     , 20)
TRCell():New( oSection2, "NKG_CODDES" , "NKG",STR0037   ,     , 6) // // "Desp"
TRCell():New( oSection2, "FATGER"     ,      , "FG"       ,"@!" , 7) 
TRCell():New( oSection2, "PERCOB"     ,      , "P"        ,"@!" , 5)
TRCell():New( oSection2, "DATINI" , , "Dt.Ini"            , "@!", 15)
TRCell():New( oSection2, "DATFIM" , , "Dt.Fim"            , "@!", 15) 
TRCell():New( oSection2, "NKG_QTDPER" , "NKG",            ,     , 25) 
TRCell():New( oSection2, "NKG_QTDBAS" , "NKG",            ,     , 25)
TRCell():New( oSection2, "NKG_VALTAR" , "NKG",            ,     , 25)
TRCell():New( oSection2, "NKG_UMTAR"  , "NKG", "UM"       ,     , 5)
TRCell():New( oSection2, "NKG_QTDAJU" , "NKG","Ajuste"    ,     , 25)
TRCell():New( oSection2, "NKG_VALSER" , "NKG",            ,     , 25)
TRCell():New( oSection2, "STATUS"     , 	   , "S"        ,"@!" , 5)
TRCell():New( oSection2, "NFSER"      ,      , "Doc.Serv" ,     , 20)

oBreak1  := TRBreak():New( oSection2, {||QryNKGV->(NKG_CODDES)}   , STR0031  )//"Total -->"
TRFunction():New(oSection2:Cell("NKG_QTDAJU")	, "T3", "SUM" , oBreak1, , , , .f., .f. )
TRFunction():New(oSection2:Cell("NKG_VALSER")	, "T4", "SUM" , oBreak1, , , , .f., .f. )

oBreak1a := TRBreak():New( oSection2, ""  , STR0008  )//"Total -->"
TRFunction():New(oSection2:Cell("NKG_QTDAJU")   , Nil, "SUM" , oBreak1a, , , , .f., .f. )
TRFunction():New(oSection2:Cell("NKG_VALSER")   , Nil, "SUM" , oBreak1a, , , , .f., .f. )

oBreak1:onBreak({|a,b| GetTotais(a, b, oBreak1, "oBreak1")}) // Evento acionado a cada quebra do Obreak1

/*
Seção 03 - Retenção 

NKG_CODCTR  06
NKG_ITEMOV  08
NKG_CODROM  10
NKG_DOCSER  03
NKG_DOCNUM  09
NKG_DOCEMI  10
NKG_SERORI  03
NKG_NFORI   09
NKG_DATCAL  10
NKG_CODDES  03
NKG_DESDES  40
NKG_FATGER  07    // descrição
NKG_PERCOB  09    // descrição
NKG_DATINI  10
NKG_DATFIM  10
NKG_QTDPER  09
NKG_QTDBAS  12
NKG_PERRET  09
NKG_QTDAJU  12
NKG_QTDRET  12
NKG_STATUS  10
NKG_ROMRET  10
*/

oSection3 := TRSection():New( oReport, STR0005, { "NKG" } ) //"Retenção"
TRCell():New( oSection3, "NKG_CODCTR" , "NKG", "Contrat" ,     , 13)
TRCell():New( oSection3, "NKG_CODROM" , "NKG",           ,     , 25)
TRCell():New( oSection3, "NKG_DOCSER" , "NKG")
TRCell():New( oSection3, "NKG_DOCNUM" , "NKG",           ,     , 20) 
TRCell():New( oSection3, "DOCEMI"     ,      ,"Trans."   ,     , 15)
TRCell():New( oSection3, "NKG_NFORI"  , "NKG",           ,     , 20)
TRCell():New( oSection3, "NKG_CODDES" , "NKG",STR0037  ,     , 6) // // "Desp"
TRCell():New( oSection3, "FATGER"     ,      , "FG"      , "@!", 7) 
TRCell():New( oSection3, "PERCOB"     ,      , "P"       , "@!", 5)
TRCell():New( oSection3, "DATINI"     ,      , "Dt.Ini"  , "@!", 15)
TRCell():New( oSection3, "DATFIM"     ,      , "Dt.Fim"  , "@!", 15) 
TRCell():New( oSection3, "NKG_QTDPER" , "NKG",           ,     , 25) 
TRCell():New( oSection3, "NKG_QTDBAS" , "NKG",           ,     , 25)
TRCell():New( oSection3, "NKG_UMTAR"  , "NKG", "UM"      ,     , 5)
TRCell():New( oSection3, "NKG_PERRET" , "NKG",           ,     , 15)
TRCell():New( oSection3, "NKG_QTDAJU" , "NKG","Ajuste"   ,     , 25)
TRCell():New( oSection3, "NKG_QTDRET" , "NKG",           ,     , 25)
TRCell():New( oSection3, "STATUS"     , 	   , "S"       , "@!", 5)
TRCell():New( oSection3, "ROMRET"     ,      , "Rom.Ret" , "@!", 20)

oBreak2 := TRBreak():New( oSection3, {||QryNKGR->(NKG_CODDES)}   , STR0031 )//"Total -->"
TRFunction():New(oSection3:Cell("NKG_QTDAJU")	, "T1", "SUM"		, oBreak2, , , , .f., .f. )
TRFunction():New(oSection3:Cell("NKG_QTDRET")	, "T2", "SUM"		, oBreak2, , , , .f., .f. )

oSectionTot1 := TRSection():New( oReport, STR0034, { "NKG" } ) // Totalizador por Filiais.

TRCell():New( oSectionTot1, "NKG_FILIAL"	, "NKG")
TRCell():New( oSectionTot1, "NKG_CODDEV"	, "NKG")
TRCell():New( oSectionTot1, "NKG_NOMDEV"	, "NKG") 
TRCell():New( oSectionTot1, "NKG_CODSAF"	, "NKG") 
TRCell():New( oSectionTot1, "NKG_CODPRO"	, "NKG") 
TRCell():New( oSectionTot1, "NKG_DESPRO"	, "NKG")
TRCell():New( oSectionTot1, "NKG_UM1PRO"	, "NKG")

oSectionTot2 := TRSection():New( oReport, STR0035, { "NKG" } ) // Totalizador por Tipo de Cobrança

TRCell():New( oSectionTot2, "TPCOBRANCA"	, "NKG", STR0036) // "TP Cobrança"
TRCell():New( oSectionTot2, "NKG_CODDES"	, "NKG", STR0037) // "Desp"
TRCell():New( oSectionTot2, "NKG_QTDAJU"	, "NKG", STR0038) // "Total Ajuste"
TRCell():New( oSectionTot2, "NKG_QTDRET"	, "NKG", STR0039) // "Total Qtd.Reten.S"
TRCell():New( oSectionTot2, "NKG_VALSER"	, "NKG", STR0040) // "Total Val.Serviço.S"

oBreak2a := TRBreak():New( oSection3, ""   , STR0008 )//"Total -->"
TRFunction():New(oSection3:Cell("NKG_QTDAJU")   , Nil, "SUM"        , oBreak2a, , , , .f., .f. )
TRFunction():New(oSection3:Cell("NKG_QTDRET")   , Nil, "SUM"        , oBreak2a, , , , .f., .f. )

oBreak2:onBreak({|a,b| GetTotais(a, b, oBreak2, "oBreak2")}) // Evento acionado a cada quebra do Obreak2

oReport:SetLandScape()
oReport:DisableOrientation()
oReport:oPage:setPaperSize(9) // 9 e 10 sao A4
	
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
Local oS3			:= oReport:Section( 3 )
Local oStot1		:= oReport:Section( 4 ) // Seção do totalizador por filiais
Local oStot2		:= oReport:Section( 5 ) // Seção do totalizador por tipo de cobranças

Local cFiltroImp := ""
Local cFiltro    := ""
Local nIt5			:= 0
Local nIt6 		:= 0

If oReport:Cancel()
	Return( Nil )
EndIf

If !(Empty(MV_PAR01))
	cFiltro += " AND NKG.NKG_FILIAL >= '" + MV_PAR01 + "' "
endif
If !(Empty(MV_PAR02))
	cFiltro += " AND NKG.NKG_FILIAL <= '" + MV_PAR02 + "' "
endif	
If !(Empty(MV_PAR07))
	cFiltro += " AND NKG.NKG_CODCTR >= '" + MV_PAR07 + "' "
endif
If !(Empty(MV_PAR08))
	cFiltro += " AND NKG.NKG_CODCTR <= '" + MV_PAR08 + "' "
endif
If !(Empty(MV_PAR03))
	cFiltro += " AND NKG.NKG_CODDEV >= '" + MV_PAR03 + "' "
endif
If !(Empty(MV_PAR05))
	cFiltro +=	 " AND NKG.NKG_CODDEV <= '" + MV_PAR05 + "' "
endif
If !(Empty(MV_PAR04))
	cFiltro += " AND NKG.NKG_LOJDEV >= '" + MV_PAR04 + "' "
endif
If !(Empty(MV_PAR06))
	cFiltro += " AND NKG.NKG_LOJDEV <= '" + MV_PAR06 + "' "
endif
If !(Empty(MV_PAR13))
	cFiltro += " AND NKG.NKG_CODPRO >= '" + MV_PAR13 + "' "
endif
If !(Empty(MV_PAR14))
	cFiltro += " AND NKG.NKG_CODPRO <= '" + MV_PAR14 + "' "
endif
If !(Empty(MV_PAR15))
	cFiltro += " AND NKG.NKG_CODSAF >= '" + MV_PAR15 + "' "
endif
If !(Empty(MV_PAR16))
	cFiltro += " AND NKG.NKG_CODSAF <= '" + MV_PAR16 + "' "
endif
If !(Empty(MV_PAR09))
	cFiltro += " AND NKG.NKG_CODTSE >= '" + MV_PAR09 + "' "
endif
If !(Empty(MV_PAR10))
	cFiltro += " AND NKG.NKG_CODTSE <= '" + MV_PAR10 + "' "
endif
If !(Empty(MV_PAR11))
	cFiltro += " AND NKG.NKG_CODDES >= '" + MV_PAR11 + "' "
endif
If !(Empty(MV_PAR12))
	cFiltro += " AND NKG.NKG_CODDES <= '" + MV_PAR12 + "' "
endif
If !(Empty(MV_PAR17))
	cFiltro += " AND NKG.NKG_DOCEMI >= '" + DTOS(MV_PAR17) + "' "
endif
If !(Empty(MV_PAR18))
	cFiltro += " AND NKG.NKG_DOCEMI <= '" + DTOS(MV_PAR18) + "' "
endif
If !(Empty(MV_PAR19))
	cFiltro += " AND NKG.NKG_DATCAL >= '" + DTOS(MV_PAR19) + "' "
endif
If !(Empty(MV_PAR20))
	cFiltro += " AND NKG.NKG_DATCAL <= '" + DTOS(MV_PAR20) + "' "
endif
If !(Empty(MV_PAR22))
    cFiltro += " AND NKG.NKG_DATFIM >= '" + DTOS(MV_PAR22) + "' "
endif
If !(Empty(MV_PAR23))
    cFiltro += " AND NKG.NKG_DATFIM <= '" + DTOS(MV_PAR23) + "' "
endif
	
cFiltro += GetStatus()	
cFiltro := "%" + cFiltro + "%"

oS1:BeginQuery()
	
oS1:Init()
BeginSql Alias "QryAux"
	Select
		NKG.NKG_FILIAL,  
		NKG.NKG_CODDEV,  
		NKG.NKG_LOJDEV,  
		NKG.NKG_CODSAF,  
		NKG.NKG_CODPRO,  
		NKG.NKG_UM1PRO	
	From
		%Table:NKG% NKG 
	Where
		NKG.%NotDel%
		%Exp:cFiltro% 
	Group By
		NKG.NKG_FILIAL,  
		NKG.NKG_CODDEV,  
		NKG.NKG_LOJDEV,  
		NKG.NKG_CODSAF,  
		NKG.NKG_CODPRO,  
		NKG.NKG_UM1PRO
EndSQL
oS1:EndQuery()

QryAux->( dbGoTop() )

/*******************************************************/
/********************** Filtro Impressão ***************/
/*******************************************************/

If !(Empty(MV_PAR07))
	cFiltroImp += " AND NKG.NKG_CODCTR >= '" + MV_PAR07 + "' "
endif
If !(Empty(MV_PAR08))
	cFiltroImp += " AND NKG.NKG_CODCTR <= '" + MV_PAR08 + "' "
endif
If !(Empty(MV_PAR09))
	cFiltroImp += " AND NKG.NKG_CODTSE >= '" + MV_PAR09 + "' "
endif	
If !(Empty(MV_PAR10))	
	cFiltroImp += " AND NKG.NKG_CODTSE <= '" + MV_PAR10 + "' "
endif
If !(Empty(MV_PAR11))
	cFiltroImp += " AND NKG.NKG_CODDES >= '" + MV_PAR11 + "' "
endif	
If !(Empty(MV_PAR12))
	cFiltroImp += " AND NKG.NKG_CODDES <= '" + MV_PAR12 + "' "
endif	
If !(Empty(MV_PAR17))
	cFiltroImp += " AND NKG.NKG_DOCEMI >= '" + DTOS(MV_PAR17) + "' "
endif	
If !(Empty(MV_PAR18))
	cFiltroImp += " AND NKG.NKG_DOCEMI <= '" + DTOS(MV_PAR18) + "' "
endif	
If !(Empty(MV_PAR19))
	cFiltroImp += " AND NKG.NKG_DATCAL >= '" + DTOS(MV_PAR19) + "' "
endif	
If !(Empty(MV_PAR20))
	cFiltroImp += " AND NKG.NKG_DATCAL <= '" + DTOS(MV_PAR20) + "' "
endif	
If !(Empty(MV_PAR22))
    cFiltroImp += " AND NKG.NKG_DATFIM >= '" + DTOS(MV_PAR22) + "' "
endif
If !(Empty(MV_PAR23))
    cFiltroImp += " AND NKG.NKG_DATFIM <= '" + DTOS(MV_PAR23) + "' "
endif
	
	
MaKeSqlExpr(__cPerg)	
cFiltroImp += GetStatus()	
cFiltroImp := "%" + cFiltroImp + "%"
/*******************************************************/

While .Not. QryAux->( Eof( ) )
	oS1:Init()
		
	oS1:Cell("NKG_NOMDEV"):SetValue( Posicione( "NJ0", 1, xFilial( "NJ0" ) + QryAux->NKG_CODDEV + QryAux->NKG_LOJDEV, "NJ0_NOME" ) )	
	oS1:Cell("NKG_NLJDEV"):SetValue( Posicione( "NJ0", 1, xFilial( "NJ0" ) + QryAux->NKG_CODDEV + QryAux->NKG_LOJDEV, "NJ0_NOMLOJ" ) )
	oS1:Cell("NKG_DESPRO"):SetValue( Posicione( "SB1", 1, xFilial( "SB1" ) + QryAux->NKG_CODPRO, "B1_DESC" ) )
		
	oS1:PrintLine()
	
	/************************************************************************************/
	/************************************************************************************/
	/*                                    Retenção                                      */
	/************************************************************************************/
	/************************************************************************************/
	oS3:BeginQuery()
	oS3:Init()
	
	BeginSql Alias "QryNKGR"
		Select 
			NKG.*
		From
			%Table:NKG% NKG
		Where
			NKG.%NotDel%
			AND NKG.NKG_FILIAL = %exp:QryAux->NKG_FILIAL%
			AND NKG.NKG_CODDEV = %exp:QryAux->NKG_CODDEV%
			AND NKG.NKG_LOJDEV = %exp:QryAux->NKG_LOJDEV%
			AND NKG.NKG_CODSAF = %exp:QryAux->NKG_CODSAF%
			AND NKG.NKG_CODPRO = %exp:QryAux->NKG_CODPRO%
			AND NKG.NKG_UM1PRO = %exp:QryAux->NKG_UM1PRO%
			AND NKG.NKG_QTRETC > 0
			%exp:cFiltroImp%
		Order By
			NKG.NKG_CODDES,
			NKG.NKG_CODCTR,
			NKG.NKG_CODROM,
			NKG.NKG_ITEMOV			
	EndSQL			
	oS3:EndQuery()
	
	QryNKGR->( dbGoTop() )
	
	if .Not. QryNKGR->(Eof()) //Verifica se tem registros... se não tem nao precisa imprimir o total.
		
		oS3:Init()
		While .Not. QryNKGR->(Eof())
			
			oS3:Cell("DOCEMI"):SetValue( FormatDate( QryNKGR->NKG_DOCEMI ) )				
			oS3:Cell("DATINI"):SetValue( FormatDate( QryNKGR->NKG_DATINI ) )		
			oS3:Cell("DATFIM"):SetValue( FormatDate( QryNKGR->NKG_DATFIM ) )
			oS3:Cell("FATGER"):SetValue( GetFatoGer(QryNKGR->NKG_FATGER) )
			oS3:Cell("PERCOB"):SetValue( GetPerCob(QryNKGR->NKG_PERCOB) )
			oS3:Cell("STATUS"):SetValue( GetAbrevStatus(QryNKGR->NKG_STATUS) )
			oS3:Cell("ROMRET"):SetValue( Posicione('NKS',1,xFilial('NKS')+QryNKGR->NKG_FECSER,'NKS_CODROM') )
			
			oS3:PrintLine()
			
			QryNKGR->( dbSkip() )
		EndDo
		
		oS3:Finish()	
		QryNKGR->( dbCloseArea() )
	endIF
	
	/************************************************************************************/
	/********************************  Cobrança Valor  **********************************/
	/************************************************************************************/
	
	oS2:BeginQuery()
	oS2:Init()
	
	BeginSql Alias "QryNKGV"
		Select 
			NKG.*
		From
			%Table:NKG% NKG
		Where
			NKG.%NotDel%
			AND NKG.NKG_FILIAL = %exp:QryAux->NKG_FILIAL%
			AND NKG.NKG_CODDEV = %exp:QryAux->NKG_CODDEV%
			AND NKG.NKG_LOJDEV = %exp:QryAux->NKG_LOJDEV%
			AND NKG.NKG_CODSAF = %exp:QryAux->NKG_CODSAF%
			AND NKG.NKG_CODPRO = %exp:QryAux->NKG_CODPRO%
			AND NKG.NKG_UM1PRO = %exp:QryAux->NKG_UM1PRO%
			AND NKG.NKG_VLTARC > 0
			%exp:cFiltroImp%
		Order By
			NKG.NKG_CODDES,
			NKG.NKG_CODCTR,
			NKG.NKG_CODROM,
			NKG.NKG_ITEMOV			
	EndSQL			
	oS2:EndQuery()
	
	QryNKGV->( dbGoTop() )
	
	if .Not. QryNKGV->(Eof()) //Verifica se tem registros... se não tem nao precisa imprimir o total.
	
		oS2:Init()
		While .Not. QryNKGV->(Eof())
				
			oS2:Cell("DOCEMI"):SetValue( FormatDate( QryNKGV->NKG_DOCEMI ) )	
			oS2:Cell("DATINI"):SetValue( FormatDate( QryNKGV->NKG_DATINI ) )		
			oS2:Cell("DATFIM"):SetValue( FormatDate( QryNKGV->NKG_DATFIM ) )		
			oS2:Cell("FATGER"):SetValue( GetFatoGer(QryNKGV->NKG_FATGER) )
			oS2:Cell("PERCOB"):SetValue( GetPerCob(QryNKGV->NKG_PERCOB) )
			oS2:Cell("STATUS"):SetValue( GetAbrevStatus(QryNKGV->NKG_STATUS) )
			oS2:Cell("NFSER") :SetValue( Posicione('NKS',1,xFilial('NKS')+QryNKGV->NKG_FECSER,'NKS_DOCNUM') )
			
			oS2:PrintLine()
			
			QryNKGV->( dbSkip() )
		EndDo
		
		oS2:Finish()	
		QryNKGV->( dbCloseArea() )
	
	endIF
	
	/**************************************************************************************/
				
	oS1:Finish()		
	QryAux->( dbSkip() )	
EndDo
	
QryAux->( dbCloseArea() )

//Impressão do Totalizador
For nIt5 := 1 To Len(__aEnts) // Totalizador por Filias - Entidades
	oSTot1:Init()
	osTot2:Init()
	
	oSTot1:Cell("NKG_FILIAL"):SetValue(__aEnts[nIt5][2][1])
	oSTot1:Cell("NKG_CODDEV"):SetValue(__aEnts[nIt5][2][2])
	oSTot1:Cell("NKG_NOMDEV"):SetValue(__aEnts[nIt5][2][3]) 
	oSTot1:Cell("NKG_CODSAF"):SetValue(__aEnts[nIt5][2][4]) 
	oSTot1:Cell("NKG_CODPRO"):SetValue(__aEnts[nIt5][2][5]) 
	oSTot1:Cell("NKG_DESPRO"):SetValue(__aEnts[nIt5][2][6])
	oSTot1:Cell("NKG_UM1PRO"):SetValue(__aEnts[nIt5][2][7])
	
	osTot1:PrintLine()
	
		For nIt6 := 1 To Len(__aEnts[nIt5][3]) // Totalizador por Tipo de Cobranças
			
			oSTot2:Cell("TPCOBRANCA"):SetValue(Iif((__aEnts[nIt5][3][nIt6][2] == "retencao"), STR0005, STR0043))
			oSTot2:Cell("NKG_CODDES"):SetValue(__aEnts[nIt5][3][nIt6][5])
			oSTot2:Cell("NKG_QTDAJU"):SetValue(__aEnts[nIt5][3][nIt6][3])
			
			If(__aEnts[nIt5][3][nIt6][2] == "retencao")
				oSTot2:Cell("NKG_QTDRET"):SetValue(__aEnts[nIt5][3][nIt6][4])
				oSTot2:Cell("NKG_VALSER"):SetValue(0)
			Else
				oSTot2:Cell("NKG_VALSER"):SetValue(__aEnts[nIt5][3][nIt6][4])
				oSTot2:Cell("NKG_QTDRET"):SetValue(0)
				
			EndIf
				
			oSTot2:PrintLine()
			
		Next nIt6
	
	oSTot1:Finish()
	osTot2:Finish()

Next nIt5
	
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
	
	cDat := cDia + "/" + cMes + "/" + cAno
	
Return ( cDat )

/** {Protheus.doc} GetAbrevStatus
Função para retornar a abreviação do status

@param: 	Nil
@author: 	Bruna Rocio
@since: 	07/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function GetAbrevStatus( pcSts )
	//"0=Pendente;1=Atualizado;2=Confirmado;3=Bonificado;9=Simulado" 
	Local cSts := ""
	
	If pcSts = '0'
		cSts := 'P'
	ElseIf pcSts = '1'
		cSts := 'A'
	ElseIf pcSts = '2' 
		cSts := 'C'
	ElseIf pcSts = '3'
		cSts := 'B'	
	Else
		cSts := 'S' 
	Endif

Return ( cSts )

/** {Protheus.doc} GetPerCob
Função para retornar a abreviação do periodo de cobrança

@param: 	Nil
@author: 	Bruna Rocio
@since: 	07/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function GetPerCob( pcCob )
	//"0=Diário;1=Quinzenal;2=Mensal"
	Local cPer := ""

	If pcCob = '0'
		cPer := 'D'
	ElseIf pcCob = '1'
		cPer := 'Q'
	Else
		cPer := 'M'
	End

Return ( cPer )

/** {Protheus.doc} GetFatoGer
Função para retornar a abreviação do fato gerador

@param: 	Nil
@author: 	Bruna Rocio
@since: 	07/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/
Static Function GetFatoGer( pcFat )
	//0=Entrada;1=Saída;2=Saldo
	
	Local cFat := ""
	
	If pcFat = '0'
		cFat := 'ENT'
	ElseIf pcFat = '1'
		cFat := 'SAI'
	Else
		cFat := 'SLD'
	End

Return ( cFat )

/** {Protheus.doc} GetStatus
Função para retornar os status selecionados no filtro

@param: 	Nil
@author: 	Bruna Rocio
@since: 	05/01/2014
@Uso: 		SIGAAGR - Originação de Grãos
*/

Static Function GetStatus()
		
	Local mvpar21	:= AllTrim( mv_par21 )
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
	
	If AT(cHifen, mvpar21) > 0 .And. AT(cPV, mvpar21) > 0 
		nTam  := Len(mvpar21)
		nPosH := AT(cHifen, mvpar21)
		hPosV := AT(cPV, mvpar21)
		
		cIni := SUBSTR(mvpar21, 1, (nPosH + 1))
		cFim := SUBSTR(mvpar21, (nPosH + 1), (nPosH + 1))
		
		For nY := Val(cIni) To Val(cFim)
			
			cAux := cValToChar(nY)
			aAdd( aTipos, cAux )
		Next nY
		
		cIni := SUBSTR(mvpar21, nPosV + 1, nTam)
		
		If Len(cIni) > 0
			For nX := 1 to Len( cIni )
			
				cAux := substr( cIni, nX, 1 )
				If cAux $ "0123456789"
					aAdd( aTipos, cAux )
				EndIf
			
			Next nX
					
			For nX := 1 to Len( aTipos )
				
				If nX = 1
					cFiltro += " AND ( NKG_STATUS = '" + aTipos[nX] + "'"
				Else
					cFiltro += " OR NKG_STATUS = '" + aTipos[nX] + "'"
				Endif			
			Next nX
			
			cFiltro := cFiltro + " ) "
		EndIf	
			
	ElseIf AT(cHifen, mvpar21) > 0
		nTam := Len(mvpar21)
		nPos := AT(cHifen, mvpar21)
		cIni := SUBSTR(mvpar21, 1, (nTam - nPos))
		cFim := SUBSTR(mvpar21, (nPos + 1), nTam)
		
		cFiltro += " AND NKG_STATUS >= '" + cIni + "'"
		cFiltro += " AND NKG_STATUS <= '" + cFim + "'"
		
	ElseIf AT(cPV, mvpar21) > 0
		If Len(mvpar21) > 0
			For nX := 1 to Len( mvpar21 )
			
				cAux := substr( mvpar21, nX, 1 )
				If cAux $ "0123456789"
					aAdd( aTipos, cAux )
				EndIf
			
			Next nX
					
			For nX := 1 to Len( aTipos )
				
				If nX = 1
					cFiltro += " AND ( NKG_STATUS = '" + aTipos[nX] + "'"
				Else
					cFiltro += " OR NKG_STATUS = '" + aTipos[nX] + "'"
				Endif			
			Next nX
			
			cFiltro := cFiltro + " ) "
		EndIf	
	Elseif Len(mvpar21) == 1
		cFiltro += " AND NKG_STATUS = '" + mvpar21 + "'"
	Endif
	
Return ( cFiltro )


// Função de interceptação de Obreak's, para popular o totalizador de serviços por entidade.
Static Function GetTotais(uBreakAnt, uBreakAtu, oBreaka, oBreakNam)
	Local nI1 := 0	
	Local nI2 := 0
	Local aServs := {}	 // Array de serviços para cada entidade contento retenção ou serviços.
 	
	nAtual := Val(QryAux->(NKG_CODDEV))
	
	nI1 := AScan(__aEnts, {|x| x[1]  == nAtual }) // Verifica se a entidade ja está presente no array.
	If( nI1 > 0) // Se a entidade estiver presente realiza a atualização dos serviços da mesma.
				nI2 := AScan(__aEnts[nI1][3], {|x| x[1]  == uBreakAnt + Iif((oBreakNam = "oBreak2"), "retencao","cobranca")}) // Verifica se contem o serviço e retorna a sua posicao
				If(nI2 > 0) // Se existe um serviço então atualiza o mesmo.
					If(oBreakNam = "oBreak2") // Atualiza Retenção.
						__aEnts[nI1][3][nI2][3] += oBreaka:GetFunction("T1"):UVALUE
						__aEnts[nI1][3][nI2][4] += oBreaka:GetFunction("T2"):UVALUE
					Else  // Atualiza o Valor Serviço.
						__aEnts[nI1][3][nI2][3] += oBreaka:GetFunction("T3"):UVALUE
						__aEnts[nI1][3][nI2][4] += oBreaka:GetFunction("T4"):UVALUE
					EndIf
				Else // Adiciona o serviço a entidade em questão caso o mesmo ainda não existir.
					aAdd(__aEnts[nI1][3], {uBreakAnt + Iif((oBreakNam = "oBreak2"), "retencao","cobranca"), ;
						Iif((oBreakNam = "oBreak2"), "retencao","cobranca"), ;
							oBreaka:GetFunction(Iif((oBreakNam = "oBreak2"), "T1","T3")):UVALUE, ;
						oBreaka:GetFunction(Iif((oBreakNam = "oBreak2"), "T2","T4")):UVALUE, uBreakAnt})
				EndIf	
	
	Else // Se a entidade não estiver presente no array de entidades, então adiciona a entidade e o serviço.
		
		aAdd(aServs, {uBreakAnt + Iif((oBreakNam = "oBreak2"), "retencao","cobranca"), ;
						Iif((oBreakNam = "oBreak2"), "retencao","cobranca"), ;
							oBreaka:GetFunction(Iif((oBreakNam = "oBreak2"), "T1","T3")):UVALUE, ;
						oBreaka:GetFunction(Iif((oBreakNam = "oBreak2"), "T2","T4")):UVALUE, uBreakAnt})
		
		aAdd(__aEnts, {nAtual, {QryAux->(NKG_FILIAL), QryAux->(NKG_CODDEV), ;
			Posicione( "NJ0", 1, xFilial( "NJ0" ) + QryAux->NKG_CODDEV + QryAux->NKG_LOJDEV, "NJ0_NOME" ), ;
			 QryAux->(NKG_CODSAF), QryAux->(NKG_CODPRO), ;
			 Posicione( "SB1", 1, xFilial( "SB1" ) + QryAux->NKG_CODPRO, "B1_DESC" ), ;
			  QryAux->(NKG_UM1PRO), QryNKGR->(NKG_DOCSER)}, aServs})
	
	EndIf
	
Return ()