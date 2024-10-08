#INCLUDE "VDFR200.ch"
#Include "Totvs.Ch"
#Include "Report.Ch"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o � VDFR200  � Autor � Robson Soares de Morais� Data �  06.01.14    ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Controle de Promotores Eleitorais    			    	    ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR200(void)                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���Marcos Pere �12/12/2014�TREOTW� Ajuste na query para solucionar erro de   ��
���            �          �      � duplicidade de coluna e ajuste na ordem   ��
���            �          �      � p/tratar ingresso na comarca.             ��
�������������������������������������������������������������������������������
*/

Function VDFR200()

	Local aRegs := {}

	Private oReport
	Private cString   := "SRA"
	Private cPerg	  := "VDFR200"
	Private cTitulo   := STR0001 //'Controle de Promotores Eleitorais'
	Private nSeq      := 0
	Private cQCargo   := ""
	Private cAliasQRY := ""
	Private oCelCargo := Nil


	Pergunte(cPerg, .F.)

	oReport := ReportDef()
	oReport:PrintDialog()

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportDef  � Autor � Robson Soares de Morais   � Data � 06.01.14 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Montagem das defini��es do relat�rio VDFR200                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR200                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR200 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function ReportDef()

	Local cDescri := STR0002 //'Este relat�rio visa auxiliar o gerenciamento dos per�odos de exerc�cio dos membros como promotores eleitorais.'

	oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri)
	oReport:nFontBody := 7

	oReport:OnPageBreak( { || 	If(	oReport:oPage:nPage > 1, 	(oReport:Section(1):Init(), oReport:Section(1):PrintLine(), oReport:Section(1):Finish(),;
									oReport:Section(1):Section(1):Init(), oReport:Section(1):Section(1):PrintLine(),;
									oReport:Section(1):Section(1):Finish()), .F.) })

// TRSection():New(	oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,;
//					lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)

	oFilial := TRSection():New(oReport, STR0004, { "SM0" }) //'Filiais'
	oFilial:SetLineStyle()
	oFilial:cCharSeparator := ""
	oFilial:nLinesBefore   := 0
	
	oFilial:bOnPrintLine := { || (oReport:SkipLine(), 	oReport:PrintText(AllTrim(RetTitle("RA_FILIAL")) + ': ' +;
														(cAliasQry)->(RA_FILIAL) + " - " +;
														fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")), .F.) } 
	
	TRCell():New(oFilial,"RA_FILIAL","SRA")
	TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM") } )
	
	oComarca  := TRSection():New(oFilial  , STR0005,( "SQB" )) //'Comarca'
	
	TRCell():New(oComarca, "", "", STR0005,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| AllTrim((cAliasQRY)->(REC_NOME)) }) //'Comarca'
	oComarca:nLinesBefore   := 0
	oComarca:bOnPrintLine := { || (oReport:SkipLine(), oReport:PrintText(Space(5) + 'Comarca' + ': ' + (cAliasQry)->(REC_NOME)), .F.) } 

	//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore)
	oFunc := TRSection():New(oComarca , STR0006, ( "SRA","SQ3","SQB","SPF" )) //'Servidores'
	oFunc:nLinesBefore   := 0
	oFunc:SetLeftMargin(5)
	oFunc:SetCellBorder("ALL",,, .T.)
	oFunc:SetCellBorder("RIGHT")
	oFunc:SetCellBorder("LEFT")
	oFunc:SetCellBorder("BOTTOM")
	
	TRCell():New(oFunc,	"RA_NOME","SRA",,, 50)

	TRCell():New(oFunc,	"","", STR0007 ,/*cPicture*/, 30,/*lPixel*/,;
				{ || If((cAliasQRY)->(ASSUMIU) = 0, STR0010, Dtoc((cAliasQRY)->(RIM_DTINI))) },; //'Inicio do Ultimo Mandato'
					/*cAlign*/, /*lLineBreak*/, /*cHeaderAlign*/)  

	TRCell():New(oFunc, "RIM_DTFIM","RIM", STR0008,, 30) //'Fim do Ultimo Mandato'
	TRCell():New(oFunc, "RIM_ZONA","RIM", STR0009,, 30) //'Zona Eleitoral'

Return (oReport)

/*
�������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������
���������������������������������������������������������������������������������Ŀ��
���Fun�ao    � ReportPrint � Autor � Robson Soares de Morais   � Data � 05.12.13  ���
���������������������������������������������������������������������������������Ĵ��
���Descri�ao � Montagem das defini��es do relat�rio VDFR200                       ���
���������������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR200                                                            ���
���������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                    ���
���������������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR200 - Generico - Release 4                                     ���
����������������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Static Function ReportPrint(oReport)

	Local oFilial   := oReport:Section(1)
	Local oComarca  := oReport:Section(1):Section(1)
	Local oFunc     := oReport:Section(1):Section(1):Section(1)
	Local cWhere    := "%"
	Local cWhereRA  := "%"
	Local cJoinSRA	 := ""
	Local cJoinSQB	 := ""

	cAliasQRY := GetNextAlias()
	
	If Empty(mv_par03)
		MsgInfo(STR0003) //"Aten��o. � obrigat�rio selecionar os cargos de promotoria !"
		Return
	EndIf

	//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
	MakeSqlExpr(cPerg)

	If ! Empty(mv_par01)		//-- Filial
		cWhere += " AND " + mv_par01
	EndIf

	If ! Empty(mv_par02)		//-- Matricula
		cWhere += " AND " + mv_par02
	EndIf

	If ! Empty(mv_par03)		//-- Cargo
		cWhere += " AND " + mv_par03
	EndIf
	cWhereRA := cWhere + "%"

	If ! Empty(mv_par04)		//-- Data Fim de Mandato
		cWhere += " AND " + mv_par04
	EndIf

	If ! Empty(mv_par05)		//-- Comarca
		cWhere += " AND " + mv_par05
	EndIf
	cWhere += "%"
	cWhere := strtran(cWhere,"RA_","SRA.RA_")
	
	cJoinSRA := "%" + FWJoinFilial("SRA","REC") + "%"
	cJoinSQB := "%" + FWJoinFilial("SQB","REC") + "%"
	

	oFilial:BeginQuery()
	BeginSql Alias cAliasQRY
		COLUMN RIM_DTINI AS DATE
		COLUMN RIM_DTFIM AS DATE

		SELECT SRA.RA_FILIAL, REC.REC_CODIGO, REC.REC_NOME, SRA.RA_NOME, RIM.RIM_DTINI, RIM.RIM_DTFIM,
		       (SELECT RIM_ZONA FROM %table:RIM% WHERE %notDel% AND RIM_FILIAL = RIM.RIM_FILIAL AND RIM_MAT = RIM.RIM_MAT
		           AND RIM_DTINI = RIM.RIM_DTINI AND RIM_DTFIM = RIM.RIM_DTFIM AND RIM_ZONA <> %Exp:Space( TamSx3("RIM_ZONA")[1] )%) AS RIM_ZONA,
		       CASE WHEN RIM.RIM_FILIAL IS NULL THEN 0 ELSE 1 END AS ASSUMIU
		  FROM %table:REC% REC
		  JOIN %table:SQB% SQB ON SQB.%notDel% AND %Exp:cJoinSQB% AND SQB.QB_COMARC = REC.REC_CODIGO
		  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_DEPTO = SQB.QB_DEPTO AND SRA.RA_CATFUNC IN (%Exp:'0'%, %Exp:'1'%)
		   AND SRA.RA_SITFOLH <> %Exp:'D'% AND %Exp:cJoinSRA%
		  LEFT JOIN (SELECT RIM_FILIAL, RIM_MAT, MAX(RIM_DTINI) AS RIM_DTINI, MAX(RIM_DTFIM) AS RIM_DTFIM
		               FROM %table:RIM%
		              WHERE %notDel%
		              GROUP BY RIM_FILIAL, RIM_MAT) RIM ON RIM.RIM_FILIAL = SRA.RA_FILIAL AND RIM.RIM_MAT = SRA.RA_MAT
		  LEFT JOIN (SELECT RA_FILIAL, RA_MAT, QB_COMARC, MIN(RE_DATA) AS RE_DATA
                     FROM (SELECT SRA.RA_FILIAL, SRA.RA_MAT, SQB.QB_COMARC, SRE.RE_DATA 
                             FROM %table:SRE% SRE
                             JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SRE.RE_FILIALP AND SRA.RA_MAT = SRE.RE_MATP
                             JOIN %table:SQB% SQB ON SQB.%notDel% AND SQB.QB_FILIAL = %Exp:xFilial("SQB")% AND SQB.QB_DEPTO = SRE.RE_DEPTOP
                            WHERE SRE.%notDel% %Exp:cWhereRA% AND SRE.RE_DEPTOD <> SRE.RE_DEPTOP AND SRE.RE_DEPTOP <> %Exp:' '%
                            UNION ALL
                           SELECT SRA.RA_FILIAL, SRA.RA_MAT, SQB.QB_COMARC, SRA.RA_ADMISSA
                             FROM %table:SRA% SRA
  				        LEFT JOIN (SELECT SRE.RE_FILIALP, RE_MATP, SRE.RE_DEPTOD, SRE.RE_DATA
				                     FROM %table:SRE% SRE
                                     JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SRE.RE_FILIALP AND SRA.RA_MAT = SRE.RE_MATP %Exp:cWhereRA%
				                    WHERE SRE.%notDel%
				                      AND SRE.RE_DATA IN (SELECT MIN(RE_DATA) FROM %table:SRE% WHERE %notDel% AND RE_FILIALP = SRE.RE_FILIALP
				                                             AND RE_MATP = SRE.RE_MATP)) SRE ON SRE.RE_FILIALP = SRA.RA_FILIAL AND SRE.RE_MATP = SRA.RA_MAT
                             JOIN %table:SQB% SQB ON SQB.%notDel% AND SQB.QB_FILIAL = %Exp:xFilial("SQB")% 
                              AND SQB.QB_DEPTO = COALESCE(SRE.RE_DEPTOD, SRA.RA_DEPTO)
                            WHERE SRA.%notDel% %Exp:cWhereRA%) SRE
					     GROUP BY RA_FILIAL, RA_MAT, QB_COMARC) SRE ON SRE.RA_FILIAL = SRA.RA_FILIAL AND SRE.RA_MAT = SRA.RA_MAT 
				AND SRE.QB_COMARC = SQB.QB_COMARC
		  LEFT JOIN (SELECT RII_FILIAL, RII_MAT, SUM(RII_TMPLIQ) AS RII_TMPLIQ
				         FROM %table:RII%
					     WHERE %notDel% AND RII_TIPAVE = %Exp:'1'%
					  GROUP BY RII_FILIAL, RII_MAT) RII ON RII.RII_FILIAL = SRA.RA_FILIAL AND RII.RII_MAT = SRA.RA_MAT
		 WHERE REC.%notDel% %Exp:cWhere%
		 ORDER BY 	SRA.RA_FILIAL, 
		 			REC.REC_CODIGO, 
		 			CASE WHEN (RIM.RIM_FILIAL = %Exp:''% or RIM.RIM_FILIAL = NULL) 
		 				 THEN COALESCE(SRE.RE_DATA, SRA.RA_ADMISSA) 
		                 ELSE COALESCE(RIM.RIM_DTFIM, %Exp:''%) 
		                 END,
		 			COALESCE(SRE.RE_DATA, %Exp:''%), 
		 			SRA.RA_ADMISSA, 
		 			RII.RII_TMPLIQ DESC, 
		 			SRA.RA_NASC
	EndSql

	//Criterios de ordenacao dentro da comarca:
	//1. quem nunca cumpriu mandato (sem registro na RIM), ordenados pelo ingresso na comarca (SRE/SQB/REC ou admissao)
	//2. demais que ja cumpriram algum mandado (com registro na RIM), ordenados pela data final do ultimo mandato
	//3. mais antigos na comarca (SRE/SQB/REC)
	//4. admissao
	//5. averbacoes (RII)
	//6. nascimento

	oFilial:EndQuery()

	oComarca:SetParentQuery()
	oComarca:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL == cParam}, {|| (cAliasQRY)->RA_FILIAL  })

	oFunc:SetParentQuery() 
	//oFunc:SetRelation({|| (cAliasQRY)->RA_FILIAL})
	oFunc:SetParentFilter({|cParam| (cAliasQRY)->RA_FILIAL + (cAliasQRY)->(REC_CODIGO) == cParam}, {|| (cAliasQRY)->RA_FILIAL + (cAliasQRY)->(REC_CODIGO) })

	oFilial:Print()

Return
