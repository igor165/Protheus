#include "fileIO.ch"
#include "protheus.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#INCLUDE 'PLSU520EXP.CH'
#INCLUDE "FWMVCDEF.CH"

#define CRLF chr( 13 ) + chr( 10 )
#define F_BLOCK  512
#define G_CONSULTA  "01"
#define G_SADT_ODON "02"
#define G_RES_INTER "05"
#define G_HONORARIO "06"

static cFileHASH := criatrab( nil,.F. ) + ".tmp"

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSU520EXP
Gerador do arquivo XML - Aviso Lote Guia entre operadoras

@author    Guilherme Carvalho
@version   1.xx
@since     18/04/2018
/*/
//------------------------------------------------------------------------------------------
function PLSU520EXP()
	local lEnd		:= .T.
	local oError	:= errorBlock( { | e | trataErro( e ) } )	
	
	begin transaction
		processa( { | lEnd | geraArquivo(@lEnd) }, STR0001,STR0002,lEnd ) //"Aguarde..." # "Gerando arquivo..."
	end transaction
	
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
	msgAlert( STR0003 + chr( 10 ) + e:Description,STR0004 ) //"Erro: "
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
static function geraArquivo( lEnd, lAuto, cMark )
//--- cGetFile -----
local cMascara	:= STR0005 + " .XML | *.XML" //"Arquivos"
local cTitulo	:= STR0006 //"Selecione o local"
local nMascpad	:= 0
local cRootPath	:= ""
local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
local l3Server	:= .F.
//------------------
local cNumSeq	:= "" //Numero sequencial de arquivos A520 gerados. 
local cFileXML	:= ""
local cPathXML	:= ""
local nCabXml	:= 0
local nArqFull	:= 0
local nBytes	:= 0
local cCabTMP	:= ""
local cDetTMP	:= ""
local cXmlTMP	:= ""
local cBuffer	:= ""
local lFinal	:= .F.
local cPath		:= ""
local cTipoGuia	:= ""
local cSql		:= ""
local cLog		:= ""
local aLog		:= {}
local aCritica	:= {}
local cArqFinal	:= ""
local cReAnsOri := ""
local cReAnsDes	:= ""
Local dDtTran	:= CToD("")
Local cHrTran	:= ""

private nArqHash := 0
default lEnd	:= .F.
default lAuto	:= .F.
default cMark	:= ""
 
B2S->( ConfirmSx8() )

if lAuto
	cArqFinal 	:= PLSMUDSIS( "\temp\" )
else
	cMark := oMBrwB2S:cMark
	cArqFinal := cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
endif

If Empty(cArqFinal)
	msgAlert( STR0007,STR0004 ) //"Local não selecionado. Processo de geração de arquivo interrompido." # "Atenção!"
	disarmTransaction()
	return()
EndIf

cPathXML := PLSMUDSIS( "\temp\" )
if( !existDir( cPathXML ) )
	if( MakeDir( cPathXML ) <> 0 )
		msgAlert( STR0008+ cPathXML,STR0004 ) //"Não foi possível criar o diretorio no servidor: " # "Atenção!"
		disarmTransaction()
		return()
	endIf
endIf

cSql := " SELECT B2S_TIPGUI, R_E_C_N_O_ RECNO, B2S_STATUS, B2S_OPEORI, B2S_NUMLOT " 
cSql += " FROM " + RetSqlName("B2S") + " B2S "
cSql += " WHERE B2S_FILIAL = '" + xFilial("B2S") + "' "
cSql += " AND B2S_OK = '" + cMark + "' "
cSql += " AND B2S.D_E_L_E_T_ = ' '  "

cSql := ChangeQuery(cSql)
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PLEXP",.F.,.T.)	

while !PLEXP->(eof())
	cTipoGuia := PLEXP->B2S_TIPGUI
	If cTipoGuia == G_CONSULTA
		cProcGuia := "CONSULTA"
	ElseIf cTipoGuia == G_SADT_ODON
		cProcGuia := "SADT"
	ElseIf cTipoGuia == G_HONORARIO
		cProcGuia := "HONORARIO"
	ElseIf cTipoGuia == G_RES_INTER
		cProcGuia := "RESUMO INTERNACAO"
	EndIf
	cXmlTMP := ""
	B2S->(dbgoto(PLEXP->RECNO))
	cReAnsOri 	:= POSICIONE("BA0",1,xFilial("BA0")+B2S->B2S_OPEHAB,"BA0_SUSEP")
 	cReAnsDes 	:= POSICIONE("BA0",1,xFilial("BA0")+B2S->B2S_OPEORI,"BA0_SUSEP")		
	cNumSeq		:= StrZero(Val(GETMV("MV_PLSE520"))+1,7)
	cFileXML  	:= getNomeArq(cNumSeq)
	cLog := ""
	If  !Empty(cPathXML)

		nArqFull := FCreate(cPathXML+cFileXML,FC_NORMAL,,.F.)

		If nArqFull > 0 		

			nArqHash := fCreate( lower( cPathXML+cFileHASH ),FC_NORMAL,,.F. )
			cCabTMP := geraCabec( cPathXML, cFileXML, cNumSeq,  cReAnsOri, cReAnsDes, @dDtTran ,@cHrTran )
			cDetTMP := geraGuias( cPathXML, @lEnd, cTipoGuia, cReAnsOri, cReAnsDes, @aCritica )

			If !lEnd

				//--< Append cabecalho TMP >--					
				nCabXml := fOpen( cCabTMP,FO_READ )

				if( nCabXml <= 0 )
					cLog +=  STR0009 + cCabTMP  //"Não foi possível abrir o arquivo: "
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
					cLog +=  STR0009 + cDetTMP  //"Não foi possível abrir o arquivo: "
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

				if( validXML( cPathXML+cFileXML,GetNewPar( "MV_TISSDIR","\TISS\" ) + "schemas\tissV"+allTrim( strTran( PGetTISVer(),".","_" ) )+".xsd", cArqFinal, cFileXML ) )

					StatGuias(cNumSeq, dDtTran ,cHrTran)

					cLog += STR0010  //"Arquivo gerado com sucesso!"
					//----------------------------------------------------------------------------
					// Atualiza numeracao sequencial do arquivo de exportação do PTU A520.       |
					//----------------------------------------------------------------------------
					PutMV("MV_PLSE520",cNumSeq)
				else
					FRename( cPathXML+cFileXML, cPathXML+strtran(cFileXML,".xml")+"_"+ allTrim( B2S->B2S_OPEORI ) + allTrim( B2S->B2S_NUMLOT ) + ".XML")
					cFileXML := strtran(cFileXML,".xml")+"_"+ allTrim( B2S->B2S_OPEORI ) + allTrim( B2S->B2S_NUMLOT ) + ".XML"
					cLog += "Erro na validação do XML, foi gerado um arquivo de LOG na mesma pasta informada."
				endIf
				
			Else

				If File(cPathXML+cFileXML)
					fClose( nArqFull )
					fErase(cPathXML+cFileXML)
				EndIf

				If File(cPathXML+cFileHASH)
					fClose( nArqHash )
					fErase(cPathXML+cFileHASH)
				EndIf

			EndIf
			if !lAuto
				CpyS2T( cPathXML+cFileXML,cArqFinal,.F.,.F. )
			endif
		Else
			cLog += STR0011 + allTrim( cFileXML )  //"Nao foi possivel criar o arquivo: "		
		EndIf
	EndIf

	aadd(aLog, {"[" + PLEXP->B2S_OPEORI + "]" + PLEXP->B2S_NUMLOT, cLog})
	PLEXP->(dbskip())
enddo

PLEXP->(dbCloseArea())

if !lAuto
	If !Empty(aCritica)
		PLSCRIGEN(aCritica,{ {"Número do Lote","@!",20}, {STR0023,"@C",120},{STR0024,"@C",020},{STR0025,"@C",15},{STR0026,"@C",100} },STR0027 ) //"Critica" # "Tabela" # "Índice" # "Chave" # "RESUMO DO PROCESSAMENTO"
	EndIf

	if len(aLog) > 0
		PLSCRIGEN(aLog,{{"Número do Lote","@!",20},{"Mensagem","@!",120}},"Log de geração",nil,nil)
	endif
endif

return {aLog,aCritica}

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
static function geraCabec( cPathXML, cFileXML, cNumSeq, cReAnsOri, cReAnsDes, dDtTran ,cHrTran )
	local cXML := ""
	local cFileCAB	:= cPathXML + criatrab( nil,.F. ) + ".tmp"
	local nArqCab	:= fCreate( cFileCAB,FC_NORMAL,,.F. )
	
	cXML := '<?xml version="1.0" encoding="ISO-8859-1"?>' + CRLF
	cXML += '<ans:mensagemTISS xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">' + CRLF
			
	cXML += A270Tag( 1,"ans:cabecalho"				,''						 ,.T.,.F.,.T. )
	cXML += A270Tag( 2,"ans:identificacaoTransacao" ,''						 ,.T.,.F.,.T. )
	cXML += A270Tag( 3,"ans:tipoTransacao"			,'ENVIO_LOTE_GUIAS'		 ,.T.,.T.,.T.,.F. )
	cXML += A270Tag( 3,"ans:sequencialTransacao"	,cvaltochar(val(cNumSeq)),.T.,.T.,.T. )	
	cXML += A270Tag( 3,"ans:dataRegistroTransacao"	,convDataXML( B2S->B2S_DATTRA ),.T.,.T.,.T. )
	cHrTran := allTrim( time() )
	cXML += A270Tag( 3,"ans:horaRegistroTransacao"	,cHrTran				 ,.T.,.T.,.T.,.F. )
	cXML += A270Tag( 2,"ans:identificacaoTransacao"	,''						 ,.F.,.T.,.T. )
	cXML += A270Tag( 2,"ans:origem"					,''						 ,.T.,.F.,.T. )
	cXML += A270Tag( 3,"ans:registroANS"			,cReAnsOri            	 ,.T.,.T.,.T. )
	cXML += A270Tag( 2,"ans:origem"					,''						 ,.F.,.T.,.T. )
	cXML += A270Tag( 2,"ans:destino"				,''						 ,.T.,.F.,.T. )
	cXML += A270Tag( 3,"ans:registroANS"			,cReAnsDes               ,.T.,.T.,.T. )
	cXML += A270Tag( 2,"ans:destino"				,''					 	 ,.F.,.T.,.T. )
	cXML += A270Tag( 2,"ans:Padrao"					,PGetTISVer()	 		 ,.T.,.T.,.T.,.F. )
	cXML += A270Tag( 1,"ans:cabecalho"				,''						 ,.F.,.T.,.T. )
	
	if( nArqCab == -1 )
		msgAlert( STR0012 + cFileCAB,STR0004 ) //"Não conseguiu criar o arquivo: " # "Atenção!"
		
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

return "AVE"+Substr(dtos(B2S->B2S_DATTRA),1,4)+Substr(dtos(B2S->B2S_DATTRA),5,2)+Substr(B2S->B2S_OPEHAB,2,3)+cNumSeq+".xml" //AVEaaaammuuu9999999.xml

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraGuias
Grava os dados obtidos na consulta no arquivo .XML

@author    Guilherme Carvalho
@version   1.xx
@since     18/04/2018

@return    cFileGUI = Nome do arquivo
/*/
//------------------------------------------------------------------------------------------
static function geraGuias( cPathXML, lEnd, cTipGuia, cReAnsOri, cReAnsDes, aCritica ) 
	Local cAlias	:= ""
	Local cFileGUI		:= cPathXML + criaTrab( nil,.F. ) + ".tmp"
	Local nArqGui		:= fCreate( cFileGUI,FC_NORMAL,,.F. )
	Local nGuias		:= 0
	Local nQtdPro		:= 0
	Local nValPro		:= 0
	Local cXMLAux		:= ""
	Local cGuia			:= ""
	Local cItemGuia 	:= ""
	Local cNumGuia		:= ""
	Local cCodPad		:= ""
	Local cCodPro		:= ""
	Local cDescri		:= ""
	Local cGuiaInt		:= ""
	Local cCnes			:= ""
	Local cCnesEx		:= ""
	Local dDtIniF		:= CToD("")
	Local dDtFimF		:= CToD("")
	Local cHrIniF		:= ""
	Local cHrFimF		:= ""
	Local cREGPRE  		:= ""
	Local cViaTis		:= ""
	Local cVincBkp		:= ""
	Local cCGCSol		:= ""
	Local cCodOriSol	:= ""
	Local cCodSol		:= ""
	Local cNomSol		:= ""
	Local cCGCExe		:= ""
	Local cCodOriExe	:= ""
	Local cCodExe		:= ""
	Local cNomExe		:= ""
	Local cCNES			:= ""
	Local cCGCRDA		:= ""
	Local cNomRDA		:= ""
	Local cRegExe 		:= ""
	Local cEstExe		:= ""
	Local cSigExe		:= ""
	Local cGuiaPres		:= ""
	Local cGrauPa 		:= ""
	Local cGrauPart 	:= ""
	//Local aCritica		:= { }
	
	default lEnd		:= .F.
	
	if( nArqGui == -1 )
		msgAlert( STR0011 ) //"Não foi possível criar o arquivo!"
	else	
		cXMLAux := A270Tag( 1,"ans:prestadorParaOperadora"	,''				,.T.,.F.,.T. )
	    cXMLAux += A270Tag( 2,"ans:loteGuias"	,''							,.T.,.F.,.T. )
	    cXMLAux += A270Tag( 3,"ans:numeroLote"	,cvaltochar(B2S->B2S_NUMLOT)	,.T.,.T.,.T. )
	    cXMLAux += A270Tag( 3,"ans:guiasTISS"	,''							,.T.,.F.,.T. )
	    fWrite( nArqGui,cXMLAux )
		
		DBSelectarea("B5S")
		B5S->(DBSetorder(1)) //B5S_FILIAL+B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO
		If B5S->(MsSeek(xFilial("B5S")+B2S->B2S_NUMLOT))
			while ( B5S->(!eof()) .And. B5S->(B5S_FILIAL+B5S_NUMLOT) == xFilial("B5S")+B2S->B2S_NUMLOT )
				If cTipGuia == B5S->B5S_TIPGUI 
					nGuias++
				EndIf
				B5S->( dbSkip() )
			EndDo
		Else
			//"Nenhum registro de Guia encontrada."
			return ""
		EndIf
		
		If nGuias == 0
			alert( STR0014 + " " + cTipGuia + " " + STR0015 ) //"Nenhum registro de Guia do tipo" # "encontrada."
			return ""
		Else
			ProcRegua( nGuias )
		EndIf
		
		B5S->(DbGoTop())
		
		DBSelectarea("BD5")
		BD5->(DBSetorder(1)) //BD5_FILIAL+BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_SITUAC+BD5_FASE+BD5_DATPRO+BD5_OPERDA+BD5_CODRDA
		DBSelectarea("B6S")
		B6S->(DBSetorder(1)) //B6S_FILIAL+B6S_NUMLOT+B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO+B6S_ORIMOV+B6S_SEQUEN+B6S_CODPAD+B6S_CODPRO
		DBSelectarea("BD6")
		BD6->(DBSetorder(1)) //BD6_FILIAL+BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_SEQUEN+BD6_CODPAD+BD6_CODPRO
		DBSelectarea("BB0")
		BB0->(DBSetorder(4)) //BB0_FILIAL+BB0_ESTADO+BB0_NUMCR+BB0_CODSIG+BB0_CODOPE
		DBSelectarea("BAU")
		BAU->(DBSetorder(1)) //BAU_FILIAL+BAU_CODIGO
		DBSelectarea("BE4")
		BE4->(DBSetorder(1)) //BE4_FILIAL+BE4_CODOPE+BE4_CODLDP+BE4_CODPEG+BE4_NUMERO+BE4_SITUAC+BE4_FASE
		DBSelectarea("BD7")
		BD7->(DBSetorder(2)) //BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO+BD7_CODUNM+BD7_NLANC   
		
		//BA1 |Indice 2| BA1_FILIAL+BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO 
		//BTS |Indice 1| BTS_FILIAL+BTS_MATVID 
		//BAQ |Indice 7| BAQ_FILIAL+BAQ_CODESP
		//BB8 |Indice 1| BB8_FILIAL+BB8_CODIGO+BB8_CODINT+BB8_CODLOC+BB8_LOCAL
		//BTU |Indice 4| BTU_FILIAL+BTU_CODTAB+BTU_VLRSIS+BTU_ALIAS
		
		If cTipGuia == G_SADT_ODON
			
			If B5S->(MsSeek(xFilial("B5S")+B2S->B2S_NUMLOT))
				
				while ( B5S->(!eof()) .And. B5S->(B5S_FILIAL+B5S_NUMLOT) == xFilial("B5S")+B2S->B2S_NUMLOT )
					
					If lEnd
						alert( STR0016 ) //"Execução cancelada pelo usuário."
						exit
					EndIf
					
					If cTipGuia != B5S->B5S_TIPGUI
						B5S->( dbSkip() )
						Loop
					EndIf
					
					cXMLAux := ""
					
					cCGCSol		:= ""
					cCodOriSol	:= ""
					cCodSol		:= ""
					cNomSol		:= ""
					cCGCRDA		:= ""
					cNomRDA		:= ""
					cCNES		:= ""
					
					IncProc( STR0017 ) //"Gerando dados para o arquivo de envio..."
					
					//Posiciona BD5
					If !( BD5->(MsSeek( xFilial("BD5")+B5S->(B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO) )) )
						aAdd(aCritica,{ 	"[" + B2S->B2S_OPEORI + "]" + B2S->B2S_NUMLOT,;
											STR0018,; //"Não encontrado registro de contas correspondente."
											"BD5",;
											"1",;
											xFilial("B5S")+B5S->(B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO) } )
					EndIf
					
					cMatAnt 	:= AllTrim( Posicione("BA1",2,xFilial("BA1")+BD5->(BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO),"BA1_MATANT") )
					cCartei 	:= AllTrim( BD5->(BD5_FILIAL+BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO) )
					cNRCRNA 	:= AllTrim( Posicione("BTS",1,xFilial("BTS")+BD5->BD5_MATVID,"BTS_NRCRNA") )
					cCBOS		:= AllTrim( Posicione("BAQ",7,xFilial("BAQ")+BD5->BD5_CODESP,"BAQ_CBOS") )
					cCNES		:= AllTrim( Posicione("BB8",1,xFilial("BB8")+BD5->(BD5_CODRDA+BD5_CODOPE+BD5_CODLOC),"BB8_CNES") )
					
					//=========== Dados do Solicitante ============
					If BB0->(MsSeek( xFilial("BB0")+BD5->(BD5_ESTSOL+BD5_REGSOL+BD5_SIGLA) ))
						cCGCSol		:= AllTrim(BB0->BB0_CGC)
						cCodOriSol	:= AllTrim(BB0->BB0_CODORI)
						cCodSol		:= AllTrim(BB0->BB0_CODIGO)
						cNomSol		:= AllTrim(BB0->BB0_NOME)
					EndIf
					//=============================================
					
					//=========== Dados do RDA =============
					If BAU->( MsSeek( xFilial("BAU")+BD5->BD5_CODRDA ) ) 
						cCGCRDA		:= AllTrim(BAU->BAU_CPFCGC)
						cNomRDA		:= AllTrim(BAU->BAU_NOME)
						cCNES 		:= AllTrim(BAU->BAU_CNES)
					EndIf
					If Empty(cCNES)
						cCNES := "9999999"
					EndIf
					//======================================
					
					cNumGuia := PLU520RGui(G_SADT_ODON)
					 						
					cCarAtend := AllTrim( PLSGETVINC("BTU_CDTERM", "BDR", .F., "23", BD5->BD5_TIPADM) ) 
					if empty(cCarAtend)
						cCarAtend := "1"
					endif
					
					cXMLAux += A270Tag( 4,"ans:guiaSP-SADT"	 				,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 5,"ans:cabecalhoGuia"				,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:registroANS"	 				,cReAnsOri							 	,.T.,.T.,.F. )
					cXMLAux += A270Tag( 6,"ans:numeroGuiaPrestador"			,cNumGuia								,.T.,.T.,.F. )
					cXMLAux += A270Tag( 5,"ans:cabecalhoGuia"				,''										,.F.,.T.,.T. )
				
					cXMLAux += A270Tag( 5,"ans:dadosBeneficiario"			,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:numeroCarteira"				,allTrim( cMatAnt )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:atendimentoRN"				,IIF(BD5->BD5_ATERNA=="1","S","N")		,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:nomeBeneficiario"			,allTrim( BD5->BD5_NOMUSR )				,.T.,.T.,.T. )
					if !(empty(cNRCRNA)) 
						cXMLAux += A270Tag( 6,"ans:numeroCNS"				,allTrim( cNRCRNA )						,.T.,.T.,.T. ) //Opcional
					endif
					//if !(empty(cCartei))
					//	cXMLAux += A270Tag( 6,"ans:identificadorBeneficiario",allTrim( cCartei )					,.T.,.T.,.F. ) //Opcional
					//endif
					cXMLAux += A270Tag( 5,"ans:dadosBeneficiario"			,''										,.F.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:dadosSolicitante"			,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:contratadoSolicitante"		,''										,.T.,.F.,.T. )
					
					If !(Empty(cCGCSol))
						If Len(AllTrim(cCGCSol)) > 11
							cXMLAux += A270Tag( 7,"ans:cnpjContratado"		,allTrim( cCGCSol )					,.T.,.T.,.T. )
						Else
							cXMLAux += A270Tag( 7,"ans:cpfContratado"		,allTrim( cCGCSol )					,.T.,.T.,.T. )
						EndIf
					Else
						If !(Empty(cCodOriSol))
							cXMLAux += A270Tag( 7,"ans:codigoPrestadorNaOperadora",allTrim( cCodOriSol )		,.T.,.T.,.T. )
						Else
							cXMLAux += A270Tag( 7,"ans:codigoPrestadorNaOperadora",allTrim( cCodSol )			,.T.,.T.,.T. )
						EndIf
					EndIf
					cXMLAux += A270Tag( 7,"ans:nomeContratado"				,allTrim( cNomSol )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:contratadoSolicitante"		,''										,.F.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:profissionalSolicitante"		,''										,.T.,.F.,.T. )
					If !(Empty(BD5->BD5_NOMSOL))
						cXMLAux += A270Tag( 7,"ans:nomeProfissional"		,allTrim( BD5->BD5_NOMSOL )				,.T.,.T.,.T. ) //Opcional
					EndIf
					cXMLAux += A270Tag( 7,"ans:conselhoProfissional"		,AllTrim( PLSGETVINC("BTU_CDTERM", "BAH", .F., "26", BD5->BD5_SIGLA) )	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 7,"ans:numeroConselhoProfissional"	,allTrim( BD5->BD5_REGSOL )				,.T.,.T.,.T. )
					cXMLAux += A270Tag( 7,"ans:UF"							,AllTrim( PLSGETVINC("BTU_CDTERM", "   ", .F., "59", BD5->BD5_ESTSOL) )	,.T.,.T.,.T. ) //allTrim( BD5->BD5_ESTSOL )
					
					cXMLAux += A270Tag( 7,"ans:CBOS"						,Iif(Empty(cCBOS),"999999",allTrim(cCBOS)),.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:profissionalSolicitante"		,''										,.F.,.T.,.T. )
					cXMLAux += A270Tag( 5,"ans:dadosSolicitante"			,''										,.F.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:dadosSolicitacao"			,''										,.T.,.F.,.T. )
					If !(Empty(BD5->BD5_DATSOL))
						cXMLAux += A270Tag( 6,"ans:dataSolicitacao"			,convDataXML( BD5->BD5_DATSOL )			,.T.,.T.,.T. ) //Opcional
					EndIf
					cXMLAux += A270Tag( 6,"ans:caraterAtendimento"			,cCarAtend								,.T.,.T.,.T. )
					If !(Empty(BD5->(BD5_INDCLI+BD5_INDCL2)))
						cXMLAux += A270Tag( 6,"ans:indicacaoClinica"		,allTrim( BD5->(BD5_INDCLI+BD5_INDCL2) ),.T.,.T.,.T. ) //Opcional
					EndIf
					cXMLAux += A270Tag( 5,"ans:dadosSolicitacao"			,''										,.F.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:dadosExecutante"				,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:contratadoExecutante"		,''										,.T.,.F.,.T. )
					
					If !(Empty(cCGCRDA))
						If Len(AllTrim(cCGCRDA)) > 11
							cXMLAux += A270Tag( 7,"ans:cnpjContratado"	,allTrim( cCGCRDA )						,.T.,.T.,.T. )
						Else
							cXMLAux += A270Tag( 7,"ans:cpfContratado"	,allTrim( cCGCRDA )						,.T.,.T.,.T. )
						EndIf
					Else
						cXMLAux += A270Tag( 7,"ans:codigoPrestadorNaOperadora"	,allTrim( BD5->BD5_CODRDA )			,.T.,.T.,.T. )
					EndIf
					cXMLAux += A270Tag( 7,"ans:nomeContratado"				,allTrim( cNomRDA )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:contratadoExecutante"		,''										,.F.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:CNES"						,allTrim( cCNES )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 5,"ans:dadosExecutante"				,''										,.F.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:dadosAtendimento"			,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:tipoAtendimento"				,allTrim( Iif(Empty(BD5->BD5_TIPATE),"13",allTrim(BD5->BD5_TIPATE)) )				,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:indicacaoAcidente"			,IIF(Empty(BD5->BD5_INDACI),"9",AllTrim(BD5->BD5_INDACI)),.T.,.T.,.T. )
					//cXMLAux += A270Tag( 6,"ans:tipoConsulta"				,Iif(Empty(BD5->BD5_TIPCON),"1",allTrim(BD5->BD5_TIPCON)),.T.,.T.,.T. ) //Opcional
					//cXMLAux += A270Tag( 6,"ans:motivoEncerramento"		,allTrim(  )							,.T.,.T.,.T. ) //Opcional
					cXMLAux += A270Tag( 5,"ans:dadosAtendimento"			,''										,.F.,.T.,.T. )
					
					fWrite( nArqGui,cXMLAux )
					cXMLAux := ""
					
					//=============================== TAG - procedimentosExecutados é OPCIONAL ===================================
					If B6S->(MsSeek(xFilial("B6S")+B5S->(B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO)))
						
						cXMLAux += A270Tag( 5,"ans:procedimentosExecutados"		,''										,.T.,.F.,.T. )
						
						While ( B6S->(!eof()) .And. B6S->(B6S_FILIAL+B6S_NUMLOT+B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO) ==;
													 xFilial("B6S")+B5S->(B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO) )
							
							//Posiciona BD6
							If !( BD6->(MsSeek( xFilial("BD6")+B6S->(B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO+B6S_ORIMOV+B6S_SEQUEN+B6S_CODPAD+B6S_CODPRO) )) )
								aAdd(aCritica,{ 	"[" + B2S->B2S_OPEORI + "]" + B2S->B2S_NUMLOT,;
													STR0019,; //"Não encontrado registro de procedimentos correspondente."
													"BD6",;
													"1",;
													xFilial("BD6")+B6S->(B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO+B6S_ORIMOV+B6S_SEQUEN+B6S_CODPAD+B6S_CODPRO) } )
							EndIf
	
							cXMLAux += A270Tag( 6,"ans:procedimentoExecutado"	, ''									,.T.,.F.,.T. )
							cXMLAux += A270Tag( 7,"ans:sequencialItem"			,PGetSeqTISS()							,.T.,.T.,.F. )
							cXMLAux += A270Tag( 7,"ans:dataExecucao"			,convDataXML(BD6->BD6_DATPRO)			,.T.,.T.,.F. )
							If  !Empty(BD6->BD6_HORPRO)
								cHrIniF	:= FormatHora(BD6->BD6_HORPRO)
								cXMLAux += A270Tag( 7,"ans:horaInicial"         ,cHrIniF								,.T.,.T.,.T.,.F. ) //Opcional
							EndIf
							If  !Empty(BD6->BD6_HORFIM)
								cHrFimF	:= FormatHora(BD6->BD6_HORFIM)
								cXMLAux += A270Tag( 7,"ans:horaFinal"       	,cHrFimF								,.T.,.T.,.T.,.F. )//Opcional	
							EndIf
							cXMLAux += A270Tag( 7,"ans:procedimento"			,''										,.T.,.F.,.T. )
							aProced	:= PLGETPROC(Alltrim(BD6->BD6_CODPAD),Alltrim(BD6->BD6_CODPRO))
							cCodPad := aProced[2]
							cCodPro := aProced[3]
							cDescri := PLSIMPVINC("BR8",cCodPad	,	BD6->BD6_CODPAD+BD6->BD6_CODPRO	,.T.)
							BR8->(dbSetOrder(1))
							if BR8->(msSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO)))
								if Empty(cDescri)
									cDescri := alltrim(BR8->BR8_DESCRI)
								endIf
								if !empty(BR8->BR8_CODEDI)
									cCodPro := alltrim(BR8->BR8_CODEDI)
								endIf
							endif
							cDescri := substr(cDescri,1,150)
							cXMLAux += A270Tag( 8,"ans:codigoTabela"			,cCodPad			   					,.T.,.T.,.T. )
							cXMLAux += A270Tag( 8,"ans:codigoProcedimento"		,cCodPro			   					,.T.,.T.,.T. )
							cXMLAux += A270Tag( 8,"ans:descricaoProcedimento"	,allTrim( cDescri )						,.T.,.T.,.T. )
							cXMLAux += A270Tag( 7,"ans:procedimento"			,''										,.F.,.T.,.T. )
							nQtdPro	:= round(B6S->B6S_QTDPRO,2)
							nValPro	:= B6S->B6S_VLRPRO/nQtdPro
							nValPro := round(nValPro,2)
							cXMLAux += A270Tag( 7,"ans:quantidadeExecutada"		,allTrim(str(nQtdPro))					,.T.,.T.,.T. )
							cViaTis := AllTrim(Posicione("BGR",1,xFilial("BGR")+BD6->(BD6_CODOPE+BD6_VIA),"BGR_VIATIS"))
							 
							cVincBkp := P520VINC('61', 'BGR', cViaTis)
							//PLSVARVINC('61', 'BGR', cViaTis) // Vinculo Terminologia de Via de Acesso Tabela 61 TISS
							If !Empty(cVincBkp)
								cViaTis := cVincBkp
							EndIf
							If !Empty(cViaTis)
								cXMLAux += A270Tag( 7,"ans:viaAcesso"			,alltrim( cViaTis )						,.T.,.T.,.T. )//Opcional
							EndIf
							If !Empty(BD6->BD6_TECUTI)
								cXMLAux += A270Tag( 7,"ans:tecnicaUtilizada"	,alltrim( BD6->BD6_TECUTI )				,.T.,.T.,.T. )//Opcional
							EndIf
							cXMLAux += A270Tag( 7,"ans:reducaoAcrescimo"		,"1"									,.T.,.T.,.T. )
							cXMLAux += A270Tag( 7,"ans:valorUnitario"			,allTrim(str(nValPro))					,.T.,.T.,.T.,.F. )
							cXMLAux += A270Tag( 7,"ans:valorTotal"				,allTrim(str(round(B6S->B6S_VLRPRO,2)))	,.T.,.T.,.T.,.F. )
							
							/*=================== TAG - equipeSadt - ZERO OU MAIS REPETIÇÕES =====================
								cXMLAux += A270Tag( 7,"ans:equipeSadt"				  ,''			,.T.,.F.,.T. )
								cXMLAux += A270Tag( 8,"ans:grauPart"				  ,allTrim(  )	,.T.,.T.,.T. )
								cXMLAux += A270Tag( 8,"ans:codProfissional"			  ,''			,.T.,.F.,.T. )
								cXMLAux += A270Tag( 9,"ans:codigoPrestadorNaOperadora",allTrim(  )	,.T.,.T.,.T. )
								cXMLAux += A270Tag( 8,"ans:codProfissional"			  ,''			,.F.,.T.,.T. )
								cXMLAux += A270Tag( 8,"ans:nomeProf"				  ,allTrim(  )	,.T.,.T.,.T. )
								cXMLAux += A270Tag( 8,"ans:conselho"				  ,allTrim(  )	,.T.,.T.,.T. )
								cXMLAux += A270Tag( 8,"ans:numeroConselhoProfissional",allTrim(  )	,.T.,.T.,.T. )
								cXMLAux += A270Tag( 8,"ans:UF"						  ,allTrim(  )	,.T.,.T.,.T. )
								cXMLAux += A270Tag( 8,"ans:CBOS"					  ,allTrim(  )	,.T.,.T.,.T. )
								cXMLAux += A270Tag( 7,"ans:equipeSadt"				  ,''			,.F.,.T.,.T. )
							//==================================================================================*/
							
							If ( BD7->(MsSeek( xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO) )) )
														  
								While BD7->(!eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO) ==;
														 xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)
									
									cCGCExe		:= ""
									cCodOriExe	:= ""
									cCodExe		:= ""
									cNomExe		:= ""
									cREGPRE		:= ""
									
									If BB0->(MsSeek( xFilial("BB0")+BD7->(BD7_ESTPRE+BD7_REGPRE+BD7_SIGLA) ))
										cCGCExe		:= BB0->BB0_CGC
										cCodOriExe	:= BB0->BB0_CODORI
										cCodExe		:= BB0->BB0_CODIGO
										cNomExe		:= BB0->BB0_NOME
										cREGPRE		:= BD7->BD7_REGPRE
									EndIf
									
									If Empty(cCNES)
										cCNES := "9999999"
									EndIf
									
									cCBOS := AllTrim( Posicione("BAQ",7,xFilial("BAQ")+BD7->BD7_ESPEXE,"BAQ_CBOS") )
									If Empty(cCBOS)
										cCBOS := AllTrim( Posicione("BAQ",7,xFilial("BAQ")+BD7->BD7_CODESP,"BAQ_CBOS") )
									EndIf
									
									cGrauPart := cGrauPa	:= ""
									If !Empty(BD7->BD7_CODTPA)
										cGrauPart := PLSGETVINC("BTU_CDTERM", "BWT", .F., "35", BD7->BD7_CODTPA)
									Else
										cGrauPa := PLSGrauUM(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD7->BD7_CODUNM,BD6->BD6_DATPRO,"2")[2]
										cGrauPart := PLSGETVINC("BTU_CDTERM", "BWT", .F., "35", cGrauPa)
									EndIf  
									
									If ( !Empty(cCGCExe) .Or. !Empty(cCodOriExe) .Or. !Empty(cCodExe) ) .And.;
										 !Empty(cNomExe) .And. !Empty(cREGPRE)
														 
										cXMLAux += A270Tag( 7,"ans:equipeSadt"					,''									,.T.,.F.,.T. )
										cXMLAux += A270Tag( 8,"ans:grauPart"					,allTrim( cGrauPart )				,.T.,.T.,.f. )
										cXMLAux += A270Tag( 8,"ans:codProfissional"				,''									,.T.,.F.,.T. )
										If !(Empty(cCGCExe))
											cXMLAux += A270Tag( 9,"ans:cpfContratado"			,allTrim( cCGCExe )				,.T.,.T.,.T. )
										Else
											If !(Empty(cCodOriExe))
												cXMLAux += A270Tag( 9,"ans:codigoPrestadorNaOperadora"	,allTrim( cCodOriExe )		,.T.,.T.,.T. )
											Else
												cXMLAux += A270Tag( 9,"ans:codigoPrestadorNaOperadora"	,allTrim( cCodExe )			,.T.,.T.,.T. )
											EndIf
										EndIf
										cXMLAux += A270Tag( 8,"ans:codProfissional"				,''									,.F.,.T.,.T. )
										cXMLAux += A270Tag( 8,"ans:nomeProf"					,allTrim( cNomExe )					,.T.,.T.,.T. )
										cXMLAux += A270Tag( 8,"ans:conselho"					,AllTrim( PLSGETVINC("BTU_CDTERM", "BAH", .F., "26", BD7->BD7_SIGLA) )	,.T.,.T.,.T. )
										cXMLAux += A270Tag( 8,"ans:numeroConselhoProfissional"	,allTrim( cREGPRE )					,.T.,.T.,.T. )
										cXMLAux += A270Tag( 8,"ans:UF"							,AllTrim( PLSGETVINC("BTU_CDTERM", "   ", .F., "59", BD7->BD7_ESTPRE) )	,.T.,.T.,.T. )
										cXMLAux += A270Tag( 8,"ans:CBOS"						,Iif(Empty(cCBOS),"999999",allTrim(cCBOS)),.T.,.T.,.T. )
										cXMLAux += A270Tag( 7,"ans:equipeSadt"					,''									,.F.,.T.,.T. )
									
									EndIf
									
									BD7->( dbSkip() )
								EndDo
								
							EndIf

							cXMLAux += A270Tag( 6,"ans:procedimentoExecutado"	, ''									,.F.,.T.,.T. )
							
							B6S->( dbSkip() )
						EndDo
						cXMLAux += A270Tag( 5,"ans:procedimentosExecutados"		,''										,.F.,.T.,.T. )
					EndIf
					//====================================================================================================================

					//cXMLAux += A270Tag( 5,"ans:observacao"					,allTrim(  )								,.T.,.T.,.T. ) //Opcional
					
					cXMLAux += A270Tag( 5,"ans:valorTotal"					,''												,.T.,.F.,.T.,.F. )
					/*========================================= TAGs de valores Opicionais ===============================================
					cXMLAux += A270Tag( 6,"ans:valorProcedimentos"			,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:valorDiarias"				,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:valorTaxasAlugueis"			,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:valorMateriais"				,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:valorMedicamentos"			,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:valorOPME"					,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:valorGasesMedicinais"		,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					=====================================================================================================================*/
					cXMLAux += A270Tag( 6,"ans:valorTotalGeral"				,allTrim(str(round(B5S->B5S_VLRPRO,2)))		,.T.,.T.,.T.,.F. )
					cXMLAux += A270Tag( 5,"ans:valorTotal"					,''											,.F.,.T.,.T.,.F. )
					
					cXMLAux += A270Tag( 4,"ans:guiaSP-SADT"	 				,''											,.F.,.T.,.T. )
					
					fWrite( nArqGui,cXMLAux )
					cXMLAux := ""
					
					aCampos	:= {}
					aAdd( aCampos,{ "B5S_NUMGUI"	,cNumGuia	} )
					lRet := PLU520Grv( 4, aCampos, 'MODEL_B5S', 'PLSU520B5S' )
					
					B5S->( dbSkip() )
					
				EndDo
	
			EndIf//If B5S->(MsSeek(xFilial("B5S")+B2S->B2S_NUMLOT))
		
		ElseIf cTipGuia == G_RES_INTER
		
			If B5S->(MsSeek(xFilial("B5S")+B2S->B2S_NUMLOT))
				
				while ( B5S->(!eof()) .And. B5S->(B5S_FILIAL+B5S_NUMLOT) == xFilial("B5S")+B2S->B2S_NUMLOT )
					
					If lEnd
						alert( 'Execução cancelada pelo usuário.' )
						exit
					EndIf
					
					If cTipGuia != B5S->B5S_TIPGUI
						B5S->( dbSkip() )
						Loop
					EndIf
					
					cXMLAux := ""
					
					cCGCRDA		:= ""
					cNomRDA		:= ""
					cCNES		:= ""
					
					IncProc( STR0017 ) //"Gerando dados para o arquivo de envio..."
					
					//Posiciona BE4
					If !( BE4->(MsSeek( xFilial("BE4")+B5S->(B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO) )) )
						aAdd(aCritica,{ 	"[" + B2S->B2S_OPEORI + "]" + B2S->B2S_NUMLOT,;
											STR0020,; //"Não encontrado registro de internação correspondente."
											"BE4",;
											"1",;
											xFilial("BE4")+B5S->(B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO) } )
					EndIf
					
					cMatAnt 	:= AllTrim( Posicione("BA1",2,xFilial("BA1")+BE4->(BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO),"BA1_MATANT") )
					cCartei 	:= AllTrim( BE4->(BE4_FILIAL+BE4_CODOPE+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG+BE4_DIGITO) )
					cNRCRNA 	:= AllTrim( Posicione("BTS",1,xFilial("BTS")+BE4->BE4_MATVID,"BTS_NRCRNA") )
					cCBOS		:= AllTrim( Posicione("BAQ",7,xFilial("BAQ")+BE4->BE4_CODESP,"BAQ_CBOS") )
					cCNES		:= AllTrim( Posicione("BB8",1,xFilial("BB8")+BE4->(BE4_CODRDA+BE4_CODOPE+BE4_CODLOC),"BB8_CNES") )
					
					//=========== Dados da RDA =============
					If BAU->( MsSeek( xFilial("BAU")+BE4->BE4_CODRDA ) )
						cCGCRDA		:= AllTrim(BAU->BAU_CPFCGC)
						cNomRDA		:= AllTrim(BAU->BAU_NOME)
						cCNES 		:= AllTrim(BAU->BAU_CNES)
					EndIf
					If Empty(cCNES)
						cCNES := "9999999"
					EndIf
					//======================================
					
					cCarAtend := AllTrim( PLSGETVINC("BTU_CDTERM", "BDR", .F., "23", BE4->BE4_TIPADM) )
					if empty(cCarAtend)
						cCarAtend := "1"
					endif
					cNumGuia := PLU520RGui(G_RES_INTER)
					
					cGuiaPres  := Padr(BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),20)
					If LEN( AllTrim(cGuiaPres) ) < 20
						cGuiaPres  := cNumGuia
					EndIf
					
					cXMLAux += A270Tag( 4,"ans:guiaResumoInternacao"		,''										,.T.,.F.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:cabecalhoGuia"				,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:registroANS"	 				,cReAnsOri					 			,.T.,.T.,.F. )
					cXMLAux += A270Tag( 6,"ans:numeroGuiaPrestador"			,cNumGuia								,.T.,.T.,.F. )
					cXMLAux += A270Tag( 5,"ans:cabecalhoGuia"				,''										,.F.,.T.,.T. )
					//cGuiaInt := BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT)
					cXMLAux += A270Tag( 5,"ans:numeroGuiaSolicitacaoInternacao"	,allTrim( cGuiaPres )				,.T.,.T.,.F. )
					
					cXMLAux += A270Tag( 5,"ans:dadosAutorizacao"			,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:numeroGuiaOperadora"			,allTrim( BE4->(BE4_CODLDP+BE4_CODPEG+BE4_NUMERO) ),.T.,.T.,.F. ) //Opcional
					cXMLAux += A270Tag( 6,"ans:dataAutorizacao"				,convDataXML( BE4->BE4_DTDIGI )			,.T.,.T.,.F. )
					cXMLAux += A270Tag( 6,"ans:senha"						,allTrim( BE4->BE4_SENHA )				,.T.,.T.,.F. )
					//cXMLAux += A270Tag( 6,"ans:dataValidadeSenha"			,allTrim( VERIFICAR )					,.T.,.T.,.F. ) //Opcional
					cXMLAux += A270Tag( 5,"ans:dadosAutorizacao"			,''										,.F.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:dadosBeneficiario"			,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:numeroCarteira"				,allTrim( cMatAnt )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:atendimentoRN"				,IIF(BE4->BE4_ATERNA=="1","S","N")		,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:nomeBeneficiario"			,allTrim( BE4->BE4_NOMUSR )				,.T.,.T.,.T. )
					if !(empty(cNRCRNA)) 
						cXMLAux += A270Tag( 6,"ans:numeroCNS"				,allTrim( cNRCRNA )						,.T.,.T.,.T. ) //Opcional
					endif
					//if !(empty(cCartei))
					//	cXMLAux += A270Tag( 6,"ans:identificadorBeneficiario",allTrim( cCartei )					,.T.,.T.,.F. ) //Opcional
					//endif
					cXMLAux += A270Tag( 5,"ans:dadosBeneficiario"			,''										,.F.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:dadosExecutante"				,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:contratadoExecutante"		,''										,.T.,.F.,.T. )
					If !(Empty(cCGCRDA))
						If Len(cCGCRDA) > 11
							cXMLAux += A270Tag( 7,"ans:cnpjContratado"	,allTrim( cCGCRDA )						,.T.,.T.,.T. )
						Else
							cXMLAux += A270Tag( 7,"ans:cpfContratado"	,allTrim( cCGCRDA )						,.T.,.T.,.T. )
						EndIf
					Else
						cXMLAux += A270Tag( 7,"ans:codigoPrestadorNaOperadora"	,allTrim( BE4->BE4_CODRDA )			,.T.,.T.,.T. )
					EndIf
					cXMLAux += A270Tag( 7,"ans:nomeContratado"				,allTrim( cNomRDA )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:contratadoExecutante"		,''										,.F.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:CNES"						,allTrim( cCNES )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 5,"ans:dadosExecutante"				,''										,.F.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:dadosInternacao"				,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:caraterAtendimento"			,allTrim( cCarAtend )					,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:tipoFaturamento"				,IIF( BE4->BE4_TIPFAT="P","2","1" )		,.T.,.T.,.T. )
					dDtIniF	:= Iif( Empty(BE4->BE4_DTINIF), BE4->BE4_DATPRO, BE4->BE4_DTINIF )
					dDtFimF	:= Iif( Empty(BE4->BE4_DTFIMF), BE4->BE4_DTALTA, BE4->BE4_DTFIMF )
					
					If !Empty(BE4->BE4_HRINIF)
						cHrIniF	:= BE4->BE4_HRINIF
					Else
						cHrIniF	:= BE4->BE4_HORPRO
					EndIf
					cHrIniF	:= FormatHora(cHrIniF)
					
					If !Empty(BE4->BE4_HRFIMF)
						cHrFimF	:= BE4->BE4_HRFIMF
					Else
						cHrFimF	:= BE4->BE4_HRALTA
					EndIf
					cHrFimF	:= FormatHora(cHrFimF)
					
					cXMLAux += A270Tag( 6,"ans:dataInicioFaturamento"		,convDataXML( dDtIniF )		  			,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:horaInicioFaturamento"		,cHrIniF								,.T.,.T.,.T.,.F. )
					cXMLAux += A270Tag( 6,"ans:dataFinalFaturamento"		,convDataXML( dDtFimF )	 				,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:horaFinalFaturamento"		,cHrFimF								,.T.,.T.,.T.,.F. )
					cXMLAux += A270Tag( 6,"ans:tipoInternacao"				,allTrim( BE4->BE4_GRPINT )				,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:regimeInternacao"			,allTrim( BE4->BE4_REGINT )				,.T.,.T.,.T. )
					If !Empty(BE4->BE4_NRDCNV) .Or. !Empty(BE4->BE4_NRDCOB)
						//========================================= DECLARAÇÕES - OPCIONAL ======================================
						cXMLAux += A270Tag( 6,"ans:declaracoes"				,''											,.T.,.F.,.T. )
						If !Empty(BE4->BE4_NRDCNV)
							cXMLAux += A270Tag( 7,"ans:declaracaoNascido"	,allTrim( BE4->BE4_NRDCNV ) 				,.T.,.T.,.F. )
						EndIf
						//cXMLAux += A270Tag( 7,"ans:diagnosticoObito"		,allTrim( BE4_CIDOBT )						,.T.,.T.,.F. )
						If !Empty(BE4->BE4_NRDCOB)
							cXMLAux += A270Tag( 7,"ans:declaracaoObito"		,allTrim( BE4->BE4_NRDCOB )					,.T.,.T.,.F. )
						EndIf
						//cXMLAux += A270Tag( 7,"ans:indicadorDORN"			,allTrim( VERIFICAR )						,.T.,.T.,.F. )
						cXMLAux += A270Tag( 6,"ans:declaracoes"				,''											,.F.,.T.,.T. )
						//=======================================================================================================
					EndIf
					cXMLAux += A270Tag( 5,"ans:dadosInternacao"				,''										,.F.,.T.,.T. )
					//=================================== DADOS DE SAÍDA INTERNAÇÃO - OPCIONAL ===================================
					cXMLAux += A270Tag( 5,"ans:dadosSaidaInternacao"		,''										,.T.,.F.,.T. )
						cXMLAux += A270Tag( 6,"ans:diagnostico"				,allTrim( BE4->BE4_CID    )				,.T.,.T.,.T. )
						cXMLAux += A270Tag( 6,"ans:indicadorAcidente"		,IIF(Empty(BE4->BE4_INDACI),"9",AllTrim(BE4->BE4_INDACI)),.T.,.T.,.T. )
						cXMLAux += A270Tag( 6,"ans:motivoEncerramento"		,allTrim( BE4->BE4_TIPALT ) 			,.T.,.T.,.T. )
					cXMLAux += A270Tag( 5,"ans:dadosSaidaInternacao"		,''										,.F.,.T.,.T. )
					//=============================================================================================================
					
					fWrite( nArqGui,cXMLAux )
					cXMLAux := ""
					
					//=============================== TAG - procedimentosExecutados é OPCIONAL ===================================
					If B6S->(MsSeek(xFilial("B6S")+B5S->(B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO)))
						
						cXMLAux += A270Tag( 5,"ans:procedimentosExecutados"		,''										,.T.,.F.,.T. )
						
						While ( B6S->(!eof()) .And. B6S->(B6S_FILIAL+B6S_NUMLOT+B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO) ==;
													 xFilial("B6S")+B5S->(B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO) )
							
							//Posiciona BD6
							If !( BD6->(MsSeek( xFilial("BD6")+B6S->(B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO+B6S_ORIMOV+B6S_SEQUEN+B6S_CODPAD+B6S_CODPRO) )) )
								aAdd(aCritica,{ 	"[" + B2S->B2S_OPEORI + "]" + B2S->B2S_NUMLOT,;
													STR0019,; //"Não encontrado registro de procedimentos correspondente."
													"BD6",;
													"1",;
													xFilial("BD6")+B6S->(B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO+B6S_ORIMOV+B6S_SEQUEN+B6S_CODPAD+B6S_CODPRO) } )
							EndIf
	
							cXMLAux += A270Tag( 6,"ans:procedimentoExecutado"	, ''									,.T.,.F.,.T. )
							cXMLAux += A270Tag( 7,"ans:sequencialItem"			,PGetSeqTISS()							,.T.,.T.,.F. )
							cXMLAux += A270Tag( 7,"ans:dataExecucao"			,convDataXML(BD6->BD6_DATPRO)			,.T.,.T.,.F. )							
							If  !Empty(BD6->BD6_HORPRO)
								cHrIniF	:= FormatHora(BD6->BD6_HORPRO)
								cXMLAux += A270Tag( 7,"ans:horaInicial"			,cHrIniF,.T.,.T.,.T.,.F. )//Opcional
							EndIf
							
							If  !Empty(BD6->BD6_HORFIM)
								cHrFimF	:= FormatHora(BD6->BD6_HORFIM)
								cXMLAux += A270Tag( 7,"ans:horaFinal"			,cHrFimF,.T.,.T.,.T.,.F. )//Opcional
							EndIf
							
							cXMLAux += A270Tag( 7,"ans:procedimento"			,''										,.T.,.F.,.T. )
							aProced	:= PLGETPROC(Alltrim(BD6->BD6_CODPAD),Alltrim(BD6->BD6_CODPRO))
							cCodPad := aProced[2]
							cCodPro := aProced[3]
							cDescri := PLSIMPVINC("BR8",cCodPad	,	BD6->BD6_CODPAD+BD6->BD6_CODPRO	,.T.)
							BR8->(dbSetOrder(1))
							if BR8->(msSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO)))
								if Empty(cDescri)
									cDescri := alltrim(BR8->BR8_DESCRI)
								endIf
								if !empty(BR8->BR8_CODEDI)
									cCodPro := alltrim(BR8->BR8_CODEDI)
								endIf
							endif							
							cDescri := substr(cDescri,1,150)
							cXMLAux += A270Tag( 8,"ans:codigoTabela"			,allTrim( cCodPad )			 			,.T.,.T.,.T. )
							cXMLAux += A270Tag( 8,"ans:codigoProcedimento"		,allTrim( cCodPro )						,.T.,.T.,.T. )
							cXMLAux += A270Tag( 8,"ans:descricaoProcedimento"	,allTrim( cDescri )		  				,.T.,.T.,.T. )
							cXMLAux += A270Tag( 7,"ans:procedimento"			,''										,.F.,.T.,.T. )
							nQtdPro	:= round(B6S->B6S_QTDPRO,2)
							nValPro	:= B6S->B6S_VLRPRO/nQtdPro
							nValPro := round(nValPro,2)
							cXMLAux += A270Tag( 7,"ans:quantidadeExecutada"		,allTrim(str(nQtdPro))					,.T.,.T.,.T. )
							cViaTis := AllTrim(Posicione("BGR",1,xFilial("BGR")+BD6->(BD6_CODOPE+BD6_VIA),"BGR_VIATIS"))
							cVincBkp := P520VINC('61', 'BGR', cViaTis)
							//PLSVARVINC('61', 'BGR', cViaTis) // Vinculo Terminologia de Via de Acesso Tabela 61 TISS
							If !Empty(cVincBkp)
								cViaTis := cVincBkp
							EndIf
							If !Empty(cViaTis)
								cXMLAux += A270Tag( 7,"ans:viaAcesso"			,alltrim( cViaTis )						,.T.,.T.,.T. )//Opcional
							EndIf
							If !Empty(BD6->BD6_TECUTI)
								cXMLAux += A270Tag( 7,"ans:tecnicaUtilizada"	,alltrim( BD6->BD6_TECUTI )				,.T.,.T.,.T. )//Opcional
							EndIf
							cXMLAux += A270Tag( 7,"ans:reducaoAcrescimo"		,"1"									,.T.,.T.,.T. )
							cXMLAux += A270Tag( 7,"ans:valorUnitario"			,allTrim(str(nValPro))					,.T.,.T.,.T.,.F. )
							cXMLAux += A270Tag( 7,"ans:valorTotal"				,allTrim(str(round(B6S->B6S_VLRPRO,2)))	,.T.,.T.,.T.,.F. )
							
							If ( BD7->(MsSeek( xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO) )) )
														  
								While BD7->(!eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO) ==;
														 xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)
									
									cCGCExe		:= ""
									cCodOriExe	:= ""
									cCodExe		:= ""
									cNomExe		:= ""
									cREGPRE		:= ""
									
									If BB0->(MsSeek( xFilial("BB0")+BD7->(BD7_ESTPRE+BD7_REGPRE+BD7_SIGLA) ))
										cCGCExe		:= BB0->BB0_CGC
										cCodOriExe	:= BB0->BB0_CODORI
										cCodExe		:= BB0->BB0_CODIGO
										cNomExe		:= BB0->BB0_NOME
										cREGPRE		:= BD7->BD7_REGPRE
									EndIf
									
									If Empty(cCNES)
										cCNES := "9999999"
									EndIf
									
									cCBOS := AllTrim( Posicione("BAQ",7,xFilial("BAQ")+BD7->BD7_ESPEXE,"BAQ_CBOS") )
									If Empty(cCBOS)
										cCBOS := AllTrim( Posicione("BAQ",7,xFilial("BAQ")+BD7->BD7_CODESP,"BAQ_CBOS") )
									EndIf
									
									cGrauPart := cGrauPa	:= ""
									If !Empty(BD7->BD7_CODTPA)
										cGrauPart := PLSGETVINC("BTU_CDTERM", "BWT", .F., "35", BD7->BD7_CODTPA)
									Else
										cGrauPa := PLSGrauUM(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD7->BD7_CODUNM,BD6->BD6_DATPRO,"2")[2]
										cGrauPart := PLSGETVINC("BTU_CDTERM", "BWT", .F., "35", cGrauPa)
									EndIf 
									
									If Empty(cGrauPart)
										aAdd(aCritica,{	"[" + B2S->B2S_OPEORI + "]" + B2S->B2S_NUMLOT,;
														STR0021,; //"Não encontrado registro de Participação na tabela TISSxProtheus (De/Para)."
														"BD7",;
														"1",;
														xFilial("BD7")+BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC) } )
									EndIf
									
									If ( !Empty(cCGCExe) .Or. !Empty(cCodOriExe) .Or. !Empty(cCodExe) ) .And.;
										 !Empty(cNomExe) .And. !Empty(cREGPRE) .And. !Empty(cGrauPart)
														 
										cXMLAux += A270Tag( 7,"ans:identEquipe"					,''									,.T.,.F.,.T. )
										cXMLAux += A270Tag( 8,"ans:identificacaoEquipe"			,''									,.T.,.F.,.T. )
										cXMLAux += A270Tag( 9,"ans:grauPart"					,allTrim( cGrauPart )				,.T.,.T.,.F. )
										cXMLAux += A270Tag( 9,"ans:codProfissional"				,''									,.T.,.F.,.T. )
										If !(Empty(cCGCExe))
											cXMLAux += A270Tag( 10,"ans:cpfContratado"			,allTrim( cCGCExe )				,.T.,.T.,.T. )
										Else
											If !(Empty(cCodOriExe))
												cXMLAux += A270Tag( 10,"ans:codigoPrestadorNaOperadora"	,allTrim( cCodOriExe )		,.T.,.T.,.T. )
											Else
												cXMLAux += A270Tag( 10,"ans:codigoPrestadorNaOperadora"	,allTrim( cCodExe )			,.T.,.T.,.T. )
											EndIf
										EndIf
										cXMLAux += A270Tag( 9,"ans:codProfissional"				,''									,.F.,.T.,.T. )
										cXMLAux += A270Tag( 9,"ans:nomeProf"					,allTrim( cNomExe )					,.T.,.T.,.T. )
										cXMLAux += A270Tag( 9,"ans:conselho"					,AllTrim( PLSGETVINC("BTU_CDTERM", "BAH", .F., "26", BD7->BD7_SIGLA) )	,.T.,.T.,.T. )
										cXMLAux += A270Tag( 9,"ans:numeroConselhoProfissional"	,allTrim( cREGPRE )					,.T.,.T.,.T. )
										cXMLAux += A270Tag( 9,"ans:UF"							,AllTrim( PLSGETVINC("BTU_CDTERM", "   ", .F., "59", BD7->BD7_ESTPRE) )	,.T.,.T.,.T. )
										cXMLAux += A270Tag( 9,"ans:CBOS"						,Iif(Empty(cCBOS),"999999",allTrim(cCBOS)),.T.,.T.,.T. )
										cXMLAux += A270Tag( 8,"ans:identificacaoEquipe"			,''									,.F.,.T.,.T. )
										cXMLAux += A270Tag( 7,"ans:identEquipe"					,''									,.F.,.T.,.T. )
									
									EndIf
									
									BD7->( dbSkip() )
								EndDo
								
							EndIf
							
							cXMLAux += A270Tag( 6,"ans:procedimentoExecutado"	, ''									,.F.,.T.,.T. )
							
							B6S->( dbSkip() )
						EndDo
						cXMLAux += A270Tag( 5,"ans:procedimentosExecutados"		,''										,.F.,.T.,.T. )
					EndIf

					cXMLAux += A270Tag( 5,"ans:valorTotal"					,''											,.T.,.F.,.T.,.F. )
					/*========================================= TAGs de valores Opicionais ===============================================
					cXMLAux += A270Tag( 6,"ans:valorProcedimentos"			,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:valorDiarias"				,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:valorTaxasAlugueis"			,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:valorMateriais"				,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:valorMedicamentos"			,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:valorOPME"					,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:valorGasesMedicinais"		,allTrim(str(round((cAlias)->(VERIFICAR),2)))	,.T.,.T.,.T. )
					=====================================================================================================================*/
					cXMLAux += A270Tag( 6,"ans:valorTotalGeral"				,allTrim(str(round(B5S->B5S_VLRPRO,2)))	,.T.,.T.,.T.,.F. )
					cXMLAux += A270Tag( 5,"ans:valorTotal"					,''											,.F.,.T.,.T.,.F. )
					
					//cXMLAux += A270Tag( 5,"ans:observacao"				,allTrim( )									,.T.,.T.,.T. )//Opcional
					
					cXMLAux += A270Tag( 4,"ans:guiaResumoInternacao"		,''											,.F.,.T.,.T. )
					
					fWrite( nArqGui,cXMLAux )
					cXMLAux := ""
					
					aCampos	:= {}
					aAdd( aCampos,{ "B5S_NUMGUI"	,cNumGuia	} )
					lRet := PLU520Grv( 4, aCampos, 'MODEL_B5S', 'PLSU520B5S' )
					
					B5S->( dbSkip() )
					
				EndDo
	
			EndIf//If B5S->(MsSeek(xFilial("B5S")+B2S->B2S_NUMLOT))
		
		ElseIf cTipGuia == G_HONORARIO
			
			DBSelectarea("BE4")
			BE4->(DBSetorder(15)) //BE4_FILIAL+BE4_GUIINT
		
			If B5S->(MsSeek(xFilial("B5S")+B2S->B2S_NUMLOT))
				
				while ( B5S->(!eof()) .And. B5S->(B5S_FILIAL+B5S_NUMLOT) == xFilial("B5S")+B2S->B2S_NUMLOT )
					
					If lEnd
						alert( STR0016 ) //"Execução cancelada pelo usuário."
						exit
					EndIf
					
					If cTipGuia != B5S->B5S_TIPGUI
						B5S->( dbSkip() )
						Loop
					EndIf
					
					cXMLAux := ""
					
					cCGCExe		:= ""
					cCodOriExe	:= ""
					cNomExe		:= ""
					cCGCRDA		:= ""
					cNomRDA		:= ""
					cCNES		:= ""
					cCnesEx		:= ""
					
					IncProc( STR0017 ) //"Gerando dados para o arquivo de envio..."
					
					//Posiciona BD5
					If !( BD5->(MsSeek( xFilial("BD5")+B5S->(B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO) )) )
						aAdd(aCritica,{ 	"[" + B2S->B2S_OPEORI + "]" + B2S->B2S_NUMLOT,;
											STR0018,; //"Não encontrado registro de contas correspondente."
											"BD5",;
											"1",;
											xFilial("B5S")+B5S->(B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO) } )
					EndIf
					
					//Posiciona BE4
					If !( BE4->(MsSeek( xFilial("BE4")+BD5->BD5_GUIINT )) )
						aAdd(aCritica,{ 	"[" + B2S->B2S_OPEORI + "]" + B2S->B2S_NUMLOT,;
											STR0020,; //"Não encontrado registro de internação correspondente."
											"BE4",;
											"15",;
											xFilial("BE4")+BD5->BD5_GUIINT } )
					EndIf
					
					cMatAnt 	:= AllTrim( Posicione("BA1",2,xFilial("BA1")+BD5->(BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO),"BA1_MATANT") )
					cCartei 	:= AllTrim( BD5->(BD5_FILIAL+BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO) )
					cNRCRNA 	:= AllTrim( Posicione("BTS",1,xFilial("BTS")+BD5->BD5_MATVID,"BTS_NRCRNA") )
					cCBOS		:= AllTrim( Posicione("BAQ",7,xFilial("BAQ")+BD5->BD5_CODESP,"BAQ_CBOS") )
					cCnesEx		:= AllTrim( Posicione("BB8",1,xFilial("BB8")+BD5->(BD5_CODRDA+BD5_CODOPE+BD5_CODLOC),"BB8_CNES") )
					
					//========== Dados Profissional Executante ===========
					If BB0->(MsSeek( xFilial("BB0")+BD5->(BD5_ESTEXE+BD5_REGEXE+BD5_SIGEXE) ))
						cCGCExe		:= AllTrim(BB0->BB0_CGC)
						cCodOriExe	:= AllTrim(BB0->BB0_CODORI)
						cNomExe		:= AllTrim(BB0->BB0_NOME)
					EndIf
					
					If Empty(cCodOriExe) .And. Empty(cCGCExe)
						BB0->(DBSetorder(3))
						If BB0->(MsSeek( xFilial("BB0")+BD5->(BD5_CPFRDA) ))
							cCGCExe		:= AllTrim(BB0->BB0_CGC)
							cCodOriExe	:= AllTrim(BB0->BB0_CODORI)
							cNomExe		:= AllTrim(BB0->BB0_NOME)
						EndIf
						BB0->(DBSetorder(4))
					EndIf
					//====================================================
					
					//=========== Dados da RDA =============
					If BAU->( MsSeek( xFilial("BAU")+BE4->BE4_CODRDA ) ) 
						cCGCRDA		:= AllTrim(BAU->BAU_CPFCGC)
						cNomRDA		:= AllTrim(BAU->BAU_NOME) 
						cCNES 		:= AllTrim(BAU->BAU_CNES)
					EndIf
					If Empty(cCNES)
						cCNES := "9999999"
					EndIf
					//======================================
					
					cNumGuia := PLU520RGui(G_HONORARIO)
					
					cXMLAux += A270Tag( 4,"ans:guiaHonorarios"				,''										,.T.,.F.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:cabecalhoGuia"				,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:registroANS"	 				,cReAnsOri					 			,.T.,.T.,.F. )
					cXMLAux += A270Tag( 6,"ans:numeroGuiaPrestador"			,cNumGuia								,.T.,.T.,.F. )
					cXMLAux += A270Tag( 5,"ans:cabecalhoGuia"				,''										,.F.,.T.,.T. )
					cGuiaInt := IIF( !Empty(BD5->BD5_GUIPRI),BD5->BD5_GUIPRI,BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT) )
					cXMLAux += A270Tag( 5,"ans:guiaSolicInternacao"			,allTrim( cGuiaInt )					,.T.,.T.,.F. )
					cXMLAux += A270Tag( 5,"ans:senha"						,allTrim( BE4->BE4_SENHA )				,.T.,.T.,.F. ) //Opcional
					cXMLAux += A270Tag( 5,"ans:numeroGuiaOperadora"			,allTrim( BD5->(BD5_CODLDP+BD5_CODPEG+BD5_NUMERO) ),.T.,.T.,.F. ) //Opcional
					cXMLAux += A270Tag( 5,"ans:beneficiario"				,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:numeroCarteira"				,allTrim( cMatAnt )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:nomeBeneficiario"			,allTrim( BD5->BD5_NOMUSR )				,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:atendimentoRN"				,IIF(BD5->BD5_ATERNA=="1","S","N")		,.T.,.T.,.T. )
					cXMLAux += A270Tag( 5,"ans:beneficiario"				,''										,.F.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:localContratado"				,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:codigoContratado"			,''										,.T.,.F.,.T. )
					If !(Empty(cCGCRDA))
						cXMLAux += A270Tag( 7,"ans:cnpjLocalExecutante"		,allTrim( cCGCRDA )						,.T.,.T.,.T. )
					Else
						cXMLAux += A270Tag( 7,"ans:codigoNaOperadora"		,allTrim( BE4->BE4_CODRDA )				,.T.,.T.,.T. )
					EndIf
					cXMLAux += A270Tag( 6,"ans:codigoContratado"			,''										,.F.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:nomeContratado"				,allTrim( cNomRDA )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:cnes"						,allTrim( cCNES )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 5,"ans:localContratado"				,''										,.F.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:dadosContratadoExecutante"	,''										,.T.,.F.,.T. )
					If !Empty(cCodOriExe)
						cXMLAux += A270Tag( 6,"ans:codigonaOperadora"		,allTrim( cCodOriExe )					,.T.,.T.,.T. )
					Else
						cXMLAux += A270Tag( 6,"ans:codigonaOperadora"		,allTrim( cCGCExe )						,.T.,.T.,.T. )
					EndIf
					cXMLAux += A270Tag( 6,"ans:nomeContratadoExecutante"	,allTrim( cNomExe )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:cnesContratadoExecutante"	,allTrim( cCnesEx )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 5,"ans:dadosContratadoExecutante"	,''										,.F.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:dadosInternacao"				,''										,.T.,.F.,.T. )
					dDtIniF	:= Iif( Empty(BE4->BE4_DTINIF), BE4->BE4_DATPRO, BE4->BE4_DTINIF )
					dDtFimF	:= Iif( Empty(BE4->BE4_DTFIMF), BE4->BE4_DTALTA, BE4->BE4_DTFIMF )
					cXMLAux += A270Tag( 6,"ans:dataInicioFaturamento"		,convDataXML( dDtIniF )					,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:dataFimFaturamento"			,convDataXML( dDtFimF )	   				,.T.,.T.,.T. )
					cXMLAux += A270Tag( 5,"ans:dadosInternacao"				,''										,.F.,.T.,.T. )
					
					fWrite( nArqGui,cXMLAux )
					cXMLAux := ""
					
					If B6S->(MsSeek(xFilial("B6S")+B5S->(B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO)))
						
						cXMLAux += A270Tag( 5,"ans:procedimentosRealizados"		,''										,.T.,.F.,.T. )
						
						While ( B6S->(!eof()) .And. B6S->(B6S_FILIAL+B6S_NUMLOT+B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO) ==;
													 xFilial("B6S")+B5S->(B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO) )
							
							//Posiciona BD6
							If !( BD6->(MsSeek( xFilial("BD6")+B6S->(B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO+B6S_ORIMOV+B6S_SEQUEN+B6S_CODPAD+B6S_CODPRO) )) )
								aAdd(aCritica,{ 	"[" + B2S->B2S_OPEORI + "]" + B2S->B2S_NUMLOT,;
													STR0019,; //"Não encontrado registro de procedimentos correspondente."
													"BD6",;
													"1",;
													xFilial("BD6")+B6S->(B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO+B6S_ORIMOV+B6S_SEQUEN+B6S_CODPAD+B6S_CODPRO) } )
							EndIf

							cXMLAux += A270Tag( 6,"ans:procedimentoRealizado"	, ''									,.T.,.F.,.T. )
							cXMLAux += A270Tag( 7,"ans:sequencialItem"			,PGetSeqTISS()							,.T.,.T.,.F. )
							cXMLAux += A270Tag( 7,"ans:dataExecucao"			,convDataXML(BD6->BD6_DATPRO)			,.T.,.T.,.F. )
							If  !Empty(BD6->BD6_HORPRO)
								cHrIniF	:= FormatHora(BD6->BD6_HORPRO)
								cXMLAux += A270Tag( 7,"ans:horaInicial"			,cHrIniF,.T.,.T.,.T.,.F. )//Opcional
							EndIf
							If  !Empty(BD6->BD6_HORFIM)
								cHrFimF	:= FormatHora(BD6->BD6_HORFIM)
								cXMLAux += A270Tag( 7,"ans:horaFinal"			,cHrFimF,.T.,.T.,.T.,.F. )//Opcional
							EndIf
							cXMLAux += A270Tag( 7,"ans:procedimento"			,''										,.T.,.F.,.T. )
							aProced	:= PLGETPROC(Alltrim(BD6->BD6_CODPAD),Alltrim(BD6->BD6_CODPRO))
							cCodPad := aProced[2]
							cCodPro := aProced[3]
							cDescri := PLSIMPVINC("BR8",cCodPad	,	BD6->BD6_CODPAD+BD6->BD6_CODPRO	,.T.)
							BR8->(dbSetOrder(1))
							if BR8->(msSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO)))
								if Empty(cDescri)
									cDescri := alltrim(BR8->BR8_DESCRI)
								endIf
								if !empty(BR8->BR8_CODEDI)
									cCodPro := alltrim(BR8->BR8_CODEDI)
								endIf
							endif
							cDescri := substr(cDescri,1,150)
							cXMLAux += A270Tag( 8,"ans:codigoTabela"			,allTrim( cCodPad )						,.T.,.T.,.T. )
							cXMLAux += A270Tag( 8,"ans:codigoProcedimento"		,allTrim( cCodPro )		   				,.T.,.T.,.T. )
							cXMLAux += A270Tag( 8,"ans:descricaoProcedimento"	,allTrim( cDescri )		   				,.T.,.T.,.T. )
							cXMLAux += A270Tag( 7,"ans:procedimento"			,''										,.F.,.T.,.T. )
							nQtdPro	:= round(B6S->B6S_QTDPRO,2)
							nValPro	:= B6S->B6S_VLRPRO/nQtdPro
							nValPro := round(nValPro,2)
							cXMLAux += A270Tag( 7,"ans:quantidadeExecutada"		,allTrim(str(nQtdPro))					,.T.,.T.,.T. )
							cViaTis := AllTrim(Posicione("BGR",1,xFilial("BGR")+BD6->(BD6_CODOPE+BD6_VIA),"BGR_VIATIS"))
							cVincBkp := P520VINC('61', 'BGR', cViaTis)
							//PLSVARVINC('61', 'BGR', cViaTis) // Vinculo Terminologia de Via de Acesso Tabela 61 TISS
							If !Empty(cVincBkp)
								cViaTis := cVincBkp 
							EndIf
							If !Empty(cViaTis)
								cXMLAux += A270Tag( 7,"ans:viaAcesso"			,alltrim( cViaTis )						,.T.,.T.,.T. )//Opcional
							EndIf
							If !Empty(BD6->BD6_TECUTI)
								cXMLAux += A270Tag( 7,"ans:tecnicaUtilizada"	,alltrim( BD6->BD6_TECUTI )				,.T.,.T.,.T. )//Opcional
							EndIf
							cXMLAux += A270Tag( 7,"ans:reducaoAcrescimo"		,"1"									,.T.,.T.,.T. )
							cXMLAux += A270Tag( 7,"ans:valorUnitario"			,allTrim(str(nValPro))					,.T.,.T.,.T.,.F. )
							cXMLAux += A270Tag( 7,"ans:valorTotal"				,allTrim(str(round(B6S->B6S_VLRPRO,2)))	,.T.,.T.,.T.,.F. )
							
							If ( BD7->(MsSeek( xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO) )) )
							
								While BD7->(!eof()) .And. BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_CODPAD+BD7_CODPRO) ==;
														 xFilial("BD7")+BD6->(BD6_CODOPE+BD6_CODLDP+BD6_CODPEG+BD6_NUMERO+BD6_ORIMOV+BD6_CODPAD+BD6_CODPRO)
									
									cCGCExe		:= ""
									cCodOriExe	:= ""
									cCodExe		:= ""
									cNomExe		:= ""
									cREGPRE		:= ""
									cEstExe		:= ""
									cSigExe		:= ""
									
									BB0->(DbSelectArea("BB0"))
									If !Empty(BD7->BD7_REGPRE)
										BB0->(DbSetOrder(4)) //BB0_FILIAL+BB0_ESTADO+BB0_NUMCR+BB0_CODSIG+BB0_CODOPE
										If BB0->(MsSeek( xFilial("BB0")+BD7->(BD7_ESTPRE+BD7_REGPRE+BD7_SIGLA) ))
											cCGCExe		:= BB0->BB0_CGC
											cCodOriExe	:= BB0->BB0_CODORI
											cCodExe		:= BB0->BB0_CODIGO
											cNomExe		:= BB0->BB0_NOME
											cREGPRE		:= BB0->BB0_NUMCR
											cEstExe 	:= BB0->BB0_ESTADO
											cSigExe		:= BB0->BB0_CODSIG
										ElseIf !Empty(BD7->BD7_CDPFPR)
											BB0->(DbSetOrder(1)) //BB0_FILIAL+BB0_CODIGO
											If BB0->( MsSeek(xFilial("BB0")+BD7->BD7_CDPFPR) )
												cCGCExe		:= BB0->BB0_CGC
												cCodOriExe	:= BB0->BB0_CODORI
												cCodExe		:= BB0->BB0_CODIGO
												cNomExe		:= BB0->BB0_NOME
												cREGPRE		:= BB0->BB0_NUMCR
												cEstExe 	:= BB0->BB0_ESTADO
												cSigExe		:= BB0->BB0_CODSIG
											EndIf
										Else
											BB0->(DbSetOrder(7)) //BB0_FILIAL+BB0_NUMCR
											If BB0->( MsSeek(xFilial("BB0")+BD7->BD7_REGPRE) )
												cCGCExe		:= BB0->BB0_CGC
												cCodOriExe	:= BB0->BB0_CODORI
												cCodExe		:= BB0->BB0_CODIGO
												cNomExe		:= BB0->BB0_NOME
												cREGPRE		:= BB0->BB0_NUMCR
												cEstExe 	:= BB0->BB0_ESTADO
												cSigExe		:= BB0->BB0_CODSIG
											EndIf
										EndIf
									EndIf
									
									If EMPTY(cCGCExe+cCodOriExe+cCodExe) .AND. !Empty(BD6->BD6_CPFRDA)
										BB0->(DbSetOrder(3))//BB0_FILIAL+BB0_CGC
										If BB0->( MsSeek(xFilial("BB0")+BD6->BD6_CPFRDA) )
											cCGCExe		:= BB0->BB0_CGC
											cCodOriExe	:= BB0->BB0_CODORI
											cCodExe		:= BB0->BB0_CODIGO
											cNomExe		:= BB0->BB0_NOME
											cREGPRE		:= BB0->BB0_NUMCR
											cEstExe 	:= BB0->BB0_ESTADO
											cSigExe		:= BB0->BB0_CODSIG
										EndIf
									EndIf
									
									cGrauPart := cGrauPa	:= ""
									If !Empty(BD7->BD7_CODTPA)
										cGrauPart := PLSGETVINC("BTU_CDTERM", "BWT", .F., "35", BD7->BD7_CODTPA)
									Else
										cGrauPa := PLSGrauUM(BD6->BD6_CODPAD,BD6->BD6_CODPRO,BD7->BD7_CODUNM,BD6->BD6_DATPRO,"2")[2]
										cGrauPart := PLSGETVINC("BTU_CDTERM", "BWT", .F., "35", cGrauPa)
									EndIf 
									
									If !Empty(cGrauPart)
										aAdd(aCritica,{	"[" + B2S->B2S_OPEORI + "]" + B2S->B2S_NUMLOT,;
														STR0021,; //"Não encontrado registro de Participação na tabela TISSxProtheus (De/Para)."
														"BD7",;
														"1",;
														xFilial("BD7")+BD7->(BD7_FILIAL+BD7_CODOPE+BD7_CODLDP+BD7_CODPEG+BD7_NUMERO+BD7_ORIMOV+BD7_SEQUEN+BD7_CODUNM+BD7_NLANC) } )
									EndIf
									
									If ( !Empty(cCGCExe) .Or. !Empty(cCodOriExe) .Or. !Empty(cCodExe) ) .And.;
										 !Empty(cNomExe) .And. !Empty(cREGPRE) .And. !Empty(cGrauPart)
										
										cXMLAux += A270Tag( 7,"ans:profissionais"				,''									,.T.,.F.,.T. )
										cXMLAux += A270Tag( 8,"ans:grauParticipacao"			,allTrim( cGrauPart )				,.T.,.T.,.F. )
										cXMLAux += A270Tag( 8,"ans:codProfissional"				,''									,.T.,.F.,.T. )
										If !(Empty(cCGCExe))
											cXMLAux += A270Tag( 9,"ans:cpfContratado"			,allTrim( cCGCExe )				,.T.,.T.,.T. )
										Else
											If !(Empty(cCodOriExe))
												cXMLAux += A270Tag( 9,"ans:codigoPrestadorNaOperadora"	,allTrim( cCodOriExe )		,.T.,.T.,.T. )
											Else
												cXMLAux += A270Tag( 9,"ans:codigoPrestadorNaOperadora"	,allTrim( cCodExe )			,.T.,.T.,.T. )
											EndIf
										EndIf
										cXMLAux += A270Tag( 8,"ans:codProfissional"				,''									,.F.,.T.,.T. )
										cXMLAux += A270Tag( 8,"ans:nomeProfissional"			,allTrim( cNomExe )					,.T.,.T.,.T. )
										cXMLAux += A270Tag( 8,"ans:conselhoProfissional"		,AllTrim( PLSGETVINC("BTU_CDTERM", "BAH", .F., "26", BD7->BD7_SIGLA) )  ,.T.,.T.,.T. )
										cXMLAux += A270Tag( 8,"ans:numeroConselhoProfissional"	,allTrim( cREGPRE )	  				,.T.,.T.,.T. )
										cXMLAux += A270Tag( 8,"ans:UF"							,AllTrim( PLSGETVINC("BTU_CDTERM", "   ", .F., "59", BD7->BD7_ESTPRE) )	,.T.,.T.,.T. )
										cCBOS := AllTrim( Posicione("BAQ",7,xFilial("BAQ")+BD7->BD7_ESPEXE,"BAQ_CBOS") )
										If Empty(cCBOS)
											cCBOS := AllTrim( Posicione("BAQ",7,xFilial("BAQ")+BD7->BD7_CODESP,"BAQ_CBOS") )
										EndIf
										cXMLAux += A270Tag( 8,"ans:CBO"							,Iif(Empty(cCBOS),"999999",allTrim(cCBOS)),.T.,.T.,.T. )
										cXMLAux += A270Tag( 7,"ans:profissionais"				,''									,.F.,.T.,.T. )
									
									EndIf
									
									BD7->( dbSkip() )
								EndDo
								
							EndIf
							
							cXMLAux += A270Tag( 6,"ans:procedimentoRealizado"	, ''									,.F.,.T.,.T. )
						
							B6S->( dbSkip() )
						EndDo
					
						cXMLAux += A270Tag( 5,"ans:procedimentosRealizados"		,''										,.F.,.T.,.T. )
					
					EndIf
					
					//cXMLAux += A270Tag( 5,"ans:observacao"					,allTrim( )								,.T.,.T.,.T. )//Opcional
					
					cXMLAux += A270Tag( 5,"ans:valorTotalHonorarios"			,allTrim(str(round(B5S->B5S_VLRPRO,2)))	,.T.,.T.,.T.,.F. )
					cXMLAux += A270Tag( 5,"ans:dataEmissaoGuia"					,convDataXML(BD5->BD5_DTDIGI)			,.T.,.T.,.T. )
					cXMLAux += A270Tag( 4,"ans:guiaHonorarios"					,''										,.F.,.T.,.T. )
					
					fWrite( nArqGui,cXMLAux )
					cXMLAux := ""
					
					aCampos	:= {}
					aAdd( aCampos,{ "B5S_NUMGUI"	,cNumGuia	} )
					lRet := PLU520Grv( 4, aCampos, 'MODEL_B5S', 'PLSU520B5S' )
					
					B5S->( dbSkip() )
					
				EndDo
	
			EndIf//If B5S->(MsSeek(xFilial("B5S")+B2S->B2S_NUMLOT))
		
		ElseIf cTipGuia == G_CONSULTA
	
			If B5S->(MsSeek(xFilial("B5S")+B2S->B2S_NUMLOT))
				
				while ( B5S->(!eof()) .And. B5S->(B5S_FILIAL+B5S_NUMLOT) == xFilial("B5S")+B2S->B2S_NUMLOT )
					
					If lEnd
						alert( STR0016 ) //"Execução cancelada pelo usuário."
						exit
					EndIf
					
					If cTipGuia != B5S->B5S_TIPGUI
						B5S->( dbSkip() )
						Loop
					EndIf
					
					cXMLAux := ""
					
					cCGCRDA		:= ""
					cNomRDA		:= ""
					cCNES		:= ""
					
					IncProc( STR0017 ) //"Gerando dados para o arquivo de envio..."
					
					//Posiciona BD5
					If !( BD5->(MsSeek( xFilial("BD5")+B5S->(B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO) )) )
						aAdd(aCritica,{ 	"[" + B2S->B2S_OPEORI + "]" + B2S->B2S_NUMLOT,;
											STR0018,; //"Não encontrado registro de contas correspondente."
											"BD5",;
											"1",;
											xFilial("B5S")+B5S->(B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO) } )
					EndIf
					
					//Posiciona B6S
					If !( B6S->(MsSeek(xFilial("B6S")+B5S->(B5S_NUMLOT+B5S_CODOPE+B5S_CODLDP+B5S_CODPEG+B5S_NUMERO))) )
						aAdd(aCritica,{ "[" + B2S->B2S_OPEORI + "]" + B2S->B2S_NUMLOT,cCritica, STR0022 } ) //"Não encontrado registro de eventos da guia (B6S) correspondente."
					EndIf
					
					//Posiciona BD6
					If !( BD6->(MsSeek( xFilial("BD6")+B6S->(B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO+B6S_ORIMOV+B6S_SEQUEN+B6S_CODPAD+B6S_CODPRO) )) )
						aAdd(aCritica,{ 	"[" + B2S->B2S_OPEORI + "]" + B2S->B2S_NUMLOT,;
											STR0019,; //"Não encontrado registro de procedimentos correspondente."
											"BD6",;
											"1",;
											xFilial("BD6")+B6S->(B6S_CODOPE+B6S_CODLDP+B6S_CODPEG+B6S_NUMERO+B6S_ORIMOV+B6S_SEQUEN+B6S_CODPAD+B6S_CODPRO) } )
					EndIf
					
					cMatAnt 	:= AllTrim( Posicione("BA1",2,xFilial("BA1")+BD5->(BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO),"BA1_MATANT") )
					cCartei 	:= AllTrim( BD5->(BD5_FILIAL+BD5_CODOPE+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO) )
					cNRCRNA 	:= AllTrim( Posicione("BTS",1,xFilial("BTS")+BD5->BD5_MATVID,"BTS_NRCRNA") )
					cCBOS		:= AllTrim( Posicione("BAQ",7,xFilial("BAQ")+BD5->BD5_CODESP,"BAQ_CBOS") )
					cCNES		:= AllTrim( Posicione("BB8",1,xFilial("BB8")+BD5->(BD5_CODRDA+BD5_CODOPE+BD5_CODLOC),"BB8_CNES") )
					
					//=========== Dados da RDA =============
					If BAU->( MsSeek( xFilial("BAU")+BD5->BD5_CODRDA ) ) 
						cCGCRDA		:= AllTrim(BAU->BAU_CPFCGC)
						cNomRDA		:= AllTrim(BAU->BAU_NOME)
						cCNES 		:= AllTrim(BAU->BAU_CNES)
					EndIf
					If Empty(cCNES)
						cCNES := "9999999"
					EndIf
					//======================================
					
					cNumGuia := PLU520RGui(G_CONSULTA)
					
					cXMLAux += A270Tag( 4,"ans:guiaConsulta"				,''										,.T.,.F.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:cabecalhoConsulta"			,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:registroANS"	 				,cReAnsOri					 			,.T.,.T.,.F. )
					cXMLAux += A270Tag( 6,"ans:numeroGuiaPrestador"			,cNumGuia								,.T.,.T.,.F. )
					cXMLAux += A270Tag( 5,"ans:cabecalhoConsulta"			,''										,.F.,.T.,.T. )
					cXMLAux += A270Tag( 5,"ans:numeroGuiaOperadora"			,allTrim( BD5->(BD5_CODLDP+BD5_CODPEG+BD5_NUMERO) ),.T.,.T.,.F. ) //Opcional
					
					cXMLAux += A270Tag( 5,"ans:dadosBeneficiario"			,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:numeroCarteira"				,allTrim( cMatAnt )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:atendimentoRN"				,IIF(BD5->BD5_ATERNA=="1","S","N")		,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:nomeBeneficiario"			,allTrim( BD5->BD5_NOMUSR )				,.T.,.T.,.T. )
					if !(empty(cNRCRNA))
						cXMLAux += A270Tag( 6,"ans:numeroCNS"				,allTrim( cNRCRNA )						,.T.,.T.,.T. ) //Opcional
					endif
					//if !empty(cCartei)
					//	cXMLAux += A270Tag( 6,"ans:identificadorBeneficiario",allTrim( cCartei )					,.T.,.T.,.F. ) //Opcional
					//endif
					cXMLAux += A270Tag( 5,"ans:dadosBeneficiario"			,''										,.F.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:contratadoExecutante"		,''										,.T.,.F.,.T. )
					If !(Empty(cCGCRDA))
						If Len(cCGCRDA) > 11
							cXMLAux += A270Tag( 6,"ans:cnpjContratado"	,allTrim( cCGCRDA )							,.T.,.T.,.T. )
						Else
							cXMLAux += A270Tag( 6,"ans:cpfContratado"	,allTrim( cCGCRDA )							,.T.,.T.,.T. )
						EndIf
					Else
						cXMLAux += A270Tag( 6,"ans:codigoPrestadorNaOperadora"	,allTrim( BD5->BD5_CODRDA )			,.T.,.T.,.T. )
					EndIf
					cXMLAux += A270Tag( 7,"ans:nomeContratado"				,allTrim( cNomRDA )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:CNES"						,allTrim( cCNES )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 5,"ans:contratadoExecutante"		,''										,.F.,.T.,.T. )
					
					If !Empty(BD5->BD5_REGEXE)
						cRegExe := BD5->BD5_REGEXE
						cEstExe	:= IIf( !EMPTY(BD5->BD5_ESTEXE),BD5->BD5_ESTEXE,BB0->(Posicione("BB0",7,xFilial("BB0")+BD5->(BD5_REGEXE),"BB0_ESTADO")) )
						cSigExe	:= IIf( !EMPTY(BD5->BD5_SIGEXE),BD5->BD5_SIGEXE,BB0->(Posicione("BB0",4,xFilial("BB0")+cEstExe+cRegExe,"BB0_CODSIG")) )
					ElseIf !Empty(BD5->BD5_CDPFRE)
						BB0->(DbSelectArea("BB0"))
						BB0->(DbSetOrder(1))
						If BB0->( MsSeek(xFilial("BB0")+BD5->BD5_CDPFRE) )
							cRegExe	:= IIF( !EMPTY(BD5->BD5_REGEXE),BD5->BD5_REGEXE,BB0->BB0_NUMCR  )
							cEstExe := IIF( !EMPTY(BD5->BD5_ESTEXE),BD5->BD5_ESTEXE,BB0->BB0_ESTADO )
							cSigExe	:= IIF( !EMPTY(BD5->BD5_SIGEXE),BD5->BD5_SIGEXE,BB0->BB0_CODSIG )
						EndIf
					ElseIf !Empty(BD5->BD5_REGSOL)
						cRegExe := BD5->BD5_REGSOL
						cEstExe	:= IIf( !EMPTY(BD5->BD5_ESTSOL),BD5->BD5_ESTSOL,BB0->(Posicione("BB0",7,xFilial("BB0")+BD5->(BD5_REGSOL),"BB0_ESTADO")) )
						cSigExe	:= IIf( !EMPTY(BD5->BD5_SIGLA), BD5->BD5_SIGLA, BB0->(Posicione("BB0",4,xFilial("BB0")+cEstExe+cRegExe,"BB0_CODSIG")) )
					ElseIf !Empty(BD5->BD5_CDPFSO)
						BB0->(DbSelectArea("BB0"))
						BB0->(DbSetOrder(1))
						If BB0->( MsSeek(xFilial("BB0")+BD5->BD5_CDPFSO) )
							cRegExe	:= IIF( !EMPTY(BD5->BD5_REGSOL),BD5->BD5_REGSOL,BB0->BB0_NUMCR  )
							cEstExe := IIF( !EMPTY(BD5->BD5_ESTSOL),BD5->BD5_ESTSOL,BB0->BB0_ESTADO )
							cSigExe	:= IIF( !EMPTY(BD5->BD5_SIGLA ),BD5->BD5_SIGLA ,BB0->BB0_CODSIG )
						EndIf
					EndIf
					
					cXMLAux += A270Tag( 5,"ans:profissionalExecutante"		,''										,.T.,.F.,.T. )
					//cXMLAux += A270Tag( 6,"ans:nomeProfissional"			,allTrim( cNomExe )						,.T.,.T.,.T. ) //Opcional
					cXMLAux += A270Tag( 6,"ans:conselhoProfissional"		,AllTrim( PLSGETVINC("BTU_CDTERM", "BAH", .F., "26", cSigExe) )	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:numeroConselhoProfissional"	,AllTrim( cRegExe )														,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:UF"							,AllTrim( PLSGETVINC("BTU_CDTERM", "   ", .F., "59", cEstExe) )	,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:CBOS"						,Iif(Empty(cCBOS),"999999",allTrim(cCBOS)),.T.,.T.,.T. )
					cXMLAux += A270Tag( 5,"ans:profissionalExecutante"		,''										,.F.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:indicacaoAcidente"			,IIF(Empty(BD5->BD5_INDACI),"9",AllTrim(BD5->BD5_INDACI)),.T.,.T.,.T. )
					
					cXMLAux += A270Tag( 5,"ans:dadosAtendimento"			,''										,.T.,.F.,.T. )
					cXMLAux += A270Tag( 6,"ans:dataAtendimento"				,convDataXML(BD6->BD6_DATPRO)			,.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:tipoConsulta"				,Iif(Empty(BD5->BD5_TIPCON),"1",allTrim(BD5->BD5_TIPCON)),.T.,.T.,.T. )
					cXMLAux += A270Tag( 6,"ans:procedimento"				,''										,.T.,.F.,.T. )
					aProced	:= PLGETPROC(Alltrim(BD6->BD6_CODPAD),Alltrim(BD6->BD6_CODPRO))
					cCodPad := aProced[2]
					cCodPro := aProced[3]
					BR8->(dbSetOrder(1))
					if BR8->(msSeek(xFilial("BR8")+BD6->(BD6_CODPAD+BD6_CODPRO)))						
						if !empty(BR8->BR8_CODEDI)
							cCodPro := alltrim(BR8->BR8_CODEDI)
						endIf
					endif
					cXMLAux += A270Tag( 7,"ans:codigoTabela"				,allTrim( cCodPad )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 7,"ans:codigoProcedimento"			,allTrim( cCodPro )						,.T.,.T.,.T. )
					cXMLAux += A270Tag( 7,"ans:valorProcedimento"			,allTrim(str(round(B6S->B6S_VLRPRO,2)))	,.T.,.T.,.T.,.F. )
					cXMLAux += A270Tag( 6,"ans:procedimento"				,''										,.F.,.T.,.T. )
					cXMLAux += A270Tag( 5,"ans:dadosAtendimento"			,''										,.F.,.T.,.T. )
						
					//cXMLAux += A270Tag( 5,"ans:observacao"				,''										,.T.,.T.,.T. ) //Opcional 
					
					cXMLAux += A270Tag( 4,"ans:guiaConsulta"				,''										,.F.,.T.,.T. )
					
					fWrite( nArqGui,cXMLAux )
					cXMLAux := ""
					
					aCampos	:= {}
					aAdd( aCampos,{ "B5S_NUMGUI"	,cNumGuia	} )
					lRet := PLU520Grv( 4, aCampos, 'MODEL_B5S', 'PLSU520B5S' )
					
					B5S->( dbSkip() )
					
				EndDo
	
			EndIf//If B5S->(MsSeek(xFilial("B5S")+B2S->B2S_NUMLOT))
	
		EndIf
			
		cXMLAux += A270Tag( 3,"ans:guiasTISS"	,''				,.F.,.T.,.T. )
		cXMLAux += A270Tag( 2,"ans:loteGuias"	,''				,.F.,.T.,.T. )
		cXMLAux += A270Tag( 1,"ans:prestadorParaOperadora"	,''	,.F.,.T.,.T. )
		
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
			cRetTag += allTrim( iif( lRetPto,PlRetponto( cVal ),cVal ) )
		endIf

		if( lFin ) // Finaliza a tag ?
			cRetTag += '</' + cTag + '>'
		EndIf
		
		if lEnvTag .And. ( nArqHash > 0 ) // Escreve conteudo da tag no temporario pra calculo do hash
			FWrite(nArqHash,AllTrim(Iif(lRetPto,PlRetponto(cVal),cVal))) 
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
		msgInfo( STR0028 + cHashFile + CRLF + STR0029 ) //"O arquivo não foi encontrado ou não está acessível: " # "Hash do arquivo não pode ser calculado!"
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
static function validXML( cXML,cXSD, cDir, cFileXML )
	local cError	:= ""
	local cWarning	:= ""	
	local lRet		:= .F.

	//--< Valida um arquivo XML com o XSD >--
	if( xmlFVldSch( cXML,cXSD,@cError,@cWarning ) )
		lRet := .T.
	endIf

	if( !lRet )		
		geraLogErro( cError, cDir, cFileXML )		
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
static function geraLogErro( cError, cDir, cFileXML )
	local cMascara	:= STR0005 + " .LOG | *.log" //"Arquivos"
	local cTitulo	:= STR0006 //"Selecione o local"
	local nMascpad	:= 0
	local cRootPath	:= ""
	local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
	local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
	local l3Server	:= .T.	//.T. = apresenta o árvore do servidor || .F. = não apresenta
	local cFileLOG	:= strtran(cFileXML,".xml") + "_" + allTrim( B2S->B2S_OPEORI ) + allTrim( B2S->B2S_NUMLOT ) + ".log"
	local cPathLOG	:= ""	
	local nArqLog	:= 0	

	cPathLOG	:= cDir//cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
	nArqLog		:= fCreate( cPathLOG+cFileLOG,FC_NORMAL,,.F. )
	
	fWrite( nArqLog,cError )
	fClose( nArqLog )
	
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} StatGuias
Caso a geração do arquivo não contenha erros será alterado o status do lote
@author    Guilherme Carvalho
@since     09/09/2016
/*/
//------------------------------------------------------------------------------------------
Static Function StatGuias(cNumSeq, dDtTran ,cHrTran)
Local aCampos 	:= {}
Default cNumSeq := ""

aadd( aCampos,{ "B2S_STATUS"	,"2"			 						} )	//2=Aviso Enviado
aadd( aCampos,{ "B2S_NUMSEQ"	,cNumSeq								} )
aadd( aCampos,{ "B2S_DATENV"	,date()									} )
aadd( aCampos,{ "B2S_HORENV"	,substr(strtran( time(),":","" ),1,4)	} )

lRet := PLU520Grv( 4, aCampos, 'MODEL_B2S', 'PLSU520B2S' )
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLU520RGui
Retorna o numero da guia conforme regra do PLSUA500

@author    Michel Montoro
@version   1.xx
@since     09/05/2018
@param     cTipGui = Tipo da Guia

/*/
//------------------------------------------------------------------------------------------
Function PLU520RGui(cTipGui)
Local aAreaBE4 := {}
Local cRet := ""

If cTipGui == G_RES_INTER   
	If Empty(BE4->BE4_ANOINT) .And. Empty(BE4->BE4_MESINT) .And. Empty(BE4->BE4_NUMINT) .And. !Empty(BE4->BE4_GUIINT)
		aAreaBE4 := BE4->(GetArea())
		BE4->(DBSetorder(1)) //BE4_FILIAL + BE4_CODOPE + BE4_CODLDP + BE4_CODPEG + BE4_NUMERO + BE4_SITUAC + BE4_FASE
		If BE4->(MsSeek(xFilial("BE4")+BE4->BE4_GUIINT))  
			IIf(Empty(BE4->BE4_NUMIMP),cRet := Padr(BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),20),cRet := Padr(BE4->BE4_NUMIMP,20))
		EndIf
		RestArea(aAreaBE4)  
	Else
		IIf(Empty(BE4->BE4_NUMIMP),cRet := Padr(BE4->(BE4_CODOPE+BE4_ANOINT+BE4_MESINT+BE4_NUMINT),20),cRet := Padr(BE4->BE4_NUMIMP,20))
	EndIf
 Else  
	 If cTipGui == G_HONORARIO  		
		If !Empty(BD5->BD5_NUMIMP)
			  cRet := Padr(BD5->BD5_NUMIMP,20)		
		ElseIf !Empty(BD5->BD5_GUIPRI)
			cRet := Padr(BD5->BD5_GUIPRI,20)
		Else
			cRet := Padr(BD5->(BD5_CODLDP+BD5_CODPEG+BD5_NUMERO),20)
		EndIf  
	 Else    
		BEA->(DbSetOrder(12))//BEA_FILIAL + BEA_OPEMOV + BEA_CODLDP + BEA_CODPEG + BEA_NUMGUI + BEA_ORIMOV
		If !Empty(BD5->BD5_NUMIMP)
			cRet := Padr(BD5->BD5_NUMIMP,20)
		ElseIf BEA->(MsSeek(xFilial("BEA")+BD5->(BD5_CODOPE+BD5_CODLDP+BD5_CODPEG+BD5_NUMERO+BD5_ORIMOV)))
			cRet := Padr(BEA->(BEA_OPEMOV+BEA_ANOAUT+BEA_MESAUT+BEA_NUMAUT),20)
		ElseIf !Empty(BD5->BD5_GUIPRI)
			cRet := Padr(BD5->BD5_GUIPRI,20)
		Else
			cRet := Padr(BD5->(BD5_CODLDP+BD5_CODPEG+BD5_NUMERO),20)
		EndIf 
	 EndIf
 EndIf      

Return(cRet)

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FormatHora
Retorna a hora no formato correto.

@author    Guilherme Carvalho
@version   1.xx
@since     04/06/2018
/*/
//------------------------------------------------------------------------------------------
static function FormatHora( cHora )
	local cRet := ""

If !Empty(cHora)
	
	cRet := AllTrim(TransForm(AllTrim(cHora),"@R !!:!!:!!"))
	
	If Len(cRet) == 5 //99:99
		cRet := cRet+":00"
	ElseIf Len(cRet) == 6 //99:99:
		cRet := cRet+"00"
	ElseIf Len(cRet) == 7 //99:99:9
		cRet := cRet+"0"
	EndIf 	

EndIf

Return(cRet)						
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} P520VINC
Retorna o de para tiss

@author    Lucas Nonato
@version   12.1.17
@since     10/12/2018
/*/
//------------------------------------------------------------------------------------------
static function P520VINC(cCodTab, cAlias, cCdTerm)

BTP->( DbSetOrder(1) )
BTP->( MsSeek( xFilial("BTP") + cCodTab ) )
	
BTU->(DbSetOrder(2)) //BTU_FILIAL, BTU_CODTAB, BTU_ALIAS, BTU_VLRSIS
If BTU->(MsSeek(xFilial("BTU") + cCodTab + cAlias + cCdTerm))	
	cCdTerm 	:= BTU->BTU_CDTERM
endif			

return cCdTerm	

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PConvSoma1
Converte o soma1 para numérico(BD6_SEQUEN)

@author    PLS TEAM
@version   P12
@since     03/03/2020
/*/
function PConvSoma1(cNumero)
local nValor    := 0
local lSoNumero := .T.
local nAtual    := 0
local cAscii    := ""
local nPosIni   := 0
local cCaract   := ""
local nValAux   := 0
local cZeros    := ""

cNumero := Upper(cNumero)
 
//Percorre os valores
For nAtual := 1 To Len(cNumero)
    cCaract := SubStr(cNumero, nAtual, 1)
     
    //Se tiver alguma letra no numero
    If cCaract $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        If nPosIni == 0
            nPosIni := nAtual
        EndIf
        lSoNumero := .F.
        Exit
    EndIf
Next
     
//Se tiver somente numero, converte com Val
If lSoNumero
    nValor := Val(cNumero)
     
Else
    nValor := 0
     
    //Percorre os valores
    For nAtual := 1 To Len(cNumero)
        cCaract := SubStr(cNumero, nAtual, 1)
        cZeros  := Replicate("0", Len(cNumero)-nAtual)
         
        //Se tiver alguma letra no numero
        If cCaract $ "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
            cAscii := cValToChar(Asc(cCaract) - 64 + 9)
             
            //Se for a partir da segunda posição e não for a última
            If nAtual > nPosIni .And. nAtual != Len(cNumero)
                nValAux := Val(cAscii + cZeros) + Iif(nAtual != Len(cNumero), 26 * (Asc(cCaract) - 64), 0)
                nValAux *= Val(cAscii)
                nValAux += (26 + Val(cAscii))
                nValor += nValAux
                 
            Else
                nValor += Val(cAscii + cZeros) + Iif(nAtual != Len(cNumero), 26 * (Asc(cCaract) - 64), 0)
            EndIf
         
        //Se for somente números
        Else
            //Se for a partir da segunda posição e não for a última
            If nAtual > nPosIni .And. nAtual != Len(cNumero)
                nValor += Val(cCaract + cZeros) + (36 * 26) + (26*Val(cCaract))
            Else
                nValor += Val(cCaract + cZeros)
            EndIf
        EndIf
    Next        
EndIf
 
return nValor