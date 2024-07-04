#include "TOTVS.CH"
#include "protheus.ch"
#include "FWMVCDEF.CH"
#include "fileIO.ch"
#include "XMLXFUN.CH"
#include 'PLSP520IMP.CH'
#include "PLSMGER.CH"

#define CRLF chr( 13 ) + chr( 10 )
#define G_CONSULTA  "01"
#define G_SADT_ODON "02"
#define G_RES_INTER "05"
#define G_HONORARIO "06"

static nTamSeq := TamSX3('B6T_SEQUEN')[1]

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP520IMP
Importação do arquivo Lote Guias .XML

@author    Guilherme Carvalho
@version   1.xx
@since     23/08/2018
/*/
//------------------------------------------------------------------------------------------
function PLSP520IMP(lAuto)
Local cTitulo	:= STR0001 //"Importar arquivo Lote de Guias"
Local cTexto	:= CRLF + CRLF + STR0002 + CRLF +; 	//"Esta opção irá efetuar a leitura do arquivo .XML a ser"
				STR0003					 			//"disponibilizado pela operadora Habitual e importado pela operadora Origem"
Local aOpcoes	:= { STR0004,STR0005 } //"Processar" # "Cancelar" 
Local nTaman	:= 3
Local nOpc		:= 1
default lAuto 	:= .f.

Private cSeqLote := ""
Private cSeqGuia := "000"

if valtype(lAuto) <> 'L'
	lAuto := .f.
endif

if !lAuto
	nOpc	:= aviso( cTitulo,cTexto,aOpcoes,nTaman )
endif

If( nOpc == 1 )
	PLP520Proc(lAuto)
EndIf

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLP520Proc
Abre janela de dialogo para importacao dos arquivos

@author    Michel Montoro
@version   1.xx
@since     08/08/2018
/*/
//------------------------------------------------------------------------------------------
Function PLP520Proc(lAuto)
Local nFor			:= 0
Local cDirOri 	   	:= ""
Local aArquivos	   	:= {}
Local aLista	   	:= {}
Local aMatCol		:= {}
Local lOk			:= .F.
Local lRet			:= .T.    // variavel de retorno para verificar se foram selecionados os xmls ou nao
Local cExtensao		:= "*.XML"
Local cFileXML 		:= "" 
Local cPath			:= getNewPar( "MV_TISSDIR","\TISS\" ) + "TEMP\"
Local aCritGuia		:= {}
Local aCritLote		:= {}
//--- cGetFile -----
Local cMascara	:= STR0006 + " .XML | *.XML" //"Arquivos"
Local cTitulo	:= "Geração arquivo de RETORNO - Selecione o local" //MMM"Geração arquivo de RETORNO - Selecione o local"
Local nMascpad	:= 0
Local cRootPath	:= ""
Local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
Local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
Local l3Server	:= .F.
Local cArqFinal	:= ""
default lAuto 	:= .f.

// Selecionar arquivos xml
if !lAuto
	cDirOri	  := cGetFile("Todos os Arquivos|*.*|","Selecione o diretorio dos arquivos",,"",.T.,GETF_OVERWRITEPROMPT + GETF_NETWORKDRIVE + GETF_LOCALHARD + GETF_RETDIRECTORY)
else
	cDirOri := "\sigapls\plsp520testcase\"
endif

If Empty(cDirOri) // cancelou a janela de selecao do diretorio
	lRet := .F.
	Return(lRet)
EndIf

aArquivos := directory(cDirOri+cExtensao)

If Len(aArquivos) > 0
	
	// Monta lista de arquivos
	For nFor := 1 to len(aArquivos)
		aAdd(aLista,{aArquivos[nFor][1],DtoC(aArquivos[nFor][3]),aArquivos[nFor][4],AllTrim(transform(aArquivos[nFor][2]/1000,"@E 999,999,999.99"))+" KB",iif(lAuto,.t.,.f.)})
	Next
	
	aLista := aSort(aLista,,, { |x,y| DTOS(CTOD(x[2])) < DTOS(CTOD(y[2])) })
	
	// Colunas do browse
	aAdd( aMatCol,{"Arquivo"	,'@!',200} )
	aAdd( aMatCol,{"Data"		,'@!',040} )
	aAdd( aMatCol,{"Hora"		,'@!',040} )
	aAdd( aMatCol,{"Tamanho"	,'@!',040} )
		
	// Browse para selecionar
	if !lAuto
		lOk := PLSSELOPT( "Selecione o(s) arquivos(s) a serem importados", "Marca e Desmarca todos", aLista, aMatCol, K_Incluir,.T.,.T.,.F.)
	else
		lOk := .t.		
	endif

	// Verifica se algum arquivo foi selecionado
	If lOk
		lOk := aScan(aLista,{|x| x[len(aLista[1])] == .T.}) > 0
	EndIf

	// Processando arquivos
	If lOk

		if !lAuto
			cArqFinal := cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
		else
			cArqFinal := "\temp\"
		endif
		
		If Empty(cArqFinal)
			msgAlert( "Local não selecionado. Processo de geração de arquivo interrompido.","Atenção!" ) //MMM"Local não selecionado. Processo de geração de arquivo interrompido." # MMM"Atenção!"
			return()
		EndIf
		
		For nFor := 1 To Len(aLista)
			If aLista[nFor][05] .AND. ( !Empty(aLista[nFor][01]) )
				cFileXML := cDirOri + aLista[nFor][01]
				
				If( At( ":\",cFileXML ) <> 0 )	//--< COPIA ARQUIVO TEMPORARIO PARA SERVIDOR >---
					
					If( !existDir( cPath ) )
						MakeDir( cPath )
					EndIf
					
					If lAuto .or. ( CpyT2S( cFileXML,cPath,.F.,.F. ) )
						cArqTmp := cPath + substr( cFileXML,rat( "\",cFileXML ) + 1 )
						LerArquivo( cArqTmp, aCritLote, aCritGuia, cArqFinal, lAuto )
						If( fErase( cArqTmp ) == -1 )	//--< EXCLUI ARQUIVO TEMPORARIO >---
						EndIf
					EndIf
				Else	//--< ARQUIVO SERVIDOR >---
					LerArquivo( cFileXML, aCritLote, aCritGuia, cArqFinal, lAuto )
				EndIf
			EndIf
		Next nFor
		if !lAuto
			If !Empty(aCritLote)
				PLSCRIGEN(aCritLote,{ {STR0016,"@C",35},{"Arquivo","@C",70},{STR0019,"@C",60} },"RESUMO DE PROCESSAMENTO" ) //"Num.Lote" # "Arquivo"MMM # "Critica" # "RESUMO DE PROCESSAMENTO" MMM
			EndIf
			If !Empty(aCritGuia)
				PLSCRIGEN(aCritGuia,{ {"Seq.Lote","@C",35},{STR0017,"@C",30},{STR0018,"@C",40},{STR0019,"@C",60} },STR0020 ) //MMM"Seq.Lote" # "Guia" # "Beneficiario" # "Critica" # "RESUMO DE CRÍTICAS"
				cMsg := STR0021 //"Arquivo(s) processado(s) porém não foi encontrado em nossa base, algum(ns) beneficiário(s) do lote."
			EndIf
		endif
		
	Else
		lRet := .F.
	EndIf
	
ElseIf !empty(cDirOri)
	msgAlert('Pasta não contem arquivos conforme parâmetros ou operação cancelada')
	lRet := .F.
EndIf

Return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LerArquivo
Leitura do arquivo .XML utilizado a classe TXmlManager

@author    Guilherme Carvalho
@version   1.xx
@since     08/05/2018
@param     Arquivo .XML
/*/
//------------------------------------------------------------------------------------------
static function LerArquivo( cFileXML, aCritLote, aCritGuia, cArqFinal, lAuto )
	Local oXML
	Local cError	:= ""
	Local cTipoGuia	:= ""
	Local aOK		:= {}
	Local aRetFun	:= {}
	Local lArqOk	:= .F.
	Local lImporta	:= .F.
	Local lTodas	:= .T.
	Local lLocBenef := .T.
	Local aCabec	:= {}
	Local aGuias	:= {}
	Local ans		:= {}
	Local aCpo		:= {}
	Local nFor		:= 0
	Local nNS		:= 0
	Local oXMLVer := nil
	Local cErroVer := ""
	Local cAvisVer := ""
	Local aDadVer	:= {}
	Local cVerTISS := ""
	default lAuto := .f.
	
	oXMLVer := XmlParserFile(cFileXml, "_", @cErroVer, @cAvisVer)
	
	aDadVer := PXMLTOARR(classDataArr(oXMLVer))
	
	cVerTISS := PXMLTISVER(aDadVer)
	
	If empty(cVerTISS)
		cVerTISS := GetNewPar("MV_TISSVER","2.02.03")
	EndIf
	
	cVerTISS := strTran( cVerTISS,".","_" )
	
	adadVer := {}
	oXMlver := nil
	
	lArqOk := validXML( cFileXML, GetNewPar( "MV_TISSDIR","\TISS\" )+"schemas\tissV"+allTrim( cVerTISS )+".xsd" )

	If lArqOk

		oXML := TXmlManager():New()
		aOK := oXML:ReadFile( cFileXML,,oXML:Parse_nsclean )
		
		If( !aOK )
			cError := "Erro: " + oXML:Error()
			msgalert( cError )
		Else
			//--< REGISTRO NAMESPACE 'ANS' >--
			aNS := oXML:XPathGetRootNsList()
			nNS := ascan(aNS,{|x| UPPER(AllTrim(x[1])) == 'ANS'}) 
			
			if nNs==0 //se caso o xml não vir com ans
				oXML:XPathRegisterNs( "ans","http://www.ans.gov.br/padroes/tiss/schemas")	
			else
				aNS[ 1 ][ 1 ] := aNS[ nNS ][ 1 ]
				aNS[ 1 ][ 2 ] := aNS[ nNS ][ 2 ]
				oXML:XPathRegisterNs( aNS[ 1 ][ 1 ],aNS[ 1 ][ 2 ] )
			endif

			aCabec := getCabecalho( oXML )
			
			If aCabec[1][3] == "ENVIO_LOTE_GUIAS" .AND. aCabec[7][3] <> "" .AND. aCabec[8][3] <> "" 
			
				cTipoGuia := fTipoGuia( oXML )
				lImporta  := VerifArq(aCabec)
				
				If lImporta
				 
					if ( gravaCabec( aCabec, cTipoGuia ) )
						cMsg := STR0022 //"Arquivo processado com sucesso!" 
						aAdd( aCritLote,{aCabec[5][3],cFileXML,cMsg} )
						processa( { || ( aRetFun := processaGuias( oXML, aCabec ) ) },STR0008,STR0009,.F. ) //"Por favor, aguarde!" # "Gravando os dados do arquivo..." 
						
						For nFor := 1 To Len(aRetFun)
							//{lRet,lLocBenef,cSeqLote,cSeqGuia}
							If !(lLocBenef := aRetFun[nFor][02])
								cMsg := STR0010 //"Não foi encontrado em nossa base o beneficiário da guia."
								aAdd( aCritGuia,{aRetFun[nFor][03],aRetFun[nFor][04],aRetFun[nFor][05],cMsg + " - " + STR0011} ) //"Guia não processada !!!"
							EndIf
							
							If !lLocBenef
								
								DBSelectarea("B5T")
								B5T->(DBSetorder(4)) //B5T_FILIAL+B5T_SEQLOT+B5T_SEQGUI
								If B5T->(MsSeek(xFilial("B5T")+aRetFun[nFor][03]+aRetFun[nFor][04]))
									while ( B5T->(!eof()) .And. B5T->(B5T_FILIAL+B5T_SEQLOT) == xFilial("B5T")+aRetFun[nFor][03]+aRetFun[nFor][04] )
										PL520GRGUI( 5, aCpo, 'MODEL_B5T', 'PLSP520B5T' )
										B5T->( dbSkip() )
									EndDo
								EndIf
								
								DBSelectarea("B6T")
								B6T->(DBSetorder(1)) //B6T_FILIAL+B6T_SEQLOT+B6T_SEQGUI+B6T_SEQUEN
								If B6T->(MsSeek(xFilial("B6T")+aRetFun[nFor][03]+aRetFun[nFor][04]))
									while ( B6T->(!eof()) .And. B6T->(B6T_FILIAL+B6T_SEQLOT) == xFilial("B6T")+aRetFun[nFor][03]+aRetFun[nFor][04] )
										PL520GRGUI( 5, aCpo, 'MODEL_B6T', 'PLSP520B6T' )
										B6T->( dbSkip() )
									EndDo
								EndIf
								
								DBSelectarea("BNT")
								BNT->(DBSetorder(1)) //BNT_FILIAL+BNT_SEQLOT+BNT_SEQGUI+BNT_SEQUEN+BNT_SEQEQU
								If BNT->(MsSeek(xFilial("BNT")+aRetFun[nFor][03]+aRetFun[nFor][04]))
									While ( BNT->(!eof()) .And. BNT->(BNT_FILIAL+BNT_SEQLOT) == xFilial("BNT")+aRetFun[nFor][03]+aRetFun[nFor][04] )
										PL520GRGUI( 5, aCpo, 'MODEL_BNT', 'PLSP520BNT' )
										BNT->( dbSkip() )
									EndDo
								EndIf
								
							EndIf
						Next nFor
						
					Else
						aAdd( aCritLote,{aCabec[5][3],cFileXML,STR0012} ) //"Não foi possível gravar o Lote."
					EndIf
				
				Else
					aAdd( aCritLote,{aCabec[5][3],cFileXML,STR0013} ) //"Arquivo já importado anteriormente."	
				EndIf
			
			Else
				If aCabec[1][3] != "ENVIO_LOTE_GUIAS"
					aAdd( aCritLote,{"",cFileXML,"Arquivo de lote de guias inválido."} ) //MMM"Arquivo de lote de guias inválido."
				ElseIf aCabec[7][3] != "" 
					aAdd( aCritLote,{aCabec[5][3],cFileXML,STR0014} ) //"Não foi possível encontrar a Operadora Habitual do beneficiário (Origem da Mensagem)."
				Else
					aAdd( aCritLote,{aCabec[5][3],cFileXML,STR0015} ) //"Não foi possível encontrar a Operadora Origem do beneficiário (Destino da Mensagem)."
				EndIf
			EndIf
		
		EndIf
	Else
		aAdd( aCritLote,{"",cFileXML,"Arquivo de lote de guias não está no padrão TISS."} ) //MMM"Arquivo de lote de guias não está no padrão TISS."
	EndIf

	If Len(aRetFun) > 0
		processa( { || ( PLSUA525E(lAuto, aRetFun, cArqFinal) ) }, cMsg, STR0024,.F. ) //"Gerando arquivo de retorno..."
		
		// Se não achar nenhuma guia no lote, deleto o lote na B2S
		DBSelectarea("B5T")
		B5T->(DBSetorder(4)) //B5T_FILIAL+B5T_SEQLOT+B5T_SEQGUI
		If !B5T->( MsSeek(xFilial("B5T")+aRetFun[01][03]) )
			DBSelectarea("B2T")
			B2T->(DBSetorder(1)) //B2T_FILIAL+B2T_SEQLOT
			If B2T->(MsSeek(xFilial("B2T")+aRetFun[01][03]))
				PL520GRGUI( 5, aCpo, 'MODEL_B2T', 'PLSP520B2T' )
			EndIf
		EndIf
	EndIf
	
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} VerifArq
Verifica se o arquivo já foi importado anteriormente.

@author    Guilherme Carvalho
@version   1.xx
@since     04/06/2018
/*/
//------------------------------------------------------------------------------------------
static function VerifArq( aCabec )
	local lRet := .T.
	
	DBSelectarea("B2T")
	B2T->(DBSetorder(2)) //B2T_FILIAL+B2T_OPEHAB+B2T_NUMLOT
	If B2T->(MsSeek(xFilial("B2T")+aCabec[7][3]+aCabec[5][3]))
		lRet := .F.
	EndIf

return(lRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gravaCabec
Gravacao dos dados do cabecalho do arquivo - B2T

@author    Guilherme Carvalho
@version   1.xx
@since     08/05/2018
@param     nOpc(tipo de operacao) ,aCabec(dados do cabecalho)
/*/
//------------------------------------------------------------------------------------------
static function gravaCabec( aCabec, cTipoGuia )
	local aCampos	:= {}
	local lRet		:= .F.
	
	cSeqLote := GetSX8Num("B2T","B2T_SEQLOT")
	
	aadd( aCampos,{ "B2T_FILIAL"	,xFilial( "B2T" ) 						} )	// Filial
	aadd( aCampos,{ "B2T_SEQLOT"	,cSeqLote		 						} )	// Sequencia do Lote
	aadd( aCampos,{ "B2T_NUMLOT"	,aCabec[5][3] 							} )	// Numero do Lote
	aadd( aCampos,{ "B2T_STATUS"	,'1'									} )	// Status - 1 = Recebido
	aAdd( aCampos,{ "B2T_TIPGUI"	,cTipoGuia	 							} ) // Tipo das Guias
	aadd( aCampos,{ "B2T_OPEORI"	,aCabec[8][3] 							} )	// Operadora Destino no arquivo
	aadd( aCampos,{ "B2T_OPEHAB"	,aCabec[7][3]							} )	// Operadora Origem no arquivo
	aadd( aCampos,{ "B2T_SEQTRA"	,aCabec[2][3] 							} )	// Sequencia da Transação
	aadd( aCampos,{ "B2T_DATTRA"	,stod( strTran( aCabec[3][3],"-","" ) ) } )	// Data da Transação
	aadd( aCampos,{ "B2T_HORTRA"	,substr(StrTran(aCabec[4][3],":",""),1,6) } )	// Hora da Transação
	aadd( aCampos,{ "B2T_TISVER"	,aCabec[6][3] 							} )	// versao TISS
	aadd( aCampos,{ "B2T_DATIMP"	,dDataBase 								} )	// Data da Importação
	aadd( aCampos,{ "B2T_HORIMP"	,StrTran( AllTrim(time()),":","" ) 		} )	// Hora da Importação
	aadd( aCampos,{ "B2T_CODRDA"	,aCabec[9][3] 							} )	// Codigo RDA da Operadora Habitual
	
	lRet := PL520GRGUI( 3, aCampos, 'MODEL_B2T', 'PLSP520B2T' )
	
	If lRet
		B2T->(ConfirmSx8())
	EndIf
	
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getCabecalho
Leitura dos dados do cabecalho

@author    Guilherme Carvalho
@version   1.xx
@since     08/05/2018
@param     oXML(XML convertido em objeto)
@return    Array contendo os dados do cabecalho
/*/
//------------------------------------------------------------------------------------------
static function getCabecalho( oXML )
	local nx		:= 0
	local nPosANS	:= 0
	local nPosCNPJ	:= 0
	local aCabec	:= {}
	local aOrigem	:= {}
	local aDestino	:= {}
	local aPathTag	:= {}
	local cPathTag	:= ""
	local cOpeHab	:= ""
	local cOpeOri	:= ""
	Local cCodRDA	:= ""

	cPathTag := "/ans:mensagemTISS/ans:cabecalho"

	if( oXml:XPathHasNode( cPathTag ) )
		
		aPathTag := { 	"/ans:mensagemTISS/ans:cabecalho/ans:identificacaoTransacao/ans:tipoTransacao",;
						"/ans:mensagemTISS/ans:cabecalho/ans:identificacaoTransacao/ans:sequencialTransacao",;
						"/ans:mensagemTISS/ans:cabecalho/ans:identificacaoTransacao/ans:dataRegistroTransacao",;
						"/ans:mensagemTISS/ans:cabecalho/ans:identificacaoTransacao/ans:horaRegistroTransacao",;
						"/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:numeroLote",;
						"/ans:mensagemTISS/ans:cabecalho/ans:Padrao";
					}
				
		for nx:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nx ] ) )
				aadd( aCabec,{ subStr( aPathTag[ nx ],rat( ":",aPathTag[ nx ])+1 ),aPathTag[ nx ],oXML:XPathGetNodeValue( aPathTag[ nx ] ) } )
			endIf
		next nx
		
		aPathTag := { 	"/ans:mensagemTISS/ans:cabecalho/ans:origem/ans:registroANS",;
						"/ans:mensagemTISS/ans:cabecalho/ans:origem/ans:identificacaoPrestador/ans:CNPJ",;
						"/ans:mensagemTISS/ans:cabecalho/ans:origem/ans:identificacaoPrestador/ans:codigoPrestadorNaOperadora";
					}
				
		for nx:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nx ] ) )
				aadd( aOrigem,{ subStr( aPathTag[ nx ],rat( ":",aPathTag[ nx ])+1 ),aPathTag[ nx ],oXML:XPathGetNodeValue( aPathTag[ nx ] ) } )
			endIf
		next nx
		
		aPathTag := { 	"/ans:mensagemTISS/ans:cabecalho/ans:destino/ans:registroANS",;
						"/ans:mensagemTISS/ans:cabecalho/ans:destino/ans:identificacaoPrestador/ans:CNPJ",;
						"/ans:mensagemTISS/ans:cabecalho/ans:destino/ans:identificacaoPrestador/ans:codigoPrestadorNaOperadora";
					}
		
		for nx:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nx ] ) )
				aadd( aDestino,{ subStr( aPathTag[ nx ],rat( ":",aPathTag[ nx ])+1 ),aPathTag[ nx ],oXML:XPathGetNodeValue( aPathTag[ nx ] ) } )
			endIf
		next nx
		
	endIf
	
	//Operadora Origem da mensagem - Operadora Habitual
	nPosANS := ascan( aOrigem ,{ | x | x[ 1 ] == "registroANS" } )
	If nPosANS > 0	
		cOpeHab	:= AllTrim( Posicione("BA0",5,xFilial("BA0")+allTrim(aOrigem[nPosANS][3]),"BA0_CODIDE+BA0_CODINT") )
	Else
		nPosCNPJ := ascan( aOrigem ,{ | x | x[ 1 ] == "CNPJ" } )
		If nPosCNPJ > 0
			DBSelectarea("BA0")
			BA0->(DBSetorder(4)) ////BA0_FILIAL+BA0_CGC
			If BA0->(MsSeek(xFilial("BA0")+aOrigem[nPosCNPJ][3]))
				cOpeHab := AllTrim(BA0->(BA0_CODIDE+BA0_CODINT))	
			EndIf
		EndIf
	EndIf
	
	//Operadora Destino da mensagem - Operadora Origem
	nPosANS := ascan( aDestino ,{ | x | x[ 1 ] == "registroANS" } )
	If nPosANS > 0
		cOpeOri	:= AllTrim( Posicione("BA0",5,xFilial("BA0")+allTrim(aDestino[nPosANS][3]),"BA0_CODIDE+BA0_CODINT") )
	Else
		nPosCNPJ := ascan( aDestino ,{ | x | x[ 1 ] == "CNPJ" } )
		If nPosCNPJ > 0
			DBSelectarea("BA0")
			BA0->(DBSetorder(4)) ////BA0_FILIAL+BA0_CGC
			If BA0->(MsSeek(xFilial("BA0")+aDestino[nPosCNPJ][3]))
				cOpeOri := AllTrim(BA0->(BA0_CODIDE+BA0_CODINT))	
			EndIf
		EndIf
	EndIf
	
	cCodRDA := ""
	If !Empty(cOpeHab)
		BAU->(DbSetOrder(7))//BAU_FILIAL+BAU_CODOPE
		If BAU->(DbSeek(xFilial("BAU")+cOpeHab))
			cCodRDA := BAU->BAU_CODIGO
		EndIf
	EndIf
	
	aadd( aCabec,{ "Habitual", 	"", cOpeHab } )
	aadd( aCabec,{ "Origem", 	"", cOpeOri } )
	aadd( aCabec,{ "CodRda", 	"", cCodRDA } )
	aCabec[2][3] := strzero( val(aCabec[2][3]),7 )
	aCabec[5][3] := strzero( val(aCabec[5][3]),12 )
return aCabec

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fTipoGuia
Busca o tipo da Guia

@author    Guilherme Carvalho
@version   1.xx
@since     08/05/2018
@param     oXML(XML convertido em objeto)
@return    Variavel contendo o tipo da guia
/*/
//------------------------------------------------------------------------------------------
static function fTipoGuia( oXML )
	local cTipo			:= ""
	local cPathTag 		:= "/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:guiasTISS"	
	local cTagSADT 		:= "/ans:guiaSP-SADT"
	local cTagInter 	:= "/ans:guiaResumoInternacao"
	local cTagHonor 	:= "/ans:guiaHonorarios"
	local cTagConsul	:= "/ans:guiaConsulta"

If( oXml:XPathHasNode( cPathTag+cTagSADT ) .Or. oXml:XPathHasNode( cPathTag+cTagSADT+"[1]" ) )
	cTipo := G_SADT_ODON
ElseIf ( oXml:XPathHasNode( cPathTag+cTagInter ) .Or. oXml:XPathHasNode( cPathTag+cTagInter+"[1]" ) )
	cTipo := G_RES_INTER
ElseIf ( oXml:XPathHasNode( cPathTag+cTagHonor ) .Or. oXml:XPathHasNode( cPathTag+cTagHonor+"[1]" ) )
	cTipo := G_HONORARIO
ElseIf ( oXml:XPathHasNode( cPathTag+cTagConsul ) .Or. oXml:XPathHasNode( cPathTag+cTagConsul+"[1]" )  )
	cTipo := G_CONSULTA
EndIf

return cTipo

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} processaGuias
Leitura dos dados da Guia

@author    Guilherme Carvalho
@version   1.xx
@since     08/05/2018

@param     oXML(arquivo .xtr),aCabec(dados do cabecalho)
@return    aray de guias processadas
/*/
//------------------------------------------------------------------------------------------
static function processaGuias( oXML, aCabec )
local nx			:= 0
local nz			:= 0
local ny			:= 0
local nGuias		:= 0
local nProced		:= 0
local nProf			:= 0
local lProf  		:= .T.
local lUnico 		:= .F.
local aRet			:= { }
local aRetFun		:= { }
local aGuias		:= { }
local aCabGuia		:= { }
local aBenefici		:= { }
local aSolicit		:= { }
local aExecut		:= { }
local aInternacao	:= { }
local aAtendim		:= { }
local aProced		:= { }
local aProcedGuia	:= { }
local aProfissional	:= { }
local aPathTag		:= { }
local cPathTag 		:= "/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:guiasTISS"	
local cTagSADT 		:= "/ans:guiaSP-SADT"
local cTagInter 	:= "/ans:guiaResumoInternacao"
local cTagHonor 	:= "/ans:guiaHonorarios"
local cTagConsul	:= "/ans:guiaConsulta"

If( oXml:XPathHasNode( cPathTag+cTagSADT ) .Or. oXml:XPathHasNode( cPathTag+cTagSADT+"[1]" ) )
	
	//Verifico a quantidade de guias		
	nGuias := oXML:XPathChildCount( cPathTag )

	procRegua( nGuias )
	
	for nx:=1 to nGuias
		
		incProc( STR0025 ) //"Processando arquivo XML..."

		cPathTag := "/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:guiasTISS"+cTagSADT
		
		If nGuias > 1
			cPathTag += "["+ allTrim( str( nx ) ) +"]"
		EndIf
		
		aPathTag := { 	cPathTag + "/ans:cabecalhoGuia/ans:registroANS",;
						cPathTag + "/ans:cabecalhoGuia/ans:numeroGuiaPrestador",;
						cPathTag + "/ans:valorTotal/ans:valorTotalGeral";
					}
		aCabGuia := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aCabGuia, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:dadosBeneficiario/ans:numeroCarteira",;
						cPathTag + "/ans:dadosBeneficiario/ans:atendimentoRN",;
						cPathTag + "/ans:dadosBeneficiario/ans:nomeBeneficiario",;
						cPathTag + "/ans:dadosBeneficiario/ans:numeroCNS",;
						cPathTag + "/ans:dadosBeneficiario/ans:identificadorBeneficiario";
					}
		aBenefici := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aBenefici, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:dadosSolicitante/ans:contratadoSolicitante/ans:nomeContratado",;
						cPathTag + "/ans:dadosSolicitante/ans:profissionalSolicitante/ans:conselhoProfissional",;
						cPathTag + "/ans:dadosSolicitante/ans:profissionalSolicitante/ans:numeroConselhoProfissional",;
						cPathTag + "/ans:dadosSolicitante/ans:profissionalSolicitante/ans:UF",;
						cPathTag + "/ans:dadosSolicitante/ans:profissionalSolicitante/ans:CBOS",;
						cPathTag + "/ans:dadosSolicitacao/ans:caraterAtendimento",;
						cPathTag + "/ans:dadosSolicitante/ans:contratadoSolicitante/ans:cnpjContratado",;
						cPathTag + "/ans:dadosSolicitante/ans:contratadoSolicitante/ans:cpfContratado",;
						cPathTag + "/ans:dadosSolicitante/ans:contratadoSolicitante/ans:codigoPrestadorNaOperadora",;
						cPathTag + "/ans:dadosSolicitante/ans:profissionalSolicitante/ans:nomeProfissional",;
						cPathTag + "/ans:dadosSolicitacao/ans:dataSolicitacao",;
						cPathTag + "/ans:dadosSolicitacao/ans:indicacaoClinica";
					}
		aSolicit := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aSolicit, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:dadosExecutante/ans:contratadoExecutante/ans:nomeContratado",;
						cPathTag + "/ans:dadosExecutante/ans:CNES",;
						cPathTag + "/ans:dadosExecutante/ans:contratadoExecutante/ans:cnpjContratado",;
						cPathTag + "/ans:dadosExecutante/ans:contratadoExecutante/ans:cpfContratado",;
						cPathTag + "/ans:dadosExecutante/ans:contratadoExecutante/ans:codigoPrestadorNaOperadora";
					}
		aExecut := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aExecut, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:dadosAtendimento/ans:tipoAtendimento",;
						cPathTag + "/ans:dadosAtendimento/ans:indicacaoAcidente",;
						cPathTag + "/ans:dadosAtendimento/ans:tipoConsulta",;
						cPathTag + "/ans:dadosAtendimento/ans:motivoEncerramento";
					}
		aAtendim := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aAtendim, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		cTagProced := cPathTag+"/ans:procedimentosExecutados"
		
		aProcedGuia := { }
		
		//Verifico a quantidade de procedimentos		
		nProced := oXML:XPathChildCount( cTagProced )
		
		for ny:=1 to nProced
			
			cTagProced := cPathTag+"/ans:procedimentosExecutados/ans:procedimentoExecutado"
			
			If nProced > 1
				cTagProced += "["+ allTrim( str( ny ) ) +"]"
			EndIf
			
			aPathTag := { 	cTagProced + "/ans:dataExecucao",;
							cTagProced + "/ans:procedimento/ans:codigoTabela",;
							cTagProced + "/ans:procedimento/ans:codigoProcedimento",;
							cTagProced + "/ans:valorUnitario",;
							cTagProced + "/ans:valorTotal",;
							cTagProced + "/ans:quantidadeExecutada",;
							cTagProced + "/ans:horaInicial",;
							cTagProced + "/ans:horaFinal",;
							cTagProced + "/ans:viaAcesso",;
							cTagProced + "/ans:tecnicaUtilizada",;
							cTagProced + "/ans:sequencialItem";
						}
			aProced := { }
			for nz:=1 to len( aPathTag )
				if( oXml:XPathHasNode( aPathTag[ nz ] ) )
					aadd( aProced, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
				endIf
			next nz
			aadd( aProcedGuia, aProced )
			cTagProfis := cTagProced+"/ans:equipeSadt"
		
			nProf  := 0
			lProf  := .T.
			lUnico := .F.
			
			while lProf
				
				nProf++
				
				cTagProfis := cTagProced+"/ans:equipeSadt"
		
				If oXml:XPathHasNode( cTagProfis )
					lUnico := .T.
					lProf  := .F.
				Else
					cTagProfis += "["+ allTrim( str( nProf ) ) +"]"
					
					If !( oXml:XPathHasNode( cTagProfis ) )
						lProf := .F.
					EndIf
				EndIf
					
				If lProf .Or. lUnico 
				
					aPathTag := { 	cTagProfis + "/ans:nomeProf",;
									cTagProfis + "/ans:conselho",;
									cTagProfis + "/ans:numeroConselhoProfissional",;
									cTagProfis + "/ans:UF",;
									cTagProfis + "/ans:CBOS",;
									cTagProfis + "/ans:grauPart",;
									cTagProfis + "/ans:codProfissional/ans:cpfContratado",;
									cTagProfis + "/ans:codProfissional/ans:codigoPrestadorNaOperadora";
								}
					aProf := { }
					for nz:=1 to len( aPathTag )
						if( oXml:XPathHasNode( aPathTag[ nz ] ) )
							aadd( aProf, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
						endIf
					next nz
					aadd( aProfissional, { ny, aProf } )
				
				EndIf
			
			EndDo
		next ny

		cTagProced := cPathTag+"/ans:outrasDespesas"

		//Verifico a quantidade de procedimentos		
		nProced := oXML:XPathChildCount( cTagProced )
		
		for ny:=1 to nProced
			
			cTagProced := cPathTag+"/ans:outrasDespesas/ans:despesa"
			
			if nProced > 1
				cTagProced += "["+ allTrim( str( ny ) ) +"]"
			endif

			aPathTag := { 	cTagProced + "/ans:servicosExecutados/ans:dataExecucao",;
							cTagProced + "/ans:servicosExecutados/ans:codigoTabela",;
							cTagProced + "/ans:servicosExecutados/ans:codigoProcedimento",;
							cTagProced + "/ans:servicosExecutados/ans:valorUnitario",;
							cTagProced + "/ans:servicosExecutados/ans:valorTotal",;
							cTagProced + "/ans:servicosExecutados/ans:quantidadeExecutada",;
							cTagProced + "/ans:servicosExecutados/ans:horaInicial",;
							cTagProced + "/ans:servicosExecutados/ans:horaFinal",;
							cTagProced + "/ans:sequencialItem";
						}
			aProced := { }
			for nz:=1 to len( aPathTag )
				if( oXml:XPathHasNode( aPathTag[ nz ] ) )
					aadd( aProced, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
				endIf
			next nz
			
			aadd( aProcedGuia, aProced )
			
		next ny
		
		aRetFun := gravaGuia( aCabec, aCabGuia, aBenefici, aSolicit, aExecut, aInternacao, aAtendim, aProcedGuia, aProfissional, G_SADT_ODON )
		aAdd(aRet,aRetFun)
	
	next nx

ElseIf ( oXml:XPathHasNode( cPathTag+cTagInter ) .Or. oXml:XPathHasNode( cPathTag+cTagInter+"[1]" ) )

	//Verifico a quantidade de guias		
	nGuias := oXML:XPathChildCount( cPathTag )

	procRegua( nGuias )
	
	for nx:=1 to nGuias
		
		incProc( STR0025 ) //"Processando arquivo XML..."

		cPathTag := "/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:guiasTISS"+cTagInter
		
		If nGuias > 1
			cPathTag += "["+ allTrim( str( nx ) ) +"]"
		EndIf
		
		aPathTag := { 	cPathTag + "/ans:cabecalhoGuia/ans:registroANS",;
						cPathTag + "/ans:cabecalhoGuia/ans:numeroGuiaPrestador",;
						cPathTag + "/ans:valorTotal/ans:valorTotalGeral",;
						cPathTag + "/ans:numeroGuiaSolicitacaoInternacao",;
						cPathTag + "/ans:dadosAutorizacao/ans:dataAutorizacao",;
						cPathTag + "/ans:dadosAutorizacao/ans:senha";
					}
		aCabGuia := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aCabGuia, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:dadosBeneficiario/ans:numeroCarteira",;
						cPathTag + "/ans:dadosBeneficiario/ans:atendimentoRN",;
						cPathTag + "/ans:dadosBeneficiario/ans:nomeBeneficiario",;
						cPathTag + "/ans:dadosBeneficiario/ans:numeroCNS",;
						cPathTag + "/ans:dadosBeneficiario/ans:identificadorBeneficiario";
					}
		aBenefici := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aBenefici, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:dadosExecutante/ans:contratadoExecutante/ans:nomeContratado",;
						cPathTag + "/ans:dadosExecutante/ans:CNES",;
						cPathTag + "/ans:dadosExecutante/ans:contratadoExecutante/ans:cnpjContratado",;
						cPathTag + "/ans:dadosExecutante/ans:contratadoExecutante/ans:cpfContratado",;
						cPathTag + "/ans:dadosExecutante/ans:contratadoExecutante/ans:codigoPrestadorNaOperadora";
					}
		aExecut := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aExecut, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:dadosInternacao/ans:caraterAtendimento",;
						cPathTag + "/ans:dadosInternacao/ans:tipoFaturamento",;
						cPathTag + "/ans:dadosInternacao/ans:dataInicioFaturamento",;
						cPathTag + "/ans:dadosInternacao/ans:horaInicioFaturamento",;
						cPathTag + "/ans:dadosInternacao/ans:dataFinalFaturamento",;
						cPathTag + "/ans:dadosInternacao/ans:horaFinalFaturamento",;
						cPathTag + "/ans:dadosInternacao/ans:tipoInternacao",;
						cPathTag + "/ans:dadosInternacao/ans:regimeInternacao",;
						cPathTag + "/ans:dadosInternacao/ans:declaracoes/ans:declaracaoNascido",;
						cPathTag + "/ans:dadosInternacao/ans:declaracoes/ans:diagnosticoObito",;
						cPathTag + "/ans:dadosInternacao/ans:declaracoes/ans:declaracaoObito";
					}
		aInternacao := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aInternacao, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:dadosSaidaInternacao/ans:indicacaoAcidente",;
						cPathTag + "/ans:dadosSaidaInternacao/ans:diagnostico",;
						cPathTag + "/ans:dadosSaidaInternacao/ans:motivoEncerramento";
					}
		aAtendim := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aAtendim, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		cTagProced := cPathTag+"/ans:procedimentosExecutados"
		
		aProcedGuia 	:= { }
		aProfissional 	:= { }
		
		//Verifico a quantidade de procedimentos		
		nProced := oXML:XPathChildCount( cTagProced )
		
		for ny:=1 to nProced
			
			cTagProced := cPathTag+"/ans:procedimentosExecutados/ans:procedimentoExecutado"
			
			If nProced > 1
				cTagProced += "["+ allTrim( str( ny ) ) +"]"
			EndIf
			
			aPathTag := { 	cTagProced + "/ans:dataExecucao",;
							cTagProced + "/ans:procedimento/ans:codigoTabela",;
							cTagProced + "/ans:procedimento/ans:codigoProcedimento",;
							cTagProced + "/ans:valorUnitario",;
							cTagProced + "/ans:valorTotal",;
							cTagProced + "/ans:quantidadeExecutada",;
							cTagProced + "/ans:horaInicial",;
							cTagProced + "/ans:horaFinal",;
							cTagProced + "/ans:viaAcesso",;
							cTagProced + "/ans:tecnicaUtilizada",;
							cTagProced + "/ans:sequencialItem";
						}
			aProced := { }
			for nz:=1 to len( aPathTag )
				if( oXml:XPathHasNode( aPathTag[ nz ] ) )
					aadd( aProced, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
				endIf
			next nz
			
			aadd( aProcedGuia, aProced )
			
			cTagProfis := cTagProced+"/ans:identEquipe"
			
			nProf  := 0
			lProf  := .T.
			lUnico := .F.
			
			while lProf
				
				nProf++
				
				cTagProfis := cTagProced+"/ans:identEquipe"
		
				If oXml:XPathHasNode( cTagProfis )
					lUnico := .T.
					lProf  := .F.
				Else
					cTagProfis += "["+ allTrim( str( nProf ) ) +"]"
					
					If !( oXml:XPathHasNode( cTagProfis ) )
						lProf := .F.
					EndIf
				EndIf
					
				If lProf .Or. lUnico 
				
					aPathTag := { 	cTagProfis + "/ans:identificacaoEquipe/ans:nomeProf",;
									cTagProfis + "/ans:identificacaoEquipe/ans:conselho",;
									cTagProfis + "/ans:identificacaoEquipe/ans:numeroConselhoProfissional",;
									cTagProfis + "/ans:identificacaoEquipe/ans:UF",;
									cTagProfis + "/ans:identificacaoEquipe/ans:CBOS",;
									cTagProfis + "/ans:identificacaoEquipe/ans:grauPart",;
									cTagProfis + "/ans:identificacaoEquipe/ans:codProfissional/ans:cpfContratado",;
									cTagProfis + "/ans:identificacaoEquipe/ans:codProfissional/ans:codigoPrestadorNaOperadora";
								}

					aProf := { }
					for nz:=1 to len( aPathTag )
						if( oXml:XPathHasNode( aPathTag[ nz ] ) )
							aadd( aProf, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
						endIf
					next nz
					aadd( aProfissional, { ny, aProf } )
				
				EndIf
			
			EndDo
			
		next ny

		aRetFun := gravaGuia( aCabec, aCabGuia, aBenefici, aSolicit, aExecut, aInternacao, aAtendim, aProcedGuia, aProfissional, G_RES_INTER )
		aAdd(aRet,aRetFun)
		
	next nx

ElseIf ( oXml:XPathHasNode( cPathTag+cTagHonor ) .Or. oXml:XPathHasNode( cPathTag+cTagHonor+"[1]" ) )

	//Verifico a quantidade de guias		
	nGuias := oXML:XPathChildCount( cPathTag )

	procRegua( nGuias )
	
	for nx:=1 to nGuias
		
		incProc( STR0025 ) //"Processando arquivo XML..."

		cPathTag := "/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:guiasTISS"+cTagHonor
		
		If nGuias > 1
			cPathTag += "["+ allTrim( str( nx ) ) +"]"
		EndIf
		
		aPathTag := { 	cPathTag + "/ans:cabecalhoGuia/ans:registroANS",;
						cPathTag + "/ans:cabecalhoGuia/ans:numeroGuiaPrestador",;
						cPathTag + "/ans:valorTotalHonorarios",;
						cPathTag + "/ans:guiaSolicInternacao",;
						cPathTag + "/ans:dataEmissaoGuia",;
						cPathTag + "/ans:numeroGuiaOperadora",;
						cPathTag + "/ans:senha";
					}
		aCabGuia := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aCabGuia, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:beneficiario/ans:numeroCarteira",;
						cPathTag + "/ans:beneficiario/ans:atendimentoRN",;
						cPathTag + "/ans:beneficiario/ans:nomeBeneficiario";
					}
		aBenefici := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aBenefici, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:localContratado/ans:nomeContratado",;
						cPathTag + "/ans:localContratado/ans:cnes",;
						cPathTag + "/ans:localContratado/ans:codigoContratado/ans:cnpjLocalExecutante",;
						cPathTag + "/ans:localContratado/ans:codigoContratado/ans:codigoNaOperadora";
					}
		aExecut := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aExecut, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:dadosInternacao/ans:dataInicioFaturamento",;
						cPathTag + "/ans:dadosInternacao/ans:dataFimFaturamento";
					}
		aInternacao := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aInternacao, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		cTagProced := cPathTag+"/ans:procedimentosRealizados"
		
		aProcedGuia 	:= { }
		aProfissional 	:= { }
		
		//Verifico a quantidade de procedimentos		
		nProced := oXML:XPathChildCount( cTagProced )
		
		for ny:=1 to nProced
			
			cTagProced := cPathTag+"/ans:procedimentosRealizados/ans:procedimentoRealizado"
			
			If nProced > 1
				cTagProced += "["+ allTrim( str( ny ) ) +"]"
			EndIf
			
			aPathTag := { 	cTagProced + "/ans:dataExecucao",;
							cTagProced + "/ans:procedimento/ans:codigoTabela",;
							cTagProced + "/ans:procedimento/ans:codigoProcedimento",;
							cTagProced + "/ans:valorUnitario",;
							cTagProced + "/ans:valorTotal",;
							cTagProced + "/ans:quantidadeExecutada",;
							cTagProced + "/ans:horaInicial",;
							cTagProced + "/ans:horaFinal",;
							cTagProced + "/ans:viaAcesso",;
							cTagProced + "/ans:tecnicaUtilizada",;
							cTagProced + "/ans:sequencialItem";
						}
			aProced := { }
			for nz:=1 to len( aPathTag )
				if( oXml:XPathHasNode( aPathTag[ nz ] ) )
					aadd( aProced, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
				endIf
			next nz
			
			aadd( aProcedGuia, aProced )
			
			cTagProfis := cTagProced+"/ans:profissionais"
			
			nProf  := 0
			lProf  := .T.
			lUnico := .F.
			
			while lProf
				
				nProf++
				
				cTagProfis := cTagProced+"/ans:profissionais"
		
				If oXml:XPathHasNode( cTagProfis )
					lUnico := .T.
					lProf  := .F.
				Else
					cTagProfis += "["+ allTrim( str( nProf ) ) +"]"
					
					If !( oXml:XPathHasNode( cTagProfis ) )
						lProf := .F.
					EndIf
				EndIf
					
				If lProf .Or. lUnico 
				
					aPathTag := { 	cTagProfis + "/ans:nomeProfissional",;
									cTagProfis + "/ans:conselhoProfissional",;
									cTagProfis + "/ans:numeroConselhoProfissional",;
									cTagProfis + "/ans:UF",;
									cTagProfis + "/ans:CBO",;
									cTagProfis + "/ans:grauParticipacao",;
									cTagProfis + "/ans:codProfissional/ans:cpfContratado",;
									cTagProfis + "/ans:codProfissional/ans:codigoPrestadorNaOperadora";
								}
					aProf := { }
					for nz:=1 to len( aPathTag )
						if( oXml:XPathHasNode( aPathTag[ nz ] ) )
							aadd( aProf, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
						endIf
					next nz
					aadd( aProfissional, { ny, aProf } )
				
				EndIf
			
			EndDo

		next ny

		aRetFun := gravaGuia( aCabec, aCabGuia, aBenefici, aSolicit, aExecut, aInternacao, aAtendim, aProcedGuia, aProfissional, G_HONORARIO )
		aAdd(aRet,aRetFun)
		
	next nx


ElseIf ( oXml:XPathHasNode( cPathTag+cTagConsul ) .Or. oXml:XPathHasNode( cPathTag+cTagConsul+"[1]" )  )

	//Verifico a quantidade de guias		
	nGuias := oXML:XPathChildCount( cPathTag )

	procRegua( nGuias )
	
	for nx:=1 to nGuias
		
		incProc( STR0025 ) //"Processando arquivo XML..."

		cPathTag := "/ans:mensagemTISS/ans:prestadorParaOperadora/ans:loteGuias/ans:guiasTISS"+cTagConsul
		
		If nGuias > 1
			cPathTag += "["+ allTrim( str( nx ) ) +"]"
		EndIf
		
		aPathTag := { 	cPathTag + "/ans:cabecalhoConsulta/ans:registroANS",;
						cPathTag + "/ans:cabecalhoConsulta/ans:numeroGuiaPrestador",;
						cPathTag + "/ans:dadosAtendimento/ans:procedimento/ans:valorProcedimento",;
						cPathTag + "/ans:numeroGuiaOperadora";
					}
		aCabGuia := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aCabGuia, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:dadosBeneficiario/ans:numeroCarteira",;
						cPathTag + "/ans:dadosBeneficiario/ans:atendimentoRN",;
						cPathTag + "/ans:dadosBeneficiario/ans:nomeBeneficiario",;
						cPathTag + "/ans:dadosBeneficiario/ans:numeroCNS",;
						cPathTag + "/ans:dadosBeneficiario/ans:identificadorBeneficiario";
					}
		aBenefici := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aBenefici, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:contratadoExecutante/ans:nomeContratado",;
						cPathTag + "/ans:contratadoExecutante/ans:CNES",;
						cPathTag + "/ans:contratadoExecutante/ans:cnpjContratado",;
						cPathTag + "/ans:contratadoExecutante/ans:cpfContratado",;
						cPathTag + "/ans:contratadoExecutante/ans:codigoPrestadorNaOperadora";
					}
		aExecut := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aExecut, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:profissionalExecutante/ans:conselhoProfissional",;
						cPathTag + "/ans:profissionalExecutante/ans:numeroConselhoProfissional",;
						cPathTag + "/ans:profissionalExecutante/ans:UF",;
						cPathTag + "/ans:profissionalExecutante/ans:CBOS",;
						cPathTag + "/ans:profissionalExecutante/ans:nomeProfissional";
					}
		aProfissional := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aProfissional, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:indicacaoAcidente",;
						cPathTag + "/ans:dadosAtendimento/ans:tipoConsulta";
					}
		aAtendim := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aAtendim, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		
		aPathTag := { 	cPathTag + "/ans:dadosAtendimento/ans:dataAtendimento",;
						cPathTag + "/ans:dadosAtendimento/ans:procedimento/ans:codigoTabela",;
						cPathTag + "/ans:dadosAtendimento/ans:procedimento/ans:codigoProcedimento",;
						cPathTag + "/ans:dadosAtendimento/ans:procedimento/ans:valorProcedimento",;
						cPathTag + "/ans:dadosAtendimento/ans:procedimento/ans:valorProcedimento",;
						cPathTag + "/ans:dadosAtendimento/ans:procedimento/ans:descricaoProcedimento";						
					}
		aProced := { }
		for nz:=1 to len( aPathTag )
			if( oXml:XPathHasNode( aPathTag[ nz ] ) )
				aadd( aProced, { subStr( aPathTag[ nz ],rat( ":",aPathTag[ nz ] )+1 ),aPathTag[ nz ],oXML:XPathGetNodeValue( aPathTag[ nz ] ) } )
			endIf
		next nz
		if len(aProced) == 5
			aadd(aProced, {"descricaoProcedimento","/ans:dadosAtendimento/ans:procedimento/ans:descricaoProcedimento","CONSULTA"})
		endif
		aadd( aProcedGuia, aProced )

		aRetFun := gravaGuia( aCabec, aCabGuia, aBenefici, aSolicit, aExecut, aInternacao, aAtendim, aProcedGuia, aProfissional, G_CONSULTA )
		aAdd(aRet,aRetFun)
		
	next nx

EndIf

return aRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gravaGuia
Efetua a gravação dos dados da Guia

@author    Guilherme Carvalho
@version   1.xx
@since     02/05/2018

@param     aCabec(dados do cabecalho),aGuia(dados da guia)
/*/
//------------------------------------------------------------------------------------------
static function gravaGuia( aCabec, aCabGuia, aBenefici, aSolicit, aExecut, aInternacao, aAtendim, aProcedGuia, aProfissional, cTipoGuia )
	local aCposB2T	:= {}
	local aCposB5T	:= {}
	local aCposB6T	:= {}
	local aCposBNT	:= {}
	Local aDadA525	:= {}
	local nP		:= 0
	local nX		:= 0
	local nProcAnt	:= 1
	local nSeqEqu	:= 0
	local lRet		:= .T.
	Local lLocBenef	:= .T.
	
	local cCarAtendi 	:= ""
	local cTipAdm	 	:= ""
	local cIndCli		:= ""
	local cIndCl2		:= ""
	local cSigla		:= ""
	local cUF			:= ""
	local cGrauPart		:= ""
	local cArqGrau		:= ""
	local cCodTab		:= ""
	local cCodPro		:= ""
	local cViaTis		:= ""
	local cSeqTiss		:= ""
	
	local nPosCNS		:= ascan( aBenefici ,{ | x | x[ 1 ] == "numeroCNS" } )
	
	local nPosCNPJExe	:= ascan( aExecut, { | x | x[ 1 ] == IIF(cTipoGuia == G_HONORARIO, "cnpjLocalExecutante", "cnpjContratado") } )
	local nPosCPFExe	:= ascan( aExecut, { | x | x[ 1 ] == "cpfContratado" } )
	local nPosCodExe	:= ascan( aExecut, { | x | x[ 1 ] == IIF(cTipoGuia == G_HONORARIO, "codigoNaOperadora", "codigoPrestadorNaOperadora") } )
	
	local nPosTpAte		:= ascan( aAtendim, { | x | x[ 1 ] == "tipoAtendimento" } )
	local nPosIndAci	:= ascan( aAtendim, { | x | x[ 1 ] == "indicacaoAcidente" } )
	local nPosDiag		:= ascan( aAtendim, { | x | x[ 1 ] == "diagnostico" } )
	local nPosMotEnc	:= ascan( aAtendim, { | x | x[ 1 ] == "motivoEncerramento" } )
	
	local nPosSenha		:= ascan( aCabGuia, { | x | x[ 1 ] == "senha" } )
	local nPosGuiOpe	:= ascan( aCabGuia, { | x | x[ 1 ] == "numeroGuiaOperadora" } )
	
	local nPosDecNas	:= ascan( aInternacao, { | x | x[ 1 ] == "declaracaoNascido" } )
	local nPosObDiag	:= ascan( aInternacao, { | x | x[ 1 ] == "diagnosticoObito" } )
	local nPosDecObi	:= ascan( aInternacao, { | x | x[ 1 ] == "declaracaoObito" } )
	
	local nPosCNPJSol	:= ascan( aSolicit, { | x | x[ 1 ] == "cnpjContratado" } )
	local nPosCPFSol	:= ascan( aSolicit, { | x | x[ 1 ] == "cpfContratado" } )
	local nPosCodSol	:= ascan( aSolicit, { | x | x[ 1 ] == "codigoPrestadorNaOperadora" } )
	local nPosNomPro	:= ascan( aSolicit, { | x | x[ 1 ] == "nomeProfissional" } )
	local nPosDtSol		:= ascan( aSolicit, { | x | x[ 1 ] == "dataSolicitacao" } )
	local nPosIndCli	:= ascan( aSolicit, { | x | x[ 1 ] == "indicacaoClinica" } )
	local nPosCarAte	:= ascan( aSolicit, { | x | x[ 1 ] == "caraterAtendimento" } )
	
	local nPosGrau  	:= 0
	local nPosCGC	  	:= 0

	cSeqGuia := Soma1(cSeqGuia,3)
	aDadA525 := {}
	
	DBSelectarea("BA1")
	BA1->(DBSetorder(2)) //BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO
	aBenefici[01][3] := strzero(val(aBenefici[01][3]),17)
	If BA1->(MsSeek(xFilial("BA1")+aBenefici[01][3]))
		lLocBenef 	:= .T.
		aAdd(aDadA525,Val(aCabGuia[03][3]))
		aAdd(aDadA525,aCabGuia[02][3])
		If nPosGuiOpe > 0
			aAdd(aDadA525,aCabGuia[nPosGuiOpe][3])
		Else
			aAdd(aDadA525,"")
		EndIf
		aAdd(aDadA525,aBenefici[01][3])
		aAdd(aDadA525,aBenefici[02][3])
		aAdd(aDadA525,aBenefici[03][3])
		If nPosCNS > 0
			aAdd(aDadA525,aBenefici[nPosCNS][3])
		Else
			aAdd(aDadA525,"")
		EndIf
	Else
		lLocBenef 	:= .F.
		aAdd(aDadA525,0)
		aAdd(aDadA525,aCabGuia[02][3])
		If nPosGuiOpe > 0
			aAdd(aDadA525,aCabGuia[nPosGuiOpe][3])
		Else
			aAdd(aDadA525,"")
		EndIf
		aAdd(aDadA525,aBenefici[01][3])
		aAdd(aDadA525,aBenefici[02][3])
		aAdd(aDadA525,aBenefici[03][3])
		If nPosCNS > 0
			aAdd(aDadA525,aBenefici[nPosCNS][3])
		Else
			aAdd(aDadA525,"")
		EndIf
	EndIf
	
	If lLocBenef
	
		If cTipoGuia == G_RES_INTER .Or. cTipoGuia == G_SADT_ODON
			If cTipoGuia == G_RES_INTER
				cCarAtendi := aInternacao[01][3] 
			Else
				If nPosCarAte > 0
					cCarAtendi := aSolicit[nPosCarAte][3]
				EndIf	
			EndIf
			If !Empty(cCarAtendi) 
				//|BTU|Indice 5| BTU_FILIAL+BTU_CODTAB+BTU_CDTERM+BTU_ALIAS
				cTipAdm := AllTrim( Posicione("BTU",5,xFilial("BTU")+"23"+xFilial("BDR")+allTrim(cCarAtendi),"BTU_VLRBUS") )
			EndIf
		EndIf
		
		aAdd( aCposB5T,{ "B5T_FILIAL"	,xFilial( "B5T" ) 	  } )					// Filial
		aAdd( aCposB5T,{ "B5T_SEQLOT"	,cSeqLote			  } )					// Sequencia do Lote
		aAdd( aCposB5T,{ "B5T_SEQGUI"	,cSeqGuia			  } )					// Sequencia da Guia
		aAdd( aCposB5T,{ "B5T_NUMLOT"	,aCabec[5][3]		  } )					// Numero do Lote
		aAdd( aCposB5T,{ "B5T_TIPGUI"	,cTipoGuia 			  } )					// Tipo da Guia
		aAdd( aCposB5T,{ "B5T_OPEORI"	,aCabec[8][3]	 	  } )					// Operadora Origem
		aAdd( aCposB5T,{ "B5T_OPEHAB"	,aCabec[7][3] 		  } )					// Operadora Habitual
		aAdd( aCposB5T,{ "B5T_SUSEP "	,aCabGuia[01][3] 	  } )					// registroANS
		aAdd( aCposB5T,{ "B5T_NMGPRE"	,aCabGuia[02][3] 	  } )					// numeroGuiaPrestador
		aAdd( aCposB5T,{ "B5T_VLRTOT"	,Val(aCabGuia[03][3]) } )					// valorTotalGeral
		
		aadd( aCposB5T,{ "B5T_MATRIC"	,aBenefici[01][3] } )						// numeroCarteira
		aAdd( aCposB5T,{ "B5T_ATERNA"	,IIF(aBenefici[02][3]=="S","1","0") } )		// atendimentoRN
		aAdd( aCposB5T,{ "B5T_NOMUSR"	,aBenefici[03][3] } )						// nomeBeneficiario
		If nPosCNS > 0
			aAdd( aCposB5T,{ "B5T_NRCRNA"	,aBenefici[nPosCNS][3] } )				// numeroCNS
		EndIf
	
		aAdd( aCposB5T,{ "B5T_NOMEXE"	, SubStr(aExecut[01][3], 1, TamSx3("B5T_NOMEXE")[1] ) } )							// contratadoExecutante/nomeContratado
		aAdd( aCposB5T,{ "B5T_CNESEX"	,aExecut[02][3] } )							// CNES
		If nPosCNPJExe > 0
			aAdd( aCposB5T,{ "B5T_CGCEXE"	,aExecut[nPosCNPJExe][3] 	} )			// contratadoExecutante/cnpjContratado
		ElseIf nPosCPFExe > 0
			aAdd( aCposB5T,{ "B5T_CGCEXE"	,aExecut[nPosCPFExe][3]		} )			// contratadoExecutante/cpfContratado
		ElseIf nPosCodExe > 0
			aAdd( aCposB5T,{ "B5T_CGCEXE"	,aExecut[nPosCodExe][3] 	} )			// contratadoExecutante/codigoPrestadorNaOperadora
		EndIf
		
		If nPosTpAte > 0 
			aAdd( aCposB5T,{ "B5T_TIPATE"	,aAtendim[nPosTpAte][3] 	} )			// tipoAtendimento
		EndIf
		If nPosIndAci > 0
			aAdd( aCposB5T,{ "B5T_INDACI"	,aAtendim[nPosIndAci][3] 	} )			// indicacaoAcidente
		EndIf
		If nPosDiag > 0
			aAdd( aCposB5T,{ "B5T_CID"		,aAtendim[nPosDiag][3] 		} )			// diagnostico
		EndIf
		If nPosMotEnc > 0
			aAdd( aCposB5T,{ "B5T_TIPALT"	,aAtendim[nPosMotEnc][3] 	} )			// motivoEncerramento
		EndIf
		
		If cTipoGuia == G_CONSULTA
		
			If nPosGuiOpe > 0
				aAdd( aCposB5T,{ "B5T_GUIORI"		,aCabGuia[nPosGuiOpe][3] } )	// numeroGuiaOperadora
			EndIf
		
		ElseIf cTipoGuia == G_HONORARIO
		
			aAdd( aCposB5T,{ "B5T_GUIINT"	,aCabGuia[04][3] } )							// numeroGuiaSolicitacaoInternacao
			aAdd( aCposB5T,{ "B5T_DTDIGI"	,StoD( StrTran(aCabGuia[05][3],"-","") ) } )	// dataEmissaoGuia
			If nPosSenha > 0
				aAdd( aCposB5T,{ "B5T_SENHA",aCabGuia[nPosSenha][3]	} )						// senha
			EndIf
			If nPosGuiOpe > 0
				aAdd( aCposB5T,{ "B5T_GUIORI"		,aCabGuia[nPosGuiOpe][3] } )			// numeroGuiaOperadora
			EndIf
			
			aAdd( aCposB5T,{ "B5T_DTINIF"	,StoD( StrTran(aInternacao[01][3],"-","") ) } )	// dadosInternacao/dataInicioFaturamento
			aAdd( aCposB5T,{ "B5T_DTFIMF"	,StoD( StrTran(aInternacao[02][3],"-","") ) } )	// dadosInternacao/dataFinalFaturamento
			
		ElseIf cTipoGuia == G_RES_INTER
			
			aAdd( aCposB5T,{ "B5T_GUIINT"	,aCabGuia[04][3] } )							// numeroGuiaSolicitacaoInternacao
			aAdd( aCposB5T,{ "B5T_DTDIGI"	,StoD( StrTran(aCabGuia[05][3],"-","") ) } )	// dadosAutorizacao/dataAutorizacao
			aAdd( aCposB5T,{ "B5T_SENHA"	,aCabGuia[06][3] } )							// dadosAutorizacao/senha
			
			If nPosGuiOpe > 0
				aAdd( aCposB5T,{ "B5T_GUIORI" ,aCabGuia[nPosGuiOpe][3] } ) 					// numeroGuiaOperadora
			EndIf
			If !Empty(cTipAdm)
				aAdd( aCposB5T,{ "B5T_TIPADM"	,cTipAdm } )								// caraterAtendimento
			EndIf
			aAdd( aCposB5T,{ "B5T_TIPFAT"	,IIF( aInternacao[02][3]=="2","P","T" )  } )	// dadosInternacao/tipoFaturamento
			aAdd( aCposB5T,{ "B5T_DTINIF"	,StoD( StrTran(aInternacao[03][3],"-","") ) } )	// dadosInternacao/dataInicioFaturamento
			aAdd( aCposB5T,{ "B5T_HRINIF"	,StrTran(aInternacao[04][3],":","") } )			// dadosInternacao/horaInicioFaturamento
			aAdd( aCposB5T,{ "B5T_DTFIMF"	,StoD( StrTran(aInternacao[05][3],"-","") ) } )	// dadosInternacao/dataFinalFaturamento
			aAdd( aCposB5T,{ "B5T_HRFIMF"	,StrTran(aInternacao[06][3],":","") } )			// dadosInternacao/horaFinalFaturamento
			aAdd( aCposB5T,{ "B5T_GRPINT"	,aInternacao[07][3] } )							// dadosInternacao/tipoInternacao
			aAdd( aCposB5T,{ "B5T_REGINT"	,aInternacao[08][3] } )							// dadosInternacao/regimeInternacao
			If nPosDecNas > 0
				aAdd( aCposB5T,{ "B5T_NRDCNV"	,aInternacao[nPosDecNas][3]	} )				// dadosInternacao/declaracoes/declaracaoNascido
			End
			If nPosObDiag > 0
				aAdd( aCposB5T,{ "B5T_CIDOBT"	,aInternacao[nPosObDiag][3] } )				// dadosInternacao/declaracoes/diagnosticoObito
			EndIf
			If nPosDecObi > 0
				aAdd( aCposB5T,{ "B5T_NRDCOB"	,aInternacao[nPosDecObi][3] } )				// dadosInternacao/declaracoes/declaracaoObito
			EndIf
			
		ElseIf cTipoGuia == G_SADT_ODON
			
			//|BTU|Indice 5| BTU_FILIAL+BTU_CODTAB+BTU_CDTERM+BTU_ALIAS
			cSigla 	:= AllTrim( Posicione("BTU",5,xFilial("BTU")+'26'+AllTrim(aSolicit[02][3]),"BTU_VLRBUS") )
			If Empty(cSigla)
				cSigla := AllTrim(aSolicit[02][3])
			EndIf
			cUF := AllTrim( Posicione("BTU",5,xFilial("BTU")+"59"+AllTrim(aSolicit[04][3]),"BTU_VLRBUS") )
			If Empty(cUF)
				cUF := AllTrim(aSolicit[04][3])
			EndIf
			
			aAdd( aCposB5T,{ "B5T_NOMRDA"	, SubStr(aSolicit[01][3], 1, TamSx3("B5T_NOMRDA")[1] )} )		// contratadoSolicitante/nomeContratado
			aAdd( aCposB5T,{ "B5T_SIGSOL"	,cSigla			 } )		// profissionalSolicitante/conselhoProfissional
			aAdd( aCposB5T,{ "B5T_REGSOL"	,aSolicit[03][3] } )		// profissionalSolicitante/numeroConselhoProfissional
			aAdd( aCposB5T,{ "B5T_ESTSOL"	,cUF			 } )		// profissionalSolicitante/UF
			aAdd( aCposB5T,{ "B5T_CBOS"		,aSolicit[05][3] } )		// profissionalSolicitante/CBOS
			
			aAdd( aCposB5T,{ "B5T_TIPADM"	,cTipAdm } )				// caraterAtendimento
			
			If nPosCNPJSol > 0
				aAdd( aCposB5T,{ "B5T_CGCRDA"	,aSolicit[nPosCNPJSol][3] } )	// contratadoSolicitante/cnpjContratado
			ElseIf nPosCPFSol > 0
				aAdd( aCposB5T,{ "B5T_CGCRDA"	,aSolicit[nPosCPFSol][3]  } )	// contratadoSolicitante/cpfContratado
			ElseIf nPosCodSol > 0
				aAdd( aCposB5T,{ "B5T_CGCRDA"	,aSolicit[nPosCodSol][3]  } )	// contratadoSolicitante/codigoPrestadorNaOperadora
			EndIf
			If nPosNomPro > 0
				aAdd( aCposB5T,{ "B5T_NOMSOL"	, SubStr(aSolicit[nPosNomPro][3], 1, TamSx3("B5T_NOMSOL")[1] ) } )	// profissionalSolicitante/nomeProfissional
			EndIf
			If nPosDtSol > 0
				aAdd( aCposB5T,{ "B5T_DATSOL"	,StoD( StrTran(aSolicit[nPosDtSol][3],"-","") )	  } )	// dataSolicitacao
			EndIf
			
			If nPosIndCli > 0
				cIndCli := aSolicit[nPosIndCli][3]
				If !Empty(cIndCli)
					If Len(AllTrim(cIndCli)) > 250 
						cIndCl2 := SubStr(AllTrim(cIndCli), 250, len(AllTrim(cIndCli))-250)
						cIndCli := SubStr(AllTrim(cIndCli), 1, 250)
						aAdd( aCposB5T,{ "B5T_INDCLI"	,cIndCli 	} )		// indicacaoClinica
						aAdd( aCposB5T,{ "B5T_INDCL2"	,cIndCl2 	} )		// indicacaoClinica2
					Else
						aAdd( aCposB5T,{ "B5T_INDCLI"	,cIndCli 	} )		// indicacaoClinica
					EndIf
				EndIf
			EndIf
			
		EndIf
	
		lRet := PL520GRGUI( 3, aCposB5T, 'MODEL_B5T', 'PLSP520B5T' )
		
		If lRet
		
			for nP:=1 to len( aProcedGuia )
				
				cCodTab	:= alltrim(PLSGETVINC("BTU_CDTERM", "BR4", .F., "87",  aProcedGuia[nP][02][3],.T.))
				cCodPro := alltrim(PLSGETVINC("BTU_CDTERM", "BR8", .F., cCodTab,  alltrim(aProcedGuia[nP][03][3]), .T. ))
				BR8->(DbSetOrder(1))
				if !BR8->(MsSeek(xFilial("BR8")+cCodTab+cCodPro))
					//Se não achou sigo o padrão do PTU A500
					pergunte("PLS500    ",.F.)
					if !BR8->(MsSeek(xFilial("BR8")+mv_par14+cCodPro))
						BR8->(DbSetOrder(3))
						if BR8->(MsSeek(xFilial("BR8")+cCodPro))
							cCodTab := BR8->BR8_CODPAD
						endif
					else
						cCodTab := BR8->BR8_CODPAD
					endif
				endif

				nPosHrIni	:= ascan( aProcedGuia[nP], { | x | x[ 1 ] == "horaInicial" } )
				nPosHrFin	:= ascan( aProcedGuia[nP], { | x | x[ 1 ] == "horaFinal" } )
				nPosVia		:= ascan( aProcedGuia[nP], { | x | x[ 1 ] == "viaAcesso" } )
				nPosTecUti	:= ascan( aProcedGuia[nP], { | x | x[ 1 ] == "tecnicaUtilizada" } )
				nPosSeq		:= ascan( aProcedGuia[nP], { | x | x[ 1 ] == "sequencialItem" } )

				if nPosSeq > 0
					cSeqTiss := StrZero(Val(aProcedGuia[nP][nPosSeq][3]),nTamSeq)					
				endif
				cSeq := StrZero(nP,nTamSeq)

				aAdd( aCposB6T,{ "B6T_FILIAL"	,xFilial( "B6T" ) } )				// Filial	
				aAdd( aCposB6T,{ "B6T_SEQLOT"	,cSeqLote		  } )				// Sequencia do Lote
				aAdd( aCposB6T,{ "B6T_SEQGUI"	,cSeqGuia		  } )				// Sequencia da Guia
				aAdd( aCposB6T,{ "B6T_SEQUEN"	,cSeq 	  		  } )				// Sequencia do Evento
				If B6T->(fieldPos("B6T_SQTISS")) > 0 .And. !empty(cSeqTiss)
					aAdd( aCposB6T,{ "B6T_SQTISS"	,cSeqTiss 	  	  } )				// Sequencial TISS
				endif
				aAdd( aCposB6T,{ "B6T_NUMLOT"	,aCabec[5][3] 	  } )				// Numero Lote	
				aAdd( aCposB6T,{ "B6T_OPEORI"	,aCabec[8][3] 	  } )				// Operadora Origem	
				aAdd( aCposB6T,{ "B6T_OPEHAB"	,aCabec[7][3] 	  } )				// Operadora Habitual	
				aAdd( aCposB6T,{ "B6T_NMGPRE"	,aCabGuia[02][3]  } )				// numeroGuiaPrestador
				aAdd( aCposB6T,{ "B6T_MATRIC"	,aBenefici[01][3] } )				// Matricula/NumeroCarteira	
				aAdd( aCposB6T,{ "B6T_DATPRO"	,StoD( StrTran(aProcedGuia[nP][01][3],"-","") )	 } )			// dataExecucao			
				aAdd( aCposB6T,{ "B6T_CODPAD"	,cCodTab				} )			// codigoTabela	
				aAdd( aCposB6T,{ "B6T_CODPRO"	,cCodPro				} )			// codigoProcedimento
				aAdd( aCposB6T,{ "B6T_DESPRO"	,aProcedGuia[nP][06][3]				} )			// codigoProcedimento
				aAdd( aCposB6T,{ "B6T_VLRPRO"	,Val(aProcedGuia[nP][05][3]) } )	// valorTotal	
				//aAdd( aCposB6T,{ "B6T_VLRTPR"	,Val(aProcedGuia[nP][05][3]) } )	// valorTotal		
				If cTipoGuia == G_CONSULTA
					aAdd( aCposB6T,{ "B6T_QTDPRO"	,1 } )							// quantidadeExecutada	
				Else
					aAdd( aCposB6T,{ "B6T_QTDPRO"	,Val(aProcedGuia[nP][06][3]) } )// quantidadeExecutada
				EndIf
				If nPosHrIni > 0
					aAdd( aCposB6T,{ "B6T_HORPRO"	,substr(StrTran(aProcedGuia[nP][nPosHrIni][3],":",""),1,6) 	} )	// horaInicial	
				EndIf
				If nPosHrFin > 0
					aAdd( aCposB6T,{ "B6T_HORFIM"	,StrTran(aProcedGuia[nP][nPosHrFin][3],":","")	} )	// horaFinal
				EndIf
				If nPosVia > 0
					cViaTis := fRetVia(aCabec[8][3], aProcedGuia[nP][nPosVia][3])
					If !Empty(cViaTis)
						aAdd( aCposB6T,{ "B6T_VIA"		,cViaTis 					} )	// viaAcesso
					EndIf	
				EndIf
				If nPosTecUti > 0
					aAdd( aCposB6T,{ "B6T_TECUTI"	,aProcedGuia[nP][nPosTecUti][3]	} )	// tecnicaUtilizada
				EndIf
				
				If cTipoGuia == G_RES_INTER .Or. cTipoGuia == G_HONORARIO .Or. cTipoGuia == G_SADT_ODON
					
					for nX:=1 to len( aProfissional )
						
						If aProfissional[nX][1] == nP
							
							nPosGrau := ascan( aProfissional[nX][2], { | x | x[ 1 ] == "grauPart" } )
							nPosGrau := IIF( nPosGrau == 0, ascan(aProfissional[nX][2], { | x | x[ 1 ] == "grauParticipacao" }), nPosGrau)
							If nPosGrau > 0
								cArqGrau := AllTrim(aProfissional[nX][2][nPosGrau][3]) 
								If !Empty(cArqGrau) 
									cGrauPart := AllTrim( Posicione("BTU",5,xFilial("BTU")+'35'+allTrim(cArqGrau),"BTU_VLRBUS") )
									If Empty(cGrauPart) 
										cGrauPart := allTrim(cArqGrau)
									EndIf	
								EndIf
							EndIf
							
							nPosCGC := ascan( aProfissional[nX][2], { | x | x[ 1 ] == "cpfContratado" } )
							nPosCGC := IIF( nPosCGC == 0, ascan(aProfissional[nX][2], { | x | x[ 1 ] == "codigoPrestadorNaOperadora" }), nPosCGC)
							
							cSigla := AllTrim( Posicione("BTU",5,xFilial("BTU")+'26'+AllTrim(aProfissional[nX][2][02][3]),"BTU_VLRBUS") )
							If Empty(cSigla)
								cSigla := AllTrim(aProfissional[nX][2][02][3])
							EndIf
							
							cUF := AllTrim( Posicione("BTU",5,xFilial("BTU")+"59"+AllTrim(aProfissional[nX][2][04][3]),"BTU_VLRBUS") )
							If Empty(cUF)
								cUF := AllTrim(aProfissional[nX][2][04][3])
							EndIf
							
							If nP == nProcAnt
								nSeqEqu++
							Else
								nProcAnt := nP
								nSeqEqu  := 1
							EndIf
							
							aAdd( aCposBNT,{ "BNT_FILIAL"	,xFilial( "BNT" ) } )							// Filial	
							aAdd( aCposBNT,{ "BNT_SEQLOT"	,cSeqLote		  } )							// Sequencia do Lote
							aAdd( aCposBNT,{ "BNT_SEQGUI"	,cSeqGuia		  } )							// Sequencia da Guia
							aAdd( aCposBNT,{ "BNT_SEQUEN"	,cSeq 	  		  } )							// Sequencia do Evento
							aAdd( aCposBNT,{ "BNT_SEQEQU"	,StrZero(nSeqEqu,3)} )							// Sequencia da Equipe
							aAdd( aCposBNT,{ "BNT_NUMLOT"	,aCabec[5][3] 	  } )							// Numero Lote	
							aAdd( aCposBNT,{ "BNT_OPEORI"	,aCabec[8][3] 	  } )							// Operadora Origem	
							aAdd( aCposBNT,{ "BNT_OPEHAB"	,aCabec[7][3] 	  } )							// Operadora Habitual
							If Empty(cGrauPart) 
								aAdd( aCposBNT,{ "BNT_CODTPA"	,cGrauPart			  } )					// grauPart			
							EndIf
							If nPosCGC > 0
								aAdd( aCposBNT,{ "BNT_CGCPRE"	,AllTrim(aProfissional[nX][2][nPosCGC][3]) } )	// cpfContratado ou codigoPrestadorNaOperadora
							EndIf
							aAdd( aCposBNT,{ "BNT_NOMPRE"	,aProfissional[nX][2][01][3] } )					// nomeProf	
							aAdd( aCposBNT,{ "BNT_SIGLA"	,cSigla 				  } )					// conselho		
							aAdd( aCposBNT,{ "BNT_REGPRE"	,aProfissional[nX][2][03][3] } )					// numeroConselhoProfissional	
							aAdd( aCposBNT,{ "BNT_ESTPRE"	,cUF					  } )					// UF
							aAdd( aCposBNT,{ "BNT_CBOS"		,aProfissional[nX][2][05][3] } )					// CBOS
							
							lRet := PL520GRGUI( 3, aCposBNT, 'MODEL_BNT', 'PLSP520BNT' )
							
							nPosGrau  := 0
							nPosCGC	  := 0
							cGrauPart := ""
							cArqGrau  := ""
							cSigla	  := ""
							cUF		  := ""
							
						EndIf
						
					next nX
					
					nProcAnt := nP
			
				EndIf
				
				lRet := PL520GRGUI( 3, aCposB6T, 'MODEL_B6T', 'PLSP520B6T' )	
				
				aCposB6T	:= { }
				cCodTab		:= ""
				cCodPro 	:= ""
				nPosHrIni	:= 0
				nPosHrFin	:= 0
				nPosVia		:= 0
				nPosTecUti	:= 0
			
			next nP
	
		EndIf
		
	EndIf
	
return {lRet,lLocBenef,cSeqLote,cSeqGuia,aBenefici[01][3],aDadA525}

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PL520GRGUI
Grava os dados do Lote Guias - Tabelas [B2T-B5T-B6T]

@author    Guilherme Carvalho
@version   1.xx
@since     30/04/2018
/*/
//------------------------------------------------------------------------------------------
Function PL520GRGUI( nOpc,aCampos,cModel,cLoadModel )
	local oAux
	local oStruct
	local oModel
	local aAux
	local aErro
	
	local nI
	local nPos
	
	local lRet := .T.
	local lAux
	
	oModel := FWLoadModel( cLoadModel )
	oModel:setOperation( nOpc )
	oModel:activate()
	
	oAux	:= oModel:getModel( cModel )
	oStruct	:= oAux:getStruct()
	aAux	:= oStruct:getFields()
	
	if( nOpc <> MODEL_OPERATION_DELETE )
		begin Transaction
			for nI := 1 to len( aCampos )
				if( nPos := aScan( aAux,{| x | allTrim( x[ 3 ] ) == allTrim( aCampos[ nI,1 ] ) } ) ) > 0
					if !( lRet := oModel:setValue( cModel,aCampos[ nI,1 ],aCampos[ nI,2 ] ) )
						aErro := oModel:getErrorMessage()
						
						autoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[ 1 ] ) + ']' )
						autoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[ 2 ] ) + ']' )
						autoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[ 3 ] ) + ']' )
						autoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[ 4 ] ) + ']' )
						autoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[ 5 ] ) + ']' )
						autoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']' )
						
						mostraErro()
						disarmTransaction()
						exit
					endif
				endIf
			next nI
		end Transaction
	endIf		
	
	if( lRet := oModel:vldData() )
		oModel:commitData()
	else
		aErro := oModel:getErrorMessage()						
		autoGrLog( "Id do formulário de origem:" 	+ ' [' + AllToChar( aErro[ 1 ] ) + ']' )
		autoGrLog( "Id do campo de origem: " 		+ ' [' + AllToChar( aErro[ 2 ] ) + ']' )
		autoGrLog( "Id do formulário de erro: " 	+ ' [' + AllToChar( aErro[ 3 ] ) + ']' )
		autoGrLog( "Id do campo de erro: " 			+ ' [' + AllToChar( aErro[ 4 ] ) + ']' )
		autoGrLog( "Id do erro: " 					+ ' [' + AllToChar( aErro[ 5 ] ) + ']' )
		autoGrLog( "Mensagem do erro: " 			+ ' [' + AllToChar( aErro[ 6 ] ) + ']' )
		
		mostraErro()
		disarmTransaction()
	endif
	
	oModel:deActivate()
	oModel:destroy()
	freeObj( oModel )
	oModel := nil
	delClassInf()
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} fRetVia
Retorna codigo da Via da Operadora

@author    Guilherme Carvalho
@version   1.xx
@since     10/05/2018
/*/
//------------------------------------------------------------------------------------------
Static Function fRetVia(cCodInt, cViaTiss)
	local cVia 		:= ""
	local cQuery 	:= ""
	
cQuery := " SELECT BGR_CODVIA FROM "+RetSqlName("BGR")+" BGR " 	+ CRLF
cQuery += " WHERE 	BGR_FILIAL = '"+xFilial("BGR")+"' " 		+ CRLF
cQuery += " 	AND BGR_CODINT = '"+cCodInt+"' " 				+ CRLF 
cQuery += " 	AND BGR_VIATIS = '"+cViaTiss+"' " 				+ CRLF
cQuery += " 	AND BGR.D_E_L_E_T_ = '' " 						+ CRLF
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRBBGR", .F., .T.)
If TRBBGR->(!eof())
	cVia := AllTrim(TRBBGR->BGR_CODVIA)	
EndIf
TRBBGR->(DBCloseArea())
	
return cVia

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} validXML
Validador do arquivo XML em cima do arquivo XSD

@author    Jonatas Almeida
@version   1.xx
@since     5/09/2016
@param     cDataAnt	= Data nao formatada
@return    [lRet], lógica 

/*/
//------------------------------------------------------------------------------------------
static function validXML( cXML,cXSD )
	local cError	:= ""
	local cWarning	:= ""
	local aErrors	:= { }
	local lRet		:= .F.

	//--< Valida um arquivo XML com o XSD >--
	if( xmlFVldSch( cXML,cXSD,@cError,@cWarning ) )
		lRet := .T.
	endIf

	if( !lRet )
		if( msgYesNo( STR0026 ) ) //"Existem erros na validação do arquivo XML. Deseja salvar o arquivo de LOG?"
			geraLogErro( cError )
		endIf
	endIf
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraLogErro
Grava arquivo de log

@author    Jonatas Almeida
@version   1.xx
@since     8/09/2016
@param     cError = lista de erros encontrados

/*/
//------------------------------------------------------------------------------------------
static function geraLogErro( cError )
	local cMascara	:= STR0006 + " .LOG | *.log" //"Arquivos"
	local cTitulo	:= STR0007 //"Selecione o local"
	local nMascpad	:= 0
	local cRootPath	:= ""
	local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
	local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
	local l3Server	:= .T.	//.T. = apresenta o árvore do servidor || .F. = não apresenta
	local cFileLOG	:= "ImportacaoLoteGuias" + "_" + dtos( date() ) + "_" + strTran( allTrim( time() ),":","" ) + ".log"
	local cPathLOG	:= ""	
	local nArqLog	:= 0
	
	cPathLOG	:= cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
	nArqLog		:= fCreate( cPathLOG+cFileLOG,FC_NORMAL,,.F. )
	
	fWrite( nArqLog,cError )
	fClose( nArqLog )
return
