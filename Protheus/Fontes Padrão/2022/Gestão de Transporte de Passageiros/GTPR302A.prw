#Include 'Protheus.ch'
#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#Include 'GTPR302A.ch'
Static oGR302ATable

Function GTPR302A()
Local oReport
Local cPerg  := 'GTPR302'

If FwIsInCallStack('GTPA303')
	Pergunte(cPerg, .T.)
	
	oReport := ReportDef()
	oReport:PrintDialog()
Else	
	FwAlertHelp('Não é mais possivel gerar o relatório por essa opção','Para gerar o relatório, vá na Alocação de Colaborador e realize a impressão da alocação desejada')
EndIf

Return()

Static Function ReportDef()

Local oReport

Local bPrint	:= {|oRpt|	ReportPrint(oRpt)}

oReport := TReport():New('GTPR302A', STR0005, , bPrint, STR0006, .F. /*lLandscape*/, /*uTotalText*/, /*lTotalInLine*/, /*cPageTText*/, /*lPageTInLine*/, /*lTPageBreak*/, /*nColSpace*/)//"Relatório de Agenda Programada" "Gera Relatório"

SetSections(oReport)

Return oReport


Static Function SetSections(oReport)

Local oSecColab
Local oSecAgenda
Local oSecTotal

Local aSecColab		:= GR302ACellCollect("SEC_COLAB")	//SEÇÃO 1: DADOS DO COLABORADOR
Local aSecAgenda	:= GR302ACellCollect("SEC_AGENDA")	//SEÇÃO 2: DADOS DO AGENDA
Local aSecTotal		:= GR302ACellCollect("SEC_TOTAL")	//SEÇÃO 3: TOTAL

Local nX	:= 0

//Definição das Seções do Relatório - instanciando os objetos - Início

oSecColab 	:= TRSection():New(oReport, "SEC_COLAB", {'GYG'})		//SEÇÃO 1

oSecAgenda 	:= TRSection():New(oSecColab, "SEC_AGENDA", {'GYE','GYO','GYP'})	//SEÇÃO 2
oSecAgenda:SetLeftMargin(3) 

oSecTotal	:= TRSection():New(oSecAgenda, "SEC_TOTAL", {'GYE','GYO','GYP'})	//SEÇÃO 3
oSecTotal:SetLeftMargin(3) 
//Definição das Seções do Relatório - instanciando os objetos - Fim

//Definição das Células das seções - início

//Células da Seção 1 - Início
For nX := 1 To len(aSecColab)

	TRCell():New(oSecColab, aSecColab[nX,1], aSecColab[nX,2], aSecColab[nX,3], aSecColab[nX,4],; 
					aSecColab[nX,5],,,aSecColab[nX,6])
					
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

Static Function GR302ACellCollect(cSection)

Local aRet		:= {}

Do Case
Case ( cSection == "SEC_COLAB" )	// SEÇÃO 1: DADOS DA FILIAL
	
	//Nome da Célula, Alias da Tabela, Nome da Coluna, Picture, Tamanho
	
	aRet := { 	{"GYG_CODIGO","GYG",GetSx3Cache("GYG_CODIGO","X3_TITULO"),"",GetSx3Cache("GYG_CODIGO","X3_TAMANHO"),"LEFT"},;									
				{"GYG_NOME","GYG",GetSx3Cache("GYG_NOME","X3_TITULO"),"",GetSx3Cache("GYG_NOME","X3_TAMANHO"),"LEFT"},;
				{"GYQ_DTINI","GYQ","Data De ","",GetSx3Cache("GYE_DTREF","X3_TAMANHO")+10,"LEFT"},;
				{"GYQ_DTINI","GYQ","Data Até ","",GetSx3Cache("GYE_DTREF","X3_TAMANHO")+10,"LEFT"},;
				{"GYQ_CODIGO","GYQ","Cód Alocação","",GetSx3Cache("GYQ_CODIGO","X3_TAMANHO")+15,"LEFT"};
			}
					
Case ( cSection == "SEC_AGENDA" )	//SEÇÃO 2: DADOS DO FORNECEDOR
	
	aRet := { 	{"GYE_DTREF","GYE",GetSx3Cache("GYE_DTREF","X3_TITULO"),"",GetSx3Cache("GYE_DTREF","X3_TAMANHO")+8,"LEFT"},;									
				{"GYP_ESCALA","GYP",GetSx3Cache("GYP_ESCALA","X3_TITULO"),"",GetSx3Cache("GYP_ESCALA","X3_TAMANHO"),"LEFT"},;
				{"GID_NUMSRV","GID",GetSx3Cache("GID_NUMSRV","X3_TITULO"),"",GetSx3Cache("GID_NUMSRV","X3_TAMANHO"),"LEFT"},;
				{"GYP_SRVORI","GYP",GetSx3Cache("GYP_SRVORI","X3_TITULO"),"",GetSx3Cache("GYP_SRVORI","X3_TAMANHO")+35,"LEFT"},;
				{"GYP_SRVDES","GYP",GetSx3Cache("GYP_SRVDES","X3_TITULO"),"",GetSx3Cache("GYP_SRVDES","X3_TAMANHO")+35,"LEFT"},;
				{"GYP_HRINIT","GYP",GetSx3Cache("GYP_HRINIT","X3_TITULO"),GetSx3Cache("GYP_HRINIT","X3_PICTURE"),GetSx3Cache("GYP_HRINIT","X3_TAMANHO"),"LEFT"},;
				{"GYP_HORORI","GYP",GetSx3Cache("GYP_HORORI","X3_TITULO"),GetSx3Cache("GYP_HORORI","X3_PICTURE"),GetSx3Cache("GYP_HORORI","X3_TAMANHO"),"LEFT"},;
				{"GYP_HORDES","GYP",GetSx3Cache("GYP_HORDES","X3_TITULO"),GetSx3Cache("GYP_HORDES","X3_PICTURE"),GetSx3Cache("GYP_HORDES","X3_TAMANHO"),"LEFT"},;
				{"GYP_HRFIMT","GYP",GetSx3Cache("GYP_HRFIMT","X3_TITULO"),GetSx3Cache("GYP_HRFIMT","X3_PICTURE"),GetSx3Cache("GYP_HRFIMT","X3_TAMANHO"),"LEFT"},;
				{"GYO_HRVOL","GYO",GetSx3Cache("GYO_HRVOL","X3_TITULO"),GetSx3Cache("GYO_HRVOL","X3_PICTURE"),GetSx3Cache("GYO_HRVOL","X3_TAMANHO"),"LEFT"},;
				{"GYO_HRFVOL","GYO",GetSx3Cache("GYO_HRFVOL","X3_TITULO"),GetSx3Cache("GYO_HRFVOL","X3_PICTURE"),GetSx3Cache("GYO_HRFVOL","X3_TAMANHO"),"LEFT"},;
				{"NUMVEIC","GYO","Cod Recurso",'',20,"LEFT"},;
				{"TPVISTO","GYO","Visto",'',20,"LEFT"}}
				//{"GYP_LINCOD","GYP",GetSx3Cache("GYP_LINCOD","X3_TITULO"),"",GetSx3Cache("GYP_LINCOD","X3_TAMANHO"),"LEFT"},;
Case ( cSection == "SEC_TOTAL" )	//SEÇÃO 3: Apuração
	
	aRet := {; 	
				{"TOTAL_NORMAL"	,"GYO","Hrs Normais"	,"@R 999:99",GetSx3Cache("GYO_HRVOL","X3_TAMANHO")+15,"LEFT"},;
				{"TOTAL_EXTRA"	,"GYO","Hrs Extras"		,"@R 999:99",GetSx3Cache("GYO_HRVOL","X3_TAMANHO")+15,"LEFT"},;
				{"TOTAL_DSR"	,"GYO","D.S.R"			,"@R 99:99"	,GetSx3Cache("GYO_HRVOL","X3_TAMANHO")+15,"LEFT"},;
				{"TOTAL_ADN"	,"GYO","A.D.N"			,"@R 999:99",GetSx3Cache("GYO_HRVOL","X3_TAMANHO")+15,"LEFT"},;
				{"TOTAL_PLANTAO","GYO","Hrs Plantão"	,"@R 999:99",GetSx3Cache("GYO_HRVOL","X3_TAMANHO")+15,"LEFT"},;
				{"TOTAL_HRVOL"	,"GYO","Hrs Volante"	,"@R 999:99",GetSx3Cache("GYO_HRVOL","X3_TAMANHO")+15,"LEFT"},;
				{"TOTAL_HRFVOL"	,"GYO","Hrs Fora Vol"	,"@R 999:99",GetSx3Cache("GYO_HRVOL","X3_TAMANHO")+15,"LEFT"},;
				{"TOTAL_HORAS"	,"GYO","Hrs Trab"		,"@R 999:99",GetSx3Cache("GYO_HRVOL","X3_TAMANHO")+15,"LEFT"},;
                {"TOTAL_EXTDSR"	,"GYO","Ext - DSR"		,"@R 999:99",GetSx3Cache("GYO_HRVOL","X3_TAMANHO")+15,"LEFT"};
			}
				
			//{"TOTAL_LINCOD","GYP",Space(Len(GetSx3Cache("GYP_LINCOD","X3_TITULO"))),"",GetSx3Cache("GYP_LINCOD","X3_TAMANHO"),"LEFT"},;
EndCase

Return(aRet)

Static Function ReportPrint(oReport)

Local cAliasDSR		:= GetNextAlias()
Local cHrsDSR		:= "0000"
Local nQtdDSR		:= 0
Local nHrDsr		:= 0
Local oSecColab		:= oReport:Section(1)						//SEÇÃO 1: DADOS DO COLABORADOR
Local oSecAgenda	:= oReport:Section(1):Section(1)			//SEÇÃO 2: DADOS DO AGENDA
Local oSecTotal		:= oReport:Section(1):Section(1):Section(1)	//SEÇÃO 3: TOTAL
Local cTmpAlias     := GR302ASetQry()

If((cTmpAlias)->(!Eof()))
	oReport:StartPage()

	oSecColab:Init()
			
	GR302APutValues(cTmpAlias, oSecColab, "SEC_COLAB")
			
	oReport:ThinLine()
			
	oSecColab:Finish()

	oSecAgenda:Init()
		

	GR302ASecColab(cTmpAlias, oSecAgenda, oReport)


	oSecTotal:Init()
		
	(cTmpAlias)->(DBGOTOP())

	BeginSQl Alias cAliasDSR
		SELECT COUNT(GYE_TPDIA) as TOTFOLGA
		FROM %Table:GYE% GYE
		WHERE
			GYE.GYE_FILIAL = %xFilial:GYE%
			AND GYE_CODGYQ = %Exp:GYQ->GYQ_CODIGO%
			AND GYE_COLCOD = %Exp:GYQ->GYQ_COLCOD%
			//AND GYE_DTREF BETWEEN %Exp:MV_PAR02% AND %Exp:MV_PAR03%
			AND GYE_TPDIA in ('3','4')
			AND GYE.%NotDel%
	EndSql

	If (cTmpAlias)->GYQ_QTDDSR > (cAliasDSR)->TOTFOLGA
		nQtdDSR	:= (cTmpAlias)->GYQ_QTDDSR - (cAliasDSR)->TOTFOLGA
		nHrDsr	:= nQtdDSR * (cTmpAlias)->RA_HRSDIA
		cHrsDSR := IntToHora(nHrDsr)
	Else 
		cHrsDSR := "0000" 
	EndIf
	
	oSecTotal:Cell("TOTAL_HRVOL"	):SetValue((cTmpAlias)->GYQ_HRVOLA)
	oSecTotal:Cell("TOTAL_HRFVOL"	):SetValue(Hr2Str(SomaHoras(Transform( (cTmpAlias)->GYQ_HRFVOL, "@R 999:99" ) ,Transform((cTmpAlias)->GYQ_HRDESP, "@R 999:99" ) ),"HHH:MM"))
	oSecTotal:Cell("TOTAL_HORAS"	):SetValue((cTmpAlias)->GYQ_HRTRAB)
	oSecTotal:Cell("TOTAL_PLANTAO"	):SetValue((cTmpAlias)->GYQ_HRPLAN)	
	oSecTotal:Cell("TOTAL_ADN"		):SetValue((cTmpAlias)->GYQ_HRADN)
	oSecTotal:Cell("TOTAL_EXTRA"	):SetValue((cTmpAlias)->GYQ_HREXTR)
	oSecTotal:Cell("TOTAL_DSR"		):SetValue(cHrsDSR)	
	oSecTotal:Cell("TOTAL_NORMAL"	):SetValue((cTmpAlias)->GYQ_HRMENS)

	If SUBHORAS(Transform((cTmpAlias)->GYQ_HREXTR, "@R 999:99" ),cHrsDSR) > 0 
		oSecTotal:Cell("TOTAL_EXTDSR"	):SetValue(Hr2Str(SUBHORAS(Transform((cTmpAlias)->GYQ_HREXTR, "@R 999:99" ),cHrsDSR),"HHH:MM"))
	else
		oSecTotal:Cell("TOTAL_EXTDSR"	):SetValue('00000')
	Endif


	oSecTotal:PrintLine()
	oSecTotal:Finish()

	oReport:SkipLine(2)
	oReport:PrintText("Assinatura: ________________________________________________" + "         " + "Data de " + DtoC((cTmpAlias)->GYQ_DTINI) + "       " + "Date até " + DtoC((cTmpAlias)->GYQ_DTFIM) )//"Filial: "
	oReport:SkipLine(1)
	oReport:ThinLine()		

	oSecAgenda:Finish()

	(cAliasDSR)->(DbCloseArea())
Else
	FwAlertWarning(STR0001,STR0002)//"Não há dados para serem apresentados""Atenção"
EndIf
// GR302ADestroy(cTmpAlias)

Return()


Function GR302ASetQry()
Local cTmpAlias	:= Iif( Valtype(oGR302ATable) <> "O",GetNextAlias(),oGR302ATable:GetAlias())
Local cCodGYQ	:= GYQ->GYQ_CODIGO
Local cColabora	:= GYQ->GYQ_COLCOD
Local cQuery	:= ""
//BeginSql Alias cTmpAlias
//	Column GYE_DTREF as date
//	Column GYQ_DTINI as date
//	Column GYQ_DTFIM as date

	cQuery	+= "SELECT                                                                                    "
	cQuery	+= "	GYG.GYG_CODIGO,                                                                       "
	cQuery	+= "	LTRIM(RTRIM(REPLACE(REPLACE(GYG.GYG_NOME,'(',''),')',''))) GYG_NOME,                  "
	cQuery	+= "	GYQ_DTINI,                                                                            "
	cQuery	+= "	GYQ_DTFIM,                                                                            "
	cQuery	+= "	GYQ_CODIGO,                                                                           "
	//----------ESCALAS------------------------------------------------------------------------------------------
	cQuery	+= "	GYE.GYE_DTREF,                                                                        "
	cQuery	+= "	GYE.GYE_TPDIA,                                                                        "
	cQuery	+= "	GYP.GYP_ESCALA,                                                                       "
	cQuery	+= "	GYP.GYP_ITEM,                                                                         "
	cQuery	+= "	GID.GID_NUMSRV,                                                                       "
	cQuery	+= "	LTRIM(RTRIM(REPLACE(REPLACE(GI1ORI.GI1_DESCRI,'(',''),')','')))  AS GYP_SRVORI,       "
	cQuery	+= "	LTRIM(RTRIM(REPLACE(REPLACE(GI1DES.GI1_DESCRI,'(',''),')','')))  AS GYP_SRVDES,       "
	cQuery	+= "	GYP.GYP_HRINIT,                                                                       "
	cQuery	+= "	GYP.GYP_HORORI,                                                                       "
	cQuery	+= "	GYP.GYP_HORDES,                                                                       "
	cQuery	+= "	GYP.GYP_HRFIMT,                                                                       "
	cQuery	+= "	GQK.GQK_CODIGO,                                                                       "
	cQuery	+= "	GQK.GQK_CODGZS,                                                                       "
	cQuery	+= "	GYP.GYP_TIPO,                                                                         "
	cQuery	+= "	(CASE                                                                                 "
	cQuery	+= "		WHEN GYE.GYE_SITRH	= '2'							THEN 'Férias'                 "
	cQuery	+= "		WHEN GYE.GYE_SITRH	= '3'							THEN 'Afastado'               "
	cQuery	+= "		WHEN GYE.GYE_SITRH	= '4'							THEN 'Demitido'               "
	cQuery	+= "		WHEN GYP.GYP_TIPO	= '2' AND GYP.GYP_SRVEXT <> ''	THEN GZSEXT.GZS_DESCRI        "
	cQuery	+= "		WHEN GYP.GYP_TIPO	= '3'							THEN 'Plantão'                "
	cQuery	+= "		WHEN GYP.GYP_TIPO	= '4'							THEN 'Intervalo'              "
	cQuery	+= "		WHEN GYP.GYP_PASSAG = '1'							THEN 'Motorista Passageiro'   "
	cQuery	+= "		WHEN GYP.GYP_TIPO	= '2' AND GYP.GYP_SRVEXT = ''	THEN 'Extraordinario'         "
	cQuery	+= "		WHEN GQK.GQK_CODGZS <> ''							THEN GZSPLAN.GZS_DESCRI       "
	cQuery	+= "		WHEN GYE.GYE_TPDIA	= '3'							THEN 'Folga'                  "
	cQuery	+= "		WHEN GYE.GYE_TPDIA	= '4'							THEN 'DSR'                    "
	cQuery	+= "		ELSE ''                                                                           "
	cQuery	+= "	END) AS VISTO,                                                                        "
	cQuery	+= "	(CASE                                                                                 "
	cQuery	+= "		WHEN GYPMIN.GYP_ITEM IS NOT NULL AND GYPMAX.GYP_ITEM IS NOT NULL  THEN 'FULL'     "
	cQuery	+= "		WHEN GYPMIN.GYP_ITEM IS NOT NULL THEN 'MIN'                                       "
	cQuery	+= "		WHEN GYPMAX.GYP_ITEM IS NOT NULL  THEN 'MAX'                                      "
	cQuery	+= "		WHEN GYP.GYP_TIPO <> '1' THEN GYP_TIPO                                            "
	cQuery	+= "		WHEN GYP.GYP_PASSAG = '1' THEN '6'                                                "
	cQuery	+= "		ELSE '0'                                                                          "
	cQuery	+= "	END) AS MINMAX,                                                                       "
	cQuery	+= "	(Case                                                                                 "
	cQuery	+= "		WHEN MAXITEM.GYP_ITEM IS NOT NULL THEN 'MAX'                                      "
	cQuery	+= "		ELSE ''                                                                           "
	cQuery	+= "	End) AS MAXITEM,                                                                      "
	cQuery	+= "	GYO_HRVOL,                                                                            "
	cQuery	+= "	GYO_HRFVOL,                                                                           "
	cQuery	+= "	GYO_HRDESP,                                                                           "
	//----------TOTALIZADORES--------------------------------------------------------------------------------
	cQuery	+= "	GYQ.GYQ_HRVOLA,                                                                       "
	cQuery	+= "	GYQ.GYQ_HRFVOL,                                                                       "
	cQuery	+= "	GYQ.GYQ_HRTRAB,                                                                       "
	cQuery	+= "	GYQ.GYQ_HRPLAN,                                                                       "
	cQuery	+= "	GYQ.GYQ_HRADN,                                                                        "
	cQuery	+= "	GYQ.GYQ_HREXTR,                                                                       "
	cQuery	+= "	GYQ.GYQ_QTDDSR,                                                                       "
	cQuery	+= "	GYQ.GYQ_HRMENS,                                                                       "
	cQuery	+= "	GYQ.GYQ_HRDESP,                                                                       "
	cQuery	+= "	SRA.RA_HRSDIA                                                                         "
	
	cQuery	+= "FROM "+RetSqlName('GYE')+" GYE                                                                      "
	cQuery	+= "	INNER JOIN "+RetSqlName('GYQ')+" GYQ ON                                                         "
	cQuery	+= "		GYQ.GYQ_FILIAL = GYE.GYE_FILIAL                                                   "
	cQuery	+= "		AND GYQ.GYQ_CODIGO = '"+cCodGYQ+"'                                                "
	cQuery	+= "		AND GYQ.GYQ_CODIGO = GYE.GYE_CODGYQ                                               "
	cQuery	+= "		AND GYQ.D_E_L_E_T_ = ' '                                                          "
	cQuery	+= "	INNER JOIN "+RetSqlName('GYG')+" GYG ON                                                         "
	cQuery	+= "		GYG.GYG_FILIAL = '"+xFilial('GYG')+"'                                                    "
	cQuery	+= "		AND GYG.GYG_CODIGO = GYQ.GYQ_COLCOD                                               "
	cQuery	+= "		AND GYG.D_E_L_E_T_ = ' '                                                          "
	cQuery	+= "	INNER JOIN "+RetSqlName('SRA')+" SRA ON                                                         "
	cQuery	+= "		SRA.RA_FILIAL = GYG.GYG_FILSRA                                                    "
	cQuery	+= "		AND SRA.RA_MAT = GYG.GYG_FUNCIO                                                   "
	cQuery	+= "		AND SRA.D_E_L_E_T_ = ' '                                                          "
	cQuery	+= "	LEFT JOIN "+RetSqlName('GYO')+" GYO ON                                                          "
	cQuery	+= "		GYO.GYO_FILIAL = '"+xFilial('GYO')+"'                                                    "
	cQuery	+= "		AND GYO.GYO_CODIGO = GYE.GYE_ESCALA                                               "
	cQuery	+= "		AND GYO.D_E_L_E_T_ = ' '                                                          "
	cQuery	+= "	LEFT JOIN "+RetSqlName('GYP')+" GYP ON                                                          "
	cQuery	+= "		GYP.GYP_FILIAL= GYO.GYO_FILIAL                                                    "
	cQuery	+= "		AND GYP.GYP_ESCALA = GYE.GYE_ESCALA                                               "
	cQuery	+= "		AND GYP.D_E_L_E_T_ = ' '                                                          "
	cQuery	+= "	LEFT JOIN "+RetSqlName('GID')+" GID ON                                                          "
	cQuery	+= "		GID.GID_FILIAL = '"+xFilial('GID')+"'                                                             "
	cQuery	+= "		AND GID.GID_COD = GYP.GYP_CODGID                                                  "
	cQuery	+= "		AND GID.D_E_L_E_T_ = ' '                                                          "
	cQuery	+= "	LEFT JOIN "+RetSqlName('GI1')+" GI1ORI ON                                                       "
	cQuery	+= "		GI1ORI.GI1_FILIAL = '"+xFilial('GI1')+"'                                                 "
	cQuery	+= "		AND GI1ORI.GI1_COD = GYP.GYP_SRVORI                                               "
	cQuery	+= "		AND GI1ORI.D_E_L_E_T_ = ' '                                                       "
	cQuery	+= "	LEFT JOIN "+RetSqlName('GI1')+" GI1DES ON                                                       "
	cQuery	+= "		GI1DES.GI1_FILIAL = '"+xFilial('GI1')+"'                                                 "
	cQuery	+= "		AND GI1DES.GI1_COD = GYP.GYP_SRVDES                                               "
	cQuery	+= "		AND GI1DES.D_E_L_E_T_ = ' '                                                       "
	cQuery	+= "	LEFT JOIN "+RetSqlName('GQK')+" GQK ON                                                          "
	cQuery	+= "		GQK.GQK_FILIAL = '"+xFilial('GQK')+"'                                                             "
	cQuery	+= "		AND GQK.GQK_DTREF = GYE.GYE_DTREF                                                 "
	cQuery	+= "		AND GQK.GQK_RECURS = GYE.GYE_COLCOD                                               "
	cQuery	+= "		AND GQK.GQK_CODGYQ = GYQ.GYQ_CODIGO                                               "
	cQuery	+= "		AND (                                                                            "
	cQuery	+= "				(GYP.GYP_TIPO IS NOT NULL                                                "
	cQuery	+= "				AND GYP.GYP_TIPO = '3'                                                   "
	cQuery	+= "				AND GYP.GYP_HRINIT = GQK.GQK_HRINI                                       "
	cQuery	+= "				AND GYP.GYP_HRFIMT = GQK.GQK_HRFIM)                                      "
	cQuery	+= "				OR GYP.GYP_TIPO IS NULL                                                  "
	cQuery	+= "			)                                                                            "
	cQuery	+= "		AND GQK.D_E_L_E_T_ = ' '                                                          "
	cQuery	+= "	LEFT JOIN "+RetSqlName('GZS')+" GZSEXT ON                                                          "
	cQuery	+= "		GZSEXT.GZS_FILIAL = '"+xFilial('GZS')+"'                                                    "
	cQuery	+= "		AND GZSEXT.GZS_CODIGO = GYP.GYP_SRVEXT                                               "
	cQuery	+= "		AND GZSEXT.D_E_L_E_T_ = ' '                                                          "
	cQuery	+= "	LEFT JOIN "+RetSqlName('GZS')+" GZSPLAN ON                                                          "
	cQuery	+= "		GZSPLAN.GZS_FILIAL = '"+xFilial('GZS')+"'                                                    "
	cQuery	+= "		AND GZSPLAN.GZS_CODIGO = GQK.GQK_CODGZS                                               "
	cQuery	+= "		AND GZSPLAN.D_E_L_E_T_ = ' '                                                          "
	
	cQuery	+= "	LEFT JOIN (                                                                           "
	cQuery	+= "				SELECT GYP_FILIAL,GYP_ESCALA,GYP_CODGID,MIN(GYP_ITEM) AS GYP_ITEM         "
	cQuery	+= "				FROM "+RetSqlName('GYE')+" GYE                                                      "
	cQuery	+= "					INNER JOIN "+RetSqlName('GYP')+" GYP ON                                         "
	cQuery	+= "						GYP.GYP_FILIAL = '"+xFilial('GYP')+"'                                    "
	cQuery	+= "						AND GYP.GYP_ESCALA = GYE.GYE_ESCALA                               "
	cQuery	+= "						AND GYP.D_E_L_E_T_ = ' '                                          "
	cQuery	+= "				WHERE                                                                     "
	cQuery	+= "					GYE.GYE_FILIAL = '"+xFilial('GYE')+"'                                        "
	cQuery	+= "					AND GYE_CODGYQ = '"+cCodGYQ+"'                                        "
	cQuery	+= "					AND GYE_COLCOD = '"+cColabora+"'                                      "
	cQuery	+= "					AND GYP.GYP_TIPO = '1'                                                "
	cQuery	+= "					AND GYE.D_E_L_E_T_ = ' '                                              "
	cQuery	+= "				GROUP BY GYP_FILIAL,GYP_ESCALA,GYP_CODGID                                 "
	cQuery	+= "			) AS GYPMIN ON                                                                "
	cQuery	+= "		GYPMIN.GYP_FILIAL = GYP.GYP_FILIAL                                                "
	cQuery	+= "		AND GYPMIN.GYP_ESCALA = GYP.GYP_ESCALA                                            "
	cQuery	+= "		AND GYPMIN.GYP_CODGID = GYP.GYP_CODGID                                            "
	cQuery	+= "		AND GYPMIN.GYP_ITEM = GYP.GYP_ITEM                                                "
	
	cQuery	+= "	LEFT JOIN (                                                                           "
	cQuery	+= "				SELECT GYP_FILIAL,GYP_ESCALA,GYP_CODGID,MAX(GYP_ITEM) AS GYP_ITEM         "
	cQuery	+= "				FROM "+RetSqlName('GYE')+" GYE                                                      "
	cQuery	+= "					INNER JOIN "+RetSqlName('GYP')+" GYP ON                                         "
	cQuery	+= "						GYP.GYP_FILIAL = '"+xFilial('GYP')+"'                                    "
	cQuery	+= "						AND GYP.GYP_ESCALA = GYE.GYE_ESCALA                               "
	cQuery	+= "						AND GYP.GYP_TIPO = '1'                                            "
	cQuery	+= "						AND GYP.D_E_L_E_T_ = ' '                                          "
	cQuery	+= "				WHERE                                                                     "
	cQuery	+= "					GYE.GYE_FILIAL = '"+xFilial('GYE')+"'                                        "
	cQuery	+= "					AND GYE_CODGYQ = '"+cCodGYQ+"'                                        "
	cQuery	+= "					AND GYE_COLCOD = '"+cColabora+"'                                      "
	cQuery	+= "					AND GYE.D_E_L_E_T_ = ' '                                              "
	cQuery	+= "				GROUP BY GYP_FILIAL,GYP_ESCALA,GYP_CODGID                                 "
	cQuery	+= "			) AS GYPMAX ON                                                                "
	cQuery	+= "		GYPMAX.GYP_FILIAL = GYP.GYP_FILIAL                                                "
	cQuery	+= "		AND GYPMAX.GYP_ESCALA = GYP.GYP_ESCALA                                            "
	cQuery	+= "		AND GYPMAX.GYP_CODGID = GYP.GYP_CODGID                                            "
	cQuery	+= "		AND GYPMAX.GYP_ITEM = GYP.GYP_ITEM                                                "
	
	cQuery	+= "	LEFT JOIN (                                                                           "
	cQuery	+= "				SELECT GYP_FILIAL,GYP_ESCALA,MAX(GYP_ITEM) AS GYP_ITEM                    "
	cQuery	+= "				FROM "+RetSqlName('GYE')+" GYE                                                      "
	cQuery	+= "					INNER JOIN "+RetSqlName('GYP')+" GYP ON                                         "
	cQuery	+= "						GYP.GYP_FILIAL = '"+xFilial('GYP')+"'                                    "
	cQuery	+= "						AND GYP.GYP_ESCALA = GYE.GYE_ESCALA                               "
	cQuery	+= "						AND GYP.D_E_L_E_T_ = ' '                                          "
	cQuery	+= "				WHERE                                                                     "
	cQuery	+= "					GYE.GYE_FILIAL = '"+xFilial('GYE')+"'                                        "
	cQuery	+= "					AND GYE_CODGYQ = '"+cCodGYQ+"'                                        "
	cQuery	+= "					AND GYE_COLCOD = '"+cColabora+"'                                      "
	cQuery	+= "					AND GYE.D_E_L_E_T_ = ' '                                              "
	cQuery	+= "				GROUP BY GYP_FILIAL,GYP_ESCALA                                            "
	cQuery	+= "			) AS MAXITEM ON                                                               "
	cQuery	+= "		MAXITEM.GYP_FILIAL = GYP.GYP_FILIAL                                               "
	cQuery	+= "		AND MAXITEM.GYP_ESCALA = GYP.GYP_ESCALA                                           "
	cQuery	+= "		AND MAXITEM.GYP_ITEM = GYP.GYP_ITEM                                               "
	
	cQuery	+= "WHERE                                                                                     "
	cQuery	+= "	GYE.GYE_FILIAL = '"+xFilial('GYE')+"'                                                        "
	cQuery	+= "	AND GYE_COLCOD = '"+cColabora+"'                                                      "
	cQuery	+= "	AND GYE.D_E_L_E_T_ = ' '                                                              "
	cQuery	+= "ORDER BY                                                                                  "
	cQuery	+= "	GYE.GYE_DTREF,                                                                        "
	cQuery	+= "	GYP.GYP_ITEM                                                                          "

//EndSql

GTPTemporaryTable(cQuery,cTmpAlias,{{"IDX",{"GYE_DTREF","GYP_ITEM"}}},{{"GYE_DTREF","D",8},{"GYQ_DTINI","D",8},{"GYQ_DTFIM","D",8}},@oGR302ATable)

Return cTmpAlias
// dbo.##TMPSC05_75
// Function GR302ADestroy(cTmpAlias)

// If ( ValType(cTmpAlias) <> "U" .and. Select(cTmpAlias)> 0 )
// 	(cTmpAlias)->(DbCloseArea())
// EndIf

// If ( ValType(oGR302ATable) == "O" )
// 	oGR302ATable:Delete()
// 	GTPDestroy(oGR302ATable)
// EndIf

// Return()

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} TR50PutValues
Função que atualiza o conteúdo das células de uma determinada seção.

@type 		Function
@author 	Fernando Radu Muscalu
@since 		29/02/2016
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function GR302APutValues(cAlias, xSection, cSecCell)

Local nI := 0 
Local nX := 0
Local nP := 0

Local cConteudo	:= ""
Local aCells 	:= GR302ACellCollect(cSecCell)

If ( Valtype(xSection) == "O" )
	
	For nI := 1 to Len(aCells)
		If ( "_" $ aCells[nI,1] )
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
		Else
			cConteudo := ''
		Endif
		
		xSection:Cell(aCells[nI,1]):SetValue(cConteudo)
		
	Next nI
	/*If cSecCell == "SEC_COLAB"
		xSection:Cell("DATADE"):SetValue(MV_PAR02)
		xSection:Cell("DATAATE"):SetValue(MV_PAR03)
	EndIf*/
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

//+----------------------------------------------------------------------------------------
/*/{Protheus.doc} GR302ASecColab
Realiza impressão da escala

@type 		Function
@author 	Yuki Shiroma	
@since 		22/02/2018
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function GR302ASecColab(cTmpAlias, oSecColab, oReport)
Local dDtRef		:=CtoD('  /  /  ')
Local cEscala		:=""
Local cNumSrv		:=""
Local cLocOri		:=""
Local cLocDes		:=""
Local cHrIniTrb	    :=""
Local cHrOrigem	    :=""
Local cHrDestino	:=""
Local cHrFimTrb	    :=""
Local cHrVolante	:=""
Local cHrFrVol		:=""
Local cVisto		:=""
Local lReset 		:= .T.
Local lIntervalo	:= .F.
(cTmpAlias)->(DbGoTop())	

While (cTmpAlias)->(!EoF())
	If dDtRef <> (cTmpAlias)->GYE_DTREF
		oReport:ThinLine()
		dDtRef := (cTmpAlias)->GYE_DTREF
		lReset := .T.
	EndIf
	If (cTmpAlias)->GYE_TPDIA == '1'
		If !lReset .and. (ALLTRIM((cTmpAlias)->MINMAX) == "0") 
			(cTmpAlias)->(DbSkip())
			loop
		Endif
		If (ALLTRIM((cTmpAlias)->MINMAX) == "0" .and. lIntervalo)
			(cTmpAlias)->MINMAX := "MIN"
			lIntervalo	:= .F.
		ElseIf (ALLTRIM((cTmpAlias)->MINMAX) == "MAX" .and. lIntervalo)
			(cTmpAlias)->MINMAX := "FULL"
			lIntervalo	:= .F.
		Endif
		//If lReset
			If ALLTRIM((cTmpAlias)->MINMAX) == 'MIN' 
				cHrIniTrb	:= (cTmpAlias)->GYP_HRINIT	
				cHrOrigem	:= (cTmpAlias)->GYP_HORORI	
				cLocOri		:= (cTmpAlias)->GYP_SRVORI
				While (cTmpAlias)->(!EoF())
					If ALLTRIM((cTmpAlias)->MINMAX) == 'MAX'
						Exit
					ElseIf (cTmpAlias)->GYP_TIPO = '4' .or. ALLTRIM((cTmpAlias)->MINMAX) == '6'
						lReset 		:= .T.
						lIntervalo	:= .T.
						(cTmpAlias)->(DbSkip(-1))
						Exit
					Endif
					(cTmpAlias)->(DbSkip())
				EndDo 
			ElseIf ALLTRIM((cTmpAlias)->MINMAX) <> 'MAX' 
				cHrIniTrb	:= (cTmpAlias)->GYP_HRINIT	
				cHrOrigem	:= (cTmpAlias)->GYP_HORORI	
				cLocOri		:= (cTmpAlias)->GYP_SRVORI 
				
			Endif
		//Endif
		
		cEscala		:= (cTmpAlias)->GYP_ESCALA
		cNumSrv		:= (cTmpAlias)->GID_NUMSRV	
		cLocDes		:= (cTmpAlias)->GYP_SRVDES	
		cHrDestino	:= (cTmpAlias)->GYP_HORDES	
		cHrFimTrb	:= (cTmpAlias)->GYP_HRFIMT
		If (cTmpAlias)->MAXITEM == "MAX"
			cHrVolante	:= (cTmpAlias)->GYO_HRVOL
			cHrFrVol	:= GTFormatHour(SomaHoras(GTFormatHour((cTmpAlias)->GYO_HRFVOL, "99:99"),GTFormatHour((cTmpAlias)->GYO_HRDESP, "99:99")), "99:99")
		Else
			cHrVolante	:= "0000"
			cHrFrVol	:= "0000"
		Endif	
		cVisto		:= (cTmpAlias)->VISTO	
	Else
		cEscala		:= ""
		cNumSrv		:= ""	
		cLocOri		:= ""	
		cLocDes		:= ""	
		cHrIniTrb	:= ""	
		cHrOrigem	:= ""	
		cHrDestino	:= ""	
		cHrFimTrb	:= ""	
		cHrVolante	:= ""
		cHrFrVol	:= ""	
		cVisto		:= (cTmpAlias)->VISTO	
	Endif
	oSecColab:Cell("GYE_DTREF"	):SetValue(dDtRef		)
	oSecColab:Cell("GYP_ESCALA"	):SetValue(cEscala		)
	oSecColab:Cell("GID_NUMSRV"	):SetValue(cNumSrv		)
	oSecColab:Cell("GYP_SRVORI"	):SetValue(cLocOri		)
	oSecColab:Cell("GYP_SRVDES"	):SetValue(cLocDes		)
	oSecColab:Cell("GYP_HRINIT"	):SetValue(cHrIniTrb	)
	oSecColab:Cell("GYP_HORORI"	):SetValue(cHrOrigem	)
	oSecColab:Cell("GYP_HORDES"	):SetValue(cHrDestino	)
	oSecColab:Cell("GYP_HRFIMT"	):SetValue(cHrFimTrb	)
	oSecColab:Cell("GYO_HRVOL"	):SetValue(cHrVolante	)
	oSecColab:Cell("GYO_HRFVOL"	):SetValue(cHrFrVol		)
	oSecColab:Cell("TPVISTO"	):SetValue(cVisto		)
	oSecColab:PrintLine()
	(cTmpAlias)->(DbSkip())
	If lReset .AND. !lIntervalo
		lReset := .F.
	Endif
EndDo 


Return()


Static Function Hr2Str(xVal,cFormat)
Local cRet			:= ""
Local aFormatHr		:= Separa(cFormat,":") 
Local cSeparador	:= ":" 
Local aHour			:= nil
Local n1			:= 0
Local cRetFormat	:= ""
If ValType(xVal) == 'N'
	xVal := cValToChar(xVal)
Endif

If ( At(".",xVal) > 0 )
	cSeparador := "."	
ElseIf ( At(":",xVal) > 0 )
	cSeparador := ":"
Endif

aHour := Separa(xVal, cSeparador)

For n1	:= 1 To Len(aFormatHr)
	If n1 <= Len(aHour)
		If "H" $ aFormatHr[n1] 
			cRet += PadL(aHour[n1],Len(aFormatHr[n1]),"0")
		Else
			cRet += PadR(aHour[n1],Len(aFormatHr[n1]),"0")
		Endif   
	Else
		If "H" $ aFormatHr[n1] 
			cRet += PadL("",Len(aFormatHr[n1]),"0")
		Else
			cRet += PadR("",Len(aFormatHr[n1]),"0")
		Endif
	Endif
	If n1 > 1
		cRetFormat += ":"
	Endif
	cRetFormat += Replicate('9',Len(aFormatHr[n1]))
	
Next

cRet := Transform(cRet, "@R " + cRetFormat )

Return cRet
