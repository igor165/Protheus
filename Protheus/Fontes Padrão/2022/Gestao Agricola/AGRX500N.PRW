#INCLUDE "AGRX500.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//===========================================================================================================
/*****  Fun��es relacionadas a execu��o da atualiza��o/confirma��o do romaneio no P�tios e Portarias  *****/
//===========================================================================================================


/*/{Protheus.doc} AX500NAtuC
Fun��o que ser� chamada no ponto de controle do GFE para atualizar/confirmar o Romaneio
@author silvana.torres
@since 05/06/2018
@version undefined

@type function
/*/
Function AX500NAtu()
	Local lRet		:= .T.
	Local cNrAgen	:= ""
	Local aArea		:= GetArea()
	
	Private _lAltIE		:= .F. //indica se houve altera��o/inclus�o na IE
	
	//Pega o numero do agendamento GFE
	cNrAgen := GWV->GWV_NRAGEN

	lRet := AX500NAtCo(cNrAgen)

	RestArea(aArea)

Return lRet

/*/{Protheus.doc} AX500NAtCo
Fun��o que ir� chamar a rotina de atualiza��o e confirma��o do romaneio
@author silvana.torres
@since 05/06/2018
@version undefined
@param cAgendaGFE, characters, descricao
@type function
/*/
Function AX500NAtCo(cAgendaGFE)

	Local lRet 		:= .T.
	Local aAreaAtu 	:= GetArea()
	Local aRetRom	:= {}
	Local cNmRom	:= ""
	Local cTpOper	:= ""
	Local cAlias, nReg, nAcao, lAuto 

	Private _lVincFard := .F.

	If .NOT. Empty(cAgendaGFE)
		//Busca o numero do romaneio AGRO a partir do agendamento GFE
		aRetRom := AGRRomDoAg(cAgendaGFE)
		
		If !(EMPTY(aRetRom)) .AND. ValType(aRetRom[1]) <> "U" 
			cNmRom  := aRetRom[1]
			cTpOper	:= aRetRom[2]
		
			If .NOT. Empty(cNmRom)
				DbSelectArea("NJJ")
				NJJ->(DbSetOrder(1)) //Filial + Cod.Rom
				
				If NJJ->(MsSeek(FWxFilial("NJJ") + cNmRom))
					lRet := OGA250ATUC(cAlias, nReg, nAcao, lAuto)
					
					If lRet
						dbSelectArea("N92")
						N92->(DbSetOrder(1))
						If N92->(MsSeek(FWxFilial("N92") + cTpOper))
							If N92->N92_AUTCNF == .T.
								lRet := A500ConfRom(cNmRom, .T.)						
							EndIf
						endIf
					EndIf
				EndIf
				
				NJJ->(DbCloseArea())
			Else
				lRet := .F.
			EndIf
		Else
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf
	
	RestArea(aAreaAtu)
		
Return lRet

/*/{Protheus.doc} AX500FCONF
//RESPONS�VEL PELA CONFIRMA��O DO ROMANEIO PELA PROCESSO DO P�TIOS E PORTARIAS
@author brunosilva
@since 05/06/2018
@version undefined

@type function
/*/
Function AX500FCONF()
	Local lRet		:= .T.
	Local cNrAgen	:= ""
	Local cNmRom	:= ""
	Local aRetRom	:= Nil

	Private _lVincFard	:= .F.
	Private _lAltIE		:= .F. //indica se houve altera��o/inclus�o na IE

	//Pega o numero do agendamento GFE
	cNrAgen := GWV->GWV_NRAGEN
	
	if !EMPTY(cNrAgen)
		//Busca o numero do romaneio AGRO a partir do agendamento GFE
		//aRetRom[1] = Numero do romaneio
		//aRetRom[2] = Codigo Tipo de opera��o AGRO
		aRetRom := AGRRomDoAg(cNrAgen)
		
		//If ValType(aRetRom[1]) <> "U"
		if empty(aRetRom)
			cNmRom  := aRetRom[1]
		
			//Chama a fun��o de confirma��o do romaneio.
			lRet := A500ConfRom(cNmRom, .T./*lVisual*/)
		Else
			lRet := .F.
		EndIf
	endIf
	
Return lRet

/*/{Protheus.doc} AX500NAprR
Fun��o para chamar a aprova��o de romaneio pendende de aprova��o
@author silvana.torres
@since 06/06/2018
@version undefined

@type function
/*/
Function AX500NAPRR()
	
	Local lRet		:= .T.
	Local cNrAgen	:= ""
	Local cNmRom	:= ""
	Local aRetRom	:= Nil

	//Pega o numero do agendamento GFE
	cNrAgen := GWV->GWV_NRAGEN

	if !EMPTY(cNrAgen)
		//Busca o numero do romaneio AGRO a partir do agendamento GFE
		aRetRom := AGRRomDoAg(cNrAgen)
		
		//If ValType(aRetRom[1]) <> "U"
		if empty(aRetRom)
			cNmRom  := aRetRom[1] //Numero do romaneio
		
			//Chama a fun��o de aprova��o de romaneio pendente de aprova��o
			lRet := A500Aprov(cNmRom, .T.)
		Else
			lRet := .F.
		EndIf
	endIf

Return lRet

/*/{Protheus.doc} AX500AGPRM
//Respons�vel por fazer as tratativas referentes ao romaneio no ato da entrada do agendamento no p�tio.
@author brunosilva
@since 06/06/2018
@version undefined

@type function
/*/
Function AX500AGPRM()
	Local lRet := .T.
	Local cNrAgen	:= ""
	Local cNrMov	:= ""
	Local cNmRom	:= ""
	Local aRetRom	:= Nil

	Private _lVincFard	:= .F.
	Private _lAltIE		:= .F. //indica se houve altera��o/inclus�o na IE

	//Pega o numero do agendamento GFE
	cNrAgen := GWV->GWV_NRAGEN
	//Pega o n�mero do movimento GFE
	cNrMov  := GWV->GWV_NRMOV

	//Caso venha vazio, significa que nao tem agendamento nem no GFE.
	if !EMPTY(cNrAgen)
		//Busca o numero do romaneio AGRO a partir do agendamento GFE
		//aRetRom[1] = Numero do romaneio
		//aRetRom[2] = Codigo Tipo de opera��o AGRO
		aRetRom := AGRRomDoAg(cNrAgen)
		//If ValType(aRetRom) = "U"
		if empty(aRetRom)
			//O GFE pode dar entrada sem ter agendamento, mas neste ponto a GWV j� foi criada.
			//Ele vai entrar aqui pq � encontrou liga��o com AGRO.
			//MsgInfo(STR0061,STR0060) //'O status ser� alterado na execu��o do primeiro PC que tenha a��o relacionada.'  //Erro ao alterar o status do agendamento AGRO.
		else
			cNmRom  := aRetRom[1]
		
			//Atualiza status do Agendamento AGRO transformando ele em Romaneio AGRO. //AGRA550.prw
			lRet := A550AtuSt(cNmRom, .F., cNrMov)
			
			//Atualiza placa/ motorista no romaneio com dados wizard acesso veiculo (GFEA522)
			AX500PLMOT(cNmRom)
		endIf
	endIf
	
Return lRet

/*/{Protheus.doc} AX500PLMOT
//Fun��o atualiza placa/ motorista no romaneio com os dados informados no wizard de acesso de veiculos (GFEA522)
@author marina.muller
@since 15/02/2019
@version 1.0
@return ${return}, ${return_description}
@param cNmRom, characters, descricao
@type function
/*/
Static Function AX500PLMOT(cNmRom)
	Local aArea		:= GetArea()
	Local cPlaca    := ""
	Local cMotVei   := ""
	Local cCPFCNPJ  := ""
	
	cPlaca   := GU8->GU8_PLACA  
	cMotVei  := GUU->GUU_CDMTR   
	cCPFCNPJ := GUU->GUU_IDFED 
	
	dbSelectArea('NJJ')
	NJJ->(dbSetOrder(1))
	If NJJ->(MsSeek(FWxFilial('NJJ')+cNmRom)) //filial + romaneio
		If RecLock("NJJ", .F.)					
			NJJ->NJJ_PLACA  := cPlaca 
			NJJ->NJJ_CODMOT := cMotVei
			NJJ->NJJ_CGC    := cCPFCNPJ  
			MsUnlock("NJJ")
		EndIf
    EndIf
    NJJ->(dbCloseArea())
    
    RestArea(aArea)
    
Return .T.
