#Include 'Protheus.ch'

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSR465
Este relatório apresenta resultado do calculo da taxa de saude por usuario.
para analise do SIB
   
@param 		Relatorio de Taxa de saúde ANALITICO
@author   	Team TOTVS 
@version  	P12
@since		02/10/2018
/*/


Function PLSR465()

Private oReport
Private oSection1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport	:= ReportDef()


Return


//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportDef
Cria o Treport para impresão para analise do SIB

@param 		Relatorio de Taxa de saúde ANALITICO
@author   	Team TOTVS 
@version  	P12
@since		02/10/2018
/*/


Static Function ReportDef()

Local cReport 	:= "PLSR465"
Local cTitulo 		:= "Relatorio de Taxa de saúde ANALITICO"
Local cDescri 		:= "Este relatório apresenta resultado do calculo da taxa de saude por usuario."
Local oReport 		:= nil
Local aParamBox		:={}
Local aRet			:={}
Local nTamNomBen	:= TamSx3("B3K_NOMBEN")[1]-20
Local nTamMatric	:= TamSx3("B3K_MATRIC")[1]+1
Local nTamCodCco	:= TamSx3("B3K_CODCCO")[1]+1
Local nTamCns		:= TamSx3("B3K_CNS")[1]+1
Local cTxtIdade		:= "Ate 59 anos"



aAdd(aParamBox,{1,"Mes",StrZero(Month(dDataBase), 2),"","","","",0,.T.}) // Tipo caractere
aAdd(aParamBox,{1,"Ano",Year(dDataBase),"","","","",0,.T.}) // Tipo caractere
aAdd(aParamBox,{1,"Operadora",Space(Tamsx3("BA0_SUSEP")[1]),"","","BA0ANS","",0,.T.}) // Tipo caractere

If ParamBox(aParamBox,"Parâmetros",@aRet,,,,,,)
                   
	oReport := TReport():New( cReport, cTitulo,  , { |oReport| ReportPrint( oReport, aRet ) }, cDescri )
	oReport:SetPortrait()
	oReport:SetTotalInLine(.F.)
	oReport:ShowHeader()


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define a 1a. secao do relatorio 						 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	oSection1 := TRSection():New( oReport, "Usuarios", {"TRBQTD" } ,)
	TRCell():New( oSection1, "B3K_MATRIC" 	,"TRBQTD" ,/*X3Titulo*/,/*Picture*/,nTamMatric,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection1, "B3K_MATANT" 	,"TRBQTD" ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection1, "B3K_NOMBEN" 	,"TRBQTD" ,/*X3Titulo*/,/*Picture*/,nTamNomBen,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection1, "B3K_DATNAS"	,"TRBQTD" ,/*X3Titulo*/,PesqPict("B3K","B3K_DATNAS"),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection1, "B3K_DATINC"	,"TRBQTD" ,/*X3Titulo*/,PesqPict("B3K","B3K_DATINC"	),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection1, "B3K_DATREA" 	,"TRBQTD" ,/*X3Titulo*/,PesqPict("B3K","B3K_DATREA"	),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection1, "B3K_DATBLO"	,"TRBQTD" ,/*X3Titulo*/,PesqPict("B3K","B3K_DATBLO"	),/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection1, "B3K_SITANS" 	,"TRBQTD" ,/*X3Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection1, "B3K_CODCCO" 	,"TRBQTD",/*X3Titulo*/,/*Picture*/,nTamCodCco,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New( oSection1, "B3K_CNS"   	,"TRBQTD" ,/*X3Titulo*/,/*Picture*/,nTamCns,/*lPixel*/,/*{|| code-block de impressao }*/)


	oBreak := TRBreak():New(oSection1,{ || TRBQTD->(!Eof()) },"Total======> ") 
	TRFunction():New(oSection1:Cell("B3K_CNS" ),"Total Grupos","COUNT",oBreak,,,,.F.,.T.,.T.) 

	
	oReport:SetTotalText('Total Geral=> ')	

	oReport:PrintDialog()
	

Endif	 
	


Return
 




//-------------------------------------------------------------------------------------
/*/{Protheus.doc} ReportPrint
Cria o Treport para impresão para analise do SIB
   
@param 		Relatorio de Taxa de saúde ANALITICO
@author   	Team TOTVS 
@version  	P12
@since		02/10/2018
/*/


Static Function ReportPrint( oReport , aRet )

Local oSection1 := oReport:Section(1)
Local oBreak1
Local nI				:= 0
Local nFor				:= 0
Local cMes				:= aRet[1]
Local cAno 				:= aRet[2] 
Local cAbrSeg 			:= ""

	
	If VerAbrangencias()
	
		While !TRBABR->(Eof())
			
			
			If VerSegmentos(TRBABR->B4X_CODORI)
	
				While !TRBSEG->(Eof())
									
					cLinSeg := TRBSEG->B4Y_SEGMEN + Space(01) + TRBSEG->B4Y_DESORI + Space(01)
					
					//Quantidade de Beneficiários ativos: 
					CalcQtdBenAtiv(aRet,oReport)
									
					TRBSEG->(dbSkip())
				
				EndDo
				
			EndIf
			
			TRBABR->(dbSkip())
			TRBSEG->(dbCloseArea())
				
		EndDo
	EndIf
	
	TRBABR->(dbCloseArea())
	
	//Imprime rodape do relatorio...
	

Return .T.


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CalcQtdBenAtiv

Funcao cria a area de trabalho TRBABR com as informacoes de todas as abrangencias (BF7)

@param	nOpc		1-Importar carga incial; 2-Reimportar criticados

@return lRet		Indica se foi .T. ou nao .F. encontrado produtos no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function CalcQtdBenAtiv(aRet,oReport)

Local dDatIni := cToD("")
Local dDatFim := cToD("")
Local nQtd1MAte60 := 0
Local nQtd1MMai60 := 0
Local nPerSeg := TRBSEG->B4Y_PERDES
Local nPerAbr := TRBABR->B4X_PERDES
Local cOper    := aRet[3]

//1 - No primeiro mês do trimestre
dDatIni := cToD("01/" + aRet[1] + "/"+ Str(aRet[2]))
dDatFim := Lastday(dDatIni, 0)

//1.1 - Com Menos de 60 Anos
nQtd1MAte60 := RetQtdBenef( cOper, dDatIni , dDatFim , .T.,TRBABR->B4X_CODORI,;
				TRBSEG->B4Y_SEGMEN,oReport )
					
//1.2 - Com Mais de 60 Anos
	
nQtd1MMai60 := RetQtdBenef(cOper,dDatIni , dDatFim , .F. ,TRBABR->B4X_CODORI,;
				TRBSEG->B4Y_SEGMEN,oReport )
				
Return

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} RetQtdBenef

Funcao cria a area de trabalho TRBABR com as informacoes de todas as abrangencias (BF7)

@param	nOpc		1-Importar carga incial; 2-Reimportar criticados

@return lRet		Indica se foi .T. ou nao .F. encontrado produtos no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Static Function RetQtdBenef(cCodOpe,dDatIni,dDatFim,lAte60,cAbrang,cSegmen,oReport)
Local cDataBase	:= DTOS(dDataBase)
Local cSql := ""
Local nQtd := 0
Local cTIPODB 	:= Alltrim(Upper(TCGetDb()))
Local oSection1 := oReport:Section(1)
local aCODCCO	:={}
Local cTipo		:= '1'
Local cStatus	:= '1'
Local nMesRel	:=Month(dDatIni)
Local dDatLim

Default cCodOpe := ""
Default dDatIni := CTOD("")
Default dDatFim := CTOD("")
Default lAte60 := .F.

If !Empty(dDatIni)

//VERIFICAR QUAL PERIODO ESTA SENDO CALCULADO PARA SETAR A DDATLIM
	If nMesRel == 12 .or. nMesRel == 1 .or. nMesRel == 2
		dDatLim := DTOS(Lastday(cToD("01/02/" + Right(DTOC(dDatFim),4)), 0))
	ElseIf 	nMesRel > 2 .AND. nMesRel < 6
		dDatLim := DTOS(Lastday(cToD("01/05/" + Right(DTOC(dDatFim),4)), 0))
	elseif nMesRel > 5 .AND. nMesRel < 9
		dDatLim := DTOS(Lastday(cToD("01/08/" + Right(DTOC(dDatFim),4)), 0))
	else
		dDatLim := DTOS(Lastday(cToD("01/11/" + Right(DTOC(dDatFim),4)), 0))	
	EndIf
	
	cSQL := " SELECT DISTINCT B3K_MATRIC, B3K_MATANT, B3K_NOMBEN, B3K_DATNAS, B3K_DATINC, B3K_DATREA, B3K_DATBLO, B3K_ATUCAR, B3K_SITANS, B3K_STASIB, B3K_STATUS, B3K_CNS, B3K_CODCCO  "
	cSQL += " FROM " + RetSqlName("B3K") + " B3K "
	cSQL += " LEFT OUTER JOIN " + RetSqlName("B4W") + " B4W ON B3K_FILIAL=B4W_FILIAL AND B3K_MATRIC = B4W_MATRIC AND B4W.D_E_L_E_T_ = '' ," + RetSqlName("B3J") +   " B3J," + RetSqlName("B3W") + " B3W "
	cSQL += " WHERE "
	cSQL += " 	B3K_FILIAL = '" + xFilial('B3K') + "' "
	cSQL += " 	AND B3J_FILIAL = '" + xFilial('B3J') + "' "
	cSQL += " 	AND B3W_FILIAL = '" + xFilial('B3W') + "' "
	cSQL += " 	AND B3K_CODPRO = B3J_CODIGO "
	cSQL += " 	AND B3K_CODCCO = B3W_CODCCO "
	cSQL += " 	AND B3K_CODCCO <> ' ' "
	cSQL += " 	AND B3K_CODOPE = '" + cCodOpe + "' "
	cSQL += " 	AND B3J_ABRANG ='" + cAbrang + "'"
	cSQL += " 	AND B3J_SEGMEN ='" + cSegmen + "'"

	If cTIPODB $ "MSSQL/MSSQL7"
		cSQL += " AND  ( YEAR('" + dDatLim + "')-YEAR(B3K_DATNAS)-IIF(MONTH('" + dDatLim + "')*32+DAY('" + dDatLim + "')<MONTH(B3K_DATNAS)*32+DAY(B3K_DATNAS),1,0) )" + IIf(lAte60,"<",">=") + " '60' " + CRLF
	ElseIf cTIPODB $ "POSTGRES"
		cSQL += " AND DATE_PART('YEAR', AGE('" + dDatLim + "',  TO_DATE(CONCAT(SUBSTRING(B3K_DATNAS,1,4),'-',SUBSTRING(B3K_DATNAS,5,2),'-',SUBSTRING(B3K_DATNAS,7,2)), 'YYYY/MM/DD')	))" + IIf(lAte60,"<",">=") + " 60 " + CRLF
	Else
		cSQL += " AND EXTRACT(YEAR FROM TO_DATE('" + dDatLim + "', 'YYYY-MM-DD')) - EXTRACT(YEAR FROM TO_DATE(B3K_DATNAS, 'YYYY-MM-DD')) - CASE WHEN EXTRACT(MONTH FROM TO_DATE('" + dDatLim + "', 'YYYY-MM-DD'))*32+EXTRACT (DAY FROM TO_DATE('" + dDatLim + "', 'YYYY-MM-DD')) < EXTRACT(MONTH FROM TO_DATE(B3K_DATNAS, 'YYYY-MM-DD'))*32+EXTRACT (DAY FROM TO_DATE(B3K_DATNAS, 'YYYY-MM-DD')) THEN 1 ELSE 0 END " + IIf(lAte60,"<",">=") + " 60 " + CRLF
	EndIf
	
	cSQL += " 	AND ((SELECT COUNT(*) FROM " + RetSqlName("B4W") + " B4W2 "
	cSQL += " 		WHERE   B4W2.B4W_DATA <= '" + DTOS(dDatFim) + "' "
	cSQL += " 			AND B4W2.B4W_TIPO = '0' "
	cSQL += "			AND B4W2.B4W_STATUS = '1' "
	cSQL += "			AND B4W2.D_E_L_E_T_ = ' ' "
	cSQL += "           AND B4W2.B4W_MATRIC = B3K_MATRIC) = 0"

	cSQL += " 	AND ((SELECT COUNT(*) FROM " + RetSqlName("B4W") + " B4W2 "
	cSQL += " 		WHERE   B4W2.B4W_DATA <= '" + DTOS(dDatFim) + "' "
	cSQL += " 			AND B4W2.B4W_TIPO = '1' "
	cSQL += "			AND B4W2.B4W_STATUS = '1' "
	cSQL += "			AND B4W2.D_E_L_E_T_ = ' ' "
	cSQL += "			AND B4W2.B4W_MATRIC = B3K_MATRIC) >= 1) "
	
	cSQL += " 	OR ((SELECT COUNT(*) FROM " + RetSqlName("B4W") + " B4W2 "
	cSQL += " 		WHERE   B4W2.B4W_DATA <= '" + DTOS(dDatFim) + "' "
	cSQL += " 			AND B4W2.B4W_TIPO = '0' "
	cSQL += "			AND B4W2.B4W_STATUS = '1' "
	cSQL += "			AND B4W2.D_E_L_E_T_ = ' ' "
	cSQL += "			AND B4W2.B4W_MATRIC = B3K_MATRIC) =  "
	cSQL += "			(SELECT COUNT(*) FROM " + RetSqlName("B4W") + " B4W2 "
	cSQL += " 				WHERE  B4W2.B4W_DATA <= '" + DTOS(dDatFim) + "' "
	cSQL += " 				AND B4W2.B4W_TIPO = '1' "
	cSQL += "				AND B4W2.B4W_STATUS = '1' "
	cSQL += "				AND B4W2.B4W_MATRIC = B3K_MATRIC "
	cSQL += "				AND B4W2.D_E_L_E_T_ = ' ' )))" 
	cSQL += "	AND B3K.B3K_DATINC <= '" + DTOS(dDatFim) + "' "
	cSQL += "	AND (B3K.B3K_SITANS IN (' ','A')  OR (B3K.B3K_SITANS ='I' AND  B3K.B3K_DATBLO >= '" + DTOS(dDatFim) + "'  ) )"
	cSQL += "	AND B3K.D_E_L_E_T_ = '' "
	cSQL += "	AND B3J.D_E_L_E_T_ = '' "
	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBQTD",.F.,.T.)
	
	If TRBQTD->(Eof())
		TRBQTD->(DbCloseArea())
		Return 0
	Endif	

	oSection1:Init()
	oSection1:SetHeaderSection(.T.)
	
	oReport:IncMeter()
	
	B4W->(dBsetorder(1))

	
	While TRBQTD->(!Eof())
	
		If oReport:Cancel()
			Exit
		EndIf
		oSection1:PrintLine()
		nQtd++
	   TRBQTD->(DbSkip())
	EndDo
	
	oReport:Section(1):Finish()

	TRBQTD->(DbCloseArea())

EndIf

Return nQtd


//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VerAbrangencias

Funcao cria a area de trabalho TRBABR com as informacoes de todas as abrangencias (BF7)

@param	nOpc		1-Importar carga incial; 2-Reimportar criticados

@return lRet		Indica se foi .T. ou nao .F. encontrado produtos no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function VerAbrangencias()
Local cSql	:= ''
Local lRet	:= .F.

cSql += "SELECT DISTINCT B4X_CODORI, B4X_DESORI, B4X_PERDES "
cSql += "FROM " + RetSqlName("B4X") + " B4X " 
cSql += "WHERE B4X_FILIAL = '" + xFilial('B4X') + "' "
cSql += "AND B4X.D_E_L_E_T_ = ' ' "

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBABR",.F.,.T.)

If TRBABR->(Eof())
	lRet := .F.
Else
	lRet := .T.
EndIf

Return lRet

//--------------------------------------------------------------------------------------------------
/*/{Protheus.doc} VerSegmentos

Funcao cria a area de trabalho TRBSEG com as informacoes de todos os segmentos (BI6)

@param	nOpc		1-Importar carga incial; 2-Reimportar criticados

@return lRet		Indica se foi .T. ou nao .F. encontrado produtos no PLS

@author TOTVS PLS Team
@since 26/01/2016
/*/
//--------------------------------------------------------------------------------------------------
Function VerSegmentos(cAbrang)
Local cSql	:= ''
Local lRet	:= .F.
Default cAbrang	:= ""

If !Empty(cAbrang)
	cSql += "SELECT DISTINCT B4Y_SEGMEN, B4Y_DESORI, B4Y_PERDES "
	cSql += "FROM " + RetSqlName("B4Y") + " B4Y, " + RetSqlName('B3J') + " B3J " 
	cSql += "WHERE B4Y_FILIAL = '" + xFilial('B4Y') + "' "
	cSql += "AND B3J_FILIAL = '" + xFilial('B3J') + "' "
	cSql += "AND B4Y_SEGMEN = B3J_SEGMEN "
	cSql += "AND B3J_ABRANG = '" + cAbrang + "' "
	cSql += "AND B4Y.D_E_L_E_T_ = ' ' "
	cSql += "AND B3J.D_E_L_E_T_ = ' ' "
	
	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TRBSEG",.F.,.T.)
	
	If TRBSEG->(Eof())
		lRet := .F.
	Else
		lRet := .T.
	EndIf
EndIf

Return lRet
