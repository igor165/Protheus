// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 06    º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#Include "PROTHEUS.CH"
#INCLUDE "OFINJD17.CH"

#define STR0015 "Altera Senha"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ OFINJD17 º Autor ³ Rubens Takahashi    º Data ³ 14/05/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Registro de Produto - JD                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFINJD17()

Private aRotina   := MenuDef()
Private cCadastro := STR0001 // "Registro de Produtos"

mBrowse( 6, 1,22,75,"VMY",,,,,,OFNJD17LEG())

Return()


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFNJD17VIS  ³ Autor ³ Rubens Takahashi   ³ Data ³ 15/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualização do Registro                   			      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFNJD17VIS(cAlias,nReg,nOpc)

/////////////////////////////////////////
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )
/////////////////////////////////////////

AxVisual(cAlias,nReg,nOpc)

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFNJD17INC  ³ Autor ³ Rubens Takahashi   ³ Data ³ 15/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclusão do Registro                     			      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFNJD17INC(cAlias,nReg,nOpc)

/////////////////////////////////////////
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )
/////////////////////////////////////////

If !OFNJD17VALID()
	Return
EndIf

AxInclui(cAlias,nReg,nOpc,,,,/* cTudoOk */ )

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFNJD17ALT  ³ Autor ³ Rubens Takahashi   ³ Data ³ 15/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alteração do Registro                    			      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFNJD17ALT(cAlias,nReg,nOpc)

/////////////////////////////////////////
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )
/////////////////////////////////////////

If !OFNJD17VALID()
	Return
EndIf

If !Empty(VMY->VMY_DTTRAN)
	MsgAlert(STR0002) // "Registro já transmitido"
	Return
EndIf

AxAltera(cAlias,nReg,nOpc,,,,,/* cTudoOk */ )

Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFNJD17DEL  ³ Autor ³ Rubens Takahashi    ³ Data ³ 15/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Exclusão do registro                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFNJD17DEL(cAlias,nReg,nOpc)

/////////////////////////////////////////
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )
/////////////////////////////////////////

If !Empty(VMY->VMY_DTTRAN)
	MsgAlert(STR0002) // "Registro já transmitido"
	Return
EndIf

AxDeleta(cAlias,nReg,nOpc,,,,,, .T. /* lMaximized */ )

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFNJD17TRAN ³ Autor ³ Rubens Takahashi   ³ Data ³ 15/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Transmissão do registro para o WebService da John Deere    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFNJD17TRAN(cAlias,nReg,nOpc)

Local oWS

/////////////////////////////////////////
VISUALIZA := ( nOpc == 2 )
INCLUI 	  := ( nOpc == 3 )
ALTERA 	  := ( nOpc == 4 )
EXCLUI 	  := ( nOpc == 5 )
/////////////////////////////////////////

If !OFNJD17VALID()
	Return
EndIf

If !Empty(VMY->VMY_DTTRAN)
	MsgAlert(STR0002) // "Registro já transmitido"
	Return
EndIf

If !MsgYesNo(STR0014) // "Deseja transmitir registro do produto"
	Return
EndIf

VV1->(dbSetOrder(1))
VV1->(dbSeek(xFilial("VV1") + VMY->VMY_CHAINT ))

SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1") + VMY->VMY_CLIENT + VMY->VMY_LOJA ))

// Registra o produto para um determinado cliente
oWS := WSJohnDeere_Garantia():New("SubmitDeliveryReceipt")
oWS:oSubmitDeliveryReceipt_INPUT:cCUSTTYPE     := VMY->VMY_CTYPE
oWS:oSubmitDeliveryReceipt_INPUT:cDELIVERYDATE := DtoS(VMY->VMY_DTENTR)

oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cBUSIND        := VMY->VMY_BUSIND
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cFIRSTNM       := AllTrim(VMY->VMY_NOME)
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cMI            := AllTrim(VMY->VMY_MNOME)
If VMY->VMY_BUSIND == "I"
	oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cLASTNM        := AllTrim(VMY->VMY_SNOME)
Else
	oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cBUSNM         := AllTrim(VMY->VMY_SNOME)
EndIf
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cCONTACT       := AllTrim(VMY->VMY_CONTAT)
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cSTADDR1       := AllTrim(SA1->A1_END)
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cSTADDR2       := ""
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cCITY          := AllTrim(SA1->A1_MUN)
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cSTATE         := AllTrim(SA1->A1_EST)
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cCOUNTRY       := Iif(SA1->A1_PAIS == "105" , "BR" , "" )
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cPHONE         := AlLTrim(SA1->A1_DDD) + AllTrim(SA1->A1_TEL)
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cZIP           := AllTrim(SA1->A1_CEP)
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cEMAIL_ADDRESS := AllTrim(SA1->A1_EMAIL)
//oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cCKCCUSTID     :=
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cTAXID_TYPE    := IIf(SA1->A1_PESSOA == "F" , "CPF" , "CNPJ")
oWS:oSubmitDeliveryReceipt_INPUT:oCUSTOMER:cTAXID         := AllTrim(SA1->A1_CGC)

Do Case
Case VMY->VMY_STATUS == "1"
	oWS:oSubmitDeliveryReceipt_INPUT:oEQUIPMENT:cOWNERCODE   := "NEW"
Case VMY->VMY_STATUS == "2"
	oWS:oSubmitDeliveryReceipt_INPUT:oEQUIPMENT:cOWNERCODE   := "USED"
Case VMY->VMY_STATUS == "3"
	oWS:oSubmitDeliveryReceipt_INPUT:oEQUIPMENT:cOWNERCODE   := "RENTAL"
EndCase
oWS:oSubmitDeliveryReceipt_INPUT:oEQUIPMENT:cPIN             := AllTrim(VV1->VV1_CHASSI)
oWS:oSubmitDeliveryReceipt_INPUT:oEQUIPMENT:cMKTCODE         := VMY->VMY_MKTCOD
oWS:oSubmitDeliveryReceipt_INPUT:oEQUIPMENT:cEXPFIRSTUSEDATE := DtoS(VMY->VMY_DTFUSE)
//oWS:oSubmitDeliveryReceipt_INPUT:oEQUIPMENT:cLICENSE_PLATE   :=
//oWS:oSubmitDeliveryReceipt_INPUT:oEQUIPMENT:cOPE_MANUAL_ID   :=

nPos := oWS:oSubmitDeliveryReceipt_INPUT:AddMeasurement()
oWS:oSubmitDeliveryReceipt_INPUT:oMEASUREMENTS[nPos]:cUSEINDICATOR := VMY->VMY_UN1
oWS:oSubmitDeliveryReceipt_INPUT:oMEASUREMENTS[nPos]:cAMTUSE       := AllTrim(Str(VMY->VMY_USO1,22))

lProcessado:= .f.
MsgRun(STR0004,STR0003,{|| lProcessado := oWS:SubmitDeliveryReceipt() }) // "Registrando produto"
If !lProcessado
	oWS:ExibeErro()
	Return
EndIf

If oWS:oOUTPUT:oSUCCESS:cTYPE $ "E/X"
	MsgInfo(STR0005 + oWS:oOUTPUT:oSUCCESS:cTYPE + " - " + oWS:oOUTPUT:oSUCCESS:cRESDESC ) // "Erro: "
	Return
EndIf

//If oWS:oOUTPUT:oSUCCESS:cTYPE == "S"

If oWS:oOUTPUT:oDRSTATUS:cSTATUS == "C"

	dbSelectArea("VMY")
	Reclock("VMY",.f.)
	VMY->VMY_DTTRAN := dDataBase
	VMY->VMY_DRNO := oWS:oOUTPUT:oDELRECPT:nDRNO
	VMY->(MSUnlock())

EndIf

MsgInfo(oWS:oOUTPUT:oDRSTATUS:cMSG)


oWS := NIL
//

Return


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFNJD17VEIC ³ Autor ³ Rubens Takahashi   ³ Data ³ 15/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valid do campo de chassi                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFNJD17VLD(cReadVar)

Local cSlvAlias := Alias()

Local cFirstName := ""
Local cMidleName := ""
Local cLastName  := ""
//Local lProcCliente := .f.

Local nTamSNOME := TamSX3("VMY_SNOME")[1]
Local nTamNOME  := TamSX3("VMY_NOME")[1] 
Local nTamMNOME := TamSX3("VMY_MNOME")[1]

Default cReadVar := ReadVar()

If cReadVar == "M->VMY_BUSIND"
	If M->VMY_BUSIND == "I"
		M->VMY_MNOME := Space(TamSX3("VMY_MNOME")[1])
	EndIf
EndIf

//If cReadVar == "M->VMY_CLIENT"
//	SA1->(dbSetOrder(1))
//	If !Empty(M->VMY_LOJA) .and. SA1->(dbSeek( xFilial("SA1") + M->VMY_CLIENT + M->VMY_LOJA
//		If 
//
//If 

If cReadVar == "M->VMY_GETKEY"

	If Empty(M->VMY_GETKEY)
		Return(.t.)
	EndIf
	
	If !FG_POSVEI("M->VMY_GETKEY",)
		Return(.t.)
	EndIf
	
	M->VMY_GETKEY := VV1->VV1_CHASSI
	M->VMY_CHAINT := VV1->VV1_CHAINT
	
	If !Empty(VV1->VV1_PROATU)
	
		SA1->(dbSetOrder(1))
		If SA1->(dbSeek( xFilial("SA1") + VV1->VV1_PROATU + VV1->VV1_LJPATU ))
			M->VMY_CLIENT := VV1->VV1_PROATU
			M->VMY_LOJA := VV1->VV1_LJPATU
			
			
			//cAuxNome := AllTrim(Posicione("SA1",1,xFilial("SA1")+M->VMY_CLIENT+M->VMY_LOJA,"A1_NOME"))
			cAuxNome := AllTrim(SA1->A1_NOME)
				
			// Se for Individual
			If M->VMY_BUSIND == "I"
				// Retira o Sobrenome
				nPos := RAT(" ",cAuxNome)
				If nPos <> 0
					cLastName := Right(cAuxNome,Len(cAuxNome) - nPos)
					cAuxNome := AllTrim(Left(cAuxNome,nPos))
				EndIf
				// Retira o Primeiro Nome
				nPos := AT(" ",cAuxNome)
				If nPos == 0 .and. Len(cAuxNome) <> 0
					nPos := Len(cAuxNome)
				EndIf
				If nPos <> 0
					cFirstName := AllTrim(Left(cAuxNome,nPos))
					cAuxNome := AllTrim(SubStr(cAuxNome,Len(cFirstName)+1))
				EndIf
				// Retira Nome do meio
				If !Empty(cAuxNome)
					cMidleName := AllTrim(cAuxNome)
				EndIf
				//
			// Se for business
			Else
				cFirstName := cLastName := AllTrim(SA1->A1_NOME)
			EndIf
			
			// M->VMY_SNOME := IIF( !Empty(cLastName)  , PadR(cLastName ,nTamSNOME) , Space(nTamSNOME) )
			// M->VMY_NOME  := IIF( !Empty(cFirstName) , PadR(cFirstName,nTamNOME ) , Space(nTamNOME ) )
			// M->VMY_MNOME := IIF( !Empty(cMidleName) , PadR(cMidleName,nTamMNOME) , Space(nTamMNOME) )
			M->VMY_SNOME := PadR(cLastName ,nTamSNOME)
			M->VMY_NOME  := PadR(cFirstName,nTamNOME )
			M->VMY_MNOME := PadR(cMidleName,nTamMNOME)
		
		EndIf
	EndIf
	
EndIf

dbSelectArea(cSlvAlias)

Return(.t.)

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFNJD17LEG  ³ Autor ³ Rubens Takahashi   ³ Data ³ 15/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Legenda                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFNJD17LEG(nReg)

Local uRetorno  := .t.
Local aLegenda  := {{ 'BR_VERDE' , STR0005 } ,; // "Não Transmitido"
					{ 'BR_AZUL'  , STR0006 } }  // "Transmitido"

If nReg == NIL 	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	AADD(uRetorno , { 'Empty(VMY->VMY_DTTRAN)', aLegenda[1,1] , aLegenda[1,2]} ) // "Não Transmitido"
	AADD(uRetorno , { '!Empty(VMY->VMY_DTTRAN)' , aLegenda[2,1] , aLegenda[2,2]} ) // "Transmitido"
Else
	BrwLegenda(cCadastro,STR0007,aLegenda) //Legenda
EndIf

Return uRetorno


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MenuDef  ³ Autor ³ Rubens Takahashi      ³ Data ³ 15/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tratamento do menu aRotina							      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {}
aRotina := {	{ STR0008 , "AxPesqui"    , 0 , 1 },;			// Pesquisar
					{ STR0009 , "OFNJD17VIS"  , 0 , 2 },;			// Vizualizar
					{ STR0010 , "OFNJD17INC"  , 0 , 3 },;			// Incluir
					{ STR0011 , "OFNJD17ALT"  , 0 , 4 },;			// Alterar
					{ STR0012 , "OFNJD17DEL"  , 0 , 5 },;			// Excluir
					{ STR0013 , "OFNJD17TRAN" , 0 , 6 },;			// Transmitir
					{ STR0015 , "OFNJD15PW"   , 0 , 3 },;			// Altera Senha
					{ STR0007 , "OFNJD17LEG"  , 0 , 4 ,2,.f. } }	// Legenda
Return aRotina


/*/{Protheus.doc} OFNJD17VALID

Função responsável por permitir o envio de um registro de produto através Web Service.
Validação é necessária pois a rotina será descontinuada pela John Deere

@author Rubens
@since 08/06/2015
@version 1.0
@return logico, Indica se é possível registrar equipamento através do Web Service

/*/
Static Function OFNJD17VALID()
// Projeto Piloto com a D Carvalho
If AllTrim(GetNewPar("MV_MIL0005")) $ "201068/201124/201301/201319/201362/201390"
	If Date() >= CtoD("17/08/2015")
		MsgStop("A pedido da John Deere, a rotina de registro de produto deverá ser realizada através do DCP(Dealer Communication Platform)." + chr(13) + chr(10) + "Dúvidas entrar em contato com a John Deere")
		Return .f.
	ElseIf Date() >= CtoD("27/07/2015")
		MsgInfo("A pedido da John Deere, a rotina de registro de produto será desativada a partir do dia 17/08/2015.")
	EndIf
EndIf
Return .t.