#DEFINE CRLF chr( 13 ) + chr( 10 )
#DEFINE GUIAS_MONITORAMENTO "1"
#DEFINE FORNECIMENTO_DIRETO "2"
#DEFINE OUTRA_REMUNERACAO "3"
#DEFINE VALOR_PREESTABELECIDO "4"

#include "FWMVCDEF.CH"
#include "totvs.ch"
#include "protheus.ch"
#include "PLSMGER.CH"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM270XTR
Importação do arquivo de retorno .XTR

@author    Jonatas Almeida
@version   1.xx
@since     23/08/2016
/*/
//------------------------------------------------------------------------------------------
function PLSM270XTR(lAuto)
	local cTitulo	:= "Importar arquivo de retorno - TISS"
	local cTexto	:= CRLF + CRLF + "Esta opção irá efetuar a leitura do arquivo de retorno .XTR" + CRLF +;
		"a ser disponibilizado pela ANS e importado pela operadora"
	local aOpcoes	:= { "Processar","Cancelar" }
	local nTaman	:= 3
	local nOpc		:= 0
	default lAuto 	:= .f.

	if valtype(lAuto) <> 'L'
		lAuto := .f.
	endif

	if !lAuto
		nOpc	:= aviso( cTitulo,cTexto,aOpcoes,nTaman )
	endif
	B4P->(dbSetOrder(1))
	If B4P->(FieldPos("B4P_CODGRU")) <=  0
		MsgInfo("Ambiente desatualizado realize a atualização de dicionários.")
		return
	EndIf		
	
	if( nOpc == 1 ) .or. lAuto
		PLSM270Proc(lAuto)
	endIf
return
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM270Proc
Abre janela de dialogo para importação dos arquivos em lista

@author    Eduardo Bento
@version   1.12
@since     13/05/2019
/*/
//------------------------------------------------------------------------------------------
Function PLSM270Proc(lAuto)
Local nFor			:= 0   		// Contador para loop
Local cDirOri 	   	:= ""  		// Recebe diretório dos arquivos
Local aArquivos	   	:= {}  		// Array para receber arquivos do dir.
Local aLista	   	:= {}		// Array para listar arquivos
Local lOk			:= .F.		// Flag de ausência de erros - T-sem erros F-com erros
Local lRet			:= .T.    	// Variavel de retorno para verificar se foram selecionados os arquivos ou não
Local cExtensao		:= "*.XTR" 	// Aux para extenção do arquivo
Local cFileXTR 		:= "" 		// Arquivo, incluso seu endereço
Local cPath			:= getNewPar( "MV_TISSDIR","\TISS\" ) + "TEMP\" // Dir. do servidor para arquivo temporário
Local aResumoLeitura:= {} 		// Registra informações do processamento para o resumo
Local aErros		:= {}		// Registra o número de processamentos com problema
//--- cGetFile ----- Argumentos para montar a tela
Local cMascara		:= "Todos os Arquivos|*.*|"	
Local cTitulo		:= "Selecione o diretorio dos arquivos 1558"
Local cRootPath		:= ""
Local lSalvar		:= .T.		//.F. = Salva || .T. = Abre
Local cArqTmp		:= "" 		// Arquivo para enviar de argumento para function de processamento
//--- PLSSELOPT ----- Argumentos para montar a tela
Local aMatCol		:= {}		// Aux para montar a tela
Local cTitulo2		:= "Selecione o(s) arquivos(s) a serem importados"
Local cDesc			:= "Marca e Desmarca todos"
default lAuto 	:= .f.

// Seleciona o diretório
if !lAuto
	cDirOri	  := cGetFile(cMascara,cTitulo,,cRootPath,lSalvar,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
else
	cDirOri := "\sigapls\plsm270testcase\"
endif
If Empty(cDirOri) // cancelou a janela de selecao do diretorio
	lRet := .F.
	Return(lRet)
EndIf

// Busca por arquivos com a extenção .XTR
aArquivos := directory(cDirOri+cExtensao)

If Len(aArquivos) > 0 // Se houver algum arquivo .XTR
	
	// Monta lista de arquivos
	For nFor := 1 to len(aArquivos)
		aAdd(aLista,{aArquivos[nFor][1],DtoC(aArquivos[nFor][3]),aArquivos[nFor][4],AllTrim(transform(aArquivos[nFor][2]/1000,"@E 999,999,999.99"))+" KB",iif(lAuto,.t.,.F.)})
	Next
	
	aLista := aSort(aLista,,, { |x,y| DTOS(CTOD(x[2])) < DTOS(CTOD(y[2])) })
	
	// Colunas do browse
	aAdd( aMatCol,{"Arquivo"	,'@!',200} )
	aAdd( aMatCol,{"Data"		,'@!',040} )
	aAdd( aMatCol,{"Hora"		,'@!',040} )
	aAdd( aMatCol,{"Tamanho"	,'@!',040} )
		
	// Browse para selecionar
	if !lAuto
		lOk := PLSSELOPT ( cTitulo2, cDesc, aLista, aMatCol, K_Incluir,.T.,.T.,.F.)
	else
		lOk := .t.		
	endif
	
	// Verifica se algum arquivo foi selecionado
	If lOk
		lOk := aScan(aLista,{|x| x[len(aLista[1])] == .T.}) > 0
	EndIf

	// Processando arquivos
	If lOk
				
		For nFor := 1 To Len(aLista) //Abertura do loop para varrer a lista de opções
			If aLista[nFor][05] .AND. ( !Empty(aLista[nFor][01]) ) // Verifica se foi selecionado e se o arquivo correspondente tem nome
				cFileXTR := cDirOri + aLista[nFor][01] // Construção do endereço do arquivo
				
				If( At( ":\",cFileXTR ) <> 0 )	//--< COPIA ARQUIVO TEMPORARIO PARA SERVIDOR >---
					
					If( !existDir( cPath ) )
						MakeDir( cPath )
					EndIf
					
					If lAuto .or. ( CpyT2S( cFileXTR,cPath,.F.,.F. ) )
						cArqTmp := cPath + substr( cFileXTR,rat( "\",cFileXTR ) + 1 ) //Extrai o nome apenas
						LerArqLista( cArqTmp, aResumoLeitura, aErros) // Chamado da função para processamento do arquivo
						If( fErase( cArqTmp ) == -1 )	//--< EXCLUI ARQUIVO TEMPORARIO >---
						EndIf
					EndIf
				Else	//--< ARQUIVO SERVIDOR >---
					cArqTmp := cDirOri + aLista[nFor][01]
					LerArqLista( cArqTmp, aResumoLeitura, aErros)
				EndIf
			EndIf
		Next nFor
		if !lAuto
			If Len(aErros)  > 0 //Exibir resultado final
				If Len(aErros)==1
					msgAlert( "Processo finalizado, porém um arquivo apresentou erro")
				Else
					msgAlert( "Processo finalizado, porém alguns arquivos apresentaram erros" )
				Endif
			Else
				msgAlert( "Processo finalizado com sucesso!")
			EndIf
			PLSCRIGEN(aResumoLeitura,{{"Nome do arquivo","@C",80},{"Descrição","@C",80}},"Resumo do processamento")
		endif
	Else
		lRet := .F.
	EndIf
	
ElseIf !empty(cDirOri)
	msgAlert('Pasta não contém arquivos conforme parâmetros ou operação cancelada')
	lRet := .F.
EndIf

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LerArqLista
Leitura do arquivo .XTR utilizado a classe TXmlManager

@author    Eduardo Bento
@version   1.12
@since     13/05/2019
@param     Arquivo .XTR
/*/
//------------------------------------------------------------------------------------------
static function LerArqLista( cFileXTR, aResumoLeitura, aErros )
local oXML						// Recebe arquivo xtr
local cDesc	    := ""		// Recebe descrição do status final do processamento do arquivo
local lOK		    := .F.     	
local aCabec	    := { }   	
local aGuias    	:= { }
local ans	    	:= { }
local nomeArquivo   := ""		// Nome do arquivo para exibir no resumo de erros

// Leitura do arquivo
oXML := TXmlManager():New()
lOK := oXML:ReadFile( cFileXTR,,oXML:Parse_nsclean )
nomeArquivo := substr( cFileXTR,rat( "\",cFileXTR ) + 1 ) //Extrai o nome para montagem do resumo do proc.

// Adicionando erro a lista de erros
if( !lOK )
	cDesc := "Erro: " + oXML:Error()
	aAdd( aResumoLeitura,{nomeArquivo,cDesc} )
	aAdd( aErros,{nomeArquivo,cDesc} )

// Processando arquivo
else
	//--< REGISTRO NAMESPACE 'ANS' >--
	aNS := oXML:XPathGetRootNsList()
	oXML:XPathRegisterNs( aNS[ 1 ][ 1 ],aNS[ 1 ][ 2 ] )

	aCabec := getCabecalho( oXML )
	if( gravaCabec( 4,aCabec ) ) 
		If B4M->(FieldPos("B4M_TIPENV")) > 0 .And. B4M->B4M_TIPENV == VALOR_PREESTABELECIDO
			processa( { || ( aGuias := processaGuias( oXML,aCabec ) ) },"Por favor, aguarde!","Gravando os dados do arquivo de retorno...",.F. )
		elseif B4M->(FieldPos("B4M_TIPENV")) > 0 .And. B4M->B4M_TIPENV == FORNECIMENTO_DIRETO
			processa( { || ( aGuias := ImportaForn( oXML,aCabec ) ) },"Por favor, aguarde!","Gravando os dados do arquivo de retorno...",.F. )
		Else
			processa( { || ( aGuias := ImportaXTR( oXML,aCabec ) ) },"Por favor, aguarde!","Gravando os dados do arquivo de retorno...",.F. )
		EndIf
	aAdd( aResumoLeitura,{nomeArquivo,"Arquivo processado com sucesso"} )
	// Erro de resitro não encontrado
	else
		aAdd( aResumoLeitura,{nomeArquivo,"Registro não encontrado no Monitoramento TISS (B4M)"} )
		aAdd( aErros,{nomeArquivo,cDesc} )
		//msgAlert( "Registro não encontrado no Monitoramento TISS (B4M)" )
	endIf
endIf

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gravaCabec
Gravacao dos dados do cabecalho do arquivo - B4M

@author    Jonatas Almeida
@version   1.xx
@since     29/08/2016
@param     nOpc(tipo de operacao) ,aCabec(dados do cabecalho)
/*/
//------------------------------------------------------------------------------------------
static function gravaCabec( nOpc,aCabec )
	local aCampos	:= {}
	local lRet		:= .F.
	local nStatus	:= 1
	local cStatus	:= ''
	
	If Len(aCabec) > 9// 9 eh o tamanho do cabecalho retornado quando o arquivo enviado foi invalido 
		nStatus := val( aCabec[ 12 ][ 3 ] )
	EndIf
	
	if( nStatus == 0 )
		cStatus := '5'	//arq retorno sem criticas
	else
		cStatus := '6'	//arq retorno criticado
	endIf

	aadd( aCampos,{ "B4M_FILIAL"	,xFilial( "B4M" ) } )	// filial
	aadd( aCampos,{ "B4M_SUSEP"		,aCabec[ 06 ][ 3 ] } )	// operadora
	aadd( aCampos,{ "B4M_STATUS"	,cStatus } )			// Status - Arquivo de retorno
	aadd( aCampos,{ "B4M_CODUSR"	,retCodUsr() } )		// codigo usuario corrente
	aadd( aCampos,{ "B4M_TISVER"	,aCabec[ 07 ][ 3 ] } ) 	// versao TISS
	aadd( aCampos,{ "B4M_CMPLOT"	,aCabec[ 03 ][ 3 ] } )	// competencia lote
	aadd( aCampos,{ "B4M_DTPRRE"	,stod( strTran( aCabec[ 04 ][ 3 ],"-","" ) ) } )	// data de processamento do retorno
	aadd( aCampos,{ "B4M_HRPRRE"	,aCabec[ 05 ][ 3 ] } )	// hora de processamento do retorno
	
	If Len(aCabec) > 9
		aadd( aCampos,{ "B4M_QTRGIN"	,val( aCabec[ 09 ][ 3 ] ) } )	// Quantidade de registros incluidos
		aadd( aCampos,{ "B4M_QTRGAL"	,val( aCabec[ 10 ][ 3 ] ) } )	// Quantidade de registros alterados
		aadd( aCampos,{ "B4M_QTRGEX"	,val( aCabec[ 11 ][ 3 ] ) } )	// Quantidade de registros excluidos
		aadd( aCampos,{ "B4M_QTRGER"	,val( aCabec[ 12 ][ 3 ] ) } )	// Quantidade de registros com erros 
		aadd( aCampos,{ "B4M_PRORET"	,"S" } )						// N-Nao, S-Sim
	Else
		aadd( aCampos,{ "B4M_CODREJ"	,aCabec[ 9 ][ 3 ] } )		// Codigo Rejeicao 5001	MENSAGEM ELETRÔNICA FORA DO PADRÃO TISS
	EndIf
	
	if( len( aCabec ) > 13 )
		aadd( aCampos,{ "B4M_CODREJ"	,aCabec[ 14 ][ 3 ] } )		// Codigo Rejeicao
	endIf
	
	B4M->( dbSetOrder( 1 ) ) //B4M_FILIAL+B4M_SUSEP+B4M_CMPLOT+B4M_NUMLOT+B4M_NMAREN
	if( B4M->( dbSeek( xFilial( "B4M" ) + aCabec[ 06 ][ 3 ] + aCabec[ 03 ][ 3 ] + aCabec[ 02 ][ 3 ] ) ) )
		lRet := gravaMonit( nOpc,aCampos,'MODEL_B4M','PLSM270' )	
	elseif aCabec[ 02 ][ 3 ] == "999999999999" 
		B4M->( dbSetOrder(4) ) //B4M_FILIAL+B4M_NMAREN
		if B4M->( msseek( xFilial( "B4M" ) + alltrim(aCabec[ 8 ][ 3 ] ) ) ) 
			lRet := gravaMonit( nOpc,aCampos,'MODEL_B4M','PLSM270' )
		endif
	endIf
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCabecalho
Leitura dos dados do cabecalho

@author    Jonatas Almeida
@version   1.xx
@since     24/08/2016
@param     oXML(XML convertido em objeto)
@return    Array contendo os dados do cabecalho
/*/
//------------------------------------------------------------------------------------------
static function getCabecalho( oXML )
	local nx			:= 0
	local aCabec	:= {}
	local aPathTag	:= {}
	local cPathTag	:= ""

	cPathTag := "/ans:mensagemEnvioANS/ans:cabecalho"

	if( oXml:XPathHasNode( cPathTag ) )
		aPathTag := { "/ans:mensagemEnvioANS/ans:cabecalho/ans:identificacaoTransacao/ans:tipoTransacao",;
			"/ans:mensagemEnvioANS/ans:cabecalho/ans:identificacaoTransacao/ans:numeroLote",;
			"/ans:mensagemEnvioANS/ans:cabecalho/ans:identificacaoTransacao/ans:competenciaLote",;
			"/ans:mensagemEnvioANS/ans:cabecalho/ans:identificacaoTransacao/ans:dataRegistroTransacao",;
			"/ans:mensagemEnvioANS/ans:cabecalho/ans:identificacaoTransacao/ans:horaRegistroTransacao",;
			"/ans:mensagemEnvioANS/ans:cabecalho/ans:registroANS",;
			"/ans:mensagemEnvioANS/ans:cabecalho/ans:versaoPadrao",;
			"/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:nomeArquivo",;
			"/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:resumoProcessamentoTotais/ans:registrosIncluidos",;
			"/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:resumoProcessamentoTotais/ans:registrosAlterados",;
			"/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:resumoProcessamentoTotais/ans:registrosExcluidos",;
			"/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:resumoProcessamentoTotais/ans:registrosComErros",;
			"/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:arquivoProcessadoPelaANS",;
			"/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:arquivoRejeitado/ans:nomeArquivo",;
			"/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:arquivoRejeitado/ans:codigoRejeicao";
		}
				
		for nx:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nx ] ) )
				aadd( aCabec,{ subStr( aPathTag[ nx ],rat( ":",aPathTag[ nx ])+1 ),aPathTag[ nx ],oXML:XPathGetNodeValue( aPathTag[ nx ] ) } )
			endIf
		next nx
	endIf
return aCabec

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} processaGuias
Leitura dos dados da Guia

@author    Jonatas Almeida
@version   1.xx
@since     24/08/2016

@param     oXML(arquivo .xtr),aCabec(dados do cabecalho)
@return    aray de guias processadas
/*/
//------------------------------------------------------------------------------------------
static function processaGuias( oXML,aCabec )
	local nx			:= 0
	local nz			:= 0
	local ny			:= 0
	local nCountReg	:= 0
	local nErrosGuia	:= 0
	local aGuias		:= { }
	local aErroGuia		:= { }
	local aErroItens	:= { }
	local aErroG		:= { }
	local aErroIG		:= { }
	local aPathTag		:= { }
	local aRegRej		:= { }
	local cPathTag		:= ""
	local lB4M_TIPENV := B4M->(FieldPos("B4M_TIPENV")) > 0

	cPathTag := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados"

if( oXml:XPathHasNode( cPathTag ) )//guias monitoramento
		
		//Verifico a quantidade de guias		
		nCountReg := oXML:XPathChildCount( cPathTag )

		//--< Leitura das tags 'registrosRejeitados' >--
		procRegua( nCountReg )
		
		for nx:=1 to nCountReg
			incProc( nCountReg )
	
		If lB4M_TIPENV .And. B4M->B4M_TIPENV == "4"
			
			cPathTag := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados/ans:valorPreestabelecidoMonitoramento"
			If nCountReg > 1
				cPathTag += "["+ allTrim( str( nx ) ) +"]"
			EndIf
			
			aPathTag := { cPathTag + "/ans:contratadoExecutante/ans:CNES",;
			cPathTag + "/ans:contratadoExecutante/ans:identificadorExecutante",;
			cPathTag + "/ans:contratadoExecutante/ans:codigoCNPJ_CPF",;
			cPathTag + "/ans:contratadoExecutante/municipioExecutante",;
			cPathTag + "/ans:registroANSOperadoraIntermediaria",; 
			cPathTag + "/ans:competenciaCoberturaContratada",; 
			cPathTag + "/ans:identificacaoValorPreestabelecido";
			}
		Else

			cPathTag := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados/ans:guiaMonitoramento"
			If nCountReg > 1
				cPathTag += "["+ allTrim( str( nx ) ) +"]"
			EndIf
			
			aPathTag := { cPathTag + "/ans:contratadoExecutante/ans:CNES",;
				cPathTag + "/ans:contratadoExecutante/ans:identificadorExecutante",;
				cPathTag + "/ans:contratadoExecutante/ans:codigoCNPJ_CPF",;
				cPathTag + "/ans:numeroGuiaPrestador",;
				cPathTag + "/ans:numeroGuiaOperadora",;
				cPathTag + "/ans:identificadorReembolso",;
				cPathTag + "/ans:dataProcessamento";
			}
		EndIf
			
			aRegRej		:= { }
			
			for nz:=1 to len( aPathTag )
				if( oXml:XPathHasNode( aPathTag[ nz ] ) )
					aadd( aRegRej, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
				endIf
			next nz
			
		If lB4M_TIPENV .And. B4M->B4M_TIPENV == "4"

			nErrosCon := oXML:XPathChildCount( cPathTag )
			aErroC := {}
			
			for nz:=1 to nErrosCon

				aErroCon	:= {}
				aPathTag := { cPathTag + "/ans:errosValorPreestabelecido["+ allTrim( str( nz ) ) +"]/ans:identificadorCampo",;
				cPathTag + "/ans:errosValorPreestabelecido["+ allTrim( str( nz ) ) +"]/ans:codigoErro";
				}
			
				for ny:=1 to len( aPathTag )
					if( oXml:XPathHasNode( allTrim( aPathTag[ nY ] ) ) )
						aadd( aErroCon, { subStr( aPathTag[ ny ],rat( ":",aPathTag[ ny ] ) + 1 ),aPathTag[ ny ],oXML:XPathGetNodeValue( aPathTag[ ny ] ) } )
					endif
				next ny
				
				If Len(aErroCon) >= 2
					aAdd(aErroC,{aErroCon[1],aErroCon[2]})
				EndIf

			next nz
			
		Else//If lB4M_TIPENV .And. B4M->B4M_TIPENV == "4"
		
			nErrosGuia := oXML:XPathChildCount( cPathTag )
			//--< ERROS E ITENS DE ERRO DA GUIA >--
			aErroGuia	:= { }
			aErroItens	:= { }
			
			for nz:=1 to nErrosGuia
				aPathTag := { cPathTag + "/ans:errosGuia["+ allTrim( str( nz ) ) +"]/ans:identificadorCampo",;
					cPathTag + "/ans:errosGuia["+ allTrim( str( nz ) ) +"]/ans:codigoErro",;
					cPathTag + "/ans:errosItensGuia["+ allTrim( str( nz ) ) +"]/ans:identProcedimento/ans:codigoTabela",;
					cPathTag + "/ans:errosItensGuia["+ allTrim( str( nz ) ) +"]/ans:identProcedimento/ans:Procedimento/ans:grupoProcedimento",;
					cPathTag + "/ans:errosItensGuia["+ allTrim( str( nz ) ) +"]/ans:identProcedimento/ans:Procedimento/ans:codigoProcedimento",;
					cPathTag + "/ans:errosItensGuia["+ allTrim( str( nz ) ) +"]/ans:denteFace",;
					cPathTag + "/ans:errosItensGuia["+ allTrim( str( nz ) ) +"]/ans:denteRegiao/ans:codDente",;
					cPathTag + "/ans:errosItensGuia["+ allTrim( str( nz ) ) +"]/ans:denteRegiao/ans:codRegiao",;
					cPathTag + "/ans:errosItensGuia["+ allTrim( str( nz ) ) +"]/ans:relacaoErros/ans:identificadorCampo",;
					cPathTag + "/ans:errosItensGuia["+ allTrim( str( nz ) ) +"]/ans:relacaoErros/ans:codigoErro";
				}
				
				aErroG  := { }
				aErroIG := { }

				for ny:=1 to len( aPathTag )
					if( oXml:XPathHasNode( allTrim( aPathTag[ nY ] ) ) )
						if( "errosGuia" $ aPathTag[ ny ] )
							aadd( aErroG, { subStr( aPathTag[ ny ],rat( ":",aPathTag[ ny ] ) + 1 ),aPathTag[ ny ],oXML:XPathGetNodeValue( aPathTag[ ny ] ) } )
						elseIf( "errosItensGuia" $ aPathTag[ ny ] )
							aadd( aErroIG, { subStr( aPathTag[ ny ],rat( ":",aPathTag[ ny ] ) + 1 ),aPathTag[ ny ],oXML:XPathGetNodeValue( aPathTag[ ny ] ) } )
						endIf
					endif
				next ny
				
				if( len( aErroG )  > 0 )
					aadd( aErroGuia,aErroG )
				endIf
				
				if( len( aErroIG )  > 0 )
					aadd( aErroItens,aErroIG )
				endIf
			next nz
                                        
		EndIf
			
			if( len( aRegRej ) > 0 )
				
			If lB4M_TIPENV .And. B4M->B4M_TIPENV == "4"
				aadd( aRegRej,IIf(len(aErroC)  > 0,aErroC ,{}) )
				PLSM270B8R(aCabec,aRegRej)
			else	
				aadd( aRegRej,IIf(len(aErroGuia)  > 0,aErroGuia ,{}) )
		  		aadd( aRegRej,IIf(len(aErroItens) > 0,aErroItens ,{}) )

				aadd( aGuias,aRegRej )
				gravaGuia( aCabec,aRegRej )
			endif		

			endIf

		next nx

	endIf
return aGuias

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gravaGuia
Efetua a gravação dos dados da Guia

@author    Jonatas Almeida
@version   1.xx
@since     24/08/2016

@param     aCabec(dados do cabecalho),aGuia(dados da guia)
/*/
//------------------------------------------------------------------------------------------
static function gravaGuia( aCabec,aGuia )
	local aCposB4N	:= { }
	local aCposB4O	:= { }
	local aCposB4P	:= { }
	local aErros	:= { }
	local cRegANS	:= ""
	local cCmpLote	:= ""
	local cNumLote	:= ""
	local cNGuiaOP	:= ""
	local cNGuiaPR	:= ""
	local cVerTiss	:= ""
	local cCodPro	:= ""
	local cCodGrp	:= ""
	local nPosCodErro := 0
	local nPosIDCampo := 0
	local nPosCodTabe := 0
	local nPosCodProc := 0
	local nPosGrpProc := 0
	local nx		  := 0
	local nOpc		  := 0
	local lRet		:= .T.
	
	cRegANS	:= aCabec[ 6 ][ 3 ]	// Registro ANS
	cCmpLote	:= aCabec[ 3 ][ 3 ]	// Competencia do lote
	cNumLote	:= aCabec[ 2 ][ 3 ]	// Numero do lote
	cVerTiss	:= aCabec[ 7 ][ 3 ] // Versao TISS
	cNGuiaOP	:= aGuia[ 5 ][ 3 ]	// Numero guia operadora
	cNGuiaPR	:= aGuia[ 4 ][ 3 ]	// Numero guia prestador
	cNGuiaRE   := aGuia[ 6 ][ 3 ]	// Numero guia Reembolso
	
	// Verifica se é reembolso e pego numero da guia de reembolso
	If Alltrim(cNGuiaOP)	== "00000000000000000000" .And. Alltrim(cNGuiaRE) <> "00000000000000000000"
		cNGuiaOP	:= cNGuiaRE
	Endif
	 
	//--< GUIA - B4N >--	
	B4N->( dbSetOrder( 1 ) )
	if( B4N->( dbSeek( xFilial( "B4N" ) + cRegANS + cCmpLote + cNumLote + cNGuiaOP ) ) )
		aAdd( aCposB4N,{ "B4N_STATUS",'2' } )	// Status
		aAdd( aCposB4N,{ "B4N_ORIERR",'2' } )	// 1-sistema | 2-retorno | 3-qualidade
		lRet := gravaMonit( 4,aCposB4N,'MODEL_B4N','PLSM270B4N' )

		//--< ERROS DA GUIA - B4P >--
		aErros := aGuia[ 8 ]
		
		B4P->( dbSetOrder( 2 ) ) //B4P_FILIAL+B4P_CMPLOT+B4P_NUMLOT+B4P_NMGOPE+B4P_NMGPRE 
		for nx:=1 to len( aErros )
			if( !B4P->( dbSeek( xFilial( "B4P" ) + cCmpLote + cNumLote + cNGuiaOP + cNGuiaPR ) ) )
				cCodErro := aErros[ nx ][ 2 ][ 3 ]
				BTQ->( dbSetOrder( 1 ) ) //BTQ_FILIAL, BTQ_CODTAB, BTQ_CDTERM
				BTQ->( msSeek( xFilial( "BTQ" ) + '38' + cCodErro ) )
				cDescErro := allTrim( BTQ->BTQ_DESTER )
			
				aCposB4P := { }
				aAdd( aCposB4P,{ "B4P_FILIAL"	,xFilial( "B4P" ) } )			// Filial
				aAdd( aCposB4P,{ "B4P_CDCMGU"	,aErros[ nx ][ 1 ][ 3 ] } )		// ID campo GUIA
				aAdd( aCposB4P,{ "B4P_CDCMER"	,aErros[ nx ][ 2 ][ 3 ] } )		// Codigo Erro
				aadd( aCposB4P,{ "B4P_DESERR"	,cDescErro } ) 					// Descricao do Erro
				aAdd( aCposB4P,{ "B4P_SUSEP"	,cRegANS } )					// Registro ANS
				aAdd( aCposB4P,{ "B4P_CMPLOT"	,cCmpLote } )					// Competencia do lote
				aAdd( aCposB4P,{ "B4P_NUMLOT"	,cNumLote } )					// Numero do lote
				aAdd( aCposB4P,{ "B4P_NMGOPE"	,cNGuiaOP } )					// Numero guia operadora
				aAdd( aCposB4P,{ "B4P_NMGPRE"	,cNGuiaPR } )					// Numero guia prestador
				aAdd( aCposB4P,{ "B4P_NIVERR"	,"G" } )						// Nivel do erro
				aAdd( aCposB4P,{ "B4P_ORIERR"	,"2" } )						// 1-sistema | 2-retorno | 3-qualidade
				
				lRet := gravaMonit( 3,aCposB4P,'MODEL_B4P','PLSM270B4P' )
			endIf
		next nx
		
		//--< ERROS ITENS DA GUIA - B4P >--
		aErros := aGuia[ 9 ]
	
		B4P->( dbSetOrder( 1 ) ) //B4P_FILIAL+B4P_SUSEP+B4P_CMPLOT+B4P_NUMLOT+B4P_NMGOPE+B4P_CODPAD+B4P_CODPRO+B4P_CDCMER
		for nx:=1 to len( aErros )
			nPosCodTabe := ascan( aErros[ nx ],{ | x | x[ 1 ] == "codigoTabela" } )
			nPosCodProc := ascan( aErros[ nx ],{ | x | x[ 1 ] == "codigoProcedimento" } )
			nPosCodErro := ascan( aErros[ nx ],{ | x | x[ 1 ] == "codigoErro" } )
			nPosIDCampo := ascan( aErros[ nx ],{ | x | x[ 1 ] == "identificadorCampo" } )
			nPosGrpProc := ascan( aErros[ nx ],{ | x | x[ 1 ] == "grupoProcedimento" } )
			
			if( nPosCodErro <> 0 .and. nPosCodProc <> 0 )
				//--< ATUALIZA STATUS B4O - EVENTOS >---
				cCodPro := ""
				cCodGrp := ""
				
				if( nPosCodProc == 0 )
					cCodPro := space( tamSX3( "B4O_CODPRO" )[ 1 ] )
				else
					cCodPro := aErros[ nx ][ nPosCodProc ][ 3 ]
				endIf
				
				if( nPosGrpProc == 0 )
					cCodGrp := space( tamSX3( "B4O_CODGRU" )[ 1 ] )
				else
					cCodGrp := aErros[ nx ][ nPosGrpProc ][ 3 ]
				endIf
				
				B4O->( dbSetOrder( 5 ) ) //B4O_FILIAL+B4O_SUSEP+B4O_CMPLOT+B4O_NUMLOT+B4O_NMGOPE+B4O_CODGRU+B4O_CODTAB+B4O_CODPRO
				if( B4O->( dbSeek( xFilial( "B4O" ) + cRegANS + cCmpLote + cNumLote + cNGuiaOP + cCodGrp + cCodPro ) ) )
					aadd( aCposB4O,{ "B4O_STATUS"	,'2' } )									// Alteracao de Status
					aadd( aCposB4O,{ "B4O_ORIERR"	,'2' } )									//1-Sistema, 2-Retorno, 3-Qualidade
					lRet := gravaMonit( 4,aCposB4O,'MODEL_B4O','PLSM270B4O' )
				endIf

				//if( !B4P->( dbSeek( xFilial( "B4P" ) + cRegANS + cCmpLote + cNumLote + cNGuiaOP + aErros[ nx ][ nPosCodTabe ][ 3 ] + aErros[ nx ][ nPosCodProc ][ 3 ] +  aErros[ nx ][ nPosCodErro ][ 3 ] ) ) )
				B4P->( dbSetOrder( 1 ) )
				if( !B4P->( dbSeek( xFilial( "B4P" ) + cRegANS + cCmpLote + cNumLote + cNGuiaOP + Iif(B4P->(FieldPos("B4P_CODGRU")) > 0,aErrosItens[nGuias,2],"") + aErros[ nx ][ nPosCodTabe ][ 3 ] + aErros[ nx ][ nPosCodProc ][ 3 ] ) ) )
					cCodErro := aErros[ nx ][ nPosCodErro ][ 3 ]
					BTQ->( dbSetOrder( 1 ) ) //BTQ_FILIAL, BTQ_CODTAB, BTQ_CDTERM
					BTQ->( msSeek( xFilial( "BTQ" ) + '38' + cCodErro ) )
					cDescErro := allTrim( BTQ->BTQ_DESTER )
				
					aCposB4P := { }
					aAdd( aCposB4P,{ "B4P_FILIAL"	,xFilial( "B4P" ) } )					// Filial
					aAdd( aCposB4P,{ "B4P_CDCMGU"	,aErros[ nx ][ nPosIDCampo ][ 3 ] } )	// ID campo GUIA
					aAdd( aCposB4P,{ "B4P_CDCMER"	,aErros[ nx ][ nPosCodErro ][ 3 ] } )	// Codigo Erro
					aadd( aCposB4P,{ "B4P_DESERR"	,cDescErro } ) 							// Descricao do Erro
					aAdd( aCposB4P,{ "B4P_SUSEP"	,cRegANS } )							// Registro ANS
					aAdd( aCposB4P,{ "B4P_CMPLOT"	,cCmpLote } )							// Competencia do lote
					aAdd( aCposB4P,{ "B4P_NUMLOT"	,cNumLote } )							// Numero do lote
					aAdd( aCposB4P,{ "B4P_NMGOPE"	,cNGuiaOP } )							// Numero guia operadora
					aAdd( aCposB4P,{ "B4P_NMGPRE"	,cNGuiaPR } )							// Numero guia prestador
					aAdd( aCposB4P,{ "B4P_CODPRO"	,aErros[ nx ][ nPosCodProc ][ 3 ] } )	// Codigo Procedimento
					aAdd( aCposB4P,{ "B4P_CODPAD"	,aErros[ nx ][ nPosCodTabe ][ 3 ] } )	// Codigo Tabela Padrao
					aAdd( aCposB4P,{ "B4P_NIVERR"	,"E" } )								// Nivel do erro
					aAdd( aCposB4P,{ "B4P_ORIERR"	,"2" } )								// 1-sistema | 2-retorno | 3-qualidade
					If B4P->(FieldPos("B4P_CODGRU")) > 0
						aadd( aCampos,{ "B4P_CODGRU", 	cCodGrp				} ) 			//Grupo
					EndIf
					
					lRet := gravaMonit( 3,aCposB4P,'MODEL_B4P','PLSM270B4P' )
				endIf
			endIf
		next nx
	endIf

return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ImportaXTR
Importa o arquivo de retorno .XTR de monitoramento

@author    timoteo.bega
@since     09/05/2017
@param     oXml	objeto xml do arquivo .XTR
@param     aLote	Informacoes do lote
/*/
//------------------------------------------------------------------------------------------
Static Function ImportaXTR( oXML,aLote )
Local nQtdeGuias		:= 0
Local nQtErrGuia		:= 0
Local nQtdErrIte		:= 0
Local nFor				:= 0
Local cPathRegitro	:= "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados"
Local cPathGuia		:= ""
Local aCabGuia			:= {}
Local aErrosGuia		:= {}
Local aErrosItens		:= {}
Local lB4M_TIPENV		:= B4M->(FieldPos("B4M_TIPENV")) > 0

//Verifico a quantidade de guias
nQtdeGuias := oXML:XPathChildCount(cPathRegitro)
	
//Defino o tamanho da regua com a quantidade de guias do arquivo
ProcRegua(nQtdeGuias)
	
//Vou percorrer todas as guias
For nFor := 1 TO nQtdeGuias

	If nQtdeGuias > 0
		cPathGuia := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados/ans:guiaMonitoramento[" + AllTrim(Str(nFor)) + "]"
	EndIf

	If oXml:XPathHasNode(cPathGuia)

		//Pego o cabecalho da guia posicionada no arquivo 
		aCabGuia := GetCabGuia(oXml,cPathGuia)
		
		//Pegos os erros no nivel da guia
		aErrosGuia := GetErrosGuia(oXml,cPathGuia)

		//Pegos os erros no nivel dos procedimentos/itens
		aErrosItens := GetErrosItens(oXml,cPathGuia)
		
		//Atualiza Guia
		AtualizaGuia(aLote,aCabGuia,aErrosGuia,aErrosItens)

	EndIf

Next nFor

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetCabGuia
Pega as informacoes de cabecalho do lote no arquivo .XTR

@author    timoteo.bega
@since     09/05/2017
@param     oXml		objeto xml do arquivo .XTR
@param     cPathGuia	Caminho da guia no objeto oxml
/*/
//------------------------------------------------------------------------------------------
Static Function GetCabGuia(oXml,cPathGuia)
Local nFor		:= 0
Local aRet		:= {"","","","","","","",""}
Local aTags		:= {}

aAdd(aTags,"/ans:tipoRegistro")
aAdd(aTags,"/ans:contratadoExecutante/ans:CNES")
aAdd(aTags,"/ans:contratadoExecutante/ans:identificadorExecutante")
aAdd(aTags,"/ans:contratadoExecutante/ans:codigoCNPJ_CPF")
aAdd(aTags,"/ans:numeroGuiaPrestador")
aAdd(aTags,"/ans:numeroGuiaOperadora")
aAdd(aTags,"/ans:identificadorReembolso")
aAdd(aTags,"/ans:dataProcessamento")

For nFor := 1 TO Len(aTags)

	If oXml:XPathHasNode(cPathGuia+aTags[nFor])
		aRet[nFor] := oXML:XPathGetNodeValue(cPathGuia+aTags[nFor])
	EndIf

Next nFor

Return aRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetErrosGuia
Pega a lista de erros da guia no arquivo

@author    timoteo.bega
@since     09/05/2017
@param     oXml		objeto xml do arquivo .XTR
@param     cPathGuia	Caminho da guia no objeto oxml
/*/
//------------------------------------------------------------------------------------------
Static Function GetErrosGuia(oXml,cPathGuia,cNameSpace)
Local nFor		:= 0
Local nTamGuia:= oXML:XPathChildCount(cPathGuia)
Local aGuia		:= oXml:XPathGetChildArray(cPathGuia)
Local aErro		:= {}
Local aRet		:= {}
default cNameSpace := "errosGuia"

For nFor := 1 TO nTamGuia

	If aGuia[nFor,1] == cNameSpace .And. oXml:XPathHasNode(aGuia[nFor,2])

		aErro := oXml:XPathGetChildArray(aGuia[nFor,2])
		aAdd(aRet,{aErro[1,3],aErro[2,3]})

	EndIf

Next nFor

Return aRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetErrosItens
Pega a lista de erros do procedimento no arquivo

@author    timoteo.bega
@since     09/05/2017
@param     oXml		objeto xml do arquivo .XTR
@param     cPathGuia	Caminho da guia no objeto oxml
/*/
//------------------------------------------------------------------------------------------
Static Function GetErrosItens(oXml,cPathGuia,cNameSpace)
Local nFor		:= 0
Local nErros	:= 0
Local cTabela	:= ""
Local cGrupo	:= ""
Local cCodPro	:= ""
Local cCodDen	:= ""
Local cCodReg	:= ""
Local cFace		:= ""
Local nTamGuia	:= oXML:XPathChildCount(cPathGuia)
Local aGuia		:= oXml:XPathGetChildArray(cPathGuia)
Local aItem		:= {}
Local aErro		:= {}
Local aRet		:= {}
default cNameSpace 	:= "errosItensGuia"

For nFor := 1 TO nTamGuia

	If aGuia[nFor,1] == cNameSpace .And. oXml:XPathHasNode(aGuia[nFor,2])

		aItem := oXml:XPathGetChildArray(aGuia[nFor,2])
		
		For nErros := 1 TO Len(aItem)

			If aItem[nErros,1] == "identProcedimento"
				cTabela := oXML:XPathGetNodeValue(aItem[1,2]+"/ans:codigoTabela")
				cGrupo := oXML:XPathGetNodeValue(aItem[1,2]+"/ans:Procedimento/ans:grupoProcedimento")
				cCodPro := oXML:XPathGetNodeValue(aItem[1,2]+"/ans:Procedimento/ans:codigoProcedimento")
			EndIf

			If aItem[nErros,1] == "denteRegiao"
				cCodDen := oXML:XPathGetNodeValue(aItem[1,2]+"/ans:denteRegiao/ans:codDente")
				cCodReg := oXML:XPathGetNodeValue(aItem[1,2]+"/ans:denteRegiao/ans:codRegiao")
			EndIf

			If aItem[nErros,1] == "denteFace"
				cFace := oXML:XPathGetNodeValue(aItem[1,2]+"/ans:denteFace")
			EndIf

			If aItem[nErros,1] == "relacaoErros"

				cGrupo	:= PADR( cGrupo	,tamSX3("B4O_CODGRU")[1] )
				cCodPro	:= PADR( cCodPro	,tamSX3("B4O_CODPRO")[1] )
				aErro := oXml:XPathGetChildArray(aItem[nErros,2])
				aAdd(aRet,{cTabela,cGrupo,cCodPro,aErro[1,3],aErro[2,3]})
			
			EndIf

		Next nErros

	EndIf

Next nFor

Return aRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtualizaGuia
Atualiza o status da guia B4N e grava as criticas B4P

@author    timoteo.bega
@since     09/05/2017
@param     aLote			Matriz com as informacoes do lote
@param     aCabGuia		Matriz com as informacoes do cabecalho da guia
@param     aErrosGuia	Matriz com a lista de erros da guia
@param     aErrosItens	Matriz com a lista de erros dos procedimentos
/*/
//------------------------------------------------------------------------------------------
Static Function AtualizaGuia(aLote,aCabGuia,aErrosGuia,aErrosItens,cTipo)
local nGuias		:= 0
local cRegANS		:= ""
local cCmpLote		:= ""
local cNumLote		:= ""
local cVerTiss		:= ""
local cNumGuiOpe	:= ""
local cNumGuiPre	:= ""
local cNumGuiaRE	:= ""
local cInd1B4P   	:= ""
local cInd2B4P   	:= ""
local cInd3B4P   	:= ""
local cInd4B4P   	:= ""
local cCgcRda 		:= ""
local cChave		:= ""
local cCodRda		:= ""
local aCampos		:= {}
default cTipo		:= "1"

cRegANS		:= aLote[6,3]		// Registro ANS
cCmpLote	:= aLote[3,3]		// Competencia do lote
cNumLote	:= aLote[2,3]		// Numero do lote
cVerTiss	:= aLote[7,3]		// Versao TISS
if cTipo == "1"
	cCgcRda		:= aCabGuia[4]		// CGC RDA
	cNumGuiPre	:= aCabGuia[5]		// Numero guia prestador
	cNumGuiOpe	:= aCabGuia[6]		// Numero guia operadora
	cNumGuiaRE	:= aCabGuia[7]		// Numero guia Reembolso
	B4N->(dbSetOrder(1)) //B4N_FILIAL+B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4N_CODRDA

	BAU->(dbsetorder(4))
	if BAU->(msseek(xfilial("BAU") + cCgcRda))
		cCodRda := BAU->BAU_CODIGO
	endif
	
	// Verifica se é reembolso e pego numero da guia de reembolso
	If Alltrim(cNumGuiOpe)	== "00000000000000000000" .And. Alltrim(cNumGuiaRE) <> "00000000000000000000"
		cNumGuiOpe	:= cNumGuiaRE
	Endif	

	cInd1B4P   	:= PadR(cCmpLote  , tamSX3("B4P_CMPLOT")[1])
	cInd2B4P   	:= PadR(cNumLote  , tamSX3("B4P_NUMLOT")[1])
	cInd3B4P   	:= PadR(cNumGuiPre, TamSX3("B4P_NMGPRE")[1])
	cInd4B4P   	:= PadR(cNumGuiOpe, TamSX3("B4P_NMGOPE")[1])
	cChave		:= cRegANS+cCmpLote+cNumLote+cNumGuiOpe+cCodRda
	
else
	cNumGuiPre	:= aCabGuia[1]		// Numero guia prestador
	cChave := cNumGuiPre
	B4N->(dbSetOrder(4)) //B4N_FILIAL+B4N_NMGPRE
endif

If B4N->(dbSeek(xFilial("B4N")+ cChave ))
	while B4M->B4M_CMPLOT+B4M->B4M_NUMLOT <> B4N->B4N_CMPLOT+B4N->B4N_NUMLOT
		B4N->(dbskip())
	enddo
	if cTipo <> "1"			
		cNumGuiOpe	:= B4N->B4N_NMGOPE		// Numero guia operadora

		cInd1B4P   	:= PadR(cCmpLote  , tamSX3("B4P_CMPLOT")[1])
		cInd2B4P   	:= PadR(cNumLote  , tamSX3("B4P_NUMLOT")[1])
		cInd3B4P   	:= PadR(cNumGuiPre, TamSX3("B4P_NMGPRE")[1])
		cInd4B4P   	:= PadR(cNumGuiOpe, TamSX3("B4P_NMGOPE")[1])		
	endif

	aAdd( aCampos,{ "B4N_STATUS",'2' } )	// Status
	aAdd( aCampos,{ "B4N_ORIERR",'2' } )	// 1-sistema | 2-retorno | 3-qualidade
	lRet := gravaMonit( 4,aCampos,'MODEL_B4N','PLSM270B4N' )
	
	B4P->(dbSetOrder(2))//B4P_FILIAL+B4P_CMPLOT+B4P_NUMLOT+B4P_NMGOPE+B4P_NMGPRE+B4P_CDCMER+B4P_CDCMGU 
	If Len(aErrosGuia) > 0 

		For nGuias := 1 TO Len(aErrosGuia)
		
			If !B4P->(MsSeek(xFilial("B4P")+cInd1B4P+cInd2B4P+cInd4B4P+cInd3B4P+PadR(aErrosGuia[nGuias,2], TamSX3("B4P_CDCMER")[1])+ aErrosGuia[nGuias,1] )) 
			
				aCampos := {}
				aAdd( aCampos,{ "B4P_FILIAL"	,xFilial("B4P")			} )// Filial
				aAdd( aCampos,{ "B4P_CDCMGU"	,aErrosGuia[nGuias,1]	} )// ID campo GUIA
				aAdd( aCampos,{ "B4P_CDCMER"	,aErrosGuia[nGuias,2]	} )// Codigo Erro
				aAdd( aCampos,{ "B4P_DESERR"	,GetDescCri(aErrosGuia[nGuias,2])} )// Descricao do Erro
				aAdd( aCampos,{ "B4P_SUSEP"		,cRegANS					} )// Registro ANS
				aAdd( aCampos,{ "B4P_CMPLOT"	,cCmpLote				} )// Competencia do lote
				aAdd( aCampos,{ "B4P_NUMLOT"	,cNumLote				} )// Numero do lote
				aAdd( aCampos,{ "B4P_NMGOPE"	,cNumGuiOpe				} )// Numero guia operadora
				aAdd( aCampos,{ "B4P_NMGPRE"	,cNumGuiPre				} )// Numero guia prestador
				aAdd( aCampos,{ "B4P_NIVERR"	,"G"					} )// Nivel do erro
				aAdd( aCampos,{ "B4P_ORIERR"	,"2"					} )// 1-sistema | 2-retorno | 3-qualidade
				
				lRet := gravaMonit( 3,aCampos,'MODEL_B4P','PLSM270B4P' )
			
			EndIf
		
		Next nGuias

	EndIf
	
	B4P->(dbSetOrder(1))//B4P_FILIAL+B4P_SUSEP+B4P_CMPLOT+B4P_NUMLOT+B4P_NMGOPE+B4P_CODGRU+B4P_CODPAD+B4P_CODPRO+B4P_CDCMER+B4P_CDCMGU
	B4O->(dbSetOrder(5))//B4O_FILIAL+B4O_SUSEP+B4O_CMPLOT+B4O_NUMLOT+B4O_NMGOPE+B4O_CODGRU+B4O_CODTAB+B4O_CODPRO+B4O_CODRDA
	If Len(aErrosItens) > 0

		For nGuias := 1 TO Len(aErrosItens)
		
			If B4O->(dbSeek(xFilial("B4O")+cRegANS+cCmpLote+cNumLote+cNumGuiOpe+aErrosItens[nGuias,2]+aErrosItens[nGuias,1]+aErrosItens[nGuias,3])) .And. B4O->B4O_STATUS <> '2'

				aCampos := {}
				aAdd( aCampos,{ "B4O_STATUS"	,"2"	} )//1-Sem critica, 2-Com critica
				aAdd( aCampos,{ "B4O_ORIERR"	,"2"	} )//1-Sistema, 2-Retorno, 3-Qualidade

				lRet := gravaMonit( 4,aCampos,'MODEL_B4O','PLSM270B4O' )

			EndIf

			If !B4P->(dbSeek(xFilial("B4P")+cRegANS+cInd1B4P+cInd2B4P+cInd4B4P+aErrosItens[nGuias,2]+aErrosItens[nGuias,1]+aErrosItens[nGuias,3]+aErrosItens[nGuias,5]+aErrosItens[nGuias,4]))

				aCampos := {}
				aAdd( aCampos,{ "B4P_FILIAL"	,xFilial("B4P")				} )// Filial
				aAdd( aCampos,{ "B4P_CDCMGU"	,aErrosItens[nGuias,4]		} )// ID campo GUIA
				aAdd( aCampos,{ "B4P_CDCMER"	,aErrosItens[nGuias,5]		} )// Codigo Erro
				aAdd( aCampos,{ "B4P_DESERR"	,GetDescCri(aErrosItens[nGuias,5])} )// Descricao do Erro
				aAdd( aCampos,{ "B4P_SUSEP"		,cRegANS					} )// Registro ANS
				aAdd( aCampos,{ "B4P_CMPLOT"	,cCmpLote					} )// Competencia do lote
				aAdd( aCampos,{ "B4P_NUMLOT"	,cNumLote					} )// Numero do lote
				aAdd( aCampos,{ "B4P_NMGOPE"	,cNumGuiOpe					} )// Numero guia operadora
				aAdd( aCampos,{ "B4P_NMGPRE"	,cNumGuiPre					} )// Numero guia prestador
				aAdd( aCampos,{ "B4P_CODPAD"	,aErrosItens[nGuias,1]		} )// Codigo da tabela
				aAdd( aCampos,{ "B4P_CODPRO"	,aErrosItens[nGuias,3]		} )// Codigo do procedimento
				aAdd( aCampos,{ "B4P_NIVERR"	,"E"						} )// Nivel do erro
				aAdd( aCampos,{ "B4P_ORIERR"	,"2"						} )// 1-sistema | 2-retorno | 3-qualidade
				aadd( aCampos,{ "B4P_CODGRU", 	aErrosItens[nGuias,2]		} ) //Grupo
				
				lRet := gravaMonit( 3,aCampos,'MODEL_B4P','PLSM270B4P' )

			EndIf

		Next nGuias

	EndIF

EndIf

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GetDescCri
Retorna a descricao referente ao codigo da critica encontrada no arquivo .XTR

@author    timoteo.bega
@since     09/05/2017
@param     cCodErr	Codigo do erro do arquivo .XTR
/*/
//------------------------------------------------------------------------------------------
Static Function GetDescCri(cCodErr)
Local cDesc			:= ""
Default cCodErr	:= ""

If !Empty(cCodErr)

		BTQ->(dbSetOrder(1))//BTQ_FILIAL, BTQ_CODTAB, BTQ_CDTERM
		BTQ->(msSeek(xFilial("BTQ")+'38'+cCodErr))
		cDesc := AllTrim(BTQ->BTQ_DESTER)

EndIf

Return cDesc


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} ImportaForn
Importa o arquivo de retorno .XTR de Fornecimento Direto

@author    Lucas Nonato
@since     15/01/2019
@param     oXml	objeto xml do arquivo .XTR
@param     aLote	Informacoes do lote
/*/
//------------------------------------------------------------------------------------------
Static Function ImportaForn( oXML,aLote )
Local nQtdeGuias		:= 0
Local nQtErrGuia		:= 0
Local nQtdErrIte		:= 0
Local nFor				:= 0
Local cPathRegitro		:= "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados"
Local cPathGuia			:= ""
Local aCabGuia			:= {}
Local aErrosGuia		:= {}
Local aErrosItens		:= {}
Local lB4M_TIPENV		:= B4M->(FieldPos("B4M_TIPENV")) > 0

//Verifico a quantidade de guias
nQtdeGuias := oXML:XPathChildCount(cPathRegitro)
	
//Defino o tamanho da regua com a quantidade de guias do arquivo
ProcRegua(nQtdeGuias)
	
//Vou percorrer todas as guias
For nFor := 1 TO nQtdeGuias

	If nQtdeGuias > 0
		cPathGuia := "/ans:mensagemEnvioANS/ans:Mensagem/ans:ansParaOperadora/ans:resumoProcessamento/ans:registrosRejeitados/ans:fornecimentoDiretoMonitoramento[" + AllTrim(Str(nFor)) + "]"
	EndIf

	If oXml:XPathHasNode(cPathGuia)

		//Pego o cabecalho da guia posicionada no arquivo			
		aCabGuia := {oXML:XPathGetNodeValue(cPathGuia+"/ans:identificacaoFornecimentoDireto")}	
		
		//Pegos os erros no nivel da guia
		aErrosGuia := GetErrosGuia(oXml,cPathGuia,"errosFornecimentoDireto")

		//Pegos os erros no nivel dos procedimentos/itens
		aErrosItens := GetErrosItens(oXml,cPathGuia,"errosItensFornecimentoDireto")
		
		//Atualiza Guia
		AtualizaGuia(aLote,aCabGuia,aErrosGuia,aErrosItens,"2")

	EndIf

Next nFor

Return