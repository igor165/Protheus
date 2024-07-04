#INCLUDE "Protheus.ch"
#INCLUDE "MSGRAPHI.CH"
#INCLUDE "TMKA272PGON1.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � TK272PGOn1  � Autor � Conrado Q. Gomes   � Data � 12.02.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Painel de gest�o on-line (Status dos atendimentos em tmk)  ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                 											  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      �SIGATEC                                                     ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function TK272PGOn1()

	Local aInfo				:= {}			// Array com os dados que ser�o exibidos no painel
	Local nCntFor			:= 0			// Contador
	Local aPGONLAtendimento	:= {}			// Array com objetos
	Local dDataIni			:= dDataBase	// Data de inicio do processamento
	Local aTabela			:= {}			// Array com os dados relativos a quantidade por campanha
	Local aGraficoTit		:= {}			// Array com os t�tulos das partes do gr�fico
	Local aGraficoVal		:= {}			// Array com os valores de cada t�tulo

	Local cAliasQry	:= GetNextAlias()		// Alias de conex�o TOP

	//��������������������������������������������������������������Ŀ
	//�                       PARAMETROS                             �
	//�                                                              �
	//� MV_PAR01 : Dias a analisar ?                                 �
	//�                                                              �
	//����������������������������������������������������������������	
	Pergunte("TMKH05",.F.)

	// Cria o objeto desse m�s
	aAdd( aPGONLAtendimento, PGONLAtendimento():New( 1, BSCXBOX("UC_STATUS","1") ) )
	aAdd( aPGONLAtendimento, PGONLAtendimento():New( 2, BSCXBOX("UC_STATUS","2") ) )
	aAdd( aPGONLAtendimento, PGONLAtendimento():New( 3, BSCXBOX("UC_STATUS","3") ) )		    
	
	// Calcula data inicial de processamento
	dDataIni -= MV_PAR01
	
	MakeSqlExpr("TMKH05")	
			
	BeginSql Alias cAliasQry
		Column UC_DATA As Date
	
		SELECT	UC_FILIAL	, UC_DATA	, UC_STATUS	,	UC_CODCAMP
		
		FROM %table:SUC% SUC
			
		WHERE UC_FILIAL = %xFilial:SUC%
			AND UC_DATA	>	%Exp:dDataIni%
			AND SUC.%NotDel%

	EndSql		

	dbSelectArea(cAliasQry)
	If !(cAliasQry)->(Eof())
		While !(cAliasQry)->(Eof())
			For nCntFor := 1 To Len( aPGONLAtendimento )
				//�����������������������������������������������������������Ŀ
				//�Verifica se o objeto PGONLAtendimento � relativo ao status �
				//�do atendimento atual.                                      �
				//�������������������������������������������������������������
				If ( aPGONLAtendimento[nCntFor]:GetStatus() == Val((cAliasQry)->UC_STATUS) )
					//���������������������������������������������������������Ŀ
					//�Adiciona campanha, caso n�o exista, e soma na quantidade �
					//�de atendimento.                                          �
					//�����������������������������������������������������������
					If ( aPGONLAtendimento[nCntFor]:HasCampanha( (cAliasQry)->UC_CODCAMP ) )
						aPGONLAtendimento[nCntFor]:Conta( (cAliasQry)->UC_CODCAMP )
					Else
						aPGONLAtendimento[nCntFor]:AddCampanha( (cAliasQry)->UC_CODCAMP )
						aPGONLAtendimento[nCntFor]:Conta( (cAliasQry)->UC_CODCAMP )
					EndIf
				EndIf
			Next			
			(cAliasQry)->(DbSkip())
		EndDo
	EndIf
	(cAliasQry)->(DbCloseArea())			

	// Tabela com as informa��es detalhadas	
	aTabela :=	{	;
					{ aPGONLAtendimento[1]:GetNome(), { STR0005 , STR0006 }, aPGONLAtendimento[1]:GetTotalPorCampanha() }	,;	// "Campanha" "Quantidade"
					{ aPGONLAtendimento[2]:GetNome(), { STR0005 , STR0006 }, aPGONLAtendimento[2]:GetTotalPorCampanha() }	,;	// "Campanha" "Quantidade"
					{ aPGONLAtendimento[3]:GetNome(), { STR0005 , STR0006 }, aPGONLAtendimento[3]:GetTotalPorCampanha() }	;	// "Campanha" "Quantidade"							
				}
	
	// Valores do gr�fico
	aGraficoTit :=	{	aPGONLAtendimento[1]:GetNome() , aPGONLAtendimento[2]:GetNome() 	, aPGONLAtendimento[3]:GetNome()	}
	aGraficoVal := 	{	aPGONLAtendimento[1]:GetTotal(), aPGONLAtendimento[2]:GetTotal()	, aPGONLAtendimento[3]:GetTotal()	}

	// Constru��o do retorno esperado
	aInfo :=	{  GRP_PIE					,						;
					{ STR0001	, {||}	, aGraficoTit, aGraficoVal }	,;	// "Quantidade de Atendimentos"
					{ STR0002	, {||}	, aTabela  }	;					// "Atendimentos"
					}
Return aInfo

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���Classe    � MesAnoAtendimentoOS � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Classe com as informa��es relativas a um status de atendimento      ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Class PGONLAtendimento
	Data nStatus			As Integer	// Status do atendimento
	Data cNome				As String	// Nome do status do atendimento
	Data aCampanhas			As Array	// Campanhas
	
	Method New() Constructor
	Method Conta()
	Method AddCampanha()
	Method HasCampanha()
	Method GetStatus()
	Method GetNome()
	Method GetTotal()
	Method GetTotalPorCampanha()
EndClass

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � New                 � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Contrutor.                                                          ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� ExpN1: Status do atendimento                                        ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method New( nStatus, cNome ) Class PGONLAtendimento
	::nStatus		:= nStatus
	::cNome			:= cNome
	::aCampanhas	:= {}
Return

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � Conta               � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Adiciona um atendimento para uma determinada campanha               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: C�digo da campanha                                           ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method Conta( cCampanha ) Class PGONLAtendimento
	Local nPos := 0 // Posi��o da campanha, caso seja encontrada na lista de campanhas

	nPos := aScan( ::aCampanhas, {|x| x[1] == cCampanha } )
	If ( nPos > 0 )
		::aCampanhas[nPos][2]++
	EndIf
Return

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � AddCampanha         � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Adiciona uma campanha                                               ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: C�digo da campanha                                           ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method AddCampanha( cCampanha ) Class PGONLAtendimento
	aAdd( ::aCampanhas, { cCampanha, 0 } )
Return

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � HasCampanha         � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se a campanha j� foi adicionada                            ���
����������������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: C�digo da campanha                                           ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � ExpL1: Se a campanha est� cadastrada                                ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method HasCampanha( cCampanha ) Class PGONLAtendimento
	Local lRet := .F.	// N�o encontrou a campanha
	
	If ( aScan( ::aCampanhas, {|x| x[1] == cCampanha } ) > 0 )
		lRet := .T.
	EndIf
Return lRet

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � GetStatus           � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o Status de atendimento que o objeto contempla              ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � ExpN1: O Status de atendimento que o objeto contempla               ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method GetStatus() Class PGONLAtendimento
Return ::nStatus

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � GetNome             � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o Nome de atendimento que o objeto contempla                ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � ExpN1: O Nome de atendimento que o objeto contempla                 ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method GetNome() Class PGONLAtendimento
Return ( ::cNome )

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � GetTotal            � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Calcula o total de atendimentos cadastrados no objeto               ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � ExpN1: A quantiade total de atendimentos                            ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method GetTotal() Class PGONLAtendimento
	Local nTotal := 0	// Total de todas as campanhas
	aEval( ::aCampanhas, { |x| nTotal +=x[2] } )
Return nTotal

/*������������������������������������������������������������������������������������
��������������������������������������������������������������������������������������
����������������������������������������������������������������������������������Ŀ��
���M�todo    � GetTotalPorCampanha � Autor � Conrado Q. Gomes    � Data � 12.02.07 ���
����������������������������������������������������������������������������������Ĵ��
���Descri��o � Retorna o total de atendimentos por campanha                        ���
����������������������������������������������������������������������������������Ĵ��
���Retorno   � ExpA1: Total de atendimentos por campanha, onde:                    ���
���          �        aRet[n,1] = Descri��o da campanha                            ���
��|          �        aRet[n,2] = Quantidade de atendimentos                       ���
����������������������������������������������������������������������������������Ĵ��
��� Uso      � SIGATEC                                                             ���
�����������������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������������
������������������������������������������������������������������������������������*/
Method GetTotalPorCampanha() Class PGONLAtendimento
	Local aRet		:= ::aCampanhas	// Campanhas existentes padr�o
	Local nCntFor	:= 0			// Contador
	
	For nCntFor := 1 To Len( aRet )
		If Empty(aRet[nCntFor][1])
			aRet[nCntFor][1] := STR0003 // "SEM CAMPANHA"
		Else
			aRet[nCntFor][1] := Alltrim(Posicione( "SUO", 1, xFilial( "SUO" ) + aRet[nCntFor][1], "UO_DESC" ))
		EndIf
	Next
	
	If ( Len(aRet) == 0 )
		aRet := {{STR0004,0}} // "SEM INFORMA��O"
	EndIf
Return aRet