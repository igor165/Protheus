#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "MSOLE.CH"
#INCLUDE "VKEY.CH"
#INCLUDE "LOCA077.CH"

/*/{PROTHEUS.DOC} LOCA077.PRW
ITUP BUSINESS - TOTVS RENTAL
RELATÓRIO DE INTEGRAÇÃO POR OBRA
@TYPE FUNCTION
@AUTHOR ifranzoi
@SINCE 12/07/2021
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/

MAIN FUNCTION LOCA077(_cEmpresax, _cFilialx)
Local cPerg  	:= "LOCP079"
Local lMenu 	:= .F.
Local lContinua	:= .T.

Default _cEmpresax := "01"
Default _cFilialx  := "010101"

Private lJob := FWGetRunSchedule()

//Quando chamado via menu cai nesse cenário
If Select("SX2") <> 0
	lMenu := .T.
Endif

If !lJob .And. !lMenu
	RPCSETTYPE ( 3 )
	PREPARE ENVIRONMENT EMPRESA _cEmpresax FILIAL _cFilialx MODULO "" 
EndIf

If lJob .Or. !lMenu
	//foi retirado o pergunte, pois via job já vem com a pergunta respondida, quando chamado novamente, ele considera errado
	//Pergunte(cPerg,.F.)
	//MV_PAR01 := 1
Else
	If !Pergunte(cPerg,.T.)
		lContinua	:= .F.
	EndIf
EndIf

If lContinua	:= .T.
	If ( MV_PAR01 == 1 )
		//Envio do email de VENCIMENTO DE INTEGRAÇÃO E ASO
		LOCA07701()
	ElseIf ( MV_PAR01 == 2 )
		//Envio do email de aviso de Vencimento de data de Integração 	
		LOCA07702()
	EndIf
EndIf

If !lJob .And. !lMenu
	RESET ENVIRONMENT
EndIf

RETURN

/*/{PROTHEUS.DOC} LOCA07701
ITUP BUSINESS - TOTVS RENTAL
APONTADOR AS
@TYPE FUNCTION
@AUTHOR ifranzoi
@SINCE 29/06/2021
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
FUNCTION LOCA07701()									     //U_INTMAIL()   
LOCAL _cRemet	:= ""									     //REMETENTE
LOCAL _cDest   	:= ""		         	
LOCAL _cCC    	:= ""									     //COPIA
LOCAL _cAssunto	:= STR0001 //"VENCIMENTO DE INTEGRAÇÃO E ASO"		     //ASSUNTO
LOCAL cBody   	:= ""                 					     //CORPO DO EMAIL
LOCAL _cAnex  	:= ""                 					     //ANEXO
LOCAL _cCco  	:= ""                 					     //COPIA OCULTA
LOCAL cDataIn   := " "
LOCAL cDataAso  := " "
Local cQry		:= ""
Local cBgLinha	:= ""
LOCAL _lMsg   	:= .F.                 				         //MONSTRA MENSAGEM 'ENVIO COM SUCESSO'
Local nReg1		:= 0
LOCAL dDTVINT											     //DATA DE VALIDADE DA INTEGRACAO

	//01-09-2011 - Maickon Queiroz - Alterado a Query pois não atendia a funcionalidade do relatório. Funcionarios somente com Integração vencida não era apresentado. 
	//								 Incluido FPU_CONTRO para trazer somente funcionarios que estiverem preenchido e o maior numero referente ao funcionários.
	cQry := " SELECT "
	cQry += "	MAX(FPU.FPU_CONTRO)AS FPU_CONTRO, FPU.FPU_FILIAL , FPU.FPU_AS , FPU.FPU_OBRA , FPU.FPU_MAT , FPU.FPU_NOME , "
	cQry += "	FPU.FPU_DTINI , FPU.FPU_DTFIN , FPU.FPU_DTLIM , FPU.FPU_VALID, 	FPU.FPU_CRACHA , FPU.FPU_DESIST, "
	cQry += "	FQ5_NOMCLI , FQ5_DESTIN  "
	cQry += " FROM "+RetSqlName("FPU")+ " as FPU "
	cQry += "	Left JOIN "+RetSqlName("FQ5")+ " FQ5 ON FQ5.D_E_L_E_T_ = '' "
	cQry += "       AND FPU.FPU_AS = FQ5_AS "
	cQry += "		AND FQ5_FILIAL = '"+xFILIAL("FQ5")+"' " 
	cQry += " WHERE FPU.D_E_L_E_T_ = '' "
	cQry += "	AND FPU_CRACHA = '1'  "
	cQry += "	AND FPU.FPU_DESIST = '2'  "
	cQry += "	AND FPU.FPU_FILIAL = '"+xFILIAL("FPU")+ "' "
	cQry += "	AND FPU.FPU_CONTRO <> '' "
	cQry += " GROUP BY FPU_FILIAL ,FPU_AS ,FPU_OBRA , FPU_MAT , FPU_NOME , "
	cQry += "		FPU_DTINI, FPU_DTFIN, FPU_DTLIM, FPU_VALID, FPU_CRACHA, FPU_DESIST, FQ5_NOMCLI , FQ5_DESTIN "

	If Select("INT077") <> 0                                     		//SE ALIAS ESTIVER ABERTO
		INT077->(DBCLOSEAREA())										//FECHANDO TABELA TEMPORARIA
	Endif															//FIM
		
	cQry := CHANGEQUERY(cQry) 
	DBUSEAREA(.T.,"TOPCONN",TCGENQRY(,,cQry),"INT077",.F.,.T.)         //USANDO AREA INT077

	cBody += " <html> " 
	cBody += " 	<body> " 
	cBody += " 		<table width='100%' border='0' style='font-family:arial;font-size:13' >  "
	cBody += " 			<tr> "
	cBody += " 				<td colspan='5'  align='center' bgcolor='#3399FF'><b>&nbsp;"+STR0001+"</b></td> " //TITULO DO EMAIL  "VENCIMENTO DE INTEGRAÇÃO E ASO" 
	cBody += " 			</tr> "
	cBody += " 			<tr> "
	cBody += " 				<td width='075' align='center' bgcolor='#CCCCCC'><b>"+STR0002+"</b></td> "			//MATRICULA
	cBody += " 				<td width='520' align='center' bgcolor='#CCCCCC'><b>"+STR0003+"</b></td> "				//NOME
	cBody += "  			<td width='120' align='center' bgcolor='#CCCCCC'><b>"+STR0004+"</b></td> "  	//DT VALIDACAO INTEGRACAO
	cBody += "  			<td width='600' align='center' bgcolor='#CCCCCC'><b>"+STR0006+"</b></td> "	    //NOME CLIENTE																	
	cBody += "  			<td width='120' align='center' bgcolor='#CCCCCC'><b>"+STR0007+"</b></td> "	//MUNICIPIO UF																		
	cBody += " 			</tr> "		

	INT077->(DBGOTOP())								                                                                //PRIMEIRO REGISTRO DA TABELA TEMPORARIA
	WHILE INT077->(!EOF())							                                                                   	//LACO ENQUANTO NAO FOR O FIM DA TABELA TEMPORARIA INT077(QUERY) 

		If !EMPTY(INT077->FPU_DTFIN).AND.!EMPTY(INT077->FPU_VALID)
			dDTVINT	:= MONTHSUM(STOD(INT077->FPU_DTFIN),INT077->FPU_VALID)-30	                                            //DATA DE VALIDADE DA INTEGRACAO
		Else
			dDTVINT  := STOD(INT077->FPU_DTFIN)
		Endif

		IF !EMPTY(INT077->FPU_DTFIN) 

			IF !EMPTY(INT077->FPU_DTFIN)
				IF dDATABASE >= dDTVINT 
					cDataIn := DTOC(MONTHSUM(STOD(INT077->FPU_DTFIN),INT077->FPU_VALID))
				ENDIF
			ENDIF  

			IF !EMPTY(cDataIn)

				nReg1++

				//alterna a cor por linha 
				If Mod(nReg1,2) == 0
					cBgLinha := " bgcolor = #eee "
				else
					cBgLinha := ""
				EndIf

				cBody += " <tr" + cBgLinha + "> "
				cBody += " 		<td width='075' align='center'><b>"+ALLTRIM(INT077->FPU_MAT)+"</b></td> "	   //MATRICULA
				cBody += " 		<td width='520' align='center'><b>"+ALLTRIM(INT077->FPU_NOME)+"</b></td> "	   //NOME FUNCIONARIO
				cBody += " 		<td width='120' align='center'><b>"+cDataIn+"</b></td> "   	               //DATA DE VENCIMENTO DA INTEGRACAO
				cBody += " 		<td width='600' align='center'><b>"+INT077->FQ5_NOMCLI+"</b></td> "		   //NOME DO CLIENTE
				cBody += " 		<td width='120' align='center'><b>"+INT077->FQ5_DESTIN+"</b></td> "		   //MUNICIPIO																														
				cBody += " </tr> "

			ENDIF

		ENDIF					

		INT077->(DBSKIP())
		cDataIn  := " "
		cDataAso := " "

	ENDDO

	IF INT077->(EOF())  //SE FOR O FIM DA QUERY				

		//IMPRIMI RODAPÉ DO EMAIL A SER ENVIADO
		cBody  += " </table> "
		cBody  += " </body> "
		cBody  += " </html> "
		_cDest := SuperGetMV("MV_LOCX054",.F.,"") 

		//CHAMANDO FUNCAO PADRAO  PARA ENVIO DE EMAIL
		SendEmail(_cRemet, _cDest, _cCC, _cAssunto, cBody, _cAnex, _cCco, _lMsg) 
	ENDIF

RETURN

//------------------------------------------------------------------------------
/*/{Protheus.doc} LOCA07702

Envio do email de aviso de Vencimento de data de Integração 	
@type  Static Function
@author Jose Eulalio
@since 02/08/2022

/*/
//------------------------------------------------------------------------------
Function LOCA07702()
LOCAL cAs      	:= ""
LOCAL cQry     	:= ""
LOCAL cMsg   	:= ""
Local cPara		:= ""
Local cBgLinha	:= ""
Local cAssunto	:= ""
Local cArq		:= ""
Local nReg		:= 0
Local nReg1		:= 0

//Query para verificar itens que devem ser integrados
cQRY:= " SELECT DISTINCT(FPU_AS)  AS NR_AS, FPU_OBRA  AS OBRA, FPU_PROJ  AS PROJ, FPU_DTLIM AS DATALIMITE , FQ5_NOMCLI AS NOMCLI, FQ5_DESTIN AS MUNEST  "  + CRLF
cQRY+= " FROM "+ RETSQLNAME("FPU") + " M0 (NOLOCK) "                                                                            + CRLF
cQRY+= " INNER JOIN "+ RETSQLNAME("FQ5") + " FQ5 (NOLOCK) "                                                                     + CRLF  //FQ5
cQRY+= " ON FQ5_SOT = M0.FPU_PROJ AND FQ5_OBRA = M0.FPU_OBRA AND FQ5_AS = M0.FPU_AS "                                           + CRLF
cQRY+= " WHERE FQ5.D_E_L_E_T_ = '' AND M0.D_E_L_E_T_ = '' "													                    + CRLF

cQRY := CHANGEQUERY(cQRY) 
DBUSEAREA(.T.,"TOPCONN",TCGENQRY(,,cQRY),'QRYAS',.T.,.F.)

QRYAS->(DBGOTOP())

//monta o cabeçalho do HTML
cMsg := '	<!DOCTYPE html>						'   + CRLF
cMsg += '	<html>								'   + CRLF
//cMsg += '	<style>								'   + CRLF
//cMsg += '    	table, th, td {					'   + CRLF
//cMsg += '          border-left: 1px solid gray;	'   + CRLF
//cMsg += '          border-collapse: collapse;	'   + CRLF
//cMsg += '        }								'   + CRLF
//cMsg += '    </style>							'   + CRLF
//cMsg += '    <body style="font-family:verdana">	'   + CRLF

//Percorre os resultados
WHILE QRYAS->(!EOF())  
	
	//aglutina pela AS
    If cAs <> QRYAS->NR_AS

		//monta a query para a mesma AS
		cQRY:= " SELECT FPU_MAT AS COD , FPU_NOME AS NOME, FPU_DTLIM AS DATALIMITE , FPU_DTFIN "               + CRLF
		cQRY+= " FROM "+ RETSQLNAME("FPU") + " M0 (NOLOCK)"                                                    + CRLF
		cQRY+= " WHERE FPU_DTFIN = ''  AND FPU_AS = '"+ QRYAS->NR_AS + "' "                                    + CRLF
		cQRY+= " AND FPU_PROJ = '" + QRYAS->PROJ +"' "                                                         + CRLF
		cQRY+= " AND FPU_DTLIM BETWEEN  '"+DTOS(STOD(QRYAS->DATALIMITE)-7)+"' AND '"+ DTOS(DATE()) +"' "       + CRLF
		cQRY+= " AND FPU_DESIST = '2' "                                                                        + CRLF
		cQRY+= " ORDER BY COD "                                                                                + CRLF
		
		cQRY := CHANGEQUERY(cQRY) 
		DbUseArea(.T.,"TOPCONN",TcGenqry(,,cQry),'QRY',.T.,.F.)
		
		Count TO nReg
		
		//Se retornou registros prossegue
		IF nReg > 0
			
			QRY->(DBGOTOP())
			
			//cabeçalho por AS
			cMsg+= '<Font size = 2> <b> AS: </b>'  + QRYAS->NR_AS 	+ CRLF
			cMsg+= '	<b> ' + STR0008 + ': </b>' + QRYAS->PROJ 	+ CRLF //Projeto
			cMsg+= '	<b> ' + STR0009 + ': </b>' + QRYAS->OBRA 	+ CRLF	//Obra
			cMsg+= '	<b> ' + STR0010 + ': </b>' + QRYAS->NOMCLI 	+ CRLF	//Cliente
			cMsg+= '	<b> ' + STR0011 + ': </b>' + QRYAS->MUNEST 	+ CRLF	//Municipio
			cMsg+= '</font> <br>'									+ CRLF
			
			
			nReg1 	:= 1
			
			WHILE QRY->(!EOF())

				//cabeçalho da tabela
				IF  nReg1 == 1
					cMsg += '<table >'													+ CRLF
					cMsg += '	<tr bgcolor = blue> '									+ CRLF
					cMsg += '		<th><font color = white> ' + STR0002 + ' </font></th> '	+ CRLF	//Matricula
					cMsg += '		<th><font color = white> ' + STR0012 + ' </font></th>'	+ CRLF	//Funcionário
					cMsg += '		<th><font color = white> ' + STR0013 + ' </font></th> '	+ CRLF	//Data Limite
					cMsg += '	</tr>'													+ CRLF
				ENDIF
				
				//alterna a cor por linha 
				If Mod(nReg1,2) == 0
					cBgLinha := " bgcolor = Gainsboro "
				else
					cBgLinha := ""
				EndIf
				
				//linha com informações
				cMsg += '<tr ' + cBgLinha + '> '							+ CRLF
				cMsg += '	<td>' + QRY->COD + '</td> '						+ CRLF
				cMsg += '	<td>' + QRY->NOME + '</td> '					+ CRLF
				cMsg += '	<td>' + DTOC(STOD(QRY->DATALIMITE)) + '</td>'	+ CRLF
				cMsg += '</tr>'												+ CRLF
				
				nReg1++
				
				QRY->(DBSKIP())

				//se for o final do arquivo, fecha a tag da tabela
				If QRY->(EOF())
					cMsg += '</table> <p><p><hr>'							+ CRLF
				EndIf
				
			ENDDO
			
		ENDIF
		
		//atualiza AS para aglutinar ou não
		cAs := QRYAS->NR_AS
		
		QRY->(DBCLOSEAREA())
	
	ENDIF
	
	QRYAS->(DBSKIP())
	
ENDDO

QRYAS->(DBCLOSEAREA())
			
IF !Empty(cMsg)
	
	//fecha as tags
	cMsg+= '</body>'	+ CRLF
	cMsg+= '</html>'	+ CRLF

	//Atualiza informações par ao e-mail
	cAssunto	:= STR0014 // "Vencimento de data de Integração "
	cPara		:= SuperGetMV('MV_LOCX159',.F.,"jeulalio@itup.com.br")	 //email cadastrado
	cArq		:= '\Spool\integracao.html'
	
	//grava no Spool
	//memowrite(cArq,cMsg)
	//grava na pasta temporária local
	//If !lJob
		//memowrite(GetTempPath() + "integracao.html",cMsg)
		//oFWriter := FWFileWriter():New(GetTempPath() + "integracao.html", .T.)
		//oFWriter:Write(cMsg)
		//cArq := GetTempPath() + "integracao.html"
	//Else
		//oFWriter := FWFileWriter():New(cArq, .T.)
		//oFWriter:Write(cMsg)
	//EndIf
	
	//se não localizou o arquivo e foi chamado pela interface apresenta mensagem
	//If !File(cArq) .And. !IsBlind()
	//	MsgInfo(STR0021,"RENTAL")	//"Arquivo nao encontrado"
	//Endif
	
	// Funcao responsavel por Envio de email com mensagem anexa.
	SendEmail(""     ,cPara  ,""   ,cAssunto  ,cMsg  ,,'') 
	
	//exclui arquivo após envio
	//IF FILE (cArq)
	//	FERASE (cArq)
	//endif
	//oFWriter:Close()
	
ENDIF

Return

/*/{PROTHEUS.DOC} LOCA059.PRW
ITUP BUSINESS - TOTVS RENTAL
Envio de E-Mail
@TYPE FUNCTION
@AUTHOR ifranzoi
@SINCE 29/06/2021
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
Static Function SendEmail(cSender, cRecipient, cCpyEma, cSubJec, cBody, cAttFil, cCpyHdd, lMsg) 
// ======================================================================= \\
// --> Envia Email - Rotina Padrão

Local cEnvia    	:= AllTrim(GetMV("MV_RELFROM"))
Local cSrvMai		:= AllTrim(GetMV("MV_RELSERV"))
Local cFrmMai     	:= AllTrim(GetMV("MV_RELACNT"))
Local cPasWrd		:= AllTrim(GetMV("MV_RELPSW"))
Local lSmtpAuth  	:= GetMV("MV_RELAUTH",,.F.)
Local _lEnviado		:= .F.
Local _lConectou	:= .F.
Local _cMailError	:= ""

DEFAULT cBody 		:= "" 

cSender := cEnvia

//If IsInCallStack("APCRetorno")	
//	ConOut("Retornou WF")
//EndIf 
      
If Pcount() < 8																	// Não mostra a mensagem de email enviado com sucesso
	lMsg	:= .T.
EndIf 
                                                             	
Connect SMTP Server cSrvMai Account cFrmMai Password cPasWrd Result _lConectou	// Conecta ao servidor de email

If !(_lConectou)																// Se nao conectou ao servidor de email, avisa ao usuario
	Get Mail Error _cMailError
	If lMsg

		//"Não foi possível conectar ao Servidor de email."
		MsgStop( STR0015 + Chr(13) + Chr(10) + ; 
			     STR0016 + Chr(13) + Chr(10) + ; 
			   	 STR0017		  + _cMailError, "RENTAL") 
	EndIf
Else   
	If lSmtpAuth
		lAutOk := MailAuth(cFrmMai,cPasWrd)
    Else                      
        lAutOK := .T.
    EndIf
	If !lAutOk 
		If lMsg
			MsgStop( STR0018, "RENTAL")  //"Não foi possivel autenticar no servidor."
		EndIf
	Else   
		If Empty(cSender)
			cSender := Capital(StrTran(AllTrim(UsrRetName(RetCodUsr())),"."," ")) + " <" + AllTrim(cEnvia) + ">"
		EndIf
		If !Empty(cAttFil)
			Send Mail From cSender To cRecipient Cc cCpyEma BCC cCpyHdd SUBJECT cSubJec BODY cBody ATTACHMENT cAttFil Result _lEnviado
		Else
			Send Mail From cSender To cRecipient Cc cCpyEma BCC cCpyHdd SUBJECT cSubJec BODY cBody Result _lEnviado
		EndIf
		If !(_lEnviado)
			Get Mail Error _cMailError
			If lMsg
				MsgStop(STR0019	+ Chr(13) + Chr(10) +;
					    STR0016	+ Chr(13) + Chr(10) +;
					    STR0017	+ _cMailError, "RENTAL")
			EndIf
		Else
			If lMsg
				MsgInfo( STR0020, "RENTAL") //"E-Mail enviado com sucesso!"
			EndIf
		EndIf
    EndIf 

	Disconnect Smtp Server
EndIf 

Return _lEnviado

/*/{PROTHEUS.DOC} Scheddef
ITUP BUSINESS - TOTVS RENTAL
Agendamento de JOB - Retorno do Pergunte no Schedule
@TYPE FUNCTION
@AUTHOR ifranzoi
@SINCE 29/06/2021
@VERSION P12
@HISTORY 03/12/2020, FRANK ZWARG FUGA, FONTE PRODUTIZADO.
/*/
Static Function Scheddef()

Local cPerg  := "LOCP079"

Local aParam := {}

aParam := { "P",;
            cPerg,;
            "",;
            {},;
            "Schedule Default Ask"}

Return( aParam )
