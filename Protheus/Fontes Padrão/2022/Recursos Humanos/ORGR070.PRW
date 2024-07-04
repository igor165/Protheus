#INCLUDE "ORGR070.CH"
#INCLUDE "PROTHEUS.CH"      
#INCLUDE "REPORT.CH"
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma     ณ ORGR070  ณ Autor ณ Rogerio R.            ณ Data ณ04/12/2008ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio    ณ Impressao da visao                                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso          ณ SIGAORG - Arquitetura Organizacional                       ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramador  ณ Data   ณ FNC          ณ  Motivo da Alteracao               ณฑฑ  
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ 
ฑฑณCecilia Carv.ณ07/08/14ณTQEQKP        ณIncluido o fonte da 11 para a 12    ณฑฑ
ฑฑณ             ณ        ณ              ณe efetuada a limpeza.               ณฑฑ
ฑฑณMarcos Cout. ณ11/07/17ณDRHPONTP-1235 ณRealizando o ajuste para exibir a   ณฑฑ
ฑฑณ             ณ        ณ              ณFIL. Fonte compativel entre versoes ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ 
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function ORGR070()
	Local oReport   
	Local aArea 		:= GetArea()
	Private cAliasQry	:= GetNextAlias()
	
	Pergunte("ORG70R",.F.)      
	oReport := ReportDef()
	oReport:PrintDialog()
	RestArea( aArea )
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณORGR070   บAutor  ณRogerio Ribeiro     บ Data ณ  12/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบFuncao    ณORG70Imp													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ReportDef()
	Local oReport 
	Local oSection1 
	Local oCell01, oCell02
	Private aOrd    := {OemToAnsi(STR0002)}							//"Itens da Visao"
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณCriacao dos componentes de impressao                                    ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	DEFINE REPORT oReport;
		NAME "ORGR070";
		TITLE OemToAnsi(STR0001);				//"Impressใo da Visใo"
		PARAMETER "ORG70R";
		ACTION {|oReport| ORG70Imp(oReport)};
		DESCRIPTION OemToAnsi(STR0003)			//"Este relatorio imprime a visใo selecionada."
	
	DEFINE SECTION oSection1;
		OF oReport;
		TITLE OemToAnsi(STR0004);				//"Estrutura da Visใo"
		TABLES "RD4";
		ORDERS aOrd
	
	DEFINE CELL oCell01;
		NAME "ITEM";
		OF oSection1;
		TITLE OemToAnsi(STR0004); 				//"Itens da Visใo"
		AUTO SIZE

	DEFINE CELL oCell02;
		NAME "QUANT";
		OF oSection1;
		TITLE OemToAnsi(STR0005); 					//"Ocup./Total"
		SIZE 12;
		ALIGN RIGHT

			
	//oReport:SetLandscape(.T.)						
	oReport:SetColSpace(4)				
Return oReport


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณORGR070   บAutor  ณRogerio Ribeiro     บ Data ณ  12/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบFuncao    ณORG70Imp													  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function ORG70Imp(oReport)
	Local cIdent:= ""
	Local lContagem:= .T.
	Local cCodigo
	Local cDBMS := ""
	Local cLength := ""
	Local nCount
	Local aItems:= {}     
	Local nItemLen
	Local cChave:= Space(GetSx3Cache("RD4_CHAVE", "X3_TAMANHO"))
	Local cChaveTemp
	Local oSection1 := oReport:Section(1)
	Local nPos := 0
	Local aSm0 := {}
	                  
	Pergunte("ORG70R", .F.)
	cCodigo:= MV_PAR01
	nNiveis:= MV_PAR02 * 3
	lContagem:= (MV_PAR03 == 1)
	
	aSm0 := FWLoadSM0()

	IF !lContagem
		oSection1:Cell("QUANT"):Disable()
	EndIf	
	
	DBSelectArea("RDK")
	DBSetORder(1)
	DBSeek(xFilial("RDK") + cCodigo)

	cDBMS   := Upper(TcGetDb())
	cLength := If( "MSSQL" $ cDBMS , "%Len(RD4.RD4_CHAVE)%" , "%Length(trim(RD4.RD4_CHAVE))%")
	
	BEGINSQL ALIAS cAliasQry
		SELECT
			COUNT(*) AS NROREG
		FROM
			%table:RD4% RD4
		WHERE   
			RD4.RD4_CODIGO = %exp:cCodigo% AND
			RD4.RD4_CHAVE != %exp:cChave% AND
			(%exp:cLength% <= %exp:nNiveis% OR %exp:nNiveis% = 0) AND
			RD4.%notDel%      
	ENDSQL

	nItemLen:= (cAliasQry)->NROREG
	(cAliasQry)->(DBCloseArea())	
	
	BEGINSQL ALIAS cAliasQry
		SELECT
			RD4.RD4_CHAVE,
			RD4_EMPIDE, 
			RD4_FILIDE,		
			RD4.RD4_CODIDE,
			RD4.RD4_DESC
		FROM
			%table:RD4% RD4
		WHERE   
			RD4.RD4_CODIGO = %exp:cCodigo% AND
			RD4.RD4_CHAVE != %exp:cChave% AND				
			(%exp:cLength% <= %exp:nNiveis% OR %exp:nNiveis% = 0) AND			
			RD4.%notDel%
		ORDER BY
			RD4_CHAVE
	ENDSQL
	    
	oReport:SetMeter((nItemLen*2)+1)

	DBEval(;
		{|| aAdd(aItems, { AllTrim(RD4_CHAVE), RD4_EMPIDE, RD4_FILIDE, RD4_CODIDE, RD4_DESC }),;
			oReport:IncMeter();
		};
	)

	oSection1:Init()	
	
	oReport:IncMeter()
	oSection1:Cell("ITEM"):SetValue(" # " + RDK->RDK_DESC) 
	oSection1:PrintLine() 
	
	For nCount:= 1 To nItemLen
		cChave:= aItems[nCount, 1]
		
		oReport:IncMeter()
		If oReport:Cancel()
			Exit
		EndIf

		If Len(cChave) > Len(cIdent)
			If nCount != 1
				cChaveTemp:= aItems[nCount-1, 1]
				
				If SubStr(cChave, 1, Len(cChaveTemp)) == cChaveTemp
					If AScan(aItems, {|aTemp|	Len(aTemp[1]) == Len(cChaveTemp) .AND. ;
												SubStr(aTemp[1], 1, Len(cChaveTemp)-3) == SubStr(cChaveTemp, 1, Len(cChaveTemp)-3)}, nCount) == 0
						cIdent:= SubStr(cIdent, 1, Len(cIdent)-3) + Space(3)
					Endif		                  					
				Endif		                  
			EndIf
			
			cIdent+= " +-"
		Else
			While (Len(cChave) < Len(cIdent))
				cIdent:= SubStr(cIdent, 1, Len(cIdent)-3)
			EndDo
		EndIf
		
		If Substr(cIdent, Len(cIdent)-5, 6) == " +- +-"
			cIdent:= SubStr(cIdent, 1, Len(cIdent)-6) + " |  +-"
		EndIf

		If Substr(cIdent, Len(cIdent)-2, 3) == " | "
			cIdent:= SubStr(cIdent, 1, Len(cIdent)-3) + " +-"
		EndIf

		//Informando a filial e seu nome na descri็ใo do relatorio
		nPos := aScan( aSM0, { |x| AllTrim( x[2] ) == AllTrim( aItems[nCount,3] ) } )

		If nPos > 0
			oSection1:Cell("ITEM"):SetValue( cIdent + "-# " + aItems[nCount, 4] + ' - ' + AllTrim( aItems[nCount, 5] ) + " (" + AllTrim( aItems[nCount, 3] ) + " - " + AllTrim( aSm0[nPos,7] ) + ")"  )
		Else
			oSection1:Cell("ITEM"):SetValue( cIdent + "-# " + aItems[nCount, 4] + ' - ' + AllTrim( aItems[nCount, 5] ) )
		EndIf

		IF lContagem
			oSection1:Cell("QUANT"):SetValue( GetPostInfo(aItems[nCount, 2], aItems[nCount, 3], aItems[nCount, 4], RDK->RDK_HIERAR == "1") )
		EndIf

		oSection1:PrintLine() 
	Next	
	oSection1:Finish()
	
	(cAliasQry)->(DBCloseArea())	
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณORGR070   บAutor  ณRogerio Ribeiro     บ Data ณ  12/08/08   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบFuncao    ณGetPostInfo												  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GetPostInfo(cEmpPar, cFilPar, cCodPar, lDepto)
	Local cEmpTmp:= cEmpAnt
	Local cRCLALias
	Local cSQBALias
	Local cAliasQry	:= GetNextAlias()
	Local cFilRCLSQB	:= "%" + FWJoinFilial("RCL", "SQB") + "%"	
	
	cEmpAnt:= cEmpPar	
	cRCLALias:= "%" + RetSqlName("RCL") + "%" 
	cSQBALias:= "%" + RetSqlName("SQB") + "%" 
	cEmpAnt:= cEmpTmp
	
   

	If lDepto
	 	cFilPar := xFilial("SQB",cFilPar)
		BEGINSQL ALIAS cAliasQry
			SELECT
				SUM(RCL_OPOSTO) AS RCL_OPOSTO,
				SUM(RCL_NPOSTO) AS RCL_NPOSTO
			FROM
				%exp:cRCLALias% RCL
			INNER JOIN %exp:cSQBALias% SQB ON
				RCL.RCL_DEPTO = SQB.QB_DEPTO	
				AND  %exp:cFilRCLSQB%		
			WHERE 
				SQB.QB_FILIAL = %exp:cFilPar% AND
				SQB.QB_DEPTO = %exp:cCodPar% AND
				SQB.%notDel% AND
				RCL.%notDel% 
			GROUP BY
				SQB.QB_DEPTO
		ENDSQL
	Else
		cFilPar := xFilial("RCL",cFilPar)
		BEGINSQL ALIAS cAliasQry
			SELECT
				RCL_OPOSTO,
				RCL_NPOSTO
			FROM
				%exp:cRCLALias% 
			WHERE 
				RCL_FILIAL = %exp:cFilPar% AND
				RCL_POSTO = %exp:cCodPar% AND
				%notDel%			
		ENDSQL
	EndIf


	cRet:= (cAliasQry)->(AllTrim(Str(RCL_OPOSTO)) + "/" + AllTrim(Str(RCL_NPOSTO)))	
	(cAliasQry)->(DBCloseArea())
Return cRet