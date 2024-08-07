#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"  
#INCLUDE "TRM020.CH"
#INCLUDE "REPORT.CH"

/*��������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Fun��o       � TRM020   � Autor � Eduardo Ju              � Data � 24.05.06 ���
������������������������������������������������������������������������������Ĵ��
���Descri��o    � Relatorio de Treinamentos (Solicitacao)                      ���
������������������������������������������������������������������������������Ĵ��
���Uso          � TRM020                                                       ���
������������������������������������������������������������������������������Ĵ��
���Programador  � Data     � BOPS �  Motivo da Alteracao                       ���
������������������������������������������������������������������������������Ĵ��
���Cecilia Carv.�31/07/2014�TPZWAO�AIncluido o fonte da 11 para a 12 e efetuada���
���             �          �      �a limpeza.                                  ���
���Flavio Correa�01/09/2014�TQHXL4�Ajuste no Join da query referente a Filiais ���
���Thiago Y.M.N �04/02/2015�TRJPHI�Ajuste para imprimir relat�rio de impress�o ���
���             �          �      � de solicita��es de treinamento corretamen- ���
���             �          �      �te, quando h� cargos com mesmo c�digo mas   ���
���             �          �      �com centro de custos diferentes, e ajuste   ���
���             �          �      �para trata compartilhamento entre as tabe-  ���
���             �          �      �las que estava inconsistente.               ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/   
Function TRMR140()

Local oReport
Local aArea := GetArea()

Pergunte("TR020R",.F.)
oReport := ReportDef()
oReport:PrintDialog()	
RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 16.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Definicao do Componente de Impressao do Relatorio           ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2
Local aOrdem    := {}
Local cAliasQry := GetNextAlias()

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport := TReport():New("TRM020",STR0009,"TR020R",{|oReport| PrintReport(oReport,cAliasQry)},STR0017)	//"Solicita��o de Treinamento"#"Este programa tem como objetivo imprimir a Solicita��o de Treinamento conforme par�metros selecionados"
oReport:SetTotalInLine(.F.) 
oReport:SetLandscape()	//Imprimir Somente Paisagem
Pergunte("TR020R",.F.)

Aadd( aOrdem, STR0004)	// "Matricula"
Aadd( aOrdem, STR0005)	// "Centro de Custo"
Aadd( aOrdem, STR0006)	// "Nome" 

//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�TRCell():New                                                            �
//�ExpO1 : Objeto TSection que a secao pertence                            �
//�ExpC2 : Nome da celula do relat�rio. O SX3 ser� consultado              �
//�ExpC3 : Nome da tabela de referencia da celula                          �
//�ExpC4 : Titulo da celula                                                �
//�        Default : X3Titulo()                                            �
//�ExpC5 : Picture                                                         �
//�        Default : X3_PICTURE                                            �
//�ExpC6 : Tamanho                                                         �
//�        Default : X3_TAMANHO                                            �
//�ExpL7 : Informe se o tamanho esta em pixel                              �
//�        Default : False                                                 �
//�ExpB8 : Bloco de c�digo para impressao.                                 �
//�        Default : ExpC2                                                 �
//��������������������������������������������������������������������������
//���������������������������Ŀ
//� Criacao da Primeira Secao:�
//����������������������������� 
oSection1 := TRSection():New(oReport,STR0018,{"RA3","RA1"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)	//"Curso"

TRCell():New(oSection1,"RA3_CURSO","RA3",STR0018)	//Codigo do Curso    

TRCell():New(oSection1,"RA1_DESC","RA1","")		//Descricao do Curso    

//���������������������������Ŀ
//� Criacao da Segunda Secao: �
//�����������������������������

//                 1                  2                  3                           4                5                6             7             8
//TRCell():New(<oParent>	, <cName>			, [ <cAlias> ]			, [ <cTitle> ]		,[ <cPicture> ] , [ <nSize> ]	 , [ <.lPixel.> ], [ <bBlock> ],; 
//             9                    10                  11                          12               13              14             15             16
//		[ <"cAlign"> ]		, [ <.lLineBreak.> ], [ <"cHeaderAlign"> ]	, [ <.lCellBreak.> ],[ <nColSpace> ], [<.lAutoSize.>], [ <nClrBack> ], [ <nClrFore> ])

oSection2 := TRSection():New(oSection1,STR0001,{"RA3","SRA","SQ3","SQ0","SQB"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Treinamento"	
TRCell():New(oSection2,"RA3_FILIAL","RA3",STR0019)			//Filial
TRCell():New(oSection2,"RA3_MAT","RA3",STR0020,,7) 			//Matricula do Funcionario
TRCell():New(oSection2,"RA_NOME","SRA",STR0021)				//Nome do Funcionario
TRCell():New(oSection2,"Q3_GRUPO","SQ3")					//Codigo do Grupo **SUPRIMIR CAMPO
TRCell():New(oSection2,"Q0_DESCRIC","SQ0",STR0022)			//Descricao do Grupo 
TRCell():New(oSection2,"RA_DEPTO","SRA","")					//Codigo do Depto **SUPRIMIR CAMPO
TRCell():New(oSection2,"RA_DDEPTO","SRA",STR0023,,10,,{|| FDESC('SQB',SRA->RA_DEPTO,'QB_DESCRIC') })		//Descricao do Depto 
TRCell():New(oSection2,"RA_CARGO","SRA")					//Cargo:= fGetCargo(SRA->RA_MAT) **SUPRIMIR CAMPO
TRCell():New(oSection2,"RA_DCARGO","SRA",STR0024,,,,{|| DESCARCC()},,,,,,.F.)		//Descricao do Cargo  
TRCell():New(oSection2,"RA3_RESERV","RA3",STR0025)			//Status da Reserva (Reservado)
TRCell():New(oSection2,"RA3_DATA","RA3",STR0026,,12)		//Data da Solicitacao
TRCell():New(oSection2,"RA3_CALEND","RA3",STR0027)			//Calendario de Treinamento
TRCell():New(oSection2,"RA2_DESC","RA2","")					//Descricado do Calendario
TRCell():New(oSection2,"RA2_DATAIN","RA2",STR0028,,12)		//Periodo: Data Inicio do Curso
TRCell():New(oSection2,"RA2_DATAFI","RA2",,,12)				//Periodo: Data Final do Curso 
TRCell():New(oSection2,"RA3_TURMA","RA3")					//Turma     
TRCell():New(oSection2,"RA_CC","SRA")						//Centro de Custo
TRCell():New(oSection2,"CTT_DESC01","CTT","",,,,{|| RhDescCC(RA_CC)},,,,,,.F.)	//Descricao do Centro de Custo 

TRFunction():New(oSection2:Cell("RA3_MAT" ),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,"9999"/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
oSection2:SetTotalText({|| STR0029 })
oSection2:SetTotalInLine(.F.) 
oSection2:SetAutoSize()

Return oReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 19.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do Relatorio (Lista de Presenca)                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(oReport,cAliasQry)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)  
Local cFil 		:= ""
Local cMat 		:= ""
Local cCc  		:= ""
Local cNom 		:= ""
Local cCur 		:= ""
Local cGru 		:= ""
Local cDep 		:= ""
Local cCar 		:= ""
Local nNecess	:= ""
Local nFerProg  := ""
Local cSitFol   := "" 
Local nOrdem  	:= osection1:GetOrder() 
Local cTamCC	:= Space(TamSx3("RA_CC")[1])
Local lQuery    := .F. 
Local cExpressao:= ""
Local cOrder	:= ""
Local i 		:= 0

Private cSituacao	:= "" 

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr("TR020R")

//+--------------------------------------------------------------+
//� Carregando variaveis MV_PAR?? para Variaveis do Sistema.     �
//+--------------------------------------------------------------+
cFil 		:= MV_PAR01
cMat 		:= MV_PAR02
cCc  		:= MV_PAR03
cNom 		:= MV_PAR04
cCur 		:= MV_PAR05
cGru 		:= MV_PAR06
cDep 		:= MV_PAR07
cCar 		:= MV_PAR08
nNecess		:= If(!Empty(MV_PAR09),nNecess:=MV_PAR09,nNecess:=3)
cSituacao 	:= MV_PAR10
nFerProg  	:= MV_PAR11

	//-- Filtragem do relat�rio
	//-- Query do relat�rio da secao 1
	lQuery := .T.          

	If nOrdem == 1		// Matricula 
		cOrder := "%RA3_CURSO,RA3_FILIAL,RA3_MAT%"	//"TR_FILIAL + TR_CURSO + TR_MAT"
	ElseIf nOrdem == 2	// Centro de Custo + Matricula
		cOrder := "%RA3_CURSO,RA3_FILIAL,RA_CC,RA3_MAT%"
	Else				// Nome	
		cOrder := "%RA3_CURSO,RA3_FILIAL,RA_NOME%"
	EndIf

	oReport:Section(1):BeginQuery()	
	
	cFilRA1 := "% AND "+FWJoinFilial( "RA1", "RA3" )+"%"
	cFilRA2 := "% AND "+FWJoinFilial( "RA2", "RA3" )+"%"
	cFilSRA := "% AND "+FWJoinFilial( "SRA", "RA3" )+"%"
	cFilSQ3 := "% AND "+FWJoinFilial( "SQ3", "SRA" )+"%"
	cFilSQ0 := "% AND "+FWJoinFilial( "SQ0", "SQ3" )+"%"
	cFilSRJ := "% AND "+FWJoinFilial( "SRA", "SRJ" )+"%"
		
	If !Empty(MV_PAR01)	
   		cExpressao:= MV_PAR01
	EndIf
	
	If !Empty(MV_PAR02)		
		cExpressao += Iif(!Empty(cExpressao)," AND ","")
		cExpressao += MV_PAR02
	EndIf
	
	If !Empty(MV_PAR03)	
		cExpressao += Iif(!Empty(cExpressao)," AND ","")
		cExpressao += MV_PAR03 
	EndIf
	
	If !Empty(MV_PAR04)	
		cExpressao += Iif(!Empty(cExpressao)," AND ","")
		cExpressao += MV_PAR04
	EndIf
	
	If !Empty(MV_PAR05)	
		cExpressao += Iif(!Empty(cExpressao)," AND ","")
		cExpressao += MV_PAR05
	EndIf
	
	If !Empty(MV_PAR06)	
		cExpressao += Iif(!Empty(cExpressao)," AND ","")
		cExpressao += MV_PAR06
	EndIf
	
	If !Empty(MV_PAR07)	
		cExpressao += Iif(!Empty(cExpressao)," AND ","")
		cExpressao += MV_PAR07
	EndIf
	
	If !Empty(MV_PAR08)	
		cExpressao += Iif(!Empty(cExpressao)," AND ","")
		cExpressao += MV_PAR08
	EndIf
	
	If nNecess == 1 //Necessidade do Cargo
		cExpressao += Iif(!Empty(cExpressao)," AND ","") + "EXISTS ( SELECT 1 FROM " + RetSqlName("RA5") + " RA5 WHERE RA5_CARGO = Q3_CARGO AND ( (RA5_CC = RA_CC) or (RA5_CC = '" + cTamCC + "')) AND RA5_CURSO = RA3_CURSO )"
	ElseIf nNecess == 2	//Solicitacao	
		cExpressao += Iif(!Empty(cExpressao)," AND ","") + "NOT EXISTS ( SELECT 1 FROM " + RetSqlName("RA5")  + " RA5 WHERE RA5_CARGO = Q3_CARGO AND ( (RA5_CC = RA_CC) or (RA5_CC = '" + cTamCC + "')) AND RA5_CURSO = RA3_CURSO )" 
	EndIf	
		
	If !Empty(cExpressao)
		cExpressao += " AND "
	EndIf
	
	cExpressao := "%"+cExpressao+"%"
	
	BeginSql Alias cAliasQry
	
		SELECT DISTINCT	RA3_FILIAL,RA3_CURSO,RA1_DESC,RA3_MAT,RA3_DATA,RA_NOME,Q3_GRUPO,Q0_DESCRIC,Q3_DEPTO,
				QB_DESCRIC,Q3_CARGO,Q3_DESCSUM,RA3_RESERV,RA3_CALEND,RA2_DESC,
				RA2_DATAIN,RA2_DATAFI,RA3_TURMA,RA_CC/*,I3_DESC*/
		FROM 	%table:RA3% RA3		  
		INNER JOIN %table:RA1% RA1
			ON RA1_CURSO = RA3_CURSO
			AND RA1.%NotDel% 
			%exp:cFilRA1%
		LEFT JOIN %table:RA2% RA2
			ON RA2_CALEND = RA3_CALEND
			AND RA2_CURSO = RA3_CURSO
			AND RA2_TURMA = RA3_TURMA
			AND RA2.%NotDel% 
			%exp:cFilRA2%  	  
		INNER JOIN %table:SRA% SRA
			ON RA_MAT = RA3_MAT
			AND SRA.%NotDel% 
			%exp:cFilSRA%  
		INNER JOIN %table:SQ3% SQ3
			ON Q3_CARGO = RA_CARGO
			AND SQ3.%NotDel%			 								
			%exp:cFilSQ3% 
		INNER JOIN %table:SQ0% SQ0
			ON Q0_GRUPO = Q3_GRUPO
			AND SQ0.%NotDel%
			%exp:cFilSQ0% 
		LEFT JOIN %table:SQB% SQB
			ON QB_FILIAL = %xFilial:SQB%
			AND QB_DEPTO = Q3_DEPTO
			AND SQB.%NotDel%					
		WHERE 	%exp:cExpressao%
				RA3.%NotDel%  //Se remover essa expressao podera ocorrer erro na compilacao

	   	UNION 

		SELECT DISTINCT RA3_FILIAL,RA3_CURSO,RA1_DESC,RA3_MAT,RA3_DATA,RA_NOME,Q3_GRUPO,Q0_DESCRIC,Q3_DEPTO,
				QB_DESCRIC,Q3_CARGO,Q3_DESCSUM,RA3_RESERV,RA3_CALEND,RA2_DESC,
				RA2_DATAIN,RA2_DATAFI,RA3_TURMA,RA_CC
		FROM 	%table:RA3% RA3		 
		 
		INNER JOIN %table:RA1% RA1
			ON RA1_CURSO = RA3_CURSO
			AND RA1.%NotDel% 
			%exp:cFilRA1%
		LEFT JOIN %table:RA2% RA2
			ON RA2_CALEND = RA3_CALEND
			AND RA2_CURSO = RA3_CURSO
			AND RA2_TURMA = RA3_TURMA
			AND RA2.%NotDel%
			%exp:cFilRA2%  
		INNER JOIN %table:SRA% SRA
			ON RA_MAT = RA3_MAT
			AND SRA.%NotDel% 
			%exp:cFilSRA%  
		INNER JOIN %table:SRJ% SRJ
			ON RJ_FUNCAO = RA_CODFUNC
			AND SRJ.%NotDel%
			%exp:cFilSRJ% 
		INNER JOIN %table:SQ3% SQ3
			ON Q3_CARGO = RJ_CARGO
			AND SQ3.%NotDel%
			%exp:cFilSQ3% 
		INNER JOIN %table:SQ0% SQ0
			ON Q0_GRUPO = Q3_GRUPO
			AND SQ0.%NotDel%
			%exp:cFilSQ0% 
		LEFT JOIN %table:SQB% SQB
			ON QB_FILIAL = %xFilial:SQB%
			AND QB_DEPTO = Q3_DEPTO
			AND SQB.%NotDel%					 	
		WHERE RA_CARGO = '     ' AND
			%exp:cExpressao%
			RA3.%NotDel% //Se remover essa expressao podera ocorrer erro na compilacao
		  										
		ORDER BY %Exp:cOrder%                 		
	EndSql
	
	//������������������������������������������������������������������������Ŀ
	//�Metodo EndQuery ( Classe TRSection )                                    �
	//�Prepara o relat�rio para executar o Embedded SQL.                       �
	//�ExpA1 : Array com os parametros do tipo Range                           �
	//��������������������������������������������������������������������������
	oReport:Section(1):EndQuery()
		
	//-- Inicio da impressao do fluxo do relat�rio
	oReport:SetMeter(RA3->(LastRec()))

	//-- Utiliza a query do Pai
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( { |cParam| (cAliasQry)->RA3_CURSO == cParam },{ || (cAliasQry)->RA3_CURSO })
	
	//Valida Situacao do Funcionario 
	oSection2:SetLineCondition({|| fChkSit(cAliasQry)})

	oSection2:Cell("Q3_GRUPO"):Disable()
	oSection2:Cell("RA_DEPTO"):Disable()
	oSection2:Cell("RA_CARGO"):Disable()
	oSection1:Print()	 //Imprimir
	
Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �fChkSit     � Autor � Eduardo Ju          � Data � 10.10.07 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Checa a Situacao do Funcionario                             ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TRM020                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function fChkSit(cAliasQry)   

Local aSaveArea	:= GetArea()
Local lChkSit	:= .F.  

SRA->(dbSeek( (cAliasQry)->RA3_FILIAL+(cAliasQry)->RA3_MAT ))
lChkSit := TrmSitFol( If(Empty((cAliasQry)->RA2_DATAIN),(cAliasQry)->RA3_DATA,(cAliasQry)->RA2_DATAIN)) $ cSituacao
       
RestArea(aSaveArea)

Return(lChkSit)
