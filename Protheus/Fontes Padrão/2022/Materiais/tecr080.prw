#include "protheus.ch"
#include "tecr080.ch"
Static cAutoPerg := "ATR080"
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    � TECR080  � Autor � Totvs                 � Data � 14/04/2011  ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Contrato de Servicos                             ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � TECR080()                                                     ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function TECR080()
Private aPergs      := {}
Private cRetSX1		:= ""
Private titulo		:= STR0001 //"Relat�rio de Contrato de Servi�os"
Private nomeprog	:= FunName()
Private oReport

oReport := ReportDef()      

If Valtype( oReport ) == 'O'
	If !Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf	

	oReport:PrintDialog()      
EndIf

oReport := Nil

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Totvs                 � Data � 14/04/11 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao tem como objetivo definir as secoes, celulas,   ���
���          �totalizadores do relatorio que poderao ser configurados     ���
���          �pelo relatorio.                                             ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()  
Local aArea	   		:= GetArea()   
Local cReport		:= FunName()
Local cDesc			:= STR0002 //"Este programa ir� imprimir o relatorio de contrato de servi�os"
Local cPerg		   	:= "ATR080"			  
Local lRet		 	:= .T. 

IF TYPE("aPergs") == "U"
	aPergs      := {}
EndIf
IF TYPE("cRetSX1") == "U"
	cRetSX1		:= ""
EndIf
IF TYPE("titulo") == "U"
	titulo		:= STR0001 //"Relat�rio de Contrato de Servi�os"
EndIf
IF TYPE("nomeprog") == "U"
	nomeprog	:= FunName()
EndIf

oReport	:= TReport():New( cReport, TITULO, cPerg, { |oReport| ReportPrint( oReport ) }, cDesc ) 
oReport:SetTotalInLine( .F. )
oReport:EndPage( .T. )
oReport:SetPortrait( .T. )

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
oSection1  := TRSection():New( oReport, STR0003, {"AAM","AAN","AAO"},,.F.,.F.,,,,,,,,,,.F./*AutoAjuste*/,)   //"Contrato"
TRCell():New( oSection1, "AAM_CONTRT"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAM_CONTRT } )
TRCell():New( oSection1, "AAM_CODCLI"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAM_CODCLI } )
TRCell():New( oSection1, "AAM_LOJA"             ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAM_LOJA   } )
TRCell():New( oSection1, "A1_NOME"              ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || A1_NOME    } )
TRCell():New( oSection1, "AAM_TPCONT"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || IIf( AAM_TPCONT == "1", STR0004, STR0005 ) } )
TRCell():New( oSection1, "AAM_CLASSI"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || GetX5Desc( "A7", AAM_CLASSI ) } ) //SX5-A7
TRCell():New( oSection1, "AAM_ABRANG"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || IIf( AAM_ABRANG == "1", STR0006, STR0007 ) } )
TRCell():New( oSection1, "AAM_STATUS"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/ )
TRCell():New( oSection1, "AAM_INIVIG"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || StoD( AAM_INIVIG ) } )
TRCell():New( oSection1, "AAM_FIMVIG"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || StoD( AAM_FIMVIG ) } )

oSection2  := TRSection():New( oReport, STR0008, {"AAM","AAN","AAO"},,.F.,.F.,,,,,,,,,,.F./*AutoAjuste*/,)   //"Parcerias"
TRCell():New( oSection2, "AAN_ITEM"             ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAN->AAN_ITEM } )
TRCell():New( oSection2, "AAN_CODPRO"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAN->AAN_CODPRO } )
TRCell():New( oSection2, "B1_DESC"              ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || GetDProd( AAN->AAN_CODPRO ) } )
TRCell():New( oSection2, "AAN_QUANT"            ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAN->AAN_QUANT } )
TRCell():New( oSection2, "AAN_VLRUNI"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAN->AAN_VLRUNI } )
TRCell():New( oSection2, "AAN_VALOR"            ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAN->AAN_VALOR } )
TRCell():New( oSection2, "AAN_CONPAG"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAN->AAN_CONPAG } )
TRCell():New( oSection2, "AAN_ULTPED"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAN->AAN_ULTPED } )
TRCell():New( oSection2, "AAN_ULTEMI"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAN->AAN_ULTEMI } )

oSection3  := TRSection():New( oReport, "WMS", {"AAM","AAN","AAO"},,.F.,.F.,,,,,,,,,,.F./*AutoAjuste*/,)   //"WMS"
TRCell():New( oSection3, "AAO_ITEM"             ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAO->AAO_ITEM } )
TRCell():New( oSection3, "AAO_CODPRO"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAO->AAO_CODPRO } )
TRCell():New( oSection3, "B1_DESC"              ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || GetDProd( AAO->AAO_CODPRO ) } )
TRCell():New( oSection3, "AAO_TABELA"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || AAO->AAO_TABELA } )
TRCell():New( oSection3, "AAO_DESSER"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || GetX5Desc( "L4", AAO->AAO_SERVIC ) } ) //DC5-L4
TRCell():New( oSection3, "AAO_DESTAR"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || GetX5Desc( "L2", AAO->AAO_TAREFA ) } )	//DC6-L2
TRCell():New( oSection3, "AAO_DESATI"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || GetX5Desc( "L3", AAO->AAO_ATIVID ) } )	//SX5-L3

Return oReport

/*/
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
������������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Totvs                � Data � 14/04/11      ���
������������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o relatorio definido pelo usuario de acordo com as       ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.       ���
���          �Nesta funcao deve ser criada a query das secoes se SQL ou        ���
���          �definido o relacionamento e filtros das tabelas em CodeBase.     ���
������������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(oReport)                                            ���
������������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relat�rio                                       ���
�������������������������������������������������������������������������������ٱ�
����������������������������������������������������������������������������������
����������������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport )
Local cContrt		:= ""
Local cOldContrt	:= ""
Local cStatus		:= ""
Local oSection1 	:= oReport:Section( 1 )
Local oSection2 	:= oReport:Section( 2 )
Local oSection3 	:= oReport:Section( 3 )

cAliasQry := GetNextAlias()
If Select( cAliasQry ) > 0
	DbSelectArea( cAliasQry )
	dbCloseArea()        
EndIf

BeginSql Alias cAliasQry

	SELECT  A1_SATIV1, 
			A1_SATIV2,
			A1_SATIV3,
			A1_SATIV4,
			A1_SATIV5,
			A1_SATIV6,
			A1_SATIV7,
			A1_SATIV8,
			AAM_TPCONT,
			AAM_STATUS,
			AAM_CONTRT,
			AAM_CODCLI,
			AAM_LOJA,
			A1_NOME,
			AAM_CLASSI,
			AAM_ABRANG,
			AAM_INIVIG,
			AAM_FIMVIG
	FROM %table:AAM% AAM
	LEFT JOIN %table:SA1% SA1 ON A1_FILIAL  = %xfilial:SA1% AND A1_COD = AAM_CODCLI AND A1_LOJA  = AAM_LOJA AND SA1.%notDel% 
	WHERE 	AAM.%notDel% AND
			AAM.AAM_FILIAL = %xfilial:AAM% AND
			AAM.AAM_CODCLI >= %Exp:mv_par01% AND
			AAM.AAM_CODCLI <= %Exp:mv_par02%
	ORDER BY AAM_CONTRT, AAM_CODCLI, AAM_LOJA

EndSql  

DbGoTop()
DbSelectArea( cAliasQry )

oReport:SetMeter( RecCount() )

While (cAliasQry)->( !Eof() )
	If oReport:Cancel()
		Exit
	EndIf

	// Filtra os Segmentos do Cliente -- 1o..8o opcao de segmento
	If	!Empty( MV_PAR03 ) .AND. !( MV_PAR03 $ ( (cAliasQry)->A1_SATIV1 + (cAliasQry)->A1_SATIV2 + (cAliasQry)->A1_SATIV3 + (cAliasQry)->A1_SATIV4 + (cAliasQry)->A1_SATIV5 + (cAliasQry)->A1_SATIV6 + (cAliasQry)->A1_SATIV7 + (cAliasQry)->A1_SATIV8 ) )
		oReport:IncMeter()
		(cAliasQry)->( DbSkip() )
		Loop
	EndIf

	// Filtra o Tipo de Contrato
	If MV_PAR04 < 3 .AND. Val( (cAliasQry)->AAM_TPCONT ) <> MV_PAR04
		oReport:IncMeter()
		(cAliasQry)->( DbSkip() )
		Loop
	EndIf

	// Filtra o Status
	If MV_PAR05 < 4 .AND. Val( (cAliasQry)->AAM_STATUS ) <> MV_PAR05
		oReport:IncMeter()
		(cAliasQry)->( DbSkip() )
		Loop
	EndIf

	// Determina o status
	cStatus := ""
	If (cAliasQry)->AAM_STATUS == "1"
		cStatus	:= STR0009
	ElseIf (cAliasQry)->AAM_STATUS == "2"
		cStatus := STR0010
	ElseIf (cAliasQry)->AAM_STATUS == "3"
		cStatus := STR0011
	EndIf

	oSection1:Cell( "AAM_STATUS" ):SetBlock( { || cStatus } )

	// Inicia as sessoes e imprime os registros
	oSection1:Init()
	oSection2:Init()
	oSection3:Init()

	cContrt := (cAliasQry)->AAM_CONTRT
	If cContrt <> cOldContrt
		If !isBlind()
			oSection1:PrintLine()
		EndIf
		
		cOldContrt := cContrt
	EndIf

	// Imprime sessao 2
	DbSelectAre( "AAN" )
	AAN->( DbSetOrder( 1 ) )
	AAN->( DbSeek( xFilial( "AAN" ) + (cAliasQry)->AAM_CONTRT ) )
	While AAN->( !Eof() ) .AND. AAN->AAN_CONTRT == (cAliasQry)->AAM_CONTRT
		If !isBlind()
			oSection2:PrintLine()
		EndIf
		AAN->( DbSkip() )
	End

	// Imprime sessao 3
	DbSelectAre( "AAO" )
	AAO->( DbSetOrder( 1 ) )
	AAO->( DbSeek( xFilial( "AAO" ) + (cAliasQry)->AAM_CONTRT ) )
	While AAO->( !Eof() ) .AND. AAO->AAO_CONTRT == (cAliasQry)->AAM_CONTRT
		If !isBlind()
			oSection3:PrintLine()
		EndIf
		AAO->( DbSkip() )
	End

	// Restaura a area para impressao da sessao 1
	DbSelectArea( cAliasQry )

	oReport:IncMeter()
	(cAliasQry)->( DbSkip() )

	// Pula linha para proximo registro e atualiza a regua
	If (cAliasQry)->AAM_CONTRT <> cOldContrt
		oReport:SkipLine( 2 )

		oSection1:Finish()
		oSection2:Finish()
		oSection3:Finish()
	EndIf
End

Return

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    �GetX5Desc � Autor � Totvs                 � Data � 14/04/2011  ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Localiza na tabela SX5 o item desejado                        ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � GetX5Desc( cTabela, cCodigo )                                 ���
����������������������������������������������������������������������������Ĵ��
���Par�metros� ExpC1 -> tabela no SX5                                        ���
���          � ExpC2 -> codigo a ser pesquisado                              ���
����������������������������������������������������������������������������Ĵ��
���Retorna	 � ExpC1 -> descricao da tabela pesquisada                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function GetX5Desc( cTabela, cCodigo )
Local aArea	:= GetArea()
Local cRet	:= ""

DbSelectArea( "SX5" )
SX5->( DbSeek( xFilial( "SX5" ) + cTabela + cCodigo ) )
cRet := X5Descri()

RestArea( aArea )

Return cRet

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    � GetDProd � Autor � Totvs                 � Data � 14/04/2011  ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Localiza o produto e retorna sua descricao                    ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe	 � GetDProd( cCodigo )                                           ���
����������������������������������������������������������������������������Ĵ��
���Par�metros� ExpC1 -> codigo a ser pesquisado                              ���
����������������������������������������������������������������������������Ĵ��
���Retorna	 � ExpC1 -> descricao da tabela pesquisada                       ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Static Function GetDProd( cCodigo )
Local aArea	:= GetArea()
Local cRet	:= ""

DbSelectArea( "SB1" )
SB1->( DbSetOrder( 1 ) )
If SB1->( DbSeek( xFilial( "SB1" ) + cCodigo ) )
	cRet := SB1->B1_DESC
EndIf

RestArea( aArea )

Return cRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PrintReport
Chama a fun��o ReportPrint
Chamada utilizada na automa��o de c�digo.

@author Mateus Boiani
@since 31/10/2018
@return objeto Report
/*/
//-------------------------------------------------------------------------------------
Static Function PrintReport ( oReport )

Return ReportPrint( oReport )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetPergTRp
Retorna o nome do Pergunte utilizado no relat�rio
Fun��o utilizada na automa��o
@author Mateus Boiani
@since 31/10/2018
@return cAutoPerg, string, nome do pergunte
/*/
//-------------------------------------------------------------------------------------
Static Function GetPergTRp()

Return cAutoPerg
