#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSMA7ROT  ºAutor  ³Microsiga           º Data ³  12/29/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Ponto de Entrada para incluir a rotina de liberacao na tela º±±
±±º          ³de Anamnese (Prontuario)                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
 
//HS_MSGINF("Selecione o orçamento no Plano de tratamento!",STR0029, STR0030)//"Cliente não encontrado!","Atenção", "Validação Atualização Orçamento"
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