#Include "TECR800A.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'REPORT.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} TECR800
Relatório TReport para impressão de apurações 

@sample 	TECR800A() 
@author     Matheus Lando Raimundo
@since		24/04/2018       
@version	P12   
/*/
//------------------------------------------------------------------------------
Function TECR800A()

Local oReport 	:= Nil
Local oSection1 := Nil
Local oSection2	:= Nil
Local oTotal	:= Nil
Local oBreakCTR	:= Nil
Local oBreakTIP := Nil
Local oBreakTFV	:= Nil 


Pergunte('TECR800A',.F.)

DEFINE REPORT oReport NAME 'TECR800A' TITLE STR0001 PARAMETER 'TECR800A' ACTION {|oReport| PrintReport(oReport)}
	
	oReport:HideParamPage()  // inibe a impressão da página de parâmetros
	oReport:SetLandscape() //Escolher o padrão de Impressao como Paisagem 	
	
	oSection1 := TRSection():New(oReport	,STR0001,   {"TFV"},,,,,,,.T.)	 //"Apurações"
	oSection2 := TRSection():New(oSection1	,STR0002 ,{"TIP"},,,,,,,.T.) //"Bases de atendimento"
		
			
	DEFINE CELL NAME 'TFV_CONTRT' OF oSection1 ALIAS 'TFV'
	DEFINE CELL NAME 'TFV_REVISA' OF oSection1 ALIAS 'TFV' TITLE STR0007
	DEFINE CELL NAME 'TFV_CODIGO' OF oSection1 ALIAS 'TFV'			
	DEFINE CELL NAME 'TFV_DTINI'  OF oSection1 ALIAS 'TFV' TITLE STR0003 //'Dt início Apuração'
	DEFINE CELL NAME 'TFV_DTFIM'  OF oSection1 ALIAS 'TFV' TITLE STR0004 //'Dt fim Apuração'
	DEFINE CELL NAME 'B1_COD'  	  OF oSection1 ALIAS 'SB1' TITLE STR0005 //'Produto'
	DEFINE CELL NAME 'B1_DESC' 	  OF oSection1 ALIAS 'SB1'
	DEFINE CELL NAME 'TFZ_MODCOB' OF oSection1 ALIAS 'TFZ'
	DEFINE CELL NAME 'TFZ_TOTAL'  OF oSection1 ALIAS 'TFZ'				
	DEFINE CELL NAME 'TIP_CODEQU' OF oSection2 ALIAS 'TIP' TITLE STR0006 //'Equipamento(s)'	

	
	oBreakTFV := TRBreak():New( oSection1,{|| QRY_TFV->RECTFZ } )
	oBreakTIP := TRBreak():New( oSection2,{|| QRY_TFV->RECTFZ  } )
			

	TRFunction():New(oSection1:Cell("TFZ_TOTAL"),/* cID */,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,/*lEndPage*/)	
		
oReport:PrintDialog()

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Função que faz o controle de impressão do relatório 
Relatório TReport para impressão de apurações 

@sample 	TECR800A() 
@author     Matheus Lando Raimundo
@since		24/04/2018       
@version	P12   
/*/
//------------------------------------------------------------------------------
Static Function PrintReport(oReport)
Local oSection1  	:= oReport:Section(1)
Local oSection2 	:= oReport:Section(1):Section(1)
Local cTamCodEq		:= Space(TamSX3('TIP_CODEQU')[1])		
Local cExpFil		:= ""
Local cContr 		:= ""	
  
//-- Cliente de 
If !Empty(MV_PAR01)
	cExpFil += " AND ABS.ABS_ENTIDA = '1' AND ABS.ABS_CODIGO >= '" + MV_PAR01 + "'"
EndIf
	 
If !Empty(MV_PAR02)
	cExpFil += " AND ABS.ABS_ENTIDA = '1' AND ABS.ABS_LOJA >= '" + MV_PAR02  + "'"
EndIf

//-- Cliente até
If !Empty(MV_PAR03)
	cExpFil += " AND ABS.ABS_ENTIDA = '1' AND ABS.ABS_CODIGO <= '" + MV_PAR03 + "'"
EndIf
	 
If !Empty(MV_PAR04)
	cExpFil += " AND ABS.ABS_ENTIDA = '1' AND ABS.ABS_LOJA <= '" + MV_PAR04  + "'"
EndIf

//-- Contrato de 
If !Empty(MV_PAR05)  
	cExpFil +=  " AND TFV.TFV_CONTRT >= '" + MV_PAR05 + "'"
EndIf	 

//-- Contrato até
If !Empty(MV_PAR06)
	cExpFil += " AND TFV.TFV_CONTRT <= '" + MV_PAR06 + "'"
EndIf

//-- Data de 
If !Empty(MV_PAR07)
	cExpFil += " AND TFV.TFV_DTINI >= '" + DTOS(MV_PAR07) + "'"
EndIf	 

//-- Data até 
If !Empty(MV_PAR08)
	cExpFil +=  " AND TFV.TFV_DTFIM <= '" + DTOS(MV_PAR08) + "'"
EndIf

//-- Produto de
If !Empty(MV_PAR09)  
	cExpFil +=  " AND TFI_PRODUT >= '" + MV_PAR09 + "'"
EndIf	 

//-- Produto até
If !Empty(MV_PAR10)
	cExpFil +=  " AND TFI_PRODUT <= '" + MV_PAR10 + "'"
EndIf

If Empty(cExpFil)
	cExpFil	:= "% AND 0 = 0%"
Else
	cExpFil := '% '  + cExpFil + '%' 			
EndIf	

oSection1:BeginQuery()

BeginSql alias "QRY_TFV"
	SELECT TFZ.R_E_C_N_O_  RECTFZ , TFV.TFV_CONTRT, TFV.TFV_REVISA, TFV.TFV_CODIGO, TFV.TFV_DTINI, TFV.TFV_DTFIM, B1_COD, B1_DESC, TFZ_MODCOB, TFZ_TOTAL FROM %table:TFZ% TFZ
		INNER JOIN %table:TFV%  TFV ON TFV_FILIAL = %xfilial:TFV% AND  TFZ.TFZ_APURAC = TFV.TFV_CODIGO AND TFV.%notDel%
		INNER JOIN %table:TFI%  TFI ON TFI_FILIAL = %xfilial:TFI% AND  TFZ.TFZ_CODTFI = TFI.TFI_COD AND TFI.%notDel%
		INNER JOIN %table:TFL%  TFL ON TFL_FILIAL = %xfilial:TFL% AND  TFI.TFI_CODPAI = TFL.TFL_CODIGO AND TFL.%notDel%		
		INNER JOIN %table:ABS%  ABS ON ABS_FILIAL = %xfilial:ABS% AND  TFL.TFL_LOCAL = ABS.ABS_LOCAL AND ABS.%notDel%
		INNER JOIN %table:SB1%  SB1 ON B1_FILIAL = 	%xfilial:SB1% AND  TFI.TFI_PRODUT = B1_COD AND SB1.%notDel%
	WHERE TFV_FILIAL = 	%xfilial:TFV%
	AND TFZ_TOTAL > 0
	%Exp:cExpFil%
	AND TFV.%notDel%
	ORDER BY TFV.TFV_CONTRT, TFV.TFV_REVISA	, TFV.TFV_DTINI, TFV.TFV_DTFIM
EndSql

END REPORT QUERY oSection1

QRY_TFV->(DbGoTop())

oSection1:EndQuery()
oSection1:SetParentQuery(.F.)
oSection1:Init()

cContr := QRY_TFV->(TFV_CONTRT)
While QRY_TFV->(!Eof()) 				
			
	oSection1:PrintLine()
	
	If MV_PAR11 == 1
		oSection2:SetParentQuery(.F.)				
	 	oSection2:Init()
	 	
	 	oSection2:BeginQuery()
		BeginSql alias "QRY_TIP"
			SELECT TIP_CODEQU FROM %table:TIP% TIP
				INNER JOIN %table:AA3% AA3 ON AA3_FILIAL = %xfilial:AA3% AND AA3_CODPRO = %Exp:QRY_TFV->B1_COD% AND AA3_NUMSER = TIP_CODEQU AND AA3.%notDel% 	
				WHERE TIP_FILIAL = 	%xfilial:TIP%
				AND TIP_ITAPUR 	 = %Exp:QRY_TFV->TFV_CODIGO%		
				AND (TIP_CODEQU <> '' OR TIP_CODEQU <> %Exp:cTamCodEq%)
				AND TIP.%notDel%   						
		EndSql
		oSection2:EndQuery()
		
		While QRY_TIP->(!Eof())
			oSection2:PrintLine()
			QRY_TIP->(dbSkip())		
		EndDo		
	EndIf
	QRY_TFV->(dbSkip())
EndDo	

Return