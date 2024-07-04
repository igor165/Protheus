#INCLUDE "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.ch"
#INCLUDE "AGRX500J.ch"

#DEFINE _CRLF CHR(13)+CHR(10)

/*/{Protheus.doc} AX500PRFUN
//Pré função gerada usada para exibir os pontos de controle QUE ESTEJAM VINCULADOS A UM REGISTRO DA N93 NO
// TIPO DE OPERAÇÃO DO ROMANEIO.
@author brunosilva
@since 04/06/2018

@type function
/*/
Function AX500PRFUN(cChamada)
	Local lRet		:= .T.
	Local cNrAgen	:= ""
	Local cNmRom	:= ""
	Local cOper		:= ""
	Local cEtapa	:= ""		
	Local cCdPtCt	:= ""
	Local cCdPerg	:= ""
	Local cMsg		:= ""
	Local aArea		:= GetArea()
	Local aRetRom	:= Nil
	Local cRet		:= ""
	Local cQry		:= ""
	
	Private _lAltIE		:= .F. //indica se houve alteração/inclusão na IE
	
	Default cChamada	:= ""
	
	//Pega o numero do agendamento GFE
	cNrAgen := GWV->GWV_NRAGEN
	
	//Caso esteja vazio, não existe agendamento a ser considerado
	if EMPTY(cNrAgen) .AND. FWISINCALLSTACK('GFE519BLK')
		cMsg := STR0012 //"Agendamento GFE não encontrado. Para executar esta pergunta, é obrigatório um agendamento GFE relacionado a um agendamento AGRO."
		
		MSGINFO( cMsg , STR0001 )	//'Atenção'
		lRet := .F.
	else
		//Pega o codigo do ponto de controle em que a movimentação esta posicionado.
		cCdPtCt	:= GX4->GX4_CDPTCT
		
		/*PE PARA CHAMADA DE MENU*/
		If EXISTBLOCK ("AX500PE1") .AND. !FWISINCALLSTACK('GFE519BLK') .AND. Empty(cChamada)
			cRet := ExecBlock("AX500PE1",.F.,.F.)
			If ValType(cRet) == "C"
				cCdPerg := cRet
			EndIf
		else
			cCdPerg	:= GVH->GVH_CDPERG
		EndIf
		
		//Busca o numero do romaneio AGRO a partir do agendamento GFE
		//aRetRom[1] = Numero do romaneio
		//aRetRom[2] = Codigo Tipo de operação AGRO
		if !Empty(cNrAgen)
			aRetRom := AGRRomDoAg(cNrAgen)
		endIf
		
		if empty(aRetRom) .AND. Empty(cChamada)
			cMsg := STR0012 //"Agendamento AGRO não encontrado. Para executar esta pergunta, é obrigatório um agendamento AGRO relacionado a um agendamento GFE."
		
			MSGINFO( cMsg , STR0001 )	//'Atenção'
			lRet := .F.
		elseif !Empty(cChamada) .AND. (UPPER(cChamada) == "PESAGEM") .AND. empty(aRetRom)
			//TODO PONTO DE ENTRADA DO GFE PARA ABRIR A PESAGEM AVULSA
			If EXISTBLOCK ("AX500PE2")
				lRet := ExecBlock("AX500PE2",.F.,.F.)
			EndIf			
		elseif !empty(aRetRom) //.AND. !Empty(cChamada)
			cNmRom  := aRetRom[1]
			cOper	:= aRetRom[2]			
			if !EMPTY(cCdPerg) .AND. Empty(cChamada)
				dbSelectArea("N93")
				N93->(DbSetOrder(2))
				If N93->(DbSeek(FWxFilial("N93") + cOper + cCdPtCt + cCdPerg)) 
					If N93->N93_OK == .T.	//--Verifica se o check estiver preenchido.
						//ETAPA DO TIPO DE OPERAÇÃO AGRO QUE CORRESPONDE AO PONTO DE CONTROLE.
						cEtapa := N93->N93_CODIGO
						lRet   := .T.
					Else
						lRet := .F.
						//"Etapa não foi selecionada."
						cMsg := STR0003 +_CRLF
						//"Favor selecionar Etapa no cadastro de Tipo de Operação do Romaneio."
						cMsg += STR0011
						MSGINFO( cMsg, STR0001 )	//'Atenção'
					EndIf
				Else
					lRet := .F.
					//"Ponto de Controle não informado para essa Etapa."
					cMsg := STR0002 + _CRLF
					//"Favor informar o Ponto de Controle correspondente à Etapa no cadastro de Tipo de Operação do Romaneio."
					cMsg += STR0010
					MSGINFO( cMsg, STR0001 )	//'Atenção'
				EndIf
			elseif !Empty(cChamada) //.AND. EMPTY(cCdPerg)  
				if UPPER(cChamada) == "PESAGEM"
					cQry := "SELECT N94_CODTO FROM "+RetSQLName("N94")+" N94 WHERE N94_FILIAL =  '" + FWXFILIAL("N94") + "' AND N94_CODTO = '" + cOper + "' AND N94_QTCPES = 'T' "
					If Empty(GetDataSql(cQry))
						lRet := .F.
						cMsg := "O Tipo de operação do Romaneio não contem nenhuma etapa de pesagem" + _CRLF
						cMsg += "Não é possível efetuar a operação de pesagem para este agendamento."
						MSGINFO( cMsg, STR0001 )	//'Atenção'
					endIf									
				endIf
			else
				lRet := .F.
				//"Etapa não foi selecionada."
				cMsg := STR0003 +_CRLF
				//"Favor selecionar Etapa no cadastro de Tipo de Operação do Romaneio."
				cMsg += STR0011
				MSGINFO( cMsg, STR0001 )	//'Atenção'
			endIf
			
			If lRet	//Chama a função de pop-up.
				dbSelectArea("NJJ")
				NJJ->(DbSetOrder(1))
				If NJJ->(DbSeek(FWxFilial("NJJ") + cNmRom ))
					//--Status diferente de 2=Atualizado/3=Confirmado/4=Cancelado
					If NJJ->NJJ_STATUS $ "0|1|5|6"	//--0=Pendende/1=Completo/5=Pendente Aprovação/6=Previsto
						lRet := AGRA500POP(cNmRom, cOper, cEtapa,cChamada,cCdPtCt)
					Else
						lRet := .F.
						//"Romaneio não pode ser alterado com status igual a "#"Atualizado."#"Confirmado."#"Cancelado."
						cMsg := STR0004 + If(NJJ->NJJ_STATUS=="2", STR0005, If(NJJ->NJJ_STATUS=="3",STR0006, STR0007)) + _CRLF	
						//"Favor verificar o Romaneio "#" pelo módulo 67 - Gestão de Agronegócio."
						cMsg += STR0008 + Alltrim(cNmRom) +STR0009
						MSGINFO( cMsg , STR0001 )	//'Atenção'
					EndIf
				EndIf
			EndIf
		endIf
	endIf
	
	RestArea(aArea)
	
Return lRet