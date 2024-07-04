#Include "MNTW060.ch"
#Include "RWMAKE.CH"
#Include "PROTHEUS.CH"
#Include "TOPCONN.CH"

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW060
Workflow de aviso de inclus�o de multa
@type function

@author Ricardo Dal Ponte
@since 09/04/2007

@sample MNTW060( '0001' )

@param  cMulta, Caracter, N�mero da multa incluida.
@return L�gico, Define se o workflow foi enviado com �xito.

@obs Reescrito por: Alexandre Santos, 11/04/2019.
/*/
//---------------------------------------------------------------------
Function MNTW060( cMulta )

	Local cMail := ''
	Local lRet  := .T.

	dbSelectArea( 'TRX' )
	dbSetOrder( 1 )
	If !dbSeek( xFilial( 'TRX' ) + cMulta )

		lRet := .F.

	Else

		cMail := MntRetMail( TRX->TRX_PLACA, 'MNTW060' )

		If !Empty( cMail )

			Processa( { || MNTW060F( cMail ) } )

		Else

			lRet := .F.

		EndIf

	EndIf

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MNTW060F
Envio do Workflow
@type function

@author Ricardo Dal Ponte
@since 09/04/2007

@sample MNTW060F( 'perug@email.com' )

@param  cMail , Caracter, E-mails que seram destino para o workflow.
@return L�gico, Define se o workflow foi enviado com �xito.
/*/
//---------------------------------------------------------------------
Function MNTW060F( cMail )

	Local aArea		 := GetArea()
	Local aRegistros := {}
	Local aCampos	 := {}
	Local aProcessos := {}

	Local cBodyHtml  := ''

	Local lRet       := .T.

	dbSelectArea("DA4")
	dbSetOrder(1)
	cMotorista := ""

	If dbSeek(xFilial("DA4") + TRX->TRX_CODMO)
		cMotorista := DA4->DA4_NOME
	EndIf

	If !Empty(cMotorista)
		cStrTEXTO1 := STR0009+" "+cMotorista+" "+STR0010+":" //"O motorista Sr."###"cometeu o seguinte ato infracional"
	Else
		cStrTEXTO1 := STR0037+":" //"O motorista n�o foi informado no ato infracional"
	EndIf
	cStrTexto2 := STR0011 + " " + ; //"Caso o infrator queira recorrer da multa, o mesmo dever� entrar em contato"
	              STR0012 + "."		//"com a Gest�o de Riscos para as devidas orienta��es."

	cTRX_DTINFR := DTOC(TRX->TRX_DTINFR)
	cTRX_RHINFR := TRX->TRX_RHINFR
	cTRX_LOCAL  := TRX->TRX_LOCAL
	cTRX_CIDINF := TRX->TRX_CIDINF
	cTRX_UFINF  := TRX->TRX_UFINF

	dbSelectArea("ST9")
	dbSetOrder(14)

	cNomBem := ""
	cPlaca := ""

	If dbSeek(TRX->TRX_PLACA)
		cNomBem := AllTrim(ST9->T9_NOME)
		cPlaca  := AllTrim(ST9->T9_PLACA)
	EndIf

	cTRX_Frota  := cPlaca + " - " + cNomBem

	cTRX_NUMAIT := TRX->TRX_NUMAIT
	cTRX_CODINF := TRX->TRX_CODINF

	dbSelectArea("TSH")
	dbSetOrder(1)

	cTRX_DESART := ""
	cTRX_PONTOS := ""

	If dbSeek(xFilial("TSH") + TRX->TRX_CODINF)
		cTRX_DESART := AllTrim(TSH->TSH_DESART)
		cTRX_PONTOS := TSH->TSH_PONTOS
	EndIf

	dbSelectArea("TRX")
	cTRX_DESOBS := IIf(FieldPos('TRX_MMSYP') > 0, MSMM(TRX->TRX_MMSYP, 80), IIf(FieldPos('TRX_OBS') > 0, TRX->TRX_OBS, " "))

	aAdd(aRegistros, {;
							STR0013,; //"Data Infra��o"
							STR0014,; //"Hor�rio"
							STR0015,; //"Local"
							STR0016,; //"Munic�pio"
							STR0017,; //"UF"
							STR0018,; //"Placa/Ve�culo"
							STR0019,; //"Auto de Infra��o"
							STR0020,; //"Infra��o"
							STR0021,; //"Descri��o"
							STR0022,; //"Observa��o"
							STR0023,; //"Pontos"
							cTRX_DTINFR,;
							cTRX_RHINFR,;
							cTRX_LOCAL,;
							cTRX_CIDINF,;
							cTRX_UFINF,;
							cTRX_Frota,;
							cTRX_NUMAIT,;
							cTRX_CODINF,;
							cTRX_DESART,;
							cTRX_DESOBS,;
							cTRX_PONTOS;
					};
		)

	If Len( aRegistros ) == 0
		lRet := .F.
	ElseIf FindFunction( 'NGUseTWF' ) .And. NGUseTWF( 'MNTW060' )[1]
		aCampos := {;
						{ 'cSubTitulo'      , DtoC(MsDate()) + ' - ' + STR0024 },; // Aviso de Inclus�o de Multa
						{ 'it1.TEXTO1' 		, cStrTEXTO1 },; // O motorista Sr."###"cometeu o seguinte ato infracional #OU# O motorista n�o foi informado no ato infracional
						{ 'it2.TRX_DTINFR'  , STR0013 },; // Data Infra��o
						{ 'it2.TRX_RHINFR'  , STR0014 },; // Hor�rio
						{ 'it2.TRX_LOCAL'   , STR0015 },; // Local
						{ 'it2.TRX_CIDINF'  , STR0016 },; // Munic�pio
						{ 'it2.TRX_UFINF'   , STR0017 },; // UF
						{ 'it2.TRX_Frota'   , STR0018 },; // Placa/Ve�culo
						{ 'it2.TRX_NUMAIT'  , STR0019 },; // Auto de Infra��o
						{ 'it4.TRX_CODINF'  , STR0020 },; // Infra��o
						{ 'it4.TRX_DESART'  , STR0021 },; // Descri��o
						{ 'it4.TRX_DESOBS'  , STR0022 },; // Observa��o
						{ 'it4.TRX_PONTOS'  , STR0023 },; // Pontos
						{ 'it3.TRX_DTINFR'  , cTRX_DTINFR },;
						{ 'it3.TRX_RHINFR'  , cTRX_RHINFR },;
						{ 'it3.TRX_LOCAL'   , cTRX_LOCAL },;
						{ 'it3.TRX_CIDINF'  , cTRX_CIDINF },;
						{ 'it3.TRX_UFINF'   , cTRX_UFINF },;
						{ 'it3.TRX_Frota'   , cTRX_Frota },;
						{ 'it3.TRX_NUMAIT'  , cTRX_NUMAIT },;
						{ 'it5.TRX_CODINF'  , cTRX_CODINF },;
						{ 'it5.TRX_DESART'  , cTRX_DESART },;
						{ 'it5.TRX_DESOBS'  , cTRX_DESOBS },;
						{ 'it5.TRX_PONTOS'  , cTRX_PONTOS };
					}

		// Fun��o para cria��o do objeto da classe TWFProcess responsavel pelo envio de workflows.
		aProcessos := NGBuildTWF( cMail, 'MNTW060', STR0024, 'MNTW060', aCampos ) 

		// Consiste se foi possivel a inicializa��o do objeto TWFProcess.
		If aProcessos[1]
			// Fun��o que realiza o envio do workflow conforme defini��es do objeto passado por par�metro.
			NGSendTWF( aProcessos[2] )
		EndIf
	Else
		cBodyHtml += '<html>'
		cBodyHtml += '<head>'
		cBodyHtml += '<meta http-equiv="Content-Language" content="pt-br">'
		cBodyHtml += '<meta http-equiv="Content-Type" content="text/html; charset=windows-1252">'
		cBodyHtml += '<meta name="GENERATOR" content="Microsoft FrontPage 4.0">'
		cBodyHtml += '<meta name="ProgId" content="FrontPage.Editor.Document">'
		cBodyHtml += '<title>'+ STR0024 + '</title>' //"Aviso de Inclus�o de Multa"
		cBodyHtml += '</head>'

		cBodyHtml += '<noscript><b><U><font face="Arial" size=2 color="#FF0000"></font></b>'
		cBodyHtml += '</noscript>'

		cBodyHtml += '<p><b><font face="Arial">' + DtoC(MsDate()) + " - " + STR0024 + '</font></b></p>' //"Aviso de Inclus�o de Multa"
		cBodyHtml += '</u>'

		cBodyHtml += '<table border=0 WIDTH=100% cellpadding="1">'
		cBodyHtml += '<tr>'
		cBodyHtml += '<p><font face="Arial" size="2">' + cStrTEXTO1 + '</font></p>'
		cBodyHtml += '</tr>'
		cBodyHtml += '</table>'
		cBodyHtml += '<table border=0 WIDTH=100% cellpadding="1">'
		cBodyHtml += '<tr>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,1] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,2] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,3] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,4] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,5] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,6] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#C0C0C0" align="left"><b><font face="Arial" size="2">' + aRegistros[1,7] + '</font></b></td>'
		cBodyHtml += '<tr>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,12] + '</font></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,13] + '</font></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,14] + '</font></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,15] + '</font></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,16] + '</font></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,17] + '</font></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left"><font face="Arial" size="1">' + aRegistros[1,18] + '</font></td>'
		cBodyHtml += '</tr>'

		cBodyHtml += '</table>'
		cBodyHtml += '&nbsp;'
		cBodyHtml += '<table border=0 WIDTH=655 cellpadding="1">'

		cBodyHtml += '<tr>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">' + aRegistros[1,8] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">' + aRegistros[1,19] + '</font></td>'
		cBodyHtml += '<tr>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">' + aRegistros[1,9] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">' + aRegistros[1,20] + '</font></td>'
		cBodyHtml += '<tr>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">' + aRegistros[1,10] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">' + aRegistros[1,21] + '</font></td>'
		cBodyHtml += '<tr>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="157"><b><font face="Arial" size="2">' + aRegistros[1,11] + '</font></b></td>'
		cBodyHtml += 	'<td bgcolor="#EEEEEE" align="left" width="420"><font face="Arial" size="1">' + aRegistros[1,22] + '</font></td>'
		cBodyHtml += 	'</table>'
		cBodyHtml += 	'<br><hr>'

		lRet := NGSendMail( , cMail , , , STR0024 , , cBodyHtml ) // Aviso de Inclus�o de Multa

		If lRet
			MsgInfo( STR0026 + ': ' + Lower( cMail ), STR0027 ) // Aviso de Inclus�o de Multa enviado para # Aten��o
		EndIf
	EndIf

	RestArea( aArea )

Return lRet

//---------------------------------------------------------------------
/*/{Protheus.doc} MntRetMail
Monta string com e-mails de destino para o workflow.
@type function

@author Alexandre Santos
@since 11/04/2019

@sample MntRetMail( 'PLA-1234' )

@param  cBoard , Caracter, Placa do ve�culo vinculado a multa.
@return cReturn, Caracter, E-mails de destino para o workflow.
/*/
//---------------------------------------------------------------------
Function MntRetMail( cBoard, cWorkflow )

	Local aArea    := GetArea()
	Local cMailRsp := Trim( SuperGetMv( 'MV_NGRESMU' ) )
	Local cLeasP   := Trim( SuperGetmv( 'MV_NGLEASP' ) )
	Local cMail    := NgEmailWF( '3', cWorkflow )

	If cWorkflow $ 'MNTW060#MNTW061'

		dbSelectArea( 'ST9' )
		dbSetOrder( 14 ) // T9_PLACA + T9_SITBEM
		If dbSeek( cBoard )

			If cLeasP == ST9->T9_STATUS

				dbSelectArea( 'TSJ' )
				dbSetOrder( 1 )
				If dbSeek( xFilial( 'TSJ' ) + ST9->T9_CODBEM )

					If !Empty( TSJ->TSJ_EMAIL ) .And. !( TSJ->TSJ_EMAIL $ cMail )

					cMail += Trim( TSJ->TSJ_EMAIL ) + ';'

					EndIf

				EndIf

			EndIf

		EndIf

	EndIf

	// Executa ponto de entrada para altera��o de destinat�rio.
	If cWorkflow == 'MNTW060'

		// Ponto de entrada para alterar destinat�rio de email de multas
		If ExistBlock( 'MNTW0601' )
			cMail := ExecBlock( 'MNTW0601', .F., .F., cMail )
		EndIf

	ElseIf cWorkflow == 'MNTW061'

		//Ponto de entrada para alterar destinat�rio de email de notifica��es
		If ExistBlock( 'MNTW0611' )
			cMail := ExecBlock( 'MNTW0611', .F., .F., cMail )
		EndIf

	EndIf

	// Inclui o e-mail do respons�vel por multas nos e-mails de destinat�rio.
	If !Empty( cMailRsp ) .And. !( cMailRsp $ cMail )

		cMail += cMailRsp

	EndIf

	// Remove ponto e virgula excedente.
	If SubStr( cMail, Len( cMail ) ) == ';'
		cMail := SubStr( cMail, 1, Len( cMail ) - 1 )
	EndIf

	RestArea( aArea )

Return cMail
