#include "Protheus.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � AT460PGOnL1 � Autor � Conrado Q. Gomes   � Data � 12.02.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de gest�o on-line (Tempo de atend. m�dio por O.S)   ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGATEC                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function AT460PGOnL1()

	Local aInfo					:= {}					// Array com os dados que ser�o exibidos no painel
	Local nCntFor				:= 0					// Contador
	Local aMesAnoAtendimentoOSs	:= {}					// Array com objetos
	Local nMesReferencia		:= Month(dDataBase)		// M�s atual
	Local nAnoReferencia		:= Year(dDataBase)		// Ano atual
	Local cAliasQry				:= GetNextAlias()		// Alias de conex�o TOP

	//��������������������������������������������������������������Ŀ
	//�                       PARAMETROS                             �
	//�                                                              �
	//� MV_PAR01 : Cliente de ?                                      �
	//� MV_PAR02 : Loja de ?                                         �
	//� MV_PAR03 : Cliente ate ?                                     �	
	//� MV_PAR04 : Loja ate ?                                        �	
	//� MV_PAR05 : T�cnico de ?                                      �		
	//� MV_PAR06 : T�cnico at� ?                                     �			
	//� MV_PAR07 : Produto de ?                                      �		
	//� MV_PAR08 : Produto at� ?                                     �				
	//� MV_PAR09 : Quantos meses ?                                   �		
	//�                                                              �
	//����������������������������������������������������������������	
	Pergunte("ATP460",.F.)

	// Cria o objeto desse m�s
	aAdd( aMesAnoAtendimentoOSs, MesAnoAtendimentoOS():New( nMesReferencia, nAnoReferencia ) )
	    
	// Cria os objetos dos m�ses anteriores desejados
	For nCntFor := 1 To MV_PAR09
		If nMesReferencia == 1
			nMesReferencia := 12
			nAnoReferencia -= 1
		Else
			nMesReferencia -= 1
		EndIf
		
		aAdd( aMesAnoAtendimentoOSs, MesAnoAtendimentoOS():New( nMesReferencia, nAnoReferencia ) )
	Next
	
	MakeSqlExpr("ATP460")	
	
	BeginSql Alias cAliasQry
		Column AB9_DTFIM As Date
	
		SELECT	AB9_FILIAL	, AB9_CODCLI, AB9_LOJA	, AB9_CODTEC,
	   			AB9_DTFIM	, AB9_NUMOS	, AB9_TOTFAT
		
		FROM %table:AB9% AB9
			
		WHERE AB9_FILIAL = %xFilial:AB9%
			AND AB9_CODCLI  BETWEEN %Exp:mv_par01% AND %Exp:mv_par03%
			AND AB9_LOJA	BETWEEN %Exp:mv_par02% AND %Exp:mv_par04%
			AND AB9_CODTEC	BETWEEN %Exp:mv_par05% AND %Exp:mv_par06%
			AND AB9_CODPRO	BETWEEN %Exp:mv_par07% AND %Exp:mv_par08%				
			AND AB9.%NotDel%

	EndSql		

	dbSelectArea(cAliasQry)
	If !(cAliasQry)->(Eof())
		While !(cAliasQry)->(Eof())
			// Para cada m�s verifica se � o m�s correspondente e adiciona o valor e a O.S. no objeto
			For nCntFor := 1 To Len( aMesAnoAtendimentoOSs )
				If aMesAnoAtendimentoOSs[nCntFor]:IsMesAnoReferente( (cAliasQry)->AB9_DTFIM )
					aMesAnoAtendimentoOSs[nCntFor]:Soma( (cAliasQry)->AB9_NUMOS, (cAliasQry)->AB9_TOTFAT )
				EndIf
			Next			
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf
	(cAliasQry)->(DbCloseArea())			

	// Para cada objeto adiciona na array de retornos os dados
	For nCntFor := 1 To Len( aMesAnoAtendimentoOSs )
		aAdd( aInfo, { aMesAnoAtendimentoOSs[nCntFor]:MesAnoReferencia()	, aMesAnoAtendimentoOSs[nCntFor]:Media()	,aMesAnoAtendimentoOSs[nCntFor]:Cor(), {||} } )
	Next	
			
Return aInfo

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Classe    � MesAnoAtendimentoOS � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Classe com as informa��es do m�s/ano para c�lculo, etc.             ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Class MesAnoAtendimentoOS
	Data nMesReferente		As Integer	// M�s a que o objeto se refere
	Data nAnoReferente		As Integer	// Ano a que o objeto se refere
	Data nMesPosReferente	As Integer	// Pr�ximo m�s
	Data nAnoPosReferente	As Integer	// Pr�ximo ano
	Data nTempo				As Integer	// Tempo total do m�s/ano
	Data aOSs				As Array	// OSs atreladas ao tempo total
	Data lStatico			As Boolean	// Se � o objeto do m�s atual
	
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
���M�todo    � New                 � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
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
Method New( nMesReferente, nAnoReferente ) Class MesAnoAtendimentoOS
	::nMesReferente	:= nMesReferente
	::nAnoReferente	:= nAnoReferente
	::nTempo		:= 0	
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
���M�todo    � AddOs               � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Adiciona uma OS ao contador de OSs do objeto.                       ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1: N�mero da OS                                                 ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method AddOs( nNumOS ) Class MesAnoAtendimentoOS
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
���M�todo    � Soma                � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Adiciona o valor ao objeto.                                         ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1: N�mero da OS                                                 ���
���          � ExpN2: Tempo a ser adicionado                                       ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method Soma( nNumOS, cTempo ) Class MesAnoAtendimentoOS	
	// Soma o valor e adiciona a O.S.
	::nTempo += HoraToInt(cTempo,2)
	::AddOs( nNumOS )
Return

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � Media               � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula a m�dia do Mes/Ano referente.                               ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � Media do Mes/Ano refer�nte.                                         ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method Media() Class MesAnoAtendimentoOS
	Local cRet := "00:00"// M�dia de Atendimento no m�s
	
	// Prote��o contra divis�o por zero
	If Len( ::aOSs ) > 0
		cRet := IntToHora( ::nTempo / Len( ::aOSs ) )
	EndIf		
Return ( cRet + "Hr(s)" )

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � MesAnoReferente     � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Cria string para exibi��o dos Mes/Ano referente.                    ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � String para exibi��o do Mes/Ano refer�nte.                          ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method MesAnoReferente() Class MesAnoAtendimentoOS
Return ( StrZero( ::nMesReferente, 2 ) + "/" + Alltrim( Str ( ::nAnoReferente ) ) )

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � IsMesAnoReferente   � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
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
Method IsMesAnoReferente( dData ) Class MesAnoAtendimentoOS
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
���M�todo    � Cor                 � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorno a Cor para exibi��o da informa��o relativa ao M�s/Ano.      ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � Cor para a exibi��o.                             	               ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method Cor() Class MesAnoAtendimentoOS
	Local cCor := CLR_BLACK	// Cor padr�o para a exibi��o dos dados
	
	// Se o mes/ano referente desse objeto for o mesmo da data atual, retorna outra cor
	If ( Month( dDataBase ) == ::nMesReferente ) .And. ( Year( dDataBase ) == ::nAnoReferente )
		cCor := CLR_BLUE
	EndIf		
Return cCor