#include "protheus.ch"
#include "tecr090.ch"
Static cAutoPerg := "ATR090"
/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Fun��o    � TECR090  � Autor � Totvs                 � Data � 18/04/2011  ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Relatorio de Contrato de Manutencao                           ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � TECR090()                                                     ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
/*/
Function TECR090()
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
Local cPerg		   	:= "ATR090"			  
Local lRet		 	:= .T.  
Local cAliasQry := GetNextAlias()
If TYPE("TITULO") == "U"
	TITULO := STR0001
EndIf
oReport	:= TReport():New( cReport, TITULO, cPerg, { |oReport| ReportPrint( oReport , cAliasQry) }, cDesc ) 
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
oSection1  := TRSection():New( oReport, STR0003, {"AAH","SA1"},,.F.,.F.,,,,,,,,,,.F./*AutoAjuste*/,)   //"Contrato"
TRCell():New( oSection1, "AAH_CONTRT"           ,,,/*Picture*/,20, /*lPixel*/, /*CodeBlock*/{ || (cAliasQry)->AAH_CONTRT } )
TRCell():New( oSection1, "AAH_CODCLI"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || (cAliasQry)->AAH_CODCLI } )
TRCell():New( oSection1, "AAH_LOJA"             ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || (cAliasQry)->AAH_LOJA   } )
TRCell():New( oSection1, "A1_NOME"              ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || (cAliasQry)->A1_NOME    } )
TRCell():New( oSection1, "AAH_TPCONT"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || IIf( (cAliasQry)->AAH_TPCONT == "1", STR0004, STR0005 ) } )
TRCell():New( oSection1, "AAH_CONPAG"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || (cAliasQry)->AAH_CONPAG } )
TRCell():New( oSection1, "AAH_ABRANG"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || IIf( (cAliasQry)->AAH_ABRANG == "1", STR0006, STR0007 ) } )
TRCell():New( oSection1, "AAH_VALOR"            ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || (cAliasQry)->AAH_VALOR } )
TRCell():New( oSection1, "AAH_CODPRO"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || (cAliasQry)->AAH_CODPRO } )
TRCell():New( oSection1, "AAH_GRPATE"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || (cAliasQry)->AAH_GRPATE } )

oSection2  := TRSection():New( oReport, STR0008, {"AA3"},,.F.,.F.,,,,,,,,,,.F./*AutoAjuste*/,)
TRCell():New( oSection2, "AA3_CODPRO"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || (cAliasQry)->AA3_CODPRO } )
TRCell():New( oSection2, "B1_DESC"              ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || GetDProd( (cAliasQry)->AA3_CODPRO ) } )
TRCell():New( oSection2, "AA3_NUMSER"           ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || (cAliasQry)->AA3_NUMSER } )
TRCell():New( oSection2, "AA3_SITE"             ,,,/*Picture*/,, /*lPixel*/, /*CodeBlock*/{ || (cAliasQry)->AA3_SITE } )

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
Static Function ReportPrint( oReport, cAliasQry )

Local cContrt		:= ""
Local cOldContrt	:= ""
Local oSection1 	:= oReport:Section( 1 )
Local oSection2 	:= oReport:Section( 2 )
Local aAreaAAH	 	:= AAH->(GetArea())
Local aAreaAA3		:= AA3->(GetArea())
Local aAreaSA1      := SA1->(GetArea())

Default cAliasQry := GetNextAlias()

If Select( cAliasQry ) > 0
	DbSelectArea( cAliasQry )
	dbCloseArea()        
EndIf

BeginSql Alias cAliasQry

	SELECT
	SA1.A1_SATIV1 , SA1.A1_SATIV2, SA1.A1_SATIV3 , SA1.A1_SATIV4 , SA1.A1_SATIV5 , SA1.A1_SATIV6 , SA1.A1_SATIV7 , SA1.A1_SATIV8,
	AAH.AAH_TPCONT, AAH.AAH_CONTRT, AAH.AAH_CODCLI, AAH.AAH_LOJA, SA1.A1_NOME, AAH.AAH_CONPAG, AAH.AAH_ABRANG, AAH.AAH_VALOR, AAH.AAH_CODPRO, AAH.AAH_GRPATE, AA3.AA3_CODPRO, AA3.AA3_NUMSER, AA3.AA3_SITE, 
	AAH.R_E_C_N_O_ AS AAH_RECNO , AA3.R_E_C_N_O_ AS AA3_RECNO , SA1.R_E_C_N_O_ AS SA1_RECNO 
	FROM %table:AAH% AAH
	LEFT JOIN %table:AA3% AA3 ON AA3_FILIAL = %xfilial:AA3% AND AA3_CONTRT = AAH_CONTRT AND AA3.%notDel%
	LEFT JOIN %table:SA1% SA1 ON A1_FILIAL  = %xfilial:SA1% AND A1_COD     = AAH_CODCLI AND A1_LOJA    = AAH_LOJA AND SA1.%notDel% 
	WHERE 	AAH.%notDel% AND
			AAH.AAH_FILIAL = %xfilial:AAH% AND
			AAH.AAH_CODCLI >= %Exp:mv_par01% AND
			AAH.AAH_CODCLI <= %Exp:mv_par02%
	ORDER BY AAH_CONTRT, AAH_CODCLI, AAH_LOJA
	
EndSql  

DbGoTop()
DbSelectArea( cAliasQry )

oReport:SetMeter( RecCount() )

While (cAliasQry)->( !Eof() )
	If oReport:Cancel()
		Exit
	EndIf

	// Filtra os Segmentos do Cliente -- 1o..8o opcao de segmento
	If	!Empty( MV_PAR03 ) .AND. !( MV_PAR03 $ (cAliasQry)->( A1_SATIV1 + A1_SATIV2 + A1_SATIV3 + A1_SATIV4 + A1_SATIV5 + A1_SATIV6 + A1_SATIV7 + A1_SATIV8 ) )
		oReport:IncMeter()
		(cAliasQry)->( DbSkip() )
		Loop
	EndIf

	// Filtra o Tipo de Contrato
	If MV_PAR04 < 3 .AND. Val( (cAliasQry)->AAH_TPCONT ) <> MV_PAR04
		oReport:IncMeter()
		(cAliasQry)->( DbSkip() )
		Loop
	EndIf

	// Inicia as sessoes e imprime os registros
	oSection1:Init()
	oSection2:Init()
	
	cContrt := (cAliasQry)->AAH_CONTRT
	If cContrt <> cOldContrt
		If !isBlind()
			AAH->(DbGoto((cAliasQry)->AAH_RECNO))
			SA1->(DbGoto((cAliasQry)->SA1_RECNO))
			oSection1:PrintLine()
		EndIf
		cOldContrt := cContrt
	EndIf
	If !isBlind()
		AA3->(DbGoto((cAliasQry)->AA3_RECNO))
		oSection2:PrintLine()
	EndIf
	oReport:IncMeter()
	(cAliasQry)->( DbSkip() )

	// Pula linha para proximo registro e atualiza a regua
	If (cAliasQry)->AAH_CONTRT <> cOldContrt
		oReport:SkipLine( 2 )

		oSection1:Finish()
		oSection2:Finish()
	EndIf
End

RestArea(aAreaAAH)
RestArea(aAreaAA3)
RestArea(aAreaSA1)

Return

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