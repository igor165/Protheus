#include "eadvpl.ch"
#include "_pmspalm.ch"

// fun��es para codificao e decodificao de base64
// - n�o segue totalmente o RFC 2045
// - n�o otimizada


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �B64Code   �Autor  �Adriano Ueda        � Data �  27/01/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     �Converte uma string utilizando o algoritmo de base 64       ���
�������������������������������������������������������������������������͹��
���Parametros�cString - string a ser codificada                           ���
�������������������������������������������������������������������������͹��
���Retorno   �cBuffer - cString codificada                                ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function B64Code(cString)
	Local cBuffer := ""
	Local i := 1
	
	While (i < Len(cString))
		cBuffer += B64CodGroup(Substr(cString, i, 3))	
		i := i + 3
	End	
Return cBuffer


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �B64Decode �Autor  �Adriano Ueda        � Data �  27/01/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     �Decodifica uma string em base 64 para o texto original      ���
�������������������������������������������������������������������������͹��
���Parametros�cString - string a ser decodificada                         ���
�������������������������������������������������������������������������͹��
���Retorno   �cBuffer - cString decodificada                              ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function B64Decode(cString)
	Local cBuffer := ""
	Local i := 1
	Local cTemp := ""
	
	//alert(len(cString))
	
	While (i < Len(cString))
		cTemp := B64DecGroup(Substr(cString, i, 4))
		cBuffer += cTemp
		i += 4
		//alert(Str(Asc(Substr(cTemp, 1))) + Str(Asc(Substr(cTemp, 2))) + Str(Asc(Substr(cTemp, 3))))
		//alert(Str(Len(ctemp)) + " * " + Str(i))
	End
Return cBuffer


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �B64CodGrou�Autor  �Adriano Ueda        � Data �  27/01/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     �Converte uma string de tamanho 3 caracteres em 4 octetos em ���
���          �base 64                                                     ���
�������������������������������������������������������������������������͹��
���Parametros�cGroup - string de 3 caracteres a ser codificada            ���
�������������������������������������������������������������������������͹��
���Retorno   �cBuffer - string contendo os 4 octetos representando cGroup ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function B64CodGroup(cGroup)
	Local cBuffer := ""
	Local aOut    := {0, 0, 0, 0}
	Local aInput  := {" ", " ", " "}

	If Len(cGroup) < 3
		cGroup := PadR2(cGroup, 3, Chr(0))
	EndIf

	aInput[1] := Asc(Substr(cGroup, 1, 1))
	aInput[2] := Asc(Substr(cGroup, 2, 1))
	aInput[3] := Asc(Substr(cGroup, 3, 1))

	//Alert("i1: " + Str(aInput[1]))
	//Alert("i2: " + Str(aInput[2]))
	//Alert("i3: " + Str(aInput[3]))
	//Alert("i4: " + Str(aInput[4]))
				
	aOut[1] := Shr(aInput[1], 2)
	aOut[2] := Shr(Shl(aInput[1], 6), 2) + Shr(aInput[2], 4)
	aOut[3] := Shr(Shl(aInput[2], 4), 2) + Shr(aInput[3], 6)
	aOut[4] := Shr(Shl(aInput[3], 2), 2)

	//Alert("i1: " + Str(aOut[1]))
	//Alert("i2: " + Str(aOut[2]))
	//Alert("i3: " + Str(aOut[3]))
	//Alert("i4: " + Str(aOut[4]))
	
	cBuffer := B64GetChar(aOut[1] + 1) + B64GetChar(aOut[2] + 1) +;
	           B64GetChar(aOut[3] + 1) + B64GetChar(aOut[4] + 1)
Return cBuffer


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �B64GetChar�Autor  �Adriano Ueda        � Data �  27/01/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna um caracter no alfabeto de base 64 a partir de um   ���
���          �numero inteiro positivo, maior que zero ou menor igual a 64 ���
�������������������������������������������������������������������������͹��
���Parametros�nCode - numero inteiro positivo > 0 e <= 64                 ���
�������������������������������������������������������������������������͹��
���Retorno   �cChar - caracter correspondente ao nCode na tabela da       ���
���          �base 64                                                     ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function B64GetChar(nCode)
	Local cChar := "="
	
	If nCode > 0 .And. nCode <= 64
		cChar := Substr(B64Table(), nCode, 1)
	Else
		cChar := "="
	EndIf
Return cChar


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �B64DecGrou�Autor  �Adriano Ueda        � Data �  27/01/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     �Decodificada um string de 4 octetos de base 64 em uma string���
���          �de 3 caracteres                                             ���
�������������������������������������������������������������������������͹��
���Parametros�cGroup - uma string de 4 octetos a ser convertidos          ���
�������������������������������������������������������������������������͹��
���Retorno   �cBuffer - a string decodifica a partir de cGroup            ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function B64DecGroup(cGroup)
	Local cBuffer := ""            // armazena a string resultante
	Local aInput  := {0, 0, 0, 0}  // armazena os valores numericos de cada octeto
	Local aOut    := {0, 0, 0}     // armazena os tres valores resultantes

	If Len(cGroup) == 4
		aInput[1] := B64GetValue(Substr(cGroup, 1, 1))
		aInput[2] := B64GetValue(Substr(cGroup, 2, 1))
		aInput[3] := B64GetValue(Substr(cGroup, 3, 1))
		aInput[4] := B64GetValue(Substr(cGroup, 4, 1))
	EndIf

	aOut[1] := Shl(aInput[1], 2) + Shr(aInput[2], 4)
	aOut[2] := Shl(aInput[2], 4) + Shr(aInput[3], 2)
	aOut[3] := Shl(aInput[3], 6) + aInput[4]    // NESTE PONTO, sem o Abs(), aOut[3] == -1
  
	//alert(Str(aOut[1]) + " " + Str(aOut[2]) + " " + Str(aOut[3]))

	cBuffer := Chr(aOut[1]) + Chr(aOut[2]) + Chr(aOut[3])
Return cBuffer


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �B64GetValu�Autor  �Adriano Ueda        � Data �  27/01/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     �Retorna o valor numerico de um caracter, utilizando o alfa- ���
���          �beto de base 64.                                            ���
�������������������������������������������������������������������������͹��
���Parametros�cChar - caracter correspondente ao codigo na tabela de      ���
���          �base 64                                                     ���
�������������������������������������������������������������������������͹��
���Retorno   �i - retorna 0 se o caracter nao existe no alfabeto, caso    ���
���          �contr�rio, retorna o codigo correspondente                  ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function B64GetValue(cChar)
	Local i := 0
	Local cDecTable := B64Table()
	
	For i := 1 To Len(cDecTable)
		If Substr(cDecTable, i, 1) == cChar
			Return i - 1
		EndIf
	Next
Return i


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �B64Table  �Autor  �Adriano Ueda        � Data �  27/01/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     �Armazena o alfabeto de base 64, contendo todos os caracteres���
���          �permitidos para uso.                                        ���
�������������������������������������������������������������������������͹��
���Parametros�Nenhum                                                      ���
�������������������������������������������������������������������������͹��
���Retorno   �O alfabeto inteiro, na forma de uma unica string.inaria     ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function B64Table()
Return "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Shr       �Autor  �Adriano Ueda        � Data �  27/01/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     �Emula uma operacao de right shift nao aritmetico, utilizando���
���          �o limite de 8 bits por default.                             ���
�������������������������������������������������������������������������͹��
���Parametros�nOp1 - operando a ser deslocado (inteiro positivo)          ���
���          �nOp2 - operando, indica a quantidade de bits a ser deslocada���
���          �(nao considera o caso de nOp2 ser maior que nBound)         ���
���          �nBound - limite esquerdo para qual o shift sera executado   ���
���          �(inteiro positivo)                                          ���
�������������������������������������������������������������������������͹��
���Retorno   �nRes - o numero resultante da operacao right shift          ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Shr(nOp1, nOp2, nBound)
	Local nRes  := 0
	Local nBits := 256
	
	Default nBound := 8
	
	nBits := Pow2(2, nBound)

	nOp1 := nOp1 - Int(nOp1 / nBits) * nBits  // arredonda o operador para 1 byte
	nRes := Int(nOp1 / Pow2(2, nOp2))         // executa o right shift
	nRes := nRes - Int(nRes / nBits) * nBits  // arredonda o resultado para o limite de 1 byte
Return nRes


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Shl       �Autor  �Adriano Ueda        � Data �  27/01/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     �Emula uma operacao de left shift nao aritmetico, utilizando ���
���          �o limite de 8 bits por default.                             ���
�������������������������������������������������������������������������͹��
���Parametros�nOp1 - operando a ser deslocado (inteiro positivo)          ���
���          �nOp2 - operando, indica a quantidade de bits a ser deslocada���
���          �(nao considera o caso de nOp2 ser maior que nBound)         ���
���          �(inteiro positivo)                                          ���
���          �nBound - limite esquerdo para qual o shift sera executado   ���
�������������������������������������������������������������������������͹��
���Retorno   �nRes - o numero resultante da operacao left shift           ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Shl(nOp1, nOp2, nBound)
	Local nRes  := 0
	Local nBits := 256
	
	Default nBound := 8
	
	nBits := Pow2(2, nBound)

	nOp1 := nOp1 - Int(nOp1 / nBits) * nBits  // arredonda o operador para 1 byte
	nRes := Int(nOp1 * Pow2(2, nOp2))         // executa o left shift
	nRes := nRes - Int(nRes / nBits) * nBits  // arredonda o resultado para o limite de 1 byte
Return nRes


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �Pow2      �Autor  �Adriano Ueda        � Data �  27/01/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     �Emula uma operacao de exponenciacao                       - ���
�������������������������������������������������������������������������͹��
���Parametros�nBase - base                                                ���
���          �nExp - expoente                                             ���
�������������������������������������������������������������������������͹��
���Retorno   �o caracter convertido a partir da representacao binaria     ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function Pow2(nBase, nExp)
	Local i := 1
	Local nRes := 1
	
	For i := 1 To nExp
		nRes *= nBase	
	Next
Return nRes


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Funcao    �PadR2     �Autor  �Adriano Ueda        � Data �  27/01/2005 ���
�������������������������������������������������������������������������͹��
���Desc.     �Emula a funcao PadR() do Advpl                              ���
�������������������������������������������������������������������������͹��
���Retorno   �a string preenchinda ate ter nLength caracteres             ���
�������������������������������������������������������������������������͹��
���Uso       � Palm                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function PadR2(cString, nLength, cChar)
	Local cBuffer := ""
	Default cChar := " "
	
	If Len(cString) < nLength
		cBuffer += (cString + Space(nLength - Len(cString)))
	Else
		cBuffer := cString
	EndIf
Return cBuffer