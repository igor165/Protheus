#INCLUDE "rwmake.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"
#INCLUDE "TOTVS.ch"
#INCLUDE "GTPR310.ch"

/*/{Protheus.doc} GTPR310
Rel. Programa de Escala de Veículos
@type function
@author jacomo.fernandes
@since 09/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPR310()
	
Local cPerg := "GTPR310"
	
If Pergunte(cPerg,.T.)
	oReport		:= ReportDef()
	oReport:PrintDialog()
		
EndIf
		
Return
/*/{Protheus.doc} ReportDef
Função responsavel para definição do layout do relatório
@type function
@author jacomo.fernandes
@since 08/10/2018
@version 1.0
@param cAliasTmp, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function ReportDef()
	
	Local oReport
	Local oSecVeiculo
	Local oSecAlocacao
	Local oBreak
	Local cTitulo 	:= '[GTPR310] - '+ STR0022 //"Rel. Programa de Escala de Veículos"
	Local cAliasTmp	:= QryEscala()
	
	SX3->(DBSETORDER(1))
	 
	oReport := TReport():New('GTPR310', cTitulo, , {|oReport| PrintReport(oReport,cAliasTmp)}, STR0023 ,,,.T.  ) //'Este relatório ira imprimir o Programa de Escala de Veículos'
	
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader(.F.)
					
	
	oSecVeiculo := TRSection():New( oReport, "RECURSO" ,{cAliasTmp} )
	TRCell():New(oSecVeiculo, "T9_CODBEM"	, cAliasTmp , STR0024	,"@!"							,TamSX3("GQE_RECURS")[1]+2)//"Cód. Recurso" 
	TRCell():New(oSecVeiculo, "T9_NOME"		, cAliasTmp , STR0025	,"@!"							,TamSX3("T9_NOME")[1]+2) //"Nome do Bem"
	TRCell():New(oSecVeiculo, "T9_POSCONT"	, cAliasTmp , STR0007	,PesqPict('ST9'	,"T9_POSCONT")	,TamSX3("T9_POSCONT")[1]+2)//"KM Inicial"
	TRCell():New(oSecVeiculo, "KM_FINAL"	, cAliasTmp , STR0008	,"@!"							,15)//"KM Final"
	TRCell():New(oSecVeiculo, "MED_LITRO"	, cAliasTmp , STR0009	,"@!"							,15)//"Média Cons./Litro"
	TRCell():New(oSecVeiculo, "OLEO_MOTOR"	, cAliasTmp , STR0010	,"@!"							,80)//"Total Óleo Motor"	
	
	oSecAlocacao 	:= TRSection():New(oSecVeiculo, "ALOCACAO"	, 	{cAliasTmp}  , , .F., .T.)
	
	TRCell():New(oSecAlocacao	, "G55_DTPART"	, cAliasTmp, STR0026	, "@D"			, TamSX3("G55_DTPART")[1]+5)//'Data' 
    TRCell():New(oSecAlocacao	, "G55_HRINI"	, cAliasTmp, STR0011	, "@R 99:99"	, TamSX3("G55_HRINI")[1]+2)//'Hora' 
    TRCell():New(oSecAlocacao	, "GI1_LOCORI"	, cAliasTmp, STR0027	, "@!"			, TamSX3("GI1_DESCRI")[1]+2) //'Origem'
    TRCell():New(oSecAlocacao	, "GI1_LOCDES"	, cAliasTmp, STR0028	, "@!"			, TamSX3("GI1_DESCRI")[1]+2) //'Destino'
    TRCell():New(oSecAlocacao	, "KM_PARCIAL"	, cAliasTmp, STR0014	, "@!"			, 10)//'Km. Parcial'
    TRCell():New(oSecAlocacao	, "KM_INICIO"	, cAliasTmp, STR0015	, "@!"			, 10)//'Km. Inicial'
    TRCell():New(oSecAlocacao	, "KM_FINAL"	, cAliasTmp, STR0008	, "@!"			, 10)//'Km. Final'
    TRCell():New(oSecAlocacao	, "KM_ACUMU"	, cAliasTmp, STR0016	, "@!"			, 30)//'Km. Acumulada'
    TRCell():New(oSecAlocacao	, "SER"			, cAliasTmp, STR0017	, "@!"			, 10)//'Ser/'
    TRCell():New(oSecAlocacao	, "RECEP"		, cAliasTmp, STR0018	, "@!"			, 10)//'Recep.'
    TRCell():New(oSecAlocacao	, "DIESEL"		, cAliasTmp, STR0019	, "@!"			, 10)//'Diesel'
    TRCell():New(oSecAlocacao	, "MOTOR"		, cAliasTmp, STR0020	, "@!"			, 10)//'Motor'
    TRCell():New(oSecAlocacao	, "LIBERACAO"	, cAliasTmp, STR0021	, "@!"			, 10)//'Liberação'
	oSecAlocacao:SetLeftMargin(05) 
	
	oSecAlocacao:Cell("G55_DTPART"):lHeaderSize 					:= .F.
	
Return (oReport)

/*/{Protheus.doc} PrintReport
(long_description)
@type function
@author jacomo.fernandes
@since 09/10/2018
@version 1.0
@param oReport, objeto, (Descrição do parâmetro)
@param cAliasTmp, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function PrintReport( oReport,cAliasTmp )
 
	Local oSecVeiculo 	:= oReport:Section(1)
	Local oSecAlocacao	:= oReport:Section(1):Section(1)
	
	Local cVeiculo		:= ''
	Local nAcumulado	:= 0
	
	Local dDtIni		:= STOD('')
	Local cHrIni		:= ""
	Local cCodOri		:= ""
	Local cDesOri		:= ""
	Local cCodDes		:= ""
	Local cDesDes		:= ""
	Local cKmParc		:= ""
	Local nKMParc		:= 0
	Local cKmAcumu		:= ""
	Local nKmAcumu		:= 0
	
	
	DbSelectArea(cAliasTmp)
	oReport:SetMeter((cAliasTmp)->(ScopeCount()))
	oReport:SetLineHeight(30)
	oReport:lUnderLine := .F.
	
	
	(cAliasTmp)->(dbGoTop())
	While (cAliasTmp)->(!Eof())
		
		If (cAliasTmp)->T9_CODBEM <> cVeiculo
			oSecAlocacao:Finish()
			If !Empty(cVeiculo) 
				oReport:EndPage()
			Endif
			
			cVeiculo := (cAliasTmp)->T9_CODBEM
			
			oSecVeiculo:Init()
			oSecVeiculo:Cell("T9_CODBEM"	):SetValue((cAliasTmp)->T9_CODBEM	)
			oSecVeiculo:Cell("T9_NOME"		):SetValue((cAliasTmp)->T9_NOME		)	
			oSecVeiculo:Cell("T9_POSCONT"	):SetValue((cAliasTmp)->T9_POSCONT	)	
			oSecVeiculo:Cell("KM_FINAL"		):SetValue('')
			oSecVeiculo:Cell("MED_LITRO"	):SetValue('')
			oSecVeiculo:Cell("OLEO_MOTOR"	):SetValue('')	
			oSecVeiculo:PrintLine()
			oSecVeiculo:Finish()				
			oSecAlocacao:Init()
			
			nKmAcumu := 0
		Endif 
		If (cAliasTmp)->TPSEQ <> 'MAX'
			dDtIni		:= (cAliasTmp)->G55_DTPART		
			cHrIni		:= (cAliasTmp)->G55_HRINI	
			cCodOri		:= (cAliasTmp)->G55_LOCORI	
			cDesOri		:= (cAliasTmp)->GI1_LOCORI	
			
			If (cAliasTmp)->TPSEQ == 'MIN'
				WHILE (cAliasTmp)->(!EOF())
					(cAliasTmp)->(dbSkip())
					If (cAliasTmp)->TPSEQ == 'MAX'
						Exit
					Endif
				END
			Endif
		
		Endif
		
		cCodDes		:= (cAliasTmp)->G55_LOCDES
		cDesDes		:= (cAliasTmp)->GI1_LOCDES
		
		If !Empty((cAliasTmp)->GYN_LINCOD)
			nKMParc	:= Posicione('GI4',/*nOrd*/,xFilial('GI4')+(cAliasTmp)->GYN_LINCOD+cCodOri+cCodDes+'2','GI4_KM','GI4LOCHIST' )
			
		ElseIf !Empty((cAliasTmp)->GYN_KMREAL)
			nKMParc	:= (cAliasTmp)->GYN_KMREAL
			
		ElseIf !Empty((cAliasTmp)->GYN_KMPROV)
			nKMParc	:= (cAliasTmp)->GYN_KMPROV
			
		Endif
		
		nKmAcumu	+= nKMParc 
		
		cKmParc		:= Transform(nKMParc	,"@R 999,999,999.99")		
		cKmAcumu	:= Transform(nKmAcumu	,"@R 999,999,999.99")
					
		oSecAlocacao:Cell("G55_DTPART"	):SetValue(dDtIni)
		oSecAlocacao:Cell("G55_HRINI"	):SetValue(cHrIni)
		oSecAlocacao:Cell("GI1_LOCORI"	):SetValue(cDesOri)
		oSecAlocacao:Cell("GI1_LOCDES"	):SetValue(cDesDes)
		oSecAlocacao:Cell("KM_PARCIAL"	):SetValue(cKmParc)
		oSecAlocacao:Cell("KM_ACUMU"	):SetValue(cKmAcumu)
		
		
		oSecAlocacao:Cell("KM_INICIO"	):SetValue('')
		oSecAlocacao:Cell("KM_FINAL"	):SetValue('')
		oSecAlocacao:Cell("SER"			):SetValue('')
		oSecAlocacao:Cell("RECEP"		):SetValue('')
		oSecAlocacao:Cell("DIESEL"		):SetValue('')
		oSecAlocacao:Cell("MOTOR"		):SetValue('')
		oSecAlocacao:Cell("LIBERACAO"	):SetValue('')
		
		
		oSecAlocacao:PrintLine()
		
		(cAliasTmp)->(dbSkip())
	End
	oSecAlocacao:Finish()
	oReport:EndPage()
	
Return

/*/{Protheus.doc} QryEscala
(long_description)
@type function
@author jacomo.fernandes
@since 09/10/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function QryEscala()
Local cFilSt9	:= RTrim(xFilial('GYN'))+'%'
Local cJoinGYU	:= ""
Local cWhereGYU	:= ""
Local cAliasTmp	:= GetNextAlias()

If !Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
	cJoinGYU := " INNER JOIN " + RetSQLName("GYU") +" GYU ON "
	cJoinGYU += " 	GYU.GYU_FILIAL = '"+xFilial('GYU')+"' "
	cJoinGYU += " 	AND GYU.GYU_CODVEI = GQE.GQE_RECURS "
	cJoinGYU += " 	AND GYU.D_E_L_E_T_ = ' ' "
	
	cWhereGYU := " AND GYU.GYU_CODSET BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
ElseIf Empty(MV_PAR03) .AND. !Empty(MV_PAR04)
	cJoinGYU := " LEFT JOIN " + RetSQLName("GYU") +" GYU ON "
	cJoinGYU += " 	GYU.GYU_FILIAL = '"+xFilial('GYU')+"' "
	cJoinGYU += " 	AND GYU.GYU_CODVEI = GQE.GQE_RECURS "
	cJoinGYU += " 	AND GYU.D_E_L_E_T_ = ' ' "
	
	cWhereGYU := " AND (GYU.GYU_CODSET BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
	cWhereGYU += " 	OR GYU.GYU_CODVEI IS NULL) "
Endif
	
cJoinGYU	:= "%"+cJoinGYU+"%"
cWhereGYU	:= "%"+cWhereGYU+"%"

BeginSql Alias cAliasTmp

	 column G55_DTPART as Date
	 Select
		ST9.T9_CODBEM
	  , ST9.T9_POSCONT
	  , ST9.T9_CONTACU
	  , ST9.T9_NOME
	  , G55.G55_DTPART
	  , G55.G55_HRINI
	  , G55.G55_LOCORI
	  , GI1ORI.GI1_DESCRI AS GI1_LOCORI
	  , G55.G55_LOCDES
	  , GI1DES.GI1_DESCRI AS GI1_LOCDES
	  ,
		(
			CASE
				WHEN G55.G55_SEQ    = G55SEQ.MINSEQ
					AND G55.G55_SEQ = G55SEQ.MAXSEQ
					THEN 'ALL'
				WHEN G55.G55_SEQ = G55SEQ.MINSEQ
					THEN 'MIN'
				WHEN G55.G55_SEQ = G55SEQ.MAXSEQ
					THEN 'MAX'
					ELSE ''
			END
		)
		AS TPSEQ
	  , GYN.GYN_TIPO
	  , GYN.GYN_FILPRO
	  , GYN.GYN_OPORTU
	  , GYN.GYN_PROPOS
	  , GYN.GYN_LINCOD
	  , GYN.GYN_CODGID
	  , GYN.GYN_KMPROV
	  , GYN.GYN_KMREAL
	From
		%Table:GYN% GYN
		INNER JOIN
			%Table:G55% G55
			ON
				G55.G55_FILIAL     = GYN.GYN_FILIAL
				and G55.G55_CODVIA = GYN.GYN_CODIGO
				AND G55.%NotDel%
		INNER JOIN
			%Table:GQE% GQE
			ON
				GQE.GQE_FILIAL     = GYN.GYN_FILIAL
				AND GQE.GQE_VIACOD = GYN.GYN_CODIGO
				AND GQE.GQE_SEQ    = G55.G55_SEQ
				AND GQE.GQE_TRECUR = '2'
				AND GQE.GQE_RECURS BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
				AND GQE.%NotDel%
				AND GQE.GQE_TERC IN (' '
								   ,'2')
		INNER JOIN
			%Table:ST9% ST9
			ON
				ST9.T9_FILIAL  LIKE %Exp:cFilSt9%
				AND ST9.T9_CODBEM = GQE.GQE_RECURS
				AND ST9.%NotDel%
		INNER JOIN
			(
				SELECT
					GYNSUB.GYN_FILIAL
				  , GYNSUB.GYN_CODIGO
				  , GQESUB.GQE_RECURS
				  , MIN(G55SUB .G55_SEQ) AS MINSEQ
				  , MAX(G55SUB .G55_SEQ) AS MAXSEQ
				FROM
					%Table:GYN% GYNSUB
					INNER JOIN
						%Table:G55% G55SUB
						ON
							GYNSUB.GYN_FILIAL     = G55SUB.G55_FILIAL
							AND GYNSUB.GYN_CODIGO = G55SUB.G55_CODVIA
							AND G55SUB.%NotDel%
					INNER JOIN
						%Table:GQE% GQESUB
						ON
							GQESUB.GQE_FILIAL     = G55SUB.G55_FILIAL
							AND GQESUB.GQE_VIACOD = G55SUB.G55_CODVIA
							AND GQESUB.GQE_SEQ    = G55SUB.G55_SEQ
							AND GQESUB.GQE_TRECUR = '2'
							AND GQESUB.GQE_RECURS BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06%
							AND GQESUB.%NotDel%
				WHERE
					GYNSUB.GYN_FILIAL = %xFilial:GYN%
					AND GYNSUB.GYN_DTINI BETWEEN %Exp:DtoS(MV_PAR01)% AND %Exp:DtoS(MV_PAR02)%
					AND GYNSUB.%NotDel%
				GROUP BY
					GYNSUB.GYN_FILIAL
				  , GYNSUB.GYN_CODIGO
				  , GQESUB.GQE_RECURS
			)
			G55SEQ
			ON
				G55SEQ.GYN_FILIAL     = GYN.GYN_FILIAL
				AND G55SEQ.GYN_CODIGO = GYN.GYN_CODIGO
				AND
				(
					G55SEQ.MINSEQ    = G55.G55_SEQ
					OR G55SEQ.MAXSEQ = G55.G55_SEQ
				)
		INNER JOIN
			%Table:GI1% GI1ORI
			ON
				GI1ORI.GI1_FILIAL  = %xFilial:GI1%
				AND GI1ORI.GI1_COD = G55.G55_LOCORI
				AND GI1ORI.%NotDel%
		INNER JOIN
			%Table:GI1% GI1DES
			ON
				GI1DES.GI1_FILIAL  = %xFilial:GI1%
				AND GI1DES.GI1_COD = G55.G55_LOCDES
				AND GI1DES.%NotDel% %Exp:cJoinGYU%
	Where
		GYN.GYN_FILIAL = %xFilial:GYN%
		AND GYN.GYN_DTINI BETWEEN %Exp:DtoS(MV_PAR01)% AND %Exp:DtoS(MV_PAR02)%
		AND GYN.%NotDel% %Exp:cWhereGYU%
	ORDER BY
		ST9.T9_CODBEM
	  , G55.G55_DTPART
	  , G55_HRINI
		        
EndSql
  
Return cAliasTmp
