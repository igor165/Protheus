#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'GTPA002P.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA002P()
 LINHA x PERFIL DE ALOCACAO  

@sample  	GTPA002P()
@Return 	
@author	Lucas Brustolin -  Inovação
@since		07/07/2017
@version 	P12
/*/
//-------------------------------------------------------------------

Function GTPA002P()

Local lRet :=  .T.

If GI2->( Recno() ) <> 0
    FWExecView(".","VIEWDEF.GTPA002P",MODEL_OPERATION_UPDATE,,{|| .T.})	
Else
    HELP(" ",1,"ARQVAZIO")
	lRet := .F.
Endif

Return(lRet)


//-------------------------------------------------------------------
/*/{Protheus.doc} TP003MDLDef()

@sample  	TP003MDLDef()

@return  	oModel - Modelo de dados

@author	Lucas Brustolin -  Inovação
@since		07/07/2017
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
		
Local oModel	    := Nil
Local oStruGI2	    := FWFormStruct( 1,"GI2",{ |x| ALLTRIM(x)+"|" $ "GI2_COD|" } , .F.) //Tabela de Linhas
Local oStruGYM		:= FWFormStruct( 1,"GYM" ) // Recursos por Linha
Local oStruTurno	:= FWFormStruct( 1,"GYJ" ) // Caracteristicas da Linha - Turno 
Local oStruFuncao	:= FWFormStruct( 1,"GYJ" ) // Caracteristicas da Linha - Funcao
Local oStruCargo	:= FWFormStruct( 1,"GYJ" ) // Caracteristicas da Linha - Cargo
Local oStruCurso	:= FWFormStruct( 1,"GYJ" ) // Caracteristicas da Linha - Curso	
Local oStruHabil	:= FWFormStruct( 1,"GYJ" ) // Caracteristicas da Linha - Habilidade
Local nI 			:= 0


//-- Add campo virtual Descrição Linha
GA002StrGI2(oStruGI2,"GTPA002A","M")

oStruGYM:SetProperty( "GYM_ORIGEM", MODEL_FIELD_INIT, {|| "GI2" }  )


// GATILHO - GRID TURNO                
oStruTurno:AddTrigger( ;
		'GYJ_CHAVE'  , ;                  	// [01] Id do campo de origem
		'GYJ_DESC'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		 { || AllTrim(Posicione( "SR6", 1, xFilial('SR6') + SubStr(FwFldGet("GYJ_CHAVE"),1,TamSx3("R6_TURNO")[1]), 'R6_DESC'))	} ) // [04] Bloco de codigo de execução do gatilho
		 	 
oStruTurno:SetProperty('GYJ_DESC' , MODEL_FIELD_INIT,{|| Posicione( "SR6", 1, xFilial('SR6') + GYJ->GYJ_CHAVE, 'R6_DESC') } )


// GATILHO - GRID FUNCAO               
oStruFuncao:AddTrigger( ;
		'GYJ_CHAVE'  , ;                  	// [01] Id do campo de origem
		'GYJ_DESC'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		 { || Posicione( "SRJ", 1, xFilial('SRJ') + SubStr(FwFldGet("GYJ_CHAVE"),1,TamSx3("RJ_FUNCAO")[1]), 'RJ_DESC')	} ) // [04] Bloco de codigo de execução do gatilho
		 	 
oStruFuncao:SetProperty('GYJ_DESC' , MODEL_FIELD_INIT,{|| Posicione( "SRJ", 1, xFilial('SRJ') + GYJ->GYJ_CHAVE, 'RJ_DESC') } )

// GATILHO - GRID CARGO               
oStruCargo:AddTrigger( ;
		'GYJ_CHAVE'  , ;                  	// [01] Id do campo de origem
		'GYJ_DESC'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		 { || AllTrim(Posicione( "SQ3", 1, xFilial('SQ3') + SubStr(FwFldGet("GYJ_CHAVE"),1,TamSx3("Q3_CARGO")[1]), 'Q3_DESCSUM'))	} ) // [04] Bloco de codigo de execução do gatilho
		 	 
oStruCargo:SetProperty('GYJ_DESC' , MODEL_FIELD_INIT,{|| Posicione( "SQ3", 1, xFilial('SQ3') + GYJ->GYJ_CHAVE, 'Q3_DESCSUM') } )

// GATILHO - GRID CURSO           
oStruCurso:AddTrigger( ;
		'GYJ_CHAVE'  , ;                  	// [01] Id do campo de origem
		'GYJ_DESC'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		 { || AllTrim(Posicione( "RA1", 1, xFilial('RA1') + SubStr(FwFldGet("GYJ_CHAVE"),1,TamSx3("RA1_CURSO")[1]) , 'RA1_DESC'))	} ) // [04] Bloco de codigo de execução do gatilho
		 	 
oStruCurso:SetProperty('GYJ_DESC' , MODEL_FIELD_INIT,{|| Posicione( "RA1", 1, xFilial('RA1') + GYJ->GYJ_CHAVE, 'RA1_DESC') } )


// GATILHO GRID HABILIDADES                
oStruHabil:AddTrigger( ;
		'GYJ_CHAVE'  , ;                  	// [01] Id do campo de origem
		'GYJ_DESC'  , ;                  	// [02] Id do campo de destino
		 { || .T. } , ; 						// [03] Bloco de codigo de validação da execução do gatilho
		 { || AllTrim(Posicione( "RBG", 1, xFilial('RBG') + SubStr(FwFldGet("GYJ_CHAVE"),1,TamSx3("RBG_HABIL")[1]), 'RBG_DESC'))	} ) // [04] Bloco de codigo de execução do gatilho
		 	 
oStruHabil:SetProperty('GYJ_DESC' , MODEL_FIELD_INIT,{|| Posicione( "RBG", 1, xFilial('RBG') + GYJ->GYJ_CHAVE, 'RBG_DESC') } )


oStruGYM:SetProperty('GYM_CODIGO',MODEL_FIELD_OBRIGAT, .F. )
oStruTurno:SetProperty('*'	,MODEL_FIELD_OBRIGAT, .F. )
oStruFuncao:SetProperty('*'	,MODEL_FIELD_OBRIGAT, .F. )
oStruCargo:SetProperty('*'	,MODEL_FIELD_OBRIGAT, .F. )
oStruCurso:SetProperty('*'	,MODEL_FIELD_OBRIGAT, .F. )
oStruHabil:SetProperty('*'	,MODEL_FIELD_OBRIGAT, .F. )

oModel := MPFormModel():New("GTPA002P")//, /*bPreValidacao*/, {|oMdl| TA39FVld(oMdl)}/*bPosValidacao*/,/*bCommit*/, /*bCancel*/ )

oModel:AddFields("GI2MASTER", /*cOwner*/, oStruGI2,/*bLinePre*/)

oModel:AddGrid('GYMGRID','GI2MASTER' , oStruGYM)
oModel:SetRelation( 'GYMGRID', { { 'GYM_FILIAL', 'xFilial( "GI2" )' }, { 'GYM_CODENT', 'GI2_COD' },{'GYM_ORIGEM',"'GI2'"}  }, GYM->( IndexKey( 1 ) ) )

oModel:AddGrid('GYJGRID_1','GYMGRID',oStruTurno)
oModel:SetRelation( 'GYJGRID_1', { { 'GYJ_FILIAL', 'xFilial( "GYM" )'	},{'GYJ_CODGYM', 'GYM_CODIGO' }, { 'GYJ_TIPO'	, "'1'" } }, GYJ->(IndexKey(1)))

oModel:AddGrid('GYJGRID_2','GYMGRID',oStruFuncao)
oModel:SetRelation( 'GYJGRID_2', { { 'GYJ_FILIAL', 'xFilial( "GYM" )'	},{'GYJ_CODGYM', 'GYM_CODIGO' }, { 'GYJ_TIPO'	, "'2'" } }, GYJ->(IndexKey(1)))

oModel:AddGrid('GYJGRID_3','GYMGRID',oStruCargo)
oModel:SetRelation( 'GYJGRID_3', { { 'GYJ_FILIAL', 'xFilial( "GYM" )'	},{'GYJ_CODGYM', 'GYM_CODIGO' }, { 'GYJ_TIPO'	, "'3'" } }, GYJ->(IndexKey(1)))

oModel:AddGrid('GYJGRID_4','GYMGRID',oStruCurso)
oModel:SetRelation( 'GYJGRID_4', { { 'GYJ_FILIAL', 'xFilial( "GYM" )'	},{'GYJ_CODGYM', 'GYM_CODIGO' }, { 'GYJ_TIPO'	, "'4'" } }, GYJ->(IndexKey(1)))

oModel:AddGrid('GYJGRID_5','GYMGRID',oStruHabil)
oModel:SetRelation( 'GYJGRID_5', { { 'GYJ_FILIAL', 'xFilial( "GYM" )'	},{'GYJ_CODGYM', 'GYM_CODIGO' }, { 'GYJ_TIPO'	, "'5'" } }, GYJ->(IndexKey(1)))


oModel:GetModel("GI2MASTER"):SetOnlyQuery(.T.)

oModel:GetModel('GYMGRID'):SetOptional(.T.)
oModel:GetModel("GYMGRID"):SetUniqueLine( { "GYM_RECCOD" } )


For nI := 1 To 5
	oModel:GetModel('GYJGRID_' + AllTrim( Str(nI) ) ):SetOptional(.T.)
	oModel:GetModel('GYJGRID_' + AllTrim( Str(nI) ) ):SetUniqueLine( { "GYJ_CODGYM","GYJ_CHAVE" } )
Next

oModel:SetDescription(STR0001) // ""Perfil Alocação x Linha""
oModel:GetModel('GYMGRID'):SetDescription(STR0002)	//"Tipos de Recursos"
oModel:GetModel('GYJGRID_1'):SetDescription(STR0003) //'Turnos'
oModel:GetModel('GYJGRID_2'):SetDescription(STR0004)	//'Funções'
oModel:GetModel('GYJGRID_3'):SetDescription(STR0005)	//'Cargos'
oModel:GetModel('GYJGRID_4'):SetDescription(STR0006)	//'Cursos'
oModel:GetModel('GYJGRID_5'):SetDescription(STR0007)	//'Habilidades'

oModel:SetActivate({|oMdl| GA002LoadGI2(oMdl,"GI2MASTER")})

//Define chave unica
oModel:SetPrimaryKey({"GI2_FILIAL","GI2_COD"})

Return ( oModel )

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()

@sample  	ViewDef()

@return  	oView - Objeto do View

@author	Lucas Brustolin -  Inovação
@since		07/07/2017
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView 		:= FWFormView():New()
Local oModel		:= FwLoadModel("GTPA002P")

//-- Estruras de Linha e  Perfil de Alocacao
Local oStruGI2	    := FWFormStruct( 2,"GI2", { |x| ALLTRIM(x)+"|" $ "GI2_COD|" } , .F.) //Tabela de Linhas
Local oStruGYM		:= FWFormStruct( 2,"GYM", {|cCampo| AllTrim(cCampo)+ "|" $ "GYM_RECCOD|GYM_RECDES|GYM_QTD|GYM_OBG|GYM_OBGEXT|" } )
Local oStruTurno	:= FWFormStruct( 2,"GYJ", {|cCampo| AllTrim(cCampo)+ "|" $ "GYJ_CHAVE|GYJ_DESC|"})
Local oStruFuncao	:= FWFormStruct( 2,"GYJ", {|cCampo| AllTrim(cCampo)+ "|" $ "GYJ_CHAVE|GYJ_DESC|"})
Local oStruCargo	:= FWFormStruct( 2,"GYJ", {|cCampo| AllTrim(cCampo)+ "|" $ "GYJ_CHAVE|GYJ_DESC|"})
Local oStruCurso	:= FWFormStruct( 2,"GYJ", {|cCampo| AllTrim(cCampo)+ "|" $ "GYJ_CHAVE|GYJ_DESC|"})
Local oStruHabil	:= FWFormStruct( 2,"GYJ", {|cCampo| AllTrim(cCampo)+ "|" $ "GYJ_CHAVE|GYJ_DESC|"})


//-- Add campo virtual Descrição Linha
GA002StrGI2(oStruGI2,"GTPA002A","V")

oView:SetModel(oModel)

oView:AddField("VIEW_GI2", oStruGI2     , "GI2MASTER") 
oView:AddGrid('VIEW_GYM' , oStruGYM     , "GYMGRID"  )	
oView:AddGrid('VIEWGYJ_1', oStruTurno   , "GYJGRID_1")	
oView:AddGrid('VIEWGYJ_2', oStruFuncao  , "GYJGRID_2")	
oView:AddGrid('VIEWGYJ_3', oStruCargo   , "GYJGRID_3")	
oView:AddGrid('VIEWGYJ_4', oStruCurso   , "GYJGRID_4")	
oView:AddGrid('VIEWGYJ_5', oStruHabil   , "GYJGRID_5")

oView:CreateHorizontalBox('SUPERIOR',15)	
oView:CreateHorizontalBox('MEIO',45)	
oView:CreateHorizontalBox('INFERIOR',40)

oView:CreateFolder( "PASTA", "INFERIOR" )
oView:AddSheet( "PASTA", "ABA01", STR0003)  // "Turnos" 
oView:AddSheet( "PASTA", "ABA02", STR0004 )	// "Funções"
oView:AddSheet( "PASTA", "ABA03", STR0005 ) // "Cargos"
oView:AddSheet( "PASTA", "ABA04", STR0006 ) // "Cursos"
oView:AddSheet( "PASTA", "ABA05", STR0007 ) // "Habilidades"

oView:CreateHorizontalBox( 'ID_ABA01', 100,,, 'PASTA', 'ABA01' ) 
oView:CreateHorizontalBox( 'ID_ABA02', 100,,, 'PASTA', 'ABA02' ) 
oView:CreateHorizontalBox( 'ID_ABA03', 100,,, 'PASTA', 'ABA03' ) 
oView:CreateHorizontalBox( 'ID_ABA04', 100,,, 'PASTA', 'ABA04' ) 
oView:CreateHorizontalBox( 'ID_ABA05', 100,,, 'PASTA', 'ABA05' ) 


oView:SetOwnerView('VIEW_GI2','SUPERIOR')	
oView:SetOwnerView('VIEW_GYM','MEIO')	
oView:SetOwnerView('VIEWGYJ_1','ID_ABA01')
oView:SetOwnerView('VIEWGYJ_2','ID_ABA02')
oView:SetOwnerView('VIEWGYJ_3','ID_ABA03')
oView:SetOwnerView('VIEWGYJ_4','ID_ABA04')
oView:SetOwnerView('VIEWGYJ_5','ID_ABA05')
		

//Habitila os títulos dos modelos para serem apresentados na tela
oView:EnableTitleView("VIEW_GI2")
oView:EnableTitleView("VIEW_GYM")
oView:EnableTitleView("VIEWGYJ_1")
oView:EnableTitleView("VIEWGYJ_2")
oView:EnableTitleView("VIEWGYJ_3")
oView:EnableTitleView("VIEWGYJ_4")
oView:EnableTitleView("VIEWGYJ_5")


Return ( oView )

//-------------------------------------------------------------------
/*/{Protheus.doc} Tp300AF3()

Rotina chamada atraves da consulta padrão personalizada. Verifica 
qual pasta(Folder Ativa) para executar uma segunda consulta padrão.

@sample  	Tp300AF3()

@Return	.T. - Execução do F3

@author	Lucas Brustolin -  Inovação
@since		07/07/2017
@version 	P12
/*/
//-------------------------------------------------------------------

Function Tp300AF3()  

Local oView 	:= FwViewActive()
Local aArea 	:= GetArea()
Local nFolder	:= 0
Local cF3		:= ""
Local lRet  	:= .F.


//-- 1= Retorna o ID do folder, 2 = Retorna o titulo do folder.                                                                                   
nFolder 	:= oView:GetFolderActive("PASTA",2)[1] 

Do Case             
	Case nFolder = 1
		cF3 := "SR6" // Turno  		           
	Case nFolder = 2
		cF3	:= "SRJ" // Função
	Case nFolder = 3
		cF3	:= "SQ3" // Cargo
	Case nFolder = 4
		cF3	:= "RA1" // Curso
	Case nFolder = 5
		cF3	:= "RBG" // Habilidades	
EndCase


lRet := Conpad1( , , , cF3 )


RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} Tp300AF3()

Rotina chamada atraves da consulta padrão personalizada. Seu objetivo 
é retornar o valor de determinada tabela, conforme a pasta (Folder Ativo).

@sample  	Tp300ARtF3()

@Return 	cCod = Retorna valor do campo referente a consulta padrao

@author	Lucas Brustolin -  Inovação
@since		07/07/2017
@version 	P12
/*/
//-------------------------------------------------------------------
Function Tp300ARtF3()

Local oView 	:= FwViewActive()
Local nFolder := 0
Local cFolder	:= ""
Local cCod		:= ""

nFolder 	:= oView:GetFolderActive("PASTA",2)[1] 

Do Case             
	Case nFolder = 1
		&(Readvar()) := SR6->R6_TURNO     
		cCod := SR6->R6_TURNO
		
	Case nFolder = 2
		&(Readvar()) := SRJ->RJ_FUNCAO
		cCod := SRJ->RJ_FUNCAO
		
	Case nFolder = 3
		&(Readvar()) := SQ3->Q3_CARGO
		cCod := SQ3->Q3_CARGO
	
	Case nFolder = 4
		&(Readvar()) := RA1->RA1_CURSO
		cCod := RA1->RA1_CURSO

	Case nFolder = 5
		&(Readvar()) := RBG->RBG_HABIL
		cCod := RBG->RBG_HABIL

EndCase

Return(cCod)


//-------------------------------------------------------------------
/*/{Protheus.doc} TPExistGYJ()

Rotina que tem como objetivo validar existencia do codigo informado com 
base na pasta ativa. (Turno/Função/Cargo/Curso/Habilidade)

@sample  	TPExistGYJ()

@Return 	lRet = Retorna se validação está OK (.T./.F.)

@author	Lucas Brustolin -  Inovação
@since		11/09/2015
@version 	P12
/*/
//-------------------------------------------------------------------

Function TPExistGYJ(cConteudo)

Local oView 	:= FwViewActive()
Local nFolder := 0
Local cFolder	:= ""
Local lRet 	:= .T.

nFolder 	:= oView:GetFolderActive("PASTA",2)[1] 

Do Case             
	Case nFolder = 1
		cConteudo := SubStr(cConteudo,1,TamSx3("R6_TURNO")[1])
		lRet := ExistCpo("SR6", cConteudo )
	Case nFolder = 2
		cConteudo := SubStr(cConteudo,1,TamSx3("RJ_FUNCAO")[1])
		lRet := ExistCpo("SRJ", cConteudo )
	Case nFolder = 3
		cConteudo := SubStr(cConteudo,1,TamSx3("Q3_CARGO")[1])
		lRet := ExistCpo("SQ3", cConteudo )
	Case nFolder = 4
		cConteudo := SubStr(cConteudo,1,TamSx3("RA1_CURSO")[1])
		lRet := ExistCpo("RA1", cConteudo )
	Case nFolder = 5
	cConteudo := SubStr(cConteudo,1,TamSx3("RBG_HABIL")[1])
		lRet := ExistCpo("RBG", cConteudo )
EndCase

Return (lRet)
