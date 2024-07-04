#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �HSMA7ROT  �Autor  �Microsiga           � Data �  12/29/11   ���
�������������������������������������������������������������������������͹��
���Desc.     �Ponto de Entrada para incluir a rotina de liberacao na tela ���
���          �de Anamnese (Prontuario)                                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function HSMA7ROT() 
Local aArea	:= getArea()
Local aRot := {}

aRot := {{"Ficha de Tratamento","u_HMA7Ficha",0,02}}

RestArea(aArea)
Return(aRot)          


User Function HMA7Ficha()  
Local aArea		:= getArea()
Local cCodReg	:= ""
                            
FS_PosSx1("HSPM61    01",GCY->GCY_REGGER)
 
//HS_MSGINF("Selecione o or�amento no Plano de tratamento!",STR0029, STR0030)//"Cliente n�o encontrado!","Aten��o", "Valida��o Atualiza��o Or�amento"
//Return()
If Pergunte("HSPM61", .T.)
	cCodReg := MV_PAR01
Else
	RestArea(aArea)
	Return()
EndIf

fs_perfCli(3 , cCodReg)
RestArea(aArea)
Return()
                                 

Static Function FS_PosSx1(cChave, xConteudo)
Local nForSx1 := 0
 
DbSelectArea("SX1")
DbSetOrder(1) // X1_GRUPO + X1_ORDEM           
If DbSeek(cChave)
	If Type("xConteudo") == "A"
		For nForSx1 := 1 To Len(xConteudo)
			RecLock("SX1", .F.)
			&(xConteudo[nForSx1][1]) := xConteudo[nForSx1][2]
			MsUnLock()
		Next
	EndIf
EndIf

Return(Nil)	 