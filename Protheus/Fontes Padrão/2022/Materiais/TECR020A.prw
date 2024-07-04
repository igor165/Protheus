#INCLUDE "REPORT.CH"
#Include "Protheus.ch"      
#Include "TOPCONN.ch"
#Include "TECR020A.ch"

Static cAutoPerg := "TECR020A"

//-------------------------------------------------------------------
/*/{Protheus.doc} TECR020A
Monta as definiçoes do relatorio de Atendentes sem Agenda.

@author fabiana.silva
@since 24/09/2019
@version P12.1.25
/*/
//-------------------------------------------------------------------
Function TECR020A()
Local oReport := Nil
Local cPerg	:= "TECR020A" 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PARAMETROS                                                             ³
//³ MV_PAR01 : Data de ?                                                   ³
//³ MV_PAR02 : Data ate?                                                   ³
//³ MV_PAR03 : Atendente de ?                                              ³
//³ MV_PAR04 : Atendente ate ?                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 

//Exibe dialog de perguntes ao usuario
If Pergunte(cPerg,.T.)
	//Pinta o relatorio a partir das perguntas escolhidas
	oReport := ReportDef(cPerg)   
	oReport:PrintDialog()
EndIf

  
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} reportDef
Monta as definiçoes do relatorio de Atendentes sem Agenda

@author fabiana.silva
@since 24/09/2019
@version P12.1.25
@param cPerg - Pergunte do relatório
@return  Nil
/*/
//-------------------------------------------------------------------------------------
Static Function ReportDef(cPerg)

Local cTitulo 	:= STR0001 //"Atendentes sem agenda"
Local oReport := NIL
Local oSection0 := nil
Local cAlias := GetNextAlias()
Local oBreak := NIL
Local nTam := 0
Local nX := 0


	oReport 	:= TReport():New(cPerg, cTitulo, cPerg , {|oReport| PrintReport(oReport, cAlias)}, STR0001 ) //"Atendentes sem agenda"
	oSection0 := TRSection():New(oReport, STR0001 ,{cAlias, "AA1","SRA"}) //"Atendentes sem agenda"

	For nX := 1 to 7 
		nTam := Max(Len(TECCdow(Dow(sTod('20190511')+nX))), nTam)
	Next Nx

	oBreak0 = TRBreak():New( oSection0 , {|| (cAlias)->AA1_CODTEC },""  , .F. ,  , .T. )  
 		
 		DEFINE CELL NAME "AA1_CODTEC"	OF oSection0 ALIAS "AA1"
		DEFINE CELL NAME "AA1_NOMTEC"	OF oSection0 ALIAS "AA1"
		DEFINE CELL NAME "AA1_CDFUNC"	OF oSection0 ALIAS "AA1"
 		DEFINE CELL NAME "RA_ADMISSA"	OF oSection0 ALIAS "AA1"
 		DEFINE CELL NAME "RA_DEMISSA"	OF oSection0 ALIAS "AA1"
		DEFINE CELL NAME "DATA"		OF oSection0 ALIAS cAlias TITLE STR0002 SIZE 10  Block {|| Ctod("" )} //"Data Sem Agenda"
		DEFINE CELL NAME "DIASEM"		OF oSection0 ALIAS cAlias  TITLE STR0003  SIZE nTam Block {|| "" } //"Dia da Semana"
		TRPosition():New(oSection0,"AA1", 1,{|| xFilial("AA1")+(cAlias)->AA1_CODTEC})  
		TRPosition():New(oSection0,"SRA", 1,{|| AA1->AA1_FUNFIL+AA1->AA1_CDFUNC})  
			
Return (oReport) 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Gera o relatorio de Atendentes sem Agenda

@author fabiana.silva
@since 24/09/2019
@version P12.1.25
@param oReport - Objeto report
@param cAlias - Objeto Alias
@return  Nil

/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport(oReport, cAlias)
Local oSection0		:= oReport:Section(1)
Local cAlias2 		:=  GetNextAlias()
Local cCodTec 		:= ""
Local dDtIni 		:= Ctod("")
Local dDtFim 		:= Ctod("")
Local aDiaOc 		:= {}
Local dDataUlt 		:= Ctod("")
Local nC 			:= 0
Local cWhrAA1Blq 	:= ""
Local cWhrSRABlq 	:= ""
Local cCol 			:= ""

If AA1->(ColumnPos('AA1_MSBLQL')) > 0
	cWhrAA1Blq := " AND AA1.AA1_MSBLQL <> '1'"
EndIf


If SRa->(ColumnPos('RA_MSBLQL')) > 0
	cWhrSRABlq := " AND (X.RA_MSBLQL IS NULL OR X.RA_MSBLQL <> '1') "
	cCol := ",SRA.RA_MSBLQL"
EndIf	


cWhrAA1Blq := "%" +cWhrAA1Blq+"%"


cWhrSRABlq := "%"+cWhrSRABlq+"%"

cCol := "%"+cCol+"%"

BEGIN REPORT QUERY oSection0

     BeginSql alias cAlias
		COLUMN RA_DEMISSA AS DATE
		COLUMN RA_ADMISSA AS DATE

		Select 
	
		X.* FROM
		(
			SELECT AA1.AA1_CODTEC, 
			AA1.AA1_CDFUNC, 
			AA1.AA1_NOMTEC, 
			AA1.AA1_FUNFIL, 
			SRA.RA_ADMISSA, 
			SRA.RA_DEMISSA, 
			SRA.RA_TPCONTR
			%Exp:cCol%
			FROM 
			%table:AA1% AA1
			LEFT JOIN %table:SRA% SRA ON (SRA.RA_MAT = AA1.AA1_CDFUNC  AND SRA.RA_FILIAL =  AA1.AA1_FUNFIL AND SRA.%notDel%)
		
			WHERE  AA1.AA1_CODTEC  BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04% AND 
			AA1.AA1_ALOCA <> '2' AND
			AA1.%notDel% AND 
			AA1.AA1_FILIAL =  %xfilial:AA1% 
			%Exp:cWhrAA1Blq%
			 )X
		WHERE
		 ( X.RA_ADMISSA IS NULL OR  X.RA_ADMISSA <= %Exp:MV_PAR02%) AND 
		 ( X.RA_DEMISSA IS NULL OR  X.RA_DEMISSA =  %Exp:dDataUlt%  OR  X.RA_DEMISSA >=  %Exp:MV_PAR01%) AND
		 (X.RA_TPCONTR IS NULL OR X.RA_TPCONTR <> '3')
		 %Exp:cWhrSRABlq%
		ORDER BY X.AA1_CODTEC
		
	EndSql

END REPORT QUERY oSection0


oSection0:Init()
While (cAlias)->(!Eof())

	If Select(cAlias2) > 0
		(cAlias2)->(DbCloseArea())
	EndIf
	cCodTec := (cAlias)->AA1_CODTEC
	dDtIni := MV_PAR01
	If  !Empty((cAlias)->RA_ADMISSA)
		dDtIni := Max((cAlias)->RA_ADMISSA, dDtIni)
	EndIf
	
	dDtFim := MV_PAR02
	If  !Empty((cAlias)->RA_DEMISSA)
		dDtFim := Min((cAlias)->RA_DEMISSA,dDtFim)
	EndIf
	aDiaOc := {}

	BeginSql Alias cAlias2
		Column ABB_DTINI As Date
		Column ABB_DTFIM As Date
		Select Distinct ABB.ABB_DTINI, ABB.ABB_DTFIM From
		%table:ABB% ABB
		Where ABB.ABB_CODTEC  = %exp:cCodTec%
			AND ABB.ABB_FILIAL = %xfilial:ABB%
			AND (ABB.ABB_DTINI BETWEEN %exp:dDtIni% AND %exp:dDtFim% OR
			ABB.ABB_DTFIM BETWEEN %exp:dDtIni% AND %exp:dDtFim%)
			AND ABB.%notDel%
			ORDER BY ABB.ABB_DTINI, ABB.ABB_DTFIM

   EndSql
   
    dDataUlt := dDtIni
    If (cAlias2)->(!Eof())
	    Do While (cAlias2)->(!Eof())

	    	If (cAlias2)->ABB_DTINI >  dDataUlt
			    	Do While dDataUlt < (cAlias2)->ABB_DTINI
		    				aAdd( aDiaOc , {  dDataUlt, TECCdow(Dow(dDataUlt))} )	    	
		    				dDataUlt++
		    		EndDo	
    		
	    	EndIf
		    If (cAlias2)->ABB_DTINI < (cAlias2)->ABB_DTFIM	
		    	dDataUlt := (cAlias2)->ABB_DTFIM	
		    EndIf
		    dDataUlt++
	    	(cAlias2)->(DbSkip(1))
	    EndDo
	EndIf
    
	Do While dDataUlt <= dDtFim
		aAdd( aDiaOc , {  dDataUlt, TECCdow(Dow(dDataUlt))} )	    	
		dDataUlt++
	EndDo

 (cAlias2)->(DbCloseArea()) 
 If Len(aDiaOc) > 0
 	
 	aSort(aDiaOc,,, {|a,b| a[1] < b[1] })

 	For nC := 1 to Len(aDiaOc)
 		oSection0:Cell("DATA"):SetValue(aDiaOc[nC, 01])
 		
 		oSection0:Cell("DIASEM"):SetValue(aDiaOc[nC, 02])
 		oSection0:Printline()
 	Next nC 
 EndIf

(cAlias)->(DbSkip(1))	

Enddo

oSection0:Finish()
(cAlias)->(DbCloseArea())
Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPergTRp
Retorna o nome do Pergunte utilizado no relatório
Função utilizada na automação
@author Junior Geraldo
@since 29/05/2020
@return cAutoPerg, string, nome do pergunte
/*/
//-------------------------------------------------------------------------------------
Static Function GetPergTRp()

Return cAutoPerg