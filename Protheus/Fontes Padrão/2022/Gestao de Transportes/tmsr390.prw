#INCLUDE "TMSR390.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR390  � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Imprime a relacao das ocorrencias.                         ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR390()

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
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local aOrdem     := {}
Local cAliasQry  := GetNextAlias()

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
oReport:= TReport():New("TMSR390",STR0014,"TMR390", {|oReport| ReportPrint(oReport,cAliasQry)},STR0015) // "Ocorr�ncias" ### "Emite a rela��o das ocorr�ncias conforme os parametros informados"
oReport:SetTotalInLine(.F.)
oReport:SetLandscape(.T.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01	 // Ocorrencia De                                 �
//� mv_par02	 // Ocorrencia Ate                                �
//� mv_par03	 // Periodo De                                    �
//� mv_par04	 // Periodo Ate                                   �
//� mv_par05	 // Servico Transp. De                            �
//� mv_par06	 // Servico Transp. Ate                           �
//� mv_par07	 // Tipo Ocorrencia De                            �
//� mv_par08	 // Tipo Ocorrencia Ate                           �
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
Aadd( aOrdem, STR0016 ) // "Serv.Transp. + Cod. Ocorr�ncia"

oServ := TRSection():New(oReport,STR0017,{cAliasQry},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Serv.Transporte"
oServ:SetTotalInLine(.F.)
oServ:SetTotalText(STR0019) // "Sub-Total"
TRCell():New(oServ,"DT2_SERTMS","DT2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oServ,"DT2_DESSVT","DT2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| TMSValField(cAliasQry+'->DT2_SERTMS',.F.) }) // 'Descri��o'

oTipOco := TRSection():New(oServ,STR0021,{cAliasQry},/*Array com as Ordens do relat�rio*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Ocorr�ncia"
oTipOco:SetTotalInLine(.F.)
TRCell():New(oTipOco,"DT2_CODOCO","DT2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTipOco,"DT2_DESCRI","DT2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTipOco,"DT2_TIPOCO","DT2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oTipOco,"DT2_DTPOCO","DT2",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| TMSValField(cAliasQry+'->DT2_TIPOCO',.F.) })

oOcorr := TRSection():New(oTipOco,STR0022,{cAliasQry},/*Array com as Ordens do relat�rio*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Itens"
oOcorr:SetTotalInLine(.F.)
TRCell():New(oOcorr,"DUA_DATOCO"	,"DUA",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oOcorr,"DUA_HOROCO"	,"DUA",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oOcorr,"DUA_FILORI"	,"DUA",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oOcorr,"DUA_VIAGEM"	,"DUA",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oOcorr,"DUA_FILDOC"	,"DUA",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oOcorr,"DUA_DOC"   	,"DUA",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oOcorr,SerieNfID("DUA",3,"DUA_SERIE"),"DUA",SerieNfID("DUA",7,"DUA_SERIE"),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oOcorr,"DUA_QTDOCO"	,"DUA",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oOcorr,"DUA_PESOCO"	,"DUA",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oOcorr,"DUA_CODMOT"	,"DUA",STR0020   ,/*Picture*/,50         ,/*lPixel*/, {|| MSMM((cAliasQry)->DUA_CODMOT) } )

TRFunction():New(oOcorr:Cell("DUA_DATOCO"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oServ)
TRFunction():New(oOcorr:Cell("DUA_QTDOCO"),/*cId*/,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oServ)
TRFunction():New(oOcorr:Cell("DUA_PESOCO"),/*cId*/,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oServ)

TRFunction():New(oOcorr:Cell("DUA_DATOCO"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oTipOco)
TRFunction():New(oOcorr:Cell("DUA_QTDOCO"),/*cId*/,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oTipOco)
TRFunction():New(oOcorr:Cell("DUA_PESOCO"),/*cId*/,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/,oTipOco)

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR170                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry)
Local cFecth := ""
Local cGrupo := ""

If SerieNfId("DUA",3,"DUA_SERIE")=="DUA_SDOC"
	cFetch := "%DUA_SDOC,%"
	cGrupo := "%,DUA_SDOC%"
Else
	cFetch := "%%"
	cGrupo := "%%"
EndIf


//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT
			DT2_CODOCO, DUA_DATOCO, DUA_HOROCO, DUA_FILDOC, DUA_DOC, DT2_SERTMS, 
			DUA_SERIE , DUA_FILORI, DUA_VIAGEM, DUA_QTDOCO, DUA_PESOCO, DT2_DESCRI,DUA_FILIAL,
			DT2_TIPOCO,
			%Exp:cFetch% 
			MAX(DT6_QTDVOL) DT6_QTDVOL, MAX(DT6_PESO) DT6_PESO, MAX(DUA_CODMOT) DUA_CODMOT
		FROM %table:DT2% DT2
		JOIN %table:DUA% DUA
			ON DUA_FILIAL = %xFilial:DUA%
			AND DUA_CODOCO = DT2_CODOCO
			AND DUA_SERTMS = DT2_SERTMS
			AND DUA.%NotDel%
		JOIN %table:DT6% DT6
			ON  DT6_FILIAL = %xFilial:DT6%
			AND DT6_FILDOC = DUA_FILDOC
			AND DT6_DOC    = DUA_DOC
			AND DT6_SERIE  = DUA_SERIE
			AND DT6.%NotDel%
		WHERE DT2_FILIAL = %xFilial:DT2%
			AND DT2_CODOCO BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
			AND DT2_SERTMS BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
			AND DT2_TIPOCO BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%
			AND DUA_DATOCO BETWEEN %Exp:DTOS(mv_par03)% AND %Exp:DTOS(mv_par04)%
			AND DUA_FILORI BETWEEN %Exp:mv_par09% AND %Exp:mv_par11%
			AND DUA_VIAGEM BETWEEN %Exp:mv_par10% AND %Exp:mv_par12%
			AND DT2.%NotDel%
	GROUP BY DUA_FILIAL, DT2_SERTMS, DT2_CODOCO, DUA_DATOCO, DUA_HOROCO, DUA_FILORI, DUA_VIAGEM, DUA_FILDOC, DUA_DOC, DUA_SERIE, DUA_QTDOCO, DUA_PESOCO, DT2_DESCRI, DT2_TIPOCO%Exp:cGrupo% 
	ORDER BY DUA_FILIAL, DT2_SERTMS, DT2_CODOCO, DUA_DATOCO, DUA_HOROCO, DUA_FILORI, DUA_VIAGEM, DUA_FILDOC, DUA_DOC, DUA_SERIE
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

oReport:Section(1):Section(1):SetParentRecno()
oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->DT2_SERTMS == cParam },{ || (cAliasQry)->DT2_SERTMS })

oReport:Section(1):Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->DT2_SERTMS+(cAliasQry)->DT2_CODOCO == cParam },{ || (cAliasQry)->DT2_SERTMS+(cAliasQry)->DT2_CODOCO })
oReport:Section(1):Print()

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DUA->(LastRec()))

Return