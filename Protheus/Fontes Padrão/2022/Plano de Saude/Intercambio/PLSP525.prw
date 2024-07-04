#define CRLF chr( 13 ) + chr( 10 )
#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'PLSP525.CH'
#include "XMLXFUN.CH"
#INCLUDE "FILEIO.CH"

#DEFINE G_CONSULTA  "01"
#DEFINE G_SADT_ODON "02"
#DEFINE G_RES_INTER "05"
#DEFINE G_HONORARIO "06"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP525
Importação do arquivo .xml de retorno - Aviso Lote Guias

@author    Guilherme Carvalho
@version   1.xx
@since     23/08/2018
/*/
//------------------------------------------------------------------------------------------
function PLSP525()
	local cTitulo	:= STR0001 //"Importar arquivo de RETORNO Aviso Lote de Guias"
	local cTexto	:= CRLF + CRLF + 	STR0002 + CRLF +; 	//"Esta opção irá efetuar a leitura do arquivo .XML  de retorno a ser"
										STR0003 			//"disponibilizado pela operadora Origem e importado pela operadora Executora"
	local aOpcoes	:= { STR0004,STR0005 } //"Importar" # "Cancelar" 
	local nTaman	:= 3
	local nOpc		:= aviso( cTitulo,cTexto,aOpcoes,nTaman )
	
	if( nOpc == 1 )
		obterArquivo()
	endIf
return
 
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} obterArquivo
Abre janela de dialogo para importacao do arquivo

@author    Guilherme Carvalho
@version   1.xx
@since     08/05/2018
/*/
//------------------------------------------------------------------------------------------
static function obterArquivo()
	Local cMascara		:= STR0006 + " .XML | *.xml" //"Arquivos"
	Local cTitulo		:= STR0007 //"Selecione o arquivo"
	Local nMascpad		:= 0
	Local cRootPath	:= ""
	Local lSalvar		:= .T.	//.F. = Salva || .T. = Abre
	Local nOpcoes		:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER )
	Local l3Server		:= .T.	//.T. = apresenta o árvore do servidor || .F. = não apresenta
	Local cFileXML		:= ""
	Local cPath			:= ""
	Local cArqTmp		:= ""

	cFileXML := cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
	
	if( !empty( cFileXML ) )
		if( at( ":\",cFileXML ) <> 0 )	//--< COPIA ARQUIVO TEMPORARIO PARA SERVIDOR >---
			cPath := getNewPar( "MV_TISSDIR","\TISS\" ) + "TEMP\"
			
			if( !existDir( cPath ) )
				makeDir( cPath )
			endIf
			
			if( CpyT2S( cFileXML,cPath,.F.,.F. ) )
				cArqTmp := cPath + substr( cFileXML,rat( "\",cFileXML ) + 1 )
				lerArquivo( cArqTmp )
				if( fErase( cArqTmp ) == -1 )	//--< EXCLUI ARQUIVO TEMPORARIO >---
					
				endIf
			endIf
		else	//--< ARQUIVO SERVIDOR >---
			lerArquivo( cFileXML )
		endIf
	endIf
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} LerArquivo
Leitura do arquivo .XML utilizado a classe TXmlManager

@author    Guilherme Carvalho
@version   1.xx
@since     08/05/2018
@param     Arquivo .XML
/*/
//------------------------------------------------------------------------------------------
static function LerArquivo( cFileXML )
	local oXML
	local cError	:= ""
	local lOK		:= .F.
	local ans		:= { }
	local lArqOk	:= .F.
	Local oXMLVer := nil
	Local cErroVer := ""
	Local cAvisVer := ""
	Local aDadVer	:= {}
	Local cVerTISS := ""
	
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
		lOK := oXML:ReadFile( cFileXML,,oXML:Parse_nsclean )
		
		if( !lOK )
			cError := "Erro: " + oXML:Error()
			msgalert( cError )
		else
			//--< REGISTRO NAMESPACE 'ANS' >--
			aNS := oXML:XPathGetRootNsList()
			oXML:XPathRegisterNs( aNS[ 1 ][ 1 ],aNS[ 1 ][ 2 ] )

			processa( { || ( lOK := processaArq( oXML ) ) },STR0008,STR0009,.F. ) //"Por favor, aguarde!" # "Lendo arquivo..." 
			
			If lOK
				MsgInfo(STR0010) //"Arquivo de retorno importado."
			EndIf
		endIf
		
	endif

return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} processaArq
Leitura dos dados da Guia

@author    Guilherme Carvalho
@version   1.xx
@since     08/05/2018

@param     oXML(arquivo .xtr),aCabec(dados do cabecalho)
@return    aray de guias processadas
/*/
//------------------------------------------------------------------------------------------
static function processaArq( oXML )
Local nFor			:= 0
Local nX			:= 0
Local nGuias		:= 0
Local nPos			:= 0
Local lRet			:= .F.
Local aInfos		:= {}
Local aGuias		:= {}
Local aPathTag		:= {}
Local aCpos			:= {}
Local aGuiasOK		:= {}
Local aCritica		:= {}
Local cPathTag 		:= "/ans:mensagemTISS/ans:operadoraParaPrestador/ans:recebimentoLote/ans:protocoloRecebimento"
Local cPathSub		:= ""
Local cSeqTra		:= ""
Local cNumLote		:= ""
Local cMensagem		:= "" 	
Local cSql 			:= ""
Local cTipoGuia		:= ""
Local cRet			:= ""
	
If oXml:XPathHasNode( cPathTag )

	cPathTag := "/ans:mensagemTISS/ans:operadoraParaPrestador/ans:recebimentoLote/ans:protocoloRecebimento/ans:numeroLote"
	cNumLote	 := strzero( val(oXML:XPathGetNodeValue( cPathTag )),12 )
	
	cPathTag := "/ans:mensagemTISS/ans:operadoraParaPrestador/ans:recebimentoLote/ans:protocoloRecebimento/ans:detalheProtocolo/ans:dadosGuiasProtocolo"
	nGuias := oXML:XPathChildCount( cPathTag )
	
	For nFor := 1 To nGuias
		cPathSub := cPathTag+"/ans:dadosGuias"
		If nGuias > 1
			cPathSub += "["+ AllTrim( Str( nFor ) ) +"]"
		EndIf
		
		aPathTag := { 	cPathSub + "/ans:numeroGuiaPrestador",;
						cPathSub + "/ans:dadosBeneficiario/ans:numeroCarteira",;
						cPathSub + "/ans:dadosBeneficiario/ans:nomeBeneficiario";
					}
		aInfos := {}			
		For nX:=1 To Len( aPathTag )
			If( oXml:XPathHasNode( aPathTag[ nX ] ) )
				aAdd( aInfos, oXML:XPathGetNodeValue(aPathTag[nX]) )
			EndIf
		Next nX
		
		If oXml:XPathHasNode( cPathSub+"/ans:procedimentosRealizados" )
			aAdd( aInfos, "0" )	//0=Não Criticada
		ElseIf oXml:XPathHasNode( cPathSub+"/ans:glosaGuia" )
			aAdd( aInfos, "1" )	//1=Criticada
		EndIf
		
		aAdd (aGuias,aInfos)
	Next nFor
	
	DbSelectArea("B2S")
	B2S->(DBSetorder(1)) //B2S_FILIAL+B2S_NUMLOT+B2S_TIPGUI
	If !B2S->(MsSeek(xFilial("B2S")+cNumLote))
		MsgAlert(STR0011 + " " + cNumLote + " " + STR0012) //"Lote número" # "não encontrado."
	Else
		If B2S->B2S_STATUS == "3" 
			MsgAlert(STR0013+" "+AllTrim(B2S->B2S_NUMLOT)+" "+STR0014) //"O arquivo de retorno referente ao lote" # "já foi recebido anteriormente."	
		Else
			cTipoGuia := B2S->B2S_TIPGUI
			
			//ATUALIZA AS GUIAS
			If cTipoGuia <> G_RES_INTER //"05"
				cSql := " SELECT B2S_TIPGUI, BD5_NUMIMP, B5S_GUICRI, B5S_NUMLOT, B5S_CODOPE, B5S_CODLDP, B5S_CODPEG, B5S_NUMERO, BD5.* " 
				cSql += " FROM " + RetSqlName("B2S") + " B2S "
				
				cSql += " INNER JOIN " + RetSqlName("B5S") + " B5S "
				cSql += " 	ON  B5S.B5S_FILIAL = '" + xFilial("B5S") + "' "
				cSql += " 	AND B5S.B5S_NUMLOT = B2S.B2S_NUMLOT "
				cSql += " 	AND B5S.D_E_L_E_T_ = ' ' "
				
				cSql += " INNER JOIN " + RetSqlName("BD5") + " BD5 "
				cSql += " 	ON  BD5.BD5_FILIAL = '" + xFilial("BD5") + "' "
				cSql += " 	AND BD5.BD5_CODOPE = B5S.B5S_CODOPE "
				cSql += " 	AND BD5.BD5_CODLDP = B5S.B5S_CODLDP "
				cSql += " 	AND BD5.BD5_CODPEG = B5S.B5S_CODPEG "
				cSql += " 	AND BD5.BD5_NUMERO = B5S.B5S_NUMERO "
				cSql += " 	AND BD5.D_E_L_E_T_ = ' ' "
				
				cSql += " WHERE B2S.B2S_FILIAL = '" + xFilial("B2S") + "' "
				cSql += " 	AND B2S.B2S_STATUS = '2' "
				cSql += " 	AND B2S.B2S_NUMLOT = '"+cNumLote+"' "
				cSql += " 	AND B2S.D_E_L_E_T_ = ' ' "
				
				cSql := ChangeQuery(cSql)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbB5S",.F.,.T.)
				
				If !TrbB5S->(Eof())
					DbSelectArea("BEA")					
					
					While !TrbB5S->(Eof())
						nPos 	:= 0
						cRet	:= ""
						If TrbB5S->B2S_TIPGUI == G_HONORARIO //"06"							
							
							If !Empty(TrbB5S->BD5_NUMIMP)
								cRet := Padr(TrbB5S->BD5_NUMIMP,20)
								nPos := aScan( aGuias,{|x| AllTrim(x[1]) == AllTrim(cRet) } )							
							ElseIf !Empty(TrbB5S->BD5_GUIPRI)
								cRet := Padr(TrbB5S->BD5_GUIPRI,20)
								nPos := aScan( aGuias,{|x| AllTrim(x[1]) == AllTrim(cRet) } )
							Else
								cRet := Padr(BD5->(BD5_CODLDP+BD5_CODPEG+BD5_NUMERO),20)
								nPos := aScan( aGuias,{|x| AllTrim(x[1]) == AllTrim(cRet) } )
							EndIf
							
						Else //G_CONSULTA "01" e G_SADT_ODON "02"
							
							BEA->(DbSetOrder(12))//BEA_FILIAL + BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI + BEA_ORIMOV
							If !Empty(TrbB5S->BD5_NUMIMP)
								cRet := Padr(TrbB5S->BD5_NUMIMP,20)
								nPos := aScan( aGuias,{|x| AllTrim(x[1]) == AllTrim(cRet) } )
							ElseIf BEA->(MsSeek(xFilial("BEA")+TrbB5S->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))
								cRet := Padr(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),20)
								nPos := aScan( aGuias,{|x| AllTrim(x[1]) == AllTrim(cRet) } )
							ElseIf !Empty(TrbB5S->BD5_GUIPRI)
								cRet := Padr(TrbB5S->BD5_GUIPRI,20)
								nPos := aScan( aGuias,{|x| AllTrim(x[1]) == AllTrim(cRet) } )
							Else
								cRet := Padr(BD5->(BD5_CODLDP+BD5_CODPEG+BD5_NUMERO),20)
								nPos := aScan( aGuias,{|x| AllTrim(x[1]) == AllTrim(cRet) } )
							EndIf
							
						EndIf
						
						If nPos > 0
							//Posiciona B5S
							B5S->(DBSetorder(1)) //B5S_FILIAL+B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO
							If B5S->(MsSeek(xFilial("B5S")+TrbB5S->(B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO)))
								aAdd( aCpos,{ "B5S_GUICRI"	,aGuias[nPos][04]	} ) //0=Não Criticada;1=Criticada;2=Guia Expirada
								lRet := PLU520Grv( 4, aCpos, 'MODEL_B5S', 'PLSU520B5S' )
								If aGuias[nPos][04] == "1"
									aAdd( aCritica,{cNumLote,aGuias[nPos][01],aGuias[nPos][02],aGuias[nPos][03],STR0015} ) //"Guia Criticado na Operadora de Origem - Liberado para novo lote !!!"
								Else
									aAdd( aGuiasOK,{cNumLote,aGuias[nPos][01],aGuias[nPos][02],aGuias[nPos][03],STR0016} ) //"Guia processado com sucesso na Operadora de Origem !!!"
								EndIf
							Else 
								aAdd( aCritica,{cNumLote,aGuias[nPos][01],aGuias[nPos][02],aGuias[nPos][03],STR0017} ) //"Guia do arquivo não encontrada na tabela B5S !!!"
							EndIf
						Else
							If !Empty(cRet) 
								aAdd( aCritica,{cNumLote,cRet,"","",STR0018} ) //"Guia do lote não encontrada no arquivo !!!"
							EndIf
						EndIf
						
						TrbB5S->(dbSkip())
						
					EndDo
					
				EndIf
				
				TrbB5S->(dbCloseArea())
			Else
				
				cSql := " SELECT B2S_TIPGUI, B5S_GUICRI, B5S_NUMLOT, B5S_CODOPE, B5S_CODLDP, B5S_CODPEG, B5S_NUMERO, BE4.* " 
				cSql += " FROM " + RetSqlName("B2S") + " B2S "
				
				cSql += " INNER JOIN " + RetSqlName("B5S") + " B5S "
				cSql += " 	ON  B5S.B5S_FILIAL = '" + xFilial("B5S") + "' "
				cSql += " 	AND B5S.B5S_NUMLOT = B2S.B2S_NUMLOT "
				cSql += " 	AND B5S.D_E_L_E_T_ = ' ' "
				
				cSql += " INNER JOIN " + RetSqlName("BE4") + " BE4 "
				cSql += " 	ON  BE4.BE4_FILIAL = '" + xFilial("BE4") + "' "
				cSql += " 	AND BE4.BE4_CODOPE = B5S.B5S_CODOPE "
				cSql += " 	AND BE4.BE4_CODLDP = B5S.B5S_CODLDP "
				cSql += " 	AND BE4.BE4_CODPEG = B5S.B5S_CODPEG "
				cSql += " 	AND BE4.BE4_NUMERO = B5S.B5S_NUMERO "
				cSql += " 	AND BE4.D_E_L_E_T_ = ' ' "
				
				cSql += " WHERE B2S.B2S_FILIAL = '" + xFilial("B2S") + "' "
				cSql += " 	AND B2S.B2S_STATUS = '2' "
				cSql += " 	AND B2S.B2S_NUMLOT = '"+cNumLote+"' "
				cSql += " 	AND B2S.D_E_L_E_T_ = ' ' "
				
				cSql := ChangeQuery(cSql)
				dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbB5S",.F.,.T.)
				
				If !TrbB5S->(Eof())
					//DbSelectArea("BE4")
					
					While !TrbB5S->(Eof())
						nPos 	:= 0
						cRet	:= ""
						If TrbB5S->B2S_TIPGUI == G_RES_INTER //"06"
							BE4->(DBSetorder(15)) //BE4_FILIAL+BE4_GUIINT
							If Empty(TrbB5S->BE4_ANOINT) .And. Empty(TrbB5S->BE4_MESINT) .And. Empty(TrbB5S->BE4_NUMINT) .And. !Empty(TrbB5S->BE4_GUIINT)
								If BE4->(MsSeek(xFilial("BE4")+TrbB5S->BE4_GUIINT))  
									IIf(Empty(TrbB5S->BE4_NUMIMP),cRet := Padr(TrbB5S->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),20),cRet := Padr(TrbB5S->BE4_NUMIMP,20))
								EndIf
							Else
								IIf(Empty(TrbB5S->BE4_NUMIMP),cRet := Padr(TrbB5S->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),20),cRet := Padr(TrbB5S->BE4_NUMIMP,20))
							EndIf
							
							If !Empty(cRet)
								nPos := aScan( aGuias,{|x| AllTrim(x[1]) == AllTrim(cRet) } )
							EndIf
							
						EndIf
						
						If nPos > 0
							//Posiciona B5S
							B5S->(DBSetorder(1)) //B5S_FILIAL+B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO
							If B5S->(MsSeek(xFilial("B5S")+TrbB5S->(B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO)))
								aCpos := {}
								aAdd( aCpos,{ "B5S_GUICRI"	,aGuias[nPos][04]	} ) //0=Não Criticada;1=Criticada;2=Guia Expirada
								lRet := PLU520Grv( 4, aCpos, 'MODEL_B5S', 'PLSU520B5S' )
								If aGuias[nPos][04] == "1"
									aAdd( aCritica,{cNumLote,aGuias[nPos][01],aGuias[nPos][02],aGuias[nPos][03],STR0015} ) //"Guia Criticado na Operadora de Origem - Liberado para novo lote !!!"
								Else
									aAdd( aGuiasOK,{cNumLote,aGuias[nPos][01],aGuias[nPos][02],aGuias[nPos][03],STR0016} ) //"Guia processado com sucesso na Operadora de Origem !!!"
								EndIf
							Else 
								aAdd( aCritica,{cNumLote,aGuias[nPos][01],aGuias[nPos][02],aGuias[nPos][03],STR0017} ) //"Guia do arquivo não encontrada na tabela B5S !!!"
							EndIf
						Else
							If !Empty(cRet) 
								aAdd( aCritica,{cNumLote,cRet,"","",STR0018} ) //"Guia do lote não encontrada no arquivo !!!"
							EndIf
						EndIf
						
						TrbB5S->(dbSkip())
						
					EndDo
					
				EndIf
				
				TrbB5S->(dbCloseArea())
			
			EndIf
			
		EndIf
		
		aAdd( aCpos, { "B2S_STATUS", "3" } ) //"3" Retorno Importado
		lRet := PLU520Grv( 4, aCpos, 'MODEL_B2S', 'PLSU520B2S' )
			
	EndIf
		
Else
	
	cPathTag := "/ans:mensagemTISS/ans:operadoraParaPrestador/ans:recebimentoLote/ans:mensagemErro"
	
	If oXml:XPathHasNode( cPathTag )
		
		DBSelectarea("B5S")
		
		cPathTag := "/ans:mensagemTISS/ans:cabecalho/ans:identificacaoTransacao/ans:sequencialTransacao"
		cSeqTra	 := strzero(val(oXML:XPathGetNodeValue( cPathTag )),7)
		
		If !Empty(cSeqTra)
			cSql := " SELECT B5S.* " 
			cSql += " FROM " + RetSqlName("B2S") + " B2S "
			
			cSql += " INNER JOIN " + RetSqlName("B5S") + " B5S "
			cSql += " 	ON  B5S.B5S_FILIAL = '" + xFilial("B5S") + "' "
			cSql += " 	AND B5S.B5S_NUMLOT = B2S.B2S_NUMLOT "
			cSql += " 	AND B5S.D_E_L_E_T_ = ' ' "
			
			cSql += " WHERE B2S.B2S_FILIAL = '" + xFilial("B2S") + "' "
			cSql += " 	AND B2S.B2S_STATUS = '2' "
			cSql += " 	AND B2S.B2S_NUMSEQ = '"+AllTrim(cSeqTra)+"' "
			cSql += " 	AND B2S.D_E_L_E_T_ = ' ' "
			
			cSql := ChangeQuery(cSql)
			dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TrbB5S",.F.,.T.)
			
			If !TrbB5S->(Eof())
				
				While !TrbB5S->(Eof())
				
					//Posiciona B5S
					B5S->(DBSetorder(1)) //B5S_FILIAL+B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO
					If B5S->(MsSeek(xFilial("B5S")+TrbB5S->(B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO)))
						aAdd( aCpos,{ "B5S_GUICRI"	,"1"	} ) //0=Não Criticada;1=Criticada;2=Guia Expirada
						lRet := PLU520Grv( 4, aCpos, 'MODEL_B5S', 'PLSU520B5S' )
					EndIf
					
					TrbB5S->(dbSkip())
					
				EndDo
				
			EndIf
			TrbB5S->(dbCloseArea())
		EndIf
		
		cMensagem := STR0019+cSeqTra+"."	+CRLF 	//"A operadora origem não conseguiu importar o arquivo Lote Guias de Sequência: "
		cMensagem += STR0020				+CRLF 	//"Verifique os benefíciarios presentes no lote e gere um novo arquivo Lote Guias."
		MsgAlert(	cMensagem, STR0021) 			//"Arquivo não recebido"
		
	EndIf

EndIf

If !Empty(aGuiasOK)
	PLSCRIGEN(aGuiasOK,{ {STR0022,"@C",25},{STR0023,"@C",35},{STR0024,"@C",30},{STR0025,"@C",40},{STR0026,"@C",50} },STR0027 ) //"No Lote" # "Numero Guia" # "No Carteira" # "Beneficiario" # "Critica" # "MENSAGENS"
EndIf
If !Empty(aCritica)
	PLSCRIGEN(aCritica,{ {STR0022,"@C",25},{STR0023,"@C",35},{STR0024,"@C",30},{STR0025,"@C",40},{STR0026,"@C",50} },STR0028 ) //"No Lote" # "Numero Guia" # "No Carteira" # "Beneficiario" # "Critica" # "CRÍTICAS"
EndIf

return lRet

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
		if( msgYesNo( STR0029 ) ) //"Existem erros na validação do arquivo XML. Deseja salvar o arquivo de LOG?"
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
	local cMascara	:= "Arquivos .LOG | *.log"
	local cTitulo	:= "Selecione o local"
	local nMascpad	:= 0
	local cRootPath	:= ""
	local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
	local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
	local l3Server	:= .T.	//.T. = apresenta o árvore do servidor || .F. = não apresenta
	local cFileLOG	:= "RetornoLoteGuais" + "_" + dtos( date() ) + "_" + strTran( allTrim( time() ),":","" ) + ".log"
	local cPathLOG	:= ""	
	local nArqLog	:= 0
	
	cPathLOG	:= cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
	nArqLog		:= fCreate( cPathLOG+cFileLOG,FC_NORMAL,,.F. )
	
	fWrite( nArqLog,cError )
	fClose( nArqLog )
return