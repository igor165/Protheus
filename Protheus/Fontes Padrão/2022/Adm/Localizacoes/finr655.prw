#INCLUDE "finr655.ch"
/*/
����������������������������������������������������������������������������
����������������������������������������������������������������������������
������������������������������������������������������������������������Ŀ��
���Fun��o    � FINR655  � Autor �Bruno Sobieski        � Data � 23.05.08 ���
������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de titulos vs cobrancas duvidosas                 ���
������������������������������������������������������������������������Ĵ��
���Sintaxe e � FINR655(void)                                             ���
������������������������������������������������������������������������Ĵ��
���Parametros�                                                           ���
�������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������
����������������������������������������������������������������������������
/*/

Function FINR655()
Local oReport
#IFDEF TOP
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport	:= ReportDef()
	oReport:PrintDialog()
#ELSE
	Aviso(STR0003,STR0004,{STR0005}) //"Nao disponivel"###"Este relatorio so esta disponivel para ambientes com banco de dados relacional"###"Ok"
#ENDIF
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Bruno Sobieski         � Data �23.05.2008���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport,oSection1,oSection2
Local cReport := "FINR655"
Local cTitulo := OemToAnsi(STR0006)  //"Titulos vs Provisoes para cobranca duvidosa"
Local cDescri := OemToAnsi(STR0001) //"Este relatorio imprime os titulos a receber conforme parametros selecionado pelo usuario, e as provisoes geradas para estes titulos"

Pergunte( "FINR655001" , .F. )
                   
oReport  := TReport():New( cReport, cTitulo, 'FINR655001' , { |oReport| ReportPrint( oReport ) }, cDescri )
oReport:SetLandScape()

//������������������������������������������������������Ŀ
//� Define a 1a. secao do relatorio Valores nas Moedas   �
//��������������������������������������������������������

oSection1 := TRSection():New( oReport,STR0007 , {"QRYSE1"})  //"Titulos"

TRCell():New( oSection1, "E1_CLIENTE" 	,"QRYSE1", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "E1_LOJA" 	  	,"QRYSE1", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "E1_EMIS1"		,"QRYSE1",  ,/*Picture*/,,/*lPixel*/,)
TRCell():New( oSection1, "E1_VENCREA"	,"QRYSE1",  ,/*Picture*/,,/*lPixel*/,)
TRCell():New( oSection1, "E1_PREFIXO"	,"QRYSE1", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "E1_NUM" 		,"QRYSE1", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "E1_PARCELA"	,"QRYSE1"	, ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "E1_TIPO" 		,"QRYSE1", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "E1_VALOR"		,"QRYSE1", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "E1_MOEDA"		,"QRYSE1", ,/*Picture*/, ,/*lPixel*/,)	
TRCell():New( oSection1, "E1_SALDO"		,"QRYSE1", ,/*Picture*/, ,/*lPixel*/,)	
oSection1:SetHeaderPage(.T.)
oSection2 := TRSection():New( oSection1,STR0002 , {"FIA"}) //'Provisoes'
TRCell():New( oSection2, "FIA_DTPROV" 	,"QRYSE1" )
TRCell():New( oSection2, "FIA_VALOR"	,"QRYSE1" )	
TRCell():New( oSection2, "FIA_VLLOC"	,"QRYSE1" )	
TRCell():New( oSection2, "FIA_SEQ"		,"QRYSE1" )	
oSection2:SetHeaderPage(.T.)
 

Return oReport
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ReportPrint Autor � Bruno Sobieski       � Data � 23.05.08 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Impressao do TREPORT                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oReport : Objeto Report                                    ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

Static Function ReportPrint( oReport )
Local oSection1 := oReport:Section(1)
Local oSection2 := oSection1:Section(1)
MaKeSqlExpr("FINR655001")

	oSection1:BeginQuery()

	BeginSql alias "QRYSE1"
		SELECT E1_CLIENTE,E1_LOJA,E1_EMIS1,E1_VENCREA,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_VALOR,E1_MOEDA,E1_SALDO,
					 FIA_CLIENT,FIA_LOJA,FIA_PREFIX,FIA_NUM,FIA_PARCEL,FIA_TIPO,
					FIA_DTPROV, FIA_VALOR, FIA_SEQ, FIA_VLLOC
  	FROM %table:SE1% SE1,%table:FIA% FIA
		WHERE 	E1_FILIAL = %xfilial:SE1% AND
					FIA_FILIAL = %xfilial:FIA% AND
					FIA_DTPROV BETWEEN %exp:Dtos(mv_par04)% AND %exp:Dtos(mv_par05)% AND
					E1_VENCREA BETWEEN %exp:Dtos(mv_par06)% AND %exp:Dtos(mv_par07)% AND
  				FIA_CLIENT=		E1_CLIENTE AND 
  				FIA_LOJA	=   E1_LOJA 	 AND 
  				FIA_PREFIX=   E1_PREFIXO AND 
  				FIA_NUM		=   E1_NUM		 AND 
  				FIA_PARCEL=   E1_PARCELA AND 
  				FIA_TIPO	=   E1_TIPO 	 AND 
			  	SE1.%notDel% AND                                                              
			  	FIA.%notDel%
			  	ORDER BY E1_CLIENTE,E1_LOJA,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,FIA_DTPROV
	EndSql

	/*
	Prepara relatorio para executar a query gerada pelo Embedded SQL passando como 
	parametro a pergunta ou vetor com perguntas do tipo Range que foram alterados 
	pela funcao MakeSqlExpr para serem adicionados a query
	*/
	oSection1:EndQuery({mv_par01,mv_par02,mv_par03})

	oSection2:SetParentQuery(.T.)
	oSection2:SetParentFilter({|cParam|  QRYSE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) >= cParam .And. QRYSE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) <= cParam },{|| QRYSE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO) })
	oSection1:Print()

Return