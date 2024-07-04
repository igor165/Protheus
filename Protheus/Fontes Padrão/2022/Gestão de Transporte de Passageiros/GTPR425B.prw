#include 'PROTHEUS.CH'
#include 'PARMTYPE.CH'
#include 'GTPR425B.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPR425B
Relatório Horas completadas/Extras
@type Function
@author 
@since 27/01/2021
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPR425B()

Local oReport := nil

If Pergunte("GTPR425B", .T.)
    oReport := ReportDef()
    oReport:PrintDialog()
EndIf

Return 

/*/{Protheus.doc} ReportDef
(long_description)
@type  Static Function
@author user
@since 27/01/2021
@version version
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportDef()

Local oReport    := Nil
Local oSectColab := Nil	
Local oSectViagm := Nil
Local oSectTota  := Nil	
Local oBreak     := Nil
Local cTitle     := ""
Local cHelp      := STR0001 //"Este relatorio ira imprimir o Relatório com os horários dos Colaboradores."
Local cPerg      := "GTPR425B"

oReport := TReport():New(cPerg, cTitle, cPerg, {|oReport|ReportPrint(oReport)}, cHelp, .T.,, .F.,, .F., .F.,)

//Seção do colaborador
oSectColab := TRSection():New(oReport, STR0002, {"GYG"})  //"Colaborador"
TRCell():New(oSectColab, "GYG_CODIGO" , "GYG", STR0003,,  TamSx3('GYG_CODIGO')[1],,,,,,,5,,,,)  //"Código GTP"
TRCell():New(oSectColab, "GYG_FUNCIO" , "GYG", STR0004,, TamSx3('GYG_FUNCIO')[1],,,,,,,5,,,,)  //"Matrícula RH"
TRCell():New(oSectColab, "GYG_NOME"   , "GYG", STR0005,, TamSx3('GYG_NOME')[1],,,,,,,5,,,,)  //"Nome"
TRCell():New(oSectColab, "TMP_STATUS" , "GYG", STR0006,, 50,,,,,,,5,,,,)  //"Status RH"

//Seção da viagem
oSectViagm := TRSection():New(oReport, "", {"GYN"}) 
TRCell():New(oSectViagm, "GYN_CODIGO", "GYN", STR0007,, TamSx3('GYN_CODIGO')[1],,,,,,,5,,,,) //"Código viagem"
TRCell():New(oSectViagm, "TMP_LOCORI", "GYN", STR0008,, 30,,,,,,,5,,,,) //"Localidade início"
TRCell():New(oSectViagm, "TMP_LOCDES", "GYN", STR0009,, 30,,,,,,,5,,,,) //"Localidade destino"
TRCell():New(oSectViagm, "GYN_DTINI" , "GYN", STR0010,, TamSx3('GYN_DTINI')[1],,,,,,,5,,,,) //"Data inicio"
TRCell():New(oSectViagm, "GYN_DTFIM" , "GYN", STR0011,, TamSx3('GYN_DTFIM')[1],,,,,,,5,,,,) //"Data destino"
TRCell():New(oSectViagm, "GYN_HRINI" , "GYN", STR0012,, TamSx3('GYN_HRINI' )[1],,,,,,,5,,,,) //"Hora inicial"
TRCell():New(oSectViagm, "GYN_HRFIM" , "GYN", STR0013,, TamSx3('GYN_HRFIM' )[1],,,,,,,5,,,,) //"Hora final"
TRCell():New(oSectViagm, "TMP_FINAL" , "GYN", STR0014,, 10                     ,,,,,,,5,,,,) //"Total horas trecho"
TRCell():New(oSectViagm, "TMP_COLAB" , "GYN", STR0015,, 15                     ,,,,,,,5,,,,) //"Status trecho"

oSectTota := TRSection():New(oReport, "", {"GQE"}) 
TRCell():New(oSectTota, "TMP_HRPAG" , "GQE", STR0016 ,, 15,,,,,,,5,,,,)   //"Total de horas feitas"
TRCell():New(oSectTota, "TMP_HRVOL" , "GQE", STR0017 ,, 15,,,,,,,5,,,,) //"Total de horas extras feitas"
TRCell():New(oSectTota, "TMP_HRFVOL", "GQE", STR0018 ,, 15,,,,,,,5,,,,)   //"Total de horas completadas"
TRCell():New(oSectTota, "TMP_TOTAL" , "GQE", STR0019 ,, 15,,,,,,,5,,,,)   //"Total de horas não completadas"
TRCell():New(oSectTota, "TMP_DSR"   , "GQE", STR0020 ,, 15,,,,,,,5,,,,)  //"Total de D.S.R."
TRCell():New(oSectTota, "TMP_THRVOL", "GQE", STR0021 ,, 15,,,,,,,5,,,,)  //"Total de horas volante"

oSectViagm:SetLeftMargi(5)
oSectViagm:SetTotalInLine(.F.)

oSectTota:SetLeftMargi(5)
oSectTota:SetTotalInLine(.F.)

oBreak := TRBreak():New(oSectColab, oSectColab:Cell("GYG_CODIGO"), STR0002, .F., "GYG_CODIGO", .F.) //STR0002 //"Colaborador"
oBreak:SetPageBreak(.T.)

Return oReport

/*/{Protheus.doc} ReportPrint
(long_description)
@type  Static Function
@author user
@since 27/01/2021
@version version
@param oReport, param_type, param_descr
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportPrint(oReport)
Local cAliasTmp    := ""
Local oSectColab   := oReport:Section(1)
Local oSectViagm   := oReport:Section(2)
Local oSectTota    := oReport:Section(3)
Local cColab       := ""
Local cHrVolante   := "00:00"
Local cTotal       := "00:00"
Local cHrExtra     := "00:00"
Local cHrCompleta  := "00:00"
Local cHrNaCompleta:= "00:00"
Local cHrTrech     := "00:00"
Local cDsr         := "0"
Local oCalcDia

Pergunte("GTPR425B", .F.)

cAliasTmp := SetQrySection()

DbSelectArea(cAliasTmp)
(cAliasTmp)->(dbGoTop())
oReport:SetMeter((cAliasTmp)->(RecCount()))

If (cAliasTmp)->(!Eof())
	While (cAliasTmp)->(!Eof())
		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()
		oCalcDia   := GTPxCalcHrDia():New(STOD((cAliasTmp)->G55_DTPART),(cAliasTmp)->GYT_CODIGO,(cAliasTmp)->GYG_CODIGO)
		If EMPTY(cColab) .OR. cColab != (cAliasTmp)->GYG_CODIGO
			
			If !(EMPTY(cColab)) .AND. cColab != (cAliasTmp)->GYG_CODIGO
				cDsr := val(cDsr) + CalcDsr(MV_PAR01,MV_PAR02)
				oSectTota:init()
				oSectTota:Cell("TMP_HRPAG" ):SetValue(cTotal)       //"Total de horas feitas"
				oSectTota:Cell("TMP_HRVOL" ):SetValue(cHrExtra)     //"Total de horas extras feitas" 
				oSectTota:Cell("TMP_HRFVOL"):SetValue(cHrCompleta)  //"Total de horas completadas"
				oSectTota:Cell("TMP_TOTAL" ):SetValue(cHrNaCompleta)//"Total de horas não completadas"
				oSectTota:Cell("TMP_DSR"   ):SetValue(cvaltochar(cDsr))         //"Total de D.S.R."
				oSectTota:Cell("TMP_THRVOL"):SetValue(cHrVolante)   //"Total de horas volante"
				oSectTota:PrintLine()
				oSectTota:Finish()
				cTotal        := "00:00"
				cHrExtra      := "00:00"
				cHrCompleta   := "00:00"
				cHrNaCompleta := "00:00"
				cDsr          := "0"
				cHrVolante    := "00:00"
			EndIf
			cColab := (cAliasTmp)->GYG_CODIGO
			If !(EMPTY(cColab))
				oReport:SkipLine()
				oSectViagm:Finish()
				oSectColab:Finish()
			EndIf
			oSectColab:Init()		
		
			oSectColab:Cell("GYG_CODIGO"):SetValue((cAliasTmp)->GYG_CODIGO)
			oSectColab:Cell("GYG_CODIGO"):SetBorder("BOTTOM",0,0,.T.)
			
			oSectColab:Cell("GYG_FUNCIO"):SetValue((cAliasTmp)->GYG_FUNCIO)
			oSectColab:Cell("GYG_FUNCIO"):SetBorder("BOTTOM",0,0,.T.)

			oSectColab:Cell("GYG_NOME"):SetValue((cAliasTmp)->GYG_NOME)
			oSectColab:Cell("GYG_NOME"):SetBorder("BOTTOM",0,0,.T.)

			If !(EMPTY((cAliasTmp)->R8_TIPOAFA))
				oSectColab:Cell("TMP_STATUS"):SetValue((cAliasTmp)->R8_TIPOAFA + " - " + (cAliasTmp)->RCM_DESCRI)
			ElseIf !(EMPTY((cAliasTmp)->RA_DEMISSA))
				oSectColab:Cell("TMP_STATUS"):SetValue(STR0022)  //"Demitido"
			Else
				oSectColab:Cell("TMP_STATUS"):SetValue(STR0023)  //"Normal"
			EndIf
			oSectColab:Cell("TMP_STATUS"):SetBorder("BOTTOM",0,0,.T.)

			oSectColab:PrintLine()
		EndIf 

		cHrTrech := IntToHora(GxElapseTime(stod((cAliasTmp)->G55_DTPART),horatoint((cAliasTmp)->TMP_HRINTR),stod((cAliasTmp)->G55_DTCHEG),horatoint((cAliasTmp)->TMP_HRFNTR)))
		oSectViagm:init()
		oSectViagm:Cell("GYN_CODIGO"):SetValue((cAliasTmp)->GYN_CODIGO)
		oSectViagm:Cell("TMP_LOCORI"):SetValue((cAliasTmp)->G55_LOCORI + '-' + (cAliasTmp)->TMP_DESORI)
		oSectViagm:Cell("TMP_LOCDES"):SetValue((cAliasTmp)->G55_LOCDES + '-' + (cAliasTmp)->TMP_DESDES)
		oSectViagm:Cell("GYN_DTINI" ):SetValue(STOD((cAliasTmp)->G55_DTPART))
		oSectViagm:Cell("GYN_DTFIM" ):SetValue(STOD((cAliasTmp)->G55_DTCHEG) )
		oSectViagm:Cell("GYN_HRINI" ):SetValue((cAliasTmp)->TMP_HRINTR )
		oSectViagm:Cell("GYN_HRFIM" ):SetValue((cAliasTmp)->TMP_HRFNTR)		
		oSectViagm:Cell("TMP_FINAL" ):SetValue(cHrTrech)
		oSectViagm:Cell("TMP_COLAB" ):SetValue(IIF((cAliasTmp)->GYN_FINAL == "1",STR0025,STR0024) ) //"Planejado" //"Realizado"
		
		oSectViagm:PrintLine()
		oCalcDia:AddTrechos('1',STOD((cAliasTmp)->G55_DTPART),(cAliasTmp)->TMP_HRINTR,,,STOD((cAliasTmp)->G55_DTCHEG),(cAliasTmp)->TMP_HRFNTR,,,.T.,.T.)
		oCalcDia:CalculaDia()

		cTotal        := IntToHora(SomaHoras(cTotal,oCalcDia:cHrJorn))
		cTotal        := IntToHora(SomaHoras(cTotal,cHrTrech))      
		cHrExtra      := IntToHora(SomaHoras(cHrExtra,oCalcDia:cHrExtra))
		If (cAliasTmp)->GYN_FINAL == "1"
			cHrCompleta   := IntToHora(SomaHoras(cHrCompleta,cHrTrech)) 
		Else
			cHrNaCompleta := IntToHora(SomaHoras(cHrNaCompleta,cHrTrech))
		EndIf
		If oCalcDia:cTpDia == "6" //DSR
			cDsr := cvaltochar(val(cDsr) + 1)
		Endif
			
		cHrVolante    := IntToHora(SomaHoras(cHrVolante,oCalcDia:cHrVolante))
	
		(cAliasTmp)->(dbSkip())
	End
	If !(EMPTY(cColab))
		cDsr := val(cDsr) + CalcDsr(MV_PAR01,MV_PAR02)
		oSectTota:init()
		oSectTota:Cell("TMP_HRPAG" ):SetValue(cTotal)       //"Total de horas feitas"
		oSectTota:Cell("TMP_HRVOL" ):SetValue(cHrExtra)     //"Total de horas extras feitas" 
		oSectTota:Cell("TMP_HRFVOL"):SetValue(cHrCompleta)  //"Total de horas completadas"
		oSectTota:Cell("TMP_TOTAL" ):SetValue(cHrNaCompleta)//"Total de horas não completadas"
		oSectTota:Cell("TMP_DSR"   ):SetValue(cvaltochar(cDsr))         //"Total de D.S.R."
		oSectTota:Cell("TMP_THRVOL"):SetValue(cHrVolante)   //"Total de horas volante"
		oSectTota:PrintLine()
		oSectTota:Finish()
	EndIf
EndIf
(cAliasTmp)->(DbCloseArea())
oSectViagm:Finish()
oSectColab:Finish()
Return 

/*/{Protheus.doc} CalcDsr
(long_description)
@type  Static Function
@author user
@since 01/02/2021
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function CalcDsr(dDataInicio,dDataFinal)
Local nDsr := 0

While dDataInicio != dDataFinal
	If Dow(dDataInicio) == 1
		nDsr++
	EndIf
	dDataInicio := DaySum(dDataInicio,1)
End

Return nDsr
/*/{Protheus.doc} SetQrySection
(long_description)
@type  Static Function
@author user
@since 28/01/2021
@version version
@return cAliasSec, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetQrySection()
Local cAliasSec  := GetNextAlias()
Local cWhere     := ""

If MV_PAR07 == 3
	cWhere := "%%"
ElseIf MV_PAR07 == 2
	cWhere := "% AND GYN.GYN_FINAL = '1' %"
Else
	cWhere := "% AND GYN.GYN_FINAL = '2' %"
EndIf
BeginSql Alias cAliasSec
SELECT 
	GYG.GYG_CODIGO
	, GYG.GYG_FUNCIO
	, GYG.GYG_NOME
	, SRA.RA_MAT
	, SRA.RA_CODFUNC
	, SRA.RA_DEMISSA 
	, SR8.R8_TIPOAFA
	, RCM.RCM_DESCRI
	, GYN.GYN_FILIAL
	, GYN.GYN_CODIGO
	, GYN.GYN_FINAL
	, G55.G55_SEQ
	, G55.G55_LOCORI
	, (	
		SELECT GI1.GI1_DESCRI 
		FROM %Table:GI1% GI1 
		WHERE GI1.GI1_FILIAL = %xFilial:GI1% AND GI1.GI1_COD = G55.G55_LOCORI AND GI1.%NotDel% 
	  ) TMP_DESORI
	, GQE.GQE_HRINTR TMP_HRINTR
	, GQE.GQE_CONF TMP_CONF
	, G55.G55_LOCDES
	, (
		SELECT GI1.GI1_DESCRI 
		FROM %Table:GI1% GI1 
		WHERE GI1.GI1_FILIAL = %xFilial:GI1% AND GI1.GI1_COD = G55.G55_LOCDES AND GI1.%NotDel% 
	  ) TMP_DESDES
	, GQE.GQE_HRFNTR TMP_HRFNTR
	, G55.G55_DTPART
	, G55.G55_DTCHEG
	, GQE.GQE_TCOLAB TMP_TCOLAB
	, GYK.GYK_DESCRI
    , GYT.GYT_CODIGO
FROM %Table:GYG% GYG
	INNER JOIN 
		%Table:GYN% GYN
		ON
			GYN.GYN_FILIAL     = %xFilial:GYN%
			AND GYN.GYN_DTINI >= %Exp:MV_PAR01%
			AND GYN.GYN_DTFIM <= %Exp:MV_PAR02%
			AND GYN.%NotDel%
			%Exp:cWhere%
	INNER JOIN
		%Table:G55% G55
		ON
			G55.G55_FILIAL     = GYN.GYN_FILIAL
			AND G55.G55_CODVIA = GYN.GYN_CODIGO
			AND G55.G55_CODGID = GYN.GYN_CODGID
			AND G55.%NotDel%
	INNER JOIN
		%Table:GQE% GQE
		ON
			GQE.GQE_FILIAL     = GYN.GYN_FILIAL
			AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
			AND GQE.GQE_SEQ    = G55.G55_SEQ
			AND GQE.GQE_TRECUR = '1'
			AND GQE.GQE_TERC IN (' ','2')
			AND GQE.%NotDel%
	INNER JOIN 
		%Table:GYK% GYK
		ON
			GYK.GYK_FILIAL = %xFilial:GYK%
			AND GYK.GYK_CODIGO = GQE.GQE_TCOLAB
			AND GYK.%NotDel%
	LEFT JOIN
		%Table:SRA% SRA
		ON
			SRA.RA_FILIAL     = GYG.GYG_FILSRA
			AND SRA.RA_MAT    = GYG.GYG_FUNCIO
			AND SRA.%NotDel%
	LEFT JOIN
		%Table:SR8% SR8
		ON
			SR8.R8_FILIAL       = SRA.RA_FILIAL
			AND SR8.R8_MAT      = SRA.RA_MAT
			AND SR8.R8_DATAINI >= %Exp:MV_PAR01%
			AND SR8.R8_DATAINI >= GQE.GQE_DTREF
			AND SR8.R8_DATAFIM <= %Exp:MV_PAR02%
			AND SR8.R8_DATAFIM <= GQE.GQE_DTREF
			AND SR8.%NotDel%
	LEFT JOIN 
		%Table:RCM% RCM
		ON
			RCM.RCM_FILIAL      = %xFilial:RCM%
			AND RCM.RCM_TIPO    = SR8.R8_TIPOAFA
			AND RCM.%NotDel%
	LEFT JOIN
		%Table:GYT% GYT
		ON
			GYT.GYT_FILIAL = %xFilial:GYT%
			AND GYT.GYT_CODIGO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
			AND GYT.%NotDel%
	LEFT JOIN
		%Table:GY2% GY2
		ON
			GY2.GY2_FILIAL     = GYT.GYT_FILIAL
			AND GY2.GY2_SETOR  = GYT.GYT_CODIGO
			AND GY2.GY2_CODCOL = GYG.GYG_CODIGO
			AND GY2.%NotDel%
WHERE	GYG.GYG_FILIAL = %xFilial:GYG%
		AND GYG.GYG_CODIGO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
		AND GYG.GYG_CODIGO = GQE.GQE_RECURS
		AND GYG.%NotDel%
UNION
SELECT 
	GYG.GYG_CODIGO
	, GYG.GYG_FUNCIO
	, GYG.GYG_NOME
	, SRA.RA_MAT
	, SRA.RA_CODFUNC
	, SRA.RA_DEMISSA 
	, SR8.R8_TIPOAFA
	, RCM.RCM_DESCRI
	, GYN.GYN_FILIAL
	, GYN.GYN_CODIGO
	, GYN.GYN_FINAL
	, G55.G55_SEQ
	, G55.G55_LOCORI
	, (	
		SELECT GI1.GI1_DESCRI 
		FROM %Table:GI1% GI1 
		WHERE GI1.GI1_FILIAL = %xFilial:GI1% AND GI1.GI1_COD = G55.G55_LOCORI AND GI1.%NotDel% 
	  ) TMP_DESORI
	, GQK.GQK_HRINI TMP_HRINTR
	, GQK.GQK_CONF TMP_CONF
	, G55.G55_LOCDES
	, (
		SELECT GI1.GI1_DESCRI 
		FROM %Table:GI1% GI1 
		WHERE GI1.GI1_FILIAL = %xFilial:GI1% AND GI1.GI1_COD = G55.G55_LOCDES AND GI1.%NotDel% 
	  ) TMP_DESDES
	, GQK.GQK_HRFIM TMP_HRFNTR
	, G55.G55_DTPART
	, G55.G55_DTCHEG
	, GQK.GQK_TCOLAB TMP_TCOLAB
	, GYK.GYK_DESCRI
    , GYT.GYT_CODIGO
FROM %Table:GYG% GYG
	INNER JOIN 
		%Table:GYN% GYN
		ON
			GYN.GYN_FILIAL     = %xFilial:GYN%
			AND GYN.GYN_DTINI >= %Exp:MV_PAR01%
			AND GYN.GYN_DTFIM <= %Exp:MV_PAR02%
			AND GYN.%NotDel%
			%Exp:cWhere%
	INNER JOIN
		%Table:G55% G55
		ON
			G55.G55_FILIAL     = GYN.GYN_FILIAL
			AND G55.G55_CODVIA = GYN.GYN_CODIGO
			AND G55.G55_CODGID = GYN.GYN_CODGID
			AND G55.%NotDel%
	INNER JOIN
		%Table:GQK% GQK
		ON
			GQK.GQK_FILIAL     = GYN.GYN_FILIAL
			AND GQK.GQK_CODVIA = GYN.GYN_CODIGO
			AND
			(
				GQK.GQK_LOCORI    = GYN.GYN_LOCORI
				OR GQK.GQK_LOCDES = GYN.GYN_LOCDES
			)
			AND GQK.GQK_TRECUR = '1'
			AND GQK.GQK_TERC IN (' ','2')
			AND GQK.%NotDel%
	INNER JOIN 
		%Table:GYK% GYK
		ON
			GYK.GYK_FILIAL = %xFilial:GYK%
			AND GYK.GYK_CODIGO = GQK.GQK_TCOLAB
			AND GYK.%NotDel%
	LEFT JOIN
		%Table:SRA% SRA
		ON
			SRA.RA_FILIAL     = GYG.GYG_FILSRA
			AND SRA.RA_MAT    = GYG.GYG_FUNCIO
			AND SRA.%NotDel%
	LEFT JOIN
		%Table:SR8% SR8
		ON
			SR8.R8_FILIAL       = SRA.RA_FILIAL
			AND SR8.R8_MAT      = SRA.RA_MAT
			AND SR8.R8_DATAINI >= %Exp:MV_PAR01%
			AND SR8.R8_DATAINI >= GQK.GQK_DTINI
			AND SR8.R8_DATAFIM <= %Exp:MV_PAR02%
			AND SR8.R8_DATAFIM <= GQK.GQK_DTFIM
			AND SR8.%NotDel%
	LEFT JOIN 
		%Table:RCM% RCM
		ON
			RCM.RCM_FILIAL      = %xFilial:RCM%
			AND RCM.RCM_TIPO    = SR8.R8_TIPOAFA
			AND RCM.%NotDel%
	LEFT JOIN
		%Table:GYT% GYT
		ON
			GYT.GYT_FILIAL = %xFilial:GYT%
			AND GYT.GYT_CODIGO BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
			AND GYT.%NotDel%
	LEFT JOIN
		%Table:GY2% GY2
		ON
			GY2.GY2_FILIAL     = GYT.GYT_FILIAL
			AND GY2.GY2_SETOR  = GYT.GYT_CODIGO
			AND GY2.GY2_CODCOL = GYG.GYG_CODIGO
			AND GY2.%NotDel%
WHERE	GYG.GYG_FILIAL = %xFilial:GYG%
		AND GYG.GYG_CODIGO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
		AND GYG.GYG_CODIGO = GQK.GQK_RECURS
		AND GYG.%NotDel%
ORDER BY
	GYG_CODIGO
	, GYN_FILIAL
	, GYN_CODIGO
EndSql

Return cAliasSec
