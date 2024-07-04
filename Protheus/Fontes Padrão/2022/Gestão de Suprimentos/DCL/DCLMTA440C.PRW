#INCLUDE "rwmake.ch"  

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLMTA440C 
Função para substituir o valid exist('SD3',M->D1_T_DPROV,14) com indice posicional 
para indice com nickname
adaptação da função MTA440C9
@author ANTONIO CORD
@since 01/07/2002
/*/
//-------------------------------------------------------------------
Function DCLMTA440C()  
Local aAreaSB1 := SB1->(GetArea())

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

//Salva a integridade dos Arquivos.
If SuperGetMv("MV_DCLNEW",.F.,.F.)
	
	// NO RAMO DE COMBUSTIVEIS OS PRODUTOS NAO SOFREM BLOQUEIOS DE ESTOQUES
	If SB1->(DBSEEK(XFILIAL()+SC9->C9_PRODUTO)) .AND. Empty(SC9->C9_BLCRED) .AND. SC9->C9_BLEST=="02"
	   a450Grava(1,.F.,.T.)
	EndIf
	
	RestArea(aAreaSB1)
	
EndIf

Return Nil

