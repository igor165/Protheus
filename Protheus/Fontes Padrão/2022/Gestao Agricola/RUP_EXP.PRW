#Include 'Protheus.ch'
/*{Protheus.doc}
Função de compatibilização do release incremental.
Função chamada apartir da rotina RUP_AGR*/
Function RUP_EXP()

	//Realiza a chamada da função refente aos campos ( SX3 )
	FAtuTafSX3()
	
Return  Nil


/*/--------------------------------------------------------------------------------------------------/*/
Static Function FAtuTafSX3()

	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	if SX3->(dbSeek("NJ0_CGC"))
		RecLock("SX3")
		SX3->X3_TITSPA := 'RUC'
		MSUnlock("SX3")
	EndIf		

	DbSelectArea("SX3")
	SX3->(dbSetOrder(2))
	if SX3->(dbSeek("NJB_QTDPRO"))
		RecLock("SX3")
		SX3->X3_WHEN := ''
		MSUnlock("SX3")
	EndIf		

	AjustaSx3("NJK_FILIAL",  { { "X3_ORDEM", '01' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_CODROM",  { { "X3_ORDEM", '02' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_ITEM",    { { "X3_ORDEM", '03' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_TPCLAS",  { { "X3_ORDEM", '04' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_CODDES",  { { "X3_ORDEM", '05' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_DESDES",  { { "X3_ORDEM", '06' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_BASDES",  { { "X3_ORDEM", '07' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_OBRGT",   { { "X3_ORDEM", '08' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_PERDES",  { { "X3_ORDEM", '09' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_READES",  { { "X3_ORDEM", '10' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_QTDDES",  { { "X3_ORDEM", '11' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_DESRES",  { { "X3_ORDEM", '12' } }, { }, { }, {|| .T.} )
	AjustaSx3("NJK_RESINF",  { { "X3_ORDEM", '13' } }, { }, { }, {|| .T.} )

Return

//-------------------------------------------------------------------
/*{Protheus.doc}  AjustaSX3(cCampo, aCpoPor, aCpoSpa, aCpoEng, cCondicao)
Filtro 

@author Simone Mie Sato Kakinoana

@version P12
@since   27/03/2015
@return  Nil
@obs
*/
//-------------------------------------------------------------------
Static Function AjustaSx3(cCampo, aCpoPor, aCpoSpa, aCpoEng, cCondicao)

	Local aArea := GetArea(), nIndice, lCondicao

	If ValType(aCpoPor) = "C"        // A variavel pode ser passada tambem como string
		aCpoPor := { { "X3_CBOX", aCpoPor } }        // Pois eh convertida para matriz
		aCpoSpa := { { "X3_CBOXSPA", aCpoSpa } }
		aCpoEng := { { "X3_CBOXENG", aCpoEng } }
	Endif

	DbSelectArea("SX3")
	DbSetOrder(2)
	MsSeek(cCampo)

	If ValType(cCondicao) = "B"
		lCondicao := Eval(cCondicao)
	Else
		lCondicao := ! cCondicao $ AllTrim(&(aCpoPor[1][1]))
	Endif
	If Found() .And. lCondicao
		RecLock("SX3", .F.)
		For nIndice := 1 To Len(aCpoPor)
			Replace &(aCpoPor[nIndice][1]) With aCpoPor[nIndice][2]
		Next
		For nIndice := 1 To Len(aCpoSpa)
			Replace &(aCpoSpa[nIndice][1]) With aCpoSpa[nIndice][2]
		Next
		For nIndice := 1 To Len(aCpoEng)
			Replace &(aCpoEng[nIndice][1]) With aCpoEng[nIndice][2]
		Next
		SX3->(MsUnLock())
	Endif

	RestArea(aArea)

Return .T.

