#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "formregistration.ch"

STATIC lDicValido := Nil

WSRESTFUL FormRegistration DESCRIPTION "Serviço REST para manipulação do Cadastro de Formulários do apontamento"

WSDATA userCode	  AS String  
WSDATA code       AS String  Optional
WSDATA count      AS INTEGER Optional
WSDATA startIndex AS INTEGER Optional
WSDATA page    	  AS INTEGER Optional
WSDATA onlyHeader AS INTEGER Optional
WSDATA codeForm   AS String
WSDATA productionOrder AS INTEGER Optional
 
WSMETHOD GET Form 				DESCRIPTION "Recupera os formulários de apontamento"				WSSYNTAX "/Form/{code}/{startIndex}/{count}/{page}" PATH "/Form"
WSMETHOD GET FormUsers 			DESCRIPTION "Recupera os formulários de apontamento do usuário"		WSSYNTAX "/FormUsers/{userCode}/{startIndex}/{count}/{page}/{onlyHeader}" PATH "FormUsers"
WSMETHOD GET FormFields			DESCRIPTION "Recupera os campos do formulário"						WSSYNTAX "/FormFields/{codeForm}/{userCode}/{startIndex}/{count}/{page}" PATH "FormFields"
WSMETHOD GET FormConfig			DESCRIPTION "Recupera a configuração de um formulário"				WSSYNTAX "/FormConfig/{codeForm}/{userCode}/{startIndex}/{count}/{page}" PATH "FormConfig"
WSMETHOD GET FormMachines		DESCRIPTION "Recupera as máquinas do formulário"					WSSYNTAX "/FormMachines/{codeForm}/{userCode}/{startIndex}/{count}/{page}" PATH "FormMachines"
WSMETHOD GET FormCustomField	DESCRIPTION "Recupera os campos customizados do formulário"		    WSSYNTAX "/FormCustomField/{codeForm}/{userCode}/{startIndex}/{count}/{page}" PATH "FormCustomField"
WSMETHOD POST	        		DESCRIPTION "Inclui novos registros de formulários de apontamento"	WSSYNTAX "/FormRegistration/Form"
WSMETHOD PUT	        		DESCRIPTION "Altera um formulário de apontamento"					WSSYNTAX "/FormRegistration/Form"
WSMETHOD DELETE	        		DESCRIPTION "Exclui um formulário de apontamento"					WSSYNTAX "/FormRegistration/Form"
WSMETHOD GET profile            DESCRIPTION "Recupera as permissões de acesso"                      WSSYNTAX "/profile"

END WSRESTFUL

WSMETHOD GET profile WSSERVICE FormRegistration
    Local oJson := JsonObject():New()

    oJson["apiVersion"] := 2

    ::SetResponse(EncodeUTF8(oJson:toJson()))
Return .T.

WSMETHOD GET Form WSRECEIVE code, startIndex, count, page WSSERVICE FormRegistration
	Local aSOX  := {}
	Local lGet  := .T.
	Local lSMJ  := AliasInDic("SMJ")
	Local nI    := 0
	Local oJson := Nil
	Local oSMJ  := Nil

	// define o tipo de retorno do método
	::SetContentType("application/json")

	If !VldDiciona()
		SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
		lGet := .F.	
	Else
		// define o tipo de retorno do método
		oJson := JsonObject():New()

		If !Empty(::code)

			// insira aqui o código para pesquisa do parametro recebido
			aSOX := PCPA121Con(::code)
			If Len(aSOX) > 0
				oJson['code']            := EncodeUTF8(aSOX[1,1])
				oJson['appointmentType'] := aSOX[1,2]
				oJson['iconName']        := aSOX[1,3]
				oJson['description']     := trim(EncodeUTF8(aSOX[1,4]))
				oJson['stopReport']      := aSOX[1,5]
				oJson['useTimer']        := aSOX[1,6]
				oJson['typeProgress']    := aSOX[1,7]

				If lSMJ 
					oSMJ := PCPA121Emp(aSOX[1,1], .F.)
					oJson["viewAllocations"  ] := oSMJ["viewAllocations"  ]
					oJson["insertAllocations"] := oSMJ["insertAllocations"]
					oJson["updateAllocations"] := oSMJ["updateAllocations"]
					oJson["deleteAllocations"] := oSMJ["deleteAllocations"]
				EndIf
			Else
				lGet := .F.
				SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
			EndIf

			// exemplo de retorno de um objeto JSON
			::SetResponse(oJson:toJson())

			If oSMJ != Nil
				FreeObj(oSMJ)
				oSMJ := Nil
			EndIf
		Else
			// as propriedades da classe receberão os valores enviados por querystring
			// exemplo: http://localhost:8080/sample?startIndex=1&count=10
			DEFAULT ::startIndex := 1, ::count := 20, ::page := 0

			// exemplo de retorno de uma lista de objetos JSON
			aSOX:= PCPA121con(::code, ::startIndex, ::count, ::page)
			
			If Len(aSOX) < 1
				lGet := .F.
				SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
			Else	
				::SetResponse('[')
				For nI := 1 To len(aSOX)
					If nI > ::startIndex
						::SetResponse(',')
					EndIf
					oJson['code']            := EncodeUTF8(aSOX[nI,1])
					oJson['appointmentType'] := aSOX[nI,2]
					oJson['iconName']        := aSOX[nI,3]
					oJson['description']     := trim(EncodeUTF8(aSOX[nI,4]))
					oJson['stopReport']      := aSOX[nI,5]
					oJson['useTimer']        := aSOX[nI,6]
					oJson['typeProgress']    := aSOX[nI,7]

					If lSMJ 
						oSMJ := PCPA121Emp(aSOX[nI,1], .F.)
						oJson["viewAllocations"  ] := oSMJ["viewAllocations"  ]
						oJson["insertAllocations"] := oSMJ["insertAllocations"]
						oJson["updateAllocations"] := oSMJ["updateAllocations"]
						oJson["deleteAllocations"] := oSMJ["deleteAllocations"]
					EndIf

					::SetResponse(oJson:toJson())

					If oSMJ != Nil
						FreeObj(oSMJ)
						oSMJ := Nil
					EndIf
				Next nI
				::SetResponse(']') 
			EndIf
			
		EndIf
	EndIf

	aSize(aSOX, 0)

	If oJson != Nil
		FreeObj(oJson)
		oJson := Nil
	EndIf

Return lGet

// O metodo POST pode receber parametros por querystring, por exemplo:
// WSMETHOD POST WSRECEIVE startIndex, count WSSERVICE sample
WSMETHOD POST  WSSERVICE FormRegistration
	Local lPost := .T.
	Local cBody := " "
	Local aSOX := {}
	Local cCodForm   := " "
	Local cPrgApon   := " "
	Local cImagem    := " "
	Local cDescricao := " "
	Local oJson

	If !VldDiciona()
		SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
		lPost := .F.	
	Else
		oJson := JsonObject():New()

		cBody := ::GetContent()

		If oJson:fromJson( cBody ) <> nil

			SetRestFault(400, EncodeUTF8(STR0001)) //"Parâmetros do apontamento não enviados ou inválidos."                                                                                                                                                                                                                                                                                                                                                                                                                                                              
			lPost := .F.
		Else
			If Empty(oJson['code'])
				SetRestFault(400, EncodeUTF8(STR0002)) //"Código do Formulário de Apontamento não informado."                                                                                                                                                                                                                                                                                                                                                                                                                                                                
				lPost := .F.
			ElseIf Empty(oJson['description'])
				SetRestFault(400, EncodeUTF8(STR0003)) //"Descrição do Formulário de Apontamento não informado."                                                                                                                                                                                                                                                                                                                                                                                                                                                             
				lPost := .F.
			ElseIf Empty(oJson['iconName'])
				SetRestFault(400, EncodeUTF8(STR0004))  //"Ícone do Formulário de Apontamento não informado."                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
				lPost := .F.
			ElseIf Empty(oJson['appointmentType'])
				SetRestFault(400, EncodeUTF8(STR0005)) //"Programa de Apontamento não informado"                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
				lPost := .F.
			ElseIf !PCPA121Vld('OX_FORM', DecodeUTF8(oJson['code']), 3)
				SetRestFault(400, EncodeUTF8(STR0006)) //"Registro duplicado. Inclusão não permitida!"                                                                                                                                                                                                                                                                                                                                                                                                                                                                       
				lPost := .F.
			ElseIf !PCPA121Vld('OX_PRGAPON', oJson['appointmentType'], 3) 
				SetRestFault(400, EncodeUTF8(STR0007)) //"Programa de Apontamento inválidos. Opção permitida são: 1 = MATA250, 2 = MATA680, 3 = MATA681 , 4 = SFCA314"                                                                                                                                                                                                                                                                                                                                                                                                       
				lPost := .F.
			ElseIf !PCPA121Tam('OX_FORM', DecodeUTF8(oJson['code']))
				SetRestFault(400, EncodeUTF8(STR0008)) //"Campo Código do Formulário está informado com um conteúdo maior que o definido no banco de dados"
				lPost := .F.
			ElseIf !PCPA121Tam('OX_PRGAPON', oJson['appointmentType'])	
				SetRestFault(400, EncodeUTF8(STR0009)) //"Campo Programa de Apontamento está informado com um conteúdo maior que o definido no banco de dados"
				lPost := .F.
			ElseIf !PCPA121Tam('OX_IMAGEM', oJson['iconName'])	
				SetRestFault(400, EncodeUTF8(STR0010)) //"Campo Imagem está informado com um conteúdo maior que o definido no banco de dados"
				lPost := .F.
			ElseIf !PCPA121Tam('OX_DESCR', DecodeUTF8(oJson['description']))	
				SetRestFault(400, EncodeUTF8(STR0011)) //"Campo Descrição do Formulário está informado com um conteúdo maior que o definido no banco de dados"
				lPost := .F.
			ElseIf !Empty(oJson['stopReport'] )
				If !PCPA121Vld('OX_PARADA', oJson['stopReport'], 3)
					SetRestFault(400, EncodeUTF8(STR0022)) //"Campo Apontamento de Parada está informado com conteúdo inválido. Valores válidos: 1-Sim, 2-Não"
					lPost := .F.
				EndIf

				If lPost
					If !PCPA121vld('OX_PARADA', oJson['stopReport'], 3, oJson['appointmentType']) 
						SetRestFault(400, EncodeUTF8(STR0023)) //"É permitido informar o campo Apontamento de Parada somente para o tipo de apontamento 4 - SFCA314."
						lPost := .F.
					EndIf
				EndIf
			EndIf
			
			If !Empty(oJson['useTimer'] )
				If !PCPA121Vld('OX_CRONOM', oJson['useTimer'], 3)
					SetRestFault(400, EncodeUTF8(STR0024)) //"Campo Usar Cronômetro está informado com conteúdo inválido. Valores válidos: 1-Sim, 2-Não"
					lPost := .F.
				EndIf

				If lPost
					If !PCPA121vld('OX_CRONOM', oJson['useTimer'], 3, oJson['appointmentType']) 
						SetRestFault(400, EncodeUTF8(STR0025)) //"É permitido informar o campo Usar Cronômetro somente para o tipo de apontamento 4 - SFCA314."
						lPost := .F.
					EndIf
				EndIf
			EndIf

			If !Empty(oJson['typeProgress'] )
				If !PCPA121Vld('OX_TPPROG', oJson['typeProgress'], 3)
					SetRestFault(400, EncodeUTF8(STR0026)) //"Campo Tipo de Progresso está informado com conteúdo inválido. Valores válidos: 1-Sim, 2-Não"
					lPost := .F.
				EndIf

				If lPost
					If !PCPA121vld('OX_TPPROG', oJson['typeProgress'], 3, oJson['useTimer']) 
						SetRestFault(400, EncodeUTF8(STR0027)) //"É permitido informar o campo Tipo de Progresso somente quando o campo Usar Cronômetro estiver igual a 1 - Sim."
						lPost := .F.
					EndIf
				EndIf
			EndIf
		EndIf
	EndIf

	If lPost
		cCodForm   := DecodeUTF8(oJson['code'])
		cPrgApon   := oJson['appointmentType']
		cImagem    := oJson['iconName']
		cDescricao := DecodeUTF8(oJson['description'])
		cParada    := oJson['stopReport'] 
		cCronom    := oJson['useTimer']
		cTpProg    := oJson['typeProgress']

		aAdd(aSOX,{"OX_FORM"     ,cCodForm   ,Nil})
		aAdd(aSOX,{"OX_PRGAPON"  ,cPrgApon   ,Nil})
		aAdd(aSOX,{"OX_IMAGEM"   ,cImagem    ,Nil})
		aAdd(aSOX,{"OX_DESCR"    ,cDescricao ,Nil})
		aAdd(aSOX,{"OX_PARADA"   ,cParada    ,Nil})
		aAdd(aSOX,{"OX_CRONOM"   ,cCronom    ,Nil})
		aAdd(aSOX,{"OX_TPPROG"   ,cTpProg    ,Nil})

		If !PCPA121In(aSOX) //Função que fará a inclusão da tabela SOX
			lPost := .F.
		EndIf
		::SetResponse(oJson:toJson())
	EndIf
	FreeObj(oJson)
Return lPost

// O metodo PUT pode receber parametros por querystring, por exemplo:
// WSMETHOD PUT WSRECEIVE startIndex, count WSSERVICE sample
WSMETHOD PUT  WSSERVICE FormRegistration
	Local lPut			:= .T.
	Local cBody			:= " "
	Local aSOX			:= {}
	Local cCodForm		:= " "
	Local cPrgApon		:= " "
	Local cImagem		:= " "
	Local cDescricao	:= " "
	Local oJson

	If !VldDiciona()
		SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
		lPut := .F.	
	Else
		oJson := JsonObject():New()

		cBody := ::GetContent()

		If oJson:fromJson( cBody ) <> nil
			SetRestFault(400, EncodeUTF8(STR0001)) //"Parâmetros do apontamento não enviados ou inválidos."
			lPut := .F.
		Else
			If Empty(oJson['code'])
				SetRestFault(400, EncodeUTF8(STR0002)) //"Código do Formulário de Apontamento não informado."
				lPut := .F.
			ElseIf Empty(oJson['description'])
				SetRestFault(400, EncodeUTF8(STR0003)) //"Descrição do Formulário de Apontamento não informado."                                                                                                                                                                                                                                                                                                                                                                                                                                                             
				lPut := .F.
			ElseIf Empty(oJson['iconName'])
				SetRestFault(400, EncodeUTF8(STR0004))  //"Ícone do Formulário de Apontamento não informado."                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
				lPut := .F.
			ElseIf Empty(oJson['appointmentType'])
				SetRestFault(400, EncodeUTF8(STR0005)) //"Programa de Apontamento não informado"                                                                                                                                                                                                                                                                                                                                                                                                                                                                             
				lPut := .F.
			ElseIf !PCPA121vld('OX_FORM', DecodeUTF8(oJson['code']), 4) 
				SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
				lPut := .F.
			ElseIf !PCPA121vld('OX_PRGAPON', oJson['appointmentType'], 4, DecodeUTF8(oJson['code']))
				SetRestFault(400, EncodeUTF8(STR0013)) //"Não é permitido alterar o Programa de Apontamento."
				lPut := .F.
			ElseIf !PCPA121Tam('OX_FORM', DecodeUTF8(oJson['code']))
				SetRestFault(400, EncodeUTF8(STR0008)) //"Campo Código do Formulário está informado com um valor maior que o definido no banco de dados"
				lPut := .F.
			ElseIf !PCPA121Tam('OX_PRGAPON', oJson['appointmentType'])	
				SetRestFault(400, EncodeUTF8(STR0009)) //"Campo Programa de Apontamento está informado com um valor maior que o definido no banco de dados"
				lPut := .F.
			ElseIf !PCPA121Tam('OX_IMAGEM', oJson['iconName'])
				SetRestFault(400, EncodeUTF8(STR0010)) //"Campo Imagem está informado com um valor maior que o definido no banco de dados"
				lPut := .F.
			ElseIf !PCPA121Tam('OX_DESCR', DecodeUTF8(oJson['description']))
				SetRestFault(400, EncodeUTF8(STR0011)) //"Campo Descrição do Formulário está informado com um valor maior que o definido no banco de dados"'	'
				lPut := .F.
			ElseIf !Empty(oJson['stopReport'] )
				If !PCPA121Vld('OX_PARADA', oJson['stopReport'], 3)
					SetRestFault(400, EncodeUTF8(STR0022)) //"Campo Apontamento de Parada está informado com conteúdo inválido. Valores válidos: 1-Sim, 2-Não"
					lPut := .F.
				EndIf

				If lPut
					If !PCPA121vld('OX_PARADA', oJson['stopReport'], 3, oJson['appointmentType']) 
						SetRestFault(400, EncodeUTF8(STR0023)) //"É permitido informar o campo Apontamento de Parada somente para o tipo de apontamento 4 - SFCA314."
						lPut := .F.
					EndIf
				EndIf
			EndIf
			
			If !Empty(oJson['useTimer'] )
				If !PCPA121Vld('OX_CRONOM', oJson['useTimer'], 3)
					SetRestFault(400, EncodeUTF8(STR0024)) //"Campo Usar Cronômetro está informado com conteúdo inválido. Valores válidos: 1-Sim, 2-Não"
					lPut := .F.
				EndIf

				If lPut
					If !PCPA121vld('OX_CRONOM', oJson['useTimer'], 3, oJson['appointmentType']) 
						SetRestFault(400, EncodeUTF8(STR0025)) //"É permitido informar o campo Usar Cronômetro somente para o tipo de apontamento 4 - SFCA314."
						lPut := .F.
					EndIf
				EndIf
			EndIf

			If !Empty(oJson['typeProgress'] )
				If !PCPA121Vld('OX_TPPROG', oJson['typeProgress'], 3)
					SetRestFault(400, EncodeUTF8(STR0026)) //"Campo Tipo de Progresso está informado com conteúdo inválido. Valores válidos: 1-Sim, 2-Não"
					lPut := .F.
				EndIf

				If lPut
					If !PCPA121vld('OX_TPPROG', oJson['typeProgress'], 3, oJson['useTimer']) 
						SetRestFault(400, EncodeUTF8(STR0027)) //"É permitido informar o campo Tipo de Progresso somente quando o campo Usar Cronômetro estiver igual a 1 - Sim."
						lPut := .F.
					EndIf
				EndIf
			EndIf
		EndIf     
	EndIf

	If lPut
		cCodForm   := DecodeUTF8(oJson['code'])
		cPrgApon   := oJson['appointmentType']
		cImagem    := oJson['iconName']
		cDescricao := DecodeUTF8(oJson['description'])
		cParada    := oJson['stopReport'] 
		cCronom    := oJson['useTimer']
		cTpProg    := oJson['typeProgress']

		aAdd(aSOX,{"OX_FORM"     ,cCodForm   ,Nil})
		aAdd(aSOX,{"OX_PRGAPON"  ,cPrgApon   ,Nil})
		aAdd(aSOX,{"OX_IMAGEM"   ,cImagem    ,Nil})
		aAdd(aSOX,{"OX_DESCR"    ,cDescricao ,Nil})
		aAdd(aSOX,{"OX_PARADA"   ,cParada    ,Nil})
		aAdd(aSOX,{"OX_CRONOM"   ,cCronom    ,Nil})
		aAdd(aSOX,{"OX_TPPROG"   ,cTpProg    ,Nil})

		If !PCPA121Atu(aSOX) //Função que fará a atualização da tabela SOX
			lPut := .F.
		EndIf

		::SetResponse(oJson:toJson())
	EndIf
	FreeObj(oJson)
Return lPut

// O metodo DELETE pode receber parametros por querystring, por exemplo:
// WSMETHOD DELETE WSRECEIVE startIndex, count WSSERVICE sample
WSMETHOD DELETE  WSSERVICE FormRegistration
Local lDelete := .T.
Local oJson

If !VldDiciona()
	SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
	lDelete := .F.	
Else
	oJson := JsonObject():New()

	cBody := ::GetContent()

	If oJson:fromJson( cBody ) <> nil
		SetRestFault(400, EncodeUTF8(STR0001)) //"Parâmetros do apontamento não enviados ou inválidos."
		lDelete := .F.
	Else
		If !PCPA121Vld('OX_FORM', DecodeUTF8(oJson['code']), 5) 
			SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
			lDelete := .F.
		EndIf
	EndIf
EndIf

If lDelete
	cCodForm   := DecodeUTF8(oJson['code'])

	If !PCPA121Del(cCodForm) //Função que fará a exclusão da tabela SOX
		lDelete := .F.
	EndIf

	::SetResponse(oJson:toJson())
EndIf
FreeObj(oJson)
Return lDelete

WSMETHOD GET FormUsers WSRECEIVE userCode, startIndex, count, page, onlyHeader, productionOrder WSSERVICE FormRegistration
	Local aHWS    := {}
	Local aSMC    := {}
	Local aSOY    := {}
	Local aSOZ    := {}
	Local cValPad := ""
	Local lGet    := .T.
	Local lHWS    := AliasInDic("HWS")
	Local lSMC    := AliasInDic("SMC")
	Local lSMJ    := AliasInDic("SMJ")
	Local nI      := 0
	Local n1I     := 0
	Local nPos    := 0
	Local oJson   := Nil
	Local oSMJ    := Nil

	// as propriedades da classe receberão os valores enviados por querystring
	// exemplo: http://localhost:8080/sample?startIndex=1&count=10
	DEFAULT ::startIndex := 1, ::count := 20, ::page := 0, ::onlyHeader := 0, ::productionOrder := 0

	// define o tipo de retorno do método
	::SetContentType("application/json")

	If !VldDiciona()
		SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
		lGet := .F.
	Else
		// define o tipo de retorno do método
		oJson := JsonObject():New()

		// verifica se recebeu parametro pela URL
		// exemplo: http://localhost:8080/sample/1
		If !Empty(::userCode)
			// exemplo de retorno de uma lista de objetos JSON
			aSOZ:= PCPA121usf(::userCode, ::startIndex, ::count, ::page, ::productionOrder)

			If Len(aSOZ) < 1
				lGet := .F.
				If ::productionOrder == 1
					SetRestFault(400, EncodeUTF8(STR0028)) //Não há formulários de ordem de produção cadastrados para o usuário.
				Else					
					SetRestFault(400, EncodeUTF8(STR0020)) //Não há formulários de apontamento cadastrados para o usuário.
				EndIf
			Else	
				::SetResponse('[')
				For nI := 1 To len(aSOZ)
					If nI > ::startIndex
						::SetResponse(',')
					EndIf 

					oJson['code'           ] := EncodeUTF8(aSOZ[nI,1])
					oJson['description'    ] := trim(EncodeUTF8(aSOZ[nI,2]))
					oJson['appointmentType'] := aSOZ[nI,3]
					oJson['iconName'       ] := LOWER(trim(aSOZ[nI,4]))
					oJson['stopReport'     ] := aSOZ[nI,5]
					oJson['useTimer'       ] := aSOZ[nI,6]
					oJson['typeProgress'   ] := aSOZ[nI,7]

                    If ::onlyHeader == 0
						aSOY:={}
						aSOY:= PCPA121fld(aSOZ[nI,1], ::userCode, ::startIndex, ::count, ::page)

						If Len(aSOY) < 1
							lGet := .F.
							If ::productionOrder == 1
								SetRestFault(400, EncodeUTF8(STR0028)) //Não há formulários de ordem de produção cadastrados para o usuário.
							Else					
								SetRestFault(400, EncodeUTF8(STR0020)) //Não há formulários de apontamento cadastrados para o usuário.
							EndIf
						Else	
							oJson['FormFields'] := {}
							
							For n1I := 1 To Len(aSOY)
								Aadd(oJson['FormFields'], JsonObject():New())

								oJson['FormFields'][n1I]['code'       ] := EncodeUTF8(aSOY[n1I,1])
								oJson['FormFields'][n1I]['field'      ] := trim(aSOY[n1I,2])
								oJson['FormFields'][n1I]['description'] := trim(EncodeUTF8(aSOY[n1I,3]))
								oJson['FormFields'][n1I]['codebar'    ] := aSOY[n1I,4]
								oJson['FormFields'][n1I]['visible'    ] := aSOY[n1I,5]
								oJson['FormFields'][n1I]['editable'   ] := aSOY[n1I,6]
								oJson['FormFields'][n1I]['default'    ] := execPad(trim(aSOY[n1I,7]))
							Next n1I
						EndIf		

						If lHWS
							aHWS:={}
							aHWS:= PCPA121maq(aSOZ[nI,1], ::userCode, ::startIndex, ::count, ::page)

							oJson['FormMachines'] := {}

							If Len(aHWS) >= 1
								For n1I := 1 To len(aHWS)
									Aadd(oJson['FormMachines'], JsonObject():New())

									oJson['FormMachines'][n1I]['code'       ] := EncodeUTF8(aHWS[n1I,1])
									oJson['FormMachines'][n1I]['machine'    ] := trim(aHWS[n1I,2])
									oJson['FormMachines'][n1I]['description'] := trim(EncodeUTF8(aHWS[n1I,3]))
								Next n1I
							EndIf		
						EndIf	

						If lSMC
							aSMC := {}
							aSMC := PCPA121cus(aSOZ[nI,1], ::userCode, ::startIndex, ::count, ::page)

							oJson['FormCustomField'] := {}

							If Len(aSMC) >= 1
								For n1I := 1 To len(aSMC)
									Aadd(oJson['FormCustomField'], JsonObject():New())

									oJson['FormCustomField'][n1I]['code'        ] := EncodeUTF8(aSMC[n1I,1])
									oJson['FormCustomField'][n1I]['type'        ] := trim(aSMC[n1I,2])
									oJson['FormCustomField'][n1I]['field'       ] := trim(aSMC[n1I,3])
									oJson['FormCustomField'][n1I]['description' ] := trim(EncodeUTF8(aSMC[n1I,4]))
									oJson['FormCustomField'][n1I]['codebar'     ] := aSMC[n1I,5]
									oJson['FormCustomField'][n1I]['visible'     ] := aSMC[n1I,6]
									oJson['FormCustomField'][n1I]['editable'    ] := aSMC[n1I,7]

									nPos := 0
									If "CustomFieldList" $ trim(aSMC[n1I,2])
										oJson['FormCustomField'][n1I]['options'] := getOptions(RTrim(aSmc[n1I,9]))
										
										cValPad := execPad(trim(aSMC[n1I,8]))
										nPos    := AScan(oJson['FormCustomField'][n1I]['options'], {|x| RTrim(x["code"]) == cValPad})
										If(nPos > 0 )
											oJson['FormCustomField'][n1I]['default'] := cValPad
										Else
											oJson['FormCustomField'][n1I]['default'] := ' '	
										EndIf
									Else
										oJson['FormCustomField'][n1I]['default'] := execPad(trim(aSMC[n1I,8]))
									EndIf

								Next n1I
							EndIf
						EndIf

						If lSMJ 
							oSMJ := PCPA121Emp(aSOZ[nI,1], .T.)
							oJson["viewAllocations"  ] := oSMJ["viewAllocations"  ]
							oJson["insertAllocations"] := oSMJ["insertAllocations"]
							oJson["updateAllocations"] := oSMJ["updateAllocations"]
							oJson["deleteAllocations"] := oSMJ["deleteAllocations"]
							oJson["allocationFields" ] := oSMJ["allocationFields" ]

							If oSMJ != Nil
								FreeObj(oSMJ)
								oSMJ := Nil
							EndIf
						EndIf
					EndIf

					::SetResponse(oJson:toJson())
				Next nI

				::SetResponse(']')
			EndIf
		Else
			SetRestFault(400, EncodeUTF8(STR0019)) //"Usuário não informado."
			lGet := .F.
		EndIf
	EndIf

	If oJson != Nil
		FreeObj(oJson)
		oJson := Nil
	EndIf

	aSize(aHWS, 0)
	aSize(aSMC, 0)
	aSize(aSOY, 0)
	aSize(aSOZ, 0)
Return lGet

WSMETHOD GET FormFields WSRECEIVE codeForm, userCode, startIndex, count, page WSSERVICE FormRegistration

Local aSOY  := {}
Local lGet  := .T.
Local nI    := 0
Local oJson

// define o tipo de retorno do método
::SetContentType("application/json")

If !VldDiciona()
	SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
	lGet := .F.
Else

	// define o tipo de retorno do método
	oJson := JsonObject():New()

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/sample/1

	If !Empty(::codeForm) .And. !Empty(::userCode)

		// as propriedades da classe receberão os valores enviados por querystring
		// exemplo: http://localhost:8080/sample?startIndex=1&count=10
		DEFAULT ::startIndex := 1, ::count := 20, ::page := 0

		// exemplo de retorno de uma lista de objetos JSON
		aSOY:= PCPA121fld(::codeForm, ::userCode, ::startIndex, ::count, ::page)
		
		If Len(aSOY) < 1
			lGet := .F.
			SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
		Else	
			::SetResponse('[')
			For nI := 1 To len(aSOY)
				If nI > ::startIndex
					::SetResponse(',')
				EndIf
				oJson['code']			:= EncodeUTF8(aSOY[nI,1])
				oJson['field']			:= trim(aSOY[nI,2])
				oJson['description']	:= trim(EncodeUTF8(aSOY[nI,3]))
				oJson['codebar']		:= aSOY[nI,4]
				oJson['visible']		:= aSOY[nI,5]
				oJson['editable']		:= aSOY[nI,6]
				oJson['default']		:= execPad(trim(aSOY[nI,7]))
				
				::SetResponse(oJson:toJson())
			Next nI
			::SetResponse(']')
		EndIf
	Else
		if Empty(::codeForm)
			SetRestFault(400, EncodeUTF8(STR0002)) //"Código do Formulário de Apontamento não informado."
			lGet := .F.
		ElseIf Empty(::userCode)
			SetRestFault(400, EncodeUTF8(STR0019)) //"Usuário não informado."
			lGet := .F.
		EndIf
	EndIf
EndIf

Return lGet

WSMETHOD GET FormConfig WSRECEIVE codeForm, userCode, startIndex, count, page WSSERVICE FormRegistration
	Local aHWS    := {}
	Local aSMC    := {}
	Local aSOX    := {}
	Local aSOY    := {}
	Local cValPad := ""
	Local lGet    := .T.
	Local lHWS    := AliasInDic("HWS")
	Local lSMC    := AliasInDic("SMC")
	Local lSMJ    := AliasInDic("SMJ")
	Local nI      := 0
	Local nPos
	Local oJson
	Local oSMJ  := Nil

	// as propriedades da classe receberão os valores enviados por querystring
	// exemplo: http://localhost:8080/sample?startIndex=1&count=10
	DEFAULT ::startIndex := 1, ::count := 40, ::page := 0

	// define o tipo de retorno do método
	::SetContentType("application/json")

	If !VldDiciona()
		SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
		lGet := .F.
	Else
		// define o tipo de retorno do método
		oJson := JsonObject():New()

		If !Empty(::codeForm) .And. !Empty(::userCode)
			aSOX := PCPA121Con(::codeForm)

			If Len(aSOX) > 0
				aSOY:= PCPA121fld(::codeForm, ::userCode, ::startIndex, ::count, ::page)

				If Len(aSOY) < 1
					lGet := .F.
					SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
				Else
					oJson['code']            := EncodeUTF8(aSOX[1,1])
					oJson['appointmentType'] := aSOX[1,2]
					oJson['iconName']        := LOWER(trim(aSOX[1,3]))
					oJson['description']     := trim(EncodeUTF8(aSOX[1,4]))
					oJson['stopReport']      := aSOX[1,5]
					oJson['useTimer']        := aSOX[1,6]
					oJson['typeProgress']    := aSOX[1,7]

					oJson['FormFields'] := {}
					
					For nI := 1 To len(aSOY)
						Aadd(oJson['FormFields'], JsonObject():New())

						oJson['FormFields'][nI]['code']        := EncodeUTF8(aSOY[nI,1])
						oJson['FormFields'][nI]['field']       := trim(aSOY[nI,2])
						oJson['FormFields'][nI]['description'] := trim(EncodeUTF8(aSOY[nI,3]))
						oJson['FormFields'][nI]['codebar']     := aSOY[nI,4]
						oJson['FormFields'][nI]['visible']     := aSOY[nI,5]
						oJson['FormFields'][nI]['editable']    := aSOY[nI,6]
						oJson['FormFields'][nI]['default']	   := execPad(trim(aSOY[nI,7]))
					Next nI

					If lHWS
						aHWS:={}
						aHWS:= PCPA121maq(::codeForm, ::userCode, ::startIndex, ::count, ::page)

						oJson['FormMachines'] := {}

						If Len(aHWS) >= 1
							For nI := 1 To len(aHWS)
								Aadd(oJson['FormMachines'], JsonObject():New())

								oJson['FormMachines'][nI]['code']        := EncodeUTF8(aHWS[nI,1])
								oJson['FormMachines'][nI]['machine']     := trim(aHWS[nI,2])
								oJson['FormMachines'][nI]['description'] := trim(EncodeUTF8(aHWS[nI,3]))
							Next nI
						EndIf		
					EndIf	

					If lSMC
						aSMC := {}
						aSMC := PCPA121cus(::codeForm, ::userCode, ::startIndex, ::count, ::page)

						oJson['FormCustomField'] := {}

						If Len(aSMC) >= 1
							For nI := 1 To len(aSMC)
								Aadd(oJson['FormCustomField'], JsonObject():New())
								
								oJson['FormCustomField'][nI]['code']        := EncodeUTF8(aSMC[nI,1])
								oJson['FormCustomField'][nI]['type']        := trim(aSMC[nI,2])
								oJson['FormCustomField'][nI]['field']       := trim(aSMC[nI,3])
								oJson['FormCustomField'][nI]['description'] := trim(EncodeUTF8(aSMC[nI,4]))
								oJson['FormCustomField'][nI]['codebar']     := aSMC[nI,5]
								oJson['FormCustomField'][nI]['visible']     := aSMC[nI,6]
								oJson['FormCustomField'][nI]['editable']    := aSMC[nI,7]

								nPos := 0
								If "CustomFieldList" $ trim(aSMC[nI,2])
									oJson['FormCustomField'][nI]['options'] := getOptions(RTrim(aSmc[nI,9]))

									cValPad := execPad(trim(aSMC[nI,8]))
									nPos    := AScan(oJson['FormCustomField'][nI]['options'], {|x| RTrim(x["code"]) == cValPad})
									If(nPos > 0 )
										oJson['FormCustomField'][nI]['default'] := cValPad
									Else
										oJson['FormCustomField'][nI]['default'] := ' '	
									EndIf
								Else
									oJson['FormCustomField'][nI]['default'] := execPad(trim(aSMC[nI,8]))
								EndIf
								
							Next nI
						EndIf
					EndIf

					If lSMJ 
						oSMJ := PCPA121Emp(::codeForm, .T.)
						oJson["viewAllocations"  ] := oSMJ["viewAllocations"  ]
						oJson["insertAllocations"] := oSMJ["insertAllocations"]
						oJson["updateAllocations"] := oSMJ["updateAllocations"]
						oJson["deleteAllocations"] := oSMJ["deleteAllocations"]
						oJson["allocationFields" ] := oSMJ["allocationFields" ]
					EndIf

					::SetResponse(oJson:toJson())

					If oSMJ != Nil
						FreeObj(oSMJ)
						oSMJ := Nil
					EndIf
				EndIf
			Else
				lGet := .F.
				SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
			EndIf
		Else
			if Empty(::codeForm)
				SetRestFault(400, EncodeUTF8(STR0002)) //"Código do Formulário de Apontamento não informado."
				lGet := .F.
			ElseIf Empty(::userCode)
				SetRestFault(400, EncodeUTF8(STR0019)) //"Usuário não informado."
				lGet := .F.
			EndIf
		EndIf
	EndIf

	If oJson != Nil
		FreeObj(oJson)
		oJson := Nil
	EndIf

	aSize(aHWS, 0)
	aSize(aSMC, 0)
	aSize(aSOY, 0)
	aSize(aSOX, 0)
Return lGet

WSMETHOD GET FormMachines WSRECEIVE codeForm, userCode, startIndex, count, page WSSERVICE FormRegistration

Local aHWS  := {}
Local lGet  := .T.
Local nI    := 0
Local oJson

// define o tipo de retorno do método
::SetContentType("application/json")

If !VldDiciona()
	SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
	lGet := .F.
Else

	// define o tipo de retorno do método
	oJson := JsonObject():New()

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/sample/1

	If !Empty(::codeForm) .And. !Empty(::userCode)

		// as propriedades da classe receberão os valores enviados por querystring
		// exemplo: http://localhost:8080/sample?startIndex=1&count=10
		DEFAULT ::startIndex := 1, ::count := 20, ::page := 0

		// exemplo de retorno de uma lista de objetos JSON
		aHWS:= PCPA121maq(::codeForm, ::userCode, ::startIndex, ::count, ::page)
		
		If Len(aHWS) < 1
			lGet := .F.
			SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
		Else	
			::SetResponse('[')
			For nI := 1 To len(aHWS)
				If nI > ::startIndex
					::SetResponse(',')
				EndIf
				oJson['code']  	     := EncodeUTF8(aHWS[nI,1])
				oJson['machine']     := trim(aHWS[nI,2])
				oJson['description'] := trim(EncodeUTF8(aHWS[nI,3]))
				
				::SetResponse(oJson:toJson())
			Next nI
			::SetResponse(']')
		EndIf
	Else
		if Empty(::codeForm)
			SetRestFault(400, EncodeUTF8(STR0002)) //"Código do Formulário de Apontamento não informado."
			lGet := .F.
		ElseIf Empty(::userCode)
			SetRestFault(400, EncodeUTF8(STR0019)) //"Usuário não informado."
			lGet := .F.
		EndIf
	EndIf
EndIf

Return lGet

WSMETHOD GET FormCustomField WSRECEIVE codeForm, userCode, startIndex, count, page WSSERVICE FormRegistration

Local aSMC    := {}
Local cValPad := ""
Local lGet    := .T.
Local nI      := 0
Local nPos    := 0
Local oJson

// define o tipo de retorno do método
::SetContentType("application/json")

If !VldDiciona()
	SetRestFault(400, EncodeUTF8(STR0021)) //"Tabela SOX ou SOY ou SOZ não cadastrada no sistema!"
	lGet := .F.
Else
	// define o tipo de retorno do método
	oJson := JsonObject():New()

	// verifica se recebeu parametro pela URL
	// exemplo: http://localhost:8080/sample/1

	If !Empty(::codeForm) .And. !Empty(::userCode)

		// as propriedades da classe receberão os valores enviados por querystring
		// exemplo: http://localhost:8080/sample?startIndex=1&count=10
		DEFAULT ::startIndex := 1, ::count := 20, ::page := 0

		// exemplo de retorno de uma lista de objetos JSON
		aSMC:= PCPA121cus(::codeForm, ::userCode, ::startIndex, ::count, ::page)
		
		If Len(aSMC) < 1
			lGet := .F.
			SetRestFault(400, EncodeUTF8(STR0012)) //"Formulário não encontrado."
		Else	
			::SetResponse('[')
			For nI := 1 To len(aSMC)
				If nI > ::startIndex
					::SetResponse(',')
				EndIf

				oJson['code']  	      := EncodeUTF8(aSMC[nI,1])
				oJson['type']         := trim(aSMC[nI,2])
				oJson['field']		  := trim(aSMC[nI,3])
				oJson['description']  := trim(EncodeUTF8(aSMC[nI,4]))
				oJson['codebar']	  := aSMC[nI,5]
				oJson['visible']	  := aSMC[nI,6]
				oJson['editable']	  := aSMC[nI,7]

				nPos := 0
				If "CustomFieldList" $ trim(aSMC[nI,2])
					oJson['options'] := getOptions(RTrim(aSmc[nI,9]))

					cValPad := execPad(trim(aSMC[nI,8]))
					nPos    := AScan(oJson['options'], {|x| RTrim(x["code"]) == cValPad})
					If(nPos > 0 )
						oJson['default'] := cValPad
					Else
						oJson['default'] := ' '	
					EndIf
				Else
					oJson['default'] := execPad(trim(aSMC[nI,8]))
				EndIf
				
				::SetResponse(oJson:toJson())
			Next nI
			::SetResponse(']')
		EndIf
	Else
		if Empty(::codeForm)
			SetRestFault(400, EncodeUTF8(STR0002)) //"Código do Formulário de Apontamento não informado."
			lGet := .F.
		ElseIf Empty(::userCode)
			SetRestFault(400, EncodeUTF8(STR0019)) //"Usuário não informado."
			lGet := .F.
		EndIf
	EndIf
EndIf

Return lGet

/*/{Protheus.doc} VldDiciona
	Valida se as tabelas SOX, SOY e SOZ estão no dicionário.
	@typVldDiciona

	@author Michelle Ramos
	@since 14/12/2018
	@param Sem parâmetro
	@return True or False

/*/
 Static Function VldDiciona()
	Local lRet := .T.

	if lDicValido == Nil
		If !AliasInDic("SOX") .Or. !AliasInDic("SOY") .Or. !AliasInDic("SOZ")
			lRet := .F.
			lDicValido := .F.
		Else
			lDicValido := .T.
		EndIf
	Else
		lRet := lDicValido
	EndIf

Return lRet

/*/{Protheus.doc} execPad
Avalia código do campo Valor padrão e executa funções que sejam passadas 
no campo ( obrigatório uso de "_" para definir que o valor é função)

@type  Function
@author douglas.Heydt
@since 16/08/2021
@version P12.1.30
@param cValPad  , Caracter, Valor padrão para o campo informado na rotina de formulários
@return cReturn , Caracter, Retorna o valor padrão atualizado.
/*/
Function execPad(cValPad)
	Local cReturn := ""

	IF SUBSTR(cValPad, 0, 1) == "_"
		cFunc := SUBSTR(cValPad, 2, Len(cValPad) )
		IF FindFunction(cFunc)
			cReturn := &cFunc
		ENDIF
	ELSE
		cReturn := cValPad
	ENDIF

return cReturn

/*/{Protheus.doc} getOptions
Retorna as informações da SX5 para determinada tabela

@type  Static Function
@author lucas.franca
@since 14/12/2021
@version P12
@param cTabela, Charactrer, Código da tabela da SX5
@return aOptions, Array, Array com as opções disponíveis
/*/
Static Function getOptions(cTabela)
	Local aOptions  := {}
	Local aDadosSX5 := FWGetSX5(cTabela) 
	Local nIndex    := 0
	Local nTotal    := Len(aDadosSX5)
	
	aOptions := Array(nTotal)

	For nIndex := 1 To nTotal 
		aOptions[nIndex] := JsonObject():New()
		aOptions[nIndex]["code"       ] := EncodeUTF8(RTrim(aDadosSX5[nIndex][3]))
		aOptions[nIndex]["description"] := EncodeUTF8(aOptions[nIndex]["code"] + " - " + RTrim(aDadosSX5[nIndex][4]))
	Next nIndex

	aSize(aDadosSX5, 0)

Return aOptions
