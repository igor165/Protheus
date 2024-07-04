#INCLUDE "CTBR090.CH"
#INCLUDE "PROTHEUS.CH"


// 17/08/2009 -- Filial com mais de 2 caracteres

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � Ctbr090  � Autor � Pilar S Albaladejo    � Data � 10/01/00 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Impressao do Cadastro de Itens Contabeis		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctbr090()                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                    ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function Ctbr090()

Private nomeProg	:= "CTBR090"

CTBR090R4()

Return

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � CTBR090R4 � Autor� Daniel Sakavicius		� Data � 17/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Impressao do Cadastro de Itens Contabeis	- R4  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � CTBR090R4												  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � SIGACTB                                    				  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function CTBR090R4()         

//������������������������������������������������������������������������Ŀ
//�Interface de impressao                                                  �
//��������������������������������������������������������������������������
oReport := ReportDef()      
If !Empty( oReport:uParam )
	Pergunte( oReport:uParam, .F. )
EndIf	
oReport :PrintDialog()      
Return                                


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportDef � Autor � Daniel Sakavicius		� Data � 17/07/06 ���
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

Local oReport
local aArea	   		:= GetArea()   
Local cReport		:= "CTR090"
Local cSayClass		:= CtbSayApro("CTH")				//	"Cod Cl Val"
Local cTitulo		:= STR0007 + cSayClass	   			//	"Listagem do Cadastro de Cod Cl Val"
Local aOrdem 		:= {cSayClass,OemToAnsi(STR0004)}	// Cod. Classe,Descricao"
Local cDesc			:= STR0001+" "+cSayClass+;	  		// "Este programa ira imprimir o Cadastro Cod Cl Val"
							STR0002+;						// "Sera impresso de acordo com os parametros solicitados pelo"
							STR0003							//	"usuario."			
Local nCont
Local cMascara	
Local aTamCLVL		:= TAMSX3("CTH_CLVL")    						
Local aTamDesc		:= TAMSX3("CTH_DESC01")  
Local aTamSup		:= TAMSX3("CTH_CLSUP") 
Local oClasse	

*��������������������������������������������������Ŀ
*�add por Icaro Queiroz em 25 de Agosto de 2010     �
*�Variaveis para tratamento de tipificacao - CTBR015�
*����������������������������������������������������
Local bTitulo		:= { |cCampo| SX3->( dbSetOrder(2) ), SX3->( MsSeek( cCampo ) ), X3Titulo() }
Local cTitCpo

PRIVATE cPerg		:= "CTR090"							

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

//"Este programa tem o objetivo de emitir o Cadastro de Itens Classe de Valor "
//"Sera impresso de acordo com os parametros solicitados pelo"
//"usuario"
oReport	:= TReport():New( cReport,cTitulo,cPerg, { |oReport| ReportPrint( oReport,oClasse ) }, cDesc )

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
oClasse  := TRSection():New( oReport, cSayClass, {"CTH"}, aOrdem, .F., .F. )        

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

TRCell():New( oClasse, "CTH_CLVL"  , "CTH",Upper(cSayClass),/*Picture*/,aTamClvl[1]+aTamClvl[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oClasse, "DESCRI"  	, ,STR0008   ,/*Picture*/,aTamDesc[1]/*Tamanho*/,/*lPixel*/,{|| If(CTH->( FieldPos("CTH_DESC"+mv_par04) )>0,CTH->( FieldGet(FieldPos("CTH_DESC"+mv_par04)) ),CTH->CTH_DESC01) } )	// "D E N O M I N A C A O                             "
TRCell():New( oClasse, "CTH_CLSUP" , "CTH",Upper(cSayClass)+" "+AllTrim(Left(STR0009,10)),/*Picture*/,aTamSup[1]/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)
TRCell():New( oClasse, "CTH_BLOQ"  , "CTH",AllTrim(Right(STR0009,5)),/*Picture*/,/*Tamanho*/,/*lPixel*/,/*CodeBlock*/)

*���������������������������������������������������������������Ŀ
*�Add por Icaro Queiroz em 25 de Agosto de 2010                  �
*�Caso seja chamado do CTBR015, imprime as colunas de tipificacao�
*�����������������������������������������������������������������
If Upper( FunName() ) == 'CTBR015'
	If MV_TPO01 > 0
		cTitCpo := Eval( bTitulo, ( "CTH_TPO" + StrZero( MV_TPO01, 2 ) ) )
		TRCell():New( oClasse, "CTH_TPO01"		,"CTH" , cTitCpo,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || &( "CTH->CTH_TPO" + StrZero( MV_TPO01, 2 ) ) } )
	EndIf

	If MV_TPO02 > 0
		cTitCpo := Eval( bTitulo, ( "CTH_TPO" + StrZero( MV_TPO02, 2 ) ) )
		TRCell():New( oClasse, "CTH_TPO02"		,"CTH" , cTitCpo,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || &( "CTH->CTH_TPO" + StrZero( MV_TPO02, 2 ) ) } )
	EndIf

	If MV_TPO03 > 0
		cTitCpo := Eval( bTitulo, ( "CTH_TPO" + StrZero( MV_TPO03, 2 ) ) )
		TRCell():New( oClasse, "CTH_TPO03"		,"CTH" , cTitCpo,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || &( "CTH->CTH_TPO" + StrZero( MV_TPO03, 2 ) ) } )
	EndIf

	If MV_TPO04 > 0
		cTitCpo := Eval( bTitulo, ( "CTH_TPO" + StrZero( MV_TPO04, 2 ) ) )
		TRCell():New( oClasse, "CTH_TPO04"		,"CTH" , cTitCpo,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || &( "CTH->CTH_TPO" + StrZero( MV_TPO04, 2 ) ) } )
	EndIf
EndIf

Return(oReport)    
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �ReportPrint� Autor � Daniel Sakavicius	� Data � 17/07/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o �Imprime o relatorio definido pelo usuario de acordo com as  ���
���          �secoes/celulas criadas na funcao ReportDef definida acima.  ���
���          �Nesta funcao deve ser criada a query das secoes se SQL ou   ���
���          �definido o relacionamento e filtros das tabelas em CodeBase.���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � ReportPrint(oReport,aSection)                              ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �EXPO1: Objeto do relat�rio                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportPrint( oReport, oSecaoCTH )

Local cMascara
Local cSeparador	:= ""
Local lMoedaOk		:= .T.
Local nScanMoeda

Local cChave 		:= ""
Local cIndex		:= ""
Local nIndex

//��������������������������������������������������������������������������Ŀ
//� Verificando se a Moeda informada pelo usuario (mv_par04) esta cadastrada �
//����������������������������������������������������������������������������
If (	Empty(mv_par04)	)	.Or.;								//	Se nao preencheu a moeda ou;
	(	! CTO->( MsSeek( xFilial("CTO")+mv_par04,.F. ) )	)	//	nao encontrou a Moeda no cadastro
	Help(" ",1,"NOMOEDA")
	oReport:CancelPrint()	
EndIf

If Empty(mv_par06)
	cMascara := GetMv("MV_MASCCTH")
Else
	cMascara := RetMasCtb(mv_par06,@cSeparador)
EndIf

oReport:SetPageNumber( mv_par03 )

nScanMoeda := Val(MV_PAR04)//Ascan( aSection[1],CTO->CTO_MOEDA )

oSecaoCTH:Cell("CTH_CLVL"):SetBlock(	{|| EntidadeCTB(CTH->CTH_CLVL,000,000,025,.F.,cMascara,cSeparador,,,.F.,,.F.)	}	)
oSecaoCTH:Cell("DESCRI"):SetBlock(	{|| &('CTH->CTH_DESC'+mv_par04)	}	)
oSecaoCTH:Cell("CTH_CLSUP"):SetBlock(	{|| EntidadeCTB(CTH->CTH_CLSUP,000,000,025,.F.,cMascara,cSeparador,,,.F.,,.F.)	}	)
oSecaoCTH:Cell("CTH_BLOQ" ):SetBlock(	{|| If (CTH->CTH_BLOQ == "1",OemToAnsi(STR0012),OemToAnsi(STR0013)) 	}	)
                                                                               
cCondicao := "CTH->CTH_FILIAL == xFilial('CTH') .And. CTH->CTH_CLVL >= mv_par01 .And. CTH->CTH_CLVL <= mv_par02"
IF mv_par05 == 2
	cCondicao += " .And. CTH->CTH_BLOQ <> '1' "
EndIf

oSecaoCTH:SetLineCondition({|| &cCondicao})

// Se NAO selecionou a ordem por codigo da Classe
If oSecaoCTH:GetOrder() <> 1
	oSecaoCTH:SetIdxOrder(4)
EndIf

oSecaoCTH:Print()

// Se criou novo indice, apaga-lo e retornar o indice 1 do CTT
If oSecaoCTH:GetOrder() <> 1
	If mv_par04 <> "01"
		CTH->( dbClearFilter() )
		RetIndex( "CTH" )
		If !Empty(cIndex)
			FErase( cIndex+OrdBagExt() )
		Endif
	EndIf
	CTH->( dbSetOrder(1) )
EndIf
    
Return
