#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} GX300Viagem
Geração da Viagem Especial no momento que finalizada a oportunidade
@type function
@author jacomo.fernandes
@since 02/08/2018
@version 1.0
@param oMdlAD1, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GX300Viagem(oModel,cPurchase)
	
	Local lRet			:= .T.

	Default oModel		:= FwModelActive()
	Default cPurchase	:= ""

	If ( oModel:GetId() == "GTPA600B" .and. oModel:GetOperation() <> MODEL_OPERATION_INSERT )

		Processa({|| lRet := GerVgExtr(cPurchase)},"Aguarde...","Gerando viagens extraordinárias.")

	EndIf

Return lRet

/*/{Protheus.doc} GerVgExtr
(long_description)
@type function
@author jacomo.fernandes
@since 13/12/2018
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GerVgExtr(cPurchase)

	Local lRet 			:= .T.

	Local oMdl300 		:= FWLoadModel("GTPA300") //Modelo da viagem
	Local oMdlGYN		:= oMdl300:GetModel("GYNMASTER")	
	Local oMdlG55		:= oMdl300:GetModel("G55DETAIL") 
	Local oMdl600		:= FWLoadModel("GTPA600") //Modelo do Orçamento de Viagem
	Local oMdlG6R		:= oMdl600:GetModel("MASTER")

	Local cCdSvEsp		:= SuperGetMv("MV_GTPCSVE") 

	Local lAlocacao		:= G6R->G6R_DISPVE == '3'
	Local lItiner		:= G6R->G6R_TIPITI == '2'//Ida e Volta

	Local nViagens		:= If(!lAlocacao,1,2)
	Local nVeiculos		:= G6R->G6R_QUANT
	Local n1			:= 0
	Local n2			:= 0
	Local n3			:= 0
	Local nTrechoDe		:= 0
	Local nTrechoAte	:= 0
	Local nLinha		:= 0

	Local aTrechos		:= {}

	nP := aScan(oMdl300:Cargo,{|z| z[1] == "FUNNAME"})

	If (nP > 0 )
		oMdl300:Cargo[nP][2] := "GX300VIAGEM"
	EndIf

	oMdlGYN:GetStruct():SetProperty("GYN_CODIGO" 	, MODEL_FIELD_INIT, {|| GTPXENUM('GYN','GYN_CODIGO',1) })

	oMdl600:SetOperation(MODEL_OPERATION_VIEW)

	If oMdl600:Activate()

		aTrechos := GetTrechos(oMdl600)
		
		If Len(aTrechos) > 0
			//Para cada veiculo, é criado uma viagem
			For n1 := 1 to nVeiculos
				//Caso alocação, cria-se duas viagens, se não, apenas uma 
				For n2 := 1 to nViagens
					
					oMdl300:SetOperation(MODEL_OPERATION_INSERT)
		
					If oMdl300:Activate()
						
						oMdlGYN:LoadValue('GYN_TIPO'		,"2")//Especial
						oMdlGYN:LoadValue('GYN_SRVEXT'	,cCdSvEsp)
						oMdlGYN:LoadValue("GYN_IDENT"	, "1")
						
						IF ( !Empty(cPurchase) .And. oMdlG6R:HasField("G6R_PEDIDO") )
							oMdlGYN:LoadValue("GYN_CODPED", cPurchase)
						EndIf
						
						oMdlGYN:LoadValue("GYN_ITINI"	, oMdlG6R:GetValue("G6R_ENDEMB")  )
						oMdlGYN:LoadValue("GYN_ITFIM"	, oMdlG6R:GetValue("G6R_ENDDES")  )		
						oMdlGYN:LoadValue('GYN_KMPROV' 	, oMdlG6R:GetValue("G6R_KMCONT") )
						oMdlGYN:LoadValue('GYN_LOTACA' 	, oMdlG6R:GetValue("G6R_POLTR") )
						
						If lAlocacao 
							nTrechoDe	:= If(n2 == 1,1,aScan(aTrechos,{|x| x[9] == 2 }) ) 	
							nTrechoAte  := If(n2 == 1,aScan(aTrechos,{|x| x[9] == 2 })-1,Len(aTrechos) )
						Else
							nTrechoDe	:= 1
							nTrechoAte  := Len(aTrechos)
						Endif
						
						nLinha := 0
						
						For n3 := nTrechoDe to nTrechoAte
							
							If !oMdlG55:IsEmpty() .and. !Empty(oMdlG55:GetValue('G55_SEQ'))
								oMdlG55:AddLine()
							Endif
							nLinha++
							oMdlG55:LoadValue('G55_SEQ'		,StrZero(nLinha,TamSx3('G55_SEQ')[1]))
							oMdlG55:LoadValue('G55_LOCORI'	,aTrechos[n3][2])
							oMdlG55:LoadValue('G55_DTPART'	,aTrechos[n3][3])
							oMdlG55:LoadValue('G55_HRINI'	,aTrechos[n3][4])
							oMdlG55:LoadValue('G55_LOCDES'	,aTrechos[n3][5])
							oMdlG55:LoadValue('G55_DTCHEG'	,aTrechos[n3][6])
							oMdlG55:LoadValue('G55_HRFIM'	,aTrechos[n3][7])
							
							oMdlG55:LoadValue('G55_CANCEL'	,'1') //Não cancelado
							oMdlG55:LoadValue('G55_CONF'		,'2') //Não conferido
							
						Next
						
						If !lAlocacao 
							
							oMdlGYN:LoadValue('GYN_LOCORI'	,oMdlG6R:GetValue("G6R_LOCORI"))
							oMdlGYN:LoadValue('GYN_DTINI'	,oMdlG6R:GetValue("G6R_DTIDA"))
							oMdlGYN:LoadValue('GYN_HRINI'	,oMdlG6R:GetValue("G6R_HRIDA"))
							
							oMdlGYN:LoadValue('GYN_LOCDES'	,oMdlG6R:GetValue("G6R_LOCDES"))
							
							If lItiner
								oMdlGYN:LoadValue('GYN_DTFIM'	,oMdlG6R:GetValue("G6R_DTVLTA"))
								oMdlGYN:LoadValue('GYN_HRFIM'	,oMdlG6R:GetValue("G6R_HRVLTA"))
							Else
								oMdlGYN:LoadValue('GYN_DTFIM'	,oMdlG55:GetValue("G55_DTCHEG"	,oMdlG55:Length()))
								oMdlGYN:LoadValue('GYN_HRFIM'	,oMdlG55:GetValue("G55_HRFIM"	,oMdlG55:Length()))
							Endif
							
						Else
							If n2 == 1
								oMdlGYN:LoadValue('GYN_LOCORI'	,oMdlG6R:GetValue("G6R_LOCORI"))
								oMdlGYN:LoadValue('GYN_DTINI'	,oMdlG6R:GetValue("G6R_DTIDA"))
								oMdlGYN:LoadValue('GYN_HRINI'	,oMdlG6R:GetValue("G6R_HRIDA"))
								
								oMdlGYN:LoadValue('GYN_LOCDES'	,oMdlG6R:GetValue("G6R_LOCDES"))
								oMdlGYN:LoadValue('GYN_DTFIM'	,oMdlG55:GetValue("G55_DTCHEG"	,oMdlG55:Length()))
								oMdlGYN:LoadValue('GYN_HRFIM'	,oMdlG55:GetValue("G55_HRFIM"	,oMdlG55:Length()))
							Else
								oMdlGYN:LoadValue('GYN_LOCORI'	,oMdlG6R:GetValue("G6R_LOCDES"))
								oMdlGYN:LoadValue('GYN_DTINI'	,oMdlG55:GetValue("G55_DTPART"	,1))
								oMdlGYN:LoadValue('GYN_HRINI'	,oMdlG55:GetValue("G55_HRINI"	,1))
								
								oMdlGYN:LoadValue('GYN_LOCDES'	,oMdlG6R:GetValue("G6R_LOCORI"))
								
								If lItiner 
									oMdlGYN:LoadValue('GYN_DTFIM'	,oMdlG55:GetValue("G55_DTCHEG"	,oMdlG55:Length()))
									oMdlGYN:LoadValue('GYN_HRFIM'	,oMdlG55:GetValue("G55_HRFIM"	,oMdlG55:Length()))
								/*Else
									oMdlGYN:LoadValue('GYN_DTFIM'	,oMdlG6R:GetValue("G6R_DTVLTA"))
									oMdlGYN:LoadValue('GYN_HRFIM'	,oMdlG6R:GetValue("G6R_HRVLTA"))*/
								Endif
								
							Endif
							
						Endif
						
						If lRet .and. oMdl300:VldData() 
							oMdl300:CommitData()
						Else
							lRet	:= .F.
							JurShowError(oMdl300:GetErrorMessage())
						Endif
						oMdl300:DeActivate()
					Endif
										
					If !lRet 
						Exit
					Endif
				Next
				
				If !lRet 
					Exit
				Endif
			
			Next
	
			oMdl300:Destroy()
	
		Endif

		oMdl600:DeActivate()

	Endif

	oMdl600:Destroy()

	GTPDestroy(aTrechos)

Return(lRet)

/*/{Protheus.doc} GetTrechos
(long_description)
@type function
@author jacomo.fernandes
@since 13/12/2018
@version 1.0
@param oMdl600, objeto, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function GetTrechos(oMdl600)
Local oMdlG9C		:= oMdl600:GetModel("G9CDETAIL")
Local lAlocacao		:= G6R->G6R_DISPVE == '3'
Local lItiner		:= G6R->G6R_TIPITI == '2'//Ida e Volta

Local aTrecho		:= {}
Local aTrechos		:= {}

Local aTrechosIda	:= {}
Local aTrechosVolta	:= {}

Local n1			:= 0

Local dDtAux		:= G6R->G6R_DTVLTA
Local cHrAux		:= G6R->G6R_HRVLTA

Local dDtIni		:= nil
Local cHrIni        := nil
Local dDtFim        := nil
Local cHrFim        := nil

Local nHrAux		:= 0

For n1 := 1 to oMdlG9C:Length()
	oMdlG9C:GoLine(n1)
	
	aSize(aTrecho,0)
	
	aAdd(aTrecho,Len(aTrechosIda)+1)//Sequencia De trechos
	
	aAdd(aTrecho,oMdlG9C:GetValue('G9C_CODORI'))//Origem
	aAdd(aTrecho,oMdlG9C:GetValue('G9C_DTORIG'))//Dt Origem
	aAdd(aTrecho,oMdlG9C:GetValue('G9C_HRORIG'))//Hr Origem
	
	aAdd(aTrecho,oMdlG9C:GetValue('G9C_CODDES'))//Destino
	aAdd(aTrecho,oMdlG9C:GetValue('G9C_DTDEST'))//Dt Destino
	aAdd(aTrecho,oMdlG9C:GetValue('G9C_HRDEST'))//Hr Destino
	
	nHrAux := DataHora2Val(oMdlG9C:GetValue('G9C_DTORIG'),;
							 GTFormatHour(oMdlG9C:GetValue('G9C_HRORIG'), "99:99"),;
							 oMdlG9C:GetValue('G9C_DTDEST'),;
							 GTFormatHour(oMdlG9C:GetValue('G9C_HRDEST'), "99:99"),;
							 "H" )
	nHrAux := HoraToInt(GTFormatHour(nHrAux, "99:99"))
	
	aAdd(aTrecho,nHrAux)//Diferença de um treco pro outro
	
	aAdd(aTrecho,1) //Indica se é da primeira viagem ou se alocação deverá distinguir as viagens
	
	aAdd(aTrechosIda,aClone(aTrecho))		

Next

If lItiner

	For n1 := 1 to Len(aTrechosIda)
		aSize(aTrecho,0)
		
		dDtFim	:= dDtAux
		cHrFim	:= GTFormatHour(cHrAux, "9999")
		
		nHrAux	:= HoraToInt(cHrAux)-aTrechosIda[n1][8]
		If nHrAux < 0 //Se Hora for negativa, siginifica que mudou o dia
			dDtAux	:= dDtAux-1
		    nHrAux	:= 24+nHrAux  
		Endif 
		cHrAux	:= IntToHora(nHrAux)
		
		dDtIni	:= dDtAux
		cHrIni	:= GTFormatHour(cHrAux, "9999")
	
		aAdd(aTrecho,Len(aTrechosVolta)+1)//Sequencia De trechos
			
		aAdd(aTrecho,aTrechosIda[n1][5])//Origem
		aAdd(aTrecho,dDtIni)//Dt Origem
		aAdd(aTrecho,cHrIni)//Hr Origem
		
		aAdd(aTrecho,aTrechosIda[n1][2]	)//Destino
		aAdd(aTrecho,dDtFim  			)//Dt Destino
		aAdd(aTrecho,cHrFim				)//Hr Destino
		
		aAdd(aTrecho,aTrechosIda[n1][8])//Diferença de um treco pro outro
		
		aAdd(aTrecho,If(lAlocacao,2,1)) //Indica se é da primeira viagem ou se alocação deverá distinguir as viagens
		
		aAdd(aTrechosVolta,aClone(aTrecho))	
		
	Next 
	
	ASORT(aTrechosVolta,,, { |x, y| x[1] > y[1] } ) 
	
	If !lAlocacao
	
		aSize(aTrecho,0)
		
		aAdd(aTrecho,Len(aTrechos)+1						)//Sequencia De trechos
		aAdd(aTrecho,aTrechosIda[Len(aTrechosIda)][5]		)//Origem
		aAdd(aTrecho,aTrechosIda[Len(aTrechosIda)][6]		)//Dt Origem
		aAdd(aTrecho,aTrechosIda[Len(aTrechosIda)][7]		)//Hr Origem
		
		aAdd(aTrecho,aTrechosVolta[1][2]	)//Destino
		aAdd(aTrecho,aTrechosVolta[1][3]	)//Dt Destino
		aAdd(aTrecho,aTrechosVolta[1][4]	)//Hr Destino
		
		nHrAux := DataHora2Val(aTrecho[3],;
								 GTFormatHour(aTrecho[4], "99:99"),;
								 aTrecho[6],;
								 GTFormatHour(aTrecho[7], "99:99"),;
								 "H" )
		nHrAux := HoraToInt(GTFormatHour(nHrAux, "99:99"))
		
		aAdd(aTrecho,nHrAux	)//Diferença de um treco pro outro
		aAdd(aTrecho,1		) //Indica se é da primeira viagem ou se alocação deverá distinguir as viagens
		
		aAdd(aTrechosIda,aClone(aTrecho))
	
	Endif

Endif

For n1 := 1 To Len(aTrechosIda)

	aSize(aTrecho,0)
	
	aAdd(aTrecho,Len(aTrechos)+1	)//Sequencia De trechos
	aAdd(aTrecho,aTrechosIda[n1][2]	)//Origem
	aAdd(aTrecho,aTrechosIda[n1][3]	)//Dt Origem
	aAdd(aTrecho,aTrechosIda[n1][4]	)//Hr Origem
	aAdd(aTrecho,aTrechosIda[n1][5]	)//Destino
	aAdd(aTrecho,aTrechosIda[n1][6]	)//Dt Destino
	aAdd(aTrecho,aTrechosIda[n1][7]	)//Hr Destino
	aAdd(aTrecho,aTrechosIda[n1][8]	)//Diferença de um treco pro outro
	aAdd(aTrecho,aTrechosIda[n1][9]	) //Indica se é da primeira viagem ou se alocação deverá distinguir as viagens
	
	aAdd(aTrechos,aClone(aTrecho))
	
Next

If lItiner
	For n1 := 1 To Len(aTrechosVolta)
	
		aSize(aTrecho,0)
		
		aAdd(aTrecho,Len(aTrechos)+1	)//Sequencia De trechos
		aAdd(aTrecho,aTrechosVolta[n1][2]	)//Origem
		aAdd(aTrecho,aTrechosVolta[n1][3]	)//Dt Origem
		aAdd(aTrecho,aTrechosVolta[n1][4]	)//Hr Origem
		aAdd(aTrecho,aTrechosVolta[n1][5]	)//Destino
		aAdd(aTrecho,aTrechosVolta[n1][6]	)//Dt Destino
		aAdd(aTrecho,aTrechosVolta[n1][7]	)//Hr Destino
		aAdd(aTrecho,aTrechosVolta[n1][8]	)//Diferença de um treco pro outro
		aAdd(aTrecho,aTrechosVolta[n1][9]	) //Indica se é da primeira viagem ou se alocação deverá distinguir as viagens
		
		aAdd(aTrechos,aClone(aTrecho))
	Next
Endif

Return aTrechos

/*/{Protheus.doc} GTP300aCab
Função responsavel para complementar os dados de da geração do pedido quando vem pelo modulo do GTP
@type function
@author jacomo.fernandes
@since 25/05/2018
@version 1.0
@param aCabec, array, Array utilizado para preenchimento dos dados via MsExecAuto
@param cPropos, character, Numero da Proposta para posicionar na tabela de percurso da proposta comercial
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Function GTPX300aCab(aCabec,cOportuni,cPropos)
Local aArea		:=	GetArea()
Local lHasFld	:= 	SC5->(ColumnPos("C5_UFORIG")) > 0 ;
					.AND. SC5->(ColumnPos("C5_CMUNOR")) > 0 ;
					.AND. SC5->(ColumnPos("C5_UFDEST")) > 0 ;
					.AND. SC5->(ColumnPos("C5_CMUNDE")) > 0 
					
aAdd(aCabec,{"C5_ORIGEM","GTPA600"	,Nil})

G6R->(DbSetOrder(5)) // G6R_FILIAL+G6R_NROPOR+G6R_PROPOS
If lHasFld .AND.  G6R->(DbSeek(xFilial('G6R')+cOportuni+cPropos))
	aAdd(aCabec,{"C5_UFORIG",Posicione('GI1',1,xFilial('GI1')+G6R->G6R_LOCORI,'GI1_UF')		,Nil})
	aAdd(aCabec,{"C5_CMUNOR",Posicione('GI1',1,xFilial('GI1')+G6R->G6R_LOCORI,'GI1_CDMUNI')	,Nil})
	aAdd(aCabec,{"C5_UFDEST",Posicione('GI1',1,xFilial('GI1')+G6R->G6R_LOCDES,'GI1_UF')		,Nil})
	aAdd(aCabec,{"C5_CMUNDE",Posicione('GI1',1,xFilial('GI1')+G6R->G6R_LOCDES,'GI1_CDMUNI')	,Nil})
Endif

RestArea(aArea)

Return
