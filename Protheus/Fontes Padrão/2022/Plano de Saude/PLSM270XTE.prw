#include "fileIO.ch"
#include "protheus.ch"
#include "xmlxfun.ch"
#include "totvs.ch"
#define F_BLOCK  512
#define CRLF chr( 13 ) + chr( 10 )

static cFileHASH := criatrab( nil,.F. ) + ".tmp"
static cNomLogErr:= ""	
static aRecAtu	 := {}		
static lAtuTiss4 := B4O->(fieldPos("B4O_CODUNM")) > 0 .AND. B4N->(fieldPos("B4N_REGATE")) > 0 .AND. B4N->(fieldPos("B4N_SAUOCU")) > 0 .AND. B4N->(fieldPos("B4N_CPFUSR")) > 0 .AND. dDataBase > CtoD("01/03/2023") //Data de início de vigência da versão 1.03.00

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSM270XTE
Gerador do arquivo Operadora para ANS - Tela Inicial

@author    Jonatas Almeida 
@version   1.xx
@since     1/09/2016
/*/
//------------------------------------------------------------------------------------------
function PLSM270XTE(lAuto)
	local cTitulo	:= "Gerar arquivo para ANS - TISS"
	local cTexto	:= CRLF + CRLF + "Gerador do arquivo Operadora para ANS"
	local aOpcoes	:= { "Gerar arquivo","Cancelar" }
	local nTaman	:= 3
	local nOpc		:= 0
	local lEnd		:= .T.
	local oError	:= errorBlock( { | e | trataErro( e ) } )
	default lAuto 	:= .f.

	if valtype(lAuto) <> 'L'
		lAuto := .f.
	endif

	if !lAuto
		nOpc	:= aviso( cTitulo,cTexto,aOpcoes,nTaman )
	endif
	B4N->(dbSetOrder(1))
	B4M->(dbSetOrder(1))
	if B4M->(FieldPos("B4M_VERSAO")) <= 0 	
		Aviso( "Atenção","Para a execução da rotina, é necessária a criação do(s) campo(s): B4M_VERSAO ",{ "Ok" }, 2 )
		return	
	endIf	
	
	If nOpc ==1 .And. B4M->B4M_STATUS == '2' .And. !MsgYesNo("Lote possui criticas. Deseja gerar o arquivo assim mesmo ?")
		nOpc := 0
	EndIf
	
	if( nOpc == 1 ) .or. lAuto
		begin transaction
			processa( { | lEnd | geraArquivo(@lEnd,lAuto) }, "Aguarde...","Carregando dados...",lEnd )
		end transaction
	endIf
	
	errorBlock( oError )
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} trataErro
Tratamento de excecoes nao previstas

@author    Jonatas Almeida
@version   1.xx
@since     05/29/2016
/*/
//------------------------------------------------------------------------------------------
static function trataErro( e )
	msgAlert( "Erro: " + chr( 10 ) + e:Description,"Atenção!" )
	disarmTransaction()
	break
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraArquivo
Gerador do arquivo Operadora para ANS - Processamento dos dados

@author    Jonatas Almeida
@version   1.xx
@since     1/09/2016
/*/
//------------------------------------------------------------------------------------------
static function geraArquivo( lEnd, lAuto )
	local cMascara	:= "Arquivos .XTE | *.xte"
	local cTitulo	:= "Selecione o local"
	local nMascpad	:= 0
	local cRootPath	:= ""
	local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
	local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
	local cFileXTE	:= ""
	local cPathXTE	:= ""
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
	local cSql		:= ""
	local aPerg		:= {}
	local aRetP		:= {}
	local lFlagDef	:= .F.
	local l3Server	:= .F.
	local lPrcXTE	:= .T.//Processa gravacao do arquivo .XTE
	local cArqFinal	:= ""
	local aLog		:= {}
	local aArqs		:= {}
	local lAltNom		:= .f.
	local cNome		:= ""
	local cTipEnv 	:= 0
	private nArqHash := 0
	default lEnd	:= .F. 
	default lAuto	:= .F. 
	
	cPathXTE := PLSMUDSIS( "\temp\" )
	if !lAuto 
		cArqFinal := cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
	else
		cArqFinal := cPathXTE
	endif
	if( !existDir( cPathXTE ) )
		if( MakeDir( cPathXTE ) <> 0 )
			msgAlert( "Não foi possível criar o diretorio '\temp\' no servidor.","Atenção!" )
			disarmTransaction()
			break
		endIf
	endIf
	aadd( aPerg,{ 2,"Gerar arquivo ","2",{ "1=Definitivo","2=Conferencia" },50,/*'.T.'*/,.T. } )

	if !lAuto	
		lPrcXTE := paramBox( aPerg,"Parâmetros - Processa arquivo de envio ANS",aRetP,/*bOK*/,/*aButtons*/,/*lCentered*/,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSM270XTEflg',/*lCanSave*/.T.,/*lUserSave*/.T. )
	endif
	cSql += " SELECT B4M_FILIAL,B4M_NMAREN,B4M_SUSEP,B4M_CMPLOT,B4M_NUMLOT,B4M_REENVI " 
	cSql += " FROM " + RetSqlName("B4M") + " B4M "
	cSql += " WHERE B4M_FILIAL = '" + xFilial("B4M") + "' "
	cSql += " AND B4M_OK = '" + oMBrwB4M:cMark + "' "
	cSql += " AND B4M.D_E_L_E_T_ = ' '  "	

	cSql := ChangeQuery(cSql)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"PLEXC",.F.,.T.)	

	while !PLEXC->(eof())
		lAltNom := .f.
		B4M->(msseek(xFilial("B4M") + PLEXC->(B4M_SUSEP+B4M_CMPLOT+B4M_NUMLOT)))
		cFileXTE := getNomeArq(aArqs)
		cTipEnv  := Iif( B4M->(FieldPos("B4M_TIPENV")) > 0 .and. !empty(B4M->B4M_TIPENV), B4M->B4M_TIPENV, "1" )

		If lPrcXTE
			atualizaCabec( cFileXTE,allTrim( time() ) ) 
			if lAuto 
				lFlagDef := .t.
			else
				lFlagDef := iif( allTrim( aRetP[ 1 ] ) == "1",.T.,.F. )		
			endif
		EndIf
				
		If lPrcXTE//Continua com a gravacao 
		
			nArqFull := fCreate( cPathXTE+cFileXTE,FC_NORMAL )
	
			If nArqFull > 0 		
		
				nArqHash := fCreate( lower( cPathXTE+cFileHASH ),0,,.F. )
				cCabTMP := geraCabec( cPathXTE,cFileXTE )
				cDetTMP := geraGuias( cPathXTE,@lEnd )
			
				If !lEnd
	
					//--< Append cabecalho TMP >--					
					nCabXml := fOpen( cCabTMP,FO_READ )
	
					if( nCabXml <= 0 )						
						cRet +=  "[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT + "- Não foi possível abrir o arquivo " + cCabTMP + CRLF
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
						cRet +=  "[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT + "- Não foi possível abrir o arquivo " + cDetTMP + CRLF						
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
										
					cHash := A270Hash( cPathXTE+cFileHASH,nArqHash )
					If !lFlagDef
						cHash := "Arquivo de Conferencia"
					EndIf		
								
					cXmlTMP := A270Tag( 1,'ans:epilogo','',.T.,.F.,.T. )
					cXmlTMP += A270Tag( 2,'ans:hash',upper( cHash ),.T.,.T.,.T. )
					cXmlTMP += A270Tag( 1,'ans:epilogo','',.F.,.T.,.T. )
					cXmlTMP += A270Tag( 0,"ans:mensagemEnvioANS",'',.F.,.T.,.T. )
					fWrite( nArqFull,cXmlTMP )
					fClose( nArqFull )
					if empty(B4M->B4M_VERSAO)
						cVSchema := "1_00_00"
					else
						cVSchema := allTrim( strTran( P270RetVer(.T.),".","_" ) )
					endif

					if( validXML( cPathXTE+cFileXTE,GetNewPar( "MV_TISSDIR","\TISS\" ) + "schemas\tissMonitoramentoV"+ cVSchema +".xsd", cArqFinal, @aLog,cFileXTE ) )
				
						If B4M->B4M_STATUS <> '2'//Diferente de criticado no processamento
							if( lFlagDef )
								atualizaCabec( cFileXTE,allTrim( time() ) )
								flgGuias( B4M->B4M_NUMLOT,B4M->B4M_CMPLOT,B4M->B4M_SUSEP )	
					
								aCampos := { }
								aadd( aCampos,{ "B4M_FILIAL"	,xFilial( "B4M" ) } )	// filial
								aadd( aCampos,{ "B4M_SUSEP"		,B4M->B4M_SUSEP } )		// operadora
								aadd( aCampos,{ "B4M_CMPLOT"	,B4M->B4M_CMPLOT } )	// competencia lote
								aadd( aCampos,{ "B4M_NUMLOT"	,B4M->B4M_NUMLOT } )	// numero de lote
								aadd( aCampos,{ "B4M_STATUS"	,iif(B4M->B4M_STATUS $ '5,6,7,8,9', B4M->B4M_STATUS, '3') } )				// Arq. envio (sem criticas)
								gravaMonit( 4,aCampos,'MODEL_B4M','PLSM270' )

							else
								atualizaCabec( cFileXTE,allTrim( time() ), iif(B4M->B4M_STATUS $ '1,2' , .T., .F.) )
							endIf

							aadd(aLog, {"[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT, ' Arquivo gerado: ' + cFileXTE} )							
				
						Else//If B4M->B4M_STATUS <> '2'
							lAltNom := .t.
							atualizaCabec( cFileXTE,allTrim( time() ),.T. )
							aadd(aLog, {"[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT, "Nao enviar para a ANS!" } )
							aadd(aLog, { "[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT, "Arquivo de conferencia gerado. Lote possui criticas e nao foi atualizado" } ) 
													
						EndIf
	
					else//if( validXML(	
						lAltNom := .t.	
						atualizaCabec( cFileXTE,allTrim( time() ),.T. )	
						aadd(aLog, { "[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT, "Nao enviar para a ANS!" } ) 
						aadd(aLog, {  "[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT, "Arquivo de conferencia gerado. Lote possui criticas e nao foi atualizado" } )						
					endIf
				Else
				
					If File(cPathXTE+cFileXTE)
						fClose( nArqFull )
						fErase(cPathXTE+cFileXTE)
					EndIf
				
					If File(cPathXTE+cFileHASH)
						fClose( nArqHash )
						fErase(cPathXTE+cFileHASH)
					EndIf
			
				EndIf//If !lEnd
				if !lAuto 
					CpyS2T( cPathXTE+cFileXTE,cArqFinal )
				endif
				if lAltNom
					//caso o arquivo esteja criticado, iremos renomear com o novo nome.
					cnome := LEFT(cFileXTE, AT(".", cFileXTE) -1 ) + cNomLogErr + "_CRITICADO" + RIGHT(cFileXTE, 4)
					frename(cArqFinal+cFileXTE, cArqFinal + cnome)
				endif
			Else//If nArqFull > 0				
				aadd(aLog, { "[" + PLEXC->B4M_CMPLOT + "]" + PLEXC->B4M_NUMLOT, "Nao foi possivel criar o arquivo: " + allTrim( cFileXTE ) } )	
			EndIf
		EndIf//If lPrcXTE
		PLEXC->(dbskip())
	enddo
	PLEXC->(DbCloseArea())
	if len(aLog) > 0 .and. !lAuto
		PLSCRIGEN(aLog,{{"Lote","@!",20},{"Mensagem","@!",120}},"Log de geração",nil,nil)
	endif
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraCabec
Compoe os dados do cabecalho do arquivo

@author    Jonatas Almeida
@version   1.xx
@since     1/09/2016

@param     cPathXTE = caminho do arquivo
@param     cFileXTE = nome do arquivo
@return    cFileCAB = nome do arquivo
/*/
//------------------------------------------------------------------------------------------
static function geraCabec( cPathXTE,cFileXTE )
	local cXTE := ""
	local cHorComp		:= allTrim( time() )
	local cFileCAB		:= cPathXTE + criatrab( nil,.F. ) + ".tmp"
	local nArqCab	:= fCreate( cFileCAB,FC_NORMAL )
	
	cXTE := '<?xml version="1.0" encoding="ISO-8859-1"?>' + CRLF
	cXTE += '<ans:mensagemEnvioANS xmlns:ans="http://www.ans.gov.br/padroes/tiss/schemas" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.ans.gov.br/padroes/tiss/schemas">' + CRLF
	cXTE += A270Tag( 1,"ans:cabecalho",'',.T.,.F.,.T. )
	cXTE += A270Tag( 2,"ans:identificacaoTransacao",'',.T.,.F.,.T. )
	cXTE += A270Tag( 3,"ans:tipoTransacao",'MONITORAMENTO',.T.,.T.,.T. )
	cXTE += A270Tag( 3,"ans:numeroLote",allTrim( B4M->( B4M_NUMLOT ) ),.T.,.T.,.T. )
	cXTE += A270Tag( 3,"ans:competenciaLote",allTrim( B4M->( B4M_CMPLOT ) ),.T.,.T.,.T. )
	cXTE += A270Tag( 3,"ans:dataRegistroTransacao", convDataXML( dDataBase ) ,.T.,.T.,.T. )
	cXTE += A270Tag( 3,"ans:horaRegistroTransacao",cHorComp,.T.,.T.,.T.,.F. )
	cXTE += A270Tag( 2,"ans:identificacaoTransacao",'',.F.,.T.,.T. )
	cXTE += A270Tag( 2,"ans:registroANS",allTrim( B4M->( B4M_SUSEP ) ),.T.,.T.,.T. )
	cXTE += A270Tag( 2,"ans:versaoPadrao",allTrim( iif(!empty(B4M->B4M_VERSAO),P270RetVer(.T.),"1.00.00") ),.T.,.T.,.T.,.F. )
	cXTE += A270Tag( 1,"ans:cabecalho",'',.F.,.T.,.T. )
	
	if( nArqCab == -1 )
		msgAlert( "Não conseguiu criar o arquivo: " + cFileCAB,"Atenção!" )
		
		atualizaCabec( cFileXTE,allTrim( time() ),.T. )
		disarmTransaction()
		break
	else
		fWrite( nArqCab,cXTE )
		fClose( nArqCab )
	endIf

return cFileCAB

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} atualizaCabec
Gerador do arquivo Operadora para ANS - Tela Inicial

@author    Jonatas Almeida
@version   1.xx
@since     1/09/2016

@param     cPath = caminho do arquivo
@param     cNome = nome do arquivo
@param     cConteudo = conteudo do arquivo
@param     cHorComp = horario de geracao do arquivo

@return    lRet = Flag indicando se atualizou ou nao os dados de cabecalho (B4M)
/*/
//------------------------------------------------------------------------------------------
static function atualizaCabec( cNome,cHorComp,lDel )
	local aCampos	:= {}
	local lRet		:= .F.
	default lDel	:= .F.
	
	if( lDel )
		aadd( aCampos,{ "B4M_NMAREN"	,"" 		} )
		aadd( aCampos,{ "B4M_DTPREN"	,ctod( "  /  /    " ) } )
		aadd( aCampos,{ "B4M_HRPREN"	,""			} )
		//aadd( aCampos,{ "B4M_STATUS"	,"1" 		} )
	else
		aadd( aCampos,{ "B4M_NMAREN"	,cNome		} )
		aadd( aCampos,{ "B4M_DTPREN"	,dDataBase	} )
		aadd( aCampos,{ "B4M_HRPREN"	,cHorComp	} )
	endIf
	
	lRet := gravaMonit( 4,aCampos,'MODEL_B4M','PLSM270' )
return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getNomeArq
Gerador de numerico sequencial para controle da nomenclatura do arquivo

@author    Jonatas Almeida
@version   1.xx
@since     1/09/2016

@return    cNumSeq = Numero sequencial
/*/
//------------------------------------------------------------------------------------------
static function getNomeArq(aArqs)
	local cWhere	:= ""
	local cAlias	:= criaTrab( nil,.F. )
	local cNumSeq	:= superGetMv( "MV_PLSQXTE",.F.,"" )
	local aPergs	:= { }
	local __aRet		:= { }
	
	if( empty( B4M->B4M_NMAREN ) )
		cWhere	:= "%B4M.B4M_SUSEP = '"+ B4M->( B4M_SUSEP ) + "' AND "
		cWhere	+= "B4M.B4M_CMPLOT = '"+ B4M->( B4M_CMPLOT ) +"' AND "
		cWhere	+= "B4M.B4M_NMAREN <> ' ' %"

		beginSQL Alias cAlias
			SELECT MAX( B4M.B4M_NMAREN ) NUMSEQ
			FROM
			%table:B4M% B4M
			WHERE
			B4M.B4M_FILIAL = %xFilial:B4M% AND
			%exp:cWhere% AND
			B4M.%notDel%
		endSQL

		( cAlias )->( dbGoTop() )

		if( !empty( ( cAlias )->( NUMSEQ ) ) )
			cNumSeq := strTran( UPPER(( cAlias )->( NUMSEQ )),".XTE","" )
			cNumSeq := PadL(Val(cNumSeq)+1,16,'0')  //Por algum motivo o Soma1 não estava funcionando em ambientes Linux			
			cNumSeq := cNumSeq + ".xte"
		else
			if( !empty( cNumSeq ) .and. B4M->B4M_CMPLOT < cNumSeq )
				aadd( aPergs,{ 1,"Num. Seq. p/ o lote: " + allTrim( B4M->B4M_CMPLOT ),space( 4 ),"@!",'.T.',''/*F3*/,/*'.T.'*/,70,.T. } )
				if( paramBox( aPergs,"Parâmetros - Numero Sequencial",__aRet,/*bOK*/,/*aButtons*/,/*lCentered*/.T.,/*nPosX*/,/*nPosy*/,/*oDlgWizard*/,/*cLoad*/'PLSM270XTE',/*lCanSave*/.T.,/*lUserSave*/.T. ) )
					cNumSeq	:= allTrim( B4M->B4M_SUSEP ) + allTrim( B4M->B4M_CMPLOT ) + allTrim( __aRet[ 1 ] ) + ".xte"
				endIf
			else
				cNumSeq := allTrim( B4M->B4M_SUSEP ) + allTrim( B4M->B4M_CMPLOT ) + "0001.xte"
			endIf
		endIf

		( cAlias )->( dbCloseArea() )
	else
		cNumSeq := allTrim( B4M->B4M_NMAREN )
	endIf

	/*while ascan(aArqs,cNumSeq) > 0
		cNumSeq := PadL(Val(strtran(cNumSeq,".xte",""))+1,16,'0') + ".xte"		
	enddo
	aadd(aArqs,cNumSeq)*/
return cNumSeq

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraGuias
Grava os dados obtidos na consulta no arquivo .XTE

@author    Jonatas Almeida
@version   1.xx
@since     1/09/2016

@return    cFileGUI = Nome do arquivo
/*/
//------------------------------------------------------------------------------------------
static function geraGuias( cPathXTE,lEnd ) 
	local cAlias	:= ""
	local cFileGUI	:= cPathXTE + criaTrab( nil,.F. ) + ".tmp"
	local nArqGui		:= fCreate( cFileGUI,FC_NORMAL )
	local cXTEAux	:= ""
	local cXTEPac	:= ""
	local cGuia		:= ""
	local cItemGuia:= ""
	local cChvPct	:= ""
	local cItePct	:= ""
	local cCdTbPc	:= ""
	local cCdPrPc	:= ""
	local cPrimItem := ""
	local cCbosCnv	:= ""
	local nB4N_VLTINF := 0
	local nB4N_VLTGUI := 0
	local nB4N_VLTPRO := 0
	local nNV		  := 0
	local nTipEnv := Iif( B4M->(FieldPos("B4M_TIPENV")) > 0 .and. !empty(B4M->B4M_TIPENV),val(B4M->B4M_TIPENV),1 )
	local aNRDCNV	:= {}
	local oHMTISS	:= nil
	local aModelRem := {,} //modelo de remuneração
	default lEnd	:= .F.
	
	if( nArqGui == -1 )
		msgAlert( "Não foi possível criar o arquivo!" )
	else	

	    cXTEAux := A270Tag( 1,"ans:Mensagem",'',.T.,.F.,.T. )
	    cXTEAux += A270Tag( 2,"ans:operadoraParaANS",'',.T.,.F.,.T. )
	    fWrite( nArqGui,cXTEAux )
		cXTEAux := ""
	If nTipEnv == 1//Guias monitoramento

		cAlias	:= getGuias()
		procRegua( ( cAlias )->( recCount() ) )
		
		if (cAlias)->( eof() ) 
			cXTEAux += A270Tag( 3,"ans:semMovimentoInclusao","5016",.T.,.T.,.T. )
		endif

		oHMTISS := setVerTiss(oHMTISS)

		while( ( cAlias )->( !eof() ) )
			If lEnd
				alert( 'Execução cancelada pelo usuário.' )
				exit
			EndIf

			cXTEAux := ""
			cCbosCnv := ""
			
			incProc( "Gerando dados para o arquivo de envio" )
			 
			/* Dados da guia - inicio */
			If cGuia <> ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4N_CODRDA)

				cPrimItem := ""
				cGuia := ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4N_CODRDA)
				cXTEAux += A270Tag( 3,"ans:guiaMonitoramento",'',.T.,.F.,.T. )
				cXTEAux += A270Tag( 4,"ans:tipoRegistro",allTrim( ( cAlias )->( B4N_TPRGMN ) ),.T.,.T.,.T. )
				cXTEAux += A270Tag( 4,"ans:versaoTISSPrestador", getVerTISS( allTrim( ( cAlias )->( B4N_VTISPR ) ), oHMTISS ) ,.T.,.T.,.F. )
				cXTEAux += A270Tag( 4,"ans:formaEnvio",allTrim( ( cAlias )->( B4N_FORENV ) ),.T.,.T.,.T. )
				cXTEAux += A270Tag( 4,"ans:dadosContratadoExecutante",'',.T.,.F.,.T. )
			
				if( ! empty( allTrim( ( cAlias )->( B4N_CNES ) ) ) )
					cXTEAux += A270Tag( 5,"ans:CNES",allTrim( ( cAlias )->( B4N_CNES ) ),.T.,.T.,.T. )
				else
					cXTEAux += A270Tag( 5,"ans:CNES",'1',.T.,.T.,.T. )
				endIf
			
				cXTEAux += A270Tag( 5,"ans:identificadorExecutante",iif( allTrim( ( cAlias )->( B4O_IDEEXC ) ) == 'F','2','1'),.T.,.T.,.T. )
				cXTEAux += A270Tag( 5,"ans:codigoCNPJ_CPF",allTrim( ( cAlias )->( B4O_CPFCNP ) ),.T.,.T.,.T. )
				cXTEAux += A270Tag( 5,"ans:municipioExecutante",allTrim( ( cAlias )->( B4N_CDMNEX ) ),.T.,.T.,.T. )
				cXTEAux += A270Tag( 4,"ans:dadosContratadoExecutante",'',.F.,.T.,.T. )
				cXTEAux += A270Tag( 4,"ans:registroANSOperadoraIntermediaria",allTrim( ( cAlias )->( B4N_RGOPIN ) ),.T.,.T.,.F. )
				if !empty(( cAlias )->( B4N_RGOPIN ))
					cXTEAux += A270Tag( 4,"ans:tipoAtendimentoOperadoraIntermediaria","1",.T.,.T.,.F. )
				endif				
				
				cXTEAux += A270Tag( 4,"ans:dadosBeneficiario",'',.T.,.F.,.T. )
				cXTEAux += A270Tag( 5,"ans:identBeneficiario",'',.T.,.F.,.T. )				
				cXTEAux += A270Tag( 6,"ans:numeroCartaoNacionalSaude",allTrim( ( cAlias )->( B4N_NUMCNS ) ),.T.,.T.,.F. )				
				if lAtuTiss4
					if !(empty( ( cAlias )->( B4N_CPFUSR ) ))
						cXTEAux += A270Tag( 7,"ans:numeroCPFBeneficiario",allTrim( ( cAlias )->( B4N_CPFUSR ) ),.T.,.T.,.F. )
					endif
				endif
				cXTEAux += A270Tag( 6,"ans:sexo",allTrim( ( cAlias )->( B4N_SEXO ) ),.T.,.T.,.T. )
				cXTEAux += A270Tag( 6,"ans:dataNascimento",convDataXML( ( cAlias )->( B4N_DATNAS ) ),.T.,.T.,.T. )
				cXTEAux += A270Tag( 6,"ans:municipioResidencia",allTrim( ( cAlias )->( B4N_CDMNRS ) ),.T.,.T.,.T. )				
				cXTEAux += A270Tag( 5,"ans:identBeneficiario",'',.F.,.T.,.T. )
				cXTEAux += A270Tag( 5,"ans:numeroRegistroPlano",allTrim( ( cAlias )->( B4N_SCPRPS ) ),.T.,.T.,.T. )
				cXTEAux += A270Tag( 4,"ans:dadosBeneficiario",'',.F.,.T.,.T. )				
				
				cXTEAux += A270Tag( 4,"ans:tipoEventoAtencao",allTrim( ( cAlias )->( B4N_TPEVAT ) ),.T.,.T.,.T. )			
				if( ! empty( allTrim( ( cAlias )->( B4N_OREVAT ) ) ) )
					cXTEAux += A270Tag( 4,"ans:origemEventoAtencao",allTrim( ( cAlias )->( B4N_OREVAT ) ),.T.,.T.,.T. )
				else
					cXTEAux += A270Tag( 4,"ans:origemEventoAtencao",'1',.T.,.T.,.T. )
				endIf
				
				if( empty( ( cAlias )->( B4N_NMGPRE ) ) )
					If allTrim( ( cAlias )->( B4N_OREVAT ) ) == "4" // Reembolso
						cXTEAux += A270Tag( 4,"ans:numeroGuia_prestador","00000000000000000000",.T.,.T.,.T. )
					Else
						cXTEAux += A270Tag( 4,"ans:numeroGuia_prestador",allTrim( ( cAlias )->( B4N_NMGOPE ) ),.T.,.T.,.T. )
					Endif
				else 
					cXTEAux += A270Tag( 4,"ans:numeroGuia_prestador",allTrim( ( cAlias )->( B4N_NMGPRE ) ),.T.,.T.,.T. )
				endIf
				
				If allTrim( ( cAlias )->( B4N_OREVAT ) ) == "4" // Reembolso
					cXTEAux += A270Tag( 4,"ans:numeroGuia_operadora","00000000000000000000",.T.,.T.,.T. )
				Else
					cXTEAux += A270Tag( 4,"ans:numeroGuia_operadora",allTrim( ( cAlias )->( B4N_NMGOPE ) ),.T.,.T.,.T. )
				Endif
				
				if( ! empty( allTrim( ( cAlias )->( B4N_IDEREE ) ) ) )
					cXTEAux += A270Tag( 4,"ans:identificacaoReembolso",allTrim( ( cAlias )->( B4N_IDEREE ) ),.T.,.T.,.T. )
				else
					cXTEAux += A270Tag( 4,"ans:identificacaoReembolso",'1',.T.,.T.,.T. )
				endIf

				if( ! empty( allTrim( ( cAlias )->( B4N_IDCOPR ) ) ) )
					cXTEAux += A270Tag( 4,"ans:identificacaoValorPreestabelecido",allTrim( ( cAlias )->( B4N_IDCOPR ) ),.T.,.T.,.T. )
				endIf

				nB4N_VLTINF := ( cAlias )->( B4N_VLTINF )
				nB4N_VLTGUI := ( cAlias )->( B4N_VLTGUI )
				nB4N_VLTPRO := ( cAlias )->( B4N_VLTPRO )
				If nB4N_VLTINF < nB4N_VLTGUI
					nB4N_VLTINF := nB4N_VLTGUI//Para evitar critica 1706 - VALOR APRESENTADO A MENOR
					nB4N_VLTPRO := nB4N_VLTGUI - ( cAlias )->( B4N_VLTGLO )
				EndIf

				aModelRem := tpModelRem( ( cAlias )->( B4N_CODRDA ) , !empty( allTrim( ( cAlias )->( B4N_IDCOPR ) ) ))
				if lAtuTiss4 .AND. aModelRem[1]									
					cXTEAux += A270Tag( 4,"ans:formasRemuneracao",'',.T.,.F.,.T. )
					cXTEAux += A270Tag( 5,"ans:formaRemuneracao",aModelRem[2],.T.,.T.,.T. )
					cXTEAux += A270Tag( 5,"ans:valorRemuneracao",allTrim( str( round( nB4N_VLTINF,2 ) ) ),.T.,.T.,.T.,.F. )
					cXTEAux += A270Tag( 4,"ans:formasRemuneracao",'',.F.,.T.,.T. )
				endif

				cXTEAux += A270Tag( 4,"ans:guiaSolicitacaoInternacao",allTrim( ( cAlias )->( B4N_SOLINT ) ),.T.,.T.,.F. )
			
				if( B4M->B4M_TISVER == "3.03.00" )//Esse tratamento foi realizado devido a sequencia das tags
					cXTEAux += A270Tag( 4,"ans:numeroGuiaSPSADTPrincipal",allTrim( ( cAlias )->( B4N_NMGPRI ) ),.T.,.T.,.F. )
					if( ! empty( ( cAlias )->( B4O_DATSOL ) ) )
						cXTEAux += A270Tag( 4,"ans:dataSolicitacao",convDataXML( ( cAlias )->( B4O_DATSOL ) ),.T.,.T.,.T. )
					endIf
				elseIf( B4M->B4M_TISVER >= "3.03.01" )
					if( ! empty( ( cAlias )->( B4O_DATSOL ) ) )
						cXTEAux += A270Tag( 4,"ans:dataSolicitacao",convDataXML( ( cAlias )->( B4O_DATSOL ) ),.T.,.T.,.T. )
					EndIf
					cXTEAux += A270Tag( 4,"ans:numeroGuiaSPSADTPrincipal",allTrim( ( cAlias )->( B4N_NMGPRI ) ),.T.,.T.,.F. )
				endIf

				If !Empty( (cAlias)->(B4O_DATAUT) )
					cXTEAux += A270Tag( 4,"ans:dataAutorizacao",convDataXML( ( cAlias )->( B4O_DATAUT ) ),.T.,.T.,.T. )
				EndIf
			
				if( ! empty( ( cAlias )->( B4O_DATREA ) ) )
					cXTEAux += A270Tag( 4,"ans:dataRealizacao",convDataXML( ( cAlias )->( B4O_DATREA ) ),.T.,.T.,.F. )
				endIf
			
				if( ! empty( ( cAlias )->( B4O_DTINFT ) ) )
					cXTEAux += A270Tag( 4,"ans:dataInicialFaturamento",convDataXML( ( cAlias )->( B4O_DTINFT ) ),.T.,.T.,.T. )
				endIf
			
				if( ! empty( ( cAlias )->( B4O_DTFIFT ) ) )
					cXTEAux += A270Tag( 4,"ans:dataFimPeriodo",convDataXML( ( cAlias )->( B4O_DTFIFT ) ),.T.,.T.,.F. )
				endIf
			
				if( ! empty( ( cAlias )->( B4O_DTPROT ) ) )
					cXTEAux += A270Tag( 4,"ans:dataProtocoloCobranca",convDataXML( ( cAlias )->( B4O_DTPROT ) ),.T.,.T.,.F. )
				endIf
			
				if( ! empty( ( cAlias )->( B4N_DTPAGT ) ) )
					cXTEAux += A270Tag( 4,"ans:dataPagamento",convDataXML( ( cAlias )->( B4N_DTPAGT ) ),.T.,.T.,.F. )
				endIf
			
				cXTEAux += A270Tag( 4,"ans:dataProcessamentoGuia",convDataXML( ( cAlias )->( B4N_DTPRGU ) ),.T.,.T.,.T. )
				cXTEAux += A270Tag( 4,"ans:tipoConsulta",allTrim( ( cAlias )->( B4O_TIPCON ) ),.T.,.T.,.F. )
				cCbosCnv := PLSGETVINC('BTU_CDTERM','BAQ',.F.,'24',ALLTRIM(( cAlias )->( B4O_CBOS )))
				if ( alltrim( (cAlias)->(B4N_TPEVAT)) $ "1,2" .and. (alltrim((cAlias)->(B4N_OREVAT)) $ "1,2,3" .or. Empty((cAlias)->(B4N_OREVAT)))  .and. alltrim((cAlias)->(B4O_TIPCON)) = "1")
					cXTEAux += A270Tag( 4,"ans:cboExecutante",allTrim(cCbosCnv),.T.,.T.,.F. )
				elseif (cCbosCnv != "999999" .and. !Empty(cCbosCnv))
					cXTEAux += A270Tag( 4,"ans:cboExecutante",allTrim(cCbosCnv),.T.,.T.,.F. )
				endif
				cXTEAux += A270Tag( 4,"ans:indicacaoRecemNato",allTrim( ( cAlias )->( B4N_INAVIV ) ),.T.,.T.,.F. )
				cXTEAux += A270Tag( 4,"ans:indicacaoAcidente",allTrim( ( cAlias )->( B4N_INDACI ) ),.T.,.T.,.F. )
				cXTEAux += A270Tag( 4,"ans:caraterAtendimento",allTrim( ( cAlias )->( B4N_TIPADM ) ),.T.,.T.,.F. )
				cXTEAux += A270Tag( 4,"ans:tipoInternacao",allTrim( ( cAlias )->( B4N_TIPINT ) ),.T.,.T.,.F. )
				cXTEAux += A270Tag( 4,"ans:regimeInternacao",allTrim( ( cAlias )->( B4N_REGINT ) ),.T.,.T.,.F. )
			
				if( ! empty( allTrim( ( cAlias )->( B4N_CODCID ) ) ) )
					cXTEAux += A270Tag( 4,"ans:diagnosticosCID10",'',.T.,.F.,.T. )
					cXTEAux += A270Tag( 5,"ans:diagnosticoCID",allTrim( substr(( cAlias )->( B4N_CODCID ),1,4) ),.T.,.T.,.F. )
					cXTEAux += A270Tag( 4,"ans:diagnosticosCID10",'',.F.,.T.,.T. )
				endIf
			
				cXTEAux += A270Tag( 4,"ans:tipoAtendimento",allTrim( ( cAlias )->( B4N_TIPATE ) ),.T.,.T.,.F. )
				if lAtuTiss4
					if !empty( ( cAlias )->( B4N_REGATE ) )
						cXTEAux += A270Tag( 4,"ans:regimeAtendimento",allTrim( ( cAlias )->( B4N_REGATE ) ),.T.,.T.,.F. )
					endif
					if !empty( ( cAlias )->( B4N_SAUOCU ) )
						cXTEAux += A270Tag( 4,"ans:saudeOcupacional",allTrim( ( cAlias )->( B4N_SAUOCU ) ),.T.,.T.,.F. )
					endif
				endif
				cXTEAux += A270Tag( 4,"ans:tipoFaturamento",allTrim( ( cAlias )->( B4N_TIPFAT ) ),.T.,.T.,.F. )
				cXTEAux += A270Tag( 4,"ans:diariasAcompanhante",allTrim( ( cAlias )->( B4N_DIAACP ) ),.T.,.T.,.F. )
				cXTEAux += A270Tag( 4,"ans:diariasUTI",allTrim( ( cAlias )->( B4N_DIAUTI ) ),.T.,.T.,.F. )
				cXTEAux += A270Tag( 4,"ans:motivoSaida",allTrim( ( cAlias )->( B4N_MOTSAI ) ),.T.,.T.,.F. )
				cXTEAux += A270Tag( 4,"ans:valoresGuia",'',.T.,.F.,.T. )
				cXTEAux += A270Tag( 5,"ans:valorTotalInformado",allTrim( str( round( nB4N_VLTINF,2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 5,"ans:valorProcessado",allTrim( str( round( nB4N_VLTPRO,2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 5,"ans:valorTotalPagoProcedimentos",allTrim( str( round( ( cAlias )->( B4N_VLTPGP ),2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 5,"ans:valorTotalDiarias",allTrim( str( round( ( cAlias )->( B4N_VLTDIA ),2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 5,"ans:valorTotalTaxas",allTrim( str( round( ( cAlias )->( B4N_VLTTAX ),2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 5,"ans:valorTotalMateriais",allTrim( str( round( ( cAlias )->( B4N_VLTMAT ),2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 5,"ans:valorTotalOPME",allTrim( str( round( ( cAlias )->( B4N_VLTOPM ),2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 5,"ans:valorTotalMedicamentos",allTrim( str( round( ( cAlias )->( B4N_VLTMED ),2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 5,"ans:valorGlosaGuia",allTrim( str( round( ( cAlias )->( B4N_VLTGLO ),2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 5,"ans:valorPagoGuia",allTrim( str( round( nB4N_VLTGUI,2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 5,"ans:valorPagoFornecedores",allTrim( str( round( ( cAlias )->( B4N_VLTFOR ),2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 5,"ans:valorTotalTabelaPropria",allTrim( str( round( ( cAlias )->( B4N_VLTTBP ),2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 5,"ans:valorTotalCoParticipacao",allTrim( str( round( ( cAlias )->( B4N_VLTCOP ),2 ) ) ),.T.,.T.,.T.,.F. )
				cXTEAux += A270Tag( 4,"ans:valoresGuia",'',.F.,.T.,.T. )
				
				aNRDCNV 	:= StrTokArr( allTrim( ( cAlias )->( B4N_NRDCNV ) ), "," )	
				for nNV := 1 to len(aNRDCNV)					
					cXTEAux += A270Tag( 4,"ans:declaracaoNascido",allTrim( substr(cvaltochar(val(aNRDCNV[nNV])),1,11) ),.T.,.T.,.F. )
				next				
				cXTEAux += A270Tag( 4,"ans:declaracaoObito",allTrim( ( cAlias )->( B4N_NRDCOB ) ),.T.,.T.,.F. )

				/* Procedimentos da Guia - inicio */
							
				cCodTab		:= "" //Codigo da tabela
				cCodGru		:= "" //Codigo do grupo
				cCodPro		:= "" //Codigo do procedimento
				cCNPJFn		:= "" //CNPJ do fornecedor
				nQtdInf		:= 0 //Quantidade informada
				nVlrInf		:= 0 //Valor informado
				nQtdPag		:= 0 //Quantidade paga
				nVlrPag		:= 0 //Valor pago
				nVlrPgFn		:= 0 //Valor pago ao fornecedor
				nVlrCoPar	:= 0 //Valor de coparticipacao
				
				cItemGuia := ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4O_DATREA+B4O_CODGRU+B4O_CODTAB+B4O_CODPRO+B4O_CDDENT+B4O_CDFACE+B4O_CDREGI+B4N_CODRDA)
				fWrite( nArqGui,cXTEAux )
				cXTEAux := ""
				cXTEPac := ""

				while ( cAlias )->( !eof() ) .And. cGuia == ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4N_CODRDA) 
			
					//Quando for pacote eu atualizo os valores apenas uma vez para o procedimento
					If Empty(( cAlias )->( B4U_CDTBIT )) .Or. (cChvPct <> cItemGuia) .Or. cItemGuia <> ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4O_CODGRU+B4O_DATREA+B4O_CODTAB+B4O_CODPRO+B4O_CDDENT+B4O_CDFACE+B4O_CDREGI+B4N_CODRDA)
					
						nQtdInf		+= ( cAlias )->( B4O_QTDINF )
						nVlrInf		+= ( cAlias )->( B4O_VLRINF )
						
						nVlrPag		+= ( cAlias )->( B4O_VLPGPR )
						nQtdPag		+= Iif( nVlrPag > 0, ( cAlias )->( B4O_QTDPAG ) , 0 )
						
						nVlrPgFn	+= ( cAlias )->( B4O_VLRPGF )
						nVlrCoPar	+= ( cAlias )->( B4O_VLRCOP )
						cCdTbPc		:= AllTrim(( cAlias )->( B4U_CDTBIT ))
						cCdPrPc		:= AllTrim(( cAlias )->( B4U_CDPRIT ))
						nQtPrPc		:= ( cAlias )->( B4U_QTPRPC )
						cChvPct		:= cItemGuia
						
					EndIf

					if( allTrim( ( cAlias )->( B4O_CODTAB ) ) $ "18|19|20|22|90|98|00" )
						cCodTab := AllTrim( ( cAlias )->( B4O_CODTAB ) )
					else
						cCodTab := '22'
					endIf
		
					cCdDent	:= allTrim( ( cAlias )->( B4O_CDDENT ) )
					cCdRegi	:= allTrim( ( cAlias )->( B4O_CDREGI ) )
					cCdFace	:= allTrim( ( cAlias )->( B4O_CDFACE ) )
					cCodGru := AllTrim( ( cAlias )->( B4O_CODGRU ) )
					cCodPro := AllTrim( ( cAlias )->( B4O_CODPRO ) )			
					cCNPJFn := AllTrim( ( cAlias )->( B4O_CNPJFR ) )
						
					//Mudou o item
					If Empty(cPrimItem) .Or. cItemGuia <> ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4O_CODGRU+B4O_DATREA+B4O_CODTAB+B4O_CODPRO+B4O_CDDENT+B4O_CDFACE+B4O_CDREGI+B4N_CODRDA)
					
						cPrimItem := cItemGuia
						cItemGuia := ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4O_DATREA+B4O_CODGRU+B4O_CODTAB+B4O_CODPRO+B4O_CDDENT+B4O_CDFACE+B4O_CDREGI+B4N_CODRDA)
						cXTEAux += A270Tag( 4,"ans:procedimentos",'',.T.,.F.,.T. )
						cXTEAux += A270Tag( 5,"ans:identProcedimento",'',.T.,.F.,.T. )
						cXTEAux += A270Tag( 6,"ans:codigoTabela",cCodTab,.T.,.T.,.T. )			
						cXTEAux += A270Tag( 6,"ans:Procedimento",'',.T.,.F.,.T. )
			
						if ! empty(cCodGru)
							cXTEAux += A270Tag( 7,"ans:grupoProcedimento",cCodGru,.T.,.T.,.T. )
						else
							cXTEAux += A270Tag( 7,"ans:codigoProcedimento",cCodPro,.T.,.T.,.T. )
						endIf

						cXTEAux += A270Tag( 6,"ans:Procedimento",'',.F.,.T.,.T. )
						cXTEAux += A270Tag( 5,"ans:identProcedimento",'',.F.,.T.,.T. )
			
						if( ! empty( cCdDent ) )
							cXTEAux += A270Tag( 5,"ans:denteRegiao",'',.T.,.F.,.T. )
							cXTEAux += A270Tag( 6,"ans:codDente",cCdDent,.T.,.T.,.T. )
							cXTEAux += A270Tag( 5,"ans:denteRegiao",'',.F.,.T.,.T. )
						endIf
						
						if( ! empty( cCdRegi ) ) .And. ( empty( cCdDent ) )
							cXTEAux += A270Tag( 5,"ans:denteRegiao",'',.T.,.F.,.T. )							
							cXTEAux += A270Tag( 6,"ans:codRegiao",cCdRegi,.T.,.T.,.T. )
							cXTEAux += A270Tag( 5,"ans:denteRegiao",'',.F.,.T.,.T. )
						endIf			
						cXTEAux += A270Tag( 5,"ans:denteFace",cCdFace,.T.,.T.,.F. )

						If nB4N_VLTINF == 0 .And. nVlrInf > 0//Se zerei o cabecalho devo zerar tambem os itens por causa da critica 1706 - VALOR APRESENTADO A MENOR
							nVlrInf := nVlrPag
							nQtdInf := nQtdInf
						EndIf
						cXTEAux += A270Tag( 5,"ans:quantidadeInformada",allTrim( str( nQtdInf ) ),.T.,.T.,.T.,.F. )
						cXTEAux += A270Tag( 5,"ans:valorInformado",allTrim( str( round( nVlrInf,2 ) ) ),.T.,.T.,.T.,.F. )
						cXTEAux += A270Tag( 5,"ans:quantidadePaga",allTrim( str( nQtdPag ) ),.T.,.T.,.T.,.F. )
						if lAtuTiss4
							if !empty( ( cAlias )->( B4O_CODUNM ) )
								cXTEAux += A270Tag( 5,"ans:unidadeMedida", ( cAlias )->( B4O_CODUNM ),.T.,.T.,.T.,.F. )
							endif
						endif
						cXTEAux += A270Tag( 5,"ans:valorPagoProc",allTrim( str( round( nVlrPag,2 ) ) ),.T.,.T.,.T.,.F. )
						cXTEAux += A270Tag( 5,"ans:valorPagoFornecedor",allTrim( str( round( nVlrPgFn,2 ) ) ),.T.,.T.,.T.,.F. )
						cXTEAux += A270Tag( 5,"ans:CNPJFornecedor",allTrim( cCNPJFn ),.T.,.T.,.F. )
						cXTEAux += A270Tag( 5,"ans:valorCoParticipacao",allTrim( str( round( nVlrCoPar,2 ) ) ),.T.,.T.,.T.,.F. )
						
						cCodGru := AllTrim( ( cAlias )->( B4O_CODGRU ) )
						cCodPro := AllTrim( ( cAlias )->( B4O_CODPRO ) )			
						cCNPJFn := AllTrim( ( cAlias )->( B4O_CNPJFR ) )
						cCdDent	:= allTrim( ( cAlias )->( B4O_CDDENT ) )
						cCdRegi	:= allTrim( ( cAlias )->( B4O_CDREGI ) )
						cCdFace	:= allTrim( ( cAlias )->( B4O_CDFACE ) )
						nQtdInf	:= 0
						nVlrInf	:= 0
						nQtdPag	:= 0
						nVlrPag	:= 0
						nVlrPgFn := 0
						nVlrCoPar := 0
						fWrite( nArqGui,cXTEAux )
						cXTEAux := ""

					EndIf//If cItemGuia <> ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4O_DATREA+B4O_CODGRU+B4O_CODTAB+B4O_CODPRO+B4O_CDDENT+B4O_CDFACE+B4O_CDREGI+B4N_CODRDA)
					
					While ( cAlias )->( !eof() ) .And. cItemGuia == ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4O_DATREA+B4O_CODGRU+B4O_CODTAB+B4O_CODPRO+B4O_CDDENT+B4O_CDFACE+B4O_CDREGI+B4N_CODRDA)
					
						If cItePct <> AllTrim(( cAlias )->(B4U_CDTBPC+B4U_CDPRIT))

							cXTEAux += A270Tag( 5,"ans:detalhePacote"			, ''														, .T.,.F.,.T. )
							cXTEAux += A270Tag( 6,"ans:codigoTabela"			, AllTrim(( cAlias )->( B4U_CDTBIT ))			, .T.,.T.,.F.,.F. )
							cXTEAux += A270Tag( 6,"ans:codigoProcedimento"	, AllTrim(( cAlias )->( B4U_CDPRIT ))			, .T.,.T.,.F.,.F. )
							cXTEAux += A270Tag( 6,"ans:quantidade"				, AllTrim(Str(( cAlias )->( B4O_QTDPAG )))	, .T.,.T.,.F.,.F. )
							cXTEAux += A270Tag( 5,"ans:detalhePacote"			, ''														, .F.,.T.,.T. )
							cItePct := ( cAlias )->(B4U_CDTBPC+B4U_CDPRIT)
							
						Else
							( cAlias )->( dbSkip() )
							Exit
						EndIf
					
						( cAlias )->( dbSkip() )
					
					EndDo
					
					If cItemGuia <> ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4O_DATREA+B4O_CODGRU+B4O_CODTAB+B4O_CODPRO+B4O_CDDENT+B4O_CDFACE+B4O_CDREGI+B4N_CODRDA)
						cItePct := ""
						cXTEAux += A270Tag( 4,"ans:procedimentos",'',.F.,.T.,.T. )
					EndIf
					
					If cGuia <> ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4N_CODRDA)
						Exit//Trocou a guia
					EndIf

				EndDo 

				/* Procedimentos da Guia - termino */
			
				cXTEAux += A270Tag( 3,"ans:guiaMonitoramento",'',.F.,.T.,.T. )
				fWrite( nArqGui,cXTEAux )
				cXTEAux := ""

			EndIf//If cGuia <> ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4N_CODRDA)
			
			/*Dados da guia - termino*/

			If cGuia == ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4N_CODRDA)
				( cAlias )->( dbSkip() )
			EndIf

	 EndDo//while( ( cAlias )->( !eof() ) )
		( cAlias )->( dbCloseArea() )
	ElseIf nTipEnv == 2//Fornecimento Direto		

		cAlias	:= getGuias(.t.)
		procRegua( ( cAlias )->( recCount() ) )
		
		while( ( cAlias )->( !eof() ) )
			if lEnd
				alert( 'Execução cancelada pelo usuário.' )
				exit
			endif
			incProc( "Gerando dados para o arquivo de envio" )

			cXTEAux := ""
			cPrimItem := ""
			cXTEAux += A270Tag( 3,"ans:fornecimentoDiretoMonitoramento",'',.T.,.F.,.T. )
			cXTEAux += A270Tag( 4,"ans:tipoRegistro",allTrim( ( cAlias )->( B4N_TPRGMN ) ),.T.,.T.,.T. )
			cXTEAux += A270Tag( 4,"ans:dadosBeneficiario",'',.T.,.F.,.T. )
			cXTEAux += A270Tag( 5,"ans:identBeneficiario",'',.T.,.F.,.T. )			
			
			cXTEAux += A270Tag( 6,"ans:dadosSemCartao",'',.T.,.F.,.T. )
			cXTEAux += A270Tag( 7,"ans:numeroCartaoNacionalSaude",allTrim( ( cAlias )->( B4N_NUMCNS ) ),.T.,.T.,.F. )
						
			cXTEAux += A270Tag( 7,"ans:sexo",allTrim( ( cAlias )->( B4N_SEXO ) ),.T.,.T.,.T. )
			cXTEAux += A270Tag( 7,"ans:dataNascimento",convDataXML( ( cAlias )->( B4N_DATNAS ) ),.T.,.T.,.T. )
			cXTEAux += A270Tag( 7,"ans:municipioResidencia",allTrim( ( cAlias )->( B4N_CDMNRS ) ),.T.,.T.,.T. )
			cXTEAux += A270Tag( 6,"ans:dadosSemCartao",'',.F.,.T.,.T. )			            
			cXTEAux += A270Tag( 5,"ans:identBeneficiario",'',.F.,.T.,.T. )
			cXTEAux += A270Tag( 5,"ans:numeroRegistroPlano",allTrim( ( cAlias )->( B4N_SCPRPS ) ),.T.,.T.,.T. )
			cXTEAux += A270Tag( 4,"ans:dadosBeneficiario",'',.F.,.T.,.T.)			
			cXTEAux += A270Tag( 4,"ans:identificacaoFornecimentoDireto",( cAlias )->B4N_NMGPRE,.T.,.T.,.T. )
			cXTEAux += A270Tag( 4,"ans:dataFornecimento",convDataXML( ( cAlias )->( B4N_DTPRGU ) ),.T.,.T.,.T. )
			cXTEAux += A270Tag( 4,"ans:valorTotalFornecimento",allTrim( str( round( ( cAlias )->B4N_VLTGUI ,2 ) ) ),.T.,.T.,.T.,.F. )
			cXTEAux += A270Tag( 4,"ans:valorTotalTabelaPropria",allTrim( str( round( ( cAlias )->( B4N_VLTTBP ),2 ) ) ),.T.,.T.,.T.,.F. )
			cXTEAux += A270Tag( 4,"ans:valorTotalCoParticipacao",allTrim( str( round( ( cAlias )->( B4N_VLTCOP ),2 ) ) ),.T.,.T.,.T.,.F. )				

			If Empty(cPrimItem) .Or. cItemGuia <> ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE)
				cItemGuia := ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE)
				while ( cAlias )->( !eof() ) .and. cItemGuia == ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE)
					if( allTrim( ( cAlias )->( B4O_CODTAB ) ) $ "18|19|20|22|90|98|00" )
						cCodTab := AllTrim( ( cAlias )->( B4O_CODTAB ) )
					else
						cCodTab := '22'
					endIf

					cPrimItem := cItemGuia
					cCodGru := AllTrim( ( cAlias )->( B4O_CODGRU ) )
					cCodPro := AllTrim( ( cAlias )->( B4O_CODPRO ) )
					
					cXTEAux += A270Tag( 4,"ans:procedimentos",'',.T.,.F.,.T. )
					cXTEAux += A270Tag( 5,"ans:identProcedimento",'',.T.,.F.,.T. )
					cXTEAux += A270Tag( 6,"ans:codigoTabela",cCodTab,.T.,.T.,.T. )			
					cXTEAux += A270Tag( 6,"ans:procedimento",'',.T.,.F.,.T. )							
					if ! empty(cCodGru)
						cXTEAux += A270Tag( 7,"ans:grupoProcedimento",cCodGru,.T.,.T.,.T. )
					else
						cXTEAux += A270Tag( 7,"ans:codigoProcedimento",cCodPro,.T.,.T.,.T. )
					endIf
					cXTEAux += A270Tag( 6,"ans:procedimento",'',.F.,.T.,.T. )	
                	cXTEAux += A270Tag( 5,"ans:identProcedimento",'',.F.,.T.,.T. )			
					cXTEAux += A270Tag( 5,"ans:quantidadeFornecida",allTrim( str( ( cAlias )->( B4O_QTDINF ) ) ),.T.,.T.,.T.,.F. )				
					cXTEAux += A270Tag( 5,"ans:valorFornecido",allTrim( str( round( ( cAlias )->( B4O_VLPGPR ),2 ) ) ),.T.,.T.,.T.,.F. )
					cXTEAux += A270Tag( 5,"ans:valorCoParticipacao",allTrim( str( round( ( cAlias )->( B4O_VLRCOP ),2 ) ) ),.T.,.T.,.T.,.F. )
					cXTEAux += A270Tag( 4,"ans:procedimentos",'',.F.,.T.,.T. )

					cItemGuia := ( cAlias )->(B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE)
					( cAlias )->( dbSkip() )					
				enddo
			else
				( cAlias )->( dbSkip() )
			endIf
				
			cXTEAux += A270Tag( 3,"ans:fornecimentoDiretoMonitoramento",'',.F.,.T.,.T. )

			fWrite( nArqGui,cXTEAux )
			cXTEAux := ""
		enddo
		( cAlias )->( dbCloseArea() )

	ElseIf nTipEnv == 4//Valor preestabelecido

		procRegua( -1 )
		cXTEAux := ""
		cXTEAux := geraConPree(nArqGui)

	EndIf//If nTpProc == 1 - Guias monitoramento
		
	cXTEAux += A270Tag( 2,"ans:operadoraParaANS",'',.F.,.T.,.T. )
	cXTEAux += A270Tag( 1,"ans:Mensagem",'',.F.,.T.,.T. )
	fWrite( nArqGui,cXTEAux )
	fClose( nArqGui )

endIf//if( nArqGui == -1 )

return cFileGUI

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getGuias
Consulta ao banco de dados

@author    Jonatas Almeida
@version   1.xx
@since     1/09/2016

@return    cAlias = retorna consulta
/*/
//------------------------------------------------------------------------------------------
static function getGuias(lFornec)
	local cAlias := criaTrab( nil,.F. )
	local cWhere := ""
	local cRdaProp	:= GetNewPar("MV_RDAPROP","")
	default lFornec := .f.

	cWhere	:= "%B4M.B4M_SUSEP = '"+ B4M->( B4M_SUSEP ) +"' AND "
	cWhere	+= "B4M.B4M_CMPLOT = '"+ B4M->( B4M_CMPLOT ) +"' AND "
	cWhere	+= "B4M.B4M_NUMLOT = '"+ B4M->( B4M_NUMLOT ) +"' AND " 
	if lFornec
		cWhere	+= "B4N.B4N_CODRDA = '"+ cRdaProp +"'%"
	else
		cWhere	+= "B4N.B4N_CODRDA <> '" + cRdaProp +"'%"
	endif	
	
	beginSQL Alias cAlias
		SELECT B4N_SUSEP,B4N_CMPLOT,B4N_NUMLOT,B4N_CODRDA, 
			B4N_CDMNEX,B4N_CDMNRS,B4N_CNES,B4N_CODCID,B4N_DATNAS,B4N_DIAACP,B4N_DTPRGU,B4N_FORENV,
			B4N_IDEREE,B4N_INAVIV,B4N_INDACI,B4N_MOTSAI,B4N_NMGOPE,B4N_NMGPRE,B4N_NMGPRI,B4N_NRDCNV,
			B4N_NRDCOB,B4N_NUMCNS,B4N_OREVAT,B4N_REGINT,B4N_RGOPIN,B4N_SCPRPS,B4N_SEXO,B4N_SOLINT,
			B4N_TIPADM,B4N_TIPATE,B4N_TIPFAT,B4N_TIPINT,B4N_TPEVAT,B4N_TPRGMN,B4N_VLTCOP,B4N_VLTDIA,
			B4N_VLTFOR,B4N_VLTGLO,B4N_VLTGUI,B4N_VLTINF,B4N_VLTMAT,B4N_VLTMED,B4N_VLTOPM,B4N_VLTPGP,
			B4N_VLTPRO,B4N_VLTTAX,B4N_VLTTBP,B4N_VTISPR,B4N_DTPAGT,B4N_DIAUTI,B4N_IDCOPR,
			
			B4O_CBOS,B4O_CDDENT,B4O_CDFACE,B4O_CDREGI,B4O_CNPJFR,B4O_CODGRU,B4O_CODPRO,B4O_CODTAB,
			B4O_CPFCNP,B4O_DATAUT,B4O_DATREA,B4O_DATSOL,B4O_DIAUTI,B4O_DTFIFT,B4O_DTINFT,B4O_DTPAGT,
			B4O_DTPROT,B4O_IDEEXC,B4O_QTDINF,B4O_QTDPAG,B4O_TIPCON,B4O_VLPGPR,B4O_VLRCOP,B4O_VLRINF,
			B4O_VLRPGF,B4U_CDTBPC,B4U_CDPRIT,B4U_QTPRPC,B4U_CDTBIT, B4N_REGATE, B4N_SAUOCU, B4N_CPFUSR, B4O_CODUNM

		FROM
			%table:B4M% B4M INNER JOIN
			%table:B4N% B4N ON //B4N_FILIAL+B4N_SUSEP+B4N_CMPLOT+B4N_NUMLOT+B4N_NMGOPE+B4N_CODRDA
				B4N.B4N_FILIAL	= B4M.B4M_FILIAL AND
				B4N.B4N_SUSEP	= B4M.B4M_SUSEP AND
				B4N.B4N_CMPLOT	= B4M.B4M_CMPLOT AND
				B4N.B4N_NUMLOT	= B4M.B4M_NUMLOT AND
				B4N.%notDel% INNER JOIN
			%table:B4O% B4O ON //B4O_FILIAL+B4O_SUSEP+B4O_CMPLOT+B4O_NUMLOT+B4O_NMGOPE+B4O_CODGRU+B4O_CODTAB+B4O_CODPRO+B4O_CODRDA
				B4O.B4O_FILIAL	= B4N.B4N_FILIAL AND
				B4O.B4O_SUSEP	= B4N.B4N_SUSEP AND
				B4O.B4O_CMPLOT	= B4N.B4N_CMPLOT AND
				B4O.B4O_NUMLOT	= B4N.B4N_NUMLOT AND
				B4O.B4O_NMGOPE	= B4N.B4N_NMGOPE AND
				B4O.B4O_CODRDA = B4N.B4N_CODRDA AND
				B4O.%notDel% LEFT JOIN
			%table:B4U% B4U ON
				B4U.B4U_FILIAL	= B4O.B4O_FILIAL AND
				B4U.B4U_SUSEP	= B4O.B4O_SUSEP AND
				B4U.B4U_CMPLOT	= B4O.B4O_CMPLOT AND
				B4U.B4U_NUMLOT	= B4O.B4O_NUMLOT AND
				B4U.B4U_NMGOPE	= B4O.B4O_NMGOPE AND                 
				B4U.B4U_CDTBPC = B4O.B4O_CODTAB AND
				B4U.B4U_CDPRPC = B4O.B4O_CODPRO AND
				B4U.%notDel%
		WHERE
			B4M.B4M_FILIAL = %xFilial:B4M% AND
			%exp:cWhere% AND
			B4M.%notDel% 			
		ORDER BY 
			B4N_SUSEP,B4N_CMPLOT,B4N_NUMLOT,B4N_NMGOPE,B4N_CODRDA,B4O_CODPRO

	endSQL
	
	( cAlias )->( dbGoTop() )
return cAlias

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
		msgInfo( "O arquivo " + cHashFile + " não foi encontrado ou não está acessível." + CRLF + "Hash do arquivo não pode ser calculado!" )
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
static function validXML( cXML,cXSD,cArqFinal,aLog,cFileXTE )
	local cError	:= ""
	local cWarning	:= ""
	local aErrors	:= { }
	local lRet		:= .F.

	//--< Valida um arquivo XML com o XSD >--
	if( xmlFVldSch( cXML,cXSD,@cError,@cWarning ) )
		lRet := .T.
	endIf

	if( !lRet )		
		geraLogErro( cError,cArqFinal,@aLog,cFileXTE )		
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
static function geraLogErro( cError,cArqFinal,aLog,cFileXTE )
	local cMascara	:= "Arquivos .LOG | *.log"
	local cTitulo	:= "Selecione o local"
	local nMascpad	:= 0
	local cRootPath	:= ""
	local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
	//local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
	//local l3Server	:= .T.	//.T. = apresenta o árvore do servidor || .F. = não apresenta
	local cConfArq	:= "_" + dtos( date() ) + "_" + strTran( allTrim( time() ),":","" )
	local cFileLOG	:= strtran(cFileXTE,".xte","") + cConfArq + "_CRITICADO.log" //+ "_CRITICADO.log"
	local cPathLOG	:= ""	
	local nArqLog	:= 0	

	cNomLogErr := ""
	cNomLogErr := cConfArq
	cPathLOG	:= cArqFinal
	nArqLog		:= fCreate( cPathLOG+cFileLOG,FC_NORMAL )
	
	aadd(aLog,{"[" + B4M->B4M_CMPLOT + "]" + B4M->B4M_NUMLOT, "Existem erros na validação do arquivo XML " + cPathLOG + cFileLOG})
	fWrite( nArqLog,cError )
	fClose( nArqLog )
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} FlgGuias
Caso a geração do arquivo não contenha erros será gravado um Flag nas guias BD5/BE4 para marcar se ja foram enviadas
@author    Lucas Nonato
@since     09/09/2016
/*/
//------------------------------------------------------------------------------------------
Static Function flgGuias( cLote,cComp,cSusep )
Local cAliasFlg	:= criaTrab( nil,.F. )
Local cAliasGui	:= ""
Local cCodInt	:= ""
Local cLotGrv	:= ""
Local lCont		:= .T.
//TODO Essa função não deve existir na central de obrigações.

BeginSql Alias cAliasFlg
	SELECT
	B4N_CODOPE, B4N_CODLDP, B4N_CODPEG, B4N_NUMERO, B4N_TPEVAT, B4N_TPRGMN, B4N_DTPAGT
	FROM
	%table:B4N% B4N 	/*Guias*/
	WHERE
	B4N_FILIAL	= %xfilial:B4N% AND
	B4N_SUSEP 	= %exp:cSusep% AND
	B4N_CMPLOT	= %exp:cComp% AND
	B4N_NUMLOT	= %exp:cLote% AND
	B4N.%notDel%
EndSql

cDebug := getLastQuery()[ 2 ]	//Para debugar a query

BD5->( dbSetOrder( 1 ) ) // BD5_FILIAL, BD5_CODOPE, BD5_CODLDP, BD5_CODPEG, BD5_NUMERO, BD5_SITUAC, BD5_FASE, BD5_DATPRO, BD5_OPERDA, BD5_CODRDA,
BE4->( dbSetOrder( 1 ) ) // BE4_FILIAL, BE4_CODOPE, BE4_CODLDP, BE4_CODPEG, BE4_NUMERO, BE4_SITUAC, BE4_FASE
BA0->( dbSetOrder( 5 ) ) // BA0_FILIAL, BA0_SUSEP, R_E_C_N_O_, D_E_L_E_T_

if( BA0->( dbSeek( xFilial( "BA0" ) + allTrim( cSusep ) ) ) )
	cCodInt := BA0->( BA0_CODIDE + BA0_CODINT )
else
	msgInfo( "Operadora não encontrada: " + cSusep )
	lCont := .F.
endIf

if( lCont )
	cLotGrv :=  cComp + cLote 
	
	//Quando estiver gerando o arquivo como exclusão atualizar BE4/BD5_LOTMOE com o numero do lote gerado
	//Quando estiver gerando o arquivo como inclusão / alteração atualizar BE4/BD5_LOTMOP com o numero do lote gerado
	while( ( cAliasFlg )->( !eof() ) )
		cAliasGui := iif( allTrim( (cAliasFlg)->( B4N_TPEVAT ) ) == "3","BE4","BD5" )
		
		if( ( cAliasGui )->( dbSeek( xFilial( cAliasGui ) + cCodInt + ( cAliasFlg )->( B4N_CODLDP + B4N_CODPEG + B4N_NUMERO ) ) ) )
			if( ( cAliasFlg )->B4N_TPRGMN == '3' )
				( cAliasGui )->( recLock( cAliasGui,.F.) )
				( cAliasGui )->&( cAliasGui + "_LOTMOE" ) := cLotGrv
				( cAliasGui )->&( cAliasGui + "_LOTMOP" ) := ""
				( cAliasGui )->&( cAliasGui + "_LOTMOF" ) := ""
				( cAliasGui )->( msUnlock() )
			else
				( cAliasGui )->( recLock( cAliasGui,.F. ) )
				If Empty( (cAliasFlg)->(B4N_DTPAGT) ) 
					( cAliasGui )->&( cAliasGui + "_LOTMOP" ) := cLotGrv
				Else
					( cAliasGui )->&( cAliasGui + "_LOTMOF" ) := cLotGrv
				EndIf
				( cAliasGui )->( msUnlock() )
			endIf
		endIf
		
		( cAliasFlg )->( dbSkip() )
	endDo
	
	( cAliasFlg )->( dbCloseArea() )
endIf
return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} getVerTISS
Retorna versao TISS Prestador

@author    Jonatas Almeida
@version   1.xx
@since     13/10/2016
@param     cVersao = versao TISS

/*/
//------------------------------------------------------------------------------------------
static function getVerTISS( cVersao, oHMTISS )
local aRet := {}
local cRet := ""

if HMGet( oHMTISS , cVersao, @aRet ) .and. len(aRet) > 0
	cRet := aRet[1][2]
elseif HMGet( oHMTISS , "0"+cVersao, @aRet ) .and. len(aRet) > 0
	cRet := aRet[1][2]
endif

return cRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} geraConPree
Gera XML/XTE de contratos preestabelecido

@author    timoteo.bega
@since     01/05/2011
/*/
//------------------------------------------------------------------------------------------
Static Function geraConPree(nArqGui)
Local cSql				:= ""
Local cXTEAux			:= ""
Local cAliSql			:= criaTrab( nil,.F. )
Default nArqGui			:= 0

If nArqGui > 0

	cSql := " SELECT B8O_IDCOPR, B8O_VLRCON, B8O_VIGINI, B8O_VIGFIM, BAU_NREDUZ, BAU_TIPPE, BAU_CPFCGC, BAU_MUN, B8O.R_E_C_N_O_ FROM " + RetSqlName("B8O") + " B8O "	
	cSql += " INNER JOIN " + RetSqlName("B8Q") + " B8Q ON "
	cSql += "    B8Q_FILIAL = B8O_FILIAL AND B8Q_IDCOPR = B8O_IDCOPR AND"
	cSql += "    B8Q_SUSEP  = '" + B4M->( B4M_SUSEP )  + "' AND "
	cSql += "    B8Q_CMPLOT = '" + B4M->( B4M_CMPLOT ) + "' AND "
	cSql += "    B8Q_NUMLOT = '" + B4M->( B4M_NUMLOT ) + "' AND " 
	cSql += "    B8Q.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("BAW") + " BAW ON "
	cSql += "    BAW_FILIAL = '" + xFilial("BAW") + "' AND "
	cSql += "    BAW_CODINT = '" + PLSINTPAD() + "' AND "
	cSql += "    BAW_CODIGO = B8O_CODRDA AND "
	cSql += "    BAW.D_E_L_E_T_ = ' ' "
	cSql += " INNER JOIN " + RetSqlName("BAU") + " BAU ON "
	cSql += "    BAU_FILIAL = '" + xFilial("BAU") + "' AND "
	cSql += "    BAU_CPFCGC = B8Q_CPFCNP AND "
	cSql += "    BAU.D_E_L_E_T_ = ' ' "
	cSql += " WHERE B8O_FILIAL = '" + xFilial("B8O") + "' AND " 
	cSql += "    B8O_CODINT = BAW_CODINT AND B8O_CODRDA = BAU_CODIGO AND "
	cSql += "    B8O_VIGINI <= '" + B4M->B4M_CMPLOT + "01' AND (B8O_VIGFIM <= '" + B4M->B4M_CMPLOT + "31' OR B8O_VIGFIM = ' ') AND B8O.D_E_L_E_T_ = ' '"
	
	If PLSM270QRY(cSql,cAliSql)

		While !(cAliSql)->(Eof())
		
			cXTEAux += A270Tag( 3,"ans:valorPreestabelecidoMonitoramento",'',.T.,.F.,.T. )

			cXTEAux += A270Tag( 4,"ans:tipoRegistro","1",.T.,.T.,.T. )
			cXTEAux += A270Tag( 4,"ans:competenciaCoberturaContratada",B4M->B4M_CMPLOT,.T.,.T.,.T. )
			
			cXTEAux += A270Tag( 4,"ans:dadosPrestador",'',.T.,.F.,.T. )
			cXTEAux += A270Tag( 5,"ans:CNES","9999999",.T.,.T.,.T. )
			cXTEAux += A270Tag( 5,"ans:identificadorPrestador",Iif((cAliSql)->BAU_TIPPE == "F","2","1"),.T.,.T.,.T. )
			cXTEAux += A270Tag( 5,"ans:codigoCNPJ_CPF",AllTrim((cAliSql)->BAU_CPFCGC),.T.,.T.,.T. )
			cXTEAux += A270Tag( 5,"ans:municipioPrestador",AllTrim((cAliSql)->BAU_MUN),.T.,.T.,.T. )
			cXTEAux += A270Tag( 4,"ans:dadosPrestador",'',.F.,.T.,.T. )
			
			cXTEAux += A270Tag( 4,"ans:identificacaoValorPreestabelecido",AllTrim((cAliSql)->B8O_IDCOPR),.T.,.T.,.T. )
			cXTEAux += A270Tag( 4,"ans:valorPreestabelecido",AllTrim(Str( Round((cAliSql)->B8O_VLRCON,2) )),.T.,.T.,.T.,.F. )

			cXTEAux += A270Tag( 3,"ans:valorPreestabelecidoMonitoramento",'',.F.,.T.,.T. )
			
			aadd(aRecAtu, (cAliSql)->R_E_C_N_O_)

			(cAliSql)->(dbSkip())

		EndDo

	EndIf
	(cAliSql)->(dbCloseArea())

EndIf

Return cXTEAux						 


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} AtuB8ODef
Atualiza o flag na B8O, indicando que foi gerado o XML definitivo, para não sair nos outros meses
@since     10/2019
/*/
//------------------------------------------------------------------------------------------
Static Function AtuB8ODef(cValor)
local nI 		:= 0
default cValor 	:= "1"

for nI := 1 to len(aRecAtu)
	B8O->( dbGoTo(aRecAtu[nI]) )
	B8O-> (recLock("B8O", .f.))
		B8O->B8O_ENVMON := cValor
	B8O->(msUnlock())
next
aRecAtu := {}
return

//-------------------------------------------------------------------
/*/{Protheus.doc} setVerTiss
Seta versão tiss em hashmap
@author Lucas Nonato
@since  05/03/2020
@version P12
/*/
static function setVerTiss(oHMTISS)
local aDados 	:= {}
local cSql 		:= ""

cSql := " SELECT BTQ_DESTER, BTQ_CDTERM FROM " + RetSqlName("BTQ")
cSql += " WHERE BTQ_FILIAL = '" + xFilial("BTQ") + "' "
cSql += " AND BTQ_CODTAB = '69' "
cSql += " AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cSql),"TMPBTQ",.F.,.T.)	

while !TMPBTQ->(eof())
	if aScan( aDados,{| x | allTrim( x[ 1 ] ) == alltrim(TMPBTQ->BTQ_DESTER) } ) <= 0
		aadd(aDados, {alltrim(TMPBTQ->BTQ_DESTER), strzero(val(TMPBTQ->BTQ_CDTERM),3)})
	endif
	TMPBTQ->(dbSkip())
enddo

TMPBTQ->(dbclosearea())
oHMTISS := aToHM(aDados,1)

return oHMTISS

//-------------------------------------------------------------------
/*/{Protheus.doc} tpModelRem
Processamento para Modelo de Remuneração
@author Eduardo Bento
@since  08/2022
@version P12
/*/
function tpModelRem (cRda,lCapt)
local lRet			:= .f.
local cModeloRem	:= "01"
default cRda		:= "" 
default lCapt		:= .f. 

BA0->(dbSetOrder(1))
BA0->(msseek(xFilial("BA0") + PLSINTPAD() ))

BAU->(dbSetOrder(1))
if BAU->(msseek(xFilial("BAU") + cRda))
	if BAU->BAU_COPCRE $ '1,2,3' .and. BAU->BAU_CPFCGC != BA0->BA0_CGC
	//BAU_COPCRE -> 1=Cooperado;2=Credenciado/Contratualizado;3=Funcionario;4=Não Prestador
		lRet := .t.
		cModeloRem := iif(lCapt,"04","01")
		//TUSS 79 -> Tipo = 1 (Por Procedimento) | Tipo = 4 (Captation) 
	endif
endif

return {lRet,cModeloRem} //{ existirá a tag , Modelo de remuneração }
                                                         