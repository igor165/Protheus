#INCLUDE "CTBR020.CH"
#INCLUDE "PROTHEUS.CH"


// 17/08/2009 -- Filial com mais de 2 caracteres

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR020  � Autor � Eduardo Nunes Cirqueira � Data � 07/07/06 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Impressao do Cadastro de Centro de Custo		  	 ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctbr020() 		                                              ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                      ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
/*/

Function CTBR020()

Local oReport

oReport	:= ReportDef()
oReport:PrintDialog()

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � ReportDef � Autor � Eduardo Nunes      � Data �  07/07/06  ���
�������������������������������������������������������������������������͹��
���Descricao � Definicao do objeto do relatorio personalizavel e das      ���
���          � secoes que serao utilizadas                                ���
�������������������������������������������������������������������������͹��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � SIGACTB                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function ReportDef()

Local oReport
Local oSecaoCTT

Local cReport	:=	"CTBR020"					// Nome do Relatorio

Local aArea		:= GetArea()
Local cPerg  	:= "CTR020"						// Nome do grupo de perguntas
Local cAlias	:= "CTT"						// Alias da tabela
Local cSayCusto	:= CtbSayApro("CTT")			// "C Custo"
Local cTitulo	:= STR0007 + cSayCusto			// "Listagem do Cadastro de C Custo"

Local aOrd	 	:= { cSayCusto,;				// "C Custo"
					 OemToAnsi(STR0004)}		// "Descricao"

Local cDesc		:= STR0001+" "+cSayCusto+;		// "Este programa ira imprimir o Cadastro de C Custo"
				   STR0002+;					// "Sera impresso de acordo com os parametros solicitados pelo"
				   STR0003						//	"usuario."
                                                                    
Local nCont
Local cMascara

*��������������������������������������������������Ŀ
*�add por Icaro Queiroz em 24 de Agosto de 2010     �
*�Variaveis para tratamento de tipificacao - CTBR015�
*����������������������������������������������������
Local bTitulo		:= { |cCampo| SX3->( dbSetOrder(2) ), SX3->( MsSeek( cCampo ) ), X3Titulo() }
Local cTitCpo

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01		// Do C.Custo                                �
//� mv_par02		// ate o C.Custo                             �
//� mv_par03		// folha inicial		         		     �
//� mv_par04		// Desc na Moeda						     �
//� mv_par05		// Imprime Bloqueadas?         	       	     � 
//� mv_par06		// Mascara?                    	       	     � 
//����������������������������������������������������������������

dbSelectArea("CTT")
dbSetOrder(1)


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
oReport	:= TReport():New( cReport,cTitulo,cPerg, { |oReport| Iif( CTBR020Imp( oReport,oSecaoCTT ), .T., oReport:CancelPrint() ) }, cDesc )
					
//�������������������������������������������������������������������������������������������Ŀ
//� Define tantas secoes quantas Moedas existirem na base, pois somente assim podera imprimir �
//� a descricao da moeda que o usuario selecionou atraves do parametro mv_par04               �
//���������������������������������������������������������������������������������������������
CTO->( MsSeek( xFilial("CTO"),.T. ) )
oSecaoCTT := TRSection():New( oReport, cSayCusto , {"CTT"}, aOrd )	//	"Listagem do Cadastro de C Custo"

TRCell():New( oSecaoCTT, "CTT_CUSTO"	,"CTT",Upper(cSayCusto)												,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "C CUSTO"
TRCell():New( oSecaoCTT, "DESCRI"		,"CTT",STR0008															,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| If(CTT->( FieldPos("CTT_DESC"+mv_par04) )>0,CTT->( FieldGet(FieldPos("CTT_DESC"+mv_par04)) ),CTT->CTT_DESC01) } )	// "D E N O M I N A C A O "
TRCell():New( oSecaoCTT, "CTT_CCSUP"	,"CTT",Upper(cSayCusto)+" "+AllTrim(Left(STR0009,10))	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "C CUSTO SUPERIOR"
TRCell():New( oSecaoCTT, "CTT_BLOQ"		,"CTT",AllTrim(Right(STR0009,5))									,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	// "BLOQ"

*���������������������������������������������������������������Ŀ
*�Add por Icaro Queiroz em 24 de Agosto de 2010                  �
*�Caso seja chamado do CTBR015, imprime as calunas de tipificacao�
*�����������������������������������������������������������������
If Upper( FunName() ) == 'CTBR015'
	If 	CTT->( FieldPos( "CTT_TPO01" ) ) > 0 .And.;
		CTT->( FieldPos( "CTT_TPO02" ) ) > 0 .And.;
		CTT->( FieldPos( "CTT_TPO03" ) ) > 0 .And.;
		CTT->( FieldPos( "CTT_TPO04" ) ) > 0

		If MV_TPO01 > 0
			cTitCpo := Eval( bTitulo, ( "CTT_TPO" + StrZero( MV_TPO01, 2 ) ) )
			TRCell():New( oSecaoCTT, "CTT_TPO01"		,"CTT" , cTitCpo,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || &( "CTT->CTT_TPO" + StrZero( MV_TPO01, 2 ) ) } )
		EndIf

		If MV_TPO02 > 0
			cTitCpo := Eval( bTitulo, ( "CTT_TPO" + StrZero( MV_TPO02, 2 ) ) )
			TRCell():New( oSecaoCTT, "CTT_TPO02"		,"CTT" , cTitCpo,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || &( "CTT->CTT_TPO" + StrZero( MV_TPO02, 2 ) ) } )
		EndIf

		If MV_TPO03 > 0
			cTitCpo := Eval( bTitulo, ( "CTT_TPO" + StrZero( MV_TPO03, 2 ) ) )
			TRCell():New( oSecaoCTT, "CTT_TPO03"		,"CTT" , cTitCpo,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || &( "CTT->CTT_TPO" + StrZero( MV_TPO03, 2 ) ) } )
		EndIf

		If MV_TPO04 > 0
			cTitCpo := Eval( bTitulo, ( "CTT_TPO" + StrZero( MV_TPO04, 2 ) ) )
			TRCell():New( oSecaoCTT, "CTT_TPO04"		,"CTT" , cTitCpo,/*Picture*/,/*Tamanho*/,/*lPixel*/, { || &( "CTT->CTT_TPO" + StrZero( MV_TPO04, 2 ) ) } )
		EndIf

	EndIf
EndIf

Return oReport      


/*/
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
�����������������������������������������������������������������������������Ŀ��
���Fun��o    � CTBR020Imp � Autor � Eduardo Nunes Cirqueira � Data � 17/07/06 ���
�����������������������������������������������������������������������������Ĵ��
���Descri��o � Programa de Impressao do Cadastro de Centro de Custo (R4)      ���
�����������������������������������������������������������������������������Ĵ��
���Sintaxe   � Ctbr020(oReport,oSection)                                      ���
�����������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                         ���
�����������������������������������������������������������������������������Ĵ��
��� Uso      � SIGACTB                                                        ���
�����������������������������������������������������������������������������Ĵ��
���Parametros� oReport  = Objeto de impressao da classe TReport               ���
���          � oSection = Matriz contendo as Secoes de impressao. Cada        ���
���          �            elemento corresponde a secao de uma moeda           ���
������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Function CTBR020Imp( oReport,oSecaoCTT )

Local lMoedaOk		:= .T.

Local cMascara		:= ""
Local cSeparador	:= ""

Local cChave 		:= ""
Local cIndex		:= ""

Local nSizeCC		:= 0
Local nIndex		:= 0
Local nScanMoeda	:= 0
Local nTamCusto		:= TamSX3("CTT_CUSTO")[1]

Pergunte("CTR020",.F.)

oReport:SetPageNumber( mv_par03 ) //mv_par03 - Pagina Inicial

//��������������������������������������������������������������������������Ŀ
//� Verificando se a Moeda informada pelo usuario (mv_par04) esta cadastrada �
//����������������������������������������������������������������������������
If (	Empty(mv_par04)	)	.Or.;										//	Se nao preencheu a moeda ou;
	(	! CTO->( MsSeek( xFilial("CTO")+mv_par04,.F. ) )	)	//	nao encontrou a Moeda no cadastro
	Help(" ",1,"NOMOEDA")
	Return .F.
EndIf

If Empty(mv_par06)
	cMascara := GetMv("MV_MASCCUS")
Else
	cMascara := RetMasCtb(mv_par06,@cSeparador)
EndIf

nSizeCC := IF( Empty(cMascara),nTamCusto,If(Empty(cSeparador),nTamCusto+Len(cMascara),nTamCusto+Len(cSeparador)))
                                            
oSecaoCTT:Cell("CTT_CUSTO"):SetSize(nSizeCC)
oSecaoCTT:Cell("CTT_CCSUP"):SetSize(nSizeCC)
	
oSecaoCTT:Cell("CTT_CUSTO"):SetBlock(	{|| EntidadeCTB(CTT->CTT_CUSTO,000,000,030,.F.,cMascara,cSeparador,,,.F.,,.F.)	}	)
oSecaoCTT:Cell("CTT_CCSUP"):SetBlock(	{|| EntidadeCTB(CTT->CTT_CCSUP,000,000,030,.F.,cMascara,cSeparador,,,.F.,,.F.)	}	)
oSecaoCTT:Cell("CTT_BLOQ" ):SetBlock(	{|| If (CTT->CTT_BLOQ == "1",OemToAnsi(STR0012),OemToAnsi(STR0013)) 	}	)
                                                                               
cCondicao := "CTT_FILIAL =='"+ xFilial('CTT') +"'.And. CTT_CUSTO >= '"+mv_par01+"' .And. CTT_CUSTO <='"+ mv_par02+ "'"
IF mv_par05 == 2
	cCondicao += " .And. CTT_BLOQ <> '1' "
EndIf

oSecaoCTT:SetLineCondition({|| &cCondicao})

// Se NAO selecionou a ordem por codigo do C.Custo
If oSecaoCTT:GetOrder() <> 1

      // Se for Moeda 01
	If mv_par04 == "01"
		// Trabalhando com o indice 4 do CTT ( CTT_FILIAL + CTT_DESC01 )
		oSecaoCTT:SetIdxOrder(4)
	Else                                      		
		//Se NAO for Moeda 01, criar indice temporario por descricao na moeda selecionada
		cChave 	:= "CTT_FILIAL+CTT_DESC"+mv_par04
		cIndex	:= CriaTrab(nil,.f.)
		IndRegua("CTT",cIndex,cChave,,,OemToAnsi(STR0011)) //"Selecionando Registros..."
		nIndex	:= RetIndex("CTT")
		oSecaoCTT:SetIdxOrder(0)
	EndIf
EndIf

oSecaoCTT:Print()

// Se criou novo indice, apaga-lo e retornar o indice 1 do CTT
If oSecaoCTT:GetOrder() <> 1
	If mv_par04 <> "01"
		CTT->( dbClearFilter() )
		RetIndex( "CTT" )
		If !Empty(cIndex)
			FErase( cIndex+OrdBagExt() )
		Endif
	EndIf
	CTT->( dbSetOrder(1) )
EndIf
	
Return .T.