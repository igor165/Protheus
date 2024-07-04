// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 02     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "PROTHEUS.CH"
#INCLUDE "OFIIA600.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIIA600 º Autor ³ Luis Delorme       º Data ³  23/10/02   º±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³ IMPORTACAO SCANIA - CANCELAMENTO DE PEDIDOS EM BO         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA600
*********************

If !MsgYesNo(STR0001)
	Return
Endif

set delete on

processa({|| _OFIIA600()})

Return

Static Function _OFIIA600()
*************************

Local aErro := {}

Private lMT235G1 := existblock("MT235G1")

DBSelectArea("VE4")
DBSetOrder(1)
DbSeek(xFilial("VE4"))

DbSelectArea("VIY")
DBSetOrder(1)
DBSeek( xFilial("VIY") )

ProcRegua( VIY->(RecCount()) )

aErro := {}
while !VIY->(Eof()) .And. VIY->VIY_FILIAL == xFilial("VIY")
                           
	IncProc(STR0008)

	DBSelectArea("VEI")
	DBSetOrder(2)
	if !(DBSeek(xFilial("VEI")+VE4->VE4_PREFAB+strzero(val(VIY->VIY_PEDIDO),10)+"/"+Right(strzero(VIY->VIY_ANOPED,4),2)))
		if !(DBSeek(xFilial("VEI")+VE4->VE4_PREFAB+strzero(val(VIY->VIY_PEDIDO),13)))
			aAdd(aErro,STR0002 + VIY->VIY_PEDIDO + "/"+ strzero(VIY->VIY_ANOPED,4) + STR0003)
			DbSelectArea("VIY")
			DBSkip()
			loop
		endif
	endif
	if Year(VEI->VEI_DATSC7) != VIY->VIY_ANOPED
		aAdd(aErro,STR0002 + VIY->VIY_PEDIDO + "/"+ strzero(VIY->VIY_ANOPED,4) + STR0004)
		DbSelectArea("VIY")
		DBSkip()
		loop
	endif			
	// achou
	DBSelectArea("VE4")
	DBSetOrder(1)
	DbSeek(xFilial("VE4"))
	DBSelectArea("SB1")
	DbSetOrder(7)
	DBSeek(xFilial("SB1")+VE4->VE4_GRUITE+STRZERO(VAL(VIY->VIY_CODITE),7))
	DBSelectArea("SC7")  
	DBSetOrder(4)
	if !(DBSeek(xFilial("SC7")+SB1->B1_COD+VEI->VEI_NUM))
		aAdd(aErro,STR0002 + VIY->VIY_PEDIDO + "/"+ strzero(VIY->VIY_ANOPED,4) + STR0005)
		DbSelectArea("VIY")
		DBSkip()
		loop
	endif			
	DBSelectArea("SB2")
	DBSetOrder(1)
	// tudo posicionado... comecando a baixar o item
	nResiduo := VIY->VIY_QTDCAN
	if SC7->C7_QUANT > SC7->C7_QUJE
		if SC7->C7_QUANT - SC7->C7_QUJE < nResiduo 
			nResiduo := SC7->C7_QUANT - SC7->C7_QUJE
		endif
		
		DbSelectArea("SC7")
		Begin Transaction
					
			RecLock("SC7",.F.)
			Replace C7_RESIDUO with "S"
			DBSelectArea("SB2")
			DBSetOrder(1)
			if !(DBSeek(xFilial("SB2")+SB1->B1_COD+SC7->C7_LOCAL))

				CriaSb2( SC7->C7_PRODUTO,SC7->C7_LOCAL)
				aAdd(aErro,STR0006 + SB1->B1_GRUPO+"/"+SB1->B1_CODITE +STR0007+SC7->C7_LOCAL+" !")
				DbSelectArea("VIY")
				DBSkip()
			
			Else
			
				RecLock("SB2",.F.)
				if B2_SALPEDI > nResiduo
					Replace B2_SALPEDI With B2_SALPEDI - nResiduo
				else
					Replace B2_SALPEDI With 0
				endif

			endif			

		End Transaction
	endif
		
	If lMT235G1
		ExecBlock("MT235G1",.F.,.F.)
	EndIf
	
	DbSelectArea("VIY")
	DBSkip()

enddo

return