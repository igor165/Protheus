#INCLUDE "CTBR030.CH"
#INCLUDE "PROTHEUS.CH"


// 17/08/2009 -- Filial com mais de 2 caracteres

// TRADUCAO DE CH'S PARA PORTUGAL

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Ctbr030  � Autor � Pilar S Albaladejo    � Data � 10/01/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Impressao do Cadastro de Itens Contabeis		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctbr030()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctbr030()

Local oReport

PRIVATE titulo		:= ""
Private nomeprog	:= "CTBR030"

oReport	:= ReportDef()
oReport:PrintDialog()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � ReportDef  												  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Static Function ReportDef()

Local oReport
Local oSecaoCTD
Local cReport		:=	"CTBR030"						// Nome do Relatorio

Local cPerg  		:=	"CTR030"						// Perguntas
LOCAL cString	:="CTD"
Local cSayItem	:= CtbSayApro("CTD")
LOCAL aOrd	 	:= {	cSayItem,;				// "Itens Contabeis"
						OemToAnsi(STR0004)}  // "Descricao"
LOCAL cDesc 	:= OemToAnsi(STR0001) + ;	// "Este programa ira imprimir o Cadastro de "
						CtbSayApro("CTD") + CRLF +;
						OemToAnsi(STR0002)+ CRLF +; 	// "Sera impresso de acordo com os parametros solicitados pelo"
						OemToAnsi(STR0003)  	// "usuario."
Local aTamItem		:= TAMSX3("CTD_ITEM")  

*��������������������������������������������������Ŀ
*�add por Icaro Queiroz em 24 de Agosto de 2010     �
*�Variaveis para tratamento de tipificacao - CTBR015�
*����������������������������������������������������
Local bTitulo		:= { |cCampo| SX3->( dbSetOrder(2) ), SX3->( MsSeek( cCampo ) ), X3Titulo() }
Local cTitCpo

titulo		:= OemToAnsi(STR0007) +;		//"Listagem do Cadastro de "
						cSayItem



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
oReport	:= TReport():New( cReport,@Titulo,cPerg, { |oReport| CT030ImpR4( oReport,oSecaoCTD ) }, cDesc )

oReport:SetCustomText( {|| CtCGCCabTR(,,,,,dDatabase,Titulo,,,,,oReport) } )

//�������������������������������������������������������������������������������������������Ŀ
//� Define tantas secoes quantas Moedas existirem na base, pois somente assim podera imprimir �
//� a descricao da moeda que o usuario selecionou atraves do parametro mv_par04               �
//���������������������������������������������������������������������������������������������
CTO->(DbSetOrder(1))
CTO->( MsSeek( xFilial("CTO"),.T. ) )
oSecaoCTD := TRSection():New( oReport, cSayItem, {"CTD"}, aOrd )	

TRCell():New( oSecaoCTD, "CTD_ITEM"		,"CTD",Upper(cSayItem)												,/*Picture*/,aTamItem[1]+aTamItem[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "C CUSTO"
TRCell():New( oSecaoCTD, "DESCRI"		,"CTD",STR0008															,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| If(CTD->( FieldPos("CTD_DESC"+mv_par04) )>0,CTD->( FieldGet(FieldPos("CTD_DESC"+mv_par04)) ),CTD->CTD_DESC01) } )	// "D E N O M I N A C A O                             "
TRCell():New( oSecaoCTD, "CTD_ITSUP"	,"CTD",Upper(cSayItem)+" "+AllTrim(Left(STR0009,10))	,/*Picture*/,aTamItem[1]+aTamItem[1]/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "C CUSTO SUPERIOR"
TRCell():New( oSecaoCTD, "CTD_BLOQ"		,"CTD",AllTrim(Right(STR0009,5))									,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "BLOQ"

*���������������������������������������������������������������Ŀ
*�Add por Icaro Queiroz em 24 de Agosto de 2010                  �
*�Caso seja chamado do CTBR015, imprime as calunas de tipificacao�
*�����������������������������������������������������������������
If Upper( FunName() ) == 'CTBR015'
	If MV_TPO01 > 0
		cTitCpo := Eval( bTitulo, ( "CTD_TPO" + StrZero( MV_TPO01, 2 ) ) )
		TRCell():New( oSecaoCTD, "CTD_TPO01"		,"CTD" , cTitCpo,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || &( "CTD->CTD_TPO" + StrZero( MV_TPO01, 2 ) ) } )
	EndIf

	If MV_TPO02 > 0
		cTitCpo := Eval( bTitulo, ( "CTD_TPO" + StrZero( MV_TPO02, 2 ) ) )
		TRCell():New( oSecaoCTD, "CTD_TPO02"		,"CTD" , cTitCpo,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || &( "CTD->CTD_TPO" + StrZero( MV_TPO02, 2 ) ) } )
	EndIf

	If MV_TPO03 > 0
		cTitCpo := Eval( bTitulo, ( "CTD_TPO" + StrZero( MV_TPO03, 2 ) ) )
		TRCell():New( oSecaoCTD, "CTD_TPO03"		,"CTD" , cTitCpo,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || &( "CTD->CTD_TPO" + StrZero( MV_TPO03, 2 ) ) } )
	EndIf

	If MV_TPO04 > 0
		cTitCpo := Eval( bTitulo, ( "CTD_TPO" + StrZero( MV_TPO04, 2 ) ) )
		TRCell():New( oSecaoCTD, "CTD_TPO04"		,"CTD" , cTitCpo,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || &( "CTD->CTD_TPO" + StrZero( MV_TPO04, 2 ) ) } )
	EndIf
EndIf

Return oReport
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Ct030ImpR4� Autor � Pilar S Albaladejo   � Data � 10/01/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Impressao do Cadastro de Itens Contabeis  	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctbr030(lEnd,wnRel,cString)                                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � CTBR030                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� lEnd    - A��o do Codeblock                                ���
���          � wnRel   - T�tulo do relat�rio                              ���
���          � cString - Mensagem                                         ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function Ct030ImpR4(oReport,oSecaoCTD )

Local cMascara
Local cSeparador 	:= ""
Local cIndex
Local cCondicao
Local cChave
Local nScanMoeda

Pergunte( "CTR030" , .F. )

// define o numero da pagina
oReport:SetPageNumber( mv_par03 )

CTO->(DbSetOrder(1))

//��������������������������������������������������������������������������Ŀ
//� Verificando se a Moeda informada pelo usuario (mv_par04) esta cadastrada �
//����������������������������������������������������������������������������
If (	Empty(mv_par04)	)	.Or.;										//	Se nao preencheu a moeda ou;
	(	! CTO->( MsSeek( xFilial("CTO")+mv_par04,.F. ) )	)	//	nao encontrou a Moeda no cadastro
	Help(" ",1,"NOMOEDA")
	oReport:CancelPrint()	
EndIf

If Empty(mv_par06)
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara := RetMasCtb(mv_par06,@cSeparador)
EndIf    

oSecaoCTD:Cell("CTD_ITEM"):SetBlock(	{|| EntidadeCTB(CTD->CTD_ITEM,000,000,030,.F.,cMascara,cSeparador,,,.F.,,.F.)	}	)
oSecaoCTD:Cell("CTD_ITSUP"):SetBlock(	{|| EntidadeCTB(CTD->CTD_ITSUP,000,000,030,.F.,cMascara,cSeparador,,,.F.,,.F.)	}	)
oSecaoCTD:Cell("CTD_BLOQ" ):SetBlock(	{|| If (CTD->CTD_BLOQ == "1",OemToAnsi(STR0012),OemToAnsi(STR0013)) 	}	)

cCondicao := "CTD_FILIAL == '"+xFilial('CTD')+"' .And. CTD_ITEM >= '"+mv_par01+"' .And. CTD_ITEM <= '"+mv_par02+"'"
IF mv_par05 == 2
	cCondicao += " .And. CTD_BLOQ <> '1' "
   EndIf

oSecaoCTD:SetLineCondition({|| &cCondicao})

// Se NAO selecionou a ordem por codigo do C.Custo
If oSecaoCTD:GetOrder() <> 1

      // Se for Moeda 01
	If mv_par04 == "01"
		// Trabalhando com o indice 4 do CTD ( CTD_FILIAL + CTD_DESC01 )
		oSecaoCTD:SetIdxOrder(4)
	Else                                      		
		//Se NAO for Moeda 01, criar indice temporario por descricao na moeda selecionada
		cChave 	:= "CTD_FILIAL+CTD_DESC"+mv_par04
		cIndex	:= CriaTrab(nil,.f.)
		IndRegua("CTD",cIndex,cChave,,,OemToAnsi(STR0011)) //"Selecionando Registros..."
		nIndex	:= RetIndex("CTD")
		oSecaoCTD:SetIdxOrder(0)
	EndIf
EndIf
//Cabec...
oSecaoCTD:Print()

// Se criou novo indice, apaga-lo e retornar o indice 1 do CTD
If oSecaoCTD:GetOrder() <> 1
	If mv_par04 <> "01"
		CTD->( dbClearFilter() )
		RetIndex( "CTD" )
		If !Empty(cIndex)
			FErase( cIndex+OrdBagExt() )
		Endif
	EndIf
	CTD->( dbSetOrder(1) )
EndIf

Return