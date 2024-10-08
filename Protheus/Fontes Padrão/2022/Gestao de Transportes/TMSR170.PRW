#INCLUDE "TMSR170.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR170  � Autor � Eduardo de Souza      � Data � 08/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao dos documentos emitidos                            ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR170()

Local oReport

//-- Interface de impressao
oReport := ReportDef()
oReport:PrintDialog()

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
Local oFilOri
Local oTotal
Local oTotaliz
Local cAliasQry := GetNextAlias()
Local aOrdem    := {}
Local aAreaSM0  := SM0->(GetArea())

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
oReport:= TReport():New("TMSR170",STR0051,"TMR170", {|oReport| ReportPrint(oReport,cAliasQry)},STR0052) // "Documentos emitidos" ### "Este relat�rio ir� imprimir a rela��o dos documentos emitidos."
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
Aadd( aOrdem, STR0022 ) // 'Filial + Documento + Serie'
Aadd( aOrdem, STR0023 ) // 'Filial + Emiss�o + Documento + Serie'

oFilOri := TRSection():New(oReport,STR0024,{"DT6"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Filial"
oFilOri:SetTotalInLine(.F.)
TRCell():New(oFilOri,"DT6_FILDOC","DT6",STR0025,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // 'Filial Origem'
TRCell():New(oFilOri,"DES.FILIAL",""   ,STR0026,""        ,15         ,          , {|| Posicione("SM0",1,cEmpAnt+(cAliasQry)->DT6_FILDOC,"M0_FILIAL") }) // 'Descri��o'

oSection := TRSection():New(oFilOri,STR0027,{"DT6","SA1"},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Documento"
oSection:SetTotalInLine(.F.)
TRCell():New(oSection,"DT6_DATEMI","DT6",STR0028,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"DT6_DOC"   ,"DT6",STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // "Documento"
TRCell():New(oSection,SerieNfId("DT6",3,"DT6_SERIE"),"DT6",STR0029,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // 'Serie'
TRCell():New(oSection,"DT6_DOCTMS","DT6",STR0030,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| TMSValField(cAliasQry+'->DT6_DOCTMS',.F.) }) // Tipo
TRCell():New(oSection,"DT6_FILDES","DT6",STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // 'Fil.Dest.'
TRCell():New(oSection,"DT6_TIPTRA","DT6",STR0032,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| TMSValField(cAliasQry+'->DT6_TIPTRA',.F.) }) // Transporte
TRCell():New(oSection,"DT6_TIPFRE","DT6",STR0033,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // Frete
TRCell():New(oSection,"A1_NREDUZ" ,"SA1",STR0034,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // 'Devedor'
TRCell():New(oSection,"DT6_PESO"  ,"DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"DT6_PESOM3","DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"DT6_PESCOB","DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"DT6_VOLORI","DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"DT6_VALTOT","DT6",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection,"DT6_PESCOB","DT6",STR0035,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Iif((cAliasQry)->DT6_PESCOB>0,((cAliasQry)->DT6_VALTOT/(cAliasQry)->DT6_PESCOB)*1000,0)}) // "Frete/Cobrado"

//-- Totalizador Pago Remetente
oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"COUNT_1" ,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(1,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"PESO_1"  ,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(1,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESOM3"),"PESOM3_1","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(1,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESCOB"),"PESCOB_1","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(1,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VOLORI"),"QTDVOL_1","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(1,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VALTOT"),"VALTOT_1","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(1,Len(DT6->DT6_DEVFRE)) })

//-- Totalizador Pago Destinatario
oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"COUNT_2" ,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(2,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"PESO_2"  ,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(2,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESOM3"),"PESOM3_2","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(2,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESCOB"),"PESCOB_2","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(2,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VOLORI"),"QTDVOL_2","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(2,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VALTOT"),"VALTOT_2","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(2,Len(DT6->DT6_DEVFRE)) })

//-- Totalizador Pago Consignatario
oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"COUNT_3" ,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(3,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"PESO_3"  ,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(3,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESOM3"),"PESOM3_3","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(3,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESCOB"),"PESCOB_3","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(3,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VOLORI"),"QTDVOL_3","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(3,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VALTOT"),"VALTOT_3","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(3,Len(DT6->DT6_DEVFRE)) })

//-- Totalizador Pago Despachante
oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"COUNT_4" ,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(4,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"PESO_4"  ,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(4,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESOM3"),"PESOM3_4","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(4,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESCOB"),"PESCOB_4","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(4,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VOLORI"),"QTDVOL_4","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(4,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VALTOT"),"VALTOT_4","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(1,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(4,Len(DT6->DT6_DEVFRE)) })

//-- Totalizador Pagar Remetente
oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"COUNT_5" ,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(1,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"PESO_5"  ,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(1,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESOM3"),"PESOM3_5","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(1,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESCOB"),"PESCOB_5","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(1,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VOLORI"),"QTDVOL_5","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(1,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VALTOT"),"VALTOT_5","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(1,Len(DT6->DT6_DEVFRE)) })

//-- Totalizador Pagar Destinatario
oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"COUNT_6" ,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(2,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"PESO_6"  ,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(2,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESOM3"),"PESOM3_6","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(2,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESCOB"),"PESCOB_6","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(2,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VOLORI"),"QTDVOL_6","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(2,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VALTOT"),"VALTOT_6","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(2,Len(DT6->DT6_DEVFRE)) })

//-- Totalizador Pagar Consignatario
oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"COUNT_7" ,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(3,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"PESO_7"  ,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(3,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESOM3"),"PESOM3_7","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(3,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESCOB"),"PESCOB_7","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(3,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VOLORI"),"QTDVOL_7","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(3,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VALTOT"),"VALTOT_7","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(3,Len(DT6->DT6_DEVFRE)) })

//-- Totalizador Pagar Despachante
oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"COUNT_8" ,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(4,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESO"  ),"PESO_8"  ,"SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(4,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESOM3"),"PESOM3_8","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(4,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_PESCOB"),"PESCOB_8","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(4,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VOLORI"),"QTDVOL_8","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(4,Len(DT6->DT6_DEVFRE)) })

oTotaliz := TRFunction():New(oSection:Cell("DT6_VALTOT"),"VALTOT_8","SUM"  ,/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
oTotaliz:SetCondition({ || (cAliasQry)->DT6_TIPFRE == StrZero(2,Len(DT6->DT6_TIPFRE)) .And. (cAliasQry)->DT6_DEVFRE == StrZero(4,Len(DT6->DT6_DEVFRE)) })

//-- Secao Totalizadora
oTotal := TRSection():New(oReport,STR0036,{},/*{Array com as ordens do relat�rio}*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Total Geral"
oTotal:SetHeaderSection()
oTotal:SetPageBreak()
TRCell():New(oTotal,"TEXTO"     ,"   ",STR0036,/*cPicture*/          ,25         ,/*lPixel*/,/*{|| code-block de impressao }*/) // "Total Geral"
TRCell():New(oTotal,"QTDE"      ,"   ",STR0037,"@E 99,999,999,999.99",18         ,/*lPixel*/,/*{|| code-block de impressao }*/) // "Quantidade"
TRCell():New(oTotal,"DT6_PESO"  ,"DT6",STR0038,"@E 99,999,999,999.99",18/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // "Peso Real"
TRCell():New(oTotal,"DT6_PESOM3","DT6",STR0039,"@E 99,999,999,999.99",18/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // "Peso Cubado"
TRCell():New(oTotal,"DT6_PESCOB","DT6",STR0050,"@E 99,999,999,999.99",18/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // "Peso Cobrado"
TRCell():New(oTotal,"QTDVOL"    ,"   ",STR0040,"@E 99,999,999,999.99",18         ,/*lPixel*/,/*{|| code-block de impressao }*/) // "Volumes"
TRCell():New(oTotal,"DT6_VALTOT","DT6",STR0041,"@E 99,999,999,999.99",18/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) // "Valor Frete"

RestArea(aAreaSM0)

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

Local lQuery    := .F.
Local cFetch		:= ""

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
lQuery := .T.
oReport:Section(1):BeginQuery()	

If oReport:Section(1):GetOrder() == 2
	cOrder := "%DT6_DATEMI,%"
Else
	cOrder := "%%"
EndIf

If SerieNfId("DT6",3,"DT6_SERIE")=="DT6_SDOC"
	cFetch := "%,DT6_SDOC%"
Else
	cFetch := "%%"	
EndIf

BeginSql Alias cAliasQry
	SELECT DT6_FILDOC,DT6_DATEMI,DT6_DOCTMS,DT6_TIPTRA,DT6_DOC,DT6_SERIE,DT6_FILDES,DT6_TIPFRE,
			 DT6_CLIDEV,DT6_LOJDEV,DT6_PESO,DT6_PESOM3,DT6_PESCOB,DT6_VOLORI,DT6_DEVFRE,DT6_VALTOT,A1_NREDUZ%Exp:cFetch%
			 
	FROM %table:DT6% DT6
	LEFT JOIN %table:SA1% SA1 ON A1_FILIAL = %xFilial:SA1%
		AND A1_COD    = DT6_CLIDEV
		AND A1_LOJA   = DT6_LOJDEV
		AND SA1.%NotDel%
	WHERE  DT6_FILIAL = %xFilial:DT6% 
		AND DT6_FILDOC >= %Exp:mv_par01%
		AND DT6_FILDOC <= %Exp:mv_par02%
		AND DT6_DATEMI >= %Exp:DTOS(mv_par03)%
		AND DT6_DATEMI <= %Exp:DTOS(mv_par04)%
		AND DT6_DOCTMS >= %Exp:mv_par05%
		AND DT6_DOCTMS <= %Exp:mv_par06%
		AND DT6_TIPTRA >= %Exp:mv_par07%
		AND DT6_TIPTRA <= %Exp:mv_par08%
		AND DT6.%NotDel%
		
	ORDER BY DT6_FILDOC, %Exp:cOrder% DT6_DOC, DT6_SERIE
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
oReport:SetMeter(DT6->(LastRec()))

//-- Utiliza a query do Pai
oReport:Section(1):Section(1):SetParentQuery()

oReport:Section(1):Section(1):SetParentFilter( { |cParam| DT6_FILDOC == cParam },{ || (cAliasQry)->DT6_FILDOC })

oReport:Section(1):Print()

//-- Impressao dos totalizadores
oReport:Section(2):Init()

oReport:Section(2):Cell("TEXTO"):SetValue(STR0042) // "Pago Remetente"
oReport:Section(2):Cell("QTDE"):SetValue(oReport:Section(1):Section(1):GetFunction("COUNT_1"):ReportValue())
oReport:Section(2):Cell("DT6_PESO"):SetValue(oReport:Section(1):Section(1):GetFunction("PESO_1"):ReportValue())
oReport:Section(2):Cell("DT6_PESOM3"):SetValue(oReport:Section(1):Section(1):GetFunction("PESOM3_1"):ReportValue())
oReport:Section(2):Cell("DT6_PESCOB"):SetValue(oReport:Section(1):Section(1):GetFunction("PESCOB_1"):ReportValue())
oReport:Section(2):Cell("QTDVOL"):SetValue(oReport:Section(1):Section(1):GetFunction("QTDVOL_1"):ReportValue())
oReport:Section(2):Cell("DT6_VALTOT"):SetValue(oReport:Section(1):Section(1):GetFunction("VALTOT_1"):ReportValue())
oReport:Section(2):PrintLine()
  
oReport:Section(2):Cell("TEXTO"):SetValue(STR0043) // "Pago Destinat�rio"
oReport:Section(2):Cell("QTDE"):SetValue(oReport:Section(1):Section(1):GetFunction("COUNT_2"):ReportValue())
oReport:Section(2):Cell("DT6_PESO"):SetValue(oReport:Section(1):Section(1):GetFunction("PESO_2"):ReportValue())
oReport:Section(2):Cell("DT6_PESOM3"):SetValue(oReport:Section(1):Section(1):GetFunction("PESOM3_2"):ReportValue())
oReport:Section(2):Cell("DT6_PESCOB"):SetValue(oReport:Section(1):Section(1):GetFunction("PESCOB_2"):ReportValue())
oReport:Section(2):Cell("QTDVOL"):SetValue(oReport:Section(1):Section(1):GetFunction("QTDVOL_2"):ReportValue())
oReport:Section(2):Cell("DT6_VALTOT"):SetValue(oReport:Section(1):Section(1):GetFunction("VALTOT_2"):ReportValue())
oReport:Section(2):PrintLine()

oReport:Section(2):Cell("TEXTO"):SetValue(STR0044) // "Pago Consignat�rio"
oReport:Section(2):Cell("QTDE"):SetValue(oReport:Section(1):Section(1):GetFunction("COUNT_3"):ReportValue())
oReport:Section(2):Cell("DT6_PESO"):SetValue(oReport:Section(1):Section(1):GetFunction("PESO_3"):ReportValue())
oReport:Section(2):Cell("DT6_PESOM3"):SetValue(oReport:Section(1):Section(1):GetFunction("PESOM3_3"):ReportValue())
oReport:Section(2):Cell("DT6_PESCOB"):SetValue(oReport:Section(1):Section(1):GetFunction("PESCOB_3"):ReportValue())
oReport:Section(2):Cell("QTDVOL"):SetValue(oReport:Section(1):Section(1):GetFunction("QTDVOL_3"):ReportValue())
oReport:Section(2):Cell("DT6_VALTOT"):SetValue(oReport:Section(1):Section(1):GetFunction("VALTOT_3"):ReportValue())
oReport:Section(2):PrintLine()

oReport:Section(2):Cell("TEXTO"):SetValue(STR0045) // "Pago Despachante"
oReport:Section(2):Cell("QTDE"):SetValue(oReport:Section(1):Section(1):GetFunction("COUNT_4"):ReportValue())
oReport:Section(2):Cell("DT6_PESO"):SetValue(oReport:Section(1):Section(1):GetFunction("PESO_4"):ReportValue())
oReport:Section(2):Cell("DT6_PESOM3"):SetValue(oReport:Section(1):Section(1):GetFunction("PESOM3_4"):ReportValue())
oReport:Section(2):Cell("DT6_PESCOB"):SetValue(oReport:Section(1):Section(1):GetFunction("PESCOB_4"):ReportValue())
oReport:Section(2):Cell("QTDVOL"):SetValue(oReport:Section(1):Section(1):GetFunction("QTDVOL_4"):ReportValue())
oReport:Section(2):Cell("DT6_VALTOT"):SetValue(oReport:Section(1):Section(1):GetFunction("VALTOT_4"):ReportValue())
oReport:Section(2):PrintLine()

//-- Pula Linha
oReport:SkipLine()

oReport:Section(2):Cell("TEXTO"):SetValue(STR0046) // "Pagar Remetente"
oReport:Section(2):Cell("QTDE"):SetValue(oReport:Section(1):Section(1):GetFunction("COUNT_5"):ReportValue())
oReport:Section(2):Cell("DT6_PESO"):SetValue(oReport:Section(1):Section(1):GetFunction("PESO_5"):ReportValue())
oReport:Section(2):Cell("DT6_PESOM3"):SetValue(oReport:Section(1):Section(1):GetFunction("PESOM3_5"):ReportValue())
oReport:Section(2):Cell("DT6_PESCOB"):SetValue(oReport:Section(1):Section(1):GetFunction("PESCOB_5"):ReportValue())
oReport:Section(2):Cell("QTDVOL"):SetValue(oReport:Section(1):Section(1):GetFunction("QTDVOL_5"):ReportValue())
oReport:Section(2):Cell("DT6_VALTOT"):SetValue(oReport:Section(1):Section(1):GetFunction("VALTOT_5"):ReportValue())
oReport:Section(2):PrintLine()

oReport:Section(2):Cell("TEXTO"):SetValue(STR0047) // "Pagar Destinat�rio"
oReport:Section(2):Cell("QTDE"):SetValue(oReport:Section(1):Section(1):GetFunction("COUNT_6"):ReportValue())
oReport:Section(2):Cell("DT6_PESO"):SetValue(oReport:Section(1):Section(1):GetFunction("PESO_6"):ReportValue())
oReport:Section(2):Cell("DT6_PESOM3"):SetValue(oReport:Section(1):Section(1):GetFunction("PESOM3_6"):ReportValue())
oReport:Section(2):Cell("DT6_PESCOB"):SetValue(oReport:Section(1):Section(1):GetFunction("PESCOB_6"):ReportValue())
oReport:Section(2):Cell("QTDVOL"):SetValue(oReport:Section(1):Section(1):GetFunction("QTDVOL_6"):ReportValue())
oReport:Section(2):Cell("DT6_VALTOT"):SetValue(oReport:Section(1):Section(1):GetFunction("VALTOT_6"):ReportValue())
oReport:Section(2):PrintLine()

oReport:Section(2):Cell("TEXTO"):SetValue(STR0048) // "Pagar Consignat�rio"
oReport:Section(2):Cell("QTDE"):SetValue(oReport:Section(1):Section(1):GetFunction("COUNT_7"):ReportValue())
oReport:Section(2):Cell("DT6_PESO"):SetValue(oReport:Section(1):Section(1):GetFunction("PESO_7"):ReportValue())
oReport:Section(2):Cell("DT6_PESOM3"):SetValue(oReport:Section(1):Section(1):GetFunction("PESOM3_7"):ReportValue())
oReport:Section(2):Cell("DT6_PESCOB"):SetValue(oReport:Section(1):Section(1):GetFunction("PESCOB_7"):ReportValue())
oReport:Section(2):Cell("QTDVOL"):SetValue(oReport:Section(1):Section(1):GetFunction("QTDVOL_7"):ReportValue())
oReport:Section(2):Cell("DT6_VALTOT"):SetValue(oReport:Section(1):Section(1):GetFunction("VALTOT_7"):ReportValue())
oReport:Section(2):PrintLine()

oReport:Section(2):Cell("TEXTO"):SetValue(STR0049) // "Pagar Despachante"
oReport:Section(2):Cell("QTDE"):SetValue(oReport:Section(1):Section(1):GetFunction("COUNT_8"):ReportValue())
oReport:Section(2):Cell("DT6_PESO"):SetValue(oReport:Section(1):Section(1):GetFunction("PESO_8"):ReportValue())
oReport:Section(2):Cell("DT6_PESOM3"):SetValue(oReport:Section(1):Section(1):GetFunction("PESOM3_8"):ReportValue())
oReport:Section(2):Cell("DT6_PESCOB"):SetValue(oReport:Section(1):Section(1):GetFunction("PESCOB_8"):ReportValue())
oReport:Section(2):Cell("QTDVOL"):SetValue(oReport:Section(1):Section(1):GetFunction("QTDVOL_8"):ReportValue())
oReport:Section(2):Cell("DT6_VALTOT"):SetValue(oReport:Section(1):Section(1):GetFunction("VALTOT_8"):ReportValue())
oReport:Section(2):PrintLine()

oReport:Section(2):Finish()

Return