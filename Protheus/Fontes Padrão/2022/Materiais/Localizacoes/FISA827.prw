#include "FISA827.CH"
#Include "PROTHEUS.CH"
#Include "FWMVCDEF.CH"

Function FISA827( cAlias, nReg, nOperation, nOpcCat )
	Local aArea 			:= GetArea()
	Local oExecView			:= Nil 
	Local oModel			:= Nil
	Local cTipo             := "" 
	
	Default cAlias  		:= Alias()
	Default nReg	  		:= (cAlias)->(RecNo()) 
	Default nOperation		:= 1
	Default nOpcCat		    := 1
	
	Private nOpcConf := nOpcCat
	
	dbSelectArea("SA1")
	SA1->(MsGoto(nReg))
	
	cTipo := IIf(nOpcConf == 1, "R", "T")
	
	cCod    := SA1->A1_COD 
	cLoja   := SA1->A1_LOJA
	cNomCli := SA1->A1_NOME
	
	oModel := FWLoadModel("FISA827")
	oModel:SetOperation(nOperation)
	oModel:GetModel("AITMASTER"):bLoad := {|| {xFilial("AIT"),cCod,cLoja,cTipo,cNomCli}}
	oModel:Activate() 
	
	oView := FWLoadView("FISA827")
	oView:SetModel(oModel)
	oView:SetOperation(nOperation) 
			  	
	oExecView := FWViewExec():New()
	oExecView:SetTitle(STR0001) //"DIAN"
	oExecView:SetView(oView)
	oExecView:SetModal(.F.)
	oExecView:SetCloseOnOK({|| .T. })
	oExecView:SetOperation(nOperation)
	oExecView:OpenView(.T.)
	
	oModel:DeActivate()
	
	RestArea(aArea)
Return Nil


//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definición del modelo de datos
@author 	luis.enriquez
@return		oModel objeto del Model
@since 		31/07/2019
@version	12.1.17 / Superior
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
	Local oModel 		:= Nil
	Local cCpoAITCab	:= "AIT_FILIAL|AIT_CODCLI|AIT_LOJA|AIT_TIPO|"
	Local bAvCpoCab		:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoAITCab}
	Local oStructMST 	:= FWFormStruct(1,"AIT",bAvCpoCab)
	Local oStructAIT 	:= FWFormStruct(1,"AIT")
	Local cTitulo       := ""
	Local aTrigger      := {}
	Local nOpcPan       := 1
	
	If !(Type( "nOpcConf" ) == "U")
		nOpcPan := nOpcConf
	EndIf

	cTitulo       := IIf(nOpcPan == 1, STR0002, STR0003) //"Responsabilidades" //"Tributos"
	aTrigger := F827TRIGR(nOpcPan)  //Monta o gatilho dos campos AIT_CODRES e AIT_CODTRI
	
	oStructMST:AddField(	AllTrim(STR0004)				,; 	// [01] C Titulo do campo //"Nombre"
							AllTrim(STR0005)	            ,; 	// [02] C ToolTip do campo //"Nombre del cliente"
							"AIT_NOMCLI" 					,; 	// [03] C identificador (ID) do Field
							"C" 							,; 	// [04] C Tipo do campo
							40 								,; 	// [05] N Tamanho do campo
							0 								,; 	// [06] N Decimal do campo
							Nil 							,; 	// [07] B Code-block de validação do campo
							Nil								,; 	// [08] B Code-block de validação When do campo
							Nil					 			,; 	// [09] A Lista de valores permitido do campo
							Nil 							,; 	// [10] L Indica se o campo tem preenchimento obrigatório
							Nil		 			   			,;  // [11] B Code-block de inicializacao do campo
							Nil 							,; 	// [12] L Indica se trata de um campo chave
							Nil				 				,; 	// [13] L Indica se o campo pode receber valor em uma operação de update.
							Nil )		
							
	// Campos vistuales que mostraran la descripción de cada mnemónico utilizado en la formulación del asiento por línea.
	oStructAIT:AddField(  ;      	// Ord. Tipo Desc.
	STR0006             , ;      // [01]  C   Titulo do campo //"Descripción"
	STR0007	            , ;      // [02]  C   ToolTip do campo //"Descripción de resp/tributo"
	'AIT_DESC1'		    , ;      // [03]  C   Id do Field
	'C'					, ;      // [04]  C   Tipo do campo
	100            	    , ;      // [05]  N   Tamanho do campo
	0					, ;      // [06]  N   Decimal do campo
	NIL					, ;      // [07]  B   Code-block de validação do campo
	NIL					, ;      // [08]  B   Code-block de validação When do campo
	NIL             	, ;      // [09]  A   Lista de valores permitido do campo
	.F.                 , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
	NIL   				, ;      // [11]  B   Code-block de inicializacao do campo
	NIL					, ;      // [12]  L   Indica se trata-se de um campo chave
	NIL					, ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
	.T.             )            // [14]  L   Indica se o campo é virtual
	
	oModel := MPFormModel():New("FISA827",/*bPreValidacao*/,/*bPosValid*/,/*bCommit*/,/*bCancel*/)	
	oModel:SetDescription(cTitulo)
	
	oModel:AddFields("AITMASTER",/*cOwner*/,oStructMST,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/) 
	oModel:AddGrid("AITCONTDET","AITMASTER",oStructAIT, ,/*bPosValidacao*/,/*bCarga*/)
	
	oModel:GetModel("AITCONTDET"):SetOptional( .T. )
	
	If nOpcPan == 1
		oModel:SetPrimaryKey({"AIT_FILIAL","AIT_CODCLI","AIT_LOJA","AIT_CODRES"})
		oModel:GetModel( 'AITCONTDET' ):SetLoadFilter( { { 'AIT_TIPO', "'R'", MVC_LOADFILTER_EQUAL } } )
		oModel:GetModel("AITCONTDET"):SetUniqueLine({"AIT_CODRES"})
	ElseIf nOpcPan == 2
		oModel:SetPrimaryKey({"AIT_FILIAL","AIT_CODCLI","AIT_LOJA","AIT_CODTRI"})
		oModel:GetModel( 'AITCONTDET' ):SetLoadFilter( { { 'AIT_TIPO', "'T'", MVC_LOADFILTER_EQUAL } } )
		oModel:GetModel("AITCONTDET"):SetUniqueLine({"AIT_CODTRI"})
	EndIf
	
	oModel:GetModel("AITCONTDET"):SetOptional( .T. )
	
	
	oModel:SetRelation("AITCONTDET",{ {"AIT_FILIAL","AIT_FILIAL"},;
	                                  {"AIT_CODCLI","AIT_CODCLI"},;
	                                  {"AIT_LOJA","AIT_LOJA"}; 
	                                },AIT->( IndexKey(1)))

	oStructAIT:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])
Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Interface del modelo de datos de configuración de responsabilidades RUT y tributos de clientes.
@param		Nenhum
@return		oView objeto del View
@author 	luis.enriquez
@since 		31/07/2019
@version	12.1.17 / Superior
/*/
//------------------------------------------------------------------------------

Static Function ViewDef()
	Local oView 		:= Nil
	Local oModel		:= FwLoadModel("FISA827")
	Local cCpoAAITCab	:= "AIT_FILIAL|AIT_CODCLI|AIT_LOJA|AIT_TIPO|"
	Local bAvCpoCab		:= {|cCampo| AllTrim(cCampo)+"|" $ cCpoAAITCab}
	Local oStructMST 	:= FWFormStruct(2,"AIT",bAvCpoCab)
	Local oStructAIT 	:= FWFormStruct(2,"AIT")
	Local nOrden        := 0
	Local nOpcPan       := IIf( ValType( "nOpcConf" ) == "U", 1, nOpcConf )

	//Campos no ediatbles
	oStructMST:SetProperty("AIT_CODCLI",MVC_VIEW_CANCHANGE,.F.)
	oStructMST:SetProperty("AIT_LOJA" , MVC_VIEW_CANCHANGE, .F. )
	oStructMST:SetProperty("AIT_TIPO" , MVC_VIEW_CANCHANGE, .F. )
	
	nOrden	:= F827ORD("AIT")
	
	oStructMST:AddField(	"AIT_NOMCLI" 			,;	// [01] C Nome do Campo
							Str(nOrden) 		    ,; 	// [02] C Ordem
							STR0004	                ,; 	// [03] C Titulo do campo //"Nombre"
							STR0005					,; 	// [04] C Descrição do campo//"Nombre del cliente"
							{} 	   					,; 	// [05] A Array com Help
							"C" 					,; 	// [06] C Tipo do campo
							"@!" 					,; 	// [07] C Picture
							Nil 					,; 	// [08] B Bloco de Picture Var
							Nil 					,; 	// [09] C Consulta F3
							.F. 					,;	// [10] L Indica se o campo é evitável
							Nil 					,; 	// [11] C Pasta do campo
							Nil 					,;	// [12] C Agrupamento do campo
							Nil 					,; 	// [13] A Lista de valores permitido do campo (Combo)
							Nil 					,;	// [14] N Tamanho Maximo da maior opção do combo
							Nil 					,;	// [15] C Inicializador de Browse
							Nil 					,;	// [16] L Indica se o campo é virtual
							Nil ) 
	
	nOrden += 1
	oStructAIT:AddField(; 	      // Ord. Tipo Desc.
	'AIT_DESC1'		, ;      // [01]  C   Nome do Campo
	'ZZ'            , ;      // [02]  C   Ordem
	STR0006 	    , ;      // [03]  C   Titulo do campo //"Descripción"
	STR0007     	, ;      // [04]  C   Descricao do campo //"Descripción de resp/tributo"
	{ STR0006 }		, ;      // [05]  A   Array com Help //"Descripción"
	'C' 			, ;      // [06]  C   Tipo do campo
	'@!'           	, ;      // [07]  C   Picture
	NIL            	, ;      // [08]  B   Bloco de Picture Var
	''             	, ;      // [09]  C   Consulta F3
	.F.				, ;      // [10]  L   Indica se o campo é alteravel
	NIL           	, ;      // [11]  C   Pasta do campo
	NIL            	, ;      // [12]  C   Agrupamento do campo
	NIL            	, ;      // [13]  A   Lista de valores permitido do campo (Combo)
	NIL            	, ;      // [14]  N   Tamanho maximo da maior opção do combo
	NIL            	, ;      // [15]  C   Inicializador de Browse
	.T.             , ;      // [16]  L   Indica se o campo é virtual
	NIL            	, ;      // [17]  C   Picture Variavel
	NIL            	)        // [18]  L   Indica pulo de linha após o campo
	
	//Campos removididos del grid												
	oStructAIT:RemoveField("AIT_FILIAL")
	oStructAIT:RemoveField("AIT_CODCLI")
	oStructAIT:RemoveField("AIT_LOJA")
	oStructAIT:RemoveField("AIT_TIPO")
	If nOpcPan == 1
		oStructAIT:RemoveField("AIT_CODTRI")
	ElseIf nOpcPan == 2
		oStructAIT:RemoveField("AIT_CODRES")
	EndIf
	
	oView := FWFormView():New()
	oView:SetModel(oModel)
	 
	oView:AddField("VIEW_MST",oStructMST,"AITMASTER")
	oView:AddGrid("VIEW_AIT",oStructAIT, "AITCONTDET")
	
	oView:CreateHorizontalBox("VIEW_TOP",20)
	oView:SetOwnerView("VIEW_MST","VIEW_TOP")
	
	oView:CreateHorizontalBox("VIEW_DET",80)
	oView:SetOwnerView("VIEW_AIT","VIEW_DET")
	
	oView:SetAfterViewActivate({|oView| F827VISTA(oView)}) 
Return(oView)

/*/{Protheus.doc} F827ORD
Obtiene el siguiente orden de una tabla 
@author luis.enriquez
@return		nProxOrdem
@since 31/07/2019
@version P12
/*/
Static Function F827ORD(cTabla)
	Local nProxOrdem:= 0
	Local aAreaSX3  := SX3->(GetArea())
	Local nOrden    := 0
	Local cOrden	:= ""
	
	// Verificando a ultima ordem utilizada
	dbSelectArea("SX3")
	dbSetOrder(1)
	If MsSeek(cTabla)
		Do While SX3->X3_ARQUIVO == cTabla  .And. !SX3->(Eof())
			cOrden := SX3->X3_ORDEM
			SX3->(dbSkip())
		Enddo
	Else
		cOrden := "00"
	EndIf
	
	SX3->(RestArea(aAreaSX3))
	
	nOrden    := RetAsc(cOrden,3,.F.)   //A0 -> 100
	nProxOrdem:= VAL(nOrden)+ 1
Return nProxOrdem

/*/{Protheus.doc} F827VISTA
Función llamada después de la activación de la Vista.
Inicializa los valores para la edición del documento.
@author 	luis.enriquez
@return		Boolean
@since 		08/08/2019
@version	12.1.17 / Superior
/*/
Function F827VISTA(oView)
	Local oModel 	 := FWModelActivate()
	Local oModelAIT	 := oModel:GetModel('AITCONTDET')
	Local nOperation := oModel:GetOperation()
	Local nX         := 0
	Local cDesc      := ""
	
	If nOperation == 4 
		For nX:= 1 to oModelAIT:Length()
			oModelAIT:GoLine(nX)
			If nOpcConf == 1 //Resp
				cValor := oModelAIT:GetValue("AIT_CODRES") 
				cDesc  := Alltrim(ObtColSAT("S014",AllTrim(cValor),1,4,5,80))
			ElseIf nOpcConf == 2 //Tributos
				cValor := oModelAIT:GetValue("AIT_CODTRI") 
				cDesc  := Alltrim(ObtColSAT("S005",AllTrim(cValor),1,2,3,80))
			EndIf
			
			If !Empty(cDesc)
				oModelAIT:LoadValue( 'AIT_DESC1' , cDesc)
			EndIf			
		Next nX
	EndIf	
	
	oModelAIT:GoLine(1)
	oView:Refresh()		
Return

/*/{Protheus.doc} F827TRIGR
Monta el gatillo para los campos AIT_CODRES y AIT_CODTRI.
@author 	luis.enriquez
@since 		12/11/2019
@version	12.1.17 / Superior
/*/
Static Function F827TRIGR(nOpcConf)
	Local aRet   :=Nil
	Local cDom   :=""
	Local cCDom  :=""
	Local cRegra :=""
	Local lSeek  :=.f.
	Local cAlias :=""
	Local nOrdem :=0
	Local cChave :=""
	Local cCondic:=Nil
	Local cSequen:="01"
	
	If nOpcConf == 1
		cDom  :="AIT_CODRES"
		cCDom :="AIT_DESC1"
		cRegra:='Alltrim(ObtColSAT("S014",AllTrim(M->AIT_CODRES),1,4,5,80))'
	ElseIf nOpcConf == 2
		cDom  :="AIT_CODTRI"
		cCDom :="AIT_DESC1"
		cRegra:='Alltrim(ObtColSAT("S005",AllTrim(M->AIT_CODTRI),1,2,3,80))'
	EndIf
	
	aRet:=FwStruTrigger(cDom, cCDom, cRegra, lSeek, cAlias, nOrdem, cChave, cCondic, cSequen)

Return(aRet)
