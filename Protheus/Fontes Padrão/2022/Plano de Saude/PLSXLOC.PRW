#INCLUDE "PLSXLOC.ch"
#include "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ PLSCHKDIG ³ Autor ³ Luciano Aparecido     ³ Data ³ 16.04.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida o Digito verificador do campo "RG/Ced Estr."		   ³±±
±±³			 ³ quando o campo Tipo Documento seja igual a "CI"			   ³±±
±±³			 ³      -Verifica el digito de control de la Cedula- 		   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SigaPLS  (LOCALIZACAO URUGUAI)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ (cNumRG) - Número da Cédula de Identidade                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSCHKDIG(cNumRG, lShowMsg) 

Local nPos1		:= 0  
Local nPos2 	:= 0
Local nPos3 	:= 0
Local nPos4 	:= 0
Local nPos5 	:= 0
Local nPos6 	:= 0
Local nPos7 	:= 0
Local cDigito 	:= ""
Local cR1  		:= ""
Local cR2  		:= ""
Local cR3  		:= ""
Local cR4  		:= ""
Local cR5  		:= ""
Local cR6  		:= ""
Local cR7   	:= ""
Local nDigCalc  := 0
Local nTotal	:= 0
Local nTotalR	:= 0   
Local lRet      := .F.
Default cNumRG 	:= Space(1)
Default lShowMsg:= .T.

// Valida se tem 8 Digitos o Numero fornecido
If Len(Alltrim(cNumRg)) <> 8 .or. Val(cNumRg) == 0
	If lShowMsg
		MsgAlert(STR0001,STR0002) //"O número RG/Ced Estr. informado está incorreto para o Tipo de Documento escolhido!"###"Número Inválido !"
	EndIf
	Return lRet 
Endif 

// Desmenbla o Numero fornecido para validação
nPos1	:= Val(Substr(cNumRG,1,1))
nPos2	:= Val(Substr(cNumRG,2,1))
nPos3	:= Val(Substr(cNumRG,3,1))
nPos4	:= Val(Substr(cNumRG,4,1))
nPos5	:= Val(Substr(cNumRG,5,1))
nPos6	:= Val(Substr(cNumRG,6,1))
nPos7	:= Val(Substr(cNumRG,7,1))
cDigito := Substr(cNumRG,8,1) 

//Quando o dígito é 0 entende como 10
If Upper(cDigito) $ "0"
	cDigito :="10"
Endif

//Calculo dos 7 primeiros digitos de acordo com a regra
cR1 	:= StrZero(nPos1 * 2,2)  
cR2 	:= StrZero(nPos2 * 9,2)
cR3 	:= StrZero(nPos3 * 8,2)
cR4 	:= StrZero(nPos4 * 7,2)
cR5 	:= StrZero(nPos5 * 6,2)
cR6 	:= StrZero(nPos6 * 3,2)
cR7 	:= StrZero(nPos7 * 4,2) 

// Soma Todas as 2ª posiçoes do cR calculado
nTotal	:= Val(Substr(cR1,2,1)) + Val(Substr(cR2,2,1)) + Val(Substr(cR3,2,1)) + Val(Substr(cR4,2,1))
nTotal  += Val(Substr(cR5,2,1)) + Val(Substr(cR6,2,1)) + Val(Substr(cR7,2,1))
        
//Pega a nTotal = Picture 99 (Pega a 1ª posição do nTotal e soma 1 e atribue 0 a 2ª posição)
nTotalR := Val(STR(Val(Substr(Alltrim(StrZero(nTotal,2)),1,1))+1)+"0")

// Calcula o Digito correto
nDigCalc := nTotalR - nTotal

//Verifica se o Digito Informado é igual ao calculado	
If Val(cDigito) == nDigCalc 
	lRet := .T.
Else
	If lShowMsg
		MsgAlert(STR0003,STR0004) //"O Número RG/Ced Estr. informado tem o dígito verificador inválido !"###"Dígito Invalido !"
	EndIf
Endif
	
Return lRet 

