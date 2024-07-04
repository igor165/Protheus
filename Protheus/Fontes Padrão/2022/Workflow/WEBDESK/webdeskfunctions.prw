#INCLUDE "WEBDESKINTEGRATION.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "ECMCONST.CH"
#INCLUDE "TBICONN.CH" 
 
//-------------------------------------------------------------------
/*/{Protheus.doc} BISetLogEvent
Realiza o log dos eventos/chamadas desse webservice

@protected
@param acEventLocal string com o local onde ocorreu o evento do log (Exemplo: Método XXX)
@param acEventDesc string com a descrição do evento ocorrido
@param aaParams array de string com os parâmtros a serem logados
@author  Paulo R. Vieira
@version P11
@since   15/04/2009
/*/
//-------------------------------------------------------------------
function BISetLogEvent(anLevel, acEventLocal, acEventDesc, aaParams)

	//FW_EV_LEVEL_INFO | FW_EV_LEVEL_WARNING | FW_EV_LEVEL_ERROR

	local cMessage	:= "" 
	local nInd		:= 0

	default aaParams := {}

	for nInd := 1 to len(aaParams)
		cMessage := "*Parameter" + DwStr( nInd ) + ":" + DwStr( aaParams[nInd] ) + "; "
	next

	if ECM_DEBUG .OR. ( anLevel == ECM_EV_LEVEL_ERROR )
		conout("********** TOTVS ECM Integration Event **********")
		conout("*Local		  :" + acEventLocal + ";")
		conout("*Description:" + acEventDesc + ";")
		conout( cMessage )

		if ECM_EVENT_VIEWER
			cMessage := acEventDesc + " " + cMessage 
		   EventInsert( ECM_EVENT_CHANEL, ECM_EVENT_CATEGORY, ECM_EVENT_ID, anLevel, "", acEventLocal, cMessage )
		endif
	endif
		
return


//-------------------------------------------------------------------
/*/{Protheus.doc} biPrtEcm
Realiza a gravação na tabela de equivalências entre instâncias no TOTVS ECM e processos no Microsiga Protheus

@param cTpProc Tipo de Processo
@param cCodPrt Código do processo no Microsiga Protheus
@param cCodECM Código da instância no TOTVS ECM
@return lOk Se for falso indica que ocorreu erro durante a gravação (chave duplicada)
@author Gilmar P. Santos
@version P11
@since 30/11/2009
/*/
//-------------------------------------------------------------------
function biPrtEcm( cTpProc, cCodPrt, cCodECM )
	local aArea		:= GetArea()
	local lOk		:= .F.
	local cFilPrt	:= xFilial(ECM_TABLE_NAME)

	cTpProc	:= padr( cTpProc, 10 )
	cCodPrt	:= padr( cCodPrt, 240 )
	cCodECM	:= padr( cCodECM, 240 )

	chkfile( ECM_TABLE_NAME )
	dbSelectArea( ECM_TABLE_NAME )
   
	(ECM_TABLE_NAME)->( dbSetOrder( ECM_ORDER_PRT ) )
	(ECM_TABLE_NAME)->( dbSeek( cFilPrt + cTpProc + cCodPrt ) )

	if (ECM_TABLE_NAME)->( EoF() )

		(ECM_TABLE_NAME)->( dbSetOrder( ECM_ORDER_ECM ) )
		(ECM_TABLE_NAME)->( dbSeek( cFilPrt + cTpProc + cCodECM ) )

		if (ECM_TABLE_NAME)->( EoF() )

			RecLock( ECM_TABLE_NAME, .T. )

			(ECM_TABLE_NAME)->(&(ECM_FIELD_PREFIX + "_FILIAL"))	:= cFilPrt
			(ECM_TABLE_NAME)->(&(ECM_FIELD_PREFIX + "_TPPROC"))	:= cTpProc
			(ECM_TABLE_NAME)->(&(ECM_FIELD_PREFIX + "_PRTID"))		:= cCodPrt
			(ECM_TABLE_NAME)->(&(ECM_FIELD_PREFIX + "_ECMID"))		:= cCodECM

			MsUnLock()

			lOk := .T.

		endif
	endif
	
	RestArea( aArea )

	// lOk = .F. indica chave duplicada

return lOk

//-------------------------------------------------------------------
/*/{Protheus.doc} biPrt2Ecm
Retorna o código de uma instância no TOTVS ECM equivalente a determinado processo no Microsiga Protheus

@param cTpProc Tipo de Processo
@param cCodPrt Código do processo no Microsiga Protheus
@return cCodECM Código da instância no TOTVS ECM
@author Gilmar P. Santos
@version P11
@since 30/11/2009
/*/
//-------------------------------------------------------------------
function biPrt2Ecm( cTpProc, cCodPrt )
	local aArea		:= GetArea()
	local cCodECM	:= ""  
	local cFilPrt	:= xFilial( ECM_TABLE_NAME )

	cTpProc	:= padr( cTpProc, 10 )
	cCodPrt	:= padr( cCodPrt, 240 )

	chkfile( ECM_TABLE_NAME )
	dbSelectArea( ECM_TABLE_NAME )
   
	(ECM_TABLE_NAME)->( dbSetOrder( ECM_ORDER_PRT ) )

	(ECM_TABLE_NAME)->( dbSeek( cFilPrt + cTpProc + cCodPrt ) )

	if !(ECM_TABLE_NAME)->( EoF() )
		cCodECM := (ECM_TABLE_NAME)->(&(ECM_FIELD_PREFIX + "_ECMID"))
	endif

	RestArea( aArea )

return Alltrim( cCodECM )

//-------------------------------------------------------------------
/*/{Protheus.doc} biECM2Prt
Retorna o código de um processo no Microsiga Protheus equivalente a uma instância no TOTVS ECM

@param cTpProc Tipo de Processo
@param cCodECM Código da instância no TOTVS ECM
@return cCodPrt Código do processo no Microsiga Protheus
@author Gilmar P. Santos
@version P11
@since 30/11/2009
/*/
//-------------------------------------------------------------------
function biECM2Prt( cTpProc, cCodECM )
	local aArea		:= GetArea()
	local cCodPrt	:= ""  
	local cFilPrt	:= xFilial( ECM_TABLE_NAME )

	cTpProc	:= padr( cTpProc, 10 )
	cCodECM	:= padr( cCodECM, 240 )

	chkfile( ECM_TABLE_NAME )
	dbSelectArea( ECM_TABLE_NAME )
   
	(ECM_TABLE_NAME)->( dbSetOrder( ECM_ORDER_ECM ) )

	(ECM_TABLE_NAME)->( dbSeek( cFilPrt + cTpProc + cCodECM ) )

	if !(ECM_TABLE_NAME)->( EoF() )
		cCodPrt := (ECM_TABLE_NAME)->(&(ECM_FIELD_PREFIX + "_PRTID"))
	endif

	RestArea( aArea )

return Alltrim( cCodPrt )


//-------------------------------------------------------------------
/*/{Protheus.doc} biCript
Converte uma string em um formato gzip em base 64

@protected
@param cXmlDecript String plain text que será convertida
@return cXmlCript String no formato zip (base 64) convertida
@author Gilmar P. Santos
@version P11
@since 04/12/2009
/*/
//-------------------------------------------------------------------
function biCript( cXmlDecript )
	local cXmlZip		:= ""
	local cXmlCript	:= ""
	local cFNameSrc	:= ""
	local cFNameDst	:= ""
	
	local cGzComp		:= "gzCompress"
	
	local cDir			:= "/biecm"

	// O correto funcionamento dessa rotina depende da resolução do chamado SCIJ73 de 5/1/2010

	if findFunction( cGzComp )
	   wfForceDir( cDir )
	
		cFNameSrc := cDir + "/ecm" + substr( CriaTrab( NIL, .F. ), 3 )
		cFNameDst := cDir + "/ecm" + substr( CriaTrab( NIL, .F. ), 3 )
		
		memowrite( cFNameSrc, cXmlDecript )
	
		&cGzComp.(cFNameSrc, cFNameDst)
		
		cXmlZip := MemoRead( cFNameDst )
		
		cXmlCript := encode64( cXmlZip )
	
		FErase ( cFNameSrc )
		FErase ( cFNameDst )
	else 
		UserException( STR0017 )
	endif	

return cXmlCript


//-------------------------------------------------------------------
/*/{Protheus.doc} biDecript
Converte uma string em um formato gzip em base 64

@protected
@param cXmlCript String no formato zip (base 64) que será convertida
@return cXmlDecript String plain text convertida
@author Gilmar P. Santos
@version P11
@since 04/12/2009
/*/
//-------------------------------------------------------------------
function biDecript( cXmlCript )
	local cXmlDecript	:= ""
	local cXmlDecode	:= ""
	local cFNameSrc	:= ""
	local cName			:= ""

	local cDirSrc		:= "/biecm/"
	local cDirDst		:= "/biecm/" + substr( CriaTrab( NIL, .F. ), 3 ) + "/"
	
	local aFiles		:= {}
	
	local nFiles		:= 0
	
	local cGzDecomp	:= "gzDecomp"

	// O correto funcionamento dessa rotina depende da resolução do chamado SCIJ73 de 5/1/2010

	if findFunction( cGzDecomp )
	   wfForceDir( cDirSrc )
	   wfForceDir( cDirDst )
	
		cName := "ecm" + substr( CriaTrab( NIL, .F. ), 3 )
		cFNameSrc := cDirSrc + cName
	
		cXmlDecode := decode64( cXmlCript )
		memowrite( cFNameSrc, cXmlDecode )
	
		&cGzDecomp.(cFNameSrc, cDirDst)
	
		nFiles := ADir( cDirDst + "*.*" , aFiles )
	
		if nFiles > 0
			cXmlDecript := MemoRead( cDirDst + aFiles[nFiles] )
	
			FErase ( cFNameSrc )
			FErase ( cDirDst + aFiles[nFiles] )
	
			DirRemove( substr( cDirDst, 1, len(cDirDst) - 1 ) )
		endif
	else 
		UserException( STR0017 )
	endif	

return cXmlDecript


//-------------------------------------------------------------------
/*/{Protheus.doc} biEcmClean
Executa limpeza da tabela de equivalência Protheus-ECM

@protected
@param dDate Data limite para os registros que serão excluidos
@author Gilmar P. Santos
@version P10
@since 03/03/2010
/*/
//-------------------------------------------------------------------
static function biEcmClean( dDate )
	local aArea		:= GetArea()
	local lOk		:= .F.
	local cFilPrt	:= xFilial(ECM_TABLE_NAME)

	default dDate := date() - 60

	chkfile( ECM_TABLE_NAME )
	dbSelectArea( ECM_TABLE_NAME )

	(ECM_TABLE_NAME)->( DBSetFilter({|| !Empty( &(ECM_FIELD_PREFIX + "_DTFIM") ) .and. ( &(ECM_FIELD_PREFIX + "_DTFIM") <= dDate ) .and. ( &(ECM_FIELD_PREFIX + "_FILIAL") == cFilPrt )}, ECM_FIELD_PREFIX + "_DTFIM <= date()") )

	(ECM_TABLE_NAME)->( DBGoTop() )

	while ! ( (ECM_TABLE_NAME)->( EoF() ) )

		RecLock( ECM_TABLE_NAME, .F. )

		(ECM_TABLE_NAME)->( DBDelete() )

		MsUnLock()

		(ECM_TABLE_NAME)->( DBSkip() )

	enddo

	(ECM_TABLE_NAME)->( DBClearFilter() )

	RestArea( aArea )

return


//-------------------------------------------------------------------
/*/{Protheus.doc} biSchEcmClean
Executa limpeza da tabela de equivalência Protheus-ECM
Rotina preparada para ser executada via scheduler

@param aParam[1] Empresa onde será realizada a limpeza
@param aParam[2] Data limite para a limpeza (opcional)
@author Gilmar P. Santos
@version P10
@since 04/03/2010
/*/
//-------------------------------------------------------------------
function biSchEcmClean( aParam )
	local aArea := GetArea()
	local dData := nil

	If aParam == Nil .OR. valtype( aParam ) == "U"
		conout( STR0021 ) //###Parâmetros inválidos
		return
	EndIf

	Prepare Environment Empresa aParam[1] Filial "01"

	chkfile("SM0")

	DBSelectArea("SM0")
	DBSetOrder(1)
	DBSeek(aParam[1],.F.)

	if len( aParam ) == 2 
		dData := aParam[2]
	endif

	while !SM0->(EOF()) .AND. SM0->M0_CODIGO == aParam[1]
		cFilAnt	:= SM0->M0_CODFIL

		biEcmClean( dData )

		SM0->(DBSkip())
	end

	RestArea( aArea )

return