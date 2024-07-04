#INCLUDE "Protheus.ch"
#INCLUDE "CSAR040.CH"      

/*
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � CSAR040  � Autor � Eduardo Ju            � Data � 07/08/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Pontuacao de Funcionarios                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � CSAR040                                                    ���
�������������������������������������������������������������������������Ĵ��            
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�30/07/14�TPZVV4�Incluido o fonte da 11 para a 12 e efetua-���
���            �        �      �da a limpeza.                             ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/  

Function CSAR040()

Local oReport
Local aArea := GetArea()
Private nTotFunc 	:= 0 
Private nTotCarg 	:= 0

Pergunte("CSR40R",.F.)
oReport := ReportDef()
oReport:PrintDialog()	

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 07/08/06 ���
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
oReport:=TReport():New("CSAR040",STR0001,"CSR40R",{|oReport| PrintReport(oReport)},OemToAnsi(STR0025)+" - "+STR0002+" "+STR0003)	//"Rela��o de Pontos do Cargo e do Funcion�rio"#"Ser� impresso de acordo com os parametros solicitados pelo usuario"
Pergunte("CSR40R",.F.)

Aadd( aOrdem, STR0004)	// "Filial + Matricula"
Aadd( aOrdem, STR0005)	// "Nome"                 
Aadd( aOrdem, STR0006)	// "C.Custo+Nome"         
Aadd( aOrdem, STR0007)	// "Funcao + Nome" 
//-- Foi desabilitada a ordem por pontos pois na R4 nao tem como ordernar por pontos.
//Aadd( aOrdem, STR0008)	// "Pontos"

//�������������������������������������������������������Ŀ
//� Criacao da Primeira Secao: "Pontuacao do Funcionario" �
//��������������������������������������������������������� 
oSection1 := TRSection():New(oReport,STR0013,{"SRA","SQ8","SQ3","SQ4"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)	
oSection1:SetTotalInLine(.F.)  
oSection1:SetHeaderBreak(.T.)    

TRCell():New(oSection1,"RA_FILIAL","SRA")					//Filial do Funcionario
TRCell():New(oSection1,"RA_MAT","SRA",STR0019)				//Matricula do Funcionario
TRCell():New(oSection1,"RA_NOME","SRA","")					//Nome do Funcionario
TRCell():New(oSection1,"Q4_PONTOS","SQ4",STR0020,,,,{|| Cs040TotCarg() })//Pontos do Cargo 
TRCell():New(oSection1,"Q8_PONTOS","SQ8",STR0021,,10,,{|| Cs040TotFunc() })//Pontos do Funcionario 
TRCell():New(oSection1,"NUM_ANOS","   ",STR0022,,10,,{|| Cs040Anos() }) //Meses/Anos Trabalhados
TRCell():New(oSection1,"VARIAC","   ",STR0023,"@E 999.99",8,,{|| Round((nTotFunc/nTotCarg ) *100,2) }) //Meses/Anos Trabalhados

//������������������������Ŀ
//� Total de Funcionarios  �
//�������������������������� 
oSection1:SetTotalText({|| STR0024})	//Total de Funcionarios   
TRFunction():New(oSection1:Cell("RA_MAT"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection1:Cell("Q4_PONTOS"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,"@E 9999.99",/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection1:Cell("Q8_PONTOS"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

Return oReport 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ReportDef() � Autor � Eduardo Ju          � Data � 07.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Impressao do Relatorio                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function PrintReport(oReport)

Local oSection1 := oReport:Section(1)
Local nOrdem  	:= osection1:GetOrder()
Local cFiltro   := "" 
Local cArq1   	:= ""
Local cArq2  	:= ""
Local cArq3   	:= ""
Local cArq4   	:= ""
Local cArq5   	:= ""
Local cInd		:= ""

//�������������������������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                                          �
//� mv_par01        //  Filial?                                                   �
//� mv_par02        //  Centro de Custo ?                                         �
//� mv_par03        //  Funcao?                                                   �
//� mv_par04        //  Dt.Admissao?                                              �
//� mv_par05        //  Listar Func.com? 1-Pontos Acima; 2-Pontos Abaixo; 3-Ambos �
//��������������������������������������������������������������������������������� 

//������������������������������������������������������Ŀ
//� Transforma parametros Range em expressao (intervalo) �
//��������������������������������������������������������
MakeAdvplExpr("CSR40R")	                                  

If !Empty(mv_par01)	//RA_FILIAL
	cFiltro:= mv_par01
EndIf  

If !Empty(mv_par02)	//RA_CC
	cFiltro += Iif(!Empty(cFiltro)," .AND. ","")
	cFiltro += mv_par02
EndIf  

If !Empty(mv_par03) //RA_CODFUNC
	cFiltro += Iif(!Empty(cFiltro)," .AND. ","")
	cFiltro += mv_par03
EndIf

If !Empty(mv_par04) //RA_ADMISSA
	cFiltro += Iif(!Empty(cFiltro)," .AND. ","")
	cFiltro += mv_par04
EndIf              
           
cFiltro += Iif(!Empty(cFiltro)," .AND. ","")
cFiltro += 'RA_SITFOLH $ "'+ " *A*F" + '"	
    
//����������������������Ŀ
//� Ordem do Relatorio   � 
//� 1-Filial+Matricula   �
//� 2-Nome               �
//� 3-C.Custo + Nome     �
//� 4-Funcao + Nome      �
//� 5-Pontos do Cargo    �
//������������������������
//Obs.: Nao sera considerado Ordem 5 no RP-R4
//cInd := 'TR_PONCAR'
//cArq5 := CriaTrab(Nil, .F.)                                                 
//IndRegua("SRA",cArq5,cInd,,,STR0018) //"Selecionando Registros..." 

If nOrdem == 1
	cInd := 'RA_FILIAL + RA_MAT'
ElseIf nOrdem == 2
	cInd := 'RA_NOME'
ElseIf nOrdem == 3
	cInd := 'RA_CC + RA_NOME'
ElseIf nOrdem == 4
	cInd := 'RA_CODFUNC + RA_NOME'
EndIf

oSection1:SetFilter(cFiltro, cInd) 
 
DbSelectArea("SRA")
DbSetOrder(nOrdem)

//�����������������������������������������������������������Ŀ
//� Listar Func.com? 1-Pontos Acima; 2-Pontos Abaixo; 3-Ambos �
//�������������������������������������������������������������
If mv_par05 == 1
	oSection1:SetLineCondition({|| oSection1:EvalCell(), mv_par05 == 1 .And. oSection1:Cell("VARIAC"):GetValue(.T.) >= 100 })
ElseIf mv_par05 == 2
	oSection1:SetLineCondition({|| oSection1:EvalCell(), mv_par05 == 2 .And. oSection1:Cell("VARIAC"):GetValue(.T.) <= 100 })	   	
EndIf	

oReport:SetMeter(SRA->(LastRec()))	
oSection1:Print() //Imprimir  	

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Cs040Anos() � Autor � Eduardo Ju          � Data � 07.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Calcula Tempo de Servico no Emprego Atual                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CSAR040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function Cs040Anos() 

Local nMeses 	:= 0
Local cSvAlias 	:= Alias()

If !Empty(SRA->RA_DEMISSA)
	nMeses := SRA->RA_DEMISSA - SRA->RA_ADMISSA	
Else
	nMeses := dDataBase - SRA->RA_ADMISSA
Endif	
	
nMeses := Noround(nMeses/365,2)

DbSelectArea(cSvAlias)

Return nMeses 

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �Cs040TotCarg� Autor � Eduardo Ju          � Data � 07.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Somatoria da Pontuacao do Cargo.                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CSAR040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function Cs040TotCarg()

Local nx		:= 0
Local cSvAlias 	:= Alias()
Local aFator	:= {}   

nTotCarg := 0

FMontaFator(SRA->RA_FILIAL,SRA->RA_CODFUNC,,SRA->RA_MAT,,,@aFator,SRA->RA_CC)

For nx := 1 To Len(aFator)
	nTotCarg := nTotCarg + aFator[nx][5]	//5 Pontos do Cargo		
Next nx

DbSelectArea(cSvAlias)

Return nTotCarg        

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �Cs040TotFunc� Autor � Eduardo Ju          � Data � 07.08.06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Somatoria da Pontuacao do Funcionario                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CSAR040                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function Cs040TotFunc()

Local nx			:= 0
Local cSvAlias 		:= Alias()
Local aFator		:= {}  

nTotFunc 	:= 0

FMontaFator(SRA->RA_FILIAL,SRA->RA_CODFUNC,,SRA->RA_MAT,,,@aFator,SRA->RA_CC)

For nx := 1 To Len(aFator)
	nTotFunc := nTotFunc + aFator[nx][8]	//8 Pontos do Funcionario
Next nx

DbSelectArea(cSvAlias)

Return nTotFunc