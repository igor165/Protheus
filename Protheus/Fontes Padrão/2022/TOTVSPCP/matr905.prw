#INCLUDE "matr905.ch"
#Include "FIVEWIN.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MATR905   � Autor �Felipe Nunes Toledo    � Data � 30/06/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relacao das Ferramentas.                                    ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������           
*/
Function MATR905()
Local   oReport

If TRepInUse()
	//������������������������������������������������������������������������Ŀ
	//�Interface de impressao                                                  �
	//��������������������������������������������������������������������������
	oReport:= ReportDef()
	oReport:PrintDialog()
Else
	MATR905R3()
EndIf

Return NIL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor �Felipe Nunes Toledo    � Data �30/06/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportDef devera ser criada para todos os ���
���          �relatorios que poderao ser agendados pelo usuario.          ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �MATR905			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()
Local oReport
Local oSH4    // Secao 1
Local oSH9    // Secao 2
Local cTitle    := OemToAnsi(STR0001) //"Relacao de Ferramentas"
Local cAliasSH4 := GetNextAlias()

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
oReport:= TReport():New("MATR905",cTitle,"MTR905", {|oReport| ReportPrint(oReport,cAliasSH4)},OemToAnsi(STR0002)+" "+OemToAnsi(STR0003)) //##"Este programa ira imprimir a relacao do Cadastro"##"de Ferramentas."

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas (MTR905)                  �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        	// Da Ferramenta		                 �
//� mv_par02        	// Ate a Ferramenta  		             �
//� mv_par03        	// Lista Bloqueios ? 		             �
//����������������������������������������������������������������
Pergunte(oReport:GetParam(),.F.)

//������������������������������������������������������������������������Ŀ
//�Criacao das secoes utilizadas pelo relatorio                            �
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
//��������������������������������������������������������������������������

//�������������������������������������������������������������Ŀ
//� Secao 1 (oSH4)                                              �
//���������������������������������������������������������������
oSH4 := TRSection():New(oReport,STR0012,{"SH4"},/*Ordem*/) //"Ferramentas"
oSH4:SetHeaderPage()

TRCell():New(oSH4,'H4_CODIGO'	,'SH4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSH4,'H4_DESCRI' 	,'SH4',/*Titulo*/,/*Picture*/, 25        ,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSH4,'H4_VIDAUTI' 	,'SH4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSH4,'H4_TIPOVID' 	,'SH4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSH4,'H4_DTAQUIS' 	,'SH4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSH4,'H4_VIDAACU' 	,'SH4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSH4,'H4_QUANT' 	,'SH4',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSH4,'DtVenc'  	,'SH4', STR0011  ,PesqPict("SH4","H4_DTAQUIS"),/*Tamanho*/,/*lPixel*/, {|| CalcVenc(cAliasSH4) } )

//�������������������������������������������������������������Ŀ
//� Secao 2 (oSH9)                                              �
//���������������������������������������������������������������
oSH9 := TRSection():New(oSH4,STR0013,{"SH9"},/*Ordem*/) //"Bloqueios e exe��es de Calend�rio"
oSH9:SetHeaderPage()

TRCell():New(oSH9,'H9_QUANT'   	,'SH9',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSH9,'H9_MOTIVO'  	,'SH9',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSH9,'H9_DTINI' 	,'SH9',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSH9,'H9_HRINI'  	,'SH9',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSH9,'H9_DTFIM' 	,'SH9',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSH9,'H9_HRFIM' 	,'SH9',/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)

Return(oReport)

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint � Autor �Felipe Nunes Toledo  � Data �30/06/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �A funcao estatica ReportPrint devera ser criada para todos  ���
���          �os relatorios que poderao ser agendados pelo usuario.       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpO1: Objeto Report do Relatorio                           ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR905			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportPrint(oReport, cAliasSH4)
Local oSH4      := oReport:Section(1)
Local oSH9	    := oReport:Section(1):Section(1)
Local cFilter

dbSelectarea("SH4")
dbSetOrder(1)
//������������������������������������������������������������������������Ŀ
//�Filtragem do relatorio                                                  �
//��������������������������������������������������������������������������
MakeSqlExpr(oReport:GetParam())

//������������������������������������������������������������������������Ŀ
//�Query do relatorio                                                      �
//��������������������������������������������������������������������������

 	BEGIN REPORT QUERY oSH4
 	BeginSql Alias cAliasSH4

	SELECT SH4.*
       
	FROM %table:SH4% SH4

	WHERE H4_FILIAL  = %xFilial:SH4%   AND                                 
  		H4_CODIGO  	    >= %Exp:mv_par01%  AND 
  		H4_CODIGO      	<= %Exp:mv_par02%  AND 
	SH4.%NotDel%

ORDER BY %Order:SH4%		

EndSql 
END REPORT QUERY oSH4 



If mv_par03 == 1
	//�����������������������������Ŀ
	//�Posicionamento da tabela SH9 �
	//�������������������������������
	TRPosition():New(oSH4,"SH9",3,{|| xFilial("SH9")+"F"+(cAliasSH4)->H4_CODIGO })

	//��������������������������������������������������������Ŀ
	//�Define a formula de relacionamento da secao filha (oSH9)�
	//�com a secao pai (oSH4).                                 �
	//����������������������������������������������������������
	oSH9:SetRelation({|| xFilial("SH9")+"F"+(cAliasSH4)->H4_CODIGO },"SH9",3,.T.)

	//�������������������������������������������������Ŀ
	//�Define a regra de sa�da do loop de processamento �
	//���������������������������������������������������
	oSH9:SetParentFilter({|cParam| SH9->H9_FILIAL+SH9->H9_TIPO+SH9->H9_FERRAM == cParam},{|| xFilial("SH9")+"F"+(cAliasSH4)->H4_CODIGO })
Else

	//��������������������������������������������Ŀ
	//�Desabilita a Impressao da secao Filha (oSH9)�
	//����������������������������������������������
	oSH9:Disable()
EndIf

//�����������������������Ŀ
//�Impressao do Relatorio �
//�������������������������
oSH4:Print()

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Descri��o � PLANO DE MELHORIA CONTINUA                                 ���
�������������������������������������������������������������������������Ĵ��
���ITEM PMC  � Responsavel              � Data         |BOPS:		      ���
�������������������������������������������������������������������������Ĵ��
���      01  �                          �              |                  ���
���      02  �Erike Yuri da Silva       �17/01/2006    |00000091714       ���
���      03  �                          �              |                  ���
���      04  �                          �              |                  ���
���      05  �                          �              |                  ���
���      06  �                          �              |                  ���
���      07  �                          �              |                  ���
���      08  �                          �              |                  ���
���      09  �                          �              |                  ���
���      10  �Erike Yuri da Silva       �17/01/2006    |00000091714       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/	
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � MATR905  � Autor �Patricia A. Salomao    � Data �29.05.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Relacao das Ferramentas                                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATR905                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATR905R3()

LOCAL titulo  := STR0001 //"Relacao de Ferramentas"
LOCAL cString := "SH4"
LOCAL wnrel   := "MATR905"
LOCAL cDesc1  := STR0002 //"Este programa ira imprimir a relacao do Cadastro"
LOCAL cDesc2  := STR0003 //"de Ferramentas."
LOCAL cDesc3  := ""
LOCAL tamanho := "M"

PRIVATE aReturn  := {STR0004,1,STR0005,2, 2, 1, "",1 } //"Zebrado"###"Administracao"
PRIVATE cPerg    := "MTR905"
PRIVATE nLastKey := 0
//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
pergunte("MTR905",.F.)
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01        	// Da Ferramenta		                 �
//� mv_par02        	// Ate a Ferramenta  		             �
//� mv_par03        	// Lista Bloqueios ? 		             �
//����������������������������������������������������������������

wnrel:=SetPrint(cString,wnrel,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| R905Imp(@lEnd,wnRel,titulo,tamanho)},titulo)

Return NIL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R905Imp  � Autor �Patricia A. Salomao    � Data �29.05.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relat�rio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR905			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function R905Imp(lEnd,wnRel,titulo,tamanho)
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
LOCAL CbTxt, nTipo
LOCAL CbCont,cabec1,cabec2

//�������������������������������������������������������������������Ŀ
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
//���������������������������������������������������������������������
nTipo  := IIF(aReturn[04]==1,GetMv("MV_COMP"),GetMv("MV_NORM"))

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Impressao do Cabecalho e Rodape    �
//����������������������������������������������������������������
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80
m_pag    := 1

//��������������������������������������������������������������Ŀ
//� Monta os Cabecalhos                                          �
//����������������������������������������������������������������
cabec1 := STR0006 //"CODIGO  DESCRICAO DA FERRAMENTA        VIDA UTIL  TP.VIDA  DT. AQUISICAO  VIDA ACUMULATIVA       QUANTIDADE   VENCIMENTO"
cabec2 := If(mv_par03==1,STR0007," ") //"QUANTIDADE    MOTIVO                          DATA INICIO    HORA INICIO    DATA FIM     HORA FIM"
//         123456  123456789012345678901234567890     99999        X    1234567890             99999       99999999  1234567890
//         123456         123456789012345678901234567890  1234567890          99:99    1234567890       99:99
//         0         1         2         3         4         5         6         7         8         9        10        11        12
//		   0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456

dbSelectarea("SH4")
dbSetOrder(1)

cIndSH4:=CriaTrab(NIL,.F.)
cFilter:='H4_FILIAL=="'+xFilial("SH4")+'".And.H4_CODIGO>="'+mv_par01+'".And.'
cFilter+='H4_CODIGO<="'+mv_par02+'"'
IndRegua("SH4",cIndSH4,Indexkey(),,cFilter,STR0008) //"Criando Indice ...."

SetRegua(LastRec())

dbSeek(xFilial("SH4")+mv_par01,.T.)
Do While !Eof() .And. H4_FILIAL == xFilial("SH4") .And. H4_CODIGO <= mv_par02
	cCodigo := SH4->H4_CODIGO
	Do While !Eof() .And. cCodigo == SH4->H4_CODIGO
		If lEnd
			@PROW()+1,001 PSay STR0010 //"CANCELADO PELO OPERADOR"
			Exit
		EndIf
		IncRegua()
		If li > 58
			cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
		EndIf
		@ li, 000 PSay SH4->H4_CODIGO
		@ li, 008 PSay Substr(SH4->H4_DESCRI,1,25)
		@ li, 043 PSay SH4->H4_VIDAUTI
		@ li, 055 PSay SH4->H4_TIPOVID
		@ li, 061 PSay SH4->H4_DTAQUIS
		@ li, 084 PSay SH4->H4_VIDAACU Picture PesqPictQt("H4_QUANT",10)
		@ li, 100 PSay SH4->H4_QUANT   Picture PesqPictQt("H4_QUANT",10)
		@ li, 112 PSay CalcVenc()
		li+=1
		If mv_par03 == 1 //Lista Bloqueios das ferramentas
			dbSelectArea("SH9")
			dbSetOrder(3)
			dbSeek(xFilial("SH9")+"F"+cCodigo)
			lImpTit := .T.
			Do While !Eof() .And. xFilial("SH9")+cCodigo == H9_FILIAL+H9_FERRAM
				If lEnd
					@PROW()+1,001 PSay STR0010 //"CANCELADO PELO OPERADOR"
					Exit
				EndIf				
				If li > 58
					cabec(titulo,cabec1,cabec2,wnrel,Tamanho,nTipo)
				EndIf	
				If lImpTit			
					@ li,000 PSay STR0009 //"Bloqueios: "
					li+=1						
				EndIf	
				lImpTit := .F.
				@ li,000 PSay SH9->H9_QUANT Picture PesqPictQt("H9_QUANT",8)
				@ li,015 PSay SH9->H9_MOTIVO
				@ li,047 PSay SH9->H9_DTINI
				@ li,067 PSay SH9->H9_HRINI
				@ li,076 PSay SH9->H9_DTFIM
				@ li,093 PSay SH9->H9_HRFIM
				li+=1
				SH9->(dbSkip())
			EndDo
			@ li,000 PSay __PrtThinLine()
			li+=1
			dbSelectArea("SH4")
		EndIf
		SH4->(dbSkip())
	EndDo
EndDo

IF  Li != 80
	roda(cbcont,cbtxt,tamanho)
EndIF

dbSelectArea("SH4")
RetIndex("SH4")
Set Filter To
dbSetOrder(1)
Ferase(cIndSH4+OrdBagExt())

If aReturn[5] = 1
	Set Printer To
	dbCommitall()
	ourspool(wnrel)
Endif

MS_FLUSH()

Return NIL


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � CalcVenc � Autor �Patricia A. Salomao    � Data �29.05.2001���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula a Data de Vencimento da Ferramenta                 ���
�������������������������������������������������������������������������Ĵ��
���Parametro � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Data de Vencimento                                         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR905			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function CalcVenc(cAliasTop)

LOCAL dData
LOCAL cTempo
LOCAL cTipo
LOCAL dDataAqu
LOCAL dDias

Default cAliasTop := "SH4"

cTempo   := (cAliasTop)->H4_VIDAUTI
cTipo    := (cAliasTop)->H4_TIPOVID
dDataAqu := (cAliasTop)->H4_DTAQUIS
dDias    := cTempo	

//Transformar em Dias
If cTipo = "H"   // Hora
	dDias := cTempo/24
ElseIf cTipo = "M"  // Mes
	dDias := cTempo*30
ElseIf cTipo = "A"  //Ano
	dDias := cTempo*365
EndIf	
dData := dDataAqu+dDias

Return(dData)
