#INCLUDE "Protheus.ch"
#INCLUDE "ATFA300.CH"

// 17/08/2009 - Ajuste para filiais com mais de 2 caracteres.

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA300   �Autor  �Marcos S. Lobo      � Data �  09/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Cadastro de Ap�lices de Seguros                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP - SIGAATF                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function ATFA300()

Local cArqMain		:= "SNB"
Local aAreaATF90	:= GetArea()

Private cCadastro	:= STR0001 ///"Ap�lices de Seguro"

dbSelectArea("SX2")
dbSetOrder(1)
If dbSeek(cArqMain)
	cCadastro := X2Nome()
Endif

Private aRotina := MenuDef()

dbSelectArea(cArqMain)
MsSeek(xFilial(cArqMain))
mBrowse( 6, 1,22,75,cArqMain,,,,,,)

RestArea(aAreaATF90)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AF300Vis  �Autor  �Marcos S. Lobo      � Data �  09/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Visualiza��o de Ap�lice de Seguros                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP - SIGAATF                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AF300Vis(cAlias,nReg,nOpc)

If Empty(cAlias)
	cAlias := Alias()
Endif

If Empty(nReg)
	nReg := (cAlias)->(Recno())
Endif

AxVisual(cAlias,nReg,nOpc)

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AF300Inc  �Autor  �Marcos S. Lobo      � Data �  09/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inclus�o de Ap�lice de Seguros                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP - SIGAATF                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/                            
Function AF300Inc(cAlias,nReg,nOpc)

Local lNBDADOS	:= .F.
Public cNBDADOS 	:= ""

If Empty(cAlias)
	cAlias := Alias()
Endif

If Empty(nReg)
	nReg := (cAlias)->(Recno())
Endif

lNBDADOS := X3Usado("NB_DADOS")

If AxInclui(cAlias,nReg,nOpc,,,,,,IIf(lNBDADOS,"LoadNBDADOS(3)",),,,,.T.) == 1
	
	If lNBDADOS
		cSNECHAVE := SNB->(NB_APOLICE+NB_CODSEG)
		If Empty(MEUMEMO("SNE",cSNECHAVE,cNBDADOS,3))									//// GRAVACAO DO CONTEUDO DO MEMO
			MsgInfo(STR0007+ALLTRIM(SNB->NB_APOLICE)+" !",STR0008)
		Endif
	Endif
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AF300Alt  �Autor  �Marcos S. Lobo      � Data �  09/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Altera��o de Ap�lice de Seguros                             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP - SIGAATF                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AF300Alt(cAlias,nReg,nOpc)

Local lNBDADOS 	:= .F.
Public cNBDADOS := ""

If Empty(cAlias)
	cAlias := Alias()
Endif

If Empty(nReg)
	nReg := (cAlias)->(Recno())
Endif
            
lNBDADOS 	:= X3Usado("NB_DADOS")

If AxAltera(cAlias,nReg,nOpc,,,,,,If(lNBDADOS,"LoadNBDADOS(3)",),If(lNBDADOS,"LoadNBDADOS(4)",),,,,.T.) == 1
	dbSelectArea("SN1")
	dbSetOrder(5)
	If MsSeek(xFilial("SN1")+SNB->(NB_APOLICE+NB_CODSEG),.F.)
		While !SN1->(Eof()) .and. SN1->(N1_FILIAL+N1_APOLICE+N1_CODSEG) == xFilial("SN1")+SNB->(NB_APOLICE+NB_CODSEG)
			RecLock("SN1",.F.)
			Field->N1_DTVENC  := SNB->NB_DTVENC
			Field->N1_CSEGURO := SNB->NB_CSEGURO
			SN1->(MsUnlock())
			SN1->(dbSkip())
		Enddo
	Endif
	
	If lNBDADOS
		cSNECHAVE := SNB->(NB_APOLICE+NB_CODSEG)
		If Empty(MEUMEMO("SNE",cSNECHAVE,cNBDADOS,4))									//// ALTERACAO DO CONTEUDO DO MEMO
			MsgInfo(STR0009+ALLTRIM(SNB->NB_APOLICE)+" !",STR0008)
		Endif
	Endif
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �AF300Del  �Autor  �Marcos S. Lobo      � Data �  09/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Exclus�o de Ap�lice de Seguros                              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP - SIGAATF                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AF300Del(cAlias,nReg,nOpc)

Local cMsg 	  := ""
Local aAreaNB := {}
Local lNBDADOS := .F.

If Empty(cAlias)
	cAlias := Alias()
Endif

If Empty(nReg)
	nReg := (cAlias)->(Recno())
Endif

lNBDADOS := X3Usado("NB_DADOS")

dbSelectArea(cAlias)
dbGoTo(nReg)
aAreaNB := GetArea()

If AxVisual(cAlias,nReg,nOpc) == 1
	
	dbSelectArea("SN1")
	dbSetOrder(5)
	If MsSeek(xFilial("SN1")+SNB->(NB_APOLICE+NB_CODSEG),.F.)
		cMsg := STR0010 ///"Deseja retirar o seguro destes bens e excluir a ap�lice ?"
		
		If !MsgYesNo(cMsg,STR0011)///"Aten��o ! Bens relacionados a esta ap�lice."
			cMsg := STR0012+ALLTRIM(SNB->NB_APOLICE)+STR0013+ALLTRIM(SNB->NB_CSEGURO)+STR0014 //// "A ap�lice " # " da Cia. de Seguros " # " foi mantida."
			MsgInfo(cMsg)
			RestArea(aAreaNB)			/// SE NAO CONFIRMOU A LIMPEZA DOS BENS
			Return						/// RESTAURA AREA E CANCELA
		Endif
		
		While !SN1->(Eof()) .and. SN1->(N1_FILIAL+N1_APOLICE+N1_CODSEG) == xFilial("SN1")+SNB->(NB_APOLICE+NB_CODSEG)
			RecLock("SN1",.F.)
			Field->N1_APOLICE := ""
			Field->N1_CODSEG  := ""
			Field->N1_DTVENC  := CTOD("  /  /  ")
			Field->N1_CSEGURO := ""
			SN1->(MsUnlock())
			SN1->(dbSkip())
		Enddo
	Endif
	
	If lNBDADOS
		cSNECHAVE := SNB->(NB_APOLICE+NB_CODSEG)
		If !MEUMEMO("SNE",cSNECHAVE,"",5)									//// DELECAO DO CONTEUDO DO MEMO
			MsgInfo(STR0015+ALLTRIM(SNB->NB_APOLICE)+" !",STR0008) ///"Nao foi poss�vel excluir os DADOS ADICIONAIS da apolice " # "Contate o Administrador"
		Endif
	Endif
	
	RecLock(cAlias,.F.)
	(cAlias)->(dbDelete())
	(cAlias)->(MsUnLock())
Endif

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA300   �Autor  �Microsiga           � Data �  09/26/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Sugere o vencimento para a Ap�lice de Seguro com base na    ���
���          �data de in�cio de vig�ncia.                                 ���
�������������������������������������������������������������������������͹��
���Uso       � AP - SIGAATF                                               ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function AF300Venc(dNBDTINI)

Local dNBDTVENC := dDataBase

If Empty(dNBDTINI)
	dNBDTINI := dDataBase
Endif

dNBDTVENC := CTOD(substr(DTOC(dNBDTINI),1,6)+SUBSTR(ALLTRIM(STR(Year(dNBDTINI)+1)),3,2))

M->NB_DTVENC := dNBDTVENC

Return(dNBDTVENC)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o	 � MEUMEMO  � Autor � Marcos S. Lobo   	  � Data   � 02/10/03 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Funcao para Leitura e Gravacao de campo MEMO Virtual		  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � MEUMEMO(cTable,cChave,cString,nOpc)						  ���
���       	 � cTable 	= Alias da Tabela onde sera gravado o MEMO		  ���
���       	 � cChave	= Chave Unica para identificacao do MEMO 		  ���
���       	 � cString	= Conteudo Integral do Memo a ser gravado 		  ���
���       	 � nOpc		= Opcao a ser executada (2=Vis/3=Inc/4=Alt/5=Exc) ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 �De acordo com o parametro nOpc					 		  ���
���       	 �nOpc == 3/4 (Inc/Alt)		Retorno = Char   (Chave do MEMO)  ���
���       	 �nOpc == 2   (Visual)		Retorno = Char   (Texto do MEMO)  ���
���       	 �nOpc == 5   (Exclusao)	Retorno = Logico (.T./.F. Exclui) ���
�������������������������������������������������������������������������Ĵ��
���Uso		 � SIGAATF		 											  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
*/
Function MEUMEMO(cTable,cChave,cString,nOpc)

Local cAliasOld := Alias()
Local nOrdX3	:= SX3->(IndexOrd())
Local nRecX3	:= SX3->(Recno())

Local uRet      := " "
Local cMEMO		:= ""

Local cPrefCPO			:= ""
Local nStr				:= 1

If Empty(cTable)							//// DEVE CONTER O NOME DA TABELA A SER GRAVADA
	cTable := Alias()
Endif

If Empty(cTable) .or. Empty(cChave)
	If nOpc == 5
		Return .F.
	Else
		Return("")
	Endif
Endif

dbSelectArea("SX3")
dbSetOrder(1)
If !MsSeek(cTable)
	Alert(STR0016+cTable+STR0017) ///"Tabela " # " nao encontrada no Dicionario !"
	If nOpc == 5
		Return .F.
	Else
		Return("")
	Endif
Endif

cPrefCPO		:= Left(SX3->X3_CAMPO,At("_",SX3->X3_CAMPO))						/// PREFIXO DOS CAMPOS PARA A TABELA
cCpoFILIAL		:= cPrefCPO+"FILIAL"												/// NOME DO CAMPO FILIAL
cCpoKEY	  		:= cPrefCPO+"KEY"													/// NOME DO CAMPO QUE CONTERA A CHAVE
cCpoSEQUEN		:= cPrefCPO+"SEQUEN"												/// NOME DO CAMPO COM A SEQUENCIA
cCpoMEMO		:= cPrefCPO+"MEMO"													/// NOME DO CAMPO COM O CONTEUDO DO TEXTO
nTam			:= Len(CriaVar(cCpoMEMO))											/// TAMANHO DO CAMPO COM O CONTEUDO DO TEXTO

//verifica se o campo existe na tabela
nOpc    := If(nOpc == NIL,3,nOpc)

If Select(cTable) == 0
	If !ChkFile(cTable)
		MsgStop(cTable+STR0018)///" - Falha de abertura."
		If nOpc == 5
			Return .F.
		Else
			Return("")
		Endif
	EndIf
EndIf

DbSelectArea(cTable)
DbSetOrder(1)
cFilial	:= xFilial(cTable)
MsSeek(cFilial+cChave)

cInFILIAL := &(cTable+"->"+cCpoFILIAL)						//// VARIAVEL COM O CONTEUDO DA FILIAL POSICIONADA
cInKEY	  := &(cTable+"->"+cCpoKEY)						//// VARIAVEL COM O CONTEUDO DO KEY POSICIONADO
cInMEMO	  := &(cTable+"->"+cCpoMEMO)						//// VARIAVEL COM O CONTEUDO TEXTO POSICIONADO
cInSEQUEN := &(cTable+"->"+cCpoSEQUEN)						//// VARIAVEL COM O CONTEUDO DA SEQUENCIA POSICINADA

cChave  := PADR(cChave,Len(cInKEY))

If nOpc == 2												/// LEITURA DOS REGISTROS (RETORNA O CONTEUDO)
	uRet	:= ""
	cString := ""
	While !Eof() .And. cFilial+cChave == cInFILIAL+cInKEY
		cString += cInMEMO
		(cTable)->(	dbSkip())
		cInFILIAL := &(cTable+"->"+cCpoFILIAL)
		cInKEY	  := &(cTable+"->"+cCpoKEY)
		cInMEMO	  := &(cTable+"->"+cCpoMEMO)
		cInSEQUEN := &(cTable+"->"+cCpoSEQUEN)
	End
	uRet := cString
ElseIf nOpc == 5											/// SE FOR EXCLUSAO APAGA OS REGISTROS (RETORNA .T./.F.)
	// Excluir campo MEMO
	uRet := .F.
	While !Eof() .And. cFilial+cChave == cInFILIAL+cInKEY
		RecLock(cTable,.F.)
		DbDelete()
		MsUnLock()
		(cTable)->(	dbSkip())
		cInFILIAL := &(cTable+"->"+cCpoFILIAL)
		cInKEY	  := &(cTable+"->"+cCpoKEY)
		cInMEMO	  := &(cTable+"->"+cCpoMEMO)
		cInSEQUEN := &(cTable+"->"+cCpoSEQUEN)
	End
	uRet:=.T.
Else														/// CASO CONTR�RIO DEVE FAZER GRAVACAO (INCLUSAO/ALTERACA)
	uRet := ""
	cString		:= AllTrim(cString)							/// LIMPA OS ESPACOS EM BRANCO A DIREITA E A ESQUERDA NO TEXTO
	nLenStr		:= Len(cString)								/// TAMANHO DO STRING DE TEXTO
	nStepNum	:= 1										/// NUMERO DO STEP PARA IDENTIFICACAO DA SEQUENCIA
	nTCpoSEQUEN := Len(cInSEQUEN)							/// TAMANHO DO CAMPO SEQUEN (PARA O STRZERO)
	
	For nStr := 1 to nLenStr Step nTam
		cMEMO 		:= Substr(cString,nStr,nTam)
		cSEQUEN		:= STRZERO(nStepNum,nTCpoSEQUEN)
		dbSelectArea(cTable)
		dbSetOrder(1)
		If MsSeek(cFilial+cChave+cSEQUEN) .and. nOpc == 4 /// SE ENCONTRAR E FOR ALTERACAO (PARA NO CASO DE PROBLEMAS NAO PERDER O CONTEUDO)
			If cMEMO <> &(cTable+"->"+cCpoMEMO)		   /// SO REGRAVA SE O TEXTO FOI ALTERADO
				RecLock(cTable,.F.)
				&("Field->"+cCpoFILIAL) := cFilial
				&("Field->"+cCpoKEY)	 := cChave
				&("Field->"+cCpoSEQUEN)	 := cSEQUEN
				&("Field->"+cCpoMEMO)	 := cMEMO
				(cTable)->(MsUnlock())
			Endif
		Else											   /// SE FOR INCLUSAO NAO ALTERA... SEMPRE ADICIONA (PARA NAO PERDER O CONTEUDO NO CASO DE PROBLEMAS)
			RecLock(cTable,.T.)
			&("Field->"+cCpoFILIAL) := cFilial
			&("Field->"+cCpoKEY)	 := cChave
			&("Field->"+cCpoSEQUEN)	 := cSEQUEN
			&("Field->"+cCpoMEMO)	 := cMEMO
			(cTable)->(MsUnlock())
		Endif
		nStepNum++
	Next
	
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	//// NO CASO DE ALTERACAO VERIFICA SE HOUVE DELECAO DE LINHAS - ELIMINANDO AS EXCEDENTES
	/////////////////////////////////////////////////////////////////////////////////////////////////////
	If nOpc <> 3											/// SE NAO FOR INCLUSAO
		DbSelectArea(cTable)
		cSEQUEN		:= STRZERO(nStepNum,nTCpoSEQUEN)
		If MsSeek(cFilial+cChave+cSEQUEN,.F.)
			While !(cTable)->(Eof()) .And. cFilial+cChave == &(cTable+"->("+cCpoFILIAL+"+"+cCpoKEY+")")
				RecLock(cTable,.f.)
				(cTable)->(dbDelete())
				(cTable)->(MsUnlock())
				(cTable)->(dbSkip())
			EndDo
		Endif
	Endif
	uRet := cChave
Endif

SX3->(dbSetOrder(nOrdX3))
SX3->(dbGoTo(nRecX3))
DbSelectArea(cAliasOld)

Return uRet

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �LoadNBDADO�Autor  �Marcos S. Lobo      � Data �  10/03/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �Bloco executado na AxInclui/AxAltera (Dentro da Transacao)  ���
���          �para obter o texto contido no campo memo virtual            ���
�������������������������������������������������������������������������͹��
���Uso       � AP - Campos Memo em Cadastro do tipo Enchoice (AxXXXXXX)   ���
���          � Cadastro de Apolices de Seguros - SIGAATF                  ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function LoadNBDADOS(nOpc)

Local cReturn := ""

If nOpc == 3 .or. Empty(nOpc)
	cReturn	:= "cNBDADOS := M->NB_DADOS"
ElseIf nOpc == 4
	If Empty(M->NB_DADOS)
		cReturn	:= 'M->NB_DADOS := CriaVar("NB_DADOS",.T.) '
	Endif
Endif

Return(&cReturn)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �ATFA300   �Autor  �Microsiga           � Data �  10/09/03   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function X3Usado(cNomeCpo)

Local lEmUso	:= .F.
Local nOrdX3P	:= 1
Local nRecX3P	:= 1

If Empty(cNomeCpo)
	Return(.F.)
Endif

nOrdX3P := SX3->(IndexOrd())
nRecX3P := SX3->(Recno())

dbSelectArea("SX3")
dbSetOrder(2)
If MsSeek(cNomeCpo,.F.)
	If X3Uso(SX3->X3_USADO)
		lEmUso := .T.
	Endif
Endif

SX3->(dbSetOrder(nOrdX3P))
SX3->(dbGoTo(nRecX3P))

Return(lEmUso)

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Ana Paula N. Silva     � Data �30/11/06 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados     ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()
Local aRotina := {}
	aAdd(aRotina,{ STR0002	, "AxPesqui"  					, 0, 1 , ,.F.})		//"Pesquisar"
	aAdd(aRotina,{ STR0003	, "AF300Vis"					, 0, 2})		//"Visualizar"
	aAdd(aRotina,{ STR0004	, "AF300Inc"					, 0, 3})		//"Incluir"
	aAdd(aRotina,{ STR0005	, "AF300Alt"					, 0, 4})		//"Alterar"
	aAdd(aRotina,{ STR0006	, "AF300Del"					, 0, 5})		//"Excluir"
Return(aRotina)