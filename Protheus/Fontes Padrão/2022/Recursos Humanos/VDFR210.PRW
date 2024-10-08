#Include "VDFR210.Ch"
#Include "Totvs.Ch"
#Include "Report.Ch"

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o  � VDFR210  � Autor � Robson Soares de Morais � Data �  13.12.13  ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Relat�rio por Verba x Dias de Afastamentos                   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR210(void)                                                ���
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

Function VDFR210()

Local aRegs := {}

Private oReport
Private cString   := "SRA"
Private cPerg	   	:= "VDFR210"
Private cTitulo   := STR0001 //-'Relat�rio de Pagamento de Verbas X Dias de Afastamento'
Private nSeq      	:= 0, lPrnDet := .F., oFunc
Private cAliasQRY	:= GetNextAlias()
Private cAliasQRY2 := GetNextAlias2()

Pergunte(cPerg, .F.)

M->RA_FILIAL := ""	// Variavel para controle da numera��o

oReport := ReportDef()
oReport:PrintDialog()

Return

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao  � ReportDef  � Autor � Robson Soares de Morais � Data � 13.12.13 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Montagem das defini��es do relat�rio VDFR210                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR210                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR210 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/

Static Function ReportDef()

Local cDescri := STR0002 // - 'Este relat�rio visa listar verbas da folha e afastamentos que podem ter ou n�o influenciado em proporcionaliza��o.'

oReport := TReport():New(cPerg, cTitulo, cPerg, {|oReport| ReportPrint(oReport, cTitulo)}, cDescri)
oReport:nFontBody := 7

// TRSection():New(	oParent,cTitle,uTable,aOrder,lLoadCells,lLoadOrder,uTotalText,lTotalInLine,lHeaderPage,lHeaderBreak,lPageBreak,lLineBreak,nLeftMargin,;
//					lLineStyle,nColSpace,lAutoSize,cCharSeparator,nLinesBefore,nCols,nClrBack,nClrFore,nPercentage)

oFilial := TRSection():New(oReport, STR0003, { "SM0" })  //- 'Filiais'
oFilial:SetLineStyle()
oFilial:cCharSeparator := ""

oFunc := TRSection():New(oFilial, STR0004, { "SRA", "SRC", "SRD", "SQB", "SQ3" }) //- 'Servidores'
oFunc:bLineCondition := { || NewLine() }
oFunc:nLinesBefore := 0

oReport:OnPageBreak( { || If(oReport:oPage:nPage > 1, (	oReport:Section(1):Init(), oFunc:SetHeaderSection(.T.),;
															 	oReport:Section(1):PrintLine(), oReport:Section(1):Finish()), .F.) })

TRCell():New(oFilial, "RA_FILIAL","SRA")
TRCell():New(oFilial, "", "", '-',,, /*lPixel*/,/*bBlock*/ { || (If(M->RA_FILIAL <> (cAliasQry)->RA_FILIAL, (M->RA_FILIAL := (cAliasQry)->RA_FILIAL, nSeq := 0), Nil),;
																 fDesc("SM0", cEmpAnt + (cAliasQry)->(RA_FILIAL), "M0_NOMECOM")) } )

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore)
nSeq := 0
TRCell():New(oFunc, "","", 'No', "99999", 5, /*lPixel*/,/*bBlock*/ { || PrintSeq() } )
TRCell():New(oFunc, "RA_MAT","SRA", STR0006,, 10)  //- 'Matr�cula'
TRCell():New(oFunc, "RA_NOME","SRA", STR0007)  //- 'Nome'            
TRCell():New(oFunc, "QB_DESCRIC","SQB", STR0008)  //- 'Lota��o'
TRCell():New(oFunc, "Q3_DESCSUM","SQ3",STR0009)  //- 'Cargo/Fun��o'
TRCell():New(oFunc, "RC_HORAS","SRC",STR0010,, 12)   //- 'Ref. Verba'
TRCell():New(oFunc, "RC_VALOR", "SRC", STR0011,,  /*nSize*/,/*lPixel*/,/*bBlock*/,/*cAlign*/ "RIGHT",/*lLineBreak*/,/*cHeaderAlign*/,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/ .T.) //- 'Valor Pagto'
TRCell():New(oFunc, "", "", STR0012, , 10, /*lPixel*/,/*bBlock*/ { || If(Left((cAliasQry)->(RC_NUMID),3) == "RIK", STR0013, If((cAliasQry)->(RC_TIPO2)=='I',STR0014,STR0021) ) } )//'Origem' //Se o 3 primeiros caracteres da RC_NUMID (ou RD_NUMID) for "RIK", indicar como "Automatico", caso contr�rio, "Calculado" ou "Manual".

oAfast := TRSection():New(oFunc, STR0005, { "SR8", "RCM" }) //- 'Afastamentos'
oAfast:SetLeftMargin(15)

//TRCell():New(oParent,cName,cAlias,cTitle,cPicture,nSize,lPixel,bBlock,cAlign,lLineBreak,cHeaderAlign,lCellBreak,nColSpace,lAutoSize,nClrBack,nClrFore)

TRCell():New(oAfast, "","",'',"",1, /*lPixel*/,/*bBlock*/ {||" " } )
TRCell():New(oAfast, "R8_DATAINI", "SR8", STR0015)  //- 'Inicio Licen�a'
TRCell():New(oAfast, "R8_DATAFIM", "SR8", STR0016)  //- 'Fim Licen�a'
TRCell():New(oAfast, "R8_DURACAO","SR8", STR0017, , , /*lPixel*/,/*bBlock*/ { || CalcAfas((cAliasQry2)->R8_DATAFIM,(cAliasQry2)->R8_DATAINI, mv_par03) }, "CENTER" ) 
TRCell():New(oAfast, "RCM_DESCRI", "RCM", STR0018, , , /*lPixel*/,/*bBlock*/ { || (cAliasQry2)->R8_TIPOAFA + ' - ' +  (cAliasQry2)->RCM_DESCRI } ) /* R8_TIPOAFA + Descri��o do Tipo do Afastamento - RCM_DESCRI */

Return (oReport)

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � PrintSeq    � Autor � Wagner Mobile Costa  � Data � 08.05.14 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao para controle da impress�o do cabecalho das colunas   ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR210                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR210 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function PrintSeq()

lPrnDet := .F.
oFunc:SetHeaderSection(nSeq == 0)

DbSelectArea(cAliasQRY2)
Set Filter To R8_FILIAL = (cAliasQry)->RA_FILIAL .And. R8_MAT = (cAliasQry)->RA_MAT
DbGoTop()

DbSelectArea(cAliasQry)

lNewPage := .F.

Return AllTrim(Str(++ nSeq))

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � NewLine     � Autor � Wagner Mobile Costa  � Data � 15.05.14 ���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Funcao para controle de salto de linha quando houver detalhe ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR210                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR210 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Static Function NewLine()

If lPrnDet
	oReport:SkipLine()
EndIf

Return .T.

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao  � ReportPrint � Autor � Robson Soares de Morais � Data � 13.12.13���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Montagem das defini��es do relat�rio VDFR210                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR210                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR210 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/

Static Function ReportPrint(oReport)

Local cWhere	:= "%", cWhereDt := cCodFunc := "", nTamCodFunc := GetSx3Cache( "RA_CATFUNC", "X3_TAMANHO" ), nCont := 0
Local oFilial	:= oReport:Section(1), oAfast := oReport:Section(1):Section(1):Section(1)
Local dData  	:= Stod(Right(mv_par03, 4) + Left(mv_par03, 2) + '01')

If Empty(mv_par03)
	MsgInfo(STR0022)  //'� obrigat�rio o preenchimento da compet�ncia ! Verifique os par�metros !'
	Return 
EndIF

SRV->(DbSetOrder(1))
SRV->(DbSeek(xFilial() + mv_par04))

oReport:SetTitle(STR0019 + Trans(mv_par03, "@R 99/9999") + ' - ' + STR0020 + ': ' + mv_par04 + "-" + SRV->RV_DESC) //'Pagamento de Verbas X Dias de Afastamento - Mes ' ### 'Verba'

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

If ! Empty(mv_par01)		//-- Filial
	cWhere += " AND " + mv_par01
EndIf

If ! Empty(mv_par02)		//-- Matricula
	cWhere += " AND " + mv_par02
EndIf

cWhereDt += " AND (( R8_DATAINI BETWEEN '" + Dtos(FirstDay(dData)) + "' AND '" + Dtos(LastDay(dData)) + "' ) OR " + ;
  	               " ( R8_DATAFIM BETWEEN '" + Dtos(FirstDay(dData)) + "' AND '" + Dtos(LastDay(dData)) + "' ) OR " + ;
  	               " ( R8_DATAINI < '" + Dtos(FirstDay(dData)) + "' AND R8_DATAFIM = ' ' ))%"    	             

//-- Monta a string de Codigos de Afastamentos para Impressao
If AllTrim( mv_par05 ) <> "*"
	cCodFunc   := ""
	For nCont  := 1 to Len(Alltrim(mv_par05)) Step nTamCodFunc
		cCodFunc += "'" + Substr(mv_par05, nCont, nTamCodFunc) + "'"  
		if ncont <= Len(Alltrim(mv_par05))
		  cCodFunc += ", " 
		EndIf  
	Next
	cCodFunc := Substr( cCodFunc, 1, Len(cCodFunc)-2)
	If !Empty(AllTrim(cCodFunc))
		cWhere += ' AND SRA.RA_CATFUNC IN (' + cCodFunc + ')'
	EndIf
EndIf
cWhere += "%"

oFilial:BeginQuery()
BeginSql Alias cAliasQRY
//Origem dos Funcion�rios/Pagamentos
	SELECT SRA.RA_FILIAL, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_DEPTO, SQB.QB_DESCRIC, SRA.RA_CARGO, SQ3.Q3_DESCSUM, SRC.RC_HORAS, SRC.RC_VALOR, SRC.RC_NUMID, SRC.RC_TIPO2 
	  FROM %table:SRA% SRA
	  JOIN %table:SQ3% SQ3 ON SQ3.%notDel% AND SQ3.Q3_FILIAL = %Exp:xFilial("SQ3")% AND SQ3.Q3_CARGO = SRA.RA_CARGO
 LEFT JOIN %table:SQB% SQB ON SQB.%notDel% AND SQB.QB_FILIAL = %Exp:xFilial("SQB")% AND SQB.QB_DEPTO = SRA.RA_DEPTO
	  JOIN (SELECT SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_HORAS, SRC.RC_VALOR, SRC.RC_NUMID, SRC.RC_TIPO2
	          FROM %table:SRC% SRC
	         WHERE SRC.%notDel% AND SRC.RC_PERIODO = %Exp:Right(mv_par03, 4) + Left(mv_par03, 2)% AND SRC.RC_PD = %Exp:mv_par04%
	         UNION
	        SELECT SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_HORAS, SRD.RD_VALOR, SRD.RD_NUMID, SRD.RD_TIPO2
	          FROM %table:SRD% SRD
	         WHERE SRD.%notDel% AND SRD.RD_PERIODO = %Exp:Right(mv_par03, 4) + Left(mv_par03, 2)% AND SRD.RD_PD = %Exp:mv_par04%) SRC 
	         ON SRC.RC_FILIAL = SRA.RA_FILIAL
	   AND SRC.RC_MAT = SRA.RA_MAT         
	 WHERE SRA.%notDel% %Exp:cWhere%
     ORDER BY SRA.RA_FILIAL, SRA.RA_NOME
EndSql

oFilial:EndQuery()
oFunc:SetParentQuery()
oFunc:SetParentFilter({|cParam| RA_FILIAL == cParam}, {|| (cAliasQry)->RA_FILIAL })

cWhere := Left(cWhere,Len(cWhere)-1) + cWhereDt

oAfast:BeginQuery()
BeginSql Alias cAliasQRY2
//Origem dos Afastamentos
	SELECT SR8.R8_FILIAL, SR8.R8_MAT, SR8.R8_DATAINI, SR8.R8_DATAFIM, SR8.R8_DURACAO, SR8.R8_TIPOAFA, RCM.RCM_DESCRI, SRC.RC_NUMID, RIK.RIK_AFASTA
	  FROM %table:SR8% SR8
	  JOIN %table:SRA% SRA ON SRA.%notDel% AND SRA.RA_FILIAL = SR8.R8_FILIAL AND SRA.RA_MAT = SR8.R8_MAT
	  JOIN %table:RCM% RCM ON RCM.%notDel% AND RCM.RCM_FILIAL = %Exp:xFilial("RCM")% AND RCM.RCM_TIPO = SR8.R8_TIPOAFA 
	  JOIN (SELECT SRC.RC_FILIAL, SRC.RC_MAT, SRC.RC_HORAS, SRC.RC_VALOR, SRC.RC_NUMID 
	          FROM %table:SRC% SRC
	         WHERE SRC.%notDel% AND SRC.RC_PERIODO = %Exp:Right(mv_par03, 4) + Left(mv_par03, 2)% AND SRC.RC_PD = %Exp:mv_par04%
	         UNION 
	        SELECT SRD.RD_FILIAL, SRD.RD_MAT, SRD.RD_HORAS, SRD.RD_VALOR, SRD.RD_NUMID
	          FROM %table:SRD% SRD
	         WHERE SRD.%notDel% AND SRD.RD_PERIODO = %Exp:Right(mv_par03, 4) + Left(mv_par03, 2)% 
	           AND SRD.RD_PD = %Exp:mv_par04%) SRC ON SRC.RC_FILIAL = SR8.R8_FILIAL 
	   AND SRC.RC_MAT = SR8.R8_MAT
 LEFT JOIN %table:RIK% RIK ON RIK.%notDel% AND RIK.RIK_FILIAL = %Exp:xFilial("RIK")% AND SUBSTRING(SRC.RC_NUMID, 1, 3) = 'RIK'
       AND RIK.RIK_COD = SUBSTRING(SRC.RC_NUMID, 4, 3)
	 WHERE SR8.%notDel% %Exp:StrTran(cWhere, "RA_FILIAL", "SR8.R8_FILIAL")% 
     ORDER BY SRA.RA_NOME
     
EndSql
oAfast:EndQuery()
oAfast:SetLineCondition({|| 	Left((cAliasQry2)->RC_NUMID, 3) <> "RIK" .Or.; 
									(AllTrim((cAliasQry2)->RIK_AFASTA) = "*" .Or.;
									((cAliasQry2)->R8_TIPOAFA) + "/" $ (AllTrim((cAliasQry2)->RIK_AFASTA)) + "/")  })

oAfast:SetParentFilter({|cParam| (R8_FILIAL + R8_MAT) == cParam}, {|| (cAliasQry)->(RA_FILIAL + RA_MAT) })

oFilial:Print()

Return
/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun�ao    � Auxiliar � Autor � Alexandre Florentino �     Data � 02.04.14���
���������������������������������������������������������������������������Ĵ��
���Descri�ao � Montagem das defini��es do relat�rio VDFR210                 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � VDFR210                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � VDFR210 - Generico - Release 4                               ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Static Function CalcAfas(dDtR8Fim,dDtR8Ini,cComp)

Local dData := Stod(Right(cComp, 4) + Left(cComp, 2) + '01')

If dDtR8Ini < dData
	dDtR8Ini := dData
EndIf

If dDtR8Fim > LastDay(dData) .Or. Empty(dDtR8Fim)
	dDtR8Fim := LastDay(dData)
EndIf

Return Alltrim(Str(dDtR8Fim - dDtR8Ini + 1))