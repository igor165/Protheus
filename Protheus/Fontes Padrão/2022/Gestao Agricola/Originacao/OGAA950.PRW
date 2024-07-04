#INCLUDE "OGAA950.ch"
#include "protheus.ch"
#include "fwmvcdef.ch"

Static oArqTemp := Nil

Static __cTabTmp := ""
Static __cNamTmp := ""

/** {Protheus.doc} OGAA950
Rotina para cadastro de Encontro de Contas Invoice.

@param: 	Nil
@author: 	Christopher.miranda
@since: 	19/10/2018
@Uso: 		SIGAAGR - Originação de Grãos
*/
Function OGAA950( )
	Local oBrowse

    Private _aRecnoN82  := {}

	//Proteç?o
	If !TableInDic('NLG')
		Help( , , STR0020, , STR0021, 1, 0 ) //"Atenç?o" //"Para acessar esta funcionalidade é necessario atualizar o dicionario do Protheus."
		Return(Nil)
	EndIf  

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("NLG")			// Alias da tabela utilizada
	oBrowse:SetDescription(STR0001)	// Descrição do browse 
	oBrowse:AddLegend( "NLG_STATUS='1'", "YELLOW" , STR0008 ) //"Pendente"
	oBrowse:AddLegend( "NLG_STATUS='2'", "GREEN"  , STR0009 ) //"Liquidado"

	oBrowse:SetMenuDef("OGAA950")	// Nome do fonte onde esta a função MenuDef
	
	oBrowse:Activate()         
	
    //Elimina a tabela temporária, se houver
    
    //--Temporaria Documentos
	IF Select( __cTabTmp ) > 0
		(__cTabTmp)->( DbCloseArea() )
		FErase(__cTabTmp + GetDbExtension() ) 	// Deletando o arquivo
	EndIF
	
    AGRDLTPTB(oArqTemp)
                                  
Return(Nil)

/** {Protheus.doc} MenuDef
Função que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author: 	Christopher.miranda
@since: 	19/10/2018
@Uso: 		OGAA950
*/
Static Function MenuDef()

	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	aAdd( aRotina, { STR0002, "PesqBrw"          , 0, 1, 0, .T. } ) //"Pesquisar"
	aAdd( aRotina, { STR0003, "VIEWDEF.OGAA950"  , 0, 2, 0, .T. } ) //"Visualizar"
	aAdd( aRotina, { STR0004, "VIEWDEF.OGAA950"  , 0, 3, 0, .T. } ) //"Incluir"
	aAdd( aRotina, { STR0005, "VIEWDEF.OGAA950"  , 0, 4, 0, .T. } ) //"Alterar"
	aAdd( aRotina, { STR0006, "VIEWDEF.OGAA950"  , 0, 5, 0, .T. } ) //"Excluir"
	aAdd( aRotina, { STR0007, "VIEWDEF.OGAA950"  , 0, 8, 0, .T. } ) //"Imprimir"
	
Return aRotina
	
/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Christopher.miranda
@since: 	19/10/2018
@Uso: 		OGAA950
*/
Static Function ModelDef()
	
	Local oStruNLG := FWFormStruct( 1, "NLG" )
	Local oModel   := MPFormModel():New( "OGAA950", /* {| oModel | PreModelo( oModel ) } */ , {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) } )
	
	oModel:AddFields("NLGUNICO", Nil, oStruNLG)
	oModel:SetPrimaryKey({"NLG_FILIAL","NLG_CODIGO","NLG_CODCLI","NLG_LOJCLI"})

	oStruNLG:SetProperty( "NLG_CODCLI" , MODEL_FIELD_VALID  , { || LoadGrdInv() })
	oStruNLG:SetProperty( "NLG_LOJCLI" , MODEL_FIELD_VALID  , { || LoadGrdInv() })

	oStruNLG:SetProperty( "NLG_TOTINV" , MODEL_FIELD_VALID  , { || fTrgNLGSld() })
	oStruNLG:SetProperty( "NLG_TOTTIT" , MODEL_FIELD_VALID  , { || fTrgNLGSld() })
Return oModel


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author:    Christopher.miranda
@since:     19/10/2018
@Uso: 		OGAA780/
*/
Static Function ViewDef()
	Local oModel := FWLoadModel("OGAA950")
	Local oView  := Nil
	Local oStructNLG := FWFormStruct(2,"NLG", { |x| !ALLTRIM(x) $ ("NLG_SLDINT, NLG_TOTINV, NLG_TOTTIT")})
	Local oStruNLGTo := FWFormStruct(2,"NLG", { |x| ALLTRIM(x) $ ("NLG_SLDINT, NLG_TOTINV, NLG_TOTTIT")/* ("NLG_CODIGO, NLG_CODCLI, NLG_LOJCLI, NLG_NOMCLI, NLG_NLJCLI, NLG_STATUS") */}) 

	Static oBrwInv := Nil
	Static oBrwTit := Nil
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	oView:AddField( "VIEW_NLG",     oStructNLG, "NLGUNICO")
	oView:AddField( "VIEW_NLG_TOT", oStruNLGTo, "NLGUNICO")

	//oStructNLG:RemoveField("NLG_DTUATU")
	//oStructNLG:RemoveField("NLG_HRUATU")

	oView:CreateHorizontalBox( "SUPERIOR" , 20 )
	oView:CreateHorizontalBox( "HBOX_INV" , 35 )
	oView:CreateHorizontalBox( "HBOX_TIT" , 35 )
	oView:CreateHorizontalBox( "INFERIOR" , 10 )

	oView:AddOtherObject("VIEW_N82", {|oPanel| CriaBrwInv(oPanel)},,{|oPanel| oBrwInv:Refresh() })
	oView:AddOtherObject("VIEW_EEQ", {|oPanel| CriaBrwTit(oPanel)},,{|oPanel| oBrwTit:Refresh() })

	oView:SetOwnerView( "VIEW_NLG",     "SUPERIOR" )
	oView:SetOwnerView( "VIEW_N82",     "HBOX_INV" )
	oView:SetOwnerView( "VIEW_EEQ",     "HBOX_TIT" )
	oView:SetOwnerView( "VIEW_NLG_TOT", "INFERIOR" )

	oView:SetAfterViewActivate({|oView|AfterVal(oView)})

	oView:SetModified(.T.) // Seta a View como modificada, para realizar o commit.

Return oView

/*/{Protheus.doc} CriaStrInv()
Função que cria o mark browse das invoices
@type  Static Function
@author rafael.kleestadt
@since 22/10/2018
@version 1.0
@param oPanel, object, painel onde deve ser criado a grid
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function CriaBrwInv(oPanel)

	Local aArea   := GetArea()
	Local cFiltro := FiltraMark()
	Local aCposBrw := {"N82_CODINE","N82_PEDIDO","N82_FILORI","N82_ITEM","N82_CODINV","N82_TOTDES"}
	
 	oBrwInv:=FWMarkBrowse():New()     // Cria o objeto oMark - MarkBrowse
 	oBrwInv:SetDescription(STR0010) //"Resultado Perda/Ganho de Peso/Qualidade por Invoice"		
	oBrwInv:SetFilterDefault(cFiltro)
	oBrwInv:SetAlias("N82")
	oBrwInv:SetFieldMark("N82_OK")    // Define o campo utilizado para a marcacao
	oBrwInv:SetOnlyFields( aCposBrw )
	oBrwInv:SetSemaphore(.F.)	      // Define se utiliza marcacao exclusiva
	oBrwInv:SetMenuDef("")	             
	oBrwInv:SetOwner(oPanel)	      // Ativa o MarkBrowse
	oBrwInv:DisableReport(.T.)        // Desabilita a opcao de imprimir	 
	oBrwInv:DisableConfig(.T.)
	oBrwInv:SetAfterMark({|| Marcar() }) //Indica o Code-Block executado após a marcação ou desmarcação do registro
	oBrwInv:SetAllMark({||MarkAll()}) //Indica o Code-Block executado no clique do header da coluna de marca/desmarca
	/*oBrwTit:bAllMark := {||MarkAll('1'), oBrwTit:Refresh(.T.)}
	oBrwInv:SetValid({|| Marcar()}) //Valida marcacao */
	
	oBrwInv:Activate()
	oBrwInv:Enable()
	oBrwInv:Refresh(.T.)

	RestArea(aArea)

Return .T.

/*/{Protheus.doc} CriaBrwTit()
Função que cria o mark browse dos títulos
@type  Static Function
@author tamyris.g	
@since 22/10/2018
@version 1.0
@param oPanel, object, painel onde deve ser criado a grid
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function CriaBrwTit(oPanel)
	Local nCont		 := 0
	Local aStrcTmp   := {}
	Local aIndTmp    := {}
	Local aFilBrwTmp := {}
	Local nLinEdit   := 0
	Local aHeader    := {}
	Local aSeek      := {}

    //Array com os campos
    aStrcTmp := { {RetTitle("NLH_FILIAL"), "NLH_FILIAL", TamSX3("NLH_FILIAL")[3], TamSX3("NLH_FILIAL")[1], TamSX3("NLH_FILIAL")[2], PesqPict( "NLH", "NLH_FILIAL" )	},;					
                  {RetTitle("NLH_NRINVO"), "NLH_NRINVO", TamSX3("NLH_NRINVO")[3], TamSX3("NLH_NRINVO")[1], TamSX3("NLH_NRINVO")[2], PesqPict( "NLH", "NLH_NRINVO" )	},;						
                  {RetTitle("NLH_PREEMB"), "NLH_PREEMB", TamSX3("NLH_PREEMB")[3], TamSX3("NLH_PREEMB")[1], TamSX3("NLH_PREEMB")[2], PesqPict( "NLH", "NLH_PREEMB" )	},;						
                  {RetTitle("NLH_PARC"  ), "NLH_PARC"  , TamSX3("NLH_PARC"  )[3], TamSX3("NLH_PARC"  )[1], TamSX3("NLH_PARC"  )[2], PesqPict( "NLH", "NLH_PARC"   )	},;						
                  {RetTitle("NLH_FASE"  ), "NLH_FASE"  , TamSX3("NLH_FASE"  )[3], TamSX3("NLH_FASE"  )[1], TamSX3("NLH_FASE"  )[2], PesqPict( "NLH", "NLH_FASE"   )	},;		
                  {RetTitle("NLH_PROCES"), "NLH_PROCES", TamSX3("NLH_PROCES")[3], TamSX3("NLH_PROCES")[1], TamSX3("NLH_PROCES")[2], PesqPict( "NLH", "NLH_PROCES" )	},;		
                  {RetTitle("NLH_CODFEC"), "NLH_CODFEC", TamSX3("NLH_CODFEC")[3], TamSX3("NLH_CODFEC")[1], TamSX3("NLH_CODFEC")[2], PesqPict( "NLH", "NLH_CODFEC" )	},;		
                  {RetTitle("NLH_QTDSLD"), "NLH_QTDSLD", TamSX3("NLH_QTDSLD")[3], TamSX3("NLH_QTDSLD")[1], TamSX3("NLH_QTDSLD")[2], PesqPict( "NLH", "NLH_QTDSLD" )	},; 	
                  {RetTitle("NLH_TOTVIN"), "NLH_TOTVIN", TamSX3("NLH_TOTVIN")[3], TamSX3("NLH_TOTVIN")[1], TamSX3("NLH_TOTVIN")[2], PesqPict( "NLH", "NLH_TOTVIN" )	},; 	
                  {RetTitle("NLH_SALDO" ), "NLH_SALDO" , TamSX3("NLH_SALDO" )[3], TamSX3("NLH_SALDO" )[1], TamSX3("NLH_SALDO" )[2], PesqPict( "NLH", "NLH_SALDO"  )	},; 	
                  {RetTitle("NLH_VCT"   ), "NLH_VCT"   , TamSX3("NLH_VCT"   )[3], TamSX3("NLH_VCT"   )[1], TamSX3("NLH_VCT"   )[2], PesqPict( "NLH", "NLH_VCT"    )	}} 	
				  
    aIndTmp := {{"", "NLH_FILIAL,NLH_NRINVO,NLH_PREEMB,NLH_PARC,NLH_FASE,NLH_PROCES"}}

	//Cria a tabela temporária
    Processa({|| OG710ACTMP(@__cTabTmp, @__cNamTmp, aStrcTmp, aIndTmp)}, STR0012) //"Aguarde. Criando a Tabela..."

/* 	For nCont := 2 to Len(aStrcTmp)
    	If !aStrcTmp[nCont][2] $ ("NLH_FASE|NLH_PROCES")
    		aADD(aFieldsTit,{ aStrcTmp[nCont][1], aStrcTmp[nCont][2], aStrcTmp[nCont][3], aStrcTmp[nCont][4], aStrcTmp[nCont][5], aStrcTmp[nCont][6] })
		EndIF
    Next nCont */
	
	//Cria o array com as colunas que devem ser exibidas no Browse
	For nCont := 2  to Len(aStrcTmp)
		If !aStrcTmp[nCont][2] $ ("NLH_FASE|NLH_PROCES|NLH_CODFEC")
			
			Aadd(aHeader, {aStrcTmp[nCont][1], &("{||"+aStrcTmp[nCont][2]+"}"), aStrcTmp[nCont][3], aStrcTmp[nCont][6], 2, aStrcTmp[nCont][4], aStrcTmp[nCont][5], .F.})
			Aadd(aFilBrwTmp, {aStrcTmp[nCont][2], aStrcTmp[nCont][1], aStrcTmp[nCont][3], aStrcTmp[nCont][4], aStrcTmp[nCont][5], aStrcTmp[nCont][6]})
		
			If aStrcTmp[nCont][2] $ ("NLH_TOTVIN")
				nLinEdit := Len(aHeader)
			EndIf
		
		EndIf
	Next nCont
    
	//-- GRID Títulos
	oBrwTit := FWFormBrowse():New()
	oBrwTit:SetOwner(oPanel)
	oBrwTit:SetDescription(STR0011) //"Títulos em Aberto"
	oBrwTit:SetDataTable(.T.)
    oBrwTit:SetTemporary(.T.)
    oBrwTit:SetAlias(__cTabTmp)
    oBrwTit:SetProfileID("NLH")
    oBrwTit:DisableDetails()    
    oBrwTit:Acolumns := {}
    oBrwTit:SetColumns(aHeader)      
    oBrwTit:DisableReport(.T.)

	// Filtro
    oBrwTit:SetUseFilter(.T.)
	oBrwTit:SetUseCaseFilter(.T.)                         
    oBrwTit:SetFieldFilter(aFilBrwTmp)   
    oBrwTit:SetDBFFilter(.T.)
	oBrwTit:SetSeek( , aSeek )
  	
	oBrwTit:SetEditCell(.T.)
	oBrwTit:bValidEdit := { || ValTotVin() }

	oBrwTit:Acolumns[nLinEdit]:SetEdit(.T.)
    oBrwTit:Acolumns[nLinEdit]:SetReadVar("NLH_TOTVIN")

	oBrwTit:Activate(oPanel)
	
Return .T.

/*/{Protheus.doc} FiltraMark
Função que carrega o filtro padrão da grid das invoices
@type  Static Function
@author rafael.kleestadt
@since 22/10/2018
@version 1.0
@param param, param_type, param_descr
@return cQuery, caractere, filtro no formato advpl
@example
(examples)
@see (links_or_references)
/*/
Static Function FiltraMark()
	Local oModel     := FwModelActive()
	Local nOperation := oModel:GetOperation()
	Local oNLG       := oModel:GetModel( "NLGUNICO" )
	Local cQuery     := ""
	Local cCodCli    := oNLG:GetValue("NLG_CODCLI")
	Local cLojCli    := oNLG:GetValue("NLG_LOJCLI")

	If "NLG_CODCLI" $ ReadVar() .And. Empty(cLojCli)

		cLojCli := POSICIONE('SA1',1,XFILIAL('SA1')+FWFLDGET('NLG_CODCLI'), "A1_LOJA")

	EndIf

	cQuery := "        N82_FILIAL = '" + XFilial('N82') + "' " 
	cQuery += "  .And. N82_CODENT = '" + cCodCli + "' "
	cQuery += "  .And. N82_LOJENT = '" + cLojCli + "' "
	cQuery += "  .And. N82_STATUS = '3' "

	If nOperation == MODEL_OPERATION_INSERT
		cQuery += "  .And. N82_CODFEC = '" + SPACE(TamSX3("N82_CODFEC")[1]) + "' " "
	Else
		cQuery += "  .And. ( N82_CODFEC = '" + oNLG:GetValue("NLG_CODIGO") + "' " "
		cQuery += "  .Or. N82_CODFEC = '" + SPACE(TamSX3("N82_CODFEC")[1]) + "' )" "
	EndIf

Return cQuery

/*/{Protheus.doc} LoadGrdInv()
Função de validação do campo NLG_LOJCLI para realizar o filtro na grid de invoices
@type  Static Function
@author rafael.kleestadt
@since 22/10/2018
@version 1.0
@param param, param_type, param_descr
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function LoadGrdInv()
	Local cFiltro    := FiltraMark()
	
	oBrwInv:SetFilterDefault( cFiltro )

	oBrwInv:Refresh(.T.)
	
	//Posiciona no topo da lista	
	N82->(dbGoTop())
	While N82->( !Eof() )

		If (N82->N82_OK == oBrwInv:Mark())
			nRecno := (oBrwInv:Alias())->(Recno())
			aAdd(_aRecnoN82, nRecno )
		EndIf

		N82->(dbSkip())
	EndDo
	N82->(dbGoTop())
	
	OGAA950REG('1') //Alteração
	oBrwTit:Refresh(.T.)

Return .T.

/*/{Protheus.doc} Marcar()
Função executada após a marcação ou desmarcação do registro
@type  Static Function
@author rafael.kleestadt
@since 22/10/2018
@version 1.0
@param param, param_type, param_descr
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function Marcar()

	Local oModel     := FwModelActive()
	Local nOperation := oModel:GetOperation()
	Local oNLG       := oModel:GetModel( "NLGUNICO" )
	Local nTotInv    := 0
	
	_aRecnoN82 := {}
	
	nRecno := (oBrwInv:Alias())->(Recno())
	aAdd(_aRecnoN82, nRecno )
	
	If oBrwInv:IsMArk()
		OGAA950REG('2') //Alteração
	Else
		OGAA950REG('3') //Exclusão
	EndIF

	//Posiciona no topo da lista	
	N82->(dbGoTop())
	While N82->( !Eof() )

		If (N82->N82_OK == oBrwInv:Mark())
			nTotInv += N82->N82_TOTDES
		EndIf

		N82->(dbSkip())
	EndDo
	N82->(dbGoTop())

	If nOperation <> MODEL_OPERATION_DELETE
		//Total Invoice
		oNLG:LoadValue("NLG_TOTINV", nTotInv)
	EndIF
	
	//Atualiza o saldo -> Saldo Total Invoice - Total Títulos
	fTrgNLGSld()

Return .T.

/*/{Protheus.doc} GrvModelo( oModel )
Função de gravação do modelo de dados, salva o codigo do fechamento nos embarques
@type  Static Function
@author rafael.kleestadt
@since 23/10/2018
@version 1.0
@param oModel, object, objeto do modelo de dados principal
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function GrvModelo( oModel )
	Local oNLG       := oModel:GetModel( "NLGUNICO" )
	Local nOperation := oModel:GetOperation()
	
	IF oNLG:GetValue("NLG_TOTINV") < 0 .And. oNLG:GetValue("NLG_TOTTIT") > 0
		
		If MsgYesNo("Confirma o abatimento dos Títulos selecionados?")
			
			If oNLG:GetValue("NLG_TOTTIT") > Abs(oNLG:GetValue("NLG_TOTINV"))
			
				MsgAlert("Valor dos Títulos selecionados excede o Valor Total do Desconto das Invoices. " + ;
				          "Será realizado o abatimento dos Títulos no valor de " + Str(Abs(oNLG:GetValue("NLG_TOTINV") )) )
			EndIF
			
		EndIF
	EndIF
		
	If FWFormCommit( oModel )

		//Posiciona no topo da lista	
		N82->(dbGoTop())
 		While N82->( !Eof() )

			If RecLock("N82", .F.)

				If oBrwInv:IsMark() .And. nOperation <> MODEL_OPERATION_DELETE
					N82->N82_CODFEC := oNLG:GetValue("NLG_CODIGO")
				Else
					N82->N82_CODFEC := ""	
				EndIf
					
				N82->(MsUnlock())
			EndIf

			N82->(dbSkip())
		EndDo
	
		//Exclui os registros antigos
		(oBrwTit:Alias())->(dbGoTop())
		While (oBrwTit:Alias())->( !Eof() ) 

			dbSelectArea("NLH")
			NLH->(dbGoTop())
			NLH->(dbSetOrder(1))
			IF NLH->(dbSeek(xFilial("NLH")+(oBrwTit:Alias())->(NLH_NRINVO+NLH_PREEMB+NLH_PARC+NLH_FASE+NLH_PROCES) ))
				RecLock("NLH",.F.)
					NLH->(DbDelete()) 
				NLH->(MsUnLock())
			EndIf
			NLH->(DbCloseArea())

			(oBrwTit:Alias())->(dbSkip())
		EndDo
		(oBrwTit:Alias())->(dbGoTop())

		//Grava os novos registros
		(oBrwTit:Alias())->(dbGoTop())
		While (oBrwTit:Alias())->( !Eof() ) 

			dbSelectArea("NLH")

				IF (oBrwTit:Alias())->NLH_TOTVIN > 0 .And. nOperation <> MODEL_OPERATION_DELETE
					RecLock("NLH",.T.)

					NLH->NLH_FILIAL := xFilial("NLH")
					NLH->NLH_NRINVO := (oBrwTit:Alias())->NLH_NRINVO
					NLH->NLH_PREEMB := (oBrwTit:Alias())->NLH_PREEMB
					NLH->NLH_PARC   := (oBrwTit:Alias())->NLH_PARC  
					NLH->NLH_FASE   := (oBrwTit:Alias())->NLH_FASE  
					NLH->NLH_PROCES := (oBrwTit:Alias())->NLH_PROCES
					NLH->NLH_QTDSLD := (oBrwTit:Alias())->NLH_QTDSLD 
					NLH->NLH_TOTVIN := (oBrwTit:Alias())->NLH_TOTVIN 
					NLH->NLH_SALDO  := (oBrwTit:Alias())->NLH_SALDO
					NLH->NLH_CODFEC := oNLG:GetValue("NLG_CODIGO")
					NLH->NLH_VCT    := (oBrwTit:Alias())->NLH_VCT
						
					NLH->(MsUnLock())
				EndIF

			NLH->(DbCloseArea())

			(oBrwTit:Alias())->(dbSkip())
		EndDo
		(oBrwTit:Alias())->(dbGoTop())

	EndIf

Return .T.

/*/{Protheus.doc} AfterVal
Seta um bloco de código que será chamado depois do Activate do View.
@type  Static Function
@author rafael.kleestadt
@since 23/10/2018
@version 1.0
@param oView, object, objeto da view
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AfterVal( oView )
	Local oModel     := oView:GetModel()
	Local oNLG       := oModel:GetModel( "NLGUNICO" )
	Local nOperation := oModel:GetOperation()
	Local aAreaN82   := N82->(GetArea())
	Local nTotInv    := 0

	If nOperation <> MODEL_OPERATION_INSERT .And. nOperation <> MODEL_OPERATION_UPDATE
		oBrwInv:Disable()
		oBrwTit:Disable()
	EndIF
	
	_aRecnoN82  := {}
	
	// Seta os campos de data e hora da ultima atualização para setar o modelo como alterado
	If oModel:Activate() .And. (nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE)	
 		//oNLG:LoadValue("NLG_DTUATU", DDATABASE )
		//oNLG:LoadValue("NLG_HRUATU", SubStr(TIME(), 0, 8) )

		oView:SetModified(.T.) // Seta a View como modificada, para realizar o commit.
	EndIf

	//Posiciona no topo da lista	
	N82->(dbGoTop())
	While N82->( !Eof() )

		If N82->N82_CODFEC == oNLG:GetValue("NLG_CODIGO")

			RecLock(oBrwInv:Alias(),.F.)
			(oBrwInv:Alias())->N82_OK  := oBrwInv:Mark()
			(oBrwInv:Alias())->(MsUnLock())
			
			aAdd(_aRecnoN82, N82->(Recno()) )
			
			nTotInv += (oBrwInv:Alias())->N82_TOTDES

		EndIf

		N82->(dbSkip())
	EndDo

	N82->(dbGoTop())
	
	If nOperation <> MODEL_OPERATION_DELETE
		//Total Invoice
		oNLG:LoadValue("NLG_TOTINV", nTotInv)
	EndIF
	
	// Carrega
	OGAA950REG('1') //Valor inicial
	
	If nOperation <> MODEL_OPERATION_DELETE
		//Total Invoice
		oNLG:LoadValue("NLG_TOTTIT", fSomaTit())
	
		//Atualiza o saldo -> Saldo Total Invoice - Total Títulos
		fTrgNLGSld()
	EndIf
    
	(__cTabTmp)->(dbGoTop())
	
    oBrwInv:Refresh()
    oBrwTit:Refresh()

	oBrwTit:SetFocus()  // Focus no browser de Finalidades - Principal
	oBrwTit:GoColumn(1) // Posiciona o Browse 2 na primeira coluna depois da ativação

	oBrwTit:GoPgDown() 
	oBrwTit:GoPgUp()
	
	oView:Refresh()

	RestArea(aAreaN82)

Return .T.

/*{Protheus.doc} OGAA950REG
- Função para carregar as tabelas temporarias
@author 	tamyris.g
@since 		24/10/2018
@version 	1.0
@return 	Nil
*/
Function OGAA950REG(cOpcao)
    
   	Local oView      := FwViewActive()
	Local oModel     := oView:GetModel()
	Local oNLG       := oModel:GetModel( "NLGUNICO" )
	Local nOperation := oModel:GetOperation()
    Local nX         := 0 
    Local cFiltro    := ""
    Local cCodFec    := ""
	Local nTotVin    := 0
	Local nSaldo     := 0
	Local nQtdSld    := 0
    			
    If cOpcao == '1'
		// Limpa a tabela temporária
		DbSelectArea(__cTabTmp)
		(__cTabTmp)->(DbSetorder(1))
		ZAP
	EndIF
	
	For nX := 1 to Len(_aRecnoN82)
		If !empty(cFiltro)
			cFiltro += " OR "
		Else
		 	cFiltro += " ( "
		EndIf
		cFiltro +=  "N82.R_E_C_N_O_ = " + cValToChar(_aRecnoN82[nX])
	Next nX
	
	If !Empty(cFiltro)
		cFiltro += " ) "
		
	    cAliasQry := GetNextAlias()
		cQuery := "   SELECT *  FROM " + RetSqlName('EEQ') + " EEQ "
		cQuery += " INNER JOIN " + RetSqlName("N82") + " N82 "
		cQuery += "  ON " + cFiltro
		
		cQuery += "    WHERE EEQ.EEQ_FILIAL =  N82.N82_FILORI "
		cQuery += "      AND EEQ.EEQ_PREEMB =  N82.N82_PEDIDO "
		cQuery += "      AND EEQ.EEQ_NRINVO =  N82.N82_CODINV "
		cQuery += "      AND EEQ.EEQ_EVENT = '101'" ///Relacionadas às invoices
		cQuery += "      AND EEQ_DTCE  = ''" //Ainda não recebidas
		cQuery += "      AND EEQ.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T.)
		(cAliasQry)->(dbGoTop())
		If !(cAliasQry)->( Eof() )
			While ( cAliasQry )->( !Eof() )
				
				If cOpcao $ '12' //Alteração - Marca
					
					//Se encontra, carrega os campos alteraveis.
					cCodFec := ""
					dbSelectArea("NLH")
					NLH->(dbGoTop())
					NLH->(dbSetOrder(1))
					IF NLH->(dbSeek(xFilial("NLH")+(cAliasQry)->(EEQ_NRINVO+EEQ_PREEMB+EEQ_PARC+EEQ_FASE+EEQ_PROCES) ))
						cCodFec := NLH->NLH_CODFEC
						nTotVin := NLH->NLH_TOTVIN
						nQtdSld := NLH->NLH_QTDSLD
						nSaldo  := NLH->NLH_QTDSLD - NLH->NLH_TOTVIN
					EndIF
					NLH->(DbCloseArea())
						
					RecLock((__cTabTmp),.T.)
						(__cTabTmp)->NLH_FILIAL := (cAliasQry)->EEQ_FILIAL
						(__cTabTmp)->NLH_NRINVO := (cAliasQry)->EEQ_NRINVO
						(__cTabTmp)->NLH_PREEMB := (cAliasQry)->EEQ_PREEMB
						(__cTabTmp)->NLH_PARC   := (cAliasQry)->EEQ_PARC 
						(__cTabTmp)->NLH_FASE   := (cAliasQry)->EEQ_FASE 
						(__cTabTmp)->NLH_PROCES := (cAliasQry)->EEQ_PROCES
						(__cTabTmp)->NLH_QTDSLD := IIF(nOperation == 1, (cAliasQry)->EEQ_SALDO, nQtdSld)
						(__cTabTmp)->NLH_TOTVIN := nTotVin
						(__cTabTmp)->NLH_CODFEC := cCodFec
						(__cTabTmp)->NLH_SALDO  := IIF(nOperation == 1, (cAliasQry)->EEQ_SALDO, nSaldo)
						(__cTabTmp)->NLH_VCT    := STOD((cAliasQry)->EEQ_VCT)	
					(__cTabTmp)->(MsUnlock())

				ElseIf cOpcao == '3' //Exclusão - Desmarca
					
					//Eliminar registro na tabela temporária
					DbselectArea(__cTabTmp)
					(__cTabTmp)->(DbGoTop())
					(__cTabTmp)->(DbSetOrder(1))
					If (__cTabTmp)->(DbSeek((cAliasQry)->(EEQ_FILIAL+EEQ_NRINVO+EEQ_PREEMB) ))
						RecLock(__cTabTmp, .F.)	
							(__cTabTmp)->(DbDelete())
						(__cTabTmp)->(MsUnlock())
					EndIf
					
				EndIF
				
				(cAliasQry)->( DbSkip() )
			EndDo
		EndIf
		(cAliasQry)->(DbCloseArea())
	EndIf  
	
	(__cTabTmp)->(dbGoTop())

	If nOperation <> MODEL_OPERATION_DELETE
		//Total Invoice
		oNLG:LoadValue("NLG_TOTTIT", fSomaTit())
	EndIF

	oBrwTit:Refresh(.T.)

	oView:Refresh()
	
Return .T.

/*/{Protheus.doc} fTrgNLGSld()
Função de validação dos campos NLG_TOTINV e NLG_TOTTIT para atualizar o campo NLG_SLDINT
@type  Static Function
@author rafael.kleestadt
@since 24/10/2018
@version 1.0
@param param, param_type, param_descr
@return True, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function fTrgNLGSld()
	Local oModel := FwModelActive()
	Local oView  := FwViewActive()
	Local oNLG   := oModel:GetModel( "NLGUNICO" )
	Local lRet   := .F.
	
	If oView:IsActive()
		//Saldo Total Invoice - Total Títulos
		If oNLG:GetValue("NLG_TOTINV") < 0 //Se saldo é negativo, realiza o abatimento dos títulos em aberto
			If oNLG:GetValue("NLG_TOTTIT") >= ABS(oNLG:GetValue("NLG_TOTINV")) //Até o limite do valor das invoices
				lRet := oNLG:LoadValue("NLG_SLDINT", 0)
			Else
				lRet := oNLG:LoadValue("NLG_SLDINT", oNLG:GetValue("NLG_TOTINV") + oNLG:GetValue("NLG_TOTTIT"))
			EndIF

			oBrwTit:SetEditCell( .T., { || ValTotVin() })

		Else //Se saldo é positivo, não desconta dos títulos em aberto
			lRet := oNLG:LoadValue("NLG_SLDINT", oNLG:GetValue("NLG_TOTINV") )

			oBrwTit:SetEditCell( .F., { || .T. })

		EndIf
	EndIf

	oBrwInv:Refresh()
	oBrwTit:Refresh()
	oView:Refresh()

Return lRet

/*/{Protheus.doc} MarkAll
Code-Block executado no clique do header da coluna de marca/desmarca, atualiza os campos Total Invoice e Total Títulos
@type  Static Function
@author rafael.kleestadt
@since 25/10/2018
@version 1.0
@param cOpcao, caractere, 1-Browse Invoices, 2-Browse Títulos
@return True, Logycal, True or False
@example
(examples)
@see (links_or_references)
/*/
Static Function MarkAll()
	Local oModel     := FwModelActive()
	Local oNLG       := oModel:GetModel( "NLGUNICO" )
	Local nOperation := oModel:GetOperation()
	Local nTotInv    := 0

	_aRecnoN82 := {}

	//Posiciona no topo da lista	
	N82->(dbGoTop())
	While N82->( !Eof() )

		RecLock("N82",.F.)

			If (N82->N82_OK <> oBrwInv:Mark())
				N82->N82_OK := oBrwInv:Mark()
				nTotInv += N82->N82_TOTDES
				aAdd(_aRecnoN82, N82->(Recno()) )
			ElseIf (N82->N82_OK == oBrwInv:Mark())
				N82->N82_OK := ""
			EndIf

		N82->(MsUnLock())

		N82->(dbSkip())
	EndDo
	N82->(dbGoTop())

	If nOperation <> MODEL_OPERATION_DELETE
		//Total Invoice
		oNLG:LoadValue("NLG_TOTINV", nTotInv)
	EndIF

	OGAA950REG('1')

	oBrwInv:GoTop(.T.)

	//Atualiza o saldo -> Saldo Total Invoice - Total Títulos
	fTrgNLGSld()

Return .T.

/*/{Protheus.doc} ValTotVin()
Valida e atualiza os campos de saldo
@type  Static Function
@author rafael.kleestadt
@since 01/11/2018
@version 1.0
@param param, param_type, param_descr
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function ValTotVin()
	Local oModel     := FwModelActive()
	Local oNLG       := oModel:GetModel( "NLGUNICO" )
	Local nOperation := oModel:GetOperation()

	If nOperation <> MODEL_OPERATION_DELETE
		If (oBrwTit:Alias())->NLH_TOTVIN <= (oBrwTit:Alias())->NLH_QTDSLD
			//Total Invoice
			oNLG:LoadValue("NLG_TOTTIT", fSomaTit())

			//Calcula o saldo
			RecLock(oBrwTit:Alias(),.F.)
				(oBrwTit:Alias())->NLH_SALDO := (oBrwTit:Alias())->NLH_QTDSLD - (oBrwTit:Alias())->NLH_TOTVIN
			(oBrwTit:Alias())->(MsUnLock())
		Else
			HELP(' ', 1, RetTitle("NLH_TOTVIN") ,,STR0013+AllTrim(RetTitle("NLH_TOTVIN"))+STR0014+AllTrim(RetTitle("NLH_QTDSLD"))+".",2,0,,,,,, {STR0015+AllTrim(RetTitle("NLH_TOTVIN"))+"."})
			//Tot. Vincula###"O valor do campo "###Tot. Vincula ###" não pode ser maior que o do campo "###Qtd. Saldo.###"Ajuste o valor informado no campo "###Tot. Vincula.
			Return .F.
		EndIF
	EndIF

	//Atualiza o saldo -> Saldo Total Invoice - Total Títulos
	fTrgNLGSld()

Return .T.

/*/{Protheus.doc} fSomaTit()
Soma a quantidade vinculada na grid de títulos
@type  Static Function
@author rafael.kleestadt
@since 01/11/2018
@version 1.0
@param param, param_type, param_descr
@return nTotTit, numeric, Soma da quantidade vinculada na grid de títulos
@example
(examples)
@see (links_or_references)
/*/
Static Function fSomaTit()
	Local aAreaTmp  := (__cTabTmp)->( GetArea() )
	Local nTotTit   := 0

	//Posiciona no topo da lista	
	(__cTabTmp)->(dbGoTop())
	While (__cTabTmp)->( !Eof() )

		nTotTit += (__cTabTmp)->NLH_TOTVIN

		(__cTabTmp)->(dbSkip())
	EndDo

	RestArea(aAreaTmp)

	oBrwTit:Refresh(.T.)

Return nTotTit

/*/{Protheus.doc} PosModelo( oModel )
Função de pós-validação do modelo
@type  Static Function
@author rafael.kleestadt
@since 02/11/2018
@version 1.0
@param oModel, object, objeto do modelo de dados principal
@return true, logycal, true or false
@example
(examples)
@see (links_or_references)
/*/
Static Function PosModelo( oModel )
	Local oNLG       := oModel:GetModel( "NLGUNICO" )
	Local cTotTit    := ""
	Local cTotInv    := ""
	Local cTotInvPos := ""

	If oNLG:GetValue("NLG_TOTTIT") + oNLG:GetValue("NLG_TOTINV") > 0

		cTotTit    := AllTrim(cValToChar(Transform( oNLG:GetValue("NLG_TOTTIT"),PesqPict("NLG", "NLG_TOTTIT"))))
		cTotInv    := AllTrim(cValToChar(Transform( oNLG:GetValue("NLG_TOTINV"),PesqPict("NLG", "NLG_TOTINV"))))
		
		If Negativo(oNLG:GetValue("NLG_TOTINV"))
			cTotInvPos := AllTrim(cValToChar(Transform( -oNLG:GetValue("NLG_TOTINV"),PesqPict("NLG", "NLG_TOTINV"))))
		Else
			cTotInvPos := cTotInv
		EndIf

		HELP(' ',1,RetTitle("NLG_TOTTIT") ,,STR0016+cTotTit+STR0017+cTotInv+STR0018,2,0,,,,,, {STR0019+cTotInvPos+"."})
		           //Vl Tot Tit###"O valor de "###" dos titúlos ultrapassou o valor necessário de "###" dos descontos das invoices marcadas."###"Ajuste os valores informados para que a soma não ultrapasse "###"."
		Return .F.
	EndIf

Return .T.