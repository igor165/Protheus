#INCLUDE "WFSndRcv.ch"
#include "SigaWF.CH"

/*
	WFSndFiles	-	Envio de emails com arquivos atachados (compacta).
	WFRcvFiles	-	Recebimeto de emails com arquivos atachados (descompacta).
	Obs:	As funcoes de usuario definidas, tanto para envio, quanto para recebimento de arquivos,
			sao INEVITAVELMENTE executadas, antes ou depois da conexao e "down ou up" load dos e-mails,
			E PORTANTO, devem tratar a possibilidade de erro na conexao e da operacao ser abortada.
			
			Para verificar o sucesso de uma operacao de envio ou recebimento durante a construcao da
			funcao de usuario, verifique o status das seguintes variaveis privadas:

			nSndRcvError( N ) 	=	0 - Sucesso total no envio ou recebimento.
								Erros que ocorrem no envio:
								=  11 - Erro nenhum arquivo foi encontrado.
								=  12 - Erro durante a conexão Dial-Up.
								=  13 - Erro na operação com SMTP.
								=  14 - Erro compactando os arquivos.
								=  15 - Erro falta de destinatários.
								Erros que ocorrem durante o recebimento:
								=  21 - Erro durante a conexão Dial-Up.
								=  22 - Erro na operação com POP.
								=  23 - Erro nada consta na caixa postal.
								=  24 - Erro nenhum arquivo CAB foi anexado.
								=  25 - Erro descompactando os arquivos..
			nTotalFiles	( N )  - Numero total de attachments.
			nTotalMsg	( N )  - Numero total de mensagens recebidas ou enviadas.
			nEMLTotalMsg( N )  - Numero total de mensagens salvas EML.
*/

function WFRcvFiles( aParams )
	Local nC
	Local oTD
	Local aUserFuncs := {}

	default aParams := {}
	
	if len( aParams ) >= 2
		oTD := TWFTransDados():New( aParams )
		for nC := 3 to len( aParams )
			AAdd( aUserFuncs, aParams[ nC ] )
		end
		oTD:Receive( aUserFuncs )
	else
		ConOut( Replicate( "*",79 ) )
		ConOut( STR0001 ) //"* FALHA DE EXECUCAO"
		ConOut( STR0002 ) //"* Parametros insuficientes para a execucao do envio de arquivos."
		ConOut( STR0003 ) //"* WFRcvFiles( <cEmpresa>,<cFilial> )"
		ConOut( Replicate( "*",79 ) )
	end
	
return

function WFSndFiles( aParams )
	Local oTD
	
	default aParams := {}

	if len( aParams ) >= 3
		oTD := TWFTransDados():New( aParams )
		oTD:Send( aParams[3] )
	else
		ConOut( Replicate( "*",79 ) )
		ConOut( STR0001 ) //"* FALHA DE EXECUCAO"
		ConOut( STR0002 ) //"* Parametros insuficientes para a execucao do envio de arquivos."
		ConOut( STR0004 ) //"* WFSndFiles( <cEmpresa>,<cFilial>,<cCodigoEnvio> )"
		ConOut( Replicate( "*",79 ) )
	end

return


/******************************************************************************
	TDSendMail
	Rotina especifica para envio de mensagens do Transdados
	Parametros:
		aParams: { <cEmpresa>, <cFilial> }
******************************************************************************/
Procedure TDSendMail( aParams )
	if aParams <> nil
		StartJob( "WFLauncher", GetEnvServer(), .f., { "TDJobSndMail", aParams } )
	end
return

/******************************************************************************
	TDJobSndMail
	Complemento da funcao TDSendMail para execucao via job
	Parametros:
		aParams: { <cEmpresa>, <cFilial> }
******************************************************************************/
Procedure TDJobSndMail( aParams )
	local oMail := TWFMail():New( aParams )
	local cMailBox := AllTrim( WFGetMV( "MV_TDMLBOX", "" ) )
	local oMailBox := oMail:GetMailBox( cMailBox )
	oMailBox:bAfterSend := "TDAfterSend"
	oMailBox:Send()
return

/******************************************************************************
	TDAfterSend
	Complemento da funcao TDJobSndMail. Envento ocorrido apos o envio da mensagem.
******************************************************************************/
Procedure TDAfterSend( oMsg, aMessage )
	Local nC
	Local oTD
	default aMessage := {}
	if Len( aMessage ) > 0
		oTD := TWFTransDados():New()
		if len( aMessage[ MSG_ATTACHS ] ) > 0 
			for nC := 1 to len( aMessage[ MSG_ATTACHS ] )
				if ValType( aMessage[ MSG_ATTACHS ][ nC ] ) == "A"
					if file( aMessage[ MSG_ATTACHS ][ nC ][ 1 ] )
						WFMoveFiles( aMessage[ MSG_ATTACHS ][ nC ][ 1 ], oTD:cSndBkDir )
					end
				else
					if file( aMessage[ MSG_ATTACHS ][ nC ] )
						WFMoveFiles( aMessage[ MSG_ATTACHS ][ nC ], oTD:cSndBkDir )
					end
				end
			next
		end
	end
return
