#Include "PROTHEUS.CH"
#Include "GPER624.CH"

/*/
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun��o    � GPER624  � Autor � Ricardo Berti	                 � Data �04/10/2013���
�����������������������������������������������������������������������������������Ĵ��
���Descri��o �Geracao de TXT sobre Aportes de Caja de Salud -BOLIVIA                ���
���          � 			Dados extraidos a partir do relatorio GPER625			       ���
���          � 		Obs.: Demais funcoes encontram-se no fonte GPER625.PRW 			���
���          � 		ATENCAO-> Sempre incluir dependencia do fonte GPER625.PRW		���
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � GPER624()                                                            ���
�����������������������������������������������������������������������������������Ĵ��
���Parametros�                                                                      ���
�����������������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                             ���
�����������������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL                        ���
�����������������������������������������������������������������������������������Ĵ��
���Programador � Data     � CHAMADO      �  Motivo da Alteracao                     ���
�����������������������������������������������������������������������������������Ĵ��
���Jonathan Glz�06/05/2015�    PCREQ-4256�Se elimina la funcion AjustaSX1, la cual  ���
���            �          �              �realiza la modificacion aldiccionario de  ���
���            �          �              �datos(SX1) por motivo de adecuacion  nueva���
���            �          �              �estructura de SXs para version 12         ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
/*/
Function GPER624()

Local aGetArea	:= GetArea()
Local cPerg		:= "GPR624"
Local nOpca		:= 0
Local aSays		:= {}, aButtons := {} //<== arrays locais de preferencia

Private Titulo	:= STR0001 // "Gera��o do arquivo TXT - Aportes Caja Salud de la Banca Privada"
Private cFilialDe
Private cFilialAte
Private cMesAno
Private cMes
Private cAno
Private cMatDe
Private cMatAte
Private cCustoDe
Private cCustoAte
Private cNomeDe
Private cNomeAte
Private cSit
Private cCat
Private nOrdem
Private cArqNome

Pergunte(cPerg,.F.)

AADD(aSays,STR0002)		//"Este programa gera o arquivo TXT Aportes Caja de Salud de la Banca Privada"

AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
AADD(aButtons, { 1,.T.,{|o| nOpca := 1,IF(gpTudoOK(cPerg),FechaBatch(),nOpca:=0) }} )
AADD(aButtons, { 2,.T.,{|o| FechaBatch() }} )

FormBatch( Titulo, aSays, aButtons )

If nOpca == 1

	Processa({|lEnd| GPR624Proc(),Titulo})		// esta funcao esta' em GPER625

EndIf

RestArea(aGetArea)

Return Nil

/*
���������������������������������������������������������������������������������������
���������������������������������������������������������������������������������������
�����������������������������������������������������������������������������������Ŀ��
���Fun�ao    � gpTudoOK � Autor � Ricardo Berti	                  � Data �02/04/2013���
�����������������������������������������������������������������������������������Ĵ��
���Descri�ao �Validacao dos dados antes de executar o processo						���
���          �		                                                				���
�����������������������������������������������������������������������������������Ĵ��
���Sintaxe   � gpTudoOK(ExpC1)	                                                    ���
�����������������������������������������������������������������������������������Ĵ��
���Parametros� ExpC1: Grupo de pergunte 		                                    ���
�����������������������������������������������������������������������������������Ĵ��
��� Uso      � GPER624                                                              ���
������������������������������������������������������������������������������������ٱ�
���������������������������������������������������������������������������������������
�������������������������������������������������������������������������������������*/
Static Function gpTudoOK(cPerg)

Local lRet	:= .T.
Local cFile	:= AllTrim(mv_par12)

Pergunte(cPerg,.F.)

If Empty(mv_par03)
	Help(" ",1,"XINVMESANO")
	lRet := .F.
EndIf

//�����������������������������������������������������������Ŀ
//�Verifica o Arquivo TXT                                     �
//�������������������������������������������������������������
If lRet .And. File(cFile) .And. !MsgYesNo(STR0003+CRLF+STR0004)	//  "El archivo existe."###"Desea sobrescribir ?"
	lRet := .F.
Endif

Return(lRet)
