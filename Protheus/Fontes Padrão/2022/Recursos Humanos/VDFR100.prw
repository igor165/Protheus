#INCLUDE "VDFR100.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VDFR100  � Autor � Alexandre Florentino�    Data �  26.02.14 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Rela��o de Servidores Afastamentos                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR100(void)                                                ���
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

Function VDFR100()

Local aRegs := {}

Private oReport
Private	cString		:= "SR8"
Private cPerg		:= "VDFR100"
Private aOrd    	:= {}
Private cTitulo		:= STR0001 //'Rela��o de Servidores Afastados'
Private nSeq 		:= 0
Private cAliasQRY 	:= ""

	Pergunte(cPerg, .F.)

M->RA_FILIAL := ""	// Variavel para controle da numera��o

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Alexandre Florentino�    Data � 26.02.14���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Montagem das defini��es do relat�rio                         ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR100                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR100 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ReportDef()

	Local cDescri   := STR0002 //"Esse relat�rio ser� emitido com base nas informa��es contidas no cadastro de Licen�as e Afastamentos."

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
								/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 2)

	oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, (oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

	oFilial := TRSection():New(oReport, STR0010, { "SM0" }) //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""

	TRCell():New(oFilial,"R8_FILIAL","SR8")	
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->R8_FILIAL, nSeq := 0, Nil),;
																 	 fDesc("SM0", cEmpAnt + (cAliasQry)->(R8_FILIAL), "M0_NOMECOM")) } )

	oFunc := TRSection():New(oFilial, STR0003, ( "SRA","SR8","SQ3","RCM","SR8" )) //'Servidores'

	nSeq := 0

	TRCell():New(oFunc,	"","",'N�', "99999", 5, /*lPixel*/,/*bBlock*/ { || AllTrim(Str(++ nSeq)) } ) //Para incluir o n�mero(sequencial) na linha de impress�o
	TRCell():New(oFunc,"RA_MAT","SRA",STR0004,,10)             //'Matr�cula'
	TRCell():New(oFunc,"RA_NOME","SRA",STR0005,, 35) //'Nome'
	TRCell():New(oFunc,"Q3_DESCSUM","SQ3",STR0006,, 35) //'Cargo/Fun��o'
	TRCell():New(oFunc,"RCM_DESCRI","RCM",STR0007,, 55) //'Tipo Afastamento'
	TRCell():New(oFunc,"R8_DATAINI","SR8",STR0008, /*cPicture*/, 10, /*lPixel*/, /*bBlock*/, "CENTER") //'Data Inicio'
	TRCell():New(oFunc,"R8_DATAFIM","SR8",STR0009, /*cPicture*/, 10, /*lPixel*/, /*bBlock*/, "CENTER") //'Data Fim'

Return(oReport)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportPrint � Autor � Wagner Mobile Costa  � Data � 01.01.14 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Impress�o do conte�do do relat�rio                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR100                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR100 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function ReportPrint(oReport)

	Local oFilial := oReport:Section(1), oFunc := oReport:Section(1):Section(1), cWhere := "%"
	Local cRI6_DTSQL := cRA_CATFUN := "", nTRACATFUN := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" ), nCont := 0
	Local nTamCodAfas := GetSx3Cache( "R8_TIPOAFA", "X3_TAMANHO" )

	cAliasQRY := GetNextAlias()

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	cMV_PAR := ""

	If !Empty(MV_PAR01)		//-- Filial
		cMV_PAR += " AND " + MV_PAR01
	EndIf

	If !Empty(MV_PAR02)		//-- Matricula
		cMV_PAR += " AND " + MV_PAR02
	EndIf

	If !Empty(MV_PAR03)		//-- Exercicio
		cMV_PAR += " AND " + MV_PAR03
	EndIf
    
	If !Empty(MV_PAR04)		//-- Exercicio
		cMV_PAR += " AND " + MV_PAR04
	EndIf

	//-- Monta a string de Codigos de Afastamentos para Impressao
	If AllTrim( mv_par05 ) <> Replicate("*", Len(AllTrim( mv_par05 )))
		cCodAfas   := ""
		
		For nCont  := 1 to Len(Alltrim(mv_par05)) Step nTamCodAfas
			cCodAfas += "'" + Substr(mv_par05, nCont, nTamCodAfas) + "',"
		Next
	
		cCodAfas := Substr( cCodAfas, 1, Len(cCodAfas)-1)
	   	
		If !Empty(AllTrim(cCodAfas))
			cMV_PAR += ' AND SR8.R8_TIPOAFA IN (' + cCodAfas + ')'
		EndIf	
	EndIf
	
	//-- Monta a string com as categorias a serem listadas
	If AllTrim( mv_par06 ) <> Replicate("*", Len(AllTrim( mv_par06 )))
		cRA_CATFUN   := ""
		For nCont  := 1 to Len(Alltrim(mv_par06)) Step nTRACATFUN
			If Substr(mv_par06, nCont, nTRACATFUN) <> Replicate("*", Len(Substr(mv_par06, nCont, nTRACATFUN)))
				cRA_CATFUN += "'" + Substr(mv_par06, nCont, nTRACATFUN) + "',"
			EndIf
		Next
		cRA_CATFUN := Substr( cRA_CATFUN, 1, Len(cRA_CATFUN)-1)
	
		If ! Empty(AllTrim(cRA_CATFUN))
			cMV_PAR += 'AND SRA.RA_CATFUNC IN (' + cRA_CATFUN + ')'
		EndIf
	EndIf
	
	cMV_PAR += "%"

	cWhere += cMV_PAR

	oFilial:BeginQuery()
		BeginSql Alias cAliasQRY

			SELECT SR8.R8_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SQ3.Q3_DESCSUM, RCM.RCM_DESCRI, SR8.R8_DATAINI, SR8.R8_DATAFIM
			  FROM %table:SR8% SR8
			  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL  = SR8.R8_FILIAL AND SRA.RA_MAT = SR8.R8_MAT 
			  JOIN %table:RCM% RCM ON RCM.%notDel% AND RCM.RCM_FILIAL = %Exp:xFilial("RCM")% AND RCM.RCM_TIPO = SR8.R8_TIPOAFA 
			  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL  = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO 
			 WHERE SR8.%notDel% %Exp:cWhere%  
		 	 ORDER BY SR8.R8_FILIAL, SR8.R8_DATAINI
		
		EndSql
	oFilial:EndQuery()

	oFunc:SetParentQuery()
	oFunc:SetParentFilter({|cParam| (cAliasQRY)->R8_FILIAL == cParam}, {|| (cAliasQRY)->R8_FILIAL  })

	oFilial:Print()

Return