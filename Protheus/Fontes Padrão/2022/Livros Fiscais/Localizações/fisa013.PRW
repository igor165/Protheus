#INCLUDE "PROTHEUS.CH"
#INCLUDE "FISA013.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FISA013  ³ Autor ³ Ivan Haponczuk         ³ Data ³ 04.11.09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro de Amarracoes tipos comprovante.                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FATURAMENTO                                                 ³±±
±±³          ³ LOCALIZACAO PERU                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FISA013 

	Local nlX     := 0
	Local alRelac := {}
	
	aAdd(alRelac,{"NF   ","01",""})
	aAdd(alRelac,{"NCC  ","07",""})
	aAdd(alRelac,{"NCP  ","07",""})
	aAdd(alRelac,{"NCI  ","07",""})	
	aAdd(alRelac,{"NCE  ","07",""})		
	aAdd(alRelac,{"NDC  ","08",""})
	aAdd(alRelac,{"NDP  ","08",""}) 
	aAdd(alRelac,{"NDE  ","08",""}) 	
	aAdd(alRelac,{"NDI  ","08",""})	


	
	dbSelectArea("CCL")
	dbSetOrder(2)
	
	For nlX:=1 To Len(alRelac) 
		If dbSeek(xFilial()+alRelac[nlX,2]) 
			alRelac[nlX,3] := CCL->CCL_CODIGO
		EndIf
	Next nlX
	
	CCL->(dbCloseArea())
	
	dbSelectArea("CCM")              
	dbSetOrder(1)
	
	For nlX:=1 To Len(alRelac)
		If !Empty(alRelac[nlX,3])
			If !dbSeek(xFilial()+alRelac[nlX,1]+alRelac[nlx,3])
				If Reclock("CCM",.T.)
					CCM->CCM_FILIAL := xFilial("CCM")
					CCM->CCM_COD42  := alRelac[nlX,1]
					CCM->CCM_CODGOV := alRelac[nlX,3]
					MsUnlock()
				EndIf
			EndIf 
		EndIf
	Next nlX
	
	CCM->(dbGoTop())

	AxCadastro("CCM",STR0001,".T.",".T.")//Cadastro de Amarração Tipos de Comprovante

Return