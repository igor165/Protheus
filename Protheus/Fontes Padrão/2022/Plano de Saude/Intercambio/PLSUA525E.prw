#include "fileIO.ch"
#include "protheus.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#INCLUDE 'PLSUA525E.CH'

#define CRLF chr( 13 ) + chr( 10 )
#define F_BLOCK  512

static cFileHASH := criatrab( nil,.F. ) + ".tmp"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSUA525E
Gerador do arquivo XML - Retorno da Importação

@author    Guilherme Carvalho
@version   1.xx
@since     09/05/2018
/*/
//------------------------------------------------------------------------------------------
function PLSUA525E(lAuto, aGuias, cArqFinal)
	local oError	:= errorBlock( { | e | trataErro( e ) } )
	local cTitulo	:= STR0001 //"Lote Guais - Gerar arquivo de RETORNO"
	local cTexto	:= CRLF + CRLF + 	STR0002 + CRLF +; 	//"Esta opção irá realizar a geração do arquivo .XML de RETORNO a ser"
										STR0003 			//"disponibilizado pela operadora Origem e importado pela operadora Executante"
	local aOpcoes	:= { STR0004,STR0005 } //"Gerar Arq." # "Cancelar"
	local nTaman	:= 3
	local nOpc		:= 0
	
	Default lAuto := .F.
	Default aGuias:= {} 	

	If LEN(aGuias) > 0
		geraArquivo(aGuias,lAuto,cArqFinal)
	EndIf
	
	errorBlock( oError )
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} trataErro
Tratamento de excecoes nao previstas

@author    Guilherme Carvalho
@version   1.xx
@since     18/04/2018
/*/
//------------------------------------------------------------------------------------------
static function trataErro( e )
	msgAlert( STR0008+" " + chr( 10 ) + e:Description,STR0009 )
	disarmTransaction()
	break
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraArquivo
Gerador do arquivo Aviso Lote Guia - Processamento dos dados

@author    Guilherme Carvalho
@version   1.xx
@since     18/04/2018
/*/
//------------------------------------------------------------------------------------------
static function geraArquivo( aGuias,lAuto,cArqFinal )
//--- cGetFile -----
local cMascara	:= STR0010 + " .XML | *.XML" //"Arquivos"
local cTitulo	:= STR0011 //"Geração arquivo de RETORNO - Selecione o local"
local nMascpad	:= 0
local cRootPath	:= ""
local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
local l3Server	:= .F.
//------------------
local cNumSeq	:= alltrim(B2T->B2T_SEQTRA)
local cFileXML	:= getNomeArq(cNumSeq)
local cPathXML	:= ""
local nCabXml	:= 0
local nArqFull	:= 0
local nBytes	:= 0
local cCabTMP	:= ""
local cDetTMP	:= ""
local cXmlTMP	:= ""
local cBuffer	:= ""
local lFinal	:= .F.
local lFlagTmp	:= .F.
local cPath		:= ""
local cNewPath	:= ""
local aPerg		:= {}
local aRetP		:= {}

local cReAnsOri := POSICIONE("BA0",1,xFilial("BA0")+B2T->B2T_OPEORI,"BA0_SUSEP")
local cReAnsDes	:= POSICIONE("BA0",1,xFilial("BA0")+B2T->B2T_OPEHAB,"BA0_SUSEP")

private nArqHash := 0

If Empty(cArqFinal)
	cArqFinal := cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
	If Empty(cArqFinal)
		If !lAuto
			msgAlert( STR0012,STR0009 ) //"Local não selecionado. Processo de geração de arquivo interrompido." # "Atenção!"
		EndIf
		disarmTransaction()
		return()
	EndIf
EndIf
cPathXML := PLSMUDSIS( "\temp\" )
if( !existDir( cPathXML ) )
	if( MakeDir( cPathXML ) <> 0 )
		If !lAuto
			msgAlert( STR0013+cPathXML,STR0009 ) //"Não foi possível criar o diretorio no servidor:" # "Atenção!"
		EndIf
		disarmTransaction()
		return()
	endIf
endIf

If  !Empty(cPathXML)
			
	nArqFull := fCreate( cPathXML+cFileXML,FC_NORMAL,,.F. )

	If nArqFull > 0 		

		nArqHash := fCreate( lower( cPathXML+cFileHASH ),FC_NORMAL,,.F. )
		cCabTMP := geraCabec( cPathXML, cFileXML, cNumSeq,  cReAnsOri, cReAnsDes )
		cDetTMP := geraGuias( cPathXML, cReAnsOri, cReAnsDes, aGuias )  

		//--< Append cabecalho TMP >--					
		nCabXml := fOpen( cCabTMP,FO_READ )

		if( nCabXml <= 0 )
			If !lAuto
				msgAlert( STR0014 + cCabTMP ) //"Não foi possível abrir o arquivo: "
			EndIf
		else
			lFinal	:= .F.
			nBytes	:= 0
			cBuffer	:= ""
		
			Do While !lFinal
				nBytes := fRead( nCabXml,@cBuffer,F_BLOCK )
				
				if( fWrite( nArqFull,cBuffer,nBytes ) < nBytes )
					lFinal := .T.
				else
					lFinal := ( nBytes == 0 )
				endIf
			EndDo

			fClose( nCabXml )
			fErase( cCabTMP )
		endIf
		
		//--< Append detalhes TMP >--						
		nTmpXml := fOpen( cDetTMP,FO_READ )

		if( nTmpXml <= 0 )
			If !lAuto
				msgAlert( STR0014 + cDetTMP )//"Não foi possível abrir o arquivo: "
			EndIf
		else
			lFinal	:= .F.
			nBytes	:= 0
			cBuffer	:= ""
				
			Do While !lFinal
				nBytes := fRead( nTmpXml,@cBuffer,F_BLOCK )
				if( fWrite( nArqFull,cBuffer,nBytes ) < nBytes )
					lFinal := .T.
				Else
					lFinal := ( nBytes == 0 )
				EndIf
			EndDo
		
			fClose( nTmpXml )
			fErase( cDetTMP )
		endIf					
		
		//--< Calculo e inclusao do HASH no arquivo >--					
		fClose( nArqHash )
							
		cHash := A270Hash( cPathXML+cFileHASH,nArqHash )
		
		cXmlTMP += A270Tag( 1,"ans:epilogo"				,''						,.T.,.F.,.T. )
		cXmlTMP += A270Tag( 2,"ans:hash"				,lower( cHash )			,.T.,.T.,.T. )
		cXmlTMP += A270Tag( 1,"ans:epilogo"				,''						,.F.,.T.,.T. )
		
		cXmlTMP += A270Tag( 0,"ans:mensagemTISS",''				,.F.,.T.,.T. )
		
		fWrite( nArqFull,cXmlTMP )
		fClose( nArqFull )

		if ( validXML( cPathXML+cFileXML,GetNewPar( "MV_TISSDIR","\TISS\" ) + "schemas\tissV"+allTrim( strTran( PGETTISVER(),".","_" ) )+".xsd" ) )
		endIf
		If !lAuto
			CpyS2T( cPathXML+cFileXML,cArqFinal,.F.,.F. )
		endif
	Else
		If !lAuto
			MsgInfo(STR0016 + allTrim( cFileXML ) ) //"Nao foi possivel criar o arquivo: "
		EndIf		
	EndIf
EndIf
return()

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraCabec
Compoe os dados do cabecalho do arquivo

@author    Guilherme Carvalho
@version   1.xx
@since     18/04/2018

@param     cPathXML = caminho do arquivo
@param     cFileXML = nome do arquivo
@return    cFileCAB = nome do arquivo
/*/
//------------------------------------------------------------------------------------------
static function geraCabec( cPathXML, cFileXML, cNumSeq, cReAnsOri, cReAnsDes )
	local cXML := ""
	local cHorComp	:= allTrim( time() )
	local cFileCAB	:= cPathXML + criatrab( nil,.F. ) + ".tmp"
	local nArqCab	:= fCreate( cFileCAB,FC_NORMAL,,.F. )
	
	cXML := '<?xml version="1.0" encoding="ISO-8859-1"?>' + CRLF
	cXML += '<ans:mensagemTISS xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' + CRLF
					
	cXML += A270Tag( 1,"ans:cabecalho"				,''						 ,.T.,.F.,.T. )
	cXML += A270Tag( 2,"ans:identificacaoTransacao" ,''						 ,.T.,.F.,.T. )
	cXML += A270Tag( 3,"ans:tipoTransacao"			,'PROTOCOLO_RECEBIMENTO' ,.T.,.T.,.T.,.F. )
	cXML += A270Tag( 3,"ans:sequencialTransacao"	,cvaltochar(val(cNumSeq)),.T.,.T.,.T. )
	cXML += A270Tag( 3,"ans:dataRegistroTransacao"	,convDataXML( dDataBase ),.T.,.T.,.T. )
	cXML += A270Tag( 3,"ans:horaRegistroTransacao"	,cHorComp				 ,.T.,.T.,.T.,.F. )
	cXML += A270Tag( 2,"ans:identificacaoTransacao"	,''						 ,.F.,.T.,.T. )
	
	cXML += A270Tag( 2,"ans:origem"					,''						 ,.T.,.F.,.T. )
	cXML += A270Tag( 3,"ans:registroANS"			,cReAnsOri               ,.T.,.T.,.T. )
	cXML += A270Tag( 2,"ans:origem"					,''						 ,.F.,.T.,.T. )
	
	cXML += A270Tag( 2,"ans:destino"				,''						 ,.T.,.F.,.T. )
	cXML += A270Tag( 3,"ans:registroANS"			,cReAnsDes                ,.T.,.T.,.T. )
	cXML += A270Tag( 2,"ans:destino"				,''					 	 ,.F.,.T.,.T. )
	
	cXML += A270Tag( 2,"ans:Padrao"					,PGETTISVER()	 ,.T.,.T.,.T.,.F. )
	cXML += A270Tag( 1,"ans:cabecalho"				,''						 ,.F.,.T.,.T. )
	
	if( nArqCab == -1 )
		msgAlert( STR0016 + cFileCAB,STR0009 ) //"Nao foi possivel criar o arquivo: " # "Atenção!"
		
		disarmTransaction()
		break
	else
		fWrite( nArqCab,cXML )
		fClose( nArqCab )
	endIf

return cFileCAB

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getNomeArq
Gerador de numerico sequencial para controle da nomenclatura do arquivo

@author    Guilherme Carvalho
@version   1.xx
@since     18/04/2018

@return    cNumSeq = Numero sequencial
/*/
//------------------------------------------------------------------------------------------
static function getNomeArq(cNumSeq)
Local sData := DToS(dDataBase)
return "AVR"+Substr(sData,1,4)+Substr(sData,5,2)+Substr(B2T->B2T_OPEHAB,2,3)+cNumSeq+".xml" //AVRaaaammuuu9999999.xml

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraGuias
Grava o protocolo de recebimento.

@author    Guilherme Carvalho
@version   1.xx
@since     18/04/2018

@return    cFileGUI = Nome do arquivo
/*/
//------------------------------------------------------------------------------------------
static function geraGuias( cPathXML, cReAnsOri, cReAnsDes, aGuias ) 
	local cAlias	:= ""
	local cFileGUI	:= cPathXML + criaTrab( nil,.F. ) + ".tmp"
	local nArqGui	:= fCreate( cFileGUI,FC_NORMAL,,.F. )
	Local cCgc		:= AllTrim( Posicione("BA0",1,xFilial("BA0")+B2T->B2T_OPEHAB,"BA0_CGC") ) 
	Local cNomeDes	:= AllTrim( Posicione("BA0",1,xFilial("BA0")+B2T->B2T_OPEHAB,"BA0_NOMINT") ) 
	local cXMLAux	:= ""
	local cCodPad 	:= ""
	local cCodPro 	:= ""
	local cDescri 	:= ""
	local nGuias	:= 0
	local nTotGuias	:= 0
	Local nFor		:= 0
	
	B5T->(dbsetorder(2))
	if B5T->(msseek(xfilial("B5T") + B2T->B2T_OPEHAB + B2T->B2T_NUMLOT))
		cCgc 		:= iif(!empty(B5T->B5T_CGCRDA),alltrim(B5T->B5T_CGCRDA),alltrim(B5T->B5T_CGCEXE))
		cNomeDes 	:= iif(!empty(B5T->B5T_NOMRDA),alltrim(B5T->B5T_NOMRDA),alltrim(B5T->B5T_NOMEXE))
	endif
	
	if( nArqGui == -1 )
		msgAlert( STR0016 + cFileGUI ) //"Nao foi possivel criar o arquivo: "
	else	
		cXMLAux := A270Tag( 1,"ans:operadoraParaPrestador"	,''	,.T.,.F.,.T. )
		cXMLAux += A270Tag( 1,"ans:recebimentoLote"			,''	,.T.,.F.,.T. )
		
		If Len(aGuias) > 0
			
			For nFor := 1 To Len(aGuias)
				If aGuias[nFor][02]
					nTotGuias += aGuias[nFor][06][01]
				EndIf
				nGuias++
			Next nFor
			
			ProcRegua( nGuias )
			
			cXMLAux += A270Tag( 2,"ans:protocoloRecebimento"	,''									,.T.,.F.,.T. )
		    cXMLAux += A270Tag( 3,"ans:registroANS"				,allTrim( cReAnsDes )				,.T.,.T.,.T. )
		    cXMLAux += A270Tag( 3,"ans:dadosPrestador"			,''									,.T.,.F.,.T. )
		    
		    if len(allTrim( cCgc  )) > 11
				cXMLAux += A270Tag( 4,"ans:cnpjContratado"			,allTrim( cCgc  )					,.T.,.T.,.T. )
			else
				cXMLAux += A270Tag( 4,"ans:cpfContratado"			,allTrim( cCgc )					,.T.,.T.,.T. )
			endif
			
			cXMLAux += A270Tag( 4,"ans:nomeContratado"			,allTrim( cNomeDes )				,.T.,.T.,.T. )
		    cXMLAux += A270Tag( 3,"ans:dadosPrestador"			,''									,.F.,.T.,.T. )
		    cXMLAux += A270Tag( 3,"ans:numeroLote"				,cvaltochar( val(B2T->B2T_NUMLOT) )			,.T.,.T.,.T. )
		    cXMLAux += A270Tag( 3,"ans:dataEnvioLote"			,convDataXML( B2T->B2T_DATTRA )		,.T.,.T.,.T. )
		    
		    cXMLAux += A270Tag( 3,"ans:detalheProtocolo"		,''									,.T.,.F.,.T. )
		    cXMLAux += A270Tag( 4,"ans:numeroProtocolo"			,allTrim( B2T->B2T_SEQLOT )			,.T.,.T.,.T. )
		    cXMLAux += A270Tag( 4,"ans:valorTotalProtocolo"		,allTrim(str(round(nTotGuias,2)))	,.T.,.T.,.T.,.F. )
		    
		    cXMLAux += A270Tag( 4,"ans:dadosGuiasProtocolo"		,''									,.T.,.F.,.T. )
		    
		    fWrite( nArqGui,cXMLAux )
			cXMLAux := ""
			IncProc( STR0017 ) //"Gerando dados para o arquivo de envio..."
			
		    For nFor := 1 To Len(aGuias)
				
	   			cXMLAux += A270Tag( 5,"ans:dadosGuias"			,''										,.T.,.F.,.T. )
	   			cXMLAux += A270Tag( 6,"ans:numeroGuiaPrestador"	,allTrim( aGuias[nFor][06][02] )		,.T.,.T.,.T. )
	   			If !Empty(aGuias[nFor][06][03])
	   				cXMLAux += A270Tag( 6,"ans:numeroGuiaOperadora"	,allTrim( aGuias[nFor][06][03] )	,.T.,.T.,.T. ) //Opcional
	   			EndIf
	   			cXMLAux += A270Tag( 6,"ans:dadosBeneficiario"		,''									,.T.,.F.,.T. )
				cXMLAux += A270Tag( 7,"ans:numeroCarteira"			,allTrim( aGuias[nFor][06][04] )	,.T.,.T.,.T. )
				cXMLAux += A270Tag( 7,"ans:atendimentoRN"			,allTrim( aGuias[nFor][06][05] )	,.T.,.T.,.T. )
				cXMLAux += A270Tag( 7,"ans:nomeBeneficiario"		,allTrim( aGuias[nFor][06][06] )	,.T.,.T.,.T. )
				If !(empty(aGuias[nFor][06][07])) 
					cXMLAux += A270Tag( 7,"ans:numeroCNS"			,allTrim( aGuias[nFor][06][07] )	,.T.,.T.,.T. ) //Opcional
				Endif
				cXMLAux += A270Tag( 6,"ans:dadosBeneficiario"		,''									,.F.,.T.,.T. )
				
				fWrite( nArqGui,cXMLAux )
	    		cXMLAux := ""
	    		
				/*================================== TAG - vlInformadoGuia é OPCIONAL ===================================
				cXMLAux += A270Tag( 6,"ans:vlInformadoGuia"			,''										,.T.,.F.,.T. )
				cXMLAux += A270Tag( 7,"ans:valorProcessado"			,allTrim(str(round(B5T->B5T_VLRTOT,2)))	,.T.,.T.,.T. )
				cXMLAux += A270Tag( 7,"ans:valorGlosa"				,allTrim(str(round( ,2)))		,.T.,.T.,.T. )
				cXMLAux += A270Tag( 7,"ans:valorLiberado"			,allTrim(str(round( ,2)))		,.T.,.T.,.T. )
				cXMLAux += A270Tag( 6,"ans:vlInformadoGuia"			,''										,.F.,.T.,.T. )
				//=======================================================================================================*/
				
				If !(aGuias[nFor][02])
	    			
					//====================================== TAG - glosaGuia é OPCIONAL ======================================
					cXMLAux += A270Tag( 6,"ans:glosaGuia"			,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 7,"ans:motivoGlosa"			,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 8,"ans:codigoGlosa"			,"1011"									,.T.,.T.,.T. )
					//cXMLAux += A270Tag( 8,"ans:descricaoGlosa"	,										,.T.,.T.,.T. ) //Opcional
					cXMLAux += A270Tag( 7,"ans:motivoGlosa"			,''										,.F.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:glosaGuia"			,''										,.F.,.T.,.T. )
					//=======================================================================================================*/
				
					fWrite( nArqGui,cXMLAux )
					cXMLAux := ""
						
				Else
					DBSelectarea("B5T")
					B5T->(DBSetorder(4)) //B5T_FILIAL+B5T_SEQLOT+B5T_SEQGUI
					If B5T->(MsSeek(xFilial("B5T")+aGuias[nFor][03]+aGuias[nFor][04]))
					
						//=============================== TAG - procedimentosExecutados é OPCIONAL ===================================
						DBSelectarea("B6T")
						B6T->(DBSetorder(1)) //B6T_FILIAL+B6T_SEQLOT+B6T_SEQGUI+B6T_SEQUEN
						If B6T->(MsSeek(xFilial("B6T")+B5T->(B5T_SEQLOT+B5T_SEQGUI)))
							
							cXMLAux += A270Tag( 6,"ans:procedimentosRealizados"		,''										,.T.,.F.,.T. )
							
							While ( B6T->(!eof()) .And. B6T->(B6T_FILIAL+B6T_SEQLOT+B6T_SEQGUI) == xFilial("B6T")+B5T->(B5T_SEQLOT+B5T_SEQGUI) )
		
								cXMLAux += A270Tag( 7,"ans:procedimentoRealizado"	, ''									,.T.,.F.,.T. )								
								cXMLAux += A270Tag( 8,"ans:sequencialItem"			,cvaltochar(val(B6T->B6T_SEQUEN))		,.T.,.T.,.F. )								
								cXMLAux += A270Tag( 8,"ans:dataExecucao"			,convDataXML(B6T->B6T_DATPRO)			,.T.,.T.,.F. )
								If  !Empty(B6T->B6T_HORPRO)
									cXMLAux += A270Tag( 8,"ans:horaInicial"			,ALLTRIM(TransForm(B6T->B6T_HORPRO,PesqPict("B6T","B6T_HORPRO"))),.T.,.T.,.T.,.F. )//Opcional
								EndIf
								If  !Empty(B6T->B6T_HORFIM)
									cXMLAux += A270Tag( 8,"ans:horaFinal"			,ALLTRIM(TransForm(B6T->B6T_HORFIM,PesqPict("B6T","B6T_HORFIM"))),.T.,.T.,.T.,.F. )//Opcional
								EndIf
								cXMLAux += A270Tag( 8,"ans:procedimento"			,''										,.T.,.F.,.T. )
								
								cCodPad := PLSGETVINC("BTU_CDTERM", "BR4",.F., "87", B6T->B6T_CODPAD)
								cCodPro := PLSGETVINC("BTU_CDTERM", "BR8",.F., cCodPad,B6T->B6T_CODPRO)
								cDescri := PLSIMPVINC("BR8",cCodPad	,	B6T->B6T_CODPAD+B6T->B6T_CODPRO	,.T.)
								If Empty(cDescri)
									cDescri := AllTrim(Posicione("BR8",1,xFilial("BR8")+alltrim(B6T->(B6T_CODPAD+B6T_CODPRO)),"BR8_DESCRI"))
								EndIf
								if empty(cDescri)
									cDescri := AllTrim(Posicione("BTQ",1,xFilial("BTQ")+alltrim(B6T->(B6T_CODPAD+B6T_CODPRO)),"BTQ_DESTER"))
								endif
								if empty(cDescri)
									cDescri := "PROCEDIMENTO GENERICO"
								endif
								cXMLAux += A270Tag( 9,"ans:codigoTabela"			,cCodPad			   					,.T.,.T.,.T. )
								cXMLAux += A270Tag( 9,"ans:codigoProcedimento"		,cCodPro			   					,.T.,.T.,.T. )
								cXMLAux += A270Tag( 9,"ans:descricaoProcedimento"	,allTrim( cDescri )						,.T.,.T.,.T. )
								cXMLAux += A270Tag( 8,"ans:procedimento"			,''										,.F.,.T.,.T. )							
								cXMLAux += A270Tag( 8,"ans:quantidadeExecutada"		,allTrim(str(round(B6T->B6T_QTDPRO,2)))	,.T.,.T.,.T. )
								cViaTis := AllTrim(Posicione("BGR",1,xFilial("BGR")+B6T->(B6T_OPEHAB+B6T_VIA),"BGR_VIATIS"))
								If !Empty(cViaTis)
									cXMLAux += A270Tag( 8,"ans:viaAcesso"			,alltrim( cViaTis )						,.T.,.T.,.T. )//Opcional
								EndIf
								If !Empty(B6T->B6T_TECUTI)
									cXMLAux += A270Tag( 8,"ans:tecnicaUtilizada"	,alltrim( B6T->B6T_TECUTI )				,.T.,.T.,.T. )//Opcional
								EndIf
								cXMLAux += A270Tag( 8,"ans:valorUnitario"			,allTrim(str(round(B6T->B6T_VLRPRO,2)))	,.T.,.T.,.T.,.F. )
								cXMLAux += A270Tag( 8,"ans:valorTotal"				,allTrim(str(round(B6T->B6T_VLRPRO,2)))	,.T.,.T.,.T.,.F. )
								//cXMLAux += A270Tag( 8,"ans:fatorReducaoAcrescimo"		,"1"									,.T.,.T.,.T. )//Opcional
								
								/*================================= TAG - glosasProcedimento é OPCIONAL =================================
								cXMLAux += A270Tag( 8,"ans:glosasProcedimento"		,''										,.T.,.F.,.T. )
								cXMLAux += A270Tag( 9,"ans:motivoGlosa"				,''										,.T.,.F.,.T. )
								cXMLAux += A270Tag( 10,"ans:codigoGlosa"			,allTrim()						,.T.,.T.,.T. )
								//cXMLAux += A270Tag( 10,"ans:descricaoGlosa"		,										,.T.,.T.,.T. ) //Opcional
								cXMLAux += A270Tag( 9,"ans:motivoGlosa"				,''										,.F.,.T.,.T. )
								cXMLAux += A270Tag( 8,"ans:glosasProcedimento"		,''										,.F.,.T.,.T. )
								//======================================================================================================*/
								
								cXMLAux += A270Tag( 7,"ans:procedimentoRealizado"	, ''									,.F.,.T.,.T. )
								
								fWrite( nArqGui,cXMLAux )
								cXMLAux := ""
								
								B6T->( dbSkip() )
							EndDo
							cXMLAux += A270Tag( 6,"ans:procedimentosRealizados"		,''										,.F.,.T.,.T. )
							
							fWrite( nArqGui,cXMLAux )
							cXMLAux := ""
					
						EndIf
						
					EndIf
					
					//================================== Fim da TAG - procedimentosExecutados =======================================
					
			   	EndIf
			   	
			   	cXMLAux += A270Tag( 5,"ans:dadosGuias"				,''									,.F.,.T.,.T. )
			   	
			   	fWrite( nArqGui,cXMLAux )
				cXMLAux := ""
					
		   	Next nFor
		   	
		    cXMLAux += A270Tag( 4,"ans:dadosGuiasProtocolo"		,''									,.F.,.T.,.T. )
		    cXMLAux += A270Tag( 3,"ans:detalheProtocolo"		,''									,.F.,.T.,.T. )
		    cXMLAux += A270Tag( 2,"ans:protocoloRecebimento"	,''									,.F.,.T.,.T. )
		    
		Else //mensagemErro 
			
			cXMLAux += A270Tag( 2,"ans:mensagemErro"		,''							,.T.,.F.,.T. )
		    cXMLAux += A270Tag( 3,"ans:codigoGlosa"			,"1011"						,.T.,.T.,.T. )
		    cXMLAux += A270Tag( 2,"ans:mensagemErro"		,''							,.F.,.T.,.T. )
		
		EndIf
		
		cXMLAux += A270Tag( 1,"ans:recebimentoLote"			,''	,.F.,.T.,.T. )
		cXMLAux += A270Tag( 1,"ans:operadoraParaPrestador"	,''	,.F.,.T.,.T. )
		
		fWrite( nArqGui,cXMLAux )
		fClose( nArqGui )
	
	endIf

return cFileGUI

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A270Tag
Formata a TAG XML a ser escrita no arquivo

@author    Jonatas Almeida
@version   1.xx
@since     02/09/2016

@param nSpc    = quantidade de tabulacao para identar o arquivo
@param cTag    = nome da tab
@param cVal    = valor da tag
@param lIni    = abertura de tag
@param lFin    = fechamento de tag
@param lPerNul = permitido nulo na tag
@param lRetPto = retira caracteres especiais
@param lEnvTag = retorna o conteudo da tag

@return cRetTag= tag ou vazio
/*/
//------------------------------------------------------------------------------------------
static function A270Tag( nSpc,cTag,cVal,lIni,lFin,lPerNul,lRetPto,lEnvTag )
	local	cRetTag := "" // Tag a ser gravada no arquivo texto
	
	Default lRetPto	:= .T.
	Default lEnvTag	:= .T.

	if( !empty( cVal ) .or. lPerNul )
		if( lIni ) // Inicializa a tag ?
			cRetTag += '<' + cTag + '>'
			cRetTag += allTrim( iif( lRetPto,PlRetPonto( cVal ),cVal ) )
		endIf

		if( lFin ) // Finaliza a tag ?
			cRetTag += '</' + cTag + '>'
		EndIf
		
		if lEnvTag .And. ( nArqHash > 0 ) // Escreve conteudo da tag no temporario pra calculo do hash
			FWrite(nArqHash,AllTrim(Iif(lRetPto,PlRetPonto(cVal),cVal))) 
		endIf

		cRetTag := replicate( "	", nSpc ) + cRetTag + CRLF // Identa o arquivo
	endIf
return iif( lEnvTag,cRetTag,"" )

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} A270Hash
Calculo do hash

@author    Jonatas Almeida
@version   1.xx
@since     1/09/2016
@param     cHashFile	= nome do arquivo
@param     nArqFull		= Arquivo de hash
@return    cRetHash		= Codigo Hash

/*/
//------------------------------------------------------------------------------------------
static function A270Hash( cHashFile,nArqFull )
	local cRetHash    := ""			// Hash calculado do arquivo SBX
	local cBuffer	  := ""			// Buffer lido
	local cHashBuffer := ""			// Buffer do hash calculado
	local cFnHash     := "MD5File"	// Definicao da função MD5File
	local nBytesRead  := 0			// Quantidade de bytes lidos no arquivo
	local nTamArq	  := 0			// Tamanho do arquivo em bytes
	local nFileHash	  := nArqFull	// Arquivo de hash
	local aPatch      := { }		// Conteudo do diretorio

	aPatch := directory( cHashFile,"F" )

	if( len( aPatch ) > 0 )
		nTamArq := aPatch[1,2]/1048576

		if( nTamArq > 0.9 )
			// Utilizado a macro-execucao por solicitacao da tecnologia, para evitar  
			// erro na funcao MD5File decorrente a utilizacao de binarios mais antigos
			cRetHash := &( cFnHash + "('" + cHashFile + "')" )
		else
			cBuffer   := space( F_BLOCK )
			nFileHash := fOpen( lower( cHashFile),FO_READ )
			nTamArq   := aPatch[ 1,2 ]	//Tamanho em bytes

			do while nTamArq > 0
				nBytesRead	:= fRead( nFileHash,@cBuffer,F_BLOCK )
				nTamArq		-= nBytesRead
				cHashBuffer	+= cBuffer
			endDo
			
			fClose( nFileHash )
			fErase( lower( cHashFile ) )
			cRetHash := md5( cHashBuffer,2 )
		endIf
	else
		msgInfo( STR0018 + cHashFile + CRLF + STR0019 ) //"O arquivo não foi encontrado ou não está acessível: " # "Hash do arquivo não pode ser calculado!"
	endIf
return cRetHash

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} convDataXML
Formatador de datas para o arquivo XML

@author    Jonatas Almeida
@version   1.xx
@since     5/09/2016
@param     cDataAnt	= Data nao formatada
@return    cNovaData = Data formatada para o XML

/*/
//------------------------------------------------------------------------------------------
static function convDataXML( cDataAnt )
	local cNovaData := ""
	
	if( cDataAnt <> nil )
		if( valType( cDataAnt ) == "D" )
			cDataAnt := DtoS( cDataAnt )
		else
			cDataAnt := allTrim( cDataAnt )
		endIf
		
		if(! empty( cDataAnt ))
			cNovaData := subStr( cDataAnt,1,4 ) + "-"
			cNovaData += subStr( cDataAnt,5,2 ) + "-"
			cNovaData += subStr( cDataAnt,7,2 )
		endIf
	endIf
return cNovaData

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
		if( msgYesNo( STR0020 ) ) //"Existem erros na validação do arquivo XML. Deseja salvar o arquivo de LOG?"
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
	local cMascara	:= STR0021 + " .LOG | *.log" //"Arquivos"
	local cTitulo	:= STR0022 //"Selecione o local"
	local nMascpad	:= 0
	local cRootPath	:= ""
	local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
	local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
	local l3Server	:= .T.	//.T. = apresenta o árvore do servidor || .F. = não apresenta
	local cFileLOG	:= allTrim( B2T->B2T_SEQLOT ) + "_" + dtos( date() ) + "_" + strTran( allTrim( time() ),":","" ) + ".log"
	local cPathLOG	:= ""	
	local nArqLog	:= 0	

	cPathLOG	:= cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
	nArqLog		:= fCreate( cPathLOG+cFileLOG,FC_NORMAL,,.F. )
	
	fWrite( nArqLog,cError )
	fClose( nArqLog )
return