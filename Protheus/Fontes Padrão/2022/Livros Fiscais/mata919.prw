#Include "Protheus.Ch"
#Include "Mata919.Ch"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MATA919   � Autor �Sergio S. Fuzinaka     � Data � 10.11.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Rotina de Aglutinacao de Titulos ( DCTF )                   ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   Data   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function MATA919()

Local cPerg	:= "MTA919"  // Pergunta

Private aRotina		:= MenuDef()
Private cCadastro	:= OemToAnsi(STR0007)

Pergunte(cPerg,.F.)

mBrowse(6,1,22,75,"SGH")

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �A919Agl   � Autor � Sergio S. Fuzinaka    � Data � 27.11.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Rotina de Aglutinacao                                       ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A919Agl()

Local aArea 	:= GetArea()
Local aSE2		:= SE2->(GetArea())
Local nSaveSX8  := GetSX8Len()
Local cCodAgl 	:= ""
Local cPerg		:= "MTA919"
Local lGrava	:= .F.
Local cCodRet	:= ""
Local dDtVenc	:= Ctod("")
Local dDtApur	:= Ctod("")

//����������������������������������������������Ŀ
//� Processa a Aglutinacao ds Titulos            �
//������������������������������������������������
If Pergunte(cPerg,.T.)

	cCodAgl	:= GetSX8Num("SGH","GH_CODIGO")
	dDtVenc	:= mv_par01		//Data de Vencimento Real
	cCodRet	:= mv_par02		//Codigo SRF
	dDtApur	:= mv_par03		//Data de Apuracao
	
	dbSelectArea("SE2")
	ProcRegua(LastRec())
	dbSetOrder(3)
	dbSeek(xFilial("SE2")+Dtos(dDtVenc),.T.)
	While !Eof() .And. xFilial("SE2") == SE2->E2_FILIAL .And. SE2->E2_VENCREA == dDtVenc
		If !Empty(SE2->E2_CODRET) .And. SE2->E2_CODRET == cCodRet .And. SE2->E2_TIPO $ MVTAXA
			If Empty(SE2->E2_CODAGL)
				RecLock("SE2",.F.)
				lGrava			:= .T.
				SE2->E2_CODAGL	:= cCodAgl
				MsUnlock()
			Endif
		Endif
		IncProc()
		dbSelectArea("SE2")
		dbSkip()
	Enddo

	//������������������������������Ŀ
	//� Grava o Registro Aglutinador �
	//��������������������������������
	If lGrava
		dbSelectArea("SGH")
		dbSetOrder(1)
		RecLock("SGH",.T.)
		SGH->GH_FILIAL 	:= xFilial("SGH")  
		SGH->GH_CODIGO 	:= cCodAgl				//Codigo Aglutinador
		SGH->GH_DTEMIS	:= dDataBase			//Data de Emissao
		SGH->GH_DTVENC	:= dDtVenc				//Data de Vencimento
		SGH->GH_CODRET	:= cCodRet				//Codigo de Retencao
		SGH->GH_DTAPUR	:= dDtApur				//Data de Apuracao
		MsUnlock()	

		While ( GetSX8Len() > nSaveSX8 )
			ConfirmSX8()
		Enddo
	Else
		MsgAlert(OemToAnsi(STR0009),OemToAnsi(STR0008))
		While ( GetSX8Len() > nSaveSX8 )
			RollBackSX8()
		EndDo
	Endif

Endif

RestArea(aSE2)
RestArea(aArea)

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �A919Del   � Autor � Sergio S. Fuzinaka    � Data � 10.11.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Rotina de Exclusao                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Function A919Del(cAlias,nReg,nOpc)

Local oDlg
Local aArea 	:= GetArea()
Local aSE2		:= SE2->(GetArea())
Local nOpca		:= 2
Local aCpo		:= {"GH_CODIGO","GH_DTEMIS","GH_CODRET","GH_DTVENC","GH_DTAPUR"}
Local aInfo     := {}
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := MsAdvSize() 
Local nGd1      := 2
Local nGd2 		:= 2
Local nGd3 		:= 0
Local nGd4 		:= 0

aObjects := {} 
AAdd( aObjects, {100, 100, .t., .t. } )

aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 } 
aPosObj := MsObjSize( aInfo, aObjects )

nGd1 := 2
nGd2 := 2
nGd3 := aPosObj[1,3]-aPosObj[1,1]
nGd4 := aPosObj[1,4]-aPosObj[1,2]

DEFINE MSDIALOG oDlg TITLE OEMTOANSI(STR0007) FROM nGd1,nGd2 TO nGd3,nGd4 OF oMainWnd PIXEL
EnChoice( cAlias, nReg, nOpc,,,, aCpo, aPosObj[1], , 3 )
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 1,oDlg:END()},{|| nOpca := 2,oDlg:END()})

If nOpca == 1	//Exclusao
	dbSelectArea("SE2") 
	ProcRegua(LastRec())	
	dbSetOrder(3)
	dbSeek(xFilial("SE2")+Dtos(SGH->GH_DTVENC),.T.)
	While !Eof() .And. xFilial("SE2") == SE2->E2_FILIAL .And. SE2->E2_VENCREA == SGH->GH_DTVENC
	
		If SE2->E2_CODAGL == SGH->GH_CODIGO .And. SE2->E2_CODRET == SGH->GH_CODRET .And. SE2->E2_TIPO $ MVTAXA
			RecLock("SE2",.F.)
			SE2->E2_CODAGL := ""
			MsUnlock()
		Endif

		IncProc()	
		dbSelectArea("SE2")
		dbSkip()
	Enddo

	dbSelectArea("SGH")	
	RecLock("SGH",.F.)
	dbDelete()
	MsUnlock()
Endif

RestArea(aSE2)
RestArea(aArea)

Return Nil

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data � 01.09.06 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Utilizacao de menu Funcional                               ���
���          �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �	  1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
     
Private aRotina := {	{ OemToAnsi(STR0001),"AxPesqui"	, 0, 1,0,.F.}	,;		//"Pesquisar"
                    	{ OemToAnsi(STR0003),"A919Agl"	, 0, 3,0,Nil}	,;		//"Aglutinar"
                    	{ OemToAnsi(STR0005),"A919Del"	, 0, 5,0,Nil}	}		//"Excluir"

If ExistBlock("MT919MNU")
	ExecBlock("MT919MNU",.F.,.F.)
EndIf

Return(aRotina)

