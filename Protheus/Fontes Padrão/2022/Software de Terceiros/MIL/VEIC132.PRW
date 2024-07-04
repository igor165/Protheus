#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE "AP5MAIL.CH"
#INCLUDE "VEIC132.CH"

/*/{Protheus.doc} VEIC132
	Rotina via schedule ou pelo menu - envio de e-mail com Potencial de Bonus de Venda em relação ao Estoque/Pedido atual (chamada interna do VEIC131)

	@author Andre Luis Almeida
	@since  27/04/2021
/*/
Function VEIC132()
	//PROCESSO()
	BatchProcess(STR0001,; // Potencial de Bonus de Venda
				 STR0018+CHR(13)+CHR(10)+CHR(13)+CHR(10)+; // Envio de e-mail com Potencial de Bonus de Venda em relação ao Estoque/Pedido atual.
				 STR0003+": "+GetNewPar("MV_MIL0164",""),,{ || VC1320011_Processa() }) // Destinatário
Return .T.

/*/{Protheus.doc} VC1320011_Processa
	Função que faz a chamada do VEIC131 e depois envia o e-mail com os dados recebidos da funcao

	@author Andre Luis Almeida
	@since  27/04/2021
/*/
Static Function VC1320011_Processa()
Local aALLBonus  := VEIC131( .f. ) // Faz o levantamento do Potencial de Bonus de Venda em relação ao Estoque/Pedido atual
Local cTitulo    := STR0019 // Potencial de Bonus de Venda em relação ao Estoque/Pedido atual
Local cMensagem  := ""
If ExistBlock("VC132EML")
	cMensagem := ExecBlock("VC132EML",.f.,.f.,{ cTitulo , aClone(aALLBonus) }) // Corpo do E-mail customizado
Else
	cMensagem := VC1320021_Monta_Email( cTitulo , aClone(aALLBonus) ) // Montagem do Corpo do E-mail Padrão
EndIf
If !Empty(cMensagem)
	VC1320031_Enviar_Email( cTitulo , cMensagem ) // Enviar o E-mail
EndIf
If ExistBlock("VC132FIM")
	ExecBlock("VC132FIM",.f.,.f.,{ cTitulo , aClone(aALLBonus) }) // PE executado no final do processo
EndIf
Return .T.

/*/{Protheus.doc} VC1320021_Monta_Email
	Montagem do E-mail

	@author Andre Luis Almeida
	@since  29/04/2021
/*/
Static Function VC1320021_Monta_Email( cTitulo , aALLBonus )
Local cMensagem  := ""
Local aALLVeic   := {}
Local nCntFor    := 0
Local nCntVei    := 0
Local cFCabec    := "<font size=2 face='verdana,arial' Color=RED>"
Local cFLista    := "<font size=2 face='verdana,arial' Color=BLACK>"
//
cMensagem += "<TABLE width=100% border=1>"
cMensagem += "<TR>"
cMensagem += "<TD COLSPAN=6 bgcolor=silver><br><br><center>"
cMensagem += "<font size=5 face='verdana,arial' Color=#0000cc><b>"+cTitulo+"</b></font>"
cMensagem += "<br><br><font size=3 face='verdana,arial' Color=black>"+Transform(dDataBase,"@D")+" "+Time()+"</font>"
cMensagem += "</center><br><br></TD>"
cMensagem += "</TR>"
cMensagem += "<TR>"
cMensagem += "<TD width=40% bgcolor=silver><center>"+cFCabec+"<b>"+STR0005+"</b></font></center></TD>" // Bonus
cMensagem += "<TD width=11% bgcolor=silver><center>"+cFCabec+"<b>"+"%"+"</b></font></center></TD>" // %
cMensagem += "<TD width=12% bgcolor=silver><center>"+cFCabec+"<b>"+STR0006+"</b></font></center></TD>" // Dt.Inicial
cMensagem += "<TD width=12% bgcolor=silver><center>"+cFCabec+"<b>"+STR0007+"</b></font></center></TD>" // Dt.Final
cMensagem += "<TD width=10% bgcolor=silver><center>"+cFCabec+"<b>"+STR0008+"</b></font></center></TD>" // Quantidade
cMensagem += "<TD width=15% bgcolor=silver><center>"+cFCabec+"<b>"+STR0009+"</b></font></center></TD>" // Vlr.Liquido
cMensagem += "</TR>"
For nCntFor := 1 to len(aALLBonus) // Resumo por Bonus
	cMensagem += "<TR>"
	cMensagem += "<TD>"+cFLista+"<b>"+aALLBonus[nCntFor,01]+" - "+aALLBonus[nCntFor,02]+"</b></font></TD>"
	cMensagem += "<TD><center>"+cFLista+"<b>"+Transform(aALLBonus[nCntFor,08],"@EZ 99.9999")+"</b></font></center></TD>"
	cMensagem += "<TD><center>"+cFLista+"<b>"+aALLBonus[nCntFor,06]+"</b></font></center></TD>"
	cMensagem += "<TD><center>"+cFLista+"<b>"+aALLBonus[nCntFor,07]+"</b></font></center></TD>"
	cMensagem += "<TD><center>"+cFLista+"<b>"+Transform(aALLBonus[nCntFor,03],"@E 999,999")+"</b></font></center></TD>"
	cMensagem += "<TD align=right>"+cFLista+"<b>"+Transform(aALLBonus[nCntFor,04],"@E 999,999,999,999.99")+"</b></font></TD>"
	cMensagem += "</TR>"
Next
cMensagem += "</TABLE><br><br><hr><br><br>"
cMensagem += "<TABLE width=100% border=1>"
cMensagem += "<TR>"
cMensagem += "<TD bgcolor=silver><br><center><font size=4 face='verdana,arial' Color=#0000cc><b>"+STR0010+"</b></font></center><br></TD>" // Veiculo/Máquina por Bonus de Venda
cMensagem += "</TR>"
cMensagem += "</TABLE>"
For nCntFor := 2 to len(aALLBonus)
	cMensagem += "<br><br>"
	cMensagem += "<TABLE width=100% border=1>"
	cMensagem += "<TR>"
	cMensagem += "<TD width=40% bgcolor=silver><center>"+cFCabec+"<b>"+STR0005+"</b></font></center></TD>" // Bonus
	cMensagem += "<TD width=11% bgcolor=silver><center>"+cFCabec+"<b>"+"%"+"</b></font></center></TD>" // %
	cMensagem += "<TD width=12% bgcolor=silver><center>"+cFCabec+"<b>"+STR0006+"</b></font></center></TD>" // Dt.Inicial
	cMensagem += "<TD width=12% bgcolor=silver><center>"+cFCabec+"<b>"+STR0007+"</b></font></center></TD>" // Dt.Final
	cMensagem += "<TD width=10% bgcolor=silver><center>"+cFCabec+"<b>"+STR0008+"</b></font></center></TD>" // Quantidade
	cMensagem += "<TD width=15% bgcolor=silver><center>"+cFCabec+"<b>"+STR0009+"</b></font></center></TD>" // Vlr.Liquido
	cMensagem += "</TR>"
	cMensagem += "<TR>"
	cMensagem += "<TD>"+cFLista+"<b>"+aALLBonus[nCntFor,01]+" - "+aALLBonus[nCntFor,02]+"</b></font></TD>"
	cMensagem += "<TD><center>"+cFLista+"<b>"+Transform(aALLBonus[nCntFor,08],"@EZ 99.9999")+"</b></font></center></TD>"
	cMensagem += "<TD><center>"+cFLista+"<b>"+aALLBonus[nCntFor,06]+"</b></font></center></TD>"
	cMensagem += "<TD><center>"+cFLista+"<b>"+aALLBonus[nCntFor,07]+"</b></font></center></TD>"
	cMensagem += "<TD><center>"+cFLista+"<b>"+Transform(aALLBonus[nCntFor,03],"@E 999,999")+"</b></font></center></TD>"
	cMensagem += "<TD align=right>"+cFLista+"<b>"+Transform(aALLBonus[nCntFor,04],"@E 999,999,999,999.99")+"</b></font></TD>"
	cMensagem += "</TR>"
	cMensagem += "</TABLE>"
	//
	aALLVeic := aClone(aALLBonus[nCntFor,05]) // Veiculos/Maquinas referente ao Bonus posicionado
	//
	cMensagem += "<TABLE width=100% border=1>"
	cMensagem += "<TR>"
	cMensagem += "<TD width=11%><center>"+cFCabec+"<b>"+STR0011+"</b></font></center></TD>" // Dt.Pedido
	cMensagem += "<TD width=11%><center>"+cFCabec+"<b>"+STR0012+"</b></font></center></TD>" // Marcado Vendido
	cMensagem += "<TD width=11%><center>"+cFCabec+"<b>"+STR0013+"</b></font></center></TD>" // Marca
	cMensagem += "<TD width=20%><center>"+cFCabec+"<b>"+STR0014+"</b></font></center></TD>" // Modelo
	cMensagem += "<TD width=13%><center>"+cFCabec+"<b>"+STR0015+"</b></font></center></TD>" // Cor
	cMensagem += "<TD width=14%><center>"+cFCabec+"<b>"+STR0016+"</b></font></center></TD>" // Chassi
	cMensagem += "<TD width=08%><center>"+cFCabec+"<b>"+STR0020+"</b></font></center></TD>" // Situação
	cMensagem += "<TD width=12%><center>"+cFCabec+"<b>"+STR0009+"</b></font></center></TD>" // Vlr.Liquido
	cMensagem += "</TR>"
	//
	For nCntVei := 1 to len(aALLVeic)
		cMensagem += "<TR>"
		cMensagem += "<TD><center>"+cFLista+aALLVeic[nCntVei,09]+"</font></center></TD>"
		cMensagem += "<TD><center>"+cFLista+aALLVeic[nCntVei,10]+"</font></center></TD>"
		cMensagem += "<TD>"+cFLista+aALLVeic[nCntVei,02]+"</font></TD>"
		cMensagem += "<TD>"+cFLista+aALLVeic[nCntVei,03]+"</font></TD>"
		cMensagem += "<TD>"+cFLista+aALLVeic[nCntVei,04]+"</font></TD>"
		cMensagem += "<TD>"+cFLista+aALLVeic[nCntVei,05]+"</font></TD>"
		cMensagem += "<TD><center>"+cFLista+IIf(aALLVeic[nCntVei,11]=="8",STR0022,STR0021)+"</font></center></TD>" // Pedido / Estoque
		cMensagem += "<TD align=right>"+cFLista+Transform(aALLVeic[nCntVei,07],"@E 999,999,999,999.99")+"</font></TD>"
		cMensagem += "</TR>"
	Next
	cMensagem += "</TABLE>"
Next
If !Empty(cMensagem)
	//
	aALLVeic := aClone(aALLBonus[1,05]) // Fazer o RESUMO por Veiculo/Máquina
	//
	cMensagem += "<br><br><hr><br><br>"
	cMensagem += "<TABLE width=100% border=1>"
	cMensagem += "<TR>"
	cMensagem += "<TD COLSPAN=9 bgcolor=silver><br><center><font size=4 face='verdana,arial' Color=#0000cc><b>"+STR0017+"</b></font></center><br></TD>" // Totais dos Bonus de Venda por Veiculo/Máquina
	cMensagem += "</TR>"
	cMensagem += "<TR>"
	cMensagem += "<TD width=10%><center>"+cFCabec+"<b>"+STR0011+"</b></font></center></TD>" // Dt.Pedido
	cMensagem += "<TD width=10%><center>"+cFCabec+"<b>"+STR0012+"</b></font></center></TD>" // Marcado Vendido
	cMensagem += "<TD width=10%><center>"+cFCabec+"<b>"+STR0013+"</b></font></center></TD>" // Marca
	cMensagem += "<TD width=20%><center>"+cFCabec+"<b>"+STR0014+"</b></font></center></TD>" // Modelo
	cMensagem += "<TD width=10%><center>"+cFCabec+"<b>"+STR0015+"</b></font></center></TD>" // Cor
	cMensagem += "<TD width=11%><center>"+cFCabec+"<b>"+STR0016+"</b></font></center></TD>" // Chassi
	cMensagem += "<TD width=08%><center>"+cFCabec+"<b>"+STR0020+"</b></font></center></TD>" // Situação
	cMensagem += "<TD width=10%><center>"+cFCabec+"<b>"+STR0008+"</b></font></center></TD>" // Quantidade
	cMensagem += "<TD width=11%><center>"+cFCabec+"<b>"+STR0009+"</b></font></center></TD>" // Vlr.Liquido
	cMensagem += "</TR>"
	//
	For nCntVei := 1 to len(aALLVeic)
		cMensagem += "<TR>"
		cMensagem += "<TD><center>"+cFLista+aALLVeic[nCntVei,09]+"</font></center></TD>"
		cMensagem += "<TD><center>"+cFLista+aALLVeic[nCntVei,10]+"</font></center></TD>"
		cMensagem += "<TD>"+cFLista+aALLVeic[nCntVei,02]+"</font></TD>"
		cMensagem += "<TD>"+cFLista+aALLVeic[nCntVei,03]+"</font></TD>"
		cMensagem += "<TD>"+cFLista+aALLVeic[nCntVei,04]+"</font></TD>"
		cMensagem += "<TD>"+cFLista+aALLVeic[nCntVei,05]+"</font></TD>"
		cMensagem += "<TD><center>"+cFLista+IIf(aALLVeic[nCntVei,11]=="8",STR0022,STR0021)+"</font></center></TD>" // Pedido / Estoque
		cMensagem += "<TD align=right>"+cFLista+Transform(aALLVeic[nCntVei,06],"@E 999,999")+"</font></TD>"
		cMensagem += "<TD align=right>"+cFLista+Transform(aALLVeic[nCntVei,07],"@E 999,999,999,999.99")+"</font></TD>"
		cMensagem += "</TR>"
	Next
	cMensagem += "</TABLE>"
	cMensagem += "<br><hr>"
	//
EndIf
Return cMensagem

/*/{Protheus.doc} VC1320031_Enviar_Email
	Enviar E-mail

	@author Andre Luis Almeida
	@since  27/04/2021
/*/
Static Function VC1320031_Enviar_Email( cTitulo , cMensagem )
Local lOk        := .f.
Local lSendOK    := .f.
Local cError     := ""
Local cMailConta := GETMV("MV_EMCONTA") // Usuario/e-mail de envio
Local cMailServer:= GETMV("MV_RELSERV") // Server de envio
Local cMailSenha := GETMV("MV_EMSENHA") // Senha e-mail de envio
Local lAutentica := GetMv("MV_RELAUTH",,.f.)          // Determina se o Servidor de E-mail necessita de Autenticacao
Local cUserAut   := Alltrim(GetMv("MV_RELAUSR",," ")) // Usuario para Autenticacao no Servidor de E-mail
Local cPassAut   := Alltrim(GetMv("MV_RELAPSW",," ")) // Senha para Autenticacao no Servidor de E-mail
Local cEmail	 := GetNewPar("MV_MIL0164","") // E-mail para receber o Potencial de Bonus de Venda em relação ao Estoque/Pedido atual
// Enviar o e-mail
If !Empty(cMailConta) .And. !Empty(cMailServer) .And. !Empty(cMailSenha) .and. !Empty(cEmail)
	// Conecta uma vez com o servidor de e-mails
	CONNECT SMTP SERVER cMailServer ACCOUNT cMailConta PASSWORD cMailSenha RESULT lOk
	If lOk
		lOk := .f.
		If lAutentica
			If !MailAuth(cUserAut,cPassAut) // Erro no envio de e-mail.
				DISCONNECT SMTP SERVER
			Else
				lOk := .t.
			EndIf
		Else
			lOk := .t.
		EndIf
		If lOk
			// Envia e-mail com os dados necessarios
			SEND MAIL FROM cMailConta to Alltrim(cEmail) SUBJECT (cTitulo) BODY cMensagem FORMAT TEXT RESULT lSendOk
			If !lSendOk // Erro no Envio do e-mail
				GET MAIL ERROR cError 
			EndIf
			// Desconecta com o servidor de e-mails
			DISCONNECT SMTP SERVER
		EndIf
	EndIf
EndIf
//
Return