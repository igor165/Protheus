//#INCLUDE "OGR263.CH"
#include "totvs.ch"

/** {Protheus.doc} OGR263
Documento de entrada e saida sem contrato vinculado.

@param: 	Nil
@author: 	Vitor Alexandre de Barba
@since: 	04/05/2015
@Uso: 		SIGAAGR - Originação de Grãos
 */

Function OGR263()

	Local aAreaAtu 	:= GetArea()
	Local oReport		:= Nil
	Private cPergunta	:= "OGR263001"
	
	If TRepInUse()
		oReport := ReportDef()
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

Static Function ReportDef()

Local oReport			:= Nil
Local oSection1		:= Nil

oReport := TReport():New("OGR263", "Documentos sem Romaneio", cPergunta, {| oReport | PrintReport( oReport ) }, "Documentos sem Romaneio" ) 

oSection1 := TRSection():New( oReport, " ", { } ) //"Documentos Entrada"
TRCell():New( oSection1, "TIPO"     	,      , "Tip"	, "@!"	,03 ) 
TRCell():New( oSection1, "NJ0_CODENT"	, "NJ0", 			, 		,TamSX3("NJ0_CODENT")[1] )
TRCell():New( oSection1, "NJ0_LOJENT"	, "NJ0", 			, 		,TamSX3("NJ0_LOJENT")[1] )
TRCell():New( oSection1, "NJ0_NOME"	, "NJ0", 			, 		,20 ) 
TRCell():New( oSection1, "NJ0_NOMLOJ"	, "NJ0", 			,		,20 ) 
TRCell():New( oSection1, "D1_TES" 		, "SD1", "TES"	, "@!"	,TamSX3("D1_TES")[1] ) 
TRCell():New( oSection1, "D1_CF" 		, "SD1", "CF"		, "@!"	,TamSX3("D1_CF")[1] ) 
TRCell():New( oSection1, "D1_DOC" 		, "SD1", 			, 		,TamSX3("D1_DOC")[1] )
TRCell():New( oSection1, "D1_SERIE" 	, "SD1", 			, 		,TamSX3("D1_SERIE")[1] )
TRCell():New( oSection1, "D1_EMISSAO" 	, "SD1", "Dt.Emi"	, 		,10 )
TRCell():New( oSection1, "D1_COD" 		, "SD1", 			, 		,TamSX3("D1_COD")[1] )
TRCell():New( oSection1, "B1_DESC" 	, "SB1", 			,		,20 ) 
TRCell():New( oSection1, "D1_QUANT" 	, "SD1") 
TRCell():New( oSection1, "D1_TOTAL" 	, "SD1")


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
Local nRecCount	:= 0
Local cFiltroImp	:= ""

BeginSql Alias "QryNJ0"
	Select
		NJ0.NJ0_FILIAL,
		NJ0.NJ0_NOME,  
		NJ0.NJ0_CODENT,  
		NJ0.NJ0_LOJENT,
		NJ0.NJ0_NOMLOJ,
		NJ0.NJ0_CODFOR,
		NJ0.NJ0_LOJFOR,
		NJ0.NJ0_CODCLI,
		NJ0.NJ0_LOJCLI
	From %Table:NJ0% NJ0
	Where NJ0.%NotDel%
	  And NJ0.NJ0_FILIAL = %xFilial:NJ0% 
	Order By
		NJ0.NJ0_FILIAL,
		NJ0.NJ0_NOME,  
		NJ0.NJ0_CODENT,  
		NJ0.NJ0_LOJENT
EndSQL

Count To nRecCount			//Contando o registros da query

oReport:SetMeter( nRecCount )

oS1:Init()

QryNJ0->( dbGoTop() )
While .Not. QryNJ0->( Eof( ) )	
	
	IF oReport:Cancel()
		Exit
	EndIF
	
	oReport:IncMeter()
	
	/************************************************************************************/
	/************************************************************************************/
	/*                                    Documento de entrada                          */
	/************************************************************************************/
	/************************************************************************************/	
	cFiltroImp := " AND ((SD1.D1_FORNECE = '" + QryNJ0->( NJ0_CODFOR ) + "' "
	cFiltroImp += " AND SD1.D1_LOJA = '" + QryNJ0->( NJ0_LOJFOR) + "' )"
	If QryNJ0->( NJ0_CODFOR + NJ0_LOJFOR) != QryNJ0->(NJ0_CODCLI + NJ0_LOJCLI)
		cFiltroImp += " OR (SD1.D1_FORNECE = '" + QryNJ0->( NJ0_CODCLI ) + "' "
		cFiltroImp += " AND SD1.D1_LOJA = '" + QryNJ0->( NJ0_LOJCLI) + "' )"
	EndIF
	cFiltroImp += ")"	
	cFiltroImp := "%" + cFiltroImp + "%"
	
	BeginSql Alias "QrySD1"
		column D1_EMISSAO As Date
		select 
			SD1.D1_FILIAL,
			SD1.D1_DOC,
			SD1.D1_SERIE,
			SD1.D1_EMISSAO,
			SD1.D1_CF,
			SD1.D1_COD,
			SD1.D1_QUANT,
			SD1.D1_TES,
			SD1.D1_TOTAL
		 from %Table:SD1% SD1
		where SD1.%NotDel%
		  and SD1.D1_FILIAL = %xFilial:SD1% 
		  and SD1.D1_CODROM = ' '
		  and SD1.D1_TES in ( select distinct NJM_TES from %Table:NJM% NJM where NJM.%NotDel% and NJM_FILIAL = %xFilial:NJM% and NJM_TIPO in ('3','5','7','9') ) 
		  and exists (select * from %table:NJR% NJR where NJR.%NotDel% and NJR.NJR_FILIAL = %xFilial:NJR% and NJR.NJR_CODPRO = SD1.D1_COD)
			%exp:cFiltroImp%
	EndSQL
	
	QrySD1->( dbGoTop() )
	While .Not. QrySD1->(Eof())
		
		oS1:Cell("TIPO"):SetValue( "Ent" )		
		oS1:Cell("NJ0_CODENT"):SetValue( QryNJ0->( NJ0_CODENT ) )		
		oS1:Cell("NJ0_LOJENT"):SetValue( QryNJ0->( NJ0_LOJENT ) )				
		oS1:Cell("NJ0_NOME"):SetValue( QryNJ0->( NJ0_NOME ) ) 		
		oS1:Cell("NJ0_NOMLOJ"):SetValue( QryNJ0->(NJ0_NOMLOJ ) )
		oS1:Cell("D1_TES"):SetValue( QrySD1->( D1_TES ) )				
		oS1:Cell("D1_CF"):SetValue( QrySD1->( D1_CF ) )				
		oS1:Cell("D1_DOC"):SetValue( QrySD1->( D1_DOC ) )				
		oS1:Cell("D1_SERIE"):SetValue( QrySD1->( D1_SERIE ) ) 		
		oS1:Cell("D1_EMISSAO"):SetValue( QrySD1->(D1_EMISSAO ) )
		oS1:Cell("D1_COD"):SetValue( QrySD1->( D1_COD ) )
		oS1:Cell("B1_DESC"):SetValue( Posicione( "SB1", 1, xFilial("SB1") + QrySD1->( D1_COD ), "B1_DESC" ) )
		oS1:Cell("D1_QUANT"):SetValue( QrySD1->( D1_QUANT ) )
		oS1:Cell("D1_TOTAL"):SetValue( QrySD1->( D1_TOTAL ) )
	
		oS1:PrintLine()		
	
		QrySD1->( dbSkip() )
	EndDo
	QrySD1->( dbCloseArea() )			
	
	/************************************************************************************/
	/************************************************************************************/
	/*                                    Documento de Saída                            */
	/************************************************************************************/
	/************************************************************************************/	
	cFiltroImp := " AND ((SD2.D2_CLIENTE = '" + QryNJ0->( NJ0_CODCLI ) + "' "
	cFiltroImp += " AND SD2.D2_LOJA = '" + QryNJ0->( NJ0_LOJCLI) + "' )"
	If QryNJ0->( NJ0_CODFOR + NJ0_LOJFOR) != QryNJ0->(NJ0_CODCLI + NJ0_LOJCLI)
		cFiltroImp += " OR (SD2.D2_CLIENTE = '" + QryNJ0->( NJ0_CODFOR ) + "' "
		cFiltroImp += " AND SD2.D2_LOJA = '" + QryNJ0->( NJ0_LOJFOR) + "' )"
	EndIF
	cFiltroImp += ")"	
	cFiltroImp := "%" + cFiltroImp + "%"

	BeginSql Alias "QrySD2"
		column D2_EMISSAO As Date
		select 
			SD2.D2_FILIAL,
			SD2.D2_DOC,
			SD2.D2_SERIE,
			SD2.D2_EMISSAO,
			SD2.D2_CF,
			SD2.D2_COD,
			SD2.D2_QUANT,
			SD2.D2_TES,
			SD2.D2_TOTAL,
			N8K.N8K_CODROM
		 from %Table:SD2% SD2
		 INNER JOIN %Table:N8K% N8K 
		 		ON  N8K.N8K_FILIAL 	= SD2.D2_FILIAL
		 		AND N8K.N8K_DOC 	= SD2.D2_DOC
		 		AND N8K.N8K_SERIE 	= SD2.D2_SERIE
		 		AND N8K.N8K_CLIFOR 	= SD2.D2_CLIENTE
		 		AND N8K.N8K_LOJA 	= SD2.D2_LOJA
		 		AND N8K.N8K_ITEDOC 	= SD2.D2_ITEM
		 		AND N8K.N8K_PRODUT 	= SD2.D2_COD
		 		AND N8K.%NotDel%
		 
		where SD2.%NotDel%
		  and SD2.D2_FILIAL = %xFilial:SD2% 
		  and N8K.N8K_CODROM = ' '
		  and SD2.D2_TES in (select distinct NJM_TES from %Table:NJM% NJM where NJM.%NotDel% and NJM_FILIAL = %xFilial:NJM% and NJM_TIPO in ('2','4','6','8')) 
		  and exists (select * from %table:NJR% NJR where NJR.%NotDel% and NJR.NJR_FILIAL = %xFilial:NJR% and NJR.NJR_CODPRO = SD2.D2_COD)
		  %exp:cFiltroImp%
	EndSQL			
	
	QrySD2->( dbGoTop() )
	While .Not. QrySD2->(Eof())
		
		oS1:Cell("TIPO"):SetValue( "Sai" )		
		oS1:Cell("NJ0_CODENT"):SetValue( QryNJ0->( NJ0_CODENT ) )		
		oS1:Cell("NJ0_LOJENT"):SetValue( QryNJ0->( NJ0_LOJENT ) )				
		oS1:Cell("NJ0_NOME"):SetValue( QryNJ0->( NJ0_NOME ) ) 		
		oS1:Cell("NJ0_NOMLOJ"):SetValue( QryNJ0->(NJ0_NOMLOJ ) )
		oS1:Cell("D1_TES"):SetValue( QrySD2->( D2_TES ) )			
		oS1:Cell("D1_CF"):SetValue( QrySD2->( D2_CF ) )
		oS1:Cell("D1_DOC"):SetValue( QrySD2->( D2_DOC ) )				
		oS1:Cell("D1_SERIE"):SetValue( QrySD2->( D2_SERIE ) ) 		
		oS1:Cell("D1_EMISSAO"):SetValue( QrySD2->(D2_EMISSAO ) )
		oS1:Cell("D1_COD"):SetValue( QrySD2->( D2_COD ) )
		oS1:Cell("B1_DESC"):SetValue( Posicione( "SB1", 1, xFilial("SB1") + QrySD2->( D2_COD ), "B1_DESC" ) )
		oS1:Cell("D1_QUANT"):SetValue( QrySD2->( D2_QUANT ) )
		oS1:Cell("D1_TOTAL"):SetValue( QrySD2->( D2_TOTAL ) )
	
		oS1:PrintLine()		
	
		QrySD2->( dbSkip() )
	EndDo
	QrySD2->( dbCloseArea() )
		
	QryNJ0->( dbSkip() )	
EndDo
oS1:Finish()	

QryNJ0->( dbCloseArea() )
	
RestArea(aAreaAtu)
	
Return( )

