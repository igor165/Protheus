#INCLUDE "PROTHEUS.CH"
#INCLUDE "TRMR080.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TRMR080  � Autor � Eduardo Ju            � Data � 03/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Planejamentos.                                ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TRMR080                                                    ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�31/07/14�TPZWAO�AIncluido o fonte da 11 para a 12 e efetu-���
���            �        �      �ada a limpeza.                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Function TRMR080()

Local oReport
Local aArea := GetArea()

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("TRR080",.F.)
oReport := ReportDef()
oReport:PrintDialog()	

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 03.06.06 ���
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

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport:=TReport():New("TRMR080",STR0001,"TRR080",{|oReport| PrintReport(oReport)},STR0022)	//"Custo de Treinamento"#"Ser� impresso de acordo com os parametros solicitados pelo usuario"
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
oSection1 := TRSection():New(oReport,STR0021,{"RA8"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Solicita��o de Treinamento"
oSection1:SetTotalInLine(.F.)
TRCell():New(oSection1,"RA8_FILIAL","RA8",STR0010)	//Codigo da Filial do Planejamento 
TRCell():New(oSection1,"RA8_PLANEJ","RA8",)		//Codigo do Planejamento
TRCell():New(oSection1,"RA8_DESC","RA8",STR0011)	//Descricao do Planejamento

//���������������������������Ŀ
//� Criacao da Segunda Secao: �
//�����������������������������
oSection2 := TRSection():New(oSection1,STR0020,{"RA8","RA1","SRA"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Solicita��o de Treinamento"	
oSection2:SetTotalInLine(.F.) 
TRCell():New(oSection2,"RA8_CURSO","RA8",STR0012,,15,.T.)	//Codigo do Curso   
TRCell():New(oSection2,"RA1_DESC","RA1","",,35,.T.)	  			//Descricao do Curso
TRCell():New(oSection2,"RA8_NFUNC","RA8",STR0013,,15,.T.)	//Numero de Funcionarios
TRCell():New(oSection2,"RA8_VALOR","RA8",,"@E 999,999,999.99",20,.T.)			//Valor
TRCell():New(oSection2,"RA8_HORAS","RA8",STR0014,,15,.T.)	//Horas Treinamento 
TRCell():New(oSection2,"RA8_DATA","RA8",STR0015,,20,.T.)	//Data do Planejamento
TRCell():New(oSection2,"RA8_DATADE","RA8",STR0016,,20,.T.)	//Periodo Inicial
TRCell():New(oSection2,"RA8_DATAAT","RA8",STR0017,,20,.T.)	//Periodo Final
TRCell():New(oSection2,"RA8_MAT","RA8",STR0018,,15,.T.)	//Numero de Funcionarios
TRCell():New(oSection2,"RA8_NOME","RA8",STR0019,,40,.T.)	//Nome do Funcionario

TRPosition():New(oSection2,"RA1",1,{|| xFilial("RA1") + RA8->RA8_CURSO}) 
TRPosition():New(oSection2,"SRA",1,{|| xFilial("SRA") + RA8->RA8_MAT})

//������������������������Ŀ
//� Total de Planejamento  �
//�������������������������� 
oSection2:SetTotalText({|| STR0008})	//Total do Planejamento   
TRFunction():New(oSection2:Cell("RA8_NFUNC"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection2:Cell("RA8_VALOR"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection2:Cell("RA8_HORAS" ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)

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
Static Function PrintReport(oReport)

Local cAcessaRA1:= &("{ || " + ChkRH(FunName(),"RA1","2") + "}")
Local cAcessaRA8:= &("{ || " + ChkRH(FunName(),"RA8","2") + "}")
Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)  
Local cFiltro := ""

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� MV_PAR01        //  Filial  De                               �
//� MV_PAR02        //  Filial  Ate                              �
//� MV_PAR03        //  Planejamento De                          �
//� MV_PAR04        //  Planejamento Ate                         �
//� MV_PAR05        //  Periodo De                               �
//� MV_PAR06        //  Periodo Ate                              �
//� MV_PAR07        //  Curso De                                 �
//� MV_PAR08        //  Curso Ate                                �
//����������������������������������������������������������������

If !Empty(xFilial("RA8"))
	cFiltro += "RA8_FILIAL >= '" + MV_PAR01 + "' .AND. "
	cFiltro += "RA8_FILIAL <= '" + MV_PAR02 + "' .AND. "
EndIf

cFiltro += "RA8_PLANEJ >= '" + MV_PAR03 + "' .AND. "
cFiltro += "RA8_PLANEJ <= '" + MV_PAR04 + "' .AND. "
cFiltro += "Dtos(RA8_DATADE) >= '" + Dtos(MV_PAR05) + "' .AND. "
cFiltro += "Dtos(RA8_DATADE) <= '" + Dtos(MV_PAR06) + "' .AND. "
cFiltro += "RA8_CURSO >= '" + MV_PAR07 + "' .AND. "
cFiltro += "RA8_CURSO <= '" + MV_PAR08 + "'    
 
oSection1:SetFilter(cFiltro)
oSection2:SetParentFilter({|cParam| RA8->RA8_FILIAL+RA8->RA8_PLANEJ == cParam},{|| RA8->RA8_FILIAL+RA8->RA8_PLANEJ})
oSection1:SetLineCondition(cAcessaRA8)
oSection2:SetLineCondition(cAcessaRA1)

oReport:SetMeter(RA8->(LastRec()))
oSection1:Print()

Return Nil