#INCLUDE "TMSR490.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR490  � Autor � Eduardo de Souza      � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Documentos Embarcados                                      ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR490()

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
���Uso       � TMSR490                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportDef()

Local oReport
Local cAliasQry := GetNextAlias()
Local aOrdem    := {}
Local lTercRbq  := DTR->(ColumnPos("DTR_CODRB3")) > 0

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
oReport:= TReport():New("TMSR490",STR0009,"TMR490", {|oReport| ReportPrint(oReport,cAliasQry)},STR0010) // "Documentos Embarcados" ### "Emite Relacao de Documentos Embarcados, conforme parametros informados"
oReport:SetTotalInLine(.F.)
oReport:SetLandscape(.T.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� mv_par01	 // Filial Origem De	                             �
//� mv_par02	 // Filial Origem Ate                             �
//� mv_par03	 // Data Saida De                                 �
//� mv_par04	 // Data Saida Ate                                �
//� mv_par05	 // Tipo Transporte De                            �
//� mv_par06	 // Tipo Transporte Ate                           �
//� mv_par07	 // Data Embarque De                              �
//� mv_par08	 // Data Embarque Ate                             �
//� mv_par09	 // Cod. Remetente De                             �
//� mv_par10	 // Loja Remetente De                             �
//� mv_par11	 // Cod. Remetente Ate                            �
//� mv_par12	 // Loja Remetente Ate                            �
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
Aadd( aOrdem, STR0011 ) // "Emiss�o + Fil.Docto + Documento + Serie"

oDocumento:= TRSection():New(oReport,STR0012,{"DT6","SA1","DUY","DTW","DTR"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oDocumento:SetTotalInLine(.F.)
oDocumento:SetTotalText(STR0013) //-- "Total Documento"
TRCell():New(oDocumento,"DT6_FILDOC","DT6",STR0018   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DT6_DOC"   ,"DT6",STR0019   ,/*Picture*/,TamSx3("DT6_DOC")[1]+2,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,SerieNfId("DT6",3,"DT6_SERIE") ,"DT6",STR0020   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DT6_DATEMI","DT6",STR0021   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"A1_NREDUZ" ,"SA1",STR0014   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DUY_DESCRI","DUY",STR0015   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DUY_EST"   ,"DUY",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DTW_DATREA","DTW",STR0022   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DT6_ULTEMB","DT6",STR0023   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DT6_VALMER","DT6",/*cTitle*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"PLACAVEI"  ,""   ,STR0016   ,/*Picture*/,TamSx3("DA3_PLACA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DTR_CODVEI","DTR",STR0024   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DESVEI"    ,""   ,STR0017   ,/*Picture*/,TamSx3("DA3_DESC")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"PLACARB1"  ,""   ,STR0016   ,/*Picture*/,TamSx3("DA3_PLACA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DTR_CODRB1","DTR",STR0025   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DESRB1"    ,""   ,STR0017   ,/*Picture*/,TamSx3("DA3_DESC")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"PLACARB2"  ,""   ,STR0016   ,/*Picture*/,TamSx3("DA3_PLACA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DTR_CODRB2","DTR",STR0026   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oDocumento,"DESRB2"    ,""   ,STR0017   ,/*Picture*/,TamSx3("DA3_DESC")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
If lTercRbq
	TRCell():New(oDocumento,"PLACARB3"  ,""   ,STR0016   ,/*Picture*/,TamSx3("DA3_PLACA")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oDocumento,"DTR_CODRB3","DTR",STR0027   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oDocumento,"DESRB3"    ,""   ,STR0017   ,/*Picture*/,TamSx3("DA3_DESC")[1] ,/*lPixel*/,/*{|| code-block de impressao }*/)
EndIf
oTotaliz:=TRFunction():New(oDocumento:Cell("DT6_VALMER"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
oTotaliz:SetCondition({ || TMR490Doc((cAliasQry)->DT6_FILDOC,(cAliasQry)->DT6_DOC,(cAliasQry)->DT6_SERIE) })

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
���Uso       � TMSR490                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function ReportPrint(oReport,cAliasQry)

Local cAtivSAI  := GetMV('MV_ATIVSAI',,'')
Local cFetch    :=''
Local cGroup    :=''
Local cCodRb3   := ''
Local cPlacaRb3 := ''
Local cColNamRb3 := ''
Local cDescRb3  := ''
Local cDa3Ddesc := ''
Local lTercRbq  := DTR->(ColumnPos("DTR_CODRB3")) > 0

If lTercRbq
	cCodRb3   := "%DTR_CODRB3%"
	cPlacaRb3 := "%DA3D.DA3_PLACA%"
	cColNamRb3:= "%PLACARB3%"
	cDescRb3  := "%DESRB3%"
	cDa3Ddesc := "%DA3D.DA3_DESC%" 
EndIf 

If SerieNfId("DT6",3,"DT6_SERIE")=="DT6_SDOC"
	cFetch := '%DT6_SDOC,%'
	cGroup := '%DT6_SDOC,%'
Else
	cFetch :='%%'
	cGroup :='%%'
EndIf

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT MAX(DTW_FILORI) DTW_FILORI, MAX(DTW_VIAGEM) DTW_VIAGEM, MAX(DTW_DATREA) DTW_DATREA, 
			 DT6_FILDOC, DT6_DOC, DT6_SERIE, %Exp:cFetch% DT6_DATEMI, MAX(DT6_ULTEMB) DT6_ULTEMB, MAX(DT6_VALMER) DT6_VALMER, 
			 MAX(DUY_DESCRI) DUY_DESCRI, MAX(DUY_EST) DUY_EST, DTR_CODVEI, MAX(DA3A.DA3_PLACA) PLACAVEI, 
			 MAX(DA3A.DA3_DESC) DESVEI , MAX(DTR_CODRB1) DTR_CODRB1, MAX(DA3B.DA3_PLACA) PLACARB1, 
			 MAX(DA3B.DA3_DESC) DESRB1 , MAX(DTR_CODRB2) DTR_CODRB2, MAX(DA3C.DA3_PLACA) PLACARB2, 
			 MAX(DA3C.DA3_DESC) DESRB2 , MAX(%Exp:cCodRb3%) %Exp:cCodRb3%, MAX(%Exp:cPlacaRb3%) %Exp:cColNamRb3%, 
			 MAX(%Exp:cDa3Ddesc%) %Exp:cDescRb3% , MAX(A1_NREDUZ) A1_NREDUZ  , DT6_FILIAL
	   FROM %table:DTW% DTW   
	   LEFT JOIN %table:DTR% DTR
	     ON DTR_FILIAL = %xFilial:DTR%
	     AND DTR_FILORI = DTW_FILORI
	     AND DTR_VIAGEM = DTW_VIAGEM
	     AND DTR.%NotDel%
	   LEFT JOIN %table:DA3% DA3A
	     ON DA3A.DA3_FILIAL = %xFilial:DA3%
	     AND DA3A.DA3_COD = DTR_CODVEI
	     AND DA3A.%NotDel%
	   LEFT JOIN %table:DA3% DA3B
	     ON DA3B.DA3_FILIAL = %xFilial:DA3%
	     AND DA3B.DA3_COD = DTR_CODRB1
	     AND DA3B.%NotDel%
	   LEFT JOIN %table:DA3% DA3C
	     ON DA3C.DA3_FILIAL = %xFilial:DA3%
	     AND DA3C.DA3_COD = DTR_CODRB2
	     AND DA3C.%NotDel%
	   LEFT JOIN %table:DA3% DA3D
	     ON DA3D.DA3_FILIAL = %xFilial:DA3%
	     AND DA3D.DA3_COD = %Exp:cCodRb3%
	     AND DA3D.%NotDel%  
	   JOIN %table:DUD% DUD
	     ON DUD_FILIAL = %xFilial:DUD%
	     AND DUD_FILORI = DTW_FILORI
	     AND DUD_VIAGEM = DTW_VIAGEM
	     AND DUD_STATUS <> '9'
	     AND DUD.%NotDel%
	   JOIN %table:DT6% DT6
	     ON DT6_FILIAL = %xFilial:DT6%
	     AND DT6_FILDOC = DUD_FILDOC
	     AND DT6_DOC    = DUD_DOC
	     AND DT6_SERIE  = DUD_SERIE
	     AND DT6_ULTEMB BETWEEN %Exp:Dtos(mv_par07)% AND %Exp:Dtos(mv_par08)%
		  AND DT6_CLIREM BETWEEN %Exp:mv_par09% AND %Exp:mv_par11%
		  AND DT6_LOJREM BETWEEN %Exp:mv_par10% AND %Exp:mv_par12%
	     AND DT6.%NotDel%
	   JOIN %table:DUY% DUY
	     ON DUY_FILIAL = %xFilial:DUY%
	     AND DUY_GRPVEN = DT6_CDRDES
	     AND DUY.%NotDel%
	   JOIN %table:SA1% SA1
	     ON A1_FILIAL = %xFilial:SA1%
	     AND A1_COD = DT6_CLIREM
	     AND A1_LOJA = DT6_LOJREM
	     AND SA1.%NotDel%
	   WHERE DTW_FILIAL = %xFilial:DTW%
		  AND DTW_FILATI BETWEEN %Exp:mv_par01% AND %Exp:mv_par02%
		  AND DTW_TIPTRA BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
		  AND DTW_DATREA BETWEEN %Exp:Dtos(mv_par03)% AND %Exp:Dtos(mv_par04)%
		  AND DTW_SERTMS IN ('3', '2')
		  AND DTW_ATIVID = %Exp:cATIVSAI%
	     AND DTW.%NotDel%
	GROUP BY DT6_FILIAL, DT6_DATEMI, DT6_FILDOC, DT6_DOC, DT6_SERIE, %Exp:cGroup% DTR_CODVEI
	ORDER BY DT6_FILIAL, DT6_DATEMI, DT6_FILDOC, DT6_DOC, DT6_SERIE, DTR_CODVEI
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

DbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	oReport:Section(1):Init()
	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
		cFilDoc := (cAliasQry)->DT6_FILDOC
		cDocto  := (cAliasQry)->DT6_DOC
		cSerie  := (cAliasQry)->DT6_SERIE	
		oReport:Section(1):PrintLine()
		(cAliasQry)->(DbSkip())
		While !(cAliasQry)->(Eof()) .And. 	(cAliasQry)->DT6_FILDOC == cFilDoc .And. ;
														(cAliasQry)->DT6_DOC    == cDocto  .And. ;
														(cAliasQry)->DT6_SERIE  == cSerie
			oReport:Section(1):Cell("DT6_FILDOC"):Hide()
			oReport:Section(1):Cell("DT6_DOC"   ):Hide()
			oReport:Section(1):Cell(SerieNfId("DT6",3,"DT6_SERIE") ):Hide()
			oReport:Section(1):Cell("DT6_DATEMI"):Hide()
			oReport:Section(1):Cell("A1_NREDUZ" ):Hide()
			oReport:Section(1):Cell("DUY_DESCRI"):Hide()
			oReport:Section(1):Cell("DUY_EST"   ):Hide()
			oReport:Section(1):Cell("DTW_DATREA"):Hide()
			oReport:Section(1):Cell("DT6_ULTEMB"):Hide()
			oReport:Section(1):Cell("DT6_VALMER"):Hide()
			oReport:Section(1):PrintLine()
			(cAliasQry)->(DbSkip())
		EndDo
		oReport:Section(1):Cell("DT6_FILDOC"):Show()
		oReport:Section(1):Cell("DT6_DOC"   ):Show()
		oReport:Section(1):Cell(SerieNfId("DT6",3,"DT6_SERIE") ):Show()
		oReport:Section(1):Cell("DT6_DATEMI"):Show()
		oReport:Section(1):Cell("A1_NREDUZ" ):Show()
		oReport:Section(1):Cell("DUY_DESCRI"):Show()
		oReport:Section(1):Cell("DUY_EST"   ):Show()
		oReport:Section(1):Cell("DTW_DATREA"):Show()
		oReport:Section(1):Cell("DT6_ULTEMB"):Show()
		oReport:Section(1):Cell("DT6_VALMER"):Show()
	EndDo
	oReport:Section(1):Finish()
EndIf

TMR490Doc(,,,.T.)

Return

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �TMR490Doc � Autor �Eduardo de Souza       � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Controla o totalizador do relatorio                        ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Filial Documento                                     ���
���          �ExpC2: Documento                                            ���
���          �ExpC3: Serie                                                ���
���          �ExpL1: Zera variavel                                        ���
�������������������������������������������������������������������������Ĵ��
���Uso       � TMSR490                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function TMR490Doc(cFilDoc,cDocto,cSerie,lZera)

Static cDoc := ''
Local lRet  := .T.
Default lZera := .F.

If lZera
	cDoc := ''
Else
	If cDoc == cFilDoc+cDocto+cSerie
		lRet := .F.
	EndIf
	cDoc := cFilDoc+cDocto+cSerie
EndIf

Return lRet