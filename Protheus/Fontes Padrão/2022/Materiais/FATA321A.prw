#INCLUDE "FATA321A.CH"
#INCLUDE "Protheus.ch"
#INCLUDE "TopConn.ch"

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft321SincCon()
Sincroniza contatos do Protheus com o exchange.

@return cRet Relação de contatos do representante.
@author Vendas CRM
@since 04/06/2013
/*/
//------------------------------------------------------------------------------------------------

Function Ft321SincCon(aInfo, lAutomatico)

Local cQuery      := ""
Local aContatos   := {}
Local aRet 	      := {.F., ""}
Local lPEExCont   := ExistBlock("PEEXCONT")	// Ponto de entrada para montagem do array de contatos.
Local cCodVend    := ""
Local cCodUsr     := ""
Local cOperConc   := if(Trim(Upper(TcGetDb())) $ "ORACLE,POSTGRES,DB2,INFORMIX","||", "+")

Default lAutomatico := .F.

If  nModulo == 73 
	cCodUsr :=  RetCodUsr() //Usuario logad 
Else
	cCodVend := Ft320RpSel()
EndIf
	
If SU5->(FieldPos("U5_IDEXC")) > 0 
	      
	If Select("TMP1") > 0
	   	DBSelectArea("TMP1")   
	    DBCloseArea()
	Endif    
	
	// Caso tenha Ponto de entrada para definição de array dos contatos, nao utiliza a query
	If lPEExCont
		aContatos := ExecBlock("PEEXCONT",.F.,.F., {cCodVend})
		If ValType(aContatos) <> "A"
			aContatos := {}
		EndIf
	Else
		If nModulo == 73 
 			// Busca contatos relacionados com o representante utilizando.	
			cQuery := " SELECT DISTINCT SU5.U5_FILIAL, SU5.U5_CODCONT FROM " +RetSqlName("SU5")+ " SU5 "+CRLF
			cQuery += " INNER JOIN " +RetSqlName("AC8")+" AC8 ON AC8.AC8_CODCON = SU5.U5_CODCONT AND AC8.D_E_L_E_T_ ='' "+CRLF
			cQuery += " WHERE SU5.D_E_L_E_T_='' AND SU5.U5_EMAIL <> '' AND SU5.U5_CODUSR = '" +  cCodUsr + "'"+ CRLF
		Else
			// Busca contatos relacionados com o representante utilizando a ADL.
			cQuery := " SELECT DISTINCT U5_FILIAL, U5_CODCONT FROM " +RetSqlName("ADL")+ " ADL "+CRLF
			cQuery += " INNER JOIN " +RetSqlName("AC8")+" AC8 ON ADL_ENTIDA = AC8_ENTIDA AND ADL_CODENT"+cOperConc+"ADL_LOJENT = AC8_CODENT "+CRLF
			cQuery += " AND AC8.D_E_L_E_T_='' "+CRLF
			cQuery += " INNER JOIN " +RetSqlName("SU5")+" SU5 ON AC8_CODCON = U5_CODCONT AND SU5.U5_EMAIL <> '' AND SU5.D_E_L_E_T_=''"+CRLF
			cQuery += " WHERE ADL.D_E_L_E_T_='' AND ADL.ADL_VEND = '" + cCodVend + "'" + CRLF
		EndIf
		cQuery := ChangeQuery(cQuery)
		
		TcQuery cQuery NEW ALIAS "TMP1" 
		
		While TMP1->(!Eof())
			Aadd(aContatos,{TMP1->U5_FILIAL, TMP1->U5_CODCONT})
			TMP1->(dbSkip())
		EndDo
				
	EndIf
	aRet := Ft321CriaCon(aContatos,aInfo, lAutomatico)
EndIf
	
Return (aRet)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft321ProcCon()
Processa contatos do representante.
 
@author Vendas CRM
@since 04/06/2013
/*/
//------------------------------------------------------------------------------------------------

Function Ft321ProcCon(aContSU5,aInfo, lAutomatico)

Local nX
Local nY
Local aInfoCont := aClone(aContSU5)
Local aAllCont  := {}
Local aEndereco := {}
Local aTelefone := {}
Local nPosCont
Local cUsuExc  := AllTrim(aInfo[2,1])
Local cSenExc  := AllTrim(aInfo[2,2])
Local aArea := GetArea()
Local aAreaSU5 := SU5->(GetArea())
Local aAreaAGA := AGA->(GetArea())
Local aAreaAGB := AGB->(GetArea())	
Local cRetorno
Local lRetCont := {}
Local aRet := {.T., ""}
         
Default lAutomatico := .F.         
                                                                                       
DbSelectArea("SU5")
DbSetOrder(1) //U5_FILIAL, U5_CODCONT

DbSelectArea("AGA")
DbSetOrder(3)	//AGA_FILIAL, AGA_ENTIDA, AGA_CODENT, AGA_PADRAO	

If SU5->(FieldPos("U5_IDEXC")) > 0 
	
	For nX := 1 to Len(aInfoCont)
	
		If SU5->(DbSeek(xFilial("SU5")+aInfoCont[nX,2]))
				lRetCont := EX07_Cont4(cUsuExc, cSenExc)
				
				If !lRetCont[1]
					aRet := FT321IntegrationInformation(STR0001,lRetCont[2], lAutomatico) //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
					Return aRet
				ElseIf lRetCont != Nil .And. !lRetCont[1]
					aRet := FT321IntegrationInformation(STR0002,lRetCont[2], lAutomatico)  //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
					Return aRet
				EndIf
				
				
				aAllCont := lRetCont[3]
		   		nPosCont := aScan(aAllCont,{|x|AllTrim(x[1]) == AllTrim(aInfoCont[nX][9])}) //procura o contato do protheus na lista do outlook
			
			// Caso os contatos do protheus não seja encontrado na lista do outlook, será feita sua inclusao no outlook. 
			//Onde serao gravados dos id's de controle na função Ft321GIdCon.
			If nPosCont == 0 // se nao encontrar o contato do protheus no outlook, inclui ele pelo exchange
				lRetCont := EX07_Cont1(cUsuExc,cSenExc,AllTrim(aInfoCont[nX,3]),AllTrim(aInfoCont[nX,5]),aInfoCont[nX,4],;
								aInfoCont[nX,6],AllTrim(aInfoCont[nX,7]),AllTrim(aInfoCont[nX,8]),aInfoCont[nX,2])	
								
				If !lRetCont[1]
					aRet := FT321IntegrationInformation(STR0003,lRetCont[2], lAutomatico) //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
					Return aRet
				ElseIf lRetCont != Nil .And. !lRetCont[1]
					aRet := FT321IntegrationInformation(STR0004,lRetCont[2], lAutomatico)  //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
					Return aRet
				EndIf				
		    Else
		   		
				// Se Id Outlook for igual do Protheus chamar funcao de alteracao no outlook passando aInfoConf
				// Receber changekey novo e grava-lo na SU5
				If nPosCont > 0
					If AllTrim(aAllCont[nPosCont,1]) == AllTrim(aInfoCont[nX][9]) .AND. AllTrim(aAllCont[nPosCont,2]) == AllTrim(aInfoCont[nX][10])
		            	lRetCont := EX07_Cont2(cUsuExc,cSenExc,SU5->U5_IDEXC,SU5->U5_CHGKEY,AllTrim(aInfoCont[nX,3]),;
		            	AllTrim(aInfoCont[nX,5]),aInfoCont[nX,4],aInfoCont[nX,6],AllTrim(aInfoCont[nX,7]),;
		            	AllTrim(aInfoCont[nX,8]),aInfoCont[nX,2])
		            	
			          If !lRetCont[1]
							aRet := FT321IntegrationInformation(STR0005,lRetCont[2], lAutomatico) //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
							Return aRet
						ElseIf lRetCont != Nil .And. !lRetCont[1]
							aRet := FT321IntegrationInformation(STR0006,lRetCont[2], lAutomatico)  //"Não foi possível efetuar a integração com exchange, tente novamente mais tarde ou se o problema persistir, contate o administrador do sistema!"
							Return aRet
						EndIf	
	            	
			   		Else
						If SU5->(DbSeek(xFilial("SU5")+SU5->U5_CODCONT))
						   RecLock("SU5",.F.)
								SU5->U5_IDEXC   := aAllCont[nPosCont,1]
								SU5->U5_CHGKEY  := aAllCont[nPosCont,2]
								SU5->U5_CONTAT  := aAllCont[nPosCont,3]
								SU5->U5_FCOM1   := aAllCont[nPosCont,6]
								SU5->U5_EMAIL   := aAllCont[nPosCont,7]
								SU5->U5_END		:= aAllCont[nPosCont,8,5]
								SU5->U5_BAIRRO	:= aAllCont[nPosCont,8,4]
								SU5->U5_MUN		:= aAllCont[nPosCont,8,2]
								SU5->U5_EST		:= aAllCont[nPosCont,8,3]
						   SU5->(MsunLock())
						EndIf
						
				  		Ft321VldTel(aInfoCont,aAllCont,"1",nPosCont) // BusinessPhone
						Ft321VldTel(aInfoCont,aAllCont,"2",nPosCont) // HomePhone
						Ft321VldTel(aInfoCont,aAllCont,"3",nPosCont) // BusinessFax
						Ft321VldTel(aInfoCont,aAllCont,"4",nPosCont) // HomeFax
						Ft321VldTel(aInfoCont,aAllCont,"5",nPosCont) // MobilePhone
					    
					    For nY := 1 to Len(aAllCont[nPosCont,8])
					    	If !Ft321SemEnd(aAllCont[nPosCont,8])
		    
			                	If AGA->(DbSeek(xFilial("AGA")+"SU5"+Padr(SU5->U5_CODCONT, TamSX3("AGA_CODENT")[1])+"1"))
			                	   RecLock("AGA",.F.)
										AGA->AGA_END    := AllTrim(aAllCont[nPosCont,8,5])
										AGA->AGA_BAIRRO := AllTrim(aAllCont[nPosCont,8,2])
										AGA->AGA_MUNDES := AllTrim(aAllCont[nPosCont,8,4])
										AGA->AGA_EST    := AllTrim(aAllCont[nPosCont,8,3])                	   
			                	   AGA->(MsUnlock())
			                	Else
			                		RecLock("AGA",.T.)
			                			AGA->AGA_FILIAL := xFilial("AGB")
										AGA->AGA_CODENT := GetSx8Num("AGA","AGA_CODIGO")
										AGA->AGA_TIPO   := "1"
										AGA->AGA_PADRAO := "1"
										AGA->AGA_END    := AllTrim(aAllCont[nPosCont,8,5])
										AGA->AGA_BAIRRO := AllTrim(aAllCont[nPosCont,8,2])
										AGA->AGA_MUNDES := AllTrim(aAllCont[nPosCont,8,4])
										AGA->AGA_EST    := AllTrim(aAllCont[nPosCont,8,3])
			                		AGA->(MsUnlock())
			                		ConfirmSX8()
			                		EndIf
			                Else
								If AGA->(DbSeek(xFilial("AGA")+"SU5"+Padr(SU5->U5_CODCONT, TamSX3("AGA_CODENT")[1])+"1"))    
						    		Reclock("AGA",.F.)
						 	   		AGA->(DbDelete())
							   		AGA->(MsUnlock())
							   		Reclock("SU5",.F.)
							   		SU5->U5_END		:= ""
									SU5->U5_BAIRRO	:= ""
									SU5->U5_MUN		:= ""
									SU5->U5_CEP		:= ""
							   		SU5->(MsUnlock())
							    EndIf
			                EndIf  
					    Next nY    
		
						EndIf
			   		EndIf
			   	EndIF
		EndIf
	        	
	Next nX
	
	RestArea(aAreaSU5)
	RestArea(aAreaAGA)
	RestArea(aAreaAGB)
	RestArea(aArea)

EndIf
	
Return aRet

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft321GIdCon()
Realiza a gravação do id exchange no contato do Protheus.

@author Vendas CRM
@since 04/06/2013
/*/
//------------------------------------------------------------------------------------------------

Function Ft321GIdCon(cIDContact, cChangeKeyContact, cCodContato)

Local aArea := GetArea()
Local aAreaSU5 := SU5->(GetArea())

DbSelectArea("SU5")
DbSetOrder(1) //U5_FILIAL, U5_CODCONT
If SU5->(FieldPos("U5_IDEXC")) > 0 
	
	If DbSeek(xFilial("SU5")+cCodContato)
		RecLock("SU5",.F.)
			SU5->U5_IDEXC  := cIDContact
			SU5->U5_CHGKEY := cChangeKeyContact
		MsunLock()
	EndIf
	
	RestArea(aAreaSU5)
	RestArea(aArea)
EndIf

Return

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft321CriaCon()
Cria um array com relação dos contatos a serem sincronizados com o exchange.
 
@return aContSU5 Array com relação de contatos para realizar sincronização.
@author Vendas CRM
@since 04/06/2013
/*/
//------------------------------------------------------------------------------------------------

Function Ft321CriaCon(aContatos, aInfo, lAutomatico)
       
Local nX
Local aContSU5  := {}
Local aEndereco := {}
Local aTelefone := {}
Local aArea := GetArea()
Local aAreaSU5 := SU5->(GetArea())
Local aAreaSUM := SUM->(GetArea())
Local aAreaSX5 := SX5->(GetArea())
Local aAreaAGA := AGA->(GetArea())
Local aAreaAGB := AGB->(GetArea())
Local cCargo			:= ""
Local cTratamento 	:= ""
Local aRet := {.F., ""}

DbSelectArea("SU5")
DbSetOrder(1) //U5_FILIAL, U5_CODCONT

DbSelectArea("SUM")
DbSetOrder(1)	// UM_FILIAL, UM_CARGO

DbSelectArea("SX5")
DbSetOrder(1)	// X5_FILIAL, X5_TABELA

If SU5->(FieldPos("U5_IDEXC")) > 0 
	
	For nX := 1 to Len(aContatos)
		
		If SU5->(DbSeek(xFilial("SU5")+aContatos[nX,2]))

			If SUM->(DbSeek(xFilial("SUM")+SU5->U5_FUNCAO))
				cCargo := SUM->UM_DESC
			EndIf

			If SX5->(DbSeek(xFilial("SX5")+"AX"+SU5->U5_TRATA))
				cTratamento := SX5->X5_DESCRI
			EndIf	
					
			aEndereco := Ft321BusEnd(SU5->U5_CODCONT)
			aTelefone := Ft321BusTel(SU5->U5_CODCONT)
			
			Aadd(aContSU5,{SU5->U5_FILIAL,SU5->U5_CODCONT,SU5->U5_CONTAT,aEndereco,SU5->U5_EMAIL,;
				aTelefone, cCargo  ,cTratamento,SU5->U5_IDEXC,SU5->U5_CHGKEY})
			
		EndIf
	
	Next nX	
	
	RestArea(aAreaSU5)
	RestArea(aAreaSUM)
	RestArea(aAreaSX5)
	RestArea(aAreaAGA)
	RestArea(aAreaAGB)
	RestArea(aArea)
	
	aRet := Ft321ProcCon(aContSU5, aInfo, lAutomatico)

EndIf

Return (aRet)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft321BusEnd()
Busca os endereços do contato.
 
@return aEndereco Array com endereços do contato. 
@author Vendas CRM
@since 04/06/2013
/*/
//------------------------------------------------------------------------------------------------

Function Ft321BusEnd(cContato)

Local aEndereco := {}
Local aArea := GetArea()
Local aAreaAGA := AGA->(GetArea())

DbSelectArea("AGA")
DbSetOrder(3)	//AGA_FILIAL, AGA_ENTIDA, AGA_CODENT, AGA_PADRAO

If DbSeek(xFilial("AGA")+"SU5"+Padr(cContato, TamSX3("AGA_CODENT")[1])+"1")

   While xFilial("AGA") == AGA->AGA_FILIAL .AND. AllTrim(AGA_CODENT) == SU5->U5_CODCONT .AND. AGA->AGA_PADRAO == '1'
    	Aadd(aEndereco,{AGA_TIPO,AGA_END,AGA_BAIRRO,AGA_MUNDES, AGA_EST})
   AGA->(DbSkip())
   EndDo

EndIf

RestArea(aAreaAGA)
RestArea(aArea)

Return (aEndereco)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft321BusTel()
Busca os telefones do contato.

@return aTelefone Array com telefones do contato.
@author Vendas CRM
@since 04/06/2013
/*/
//------------------------------------------------------------------------------------------------
                 
Function Ft321BusTel(cContato)

Local aTelefone := {}
Local aArea := GetArea()
Local aAreaAGB := AGB->(GetArea())

DbSelectArea("AGB")
DbSetOrder(3)	//AGB_FILIAL, AGB_ENTIDA, AGB_CODENT, AGB_PADRAO

If DbSeek(xFilial("AGB")+"SU5"+Padr(cContato, TamSX3("AGB_CODENT")[1])+"1")

	While xFilial("AGB") == AGB->AGB_FILIAL .AND. AllTrim(AGB_ENTIDA) == "SU5";
	 .AND. AllTrim(AGB->AGB_CODENT) == cContato .AND. AGB->AGB_PADRAO = '1'
		Aadd(aTelefone,{AGB->AGB_TIPO,AGB->AGB_TELEFO})
	AGB->(DbSkip())
	EndDo

EndIf

RestArea(aAreaAGB)
RestArea(aArea)

Return (aTelefone)

//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft321SemEnd()
Valida se o contato possui endereços.

@return lRet caso o retorno seja .T. o contato não tem endereço.
@author Vendas CRM
@since 04/06/2013
/*/
//------------------------------------------------------------------------------------------------

Function Ft321SemEnd(aEndereco)

Local nX
Local lRet := .T.
Default aEndereco := {}

	If !FT321ValEnd(aEndereco,2) .OR.!FT321ValEnd(aEndereco,3) .OR. !FT321ValEnd(aEndereco,4) .OR. !FT321ValEnd(aEndereco,5) .OR.;
		!FT321ValEnd(aEndereco,7) .OR.!FT321ValEnd(aEndereco,8) .OR. !FT321ValEnd(aEndereco,9) .OR. !FT321ValEnd(aEndereco,10) 
	    	lRet := .F.
	EndIf
	
Return lRet    



Function FT321ValEnd(aEndereco, nIndice)

Local lRet := .T.

If Len(aEndereco) >= nIndice
	lRet := Empty(aEndereco[nIndice])
EndIf

Return lRet


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} Ft321VldTel()
Valida, insere, altera ou exclui os tipos de telefones do contato.

@author Vendas CRM
@since 04/06/2013
/*/
//------------------------------------------------------------------------------------------------

Function Ft321VldTel(aInfoCont,aAllCont,cTipo,nPosCont)

Local cDescTipo := ""
Local nIndTipo
Local nIndTel
Local nX
Local aArea := GetArea()
Local aAreaAGB := AGB->(GetArea())
Local nPosBusPho := aScan(aAllCont[nPosCont,9],{|x|AllTrim(x) == "BusinessPhone"})
Local nPosHomePh := aScan(aAllCont[nPosCont,9],{|x|AllTrim(x) == "HomePhone"})
Local nPosBusFax := aScan(aAllCont[nPosCont,9],{|x|AllTrim(x) == "BusinessFax"})
Local nPosHomFax := aScan(aAllCont[nPosCont,9],{|x|AllTrim(x) == "HomeFax"})
Local nPosMobPho := aScan(aAllCont[nPosCont,9],{|x|AllTrim(x) == "MobilePhone"})

If cTipo == "1"
	cDescTipo := "BusinessPhone"
	nIndTipo  := nPosBusPho
	nIndTel   := nIndTipo+1
ElseIf cTipo == "2"
    cDescTipo := "HomePhone"
	nIndTipo  := nPosHomePh
	nIndTel   := nIndTipo+1   
ElseIf cTipo == "3"
    cDescTipo := "BusinessFax"
	nIndTipo  := nPosBusFax
	nIndTel   := nIndTipo+1
ElseIf cTipo == "4"
    cDescTipo := "HomeFax"
	nIndTipo  := nPosHomFax
	nIndTel   := nIndTipo+1
ElseIf cTipo == "5"
    cDescTipo := "MobilePhone"
	nIndTipo  := nPosMobPho
	nIndTel   := nIndTipo+1
EndIf

If nIndTipo > 0

	If !Empty(aAllCont[nPosCont,9,nIndTel])
		DbSelectArea("AGB")
		DbSetOrder(1)	//AGB_FILIAL, AGB_ENTIDA, AGB_CODENT, AGB_TIPO
		If DbSeek(xFilial("AGB")+"SU5"+Padr(SU5->U5_CODCONT, TamSX3("AGB_CODENT")[1])+cTipo)
			RecLock("AGB",.F.)
			If Upper(aAllCont[nPosCont,9,nIndTipo]) == Upper(cDescTipo)
				AGB->AGB_TELEFO := AllTrim(aAllCont[nPosCont,9,nIndTel])
				AGB->AGB_TIPO   := cTipo
				AGB->AGB_PADRAO := "1"
			EndIf
			AGB->(MsUnlock())
		Else
			RecLock("AGB",.T.)
			AGB->AGB_FILIAL	:= xFilial("AGB")
			AGB->AGB_CODIGO := GetSx8Num("AGB","AGB_CODIGO")
			AGB->AGB_ENTIDA := "SU5"
			AGB->AGB_CODENT := SU5->U5_CODCONT
			AGB->AGB_TIPO   := cTipo
			AGB->AGB_PADRAO := "1"
			AGB->AGB_TELEFO := AllTrim(aAllCont[nPosCont,9,nIndTel])
			AGB->(MsUnlock())
			ConfirmSX8()
		EndIf
	Else
			DbSelectArea("AGB")
			DbSetOrder(1)
			If DbSeek(xFilial("AGB")+"SU5"+Padr(SU5->U5_CODCONT, TamSX3("AGA_CODENT")[1])+cTipo)
				Reclock("AGB",.F.)
				AGB->(DbDelete())
				AGB->(MsUnlock())
				Reclock("SU5",.F.)
			  
				SU5->U5_FCOM1	:= ""
				SU5->U5_FCOM2   := ""
				SU5->U5_FONE    := ""
				SU5->U5_CELULAR := ""
				SU5->U5_FAX     := ""
				SU5->(MsUnlock())		
	        EndIf
	EndIf
	
EndIf

RestArea(aAreaAGB)
RestArea(aArea)
Return