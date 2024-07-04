#include "PROTHEUS.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �RET_CBARRA�Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     � Este programa tem como objetivo efetuar os calculos e      ���
���          �retornar os seguintes dados:                                ���
���          � Nosso numero                                               ���
���          � Linha digitavel                                            ���
���          � String com o valor para codigo de barras(uilizado pela     ���
���          �MSBAR)                                                      ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �RetDados  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Gera SE1                        					          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function RetDados()

Local cNosso		:= ""
Local cDigNosso		:= ""
Local NNUM			:= ""
Local cCampoL		:= ""
Local cFatorValor	:= ""
Local cLivre		:= ""
Local cDigBarra		:= ""
Local cBarra		:= ""
Local cParte1		:= ""
Local cDig1			:= ""
Local cParte2		:= ""
Local cDig2			:= ""
Local cParte3		:= ""
Local cDig3			:= ""
Local cParte4		:= ""
Local cParte5		:= ""
Local cDigital		:= ""
Local aRet			:= {}
Local cPrefixo		:= PARAMIXB[1]
Local cNumero		:= PARAMIXB[2]
Local cParcela		:= PARAMIXB[3]
Local cTipo			:= PARAMIXB[4]
Local cBanco		:= PARAMIXB[5]
Local cAgencia		:= PARAMIXB[6]
Local cConta		:= PARAMIXB[7]
Local cDacCC		:= PARAMIXB[8]
Local cNroDoc		:= PARAMIXB[9]
Local nValor		:= PARAMIXB[10]
Local cCart			:= PARAMIXB[11]
Local cMoeda		:= PARAMIXB[12]

DEFAULT nValor := 0

Do case
		
	// Banco do Brasil
	case cBanco == '001'
		
		cAgencia:=Transform(Val(cAgencia),"9999")
		
		cNosso := ""
		NNUM := STRZERO(Val(cNroDoc),11)
		//Nosso Numero
		cDigNosso  := U_CALC_di9(NNUM)
		cNosso     := NNUM + cDigNosso
		
		// campo livre			// verificar a conta e carteira
		//			cCampoL := cNosso+substr(e1_agedep,1,4)+STRZERO(VAL(e1_conta),8)+'18'
		cCampoL := NNUM+cAgencia+StrZero(Val(cConta),8)+cCart
		
		//campo livre do codigo de barra                   // verificar a conta
		If nValor > 0
			cFatorValor  := u_fator()+strzero(nValor*100,10)
		Else
			cFatorValor  := u_fator()+strzero(SE1->E1_VALOR*100,10)
		Endif
		
		cLivre := cBanco+cMoeda+cFatorValor+cCampoL
		
		// campo do codigo de barra
		cDigBarra := U_CALC_5p( cLivre )
		cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)
		
		// composicao da linha digitavel
		cParte1  := cBanco+cMoeda
		cParte1  := cParte1 + SUBSTR(cCampoL,1,5)
		cDig1    := U_DIGIT001( cParte1 )
		cParte2  := SUBSTR(cCampoL,6,10)
		cDig2    := U_DIGIT001( cParte2 )
		cParte3  := SUBSTR(cCampoL,16,10)
		cDig3    := U_DIGIT001( cParte3 )
		cParte4  := " "+cDigBarra+" "
		cParte5  := cFatorValor
		
		cDigital := substr(cParte1,1,5)+"."+substr(cparte1,6,4)+cDig1+" "+;
					substr(cParte2,1,5)+"."+substr(cparte2,6,5)+cDig2+" "+;
					substr(cParte3,1,5)+"."+substr(cparte3,6,5)+cDig3+" "+;
					cParte4+;
					cParte5

		Aadd(aRet,cBarra)
		Aadd(aRet,cDigital)
		Aadd(aRet,cNosso)		

	// CEF
	case cBanco == '104'
		
		cAgencia:=Strzero(Val(cAgencia),4)
		
		cNosso := ""
		NNUM := STRZERO(Val(cNroDoc),11)
		//Nosso Numero
		cDigNosso  := U_CALC_di9(NNUM)
		cNosso     := NNUM + cDigNosso
		
		// campo livre			// verificar a conta e carteira
		//			cCampoL := cNosso+substr(e1_agedep,1,4)+STRZERO(VAL(e1_conta),8)+'18'
		cCampoL := NNUM+cAgencia+StrZero(Val(cConta),8)+cCart
		
		//campo livre do codigo de barra                   // verificar a conta
		If nValor > 0
			cFatorValor  := u_fator()+strzero(nValor*100,10)
		Else
			cFatorValor  := u_fator()+strzero(SE1->E1_VALOR*100,10)
		Endif
		
		cLivre := cBanco+cMoeda+cFatorValor+cCampoL
		
		// campo do codigo de barra
		cDigBarra := U_CALC_5p( cLivre )
		cBarra    := Substr(cLivre,1,4)+cDigBarra+Substr(cLivre,5,40)
		
		// composicao da linha digitavel
		cParte1  := cBanco+cMoeda
		cParte1  := cParte1 + SUBSTR(cCampoL,1,5)
		cDig1    := U_DIGIT001( cParte1 )
		cParte2  := SUBSTR(cCampoL,6,10)
		cDig2    := U_DIGIT001( cParte2 )
		cParte3  := SUBSTR(cCampoL,16,10)
		cDig3    := U_DIGIT001( cParte3 )
		cParte4  := " "+cDigBarra+" "
		cParte5  := cFatorValor
		
		cDigital := substr(cParte1,1,5)+"."+substr(cparte1,6,4)+cDig1+" "+;
					substr(cParte2,1,5)+"."+substr(cparte2,6,5)+cDig2+" "+;
					substr(cParte3,1,5)+"."+substr(cparte3,6,5)+cDig3+" "+;
					cParte4+;
					cParte5

		Aadd(aRet,cBarra)
		Aadd(aRet,cDigital)
		Aadd(aRet,cNosso)		

		
	Otherwise
		Aadd(aRet,"")
		Aadd(aRet,"")
		Aadd(aRet,"")		

Endcase
Return aRet


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC_dig	�Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do digito do nosso numero do Itau                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CALC_dig(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,10)
If auxi > 9 .or. auxi == 0
	auxi := 0
Else
	auxi := 10 - auxi
EndIf

Return(str(auxi,1,0))


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALCDig745�Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do digito do nosso numero do Itau                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CALCDig745(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,10)
If auxi == 10 .or. auxi == 0  .or. auxi == 1
	auxi := 0
Else
	auxi := 10 - auxi
EndIf

//cBase:=cBase+str(Auxi,1,0)

Return(str(auxi,1,0))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC745   �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do digito do nosso numero do City Bank              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CALC745(cVariavel)
Local Auxi := 0, sumdig := 0, nBase := 0

cbase  := cVariavel
lbase  := LEN(cBase)
nBase  := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If nBase == 10
		nBase := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * nBase
	sumdig := SumDig+auxi
	nBase := nBase + 1
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 10 .or. auxi == 1
	auxi := 0
Else
	auxi := 11 - auxi
EndIf

Return(str(auxi,1,0))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC707   �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do digito do nosso numero do                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CALC707(cVariavel)
Local Auxi := 0, sumdig := 0, nBase := 0

cbase  := cVariavel
lbase  := LEN(cBase)
nBase  := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If nBase == 8
		nBase := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * nBase
	sumdig := SumDig+auxi
	nBase := nBase + 1
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0
	auxi := "0"
ElseIf auxi == 1
	auxi := "P"
Else
	auxi := str(11 - auxi,1,0)
EndIf

Return(auxi)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC_5p   �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do digito do nosso numero do                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CALC_5p(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base >= 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 1 .or. auxi >= 10
	auxi := 1
Else
	auxi := 11 - auxi
EndIf

Return(str(auxi,1,0))


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �FATOR		�Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do FATOR  de vencimento para linha digitavel.       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User function Fator()
If Len(ALLTRIM(SUBSTR(DTOC(SE1->E1_VENCTO),7,4))) = 4
	cData := SUBSTR(DTOC(SE1->E1_VENCTO),7,4)+SUBSTR(DTOC(SE1->E1_VENCTO),4,2)+SUBSTR(DTOC(SE1->E1_VENCTO),1,2)
Else
	cData := "20"+SUBSTR(DTOC(SE1->E1_VENCTO),7,2)+SUBSTR(DTOC(SE1->E1_VENCTO),4,2)+SUBSTR(DTOC(SE1->E1_VENCTO),1,2)
EndIf
cFator := STR(1000+(STOD(cData)-STOD("20000703")),4)
//cFator := STR(1000+(SE1->E1_VENCREA-STOD("20000703")),4)
Return(cFator)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �FATOR453  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do FATOR  de vencimento para linha digitavel.       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function fator453()
cFator := SE1->E1_VENCREA - STOD("19971007")
cFator := STR(cFator,4)
return(cFator)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC_di1  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do nosso numero                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CALC_di1(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := STRZERO(VAL(cVariavel),7)
lbase  :=  LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
auxi := 11 - auxi
If auxi == 1 .OR. auxi == 11  .OR. auxi == 10
	auxi := 0
ElseIf auxi == 0
	auxi := 1
EndIf
auxi := str(Auxi,1,0)

Return(auxi)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC_di2  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do nosso numero                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CALC_di2(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := ALLTRIM(cVariavel)
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 10 .or. auxi == 1
	cBase := "1"
Else
	auxi := 11 - auxi
	cBase:=str(Auxi,1,0)
Endif

Return(cBase)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC_di3  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do nosso numero                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CALC_di3(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := STRZERO(VAL(cVariavel),10)
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := sumdig*10
auxi := mod(sumdig,11)
If auxi >= 10
	cBase:=cBase+"0"
ElseIf auxi == 0
	cBase:=cBase+"0"
Else
	cBase:=cBase+str(Auxi,1,0)
Endif

Return(cBase)


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC_di4  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do nosso numero                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CALC_di4(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := STRZERO(VAL(cVariavel),12)
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 10
		base := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 1
	iDig   := iDig-1
EndDo
auxi := int(Sumdig/11)
auxi := 11 - (sumdig - ( auxi * 11 ) )
cBase:=cBase+str(Auxi,1,0)

Return(cBase)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC_di5  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do nosso numero                                     ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CALC_di5(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := STRZERO(VAL(cVariavel),7)
lbase  := LEN(cBase)
base   := 20
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base + 10
	iDig   := iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 10
	auxi:="0"
Else
	auxi := STR(auxi,1,0)
Endif

Return(auxi)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC_di6  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do nosso numero BANCO RURAL (453)                   ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CALC_di6(cVariavel)
Local Auxi := 0, sumdig := 0

sumdig := 0
Auxi   := 0

aPesos := {0,1,9,7,3,1,9,7,3,1,9,7,3,1,9,7,3,1,9,7,3}

For iDig := 1 To LEN(cVariavel)
	auxi   := Val(SubStr(cVariavel, idig, 1)) * aPesos[iDig]
	sumdig := SumDig + auxi
Next iDig

auxi := mod(sumdig,10)

If auxi == 0 .or. auxi >= 10
	cBase := '0'
ElseIf auxi == 1
	cBase := '9'
ElseIf auxi == 2
	cBase := '8'
ElseIf auxi == 3
	cBase := '7'
ElseIf auxi == 4
	cBase := '6'
ElseIf auxi == 5
	cBase := '5'
ElseIf auxi == 6
	cBase := '4'
ElseIf auxi == 7
	cBase := '3'
ElseIf auxi == 8
	cBase := '2'
ElseIf auxi == 9
	cBase := '1'
Else
	cBase := '1'
	MsgBox("Verificar Digito")
EndIf

Return(cBase)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC_di7  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do nosso numero Nossa Caixa                         ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CALC_di7(cVariavel)

cbase := cVariavel
lbase  :=  LEN(cBase)
sumdig := 0
Auxi   := 0
iDig   := lBase
aPesos := {3,1,9,7,3,1,9,7,3,1,9,7,3,1,3,1,9,7,3,1,9,7,3}
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * aPesos[iDig]
	sumdig := SumDig+auxi
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,10)
If auxi = 10
	auxi:="0"
Else
	auxi:=str(10-Auxi,1,0)
Endif

Return(auxi)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC_8P   �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do digito do codigo de BARRAS BANCO RURAL           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CALC_8p(cVariavel)

cbase := cVariavel
lbase  :=  LEN(cBase)
base := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base = 10
		base = 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base := base + 1
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,11)
auxi := 11 - auxi
If auxi = 0 .or. auxi = 1 .or. auxi > 9
	auxi := 1
EndIf

Return(str(auxi,1,0))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DIGIT453  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do digito                                           ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DIGIT453(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	If auxi > 10
		auxi := (auxi-10) + 1
	Endif
	sumdig := SumDig+auxi
	base   := 3 - base
	iDig   := iDig - 1
End
auxi := mod(sumdig,10)
auxi := 10 - auxi
If auxi >= 10 .or. auxi == 0
	auxi := "0"
Else
	auxi := str(Auxi,1,0)
Endif
Return( auxi )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC_di9  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Para calculo do nosso numero do banco do brasil             ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CALC_di9(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
base   := 9
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If base == 1
		base := 9
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * base
	sumdig := SumDig+auxi
	base   := base - 1
	iDig   := iDig-1
EndDo
auxi := mod(Sumdig,11)
If auxi == 10
	auxi := "X"
Else
	auxi := str(auxi,1,0)
EndIf
Return(auxi)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DIGIT001  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Para calculo da linha digitavel do Banco do Brasil          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function DIGIT001(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
cValor:=AllTrim(STR(sumdig,12))
nDezena:=VAL(ALLTRIM(STR(VAL(SUBSTR(cvalor,1,1))+1,12))+"0")
auxi := nDezena - sumdig

If auxi >= 10
	auxi := 0
EndIf
Return(str(auxi,1,0))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC151   �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �// digito 1 e 2 da chave ASBACE					          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CALC151(cVariavel)
Local Auxi := 0, sumdig := 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,10)
If auxi == 0
	auxi := 0
Else
	auxi := 10 - auxi
EndIf

cDig1 := auxi

//Return(str(auxi,1,0))

//��������������������������������������������������������������Ŀ
//�                                                              �
//����������������������������������������������������������������
// digito 2 da chave ASBACE
//User Function CALC_D2(cVariavel)
//Local Auxi := 0, sumdig := 0

cbase  := cVariavel+str(cDig1,1,0)
lbase  := LEN(cBase)
nBase  := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If nBase == 8
		nBase := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * nBase
	sumdig := SumDig+auxi
	nBase := nBase + 1
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 1 .or. auxi == 10
	cDig1 := cDig1+1
	cbase  := cVariavel+str(cDig1,1,0)
	lbase  := LEN(cBase)
	nBase  := 2
	sumdig := 0
	Auxi   := 0
	iDig   := lBase
	While iDig >= 1
		If nBase == 8
			nBase := 2
		EndIf
		auxi   := Val(SubStr(cBase, idig, 1)) * nBase
		sumdig := SumDig+auxi
		nBase := nBase + 1
		iDig:=iDig-1
	EndDo
	auxi := mod(sumdig,11)
	If auxi == 1 .or. auxi == 10
		auxi := 0
	Else
		auxi := 11 - auxi
	EndIf
ElseIf auxi == 0
	auxi := 0
Else
	auxi := 11 - auxi
EndIf
cDig2 := auxi

Return(str(cDig1,1,0)+str(cDig2,1,0))
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �DIGIT151  �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Linha digitavel nossa caixa.    					          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function DIGIT151(cVariavel)
Local Auxi := 0, sumdig := 0
Local nValor	:= 0

cbase  := cVariavel
lbase  := LEN(cBase)
umdois := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * umdois
	sumdig := SumDig+If (auxi < 10, auxi, (auxi-9))
	umdois := 3 - umdois
	iDig:=iDig-1
EndDo
nValor:=sumdig*9
auxi := mod(nvalor,10)

Return(str(auxi,1,0))

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC422   �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Codigo de barras BANCO SAFRA.   					          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function CALC422(cVariavel)
Local Auxi := 0, sumdig := 0, nBase := 0

cbase  := cVariavel
lbase  := LEN(cBase)
nBase  := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	auxi   := Val(SubStr(cBase, idig, 1)) * nBase
	sumdig += auxi
	nBase := nBase + 1
	iDig:=iDig-1
EndDo
auxi := mod(sumdig,11)
If auxi == 0
	auxi := 1
ElseIf auxi == 1
	auxi := 0
Else
	auxi := 11 - auxi
EndIf

Return(str(auxi,1,0))


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �CALC409   �Autor  �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                					          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function CALC409(cVariavel)
Local Auxi := 0, sumdig := 0, nBase := 0

cbase  := cVariavel
lbase  := LEN(cBase)
nBase  := 2
sumdig := 0
Auxi   := 0
iDig   := lBase
While iDig >= 1
	If nBase == 10
		nBase := 2
	EndIf
	auxi   := Val(SubStr(cBase, idig, 1)) * nBase
	sumdig := SumDig+auxi
	nBase := nBase + 1
	iDig:=iDig-1
EndDo
sumdig := sumdig*10
auxi := mod(sumdig,11)
If auxi == 0 .or. auxi == 10
	auxi := 0
EndIf

Return(str(auxi,1,0))



/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Ger_NNumero�Autor �Microsiga           � Data �  02/13/04   ���
�������������������������������������������������������������������������͹��
���Desc.     �Calculo do nosso numero.        					          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � BOLETOS                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function Ger_NNumero(cNumero, cBanco, cAgencia, cConta)
// NUMERO, BANCO, AGENCIA, CONTA

cNosso := ""

do case
	// ITAU
	case cBanco == '341' .AND. ALLTRIM(cAgencia) <> '1248'
		AGE := strzero(val(cAgencia),5)
		CON := substr(cConta,1,5)
		TEZ := '175'
		NNUM := strzero(val(cNumero),8)
		cDigNosso := U_CALC_dig(AGE+CON+TEZ+NNUM)
		cNosso := NNUM+cDigNosso
		
		// bcn
	case cBanco == '291'
		cDigNosso := U_CALC_di5(strzero(val(se1->e1_num),7))
		cNosso := strzero(val(se1->e1_num),7)+cDigNosso
		
		// rural
	case cBanco == '453'
		AGE  := strzero(val(cAgencia),4)
		CON  := '96'
		TEZ  := '00018591'
		NNUM := STRZERO(VAL(cNumero),7)
		cNosso  := U_CALC_di6(AGE+CON+TEZ+NNUM)
		cNosso  := NNUM+cNosso
		
		// Banco Brasil
	case cBanco == '001'
		NNUM := SUBSTR(cNumero,1,11)
		cDigNosso  := U_CALC_di9(NNUM)
		cNosso     := NNUM + cDigNosso
		
		// REAL
	case  cBanco == '275'
		AGE  := "0372"
		CON  := "1727122"
		NNUM := SUBSTR(cNumero,1,13)
		cDigNosso := U_CALC_dig(NNUM+AGE+CON)
		cNosso := NNUM+cDigNosso
endcase
Return(cNosso)


