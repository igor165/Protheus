#INCLUDE "rwmake.ch"
      
//-------------------------------------------------------------------
/*/{Protheus.doc} DCLMTA440C 
Libera manualmente estoque para produtos com necessidade de producao.
Adaptação da função Mta450i
@author ANTONIO CORD
@since 01/07/2002
/*/
//-------------------------------------------------------------------
Function DCLMTA450I()  
Local aAreaSB1 := SB1->(GetArea())

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

//Salva a integridade dos Arquivos.
If SuperGetMv("MV_DCLNEW",.F.,.F.) 

	// NO RAMO DE COMBUSTIVEIS OS PRODUTOS NAO SOFREM BLOQUEIOS DE ESTOQUES
	IF SB1->(DbSeek(xFilial()+SC9->C9_PRODUTO)) .And. Empty(SC9->C9_BLCRED) .And. SC9->C9_BLEST=="02"
	   a450Grava(1,.F.,.T.)
	ENDIF
	
	RestArea(aAreaSB1)
	
EndIf
Return Nil

