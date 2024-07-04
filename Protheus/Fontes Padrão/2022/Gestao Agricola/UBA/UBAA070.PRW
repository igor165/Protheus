#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "UBAA070.CH"
 
//Variaveis estáticas rotina
Static __oBrwBloco    := Nil
Static __oBrwMala     := Nil
Static __oDXDTEMP     := Nil
Static __oDXJTEMP     := Nil
Static __oDXKTEMP     := Nil
Static __DXDTEMP      := Nil
Static __DXJTEMP      := Nil
Static __DXKTEMP      := Nil
Static __aFieldFilter := {}
Static __aMalaFilter  := {}
Static __cMarca       := GetMark()
Static __aEstrFrd 	  := {}
Static __cAliasFr
Static __nCodSeq  	  := 0
Static __nMaxCols     := 0
Static __cCodRegra	  := ""
Static __aReleva      := {}


/*/{Protheus.doc} UBAA070
//Rotina de Simulação e Persistência de Emblocamento
@author bruna.rocio
@since 04/08/2017
@version undefined
@type function
/*/
Function UBAA070(cCodRegra, cSafraPar)
	Local aButtons 		:= {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.T.,STR0086},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}} //botão fechar
	
	Default cCodRegra	:= ""
	
	Private bKeyF11070 	:= { || GatilhoPergunte(.T.) }
	Private bKeyF12070 	:= { || Pergunte('UBAA070003', .T.), UBAA070COL() }
	Private _cRet

	__cCodRegra := cCodRegra
	__cSafraPar	:= cSafraPar
	
	If .Not. FwIsInCallStack('AGRA720')
		SetKey( VK_F11, bKeyF11070 )
		SetKey( VK_F12, bKeyF12070 )
	EndIf	

	If .Not. TableInDic('N76')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	FWExecView(STR0014 /*"Simulação de Emblocamento"*/,"UBAA070",4,,{|| .T.},,,aButtons)

	SetKey(VK_F11,Nil)
	SetKey(VK_F12,Nil) 
Return Nil

/*/{Protheus.doc} ModelDef
//Camada de Modelo da Rotina
@author bruna.rocio
@since 04/08/2017
@version undefined
@type function
/*/
Static Function ModelDef()
	Local oModel    := MpFormModel():New('UBAA070') //trocar nome do model principal para nome da rotina e filhos para rotina_tabela
	Local oStrFIL   := getTTModelStruct()
	Local oStrFLSAF := getModelStruct()
	Local oStrBloco := FwFormStruct(1, 'DXD')
	Local oStrMala  := FwFormStruct(1, 'DXJ')
	Local oStruN7P 	:= FwFormStruct( 1, "N7P" )
	Local oStruN7T 	:= FwFormStruct( 1, "N7T" )
	Local bLoadGrid   := {|oGridModel, lCopy| FLSafraLoad(oGridModel, lCopy)}

	//Blocos de inicialização tabela DXJ - Mala
	Local bDXJNmProd := {|oGridModel| Posicione("NJ0",1,fwxFilial("NJ0")+DXJ->(DXJ_PRDTOR+DXJ_LJPRO),"NJ0_NOME")  }
	Local bDXJtNmFaz := {|oGridModel| Posicione("NN2",2,fwxFilial("NN2")+DXJ->DXJ_FAZ,"NN2_NOME")}
	Local bDXJNmClas := {|oGridModel| Posicione("NNA",1,fwxFilial("NNA")+DXJ->DXJ_CODCLA,"NNA_NOME")}

	//Blocos de inicialização tabela DXD - Bloco
	Local bDXDNmProd := {|oGridModel| Posicione("NJ0",1,fwxFilial("NJ0")+DXD->(DXD_PRDTOR+DXD_LJPRO),"NJ0_NOME")  }
	Local bDXDtNmFaz := {|oGridModel| Posicione("NN2",2,fwxFilial("NN2")+DXD->DXD_FAZ,"NN2_NOME")}

	//Manipula o inicializador da padrão da tabela mala, pois, produtor e fazenda não são obrigatórios	
	oStrMala:SetProperty('DXJ_NMPDTR', MODEL_FIELD_INIT, bDXJNmProd)
	oStrMala:SetProperty('DXJ_NMFAZ' , MODEL_FIELD_INIT, bDXJtNmFaz)
	oStrMala:SetProperty('DXJ_NOMCLA', MODEL_FIELD_INIT, bDXJNmClas)
	//Adiciona campo check-box para seleção da mala para bloqueio
	oStrMala:AddField('', '', 'SELEC', 'L', 1, 0,,, {}, .F.,, .F., .F., .F.,,)

	//Manipula o inicializador da padrão da tabela bloco, pois, produtor e fazenda não são obrigatórios	
	oStrBloco:SetProperty('DXD_NMPRDT', MODEL_FIELD_INIT, bDXDNmProd)
	oStrBloco:SetProperty('DXD_NMFAZ' , MODEL_FIELD_INIT, bDXDtNmFaz)

	//Adiciona campo check-box para seleção do bloco na geração
	oStrBloco:AddField('', '', 'SELEC', 'L', 1, 0,,, {}, .F.,, .F., .F., .F.,,)

	//Sub-modelo obrigatório por causa do AddFields	
	oModel:SetDescription(STR0014/*'Simulação de Emblocamento'*/ )
	oModel:AddFields('MD_FILIAL',,oStrFIL,,,{|o| {} })
	oModel:GetModel('MD_FILIAL'):SetDescription(STR0022/*'Filial'*/)
	oModel:SetPrimaryKey({})
	oModel:GetModel('MD_FILIAL'):SetOnlyQuery(.T.)

	//Sub-modelo para seleção de filiais e safra para execução			
	oModel:AddGrid('UBAA070_VT','MD_FILIAL',oStrFLSAF, , , , , bLoadGrid )
	oModel:GetModel('UBAA070_VT'):SetDescription(STR0024/*'Filial X Safra'*/)
	oModel:GetModel('UBAA070_VT'):SetOnlyQuery(.T.)
	oModel:GetModel('UBAA070_VT'):SetNoInsertLine(.T.)
	oModel:GetModel('UBAA070_VT'):SetNoDeleteLine(.T.)

	//Sub-modelo do emblocamento
	oModel:AddGrid('UBAA070_DXD','UBAA070_VT',oStrBloco,,,,,{|o|{}} )
	oModel:GetModel('UBAA070_DXD'):SetDescription(STR0011/*'Blocos'*/)
	oModel:SetRelation('UBAA070_DXD', {{'DXD_FILIAL','VT_FILIAL'},{'DXD_SAFRA','VT_CODSAF'}},DXD->(IndexKey(1)))
	oModel:GetModel('UBAA070_DXD'):SetOnlyQuery(.T.)
	oModel:SetOptional('UBAA070_DXD', .T.)

	oModel:GetModel('UBAA070_DXD'):SetNoInsertLine(.T.)
	oModel:GetModel('UBAA070_DXD'):SetNoUpdateLine(.T.)
	oModel:GetModel('UBAA070_DXD'):SetNoDeleteLine(.T.)

	//Sub-modelo de avaliação de malas
	oModel:AddGrid('UBAA070_DXJ','UBAA070_VT',oStrMala,,,,,{|o|{}}  )
	oModel:GetModel('UBAA070_DXJ'):SetDescription(STR0012/*'Malas'*/)
	oModel:SetRelation('UBAA070_DXJ', {{'DXJ_FILIAL','VT_FILIAL'},{'DXJ_SAFRA','VT_CODSAF'}},DXJ->(IndexKey(3)))
	oModel:GetModel('UBAA070_DXJ'):SetOnlyQuery(.T.)
	oModel:SetOptional('UBAA070_DXJ', .T.)

	oModel:GetModel('UBAA070_DXJ'):SetNoInsertLine(.T.)
	oModel:GetModel('UBAA070_DXJ'):SetNoUpdateLine(.T.)
	oModel:GetModel('UBAA070_DXJ'):SetNoDeleteLine(.T.)

	//Sub-modelo de Alerta de Emblocamento
	oStruN7P:SetProperty('N7P_SAFRA', MODEL_FIELD_WHEN,{|| .T. })
	oStruN7P:SetProperty('N7P_EMAIL', MODEL_FIELD_WHEN,{|| .T. })

	oStruN7P:SetProperty('N7P_SAFRA', MODEL_FIELD_OBRIGAT, .F. )
	oStruN7P:SetProperty('N7P_EMAIL', MODEL_FIELD_OBRIGAT, .F. )
	
	//Adiciona campo check-box para seleção de range de envio de email
	oStruN7T:AddField('', '', 'CHECK', 'L', 1, 0,{||ValidMar(oModel)},, {}, .F.,, .F., .F., .F.,,)

	oModel:AddFields( 'MdFieldN7P', 'UBAA070_VT', oStruN7P )
	oModel:GetModel( 'MdFieldN7P' ):SetDescription(STR0052) //Alerta de Emblocamento Físico
	oModel:SetRelation('MdFieldN7P', {{'N7P_FILIAL','VT_FILIAL'},{'N7P_SAFRA','VT_CODSAF'}},N7P->(IndexKey(1)))
	oModel:SetPrimaryKey( { "N7P_FILIAL", "N7P_SAFRA" } )
	oModel:AddGrid( 'MdGrdN7T', 'MdFieldN7P', oStruN7T)
	oModel:GetModel( 'MdGrdN7T'):SetDescription(STR0052) //Range de fardo do alerta de email
	oModel:GetModel( "MdGrdN7T"):SetOptional( .T. )
	oModel:SetRelation( 'MdGrdN7T', {{ 'N7T_FILIAL', 'N7P_FILIAL' }, { 'N7T_SAFRA', 'N7P_SAFRA' }})	

Return oModel


/*/{Protheus.doc} ViewDef
//Camada de View da Rotina
@author bruna.rocio
@since 03/08/2017
@version undefined
@type function
/*/
Static Function ViewDef()
	Local oModel    := ModelDef()
	Local oView     := FwFormView():New()
	Local oStrFLSAF := getViewStruct()
	Local oStruN7P  := FWFormStruct(2,"N7P")
	Local oStruN7T   := FWFormStruct(2,'N7T') 

	//adiciona campo de check para grid de range de email
	oStruN7T:AddField( 'CHECK' ,'01',''      ,''      ,, 'CHECK' ,,,,.T.,,,,,,,, )
	//Relaciona modelo principal à view
	oView:SetModel(oModel)

	//Remove campos da estrutura de itens de alerta de emblocamento
	oStruN7T:RemoveField('N7T_DTINCL')
	oStruN7T:RemoveField('N7T_HRINCL')
	oStruN7P:RemoveField('N7P_SAFRA')

	//Adiciona sub-modelos à view
	oView:AddGrid( 'FORM_FLSAFRA', oStrFLSAF, 'UBAA070_VT')
	oView:AddField( "VwFieldN7P", oStruN7P, "MdFieldN7P" )
	oView:AddGrid( 'VIEW_N7T', oStruN7T, 'MdGrdN7T' )

	//Adiciona outros objetos a view
	oView:AddOtherObject("FORM_BLOCO"	,{|oPanel| A070Bloco( oPanel, oView, oModel )})
	oView:AddOtherObject("FORM_MALA"	, {|oPanel| A070Mala( oPanel, oView, oModel )})
	oView:AddOtherObject("OTHER_BTN"	, {|oPanel,oModel| UBA070BTN(oPanel,oModel)}  )	//Objeto não MVC
	oView:AddOtherObject("BTN_ENV" 		, {|oPanel,oModel| BotaoEnviar(oPanel,oModel)}  )	//Botao de envio	

	//Divide a tela para a grid das filiais e folder (aval.mala;pré-embl;alerta)
	oView:CreateHorizontalBox('BOXUNICO',100)
	oView:CreateVerticalBox('BOXESQUERDA',30,'BOXUNICO')
	oView:CreateVerticalBox('BOXDIREITA' ,70,'BOXUNICO')

	//Adiciona folder ao box da direita (grid filiais)
	oView:CreateFolder('FOLDER','BOXDIREITA')

	//Adiciona pasta para avaliação de mala
	oView:AddSheet('FOLDER','ABAMALA', STR0048/*'Aval.Malas'*/, { || AtualizAba() }) 
	oView:CreateHorizontalBox( 'BOXMALA', 100, , , 'FOLDER', 'ABAMALA')

	//Adiciona pasta para pré-emblocamento
	oView:AddSheet('FOLDER','ABABLOCO',STR0015/*'Pré-Emblocamento'*/, { || AtualizAba() })
	oView:CreateHorizontalBox( 'BOXBLOCO', 100, , , 'FOLDER', 'ABABLOCO')

	//Adiciona pasta para alerta de emblocamento
	oView:AddSheet('FOLDER','ABAALERT',STR0052) //Alerta de Emblocamento

	//Cria box de cabeçalho na aba de alerta
	oView:CreateHorizontalBox( 'CABEC', 20,/*cOwner*/ , /*lFixPixel*/ , 'FOLDER', 'ABAALERT')

	//Divide box de cabeçalho em duas partes verticais
	oView:CreateVerticalBox( 'ESQUERDA', 80, 'CABEC', /*lFixPixel*/, 'FOLDER', 'ABAALERT')
	oView:CreateVerticalBox( 'DIREITA' , 20, 'CABEC', /*lFixPixel*/, 'FOLDER', 'ABAALERT')

	//Cria box de grid na aba de alerta
	oView:CreateHorizontalBox( 'GRID',  70, , , 'FOLDER', 'ABAALERT')

	//Cria box de rodape na aba de alerta
	oView:CreateHorizontalBox( 'RODAPE',10, , , 'FOLDER', 'ABAALERT')

	//Divide box de rodape em duas partes verticais
	oView:CreateVerticalBox( 'RODESQ', 80, 'RODAPE', /*lFixPixel*/, 'FOLDER', 'ABAALERT')
	oView:CreateVerticalBox( 'RODDIR' ,20, 'RODAPE', /*lFixPixel*/, 'FOLDER', 'ABAALERT')

	//Adiciona campo de auto-incremento na grid de itens do alerta de emblocamento 
	oView:AddIncrementField( 'VIEW_N7T', 'N7T_IDRANG' )

	//Habilita o título do cabeçalho de alerta de email
	oView:EnableTitleView( "VwFieldN7P" )

	//Seta a propriedade change-line para a grid de filiais/safra
	oView:SetViewProperty( 'FORM_FLSAFRA', "CHANGELINE", {{ |oModel| SetRelation(oModel) }} )

	//Identifica a qual objeto gráfico pertence cada formulário de dados 
	oView:SetOwnerView('VwFieldN7P'  , 'ESQUERDA' )
	oView:SetOwnerView('OTHER_BTN'	 , 'DIREITA' )
	oView:SetOwnerView('BTN_ENV' 	 , 'RODDIR' )
	oView:SetOwnerView('VIEW_N7T'    , 'GRID' )
	oView:SetOwnerView('FORM_FLSAFRA', 'BOXESQUERDA')
	oView:SetOwnerView('FORM_MALA'   , 'BOXMALA') 
	oView:SetOwnerView('FORM_BLOCO'  , 'BOXBLOCO') 

Return oView

/*/{Protheus.doc} getModelStruct
//Cria estrutura de modelo para filial x safra
@author bruna.rocio
@since 03/08/2017
@version undefined
@type function
/*/
Static Function getTTModelStruct()
	Local oStruct := FWFormModelStruct():New()

	oStruct:AddField(STR0022/*'Filial'*/,STR0022/*'Filial'*/, 'TT_FILIAL', 'C', TamSX3('DXD_FILIAL')[1], 0, , , {}, .F., , .F., .F., .F., , )
Return oStruct


/*/{Protheus.doc} getModelStruct
//Cria estrutura de modelo para filial x safra
@author bruna.rocio
@since 03/08/2017
@version undefined
@type function
/*/
Static Function getModelStruct()
	Local oStruct := FWFormModelStruct():New()

	oStruct:AddField(''      			   ,''      			  , 'VT_SELEC' , 'L', 1                      , 0, ,        , {}, .F., , .F., .F., .F., , )
	oStruct:AddField(STR0001/*'Safra'*/    ,STR0001/*'Safra'*/    , 'VT_CODSAF', 'C', TamSX3('NJU_CODSAF')[1], 0, ,        , {}, .F., , .F., .F., .F., , )
	oStruct:AddField(STR0022/*'Filial'*/   ,STR0022/*'Filial'*/   , 'VT_FILIAL', 'C', TamSX3('DXD_FILIAL')[1], 0, , 	   , {}, .F., , .F., .F., .F., , )
	oStruct:AddField(STR0023/*'Descrição'*/,STR0023/*'Descrição'*/, 'VT_NOME'  , 'C', 50                     , 0, ,        , {}, .T., , .F., .F., .F., , )	
Return oStruct


/*/{Protheus.doc} getViewStruct
//Cria estrutura de view para filial x safra
@author bruna.rocio
@since 03/08/2017
@version undefined
@type function
/*/
Static Function getViewStruct()
	Local oStruct := FWFormViewStruct():New()

	oStruct:AddField( 'VT_SELEC' ,'1',''      				,''      				,, 'CHECK' ,,,	   ,.T.	,,,,,,,, )
	oStruct:AddField( 'VT_CODSAF','2',STR0001/*'Safra'*/ 	,STR0001/*'Safra'*/ 	,, 'Get'   ,,,'NJU',	,,,,,,,, )
	oStruct:AddField( 'VT_FILIAL','3',STR0022/*'Filial'*/	,STR0022/*'Filial'*/	,, 'Get'   ,,,     ,	,,,,,,,, )
	oStruct:AddField( 'VT_NOME'  ,'4',STR0023/*'Descrição'*/,STR0023/*'Descrição'*/ ,, 'Get'   ,,,     ,.F.	,,,,,,,, )	
Return oStruct


/*/{Protheus.doc} StruDXDTEMP
//Retorna estrutura da tabela temporária de bloco
@author bruna.rocio
@since 14/08/2017
@version undefined
@type function
/*/
Static Function StruDXDTEMP()
	Local aDXDTEMP := {}

	aAdd(aDXDTEMP,{ "SELEC" , "C", 2, 0, , }) //Seleção
	aAdd(aDXDTEMP,{ "DXD_FILIAL", TamSX3("DXD_FILIAL")[3], TamSX3("DXD_FILIAL")[1], TamSX3("DXD_FILIAL")[2], AGRTITULO("DXD_FILIAL") , PesqPict("DXD", "DXD_FILIAL")})
	aAdd(aDXDTEMP,{ "DXD_SAFRA" , TamSX3("DXD_SAFRA")[3],  TamSX3("DXD_SAFRA")[1],  TamSX3("DXD_SAFRA")[2] , AGRTITULO("DXD_SAFRA")  , PesqPict("DXD", "DXD_SAFRA") })
	aAdd(aDXDTEMP,{ "DXD_CODIGO", TamSX3("DXD_CODIGO")[3], TamSX3("DXD_CODIGO")[1], TamSX3("DXD_CODIGO")[2], AGRTITULO("DXD_CODIGO") , PesqPict("DXD", "DXD_CODIGO")})
	aAdd(aDXDTEMP,{ "DXD_CODSEQ", TamSX3("DXD_CODIGO")[3], TamSX3("DXD_CODIGO")[1], TamSX3("DXD_CODIGO")[2], AGRTITULO("DXD_CODIGO") , PesqPict("DXD", "DXD_CODIGO")})
	aAdd(aDXDTEMP,{ "DXD_CLACOM", TamSX3("DXD_CLACOM")[3], TamSX3("DXD_CLACOM")[1], TamSX3("DXD_CLACOM")[2], AGRTITULO("DXD_CLACOM") , PesqPict("DXD", "DXD_CLACOM")})
	aAdd(aDXDTEMP,{ "DXD_DSCREG", TamSX3("N80_NMEMBL")[3], TamSX3("N80_NMEMBL")[1], TamSX3("N80_NMEMBL")[2], AGRTITULO("N80_NMEMBL") , PesqPict("N80", "N80_NMEMBL")})
	Aadd(aDXDTEMP,{ "PCTFOR"    , TamSX3("DXD_PCTFOR")[3], TamSX3("DXD_PCTFOR")[1], TamSX3("DXD_PCTFOR")[2], AGRTITULO("DXD_PCTFOR") , PesqPict("DXD", "DXD_PCTFOR")})
	aAdd(aDXDTEMP,{ "DXD_QTDVNC", TamSX3("DXD_QTDVNC")[3], TamSX3("DXD_QTDVNC")[1], TamSX3("DXD_QTDVNC")[2], AGRTITULO("DXD_QTDVNC") , PesqPict("DXD", "DXD_QTDVNC")}) 
	aAdd(aDXDTEMP,{ "DXD_PRDTOR", TamSX3("DXD_PRDTOR")[3], TamSX3("DXD_PRDTOR")[1], TamSX3("DXD_PRDTOR")[2], AGRTITULO("DXD_PRDTOR") , PesqPict("DXD", "DXD_PRDTOR")})
	aAdd(aDXDTEMP,{ "DXD_LJPRO" , TamSX3("DXD_LJPRO")[3] , TamSX3("DXD_LJPRO")[1],  TamSX3("DXD_LJPRO")[2] , AGRTITULO("DXD_LJPRO")  , PesqPict("DXD", "DXD_LJPRO") })
	aAdd(aDXDTEMP,{ "DXD_NMPRDT", TamSX3("DXD_NMPRDT")[3], TamSX3("DXD_NMPRDT")[1], TamSX3("DXD_NMPRDT")[2], AGRTITULO("DXD_NMPRDT") , PesqPict("DXD", "DXD_NMPRDT")})
	aAdd(aDXDTEMP,{ "DXD_FAZ"   , TamSX3("DXD_FAZ")[3]   , TamSX3("DXD_FAZ")[1]   , TamSX3("DXD_FAZ")[2]   , AGRTITULO("DXD_FAZ")    , PesqPict("DXD", "DXD_FAZ")   })
	aAdd(aDXDTEMP,{ "DXD_NMFAZ" , TamSX3("DXD_NMFAZ")[3] , TamSX3("DXD_NMFAZ")[1] , TamSX3("DXD_NMFAZ")[2] , AGRTITULO("DXD_NMFAZ")  , PesqPict("DXD", "DXD_NMFAZ") })
	aAdd(aDXDTEMP,{ "DXD_FDINI" , TamSX3("DXD_FDINI")[3] , TamSX3("DXD_FDINI")[1] , TamSX3("DXD_FDINI")[2] , AGRTITULO("DXD_FDINI")  , PesqPict("DXD", "DXD_FDINI") })
	aAdd(aDXDTEMP,{ "DXD_FDFIN" , TamSX3("DXD_FDFIN")[3] , TamSX3("DXD_FDFIN")[1] , TamSX3("DXD_FDFIN")[2] , AGRTITULO("DXD_FDFIN")  , PesqPict("DXD", "DXD_FDFIN") })
	aAdd(aDXDTEMP,{ "DXD_CODREG", TamSX3("DXD_CODREG")[3], TamSX3("DXD_CODREG")[1], TamSX3("DXD_CODREG")[2], AGRTITULO("DXD_CODREG") , PesqPict("DXD", "DXD_CODREG")})
	aAdd(aDXDTEMP,{ "DXD_QTDFRM", TamSX3("DXD_QTDMAX")[3], TamSX3("DXD_QTDMAX")[1], TamSX3("DXD_QTDMAX")[2], STR0031 				 , PesqPict("DXD", "DXD_QTDMAX")}) //Qtde.Max com % de Formação	
	aAdd(aDXDTEMP,{ "DXD_QTDMAX", TamSX3("DXD_QTDMAX")[3], TamSX3("DXD_QTDMAX")[1], TamSX3("DXD_QTDMAX")[2], AGRTITULO("DXD_QTDMAX") , PesqPict("DXD", "DXD_QTDMAX")}) //Qtde.Max
	Aadd(aDXDTEMP,{ "DXD_RELEVA", "N", TamSX3( "N80_RELEVA" )[ 1 ] , 0 , STR0006, "@E 99" })                     //Relevância
	Aadd(aDXDTEMP,{ "DXD_NOVO"  , "C", 1 , 0 , STR0090, "@!"}) //Indica se é um novo bloco ou se já é um bloco persistido 1=Sim/2=Não  //"Bloco Novo"
	aAdd(aDXDTEMP,{ "DX7_MIC"   , TamSX3("DX7_MIC")[3], TamSX3("DX7_MIC")[1], TamSX3("DX7_MIC")[2], AGRTITULO("DX7_MIC") ,PesqPict("DX7", "DX7_MIC") }) 
	aAdd(aDXDTEMP,{ "DX7_UHM"   , TamSX3("DX7_UHM")[3], TamSX3("DX7_UHM")[1], TamSX3("DX7_UHM")[2], AGRTITULO("DX7_UHM") ,PesqPict("DX7", "DX7_UHM") }) 
	aAdd(aDXDTEMP,{ "DX7_RES"   , TamSX3("DX7_RES")[3], TamSX3("DX7_RES")[1], TamSX3("DX7_RES")[2], AGRTITULO("DX7_RES") ,PesqPict("DX7", "DX7_RES") }) 	
	aAdd(aDXDTEMP,{ "DXD_CODUNB", TamSX3("DXD_CODUNB")[3], TamSX3("DXD_CODUNB")[1], TamSX3("DXD_CODUNB")[2], AGRTITULO("DXD_CODUNB") ,PesqPict("DXD", "DXD_CODUNB") })	
	Aadd(aDXDTEMP,{ "DXD_STATUS", TamSX3("DXD_STATUS")[3], TamSX3("DXD_STATUS")[1], TamSX3("DXD_STATUS")[2], AGRTITULO("DXD_STATUS") ,PesqPict("DXD", "DXD_STATUS") })	//Status

Return aDXDTEMP


/*/{Protheus.doc} StruDXJTEMP
//Retorna estrutura da tabela temporária de malas
@author brunosilva
@since 15/08/2017
@version undefined
@type function
/*/
Static Function StruDXJTEMP()
	Local aDXJTEMP := {}
	Local nX       := 0
	Local cLabel   := "% Reg."
	Local cCampo   := "DXJ_PCRG"

	aAdd(aDXJTEMP,{ "SELEC" , "C", 2, 0, , }) //Seleção
	aAdd(aDXJTEMP,{ "DXJ_FILIAL", TamSX3("DXJ_FILIAL")[3], TamSX3("DXJ_FILIAL")[1], TamSX3("DXJ_FILIAL")[2], AGRTITULO("DXJ_FILIAL"), PesqPict("DXJ", "DXJ_FILIAL")})
	aAdd(aDXJTEMP,{ "DXJ_SAFRA" , TamSX3("DXJ_SAFRA")[3] , TamSX3("DXJ_SAFRA")[1] , TamSX3("DXJ_SAFRA")[2] , AGRTITULO("DXJ_SAFRA") , PesqPict("DXJ", "DXJ_SAFRA")})
	aAdd(aDXJTEMP,{ "DXJ_CODIGO", TamSX3("DXJ_CODIGO")[3], TamSX3("DXJ_CODIGO")[1], TamSX3("DXJ_CODIGO")[2], AGRTITULO("DXJ_CODIGO"), PesqPict("DXJ", "DXJ_CODIGO")})
	aAdd(aDXJTEMP,{ "DXJ_QTVINC", TamSX3("DXJ_QTVINC")[3], TamSX3("DXJ_QTVINC")[1], TamSX3("DXJ_QTVINC")[2], AGRTITULO("DXJ_QTVINC"), PesqPict("DXJ", "DXJ_QTVINC")})
	aAdd(aDXJTEMP,{ "DXJ_FRDINI", TamSX3("DXJ_FRDINI")[3], TamSX3("DXJ_FRDINI")[1], TamSX3("DXJ_FRDINI")[2], AGRTITULO("DXJ_FRDINI"), PesqPict("DXJ", "DXJ_FRDINI")})
	aAdd(aDXJTEMP,{ "DXJ_FRDFIM", TamSX3("DXJ_FRDFIM")[3], TamSX3("DXJ_FRDFIM")[1], TamSX3("DXJ_FRDFIM")[2], AGRTITULO("DXJ_FRDFIM"), PesqPict("DXJ", "DXJ_FRDFIM")})
	For nX := 1 to __nMaxCols
		aAdd(aDXJTEMP,{ cCampo+cValToChar(nX), "N", 6, 2, cLabel+cValToChar(nX) , "@E 999.99"})
	Next nX
	
Return aDXJTEMP


/*/{Protheus.doc} StruDXKTEMP
//Retorna estrutura da tabela temporarias de fardos das malas
@author bruna.rocio
@since 15/08/2017
@version undefined
@type function
/*/
Static Function StruDXKTEMP()
	Local aDXKTEMP := {}

	aAdd(aDXKTEMP,{ "DXK_ALERTA", "C", 1, 0, , })
	aAdd(aDXKTEMP,{ "DXK_FILIAL", TamSX3("DXK_FILIAL")[3], TamSX3("DXK_FILIAL")[1], TamSX3("DXK_FILIAL")[2], AGRTITULO("DXK_FILIAL"), PesqPict("DXK", "DXK_FILIAL")})
	aAdd(aDXKTEMP,{ "DXK_SAFRA" , TamSX3("DXK_SAFRA")[3] , TamSX3("DXK_SAFRA")[1] , TamSX3("DXK_SAFRA")[2] , AGRTITULO("DXK_SAFRA") , PesqPict("DXK", "DXK_SAFRA")})
	aAdd(aDXKTEMP,{ "DXK_CODROM", TamSX3("DXK_CODROM")[3], TamSX3("DXK_CODROM")[1], TamSX3("DXK_CODROM")[2], AGRTITULO("DXK_CODROM"), PesqPict("DXK", "DXK_CODROM")})
	aAdd(aDXKTEMP,{ "DXK_ETIQ"  , TamSX3("DXK_ETIQ")[3]  , TamSX3("DXK_ETIQ")[1]  , TamSX3("DXK_ETIQ")[2]  , AGRTITULO("DXK_ETIQ")  , PesqPict("DXK", "DXK_ETIQ")})
	aAdd(aDXKTEMP,{ "DXK_FARDO" , TamSX3("DXK_FARDO")[3] , TamSX3("DXK_FARDO")[1] , TamSX3("DXK_FARDO")[2] , AGRTITULO("DXK_FARDO") , PesqPict("DXK", "DXK_FARDO")})
	aAdd(aDXKTEMP,{ "DXK_PSLIQU", TamSX3("DXK_PSLIQU")[3], TamSX3("DXK_PSLIQU")[1], TamSX3("DXK_PSLIQU")[2], AGRTITULO("DXK_PSLIQU"), PesqPict("DXK", "DXK_PSLIQU")})
	aAdd(aDXKTEMP,{ "DXK_PSBRUT", TamSX3("DXK_PSBRUT")[3], TamSX3("DXK_PSBRUT")[1], TamSX3("DXK_PSBRUT")[2], AGRTITULO("DXK_PSBRUT"), PesqPict("DXK", "DXK_PSBRUT")})

	aAdd(aDXKTEMP,{ "DX7_SCI"   , TamSX3("DX7_SCI")[3]   , TamSX3("DX7_SCI")[1]   , TamSX3("DX7_SCI")[2]  , AGRTITULO("DX7_SCI")  , PesqPict("DX7", "DX7_SCI")})
	aAdd(aDXKTEMP,{ "DX7_MATU"  , TamSX3("DX7_MATU")[3]  , TamSX3("DX7_MATU")[1]  , TamSX3("DX7_MATU")[2] , AGRTITULO("DX7_MATU") , PesqPict("DX7", "DX7_MATU")})
	aAdd(aDXKTEMP,{ "DX7_UHM"   , TamSX3("DX7_UHM")[3]   , TamSX3("DX7_UHM")[1]   , TamSX3("DX7_UHM")[2]  , AGRTITULO("DX7_UHM")  , PesqPict("DX7", "DX7_UHM")})
	aAdd(aDXKTEMP,{ "DX7_COUNT" , TamSX3("DX7_COUNT")[3] , TamSX3("DX7_COUNT")[1] , TamSX3("DX7_COUNT")[2], AGRTITULO("DX7_COUNT"), PesqPict("DX7", "DX7_COUNT")})
	aAdd(aDXKTEMP,{ "DX7_RD"    , TamSX3("DX7_RD")[3]    , TamSX3("DX7_RD")[1]    , TamSX3("DX7_RD")[2]   , AGRTITULO("DX7_RD")   , PesqPict("DX7", "DX7_RD")})

	aAdd(aDXKTEMP,{ "DX7_MAISB", TamSX3("DX7_MAISB")[3]  , TamSX3("DX7_MAISB")[1] , TamSX3("DX7_MAISB")[2], AGRTITULO("DX7_MAISB"), PesqPict("DX7", "DX7_MAISB")})
	aAdd(aDXKTEMP,{ "DX7_CG"   , TamSX3("DX7_CG")[3]     , TamSX3("DX7_CG")[1]    , TamSX3("DX7_CG")[2]   , AGRTITULO("DX7_CG")   , PesqPict("DX7", "DX7_CG")})
	aAdd(aDXKTEMP,{ "DX7_CSP"  , TamSX3("DX7_CSP")[3]    , TamSX3("DX7_CSP")[1]   , TamSX3("DX7_CSP")[2]  , AGRTITULO("DX7_CSP")  , PesqPict("DX7", "DX7_CSP")})
	aAdd(aDXKTEMP,{ "DX7_AREA" , TamSX3("DX7_AREA")[3]   , TamSX3("DX7_AREA")[1]  , TamSX3("DX7_AREA")[2] , AGRTITULO("DX7_AREA") , PesqPict("DX7", "DX7_AREA")})
	aAdd(aDXKTEMP,{ "DX7_ELONG", TamSX3("DX7_ELONG")[3]  , TamSX3("DX7_ELONG")[1] , TamSX3("DX7_ELONG")[2], AGRTITULO("DX7_ELONG"), PesqPict("DX7", "DX7_ELONG")})

	aAdd(aDXKTEMP,{ "DX7_SFI"  , TamSX3("DX7_SFI")[3]    , TamSX3("DX7_SFI")[1]   , TamSX3("DX7_SFI")[2]  , AGRTITULO("DX7_SFI")  , PesqPict("DX7", "DX7_SFI")})
	aAdd(aDXKTEMP,{ "DX7_UI"   , TamSX3("DX7_UI")[3]     , TamSX3("DX7_UI")[1]    , TamSX3("DX7_UI")[2]   , AGRTITULO("DX7_UI")   , PesqPict("DX7", "DX7_UI")})
	aAdd(aDXKTEMP,{ "DX7_FIBRA", TamSX3("DX7_FIBRA")[3]  , TamSX3("DX7_FIBRA")[1] , TamSX3("DX7_FIBRA")[2], AGRTITULO("DX7_FIBRA"), PesqPict("DX7", "DX7_FIBRA")})
	aAdd(aDXKTEMP,{ "DX7_RES"  , TamSX3("DX7_RES")[3]    , TamSX3("DX7_RES")[1]   , TamSX3("DX7_RES")[2]  , AGRTITULO("DX7_RES")  , PesqPict("DX7", "DX7_RES")})
	aAdd(aDXKTEMP,{ "DX7_MIC"  , TamSX3("DX7_MIC")[3]    , TamSX3("DX7_MIC")[1]   , TamSX3("DX7_MIC")[2]  , AGRTITULO("DX7_MIC")  , PesqPict("DX7", "DX7_MIC")})
	aAdd(aDXKTEMP,{ "DX7_LEAF" , TamSX3("DX7_LEAF")[3]   , TamSX3("DX7_LEAF")[1]  , TamSX3("DX7_LEAF")[2] , AGRTITULO("DX7_LEAF") , PesqPict("DX7", "DX7_LEAF")})

Return aDXKTEMP

/*/{Protheus.doc} PrepareTT
//Cria arquivo temporario 
@author carlos.augusto
@since 07/06/2017
@version 12.1.20
@type function
/*/
Static Function PrepareTT(cAliasTT, aStruct, aIndex)
	Local oObjTT

	oObjTT := AGRCRTPTB(cAliasTT, {aStruct, aIndex }) 

Return oObjTT


/*/{Protheus.doc} RegDinamica
//Altera a descrição com os nomes das regras de avaliação de mala e remove ou recupera as colunas de regras
@author bruna.rocio
@since 20/08/2017
@version undefined
@type function
/*/
Static Function RegDinamica(oModel, cFilSel)
	Local aLines    := FwSaveRows()
	Local cAliasReg := GetNextAlias() 
	Local cLabel    := "% "
	Local nIndice   := 8 //indice da primeira coluna de regras
	Local nX        := 0
	Local nRegFil	:= 0 //num de regras da filial

	If  FWModeAccess("N80",1)='C'
		BeginSql Alias cAliasReg
		  Select N80_RELEVA, N80_NMEMBL 
			From %table:N80% N80
		   where N80.%notDel%
			 and N80.N80_FILIAL = %xFilial:N80%
			 and N80.N80_TIPEMB = '2'
		ORDER BY N80.N80_RELEVA
		EndSql
	Else	
		BeginSql Alias cAliasReg
		  Select N80_RELEVA, N80_NMEMBL From %table:N80% N80
		   where N80.%notDel%
		     and N80.N80_FILIAL = %exp:cFilSel%
			 and N80.N80_TIPEMB = '2'
		ORDER BY N80.N80_RELEVA
		EndSql		
	Endif
	
	dbSelectArea(cAliasReg)  
	(cAliasReg)->(dbGoTop())

	//Laço para atualizar a descrição das colunas de regras de avaliação de malas
	While (cAliasReg)->(!Eof())
		__oBrwMala:AColumns[nIndice + nRegFil]:cTitle := cLabel + AllTrim((cAliasReg)->N80_NMEMBL)
		nRegFil++		
		(cAliasReg)->(dbSkip())
	EndDo

	For nX := (nIndice) to (Len(__oBrwMala:AColumns) ) //Voltar todas as colunas de regras
		__oBrwMala:RecoveryColumn(nX)
	Next nX
			
	If __nMaxCols > nRegFil //Remover as desnecessarias
		For nX := (nIndice + nRegFil) to (Len(__oBrwMala:AColumns) ) 
			__oBrwMala:DelColumn(nX)
		Next nX
	EndIf

	__oBrwMala:UpdateBrowse()
	__oBrwMala:Save()
	FwRestRows(aLines)
Return 

/*/{Protheus.doc} GetNumRegras
//Função responsável por retornar o número de colunas que a tabela de malas precisará para armanezar as regras
@author bruna.rocio
@since 21/08/2017
@version undefined
@type function
/*/
Static Function GetNumRegras()
	Local aLines     := FwSaveRows()
	Local oModel    := FwModelActive()
	Local oGridVT   := oModel:GetModel('UBAA070_VT')
	Local cAliasReg 
	Local nNum      := 0
	Local nX        := 0

	For nX := 1 to oGridVT:Length()
		oGridVT:GoLine(nX)
		
		cAliasReg := GetNextAlias()
		
		BeginSql Alias cAliasReg
		  Select count(*) AS numRegras 
		    From %table:N80% N80
		   where N80.%notDel%
		     and N80.N80_TIPEMB = '2'
		EndSql	

		If (cAliasReg)->(!Eof())

			If (cAliasReg)->numRegras > nNum
				nNum := (cAliasReg)->numRegras
			Endif

			(cAliasReg)->(dbSkip())
		EndIf
		(cAliasReg)->(dbCloseArea())
	Next nX

	FwRestRows(aLines)
Return nNum

/*/{Protheus.doc} DXDFilter
//Responsável por montar a estrutura do array que será usado no filtro do browse.
@author brunosilva
@since 14/08/2017
@version undefined

@type function
/*/
Static Function DXDFilter()

	aAdd(__aFieldFilter, {"DXD_FILIAL", AGRTITULO("DXD_FILIAL") ,TamSX3("DXD_FILIAL")[3], TamSX3("DXD_FILIAL")[1], TamSX3("DXD_FILIAL")[2], PesqPict("DXD", "DXD_FILIAL")} )
	aAdd(__aFieldFilter, {"DXD_SAFRA",  AGRTITULO("DXD_SAFRA")  ,TamSX3("DXD_SAFRA")[3],  TamSX3("DXD_SAFRA")[1],  TamSX3("DXD_SAFRA")[2] , PesqPict("DXD", "DXD_SAFRA") } )
	aAdd(__aFieldFilter, {"DXD_CODIGO", AGRTITULO("DXD_CODIGO") ,TamSX3("DXD_CODIGO")[3], TamSX3("DXD_CODIGO")[1], TamSX3("DXD_CODIGO")[2], PesqPict("DXD", "DXD_CODIGO")} )
	aAdd(__aFieldFilter, {"DXD_CODSEQ", AGRTITULO("DXD_CODIGO") ,TamSX3("DXD_CODIGO")[3], TamSX3("DXD_CODIGO")[1], TamSX3("DXD_CODIGO")[2], PesqPict("DXD", "DXD_CODIGO")} )
	aAdd(__aFieldFilter, {"DXD_CLACOM", AGRTITULO("DXD_CLACOM") ,TamSX3("DXD_CLACOM")[3], TamSX3("DXD_CLACOM")[1], TamSX3("DXD_CLACOM")[2], PesqPict("DXD", "DXD_CLACOM")} )
	aAdd(__aFieldFilter, {"DXD_PRDTOR", AGRTITULO("DXD_PRDTOR") ,TamSX3("DXD_PRDTOR")[3], TamSX3("DXD_PRDTOR")[1], TamSX3("DXD_PRDTOR")[2], PesqPict("DXD", "DXD_PRDTOR")} )
	aAdd(__aFieldFilter, {"DXD_LJPRO",  AGRTITULO("DXD_LJPRO")  ,TamSX3("DXD_LJPRO")[3],  TamSX3("DXD_LJPRO")[1],  TamSX3("DXD_LJPRO")[2] , PesqPict("DXD", "DXD_LJPRO") } )
	aAdd(__aFieldFilter, {"DXD_NMPRDT", AGRTITULO("DXD_NMPRDT") ,TamSX3("DXD_NMPRDT")[3], TamSX3("DXD_NMPRDT")[1], TamSX3("DXD_NMPRDT")[2], PesqPict("DXD", "DXD_NMPRDT")} )
	aAdd(__aFieldFilter, {"DXD_FAZ",    AGRTITULO("DXD_FAZ")    ,TamSX3("DXD_FAZ")[3],    TamSX3("DXD_FAZ")[1],    TamSX3("DXD_FAZ")[2]   , PesqPict("DXD", "DXD_FAZ")   } )
	aAdd(__aFieldFilter, {"DXD_NMFAZ",  AGRTITULO("DXD_NMFAZ")  ,TamSX3("DXD_NMFAZ")[3],  TamSX3("DXD_NMFAZ")[1],  TamSX3("DXD_NMFAZ")[2] , PesqPict("DXD", "DXD_NMFAZ") } )
	aAdd(__aFieldFilter, {"DXD_FDINI",  AGRTITULO("DXD_FDINI")  ,TamSX3("DXD_FDINI")[3],  TamSX3("DXD_FDINI")[1],  TamSX3("DXD_FDINI")[2] , PesqPict("DXD", "DXD_FDINI") } )
	aAdd(__aFieldFilter, {"DXD_FDFIN",  AGRTITULO("DXD_FDFIN")  ,TamSX3("DXD_FDFIN")[3],  TamSX3("DXD_FDFIN")[1],  TamSX3("DXD_FDFIN")[2] , PesqPict("DXD", "DXD_FDFIN") } )
	aAdd(__aFieldFilter, {"DXD_CODREG", AGRTITULO("DXD_CODREG") ,TamSX3("DXD_CODREG")[3], TamSX3("DXD_CODREG")[1], TamSX3("DXD_CODREG")[2], PesqPict("DXD", "DXD_CODREG")} )
	aAdd(__aFieldFilter, {"DXD_DSCREG", AGRTITULO("N80_NMEBL")  ,TamSX3("N80_NMEMBL")[3],  TamSX3("N80_NMEMBL")[1],TamSX3("N80_NMEMBL")[2] , PesqPict("N80", "N80_NMEMBL") })

Return __aFieldFilter


/*/{Protheus.doc} DXJFilter
//Responsável por montar a estrutura do array que será usado no filtro do browse.
@author brunosilva
@since 14/08/2017
@version undefined

@type function
/*/
Static Function DXJFilter()

	aAdd(__aMalaFilter, {"DXJ_FILIAL", AGRTITULO("DXJ_FILIAL"),TamSX3("DXJ_FILIAL")[3], TamSX3("DXJ_FILIAL")[1], TamSX3("DXJ_FILIAL")[2], PesqPict("DXJ", "DXJ_FILIAL")} )
	aAdd(__aMalaFilter, {"DXJ_SAFRA" , AGRTITULO("DXJ_SAFRA") ,TamSX3("DXJ_SAFRA")[3] , TamSX3("DXJ_SAFRA")[1] , TamSX3("DXJ_SAFRA")[2] , PesqPict("DXJ", "DXJ_SAFRA")} )
	aAdd(__aMalaFilter, {"DXJ_CODIGO", AGRTITULO("DXJ_CODIGO"),TamSX3("DXJ_CODIGO")[3], TamSX3("DXJ_CODIGO")[1], TamSX3("DXJ_CODIGO")[2], PesqPict("DXJ", "DXJ_CODIGO")} )
	aAdd(__aMalaFilter, {"DXJ_FRDINI", AGRTITULO("DXJ_FRDINI"),TamSX3("DXJ_FRDINI")[3], TamSX3("DXJ_FRDINI")[1], TamSX3("DXJ_FRDINI")[2], PesqPict("DXJ", "DXJ_FRDINI")} )
	aAdd(__aMalaFilter, {"DXJ_FRDFIM", AGRTITULO("DXJ_FRDFIM"),TamSX3("DXJ_FRDFIM")[3], TamSX3("DXJ_FRDFIM")[1], TamSX3("DXJ_FRDFIM")[2], PesqPict("DXJ", "DXJ_FRDFIM")} )
	aAdd(__aMalaFilter, {"DXJ_QTVINC", AGRTITULO("DXJ_QTVINC"),TamSX3("DXJ_QTVINC")[3], TamSX3("DXJ_QTVINC")[1], TamSX3("DXJ_QTVINC")[2], PesqPict("DXJ", "DXJ_QTVINC")} )
Return __aMalaFilter



/*/{Protheus.doc} FLSafraLoad
//Função responsável pela carga de dados de filial x safra
@author bruna.rocio
@since 04/08/2017
@version undefined
@type function
/*/
Static Function FLSafraLoad(oGridModel, lCopy)
	Local aArea   := GetArea()
	Local aLoad   := Array(0)
	Local aRetSM0 := Array(0)
	Local nX      := 0
	Local cSafra  := Space(TamSX3('NJU_CODSAF')[1])

	Pergunte('UBAA070002', .F.)

	If .Not. Empty(__cSafraPar)
		cSafra := __cSafraPar
	ElseIf !Empty(MV_PAR01)
		cSafra := MV_PAR01
	Endif

	//Retorna todas as filiais disponíveis para o usuário
	aRetSM0    := FWAllFilial(FWCompany(),FWUnitBusiness(),cEmpAnt,.F.)

	//Adiciona os dados no array de retorno
	For nX := 1 to Len(aRetSM0)
		aAdd(aLoad, {nX,{ .F. , cSafra, aRetSM0[nX], FWFilName(cEmpAnt,aRetSM0[nX])}})
	Next nX

	RestArea(aArea)
Return aLoad

/*/{Protheus.doc} GatilhoPergunte
//Função de gatilho para pergunte
@author joaquim.burjack
@since 26/06/2017
@version undefined

@type function
/*/
Static Function GatilhoPergunte(lVisivel)
	Local aArea   := GetArea()
	Local aSaveLines := FWSaveRows()
	Local nZ
	Local oModel  := FwModelActive()
	Local cSafra  := Space(TamSX3('NJU_CODSAF')[1])
	Local lOk	  := .F.
	Local oGridVT := oModel:GetModel('UBAA070_VT')

	oGridVT := oModel:GetModel('UBAA070_VT')

	If lVisivel
		lOk := Pergunte('UBAA070002', lVisivel)		

		If !Empty(MV_PAR01)
			cSafra := MV_PAR01
		Endif

		For nZ := 1 to oGridVT:Length()
			oGridVT:GoLine(nZ)
			If !oGridVT:IsDeleted()
				oGridVT:LoadValue('VT_CODSAF',cSafra)
			Endif
		Next nZ

		If lOk
			FwRestRows(aSaveLines)
			UBAA070COL()
		EndIf
	Endif
	RestArea(aArea)
Return

/*/{Protheus.doc} A070MBLine
//Marca ou desmarca um item do grid
@author carlos.augusto
@since 21/06/2017
@version 12.1.20

@type function
/*/
Static Function A070MBLine(cAliasBrw)

	If !(cAliasBrw)->( Eof() )		
		RecLock(cAliasBrw, .F.)
		(cAliasBrw)->SELEC := IIf((cAliasBrw)->SELEC = __cMarca,' ',__cMarca)
		MsUnlock(cAliasBrw)
	EndIf	
Return .T.

/*/{Protheus.doc} A070MBAll
//Marca ou desmarca todos itens do grid
@author carlos.augusto
@since 21/06/2017
@version 12.1.20

@type function
/*/
Static Function A070MBAll(cAliasBrw,oBrw)
	Local aSaveLines := FWSaveRows()

	dbSelectArea(cAliasBrw)
	(cAliasBrw)->( dbGoTop() )
	While !(cAliasBrw)->( Eof() )

		RecLock(cAliasBrw,.f.)
		(cAliasBrw)->SELEC := IIf((cAliasBrw)->SELEC = __cMarca,' ',__cMarca)
		MsUnLock(cAliasBrw)

		(cAliasBrw)->( dbSkip() )
	EndDo

	(cAliasBrw)->( dbGoTop() )

	oBrw:Refresh()
	FwRestRows(aSaveLines)
Return


/*/{Protheus.doc} A070Bloco
//Função para criação da grid de simulação de emblocamento
@author bruna.rocio
@since 14/08/2017
@version undefined
@param oPanel, object, descricao
@param oView, object, descricao
@param oModel, object, descricao
@type function
/*/
Static Function A070Bloco( oPanel, oView, oModel )
	Local aColunaBloco := {}
	Local nCol         := 0
	Local aIndex       := {}
	Local aStrBloco    := StruDXDTEMP()
	Local nX           := 0
    Local aSeek        := {} 
    Local nTam
    
	aAdd(aIndex,{"1","DXD_FILIAL,DXD_SAFRA,DXD_CODREG,DXD_CLACOM,DXD_STATUS,DXD_PRDTOR,DXD_LJPRO,DXD_FAZ" })
	aAdd(aIndex,{"2","DXD_FILIAL,DXD_SAFRA,DXD_CODREG,DXD_CLACOM,DXD_CODSEQ" })
	aAdd(aIndex,{"3","DXD_FILIAL,DXD_SAFRA,DXD_NOVO" })
	aAdd(aIndex,{"4","DXD_FILIAL,DXD_CODREG" })
	aAdd(aIndex,{"5","DXD_FILIAL,DXD_RELEVA" })


	__DXDTEMP  := GetNextAlias()
	__oDXDTEMP := PrepareTT(__DXDTEMP, aStrBloco, aIndex)

	//Criação e instância do browse de blocos
	__oBrwBloco := FWFormBrowse():New()
	__oBrwBloco:SetOwner(oPanel)
	__oBrwBloco:SetDataTable(.T.)
	__oBrwBloco:SetTemporary(.T.)
	__oBrwBloco:SetAlias(__DXDTEMP)
	__oBrwBloco:SetDescription(STR0015) /*"Pré-Emblocamento"*/
	__oBrwBloco:SetProfileID("__oBrwBloco")

	//monta botão filtrar 
	DXDFilter()
	__oBrwBloco:SetUseFilter(.T.)
	__oBrwBloco:SetUseCaseFilter(.T.)
	__oBrwBloco:SetFieldFilter(__aFieldFilter)
	__oBrwBloco:SetDBFFilter(.T.)
	
	ADD MARKCOLUMN oColumn DATA { || If((__DXDTEMP)->SELEC == __cMarca,'LBOK','LBNO') }  ;
	DOUBLECLICK { |__oBrwBloco| A070MBLine(__DXDTEMP) } ;
	HEADERCLICK { |__oBrwBloco| A070MBAll(__DXDTEMP, @__oBrwBloco) } OF __oBrwBloco		

	// Monta colunas desconsiderando os campos abaixo
	nCol := 1
	For nx := 1 to Len(aStrBloco)

		If !(aStrBloco[nX,1] $ "SELEC,DXD_QTDFRM,DXD_QTDMAX")
			AAdd(aColunaBloco,FWBrwColumn():New())
			aColunaBloco[nCol]:SetData(&("{||"+aStrBloco[nX,1]+"}"))
			aColunaBloco[nCol]:SetTitle(aStrBloco[nX,5])
			aColunaBloco[nCol]:SetPicture(aStrBloco[nX,6])
			aColunaBloco[nCol]:SetType(aStrBloco[nX,2])
			aColunaBloco[nCol]:SetSize(aStrBloco[nX,3])
			aColunaBloco[nCol]:SetReadVar(aStrBloco[nX,1])
			nCol++
		Endif
	Next nX
    
    	//monta "chave" do pesquisar
	nTam := TamSX3("DXD_FILIAL")[1] + TamSX3("DXD_SAFRA")[1] + TamSX3("DXD_CODREG")[1] + TamSX3("DXD_CLACOM")[1] + TamSX3("DXD_STATUS")[1] + TamSX3("DXD_PRDTOR")[1] + TamSX3("DXD_LJPRO")[1]  + TamSX3("DXD_FAZ")[1]
	Aadd(aSeek,{STR0087 ,{{"", 'C' , nTam, 0 , "@!" }}, 1, .T. } ) //Filial+Safra+Regra+Class+Status+Produtor+Loja+Fazenda
	
		
	__oBrwBloco:SetSeek( ,aSeek)
	
	__oBrwBloco:SetColumns(aColunaBloco)
	__oBrwBloco:SetDoubleClick({|| DetBloco((__DXDTEMP)->DXD_FILIAL,(__DXDTEMP)->DXD_SAFRA,(__DXDTEMP)->DXD_CODSEQ) })	
	__oBrwBloco:AddButton(STR0028/*'&Processar'*/,{|| SimularEmb(oModel) },,2,0,.T.,3,,)
	__oBrwBloco:AddButton(STR0035/*'&Gerar'*/    ,{||Processa( {||PersisteEmbl(@__oBrwBloco,oModel)}, STR0077)},,2,0,.T.,3,,)//"Aguarde. Gerando blocos."
	__oBrwBloco:DisableDetails()				
	__oBrwBloco:Activate()

	//Analisar as colunas produtor e fazenda
	UBAA070COL()

Return 

/*/{Protheus.doc} A070Mala
//Painel com objeto de grid de avaliação de mala
@author brunosilva
@since 15/08/2017
@version undefined
@param oPanel, object, descricao
@param oView, object, descricao
@param oModel, object, descricao
@type function
/*/
Static Function A070Mala( oPanel, oView, oModel )
	Local aColunaMala := {}
	Local nCol        := 0
	Local nX          := 0 
	Local aStrDXJ    
	Local aStrDXK    
	Local aSeek        := {} 

	//Busca número máximo de regras
	__nMaxCols     := GetNumRegras()

	//Busca a estrutura das tabelas temporárias
	aStrDXJ    := StruDXJTEMP()
	aStrDXK    := StruDXKTEMP()

	//Tabela Temporária de Rom.Clas/Mala
	__DXJTEMP := GetNextAlias()
	__oDXJTEMP := FwTemporaryTable():New(__DXJTEMP)
	__oDXJTEMP:SetFields(aStrDXJ)
	__oDXJTEMP:AddIndex("1",{"DXJ_FILIAL","DXJ_SAFRA","DXJ_CODIGO"})
	__oDXJTEMP:Create()

	//Tabela Temporária de It.Rom.Clas/Fardinho da Mala
	__DXKTEMP := GetNextAlias()
	__oDXKTEMP := FwTemporaryTable():New(__DXKTEMP)
	__oDXKTEMP:SetFields(aStrDXK)
	__oDXKTEMP:AddIndex("1",{"DXK_FILIAL","DXK_SAFRA","DXK_ETIQ"})
	__oDXKTEMP:AddIndex("2",{"DXK_FILIAL","DXK_SAFRA","DXK_CODROM"})
	__oDXKTEMP:Create()

	//Criação e instância do browse de avaliação de malas
	__oBrwMala := FWFormBrowse():New()
	__oBrwMala:SetOwner(oPanel)
	__oBrwMala:SetDataTable(.T.)
	__oBrwMala:SetTemporary(.T.)
	__oBrwMala:SetAlias(__DXJTEMP)
	__oBrwMala:SetDescription(STR0049) /*"Avaliar Mala" */
	__oBrwMala:SetProfileID("__oBrwMala")
	
	//monta botão filtrar 
	DXJFilter()
	__oBrwMala:SetUseFilter(.T.)
	__oBrwMala:SetUseCaseFilter(.T.)
	__oBrwMala:SetFieldFilter(__aMalaFilter)
	__oBrwMala:SetDBFFilter(.T.)
	
	ADD MARKCOLUMN oColumn DATA { || If((__DXJTEMP)->SELEC = __cMarca,"LBOK","LBNO") } ;
	DOUBLECLICK { |__oBrwMala| A070MBLine( __DXJTEMP ) } ;
	HEADERCLICK { |__oBrwMala| A070MBAll( __DXJTEMP , @__oBrwMala) } OF __oBrwMala

	//Monta as colunas desconsiderando os campos abaixo
	nCol := 1
	For nX := 1 to Len(aStrDXJ)
		If !(aStrDXJ[nX,1] $ "SELEC")
			aAdd(aColunaMala,FWBrwColumn():New())
			aColunaMala[nCol]:SetData(&("{||"+aStrDXJ[nX,1]+"}"))
			aColunaMala[nCol]:SetTitle(aStrDXJ[nX,5])
			aColunaMala[nCol]:SetPicture(aStrDXJ[nX,6])
			aColunaMala[nCol]:SetType(aStrDXJ[nX,2])
			aColunaMala[nCol]:SetSize(aStrDXJ[nX,3])
			aColunaMala[nCol]:SetReadVar(aStrDXJ[nX,1])
			nCol++
		EndIf	
	Next nX
    
    //monta "chave" do pesquisar
	Aadd(aSeek,{STR0088 ,{{"", 'C' , TamSX3("DXJ_FILIAL")[1] + TamSX3("DXJ_SAFRA")[1] + TamSX3("DXJ_CODIGO")[1] , 0 , "@!" }}, 1, .T. } ) //Filial+Safra+Código
	__oBrwMala:SetSeek( ,aSeek)
	
	__oBrwMala:SetColumns(aColunaMala)
	__oBrwMala:SetDoubleClick({|| DetMala(( __DXJTEMP )->DXJ_FILIAL, ( __DXJTEMP )->DXJ_SAFRA, ( __DXJTEMP )->DXJ_CODIGO) })	
	__oBrwMala:AddButton(STR0027/*'&Avaliar'*/  ,{|__oBrwMala| PreAvaliacao() },,2,0,.T.,3,,)
	__oBrwMala:AddButton(STR0030/*'&Bloquear'*/ ,{|__oBrwMala| PreBloqueio() },,2,0,.T.,3,,)
	__oBrwMala:DisableDetails()				
	__oBrwMala:Activate()

	UBAA070COL()
	
Return

/*/{Protheus.doc} SetRelation
//Seta o relacionamento entre a grid de filiais/safra e grid de blocos
@author bruna.rocio
@since 15/08/2017
@version undefined
@param oModel, object, Modelo da rotina UBAA070
@type function
/*/
Static Function SetRelation(oModel)

	__oBrwBloco:SetFilterDefault("@DXD_FILIAL = '" + oModel:GetValue('UBAA070_VT','VT_FILIAL') + "' AND DXD_SAFRA = '" + oModel:GetValue('UBAA070_VT','VT_CODSAF') +"'")
	__oBrwBloco:Refresh()	

	If FWModeAccess("N80",1)='C'
		__oBrwMala:SetFilterDefault("@DXJ_FILIAL = '" + oModel:GetValue('UBAA070_VT','VT_FILIAL') + "' AND DXJ_SAFRA = '" + oModel:GetValue('UBAA070_VT','VT_CODSAF') +"'")
		__oBrwMala:Refresh()
	Else
		Processa({|| RegDinamica(oModel, oModel:GetValue('UBAA070_VT','VT_FILIAL') )}, STR0051/*"Atualizando malas para a Filial "*/ + oModel:GetValue('UBAA070_VT','VT_FILIAL') )
		__oBrwMala:SetFilterDefault("@DXJ_FILIAL = '" + oModel:GetValue('UBAA070_VT','VT_FILIAL') + "' AND DXJ_SAFRA = '" + oModel:GetValue('UBAA070_VT','VT_CODSAF') +"'")
		__oBrwMala:Refresh()
	Endif
	
Return 

/*/{Protheus.doc} AtualizAba
//atualiza a grid ao clicar na aba
@author silvana.torres
@since 25/10/2017
@version undefined
@type function
/*/
Static Function AtualizAba()
	
	Local oModel    := FwModelActive()
	
	
	If oModel != Nil
		__oBrwBloco:SetFilterDefault("@DXD_FILIAL = '" + oModel:GetValue('UBAA070_VT','VT_FILIAL') + "' AND DXD_SAFRA = '" + oModel:GetValue('UBAA070_VT','VT_CODSAF') +"'")
		__oBrwMala:SetFilterDefault("@DXJ_FILIAL = '" + oModel:GetValue('UBAA070_VT','VT_FILIAL') + "' AND DXJ_SAFRA = '" + oModel:GetValue('UBAA070_VT','VT_CODSAF') +"'")
	endIf
		
Return 

/*/{Protheus.doc} DetBloco
@author bruna.rocio
@since 17/05/2017
@version 12.1.20
@param cSafra, caracter, Safra do bloco
@param cCodSeq, caracter, código de bloco sequencial a ser detalhado
@type function
/*/
Static Function DetBloco(cFilBlc, cSafra, cCodSeq)
	Local oDlgFrd     := Nil
	Local oFwLayer    := Nil
	Local oPnFardinho := Nil
	Local oSize       := Nil
	Local oBrwFrd     := Nil
	Local nx
	Local nRegTemp    := __oBrwBloco:At()
	Local aSeek       := {}
	Local aColunaFard := {}
	Local nCol
	
	SetKey(VK_F11,Nil)
	SetKey(VK_F12,Nil)

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 60, 60, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlgFrd := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4],;
	STR0016  /*Fardinhos do Bloco*/  , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlgFrd, .f., .t. )

	oFWLayer:AddLine( 'GRID', 100, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'GRID' )
	oPnFardinho := oFWLayer:GetColPanel( 'ALL', 'GRID' )


	//Criação e instância do browse de fardos de blocos
	oBrwFrd := FWFormBrowse():New()
	oBrwFrd:SetOwner(oPnFardinho)
	oBrwFrd:SetFilterDefault("F_FILIAL = '" + cFilBlc + "' .And. F_SAFRA = '" + cSafra + "' .And. F_CODSEQ = '" + cCodSeq + "'")
	oBrwFrd:SetBlkBackColor({|| Iif( (__cAliasFr)->F_NOVO = '1', CLR_LIGHTGRAY, Nil ) })
	oBrwFrd:SetDataTable(.T.)
	oBrwFrd:SetTemporary(.T.)
	oBrwFrd:SetAlias(__cAliasFr)
	oBrwFrd:SetDescription(STR0016) /* Fardinhos do Bloco */
	oBrwFrd:SetProfileID("oBrwFrd")

	//monta botão filtrar 
	oBrwFrd:SetUseCaseFilter(.T.)
	oBrwFrd:SetDBFFilter(.T.)
	
	// Monta colunas desconsiderando os campos abaixo
	nCol := 1
	For nx := 1 to Len(__aEstrFrd)

		If !(__aEstrFrd[nX,1] $ "F_BLOCO, F_PADREP")
			AAdd(aColunaFard,FWBrwColumn():New())
			aColunaFard[nCol]:SetData(&("{||"+__aEstrFrd[nX,1]+"}"))
			aColunaFard[nCol]:SetTitle(__aEstrFrd[nX,5])
			aColunaFard[nCol]:SetPicture(__aEstrFrd[nX,6])
			aColunaFard[nCol]:SetType(__aEstrFrd[nX,2])
			aColunaFard[nCol]:SetSize(__aEstrFrd[nX,3])
			aColunaFard[nCol]:SetReadVar(__aEstrFrd[nX,1])
			nCol++
		Endif
	Next nX
    
    	//monta "chave" do pesquisar
	Aadd(aSeek,{STR0091 ,{{"", 'C' , TamSX3("DXI_FILIAL")[1] + TamSX3("DXI_SAFRA")[1] + TamSX3("DXI_ETIQ")[1], 0 , "@!" }}, 1, .T. } ) //"Filial+Safra+Etiqueta" 
		
	oBrwFrd:SetSeek( ,aSeek)
	
	oBrwFrd:SetColumns(aColunaFard)
	oBrwFrd:DisableDetails()				
	oBrwFrd:Activate()

	/* Browse Fardos 1 = Filial, 2 = Mala, 	3 = Etiqueta, 	4 = Fardo, 		5 = Peso Líquido, 	6 = Reg. Emb, 	7 = Result. Ana,
				 	 8 = Bloco,	 9 = Safra,	10 = Clas.Com.,	11 = Peso Liq., 12 = Bloco Novo, 	13 = Entidade, 14 = Lj. Entidade, = 15 Fazenda*/

	oBrwFrd:DelColumn(1)
	oBrwFrd:DelColumn(8)
	oBrwFrd:DelColumn(9)
	oBrwFrd:DelColumn(10)
	oBrwFrd:DelColumn(11)
	oBrwFrd:DelColumn(12)
	oBrwFrd:DelColumn(13)
	oBrwFrd:DelColumn(14)
	oBrwFrd:DelColumn(15)
	oBrwFrd:UpdateBrowse(.t.)
	oBrwFrd:Refresh()

	oDlgFrd:Activate( , , , .t., { || .t. }, ,  )

	(__cAliasFr)->(dbGoTop())
	(__DXDTEMP)->(DbGoTo(nRegTemp))
	__oBrwBloco:Refresh(.T.)

	SetKey( VK_F11, bKeyF11070 )
	SetKey( VK_F12, bKeyF12070 )

Return .T.

/*/{Protheus.doc} DetMala
@author carlos.augusto	
@since 21/06/2017
@version 12.1.20
@param cSafra, caracter, Safra da mala
@param cBloco, caracter, Mala a ser detalhada
@type function
/*/
Static Function DetMala(cFilMala, cSafra, cMala)
	Local aArea       := GetArea()
	Local oDlgFrd     := Nil
	Local oFwLayer    := Nil
	Local oPnFardinho := Nil
	Local oSize       := Nil
	Local oBrwFrd     := Nil
	Local nx
	Local aStruDXK    := StruDXKTEMP()
	Local aSeek       := {}
	Local aColunaMala := {}
	Local nCol
	
	SetKey(VK_F11,Nil)
	SetKey(VK_F12,Nil)

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 60, 60, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlgFrd := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3], oSize:aWindSize[4],;
	STR0050 /* Fardos da Mala */ , , , , , CLR_BLACK, CLR_WHITE, , , .t. ) 

	oFwLayer := FwLayer():New()
	oFwLayer:Init( oDlgFrd, .f., .t. )

	oFWLayer:AddLine( 'GRID', 100, .F. )
	oFWLayer:AddCollumn( 'ALL' , 100, .T., 'GRID' )
	oPnFardinho := oFWLayer:GetColPanel( 'ALL', 'GRID' )

	//Criação e instância do browse de fardos de malas
	oBrwFrd := FWFormBrowse():New()
	oBrwFrd:SetOwner(oPnFardinho)
	oBrwFrd:SetDataTable(.T.)
	oBrwFrd:SetTemporary(.T.)
	oBrwFrd:SetAlias(__DXKTEMP)
	oBrwFrd:SetDescription(STR0050)  /* Fardinhos da Mala */
	oBrwFrd:SetProfileID("oBrwFrd")
	
	oBrwFrd:SetDBFFilter(.T.)
	oBrwFrd:SetFilterDefault("DXK_FILIAL = '" + cFilMala + "' .And. DXK_SAFRA = '" + cSafra + "' .And. DXK_CODROM = '" + cMala + "'")
	
	//Monta as colunas desconsiderando os campos abaixo
	nCol := 1
	For nX := 1 to Len(aStruDXK)
		If !(aStruDXK[nX,1] $ "DXK_ALERTA")
			aAdd(aColunaMala,FWBrwColumn():New())
			aColunaMala[nCol]:SetData(&("{||"+aStruDXK[nX,1]+"}"))
			aColunaMala[nCol]:SetTitle(aStruDXK[nX,5])
			aColunaMala[nCol]:SetPicture(aStruDXK[nX,6])
			aColunaMala[nCol]:SetType(aStruDXK[nX,2])
			aColunaMala[nCol]:SetSize(aStruDXK[nX,3])
			aColunaMala[nCol]:SetReadVar(aStruDXK[nX,1])
			nCol++
		EndIf	
	Next nX
    
    	//monta "chave" do pesquisar
	Aadd(aSeek,{STR0089 ,{{"", 'C' , TamSX3("DXK_FILIAL")[1] + TamSX3("DXK_SAFRA")[1] + TamSX3("DXK_ETIQ")[1] , 0 , "@!" }}, 1, .T. } ) //"Filial+Safra+Etiqueta"
	oBrwFrd:SetSeek( ,aSeek)
	
	oBrwFrd:SetColumns(aColunaMala)
	oBrwFrd:AddButton(STR0017 /* Sair */,{|| oDlgFrd:End() })	
	oBrwFrd:DisableDetails()				
	oBrwFrd:Activate()

	oBrwFrd:DelColumn(1)
	oBrwFrd:DelColumn(2)
	oBrwFrd:DelColumn(3)
		
	oBrwFrd:UpdateBrowse(.t.)
	oBrwFrd:Refresh()

	oDlgFrd:Activate( , , , .t., { || .t. }, ,  )

	SetKey( VK_F11, bKeyF11070 )
	SetKey( VK_F12, bKeyF12070 )

	RestArea(aArea)
Return .T.


/*/{Protheus.doc} PreBloqueio
@author bruna.rocio
@since 16/08/2017
@version undefined
@type function
/*/
Static Function PreBloqueio()
	Local lRet       := .T.
	Local aSaveLines := FWSaveRows()

	dbSelectArea(__DXJTEMP)
	(__DXJTEMP)->(dbGoTop())

	While (__DXJTEMP)->(!Eof())	

		If (__DXJTEMP)->SELEC = __cMarca
			Processa({|| lRet := A070BloqMala((__DXJTEMP)->DXJ_FILIAL,(__DXJTEMP)->DXJ_SAFRA, (__DXJTEMP)->DXJ_CODIGO) }, STR0044 /*"Efetuando bloqueio das malas selecionadas"*/)
			If lRet
				RemoveMala((__DXJTEMP)->DXJ_FILIAL,(__DXJTEMP)->DXJ_SAFRA, (__DXJTEMP)->DXJ_CODIGO)

				fZapTRB( __DXDTEMP )
				fZapTRB( __cAliasFr )

				__oBrwBloco:Refresh(.T.)
			Endif
		Endif

		(__DXJTEMP)->(dbSkip())
	EndDo

	__oBrwMala:Refresh(.T.)

	FwRestRows(aSaveLines)
Return 

/*/{Protheus.doc} RemoveMala
//Remove malas que foram bloqueadas
@author carlos.augusto	
@since 30/06/2017
@version 12.1.20
@param cFilBloq, caracter, filial da mala que foi bloqueada
@param cSafraBloq, caracter, safra da mala que foi bloqueada
@param cMalaBloq, caracter, mala que foi bloqueada
@type function
/*/
Static Function RemoveMala(cFilBloq, cSafraBloq, cMalaBloq)
	Local aArea := GetArea()

	dbSelectArea(__DXJTEMP)
	dbSetOrder(1)
	If (__DXJTEMP)->(MsSeek(cFilBloq+cSafraBloq+cMalaBloq))
		dbSelectArea(__DXKTEMP)
		dbSetOrder(1)
		If (__DXKTEMP)->(MsSeek((__DXJTEMP)->(DXJ_FILIAL+DXJ_SAFRA+DXJ_CODIGO)))
			While (__DXKTEMP)->(!Eof()) .And.;
			(__DXKTEMP)->(DXK_FILIAL+DXK_SAFRA+DXK_CODROM) = (__DXJTEMP)->(DXJ_FILIAL+DXJ_SAFRA+DXJ_CODIGO) 	

				If RecLock(__DXKTEMP,.F.)
					(__DXKTEMP)->(dbDelete())
					(__DXKTEMP)->(MsUnlock())
				EndIf

				(__DXKTEMP)->(dbSkip())
			EndDo
		Endif
		dbSelectArea(__DXJTEMP)
		If RecLock(__DXJTEMP,.F.)
			(__DXJTEMP)->(dbDelete())
			(__DXJTEMP)->(MsUnlock())
		EndIf
	Endif

	RestArea(aArea)
Return .T.

/*/{Protheus.doc} PreAvaliacao
//Função responsável pela chamada e envio de parâmetros para a avaliação de malas
@author bruna.rocio
@since 15/08/2017
@version undefined
@type function
/*/
Static Function PreAvaliacao()
	Local aRows     := FwSaveRows()
	Local oModel    := FwModelActive()
	Local oGridVT   := oModel:GetModel('UBAA070_VT')
	Local nX        := 0
	Local lMessage  := .T.
	Local cFilSel   := oGridVT:GetValue('VT_FILIAL')
	Local cSafraSel := oGridVT:GetValue('VT_CODSAF')

	__oBrwMala:SetFilterDefault()
	//Limpa a tabela temporária de mala
	fZapTRB( __DXJTEMP )
	fZapTRB( __DXKTEMP )

	For nX := 1 to oGridVT:Length()
		oGridVT:GoLine(nX)
		If !oGridVT:IsDeleted() .And. oGridVT:GetValue('VT_SELEC') .And. !Empty(oGridVT:GetValue('VT_CODSAF'))
			lMessage := .F.
			Processa( {|| A070AvalMala( oGridVT:GetValue('VT_FILIAL'), oGridVT:GetValue('VT_CODSAF'), @__DXJTEMP, @__DXKTEMP, __nMaxCols)} ,;
			STR0046/*"Avaliando malas da Filial "*/ + oGridVT:GetValue('VT_FILIAL') + STR0047/*" para a Safra "*/ + oGridVT:GetValue('VT_CODSAF'))			
		Endif
	Next nX	

	If lMessage
		Help("",1,STR0025/*"Atenção"*/,,STR0045/*"Selecione ao menos uma filial/safra para avaliação de malas"*/,1) 
	Endif

	Processa({|| RegDinamica(oModel, cFilSel)}, STR0051/*"Atualizando malas para a Filial "*/ + cFilSel )
	__oBrwMala:SetFilterDefault("@DXJ_FILIAL = '" + cFilSel + "' AND DXJ_SAFRA = '" + cSafraSel +"'")
	__oBrwMala:Refresh()

	FwRestRows(aRows)	
Return .T.


/*/{Protheus.doc} SimularEmb
//Inicia a simulação de emblocamento
@author carlos.augusto
@since 21/08/2017
@version 12.1.20
@type function
/*/
Static Function SimularEmb(oModel)
	Local nz
	Local aRows     := FwSaveRows()
	Local oGridVT := oModel:GetModel('UBAA070_VT')
	Local cFilTemp := cFilAnt
	Local cFilSel   := oGridVT:GetValue('VT_FILIAL')
	Local cSafraSel := oGridVT:GetValue('VT_CODSAF')

	__cAliasFr := GetNextAlias()
	__oAliasFr := TempFrd(@__cAliasFr)

	//Verifica preenchimento de safra para todos os itens marcados
	lRet := ValidEntr(oModel)

	__oBrwBloco:SetFilterDefault("")

	If lRet
		__nCodSeq = 0

		fZapTRB( __DXDTEMP )
		fZapTRB( __cAliasFr )

		For nZ := 1 to oGridVT:Length()
			oGridVT:Goline(nZ)
			cFilAnt := oGridVT:GetValue('VT_FILIAL')
			If oGridVT:GetValue('VT_SELEC')
				Processa ({|| EmblContam(oGridVT:GetValue('VT_FILIAL'), oGridVT:GetValue('VT_CODSAF')) }, STR0018 /*Aguarde*/, STR0020 + oGridVT:GetValue('VT_FILIAL') /* "Aplicando regras de emblocamento para a filial " */,.F.)
			Endif
		Next nZ

	Endif

	__oBrwBloco:SetFilterDefault("@DXD_FILIAL = '" + cFilSel + "' AND DXD_SAFRA = '" + cSafraSel +"'")

	/****************************************************************/
	/* Ao finalizar processamento, reordena as tabelas temporárias  */
	/****************************************************************/
	dbSelectArea(__cAliasFr)
	(__cAliasFr)->(dbSetOrder(2))
	(__cAliasFr)->(dbGoTop())

	dbSelectArea(__DXDTEMP)
	(__DXDTEMP)->(dbGoTop())		
	(__DXDTEMP)->(dbSetOrder(5))
	__oBrwBloco:SetAlias(__DXDTEMP)
	__oBrwBloco:UpdateBrowse(.t.)	
	__oBrwBloco:SetFocus()

	cFilAnt := cFilTemp

	/****************************************************************/
	FwRestRows(aRows)


Return lRet


/*/{Protheus.doc} EmblContam
//Emblocamento de fardinho de acordo com critérios de contaminantes e tipo comercial
@author bruna.rocio
@since 16/05/2017
@version 12.1.20
@param cFilialBlc, characters, filial
@param cSafraBloc, characters, safra
@type function
/*/
Static Function EmblContam(cFilialBlc, cSafraBloc)
	Local aArea       := GetArea()
	Local lRet        := .T.
	Local cAliasPre   := GetNextAlias()
	Local cQuery      := ""
	Local nQtdeBloco
	Local nQtdReserva := 0
	Local nPerc 	  := 0	
	Local nFardoReg   := 0
	Local aRegraDeEmb := {}
	Local cCodRegra	  := ""
	Local lEncRegra	  := .F.
	Local cTipReg	  := IIF(Empty(__cCodRegra),"1","3") 
	
	Private _nTotPsLiq  := 0

	aRegraDeEmb := PegaRegras(cFilialBlc, cSafraBloc)
	
	Pergunte('UBAA070003', .F.)
	
	If .Not. Empty(__cCodRegra)
		DbSelectArea("N80")
		N80->(dbSetOrder(1))
		If N80->(dbSeek(FwxFilial("N80") + __cCodRegra + "3"))
			nQtdeBloco := N80->N80_QTDFAR
		Else
			nQtdeBloco := 9999
			MsgAlert(STR0092 + __cCodRegra)//"Regra de emblocamento não foi encontrada para definir a quantidade limite do bloco:" 
		EndIf
		N80->(dbCloseArea())
	Else
		nQtdeBloco := MV_PAR01	
	EndIf


	cQuery := " SELECT DISTINCT DXI_FILIAL, DXI_SAFRA, DXI_ETIQ, DXI_CODIGO, DXI_CLACOM, DXI_PSLIQU, DXI_PRDTOR, DXI_LJPRO, DXI_FAZ, DXJ_CODIGO, DX7_MIC, DXI_CODUNB,"
	cQuery +=        " DX7_RES, DX7_FIBRA, DX7_UI, DX7_SFI, DX7_ELONG, DX7_LEAF, DX7_AREA, DX7_CSP, DX7_CG, DX7_MAISB, DX7_RD, DX7_COUNT, DX7_UHM,"
	cQuery +=        " DX7_MATU, DX7_SCI "
	cQuery += " FROM " + RetSqlName('DXI') + " DXI "

	cQuery += " INNER JOIN " + RetSqlName('DXK') + " DXK ON " 
	cQuery += 			" DXK.DXK_FILIAL = DXI.DXI_FILIAL "
	cQuery += 		" AND DXK.DXK_SAFRA  = DXI.DXI_SAFRA "
	cQuery += 		" AND DXK.DXK_ETIQ   = DXI.DXI_ETIQ "
	cQuery += 		" AND DXK.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName('DXJ') + " DXJ ON " 
	cQuery += 			" DXJ.DXJ_FILIAL = DXK.DXK_FILIAL "
	cQuery += 		" AND DXJ.DXJ_SAFRA  = DXK.DXK_SAFRA "
	cQuery += 		" AND DXJ.DXJ_CODIGO = DXK.DXK_CODROM "
	cQuery += 		" AND DXJ.DXJ_STATUS = '6' "
	cQuery += 		" AND DXJ.D_E_L_E_T_ = ' ' "
	cQuery += " INNER JOIN " + RetSqlName('DX7') + " DX7 ON " 
	cQuery += 			" DX7.DX7_FILIAL = DXI.DXI_FILIAL "
	cQuery += 		" AND DX7.DX7_SAFRA  = DXI.DXI_SAFRA "
	cQuery += 		" AND DX7.DX7_ETIQ   = DXI.DXI_ETIQ "
	cQuery += 		" AND DX7.D_E_L_E_T_ = ' ' " 
	cQuery += 		" AND DX7.DX7_ATIVO = '1' "

	cQuery += " AND NOT EXISTS (SELECT * FROM " + RetSqlName('DXK') + " DXK2 " 
	cQuery += " INNER JOIN " + RetSqlName('DXJ') + " DXJ2 ON " 
	cQuery += 			" DXJ2.DXJ_FILIAL = '" + fwxFilial('DXJ') + "' "
	cQuery += 		" AND DXJ2.DXJ_CODIGO = DXK2.DXK_CODROM  "
	cQuery += 		" AND DXJ2.DXJ_TIPO   = DXK2.DXK_TIPO  "
	cQuery += 		" AND DXJ2.DXJ_SAFRA  = DXK2.DXK_SAFRA "
	cQuery += 		" AND DXJ2.DXJ_STATUS = '8'  " /* Mala Bloqueada */  
	cQuery += 		" AND DXJ2.D_E_L_E_T_ = ' ' "
	cQuery += 			" WHERE DXK2.DXK_FILIAL = '" + fwxFilial('DXK') + "' "
	cQuery += 			  " AND DXK2.DXK_SAFRA  = DXI.DXI_SAFRA  "
	cQuery += 			  " AND DXK2.DXK_ETIQ   = DXI.DXI_ETIQ " 
	cQuery += 			  " AND DXK2.DXK_TIPO   = '2' "
	cQuery += 			 " AND DXK2.D_E_L_E_T_ = ' '  )   " /*HVI*/
	
	cQuery += 		" AND DXI.D_E_L_E_T_ = ' ' "
	cQuery += 		" AND DXI.DXI_FILIAL = '" + fwxFilial('DXI') + "' "
	cQuery += 		" AND DXI.DXI_SAFRA = '" + cSafraBloc + "' "	
	cQuery += 		" AND DXI.DXI_CLACOM <> ' ' "
	cQuery += 		" AND DXI.DXI_BLOCO   = ' '  "
	
	
	
	cQuery    := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cAliasPre, .F., .T. )
	
	While (cAliasPre)->(!Eof())
	
		//Aqui eu obrigatoriamente devo saber qual é a regra que o fardo se encaixa
		cCodRegra := ValidaFardo(aRegraDeEmb, (cAliasPre)->DXI_FILIAL,(cAliasPre)->DXI_SAFRA,(cAliasPre)->DXI_ETIQ, (cAliasPre)->DXI_CLACOM,@cAliasPre)
		
		DbSelectArea("N80")
		N80->(dbSetOrder(1))
		If !N80->(dbSeek(FwxFilial("N80") + cCodRegra + cTipReg + "1"))
			lEncRegra := .F.
		Else	
			lEncRegra := .T.
		EndIf

		If lEncRegra

			dbSelectArea(__DXDTEMP)

			(__DXDTEMP)->(dbSetOrder(1))
			(__DXDTEMP)->(dbGoTop())
			//Encontra bloco do padrão atribuido ao fardo e aberto
			If (__DXDTEMP)->(msSeek((cAliasPre)->DXI_FILIAL+(cAliasPre)->DXI_SAFRA+N80->N80_CODIGO+(cAliasPre)->DXI_CLACOM+"2"+;
			IIF(MV_PAR02 == 2, (cAliasPre)->DXI_PRDTOR+(cAliasPre)->DXI_LJPRO,;
			IIF(MV_PAR02 == 3, (cAliasPre)->DXI_PRDTOR+(cAliasPre)->DXI_LJPRO+(cAliasPre)->DXI_FAZ,""))))

				dbSelectArea(__cAliasFr)
				dbSetOrder(1)
				If !msSeek((cAliasPre)->DXI_FILIAL+(cAliasPre)->DXI_SAFRA+(cAliasPre)->DXI_ETIQ)
					
					If nQtdReserva > 0
						If (_nTotPsLiq + (cAliasPre)->DXI_PSLIQU) < nQtdReserva
							_nTotPsLiq += (cAliasPre)->DXI_PSLIQU
						Else
							Exit
						EndIf
					EndIf
						 	
					If RecLock(__cAliasFr, .T.) //Cria registro vinculando o fardinho ao bloco
						(__cAliasFr)->F_FILIAL := (cAliasPre)->DXI_FILIAL
						(__cAliasFr)->F_MALA   := (cAliasPre)->DXJ_CODIGO
						(__cAliasFr)->F_SAFRA  := (cAliasPre)->DXI_SAFRA
						(__cAliasFr)->F_FARDO  := (cAliasPre)->DXI_CODIGO
						(__cAliasFr)->F_ETIQ   := (cAliasPre)->DXI_ETIQ
						(__cAliasFr)->F_BLOCO  := (__DXDTEMP)->DXD_CODIGO
						(__cAliasFr)->F_CODSEQ := (__DXDTEMP)->DXD_CODSEQ
						(__cAliasFr)->F_PADRAO := (__DXDTEMP)->DXD_CODREG
						(__cAliasFr)->F_CLACOM := (__DXDTEMP)->DXD_CLACOM
						(__cAliasFr)->F_PSLIQU := (cAliasPre)->DXI_PSLIQU
						(__cAliasFr)->F_PADREP := ''
						(__cAliasFr)->F_DESPDR := Posicione('N80',1,fwxFilial('N80')+N80->N80_CODIGO,"N80_NMEMBL")
						(__cAliasFr)->F_CRITER := GetCriterio((__DXDTEMP)->DXD_CODREG, (cAliasPre)->DXI_SAFRA, (cAliasPre)->DXI_ETIQ)
						(__cAliasFr)->F_NOVO   := "1" //Não é um fardo já relacionado
						(__cAliasFr)->F_PRDTOR := (cAliasPre)->DXI_PRDTOR
						(__cAliasFr)->F_LJPRO  := (cAliasPre)->DXI_LJPRO
						(__cAliasFr)->F_FAZ    := (cAliasPre)->DXI_FAZ

						(__cAliasFr)->(MsUnlock())
					Endif

					dbSelectArea(__DXDTEMP)
					If RecLock(__DXDTEMP) //Atualiza a quantidade vinculada ao bloco
						(__DXDTEMP)->DXD_QTDVNC += 1
						(__DXDTEMP)->PCTFOR     += 1

						//Se bloco foi completo, muda status					
						If (__DXDTEMP)->DXD_QTDVNC >= (__DXDTEMP)->DXD_QTDFRM
							(__DXDTEMP)->DXD_STATUS = "3" //Finalizado
						Endif

						If (__DXDTEMP)->DXD_FDINI == Nil .OR. AllTrim((__DXDTEMP)->DXD_FDINI) == ""  
							(__DXDTEMP)->DXD_FDINI  := (cAliasPre)->DXI_CODIGO
						endIf

						(__DXDTEMP)->DXD_FDFIN  := (cAliasPre)->DXI_CODIGO

						(__DXDTEMP)->(MsUnlock()) 
					Endif
				Endif
			Else //Sem bloco do padrao e tipo comercial aberto	

				dbSelectArea(__cAliasFr)
				dbSetOrder(1)
				If !msSeek((cAliasPre)->DXI_FILIAL+(cAliasPre)->DXI_SAFRA+(cAliasPre)->DXI_ETIQ)
				
					If nQtdReserva > 0
						If (_nTotPsLiq + (cAliasPre)->DXI_PSLIQU) < nQtdReserva
							_nTotPsLiq += (cAliasPre)->DXI_PSLIQU
						Else
							Exit
						EndIf
					EndIf
					
					//Cria um novo bloco para o tipo comercial e regra
					If RecLock(__DXDTEMP, .T.)

						__nCodSeq := __nCodSeq + 1

						(__DXDTEMP)->DXD_FILIAL	:= (cAliasPre)->DXI_FILIAL 
						(__DXDTEMP)->DXD_SAFRA  := (cAliasPre)->DXI_SAFRA 
						(__DXDTEMP)->DXD_CODSEQ	:= CValToChar(__nCodSeq)
						(__DXDTEMP)->DXD_CODIGO := ''
						(__DXDTEMP)->DXD_CODUNB := (cAliasPre)->DXI_CODUNB							

						If MV_PAR02 == 2
							(__DXDTEMP)->DXD_PRDTOR := (cAliasPre)->DXI_PRDTOR
							(__DXDTEMP)->DXD_LJPRO  := (cAliasPre)->DXI_LJPRO
							(__DXDTEMP)->DXD_NMPRDT   := Posicione("NJ0",1,FWxFilial("NJ0")+(cAliasPre)->DXI_PRDTOR+(cAliasPre)->DXI_LJPRO,"NJ0_NOME")
						ElseIf MV_PAR02 == 3
							(__DXDTEMP)->DXD_PRDTOR := (cAliasPre)->DXI_PRDTOR
							(__DXDTEMP)->DXD_LJPRO  := (cAliasPre)->DXI_LJPRO
							(__DXDTEMP)->DXD_NMPRDT   := Posicione("NJ0",1,FWxFilial("NJ0")+(cAliasPre)->DXI_PRDTOR+(cAliasPre)->DXI_LJPRO,"NJ0_NOME")

							(__DXDTEMP)->DXD_FAZ    := (cAliasPre)->DXI_FAZ
							(__DXDTEMP)->DXD_NMFAZ   := Posicione("NN2",2,FWxFilial("NN2")+(cAliasPre)->DXI_FAZ,"NN2_NOME")
						EndIf

						(__DXDTEMP)->DXD_CLACOM := (cAliasPre)->DXI_CLACOM 
						(__DXDTEMP)->DXD_RELEVA := N80->N80_RELEVA
						(__DXDTEMP)->DXD_CODREG := N80->N80_CODIGO
						(__DXDTEMP)->DXD_QTDMAX := nQtdeBloco //Qtde Máxima
						(__DXDTEMP)->DXD_QTDFRM := CalcQTForm(nQtdeBloco, N80->N80_PCTFRM) //Qtde Máxima Formação   
						(__DXDTEMP)->DXD_QTDVNC := 1   //Qtde Vinculada
						(__DXDTEMP)->PCTFOR     := 1
						(__DXDTEMP)->DXD_DSCREG := Posicione('N80',1,fwxFilial('N80')+N80->N80_CODIGO,"N80_NMEMBL")
						(__DXDTEMP)->DXD_FDINI  := (cAliasPre)->DXI_CODIGO
						(__DXDTEMP)->DXD_FDFIN  := (cAliasPre)->DXI_CODIGO
						(__DXDTEMP)->DXD_NOVO   := "1" //É um bloco novo

						//Se bloco foi completo, muda status					
						If ROUND(((nQtdeBloco * N80->N80_PCTFRM) / 100 ),0) = 1 //Qtde Máxima Formação  
							(__DXDTEMP)->DXD_STATUS := "3" //Finalizado 
						Else
							(__DXDTEMP)->DXD_STATUS := "2" //Iniciado 
						Endif

						(__DXDTEMP)->(MsUnlock())
					Endif

					//Cria registro vinculando o fardinho ao bloco
					If RecLock(__cAliasFr, .T.)
						(__cAliasFr)->F_FILIAL := (cAliasPre)->DXI_FILIAL 
						(__cAliasFr)->F_MALA     := (cAliasPre)->DXJ_CODIGO
						(__cAliasFr)->F_SAFRA  := (cAliasPre)->DXI_SAFRA
						(__cAliasFr)->F_FARDO  := (cAliasPre)->DXI_CODIGO
						(__cAliasFr)->F_ETIQ   := (cAliasPre)->DXI_ETIQ
						(__cAliasFr)->F_BLOCO  := (__DXDTEMP)->DXD_CODIGO
						(__cAliasFr)->F_CODSEQ := (__DXDTEMP)->DXD_CODSEQ
						(__cAliasFr)->F_PADRAO := N80->N80_CODIGO
						(__cAliasFr)->F_DESPDR := Posicione('N80',1,fwxFilial('N80')+N80->N80_CODIGO,"N80_NMEMBL")
						(__cAliasFr)->F_CLACOM := (cAliasPre)->DXI_CLACOM 
						(__cAliasFr)->F_PSLIQU := (cAliasPre)->DXI_PSLIQU
						(__cAliasFr)->F_PADREP := ''
						(__cAliasFr)->F_CRITER := GetCriterio(N80->N80_CODIGO, (cAliasPre)->DXI_SAFRA, (cAliasPre)->DXI_ETIQ)
						(__cAliasFr)->F_NOVO   := "1" //Não é um fardo já relacionado
						(__cAliasFr)->F_PRDTOR := (cAliasPre)->DXI_PRDTOR
						(__cAliasFr)->F_LJPRO  := (cAliasPre)->DXI_LJPRO
						(__cAliasFr)->F_FAZ    := (cAliasPre)->DXI_FAZ

						(__cAliasFr)->(MsUnlock())
					Endif
				Endif
			Endif
		EndIf	

		dbSelectArea(cAliasPre)
		(cAliasPre)->(dbSkip())
	EndDo

	(__DXDTEMP)->(dbGoTop())
	(__cAliasFr)->(dbGoTop())

	/*******************************************/
	/* Chama função para terminar de modelar   */
	/* os blocos de acordo com o % de formação */
	/* da regra                                */  
	/*******************************************/
	
	Processa ({|| CalcPercForm(cFilialBlc) }, STR0018 /*Aguarde*/, STR0019 /*"Calculando % de Formação"*/,.F.)

	/************************************/
	/* Verifica se não sobrou bloco já  */
	/* persistido sem fardos novos      */
	/************************************/
	Processa ({||VerifyBlocos(cFilialBlc, cSafraBloc ) }, STR0018 /*Aguarde*/,  STR0021/*"Realizando conferência dos blocos simulados"*/,.F.)

	DbSelectArea(__DXDTEMP)
	(__DXDTEMP)->(dbGoTop())
	While (__DXDTEMP)->(!Eof())
		nPerc := 0	
		nFardoReg := 0
		
		dbSelectArea(__cAliasFr)
		(__cAliasFr)->(dbSetOrder(3))
		(__cAliasFr)->(dbGoTop())
		If MsSeek( (__DXDTEMP)->DXD_FILIAL+(__DXDTEMP)->DXD_SAFRA+(__DXDTEMP)->DXD_CODSEQ)
		
			While (__cAliasFr)->(!Eof())                           .And. ;
				  (__cAliasFr)->F_FILIAL = (__DXDTEMP)->DXD_FILIAL .And. ;
				  (__cAliasFr)->F_SAFRA  = (__DXDTEMP)->DXD_SAFRA  .And. ;
			      (__cAliasFr)->F_CODSEQ = (__DXDTEMP)->DXD_CODSEQ .And.;
				  (__cAliasFr)->F_PADRAO = (__DXDTEMP)->DXD_CODREG
				
				nFardoReg++
				
			(__cAliasFr)->(dbSkip())
			EndDo	
		EndIf
					
		If RecLock(__DXDTEMP, .F.)
			nPerc := (nFardoReg/(__DXDTEMP)->DXD_QTDVNC) *100
			(__DXDTEMP)->PCTFOR := nPerc
			(__DXKTEMP)->(MsUnlock())
		EndIf
		
		(__DXDTEMP)->(dbSkip())
	EndDo

	(cAliasPre)->(dbCloseArea())

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} CalcQTForm
//Retorna a quantidade de formação do bloco arredondando o valor sempre para mais
@author bruna.rocio
@since 29/09/2017
@version undefined
@param nQuant, numeric, quantidade que forma um bloco completo
@param nPerc, numeric, percentual de formação da regra
@type function
//Funções utilizadas:
//http://tdn.totvs.com/display/tec/Mod
//http://tdn.totvs.com/display/tec/NoRound
/*/
Static Function CalcQTForm(nQuant, nPerc)
	Local nQtForm := 0
	Local nResto  := 0

	//Utiliza a função mod para retornar o resto do calculo
	nResto := Mod( (nQuant * nPerc), 100 )

	//Valida o resto da divisão
	If nResto > 0 
		//Se resto > 0, invés de arredondar - matematicamente - trunca o valor da divisão
		//e soma +1, dessa forma, garantindo sempre o arredondamento "pra cima"
		nQtForm  := NoRound(((nQuant * nPerc) / 100 ),0)
		nQtForm += 1
	Else
		//Se o resto = 0, então, usa a divisão normal
		nQtForm := ((nQuant * nPerc) / 100 )
	Endif

Return nQtForm

/*/{Protheus.doc} GetParcial
//Função responsável por buscar blocos parciais gerados a partir de emblocamento automático
@author bruna.rocio
@since 20/07/2017
@version undefined

@type function
/*/
Static Function GetParcial(cRegra,nReleva, nForm, cFil, cSafra, nQtdeBloco, nQtdReserva)
	Local aArea   		:= GetArea()
	Local cAliDXD 		:= GetNextAlias()

	If nQtdReserva = 0
		BeginSql Alias cAliDXD
		Select * From %Table:DXD% DXD
		WHERE DXD.%notDel%
		AND DXD.DXD_FILIAL  = %exp:cFil%
		AND DXD.DXD_SAFRA	= %exp:cSafra%
		AND DXD.DXD_CODREG  = %exp:cRegra%
		AND DXD.DXD_STATUS <= 2
		ORDER BY DXD.DXD_CODIGO	
		EndSql
	
		dbSelectArea(cAliDXD)
		(cAliDXD)->(dbGoTop())
	
		While (cAliDXD)->(!Eof())	
	
			__nCodSeq += 1
	
			DXI->(dbSelectArea('DXI'))
			DXI->(dbSetOrder(4))
			If DXI->(MsSeek(fwxFilial('DXI')+(cAliDXD)->DXD_SAFRA+(cAliDXD)->DXD_CODIGO))
			
				If nQtdReserva > 0 .AND. DXI->DXI_PSLIQU > nQtdReserva
					Exit
				EndIf
				
				If RecLock(__DXDTEMP, .T.)
					(__DXDTEMP)->DXD_FILIAL := (cAliDXD)->DXD_FILIAL 
					(__DXDTEMP)->DXD_SAFRA  := (cAliDXD)->DXD_SAFRA 
					(__DXDTEMP)->DXD_CODIGO := (cAliDXD)->DXD_CODIGO
					(__DXDTEMP)->DXD_CODSEQ := CValToChar(__nCodSeq)
					(__DXDTEMP)->DXD_CLACOM := (cAliDXD)->DXD_CLACOM 
					(__DXDTEMP)->DXD_RELEVA := nReleva
					(__DXDTEMP)->DXD_CODREG := cRegra
					(__DXDTEMP)->DXD_QTDMAX := (cAliDXD)->DXD_QTDMAX
					(__DXDTEMP)->DXD_QTDFRM := CalcQTForm((cAliDXD)->DXD_QTDMAX, nForm) //Qtde Máxima Formação   
					(__DXDTEMP)->DXD_QTDVNC := (cAliDXD)->DXD_QTDVNC
					(__DXDTEMP)->DXD_DSCREG := Posicione('N80',1,fwxFilial('N80')+cRegra,"N80_NMEMBL")
					(__DXDTEMP)->DXD_FDINI  := (cAliDXD)->DXD_FDINI
					(__DXDTEMP)->DXD_FDFIN  := (cAliDXD)->DXD_FDFIN
					(__DXDTEMP)->DXD_STATUS := "2" //Iniciado
					(__DXDTEMP)->DXD_NOVO   := "2" //Já é um bloco persistido
					(__DXDTEMP)->DXD_PRDTOR := (cAliDXD)->DXD_PRDTOR 
					(__DXDTEMP)->DXD_LJPRO  := (cAliDXD)->DXD_LJPRO
					(__DXDTEMP)->DXD_NMPRDT := Posicione("NJ0",1,FWxFilial("NJ0")+(cAliDXD)->DXD_PRDTOR+(cAliDXD)->DXD_LJPRO,"NJ0_NOME") 
					(__DXDTEMP)->DXD_FAZ    := (cAliDXD)->DXD_FAZ
					(__DXDTEMP)->DXD_NMFAZ  := Posicione("NN2",2,FWxFilial("NN2")+(cAliDXD)->DXD_FAZ,"NN2_NOME") 
		
					(__DXDTEMP)->(MsUnlock())
				Endif

				While DXI->(!Eof())                       	.And.;
					  DXI->DXI_SAFRA = (cAliDXD)->DXD_SAFRA .And.;
					  DXI->DXI_BLOCO = (cAliDXD)->DXD_CODIGO
	
					  If nQtdReserva > 0
						If (_nTotPsLiq + DXI->DXI_PSLIQU) < nQtdReserva
							_nTotPsLiq += DXI->DXI_PSLIQU
						Else
							Exit
						EndIf
					EndIf
					
					//Cria registro vinculando o fardinho ao bloco
					If RecLock(__cAliasFr, .T.) 
						(__cAliasFr)->F_FILIAL := DXI->DXI_FILIAL
						(__cAliasFr)->F_MALA   := Posicione('DXK',2,fwxFilial('DXK')+DXI->DXI_SAFRA+DXI->DXI_ETIQ+'2','DXK_CODROM')
						(__cAliasFr)->F_SAFRA  := DXI->DXI_SAFRA
						(__cAliasFr)->F_FARDO  := DXI->DXI_CODIGO
						(__cAliasFr)->F_ETIQ   := DXI->DXI_ETIQ
						(__cAliasFr)->F_BLOCO  := DXI->DXI_BLOCO
						(__cAliasFr)->F_CODSEQ := cValToChar(__nCodSeq)
						(__cAliasFr)->F_PADRAO := DXI->DXI_CODREG
						(__cAliasFr)->F_DESPDR := Posicione('N80',1,fwxFilial('N80')+cRegra,"N80_NMEMBL")
						(__cAliasFr)->F_CLACOM := DXI->DXI_CLACOM
						(__cAliasFr)->F_PSLIQU := DXI->DXI_PSLIQU
						(__cAliasFr)->F_PADREP := (cAliDXD)->DXD_CODREG
						(__cAliasFr)->F_NOVO   := "2" //Já é um fardo relacionado
						(__cAliasFr)->F_CRITER := GetCriterio(cRegra, DXI->DXI_SAFRA, DXI->DXI_ETIQ)
						(__cAliasFr)->F_PRDTOR := DXI->DXI_PRDTOR
						(__cAliasFr)->F_LJPRO  := DXI->DXI_LJPRO
						(__cAliasFr)->F_FAZ    := DXI->DXI_FAZ
	
						(__cAliasFr)->(MsUnlock())
					Endif
	
					DXI->(dbSkip())
				EndDo
			Endif
	
			dbSelectArea(cAliDXD)		
			(cAliDXD)->(dbSkip())
		EndDo	
	EndIf

	RestArea(aArea)
Return .T.


/*/{Protheus.doc} ConfereCont
//Confere a não existencia do contaminante para o fardinho antes da associação ao bloco
@author bruna.rocio
@since 18/05/2017
@version 12.1.20
@param cSafra, characters, safra do bloco
@param cEtiqueta, characters, etiqueta do fardinho
@param cRegra, characters, código do padrao de regra do emblocamento
@type function
/*/
Static Function ConfereCont(cSafra, cEtiqueta, cRegra)
	Local aArea   := GetArea()
	Local lRet    := .T.
	Local cAliQry := GetNextAlias()

	BeginSql Alias cAliQry
	Select * From %Table:N81% N81
	INNER JOIN %Table:NPX% NPX
	ON NPX.%notDel%
	AND NPX.NPX_FILIAL = %xFilial:NPX%
	AND NPX.NPX_CODSAF = %exp:cSafra%
	AND NPX.NPX_ETIQ   = %exp:cEtiqueta%  
	AND NPX.NPX_CODTA  = N81.N81_CODREG
	AND NPX.NPX_ATIVO  = '1' //ATIVO
	WHERE N81.%notDel%
	AND N81.N81_CODEMB = %exp:cRegra%
	AND N81.N81_TIPREG = 2
	EndSQL

	dbSelectArea(cAliQry)
	(cAliQry)->(dbGoTop())

	While (cAliQry)->(!Eof())
		lRet := .F.
		(cAliQry)->(dbSkip())
	EndDo

	(cAliQry)->(dbCloseArea())

	RestArea(aArea)
Return lRet

/*/{Protheus.doc} GetCriterio
//Busca critérios de contaminação avaliados para o padrão
@author bruna.rocio
@since 16/05/2017
@version 12.1.20
@param cRegra, characters, código da regra de emblocamento a ser avaliado
@param cSafra, characters, safra do fardinho a ser avaliado
@param cEtiq , characters, etiqueta do fardinho a ser avaliado
@type function
/*/
Static Function GetCriterio( cRegra, cSafra, cEtiq )
	Local aArea      := GetArea()
	Local cCriterios := ""
	Local cExame     := ""

	dbSelectArea('N81')
	dbSetOrder(1)
	If msSeek(fwxFilial('N81')+cRegra+"1")

		While !Eof() .And. ;
		N81->N81_FILIAL = fwxFilial('N81') .And.;
		N81->N81_CODEMB = cRegra

			Do Case
				Case RTRIM(N81->N81_CODREG) = "+B"
				cExame := "DX7_MAISB"
				Case RTRIM(N81->N81_CODREG) = "C.G"
				cExame := "DX7_CG"
				Case RTRIM(N81->N81_CODREG) = "MATU100"
				cExame := "DX7_MATU"
				Otherwise
				cExame := "DX7_" +  RTRIM(N81->N81_CODREG) 	
			EndCase

			If Empty(cCriterios)

				If N81->N81_TIPREG = "1" //HVI
					cCriterios := RTRIM(N81->N81_CODREG) + " "  + cValToChar(Posicione("DX7",2,fwXFilial('DX7')+cSafra+cEtiq+"1",cExame))
				Else
					cCriterios := RTRIM(Posicione("N76",1,fwxFilial('N76')+PADR(RTRIM(N81->N81_CODREG),TamSX3('N76_CODIGO')[1],' '),"N76_NMCON"))
				Endif
			Else
				If N81->N81_TIPREG = "1" //HVI
					cCriterios := cCriterios + "/" + RTRIM(N81->N81_CODREG) + " " +  cValToChar(Posicione("DX7",2,fwXFilial('DX7')+cSafra+cEtiq+"1",cExame))
				Else
					cCriterios := cCriterios + "/" + RTRIM(Posicione("N76",1,fwxFilial('N76')+PADR(RTRIM(N81->N81_CODREG),TamSX3('N76_CODIGO')[1],' '),"N76_NMCON"))
				Endif
			Endif  	

			dbSkip()
		EndDo
	Endif

	N81->(dbCloseArea())

	RestArea(aArea)
Return cCriterios

/*/{Protheus.doc} CalcPercForm
//Recalcula distribuição dos blocos de acordo com o percentual de formação
@author bruna.rocio
@since 26/05/2017
@version 12.1.20
@type function
/*/
Static Function CalcPercForm(cFilialBlc)
	Local aArea     := GetArea()	
	Local nSaldo    := 0
	Local cNextPD   := ""
	Local nFardos   := 0
	Local nVinc     := 0
	Local cTipReg	:= IIF(Empty(__cCodRegra),'1','3')
	Local cAliasN80 := GetNextAlias()
	

	Pergunte('UBAA070003', .F.)


	BeginSql Alias cAliasN80
	Select * From %Table:N80% N80
	WHERE N80.%notDel%
	AND N80.N80_FILIAL = %xFilial:N80%
	AND N80.N80_TIPEMB = %exp:cTipReg%
	AND N80.N80_ATIVO = '1'
	ORDER BY N80.N80_RELEVA	
	EndSql

	dbSelectArea(cAliasN80)
	(cAliasN80)->(dbGoTop())

	/************************************************************************/
	/**         Processo de enfileiramento de fardinhos nos blocos         **/
	/************************************************************************/

	While (cAliasN80)->(!Eof())

		If (cAliasN80)->N80_PCTFRM < 100

			dbSelectArea(__DXDTEMP)
			(__DXDTEMP)->(dbGoTop())
			(__DXDTEMP)->(dbSetOrder(4))

			//Encontra bloco do padrão
			If (__DXDTEMP)->(msSeek((__DXDTEMP)->DXD_FILIAL+(cAliasN80)->N80_CODIGO))

				While (__DXDTEMP)->(!Eof()) .And. ;
				(__DXDTEMP)->DXD_FILIAL = cFilialBlc .And. ;
				(__DXDTEMP)->DXD_CODREG = (cAliasN80)->N80_CODIGO
				

					If (__DXDTEMP)->DXD_QTDMAX > (__DXDTEMP)->DXD_QTDVNC .And. (__DXDTEMP)->DXD_STATUS = '3' .And. (__DXDTEMP)->DXD_QTDVNC > 0

						cNextPD := (__DXDTEMP)->DXD_CODREG
						//Enquanto a quantidade vinculada for inferior a quantidade total
						//busca fardos para completar o bloco
						While (__DXDTEMP)->DXD_QTDMAX > (__DXDTEMP)->DXD_QTDVNC

							nSaldo  := (__DXDTEMP)->DXD_QTDMAX - (__DXDTEMP)->DXD_QTDVNC
							nVinc   := 0
							//Busca o próximo padrão na ordem por relevância
							cNextPD := GetNextStandard(cNextPD)

							//Se próximo padrão não for branco
							If !Empty(cNextPD)

								//Verifica se existem fardos para a safra, regra e tipo comercial					    	
								If CalcFardoByRegra((__DXDTEMP)->DXD_FILIAL,(__DXDTEMP)->DXD_SAFRA, cNextPD, (__DXDTEMP)->DXD_CLACOM, (__DXDTEMP)->DXD_PRDTOR, (__DXDTEMP)->DXD_LJPRO, (__DXDTEMP)->DXD_FAZ) > 0

									//Busca os fardos para safra, regra e tipo comercial
									dbSelectArea(__cAliasFr)
									(__cAliasFr)->(dbSetOrder(2))
									If (__cAliasFr)->(MsSeek((__DXDTEMP)->DXD_FILIAL+(__DXDTEMP)->DXD_SAFRA+cNextPD+(__DXDTEMP)->DXD_CLACOM + ;
									IIF(MV_PAR02 == 2,(__DXDTEMP)->DXD_PRDTOR+(__DXDTEMP)->DXD_LJPRO,;
									IIF(MV_PAR02 == 3,(__DXDTEMP)->DXD_PRDTOR+(__DXDTEMP)->DXD_LJPRO+(__DXDTEMP)->DXD_FAZ,""))))

										While (__cAliasFr)->(!Eof()) .And. ;
										(__cAliasFr)->F_FILIAL = (__DXDTEMP)->DXD_FILIAL .And. ;
										(__cAliasFr)->F_SAFRA  = (__DXDTEMP)->DXD_SAFRA  .And. ;
										(__cAliasFr)->F_PADRAO = cNextPD .And. ;
										(__cAliasFr)->F_CLACOM = (__DXDTEMP)->DXD_CLACOM .And. ;
										IIF(MV_PAR02 == 2,(__cAliasFr)->F_PRDTOR = (__DXDTEMP)->DXD_PRDTOR .And. (__cAliasFr)->F_LJPRO = (__DXDTEMP)->DXD_LJPRO,;
										IIF(MV_PAR02 == 3,(__cAliasFr)->F_PRDTOR = (__DXDTEMP)->DXD_PRDTOR .And. (__cAliasFr)->F_LJPRO = (__DXDTEMP)->DXD_LJPRO .And. (__cAliasFr)->F_FAZ = (__DXDTEMP)->DXD_FAZ, 1 = 1))


											If Empty((__cAliasFr)->F_PADREP) 

												//Se o saldo necessário for maior que a quantidade de fardos 
												//já vinculadas para o bloco, então vincula o fardo corrente também 
												If nSaldo > nVinc
													If RecLock(__cAliasFr,.F.)
														(__cAliasFr)->F_BLOCO  := (__DXDTEMP)->DXD_CODIGO
														(__cAliasFr)->F_CODSEQ := (__DXDTEMP)->DXD_CODSEQ
														(__cAliasFr)->F_PADREP := (__DXDTEMP)->DXD_CODREG
														(__cAliasFr)->(MsUnlock()) 
													EndIf
													nVinc ++
												Else		
													If RecLock(__DXDTEMP, .F.)
														(__DXDTEMP)->DXD_QTDVNC += nVinc
														(__DXDTEMP)->(MsUnlock())
													EndIf
													nVinc := 0
													Exit
												EndIf 
											Endif

											(__cAliasFr)->(dbSkip())
										EndDo

										If RecLock(__DXDTEMP, .F.)
											(__DXDTEMP)->DXD_QTDVNC += nVinc
											(__DXDTEMP)->(MsUnlock())
											nVinc := 0
										EndIf
									EndIf
								Endif
							Else //Se for branco, já foram percorridos todos os padrões

								//Calcula se existem fardos a serem associados 
								nFardos := CalcFardoByRegra((__DXDTEMP)->DXD_FILIAL, (__DXDTEMP)->DXD_SAFRA, (__DXDTEMP)->DXD_CODREG, (__DXDTEMP)->DXD_CLACOM, (__DXDTEMP)->DXD_PRDTOR, (__DXDTEMP)->DXD_LJPRO, (__DXDTEMP)->DXD_FAZ) -;
								QTSRegra((__DXDTEMP)->DXD_FILIAL, (__DXDTEMP)->DXD_SAFRA, (__DXDTEMP)->DXD_CODSEQ)

								If nFardos > 0

									//Busca os fardos para safra, regra e tipo comercial
									dbSelectArea(__cAliasFr)
									(__cAliasFr)->(dbSetOrder(2))
									If (__cAliasFr)->(MsSeek((__DXDTEMP)->DXD_FILIAL+(__DXDTEMP)->DXD_SAFRA+(__DXDTEMP)->DXD_CODREG+(__DXDTEMP)->DXD_CLACOM+ ;
									IIF(MV_PAR02 == 2,(__DXDTEMP)->DXD_PRDTOR+(__DXDTEMP)->DXD_LJPRO,;
									IIF(MV_PAR02 == 3,(__DXDTEMP)->DXD_PRDTOR+(__DXDTEMP)->DXD_LJPRO+(__DXDTEMP)->DXD_FAZ,""))))

										While (__cAliasFr)->(!Eof()) .And. ;
										(__cAliasFr)->F_FILIAL = (__DXDTEMP)->DXD_FILIAL .And. ;
										(__cAliasFr)->F_SAFRA  = (__DXDTEMP)->DXD_SAFRA  .And. ;
										(__cAliasFr)->F_PADRAO = (__DXDTEMP)->DXD_CODREG .And. ;
										(__cAliasFr)->F_CLACOM = (__DXDTEMP)->DXD_CLACOM .And. ;
										IIF(MV_PAR02 == 2,(__cAliasFr)->F_PRDTOR = (__DXDTEMP)->DXD_PRDTOR .And. (__cAliasFr)->F_LJPRO = (__DXDTEMP)->DXD_LJPRO,;
										IIF(MV_PAR02 == 3,(__cAliasFr)->F_PRDTOR = (__DXDTEMP)->DXD_PRDTOR .And. (__cAliasFr)->F_LJPRO = (__DXDTEMP)->DXD_LJPRO .And. (__cAliasFr)->F_FAZ = (__DXDTEMP)->DXD_FAZ, 1 = 1)) 


											If (__cAliasFr)->F_CODSEQ  <> (__DXDTEMP)->DXD_CODSEQ .And.;
											Empty((__cAliasFr)->F_PADREP) 

												//Se o saldo necessário for maior que a quantidade de fardos 
												//já vinculadas para o bloco, então vincula o fardo corrente também 				
												If nSaldo > nVinc
													If RecLock(__cAliasFr,.F.)
														nVinc ++
														(__cAliasFr)->F_BLOCO  := (__DXDTEMP)->DXD_CODIGO
														(__cAliasFr)->F_CODSEQ := (__DXDTEMP)->DXD_CODSEQ
														(__cAliasFr)->F_PADREP := (__DXDTEMP)->DXD_CODREG
														(__cAliasFr)->(MsUnlock()) 
													EndIf							    					
												Else
													If RecLock(__DXDTEMP, .F.)
														(__DXDTEMP)->DXD_QTDVNC += nVinc
														(__DXDTEMP)->(MsUnlock())
													EndIf
													nVinc := 0
													Exit
												EndIf 
											EndIf

											(__cAliasFr)->(dbSkip())
										EndDo

										If RecLock(__DXDTEMP, .F.)
											(__DXDTEMP)->DXD_QTDVNC += nVinc
											(__DXDTEMP)->(MsUnlock())
											nVinc := 0
										EndIf
									EndIf
								Else
									Exit
								EndIf
							Endif						    	
						EndDo					
					EndIf

					Processa({|| ReviewBloco() }, STR0018/*"Aguarde"*/, STR0021/*"Realizando conferência dos blocos simulados"*/,.F.)
					
					dbSelectArea(__DXDTEMP)

					(__DXDTEMP)->(dbSkip())
				EndDo
			EndIf
		EndIf	

		(cAliasN80)->(dbSkip())
	EndDo

	(cAliasN80)->(dbCloseArea())

	/*******************************************/
	/* Chama função para revisar os registros  */
	/* dos blocos e deletar os que ficaram sem */
	/* fardos vinculados ou atualizar a        */
	/* quantidade de fardos vinculados         */	
	/*******************************************/
	Processa({|| ReviewBloco() }, STR0018/*"Aguarde"*/, STR0021/*"Realizando conferência dos blocos simulados"*/,.F.)
	/*******************************************/

	RestArea(aArea)
Return .T.


/*/{Protheus.doc} GetNextStandard
//Retorna o próximo nivel de regra de emblocamento
@author bruna.rocio
@since 26/05/2017
@version 12.1.20
@param cRegra, characters, código de regra de emblocamento corrente
@type function
/*/
Static Function GetNextStandard(cRegra)
	Local cNext := ""
	Local nPos  := 0

	nPos := aScan(__aReleva, {|X| Alltrim(x[1]) = AllTrim(cRegra) })

	If nPos > 0 .And. nPos < Len(__aReleva)
		cNext := __aReleva[nPos+1,1]
	EndIf
Return cNext



/*/{Protheus.doc} CalcFardoByRegra
//Totaliza quantidade de fardos que atendem determinado tipo e regra
@author bruna.rocio
@since 26/05/2017
@version 12.1.20
@param cSafra, characters, safra que está sendo considerada
@param cRegra, characters, regra cujos fardos devem ser contabilizados
@param cTipo , characters, tipo comercial cujos fardos devem ser contabilizados
@type function
/*/
Static Function CalcFardoByRegra(cFilBlc, cSafra, cRegra, cTipo, cProdutor, cLoja, cFazenda)
	Local aArea     := GetArea()
	Local nFarBloco := 0 

	Pergunte('UBAA070003', .F.)

	dbSelectArea(__cAliasFr)
	(__cAliasFr)->(dbSetOrder(2))
	//Encontra bloco do padrão  e tipo informado
	If (__cAliasFr)->(msSeek(cFilBlc+cSafra+cRegra+cTipo+;
	IIF(MV_PAR02 == 2, cProdutor+cLoja,;
	IIF(MV_PAR02 == 3, cProdutor+cLoja+cFazenda,"")))) 

		While (__cAliasFr)->(!Eof()) .And. ;
		(__cAliasFr)->F_FILIAL = cFilBlc .And. ;
		(__cAliasFr)->F_SAFRA  = cSafra  .And. ;
		(__cAliasFr)->F_PADRAO = cRegra  .And. ;
		(__cAliasFr)->F_CLACOM = cTipo   .And. ;
		IIF(MV_PAR02 == 2, (__cAliasFr)->F_PRDTOR = cProdutor .And. (__cAliasFr)->F_LJPRO = cLoja,;
		IIF(MV_PAR02 == 3, (__cAliasFr)->F_PRDTOR = cProdutor .And. (__cAliasFr)->F_LJPRO = cLoja .And. (__cAliasFr)->F_FAZ = cFazenda, 1 = 1)) 


			If Empty( (__cAliasFr)->F_PADREP) 	
				nFarBloco ++
			Endif	

			(__cAliasFr)->(dbSkip())
		EndDo
	EndIf	

	RestArea(aArea)
Return nFarBloco


/*/{Protheus.doc} QTSRegra
//TODO Descrição auto-gerada.
@author bruna.rocio
@since 14/06/2017
@version undefined
@param cSafra, characters, descricao
@param cBloco, characters, descricao
@type function
/*/
Static Function QTSRegra(cFilBlc, cSafra, cCodSeq)
	Local aArea      := GetArea()
	Local nQtdFardos := 0

	Pergunte('UBAA070003', .F.)
	
	dbSelectArea(__cAliasFr)
	(__cAliasFr)->(dbSetOrder(4))	
	If (__cAliasFr)->(MsSeek(cFilBlc+cSafra+cCodSeq+;
	IIF(MV_PAR02 == 2, (__DXDTEMP)->DXD_PRDTOR+(__DXDTEMP)->DXD_LJPRO,;
	IIF(MV_PAR02 == 3, (__DXDTEMP)->DXD_PRDTOR+(__DXDTEMP)->DXD_LJPRO+(__DXDTEMP)->DXD_FAZ,""))))
		While (__cAliasFr)->(!Eof())       .And. ;
		(__cAliasFr)->F_FILIAL = cFilBlc .And. ;
		(__cAliasFr)->F_SAFRA  = cSafra  .And. ;
		(__cAliasFr)->F_CODSEQ = cCodSeq  .And. ;
		IIF(MV_PAR02 == 2, (__cAliasFr)->F_PRDTOR = (__DXDTEMP)->DXD_PRDTOR .And. (__cAliasFr)->F_LJPRO = (__DXDTEMP)->DXD_LJPRO,;
		IIF(MV_PAR02 == 3, (__cAliasFr)->F_PRDTOR = (__DXDTEMP)->DXD_PRDTOR .And. (__cAliasFr)->F_LJPRO = (__DXDTEMP)->DXD_LJPRO .And. (__cAliasFr)->F_FAZ = (__DXDTEMP)->DXD_FAZ, 1 = 1) )


			If Empty((__cAliasFr)->F_PADREP)
				nQtdFardos ++
			Endif	
			(__cAliasFr)->(dbSkip())
		EndDo
	EndIf

	RestArea(aArea)
Return nQtdFardos


/*/{Protheus.doc} ReviewBloco
//Revisa os blocos e deleta os que não possuem mais fardos
@author bruna.rocio
@since 26/05/2017
@version 12.1.20
@type function
/*/
Static Function ReviewBloco()
	Local aArea := GetArea()

	Pergunte('UBAA070003', .F.)

	dbSelectArea(__DXDTEMP)
	(__DXDTEMP)->(dbGoTop())

	While (__DXDTEMP)->(!Eof())
	

		If CtbFrdByBloco((__DXDTEMP)->DXD_FILIAL, (__DXDTEMP)->DXD_SAFRA, (__DXDTEMP)->DXD_CODSEQ, (__DXDTEMP)->DXD_PRDTOR, (__DXDTEMP)->DXD_LJPRO, (__DXDTEMP)->DXD_FAZ) <= 0
			If RecLock(__DXDTEMP, .F.)
				(__DXDTEMP)->(dbDelete())
				(__DXDTEMP)->(MsUnlock())
			EndIf
		ElseIf (__DXDTEMP)->DXD_QTDMAX = CtbFrdByBloco((__DXDTEMP)->DXD_FILIAL,(__DXDTEMP)->DXD_SAFRA, (__DXDTEMP)->DXD_CODSEQ, (__DXDTEMP)->DXD_PRDTOR, (__DXDTEMP)->DXD_LJPRO, (__DXDTEMP)->DXD_FAZ, @__DXDTEMP)

			dbSelectArea(__cAliasFr)
			(__cAliasFr)->(dbSetOrder(4))
			If (__cAliasFr)->(MsSeek((__DXDTEMP)->DXD_FILIAL+(__DXDTEMP)->DXD_SAFRA+(__DXDTEMP)->DXD_CODSEQ + ;
			IIF(MV_PAR02 == 2,(__DXDTEMP)->DXD_PRDTOR+(__DXDTEMP)->DXD_LJPRO,;
			IIF(MV_PAR02 == 3,(__DXDTEMP)->DXD_PRDTOR+(__DXDTEMP)->DXD_LJPRO+(__DXDTEMP)->DXD_FAZ,""))))


				While (__cAliasFr)->(!Eof())                     .And. ;
				(__cAliasFr)->F_FILIAL = (__DXDTEMP)->DXD_FILIAL .And. ;
				(__cAliasFr)->F_SAFRA  = (__DXDTEMP)->DXD_SAFRA  .And. ;
				(__cAliasFr)->F_CODSEQ = (__DXDTEMP)->DXD_CODSEQ .And. ;
				IIF(MV_PAR02 == 2,(__cAliasFr)->F_PRDTOR = (__DXDTEMP)->DXD_PRDTOR .And. (__cAliasFr)->F_LJPRO = (__DXDTEMP)->DXD_LJPRO,;
				IIF(MV_PAR02 == 3,(__cAliasFr)->F_PRDTOR = (__DXDTEMP)->DXD_PRDTOR .And. (__cAliasFr)->F_LJPRO = (__DXDTEMP)->DXD_LJPRO .And. (__cAliasFr)->F_FAZ = (__DXDTEMP)->DXD_FAZ, 1 = 1)) 


					If RecLock(__cAliasFr,.F.)
						(__cAliasFr)->F_PADREP := (__DXDTEMP)->DXD_CODREG
						(__cAliasFr)->(MsUnlock())
					Endif
					(__cAliasFr)->(dbSkip())	
				EndDo
			EndIf
		Else	
			If RecLock(__DXDTEMP, .F.)
				(__DXDTEMP)->DXD_QTDVNC := CtbFrdByBloco((__DXDTEMP)->DXD_FILIAL,(__DXDTEMP)->DXD_SAFRA, (__DXDTEMP)->DXD_CODSEQ, (__DXDTEMP)->DXD_PRDTOR, (__DXDTEMP)->DXD_LJPRO, (__DXDTEMP)->DXD_FAZ, @__DXDTEMP)
				(__DXDTEMP)->(MsUnlock())
			EndIf
		EndIf

		(__DXDTEMP)->(dbSkip())
	EndDo

	RestArea(aArea)
Return .T.



/*/{Protheus.doc} CtbFrdByBloco
//Contabiliza quantidade de fardos por bloco e safra
@author bruna.rocio
@since 26/05/2017
@version 12.1.20
@param cSafra, characters, safra do bloco
@param cCodSeq, characters, código sequencial de bloco para contabilização
@type function
/*/
Static Function CtbFrdByBloco(cFilBlc, cSafra, cCodSeq, cProdutor, cLoja, cFazenda, __DXDTEMP)
	Local aArea      := GetArea()
	Local nQtdFardos := 0
	Local nUHM := 0
	Local nMIC := 0
	Local nRES := 0

	Pergunte('UBAA070003', .F.)
	
	dbSelectArea(__cAliasFr)
	(__cAliasFr)->(dbSetOrder(4))	
	If (__cAliasFr)->(MsSeek(cFilBlc+cSafra+cCodSeq+;
	IIF(MV_PAR02 == 2, cProdutor+cLoja,;
	IIF(MV_PAR02 == 3, cProdutor+cLoja+cFazenda,""))))
		While (__cAliasFr)->(!Eof())         .And. ;
		(__cAliasFr)->F_FILIAL = cFilBlc .And. ;
		(__cAliasFr)->F_SAFRA  = cSafra  .And. ;
		(__cAliasFr)->F_CODSEQ = cCodSeq  .And. ;
		IIF(MV_PAR02 == 2,(__cAliasFr)->F_PRDTOR = cProdutor .And. (__cAliasFr)->F_LJPRO = cLoja,;
		IIF(MV_PAR02 == 3,(__cAliasFr)->F_PRDTOR = cProdutor .And. (__cAliasFr)->F_LJPRO = cLoja .And. (__cAliasFr)->F_FAZ = cFazenda, 1 = 1)) 

			nQtdFardos ++
			ColetaHvi((__cAliasFr)->F_FILIAL + (__cAliasFr)->F_SAFRA + (__cAliasFr)->F_ETIQ, @nUHM,@nMIC,@nRES)

			If ValType(__DXDTEMP) != "U"
				If RecLock(__DXDTEMP, .F.)
					If nQtdFardos == 1 .Or. (__DXDTEMP)->DXD_FDINI > (__cAliasFr)->F_FARDO
						(__DXDTEMP)->DXD_FDINI  = (__cAliasFr)->F_FARDO
					EndIf
					If nQtdFardos == 1 .Or. (__DXDTEMP)->DXD_FDFIN < (__cAliasFr)->F_FARDO
						(__DXDTEMP)->DXD_FDFIN  = (__cAliasFr)->F_FARDO
					EndIf
					(__DXDTEMP)->DX7_UHM := nUHM /  nQtdFardos
					(__DXDTEMP)->DX7_MIC := nMIC /  nQtdFardos
					(__DXDTEMP)->DX7_RES := nRES /  nQtdFardos
					(__DXDTEMP)->(MsUnlock())
				EndIf
			EndIf

			(__cAliasFr)->(dbSkip())
		EndDo
	EndIf

	RestArea(aArea)
Return nQtdFardos

/*/{Protheus.doc} VerifyBlocos
//
@author bruna.rocio
@since 24/07/2017
@version undefined
@type function
/*/
Static Function VerifyBlocos(cFilBlc,cSafra)
	Local aArea := GetArea()
	Local lRet  := .T.
	
	DbSelectArea(__DXDTEMP)
	dbSetOrder(3)
	If MsSeek(cFilBlc+cSafra+"2") //Somente fardos já persistidos
		While (__DXDTEMP)->(!Eof()) .And.  (__DXDTEMP)->DXD_FILIAL = cFilBlc .And. (__DXDTEMP)->DXD_SAFRA = cSafra .And. (__DXDTEMP)->DXD_NOVO = "2"


			dbSelectArea(__cAliasFr)
			dbSetOrder(3)
			If !MsSeek((__DXDTEMP)->DXD_FILIAL+(__DXDTEMP)->DXD_SAFRA+(__DXDTEMP)->DXD_CODSEQ+"1") //Verifica se há algum fardo novo relacionado

				//Se não há fardo relacionado, busca todos os já persistidos e deleta da temp table
				If MsSeek((__DXDTEMP)->DXD_FILIAL+(__DXDTEMP)->DXD_SAFRA+(__DXDTEMP)->DXD_CODSEQ+"2") 
					While (__cAliasFr)->(!Eof())                     .And. ;
					(__cAliasFr)->F_FILIAL = (__DXDTEMP)->DXD_FILIAL .And. ;
					(__cAliasFr)->F_SAFRA  = (__DXDTEMP)->DXD_SAFRA  .And. ;
					(__cAliasFr)->F_CODSEQ = (__DXDTEMP)->DXD_CODSEQ .And. ;
					(__cAliasFr)->F_NOVO   = "2"

						If RecLock(__cAliasFr,.F.)
							dbDelete()
							MsUnlock()
						EndIf

						(__cAliasFr)->(dbSkip()) 
					EndDo
					//Por fim, deleta o bloco
					dbSelectArea(__DXDTEMP)
					If RecLock(__DXDTEMP,.F.)
						dbDelete()
						MsUnlock()
					EndIf
				EndIf
			Endif

			dbSelectArea(__DXDTEMP)
			(__DXDTEMP)->(dbSkip())
		EndDo
	Endif

	RestArea(aArea)
Return lRet



/*/{Protheus.doc} EstruFrd
//Estrutura da tabela de Fardos
@author carlos.augusto
@since 07/06/2017
@version 12.1.20
@type function
/*/
Static Function EstruFrd()

	If (Len(__aEstrFrd) = 0)
		aAdd(__aEstrFrd,{ "F_FILIAL", TamSX3("DXI_FILIAL")[3], TamSX3("DXI_FILIAL")[1], TamSX3("DXI_FILIAL")[2], AGRTITULO("DXI_FILIAL") , PesqPict("DXI", "DXI_FILIAL")} )
		Aadd(__aEstrFrd,{ "F_MALA"  , "C", TamSX3( "DXJ_CODIGO" )[ 1 ], 0                           , STR0032				  , PesqPict("DXJ","DXJ_CODIGO") }) //Mala
		Aadd(__aEstrFrd,{ "F_ETIQ"  , "C", TamSX3( "DXI_ETIQ" )[ 1 ]  , 0                           , AGRTITULO("DXI_ETIQ")	  , PesqPict("DXI","DXI_ETIQ")  }) //Etiqueta	
		Aadd(__aEstrFrd,{ "F_FARDO" , "C", TamSX3( "DXI_CODIGO" )[ 1 ], 0                           , AGRTITULO("DXK_FARDO")  , PesqPict("DXI","DXI_CODIGO")}) //Fardo
		Aadd(__aEstrFrd,{ "F_PSLIQU", "N", TamSX3( "DXI_PSLIQU" )[ 1 ], TamSX3( "DXI_PSLIQU" )[ 2 ] , AGRTITULO("DXI_PSLIQU") , PesqPict("DXI","DXI_PSLIQU")}) //Peso
		Aadd(__aEstrFrd,{ "F_DESPDR", "C", TamSX3( "N80_NMEMBL" )[ 1 ], 0 							, AGRTITULO("DXI_CODREG") , PesqPict("N80","N80_NMEMBL") }) //Nome.Pad
		Aadd(__aEstrFrd,{ "F_CRITER", "C", 100                        , 0                           , STR0006				  , "@!" })						  //Result.Ana
		Aadd(__aEstrFrd,{ "F_BLOCO" , "C", TamSX3( "DXD_CODIGO" )[ 1 ], 0                           , AGRTITULO("DXI_BLOCO")  , PesqPict("DXI","DXI_BLOCO") }) //Bloco
		Aadd(__aEstrFrd,{ "F_CODSEQ", "C", TamSX3( "DXD_CODIGO" )[ 1 ], 0                           , AGRTITULO("DXI_BLOCO")  , PesqPict("DXI","DXI_BLOCO") }) //Bloco
		Aadd(__aEstrFrd,{ "F_SAFRA" , "C", TamSX3( "DXI_SAFRA" )[ 1 ] , 0                           , STR0001				  , PesqPict("DXI","DXI_SAFRA") }) //Safra
		Aadd(__aEstrFrd,{ "F_CLACOM", "C", TamSX3( "DXD_CLACOM")[ 1 ] , 0 							, STR0003				  , PesqPict("DXI","DXI_CLACOM")}) //Clas.Com
		Aadd(__aEstrFrd,{ "F_PADRAO", "C", TamSX3( "N80_CODIGO")[ 1 ] , 0 							, STR0008				  , PesqPict("N80","N80_CODIGO") })//Padrão	
		Aadd(__aEstrFrd,{ "F_PADREP", "C", TamSX3( "N80_CODIGO")[ 1 ] , 0 							, STR0008				  , PesqPict("N80","N80_CODIGO") })//Padrão				  
		Aadd(__aEstrFrd,{ "F_NOVO"  , "C",                           1, 0 							, STR0090				  , "@!" }) //Indica se o relacionamento do fardo com o bloco é novo 1=Sim/2=Não //Bloco novo
		Aadd(__aEstrFrd,{ "F_PRDTOR", "C", TamSX3( "DXI_PRDTOR" )[ 1 ], 0 							, AGRTITULO("DXI_PRDTOR") , PesqPict("DXI","DXI_PRDTOR") })//Produtor
		Aadd(__aEstrFrd,{ "F_LJPRO" , "C",  TamSX3( "DXI_LJPRO" )[ 1 ] , 0 							, AGRTITULO("DXI_LJPRO")  , PesqPict("DXI","DXI_LJPRO") })//Loja
		Aadd(__aEstrFrd,{ "F_FAZ"   , "C", TamSX3( "DXI_FAZ" )[ 1 ]   , 0 							, AGRTITULO("DXI_FAZ")	  , PesqPict("DXI","DXI_FAZ") })//Fazenda
	EndIf

Return __aEstrFrd


/*/{Protheus.doc} TempFrd
//Cria arquivo temporario para fardos
@author carlos.augusto
@since 07/06/2017
@version 12.1.20
@type function
/*/
Static Function TempFrd(__cAliasFr)

	Local oAliasFr
	
	oAliasFr := AGRCRTPTB(__cAliasFr, {EstruFrd(), {{"", "F_FILIAL,F_SAFRA,F_ETIQ" },;
	{"", "F_FILIAL,F_SAFRA,F_PADRAO,F_CLACOM,F_PRDTOR,F_LJPRO,F_FAZ"},;
	{"", "F_FILIAL,F_SAFRA,F_CODSEQ,F_NOVO"},;
	{"", "F_FILIAL,F_SAFRA,F_CODSEQ,F_PRDTOR,F_LJPRO,F_FAZ"},;
	{"", "F_FILIAL,F_SAFRA,F_CODSEQ,F_PADRAO"}} }) 


Return oAliasFr

/*/{Protheus.doc} fZapTRB
//Deleta todos os dados de uma tabela temporária
@author bruna.rocio
@since 01/08/2016
@version 12.1.17
@param pcAliasTRB, , Alias da tabela temporária que deve ser limpa
@type function
/*/
Static Function fZapTRB( pcAliasTRB )
	Local aAreaAtu	 	:= GetArea()

	If Select( pcAliasTRB ) > 0
		DbSelectArea( pcAliasTRB )
		( pcAliasTRB )->(DbGoTop())
		While ( pcAliasTRB )->(!Eof())
			If RecLock(pcAliasTRB, .F.)
				dbDelete()
				MsUnlock()
			Endif
			( pcAliasTRB )->(dbSkip())
		EndDo
	Endif

	RestArea( aAreaAtu )
Return( NIL )

/*/{Protheus.doc} ValidEntr
//Valid o preenchimento de safra para todos os itens marcados
@author carlos.augusto
@since 05/06/2017
@version 12.1.20
@type function
/*/
Static Function ValidEntr(oModel)
	Local aSaveLines := FWSaveRows()
	Local lRet 			:= .T.
	Local nz
	Local oGridVT 		:= oModel:GetModel('UBAA070_VT')
	Local lRegSelec 	:= .F.

	For nZ := 1 to oGridVT:Length() 
		oGridVT:Goline(nZ)
		If oGridVT:GetValue('VT_SELEC')
			lRegSelec := .T.
		EndIf


		If oGridVT:GetValue('VT_SELEC') .And. Empty(oGridVT:GetValue('VT_CODSAF'))
			Help("",1,STR0025,,STR0026,1)
			//"Atenção"###".""Favor preencher o campo Safra para todos os itens marcados." 
			lRet := .F.
			exit		
		EndIf
	Next nZ

	If !lRegSelec
		Help('' ,1,".UBAA07000207.", , ,1,0) /* Nenhuma filial selecionada.Favor marcar pelo menos uma filial. */
		lRet := .F.
	EndIf
	FwRestRows(aSaveLines)

Return lRet

/*/{Protheus.doc} UBAA070COL
////Analisa se as colunas produtor e fazenda devem ser apresentadas
@author carlos.augusto
@since 02/08/2017
@version undefined
@param __oBrwBloco, object, descricao
@type function
/*/
Static Function UBAA070COL()
	Local aSaveLines := FWSaveRows()

/* Browse Mala Coluna:
 1 = Marca, 2 = Filial, 3 = Safra, 4 = Código, 5 = Qt. Vinc, ? , Ini. Seq. Fard, Fim. Seq. Fard. */

/* Browse Bloco Coluna:
 1 = Marca, 		2 = Filial, 		3 = Safra, 			4 = Bloco, 			5 = Bloco, 		6 = Class.Com., 	7 = Nome Embl, 		8 = Pct. Form., 
 9 = Qrd. Vinc.,	10 = Entidade		11 = Lj. Entidade,	12 = Nome Entid.,	13 = Fazenda,	14 = Nome Fazenda,	15 = Fardo Ini.,	16 = Fardo Fin.,
 17 = Reg. Embl,	18 = Result. Ana,	19 = Bloco Novo,	20 = Mic,			21 = UHM,		22 = Res,			23 = UN. Benef,		24 = Peso Bruto */

	Pergunte('UBAA070003', .F.)
	
	If __oBrwMala <> Nil
		__oBrwMala:DelColumn(2)
		__oBrwMala:DelColumn(3)
	EndIf
	
	If __oBrwBloco <> Nil
	
		__oBrwBloco:DelColumn(17)
		__oBrwBloco:DelColumn(19)
		__oBrwBloco:DelColumn(24)
	
		Do Case	
			Case MV_PAR02 == 1 //Nenhum
			
			__oBrwBloco:DelColumn(2)
			__oBrwBloco:DelColumn(3)
			__oBrwBloco:DelColumn(5)
			
			__oBrwBloco:DelColumn(10)
			__oBrwBloco:DelColumn(11)
			__oBrwBloco:DelColumn(12)
			__oBrwBloco:DelColumn(13)
			__oBrwBloco:DelColumn(14)
			
			Case MV_PAR02 == 2 //Produtor
			
			__oBrwBloco:DelColumn(2)
			__oBrwBloco:DelColumn(3)
			__oBrwBloco:DelColumn(5)
			
			__oBrwBloco:DelColumn(13)
			__oBrwBloco:DelColumn(14)
			
			__oBrwBloco:RecoveryColumn(10)
			__oBrwBloco:RecoveryColumn(11)
			__oBrwBloco:RecoveryColumn(12)
			
			Case MV_PAR02 == 3 //Produtor/Fazenda
			
			__oBrwBloco:DelColumn(2)
			__oBrwBloco:DelColumn(3)
			__oBrwBloco:DelColumn(5)
			
			__oBrwBloco:RecoveryColumn(10)
			__oBrwBloco:RecoveryColumn(11)
			__oBrwBloco:RecoveryColumn(12)
			__oBrwBloco:RecoveryColumn(13)
			__oBrwBloco:RecoveryColumn(14)
		EndCase
	EndIf
	
	__oBrwBloco:UpdateBrowse()
	__oBrwBloco:Save()
	FwRestRows(aSaveLines)
return



/*/{Protheus.doc} PersisteEmbl
//Pré função de persistencia dos dados do bloco
@author bruna.rocio
@since 17/07/2017
@version undefined
@param __oBrwBloco, object, descricao
@type function
/*/
Static Function PersisteEmbl(__oBrwBloco, oModel)
	Local oView 		:= FWViewActive()
	Local oModel 		:= FWModelActive()
	Local aArea 		:= GetArea()
	Local lRet      	:= .T.	
	Local cFilTemp 		:= cFilAnt
	Local aSaveLines 	:= FWSaveRows()
	Local nCont         := 0
	Local oGridVT   	:= oModel:GetModel('UBAA070_VT')
	Local cFilSel   	:= oGridVT:GetValue('VT_FILIAL')
	Local cSafSel   	:= oGridVT:GetValue('VT_CODSAF')
	Local lRegMark		:= .F. //Indica se tem registros marcados
	Local aFilBkp 		:= UBAA070BKP(oModel) //Guardar filiais marcadas
				
	Private _aBlocosOk 	:= {}
	
	dbSelectArea(__DXDTEMP)
	
	(__DXDTEMP)->( dbGoTop())
	(__DXDTEMP)->(DbEval({|x| nCont++}))
	
	ProcRegua(nCont)
	IncProc(STR0078)//"Processando blocos"
	
	(__DXDTEMP)->( dbGoTop() )
	While !(__DXDTEMP)->( Eof() )

		If (__DXDTEMP)->SELEC = __cMarca
			lRegMark := .T.
			cFilAnt := (__DXDTEMP)->DXD_FILIAL
			lRet := CreateBloco((__DXDTEMP)->DXD_FILIAL,(__DXDTEMP)->DXD_SAFRA, (__DXDTEMP)->DXD_CODIGO,(__DXDTEMP)->DXD_CODSEQ, (__DXDTEMP)->DXD_PRDTOR, (__DXDTEMP)->DXD_LJPRO, (__DXDTEMP)->DXD_FAZ, (__DXDTEMP)->DXD_NOVO)					
		EndIf

		(__DXDTEMP)->( dbSkip() )
	EndDo


	If lRegMark
		//emissão do relatório
		If MsgYesNo(STR0070)
			//passa array para relatório quebrar os blocos
			AGRAR650B(cFilSel, cSafSel, _aBlocosOk)
		EndIf	
		
		Pergunte('UBAA070002', .F.)
		If !Empty(MV_PAR02) .And. !Empty(_aBlocosOk)
			U70EnvAlrt(oModel, cFilSel, cSafSel)
		EndIf
		
		If Empty(MV_PAR02)
			Help('' ,1,".UBAA07000208.", , ,1,0) /* E-mail não enviado. Pressione a tecla F11 e informe o template de e-mail, por gentileza. */
			
		EndIf
	
		cFilAnt := cFilTemp	
		__oBrwBloco:Refresh(.T.)
		//Devolver filiais marcadas
		UBAA070UPD(oModel, aFilBkp)
		FwRestRows(aSaveLines)
		oView:Refresh()
	Else
		lRet := .F.
		Help('' ,1,".UBAA07000205.", , ,1,0) /* Para gerar o emblocamento é necessário processar e selecionar o(s) bloco(s) desejado(s). */ /* Realize as ações solicitadas, por gentileza. */		
	EndIf

	oModel:Activate()
	RestArea(aArea)
	
Return lRet


/*/{Protheus.doc} CreateBloco
//Função que realiza a persistencia dos dados do bloco
@author bruna.rocio
@since 17/07/2017
@version undefined

@type function
/*/
Static Function CreateBloco(cFilBlc, cSafra, cBloco,cCodSeq, cProdutor, cLoja, cFazenda, cNovo)
	Local aArea     := GetArea()
	Local lRet      := .T.
	Local oMdlBloco := FwLoadModel('AGRA650')

	Pergunte('UBAA070003', .F.)
	If cNovo = '1' //Novo Bloco 
		oMdlBloco:SetOperation(3)

		If oMdlBloco:Activate()

			cBloco := GetSXENum("DXD","DXD_CODIGO")

			oMdlBloco:SetValue('CABEC','DXD_FILIAL',(__DXDTEMP)->DXD_FILIAL)
			oMdlBloco:SetValue('CABEC','DXD_CODIGO', cBloco)
			oMdlBloco:SetValue('CABEC','DXD_SAFRA' ,(__DXDTEMP)->DXD_SAFRA)
			oMdlBloco:SetValue('CABEC','DXD_CLACOM',(__DXDTEMP)->DXD_CLACOM)
			oMdlBloco:SetValue('CABEC','DXD_QTDMAX',(__DXDTEMP)->DXD_QTDMAX)
			oMdlBloco:SetValue('CABEC','DXD_QTDVNC',(__DXDTEMP)->DXD_QTDVNC)
			oMdlBloco:SetValue('CABEC','DXD_DATAEM',dDatabase)
			oMdlBloco:SetValue('CABEC','DXD_CODREG',(__DXDTEMP)->DXD_CODREG)
			oMdlBloco:SetValue('CABEC','DXD_FDINI' ,(__DXDTEMP)->DXD_FDINI)
			oMdlBloco:SetValue('CABEC','DXD_FDFIN' ,(__DXDTEMP)->DXD_FDFIN)
			oMdlBloco:SetValue('CABEC','DXD_PCTFOR', (__DXDTEMP)->PCTFOR)
			oMdlBloco:SetValue('CABEC','DXD_CODUNB', (__DXDTEMP)->DXD_CODUNB)
			oMdlBloco:SetValue('CABEC','DXD_STATUS', (__DXDTEMP)->DXD_STATUS)
			oMdlBloco:SetValue('CABEC','DXD_TIPEMB', IIF(.Not. Empty(__cCodRegra),"3","1"))
			
			If (__DXDTEMP)->DXD_STATUS == "3" // 3 - Finalizado
			
				// Atualiza a data e hora da inclusão para incluir o bloco no aplicativo do Beneficiamento
				oMdlBloco:SetValue('CABEC','DXD_DATATU', dDatabase)
				oMdlBloco:SetValue('CABEC','DXD_HORATU', Time())
			EndIf
			
			//Quando usa quebra, grava informação no bloco
			If MV_PAR02 = 2 //Produtor
				oMdlBloco:SetValue('CABEC','DXD_PRDTOR',(__DXDTEMP)->DXD_PRDTOR)
				oMdlBloco:SetValue('CABEC','DXD_LJPRO',(__DXDTEMP)->DXD_LJPRO)
			ElseIf MV_PAR02 = 3 //Produtor - Fazenda
				oMdlBloco:SetValue('CABEC','DXD_PRDTOR',(__DXDTEMP)->DXD_PRDTOR)
				oMdlBloco:SetValue('CABEC','DXD_LJPRO' ,(__DXDTEMP)->DXD_LJPRO)
				oMdlBloco:SetValue('CABEC','DXD_FAZ' ,(__DXDTEMP)->DXD_FAZ)
			Endif
			
			IncProc( STR0079 +" - "+ cBloco) //"Criando bloco"

			If oMdlBloco:VldData()
				lRet := oMdlBloco:CommitData()
				If lRet
					aAdd( _aBlocosOk, {cBloco, (__DXDTEMP)->DXD_QTDVNC })
				EndIf

			Else
				lRet := .F.
				Help( ,,STR0025,, oMdlBloco:GetErrorMessage()[6], 1, 0 ) //"Atenção"###
			Endif	
			oMdlBloco:DeActivate()
		Endif
	Else
		dbSelectArea('DXD')
		dbSetOrder(1)
		If MsSeek(fwxFilial("DXD")+cSafra+cBloco)

			oMdlBloco:SetOperation(4)

			If oMdlBloco:Activate()
				oMdlBloco:SetValue('CABEC','DXD_QTDVNC',(__DXDTEMP)->DXD_QTDVNC)
				oMdlBloco:SetValue('CABEC','DXD_STATUS',(__DXDTEMP)->DXD_STATUS)
				oMdlBloco:SetValue('CABEC','DXD_FDINI' ,(__DXDTEMP)->DXD_FDINI)
				oMdlBloco:SetValue('CABEC','DXD_FDFIN' ,(__DXDTEMP)->DXD_FDFIN)
				oMdlBloco:SetValue('CABEC','DXD_PCTFOR', (__DXDTEMP)->PCTFOR)
				
				If (__DXDTEMP)->DXD_STATUS == "3" // 3 - Finalizado
			
					// Atualiza a data e hora de alteração para incluir/alterar o bloco no aplicativo do Beneficiamento
					oMdlBloco:SetValue('CABEC','DXD_DATATU', dDatabase)
					oMdlBloco:SetValue('CABEC','DXD_HORATU', Time())
				EndIf
				
				IncProc(STR0080+" - "+cBloco)//"Alterando bloco"

				If oMdlBloco:VldData()
					lRet := oMdlBloco:CommitData()
					If lRet
						aAdd( _aBlocosOk, {cBloco, (__DXDTEMP)->DXD_QTDVNC })
					EndIf

				Else
					lRet := .F.
					Help( ,,STR0025,, oMdlBloco:GetErrorMessage()[6], 1, 0 ) //"Atenção"###
				Endif	
				oMdlBloco:DeActivate()
			Endif
		Else
			lRet := .F.
		Endif
	Endif

	If lRet
		Begin Transaction
			dbSelectArea(__cAliasFr)
			dbSetOrder(4)
			If(MsSeek(cFilBlc+cSafra+cCodSeq+;
			IIF(MV_PAR02 == 2, cProdutor+cLoja,;
			IIF(MV_PAR02 == 3, cProdutor+cLoja+cFazenda,""))))

				While !Eof()                      .And.;
				(__cAliasFr)->F_FILIAL = cFilBlc .And.;
				(__cAliasFr)->F_SAFRA  = cSafra  .And.;
				(__cAliasFr)->F_CODSEQ = cCodSeq  .And. ;
				IIF(MV_PAR02 == 2, (__cAliasFr)->F_PRDTOR = cProdutor .And. (__cAliasFr)->F_LJPRO = cLoja,;
				IIF(MV_PAR02 == 3, (__cAliasFr)->F_PRDTOR = cProdutor .And. (__cAliasFr)->F_LJPRO = cLoja .And. (__cAliasFr)->F_FAZ = cFazenda, 1 = 1)) 

					dbSelectArea('DXI')
					dbSetOrder(1)
					If MsSeek((__cAliasFr)->F_FILIAL+(__cAliasFr)->F_SAFRA+(__cAliasFr)->F_ETIQ)

						If RecLock('DXI',.F.)
							DXI->DXI_BLOCO  := cBloco
							DXI->DXI_CODREG := (__cAliasFr)->F_PADRAO
							DXI->DXI_TIPEMB	:= IIF(.Not. Empty(__cCodRegra),"3","1")
							DXI->DXI_STATUS := "30" //Emblocado
							
							// Ao informar o bloco no fardo, atualiza a data de alteração para alterar o fardo
							// no aplicativo do Beneficiamento	
							DXI->DXI_DATATU := dDatabase
							DXI->DXI_HORATU := Time()
							
							DXI->(MsUnlock())
						Endif
					Endif
					dbSelectArea(__cAliasFr)
					If RecLock(__cAliasFr,.F.)
						dbDelete()
						MsUnlock()
					Endif
					dbSkip()
				EndDo
			Endif	
			dbSelectArea(__DXDTEMP)
			If RecLock(__DXDTEMP,.F.)
				dbDelete()
				MsUnlock()
			Endif	
		End Transaction	

	Endif

	oMdlBloco:Destroy()
	
	RestArea(aArea)
Return lRet


Static Function U70EnvAlrt(oModel, cFilSel, cSafSel)
	Local cAliasAler 	:= GetNextAlias()
	Local oGridVT   	:= nil
	Local nCont			:= 0
	Local lEnvia		:= .T.
	Local nFardo		:= 0
	Local aBlocosMsg	:= {}
	Local oHash
	Local lRet			:= .T.

	oHash := aToHM(aBlocosMsg)

	oModel:Activate()
	oGridVT := oModel:GetModel('UBAA070_VT')

	BeginSql Alias cAliasAler
	select N7T_FILIAL, N7T_SAFRA, N7T_IDRANG,
	N7T_FRDINI, N7T_FRDFIM
	from %table:N7P% N7P, 
	%table:N7T% N7T
	where N7P.%notDel%
	AND N7P.N7P_FILIAL	=  %xFilial:N7P%
	AND N7P.N7P_FILIAL	=  N7T.N7T_FILIAL
	AND N7P.N7P_SAFRA	=  N7T.N7T_SAFRA
	AND N7T.N7T_STATUS	= '1'
	AND N7T.%notDel% 
	EndSql		 
	
	(cAliasAler)->(dbGoTop())
	(cAliasAler)->(DbEval({|x| nCont++}))
	
	ProcRegua(nCont + 2)
	IncProc(STR0081) //"Avaliando emails"
		
	Begin Transaction
		//verifica todos os alertas ligados
		(cAliasAler)->(dbGoTop())
		While (cAliasAler)->(!Eof())
	
			lRet	:= .T.
			lEnvia 	:= .T.
	
			dbSelectArea('DXI')
			dbSetOrder(7)		
			nFardo := val(substr((cAliasAler)->N7T_FRDINI,14,6))
			For nCont := val(substr((cAliasAler)->N7T_FRDINI,14,6)) to val(substr((cAliasAler)->N7T_FRDFIM,14,6))
				If DbSeek(cFilSel+(cAliasAler)->N7T_SAFRA+StrZero(nFardo, 6)) 
					if alltrim(DXI->DXI_BLOCO) = "" .or. DXI->DXI_BLOCO =  nil
						lEnvia := .F.
//						aBlocosMsg := {} //Para enviar email neste caso, deve-se forcar envio.// Se cadastrar varios  ranges
																							// e tiver um buraco no meio de nao emblocado
																							// Limpava todo o array
						exit
					else
						lEnvia := .T.
						If !HMGet( oHash , DXI->DXI_BLOCO)
							HMAdd(oHash,{DXI->DXI_BLOCO})
							aAdd(aBlocosMsg, {DXI->DXI_BLOCO})
						EndIf
					endIf
				else
					lEnvia := .F.
				endIf
				nFardo++	
			Next nCont
	
			if LEnvia .And. !Empty(MV_PAR02) .And. !Empty(aBlocosMsg)
							
				dbSelectArea("N7T")
				dbSetOrder(1)
				If MsSeek(cFilSel+(cAliasAler)->(N7T_SAFRA+N7T_IDRANG))
						IncProc(N7T_FRDINI+" - "+N7T_FRDFIM )
						
					If RecLock("N7T",.F.)
						N7T_STATUS  := '2'
						N7T_DTENV 	:= dDataBase
						N7T_HRENV 	:= Substr(Time(), 1, 5)
						N7T_DATATU := dDatabase
						N7T_HORATU := Time()
	
						N7T->(MsUnlock())
					endIF
				endIf

			endIf
	
			(cAliasAler)->(dbSkip())	
		EndDo	
	
		If !Empty(MV_PAR02) .And. !Empty(aBlocosMsg)
			lRet := UBAA70MAIL(cFilSel, cSafSel, aBlocosMsg)
			
			if lRet == .F.
				DisarmTransaction()
			ElseIf lRet .And. !IsInCallStack('UBAA070ALT')
							
				//Atualizacao forcada do grid de ranges 
				oModel:DeActivate()
				oModel:Activate()
							
			endIf
		EndIf
	End Transaction
	
	IncProc(STR0082)//"Finalizando envio de emails"
	
Return .T.


/*/{Protheus.doc} UBA070BTN
//Botao salvar alerta
@author carlos.augusto
@since 04/09/2017
@version undefined

@type function
/*/
Static Function UBA070BTN(oPanel,oView)
	Local oModel := FWModelActive()

	@ 010, 010 Button STR0053 /* Salvar Alerta*/ Size 50, 15 Message STR0054 /* Clique aqui para salvar o alerta */ Pixel Action {||Processa({||UBAA070ALT(oModel, oView)}, STR0084)} of oPanel//"Aguarde. Processando alertas."

Return .T.

/*/{Protheus.doc} UBA070BTN
//Botao salvar e alterar o alerta
@author carlos.augusto
@since 04/09/2017
@version undefined

@type function
/*/
Static Function UBAA070ALT(oModel)
	Local oView 	:= FwViewActive()
	Local lRet      := .T.
	Local oMdlAlert := FwLoadModel('UBAA100')
	Local oAuxN7T	:= oModel:GetModel( 'MdGrdN7T' )
	Local oFormN7P  := oModel:GetModel('MdFieldN7P')
	Local oGrid100  := oMdlAlert:GetModel('MdGrdN7T')
	
	Local oGridVT   := oModel:GetModel('UBAA070_VT')
	Local cFilSel   := oGridVT:GetValue('VT_FILIAL')
	Local cSafSel   := oGridVT:GetValue('VT_CODSAF')
	Local cFilTemp 	:= cFilAnt
	Local cMensagem := ""
	Local aFilBkp	:= {}
	Local nlinha	:= oGridVT:getLine()
	Local oViewN7T	:= oView:GetViewObj("VIEW_N7T")[3]
	
	cFilAnt := cFilSel

	If oView:HasError()
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", oModel:GetErrorMessage()[6], oModel:GetErrorMessage()[7] + cMensagem, "", "")
		lRet := .F.
	
	// campo e-mail em branco e range em branco
	ElseIf Empty(oFormN7P:GetValue('N7P_EMAIL')) .And. oGrid100:Length() = 0
		dbSelectArea('N7P')
		dbSetOrder(1)
		If MsSeek(fwxFilial("N7P")+cSafSel)
			oMdlAlert:SetOperation(4) //alterar
	
			If oMdlAlert:Activate()
	
				oMdlAlert:SetValue('MdFieldN7P','N7P_FILIAL', cFilSel)
				oMdlAlert:SetValue('MdFieldN7P','N7P_SAFRA' , cSafSel)
				oMdlAlert:SetValue('MdFieldN7P','N7P_EMAIL', oFormN7P:GetValue('N7P_EMAIL'))
				
				If oMdlAlert:VldData()
					lRet := FWFormCommit(oMdlAlert)
				EndIf	
	
				If lRet
					//Guardar filiais marcadas
					aFilBkp := UBAA070BKP(oModel)
					
					//Atualizacao forcada do grid de ranges
					oMdlAlert:DeActivate()
					oModel:DeActivate()
					oModel:Activate()
	
					//Devolver filiais marcadas
					UBAA070UPD(oModel, aFilBkp)
				EndIf
			Endif
		EndIf	
	
	//campo e-mail preenchido e range indiferente
	ElseIf !Empty(oFormN7P:GetValue('N7P_EMAIL')) //Novo Alerta
		dbSelectArea('N7P')
		dbSetOrder(1)
		If MsSeek(fwxFilial("N7P")+cSafSel)

			oMdlAlert:SetOperation(4) //alterar

			If oMdlAlert:Activate()

				oMdlAlert:SetValue('MdFieldN7P','N7P_EMAIL', oFormN7P:GetValue('N7P_EMAIL'))

				U070GrvGrd(oGrid100, oAuxN7T, cFilSel, cSafSel)

				If oMdlAlert:VldData()
					lRet := FWFormCommit(oMdlAlert)
					If lRet
						
						// se for inclusão/alteração de linhas envia o e-mail
						If oAuxN7T:IsUpdated() .Or. oAuxN7T:IsInserted()					
							Pergunte('UBAA070002', .F.)
							If !Empty(MV_PAR02)
								U70EnvAlrt(oModel, cFilSel, cSafSel)
							Else
								Help('' ,1,".UBAA07000208.", , ,1,0) /* E-mail não enviado. Pressione a tecla F11 e informe o template de e-mail, por gentileza. */
							EndIf
						EndIf	
					EndIf
				Else
					lRet := .F.
					Help( ,,STR0025,, oMdlAlert:GetErrorMessage()[6], 1, 0 ) //"Atenção"#
				EndIf	

				If lRet
					//Guardar filiais marcadas
					aFilBkp := UBAA070BKP(oModel)
					
					//Atualizacao forcada do grid de ranges
					oMdlAlert:DeActivate()
					oModel:DeActivate()
					oModel:Activate()
	
					//Devolver filiais marcadas
					UBAA070UPD(oModel, aFilBkp)
				EndIf
			Endif
		Else

			oMdlAlert:SetOperation(3)  //incluir
			If lRet .And. oMdlAlert:Activate()

				oMdlAlert:SetValue('MdFieldN7P','N7P_FILIAL', cFilSel)
				oMdlAlert:SetValue('MdFieldN7P','N7P_SAFRA' , cSafSel)
				oMdlAlert:SetValue('MdFieldN7P','N7P_EMAIL', oFormN7P:GetValue('N7P_EMAIL') )

				U070GrvGrd(oGrid100, oAuxN7T, cFilSel, cSafSel)

				If oMdlAlert:VldData()
					lRet := FWFormCommit(oMdlAlert)
					If lRet
						MsgInfo( STR0055, STR0025 )
						
						// se for inclusão/alteração de linhas envia o e-mail
						If oAuxN7T:IsUpdated() .Or. oAuxN7T:IsInserted()
							Pergunte('UBAA070002', .F.)
							If !Empty(MV_PAR02)
								U70EnvAlrt(oModel, cFilSel, cSafSel)
							Else
								Help('' ,1,".UBAA07000208.", , ,1,0) /* E-mail não enviado. Pressione a tecla F11 e informe o template de e-mail, por gentileza. */
								lRet := .F.
							EndIf
						EndIf	
					EndIf

				Else
					lRet := .F.
					Help( ,,STR0025,, oMdlAlert:GetErrorMessage()[6], 1, 0 ) //"Atenção"###
				EndIf

				If lRet
					//Guardar filiais marcadas
					aFilBkp := UBAA070BKP(oModel)
					
					//Atualizacao forcada do grid de ranges
					oMdlAlert:DeActivate()
					oModel:DeActivate()
					oModel:Activate()
	
					//Devolver filiais marcadas
					UBAA070UPD(oModel, aFilBkp)
				EndIf

			EndIf
		EndIf
	EndIf
	
	//Sem restRows pq estamos permitindo deletar linhas da N7T
	oGridVT:goLine(nlinha)
	If lRet
		oViewN7T:DeActivate(.T.) // Desativa a view em modo de refresh
		oViewN7T:Activate() // Ativa a view
	EndIf
	cFilAnt :=  cFilTemp
	oModel:Activate()
	
Return lRet			

/*/{Protheus.doc} BotaoEnviar
//Botao de envio de email
@author joaquim.burjack
@since 05/09/2017
@version undefined
@param oPanel, object, descricao
@param oView, object, descricao
@type function
/*/
Static Function BotaoEnviar(oPanel,oView)
	Local oModel    := FWModelActive()

	@ 010, 010 Button STR0061 /*Enviar E-mail*/ Size 50, 15 Message STR0062 /*"Clique aqui para enviar o alerta"*/ Pixel Action {||Processa( {||UBAA070ENV(oModel)}, STR0085)} of oPanel //"Aguarde. Enviando Email."

Return .T.

/*/{Protheus.doc} UBAA070ENV
//TODO Descrição auto-gerada.
@author joaquim.burjack
@since 05/09/2017
@version undefined
@param oModel, object, descricao
@type function
/*/
static Function UBAA070ENV(oModel)

	Local aRows 	:= FWSaveRows()
	Local oView 	:= FWViewActive()
	Local lRet		:= .T. 
	Local oGridN7T	:= oModel:GetModel( 'MdGrdN7T' )
	Local oGridVT   := oModel:GetModel('UBAA070_VT')
	Local cFilSel   := oGridVT:GetValue('VT_FILIAL')
	Local cSafSel   := oGridVT:GetValue('VT_CODSAF')
	Local oMdlAlert := FwLoadModel('UBAA100')
	Local oGrid100  := oMdlAlert:GetModel('MdGrdN7T')
	Local cFilTemp  := cFilAnt	
	Local nX
	Local lEnvia
	Local nFardos
	Local nCont		
	Local aBlocosMsg:= {}
	Local oHash
	Local lMark   	:= .F.
	Local lNaMemo 	:= .F.
	Local lBlocPar	:= .F.
	Local cFardoIn1 := ""
	Local cFardoIn2 := ""
	Local cFardoIn3 := ""
	Local cFardoFi1 := ""
	Local cFardoFi2 := ""
	Local cFardoFi3 := ""
	Local nlinha	:= oGridVT:getLine()
	Local aFilBkp	:= {}
	Local nMark     := 0	
	
	oHash := aToHM(aBlocosMsg)
	
	cFilAnt := cFilSel
	
	dbSelectArea('N7T')
	dbSetOrder(1)
	
	Pergunte('UBAA070002', .F.)
	
	If lRet .And. Empty(MV_PAR02)
		Help('' ,1,".UBAA07000208.", , ,1,0) /* E-mail não enviado. Pressione a tecla F11 e informe o template de e-mail, por gentileza. */
		lRet := .F.
	EndIf
	
	If lRet
		For nX := 1 To oGridN7T:Length()
			oGridN7T:Goline(nX)
			If !MsSeek(cFilSel+cSafSel+oGridN7T:GetValue('N7T_IDRANG'))  
				lNaMemo := .T.
			EndIf
			If oGridN7T:GetValue("CHECK") 
				lMark := .T.
				nMark++
			EndIf
			If lNaMemo .And. lMark
				exit
			EndIf
		Next nX
	EndIf

	If lRet .And. !lMark
		Help('' ,1,".UBAA07000204.", , ,1,0) /* Nenhum range marcado. */ /* Selecione um range, por gentileza */
		lRet := .F.
	EndIf
	
	If lRet .And. lNaMemo .And. lMark
		lRet := MSGYESNO(STR0075 /* "Existe(m) range(s) não salvos e esta operação irá descartá-lo(s). Deseja continuar?" */, STR0025 /*"Atenção"*/)
	EndIf
	
	ProcRegua(nMark + 1)
	
	If lRet
		IncProc(STR0083)//"Buscando emails"
		
		Begin Transaction
			For nX := 1 To oGridN7T:Length()
				oGridN7T:Goline(nX)
				if oGridN7T:GetValue("CHECK") 
					nFardos := 0
					dbSelectArea('DXI')
					dbSetOrder(7)		
		
					For nCont := val(substr(oGridN7T:GetValue("N7T_FRDINI"),14,6))  to val(substr(oGridN7T:GetValue("N7T_FRDFIM"),14,6))
						If MsSeek(cFilSel + cSafSel + StrZero(nCont, 6))
							if alltrim(DXI->DXI_BLOCO) = "" .or. DXI->DXI_BLOCO =  nil
								lEnvia := .F.
								lBlocPar := .T.
								nFardos ++
								/*exit*/
							else
								If !lBlocPar
									lEnvia := .T.
								EndIf
								If !HMGet( oHash , DXI->DXI_BLOCO)
									HMAdd(oHash,{DXI->DXI_BLOCO})
									aAdd(aBlocosMsg, {DXI->DXI_BLOCO})
								EndIf
							endIf
						endIf	
					Next nCont		

                    //quebra etiqueta para destacar o código do fardo inicial na mensagem
					cFardoIn1 := SUBSTR(oGridN7T:GetValue("N7T_FRDINI"), 1, 13) 
					cFardoIn2 := SUBSTR(oGridN7T:GetValue("N7T_FRDINI"), 14, 6)
					cFardoIn2 := '<b>' + cFardoIn2 + '</b>'
					cFardoIn3 := SUBSTR(oGridN7T:GetValue("N7T_FRDINI"), 20, 1)
                   
                    //quebra etiqueta para destacar o código do fardo final na mensagem 
					cFardoFi1 := SUBSTR(oGridN7T:GetValue("N7T_FRDFIM"), 1, 13)
					cFardoFi2 := SUBSTR(oGridN7T:GetValue("N7T_FRDFIM"), 14, 6) 
					cFardoFi2 := '<b>' + cFardoFi2 + '</b>'
					cFardoFi3 := SUBSTR(oGridN7T:GetValue("N7T_FRDFIM"), 20, 1)
					
					//Permitindo o envio forçado mesmo que já tenha sido enviado email para este range.
					Iif(Posicione('N7T', 1, FWxFilial('N7T')+cSafSel+oGridN7T:GetValue('N7T_IDRANG'),'N7T_STATUS') = "2", lEnvia := .T.,)
					

					if lEnvia .Or. ((nCont-1) > nFardos;  //Indica que tem menos fardos emblocados do que a faixa
					   	 .And. MSGYESNO(STR0063 /*"Existe(m) "*/ + cvaltochar(nFardos) + STR0064 /*" fardo(s) sem emblocar na faixa: "*/ + ;
   			  			 cFardoIn1 + cFardoIn2 + cFardoIn3 + " - " + cFardoFi1 + cFardoFi2 + cFardoFi3 + STR0065 /*". Deseja continuar?"*/, STR0025 /*"Atenção"*/))

	
						dbSelectArea('N7P')
						dbSetOrder(1)
						If MsSeek(fwxFilial("N7P")+cSafSel)
						
							IncProc(oGridN7T:GetValue("N7T_FRDINI")+" - "+oGridN7T:GetValue("N7T_FRDFIM"))
						
							oMdlAlert:SetOperation(4)
		
							If oMdlAlert:Activate()
			
								oGridN7T:SetValue('N7T_DTENV', dDatabase )
								oGridN7T:SetValue('N7T_HRENV', Substr(Time(), 1, 5) )
								oGridN7T:SetValue('N7T_STATUS','2' )
								oGridN7T:SetValue('N7T_DATATU', dDatabase)
								oGridN7T:SetValue('N7T_HORATU', Time())
			
								dbSelectArea('N7T')
								dbSetOrder(1)	
								
							 	If MsSeek(cFilSel+cSafSel+oGridN7T:GetValue('N7T_IDRANG'))
							 		oGrid100:goline(nX)
									oGrid100:SetValue('N7T_DTENV', oGridN7T:GetValue('N7T_DTENV'))
									oGrid100:SetValue('N7T_HRENV', oGridN7T:GetValue('N7T_HRENV'))
									oGrid100:SetValue('N7T_STATUS', oGridN7T:GetValue('N7T_STATUS'))
									oGrid100:SetValue('N7T_DATATU', oGridN7T:GetValue('N7T_DATATU'))
									oGrid100:SetValue('N7T_HORATU', oGridN7T:GetValue('N7T_HORATU'))
								endIf		
								
								oGrid100:addLine()							
			
								If oMdlAlert:VldData()
									lRet := FWFormCommit(oMdlAlert)					
								EndIf	
								
								oMdlAlert:DeActivate()	
							
							Endif
						endIf
					Else
						aBlocosMsg := {}
					Endif						
				Endif
			Next nX			
			
			If !Empty(MV_PAR02) .And. !Empty(aBlocosMsg)
				lRet := UBAA70MAIL(cFilSel, cSafSel, aBlocosMsg)
				
				if lRet == .F.
					DisarmTransaction()
				endIf
			EndIf
		End Transaction	
	EndIf

	If lRet
	
		//Guardar filiais marcadas
		aFilBkp := UBAA070BKP(oModel)
	
		// Atualiza o grid de range	
		oModel:DeActivate()
		dbSelectArea("N7P")
		N7P->(dbSeek(cFilSel+cSafSel))
		dbSelectArea("N7T")
		N7T->(dbSeek(cFilSel+cSafSel))
		oModel:Activate()
		
		//Devolver filiais marcadas
		UBAA070UPD(oModel, aFilBkp)
		
		// Atualiza o grid de range
		oView:Refresh('VIEW_N7T')
	EndIf
	
	oModel:Activate()
	oGridVT:goLine(nlinha)
	cFilAnt :=  cFilTemp
	FwRestRows(aRows)
	
Return lRet

/*/{Protheus.doc} U070GrvGrd
//Grava os dados da grid do alerta de emblocamento
@author silvana.torres / brunosilva
@since 06/09/2017
@version undefined

@type function
/*/
Static Function U070GrvGrd(oGrid100, oAuxN7T, cFilSel, cSafSel)

	Local nX
	Local aArea := getArea()
	
	dbSelectArea('N7T')
	dbSetOrder(1)
	
	
	For nX := 1 to oAuxN7T:Length()
		oAuxN7T:goLine(nx)
		
		/** Se eh a ultima posicao do banco sendo passada ao modelo do 100 
		AND se na tela tem mais registros do que no banco de dados, permite adicionar linhas **/
		If nX == oGrid100:Length() .And. oAuxN7T:Length() > oGrid100:Length()
			oGrid100:addLine()
		EndIf
		oGrid100:goLine(nx)
		
		If oAuxN7T:IsDeleted() 
			If MsSeek(fwxFilial("N7T")+cSafSel+oAuxN7T:GetValue('N7T_IDRANG'))
				oGrid100:DeleteLine()
			endIf
		ElseIf (oAuxN7T:IsUpdated() .And. oAuxN7T:IsInserted()) .Or. oAuxN7T:IsInserted() 
			If !Empty(oAuxN7T:GetValue('N7T_FRDINI')) .And. !Empty(oAuxN7T:GetValue('N7T_FRDFIM')) 
				oGrid100:SetValue('N7T_IDRANG', oAuxN7T:GetValue('N7T_IDRANG'))
			Else
				oGrid100:SetValue('N7T_IDRANG', Space(TamSX3('N7T_IDRANG')[1]) )
			EndIf
			If !Empty(oAuxN7T:GetValue('N7T_FRDINI'))
				oGrid100:SetValue('N7T_FRDINI', oAuxN7T:GetValue('N7T_FRDINI'))
			EndIf
			If !Empty(oAuxN7T:GetValue('N7T_FRDFIM'))
				oGrid100:SetValue('N7T_FRDFIM', oAuxN7T:GetValue('N7T_FRDFIM'))
			EndIf
		elseIF oAuxN7T:IsUpdated()
			If MsSeek(fwxFilial("N7T")+cSafSel+oAuxN7T:GetValue('N7T_IDRANG'))
				If !Empty(oAuxN7T:GetValue('N7T_FRDINI'))
					oGrid100:SetValue('N7T_FRDINI', oAuxN7T:GetValue('N7T_FRDINI'))
				EndIf
				If !Empty(oAuxN7T:GetValue('N7T_FRDFIM'))
					oGrid100:SetValue('N7T_FRDFIM', oAuxN7T:GetValue('N7T_FRDFIM'))
				EndIf
			endIf		
		endIf
	next nX
	
	restArea(aArea)
	
Return .T.


/*-------------------------------------------------------------------
{Protheus.doc} UBAA070Frd
Exibe browse. Consulta especifica DXIES1
@author silvana.torres
@since 06/09/2017
*/
Function UBAA070Frd()
	Local aArea     	:= GetArea()
	Local oModel		:= FWModelActive()
	Local oDlg	    	:= Nil
	Local oPnDown   	:= Nil
	Local oSize     	:= Nil
	Local lRet      	:= .T.	 	       
	Local aSeek 		:= {}
	Local aCampIni2	 	:= {}
	Local nx			

	Local cArqTemp 	:= ""
	Local aIndices	:= {}
	Local aArqTemp 	:= {}
	Local aColBrw 	:= {"DXI_CODIGO","DXI_ETIQ"} //Colunas browse
	Local aCpSX3Str	:= {} //armazena a estrutura do campo da sx3
	Local aColumns 	:= {}
	Local aCmpsTab	:= {}
	Local cAliasFrd 

	Local oGridVT   
	Local cFilSel   := ""
	Local cSafSel   := ""
	Local cFilTemp 	:= cFilAnt
	
	Local oFrm100
	
	Private _oBrwFardo	:= {}	
	Private _aFardos   	:= {}
	
	SetKey(VK_F11,Nil)
	SetKey(VK_F12,Nil)
	
	if IsInCallStack("UBAA070")
		oGridVT   := oModel:GetModel('UBAA070_VT') 
		
		cFilSel   := oGridVT:GetValue('VT_FILIAL')
		cSafSel   := oGridVT:GetValue('VT_CODSAF')
	else
		oFrm100 := oModel:GetModel('MdFieldN7P')
		
		cFilSel   := cFilAnt
		cSafSel   := oFrm100:GetValue('N7P_SAFRA')		 		
	endIf
	
	cFilAnt := cFilSel

	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1]/1.55, oSize:aWindSize[2]/1.55, oSize:aWindSize[3]/1.55, oSize:aWindSize[4]/1.55,;
	STR0060 , , , , , CLR_BLACK, CLR_WHITE, , , .t. )

	oPnDown := TPanel():New( oSize:GetDimension("ALL","LININI"), oSize:GetDimension("ALL","COLINI"),;
	,oDlg, ,.F. , , , ,oSize:GetDimension("ALL","COLEND")/1.57, oSize:GetDimension("ALL","LINEND")/1.90)

	dbSelectArea('DXI')
	dbSetOrder(1)

	DXI->(DbSeek(cFilSel+cSafSel))
	While DXI->(!Eof())  .And.  DXI->DXI_FILIAL = cFilSel .And. DXI->DXI_SAFRA = cSafSel   
		aAdd( _aFardos, { DXI->DXI_CODIGO, DXI->DXI_ETIQ } )

		DXI->(dbSkip())
	EndDo

	cFilAnt := cFilTemp

	//Limpa tabela
	If (!Empty(cAliasFrd)) .AND. Select(cAliasFrd) > 0
		(cAliasFrd)->(DbCloseArea())
	EndIf	

	//Cria colunas a serem exibidas no browse a partir da SX3
	For nx := 1 To Len(aColBrw)
		AAdd(aColumns,FWBrwColumn():New())

		aCpSX3Str := {}		
		aCpSX3Str := FWSX3Util():GetFieldStruct( aColBrw[nx] )

		If Len(aCpSX3Str) > 0 .and. Alltrim(aCpSX3Str[1]) == Alltrim(aColBrw[nx])
			aColumns[nx]:SetData(&("{||"+aColBrw[nx]+"}"))
			aColumns[nx]:SetTitle( Alltrim(FWX3Titulo(aColBrw[nx])) )
			aColumns[nx]:SetPicture( Alltrim(PesqPict("DXI", aColBrw[nx])) )
			aColumns[nx]:SetType( aCpSX3Str[2] )
			aColumns[nx]:SetSize( aCpSX3Str[3] )
			aColumns[nx]:SetReadVar( aColBrw[nx] )

			//Campos para a tabela temporária
			AADD(aArqTemp,{ aColBrw[nx] , aCpSX3Str[2] , aCpSX3Str[3] , aCpSX3Str[4] })

		EndIf

	Next nx

	//-- Cria Indice de Trabalho
	cArqTemp  := GetNextAlias() 
	aAdd(aIndices, {"Codigo", "DXI_CODIGO"} )
	aAdd(aIndices, {"Etiqueta", "DXI_ETIQ"} )
	oArqTemp  := AGRCRTPTB(cArqTemp, {aArqTemp, aIndices })
	cAliasFrd := cArqTemp

	For nx := 1 To Len(_aFardos)
		DbSelectArea(cAliasFrd)
		Reclock(cAliasFrd, .T.)
		Replace (cAliasFrd)->DXI_CODIGO   With _aFardos[nx][1]
		Replace (cAliasFrd)->DXI_ETIQ  With _aFardos[nx][2]
		MsUnlock()
	Next nx

	If Select(cAliasFrd) > 0
		(cAliasFrd)->(dbGoTop())
	EndIf

	Aadd(aSeek,{TxDadosCpo("DXI_CODIGO")[1],{{"",TamSX3("DXI_CODIGO")[3],TamSX3("DXI_CODIGO")[1],0,' ',,}}})
	Aadd(aSeek,{TxDadosCpo("DXI_ETIQ")[1],{{"",TamSX3("DXI_ETIQ")[3],TamSX3("DXI_ETIQ")[1],0,' ',,}}})

	aCmpsTab := TamSX3("DXI_CODIGO") 
	AADD(aCampIni2,{"DXI_CODIGO", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2],  "Código", "@!"})

	aCmpsTab := TamSX3("DXI_ETIQ") 
	AADD(aCampIni2,{"DXI_ETIQ", aCmpsTab[3],aCmpsTab[1],aCmpsTab[2],  "Etiqueta", "@!"})

	DEFINE FWFORMBROWSE _oBrwFardo DATA TABLE ALIAS cAliasFrd OF oPnDown
	_oBrwFardo:SetTemporary(.T.)
	_oBrwFardo:SetColumns(aColumns)
	_oBrwFardo:SetOwner(oDlg)  
	_oBrwFardo:SetDBFFilter(.T.)
	_oBrwFardo:SetSeek(,aSeek)
	_oBrwFardo:SetUseFilter(.T.)
	_oBrwFardo:SetFieldFilter(AGRITEMCBRW(aCampIni2))
	_oBrwFardo:DisableDetails(.T.)
	_oBrwFardo:DisableReport(.T.) 
	_oBrwFardo:SetDoubleClick( {|| selecFrd(), oDlg:End() })
	ACTIVATE FWFORMBROWSE _oBrwFardo	
	
	_oBrwFardo:oBrowseUI:oFwSeek:oSeekGet:oGet:SetFocus()
	
	oDlg:lEscClose := .T.
	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar(oDlg,{|| selecFrd(), oDlg:End()},{|| cancelFrd(), oDlg:End() },,/* @aButtons */) } )

	AGRDLTPTB(oArqTemp)
	
	If Type("bKeyF11070") != "U"
		SetKey( VK_F11, bKeyF11070 )		
	EndIf
	
	If Type("bKeyF12070") != "U"	
		SetKey( VK_F12, bKeyF12070 )
	EndIf

	RestArea(aArea)

Return lRet

/*-------------------------------------------------------------------
{Protheus.doc} U070RetFrd
//Retorno da Consulta especifica DXIES1
@author silvana.torres
@since 06/09/2017
@type function
-------------------------------------------------------------------*/	
Function U070RetFrd()
	//Caso o usuário preencha o campo e depois dê esc, atribuo branco pra _cRet. 
	Iif( _cRet = Nil, _cRet := " ",)
Return(_cRet)

/*-------------------------------------------------------------------
{Protheus.doc} cancelFrd
//Ação do botão cancelar da Consulta especifica DXIES1
@author silvana.torres
@since 06/09/2017
@type function
-------------------------------------------------------------------*/
Function cancelFrd()

	_cRet := ""

Return(.T.)

/*-------------------------------------------------------------------
{Protheus.doc} selecFrd
//Ação do botão OK da Consulta especifica DXIES1
@author silvana.torres
@since 06/09/2017
@type function
-------------------------------------------------------------------*/
Function selecFrd()

	_cRet := _aFardos[_oBrwFardo:nAt,2]

Return(.T.)



/*/{Protheus.doc} UBAA70MAIL
//Envia e-mail informando os blocos gerados
@author carlos.augusto
@since 25/09/2017
@param cFilCons, characters, chave de consulta no banco
@param cSafraCons, characters, chave de consulta no banco
@param aBlocos, array, chave de consulta no banco
@type function
/*/
Function UBAA70MAIL(cFilCons, cSafraCons, aBlocos)

	Local aArea		:= GetArea()
	Local cEmails 	:= "" // E-mails de envio, ou seja, os destinatários. ! Não obrigatório
	Local cBody	 	:= "" // Corpo da mensagem, caso exista. ! Não obrigatório
	Local cTabPen	:= "" // Alias referente ao browse. ! Não obrigatório
	Local cChaveFt	:= "" // Chave para trazer somente os dados referente ao registro posicionado. ! Obrigatório
	Local aIndices  := {{"1" , {"DXD_FILIAL", "DXD_SAFRA", "DXD_CODIGO"}}} // Indice utilizado na tabela relacionada
	Local nOrdem	:= 1 // Ordem do indice a ser utilizado
	Local cProcess	:= Posicione("N7L", 1, xFilial("N7L") + MV_PAR02, "N7L_PROCES")
	Local cTemplate := MV_PAR02
	Local nX
	Local lRet		:= .T.
	Local aRet 		:= {}

	dbSelectArea("DXD")	

	cChaveFt += "(DXD_FILIAL = '" + cFilCons + "' AND DXD_SAFRA = '" + cSafraCons + "') AND (" 

	For nX := 1 to Len(aBlocos)
		cChaveFt +=	" DXD_CODIGO = '" + aBlocos[nX][1] + "'" + IIF(nX < Len(aBlocos)," OR ",")")
	Next nX

	cEmails := Posicione('N7P', 1, xFilial("N7P") + cSafraCons, "N7P_EMAIL") // Obtem os emails da reserva para repassar a tela de envio de email	
	
	aRet := OGX017(cEmails, cBody, cTabPen, cChaveFt, cProcess, aIndices, nOrdem, nil, "", cTemplate, .T.) // Chama a tela de envio de email, passando os emails e o corpo da mensagem, alias e a chave referente ao filtro.
  
	if len(aRet) = 0
		lRet := .F.
	endIf
	
    If .NOT. Select("SX2") > 0 // Se a SX2 estiver fechada, reabre a mesma
	     dbSelectArea("SX2")
	EndIf

	RestArea(aArea)	
	 
Return lRet

/*/{Protheus.doc} ValidMar
//Permite marcar apenas faixas que tenham blocos
@author carlos.augusto
@since 29/09/2017
@version undefined

@type function
/*/
Static Function ValidMar(oModel)
//	Local oModel    := FwModelActive()
	Local lRet		:= .T.
	Local aArea     := GetArea()
	Local oGridN7T	:= oModel:GetModel( 'MdGrdN7T' )
	Local oGridVT   := oModel:GetModel('UBAA070_VT')
	Local cFilSel   := oGridVT:GetValue('VT_FILIAL')
	Local cSafSel   := oGridVT:GetValue('VT_CODSAF')
	Local cAliasReg := GetNextAlias()
		
	Local cFarIni	:= substr(oGridN7T:GetValue("N7T_FRDINI"),14,6) 
	Local cFarFin	:= substr(oGridN7T:GetValue("N7T_FRDFIM"),14,6)
	
	BeginSql Alias cAliasReg
	Select DXI_BLOCO From %table:DXI% DXI
	where DXI.%notDel%
	and DXI.DXI_FILIAL = %exp:cFilSel%
	and DXI.DXI_SAFRA  = %exp:cSafSel%
	and DXI.DXI_CODIGO >= %exp:cFarIni%
	and DXI.DXI_CODIGO <= %exp:cFarFin%
	EndSql	
	
	dbSelectArea(cAliasReg)
	(cAliasReg)->(dbGoTop())
	
	//Laço para atualizar a descrição das colunas de regras de avaliação de malas
	While (cAliasReg)->(!Eof())
		lRet := .F. 
		If !Empty((cAliasReg)->DXI_BLOCO)
			lRet := .T.
			exit
		EndIf
		(cAliasReg)->(dbSkip())
	EndDo

	If !lRet
		oModel:GetModel():SetErrorMessage(oModel:GetId(), , oModel:GetId(), "", "", STR0071 /* "A faixa informada não possui fardos emblocados." */, STR0072 /* "Favor gerar emblocamento." */, "", "")
	EndIf
	
	RestArea(aArea)

Return lRet

Static Function ColetaHvi(cChaveHvi,nUHM,nMIC,nRES)
	Local aArea := GetArea()

	dbselectarea("DX7")
	dbSetOrder(1)
	MsSeek(cChaveHvi)
	nUHM	+= DX7->DX7_UHM
	nMic	+= DX7->DX7_MIC
	nRes	+= DX7->DX7_RES

	RestArea(aArea)
Return


/*/{Protheus.doc} UBAA070BKP
//Guarda os registros marcados do grid de filials
@author carlos.augusto
@since 25/10/2017
@version undefined
@param oModel, object, descricao
@type function
/*/
Static Function UBAA070BKP(oModel)
	Local aFilMark := {}
	Local oGridVT   := oModel:GetModel('UBAA070_VT')
	Local nLinha	:= oGridVT:getLine()
	Local nX

	For nX := 1 to oGridVT:Length()
		oGridVT:GoLine(nX)
		If !oGridVT:IsDeleted() .And. oGridVT:GetValue('VT_SELEC')
			aAdd(aFilMark, .T.)
		Else
			aAdd(aFilMark, .F.)
		Endif
	Next nX	

	oGridVT:GoLine(nLinha)
	
Return aFilMark


/*/{Protheus.doc} UBAA070UPD
//Devolve os registros marcados do grid de filials
@author carlos.augusto
@since 25/10/2017
@version undefined
@param oModel, object, descricao
@param aFilMark, array, descricao
@type function
/*/
Static Function UBAA070UPD(oModel, aFilMark)
	Local oGridVT   := oModel:GetModel('UBAA070_VT')
	Local nX
	Local nLinha	:= oGridVT:getLine()

	For nX := 1 to oGridVT:Length()
		oGridVT:GoLine(nX)
		oGridVT:SetValue('VT_SELEC',aFilMark[nX])   
	Next nX	

	oGridVT:GoLine(nLinha)

Return


/*/{Protheus.doc} PegaRegras
//Obtem Regras de emblocamento
@author carlos.augusto
@since 10/03/2019
@version 12.1.23
@param cFilialBlc, characters, filial
@param cSafraBloc, characters, safra
@type function
/*/
Static Function PegaRegras(cFilialBlc, cSafraBloc)
	Local aArea       := GetArea()
	Local cQryReg	  := ""
	Local cAliasItReg := GetNextAlias()
	Local cAliasN80   := GetNextAlias()
	Local aArr
	Local nx  
	Local cAux    
	Local aRegras
	Local nQtdeBloco
	Local nQtdReserva := 0
	Local aRegraDeEmb := {}
	
	Private _nTotPsLiq  := 0

	Pergunte('UBAA070003', .F.)
	
	If .Not. Empty(__cCodRegra)
		DbSelectArea("N80")
		N80->(dbSetOrder(1))
		If N80->(dbSeek(FwxFilial("N80") + __cCodRegra + "3"))
			nQtdeBloco := N80->N80_QTDFAR
		Else
			nQtdeBloco := 9999
			MsgAlert(STR0092 + __cCodRegra)//"Regra de emblocamento não foi encontrada para definir a quantidade limite do bloco:" 
		EndIf
		N80->(dbCloseArea())
	Else
		nQtdeBloco := MV_PAR01	
	EndIf

	__aReleva := {}
	/************************************************************************/
	/**          Processo de pré criação de blocos para simulação          **/
	/************************************************************************/
	
	cQryReg := "SELECT * "
	cQryReg += "  FROM" + RetSqlName('N80') + " N80 "
	cQryReg += " WHERE N80.D_E_L_E_T_ = ' ' "
	cQryReg += "   AND N80.N80_FILIAL = '" + fwxFilial('N80') + "' "
	
	If .NOT. Empty(__cCodRegra)
		cQryReg += " AND N80.N80_CODIGO = '" + __cCodRegra + "' "
		cQryReg += " AND N80.N80_TIPEMB = '3' " //Emblocamento específico
	Else
		cQryReg += " AND N80.N80_TIPEMB = '1' " //Emblocamento normal
		cQryReg += " AND N80.N80_ATIVO = '1' " //Ativo
	EndIf
	
	
	cQryReg += " ORDER BY N80.N80_RELEVA	" 
	
	cQryReg    := ChangeQuery(cQryReg)
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQryReg ), cAliasN80, .F., .T. )

	/************************************************************************/
	/**         Processo de enfileiramento de fardinhos nos blocos        **/
	/************************************************************************/

	While (cAliasN80)->(!Eof())

		/*IF (cAliasN80)->N80_QTDRSV > 0
			nQtdReserva := (cAliasN80)->N80_QTDRSV
			nQtdeBloco	:= (cAliasN80)->N80_QTDFRD
		EndIf*/
		
		aAdd(__aReleva,{(cAliasN80)->N80_CODIGO,(cAliasN80)->N80_RELEVA})

		cAux := ""
		If !Empty((cAliasN80)->N80_TPCLAS)
			aArr := STRTOKARR((cAliasN80)->N80_TPCLAS,'OU')

			For nx := 1 to Len(aArr)
				If nx = 1
					cAux := "('" + ALLTRIM(aArr[nx]) + "'," 
					If Len(aArr) = 1
						cAux += "'" + ALLTRIM(aArr[nx]) + "')"
					Endif					
				ElseIf nx = Len(aArr)
					cAux += "'" + ALLTRIM(aArr[nx]) + "')" 	
				Else
					cAux += "'" + ALLTRIM(aArr[nx]) + "',"				
				Endif			
			Next nx
		Endif

		//Busca os blocos parciais e seus respectivos fardos
		GetParcial((cAliasN80)->N80_CODIGO,(cAliasN80)->N80_RELEVA,(cAliasN80)->N80_PCTFRM, cFilialBlc, cSafraBloc, nQtdeBloco, nQtdReserva)

		aRegras 	:= {}

		//Busca os exames HVI que fazem parte da regra de emblocamento para tratamento posterior
		BeginSQL Alias cAliasItReg		  
		  SELECT N81_CODREG, N81_VLDE, N81_VLATE, N81_CAMPO
		    FROM %Table:N81% N81
		    INNER JOIN %Table:N80% N80
		        ON (N80.%notDel%
		    	AND N80.N80_FILIAL = N81.N81_FILIAL 
		    	AND N80.N80_CODIGO = N81.N81_CODEMB 
		    	AND N80.N80_TIPEMB = N81.N81_TIPEMB)
		   WHERE 
		         N81.N81_TIPREG = 1 /*HVI*/
		     AND N81.N81_FILIAL = %xFilial:N81%
		     AND N81.%notDel%
		     AND N81.N81_CODEMB = %Exp:(cAliasN80)->N80_CODIGO%	     	         
		EndSQL

		dbSelectArea(cAliasItReg)
		(cAliasItReg)->(dbGoTop())

		While (cAliasItReg)->(!Eof())	
			aAdd(aRegras, {(cAliasN80)->N80_CODIGO, (cAliasItReg)->N81_CAMPO, (cAliasItReg)->N81_VLDE, (cAliasItReg)->N81_VLATE})

			(cAliasItReg)->(dbSkip())
		endDo

		(cAliasItReg)->(DbCloseArea())
		aAdd(aRegraDeEmb,{(cAliasN80)->N80_CODIGO, cAux, aRegras})



		dbSelectArea(cAliasN80)	
		(cAliasN80)->(dbSkip())
	EndDo	

	(cAliasN80)->(dbCloseArea())


	RestArea(aArea)
Return aRegraDeEmb



/*/{Protheus.doc} ValidaFardo
//TODO Descrição auto-gerada.
@author carlos.augusto
@since 10/03/2019
@version 1.0
@return ${return}, ${return_description}
@param aRegraDeEmb, array, descricao
@param cFilFard, characters, descricao
@param cSafra, characters, descricao
@param cEtiq, characters, descricao
@param cTpComer, characters, descricao
@param cAliasPre, characters, descricao
@type function
/*/
Static Function ValidaFardo(aRegraDeEmb, cFilFard, cSafra, cEtiq, cTpComer,cAliasPre)
	Local lOkReg := .F.
	Local nx
	Local cRegraOK := ""

	For nx := 1 to Len(aRegraDeEmb)
		If Empty(aRegraDeEmb[nx][2]) .Or. (cTpComer $ aRegraDeEmb[nx][2])
		
			If ConfereCont(cSafra, cEtiq ,aRegraDeEmb[nx][1]) .And. A070Regra(aRegraDeEmb[nx][3], @cAliasPre)
				lOkReg		:= .T.
				cRegraOK	:= aRegraDeEmb[nx][1]
				exit
			EndIf
		EndIf
	Next nx 
	

Return cRegraOK

