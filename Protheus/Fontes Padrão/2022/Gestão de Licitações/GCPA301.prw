#Include 'PROTHEUS.CH'
#Include 'FWMVCDEF.CH'
#Include 'GCPA301.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author jose.delmondes
@since 28/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruCPH	:= FWFormStruct(1, 'CPH')	// Cabeçalho da Ata
Local oStruCPN	:= FWFormStruct(1, 'CPN', {|cCampo| !AllTrim(cCampo) $ "CPN_NUMATA"} )	//Histórico da Ata
Local oStruCX6	:= FWFormStruct(1, 'CX6')	// Lote CX6
Local oStruCPY	:= FWFormStruct(1, 'CPY')	// Produtos Licitados
Local oStruCX3	:= FWFormStruct(1, 'CX3')	// Ata x Solicitação de Compra
Local oStruCPZ	:= FWFormStruct(1, 'CPZ')	// Licitantes
Local oStruCPI	:= FWFormStruct(1, 'CPI')	// Orgão da Ata

Local oModel		:= Nil
               
oStruCPI:AddField( ;                                                  
                        AllTrim('') , ; 			// [01] C Titulo do campo
                        AllTrim('') , ; 			// [02] C ToolTip do campo
                        'CPI_LEGEND' , ;            // [03] C identificador (ID) do Field
                        'C' , ;                     // [04] C Tipo do campo
                        50 , ;                      // [05] N Tamanho do campo
                        0 , ;                       // [06] N Decimal do campo
                        NIL , ;                     // [07] B Code-block de validação do campo
                        NIL , ;                     // [08] B Code-block de validação When do campo
                        NIL , ;                     // [09] A Lista de valores permitido do campo
                        NIL , ;                     // [10] L Indica se o campo tem preenchimento obrigatório
                        { || A300CPILeg() } , ;  	// [11] B Code-block de inicializacao do campo
                        NIL , ;                     // [12] L Indica se trata de um campo chave
                        NIL , ;                     // [13] L Indica se o campo pode receber valor em uma operação de update.
                        .T. )                       // [14] L Indica se o campo é virtual

oStruCPH:AddField( ;                                                   
	                        STR0017 , ; 											// [01] C Titulo do campo
	                        AllTrim('') , ; 										// [02] C ToolTip do campo
	                        'CPH_AUTO' , ;              							// [03] C identificador (ID) do Field
	                        'C' , ;                     							// [04] C Tipo do campo
	                        1 , ;                      								// [05] N Tamanho do campo
	                        NIL , ;													// [06] N Decimal do campo
	                        NIL , ;                     							// [07] B Code-block de validação do campo
	                        NIL , ;                     							// [08] B Code-block de validação When do campo
	                        NIL , ;                     							// [09] A Lista de valores permitido do campo
	                        NIL , ;                     							// [10] L Indica se o campo tem preenchimento obrigatório
	                        FwBuildFeature( STRUCT_FEATURE_INIPAD, "'0'" ) ,;		// [11] B Code-block de inicializacao do campo
	                        NIL , ;                     							// [12] L Indica se trata de um campo chave
	                        NIL , ;                     							// [13] L Indica se o campo pode receber valor em uma operação de update.
                        		.T. )                       						// [14] L Indica se o campo é virtual                 
                    

oModel	:= MPFormModel():New('GCPA301',/*bPreValidacao*/, /*bPosValidacao*/{|oModel|GCP300PVLD(oModel)},{|oModel|GCP300Grv(oModel)}/*bCommit*/, /*bCancel*/ )

oModel:AddFields('CPHMASTER'  ,  /*cOwner*/  ,oStruCPH, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:AddGrid( 'CPNDETAIL' , 'CPHMASTER' , oStruCPN , /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CX6DETAIL' , 'CPHMASTER' , oStruCX6 , /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CPYDETAIL' , 'CX6DETAIL' , oStruCPY , {|oModelGrid, nLine, cAction, cField|GCP300LCpi(oModelGrid, nLine, cAction, cField)} ,  /*bPosValidacao*/ , /*bCarga*/ )
oModel:AddGrid( 'CX3DETAIL' , 'CPYDETAIL' , oStruCX3 , /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CPZDETAIL' , 'CX6DETAIL' , oStruCPZ , /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'CPIDETAIL' , 'CPYDETAIL' , oStruCPI , {|oModelGrid, nLine, cAction, cField|A300PreCPIN(oModelGrid, nLine, cAction, cField)} /*bPreValidacao*/, { |oModel| A300CPIN(oModel) } , /*bCarga*/ )

//Relacionamentos
oModel:SetRelation( 'CPNDETAIL' , { { 'CPN_FILIAL' , 'xFilial("CPN")' } , { 'CPN_NUMATA' , 'CPH_NUMATA' } } , CPN->( IndexKey(1) ) )
oModel:SetRelation( 'CX6DETAIL' , { { 'CX6_FILIAL' , 'xFilial("CX6")' } , { 'CX6_NUMATA' , 'CPH_NUMATA' } } , CX6->( IndexKey(1) ) )
oModel:SetRelation( 'CPYDETAIL' , { { 'CPY_FILIAL' , 'xFilial("CPY")' } , { 'CPY_NUMATA' , 'CPH_NUMATA' } , { 'CPY_LOTE' , 'CX6_LOTE' } } 	  , CX6->( IndexKey(2) ) )
oModel:SetRelation( 'CX3DETAIL' , { { 'CX3_FILIAL' , 'xFilial("CX3")' } , { 'CX3_NUMATA' , 'CPH_NUMATA' } , { 'CX3_LOTE' , 'CX6_LOTE' } , { 'CX3_CODPRO' , 'CPY_CODPRO' } } , CX3->( IndexKey(2) ) )
oModel:SetRelation( 'CPZDETAIL' , { { 'CPZ_FILIAL' , 'xFilial("CPZ")' } , { 'CPZ_NUMATA' , 'CPH_NUMATA' } , { 'CPZ_LOTE' , 'CX6_LOTE' } } , CPZ->( IndexKey(2) ) )
oModel:SetRelation( 'CPIDETAIL' , { { 'CPI_FILIAL' , 'xFilial("CPI")' } , { 'CPI_CODEDT' , 'CPH_CODEDT' } , { 'CPI_NUMPRO' , 'CPH_NUMPRO' } , { 'CPI_NUMATA' , 'CPH_NUMATA' } , { 'CPI_CODPRO' , 'CPY_CODPRO' } , { 'CPI_LOTE' , 'CX6_LOTE' } } , CPI->( IndexKey(1) ) )
CPEConfMdl(oModel) //Configura CPEDETAIL(Controle de Saldos) em <oModel>, precisa ser chamado após a configuração do submodelo CPIDETAIL

//Filtro para verificar somente produtos válidos
oModel:GetModel('CPYDETAIL'):SetLoadFilter({{'CPY_STATUS',"'1'",MVC_LOADFILTER_EQUAL}})

//Submodelo não será gravado se estiver sendo gerado a partir do processo licitatório
oModel:GetModel('CPIDETAIL'):SetOnlyQuery(IsInCallStack('GCP200SRP'))

//Modelos não obrigatórios
oModel:GetModel( 'CPZDETAIL' ):SetOptional(.T.) 
oModel:GetModel( 'CPNDETAIL' ):SetOptional(.T.)
oModel:GetModel( 'CX3DETAIL' ):SetOptional(.T.)

oModel:GetModel('CPIDETAIL'):SetUniqueLine( { 'CPI_CODORG' } )
oModel:GetModel('CPYDETAIL'):SetUniqueLine( { 'CPY_CODPRO' } )
oModel:GetModel('CPZDETAIL'):SetUniqueLine( { 'CPZ_TIPO', 'CPZ_CODIGO', 'CPZ_LOJA' } )
oModel:GetModel('CPIDETAIL'):SetUniqueLine( { 'CPI_CODORG' } )

//Descrições
oModel:SetDescription( STR0001 )							// Manutenção da Ata
oModel:GetModel( 'CX6DETAIL' ):SetDescription( STR0003 )	// Lotes
oModel:GetModel( 'CPYDETAIL' ):SetDescription( STR0004 )	// Produtos
oModel:GetModel( 'CPZDETAIL' ):SetDescription( STR0005 )	// Licitantes
oModel:GetModel( 'CX3DETAIL' ):SetDescription( STR0018 )	// Solicitações
oModel:GetModel( 'CPIDETAIL' ):SetDescription( STR0019 )	// Orgãos

oModel:SetVldActive({|oModel| GCP300VldA()})
oModel:SetActivate({|oModel| GCP300Ini(@oModel)})

Gcp017BMod(oModel, {'CPNDETAIL','CX3DETAIL'}, .T.)

If IsInCallStack('GCP300Manu')
	Gcp017BMod(oModel, {'CX6DETAIL','CPYDETAIL','CPZDETAIL','CX3DETAIL'},.T.)
EndIf

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definição do interface

@author jose.delmondes	
@since 28/06/2017
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function ViewDef()
Local oView
Local oModel 		:= FWLoadModel( 'GCPA301' )
Local oStruCPH	:= FWFormStruct( 2 , 'CPH' , {|cCampo| !AllTrim(cCampo) $ "CPH_AVAL, CPH_CODIGO, CPH_LOJA"} )																																// Cabeçalho da Ata
Local oStruCPN	:= FWFormStruct( 2 , 'CPN' , {|cCampo| !AllTrim(cCampo) $ "CPN_NUMATA"} )																																					// Histórico da Ata
Local oStruCX6	:= FwFormStruct( 2 , 'CX6' , {|cCampo| !AllTrim(cCampo) $ "CX6_NUMATA"} )																																					// Lote
Local oStruCPY	:= FWFormStruct( 2 , 'CPY' , {|cCampo| !( AllTrim(cCampo) $ "CPY_NUMATA, CPY_STATUS, CPY_REMAN, CPY_CODNE, CPY_LOTE" .Or. AllTrim(cCampo) == "CPY_ITEMNE" ) } )												// Produtos Licitados
Local oStruCX3 	:= FWFormStruct( 2 , 'CX3' , {|cCampo| !AllTrim(cCampo) $ "CX3_NUMATA, CX3_CODPRO, CX3_LOTE"} )																																// Ata x Solicitação de Compra
Local oStruCPZ	:= FWFormStruct( 2 , 'CPZ' , {|cCampo| !AllTrim(cCampo) $ "CPZ_NUMATA, CPZ_CODPRO, CPZ_ITEM, CPZ_DESCON, CPZ_VLUNIT, CPZ_PERCRJ, CPZ_VALATU, CPZ_VLRPRE, CPZ_VALRRJ, CPZ_VALREF, CPZ_LOTE"} )								// Licitantes
Local oStruCPI	:= FWFormStruct( 2 , 'CPI' , {|cCampo| !AllTrim(cCampo) $ "CPI_CODEDT,CPI_NUMPRO,CPI_CODNAT,CPI_DESNAT,CPI_CODPRO,CPI_LOTE,CPI_NUMATA"} )																					// Orgão da Ata
Local oStruCPE	:= FWFormStruct( 2 , 'CPE' , {|cCampo| !(AllTrim(cCampo) $ "CPE_CODORG, CPE_DESORG, CPE_TIPO, CPE_CODEDT, CPE_NUMPRO, CPE_NUMATA, CPE_LOTE, CPE_CODPRO, CPE_OK, CPE_CODNE" .Or. AllTrim(cCampo) == "CPE_ITEMNE" ) } )		// Controle de Saldos

oStruCPI:AddField( ;                                                            // Ord. Tipo Desc.
                                               'CPI_LEGEND' , ;                 // [01] C Nome do Campo
                                               '00' , ;                         // [02] C Ordem
                                               AllTrim('') , ;				   	// [03] C Titulo do campo
                                               STR0021	, ;   					// [04] C Descrição do campo
                                               { STR0021 } , ;          		// [05] A Array com Help
                                               'C' , ;                          // [06] C Tipo do campo
                                               '@BMP' , ;                       // [07] C Picture
                                               NIL , ;                          // [08] B Bloco de Picture Var
                                               '' , ;                           // [09] C Consulta F3
                                               .F. , ;                          // [10] L Indica se o campo é evitável
                                               NIL , ;                          // [11] C Pasta do campo
                                               NIL , ;                          // [12] C Agrupamento do campo
                                               NIL , ;                          // [13] A Lista de valores permitido do campo (Combo)
                                               NIL , ;                          // [14] N Tamanho Maximo da maior opção do combo
                                               NIL , ;                          // [15] C Inicializador de Browse
                                               .T. , ;                          // [16] L Indica se o campo é virtual
                                               NIL )                            // [17] C Picture Variável                                             

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField( 'CPHMASTER' , oStruCPH ) 

oView:AddGrid( 'VIEW_CX6' , oStruCX6 , 'CX6DETAIL' )
oView:AddGrid( 'VIEW_CPY' , oStruCPY , 'CPYDETAIL' )
oView:AddGrid( 'VIEW_CPZ' , oStruCPZ , 'CPZDETAIL' )
oView:AddGrid( 'VIEW_CPI' , oStruCPI , 'CPIDETAIL' )
oView:AddGrid( 'VIEW_CPN' , oStruCPN , 'CPNDETAIL' ) 
oView:AddGrid( 'VIEW_CX3' , oStruCX3 , 'CX3DETAIL' ) 

oView:CreateHorizontalBox( 'TOPO' , 26 )
oView:CreateHorizontalBox( 'MEIO' , 34 )
oView:CreateHorizontalBox( 'INFERIOR' , 40 )

//Folder do Topo
oView:CreateFolder( 'FLDTOPO' , 'CPHMASTER' )
oView:AddSheet( 'FLDTOPO' , 'FLDHIST' , STR0022 ) //'Histórico da Ata'
oView:CreateHorizontalBox( 'HIST' , 100 , /*owner*/ , /*lUsePixel*/ , 'FLDTOPO' , 'FLDHIST' )	//'Participantes'
oView:SetOwnerView( 'VIEW_CPN' , 'HIST' )

//Folder do Meio
oView:CreateVerticalBox( 'MEIOVERT' , 100 , 'MEIO' )
oView:CreateFolder( 'FLMEIO' , 'MEIOVERT' )
oView:AddSheet( 'FLMEIO' , 'FLLOTES' , STR0003 )	//Lotes
oView:CreateVerticalBox( 'LOTES' , 100 , , , 'FLMEIO' , 'FLLOTES' )
oView:AddSheet( 'FLMEIO' , 'FLPRODUTOS' , STR0004 )	//'Produtos'
oView:CreateVerticalBox( 'PRODUTOS' , 100 , , , 'FLMEIO' , 'FLPRODUTOS' )
oView:AddSheet( 'FLMEIO' , 'FLSOLICITA' , STR0018 )	//'Solicitações'
oView:CreateVerticalBox( 'SOLICITA' , 100 , , , 'FLMEIO' , 'FLSOLICITA' )

//Folder de Baixo
oView:CreateVerticalBox( 'INFERIORVERT' , 100, 'INFERIOR' )
oView:CreateFolder( 'FLINFERIOR' , 'INFERIORVERT' )
oView:AddSheet( 'FLINFERIOR' , 'FLLICITANTES' , STR0005 )	//'Licitantes'
oView:CreateVerticalBox( 'LICITA' , 100 , , , 'FLINFERIOR' , 'FLLICITANTES' )
oView:AddSheet( 'FLINFERIOR' , 'FLPARTICIPA' , STR0006 )
oView:AddGrid( 'VIEW_CPE' , oStruCPE , 'CPEDETAIL' )
oView:CreateHorizontalBox( 'BPART' , 100 , /*owner*/, /*lPixel*/, 'FLINFERIOR' , 'FLPARTICIPA' )
oView:CreateFolder( 'FLPART' , 'BPART' )
oView:AddSheet('FLPART' , 'FLORGP' , STR0019 )
oView:CreateHorizontalBox( 'PARTI' , 100 , /*owner*/, /*lUsePixel*/, 'FLPART' , 'FLORGP' )
oView:AddSheet('FLPART' , 'FLSLDP' , STR0020 )
oView:CreateHorizontalBox( 'SLDP' , 100 , /*owner*/, /*lUsePixel*/, 'FLPART' , 'FLSLDP' )

//Propritários
oView:SetOwnerView( 'CPHMASTER' 	, 'TOPO' 		)
oView:SetOwnerView( 'VIEW_CX6' 		, 'LOTES' 		)
oView:SetOwnerView( 'VIEW_CPY' 		, 'PRODUTOS'	)
oView:SetOwnerView( 'VIEW_CPZ' 		, 'LICITA'		)
oView:SetOwnerView( 'VIEW_CPI'		, 'PARTI'		)
oView:SetOwnerView( 'VIEW_CPE'		, 'SLDP'		)
oView:SetOwnerView( 'VIEW_CX3'		, 'SOLICITA'	)

//Títulos
oView:EnableTitleView( 'VIEW_CX6' )
oView:EnableTitleView( 'VIEW_CPY' )
oView:EnableTitleView( 'VIEW_CPZ' )
oView:EnableTitleView( 'VIEW_CPI' )
oView:EnableTitleView( 'VIEW_CPE' )
oView:EnableTitleView( 'VIEW_CX3' )

oView:AddIncrementField('VIEW_CPE' , 'CPE_ITEM' )
oView:AddIncrementField('VIEW_CPZ' , 'CPZ_ITEM' )
oView:AddIncrementField('VIEW_CPY' , 'CPY_ITEM' )

//Remove campos do processo de repactuação de preços
If !GetRepact()
	oStruCPY:RemoveField('CPY_PERCRJ')
	oStruCPY:RemoveField('CPY_VALRRJ')
EndIf

// Desabilita campos
If !IsInCallStack("GCP300Incl") .And. !IsInCallStack("GCPA300Prz") 
	oStruCPH:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
	If FunName() == 'GCPA200'
		oStruCPH:SetProperty('CPH_NUMATA', MVC_VIEW_CANCHANGE, .T.) 
	EndIf
Else
	oStruCPH:SetProperty('CPH_STATUS', MVC_VIEW_CANCHANGE, .F.) 
	oStruCPH:SetProperty('CPH_DTPB1', MVC_VIEW_CANCHANGE, .T.)
	oStruCPH:SetProperty('CPH_CANAL1', MVC_VIEW_CANCHANGE, .T.)
EndIf

oStruCPI:SetProperty('CPI_QTDRES', MVC_VIEW_CANCHANGE, .F.)	
oStruCPI:SetProperty('CPI_QTDCON', MVC_VIEW_CANCHANGE, .F.)	

If !IsInCallStack("GCPA300Prz")
	oStruCPI:SetProperty('CPI_SALDO', MVC_VIEW_CANCHANGE, .F.)		
EndIf	

If CO1->CO1_LEI == "5"
	oStruCPE:SetProperty('CPE_TIPDOC', MVC_VIEW_CANCHANGE, .F.)
EndIf

// Agrupadores
oStruCPH:AddGroup( "GRP1" , STR0023 , "" , 1 )//'1º Publicação'
oStruCPH:AddGroup( "GRP2" , STR0024 , "" , 1 )//'2º Publicação'
oStruCPH:AddGroup( "GRP3" , STR0025 , "" , 1 )//'3º Publicação'
oStruCPH:AddGroup( "GRP4" , STR0026 , "" , 1 )//'4º Publicação'

oStruCPH:SetProperty( "CPH_DTPB1"  , MVC_VIEW_GROUP_NUMBER, "GRP1" )
oStruCPH:SetProperty( "CPH_CANAL1" , MVC_VIEW_GROUP_NUMBER, "GRP1" )
oStruCPH:SetProperty( "CPH_DTPB2"  , MVC_VIEW_GROUP_NUMBER, "GRP2" )
oStruCPH:SetProperty( "CPH_CANAL2" , MVC_VIEW_GROUP_NUMBER, "GRP2" )
oStruCPH:SetProperty( "CPH_DTPB3"  , MVC_VIEW_GROUP_NUMBER, "GRP3" )
oStruCPH:SetProperty( "CPH_CANAL3" , MVC_VIEW_GROUP_NUMBER, "GRP3" )
oStruCPH:SetProperty( "CPH_DTPB4"  , MVC_VIEW_GROUP_NUMBER, "GRP4" )
oStruCPH:SetProperty( "CPH_CANAL4" , MVC_VIEW_GROUP_NUMBER, "GRP4" )

oView:SetAfterViewActivate({||GCPA300AtLg(oModel)} )

oView:AddUserButton( STR0027 , 'CLIPS' , {|oView|  A300Legend()} )			//"Legenda"

If IsInCallStack("GCP300Incl")
	oView:AddUserButton( STR0018 , 'CLIPS' , {|oView|  GCP300CaSC(oModel)} )	//'Solicitações'
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP301Lote()
Verifica se a Ata é por lote

@author jose.delmondes

@since 29/06/2017		
@version P12
@return lRet
/*/
//-------------------------------------------------------------------
Function GCP301Lote( cNumAta , lModel )
Local lRet	:= .F.

Local aArea		:= GetArea()
Local aAreaCX6	:= {}

Local oModel	:= Nil
Local oModelCX6	:= Nil

DEFAULT cNumAta	:= CPH->CPH_NUMATA
DEFAULT lModel	:= .F.


If AliasIndic('CX6')
	If lModel
		oModel := FWModelActive()
		oModelCX6 := oModel:GetModel("CX6DETAIL")
		
		If ValType(oModelCX6) == 'O'
			lRet := .T.
		EndIf
	Else
		dbSelectArea("CX6")
		aAreaCX6 := CX6->( GetArea() )
		dbSetOrder(1)
		
		If dbSeek( xFilial("CX6") + cNumAta )	
			lRet := .T.
		EndIf
		
		RestArea(aAreaCX6)
	EndIf
EndIf

RestArea(aArea)
Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GCP301GNLT()
Função para gerar nota de empenho de uma ata por lote

@author Filipe Gonçalves
@param 
@since 04/07/2017
@version 12
/*/
//-------------------------------------------------------------------
Function GCP301GNLT()
Local aArea		:= GetArea()
Local oModel 	:= FwModelActive()
Local aProd		:= {} //{CODPROD,QUANT}
Local aAta		:= {} //{CODEDT,NUMATA,NUMPRO,{aProd}}
Local aDadosAta	:= {}
Local aFornec	:= {}
Local cAliasSql	:= GetNextAlias()
Local cCodEdt	:= CPH->CPH_CODEDT
Local cNumPro	:= CPH->CPH_NUMPRO
Local cCodFil	:= CPH->CPH_FILIAL
Local cNumAta	:= CPH->CPH_NUMATA
Local cCodPro	:= ""
Local cFilEnt	:= ""
Local cNumSC 	:= ""
Local cItemSC	:= ""
Local cCodOrg	:= ""
Local cCodFor	:= ""
Local cLoja		:= ""
Local cLote		:= ""
Local cCodNe	:= ""
Local nPreco	:= 0	
Local nPos		:= 0
Local nQuant	:= 0
Local nGravou	:= 0
Local nX		:= 0

BeginSQL Alias cAliasSql
	SELECT DISTINCT CPZ.CPZ_NUMATA ,CPZ.CPZ_CODIGO, CPZ.CPZ_LOJA, CPZ.CPZ_LOTE
	FROM 
	%table:CPZ% CPZ
	INNER JOIN %table:CPH% CPH ON CPZ.CPZ_FILIAL = CPH.CPH_FILIAL AND CPZ.CPZ_NUMATA = CPH.CPH_NUMATA AND CPH.D_E_L_E_T_ = ''
	WHERE
	CPH.CPH_CODEDT = %exp:cCodEdt% AND 
	CPH.CPH_NUMPRO = %exp:cNumPro% AND
	CPZ.CPZ_NUMATA = %exp:cNumAta% AND 
	CPZ.CPZ_STATUS = '5' AND 
	CPZ.CPZ_LOTE <> '' AND
	CPZ.%NotDel%
EndSql
			
While (cAliasSql)->(!Eof())
	aAdd(aFornec, {(cAliasSql)->CPZ_NUMATA,(cAliasSql)->CPZ_CODIGO,(cAliasSql)->CPZ_LOJA, (cAliasSql)->CPZ_LOTE})
	(cAliasSql)->(dbSkip())
End
(cAliasSql)->(DbCloseArea())
		
For nX := 1 To Len(aFornec)
	aProd := {}
	aAta := {}
	aDadosAta := {}
	cCodFor	:= aFornec[nX][2]
	cLoja := aFornec[nX][3]
	cLote := aFornec[nX][4]

	//CPY_FILIAL+CPY_NUMATA+CPY_LOTE+CPY_CODPRO	
	CPY->(DbSetOrder(2))
	If CPY->(DbSeek(cCodFil+aFornec[nX][1]+cLote))
		While CPY->(!EOF()) .And. CPY->CPY_NUMATA == cNumAta .AND. CPY->CPY_LOTE == cLote	
			cCodPro := CPY->CPY_CODPRO
			nPreco := CPY->CPY_VLUNIT
			nQuant := 0	
			CX3->(DbSetOrder(2))//CX3_FILIAL+CX3_NUMATA+CX3_LOTE+CX3_CODPRO
			If CX3->(DbSeek(cCodFil+cNumAta+cLote+cCodPro))
				While CX3->(!EOF()) .AND. CX3->CX3_NUMATA == cNumAta .AND. CX3->CX3_LOTE == cLote .AND. CX3->CX3_CODPRO = cCodPro
					If !CX3->(CX3_EMPENH)
						cNumSC 	:= CX3->CX3_NUMSC
						cItemSC	:= CX3->CX3_ITEMSC
						nQuant 	:= CX3->CX3_QUANT 
						cFilEnt	:= CX3->CX3_FILENT
						nPos := aScan( aProd, {|x| AllTrim(x[1]) == AllTrim(cCodPro)} )
						If  nPos == 0 					
							Aadd(aProd, {cCodPro, nQuant,0,cFilEnt,cNumSC,cItemSC} )
						Else
							aProd[nPos][2] := aProd[nPos][2] + nQuant
						EndIf
					EndIf					
					CX3->(dbSkip())
				EndDo
			
				For nPos := 1 To Len(aProd)
					If aProd[nPos,1] == cCodPro
						aProd[nPos][3] := aProd[nPos][2] * nPreco
					EndIf
				Next nI
			EndIf
			CPY->(dbSkip())
		EndDo
	EndIf
	
	If Len(aProd) == 0
		MsgAlert("Não existem solicitações para serem empenhadas")
	Else 
		aSort(aProd)
		If Len(aProd) > 0
			aAdd(aAta, cCodEdt)
			aAdd(aAta, cNumAta)
			aAdd(aAta, cNumPro)
			aAdd(aAta, aProd)
			
			Aadd(aDadosAta,cCodEdt)
			Aadd(aDadosAta,cNumPro)
			Aadd(aDadosAta,cCodOrg)
			
		EndIf
	
		nGravou := GCPXGeraNE(oModel,,cCodFor,cLoja,.F.,.F.,.T.,aAta,aDadosAta)
		cCodNe	 := CX0->CX0_CODNE
		
		If nGravou != 0 
			Help( "" , 1 , "GCPGENEATA" )
		EndIf
		
		If nGravou == 0
			For nPos := 1 To Len(aProd)
				CX3->(DbSetOrder(1))
				If CX3->(DbSeek(cCodFil+cNumAta+aProd[nPos][1]))
					While CX3->(!EOF()) .AND. CX3->CX3_NUMATA == cNumAta .AND. Alltrim(CX3->CX3_CODPRO) == Alltrim(aProd[nPos][1])
						If !CX3->(CX3_EMPENH)
							RecLock("CX3",.F.)
								CX3->CX3_EMPENH := .T.
								CX3->CX3_CODNE := CX0->CX0_CODNE
								
								If A400GetIt(CX0->CX0_CODNE,(aProd[nPos][1]))
									CX3->CX3_ITEMNE := CX1->CX1_ITEM 	
								EndIf
							MsUnlock()
						EndIf
						CX3->(dbSkip())
					EndDo
				EndIf
			Next
		EndIf	
	EndIf
Next nX

RestArea(aArea)

Return Nil
