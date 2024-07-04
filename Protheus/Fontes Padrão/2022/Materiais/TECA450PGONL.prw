#include "Protheus.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AT450PGOnL1 � Autor � Conrado Q. Gomes   � Data � 09.02.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de gest�o on-line (Faturamento m�dio por O.S)       ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGATEC                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function AT450PGOnL1()

	Local aInfo					:= {}					// Array com os dados que ser�o exibidos no painel
	Local nCntFor				:= 0					// Contador
	Local aMesAnoFaturamentoOSs	:= {}					// Array com objetos
	Local nMesReferencia		:= Month(dDataBase)		// M�s atual
	Local nAnoReferencia		:= Year(dDataBase)		// Ano atual
	Local cAliasQry	:= GetNextAlias()		// Alias de conex�o TOP

	//��������������������������������������������������������������Ŀ
	//�                       PARAMETROS                             �
	//�                                                              �
	//� MV_PAR01 : Cliente de ?                                      �
	//� MV_PAR02 : Loja de ?                                         �
	//� MV_PAR03 : Cliente ate ?                                     �	
	//� MV_PAR04 : Loja ate ?                                        �	
	//� MV_PAR05 : Quantos meses ?                                   �		
	//�                                                              �
	//����������������������������������������������������������������	
	Pergunte("ATP450",.F.)

	// Cria o objeto desse m�s
	aAdd( aMesAnoFaturamentoOSs, MesAnoFaturamentoOS():New( nMesReferencia, nAnoReferencia ) )
	    
	// Cria os objetos dos m�ses anteriores desejados
	For nCntFor := 1 To MV_PAR05
		If nMesReferencia == 1
			nMesReferencia := 12
			nAnoReferencia -= 1
		Else
			nMesReferencia -= 1
		EndIf
		
		aAdd( aMesAnoFaturamentoOSs, MesAnoFaturamentoOS():New( nMesReferencia, nAnoReferencia ) )
	Next
	
	MakeSqlExpr("ATP450")	
	
	BeginSql Alias cAliasQry
		Column D2_EMISSAO As Date
	
		SELECT	C6_FILIAL	, C6_NUMOS	, C6_CLI	, C6_LOJA	, 
				C6_NUM		, C6_ITEM	, C6_NUMOS	, D2_FILIAL	,
				D2_PEDIDO	, D2_ITEMPV	, D2_EMISSAO, D2_VALBRUT
		
		FROM %table:SC6% SC6
		
		JOIN %table:SD2% SD2 ON
			D2_FILIAL = %xFilial:SD2%
			AND D2_PEDIDO = C6_NUM
			AND D2_ITEMPV = C6_ITEM
			AND SD2.%NotDel%
			
		WHERE C6_FILIAL = %xFilial:SC6%
			AND C6_NUMOS IS NOT NULL
			AND C6_CLI  BETWEEN %Exp:mv_par01% AND %Exp:mv_par03%
			AND C6_LOJA BETWEEN %Exp:mv_par02% AND %Exp:mv_par04%
			AND SC6.%NotDel%

	EndSql		

	dbSelectArea(cAliasQry)
	If !(cAliasQry)->(Eof())
		While !(cAliasQry)->(Eof())
			// Para cada m�s verifica se � o m�s correspondente e adiciona o valor e a O.S. no objeto
			For nCntFor := 1 To Len( aMesAnoFaturamentoOSs )
				If aMesAnoFaturamentoOSs[nCntFor]:IsMesAnoReferente( (cAliasQry)->D2_EMISSAO )
					aMesAnoFaturamentoOSs[nCntFor]:Soma( (cAliasQry)->C6_NUMOS, (cAliasQry)->D2_VALBRUT )
				EndIf
			Next			
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf
	(cAliasQry)->(DbCloseArea())			
	
	// Para cada objeto adiciona na array de retornos os dados
	For nCntFor := 1 To Len( aMesAnoFaturamentoOSs )
		aAdd( aInfo, { aMesAnoFaturamentoOSs[nCntFor]:MesAnoReferencia()	, Transform( aMesAnoFaturamentoOSs[nCntFor]:Media() ,PesqPict("SD2", "D2_VALBRUT") )	,aMesAnoFaturamentoOSs[nCntFor]:Cor(), {||} } )
	Next	
			
Return aInfo

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Classe    � MesAnoFaturamentoOS � Autor � Conrado Q. Gomes    � Data � 09.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Classe com as informa��es do m�s/ano para c�lculo, etc.             ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Class MesAnoFaturamentoOS
	Data nMesReferente		As Integer
	Data nAnoReferente		As Integer
	Data nMesPosReferente	As Integer
	Data nAnoPosReferente	As Integer
	Data nValor				As Integer	
	Data aOSs				As Array
	Data lStatico			As Boolean
	
	Method New() Constructor
	Method AddOs()
	Method Soma()	
	Method Media()
	Method MesAnoReferente()
	Method IsMesAnoReferente()
	Method Cor()
EndClass

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � New                 � Autor � Conrado Q. Gomes    � Data � 09.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Contrutor.                                                          ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1: M�s a que o objeto se refere                                 ���
���          � ExpN2: Ano a que o objeto se refere                                 ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method New( nMesReferente, nAnoReferente ) Class MesAnoFaturamentoOS
	::nMesReferente	:= nMesReferente
	::nAnoReferente	:= nAnoReferente
	::nValor		:= 0	
	::aOSs			:= {}	

	// Configura mes/ano posterior
	If ::nMesReferente == 12
		::nMesPosReferente := 1
		::nAnoPosReferente := ::nAnoReferente + 1
	Else
		::nMesPosReferente := ::nMesReferente + 1
		::nAnoPosReferente := ::nAnoReferente
	EndIf	

Return

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � AddOs               � Autor � Conrado Q. Gomes    � Data � 09.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Adiciona uma OS ao contador de OSs do objeto.                       ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1: N�mero da OS                                                 ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method AddOs( nNumOS ) Class MesAnoFaturamentoOS
	Local nCntFor	:= 0
	Local lAdiciona := .T.
	
	// Procura se o n�mero da O.S. j� foi cadastrado anteriormente, evitando que se conte duas vezes
	For nCntFor := 1 To Len( ::aOSs )
		If ( ::aOSs[nCntFor] == SubStr(nNumOs,1,6) )
			lAdiciona := .F.
		EndIf
	Next
	
	// Se n�o encontrou adiciona na array de O.S.s
	If lAdiciona
		aAdd( ::aOSs, SubStr(nNumOS,1,6) )
	EndIf
Return

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � Soma                � Autor � Conrado Q. Gomes    � Data � 09.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Adiciona o valor ao objeto.                                         ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1: N�mero da OS                                                 ���
���          � ExpN2: Valor a ser adicionado                                       ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method Soma( nNumOS, nValor ) Class MesAnoFaturamentoOS	
	// Soma o valor e adiciona a O.S.
	::nValor += nValor
	::AddOs( nNumOS )
Return

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � Media               � Autor � Conrado Q. Gomes    � Data � 09.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula a m�dia do Mes/Ano referente.                               ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � Media do Mes/Ano refer�nte.                                          ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method Media() Class MesAnoFaturamentoOS
	Local nRet := 0	// M�dia de faturamento no m�s
	
	// Prote��o contra divis�o por zero
	If Len( ::aOSs ) > 0
		nRet := ( ::nValor / Len( ::aOSs ) )
	EndIf		
Return nRet

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � MesAnoReferente     � Autor � Conrado Q. Gomes    � Data � 09.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Cria string para exibi��o dos Mes/Ano referente.                    ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � String para exibi��o do Mes/Ano refer�nte.                          ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method MesAnoReferente() Class MesAnoFaturamentoOS
Return ( StrZero( ::nMesReferente, 2 ) + "/" + Alltrim( Str ( ::nAnoReferente ) ) )

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � IsMesAnoReferente   � Autor � Conrado Q. Gomes    � Data � 09.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se a data informada est� no escopo do objeto.              ���
����������������������������������������������������������������������������������Ĵ��
���Par�metro � ExpD1: Data para verifica��o.                                       ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � L�gico, se a data est� ou n�o no escopo do objeto	               ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method IsMesAnoReferente( dData ) Class MesAnoFaturamentoOS
	Local lRet := .F.	
	
	// Se a data passada por par�metro se refere ao mes/ano referente desse objeto
	If	(	dData >= CToD( "01/" + Alltrim( Str( ::nMesReferente ) ) 		+ "/" + Alltrim( Str( ::nAnoReferente ) ) )	.AND.;
			dData <  CToD( "01/" + Alltrim( Str( ::nMesPosReferente ) )	+ "/" + Alltrim( Str( ::nAnoPosReferente ) ) )	)	
		lRet := .T.
	EndIf
Return lRet                  

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � Cor                 � Autor � Conrado Q. Gomes    � Data � 09.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorno a Cor para exibi��o da informa��o relativa ao M�s/Ano.      ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � Cor para a exibi��o.                             	               ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method Cor() Class MesAnoFaturamentoOS
	Local cCor := CLR_BLACK	// Cor padr�o para a exibi��o dos dados
	
	// Se o mes/ano referente desse objeto for o mesmo da data atual, retorna outra cor
	If ( Month( dDataBase ) == ::nMesReferente ) .And. ( Year( dDataBase ) == ::nAnoReferente )
		cCor := CLR_BLUE
	EndIf		
Return cCor