#INCLUDE "VDFR090.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VDFR090  � Autor � Alexandre Florentino�    Data �  13.03.14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Rela��o de Prazos de F�rias                                  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR090(void)                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���            �          �      �                                          ���
�������������������������������������������������������������������������������
*/

Function VDFR090()

	Local aRegs := {}

	Private oReport
	Private cString	:= "SRA"
	Private cPerg		:= "VDFR090"
	Private aOrd    	:= {}
	Private cTitulo	:= STR0001 //'Controle de F�rias de Servidores'
	Private nSeq 		:= 0
	Private cAliasQRY := ""

	M->RA_FILIAL := ""	// Variavel para controle da numera��o
	
	Pergunte(cPerg, .F.)

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Alexandre FLorentino� Data � 13.03.14   ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Montagem das defini��es do relat�rio                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR090                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR090 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function ReportDef()

	Local cDescri   := STR0004 //"Rela��o de Prazos de F�rias"

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
								/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 2)

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, (oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

	oFilial := TRSection():New(oReport, STR0005, { "SM0" }) //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""

	TRCell():New(oFilial,"RA_FILIAL","SRA")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																 fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

	oFunc := TRSection():New(oFilial, STR0006, ( "SRA","SQ3","SQB","RI5","RI6" )) //'Servidores'
	oFunc:SetCellBorder("ALL",,, .T.)
	oFunc:SetCellBorder("RIGHT")
	oFunc:SetCellBorder("LEFT")
	oFunc:SetCellBorder("BOTTOM")

	nSeq := 0
	TRCell():New(oFunc,	""          ,        "",      'N�'                 ,     "99999",  5, /*lPixel*/,;
							/*bBlock*/ { || 	If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
												AllTrim(Str(++ nSeq)) } ) //Para incluir o n�mero(sequencial) na linha de impress�o
	TRCell():New(oFunc, "RA_MAT"    ,     "SRA", STR0007,, 12) //'Matr�cula'
	TRCell():New(oFunc, "RA_NOME"   ,     "SRA", STR0008,, 30) //'Nome'
	TRCell():New(oFunc,	""          ,        "",STR0018 + Chr(13) + Chr(10) + STR0009,          "",  14, /*lPixel*/,;
							/*bBlock*/ { || StrZero(Month((cAliasQRY)->RF_DATAFIM + 1), 2) + "/" +  StrZero(Year((cAliasQRY)->RF_DATAFIM + 1), 4)},; //'M�s/F�rias em' 'que faz Jus'
							/*cAlign*/ "CENTER")
	TRCell():New(oFunc, "RA_DTNOMEA",     "SRA", STR0010,, 12) //'Nomea��o'
	TRCell():New(oFunc, "RA_CATFUNC",     "SRA", STR0011,, 25) //'Tipo'
	TRCell():New(oFunc, "QB_DESCRIC",     "SQB", STR0012,, 25) //'Lota��o'
	TRCell():New(oFunc, "Q3_DESCSUM",     "SQ3", STR0013,, 20)                                   //'Cargo/Fun��o'
	TRCell():New(oFunc,	""          ,        "", STR0014 + Chr(13) + Chr(10) + STR0015, "", 18, /*lPixel*/,;
							/*bBlock*/ { || Alltrim(Str(year((cAliasQRY)->RF_DATABAS))) + " / " + Alltrim(Str(year((cAliasQRY)->RF_DATAFIM))) },; //'Pr�ximo Per�odo'###'Aquisitivo'
							/*cAlign*/ "CENTER")
	TRCell():New(oFunc,	""          ,        "", STR0016 + Chr(13) + Chr(10) + STR0017, "", 16,;
							/*lPixel*/,/*bBlock*/ { || Alltrim(Str((cAliasQRY)->RF_DIASDIR - (cAliasQRY)->RF_DIASPRG)) },; //'Saldo do Pr�ximo'###'Periodo'
							/*cAlign*/ "CENTER")

Return(oReport)           

/*
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportPrint � Autor � Alexandre Florentino  � Data � 13.03.14 ���
����������������������������������������������������������������������������Ĵ��
���Descri�ao � Impress�o do conte�do do relat�rio                            ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR090                                                       ���
����������������������������������������������������������������������������Ĵ��
���Parametros�                                                               ���
����������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR090 - Generico - Release 4                                ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
*/

Static Function ReportPrint(oReport)

	Local oFilial := oReport:Section(1), oFunc := oReport:Section(1):Section(1), cWhere := "%"
	Local nCont   := 0
	
	cAliasQRY := GetNextAlias()
    	
	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	cMV_PAR := "AND SRA.RA_DEMISSA = '' AND SRA.RA_CATFUNC IN ('2', '3', '5', '6') "
	If !Empty(MV_PAR01)		//-- Filial
		cMV_PAR += " AND " + MV_PAR01
	EndIf

	If !Empty(MV_PAR02)		//-- Matricula
		cMV_PAR += " AND " + MV_PAR02
	EndIf

	If !Empty(MV_PAR03)		//-- Exercicio
		cMV_PAR += " AND " + MV_PAR03
	EndIf
	
	If !Empty(MV_PAR04)		//-- Mes que faz jus
		cMV_PAR += " AND " + " RF_DATAFIM BETWEEN '" + Dtos(FirstDay(Ctod("01/" + Trans(mv_par04, "@R 99/9999")))) + "' AND '" + Dtos(LastDay(Ctod("01/" + Trans(mv_par04, "@R 99/9999")))) + "' "
	EndIf

	cMV_PAR += "%"                                               

	cWhere += cMV_PAR

	oFilial:BeginQuery()
	BeginSql Alias cAliasQRY
		Column RA_DTNOMEA As Date
	
		SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_DTNOMEA, SX5.X5_DESCRI AS RA_CATFUNC, SQB.QB_DESCRIC, SQ3.Q3_DESCSUM, 
			   SRF.RF_DATABAS, SRF.RF_DATAFIM, SRF.RF_DIASDIR, SRF.RF_DIASPRG, SRF.RF_DATABAS
		  FROM %table:SRA% SRA				
		  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO
		  JOIN %table:SQB% SQB ON SQB.%notDel% AND SQB.QB_FILIAL = %Exp:xFilial("SQB")% AND SQB.QB_DEPTO = SRA.RA_DEPTO
		  JOIN %table:SX5% SX5 ON SX5.%notDel% AND SX5.X5_FILIAL = %Exp:xFilial("SX5")% AND SX5.X5_TABELA = %Exp:'28'% 
		   AND SX5.X5_CHAVE = SRA.RA_CATFUNC
		  JOIN %table:SRF% SRF ON SRF.%notDel% AND SRF.RF_FILIAL = SRA.RA_FILIAL AND SRF.RF_MAT = SRA.RA_MAT
		   AND ((SRF.RF_DIASDIR - SRF.RF_DIASPRG) > 0 ) AND SRF.RF_DATAFIM <= %Exp:Dtos(FirstDay(dDataBase))% 
          JOIN %table:SRV% SRV ON SRV.%notDel% AND SRV.RV_FILIAL = %Exp:xFilial("SRV")% AND SRV.RV_COD = SRF.RF_PD AND SRV.RV_CODFOL = %Exp:'0072'%
	 	 WHERE SRA.%notDel% %Exp:cWhere%                                             
	     ORDER BY SRA.RA_FILIAL, SRF.RF_DATABAS, SRA.RA_NOME
	EndSql
	oFilial:EndQuery()
   
   	// FirstDay(dData): retorna o primeiro do mes da data.	
	// FirstDay(CtoD("15/02/08")) -> 01/02/08
	// LastDay(dData): retorna o ultimo dia do mes da data.
	// LastDay(CtoD("15/02/08")) -> 29/02/08
    
	//Filtros:
	//	Lota��o.� RA_DEPTO
	//	M�s de Jus� Se deixar em branco, n�o filtrar por essa informa��o RF_DATAFIM ?
	//	Por Filial e Matricula ( De/at�)�RA_FILIAL e RA_MAT

	oFunc:SetParentQuery()
	oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })
   

	oFilial:Print()
	
Return
