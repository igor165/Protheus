#INCLUDE "TMSR400.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR400  � Autor � Eduardo de Souza      � Data � 23/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Contas Correntes de Carreteiro                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR400()

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
���Programa  �ReportDef � Autor � Eduardo de Souza      � Data � 23/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR400                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local oProp
Local oVeiculo
Local oViagem
Local oDespAb
Local oBreak
Local oTotaliz
Local aOrdem     := {}
Local aRet       := {}
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
oReport:= TReport():New("TMSR400",STR0019,"TMR400", {|oReport| ReportPrint(oReport,cAliasQry)},STR0020) // "Contas Correntes de Carreteiro" ### "Emite as Contas Correntes de Carreteiro conforme os parametros informados"
oReport:SetTotalInLine(.F.)
oReport:SetLandscape()

//��������������������������������������������������������������Ŀ
//� Carrega as perguntas selecionadas                            �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01 - Servico de Transp. ? Coleta/Transp./Entrega/Todos �
//� mv_par02 - Periodo De         ?                              �
//� mv_par03 - Periodo Ate        ?                              �
//� mv_par04 - Proprietario De    ?                              �
//� mv_par05 - Loja De            ?                              �
//� mv_par06 - Proprietario Ate   ?                              �
//� mv_par07 - Loja Ate           ?                              �	 
//� mv_par08 - Contrato Gerado    ? (Sim/Nao/Ambos)              �	
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
Aadd( aOrdem, STR0021 ) // "Propriet�rio + Ve�culo"

oProp := TRSection():New(oReport,STR0022,{"DTR","SA2"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/) // "Propriet�rio"
oProp:SetTotalInLine(.F.)
TRCell():New(oProp,"DTR_CODFOR","DTR",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProp,"DTR_LOJFOR","DTR",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oProp,"A2_NOME"   ,"DTR",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oVeiculo := TRSection():New(oProp,STR0023,{"DTR","DA3"},,/*Campos do SX3*/,/*Campos do SIX*/) // "Ve�culo"
oVeiculo:SetTotalInLine(.F.)
oVeiculo:SetTotalText(STR0024) // "Total Previsto para o ve�culo"
TRCell():New(oVeiculo,"DTR_CODVEI","DTR",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DA3_PLACA" ,"DA3",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oVeiculo,"DA3_DESC"  ,"DA3",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

oViagem := TRSection():New(oVeiculo,STR0026,{"DTQ","DTR","DTY","DA8","SDG","DT7"},,/*Campos do SX3*/,/*Campos do SIX*/) // "Ve�culo"
oViagem:SetTotalInLine(.F.)
TRCell():New(oViagem,"DTQ_FILORI","DTQ",STR0025,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTQ_VIAGEM","DTQ",STR0026,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTQ_DATGER","DTQ",STR0027,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTQ_DATENC","DTQ",STR0028,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTY_NUMCTC","DTY",STR0029,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTQ_ROTA"  ,"DTQ",STR0030,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DA8_DESC"  ,"DA8",STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DTR_VALFRE","DTR",STR0032,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| Iif(Len(aRet:= TMSCalFrePag((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM,(cAliasQry)->DA3_COD,{},.F.))>0,aRet[1][3],0) })
TRCell():New(oViagem,"DTR_VALPDG","DTR",STR0033,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DG_VALCOB" ,"SDG",STR0034,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DT7_DESCRI","DT7",STR0031,/*Picture*/,20         ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oViagem,"DG_TOTAL"  ,"   ",STR0035,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| TMR400Sd((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM,(cAliasQry)->DTR_VALPDG,(cAliasQry)->DG_VALCOB,oViagem) } )

oBreak := TRBreak():New(oViagem,oViagem:Cell("DTQ_VIAGEM"),STR0036,.F.) // "Total da Viagem"
TRFunction():New(oViagem:Cell("DG_VALCOB"),/*cId*/,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)
TRFunction():New(oViagem:Cell("DG_TOTAL" ),/*cId*/,"SUM",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

oTotaliz:= TRFunction():New(oViagem:Cell("DTR_VALFRE"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oVeiculo)
oTotaliz:SetCondition({ || TMR400Tot((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM+"1") })

oTotaliz:= TRFunction():New(oViagem:Cell("DTR_VALPDG"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oVeiculo)
oTotaliz:SetCondition({ || TMR400Tot((cAliasQry)->DTQ_FILORI,(cAliasQry)->DTQ_VIAGEM+"2") })

TRFunction():New(oViagem:Cell("DG_VALCOB" ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oVeiculo)
TRFunction():New(oViagem:Cell("DG_TOTAL"  ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/,oVeiculo)

oDespAb := TRSection():New(oReport,STR0037,{"SDG","DT7"},/*Ordem do relatorio*/,/*Campos do SX3*/,/*Campos do SIX*/) // "Propriet�rio"
oDespAb:SetTotalInLine(.F.)
oDespAb:SetTotalText(STR0038) // "Total de Despesas em Aberto"
TRCell():New(oDespAb,"DG_EMISSAO","SDG",STR0039,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDespAb,"DG_DATVENC","SDG",STR0040,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDespAb,"DT7_DESCRI","DT7",STR0031,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDespAb,"DG_VALCOB" ,"SDG",STR0041,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

TRFunction():New(oDespAb:Cell("DG_VALCOB" ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

Return(oReport)

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrin� Autor �Eduardo de Souza       � Data � 23/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relat�rio                           ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR400                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry)

Local cQuery     := ""
Local cCodFor    := ""
Local cLojFor    := ""
Local cFilOri    := ""
Local cViagem    := ""
Local cAliasQry2 := GetNextAlias()
Local cJoin	 	 := ""
Private cCodVei  := ""

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

cQuery := "%"
If mv_par01 == 1  //-- Coleta
   cQuery += "  AND DTQ_SERTMS = '"+StrZero(1, Len(DTQ->DTQ_SERTMS))+ "'"
ElseIf mv_par01 == 2  //-- Transporte
   cQuery += "  AND DTQ_SERTMS = '"+StrZero(2, Len(DTQ->DTQ_SERTMS))+ "'"
ElseIf mv_par01 == 3  //-- Entrega                                 
   cQuery += "  AND DTQ_SERTMS = '"+StrZero(3, Len(DTQ->DTQ_SERTMS))+ "'"
EndIf	         
cQuery += "%"

cJoin := "% AND DG_FILORI = DTQ_FILORI AND DG_VIAGEM = DTQ_VIAGEM%"

BeginSql Alias cAliasQry
	SELECT DTQ_FILORI, DTQ_VIAGEM, DTQ_DATGER, DTQ_DATENC, DTQ_ROTA, DTR_CODVEI, DTR_VALFRE, DTR_VALPDG, DA3_CODFOR, DA3_LOJFOR, DA3_COD, DA3_PLACA, DA3_DESC, A2_NOME, DTY_NUMCTC  , DTR_CODFOR, DTR_LOJFOR,
			 DG_EMISSAO, DG_DATVENC, DG_VALCOB, DT7_DESCRI, DA8_DESC, A2_FILIAL
		FROM %table:DTQ% DTQ   
		JOIN %table:DTR% DTR
			ON  DTR_FILIAL = %xFilial:DTR%
			AND DTR_FILORI = DTQ_FILORI   
			AND DTR_VIAGEM = DTQ_VIAGEM   
			AND DTR.%NotDel%
		JOIN %table:DA3% DA3
			ON  DA3_FILIAL = %xFilial:DA3%
			AND DA3_COD    = DTR_CODVEI   
			AND DA3_FROVEI <> %Exp:StrZero(1,Len(DA3->DA3_FROVEI))%
			AND DA3.%NotDel%
		JOIN %table:SA2% SA2
			ON  A2_FILIAL = %xFilial:SA2%
			AND A2_COD    = DTR_CODFOR   
			AND A2_LOJA   = DTR_LOJFOR   
			AND SA2.%NotDel%
		JOIN %table:DA8% DA8
			ON DA8_FILIAL = %xFilial:DA8%
			AND DA8_COD = DTQ_ROTA
			AND DA8_ATIVO = %Exp:StrZero(1,Len(DA8->DA8_ATIVO))%
			AND DA8.%NotDel%
		LEFT JOIN %table:DTY% DTY 
			ON   DTY_FILIAL = %xFilial:DTY%
			AND DTY_FILORI = DTQ_FILORI   
			AND DTY_VIAGEM = DTQ_VIAGEM   
			AND DTY.%NotDel%
		LEFT JOIN %table:SDG% SDG
			ON DG_FILIAL = %xFilial:SDG%
			%Exp:cJoin%
			AND DG_CODVEI = DTR_CODVEI
			AND DG_STATUS = %Exp:StrZero(3,Len(SDG->DG_STATUS))%
			AND SDG.%NotDel%
		LEFT JOIN %table:DT7% DT7
			ON DT7_FILIAL = %xFilial:DT7%
			AND DT7_CODDES = DG_CODDES
			AND DT7.%NotDel%
		WHERE DTQ_FILIAL  = %xFilial:DTQ%
			AND DTQ_STATUS = %Exp:StrZero(3,Len(DTQ->DTQ_STATUS))%
			AND DTQ_DATENC BETWEEN %Exp:DTOS(mv_par02)% AND %Exp:DTOS(mv_par03)%
			AND DTR_CODFOR BETWEEN %Exp:mv_par04% AND %Exp:mv_par06%
			AND DTR_LOJFOR BETWEEN %Exp:mv_par05% AND %Exp:mv_par07%
			AND DTQ.%NotDel%
			%Exp:cQuery%
	ORDER BY A2_FILIAL, A2_NOME, DTR_CODFOR, DTR_LOJFOR, DTR_CODVEI, DTQ_FILORI, DTQ_VIAGEM
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

Begin Report Query oReport:Section(2)

//-- Verifica os adiantamentos com status 'Em Aberto' / 'Baixados Parcialmente'
BeginSql Alias cAliasQry2
	SELECT DG_EMISSAO, DG_DATVENC, DG_VALCOB, DT7_DESCRI
		FROM %table:SDG% SDG
		JOIN %table:DT7% DT7
			ON DT7_FILIAL = %xFilial:DT7%
			AND DT7_CODDES = DG_CODDES
			AND DT7.%NotDel%
		WHERE DG_FILIAL = %xFilial:SDG%
			AND DG_CODVEI = %report_param:cCodVei%
			AND ( DG_STATUS = %Exp:StrZero(1,Len(SDG->DG_STATUS))%
				OR DG_STATUS = %Exp:StrZero(2,Len(SDG->DG_STATUS))% )
			AND SDG.%NotDel%
EndSql 

End Report Query oReport:Section(2)

oReport:Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->DTR_CODFOR + (cAliasQry)->DTR_LOJFOR == cParam },{ || (cAliasQry)->DTR_CODFOR + (cAliasQry)->DTR_LOJFOR })
oReport:Section(1):Section(1):Section(1):SetParentQuery()
oReport:Section(1):Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->DTR_CODVEI == cParam },{ || (cAliasQry)->DTR_CODVEI })

//-- Inicio da impressao do fluxo do relat�rio
oReport:SetMeter(DTR->(LastRec()))

DbSelectArea(cAliasQry)
While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
	cCodFor := (cAliasQry)->DTR_CODFOR
	cLojFor := (cAliasQry)->DTR_LOJFOR
	//-- Impressao da secao Proprietario
	oReport:Section(1):Init()
	oReport:Section(1):PrintLine()
	While !(cAliasQry)->(Eof()) .And. 	(cAliasQry)->DTR_CODFOR == cCodFor .And. ;
													(cAliasQry)->DTR_LOJFOR == cLojFor
		cCodVei := (cAliasQry)->DTR_CODVEI
		cFilOri := ''
		cViagem := ''
		oReport:Section(1):Section(1):Init()
		oReport:Section(1):Section(1):PrintLine()
		oReport:Section(1):Section(1):Section(1):Init()
		While !(cAliasQry)->(Eof()) .And. 	(cAliasQry)->DTR_CODFOR == cCodFor .And. ;
														(cAliasQry)->DTR_LOJFOR == cLojFor .And. ;
														(cAliasQry)->DTR_CODVEI == cCodVei
			If cFilOri + cViagem == (cAliasQry)->DTQ_FILORI + (cAliasQry)->DTQ_VIAGEM
				oReport:Section(1):Section(1):Section(1):Cell("DTQ_FILORI"):Hide()
				oReport:Section(1):Section(1):Section(1):Cell("DTQ_VIAGEM"):Hide()
				oReport:Section(1):Section(1):Section(1):Cell("DTQ_DATGER"):Hide()
				oReport:Section(1):Section(1):Section(1):Cell("DTQ_DATENC"):Hide()
				oReport:Section(1):Section(1):Section(1):Cell("DTY_NUMCTC"):Hide()
				oReport:Section(1):Section(1):Section(1):Cell("DTQ_ROTA"  ):Hide()
				oReport:Section(1):Section(1):Section(1):Cell("DA8_DESC"  ):Hide()
				oReport:Section(1):Section(1):Section(1):Cell("DTR_VALFRE"):Hide()
				oReport:Section(1):Section(1):Section(1):Cell("DTR_VALPDG"):Hide()
			Else
				oReport:Section(1):Section(1):Section(1):Cell("DTQ_FILORI"):Show()
				oReport:Section(1):Section(1):Section(1):Cell("DTQ_VIAGEM"):Show()
				oReport:Section(1):Section(1):Section(1):Cell("DTQ_DATGER"):Show()
				oReport:Section(1):Section(1):Section(1):Cell("DTQ_DATENC"):Show()
				oReport:Section(1):Section(1):Section(1):Cell("DTY_NUMCTC"):Show()
				oReport:Section(1):Section(1):Section(1):Cell("DTQ_ROTA"  ):Show()
				oReport:Section(1):Section(1):Section(1):Cell("DA8_DESC"  ):Show()
				oReport:Section(1):Section(1):Section(1):Cell("DTR_VALFRE"):Show()
				oReport:Section(1):Section(1):Section(1):Cell("DTR_VALPDG"):Show()
			EndIf
			oReport:Section(1):Section(1):Section(1):Cell("DG_TOTAL"):Hide()
			cFilOri := (cAliasQry)->DTQ_FILORI
			cViagem := (cAliasQry)->DTQ_VIAGEM
			oReport:Section(1):Section(1):Section(1):PrintLine()
			(cAliasQry)->(DbSkip())
		EndDo
		oReport:Section(1):Section(1):Section(1):Cell("DTQ_FILORI"):Show()
		oReport:Section(1):Section(1):Section(1):Cell("DTQ_VIAGEM"):Show()
		oReport:Section(1):Section(1):Section(1):Cell("DTQ_DATGER"):Show()
		oReport:Section(1):Section(1):Section(1):Cell("DTQ_DATENC"):Show()
		oReport:Section(1):Section(1):Section(1):Cell("DTY_NUMCTC"):Show()
		oReport:Section(1):Section(1):Section(1):Cell("DTQ_ROTA"  ):Show()
		oReport:Section(1):Section(1):Section(1):Cell("DA8_DESC"  ):Show()
		oReport:Section(1):Section(1):Section(1):Cell("DTR_VALFRE"):Show()
		oReport:Section(1):Section(1):Section(1):Cell("DTR_VALPDG"):Show()
		oReport:Section(1):Section(1):Section(1):Finish()
		oReport:Section(1):Section(1):Finish()

		//-- Despesas em aberto
		oReport:Section(2):ExecSql()
		If !(cAliasQry2)->(Eof())
			oReport:SkipLine(2)
			oReport:Section(2):Init()
			While (cAliasQry2)->(!Eof())
				oReport:Section(2):PrintLine()
				(cAliasQry2)->(DbSkip())
			EndDo
			oReport:Section(2):Finish()
		EndIf

	EndDo
	oReport:Section(1):Finish()
EndDo													

//-- Zera a variavel controladora do totalizador da viagem
TMR400Tot(,,.T.)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMR400Tot � Autor �Eduardo de Souza       � Data � 23/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Validacao do totalizador da viagem                         ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Filial Origem                                        ���
���          �ExpC2: Viagem                                               ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR400                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR400Tot(cFilOri,cViagem,lZera)

Static aViagem := {}
Local lRet := .F.
Default lZera := .F.

If lZera
	aViagem := {}
ElseIf Ascan( aViagem, { |x| x[1]+x[2] == cFilOri + cViagem } ) == 0
	Aadd( aViagem, { cFilOri, cViagem } )
	lRet := .T.
EndIf

Return lRet

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMR400Sd  � Autor �Eduardo de Souza       � Data � 23/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Saldo a Receber                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Filial Origem                                        ���
���          �ExpC2: Viagem                                               ���
���          �ExpN1: Valor do Pedagio                                     ���
���          �ExpN2: Valor da Despesas                                    ���
���          �ExpA1: Frete Previsto                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR400                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR400Sd(cFilOri,cViagem,nValPdg,nValCob,oViagem)

Static nSaldo := 0
Static cVge   := ''
Local nValFre := oViagem:Cell("DTR_VALFRE"):UPRINT

If cFilOri + cViagem == cVge
	nSaldo := -nValCob
Else
	nSaldo := nValFre + nValPdg - nValCob
EndIf
cVge := cFilOri + cViagem

Return nSaldo