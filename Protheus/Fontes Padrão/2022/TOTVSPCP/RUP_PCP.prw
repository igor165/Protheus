
/*
@param  cVersion   - Versão do Protheus
@param  cMode      - Modo de execução. 1=Por grupo de empresas / 2=Por grupo de empresas + filial (filial completa)
@param  cRelStart  - Release de partida  Ex: 002
@param  cRelFinish - Release de chegada Ex: 005
@param  cLocaliz   - Localização (país). Ex: BRA
*/

Function RUP_PCP(cVersion, cMode, cRelStart, cRelFinish, cLocaliz )
	Local iSFC     := 0
	Local nTamanho := 0
	Local cChave   := ""

	#IFDEF TOP
		If cVersion >= "12"
			IF cMode == "1"  //1=Por grupo de empresas
				TitLocais() //Ajusta título dos campos de armazém de estoque
				foldersSVK() // Apaga os folder e agrupamentos da tabela SVK
			EndIf
			IF cRelStart <= "007" .And. cRelFinish >= "007"

				If cMode == "1"
					// Correção de campo
					AjustaSX3()				
					//Correção dos campos do MRP Multi-empresa
					SX3MrpME()
				EndIf

				If cMode == "2"  //2=Por grupo de empresas + filial (filial completa)			
					//Carga de dados referente ao projeto Operações X Componentes
					OperXComp()				
				Endif
			EndIf
			If cRelStart >= "017" .And. cMode == "1"  //1=Por grupo de empresas
				//Exclui relacionamento da SC2 com a SG2.
				dbSelectArea("SX9")
				SX9->(dbSetOrder(2))
				nTamanho := Len(SX9->X9_DOM)
				cChave   := PadR("SC2",nTamanho)+PadR("SG2",nTamanho)
				If SX9->(dbSeek(cChave))
					While SX9->(!Eof()) .And. SX9->(X9_CDOM+X9_DOM) == cChave
						RecLock("SX9",.F.)
						SX9->(dbDelete())
						SX9->(MsUnLock())
						SX9->(dbSkip())
					End
				EndIf
			EndIf
			If cRelStart <= "023" .And. cRelFinish >= "023"
				If cMode == "1" //1=Por grupo de empresas 
					iSFC := SFCIntegra()

					// Atualiza motivos de parada e refugo da tabela SX5
					UPDMotiPar()
					UPDMotiRef()

					// Quando cliente não tem SFC, ajusta campos do SFC para browse = no
					IF iSFC == 0
						dbSelectArea("SX3")
						SX3->(dbSetOrder(2))
						If SX3->(dbSeek("CYN_LGEF"))
							RecLock("SX3",.F.)
							SX3->X3_BROWSE := 'N'
							SX3->(MsUnLock())
						Endif

						dbSelectArea("SX3")
						SX3->(dbSetOrder(2))
						If SX3->(dbSeek("CYN_LGSU"))
							RecLock("SX3",.F.)
							SX3->X3_BROWSE := 'N'
							SX3->(MsUnLock())
						Endif

						dbSelectArea("SX3")
						SX3->(dbSetOrder(2))
						If SX3->(dbSeek("CYN_LGSS"))
							RecLock("SX3",.F.)
							SX3->X3_BROWSE := 'N'
							SX3->(MsUnLock())
						Endif

						dbSelectArea("SX3")
						SX3->(dbSetOrder(2))
						If SX3->(dbSeek("CYN_LGELEQ"))
							RecLock("SX3",.F.)
							SX3->X3_BROWSE := 'N'
							SX3->(MsUnLock())
						Endif

						dbSelectArea("SX3")
						SX3->(dbSetOrder(2))
						If SX3->(dbSeek("CYO_LGRT"))
							RecLock("SX3",.F.)
							SX3->X3_BROWSE := 'N'
							SX3->(MsUnLock())
						Endif

						dbSelectArea("SX3")
						SX3->(dbSetOrder(2))
						If SX3->(dbSeek("CYO_LGRFMP"))
							RecLock("SX3",.F.)
							SX3->X3_BROWSE := 'N'
							SX3->(MsUnLock())
						Endif
					Endif
				Endif
			EndIf
			If cRelStart <= "030" .And. cRelFinish >= "030" .And. cMode == "1" //1=Por grupo de empresas

				//Ajustes ordenação de campos SGI(Produto Alternativo)
				If SX3->(DbSeek("GI_DESC"))
					RecLock("SX3",.F.)
						SX3->X3_ORDEM   := "05"
					SX3->(MsUnlock())
				EndIf
				If SX3->(DbSeek("GI_TIPOCON"))
					RecLock("SX3",.F.)
						SX3->X3_ORDEM   := "06"
					SX3->(MsUnlock())
				EndIf
				If SX3->(DbSeek("GI_FATOR"))
					RecLock("SX3",.F.)
						SX3->X3_ORDEM   := "07"
					SX3->(MsUnlock())
				EndIf
				If SX3->(DbSeek("GI_MRP"))
					RecLock("SX3",.F.)
						SX3->X3_ORDEM   := "08"
					SX3->(MsUnlock())
				EndIf
				If SX3->(DbSeek("GI_DATA"))
					RecLock("SX3",.F.)
						SX3->X3_ORDEM   := "09"
					SX3->(MsUnlock())
				EndIf
				If SX3->(DbSeek("GI_ESTOQUE"))
					RecLock("SX3",.F.)
						SX3->X3_ORDEM   := "10"
					SX3->(MsUnlock())
				EndIf

			EndIf

			If cRelStart <= "031" .And. cRelFinish >= "031"
				If cMode == "1"  //1=Por grupo de empresas
					iSFC := SFCIntegra()

					If iSFC == 1
						dbSelectArea("SX3")
						SX3->(dbSetOrder(2))
						If SX3->(DbSeek("G2_TEMPEND"))
							nDecimal := SX3->X3_DECIMAL
					
							If nDecimal > 0
								dbSelectArea("SX3")
								SX3->(dbSetOrder(2))
								If SX3->(DbSeek("CYD_QTTETS"))					
									nTamCYD := SX3->X3_TAMANHO
									cPicture := ' '

									If nDecimal == 2 .And. nTamCYD == 10
										cPicture := '@E 9,999,999.99'
									Else
										CriaPicRUP(nDecimal,nTamCYD, @cPicture)
									EndIf
				
									RecLock("SX3",.F.)
										SX3->X3_DECIMAL := nDecimal
										SX3->X3_PICTURE := cPicture
									SX3->(MsUnlock())
								EndIf
							EndIf						
						EndIf
					EndIf
				EndIf
			EndIf

			//NEWPCP - Tratamento de Campos novos - Somente executa quando migrar para a 27 ou superior.
			If cRelFinish >= "027" .And. cMode == "1" //1=Por grupo de empresas
				TratNewPcp()
			EndIf
		EndIf
	#Endif

Return Nil

//----------------------------------------------------------------------
// Ajusta campos projeto operações x componentes
//----------------------------------------------------------------------
Static Function OperXComp()

	// Verificar todas as ordens de produção
	dbSelectArea('SC2')
	SC2->(dbSetOrder(1))
	If SC2->(dbSeek(xFilial('SC2')))
		While SC2->(!EOF()) .AND. SC2->C2_FILIAL == xFilial('SC2')

			IF !A650DefLeg(5) .AND. !A650DefLeg(6)
				dbSelectArea('SD4')
				SD4->(dbSetOrder(2))
				if SD4->(FieldPos("D4_PRODUTO")) > 0 .And. SD4->(FieldPos("D4_ROTEIRO")) > 0 .And. SD4->(FieldPos("D4_OPERAC")) > 0 .And. SD4->(dbSeek(xFilial('SD4')+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN))

					While SD4->(!EOF()) .AND. SD4->D4_FILIAL == xFilial('SD4') .AND. ALLTRIM(SD4->D4_OP) == ALLTRIM(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN)
						dbSelectArea('SGF')
						SGF->(dbSetOrder(2))
						IF Empty(SD4->(D4_PRODUTO+D4_ROTEIRO+D4_OPERAC)) .And. SGF->(dbSeek(xFilial('SGF')+SC2->C2_PRODUTO+SC2->C2_ROTEIRO+SD4->D4_COD+SD4->D4_TRT))
							RecLock('SD4',.F.)

							SD4->D4_PRODUTO := SC2->C2_PRODUTO
							SD4->D4_ROTEIRO := SC2->C2_ROTEIRO
							SD4->D4_OPERAC  := SGF->GF_OPERAC

							MsUnLock()

							dbSelectArea('CYP')
							CYP->(dbSetOrder(3))

							if CYP->(dbSeek(xFilial('CYP')+SD4->D4_OP+SD4->D4_COD+SD4->D4_TRT))
								RecLock('CYP',.F.)

								CYP->CYP_CDRT := SC2->C2_ROTEIRO
								CYP->CYP_CDAT := SGF->GF_OPERAC

								MsUnlock()
							Endif

						Endif

						SD4->(dbSkip())
					End

				Endif
			Endif

			SC2->(dbSkip())
		End
	Endif

Return Nil

//----------------------------------------------------------------------
// Ajusta SX3
//----------------------------------------------------------------------
Static Function AjustaSX3()
Local cSql      := ""
Local cSeqCmp   := "00"


dbSelectArea("SX3")
dbsetOrder(2)

If SX3->(DbSeek("D4_OPORIG"))
	If SX3->X3_VISUAL != "V"
		RecLock("SX3",.F.)
		Replace SX3->X3_VISUAL With "V"
		SX3->(MsUnlock())
	EndIf
EndIf

cSql := " UPDATE " + RetSqlName("CZE")
cSql +=    " SET CZE_SQAB = 1 "
cSql +=  " WHERE CZE_SQAB = 0 "
TCSQLExec(cSql)

cSql := " UPDATE " + RetSqlName("CZG")
cSql +=    " SET CZG_SQAB = 1 "
cSql +=  " WHERE CZG_SQAB = 0 "
TCSQLExec(cSql)

dbSelectArea("SX3")
SX3->(dbSetOrder(2))
If SX3->(dbSeek("CZE_CDAB"))
	cSeqCmp := SOMA1(SX3->X3_ORDEM)
	SX3->(dbSetOrder(1))
	If SX3->(dbSeek("CZE"+cSeqCmp))

		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "CZE"
			SX3->(dbSkip())
		End

		SX3->(dbSkip(-1)) //Posiciona no ultimo campo da tabela CZE.

		While SX3->(!Eof()) .And. SX3->X3_ARQUIVO == "CZE" .And. AllTrim(SX3->X3_CAMPO) != "CZE_CDAB"
			RecLock("SX3",.F.)
			SX3->X3_ORDEM := SOMA1(SX3->X3_ORDEM)
			SX3->(MsUnLock())
			SX3->(dbSkip(-1))
		End

		SX3->(dbSetOrder(2))

		If SX3->(dbSeek("CZE_SQAB"))
			RecLock("SX3",.F.)
			SX3->X3_ORDEM := cSeqCmp
			SX3->(MsUnLock())
		EndIf
	EndIf
Endif



Return

//----------------------------------------------------------------------
// Ajusta campos mrp multi empresa
//----------------------------------------------------------------------
Static Function SX3MrpME()
dbSelectArea("SX3")
	SX3->(dbsetOrder(2))

	//Ajusta a descrição e posição dos campos da tabela SOO
	If SX3->(DbSeek("OO_CDEPCZ"))
		RecLock("SX3",.F.)
			SX3->X3_TITULO  := "Grupo"
			SX3->X3_DESCRIC := "Grupo Centralizador"
			SX3->X3_TITSPA  := "Grupo"
			SX3->X3_DESCSPA := "Grupo centralizador"
			SX3->X3_TITENG  := "Group"
			SX3->X3_DESCENG := "Centralizer Group"
			SX3->X3_ORDEM   := "02"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("OO_DSEPCZ"))
		RecLock("SX3",.F.)
			SX3->X3_TITULO  := "Desc Grupo"
			SX3->X3_DESCRIC := "Descrição Grupo"
			SX3->X3_TITSPA  := "Desc Grupo"
			SX3->X3_DESCSPA := "Descripción grupo"
			SX3->X3_TITENG  := "Group Desc"
			SX3->X3_DESCENG := "Group Description"
			SX3->X3_ORDEM   := "03"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("OO_EMPRCZ"))
		RecLock("SX3",.F.)
			SX3->X3_ORDEM   := "04"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("OO_DSEMPR"))
		RecLock("SX3",.F.)
			SX3->X3_ORDEM   := "05"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("OO_UNIDCZ"))
		RecLock("SX3",.F.)
			SX3->X3_ORDEM   := "06"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("OO_DSUNID"))
		RecLock("SX3",.F.)
			SX3->X3_ORDEM   := "07"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("OO_CDESCZ"))
		RecLock("SX3",.F.)
			SX3->X3_ORDEM   := "08"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("OO_DSESCZ"))
		RecLock("SX3",.F.)
			SX3->X3_ORDEM   := "09"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("OO_TS"))
		RecLock("SX3",.F.)
			SX3->X3_ORDEM   := "10"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("OO_TE"))
		RecLock("SX3",.F.)
			SX3->X3_ORDEM   := "11"
		MsUnLock()
	EndIf

	//Ajusta a descrição dos campos da tabela SOP
	If SX3->(DbSeek("OP_CDEPCZ"))
		RecLock("SX3",.F.)
			SX3->X3_TITULO  := "Grupo"
			SX3->X3_DESCRIC := "Grupo Centralizador"
			SX3->X3_TITSPA  := "Grupo"
			SX3->X3_DESCSPA := "Grupo centralizador"
			SX3->X3_TITENG  := "Group"
			SX3->X3_DESCENG := "Centralizer Group"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("OP_CDEPGR"))
		RecLock("SX3",.F.)
			SX3->X3_TITULO  := "Grupo"
			SX3->X3_DESCRIC := "Grupo Centralizado"
			SX3->X3_TITSPA  := "Grupo"
			SX3->X3_DESCSPA := "Grupo centralizado"
			SX3->X3_TITENG  := "Group"
			SX3->X3_DESCENG := "Centralizer Group"
		MsUnLock()
	EndIf
Return

//----------------------------------------------------------------------
// Ajusta Titulos dos Campos da SVC e SVK referente armazens de consumo
//----------------------------------------------------------------------
Static Function TitLocais()
	dbSelectArea("SX3")
	SX3->(dbsetOrder(2))

	If SX3->(DbSeek("VC_LOCCONS"))
		RecLock("SX3",.F.)
			SX3->X3_TITULO  := "Arm. Consumo"
			SX3->X3_DESCRIC := "Armazém de consumo"
			SX3->X3_TITSPA  := "Alm. Consumo"
			SX3->X3_DESCSPA := "Almacén de consumo"
			SX3->X3_TITENG  := "Consump Ware"
			SX3->X3_DESCENG := "Consumption Warehouse"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("VC_LOCCDES"))
		RecLock("SX3",.F.)
			SX3->X3_TITULO  := "Desc. Arm."
			SX3->X3_DESCRIC := "Descrição do armazém"
			SX3->X3_TITSPA  := "Desc. Alm."
			SX3->X3_DESCSPA := "Descripción del almacén"
			SX3->X3_TITENG  := "Wareh Desc"
			SX3->X3_DESCENG := "Warehouse description"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("VC_LOCEST"))
		RecLock("SX3",.F.)
			SX3->X3_TITULO  := "Arm. Estoq"
			SX3->X3_DESCRIC := "Armazém de estocagem"
			SX3->X3_TITSPA  := "Alm. Stock"
			SX3->X3_DESCSPA := "Almacén de stock"
			SX3->X3_TITENG  := "Stock Wareh"
			SX3->X3_DESCENG := "Stock Warehouse"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("VC_LOCEDES"))
		RecLock("SX3",.F.)
			SX3->X3_TITULO  := "Desc. Arm."
			SX3->X3_DESCRIC := "Descrição do armazém"
			SX3->X3_TITSPA  := "Desc. Alm."
			SX3->X3_DESCSPA := "Descripción del almacén"
			SX3->X3_TITENG  := "Wareh Desc"
			SX3->X3_DESCENG := "Warehouse Description"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("VK_HORFIX"))
		RecLock("SX3",.F.)
			SX3->X3_TITULO  := "Horiz.Firme"
			SX3->X3_DESCRIC := "Horizonte Firme"
			SX3->X3_TITSPA  := "Horiz.Firme"
			SX3->X3_DESCSPA := "Horizonte Firme"
			SX3->X3_TITENG  := "Firm Horiz"
			SX3->X3_DESCENG := "Firm Horizon"
		MsUnLock()
	EndIf

	If SX3->(DbSeek("VK_TPHOFIX"))
		RecLock("SX3",.F.)
			SX3->X3_TITULO  := "Tipo Hor Fir"
			SX3->X3_DESCRIC := "Tipo do Horizonte Firme"
			SX3->X3_TITSPA  := "Horiz.Firme"
			SX3->X3_DESCSPA := "Horizonte Firme"
			SX3->X3_TITENG  := "Firm Horiz"
			SX3->X3_DESCENG := "Firm Horizon"
		MsUnLock()
	EndIf

Return

//----------------------------------------------------------------------
// Tratamento de Campos incluídos do projeto NewPCP
//----------------------------------------------------------------------
Static Function TratNewPcp()

	Local cNextAlias := GetNextAlias()
	Local cQuery     := ""

	dbSelectArea("SGI")
	If SGI->(FieldPos("GI_ESTOQUE")) > 0
		BeginSQL Alias cNextAlias
			SELECT 1 FROM %Table:SGI% SGI
			 WHERE SGI.GI_ESTOQUE IS NULL OR SGI.GI_ESTOQUE = %Exp:' '%
		EndSQL

		If !(cNextAlias)->(Eof())
			cQuery := "UPDATE " + RetSqlName("SGI")
			cQuery +=   " SET GI_ESTOQUE = '1'"
			cQuery += " WHERE GI_ESTOQUE IS NULL OR GI_ESTOQUE = ' '"
			TCSQLExec(cQuery)
		EndIf

		(cNextAlias)->(DbCloseArea())
	EndIf

	dbSelectArea("SG1")
	If SG1->(FieldPos("G1_USAALT")) > 0
		BeginSQL Alias cNextAlias
			SELECT 1 FROM %Table:SG1% SG1
			 WHERE SG1.G1_USAALT IS NULL OR SG1.G1_USAALT = %Exp:' '%
		EndSQL

		If !(cNextAlias)->(Eof())
			cQuery := "UPDATE " + RetSqlName("SG1")
			cQuery +=   " SET G1_USAALT = '1'"
			cQuery += " WHERE G1_USAALT IS NULL OR G1_USAALT = ' '"
			TCSQLExec(cQuery)
		EndIf

		(cNextAlias)->(DbCloseArea())
	EndIf

	AtualizDic()
Return

//----------------------------------------------------------------------
// Atualiza dicionário comparando campos/compartilhamento de
// tabelas do MRP com as respectivas tabelas do ERP
//----------------------------------------------------------------------
Static Function AtualizDic()

	Local aInconsCp   := {}
	Local aInconsCo   := {}
	Local aTabUpd     := {}
	Local nIndIncons  := 0

	If FindFunction("VCpMRPxERP")
		aInconsCp := VCpMRPxERP()

		If Len(aInconsCp)
			DbSelectArea("SX3")
			SX3->(DbSetOrder(2))

			For nIndIncons := 1 To Len(aInconsCp)
				If SX3->(dbSeek(aInconsCp[nIndIncons][2]))
					If RecLock("SX3",.F.)
						SX3->X3_TAMANHO := aInconsCp[nIndIncons][3]
						SX3->X3_DECIMAL := aInconsCp[nIndIncons][4]
						SX3->X3_PICTURE := aInconsCp[nIndIncons][5]
						SX3->(MsUnlock())
					Endif

					If aScan(aTabUpd, aInconsCp[nIndIncons][1]) < 1
						aAdd(aTabUpd, aInconsCp[nIndIncons][1])
					EndIf
				Endif
			Next nIndIncons
		EndIf
	EndIf

	If FindFunction("VCoMRPxERP")
		aInconsCo := VCoMRPxERP()

		If Len(aInconsCo)
			For nIndIncons := 1 To Len(aInconsCo)
				If ChkFile(aInconsCo[nIndIncons][2][1])
					DbSelectArea(aInconsCo[nIndIncons][2][1])
					(aInconsCo[nIndIncons][2][1])->(DbGoTop())

					If (aInconsCo[nIndIncons][2][1])->(Eof())
						DbSelectArea("SX2")
						SX2->(DbSetOrder(1))
						If SX2->(DbSeek(aInconsCo[nIndIncons][2][1]))
							If RecLock("SX2", .F.)
								SX2->X2_MODOEMP := aInconsCo[nIndIncons][1][2]
								SX2->X2_MODOUN  := aInconsCo[nIndIncons][1][3]
								SX2->X2_MODO    := aInconsCo[nIndIncons][1][4]
								SX2->(MsUnlock())
							EndIf

							If aScan(aTabUpd, aInconsCo[nIndIncons][2][1]) < 1
								aAdd(aTabUpd, aInconsCo[nIndIncons][2][1])
							EndIf
						EndIf
					EndIf
					(aInconsCo[nIndIncons][2][1])->(DbCloseArea())
				EndIf
			Next nIndIncons
		EndIf
	EndIf

	For nIndIncons := 1 To Len(aTabUpd)
		If !Empty(aTabUpd[nIndIncons])
			__SetX31Mode(.F.)
			
			If Select(aTabUpd[nIndIncons]) > 0
				DbSelectArea(aTabUpd[nIndIncons])
				DbCloseArea()
			EndIf
				
			X31UpdTable(aTabUpd[nIndIncons])
		EndIf
	Next nIndIncons
Return

//----------------------------------------------------------------------
// Cria PICTURE conforme tamanho do campo númerico
//----------------------------------------------------------------------
Static Function CriaPicRUP(nDecimal,nTamCYD, cPicture)
 
  Local nI := 0

	If nDecimal > 0
		cMasc := '@E '
		cPicDec := '.'
		cPicT1 := ''
		cPicT2 := ''

		//Gera formatação do decimal
		For nI = 1 to nDecimal
			cPicDec += '9'
		Next

		//Gera formatação do tamanho
		nQtd    := (nTamCYD - nDecimal - 1)
		nInt    := Int(nQtd / 3)

		If nInt > 1
			nQtd1 := nQtd - (nInt*3)		
		
			If nQtd1 > 0
				For nI := 1 to (nQtd1)
					cPicT1 +='9'
				Next
				cPicT1 += ','
			EndIf

			For nI := 1 to (nInt)
				If nI < nInt
					cPicT2 += '999,'
				Else
					cPicT2 += '999'
				EndIf
			Next			
		Else			
			For nI := 1 to (nQtd)
				cPicT1 +='9'
			Next
		EndIf

		cPicture := cValToChar(cMasc) + cValToChar(cPicT1) + cValToChar(cPicT2) + cValToChar(cPicDec)	
	EndIf

Return 

/*/{Protheus.doc} foldersSVK
Apaga os folders e agrupamentos da tabela SVK.
@type  Static Function
@author Lucas Fagundes
@since 23/08/2022
@version P12
@return Nil
/*/
Static Function foldersSVK()
	DbSelectArea("SXA")
	
	SXA->(DbSetOrder(1))
	If SXA->(DbSeek("SVK"))
		While SXA->(!EoF())
			If RecLock('SXA',.F.)
				SXA->(dbDelete())
				SXA->(MsUnlock())
			EndIf
			SXA->(dbSkip())
		End
	EndIf

Return Nil
