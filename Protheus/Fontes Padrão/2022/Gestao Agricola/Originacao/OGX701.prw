#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE "fwMvcDef.ch"

/*{Protheus.doc} OGX701WQTD
When do campo de quantidade da fixação de componente
@author jean.schulze
@since 28/08/2017
@version undefined
@type function
*/
Function OGX701WQTD() 
	Local lret   := .t.
	Local oModel := FwModelActive()
	
	if valtype(oModel) == "O" //é um objeto
		if oModel:GetId() == "OGA700" //tela negócio
			lRet := IIF(oModel:GetValue("N79UNICO" , "N79_TPCANC") == "2", .f.,.t.) //fixação de preço
			if lRet
				lRet := IIF(oModel:GetValue("N79UNICO" , "N79_FIXAC") == "1", .f.,.t.) //fixação de preço
				if lRet
					lRet := IIF(oModel:GetValue("N7CUNICO" , "N7C_TPCALC") $ "P|C|M|I", .t.,.f.)	 //somente campos diferente de resultado/tributo podem ter seus valores alterados
					if lRet
						lRet := IIF(oModel:GetValue("N7AUNICO" , "N7A_USOFIX") == "LBNO", .f.,.t.) //fixação de preço
					endif				
				endif
			endif
		endif
	endif
	
return lRet

/*{Protheus.doc} OGX701WVLR
When do campo de valor da fixação de componente
@author jean.schulze
@since 28/08/2017
@version undefined
@type function
*/
Function OGX701WVLR() 
	Local lret       := .t.
	Local oModel     := FwModelActive()
	Local cCompAjust := ""
	Local aSaveRows := nil 
	Local oModelN7C  := nil 
	
	if valtype(oModel) == "O" //é um objeto 
		if oModel:GetId() $ "OGA700" //tela negócio
			if !FWIsInCallStack("OGX701IDXN") .and. !FWIsInCallStack("OGX700CTRE") .and. !FWIsInCallStack("OGX700CTPP")
				lRet := IIF(oModel:GetValue("N7CUNICO" , "N7C_ALTVLR") == "0", .t.,.f.)	 //componente que pode ter seu valor alterado
				if lRet 
					lRet := IIF(oModel:GetValue("N7AUNICO" , "N7A_USOFIX") == "LBNO", .f.,.t.) //fixação de preço
					if lRet .and. oModel:GetValue("N7CUNICO" , "N7C_TPCALC") == "R"
						//tratamento para o campo de resultado 
						cCompAjust := POSICIONE("N74",1,FwXFilial("N74") + oModel:GetValue("N7CUNICO","N7C_CODCOM"), "N74_CODAJU")
						if !empty(cCompAjust)
							
							oModelN7C   := oModel:GetModel("N7CUNICO")
							aSaveRows  := FwSaveRows(oModel)
							
							if oModelN7C:SeekLine( { {"N7C_CODCOM", cCompAjust  } } )
								if oModelN7C:GetValue("N7C_QTDFIX") > 0 //tem fixação já realizada
									lRet := .f.
								endif
							else
								lRet := .f.
							endif
							
							FwRestRows(aSaveRows)
						else
							lRet := .f.
						endif
					endif
				endif
			endif
		endif
	endif
	
return lRet

/*{Protheus.doc} OGX701WTOR
When do campo de tipo de ordem da fixação de componente
@author niara.caetano
@since 24/10/2017
@version undefined
@type function
*/
Function OGX701WTOR() 
	Local lret   := .t.
	Local oModel := FwModelActive()

	If valtype(oModel) == "O" //é um objeto
		If oModel:GetId() $ "OGA700" //tela negócio
			lRet := IIF(oModel:GetValue("N7CUNICO" , "N7C_TPCALC") <> "R", .t.,.f.)	 //somente campos diferente de resultado podem ter seus valores alterados
			If lRet
				lRet := IIF(oModel:GetValue("N7CUNICO" , "N7C_HEDGE") = '1',.t.,.f.) //permitir alterar o tipo de ordem somente quando o hedge for Sim.
				if lRet .and. oModel:GetId() == "OGA700" //opção disponível somente na tela principal
					lRet := IIF(oModel:GetValue("N7AUNICO" , "N7A_USOFIX") == "LBNO", .f.,.t.) //fixação de preço
				endif								
			EndIf			
		EndIf
	EndIf

Return lRet

/*{Protheus.doc} OGX701WHED
When do Campo de Hedge	
@author jean.schulze
@since 20/02/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Function OGX701WHED() 
	Local lret    := .t.
	Local oModel  := FwModelActive()
	Local cTipFix := "" 

	If valtype(oModel) == "O" //é um objeto
		If oModel:GetId() $ "OGA700" //tela negócio
			if !FWIsInCallStack("OGA700VDQT") .and. !FWIsInCallStack("fLstCompN7C") 
				lRet := IIF(oModel:GetValue("N7AUNICO" , "N7A_USOFIX") == "LBNO", .f.,.t.) //fixação de preço
				
				if lRet
					if oModel:GetValue("N79UNICO","N79_TIPO") == "1" //novo negócio
						cTipFix := oModel:GetValue("N79UNICO","N79_TIPFIX") 
					else //fixação - cancelamento
						cTipFix := POSICIONE("NJR", 1, FwXFilial("NJR") + oModel:GetValue("N79UNICO","N79_CODCTR"), "NJR_TIPFIX")
					endif
					lRet := IIF(ALLTRIM(POSICIONE("NK7", 1, FwXFilial("NK7") + oModel:GetValue("N7CUNICO","N7C_CODCOM"), iif(cTipFix == "1","NK7_HEDGE","NK7_FHEDGE"))) > '0',.t.,.f.) //permitir alterar o tipo de ordem somente quando o hedge for Sim.
				endif							
			endif			
		EndIf
	EndIf

Return lRet

/*{Protheus.doc} OGX701WCOT
When do campo de valor da cotação
@author niara.caetano
@since 12/12/2017
@version undefined
@type function
*/
Function OGX701WCOT() 
	Local lret   := .t.
	Local oModel := FwModelActive()
	
	if valtype(oModel) == "O" //é um objeto
		if oModel:GetId() == "OGA700" //tela negócio
			lRet := IIF(oModel:GetValue("N7CUNICO" , "N7C_TPCALC") $ "P|C|M|I", .t.,.f.)	 //somente campos diferente de resultado podem ter seus valores alterados
			if lRet 
				lRet := IIF(oModel:GetValue("N79UNICO", "N79_MOEDA") <> oModel:GetValue("N7CUNICO" , "N7C_MOEDCO"), .t.,.f.)	 //somente pode alterar se o valor da cotação do componente for diferente do negócio
			endif
			if lRet
				lRet := IIF(oModel:GetValue("N7AUNICO" , "N7A_USOFIX") == "LBNO", .f.,.t.) //fixação de preço
			EndIf
		Endif
	endif
	
return lRet

/*{Protheus.doc} OGX701IMPT
Tratamento alteração de imposto
@author jean.schulze
@since 27/10/2017
@version undefined
@param oGrid, object, descricao
@param cCampo, characters, descricao
@type function
*/
Function OGX701IMPT(oGrid, cCampo)
	Local oModel 	:= oGrid:GetModel()
	Local oModelN7C := oModel:GetModel("N7CUNICO") 
	Local nX        := 0
	Local nLinha    := 0
	
	//atualiza o dado na tabela principal
	if oModelN7C:SeekLine( { {"N7C_CODCOM", oGrid:GetValue("N7C_CODCOM")  } } ) //posiocina no registro correto
		oModelN7C:SetValue(cCampo,  oGrid:GetValue(cCampo)  ) 
	else
		return(.f.)
	endif
	
	nLinha := oGrid:getLine()
	
	//reload de dados na tela de impostos - futuros updates
	For nX := 1 to oModelN7C:Length()
		oModelN7C:GoLine( nX )
		
		if oModelN7C:GetValue( "N7C_TPCALC") == "T" // é resultado - calcula os valores   
			if oGrid:SeekLine( { {"N7C_CODCOM", oModelN7C:GetValue("N7C_CODCOM")  } } ) //posiocina no registro correto
				oGrid:LoadValue( "N7C_VLRUN1", oModelN7C:GetValue( "N7C_VLRUN1"))
				oGrid:LoadValue( "N7C_VLRUN2", oModelN7C:GetValue( "N7C_VLRUN2"))
				oGrid:LoadValue( "N7C_APLICA", oModelN7C:GetValue( "N7C_APLICA"))
			endif
		endif
				
	next nX		
	
	oGrid:goLine(nLinha) 
	
return .t.

/*{Protheus.doc} OGX701UMPR
Validação de Unidade de Medida de Preço
@author jean.schulze
@since 06/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cProduto, characters, descricao
@type function
*/
function OGX701UMPR(cProduto)
	Local lReturn := .t. 
	
	if empty(AgrUmPrc(cProduto))
		Help( , , "Ajuda", , "O produto não possui UM de Preço.", 1, 0,,,,,,{"Informe um Produto com UM de Preço"} )
		lReturn := .f.
	//Gatilha a descrição do produto para o parametro 3 do pergunte .OGA70001.
	else
		If ValType(MV_PAR03) == 'C'
            MV_PAR03 := Posicione("SB1",1,FWxFilial("SB1")+MV_PAR02,"B1_DESC")
        EndIf
	endif
	
return lReturn

/*{Protheus.doc} OGX701IDXN
Gatilho para uso de indíces de preço da bolsa.
@author jean.schulze
@since 14/02/2018
@version 1.0
@return ${return}, ${return_description}
@param cCodIdx, characters, descricao
@type function
*/
Function OGX701IDXN(cCodIdx)
	Local oModel    := FwModelActive()
	Local oModelN7C := nil
	Local nX        := 1
	Local nVrIndice := 0
	Local aSaveRows := nil
	
	if valtype(oModel) == "O" //é um objeto
		if oModel:GetId() == "OGA700" //tela negócio
			
			aSaveRows := FwSaveRows(oModel)
			oModelN7C := oModel:GetModel("N7CUNICO")
			
			while nX <= oModelN7C:Length() 
				oModelN7C:GoLine( nX )
				
				if !empty(oModelN7C:GetValue("N7C_BOLSA"))
					//verifica se a bolsa tem indice
					dbSelectArea("NK0")
					NK0->( dbSetOrder(1) )
		
					If NK0->(DbSeek(xFilial("NK0") + cCodIdx ))
						
						if NK0->(NK0_CODBOL) == oModelN7C:GetValue("N7C_BOLSA") //usamos a mesma bolsa
							//insere os dados no componente atual
							nVrIndice := AgrGetInd( NK0->NK0_INDICE,NK0->NK0_TPCOTA, dDataBase )
							oModelN7C:SetValue("N7C_CODIDX", cCodIdx )
							oModelN7C:SetValue("N7C_VLRIDX", nVrIndice )
							If oModel:GetValue( "N79UNICO","N79_TIPO") == "1" .AND.;
								((Type("_lOGA700CP") == "L" .AND. _lOGA700CP) .OR. (oModel:GetOperation() == 3))
								oModelN7C:SetValue("N7C_VLRCOM", 0 )
							Else 
								oModelN7C:SetValue("N7C_VLRCOM", nVrIndice )
							EndIf
						endif
						
					EndIF
					
				endif
				 				
				nX++
			end
			
			FwRestRows(aSaveRows)
			
		endif
	endif
	
return cCodIdx 

//-------------------------------------------------------------------
/*/{Protheus.doc} OGX701AALC
Função responsável pela aprovação da alçada via MATA094.
@author  RAFAEL.VOLTZ
@since   26/03/2018
@version version
/*/
//-------------------------------------------------------------------
Function OGX701AALC(cChave, cObs, cResult, cUserAprov)
	Local lRet  	as logical
	Local cMsg 		as char
	Local oModel700 as object	
	Local aArea     as array
	Local cStatus  as char
    Local oModel  := FWModelActive()
	
	lRet  := .T.
	aArea := GetArea()
    
	cChave := xFilial("N79") + cChave

	N79->(DbSetOrder(1))
	If N79->(DbSeek(cChave))		
		oModel700 := FWLoadModel('OGA700')
		oModel700:SetOperation(MODEL_OPERATION_UPDATE)		

		If (oModel700:Activate())
            FWModelActive(oModel700)
			If cResult == "A"				
				cStatus := OGA700STU(oModel700)
				cMsg := "Aprovação financeira referente a multa de cancelamento." +  UsrRetName(cUserAprov) + CRLF + "Observação: " + cObs 				
				oModel700:SetValue("N79UNICO","N79_STATUS", cStatus) 				
			Else
				oModel700:SetValue("N79UNICO","N79_STATUS", "4" ) 				
				cMsg := "Rejeição financeira referente a multa de cancelamento. Usuário aprovou/rejeitou: " + UsrRetName(cUserAprov) + CRLF + "Observação: " + cObs 
			EndIf

			If lRet						
				AGRGRAVAHIS("Aprovação Financeira",,,,{"N79",N79->N79_FILIAL+N79->N79_CODNGC+N79->N79_VERSAO+N79->N79_TIPO,cResult,cMsg})					

				If oModel700:VldData()    // Valida o Model
					oModel700:CommitData() // Realiza o commit
					oModel700:DeActivate() // Desativa o model
					oModel700:Destroy() // Destroi o objeto do model
					
					If N79->(DbSeek(cChave))
						lRet := iif(N79->N79_STATUS == '5', .F.,.T.)
					EndIf

					If lRet .and. !isBlind()
						If MsgYesNo("Deseja enviar um e-mail do resultado ao solicitante?", "Aviso")
							EmailAlcad(N79->N79_CODNGC, N79->N79_USERNG, cUserAprov, cResult, cObs)	
						EndIf
					EndIf
				Else 
					lRet := .f.
				EndIf	
			Else
				MsgAlert("Não foi possível realizar o cancelamento.")
				oModel700:DeActivate() // Desativa o model
				oModel700:Destroy() // Destroi o objeto do model
			EndIf
		EndIF 
	Else
		MsgAlert("Não foi possível localizar o registro de négocio. Chave de pesquisa: "+cChave)
		lRet := .F.
	EndIf
	
	FWModelActive(oModel)
    RestArea(aArea)  
	
Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} EmailAlcad()
Envia e-mail de rejeição/aprovação de documento de alçada da multa

@author Rafael Voltz
@since 26/03/2018
@version 12
/*/
//-------------------------------------------------------------------
Static Function EmailAlcad(cCodNgc, cUserSolic, cUserAprov, cResult, cObs)		
	Local cEmails   := ""
	Local nX        := 0	
	Local cRemetnt    := ""
	Local aMail       := {}
	Local aNomeUser   := {}
	Local cAssunto    := ""
	Local cMesg       := ""
	Local cMsgRet     := ""	
	
	Iif(cResult == "A",cAssunto := "Aprovação de Documento",cAssunto := "Rejeição de Documento")	

	//Busca E-mail Aprovador
	PswOrder(1)
	If	PswSeek(cUserAprov)
		aMail := {PswRet(1)[1][14]}
	EndIf
	If !Empty(aMail)
		For nX := 1 To Len(aMail)
			If !Empty(aMail[1])
				cRemetnt += aMail[1] + ";"
			EndIf
		Next
	Endif

	If Empty(cRemetnt)
		MsgAlert("E-mail não foi enviado. Endereço do remetente não foi encontrado. ")
		Return 
	EndIf

	//Busca E-mail Solicitante
	If	PswSeek(cUserSolic)
		aMail 	  := {PswRet(1)[1][14]}
		aNomeUser := {PswRet(1)[1][4]}
	EndIf

	If !Empty(aMail)
		For nX := 1 To Len(aMail)
			If !Empty(aMail[1])
				cEmails += aMail[1] + ";"
			EndIf
		Next
	Endif

	If Empty(cEmails)
		MsgAlert("E-mail não foi enviado. Endereço do destinatário não foi encontrado. ")
		Return 
	EndIf

	If !Empty(aNomeUser)
		For nX := 1 To Len(aNomeUser)
			cNomUserAp := aNomeUser[1] 
		Next
	Endif

	cMesg := "Prezado, <br><br>"
	cMesg += "Segue situação da sua solicitação referente a multa de cancelamento: <br><br>"
	cMesg += "Negócio: " + Alltrim(cCodNgc) 
	cMesg += "<br>Situação: "+ Iif(cResult =="A", "APROVADO", "REPROVADO") + " "
	cMesg += "<br>Obs: "+ Alltrim(cObs)
	cMesg += "<br><br>Atenciosamente, "
	cMesg += "<br><br> " + 	cNomUserAp
	
	cMsgRet := OGX017MAIL(cAssunto,cEmails,cMesg, cRemetnt, {})		

	If !Empty(cMsgRet)
		MsgAlert("Não foi possível enviar o e-mail. " + cMsgRet)
		Return 
	EndIf

Return 


/*{Protheus.doc} OGX701WRES
When de campo para inserir informação de Reserva 
@author jean.schulze
@since 11/10/2018
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Function OGX701WRES() 
	Local lret   := .t.
	Local oModel := FwModelActive()
	
	if valtype(oModel) == "O" //é um objeto
		if oModel:GetId() == "OGA700" //tela negócio
			lRet := AGRTPALGOD(oModel:GetValue("N79UNICO" , "N79_CODPRO")) //verifica se é algodão
			if lRet
				lRet := IIF(oModel:GetValue("N7AUNICO" , "N7A_TIPRES") == "2", .f.,.t.) //verifica se já foi feito uma reserva de negocio		
			endif
		endif
	endif
	
return lRet


