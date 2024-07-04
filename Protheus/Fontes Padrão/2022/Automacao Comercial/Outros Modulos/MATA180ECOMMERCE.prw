#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA180.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} MATA180ECOMMERCE
Classe para integração do MATA180 com o E-Commerce
 
@author Juliane Venteu
@since 02/02/2017
@version P12.1.17
 
/*/
CLASS MATA180ECOMMERCE FROM FWModelEvent
	
	DATA cIDSB5
		
	METHOD New() CONSTRUCTOR
	
	METHOD After()
	METHOD InTTS()
	METHOD ModelPosVld()
	
ENDCLASS

//-----------------------------------------------------------------
METHOD New(cID) CLASS MATA180ECOMMERCE
	
	Default cID := "SB5MASTER"
	
	self:cIDSB5 := cID
	
Return Nil

//-----------------------------------------------------------------
METHOD After(oSubModel, cID, cAlias, lNewRecord) CLASS MATA180ECOMMERCE

	Local lECCia := SuperGetMV("MV_LJECOMO",,.F.) //E-commerce ciashop
	Local nOpc 	 := oSubModel:GetOperation()
 	
	If cID == self:cIDSB5
		If nOpc <> MODEL_OPERATION_DELETE	//-- Inclusao e alteracao
			If !Empty(M->B5_ECFLAG)
				SB5->B5_ECDTEX := " "
				
				If lECCia .AND. SB5->(FieldPos("B5_ECDTEX2")) > 0					
					SB5->B5_ECDTEX2 := ""				 
				EndIf
			EndIf
		Else	//-- Exclusao
	    	SB5->B5_ECDTEX := " "   //Registro vem travado.
	    	
	    	If lECCia .AND. SB5->(FieldPos("B5_ECDTEX2")) > 0
				SB5->B5_ECDTEX2 := ""				 
			EndIf
		EndIf
	EndIf
	
Return Nil

//-----------------------------------------------------------------
METHOD InTTS(oModel, cID) CLASS MATA180ECOMMERCE

	Local nOpc 		  := oModel:GetOperation()	
	Local cCodigo     := ""            //Codigo raiz para obter todos os produtos da grade dos produtos filhos ou o codigo do produto simples.
	Local nRegOld     := 0             //Salvar o registro atual da tabela SMO  
	Local aMascRaiz   := &("{"+SuperGetMV("MV_MASCGRD",,"11,2,2")+"}")  //Cria vetor com os dados da Mascara da grade        
	Local nTamProd    := SB1->(TamSx3("B1_COD")[1]) // Tamanho do código do Produto
	Local oView  	  := FWViewActive()
	Local lUI 		  := oView <> Nil   
	Local lContinua   := .T.
	Local aArea       := GetArea()
	Local aAreaSB0    := SB0->(GetArea())
	Local aAreaSB1    := SB1->(GetArea())
	Local aAreaSM0    := SM0->(GetArea())
	
	//Inclusao ou alteração
	If nOpc <> MODEL_OPERATION_DELETE
	
		If !Empty(M->B5_ECFLAG)
			SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
			SB1->(dbSeek(xFilial("SB1")+SB5->B5_COD))

			If ( nOpc == MODEL_OPERATION_INSERT  ) .And. !Empty(SB1->B1_PRODPAI) 
			    
			    If lUI
			    	lContinua := MsgNoYes(STR0027 + RTrim(RetTitle("B5_ECFLAG")) +  STR0028 )  //"Deseja atualizar com o conteúdo do campo "#" para seus produtos-filhos que não possuam essa informação?" 
			    EndIf
			    		    			
				If lContinua
					cCodigo  := SB5->(Left(B5_COD,aMascRaiz[1])) //Obtem a raiz do produto sem a variacao da grade.
					nTamProd := aMascRaiz[1]

					SB0->(dbSetOrder(1)) //B0_FILIAL+B0_COD				
					SB1->(dbSeek(xFilial("SB1")+cCodigo))
					
					While SB1->(!EOF() .And. B1_FILIAL == xFilial("SB1")) .AND. SB1->B1_GRADE == "S" .AND. AllTrim(SB1->B1_PRODPAI) == AllTrim(SB5->B5_COD) 
						
						If SB0->( dbSeek(xFilial("SB0")+SB1->B1_COD) )
							RecLock("SB0", .F.)
						Else
							RecLock("SB0", .T.)
							
							SB0->B0_FILIAL := xFilial("SB0")
							SB0->B0_COD    := SB1->B1_COD
						EndIf
					
						If Empty(SB0->B0_ECFLAG)
							SB0->B0_ECFLAG := SB5->B5_ECFLAG						
						EndIf
						SB0->( MsUnLock() )
						
						SB1->( DbSkip() )
					End					
				EndIf
			EndIf			
		EndIf
	
		If cID == "MATA180"
			MT180ECEAI()
		EndIf
	EndIf

	RestArea(aAreaSM0)
	RestArea(aAreaSB1)
	RestArea(aAreaSB0)
	RestArea(aArea)
	
Return Nil

//-----------------------------------------------------------------
METHOD ModelPosVld(oModel) CLASS MATA180ECOMMERCE

	Local nA        := 0
	Local cCmpObrig := ""
	Local aCampos   := {}
	Local lEcCia 	:= SuperGetMv("MV_LJECOMO",, .F.)
	Local lRet   	:= .T.
	Local nOpc 		:= oModel:GetOperation()
	Local aLocais   := {}
	Local aProdutos := {}
	Local nRegOld   := 0
	Local cCodigo	:= ""
	Local cMensagem	:= ""
	Local aArea     := GetArea()
	Local aAreaSB1  := SB1->(GetArea())
	Local aAreaSB2  := SB2->(GetArea())
	Local aAreaSL2  := SL2->(GetArea())
	Local aAreaMF6  := MF6->(GetArea())
	Local aAreaSM0  := SM0->(GetArea())
	Local lMSUProd  := FWHasEAI( "MATA010", .T., .F., .T. )
	
	If nOpc == MODEL_OPERATION_UPDATE .Or. nOpc == MODEL_OPERATION_INSERT
		If !lEcCia
			aadd( aCampos, { "B5_PESO"   , {|| (M->B5_PESO > 0)    } } )
			
			If SB5->(ColumnPos("B5_ECFLAG")) > 0
				aadd( aCampos, { "B5_ECFLAG ", {|| !( Empty(M->B5_ECFLAG)  ) } } )
			EndIf
			If SB5->(ColumnPos("B5_ECPESOE")) > 0 
				aadd( aCampos, { "B5_ECPESOE", {|| (M->B5_ECPESOE > 0) } } )
			EndIf
			If SB5->(ColumnPos("B5_ECQTMAX")) > 0
				aadd( aCampos, { "B5_ECQTMAX", {|| (M->B5_ECQTMAX > 0) } } )
			EndIf
			If SB5->(ColumnPos("B5_ECTIPOP")) > 0	
				aadd( aCampos, { "B5_ECTIPOP", {|| !( Empty(M->B5_ECTIPOP) ) } } )
			EndIf
			If SB5->(ColumnPos("B5_ECPRESE")) > 0
				aadd( aCampos, { "B5_ECPRESE", {|| !( Empty(M->B5_ECPRESE) ) } } )
			EndIf	
		ElseIf (SB5->(ColumnPos("B5_ECFLAG")) > 0 .And. (M->B5_ECFLAG == "1")     ) 
	
			If lMSUProd 
				aadd( aCampos, { "B5_ECCUBAG"   , {|| (M->B5_ECCUBAG > 0)    } } ) 
			Else
				aadd( aCampos, { "B5_PESO"   , {|| (M->B5_PESO > 0)    } } )
			EndIf
			 
			If SB5->(ColumnPos("B5_ECDESCR")) > 0
				aadd( aCampos, { "B5_ECDESCR", {|| !( Empty(M->B5_ECDESCR) ) } } )
			EndIf
			If SB5->(ColumnPos("B5_ECTITU")) > 0
				aadd( aCampos, { "B5_ECTITU", {|| !( Empty(M->B5_ECTITU) ) } } )
			EndIf	
			If SB5->(FieldPos("B5_ECCOMP") > 0   .AND. SB5->(FieldPos("B5_ECLARGU")) > 0)
				aadd( aCampos, { "B5_ECLARGU", {|| !( M->B5_ECLARGU = 0  .AND. M->B5_ECCOMP+M->B5_ECPROFU > 0  ) } } )	
				aadd( aCampos, { "B5_ECCOMP", {|| !( M->B5_ECCOMP = 0 .AND. M->B5_ECLARGU+M->B5_ECPROFU > 0 ) } } )	
				aadd( aCampos, { "B5_ECPROFU", {|| !( M->B5_ECPROFU = 0 .AND. M->B5_ECCOMP+M->B5_ECLARGU > 0 ) } } )
			EndIf
	
		EndIf
		
		For nA := 1 to Len(aCampos)
			If !Eval(aCampos[nA,2])
				If !Empty(cCmpObrig)
					cCmpObrig += ","
				EndIf
				cCmpObrig += "[" + Alltrim(RetTitle(aCampos[nA,1])) + "]"  //Obtem o titulo de tela do campo para facilitar para o usuario
			EndIf
		Next nA
				
		If !Empty(cCmpObrig) .And. lEcCia
			lRet := .F.
			Help("", 1, "OBRIGAT", , STR0024 + CRLF + cCmpObrig, 3, 1) //"Os seguintes campos devem ser preenchidos para o funcionamento do e-commerce: "
		Endif
		
	ElseIf nOpc == MODEL_OPERATION_DELETE

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Caso nao seja e-commerce, nao ira validar.                   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SB5->( FieldPos("B5_ECFLAG") ) > 0 .And. !Empty(SB5->B5_ECFLAG)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Obtem os Armazens do e-commerce para verificar estoque.      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MF6->(dbSetOrder(1)) //MF6_FILIAL+MF6_CEPDE+MF6_CEPATE
			MF6->(dbGoTop())
			While MF6->( !Eof() )
				aAdd(aLocais, {MF6->MF6_XFILIA, MF6->MF6_LOCAL})
				MF6->( DbSkip() )
			End
			
			// Obtem o codigo raiz do produto de grade ou codigo do produto normal.      
			SB1->( dbSetOrder(1) ) //B1_FILIAL+B1_COD
			SB1->( dbSeek( xFilial("SB1") + oModel:GetValue(self:cIDSB5, "B5_COD") ) )
			If Empty(SB1->B1_PRODPAI)
			    cCodigo := SB1->B1_COD
			Else
				cCodigo := SB1->(Left(B1_PRODPAI,Len(Alltrim(B1_PRODPAI))-4)) //Obtem a raiz do produto sem a variacao da grade.
			EndIf
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica o estoque e-commerce do Produto Pai e dos produtos filhos        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SB1->(dbSeek(xFilial("SB1")+cCodigo))
			While SB1->(!EOF() .And. B1_FILIAL == xFilial("SB1") .And. Left(B1_COD,Len(cCodigo)) == cCodigo)
			   If SB1->B1_GRADE == "S" .AND.  AllTrim(SB1->B1_PRODPAI) == AllTrim(SB5->B5_COD)
			   
				    For nA := 1 to Len(aLocais)
						SB2->(dbSetOrder(1)) //B2_FILIAL+B2_COD+B2_LOCAL
						SB2->(dbSeek(aLocais[nA,1]+SB1->B1_COD+aLocais[nA,2]))
						If SB2->B2_QATU > 0
							aAdd(aProdutos, {SB2->B2_COD, SB2->B2_FILIAL, SB2->B2_LOCAL})
						EndIf
					Next nA
				EndIf
		
				SB1->(dbSkip())
			End
		
			If Len(aProdutos) > 0
				lRet := .F.
		
				cMensagem := STR0015+CRLF   //"Abaixo produtos e armazens que contem estoque e-commerce, invalidando "
				cMensagem += STR0016+CRLF   //"a exclusao deste complemento:"
				For nA := 1 to Len(aProdutos)
					cMensagem += Space(3) +STR0017 +aProdutos[nA,1] +STR0018 +aProdutos[nA,2] +STR0019 +aProdutos[nA,3]+CRLF  //"Produto: "##" Filial: "##" Armazém: "
				Next nA
				
				Help(" ",1,cMensagem)		
			EndIf
		
			If lRet
				SB1->(dbSeek(xFilial("SB1")+cCodigo))
				While SB1->(!EOF() .And. B1_FILIAL == xFilial("SB1") .And. Left(B1_COD,Len(cCodigo)) == cCodigo)
				
					If SB1->B1_GRADE == "S" .AND.  AllTrim(SB1->B1_PRODPAI) == AllTrim(SB5->B5_COD)
						//Quando for SB1 exclusivo
						If FWModeAccess("SB1",3) == "E"
							SB2->(dbSetOrder(1))
							SB2->(dbSeek(xFilial("SB2")+SB1->B1_COD))
							While SB2->(!EOF() .And. B2_FILIAL+B2_COD == xFilial("SB2")+SB1->B1_COD)
								If SB2->B2_QATU <> 0
									Help(" ",1,STR0017 +SB2->B2_COD +STR0020) //"Produto: "##" tem saldo!"								
									lRet := .F.
									Exit
								EndIf
								If Lj110SeekSD(xFilial("SB2")+SB2->B2_COD)
									Help(" ",1,STR0021 +SB2->B2_COD +STR0022) //"Este produto "##" não poderá ser excluído, verifique as notas de entradas, notas de saída e movimentações."							 
									lRet := .F.
									Exit
								EndIf
								SB2->(dbSkip())
							End
			
							SL2->(dbSetOrder(2))
							If SL2->(dbSeek(xFilial("SL2")+SB1->B1_COD))
								SL2->(dbSetOrder(1))
								Help(" ",1,"MA010_06")
								lRet := .F.
								Exit
							EndIf
							SL2->(dbSetOrder(1))
						Else
							nRegOld := SM0->(Recno())
			
							SM0->(dbGoTop())
							While !SM0->(EOF())
								SB2->(dbSetOrder(1))
								SB2->(dbSeek(xFilial("SB2",FWCodFil())+SB1->B1_COD))
								While SB2->(!EOF() .And. B2_FILIAL+B2_COD == xFilial("SB2",FWCodFil())+SB1->B1_COD)
									If SB2->B2_QATU <> 0
										Help(" ",1,STR0017 +SB2->B2_COD +STR0020) //"Produto: "##" tem saldo!"								
										lRet := .F.
										Exit
									EndIf
									If Lj110SeekSD(xFilial("SB2",FWCodFil())+SB2->B2_COD)
										Help(" ",1,STR0021 +SB2->B2_COD +STR0022) //"Este produto "##" não poderá ser excluído, verifique as notas de entradas, notas de saída e movimentações."								
										lRet := .F.
										Exit
									EndIf
									SB2->(dbSkip())
								End
								If !lRet
									Exit
								Endif
								SM0->(dbSkip())
							End
							SM0->(dbGoTo(nRegOld))
						Endif
					EndIf
					SB1->(dbSkip())
				End
			EndIf
		EndIf		
	EndIf
	
	RestArea(aAreaSM0)
	RestArea(aAreaMF6)
	RestArea(aAreaSL2)
	RestArea(aAreaSB2)
	RestArea(aAreaSB1)
	RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} MT180ECEAI
Função que dispara o Adapter de Produtos
@author  Varejo
@version 	P12.1.17
@since   	02/08/2018
@sample MT180ECEAI()
/*/
//-------------------------------------------------------------------
Function MT180ECEAI()

	Local cAdapter	:= "MATA010"
	Local lIntegDef	:= FWHasEAI(cAdapter,.T.,,.T.) 
	Local aRetInt	:= {}
	Local cMsgRet	:= ""
	
	If lIntegDef
		aRetInt := FwIntegDef(cAdapter,,,, cAdapter)
	
		If Valtype(aRetInt) == "A" .And. Len(aRetInt) == 2 .And. !aRetInt[1]
			If !Empty(AllTrim(aRetInt[2]))
				cMsgRet := AllTrim(aRetInt[2]) +chr(13)+chr(13)
			EndIf
			cMsgRet += "Mensage de Retorno EAI"
			Aviso("Falha no envio do Adapter EAI.",cMsgRet,{"Ok"},3)
			DisarmTransaction()
		EndIf
	EndIf

Return Nil