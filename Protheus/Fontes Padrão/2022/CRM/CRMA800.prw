#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMDEF.CH"
#INCLUDE "CRMA800.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA800 

Rotina de Painel de Proposta  

Esta rotina tem o objetivo de possibilitar a visualização de todas as 
propostas comerciais do CRM e a realização de ações que não alterem 
seu conteúdo, como por exemplo, upload, download, pesquisa, entre 
outros.

Quando acessada pelo CRM a rotina é exibida com filtros de usuário
baseados na estrutura de negócios.	

@author Thamara Villa Jacomo
@since 05/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Function CRMA800( aAddFil, cVisDef, cFilDef )

Local aArea 	  	:= GetArea()

Private aRotina	:= MenuDef()

Default aAddFil 	:= {}
Default cVisDef	:= ""
Default cFilDef	:= ""

//-------------------------------
// Browse Painel de Proposta.  
//-------------------------------
BrowseDef( /*oMBrowse*/ , aAddFil, cVisDef , cFilDef )
	
RestArea( aArea )
	
Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} BrowseDef

Browse de Painel de Proposta

@sample	BrowseDef(  oMBrowse, aAddFil, cVisDef , cFilDef ) 

@param		oMBrowse	, Objeto	, Browse criado pelo Widget da Area de Trabalho.
			aAddFil	, Array		, Filtros relacionados.
			cVisDef	, Caracter , Visao padrao.
			cFilDef	, Caracter	, Filtro padrao.
		
@return	oMBrowse	, Objeto	, Retorna o objeto FWMBrowse.

@author	Anderson Silva
@since		05/12/2015
@version	P12
/*/
//------------------------------------------------------------------------------
Static Function BrowseDef( oMBrowse, aAddFil, cVisDef , cFilDef )

Local oTableAtt		:= Nil
Local nX		 	:= 0
Local lWidget		:= .F.
Local aColumn		:= {}
Local aCRM800CL		:= {}
Local aCores		:= FT600Legenda()

Default oMBrowse	:= Nil
Default aAddFil		:= {}
Default cVisDef		:= ""
Default cFilDef		:= ""

If Empty( oMBrowse )
	oMBrowse := FWMBrowse():New()
	oMBrowse:SetAlias( "ADY" )
Else
	lWidget := .T.
EndIf

oMBrowse:SetCanSaveArea(.T.) 

For nX := 1 to Len(aCores)
	oMBrowse:AddLegend( aCores[nX][1], aCores[nX][2], aCores[nX][3]) 
Next nX

//------------------------------------------
// Ponto de entrada que adiciona coluna ao Browse
//------------------------------------------
If ExistBlock("CRM800CL")
	aCRM800CL := ExecBlock("CRM800CL",.F.,.F.)
	If ValType(aCRM800CL) == "A"
		aColumn := aCRM800CL
	EndIf
Endif 	

For nX := 1 to len(aColumn)
	oMBrowse:AddColumn(aColumn[nX])
Next nX

//------------------------------------------
// Filtros adicionais do Browse
//------------------------------------------
If !Empty ( cFilDef ) 
	oMBrowse:SetFilterDefault( cFilDef ) 
EndIf
	
For nX := 1 To Len( aAddFil )
	oMBrowse:DeleteFilter( aAddFil[ nX ][ ADDFIL_ID ] )
	oMBrowse:AddFilter( aAddFil[ nX ][ ADDFIL_TITULO ]	, ;
		aAddFil[ nX ][ ADDFIL_EXPR ]		, ;
		aAddFil[ nX ][ ADDFIL_NOCHECK ]	, ;
		aAddFil[ nX ][ ADDFIL_SELECTED ]	, ;
		aAddFil[ nX ][ ADDFIL_ALIAS ]		, ;
		aAddFil[ nX ][ ADDFIL_FILASK ]	, ;
		aAddFil[ nX ][ ADDFIL_FILPARSER ], ;
		aAddFil[ nX ][ ADDFIL_ID ] )
	oMBrowse:ExecuteFilter()
Next nX

oMBrowse:SetDescription( STR0001 )
oMBrowse:DisableDetails()
oMBrowse:SetMainProc("CRMA800")


If !lWidget 	
	//-----------------------------------------------
	// Libera a funcionalidade de Visões e Gráficos
	//----------------------------------------------
	oTableAtt := TableAttDef()
	oMBrowse:SetAttach( .T. )
	oMBrowse:SetViewsDefault( oTableAtt:aViews )
	oMBrowse:SetChartsDefault( oTableAtt:aCharts )
	//-----------------------------------------------
	// Selecionando a visão inicial
	//-----------------------------------------------
	If !Empty( cVisDef )
		nScan := aScan( oTableAtt:aViews, { |x| x:cID == cVisDef } )
		If nScan > 0
			oMBrowse:SetIDViewDefault( oTableAtt:aViews[nScan]:cID )
		EndIf
	EndIf
	
	oMBrowse:SetIdChartDefaul("DSStatus")
	oMBrowse:SetOpenChart( .F. )
	oMBrowse:Activate()
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

Define as operações realizadas pela aplicação.	

@author Thamara Villa Jacomo
@since 05/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina		:= {}
Local lCrm800Mnu	:= ExistBlock("CRM800MNU")

ADD OPTION aRotina TITLE STR0013 ACTION 'VIEWDEF.FATA600'		OPERATION 2 ACCESS 0 	// "Visualizar"
ADD OPTION aRotina TITLE STR0014 ACTION "CRMA800A"    			OPERATION 6 ACCESS 0 	// "Outras Ações"
ADD OPTION aRotina TITLE STR0049 ACTION "A800ReOpen"  			OPERATION 6 ACCESS 0 	// "Reprovar"
ADD OPTION aRotina TITLE STR0031 ACTION "CRMA090( ,'ADY' )"  	OPERATION 6 ACCESS 0    // "Upload/Download"
ADD OPTION aRotina TITLE STR0035 ACTION "CRMA180()"   			OPERATION 8 ACCESS 0    //" Atividades"

If lCrm800Mnu
	uRotina := ExecBlock("CRM800MNU",.F.,.F.,{aRotina})
	If ValType(uRotina) == "A"
		aRotina := aClone(uRotina)
	EndIf
EndIf

Return aRotina 

//-------------------------------------------------------------------
/*/{Protheus.doc} TableAttDef

Cria Visões e Gráficos	

@author Thamara Villa Jacomo
@since 05/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function TableAttDef()

Local oTableAtt := Nil
Local oDSStatus := Nil

Local lCRM800View	 := ExistBlock("CRMBRWVIEW")	//Ponto entrada para manipulação das views padrão
Local cRotina		 := "CRMA800"
Local cAliasView	 := "ADY"

If lCRM800View 
	oTableAtt := ExecBlock("CRMBRWVIEW", .F.,.F.,{cRotina,cAliasView})
EndIf

If Empty (oTableAtt) 
	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias( "ADY" )
EndIf

//--------------------------------------------
// Gráfico de Pizza de Propostas por status
//--------------------------------------------
oDSStatus := FWDSChart():New()
oDSStatus:SetName(STR0016)
oDSStatus:SetID("DSStatus")
oDSStatus:SetTitle(STR0016)
oDSStatus:SetType("PIECHART")
oDSStatus:SetSeries({{"ADY","ADY_PROPOS","COUNT"}})
oDSStatus:SetCategory({{"ADY","ADY_STATUS"}})
oDSStatus:SetPublic(.T.)
oDSStatus:SetLegend(CONTROL_ALIGN_BOTTOM) //Inferior
oTableAtt:AddChart(oDSStatus)	

Return oTableAtt

//-------------------------------------------------------------------
/*/{Protheus.doc} A800ReOpen

Reprovar da Oportunidade de Venda / Proposta Comercial.

@author Thamara Villa Jacomo
@since 08/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Function A800ReOpen()

Local aArea 	 	:= GetArea()
Local oDlg		 	:= Nil
Local oPanel	 	:= Nil
Local oFWLayer 	:= Nil
Local oColUp	 	:= Nil
Local oColDown 	:= Nil
Local oLayUp 	 	:= Nil
Local oLayDown 	:= Nil
Local oDlgUp	 	:= Nil
Local oMemo	 	:= Nil
Local oGet		 	:= Nil
Local cGet		 	:= Space(06)
Local cMemo		:= ""
Local lGrPedVend	:= SuperGetMv("MV_OPORXPV",,.T.)
Local lRet 		:= .T.
Local cAliasTmp	:= GetNextAlias()
Local aOrcamento	:= {}
Local aPedido		:= {}
Local nPos			:= 0
Local aMaster		:= {}
Local aDetail		:= {}
Local nTotal 		:= 0
Local nX			:= 0
Local cFilialSCK	:= xFilial("SCK")

Private lMsErroAuto := .F.

If ADY->ADY_STATUS $ "B|F|C|J"

	If lGrPedVend
			
		BeginSql Alias cAliasTmp
			SELECT
				CK_NUM, C5_NUM, C5_NOTA, C5_SERIE, C6_QTDEMP
			FROM
				%Table:ADZ% ADZ
				INNER JOIN %Table:SCK% SCK ON ADZ.ADZ_ORCAME = SCK.CK_NUM
				INNER JOIN %Table:SC5% SC5 ON SCK.CK_NUMPV = SC5.C5_NUM
				INNER JOIN %Table:SC6% SC6 ON SC6.C6_NUM = SC5.C5_NUM
			WHERE
				ADZ.ADZ_FILIAL = %xFilial:ADZ% AND SCK.CK_FILIAL = %xFilial:SCK% AND
				SC5.C5_FILIAL = %xFilial:SC5% AND SC6.C6_FILIAL = %xFilial:SC6% AND
				SCK.CK_PROPOST = %Exp:ADY->ADY_PROPOS% AND ADZ.%NotDel% AND SCK.%NotDel% AND  
				SC5.%NotDel% AND SC6.%NotDel%
		EndSql
		
		While (cAliasTmp)->(!Eof())
			If ( ( (cAliasTmp)->C5_NOTA <> ' ' .And. (cAliasTmp)->C5_SERIE <> ' ') .Or. (cAliasTmp)->C6_QTDEMP > 0 )
				MsgAlert(STR0050+Chr(10)+ STR0051) // "Esta proposta comercial possuem pedidos de venda com itens liberados ou faturados." 
				lRet := .F.
				Exit
			Else
				nPos := aScan(aOrcamento,{|x| x == (cAliasTmp)->CK_NUM })
				If nPos == 0
					aAdd(aOrcamento,(cAliasTmp)->CK_NUM)
				EndIf
				
				nPos := aScan(aPedido,{|x| x == (cAliasTmp)->C5_NUM })
				If nPos == 0
					aAdd(aPedido,(cAliasTmp)->C5_NUM)
				EndIf
			EndIf
			(cAliasTmp)->(DBSkip())
		End
		
		(cAliasTmp)->(DBCloseArea())
		
	EndIf
	
	If lRet 
	
		oDlg := FWDialogModal():New()
		oDlg:SetBackground(.T.)
		oDlg:SetEscClose(.T.)
		oDlg:SetSize(200,200) //cria a tela maximizada (chamar sempre antes do CreateDialog)
		oDlg:EnableFormBar(.T.)
		oDlg:CreateDialog()
		oDlg:AddYesNoButton()
		oPanel := oDlg:GetPanelMain()
		
		//-------------------------------------------------
		// Cria o painel superior do motivo
		//-------------------------------------------------
		oFWLayer := FWLayer():New()
		oFWLayer:Init(oPanel,.F.)
		oFWLayer:AddLine("UP_BOX",30,.T.)
		oFWLayer:AddCollumn("COLLUP_BOX",100,.T.,"UP_BOX")
		oColUp := oFWLayer:GetColPanel("COLLUP_BOX","UP_BOX")
		
		oLayUp := FWLayer():New()
		oLayUp:Init(oColUp,.F.)
		oLayUp:AddCollumn("COLL1",100,.T.,"LINE1")
		oLayUp:AddWindow("COLL1","WIN1",STR0017,100,.F.,.F.,,"LINE1")
		oDlgUp := oLayUp:GetWinPanel("COLL1","WIN1","LINE1")
		
		//-------------------------------------------------
		// Cria o painel inferior da observação
		//-------------------------------------------------
		oFWLayer:AddLine("DOWN_BOX",70,.T.)
		oFWLayer:AddCollumn("COLLDOWN_BOX",100,.T.,"DOWN_BOX")
		oColDown := oFWLayer:GetColPanel("COLLDOWN_BOX","DOWN_BOX")
		
		oLayDown := FWLayer():New()
		oLayDown:Init(oColDown,.F.)
		oLayDown:AddCollumn("COLL2",100,.T.,"LINE2")
		oLayDown:AddWindow("COLL2","WIN2",STR0018,100,.F.,.F.,,"LINE2")
		oDlgDown := oLayDown:GetWinPanel("COLL2","WIN2","LINE2")
		
		//-------------------------------------------------
		// Adiciona campo de seleção de motivo
		//-------------------------------------------------
		@ 10, 05 MSGET oGet  VAR cGet OF oDlgUp  SIZE 45,5 F3 "RZ" PIXEL VALID A800Gat(cGet) WHEN .T.
		@ 10, 60 MSGET  Alltrim(Posicione("SX5",1,FwxFilial("SX5")+"RZ"+ cGet,"X5_DESCRI"))  VALID {|| ,oDlgUp:Refresh()} OF oDlgUp SIZE 115,5   PIXEL WHEN .F.
		
		@ 000,000 GET oMemo VAR cMemo  OF oDlgDown MEMO SIZE 0,0 PIXEL WHEN .T.
		oMemo:Align := CONTROL_ALIGN_ALLCLIENT
		
		oDlg:Activate()
		
		If !Empty( cGet ) .And. !Empty( cMemo )
			lRet := oDlg:GetButtonSelected() <> 0
		Else
			lRet := .F.
			If oDlg:GetButtonSelected() <> 0
				MsgAlert(STR0057) //"Informe um motivo / descrição para reprovação."
			EndIf
		EndIf
		
		If lRet
		
			If !Empty(Alltrim(Posicione("SA3",1,xFilial("SA3")+ ADY->ADY_VEND , "A3_EMAIL")))
				cDest := Posicione("SA3",1,xFilial("SA3")+ ADY->ADY_VEND , "A3_EMAIL")
			Else
				cDest := Posicione("AO3",2,xFilial("SA3")+ ADY->ADY_VEND , "AO3_EXGEMA")
			EndIf
			
			cCodUsr	:= RetCodUsr()
			cChave		:= ADY->ADY_OPORTU
						
			//C5_FILIAL+C5_NUM                                                                                                                                                
			SC5->(DBSetOrder(1))
			//CJ_FILIAL+CJ_NUM+CJ_CLIENTE+CJ_LOJA                                                                                                                             
			SCJ->(DBSetOrder(1))
			//CK_FILIAL+CK_NUM+CK_ITEM+CK_PRODUTO                                                                                                                             
			SCK->(DBSetOrder(1))
			
			//----------------------------------------------------------------
			// Reabre a oportunidade de vendas
			//----------------------------------------------------------------
			Begin Transaction
				
				If lGrPedVend
				
					nTotal := Len( aPedido )
					
					For nX := 1 To nTotal
						If SC5->( DBSeek(xFilial("SC5")+aPedido[nX]) )
							aAdd(aMaster,{"C5_FILIAL"	,SC5->C5_FILIAL	,Nil})
							aAdd(aMaster,{"C5_NUM"	 	,SC5->C5_NUM		,Nil})
							MSExecAuto( { |x, y, z| Mata410(x, y, z) }, aMaster, aDetail, 5 )
							//Trata erro na ExecAuto
							If ( lMsErroAuto )
								lRet := .F.
								MostraErro()
								Exit
							EndIf
							aMaster := {}
						EndIf
					Next nX
					
					If lRet
						nTotal 	:= Len( aOrcamento )
						aMaster	:= {}
						For nX 	:= 1 To nTotal
							If SCJ->( DBSeek(xFilial("SCJ")+aOrcamento[nX]) )
								RecLock("SCJ",.F.)
								SCJ->CJ_STATUS := "A"
								MsUnLock()
								If SCK->(DBSeek(xFilial("SCK")+aOrcamento[nX]))
									While SCK->(!Eof()) .And. SCK->CK_FILIAL = cFilialSCK .And. SCK->CK_NUM == aOrcamento[nX]
										RecLock("SCK",.F.)
										SCK->CK_NUMPV := " "
										MsUnLock() 
										SCK->(DBSkip())
									End
								EndIf
							EndIf
						Next nX
					EndIf
				
				EndIf
				
				If lRet
					
					AD1->( DbSetOrder( 1 ) )
					If AD1->( DbSeek( xFilial( "AD1" ) + ADY->ADY_OPORTU + ADY->ADY_REVISA ) )
						
						RecLock( "AD1", .F. )
						AD1->AD1_FCS	  := Space( TamSX3( "AD1_FCS" )[1] )
						AD1->AD1_STATUS := "1" //Aberto
						MsUnlock()
						
						AIJ->(DBSetOrder( 1 )) 
						If AIJ->( DbSeek( xFilial( "AIJ" ) + AD1->AD1_NROPOR + AD1->AD1_REVISA + AD1->AD1_PROVEN + AD1->AD1_STAGE ) )
							RecLock( "AIJ", .F. )
							AIJ->AIJ_DTENCE	:= cTod("//")
							AIJ->AIJ_HRENCE	:= " "
							AIJ->AIJ_STATUS	:= " " 
							MsUnlock()
						EndIf
						
						//----------------------------------------------------------------
						// Atualiza as informações da proposta comercial
						//----------------------------------------------------------------
						Reclock("ADY",.F.)
						ADY->ADY_STATUS 	:= "D"
						ADY->ADY_DTREPR	:= Date()
						ADY->ADY_HRREPR	:= Time()
						ADY->ADY_USREPR	:= RetCodUsr()
						ADY->ADY_MTREPR	:= cGet
						ADY->ADY_OBSREP	:= cMemo
						If lGrPedVend
							ADY->ADY_DTPDV	:= cTod("//") 
							ADY->ADY_HRPDV 	:= " "
							ADY->ADY_USRPDV	:= " "
						EndIf
						MSUnlock()
						
						
						aCampos:= {	{"AOF_FILIAL"	,xFilial("AOF")				,Nil},;
										{"AOF_DESTIN"	,cDest   						,Nil},;
										{"AOF_ENTIDA"	,"AD1"							,Nil},;
										{"AOF_CHAVE" 	,cChave		    			,Nil},;
										{"AOF_DESCRI" ,STR0053 + ADY->ADY_OPORTU	,Nil},;
										{"AOF_CODUSR"	,cCodUsr						,Nil},;
										{"AOF_CHVCAM"	," "							,Nil},;
										{"AOF_CODCAM"	," "							,Nil},;
										{"AOF_TIPCAM"	," "							,Nil},;
										{"AOF_STATUS" ,"6"     						,Nil},;										
										{"AOF_TIPO"  	,"3"    	 					,Nil},;
										{"AOF_ASSUNT"	,STR0052 + ADY->ADY_PROPOS	,Nil } } //"Reprovacao Proposta"
							
						
						MSExecAuto( { |x, y, z| CRMA180(x, y ) }, aCampos, 3 )
						
						//Trata erro na ExecAuto
						If ( lMsErroAuto )
							lRet := .F.
							MostraErro()
						EndIf
						
					EndIf
					
				EndIf
				
				If !lRet
					DisarmTransaction()
				EndIf
			
			End Transaction
			
		EndIf
	
	EndIf
Else
	MsgAlert(STR0054)	//"Não será possível reprovar esta proposta comercial."        
EndIf

Return lRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} A800Gat

Verifica informaçao inserida no campo Motivo 

@param  cGet = MOtivo Reprovaçao 

@author Thamara Villa Jacomo
@since 08/05/2015
@version 12
/*/
//-------------------------------------------------------------------
Static Function A800Gat(cGet)
 
Local lRet := .T.

Default cGet := ""

SX5->(DBSetOrder(1))

If !Empty(cGet) .And. !SX5->(DBSeek(xFilial("SX5")+"RZ"+ cGet))	
	MsgAlert(STR0028)
	lRet := .F.
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A800VisPro 

Executa a visualiação da proposta comercial posicionando no registro

@sample 	A800VisPro( cProp )

@param		cProp   -  Numero da proposta comercial 
    		
@return   	Nil
	

@author Thamara Villa Jacomo
@since 31/07/2015
@version 12
/*/
//-------------------------------------------------------------------
Function A800PropView( cProp )

Default cProp := ""

ADY->( DBSetOrder( 1 ) ) 

If !Empty( cProp ) .And. ADY->( DbSeek( xFilial( "ADY" ) + cProp ) )
	FWExecView(STR0056, "VIEWDEF.FATA600", 1 )	//"Visualizar"
Else
	Help( ,, "A800VisProp",,STR0055, 1, 0 ) //"Proposta não localizada"
EndIf 

Return( Nil )         

//-------------------------------------------------------------------
/*/{Protheus.doc} A800SetVirt(cCampo)

Função responsável pelos preenchimentos dos campos virtuais
ADY_VALOR, ADY_UNIDAD, ADY_DSCUND e ADY_SETPUB

@param  [cCampo] Parâmetro passado no Inicializador Padrão e Inicializador do Browse de cada campo
para a identificação dos mesmos

@Return uRet - Valor a ser atribuido a cada campo. Pode ser numérico ou caracter

@author Philip Pellegrini
@since 03/08/2015
@version 12
/*/
//-------------------------------------------------------------------
Function A800SetVirt(cCampo)
	
Local cCodUnid 	:= ""
Local aArea 		:= GetArea()
Local uRet			:= Nil

Do Case
	Case cCampo == "VALOR"
		uRet := Posicione("AD1",1,FwxFilial("AD1")+ADY->ADY_OPORTU+ ADY->ADY_REVISA,"AD1_VERBA")
	Case cCampo == "UNIDAD"
		uRet := Posicione("SA3",1,FwxFilial("SA3")+ADY->ADY_VEND,"A3_UNIDAD")
	Case cCampo == "DSCUND"
		cCodUnid	:= Posicione("SA3",1,FwxFilial("SA3")+ADY->ADY_VEND,"A3_UNIDAD")
		uRet 		:= Posicione("ADK",1,FwxFilial("ADK")+cCodUnid,"ADK_NOME")
	Case cCampo == "SETPUB"	
		If ADY->ADY_ENTIDA == '1' //Cliente
			uRet := Posicione("AI0",1,FwxFilial("AI0")+ADY->ADY_CODIGO+ADY->ADY_LOJA,"AI0_SETPUB")
		ElseIf ADY->ADY_ENTIDA == '2' //Prospect
			uRet := Posicione("SUS",1,FwxFilial("SUS")+ADY->ADY_CODIGO+ADY->ADY_LOJA,"US_SETPUBL")
		EndIf
EndCase

RestArea(aArea)

Return uRet