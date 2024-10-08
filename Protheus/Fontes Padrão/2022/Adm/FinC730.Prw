#INCLUDE "finc730.ch"
#INCLUDE "PROTHEUS.CH"

/*/
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o    � FINC730  � Autor � Wagner Mobile         � Data � 31-07-2002 ���
���������������������������������������������������������������������������Ĵ��
���Descri��o � Consulta comparativa entre Valores Orcados X Reais Anual     ���
���������������������������������������������������������������������������Ĵ��
���Sintaxe   � Finc730()                                                    ���
���������������������������������������������������������������������������Ĵ��
���Retorno   � Nenhum                                                       ���
���������������������������������������������������������������������������Ĵ��
���Uso       � Generico                                                     ���
���������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                       ���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/
Function Finc730()

FinC720(.T.)

Return .T.

/*/
��������������������������������������������������������������������������������
��������������������������������������������������������������������������������
����������������������������������������������������������������������������Ŀ��
���Program   � Finc730Tmp  � Autor � Wagner Mobile Costa   � Data � 31.07.02 ���
����������������������������������������������������������������������������Ĵ��
���Descri��o � Monta temporario para apresentacao dos valores por natureza   ���
���          � Anual                                                         ���
����������������������������������������������������������������������������Ĵ��
���Sintaxe   � Finc730Tmp                                                    ���
����������������������������������������������������������������������������Ĵ��
���Retorno   � .T.                                                           ���
����������������������������������������������������������������������������Ĵ��
���Parametros�                                                               ���
�����������������������������������������������������������������������������ٱ�
��������������������������������������������������������������������������������
���������������������������������������������������������������������������������
/*/
Function Finc730Tmp(oDlg, mv_pargf)

LOCAL aNiveis  	:= {}
LOCAL aQuebR 	:= {}
LOCAL aQuebO 	:= {}
LOCAL aQuebA 	:= {}
LOCAL nLaco		:= 0
LOCAL cSituaca  := ""

//�������������������������������������������Ŀ
//� L� a formata��o do c�digo das naturezas   �
//���������������������������������������������
cMascNat := GetMV("MV_MASCNAT")
cMapa    := "123456789"
cSituaca := MV_PAR09

//����������������������������������������������������������������Ŀ
//� Esta matriz informa em que posi��es ser�o feitas as quebras.   �
//� 1-Byte inicial da quebra, 2-Quantidade de caracteres.          �
//������������������������������������������������������������������
aNiveis  := {}

//������������������������������������������������������������������������Ŀ
//� Esta matriz armazena as chaves de quebra e os totalizadores parciais.  �
//��������������������������������������������������������������������������
aQuebR := {}    // Realizado
aQuebO := {}    // Or�ado
For nLaco := 1 to len( cMascNat )
	nByte := Val( Substr( cMascNat,nLaco,1 ) )
	If nByte > 0
		AAdd( aNiveis  , { Val(Left(cMapa,1)) , nByte} )
		AAdd( aQuebR   , { "", 0,0,0,0,0,0,0,0,0,0,0,0 } )
		AAdd( aQuebO   , { "", 0,0,0,0,0,0,0,0,0,0,0,0 } )
		AAdd( aQuebA   , { "", 0,0,0,0,0,0,0,0,0,0,0,0 } )
		cMapa := Subst(cMapa,nByte+1,Len(cMapa)-nByte)
	Endif
EndFor

Processa( { || aTotais := 	Fin730Cria(@cArqTmp, @cIndex1, @cIndex2, @cIndex3, .F.,;
							aNiveis, aQuebR, aQuebO, aQuebA,,, cSituaca) })

Finc720Res(oDlg,aTotais,.T.,mv_pargf)
							
If oResumo = Nil
	oResumo	:= 	TWBrowse():New( 2,2,aPosObj[1,4],120,,;
				{"",	MesExtenso(1),MesExtenso(2),MesExtenso(3),MesExtenso(4),;
						MesExtenso(5),MesExtenso(6),MesExtenso(7),MesExtenso(8),;
						MesExtenso(9),MesExtenso(10),MesExtenso(11),MesExtenso(12)},;
						{40,60,60,60,60,60,60,60,60,60,60,60,60},oFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
Endif

oResumo:SetArray(aTotais[1])
oResumo:bLine := { || aTotais[1][oResumo:nAT] }

If Len(aTotais[2]) = 0
	HELP (" ",1,"SEMDADOS")
	Return
Endif

@ 122, 002 	To aPosObj[1,3] - 15,aPosObj[1,4] LABEL STR0001 OF oFolder:aDialogs[4]; //"Quebras por Natureza"
			COLOR CLR_HBLUE PIXEL

If oQuebras = Nil
	oQuebras	:= 	TWBrowse():New( 130,4,aPosObj[1,4]-10,aPosObj[1,3]-aPosObj[1,1]-160,,;
					{"",	MesExtenso(1),MesExtenso(2),MesExtenso(3),MesExtenso(4),;
							MesExtenso(5),MesExtenso(6),MesExtenso(7),MesExtenso(8),;
							MesExtenso(9),MesExtenso(10),MesExtenso(11),MesExtenso(12)},;
					{75,50,50,50,50,50,50,50,50,50,50,50,50},oFolder:aDialogs[4],,,,,,,,,,,,.F.,,.T.,,.F.,,,)
Endif
oQuebras:SetArray(aTotais[2])
oQuebras:bLine := { || aTotais[2][oQuebras:nAT] }

Return
