#INCLUDE "LOJA7031.ch"
#INCLUDE 'PROTHEUS.CH' 
#INCLUDE 'FWMVCDEF.CH'
//----------------------------------------------------------
/*	 Cadastro de Eventos - Integração com NeoGrid
@author  	Carlos MOta
@version 	P11 
@build		
@since 		30/07/2013
@return 	Nil														  	  
//---------------------------------------------------------- */ 
Function LOJA7031()
Local oBrowse    // Objeto do cadastro de Eventos (MVC)
                                 
oBrowse:= FWMBrowse():New()
oBrowse:SetAlias("MFP")                                	
oBrowse:SetLocate()
oBrowse:SetDescription(STR0001) //'Cadastro de Evento'
oBrowse:Activate()
Return Nil

//----------------------------------------------------------
/*	 Construção definição do modelo de dados
@author  	Carlos MOta
@version 	P11 
@build		
@since 		30/07/2013
@return 	Nil														  	  
//---------------------------------------------------------- */
Static Function ModelDef()
Local oStruMFP  := FWFormStruct(1,"MFP")  // Eventos
Local oStruMFR1 := FWFormStruct(1,"MFR")  // Filtro Produto
Local oStruMFR2 := FWFormStruct(1,"MFR")  // Filtro Fornecedor
Local oStruMFR3 := FWFormStruct(1,"MFR")  // Filtro Armazem
Local oModel    := NIL

oModel:= MPFormModel():New("LOJA7031", /*bPreValidacao*/ ,{ |oModel| Lj7031Valid( oModel ) },/*bGravacao*/)
oModel:AddFields('MFPMASTER',/*cOwner*/,oStruMFP)
oModel:SetPrimaryKey( {"MFP_FILIAL","MFP_CODEVE"} )
oModel:AddGrid( "MFR1DETAIL" , "MFPMASTER"   /*cOwner*/, oStruMFR1, /*bLinePre*/, /*bLinePost*/, /*bPre*/, {|| VlBtOk(@oModel )})
oModel:AddGrid( "MFR2DETAIL" , "MFPMASTER"   /*cOwner*/, oStruMFR2, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:AddGrid( "MFR3DETAIL" , "MFPMASTER"   /*cOwner*/, oStruMFR3, /*bLinePre*/, /*bLinePost*/, /*bPre*/, /*bPost*/ )
oModel:SetRelation( "MFR1DETAIL"    , { { "MFR_FILIAL", "xFilial('MFR')" } , { "MFR_CODEVE"   , "MFP_CODEVE" } } , MFR->( IndexKey( 1 ) ) )
oModel:SetRelation( "MFR2DETAIL"    , { { "MFR_FILIAL", "xFilial('MFR')" } , { "MFR_CODEVE"   , "MFP_CODEVE" } } , MFR->( IndexKey( 1 ) ) )
oModel:SetRelation( "MFR3DETAIL"    , { { "MFR_FILIAL", "xFilial('MFR')" } , { "MFR_CODEVE"   , "MFP_CODEVE" } } , MFR->( IndexKey( 1 ) ) )

oModel:SetDescription(STR0002) //"Modelo de dados"

oModel:GetModel('MFPMASTER'):SetDescription(STR0003) //'Dados Cadastro de Eventos'

oModel:GetModel('MFR1DETAIL'):SetDescription(STR0004)      //'Filtro do Evento'
oModel:GetModel('MFR2DETAIL'):SetDescription(STR0004)  //'Filtro do Evento'
oModel:GetModel('MFR3DETAIL'):SetDescription(STR0004) //'Filtro do Evento'

oModel:GetModel("MFR1DETAIL" ):SetUniqueLine( { "MFR_ITEM","MFR_PRODUT","MFR_GRUPO","MFR_CATEG","MFR_FORNEC","MFR_LOJA","MFR_ARMAZ" } )
oModel:GetModel("MFR2DETAIL" ):SetUniqueLine( { "MFR_ITEM","MFR_PRODUT","MFR_GRUPO","MFR_CATEG","MFR_FORNEC","MFR_LOJA","MFR_ARMAZ" } )
oModel:GetModel("MFR3DETAIL" ):SetUniqueLine( { "MFR_ITEM","MFR_PRODUT","MFR_GRUPO","MFR_CATEG","MFR_FORNEC","MFR_LOJA","MFR_ARMAZ" } )
// Filtros
oModel:GetModel( 'MFR1DETAIL' ):SetLoadFilter( { { 'MFR_GRID', "'1'" } } )   
oModel:GetModel( 'MFR2DETAIL' ):SetLoadFilter( { { 'MFR_GRID', "'2'" } } )   
oModel:GetModel( 'MFR3DETAIL' ):SetLoadFilter( { { 'MFR_GRID', "'3'" } } )
Return oModel
//----------------------------------------------------------
/*	 Construção da interface do modelo de dados
@author  	Carlos Mota
@version 	P11 
@build		
@since 		30/07/2013
@return 	Nil														  	  
//---------------------------------------------------------- */
Static Function ViewDef() 
Local oModel    := FWLoadModel("LOJA7031")
Local oStruMFP  := FWFormStruct( 2,"MFP") // Eventos
Local oStruMFR1 := FWFormStruct( 2,"MFR") // Filtro Produto
Local oStruMFR2 := FWFormStruct( 2,"MFR") // Filtro Fonecedor
Local oStruMFR3 := FWFormStruct( 2,"MFR") // Filtro Armazem
Local oView     // Objeto da View 
// Produto                        
oStruMFR1:RemoveField("MFR_TIPO")
oStruMFR1:RemoveField("MFR_CODEVE")
oStruMFR1:RemoveField("MFR_FORNEC")
oStruMFR1:RemoveField("MFR_LOJA")
oStruMFR1:RemoveField("MFR_DESFOR")
oStruMFR1:RemoveField("MFR_ARMAZ")
oStruMFR1:RemoveField("MFR_DESARM")
oStruMFR1:RemoveField("MFR_GRID")
// Fornecedor
oStruMFR2:RemoveField("MFR_TIPO")
oStruMFR2:RemoveField("MFR_CODEVE")
oStruMFR2:RemoveField("MFR_PRODUT")
oStruMFR2:RemoveField("MFR_DESPRO")
oStruMFR2:RemoveField("MFR_GRUPO")
oStruMFR2:RemoveField("MFR_DESGRP")
oStruMFR2:RemoveField("MFR_CATEG")
oStruMFR2:RemoveField("MFR_DESCAT")
oStruMFR2:RemoveField("MFR_ARMAZ")
oStruMFR2:RemoveField("MFR_DESARM")
oStruMFR2:RemoveField("MFR_GRID")
// Armazem
oStruMFR3:RemoveField("MFR_TIPO")
oStruMFR3:RemoveField("MFR_CODEVE")
oStruMFR3:RemoveField("MFR_PRODUT")
oStruMFR3:RemoveField("MFR_DESPRO")
oStruMFR3:RemoveField("MFR_GRUPO")
oStruMFR3:RemoveField("MFR_DESGRP")
oStruMFR3:RemoveField("MFR_CATEG")
oStruMFR3:RemoveField("MFR_DESCAT")
oStruMFR3:RemoveField("MFR_FORNEC")
oStruMFR3:RemoveField("MFR_LOJA")
oStruMFR3:RemoveField("MFR_DESFOR")
oStruMFR3:RemoveField("MFR_GRID")
 
oView := FWFormView():New() 
oView:SetModel(oModel) 
oView:AddField( 'VIEW_MFP', oStruMFP, 'MFPMASTER' )     

oView:AddGrid( "VIEW_MFR1", oStruMFR1, "MFR1DETAIL"  )             
oView:AddGrid( "VIEW_MFR2", oStruMFR2, "MFR2DETAIL"  )                                                         
oView:AddGrid( "VIEW_MFR3", oStruMFR3, "MFR3DETAIL"  )                                                         

oView:CreateHorizontalBox( "FORMFIELD", 50 )
oView:CreateHorizontalBox( "FORFOLDER", 50 )

oView:CreateFolder("FOLDER_01","FORFOLDER")

oView:AddSheet("FOLDER_01", "ABA_01_01", STR0005 )      //"Produto"
oView:AddSheet("FOLDER_01", "ABA_01_02", STR0006 )   //"Fornecedor"
oView:AddSheet("FOLDER_01", "ABA_01_03", STR0007 )      //"Armazem"

oView:createHorizontalBox("PRODGRID", 100,,,"FOLDER_01","ABA_01_01")
oView:createHorizontalBox("FORNGRID", 100,,,"FOLDER_01","ABA_01_02")
oView:createHorizontalBox("ARMZGRID", 100,,,"FOLDER_01","ABA_01_03")

oView:SetOwnerView( "VIEW_MFP" , "FORMFIELD"  )
oView:SetOwnerView( "VIEW_MFR1", "PRODGRID" )
oView:SetOwnerView( "VIEW_MFR2", "FORNGRID" )
oView:SetOwnerView( "VIEW_MFR3", "ARMZGRID" )  

oView:EnableControlBar( .T. )

oView:AddIncrementField( 'VIEW_MFR1', 'MFR_ITEM' )
oView:AddIncrementField( 'VIEW_MFR2', 'MFR_ITEM' )
oView:AddIncrementField( 'VIEW_MFR3', 'MFR_ITEM' ) 
Return oView

//----------------------------------------------------------
/*	 Valida ao clicar no botão Ok
@author  	Carlos Mota
@version 	P11 
@build		
@since 		30/07/2013
@return 	Nil														  	  
//---------------------------------------------------------- */
Static Function VlBtOk(oModel)
Local nOperation := oModel:GetOperation()         // Acao realizada 
Local oMd        := oModel:GetModel("MFPMASTER")  // Modelo de dados do Master
Local lRet		 := .T.

If !LJ7031T2Valid(oModel)
	lRet := .F.
EndIf

/*Inclui / Altera*/
If lRet .And. nOperation == 4 // Alteracao Limpa o campo de Exportacao de Dados 
   oMd:SetValue('MFP_DRPEXP','')
Endif

Return lRet

//----------------------------------------------------------
/*	 MenuDef 
@author  	Carlos Mota
@version 	P11 
@build		
@since 		30/07/2013
@return 	Nil														  	  
//---------------------------------------------------------- */
Static Function MenuDef()
Local aArea		:= GetArea() // Salva o ambiente ativo
Local aRotina 	:= {}        // Array para o menu principal

aAdd( aRotina, { STR0008, "PesqBrw"          , 0, 1, 0, .T. } ) // Pesquisar //"Pesquisar"
aAdd( aRotina, { STR0009, "VIEWDEF.LOJA7031"  , 0, 2, 0, .F. } ) // Visualizar //"Visualizar"
aAdd( aRotina, { STR0010, "VIEWDEF.LOJA7031"  , 0, 3, 0, Nil } ) // Incluir //"Incluir"
aAdd( aRotina, { STR0011, "VIEWDEF.LOJA7031"  , 0, 4, 0, Nil } ) // Alterar //"Alterar"
aAdd( aRotina, { STR0012, "VIEWDEF.LOJA7031"  , 0, 5, 3, Nil } ) // Excluir //"Excluir"
RestArea( aArea )
Return aRotina        
//----------------------------------------------------------
/*	 Exibir e inicializar a Descricao do Evento
@author  	Carlos Mota
@version 	P11 
@build		
@since 		09/08/2013
@return 	Nil														  	  
//---------------------------------------------------------- */
Function LOJA7031A()
Local lRet       :=.T.,nReg
Local cCampo     :=ReadVar(),cConteudo:=&(ReadVar())
Local oModel     := NIL  // Modelo de dados
Local oModel1    := NIL  // Modelo de dados
Local oModelDet  := NIL  // Modelo de dados
Local aSaveLines := NIL  // Guarda pocisionamento do Grid
Local cFornec    := NIL  // Codigo do Fornecedor
Local cCodeve    := NIL  // Codigo do Evento

If Alltrim(cCampo) == "M->MFP_TIPEVE"
	If !("MFQ"$cFOPENed)
		dbSelectArea("MFQ")
	EndIf

	dbSelectArea("MFQ")
	dbSetOrder(1)
	dbSeek(xFilial("MFQ")+cConteudo)

	If !Found()
		Help(" ",1,"GRNEXIST")
		lRet:=.F.
	EndIf
	If lRet
		M->MFP_DESTEV := MFQ->MFQ_DESCR 
	EndIf
EndIf    
If Alltrim(cCampo) == "M->MFR_PRODUT"
    aSaveLines := FWSaveRows()
	oModel     := FWLoadModel( 'LOJA7031' )
	oModelDet  := oModel:GetModel( 'MFR1DETAIL' ) 
	
	oModel     := FWModelActive()  
	If !("SB1"$cFOPENed)
		dbSelectArea("SB1")
	EndIf  
	oModelMst  := oModel:GetModel( 'MFPMASTER' )
	cCodEve    := oModelMst:GetValue('MFP_CODEVE') 

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+cConteudo)

	If !Found()
		Help(" ",1,STR0013) //"Produto não cadastrado"
		lRet:=.F.
	EndIf
	If lRet
		oModel:SetValue('MFR1DETAIL','MFR_CODEVE',cCodEve)
		oModel:SetValue('MFR1DETAIL','MFR_DESPRO',SB1->B1_DESC)
   		oModel:SetValue('MFR1DETAIL','MFR_TIPO','1')
   		oModel:SetValue('MFR1DETAIL','MFR_GRID','1')

   		oModel:LoadValue('MFR1DETAIL','MFR_GRUPO','')
   		oModel:LoadValue('MFR1DETAIL','MFR_DESGRP','')
   		oModel:LoadValue('MFR1DETAIL','MFR_CATEG','')
   		oModel:LoadValue('MFR1DETAIL','MFR_DESCAT','')
	EndIf
EndIf
If Alltrim(cCampo) == "M->MFR_GRUPO"
    aSaveLines := FWSaveRows()
	oModel     := FWLoadModel( 'LOJA7031' )
	oModelDet  := oModel:GetModel( 'MFR1DETAIL' ) 
	oModel     := FWModelActive()  
	If !("SBM"$cFOPENed)
		dbSelectArea("SBM")
	EndIf
	oModelMst  := oModel:GetModel( 'MFPMASTER' )
	cCodEve := oModelMst:GetValue('MFP_CODEVE') 

	dbSelectArea("SBM")
	dbSetOrder(1)
	dbSeek(xFilial("SBM")+cConteudo)

	If !Found()
		Help(" ",1,STR0014) //"Grupo nao cadastrado"
		lRet:=.F.
	EndIf
	If lRet
		oModel:SetValue('MFR1DETAIL','MFR_CODEVE',cCodEve)
   		oModel:SetValue('MFR1DETAIL','MFR_DESGRP',SBM->BM_DESC)
   		oModel:SetValue('MFR1DETAIL','MFR_TIPO','2')
   		oModel:SetValue('MFR1DETAIL','MFR_GRID','1')
   		oModel:LoadValue('MFR1DETAIL','MFR_CATEG','')
   		oModel:LoadValue('MFR1DETAIL','MFR_DESCAT','')
		oModel:LoadValue('MFR1DETAIL','MFR_PRODUT','')
		oModel:LoadValue('MFR1DETAIL','MFR_DESPRO','')
	EndIf
EndIf
If Alltrim(cCampo) == "M->MFR_CATEG"
    aSaveLines := FWSaveRows()
	oModel     := FWLoadModel( 'LOJA7031' )
	oModelDet  := oModel:GetModel( 'MFR1DETAIL' ) 
	oModel     := FWModelActive()  
	If !("ACU"$cFOPENed)
		dbSelectArea("ACU")
	EndIf                               
	oModelMst  := oModel:GetModel( 'MFPMASTER' )
	cCodEve := oModelMst:GetValue('MFP_CODEVE') 

	dbSelectArea("ACU")
	dbSetOrder(1)
	dbSeek(xFilial("ACU")+cConteudo)

	If !Found()
		Help(" ",1,STR0015) //"Categoria nao cadastrado"
		lRet:=.F.
	EndIf
	If lRet
		oModel:SetValue('MFR1DETAIL','MFR_CODEVE',cCodEve)
   		oModel:SetValue('MFR1DETAIL','MFR_DESCAT',ACU->ACU_DESC)
   		oModel:SetValue('MFR1DETAIL','MFR_TIPO','3')
   		oModel:SetValue('MFR1DETAIL','MFR_GRID','1')
		oModel:LoadValue('MFR1DETAIL','MFR_PRODUT','')
		oModel:LoadValue('MFR1DETAIL','MFR_DESPRO','')
   		oModel:LoadValue('MFR1DETAIL','MFR_GRUPO','')
   		oModel:LoadValue('MFR1DETAIL','MFR_DESGRP','')
	EndIf
EndIf
If Alltrim(cCampo) == "M->MFR_LOJA"
    aSaveLines := FWSaveRows()
	oModel     := FWLoadModel( 'LOJA7031' )
	oModel     := FWModelActive() 
	oModelDet  := oModel:GetModel( 'MFR2DETAIL' ) 
	oModelMst  := oModel:GetModel( 'MFPMASTER' )
	
	If !("SA2"$cFOPENed)
		dbSelectArea("SA2")
	EndIf

	cFornec := oModelDet:GetValue('MFR_FORNEC')
	cCodEve := oModelMst:GetValue('MFP_CODEVE') 
	If Empty(Alltrim(cFornec))
		Help(" ",1,STR0016) //"Fornecedor nao preenchido, Campo Cod Fornec"
		lRet:=.F.
    Else
		dbSelectArea("SA2")
		dbSetOrder(1)
		dbSeek(xFilial("SA2")+cFornec+cConteudo)
	
		If !Found()
			Help(" ",1,STR0017) //"Fornecedor nao cadastrado"
			lRet:=.F.
		EndIf
		If lRet
			oModel:SetValue('MFR2DETAIL','MFR_CODEVE',cCodEve)
	   		oModel:SetValue('MFR2DETAIL','MFR_DESFOR',SA2->A2_NOME)
	   		oModel:SetValue('MFR2DETAIL','MFR_TIPO','4')
     		oModel:SetValue('MFR2DETAIL','MFR_GRID','2')
		EndIf
    Endif
EndIf
If Alltrim(cCampo) == "M->MFR_ARMAZ"
    aSaveLines := FWSaveRows()
	oModel     := FWLoadModel( 'LOJA7031' )
	oModelDet  := oModel:GetModel( 'MFR3DETAIL' ) 
	oModel     := FWModelActive()  
	
	If !("NNR"$cFOPENed)
		dbSelectArea("NNR")
	EndIf
	
	dbSelectArea("NNR")
	dbSetOrder(1)
	dbSeek(xFilial("NNR")+cConteudo)
	
	If !Found()
		Help(" ",1,STR0018) //"Armazem nao cadastrado"
		lRet:=.F.
	EndIf
	oModelMst  := oModel:GetModel( 'MFPMASTER' )
	cCodEve := oModelMst:GetValue('MFP_CODEVE') 
	If lRet
		oModel:SetValue('MFR3DETAIL','MFR_CODEVE',cCodEve)
	   	oModel:SetValue('MFR3DETAIL','MFR_DESARM',NNR->NNR_DESCRI)
	   	oModel:SetValue('MFR3DETAIL','MFR_TIPO','5')
   		oModel:SetValue('MFR3DETAIL','MFR_GRID','3')
	EndIf
EndIf
FWRestRows( aSaveLines )
dbSelectArea("MFP")
Return lRet          
//----------------------------------------------------------
/*	 Exibir e inicializar a Descricao do Evento no Grid 
     inicializador Padrao 
@author  	Carlos Mota
@version 	P11 
@build		
@since 		15/08/2013
@return 	Descricao														  	  
//---------------------------------------------------------- */
Function LOJA7031B()   	
Local cRet       :=''            // Retorno da Funcao
Local cCampo     :=ReadVar()    // Nome da Variavel
Local cConteudo  :=&(ReadVar()) //  Conteudo da Variavel 
Local oModel     := NIL         // Modelo de Dados Master
Local oModelDet  := NIL         // Modelo de Dados Detalhe

If !Inclui
	If Alltrim(cCampo) == "M->MFR_DESPRO" .and. !Empty(Alltrim(MFR->MFR_PRODUT))
		If !("SB1"$cFOPENed)
			dbSelectArea("SB1")
		EndIf
	
		dbSelectArea("SB1")
		dbSetOrder(1)
		If dbSeek(xFilial("SB1")+MFR->MFR_PRODUT)
		   cRet  := SB1->B1_DESC
		EndIf
	EndIf 
	If Alltrim(cCampo) == "M->MFR_DESGRP" .and. !Empty(MFR->MFR_GRUPO)
		If !("SBM"$cFOPENed)
			dbSelectArea("SBM")
		EndIf
	
		dbSelectArea("SBM")
		dbSetOrder(1)
		If dbSeek(xFilial("SBM")+MFR->MFR_GRUPO)
		   cRet  := SBM->BM_DESC
		EndIf
	EndIf 
	If Alltrim(cCampo) == "M->MFR_DESCAT" .and. !Empty(MFR->MFR_CATEG)
		If !("ACU"$cFOPENed)
			dbSelectArea("ACU")
		EndIf
	
		dbSelectArea("ACU")
		dbSetOrder(1)
		If dbSeek(xFilial("ACU")+MFR->MFR_CATEG)
		   cRet  := ACU->ACU_DESC
		EndIf
	EndIf
	If Alltrim(cCampo) == "M->MFR_DESFOR" .and. !Empty(MFR->MFR_FORNEC)
		If !("SA2"$cFOPENed)
			dbSelectArea("SA2")
		EndIf
	
		dbSelectArea("SA2")
		dbSetOrder(1)
		If dbSeek(xFilial("SA2")+MFR->MFR_FORNEC+MFR->MFR_LOJA)
		   cRet  := SA2->A2_NOME
		EndIf
	EndIf 
	If Alltrim(cCampo) == "M->MFR_DESARM" .and. !Empty(MFR->MFR_ARMAZ)
		If !("NNR"$cFOPENed)
			dbSelectArea("NNR")
		EndIf
	
		dbSelectArea("NNR")
		dbSetOrder(1)
		If dbSeek(xFilial("NNR")+MFR->MFR_ARMAZ)
		   cRet  := NNR->NNR_DESCRI
		EndIf
	EndIf
Endif
dbSelectArea("MFP")
Return cRet


//----------------------------------------------------------
/*	 Validação - data inicial/data final 
@author  	
@version 	P11 
@build		
@since 		13/05/2015
@return 	lRet														  	  
//---------------------------------------------------------- */
Function Lj7031Valid(oModel)

Local lRet := .T.									// Retorno lógico
Local nOperation 	:= oModel:GetOperation()  	// Tipo de Operação
Local oModelMFP   := oModel:GetModel("MFPMASTER")  	// Model MFP
Local dMfpIni		:= Ctod("")							// Data Inicial
Local dMfpFim		:= Ctod("")							// Data Final

Default oModel := Nil

If nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
	dMfpIni := oModelMFP:GetValue('MFP_DTINI')
	dMfpFim := oModelMFP:GetValue('MFP_DTFIM') 
	If !Empty(dMfpFim) .And. (dMfpFim < dMfpIni)
		Help("",1,"Help",STR0019,STR0020 + " " + STR0021,1,0) //"Fim Evento"###"Data Fim Evento menor que Data Inicio Evento!"###"Vá ao campo Fim Evento."
		lRet := .F.
	EndIf
EndIf	

Return lRet


//----------------------------------------------------------
/*	 Validação - line post da Tela 2 Fornecedores - MFR2DETAIL
@author  	
@version 	P11 
@build		
@since 		18/11/2015
@return 	.T. ou .F.														  	  
//---------------------------------------------------------- */
Function LJ7031T2Valid(oModel)

Local oMdDet2    := oModel:GetModel("MFR2DETAIL") // Modelo de dados do Detalhe 2 - Fornecedores
Local nX			:= 0									// Contador
Local lRet			:= .T.									// Retorno Lógico

Default oModel := Nil

If oMdDet2 != Nil
	For nX := 1 to Len(oMdDet2:aDataModel)
		//Legenda: oMdDet2:aDataModel[nX][1][1][11] = MFR_FORNEC
		//Legenda: oMdDet2:aDataModel[nX][1][1][12] = MFR_LOJA
		If !Empty(oMdDet2:aDataModel[nX][1][1][11]) .AND. Empty(oMdDet2:aDataModel[nX][1][1][12]) //Fornec. não vazio e loja vazia
			Help(" ",1,"Help",STR0024+" "+STR0022+Alltrim(Str(nX))+STR0023,"",1,0) //"Aba Fornecedor:"###"Loja (item "###") não cadastrada"
			lRet := .F.
		EndIf
	Next
EndIf

Return lRet
