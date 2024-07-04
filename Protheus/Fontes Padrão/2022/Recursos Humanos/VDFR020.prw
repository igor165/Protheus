#Include "VDFR020.Ch"
#Include "Totvs.Ch"
#Include "Report.Ch"

Static aCellPDF := {}

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � VDFR020  � Autor � Robson Soares Morais  � Data �  03.12.13  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Relat�rio de Jornada dos Servidores                          ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR020(void)                                                ���
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

Function VDFR020()

Private oReport
Private cString	:= "SRA"
Private cPerg		:= "VDFR020"
Private aOrd    	:= {}
Private cTitulo	:= STR0001 //'Relat�rio de Jornada dos Servidores'
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
���Fun�ao    � ReportDef  � Autor � Robson Soares Morais  � Data � 03.12.13 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Montagem das defini��es do relat�rio VDFR020                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR020                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR020 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function ReportDef()

Local cDescri := STR0001 //"Relat�rio de Jornada dos Servidores"
Local cWhere 	:= ''

oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri,;
							/*lLandscape*/,/*uTotalText*/,/*lTotalInLine*/,/*cPageTText*/,/*lPageTInLine*/,/*lTPageBreak*/,/*nColSpace*/ 2)

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

oFilial := TRSection():New(oReport, STR0002, { "SM0" }) //'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""

TRCell():New(oFilial,"RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM") } )

oFunc := TRSection():New(oFilial, STR0003, ( "SRA","SQB","SQ3","SPF" )) //'Servidores'

nSeq := 0
TRCell():New(	oFunc,	"","",'N�', "99999", 5, /*lPixel*/,;
				/*bBlock*/ { || (	If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
									AllTrim(Str(++ nSeq))) } ) //Para incluir o n�mero(sequencial) na linha de impress�o
VdfAjuPDF(TRCell():New(oFunc,"RA_MAT","SRA",STR0010,, 11,  /*lPixel*/, /*bBlock*/, "CENTER"), 4, .T.) //'Matricula'
VdfAjuPDF(TRCell():New(oFunc,"RA_NOME","SRA",STR0004,, 32), 3) //'Nome'
TRCell():New(oFunc,"RA_JORNRED","SRA",STR0012,"@E 99 h", 12) //'Jornada'
VdfAjuPDF(TRCell():New(oFunc,"RA_CATFUNC","SRA",STR0005,, 32), 4, .F.) //'Tipo'
VdfAjuPDF(TRCell():New(oFunc,"QB_DESCRIC","SQB",STR0006,, 32), 6, .F.) //'Lota��o'
VdfAjuPDF(TRCell():New(oFunc,"Q3_DESCSUM","SQ3",STR0007,, 32), 8, .F.) //'Cargo/Fun��o'
VdfAjuPDF(TRCell():New(oFunc,"PF_DATA","SPF",STR0008, "@D", 11,/*lPixel*/, /*bBlock*/, "CENTER"), 2) //'Data Concess�o'  

Return(oReport)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportPrint � Autor � Robson Soares Morais � Data � 05.12.13 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Impress�o do conte�do do relat�rio                           ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR020                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR020 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function ReportPrint(oReport)

Local oFilial := oReport:Section(1), oFunc := oReport:Section(1):Section(1)
Local cJoinSQ3	 := ""
Local cJoinSQB	 := ""
Local cJoinSX5	 := ""
Local nReg 		 := 0

cAliasQRY := GetNextAlias()
	    
If mv_par04 == 1 //30 Horas
	cWhere := "%SRA.RA_JORNRED = 30"
ElseIf mv_par04 == 2 //35 Horas
	cWhere := "%SRA.RA_JORNRED = 35"
ElseIf mv_par04 == 3 //40 Horas
	cWhere := "%RA_HRSEMAN = 40 and (RA_JORNRED = 0 or RA_JORNRED = 40)"
Else
	cWhere := "%(SRA.RA_JORNRED IN (30,35) OR SRA.RA_HRSEMAN = 40)"
EndIf		

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

cMV_PAR := ""
if !empty(MV_PAR01)
	cMV_PAR += " AND " + MV_PAR01
EndIf
if !empty(MV_PAR02)
	cMV_PAR += " AND " + MV_PAR02
EndIf
if !empty(MV_PAR03)
	cMV_PAR += " AND " + MV_PAR03
EndIf
cMV_PAR += "%"

cWhere += cMV_PAR  

cCategoria	:= MV_PAR05
cCatQuery := ""
For nReg:=1 to Len(cCategoria)
	cCatQuery += "'"+Subs(cCategoria,nReg,1)+"'"
	If ( nReg+1 ) <= Len(cCategoria)
		cCatQuery += "," 
	EndIf
Next nReg
cCatQuery := "%" + cCatQuery + "%"	            

cJoinSQ3 := "%" + FWJoinFilial("SQ3","SRA") + "%"
cJoinSQB := "%" + FWJoinFilial("SQB","SRA") + "%"
cJoinSX5 := "%" + FWJoinFilial("SX5","SRA") + "%"

oFilial:BeginQuery()
BeginSql Alias cAliasQRY
	Column PF_DATA AS DATE

	SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, CASE WHEN SRA.RA_JORNRED > 0 THEN SRA.RA_JORNRED ELSE SRA.RA_HRSEMAN END AS RA_JORNRED,
		    SX5.X5_DESCRI AS RA_CATFUNC, SQB.QB_DESCRIC, SQ3.Q3_DESCSUM, SPF.PF_DATA
	  FROM %table:SRA% SRA
	  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND %Exp:cJoinSQ3% AND SQ3.Q3_CARGO = SRA.RA_CARGO
	  JOIN %table:SX5% SX5 ON SX5.%notDel% AND %Exp:cJoinSX5% AND SX5.X5_TABELA = %Exp:'28'% AND SX5.X5_CHAVE = SRA.RA_CATFUNC
	  LEFT JOIN %table:SQB% SQB ON SQB.%notDel% AND %Exp:cJoinSQB% AND SQB.QB_DEPTO = SRA.RA_DEPTO
	  LEFT JOIN (SELECT SPF.PF_FILIAL, SPF.PF_MAT, MAX(SPF.PF_DATA) AS PF_DATA FROM %table:SPF% SPF 
                   JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SPF.PF_FILIAL AND SRA.RA_MAT = SPF.PF_MAT
                    AND SRA.%notDel% AND %Exp:cWhere%
	  			  WHERE PF_JORNADE <> PF_JORNAPA 
	           GROUP BY SPF.PF_FILIAL, SPF.PF_MAT) SPF ON SPF.PF_FILIAL = SRA.RA_FILIAL AND SPF.PF_MAT = SRA.RA_MAT
     WHERE SRA.%notDel% AND SRA.RA_DEMISSA = %Exp:''% And SRA.RA_CATFUNC IN (%exp:Upper(cCatQuery)%) AND %Exp:cWhere% 
  ORDER BY SRA.RA_FILIAL, SRA.RA_NOME
EndSql
oFilial:EndQuery()

oFunc:SetParentQuery()    
oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

VDFPrint(oFilial)

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � AaddAjuPDF � Autor � Wagner Mobile Costa   � Data � 20.07.14 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta lista de c�lulas a serem ajustadas na impress�o p/PDF  ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � SIGAVDF                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAVDF - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function VDFAjuPDF(oCell, nSizeAjust, lZeraLista)

If lZeraLista
	aCellPDF := {}
EndIf

Aadd(aCellPDF,{ oCell, nSizeAjust })

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � PrintVDF  � Autor � Wagner Mobile Costa    � Data � 20.07.14 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Envia impress�o da Se��o e antes realiza ajustes para PDF    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � SIGAVDF                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAVDF - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Function VDFPrint(oSecao)

Local nCell := 0

If oSecao:oReport:nDevice > 3	//-- 1=IMP_DISCO, IMP_SPOOL=2 e IMP_PORTA=3
	For nCell := 1 To Len(aCellPDF)
		aCellPdf[nCell][1]:nSize += aCellPdf[nCell][2]
	Next
EndIf

oSecao:Print()

Return