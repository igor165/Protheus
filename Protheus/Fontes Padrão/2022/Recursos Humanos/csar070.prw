#INCLUDE "Protheus.CH"
#INCLUDE "CSAR070.CH"        
#INCLUDE "Report.ch"

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CSAR070  � Autor � Emerson Grassi Rocha  � Data � 19/06/2006 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Tabela Salarial (Grafico)                       ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSAR070(void)                                                ���
���������������������������������������������������������������������������Ĵ��
���Parametros�                                                              ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���Cecilia Car.�30/07/2014�TPZVV4�Incluido o fonte da 11 para a 12 e efetua-���
���            �          �      �da a limpeza.                             ���
���Allyson M   �24/06/2016�TVLFGZ�Ajuste p/ executar xFilial() no filtro de ���
���            �          �      �filial da RBR e executar FwJoinFilial()   ���
���            �          �      �nos joins                                 ���
���Willian U.  �23/06/2017�DRHPONTP-1031�Gera o relat�rio em Excel modo     ���
���            �          �             �tabela, com a repeti��o de todas as���
���            �          �             �classes, sem alterar o leiaute do  ���
���            �          �             �relat�rio padr�o.                  ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function CSAR070()
Local oReport
Local aArea := GetArea()

Private cAliasQry	:= "RBR"

pergunte("CSR071",.F.)
oReport := ReportDef()
oReport:PrintDialog()	
RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Emerson Grassi Rocha� Data � 19/06/06 ���
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
Local oSection3
Local aOrdem    := {}

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport:=TReport():New("CSAR070",STR0001,"CSR071",{|oReport| PrintReport(oReport)},OemToAnsi(STR0014))	
//"Impressao de Tabela Salarial."###"Este relatorio lista a Tabela Salarial conforme Nivel e Classe selecionados pelo usuario."
oReport:SetTotalInLine(.F.) 

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
oSection1 := TRSection():New(oReport,OemToAnsi(STR0007),{"RBR"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Tabela Salarial"
oSection1:SetTotalInLine(.F.)
TRCell():New(oSection1,"RBR_FILIAL","RBR")	//"Filial da Tabela Salarial"
TRCell():New(oSection1,"RBR_TABELA","RBR",STR0011)	//"Codigo da Tabela Salarial"
TRCell():New(oSection1,"RBR_DESCTA","RBR","")		//Descricao da Tabela
TRCell():New(oSection1,"RBR_DTREF","RBR",,,13)	//Data de Referencia da Tabela Salarial
TRCell():New(oSection1,"RBR_VLREF","RBR",,"@E 999,999,999.99",18,.T.,,"LEFT")	//Valor de Referencia da Tabela Salarial
TRCell():New(oSection1,"RBR_APLIC","RBR",STR0017,,12,,{|| If ( (cAliasQry)->RBR_APLIC == "1",STR0018,STR0019 ) }) //"Situacao da Tabela"#"Aplicada"#"N�o Aplicada" 

oSection1:SetLineStyle()  

//���������������������������Ŀ
//� Criacao da Segunda Secao: �
//�����������������������������
oSection2 := TRSection():New(oSection1,OemToansi(STR0015),{"RB6","RBR","RBF","SQ3"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//Classes e Cargos
oSection2:SetTotalInLine(.F.) 
TRCell():New(oSection2,"RB6_CLASSE","RB6")			//Classe Salarial
TRCell():New(oSection2,"RBF_DESC","RBF","")		//Descricao da Classe
TRCell():New(oSection2,"Q3_CARGO","SQ3",STR0010) 	//Cargo
TRCell():New(oSection2,"Q3_DESCSUM","SQ3","")		//Descricao do Cargo   
oSection2:SetLeftMargin(3)

//���������������������������Ŀ
//� Criacao da Terceira Secao:�
//�����������������������������
oSection3 := TrSection():New(oSection1,OemToAnsi(STR0016),{"RB6","RBR"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Niveis, Faixas e Pontos"
TRCell():New(oSection3,"RB6_NIVEL","RB6",STR0012)	//"Nivel"
TRCell():New(oSection3,"RB6_FAIXA","RB6",STR0013)	//"Faixa"
TRCell():New(oSection3,"RB6_COEFIC","RB6")			//"Coeficiente da Faixa"
TRCell():New(oSection3,"RB6_VALOR","RB6")			//Valor
TRCell():New(oSection3,"RB6_PTOMIN","RB6",STR0009)	//"Pontos"
TRCell():New(oSection3,"RB6_PTOMAX","RB6","")		//
oSection3:SetLeftMargin(5)

Return oReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �PrintReport � Autor � Emerson Grassi Rocha� Data � 19/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do Relatorio (Tabela Salarial)		              ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(oReport)

Local cAcessaRBR:= &("{ || " + ChkRH(FunName(),"RBR","2") + "}")
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)  
Local oSection3 := oReport:Section(1):Section(2)

Local cTab		:= ""
Local cFilRbf	:= ""
Local cFilRb6	:= ""
Local cFilSq3	:= "" 
Local cAliasSq3	:= ""

//������������������������������������������������������������������Ŀ
//� Variaveis utilizadas na pergunte                                 �
//� mv_par01				// Filial De                             �
//� mv_par02				// Filial Ate                            �
//� mv_par03				// Tabela Salarial De                    �
//� mv_par04				// Tabela Salarial Ate                   �
//� mv_par05				// Data de Referencia De                 �
//� mv_par06				// Data de Referencia Ate                �
//� mv_par07				// Nivel da Tabela De                    �
//� mv_par08				// Nivel da Tabela Ate                   �
//� mv_par09				// Classe Salarial De 					 �
//� mv_par10				// Classe Salarial Ate 					 �
//� mv_par11				// Listar Cargos    	 				 �
//��������������������������������������������������������������������
Local cFiltro	:= ""
Local lQuery    := .F. 
Local cWhere	:= ""
Local cOrder	:= ""                                                                                  

//�������������������������������Ŀ
//� Suprimir os Cargos		      �
//���������������������������������
If mv_par11 == 2
	oSection2:Cell("Q3_CARGO"):Disable()
	oSection2:Cell("Q3_DESCSUM"):Disable()
EndIf                   
        
//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
lQuery := .T.          
cAliasQry := GetNextAlias()
cAliasSq3 := GetNextAlias()

cFilRb6 := "%AND " + FWJoinFilial("RB6", "RBR") + "%"
cFilRbf := "%AND " + FWJoinFilial("RBF", "RBR") + "%"
cFilSq3 := "%AND " + FWJoinFilial("SQ3", "RBR") + "%"
	
BEGIN REPORT QUERY oSection1

BeginSql Alias cAliasQry

	SELECT 	RBR_FILIAL,RBR_TABELA,RBR_DESCTA,RBR_DTREF,RBR_VLREF,RBR_APLIC,RB6_FILIAL,RB6_TABELA,
			RB6_CLASSE,RBF_DESC,RB6_NIVEL,RB6_COEFIC,RB6_FAIXA,RB6_VALOR,RB6_PTOMIN,RB6_PTOMAX
	FROM 	%table:RBR% RBR
	                                                                                                                
	LEFT JOIN %table:RB6% RB6
		ON  RB6_TABELA = RBR_TABELA %Exp:cFilRb6%
		AND RB6_DTREF = RBR_DTREF
		AND RB6.%NotDel%  
	
	LEFT JOIN %table:RBF% RBF
		ON  RBF_CLASSE = RB6_CLASSE %Exp:cFilRbf%
		AND RBF.%NotDel%  
	WHERE RBR_FILIAL 	>= %Exp:xFilial("RBR", mv_par01)% AND RBR_FILIAL 	<= %Exp:xFilial("RBR", mv_par02)%
		AND RBR_TABELA 	>= %Exp:mv_par03% AND RBR_TABELA 	<= %Exp:mv_par04%
		AND RBR_DTREF 	>= %Exp:mv_par05% AND RBR_DTREF 	<= %Exp:mv_par06%			
		AND RB6_NIVEL 	>= %Exp:mv_par07% AND RB6_NIVEL 	<= %Exp:mv_par08%
		AND RB6_CLASSE 	>= %Exp:mv_par09% AND RB6_CLASSE	<= %Exp:mv_par10%			
		AND RBR.%NotDel%   										
	ORDER BY RBR_FILIAL,RBR_TABELA,RBR_DTREF,RB6_NIVEL,RB6_FAIXA,RB6_CLASSE
EndSql

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�ExpA1 : Array com os parametros do tipo Range                           �
//��������������������������������������������������������������������������
END REPORT QUERY oSection1 

BEGIN REPORT QUERY oSection2

BeginSql Alias cAliasSQ3

	SELECT DISTINCT RBR_FILIAL,RBR_TABELA,RBR_DTREF,RB6_CLASSE,Q3_CARGO, Q3_DESCSUM,RBF_DESC
	FROM 	%table:RBR% RBR
	
	LEFT JOIN %table:RB6% RB6   
		ON RB6_TABELA = RBR.RBR_TABELA 	%Exp:cFilRb6% 
		AND RB6_DTREF = RBR.RBR_DTREF
		AND RB6.%NotDel% 
	
	LEFT JOIN %table:SQ3% SQ3
		ON SQ3.Q3_CLASSE = RB6.RB6_CLASSE  %exp:cFilSq3%
		AND SQ3.%NotDel%  	

	LEFT JOIN %table:RBF% RBF   
		ON RBF_CLASSE = RB6.RB6_CLASSE 	%Exp:cFilRbf%
		AND RBF.%NotDel% 
		 			 										
	WHERE RBR_FILIAL	>= %Exp:xFilial("RBR", mv_par01)% AND RBR_FILIAL 	<= %Exp:xFilial("RBR", mv_par02)% 
		AND RBR_TABELA 	>= %Exp:mv_par03% AND RBR_TABELA 	<= %Exp:mv_par04%
		AND RBR_DTREF 	>= %Exp:mv_par05% AND RBR_DTREF 	<= %Exp:mv_par06%
		AND RB6_NIVEL 	>= %Exp:mv_par07% AND RB6_NIVEL 	<= %Exp:mv_par08%
		AND RB6_CLASSE 	>= %Exp:mv_par09% AND RB6_CLASSE 	<= %Exp:mv_par10%			
		AND RB6.%NotDel%   										
		AND RBR.RBR_TABELA= %report_param: (cAliasQry)->RBR_TABELA%
		AND SQ3.Q3_TABELA = %report_param: (cAliasQry)->RBR_TABELA%
		AND RBR.RBR_DTREF = %report_param: (cAliasQry)->RBR_DTREF%
		AND RB6_CLASSE = %report_param: (cAliasQry)->RB6_CLASSE%
	ORDER BY RBR_FILIAL,RBR_TABELA,RBR_DTREF,RB6_CLASSE
EndSql

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�ExpA1 : Array com os parametros do tipo Range                           �
//��������������������������������������������������������������������������
END REPORT QUERY oSection2

oSection3:SetParentQuery()
 	oSection3:SetParentFilter({|cParam| (cAliasQry)->RBR_FILIAL+(cAliasQry)->RBR_TABELA+DTOS((cAliasQry)->(RBR_DTREF))+(cAliasQry)->RB6_CLASSE == cParam},{|| (cAliasQry)->RBR_FILIAL+(cAliasQry)->RBR_TABELA+DTOS((cAliasQry)->(RBR_DTREF))+(cAliasQry)->RB6_CLASSE}) 

lSec1First := .T.
lSec2First := .T.
/*oSection1:SetLineCondition({|| If(lSec1First, oSection1:Show(), oSection1:Hide()), ;
										 lSec1First := .F., lSec2First := .T. ,.T. })*/	
oSection1:SetLineCondition({|| lSec2First := .T., .T. })
     
//������������������������������������������������������������������������Ŀ
//�Valida��o para caso o relat�rio for impresso em Excel modo tabela.      �
//�H� repeti��o em todas as linhas dos cargos, as classes referentes mesmo �
//�que haja repeti��o.                                                     �
//��������������������������������������������������������������������������
If oReport:nDevice <> 4
	oSection2:SetLineCondition({|| fHideCargo(@oSection2, @lSec2First), 	;
								Iif(mv_par11==2 .And. Empty((cAliasSq3)->RB6_CLASSE),.F.,.T.) })
EndIf 

dbSelectArea(cAliasQry)
dbGoTop()

oReport:SetMeter((cAliasQry)->(LastRec()))

oSection1:Print()    

Return Nil

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �fHideCargo     � Autor � Tania Bronzeri   � Data �15/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ajusta opcao do Sx1                                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function fHideCargo(oSection, lFirst)

Local lRetorno := .T.
	
	If lFirst
		oSection:Cell("RB6_CLASSE"):Show()	 
		oSection:Cell("RBF_DESC"):Show()				
	Else
		oSection:Cell("RB6_CLASSE"):Hide()	 
		oSection:Cell("RBF_DESC"):Hide()				
	EndIf
	
	lFirst := .F.

Return lRetorno