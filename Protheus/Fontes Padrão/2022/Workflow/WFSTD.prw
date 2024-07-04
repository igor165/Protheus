#INCLUDE "WFSTD.ch"
#include "SigaWF.CH"


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFSTD     บAutor  ณSIGA5055-Yale       บ Data ณ  04/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณContem funcoes/procedures genericas para o Workflow.        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

// *-----------------------------------------------------------------------*
// | WFConcat                                                              |
// | Concatena os parametros, separandos os por ^A e CR                    |
// *-----------------------------------------------------------------------*
function WFConcat(cBuffer, AValues)
	if valType(AValues) == "A"
		aEval(AValues, { |x| cBuffer += asString(x) + chr(1)})
	else            
		cBuffer += asString(AValues) + chr(1)
	endif
	cBuffer += chr(2)
return


// *-----------------------------------------------------------------------*
// | WFToken                                                               |
// | Quebra a string, separandos os campos por ^A e registros CR           |
// *-----------------------------------------------------------------------*
Function WFTokenChar( cBuffer, cSeparator )
	local aResult := {}, nPos
	default cBuffer := "", cSeparator := ";"
	while ( nPos := At( cSeparator, cBuffer ) ) > 0
		AAdd( aResult, Left( cBuffer, nPos -1 ) )
		cBuffer := SubStr( cBuffer, nPos +1 )
	end
	if !Empty( cBuffer )
		AAdd( aResult, cBuffer )
	end
return aResult

function WFUnTokenChar( aParam, cSeparator )
	Local nC
	Local cResult := ""
	Default aParam := {}, cSeparator := ";"
	if Len( aParam ) > 0
		for nC := 1 to Len( aParam )
			if nC > 1
				cResult += cSeparator
			end
			cResult += AsString( aParam[ nC ] )
		next
	end
return cResult
	

function WFToken(cBuffer,Separator)
	local aRet, nInd, aAux
	DEFAULT Separator := Chr(2)
	aRet := WFTokenChar(@cBuffer, Separator)
	for nInd := 1 to len(aRet)
		if at(chr(1), aRet[nInd]) > 0
			aAux := WFTokenChar(aRet[nInd], chr(1))
			if len(aAux) > 1    
				aRet[nInd] := {}
				aRet[nInd] := aClone(aAux)
			else
				aRet[nInd] := aAux[1]
			endif
		endif
	next
return aRet

// *-------------------------------------------------------------------------------------*
// | WFCleanStr                                                          				 |
// | Limpa uma String removendo o caractere passado como parametro ou todos os especiais |
// | Nใo remove ponto-e-virgula e virgula pois estes sใo tratados no TWFProcess.         |
// *-------------------------------------------------------------------------------------*
function WFCleanStr(cBuffer,cCaractere)
Local cRet 			:= ""
Local aSpecial		:= {"'",'"',"!","?","$","#","&","จ","|"}
Local nI			:= 0
Local cAux			:= ""
Default cCaractere  := ""  
Default cBuffer 	:= ""

if !Empty(cCaractere)
	//Remove um caractere especifico passado como parametro
	For nI := 1 to len(cBuffer)
		if cCaractere != substr(cBuffer,nI,1)
			cAux += substr(cBuffer,nI,1)
		endif
	Next nI
else
    //Remove qualquer caractere especial contido em aSpecial
   	For nI := 1 to len(cBuffer)
		if aScan(aSpecial,substr(cBuffer,nI,1)) <= 0
			cAux += substr(cBuffer,nI,1)
		endif
	Next nI
endif
cRet := cAux

Return cRet


// *-----------------------------------------------------------------------*
// | WFOpenIndex                                                           |
// | Verifica a existencia do indice e abrindo-o em seguida                 |
// *-----------------------------------------------------------------------*

function OpenIndex(APrefixo, AIndex)
	local nInd

	for nInd := 1 to len(AIndex)
		WFOpenIdx(APrefixo, AIndex[nInd][1], .T., .F., nil, APrefixo)
	next                                 
return

/*
********************************************************************************
ATENวรO: A fun็ใo abaixo substitui a MSOpenIdx
********************************************************************************
*/
Function WFOpenIdx(cIndice,cChave,lUnique,lMensagem,oAction,cArquivo,nLin,nCol)
Local lOpen,bBlock,cAlias,cDriver,cCommand
nLin := Iif(nLin==Nil,18,nLin)
nCol := Iif(nCol==Nil,30,nCol)

cDriver := RddName()
lMensagem := Iif(lMensagem == Nil,.F.,lMensagem)
lMensagem := Iif(oAction == Nil,.F.,lMensagem)
bBlock := "{ || "+cChave +"}"

cArquivo := RetArq(cDriver,cArquivo,.T.)
cIndice	:= RetArq(cDriver,cIndice,.F.)
lOpen 	:= MSFILE(cArquivo,cIndice,cDriver)
If !lOpen	// Se cria Indice
//	If lMensagem
//		oAction:SetText(OemToAnsi(STR0006)) //"Criando Indice..."
//	EndIf

	If ( File( OrdBagName( RetFileName(cIndice) )+".CDX" ) )
		WFConout(cArquivo+" "+cIndice+" "+ProcName(1)+" "+Str(ProcLine(1)))
	EndIf

	If "CDX" $ cDriver
		cIndice	:= RetFileName(cIndice)
		cArquivo := FileNoExt(cArquivo)
//		IF lMensagem  	
//  		   ordCondSet( ,,,, {|| (SysRefresh(),.t.)}, 100, RECNO(),,,,)
//		endif   
		ordCreate(cArquivo,cIndice, cChave,&bBlock, )
	ElseIf cDriver != "TOPCONN"     .and. cDriver != "DBFNTXAX"
//	    IF lMensagem 
//  		  ordCondSet( ,,,, {|| (SysRefresh(),.t.)}, 100, RECNO(),,,,)
//  		endif  
		ordCreate(cIndice,, cChave,&bBlock, )
	Else
		INDEX ON &cChave to &cIndice
	EndIf
	#ifdef TOP
		If TCSRVTYPE() == "AS/400" .and. cDriver == "TOPCONN"
			cCommand := "CHGOBJOWN OBJ("+cIndice+") OBJTYPE(*FILE) NEWOWN(QUSER)"
			TCSYSEXE(cCommand)
		EndIf
	#endif
	dbcommit()
ElseIf !("CDX" $ cDriver )  // Seta Indice
	dbSetIndex( cIndice )
EndIf
Return

// *-----------------------------------------------------------------------*
// | int2Hex                                                               |
// | Converte numero inteiro para formato hexadecimal                       |
// *-----------------------------------------------------------------------*
function int2Hex(AValue, ASize)
local nValue := int(AValue), nResto := '', cResto := ''

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
return (padl(cResto, ASize, "0"))
                                 
// *-----------------------------------------------------------------------*
// | hex2Int                                                               |
// | Converte numero em formato hexadecimal para decimal                   |
// *-----------------------------------------------------------------------*
function _hex2Int(AValue)               
	local nInd, nPotencia := 0, nVal, nRet := 0, cDig

	for nInd := len(AValue) to 1 step -1
		cDig := substr(AValue, nInd, 1)
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
				nVal := val(cDig)
		endcase           
		nRet =+ nVal * (16 ** nPotencia)
	end            
return (nRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณWFLOADFILEบAutor  ณSIGA5055-Yale       บ Data ณ  06/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao ler o conteudo do arquivo mensionado pelo para- บฑฑ
ฑฑบ          ณmetro "cFile" e retorna este conteudo como resultado da     บฑฑ
ฑฑบ          ณoperacao.                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION WFLoadFile( cFile, nMode )
	LOCAL Result := "", cBuffer := ""
	LOCAL hFile
	LOCAL nLen, nBytes := 4096
	If nMode == NIL
		nMode := FO_READ + FO_SHARED
	End
	If ( hFile := WFOpen( cFile, nMode ) ) <> -1
		nLen := WFSeek( hFile, 0, FS_END )
		WFSeek( hFile, 0, FS_SET )
		While nLen > 0
			If nBytes > nLen
				nBytes := nLen
			End
			nBytes := WFRead( hFile, @cBuffer, nBytes )
			Result += cBuffer
			nLen -= nBytes
		End
		WFClose( hFile )
	End
RETURN Result

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณWFSAVEFILEบAutor  ณSIGA5055-Yale       บ Data ณ  06/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao grava fisicamente o conteudo do parametro       บฑฑ
ฑฑบ          ณ"cBuffer" no arquivo mensionado pelo parametro "cFile"      บฑฑ
ฑฑบ          ณe retorna .T. ou .F. como resultado da operacao.            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION WFSaveFile( cFile, cBuffer )
	LOCAL Result
	LOCAL hFile 
	default cBuffer := ""
	If ( Result := cFile <> NIL )
		If ( Result := ( hFile := WFCreate( cFile ) ) ) <> -1
			Result := WFWrite( hFile, cBuffer, Len( cBuffer ) ) <> -1
			WFClose( hFile )
		End
	End
RETURN Result

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณWFWRITE   บAutor  ณSIGA5055-Yale       บ Data ณ  06/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao escreve no arquivo fisicamente atraves do para- บฑฑ
ฑฑบ          ณmetro "nHandle" a quantidade de bytes possiveis pelo para-  บฑฑ
ฑฑบ          ณmetro "nBytes" contidos no parametro "cBuffer".             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION WFWrite( nHandle, cBuffer, nBytes )
	LOCAL Result := -1
	default cBuffer := "", nBytes := Len( cBuffer )
	If nHandle <> NIL
		Result := FWrite( nHandle, cBuffer, nBytes )
		If FError() <> 0 
			WFError( FormatStr( STR0001, FError() ) ) //"Nใo foi possํvel gravar no arquivo. DOS erro: %n"
		End
	End
RETURN Result

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณWFCREATE  บAutor  ณSIGA5055-Yale       บ Data ณ  07/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao Cria o arquivo mensionado pelo parametro "cFile"บฑฑ
ฑฑบ          ณe retorna o Handle desse arquivo.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION WFCreate( cFile, nMode )
	LOCAL Result := -1
	If cFile <> NIL
		If nMode == NIL
			nMode := FC_NORMAL
		End
		Result := FCreate( Lower( cFile), nMode )
		If FError() <> 0     
			WFFError( cFile, FError(), "WFCreate" ) 
		End
	End
RETURN Result

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณWFOPEN    บAutor  ณSIGA5055-Yale       บ Data ณ  07/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao abre o arquivo mensionado pelo parametro "cFile"บฑฑ
ฑฑบ          ณe retorna o Handle desse arquivo.                           บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION WFOpen( cFile, nMode )
	LOCAL Result
	If nMode == NIL
		nMode := FO_READ
	End
	Result := FOpen( cFile, nMode )
	If FError() <> 0     
		WFFError( cFile, FError(), "WFOpen" ) 
	End
RETURN Result

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณWFREAD    บAutor  ณSIGA5055-Yale       บ Data ณ  08/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao ler uma quantidade de bytes mencionado pelo     บฑฑ
ฑฑบ          ณparametro "nBytes" no arquivo aberto atraves de seu handle  บฑฑ
ฑฑบ          ณespecificado pelo parametro "nHandle" e armazena a quantida-บฑฑ
ฑฑบ          ณde de bytes lidos no parametro "cBuffer" e retorna a quanti-บฑฑ
ฑฑบ          ณdade lida. Caso o retorno for igual a -1 e que houve error. บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION WFRead( nHandle, cBuffer, nBytes )
	LOCAL Result := -1
	If nHandle <> NIL .And. cBuffer <> NIL .And. nBytes <> NIL
		Result := FRead( nHandle, @cBuffer, nBytes )
		If FError() <> 0 
			WFFError( "", FError(), "WFRead" ) 
		End
	End
RETURN Result

Static Function WFFError( pcArquivo, pcErro, pcOperacao ) 
	Default pcArquivo 	:= "" 
	Default pcErro    	:= ""
	Default pcOperacao 	:= ""

	WFConout( STR0031 ,,,,.T., pcOperacao )  //"Erro na manipula็ใo de arquivo em disco"
	If ( ! Empty( pcArquivo ) )  
	  	WFConout( STR0032 + cBIStr( pcArquivo ) ,,,,.T., pcOperacao )   //"Arquivo: "  
	EndIf   
	WFConout(  STR0033 + cBIStr( pcErro ) ,,,,.T., pcOperacao ) //"C๓digo do Erro: "
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณWFSEEK    บAutor  ณSIGA5055-Yale       บ Data ณ  08/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao posiciona em um determinado lugar especificado  บฑฑ
ฑฑบ          ณde um arquivo aberto atraves do parametro "nHandle" pelas   บฑฑ
ฑฑบ          ณespecificacoes dos parametros "nOffSet" e "nOrigin"         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION WFSeek( nHandle, nOffSet, nOrigin )
RETURN FSeek( nHandle, nOffSet, nOrigin )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณWFCLOSE   บAutor  ณSIGA5055-Yale       บ Data ณ  08/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao fecha um handle de um arquivo aberto anterior-  บฑฑ
ฑฑบ          ณmente pelas funcoes WFCreate ou WFOpen.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION WFClose( nHandle )
RETURN FClose( nHandle )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROCEDURE ณWFError   บAutor  ณSIGA5055-Yale       บ Data ณ  09/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao retorna um array com todas as ocorrencias       บฑฑ
ฑฑบ          ณencontradas entre os parametros "cFirstChar" e "cLastChar"  บฑฑ
ฑฑบ          ณem "cText". Caso nใo encontre-os, retorna um array vazio.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
PROCEDURE WFError( cMsg, lAbort )
	If cMsg == NIL
		cMsg := ""
	End
	If lAbort == NIL
		lAbort := .F.
	End
	If lAbort
		UserException( cMsg )
	Else  
		WFConout( cMsg,,,,,"WFERROR" ) 
	End
RETURN


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณGetPatternบAutor  ณSIGA5055-Yale       บ Data ณ  14/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao retorna um array com todas as ocorrencias       บฑฑ
ฑฑบ          ณencontradas entre os parametros "cFirstChar" e "cLastChar"  บฑฑ
ฑฑบ          ณem "cText". Caso nใo encontre-os, retorna um array vazio.   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION GetPatterns( cText, cFirstChar, cLastChar, bCond )
	LOCAL nC, nPos, nCount
	LOCAL Result := {}
	LOCAL cString, cString2
	If cText == NIL .Or. cFirstChar == NIL .Or. cLastChar == NIL
		RETURN Result
	End
	If bCond == NIL
		bCond := { || .T. }
	Else
		If ValType( bCond ) <> "B"
			If Type( bCond ) <> "B"
				bCond := { || .T. }
			End
		End
	End
	While .not. Empty( cText )
		If Empty( cString := ExtractStr( cText, cFirstChar, cLastChar ) )
			cText := cString
		Else
			If At( Upper( cFirstChar ), Upper( cString ) ) > 0
				cString2 := ""
				While .not. Empty( cText )
					cString2 += cString
					If CountStr( Upper( cFirstChar ), Upper( cString2 ) ) == ;
						CountStr( Upper( cLastChar ), Upper( cString2 ) )
						Exit
					End
					cString2 += cLastChar
					nPos := At( Upper( cString2 ), Upper( cText ) )
					cText := Stuff( cText, nPos, Len( cString2 ), "" )
					cString := ExtractStr( cText, cFirstChar, cLastChar )
				End
				cString := cString2
			End
			If Eval( bCond, cString )
				AAdd( Result, { cString, NIL } )
			End
			cString := cFirstChar + cString + cLastChar
			nPos := At( Upper( cString ), Upper( cText ) )
			cText := Stuff( cText, 1, nPos + Len( cString ) -1, "" )
		End
	End
RETURN Result

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณAtStr     บAutor  ณSIGA5055-Yale       บ Data ณ  28/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Retorna a posicao do parametro "cSearch" encontrada no     บฑฑ
ฑฑบ          ณ parametro "cTarget". Esta funcao tem o mesmo recurso que   บฑฑ
ฑฑบ          ณ a funcao "AT()", exceto pelo parametro "nRatPos" que       บฑฑ
ฑฑบ          ณ indica apartir da <n> ocorrencia do parametro "cSearch"    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION AtStr( cSearch, cTarget, nRatPos )
	LOCAL Result := 0, nC := 0, nPos
	If ValType( nRatPos ) <> "N"
		nRatPos := 1
	End
	If nRatPos > 1
		While nC < nRatPos .And. ( nPos := At( cSearch, cTarget ) ) > 0
			Result += nPos
			Result += ( Len( cSearch ) -1 )
			cTarget := Stuff( cTarget, nPos, Len( cSearch ), "" )
			nC++
		End
	Else
		Result := At( cSearch, cTarget )
	End
RETURN Result


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณExtractStrบAutor  ณSIGA5055-Yale       บ Data ณ  29/03/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao retorna o conteudo entre as strings informadas  บฑฑ
ฑฑบ          ณpelos parametros "cFirstChar" e "cLastChar" obtidas em      บฑฑ
ฑฑบ          ณ"cText".                                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION ExtractStr( cText, cFirstChar, cLastChar, lIncChars, lCase )
	LOCAL nPos
	LOCAL Result := ""
	If cText == NIL
		cText := ""
	End
	If cFirstChar == NIL
		cFirstChar := ""
	End
	If cLastChar == NIL
		cLastChar := ""
	End
	If lIncChars == NIL
		lIncChars := .F.
	End
	If lCase == NIL
		lCase := .F.
	End
	If .not. Empty( cText )
		If ( nPos := At( If( lCase, cFirstChar, Upper( cFirstChar ) ), If( lCase, cText, Upper( cText ) ) ) ) > 0
			If lIncChars
				nPos := nPos -1
			Else
				nPos := nPos + Len( cFirstChar ) -1
			End
			cText := Stuff( cText, 1, nPos, "" )
			If ( nPos := At(  If( lCase, cLastChar, Upper( cLastChar ) ), If( lCase, cText, Upper( cText ) ) ) ) > 0
				If lIncChars
					nPos += Len( cLastChar )
				End
				Result := SubStr( cText, 1, nPos -1 )
			End
		End
	End
RETURN Result				

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณCountStr  บAutor  ณSIGA5055-Yale       บ Data ณ  04/04/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao retorna o numero de ocorrencias encontradas     บฑฑ
ฑฑบ          ณpelo parametro "cString" em "cText".                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION CountStr( cString, cText )
	LOCAL Result := 0, nPos
	If cText <> Nil .And. cString <> Nil
		While ( nPos := At( cString, cText ) ) > 0
			nPos += Len( cString ) - 1
			cText := Right( cText, Len( cText ) - nPos )
			Result++
		End
	End
RETURN Result

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณFormatStr บAutor  ณSIGA5055-Yale       บ Data ณ  05/04/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao tem o mesmo recurso utilizado pela funcao       บฑฑ
ฑฑบ          ณ"Transform()", exceto por ser possivel utiliza-la em uma    บฑฑ
ฑฑบ          ณstring com mais de uma informacao. Ao contrario da funcao   บฑฑ
ฑฑบ          ณ"Transform()" que apenas formata uma por vez.               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบExemplos  ณ FormatStr( "A soma de 2 + 2 e igual a: %n", 2+2 )          บฑฑ
ฑฑบ          ณ FormatStr( "A soma de %n + n% e igual a: %n", { 2,2,2+2 } )บฑฑ
ฑฑบ          ณ FormatStr( "... valor total: %@E 999,999.99n", 1550.00 )   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบFormatacaoณ Tipos: %c, %n, %d, %l                                      บฑฑ
ฑฑบ          ณ Obs: (c)aracter,(n)umerico,(d)ata e (l)ogico em minusculo. บฑฑ
ฑฑบ          ณ A formatacao quando informada entre o "%" e o tipo, sera   บฑฑ
ฑฑบ          ณ formatado conforme a funcao "Transform()" disponibiliza.   บฑฑ
ฑฑบ          ณ Para maiores detalhes, veja a funcao "Transform()". Caso   บฑฑ
ฑฑบ          ณ contrario, apenas sera substituido pelo valor mensionado   บฑฑ
ฑฑบ          ณ sem qualque formatacao especifica. Claro, que todo valor   บฑฑ
ฑฑบ          ณ informado sera convertido para string.                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION FormatStr( cString, uValue )
	LOCAL nC, nPos
	LOCAL cFormat := ""
	If ValType( uValue ) == "A"
		For nC := 1 To Len( uValue )
			cString := FormatStr( cString, uValue[ nC ] )
		Next
	Else                                 
		Do Case
			Case ValType( uValue ) == "C"
				If Empty( cFormat := ExtractStr( cString, "%", "c",, .T. ) )
					If ( nPos := At( "%c", cString ) ) > 0
						cString := Stuff( cString, nPos, 2, uValue )
					End
				End
			Case ValType( uValue ) == "N"
				If Empty( cFormat := ExtractStr( cString, "%", "n",, .T. ) )
					If ( nPos := At( "%n", cString ) ) > 0
						cString := Stuff( cString, nPos, 2, Str( uValue ) )
					End
				End
			Case ValType( uValue ) == "D"
				If Empty( cFormat := ExtractStr( cString, "%", "d",, .T. ) )
					If ( nPos := At( "%d", cString ) ) > 0
						cString := Stuff( cString, nPos, 2, DToC( uValue ) )
					End
				End
			Case ValType( uValue ) == "L"
				If Empty( cFormat := ExtractStr( cString, "%", "l",, .T. ) )
					If ( nPos := At( "%l", cString ) ) > 0
						cString := Stuff( cString, nPos, 2, Transform( uValue, "L" ) )
					End
				End
		End
		If .not. Empty( cFormat )
			uValue := Transform( uValue, cFormat )
			If ( nPos := At( cFormat, cString ) ) > 0
				cString := Stuff( cString, nPos -1, Len( cFormat ) + 2, uValue )
			End
		End
	End
RETURN cString

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณAsString  บAutor  ณSIGA5055-Yale       บ Data ณ  06/04/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao retorna o valor informado pelo parametro        บฑฑ
ฑฑบ          ณ"uValue" convertido em string.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION AsString( uValue, lForMacro)
	LOCAL Result, nInd               
	default lForMacro := .f.
	
	Do Case
		Case ValType( uValue ) == "C" .Or. ValType( uValue ) == "M"
			Result := uValue
			if lForMacro 
				if .not. (left(Result, 1) $ "{'" +'"' .and. right(Result, 1) $ "}'" +'"')
					if left(Result,5) != 'ctod('
						Result := strTran(Result, "'", "'+chr(39)+'")
						Result := strTran(Result, chr(13), "'+chr(13)+'")
						Result := strTran(Result, chr(10), "'+chr(10)+'")
						Result := "'" + strTran(Result, '"', "'+chr(34)+'") + "'"
					endif                                        
				endif
			endif
		Case ValType( uValue ) == "N"
			Result := AllTrim( Str( uValue ) )
		Case ValType( uValue ) == "D"
			if lForMacro 
				Result := "ctod(" + chr(34) + dtoc(uValue) + chr(34) + ")"
			else
				Result := DToC( uValue )
			endif
		Case ValType( uValue ) == "L"
			Result := If( uValue, ".T.", ".F." )
		Case ValType( uValue ) == "A"
			Result := "{"
			for nInd := 1 to len(uValue)
				Result := Result + asString(uValue[nInd], lForMacro) + iif(nInd = len(uValue), "", ",")
			next
			Result := Result + "}"
		Case ValType( uValue ) == "B"
			Result := AsString( Eval( uValue ), lForMacro)
		Otherwise     
			if lForMacro
				Result := "NIL"
			else
				Result := ""
			endif
	End                                                
RETURN Result

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณHex2Int   บAutor  ณSIGA5055-Yale       บ Data ณ  07/04/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao retorna a conversao de um valor em Hexadecimal  บฑฑ
ฑฑบ          ณem um valor numerico.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION Hex2Int( cHex )
	LOCAL Result := -1
	LOCAL nC, nPos, nExpo := 0
	LOCAL xBase := "0123456789ABCDEF"
	LOCAL cChar
	cHex := Upper( AllTrim( AsString( cHex ) ) )
	If .not. Empty( cHex )
		Result := 0
		For nC := Len( cHex ) To 1 STEP -1
			If ( nPos := At( cChar := SubStr( cHex, nC, 1 ), xBase ) ) > 0
				Result += ( nPos -1 ) * ( 16 ** nExpo )
				nExpo++
			Else
				Result := -1
				Exit
			End
		Next
	End
RETURN Result

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณHex2Chr   บAutor  ณSIGA5055-Yale       บ Data ณ  10/04/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao retorna a conversao de um valor em Hexadecimal  บฑฑ
ฑฑบ          ณem um caracter.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION Hex2Chr( cHex )
	LOCAL Result := Hex2Int( cHex )
RETURN If( Result == -1, "", Chr( Result ) )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณExtractFilบAutor  ณSIGA5055-Yale       บ Data ณ  04/04/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao retorna o nome do arquivo informado pelo        บฑฑ
ฑฑบ          ณparametro "FileName" + a sua extensใo.                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION ExtractFile( FileName )
   Local Result := "", nPos
   If FileName <> NIL
      if ( nPos := Len( ExtractPath( FileName ) ) ) > 0
         Result := SubStr( FileName, nPos +1, Len( FileName ) )
      Else
         Result := FileName
      End
   End

Return Result

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณExtractPatบAutor  ณSIGA5055-Yale       บ Data ณ  04/04/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao retorna o Path do arquivo informado pelo        บฑฑ
ฑฑบ          ณparametro "FileName".                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION ExtractPath( cFileName )
	Local nPos
	default cFileName := ""
	if ( nPos := Rat( "\", cFileName ) ) == 0
		nPos := Rat( "/", cFileName )
	end
Return if( nPos > 0, Left( cFileName, nPos ), "" )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณExtractExtบAutor  ณSIGA5055-Yale       บ Data ณ  04/04/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao retorna a extensใo do arquivo informado pelo    บฑฑ
ฑฑบ          ณparametro "FileName".                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION ExtractExt( FileName )
   Local Result := "", nPos
   If FileName <> NIL
      If ( nPos := At( ".", FileName ) ) > 0
         Result := SubStr( FileName, nPos, Len( FileName ) )
      End
   End
Return Result

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณChgFileExtบAutor  ณSIGA5055-Yale       บ Data ณ  04/04/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณEsta funcao retorna o parametro "FileName" modificado com a บฑฑ
ฑฑบ          ณnova extensใo informada pelo parametro "Extension"          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION ChgFileExt( FileName, Extension )
   Local nPos := 0
   If FileName <> NIL .And. Extension <> NIL
	   FileName := AllTrim( FileName )
      If ( nPos := At( ".", FileName ) ) > 0
         FileName := Left( FileName, nPos - 1 ) + Extension
      Else
         FileName += Extension
      End
   End
Return FileName

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณRDDDefaultบAutor  ณAlan Candido        บ Data ณ  25/04/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna o RDD padrใo                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
function RDDDefault()
#IFDEF WNTX
return("DBFNTX")
#ELSE
return("DBFCDX")
#ENDIF


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRetEmails บAutor  ณMarcelo Abve        บ Data ณ  12/06/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna informacoes sobre os usuarios do grupo              บฑฑ
ฑฑบ          ณParams : Nome do Grupo                                      บฑฑ
ฑฑบ          ณParams : Nome do Cargo(Filtro)                              บฑฑ
ฑฑบ          ณParams : Nome do Departamento(Filtro)                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function RetEmails(cNomeGrupo,cCargo,cDepart)
Local aGroups := AllGroups(),aUsers  := AllUsers(.T.),i,j,cCodGrupo,cReturn := '' 	
    cNomeGrupo := Upper(cNomeGrupo)   
    
	//Pego o Codigo do Grupo
	For i:=1 To Len(aGroups)
	   if Upper(aGroups[i][1][2]) = cNomeGrupo 
	     cCodGrupo := aGroups[i][1][1] 
	     Exit
	   endif
	Next i
	
	//Procuro os usuarios que pertencam ao grupo 
	For i:=1 to Len(aUsers)
	  For j:=1 to Len(aUsers[i][1][10])
  	     if aUsers[i][1][10][j] = cCodGrupo .and. AllTrim(aUsers[i][1][14]) <> ''
  	       if (cCargo <> nil .and. cDepart <> Nil) 
  	         if Upper(AllTrim(aUsers[i][1][13])) = Upper(cCargo) .and.;
     	        Upper(AllTrim(aUsers[i][1][12])) = Upper(cDepart)
      	       cReturn := cReturn + Alltrim(aUsers[i][1][14]) + ';'  	         
    	     endif
  	       elseif ( cCargo = Nil .and. cDepart = Nil ) .or. ( cCargo <> Nil .and. Upper(AllTrim(aUsers[i][1][13])) = Upper(cCargo) ) .or.; 
     	      ( cDepart <> Nil .and. Upper(AllTrim(aUsers[i][1][12])) = Upper(cDepart) )
    	       cReturn := cReturn + Alltrim(aUsers[i][1][14]) + ';'
    	   endif    
  	     endif
  	  Next j   
	Next i 
   
    if cReturn <> '' 
      cReturn := Subs(cReturn,1,Len(cReturn)-1)
    endif
	   
Return cReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFZipFile บAutor  ณAlan Candido        บ Data ณ  03/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณCompacta um arquivo, retornado o nome do arquivo compactado บฑฑ
ฑฑบ          ณParams : Nome do Arquivo                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION WFZipFile( cFiles, cZipFile )
	LOCAL nC
	LOCAL cDir := ""
	LOCAL aFiles := {}
	
	DEFAULT cFiles := "\*.*"
	
	If cZipFile <> NIL 
	
// 	No AP609 qualquer extensao pode ser processada
//
//		If Empty( ExtractExt( cZipFile ) )
//			cZipFile := ChgFileExt( cZipFile, ".cab" )
//		End
		
		If !Empty( ExtractPath( cZipFile ) )
			WFForceDir( ExtractPath( cZipFile ) )
		End
	
		If ValType( cFiles ) == "A"
			If Len( cFiles ) > 0
				AEval( cFiles,{ |x| if( File( x ), AAdd( aFiles, x ), nil ) } )
			End
		Else
			cDir := ExtractPath( cFiles )
			If Len( cFiles := Directory( cFiles ) ) > 0
				for nC := 1 to Len( cFiles )
					if cFiles[ nC,5 ] <> "D"
						AAdd( aFiles, cDir + cFiles[ nC,1 ] )
					end
				next
			End
		End

		If Len( aFiles ) > 0
			MsCompress( aFiles, cZipFile )
		End
	End

RETURN aFiles


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณWFUnzipFileบAutor  ณAlan Candido        บ Data ณ  03/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสออออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDescompacta um arquivo                                       บฑฑ
ฑฑบ          ณParams : Nome do Arquivo Compactado                          บฑฑ
ฑฑบ          ณParams : Nome do Arquivo destino                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

FUNCTION WFUnZipFile( cZipFile, cExtractPath )
	LOCAL aFiles := {}
	If cZipFile <> NIL
		// 	No AP609 qualquer extensao pode ser processada
		//
		// 	If Empty( ExtractExt( cZipFile ) )
		// 		cZipFile := ChgFileExt( cZipFile, ".cab" )
		// 	End
		If File( cZipFile )
			If cExtractPath == NIL
				cExtractPath := ExtractPath( cZipFile )
			End
			WFForceDir( cExtractPath )
			aFiles := MsDecomp( cZipFile, cExtractPath )
		End
	End
RETURN aFiles

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROCEDURE ณWFMoveFileบAutor  ณSIGA5055 YALE       บ Data ณ  05/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMove o arquivo para um dado diretorio em                    บฑฑ
ฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION WFMoveFiles( cFiles, cDir )
	LOCAL hInFile, hOutFile
	LOCAL nC,nBytesRead, nBytes := 4096
	LOCAL cInFile, cOutFile, cBuffer, cDirFiles
	LOCAL lDone := .F.
	LOCAL aMoveFiles
	DEFAULT cDir := CurDir()
	If cFiles <> NIL
		cDirFiles := ExtractPath( cFiles )
		nMax := Max( Len( cDir ), Len( cDirFiles ) )
		if Left( cDir + Replicate( "*",nMax ),nMax ) <> Left( cDirFiles + Replicate( "*",nMax ), nMax )
			If Len( aMoveFiles := Directory( cFiles ) ) > 0
				cDir := AllTrim( cDir )
				If Right( cDir,1 ) <> "\"
					cDir += "\"
				End
				WFForceDir( cDir )
				For nC := 1 To Len( aMoveFiles )
					if aMoveFiles[ nC,5 ] <> "D"
						cInFile := ExtractPath( cFiles ) + aMoveFiles[ nC,1 ]
						If ( hInFile := WFOpen( cInFile, FO_READ + FO_SHARED ) ) <> -1
							cOutFile := cDir + aMoveFiles[ nC,1 ]
							If ( hOutFile := WFCreate( cOutFile ) ) <> -1
								cBuffer := Space( nBytes )
								While !lDone
									nBytesRead := WFRead( hInFile, @cBuffer, nBytes )
									If WFWrite( hOutFile, cBuffer, nBytesRead ) <> -1
										lDone := ( nBytesRead == 0 )
									Else
										Exit
									End
								End
							End
							WFClose( hOutFile )
							WFClose( hInFile )
							If lDone
								If File( cInFile )
									FErase( cInFile )
								End
							Else
								If File( cOutFile )
									FErase( cOutFile )
								End
								Exit
							End
							lDone := .F.
						End
					End
				Next	
			End
		End
	End
RETURN If( lDone, 0, -1 )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPROCEDURE ณWFForceDirบAutor  ณSIGA5055 YALE       บ Data ณ  05/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณForca a criacao de diretorio e seus subdiretorios caso nao  บฑฑ
ฑฑบ          ณvenham existir.                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION WFForceDir( cDir )
	LOCAL nPos
	LOCAL cRoot := ""
	LOCAL lResult := .f.

	DEFAULT cDir := ""

	cDir := AllTrim( StrTran( cDir, "\", "/" ) )
	
	If Right( cDir, 1 ) <> "/"
		cDir += "/"
	End

	While ( nPos := At( "/", cDir ) ) > 0
		If Empty( Left( cDir, nPos -1 ) )
			cRoot += Left( cDir, nPos )
		else
			if At( Right( Left( cDir, nPos -1 ),1 ), ":." ) > 0
				cRoot := Left( cDir, nPos -1 )
			else
				If Right( cRoot, 1 ) <> "/"
					cRoot += "/"
				End
				cRoot += Left( cDir, nPos -1 )
			end
			if Right( cRoot, 1 ) <> ":"
				lResult := ( Str( MakeDir( cRoot ),1 ) $ "05" )
			end
		End
		cDir := Stuff( cDir, 1, nPos, "" )
	End
	
RETURN lResult

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณWFCurDir   Autor  ณSIGA5055-Yale       บ Data ณ  18/07/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEsta funcao retorna o corrente diretorio do workflow e seus บฑฑ
ฑฑ           ณsub-diretorios pre-formatados.                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบExemplo   ณ? WFCurDir( 0 )             // "\WORKFLOW"                  บฑฑ
ฑฑบ          ณ? WFCurDir( WF_INBOX )      // "\WORKFLOW\INBOX"            บฑฑ
ฑฑบ          ณ? WFCurDir( WF_OUTBOX )     // "\WORKFLOW\OUTBOX"           บฑฑ
ฑฑบ          ณ? WFCurDir( WF_OUTBOX )     // "\WORKFLOW\SENDED"           บฑฑ
ฑฑบ          ณ? WFCurDir( WF_OUTBOX )     // "\WORKFLOW\ARCHIVE"          บฑฑ
ฑฑบ          ณ? WFCurDir( WF_OUTBOX )     // "\WORKFLOW\ERROR"            บฑฑ
ฑฑบ          ณ? WFCurDir( 0 ) + "\TESTE"  // "\WORKFLOW\TESTE"            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
FUNCTION WFCurDir( nDir )
	LOCAL cDir, aDir := { "INBOX", "OUTBOX", "SENDED", "ARCHIVE", "ERROR" }
	DEFAULT nDir := 0
	cDir := AllTrim( If( GetMV( "MV_WFDIR", .T. ), GetMV( "MV_WFDIR" ), "\WORKFLOW" ) ) 
	While ( Right( cDir,1 ) == "\" )
		cDir := Left( cDir, Len( cDir ) -1 )
	End
	If nDir > 0 .and. nDir <= Len( aDir )
		cDir += "\" + aDir[ nDir ]
	End
RETURN cDir

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบFUNCAO    ณWFGetNum  ณAutor  ณSIGA0548-Alan       บ Data ณ  09/08/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera um numero sequencial similar a GetSx8Num               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
*/
function WFGetNum(AParam)
	Local cLastAlias := Alias()
	Local aSX6     	:= {}
	Local aStruct  	:= {}
	Local lReclock 	:= .F. 
	local nVal 		:= 0
	Local nI 	   	:= 0
	Local nJ	   	:= 0

	aStruct := { "X6_FIL", "X6_VAR", "X6_TIPO", "X6_DESCRIC", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG" }

	//*********************************************
	// Este P.E. nใo deve ser publicado.
	//*********************************************
	Static  __lGetNUM := ExistBlock("WFGETNUM")
	
	If __lGetNum 
		Return( ExecBlock( "WFGETNUM", .F., .F., aParam ) )
    EndIf
	
	DbSelectArea( "SX6" )

	
	if SX6->( MSSeek( xFilial('SX6') + substr(AParam, 1, 10) ) )
		aStruct := { "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG" }

		nVal := val( SX6->X6_CONTEUD ) + 1
	
		aAdd( aSX6, { str(nVal, 10, 0), str(nVal, 10, 0), str(nVal, 10, 0) } )
	
	else
		nVal := 1
		lReclock := .T.

		aStruct := { "X6_FIL", "X6_VAR", "X6_TIPO", "X6_DESCRIC", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG" }
		aAdd( aSX6, { xFilial("SX6"), AParam, 'N', 'Usado para gera็ใo de c๓digo sequencial pelo SigaWF', str(nVal, 10, 0), str(nVal, 10, 0), str(nVal, 10, 0) } )
	endif

	For nI := 1 to len( aSX6 )
		RecLock( "SX6", lReclock )
			For nJ := 1 To Len( aSX6[nI] )
				If FieldPos( aStruct[nJ] ) > 0
					FieldPut( FieldPos( aStruct[nJ] ), aSX6[nI][nJ] )
				EndIf
			Next nJ
		MSUnlock('SX6')
	Next

	if !empty( cLastAlias )
		dbSelectArea( cLastAlias )
	endIF

	FWFreeArray( aSX6 )
	FWFreeArray( aStruct )
return nVal

function WFSaveObj( oObjClass, aPropList, aObjList )
	local nC
	local uValue, uProperty
	
	PRIVATE __oClass

	default aObjList := {}
	
	if oObjClass <> nil .and. aPropList <> nil

		for nC := 1 to Len( aPropList )
			__oClass := oObjClass
		
			if AScan( __oClass:aPropertyList, { |x| Upper( x ) == Upper( aPropList[ nC ] ) } ) > 0
				uProperty := "__oClass:" + aPropList[ nC ]
				uProperty := &uProperty
				
				if ValType( uProperty ) == "O"
					uValue := {}
					uValue := uProperty:SaveObj( uValue )
				else
					uValue := uProperty
				end
				
				AAdd( aObjList, { aPropList[ nC ], ValType( uProperty ), uValue } )
			end
			
		next
		
	end
	
return aObjList

function WFLoadObj( oObjClass, aPropList )
	local nC
	local uProperty 
	local aPropertyList
	if oObjClass <> nil .and. aPropList <> nil
		PRIVATE __oClass := oObjClass
		aPropertyList := oObjClass:aPropertyList
		for nC := 1 to Len( aPropList )
			if aPropList[ nC,2 ] <> "O"
				uProperty := aPropList[ nC,1 ]
				if AScan( aPropertyList, { |x| Upper( x ) == Upper( uProperty ) } ) > 0
					uProperty := "__oClass:" + uProperty
					&uProperty := aPropList[ nC,3 ]
				end
			end
		next
		
		for nC := 1 to Len( aPropList )
			if aPropList[ nC,2 ] == "O"
				uProperty := aPropList[ nC,1 ]
				if AScan( aPropertyList, { |x| Upper( x ) == Upper( uProperty ) } ) > 0
					__oClass:InitObj( uProperty )
					uProperty := "__oClass:" + uProperty
					&(uProperty):LoadObj( aPropList[ nC,3 ] )
				end
			end
		next

	end
			
return

Function WFGetMV( cParam, uDefault )
	Local cLastAlias := Alias()
	If Select( "SX6" ) > 0
		uDefault :=  If( GetMV( cParam, .T. ), GetMV( cParam ), uDefault )
		if ValType( uDefault ) == "C"
			uDefault := left( uDefault + space(250), 250 )
		EndIf   		 
		
		If ( Upper( AllTrim( cParam ) ) == "MV_WFMESSE" )  
			/*O valor do parโmetro ้ retornado de acordo com o VerSenha(130).*/
			uDefault := If( VerSenha(130) , uDefault, !(uDefault) )
		ElseIf ( Upper( AllTrim( cParam ) ) $ "MV_WFNF004|MV_WFREPRO" )  
			uDefault := xBIConvTo( 'L', uDefault )
		EndIf
	End  
	
	If !Empty( cLastAlias )
		DbSelectArea( cLastAlias )
	End  	
Return uDefault

Function WFAGetMV( aParams )
	Default aParams := {}
	AEval( aParams,{ |x,n| aParams[ n,2 ] := WFGetMV( x[1],x[2] ) } )
Return aParams

Function WFSetMV( cParam, uValue )
	Local lRecLock 	:= .F.
	Local aStruct 	:= {}
	Local aSX6		:= {}
	Local nI		:= 0
	Local nJ 		:= 0
	Local cContent
	Local uContent

	if Select( "SX6" ) > 0
		uContent := uValue

		if ValType( uValue ) == "L"
			uContent := if( uValue, "T", "F" )
		end

		cContent := AsString( uContent )

		if SX6->( dbseek( xFilial( "SX6" ) + cParam ) )
			aStruct := { "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG" }
			Aadd( aSX6, { cContent, cContent, cContent } )

			IF cParam $ 'MV_WFNF004|MV_WFREPRO'
				Aadd( aStruct, "X6_TIPO" )
				Aadd( aSX6[ 1 ], ValType( uValue ) )
			EndIf
		Else
			lRecLock := .T.

			aStruct := { "X6_FIL", "X6_VAR", "X6_TIPO", "X6_CONTEUD", "X6_CONTSPA", "X6_CONTENG" }
			aAdd( aSX6, { xFilial("SX6"), cParam, ValType( uValue ), cContent, cContent, cContent } )
		EndIf

		For nI := 1 To Len( aSX6 )
			RecLock( "SX6", lReclock )
				For nJ := 1 To Len( aSX6[nI] )
					If FieldPos( aStruct[nJ] ) > 0
						FieldPut( FieldPos( aStruct[nJ] ), aSX6[nI][nJ] )
					EndIf
				Next nJ
			MsUnLock()
		Next nI
	endIf

	FWFreeArray( aSX6 )
	FWFreeArray( aStruct )
return uValue

Function WFASetMV( aParams )
	local nC
	Default aParams := {}
	for nC := 1 to len( aParams )
		aParams[ nC,2 ] := WFSetMV( aParams[ nC,1 ], aParams[ nC,2 ] )
	next
Return aParams

function WFPrepEnv( __empresa, __filial, __funname, __tables, __module )
	Local nC         	:= 0
	Local cMsg        	:= 0
	Local nHandler 		:= -1
	Local cLCKFile 		:= "\semaforo"
	Local bLastError    := Nil
	Local nIntervalo 	:= 5
	Local lSemaforo 	:= WFGetMV( "MV_WFSEMAF", .t. )
	local nStack      	:= 0
	local lAviso 		:= .f.
	Local cAux			:= GetPvProfString(GetEnvServer(),"REGIONALLANGUAGE","",GetAdv97())
	Local lOpened		:= .F. 	
	
	Private lLastError 	:= .f.
	 
	Default __funname 	:= "WFPrepEnv"
	Default __tables 	:= {}
	
	//-------------------------------------------------------------------
	// For็a a atualiza็ใo do cPaisLoc.
	//------------------------------------------------------------------- 	
	If ! Empty( cAux )
		Public cPaisLoc := cAux 
	ElseIf ( Type("cPaisloc") == "U" ) 
		Public cPaisLoc := "BRA"
	EndIf

	//-------------------------------------------------------------------
	// Verifica se tem algum ambiente aberto.  
	//------------------------------------------------------------------- 	
	If ! ( Select( 'SM0' ) == 0 )
		lOpened := .T. 
	  
		If ! ( __empresa == Nil )
			//------------------------------------------------------------------- 
			// Verifica se o ambiente aberto ้ o solicitado.         
			//------------------------------------------------------------------- 	
			If ! ( AllTrim( SM0->M0_CODIGO ) == AllTrim( cBIStr( __empresa ) ) )  
				//------------------------------------------------------------------- 
				// Fecha o ambiente atual para abertura do ambiente solicitado. 
				//------------------------------------------------------------------- 
				RpcClearEnv()
				lOpened := .F. 
			EndIf 
		EndIf
	EndIf  
	
	//-------------------------------------------------------------------
	// Verifica deve abrir o ambiente.  
	//------------------------------------------------------------------- 	
	If ! ( lOpened )
		if ( __empresa <> nil ) .and. ( __filial <> nil )
			WFForceDir( cLCKFile )
			cLCKFile += lower( "\wfpenv" + __empresa + ".lck" )
			
			while !KillApp() .and. ( select( "SM0" ) == 0 )
				if ( lSemaforo )
					if ( nHandler := FCREATE( cLCKFile, FC_NORMAL ) ) <> -1
						cMsg := "Thread ID: " + alltrim( str( ThreadID() ) ) + " -" + STR0012 + DtoC( MsDate() ) + " -" + STR0013 + Time()    //DATA , HORA
						FWrite( nHandler, cMsg, Len( cMsg ) )
					else
						if ( nIntervalo >= 30 ) .and. ( nIntervalo < 35 )
							WFConout( STR0010 + STR0011 + chr(13)+cLCKFile + "  Thread " + str( ThreadID() )) //"[ATENCAO] Esta ocorrendo enfileiramento de threads no servi็o de conexใo de arquivos de sistemas"
							lAviso := .t.
							nStack := 1
							cStack := "Thread " + str( ThreadID() )
							while !(procName(nStack) == "")
								cStack += + " -> " + procname(nStack) + ":" + str(procline(nStack),6)
								nStack++
							enddo
							WFConout(cStack)
						else
							if nIntervalo == 60
								WFConout( "[MAIL] " + STR0014 )//"[MAIL] Preparando email para a lista de administradores"
								WFPrepMail()
							else
								
								if nIntervalo > 180  // se for maior que 3 minutos...
									nIntervalo := 5   // volta a 5 segundos
								endIf
							endIf
						endIf
						
						nIntervalo += 5
						Sleep( randomize(5,15) * 1000 )
					endIf
				endIf
				
				lLastError := .f.
				bLastError := ErrorBlock( {|e| WFPrepError( e ) } )

				BEGIN SEQUENCE
					RPCSetType( WF_RPCSETTYPE )				
					PREPARE ENVIRONMENT EMPRESA __EMPRESA FILIAL __FILIAL FUNNAME __FUNNAME MODULO __MODULE
				END SEQUENCE
				
				If ( select("SM0") > 0 )   
					WFConout(STR0026,,,,,"WFPREPENV" )//"Inicializa็ใo de ambiente"
				else
					WFConout(STR0027 + lower(STR0026),,,,,"WFPREPENV")//"Problema na inicializa็ใo do ambiente"
				endif
				
				WFConout(STR0028 + cBIStr( __empresa ),,,,,"WFPREPENV"  )//"Empresa: " 
				WFConout(STR0029 + cBIStr(__filial )  ,,,,,"WFPREPENV" )//"Filial: " 
				WFConout(STR0030 + cBIStr(__funname ) ,,,,,"WFPREPENV" )//"Fun็ใo: " 

				ErrorBlock( bLastError )
				
				if ( lSemaforo )
					if ( nHandler <> -1 )
						FClose( nHandler )
						nHandler := -1
					endIf
				endIf
				
				if !( lLastError ) .and. ( select( "SM0" ) > 0 )
					
					for nC := 1 to len( __tables )
						ChkFile( __tables[ nC ] )
					next
				endIf
			endDo
		endIf
	endIf
return ( select( "SM0" ) <> 0 )

Function WFPrepMail()
	local cMailBox := upper( alltrim( WFGetMV( "MV_WFMLBOX" ) ) )
	local cMailAdmin := alltrim( WFGetMV( "MV_WFADMIN" ) )
	local cSMTP
	local cEndereco
	local cConta
	local cSenha

	Local lOk   := .F.
	Local cErro := ''
	
	if empty( cMailBox ) .or. empty( cMailAdmin )
		WFConout( "[EMAIL] " + STR0015  )//"Nao ha configuracoes definidas para o servico de email do workflow"
		return
	endIf
	
	dbSelectArea( "WF7" )
	dbSetOrder(1)
	
	cFindKey := xFilial( "WF7" )
	cFindKey += cMailBox
	
	if dbSeek( cFindKey )
		cSMTP	 	 := WF7->WF7_SMTPSR
		cConta 	 := WF7->WF7_CONTA
		cSenha	 := WF7->WF7_SENHA
		cEndereco := WF7->WF7_ENDERE
	else
		WFConout( "[EMAIL] " + STR0016 + cMailBox ) //"Caixa de correio nใo encontrada: "
		return
	endIf
 
	CONNECT SMTP SERVER cSMTP ACCOUNT cConta  ;
              PASSWORD cSenha RESULT lOK
 
	If ( lOk )
	    SEND MAIL FROM cEndereco   ;
	                TO cMailAdmin     ;
	                SUBJECT  STR0017 + STR0018         ; //'[URGENTE] ENFILEIRAMENTO DE THREADS'
	                BODY STR0019 + STR0020      ;//'Hแ enfileiramento de threads no servidor. Favor verificar com URGENCIA!'
	                RESULT lOk
	 
		If ( !lOk )
			GET MAIL ERROR cErro
				WFConout( '[EMAIL] ' + STR0021 + STR0022 + cErro ) //Erro durante o envio 
		EndIf
	 
		DISCONNECT SMTP SERVER RESULT lOK
	 
		If ( !lOk )
			GET MAIL ERROR cErro
				WFConout( '[EMAIL] '+ STR0021 + STR0024	 + cErro ) //"Erro durante a desconexใo" 
		EndIf
	 
	Else
 
	    GET MAIL ERROR cErro
			WFConout( '[EMAIL] ' + STR0021 + STR0023  + cErro )//"Erro durante a conexใo" 
	EndIf
 
return


FUNCTION WFPrepError( oE )
   lLastError := .t.
	WFConout(STR0025 + "(prepare environment): " + oE:Description)  //"Descricao do erro"
	If oE:GenCode > 0
		if FindFunction( "U_WFPE003" )
			StartJob( "WFLauncher", GetEnvServer(), .f., { "U_WFPE003",	{ oE:Description, oE:ErrorEnv, oE:ErrorStack } } )
		end
		BREAK
	end
return

function WFConOut( cText, oStream, lDate, lTime, lSpaceBefore, cType )
	BIConOut( cText, oStream, lDate, lTime, lSpaceBefore, cType ) 
Return

Function WFX3Title( cFieldName )
	Local cResult 		:= ""
	Local nOrder 			:= SX3->( IndexOrd() )  	
	Default cFieldName 	:= ""
	
	SX3->( DbSetOrder( 2 ) )
	
	if SX3->( DbSeek( cFieldName ) )
		cResult := X3Titulo()
	end
	SX3->( DbSetOrder( nOrder ) )
return cResult

/*Retorna a diferenca entre dois periodos(Data e Hora) em Horas*/
Function DifPeriodo(dDtIni,cHrIni,dDtFim,cHrFim)
Local nHora,nDif1,nDif2,nSubTot
   if dDtIni = Nil .or. cHrIni = Nil .or. dDtFim = Nil .or. cHrFim = Nil 
     Return "00:00:00"
   endif
   nHora := (dDtFim - dDtIni - 1) * 24 * 3600
   nDif1:=HoraToSec('24:00:00')-HoraToSec(cHrIni)
   nDif2:=HoraToSec(cHrFim)   
   nSubTot := nDif1+nDif2
Return Alltrim(SecToHora(nSubTot+nHora))

//Transforma Horas(hh:mm:ss) em Segundos(n)
Function HoraTOSec(Hora)
//Return ( (Val(Subs(Hora,1,At(':',Hora)-1)*3600 + Val(Subs(Hora,Length(Hora)-4,2))) * 60 ) + Val(Subs(Hora,Length(Hora)-1,2)      
 Hora := Alltrim(Hora)
Return ( (Val(Subs(Hora,1,At(':',Hora)-1))*60+Val(Subs(Hora,Length(Hora)-4,2))) * 60 ) + Val(Subs(Hora,Length(Hora)-1,2));

//Transforma Segundos(n) em Horas(hh:mm:ss)
Function SecTOHora(Sec)
Local nHora,nMin,nSec
  nHora := Int(Sec/3600)
  nMin  := Int((Sec - (nHora * 3600))/60 ) 
  nSec  := (Sec - (nHora * 3600)) - (nMin * 60)
Return Str(nHora)+':'+StrZero(nMin,2)+':'+StrZero(nSec,2)     

//Grava ID no campo do Alias. O registro ja deve estar posicionado
Function WFSalvaID(cAlias,cCampo,cID)
   RecLock(cAlias)
   &cCampo := cID 
   MsUnlock()
Return .T.

//Retorna o codigo do Usuario
Function WFCodUser(cUser)
Local aUsers := AllUsers(.T.),i,cCodUser:=""
   For i:=1 to Len(aUsers)
     if Alltrim(upper(aUsers[i][1][2])) == Alltrim(upper(cUser))
       cCodUser := aUsers[i][1][1] 
       exit
     endif
   Next 
Return cCodUser

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WFSeleF3
 Retorna uma string de todas as tabelas do SXB.
   
@param 		ID do processo.  
@author     ?
@version   	P10
@since      ?
/*/
//------------------------------------------------------------------------------------- 
Function WFSeleF3()
	local nC
	local aF3
	local cResult := ""

	aF3 := SeleF3()
	for nC := 1 to len( aF3 )
		if !empty( cResult )
			cResult += ";" 
		end 
		if !Empty( aF3[nC] )
			cResult += Left( aF3[nC] + Space(30),30 )
		end
	next
return cResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} extProcID
Recupera o ID do processo.
   
@param 		ID do processo.  
@author     ?
@version   	P10
@since      ?
/*/
//------------------------------------------------------------------------------------- 
function extProcID( acProcessID )
	Local cRet 	:= AllTrim( acProcessID )
	Local nPos 	:= At( ".", acProcessID )
	
	If ( nPos > 0 )
		nPos -= 1
	ElseIf ( len( acProcessID ) >= 20 ) //Tamanho do ID de processos com 8 posi็๕es. 
		nPos := WF_PROC_ID_LEN
	Else
		nPos := WF_OLD_PROC_ID_LEN
	EndIf
Return SubStr( cRet, 1, nPos )

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} extTaskID
Recupera o ID da tarefa.
   
@param 		ID do processo.  
@author     ?
@version   	P10
@since      ?
/*/
//-------------------------------------------------------------------------------------
function extTaskID( acProcessID )
	Local cRet := AllTrim( acProcessID )
	Local nPos := At( ".", acProcessID )
	
	If ( nPos > 0 )
		nPos += 1
	ElseIf ( len( acProcessID ) >= 20 ) //Tamanho do ID de processos com 8 posi็๕es. 
		nPos := WF_PROC_ID_LEN + 1
	Else
		nPos := WF_OLD_PROC_ID_LEN + 1
	EndIf
Return Substr( cRet, nPos, WF_TASK_ID_LEN )
       
//-------------------------------------------------------------------------------------
/*/{Protheus.doc} WFHtmlTemplate
Template HTML para mensagens do Workflow.
   
@param 		Tํtulo da mensagem.  
@param      Conte๚do da mensagem.
@param      Tํtulo do conte๚do.  
@author    	Valdiney V. Gomes 
@author     Pedro I. Gomes
@version   	P10
@since      05/10/2011
/*/
//-------------------------------------------------------------------------------------  
Function WFHtmlTemplate(cTitle, cMessage, cMessageTitle ) 
	Local cHTML 			:= ""
	
	Default cTitle   		:= ""
	Default cMessage        := ""
	Default cMessageTitle 	:= '<br>'

	cHTML += '<html>'
	cHTML += '    <head>'
	cHTML += '        <title>Workflow</title>'
	cHTML += '        <meta content="text/html; charset=iso-8859-1" http-equiv="Content-Type">'
	cHTML += '        <style>'
	cHTML += '            .texto {'
	cHTML += '                color: #666666;'
	cHTML += '                font-family: Verdana;'
	cHTML += '                font-size: 10px;'
	cHTML += '                background-color: #FFFFFF;'
	cHTML += '                margin: 0px;'
	cHTML += '                padding: 0px;'
	cHTML += '                border-collapse: collapse;'    
	cHTML += '            }'
	cHTML += '            .titulo{'
	cHTML += '                font-family: Verdana, Arial, Helvetica, sans-serif;'
	cHTML += '                font-size: 16px;'
	cHTML += '                font-weight: bold;'
	cHTML += '                color: #406496;'
	cHTML += '                margin: 0px;'
	cHTML += '                padding: 0px;'
	cHTML += '            }'
	cHTML += '            .tabela {'
	cHTML += '                color: #000000;'
	cHTML += '                padding: 0px;'
	cHTML += '                border-collapse: collapse;'
	cHTML += '            }'
	cHTML += '            .tabela tr td {border:1px solid #CFCFCF;}'
	cHTML += '            .texto {'
	cHTML += '                color: #666666;'
	cHTML += '                font-family: Verdana;'
	cHTML += '                font-size: 10px;'
	cHTML += '                background-color: #FFFFFF;'
	cHTML += '                margin: 0px;'
	cHTML += '                padding: 0px;'
	cHTML += '                border-collapse: collapse;'    
	cHTML += '            }'
	cHTML += '            .titulo{'
	cHTML += '                font-family: Verdana, Arial, Helvetica, sans-serif;'
	cHTML += '                font-size: 16px;'
	cHTML += '                font-weight: bold;'
	cHTML += '                color: #406496;'
	cHTML += '                margin: 0px;'
	cHTML += '                padding: 0px;'
	cHTML += '            }'
	cHTML += '            .cabecalho_2 {'
	cHTML += '                color: #000000;'
	cHTML += '                font-weight: bold;'
	cHTML += '                font-family: Verdana;'
	cHTML += '                font-size: 10px;'
	cHTML += '                text-transform: uppercase;'
	cHTML += '                background-color: #DFE5F3;'
	cHTML += '                border-collapse: collapse;'
	cHTML += '                margin: 3px;'
	cHTML += '                padding: 3px;'
	cHTML += '            }'
	cHTML += '        </style>'
	cHTML += '    </head>'
	cHTML += '    <body leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">'
	cHTML += '        <table width="100%" border="0" cellpadding="0" cellspacing="0">'
	cHTML += '            <tr>'
	cHTML += '                <td>'
	cHTML += '                    <table width="100%" border="0" cellpadding="0" cellspacing="0" class="tabela">'
	cHTML += '                        <tr>'
	cHTML += '                            <td width="150" align="center" class="texto">' + AllTrim( WFVersion()[6] ) + '</td>'
	cHTML += '                            <td class="titulo"><div align="center"><br>' + AllTrim( cTitle ) + '<br><br></td>'
	cHTML += '                            <td width="150" align="center" class="texto">' + cBIStr( Date() ) + '</td>'
	cHTML += '                        </tr>'
	cHTML += '                    </table>'
	cHTML += '                </td>'
	cHTML += '            </tr>'
	cHTML += '            <tr>'
	cHTML += '                <td>&nbsp;</td>'
	cHTML += '            </tr>'
	cHTML += '        </table>'
	cHTML += '        <table width="80%" border="0" align="center" cellpadding="0" cellspacing="0" class="tabela">'
	cHTML += '            <tr>'
	cHTML += '                <td width="23%" class="cabecalho_2">' + AllTrim( cMessageTitle ) + '</td>'
	cHTML += '            </tr>'
	cHTML += '            <tr>'
	cHTML += '                <td width="23%" class="texto">'
	cHTML += 				   		'<br>' + AllTrim( cMessage ) + '<br><br>' 
	cHTML += '                </td>'
	cHTML += '            </tr>'
	cHTML += '        </table>'
	cHTML += '    </body>'
	cHTML += '</html>'
Return cHTML

