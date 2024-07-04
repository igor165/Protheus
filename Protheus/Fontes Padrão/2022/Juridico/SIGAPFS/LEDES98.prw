#INCLUDE "LEDES98.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "VKEY.CH"

#DEFINE _DESCR_ 1
#DEFINE _TIPO_  2
#DEFINE _TAMAN_ 3
#DEFINE _DECIM_ 4
#DEFINE _CAMPO_ 5
#DEFINE _CONTE_ 6

#DEFINE EMP_EBI 1 // Identificador da critica Empresa E-billing
#DEFINE CAT_EBI 2 // Identificador da critica Categoria E-billing
#DEFINE FAS_EBI 3 // Identificador da critica Fase E-billing
#DEFINE TAF_EBI 4 // Identificador da critica Tarefa E-billing
#DEFINE TIP_EBI 5 // Identificador da critica Ativida; Tipo Despesa/Serviço Tabela E-billing
#DEFINE ESC_EBI 6 // Identificador da critica Escritório E-billing

//-------------------------------------------------------------------
/*/{Protheus.doc} LEDES98
Geração de arquivos E-billing 1998B e 1998BI.

@author SISJURI
@since 06/03/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Function LEDES98(lAutomato, cNArq, cDArq, cMoeEbi, c1998BI, cFat, cEscri)
Local oDlg         := Nil
Local oNArquivo    := Nil
Local oDArquivo    := Nil
Local oEscri       := Nil
Local oFatura      := Nil
Local oMoeda       := Nil
Local aButtons     := {}
Local cDArquivo    := ""
Local cNArquivo    := cEmpAnt + cFilAnt + __cUserId
Local oLayer       := FWLayer():New()
Local oCmb1998BI   := Nil
Local aCmb1998BI   := {STR0037, STR0036} //Não, Sim
Local cF3          := RetSXB()
Local aRetArq      := {.T., ""}

Default lAutomato  := .F.
Default cNArq      := ""
Default cDArq      := ""
Default cMoeEbi    := ""
Default c1998BI    := STR0037 //Não
Default cFat       := ""
Default cEscri     := Space(TamSx3('NXA_CESCR')[1])

cDArquivo := IIf(lAutomato,  "", GetTempPath(.T.))

If !lAutomato
	DEFINE MSDIALOG oDlg TITLE STR0001 FROM 010, 0 TO 250, 500 PIXEL //"Geração de Arquivo XML LEDES2000"

	oLayer:init(oDlg, .F.) //Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botao de fechar

	oLayer:addCollumn("MainColl", 100, .F.) //Cria as colunas do Layer

	oDlg:lEscClose := .F.

	oNArquivo := TJurPnlCampo():New(10,20,215,20, oLayer:GetColPanel( 'MainColl' ), STR0002,, {|| }, {|| cNArquivo := oNArquivo:GetValue() }, Space(50),,,) //"Nome do Arquivo:"
	oNArquivo:SetHelp(STR0039) //"Indique o nome do arquivo a ser gerado."
	oDArquivo := TJurPnlCampo():New(37,20,130,20, oLayer:GetColPanel( 'MainColl' ), STR0003,, {|| }, {|| cDArquivo := oDArquivo:GetValue() }, Space(100),,,) //"Informe o caminho"
	oDArquivo:SetHelp(STR0040) //"Indique o caminho para geração do arquivo."

	@ 68, 170 Say STR0038 Size 080, 010 Color CLR_BLUE Pixel Of oDlg //"Internacional (1998BI)?"
	oCmb1998BI := TJurCmbBox():New(47,170,60,11, oLayer:GetColPanel( 'MainColl' ), aCmb1998BI, {||}) //Sim;Não

	oEscri    := TJurPnlCampo():New(64,20,40,20, oLayer:GetColPanel( 'MainColl' ), STR0004, 'NS7_COD',{|| }, {|| cEscri := oEscri:GetValue()},,,, 'NS7')      //"Cod.Escrit.:"
	oEscri:SetValid( {|| Empty(oEscri:GetValue()) .Or. ExistCpo('NS7', oEscri:GetValue(), 1) .And. JEBillMoe(oEscri, oFatura, oMoeda) } )
	oEscri:SetHelp(STR0041) //"Código do escritório da fatura para a qual será gerado o arquivo e-billing."

	oFatura := TJurPnlCampo():New(64,90,60,20, oLayer:GetColPanel( 'MainColl' ), STR0005, 'NXA_COD',{|| },{|| },,,, cF3) //"Fatura:"
	oFatura:SetValid( {|| Empty(oFatura:GetValue()) .Or. (ExistCpo('NXA', oEscri:GetValue() + oFatura:GetValue(), 1) .And. JEBillFatCanc(oEscri, oFatura) .And. JEBILLMOE(oEscri, oFatura, oMoeda)) } )
	oFatura:oCampo:bWhen := {|| !Empty(oEscri:GetValue())}
	oFatura:SetHelp(STR0042) //"Código da fatura para a qual será gerado o arquivo e-billing."
	oFatura:Refresh()

	oMoeda := TJurPnlCampo():New(64,180,40,20, oLayer:GetColPanel( 'MainColl' ), STR0035, 'CTO_MOEDA', {|| },{|| },,,, 'CTO') //"Moeda E-billing:"		
	oMoeda:SetHelp(STR0043) //"Código da moeda com a qual será gerado o arquivo e-billing."
	oMoeda:SetValid( {|| Empty(oMoeda:GetValue()) .Or. ExistCpo('CTO', oMoeda:GetValue(), 1) } )

	oBtDir := TButton():New( 47,150,"...", oLayer:GetColPanel( 'MainColl' ), {||oDArquivo:SetValue(AllTrim(cGetFile("*.*", STR0008, 0,, .T., GETF_RETDIRECTORY+GETF_LOCALHARD+GETF_NETWORKDRIVE)))},10,10,,,,.T.)//"Selecione o Diretorio p/ gerar o Arquivo"

	ACTIVATE MSDIALOG oDlg CENTER ON INIT EnchoiceBar(oDlg, {|| Iif(!Empty(oEscri:GetValue()) .And. !Empty(oFatura:GetValue()) .And. !Empty(oMoeda:GetValue()),;
														MsgRun( STR0009, STR0010, {|| aRetArq := RunQuery(oFatura:GetValue(), cEscri, oMoeda:GetValue(), oNArquivo:GetValue(), oDArquivo:GetValue(), oCmb1998BI:cValor, lAutomato)}),;
														Alert(STR0006, STR0007) )}, {||oDlg:End()},, aButtons) //"Processando arquivo TXT"###"Aguarde..."
ElseIf lAutomato
	aRetArq := RunQuery(cFat, cEscri, cMoeEbi, cNArq, cDArq, c1998BI, lAutomato)
EndIf

Return (aRetArq)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} MontaCabec()
Rotina para fazer a  montagem dos cabeçalhos do arquivo e-billing.

@Params l1998BI   - Indica se foi solicitada a geração no modelo 1998BI
@Params aCabecHon - Estrutura de campos relacionados a timesheets
@Params aCabecDes - Estrutura de campos relacionados a despesas
@Params aCabecTab - Estrutura de campos relacionados aos tabelados
@Params aCabecAju - Estrutura de campos relacionados a ajustes (acréscimos, descontos, arredondamento)
@Params aCabecImp - Estrutura de campos relacionados aos impostos
@Params aCabecFix - Estrutura de campos relacionados as parcelas fixas

@author Cristina Cintra Santos
@since 18/04/2016
@version 1.0
/*/
//----------------------------------------------------------------------------
Static Function MontaCabec(l1998BI, aCabecHon, aCabecDes, aCabecTab, aCabecAju, aCabecImp, aCabecFix)
Local lPoNumber   := .F.
Local lCodISO     := .F.
Local lLedes98Es  := ExistBlock("Ledes98Es")
Local aCabecHonC  := {}
Local aCabecDesC  := {}
Local aCabecTabC  := {}
Local aCabecAjuC  := {}
Local aCabecImpC  := {}
Local aCabecFixC  := {}
Local cCpoGrossH  := IIf(NXA->(ColumnPos("NXA_VGROSH")) > 0, "+NXA_VGROSH", "") // @12.1.2310

Local aRetPE      := {}
Local nC          := 0
Default l1998BI   := .F.

aCabecHon  := {}
aCabecDes  := {}
aCabecTab  := {}
aCabecAju  := {}
aCabecImp  := {}
aCabecFix  := {}

//CABEC PARA FIXO
//               Tipo = F		representa uma Formula com retorno numerico
//               Tipo = " " 	representa uma Expressao com retorno Alfa
//
//                 Cabecalho                      Tipo,   Tam, Deci     ,Campos         ,Conteudo Especificos
AADD( aCabecFix, { "INVOICE_DATE"                , "C",    08, 00       ,"NXA_DTEMI" , ""                     })
AADD( aCabecFix, { "INVOICE_NUMBER"              , "C",    20, 00       ,"NXA_COD"   , ""                     })
AADD( aCabecFix, { "CLIENT_ID"                   , "C",    20, 00       ,"NXA_CCLIEN", "NXA_CCLIEN||NXA_CLOJA"})
AADD( aCabecFix, { "LAW_FIRM_MATTER_ID"          , " ",    20, 00       ,""          , "''"                   })
AADD( aCabecFix, { "INVOICE_TOTAL"               , "F",    12, 04       ,"EXP2"      , "(NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ")"})
AADD( aCabecFix, { "BILLING_START_DATE"          , " ",    08, 00       ,"EXP15"     , "''"                   })
AADD( aCabecFix, { "BILLING_END_DATE"            , " ",    08, 00       ,"EXP16"     , "''"                   })
AADD( aCabecFix, { "INVOICE_DESCRIPTION"         , "C", 15360, 00       ,"NT1_DESCRI", ""                     })
AADD( aCabecFix, { "LINE_ITEM_NUMBER"            , " ",    20, 00       ,"EXP6"      , "''"                   })
AADD( aCabecFix, { "EXP/FEE/INV_ADJ_TYPE"        , " ",    02, 00       ,"TIPO"      , "'F'"                  })
AADD( aCabecFix, { "LINE_ITEM_NUMBER_OF_UNITS"   , " ",    10, 04       ,"UNIT_NUMB" , "'1'"                  })
AADD( aCabecFix, { "LINE_ITEM_ADJUSTMENT_AMOUNT" , " ",    10, 04       ,"EXP4"      , "'0'"                  })
AADD( aCabecFix, { "LINE_ITEM_TOTAL"             , "N",    10, 04       ,"NT1_VALORA", ""                     })
AADD( aCabecFix, { "LINE_ITEM_DATE"              , "C",    08, 00       ,"NT1_DATAFI", ""                     })
AADD( aCabecFix, { "LINE_ITEM_TASK_CODE"         , " ",    20, 00       ,"EXP7"      , "''"                   })
AADD( aCabecFix, { "LINE_ITEM_EXPENSE_CODE"      , " ",    20, 00       ,"EXP5"      , "''"                   })
AADD( aCabecFix, { "LINE_ITEM_ACTIVITY_CODE"     , " ",    20, 00       ,"EXP8"      , "''"                   })
AADD( aCabecFix, { "TIMEKEEPER_ID"               , "C",    20, 00       ,"RD0_SIGLA" , ""                     })
AADD( aCabecFix, { "LINE_ITEM_DESCRIPTION"       , "C", 15360, 00       ,"NT1_DESCRI", ""                     })
AADD( aCabecFix, { "LAW_FIRM_ID"                 , "C",    20, 00       ,"NTQ_CODIGO", ""                     })
AADD( aCabecFix, { "LINE_ITEM_UNIT_COST"         , "N",    10, 04       ,"NT1_VALORA", ""                     })
AADD( aCabecFix, { "TIMEKEEPER_NAME"             , "C",    30, 00       ,"RD0_NOME"  , "RD0_NOME"             })
AADD( aCabecFix, { "TIMEKEEPER_CLASSIFICATION"   , "C",    10, 00       ,"NR2_DESC"  , ""                     })
AADD( aCabecFix, { "CLIENT_MATTER_ID"            , " ",    20, 00       ,""          , "''"                   })

If l1998BI //Campos do 1998BI
	If lPoNumber := (NXA->( FieldPos( "NXA_PONUMB" )) > 0 )
		AADD( aCabecFix, { "PO_NUMBER"                   , "C",    05, 00		,"NXA_PONUMB" , ""							}	)	
	Else
		AADD( aCabecFix, { "PO_NUMBER"                   , " ",    05, 00		,"EXP17"      , "''"							}	)
	EndIf
	AADD( aCabecFix, { "CLIENT_TAX_ID"               , "C",    20, 00		,"NXA_CGCCPF" , ""								}	)
	AADD( aCabecFix, { "MATTER_NAME"                 , " ",   255, 00		,"EXP38"      , "''"								}	)
	AADD( aCabecFix, { "INVOICE_TAX_TOTAL"           , " ",    12, 04		,"EXP19"      , "'0'"							}	)
	AADD( aCabecFix, { "INVOICE_NET_TOTAL"           , "F",    12, 04		,"EXP20"      , "(NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ")"})
	If lCodISO := (CTO->( FieldPos( "CTO_CODISO" )) > 0 )
		AADD( aCabecFix, { "INVOICE_CURRENCY"            , "C",    03, 00		,"CTO_CODISO" , ""								}	)
	Else
		AADD( aCabecFix, { "INVOICE_CURRENCY"            , " ",    03, 00		,"EXP35" , "''"								}	)
	EndIf
	AADD( aCabecFix, { "TIMEKEEPER_LAST_NAME"        , " ",    30, 00		,"EXP21"      , "RD0_NOME"								}	)
	AADD( aCabecFix, { "TIMEKEEPER_FIRST_NAME"       , " ",    30, 00		,"EXP22"      , "RD0_NOME"								}	)
	AADD( aCabecFix, { "ACCOUNT_TYPE"                , " ",    01, 00		,"EXP23"      , "'O'"							}	)
	AADD( aCabecFix, { "LAW_FIRM_NAME"               , "C",    60, 00		,"NS7_NOME"   , ""								}	)
	AADD( aCabecFix, { "LAW_FIRM_ADDRESS_1"          , " ",    60, 00		,"EXP24"      , "NS7_END||NS7_BAIRRO"			}	)
	AADD( aCabecFix, { "LAW_FIRM_ADDRESS_2"          , " ",    60, 00		,"EXP25"      , "''"								}	)
	AADD( aCabecFix, { "LAW_FIRM_CITY"               , " ",    40, 00		,"EXP26"      , "NS7_ESTADO||NS7_CMUNIC"		}	)
	AADD( aCabecFix, { "LAW_FIRM_STATEorREGION"      , " ",    40, 00		,"EXP27"      , "NS7_ESTADO"					}	)
	AADD( aCabecFix, { "LAW_FIRM_POSTCODE"           , "C",    20, 00		,"NS7_CEP"    , ""								}	)
	AADD( aCabecFix, { "LAW_FIRM_COUNTRY"            , " ",    03, 00		,"EXP36"      , "NS7_CPAIS"						}	)
	AADD( aCabecFix, { "CLIENT_NAME"                 , "C",    60, 00		,"NXA_RAZSOC" , ""								}	)
	AADD( aCabecFix, { "CLIENT_ADDRESS_1"            , " ",    60, 00		,"EXP28"      , "NXA_LOGRAD||NXA_BAIRRO"		}	)
	AADD( aCabecFix, { "CLIENT_ADDRESS_2"            , " ",    60, 00		,"EXP29"      , "''"								}	)
	AADD( aCabecFix, { "CLIENT_CITY"                 , "C",    40, 00		,"NXA_CIDADE" , ""								}	)
	AADD( aCabecFix, { "CLIENT_STATEorREGION"        , "C",    40, 00		,"NXA_ESTADO" , ""								}	)
	AADD( aCabecFix, { "CLIENT_POSTCODE"             , "C",    20, 00		,"NXA_CEP"    , ""								}	)
	AADD( aCabecFix, { "CLIENT_COUNTRY"              , " ",    03, 00		,"EXP37"      , "NXA_CCLIEN||NXA_CLOJA"		}	)
	AADD( aCabecFix, { "LINE_ITEM_TAX_RATE"          , " ",    00, 04		,"EXP30"      , "'0'"							}	)
	AADD( aCabecFix, { "LINE_ITEM_TAX_TOTAL"         , " ",    10, 04		,"EXP31"      , "'0'"							}	)
	AADD( aCabecFix, { "LINE_ITEM_TAX_TYPE"          , " ",    20, 00		,"EXP32"      , "''"								}	)
	AADD( aCabecFix, { "INVOICE_REPORTED_TAX_TOTAL"  , " ",    12, 04		,"EXP33"      , "''"								}	)
	AADD( aCabecFix, { "INVOICE_TAX_CURRENCY"        , " ",    03, 00		,"EXP34"      , "''"								}	)
EndIf

//CABEC PARA HONORARIOS
//               Tipo = F		representa uma Formula com retorno numerico  
//               Tipo = " " 	representa uma Expressao com retorno Alfa
//
//                 Cabecalho                      Tipo,   Tam, Deci     ,Campos         ,Conteudo Especificos
AADD( aCabecHon, { "INVOICE_DATE"                , "C",    08, 00		,"NXA_DTEMI"	, ""									}	)
AADD( aCabecHon, { "INVOICE_NUMBER"              , "C",    20, 00		,"NXA_COD"		, ""									}	)
AADD( aCabecHon, { "CLIENT_ID"                   , "C",    20, 00		,"NXA_CCLIEN"	, "NXA_CCLIEN||NXA_CLOJA"				}	)
AADD( aCabecHon, { "LAW_FIRM_MATTER_ID"          , "C",    20, 00		,"NVE_MATTER"	, ""									}	)
AADD( aCabecHon, { "INVOICE_TOTAL"               , "F",    12, 04		,"EXP2"       , "(NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ")"	}	)
AADD( aCabecHon, { "BILLING_START_DATE"          , " ",    08, 00		,"EXP15"      , "''"								}	)
AADD( aCabecHon, { "BILLING_END_DATE"            , " ",    08, 00		,"EXP16"      , "''"								}	)
AADD( aCabecHon, { "INVOICE_DESCRIPTION"         , " ", 15360, 00		,"EXP3"			, "NUE_CCLIEN||NUE_CLOJA||NUE_CCASO"		}	)
AADD( aCabecHon, { "LINE_ITEM_NUMBER"            , " ",    20, 00		,"EXP6"			, "''"									}	)
AADD( aCabecHon, { "EXP/FEE/INV_ADJ_TYPE"        , " ",    02, 00		,"TIPO"			, "'F'"									}	)
AADD( aCabecHon, { "LINE_ITEM_NUMBER_OF_UNITS"   , "F",    10, 04		,"NUE_TEMPOR" , "ROUND(NUE_TEMPOR * (NXA_PERFAT / 100), 4)" }	)
AADD( aCabecHon, { "LINE_ITEM_ADJUSTMENT_AMOUNT" , " ",    10, 04		,"EXP4"			, "'0'"									}	)
AADD( aCabecHon, { "LINE_ITEM_TOTAL"             , "F",    10, 04		,"NUE_VALOR"  , "(NUE_VALOR * (NXA_PERFAT / 100))"		}	) //Fazer o Round depois para não perder precisão
AADD( aCabecHon, { "LINE_ITEM_DATE"              , "C",    08, 00		,"NUE_DATATS"	, ""									}	)
AADD( aCabecHon, { "LINE_ITEM_TASK_CODE"         , "C",    20, 00		,"NRZ_CTAREF"	, ""									}	)   //chamado 3966 NRY_CFASE codigo da tarefa
AADD( aCabecHon, { "LINE_ITEM_EXPENSE_CODE"      , " ",    20, 00		,"EXP5"			, "''"									}	)
AADD( aCabecHon, { "LINE_ITEM_ACTIVITY_CODE"     , "C",    20, 00		,"NS0_CATIV"	, ""									}	)
AADD( aCabecHon, { "TIMEKEEPER_ID"               , "C",    20, 00		,"NUE_CPART2"	, ""									}	)
AADD( aCabecHon, { "LINE_ITEM_DESCRIPTION"       , "C", 15360, 00		,"NUE_DESC"		, ""									}	)	
AADD( aCabecHon, { "LAW_FIRM_ID"                 , "C",    20, 00		,"NTQ_CODIGO"	, ""									}	)
AADD( aCabecHon, { "LINE_ITEM_UNIT_COST"         , "F",    10, 04		,"NUE_VALORH"   , "NUE_VALORH"							}	)
AADD( aCabecHon, { "TIMEKEEPER_NAME"             , "C",    30, 00		,"RD0_NOME"		, "RD0_NOME"							}	)
AADD( aCabecHon, { "TIMEKEEPER_CLASSIFICATION"   , "C",    10, 00		,"NRV_CCATE"	, ""									}	)
AADD( aCabecHon, { "CLIENT_MATTER_ID"            , "C",    20, 00		,"NVE_CPGEBI"   , ""									}	) 

If l1998BI //Campos do 1998BI
	If lPoNumber := (NXA->( FieldPos( "NXA_PONUMB" )) > 0 )
		AADD( aCabecHon, { "PO_NUMBER"                   , "C",    05, 00		,"NXA_PONUMB" , ""							}	)	
	Else
		AADD( aCabecHon, { "PO_NUMBER"                   , " ",    05, 00		,"EXP17"      , "''"							}	)
	EndIf
	AADD( aCabecHon, { "CLIENT_TAX_ID"               , "C",    20, 00		,"NXA_CGCCPF" , ""								}	)
	AADD( aCabecHon, { "MATTER_NAME"                 , " ",   255, 00		,"EXP18"      , "''"								}	)
	AADD( aCabecHon, { "INVOICE_TAX_TOTAL"           , " ",    12, 04		,"EXP19"      , "'0'"							}	)
	AADD( aCabecHon, { "INVOICE_NET_TOTAL"           , "F",    12, 04		,"EXP20"      , "(NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ")"							}	)
	If lCodISO := (CTO->( FieldPos( "CTO_CODISO" )) > 0 )
		AADD( aCabecHon, { "INVOICE_CURRENCY"            , "C",    03, 00		,"CTO_CODISO" , ""								}	)
	Else
		AADD( aCabecHon, { "INVOICE_CURRENCY"            , " ",    03, 00		,"EXP35" , "''"								}	)
	EndIf
	AADD( aCabecHon, { "TIMEKEEPER_LAST_NAME"        , " ",    30, 00		,"EXP21"      , "RD0_NOME"								}	)
	AADD( aCabecHon, { "TIMEKEEPER_FIRST_NAME"       , " ",    30, 00		,"EXP22"      , "RD0_NOME"								}	)
	AADD( aCabecHon, { "ACCOUNT_TYPE"                , " ",    01, 00		,"EXP23"      , "'O'"							}	)
	AADD( aCabecHon, { "LAW_FIRM_NAME"               , "C",    60, 00		,"NS7_NOME"   , ""								}	)
	AADD( aCabecHon, { "LAW_FIRM_ADDRESS_1"          , " ",    60, 00		,"EXP24"      , "NS7_END||NS7_BAIRRO"			}	)
	AADD( aCabecHon, { "LAW_FIRM_ADDRESS_2"          , " ",    60, 00		,"EXP25"      , "''"								}	)
	AADD( aCabecHon, { "LAW_FIRM_CITY"               , " ",    40, 00		,"EXP26"      , "NS7_ESTADO||NS7_CMUNIC"		}	)
	AADD( aCabecHon, { "LAW_FIRM_STATEorREGION"      , " ",    40, 00		,"EXP27"      , "NS7_ESTADO"					}	)
	AADD( aCabecHon, { "LAW_FIRM_POSTCODE"           , "C",    20, 00		,"NS7_CEP"    , ""								}	)
	AADD( aCabecHon, { "LAW_FIRM_COUNTRY"            , " ",    03, 00		,"EXP36"      , "NS7_CPAIS"						}	)
	AADD( aCabecHon, { "CLIENT_NAME"                 , "C",    60, 00		,"NXA_RAZSOC" , ""								}	)
	AADD( aCabecHon, { "CLIENT_ADDRESS_1"            , " ",    60, 00		,"EXP28"      , "NXA_LOGRAD||NXA_BAIRRO"		}	)
	AADD( aCabecHon, { "CLIENT_ADDRESS_2"            , " ",    60, 00		,"EXP29"      , "''"								}	)
	AADD( aCabecHon, { "CLIENT_CITY"                 , "C",    40, 00		,"NXA_CIDADE" , ""								}	)
	AADD( aCabecHon, { "CLIENT_STATEorREGION"        , "C",    40, 00		,"NXA_ESTADO" , ""								}	)
	AADD( aCabecHon, { "CLIENT_POSTCODE"             , "C",    20, 00		,"NXA_CEP"    , ""								}	)
	AADD( aCabecHon, { "CLIENT_COUNTRY"              , " ",    03, 00		,"EXP37"      , "NXA_CCLIEN||NXA_CLOJA"		}	)
	AADD( aCabecHon, { "LINE_ITEM_TAX_RATE"          , " ",    00, 04		,"EXP30"      , "'0'"							}	)
	AADD( aCabecHon, { "LINE_ITEM_TAX_TOTAL"         , " ",    10, 04		,"EXP31"      , "'0'"							}	)
	AADD( aCabecHon, { "LINE_ITEM_TAX_TYPE"          , " ",    20, 00		,"EXP32"      , "''"								}	)
	AADD( aCabecHon, { "INVOICE_REPORTED_TAX_TOTAL"  , " ",    12, 04		,"EXP33"      , "''"								}	)
	AADD( aCabecHon, { "INVOICE_TAX_CURRENCY"        , " ",    03, 00		,"EXP34"      , "''"								}	)
EndIf

//CABEC PARA DESPESAS 
//               Tipo = F		representa uma Formula com retorno numerico 
//               Tipo = " "		representa uma Expressao com retorno Alfa
//
//                 Cabecalho                      Tipo,     Tam,Deci,Campos,       Conteudo Especificos
AADD( aCabecDes, { "INVOICE_DATE"                , "C",      08,00	,"NXA_DTEMI"  , ""				}	)
AADD( aCabecDes, { "INVOICE_NUMBER"              , "C",      20,00	,"NXA_COD"    , ""				}	)
AADD( aCabecDes, { "CLIENT_ID"                   , "C",      20,00	,"NXA_CCLIEN" , "NXA_CCLIEN||NXA_CLOJA"	}	)
AADD( aCabecDes, { "LAW_FIRM_MATTER_ID"          , "C",      20,00	,"NVE_MATTER" , ""				}	)
AADD( aCabecDes, { "INVOICE_TOTAL"               , "F",      12,04	,"EXP2"       , "(NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ")"	}	)
AADD( aCabecDes, { "BILLING_START_DATE"          , " ",      08,00	,"EXP15"      , "''"			}	)
AADD( aCabecDes, { "BILLING_END_DATE"            , " ",      08,00	,"EXP16"      , "''"			}	)
AADD( aCabecDes, { "INVOICE_DESCRIPTION"         , " ",   15360,00	,"EXP3"       , "NVY_CCLIEN||NVY_CLOJA||NVY_CCASO" }	)
AADD( aCabecDes, { "LINE_ITEM_NUMBER"            , " ",      20,00	,"EXP4"       , "''"				}	)
AADD( aCabecDes, { "EXP/FEE/INV_ADJ_TYPE"        , " ",      02,00	,"TIPO"       , "'E'"			}	)
AADD( aCabecDes, { "LINE_ITEM_NUMBER_OF_UNITS"   , "F",      10,04	,"NVY_QTD"    , "NVY_QTD"		}	)
AADD( aCabecDes, { "LINE_ITEM_ADJUSTMENT_AMOUNT" , " ",      10,04	,"EXP5"       , "'0'"			}	)
AADD( aCabecDes, { "LINE_ITEM_TOTAL"             , "F",      10,04	,"EXP6"       , "(NVY_VALOR * (NXA_PERFAT / 100))"		}	) //Fazer o Round depois para não perder precisão
AADD( aCabecDes, { "LINE_ITEM_DATE"              , "C",      08,00	,"NVY_DATA "  , ""				}	)
AADD( aCabecDes, { "LINE_ITEM_TASK_CODE"         , " ",      20,00	,"EXP7"       , "''"			}	)
AADD( aCabecDes, { "LINE_ITEM_EXPENSE_CODE"      , "C",      20,00	,"NS3_CDESP"  , ""				}	)
AADD( aCabecDes, { "LINE_ITEM_ACTIVITY_CODE"     , " ",      20,00	,"EXP8"       , "''"			}	)
AADD( aCabecDes, { "TIMEKEEPER_ID"               , "C",      20,00	,"NVY_CPART"  , ""				}	)
AADD( aCabecDes, { "LINE_ITEM_DESCRIPTION"       , "C",   15360,00	,"NVY_DESCRI" , ""				}	)
AADD( aCabecDes, { "LAW_FIRM_ID"                 , "C",      20,00	,"NTQ_CODIGO" , ""				}	)
AADD( aCabecDes, { "LINE_ITEM_UNIT_COST"         , "F",      10,04	,"EXP9"       , "((NVY_VALOR * (NXA_PERFAT / 100)) / NVY_QTD)" } )
AADD( aCabecDes, { "TIMEKEEPER_NAME"             , "C",      30,00	,"RD0_NOME"   , "RD0_NOME"		}	)
AADD( aCabecDes, { "TIMEKEEPER_CLASSIFICATION"   , " ",      10,00	,"EXP13"  	  , "''" 			}	)
AADD( aCabecDes, { "CLIENT_MATTER_ID"            , "C",      20,00	,"NVE_CPGEBI" , ""				}	)

If l1998BI //Campos do 1998BI
	If lPoNumber
		AADD( aCabecDes, { "PO_NUMBER"                   , "C",    05, 00		,"NXA_PONUMB" , ""							}	)	
	Else	
		AADD( aCabecDes, { "PO_NUMBER"                   , " ",    05, 00		,"EXP17"      , "''"							}	)
	EndIf
	AADD( aCabecDes, { "CLIENT_TAX_ID"               , "C",    20, 00		,"NXA_CGCCPF" , ""								}	)
	AADD( aCabecDes, { "MATTER_NAME"                 , " ",   255, 00		,"EXP18"      , "''"								}	)
	AADD( aCabecDes, { "INVOICE_TAX_TOTAL"           , " ",    12, 04		,"EXP19"      , "'0'"							}	)
	AADD( aCabecDes, { "INVOICE_NET_TOTAL"           , "F",    12, 04		,"EXP20"      , "(NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ")"							}	)
	If lCodISO
		AADD( aCabecDes, { "INVOICE_CURRENCY"            , "C",    03, 00		,"CTO_CODISO" , ""								}	)
	Else
		AADD( aCabecDes, { "INVOICE_CURRENCY"            , " ",    03, 00		,"EXP35" , "''"								}	)
	EndIf
	AADD( aCabecDes, { "TIMEKEEPER_LAST_NAME"        , " ",    30, 00		,"EXP21"      , "RD0_NOME"								}	)
	AADD( aCabecDes, { "TIMEKEEPER_FIRST_NAME"       , " ",    30, 00		,"EXP22"      , "RD0_NOME"								}	)
	AADD( aCabecDes, { "ACCOUNT_TYPE"                , " ",    01, 00		,"EXP23"      , "'O'"							}	)
	AADD( aCabecDes, { "LAW_FIRM_NAME"               , "C",    60, 00		,"NS7_NOME"   , ""								}	)
	AADD( aCabecDes, { "LAW_FIRM_ADDRESS_1"          , " ",    60, 00		,"EXP24"      , "NS7_END||NS7_BAIRRO"			}	)
	AADD( aCabecDes, { "LAW_FIRM_ADDRESS_2"          , " ",    60, 00		,"EXP25"      , "''"								}	)
	AADD( aCabecDes, { "LAW_FIRM_CITY"               , " ",    40, 00		,"EXP26"      , "NS7_ESTADO||NS7_CMUNIC"		}	)
	AADD( aCabecDes, { "LAW_FIRM_STATEorREGION"      , " ",    40, 00		,"EXP27"      , "NS7_ESTADO"					}	)
	AADD( aCabecDes, { "LAW_FIRM_POSTCODE"           , "C",    20, 00		,"NS7_CEP"    , ""								}	)
	AADD( aCabecDes, { "LAW_FIRM_COUNTRY"            , " ",    03, 00		,"EXP36"      , "NS7_CPAIS"						}	)
	AADD( aCabecDes, { "CLIENT_NAME"                 , "C",    60, 00		,"NXA_RAZSOC" , ""								}	)
	AADD( aCabecDes, { "CLIENT_ADDRESS_1"            , " ",    60, 00		,"EXP28"      , "NXA_LOGRAD||NXA_BAIRRO"		}	)
	AADD( aCabecDes, { "CLIENT_ADDRESS_2"            , " ",    60, 00		,"EXP29"      , "''"								}	)
	AADD( aCabecDes, { "CLIENT_CITY"                 , "C",    40, 00		,"NXA_CIDADE" , ""								}	)
	AADD( aCabecDes, { "CLIENT_STATEorREGION"        , "C",    40, 00		,"NXA_ESTADO" , ""								}	)
	AADD( aCabecDes, { "CLIENT_POSTCODE"             , "C",    20, 00		,"NXA_CEP"    , ""								}	)
	AADD( aCabecDes, { "CLIENT_COUNTRY"              , " ",    03, 00		,"EXP37"      , "NXA_CCLIEN||NXA_CLOJA"		}	)
	AADD( aCabecDes, { "LINE_ITEM_TAX_RATE"          , " ",    00, 04		,"EXP30"      , "'0'"							}	)
	AADD( aCabecDes, { "LINE_ITEM_TAX_TOTAL"         , " ",    10, 04		,"EXP31"      , "'0'"							}	)
	AADD( aCabecDes, { "LINE_ITEM_TAX_TYPE"          , " ",    20, 00		,"EXP32"      , "''"								}	)
	AADD( aCabecDes, { "INVOICE_REPORTED_TAX_TOTAL"  , " ",    12, 04		,"EXP33"      , "''"								}	)
	AADD( aCabecDes, { "INVOICE_TAX_CURRENCY"        , " ",    03, 00		,"EXP34"      , "''"								}	)
EndIf

//CABEC PARA SERVICOS TABELADOS 
//               Tipo = F		representa uma Formula com retorno numerico 
//               Tipo = " "		representa uma Expressao com retorno Alfa
//
//                 Cabecalho,                     Tipo,     Tam,Deci Campos        Conteudo Especificos 
AADD( aCabecTab, { "INVOICE_DATE"                , "C",      08,00	,"NXA_DTEMI"  , ""					}	)
AADD( aCabecTab, { "INVOICE_NUMBER"              , "C",      20,00	,"NXA_COD"    , ""					}	)
AADD( aCabecTab, { "CLIENT_ID"                   , "C",      20,00	,"NXA_CCLIEN" , "NXA_CCLIEN||NXA_CLOJA"	}	)
AADD( aCabecTab, { "LAW_FIRM_MATTER_ID"          , "C",      20,00	,"NVE_MATTER" , ""					}	)
AADD( aCabecTab, { "INVOICE_TOTAL"               , "F",      12,04	,"EXP2"       , "(NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ")"	}	)
AADD( aCabecTab, { "BILLING_START_DATE"          , " ",      08,00	,"EXP15"      , "''"				}	)
AADD( aCabecTab, { "BILLING_END_DATE"            , " ",      08,00	,"EXP16"      , "''"				}	)
AADD( aCabecTab, { "INVOICE_DESCRIPTION"         , " ",   15360,00	,"EXP3"       , "NV4_CCLIEN||NV4_CLOJA||NV4_CCASO" }	)
AADD( aCabecTab, { "LINE_ITEM_NUMBER"            , " ",      20,00	,"EXP4"       , "''"				}	)
AADD( aCabecTab, { "EXP/FEE/INV_ADJ_TYPE"        , " ",      02,00	,"TIPO"       , "'E'"				}	)
AADD( aCabecTab, { "LINE_ITEM_NUMBER_OF_UNITS"   , "F",      10,04	,"NV4_QUANT"  , "NV4_QUANT"			}	)
AADD( aCabecTab, { "LINE_ITEM_ADJUSTMENT_AMOUNT" , " ",      10,04	,"EXP5"       , "'0'"				}	)
AADD( aCabecTab, { "LINE_ITEM_TOTAL"             , "F",      10,04	,"EXP6"       , "(NV4_VLHFAT * (NXA_PERFAT / 100))"		}	)
AADD( aCabecTab, { "LINE_ITEM_DATE"              , "C",      08,00	,"NV4_DTLANC" , ""					}	)
AADD( aCabecTab, { "LINE_ITEM_TASK_CODE"         , " ",      20,00	,"EXP7"       , "''"				}	)
AADD( aCabecTab, { "LINE_ITEM_EXPENSE_CODE"      , "C",      20,00	,"NXN_CSRVTB" , ""					}	)
AADD( aCabecTab, { "LINE_ITEM_ACTIVITY_CODE"     , " ",      20,00	,"EXP8"       , "''"				}	)
AADD( aCabecTab, { "TIMEKEEPER_ID"               , "C",      20,00	,"NV4_CPART"  , ""					}	)
AADD( aCabecTab, { "LINE_ITEM_DESCRIPTION"       , "C",   15360,00	,"NV4_DESCRI" , ""					}	)
AADD( aCabecTab, { "LAW_FIRM_ID"                 , "C",      20,00	,"NTQ_CODIGO" , ""					}	)
AADD( aCabecTab, { "LINE_ITEM_UNIT_COST"         , "F",      10,04	,"EXP9"       , "((NV4_VLHFAT * (NXA_PERFAT / 100)) / NV4_QUANT)"		}	)
AADD( aCabecTab, { "TIMEKEEPER_NAME"             , "C",      30,00	,"RD0_NOME"   , "RD0_NOME"			}	)
AADD( aCabecTab, { "TIMEKEEPER_CLASSIFICATION"   , " ",      10,00	,"EXP13"  	  , "''" 				}	)
AADD( aCabecTab, { "CLIENT_MATTER_ID"            , "C",      20,00	,"NVE_CPGEBI" , ""					}	)

If l1998BI //Campos do 1998BI
	If lPoNumber
		AADD( aCabecTab, { "PO_NUMBER"                   , "C",    05, 00		,"NXA_PONUMB" , ""							}	)	
	Else	
		AADD( aCabecTab, { "PO_NUMBER"                   , " ",    05, 00		,"EXP17"      , "''"							}	)
	EndIf
	AADD( aCabecTab, { "CLIENT_TAX_ID"               , "C",    20, 00		,"NXA_CGCCPF" , ""								}	)
	AADD( aCabecTab, { "MATTER_NAME"                 , " ",   255, 00		,"EXP18"      , "''"								}	)
	AADD( aCabecTab, { "INVOICE_TAX_TOTAL"           , " ",    12, 04		,"EXP19"      , "'0'"							}	)
	AADD( aCabecTab, { "INVOICE_NET_TOTAL"           , "F",    12, 04		,"EXP20"      , "(NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ")"}	)
	If lCodISO
		AADD( aCabecTab, { "INVOICE_CURRENCY"            , "C",    03, 00		,"CTO_CODISO" , ""								}	)
	Else
		AADD( aCabecTab, { "INVOICE_CURRENCY"            , " ",    03, 00		,"EXP35" , "''"								}	)
	EndIf
	AADD( aCabecTab, { "TIMEKEEPER_LAST_NAME"        , " ",    30, 00		,"EXP21"      , "RD0_NOME"								}	)
	AADD( aCabecTab, { "TIMEKEEPER_FIRST_NAME"       , " ",    30, 00		,"EXP22"      , "RD0_NOME"								}	)
	AADD( aCabecTab, { "ACCOUNT_TYPE"                , " ",    01, 00		,"EXP23"      , "'O'"							}	)
	AADD( aCabecTab, { "LAW_FIRM_NAME"               , "C",    60, 00		,"NS7_NOME"   , ""								}	)
	AADD( aCabecTab, { "LAW_FIRM_ADDRESS_1"          , " ",    60, 00		,"EXP24"      , "NS7_END||NS7_BAIRRO"			}	)
	AADD( aCabecTab, { "LAW_FIRM_ADDRESS_2"          , " ",    60, 00		,"EXP25"      , "''"								}	)
	AADD( aCabecTab, { "LAW_FIRM_CITY"               , " ",    40, 00		,"EXP26"      , "NS7_ESTADO||NS7_CMUNIC"		}	)
	AADD( aCabecTab, { "LAW_FIRM_STATEorREGION"      , " ",    40, 00		,"EXP27"      , "NS7_ESTADO"					}	)
	AADD( aCabecTab, { "LAW_FIRM_POSTCODE"           , "C",    20, 00		,"NS7_CEP"    , ""								}	)
	AADD( aCabecTab, { "LAW_FIRM_COUNTRY"            , " ",    03, 00		,"EXP36"      , "NS7_CPAIS"						}	)
	AADD( aCabecTab, { "CLIENT_NAME"                 , "C",    60, 00		,"NXA_RAZSOC" , ""								}	)
	AADD( aCabecTab, { "CLIENT_ADDRESS_1"            , " ",    60, 00		,"EXP28"      , "NXA_LOGRAD||NXA_BAIRRO"		}	)
	AADD( aCabecTab, { "CLIENT_ADDRESS_2"            , " ",    60, 00		,"EXP29"      , "''"								}	)
	AADD( aCabecTab, { "CLIENT_CITY"                 , "C",    40, 00		,"NXA_CIDADE" , ""								}	)
	AADD( aCabecTab, { "CLIENT_STATEorREGION"        , "C",    40, 00		,"NXA_ESTADO" , ""								}	)
	AADD( aCabecTab, { "CLIENT_POSTCODE"             , "C",    20, 00		,"NXA_CEP"    , ""								}	)
	AADD( aCabecTab, { "CLIENT_COUNTRY"              , " ",    03, 00		,"EXP37"      , "NXA_CCLIEN||NXA_CLOJA"		}	)
	AADD( aCabecTab, { "LINE_ITEM_TAX_RATE"          , " ",    00, 04		,"EXP30"      , "'0'"							}	)
	AADD( aCabecTab, { "LINE_ITEM_TAX_TOTAL"         , " ",    10, 04		,"EXP31"      , "'0'"							}	)
	AADD( aCabecTab, { "LINE_ITEM_TAX_TYPE"          , " ",    20, 00		,"EXP32"      , "''"								}	)
	AADD( aCabecTab, { "INVOICE_REPORTED_TAX_TOTAL"  , " ",    12, 04		,"EXP33"      , "''"								}	)
	AADD( aCabecTab, { "INVOICE_TAX_CURRENCY"        , " ",    03, 00		,"EXP34"      , "''"								}	)
EndIf

//CABEC PARA DESCONTO OU ACRÉSCIMO NA FATURA
//               Tipo = F		representa uma Formula com retorno numerico  
//               Tipo = " " 	representa uma Expressao com retorno Alfa
//
//Cabeçalho                                      ,Tipo,   Tam, Dec, Campos         , Conteudo Específicos
AADD( aCabecAju, { "INVOICE_DATE"                , "C",    08, 00	,"NXA_DTEMI"	, ""								}	)
AADD( aCabecAju, { "INVOICE_NUMBER"              , "C",    20, 00	,"NXA_COD"		, ""								}	)
AADD( aCabecAju, { "CLIENT_ID"                   , "C",    20, 00	,"NXA_CCLIEN"	, "NXA_CCLIEN||NXA_CLOJA"			}	)
AADD( aCabecAju, { "LAW_FIRM_MATTER_ID"          , " ",    20, 00	,"EXP1"			, "'0'"								}	)
AADD( aCabecAju, { "INVOICE_TOTAL"               , "F",    12, 04	,"EXP2"       , "(NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ")" } )
AADD( aCabecAju, { "BILLING_START_DATE"          , " ",    08, 00	,"EXP15"      , "''"							}	)
AADD( aCabecAju, { "BILLING_END_DATE"            , " ",    08, 00	,"EXP16"      , "''"							}	)
AADD( aCabecAju, { "INVOICE_DESCRIPTION"         , " ", 15360, 00	,"EXP3"			, "''"								}	)
AADD( aCabecAju, { "LINE_ITEM_NUMBER"            , " ",    20, 00	,"EXP4"			, "''"								}	)
AADD( aCabecAju, { "EXP/FEE/INV_ADJ_TYPE"        , " ",    02, 00	,"TIPO"			, "'IF'"							}	)
AADD( aCabecAju, { "LINE_ITEM_NUMBER_OF_UNITS"   , " ",    10, 04	,"EXP5"			, "'1'"								}	)
AADD( aCabecAju, { "LINE_ITEM_ADJUSTMENT_AMOUNT" , "N",    10, 04	,"AJUSTE"		, ""  								}	)
AADD( aCabecAju, { "LINE_ITEM_TOTAL"             , "N",    10, 04	,"AJUSTE"		, ""								}	)
AADD( aCabecAju, { "LINE_ITEM_DATE"              , "C",    08, 00	,"NXA_DTEMI"	, ""								}	)
AADD( aCabecAju, { "LINE_ITEM_TASK_CODE"         , " ",    20, 00	,"EXP7"			, "''"								}	)
AADD( aCabecAju, { "LINE_ITEM_EXPENSE_CODE"      , " ",    20, 00	,"EXP8"			, "''"								}	)
AADD( aCabecAju, { "LINE_ITEM_ACTIVITY_CODE"     , " ",    20, 00	,"EXP9"			, "''"								}	)
AADD( aCabecAju, { "TIMEKEEPER_ID"               , " ",    20, 00	,"EXP10"		, "''"								}	)
AADD( aCabecAju, { "LINE_ITEM_DESCRIPTION"       , " ", 15360, 00	,"EXP3"			, "''"								}	)
AADD( aCabecAju, { "LAW_FIRM_ID"                 , "C",    20, 00	,"NTQ_CODIGO"	, ""								}	)
AADD( aCabecAju, { "LINE_ITEM_UNIT_COST"         , "F",    10, 04	,"EXP11"      , "0"								}	) 
AADD( aCabecAju, { "TIMEKEEPER_NAME"             , " ",    30, 00	,"EXP12"		, "''"								}	)
AADD( aCabecAju, { "TIMEKEEPER_CLASSIFICATION"   , " ",    10, 00	,"EXP13"		, "''"								}	)
AADD( aCabecAju, { "CLIENT_MATTER_ID"            , " ",    20, 00	,"EXP14"        , "''"								}	)

If l1998BI //Campos do 1998BI
	If lPoNumber
		AADD( aCabecAju, { "PO_NUMBER"                   , "C",    05, 00		,"NXA_PONUMB" , ""							}	)	
	Else	
		AADD( aCabecAju, { "PO_NUMBER"                   , " ",    05, 00		,"EXP17"      , "''"							}	)
	EndIf
	AADD( aCabecAju, { "CLIENT_TAX_ID"               , "C",    20, 00		,"NXA_CGCCPF" , ""								}	)
	AADD( aCabecAju, { "MATTER_NAME"                 , " ",   255, 00		,"EXP18"      , "''"								}	)
	AADD( aCabecAju, { "INVOICE_TAX_TOTAL"           , " ",    12, 04		,"EXP19"      , "'0'"							}	)
	AADD( aCabecAju, { "INVOICE_NET_TOTAL"           , "F",    12, 04		,"EXP20"      , "(NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ")"							}	)
	If lCodISO
		AADD( aCabecAju, { "INVOICE_CURRENCY"            , "C",    03, 00		,"CTO_CODISO" , ""								}	)
	Else
		AADD( aCabecAju, { "INVOICE_CURRENCY"            , " ",    03, 00		,"EXP35" , "''"								}	)
	EndIf
	AADD( aCabecAju, { "TIMEKEEPER_LAST_NAME"        , " ",    30, 00		,"EXP21"      , "RD0_NOME"								}	)
	AADD( aCabecAju, { "TIMEKEEPER_FIRST_NAME"       , " ",    30, 00		,"EXP22"      , "RD0_NOME"								}	)
	AADD( aCabecAju, { "ACCOUNT_TYPE"                , " ",    01, 00		,"EXP23"      , "'O'"							}	)
	AADD( aCabecAju, { "LAW_FIRM_NAME"               , "C",    60, 00		,"NS7_NOME"   , ""								}	)
	AADD( aCabecAju, { "LAW_FIRM_ADDRESS_1"          , " ",    60, 00		,"EXP24"      , "NS7_END||NS7_BAIRRO"			}	)
	AADD( aCabecAju, { "LAW_FIRM_ADDRESS_2"          , " ",    60, 00		,"EXP25"      , "''"								}	)
	AADD( aCabecAju, { "LAW_FIRM_CITY"               , " ",    40, 00		,"EXP26"      , "NS7_ESTADO||NS7_CMUNIC"		}	)
	AADD( aCabecAju, { "LAW_FIRM_STATEorREGION"      , " ",    40, 00		,"EXP27"      , "NS7_ESTADO"					}	)
	AADD( aCabecAju, { "LAW_FIRM_POSTCODE"           , "C",    20, 00		,"NS7_CEP"    , ""								}	)
	AADD( aCabecAju, { "LAW_FIRM_COUNTRY"            , " ",    03, 00		,"EXP36"      , "NS7_CPAIS"						}	)
	AADD( aCabecAju, { "CLIENT_NAME"                 , "C",    60, 00		,"NXA_RAZSOC" , ""								}	)
	AADD( aCabecAju, { "CLIENT_ADDRESS_1"            , " ",    60, 00		,"EXP28"      , "NXA_LOGRAD||NXA_BAIRRO"		}	)
	AADD( aCabecAju, { "CLIENT_ADDRESS_2"            , " ",    60, 00		,"EXP29"      , "''"								}	)
	AADD( aCabecAju, { "CLIENT_CITY"                 , "C",    40, 00		,"NXA_CIDADE" , ""								}	)
	AADD( aCabecAju, { "CLIENT_STATEorREGION"        , "C",    40, 00		,"NXA_ESTADO" , ""								}	)
	AADD( aCabecAju, { "CLIENT_POSTCODE"             , "C",    20, 00		,"NXA_CEP"    , ""								}	)
	AADD( aCabecAju, { "CLIENT_COUNTRY"              , " ",    03, 00		,"EXP37"      , "NXA_CCLIEN||NXA_CLOJA"		}	)
	AADD( aCabecAju, { "LINE_ITEM_TAX_RATE"          , " ",    00, 04		,"EXP30"      , "'0'"							}	)
	AADD( aCabecAju, { "LINE_ITEM_TAX_TOTAL"         , " ",    10, 04		,"EXP31"      , "'0'"							}	)
	AADD( aCabecAju, { "LINE_ITEM_TAX_TYPE"          , " ",    20, 00		,"EXP32"      , "''"								}	)
	AADD( aCabecAju, { "INVOICE_REPORTED_TAX_TOTAL"  , " ",    12, 04		,"EXP33"      , "''"								}	)
	AADD( aCabecAju, { "INVOICE_TAX_CURRENCY"        , " ",    03, 00		,"EXP34"      , "''"								}	)
EndIf

//CABEC PARA IMPOSTOS
//               Tipo = F		representa uma Formula com retorno numerico  
//               Tipo = " " 	representa uma Expressao com retorno Alfa
//
//                 Cabeçalho                     Tipo,    Tam, Deci, Campos         Conteudo Específicos
AADD( aCabecImp, { "INVOICE_DATE"                , "C",    08, 00	,"NXA_DTEMI"	, ""									}	)
AADD( aCabecImp, { "INVOICE_NUMBER"              , "C",    20, 00	,"NXA_COD"		, ""									}	)
AADD( aCabecImp, { "CLIENT_ID"                   , "C",    20, 00	,"NXA_CCLIEN"	, "NXA_CCLIEN||NXA_CLOJA"				}	)
AADD( aCabecImp, { "LAW_FIRM_MATTER_ID"          , " ",    20, 00	,"EXP1"			, "'0'"									}	)
AADD( aCabecImp, { "INVOICE_TOTAL"               , "F",    12, 04	,"EXP2"       , "(NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ")" } )
AADD( aCabecImp, { "BILLING_START_DATE"          , " ",    08, 00	,"EXP15"      , "''"								}	)
AADD( aCabecImp, { "BILLING_END_DATE"            , " ",    08, 00	,"EXP16"      , "''"								}	)
AADD( aCabecImp, { "INVOICE_DESCRIPTION"         , " ", 15360, 00	,"IMPOSTO"		, "''"									}	)
AADD( aCabecImp, { "LINE_ITEM_NUMBER"            , " ",    20, 00	,"EXP4"			, "''"									}	)
AADD( aCabecImp, { "EXP/FEE/INV_ADJ_TYPE"        , " ",    02, 00	,"TIPO"			, "'IF'"								}	)
AADD( aCabecImp, { "LINE_ITEM_NUMBER_OF_UNITS"   , " ",    10, 04	,"EXP5"			, "'1'"									}	)
AADD( aCabecImp, { "LINE_ITEM_ADJUSTMENT_AMOUNT" , "N",    10, 04	,"VALORIMP"   , ""									}	)
AADD( aCabecImp, { "LINE_ITEM_TOTAL"             , "N",    10, 04	,"VALORIMP"   , ""									}	)
AADD( aCabecImp, { "LINE_ITEM_DATE"              , "C",    08, 00	,"NXA_DTEMI"	, ""									}	)
AADD( aCabecImp, { "LINE_ITEM_TASK_CODE"         , " ",    20, 00	,"EXP7"			, "''"									}	)
AADD( aCabecImp, { "LINE_ITEM_EXPENSE_CODE"      , " ",    20, 00	,"EXP8"			, "''"									}	)
AADD( aCabecImp, { "LINE_ITEM_ACTIVITY_CODE"     , " ",    20, 00	,"EXP9"			, "''"									}	)
AADD( aCabecImp, { "TIMEKEEPER_ID"               , " ",    20, 00	,"EXP10"		, "''"									}	)
AADD( aCabecImp, { "LINE_ITEM_DESCRIPTION"       , " ", 15360, 00	,"IMPOSTO" 		, "''"									}	)
AADD( aCabecImp, { "LAW_FIRM_ID"                 , "C",    20, 00	,"NTQ_CODIGO"	, ""									}	)
AADD( aCabecImp, { "LINE_ITEM_UNIT_COST"         , " ",    10, 04	,"EXP11"      , "0"									}	) 
AADD( aCabecImp, { "TIMEKEEPER_NAME"             , " ",    30, 00	,"EXP12"		, "''"									}	)
AADD( aCabecImp, { "TIMEKEEPER_CLASSIFICATION"   , " ",    10, 00	,"EXP13"		, "''"									}	)
AADD( aCabecImp, { "CLIENT_MATTER_ID"            , " ",    20, 00	,"EXP14"        , "''"									}	)

If l1998BI //Campos do 1998BI
	If lPoNumber
		AADD( aCabecImp, { "PO_NUMBER"                   , "C",    05, 00		,"NXA_PONUMB" , ""							}	)	
	Else	
		AADD( aCabecImp, { "PO_NUMBER"                   , " ",    05, 00		,"EXP17"      , "''"							}	)
	EndIf
	AADD( aCabecImp, { "CLIENT_TAX_ID"               , "C",    20, 00		,"NXA_CGCCPF" , ""								}	)
	AADD( aCabecImp, { "MATTER_NAME"                 , " ",   255, 00		,"IMPOSTO"    , "''"								}	)
	AADD( aCabecImp, { "INVOICE_TAX_TOTAL"           , " ",    12, 04		,"EXP19"      , "'0'"							}	)
	AADD( aCabecImp, { "INVOICE_NET_TOTAL"           , "F",    12, 04		,"EXP20"      , "(NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ")"}	)
	If lCodISO
		AADD( aCabecImp, { "INVOICE_CURRENCY"            , "C",    03, 00		,"CTO_CODISO" , ""								}	)
	Else
		AADD( aCabecImp, { "INVOICE_CURRENCY"            , " ",    03, 00		,"EXP35" , "''"								}	)
	EndIf
	AADD( aCabecImp, { "TIMEKEEPER_LAST_NAME"        , " ",    30, 00		,"EXP21"      , "RD0_NOME"								}	)
	AADD( aCabecImp, { "TIMEKEEPER_FIRST_NAME"       , " ",    30, 00		,"EXP22"      , "RD0_NOME"								}	)
	AADD( aCabecImp, { "ACCOUNT_TYPE"                , " ",    01, 00		,"EXP23"      , "'O'"							}	)
	AADD( aCabecImp, { "LAW_FIRM_NAME"               , "C",    60, 00		,"NS7_NOME"   , ""								}	)
	AADD( aCabecImp, { "LAW_FIRM_ADDRESS_1"          , " ",    60, 00		,"EXP24"      , "NS7_END||NS7_BAIRRO"			}	)
	AADD( aCabecImp, { "LAW_FIRM_ADDRESS_2"          , " ",    60, 00		,"EXP25"      , "''"								}	)
	AADD( aCabecImp, { "LAW_FIRM_CITY"               , " ",    40, 00		,"EXP26"      , "NS7_ESTADO||NS7_CMUNIC"		}	)
	AADD( aCabecImp, { "LAW_FIRM_STATEorREGION"      , " ",    40, 00		,"EXP27"      , "NS7_ESTADO"					}	)
	AADD( aCabecImp, { "LAW_FIRM_POSTCODE"           , "C",    20, 00		,"NS7_CEP"    , ""								}	)
	AADD( aCabecImp, { "LAW_FIRM_COUNTRY"            , " ",    03, 00		,"EXP36"      , "NS7_CPAIS"						}	)
	AADD( aCabecImp, { "CLIENT_NAME"                 , "C",    60, 00		,"NXA_RAZSOC" , ""								}	)
	AADD( aCabecImp, { "CLIENT_ADDRESS_1"            , " ",    60, 00		,"EXP28"      , "NXA_LOGRAD||NXA_BAIRRO"		}	)
	AADD( aCabecImp, { "CLIENT_ADDRESS_2"            , " ",    60, 00		,"EXP29"      , "''"								}	)
	AADD( aCabecImp, { "CLIENT_CITY"                 , "C",    40, 00		,"NXA_CIDADE" , ""								}	)
	AADD( aCabecImp, { "CLIENT_STATEorREGION"        , "C",    40, 00		,"NXA_ESTADO" , ""								}	)
	AADD( aCabecImp, { "CLIENT_POSTCODE"             , "C",    20, 00		,"NXA_CEP"    , ""								}	)
	AADD( aCabecImp, { "CLIENT_COUNTRY"              , " ",    03, 00		,"EXP37"      , "NXA_CCLIEN||NXA_CLOJA"		}	)
	AADD( aCabecImp, { "LINE_ITEM_TAX_RATE"          , " ",    00, 04		,"EXP30"      , "'0'"							}	)
	AADD( aCabecImp, { "LINE_ITEM_TAX_TOTAL"         , " ",    10, 04		,"EXP31"      , "'0'"							}	)
	AADD( aCabecImp, { "LINE_ITEM_TAX_TYPE"          , " ",    20, 00		,"EXP32"      , "''"								}	)
	AADD( aCabecImp, { "INVOICE_REPORTED_TAX_TOTAL"  , " ",    12, 04		,"EXP33"      , "''"								}	)
	AADD( aCabecImp, { "INVOICE_TAX_CURRENCY"        , " ",    03, 00		,"EXP34"      , "''"								}	)
EndIf

If lLedes98Es
	aCabecHonC := aClone(aCabecHon)
	aCabecDesC := aClone(aCabecDes)
	aCabecTabC := aClone(aCabecTab)
	aCabecAjuC := aClone(aCabecAju)
	aCabecImpC := aClone(aCabecImp)
	aCabecFixC := aClone(aCabecFix)
	aRetPE     := ExecBlock("Ledes98Es", .F., .F., {l1998BI, aCabecHonC, aCabecDesC, aCabecTabC, aCabecAjuC, aCabecImpC, aCabecFix})

	If Len(aRetPE) >= 5
		For nC := 1 To Len(aRetPE)
			If !Empty(aRetPE[nC]) .And. ValType(aRetPE[nC]) == "A" .And. Len(aRetPE[nC]) > 0
				Do Case 
				Case nC == 1
					aCabecHon := aClone(aRetPE[nC])
				Case nC == 2
					aCabecDes := aClone(aRetPE[nC])
				Case nC == 3
					aCabecTab := aClone(aRetPE[nC])
				Case nC == 4
					aCabecAju := aClone(aRetPE[nC])
				Case nC == 5
					aCabecImp := aClone(aRetPE[nC])
				Case nC == 6
					aCabecFix := aClone(aRetPE[nC])
				EndCase
			EndIf
		Next nC 
	EndIf
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} RunQuery
Montagem das querys com campos dinâmicos.

@author SISJURI
@since 06/03/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RunQuery(cFat, cCodEsc, cMoeEbi, cNArq, cDArq, c1998BI, lAutomato)
Local nx          := 0
Local ny          := 0
Local cQuery      := ""
Local TRAB        := ""
Local lNoData     := .T. //Flag de verificacao de dados para geracao do arquivo
Local lArqCria    := .T. //Controla a criação ou reabertura do arquivo
Local cQryCabec   := ""
Local cQryCorpo   := ""
Local aLog        := {}
Local aRet        := {.T., aLog, 0}
Local cMemolog    := ""
Local cMoeFat     := ""
Local cCodContr   := ""
Local nSomaItem   := 0  //Totaliza o campo "LINE_ITEM_TOTAL" - pos 13
Local nCount      := 0  // contador da posição LINE_ITEM_NUMBER (Impostos, Ajuste de Acrescimo, Descontos e Arredondamento )
Local nContr      := 0
Local aCodContr   := {}
Local aPerFat     := {}
Local aCabecHon   := {}
Local aCabecFix   := {}
Local aCabecDes   := {}
Local aCabecTab   := {}
Local aCabecAju   := {}
Local aCabecImp   := {}
Local aCabecArq   := {}
Local l1998BI     := .F.
Local lCobraHora  := .T.
Local lCobraFixo  := .F.
Local cCpoGrossH  := IIf(NXA->(ColumnPos("NXA_VGROSH")) > 0, "+NXA_VGROSH", "") // @12.1.2310
Local aFatPag     := JurGetDados('NXA', 1, xFilial('NXA') + cCodEsc + cFat, {'NXA_CMOEDA','NXA_CLIPG','NXA_LOJPG','NXA_CCLIEN','NXA_CLOJA' })
Local cCliente    := ""
Local cLoja       := ""

Default cMoeEbi   := cMoeFat // Por padrão a moeda do Ebilling é a moeda da fatura
Default c1998BI   := STR0037 // "Não"
Default lAutomato := .F.

	If Len(aFatPag) > 0
		cMoeFat := aFatPag[1]
		cQuery := "SELECT NRX_COD FROM " + RetSQLName("NRX")
		cQuery += " INNER JOIN " + RetSQLName("NUH") + " ON ( NRX_COD = NUH_CEMP AND NUH_LOJA = '"+aFatPag[3]+"') "
		cQuery += " WHERE NUH_COD  = '" + aFatPag[2] + "'"
		
		If Len(JurSQL(cQuery, 'NRX_COD')) > 0
			// Cliente Pagador
			cCliente :=  aFatPag[2]
			cLoja    :=  aFatPag[3]
		else
			// Cliente da Fatura
			cCliente :=  aFatPag[4]
			cLoja    :=  aFatPag[5]
		EndIf

		cQuery := ""
	EndIf

	cMoeEbi := Iif(Empty(cMoeEbi), cMoeFat, cMoeEbi)

	aPerFat   := JGetPerFT(cFat, cCodEsc)
	aCodContr := JGetTpCob(cCodEsc, cFat)
	l1998BI   := c1998BI == STR0036 // "Sim"

	MontaCabec(l1998BI, @aCabecHon, @aCabecDes, @aCabecTab, @aCabecAju, @aCabecImp, @aCabecFix) //Executa a montagem dos cabeçalhos do arquivo

	For nContr := 1 To Len(aCodContr)
		lCobraHora   := aCodContr[nContr][1] == "1"
		lCobraFixo   := aCodContr[nContr][2] == "1"
		cCodContr    := aCodContr[nContr][3]

		If lCobraHora
			//QUERY PARA HONORARIOS - TIME SHEETS
			//Monta colunas Dinamicas para a Query 
			aCabecArq := aClone( aCabecHon )

			cQuery := " SELECT"
			cQuery += " NUE.R_E_C_N_O_ RECNO_NUE, NUH_CLIEBI, NUE_COD, NUE_CCLIEN, NUE_CLOJA, NUE_CCASO, NUH_CEMP, NRY_CFASE, NUR_CCAT, NUE_CMOEDA CMOEDA, "

			For nx := 1 To Len( aCabecArq )
				cQuery += IIf( aCabecArq[ nx ][ _TIPO_ ] $ " F", aCabecArq[ nx ][ _CONTE_ ] + " " + aCabecArq[ nx ][ _CAMPO_ ], aCabecArq[ nx][ _CAMPO_ ] )
				If nx < Len( aCabecArq )
					cQuery += ", "
				EndIf
			Next 

			cQuery += " FROM " + RetSqlName("NXA") + " NXA "

			cQuery += " INNER JOIN " + RetSqlName("NXC") + " NXC "
			cQuery +=     " ON ( NXC.NXC_FILIAL     = '" + xFilial("NXC") + "'"
			cQuery +=         " AND NXC.NXC_CESCR  = NXA.NXA_CESCR"
			cQuery +=         " AND NXC.NXC_CFATUR = NXA.NXA_COD"
			cQuery +=         " AND NXC.NXC_CCONTR = '" + cCodContr + "'"
			cQuery +=         " AND NXC.D_E_L_E_T_ = ' ' )"

			cQuery += " INNER JOIN " + RetSqlName("NW0") + " NW0 "
			cQuery +=     " ON ( NW0.NW0_FILIAL     = '" + xFilial("NW0") + "'"
			cQuery +=         " AND NW0.NW0_CESCR  = NXA.NXA_CESCR"
			cQuery +=         " AND NW0.NW0_CFATUR = NXA.NXA_COD"
			cQuery +=         " AND NW0.D_E_L_E_T_ = ' ' )"

			cQuery += " INNER JOIN " + RetSqlName("NUE") + " NUE "
			cQuery +=     " ON ( NUE.NUE_FILIAL     = '" + xFilial("NUE") + "'"
			cQuery +=         " AND NUE.NUE_COD    = NW0.NW0_CTS"
			cQuery +=         " AND NUE.NUE_CCLIEN = NXC.NXC_CCLIEN"
			cQuery +=         " AND NUE.NUE_CLOJA  = NXC.NXC_CLOJA"
			cQuery +=         " AND NUE.NUE_CCASO  = NXC.NXC_CCASO"
			cQuery +=         " AND NUE.NUE_VALOR1 > 0"
			cQuery +=         " AND NUE.D_E_L_E_T_ = ' ' )"

			cQuery += " INNER JOIN " + RetSqlName("NVE") + " NVE "
			cQuery +=     " ON ( NVE.NVE_FILIAL     = '" + xFilial("NVE") + "'"
			cQuery +=     " AND NVE.NVE_CCLIEN = NUE.NUE_CCLIEN" 
			cQuery +=     " AND NVE.NVE_LCLIEN = NUE.NUE_CLOJA"
			cQuery +=     " AND NVE.NVE_NUMCAS = NUE.NUE_CCASO"
			cQuery +=     " AND NVE.D_E_L_E_T_ = ' ' )"

			cQuery += " INNER JOIN " + RetSqlName("NUR") + " NUR "
			cQuery +=     " ON ( NUR.NUR_FILIAL     = '" + xFilial("NUR") + "'"
			cQuery +=         " AND NUR.NUR_CPART  = NUE.NUE_CPART2"
			cQuery +=         " AND NUR.D_E_L_E_T_ = ' ' )"

			cQuery += " INNER JOIN " + RetSqlName("RD0") + " RD0 "
			cQuery +=     " ON ( RD0.RD0_FILIAL     = '" + xFilial("RD0") + "'"
			cQuery +=         " AND RD0.RD0_CODIGO = NUR.NUR_CPART"
			cQuery +=         " AND RD0.D_E_L_E_T_ = ' ' )"

			cQuery += " INNER JOIN " + RetSqlName("NUH") + " NUH "
			cQuery +=     " ON ( NUH.NUH_FILIAL = '" + xFilial("NUH") + "'"
			cQuery +=         " AND NUH.NUH_COD = '" + cCliente + "' "
			cQuery +=         " AND NUH.NUH_LOJA = '" + cLoja + "' "
			cQuery +=         " AND NUH.D_E_L_E_T_ = ' ' )

			cQuery += " INNER JOIN " + RetSqlName("NRX") + " NRX "
			cQuery +=     " ON ( NRX.NRX_FILIAL     = '" + xFilial("NRX") + "'"
			cQuery +=         " AND NRX.NRX_COD    = NUH.NUH_CEMP"
			cQuery +=         " AND NRX.D_E_L_E_T_ = ' ' )"

			cQuery += " INNER JOIN " + RetSqlName("CTO") + " CTO "
			cQuery +=     " ON ( CTO.CTO_FILIAL     = '" + xFilial("CTO") + "'"
			cQuery +=         " AND CTO.CTO_MOEDA = NXA.NXA_CMOEDA"
			cQuery +=         " AND CTO.D_E_L_E_T_ = ' ' )" 

			cQuery += " LEFT JOIN " + RetSqlName("NTQ") + " NTQ "
			cQuery +=     " ON ( NTQ.NTQ_FILIAL     = '" + xFilial("NTQ") + "'"
			cQuery +=         " AND NTQ.NTQ_CEMP   = NRX.NRX_COD"
			cQuery +=         " AND NTQ.NTQ_CESCR  = NXA.NXA_CESCR"
			cQuery +=         " AND NTQ.D_E_L_E_T_ = ' ' )"

			cQuery += " LEFT JOIN " + RetSqlName("NS7") + " NS7 "
			cQuery +=     " ON ( NS7.NS7_FILIAL     = '" + xFilial("NS7") + "'"
			cQuery +=         " AND NS7.NS7_COD = NTQ.NTQ_CESCR "
			cQuery +=         " AND NS7.D_E_L_E_T_ = ' ' )"

			cQuery += " LEFT JOIN " + RetSqlName("SYA") + " SYA "
			cQuery +=     " ON ( SYA.YA_FILIAL     = '" + xFilial("SYA") + "'"
			cQuery +=         " AND SYA.YA_CODGI = NXA.NXA_PAIS "
			cQuery +=         " AND SYA.D_E_L_E_T_ = ' ' )"

			cQuery += " LEFT JOIN " + RetSqlName("NS2") + " NS2 "
			cQuery +=     " ON ( NS2.NS2_FILIAL     = '" + xFilial("NS2") + "'"
			cQuery +=         " AND NS2.NS2_CDOC   = NRX.NRX_CDOC"
			cQuery +=         " AND NS2.NS2_CCATEJ = NUR.NUR_CCAT"
			cQuery +=         " AND NS2.D_E_L_E_T_ = ' ' )"

			cQuery += " LEFT JOIN " + RetSqlName("NRV") + " NRV "
			cQuery +=     " ON ( NRV.NRV_FILIAL     = '" + xFilial("NRV") + "'"
			cQuery +=         " AND NRV.NRV_CDOC   = NRX.NRX_CDOC"
			cQuery +=         " AND NRV.NRV_COD    = NS2.NS2_CCATE"
			cQuery +=         " AND NRV.D_E_L_E_T_ = ' ' )"

			cQuery += " LEFT JOIN " + RetSqlName("NS0") + " NS0 "
			cQuery +=     " ON ( NS0.NS0_FILIAL     = '" + xFilial("NS0") + "'"
			cQuery +=         " AND NS0.NS0_CDOC   = NRX.NRX_CDOC"
			cQuery +=         " AND NS0.NS0_CATIV  = NUE.NUE_CTAREB"
			cQuery +=         " AND NS0.D_E_L_E_T_ = ' ' )"

			cQuery += " LEFT JOIN " + RetSqlName("NRY") + " NRY "
			cQuery +=     " ON ( NRY.NRY_FILIAL     = '" + xFilial("NRY") + "'"
			cQuery +=         " AND NRY.NRY_CDOC   = NRX.NRX_CDOC"
			cQuery +=         " AND NRY.NRY_CFASE  = NUE.NUE_CFASE"
			cQuery +=         " AND NRY.D_E_L_E_T_ = ' ' )"

			cQuery += " LEFT JOIN " + RetSqlName("NRZ") + " NRZ "
			cQuery +=     " ON ( NRZ.NRZ_FILIAL     = '" + xFilial("NRZ") + "'"
			cQuery +=         " AND NRZ.NRZ_CDOC   = NRX.NRX_CDOC"
			cQuery +=         " AND NRZ.NRZ_CTAREF = NUE.NUE_CTAREF"
			cQuery +=         " AND NRZ.NRZ_CFASE = NRY.NRY_COD"
			cQuery +=         " AND NRZ.D_E_L_E_T_ = ' ' )"

			cQuery += " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
			cQuery +=     " AND NXA.NXA_CESCR  = '" + cCodEsc + "' "
			cQuery +=     " AND NXA.NXA_COD    = '" + cFat + "' "
			cQuery +=     " AND NXA.D_E_L_E_T_ = ' '"
			cQuery += " ORDER BY "
			cQuery +=     " NUE.NUE_DATATS, NUE.NUE_COD"

			cQuery := ChangeQuery( cQuery )
			cQuery := StrTran(cQuery,'#','')
			TRAB   := GetNextAlias()

			dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), (TRAB), .T., .T. )

			aRet[3] := 0

			If !(TRAB)->( Eof() )
				If !lAutomato
					MsgRun( STR0011, , { || aRet := GerarArq( lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "H", alog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato) } ) //Passo 1 //"Processando Honorarios"
				Else
					aRet := GerarArq( lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "H", alog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato)
				EndIf

				(TRAB)->( DbCloseArea() )

				lNoData  := .F.
				lArqCria := .F.
			EndIf

			If !aRet[1]
				Return aRet
			Else
				alog      := aRet[2]
				nSomaItem += aRet[3]
			EndIf
		EndIf

		If lCobraFixo
			// QUERY PARA HONORARIOS - FIXO
			aCabecArq := aClone( aCabecFix )

			cQuery := " SELECT "
			//cQuery += " NT1.R_E_C_N_O_ RECNO_NT1, NUH_CLIEBI, NT1_SEQUEN, NVE_CCLIEN, NVE_LCLIEN, NVE_NUMCAS, NUH_CEMP, NRY_CFASE, NUR_CCAT, NT1_CMOEDA CMOEDA, "
			cQuery += " NT1.R_E_C_N_O_ RECNO_NT1, NXA.NXA_CCLIEN, NXA.NXA_CLOJA ,NUH_CLIEBI, NT1_SEQUEN, NUH_CEMP, NUR_CCAT, NT1_CMOEDA CMOEDA, NT0.NT0_TITFAT, NT0.NT0_NOME, " 
			cQuery += " CASE WHEN NT5.NT5_TITULO IS NULL THEN ' ' ELSE  NT5.NT5_TITULO END NT5_TITULO,"

			For nx := 1 To Len( aCabecArq )
				cQuery += IIf( aCabecArq[ nx ][ _TIPO_ ] $ " F", aCabecArq[ nx ][ _CONTE_ ] + " " + aCabecArq[ nx ][ _CAMPO_ ], aCabecArq[ nx][ _CAMPO_ ] )
				If nx < Len( aCabecArq )
					cQuery += ", "
				EndIf
			Next

			cQuery += " FROM " + RetSqlName("NXA") + " NXA "

			cQuery +=     " inner join " + RetSqlName("NXB") + " NXB "
			cQuery +=         " on( NXB.NXB_FILIAL     = '" + xFilial("NXB") + "'"
			cQuery +=             " and NXB.NXB_CESCR  = NXA.NXA_CESCR"
			cQuery +=             " and NXB.NXB_CFATUR = NXA.NXA_COD"
			cQuery +=             " and NXB.NXB_CCONTR = '" + cCodContr + "'"
			cQuery +=             " and NXB.D_E_L_E_T_ = ' ' )"
			
			cQuery +=     " inner join " + RetSqlName("NWE") + " NWE "
			cQuery +=         " on( NWE.NWE_FILIAL     = '" + xFilial("NWE") + "'"
			cQuery +=             " and NWE.NWE_CESCR  = NXA.NXA_CESCR"
			cQuery +=             " and NWE.NWE_CFATUR = NXA.NXA_COD"
			cQuery +=             " and NWE.D_E_L_E_T_ = ' ' )"

			cQuery +=     " inner join " + RetSqlName("NT1") + " NT1 "
			cQuery +=         " on( NT1.NT1_FILIAL = '" + xFilial("NT1") + "'"
			cQuery +=             " and NT1.NT1_SEQUEN = NWE.NWE_CFIXO "
			cQuery +=             " and NT1.D_E_L_E_T_ = ' ' )"

			cQuery +=     " inner join " + RetSqlName("NT0") + " NT0 "
			cQuery +=         " on( NT0.NT0_FILIAL = '" + xFilial("NT0") + "'"
			cQuery +=             " and NT0.NT0_COD = NT1.NT1_CCONTR "
			cQuery +=             " and NT0.D_E_L_E_T_ = ' ' )"

			cQuery +=     " inner join " + RetSqlName("NUR") + " NUR "
			cQuery +=         " on( NUR.NUR_FILIAL     = '" + xFilial("NUR") + "'"
			cQuery +=             " and NUR.NUR_CPART  = NXA.NXA_CPART"
			cQuery +=             " and NUR.D_E_L_E_T_ = ' ' )"

			cQuery +=     " inner join " + RetSqlName("RD0") + " RD0 "
			cQuery +=         " on( RD0.RD0_FILIAL     = '" + xFilial("RD0") + "'"
			cQuery +=             " and RD0.RD0_CODIGO = NUR.NUR_CPART"
			cQuery +=             " and RD0.D_E_L_E_T_ = ' ' )"

			cQuery +=     " inner join " + RetSqlName("NUH") + " NUH "
			cQuery +=         " on( NUH.NUH_FILIAL = '" + xFilial("NUH") + "'"
			cQuery +=         " AND NUH.NUH_COD = '" + cCliente + "' "
			cQuery +=         " AND NUH.NUH_LOJA = '" + cLoja + "' "
			cQuery +=             " and NUH.D_E_L_E_T_ = ' ' )"

			cQuery +=     " inner join " + RetSqlName("NR2") + " NR2 "
			cQuery +=         " on( NR2.NR2_FILIAL     = '" + xFilial("NR2") + "'"
			cQuery +=             " and NR2.NR2_CATPAR = NUR.NUR_CCAT"
			cQuery +=             " and NR2.NR2_CIDIOM = NUH.NUH_CIDIO"
			cQuery +=             " and NR2.D_E_L_E_T_ = ' ' )"

			cQuery +=     " inner join " + RetSqlName("NRX") + " NRX "
			cQuery +=         " on( NRX.NRX_FILIAL     = '" + xFilial("NRX") + "'"
			cQuery +=             " and NRX.NRX_COD    = NUH.NUH_CEMP"
			cQuery +=             " and NRX.D_E_L_E_T_ = ' ' )"

			cQuery +=     " inner join " + RetSqlName("CTO") + " CTO "
			cQuery +=         " on( CTO.CTO_FILIAL     = '" + xFilial("CTO") + "'"
			cQuery +=             " and CTO.CTO_MOEDA = NXA.NXA_CMOEDA"
			cQuery +=             " and CTO.D_E_L_E_T_ = ' ' )" 

			cQuery +=     " left join " + RetSqlName("NTQ") + " NTQ "
			cQuery +=         " on( NTQ.NTQ_FILIAL     = '" + xFilial("NTQ") + "'"
			cQuery +=             " and NTQ.NTQ_CEMP   = NRX.NRX_COD"
			cQuery +=             " and NTQ.NTQ_CESCR  = NXA.NXA_CESCR"
			cQuery +=             " and NTQ.D_E_L_E_T_ = ' ' )"

			cQuery +=     " left join " + RetSqlName("NS7") + " NS7 "
			cQuery +=         " on( NS7.NS7_FILIAL = '" + xFilial("NS7") + "'"
			cQuery +=             " and NS7.NS7_COD = NTQ.NTQ_CESCR "
			cQuery +=             " and NS7.D_E_L_E_T_ = ' ' )"

			cQuery +=     " left join " + RetSqlName("NS2") + " NS2 "
			cQuery +=         " on( NS2.NS2_FILIAL     = '" + xFilial("NS2") + "'"
			cQuery +=             " and NS2.NS2_CDOC   = NRX.NRX_CDOC"
			cQuery +=             " and NS2.NS2_CCATEJ = NUR.NUR_CCAT"
			cQuery +=             " and NS2.D_E_L_E_T_ = ' ' )"

			cQuery +=     " left join " + RetSqlName("NRV") + " NRV "
			cQuery +=         " on( NRV.NRV_FILIAL     = '" + xFilial("NRV") + "'"
			cQuery +=             " and NRV.NRV_CDOC   = NRX.NRX_CDOC"
			cQuery +=             " and NRV.NRV_COD    = NS2.NS2_CCATE"
			cQuery +=             " and NRV.D_E_L_E_T_ = ' ' )"

			cQuery +=     " left join " + RetSqlName("NT5") + " NT5 "
			cQuery +=         " on( NT5.NT5_FILIAL     = '" + xFilial("NT5") + "'"
			cQuery +=             " and NT5.NT5_CCONTR   = NT0.NT0_COD"
			cQuery +=             " and NT5.NT5_CIDIOM   = NUH.NUH_CIDIO"
			cQuery +=             " and NT5.D_E_L_E_T_ = ' ' )"

			cQuery += " where NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
			cQuery +=     " and NXA.NXA_CESCR = '" + cCodEsc + "' "
			cQuery +=     " and NXA.NXA_COD = '" + cFat + "' "
			cQuery +=     " and NXA.D_E_L_E_T_ = ' '"
			cQuery += " order by"
			cQuery +=     " NT1.NT1_DATAIN, NT1.NT1_SEQUEN"

			cQuery := ChangeQuery( cQuery )
			cQuery := StrTran(cQuery,'#','')
			TRAB   := GetNextAlias()

			dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), (TRAB), .T., .T. )

			aRet[3] := 0

			If !(TRAB)->( Eof() )
				If !lAutomato
					MsgRun( STR0011, , { || aRet := GerarArq( lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "F", alog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato) } ) //Passo 1 //"Processando Honorarios"
				Else
					aRet := GerarArq( lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "F", alog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato)
				EndIf

				(TRAB)->( DbCloseArea() )

				lNoData  := .F.
				lArqCria := .F.
			EndIf

			If !aRet[1]
				Return aRet
			Else
				alog      := aRet[2]
				nSomaItem += aRet[3]
			EndIf
		EndIf
	Next nContr

	//QUERY PARA DESPESAS
	//Monta colunas Dinamicas para a Query
	aCabecArq := aClone( aCabecDes )

	cQuery := " select"
	cQuery += " NVY.R_E_C_N_O_ as RECNO_NVY, NUH_CLIEBI, NVY_COD, NVY_CCLIEN, NVY_CLOJA, NVY_CCASO, NUH.NUH_CEMP, NUR_CCAT, NVY_CMOEDA CMOEDA, "

	For nx := 1 To Len( aCabecArq )
		cQuery += If( aCabecArq[ nx ][ _TIPO_ ] $ " F", aCabecArq[ nx ][ _CONTE_ ] + " " + aCabecArq[ nx ][ _CAMPO_ ], aCabecArq[ nx ][ _CAMPO_ ] )
		If nx < Len( aCabecArq )
			cQuery += ", "
		EndIf
	Next 

	cQuery += " from"
	cQuery +=    " " + RetSqlName("NXA") + " NXA "

	cQuery +=     " inner join " + RetSqlName("NVZ") + " NVZ "
	cQuery +=         " on( NVZ.NVZ_FILIAL     = '" + xFilial("NVZ") + "'"
	cQuery +=             " and NVZ.NVZ_CESCR  = NXA.NXA_CESCR"
	cQuery +=             " and NVZ.NVZ_CFATUR = NXA.NXA_COD"
	cQuery +=             " and NVZ.D_E_L_E_T_ = ' ' )"

	cQuery +=     " inner join " + RetSqlName("NVY") + " NVY "
	cQuery +=         " on( NVY.NVY_FILIAL     = '" + xFilial("NVY") + "'"
	cQuery +=             " and NVY.NVY_COD    = NVZ.NVZ_CDESP"
	cQuery +=             " and NVY.D_E_L_E_T_ = ' ' )"

	cQuery +=     " inner join " + RetSqlName("NVE") + " NVE "
	cQuery +=         " on( NVE.NVE_FILIAL     = '" + xFilial("NVE") + "'"
	cQuery +=         " and NVE.NVE_CCLIEN = NVY.NVY_CCLIEN"
	cQuery +=         " and NVE.NVE_LCLIEN = NVY.NVY_CLOJA"
	cQuery +=         " and NVE.NVE_NUMCAS = NVY.NVY_CCASO"
	cQuery +=         " and NVE.D_E_L_E_T_ = ' ' )"

	cQuery +=     " left join " + RetSqlName("NUR") + " NUR "
	cQuery +=         " on( NUR.NUR_FILIAL     = '" + xFilial("NUR") + "'"
	cQuery +=             " and NUR.NUR_CPART  = NVY.NVY_CPART"
	cQuery +=             " and NUR.D_E_L_E_T_ = ' ' )"

	cQuery +=     " left join " + RetSqlName("RD0") + " RD0 "
	cQuery +=         " on( RD0.RD0_FILIAL     = '" + xFilial("RD0") + "'"
	cQuery +=             " and RD0.RD0_CODIGO = NUR.NUR_CPART"
	cQuery +=             " and RD0.D_E_L_E_T_ = ' ' )"

	cQuery +=     " inner join " + RetSqlName("NUH") + " NUH "
	cQuery +=         " on( NUH.NUH_FILIAL = '" + xFilial("NUH") + "'"
	cQuery +=         " AND NUH.NUH_COD = '" + cCliente + "' "
	cQuery +=         " AND NUH.NUH_LOJA = '" + cLoja + "' "
	cQuery +=             " and NUH.D_E_L_E_T_ = ' ' )"

	cQuery +=      " inner join " + RetSqlName("NRX") + " NRX "
	cQuery +=         " on( NRX.NRX_FILIAL     = '" + xFilial("NRX") + "'"
	cQuery +=             " and NRX.NRX_COD    = NUH.NUH_CEMP"
	cQuery +=             " and NRX.D_E_L_E_T_ = ' ' )"

	cQuery +=     " inner join " + RetSqlName("CTO") + " CTO "
	cQuery +=         " on( CTO.CTO_FILIAL     = '" + xFilial("CTO") + "'"
	cQuery +=             " and CTO.CTO_MOEDA = NXA.NXA_CMOEDA"
	cQuery +=             " and CTO.D_E_L_E_T_ = ' ' )" 

	cQuery +=      " left join " + RetSqlName("NTQ") + " NTQ "
	cQuery +=         " on( NTQ.NTQ_FILIAL     = '" + xFilial("NTQ") + "'"
	cQuery +=             " and NTQ.NTQ_CEMP   = NRX.NRX_COD"
	cQuery +=             " and NTQ.NTQ_CESCR  = NXA.NXA_CESCR"
	cQuery +=             " and NTQ.D_E_L_E_T_ = ' ' )"

	cQuery +=     " left join " + RetSqlName("NS7") + " NS7 "
	cQuery +=         " on( NS7.NS7_FILIAL     = '" + xFilial("NS7") + "'"
	cQuery +=             " and NS7.NS7_COD = NTQ.NTQ_CESCR "
	cQuery +=             " and NS7.D_E_L_E_T_ = ' ' )"

	cQuery +=     " left join " + RetSqlName("SYA") + " SYA "
	cQuery +=         " on( SYA.YA_FILIAL     = '" + xFilial("SYA") + "'"
	cQuery +=             " and SYA.YA_CODGI = NXA.NXA_PAIS "
	cQuery +=             " and SYA.D_E_L_E_T_ = ' ' )"

	cQuery +=      " left join " + RetSqlName("NS2") + " NS2 "
	cQuery +=         " on( NS2.NS2_FILIAL     = '" + xFilial("NS2") + "'"
	cQuery +=             " and NS2.NS2_CDOC   = NRX.NRX_CDOC"
	cQuery +=             " and NS2.NS2_CCATEJ = NUR.NUR_CCAT"
	cQuery +=             " and NS2.D_E_L_E_T_ = ' ' )"

	cQuery +=      " left join " + RetSqlName("NRV") + " NRV "
	cQuery +=         " on( NRV.NRV_FILIAL     = '" + xFilial("NRV") + "'"
	cQuery +=             " and NRV.NRV_CDOC   = NRX.NRX_CDOC"
	cQuery +=             " and NRV.NRV_COD    = NS2.NS2_CCATE"
	cQuery +=             " and NRV.D_E_L_E_T_ = ' ' )"

	cQuery +=      " left join " + RetSqlName("NS4") + " NS4 "
	cQuery +=         " on( NS4.NS4_FILIAL     = '" + xFilial("NS4") + "'"
	cQuery +=             " and NS4.NS4_CDOC   = NRX.NRX_CDOC"
	cQuery +=             " and NS4.NS4_CDESPJ = NVY.NVY_CTPDSP"
	cQuery +=             " and NS4.D_E_L_E_T_ = ' ' )"

	cQuery +=      " left join " + RetSqlName("NS3") + " NS3 "
	cQuery +=         " on( NS3.NS3_FILIAL     = '" + xFilial("NS3") + "'"
	cQuery +=             " and NS3.NS3_CDOC   = NRX.NRX_CDOC"
	cQuery +=             " and NS3.NS3_COD    = NS4.NS4_CDESP"
	cQuery +=             " and NS3.D_E_L_E_T_ = ' ' )"

	cQuery += " where NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
	cQuery +=     " and NXA.NXA_CESCR  = '" + cCodEsc + "' "
	cQuery +=     " and NXA.NXA_COD    = '" + cFat + "' "
	cQuery +=     " and NXA.D_E_L_E_T_ = ' '"
	cQuery += " order by"
	cQuery +=     " NVY.NVY_DATA, NVY.NVY_COD"

	cQuery := ChangeQuery( cQuery )
	cQuery := StrTran(cQuery,'#','')
	TRAB   := GetNextAlias()

	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), (TRAB), .T., .T. )
	aRet[3] := 0
	If !(TRAB)->( Eof() )
		If !lAutomato
			MsgRun( STR0013, , { || aRet := GerarArq(lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "D", alog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato) } ) //Passo 2 //"Processando Despesas"
		Else
			aRet := GerarArq(lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "D", alog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato) 
		EndIf
		(TRAB)->(DbCloseArea())

		lNoData  := .F.
		lArqCria := .F.
	EndIf

	If !aRet[1]
		Return aRet
	Else
		alog      := aRet[2]
		nSomaItem += aRet[3]
	EndIf

	//QUERY PARA LANÇAMENTOS TABELADOS
	//Monta colunas Dinamicas para a Query
	aCabecArq := aClone( aCabecTab )

	cQuery := " select"
	cQuery += " NV4.R_E_C_N_O_ as RECNO_NV4, NUH_CLIEBI, NV4_COD, NV4_CCLIEN, NV4_CLOJA, NV4_CCASO, NUH_CEMP, NUR_CCAT, NV4_CMOEH CMOEDA, "

	For nx := 1 To Len( aCabecArq )	
		cQuery += If( aCabecArq[ nx ][ _TIPO_ ] $ " F", aCabecArq[ nx ][ _CONTE_ ] + " " + aCabecArq[ nx ][ _CAMPO_ ], aCabecArq[ nx ][ _CAMPO_ ] )
		If nx < Len( aCabecArq )
			cQuery += ", "
		EndIf
	Next 

	cQuery += " from"
	cQuery +=     " " + RetSqlName("NXA") + " NXA "

	cQuery +=     " inner join " + RetSqlName("NW4") + " NW4 "
	cQuery +=         " on( NW4.NW4_FILIAL     = '" + xFilial("NW4") + "'"
	cQuery +=             " and NW4.NW4_CESCR  = NXA.NXA_CESCR"
	cQuery +=             " and NW4.NW4_CFATUR = NXA.NXA_COD"
	cQuery +=             " and NW4.D_E_L_E_T_ = ' ' )"

	cQuery +=     " inner join " + RetSqlName("NV4") + " NV4 "
	cQuery +=         " on( NV4.NV4_FILIAL     = '" + xFilial("NV4") + "'"
	cQuery +=             " and NV4.NV4_COD    = NW4.NW4_CLTAB"
	cQuery +=             " and NV4.D_E_L_E_T_ = ' ' )"

	cQuery +=     " inner join " + RetSqlName("NVE") + " NVE "
	cQuery +=         " on( NVE.NVE_FILIAL     = '" + xFilial("NVE") + "'"
	cQuery +=         " and NVE.NVE_CCLIEN = NV4.NV4_CCLIEN" 
	cQuery +=         " and NVE.NVE_LCLIEN = NV4.NV4_CLOJA"
	cQuery +=         " and NVE.NVE_NUMCAS = NV4.NV4_CCASO"
	cQuery +=         " and NVE.D_E_L_E_T_ = ' ' )"

	cQuery +=     " inner join " + RetSqlName("NUR") + " NUR "
	cQuery +=         " on( NUR.NUR_FILIAL     = '" + xFilial("NUR") + "'"
	cQuery +=             " and NUR.NUR_CPART  = NV4.NV4_CPART"
	cQuery +=             " and NUR.D_E_L_E_T_ = ' ' )"

	cQuery +=     " inner join " + RetSqlName("RD0") + " RD0 "
	cQuery +=         " on( RD0.RD0_FILIAL     = '" + xFilial("RD0") + "'"
	cQuery +=             " and RD0.RD0_CODIGO = NUR.NUR_CPART"
	cQuery +=             " and RD0.D_E_L_E_T_ = ' ' )"

	cQuery +=     " inner join " + RetSqlName("NUH") + " NUH "
	cQuery +=         " on( NUH.NUH_FILIAL = '" + xFilial("NUH") + "'"
	cQuery +=         " AND NUH.NUH_COD = '" + cCliente + "' "
	cQuery +=         " AND NUH.NUH_LOJA ='" + cLoja + "' "
	cQuery +=             " and NUH.D_E_L_E_T_ = ' ' )"

	cQuery +=      " inner join " + RetSqlName("NRX") + " NRX "
	cQuery +=         " on( NRX.NRX_FILIAL     = '" + xFilial("NRX") + "'"
	cQuery +=             " and NRX.NRX_COD    = NUH.NUH_CEMP"
	cQuery +=             " and NRX.D_E_L_E_T_ = ' ' )"

	cQuery +=     " inner join " + RetSqlName("CTO") + " CTO "
	cQuery +=         " on( CTO.CTO_FILIAL     = '" + xFilial("CTO") + "'"
	cQuery +=             " and CTO.CTO_MOEDA = NXA.NXA_CMOEDA"
	cQuery +=             " and CTO.D_E_L_E_T_ = ' ' )" 

	cQuery +=      " left join " + RetSqlName("NTQ") + " NTQ "
	cQuery +=         " on( NTQ.NTQ_FILIAL     = '" + xFilial("NTQ") + "'"
	cQuery +=             " and NTQ.NTQ_CEMP   = NRX.NRX_COD"
	cQuery +=             " and NTQ.NTQ_CESCR  = NXA.NXA_CESCR"
	cQuery +=             " and NTQ.D_E_L_E_T_ = ' ' )"

	cQuery +=     " left join " + RetSqlName("NS7") + " NS7 "
	cQuery +=         " on( NS7.NS7_FILIAL     = '" + xFilial("NS7") + "'"
	cQuery +=             " and NS7.NS7_COD = NTQ.NTQ_CESCR "
	cQuery +=             " and NS7.D_E_L_E_T_ = ' ' )"

	cQuery +=     " left join " + RetSqlName("SYA") + " SYA "
	cQuery +=         " on( SYA.YA_FILIAL     = '" + xFilial("SYA") + "'"
	cQuery +=             " and SYA.YA_CODGI = NXA.NXA_PAIS "
	cQuery +=             " and SYA.D_E_L_E_T_ = ' ' )"

	cQuery +=      " left join " + RetSqlName("NS2") + " NS2 "
	cQuery +=         " on( NS2.NS2_FILIAL     = '" + xFilial("NS2") + "'"
	cQuery +=             " and NS2.NS2_CDOC   = NRX.NRX_CDOC"
	cQuery +=             " and NS2.NS2_CCATEJ = NUR.NUR_CCAT"
	cQuery +=             " and NS2.D_E_L_E_T_ = ' ' )"

	cQuery +=      " left join " + RetSqlName("NRV") + " NRV "
	cQuery +=         " on( NRV.NRV_FILIAL     = '" + xFilial("NRV") + "'"
	cQuery +=             " and NRV.NRV_CDOC   = NRX.NRX_CDOC"
	cQuery +=             " and NRV.NRV_COD    = NS2.NS2_CCATE"
	cQuery +=             " and NRV.D_E_L_E_T_ = ' ' )"

	cQuery +=      " left join " + RetSqlName("NXO") + " NXO "
	cQuery +=         " on( NXO.NXO_FILIAL     = '" + xFilial("NXO") + "'"
	cQuery +=             " and NXO.NXO_CDOC   = NRX.NRX_CDOC"
	cQuery +=             " and NXO.NXO_CSRVTJ = NV4.NV4_CTPSRV"
	cQuery +=             " and NXO.D_E_L_E_T_ = ' ' )"

	cQuery +=      " left join " + RetSqlName("NXN") + " NXN "
	cQuery +=         " on( NXN.NXN_FILIAL   = '" + xFilial("NXN") + "'"
	cQuery +=             " and NXN.NXN_CDOC = NRX.NRX_CDOC"
	cQuery +=             " and NXN.NXN_COD  = NXO.NXO_CSRVTB"
	cQuery +=             " and NXN.D_E_L_E_T_ = ' ' )"

	cQuery += " where NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
	cQuery +=     " and NXA.NXA_CESCR  = '" + cCodEsc + "' "
	cQuery +=     " and NXA.NXA_COD    = '" + cFat + "' "
	cQuery += "     and NXA.D_E_L_E_T_ = ' '"
	cQuery += " order by"
	cQuery +=     " NV4.NV4_DTLANC, NV4.NV4_COD"

	cQuery := ChangeQuery( cQuery )
	cQuery := StrTran(cQuery,'#','')
	TRAB   := GetNextAlias()

	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), (TRAB), .T., .T. )
	aRet[3] := 0
	If !(TRAB)->( Eof() )
		
		If !lAutomato
			MsgRun( STR0023, , { || aRet := GerarArq(lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "T", alog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato) } ) //Passo 2 //"Processando Despesas"
		Else
			aRet := GerarArq(lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "T", alog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato)
		EndIf
		(TRAB)->(DbCloseArea())
		
		lNoData  := .F.
		lArqCria := .F.
		
	EndIf

	If !aRet[1]
		Return aRet
	Else
		alog      := aRet[2]
		nSomaItem += aRet[3]
	EndIf

	//QUERY PARA DESCONTO OU ACRÉCIMO NA FATURA
	//Monta colunas Dinamicas para a Query 
	aCabecArq := aClone( aCabecAju )

	cQryCabec := " select"
	cQryCabec += " NXA.R_E_C_N_O_ as RECNO_NXA, NUH_CLIEBI, "

	For nx := 1 To Len( aCabecArq )
		If Upper(aCabecArq[ nx ][ _CAMPO_ ]) <> "AJUSTE"
			cQryCabec += IIf( aCabecArq[ nx ][ _TIPO_ ] $ " F", aCabecArq[ nx ][ _CONTE_ ] + " " + aCabecArq[ nx ][ _CAMPO_ ], aCabecArq[ nx][ _CAMPO_ ] )
			If nx < Len( aCabecArq )
				cQryCabec += ", "
			EndIf
		EndIf
	Next

	cQryCorpo := " FROM "
	cQryCorpo += " " + RetSqlName("NXA") + " NXA "
	cQryCorpo += " INNER JOIN " + RetSqlName("RD0") + " RD0 "
	cQryCorpo +=    " ON (RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQryCorpo +=    " AND RD0.RD0_CODIGO = NXA.NXA_CPART "
	cQryCorpo +=    " AND RD0.D_E_L_E_T_ = ' ' ) "
	cQryCorpo += " INNER JOIN " + RetSqlName("NUH") + " NUH  "
	cQryCorpo +=    " ON (NUH.NUH_FILIAL = '" + xFilial("NUH") + "' "
	cQryCorpo +=         " AND NUH.NUH_COD = '" + cCliente + "' "
	cQryCorpo +=         " AND NUH.NUH_LOJA = '" + cLoja + "' "
	cQryCorpo +=    " AND NUH.D_E_L_E_T_ = ' ' ) "
	cQryCorpo += " INNER JOIN " + RetSqlName("NRX") + " NRX  "
	cQryCorpo +=     " ON (NRX.NRX_FILIAL = '" + xFilial("NRX") + "' "
	cQryCorpo +=     " AND NRX.NRX_COD    = NUH.NUH_CEMP "
	cQryCorpo +=     " AND NRX.D_E_L_E_T_ = ' ' ) "
	cQryCorpo += " INNER JOIN " + RetSqlName("CTO") + " CTO "
	cQryCorpo +=     " ON( CTO.CTO_FILIAL     = '" + xFilial("CTO") + "'"
	cQryCorpo +=     " AND CTO.CTO_MOEDA = NXA.NXA_CMOEDA"
	cQryCorpo +=     " AND CTO.D_E_L_E_T_ = ' ' )" 
	cQryCorpo += " INNER JOIN " + RetSqlName("NTQ") + " NTQ  "
	cQryCorpo +=     " ON (NTQ.NTQ_FILIAL = '" + xFilial("NTQ") + "' "
	cQryCorpo +=     " AND NTQ.NTQ_CEMP   = NRX.NRX_COD "
	cQryCorpo +=     " AND NTQ.NTQ_CESCR  = NXA.NXA_CESCR "
	cQryCorpo +=     " AND NTQ.D_E_L_E_T_ = ' ' ) "
	cQryCorpo += " LEFT JOIN " + RetSqlName("NS7") + " NS7 "
	cQryCorpo +=     " ON( NS7.NS7_FILIAL     = '" + xFilial("NS7") + "'"
	cQryCorpo +=     " AND NS7.NS7_COD = NTQ.NTQ_CESCR "
	cQryCorpo +=     " AND NS7.D_E_L_E_T_ = ' ' )"
	cQryCorpo += " LEFT JOIN " + RetSqlName("SYA") + " SYA "
	cQryCorpo +=     " ON( SYA.YA_FILIAL     = '" + xFilial("SYA") + "'"
	cQryCorpo +=     " AND SYA.YA_CODGI = NXA.NXA_PAIS "
	cQryCorpo +=     " AND SYA.D_E_L_E_T_ = ' ' )"

	cQryCorpo += " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
	cQryCorpo +=   " AND NXA.NXA_CESCR  = '" + cCodEsc + "' "
	cQryCorpo +=   " AND NXA.NXA_COD    = '" + cFat + "' "
	cQryCorpo +=   " AND NXA.D_E_L_E_T_ = ' '"

	cQuery := cQryCabec + CRLF + ", NXA_VLACRE AS AJUSTE, 0 AS GROSSUPHON " + cQryCorpo + " AND NXA.NXA_VLACRE > 0 "
	cQuery += "UNION ALL" + CRLF
	cQuery += cQryCabec + CRLF + ", -(NXA_VLDESC) AS AJUSTE, 0 AS GROSSUPHON " + cQryCorpo + " AND NXA.NXA_VLDESC > 0 "
	If NXA->(ColumnPos("NXA_VGROSH")) > 0
		cQuery += "UNION ALL" + CRLF
		cQuery += cQryCabec + CRLF + ", 0 AS AJUSTE, NXA_VGROSH AS GROSSUPHON " + cQryCorpo + " AND NXA.NXA_VGROSH > 0 "
	EndIf

	cQuery := ChangeQuery( cQuery )
	cQuery := StrTran(cQuery,'#','')
	TRAB   := GetNextAlias()

	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), (TRAB), .T., .T. )
	aRet[3] := 0
	If !(TRAB)->( Eof() )
		If !lAutomato
			MsgRun( STR0022, , { || aRet := GerarArq( lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "A", aLog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato) } ) //Passo 1 //"Processando Ajuste"
		Else
			aRet := GerarArq( lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "A", aLog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato) 
		EndIf 
		(TRAB)->( DbCloseArea() )

		lNoData  := .F.
		lArqCria := .F.
	EndIf

	If !aRet[1]
		Return aRet
	Else
		alog      := aRet[2]
		nSomaItem += aRet[3]
	EndIf

	//QUERY PARA IMPOSTOS
	//Monta colunas Dinamicas para a Query 
	aCabecArq := aClone( aCabecImp )

	cQryCabec := " select"
	cQryCabec += " NXA.R_E_C_N_O_ RECNO_NXA, NUH_CLIEBI, "

	For nx := 1 To Len( aCabecArq )
		If Upper(aCabecArq[ nx ][ _CAMPO_ ]) <> "IMPOSTO" .And. Upper(aCabecArq[ nx ][ _CAMPO_ ]) <> "VALORIMP"
			cQryCabec += IIf( aCabecArq[ nx ][ _TIPO_ ] $ " F", aCabecArq[ nx ][ _CONTE_ ] + " " + aCabecArq[ nx ][ _CAMPO_ ], aCabecArq[ nx][ _CAMPO_ ] )
			If nx < Len( aCabecArq )
				cQryCabec += ", "
			EndIf
		EndIf
	Next

	cQryCorpo := " FROM "
	cQryCorpo +=      " " + RetSqlName("NXA") + " NXA "
	cQryCorpo += " INNER JOIN " + RetSqlName("RD0") + " RD0 "
	cQryCorpo +=    " ON (RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
	cQryCorpo +=    " AND RD0.RD0_CODIGO = NXA.NXA_CPART "
	cQryCorpo +=    " AND RD0.D_E_L_E_T_ = ' ' ) "
	cQryCorpo += " INNER JOIN " + RetSqlName("NUH") + " NUH  "
	cQryCorpo +=       " ON (NUH.NUH_FILIAL = '" + xFilial("NUH") + "' "
	cQryCorpo +=       " AND NUH.NUH_COD    = '" + cCliente + "' "
	cQryCorpo +=       " AND NUH.NUH_LOJA   ='" + cLoja + "' "
	cQryCorpo +=       " AND NUH.D_E_L_E_T_ = ' ' ) "
	cQryCorpo += " INNER JOIN " + RetSqlName("NRX") + " NRX  "
	cQryCorpo +=       " ON (NRX.NRX_FILIAL = '" + xFilial("NRX") + "' "
	cQryCorpo +=       " AND NRX.NRX_COD    = NUH.NUH_CEMP "
	cQryCorpo +=       " AND NRX.D_E_L_E_T_ = ' ' ) "
	cQryCorpo += " INNER JOIN " + RetSqlName("CTO") + " CTO "
	cQryCorpo +=       " ON ( CTO.CTO_FILIAL     = '" + xFilial("CTO") + "'"
	cQryCorpo +=       " AND CTO.CTO_MOEDA = NXA.NXA_CMOEDA"
	cQryCorpo +=       " AND CTO.D_E_L_E_T_ = ' ' )" 
	cQryCorpo += " INNER JOIN " + RetSqlName("NTQ") + " NTQ  "
	cQryCorpo +=       " ON (NTQ.NTQ_FILIAL = '" + xFilial("NTQ") + "' "
	cQryCorpo +=       " AND NTQ.NTQ_CEMP   = NRX.NRX_COD "
	cQryCorpo +=       " AND NTQ.NTQ_CESCR  = NXA.NXA_CESCR "
	cQryCorpo +=       " AND NTQ.D_E_L_E_T_ = ' ' ) "
	cQryCorpo += " LEFT JOIN " + RetSqlName("NS7") + " NS7 "
	cQryCorpo +=       " ON( NS7.NS7_FILIAL     = '" + xFilial("NS7") + "'"
	cQryCorpo +=       " AND NS7.NS7_COD = NTQ.NTQ_CESCR "
	cQryCorpo +=       " AND NS7.D_E_L_E_T_ = ' ' )"
	cQryCorpo += " LEFT JOIN " + RetSqlName("SYA") + " SYA "
	cQryCorpo +=       " ON( SYA.YA_FILIAL     = '" + xFilial("SYA") + "'"
	cQryCorpo +=       " AND SYA.YA_CODGI = NXA.NXA_PAIS "
	cQryCorpo +=       " AND SYA.D_E_L_E_T_ = ' ' )"

	cQryCorpo += " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
	cQryCorpo +=     " AND NXA.NXA_CESCR  = '" + cCodEsc + "' "
	cQryCorpo +=     " AND NXA.NXA_COD    = '" + cFat + "' "
	cQryCorpo +=     " AND NXA.D_E_L_E_T_ = ' '"

	cQuery := cQryCabec + CRLF + ", -(NXA_IRRF) AS VALORIMP, 'IRRF' AS IMPOSTO " + cQryCorpo + " AND NXA.NXA_IRRF > 0 " + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += cQryCabec + CRLF + ", -(NXA_PIS) AS VALORIMP, 'PIS' AS IMPOSTO " + cQryCorpo + " AND NXA.NXA_PIS > 0 " + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += cQryCabec + CRLF + ", -(NXA_COFINS) AS VALORIMP, 'COFINS' AS IMPOSTO " + cQryCorpo + " AND NXA.NXA_COFINS > 0 " + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += cQryCabec + CRLF + ", -(NXA_CSLL) AS VALORIMP, 'CSLL' AS IMPOSTO " + cQryCorpo + " AND NXA.NXA_CSLL > 0 " + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += cQryCabec + CRLF + ", -(NXA_INSS) AS VALORIMP, 'INSS' AS IMPOSTO " + cQryCorpo + " AND NXA.NXA_INSS > 0 " + CRLF
	cQuery += "UNION ALL" + CRLF
	cQuery += cQryCabec + CRLF + ", -(NXA_ISS) AS VALORIMP, 'ISS' AS IMPOSTO " + cQryCorpo + " AND NXA.NXA_ISS > 0 " + CRLF

	cQuery := ChangeQuery( cQuery )
	cQuery := StrTran(cQuery,'#','')
	TRAB   := GetNextAlias()

	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), (TRAB), .T., .T. )
	aRet[3] := 0
	If !(TRAB)->( Eof() )
		If !lAutomato
			MsgRun( STR0023, , { || aRet := GerarArq( lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "I", aLog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato) } ) //Passo 1 //"Processando Impostos"
		Else
			aRet := GerarArq( lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "I", aLog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato)
		EndIf
		(TRAB)->( DbCloseArea() )

		lNoData  := .F.
		lArqCria := .F.
	EndIf

	If lNoData
		If lAutomato
			aRet := {.F., {STR0012}}
		Else
			MsgStop( STR0012 ) //"Não foram encontrados dados para geração do arquivo."
		EndIf
	Else
		alog      := aRet[2]
		nSomaItem += aRet[3]
		
		//QUERY PARA AJUSTAR AS DIFERENÇAS DE ARREDONDAMENTO
		//Monta colunas Dinamicas para a Query 
		aCabecArq := aClone( aCabecAju )
		
		cQryCabec := " select"
		cQryCabec +=      " NXA.R_E_C_N_O_ as RECNO_NXA, NUH_CLIEBI, "
		
		For nx := 1 To Len( aCabecArq )
			If Upper(aCabecArq[ nx ][ _CAMPO_ ]) <> "AJUSTE"
				cQryCabec += IIf( aCabecArq[ nx ][ _TIPO_ ] $ " F", aCabecArq[ nx ][ _CONTE_ ] + " " + aCabecArq[ nx ][ _CAMPO_ ], aCabecArq[ nx][ _CAMPO_ ] )
				If nx < Len( aCabecArq )
					cQryCabec += ", "
				EndIf
			EndIf
		Next
		
		cQryCorpo := " FROM "
		cQryCorpo += " " + RetSqlName("NXA") + " NXA "
		cQryCorpo += " INNER JOIN " + RetSqlName("RD0") + " RD0 "
		cQryCorpo +=    " ON (RD0.RD0_FILIAL = '" + xFilial("RD0") + "' "
		cQryCorpo +=    " AND RD0.RD0_CODIGO = NXA.NXA_CPART "
		cQryCorpo +=    " AND RD0.D_E_L_E_T_ = ' ' ) "
		cQryCorpo += " INNER JOIN " + RetSqlName("NUH") + " NUH  "
		cQryCorpo +=    " ON (NUH.NUH_FILIAL = '" + xFilial("NUH") + "' "
		cQryCorpo +=       " AND NUH.NUH_COD    = '" + cCliente + "' "
		cQryCorpo +=       " AND NUH.NUH_LOJA   ='" + cLoja + "' "
		cQryCorpo +=    " AND NUH.D_E_L_E_T_ = ' ' ) "
		cQryCorpo += " INNER JOIN " + RetSqlName("NRX") + " NRX  "
		cQryCorpo +=     " ON (NRX.NRX_FILIAL = '" + xFilial("NRX") + "' "
		cQryCorpo +=     " AND NRX.NRX_COD    = NUH.NUH_CEMP "
		cQryCorpo +=     " AND NRX.D_E_L_E_T_ = ' ' ) "
		cQryCorpo += " INNER JOIN " + RetSqlName("CTO") + " CTO "
		cQryCorpo +=       " ON ( CTO.CTO_FILIAL     = '" + xFilial("CTO") + "'"
		cQryCorpo +=       " AND CTO.CTO_MOEDA = NXA.NXA_CMOEDA"
		cQryCorpo +=       " AND CTO.D_E_L_E_T_ = ' ' )" 
		cQryCorpo += " INNER JOIN " + RetSqlName("NTQ") + " NTQ  "
		cQryCorpo +=     " ON (NTQ.NTQ_FILIAL = '" + xFilial("NTQ") + "' "
		cQryCorpo +=     " AND NTQ.NTQ_CEMP   = NRX.NRX_COD "
		cQryCorpo +=     " AND NTQ.NTQ_CESCR  = NXA.NXA_CESCR "
		cQryCorpo +=     " AND NTQ.D_E_L_E_T_ = ' ' ) "
		cQryCorpo += " LEFT JOIN " + RetSqlName("NS7") + " NS7 "
		cQryCorpo +=       " ON( NS7.NS7_FILIAL     = '" + xFilial("NS7") + "'"
		cQryCorpo +=       " AND NS7.NS7_COD = NTQ.NTQ_CESCR "
		cQryCorpo +=       " AND NS7.D_E_L_E_T_ = ' ' )"
		cQryCorpo += " LEFT JOIN " + RetSqlName("SYA") + " SYA "
		cQryCorpo +=       " ON( SYA.YA_FILIAL     = '" + xFilial("SYA") + "'"
		cQryCorpo +=       " AND SYA.YA_CODGI = NXA.NXA_PAIS "
		cQryCorpo +=       " AND SYA.D_E_L_E_T_ = ' ' )"
		cQryCorpo += " WHERE NXA.NXA_FILIAL = '" + xFilial("NXA") + "'"
		cQryCorpo +=     " AND NXA.NXA_CESCR  = '" + cCodEsc + "' "
		cQryCorpo +=     " AND NXA.NXA_COD    = '" + cFat + "' "
		cQryCorpo += " and NXA.D_E_L_E_T_ = ' '"

		cQuery := cQryCabec + CRLF + ", (NXA_VLFATH-NXA_VLDESC+NXA_VLFATD+NXA_VLACRE-NXA_IRRF-NXA_PIS-NXA_COFINS-NXA_CSLL-NXA_INSS-NXA_ISS" + cCpoGrossH + ") AS AJUSTE " + cQryCorpo

		cQuery := ChangeQuery( cQuery )
		cQuery := StrTran(cQuery,'#','')
		TRAB   := GetNextAlias()
		
		dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery ), (TRAB), .T., .T. )
		aRet[3] := 0
		If !(TRAB)->( Eof() ) 
			If !lAutomato
				MsgRun( STR0022, , { || aRet := GerarArq( lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "R", aLog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato) } ) //Passo 1 //"Processando Ajuste"
			Else
				aRet := GerarArq( lArqCria, cDArq, cNArq, TRAB, cFat, cCodEsc, "R", aLog, @nCount, cMoeFat, cMoeEbi, @nSomaItem, aPerFat, aCabecArq, lAutomato)
			EndIf
			(TRAB)->( DbCloseArea() )
		
			lNoData  := .F.
			lArqCria := .F.
		EndIf
		If !aRet[1]
			Return aRet
		Else
			alog      := aRet[2]
			nSomaItem += aRet[3]
		EndIf

		For nx := 1 To Len(aLog)
			For ny := 1 To Len(aLog[nx])
				cMemolog += aLog[nx][ny][2] + CRLF
			Next ny
		Next nx
		
		If !Empty(cMemolog)
			cFat     := "'" + cCodEsc + cFat + "'"
			cMemolog := STR0025 + Alltrim(cDArq) + Alltrim(cNArq) + ".txt" + STR0024 + cFat + STR0026 + CRLF + CRLF + cMemolog //"O Arquivo " ## " da fatura " ### " foi gerado com as seguintes inconsistências:"
			If !lAutomato
				JurErrLog(cMemolog, STR0001) //"Geração de Arquivo Texto LEDES1998B"
			Else
				aRet[2] := {cMemolog}
			EndIf
		Else
			If !lAutomato
				MsgInfo( STR0014, STR0015 )  //"Arquivo processado com sucesso." ## "Arquivo Gerado"
			Else
				aRet[2] := {STR0015}
			EndIf
		EndIf

		If aRet[1]
			JLDFlagFat(NXA->(Recno()))
		EndIf
	EndIf

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GerarArq
Geração do arquivo texto.

@author SISJURI
@since 06/03/2010
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GerarArq(lArqCria, cPath, cNome, TRAB, cFat, cCodEsc, cTipo, aLog, nCount, cMoeFat, cMoeEbi, nSomaItem, aPerFat, aCabecArq, lAutomato)
Local nx          := 0
Local ctxtCabec   := ""
Local cDetalhe    := ""
Local VALOR       := Nil
Local lRet        := .T.
Local cSigla      := ""
Local cNomePart   := ""
Local nVtot       := 0
Local nValor      := 0
Local nTamEndEsc  := TamSx3("NS7_END")[1]
Local nTamEndCli  := TamSx3("NXA_LOGRAD")[1]
Local aValor      := {}
Local dEmiFat     := JurGetDados('NXA', 1, xFilial('NXA') + cCodEsc + cFat, 'NXA_DTEMI')
Local lGrava      := .T. //variável de controle para gravar
Local cIniLancs   := ""
Local cFimLancs   := ""
Local cPathArq    := ""
 
Default alog      := {}
Default nCount    := 0
Default lAutomato := .F.

// Proteção devido a mudança do retorno da JGetPerFT - retirar após os clientes estarem na 12.1.23
If Len(aPerFat) > 1
	cIniLancs := Dtos(aPerFat[1])
	cFimLancs := Dtos(aPerFat[2])
Else
	cIniLancs := aPerFat[1][1]
	cFimLancs := aPerFat[1][2]
EndIf

If lArqCria //ARQUIVO TEXTO AINDA NAO FOI CRIADO, NECESSITA INICIALIZA-LO
	
	If !lAutomato .And. Empty( cPath )
		If !lAutomato
			MsgInfo( STR0020, STR0007 )  //"Informe o caminho onde deseja gravar o arquivo!" "###"Atencao"
		EndIf
		Return {.F., {}}
	EndIf
	
	cPathArq := AllTrim( cPath ) + Alltrim ( cNome ) + ".txt"
	
	// Verifica se o Arquivo ja existe
	If File( cPathArq )
		If !lAutomato .And. !MsgYesNo( STR0016, STR0007 ) //"Ja existe um arquivo com este nome. Deseja sobrepor ?"###"Atencao"
			Return {.F., {}}
		Else
			FErase( cPathArq )
		EndIf
	EndIf
	
	nHandle := FCREATE( cPathArq, 0 )
	
	If ! FERROR() == 0
		If !lAutomato
			Alert( STR0017 + cPathArq ) //"Não foi possível criar o arquivo: "
		EndIf
		Return {.F., {}}
	EndIf
	
	//GRAVA LINHA FIXA E CABECALHO DOS CAMPOS
	ctxtCabec := "LEDES1998B" + "[]" + CRLF
	For nx := 1 To Len ( aCabecArq )
		ctxtCabec += aCabecArq[ nx ][ _DESCR_ ] + If( nx == Len( aCabecArq ), "[]" + CRLF, "|" )
	Next
	
	If FWRITE( nHandle, ctxtCabec ) == 0
		If !lAutomato
			Alert( STR0018 )  //"Não foi possível gravar cabecalho do arquivo!"
		EndIf
		Return {.F., {}}
	EndIf
	
Else // Inclusao de novos Dados no mesmo arquivo
	cPathArq := AllTrim( cPath ) + Alltrim ( cNome ) + ".txt"
	nHandle  := FOpen( cPathArq, 2 )
	FSeek( nHandle, 0, 2 )
EndIf

//GRAVA LINHAS DE DADOS
Do While (TRAB)->( ! Eof() ) .And. lRet
	
	cDetalhe := ""
	
	For nx := 1 To Len( aCabecArq )
		
		If aCabecArq [ nx ][ _TIPO_ ] == "D"
			cDetalhe += Dtos( (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ) )
		Else
			If cTipo $ "H|F"
				Do Case
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'NUE_DESC'
					NUE->( dbGoTo( (TRAB)->RECNO_NUE ) )
					VALOR := StrTran(NUE->NUE_DESC, CRLF, " ")
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP3'
					VALOR := GetDescCasos( (TRAB)->EXP3, cFat, cCodEsc )
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP6'
					nCount++
					VALOR := AllTrim(Str(nCount))
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'NUE_CPART2'
					VALOR  := Posicione('RD0', 1, xFilial('RD0') + (TRAB)->NUE_CPART2, 'RD0_SIGLA')
					cSigla := Alltrim(VALOR)
					
				//Efetua a conversão dos valores para a moeda e-billing
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP2' .Or. aCabecArq[ nx ][ _CAMPO_ ] == 'EXP20' //"INVOICE_TOTAL/INVOICE_NET_TOTAL na moeda da fatura"
					aValor := JA201FConv( cMoeEbi, cMoeFat, (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), '8', dEmiFat, , , , cCodEsc, cFat )
					If !Empty(aValor[4])
						If !lAutomato
							Alert(aValor[4])
						EndIf
						lRet := .F.
						Exit
					Else
						VALOR  := Round(aValor[1], 2)
					EndIf
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP21'
					cNomePart := Alltrim((TRAB)->EXP21)
					VALOR     := Substr(cNomePart, Rat(" ", cNomePart) + 1, Len(cNomePart))
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP22'
					cNomePart := Alltrim((TRAB)->EXP22)
					VALOR     := Substr(cNomePart,1,At(" ", cNomePart)-1)
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP26'
					VALOR := Posicione('CC2', 1, xFilial('CC2') + (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'CC2_MUN')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP27'
					VALOR := Posicione('SX5', 1, xFilial('SX5') + '12' + (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'X5_DESCRI')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP36'
					VALOR := Posicione('SYA', 1, xFilial('SYA') + (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'YA_SIGLA')
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP37'
					VALOR := Posicione('SA1', 1, xFilial('SA1') + (TRAB)->EXP37, 'A1_PAIS')
					VALOR := Posicione('SYA', 1, xFilial('SYA') + VALOR, 'YA_SIGLA')
				
				Case aCabecArq[ nx ][ _CAMPO_ ] $ 'NUE_VALOR|NUE_VALORH|NT1_VALORA' // 'LINE_ITEM_TOTAL|LINE_ITEM_UNIT_COST' na moeda do lançamento
					aValor := JA201FConv( cMoeEbi, (TRAB)->CMOEDA, (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), '8', dEmiFat, , , , cCodEsc, cFat )
					If !Empty(aValor[4])
						If !lAutomato
							Alert(aValor[4])
						EndIf
						lRet := .F.
						Exit
					Else
						nDecimal := Iif(aCabecArq[nx][_CAMPO_] == 'NUE_VALORH', 4, 2)
						VALOR    := Round(aValor[1], nDecimal)
						
						If aCabecArq[ nx ][ _DESCR_ ] == 'LINE_ITEM_TOTAL'
							nVtot += VALOR
						EndIf
					EndIf
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP15'
					cDetalhe += cIniLancs

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP16'
					cDetalhe += cFimLancs

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP18'
					VALOR := GetDescCasos( (TRAB)->EXP3, cFat, cCodEsc )
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP24'
					VALOR := Alltrim(Substr((TRAB)->EXP24, 1, nTamEndEsc)) + " " + Alltrim(Substr((TRAB)->EXP24, nTamEndEsc + 1, Len((TRAB)->EXP24)))

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP28'
					VALOR := Alltrim(Substr((TRAB)->EXP28, 1, nTamEndCli)) + " " + Alltrim(Substr((TRAB)->EXP28, nTamEndCli + 1, Len((TRAB)->EXP28)))

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'NT1_DESCRI'
					NT1->(DbGoTo((TRAB)->RECNO_NT1))
					VALOR := StrTran(NT1->NT1_DESCRI, Chr(13) + Chr(10), " ")
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP38'
					If Empty((TRAB)->NT0_TITFAT)
						If Empty((TRAB)->NT5_TITULO)
							VALOR := (TRAB)->NT0_NOME
						Else
							VALOR := (TRAB)->NT5_TITULO
						EndIf
					Else
						VALOR := (TRAB)->NT0_TITFAT
					EndIf

				Otherwise
					VALOR := (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] )
				EndCase
				
			ElseIf cTipo == "D"
				
				Do Case
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'NVY_DESCRI'
					NVY->( dbGoTo( (TRAB)->RECNO_NVY ) )
					VALOR := StrTran(NVY->NVY_DESCRI, CRLF, " ")
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP3'
					VALOR := GetDescCasos( (TRAB)->EXP3, cFat, cCodEsc )
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP4'
					nCount++
					VALOR := AllTrim(Str(nCount))
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'NVY_CPART'
					VALOR := Posicione('RD0', 1, xFilial('RD0') + (TRAB)->NVY_CPART, 'RD0_SIGLA')
					
				//Efetua a conversão dos valores para a moeda e-billing
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP2' .Or. aCabecArq[ nx ][ _CAMPO_ ] == 'EXP20' //"INVOICE_TOTAL/INVOICE_NET_TOTAL na moeda da fatura"
					aValor := JA201FConv( cMoeEbi, cMoeFat, (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), '8', dEmiFat, , , , cCodEsc, cFat )
					If !Empty(aValor[4])
						If !lAutomato
							Alert(aValor[4])
						EndIf
						lRet := .F.
						Exit
					Else
						VALOR  := Round(aValor[1],2)
					EndIf
					
				Case aCabecArq[ nx ][ _CAMPO_ ] $ 'EXP6|EXP9' // 'LINE_ITEM_TOTAL|LINE_ITEM_UNIT_COST' na moeda do lançamento
					aValor := JA201FConv( cMoeEbi, (TRAB)->CMOEDA, (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), '8', dEmiFat, , , , cCodEsc, cFat )
					If !Empty(aValor[4])
						If !lAutomato
							Alert(aValor[4])
						EndIf
						lRet := .F.
						Exit
					Else
						nDecimal := Iif(aCabecArq[nx][_CAMPO_] == 'EXP9', 4, 2)
						VALOR  := Round(aValor[1],nDecimal)
						
						If aCabecArq[ nx ][ _DESCR_ ] == 'LINE_ITEM_TOTAL'
							nVtot	+= VALOR
						EndIf
					EndIf
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP15'
					cDetalhe += cIniLancs
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP16'
					cDetalhe += cFimLancs
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP18'
					VALOR := GetDescCasos( (TRAB)->EXP3, cFat, cCodEsc )

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP21'
					cNomePart := Alltrim((TRAB)->EXP21)
					VALOR     := Substr(cNomePart, Rat(" ", cNomePart) + 1, Len(cNomePart))
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP22'
					cNomePart := Alltrim((TRAB)->EXP22)
					VALOR     := Substr(cNomePart, 1, At(" ", cNomePart) - 1)
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP26'
					VALOR := Posicione('CC2', 1, xFilial('CC2') + (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'CC2_MUN')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP27'
					VALOR := Posicione('SX5', 1, xFilial('SX5') + '12' + (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'X5_DESCRI')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP36'
					VALOR := Posicione('SYA', 1, xFilial('SYA') + (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'YA_SIGLA')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP37'
					VALOR := Posicione('SA1', 1, xFilial('SA1') + (TRAB)->EXP37, 'A1_PAIS')
					VALOR := Posicione('SYA', 1, xFilial('SYA') + VALOR, 'YA_SIGLA')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP24'
					VALOR := Alltrim(Substr((TRAB)->EXP24, 1, nTamEndEsc)) + " " + Alltrim(Substr((TRAB)->EXP24, nTamEndEsc + 1, Len((TRAB)->EXP24)))

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP28'
					VALOR := Alltrim(Substr((TRAB)->EXP28, 1, nTamEndCli)) + " " + Alltrim(Substr((TRAB)->EXP28, nTamEndCli + 1, Len((TRAB)->EXP28)))
					
				Otherwise
					VALOR := (TRAB)->&(aCabecArq[ nx ][ _CAMPO_ ] )
				EndCase
				
			ElseIf cTipo == "T"
				
				Do Case
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'NV4_DESCRI'
					NV4->( dbGoTo( (TRAB)->RECNO_NV4 ) )
					VALOR := StrTran(NV4->NV4_DESCRI, CRLF, " ")
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP3'
					VALOR := GetDescCasos( (TRAB)->EXP3, cFat, cCodEsc )
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP4'
					nCount++
					VALOR := AllTrim(Str(nCount))
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'NV4_CPART'
					VALOR := Posicione('RD0', 1, xFilial('RD0') + (TRAB)->NV4_CPART, 'RD0_SIGLA')
					
				//Efetua a conversão dos valores para a moeda e-billing
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP2' .Or. aCabecArq[ nx ][ _CAMPO_ ] == 'EXP20' //"INVOICE_TOTAL/INVOICE_NET_TOTAL na moeda da fatura"
					aValor := JA201FConv( cMoeEbi, cMoeFat, (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), '8', dEmiFat, , , , cCodEsc, cFat )
					If !Empty(aValor[4])
						If !lAutomato
							Alert(aValor[4])
						EndIf
						lRet := .F.
						Exit
					Else
						VALOR  := Round(aValor[1],2)
					EndIf
					
				Case aCabecArq[ nx ][ _CAMPO_ ] $ 'EXP6|EXP9' // 'LINE_ITEM_TOTAL|LINE_ITEM_UNIT_COST' na moeda do lançamento
					aValor := JA201FConv( cMoeEbi, (TRAB)->CMOEDA, (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), '8', dEmiFat, , , , cCodEsc, cFat )
					If !Empty(aValor[4])
						If !lAutomato
							Alert(aValor[4])
						EndIf
						lRet := .F.
						Exit
					Else
						nDecimal := Iif(aCabecArq[nx][_CAMPO_] == 'EXP9', 4, 2)
						VALOR    := Round(aValor[1], nDecimal)
						
						If aCabecArq[ nx ][ _DESCR_ ] == 'LINE_ITEM_TOTAL'
							nVtot += VALOR
						EndIf
					EndIf
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP15'
					cDetalhe += cIniLancs
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP16'
					cDetalhe += cFimLancs
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP18'
					VALOR := GetDescCasos( (TRAB)->EXP3, cFat, cCodEsc )
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP21'
					cNomePart := Alltrim((TRAB)->EXP21)
					VALOR     := Substr(cNomePart, Rat(" ", cNomePart) + 1, Len(cNomePart))
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP22'
					cNomePart := Alltrim((TRAB)->EXP22)
					VALOR     := Substr(cNomePart, 1, At(" ", cNomePart) - 1)
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP26'
					VALOR := Posicione('CC2', 1, xFilial('CC2') + (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'CC2_MUN')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP27'
					VALOR := Posicione('SX5', 1, xFilial('SX5') + '12'+(TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'X5_DESCRI')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP36'
					VALOR := Posicione('SYA', 1, xFilial('SYA')+(TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'YA_SIGLA')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP37'
					VALOR := Posicione('SA1', 1, xFilial('SA1') + (TRAB)->EXP37, 'A1_PAIS')
					VALOR := Posicione('SYA', 1, xFilial('SYA') + VALOR, 'YA_SIGLA')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP24'
					VALOR := Alltrim(Substr((TRAB)->EXP24, 1, nTamEndEsc)) + " " + Alltrim(Substr((TRAB)->EXP24, nTamEndEsc + 1, Len((TRAB)->EXP24)))

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP28'
					VALOR := Alltrim(Substr((TRAB)->EXP28, 1, nTamEndCli)) + " " + Alltrim(Substr((TRAB)->EXP28, nTamEndCli + 1, Len((TRAB)->EXP28)))
					
				Otherwise
					VALOR := (TRAB)->&(aCabecArq[ nx ][ _CAMPO_ ] )
				EndCase
				
			ElseIf cTipo $ "A|R"
				
				Do Case
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'AJUSTE'
					nValor := (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] )

					If nValor == 0 .And. cTipo == "A" // Em caso de GrossUp de honorários o campo AJUSTE fica zerado, e o valor fica no GROSSUPHON
						nValor := (TRAB)->GROSSUPHON
					EndIf

					aValor := JA201FConv( cMoeEbi, cMoeFat, nValor, '8', dEmiFat, , , , cCodEsc, cFat )
					If !Empty(aValor[4])
						If !lAutomato
							Alert(aValor[4])
						EndIf
						lRet := .F.
						Exit
					Else
						If cTipo == "A"
							VALOR  := aValor[1] // Desconto / Acréscimo Linear / Gross up de honorários
							If aCabecArq[ nx ][ _DESCR_ ] == 'LINE_ITEM_ADJUSTMENT_AMOUNT'
								nVtot += VALOR
							EndIf
						ElseIf cTipo == "R" // Ajustar as diferenças de arredondamento
							VALOR  := Round((aValor[1] - nSomaItem), 2)
						EndIf

						If VALOR == 0
							lGrava := .F.
							Exit
						EndIf
					EndIf

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP1'
					VALOR := LDMatterId("", cCodEsc, cFat)
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP3' .Or. aCabecArq[ nx ][ _CAMPO_ ] == 'EXP18'
					//Trata a descrição do Acréscimo / Desconto / Ajuste
					//Se o idioma da fatura for '01' (português) exibir em português, para qualquer outro, em inglês.
					cIdiFat := JurGetDados("NXA", 1, xFilial("NXA") + cCodEsc + cFat, "NXA_CIDIO")
					If cIdiFat == '01'
						If cTipo == "A"
							If (TRAB)->AJUSTE > 0
								VALOR := 'Acréscimo Linear'
							ElseIf (TRAB)->GROSSUPHON > 0
								VALOR := 'Gross up Honorários'
							Else
								VALOR := 'Desconto Linear'	
							EndIf
						ElseIf cTipo == "R"
							VALOR := 'Ajuste'
						EndIf
					Else
						If cTipo == "A"
							If (TRAB)->AJUSTE > 0
								VALOR := 'Linear Accrued'
							ElseIf (TRAB)->GROSSUPHON > 0
								VALOR := 'Gross up Fees'
							Else
								VALOR := 'Linear Discount'
							EndIf
						ElseIf cTipo == "R"
							VALOR := 'Adjust'
						EndIf
					EndIf
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP4'
					nCount++
					VALOR := AllTrim(Str(nCount))
					
				//Efetua a conversão dos valores para a moeda e-billing
				Case aCabecArq[ nx ][ _CAMPO_ ] $ 'EXP2|EXP11|EXP20'
					aValor := JA201FConv( cMoeEbi, cMoeFat, (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), '8', dEmiFat, , , , cCodEsc, cFat )
					If !Empty(aValor[4])
						If !lAutomato
							Alert(aValor[4])
						EndIf
						lRet := .F.
						Exit
					Else
						VALOR  := Round(aValor[1],2)
					EndIf

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP14'
					VALOR := LDMatterId("", cCodEsc, cFat, "C")
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP15'
					cDetalhe += cIniLancs
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP16'
					cDetalhe += cFimLancs
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP26'
					VALOR := Posicione('CC2', 1, xFilial('CC2')+(TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'CC2_MUN')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP27'
					VALOR := Posicione('SX5', 1, xFilial('SX5') + '12'+(TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'X5_DESCRI')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP36'
					VALOR := Posicione('SYA', 1, xFilial('SYA') + (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'YA_SIGLA')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP37'
					VALOR := Posicione('SA1', 1, xFilial('SA1') + (TRAB)->EXP37, 'A1_PAIS')
					VALOR := Posicione('SYA', 1, xFilial('SYA') + VALOR, 'YA_SIGLA')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP24'
					VALOR := Alltrim(Substr((TRAB)->EXP24, 1, nTamEndEsc)) + " " + Alltrim(Substr((TRAB)->EXP24, nTamEndEsc + 1, Len((TRAB)->EXP24)))

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP28'
					VALOR := Alltrim(Substr((TRAB)->EXP28, 1, nTamEndCli)) + " " + Alltrim(Substr((TRAB)->EXP28, nTamEndCli + 1, Len((TRAB)->EXP28)))
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP21'
					cNomePart := Alltrim((TRAB)->EXP21)
					VALOR     := Substr(cNomePart, Rat(" ", cNomePart) + 1, Len(cNomePart))
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP22'
					cNomePart := Alltrim((TRAB)->EXP22)
					VALOR     := Substr(cNomePart,1,At(" ", cNomePart)-1)					
				Otherwise
					VALOR := (TRAB)->&(aCabecArq[ nx ][ _CAMPO_ ] )
				EndCase
				
			ElseIf cTipo == "I"
				
				Do Case
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP1'
					VALOR := LDMatterId("", cCodEsc, cFat)
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP4'
					nCount++
					VALOR := AllTrim(Str(nCount))
					
				//Efetua a conversão dos valores para a moeda e-billing
				Case aCabecArq[ nx ][ _CAMPO_ ] $ 'EXP2|EXP11|VALORIMP|EXP20'
					aValor := JA201FConv( cMoeEbi, cMoeFat, (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), '8', dEmiFat, , , , cCodEsc, cFat )
					If !Empty(aValor[4])
						If !lAutomato
							Alert(aValor[4])
						EndIf
						lRet := .F.
						Exit
					Else
						VALOR  := Round(aValor[1],2)
						If aCabecArq[ nx ][ _DESCR_ ] == 'LINE_ITEM_TOTAL'
							nVtot += VALOR
						EndIf
					EndIf
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP14'
					VALOR := LDMatterId("", cCodEsc, cFat, "C")
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP15'
					cDetalhe += cIniLancs
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP16'
					cDetalhe += cFimLancs
					
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP26'
					VALOR := Posicione('CC2', 1, xFilial('CC2') + (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'CC2_MUN')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP27'
					VALOR := Posicione('SX5', 1, xFilial('SX5') +'12'+ (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'X5_DESCRI')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP36'
					VALOR := Posicione('SYA', 1, xFilial('SYA') + (TRAB)->&( aCabecArq[ nx ][ _CAMPO_ ] ), 'YA_SIGLA')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP37'
					VALOR := Posicione('SA1', 1, xFilial('SA1') + (TRAB)->EXP37, 'A1_PAIS')
					VALOR := Posicione('SYA', 1, xFilial('SYA') + VALOR, 'YA_SIGLA')

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP24'
					VALOR := Alltrim(Substr((TRAB)->EXP24, 1, nTamEndEsc)) + " " + Alltrim(Substr((TRAB)->EXP24, nTamEndEsc + 1, Len((TRAB)->EXP24)))

				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP28'
					VALOR := Alltrim(Substr((TRAB)->EXP28, 1, nTamEndCli)) + " " + Alltrim(Substr((TRAB)->EXP28, nTamEndCli + 1, Len((TRAB)->EXP28)))
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP21'
					cNomePart := Alltrim((TRAB)->EXP21)
					VALOR     := Substr(cNomePart, Rat(" ", cNomePart) + 1, Len(cNomePart))
				
				Case aCabecArq[ nx ][ _CAMPO_ ] == 'EXP22'
					cNomePart := Alltrim((TRAB)->EXP22)
					VALOR     := Substr(cNomePart,1,At(" ", cNomePart)-1)
				Otherwise
					VALOR := (TRAB)->&(aCabecArq[ nx ][ _CAMPO_ ] )
				EndCase
				
			EndIf
			
			If lRet
				
				If aCabecArq[ nx ][ _CAMPO_ ] == "NXA_CCLIEN"
					VALOR := IIF( Empty((TRAB)->NUH_CLIEBI), (TRAB)->NXA_CCLIEN, (TRAB)->NUH_CLIEBI)
				EndIf
				
				If aCabecArq[ nx ][ _TIPO_ ] $ "NF" .And. Valtype(VALOR) $ "NF"
					cDetalhe += Alltrim( Str( VALOR ) )
				ElseIf aCabecArq[ nx ][ _CAMPO_ ] == "RD0_NOME" .OR. ;
					  aCabecArq[ nx ][ _CAMPO_ ] $ "EXP21|EXP22"  .OR. ;
					  ( !Empty(aCabecArq[ nx ][ _CONTE_ ]) .AND. "RD0_NOME" $  aCabecArq[ nx ][ _CONTE_ ]) 
					cDetalhe += Alltrim(Left(  VALOR  , aCabecArq[ nx ][ _TAMAN_ ]) )
				Else
					cDetalhe += Alltrim( VALOR )
				EndIf
				
			EndIf
			
		EndIf
		
		cDetalhe += If( nx == Len( aCabecArq ), "[]" + CRLF, "|" )
		
	Next
	
	If lRet
		If cTipo == "H"
			aLog := LD98VlLanc((TRAB)->NUE_COD, (TRAB)->NUE_CCLIEN, (TRAB)->NUE_CLOJA, (TRAB)->NUE_CCASO, (TRAB)->NUH_CEMP, (TRAB)->NRV_CCATE, (TRAB)->NUR_CCAT, cSigla, (TRAB)->NRY_CFASE, (TRAB)->NRZ_CTAREF, (TRAB)->NS0_CATIV, "TS", aLog, (TRAB)->NTQ_CODIGO, cCodEsc)
		ElseIf cTipo == "F"
			aLog := LD98VlLanc((TRAB)->NT1_SEQUEN, (TRAB)->NXA_CCLIEN, (TRAB)->NXA_CLOJA, "", (TRAB)->NUH_CEMP, "", "", "", "", "", "", "FX", aLog, (TRAB)->NTQ_CODIGO, cCodEsc)
		ElseIf cTipo == "D"
			aLog := LD98VlLanc((TRAB)->NVY_COD, (TRAB)->NVY_CCLIEN, (TRAB)->NVY_CLOJA, (TRAB)->NVY_CCASO, (TRAB)->NUH_CEMP, "NValdCat", "NValdCat", "NValdSigla", "NtemFase", "NtemTarefa", (TRAB)->NS3_CDESP, "DP", aLog, (TRAB)->NTQ_CODIGO, cCodEsc)
		ElseIf cTipo == "T"
			aLog := LD98VlLanc((TRAB)->NV4_COD, (TRAB)->NV4_CCLIEN, (TRAB)->NV4_CLOJA, (TRAB)->NV4_CCASO, (TRAB)->NUH_CEMP, "NValdCat", "NValdCat", "NValdSigla", "NtemFase", "NtemTarefa", (TRAB)->NXN_CSRVTB, "TB", aLog, (TRAB)->NTQ_CODIGO, cCodEsc)
		EndIf
	Else
		Exit
	EndIf
	
	If lGrava
		If FWRITE( nHandle, cDetalhe ) == 0
			If !lAutomato
				Alert( STR0019 )  //"Não foi possível gravar o arquivo!"
			EndIf
			lRet:=.F.
			Exit
		EndIf
	EndIf
	
	(TRAB)->( dbSkip() )
	
EndDo

FCLOSE( nHandle )

Return {lRet,aLog, nVtot}

//-------------------------------------------------------------------
/*/{Protheus.doc} GetDescCasos
Busca a descrição dos casos 

@param  cCliLojaCaso  String contendo Cliente, Loja e Caso
@param  cEscri        Cod Escritorio
@param  cFatura       Cod Fatura
@Return cRet          Descrição do título do caso

@author Daniel Magalhaes
@since 09/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GetDescCasos(cCliLojaCaso, cFatura, cEscri)
Local cRet    := ""
Local cSQL    := ""   
Local cIdiFat := ""
Local aResult

	cIdiFat := JurGetDados("NXA", 1, xFilial("NXA") + cEscri + cFatura, "NXA_CIDIO")

	cSQL += " SELECT NVE.NVE_TITULO, NVE.NVE_TITEBI, NT7.NT7_TITULO "
	cSQL += " FROM " + RetSqlName("NVE") + " NVE "
	cSQL += " LEFT OUTER JOIN " + RetSqlName("NT7") + " NT7 "
	cSQL +=  " ON (NT7.NT7_FILIAL = '" + xFilial("NT7") + "' "
	cSQL +=    " AND  NVE.NVE_CCLIEN = NT7.NT7_CCLIEN "
	cSQL +=    " AND  NVE.NVE_LCLIEN = NT7.NT7_CLOJA  "
	cSQL +=    " AND  NVE.NVE_NUMCAS = NT7.NT7_CCASO  "
	cSQL +=    " AND  NT7.NT7_CIDIOM = '" + cIdiFat + "' " 
	cSQL +=    " AND  NT7.NT7_REV    = '1'  "
	cSQL +=    " AND  NT7.D_E_L_E_T_ = ' ')  "
	cSQL += " WHERE NVE.NVE_CCLIEN||NVE.NVE_LCLIEN||NVE.NVE_NUMCAS = '" + cCliLojaCaso + "'"
	cSQL +=    " AND NVE.D_E_L_E_T_ = ' ' "
	cSQL +=    " AND NVE.NVE_FILIAL = '" + xFilial("NVE") + "' "
	aResult := JurSQL(cSQL, {"NVE_TITULO", "NVE_TITEBI", "NT7_TITULO"})
	
	If !Empty(aResult)
		If !Empty(aResult[1][2])
			cRet := aResult[1][2] // NVE_TITEBI
		Else
			If !Empty(aResult[1][3])
				cRet := aResult[1][3] // NT7_TITULO
			Else
				cRet := aResult[1][1] // NVE_TITULO
			EndIf
		EndIf	
	EndIf

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LDMatterId
Valida o campo LAW_FIRM_MATTER_ID

@param 	cValAtu		Valor atual
@param	cEscri		Cod Escritorio
@param	cFatura		Cod Fatura
@param	cTipo		Tipo de retono
					"A" - Assunto E-billing
					"C" - Cliente Apagador

@Return cRet		Cod Matter Id

@author Daniel Magalhaes
@since 09/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function LDMatterId( cValAtu, cEscri, cFatura, cTipo )
Local aArea     := GetArea()
Local cRet      := ""
Local cSQL      := ""
Local aResult   := {}

Default cValAtu := ""
Default cTipo   := "A"

If Empty(cValAtu)
	cSQL := " SELECT NVE.NVE_MATTER, NVE.NVE_CPGEBI "
	cSQL +=    " FROM " + RetSqlName("NXC") + " NXC "
	cSQL +=    " INNER JOIN " + RetSqlName("NVE") + " NVE "
	cSQL +=         " ON( NVE.NVE_FILIAL = '" + xFilial("NVE") + "'"
	cSQL +=         " AND NVE.NVE_CCLIEN = NXC.NXC_CCLIEN" 
	cSQL +=         " AND NVE.NVE_LCLIEN = NXC.NXC_CLOJA"
	cSQL +=         " AND NVE.NVE_NUMCAS = NXC.NXC_CCASO"
	cSQL +=         " AND NVE.D_E_L_E_T_ = ' ' )"
	cSQL +=     " WHERE NXC.NXC_FILIAL = '" + xFilial("NXC") + "' "
	cSQL +=     " AND NXC.NXC_CFATUR = '" + cFatura + "'"
	cSQL +=     " AND NXC.NXC_CESCR  = '" + cEscri + "'"
	cSQL +=     " AND NXC.D_E_L_E_T_ = ' ' "
	cSQL +=     " ORDER BY NXC.NXC_CCLIEN, NXC.NXC_CLOJA, NXC.NXC_CCASO "

	aResult := JurSQL(cSQL, {"NVE_MATTER", "NVE_CPGEBI"} )

	If !Empty( aResult )
		cRet := Iif(cTipo == "A", aResult[1][1], aResult[1][2])
	EndIf
Else
	cRet := cValAtu
EndIf

RestArea(aArea)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} LD98VlLanc
Função utilizada para gerar o log de criticas na geração no arquivo E-Billing.

@Params  cCod		- Codogo do lançamento
@Params  cClient	- Cliente do lançamento 
@Params  cLoja		- Loja do lançamento
@Params  cCaso		- Caso do lançamento
@Params  cEmpEbi	- Empresa E-billing
@Params  cCateg		- Cateriga E-billing 
@Params  cCatPar	- Categoria do participante
@Params  cSiga		- Sigla do Participante 
@Params  cFase		- Fase E-billing do TimeSheet 
@Params  cTafera	- Tarefa E-billing do TimeSheet 
@Params  cTIpo		- Tipo (Atividade/Despesa/Serviço) E-billing
@Params  cLanc		- TS = TimeSheet; DP = Despesa; TB = Tabelado
@Params  aLog   	- Array com a estrutura e informações anteriores para adicionar ao aLog
@Params  cEscEbi	- Escritorio E-billing
@Params  cEscrit	- Escritorio da Fatura

@Retuns	 aLog		- Array com o Retorno do log 
					- [EMP_EBI][1] Identificador da critica Empresa E-billing
					    	   [2] Mensagem de critica
					- [CAT_EBI][1] Identificador da critica Categoria E-billing
					           [2] Mensagem de critica				
					- [FAS_EBI][1] Identificador da critica Fase E-billing
					           [2] Mensagem de critica
					- [TAF_EBI][1] Identificador da critica Tarefa E-billing
					           [2] Mensagem de critica		
					- [TIP_EBI][1] Identificador da critica Ativida; Tipo Despesa/Serviço Tabela E-billing
					           [2] Mensagem de critica
					- [ESC_EBI][1] Identificador da critica Escritório E-billing
					           [2] Mensagem de critica

@author Luciano Pereira dos Santos
@since 02/11/12
@version 1.0
/*/
//-------------------------------------------------------------------
Function LD98VlLanc(cCod, cClient, cLoja, cCaso, cEmpEbi, cCateg, cCatPart, cSigla, cFase, cTarefa, cTipo, cLanc, aLog, cEscEbi, cEscrit)
Local lErro     := .F.
Local cMsg      := ""
Local cDocEbi   := ""
Local nI        := 0
Default cClient := "" 
Default cLoja   := ""
Default cCaso   := ""
Default cCateg  := ""
Default cTipo   := ""
Default cEmpEbi := ""
Default aLog    := {}

If Empty(aLog)
	For nI := 1 To 6
		aAdd (aLog, {})
	Next nI
EndIf

If !Empty(cEmpEbi) .And. cLanc $ "TS|DP|TB"
	If cEmpEbi != JurGetDados("NUH", 1, xFilial("NUH") + cClient + cLoja, "NUH_CEMP" ) 
		If !Empty(aLog[EMP_EBI])  
			If ( aScan( aLog[EMP_EBI], { |x| x[1] == cClient + cLoja + cCaso } ) == 0 )
				aAdd( aLog[EMP_EBI], {cClient + cLoja + cCaso , I18N(STR0027, {cClient + "/" + cLoja, cCaso}) }) //"A empresa e-billing do cliente '#1' referente ao caso '#2' é diferente da empresa e-billing do cliente da fatura."
			EndIf
		Else
			aAdd( aLog[EMP_EBI], {cClient + cLoja + cCaso, I18N(STR0027, {cClient + "/" + cLoja, cCaso}) })
		EndIf
		lErro := .T.
	EndIf
EndIf

If !lErro .And. Empty(cEscEbi) .And. cLanc $ "TS|DP|TB"
	If !Empty(aLog[ESC_EBI])
		If ( aScan( aLog[ESC_EBI], { |x| x[1] == cEscrit } ) == 0 )
			aAdd( aLog[ESC_EBI], {cEscrit, I18N(STR0028, {cEmpEbi, cEscrit}) }) //"Não existe escritório e-billing relacionado a empresa e-billing #1 para o escritório da fatura '#2'."
		EndIf
	Else
		aAdd( aLog[ESC_EBI], {cEscrit, I18N(STR0028 , {cEmpEbi, cEscrit}) })
	EndIf
	lErro := .T.
EndIf

If !lErro .And. Empty(cCateg) .And. cLanc $ "TS|DP|TB"
	cDocEbi := Alltrim(JurGetDados("NRX", 1 , xFilial("NRX") + cEmpEbi, "NRX_CDOC"))
	If !Empty(aLog[CAT_EBI])
		If ( aScan( aLog[CAT_EBI], { |x| x[1] == cCatPart + cSigla } ) == 0 )
			aAdd( aLog[CAT_EBI], {cCatPart + cSigla, I18N(STR0029, {cCatPart, cSigla, cDocEbi}) }) //"A categoria '#1' do participante '#2' não está relacionada ao documento e-billing '#3'."
		EndIf
	Else
		aAdd( aLog[CAT_EBI], {cCatPart + cSigla, I18N(STR0029, {cCatPart, cSigla, cDocEbi}) })
	EndIf
	lErro := .T.
EndIf

If !lErro .And. Empty(cFase) .And. cLanc == "TS"
	cDocEbi :=  Alltrim(JurGetDados("NRX", 1, xFilial("NRX") + cEmpEbi, "NRX_CDOC" ))
	cFase   :=  Alltrim(JurGetDados("NUE", 1, xFilial("NUE") + cCod, "NUE_CFASE" ))
	
	aAdd ( aLog[FAS_EBI], {cFase, I18N(STR0030, {cFase, cCod, cDocEbi})}) //"A fase '#1' do TimeSheet '#2' não está relacionada ao documento e-billing '#3'."
	
	lErro := .T.
EndIf

If !lErro .And. Empty(cTarefa) .And. cLanc == "TS"
	cDocEbi := Alltrim(JurGetDados("NRX", 1, xFilial("NRX") + cEmpEbi, "NRX_CDOC"))
	cTarefa := Alltrim(JurGetDados("NUE", 1, xFilial("NUE") + cCod, "NUE_CTAREF"))

	aAdd(aLog[TAF_EBI], {cTarefa, I18N(STR0031, {cTarefa, cCod, cDocEbi})}) //"A tarefa '#1' do TimeSheet '#2' não está relacionada ao documento e-billing '#3'."

	lErro := .T.
EndIf

If !lErro .And. Empty(cTipo) .And. cLanc != "FX"
	cDocEbi := Alltrim(JurGetDados("NRX", 1, xFilial("NRX") + cEmpEbi, "NRX_CDOC"))
	cCod    := Alltrim(cCod)
	
	Do Case
		Case cLanc == "TS"
			cTipo := Alltrim(JurGetDados("NUE", 1, xFilial("NUE") + cCod, "NUE_CATIVI"))
			cMsg  := I18N(STR0044, {cTipo, cCod, cDocEbi}) //"Não existe atividade e-billing lançada no TimeSheet '#2'. Verifique o cadastro no documento e-billing '#3' para a atividade '#1' ou ajuste o TimeSheet."
		Case cLanc == "DP"
			cTipo := Alltrim(JurGetDados("NVY", 1, xFilial("NVY") + cCod, "NVY_CTPDSP"))
			cMsg  := I18N(STR0033, {cTipo, cCod, cDocEbi}) //"O tipo de despesa '#1' da despesa '#2' não está relacionada ao documento e-billing '#3'."
		Case cLanc == "TB"
			cTipo := Alltrim(JurGetDados("NV4", 1, xFilial("NV4") + cCod, "NV4_CTPSRV"))
			cMsg  := I18N(STR0034, {cTipo, cCod, cDocEbi}) //"O tipo de serviço tabelado '#1' do Serviço Tabelado '#2' não está relacionada ao documento e-billing '#3'."
	EndCase
	
	aAdd(aLog[TIP_EBI], {cCod + cLanc, cMsg})
EndIf

Return aLog

//-------------------------------------------------------------------
/*/{Protheus.doc} RetSXB
Retorna qual SXB a ser usado

@Return cRet		Codigo da Consulta Padrão

@author fabiana.silva
@since 06/04/2020
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function RetSXB()
Local cRet     := "NXA1"
Local aAreaSXB := SXB->(GetArea())
Local nTamSx3  := Len(SXB->XB_ALIAS)

SXB->(DbSetOrder(1)) //XB_ALIAS

If SXB->(DbSeek(PadR("NXA2", nTamSx3)))
	cRet := "NXA2"
EndIf

RestArea(aAreaSXB)

Return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} JLDFlagFat
Grava flag de arquivo e-billing gerado na fatura

@param  nRecNXA, numérico, Recno do registro da fatura

@author Jonatas Martins
@since  06/04/2020
/*/
//-------------------------------------------------------------------
Function JLDFlagFat(nRecNXA)
	Local aArea     := {}
	Local aAreaNXA  := {}

	Default nRecNXA := 0

	If NXA->(ColumnPos("NXA_ARQEBI")) > 0
		aArea    := GetArea()
		aAreaNXA := NXA->(GetArea())

		NXA->(DbGoTo(nRecNXA))

		If NXA->(!Eof())
			RecLock("NXA")
			NXA->NXA_ARQEBI := "1" // Sim
			NXA->(MsUnLock())
			lFlagFat := .T.
		EndIf

		RestArea(aAreaNXA)
		RestArea(aArea)
	EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} JGetTpCob
Retorna se os contratos vinculados a fatura cobram Hora ou Fixo

@param  cEscri Escritório da fatura
@param  cFat   Código da fatura

@author Abner Fogaça / Jorge Martins / Victor Hayashi
@since  23/09/2020
/*/
//-------------------------------------------------------------------
Static Function JGetTpCob(cEscri, cFat)
	Local cQuery    := ""
	Local aCodContr := {}

	cQuery := "SELECT NRA.NRA_COBRAH, NRA.NRA_COBRAF, NXB.NXB_CCONTR "
	cQuery += "  FROM " + RetSqlName("NRA") + " NRA "
	cQuery += " INNER JOIN " + RetSqlName("NXB") + " NXB "
	cQuery += "    ON NXB.NXB_FILIAL = '" + xFilial("NXB") + "'"
	cQuery += "   AND NXB.NXB_CTPHON = NRA.NRA_COD "
	cQuery += "   AND NXB.NXB_CESCR = '" + cEscri + "'"
	cQuery += "   AND NXB.NXB_CFATUR = '" + cFat + "'"
	cQuery += "   AND NXB.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE NRA.NRA_FILIAL = '" + xFilial("NRA") + "'"
	cQuery += "   AND NRA.D_E_L_E_T_ = ' ' "

	aCodContr := JurSQL(cQuery, {"*"})

Return aCodContr
