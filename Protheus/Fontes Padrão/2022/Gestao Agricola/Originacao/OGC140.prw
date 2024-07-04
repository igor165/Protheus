#INCLUDE "OGC140.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

/** {Protheus.doc} OGC140
Consulta - Painel de Fardos e movimentos
@param:     Nil
@return:    nil
@author:    Felipe Mendes
@since:     15/05/2018
@Uso:       SIGAAGR - Originação de Grãos
*/
Function OGC140( cFiltroDef )
	Local oBrowse
	
	Default cFiltroDef := ''
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("DXI")							// Alias da tabela utilizada
	oBrowse:SetMenuDef("OGC140")				    // Nome do fonte onde esta a função MenuDef
	oBrowse:SetFilterDefault( cFiltroDef )
	oBrowse:SetDescription(STR0001)	// Descrição do browse 
	
	oBrowse:SetAttach( .T. ) //visualizações 
	oBrowse:Activate()                                       
Return(Nil)

/** {Protheus.doc} MenuDef
Funcao que retorna os itens para construção do menu da rotina

@param: 	Nil
@return:	aRotina - Array com os itens do menu
@author:    Felipe Mendes
@since:     15/05/2018
@Uso: 		OGC140
*/
Static Function MenuDef()
	Local aRotina := {}
	//-------------------------------------------------------
	// Adiciona botões do browse
	//-------------------------------------------------------
	ADD OPTION aRotina TITLE STR0002   ACTION "AxPesqui"       OPERATION 1 ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE STR0003   ACTION "VIEWDEF.OGC140" OPERATION 2 ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE STR0004   ACTION "VIEWDEF.OGC140" OPERATION 8 ACCESS 0 //"Imprimir"
	aAdd( aRotina, { STR0006   , "OGC140CFRD(DXI->DXI_FARDAO)", 0, 2, 0, Nil } ) // "Consultar Fardão"
	
	Return aRotina
	
/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author:    Felipe Mendes
@since:     15/05/2018
@Uso: 		OGC140
*/
Static Function ModelDef()
	
	Local oStruDXI := FWFormStruct( 1, "DXI" )
	Local oStruN9D := FWFormStruct( 1, "N9D" )
	Local oModel

	oStruN9D:AddField("Descrição Movimento","Descrição Movimento","TMP_DESMOV","C"      , 	50     ,             ,           ,           ,            ,            , { || POSICIONE("SX5",1,xFilial("SX5")+"K9"+N9D->N9D_TIPMOV ,"X5_DESCRI"  ) },   .F.     ,    .F.    ,         , )
	
	oModel :=  MPFormModel():New( "OGC140", /*<bPre >*/ , /*bPost*/ , /*bCommit*/, /*bCancel*/ )
	
	oModel:SetDescription( STR0001 ) //"Processos de Aprovação"
	
	oModel:AddFields("OGC140_DXI", Nil, oStruDXI ,/*bPre*/,/*bPost*/,/*bLoad*/)
	oModel:AddGrid( "OGC140_N9D", "OGC140_DXI", oStruN9D ,  ,  ,  ,  ,  )
	oModel:GetModel( "OGC140_N9D" ):SetDescription( STR0001 )
	
	oModel:SetRelation( "OGC140_N9D", { { "N9D_FILIAL", "xFilial( 'DXI' )" }, { "N9D_SAFRA", "DXI_SAFRA" }, { "N9D_FARDO", "DXI_ETIQ" } }, N9D->( IndexKey( 1 ) ) )
	
	oModel:SetPrimaryKey({"DXI_FILIAL","DXI_SAFRA","DXI_ETIQ"})
Return oModel

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author:    Felipe Mendes
@since:     15/05/2018
@Uso: 		OGC140
*/
Static Function ViewDef()
	Local oModel := FWLoadModel("OGC140")
	Local oView  := Nil
	Local oStructDXI := FWFormStruct(2,"DXI")   
	Local oStructN9D := FWFormStruct(2,"N9D")   
	    
	oStructDXI:RemoveField( "DXI_CODINE" )
	oStructDXI:RemoveField( "DXI_ROMSAI" )
	oStructDXI:RemoveField( "DXI_ITROMS" )
	oStructDXI:RemoveField( "DXI_CODRES" )
	oStructDXI:RemoveField( "DXI_ITERES" )
	oStructDXI:RemoveField( "DXI_ITEINE" )
	oStructDXI:RemoveField( "DXI_ITEMFX" )
	oStructDXI:RemoveField( "DXI_ORDENT" )
	oStructDXI:RemoveField( "DXI_CONTNR" )
	oStructDXI:RemoveField( "DXI_ROMFLO" )
	oStructDXI:RemoveField( "DXI_ENTLOC" )
	
	oStructN9D:RemoveField( "N9D_SAFRA" )
	oStructN9D:RemoveField( "N9D_FARDO" )
	
	oStructN9D:AddField("TMP_DESMOV", "50", STR0005, STR0005, {},"C","@!",Nil,Nil,.T.,"1",Nil,Nil,Nil,Nil,.T.)	
	
	
	oStructN9D:setProperty("N9D_TIPMOV",  MVC_VIEW_ORDEM, "01")
    oStructN9D:setProperty("TMP_DESMOV",  MVC_VIEW_ORDEM, "02")
    oStructN9D:setProperty("N9D_DATA"  ,  MVC_VIEW_ORDEM, "03")
	oStructN9D:setProperty("N9D_STATUS",  MVC_VIEW_ORDEM, "04") 
	oStructN9D:setProperty("N9D_PESINI",  MVC_VIEW_ORDEM, "05")
	oStructN9D:setProperty("N9D_PESFIM",  MVC_VIEW_ORDEM, "06")
	oStructN9D:setProperty("N9D_PESDIF",  MVC_VIEW_ORDEM, "07")	
	oStructN9D:setProperty("N9D_FILORG",  MVC_VIEW_ORDEM, "08")
    oStructN9D:setProperty("N9D_LOCAL",   MVC_VIEW_ORDEM, "09") 
	oStructN9D:setProperty("N9D_LOTECT",  MVC_VIEW_ORDEM, "10")
	oStructN9D:setProperty("N9D_DTVALI",  MVC_VIEW_ORDEM, "11")
	oStructN9D:setProperty("N9D_CODCTR",  MVC_VIEW_ORDEM, "12")
	oStructN9D:setProperty("N9D_ITEETG",  MVC_VIEW_ORDEM, "13")
		
	oView := FWFormView():New()
	// Objeto do model a se associar a view.
	oView:SetModel(oModel)
	// cFormModelID - Representa o ID criado no Model que essa FormField irá representar
	// oStruct - Objeto do model a se associar a view.
	// cLinkID - Representa o ID criado no Model ,Só é necessári o caso estamos mundando o ID no View.
	oView:AddField( "VIEW_DXI" , oStructDXI, "OGC140_DXI" )	//
	// cID		  	Id do Box a ser utilizado 
	// nPercHeight  Valor da Altura do box( caso o lFixPixel seja .T. é a qtd de pixel exato)
	// cIdOwner 	Id do Box Vertical pai. Podemos fazer diversas criações uma dentro da outra.
	// lFixPixel	Determina que o valor passado no nPercHeight é na verdade a qtd de pixel a ser usada.
	// cIDFolder	Id da folder onde queremos criar o o box se passado esse valor, é necessário informar o cIDSheet
	// cIDSheet     Id da Sheet(Folha de dados) onde queremos criar o o box.
	oView:SetOnlyView("VIEW_DXI")
	oView:AddGrid( "VIEW_N9D", oStructN9D, "OGC140_N9D" )
	
	
	oView:CreateVerticallBox( "MASTER" , 100,/*cIDOwner*/,/*lFixPixel*/,/*cIDFolder*/,/*cIDSheet*/ )
	oView:CreateHorizontalBox( "SUPERIOR" , 50, "MASTER" )
	oView:CreateHorizontalBox( "INFERIOR" , 50, "MASTER" )
	
	// Associa um View a um box
	oView:SetOwnerView( "VIEW_DXI" , "SUPERIOR" )   
	oView:SetOwnerView( "VIEW_N9D" , "INFERIOR" )

	
	oView:EnableTitleView( "VIEW_N9D" )
//	oView:EnableTitleView( "VIEW_DXI" )

	oView:SetCloseOnOk( {||.t.} )
	oView:AddUserButton("Consultar Movimento","BUTTONID",{|x|OGC140Detail(oModel)} )
//	oBtn1 := TButton():New( 002, 010, "TESTE", oView, { || .T. ,.F.}, 80, 10, , , .F., .T., .F., , .F., , ,.F. )	//"Vincular / Desvincular"
			
//	oView:AddOtherObject( "OTHER_BOTAO", oBtn1 )
	//oView:SetOwnerView( "OTHER_BOTAO", "INFERIOR02"   )				 
	
	
Return oView


/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author:    Felipe Mendes
@since:     15/05/2018
@Uso: 		OGC140
*/
Static Function OGC140Detail(oModel)
	Local oModelN9D := oModel:GetModel( "OGC140_N9D" )
	Local cTipMov   := oModelN9D:Getvalue( "N9D_TIPMOV" )
	Private _aItsEsq   := {} //Variavel referente ao OGA250
	
	
	DO CASE
		CASE cTipMov == '01' //BENEFICIAMENTO
			
			Pergunte("UBAC005",.F.) 						//Inicializa as variaveis publicas da pergunta
			MV_PAR01 := oModelN9D:Getvalue( "N9D_SAFRA") 	//SAFRA

			UBAC005()
			
		CASE cTipMov == '02' //RESERVA
			
			DbSelectArea("DXP")
			DbSetOrder(1)
			If DbSeek( oModelN9D:Getvalue( "N9D_FILORG" ) + oModelN9D:Getvalue( "N9D_CODRES" ) )
				FWExecView("","AGRA720",MODEL_OPERATION_VIEW)
			EndIf	
				
		CASE cTipMov == '03' //FIXAÇÃO
		
			Pergunte("OGC020",.F.) 						//Inicializa as variaveis publicas da pergunta
			MV_PAR01 := oModelN9D:Getvalue( "N9D_SAFRA") 	//SAFRA

			OGC020()
		CASE cTipMov == '04' //ie
			
			DbSelectArea("N7Q")
			DbSetOrder(1)
			If DbSeek( oModelN9D:Getvalue( "N9D_FILORG" ) + oModelN9D:Getvalue( "N9D_CODINE" )  )
				FWExecView("","OGA710",MODEL_OPERATION_VIEW)
			EndIf
		
		CASE cTipMov $ '05|07|08|09'  //CERTIFICAÇÃO - ROMANEIO	- TRANSITO ROMANEIO - ROMANEIO COMPLEMENTAR
		
			DbSelectArea("NJJ")
			DbSetOrder(1)
			If DbSeek( oModelN9D:Getvalue( "N9D_FILORG" ) + oModelN9D:Getvalue( "N9D_CODROM" )  )
				FWExecView("","OGA250",MODEL_OPERATION_VIEW)
			EndIf
		
//		CASE cTipMov == '06' - SINISTRO 					ainda não tem programa 
//		CASE cTipMov == '10' //AUTORIZAÇÃO DE CARREGAMENTO  Ainda em Desenv
//		CASE cTipMov == '11' //PRE AGENDAMENTO				Ainda em Desenv
	
	ENDCASE

Return


/** {Protheus.doc} OGC140CFRD
Função que abre a visualização do fardão

@param: 	cFardao,char,Código do fardão
@author:    Christopher Miranda
@since:     30/08/2018
@Uso: 		OGC140
*/
Function OGC140CFRD(cFardao)
	Local aArea := DXL->(GetArea())

	dbSelectArea('DXL')
	DXL->(DbSetOrder(1)) //DXL_FILIAL+DXL_CODIGO+DXL_SAFRA+DXL_PRDTOR+DXL_LJPRO+DXL_FAZ
	If DXL->(dbSeek(FwXFilial('DXL') + cFardao)) 
		nRet := FWExecView( , 'AGRA601', MODEL_OPERATION_VIEW, , {|| .T.}, , 20 / 100) // Abre a rotina de Negociação em modo de visualização
	else
		Help( , , STR0007, , STR0008, 1, 0 )
	Endif


	RestArea(aArea)

return