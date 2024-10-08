#INCLUDE "TMSR260.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR260  � Autor � Eduardo de Souza      � Data � 26/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime relacao de motoristas (telerisco).				  ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR260()

Local oReport
Local aArea := GetArea()

//-- Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()

RestArea( aArea )

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 26/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR260                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local cAliasQry 	:= GetNextAlias()
Local aOrdem    	:= {}
Local aAreaSM0  	:= SM0->(GetArea())
Local oMotorista
Local lDTX_SERMAN 	:= DTX->(FieldPos("DTX_SERMAN")) > 0

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:= TReport():New("TMSR260",STR0015,"TMR260", {|oReport| ReportPrint(oReport,cAliasQry)},STR0016) // "Relacao de Motoristas (Telerisco)" ### "Emite relacao de motoristas (Telerisco), conforme os parametros informados"
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01	 // Filial Origem                                 �
//� mv_par02	 // Data Geracao De	                             �
//� mv_par03	 // Data Geracao Ate                              �
//� mv_par04	 // Cod. Motorista De                             �
//� mv_par05	 // Cod. Motorista Ate                            �
//����������������������������������������������������������������
Pergunte(oReport:uParam,.F.)
//������������������������������������������������������������������������Ŀ
//�Criacao da secao utilizada pelo relatorio                               �
//�                                                                        �
//�TRSection():New                                                         �
//�ExpO1 : Objeto TReport que a secao pertence                             �
//�ExpC2 : Descricao da se�ao                                              �
//�ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   �
//�        sera considerada como principal para a se��o.                   �
//�ExpA4 : Array com as Ordens do relat�rio                                �
//�ExpL5 : Carrega campos do SX3 como celulas                              �
//�        Default : False                                                 �
//�ExpL6 : Carrega ordens do Sindex                                        �
//�        Default : False                                                 �
//�                                                                        �
//��������������������������������������������������������������������������
//������������������������������������������������������������������������Ŀ
//�Criacao da celulas da secao do relatorio                                �
//�                                                                        �
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
//�                                                                        �
//��������������������������������������������������������������������������
Aadd( aOrdem, STR0017 ) // "Motorista"

oFilVge:= TRSection():New(oReport,STR0018,{"DA4","DTX"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oFilVge:SetTotalInLine(.F.)
TRCell():New(oFilVge,"DTX_FILMAN","DTX",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/, {|| mv_par01 } )

oMotorista:= TRSection():New(oFilVge,STR0020,{"DA4","DTX"},/*Ordem do reltatorio*/,/*Campos do SX3*/,/*Campos do SIX*/)
oMotorista:SetTotalInLine(.F.)
oMotorista:SetTotalText(STR0023) //-- "Total Motorista"
TRCell():New(oMotorista,"DA4_NOME"  ,"DA4",STR0017   ,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oMotorista,"DA4_RG"    ,"DA4",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oMotorista,"DA4_CGC"   ,"DA4",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oMotorista,"ESTADO"    ,""   ,STR0021   ,/*Picture*/,2/*Tamanho*/,/*lPixel*/, {|| Posicione("SM0",1,(cAliasQry)->DTX_FILDCA,"M0_ESTCOB") } )
TRCell():New(oMotorista,"CODSEG"    ,""   ,STR0022   ,/*Picture*/,3/*Tamanho*/,/*lPixel*/, {|| Padr(Tabela("MA",oMotorista:Cell("ESTADO"):UPRINT,.F.),3) } )
TRCell():New(oMotorista,"DTX_FILDCA","DTX",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oMotorista,"DTX_FILMAN","DTX",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oMotorista,"DTX_MANIFE","DTX",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
If lDTX_SERMAN
	TRCell():New(oMotorista,"DTX_SERMAN","DTX",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
EndIf
TRCell():New(oMotorista,"DTX_VALMER","DTX",/*cTitle*/,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRFunction():New(oMotorista:Cell("DTX_VALMER"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)

RestArea( aAreaSM0 )

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 25/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR430                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry)

Local lDTX_SERMAN := DTX->(FieldPos("DTX_SERMAN")) > 0

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	


If lDTX_SERMAN
	BeginSql Alias cAliasQry
	SELECT DA4_FILIAL, DA4_COD, DA4_NOME, DA4_RG, DA4_CGC, DTX_FILDCA, DTX_FILMAN, DTX_MANIFE, DTX_SERMAN, MAX(DTX_VALMER) DTX_VALMER
	   FROM %table:DA4% DA4 
	   JOIN %table:DTQ% DTQ 
	     ON DTQ_FILIAL = %xFilial:DTQ%
	     AND DTQ_DATGER BETWEEN %Exp:DTOS(mv_par02)% AND %Exp:DTOS(mv_par03)%
	     AND DTQ.%NotDel%
	   JOIN %table:DTX% DTX
	     ON DTX_FILIAL = %xFilial:DTX%
	     AND DTX_FILORI = DTQ_FILORI 
	     AND DTX_VIAGEM = DTQ_VIAGEM 
	     AND DTX.%NotDel%
	   JOIN %table:DUP% DUP 
	     ON DUP_FILIAL = %xFilial:DUP%
	     AND DUP_FILORI = %Exp:mv_par01%
	     AND DUP_CODMOT BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
	     AND DUP_FILORI = DTQ_FILORI
		  AND DUP_VIAGEM = DTQ_VIAGEM
	     AND DUP.%NotDel%
	   WHERE DA4_FILIAL = %xFilial:DA4%
		  AND DA4_COD = DUP_CODMOT	   	
	     AND DA4.%NotDel%
	GROUP BY DA4_FILIAL, DA4_COD, DA4_NOME, DA4_RG, DA4_CGC, DTX_FILDCA, DTX_FILMAN, DTX_MANIFE, DTX_SERMAN
	ORDER BY DA4_FILIAL, DA4_COD, DA4_NOME, DA4_RG, DA4_CGC, DTX_FILDCA, DTX_FILMAN, DTX_MANIFE, DTX_SERMAN
	EndSql
Else 
	BeginSql Alias cAliasQry
		SELECT DA4_FILIAL, DA4_COD, DA4_NOME, DA4_RG, DA4_CGC, DTX_FILDCA, DTX_FILMAN, DTX_MANIFE,MAX(DTX_VALMER) DTX_VALMER
	   FROM %table:DA4% DA4 
	   JOIN %table:DTQ% DTQ 
	     ON DTQ_FILIAL = %xFilial:DTQ%
	     AND DTQ_DATGER BETWEEN %Exp:DTOS(mv_par02)% AND %Exp:DTOS(mv_par03)%
	     AND DTQ.%NotDel%
	   JOIN %table:DTX% DTX
	     ON DTX_FILIAL = %xFilial:DTX%
	     AND DTX_FILORI = DTQ_FILORI 
	     AND DTX_VIAGEM = DTQ_VIAGEM 
	     AND DTX.%NotDel%
	   JOIN %table:DUP% DUP 
	     ON DUP_FILIAL = %xFilial:DUP%
	     AND DUP_FILORI = %Exp:mv_par01%
	     AND DUP_CODMOT BETWEEN %Exp:mv_par04% AND %Exp:mv_par05%
	     AND DUP_FILORI = DTQ_FILORI
		 AND DUP_VIAGEM = DTQ_VIAGEM
	     AND DA4_COD = DUP_CODMOT 
	     AND DUP.%NotDel%
	   WHERE DA4_FILIAL = %xFilial:DA4%
	     AND DA4.%NotDel%
	GROUP BY DA4_FILIAL, DA4_COD, DA4_NOME, DA4_RG, DA4_CGC, DTX_FILDCA, DTX_FILMAN, DTX_MANIFE
	ORDER BY DA4_FILIAL, DA4_COD, DA4_NOME, DA4_RG, DA4_CGC, DTX_FILDCA, DTX_FILMAN, DTX_MANIFE
	EndSql
EndIf

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oReport:Section(1):EndQuery(/*Array com os parametros do tipo Range*/)

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DA4->(LastRec()))

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( {|cParam| (cAliasQry)->DA4_COD == cParam  }, {|| (cAliasQry)->DA4_COD } )

DbSelectArea(cAliasQry)
While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
	oReport:Section(1):Init()
	oReport:Section(1):PrintLine()
	While !(cAliasQry)->(Eof())
		cCodMot := (cAliasQry)->DA4_COD
		oReport:Section(1):Section(1):Init()
		oReport:Section(1):Section(1):PrintLine()
		(cAliasQry)->(DbSkip())
		oReport:Section(1):Section(1):Cell("DA4_NOME"):Hide()
		oReport:Section(1):Section(1):Cell("DA4_RG"  ):Hide()
		oReport:Section(1):Section(1):Cell("DA4_CGC" ):Hide()
		While !(cAliasQry)->(Eof()) .And. (cAliasQry)->DA4_COD == cCodMot
			oReport:Section(1):Section(1):PrintLine()
			(cAliasQry)->(DbSkip())
		EndDo
		oReport:Section(1):Section(1):Cell("DA4_NOME"):Show()
		oReport:Section(1):Section(1):Cell("DA4_RG"  ):Show()
		oReport:Section(1):Section(1):Cell("DA4_CGC" ):Show()
		oReport:Section(1):Section(1):Finish()
	EndDo
	oReport:Section(1):Finish()
EndDo

Return