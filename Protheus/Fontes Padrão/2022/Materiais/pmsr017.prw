#INCLUDE "PMSR017.ch"
#DEFINE CHRCOMP If(aReturn[4]==1,15,18)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �PMSR017   �Autor  � Totvs              � Data �  16/03/2011 ���
�������������������������������������������������������������������������͹��
���Desc.     �Demonstrativo de Rejeicoes                                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PMSR017(cAlias,nReg,nOpcx)
Private lAE2_Produt
Private nQtdRec		:= 0
Private nQtdTpTrf	:= 0
Private nQtdPrj		:= 0
Private cItem
Private cRetSX1		// Nao remover, utilizado pelo F3 AN4SL

//�����������������������������������������������������������������Ŀ
//� Funcao utilizada para verificar a ultima versao dos fontes      �
//� SIGACUS.PRW,R3 SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        �
//�������������������������������������������������������������������
If  !PMSBLKINT()//nao permitir manipulacao pelo Sigapms quando pms integrado
           
	PMSR017R4(cAlias,nReg,nOpcx)
	
Endif
Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �PMSR017R4 � Autor � Totvs                 � Data � 16/03/11 ���
�������������������������������������������������������������������������Ĵ��
���Desc.     �Demonstrativo de Rejeicoes                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function PMSR017R4(cAlias,nReg,nOpcx)
Local oReport

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef()
If !Empty( oReport:uParam )
	Pergunte( oReport:uParam, .F. )
EndIf	

oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Totvs                 � Data �17/03/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport
Local oProjeto
Local oTpTrf
Local oRecurso
Local oTarefas
Local oTotalRec
Local cAlias 	:= GetNextAlias()
Local cObfNRecur := IIF(FATPDIsObfuscate("AE8_DESCRI",,.T.),FATPDObfuscate("RESOURCE NAME","AE8_DESCRI",,.T.),"")        

Private nCustD 	:= 0

//������������������������������������������������������������������������Ŀ
//�Criacao do componente de impressao                                      �
//�                                                                        �
//�TReport():New                                                           �
//�ExpC1 : Nome do relatorio                                               �
//�ExpC2 : Titulo                                                          �
//�ExpC3 : Pergunte                                                        �
//�ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  �
//�ExpC5 : Descricao                                                       �
//��������������������������������������������������������������������������
oReport := TReport():New( 	"PMSR017", STR0001, "PMR017", ;
							{|oReport| ReportPrint( oReport, @cAlias ) },;
							STR0002 + STR0003 )

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
//oProjeto := TRSection():New( oReport, STR0001, { cAlias }, {}, .F., .F. )

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

oProjeto := TRSection():New( oReport, STR0004, { cAlias }, {}, .F., .F. ) //"Projeto"
TRCell():New( oProjeto, "AF8_PROJET", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->PROJET } )
TRCell():New( oProjeto, "AF8_DESC", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->DESCRI } )

oTpTrf := TRSection():New( oReport, STR0005, { cAlias }, /*aOrdem*/, .F., .F. ) //"Tipo de Tarefa"
TRCell():New( oTpTrf, "AN4_TIPO"	, cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->TPTRF } )
TRCell():New( oTpTrf, "AN4_DESCRI", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->DESCTPTRF } )

oRecurso := TRSection():New( oReport, STR0006, { cAlias }, 	/*aOrdem*/, .F., .F. ) //"Recurso"
TRCell():New( oRecurso	, "AE8_RECURS",	cAlias, /*Titulo*/,	/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->EXECU } )
TRCell():New( oRecurso	, "AE8_DESCRI",	cAlias, /*Titulo*/,	/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| IIF(Empty(cObfNRecur),(cAlias)->DESCREC,cObfNRecur) } )   

oTarefas := TRSection():New( oReport, STR0008, { cAlias }, 	/*aOrdem*/, .F., .F. ) //"Recurso"
TRCell():New( oTarefas, "ANA_CODIGO"	, cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->TPERR } )
TRCell():New( oTarefas, "ANA_DESCRI", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->DESCERR } )
TRCell():New( oTarefas, "AF9_EDTPAI", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->EDTPAI } )
TRCell():New( oTarefas, "AF9_TAREFA", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->TAREFA } )
TRCell():New( oTarefas, "AF9_DESCRI", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->DESCTRF } )
TRCell():New( oTarefas, "ANB_REJEIT", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->REJEIT } )
TRCell():New( oTarefas, "ANB_EXEC", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->EXECU } )
TRCell():New( oTarefas, "ANB_DATA", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| StoD( (cAlias)->DATAR ) } )
TRCell():New( oTarefas, "ANB_CICLO", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->CICLO } )
TRCell():New( oTarefas, "ANB_ETPREJ", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->ETPREJ } )
TRCell():New( oTarefas, "ANB_ETPEXE", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->ETPEXE } )
TRCell():New( oTarefas, "ANB_QUANT", cAlias, /*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| (cAlias)->QUANT } )

oTotalRec := TRSection():New( oReport, STR0009, {}, /*aOrdem*/, .F., .F. ) //"Recurso"
TRCell():New( oTotalRec, "ANB_QUANT",, STR0009/*Titulo*/, PesqPict( "ANB", "ANB_QUANT" )/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| nQtdRec } )

oTotalTpTrf := TRSection():New( oReport, STR0010, {}, /*aOrdem*/, .F., .F. ) //"Recurso"
TRCell():New( oTotalTpTrf, "ANB_QUANT",, STR0010/*Titulo*/, PesqPict( "ANB", "ANB_QUANT" )/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| nQtdTpTrf } )

oTotalPrj := TRSection():New( oReport, STR0011, {}, /*aOrdem*/, .F., .F. ) //"Recurso"
TRCell():New( oTotalPrj,"ANB_QUANT",, STR0011/*Titulo*/, PesqPict( "ANB", "ANB_QUANT" )/*Picture*/,/*Tamanho*/,/*lPixel*/, {|| nQtdPrj } )

oTpTrf:SetLinesBefore(0)
oRecurso:SetLinesBefore(0)
oProjeto:SetLinesBefore(0)

Return(oReport)


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Totvs                � Data �17/03/2011���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
���          �que faz a chamada desta funcao ReportPrint()                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �ExpO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �ExpC1: Alias da tabela de composicoes (AJT)                 ���
���          �ExpC2: Alias da tabela de projetos (AF8)                    ���
���          �ExpC3: Alias da tabela de tarefas (AF9)                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport, cAlias )
Local cRecurso		:= ""
Local cOldRec		:= ""
Local cTrf			:= ""
Local cOldTrf		:= ""
Local cPrj			:= ""
Local cOldPrj		:= ""
Local oProjeto		:= oReport:Section(1)
Local oTpTrf		:= oReport:Section(2)
Local oRecurso		:= oReport:Section(3)
Local oTarefas		:= oReport:Section(4)
Local oTotalRec		:= oReport:Section(5)
Local oTotalTpTrf	:= oReport:Section(6)
Local oTotalPrj		:= oReport:Section(7)

//������������������������������������������������������������������������Ŀ
//�Transforma parametros Range em expressao SQL                            �
//��������������������������������������������������������������������������
//MakeSqlExpr(oReport:uParam/*Nome da Pergunte*/)

//������������������������������������������������������������������������Ŀ
//�Query do relat�rio da secao 1                                           �
//��������������������������������������������������������������������������
oProjeto:BeginQuery()	

cAlias := GetNextAlias()

	BeginSql Alias cAlias
		SELECT	ANB_FILIAL AS FILIAL,
				ANB_PROJET AS PROJET,
				ANB_REVISA AS REVISA,
				AF8_DESCRI AS DESCRI,
				AF9_DESCRI AS DESCTRF,
				AF9_TIPPAR AS TPTRF,
				AF9_EDTPAI AS EDTPAI,
				AN4_DESCRI AS DESCTPTRF,
				AE8_DESCRI AS DESCREC,
				ANB_TIPERR AS TPERR,
				ANA_DESCRI AS DESCERR,
				ANB_TAREFA AS TAREFA,
				ANB_REJEIT AS REJEIT,
				ANB_EXEC AS EXECU,
				ANB_DATA AS DATAR,
				ANB_CICLO AS CICLO,
				ANB_ETPREJ AS ETPREJ,
				ANB_ETPEXE AS ETPEXE,
				ANB_QUANT AS QUANT
		FROM %table:ANB% ANB
		LEFT JOIN %table:AF8% AF8 ON AF8_FILIAL = ANB_FILIAL AND AF8_PROJET = ANB_PROJET AND AF8.%NotDel%
		LEFT JOIN %table:AF9% AF9 ON AF9_FILIAL = ANB_FILIAL AND AF9_PROJET = ANB_PROJET AND AF9_REVISA = ANB_REVISA AND AF9_TAREFA = ANB_TAREFA AND AF9.%NotDel%
		LEFT JOIN %table:AN4% AN4 ON AN4_FILIAL = ANB_FILIAL AND AN4_TIPO = AF9_TIPPAR AND AN4.%NotDel%
		LEFT JOIN %table:ANA% ANA ON ANA_FILIAL = ANB_FILIAL AND ANA_CODIGO = ANB_TIPERR AND ANA.%NotDel%
		LEFT JOIN %table:AE8% AE8 ON AE8_FILIAL = ANB_FILIAL AND AE8_RECURS = ANB_EXEC AND AE8.%NotDel% AND AE8.AE8_EQUIP >= %Exp:mv_par03% AND AE8.AE8_EQUIP <= %Exp:mv_par04%
		WHERE 	ANB.ANB_FILIAL = %xFilial:ANB% AND 
				ANB.ANB_REJEIT >= %Exp:mv_par01% AND 
				ANB.ANB_REJEIT <= %Exp:mv_par02% AND 
				ANB.ANB_PROJET >= %Exp:mv_par05% AND 
				ANB.ANB_PROJET <= %Exp:mv_par06% AND 
				ANB.ANB_DATA >= %Exp:mv_par08% AND 
				ANB.ANB_DATA <= %Exp:mv_par09% AND 
				ANB.%NotDel%
		UNION
		SELECT	ANC_FILIAL AS FILIAL,
				ANC_PROJET AS PROJET,
				ANC_REVISA AS REVISA,
				AF8_DESCRI AS DESCRI,
				AF9_DESCRI AS DESCTRF,
				AF9_TIPPAR AS TPTRF,
				AF9_EDTPAI AS EDTPAI,
				AN4_DESCRI AS DESCTPTRF,
				AE8_DESCRI AS DESCREC,
				ANC_TIPERR AS TPERR,
				ANA_DESCRI AS DESCERR,
				ANC_TAREFA AS TAREFA,
				ANC_REJEIT AS REJEIT,
				ANC_EXEC AS EXECU,
				ANC_DATA AS DATAR,
				ANC_CICLO AS CICLO,
				ANC_ETPREJ AS ETPREJ,
				ANC_ETPEXE AS ETPEXE,
				ANC_QUANT AS QUANT
		FROM %table:ANC% ANC
		LEFT JOIN %table:AF8% AF8 ON AF8_FILIAL = ANC_FILIAL AND AF8_PROJET = ANC_PROJET AND AF8.%NotDel%
		LEFT JOIN %table:AF9% AF9 ON AF9_FILIAL = ANC_FILIAL AND AF9_PROJET = ANC_PROJET AND AF9_REVISA = ANC_REVISA AND AF9_TAREFA = ANC_TAREFA AND AF9.%NotDel%
		LEFT JOIN %table:AN4% AN4 ON AN4_FILIAL = ANC_FILIAL AND AN4_TIPO = AF9_TIPPAR AND AN4.%NotDel%
		LEFT JOIN %table:ANA% ANA ON ANA_FILIAL = ANC_FILIAL AND ANA_CODIGO = ANC_TIPERR AND ANA.%NotDel%
		LEFT JOIN %table:AE8% AE8 ON AE8_FILIAL = ANC_FILIAL AND AE8_RECURS = ANC_EXEC AND AE8.%NotDel% AND AE8.AE8_EQUIP >= %Exp:mv_par03% AND AE8.AE8_EQUIP <= %Exp:mv_par04%
		WHERE 	ANC.ANC_FILIAL = %xFilial:ANC% AND 
				ANC.ANC_REJEIT >= %Exp:mv_par01% AND 
				ANC.ANC_REJEIT <= %Exp:mv_par02% AND 
				ANC.ANC_PROJET >= %Exp:mv_par05% AND 
				ANC.ANC_PROJET <= %Exp:mv_par06% AND 
				ANC.ANC_DATA >= %Exp:mv_par08% AND 
				ANC.ANC_DATA <= %Exp:mv_par09% AND 
				ANC.%NotDel%
		ORDER BY FILIAL, EXECU, TPERR, PROJET, REVISA, TAREFA, DATAR
	EndSql 	

//������������������������������������������������������������������������Ŀ
//�Metodo EndQuery ( Classe TRSection )                                    �
//�                                                                        �
//�Prepara o relat�rio para executar o Embedded SQL.                       �
//�                                                                        �
//�ExpA1 : Array com os parametros do tipo Range                           �
//�                                                                        �
//��������������������������������������������������������������������������
oProjeto:EndQuery(/*ExpA1*/)

oReport:SetMeter( (cAlias)->( LastRec() ) )
	
DbSelectArea( cAlias )
While (cAlias)->( !Eof() ) .And. !oReport:Cancel()	
	// Filtra os tipos de tarefa
	If !Empty( MV_PAR07 ) .AND. !( (cAlias)->TPTRF $ MV_PAR07 )
		(cAlias)->( DbSkip() )
		Loop
	EndIf

	//�����������������������������������������������Ŀ
	//�inicializa as secoes e a impressao do relatorio�
	//�������������������������������������������������
	oProjeto:Init()
	oTpTrf:Init()
	oRecurso:Init()
	oTarefas:Init()

	If cOldPrj <> (cAlias)->PROJET
		oProjeto:PrintLine()
	EndIf

	If cOldTrf <> (cAlias)->TPTRF
		oTpTrf:PrintLine()
	EndIf

	If cOldRec <> (cAlias)->EXECU
		oRecurso:PrintLine()
	EndIf

	oTarefas:PrintLine()

	//�����������������������������������������������Ŀ
	//�armazena em variaveis para realizar a quebra   �
	//�������������������������������������������������
	cPrj := (cAlias)->PROJET
	If cOldPrj <> cPrj
		cOldPrj := cPrj
		oProjeto:Finish()
	EndIf

	cTrf := (cAlias)->TPTRF
	If cOldTrf <> cTrf
		cOldTrf := cTrf
		oTpTrf:Finish()
	EndIf

	cRecurso := (cAlias)->EXECU
	If cOldRec <> cRecurso
		cOldRec := cRecurso
		oRecurso:Finish()
	EndIf

	// Atualiza as quantidades
	nQtdRec		+= (cAlias)->QUANT
	nQtdTpTrf	+= (cAlias)->QUANT
	nQtdPrj		+= (cAlias)->QUANT

	(cAlias)->( DbSkip() )
	oReport:IncMeter()

	//��������������������Ŀ
	//� realizar a quebra  �
	//����������������������
	If cOldRec <> (cAlias)->EXECU .OR. (cAlias)->( Eof() )
		oTarefas:Finish()
		oTarefas:Init()

		If nQtdRec > 0
			oTotalRec:Init()
			oTotalRec:PrintLine()
			oTotalRec:Finish()
		EndIf

		nQtdRec		:= 0

		oReport:SkipLine()
	EndIf

	If cTrf <> (cAlias)->TPTRF .OR. (cAlias)->( Eof() )
		oTpTrf:Finish()
		oTpTrf:Init()

		If nQtdTpTrf > 0
			oTotalTpTrf:Init()
			oTotalTpTrf:PrintLine()
			oTotalTpTrf:Finish()
		EndIf

		nQtdTpTrf	:= 0

		oReport:SkipLine()
	EndIf

	If cOldPrj <> (cAlias)->PROJET .OR. (cAlias)->( Eof() )
		oTarefas:Finish()
		oTarefas:Init()

		oTpTrf:Finish()
		oTpTrf:Init()

		oRecurso:Finish()
		oRecurso:Init()

		oProjeto:Finish()
		oProjeto:Init()

		// Apresenta o totalizador para o recurso
		If nQtdRec > 0
			oTotalRec:Init()
			oTotalRec:PrintLine()
			oTotalRec:Finish()
		EndIf

		nQtdRec		:= 0

		// Apresenta o totalizador para o tipo de tarefa
		If nQtdTpTrf > 0
			oTotalTpTrf:Init()
			oTotalTpTrf:PrintLine()
			oTotalTpTrf:Finish()
		EndIf

		nQtdTpTrf	:= 0

		// Apresenta o totalizador para o projeto
		If nQtdPrj > 0
			oTotalPrj:Init()
			oTotalPrj:PrintLine()
			oTotalPrj:Finish()
		EndIf

		nQtdPrj		:= 0

		oReport:SkipLine()
		oReport:SkipLine()
	EndIf
End

If oReport:Cancel()
	oReport:Say( oReport:Row()+1 ,10, STR0007 )
EndIf

Return

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta fun��o deve utilizada somente ap�s 
    a inicializa��o das variaveis atravez da fun��o FATPDLoad.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, L�gico, Retorna se o campo ser� ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate


//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa fun��o quando n�o houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   



//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Fun��o que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
