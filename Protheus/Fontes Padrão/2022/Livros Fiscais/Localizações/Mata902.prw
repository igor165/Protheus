#INCLUDE "Mata902.ch"
#Include "FIVEWIN.Ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MATA902   �Autor  �Leandro M Santos    � Data �  28/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Rotina para anulacao de Documento Pre Impresso              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function MATA902

PRIVATE aRotina := MenuDef()

If SF3->(FieldPos("F3_DOCPRE")) == 0
	MsgStop(STR0009) 
	Return .F.
Else              
	SIX->(DbSeek('SF36'))
	If SIX->(FOUND()) .And. !("F3_FILIAL+F3_DOCPRE" $ STRTRAN(Upper(SIX->CHAVE)," "))
		MsgStop(STR0010)      //"Indice 6 del SF3 erroneo"
		Return .F.
	ElseIf !SIX->(FOUND())
		MsgStop(STR0011) //"Indice 6 del SF3 no encontrado"
		Return .F.
	Endif
Endif		


//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
PRIVATE cCadastro := OemToAnsi(STR0006) //"Anulacao de Pre Impresso"
//��������������������������������������������������������������Ŀ
//� Endereca a funcao de BROWSE                                  �
//����������������������������������������������������������������
mBrowse( 6, 1,22,75,"SF3")

Return
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ax902Inclui�Autor �Leandro M Santos    � Data �  28/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Inclui a anulacao de um documento pre impresso              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ax902Inclui(cAlias,nReg,nOpc)
Local nOpca, aAcho

aAcho:={"F3_DOCPRE",;
		  "F3_OBSERV"}

dbSelectArea(cAlias)
nOpca := AxInclui(cAlias,nReg,nOpc,aAcho)
RecLock(cAlias,.F.)
SF3->F3_DTCANC := dDataBase
SF3->F3_ENTRADA:= dDataBase
MsUnLock()

Return nOpca
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ax902Altera�Autor �Leandro M Santos    � Data �  28/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Altera dados da anulacao de documento pre impresso, mas so- ���
���          �mente para os criados pela Ax902Inclui                      ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ax902Altera(cAlias,nReg,nOpc)
Local nOpca, aAcho

aAcho:={"F3_DOCPRE",;
		 "F3_OBSERV"}

dbSelectArea(cAlias)
If ! Empty(SF3->F3_NFISCAL)
	MsgAlert(OemToAnsi(STR0007)) //"Registro nao pode sofre alteracoes"
Else
	nOpca := AxAltera(cAlias,nReg,nOpc,aAcho)
	RecLock(cAlias,.F.)
	SF3->F3_DTCANC := dDataBase
	SF3->F3_ENTRADA:= dDataBase
	MsUnLock()
EndIf	

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �Ax902Deleta�Autor �Leandro M Santos    � Data �  28/08/01   ���
�������������������������������������������������������������������������͹��
���Desc.     �Deleta a anulacao do documento pre impresso, mas somente    ���
���          �para os criados pela Ax902Inclui                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP5                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Ax902Deleta(cAlias,nReg,nOpc)
Local oDlg, nOpcA:=0
Private aTELA[0][0],aGETS[0]

dbSelectArea(cAlias)
If !SoftLock( cAlias )
	Return
EndIf	
If ! Empty(SF3->F3_NFISCAL) .Or. Empty(SF3->F3_DOCPRE)
	MsgAlert(OemToAnsi(STR0008)) //"Regitro nao pode ser eliminado"
	Return .F.
Endif

aAcho:={"F3_DOCPRE",;
		  "F3_OBSERV"}

DEFINE MSDIALOG oDlg TITLE cCadastro FROM 9,0 TO 28,80 OF oMainWnd
nOpcA:=EnChoice( cAlias, nReg, nOpc,,,,aAcho)
nOpca := 1
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| nOpca := 2,oDlg:End()},{|| nOpca := 1,oDlg:End()})

If nOpcA == 2
	Begin Transaction
		dbSelectArea( cAlias )
		RecLock(cAlias,.F.,.T.)
		dbDelete( )
	End Transaction	
Else
	MsUnlock( )
End
dbSelectArea( cAlias )
Return

/*/
���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Marco Bianchi         � Data �01/09/2006���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Utilizacao de menu Funcional                               ���
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
���          �		1 - Pesquisa e Posiciona em um Banco de Dados           ���
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
     
Private aRotina := {	{ OemToAnsi(STR0001),"AxPesqui"		, 0 , 1 , 0 , .F.},;	//"Pesquisar"
                    	{ OemToAnsi(STR0002),"AxVisual"		, 0 , 2 , 0 , NIL},;		//"Visualizar"
                     { OemToAnsi(STR0003),"Ax902Inclui"	, 0 , 3 , 0 , NIL},;		//"Incluir"
                     { OemToAnsi(STR0004),"Ax902Altera"	, 0 , 4 , 0 , NIL},;		//"AlTerar"
                     { OemToAnsi(STR0005),"Ax902Deleta"	, 0 , 5 , 0 , NIL} }		//"Excluir"

If ExistBlock("MT902MNU")
	ExecBlock("MT902MNU",.F.,.F.)
EndIf

Return(aRotina)
