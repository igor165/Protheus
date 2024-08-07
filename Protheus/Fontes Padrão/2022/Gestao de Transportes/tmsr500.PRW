#INCLUDE "TMSR500.CH"
#INCLUDE "PROTHEUS.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � TMSR500  � Autor � Eduardo de Souza      � Data � 29/05/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Emissao da Relacao de Agrupamento de Clientes              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGATMS                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR500()

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
oReport:= TReport():New("TMSR500",STR0010,"TMR500", {|oReport| ReportPrint(oReport,cAliasQry)},STR0011) // "Emissao da Relacao de Agrupamento de Clientes" ### "Este programa ira imprimir a relacao de agrupamento de clientes."
oReport:SetTotalInLine(.F.)

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        	// CNPJ De ?   	                          �
//� mv_par02        	// CNPJ Ate ?         	                    �
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
Aadd( aOrdem, STR0012 ) // "Cliente Principal"

oAgrup:= TRSection():New(oReport,STR0013,{"DE4"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)
oAgrup:SetTotalInLine(.F.)
TRCell():New(oAgrup,"DE4_CNPJ" ,"DE4",STR0012   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oAgrup,"CLIENTE1" ,""   ,STR0016   ,/*Picture*/,TamSx3("A1_NOME")[1],/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oAgrup,"DE4_CNPJ1","DE4",STR0015   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oAgrup,"CLIENTE2" ,""   ,STR0016   ,/*Picture*/,TamSx3("A1_NOME")[1],/*lPixel*/,/*{|| code-block de impressao }*/)

oBreak := TRBreak():New(oAgrup,oAgrup:Cell("DE4_CNPJ"),STR0014,.F.) //-- "Total de Cliente do Grupo"
TRFunction():New(oAgrup:Cell("DE4_CNPJ"),/*cId*/,"COUNT",oBreak,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F./*lEndSection*/,.F./*lEndReport*/,.F./*lEndPage*/)

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

Local cCliIni := ''
Local cCliFim := ''

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr(oReport:uParam)

cCliIni := StrTran(mv_par01,".","")
cCliIni := StrTran(cCliIni,"/","")
cCliIni := StrTran(cCliIni,"-","")

cCliFim := StrTran(mv_par02,".","")
cCliFim := StrTran(cCliFim,"/","")
cCliFim := StrTran(cCliFim,"-","")

//-- Filtragem do relat�rio
//-- Query do relat�rio da secao 1
oReport:Section(1):BeginQuery()	

BeginSql Alias cAliasQry
	SELECT DE4_FILIAL, DE4_CNPJ, SA1A.A1_NOME CLIENTE1, DE4_CNPJ1, SA1B.A1_NOME CLIENTE2
		FROM %table:DE4% DE4
		LEFT JOIN %table:SA1% SA1A
		  ON SA1A.A1_FILIAL = %xFilial:SA1%
		  AND SA1A.A1_CGC = DE4_CNPJ
		  AND SA1A.%NotDel%
		LEFT JOIN %table:SA1% SA1B
		  ON SA1B.A1_FILIAL = %xFilial:SA1%
		  AND SA1B.A1_CGC = DE4_CNPJ1
		  AND SA1B.%NotDel%
		WHERE DE4_FILIAL = %xFilial:DE4%
			AND DE4_CNPJ BETWEEN %Exp:cCliIni% AND %Exp:cCliFim%
			AND DE4.%NotDel%
	ORDER BY DE4_FILIAL, DE4_CNPJ,DE4_CNPJ1
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
oReport:SetMeter(DE4->(LastRec()))

DbSelectArea(cAliasQry)
If !(cAliasQry)->(Eof())
	While !oReport:Cancel() .And. !(cAliasQry)->(Eof())
		cCnpj := (cAliasQry)->DE4_CNPJ
		oReport:Section(1):Init()
		oReport:Section(1):PrintLine()
		(cAliasQry)->(DbSkip())
		While !(cAliasQry)->(Eof()) .And. 	(cAliasQry)->DE4_CNPJ == cCnpj
			oReport:Section(1):Cell("DE4_CNPJ"):Hide()
			oReport:Section(1):Cell("CLIENTE1"):Hide()
			oReport:Section(1):PrintLine()
			(cAliasQry)->(DbSkip())
		EndDo
		oReport:Section(1):Cell("DE4_CNPJ"):Show()
		oReport:Section(1):Cell("CLIENTE1"):Show()
		oReport:Section(1):Finish()
	EndDo
EndIf

Return


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �TMSR500Vld� Autor �Valdemar Roberto       � Data �22.08.2005���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Valida Digitacao do CNPJ                                   ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � TMSR500Vld                                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � TMSR500                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TMSR500Vld(nAcao)
Local lRet    := .T.

Default nAcao := 1

If nAcao == 1
	mv_par01 := StrTran(mv_par01,".","")
	mv_par01 := StrTran(mv_par01,"/","")
	mv_par01 := StrTran(mv_par01,"-","")
	mv_par01 := PadL(AllTrim(mv_par01),14,"0")
Else
	mv_par02 := StrTran(mv_par02,".","")
	mv_par02 := StrTran(mv_par02,"/","")
	mv_par02 := StrTran(mv_par02,"-","")
	mv_par02 := PadL(AllTrim(mv_par02),14,"0")
EndIf

If nAcao == 1
	mv_par01 := TransForm(mv_par01,PesqPict('DE4','DE4_CNPJ'))
Else
	mv_par02 := TransForm(mv_par02,PesqPict('DE4','DE4_CNPJ'))
	If mv_par01 > mv_par02
		Help(' ',1,'TMSR50001' )  // CNPJ inicial maior que o final.
		lRet := .F.
	EndIf
EndIf

Return lRet
