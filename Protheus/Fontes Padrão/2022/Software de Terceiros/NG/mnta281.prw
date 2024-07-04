#Include "Protheus.ch"
#INCLUDE "MNTA281.ch"
#Include "FWADAPTEREAI.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTA281
Fun��o invocada no processo de integra��o Protheus x uMov.me
para aplicativo de Solicita��o de Servi�o

@param String cXML: indica xml que cont�m informa��es do arquivo
importado/exportado
@author Andr� Felipe Joriatti
@since 24/10/2013
@version P11
@return Nil
/*/
//---------------------------------------------------------------------

Function MNTA281( cXML )

	Local lTransac		:= .T.
	Local oImportTxt    := NGIMPRTTXT():New()
	Local cErro         := ""
	Local cLogError		:= ""
	Local cAviso        := ""
	Local cLocLog		:= ""
	Local cArqLog		:= ""
	Local nArqLog		:= 0
	Local cArqExtLog	:= ""
	Local aSolicitacoes := {}
	Local nT            := 0
	Local nI            := 0
	Local aRetorno      := { .T., "" }
	Local nPosImg       := 0

	Default cXML := ""

	/*Default cXML := "<UmovImport>"
	     cXML += "<FileName>Solicitacao.csv</FileName>"
	     cXML += "<IPAddress>192.168.0.167</IPAddress>"
	     cXML += "<FTPPort>10</FTPPort>"
    	 cXML += "<Directory>D:\AP118\Protheus_Data\umov\ap_ss\import\Solicitacao.csv</Directory>"
    	 cXML += "<RelativeDirectory>D:\AP118\Protheus_Data\umov\ap_ss\import</RelativeDirectory>"
	     cXML += "</UmovImport>" */
	
	oXml := XmlParser( cXML,"_",@cErro,@cAviso )

	If XmlChildEx( oXml,"_UMOVIMPORT" ) != Nil

		oImportTxt:setDir( oXml:_UmovImport:_RelativeDirectory:Text )
		oImportTxt:setFile( oXml:_UmovImport:_FileName:Text )

		//Define o arquivo de Log que ser� gerado caso ocorra inconsist�ncia
		cLocLog	:= oXml:_UmovImport:_RelativeDirectory:Text
		cArqLog	:= SubStr( oXml:_UmovImport:_FileName:Text , 1 , RAt(".",oXml:_UmovImport:_FileName:Text) - 1 ) + ".log"
		cArqExtLog := cLocLog + "\erro\" + cArqLog
		If File( cArqExtLog )
			nArqLog := FT_FUse(cArqExtLog)
		Else
			nArqLog := FCREATE(cArqExtLog)
		EndIF

		// Importa��o de Solicita��o de Servi�o

		oImportTxt:setAlias( "TQB" )
		oImportTxt:setSkip( 2 ) // Deve pular 2 linhas (de cabe�alho) antes de come�ar a ler o arquivo

		// Configura posi��es para valores de ano, m�s e dia para campo do tipo data no arquivo
		oImportTxt:setPosAnoCpoData( 1,4 )
		oImportTxt:setPosMesCpoData( 6,2 )
		oImportTxt:setPosDiaCpoData( 9,2 )

		// Seta posi��es dos campos no arquivo
		oImportTxt:setFieldPos( "TQB_TIPOSS",01 )
		oImportTxt:setFieldPos( "TQB_CODBEM",02 )
		oImportTxt:setFieldPos( "TQB_DTABER",03 )
		oImportTxt:setFieldPos( "TQB_HOABER",04 )
		oImportTxt:setFieldPos( "TQB_RAMAL" ,05 )
		oImportTxt:setFieldPos( "TQB_DESCSS",06 )
		oImportTxt:setFieldPos( "TQB_CDSOLI",07 )
		oImportTxt:setFieldPos( "TQB_BITMAP",09 )

		// Seta valor padr�o para os registros
		oImportTxt:setDefaultValue( "TQB_ORIGEM","'UMOV.ME'" )
		oImportTxt:setDefaultValue( "TQB_USUARI","UsrFullName( M->TQB_CDSOLI )" )

		// Seta campo que recebe c�digo memo de SYP e vari�vei que ir� preencher os registros da SYP
		oImportTxt:setMemoCodField( "TQB_CODMSS","M->TQB_DESCSS" )

		// Seta campos que dever�o ser retornados para o array de exec auto
		oImportTxt:setFieldsExAut( { "TQB_TIPOSS","TQB_CODBEM","TQB_DTABER","TQB_HOABER","TQB_RAMAL",;
			"TQB_DESCSS","TQB_CDSOLI","TQB_BITMAP","TQB_ORIGEM" } )

		// Carrega os dados, neste caso n�o vai gravar na base, vai jogar para o array de controle de campos do execauto
		aRetorno := oImportTxt:loadPersistence()

		aSolicitacoes := oImportTxt:getRegistros()

		Begin Transaction
		For nI := 1 To Len( aSolicitacoes )

			//-------------------------------------------------------------
			// Grava imagem no reposit�rio do Protheus e retorna o c�digo
			// para relacionar ao registro de S.S.
			//-------------------------------------------------------------
			nPosImg := aScan( aSolicitacoes[nI],{ |x| AllTrim( x[1] ) == "TQB_BITMAP" } )
			If !Empty( aSolicitacoes[nI][nPosImg][2] )
				aSolicitacoes[nI][nPosImg][2] := fGrvImg281( aSolicitacoes[nI][nPosImg][2] )
			EndIf

			// Grava��o via execauto
			lMsErroAuto := .F.
			MSExecAuto( { |x| MNTA280( ,,x ) },aSolicitacoes[nI],3 ) // Inclus�o

			If lMsErroAuto
				lTransac := .F.
				cError := MostraErro()
				FWrite(nArqLog, STR0007 + cValToChar( nI ) + STR0008 + CRLF) //"Registro " //" possui inconsist�ncias:"
				FWrite(nArqLog, cError)
			Else
				FWrite(nArqLog, STR0007 + cValToChar( nI ) + STR0009 + CRLF) //"Registro " //" processado com sucesso."
				FWrite(nArqLog, Replicate("-", 80) + CRLF)
			EndIf
		Next nI
		FClose(nArqLog)
		FT_FUSE()
		If lTransac
			//END TRANSACTION
			FErase(cArqExtLog)
		Else
			DisarmTransaction()
			aRetorno := {.F., STR0001 + cArqLog} //"Grava��o n�o processada por inconsist�ncias nos registros. Para mais informa��es consultar o Log: "
		EndIf
		END TRANSACTION
		MsUnLockAll()
	EndIf

// 1: indica se processamento ocorreu ou n�o com sucesso
// 2: string com informa��o para ser gravada no log (mensagem) caso tenha ocorrido erro no processo
Return aRetorno

//---------------------------------------------------------------------
/*/{Protheus.doc} fGrvImg281
Realiza requisi��o http a partir do endere�o informado no parametro,
baixa a imagem do endere�o, grava no reposit�rio de imagens do Protheus
e retorna o c�digo da imagem no reposit�rio.

@param String cEnderecoImg: indica endere�o URL da imagem
@author Andr� Felipe Joriatti
@since 27/01/2014
@version P11
@return String cImgName: indica c�digo da imagem no reposit�rio
/*/
//---------------------------------------------------------------------

Static Function fGrvImg281( cEnderecoImg )

	Local cImgHTTP   := ""
	Local nHandle    := 0
	Local cImgName   := "U0000001"
	Local oImgRep    := Nil
	Local lGravouImg := .T.
	Local cExtensao  := ".jpg"
	Local cCaminho   := "imagens_umov_mnt"
	Local cBarras    := If( isSrvUnix(),"/","\" )
	Local cQuery     := ""
	Local cAliasQry  := GetNextAlias()
	Local bError     := ErrorBlock( { |oError| fCatchError( oError ) } )
	Local nSegundos  := 0
	Local oBmp       := Nil, oDlg := Nil

	//------------------------------------------------------------
	// Tratamento de erro na importa��o da imagem para n�o
	// interromper o fluxo da importa��o
	// de S.S. caso algo d� errado com a imagem/conex�o http, etc..
	//------------------------------------------------------------
	BEGIN SEQUENCE

		cCaminho := cCaminho + If( Right( cCaminho,1 ) == cBarras,"",cBarras )

		// Cria pasta tempor�ria caso n�o exista
		If !ExistDir( cCaminho )
			MakeDir( cCaminho )
		EndIf

		cQuery := "SELECT MAX( TQB_BITMAP ) TQB_BITMAP FROM " + RetSQLName( "TQB" )

		DbUseArea( .T.,"TOPCONN",TCGenQry( ,,ChangeQuery( cQuery ) ),cAliasQry,.F.,.T. )

		DbSelectArea( cAliasQry )
		cImgName := If ( !Empty( ( cAliasQry )->TQB_BITMAP ),;
			Soma1( ( cAliasQry )->TQB_BITMAP ),;
			 cImgName )

		( cAliasQry )->( DbCloseArea() )

		cImgHTTP := HTTPGet( cEnderecoImg ) // Baixa a imagem do endere�o estipulado pelo parametro

		If !Empty( cImgHTTP ) .And. !File( cCaminho + cImgName + cExtensao )

			nHandle := FCreate( cCaminho + cImgName + cExtensao,0 )
			FWrite( nHandle,cImgHTTP )
			FClose( nHandle )

			oImgRep := TBmpRep():New( 0,0,0,0,"",.T.,( MSDialog():New( 0,0,0,0,'t',,,,,,,,,.T. ) ),;
				Nil,Nil,.F.,.F. )

			oImgRep:InsertBmp( cCaminho + cImgName + ".jpg",cImgName,@lGravouImg )

		EndIf

	END SEQUENCE

	// Recupera o bloco de erro
	ErrorBlock( bError )

Return cImgName

//---------------------------------------------------------------------
/*/{Protheus.doc} fCatchError
Captura a excess�o lan�ada em tempo de execu��o

@param Object oError: indica o objeto de erro do sistema
@author Andr� Felipe Joriatti
@since 28/01/2014
@version P11
@return Nil
/*/
//---------------------------------------------------------------------
Static Function fCatchError( oError )

	Help( , , STR0010 , , STR0003 + oError:Description , 4 , 0 )// "Aten��o"##"Erro na importa��o da imagem uMov.me: "
	Break

Return Nil