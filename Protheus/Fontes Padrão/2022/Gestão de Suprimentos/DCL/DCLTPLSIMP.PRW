#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} DCLA010TOK()
Valida se os campos obrigatorios do SIMP estao preenchidos
Adaptação da função A010TOK
@author Itamar Oliveira
@since 18/01/2005
@version 1.0
/*/
//-------------------------------------------------------------------

Function DCLA010TOK(oModel)
Local lReturn	:= .T.
Local cMens	:= ""
Local cClTrib
Local cPrequi
Local cCodSimp
Local cTipConv
Local cSegUm
Local nConv
Local oModDH5
Local oModSB1
Local lUpd		 := .F.
Local lDH5Modify := .F.
Local nInd		 := 0
Local aFields	 := {}
Local lMvcMata010:= TableInDic( "G3Q", .F. ) .And. oModel <> NIL

If FindFunction("DclValidCp") .AND. .Not. DclValidCp()
	Return
EndIf

lCopia := IIf( Type( "lCopia" ) == "L", lCopia, .F. )

//Verificação em MVC
If lMvcMata010
	oModDH5		:= oModel:GetModel("DH5DETAIL")
	oModSB1		:= oModel:GetModel("SB1MASTER")

	oModel:Activate()
	cPrequi		:= oModDH5:GetValue("DH5_PREQUI")
	cClTrib		:= oModDH5:GetValue("DH5_CLTRIB")
	cCodSimp	:= oModDH5:GetValue("DH5_CODSIM")
	nConv		:= oModSB1:GetValue("B1_CONV")
	cTipConv	:= oModSB1:GetValue("B1_TIPCONV")
	cSegUm		:= oModSB1:GetValue("B1_SEGUM")
	lDH5Modify 	:= oModDH5:IsModified() .Or. lCopia
Else
	//Verificação para o dicionário antigo
	cPrequi		:= M->DH5_PREQUI
	cClTrib		:= M->DH5_CLTRIB
	cCodSimp	:= M->DH5_CODSIM
	nConv		:= M->B1_CONV
	cTipConv	:= M->B1_TIPCONV
	cSegUm		:= M->B1_SEGUM
	lDH5Modify	:= IsInCallStack( "A010INCPEC" ) .Or. IsInCallStack( "A010ALTPEC" )
EndIf

If lMvcMata010 //( lDH5Modify .And. !( lCopia ) ) .And. ( Empty(cClTrib) .Or. Empty(cPrequi) )
	If ( lDH5Modify )
		If !( lCopia )
			If Empty(cClTrib) .Or. Empty(cPrequi)
				cMens += "Campos obrigatórios não preenchidos. "
				Help(" ",1,"DCLA010TOK", ,cMens,1,0,,,,,,{"Verifique o valor dos campos Classif.Trib e Requisita na pasta Complemento DCL"})
				lReturn := .F.
			EndIf
			
			If lReturn .And. AllTrim(cCodSimp) <> ""
				If AllTrim(cSegUm) == "" .Or. nConv == 0 .Or. AllTrim(cTipConv) == ""
					cMens := "E obrigatorio o preenchimento dos campos Seg.Un.Medi., Fator Conv. e Tipo de Conv "
					cMens += "na pasta Cadastrais para o calculo do peso do produto em KG. Portanto a 2nd "
					cMens += "Unidade de Medida devera ser KG caso não use a terceira unidade de medida"
					Help(" ",1,"DCLA010NOK", ,cMens,1,0)
					lReturn:=.F.
				ElseIf AllTrim(cSegUm) != "KG"
					cMens := "A 2nd Unidade de Medida deve ser KG. Por favor, preencha corretamente o campo."
					Help(" ",1,"DCLA010TOK", ,cMens,1,0,,,,,,{"Verifique o valor dos campos Classif.Trib e Requisita na pasta Complemento DCL"})
					lReturn:=.F.
				Endif
			Endif
		Else
			aFields := oModDH5:GetStruct():GetFields()
			For nInd := 1 To Len( aFields )
				If !Empty( oModDH5:GetValue( aFields[ nInd ][ 3 ] ) )
					lUpd := .T.
					Exit
				EndIf
			Next nInd

			If lUpd
				If Empty(cClTrib) .Or. Empty(cPrequi)
					cMens += "Campos obrigatórios não preenchidos. "
					Help(" ",1,"DCLA010TOK", ,cMens,1,0,,,,,,{"Verifique o valor dos campos Classif.Trib e Requisita na pasta Complemento DCL"})
					lReturn := .F.
				EndIf
				
				If lReturn .And. AllTrim(cCodSimp) <> ""
					If AllTrim(cSegUm) == "" .Or. nConv == 0 .Or. AllTrim(cTipConv) == ""
						cMens := "E obrigatorio o preenchimento dos campos Seg.Un.Medi., Fator Conv. e Tipo de Conv "
						cMens += "na pasta Cadastrais para o calculo do peso do produto em KG. Portanto a 2nd "
						cMens += "Unidade de Medida devera ser KG caso não use a terceira unidade de medida"
						Help(" ",1,"DCLA010NOK", ,cMens,1,0)
						lReturn:=.F.
					ElseIf AllTrim(cSegUm) != "KG"
						cMens := "A 2nd Unidade de Medida deve ser KG. Por favor, preencha corretamente o campo."
						Help(" ",1,"DCLA010TOK", ,cMens,1,0,,,,,,{"Verifique o valor dos campos Classif.Trib e Requisita na pasta Complemento DCL"})
						lReturn:=.F.
					Endif
				Endif
			Endif
		EndIf

	EndIf
Else
	If Empty(cClTrib) .Or. Empty(cPrequi)
		cMens += "Campos obrigatórios não preenchidos. "
		Help(" ",1,"DCLA010TOK", ,cMens,1,0,,,,,,{"Verifique o valor dos campos Classif.Trib e Requisita na pasta Complemento DCL"})
		lReturn := .F.
	EndIf
	
	If lReturn .And. AllTrim(cCodSimp) <> ""
		If AllTrim(cSegUm) == "" .Or. nConv == 0 .Or. AllTrim(cTipConv) == ""
			cMens := "E obrigatorio o preenchimento dos campos Seg.Un.Medi., Fator Conv. e Tipo de Conv "
			cMens += "na pasta Cadastrais para o calculo do peso do produto em KG. Portanto a 2nd "
			cMens += "Unidade de Medida devera ser KG caso não use a terceira unidade de medida"
			Help(" ",1,"DCLA010NOK", ,cMens,1,0)
			lReturn:=.F.
		ElseIf AllTrim(cSegUm) != "KG"
			cMens := "A 2nd Unidade de Medida deve ser KG. Por favor, preencha corretamente o campo."
			Help(" ",1,"DCLA010TOK", ,cMens,1,0,,,,,,{"Verifique o valor dos campos Classif.Trib e Requisita na pasta Complemento DCL"})
			lReturn:=.F.
		Endif
	Endif
EndIf

Return lReturn
