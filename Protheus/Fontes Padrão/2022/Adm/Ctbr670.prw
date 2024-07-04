#Include "CTBR670.Ch"
#Include "PROTHEUS.Ch"

#define TAM_CEL	18

Static __cTrb
// 17/08/2009 -- Filial com mais de 2 caracteres

//-------------------------------------------------------------------
/*{Protheus.doc} CTBR670
Relacao de Lotes/Documentos nao Batidos

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Function CTBR670()

__cTrb := GetNextAlias()

CTBR670R4()

Return
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR670R4 � Autor� Gustavo Henrique		� Data � 05/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Relacao de Lotes/Documentos nao Batidos	- Release 4       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR670R4()												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB - CONR420 convertido para o SIGACTB.				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR670R4()

local aArea	:= GetArea()

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef()

If !Empty( oReport:uParam )
	Pergunte( oReport:uParam, .F. )
EndIf	

oReport:PrintDialog()

RestArea(aArea)

Return                                

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Gustavo Henrique      � Data �05/07/06  ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Esta funcao tem como objetivo definir as secoes, celulas,   ���
���          �totalizadores do relatorio que poderao ser configurados     ���
���          �pelo relatorio.                                             ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relat�rio                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�ExpC1: Alias da tabela de Planilha Orcamentaria (AK1)       ���
���          �ExpC2: Alias da tabela de Contas da Planilha (Ak3)          ���
���          �ExpC3: Alias da tabela de Revisoes da Planilha (AKE)        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function ReportDef()

Local lUseDocHis	:= X3USADO("CTC_DOCHIS")

Local oReport
Local oLote    
Local oDifLanc   

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

//"Este programa tem o objetivo de emitir a rela��o de "
//"documentos onde d�bito nao bate com o credito."
//"Relacao de Lancamentos com Diferenca"
oReport := TReport():New( "CTBR670", OemToAnsi(STR0005), "CTR670", { |oReport| ReportPrint(oReport) }, OemToAnsi(STR0001)+OemToAnsi(STR0002) )

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
oDoc  := TRSection():New( oReport, STR0020,{"CTC"},, .F., .F. )

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
TRCell():New( oDoc, "CTC_DATA"  , "CTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{ || (__cTrb)->CTC_DATA }/*CodeBlock*/)
TRCell():New( oDoc, "CTC_LOTE"  , "CTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{ || (__cTrb)->CTC_LOTE }/*CodeBlock*/)
TRCell():New( oDoc, "CTC_SBLOTE", "CTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{ || (__cTrb)->CTC_SBLOTE }/*CodeBlock*/)
TRCell():New( oDoc, "CTC_DOC"   , "CTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{ || (__cTrb)->CTC_DOC }/*CodeBlock*/)

If cPaisLoc == "ARG" .And. lUseDocHis
	TRCell():New( oDoc, "CTC_DOCHIS", "CTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| CTBR670HCL() }/*CodeBlock*/)
EndIf

oDoc:SetHeaderPage()

oLote := TRSection():New( oReport, STR0021,{"CTC"},, .F., .F. )

TRCell():New( oLote, "CTC_DATA"  , "CTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{ || (__cTrb)->CTC_DATA }/*CodeBlock*/)
TRCell():New( oLote, "CTC_LOTE"  , "CTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{ || (__cTrb)->CTC_LOTE }/*CodeBlock*/)
TRCell():New( oLote, "CTC_SBLOTE", "CTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{ || (__cTrb)->CTC_SBLOTE }/*CodeBlock*/)
If cPaisLoc == "ARG" .And. lUseDocHis
	TRCell():New( oLote, "CTC_DOCHIS", "CTC",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| CTBR670HCL(.T.) })
EndIf

oLote:SetHeaderPage()

oDifLanc := TRSection():New( oReport, STR0022, {"CT2"},, .F., .F. ) //"Lancamentos"

TRCell():New( oDifLanc, "CT2_DOC"   , "CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDifLanc, "CT2_LINHA" , "CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDifLanc, "CT2_DC"    , "CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDifLanc, "CT2_DEBITO", "CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDifLanc, "CT2_CREDIT", "CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDifLanc, "CT2_VALOR" , "CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oDifLanc, "CT2_HIST"  , "CT2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
oDifLanc:NoUserFilter({'CT2'})
oDifLanc:SetHeaderPage()

oTotais := TRSection():New( oReport, STR0023,,, .F., .F. ) //"Total"

TRCell():New( oTotais, "TOT_DEBITO" ,,OemToAnsi(STR0011),Tm(0,17),TAM_CEL/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//Total Debito
TRCell():New( oTotais, "TOT_CREDITO",,OemToAnsi(STR0010),Tm(0,17),TAM_CEL/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//Total Credito
TRCell():New( oTotais, "TOT_DIFER"  ,,OemToAnsi(STR0012),Tm(0,17),TAM_CEL/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"Diferenca:"
TRCell():New( oTotais, "TOT_INF"    ,,OemToAnsi(STR0016),Tm(0,17),TAM_CEL/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"Total Informado"
TRCell():New( oTotais, "TOT_DIG"    ,,OemToAnsi(STR0017),Tm(0,17),TAM_CEL/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"Total "
TRCell():New( oTotais, "TOT_DIFINF" ,,OemToAnsi(STR0018),Tm(0,17),TAM_CEL/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)	//"Diferenca:"
       
oTotais:Cell( "TOT_INF" ):Disable()
oTotais:Cell( "TOT_DIG" ):Disable()
oTotais:Cell( "TOT_DIFINF" ):Disable()

oTotGer := TRSection():New( oReport, STR0014,,, .F., .F. ) //"Total Geral"

// Total Debito ### Total Credito ### "Diferenca:"
TRCell():New( oTotGer, "TOTG_DEBITO",,OemToAnsi(STR0014) + CRLF + OemToAnsi(STR0011),Tm(0,17),TAM_CEL/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oTotGer, "TOTG_CREDIT",,Space(01) + CRLF + OemToAnsi(STR0010),Tm(0,17),TAM_CEL/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oTotGer, "TOTG_DIFER" ,,Space(01) + CRLF + OemToAnsi(STR0012),Tm(0,17),TAM_CEL/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)

oReport:SetPortrait()

Return(oReport)

//-------------------------------------------------------------------
/*{Protheus.doc} ReportPrint
Imprime o relatorio definido pelo usuario de acordo com as 
secoes/celulas criadas na funcao ReportDef definida acima.  

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function ReportPrint( oReport )

Local aArea 	:= GetArea()

Local oCabSec
Local oDoc		:= oReport:Section(1)
Local oLote		:= oReport:Section(2)
Local oDifLanc	:= oReport:Section(3)
Local oTotais   := oReport:Section(4)
Local oTotGer   := oReport:Section(5)
                      
Local dDataDif	:= CtoD( "  /  /  " )
Local cLoteDif	:= ""
Local cSubDif	:= ""
Local cKeyAtu	:= ""
Local dDataAnt	:= CtoD( "  /  /  " )
Local cLoteAnt	:= ""
Local cDataLote := ""

Local nInf		:= 0	// Valor informado no lote/documento
Local nDig		:= 0	// Valor (Soma) dos valores do lancamento.
Local nDeb 		:= 0
Local nCrd 		:= 0
Local nDif 		:= 0
Local nDifInf	:= 0
Local nTotCrdG	:= 0
Local nTotDebG	:= 0

Local bKeyCT2	:= { || }
Local bKeyAtu	:= { || }
Local bDataLote	:= { || }	// Controla a quebra de pagina quando bate documento (mv_par09 == 2)
Local lAllSL		:= If(Empty(mv_par08) .or. mv_par08=="*",.T.,.F.)
Local lDetail	:= If(mv_par12==1,.T.,.F.)

If lDetail
	oDoc:Cell("CTC_DOC"):HideHeader()
	oDoc:Cell("CTC_DOC"):Hide()
Else
	oDifLanc:Hide()
EndIf

If mv_par09 == 2	// Verifica documento             
	oLote:Hide()
	oCabSec := oDoc

	bKeyCT2	:= { || CT2->( DtoS(CT2_DATA) + CT2_LOTE + CT2_SBLOTE + CT2_DOC ) }
	bKeyAtu 	:= { || (__cTrb)->( DtoS(CTC_DATA) + CTC_LOTE + CTC_SBLOTE + CTC_DOC ) }
	bDataLote:= { || (__cTrb)->( DtoS(CTC_DATA) + CTC_LOTE ) }
Else
	oDoc:Hide()
	oCabSec := oLote

	bKeyCT2 	:= { || CT2->( DtoS(CT2_DATA) + CT2_LOTE + CT2_SBLOTE ) }
	bKeyAtu 	:= { || (__cTrb)->( DtoS(CTC_DATA) + CTC_LOTE + CTC_SBLOTE ) }
	bDataLote:= { || (__cTrb)->( DtoS(CTC_DATA) + CTC_LOTE ) }
EndIf

cFiltroMain	:=	oCabSec:GetSQLExp()

CTR670QRY(__cTrb,cFiltroMain)

//�������������������������������������������������������������������������������Ŀ
//� Filtra tabela de detalhe do lancamento                                        �
//���������������������������������������������������������������������������������
If !lAllSL
	oDifLanc:SetFilter( "CT2->( CT2_MOEDLC == '" +mv_par07+ "' .And. CT2_TPSALD == '" + mv_par08 + "' )" )
Else
	oDifLanc:SetFilter( "CT2->( CT2_MOEDLC == '" +mv_par07+ "' )" )
EndIf

//�������������������������������������������������������������������������������Ŀ
//� Define bloco de codigo com as variaveis para impressao das celulas de totais  �
//���������������������������������������������������������������������������������
oTotais:Cell( "TOT_DEBITO" ):SetBlock( { || nDeb } )
oTotais:Cell( "TOT_CREDITO"):SetBlock( { || nCrd } )
oTotais:Cell( "TOT_DIFER"  ):SetBlock( { || nDif } )

oTotais:Cell( "TOT_INF"    ):SetBlock( { || nInf    } )
oTotais:Cell( "TOT_DIG"    ):SetBlock( { || nDig    } )
oTotais:Cell( "TOT_DIFINF" ):SetBlock( { || nDifInf } )

//�������������������������������������������������������������������������������Ŀ
//� Inicia a impressao do relatorio                                               �
//���������������������������������������������������������������������������������
CT2->( dbSetOrder(1) )

oReport:SetMeter( 0 )

oCabSec:Init()
oReport:SkipLine()

Do While !oReport:Cancel() .And. (__cTrb)->( ! EoF() )
	
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf
	
	nInf := Round( (__cTrb)->CTC_INF, 2 )
	nDig := Round( (__cTrb)->CTC_DIG, 2 )
	
	// Se nao considera o valor informado, ou se considera o valor informado, mas nao tem
	// valor ou nao existe diferenca, desconsidera registro.
	If	Round( (__cTrb)->CTC_DEBITO - (__cTrb)->CTC_CREDIT ,2) == 0 .And. ( (mv_par11 == 2) .Or. (nInf == 0) .Or. (nInf == nDig) )
		(__cTrb)->(dbSkip())
		Loop	
	Else
		
		nDeb := 0
		nCrd := 0
		nDif := 0
		
		// So imprime se encontrar no CT2
		If CT2->( MsSeek( xFilial("CT2") + Eval( bKeyAtu ) ) )
			
			If mv_par10 == 1 												// Quebra pagina por lote
				If mv_par09 == 1                       						// Se Bate Lote
					If !Empty(cLoteAnt)
						oReport:EndPage()									// Quebra direto
						oReport:SkipLine()
					Else
						cLoteAnt := cLoteDif
					EndIf
				Else														// Se Bate Documento
					If cDataLote <> Eval( bDataLote )						// Se o Lote ou Data atual forem diferentes do anterior
						If !Empty(cDataLote)
							oReport:EndPage()								// Quebra direto
							oReport:SkipLine()
							cDataLote := Eval( bDataLote )
						Else
							cDataLote := Eval( bDataLote )
						EndIf
					EndIf
				EndIf
			EndIf
			
			oReport:ThinLine()
			oCabSec:PrintLine()
			
			If lDetail 
				oDifLanc:Init()
			Endif
			
			Do While !oReport:Cancel() .And. CT2->( ! EoF() ) .And. Eval( bKeyCT2 ) == Eval( bKeyAtu )
				
				If oReport:Cancel()
					Exit
				EndIf
				
				If lDetail
					oDifLanc:PrintLine()
				Endif
				
				If CT2->CT2_DC $ "23CX"
					nCrd += CT2->CT2_VALOR
				EndIf
				
				If CT2->CT2_DC $ "13DX"
					nDeb += CT2->CT2_VALOR
				EndIf
				
				CT2->( dbSkip() )
				
			EndDo
			
			If lDetail 
				oDifLanc:Finish()
			Endif
			
			oReport:ThinLine()
			
			nDif := Abs( nDeb - nCrd )
			
			If mv_par11 == 1 .And. nInf <> 0
				
				oTotais:Cell( "TOT_INF" ):Enable()
				oTotais:Cell( "TOT_DIG" ):Enable()
				oTotais:Cell( "TOT_DIFINF" ):Enable()
				
				nDifInf := Abs( nDig - nInf )
				
			Endif
			
			oTotais:Init()
			oTotais:PrintLine()
			oTotais:Finish()
			
			oTotais:Cell( "TOT_INF" ):Disable()
			oTotais:Cell( "TOT_DIG" ):Disable()
			oTotais:Cell( "TOT_DIFINF" ):Disable()
			
			oReport:SkipLine()
			oReport:SkipLine()
			
			nTotCrdG += nCrd
			nTotDebG += nDeb
			
		EndIf
		
	EndIf
	
	(__cTrb)->( dbSkip() )
	
EndDo

nDifTot := Abs(nTotDebG-nTotCrdG)

oReport:ThinLine()
oTotGer:Init()

oTotGer:Cell( "TOTG_DEBITO" ):SetBlock( { || nTotDebG } )
oTotGer:Cell( "TOTG_CREDIT" ):SetBlock( { || nTotCrdG } )
oTotGer:Cell( "TOTG_DIFER"  ):SetBlock( { || nDifTot  } )

oTotGer:PrintLine()
oTotGer:Finish()
oReport:ThinLine()

oCabSec:Finish()

RestArea( aArea )

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �CTBR080HCL�Autor  �Marcos R. Pires     � Data �  26/08/11   ���
�������������������������������������������������������������������������͹��
���Desc.     � Retorna o Historica da Capa de Lote                        ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function CTBR670HCL(lLote)
Local aSaveArea := GetArea()
Local aSaveCTC	:= CTC->(GetArea())
Local cRet		:= CriaVar("CTC_DOCHIS")

DEFAULT lLote := .F.

If lLote
	cRet := Posicione("CTC",1,xFilial("CTC")+DTOS((__cTrb)->CTC_DATA)+(__cTrb)->CTC_LOTE+(__cTrb)->CTC_SBLOTE,"CTC_DOCHIS")
Else
	cRet := Posicione("CTC",1,xFilial("CTC")+DTOS(CT2->CT2_DATA)+CT2->CT2_LOTE+CT2->CT2_SBLOTE+CT2->CT2_DOC,"CTC_DOCHIS")
EndIf

RestArea(aSaveCTC)
RestArea(aSaveArea)

Return(cRet)

//-------------------------------------------------------------------
/*{Protheus.doc} CTR670QRY
Realiza a query para montar o arquivo de trabalho
@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function CTR670QRY(cTRB,cFiltroMain)
Local cQuery := ""
Local lDocumento :=  .T.
Local lAllSL		:= .T.

Default cFiltroMain := ''

Pergunte("CTR670",.F.)

lDocumento :=  mv_par09 == 2
lAllSL		:= If(Empty(mv_par08) .or. mv_par08=="*",.T.,.F.)

cQuery += " SELECT " + CRLF

If lDocumento	// Verifica documento             	
	cQuery += " CTC_FILIAL,  " + CRLF
	cQuery += " CTC_LOTE, " + CRLF
	cQuery += " CTC_SBLOTE, " + CRLF
	cQuery += " CTC_DOC, " + CRLF
	cQuery += " CTC_DATA,  " + CRLF
	cQuery += " CTC_MOEDA,  " + CRLF
	cQuery += " CTC_TPSALD,  " + CRLF
	cQuery += " CTC_DEBITO,  " + CRLF
	cQuery += " CTC_CREDIT,  " + CRLF
	cQuery += " CTC_DIG,  " + CRLF
	cQuery += " CTC_INF " + CRLF
Else	 
	cQuery += " CTC_FILIAL,  " + CRLF
	cQuery += " CTC_LOTE, " + CRLF
	cQuery += " CTC_SBLOTE, " + CRLF
	cQuery += " CTC_DATA,  " + CRLF
	cQuery += " CTC_MOEDA,  " + CRLF
	cQuery += " CTC_TPSALD,  " + CRLF
	cQuery += " SUM(CTC_DEBITO) CTC_DEBITO,  " + CRLF
	cQuery += " SUM(CTC_CREDIT) CTC_CREDIT,  " + CRLF
	cQuery += " SUM(CTC_DIG) CTC_DIG,  " + CRLF
	cQuery += " SUM(CTC_INF) CTC_INF " + CRLF		
EndIf

cQuery += " FROM  " + CRLF	
cQuery += " " + RetSQLName("CTC") + "  " + CRLF	

cQuery += " WHERE " + CRLF
cQuery += " 	D_E_L_E_T_ = ''  " + CRLF
cQuery += " 	AND CTC_FILIAL = '"+xFilial("CTC")+"' " + CRLF
cQuery += " 	AND CTC_DATA >= '"+DTOS(mv_par01)+"' " + CRLF
cQuery += " 	AND CTC_DATA <= '"+DTOS(mv_par02)+"' " + CRLF
cQuery += " 	AND CTC_LOTE >= '"+mv_par03+"' " + CRLF
cQuery += " 	AND CTC_LOTE <= '"+mv_par04+"' " + CRLF
cQuery += " 	AND CTC_MOEDA = '"+mv_par07+"' " + CRLF
If !lAllSL
	cQuery += " AND CTC_TPSALD = '"+mv_par08+"'   " + CRLF 
EndIf
If lDocumento	
	cQuery += " 	AND CTC_DOC >= '"+mv_par05+"' " + CRLF
	cQuery += " 	AND CTC_DOC <= '"+mv_par06+"' " + CRLF
EndIf

If !Empty(cFiltroMain)
	cQuery	+=	" AND  " + cFiltroMain + " " + CRLF
Endif
                                                                                            
If lDocumento
	cQuery += " ORDER BY  " + CRLF
	cQuery += " CTC_FILIAL, " + CRLF
	cQuery += " CTC_DATA, " + CRLF
	cQuery += " CTC_LOTE, " + CRLF
	cQuery += " CTC_SBLOTE, " + CRLF	
	cQuery += " CTC_DOC, " + CRLF	
	cQuery += " CTC_MOEDA, " + CRLF	
	cQuery += " CTC_TPSALD " + CRLF
Else	
	cQuery += " GROUP BY " + CRLF
	cQuery += " CTC_FILIAL, " + CRLF
	cQuery += " CTC_DATA, " + CRLF
	cQuery += " CTC_LOTE, " + CRLF
	cQuery += " CTC_SBLOTE, " + CRLF	
	cQuery += " CTC_MOEDA, " + CRLF	
	cQuery += " CTC_TPSALD " + CRLF
	
	cQuery += " ORDER BY  " + CRLF
	cQuery += " CTC_FILIAL, " + CRLF
	cQuery += " CTC_DATA, " + CRLF
	cQuery += " CTC_LOTE, " + CRLF
	cQuery += " CTC_SBLOTE, " + CRLF	
	cQuery += " CTC_MOEDA, " + CRLF	
	cQuery += " CTC_TPSALD " + CRLF
EndIf

cQuery := ChangeQuery(cQuery)

If Select(cTRB) > 0
	dbSelectArea(cTRB)
	(cTRB)->(dbCloseArea())
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTRB,.T.,.F.)

aStru := CTC->(DbStruct())

aEval(aStru, { |e|	If(e[2] <> "C", TcSetField(cTRB,e[1],e[2],e[3],e[4]),) } )

Return