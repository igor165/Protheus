// ######################################################################################
// Projeto: BI Library
// Modulo : Foundation Classes and Functions
// Fonte  : BIFunctions.prw
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao  
// -----------+-------------------+------------------------------------------------------
// 15.04.2003   BI Development Team
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"
#include "bifunctions.ch"



                            
/*-------------------------------------------------------------------------------------
@function cBIStr(xValue, lMacro)
Converte um valor de qualquer tipo em String.
@param xValue - Qualquer valor que queira se converter em String.
@param lMacro - Converte o valor de entrada em uma macro do AdvPl.
@return - String resultante da conversão.
--------------------------------------------------------------------------------------*/
function cBIStr(xValue, lMacro)
	local cRet := ""
	local nInd
	local cValType := valType(xValue)

	default lMacro := .f.
	
	do case
		case cValType == "C" .or. cValType == "M"
			cRet := xValue
			if lMacro 
				if .not. (left(cRet, 1) $ "{'" +'"' .and. right(cRet, 1) $ "}'" +'"')
					if left(cRet, 4) != 'ctod'
						cRet := strTran(cRet, "'", "'+chr(39)+'")
						cRet := strTran(cRet, chr(13), "'+chr(13)+'")
						cRet := strTran(cRet, chr(10), "'+chr(10)+'")
						cRet := "'" + strTran(cRet, '"', "'+chr(34)+'") + "'"
					endif                                        
				endif
			endif
		case cValType == "N"
			cRet := allTrim(str(xValue))
		case cValType == "D"
			if lMacro 
				cRet := "ctod(" + chr(34) + dtoc(xValue) + chr(34) + ")"
			else
				cRet := dtoc(xValue)
			endif
		case cValType == "L"
			cRet := if(xValue, "T", "F" )
		case cValType == "A"
			if lMacro 
				cRet := "{"
				for nInd := 1 to len(xValue)
					cRet := cRet + cBIStr(xValue[nInd], lMacro) + iif(nInd = len(xValue), "", ",")
				next
				cRet := cRet + "}"
			else
				for nInd := 1 to len(xValue)
					cRet := cRet + cBIStr(xValue[nInd], lMacro) + CRLF
				next
			endif
		case cValType == "B"
			cRet := cBIStr(eval(xValue), lMacro)
		otherwise     
			if lMacro
				cRet := "NIL"
			else
				cRet := ""
			endif
	endcase
return cRet

/*-------------------------------------------------------------------------------------
@function nBIVal(xValue)
Converte qualquer tipo de argumento para um valor Numérico.
@param xValue - Qualquer valor que queira se converter em Numérico.
@return - Numérico resultante da conversão.
--------------------------------------------------------------------------------------*/
function nBIVal(xValue)
	local nRet := NIL

	if valType(xValue) == "U"
		nRet := 0
	elseif valType(xValue) == "D"
		nRet := val(dtos(xValue))
	elseif valType(xValue) == "L"
		nRet := iif(xValue, 1, 0)
	elseif valType(xValue) == "C"
		nRet := val(xValue)   
	elseif valType(xValue) == "N"
		nRet := xValue
	endif
return nRet

/*-------------------------------------------------------------------------------------
@function cBIStr2Hex(cValue)
Converte a string de ASC para hexadecimal.
@param cValue - String que queira se converter em Hexa.
@return - String com valores hexadecimais resultante da conversão.
--------------------------------------------------------------------------------------*/
function cBIStr2Hex(cValue)
	local cRet := "", nAux, nInd
	    
	for nInd := 1 to len(cValue)
		nAux := asc(substr(cValue, nInd, 1))
		if nAux > 255
			nAux := 32
		endif
		cRet += cBIInt2Hex(nAux,2)
	next

return cRet

/*-------------------------------------------------------------------------------------
@function cBIHex2Str(cValue)
Converte uma sequencia de hexadecimal para asc.
@param cValue - String hexa que queira se converter em ASC.
@return - String com caracteres ASC resultante da conversão.
--------------------------------------------------------------------------------------*/
function cBIHex2Str(cValue)
	local cRet := "", nAux, nInd
	
	for nInd := 1 to len(cValue) step 2
		nAux := nBIHex2Int(substr(cValue, nInd, 2))
		if nAux < 32
			nAux := 255
		endif
		cRet += chr(nAux)
	next

return cRet

/*-------------------------------------------------------------------------------------
@function cBIInt2Hex(nValue, nSize)
Converte da base decimal para base hexadecimal.
@param nValue - Valor numérico que queira se converter em Hexa.
@param nSize - Tamanho do resultado preenchido com zeros 'a esquerda.
@return - String com valor hexadecimal resultante da conversão.
--------------------------------------------------------------------------------------*/
function cBIInt2Hex(nValue, nSize)
	local nResto, cResto := ''
	default nSize := 0
	nValue := int(nValue)

	while nValue > 0 
		nResto := nValue % 16
		do case
			case nResto == 10
				cResto := 'A' + cResto
			case nResto == 11
				cResto := 'B' + cResto
			case nResto == 12
				cResto := 'C' + cResto
			case nResto == 13
				cResto := 'D' + cResto
			case nResto == 14
				cResto := 'E' + cResto
			case nResto == 15
				cResto := 'F' + cResto
			otherwise
				cResto := str(nResto, 1) + cResto
		endcase           
		nValue := int(nValue / 16)
	end            
	nSize := max(nSize, len(cResto))
return (padl(cResto, nSize, "0"))

/*-------------------------------------------------------------------------------------
@function nBIHex2Int(nValue)
Converte da base hexadecimal para base decimal.
@param cValue - String hexadecimal a converter em decimal numérico.
@return - Valor numérico decimal resultante da conversão.
--------------------------------------------------------------------------------------*/
function nBIHex2Int(cValue)               
	local nInd, nPotencia := 0, nVal, nRet := 0, cDig

	for nInd := len(cValue) to 1 step -1
		cDig := substr(cValue, nInd, 1)
		do case
			case cDig == "A"
				nVal := 10 
			case cDig == "B"
				nVal := 11 
			case cDig == "C"
				nVal := 12 
			case cDig == "D"
				nVal := 13 
			case cDig == "E"
				nVal := 14 
			case cDig == "F"
				nVal := 15 
			otherwise
				nVal := nBIVal(cDig)
		endcase           
		nRet += nVal * (16 ** nPotencia) 
		nPotencia++
	end            
return (nRet)

/*-------------------------------------------------------------------------------------
@function cBIMakeID()
Gera um ID único. (Leva no mínimo 1 segundo para ser executada)
@return - ID numérico único.
--------------------------------------------------------------------------------------*/
function cBIMakeID()
	local cRet
	
	sleep(1000)
	cRet := cBIInt2Hex(year(msdate()) - 1900, 2) + ;
			cBIInt2Hex(month(msdate()), 1) + ;
			cBIInt2Hex(day(msdate()), 1) + ;
			cBIInt2Hex(seconds(), 5)
return cRet

/*-------------------------------------------------------------------------------------
@function cBIMakeName(cPrefix)
Gera um nome único a partir de um prefixo.
@param cPrefix - Prefixo a ser utilizado.
@return - Nome único. (Pode ser utilizado com ID)
--------------------------------------------------------------------------------------*/
function cBIMakeName(cPrefix)
	local cRet := alltrim(cPrefix), nRet
	local nCont := 50
	cPrefix := "__" + cRet + "__"
	while !GlbLock() .and. !KillApp()
		sleep(100)                           
		nCont--
		if nCont == 0
			nCont := 50
		endif
	enddo
	nRet := val(GetGlbValue(cPrefix)) + 1
	PutGlbValue(cPrefix, cBIStr(nRet))
	cRet += cBIInt2Hex(nRet, 5)

	GlbUnlock()	   
return cRet        	

/*-------------------------------------------------------------------------------------
@function cBIConcat(x1, x2, x3, x4, x5, x6, x7, x8, x9, xA)
Concatena uma lista de argumentos. (Máximo 10)
Arrays terao todos os elementos convertidos em string e concatenados em sequencia.
@param x(1..A) - Valores a concatenar.
@return - Cadeia concatenada dos elementos.
--------------------------------------------------------------------------------------*/
function cBIConcat(x1, x2, x3, x4, x5, x6, x7, x8, x9, xA)
return 	cBIStr(x1) + cBIStr(x2) + cBIStr(x3) + cBIStr(x4) + cBIStr(x5);
		+ cBIStr(x6) + cBIStr(x7) + cBIStr(x8) + cBIStr(x9) + cBIStr(xA)

/*-------------------------------------------------------------------------------------
@function cBIConcatWSep(cSeparator, x1, x2, x3, x4, x5, x6, x7, x8, x9, xA)
Concatena e converte em Macro uma lista de elementos usando um separador. (Máximo 10)
Arrays terao todos os elementos executados e seus retornos concatenados em sequencia
com cada elemento seguido de separador, menos o último da cadeia concatenada.
@param cSeparator - Separador que ficará entre cada parte adicionada.
@param x(1..A) - Valores a converter em macro e concatenar.
@return - Cadeia concatenada dos elementos.
--------------------------------------------------------------------------------------*/
function cBIConcatMacro(cSeparator, x1, x2, x3, x4, x5, x6, x7, x8, x9, xA)
return cBIConcatWSep(cSeparator, x1, x2, x3, x4, x5, x6, x7, x8, x9, xA, .t.)

/*-------------------------------------------------------------------------------------
@function cBIConcatWSep(cSeparator, x1, x2, x3, x4, x5, x6, x7, x8, x9, xA)
Concatena uma lista de argumentos usando um separador. (Máximo 10)
Arrays terao todos os elementos convertidos em string e concatenados em sequencia
com cada elemento seguido de separador, menos o último da cadeia concatenada.
@param cSeparator - Separador que ficará entre cada parte adicionada.
@param x(1..A) - Valores a concatenar com separadores.
@param lMacro - Se .t. todos os elementos serão transformados em macro.
@return - Cadeia concatenada dos elementos.
--------------------------------------------------------------------------------------*/
function cBIConcatWSep(cSeparator, x1, x2, x3, x4, x5, x6, x7, x8, x9, xA, lMacro)
	local cRet := '', nPos
	default lMacro := .f.

	if valType(x1) == "A" .and. valType(x2) == "U" 
		aEval(x1, { |x| iif(valType(x) != "U", cRet += cSeparator + cBIStr(x, lMacro),nil) })
		cRet := substr(cRet, len(cSeparator)+1)
	else
		cRet += iif(valType(x1)=="U", "", cBIStr(x1, lMacro))
		cRet += iif(valType(x2)=="U", "", cSeparator + cBIStr(x2, lMacro))
		cRet += iif(valType(x3)=="U", "", cSeparator + cBIStr(x3, lMacro))
		cRet += iif(valType(x4)=="U", "", cSeparator + cBIStr(x4, lMacro))
		cRet += iif(valType(x5)=="U", "", cSeparator + cBIStr(x5, lMacro))
		cRet += iif(valType(x6)=="U", "", cSeparator + cBIStr(x6, lMacro))
		cRet += iif(valType(x7)=="U", "", cSeparator + cBIStr(x7, lMacro))
		cRet += iif(valType(x8)=="U", "", cSeparator + cBIStr(x8, lMacro))
		cRet += iif(valType(x9)=="U", "", cSeparator + cBIStr(x9, lMacro))
		cRet += iif(valType(xA)=="U", "", cSeparator + cBIStr(xA, lMacro))
		cRet := rTrim(cRet)
	endif
return cRet

/*-------------------------------------------------------------------------------------
@function BILog(cMsg, bLogger)
Chama o bloco bLogger, passando os parametros: cMsg, dData, cHora, cRotina, nLinha.
cMsg - A mensagem de log, passada como 1o. parametro desta função.
dData - Data da ocorrencia.
cHora - Hora, min, seg da ocorrencia.
cRotina - Rotina que chamou esta função para fazer o log.
nLinha - Numero da linha onde a rotina chamou esta função de log.
@param cMsg - Mensagem a ser logada.
@param bLogger - Bloco que faz o log. Se NIL, nada acontece.
--------------------------------------------------------------------------------------*/
function BILog(cMsg, bLogger)
	if(valtype(bLogger) == "B")
		eval(bLogger, cMsg, date(), time(), procname(2), procline(2))
	endif	
return

/*-------------------------------------------------------------------------------------
@function BICritical(lOnOff, cName)
Gera uma Critical Section.
@param lOnOff - liga/desliga a sessão critica.
@param cName - nome da sessão.
@return - status da sessão.
--------------------------------------------------------------------------------------*/
function BICritical(lOnOff, cName)
	local lRet := .t., cTime
	default cName := procName(1)
	
	if !alOnOff                                               
		PutGlbValue(cName, "")
		GlbUnlock()
	elseif !GlbLock()
		lRet :=.f.
	else
		cTime := time()
		PutGlbValue(cName, cTime)
	endif
return lRet

/*-------------------------------------------------------------------------------------
@function xBIConvTo(cType, xValue)
Converte qualquer tipo de argumento para um tipo especifico.
@param cType - tipo de saída desejada (CNDL).
@param cName - valor a ser convertido.
@return - valor convertido resultante.
--------------------------------------------------------------------------------------*/
function xBIConvTo(cType, xValue)
	local xRet := xValue

	if valType(xRet) != cType
		xRet := cBIStr(xValue)	
		if cType == "N"
			xRet := val(xRet)
		elseif cType == "D"
			xRet := iif("/" $ xRet, ctod(xRet), stod(xRet))
		elseif cType == "L"
			xRet := upper(alltrim(xRet)) $ ".T.|T|TRUE|.Y.|Y|YES|S|SIM|OK|"		
		endif
	endif
return xRet

/*-------------------------------------------------------------------------------------
@function cBIURLEncode(cValue)
Converte uma string para sequencia especial de saida por URL.
@param cValue - String a ser convertida.
@return - Sequencia convertida, pronta para ser enviada na URL.
--------------------------------------------------------------------------------------*/
function cBIURLEncode(cValue)
	// O equivalente desta função seria: 
	// escape(<string>) -> Klib Extended
	local cRet := cValue

	cRet := strtran(cRet, "%", "%25")
	cRet := strtran(cRet, "+", "%2B")
	cRet := strtran(cRet, "/", "%2F")
	cRet := strtran(cRet, "=", "%3D")
	cRet := strtran(cRet, " ", "%20")
	cRet := strtran(cRet, "&", "%26")
	cRet := strtran(cRet, "'", "%27")
	cRet := strtran(cRet, '"', "%22")
	cRet := strtran(cRet, ':', "%3A")
	cRet := strtran(cRet, "@", "%40")
return cRet

/*-------------------------------------------------------------------------------------
@function cBIURLDecode(cValue)
Converte uma sequencia especial de URL opara uma String padrao.
@param cValue - Sequencia a ser convertida em string.
@return - String convertida resultante da sequencia de URL.
--------------------------------------------------------------------------------------*/
function cBIURLDecode(cValue)
	// O equivalente desta função seria: 
	// unescape(<string>) -> Klib Extended
	local cAux := cValue, cRet := "", nInd, cCode, cLetra

	if left(cAux,1) == "'" .or. left(cAux,1) == '"'
		cAux := substr(cAux, 2, len(cAux)-2)
	endif	

	for nInd := 1 to len(cAux)
		cLetra := substr(cAux, nInd, 1)
		if cLetra == "%"
			cCode := substr(cAux, nInd+1, 2)
			cRet += chr(hex2Int(cCode))
			nInd += 2
		else
			cRet += cLetra
		endif
	next
return cRet

/*-------------------------------------------------------------------------------------
@function aBIToken(cLine, cSeparator, lRealType)
"Tokeniza" uma linha.
@param cLine - String com a linha a ser tokenizada.
@param cSeparator - Caracter separador de tokens.
@param lRealType - Indica se valores tokenizados devem ser reais.
@return - Array contendo todos os tokens.
--------------------------------------------------------------------------------------*/
function aBIToken(cLine, cSeparator, lRealType)
	local aRet := { }
	local nInd, cChar, cValue := ""
	local lAspas := .f.
	local cAspas
		
	default cSeparator := ","
	default lRealType := .t.
	
	for nInd := 1 to len(cLine)
		cChar := substr(cLine, nInd, 1)
		if cChar == cSeparator .and. !lAspas
			cValue := strTran(cValue, "\x22", '"')
			cValue := strTran(cValue, "\x27", "'")
			cValue := strTran(cValue, chr(13), "\n")
			cValue := strTran(cValue, chr(10), "")
			aAdd(aRet, cValue)
			cValue := ""
		else    
			if lAspas .and. cChar == cAspas
				lAspas := .f.
			elseif cChar == '"' .or. cChar == "'"
				lAspas := .T.                     
				cAspas := cChar
			endif
			cValue += cChar
		endif 		
	next

	if !empty(cValue)	
		aAdd(aRet, cValue)
	elseif right(cLine, 1) == cSeparator
		aAdd(aRet, cValue)
	endif
	        
	if lRealType
		for nInd := 1 to len(aRet)
			if left(aRet[nInd],1) == '"'
				aRet[nInd] := substr(aRet[nInd], 2, len(aRet[nInd])-2)
			elseif left(aRet[nInd],1) == '[' .and. len(aRet[nInd]) > 8
				aRet[nInd] := stod(substr(aRet[nInd], 2, len(aRet[nInd])-2))
			elseif left(aRet[nInd],1) == '.'
				aRet[nInd] := aRet[nInd] == '.t.' .or. aRet[nInd] == '.T.'
			elseif lBIIsDigit(aRet[nInd])
				aRet[nInd] := nBIVal(aRet[nInd])
			endif                                    
		next
	endif
return aRet

/*-------------------------------------------------------------------------------------
@function aBIPackArray(aArray)
Retorna um clone de um array eliminando os elementos VAZIOS(Empty).
@param aArray - Array que sera a base para a operacao. (Nao e alterado)
@return - Array clone sem os elementos vazios.
--------------------------------------------------------------------------------------*/
function aBIPackArray(aArray)
	local nInd, aRet := {}
	
	for nInd := 1 to len(aArray)
		if(valtype(aArray[nInd])!="U")
			aAdd(aRet, aArray[nInd])
		endif
	next

return aRet

/*-------------------------------------------------------------------------------------
@function BIADel(aArray, nElement)
Elimina elementos de um array e ja ajusta o tamanho.
@param aArray - Array que tera o elemento deletado.
@param nElement - Indice do elemento a ser deletado.
--------------------------------------------------------------------------------------*/
function BIADel(aArray, nElement)
	aDel(aArray, nElement)
	aSize(aArray, len(aArray)-1)
return 

/*
--------------------------------------------------------------------------------------
@function BIaDelDuplicado(aArray, alKill)
Verifica se há elementos duplicados em um array de array e elimina-os.
@param aaList - Array a ser testada
--------------------------------------------------------------------------------------
*/                      
function aBIDelDuplicado(aArray)
	Local nInd 
	Local nInd2 
	Local aAux
	Local nLen := Len(aArray)     

	For nInd := 1 to nLen   
	
		For nInd2 := nLen to 1 step -1
			
			If nInd2 <> nInd .And.;
				valType(aArray[nInd]) <> "U" .And.;
			  	valType(aArray[nInd2]) <> "U" .And.;
			  	cBIStr(aArray[nInd]) == cBIStr(aArray[nInd2])

				aArray[nInd2] := NIL
			Endif
		Next
	Next
	
	aAux := aBIPackArray(aArray)
	aSize(aArray, len(aAux))
	aEval(aAux, { |x,i| aArray[i] := x})

Return aClone(aArray)

/*-------------------------------------------------------------------------------------
@function BIUseLicence()
Ocupa uma licença e retorna .t. Se não houver licença disponível, retorna .f.
--------------------------------------------------------------------------------------*/
function BIUseLicense()
return .t.

/*-------------------------------------------------------------------------------------
@function cBIRGB(nRed, nGreen, nBlue)
Converte valores inteiros em código de cor RGB (hex).
@param nRed - Numero inteiro entre 0 e 255 representando o vermelho.
@param nGreen - Numero inteiro entre 0 e 255 representando o verde.
@param nBlue - Numero inteiro entre 0 e 255 representando o azul.
@return - String hexadecimal com a cor RGB.
--------------------------------------------------------------------------------------*/
function cBIRGB(nRed, nGreen, nBlue)
return cBIInt2Hex(nRed, 2) + cBIInt2Hex(nGreen, 2) + cBIInt2Hex(nBlue, 2)

/*-------------------------------------------------------------------------------------
@function lBIIsDigit(cText)
Verifica se uma string contem somente numero, "-" ou "."
Os caracteres "-" e "." somente serão considerados caso o parâmetro lOnlyNumbers esteja
como .F., sendo este o valor padrão.

@param cText - Texto a ser verificado.
@param lOnlyNumbers - somente números
@return - .t. se houver somente digitos.
--------------------------------------------------------------------------------------*/
function lBIIsDigit(cText, lOnlyNumbers)
	local lRet := .t.
	local nInd, cAux
	
	default lOnlyNumbers := .F.

	cText := alltrim(cText)
	if !empty(cText)              
		if !lOnlyNumbers .and. at("-", cText) > 1
			lRet := .f.
		else
			for nInd := 1 to len(cText)
				cAux := substr(cText, nInd, 1)
				if !isDigit(cAux) .and. (lOnlyNumbers .OR. ( !(cAux == "-") .and. !(cAux == ".") ))
					lRet := .f.
					exit
				endif
			next
		endif
	else
		lRet := .f.
	endif
return lRet

/*-------------------------------------------------------------------------------------
@function lChkSintax(cExpressao, cMsg)
Verifica a sintaxe de expressões ADVPL.
@param cExpressao - Expressão ADVPL a ser avaliada.
@param cMsg - Variavel passada por referencia que receberá a msg de erro.
@return - .t. se a sintaxe estiver correta. .f. senão.
--------------------------------------------------------------------------------------*/
function lChkSintax(cExpressao, cMsg)
	private lRet := .t., oE
	
	acMsg := ""            
	begin sequence
		__compstr(cExpressao)
	recover
	cMsg := "Expressão com erro, 0,0"
/*	recover using oE    
		if valType(oE) == "O"
			cMsg := oE:Description
		else    
			cMsg := "Expressão com erro, 0,0"
		endif 
*/
		lRet := .f.
	end sequence

return lRet

/*-------------------------------------------------------------------------------------
@function lExecSintax(cExpressao, cMsg)
Executa expressões tratanto erros.
@param cExpressao - Expressão ADVPL a ser executada.
@param cMsg - Variavel passada por referencia que receberá a msg de erro.
@return - .t. se a sintaxe estiver correta. .f. senão.
--------------------------------------------------------------------------------------*/
function lExecSintax(cExpressao, cMsg)
	private lOk := .t., oE, cExp := cExpressao

	cMsg := ""            
	begin sequence
		cMsg := __execstr(cExpressao)
		recover     
		cMsg := 'Erro ao executar expressão via execSintax()'		
/*	recover using oE
		if valType(oE) == "U"
			cMsg := 'Erro ao executar expressão via execSintax()'
		else
			cMsg := oE:Description
		endif
*/		
		lOk := .f.
	end sequence
return lOk

/*-------------------------------------------------------------------------------------
@function cBICripto(cValue, nLen)
Criptografia simples.
@param cValue - Valor a ser criptografado.
@param nLen -> Tamanho final.
@return - Valor a criptografado.
--------------------------------------------------------------------------------------*/
function cBICripto(cValue, nLen)
	local cRet := "", nAux
	local nInd
	    
	cValue := padr(cValue, nLen, " ")
	for nInd := 1 to len(cValue)
		nAux := asc(substr(cValue, nInd, 1)) + 7
		if nAux > 255
			nAux := 32
		endif
		cRet += cBIInt2Hex(nAux,2)
	next
return cRet

/*-------------------------------------------------------------------------------------
@function cBIUncripto(cValue)
DesCriptografia simples.
@param cValue - Valor a ser descriptografado.
@return - Valor descriptografado.
--------------------------------------------------------------------------------------*/
function cBIUncripto(cValue)
	local cRet := "", nAux
	local nInd
	
	for nInd := 1 to len(cValue) step 2
		nAux := nBIHex2Int(substr(cValue, nInd, 2)) - 7
		if nAux < 32
			nAux := 255
		endif
		cRet += chr(nAux)
	next
return cRet

/*-------------------------------------------------------------------------------------
@function cBIChgFileExt(cFilename, cExtension)
Troca a extensão (.XXX) do nome do arquivo.
@param cFilename - Nome do arquivo a ter sua extensão trocada.
@param cExtension - Extensão a ser utilizada na substituição da original.
@return - Nome do arquivo com a extensão trocada.
--------------------------------------------------------------------------------------*/
function cBIChgFileExt(cFilename, cExtension)
   local nPos := 0
   
   if cFilename <> NIL .and. cExtension <> NIL
	  cFilename := AllTrim(cFilename)
      if (nPos := at(".", cFilename)) > 0
         cFilename := left(cFilename, nPos - 1 ) + cExtension
      else
         cFilename += cExtension
      end
   end
return cFilename

/*-------------------------------------------------------------------------------------
@function cBIPrintf(cFmtString, aParams)
Formata uma lista de parametros conforme a string de formatação.
As mascaras devem estar delimitadas por [].
@param cFmtString - String de formatação.
@param aParams - Lista de parametros.
@return - String da lista formatada.
--------------------------------------------------------------------------------------*/
function cBIPrintf(cFmtString, aParams)
	local nParam := 0
	local cRet := ''
	local nPosI, nPosF
	local cMask, cAux                   
		
	if len(aParams) == 0
		cRet := cFmtString
	else
		cFmtString := strTran(cFmtString, '\%', '\!')
		for nPosI := 1 to len(cFmtString)
			cAux := substr(cFmtString, nPosI, 1)
			if cAux == '%'
				cMask := ''
				nParam++
				if nParam <= len(aParams)
					for nPosF := nPosI + 1 to len(cFmtString)
						cAux := substr(cFmtString, nPosF, 1)
						if cAux == '%'
							cRet := cRet + Transform(aParams[nParam], cMask)
							nPosI := nPosF
							exit
						else
				         cMask := cMask + cAux
			  			endif
					next       
				endif
			else
				cRet := cRet + cAux
			endif
		next
		cRet := strTran(cRet, '\!', '%')
	endif
return cRet

/*-------------------------------------------------------------------------------------
@function cBIStrTranIgnCase(cValue, cOldVal, cNewVal)
Efetua um "strtran" ignorando a caixa.
@param cValue - Valor original.
@param cOldVal - Sub-string alvo (valor antigo).
@param cNewal - Sub-string (novo valor).
@return - Valor tratado.
--------------------------------------------------------------------------------------*/
function cBIStrTranIgnCase(cValue, cOldVal, cNewVal)
	local cRet := cValue
	local nPos := 0
	local nOldVal := len(cOldVal)

	cOldVal := upper(cOldVal)

	while (nPos := at(cOldVal, upper(cRet))) != 0
		cRet := stuff(cRet, nPos, nOldVal, cNewVal)
	enddo
return cRet

/*-------------------------------------------------------------------------------------
@function BISendMail(_cEmpresa, _cFilial, cSubject, cText, cTo, cCc, aAttachs)
Envia e-mails via o SigaWF.
@param _cEmpresa -> Empresa
@param _cFilial -> Filial
@param cSubject -> Assunto.
@param cText -> Texto do corpo da mensagem.
@param cTo -> Destinatario.
@param cCc -> Destinatario com cópia.
--------------------------------------------------------------------------------------*/
function BISendMail(_cEmpresa, _cFilial, cSubject, cText, cTo, cCc, aAttachs)
	local owf, omsg, nInd
      
	default cTo := ""
	default cCc := ""
	default aAttachs := {}
	
	if !empty(cTo) .or. !empty(cCc)
		owf := twfobj( {_cEmpresa, _cFilial })
		omsg := owf:omail:oSmtpSrv:omsg
	
		omsg:cto := cTo
		omsg:ccc := cCc
		omsg:csubject := cSubject
		omsg:cbody := cText
		for nInd := 1 to len(aAttachs)
			if file(aAttachs[nInd])
				omsg:attachFile(aAttachs[nInd])
			endif	
		next	
		owf:omail:oSmtpSrv:Send()
    endif

return

/*-------------------------------------------------------------------------------------
@function function cBIParseSQL(cSQL, @cMsg, cTopDataBase)
Prepara comando SQL para ser executado conforme o banco. Caso o comando
não possa ser processado, o código original será retornado.
@param cSQL - Comando SQL.
@param cMsg - String passada por referencia para conter a mensagem de erro.
@param cTopDataBase - String contendo o database type a ser utilizado.
@return - SQL preparado.
--------------------------------------------------------------------------------------*/
function cBIParseSQL(cSQL, cMsg, cTopDataBase)
	local cRet := cSQL
	default cTopDataBase := cBIGetSGDB()

	cMsg := ""

	if ("CREATE PROCEDURE" $ upper(cRet))
		cRet := MSParse(cRet, cTopDataBase) 
	else
		cRet := StrTran(cRet, ";", "")
		cRet := MSParse(cRet, cTopDataBase, .t.)
	endif

	if empty(cRet)
		cRet := cSQL
		if(cTopDataBase!="POSTGRES") // O parser nao aceita Postgre, portanto retorna o mesmo SQL
			cMsg := MSParseErro()    // sem alteração, mas também sem conter erros
		endif	
	endif
                                    
return cRet
/*-------------------------------------------------------------------------------------
@function cBIInSession(cName , xValue)
Cria e registra "campos" em HttpSession.
@param cName - Nome da variavel.
@param xValue - Valor.
@return - Valor.
--------------------------------------------------------------------------------------*/
function cBIInSession(cName , xValue)
	if valType(cName) == "U"
		HttpSession->ASession := {}
	else
		if ascan(HttpSession->ASession, { |x| x == cName} )	== 0
			aAdd(HttpSession->ASession, cName)
		endif
		if valType(xValue) != "U"
			&("HttpSession->"+cName+":="+cBIStr(xValue,.t.))
		endif
	endif
return iif(valType(cName)=="C",&("HttpSession->"+cName),nil)

/*-------------------------------------------------------------------------------------
@function cBIInPost(cName , xValue)
Cria e registra "campos" em HttpPost.
@param cName - Nome da variavel.
@param xValue - Valor.
@return - Valor.
--------------------------------------------------------------------------------------*/
function cBIInPost(cName , xValue)
	if ascan(HttpPost->APost, { |x| x == upper(cName)} )	== 0
		aAdd(HttpPost->APost, upper(cName))
	endif
	if valType(xValue) != "U"
		&("HttpPost->"+cName+":="+cBIStr(xValue,.t.))
	endif
return &("HttpPost->"+cName)

/*-------------------------------------------------------------------------------------
@function nBITrunc(nValue, nTam, nDec)
Trunca um valor numérico sem arredondar.
@param nValue - Valor a truncar.
@param nTam - Tamanho final do número.
@param nDec - Número de decimais.
@return - Valor truncado.
--------------------------------------------------------------------------------------*/
function nBITrunc(nValue, nTam, nDec)
return val(Str(nValue, nTam, nDec))

/*-------------------------------------------------------------------------------------
@function cBIIsEmpty(xValue, xRetorno)
Se empty(xValue) for verdadeiro, retorna xRetorno, retorna
o próprio xValue mas no mesmo tipo de xRetorno.
@param xValue - Valor a ser avaliado.
@param xRetorno - Valor a retornar caso empty(xValue) seja .t.
@return - Valor retorna processado.
--------------------------------------------------------------------------------------*/
function cBIIsEmpty(xValue, xRetorno)
return (iif(empty(xValue), xRetorno, xBIConvTo(valType(xRetorno), xValue) ))

/*-------------------------------------------------------------------------------------
@function nBISQLExec(aSQL)
Executa comandos SQL.
@param aSQL - Vetor de comando SQL a ser executado.
@return - Retorna 0 (zero) se execução OK, senão o código de erro.
--------------------------------------------------------------------------------------*/
function nBISQLExec(aSQL)
	local nRet := 0, nInd, cSQLOrig, cMsgErro := ""

	if empty(aSQL) .or. len(aSQL) == 0
		return 0
	endif

	if upper(atail(aSQL)) != "GO"
		aAdd(aSQL, "GO")
	endif
	cSQL := ""
	for nInd := 1 to len(aSQL)
		if upper(aSQL[nInd]) == "GO"
			cSQLOrig := cSQL
			cSQL := cBIParseSQL(cSQL, @cMsgErro)
			nRet := TcSqlExec(cSQL)
			if nRet <> 0
				conout("########################################################")
				conout("SQLError Code " + cBIStr(nRet), tcSqlError())
				conout("ParserError ", cMsgErro)
				conout("-< Original >-------------------------------------------")
				conout(cSQLOrig)
				conout("-< MSParse >--------------------------------------------")
				conout(cSQL)
				conout("--------------------------------------------------------")
				conout("########################################################")
			endif		
			cSQL := ""
		else
			cSQL += aSQL[nInd] + CRLF
		endif		
	next
return nRet

/*-------------------------------------------------------------------------------------
@function BIRefreshAll()
Forca atualização nas tabelas abertas.
--------------------------------------------------------------------------------------*/
function BIRefreshAll()
	local nWorkArea
	
	for nWorkArea := 1 to 250
		dbSelectArea(nWorkArea)
		if !(alias() == "")
			tcRefresh(alias())
		endif
	next
return

/*-------------------------------------------------------------------------------------
@function nBIOpenDBINI(cIniFile, bLogger)
Abre uma conexão ao banco de dados, através dos parâmetros no arquivo ini.
@param cIniFile - Nome do arquivo ini. Se nao for passado, o default fica sendo 
o arquivo apXsrv.ini retornado pela funcao GetADV97() da lib Protheus.
@param bLogger - Bloco que faz o log, chamada de BILog(). Veja função BILog().
@param cEnvironment - Ambiente desejado. Default e o ambiente atual.
@return - Indica o sucesso da operação.
	  0	= Operação bem sucedida
	 -1 = Falha na conexão por não localizar servidor Top
	-35 = Falha na conexão por não localizar Ambiente
 	  x = Falha na conexão
--------------------------------------------------------------------------------------*/
static __BITopCon	// Variavel utilizada para armazenar o ponteiro da base-de-dados
function nBIOpenDBINI(cIniFile, cEnvironment, bLogger)
	local cTopDB		:= "ERROR"
	local cTopAlias	:= "ERROR"
	local cTopServer	:= "ERROR"
	local cTopConType	:= "ERROR"
	local cTopPorta	:= "ERROR"
	local cSrvEnv		:= GetEnvServer()

	default cInifile		:= GetADV97()
	default cEnvironment := cSrvEnv

	//Observação: foi desconsiderada a situação de uso com INI de nome diferente do INI padrão do Protheus
	if !(cEnvironment == cSrvEnv)
		cTopDB 		:= GetPvProfString(cEnvironment, "DbDataBase", "ERROR", cIniFile)
  		If ( cTopDB=="ERROR" ) 
		    cTopDB:= GetPvProfString(cEnvironment, "TopDataBase", "ERROR", cIniFile) 
        EndIf 

		cTopAlias   := GetPvProfString(cEnvironment, "DbAlias", "ERROR", cIniFile)
		If ( cTopAlias=="ERROR" ) 
		    cTopAlias:= GetPvProfString(cEnvironment, "TopAlias", "ERROR", cIniFile) 
        EndIf 

		cTopServer  := GetPvProfString(cEnvironment, "DbServer", "ERROR", cIniFile)  
		If ( cTopServer=="ERROR" ) 
		    cTopServer:= GetPvProfString(cEnvironment, "TopServer", "ERROR", cIniFile) 
        EndIf 

		cTopPorta	:= GetPvProfString(cEnvironment, "DbPort", "ERROR", cIniFile)	
		If ( cTopPorta=="ERROR" ) 
		    cTopPorta:= GetPvProfString(cEnvironment, "TopPort", "ERROR", cIniFile) 
        EndIf 

		cTopConType := upper(GetPvProfString(cEnvironment, "DbContype", "ERROR", cIniFile))
		If ( cTopConType=="ERROR" ) 
		    cTopConType:= upper(GetPvProfString(cEnvironment, "TopContype", "ERROR", cIniFile))
        EndIf 
	endif

	if cTopDB == "ERROR"
		cTopDB := loadTopProp( "DATABASE", "ERROR" )
	endif 

	if cTopAlias == "ERROR"
		cTopAlias := loadTopProp( "ALIAS", "ERROR" )
	endif 

	if cTopServer == "ERROR"
		cTopServer := loadTopProp( "SERVER", "ERROR" )
	endif

	if cTopConType == "ERROR"
		cTopConType := Upper( loadTopProp( "CONTYPE", "TCPIP" ) )
	endif 

	if cTopPorta == "ERROR"
		cTopPorta := alltrim( str( loadTopProp( "PORT", 7890 ) ) )
	endif

	if !(alltrim(cTopConType)$"TCPIP/LOCAL/APPC/BRIDGE/NPIPE")
		BILog(STR0001+cTopConType, bLogger) //"A entrada [Contype] da sessão [TopConnect] inválida: "
		return .f.
	endif
	if "ERROR" $ cTopDB
		BILog(STR0002+cTopDB, bLogger) //"A entrada [Database] da sessão [TopConnect] inválida: "
		return .f.
	endif
	if "ERROR" $ cTopAlias
		BILog(STR0003+cTopAlias, bLogger) //"A entrada [Alias] da sessão [TopConnect] inválida: "
		return .f.
	endif
	if "ERROR" $ cTopServer
		BILog(STR0004+cTopServer, bLogger) //"A entrada [Server] da sessão [TopConnect] inválida: "
		return .f.
	endif

return nBIOpenDB(cTopDB, cTopAlias, cTopServer, cTopConType, bLogger, val(cTopPorta))

/*------------------------------------------------------------------------------------- 
Leitura de propriedades para acesso ao TOP Connect
--------------------------------------------------------------------------------------*/
static function loadTopProp( acPropName, axDefault )
	local cProp 	:= upper( acPropName )
	local xRet		:= nil
	local aTopInfo	:= {}

	aTopInfo := FWGetTopInfo()

	do case
		case cProp == "CONTYPE"
			xRet := aTopInfo[2]
		case cProp == "SERVER"
			xRet := aTopInfo[1]
		case cProp == "PORT"
			xRet := aTopInfo[3]
		case cProp == "DATABASE"
			xRet := aTopInfo[4]
		case cProp == "ALIAS"
			xRet := aTopInfo[5]
		case cProp == "HASMAPPER"		
			xRet := aTopInfo[6]
		otherwise
			xRet := ""
	endcase
	
	if Empty( xRet ) .OR. valtype( xRet )=="U"
		xRet := axDefault
	endif 

return xRet


/*-------------------------------------------------------------------------------------
@function nBIOpenDB(cTopDB, cTopAlias, cTopServer, cTopConType, bLogger)
Abre uma conexão ao banco de dados, através dos parâmetros no arquivo ini.
@param cTopDB - TopDatabase.
@param cTopAlias - TopAlias.
@param cTopServer - TopServer.
@param cTopConType - TopConType.
@param bLogger - Bloco que faz o log, veja função BILog() para formato do bloco.
@param nTopPorta - TopPort
@param lTCQuit - sinaliza se deve ou não executar o TcQuit. Padrão .T.
@return - Indica o sucesso da operação.
	  0	= Operação bem sucedida
	 -1 = Falha na conexão por não localizar servidor Top
	-35 = Falha na conexão por não localizar Ambiente
 	  x = Falha na conexão
--------------------------------------------------------------------------------------*/
function nBIOpenDB(cTopDB, cTopAlias, cTopServer, cTopConType, bLogger, nTopPorta, lTCQuit)
	default nTopPorta := 7890
	default lTCQuit	:= .T.
	
	BILog(STR0005 + " -> " + cTopServer + ":" + cTopDB + "/" + cTopAlias, bLogger) //"Abrindo banco de dados"

	TcConType(cTopConType)
	
	if cTopConType == "APPC"
		__BITopCon := TCLINK("@!!@" + cTopDB,cTopServer,nTopPorta)//,cUser,cPsw)
	else
		if "AS" $ cTopAlias .and. "400" $ cTopAlias
			__BITopCon := TCLINK("@!!@" + cTopDB,cTopServer,nTopPorta)//,cUser,cPsw)
		else
			__BITopCon := TCLINK("@!!@" + cTopDB + "/" + cTopAlias, cTopServer, nTopPorta)//,cUser,cPsw)
		endif
	endif

	if __BITopCon < 0
		BILog(cBIMsgTopError(__BITopCon), bLogger)
		BILog(cTopServer + ":" + cTopDB + "/" + cTopAlias, bLogger)
		BILog("Code error:" + str(__BITopCon), bLogger)
		
		If lTCQuit
			TCQUIT()
		EndIf
		
	else   
		BILog(STR0012 + " -> " + TCGetDB(), bLogger)/*"Tipo do banco de dados"*/

		BILog(STR0006 + " -> " + cTopServer + ":" + cTopDB + "/" + cTopAlias, bLogger) /*"Conexão bem sucedida"*/
		__BITOPDB := cTopServer + ":" + cTopDB + "/" + cTopAlias
	endif
return __BITopCon

/*-------------------------------------------------------------------------------------
@function cBIMsgTopError()
@param nTopError - Número do erro Top
@return - Devolve a string que descreve o erro ocorrido
Messagens de erros retornados pelas funções nBIOpenDB e nnBIOpenDBIni
--------------------------------------------------------------------------------------*/
function cBIMsgTopError(nTopError)
	local cMsgError
	
	if nTopError == -1 .or. nTopError == -2
		cMsgError := STR0007 + STR0008 //"Erro TopConnect: Servidor inacessível."
	elseif nTopError == -34
		cMsgError := STR0007 + STR0009 //"Erro TopConnect: Número de licenças excedido."
	elseif nTopError == -35
		cMsgError := STR0007 + STR0010 //"Erro TopConnect: Ambiente não localizado."
	else
		cMsgError := STR0007 + STR0011 //"Erro TopConnect: Falha na conexão."
	endif
return cMsgError

/*-------------------------------------------------------------------------------------
@function BICloseDB()
@param lCloseAll - específica se deverá fechar todas as conexões. Opcional, valor default: .T.
@param lTCQuit - específica se deverá executar o TcQuit. Opcional, valor default: .T.
@param lTcUnlink - específica se deverá executar o TcUnlink. Opcional, valor default: .F.
Fecha a conexão ao banco de dados.
--------------------------------------------------------------------------------------*/
function BICloseDB(lCloseAll, lTCQuit, lTcUnlink)
	default lCloseAll	:= .T.
	default lTCQuit	:= .T.
	default lTcUnlink := .F.
	
	If lCloseAll
		dbCloseAll()
	EndIf
	
	if __BITopCon > -1
		If lTcUnlink
			TCUNLINK(__BITopCon)
			__BITopCon := -1
		EndIf
		
		If lTCQuit
			TCQUIT()
			__BITopCon := -1
		EndIf
	endif
return


/*-------------------------------------------------------------------------------------
@function cBIXMLEncode(cValue)
Converte blocos de texto em HTML "printável", trocando caractares especiais pelos seus
nomes html.
@param cValue - Valor a ser convertido
@return - Valor convertido.
--------------------------------------------------------------------------------------*/
function cBIXMLEncode(cValue)
	local cRet := cValue

	// XML tem somente 5 entidades predefinidas
	// Atenção:  &amp; deve ser o primeiro elemento deste vetor SEMPRE!!! 
	// No sistema só trabalha com aspas simples
	//local aTable := { {"&", "&amp;"}, {"<", "&lt;"}, {">", "&gt;"}, {"'", "&apos;"}, {'"', "&quot;"} }
	local aTable := { {"&", "&amp;"}, {"<", "&lt;"}, {">", "&gt;"}, {"'", "&apos;"}, {'"', "&apos;"} }

	// Primeira passada
	aEval(aTable, { |x| cRet := strTran(cRet, x[1], x[2]) })

return cRet	
                                                                                        

/*--------------------------------------------------------------------------------------
@static cStrNil(nValue, nTam, nDec)
Converte valores numéricos para string, caso seja NIL, retorna "".
@param nValue - numerico, valor a ser convertido em string
@param nTam - numerico, tamanho
@param nDec - numerico, numero de decimais
@return - string, valor convertido
--------------------------------------------------------------------------------------*/                                 
function cStrNil(nValue, nTam, nDec)
	local cRet := ""

	if(valType(nValue) != "U")
		cRet := str(nValue, nTam, nDec)
	endif
return cRet

/*--------------------------------------------------------------------------------------
@static cDtosNil(dValue)
Converte valores data para string (yyyymmdd), caso seja NIL, retorna ""
@param dValue - data, valor a ser convertido em string
@return string, valor convertido
--------------------------------------------------------------------------------------*/                                 
function cDtosNil(dValue)
	local cRet := ""

	if(valType(dValue) != "U")
		if(valType(dValue) == "C")
			cRet := dtos(ctod(dValue))
		else 
			cRet := dtos(dValue)
		endif
	endif	
return cRet

/*--------------------------------------------------------------------------------------
@function lBIIsXmlNode(oNode, cTag)
Indica se o nó especificado contém um nó child com a Tag especificada.
@param oNode - Ponteiro para o nó a ser verificado.
@param cTag - Tag do child.
@return - .t. existe o nó child, .f. não existe o nó child.
--------------------------------------------------------------------------------------*/                                 
function lBIIsXmlNode(oNode, cTag)
	local aAux := classDataArr(oNode)
	local lRet := .f., nPos
	
	cTag := upper(cTag)
	nPos := ascan(aAux, { |x| x[1] == cTag })
	if nPos > 0
		lRet := valType(aAux[nPos, 2]) != "U"
	endif	       
return lRet

/*-------------------------------------------------------------------------------------
@function cBIMakeKey(cLogin)
Gera uma chave única, com base no cLogin, para use em controle de "sessions".
@param cLogin - Login de usuário ou algo semelhante
@return - Chave única, no formato XXXXHHHHHH onde XXXX é a 1a., 5a, 9a. e 13a letras de 
          cLogin e HHHHHH é o resultado de seconds() em hexadecimal.
--------------------------------------------------------------------------------------*/
function cBIMakeKey(cLogin)
	local cAux := strTran(padr(upper(cLogin), 16, upper(cLogin)), " ", "B")
	local nInd, cAux2 := ""
	
	for nInd := 1 to len(cAux) step 4
		cAux2 += substr(cAux, nInd, 1)	
	next
		
return cAux2 + cBIInt2Hex(seconds(), 6)

/*-------------------------------------------------------------------------------------
@function BIForceDir(cPath)
Cria o caminho de diretórios a partir da raiz, se já existir, ignora.
* No Workflow corresponde a WFForceDir.
@param cPath - Diretório ou caminho a ser criado.
--------------------------------------------------------------------------------------*/
function BIForceDir(cPath)
	local nPos
	local cRoot 	:= ""
	local cBarra 	:= cBIGetSeparatorBar() // Armazena o tipo de barra a ser utilizada

	default cPath := ""

	cPath := AllTrim( cPath )
	if Right( cPath, 1 ) <> cBarra
		cPath += cBarra
	end

	while ( nPos := At( cBarra, cPath ) ) > 0
		if empty( Left( cPath, nPos -1 ) )
			cRoot += Left( cPath, nPos )
		else
			if At( Right( Left( cPath, nPos -1 ),1 ), ":." ) > 0
				cRoot := Left( cPath, nPos -1 )
			else
				if Right( cRoot, 1 ) <> cBarra
					cRoot += cBarra
				endif
				cRoot += Left( cPath, nPos -1 )
			endif
			if Right( cRoot, 1 ) <> ":"
				MakeDir( cRoot )
			endif
		endif
		cPath := Stuff( cPath, 1, nPos, "" )
	end
return
                                                                                        
/*-------------------------------------------------------------------------------------
@function cBITagEmpty(cCampo)
Utilizada para formação de HTML.
@param cCampo - Campo a ser verificado se esta vazio ou nulo
@return - Formatação definida como vazio para o HTML
--------------------------------------------------------------------------------------*/
function cBITagEmpty(cCampo)

	if(valtype(cCampo)=="C")
		if(empty(cCampo))
			cCampo = "&nbsp;"
		endif
	elseif(valtype(cCampo)=="D")
		if(cCampo==ctod(""))
			cCampo := "-"   
		else
			cCampo := cBIStr(cCampo)
		endif
	elseif(valtype(cCampo)=="N")
		if(cCampo==0)
			cCampo := "-"
		else
			cCampo := cBIStr(cCampo)
		endif
	elseif(valtype(cCampo)=="U")	
		cCampo := "-"
	endif	

return cCampo                                                                           

/*-------------------------------------------------------------------------------------
@function cBIUpper(cString)
Utilizada para conversão de minusculo para maiusculo
@param cString - String a ser convertida
@return - String convertida
--------------------------------------------------------------------------------------*/
function cBIUpper(cString)
	local aEspeciais, nI
	
	aEspeciais := cBICapitalEscapes()
	
	for nI := 1 to len(aEspeciais)
		cString := strtran(cString, aEspeciais[nI,1], aEspeciais[nI,2])
	next

return upper(cString)

/*-------------------------------------------------------------------------------------
@function cBILower(cString)
Utilizada para conversão de maiusculo para minusculo
@param cString - String a ser convertida
@return - String convertida
--------------------------------------------------------------------------------------*/
function cBILower(cString)
	local aEspeciais, nI
	
	aEspeciais := cBICapitalEscapes()
	
	for nI := 1 to len(aEspeciais)
		strtran(cString, aEspeciais[nI,2], aEspeciais[nI,1])
	next

return lower(cString)

/*-------------------------------------------------------------------------------------
@function cBICapitalEscapes()
Retorna array com caracteres especiais 
Formato: {{<minuscula>,<maiuscula>},...}
--------------------------------------------------------------------------------------*/
function cBICapitalEscapes()
	local aEspeciais
	
	aEspeciais := { {"á","Á"},{"é","É"},{"í","Í"},{"ó","Ó"},{"ú","Ú"},{"â","Â"},{"ê","Ê"},{"î","Î"},{"ô","Ô"},;
					{"û","Û"},{"à","À"},{"è","È"},{"ì","Ì"},{"ò","Ò"},{"ù","Ù"},{"ä","Ä"},{"ë","Ë"},{"ï","Ï"},;
					{"ö","Ö"},{"ü","Ü"},{"ã","Ã"},{"õ","Õ"},{"ñ","Ñ"},{"ç","Ç"} }

return aEspeciais

/*-------------------------------------------------------------------------------------
@function nBIWeekOfYear(dDate)
Retorna a semana do ano.
@param dDate  Data alvo a encontrar dentro da semana.
@return Número da semana do ano referente a data alvo. 

@see ISO 8601:2000           

NOTE 1 These rules provide for a calendar year to have 52 or 53 calendar weeks;
NOTE 2 The first calendar week of a calendar year may include up to three days from the previous calendar year; the last
calendar week of a calendar year may include up to three days from the following calendar year;
NOTE 3 The time-interval formed by the week dates of a calendar year is not the same as the time-interval formed by the
calendar dates or ordinal dates for the same year. For instance:
— Sunday 1995 January 1 is the 7th day of the 52nd week of 1994, and
— Tuesday 1996 December 31 is the 2nd day of the 1st week 1997.
NOTE 4 The rule for determining the first calendar week is equivalent with the rule “the first calendar week is the week which
includes January 4”.
--------------------------------------------------------------------------------------*/
function nBIWeekOfYear(dDate)
	Local dFWDayCYear 	:= dBIFirstWeekDay(Year(dDate)) //Primeiro dia da primeira semana do ano analisado.   
	Local dFWDayLYear 	:= Nil 							//Primeiro dia da primeira semana do ano anterior.	
	Local dFDayLastWeek	:= Nil                         	//Primeiro dia da última semana do ano. 
	Local dFDayLYear		:= Nil 							//Primeiro dia do ano anterior. 	    
	Local dLDayLYear		:= Nil 							//Último dia do ano anterior.  
	Local dFWeekDay 		:= Nil								//Dia que identifica a primeira semana do ano (04/01). 
	Local nWeek 			:= 1                           	//Semana do ano. 
	
    //-------------------------------------------------------------------
	// Calcula a semana do ano.    
	//------------------------------------------------------------------- 
    If ( ( dDate - dFWDayCYear ) > 6) 	
		nWeek := Int( ( dDate - dFWDayCYear ) / 7 ) + 1	    
	Else 
		//-------------------------------------------------------------------
		// Calcula a semana do ano quando os últimos dias estão no próximo ano.     
		//------------------------------------------------------------------- 
		If ( ( dDate - dFWDayCYear ) < 0)  
			dFDayLYear 	:= CToD("01/01/" + cBIStr( Year(dDate) -1) ) 
			dLDayLYear 	:= CToD("31/12/" + cBIStr( Year(dDate) -1) ) 
			dFWDayLYear := dBIFirstWeekDay( Year( dFDayLYear ) ) 
		  	nWeek 		:= Int( ( dLDayLYear - dFWDayLYear ) / 7 ) + 1
	    Else                                                                                 
			nWeek = 1
		EndIf
	EndIf  
	 
	//-------------------------------------------------------------------
	// Verifica se é a última semana do um ano, ou primeira do próximo.     
	//------------------------------------------------------------------- 	    
	If ( nWeek == 52 .Or. nWeek == 53 )    
		dFWeekDay   	:= CToD( "04/01/" + cBIStr( Year( dDate ) + 1 ) ) 
	  	dFDayLastWeek := dBIWeekToDate( nWeek, Year( dDate ) )

	    If ( dFWeekDay >= dFDayLastWeek .And. dFWeekDay <= dFDayLastWeek + 6 )                                             
			nWeek := 1
		EndIf  
	EndIf
return nWeek
   
/*-------------------------------------------------------------------------------------
@function dBIFirstDay(cAno)
Retorna o primeiro dia da primeira semana do ano.
@param (Caracter) cAno Ano do qual será verificado o primeiro dia da primeira semana.  
@return (Date) Primeiro dia da primeira semana do ano. 
--------------------------------------------------------------------------------------*/
function dBIFirstWeekDay(cAno)
    //Primeiro dia do ano analisado.
    Local dFirstDay := CToD("01/01/" + cBIStr(cAno))

    Do Case 
    	//Domingo
    	Case Dow(dFirstDay) == 1
    		dFirstDay := dFirstDay + 1    
    	//Sábado
    	Case Dow(dFirstDay) == 7  
    		dFirstDay := dFirstDay + 2 
    	//Sexta 
    	Case Dow(dFirstDay) == 6 
    		dFirstDay := dFirstDay + 3
    	//Quinta 
    	Case Dow(dFirstDay) == 5
    		dFirstDay := dFirstDay - 3
    	//Quarta 
    	Case Dow(dFirstDay) == 4      
    		dFirstDay := dFirstDay - 2
    	//Terça
    	Case Dow(dFirstDay) == 3      
    		dFirstDay := dFirstDay - 1
    	//Segunda
    	Case Dow(dFirstDay) == 2 
    		//Segunda-feira é o primeiro dia da semana.    		
    EndCase 
return dFirstDay   

/*-------------------------------------------------------------------------------------
Recupera o primeiro dia de uma dada semana em um ano.
@param nWeekOfYear Semana analisada no ano.
@return Primeiro dia da semana analisada.
--------------------------------------------------------------------------------------*/
function dBIWeekToDate(nWeekOfYear, nAno)
	//Primeiro dia do ano analisado.
	Local dDate			:= ctod("01/01/"+cBIStr(nAno))
    //Primeiro dia da primeira semana do ano analisado.
    Local dFWDayCYear 	:= dBIFirstWeekDay(Year(dDate)) 
      
return ( (dFWDayCYear + (7 * nWeekOfYear) ) -7 )

/*-------------------------------------------------------------------------------------
@function cBIClearAccents(cString)
Retorna uma "string" sem os acentos.
@param cString - String para limpeza.
@return - String sem os acentos.
--------------------------------------------------------------------------------------*/
function cBIClearAccents(cString)
	local cRetorno 	:=	cString
	local nItem		:=	1

	local aEspeciais := {;
							{"á","a"},{"é","e"},{"í","i"},{"ó","o"},{"ú","u"},{"â","a"},{"ê","e"},{"î","i"},;
							{"ô","o"},{"û","u"},{"à","a"},{"è","e"},{"ì","i"},{"ò","o"},{"ù","u"},{"ä","a"},;
							{"ë","e"},{"ï","i"},{"ö","o"},{"ü","u"},{"ã","a"},{"õ","o"},{"ñ","n"},{"ç","c"} ;
						}
	
	for nItem := 1 to len(aEspeciais)
		cRetorno := strTran(cRetorno,aEspeciais[nItem,1],aEspeciais[nItem,2])
		cRetorno := strTran(cRetorno,upper(aEspeciais[nItem,1]),upper(aEspeciais[nItem,2]))
	next nItem
	
return cRetorno
                                                                                        
/*-------------------------------------------------------------------------------------
@function cBICalculaTempo(nTempoInicial)
Retorna Tempo decorrido entre (00:00:00 e 23:59:59)
@param nTempoInicial - Hora inicial.
@return - Tempo Decorrido
--------------------------------------------------------------------------------------*/
function cBICalculaTempo(nTempoInicial)
	local nTempoFinal, nTempoDecorrido, nHoras, nMinutos, nSegundos

	default nTempoInicial := seconds()

	nTempoFinal := seconds()

	nTempoDecorrido := nTempoFinal - nTempoInicial

	nHoras := int((nTempoDecorrido/60)/60)

	if(nHoras > 0)
		nTempoDecorrido -= ((nHoras*60)*60)
	endif

	nMinutos := int(nTempoDecorrido/60)

	if(nMinutos > 0)
		nTempoDecorrido -= (nMinutos*60)
	endif

	nSegundos := int(nTempoDecorrido)

	nTempoDecorrido -= nSegundos

return strzero(nHoras,2)+":"+strzero(nMinutos,2)+":"+strzero(nSegundos,2)+"."+strzero(nTempoDecorrido*1000,3)

/*-------------------------------------------------------------------------------------
@function cBICalculaTempo(nTempoInicial)
Envia uma instrucao para o browse iniciar um download.
@param cFilename - Nome do arquivo para inicar o download.
@return 
-------------------------------------------------------------------------------------*/   
function BIExecDownload(cFilename)
	local oFileHandle	:= TBIFileIO():new(cFilename)
	local cDados 		:= ''
	local cDownName 	:= ""

	if(oFileHandle:lOpen())
		if ".xls" $ cFilename .or. ".xml" $ cFilename
			HttpCTType( 'application/vnd.ms-excel;')
		elseif ".doc"  $ cFilename .or. ".dot" $ cFilename
			HttpCTType( 'application/msword;')			
		elseif ".ppt"  $ cFilename .or. ".pps" $ cFilename
			HttpCTType( 'application/vnd.ms-powerpoint;')   
		elseif ".pdf"  $ cFilename 
			HttpCTType( 'application/pdf;')
		elseif ".txt"  $ cFilename 
			HttpCTType( 'text/plain;')			
		elseif ".mpeg" $ cFilename .or. ".mpg" $ cFilename
			HttpCTType( 'video/mpeg;')
		elseif ".mov"  $ cFilename 
			HttpCTType( 'video/quicktime;')
		elseif ".jpg" $ cFilename .or. ".jpeg" $ cFilename
			HttpCTType( 'image/jpeg;')	
		elseif ".gif" $ cFilename 
			HttpCTType( 'image/gif;') 
		elseif ".swf" $ cFilename 
			HttpCTType( 'application/x-shockwave-flash;') 	
		elseif ".zip" $ cFilename 
			HttpCTType( 'application/zip;') 
		elseif ".rar" $ cFilename 
			HttpCTType( 'application/rar;') 
		elseif ".avi" $ cFilename 
			HttpCTType( 'video/avi;') 
		elseif ".rtf" $ cFilename 
			HttpCTType( 'application/rtf;') 
		elseif ".htm" $ cFilename .or. ".html" $ cFilename
			HttpCTType( 'text/html;') 
		elseif ".css" $ cFilename 
			HttpCTType( 'text/css;') 
		else
			HttpCTType( 'application/octet-stream;')
		endif 
		cDownName 	:= substr(cFilename,rat("\",cFilename)+1,len(cFileName))  
		cDownName	:= strTran(cDownName," ","%20")
		HttpSetPart(.T.)
		HttpCTDisp( 'attachment; filename="' + cDownName + '"')
		HttpCTLen(oFileHandle:nSize())
		cDados := space(1024)
		while(oFileHandle:nRead(@cDados) > 0)
			HttpSend(cDados)
		end
		oFileHandle:lClose()
	endif	

return
                
/*-------------------------------------------------------------------------------------
Realiza o envio gradual do conteúdo de um arquivo XML via HTTP.   
@param acFilename 	-> Nome e extenção do arquivo a ser enviado. 
@param alDebug 		-> Define se o XML gerado deve ser preservado. 
@retun nil
-------------------------------------------------------------------------------------*/
Function BIFileTransfer(acFilename, alDebug)
	Local oFileHandle
	Local cDados := ''

  	Default alDebug := .F.

	oFileHandle := TDWFileIO():new(acFilename)
   		
	if(oFileHandle:Open())
		cDados := space(1024)
		while(oFileHandle:Read(@cDados) > 0)
			HttpSend(cDados)
		end
		oFileHandle:Close() 
		
		/*Caso não esteja em modo de debug o arquivo será apagado do StartPath.*/
		If !(alDebug)
			oFileHandle:Erase()
		EndIf
	EndIf	
return

/*-------------------------------------------------------------------------------------
Retorna o separador DEFAULT do sistema operacional em uso.   
@retun (Caracter) Separador
-------------------------------------------------------------------------------------*/            
Function cBIGetSeparatorBar()
return iIf(isSrvUnix(), "/" /*Separador do Linux*/, "\" /*Separador do Windows*/)
    
/*
--------------------------------------------------------------------------------------
Tipo de banco de dados
@param 
@retun (lógico) Indica se a inicialização foi bem suscedida
--------------------------------------------------------------------------------------
*/       
Function cBIGetSGDB()
	Local cRet := Upper(AllTrim(TcGetDB()))

	If left(cRet,1) == '@'
		cRet := Substr(cRet, 5)
	Endif

Return cRet

/*
--------------------------------------------------------------------------------------
Concatenação de string com operador do banco de dados em uso. 
@param (Array) aParams Valores a serem concatenados.
@retun (Caracter) String concatenada com o operador adequado ao banco usado. 
--------------------------------------------------------------------------------------
*/       
Function cBISQLConcat(aParms)
	Local cRet 		:= ""
	      
	Default aParms 	:= {}
	
	If ("MSSQL" $ cBIGetSGDB()) 
		cRet := cBIConcatWSep("+", aParms)
	Else                             
		cRet := cBIConcatWSep("||", aParms)
	EndIf   
Return cRet   

/*
--------------------------------------------------------------------------------------
Web host utilizado
@param 
@retun (Caracter) WebHost utilizado
--------------------------------------------------------------------------------------
*/ 
function cBIGetWebHost()
	Local cAux, aAux, nPos
	Local cRet := ""
	
	If ValType(HttpHeadin->AHeaders) == "A" .and. len(HttpHeadin->AHeaders) > 0
		cAux := substr(HttpHeadin->AHeaders[1], at("/", HttpHeadin->AHeaders[1]))
		aAux := dwToken(cAux, "/")
		nPos := 0
		
		For nPos := 1 to len(aAux)
			if ".apw" $ cBIStr( aAux[nPos] )
				exit
			endif 
			
			if " HTTP" $ cBIStr( aAux[nPos] )
				exit
			endif 	
		Next
		aSize(aAux, nPos-1)
		cRet := HttpHeadin->Host + dwConcatWSep("/", aAux) 
		
		If !("http://" $ cRet)
			cRet := "http://" + cRet
		EndIf
	Else
		cRet := ""
	Endif

return cRet  

/*
--------------------------------------------------------------------------------------
Assegura que os paths utilizados na montagem de endereço completo de arquivos terminem 
com BARRA INVERTIDA. 
@Param
	 (Caracter) cPath  Path a ser tratado.
	 (Caracter) cBar   Barra que será utilizada para na URL. 
@Return
	 (Caracter) Path tratado com BARRA INVERTIDA (Ex.: \System\)
--------------------------------------------------------------------------------------
*/
function cBIFixPath(cPath, cBar)
	
	Default cBar := "/"	
	
	cPath 	:= Iif( (right(cPath,1) $ "\/"), cPath, cPath + "\" )
   	cPath 	:= StrTran(cPath, "\", cBar)
	cPath 	:= StrTran(cPath, "/", cBar)   

return cPath     

/*
--------------------------------------------------------------------------------------
 
@Param
	 (Caracter) cText    Texto a ser impresso
	 (Objeto)   oStream
	 (Boolean)  lDate
	 (Boolean)  lTime
	 (Boolean)  lSpaceBefore
	 (Caracter) cType   
@Return
	 (Caracter) Path tratado com BARRA INVERTIDA (Ex.: \System\)
--------------------------------------------------------------------------------------
*/
function BIConOut( cText, oStream, lDate, lTime, lSpaceBefore, cType )
	local nC    			:= 0
	local cLineText := ""
	
	Default cText 			:= ""
	Default lDate 			:= .T.
	Default lTime 			:= .T. 
 	Default lSpaceBefore 	:= .F. 
 	Default cType 			:= "" 
		
	if lDate
		cLineText := "[" + Left(DToC(MsDate()),5)
	end
	
	if lTime
		if lDate
			cLineText += "|"
		else
			cLineText += space(6) + "["
		end
		cLineText += Left( Time(),5 )
	end
	
	if !empty( alltrim( cLineText ) )
		cLineText += "]"
	end
	
	If !( Empty ( cType ) ) 
		cLineText += "["    
	    cLineText += Upper( AllTrim( cType ) )
		cLineText += "] "
	Endif 

	cLineText += cText
	ConOut( cLineText )
	
	if oStream <> nil
		if ValType( oStream ) == "O"
			If ( lSpaceBefore )
			 	oStream:WriteLN( Chr( 13 ) + Chr( 10 ) )
			EndIf
		
			oStream:WriteLN( cLineText )
		elseif ValType( oStream ) == "A"
			for nC := 1 to len( oStream )
				If ( lSpaceBefore )
			    	oStream[ nC ]:WriteLN( Chr( 13 ) + Chr( 10 ) )
		   		EndIf
			
				oStream[ nC ]:WriteLN( cLineText )
			next
		end
	end
return       
/*
--------------------------------------------------------------------------------------
 
@Param
	 (Caracter) pcFile    Nome de arquivo (com ou sem path) a ser tratado
@Return
	 (Caracter) Nome do arquivo sem o seu path
--------------------------------------------------------------------------------------
*/
Function cRemoveFilePath(pcFile)

	Local cFileName:= pcFile
	
	if ( rAt( "\" , pcFile ) > 0 )
	   cFileName:= substr(pcFile,rAt( "\" , pcFile ) + 1,len(pcFile))
	EndIf
	
return cFileName

/*-------------------------------------------------------------------------------------
Fim da biblioteca de funcoes BIFunctions.
--------------------------------------------------------------------------------------*/
