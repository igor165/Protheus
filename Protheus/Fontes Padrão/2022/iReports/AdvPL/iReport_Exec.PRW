#include "BIDefs.ch"
#include "irep_exec.ch"
#include "iReportDefs.ch"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} callIReport
Execução de um relatório

@param		Nome do relatório.
@param		Parâmetros para execução sendo [1] Destino, [2] Copias, [3] Tela de configuração e [4] Exibe tela de pergunte.
@author    	Alexandre Alves da Silva
@author    	Valdiney V GOMES
@version   	P11
@since     	16/01/2007
/*/
//-------------------------------------------------------------------------------------
function callIReport( cNome, aParametros )
	Local oDlg          := Nil 	//Formulário principal.
	Local oVideo		:= Nil	//Botão Vídeo.
	Local oPrinter		:= Nil	//Botão Impressora.
	Local oPergunta		:= Nil  //Botão Parâmetros.
	Local oCancelar		:= Nil  //Botão Cancelar.
	Local oMensagem		:= Nil	//Mensagem de ausência de parâmetros.
	Local oGrpSaida		:= Nil	//Agrupador de Opções de Visualização.
	Local oGrpPergunta	:= Nil  //Agrupador de Parametros do Relatório.

	Default	cNome		:= ""
	Default aParametros	:= ""
	
	If ( GetRemoteType() == 5 )
		MsgAlert(STR0012) //"A Integração com o iReport não é homologada para SmartClient HTML."
		Return .F.
	EndIf	
	
	If ( Len(aParametros) == 3 )
		uRelatorio( cNome, aParametros[1], aParametros[2], aParametros[3] )
	ElseIf ( Len(aParametros) == 4 )
		uRelatorio( cNome, aParametros[1], aParametros[2], aParametros[3], aParametros[4] )
	Else
		//Formulário principal.
		oDlg 					:= MSDialog():New()
		oDlg:nTop 	   			:= 10
		oDlg:nLeft 				:= 10
		oDlg:nWidth    			:= 300
		oDlg:nHeight 			:= 240
		oDlg:cCaption 			:= 'iReport: ' + cNome

		//Agrupador de Opções de Visualização.
		oGrpSaida 				:= TGroup():Create( oDlg )
		oGrpSaida:nTop 	   		:= 10
		oGrpSaida:nLeft 		:= 10
		oGrpSaida:nWidth    	:= oDlg:nWidth  - 20
		oGrpSaida:nHeight 		:= 80
		oGrpSaida:cCaption 		:= STR0005 //"Opções de Visualização"

		//Botão Vídeo.
		oVideo 				:= TButton():Create( oGrpSaida )
		oVideo:nTop 		:= 40
		oVideo:nLeft 		:= 40
		oVideo:nWidth 		:= 100
		oVideo:nHeight 		:= 25
		oVideo:cCaption 	:= STR0006 //'Vídeo'
		oVideo:blClicked 	:= { || uVisualizar( cNome, oDlg ) }

		//Botão Impressora.
		oPrinter 			:= TButton():Create( oGrpSaida )
		oPrinter:nTop    	:= 40
		oPrinter:nLeft 		:= 160
		oPrinter:nWidth 	:= 100
		oPrinter:nHeight 	:= 25
		oPrinter:cCaption 	:= STR0007 //'Impressora'
		oPrinter:blClicked 	:= { || uImprimir( cNome, oDlg ) }

		//Agrupador de Parametros do Relatório.
		oGrpPergunta 			:= TGroup():Create( oDlg )
		oGrpPergunta:nTop 	   	:= 100
		oGrpPergunta:nLeft 		:= 10
		oGrpPergunta:nWidth    	:= oDlg:nWidth  - 20
		oGrpPergunta:nHeight 	:= 60
		oGrpPergunta:cCaption 	:= STR0008 //'Parâmetros do Relatório'

		//Botão Parâmetros.
		If ( SX1->( DBSeek( Padr(cNome, Len(X1_GRUPO) ) ) ))
			oPergunta 			:= TButton():Create( oGrpPergunta )
			oPergunta:nTop    	:= 120
			oPergunta:nLeft 	:= ( oDlg:nWidth / 2 ) - 50
			oPergunta:nWidth 	:= 100
			oPergunta:nHeight 	:= 25
			oPergunta:cCaption 	:= STR0009 //'Parâmetros'
			oPergunta:blClicked 	:= { || uPergunte( cNome, .T. ) }
		Else
			//Mensagem de ausência de parâmetros.
			oMensagem		 	:= TSay():Create ( oGrpPergunta )
			oMensagem:nTop   	:= 130
			oMensagem:nLeft 	:= 20
			oMensagem:nWidth  	:= oDlg:nWidth  - 30
			oMensagem:nHeight 	:= 25
			oMensagem:SetText( STR0010 ) //"Este relatório não possui parâmetros."
		EndIf

		//Botão cancelar.
		oCancelar			:= TButton():Create( oDlg )
		oCancelar:nTop    	:= 175
		oCancelar:nLeft 	:= ( oDlg:nWidth / 2 ) - 50
		oCancelar:nWidth 	:= 100
		oCancelar:nHeight 	:= 25
		oCancelar:cCaption 	:= STR0011 //'Fechar'
		oCancelar:blClicked := { || oDlg:End() }

		//Exibe o formulário.
		oDlg:Activate()
	EndIf
Return .T.

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} uVisualizar
Visualização de relatório.

@param		Nome do relatório.
@author    	Valdiney V GOMES
@version   	P11
@since     	13/08/2011
/*/
//-------------------------------------------------------------------------------------
Function uVisualizar( cNome, oDlg )
	uRelatorio( cNome, "0" )
	oDlg:End()
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} uImprimir
Impressão de relatório.

@param		Nome do relatório.
@author    	Valdiney V GOMES
@version   	P11
@since     	13/08/2011
/*/
//-------------------------------------------------------------------------------------
Function uImprimir( cNome, oDlg )
	uRelatorio( cNome, "1" )
	oDlg:End()
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} uRelatorio
Impressão de relatório.

@param		Nome do relatório.
@param		Destino de saída onde 0 é vídeo e 1 é impressora.
@param		Número de cópias impressas.
@param		Exibição da tela de configuração de impressora.
@param		Exibição da tela de parâmetros do relatório.
@author    	Valdiney V GOMES
@version   	P11
@since     	13/08/2011
/*/
//-------------------------------------------------------------------------------------
Function uRelatorio( cNome, cDestino, nCopia, lDialog, lShowPergunte )
	Local oReport	 := IReport_Run():New('')

	Default cNome	 		:= ""
	Default cDestino 		:= "0"
	Default nCopia 	 		:= 1
	Default lDialog  		:= .T.
	Default lShowPergunte 	:= .F. 
	
	If uPergunte( cNome, lShowPergunte )
		oReport:cReportName(cNome)
		oReport:cReportDestino( cDestino )
		oReport:nNumCopias(nCopia)
		oReport:lShowPrintDialog(lDialog)
		oReport:nRun()
	EndIf
Return Nil

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} uPergunte
Impressão de relatório.

@param		Nome do relatório.
@param		Exibição da tela de perguntas.
@author    	Valdiney V GOMES
@version   	P11
@since     	13/08/2011
/*/
//-------------------------------------------------------------------------------------
Function uPergunte( cNome, lPergunta )
	Local cPergunta		:= ""
	Local nPergunta		:= 1
	Local aPergunta		:= {}
	Local cResposta		:= ""
	Local lContinuar		:= .T.
 
	Default cNome 		:= ""
	Default lPergunta 	:= .F.

	If lPergunta
		//-------------------------------------------------------
		// Variável lContinuar irá determinar se o usuário clicou
		// em 'ok' ou em 'cancelar'.
		// Caso clique em cancelar o relatório não será exibido.	
		//-------------------------------------------------------
		lContinuar := Pergunte( cNome, lPergunta )
	else
		Pergunte( cNome, lPergunta )
	EndIf
                                                                            
	// Força a atualização dos parâmetros do relatório no iReport
	DBselectarea("SX1")
	DBsetorder(1)

	If ( DBseek( AllTrim( cNome ) ) )
		While ! Eof() .and. AllTrim( X1_GRUPO ) == AllTrim( cNome )
			cPergunta	:= "MV_PAR" + Padl( Alltrim( cBIStr( nPergunta ) ), 2, "0")
			cResposta 	:= &cPergunta

			If ( valtype( cResposta ) == "N" )
				cResposta := Alltrim( cBIstr( cResposta ) )
			ElseIf ( valtype(cResposta) == "D" )
				cResposta := Alltrim( DToS( cResposta ) )
			EndIf

			aAdd( aPergunta, { X1_PERGUNT, cResposta, X1_ORDEM } )

			nPergunta ++
			dbskip()
		enddo
	EndIf
              
	lIR_PutQuestions( AllTrim( cNome ), cEmpAnt, aPergunta )
Return lContinuar

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} lGetIReport
Serializa o arquivo do relatório para transferência pelo WS.

@param		oReturn
@param		Nome de arquivo .jrxml ou .jasper do relatório.
@author    	Alexandre Alves da Silva
@version   	P11
@since     	22/01/2007
/*/
//-------------------------------------------------------------------------------------
function lGetIReport( oReturn, cFileName )
	Local bytesRead		:= 0
	Local fileSize		:= 0
	Local cLidos		:= ""
	Local oFile 		:= Nil
	Local cRepPath		:= REPORTS_PATH + "\" + cFileName
	Local lRet			:= .T.
	Local lEncode64		:= .F.

	If File( cRepPath + ".jrxml" )
		cRepPath 	+= ".jrxml"
	ElseIf File( cRepPath + ".jasper" )
		cRepPath 	+= ".jasper"
		lEncode64 	:= .T.
	EndIf

	oFile 	:= TBIFileIO():New( cRepPath )

	If ( oFile:lOpen(FO_SHARED) )
		oReturn		:= ""
		fileSize	:= oFile:nSize()

		Do while ( bytesRead <  fileSize )
			oFile:nRead(@cLidos, 100000)
			bytesRead	+= 100000
			oReturn		+= cLidos
		EndDo
		
		oReturn := PutHTMLChr( oReturn )

		If ( lEncode64 )
			oReturn := Encode64( oReturn )
		EndIf

		oFile:lClose()
	Else
		oReturn	:=	STR0001//"Não foi possivel abrir o relatório."
		SetSoapFault("GETREPORT",STR0004 + " " + cRepPath ) //"Relatorio nao encontrado."
		lRet :=	.f.
	EndIf
Return lRet

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} PutHTMLChr
Tratamento para caracteres especias/com acento

@param		String a receber o tratamento.
@author    	Helio Leal
@version   	P12
@since     12/09/2014
/*/
//-------------------------------------------------------------------------------------
Function PutHTMLChr( cStr )
	
	cStr := DecodeUTF8( cStr )

	// Tratamento para caracteres com aceto agudo.
	cStr := StrTran(cStr,'Ó','&Oacute;')	
	cStr := StrTran(cStr,'Í','&Iacute;')
	cStr := StrTran(cStr,'Á','&Aacute;')
	
Return EncodeUTF8( cStr )