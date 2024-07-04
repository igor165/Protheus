#Include "GTPR425.ch"
#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include 'FWMVCDef.ch'

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPR425
Fonte de relatório de efetivação de colaboradores por data e viagem
@type Function
@author henrique.toyada
@since 07/08/2020
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPR425()
Local oReport := Nil

If Pergunte("GTPR425", .T.)
	oReport := ReportDef()
	oReport:PrintDialog()
EndIf 

Return 

/*/{Protheus.doc} ReportDef
(long_description)
@type  Static Function
@author henrique.toyada
@since 07/08/2020
@version 1.0
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportDef()
Local oReport    := Nil
Local oSectColab := Nil	
Local oSectViagm := Nil
Local oSectTrech := Nil
Local oSectHist  := Nil
Local oSectTota  := Nil	
Local oBreak     := Nil
Local cTitle     := ""
Local cHelp      := STR0001 //"Este relatorio ira imprimir o Relatório com os horários dos Colaboradores."
Local cPerg      := "GTPR425"

Pergunte("GTPR425", .F.)

If MV_PAR10 == 1
	cTitle := STR0002 //"Efetivação Escala de Colaboradores - Sintético"
ElseIf MV_PAR10 == 2
	cTitle := STR0003 //"Efetivação Escala de Colaboradores - Analitico"
Else
	cTitle := STR0004 //"Efetivação Escala de Colaboradores - Analitico/Histórico"
EndIf

oReport := TReport():New(cPerg, cTitle, cPerg, {|oReport|ReportPrint(oReport)}, cHelp, .T.,, .F.,, .F., .F.,)

//Seção do colaborador
oSectColab := TRSection():New(oReport, STR0005, {"GYG"}) //STR0005 //"Colaborador"
TRCell():New(oSectColab, "TMP_COLAB" , "GYG", STR0005,, 50,,,,,,,5,,,,)  //STR0005#Cód + Nome //"Colaborador"
TRCell():New(oSectColab, "TMP_TIPO"  , "GYG", STR0006       ,, 15,,,,,,,5,,,,)  //STR0006# Cód + descrição //"Tipo"
TRCell():New(oSectColab, "TMP_FUNCAO", "GYG", STR0007     ,, 15,,,,,,,5,,,,)  //"Setor"# Cód + descrição //"Função"
TRCell():New(oSectColab, "TMP_SETOR" , "GYG", STR0008      ,, 50,,,,,,,5,,,,)  //STR0008# Cód + descrição //"Setor"

//Seção da viagem
oSectViagm := TRSection():New(oReport, STR0009, {"GYN"}) //"Viagem"
TRCell():New(oSectViagm, "GYN_CODIGO", "GYN", STR0009        ,, TamSx3('GYN_CODIGO')[1],,,,,,,5,,,,) //"Viagem"
TRCell():New(oSectViagm, "GYN_TIPO"  , "GYN", STR0006          ,, TamSx3('GYN_TIPO'  )[1],,,,,,,5,,,,) //"Tipo"
TRCell():New(oSectViagm, "GYN_LINCOD", "GYN", STR0010         ,, TamSx3('GYN_LINCOD')[1],,,,,,,5,,,,) //"Linha"
TRCell():New(oSectViagm, "GYN_CODGID", "GYN", STR0011       ,, TamSx3('GYN_CODGID')[1],,,,,,,5,,,,) //"Horário"
TRCell():New(oSectViagm, "GYN_DTINI" , "GYN", STR0012      ,, TamSx3('GYN_DTINI' )[1],,,,,,,5,,,,) //"Data Ini"
TRCell():New(oSectViagm, "GYN_DTFIM" , "GYN", STR0013      ,, TamSx3('GYN_DTFIM' )[1],,,,,,,5,,,,) //"Data Fim"
TRCell():New(oSectViagm, "TMP_FINAL" , "GYN", STR0014        ,, 30                     ,,,,,,,5,,,,) //"Status"
TRCell():New(oSectViagm, "TMP_COLAB" , "GYN", STR0015  ,, 30                     ,,,,,,,5,,,,) //"Status Colab"

//Seção dos trechos
oSectTrech := TRSection():New(oReport, STR0016, {"GQE"}) //"Trechos"
TRCell():New(oSectTrech, "GYN_LOCORI"  , "GQE", STR0017     ,, TamSx3('GYN_LOCORI')[1],,,,,,,5,,,,) //"Partida"
TRCell():New(oSectTrech, "TMP_LOCORI"  , "GQE", STR0018   ,, 15                     ,,,,,,,5,,,,)      //"Descrição"
TRCell():New(oSectTrech, "GYN_LOCDES"  , "GQE", STR0019     ,, TamSx3('GYN_LOCDES')[1],,,,,,,5,,,,)      //"Destino"
TRCell():New(oSectTrech, "TMP_LOCDES"  , "GQE", STR0018   ,, 15                     ,,,,,,,5,,,,) //"Descrição"
TRCell():New(oSectTrech, "G55_DTPART"  , "GQE", STR0020  ,, TamSx3('G55_DTPART')[1],,,,,,,5,,,,)      //"Dt Partida"
TRCell():New(oSectTrech, "G55_HRINI"   , "GQE", STR0021  ,, TamSx3('G55_HRINI' )[1],,,,,,,5,,,,)      //"Hr Partida"
TRCell():New(oSectTrech, "GQE_HRINTR"  , "GQE", STR0022,, TamSx3('GQE_HRINTR')[1],,,,,,,5,,,,)  //"Inicio Trab."
TRCell():New(oSectTrech, "G55_DTCHEG"  , "GQE", STR0023  ,, TamSx3('G55_DTCHEG')[1],,,,,,,5,,,,)  //"Dt Destino"
TRCell():New(oSectTrech, "G55_HRFIM"   , "GQE", STR0024  ,, TamSx3('G55_HRFIM' )[1],,,,,,,5,,,,)   //"Hr Destino"
TRCell():New(oSectTrech, "GQE_HRFNTR"  , "GQE", STR0025 ,, TamSx3('GQE_HRFNTR')[1],,,,,,,5,,,,)   //"Final Trab."
TRCell():New(oSectTrech, "TMP_PREVIS"  , "GQE", STR0026    ,, 15                     ,,,,,,,5,,,,)     //"Previsto"
TRCell():New(oSectTrech, "TMP_REALIS"  , "GQE", STR0027   ,, 15                     ,,,,,,,5,,,,)    //"Realizado"

//Seção de histórico
oSectHist := TRSection():New(oReport, STR0028, {"GQF"}) //"Histórico"
TRCell():New(oSectHist, "GQF_SEQ"   , "GQF", STR0029    ,, TamSx3('GQF_SEQ'   )[1],,,,,,,5,,,,) //"Sequência"
TRCell():New(oSectHist, "GQF_ITEM"  , "GQF", STR0030         ,, TamSx3('GQF_ITEM'  )[1],,,,,,,5,,,,)      //"Item"
TRCell():New(oSectHist, "GQF_REVISA", "GQF", STR0031      ,, TamSx3('GQF_REVISA')[1],,,,,,,5,,,,)      //"Revisão"
TRCell():New(oSectHist, "GQF_DTAREG", "GQF", STR0032  ,, TamSx3('GQF_DTAREG')[1],,,,,,,5,,,,)      //"Data Atuali"
TRCell():New(oSectHist, "GQF_HRAREG", "GQF", STR0033  ,, TamSx3('GQF_HRAREG')[1],,,,,,,5,,,,) //"Hora Atuali"
TRCell():New(oSectHist, "GQF_DTINI" , "GQF", STR0034 ,, TamSx3('GQF_DTINI' )[1],,,,,,,5,,,,)   //"Data Inicial"
TRCell():New(oSectHist, "GQF_RECANT", "GQF", STR0035,, TamSx3('GQF_RECANT')[1],,,,,,,5,,,,)  //"Reg. Anterior"

oSectTota := TRSection():New(oReport, STR0036, {"GQE"}) //"Colaborador" //"Totalizadores"
If MV_PAR10 != 1
	TRCell():New(oSectTota, "TMP_HRPAG" , "GYG", STR0037        ,, 15,,,,,,,5,,,,)  //"Horas pagas"
	TRCell():New(oSectTota, "TMP_HRVOL" , "GYG", STR0038      ,, 15,,,,,,,5,,,,)  //"Horas volante"
	TRCell():New(oSectTota, "TMP_HRFVOL", "GYG", STR0039 ,, 15,,,,,,,5,,,,)  //"Horas fora volante"
	TRCell():New(oSectTota, "TMP_TOTAL" , "GYG", STR0040 ,, 15,,,,,,,5,,,,)  //"Total de horas dia"
Else
	TRCell():New(oSectTota, "TMP_TOTAL" , "GYG", STR0040 ,, 15,,,,,,,5,,,,)  //"Total de horas dia"
EndIf
oSectHist:SetLeftMargi(10)
oSectHist:SetTotalInLine(.F.)

oSectViagm:SetLeftMargi(5)
oSectViagm:SetTotalInLine(.F.)

oSectTrech:SetLeftMargi(5)
oSectTrech:SetTotalInLine(.F.)

oSectTota:SetLeftMargi(5)
oSectTota:SetTotalInLine(.F.)

oBreak := TRBreak():New(oSectColab, oSectColab:Cell("TMP_COLAB"), STR0005, .F., "TMP_COLAB", .F.) //"Colaborador"
oBreak:SetPageBreak(.T.)

Return oReport

/*/{Protheus.doc} ReportPrint
(long_description)
@type  Static Function
@author henrique.toyada
@since 07/08/2020
@version 1.0
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportPrint(oReport)
Local oSectColab   := oReport:Section(1)
Local oSectViagm   := oReport:Section(2)
Local oSectTrech   := oReport:Section(3)
Local oSectHist    := oReport:Section(4)
Local oSectTota    := oReport:Section(5)
Local cAliasTmp    := ""
Local cColab       := ""
Local cViagem      := ""
Local cDtInicio    := ""
Local cHrPaga      := "00:00"
Local cHoraVolante := "00:00"
Local cHHrFVolante := "00:00"
Local cTotal       := "00:00"
Local lLoop        := .T. 
Local oCalcDia
Pergunte("GTPR425", .F.)

cAliasTmp := SetQrySection()

DbSelectArea(cAliasTmp)
(cAliasTmp)->(dbGoTop())
oReport:SetMeter((cAliasTmp)->(RecCount()))

While (cAliasTmp)->(!Eof())
    If oReport:Cancel()
        Exit
    EndIf

    oReport:IncMeter()
	oCalcDia   := GTPxCalcHrDia():New(STOD((cAliasTmp)->GYN_DTINI),(cAliasTmp)->GYT_CODIGO,(cAliasTmp)->GQE_RECURS)
    If EMPTY(cColab) .OR. cColab != (cAliasTmp)->GQE_RECURS
        cColab := (cAliasTmp)->GQE_RECURS
        If !(EMPTY(cColab))
            oReport:SkipLine()
            oSectColab:Finish()
        EndIf
        oSectColab:Init()		
	
        oSectColab:Cell("TMP_COLAB"):SetValue((cAliasTmp)->GQE_RECURS + " - " + (cAliasTmp)->GYG_NOME)
        oSectColab:Cell("TMP_COLAB"):SetBorder("BOTTOM",0,0,.T.)
        
        oSectColab:Cell("TMP_TIPO"):SetValue((cAliasTmp)->GYN_TIPO + " - " + IIF((cAliasTmp)->GYN_TIPO=="1",STR0041,STR0042)) //"Normal" //"Extraordinario"
        oSectColab:Cell("TMP_TIPO"):SetBorder("BOTTOM",0,0,.T.)

		oSectColab:Cell("TMP_FUNCAO"):SetValue((cAliasTmp)->RA_CODFUNC + " - " + FDESC('SRJ',(cAliasTmp)->RA_CODFUNC,'RJ_DESC',TamSX3('RJ_DESC'),(cAliasTmp)->GYG_FILSRA))
		
        oSectColab:Cell("TMP_FUNCAO"):SetBorder("BOTTOM",0,0,.T.)

		oSectColab:Cell("TMP_SETOR"):SetValue(IIF(!(EMPTY((cAliasTmp)->GYT_CODIGO)),(cAliasTmp)->GYT_CODIGO + " - " + POSICIONE("GI1",1,XFILIAL("GI1")+(cAliasTmp)->GYT_LOCALI,"GI1_DESCRI"),STR0043)) //"Não informado"
        oSectColab:Cell("TMP_SETOR"):SetBorder("BOTTOM",0,0,.T.)

        oSectColab:PrintLine()
    EndIf 

	If cViagem != (cAliasTmp)->GYN_CODIGO
        If !(EMPTY(cViagem))
			If MV_PAR10 != 1
				oSectTota:init()
				oSectTota:Cell("TMP_HRPAG" ):SetValue(cHrPaga)
				oSectTota:Cell("TMP_HRVOL" ):SetValue(cHoraVolante)  
				oSectTota:Cell("TMP_HRFVOL"):SetValue(cHHrFVolante)
				oSectTota:Cell("TMP_TOTAL" ):SetValue(cTotal)
				oSectTota:PrintLine()
				oSectTota:Finish()
				cHrPaga      := "00:00"
				cHoraVolante := "00:00"
				cHHrFVolante := "00:00"
				cTotal       := "00:00"
			EndIf
		EndIf
	EndIf

	If cDtInicio != (cAliasTmp)->GYN_DTINI
		cDtInicio := (cAliasTmp)->GYN_DTINI
		If !(EMPTY(cDtInicio))
			If MV_PAR10 == 1
				oSectTota:init()
				oSectTota:Cell("TMP_TOTAL" ):SetValue(cTotal)
				oSectTota:PrintLine()
				oSectTota:Finish()
				cTotal       := "00:00"
			EndIf
		EndIf
	EndIf
	If EMPTY(cViagem) .OR. cViagem != (cAliasTmp)->GYN_CODIGO
        cViagem := (cAliasTmp)->GYN_CODIGO
        If !(EMPTY(cViagem))
			oReport:SkipLine()
			oSectTrech:Finish()
			oSectViagm:Finish()
			lLoop := .T.
        EndIf
		oSectViagm:init()
		oSectViagm:Cell("GYN_CODIGO"):SetValue((cAliasTmp)->GYN_CODIGO)
		oSectViagm:Cell("GYN_TIPO"  ):SetValue(IIF((cAliasTmp)->GYN_TIPO=='1',STR0041,STR0044)  ) //"Normal" //"Extraordinária"
		oSectViagm:Cell("GYN_LINCOD"):SetValue((cAliasTmp)->GYN_LINCOD)
		oSectViagm:Cell("GYN_CODGID"):SetValue((cAliasTmp)->GYN_CODGID)
		oSectViagm:Cell("GYN_DTINI" ):SetValue(STOD((cAliasTmp)->GYN_DTINI) )
		oSectViagm:Cell("GYN_DTFIM" ):SetValue(STOD((cAliasTmp)->GYN_DTFIM) )
		oSectViagm:Cell("TMP_FINAL" ):SetValue(IIF((cAliasTmp)->GYN_FINAL=="1",STR0045,STR0046) ) //"Finalizada" //"Aberta"
		If !(EMPTY((cAliasTmp)->R8_TIPOAFA))
			oSectViagm:Cell("TMP_COLAB"):SetValue((cAliasTmp)->R8_TIPOAFA + " - " + Posicione("RCM",1,xFilial("RCM")+(cAliasTmp)->R8_TIPOAFA,"RCM_DESCRI"))
		ElseIf !(EMPTY((cAliasTmp)->RA_DEMISSA))
			oSectViagm:Cell("TMP_COLAB"):SetValue(STR0047) //"Demitido"
		Else
			oSectViagm:Cell("TMP_COLAB"):SetValue(STR0041) //"Normal"
		EndIf
		oSectViagm:PrintLine()

		If MV_PAR10 == 1
			oSectTrech:init()
			oSectTrech:Cell("GYN_LOCORI"):SetValue((cAliasTmp)->GYN_LOCORI)//No sintético pegar a localidade da viagem
			oSectTrech:Cell("TMP_LOCORI"):SetValue(POSICIONE("GI1",1,XFILIAL("GI1")+(cAliasTmp)->GYN_LOCORI,"GI1_DESCRI"))
			oSectTrech:Cell("GYN_LOCDES"):SetValue((cAliasTmp)->GYN_LOCDES)//No sintético pegar a localidade da viagem
			oSectTrech:Cell("TMP_LOCDES"):SetValue(POSICIONE("GI1",1,XFILIAL("GI1")+(cAliasTmp)->GYN_LOCDES,"GI1_DESCRI"))
			oSectTrech:Cell("G55_DTPART"):SetValue(STOD((cAliasTmp)->G55_DTPART))
			If lLoop
				lLoop := .F.
				oSectTrech:Cell("GQE_HRINTR"):SetValue((cAliasTmp)->GQE_HRINTR)
			EndIf
			oSectTrech:Cell("G55_HRINI" ):SetValue((cAliasTmp)->GYN_HRINI)
			oSectTrech:Cell("G55_DTCHEG"):SetValue(STOD((cAliasTmp)->G55_DTCHEG))
			oSectTrech:Cell("GQE_HRFNTR"):SetValue((cAliasTmp)->GQE_HRFNTR)
			oSectTrech:Cell("G55_HRFIM" ):SetValue((cAliasTmp)->GYN_HRFIM)
			oSectTrech:Cell("TMP_PREVIS"):SetValue(CalcHoras((cAliasTmp)->G55_HRINI,(cAliasTmp)->G55_HRFIM))
			oSectTrech:Cell("TMP_REALIS"):SetValue(CalcHoras((cAliasTmp)->GQE_HRINTR,(cAliasTmp)->GQE_HRFNTR))
			oSectTrech:PrintLine()

			cTotal := IntToHora(HORATOINT(cTotal) + HORATOINT(CalcHoras((cAliasTmp)->GQE_HRINTR,(cAliasTmp)->GQE_HRFNTR)))
		EndIf
	EndIf
	
	If MV_PAR10 != 1
		oCalcDia:AddTrechos('1',STOD((cAliasTmp)->G55_DTPART),(cAliasTmp)->G55_HRINI,,,STOD((cAliasTmp)->G55_DTCHEG),(cAliasTmp)->G55_HRFIM,,,.T.,.T.)
		oCalcDia:CalculaDia()
		cHrPaga       := IntToHora(HORATOINT(cHrPaga) + HORATOINT(oCalcDia:cHrPagas))
		cHoraVolante  := IntToHora(HORATOINT(cHoraVolante) + HORATOINT(oCalcDia:cHrVolante))
		cHHrFVolante  := IntToHora(HORATOINT(cHHrFVolante) + HORATOINT(IntToHora(oCalcDia:nHrJorn - oCalcDia:nHrVolante)))
		cTotal        := IntToHora(HORATOINT(cTotal) + HORATOINT(oCalcDia:cHrJorn))
		
		oSectTrech:init()
		oSectTrech:Cell("GYN_LOCORI"):SetValue((cAliasTmp)->G55_LOCORI)//No analitico pegar a localidade do trecho
		oSectTrech:Cell("TMP_LOCORI"):SetValue(POSICIONE("GI1",1,XFILIAL("GI1")+(cAliasTmp)->G55_LOCORI,"GI1_DESCRI"))
		oSectTrech:Cell("GYN_LOCDES"):SetValue((cAliasTmp)->G55_LOCDES)//No analitico pegar a localidade do trecho
		oSectTrech:Cell("TMP_LOCDES"):SetValue(POSICIONE("GI1",1,XFILIAL("GI1")+(cAliasTmp)->G55_LOCDES,"GI1_DESCRI"))
		oSectTrech:Cell("G55_DTPART"):SetValue(STOD((cAliasTmp)->G55_DTPART))
		oSectTrech:Cell("GQE_HRINTR"):SetValue((cAliasTmp)->GQE_HRINTR)
		oSectTrech:Cell("G55_HRINI" ):SetValue((cAliasTmp)->G55_HRINI)
		oSectTrech:Cell("G55_DTCHEG"):SetValue(STOD((cAliasTmp)->G55_DTCHEG))
		oSectTrech:Cell("GQE_HRFNTR"):SetValue((cAliasTmp)->GQE_HRFNTR)
		oSectTrech:Cell("G55_HRFIM" ):SetValue((cAliasTmp)->G55_HRFIM)
		oSectTrech:Cell("TMP_PREVIS"):SetValue(CalcHoras((cAliasTmp)->G55_HRINI,(cAliasTmp)->G55_HRFIM))
		oSectTrech:Cell("TMP_REALIS"):SetValue(CalcHoras((cAliasTmp)->GQE_HRINTR,(cAliasTmp)->GQE_HRFNTR))
		oSectTrech:PrintLine()

		If MV_PAR10 == 3 .AND. !(EMPTY((cAliasTmp)->GQF_SEQ)) .AND. !(EMPTY((cAliasTmp)->GQF_ITEM))
			oSectHist:init()
			oSectHist:Cell("GQF_SEQ"   ):SetValue((cAliasTmp)->GQF_SEQ         )
			oSectHist:Cell("GQF_ITEM"  ):SetValue((cAliasTmp)->GQF_ITEM        )
			oSectHist:Cell("GQF_REVISA"):SetValue((cAliasTmp)->GQF_REVISA      )
			oSectHist:Cell("GQF_DTAREG"):SetValue(STOD((cAliasTmp)->GQF_DTAREG))
			oSectHist:Cell("GQF_HRAREG"):SetValue((cAliasTmp)->GQF_HRAREG      )
			oSectHist:Cell("GQF_DTINI" ):SetValue(STOD((cAliasTmp)->GQF_DTINI) )
			oSectHist:Cell("GQF_RECANT"):SetValue((cAliasTmp)->GQF_RECANT      )
			oSectHist:PrintLine()
			oSectHist:Finish()
		EndIf
	EndIf
    (cAliasTmp)->(dbSkip())
End

(cAliasTmp)->(DbCloseArea())
oSectHist:Finish()
oSectTrech:Finish()
oSectViagm:Finish()
oSectColab:Finish()
Return

/*/{Protheus.doc} CalcHoras
(long_description)
@type  Static Function
@author henrique.toyada
@since 10/08/2020
@version 1.0
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function CalcHoras(cHrInic,cHoraFim)

Local nHrAux   := 0
Local cHrFinal := ""

nHrAux := HoraToInt(Transform(cHoraFim,"@R 99:99"))-HoraToInt(Transform(cHrInic,"@R 99:99"))
	
If nHrAux > 0
	cHrFinal := GTFormatHour(IntToHora(nHrAux), "99:99")
Else
	cHrFinal := GTFormatHour((HoraToInt("23:59")-HoraToInt(Transform(cHrInic,"@R 99:99")))+HoraToInt(Transform(cHoraFim,"@R 99:99")), "99:99")
Endif

Return cHrFinal

/*/{Protheus.doc} SetQrySection
(long_description)
@type  Static Function
@author henrique.toyada
@since 07/08/2020
@version 1.0
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetQrySection()
Local cAliasSec1 := GetNextAlias()
Local cQryGYG    := ""

cQryGYG := "%"
//GRUPO
IF !(Empty(MV_PAR08)) .Or. !(Empty(MV_PAR09))
	cQryGYG += "			AND EXISTS ( SELECT 1 							" 			+ Chr(13)
	cQryGYG += "						 FROM " + RetSQLName("GZA") +" GZA " 			+ Chr(13)
	cQryGYG += "						 INNER JOIN " + RetSQLName("GYI") +" GYI " 		+ Chr(13)
	cQryGYG += "						 ON  " 											+ Chr(13)
	cQryGYG += "							GYI.GYI_FILIAL = '"+ xFilial("GYI") + "' " 	+ Chr(13)
	cQryGYG += "							AND GYI.GYI_GRPCOD = GZA.GZA_CODIGO " 		+ Chr(13)
	cQryGYG += "							AND GYI.GYI_COLCOD = GYG_CODIGO" 			+ Chr(13)
	cQryGYG += "							AND GYI.D_E_L_E_T_ = ' ' " 					+ Chr(13)
	cQryGYG += "					WHERE GZA.GZA_FILIAL='" + xFilial("GZA") + "' " 	+ Chr(13)
	cQryGYG += "							AND GZA.GZA_CODIGO >='" + MV_PAR08 + "' "
	cQryGYG += "							AND GZA.GZA_CODIGO <='" + MV_PAR09 + "' "
	IF !(Empty(MV_PAR06) .Or. Empty(MV_PAR07))
		cQryGYG += "						AND GZA.GZA_SETOR >= '" + MV_PAR06 + "' "		+ Chr(13)
		cQryGYG += "						AND GZA.GZA_SETOR <= '" + MV_PAR07 + "' " 	+ Chr(13)
	EndIF
	cQryGYG += "							AND GZA.D_E_L_E_T_=' ' "						+ Chr(13)
	cQryGYG += "						) 	"											+ Chr(13)
//SETOR
ElseIF !Empty(MV_PAR06) .Or. !Empty(MV_PAR07)
	cQryGYG +=" AND EXISTS ( SELECT							 " 		+ Chr(13)
	cQryGYG +=" 	GYT_CODIGO							 " 		+ Chr(13)
	cQryGYG +="	FROM " + RetSQLName("GYT") +" GYT1 		 " 		+ Chr(13)
	cQryGYG +=" INNER JOIN "+ RetSQLName("GY2") +" GY21  " 	+ Chr(13)
	cQryGYG +=" 	ON GY21.GY2_FILIAL = GYT1.GYT_FILIAL " 		+ Chr(13)
	cQryGYG +=" 	AND GY21.GY2_SETOR = GYT1.GYT_CODIGO " 		+ Chr(13)
	cQryGYG +=" 	AND GY21.GY2_CODCOL = GYG.GYG_CODIGO " 		+ Chr(13)
	cQryGYG +=" 	AND GY21.D_E_L_E_T_ = ' '			 " 		+ Chr(13)
	cQryGYG +="	WHERE GYT_CODIGO BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "' " + Chr(13)
	cQryGYG +="	AND GYT1.D_E_L_E_T_ = ' ' ) "
EndIF
cQryGYG += "%"

	BeginSql Alias cAliasSec1
	    
		SELECT	GYN.GYN_FILIAL,
				GYN.GYN_CODIGO,
				GYN.GYN_TIPO,
				GYN.GYN_SRVEXT,
				GYN.GYN_SETOR,
				GYN.GYN_LINCOD,
				GYN.GYN_LOCORI,
				GYN.GYN_CODGID,
				GYN.GYN_LOCORI,
				GYN.GYN_DTINI,
				GYN.GYN_DTFIM,
				GYN.GYN_FINAL,
				GYN.GYN_LOCORI,
				GYN.GYN_HRINI,
				GYN.GYN_LOCDES,
				GYN.GYN_HRFIM,
				G55.G55_CODIGO,
				G55.G55_SEQ,
				G55.G55_LOCORI,
				G55.G55_HRINI,
				G55.G55_LOCDES,
				G55.G55_HRFIM,
				G55.G55_DTPART,
				G55.G55_DTCHEG,
				GQE.GQE_SEQ,
				GQE.GQE_RECURS,
				GQE.GQE_STATUS,
				GQE.GQE_HRINTR,
				GQE.GQE_HRFNTR,
				GQE.GQE_DTREF,
				GYG.GYG_NOME,
				GYG.GYG_FILSRA,
				GYG.GYG_FUNCIO,
				GYG.GYG_AGENCI,
				GQF.GQF_SEQ,
				GQF.GQF_ITEM,
				GQF.GQF_REVISA,
				GQF.GQF_DTAREG,
				GQF.GQF_HRAREG,
				GQF.GQF_DTINI ,
				GQF.GQF_RECANT,
				SR8.R8_TIPOAFA,
				SRA.RA_CODFUNC,
				SRA.RA_DEMISSA,
				GYG.GYG_CODIGO,
				GQF.GQF_SEQ,
				GQF.GQF_ITEM,
				GQF.GQF_REVISA,
				GYT.GYT_CODIGO,
				GYT.GYT_LOCALI
		FROM %Table:GYN% GYN
		INNER JOIN %Table:G55% G55
			ON  G55.G55_FILIAL = GYN.GYN_FILIAL
			AND G55.G55_CODVIA = GYN.GYN_CODIGO
			AND G55.G55_CODGID = GYN.GYN_CODGID
			AND G55.%NotDel%
		INNER JOIN %Table:GQE% GQE
			ON  GQE.GQE_FILIAL = GYN.GYN_FILIAL
			AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
			AND GQE.GQE_SEQ    = G55.G55_SEQ
			AND GQE.GQE_TCOLAB = %Exp:MV_PAR05%
			AND GQE.GQE_TRECUR = '1'
			AND GQE.GQE_TERC IN (' ','2')
			AND GQE.%NotDel%
		LEFT JOIN %Table:GYG% GYG
			ON GYG.GYG_FILIAL = GYN.GYN_FILIAL
			AND GYG.GYG_CODIGO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND GYG.GYG_CODIGO = GQE.GQE_RECURS
			AND GYG.%NotDel%
		LEFT JOIN %Table:GYT% GYT
			ON GYT.GYT_FILIAL = %xFilial:GYT%
			AND GYT.GYT_CODIGO BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
			AND GYT.%NotDel%
		LEFT JOIN %Table:GY2% GY2
			ON GY2.GY2_FILIAL = GYT.GYT_FILIAL
			AND GY2.GY2_SETOR = GYT.GYT_CODIGO
			AND GY2.GY2_CODCOL = GYG.GYG_CODIGO
			AND GY2.%NotDel%
		LEFT JOIN %Table:GQF% GQF
			ON GQF.GQF_FILIAL  = %xFilial:GQF%
			AND GQF.GQF_VIACOD = GYN.GYN_CODIGO
			AND GQF.GQF_SEQ    = GQE.GQE_SEQ
			AND GQF.GQF_ITEM   = GQE.GQE_ITEM
			AND GQF.GQF_RECURS = GQE.GQE_RECURS
			AND GQF.%NotDel%
		LEFT JOIN %Table:SRA% SRA
			ON SRA.RA_FILIAL = GYG.GYG_FILSRA
			AND SRA.RA_MAT = GYG.GYG_FUNCIO
			AND SRA.%NotDel%
		LEFT JOIN %Table:SR8% SR8
			ON SR8.R8_FILIAL = SRA.RA_FILIAL
			AND SR8.R8_MAT = SRA.RA_MAT
			AND SR8.R8_DATAINI >= %Exp:MV_PAR01%
			AND SR8.R8_DATAINI >= GQE.GQE_DTREF
			AND SR8.R8_DATAFIM <= %Exp:MV_PAR02%
			AND SR8.R8_DATAFIM <= GQE.GQE_DTREF
			AND SR8.%NotDel%
		WHERE 	GYN.GYN_FILIAL = %xFilial:GYN%
			AND GYN.GYN_DTINI >= %Exp:MV_PAR01%
			AND GYN.GYN_DTFIM <= %Exp:MV_PAR02%
			AND GYN.%NotDel%
			%Exp:cQryGYG%
		UNION
		SELECT	  GYN.GYN_FILIAL
				, GYN.GYN_CODIGO
				, GYN.GYN_TIPO
				, GYN.GYN_SRVEXT
				, GYN.GYN_SETOR
				, GYN.GYN_LINCOD
				, GYN.GYN_LOCORI
				, GYN.GYN_CODGID
				, GYN.GYN_LOCORI
				, GYN.GYN_DTINI
				, GYN.GYN_DTFIM
				, GYN.GYN_FINAL
				, GYN.GYN_LOCORI
				, GYN.GYN_HRINI
				, GYN.GYN_LOCDES
				, GYN.GYN_HRFIM
				, G55.G55_CODIGO
				, G55.G55_SEQ
				, G55.G55_LOCORI
				, G55.G55_HRINI
				, G55.G55_LOCDES
				, G55.G55_HRFIM
				, G55.G55_DTPART
				, G55.G55_DTCHEG
				, '' GQE_SEQ
				, GQK.GQK_RECURS GQE_RECURS
				, '' GQE_STATUS
				, GQK.GQK_HRINI GQE_HRINTR
				, GQK.GQK_HRFIM GQE_HRFNTR
				, GQK.GQK_DTREF GQE_DTREF
				, GYG.GYG_NOME
				, GYG.GYG_FILSRA
				, GYG.GYG_FUNCIO
				, GYG.GYG_AGENCI
				, GQF.GQF_SEQ
				, GQF.GQF_ITEM
				, GQF.GQF_REVISA
				, GQF.GQF_DTAREG
				, GQF.GQF_HRAREG
				, GQF.GQF_DTINI
				, GQF.GQF_RECANT
				, SR8.R8_TIPOAFA
				, SRA.RA_CODFUNC
				, SRA.RA_DEMISSA
				, GYG.GYG_CODIGO
				, GQF.GQF_SEQ
				, GQF.GQF_ITEM
				, GQF.GQF_REVISA
				, GYT.GYT_CODIGO
				, GYT.GYT_LOCALI
		FROM %Table:GYN% GYN
		INNER JOIN %Table:G55% G55
			ON  G55.G55_FILIAL = GYN.GYN_FILIAL
			AND G55.G55_CODVIA = GYN.GYN_CODIGO
			AND G55.G55_CODGID = GYN.GYN_CODGID
			AND G55.%NotDel%
		INNER JOIN %Table:GQK% GQK
			ON  GQK.GQK_FILIAL     = GYN.GYN_FILIAL
			AND GQK.GQK_CODVIA = GYN.GYN_CODIGO
			AND (GQK.GQK_LOCORI = GYN.GYN_LOCORI
			OR GQK.GQK_LOCDES = GYN.GYN_LOCDES)
			AND GQK.GQK_TCOLAB = '01'
			AND GQK.GQK_TRECUR = '1'
			AND GQK.GQK_TERC IN (' ','2')
			AND GQK.%NotDel%
		LEFT JOIN %Table:GYG% GYG
			ON GYG.GYG_FILIAL = GYN.GYN_FILIAL
			AND GYG.GYG_CODIGO BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%
			AND GYG.GYG_CODIGO = GQK.GQK_RECURS
			AND GYG.%NotDel%
		LEFT JOIN %Table:GYT% GYT
			ON GYT.GYT_FILIAL = %xFilial:GYT%
			AND GYT.GYT_CODIGO BETWEEN %Exp:MV_PAR06% AND %Exp:MV_PAR07%
			AND GYT.%NotDel%
		LEFT JOIN %Table:GY2% GY2
			ON GY2.GY2_FILIAL = GYT.GYT_FILIAL
			AND GY2.GY2_SETOR = GYT.GYT_CODIGO
			AND GY2.GY2_CODCOL = GYG.GYG_CODIGO
			AND GY2.%NotDel%
		LEFT JOIN %Table:GQF% GQF
			ON GQF.GQF_FILIAL     = '        '
			AND GQF.GQF_VIACOD = GYN.GYN_CODIGO
			AND GQF.GQF_SEQ    = G55.G55_SEQ
			AND GQF.GQF_RECURS = GQK.GQK_RECURS
			AND GQF.%NotDel%
		LEFT JOIN %Table:SRA% SRA
			ON SRA.RA_FILIAL = GYG.GYG_FILSRA
			AND SRA.RA_MAT = GYG.GYG_FUNCIO
			AND SRA.%NotDel%
		LEFT JOIN %Table:SR8% SR8
			ON SR8.R8_FILIAL = SRA.RA_FILIAL
			AND SR8.R8_MAT = SRA.RA_MAT
			AND SR8.R8_DATAINI >= %Exp:MV_PAR01%
			AND SR8.R8_DATAINI >= GQK.GQK_DTREF
			AND SR8.R8_DATAFIM <= %Exp:MV_PAR02%
			AND SR8.R8_DATAFIM <= GQK.GQK_DTREF
			AND SR8.%NotDel%
		WHERE 	GYN.GYN_FILIAL = %xFilial:GYN%
			AND GYN.GYN_DTINI >= %Exp:MV_PAR01%
			AND GYN.GYN_DTFIM <= %Exp:MV_PAR02%
			AND GYN.%NotDel%
			%Exp:cQryGYG%
		ORDER BY GYN_FILIAL, GYG_CODIGO, GYN_CODIGO, GQF.GQF_SEQ,GQF.GQF_ITEM,GQF.GQF_REVISA
    EndSql
 
Return cAliasSec1
