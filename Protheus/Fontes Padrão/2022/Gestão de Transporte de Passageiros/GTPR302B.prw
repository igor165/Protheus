#Include 'Protheus.ch'
#include "rwmake.ch"
#INCLUDE "RPTDEF.CH"

Static oGR302BTable
Static cAliasGYO

Function GTPR302B()

oReport := ReportDef()
oReport:PrintDialog()

Return


Static Function ReportDef()


Local oReport

Local bPrint	:= {|oRpt|	ReportPrint(oRpt)}

oReport := TReport():New('GTPR302B', "Relatório de Escalas por Grupo", , bPrint, "Gera Relatório", .F. /*lLandscape*/, /*uTotalText*/, /*lTotalInLine*/, /*cPageTText*/, /*lPageTInLine*/, /*lTPageBreak*/, /*nColSpace*/)//"Relatório de Agenda Programada" "Gera Relatório"

SetSections(oReport)

Return oReport


Static Function SetSections(oReport)

Local oSecGrupo		:= TRSection():New(oReport		,"SEC_GRUPO"	, {'GYT','GZA'	})//SEÇÃO 1: DADOS DO SETOR x Grupo           
Local oSecEscCab	:= TRSection():New(oSecGrupo	,"SEC_ESCCAB"	, {'GYQ','GYP'	})//SEÇÃO 2: DADOS De Cabeçalho da Escala     
Local oSecEscDet	:= TRSection():New(oSecEscCab	,"SEC_ESCDET"	, {'GYQ','GYP'	})//SEÇÃO 3: DADOS De Detalhes da Escala      

Local aSecGrupo		:= GR302BCellCollect("SEC_GRUPO"	)	//SEÇÃO 1: DADOS DO SETOR x Grupo
Local aSecEscCab	:= GR302BCellCollect("SEC_ESCCAB"	)	//SEÇÃO 2: DADOS De Cabeçalho da Escala
Local aSecEscDet	:= GR302BCellCollect("SEC_ESCDET"	)	//SEÇÃO 3: DADOS De Detalhes da Escala

Local nX	:= 0

oSecEscDet:SetLeftMargin(3) 


//Células da Seção 1 - Início
For nX := 1 To len(aSecGrupo)

	TRCell():New(oSecGrupo, aSecGrupo[nX,1], aSecGrupo[nX,2], aSecGrupo[nX,3], aSecGrupo[nX,4], aSecGrupo[nX,5],,,aSecGrupo[nX,6])
					
Next nX

//Células da Seção 2 - Início
For nX := 1 To len(aSecEscCab)

	TRCell():New(oSecEscCab, aSecEscCab[nX,1], aSecEscCab[nX,2], aSecEscCab[nX,3], aSecEscCab[nX,4], aSecEscCab[nX,5],,,aSecEscCab[nX,6])
					
Next nX

//Células da Seção 3 - Início
For nX := 1 To len(aSecEscDet)

	TRCell():New(oSecEscDet, aSecEscDet[nX,1], aSecEscDet[nX,2], aSecEscDet[nX,3], aSecEscDet[nX,4], aSecEscDet[nX,5],,,aSecEscDet[nX,6])
					
Next nX

//Definição das Células das seções - fim

Return()

Static Function GR302BCellCollect(cSection)

Local aRet		:= {}

Do Case
Case ( cSection == "SEC_GRUPO" )	// SEÇÃO 1: Dados do Setor
	
	//Nome da Célula, Alias da Tabela, Nome da Coluna, Picture, Tamanho
	
	aRet := {; 	
				{"GYT_CODIGO"	,"GYT","Cód Setor"		,X3Picture("GYT_CODIGO"),TamSx3("GYT_CODIGO")[1]+15,"LEFT"},;
				{"GYT_DESCRI"	,"GYT","Nome Setor"		,X3Picture("GYT_DESCRI"),TamSx3("GYT_DESCRI")[1]+15,"LEFT"},;
				{"GZA_CODIGO"	,"GZA","Cód Grupo"		,X3Picture("GZA_CODIGO"),TamSx3("GZA_CODIGO")[1]+15,"LEFT"},;
				{"GZA_DESCRI"	,"GZA","Nome Grupo"		,X3Picture("GZA_DESCRI"),TamSx3("GZA_DESCRI")[1]+15,"LEFT"};
			}

Case ( cSection == "SEC_ESCCAB" )	// SEÇÃO 1: Dados do Setor
	
	//Nome da Célula, Alias da Tabela, Nome da Coluna, Picture, Tamanho
	
	aRet := {; 	
				{"GYO_CODIGO"	,"GYP",GTPX3TIT("GYO_CODIGO")	,X3Picture("GYO_CODIGO"	),TamSx3("GYO_CODIGO"	)[1]+15,"LEFT"},;
				{"GYO_DESCRI"	,"GYO",GTPX3TIT("GYO_DESCRI")	,X3Picture("GYO_DESCRI"	),TamSx3("GYO_DESCRI"	)[1]+15,"LEFT"},;
				{"GYO_HRVOL"	,"GYO",GTPX3TIT("GYO_HRVOL"	)	,X3Picture("GYO_HRVOL"	),TamSx3("GYO_HRVOL"	)[1]+15,"LEFT"},;                                                                        
				{"GYO_HRFVOL"	,"GYO",GTPX3TIT("GYO_HRFVOL")	,X3Picture("GYO_HRFVOL"	),TamSx3("GYO_HRFVOL"	)[1]+15,"LEFT"},;
				{"GYO_RHPLAN"	,"GYO",GTPX3TIT("GYO_RHPLAN")	,X3Picture("GYO_RHPLAN"	),TamSx3("GYO_RHPLAN"	)[1]+15,"LEFT"},;
				{"GYO_HRDESP"	,"GYO",GTPX3TIT("GYO_HRDESP")	,X3Picture("GYO_HRDESP"	),TamSx3("GYO_HRDESP"	)[1]+15,"LEFT"},;
				{"GYO_HORAAD"	,"GYO",GTPX3TIT("GYO_HORAAD")	,X3Picture("GYO_HORAAD"	),TamSx3("GYO_HORAAD"	)[1]+15,"LEFT"},;
				{"GYO_HORPAG"	,"GYO",GTPX3TIT("GYO_HORPAG")	,X3Picture("GYO_HORPAG"	),TamSx3("GYO_HORPAG"	)[1]+15,"LEFT"},;
				{"GYO_SEG"		,"GYO",GtpxDoW(2,3)				,X3Picture("GYO_SEG"	),TamSx3("GYO_SEG"		)[1]+15,"LEFT"},;
				{"GYO_TER"		,"GYO",GtpxDoW(3,3)				,X3Picture("GYO_TER"	),TamSx3("GYO_TER"		)[1]+15,"LEFT"},;
				{"GYO_QUA"		,"GYO",GtpxDoW(4,3)				,X3Picture("GYO_QUA"	),TamSx3("GYO_QUA"		)[1]+15,"LEFT"},;
				{"GYO_QUI"		,"GYO",GtpxDoW(5,3)				,X3Picture("GYO_QUI"	),TamSx3("GYO_QUI"		)[1]+15,"LEFT"},;
				{"GYO_SEX"		,"GYO",GtpxDoW(6,3)				,X3Picture("GYO_SEX"	),TamSx3("GYO_SEX"		)[1]+15,"LEFT"},;
				{"GYO_SAB"		,"GYO",GtpxDoW(7,3)				,X3Picture("GYO_SAB"	),TamSx3("GYO_SAB"		)[1]+15,"LEFT"},;
				{"GYO_DOM"		,"GYO",GtpxDoW(1,3)				,X3Picture("GYO_DOM"	),TamSx3("GYO_DOM"		)[1]+15,"LEFT"};
			}				

Case ( cSection == "SEC_ESCDET" )	//SEÇÃO 3: Dados do Escala
	
	aRet := {; 	
				{"GYP_ITEM"		,"GYP",GTPX3TIT("GYP_ITEM"	),X3Picture("GYP_ITEM"	),TamSx3("GYP_ITEM"		)[1]+15,"LEFT"},;
				{"GID_NUMSRV"	,"GID",GTPX3TIT("GID_NUMSRV"),X3Picture("GID_NUMSRV"),TamSx3("GID_NUMSRV"	)[1]+15,"LEFT"},;
				{"GYP_LINCOD"	,"GYP",GTPX3TIT("GYP_LINCOD"),X3Picture("GYP_LINCOD"),TamSx3("GYP_LINCOD"	)[1]+15,"LEFT"},;
				{"GYP_SRVORI"	,"GYP",GTPX3TIT("GYP_SRVORI"),X3Picture("GYP_SRVORI"),TamSx3("GYP_SRVORI"	)[1]+15,"LEFT"},;
				{"GYP_SRVDES"	,"GYP",GTPX3TIT("GYP_SRVDES"),X3Picture("GYP_SRVDES"),TamSx3("GYP_SRVDES"	)[1]+15,"LEFT"},;
				{"GYP_HRINIT"	,"GYP",GTPX3TIT("GYP_HRINIT"),X3Picture("GYP_HRINIT"),TamSx3("GYP_HRINIT"	)[1]+15,"LEFT"},;
				{"GYP_HORORI"	,"GYP",GTPX3TIT("GYP_HORORI"),X3Picture("GYP_HORORI"),TamSx3("GYP_HORORI"	)[1]+15,"LEFT"},;
				{"GYP_HORDES"	,"GYP",GTPX3TIT("GYP_HORDES"),X3Picture("GYP_HORDES"),TamSx3("GYP_HORDES"	)[1]+15,"LEFT"},;
				{"GYP_HRFIMT"	,"GYP",GTPX3TIT("GYP_HRFIMT"),X3Picture("GYP_HRFIMT"),TamSx3("GYP_HRFIMT"	)[1]+15,"LEFT"},;
				{"ESCEXT"		,"GYO","Esc. Extr."			 ,""                      ,20						   ,"LEFT"};
			}	
			
EndCase

Return(aRet)

Static Function ReportPrint(oReport)

Local oSecGrupo		:= oReport:Section(1)	//SEÇÃO 1: 
Local cTmpAlias     := GR302BSetQry()

If (cTmpAlias)->(!Eof())
	oReport:StartPage()

	oSecGrupo:Init()
			
	GR302BPutValues(cTmpAlias, oSecGrupo, "SEC_GRUPO")
			
	oSecGrupo:Finish()

	GR302BSecEscala(cTmpAlias, oSecGrupo, oReport)
Else
	FwAlertWarning("Não há dados para serem apresentados","Atenção")
EndIf
// GR302BDestroy(cTmpAlias)
Return()



Function GR302BSetQry()
Local cTmpAlias	:= ""
Local cQuery	:= ""
Local cSetor	:= GZA->GZA_SETOR
Local cGrupo	:= GZA->GZA_CODIGO
	
	cQuery	+= "SELECT                                                                                                                      	"+Chr(13)+Chr(10)
	cQuery	+= "	GYT.GYT_CODIGO,                                                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "	GI1GYT.GI1_DESCRI as GYT_DESCRI,                                                                                                          "+Chr(13)+Chr(10)
	cQuery	+= "	GZA_CODIGO,                                                                                                                 "+Chr(13)+Chr(10)
	cQuery	+= "	GZA_DESCRI,                                                                                                                 "+Chr(13)+Chr(10)
	cQuery	+= "	GYO.GYO_CODIGO,                                                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "	LTRIM(RTRIM(REPLACE(REPLACE(GYO.GYO_DESCRI,'(','['),')',']'))) as GYO_DESCRI,                                                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "	GYO_HRVOL,                                                                                                                  "+Chr(13)+Chr(10)
	cQuery	+= "	GYO_HRFVOL,                                                                                                                 "+Chr(13)+Chr(10)
	cQuery	+= "	GYO_RHPLAN,                                                                                                                 "+Chr(13)+Chr(10)
	cQuery	+= "	GYO_HRDESP,                                                                                                                 "+Chr(13)+Chr(10)
	cQuery	+= "	GYO_HORAAD,                                                                                                                 "+Chr(13)+Chr(10)
	cQuery	+= "	GYO_HORPAG,                                                                                                                 "+Chr(13)+Chr(10)
	cQuery	+= "	(CASE WHEN GYO.GYO_SEG = 'T' THEN 'S' ELSE 'N' END) AS GYO_SEG,                                                                                                                "+Chr(13)+Chr(10)
	cQuery	+= "	(CASE WHEN GYO.GYO_TER = 'T' THEN 'S' ELSE 'N' END) AS GYO_TER,                                                                                                                "+Chr(13)+Chr(10)
	cQuery	+= "	(CASE WHEN GYO.GYO_QUA = 'T' THEN 'S' ELSE 'N' END) AS GYO_QUA,                                                                                                                "+Chr(13)+Chr(10)
	cQuery	+= "	(CASE WHEN GYO.GYO_QUI = 'T' THEN 'S' ELSE 'N' END) AS GYO_QUI,                                                                                                                "+Chr(13)+Chr(10)
	cQuery	+= "	(CASE WHEN GYO.GYO_SEX = 'T' THEN 'S' ELSE 'N' END) AS GYO_SEX,                                                                                                                "+Chr(13)+Chr(10)
	cQuery	+= "	(CASE WHEN GYO.GYO_SAB = 'T' THEN 'S' ELSE 'N' END) AS GYO_SAB,                                                                                                                "+Chr(13)+Chr(10)
	cQuery	+= "	(CASE WHEN GYO.GYO_DOM = 'T' THEN 'S' ELSE 'N' END) AS GYO_DOM,                                                                                                                "+Chr(13)+Chr(10)
	cQuery	+= "	GYP.GYP_ITEM,                                                                                                               "+Chr(13)+Chr(10)
	cQuery	+= "	GID.GID_NUMSRV,                                                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "	GYP.GYP_LINCOD,                                                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "	LTRIM(RTRIM(REPLACE(REPLACE(GI1ORI.GI1_DESCRI,'(','['),')',']')))  AS GYP_SRVORI,                                             "+Chr(13)+Chr(10)
	cQuery	+= "	LTRIM(RTRIM(REPLACE(REPLACE(GI1DES.GI1_DESCRI,'(','['),')',']')))  AS GYP_SRVDES,                                             "+Chr(13)+Chr(10)
	cQuery	+= "	GYP.GYP_HRINIT,                                                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "	GYP.GYP_HORORI,                                                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "	GYP.GYP_HORDES,                                                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "	GYP.GYP_HRFIMT,                                                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "	GYP.GYP_TIPO,                                                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "	(CASE                                                                                                                       "+Chr(13)+Chr(10)
	cQuery	+= "		WHEN GYP.GYP_TIPO	= '2' AND GYP.GYP_SRVEXT <> ''	THEN GZS.GZS_DESCRI                                                 "+Chr(13)+Chr(10)
	cQuery	+= "		WHEN GYP.GYP_TIPO	= '3'							THEN 'Plantão'                                                      "+Chr(13)+Chr(10)
	cQuery	+= "		WHEN GYP.GYP_TIPO	= '4'							THEN 'Intervalo'                                                    "+Chr(13)+Chr(10)
	cQuery	+= "		WHEN GYP.GYP_PASSAG = '1'							THEN 'Motorista Passageiro'                                         "+Chr(13)+Chr(10)
	cQuery	+= "		WHEN GYP.GYP_TIPO	= '2' AND GYP.GYP_SRVEXT = ''	THEN 'Extraordinario'                                               "+Chr(13)+Chr(10)
	cQuery	+= "		ELSE ''                                                                                                                 "+Chr(13)+Chr(10)
	cQuery	+= "	END) AS ESCEXT,                                                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "	(CASE                                                                                                                       "+Chr(13)+Chr(10)
	cQuery	+= "		WHEN GYPMIN.GYP_ITEM IS NOT NULL AND GYPMAX.GYP_ITEM IS NOT NULL  THEN 'FULL'                                           "+Chr(13)+Chr(10)
	cQuery	+= "		WHEN GYPMIN.GYP_ITEM IS NOT NULL THEN 'MIN'                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "		WHEN GYPMAX.GYP_ITEM IS NOT NULL  THEN 'MAX'                                                                            "+Chr(13)+Chr(10)
	cQuery	+= "		WHEN GYP.GYP_TIPO <> '1' THEN GYP_TIPO                                                                                  "+Chr(13)+Chr(10)
	cQuery	+= "		WHEN GYP.GYP_PASSAG = '1' THEN '6'                                                                                      "+Chr(13)+Chr(10)
	cQuery	+= "		ELSE '0'                                                                                                                "+Chr(13)+Chr(10)
	cQuery	+= "	END) AS MINMAX,                                                                                                             "+Chr(13)+Chr(10)
	cQuery	+= "	(Case                                                                                                                       "+Chr(13)+Chr(10)
	cQuery	+= "		WHEN MINMAX.GYP_MINITEM = GYP.GYP_ITEM THEN 'MIN'                                                                       "+Chr(13)+Chr(10)
	cQuery	+= "		WHEN MINMAX.GYP_MAXITEM = GYP.GYP_ITEM THEN 'MAX'                                                                       "+Chr(13)+Chr(10)
	cQuery	+= "		ELSE ''                                                                                                                 "+Chr(13)+Chr(10)
	cQuery	+= "	End) AS MAXITEM                                                                                                             "+Chr(13)+Chr(10)     
	cQuery	+= "FROM "+RetSqlName('GYT')+" GYT                                                                                                  "+Chr(13)+Chr(10)
	cQuery	+= "	INNER JOIN "+RetSqlName('GI1')+" GI1GYT ON                                                                                  "+Chr(13)+Chr(10)
	cQuery	+= "		GI1GYT.GI1_FILIAL = '"+xFilial('GI1')+"'                                                                                "+Chr(13)+Chr(10)
	cQuery	+= "		AND GI1GYT.GI1_COD = GYT.GYT_LOCALI                                                                                 	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GI1GYT.D_E_L_E_T_ = ' '                                                                                          	"+Chr(13)+Chr(10)
	cQuery	+= "	INNER JOIN "+RetSqlName('GZA')+" GZA ON                                                                                     "+Chr(13)+Chr(10)
	cQuery	+= "		GZA.GZA_FILIAL = '"+xFilial('GZA')+"'                                                                                   "+Chr(13)+Chr(10)
	cQuery	+= "		AND GZA.GZA_SETOR = GYT.GYT_CODIGO                                                                                  	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GZA.D_E_L_E_T_ = ' '                                                                                             	"+Chr(13)+Chr(10)
	cQuery	+= "	INNER JOIN "+RetSqlName('GZB')+" GZB ON                                                                                     "+Chr(13)+Chr(10)
	cQuery	+= "		GZB.GZB_FILIAL = GZA.GZA_FILIAL                                                                                     	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GZB.GZB_GRPCOD =GZA.GZA_CODIGO                                                                                  	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GZB.D_E_L_E_T_ = ' '                                                                                             	"+Chr(13)+Chr(10)
	cQuery	+= "	INNER JOIN "+RetSqlName('GYO')+" GYO ON                                                                                     "+Chr(13)+Chr(10)
	cQuery	+= "		GYO.GYO_FILIAL = '"+xFilial('GYO')+"'                                                                                   "+Chr(13)+Chr(10)
	cQuery	+= "		AND GYO.GYO_SETOR = GYT.GYT_CODIGO                                                                                  	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GYO.GYO_CODIGO = GZB.GZB_ESCALA                                                                                 	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GYO.D_E_L_E_T_ = ' '                                                                                             	"+Chr(13)+Chr(10)
	cQuery	+= "	INNER JOIN "+RetSqlName('GYP')+" GYP ON                                                                                     "+Chr(13)+Chr(10)
	cQuery	+= "		GYP.GYP_FILIAL = GYO_FILIAL                                                                                         	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GYP.GYP_ESCALA = GYO.GYO_CODIGO                                                                                 	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GYP.D_E_L_E_T_ = ' '                                                                                             	"+Chr(13)+Chr(10)
	cQuery	+= "	LEFT JOIN "+RetSqlName('GID')+" GID ON                                                                                      "+Chr(13)+Chr(10)
	cQuery	+= "		GID.GID_FILIAL = '"+xFilial('GID')+"'                                                                                   "+Chr(13)+Chr(10)
	cQuery	+= "		AND GID.GID_COD = GYP.GYP_CODGID                                                                                    	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GID.D_E_L_E_T_ = ' '                                                                                            	"+Chr(13)+Chr(10)
	cQuery	+= "	LEFT JOIN (                                                                                                             	"+Chr(13)+Chr(10)
	cQuery	+= "			SELECT GYP_FILIAL,GYP_ESCALA,GYP_CODGID,MIN(GYP_ITEM) AS GYP_ITEM                                               	"+Chr(13)+Chr(10)
	cQuery	+= "			FROM "+RetSqlName('GYP')+" GYP                                                                                      "+Chr(13)+Chr(10)
	cQuery	+= "				INNER JOIN "+RetSqlName('GZB')+" GZB ON                                                                                        "+Chr(13)+Chr(10)
	cQuery	+= "					GZB.GZB_FILIAL = '"+xFilial('GZB')+"'                                                                       "+Chr(13)+Chr(10)
	cQuery	+= "					AND GZB.GZB_GRPCOD = '"+cGrupo+"'                                                                           "+Chr(13)+Chr(10)
	cQuery	+= "					AND GZB.GZB_ESCALA = GYP.GYP_ESCALA                                                                         "+Chr(13)+Chr(10)
	cQuery	+= "					AND GZB.D_E_L_E_T_  =' '                                                                                     "+Chr(13)+Chr(10)
	cQuery	+= "			WHERE                                                                                                           	"+Chr(13)+Chr(10)
	cQuery	+= "				GYP.GYP_FILIAL = '"+xFilial('GYP')+"'                                                                           "+Chr(13)+Chr(10)
	cQuery	+= "				AND GYP.GYP_TIPO = '1'                                                                                      	"+Chr(13)+Chr(10)
	cQuery	+= "				AND GYP.D_E_L_E_T_ = ' '                                                                                    	"+Chr(13)+Chr(10)
	cQuery	+= "			GROUP BY GYP_FILIAL,GYP_ESCALA,GYP_CODGID                                                                       	"+Chr(13)+Chr(10)
	cQuery	+= "		) GYPMIN ON                                                                                                      	"+Chr(13)+Chr(10)
	cQuery	+= "		GYPMIN.GYP_FILIAL = GYP.GYP_FILIAL                                                                                  	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GYPMIN.GYP_ESCALA = GYP.GYP_ESCALA                                                                              	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GYPMIN.GYP_CODGID = GYP.GYP_CODGID                                                                              	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GYPMIN.GYP_ITEM = GYP.GYP_ITEM                                                                                  	"+Chr(13)+Chr(10)
	cQuery	+= "	LEFT JOIN (                                                                                                             	"+Chr(13)+Chr(10)
	cQuery	+= "			SELECT GYP_FILIAL,GYP_ESCALA,GYP_CODGID,Max(GYP_ITEM) AS GYP_ITEM                                               	"+Chr(13)+Chr(10)
	cQuery	+= "			FROM "+RetSqlName('GYP')+" GYP                                                                                      "+Chr(13)+Chr(10)
	cQuery	+= "				INNER JOIN "+RetSqlName('GZB')+" GZB ON                                                                                        "+Chr(13)+Chr(10)
	cQuery	+= "					GZB.GZB_FILIAL = '"+xFilial('GZB')+"'                                                                       "+Chr(13)+Chr(10)
	cQuery	+= "					AND GZB.GZB_GRPCOD = '"+cGrupo+"'                                                                           "+Chr(13)+Chr(10)
	cQuery	+= "					AND GZB.GZB_ESCALA = GYP.GYP_ESCALA                                                                         "+Chr(13)+Chr(10)
	cQuery	+= "					AND GZB.D_E_L_E_T_  =' '                                                                                     "+Chr(13)+Chr(10)
	cQuery	+= "			WHERE                                                                                                           	"+Chr(13)+Chr(10)
	cQuery	+= "				GYP.GYP_FILIAL = '"+xFilial('GYP')+"'                                                                           "+Chr(13)+Chr(10)
	cQuery	+= "				AND GYP.GYP_TIPO = '1'                                                                                      	"+Chr(13)+Chr(10)
	cQuery	+= "				AND GYP.D_E_L_E_T_ = ' '                                                                                    	"+Chr(13)+Chr(10)
	cQuery	+= "			GROUP BY GYP_FILIAL,GYP_ESCALA,GYP_CODGID                                                                       	"+Chr(13)+Chr(10)
	cQuery	+= "		) GYPMAX ON                                                                                                      	"+Chr(13)+Chr(10)
	cQuery	+= "		GYPMAX.GYP_FILIAL = GYP.GYP_FILIAL                                                                                  	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GYPMAX.GYP_ESCALA = GYP.GYP_ESCALA                                                                              	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GYPMAX.GYP_CODGID = GYP.GYP_CODGID                                                                              	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GYPMAX.GYP_ITEM = GYP.GYP_ITEM                                                                                  	"+Chr(13)+Chr(10)
	cQuery	+= "	LEFT JOIN (                                                                                                             	"+Chr(13)+Chr(10)
	cQuery	+= "			SELECT GYP_FILIAL,GYP_ESCALA,MIN(GYP_ITEM) AS GYP_MINITEM,MAX(GYP_ITEM) AS GYP_MAXITEM                          	"+Chr(13)+Chr(10)
	cQuery	+= "			FROM "+RetSqlName('GYP')+" GYP                                                                                      "+Chr(13)+Chr(10)
	cQuery	+= "				INNER JOIN "+RetSqlName('GZB')+" GZB ON                                                                                        "+Chr(13)+Chr(10)
	cQuery	+= "					GZB.GZB_FILIAL = '"+xFilial('GZB')+"'                                                                       "+Chr(13)+Chr(10)
	cQuery	+= "					AND GZB.GZB_GRPCOD = '"+cGrupo+"'                                                                           "+Chr(13)+Chr(10)
	cQuery	+= "					AND GZB.GZB_ESCALA = GYP.GYP_ESCALA                                                                         "+Chr(13)+Chr(10)
	cQuery	+= "					AND GZB.D_E_L_E_T_  =' '                                                                                     "+Chr(13)+Chr(10)
	cQuery	+= "			WHERE                                                                                                           	"+Chr(13)+Chr(10)
	cQuery	+= "				GYP.GYP_FILIAL = '"+xFilial('GYP')+"'                                                                           "+Chr(13)+Chr(10)
	cQuery	+= "				AND GYP.GYP_TIPO = '1'                                                                                      	"+Chr(13)+Chr(10)
	cQuery	+= "				AND GYP.D_E_L_E_T_ = ' '                                                                                    	"+Chr(13)+Chr(10)
	cQuery	+= "			GROUP BY GYP_FILIAL,GYP_ESCALA                                                                                  	"+Chr(13)+Chr(10)
	cQuery	+= "		) MINMAX ON                                                                                                      	"+Chr(13)+Chr(10)
	cQuery	+= "		MINMAX.GYP_FILIAL = GYP.GYP_FILIAL                                                                                  	"+Chr(13)+Chr(10)
	cQuery	+= "		AND MINMAX.GYP_ESCALA = GYP.GYP_ESCALA                                                                              	"+Chr(13)+Chr(10)
	cQuery	+= "		AND (                                                                                                               	"+Chr(13)+Chr(10)
	cQuery	+= "				(MINMAX.GYP_MINITEM = GYP.GYP_ITEM )                                                                        	"+Chr(13)+Chr(10)
	cQuery	+= "				OR                                                                                                          	"+Chr(13)+Chr(10)
	cQuery	+= "				(MINMAX.GYP_MAXITEM = GYP.GYP_ITEM )                                                                        	"+Chr(13)+Chr(10)
	cQuery	+= "			)	                                                                                                            	"+Chr(13)+Chr(10)
	cQuery	+= "	LEFT JOIN "+RetSqlName('GI1')+" GI1ORI ON                                                                                   "+Chr(13)+Chr(10)
	cQuery	+= "		GI1ORI.GI1_FILIAL = '"+xFilial('GI1')+"'                                                                                "+Chr(13)+Chr(10)
	cQuery	+= "		AND GI1ORI.GI1_COD = GYP.GYP_SRVORI                                                                                 	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GI1ORI.D_E_L_E_T_ = ' '                                                                                         	"+Chr(13)+Chr(10)
	cQuery	+= "	LEFT JOIN "+RetSqlName('GI1')+" GI1DES ON                                                                                   "+Chr(13)+Chr(10)
	cQuery	+= "		GI1DES.GI1_FILIAL = '"+xFilial('GI1')+"'                                                                                "+Chr(13)+Chr(10)
	cQuery	+= "		AND GI1DES.GI1_COD = GYP.GYP_SRVDES                                                                                 	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GI1DES.D_E_L_E_T_ = ' '                                                                                         	"+Chr(13)+Chr(10)
	cQuery	+= "	LEFT JOIN "+RetSqlName('GZS')+" GZS ON                                                                                      "+Chr(13)+Chr(10)
	cQuery	+= "		GZS.GZS_FILIAL = '"+xFilial('GZS')+"'                                                                                   "+Chr(13)+Chr(10)
	cQuery	+= "		AND GZS.GZS_CODIGO = GYP.GYP_SRVEXT                                                                                 	"+Chr(13)+Chr(10)
	cQuery	+= "		AND GZS.D_E_L_E_T_ = ' '                                                                                            	"+Chr(13)+Chr(10)
	cQuery	+= "WHERE                                                                                                                       	"+Chr(13)+Chr(10)
	cQuery	+= "	GYT.GYT_FILIAL = '"+xFilial('GYT')+"'                                                                                       "+Chr(13)+Chr(10)
	cQuery	+= "	AND GYT.GYT_CODIGO = '"+cSetor+"'                                                                                           "+Chr(13)+Chr(10)
	cQuery	+= "	AND GZA_CODIGO = '"+cGrupo+"'                                                                                               "+Chr(13)+Chr(10)
	cQuery	+= "	AND GYT.D_E_L_E_T_ = ' '                                                                                                 	"+Chr(13)+Chr(10)
	cQuery	+= "	                                                                                                                        	"+Chr(13)+Chr(10)
	cQuery	+= "ORDER BY GYT_FILIAL,GYT_CODIGO,GZA_CODIGO,GYO_CODIGO,GYP_ITEM                                                               	"+Chr(13)+Chr(10)

	GTPTemporaryTable(cQuery,,{{"IDX",{"GYT_CODIGO","GZA_CODIGO","GYO_CODIGO","GYP_ITEM"}}},,@oGR302BTable)	//oGR302BTable := GTPTemporaryTable(cQuery,cTmpAlias,{{"IDX",{"GYT_CODIGO","GZA_CODIGO","GYO_CODIGO","GYP_ITEM"}}},/*{{"GYE_DTREF","D",8},{"GYQ_DTINI","D",8},{"GYQ_DTFIM","D",8}}*/)
	cTmpAlias := oGR302BTable:GetAlias()
Return cTmpAlias

// Function GR302BDestroy(cTmpAlias)

// If ( ValType(cTmpAlias) <> "U" .and. Select(cTmpAlias)> 0 )
// 	(cTmpAlias)->(DbCloseArea())
// EndIf

// If ( ValType(oGR302BTable) == "O" )
// 	oGR302BTable:Delete()
// 	GTPDestroy(oGR302BTable)
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
Static Function GR302BPutValues(cAlias, xSection, cSecCell)

Local nI := 0
Local nX := 0 
Local nP := 0

Local cConteudo	:= ""
Local cEscala	:= ""
Local aCells 	:= GR302BCellCollect(cSecCell)
Local cEscExt	:= ""
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
/*/{Protheus.doc} GR302BSecEscala
Realiza impressão da escala

@type 		Function
@author 	Yuki Shiroma	
@since 		22/02/2018
@version 	12.1.7
/*/
//+----------------------------------------------------------------------------------------
Static Function GR302BSecEscala(cTmpAlias, oSecGrupo, oReport)
Local oSecEscCab	:= oSecGrupo:Section(1)	//SEÇÃO 2: 
Local oSecEscDet	:= oSecEscCab:Section(1)//SEÇÃO 3: 

Local nI			:= 0 
Local nItem			:= 0
Local cEscala		:=""
Local cLocOri		:=""
Local cHrIniTrb	    :=""
Local cHrOrigem	    :=""
Local cEscExt		:=""
Local lReset 		:= .T.
Local lIntervalo	:= .F.
(cTmpAlias)->(DbGoTop())	

While (cTmpAlias)->(!EoF())
	If cEscala <> (cTmpAlias)->GYO_CODIGO
		If !Empty(cEscala)
			oSecEscDet:Finish()
		Endif
		//oReport:ThinLine()
		oSecEscCab:Init()
		
		GR302BPutValues(cTmpAlias, oSecEscCab, "SEC_ESCCAB")
		oSecEscCab:Finish()
		oSecEscDet:Init()
		
		cEscala := (cTmpAlias)->GYO_CODIGO
		lReset	:= .T.
		nItem	:= 1
		
	EndIf
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
	
	oSecEscDet:Cell("GYP_ITEM"	):SetValue( StrZero(nItem++,TamSx3('GYP_ITEM')[1]) 		)	
	oSecEscDet:Cell("GID_NUMSRV"):SetValue( (cTmpAlias)->GID_NUMSRV )	
	oSecEscDet:Cell("GYP_LINCOD"):SetValue( (cTmpAlias)->GYP_LINCOD )	
	oSecEscDet:Cell("GYP_HRINIT"):SetValue( cHrIniTrb				)	
	oSecEscDet:Cell("GYP_HORORI"):SetValue( cHrOrigem				)	
	oSecEscDet:Cell("GYP_SRVORI"):SetValue( cLocOri					)	
	oSecEscDet:Cell("GYP_SRVDES"):SetValue( (cTmpAlias)->GYP_SRVDES	)	
	oSecEscDet:Cell("GYP_HORDES"):SetValue( (cTmpAlias)->GYP_HORDES )	
	oSecEscDet:Cell("GYP_HRFIMT"):SetValue( (cTmpAlias)->GYP_HRFIMT )	
	oSecEscDet:Cell("ESCEXT"	):SetValue( (cTmpAlias)->ESCEXT		)	
	
	
	oSecEscDet:PrintLine()

	(cTmpAlias)->(DbSkip())
	If lReset .AND. !lIntervalo
		lReset := .F.
	Endif
EndDo 


Return()
