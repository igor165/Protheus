#include "protheus.ch"
#include "report.ch"
#include "OGR740.ch"

/*/{Protheus.doc} OGR740
Impressão de minutas
@author silvana.torres
@since 26/09/2018
@version undefined

@type function
/*/
Function OGR740()
 	Local aAreaAtu 	:= GetArea() 
	Local oReport	:= Nil
	
	Private cPergunta	:= "OGR7400001"
	Private _nDesc		:= 0
	    
	If FindFunction("TRepInUse") .And. TRepInUse()
		Pergunte( cPergunta, .f. )
		oReport:= ReportDef()
		oReport:PrintDialog()		
	EndIf
	
	RestArea( aAreaAtu )
Return( Nil )

/*/{Protheus.doc} ReportDef
@author silvana.torres
@since 26/09/2018
@version undefined

@type function
/*/
Static Function ReportDef()
	Local oReport		:= Nil
	Local oSection1		:= Nil
		
	oReport := TReport():New("OGR740", STR0001 /*"Minutas"*/, cPergunta, {| oReport | PrintReport( oReport ) }, STR0001 /*"Minutas"*/)
		
	oReport:oPage:SetPageNumber(1)
	oReport:lBold 		   := .F.
	oReport:lUnderLine     := .F.
	oReport:lHeaderVisible := .T.
	oReport:lFooterVisible := .T.
	oReport:lParamPage     := .F.
	
	//Seção 1 - Relatório
	oSection1 := TRSection():New( oReport, STR0001 /*"Minutas"*/, {"NJR"} )
	oSection1:lAutoSize := .T.
	oSection1:lAutoSize := .T. 
	
	TRCell():New( oSection1, "NJR_CODSAF", "NJR", STR0002 /*"Safra"*/)
	TRCell():New( oSection1, "NJR_CODCTR", "NJR", STR0003 /*"Contrato"*/)
	TRCell():New( oSection1, "NJR_CTREXT", "NJR", STR0004 /*"Contrato Externo"*/)
	TRCell():New( oSection1, STR0005 /*"Entidade"*/, , STR0005 /*"Entidade"*/, , TamSX3('NJR_CODENT')[1] + TamSX3('NJR_LOJENT')[1] + TamSX3('NJ0_NOME')[1] , , {|| getEnt(QryNJR->NJR_CODENT, QryNJR->NJR_LOJENT) }) 
	TRCell():New( oSection1, "NJR_STSMIN", "NJR", STR0006 /*"Status"*/)
	TRCell():New( oSection1, "NJR_PROMIN", "NJR", STR0007 /*"Processo"*/)	
				
Return (oReport)

/*/{Protheus.doc} PrintReport
@author silvana.torres
@since 26/09/2018
@version undefined
@param oReport, object, descricao
@type function
/*/
Static Function PrintReport(oReport)
	Local aAreaAtu	:= GetArea()
	Local oS1		:= oReport:Section(1)
	Local cFiltro 	:= ""

	If oReport:Cancel()
		Return( Nil )
	EndIf

	If .NOT. Empty(MV_PAR01)
		cFiltro += " AND NJR.NJR_CODSAF = '" + MV_PAR01 + "'"
	EndIf	

	If .NOT. Empty(MV_PAR02)
		cFiltro += " AND NJR.NJR_CODCTR >= '" + MV_PAR02 + "'"
	EndIf
	
	If .NOT. Empty(MV_PAR03)
		cFiltro += " AND NJR.NJR_CODCTR <= '" + MV_PAR03 + "'"
	EndIf	
	
	If .NOT. Empty(MV_PAR04)
		cFiltro += " AND NJR.NJR_CODENT >= '" + MV_PAR04 + "'"
	EndIf		
	
	If .NOT. Empty(MV_PAR05)
		cFiltro += " AND NJR.NJR_LOJENT >= '" + MV_PAR05 + "'"
	EndIf		
	
	If .NOT. Empty(MV_PAR06)
		cFiltro += " AND NJR.NJR_CODENT <= '" + MV_PAR06 + "'"
	EndIf
	
	If .NOT. Empty(MV_PAR07)
		cFiltro += " AND NJR.NJR_LOJENT <= '" + MV_PAR07 + "'"
	EndIf

	If .NOT. Empty(MV_PAR08)
		cFiltro += " AND NJR.NJR_STSMIN = '" + MV_PAR08 + "'"
	EndIf
		
	cFiltro := "%" + cFiltro + "%"

	oS1:BeginQuery()
	oS1:Init()
	
	BeginSql Alias "QryNJR"
	  SELECT NJR_CODSAF, NJR_CODCTR, NJR_CTREXT, NJR_CODENT, NJR_LOJENT, NJR_STSMIN, NJR_PROMIN
	    FROM %Table:NJR% NJR 
	   WHERE NJR.%NotDel% 
	     %Exp:cFiltro% 
	EndSql
	oS1:EndQuery()
	
	If .Not. QryNJR->(Eof())
	
		QryNJR->(dbGoTop())
		
		oS1:Init()
	
		While .Not. QryNJR->(Eof())
							
			oS1:PrintLine()
	
			QryNJR->( dbSkip() )
		EndDo
		QryNJR->( dbCloseArea() )
	
		//fecha cabeçalho
		oS1:Finish()	
	EndIf

	RestArea(aAreaAtu)		
Return .t.

/*/{Protheus.doc} getEnt
Formata a informação de entidade junto com loja
@author silvana.torres
@since 26/09/2018
@version undefined
@param cEntidade, characters, descricao
@param cLoja, characters, descricao
@type function
/*/
Static Function getEnt(cEnt, cLoja)
	Local cRet 	:= ""
	Local cDesc	:= ""
	
	If !Empty(cEnt)
		NJ0->(DbSelectArea("NJ0"))
		NJ0->(dbSetOrder(1)) //Filial + Código + Loja	
	
		if NJ0->(MsSeek(FwXFilial('NJ0')+cEnt+cLoja)) 
			cDesc := NJ0->NJ0_NOME			
		endIf
		NJ0->(dbCloseArea())
	
		cRet := cEnt + "/" + cLoja + " - " + cDesc
	Endif
	
Return cRet