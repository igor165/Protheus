#include "Protheus.ch"
#include "APDM020.CH"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � APDM020  � Autor � Eduardo Ju            � Data � 28.09.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Geracao Automatica do Mapa de Conhecimento                 ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDM020(void)                                              ���
�������������������������������������������������������������������������Ĵ��
���Uso       � SIGAAPD                                                    ���
�������������������������������������������������������������������������Ĵ��
���            ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL           ���
�������������������������������������������������������������������������Ĵ��
���Programador �Data      �BOPS       �Motivo da Alteracao                ���
�������������������������������������������������������������������������Ĵ��
���Cecilia Car.�04/07/2014�TPZWF1     �Incluido o fonte da 11 para a 12 e ���
���            �          �           � efetuada a limpeza.               ���
���Emerson Camp�25/08/2014�TQHHI4     �Ajustado o bot�o confirmar e cance-���
���            �          �           �las para que funcione corretamente ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Function APDM020()
Local aSays			:= {}
Local aButtons		:= {} 						//<== arrays locais de preferencia
Local nOpca
Local oDlg
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}
Local bSet15		:= { || NIL }
Local bSet24		:= { || NIL }

Private cCadastro 	:= OemToAnsi(STR0001)	//"Gera��o Autom�tica do Mapa"
Private nSavRec		:= 0

Pergunte("APDM20",.F.)

/*/
��������������������������������������������������������������Ŀ
� Monta as Dimensoes dos Objetos         					   �
����������������������������������������������������������������/*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]		:= (aAdvSize[5]/100) * 35	//horizontal
aAdvSize[6]		:= (aAdvSize[6]/100) * 55	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize		:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord		:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*25), (((aObjSize[1,4])/100)*55) }	//1,3 Vertical /1,4 Horizontal

SetaPilha()

DEFINE FONT oFont NAME "Arial" SIZE 0,-11 BOLD
DEFINE MSDIALOG oDlg TITLE cCadastro FROM  aAdvSize[7],20 TO aAdvSize[6]-50,700  OF oMainWnd PIXEL

	@ aGdCoord[1]+7,aGdCoord[2]	GROUP oGroupCalc TO (aGdCoord[3]/1.2)+5,aGdCoord[4]+5  LABEL "" OF oDlg PIXEL
	oGroupCalc:oFont:=oFont
	@ aGdCoord[1]+20,aGdCoord[2]+4 Say OemToAnsi( STR0002 ) Size 240,07 Pixel Font oFont Color CLR_BLUE
	@ aGdCoord[1]+32,aGdCoord[2]+4 Say OemToAnsi( STR0003 ) Size 240,07 Pixel Font oFont Color CLR_BLUE

	aButtons	:=	{;
					{"Perguntas"  ,{ || Pergunte("APDM20",.T. ) },STR0015,STR0015};
					}

	oDlg:bSet15 := { || nOpca 	:= 1, oDlg:End() }
	bSvSet15 := SetKey( 15 , oDlg:bSet15 )
	oDlg:bSet24 := { || nOpca 	:= 0 , oDlg:End() }
	bSvSet24 := SetKey( 24 , oDlg:bSet24 )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg , oDlg:bSet15 , oDlg:bSet24 , NIL , aButtons )

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//����������������������������������������������������������������
If nOpca == 1
	Processa({|lEnd| APD020Processa(),OemToAnsi(STR0001)}) //"Gera��o Autom�tica do Mapa"
EndIf

dbSelectArea("RD0")	//Pessoas/Participantes
dbSelectArea(1)

dbSelectArea("RBI")	//Habilidades do Funcionario
dbSetOrder(1)

dbSelectArea("RBJ")	//Competencia x Habilidade
dbSetOrder(1)

dbSelectArea("RBO")	//Cadastro Mapa de Conhecimento
dbSetOrder(1)

dbSelectArea("RBP")	//Mapa de Conhecimento x Avaliados
dbSetOrder(1)

dbSelectArea("RBQ")	//Habilidades do Participante
dbSetOrder(1)

Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �APD020Proc� Autor � Eduardo Ju            � Data � 29.09.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Processamento da Geracao do Mapa                           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDM020(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAAPD                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function APD020Processa()

Local cCodAdo		:=""
Local cMapa			:= ""
Local cCriterio		:= ""
Local nIntegra		:= 0
Local cCodVis		:=""
Local cRdtDescDet	:=""
Local aRD0Crit		:={}
Local aLogCriterio 	:={}
Local nx
Local aOfusca		:= If(FindFunction('ChkOfusca'), ChkOfusca(), { .T., .F. }) //[2]Ofuscamento
Local aFldRel		:= Iif( aOfusca[2], FwProtectedDataUtil():UsrNoAccessFieldsInList( {"RD0_NOME"} ), {} )
Local lOfusca		:= Len(aFldRel) > 0

//��������������������������������������������������������������Ŀ
//� Carregando as Perguntas 									 �
//����������������������������������������������������������������
cMapa		:= mv_par01	//Codigo do Mapa a ser gerado aos Participantes
cCriterio	:= mv_par02	//Filtro por Criterio
nIntegra	:= mv_par03	//Considera as Habilidades do Funcionario

//���������������������������������������������������������������Ŀ
//� Avaliar Visao do Mapa                                         �
//�����������������������������������������������������������������
dbSelectArea("RBO")	//Cadastro Mapa de Conhecimento
dbSetOrder(1)
If RBO->(DbSeek(xFilial("RBO")+cMapa))
	cCodVis:=RBO->RBO_VISAO
EndIf
//���������������������������������������������������������������Ŀ
//� Avaliar todos os participantes(RD0)                           �
//�����������������������������������������������������������������
dbSelectArea("RD0")
dbSetorder(1)
//���������������������������������������������������������������Ŀ
//� Seleciona os participante do Criterio e Visao                 �
//�����������������������������������������������������������������
Proc2BarGauge(;
					{ || aRD0Crit:=aClone(APDParCrit(cCriterio, cCodVis,@cRdtDescDet)) },;		//Acao a ser Executada
					STR0008,; //"Selecionando os registros"					//Titulo do Dialogo
					NIL,;																		//Mensagem para a 1a. BarGauge
					NIL,;
					.T.,;
					.T.,;
					.T.,;
					.T.;
			  )

//���������������������������������������������������������������Ŀ
//� Impress�o dos participantes selecionado                       �
//�����������������������������������������������������������������
If !Empty(aRD0Crit).and.(ascan(aRD0Crit,{|X|!Empty(x[2])})<>0)
	If MsgYesNo( STR0009 )//"Deseja visualiar os registros selecionado"
		aAdd( aLogCriterio , STR0010) //"Filial Participante                        Nome                                "
		aAdd( aLogCriterio , " --     ------       ----------------------------------------------------------" )
		For nX :=1 to Len(aRD0Crit)
		    If Empty(aRD0Crit[nX,2])
		       Loop
		    Endif
			RD0->( dbgoto(aRD0Crit[nX,4]) )
			/*/
			��������������������������������������������������������������Ŀ
			�Obtem as Informacoes do RD0            					   �
			����������������������������������������������������������������/*/
			aAdd( aLogCriterio , " "+RD0->RD0_FILIAL+"     "+RD0->RD0_CODIGO+"       "+If(lOfusca, Replicate('*',30), RD0->RD0_NOME) )

	    Next nRD0CLoop
		MsAguarde( { || fMakeLog( { aLogCriterio } , { STR0011 + cRdtDescDet} , NIL , .T. , FunName() , NIL , "G" , "L" , NIL , .F. ) } , STR0011 ) //"Registros selecionados pelo Criterio "
	EndIF

	//���������������������������������������������������������������Ŀ
	//� Gravacao dos MAPAS para os participantes selecionado			  �
	//�����������������������������������������������������������������
	If MsgYesNo(STR0012 )//"Confirma grava�ao para os participantes"
		Proc2BarGauge(;
							{ || APD020Save(aRD0Crit,cMapa,nIntegra) },;		//Acao a ser Executada
							STR0013,;//"Gravando os registros"					//Titulo do Dialogo
							NIL,;												//Mensagem para a 1a. BarGauge
							NIL,;
							.T.,;
							.T.,;
							.T.,;
							.T.;
					  )
	EndIf
Else
	MsgInfo(STR0014) //"Nenhum registro encontrado"
EndIf
MsgInfo(OemToAnsi(STR0005))		//Fim do Processamento
Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �APD020Save� Autor � Marcos Alves          � Data � 29.07.07 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Grava Mapa para os participante							  ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAAPD                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function APD020Save(aRD0Crit,cMapa,nIntegra)
Local nX
Local cCodAdo
Local cCodMen

For nX :=1 to Len(aRD0Crit)
    If Empty(aRD0Crit[nX,2])
       Loop
    Endif
	RD0->( dbgoto(aRD0Crit[nX,4]) )
	/*/
	��������������������������������������������������������������Ŀ
	�Obtem as Informacoes do RD0            					   �
	����������������������������������������������������������������/*/
	cCodAdo	:=	RD0->RD0_CODIGO 	//Codigo do Participante/Avaliado
	cCodMen	:=	RD0->RD0_CODMEN		//Codigo do Mentor

	//���������������������������������������������������������������Ŀ
	//� Verifica se o Participante ja esta com Plano cadastrado       �
	//�����������������������������������������������������������������
    dbSelectArea("RBP")
    dbSetorder(4) //	RBP_FILIAL+RBP_CODADO+RBP_CODMAP+RBP_VERSAO
    If !dbSeek(xFilial("RBP")+cCodado+cMapa+"0")
		RecLock("RBP",.T.)
		Replace RBP_FILIAL With xFilial("RBP")
		Replace RBP_CODMAP With cMapa
		Replace RBP_CODADO With cCodado
		Replace RBP_CODDOR With cCodMen
		Replace RBP_VERSAO With "0"
		Replace RBP_STATUS With "1"
		Replace RBP_AUTOR  With "1"
		RBP->(MsUnlock())
		If nIntegra == 1
       		CheckRBI(cMapa,cCodado)
       	EndIf
	EndIf
Next nX
Return Nil

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �CheckRBI  � Autor � Eduardo Ju            � Data � 29.09.05 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Verifica se considera Habilidades do Funcionario           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � APDM020(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � SIGAAPD                                                    ���
�������������������������������������������������������������������������Ĵ��
�����������������������������������������������������������������������������
����������������������������������������������������������������������������*/
Function CheckRBI(cMapa,cCodAdo)

Local cMatric	:= "" 	//Matricula do Funcionario
Local cHabil	:= ""
Local cCompet	:= ""
Local aArea 	:= GetArea()

DbSelectArea("RDZ")
DbSetOrder(2)

If !( RDZ->(dbSeek(xFilial("RDZ")+cCodAdo)) )
   	Return Nil
EndIf

While !RDZ->(Eof()) .And. RDZ->RDZ_CODRD0 == cCodAdo

	cMatric:= Substr(RDZ->RDZ_CODENT, FWGETTAMFILIAL+1, 15)

	DbSelectArea("SRA")
	DbSetOrder(1)

	If SRA->(dbSeek(xFilial("SRA")+cMatric)) .And. SRA->RA_SITFOLH <> "D"
		Exit
	EndIf

	RDZ->(dbSkip())

EndDo

DbSelectArea("RBI")
DbSetOrder(1)

If !( RBI->(dbSeek(xFilial("RBI")+cMatric)) )
	Return Nil
EndIf

While !RBI->(Eof()) .And. RBI->RBI_MAT == cMatric

	cHabil := RBI->RBI_HABIL

	DbSelectArea("RBJ")
	DbSetOrder(2)

	If !( RBJ->( dbSeek(xFilial("RBJ")+cHabil) ) )
		RBI->(Dbskip())
		Loop
	Endif

	cCompet := RBJ->RBJ_CODCOM

	DbSelectArea("RDM")
	DbSetOrder(1)

	If !( RDM->( dbSeek(xFilial("RBM")+cCompet) )) .Or. !(RDM->RDM_TIPO$"2/3")// Tipos de competencias do Mapa 2 - Mostra com Edicao; 3-Visualizacao
	 	RBI->(dbSkip())
	    Loop
	Endif

	RecLock("RBQ",.T.)
		Replace RBQ_FILIAL 	With xFilial("RBQ")
		Replace RBQ_CODMAP 	With cMapa
		Replace RBQ_CODADO 	With cCodAdo
		Replace RBQ_VERSAO 	With "0"
		Replace RBQ_CODCOM 	With cCompet
		Replace RBQ_ITECOM 	With RBJ->RBJ_ITECOM
		Replace RBQ_HABIL  	With RBJ->RBJ_HABIL
		Replace RBQ_ESCALA	With RBJ->RBJ_ESCALA
		Replace RBQ_ITEESC	With RBI->RBI_ITESCA
		Replace RBQ_STATUS 	With "1"
		Replace RBQ_AUTOR  	With "1"
	RBQ->(MsUnlock())

	RBI->(dbSkip())

EndDo

RestArea( aArea )

Return Nil
