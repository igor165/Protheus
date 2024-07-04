#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRMR090.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TRMR090  � Autor � Eduardo Ju            � Data � 05/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Calendario de Cursos.                         ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TRMR090                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�31/07/14�TPZWAO�AIncluido o fonte da 11 para a 12 e efetu-���
���            �        �      �ada a limpeza.                            ���
���Flavio Corre�01/09/14�TQHXL4�Ajuste no Join da query referente Filiais ���
���            �        �      �Altera�ao SXB e SX1 para trazer filial certa�
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TRMR090()

Local oReport
Local aArea := GetArea()             

Pergunte("TR090R",.F.)
oReport := ReportDef()
oReport:PrintDialog()	  

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 05.06.06 ���
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
oReport:=TReport():New("TRMR090",STR0001,"TR090R",{|oReport| PrintReport(oReport,cAliasQry)},STR0001+" "+STR0002+" "+STR0003)	//"Calendario de Cursos"#"Ser� impresso de acordo com os parametros solicitados pelo usuario"
oReport:SetTotalInLine(.F.) //Totaliza em linha
oReport:SetLandScape(.T.) 

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
oSection1 := TRSection():New(oReport,STR0011,{"RA2"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Calendario"
oSection1:SetTotalInLine(.F.)
TRCell():New(oSection1,"RA2_CALEND","RA2",STR0011)	//Codigo do Calendario 
TRCell():New(oSection1,"RA2_DESC","RA2","")		//Descricao do Calendario

//���������������������������Ŀ
//� Criacao da Segunda Secao: �
//�����������������������������
oSection2 := TRSection():New(oSection1,STR0012,{"RA2","RA1","RA9","RA0","RA7"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/) //Curso
oSection2:SetTotalInLine(.F.) 
TRCell():New(oSection2,"RA2_CURSO","RA2") 			//Codigo do Curso   
TRCell():New(oSection2,"RA1_DESC","RA1")			//Descricao do Curso
TRCell():New(oSection2,"RA2_TURMA","RA2")			//Turma
TRCell():New(oSection2,"RA2_DATAIN","RA2")			//Data Inicial
TRCell():New(oSection2,"RA2_DATAFI","RA2")			//Data Final
TRCell():New(oSection2,"RA2_ENTIDA","RA2")			//Codigo da Entidade
TRCell():New(oSection2,"RA0_DESC","RA0")			//Descricao da Entidade
TRCell():New(oSection2,"RA2_INSTRU","RA2")			//Codigo do Instrutor
TRCell():New(oSection2,"RA7_NOME","RA7")			//Nome do Instrutor
TRCell():New(oSection2,"RA2_HORARI","RA2")			//Horario 
TRCell():New(oSection2,"RA2_DURACA","RA2")			//Duracao
TRCell():New(oSection2,"RA2_UNDURA","RA2")			//Unidade de Duracao
TRCell():New(oSection2,"RA2_VAGAS","RA2",STR0017)	//Numero de Vagas
TRCell():New(oSection2,"RA2_RESERV","RA2",STR0018)	//Numero de Vagas Reservadas
TRCell():New(oSection2,"RA2_LOCAL","RA2")			//Local
TRCell():New(oSection2,"RA2_CUSTO","RA2",STR0019)	//Custo Estimado
TRCell():New(oSection2,"RA2_HORAS","RA2")			//Horas
//TRCell():New(oSection2,"RA2_REALIZ","RA2",STR0020)	 //Situacao do Treinamento  
oCell := TRCell():New(oSection2,"RA2_REALIZ","RA2",STR0020)	//Situacao do Treinamento
oCell:SetCBox("S="+STR0008+";N="+STR0009)

TRCell():New(oSection2,"RA2_SINON","RA2",STR0021)	//Codigo do Sinonimo do Curso    
TRCell():New(oSection2,"RA9_DESCR","RA9")			//Descricao do Sinonimo do Curso                                               

oSection2:SetTotalText({|| "Total de Cursos" })  
TRFunction():New(oSection2:Cell("RA2_CURSO"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)

Return oReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 30.05.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do Relatorio (Custo do Treinamento)               ���
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
Local lQuery    := .F. 
Local cWhere	:= ""
Local cOrder	:= ""
Local cFilRA1   := ""
Local cFilRA9   := ""
Local cFilRA0   := ""

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01        //  Filial                                   �
//� MV_PAR02        //  Calendario                               �
//� MV_PAR03        //  Curso                                    �
//� MV_PAR04        //  Turma                                    �
//� MV_PAR05        //  Periodo                                  �
//� MV_PAR06        //  Entidade                                 �
//� MV_PAR07        //  Instrutor                                �
//� MV_PAR08        //  Treinamento (Aberto-Baixado-Ambos)       �
//� MV_PAR09        //  Impr.Sinonimo Curso (Sim ou Nao)         �
//����������������������������������������������������������������

//����������������������������������������������Ŀ
//� Transforma parametros Range em expressao SQL �
//������������������������������������������������
MakeSqlExpr("TR090R")    

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
lQuery := .T.          
cOrder := "%RA2_FILIAL,RA2_CALEND,RA2_CURSO%"   

//����������������������������������Ŀ
//� Treinamento Aberto-Baixado-Ambos �
//������������������������������������	          
cWhere := "%%"
If MV_PAR08 == 1	//Aberto  
	cWhere := "%RA2_REALIZ <> 'S' AND%"
ElseIf MV_PAR08 == 2 //Baixado
	cWhere := "%RA2_REALIZ = 'S' AND%"
EndIf           

oReport:Section(1):BeginQuery()	
    
cFilRA1 := "% AND "+FWJoinFilial( "RA1", "RA2" )+"%"
cFilRA9 := "% AND "+FWJoinFilial( "RA9", "RA2" )+"%"
cFilRA0	:= "% AND "+FWJoinFilial( "RA2", "RA0" )+"%"



BeginSql Alias cAliasQry
	SELECT	RA2_CALEND,RA2_DESC,RA2_CURSO,RA1_DESC,RA2_TURMA,RA2_DATAIN,RA2_DATAFI,RA2_ENTIDA,
			RA0_DESC,RA2_INSTRU,RA7_NOME,RA2_HORARI,RA2_DURACA,RA2_UNDURA,RA2_VAGAS,RA2_RESERV,
			RA2_LOCAL,RA2_CUSTO,RA2_HORAS,RA2_REALIZ,RA2_SINON,RA9_DESCR		
	FROM 	%table:RA2% RA2  
	LEFT JOIN %table:RA1% RA1 
		ON RA1_CURSO = RA2_CURSO
		AND RA1.%NotDel%
		%exp:cFilRA1%              
	LEFT JOIN %table:RA9% RA9
		ON RA9_SINONI   = RA2_SINON
		AND RA9.%NotDel%
		%exp:cFilRA9%
	LEFT JOIN %table:RA0% RA0
		ON RA0_ENTIDA = RA2_ENTIDA
		AND RA0.%NotDel%		
		%exp:cFilRA0%
	LEFT JOIN %table:RA7% RA7
		ON RA7_INSTRU = RA2_INSTRU
		AND RA7.%NotDel%  
    WHERE	%exp:cWhere%
		RA2.%NotDel%   										
	ORDER BY %Exp:cOrder%                 		
EndSql

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�ExpA1 : Array com os parametros do tipo Range                           �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery({MV_PAR01,MV_PAR02,MV_PAR03,MV_PAR04,MV_PAR06,MV_PAR07})	//*Array com os parametros do tipo Range*
	
//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(RA2->(LastRec()))

//-- Utiliza a query do Pai
oSection2:SetParentQuery()
oSection2:SetParentFilter( { |cParam| (cAliasQry)->RA2_CALEND == cParam },{ || (cAliasQry)->RA2_CALEND })

//�������������������������������Ŀ
//� Suprimir o Sinonimo do Curso  �
//���������������������������������
If MV_PAR09 <> 1
	oSection2:Cell("RA2_SINON"):Disable()
	oSection2:Cell("RA9_DESCR"):Disable()
EndIf                                  

oSection1:Print()	 //Imprimir

Return Nil   

Function RetSm0()
Local cRet := SM0->M0_CODFIL

cRet := Xfilial("RA2",cRet)

Return cRet