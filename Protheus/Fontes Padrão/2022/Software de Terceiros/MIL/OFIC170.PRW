#Include "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#Include "FOLDER.CH"
#Include "OFIC170.CH"

Static oModVS1
Static oModTOT
Static oModVST
Static oModVS3
Static oModVS4
Static lInconveniente := (GetNewPar("MV_INCORC","N") == "S")

/*/{Protheus.doc} OFIC170
Consulta Orcamento VS1 VST VS3 VS4

@author Andre Luis Almeida
@since 05/02/2020
@version 1.0

@type function
/*/
Function OFIC170( cFilVS1 , cNroVS1 )

Local oBrwOC170
Local oExecView

Local nCntFor     := 0
Local cFilDefault := ""
Local cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao

Default cFilVS1 := ""
Default cNroVS1 := ""

If Empty( cFilVS1 + cNroVS1 )
	cFilDefault += " VS1->VS1_TIPORC $ '12' "
	DBSelectArea("VAI")
	DBSetOrder(4)
	DBSeek(xFilial("VAI")+__cUserId)
	If VAI->VAI_TIPTEC == "4"
		cFilDefault += " .and. VS1->VS1_CODVEN == '"+VAI->VAI_CODVEN+"'"
	EndIf
	If Alltrim(VAI->VAI_FASORC) != ""
		cFilDefault += " .and. VS1->VS1_STATUS $ '"
		For nCntFor := 1 to Len(Alltrim(VAI->VAI_FASORC))
			cFilDefault += subs(Alltrim(VAI->VAI_FASORC),nCntFor,1)+","
		Next
		cFilDefault += "'"
	EndIf
	DbSelectArea("VS1")
	oBrwOC170 := FWMBrowse():New()
	oBrwOC170:SetAlias("VS1")
	oBrwOC170:DisableLocate()
	oBrwOC170:DisableDetails()
	oBrwOC170:SetAmbiente(.F.)
	oBrwOC170:SetWalkthru(.F.)
	oBrwOC170:SetDescription(STR0001) // Consulta Orçamentos
	oBrwOC170:SetMenuDef("OFIC170") // Mostra Botao Visualizar
	oBrwOC170:AddFilter( STR0002 ,cFilDefault,.t.,.t.,) // Filtro Padrão - nao deixa desmarcar
	oBrwOC170:AddFilter( STR0003 ,"VS1->VS1_TIPORC == '1'",.f.,.f.,) // Orçamento Balcão
	oBrwOC170:AddLegend( " VS1_TIPORC+VS1_STATUS == '10' "                            , "BR_VERDE"   , STR0005 ) // Orçamento Balcão Digitado
	oBrwOC170:AddLegend( " VS1_TIPORC+VS1_STATUS == '12' "                            , "BR_PINK"    , STR0006 ) // Orçamento Balcão Margem Pendente
	oBrwOC170:AddLegend( " VS1_STATUS == '3' "                                        , "BR_BRANCO"  , STR0007 ) // Orçamento Balcão Avaliação de Crédito
	oBrwOC170:AddLegend( " VS1_STATUS == '"+cFaseConfer+"'"                           , "BR_AZUL"    , STR0008 ) // Orçamento Balcão Aguardando Separação
	oBrwOC170:AddLegend( " VS1_STATUS == '5' "                                        , "BR_MARROM"  , STR0009 ) // Orçamento Balcão Aguardando Lib.Divergencia
	oBrwOC170:AddLegend( " VS1_STATUS $ 'RT' "                                        , "BR_CINZA"   , STR0010 ) // Orçamento Balcão Aguardando Reserva
	oBrwOC170:AddLegend( " VS1_TIPORC+VS1_STATUS == '1F' "                            , "BR_AMARELO" , STR0011 ) // Orçamento Balcão Liberado para Faturamento
	oBrwOC170:AddLegend( " VS1_STATUS == 'G' "                                        , "BR_AZUL_CLARO" , STR0039 ) // Orçamento Balcão aguardando outro Orçamento
	oBrwOC170:AddLegend( " VS1_TIPORC+VS1_STATUS == '1X' "                            , "BR_PRETO"   , STR0012 ) // Orçamento Balcão Faturado
	oBrwOC170:AddLegend( " VS1_TIPORC+VS1_STATUS == '1C' "                            , "BR_VERMELHO", STR0013 ) // Orçamento Balcão Cancelado
	oBrwOC170:AddFilter( STR0004 ,"VS1->VS1_TIPORC == '2'",.f.,.f.,) // Orçamento Oficina
	oBrwOC170:AddLegend( " VS1_TIPORC+VS1_STATUS == '20' "                            , "f10_verd"   , STR0014 ) // Orçamento Oficina Digitado
	oBrwOC170:AddLegend( " ( VS1_STATUS == 'P' .or. VS1_TIPORC+VS1_STATUS == '22' ) " , "f12_azul"   , STR0016 ) // Orçamento Oficina Pendente Liberação
	oBrwOC170:AddLegend( " ( VS1_STATUS == 'L' .or. VS1_TIPORC+VS1_STATUS == '2F' ) " , "f5_amar"    , STR0015 ) // Orçamento Oficina Liberado para Ordem de Serviço
	oBrwOC170:AddLegend( " VS1_STATUS == 'I' "                                        , "f14_cinz"   , STR0017 ) // Orçamento Oficina Importado na OS
	oBrwOC170:AddLegend( " VS1_TIPORC+VS1_STATUS == '2C' "                            , "f7_verm"    , STR0018 ) // Orçamento Oficina Cancelado
	oBrwOC170:SetInsert(.f.)
	oBrwOC170:SetUseFilter()
	oBrwOC170:lOptionReport := .f.
	oBrwOC170:Activate()
Else
	DbSelectArea("VS1")
	DbSetOrder(1)
	If DbSeek( cFilVS1 + cNroVS1 )
		oExecView := FWViewExec():New()
		oExecView:SetTitle(STR0001) // Consulta Orçamentos
		oExecView:SetSource("OFIC170")
		oExecView:SetOperation(MODEL_OPERATION_VIEW)
		oExecView:OpenView(.T.)
	EndIf
EndIf

Return NIL

/*/{Protheus.doc} MenuDef()
Função para criação do menu 

@author Andre Luis Almeida
@since 05/02/2020
@version 1.0
@return aRotina 
/*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0019 ACTION 'VIEWDEF.OFIC170' OPERATION 2 ACCESS 0 // Visualizar

Return aRotina

/*/{Protheus.doc} ModelDef
Definição do modelo de Dados

@author Andre Luis Almeida
@since 05/02/2020
@version 1.0
@Return oModel
/*/
Static Function ModelDef()
Local oStrVS1
Local oStrTOT
Local oStrVST
Local oStrVS3
Local oStrVS4

If oModVS1 == NIL 
	oModVS1 := OC1700011_GetModel("VS1")
	oModTOT := OC1700011_GetModel("TOT")
	oModVST := OC1700011_GetModel("VST")
	oModVS3 := OC1700011_GetModel("VS3")
	oModVS4 := OC1700011_GetModel("VS4")
EndIf

oStrVS1 := oModVS1:GetModel()
oStrTOT := oModTOT:GetModel()
oStrVST := oModVST:GetModel()
oStrVS3 := oModVS3:GetModel()
oStrVS4 := oModVS4:GetModel()

oModel := MPFormModel():New("OFIC170", /* bPre */, /* bPost */ , /* bCommit */ , /* bCancel */ )
oModel:SetDescription(STR0001) // Consulta Orçamentos

oModel:AddFields("VS1MASTER",,oStrVS1,,,{|| OC1700021_LoadReg("VS1") })
oModel:GetModel("VS1MASTER"):SetDescription(STR0020) // Orçamento

oModel:AddGrid( "TOTDETAIL" , "VS1MASTER", oStrTOT ,,,,,{|| OC1700021_LoadReg("TOT") })
oModel:GetModel("TOTDETAIL"):SetDescription(STR0023) // Totais
oModel:GetModel("TOTDETAIL"):SetOptional(.T.)

oModel:AddGrid( "VSTDETAIL" , "VS1MASTER", oStrVST ,,,,,{|| OC1700021_LoadReg("VST") })
oModel:GetModel("VSTDETAIL"):SetDescription(STR0035) // Inconvenientes
oModel:GetModel("VSTDETAIL"):SetOptional(.T.)

oModel:AddGrid( "VS3DETAIL" , "VS1MASTER", oStrVS3 ,,,,,{|| OC1700021_LoadReg("VS3") })
oModel:GetModel("VS3DETAIL"):SetDescription(STR0021) // Peças
oModel:GetModel("VS3DETAIL"):SetOptional(.T.)

oModel:AddGrid( "VS4DETAIL" , "VS1MASTER", oStrVS4 ,,,,,{|| OC1700021_LoadReg("VS4") })
oModel:GetModel("VS4DETAIL"):SetDescription(STR0022) // Serviços
oModel:GetModel("VS4DETAIL"):SetOptional(.T.)

oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} ViewDef
Definição do interface

@author Andre Luis Almeida
@since 05/02/2020
@version 1.0
@Return oView
/*/
Static Function ViewDef()
Local oView
Local oModel  := ModelDef()
Local oStrVS1 := oModVS1:GetView()
Local oStrTOT := oModTOT:GetView()
Local oStrVST := oModVST:GetView()
Local oStrVS3 := oModVS3:GetView()
Local oStrVS4 := oModVS4:GetView()

oView := FWFormView():New()

oView:SetModel(oModel)

oView:SetCloseOnOk({||.T.})

oView:AddField( 'VIEW_VS1', oStrVS1, 'VS1MASTER' )
oView:AddGrid( 'VIEW_TOT' , oStrTOT, 'TOTDETAIL' )
If lInconveniente
	oView:AddGrid( 'VIEW_VST' , oStrVST, 'VSTDETAIL' )
EndIf
oView:AddGrid( 'VIEW_VS3' , oStrVS3, 'VS3DETAIL' )
oView:AddGrid( 'VIEW_VS4' , oStrVS4, 'VS4DETAIL' )

oView:CreateHorizontalBox('TOP' , 40)
oView:CreateVerticalBox('BOXVS1' , 70, 'TOP')
oView:CreateVerticalBox('BOXTOT' , 30, 'TOP')

oView:CreateHorizontalBox('DETAIL' , 60)
oView:CreateFolder('FOLDER','DETAIL')
If lInconveniente
	oView:AddSheet('FOLDER','FOLD_INC',STR0035) // Inconvenientes
EndIf
oView:AddSheet('FOLDER','FOLD_PEC',STR0021) // Peças
oView:AddSheet('FOLDER','FOLD_SRV',STR0022) // Serviços

If lInconveniente
	oView:CreateHorizontalBox( 'BOXVST',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_INC')
EndIf
oView:CreateHorizontalBox( 'BOXVS3',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_PEC')
oView:CreateHorizontalBox( 'BOXVS4',100, /*owner*/, /*lUsePixel*/, 'FOLDER', 'FOLD_SRV')

oView:SetOwnerView('VIEW_VS1','BOXVS1')
oView:SetOwnerView('VIEW_TOT','BOXTOT')
If lInconveniente
	oView:SetOwnerView('VIEW_VST','BOXVST')
EndIf
oView:SetOwnerView('VIEW_VS3','BOXVS3')
oView:SetOwnerView('VIEW_VS4','BOXVS4')

oView:AddUserButton(STR0034,'',{ |oView| OC1700038_Imprimir() }) // Imprimir

If FindFunction("OFIC250") .and. !IsInCallStack("OFIC250") //se existir a Consulta Tempos por Status do Orçamento e não chamou por ela mesma
	oView:AddUserButton(STR0036,'',{ |oView| OFIC250(VS1->VS1_NUMORC) }) // Tempos por Status do Orçamento
EndIf

Return oView

/*/{Protheus.doc} OC1700011_GetModel
Carrega Campos para serem utilizados nas Grid's

@author Andre Luis Almeida
@since 10/02/2020
@version 1.0
/*/
Static Function OC1700011_GetModel(cTabMod)
	Local oMdRet := OFDMSStruct():New()
	Local aAuxStru := {}
	Local nCntFor  := {}
	Local nTamCpo  := 0
	Do Case
		Case cTabMod == "TOT"
			oMdRet:AddField({	{'cTitulo'  , STR0023           },; // Totais
								{'cIdField' , "TOT_DESC"         },;
								{'cTipo'    , 'C'                },;
								{'nTamanho' , 30                 },;
								{'cTooltip' , STR0023           } ; // Totais
							})
			oMdRet:AddField({	{'cTitulo'  ,  STR0024           },; // Valor
								{'cIdField' , "TOT_VALOR"        },;
								{'cTipo'    , 'N'                },;
								{'nTamanho' , 10                 },;
								{'nDecimal' ,  2                 },;
								{'cPicture' , '@E 999,999,999.99'},;
								{'cTooltip' ,  STR0024           } ; // Valor
							})
		OtherWise
			If cTabMod == "VS1"
				aAuxStru := FWFormStruct(3, "VS1" , { |x| !AllTrim(x) $ "VS1_FILIAL/" } )
			ElseIf cTabMod == "VST"
				aAuxStru := FWFormStruct(3, "VST" , { |x| AllTrim(x) $ "VST_SEQINC/VST_GRUINC/VST_CODINC/VST_DESINC/" } ) // Campos Fixos do Inconveniente
			Else
				If lInconveniente
					aAuxStru := FWFormStruct(3, cTabMod , { |x| !AllTrim(x) $ cTabMod+"_FILIAL/"+cTabMod+"_NUMORC/" } )
				Else
					aAuxStru := FWFormStruct(3, cTabMod , { |x| !AllTrim(x) $ cTabMod+"_FILIAL/"+cTabMod+"_NUMORC/"+cTabMod+"_SEQINC/"+cTabMod+"_CODINC/"+cTabMod+"_GRUINC/"+cTabMod+"_DESINC/" } )
				EndIf
			EndIf
			For nCntFor := 1 to Len(aAuxStru[FORM_STRUCT_TABLE_MODEL])
				If !Empty(GetSX3Cache( aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ] ,"X3_CBOX"))
					nTamCpo := 30
				Else
					nTamCpo := aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_TAMANHO ]
				EndIf
				oMdRet:AddField({	{'cTitulo'  , aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_TITULO ]        },;
									{'cIdField' , "TMP"+aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ] },;
									{'cTipo'    , aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_TIPO ]          },;
									{'nTamanho' , nTamCpo                                                                   },;
									{'nDecimal' , aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_DECIMAL ]       },;
									{'cPicture' , GetSX3Cache( aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ] ,"X3_PICTURE") },;
									{'cTooltip' , aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_TITULO ]        } ;
							})
			Next
	EndCase
return oMdRet

/*/{Protheus.doc} OC1700021_LoadReg
Levanta Registros para apresentar na Tela

@author Andre Luis Almeida
@since 10/02/2020
@version 1.0
@return aRetReg 
/*/
Static Function OC1700021_LoadReg(cTabMod)
Local aRetReg  := {}
Local aAuxStru := {}
Local nCntFor  := 0
Local nLinha   := 0
Local cQuery   := ""
Local cQAlias  := "SQLTMP"+cTabMod
Local xRet
Private aOrc   := {} // utilizado dentro do PE OX001MF1
Private VISUALIZA := .t. // Compatibilidade com SX3
Private INCLUI 	  := .f. // Compatibilidade com SX3
Private ALTERA 	  := .f. // Compatibilidade com SX3
Do Case
	Case cTabMod == "TOT"
		aAdd(aOrc, {'', STR0025, 0, "VS1->VS1_VTOTNF"}) // Total
		aAdd(aOrc, {'', STR0026, 0, "VS1->VS1_ICMCAL"}) // ICMS Calculado
		if VS1->(FieldPos("VS1_VALCMP")) > 0
			aAdd(aOrc, {'', STR0027, 0, "VS1->VS1_VALCMP"}) // ICMS Complementar
		Endif
		If VS1->(FieldPos("VS1_ICMRET")) > 0
			aAdd(aOrc, {'', STR0028, 0, "VS1->VS1_ICMRET"}) // ICMS Substituição Tributária
		EndIf
		if VS1->(FieldPos("VS1_DIFAL")) > 0
			aAdd(aOrc, {'', STR0029, 0, "VS1->VS1_DIFAL"})  // Diferença de ICMS
		Endif
		aAdd(aOrc, {'', STR0030, 0, "VS1->VS1_VALDES"}) // Desconto
		aAdd(aOrc, {'', STR0031, 0, "VS1->VS1_VALSEG"}) // Seguro
		aAdd(aOrc, {'', STR0032, 0, "VS1->VS1_DESACE"}) // Despesa
		aAdd(aOrc, {'', STR0033, 0, "VS1->VS1_VALFRE"}) // Frete
		// PONTO DE ENTRADA PARA ALTERACAO DO VETOR aOrc
		If ExistBlock("OX001MF1")
			ExecBlock("OX001MF1",.f.,.f.)
		EndIf
		If VS1->VS1_VALIPI > 0
			aAdd(aOrc, {'', RetTitle("VS1_VALIPI"), 0, "VS1->VS1_VALIPI"}) // Valor do IPI
		Endif
		//
		For nCntFor := 1 to Len(aOrc)
			If !Empty(aOrc[nCntFor,4])
				aAdd(aRetReg,{ 0 , { aOrc[nCntFor,2] , &(aOrc[nCntFor,4]) } }) // Utiliza CAMPO
			Else
				aAdd(aRetReg,{ 0 , { aOrc[nCntFor,2] , aOrc[nCntFor,3] } }) // Utiliza VALOR
			EndIf
		Next
		//
	Case cTabMod == "VS1"
		aAuxStru := FWFormStruct(3, cTabMod , { |x| !AllTrim(x) $ "VS1_FILIAL/" } )
		RegToMemory("VS1",.F.) // Compatibilidade com SX3
		For nCntFor := 1 to Len(aAuxStru[FORM_STRUCT_TABLE_MODEL])
			If !aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Se NAO for campo Virtual
				If !Empty(GetSX3Cache( aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ] ,"X3_CBOX"))
					xRet := X3CBOXDESC(aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ],&("VS1->"+aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]))
				Else
					xRet := &("VS1->"+aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ])
				EndIf
			Else
				xRet := criavar(aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ])
			EndIf
			aAdd(aRetReg, xRet )
		Next
		//
	OtherWise
		If cTabMod == "VST"
			cQuery := "SELECT R_E_C_N_O_ AS RECREG"
			aAuxStru := FWFormStruct(3, "VST" , { |x| AllTrim(x) $ "VST_SEQINC/VST_GRUINC/VST_CODINC/VST_DESINC/" } )
			For nCntFor := 1 to Len(aAuxStru[FORM_STRUCT_TABLE_MODEL])
				If !aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Se NAO for campo Virtual
					cQuery += "," + aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]
				EndIf
			Next
			cQuery += "  FROM "+RetSqlName("VST")
			cQuery += " WHERE VST_FILIAL='"+VS1->VS1_FILIAL+"'"
			cQuery += "   AND VST_TIPO='1'"
			cQuery += "   AND VST_CODIGO='"+VS1->VS1_NUMORC+"'"
			cQuery += "   AND D_E_L_E_T_=' ' "
		Else // VS3 / VS4
			cQuery := "SELECT R_E_C_N_O_ AS RECREG"
			If lInconveniente
				aAuxStru := FWFormStruct(3, cTabMod , { |x| !AllTrim(x) $ cTabMod+"_FILIAL/"+cTabMod+"_NUMORC/" } )
			Else
				aAuxStru := FWFormStruct(3, cTabMod , { |x| !AllTrim(x) $ cTabMod+"_FILIAL/"+cTabMod+"_NUMORC/"+cTabMod+"_SEQINC/"+cTabMod+"_CODINC/"+cTabMod+"_GRUINC/"+cTabMod+"_DESINC/" } )
			EndIf
			For nCntFor := 1 to Len(aAuxStru[FORM_STRUCT_TABLE_MODEL])
				If !aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Se NAO for campo Virtual
					cQuery += "," + aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]
				EndIf
			Next
			cQuery += "  FROM "+RetSqlName(cTabMod)
			cQuery += " WHERE "+cTabMod+"_FILIAL='"+VS1->VS1_FILIAL+"'"
			cQuery += "   AND "+cTabMod+"_NUMORC='"+VS1->VS1_NUMORC+"'"
			cQuery += "   AND D_E_L_E_T_=' ' "
		EndIf
		dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cQAlias , .T. , .F.)
		While ! (cQAlias)->(Eof())
			aAdd(aRetReg,{ (cQAlias)->( RECREG ) , {} })
			&(cTabMod+"->(DbGoto("+str((cQAlias)->( RECREG ))+"))")
			RegToMemory(cTabMod,.F.) // Compatibilidade com SX3
			nLinha := len(aRetReg)
			For nCntFor := 1 to Len(aAuxStru[FORM_STRUCT_TABLE_MODEL])
				If !aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MODEL_FIELD_VIRTUAL ] // Se NAO for campo Virtual
					If !Empty(GetSX3Cache( aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ] ,"X3_CBOX"))
						xRet := X3CBOXDESC(aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ],(cQAlias)->( &(aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]) ))
					Else
						xRet := (cQAlias)->( &(aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ]) )
					EndIf
				Else
					xRet := criavar(aAuxStru[ FORM_STRUCT_TABLE_MODEL ][ nCntFor ][ MVC_MODEL_IDFIELD ])
				EndIf
				aAdd(aRetReg[nLinha,2], xRet )
			Next
			(cQAlias)->(dbSkip())
		EndDo
		(cQAlias)->(dbCloseArea())
EndCase
Return aRetReg

Function OC1700038_Imprimir()

	If ExistBlock("ORCAMTO") 
		ExecBlock("ORCAMTO",.f.,.f.,{VS1->VS1_NUMORC})
	Endif

Return
