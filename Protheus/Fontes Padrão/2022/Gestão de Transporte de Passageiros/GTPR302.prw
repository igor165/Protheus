#Include 'Protheus.ch'
#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#Include 'GTPR302.ch'

Static oGR302Table
Static aGR302Totais

Function GTPR302()
Local oReport
Local cPerg  := 'GTPR302'
	
Pergunte(cPerg, .T.)
	
oReport := ReportDef()
oReport:PrintDialog()

Return

Static Function ReportDef()

Local oReport

Local bPrint	:= {|oRpt|	ReportPrint(oRpt)}

oReport := TReport():New('GTPR302', STR0005, , bPrint, STR0006, .F.)//"Relatório de Escala Programada x Escala Realizada" //"Gera Relatório"                                                                                                                                                                                                                                                                                                                                                                                                                                                                 

SetSections(oReport)
Return oReport

Static Function SetSections(oReport)

Local oSecDivisao
Local oSecAgenda
Local oSecTotal

Local aSecDivisao	:= GR302CellCollect("SEC_DIVISAO")	//DIVISÃO PLANJEADO X REALIZADO
Local aSecAgenda	:= GR302CellCollect("SEC_AGENDA")	//SEÇÃO 2: DADOS DO AGENDA
Local aSecTotal		:= GR302CellCollect("SEC_TOTAL")	//SEÇÃO 3: TOTAL
 
Local nX		:= 0

//Definição das Seções do Relatório - instanciando os objetos - Início

oSecDivisao 	:= TRSection():New(oReport, "SEC_DIVISAO", {'GYG'})		//SEÇÃO 1
oSecDivisao:SetLeftMargin(27)

oSecAgenda 	:= TRSection():New(oSecDivisao, "SEC_AGENDA", {'GYE','GYO','GYP','GQE','G55','GYN','GYG'})	//SEÇÃO 2
oSecAgenda:SetLeftMargin(3) 

oSecTotal	:= TRSection():New(oSecAgenda, "SEC_TOTAL", {'GYE','GYO','GYP','GQE'})	//SEÇÃO 3
oSecTotal:SetLeftMargin(6) 
//Definição das Seções do Relatório - instanciando os objetos - Fim

//Definição das Células das seções - início

//Células da Seção 1 - Início
For nX := 1 To len(aSecDivisao)

	TRCell():New(oSecDivisao, aSecDivisao[nX,1], aSecDivisao[nX,2], aSecDivisao[nX,3], aSecDivisao[nX,4],; 
					aSecDivisao[nX,5],,,aSecDivisao[nX,6])
					
Next nX
//Células da Seção 1 - Fim

//Células da Seção 2 - Início
For nX := 1 To len(aSecAgenda)

	TRCell():New(oSecAgenda, aSecAgenda[nX,1], aSecAgenda[nX,2], aSecAgenda[nX,3], aSecAgenda[nX,4],; 
					aSecAgenda[nX,5],,,aSecAgenda[nX,6])
					
Next nX

//Células da Seção 2 - Fim

//Células da Seção 3 - Início
For nX := 1 To len(aSecTotal)

	TRCell():New(oSecTotal, aSecTotal[nX,1], aSecTotal[nX,2], aSecTotal[nX,3], aSecTotal[nX,4],; 
					aSecTotal[nX,5],,,aSecTotal[nX,6])
					
Next nX
//Células da Seção 3 - Fim

//Definição das Células das seções - fim

Return()

Static Function GR302CellCollect(cSection)

Local nTamCellPlan	:= 0
Local nTamCellReal	:= 0

Local aRet		:= {}

Do Case
Case ( cSection == "SEC_DIVISAO" )	// SEÇÃO 1: Planejado ou Realizado
	
	//Nome da Célula, Alias da Tabela, Nome da Coluna, Picture, Tamanho
	
	nTamCellPlan := Len("Planejado") 
	nTamCellPlan += (GetSx3Cache("GYE_DTREF","X3_TAMANHO")*2) 
	nTamCellPlan += GetSx3Cache("GYP_HRINIT","X3_TAMANHO") 
	nTamCellPlan += GetSx3Cache("GYP_HRFIMT","X3_TAMANHO")
	
	nTamCellReal := Len("Realizado")	
	nTamCellReal += (GetSx3Cache("GQE_DTREF","X3_TAMANHO")*2) 
	nTamCellReal += GetSx3Cache("GQE_HRINTR","X3_TAMANHO") 
	nTamCellReal += GetSx3Cache("GQE_HRFNTR","X3_TAMANHO")
	
	aRet := {	{"FAKE_CEL2","GYG",Space(Len(GetSx3Cache("GYG_NOME","X3_TITULO"))),"",GetSx3Cache("GYG_NOME","X3_TAMANHO"),"CENTER"},; 	
				{"PLANEJADO","GYG","Planejado","",nTamCellPlan,"CENTER"},;									
				{"REALIZADO","GYG","Realizado","",nTamCellReal,"CENTER"}}
					
Case ( cSection == "SEC_AGENDA" )	//SEÇÃO 2: DADOS DA AGENDA PLANEJADA E REALIZADA
	
	aRet := { 	{"PL_COLAB","GYE",GetSx3Cache("GYG_CODIGO","X3_TITULO"),"",GetSx3Cache("GYG_CODIGO","X3_TAMANHO"),"LEFT"},;									
				{"PL_NCOLAB","GYP",GetSx3Cache("GYG_NOME","X3_TITULO"),"",GetSx3Cache("GYG_NOME","X3_TAMANHO"),"LEFT"},;
				{"PL_DTINI","GYP","Dt. Início","",12,"LEFT"},;
				{"PL_HRINI","GYP",GetSx3Cache("GYP_HRINIT","X3_TITULO"),GetSx3Cache("GYP_HRINIT","X3_PICTURE"),GetSx3Cache("GYP_HRINIT","X3_TAMANHO"),"LEFT"},;
				{"PL_DTFIM","GYP","Dt. Fim","",12,"LEFT"},;
				{"PL_HRFIM","GYP",GetSx3Cache("GYP_HRFIMT","X3_TITULO"),GetSx3Cache("GYP_HRFIMT","X3_PICTURE"),GetSx3Cache("GYP_HRFIMT","X3_TAMANHO"),"LEFT"},;
				{"RL_DTINI","GQE","Dt. Início","",12,"LEFT"},;
				{"RL_HRINI","GQE",GetSx3Cache("GQE_HRINTR","X3_TITULO"),GetSx3Cache("GQE_HRINTR","X3_PICTURE"),GetSx3Cache("GQE_HRINTR","X3_TAMANHO"),"LEFT"},;
				{"RL_DTFIM","GQE","Dt. Fim","",12,"LEFT"},;
				{"RL_HRFIM","GQE",GetSx3Cache("GQE_HRFNTR","X3_TITULO"),GetSx3Cache("GQE_HRFNTR","X3_PICTURE"),GetSx3Cache("GQE_HRFNTR","X3_TAMANHO"),"LEFT"},;
				{"MOTIVO","GQE","Motivo","",40,"LEFT"}}
	
Case ( cSection == "SEC_TOTAL" )	//SEÇÃO 3: Totais
	
	aRet := { 	{"TOTAL_ATRASO","GYE","Total Atrasos","@E 9,999",5,"RIGHT"},;									
				{"TOTAL_EXTRA","GYP","Total de Extras","@E 9,999",5,"RIGHT"},;
				{"TOTAL_FALTA","GYP","Total de Faltas","@E 9,999",5,"RIGHT"}}
	
EndCase

Return(aRet)

Static Function ReportPrint(oReport)

Local dData			:= SToD("")

Local oSecDivisao	:= oReport:Section(1)						//SEÇÃO 1: DADOS DO COLABORADOR
Local oSecAgenda	:= oReport:Section(1):Section(1)			//SEÇÃO 2: DADOS DO AGENDA
Local oSecTotal		:= oReport:Section(1):Section(1):Section(1)	//SEÇÃO 3: TOTAL

Local lPrintDiv 	:= .f.

GR302SetTotals()
GR302SetQry()
(oGR302Table:GetAlias())->(dbGotop())

If((oGR302Table:GetAlias())->(!eof()))

	While ( (oGR302Table:GetAlias())->(!Eof()) )

		oReport:StartPage()
		
		If ( !lPrintDiv )
		
			oSecDivisao:Init()
			oSecDivisao:PrintLine()
			oSecDivisao:Finish()
			
			oReport:ThinLine()
			
			lPrintDiv := .t.
			
			oSecAgenda:Init()
			
		EndIf
		
		GR302PutValues(oGR302Table:GetAlias(), oSecAgenda, "SEC_AGENDA")
		
		dData := (oGR302Table:GetAlias())->PL_DTINI
		
		(oGR302Table:GetAlias())->(DbSkip())
		
		//Quebra do dia, apresentação dos totais de Horas no Volante e Fora do Volante
		If ( dData <> (oGR302Table:GetAlias())->PL_DTINI )
			
			oSecAgenda:Finish()
			oSecAgenda:Init()
			
			oSecTotal:Init()
			
			oSecTotal:Cell("TOTAL_ATRASO"):SetValue(GR302GetTotals("ATRASO"))
			oSecTotal:Cell("TOTAL_EXTRA"):SetValue(GR302GetTotals("EXTRA"))
			oSecTotal:Cell("TOTAL_FALTA"):SetValue(GR302GetTotals("AGENDA NÃO REALIZADA"))
			
			oSecTotal:PrintLine()
			oSecTotal:Finish()
			
			oSecAgenda:Finish()
			lPrintDiv := .f.
			GR302SetTotals()
			
		EndIf
		
	End While

	oSecAgenda:Finish()
Else
	FwAlertWarning(STR0003,STR0004)
EndIf
GR302Destroy()
Return()

Function GR302SetQry(dDataDe,dDataAte,cSetorDe,cSetorAte,cGrupoDe,cGrupoAte)

Local cQuery	:= ""

Default dDataDe		:= mv_par01
Default dDataAte	:= mv_par02
Default cSetorDe	:= mv_par03
Default cSetorAte	:= mv_par04
Default cGrupoDe	:= mv_par05
Default cGrupoAte	:= mv_par06

cQuery := "SELECT " + Chr(13)
cQuery += "	*, " + Chr(13)
cQuery += "	'(oGR302Table:GetAlias())->(GR302Motivo())' MOTIVO " + Chr(13)
cQuery += "FROM " + Chr(13)
cQuery += "( " + Chr(13)
cQuery += "	SELECT " + Chr(13)
cQuery += "		DISTINCT " + Chr(13) 
cQuery += "		'PLANEJADO' PL_PERFIL , " + Chr(13)
cQuery += "		GYG_CODIGO	PL_COLAB, " + Chr(13) 
cQuery += "		GYG_NOME	PL_NCOLAB, " + Chr(13) 
cQuery += "		SUBSTRING(GYE_DTREF,7,2) + '/' + SUBSTRING(GYE_DTREF,5,2) + '/' + SUBSTRING(GYE_DTREF,1,4) PL_DTINI, " + Chr(13)
cQuery += "		( " + Chr(13)
cQuery += "			CASE  " + Chr(13)
cQuery += "				WHEN GYP_HRFIMT > GYP_HRINIT THEN SUBSTRING(GYE_DTREF,7,2) + '/' + SUBSTRING(GYE_DTREF,5,2) + '/' + SUBSTRING(GYE_DTREF,1,4) " + Chr(13)
cQuery += "				ELSE RIGHT(REPLICATE('0',1) + CAST((CAST(SUBSTRING(GYE_DTREF,7,2) AS int) + 1 ) AS varchar(2)),2) + '/' + SUBSTRING(GYE_DTREF,5,2) + '/' + SUBSTRING(GYE_DTREF,1,4) " + Chr(13)
cQuery += "			END " + Chr(13)
cQuery += "		) PL_DTFIM, " + Chr(13)
cQuery += "		GYP_ESCALA	PL_ESCALA,  " + Chr(13)
cQuery += "		GYP_CODGID	PL_HORARIO,  " + Chr(13)
cQuery += "		GYP_SEQ		PL_SEQ,  " + Chr(13)
cQuery += "		GYP_LINCOD	PL_LINHA,  " + Chr(13)
cQuery += "		GYP_HRINIT	PL_HRINI,  " + Chr(13)
cQuery += "		GYP_HRFIMT	PL_HRFIM " + Chr(13)
cQuery += "	FROM  " + Chr(13)
cQuery += "		" + RetSQLName("GYE") + " GYE  " + Chr(13)
cQuery += "	INNER JOIN  " + Chr(13)
cQuery += "		" + RetSQLName("GYP") + " GYP  " + Chr(13)
cQuery += "	ON  " + Chr(13)
cQuery += "		GYP_FILIAL = '" + xFilial("GYP") + "' " + Chr(13) 
cQuery += "		AND GYP_ESCALA = GYE_ESCALA  " + Chr(13)
cQuery += "		AND GYP.D_E_L_E_T_ = ' '  " + Chr(13)
cQuery += "	INNER JOIN  " + Chr(13)
cQuery += "		" + RetSQLName("GYO") + " GYO  " + Chr(13)
cQuery += "	ON  " + Chr(13)
cQuery += "		GYO_FILIAL = GYP_FILIAL " + Chr(13) 
cQuery += "		AND GYO_CODIGO = GYP_ESCALA  " + Chr(13)
cQuery += "		AND GYO.D_E_L_E_T_ = ' '  " + Chr(13)
cQuery += "	INNER JOIN  " + Chr(13)
cQuery += "		" + RetSQLName("GYG") + " GYG  " + Chr(13)
cQuery += "	ON  " + Chr(13)
cQuery += "		GYG_FILIAL = '" + xFilial("GYG") + "' " + Chr(13) 
cQuery += "		AND GYG_CODIGO = GYE_COLCOD  " + Chr(13)
cQuery += "		AND GYG.D_E_L_E_T_ = ' '  " + Chr(13)
cQuery += "	WHERE  " + Chr(13)
cQuery += "		GYE_FILIAL = '" + xFilial("GYE") + "' " + Chr(13) 
cQuery += "		AND GYE_DTREF BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "' " + Chr(13) 
cQuery += "		AND GYE_ESCALA <> ''  " + Chr(13)

IF !(Empty(cGrupoDe) .Or. Empty(cGrupoAte))

	cQuery += "	AND EXISTS ( " + Chr(13) 
	cQuery += "				SELECT 1 " + Chr(13)
	cQuery += "				FROM " + Chr(13) 
	cQuery += "					" + RetSQLName("GZA") +" GZA "+ Chr(13)
	cQuery += "				INNER JOIN " + Chr(13) 
	cQuery += "					" + RetSQLName("GYI") + " GYI " + Chr(13)
	cQuery += "				ON  " + Chr(13)
	cQuery += "					GYI.GYI_FILIAL = '"+ xFilial("GYI") + "' " 	+ Chr(13)
	cQuery += "					AND GYI.GYI_GRPCOD = GZA.GZA_CODIGO " + Chr(13)
	cQuery += "					AND GYI.GYI_COLCOD = GYG.GYG_CODIGO " + Chr(13)
	cQuery += "					AND GYI.D_E_L_E_T_ = ' ' " + Chr(13)
	cQuery += "				WHERE " + Chr(13) 
	cQuery += "					GZA.GZA_FILIAL = '" + xFilial("GZA") + "' "  + Chr(13)
	cQuery += "					AND GZA.GZA_CODIGO >= '" + cGrupoDe + "' " + Chr(13)
	cQuery += "					AND GZA.GZA_CODIGO <= '" + cGrupoAte + "' " + Chr(13)
	
	IF !(Empty(cSetorDe) .Or. Empty(cSetorAte))
	
		cQuery += "					AND GZA.GZA_SETOR >= '" + cSetorDe + "' " + Chr(13)
		cQuery += "					AND GZA.GZA_SETOR <= '" + cSetorAte + "' " + Chr(13)
		
	EndIF
	
	cQuery += "					AND GZA.D_E_L_E_T_=' ' " + Chr(13)
	cQuery += "			) 	" + Chr(13)
	
//SETOR
ElseIF !(Empty(cSetorDe) .Or. Empty(cSetorAte))

	cQuery += "	AND EXISTS ( " + Chr(13) 
	cQuery += "				SELECT 1 " + Chr(13)				
	cQuery += "				FROM " + Chr(13) 
	cQuery += "					" + RetSQLName("GYT") +" GYT " + Chr(13)
	cQuery += "				INNER JOIN " + Chr(13) 
	cQuery += "					" + RetSQLName("GY2") +" GY2 " + Chr(13)
	cQuery += "				ON 	" + Chr(13)	
	cQuery += "					GY2.GY2_FILIAL = '" + xFilial("GY2") + "' " + Chr(13)		
	cQuery += "					AND GY2.GY2_SETOR = GYT.GYT_CODIGO	" + Chr(13)
	cQuery += "					AND GY2.GY2_CODCOL = GYG.GYG_CODIGO " + Chr(13)	
	cQuery += "					AND GY2.D_E_L_E_T_ = ' '	" + Chr(13)
	cQuery += "				WHERE " + Chr(13) 
	cQuery += "					GYT.GYT_FILIAL = '" + xFilial("GYT") + "' " + Chr(13)
	cQuery += "					AND GYT.GYT_CODIGO >='" + cSetorDe + "' " + Chr(13)
	cQuery += "					AND GYT.GYT_CODIGO <='" + cSetorAte + "' " + Chr(13)
	cQuery += "					AND GYT.D_E_L_E_T_ = ' ' " + Chr(13)
	cQuery += "				) "	 + Chr(13)
	
EndIf

cQuery += "	AND GYE.D_E_L_E_T_ = ' '  " + Chr(13)
cQuery += ") PLANEJADO " + Chr(13)
cQuery += "LEFT JOIN " + Chr(13)
cQuery += "( " + Chr(13)
cQuery += "	SELECT " + Chr(13)
cQuery += "		DISTINCT " + Chr(13) 
cQuery += "		'REALIZADO' RL_PERFIL , " + Chr(13)
cQuery += "		GYG_CODIGO	RL_COLAB, " + Chr(13) 
cQuery += "		GYG_NOME	RL_NCOLAB, " + Chr(13) 
cQuery += "		SUBSTRING(GQE_DTREF,7,2) + '/' + SUBSTRING(GQE_DTREF,5,2) + '/' + SUBSTRING(GQE_DTREF,1,4) RL_DTINI, " + Chr(13)
cQuery += "		( " + Chr(13)
cQuery += "			CASE " + Chr(13) 
cQuery += "				WHEN GQE_HRFNTR > GQE_HRINTR THEN SUBSTRING(GQE_DTREF,7,2) + '/' + SUBSTRING(GQE_DTREF,5,2) + '/' + SUBSTRING(GQE_DTREF,1,4) " + Chr(13)
cQuery += "				ELSE RIGHT(REPLICATE('0',1) + CAST((CAST(SUBSTRING(GQE_DTREF,7,2) AS int) + 1 ) AS varchar(2)),2) + '/' + SUBSTRING(GQE_DTREF,5,2) + '/' + SUBSTRING(GQE_DTREF,1,4) " + Chr(13)
cQuery += "			END " + Chr(13)
cQuery += "		) RL_DTFIM, " + Chr(13)
cQuery += "		GQE_ESCALA	RL_ESCALA, " + Chr(13) 
cQuery += "		G55_CODGID	RL_HORARIO, " + Chr(13) 
cQuery += "		G55_SEQ		RL_SEQ,  " + Chr(13)
cQuery += "		GYN_LINCOD	RL_LINHA, " + Chr(13) 
cQuery += "		GQE_HRINTR	RL_HRINI, " + Chr(13) 
cQuery += "		GQE_HRFNTR	RL_HRFIM " + Chr(13)
cQuery += "	FROM " + Chr(13) 
cQuery += "		" + RetSQLName("GQE") + " GQE " + Chr(13) 
cQuery += "	INNER JOIN " + Chr(13) 
cQuery += "		" + RetSQLName("G55") + " G55 " + Chr(13) 
cQuery += "	ON " + Chr(13) 
cQuery += "		G55_FILIAL = GQE_FILIAL " + Chr(13)
cQuery += "		AND G55_CODVIA = GQE_VIACOD " + Chr(13)
cQuery += "		AND G55_SEQ = GQE_SEQ " + Chr(13)
cQuery += "		AND G55.D_E_L_E_T_ = ' ' " + Chr(13) 
cQuery += "	INNER JOIN " + Chr(13) 
cQuery += "		" + RetSQLName("GYN") + " GYN " + Chr(13) 
cQuery += "	ON " + Chr(13) 
cQuery += "		GYN_FILIAL = G55_FILIAL " + Chr(13) 
cQuery += "		AND GYN_CODIGO = G55_CODVIA " + Chr(13) 
cQuery += "		AND GYN_CODGID = G55_CODGID " + Chr(13)
cQuery += "		AND GYN.D_E_L_E_T_ = ' ' " + Chr(13) 
cQuery += "	INNER JOIN " + Chr(13) 
cQuery += "		" + RetSQLName("GYG") + " GYG " + Chr(13) 
cQuery += "	ON " + Chr(13) 
cQuery += "		GYG_FILIAL = '" + xFilial("GYG") + "' " + Chr(13) 
cQuery += "		AND GYG_CODIGO = GQE_RECURS " + Chr(13) 
cQuery += "		AND GYG.D_E_L_E_T_ = ' ' " + Chr(13) 
cQuery += "	WHERE " + Chr(13) 
cQuery += "		GQE_FILIAL = '" + xFilial("GQE") + "' " + Chr(13) 
cQuery += "		AND GQE_DTREF BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "' " + Chr(13) 
cQuery += "		AND GQE_CONF = '1' " + Chr(13) 
cQuery += "		AND GQE_TRECUR = '1' " + Chr(13)
cQuery += "		AND GQE_TERC IN (' ', '2') " + Chr(13)

IF !(Empty(cGrupoDe) .Or. Empty(cGrupoAte))

	cQuery += "	AND EXISTS ( " + Chr(13) 
	cQuery += "				SELECT 1 " + Chr(13)
	cQuery += "				FROM " + Chr(13) 
	cQuery += "					" + RetSQLName("GZA") +" GZA "+ Chr(13)
	cQuery += "				INNER JOIN " + Chr(13) 
	cQuery += "					" + RetSQLName("GYI") + " GYI " + Chr(13)
	cQuery += "				ON  " + Chr(13)
	cQuery += "					GYI.GYI_FILIAL = '"+ xFilial("GYI") + "' " 	+ Chr(13)
	cQuery += "					AND GYI.GYI_GRPCOD = GZA.GZA_CODIGO " + Chr(13)
	cQuery += "					AND GYI.GYI_COLCOD = GYG.GYG_CODIGO " + Chr(13)
	cQuery += "					AND GYI.D_E_L_E_T_ = ' ' " + Chr(13)
	cQuery += "				WHERE " + Chr(13) 
	cQuery += "					GZA.GZA_FILIAL = '" + xFilial("GZA") + "' "  + Chr(13)
	cQuery += "					AND GZA.GZA_CODIGO >= '" + cGrupoDe + "' " + Chr(13)
	cQuery += "					AND GZA.GZA_CODIGO <= '" + cGrupoAte + "' " + Chr(13)
	
	IF !(Empty(cSetorDe) .Or. Empty(cSetorAte))
	
		cQuery += "					AND GZA.GZA_SETOR >= '" + cSetorDe + "' " + Chr(13)
		cQuery += "					AND GZA.GZA_SETOR <= '" + cSetorAte + "' " + Chr(13)
		
	EndIF
	
	cQuery += "					AND GZA.D_E_L_E_T_=' ' " + Chr(13)
	cQuery += "			) 	" + Chr(13)
	
//SETOR
ElseIF !(Empty(cSetorDe) .Or. Empty(cSetorAte))

	cQuery += "	AND EXISTS ( " + Chr(13) 
	cQuery += "				SELECT 1 " + Chr(13)				
	cQuery += "				FROM " + Chr(13) 
	cQuery += "					" + RetSQLName("GYT") +" GYT " + Chr(13)
	cQuery += "				INNER JOIN " + Chr(13) 
	cQuery += "					" + RetSQLName("GY2") +" GY2 " + Chr(13)
	cQuery += "				ON 	" + Chr(13)	
	cQuery += "					GY2.GY2_FILIAL = '" + xFilial("GY2") + "' " + Chr(13)		
	cQuery += "					AND GY2.GY2_SETOR = GYT.GYT_CODIGO	" + Chr(13)
	cQuery += "					AND GY2.GY2_CODCOL = GYG.GYG_CODIGO " + Chr(13)	
	cQuery += "					AND GY2.D_E_L_E_T_ = ' '	" + Chr(13)
	cQuery += "				WHERE " + Chr(13) 
	cQuery += "					GYT.GYT_FILIAL = '" + xFilial("GYT") + "' " + Chr(13)
	cQuery += "					AND GYT.GYT_CODIGO >='" + cSetorDe + "' " + Chr(13)
	cQuery += "					AND GYT.GYT_CODIGO <='" + cSetorAte + "' " + Chr(13)
	cQuery += "					AND GYT.D_E_L_E_T_ = ' ' " + Chr(13)
	cQuery += "				) "	 + Chr(13)
	
EndIf

cQuery += "	AND GQE.D_E_L_E_T_ = ' ' " + Chr(13)

cQuery += "UNION"

cQuery += "	SELECT " + Chr(13)
cQuery += "		DISTINCT " + Chr(13) 
cQuery += "		'REALIZADO' RL_PERFIL , " + Chr(13)
cQuery += "		GYG_CODIGO	RL_COLAB, " + Chr(13) 
cQuery += "		GYG_NOME	RL_NCOLAB, " + Chr(13) 
cQuery += "		SUBSTRING(GQK_DTREF,7,2) + '/' + SUBSTRING(GQK_DTREF,5,2) + '/' + SUBSTRING(GQK_DTREF,1,4) RL_DTINI, " + Chr(13)
cQuery += "		( " + Chr(13)
cQuery += "			CASE " + Chr(13) 
cQuery += "				WHEN GQK_HRFIM > GQK_HRINI THEN SUBSTRING(GQK_DTREF,7,2) + '/' + SUBSTRING(GQK_DTREF,5,2) + '/' + SUBSTRING(GQK_DTREF,1,4) " + Chr(13)
cQuery += "				ELSE RIGHT(REPLICATE('0',1) + CAST((CAST(SUBSTRING(GQK_DTREF,7,2) AS int) + 1 ) AS varchar(2)),2) + '/' + SUBSTRING(GQK_DTREF,5,2) + '/' + SUBSTRING(GQK_DTREF,1,4) " + Chr(13)
cQuery += "			END " + Chr(13)
cQuery += "		) RL_DTFIM, " + Chr(13)
cQuery += "		''			RL_ESCALA, " + Chr(13) 
cQuery += "		G55_CODGID	RL_HORARIO, " + Chr(13) 
cQuery += "		G55_SEQ		RL_SEQ,  " + Chr(13)
cQuery += "		GYN_LINCOD	RL_LINHA, " + Chr(13) 
cQuery += "		GQK_HRINI	RL_HRINI, " + Chr(13) 
cQuery += "		GQK_HRFIM	RL_HRFIM " + Chr(13)
cQuery += "	FROM " + Chr(13) 
cQuery += "		" + RetSQLName("GQK") + " GQK " + Chr(13) 
cQuery += "	INNER JOIN " + Chr(13) 
cQuery += "		" + RetSQLName("G55") + " G55 " + Chr(13) 
cQuery += "	ON " + Chr(13) 
cQuery += "		G55_FILIAL = GQK_FILIAL " + Chr(13)
cQuery += "		AND G55_CODVIA = GQK_CODVIA " + Chr(13)
cQuery += "		AND G55.D_E_L_E_T_ = ' ' " + Chr(13) 
cQuery += "	INNER JOIN " + Chr(13) 
cQuery += "		" + RetSQLName("GYN") + " GYN " + Chr(13) 
cQuery += "	ON " + Chr(13) 
cQuery += "		GYN_FILIAL = G55_FILIAL " + Chr(13) 
cQuery += "		AND GYN_CODIGO = G55_CODVIA " + Chr(13) 
cQuery += "		AND GYN_CODGID = G55_CODGID " + Chr(13)
cQuery += "		AND GYN.D_E_L_E_T_ = ' ' " + Chr(13) 
cQuery += "	INNER JOIN " + Chr(13) 
cQuery += "		" + RetSQLName("GYG") + " GYG " + Chr(13) 
cQuery += "	ON " + Chr(13) 
cQuery += "		GYG_FILIAL = '" + xFilial("GYG") + "' " + Chr(13) 
cQuery += "		AND GYG_CODIGO = GQK_RECURS " + Chr(13) 
cQuery += "		AND GYG.D_E_L_E_T_ = ' ' " + Chr(13) 
cQuery += "	WHERE " + Chr(13) 
cQuery += "		GQK_FILIAL = '" + xFilial("GQK") + "' " + Chr(13) 
cQuery += "		AND GQK_DTREF BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "' " + Chr(13) 
cQuery += "		AND GQK_CONF = '1' " + Chr(13) 
cQuery += "		AND GQK_TRECUR = '1' " + Chr(13)
cQuery += "		AND GQK_TERC IN (' ', '2') " + Chr(13)

IF !(Empty(cGrupoDe) .Or. Empty(cGrupoAte))

	cQuery += "	AND EXISTS ( " + Chr(13) 
	cQuery += "				SELECT 1 " + Chr(13)
	cQuery += "				FROM " + Chr(13) 
	cQuery += "					" + RetSQLName("GZA") +" GZA "+ Chr(13)
	cQuery += "				INNER JOIN " + Chr(13) 
	cQuery += "					" + RetSQLName("GYI") + " GYI " + Chr(13)
	cQuery += "				ON  " + Chr(13)
	cQuery += "					GYI.GYI_FILIAL = '"+ xFilial("GYI") + "' " 	+ Chr(13)
	cQuery += "					AND GYI.GYI_GRPCOD = GZA.GZA_CODIGO " + Chr(13)
	cQuery += "					AND GYI.GYI_COLCOD = GYG.GYG_CODIGO " + Chr(13)
	cQuery += "					AND GYI.D_E_L_E_T_ = ' ' " + Chr(13)
	cQuery += "				WHERE " + Chr(13) 
	cQuery += "					GZA.GZA_FILIAL = '" + xFilial("GZA") + "' "  + Chr(13)
	cQuery += "					AND GZA.GZA_CODIGO >= '" + cGrupoDe + "' " + Chr(13)
	cQuery += "					AND GZA.GZA_CODIGO <= '" + cGrupoAte + "' " + Chr(13)
	
	IF !(Empty(cSetorDe) .Or. Empty(cSetorAte))
	
		cQuery += "					AND GZA.GZA_SETOR >= '" + cSetorDe + "' " + Chr(13)
		cQuery += "					AND GZA.GZA_SETOR <= '" + cSetorAte + "' " + Chr(13)
		
	EndIF
	
	cQuery += "					AND GZA.D_E_L_E_T_=' ' " + Chr(13)
	cQuery += "			) 	" + Chr(13)
	
//SETOR
ElseIF !(Empty(cSetorDe) .Or. Empty(cSetorAte))

	cQuery += "	AND EXISTS ( " + Chr(13) 
	cQuery += "				SELECT 1 " + Chr(13)				
	cQuery += "				FROM " + Chr(13) 
	cQuery += "					" + RetSQLName("GYT") +" GYT " + Chr(13)
	cQuery += "				INNER JOIN " + Chr(13) 
	cQuery += "					" + RetSQLName("GY2") +" GY2 " + Chr(13)
	cQuery += "				ON 	" + Chr(13)	
	cQuery += "					GY2.GY2_FILIAL = '" + xFilial("GY2") + "' " + Chr(13)		
	cQuery += "					AND GY2.GY2_SETOR = GYT.GYT_CODIGO	" + Chr(13)
	cQuery += "					AND GY2.GY2_CODCOL = GYG.GYG_CODIGO " + Chr(13)	
	cQuery += "					AND GY2.D_E_L_E_T_ = ' '	" + Chr(13)
	cQuery += "				WHERE " + Chr(13) 
	cQuery += "					GYT.GYT_FILIAL = '" + xFilial("GYT") + "' " + Chr(13)
	cQuery += "					AND GYT.GYT_CODIGO >='" + cSetorDe + "' " + Chr(13)
	cQuery += "					AND GYT.GYT_CODIGO <='" + cSetorAte + "' " + Chr(13)
	cQuery += "					AND GYT.D_E_L_E_T_ = ' ' " + Chr(13)
	cQuery += "				) "	 + Chr(13)
	
EndIf

cQuery += "	AND GQK.D_E_L_E_T_ = ' ' " + Chr(13)

cQuery += ") REALIZADO " + Chr(13)
cQuery += "ON " + Chr(13)
cQuery += "	PLANEJADO.PL_COLAB = REALIZADO.RL_COLAB " + Chr(13)
cQuery += "	AND PLANEJADO.PL_DTINI = REALIZADO.RL_DTINI " + Chr(13)
cQuery += "	AND (PLANEJADO.PL_HORARIO = REALIZADO.RL_HORARIO or ' ' = REALIZADO.RL_HORARIO )" + Chr(13)
cQuery += "	AND PLANEJADO.PL_SEQ = REALIZADO.RL_SEQ " + Chr(13)
cQuery += "ORDER BY " + Chr(13)
cQuery += "	PLANEJADO.PL_COLAB, " + Chr(13)
cQuery += "	PLANEJADO.PL_DTINI, " + Chr(13)
cQuery += "	PLANEJADO.PL_HRINI " + Chr(13)

GTPTemporaryTable(cQuery,GetNextAlias(),,,@oGR302Table)	//,{{"IDX",{"GYE_DTREF","GYP_ESCALA","GYP_ITEM"}}},{{"DT_REFER","D",8}}) oGR302Table := GTPTemporaryTable(cQuery,GetNextAlias())//,{{"IDX",{"GYE_DTREF","GYP_ESCALA","GYP_ITEM"}}},{{"DT_REFER","D",8}})

Return()

Function GR302Destroy()

// If ( ValType(oGR302Table) == "O" )
// 	oGR302Table:Delete()
// EndIf

aGR302Totais := Nil

Return()

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TR50PutValues
Função que atualiza o conteúdo das células de uma determinada seção.

@type 		Function
@author 	Fernando Radu Muscalu
@since 		29/02/2016
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function GR302PutValues(cAlias, xSection, cSecCell)

Local nI := 0
Local nX := 0
Local nP := 0

Local cConteudo	:= ""

Local aCells 	:= GR302CellCollect(cSecCell)

If ( Valtype(xSection) == "O" )
	
	For nI := 1 to Len(aCells)
		
		If ( ValType((cAlias)->&(aCells[nI,1])) == "C" )
		
			nP := RAt(")",(cAlias)->&(aCells[nI,1]))
			
			If ( nP > 0 )
			
				cConteudo := SubStr((cAlias)->&(aCells[nI,1]),1,nP)
				cConteudo := &(cConteudo)
				
			Else
				cConteudo := (cAlias)->&(aCells[nI,1])	
			Endif
		
		Else
			cConteudo := (cAlias)->&(aCells[nI,1])
		Endif
		
		xSection:Cell(aCells[nI,1]):SetValue(cConteudo)
		
	Next nI
	
	xSection:PrintLine()
	
Else
	
	For nX := 1 to Len(xSection)		
		
		For nI := 1 to Len(aCells[nX])
			
			If ( "LBL_" $ aCells[nX][nI,1] )
				cConteudo := GTPLabelCo(aCells[nX][nI,1])
			Else
				
				If ( ValType((cAlias)->&(aCells[nX][nI,1])) == "C" )
				
					nP := At(")",(cAlias)->&(aCells[nX][nI,1]) )
			
					If ( nP > 0 )
					
						cConteudo := SubStr((cAlias)->&(aCells[nX][nI,1]),1,nP)
						
						If ( FindFunction(cConteudo) )
							cConteudo := &(cConteudo)
						Endif
					
					Else
						cConteudo := (cAlias)->&(aCells[nX][nI,1])
					Endif
				
				Else
					cConteudo := (cAlias)->&(aCells[nX][nI,1])
				Endif
				
			Endif
			
			xSection[nX]:Cell(aCells[nX][nI,1]):SetValue(cConteudo)

		Next nI
		
		xSection[nX]:PrintLine()
			
	Next nX
	
Endif

Return()

Function GR302Motivo()

Local cMotivo		:= ""
Local cTotalHrsPlan := ""
Local cTotalHrsReal := ""
	
Do Case

	Case ( Empty(RL_PERFIL) )
		cMotivo := "AGENDA NÃO REALIZADA"
	Case ( RL_HRINI > PL_HRINI .and. RL_HRFIM <= PL_HRFIM )
		cMotivo := "ATRASO"	
	Case ( RL_HRFIM > PL_HRFIM .and. RL_HRINI <= PL_HRINI )
		cMotivo := "EXTRA"
	Case ( RL_HRFIM <> PL_HRFIM .and. RL_HRINI <> PL_HRINI )
		
		cTotalHrsPlan := GTDeltaTime(, Val(GTFormatHour(PL_HRINI,"99.99")), , Val(GTFormatHour(PL_HRFIM,"99.99")))
		cTotalHrsReal := GTDeltaTime(, Val(GTFormatHour(RL_HRINI,"99.99")), , Val(GTFormatHour(RL_HRFIM,"99.99")))	
		
		If ( Val(cTotalHrsReal) > Val(cTotalHrsPlan) )
			cMotivo := "EXTRA"
		ElseIf ( Val(cTotalHrsReal) < Val(cTotalHrsPlan) )
			cMotivo := "ATRASO"
		EndIf		
		
	Otherwise
		cMotivo := ""
End Case

If ( !Empty(cMotivo) )
	GR302SumTotal(cMotivo,1)
EndIf

Return(cMotivo)

Function GR302SetTotals()

aGR302Totais := {}

aAdd(aGR302Totais,{"ATRASO",0})
aAdd(aGR302Totais,{"EXTRA",0})
aAdd(aGR302Totais,{"AGENDA NÃO REALIZADA",0}) 

Return()

Function GR302SumTotal(cTotal,nSum)

Local nP	:= 0

nP := aScan(aGR302Totals,{|x| x[1] == Upper(alltrim(cTotal) )})

If ( nP > 0 )
	aGR302Totals[nP,2] += nSum
EndIf

Return()

Function GR302GetTotals(cTotal)

Local xRet	
Default cTotal := ""

If ( Empty(cTotal) ) 
	xRet := aClone(aGR302Totais)
Else

	nP := aScan(aGR302Totais,{|x| x[1] == Upper(alltrim(cTotal) )})
	
	If ( nP > 0 )
		xRet := aGR302Totals[nP,2]
	EndIf

EndIf

Return(xRet)
