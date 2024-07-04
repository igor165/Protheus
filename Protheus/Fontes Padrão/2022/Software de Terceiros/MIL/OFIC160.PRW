#Include "PROTHEUS.CH"
#Include "OFIC160.CH"

/*/{Protheus.doc} OFIC160
Consulta valores em andamento levantados pela Validação de Crédito do Cliente ( FG_AVALCRED )

@author Andre Luis Almeida
@since 04/02/2020
@version 1.0

@type function
/*/
Function OFIC160( cCodCli , cLojCli )
Local oBrwOC160
Default cCodCli := ""
Default cLojCli := ""
If Empty( cCodCli + cLojCli )
	oBrwOC160 := FWMBrowse():New()
	oBrwOC160:SetAlias("SA1")
	oBrwOC160:AddButton(STR0002,{ || OC1600011_TelaConsulta( SA1->A1_COD , SA1->A1_LOJA ) } ) // Consultar
	oBrwOC160:DisableDetails()
	oBrwOC160:SetDescription(STR0001) // Consulta valores em andamento levantados pela Validação de Crédito do Cliente
	oBrwOC160:Activate()
Else
	OC1600011_TelaConsulta( cCodCli , cLojCli )
EndIf
Return

/*/{Protheus.doc} OC1600011_TelaConsulta
Monta Tela para listar valores em andamento de Orcamento e OSs

@author Andre Luis Almeida
@since 04/02/2020
@version 1.0

@type function
/*/
Static Function OC1600011_TelaConsulta( cCodCli , cLojCli )
//
Local aSize       := FWGetDialogSize( oMainWnd )
Local cFaseConfer := Alltrim(GetNewPar("MV_MIL0095","4")) // Fase de Conferencia e Separacao
Local aTitCol     := OC1600031_TitulosCOLUNAS()
//
Private aVetSA1 := {}
Private aVetVS1 := {}
Private aVetVO1 := {}
//
Default cCodCli := ""
Default cLojCli := ""

If Empty(cCodCli+cLojCli)
	Return
EndIf
//
OC1600041_LEVANTA( cCodCli , cLojCli )
//

oOFIC160 := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], STR0001, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) // Consulta valores em andamento levantados pela Validação de Crédito do Cliente

	oWorkArea := FWUIWorkArea():New( oOFIC160 )
		
	// -1 para nao estourar 100% da tela ( criando scroll lateral )
	oWorkArea:CreateHorizontalBox( "LINE01", 30 )
	oWorkArea:SetBoxCols( "LINE01", { "OBJTOP" } )
	oWorkArea:CreateHorizontalBox( "LINE02", 34 )
	oWorkArea:SetBoxCols( "LINE02", { "OBJORC" } )
	oWorkArea:CreateHorizontalBox( "LINE03", 34 )
	oWorkArea:SetBoxCols( "LINE03", { "OBJOSS" } )
	oWorkArea:Activate()

	oBrwSA1 := FWFormBrowse():New()
	oBrwSA1:SetOwner(oWorkarea:GetPanel("OBJTOP"))
	oBrwSA1:SetDescription(STR0001) // Consulta valores em andamento levantados pela Validação de Crédito do Cliente
	oBrwSA1:SetDataArray()
	oBrwSA1:SetArray(aVetSA1)
	oBrwSA1:SetColumns(OC1600021_MontaCol(aTitCol[1],"SA1"))
	oBrwSA1:AddButton(STR0038,{ || oOFIC160:End() } ) // Fechar
	oBrwSA1:DisableReport()
	oBrwSA1:Activate() // Ativação do Browse
	oBrwSA1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwSA1:Refresh()
	oBrwSA1:GoTop()

	oBrwVS1 := FWFormBrowse():New()
	oBrwVS1:SetOwner(oWorkarea:GetPanel("OBJORC"))
	oBrwVS1:SetDescription(STR0017) // Orçamentos em Andamento
	oBrwVS1:SetDataArray()
	oBrwVS1:SetArray(aVetVS1)
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '10' } , "BR_VERDE"   , STR0003 ) // Orçamento Balcão Digitado
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '12' } , "BR_PINK"    , STR0004 ) // Orçamento Balcão Margem Pendente
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '13' } , "BR_BRANCO"  , STR0005 ) // Orçamento Balcão Avaliação de Crédito
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '1'+cFaseConfer } , "BR_AZUL" , STR0006 ) // Orçamento Balcão Aguardando Separação
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '15' } , "BR_MARROM"  , STR0007 ) // Orçamento Balcão Aguardando Lib.Divergencia
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '1R' .or. aVetVS1[oBrwVS1:AT(),1] == '1T' } , "BR_CINZA" , STR0008 ) // Orçamento Balcão Aguardando Reserva
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '1G' } , "BR_AZUL_CLARO" , STR0039 ) // Orçamento Balcão Aguardando outro Orçamento
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '1F' } , "BR_AMARELO" , STR0009 ) // Orçamento Balcão Liberado para Faturamento
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '1X' } , "BR_PRETO"   , STR0010 ) // Orçamento Balcão Faturado
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '1C' } , "BR_VERMELHO", STR0011 ) // Orçamento Balcão Cancelado
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '20' } , "f10_verd", STR0012 ) // Orçamento Oficina Digitado
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '2F' .or. aVetVS1[oBrwVS1:AT(),1] == '2L' } , "f5_amar", STR0013 ) // Orçamento Oficina Liberado para Exportação
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '2P' .or. aVetVS1[oBrwVS1:AT(),1] == '22' } , "f12_azul", STR0014 ) // Orçamento Oficina Pendente Liberação
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '2I' } , "f14_cinz", STR0015 ) // Orçamento Oficina Importado na OS
	oBrwVS1:AddLegend( { || aVetVS1[oBrwVS1:AT(),1] == '2C' } , "f7_verm", STR0016 ) // Orçamento Oficina Cancelado
	oBrwVS1:SetColumns(OC1600021_MontaCol(aTitCol[2],"VS1"))
	oBrwVS1:SetDoubleClick( { || OC1600051_VerOrigem( "VS1" , oBrwVS1:At() ) } )	
	oBrwVS1:AddButton(STR0019,{ || OC1600051_VerOrigem( "VS1" , oBrwVS1:At() ) } ) // Visualizar
	oBrwVS1:Activate() // Ativação do Browse
	oBrwVS1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwVS1:Refresh()
	oBrwVS1:GoTop()

	oBrwVO1 := FWFormBrowse():New()
	oBrwVO1:SetOwner(oWorkarea:GetPanel("OBJOSS"))
	oBrwVO1:SetDescription(STR0018) // Ordens de Serviços em Andamento
	oBrwVO1:SetDataArray()
	oBrwVO1:SetArray(aVetVO1)
	oBrwVO1:AddLegend( { || aVetVO1[oBrwVO1:AT(),1] == 'A' } , "BR_VERDE"   , STR0020 ) // Ordem de Serviço Aberta
	oBrwVO1:AddLegend( { || aVetVO1[oBrwVO1:AT(),1] == 'D' } , "BR_AZUL"    , STR0021 ) // Ordem de Serviço Liberada
	oBrwVO1:AddLegend( { || aVetVO1[oBrwVO1:AT(),1] == 'F' } , "BR_VERMELHO", STR0022 ) // Ordem de Serviço Fechada
	oBrwVO1:AddLegend( { || aVetVO1[oBrwVO1:AT(),1] == 'C' } , "BR_PRETO"   , STR0023 ) // Ordem de Serviço Cancelada
	oBrwVO1:SetColumns(OC1600021_MontaCol(aTitCol[3],"VO1"))
	oBrwVO1:SetDoubleClick( { || OC1600051_VerOrigem( "VO1" , oBrwVO1:At() ) } )	
	oBrwVO1:AddButton(STR0019,{ || OC1600051_VerOrigem( "VO1" , oBrwVO1:At() ) } ) // Visualizar
	oBrwVO1:Activate() // Ativação do Browse
	oBrwVO1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
	oBrwVO1:Refresh()
	oBrwVO1:GoTop()

oOFIC160:Activate( , , , , , , ) //ativa a janela

Return()

/*/{Protheus.doc} OC1600021_MontaCol
Adicao das Colunas do Browse

@author Andre Luis Almeida
@since 04/02/2020
@version 1.0

@type function
/*/
Static Function OC1600021_MontaCol(aHeader,cAlBrowse)
Local oColuna
Local cSetData
Local nHeader   := 0
Local aColunas  := {}
Default aHeader := {}
For nHeader := 1 To Len(aHeader)
	// Instancia a Classe
	oColuna := FWBrwColumn():New()
	// Definições Básicas do Objeto
	oColuna:SetAlign(If(aHeader[nHeader][6] == "R", CONTROL_ALIGN_RIGHT, CONTROL_ALIGN_LEFT))
	oColuna:SetEdit(.F.)
	// Definições do Dado apresentado
	oColuna:SetSize(aHeader[nHeader][3])
	oColuna:SetTitle(aHeader[nHeader][1])
	oColuna:SetType(aHeader[nHeader][2])
	oColuna:SetPicture(aHeader[nHeader][4])
	//
	cSetData := "{|| oBrw"+cAlBrowse+":Data():GetArray()[oBrw"+cAlBrowse+":AT()][" + cValToChar(aHeader[nHeader][5]) + "] }"
	oColuna:SetData(&(cSetData))
	//
	aAdd(aColunas, oColuna)
Next nHeader
Return aColunas

/*/{Protheus.doc} OC1600031_TitulosCOLUNAS
Retorna Titulos/Tipos/Tamanhos/Mascara das Colunas do Browse

@author Andre Luis Almeida
@since 04/02/2020
@version 1.0

@type function
/*/
Static Function OC1600031_TitulosCOLUNAS()
Local aColCli := {} // Colunas grid Clientes
Local aColOrc := {} // Colunas grid Orcamentos
Local aColOSs := {} // Colunas grid Ordem de Servicos
//
aAdd(aColCli, {STR0024,"C", 25,"@!"                  , 1,"L"}) // Nome Cliente
aAdd(aColCli, {STR0026,"N", 15,"@E 99,999,999,999.99", 2,"R"}) // Total Balcão
aAdd(aColCli, {STR0027,"N", 15,"@E 99,999,999,999.99", 3,"R"}) // Total Oficina
aAdd(aColCli, {STR0017,"N", 15,"@E 99,999,999,999.99", 4,"R"}) // Orçamentos em Andamento
aAdd(aColCli, {STR0018,"N", 15,"@E 99,999,999,999.99", 5,"R"}) // Ordem de Serviços em Andamento
aAdd(aColCli, {STR0025,"N", 15,"@E 99,999,999,999.99", 6,"R"}) // Total em Andamento
//
aAdd(aColOrc, {STR0028,"C", 20,"@!"                  , 2,"L"}) // Filial
aAdd(aColOrc, {STR0029,"C", 12,"@!"                  , 3,"L"}) // Orçamento
aAdd(aColOrc, {STR0030,"C", 08,"@!"                  , 4,"L"}) // Tipo
aAdd(aColOrc, {STR0031,"N", 20,"@E 99,999,999,999.99", 5,"R"}) // Valor de Peças
aAdd(aColOrc, {STR0032,"N", 20,"@E 99,999,999,999.99", 6,"R"}) // Valor de Serviços
aAdd(aColOrc, {STR0033,"N", 20,"@E 99,999,999,999.99", 7,"R"}) // Valor Total
//
aAdd(aColOSs, {STR0028,"C", 20,"@!"                  , 2,"L"}) // Filial
aAdd(aColOSs, {STR0034,"C", 12,"@!"                  , 3,"L"}) // Ordem de Serviço
aAdd(aColOSs, {STR0035,"C", 08,"@!"                  , 4,"L"}) // Tipo de Tempo
aAdd(aColOSs, {STR0031,"N", 20,"@E 99,999,999,999.99", 5,"R"}) // Valor de Peças
aAdd(aColOSs, {STR0032,"N", 20,"@E 99,999,999,999.99", 6,"R"}) // Valor de Serviços
aAdd(aColOSs, {STR0033,"N", 20,"@E 99,999,999,999.99", 7,"R"}) // Valor Total
//
Return { aColCli , aColOrc , aColOSs }

/*/{Protheus.doc} OC1600041_LEVANTA
Levanta Dados para incluir registros no Browse 

@author Andre Luis Almeida
@since 04/02/2020
@version 1.0

@type function
/*/
Static Function OC1600041_LEVANTA( cCodCli , cLojCli )
Local nCntFor   := 0
Local nLinha    := 0
Local oSqlHlp   := DMS_SqlHelper():New()
Local aAux      := {}
Local aVetACred := {}
Default cCodCli := ""
Default cLojCli := ""
//
If !Empty(cCodCli+cLojCli)
	FG_AVALCRED( cCodCli , cLojCli , .t. , .t. , @aVetACred )
EndIf
//
aVetSA1 := {}
aVetVS1 := {}
aVetVO1 := {}
//
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek(xFilial("SA1") + cCodCli + cLojCli )
aAdd(aVetSA1,{ SA1->A1_NOME , 0 , 0 , 0 , 0 , 0 }) // Nome , Tot.Balcao , Tot.Oficina , Orc.Andamento , OS.Andamento , Tot.Andamento
//
For nCntFor := 1 to len(aVetACred)
	If aVetACred[nCntFor,7] > 0
		If aVetACred[nCntFor,1] == "1" // Orcamento
			aAdd(aVetVS1,aVetACred[nCntFor])
			nLinha := len(aVetVS1)
			aAux := oSqlHlp:GetSelectArray("SELECT VS1_TIPORC , VS1_STATUS FROM "+RetSqlName("VS1")+" WHERE VS1_FILIAL='"+aVetVS1[nLinha,2]+"' AND VS1_NUMORC='"+aVetVS1[nLinha,3]+"' AND D_E_L_E_T_=' '",2)
			If len(aAux) > 0
				aVetVS1[nLinha,1] := aAux[1,1]+aAux[1,2] // VS1_TIPORC + VS1_STATUS
				If aAux[1,1] == "2" // Oficina
					aVetVS1[nLinha,4] := STR0037 // Oficina
					aVetSA1[1,3] += aVetACred[nCntFor,7]
				Else // Balcao
 					aVetVS1[nLinha,4] := STR0036 // Balcão
					aVetSA1[1,2] += aVetACred[nCntFor,7]
				EndIf
			EndIf
			aVetSA1[1,4] += aVetACred[nCntFor,7]
			aVetSA1[1,6] += aVetACred[nCntFor,7]
		Else // Ordem de Servico
			aAdd(aVetVO1,aVetACred[nCntFor])
			nLinha := len(aVetVO1)
			aVetVO1[nLinha,1] := FM_SQL("SELECT VO1_STATUS FROM "+RetSqlName("VO1")+" WHERE VO1_FILIAL='"+aVetVO1[nLinha,2]+"' AND VO1_NUMOSV='"+aVetVO1[nLinha,3]+"' AND D_E_L_E_T_=' '")
			aVetSA1[1,3] += aVetACred[nCntFor,7]
			aVetSA1[1,5] += aVetACred[nCntFor,7]
			aVetSA1[1,6] += aVetACred[nCntFor,7]
		EndIf
	EndIf
Next
//
Return

/*/{Protheus.doc} OC1600051_VerOrigem
Ver Origem ( Orcamento ou OS )

@author Andre Luis Almeida
@since 04/02/2020
@version 1.0

@type function
/*/
Static Function OC1600051_VerOrigem( cAlOrigem , nLinha )
Local aAreaUlt := GetArea()
Local aAreaBkp := {}
Local nRecVis  := 0
If cAlOrigem == "VS1"
	If len(aVetVS1) > 0
		aAreaBkp := VS1->(GetArea())
		OFIC170( aVetVS1[nLinha,2] , aVetVS1[nLinha,3] )
		RestArea( aAreaBkp ) // Volta VS1
	EndIf
Else // cAlOrigem == "VO1"
	If len(aVetVO1) > 0
		nRecVis := FM_SQL("SELECT R_E_C_N_O_ FROM "+RetSqlName("VO1")+" WHERE VO1_FILIAL='"+aVetVO1[nLinha,2]+"' AND VO1_NUMOSV='"+aVetVO1[nLinha,3]+"' AND D_E_L_E_T_=' '")
		If nRecVis > 0
			aAreaBkp := VO1->(GetArea())
			nOpc   := 2 // Utilizado dentro das Rotinas e SX3
			Inclui := .f. // Utilizado dentro das Rotinas e SX3
			VO1->(DbGoTo(nRecVis))
			OFIOC060(.t.)
			RestArea( aAreaBkp ) // Volta VO1
		EndIf
	EndIf
EndIf
RestArea( aAreaUlt ) // Volta ultimo Alias
Return