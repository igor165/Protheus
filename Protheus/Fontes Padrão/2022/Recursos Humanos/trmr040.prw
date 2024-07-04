#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRMR040.CH"

/*�����������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � TRMR040  � Autor � Eduardo Ju              � Data � 09.06.06 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Materiais por Curso.                            ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � TRMR040(void)                                                ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.               ���
���������������������������������������������������������������������������Ĵ��
���Programador � Data     � BOPS �  Motivo da Alteracao                     ���
���������������������������������������������������������������������������Ĵ��
���Cecilia Car.�31/07/2014�TPZWAO�AIncluido o fonte da 11 para a 12 e efetu-���
���            �          �      �ada a limpeza.                            ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������*/
Function TRMR040()

Local oReport
Local aArea := GetArea()

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("TRR40A",.F.)
oReport := ReportDef()
oReport:PrintDialog()	

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 09.06.06 ���
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
oReport:=TReport():New("TRMR040",STR0001,"TRR40A",{|oReport| PrintReport(oReport,cAliasQry)},STR0011)	//"Este programa emite o Relatorio de Materiais por Curso"
oReport:SetTotalInLine(.F.) //Totaliza em linha

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
oSection1 := TRSection():New(oReport,STR0004,{"RAH"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Solicita��o de Treinamento"
oSection1:SetTotalInLine(.F.)     
TRCell():New(oSection1,"RAH_CURSO","RAH",STR0004)	//Codigo do Curso   
TRCell():New(oSection1,"RA1_DESC","RA1","")		//Descricao do Curso  

TRPosition():New(oSection1,"RA1",1,{|| xFilial("RA1") + RAH->RAH_CURSO}) 

//���������������������������Ŀ
//� Criacao da Segunda Secao: �
//�����������������������������
oSection2 := TRSection():New(oSection1,STR0010,{"RAH","RAG"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Solicita��o de Treinamento"	
oSection2:SetTotalInLine(.F.) 
TRCell():New(oSection2,"RAH_MATER","RAH",,,15,.T.)			//Codigo do Material
TRCell():New(oSection2,"RAG_DESC","RAG","")		//Descricao do Material
TRCell():New(oSection2,"RAH_REFER","RAH",,,15,.T.)			//Codigo da Referencia
TRCell():New(oSection2,"X5_DESCRI","SX5","",,30)	//Descricao da Referencia
TRCell():New(oSection2,"RAG_OBS","RAG")				//Observacoes

TRPosition():New(oSection2,"RAG",1,{|| xFilial("RAG") + RAH->RAH_MATER}) 
TRPosition():New(oSection2,"SX5",1,{|| xFilial("SX5") + "RI" + RAH->RAH_REFER}) 

TRFunction():New(oSection2:Cell("RAH_MATER"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

Return oReport

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 13.06.06 ���
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
Local cFiltro := ""
Local lQuery    := .F. 

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01        //  Filial  De                               �
//� MV_PAR02        //  Filial  Ate                              �
//� MV_PAR03        //  Curso De                                 �
//� MV_PAR04        //  Curso Ate                                �
//� MV_PAR05        //  Material De                              �
//� MV_PAR06        //  Material Ate                             �
//� MV_PAR07        //  Impr.Curso p/Folha                       �
//����������������������������������������������������������������

cFil := xFilial(NIL, MV_PAR01)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
lQuery := .T.          
cOrder := "%RAH_FILIAL,RAH_CURSO%"        
	
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
		
	SELECT	RAH_CURSO,RA1_DESC,RAH_MATER,RAG_DESC,RAH_REFER,X5_DESCRI,RAG_OBS								
				
	FROM 	%table:RAH% RAH  
		
	LEFT JOIN %table:RA1% RA1
		ON RA1_FILIAL = %xFilial:RA1%
		AND RA1_CURSO = RAH_CURSO
		AND RA1.%NotDel%
	LEFT JOIN %table:RAG% RAG
		ON RAG_FILIAL = %xFilial:RAG%
		AND RAG_MATER = RAH_MATER
		AND RAG.%NotDel%
	LEFT JOIN %table:SX5% SX5
		ON X5_FILIAL = %xFilial:SX5%
		AND X5_TABELA = 'RI'
		AND X5_CHAVE = RAH_REFER
		AND SX5.%NotDel%	
		
	WHERE  RAH_FILIAL>= %Exp:cFil% AND RAH_FILIAL<= %Exp:MV_PAR02%
		AND RAH_CURSO >= %Exp:MV_PAR03% AND RAH_CURSO <= %Exp:MV_PAR04%
		AND RAH_MATER >= %Exp:MV_PAR05% AND RAH_MATER <= %Exp:MV_PAR06%			
		AND RAH.%NotDel%   	
											
	ORDER BY %Exp:cOrder%                 		
		
EndSql
	
//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�ExpA1 : Array com os parametros do tipo Range                           �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)	
		
//�������������������������������������������Ŀ
//� Inicio da impressao do fluxo do relat�rio �
//���������������������������������������������
oReport:SetMeter(RAH->(LastRec()))

//�������������������������Ŀ
//� Utiliza a query do Pai  �
//���������������������������
oSection2:SetParentQuery()
oSection2:SetParentFilter( { |cParam| (cAliasQry)->RAH_CURSO == cParam },{ || (cAliasQry)->RAH_CURSO })
	
//���������������������������Ŀ
//� Imprime Curso por Pagina  �
//�����������������������������
If MV_PAR07 == 1   
	oBreak := TRBreak():New(oSection1,oSection1:Cell("RAH_CURSO"),"",.F.) 
	oBreak:SetPageBreak(.T.)	
EndIf
	
oSection1:Print()	 //Imprimir

Return Nil