#INCLUDE "VDFR340.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VDFR340  � Autor � Alexandre Florentino  � Data �  20.02.14  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Relat�rio de Admitidos                                      ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR340(void)                                                ���
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
Function VDFR340()

	Local aRegs := {}
	
	Private oReport
	Private cString	:= "SRA"
	Private cPerg	  	:= "VDFR340"
	Private cTitulo	:= STR0001 //'Relat�rio de Admitidos'
	Private nSeq 	  	:= 0
	Private cAliasQRY	:= ""


	Pergunte(cPerg, .F.)

	M->RA_FILIAL := ""	// Variavel para controle da numera��o

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Alexandre Florentino  � Data � 20.02.14 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Montagem das defini��es do relat�rio                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR340                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR340 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ReportDef()

Local cDescri := STR0002 //"O relat�rio deve apresentar informa��es das admiss�es dentro do per�odo selecionado."

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri)
	oReport:nFontBody := 7

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish(),;
														 oReport:Section(1):Section(1):Init(), oReport:Section(1):Section(1):PrintLine(),;
														 oReport:Section(1):Section(1):Finish()), .F.) })

	oFilial := TRSection():New(oReport, STR0003, { "SM0" }) //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""
	oFilial:nLinesBefore   := 0

	TRCell():New(oFilial,"RA_FILIAL","SRA")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																	 fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

	oFunc := TRSection():New(oFilial, STR0004, ( "SRA","SQ3","SQB" )) //'Servidores'

	nSeq := 0

	TRCell():New(oFunc,	"","",'N�', "99999", 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } ) //Para incluir o n�mero(sequencial) na linha de impress�o
	TRCell():New(oFunc,"RA_NOME","SRA",STR0005) //'Nome'
	TRCell():New(oFunc,"Q3_DESCSUM","SQ3",STR0006)       //-- Cargo //'Cargo'
	TRCell():New(oFunc,"X5_DESCRI","SRA",STR0007,, 60)    //-- Situa��o //'Situa��o'
	TRCell():New(oFunc,"RA_ADMISSA","SRA",STR0010)	// 'Data da' + Chr(13) + Chr(10) + 'Admiss�o'
	TRCell():New(oFunc,"RA_SALARIO","SRA",STR0008) //-- 'Remunera��o'
    
	//  RA_NOME  | Q3_DESCSUM | RA_CATFUNC | RA_ADMISSA | RA_SALARIO

Return(oReport)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportPrint � Autor � Alexandre Florentino � Data � 20.02.14 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Impress�o do conte�do do relat�rio                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR340                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR340 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ReportPrint(oReport)
    
	Local cIdFol := cRF_TIPOSQL := cRA_CATFUN := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" ), nCont := 0
	Local oFilial := oReport:Section(1), oFunc := oReport:Section(1):Section(1) , cWhere := "%" 
     
	If Empty(mv_par03)
		MsgInfo(STR0009) //'Aten��o. E obrigat�rio selecionar a competencia !'
		Return 
	EndIF
	
	cAliasQRY := GetNextAlias()
		
	oReport:SetTitle(cTitulo + " [" + Trans(mv_par03, "@R 99/9999") + "]")

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)
    
	If !Empty(MV_PAR01)		//-- Filial
		cWhere += " AND " + MV_PAR01
	EndIf

	If !Empty(MV_PAR02)		//-- Matricula
		cWhere += " AND " + MV_PAR02
	EndIf                                                                                               

	If !Empty(MV_PAR03)		//-- Compet�ncia da Admiss�o
		cWhere += " AND SRA.RA_ADMISSA BETWEEN '" + Right(MV_PAR03, 4) + Left(MV_PAR03, 2) + "01' AND '" + Right(MV_PAR03, 4) + Left(MV_PAR03, 2) + "31'"
	EndIf
    
	If !Empty(MV_PAR04)		//-- Tipo de Cargo
		cWhere += " AND " + MV_PAR04
	EndIf
    
	//-- Monta a string com as categorias a serem listadas
	If AllTrim( mv_par05 ) <> Replicate("*", Len(AllTrim( mv_par05 )))
		cRA_CATFUN   := ""
		
		For nCont  := 1 to Len(Alltrim(mv_par05)) Step nTRACATFUN
			If Substr(mv_par05, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(mv_par05, nCont, nTRACATFUN)))
				cRA_CATFUN += "'" + Substr(mv_par05, nCont, nTRACATFUN) + "',"
			EndIf
		Next
	
		cRA_CATFUN := Substr( cRA_CATFUN, 1, Len(cRA_CATFUN)-1)

		If ! Empty(AllTrim(cRA_CATFUN))
			cWhere += ' AND SRA.RA_CATFUNC IN (' + cRA_CATFUN + ')'
		EndIf
	EndIf

	cWhere += "%"

	oFilial:BeginQuery()
	BeginSql Alias cAliasQRY
		COLUMN RA_ADMISSA AS DATE
			
		SELECT SRA.RA_FILIAL, SRA.RA_NOME, SQ3.Q3_DESCSUM, SX5.X5_DESCRI, SRA.RA_ADMISSA, SRA.RA_SALARIO
		  FROM %table:SRA% SRA
		  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO LEFT 
		  JOIN %table:SX5% SX5 ON SX5.%notDel% AND SX5.X5_FILIAL = %Exp:xFilial("SX5")% AND SX5.X5_TABELA = %Exp:'28'% 
		   AND SX5.X5_CHAVE = SRA.RA_CATFUNC 
		 WHERE SRA.%notDel% %Exp:cWhere%
		 UNION ALL
		SELECT SRA.RA_FILIAL, SRA.RA_NOME, SQ3.Q3_DESCSUM, SX5.X5_DESCRI, SR7.R7_DATA, SR3.R3_VALOR
		  FROM %table:SR7% SR7
		  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SR7.R7_FILIAL AND SRA.RA_MAT = SR7.R7_MAT 
		  JOIN %table:SR3% SR3 ON SR3.%notDel% AND SR3.R3_FILIAL = SR7.R7_FILIAL AND SR3.R3_MAT = SR7.R7_MAT AND SR3.R3_DATA = SR7.R7_DATA 
		   AND SR3.R3_TIPO = %Exp:'004'%
		  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO LEFT 
		  JOIN %table:SX5% SX5 ON SX5.%notDel% AND SX5.X5_FILIAL = %Exp:xFilial("SX5")% AND SX5.X5_TABELA = %Exp:'28'% 
		   AND SX5.X5_CHAVE = SRA.RA_CATFUNC 
	 	 WHERE SRA.%notDel% %Exp:cWhere% AND SR7.R7_TIPO = %Exp:'004'%
		 ORDER BY RA_FILIAL, X5_DESCRI, RA_ADMISSA, RA_NOME
	EndSql
		
		//- Filtros
	
		//-	Situa��o (categorias)(RA_CATFUNC)

		//-	Cargo ( De/At� )(RA_CARGO)
        
	oFilial:EndQuery()

	oFunc:SetParentQuery()
	oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

	oFilial:Print()
Return