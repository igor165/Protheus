#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMVCDEF.CH"

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FINWS008

Geração do fornecedor a partir do participante

@author CM Solutions - Allan Constantino Bonfim
@since  17/02/2020
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function FINWS008(oBrowse, cFilPart, cCodPart)

	Local aArea			:= GetArea()
	Local lRet			:= .T.                           
	Local nLinAtu		:= 0
	Local lFornOk		:= .T.
	Local cAliasBrw		:= ""
	Local cRetFor		:= ""

	Default oBrowse		:= NIL
	Default cFilPart	:= ""
	Default cCodPart	:= ""
	
	If Valtype(oBrowse) == "O"
		//nLinha 		:= oBrowse:At()
		cAliasBrw	:= oBrowse:Alias()
		nLinAtu		:= oBrowse:oBrowse:nAt

		cFilPart	:= (cAliasBrw)->RD0_FILIAL
		cCodPart	:= (cAliasBrw)->RD0_CODIGO
	ENDIF

	If !Empty(cCodPart)

		DbSelectArea("SA2")
		DbSetOrder(3) //A2_FILIAL, A2_CGC

		DbSelectArea("RD0")
		DbSetOrder(1) //RD0_FILIAL, RD0_CODIGO
		If DbSeek(cFilPart+cCodPart)
			If Empty(RD0->RD0_FORNEC) .AND. Empty(RD0->RD0_LOJA)
				If !Empty(RD0->RD0_CIC) 
					If SA2->(DbSeek(FwxFilial("SA2")+RD0->RD0_CIC))
						If MsgYesNo("O participante já possui fornecedor cadastrado ("+SA2->A2_COD+"/"+SA2->A2_LOJA+" - "+ALLTRIM(SA2->A2_NOME)+"). Confirma a amarração do fornecedor ao participante ?", "FIWS3FOR")
							lFornOk := .F.
							Reclock("RD0", .F.)
								RD0->RD0_FORNEC := SA2->A2_COD
								RD0->RD0_LOJA	:= SA2->A2_LOJA
							RD0->(MsUnlock())
						EndIf
					EndIf
				EndIf

				If lFornOk
					If MsgYesNo("Você confirma a geração do fornecedor para o participante "+RD0->RD0_CODIGO +" - "+Alltrim(RD0->RD0_NOME)+"?", "FIWS3FOR")
						cRetFor := U_FIWS8FOR(3, cFilPart, cCodPart)
						If Empty(cRetFor)
							MsgInfo("Fornecedor cadastrado com sucesso.", "FINWS008")
						Else
							MsgStop(cRetFor, "FINWS008")
						EndIf
					EndIf
				EndIf
			Else
				If MsgYesNo("O participante já possui fornecedor cadastrado ("+RD0->RD0_FORNEC+"/"+RD0->RD0_LOJA+"). Deseja atualizar o cadastro do fornecedor ?", "FIWS3FOR")
					cRetFor := U_FIWS8FOR(4, cFilPart, cCodPart, Alltrim(RD0->RD0_FORNEC), Alltrim(RD0->RD0_LOJA))
					If Empty(cRetFor)
						MsgInfo("Fornecedor atualizado com sucesso.", "FINWS008")
					Else
						MsgStop(cRetFor, "FINWS008")
					EndIf
				Else
					//Help(NIL, NIL, "FIWS3FOR", NIL, "O participante já possui fornecedor cadastrado ("+RD0->RD0_FORNEC+"/"+RD0->RD0_LOJA+").", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique o participante selecionado e tente novamente."})
					lRet := .F.
				EndIf
			EndIf
		Else
			Help(NIL, NIL, "FIWS3FOR", NIL, "Participante não localizado no cadastro de participante ("+cCodPart+").", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique os parâmetros informados na rotina FIWS3FOR."})
			lRet := .F.
		EndIf
	Else
		Help(NIL, NIL, "FIWS3FOR", NIL, "Participante não informado.", 1, 0, NIL, NIL, NIL, NIL, NIL, {"Verifique os parâmetros da rotina FIWS3FOR."})
		lRet := .F.
	EndIf

	RestArea(aArea)

Return lRet   



//------------------------------------------------------------------------------
/*/{Protheus.doc} FIWS3FOR

Rotina para a geração do fornecedor a partir do participante.

@author  Allan Constantino Bonfim - CM Solutions
@since   17/02/2020
@version P12
@return array, Funções da Rotina
 
/*/
//------------------------------------------------------------------------------
User Function FIWS8FOR(nOpc, cFilPart, cCodPart, cCodFor, cLojFor)
	
	Local aArea			:= GetArea()
	Local cRetCad		:= ""
	Local aErro			:= {}
	Local cErro			:= ""
	Local oModel 		:= Nil
	Local cCodSA2		:= ""
	Local cCodPais      := '105'

	Private INCLUI 		:= .F.
	Private ALTERA		:= .F.

	Default nOpc 		:= 3
	Default cFilPart	:= ""
	Default cCodPart	:= ""
	Default cCodFor		:= ""
	Default cLojFor		:= ""

	If !Empty(cCodPart)
		DbSelectArea("RD0")
		DbSetOrder(1) //RD0_FILIAL, RD0_CODIGO
		If DbSeek(cFilPart+cCodPart)
			If nOpc == 3
				INCLUI := .T.
			ElseIf nOpc == 4
				ALTERA := .T.

				DbSelectArea("SA2")
				DbSetOrder(1)
				If !DbSeek(FwxFilial("SA2")+cCodFor+cLojFor)
					Return  "Fornecedor não localizado para a atualizaçaõ dos dados ("+cCodFor+"/"+cLojFor+")."
				EndIf
			ENDIF
			
			oModel := FWLoadModel('MATA020')
			oModel:SetOperation(nOpc)

			oModel:SetDeActivate({|| .T.})

			oModel:Activate()

			//Cabeçalho
			cCodSA2 := U_FIWS8NUM("SA2", "A2_COD", .T., .F., .T.)
/*
			AADD(aDados, {"A2_COD"		, cCodFor, Nil})
			AADD(aDados, {"A2_LOJA"		, "01", Nil})	
			AADD(aDados, {"A2_NOME"		, SUBSTR(RD0->RD0_NOME, 1, TAMSX3("A2_NOME")[1]), Nil})	
			AADD(aDados, {"A2_NREDUZ"	, SUBSTR(RD0->RD0_NOME, 1, TAMSX3("A2_NREDUZ")[1]), Nil})	
			AADD(aDados, {"A2_CEP"		, RD0->RD0_CEP, Nil})	
			AADD(aDados, {"A2_END"		, SUBSTR(RD0->RD0_END, 1, TAMSX3("A2_END")[1]), Nil})	
			AADD(aDados, {"A2_BAIRRO"	, SUBSTR(RD0->RD0_BAIRRO, 1, TAMSX3("A2_BAIRRO")[1]), Nil})	
			AADD(aDados, {"A2_EST"		, RD0->RD0_UF, Nil})	
			AADD(aDados, {"A2_COD_MUN"	, RD0->RD0_XCDMUN, Nil})	
			AADD(aDados, {"A2_MUN"		, SUBSTR(RD0->RD0_MUN, 1, TAMSX3("A2_MUN")[1]), Nil})	
			AADD(aDados, {"A2_TIPO"		, GetNewPar("ZZ_A2TIPO", "F"), Nil})	
			AADD(aDados, {"A2_CGC"		, RD0->RD0_CIC, Nil})	
			AADD(aDados, {"A2_DDI"		, RD0->RD0_DDI, Nil})	
			AADD(aDados, {"A2_DDD"		, RD0->RD0_DDD, Nil})	
			AADD(aDados, {"A2_TEL"		, RD0->RD0_FONE, Nil})	
			AADD(aDados, {"A2_EMAIL"	, ALLTRIM(RD0->RD0_EMAIL), Nil})	
			AADD(aDados, {"A2_CODPAIS"	, GetNewPar("ZZ_A2CPAIS", "01058"), Nil})	
			AADD(aDados, {"A2_ENDCOMP"	, SUBSTR(RD0->RD0_CMPEND, 1, TAMSX3("A2_ENDCOMP")[1]), Nil})	
			AADD(aDados, {"A2_CONTA"	, GetNewPar("ZZ_A2CONTA", "201010101"), Nil})	
			AADD(aDados, {"A2_ZZCC"		, RD0->RD0_CC, Nil})	
			AADD(aDados, {"A2_ZZCBU"	, GetNewPar("ZZ_A2ZZCBU", "00"), Nil})	
			AADD(aDados, {"A2_TIPCTA"	, GetNewPar("ZZ_A2TPCTA", "1"), Nil})	
			AADD(aDados, {"A2_BANCO"	, RD0->RD0_XBANCO, Nil})	
			AADD(aDados, {"A2_AGENCIA"	, RD0->RD0_XAGENC, Nil})
			AADD(aDados, {"A2_NUMCON"	, RD0->RD0_XNUCON, Nil})

			FWMVCRotAuto(oModel, "SA2", nOpc, {{"SA2MASTER", aDados}}, .T.) //Model //Alias //Operacao //Dados  	
*/
			If INCLUI
				cCodFor := cCodSA2
				cLojFor	:= "01"

			//	oModel:SetValue('SA2MASTER','A2_COD' 	, cCodSA2)
			//	oModel:SetValue('SA2MASTER','A2_LOJA' 	,"01") 
			//ElseIf ALTERA
			//	oModel:SetValue('SA2MASTER','A2_COD' 	, cCodFor)
			//	oModel:SetValue('SA2MASTER','A2_LOJA' 	, cLojFor) 
			EndIf

			oModel:SetValue('SA2MASTER','A2_COD' 	, cCodFor)
			oModel:SetValue('SA2MASTER','A2_LOJA' 	, cLojFor)
			oModel:SetValue('SA2MASTER','A2_PAIS' 	, cCodPais) // Caio Souza 25/02/2022 - grava o código do pais

			oModel:SetValue('SA2MASTER','A2_NOME'	, SUBSTR(RD0->RD0_NOME, 1, TAMSX3("A2_NOME")[1]))
			oModel:SetValue('SA2MASTER','A2_NREDUZ' , SUBSTR(RD0->RD0_NOME, 1, TAMSX3("A2_NREDUZ")[1]))
			oModel:SetValue('SA2MASTER','A2_CEP'	, RD0->RD0_CEP)
			oModel:SetValue('SA2MASTER','A2_END' 	, SUBSTR(RD0->RD0_END, 1, TAMSX3("A2_END")[1]))
			oModel:SetValue('SA2MASTER','A2_BAIRRO' , SUBSTR(RD0->RD0_BAIRRO, 1, TAMSX3("A2_BAIRRO")[1]))
			oModel:SetValue('SA2MASTER','A2_EST' 	, RD0->RD0_UF)
			oModel:SetValue('SA2MASTER','A2_COD_MUN', RD0->RD0_XCDMUN)
			oModel:SetValue('SA2MASTER','A2_MUN' 	, SUBSTR(RD0->RD0_MUN, 1, TAMSX3("A2_MUN")[1]))
			oModel:SetValue('SA2MASTER','A2_TIPO' 	, GetNewPar("ZZ_A2TIPO", "F"))
			oModel:SetValue('SA2MASTER','A2_CGC'	, RD0->RD0_CIC)
			oModel:SetValue('SA2MASTER','A2_DDI' 	, RD0->RD0_DDI)
			oModel:SetValue('SA2MASTER','A2_DDD' 	, RD0->RD0_DDD)
			oModel:SetValue('SA2MASTER','A2_TEL' 	, RD0->RD0_FONE)
			oModel:SetValue('SA2MASTER','A2_EMAIL'	, ALLTRIM(RD0->RD0_EMAIL))
			oModel:SetValue('SA2MASTER','A2_CODPAIS', GetNewPar("ZZ_A2CPAIS", "01058"))
			oModel:SetValue('SA2MASTER','A2_ENDCOMP', SUBSTR(RD0->RD0_CMPEND, 1, TAMSX3("A2_ENDCOMP")[1]))
			oModel:SetValue('SA2MASTER','A2_CONTA'	, GetNewPar("ZZ_A2CONTA", "201010101"))
			oModel:SetValue('SA2MASTER','A2_ZZCC'	, RD0->RD0_CC)
			oModel:SetValue('SA2MASTER','A2_ZZCBU'	, GetNewPar("ZZ_A2ZZCBU", "00"))
			oModel:SetValue('SA2MASTER','A2_TIPCTA'	, GetNewPar("ZZ_A2TPCTA", "1"))
			
			If !Empty(RD0->RD0_XBANCO)
				oModel:SetValue('SA2MASTER','A2_BANCO' 	, RD0->RD0_XBANCO)
			EndIf

			If !Empty(RD0->RD0_XAGENC)
				oModel:SetValue('SA2MASTER','A2_AGENCIA', RD0->RD0_XAGENC)
			EndIf
			
			If !Empty(RD0->RD0_XNUCON)
				oModel:SetValue('SA2MASTER','A2_NUMCON'	, RD0->RD0_XNUCON)
			EndIf

			//oModel:SetValue('SA2MASTER','A2_XBANCOR', RD0->RD0_XBANCO)
			//oModel:SetValue('SA2MASTER','A2_XAGENCR', RD0->RD0_XAGENC)
			//oModel:SetValue('SA2MASTER','A2_XCONTAR', RD0->RD0_XNUCON) 	 	 

			If oModel:VldData()
				oModel:CommitData()

				Reclock("RD0", .F.)
					RD0->RD0_FORNEC := cCodFor
					RD0->RD0_LOJA	:= "01"
				RD0->(MsUnlock())

				//MsgInfo("Fornecedor cadastrado com sucesso.")
			Else
				aErro	:= oModel:GetErrorMessage()
				
				If Empty(Alltrim(aErro[7]))
					cErro 	:= "CAMPO "+ALLTRIM(aErro[2]) +" - CONTEÚDO "+ ALLTRIM (aErro[9]) + " - ERRO "+ ALLTRIM(aErro[6])
				else
					cErro 	:= "CAMPO "+ALLTRIM(aErro[2]) +" - CONTEÚDO "+ ALLTRIM (aErro[9]) + " - ERRO "+ ALLTRIM(aErro[6]) +" - SOLUÇÃO "+ ALLTRIM(aErro[7]) 
				ENDIF

				cRetCad := cErro
				//MsgStop(cRetCad, "FIWS8FOR")
			Endif
/*
			//Se houve erro no ExecAuto, mostra mensagem
			If lMsErroAuto   
				aErro	:= oModel:GetErrorMessage()
				If Empty(Alltrim(aErro[7]))
					cErro 	:= "CAMPO "+ALLTRIM(aErro[2]) +" - CONTEÚDO "+ ALLTRIM (aErro[9]) + " - ERRO "+ ALLTRIM(aErro[6])
				else
					cErro 	:= "CAMPO "+ALLTRIM(aErro[2]) +" - CONTEÚDO "+ ALLTRIM (aErro[9]) + " - ERRO "+ ALLTRIM(aErro[6]) +" - SOLUÇÃO "+ ALLTRIM(aErro[7]) 
				ENDIF

				cRetCad := cErro
			Else
				Reclock("RD0", .F.)
					RD0->RD0_FORNEC := cCodFor
					RD0->RD0_LOJA	:= "01"
				RD0->(MsUnlock())
			ENDIF
*/
			oModel:DeActivate()
			oModel:Destroy()
		Else
			cRetCad := "Participante não localizado no cadastro de participantes ("+cCodPart+")."
		ENDIF
	Else
		cRetCad := "Participante não informado."
	ENDIF

	If !Empty(cRetCad)
		//MsgStop(cRetCad, "FIWS8FOR")
	ENDIF

	RestArea(aArea)

Return cRetCad


//-------------------------------------------------------------------
/*/{Protheus.doc} FIWS8NUM

Rotina para controle de numeração customizado.

@author  CM Solutions - Allan Constantino Bonfim
@since   17/02/2020
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------  
User Function FIWS8NUM(cTab, cCampo, lSoma1, lDelete, lNoRange)

	Local aArea    		:= GetArea()
	Local cCodFull  	:= ""
	Local cCodAux  		:= "1"
	Local cQuery   		:= ""
	Local nTamCampo		:= 0
	Local cNextTmp		:= GetNextAlias()

	Default cTab		:= ""
	Default cCampo		:= ""
	Default lSoma1		:= .T.
	Default lDelete		:= .F.
	Default lNoRange	:= .T.
		
	If !EMPTY(cTab) .AND. !EMPTY(cCampo)

		//Definindo o código atual
		nTamCampo := TamSX3(cCampo)[01]
		cCodAux   := PADL(cCodAux, nTamCampo, "0")
		
		//Faço a consulta para pegar as informações		 
		cQuery := "SELECT ISNULL(MAX(SUBSTRING("+cCampo+", 2, "+cValtoChar(nTamCampo)+")), '"+cCodAux+"') AS CODMAX "+CHR(13)+CHR(10)
		cQuery += "FROM "+RetSQLName(cTab)+" TAB "+CHR(13)+CHR(10)
		cQuery += "WHERE LEN("+cCampo+") = "+cValtoChar(nTamCampo)+" "+CHR(13)+CHR(10)
		cQuery += "AND ISNUMERIC(A2_COD) = 1 "+CHR(13)+CHR(10)
		
		If lNoRange
			cQuery += "AND A2_COD NOT IN ('024706','068900','088580','094410','101877','110001', '999999', '991914', '991913', '458999') "+CHR(13)+CHR(10)
		EndIf

		If lDelete
			cQuery += "AND D_E_L_E_T_ = ' ' "+CHR(13)+CHR(10)
		EndIf
		
		cQuery := ChangeQuery(cQuery)
		
		dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery), cNextTmp)
		
		//Se não tiver em branco
		If !EMPTY((cNextTmp)->CODMAX)
			cCodAux := PADL(ALLTRIM((cNextTmp)->CODMAX), nTamCampo, "0") //ALLTRIM((cNextTmp)->CODMAX)
		EndIf
		
		//Se for para atualizar, soma 1 na variável
		If lSoma1
			cCodAux := Soma1(cCodAux)
		EndIf

		cCodFull := cCodAux
		
		If Select(cNextTmp) > 0      
			(cNextTmp)->(DbCloseArea())
		EndIf
	EndIf
		
	RestArea(aArea)

Return cCodFull


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} FIWS8RD0

Chamada da rotina de Geração do fornecedor a partir do participante

@author CM Solutions - Allan Constantino Bonfim
@since  02/03/2020
@version P12
@return _lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function FIWS8RD0(_cAlias, _nRecno)

	Local _aArea	:= GetArea()

	Default _cAlias	:= ""
	Default _nRecno	:= 0


	If !Empty(_cAlias) .AND. !Empty(_nRecno)
		DbSelectArea("RD0")
		DbGoto(_nRecno)
		
		U_FINWS008(, RD0->RD0_FILIAL, RD0->RD0_CODIGO)
	EndIf

	RestArea(_aArea)

Return
