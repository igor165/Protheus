#INCLUDE "TMSR530.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR530  � Autor � Eduardo de Souza      � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Movimento de Custo de Transporte                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR530()

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
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR530                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local cAliasQry := GetNextAlias()
Local aOrdem    := {}
Local oCusto
Local oTotal1
Local oTotal2

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
oReport:= TReport():New("TMSR530",STR0014,"TMR530", {|oReport| ReportPrint(oReport,cAliasQry,oCusto,oTotal1,oTotal2)},STR0015) // "Movimento de Custo de Transporte" ### "Emite Relacao de Movimento de Custo de Transporte conforme os parametros informados."
oReport:SetTotalInLine(.F.)
oReport:SetLandscape()

//��������������������������������������������������������������Ŀ
//� Carrega as perguntas selecionadas                            �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01 - Emissao de         ? 									  �
//� mv_par02 - Emissao Ate        ? 									  �
//� mv_par03 - Cod. Despesa De    ?                              �
//� mv_par04 - Cod. Despesa Ate   ?                              �
//� mv_par05 - Veiculo de         ?                              �
//� mv_par06 - Veiculo Ate        ?                              �
//� mv_par07 - Filial Origem De   ?                              �
//� mv_par08 - Viagem De          ?                              �
//� mv_par09 - Filial Origem At   ?                              �
//� mv_par10 - Viagem Ate         ?                              �
//� mv_par11 - Conta Contabil De  ?                              �
//� mv_par12 - Conta Contabil Ate ?                              �
//� mv_par13 - Centro de Custo De ?                              �
//� mv_par14 - Centro de Custo Ate?                              �
//� mv_par15 - Proprietario De    ?                              �
//� mv_par16 - Loja De            ?                              �
//� mv_par17 - Proprietario Ate   ?                              �
//� mv_par18 - Loja Ate           ?                              �
//� mv_par19 - Total por          ?  1=Despesa - 2=Veiculo       �
//� 											 3=Viagem  - 4=Conta Contabil�
//� 											 5=Proprietario              �
//� mv_par20 - Data Baixa de      ? 									  �
//� mv_par21 - Data Baixa Ate     ? 									  �
//� mv_par22 - Status Movto.      ?  1=Em aberto                 �
//� 											 2=Baixado                   �
//� 											 3=Ambos                     �
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
Aadd( aOrdem, STR0016 ) // "Fil.Origem + Despesa + Emiss�o + Documento
Aadd( aOrdem, STR0017 ) // "Fil.Origem + Ve�culo + Emiss�o + Documento
Aadd( aOrdem, STR0018 ) // "Fil.Origem + Viagem + Emiss�o + Documento
Aadd( aOrdem, STR0019 ) // "Fil.Origem + Conta Cont�bil + Emiss�o + Documento
Aadd( aOrdem, STR0020 ) // "Fil.Origem + Propriet�rio + Emiss�o + Documento

oCusto:= TRSection():New(oReport,STR0021,{"SDG","DT7","DA3","SA2"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oCusto:SetTotalInLine(.F.)
TRCell():New(oCusto,"DG_DOC"    ,"SDG",,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"DG_EMISSAO","SDG",,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"DG_CODDES" ,"SDG",STR0029   ,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"DT7_DESCRI","DT7",,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"DG_CODVEI" ,"SDG",,/*Picture*/, /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"DA3_DESC"  ,"DA3",/*cTitle*/,/*Picture*/,20/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.)
TRCell():New(oCusto,"DG_FILORI" ,"SDG",,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"DG_VIAGEM" ,"SDG",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"DG_CONTA"  ,"SDG",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"DG_ITEMCTA","SDG",STR0032   ,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"DG_CC"     ,"SDG",STR0033   ,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"DG_STATUS" ,"SDG",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"DG_VALCOB" ,"SDG",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"DG_SALDO"  ,"SDG",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.F.)
TRCell():New(oCusto,"A2_NOME"   ,"SA2",/*cTitle*/,/*Picture*/,  /*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/,,,,,,.T.)

oTotal1:= TRFunction():New(oCusto:Cell("DG_VALCOB"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/)
oTotal2:= TRFunction():New(oCusto:Cell("DG_SALDO"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,.F./*lEndPage*/)

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR520                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry,oCusto,oTotal1,oTotal2)

Local cWhere  := ""
Local cOrder  := ""
Local cSelect := ""
Local cJoin   := ""
Local lIdent  := SDG->(FieldPos("DG_IDENT")) > 0 .And. nModulo<>43

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

cOrder := "%"
If oReport:Section(1):GetOrder() == 1
	oBreak := TRBreak():New(oCusto,oCusto:Cell("DG_CODDES" ),STR0022,.F.) // "Total da Despesa"
	oTotal1:SetBreak(oBreak)
	oTotal2:SetBreak(oBreak)
	If lIdent
		cOrder += "DTQ_FILORI, DG_CODDES,  DG_EMISSAO, DG_DOC "
	Else
		cOrder += "DG_FILORI, DG_CODDES,  DG_EMISSAO, DG_DOC "
	EndIf
ElseIf oReport:Section(1):GetOrder() == 2
	oBreak := TRBreak():New(oCusto,oCusto:Cell("DG_CODVEI" ),STR0023,.F.) // "Total do Ve�culo"
	oTotal1:SetBreak(oBreak)
	oTotal2:SetBreak(oBreak)
	If lIdent
		cOrder += "DTQ_FILORI, DG_CODVEI,  DG_EMISSAO, DG_DOC "	
	Else
		cOrder += "DG_FILORI, DG_CODVEI,  DG_EMISSAO, DG_DOC "	
	EndIf
ElseIf oReport:Section(1):GetOrder() == 3
	oBreak := TRBreak():New(oCusto,oCusto:Cell("DG_VIAGEM" ),STR0024,.F.) // "Total da Viagem"
	oTotal1:SetBreak(oBreak)
	oTotal2:SetBreak(oBreak)
	If lIdent
		cOrder += "DTQ_FILORI, DTQ_VIAGEM,  DG_EMISSAO, DG_DOC "	
	Else
		cOrder += "DG_FILORI, DG_VIAGEM,  DG_EMISSAO, DG_DOC "	
	EndIf
ElseIf oReport:Section(1):GetOrder() == 4
	oBreak:= TRBreak():New(oCusto,oCusto:Cell("DG_CONTA"  ),STR0025,.F.) // "Total da Conta Cont�bil"
	oTotal1:SetBreak(oBreak)
	oTotal2:SetBreak(oBreak)
	If lIdent
		cOrder += "DTQ_FILORI, DG_CONTA, DG_EMISSAO, DG_DOC "	
	Else
		cOrder += "DG_FILORI, DG_CONTA, DG_EMISSAO, DG_DOC "	
	EndIf
ElseIf oReport:Section(1):GetOrder() == 5
	oBreak := TRBreak():New(oCusto,oCusto:Cell("DA3_CODFOR"),STR0026,.F.) // "Total do Propriet�rio"
	oTotal1:SetBreak(oBreak)
	oTotal2:SetBreak(oBreak)
	If lIdent
		cOrder += "DTQ_FILORI, DA3_CODFOR, DG_EMISSAO, DG_DOC "	
	Else
		cOrder += "DG_FILORI, DA3_CODFOR, DG_EMISSAO, DG_DOC "
	EndIf
EndIf	
cOrder += "%"

cWhere := "%"
If mv_par22 == 1    
	cWhere += "  AND DG_STATUS =  '1' "
ElseIf mv_par22 == 2
	cWhere += "  AND DG_STATUS <> '1' "
	cWhere += "  AND DG_DATBAI BETWEEN  '" + Dtos(mv_par20) + "  'AND'" + Dtos(mv_par21) + "'"  
ElseIf MV_PAR22 == 4
	cWhere += "  AND DG_STATUS =  '2' "
EndIf	 

cSelect := "%"
cJoin   := "%"
If lIdent
	cSelect	+= " DG_DOC,DG_EMISSAO,DG_CODDES,DT7_DESCRI,DG_CODVEI,DA3_DESC,DTQ_FILORI,DTQ_VIAGEM,DG_CONTA,"
	cSelect	+= " DG_ITEMCTA,DG_CC,DG_STATUS,DG_TOTAL,DG_SALDO,A2_NOME, DG_VALCOB "
	
	cJoin	+= "JOIN " + RetSqlName("DTQ")  + "  " + "DTQ"
	cJoin 	+= " ON  DTQ_FILIAL = '"  + xFilial('DTQ') + "'"
	cJoin 	+= " AND DTQ_FILORI >= '" + mv_par07 + "'"
	cJoin 	+= " AND DTQ_VIAGEM >= '" + mv_par08 + "'"
	cJoin 	+= " AND DTQ_FILORI <= '" + mv_par09 + "'"
	cJoin 	+= " AND DTQ_VIAGEM <= '" + mv_par10 + "'"
	cJoin    += " AND DTQ_IDENT  = DG_IDENT"
	cJoin    += " AND DG_TIPUSO  = '1'"
	
	cWhere	+= " "                 
	
Else
	cSelect	+= " DG_DOC,DG_EMISSAO,DG_CODDES,DT7_DESCRI,DG_CODVEI,DA3_DESC,DG_FILORI,DG_VIAGEM,DG_CONTA,
	cSelect	+= " DG_ITEMCTA,DG_CC,DG_STATUS,DG_TOTAL,DG_SALDO,A2_NOME, DG_VALCOB "

	cJoin   += " "
	
	cWhere	+= " AND DG_FILORI >= '" + mv_par07 + "'"
	cWhere	+= " AND DG_VIAGEM >= '" + mv_par08 + "'"
	cWhere	+= " AND DG_FILORI <= '" + mv_par09 + "'" 
	cWhere	+= " AND DG_VIAGEM <= '" + mv_par10 + "'"
EndIf

cSelect += "%"
cJoin   += "%"
cWhere  += "%"

BeginSql Alias cAliasQry
	SELECT %Exp:cSelect%
	   FROM %table:SDG% SDG
	   JOIN %table:DA3% DA3
	      ON DA3_FILIAL = %xFilial:DA3%
	      AND DA3_COD   = DG_CODVEI
	      AND DA3_CODFOR BETWEEN %Exp:mv_par15% AND %Exp:mv_par17%
	      AND DA3_LOJFOR BETWEEN %Exp:mv_par16% AND %Exp:mv_par18%
	      AND DA3.%NotDel%
	   JOIN %table:SA2% SA2
	      ON A2_FILIAL  = %xFilial:SA2%
	      AND A2_COD    = DA3_CODFOR
	      AND A2_LOJA   = DA3_LOJFOR
	      AND SA2.%NotDel%
	   JOIN %table:DT7% DT7
	      ON DT7_FILIAL = %xFilial:DT7%
	      AND DT7_CODDES = DG_CODDES
	      AND DT7.%NotDel%
	   %Exp:cJoin%
	   WHERE DG_FILIAL  = %xFilial:SDG%
	      AND DG_EMISSAO BETWEEN %Exp:Dtos(mv_par01)% AND %Exp:Dtos(mv_par02)%
	      AND DG_CODDES  BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
	      AND DG_CODVEI  BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
	      AND DG_CONTA  BETWEEN  %Exp:mv_par11% AND %Exp:mv_par12%
	      AND DG_CC     BETWEEN  %Exp:mv_par13% AND %Exp:mv_par14%
	      AND SDG.%NotDel%
	      %Exp:cWhere%
			ORDER BY %Exp:cOrder%
EndSql 

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
oReport:SetMeter(SDG->(LastRec()))

oReport:Section(1):Print()

Return