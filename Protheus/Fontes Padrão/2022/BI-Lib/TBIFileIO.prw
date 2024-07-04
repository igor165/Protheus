// ######################################################################################
// Projeto: BI Library
// Modulo : Foundation Classes
// Fonte  : TBIFileIO.prw
// -----------+-------------------+------------------------------------------------------
// Data       | Autor             | Descricao
// -----------+-------------------+------------------------------------------------------
// 15.04.2003   BI Development Team
// --------------------------------------------------------------------------------------

#include "BIDefs.ch"

/*--------------------------------------------------------------------------------------
@class: TBIObject->TBIFileIO
Classe que efetua o I/O em arquivos fisicos.
Características: 
	- Uma vez instanciado, matem o caminho para o arquivo, permitindo gravação
	em momentos diferentes do programa, mesmo que abrindo e fechando diversas vezes.
	- Executa operações fisicas como criação e exclusão do arquivo.
--------------------------------------------------------------------------------------*/
class TBIFileIO from TBIObject

	data fnHandle		// Guarda o handle obtido de fopen() na abertura ou criação
	data fcFilename		// Nome do arquivo fisico
	data fcFileCtrl		// FileCtrl
	data flCripto		// Indica se a leitura / gravação utiliza criptografia básica

	method New(cFilename, lCripto) constructor
	method NewFileIO(cFilename, lCripto)
	method Free()
	method FreeFileIO()

	method lCreate(nMode, lForcePath)
	method lOpen(nMode)
	method lClose()
	method lIsOpen()
	method nGetError()
	method lExists()
	method lErase()
	method lCopyFile()	
	method nSize()
	method nSeek(nOffSet, nOrigin)
	method nRead(cBuffer, nBytes)
	method nWrite(cBuffer, nBytes)
	method nWriteLN(cBuffer)
	method nGoBOF()
	method nGoEOF()
	method nGo(nOffset)
	method nChgFileExt(cFilename, cExtension)
	
	method nHandle()		// Handle associado ao arquivo
	method cFilename()		// Nome do arquivo
	method cChgFileExt(cFilename, cExtension)

endclass

/*--------------------------------------------------------------------------------------
@constructor New(cFilename, lCripto)
Constroe o objeto em memória, atribui nome ao arquivo mas não o abre, reserva p/ open().
@param cFilename - Nome do arquivo fisico.
@param lCripto - Indica se a leitura / gravação utiliza criptografia básica.
--------------------------------------------------------------------------------------*/
method New(cFilename, lCripto) class TBIFileIO
	::NewFileIO(cFilename, lCripto)	
return

method NewFileIO(cFilename, lCripto) class TBIFileIO
	default lCripto := .f.

	::NewObject()

	::fnHandle 		:= NIL
	::fcFilename 	:= StrTran( cFilename, "/", cBIGetSeparatorBar() )
	::fcFilename 	:= StrTran( cFilename, "\", cBIGetSeparatorBar() )	
	::fcFileCtrl 	:= ""                
	::flCripto 		:= lCripto
return

/*--------------------------------------------------------------------------------------
@destructor Free()
Limpa os recursos do objeto, fechando o arquivo se estiver aberto.
--------------------------------------------------------------------------------------*/
method Free() class TBIFileIO
	::FreeFileIO()
return

method FreeFileIO() class TBIFileIO
	if ::lIsOpen()
		::lClose()
	endif
	::FreeObject()
return     

/*-------------------------------------------------------------------------------------
@method nGetError()
Retorna o código de erro (FError) da última operação de I/O.
@return Código de erro (FError).
--------------------------------------------------------------------------------------*/
method nGetError() class TBIFileIO
return (FError())

/*-------------------------------------------------------------------------------------
@method lIsOpen()
Determina se o arquivo encontra-se aberto.
@return Indica se o arquivo está aberto.
--------------------------------------------------------------------------------------*/
method lIsOpen() class TBIFileIO
return (::nHandle() <> NIL)

/*-------------------------------------------------------------------------------------
@method lCreate(nMode, lForcePath)
Cria o arquivo em disco.
@param nMode - Modo de criação de arquivo, vide clipper Fileio.ch
@param lForcePath - Se .t., força a criação do diretório caso não exista. Default é .f.
@return Indica sucesso da operação de criação.
--------------------------------------------------------------------------------------*/
method lCreate(nMode, lForcePath) class TBIFileIO
	local cPath, nPos
	Local cBarra := cBIGetSeparatorBar()
	
	default nMode := FC_NORMAL
	default lForcePath := .f.

	if ::lIsOpen()
		::lClose()
	endif

	if(lForcePath)
		nPos := rat(cBarra,::cFilename())
		if(nPos>1)
			cPath := substr(::cFilename(), 1, nPos)
			BIForceDir(cPath)
		endif
	endif

	::fnHandle := FCreate(::cFilename(), nMode)
	if ::nGetError() <> 0 
		::fnHandle := NIL		
	end
return (::lIsOpen())

/*-------------------------------------------------------------------------------------
@method lOpen(nMode)
Abre o arquivo no disco.
@param nMode - Modo de criação de arquivo, vide clipper Fileio.ch
@return Indica sucesso da operação de abertura.
--------------------------------------------------------------------------------------*/
method lOpen(nMode)  class TBIFileIO
	default nMode := FO_READ
	
	if ::lIsOpen()
		::lClose()
	endif
	
	::fnHandle := FOpen(::cFilename(), nMode )
	if ::nGetError() <> 0 
		::fnHandle := NIL
	end
return (::lIsOpen())

/*-------------------------------------------------------------------------------------
@method lClose()
Fecha o arquivo.
@param nMode - Modo de criação de arquivo, vide clipper Fileio.ch
@return Indica sucesso da operação de fechamento.
--------------------------------------------------------------------------------------*/
method lClose() class TBIFileIO
	if ::lIsOpen()
		FClose(::nHandle())
		::fnHandle := NIL
	end
return (::nGetError() <> 0)

/*-------------------------------------------------------------------------------------
@method nRead(cBuffer, nBytes)
Le um buffer.
@param @cBuffer - Buffer a ser lido (recebera os dados).
@param nBytes - Tamanho do buffer a ser lido.
@return Numero de bytes lidos.
--------------------------------------------------------------------------------------*/
method nRead(cBuffer, nBytes) class TBIFileIO
	local nRet := -1   
	
	default cBuffer = space(SIZE_BUFFER)
	default nBytes = len(cBuffer) 
	
	if ::lIsOpen()
		nRet := FRead(::nHandle(), @cBuffer, nBytes)
		cBuffer := substr(cBuffer, 1, nRet)
		if ::flCripto
   			cBuffer := cBIUncripto(cBuffer)
  		endif
	endif             
return nRet

/*-------------------------------------------------------------------------------------
@method nWrite(cBuffer, nBytes, cTerminal)
Grava um buffer.
@param cBuffer - Buffer a ser gravado.
@param nBytes - Tamanho do buffer a ser gravado.
@return Numero de bytes gravados.
--------------------------------------------------------------------------------------*/
method nWrite(cBuffer, nBytes, cTerminal) class TBIFileIO
	local nRet := -1, cTemp
	
	if ::lIsOpen()
		default cBuffer := ''
		default cTerminal := ''
		cTemp := cBuffer + cTerminal
		default nBytes := len(cTemp)
		if ::flCripto 
			nRet := fWrite(::nHandle(), cBICripto(cBuffer, nBytes*2)+cTerminal, (nBytes*2)+len(cTerminal))
		else
			nRet := fWrite(::nHandle(), cBuffer+cTerminal, nBytes+len(cTerminal))
		endif
	end
return nRet

/*-------------------------------------------------------------------------------------
@method nWriteLN(cBuffer)
Grava uma linha no arquivo (cBuffer+CRLF).
@param cBuffer - Buffer a ser gravado na linha.
@return Numero de bytes gravados.
--------------------------------------------------------------------------------------*/
method nWriteLN(cBuffer) class TBIFileIO
return ::nWrite(cBuffer,, CRLF)

/*-------------------------------------------------------------------------------------
@method nGoBOF()
Posiciona o ponteiro no inicio do arquivo.
@return Numero de bytes deslocados.
--------------------------------------------------------------------------------------*/
method nGoBOF() class TBIFileIO
return ::nSeek(0, FS_SET) 

/*-------------------------------------------------------------------------------------
@method nGoEOF()
Posiciona o ponteiro ao final do arquivo.
@return Numero de bytes deslocados.
--------------------------------------------------------------------------------------*/
method nGoEOF() class TBIFileIO
return ::nSeek(0, FS_END) 

/*-------------------------------------------------------------------------------------
@method nGo(nOffset)
Posiciona o ponteiro no ponto nOffset do arquivo.
@nOffset - Indice físico (numero de bytes a partir do início do arquivo).
@return Numero de bytes deslocados.
--------------------------------------------------------------------------------------*/
method nGo(nOffset) class TBIFileIO
return ::nSeek(nOffset, FS_SET) 

/*-------------------------------------------------------------------------------------
@method nSize()
Retorna o tamanho do arquivo.
@return Numero de bytes deslocados.
--------------------------------------------------------------------------------------*/
method nSize() class TBIFileIO
	local nRet := -1
	
	if ::lIsOpen()
		nRet := FSeek(::nHandle(), 0, FS_END)
		FSeek(::nHandle(), 0)
	endif
return nRet

/*-------------------------------------------------------------------------------------
@method nSeek(nOffset, nOrigin)
Posiciona o ponteiro no ponto nOffset a partir de nOrigin.
@nOffset - Posição (número de bytes a partir de nOrigin).
@nOrigin - Ponto de origem.
@return Numero de bytes deslocados.
--------------------------------------------------------------------------------------*/
method nSeek(nOffSet, nOrigin) class TBIFileIO
	local nRet := -1
	
	if ::lIsOpen()
	   nRet := FSeek(::nHandle(), nOffSet, nOrigin)
	endif
return nRet  

/*-------------------------------------------------------------------------------------
@method lExists()
Verifica a existencia do arquivo.
@return Indica se existe o arquivo.
--------------------------------------------------------------------------------------*/
method lExists() class TBIFileIO
return (file(::cFilename()))

/*-------------------------------------------------------------------------------------
@method Exists()
Remove o arquivo do disco.
@return Indica se a remoção obteve sucesso.
--------------------------------------------------------------------------------------*/
method lErase() class TBIFileIO
return (ferase(::cFilename())!=-1)

/*-------------------------------------------------------------------------------------
@property nHandle()
Retorna o handle do arquivo.
@return Handle do arquivo.
--------------------------------------------------------------------------------------*/
method nHandle() class TBIFileIO
return (::fnHandle)

/*-------------------------------------------------------------------------------------
@property cFilename()
Retorna o nome do arquivo.
@return Nome do arquivo.
--------------------------------------------------------------------------------------*/
method cFilename() class TBIFileIO
return (::fcFilename)

/*-------------------------------------------------------------------------------------
@method cChgFileExt(cFilename, cExtension)
Troca a extensão do nome de arquivo.
@cFilename - Posição (número de bytes a partir de nOrigin).
@cExtension - Ponto de origem.
@return nome do arquivo com a nova extensão.
--------------------------------------------------------------------------------------*/
method cChgFileExt(cFilename, cExtension) class TBIFileIO
return cBIChgFileExt(cFilename, cExtension)

/*-------------------------------------------------------------------------------------
@method lCopyFile(cDestino)
Copia o arquivo da Origem para o destino.
@cDestino 	- Caminho e nome do arquivo de destino.
@cPath 		- Path do Core
@return Indica se a copia foi efetuada.
--------------------------------------------------------------------------------------*/
method lCopyFile(cDestino,cPath) class TBIFileIO
	local nTry 		:= 	0
	local lRet		:=	.T.
	local oDestino  := 	Nil
	local cBuffer	:=	""
	local nTamanho	:= 	0
	local nLidos	:=	0
	 
	Default cPath 	:= ""
	
	//Verifica se a origem esta aberta.
	do while( ! ::lIsOpen() .and.  nTry < 10)
		nTry ++
		::lOpen(FO_READ)		
		sleep(500)		
	enddo
	
	if(::lIsOpen())
		//Tenta criar o arquivo de destino.
		oDestino := TBIFileIO():New(cPath+cDestino)
		nTry := 0
		do while(!oDestino:lIsOpen() .and. nTry < 10)
			nTry ++
			oDestino:lCreate(FO_READWRITE + FO_EXCLUSIVE, .t.)
			sleep(500)		
		enddo

		//Verifica se o destino esta aberto.
		if(oDestino:lIsOpen())
			::nGoBOF()
			nTamanho := ::nSize()
			do while (nLidos <= nTamanho)
				nLidos += 1024
				::nRead(@cBuffer,1024)
				oDestino:nWrite(cBuffer,1024)			
			enddo
			::lClose()
			oDestino:lClose()
		else
			lRet := .F.
		endif
	else
		lRet := .F.
	endif
	
	return lRet

function __TBIFileIO()
return