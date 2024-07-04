#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWADAPTEREAI.CH"
#INCLUDE "AGRA530.CH"

Static __cRet 		:= ''


/*/{Protheus.doc} AGRA530
//Consulta Ordem de Colheita
@author carlos.augusto
@since 09/02/2018
@version 12.1.20
@type function
/*/
Function AGRA530()
	Private _cCLTTEMP		//Alias para TT
	
	//Tabela Temporária de Consulta de Ordem de Colheita, caso nao tenha sido enviada
	If _cCLTTEMP == Nil
		_cCLTTEMP := AGRA530TTO(@_cCLTTEMP)
	EndIf
	AGRA530ODC(.T., _cCLTTEMP, .F.)

Return( Nil )


Static Function MenuDef()
	Local aRotina := {}
	aAdd( aRotina, { STR0001	, 'VIEWDEF.AGRA530', 0, 2, 0, NIL } )// Visualisar
	aAdd( aRotina, { STR0002    , 'VIEWDEF.AGRA530', 0, 3, 0, NIL } )// Incluir
	aAdd( aRotina, { STR0003	, 'VIEWDEF.AGRA530', 0, 4, 0, NIL } )// Alterar
	aAdd( aRotina, { STR0004	, 'VIEWDEF.AGRA530', 0, 5, 0, NIL } )// Excluir 
	aAdd( aRotina, { STR0005	, 'VIEWDEF.AGRA530', 0, 8, 0, NIL } )// Imprimir
	

Return aRotina


Static Function ModelDef()
	Local oStruNJJ 	:= FWFormStruct( 1,"NJJ")
	Local oModel 	:= MPFormModel():New("AGRA530")

	
	oModel:SetDescription(STR0006)
	oModel:AddFields( 'NJJAGRA530', /*cOwner*/, oStruNJJ )
	oModel:SetPrimaryKey( { "NJJ_FILIAL", "NJJ_CODIGO" } )
	oModel:GetModel( 'NJJAGRA530' ):SetDescription( STR0007 ) //"Consulta de Ordem de Colheita"
	

Return ( oModel )

Static Function ViewDef()

	Local oStruNJJ	:= FWFormStruct( 2, "NJJ" )
	Local oModel   	:= FWLoadModel( "AGRA530" )
	Local oView    	:= FWFormView():New()
		
	oView:SetModel( oModel )
	oView:AddField( "AGRA530_NJJ", oStruNJJ, "NJJAGRA530" )

	oView:CreateVerticallBox( "TELANOVA" , 100 )
	oView:CreateHorizontalBox( "SUPERIOR" , 100, "TELANOVA" )
	oView:SetOwnerView( "AGRA530_NJJ", "SUPERIOR" )
	oView:EnableTitleView( "AGRA530_NJJ" )
	
	oView:SetCloseOnOk( {||.t.} )

Return (oView) 

	
/*/{Protheus.doc} AGRA530ODC
//Consulta de Ordem de Colheita 
@author carlos.augusto
@since 29/01/2018
@version undefined
@param lDialog, characters, indica se deve abrir a dialog para selecao de registro
@param cCLTAux, characters, alias da tabela temporaria passada por referencia
@type function
/*/
Function AGRA530ODC(lDialog, cCLTAux, lZoom)
	Local aArea       	:= GetArea()
	Local aCoors 		:= FWGetDialogSize(oMainWnd) //Tamanho tela
	Local nAltura  		
	Local nLargura 		
	Local aColFilter 	:= {}
	Local aSeek        	:= {} 
	Local oPnColheita 	:= Nil
	Local oDlgClt     	:= Nil
	Local oFwLayer    	:= Nil
	Local aColColheita 	:= {}
	Local oBrwClt     	:= Nil
	Local nx
	Local nCol
	Local aRet 			:= {}
	Local lSemErro		:= .T. //Tratar selecao no grid futuramente
   	Local aStrColh		:= AGRA530CLT() //Estrutura da TT
   	Local lRet			:= .T.
   	Local lConfInt		:= .F.
	Private _cCLTTEMP	:= cCLTAux	//Alias para TT
	Private _oCLTTEMP				//Objeto para TT
   	Default lZoom		:= .T.
   	
	nAltura		:= IIF(lZoom, aCoors[3] * 0.7, aCoors[3])  //Tamanho tela
	nLargura	:= IIF(lZoom, aCoors[4] * 0.7, aCoors[4])  //Tamanho tela
	
	//Tabela Temporária de Consulta de Ordem de Colheita, caso nao tenha sido enviada
	If _cCLTTEMP == Nil
		_cCLTTEMP := AGRA530TTO(@_cCLTTEMP)
	Else
		//limpa a tabela temporária
		DbSelectArea((_cCLTTEMP))
		ZAP
	EndIf
		
	If FWHasEAI( "AGRA530", .T., .F., .T. )
		Processa({|| aRet := FWIntegDef( "AGRA530", EAI_MESSAGE_BUSINESS, TRANS_SEND, "", "AGRA530", .F., "1.001")}, STR0007 ) //"Realizando Integração com o PIMS. Aguarde."
		lConfInt := .T.
	EndIf
    
	//Erros de integracao. Teve alteracao na include	
    If !lConfInt .Or. aRet == Nil 
		Help('' ,1,".AGRA53000001.", ,STR0008 ,1,0)   
		//""Integração entre Protheus x PIMS não foi efetuada. STR0008,  "Verifique as configurações de integração da mensagem GetHarvestOrder."
		lRet := .F.
	ElseIf !Empty(aRet)  .And. !aRet[1]
		Help('' ,1,".AGRA53000001.", , STR0009 + aRet[2] ,1,0)
		//"Inconsistência na integração Protheus x PIMS. "
		lRet := .F.
	EndIf    

	If lRet .And. !Empty(lDialog) .And. lDialog
		(_cCLTTEMP)->(dbGoTop())

		DEFINE MSDIALOG oDlgClt TITLE STR0006 FROM aCoors[1], aCoors[2] TO nAltura, nLargura PIXEL OF oMainWnd //"Consulta Ordens de Colheita"
	
		oFwLayer := FwLayer():New()
		oFwLayer:Init( oDlgClt, .f., .t. )
		oFWLayer:AddLine( 'GRID', 100, .F. )
		oFWLayer:AddCollumn( 'ALL' , 100, .T., 'GRID' )
	
		oWIN   := oFWLayer:GetColPanel( 'ALL', 'GRID' )
		
		//Monta as colunas desconsiderando os campos abaixo
		nCol := 1
		For nX := 1 to Len(aStrColh)
			If !(aStrColh[nX,1] $ "IDPROD,IDOPOS")
				aAdd(aColColheita,FWBrwColumn():New())
				aColColheita[nCol]:SetData(&("{||"+aStrColh[nX,1]+"}"))
				aColColheita[nCol]:SetTitle(aStrColh[nX,5])
				aColColheita[nCol]:SetPicture(aStrColh[nX,6])
				aColColheita[nCol]:SetType(aStrColh[nX,2])
				aColColheita[nCol]:SetSize(aStrColh[nX,3])
				aColColheita[nCol]:SetReadVar(aStrColh[nX,1])
				nCol++
			EndIf	
		Next nX
	    
		aColFilter := ColFilter()
		Aadd(aSeek,{STR0010 ,{{"", 'C' , 26 , 0 , "@!" }}, 1, .T. } ) //"Ordem+Sistema+Fazenda"
	
		DEFINE FWFORMBROWSE oBrwClt DATA TABLE ALIAS _cCLTTEMP DESCRIPTION STR0011 OF oPnColheita //Ordens de Colheita
		oBrwClt:SetSeek( ,aSeek)
		oBrwClt:SetTemporary(.T.)
		oBrwClt:SetFieldFilter(aColFilter)
		oBrwClt:SetColumns(aColColheita)
		oBrwClt:SetOwner(oWIN)
		oBrwClt:SetDBFFilter(.T.)
		oBrwClt:SetUseFilter(.T.)
		oBrwClt:DisableDetails(.F.)
		oBrwClt:SetDoubleClick( {|| lSemErro := AGRA530SEL(), IIf(lSemErro, oDlgClt:End(),)   })
		oBrwClt:AddButton(STR0034,{|| AGRA530SEL(), oDlgClt:end()},,9,0) //Ok
        oBrwClt:AddButton(STR0035,{|| oDlgClt:end()},,9,0) //"Cancelar"
		ACTIVATE FWFORMBROWSE oBrwClt
		ACTIVATE MSDIALOG oDlgClt CENTERED
	EndIf

	RestArea(aArea)

Return lRet


/*/{Protheus.doc} AGRA530TTO
//Cria temporaria de Consulta de Ordens de Colheita
@author carlos.augusto
@since 31/01/2018
@version undefined
@param _cCLTTEMP, , descricao
@type function
/*/
Function AGRA530TTO(cCLTAux)
	Local oCLTTEMP
	Local aStrColh	:= AGRA530CLT() //Estrutura da TT
	
	cCLTAux := GetNextAlias()
	oCLTTEMP := FwTemporaryTable():New(cCLTAux)
	oCLTTEMP:SetFields(aStrColh)
	oCLTTEMP:AddIndex("1",{"ORDCLT","CODSIS","CODFAZ"})
	oCLTTEMP:Create()
		
Return cCLTAux

/*/{Protheus.doc} AGRA530SEL
//Confirma selecao de Ordem de Colheita
@author silvana.torres/carlos.augusto
@since 30/01/2018
@version 12.1.20
@type function
/*/
Function AGRA530SEL()

	__cRet := (_cCLTTEMP)->ORDCLT

Return(.T.)


	
/*/{Protheus.doc} AGRA530RET
//Retorno NJJES1
@author silvana.torres/carlos.augusto
@since 30/01/2018
@version undefined
@type function
/*/
Function AGRA530RET()
	
	//Caso o usuário preencha o campo e depois dê esc, atribuo branco pra __cRet. //silvana
	Iif( __cRet = Nil, __cRet := Space(TamSx3("NJJ_ORDCLT")[1]),)
	
	If .Not. Empty(__cRet)
		Do Case
			Case IsInCallStack('AGRA500')
				lRet := AGRA500ORD(__cRet, _cCLTTEMP)
				If .Not. lRet
					__cRet := Space(TamSx3("NJJ_ORDCLT")[1])
				EndIf
			Case IsInCallStack('AGRA601')
				lRet := AGRA601ORD(__cRet, _cCLTTEMP)
				If .Not. lRet
					__cRet := Space(TamSx3("DXL_ORDCLT")[1])
				EndIf
		EndCase
	EndIf
Return(__cRet)



/*/{Protheus.doc} ColFilter
//Alterar nome das colunas para campos na opcao 'Criar Filtro'
@author carlos.augusto
@since 30/01/2018
@version undefined
@type function
/*/
Static Function ColFilter()
	Local aColFilter  := {}
	
	aAdd(aColFilter, {"ORDCLT", AGRTITULO("NJJ_ORDCLT"),TamSX3("NJJ_ORDCLT")[3], TamSX3("NJJ_ORDCLT")[1], TamSX3("NJJ_ORDCLT")[2], PesqPict("NJJ", "NJJ_ORDCLT")} )
	aAdd(aColFilter, {"DATORD", STR0013				   ,"D"					   , 8					    , 0					     ,""  })
	aAdd(aColFilter, {"PREINI", STR0014				   ,"D"					   , 8					    , 0					     ,""  })
	aAdd(aColFilter, {"PREENC", STR0015				   ,"D"					   , 8					    , 0					     ,""  })
	aAdd(aColFilter, {"CODVAR", STR0016				   ,"C"					   , TamSX3("NNV_CODIGO")[1], TamSX3("NNV_CODIGO")[2],"@!"})
	aAdd(aColFilter, {"DESVAR", STR0017				   ,"C"					   , TamSX3("NNV_DESCRI")[1], 0					     ,"@!"})
	aAdd(aColFilter, {"CODPRO", STR0018				   ,"C"					   , TamSX3("B1_COD")[1]	, 0					     ,"@!"})
//	aAdd(aColFilter, {"IDPROD", STR0019				   ,"C"					   , 38					    , 0					     ,"@!"})
	aAdd(aColFilter, {"CODSIS", STR0020				   ,"C"					   , 10					    , 0					     ,"@!"})
	aAdd(aColFilter, {"DESSIS", STR0021				   ,"C"					   , 30					    , 0					     ,"@!"})
	aAdd(aColFilter, {"CODFAZ", STR0022				   ,"C"					   , TamSX3("NN2_CODIGO")[1], 0					     ,"@!"})
	aAdd(aColFilter, {"DESFAZ", STR0023				   ,"C"					   , TamSX3("NN2_NOME")[1]  , 0					     ,"@!"})
	aAdd(aColFilter, {"CODSET", STR0024				   ,"C"					   , 10					    , 0					     ,"@!"})
	aAdd(aColFilter, {"DESSET", STR0025				   ,"C"					   , 50					    , 0					     ,"@!"})
	aAdd(aColFilter, {"CODTAL", STR0026				   ,"C"					   , 6					    , 0					     ,"@!"})
	aAdd(aColFilter, {"DESTAL", STR0027				   ,"C"					   , TamSX3("NN3_DESCRI")[1], 0					     ,"@!"})
	aAdd(aColFilter, {"CODOCP", STR0028				   ,"C"					   , 10					    , 0					     ,"@!"})
	aAdd(aColFilter, {"DESOCP", STR0029				   ,"C"					   , 30					    , 0					     ,"@!"})
	aAdd(aColFilter, {"ARETAL", STR0030				   ,"N"					   , 14					    , 2					     ,"@E 99,999,999,999.99"})
	aAdd(aColFilter, {"PESEST", STR0031				   ,"N"					   , 14					    , 2					     ,"@E 99,999,999,999.99"})
	aAdd(aColFilter, {"CODOPS", STR0032				   ,"C"					   , 6					    , 0					     ,"@!"})
//	aAdd(aColFilter, {"IDOPOS", STR0279				   ,"C"					   , 38					    , 0					     ,"@!"})
	
Return aColFilter

/*/{Protheus.doc} AGRA530CLT
//Retorna estrutura da tabela temporária de Consulta de Ordem de Colheita
@author carlos.augusto
@since 25/01/2018
@version 12.1.20
@type function
/*/
Function AGRA530CLT()
	Local aCLTTEMP := {}

	aAdd(aCLTTEMP,{ "ORDCLT", TamSX3("NJJ_ORDCLT")[3], TamSX3("NJJ_ORDCLT")[1], TamSX3("NJJ_ORDCLT")[2], AGRTITULO("NJJ_ORDCLT") , PesqPict("NJJ", "NJJ_ORDCLT")})
	aAdd(aCLTTEMP,{ "DATORD", "D"					 , 8					  , 0					   , STR0013 		 , "" 							})//"Data Ordem" 	
	aAdd(aCLTTEMP,{ "PREINI", "D"					 , 8					  , 0					   , STR0014		 , "" 							})//"Prev. Inic." 	
	aAdd(aCLTTEMP,{ "PREENC", "D"					 , 8					  , 0					   , STR0015		 , "" 							})//"Prev. Encer."	
	aAdd(aCLTTEMP,{ "CODVAR", "C"					 , TamSX3("NNV_CODIGO")[1], TamSX3("NNV_CODIGO")[2], STR0016		 , "@!"							})//"Cód.Variedad"	
	aAdd(aCLTTEMP,{ "DESVAR", "C"					 , TamSX3("NNV_DESCRI")[1], 0					   , STR0017		 , "@!"							})//"Des.Variedad"	
	aAdd(aCLTTEMP,{ "CODPRO", "C"					 , TamSX3("B1_COD")[1]	  , 0					   , STR0018		 , "@!"							})//"Cód. Produto"	
	aAdd(aCLTTEMP,{ "IDPROD", "C"					 , 38					  , 0					   , STR0019		 , "@!"							})//"Id.Integ.Pro"	
	aAdd(aCLTTEMP,{ "CODSIS", "C"					 , 10					  , 0					   , STR0020		 , "@!"							})//"Cód.Sist.Col"	
	aAdd(aCLTTEMP,{ "DESSIS", "C"					 , 30					  , 0					   , STR0021		 , "@!"							})//"Des.Sist.Col"	
	aAdd(aCLTTEMP,{ "CODFAZ", "C"					 , TamSX3("NN2_CODIGO")[1], 0					   , STR0022		 , "@!"							})//"Cód. Fazenda"	
	aAdd(aCLTTEMP,{ "DESFAZ", "C"					 , TamSX3("NN2_NOME")[1]  , 0					   , STR0023		 , "@!"							})//"Des. Fazenda"	
	aAdd(aCLTTEMP,{ "CODSET", "C"					 , 10					  , 0					   , STR0024		 , "@!"							})//"Cód. Setor"	
	aAdd(aCLTTEMP,{ "DESSET", "C"					 , 50					  , 0					   , STR0025		 , "@!"							})//"Des. Setor"	
	aAdd(aCLTTEMP,{ "CODTAL", "C"					 , 6					  , 0					   , STR0026		 , "@!"							})//"Cód. Talhão"	
	aAdd(aCLTTEMP,{ "DESTAL", "C"					 , 50					  , 0					   , STR0027		 , "@!"							})//"Des. Talhão"	
	aAdd(aCLTTEMP,{ "CODOCP", "C"					 , 10					  , 0					   , STR0028		 , "@!"							})//"Cód.Ocupação"	
	aAdd(aCLTTEMP,{ "DESOCP", "C"					 , 30					  , 0					   , STR0029		 , "@!"							})//"Des.Ocupação"	
	aAdd(aCLTTEMP,{ "ARETAL", "N"					 , 14					  , 2					   , STR0030		 , "@E 99,999,999,999.99"		})//"Área Talhão"	
	aAdd(aCLTTEMP,{ "PESEST", "N"					 , 14					  , 2					   , STR0031		 , "@E 99,999,999,999.99"		})//"Est.Colheita"	
	aAdd(aCLTTEMP,{ "CODOPS", "C"					 , 6					  , 0					   , STR0032		 , "@!"							})//"Cód.OP/OS"	
	aAdd(aCLTTEMP,{ "IDOPOS", "C"					 , 38					  , 0					   , STR0033		 , "@!"							})//"Id. OP/OS" 

Return aCLTTEMP


/*/{Protheus.doc} AGRA530OCD
//Com base no elemento harvestOrder, insere um registro na tabela temporária de Consulta de Ordem de Colheita
@author carlos.augusto
@since 29/01/2018
@version 12.1.20
@param harvestOrder, , elemento do xml da Ordem de Colheita
@param cCLTTEMP, characters, tabela temporaria de Consulta de Ordem de Colheita que deve ser passada por referencia
@type function
/*/
Function AGRA530OCD(harvestOrder, cCLTTEMP)
	dbSelectArea(cCLTTEMP)
	If RecLock(cCLTTEMP,.T.)

		//Número da Ordem e Colheita
		If ( XmlChildEx( harvestOrder, '_HARVESTORDERCODE' ) != Nil )
			(cCLTTEMP)->ORDCLT    := harvestOrder:_HarvestOrderCode:Text
		EndIf
		
		//Data da Ordem de Colheita
		If ( XmlChildEx( harvestOrder, '_HARVESTORDERDATE' ) != Nil )
			(cCLTTEMP)->DATORD    := STOD(STRTRAN(harvestOrder:_HarvestOrderDate:Text, '-', '')) 
		EndIf

		//Previsão de Início de Colheita
		If ( XmlChildEx( harvestOrder, '_STARTHARVESTFORECAST' ) != Nil )
			(cCLTTEMP)->PREINI    := STOD(STRTRAN(harvestOrder:_StartHarvestForecast:Text, '-', '')) 
		EndIf
		
		//Previsão de Encerramento da Colheita
		If ( XmlChildEx( harvestOrder, '_CLOSINGHARVESTFORECAST' ) != Nil )
			(cCLTTEMP)->PREENC    := STOD(STRTRAN(harvestOrder:_ClosingHarvestForecast:Text, '-', '')) 
		EndIf
		
		//Código da Variedade
		If ( XmlChildEx( harvestOrder, '_VARIETYCODE' ) != Nil )
			(cCLTTEMP)->CODVAR    := harvestOrder:_VarietyCode:Text
		EndIf
		
		//Descrição da Variedade
		If ( XmlChildEx( harvestOrder, '_VARIETYDESCRIPTION' ) != Nil )
			(cCLTTEMP)->DESVAR    := harvestOrder:_VarietyDescription:Text
		EndIf
		
		//Código do Produto Matéria Prima
		If ( XmlChildEx( harvestOrder, '_ITEMCODE' ) != Nil )
			(cCLTTEMP)->CODPRO    := harvestOrder:_ItemCode:Text
		EndIf
		
		//Id de integração do Produto
		If ( XmlChildEx( harvestOrder, '_ITEMINTERNALID' ) != Nil )
			(cCLTTEMP)->IDPROD    := harvestOrder:_ItemInternalId:Text
		EndIf				
		
		//Código do Sistema de Colheita
		If ( XmlChildEx( harvestOrder, '_HARVESTSYSTEMCODE' ) != Nil )
			(cCLTTEMP)->CODSIS    := harvestOrder:_HarvestSystemCode:Text
		EndIf				
		
		//Descrição do Sistema de Colheita
		If ( XmlChildEx( harvestOrder, '_HARVESTSYSTEMDESCRIPTION' ) != Nil )
			(cCLTTEMP)->DESSIS    := harvestOrder:_HarvestSystemDescription:Text
		EndIf				

		//Código da [Fazenda]
		If ( XmlChildEx( harvestOrder, '_FARMCODE' ) != Nil )
			(cCLTTEMP)->CODFAZ    := harvestOrder:_FarmCode:Text
		EndIf	

		//Descrição da [Fazenda]
		If ( XmlChildEx( harvestOrder, '_FARMDESCRIPTION' ) != Nil )
			(cCLTTEMP)->DESFAZ    := harvestOrder:_FarmDescription:Text
		EndIf

		//Código do [Setor]
		If ( XmlChildEx( harvestOrder, '_SECTORCODE' ) != Nil )
			(cCLTTEMP)->CODSET    := harvestOrder:_SectorCode:Text
		EndIf

		//Descrição do [Setor]
		If ( XmlChildEx( harvestOrder, '_SECTORDESCRIPTION' ) != Nil )
			(cCLTTEMP)->DESSET    := harvestOrder:_SectorDescription:Text
		EndIf

		//Código do [Talhão]
		If ( XmlChildEx( harvestOrder, '_PARTOFLANDCODE' ) != Nil )
			(cCLTTEMP)->CODTAL    := harvestOrder:_PartOfLandCode:Text
		EndIf

		//Descrição do Talhão
		If ( XmlChildEx( harvestOrder, '_PARTOFLANDDESCRIPTION' ) != Nil )
			(cCLTTEMP)->DESTAL    := harvestOrder:_PartOfLandDescription:Text
		EndIf

		//Código da Ocupação do [Talhão]
		If ( XmlChildEx( harvestOrder, '_OCCUPATIONCODE' ) != Nil )
			(cCLTTEMP)->CODOCP    := harvestOrder:_OccupationCode:Text
		EndIf

		//Descrição da Ocupação
		If ( XmlChildEx( harvestOrder, '_OCCUPATIONDESCRIPTION' ) != Nil )
			(cCLTTEMP)->DESOCP    := harvestOrder:_OccupationDescription:Text
		EndIf

		//Área do [Talhão] a ser colhida
		If ( XmlChildEx( harvestOrder, '_HARVESTEDAREA' ) != Nil )
			(cCLTTEMP)->ARETAL    := Val(harvestOrder:_HarvestedArea:Text)
		EndIf
		
		//Estimativa (kg) de colheita para o [Talhão]
		If ( XmlChildEx( harvestOrder, '_HARVESTESTIMATE' ) != Nil )
			(cCLTTEMP)->PESEST    := Val(harvestOrder:_HarvestEstimate:Text)
		EndIf			
		
		//Código da ordem (OP ou OS) presente na ordem de colheita
		If ( XmlChildEx( harvestOrder, '_MAINORDERCODE' ) != Nil )
			(cCLTTEMP)->CODOPS    := harvestOrder:_MainOrderCode:Text
		EndIf					
		
		//InternalId da ordem (OP ou OS) presente na ordem de colheita
		If ( XmlChildEx( harvestOrder, '_MAINORDERINTERNALID' ) != Nil )
			(cCLTTEMP)->IDOPOS    := harvestOrder:_MainOrderInternalId:Text
		EndIf		

		(cCLTTEMP)->(MsUnlock())
	EndIf
Return cCLTTEMP


/*/{Protheus.doc} AGRA530XML
//Gera xml para a chamada de Consulta de Ordem de Colheita
@author carlos.augusto
@since 29/01/2018
@version undefined
@param cCodEmp, characters, codigo da empresa desejada. Se nao passada, sera a empresa logada
@param cCodFil, characters, codigo da filial desejada. Se nao passada, sera a filial logada
@param cFiltData, characters, filtro Data da Pesagem (Obrigatorio)
@param cFiltOrd, characters, numero da Ordem de Colheita (Opcional)
@param cFiltItem, characters, codigo do Produto (Opcional)
@type function
/*/
Function AGRA530XML(cCodEmp, cCodFil, cFiltData, cFiltOrd, cFiltItem)
	Local cXMLRet := ""
	Local cDataPes
	cXMLRet := '<BusinessEvent>'
	cXMLRet +=     '<Entity>GetHarvestOrder</Entity>'
	cXMLRet +=     '<Event>upsert</Event>'
	cXMLRet += '</BusinessEvent>'

	cXMLRet += '<BusinessContent>'
	
	If !Empty(cCodEmp)
		cXMLRet +=    '<CompanyId>' + cCodEmp + '</CompanyId>'  /* Obrigatorio */
	Else
		cXMLRet +=    '<CompanyId>' + FWGrpCompany() + '</CompanyId>'  /* Obrigatorio */
	EndIf
	If !Empty(cCodFil)
		cXMLRet +=    '<BranchId>'  + cCodFil + '</BranchId>'  /* Obrigatorio */
		cXMLRet +=    '<CompanyInternalId>' + cCodEmp + "|" + cCodFil + '</CompanyInternalId>'
	Else
		cXMLRet +=    '<BranchId>'  + FWCodFil() + '</BranchId>'  /* Obrigatorio */
		cXMLRet +=    '<CompanyInternalId>' + FWCodEmp() + "|" + FWCodFil() + '</CompanyInternalId>'
	EndIf
	  
	If !Empty(cFiltData)
		cDataPes := SubStr(DTOS(cFiltData), 1, 4) + '-' + SubStr(DTOS(cFiltData), 5, 2) + '-' + SubStr(DTOS(cFiltData), 7, 2)
		cXMLRet +=    '<WeighingDate>'  + cDataPes + '</WeighingDate>'   /* Obrigatorio  */
	EndIf
	If !Empty(cFiltOrd)
		cXMLRet +=    '<HarvestOrderCode>'  + AllTrim(cFiltOrd) + '</HarvestOrderCode>'
	EndIf		
	If !Empty(cFiltItem)
		cXMLRet +=    '<ItemCode>'  + AllTrim(cFiltItem) + '</ItemCode>'
	EndIf
	If !Empty(cFiltItem)
		cXMLRet +=    '<ItemInternalId>'  + FWxFilial("SB1") + "|" + cFiltItem +  '</ItemInternalId>'
	EndIf
	cXMLRet += '</BusinessContent>'
		
Return cXMLRet	

/*/{Protheus.doc} IntegDef
//Integracao de Ordem de Colheita
@author carlos.augusto
@since 09/02/2018
@version undefined
@param cXML, characters, descricao
@param nTypeTrans, numeric, descricao
@param cTypeMessage, characters, descricao
@type function
/*/
Static Function IntegDef( cXML, nTypeTrans, cTypeMessage )

	Local aRet := {}

	If FindFunction("AGRI530")// .And.   !(_cCLTTEMP)->(RecCount()) > 0
		//a funcao integdef original foi transferida para o fonte AGRI500, conforme novas regras de mensagem unica.
		aRet:= AGRI530( cXml, nTypeTrans, cTypeMessage )
	EndIf
Return aRet