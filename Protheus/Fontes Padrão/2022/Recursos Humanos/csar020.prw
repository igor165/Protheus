#INCLUDE "PROTHEUS.CH"
#INCLUDE "CSAR020.CH"    
#INCLUDE "report.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CSAR020  � Autor � Marina Shimano        � Data � 17.04.00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Graduacao de Fatores X Funcionarios           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSAR020(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�30/07/14�TPZVV4�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
���Luis Artuso �30/06/15�TRRHLI�Ajuste na Query para nao gerar errorlog ao���
���            �        �      �preencher os parametros com conteudo(A-Z).���
���Renan Borges�21/07/15�TSTVZS�Ajuste para corrigir error.log gerado quan���
���            �        �      �do for preenchido o campo �Fator Gradua-  ���
���            �        �      ���o� dos par�metros.                      ���
���Renan Borges�01/04/16�TUHHMZ�Ajuste para imprimir relat�rio de "Fatores���
���            �        �      � x  Funcion�rios" com o parametro         ���
���            �        �      �MV_IMPSX1 igual a "N" n�o seja gerado     ���
���            �        �      �error.log. Ajuste para imprimir relat�rio ���
���            �        �      �de folha de pagamento n�o personalizado   ���
���            �        �      �utilizando os parametros MV_QBIMPFO e o   ���
���            �        �      �MV_QUEBFUN.                               ���
���Marcelo F   �14/02/17�MRH-6320�Ajuste no relat�rio e na query para proc���
���            �        �461886  � adequadamente quando utilizado o param ���
���            �        �        � grau                                   ���
���Gabriel A.  �06/03/17�MRH-7339�Ajuste nos t�tulos das se��es para emitir ���
���            �        �        �o relat�rio corretamente em modo tabela.  ���
���Gabriel A.  �13/03/17�MRH-7693�Ajuste na impress�o do relat�rio para     ���
���            �        �        �considerar o par�metro "Fator" em branco. ���
��|Esther V.   |25/05/17|DRHPONTP-94|Incluida novas colunas: Filial, GAP,   ���
��|            |        |           |Grau Necessario. Modificado para usar  ���
��|            |        |           |oSection:Print() ao inves de PrintLine.���
��|            |        |           |Mais detalhes no DT presente no TDN.   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function CSAR020()
Local	oReport   
Local	aArea 	:= GetArea()
Private	cString	:= "SRA"				// alias do arquivo principal (Base)
Private	cPerg	:= "CSR20R"

Private aOrd    := {STR0007}
Private cTitulo	:= OemToAnsi(STR0001)	//"Relatorio de Graduacao de Fatores X Funcionarios"

//������������������������������������������Ŀ
//� Verifica as perguntas selecionadas       �
//��������������������������������������������
Pergunte(cPerg,.F.)
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CSAR020RDEF�Autor  �Microsiga           � Data �  24/12/10  ���
�������������������������������������������������������������������������͹��
���Desc.     �Definicao Relatorio                                         ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()

//��������������������������������������������������������������Ŀ
//� Variaveis Utilizadas na descricao do relatorio               �
//����������������������������������������������������������������   
Local oReport 
Local cDesc1	:= OemToAnsi(STR0001) + OemToAnsi(STR0002) + OemToAnsi(STR0003) //"Relatorio de Graduacao de Fatores X Funcionarios" ### "Ser� impresso de acordo com os parametros solicitados pelo"  ### "usu�rio."

//Secoes Relatorio
Local oSection1
Local oSection2
Local oSection3
Local oSection4
Local oSection5
Local oSection6

//Variaveis Utilizadas nas secoes
Local oBreak  //Objeto Quebra Utilizado no Totalizador  	
Local oBreak2 //Objeto Quebra Utilizado na Quebra de Pagina
Local oBreak01
Local oBreak02
Local oBreak03
Local oBreak04

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01        //  Filial                                   �
//� MV_PAR02        //  Grupo De                                 �
//� MV_PAR03        //  Centro Custo De                          �                                
//� MV_PAR04        //  Cargo De                                 �
//� MV_PAR05        //  Matricula De                             �
//� MV_PAR06        //  Nome De                                  �
//� MV_PAR07        //  Fator de Graduacao De                    �
//� MV_PAR08       	//  Grau De                                  �
//� MV_PAR09        //  Situacao                                 �
//� MV_PAR10        //  Categoria                                �
//� MV_PAR11        //  Imprimir Pontos S/N                      �
//� MV_PAR12       	//  Imprime Desc. Detalhada do Fator S/N 	 �
//� MV_PAR13       	//  Imprime Observacao do Fator Funcion. S/N �
//����������������������������������������������������������������

//������������������������������������������������������������������������Ŀ
//�Criacao dos componentes de impressao                                    �
//��������������������������������������������������������������������������
DEFINE REPORT oReport NAME "CSAR020" TITLE cTitulo PARAMETER cPerg ACTION {|oReport| R020Imp(oReport)} DESCRIPTION OemtoAnsi(STR0039) TOTAL IN COLUMN	 //"Este programa emite Relatorio de Graduacao de Fatores X Funcionarios.

	//SECTION 01 - Secao Grupo
	DEFINE SECTION oSection1 OF oReport TITLE OEMTOANSI(STR0024) TABLES "SQ0" //"Ctr Funcionarios
		DEFINE CELL NAME "Q3_GRUPO"   OF oSection1 ALIAS "SQ3" TITLE OEMTOANSI(STR0025) //"Cod.Grupo:"
		DEFINE CELL NAME "Q0_DESCRIC" OF oSection1 ALIAS "SQ0" TITLE OEMTOANSI(STR0026) //"Descricao"

		oBreak2 := TRBreak():New(oSection1,{||(cAliasQry)->Q3_GRUPO},,.T.)
		oBreak2:SetPageBreak(.T.)

		oSection1:SetHeaderBreak(.T.)

	//SECTION 02 - Secao CC
	oSection2 := TRSection():New(oSection1,OemToAnsi(STR0040),{"SRA", "CTT"}) //"Centro de Custo"
		DEFINE CELL NAME "RA_CC"      OF oSection2 ALIAS "SRA" TITLE OEMTOANSI(STR0027) //"Cod.Centro de Custo"
		DEFINE CELL NAME "CTT_DESC01" OF oSection2 ALIAS "CTT" TITLE OEMTOANSI(STR0026) //"Descricao"

		DEFINE BREAK oBreak01 OF oSection2 WHEN {|| (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_CC } TITLE OemToAnsi(STR0040)

		oSection2:SetLeftMargin(3)
		oSection2:SetHeaderBreak(.T.)

	//SECTION 03 - Secao Cargo
	oSection3 := TRSection():New(oSection2,OemToAnsi(STR0009),{"SRA", "SQ3"}) //"Cargo"
		DEFINE CELL NAME "RA_CARGO"   OF oSection3 ALIAS "SRA" TITLE OemToAnsi(STR0028) //"Cod.Cargo"
		DEFINE CELL NAME "Q3_DESCSUM" OF oSection3 ALIAS "SQ3" TITLE OEMTOANSI(STR0026) //"Descricao"

		DEFINE BREAK oBreak02 OF oSection3 WHEN {|| (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_CC + (cAliasQry)->RA_CARGO } TITLE OemToAnsi(STR0009)

		oSection3:SetLeftMargin(6)
		oSection3:SetHeaderBreak(.T.)

	//SECTION 04 - Secao Funcionario
	oSection4 := TRSection():New(oSection3,OemToAnsi(STR0017),{"SRA"})	//"Funcion�rio"
		TRCell():New(oSection4,"RA_MAT"     ,"SRA" ,OEMTOANSI(STR0029),,30,.T.)//"Cod.Matricula"
		TRCell():New(oSection4,"RA_NOME"    ,"SRA" ,OEMTOANSI(STR0030))//"Nome"
		TRCell():New(oSection4,"RA_NASC"    ,"SRA" ,OEMTOANSI(STR0031),,15,.T.)//"Dt.Nasc"
		TRCell():New(oSection4,"RA_ADMISSA" ,"SRA" ,OEMTOANSI(STR0032),,15,.T.)//"Dt.Admis"
		TRCell():New(oSection4,"RA_ESTCIVI" ,"SRA" ,OEMTOANSI(STR0033),X3PICTURE("X5_DESCRI"),TAMSX3("X5_DESCRI")[1],,{|| TRMDESC("SX5","33"+(cAliasQry)->RA_ESTCIVI,"SX5->X5_DESCRI")})//"Est.Civil"
		TRCell():New(oSection4,"RA_FILIAL" ,"SRA" ,OEMTOANSI(STR0043),,TAMSX3("RA_FILIAL")[1],.T.)//"FILIAL"

		DEFINE BREAK oBreak OF oSection4 WHEN {|| (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_CC + (cAliasQry)->RA_CARGO + (cAliasQry)->RA_MAT } TITLE OemToAnsi(STR0017)

		oSection4:SetLeftMargin(9)
		oSection4:SetHeaderBreak(.T.)

	//SECTION 05 - Secao Fator e Grau
	oSection5 := TRSection():New(oSection4,OemToAnsi(STR0041),{"SQ8","SQV"}) //"Fator e Grau"
		TRCell():New(oSection5,"GAP",""	,OEMTOANSI(STR0044),,1,,{|| IIF( (cAliasQry)->Q4_GRAU > (cAliasQry)->Q8_GRAU,"!", "")})//"GAP" - indica se possui divergencia entre cargo e funcionario
		TRCell():New(oSection5,"Q8_FATOR"	,"SQ8"	,OEMTOANSI(STR0035)) 
		TRCell():New(oSection5,"QV_DESCFAT","SQV2"	,OEMTOANSI(STR0036),,50)//"Fator Necessario" //pego descricao a partir do cargo
		TRCell():New(oSection5,"Q4_GRAU"  	,"SQ4"	,OEMTOANSI(STR0035))//"Cod."
		TRCell():New(oSection5,"QV_DGRAU2" 	,"SQV2"	,OEMTOANSI(STR0045),,50)//"Grau Necessario"
		TRCell():New(oSection5,"Q8_GRAU"  	,"SQ8"	,OEMTOANSI(STR0035))//"Cod." 
		TRCell():New(oSection5,"QV_DESCGRA","SQV"	,OEMTOANSI(STR0037),,50,,{|| IIF( !Empty((cAliasQry)->Q8_GRAU),(cAliasQry)->QV_DESCGRA, OemToAnsi(STR0046))})//"Gradua��o Funcionario."
		TRCell():New(oSection5,"Q8_PONTOS"	,"SQ8"	,OEMTOANSI(STR0038),,TAMSX3("Q8_PONTOS")[1],,{|| IIF(!Empty((cAliasQry)->Q2_PONTOSI),(cAliasQry)->Q2_PONTOSI,(cAliasQry)->Q8_PONTOS )}) //"Pontos."

		DEFINE BREAK oBreak03 OF oSection5 WHEN {|| (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_CC + (cAliasQry)->RA_CARGO + (cAliasQry)->RA_MAT + (cAliasQry)->Q8_FATOR } TITLE OemToAnsi(STR0041)

		oSection5:Cell("QV_DESCFAT"):SetLineBreak()
		oSection5:Cell("QV_DGRAU2"):SetLineBreak()
		oSection5:Cell("QV_DESCGRA"):SetLineBreak()
		oSection5:SetLeftMargin(12)
		oSection5:SetHeaderBreak(.T.)

    //SECTION 06 - Secao Descricao Detalhada Fator
	oSection6 := TRSection():New(oSection5,OemToAnsi(STR0001),{"SQ1","SQ8"}) //"Relat�rio Fatores X Funcion�rios"
		TRCell():New(oSection6,"Q1_DESCDET"	,"SQ1"	,OEMTOANSI(STR0013),X3PICTURE("RDY_TEXTO"),TAMSX3("RDY_TEXTO")[1],,;//"DESCRICAO DETALHADA DO FATOR"
			{|| IIF(!Empty( RHMSMM((cAliasQry)->Q1_DESCDET,,,,3,,,,,"RDY",,"SQ1")),RHMSMM((cAliasQry)->Q1_DESCDET,,,,3,,,,,"RDY",,"SQ1"),OEMTOANSI(STR0016))})		//" *** Nao tem nenhuma Observacao para este Fator *** "
		TRCell():New(oSection6,"Q8_OBS"		,"SQ8" 	,OEMTOANSI(STR0015),X3PICTURE("RDY_TEXTO"),TAMSX3("RDY_TEXTO")[1],,;//"OBSERVACAO FATOR DO FUNCIONARIO"
			{|| IIF(!Empty( RHMSMM((cAliasQry)->Q8_OBS,,,,3,,,,,"RDY",,"SQ8")),RHMSMM((cAliasQry)->Q8_OBS,,,,3,,,,,"RDY",,"SQ8"),OEMTOANSI(STR0014))})				//" *** Nao existe Descricao detalhada do Fator *** "
		
		oBreak04 := TRBreak():New(oSection6,{|| (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_CC + (cAliasQry)->RA_CARGO + (cAliasQry)->RA_MAT + (cAliasQry)->Q8_FATOR },OemToAnsi(STR0001),.F.)//"Relat�rio Fatores X Funcion�rios"

		oSection6:Cell("Q1_DESCDET"):SetLineBreak() //impressao campo Memo
		oSection6:Cell("Q8_OBS"):SetLineBreak() //impressao campo Memo
		oSection6:SetLeftMargin(15)
		oSection6:SetHeaderBreak(.T.)

Return(oReport)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �R020IMP    �Autor  �Microsiga           � Data �  24/12/10  ���
�������������������������������������������������������������������������͹��
���Desc.     �Tratamento de secao, query, e impressao                     ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R020IMP(oReport) 

//��������������������������������������������������������������Ŀ
//� Secoes Relatorio              							     �
//���������������������������������������������������������������� 
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local oSection3 := oReport:Section(1):Section(1):Section(1)
Local oSection4 := oReport:Section(1):Section(1):Section(1):Section(1)
Local oSection5 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1)
Local oSection6 := oReport:Section(1):Section(1):Section(1):Section(1):Section(1):Section(1)

Local cQry1	:= ""		//Fitro sobre Situacao Folha utilizado na QRY1
Local cQry2	:= ""		//Fitro sobre Categoria Funcionario utilizado na QRY1

Local cWhere := ""		//Condicao a ser utilizada na Query
Local cFilSRACTT := ""
Local cFilSRASQV := ""
Local cFilSRASQ0 := ""
Local cFilSRASQ1 := ""
Local cFilSRASQ2 := ""
Local cFilSRASQ3 := ""
Local cFilSRASQ4 := ""
Local cFilSRASQ8 := ""
Local cExpSQ4    := ""
Local cExpSQ8    := ""
Local cExpMV08	 := ""
Local cQuebra1	:= ""
Local cQuebra2	:= ""
Local cQuebra3	:= ""
Local cQuebra4	:= ""

Local cSit1	:= MV_PAR09 //Situacao Folha
Local cSit2 := MV_PAR10	//Categoria Funcionario

Local nRegX	:= 0       	//Contador

//O dono do Break eh a secao04 que pertence ao Funcionario, pois desejo que o totalizador seja impresso a cada quebra de funcionario
Local oBreak := TRBreak():New(oSection4,{|| (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_FILIAL + (cAliasQry)->RA_CC + (cAliasQry)->RA_CARGO + (cAliasQry)->RA_MAT },SPACE(140) + STR0034,.F.)//" T O T A L: "
TRFunction():New(oSection5:Cell("Q8_PONTOS") ,,"SUM",oBreak,SPACE(18),,,.F.,.F.,)

If oreport:nDevice == 4 
	oreport:lEmptyLineExcel := .F.
EndIf 

cAliasQry := GetNextAlias()

//��������������������������������������������������������������Ŀ
//�Filtro sobre Situacao Folha utilizado na QRY1                 �
//����������������������������������������������������������������  
For nRegX:=1 to Len(cSit1)
	cQry1 += "'"+Subs(cSit1,nRegX,1)+"'"
	If ( nRegX+1 ) <= Len(cSit1)
		cQry1 += "," 
	Endif
Next nRegX

//��������������������������������������������������������������Ŀ
//� Filtro sobre Categoria Funcionario utilizado na QRY1         �
//����������������������������������������������������������������
For nRegX:=1 to Len(cSit2)
	cQry2 += "'"+Subs(cSit2,nRegX,1)+"'"
	If ( nRegX+1 ) <= Len(cSit2)
		cQry2 += "," 
	Endif
Next nRegX

//��������������������������������������������������������������Ŀ
//� Imprimir Pontos? 				1=S, 2=N	 	             �
//����������������������������������������������������������������
If MV_PAR11 = 2
	oSection5:Cell("Q8_PONTOS"):Disable()	 	
EndIf

//��������������������������������������������������������������Ŀ
//� Imprimir Fator Detalhado? 		1=S, 2=N			         �
//����������������������������������������������������������������
If MV_PAR12 = 2
	oSection6:Cell("Q1_DESCDET"):Disable()	
EndIf 

//��������������������������������������������������������������Ŀ
//� Observacao Fator Funcionario? 	1=S, 2=N		             |
//����������������������������������������������������������������
If MV_PAR13 = 2
	oSection6:Cell("Q8_OBS"):Disable()
Endif

//Transforma parametros do tipo Range em expressao ADVPL para ser utilizada no filtro
MakeSqlExpr(cPerg)

oSection1:BeginQuery() 

// Monta o Where da query devido ter a particularidade das filiais das tabelas serem exclusivas ou compartilhadas
cWhere := "% RA_SITFOLH IN ("+ cQry1 + ") AND "
cWhere += "RA_CATFUNC IN ("+ cQry2 + ") AND "	
cWhere += "SRA.D_E_L_E_T_ = ' ' "

cFilSQVSQ4:= "%" + FWJoinFilial("SQV", "SQ4") + "%"
cFilSQVSQ4:= Replace(cFilSQVSQ4,"SQV.","SQV2.")
cFilSRACTT:= "%" + FWJoinFilial("SRA", "CTT") + "%"
cFilSRASQV:= "%" + FWJoinFilial("SRA", "SQV") + "%"
cFilSRASQ0:= "%" + FWJoinFilial("SRA", "SQ0") + "%"
cFilSRASQ1:= "%" + FWJoinFilial("SRA", "SQ1") + "%"
cFilSRASQ2:= "%" + FWJoinFilial("SRA", "SQ2") + "%"
cFilSRASQ3:= "%" + FWJoinFilial("SRA", "SQ3") + "%"
cFilSRASQ4:= FWJoinFilial("SRA", "SQ4")
cFilSRASQ8:= FWJoinFilial("SRA", "SQ8")

cExpSQ4 := "%" + cFilSRASQ4
cExpSQ4 += "%"

cExpSQ8 := "%" + cFilSRASQ8

If !Empty(MV_PAR07)
	cExpSQ8 += " AND " + MV_PAR07
Endif

If !Empty(MV_PAR08)
	cExpSQ8 += " AND " + MV_PAR08
Endif

cExpSQ8 += "%"

cWhere += " %"


BEGINSQL ALIAS cAliasQry

	SELECT
	SRA.RA_CC, SRA.RA_CARGO, SRA.RA_MAT, SRA.RA_NOME, SRA.RA_ADMISSA, SRA.RA_NASC, SRA.RA_ESTCIVI, SRA.RA_SITFOLH, 
	SRA.RA_CATFUNC, SRA.RA_FILIAL,
	CTT.CTT_FILIAL, CTT.CTT_CUSTO, CTT.CTT_DESC01,
	SQV2.QV_DESCFAT, SQV.QV_DESCGRA, SQV2.QV_DESCGRA QV_DGRAU2,
	SQ0.Q0_GRUPO, SQ0.Q0_DESCRIC,
	SQ1.Q1_DESCDET,
	SQ2.Q2_PONTOSI,
	SQ3.Q3_GRUPO, SQ3.Q3_CC, SQ3.Q3_CARGO, SQ3.Q3_DESCSUM,
	SQ4.Q4_CARGO, SQ4.Q4_FATOR, SQ4.Q4_GRAU, SQ4.Q4_GRUPO,
	SQ8.Q8_FILIAL, SQ8.Q8_FATOR, SQ8.Q8_GRAU, SQ8.Q8_PONTOS, SQ8.Q8_OBS

	FROM %table:SRA% SRA
	INNER JOIN %table:CTT% CTT ON SRA.RA_CC = CTT.CTT_CUSTO AND CTT.%NotDel% AND %exp:cFilSRACTT%
	INNER JOIN %table:SQ3% SQ3 ON (SRA.RA_CARGO = SQ3.Q3_CARGO OR (SRA.RA_CARGO = SQ3.Q3_CARGO AND SRA.RA_CC = Q3_CC ))  AND SQ3.%NotDel% AND %exp:cFilSRASQ3%
	INNER JOIN %table:SQ0% SQ0 ON SQ3.Q3_GRUPO = SQ0.Q0_GRUPO  AND SQ0.%NotDel% AND %exp:cFilSRASQ0%

	LEFT JOIN %table:SQ4% SQ4  ON (SQ4.Q4_CARGO = SQ3.Q3_CARGO OR (SQ4.Q4_CARGO = SQ3.Q3_CARGO AND SQ4.Q4_CC = SQ3.Q3_CC)) AND SQ4.%NotDel% AND %exp:cExpSQ4%
	LEFT JOIN %table:SQ8% SQ8  ON SQ8.Q8_MAT = SRA.RA_MAT AND SQ8.Q8_FATOR = SQ4.Q4_FATOR  AND SQ8.%NotDel% AND %exp:cExpSQ8% 
	LEFT JOIN %table:SQV% SQV  ON SQ8.Q8_GRAU = SQV.QV_GRAU AND SQ8.Q8_FATOR = SQV.QV_FATOR  AND SQV.%NotDel% AND %exp:cFilSRASQV% // SQ4.Q4_FATOR = SQV.QV_FATOR
	LEFT JOIN %table:SQV% SQV2 ON SQ4.Q4_GRAU = SQV2.QV_GRAU AND SQ4.Q4_FATOR = SQV2.QV_FATOR  AND SQV2.%NotDel% AND %exp:cFilSQVSQ4% 
	LEFT JOIN %table:SQ2% SQ2  ON SQ2.Q2_GRUPO = SQ3.Q3_GRUPO AND SQ2.Q2_FATOR = SQ8.Q8_FATOR AND SQ2.Q2_GRAU = SQ8.Q8_GRAU AND SQ2.%NotDel% AND %exp:cFilSRASQ2%
	LEFT JOIN %table:SQ1% SQ1  ON SQ1.Q1_GRUPO = SQ4.Q4_GRUPO AND SQ1.Q1_FATOR = SQ4.Q4_FATOR  AND SQ1.%NotDel% AND %exp:cFilSRASQ1%

	WHERE %exp:cWhere%

	ORDER BY RA_FILIAL,Q3_GRUPO,RA_CC,RA_CARGO,RA_MAT

EndSql

oSection1:EndQuery({MV_PAR01, MV_PAR02, MV_PAR03, MV_PAR04, MV_PAR05, MV_PAR06, MV_PAR07, MV_PAR08} )//Array com os parametros do tipo Range

//��������������������������������������������������������������Ŀ
//�Filtro Filial e Grupo para CC		                         �
//����������������������������������������������������������������
oSection2:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL + (cAliasQry)->Q3_GRUPO == cParam },{||(cAliasQry)->RA_FILIAL + (cAliasQry)->Q3_GRUPO})

//��������������������������������������������������������������Ŀ
//�Filtro Filial,Grupo e CC para Cargo		                     �
//����������������������������������������������������������������
oSection3:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL + (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_CC  == cParam },{||(cAliasQry)->RA_FILIAL + (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_CC})

//��������������������������������������������������������������Ŀ
//�Filtro Filial,Grupo,CC e Cargo para Mat.Func              	 �
//����������������������������������������������������������������
oSection4:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL + (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_CC + (cAliasQry)->RA_CARGO  == cParam },{||(cAliasQry)->RA_FILIAL + (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_CC + (cAliasQry)->RA_CARGO})

//��������������������������������������������������������������Ŀ
//�Filtro Filial,Grupo,CC, Cargo e Mat.Func para Fator    		 �
//����������������������������������������������������������������
oSection5:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL + (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_CC + (cAliasQry)->RA_CARGO + (cAliasQry)->RA_MAT == cParam },{||(cAliasQry)->RA_FILIAL + (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_CC + (cAliasQry)->RA_CARGO + (cAliasQry)->RA_MAT })

//��������������������������������������������������������������Ŀ
//�Filtro Filial,Grupo,CC, Cargo, Mat.Func e Fator para Descricao�
//����������������������������������������������������������������
oSection6:SetParentFilter({|cParam|(cAliasQry)->RA_FILIAL + (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_CC + (cAliasQry)->RA_CARGO + (cAliasQry)->RA_MAT + (cAliasQry)->Q8_FATOR == cParam }	,{||(cAliasQry)->RA_FILIAL + (cAliasQry)->Q3_GRUPO + (cAliasQry)->RA_CC + (cAliasQry)->RA_CARGO + (cAliasQry)->RA_MAT + (cAliasQry)->Q8_FATOR})

oSection2:SetParentQuery()
oSection3:SetParentQuery()
oSection4:SetParentQuery()
oSection5:SetParentQuery()
oSection6:SetParentQuery()

//-- Define o total da regua da tela de processamento do relatorio
oReport:SetMeter( (cAliasQry)->( RecCount() ) )

oSection1:Print() //alterado para Print automatico do relatorio, pois a logica usada anteriormente eh identica ao que o TReport faz.

Return Nil
