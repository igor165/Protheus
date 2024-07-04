#INCLUDE "TOTVS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'FWEditPanel.CH'
#INCLUDE 'VEIA144.CH'

Static oInfoNota
Static oMBonusLib
Static oMArqRetor
Static oMCpoTotal

Function VEIA144()

	Private nValBon := 0 // Utilizado na consulta padrao de modelos 
	Private nValRet := 0
	Private M->C5_ESTPRES := Space(GetSX3Cache("C5_ESTPRES","X3_TAMANHO"))

	oExecView := FWViewExec():New()
	oExecView:setTitle( STR0001 ) //"Geração nota fiscal de bônus"
	oExecView:setSource("VEIA144")
	oExecView:setCancel( { || .T. } )
	oExecView:setOperation(MODEL_OPERATION_UPDATE)
	oExecView:openView(.T.)

Return


Static Function ModelDef()

	Local oModel 

	Local oStruInfNf
	Local oStruBonLib
	Local oStruCpoTot
	Local oStruArqRet

	Local bLoadInfNf := {|| VA1440115_GetInformacaoNotaFiscal()}
	Local bLoadBonus := {|| VA1440135_GetBonusLiberados()}
	Local bLoadRetor := {|| VA1440145_GetArquivosRetornados()}

	If oInfoNota == NIL
		oInfoNota  := VA1440015_InformacaoNotaFiscal()
		oMBonusLib := VA1440035_Bonus()
		oMArqRetor := VA1440095_ArquivoRetorno()
		oMCpoTotal := VA1440085_BarraTotalizadora()
	EndIf

	oStruInfNf  := oInfoNota:GetModel()
	oStruBonLib := oMBonusLib:GetModel()
	oStruCpoTot := oMCpoTotal:GetModel()
	oStruArqRet := oMArqRetor:GetModel()

	aAuxTrigger := FwStruTrigger("PARCODMAR","PARCODMAR","cFilCodMar := FWFldGet('PARCODMAR')",.F.,"")
	oStruInfNf:AddTrigger(aAuxTrigger[1],aAuxTrigger[2],aAuxTrigger[3],aAuxTrigger[4])

	oModel := MPFormModel():New( 'VEIA144', /* bPre */, /*bPost*/ , { || .t. } /* bCommit */ , { || .T. }/* bCancel */ )
	oModel:AddFields('INFORMACAONF', /* cOwner */ , oStruInfNf, /* <bPre> */ , /* <bPost> */ , bLoadInfNf /* <bLoad> */ )
	oModel:AddFields('CAMPOSTOTAL', 'INFORMACAONF' , oStruCpoTot , /* <bPre> */ , /* <bPost> */ , /* <bLoad> */ { || } )

	oModel:AddGrid('BONUSLIBERADO' ,'INFORMACAONF',oStruBonLib, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, bLoadBonus/* <bLoad> */ )
	oModel:AddGrid('ARQUIVORETORNO','INFORMACAONF',oStruArqRet, /* <bLinePre > */ , /* <bLinePost > */ , /* <bPre > */ , /* <bLinePost > */, bLoadRetor /* <bLoad> */ )

	oModel:SetDescription( STR0001 ) // 'Geração de nota fiscal de bonus'
	
	oModel:GetModel('INFORMACAONF'  ):SetDescription( STR0002 )	// 'Informacoes da Nota Fiscal'
	oModel:GetModel('BONUSLIBERADO' ):SetDescription( STR0003 )	// 'Lista de Bonus Liberado'
	oModel:GetModel('ARQUIVORETORNO'):SetDescription( STR0004 )	// 'Lista de Arquivo de Retorno'
	oModel:GetModel('CAMPOSTOTAL'   ):SetDescription( STR0005 )	// 'Campos de totais'

	oModel:GetModel('INFORMACAONF'  ):SetOnlyQuery( .T. )
	oModel:GetModel('BONUSLIBERADO' ):SetOnlyQuery( .T. )
	oModel:GetModel('ARQUIVORETORNO'):SetOnlyQuery( .T. )
	
	oModel:GetModel('BONUSLIBERADO' ):SetOptional( .T. )
	oModel:GetModel('ARQUIVORETORNO'):SetOptional( .T. )

	oModel:SetPrimaryKey({})

	oModel:InstallEvent("VEIA144EVF", /*cOwner*/, VEIA144EVF():New("VEIA144"))
	
Return oModel

Static Function ViewDef()

	Local oModel	:= FWLoadModel( 'VEIA144' )
	Local oView 	:= Nil

	Local oStruInfNf  := oInfoNota:GetView()
	Local oStruBonLib := oMBonusLib:GetView()
	Local oStruCpoTot := oMCpoTotal:GetView()
	Local oStruArqRet := oMArqRetor:GetView()

	oView := FWFormView():New()
	oView:SetModel(oModel)
	
	oView:AddField('FIELDS_INFORMACAONF' , oStruInfNf  , 'INFORMACAONF')
	oView:AddField('GRID_MODELO_TOTALIZA', oStruCpoTot , 'CAMPOSTOTAL')
	
	oView:AddGrid('GRID_BONUS_LIBERADO' , oStruBonLib , 'BONUSLIBERADO')
	oView:AddGrid('GRID_ARQUIVO_RETORNO', oStruArqRet , 'ARQUIVORETORNO')

	oView:EnableTitleView('FIELDS_INFORMACAONF', STR0002 ) //'Informacoes da Nota Fiscal'
	
	oView:EnableTitleView('GRID_BONUS_LIBERADO', STR0006 ) //"Bônus Liberados"
	oView:SetNoInsertLine('GRID_BONUS_LIBERADO')
	oView:SetNoDeleteLine('GRID_BONUS_LIBERADO')

	oView:EnableTitleView('GRID_ARQUIVO_RETORNO', STR0007 ) //'Arquivos de Retorno'
	oView:SetNoInsertLine('GRID_ARQUIVO_RETORNO')
	oView:SetNoDeleteLine('GRID_ARQUIVO_RETORNO')

	oView:CreateHorizontalBox('TELA_INFORMNF',30)
	oView:CreateHorizontalBox('TELA_BONUSLIB',30)
	oView:CreateHorizontalBox('TELA_RETURNID',30)
	oView:CreateHorizontalBox('TELA_TOTALIZA',10)

	oView:SetOwnerView('FIELDS_INFORMACAONF' ,'TELA_INFORMNF')
	oView:SetOwnerView('GRID_BONUS_LIBERADO' ,'TELA_BONUSLIB')
	oView:SetOwnerView('GRID_ARQUIVO_RETORNO','TELA_RETURNID')
	oView:SetOwnerView('GRID_MODELO_TOTALIZA','TELA_TOTALIZA')

	oView:SetCloseOnOk({||.T.})

	//Executa a ação antes de cancelar a Janela de edição se ação retornar .F. não apresenta o 
	// qustionamento ao usuario de formulario modificado
	oView:SetViewAction("ASKONCANCELSHOW", {|| .F.}) 

	oView:SetModified(.t.) // Marca internamente que algo foi modificado no MODEL

	oView:showUpdateMsg(.f.)
	oView:showInsertMsg(.f.)

Return oView

Static Function VA1440015_InformacaoNotaFiscal()
	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddFieldDictionary( "SC5" , "C5_CLIENTE" , { {"cIdField" , "C5CLIENTE" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_LOJACLI" , { {"cIdField" , "C5LOJACLI" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_VEND1"   , { {"cIdField" , "C5VEND1"   } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_CONDPAG" , { {"cIdField" , "C5CONDPAG" } } )
	
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0008 } ,; //"Servico - Produto"
		{ "cTooltip" , STR0008 } ,;
		{ "cIdField" , "CPOCODPRD" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 70 } ,;
		{ "cLookUp" , "SB1" } ,;
		{ "bValid" , FWBuildFeature(STRUCT_FEATURE_VALID,"Vazio() .or. FG_Seek('SB1','CPOCODPRD',1)") } ,;
		{ "bInit" , { || Space(70) } } ,;
		{ "lVirtual" , .t. } ;
	})

		oRetorno:AddField( { ;
		{ "cTitulo"  , STR0009 } ,; //"Valor"
		{ "cTooltip" , STR0009 } ,;
		{ "cIdField" , "PARVALOR" } ,;
		{ "cTipo"    , "N" } ,;
		{ "cPicture" , "@E 999,999,999.99"} ,;
		{ "nTamanho" , 30 } ,;
		{ "lCanChange" , .f. } ,;
		{ "bInit" , { || 0 } } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddFieldDictionary( "SC5" , "C5_NATUREZ" , { {"cIdField" , "C5NATUREZ" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_BANCO"   , { {"cIdField" , "C5BANCO"   } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_TIPOCLI" , { {"cIdField" , "C5TIPOCLI" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_INDPRES" , { {"cIdField" , "C5INDPRES" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_MENPAD"  , { {"cIdField" , "C5MENPAD"  } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_MENNOTA" , { {"cIdField" , "C5MENNOTA" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_ESTPRES" , { {"cIdField" , "C5ESTPRES" } , { "bValid", FWBuildFeature(STRUCT_FEATURE_VALID,"VA1440155_ValidaEstadoPrestacao()") } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_MUNPRES" , { {"cIdField" , "C5MUNPRES" } } )
	oRetorno:AddFieldDictionary( "SC5" , "C5_DESCMUN" , { {"cIdField" , "C5DESCMUN" } } )

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0010 } ,; //"Observacao NF"
		{ "cTooltip" , STR0010 } ,;
		{ "cIdField" , "PAROBSNF" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 250 } ;
	})

Return oRetorno

Static Function VA1440035_Bonus()

	Local oRetorno := OFDMSStruct():New()
	Local nTamCpoNF := 0

	oRetorno:AddSelect('','CPOSELBON', , .t.)

	oRetorno:AddFieldDictionary( "VQ1" , "VQ1_CODBON" , { {"cIdField" , "VQ1CODBON" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ1" , "VQ1_VLRTOT" , { {"cIdField" , "VQ1VLRTOT" } , { "lCanChange" , .t. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_NUMPED" , { {"cIdField" , "VQ0NUMPED" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_DATPED" , { {"cIdField" , "VQ0DATPED" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_CHASSI" , { {"cIdField" , "VQ0CHASSI" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_CODMAR" , { {"cIdField" , "VQ0CODMAR" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_MODVEI" , { {"cIdField" , "VQ0MODVEI" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_CORVEI" , { {"cIdField" , "VQ0CORVEI" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_FILATE" , { {"cIdField" , "VQ0FILATE" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ0" , "VQ0_NUMATE" , { {"cIdField" , "VQ0NUMATE" } , { "lCanChange" , .f. } } )

	nTamCpoNF := 1
	nTamCpoNF += GetSX3Cache("VV0_NUMNFI","X3_TAMANHO")
	nTamCpoNF += GetSX3Cache("VV0_SERNFI","X3_TAMANHO")

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0011 } ,; //"NF e Serie"
		{ "cTooltip" , STR0011 } ,;
		{ "cIdField" , "VV0NUMNFI" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 30 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0012 } ,; //"Recno VQ1"
		{ "cTooltip" , STR0012 } ,;
		{ "cIdField" , "RECNOVQ1" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 999999 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

Return oRetorno

Static Function VA1440095_ArquivoRetorno()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddSelect('','CPOSELRET', , .t.)

	oRetorno:AddFieldDictionary( "VQ4" , "VQ4_RETUID" , { {"cIdField" , "VQ4RETUID" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ4" , "VQ4_VLRTOT" , { {"cIdField" , "VQ4VLRTOT" } , { "lCanChange" , .f. } } )
	oRetorno:AddFieldDictionary( "VQ4" , "VQ4_CIACGC" , { {"cIdField" , "VQ4CIACGC" } , { "lCanChange" , .f. } } )

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0013 } ,; //"Referente as NF's"
		{ "cTooltip" , STR0013 } ,;
		{ "cIdField" , "REFNF" } ,;
		{ "cTipo"    , "C" } ,;
		{ "nTamanho" , 250 } ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})


Return oRetorno

Static Function VA1440085_BarraTotalizadora()

	Local oRetorno := OFDMSStruct():New()

	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0014 } ,; //"Bonus selecionados"
		{ "cTooltip" , STR0014 } ,;
		{ "cIdField" , "CPOTOTBON" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 20 } ,;
		{ "cPicture" , "@E 999,999,999.99"} ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})
	
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0015 } ,; //"Retorno selecionado"
		{ "cTooltip" , STR0015 } ,;
		{ "cIdField" , "CPOTOTRET" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 20 } ,;
		{ "cPicture" , "@E 999,999,999.99"} ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})
	
	oRetorno:AddField( { ;
		{ "cTitulo"  , STR0016 } ,; //"Divergência"
		{ "cTooltip" , STR0016 } ,;
		{ "cIdField" , "CPOTOTDIV" } ,;
		{ "cTipo"    , "N" } ,;
		{ "nTamanho" , 20 } ,;
		{ "cPicture" , "@E 999,999,999.99"} ,;
		{ "lCanChange" , .f. } ,;
		{ "lVirtual" , .t. } ;
	})

Return oRetorno

Static Function VA1440115_GetInformacaoNotaFiscal()

	Local aRetorno := Array(16)
	Local cFilVQ1   := xFilial("VQ1")

	cQuery := "SELECT SF2.F2_CLIENTE , SF2.F2_LOJA , SF2.F2_VEND1 , SF2.F2_COND , SD2.D2_COD "
	cQuery += " FROM " + RetSQLName("VQ1") + " VQ1 "
	cQuery += " JOIN " + RetSQLName("SF2") + " SF2 "
	cQuery += 		" ON  SF2.F2_FILIAL = VQ1.VQ1_FILNFI "
	cQuery += 		" AND SF2.F2_DOC = VQ1.VQ1_NUMNFI "
	cQuery += 		" AND SF2.F2_SERIE = VQ1.VQ1_SERNFI "
	cQuery += 		" AND SF2.D_E_L_E_T_=' ' "
	cQuery += " JOIN " + RetSQLName("SD2") + " SD2 "
	cQuery += 		" ON  SD2.D2_FILIAL = VQ1.VQ1_FILNFI "
	cQuery += 		" AND SD2.D2_DOC = VQ1.VQ1_NUMNFI "
	cQuery += 		" AND SD2.D2_SERIE = VQ1.VQ1_SERNFI "
	cQuery += 		" AND SD2.D_E_L_E_T_=' ' "
	cQuery += " WHERE VQ1.VQ1_FILIAL = '" + cFilVQ1 + "' "
	cQuery += 	" AND VQ1.VQ1_NUMNFI <> ' ' "
	cQuery += 	" AND VQ1.D_E_L_E_T_=' ' "
	cQuery += " ORDER BY VQ1.VQ1_CODIGO DESC"

	TcQuery cQuery New Alias "TMPNF"

	If !TMPNF->( Eof() )
		aRetorno[1] := TMPNF->F2_CLIENTE
		aRetorno[2] := TMPNF->F2_LOJA
		aRetorno[3] := TMPNF->F2_VEND1
		aRetorno[4] := TMPNF->F2_COND
		aRetorno[5] := TMPNF->D2_COD
	EndIf

	aRetorno[6] := 0
	aRetorno[7] := space(TamSX3("C5_NATUREZ")[1])
	aRetorno[8] := space(TamSX3("E1_PORTADO")[1])

	TMPNF->( DbCloseArea() )

	If !Empty(aRetorno[1])
		SA1->(DbSetOrder(1))
		SA1->( DbSeek( xFilial("SA1") + aRetorno[1] + aRetorno[2]))
		aRetorno[9] := SA1->A1_TIPO
	EndIf
	
	aRetorno[10] := "0"
	aRetorno[11] := ""
	aRetorno[12] := ""
	aRetorno[13] := ""
	aRetorno[14] := ""
	aRetorno[15] := ""
	aRetorno[16] := ""

Return aRetorno


Static Function VA1440135_GetBonusLiberados()

	Local aRetorno := {}

	Local cNamVQ1   := RetSQLName("VQ1")

	cQuery := "SELECT VQ1_CODBON , VQ1_VLRTOT , R_E_C_N_O_ RECVQ1, VQ1_CODIGO"
	cQuery += " FROM " + cNamVQ1 + " "
	cQuery += " WHERE VQ1_FILIAL = '" + xFilial("VQ1") + "' "
	//cQuery += 	" AND VQ1_CODIGO = '" + VQ0->VQ0_CODIGO + "' "
	cQuery += 	" AND VQ1_NUMNFI = ' ' "
	cQuery += 	" AND VQ1_STATUS = '2' "
	cQuery += 	" AND D_E_L_E_T_ = ' '"

	TcQuery cQuery New Alias "TMPVQ1"

	While !TMPVQ1->( Eof() )

		VQ0->( DbSetOrder(1) )
		VQ0->( DbSeek( xFilial("VQ0") + TMPVQ1->VQ1_CODIGO ) )

		cNUMNFI := ""
		If !Empty( VQ0->VQ0_FILATE + VQ0->VQ0_NUMATE )
			DbSelectArea("VV0")
			DbSetOrder(1)
			If DbSeek( VQ0->VQ0_FILATE + VQ0->VQ0_NUMATE ) .and. !Empty( VV0->VV0_NUMNFI + VV0->VV0_SERNFI )
				cNUMNFI := VV0->VV0_NUMNFI + "-" + FGX_UFSNF( VV0->VV0_SERNFI )
			EndIf
		EndIf

		aAdd(aRetorno,{ ;
				Len(aRetorno) + 1 ,;
				{ 	.f. ,;
					TMPVQ1->VQ1_CODBON ,;
					TMPVQ1->VQ1_VLRTOT ,;
					VQ0->VQ0_NUMPED ,;
					VQ0->VQ0_DATPED ,;
					VQ0->VQ0_CHASSI ,;
					VQ0->VQ0_CODMAR ,;
					VQ0->VQ0_MODVEI ,;
					VQ0->VQ0_CORVEI ,;
					VQ0->VQ0_FILATE ,;
					VQ0->VQ0_NUMATE ,;
					cNUMNFI ,;
					TMPVQ1->RECVQ1 ;
				};
		})
		TMPVQ1->( DbSkip() )

	EndDo

	TMPVQ1->( DbCloseArea() )

Return aRetorno



Static Function VA1440145_GetArquivosRetornados()

	Local aRetorno := {}
	Local cNamVQ1   := RetSQLName("VQ1")
	Local cFilVQ1  := xFilial("VQ1")
	
	Local cRetAux   := "INICIAL"
	Local cNFSAux   := ""

	cQuery := "SELECT VQ4.VQ4_RETUID , VQ4.VQ4_VLRTOT , VQ4.VQ4_NUMNFI , VQ4.VQ4_SERNFI , VQ4.VQ4_CIACGC "
	cQuery += " FROM " + RetSQLName( "VQ4" ) + " VQ4 "
	cQuery += " WHERE VQ4.VQ4_FILIAL = '" + xFilial("VQ4") + "' "
	cQuery += 	" AND VQ4.VQ4_TIPREG = '2' "
	cQuery += 	" AND VQ4.VQ4_TIPNFI = '2' "
	cQuery += 	" AND NOT EXISTS ( "
	cQuery += 						" SELECT VQ1_RETUID "
	cQuery += 						" FROM " + cNamVQ1 + " "
	cQuery += 						" WHERE   VQ1_FILIAL = '" + cFilVQ1 + "' "
	cQuery += 							" AND VQ1_RETUID = VQ4_RETUID "
	cQuery += 							" AND D_E_L_E_T_ = ' ' "
	cQuery += 					" ) "
	cQuery += 	" AND VQ4.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY VQ4.VQ4_RETUID , VQ4.VQ4_NUMNFI , VQ4.VQ4_SERNFI "

	TcQuery cQuery New Alias "TMPVQ4"

	While !TMPVQ4->( Eof() )

			If cRetAux <> TMPVQ4->VQ4_RETUID
				cRetAux := TMPVQ4->VQ4_RETUID
				aAdd( aRetorno , { ;
							Len(aRetorno) + 1 ,;
							{ 	.f. ,;
								cRetAux ,;
								TMPVQ4->VQ4_VLRTOT ,;
								TMPVQ4->VQ4_CIACGC ,;
								"" ;
							};
				})
			EndIf

			cNFSAux := Alltrim( TMPVQ4->VQ4_NUMNFI ) + "-" + FGX_UFSNF( TMPVQ4->VQ4_SERNFI )

			If( cNFSAux <> "-" ) .and. !( cNFSAux $ aRetorno[len(aRetorno),2,5] )
				aRetorno[len(aRetorno),2,5] += IIf(!Empty(aRetorno[len(aRetorno),2,5]),", ","")+cNFSAux
			EndIf

		TMPVQ4->( DbSkip() )

	EndDo

	TMPVQ4->( DbCloseArea() )

Return aRetorno


Function VA1440155_ValidaEstadoPrestacao()

	M->C5_ESTPRES := C5ESTPRES

Return .t.