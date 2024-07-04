#include 'PROTHEUS.CH'
#include 'PARMTYPE.CH'
#include 'GTPR300.CH'

Static nKmAcumul := 0
//-------------------------------------------------------------------
/*/{Protheus.doc} GTPR300
Relatório de Veiculo x Escala.

@author SIGAGTP | jacomo.fernandes
@since 29/08/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------
Function GTPR300()

Local cPerg := "GTPR300"
Private oReport

If Pergunte( cPerg, .T. )
    oReport := ReportDef( cPerg )
    oReport:PrintDialog()
Endif


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Definições do Relatório de Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 21/08/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------

Static Function ReportDef(cPerg)
Local oReport   := Nil
Local oSection1 := Nil
Local oSection2 := Nil
Local oSection3 := Nil
Local oBreak    := nil	
	oReport := TReport():New("GTPR300",STR0001,cPerg,{|oReport| ReportPrint(oReport)},STR0001) //"Veiculo x Escala"
	
    oSection1:= TRSection():New(oReport,STR0010, {"ST9"}, , .F., .T.) //"Dados Veiculo"
	
    TRCell():New(oSection1,"T9_CODBEM"  ,"ST9")
    TRCell():New(oSection1,"T9_MODELO"  ,"ST9")
    TRCell():New(oSection1,"T9_PLACA"   ,"ST9")
    TRCell():New(oSection1,"T9_CHASSI"  ,"ST9")
    TRCell():New(oSection1,"T9_RENAVAM" ,"ST9")
    
    oSection2:= TRSection():New(oSection1,STR0011, {"G52"}, , .F., .T.) //"Escala"
	
    TRCell():New(oSection2,"G52_CODIGO" ,"G52")
    TRCell():New(oSection2,"G52_DESCRI" ,"G52")
    

    oSection3:= TRSection():New(oSection2,STR0012, {"GYN","G55","GQE","GIE"}, , .F., .T.) //
	oSection3:SetAutoSize(.F.)

	TRCell():New(oSection3,"GYN_CODGID" ,"GYN")
    TRCell():New(oSection3,"G55_DTCHEG" ,"G55")
    TRCell():New(oSection3,"G55_LOCORI" ,"G55")
    TRCell():New(oSection3,"G55_DESORI" ,"G55")
    TRCell():New(oSection3,"G55_LOCDES" ,"G55")
    TRCell():New(oSection3,"G55_DESDES" ,"G55")
    TRCell():New(oSection3,"GI4_KM"     ,"GI4"  ,STR0002 )//"KM Parcial"
    TRCell():New(oSection3,"KMINI" 		,""     ,STR0003,,10) //"KM Inicial"
    TRCell():New(oSection3,"KMFIN"  	,""     ,STR0004,,10) //"KM Final"
    TRCell():New(oSection3,"KMACUMUL"   ,""     ,STR0005,"@E 99,999.99",9) //"KM Acumulada"
    TRCell():New(oSection3,"G55_HRINI"  ,"G55"  ,STR0006)//"Saída"
    TRCell():New(oSection3,"G55_HRFIM"  ,"G55"  ,STR0007)//"Chegada"
    TRCell():New(oSection3,"GIE_TPTR"   ,"GIE"  ,STR0008)//"Tempo Tot"
    TRCell():New(oSection3,"VISTO"      ,""     ,STR0009,/*Picture*/,15/*Tamanho*/,/*lPixel*/	,/* {|| }*/)//"Visto"

    oSection3:Cell("GYN_CODGID"):lHeaderSize	:= .F.
    oSection3:Cell("G55_DTCHEG"):lHeaderSize	:= .F.
    oSection3:Cell("G55_LOCORI"):lHeaderSize	:= .F.
    oSection3:Cell("G55_DESORI"):lHeaderSize	:= .F.
    oSection3:Cell("G55_LOCDES"):lHeaderSize	:= .F.
    oSection3:Cell("G55_DESDES"):lHeaderSize	:= .F.
    oSection3:Cell("GI4_KM"):lHeaderSize	    := .F.
    oSection3:Cell("KMINI"):lHeaderSize	:= .F.
    oSection3:Cell("KMFIN"):lHeaderSize	    := .F.
    oSection3:Cell("KMACUMUL"):lHeaderSize	    := .F.
    oSection3:Cell("G55_HRINI"):lHeaderSize	    := .F.
    oSection3:Cell("G55_HRFIM"):lHeaderSize	    := .F.
    oSection3:Cell("GIE_TPTR"):lHeaderSize	    := .F.

    oSection3:Cell('KMACUMUL'):SetBlock({|oTrCell| FORMULA(oTrCell,oSection3) })
        
    // Imprime quebra da diferença de Entradas (Receber) e Saídas (Pagar)
    oBreak := TRBreak():New(oSection1,{||},"",.F.) 
    oBreak:SetPageBreak(.T.)      
    oReport:OnPageBreak( { || oReport:SkipLine(1),nKmAcumul := 0 } ) 

Return(oReport)

//-------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Função responsável pela impressão da Ficha de Remessa.

@author SIGAGTP | Gabriela Naomi Kamimoto
@since 21/08/2017
@version 1.0

@type function
/*/
//-------------------------------------------------------------------

Static Function ReportPrint(oReport)
Local oSection1     := oReport:Section(STR0010)//"Dados Veiculo"
    SetQrySection(oReport)

    nKmAcumul := 0
	
    oSection1:Print()
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetQrySection
description
@author  jacomo.fernandes
@since   29/08/17
@version P12
/*/
//-------------------------------------------------------------------
Static Function SetQrySection(oReport)

Local oSection1     := oReport:Section(STR0010)//"Dados Veiculo"
Local oSection2     := oSection1:Section(STR0011)//"Escala"
Local oSection3     := oSection2:Section(STR0012)//"Trechos"   
Local cAliasSec1    := GetNextAlias()
Local cAliasSec2    := GetNextAlias()
Local cAliasSec3    := GetNextAlias()
    
    Pergunte( "GTPR300", .F. )
    
    oSection1:BeginQuery()
        BeginSql Alias cAliasSec1
            SELECT DISTINCT
				ST9.T9_CODBEM
			  , ST9.T9_PLACA
			  , ST9.T9_MODELO
			  , ST9.T9_CHASSI
			  , ST9.T9_RENAVAM
			FROM
				%table:ST9% ST9
				INNER JOIN
					%table:GQA% GQA
					ON
						GQA.GQA_CODVEI = ST9.T9_CODBEM
						AND GQA.%NotDel%
				INNER JOIN
					%table:G52% G52
					ON
						G52.G52_CODIGO = GQA.GQA_CODESC
						AND G52.G52_CODIGO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
						AND G52.%NotDel%
			WHERE
				ST9.T9_FILIAL = %xFilial:ST9%
				AND ST9.T9_CODBEM BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND ST9.%NotDel% 
        EndSql
    oSection1:EndQuery()
    
    oSection2:BeginQuery()
        BeginSql Alias cAliasSec2
            SELECT DISTINCT
				ST9.T9_CODBEM
			  , ST9.T9_PLACA
			  , ST9.T9_MODELO
			  , ST9.T9_CHASSI
			  , ST9.T9_RENAVAM
			  , G52.G52_CODIGO
			  , G52.G52_DESCRI
			FROM
				%table:ST9% ST9
				INNER JOIN
					%table:GQA% GQA
					ON
						GQA.GQA_FILIAL     = %xFilial:GQA%
						AND GQA.GQA_CODVEI = ST9.T9_CODBEM
						AND GQA.%NotDel%
				INNER JOIN
					%table:G52% G52
					ON
						G52.G52_FILIAL     = %xFilial:G52%
						AND G52.G52_CODIGO = GQA.GQA_CODESC
						AND G52.G52_CODIGO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
						AND G52.%NotDel%
			WHERE
				ST9.T9_FILIAL = %xFilial:ST9%
				AND ST9.T9_CODBEM BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND ST9.%NotDel%
        EndSql
    oSection2:EndQuery()

    //Query com os bilhetes vendidos.
    oSection3:BeginQuery()
        BeginSql Alias cAliasSec3
            Select
				GYN.GYN_CODGID
			  , G55.G55_DTCHEG
			  , G55.G55_LOCORI
			  , GI1ORI.GI1_DESCRI AS G55_DESORI
			  , G55.G55_LOCDES
			  , GI1DES.GI1_DESCRI AS G55_DESDES
			  , G55.G55_HRINI
			  , G55.G55_HRFIM
			  , GIE.GIE_TPTR
			  , GI4.GI4_KM
			  , G52.G52_CODIGO
			  , GQE.GQE_RECURS
			From
				%table:GQE% GQE
				INNER JOIN
					%table:GYN% GYN
					ON
						GYN.GYN_FILIAL     = %xFilial:GYN%
						AND GYN.GYN_CODIGO = GQE.GQE_VIACOD
						AND
						(
							GYN.GYN_DTINI BETWEEN %Exp:DtoS(MV_PAR03)% AND %Exp:DtoS(MV_PAR04)%
							OR GYN.GYN_DTFIM BETWEEN %Exp:DtoS(MV_PAR03)% AND %Exp:DtoS(MV_PAR04)%
						)
						AND GYN.%NotDel%
				INNER JOIN
					%table:G55% G55
					ON
						G55.G55_FILIAL     = %xFilial:G55%
						AND G55.G55_CODVIA = GYN.GYN_CODIGO
						AND G55.G55_SEQ    = GQE.GQE_SEQ
						AND G55.%NotDel%
				INNER JOIN
					%table:GI1% GI1ORI
					ON
						GI1ORI.GI1_FILIAL  = %xFilial:GI1%
						AND GI1ORI.GI1_COD = G55.G55_LOCORI
						AND GI1ORI.%NotDel%
				INNER JOIN
					%table:GI1% GI1DES
					ON
						GI1DES.GI1_FILIAL  = %xFilial:GI1%
						AND GI1DES.GI1_COD = G55.G55_LOCDES
						AND GI1DES.%NotDel%
				INNER JOIN
					%table:GIE% GIE
					ON
						GIE.GIE_FILIAL     = %xFilial:GIE%
						AND GIE.GIE_CODGID = GYN.GYN_CODGID
						AND GIE.GIE_SEQ    = GQE.GQE_SEQ
						AND GIE.GIE_HIST   = '2'
						AND GIE.%NotDel%
				INNER JOIN
					%table:GI4% GI4
					ON
						GI4.GI4_FILIAL     = %xFilial:GI4%
						AND GI4.GI4_LINHA  = GYN.GYN_LINCOD
						AND GI4.GI4_LOCORI = G55.G55_LOCORI
						AND GI4.GI4_LOCDES = G55.G55_LOCDES
						AND GI4.GI4_HIST   = '2'
						AND GI4.%NotDel%
				INNER JOIN
					%table:G52% G52
					ON
						G52.G52_FILIAL     = %xFilial:G52%
						AND G52.G52_SERVIC = GYN.GYN_CODGID
						AND G52.G52_CODIGO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
						AND G52.%NotDel%
				INNER JOIN
					%table:GQA% GQA
					ON
						GQA.GQA_FILIAL     = %xFilial:GQA%
						AND GQA.GQA_CODESC = G52.G52_CODIGO
						AND GQA.%NotDel%
				INNER JOIN
					%table:ST9% ST9
					ON
						ST9.T9_FILIAL     = %xFilial:ST9%
						AND ST9.T9_CODBEM = GQA.GQA_CODVEI
						AND ST9.%NotDel%
			Where
				GQE.GQE_FILIAL = %xFilial:GQE%
				AND GQE.GQE_RECURS BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%
				AND GQE.GQE_TRECUR = '2'
				AND GQE.GQE_TERC IN (' '
								   , '2')
			ORDER BY
				G52.G52_CODIGO
			  , G55_DTCHEG
			  , G55_HRINI
        EndSql
    oSection3:EndQuery()
    
    oSection2:SetParentFilter({|cParam| Rtrim((cAliasSec2)->(T9_CODBEM) )== cParam},{|| Rtrim( (cAliasSec1)->(T9_CODBEM) )})
    oSection3:SetParentFilter({|cParam| Rtrim((cAliasSec3)->(G52_CODIGO+ GQE_RECURS ) )== cParam},{|| Rtrim( (cAliasSec2)->(G52_CODIGO+T9_CODBEM) )})

Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} FORMULA(A,B,C,D,E)
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function FORMULA(oTrCell,oSection3)
nKmAcumul +=  Val(oSection3:Cell('GI4_KM'):GetText())
Return nKmAcumul
