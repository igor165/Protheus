#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSR300.CH"


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR300  � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Analise de Carregamento                                    ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR300()

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
Local oViagem
Local oVeiculo
Local aOrdem     := {}
Local cAliasQry  := GetNextAlias()
Local cAliasQry2 := GetNextAlias()
Local cAliasQry3 := GetNextAlias()
Local lDTX_SERMAN := DTX->(FieldPos("DTX_SERMAN")) > 0
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
oReport:= TReport():New("TMSR300",STR0023,"TMR300", {|oReport| ReportPrint(oReport,cAliasQry,cAliasQry2,cAliasQry3)},STR0024) // "Relatorio de Analise de Carregamento" ### "Este programa ira emitir o relatorio de analise de carregamento de acordo com os parametros escolhidos pelo usuario"
oReport:SetLandscape()
oReport:SetTotalInLine(.F.)
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
Aadd( aOrdem, STR0025 ) // "Fil. Viagem + Viagem"

oFilOri:= TRSection():New(oReport,STR0049,{"DTQ"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Filial"
oFilOri:SetTotalInLine(.F.)
oFilOri:SetPageBreak()
TRCell():New(oFilOri,"DTQ_FILORI","DTQ",/*cTitle*/ ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oFilOri,"DES.FILIAL",""   ,STR0028    ,""        ,15         ,          , {|| Posicione("SM0",1,cEmpAnt+(cAliasQry)->DTQ_FILORI,"M0_FILIAL") }) // "Descri��o"

oViagem:= TRSection():New(oFilOri,STR0026,{"DTQ"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Viagem"
oViagem:SetTotalInLine(.F.)
TRCell():New(oViagem,"DTQ_VIAGEM","DTQ",/*cTitle*/ ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oVeiculo:= TRSection():New(oViagem,STR0027,{"DTQ","DTR","DA3"},/*Array com as Ordens do relat�rio*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Ve�culos"
oVeiculo:SetTotalInLine(.F.)
TRCell():New(oVeiculo,"DTR_CODVEI",""   ,STR0029,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry2)->CODVEI   })
TRCell():New(oVeiculo,"DA3_FROVEI","DA3",STR0030,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry2)->FROVEI   })
TRCell():New(oVeiculo,"DA3_PLACA" ,""   ,STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry2)->PLACAVEI })
TRCell():New(oVeiculo,"DTR_CODRB1",""   ,STR0032,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry2)->CODRB1   })
TRCell():New(oVeiculo,"DA3_PLACA" ,""   ,STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry2)->PLACARB1 })
TRCell():New(oVeiculo,"DTR_CODRB2",""   ,STR0033,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry2)->CODRB2   })
TRCell():New(oVeiculo,"DA3_PLACA" ,""   ,STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry2)->PLACARB2 })
TRCell():New(oVeiculo,"DTR_CODRB3",""   ,STR0050,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry2)->DTR_CODRB3 })
TRCell():New(oVeiculo,"DA3_PLACA" ,""   ,STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry2)->PLACARB3 })

oDocumento:= TRSection():New(oViagem,STR0026,{"DUD","DT6"},/*Array com as Ordens do relat�rio*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Ve�culos"
oDocumento:SetTotalInLine(.F.)
TRCell():New(oDocumento,"DUD_FILMAN","DUD",STR0034,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry3)->DUD_FILMAN })
TRCell():New(oDocumento,"TIPO"      ,""   ,STR0035,/*Picture*/,1          ,/*lPixel*/, {|| (cAliasQry3)->TIPO } )
TRCell():New(oDocumento,"DT6_FILDES","DT6",STR0036,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry3)->DT6_FILDES })
TRCell():New(oDocumento,"DUD_FILDCA","DUD",STR0037,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry3)->DUD_FILDCA })
TRCell():New(oDocumento,"DUD_MANIFE","DUD",STR0038,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry3)->DUD_MANIFE })
If lDTX_SERMAN
	TRCell():New(oDocumento,"DUD_SERMAN","DUD",/*cTitle*/ ,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry3)->DUD_SERMAN })
EndIf
TRCell():New(oDocumento,"QTDCTR"    ,""   ,STR0039,/*Picture*/,4          ,/*lPixel*/, {|| (cAliasQry3)->QTDCTR     })
TRCell():New(oDocumento,"DT6_PESO"  ,"DT6",STR0040,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry3)->DT6_PESO   })
TRCell():New(oDocumento,"PESDIR"    ,""   ,STR0041,PesqPict("DT6","DT6_PESO"),TamSx3("DT6_PESO")[1]+TamSx3("DT6_PESO")[2],/*lPixel*/, {|| (cAliasQry3)->PESDIR     })
TRCell():New(oDocumento,"PESFRAC"   ,""   ,STR0042,PesqPict("DT6","DT6_PESO"),TamSx3("DT6_PESO")[1]+TamSx3("DT6_PESO")[2],/*lPixel*/, {|| (cAliasQry3)->PESFRAC    })
TRCell():New(oDocumento,"DT6_PESCOB","DT6",STR0043,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAliasQry3)->DT6_PESCOB })
TRCell():New(oDocumento,"PESPAG"    ,""   ,STR0044,PesqPict("DT6","DT6_PESO"  ),TamSx3("DT6_PESO"  )[1]+TamSx3("DT6_PESO"  )[2],/*lPixel*/, {|| ((cAliasQry3)->DT6_PESO / TmsTotVge((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM)[1] ) * TmsTotVge((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM,,.T.)[11] })
TRCell():New(oDocumento,"FREDIR"    ,""   ,STR0045,PesqPict("DT6","DT6_VALTOT"),TamSx3("DT6_VALTOT")[1]+TamSx3("DT6_VALTOT")[2],/*lPixel*/, {|| (cAliasQry3)->FREDIR     })
TRCell():New(oDocumento,"FREFRAC"   ,""   ,STR0046,PesqPict("DT6","DT6_VALTOT"),TamSx3("DT6_VALTOT")[1]+TamSx3("DT6_VALTOT")[2],/*lPixel*/, {|| (cAliasQry3)->FREFRAC    })
TRCell():New(oDocumento,"CARDIR"    ,""   ,STR0047,PesqPict("DT6","DT6_VALTOT"),TamSx3("DT6_VALTOT")[1]+TamSx3("DT6_VALTOT")[2],/*lPixel*/, {|| ((cAliasQry3)->PESDIR  / TmsTotVge((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM)[1] ) * TmsTotVge((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM,.T.,)[10] })
TRCell():New(oDocumento,"CARFRAC"   ,""   ,STR0048,PesqPict("DT6","DT6_VALTOT"),TamSx3("DT6_VALTOT")[1]+TamSx3("DT6_VALTOT")[2],/*lPixel*/, {|| ((cAliasQry3)->PESFRAC / TmsTotVge((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM)[1] ) * TmsTotVge((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM,.T.,)[10] })

TRFunction():New(oDocumento:Cell("QTDCTR"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocumento:Cell("DT6_PESO"  ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocumento:Cell("PESDIR"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocumento:Cell("PESFRAC"   ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocumento:Cell("DT6_PESCOB"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocumento:Cell("PESPAG"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocumento:Cell("FREDIR"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocumento:Cell("FREFRAC"   ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocumento:Cell("CARDIR"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oDocumento:Cell("CARFRAC"   ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

TRFunction():New(oDocumento:Cell("QTDCTR"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,oFilOri)
TRFunction():New(oDocumento:Cell("DT6_PESO"  ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,oFilOri)
TRFunction():New(oDocumento:Cell("PESDIR"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,oFilOri)
TRFunction():New(oDocumento:Cell("PESFRAC"   ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,oFilOri)
TRFunction():New(oDocumento:Cell("DT6_PESCOB"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,oFilOri)
TRFunction():New(oDocumento:Cell("PESPAG"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,oFilOri)
TRFunction():New(oDocumento:Cell("FREDIR"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,oFilOri)
TRFunction():New(oDocumento:Cell("FREFRAC"   ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,oFilOri)
TRFunction():New(oDocumento:Cell("CARDIR"    ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,oFilOri)
TRFunction():New(oDocumento:Cell("CARFRAC"   ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.T./*lEndSection*/,.T./*lEndReport*/,.F./*lEndPage*/,oFilOri)

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
Static Function ReportPrint(oReport,cAliasQry,cAliasQry2,cAliasQry3)
Local lDTX_SERMAN := DTX->(FieldPos("DTX_SERMAN")) > 0
Local cCodRb3 := ''
Local cPlacaRb3 := ''

cCodRb3   := "%DTR_CODRB3%"
cPlacaRb3 := "%DA3D.DA3_PLACA PLACARB3%"

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT DTQ_FILIAL, DTQ_FILORI, DTQ_VIAGEM
		FROM %table:DTQ%
		WHERE DTQ_FILIAL = %xFilial:DTQ%
		  AND DTQ_FILORI >= %Exp:mv_par01%
	     AND DTQ_FILORI <= %Exp:mv_par02%
	     AND DTQ_TIPTRA BETWEEN %Exp:mv_par03% AND %Exp:mv_par04%
	     AND DTQ_DATFEC = %Exp:Dtos(mv_par05)%
	     AND DTQ_SERTMS BETWEEN %Exp:mv_par06% AND %Exp:mv_par07%
	     AND %NotDel%
	   ORDER BY DTQ_FILIAL,DTQ_FILORI,DTQ_VIAGEM
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

//-- Query do relat�rio da secao 2
Begin Report Query oReport:Section(1):Section(1):Section(1)

BeginSql Alias cAliasQry2
	SELECT DTR_CODVEI CODVEI, DA3A.DA3_FROVEI FROVEI , DA3A.DA3_PLACA PLACAVEI,
	       DTR_CODRB1 CODRB1, DA3B.DA3_PLACA PLACARB1, DTR_FILIAL, 
	       DTR_CODRB2 CODRB2, DA3C.DA3_PLACA PLACARB2, %Exp:cCodRb3%, %Exp:cPlacaRb3%
		FROM %table:DTR% DTR
		JOIN %table:DA3% DA3A
			ON DA3A.DA3_FILIAL = %xFilial:DA3%
			AND DA3A.DA3_COD    = DTR_CODVEI
			AND DA3A.%NotDel%
		LEFT JOIN %table:DA3% DA3B
			ON DA3B.DA3_FILIAL = %xFilial:DA3%
			AND DA3B.DA3_COD    = DTR_CODRB1
			AND DA3B.%NotDel%
		LEFT JOIN %table:DA3% DA3C
			ON DA3C.DA3_FILIAL = %xFilial:DA3%
			AND DA3C.DA3_COD    = DTR_CODRB2
			AND DA3C.%NotDel%
		LEFT JOIN %table:DA3% DA3D
			ON DA3D.DA3_FILIAL = %xFilial:DA3%
			AND DA3D.DA3_COD   = %Exp:cCodRb3%
			AND DA3D.%NotDel%
		WHERE DTR_FILIAL =  %xFilial:DTR%
			AND DTR_FILORI = %report_param:(cAliasQry)->DTQ_FILORI%
			AND DTR_VIAGEM = %report_param:(cAliasQry)->DTQ_VIAGEM%
			AND DTR.%NotDel%
	   ORDER BY DTR_FILIAL, DTR_FILORI,DTR_VIAGEM, DTR_CODVEI
EndSql 

End Report Query oReport:Section(1):Section(1):Section(1)

//-- Query do relat�rio da secao 3
Begin Report Query oReport:Section(1):Section(1):Section(2)

If lDTX_SERMAN
	BeginSql Alias cAliasQry3
	SELECT (CASE WHEN DUD_FILORI = DUD_FILMAN THEN 'P' ELSE 'R' END) TIPO,
	        DT6_FILDES, DUD_FILDCA, DUD_MANIFE,DUD_SERMAN, COUNT(DUD_FILDCA) QTDCTR, SUM(DT6_PESO) DT6_PESO, 
	        (CASE WHEN MIN(DT6_PESO) >= 100 THEN SUM(DT6_PESO) ELSE 0 END) PESDIR ,
	        (CASE WHEN MIN(DT6_PESO) < 100  THEN SUM(DT6_PESO) ELSE 0 END) PESFRAC,
	        SUM(DT6_PESCOB) DT6_PESCOB, DUD_FILMAN, 
	        (CASE WHEN MIN(DT6_PESO) >= 100 THEN SUM(DT6_VALTOT) ELSE 0 END) FREDIR ,
	        (CASE WHEN MIN(DT6_PESO) < 100  THEN SUM(DT6_VALTOT) ELSE 0 END) FREFRAC
	    FROM (
 	SELECT DUD_FILDCA, DUD_FILORI,DUD_FILMAN, DUD_MANIFE, DUD_SERMAN, DT6_FILDES, DT6_PESO, DT6_PESCOB, DT6_VALTOT
			FROM %table:DUD% DUD
			JOIN %table:DT6% DT6
	        ON DT6_FILIAL = %xFilial:DT6%
	        AND DT6_FILDOC = DUD_FILDOC
	        AND DT6_DOC    = DUD_DOC
	        AND DT6_SERIE  = DUD_SERIE
			  AND DT6.%NotDel%
	      WHERE DUD_FILIAL = %xFilial:DUD%
	        AND DUD_FILORI = %report_param:(cAliasQry)->DTQ_FILORI%
	        AND DUD_VIAGEM = %report_param:(cAliasQry)->DTQ_VIAGEM%
	        AND DUD.%NotDel% ) QUERY
	     GROUP BY DUD_FILDCA, DUD_FILORI, DUD_FILMAN, DUD_MANIFE, DUD_SERMAN, DT6_FILDES
	     EndSql
Else
	BeginSql Alias cAliasQry3
	SELECT (CASE WHEN DUD_FILORI = DUD_FILMAN THEN 'P' ELSE 'R' END) TIPO,
	        DT6_FILDES, DUD_FILDCA, DUD_MANIFE, COUNT(DUD_FILDCA) QTDCTR, SUM(DT6_PESO) DT6_PESO, 
	        (CASE WHEN MIN(DT6_PESO) >= 100 THEN SUM(DT6_PESO) ELSE 0 END) PESDIR ,
	        (CASE WHEN MIN(DT6_PESO) < 100  THEN SUM(DT6_PESO) ELSE 0 END) PESFRAC,
	        SUM(DT6_PESCOB) DT6_PESCOB, DUD_FILMAN, 
	        (CASE WHEN MIN(DT6_PESO) >= 100 THEN SUM(DT6_VALTOT) ELSE 0 END) FREDIR ,
	        (CASE WHEN MIN(DT6_PESO) < 100  THEN SUM(DT6_VALTOT) ELSE 0 END) FREFRAC
	    FROM (
 	SELECT DUD_FILDCA, DUD_FILORI,DUD_FILMAN, DUD_MANIFE, DT6_FILDES, DT6_PESO, DT6_PESCOB, DT6_VALTOT
			FROM %table:DUD% DUD
			JOIN %table:DT6% DT6
	        ON DT6_FILIAL = %xFilial:DT6%
	        AND DT6_FILDOC = DUD_FILDOC
	        AND DT6_DOC    = DUD_DOC
	        AND DT6_SERIE  = DUD_SERIE
			  AND DT6.%NotDel%
	      WHERE DUD_FILIAL = %xFilial:DUD%
	        AND DUD_FILORI = %report_param:(cAliasQry)->DTQ_FILORI%
	        AND DUD_VIAGEM = %report_param:(cAliasQry)->DTQ_VIAGEM%
	        AND DUD.%NotDel% ) QUERY
	     GROUP BY DUD_FILDCA, DUD_FILORI, DUD_FILMAN, DUD_MANIFE, DT6_FILDES
	     EndSql
EndIf

End Report Query oReport:Section(1):Section(1):Section(2)

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DTQ->(LastRec()))

//-- Utiliza a query do Pai
oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->DTQ_FILORI  == cParam },{ || (cAliasQry)->DTQ_FILORI })

oReport:Section(1):Print()

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TmsTotVge � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Totais da Viagem                                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TmsTotVge(ExpC1,ExpC2,ExpL1)                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1 - Filial Viagem                                      ���
���          � ExpC2 - Viagem                                             ���
���          � ExpL1 - Capacidade dos veiculos                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TmsTotVge(cFilOri,cViagem,lContrato,lCapac)

Local aTotViag    := {}
Local cAliasQry   := GetNextAlias()
Local cCodRb3     := ''

Default lContrato := .F.
Default lCapac    := .F.

cCodRb3   := "%DTR_CODRB3%"

Aadd( aTotViag, 0 ) //-- 1 Peso Real
Aadd( aTotViag, 0 ) //-- 2 Peso Cubado
Aadd( aTotViag, 0 ) //-- 3 Metro Cubico
Aadd( aTotViag, 0 ) //-- 4 Peso Cobrado
Aadd( aTotViag, 0 ) //-- 5 Volumes
Aadd( aTotViag, 0 ) //-- 6 Valor Mercadoria
Aadd( aTotViag, 0 ) //-- 7 Frete
Aadd( aTotViag, 0 ) //-- 8 Imposto
Aadd( aTotViag, 0 ) //-- 9 Frete Total
Aadd( aTotViag, 0 ) //-- 10 Valor Contrato
Aadd( aTotViag, 0 ) //-- 11 Capacidade Total

If !lContrato .And. !lCapac
	BeginSql Alias cAliasQry
		SELECT SUM(DT6_PESO) PESO    , SUM(DT6_PESOM3) PESOM3, SUM(DT6_METRO3) METRO3,
		       SUM(DT6_PESCOB) PESCOB, SUM(DT6_QTDVOL) QTDVOL, SUM(DT6_VALMER) VALMER,
		       SUM(DT6_VALFRE) VALFRE, SUM(DT6_VALFRE) VALIMP, SUM(DT6_VALTOT) VALTOT
			FROM %table:DUD% DUD
			JOIN %table:DT6% DT6
				ON DT6_FILIAL = %xFilial:DT6%
				AND DT6_FILDOC = DUD_FILDOC
				AND DT6_DOC    = DUD_DOC
				AND DT6_SERIE  = DUD_SERIE
				AND DT6.%NotDel%
			WHERE DUD_FILIAL   = %xFilial:DUD%
				AND DUD_FILORI  = %Exp:cFilOri%
				AND DUD_VIAGEM  = %Exp:cViagem%
				AND DUD.%NotDel%
			GROUP BY DUD_FILORI, DUD_VIAGEM
	EndSql
	aTotViag[1] := (cAliasQry)->PESO
	aTotViag[2] := (cAliasQry)->PESOM3
	aTotViag[3] := (cAliasQry)->METRO3
	aTotViag[4] := (cAliasQry)->PESCOB
	aTotViag[5] := (cAliasQry)->QTDVOL
	aTotViag[6] := (cAliasQry)->VALMER
	aTotViag[7] := (cAliasQry)->VALFRE
	aTotViag[8] := (cAliasQry)->VALIMP
	aTotViag[9] := (cAliasQry)->VALTOT
	(cAliasQry)->(DbCloseArea())
EndIf

If lContrato
	BeginSql Alias cAliasQry
		SELECT SUM(DTY_VALFRE) VALFRE
		   FROM %table:DTY%
		   WHERE DTY_FILIAL = %xFilial:DTY%
		     AND DTY_FILORI = %Exp:cFilOri%
		     AND DTY_VIAGEM = %Exp:cViagem%
		     AND %NotDel%
	EndSql
	aTotViag[10] := (cAliasQry)->VALFRE
	(cAliasQry)->(DbCloseArea())
EndIf

If lCapac
	BeginSql Alias cAliasQry
		SELECT SUM(DA3_CAPACM) CAPACM
			FROM (
				SELECT SUM(DA3_CAPACM) DA3_CAPACM
					FROM %table:DTR% DTR
					JOIN %table:DA3% DA3
						ON DA3_FILIAL = %xFilial:DA3%
						AND DA3_COD   = DTR_CODVEI
						AND DA3.%NotDel%
					WHERE DTR_FILIAL  = %xFilial:DTR%
						AND DTR_FILORI = %Exp:cFilOri%
						AND DTR_VIAGEM = %Exp:cViagem%
						AND DTR.%NotDel%
					GROUP BY DTR_FILORI, DTR_VIAGEM
				UNION ALL
				SELECT SUM(DA3_CAPACM) DA3_CAPACM
					FROM %table:DTR% DTR
					JOIN %table:DA3% DA3
						ON DA3_FILIAL = %xFilial:DA3%
						AND DA3_COD   = DTR_CODRB1
						AND DA3.%NotDel%
					WHERE DTR_FILIAL  = %xFilial:DTR%
						AND DTR_FILORI = %Exp:cFilOri%
						AND DTR_VIAGEM = %Exp:cViagem%
						AND DTR.%NotDel%
					GROUP BY DTR_FILORI, DTR_VIAGEM
				UNION ALL
				SELECT SUM(DA3_CAPACM) DA3_CAPACM
					FROM %table:DTR% DTR
					JOIN %table:DA3% DA3
						ON DA3_FILIAL = %xFilial:DA3%
						AND DA3_COD   = DTR_CODRB2
						AND DA3.%NotDel%
					WHERE DTR_FILIAL  = %xFilial:DTR%
						AND DTR_FILORI = %Exp:cFilOri%
						AND DTR_VIAGEM = %Exp:cViagem%
						AND DTR.%NotDel%
					GROUP BY DTR_FILORI, DTR_VIAGEM
				UNION ALL
				SELECT SUM(DA3_CAPACM) DA3_CAPACM
					FROM %table:DTR% DTR
					JOIN %table:DA3% DA3
						ON DA3_FILIAL = %xFilial:DA3%
						AND DA3_COD   = %Exp:cCodRb3%
						AND DA3.%NotDel%
					WHERE DTR_FILIAL  = %xFilial:DTR%
						AND DTR_FILORI = %Exp:cFilOri%
						AND DTR_VIAGEM = %Exp:cViagem%
						AND DTR.%NotDel%
					GROUP BY DTR_FILORI, DTR_VIAGEM ) QUERY
	EndSql
	aTotViag[11] := (cAliasQry)->CAPACM
	(cAliasQry)->(DbCloseArea())
EndIf

Return aTotViag
