#Include 'Protheus.ch'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'TMSA500.CH'
//-------------------------------------------------------------------
/*/{Protheus.doc} TMSC030
Visualização de documentos complementares

@author Alex Amaral
@since   27/10/2014
@version 1.8
/*/
//-------------------------------------------------------------------

Function TMSC030()
Local oBrowse		

Private aSetKey	:= {} // Recebe as teclas de atalho 
Private aFrete	:= {}
Private aItensAgd	:= {}    //-- Matriz para Agendamento de Entrega.
Private aItensGfe	:= {}   //-- Matriz para GFE
Private aRotina 	:= MenuDef()
Private aValInf	:= {}	
Private aHeaderDWT := {}
Private aColsDWT  := {}
Private cCadastro := STR0001 //'Manutencao de Documentos'

	
 If !TMS030F()
 	Return nil
 	
 EndIf	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('DT6')
	oBrowse:SetDescription(STR0213) 
	
	//------------------------------------------------
	//      Legendas de Documentos
	//------------------------------------------------
	ADD LEGEND DATA "DT6_STATUS == '1' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'1')" COLOR "BR_VERDE"    TITLE STR0056 OF oBrowse //-- Em aberto
	ADD LEGEND DATA "DT6_STATUS == '2' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'2')" COLOR "BR_VERMELHO" TITLE STR0057 + ' / ' + STR0083 OF oBrowse //-- Carregado ### Indicado para Coleta
	ADD LEGEND DATA "DT6_STATUS == '3' .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'3')" COLOR "BR_AMARELO"  TITLE STR0058 OF oBrowse //-- Em transito
	ADD LEGEND DATA "(DT6_STATUS == '4' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'5')" COLOR "BR_LARANJA"  TITLE STR0059 + ' / ' + STR0084 OF oBrowse //-- Chegada parcial ### Documento Informado
	ADD LEGEND DATA "(DT6_STATUS == '5' .And. DT6_SERIE <> 'COL' ) .Or. TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'4')" COLOR "BR_AZUL"  TITLE STR0060 + ' / ' + STR0085 OF oBrowse //-- Chegada final   ### Encerrada
	ADD LEGEND DATA "DT6_STATUS == '6'" COLOR "BR_CINZA" TITLE STR0061 OF oBrowse //-- Indicado p/ entrega
	ADD LEGEND DATA "DT6_STATUS == '7'" COLOR "BR_MARRON" TITLE STR0062 OF oBrowse //-- Entregue
	ADD LEGEND DATA "TMSStatCol(DT6_FILDOC,DT6_DOC,DT6_SERIE,'9')" COLOR "BR_PRETO" TITLE STR0151 OF oBrowse //-- Ordem de Coleta Cancelada
	ADD LEGEND DATA "DT6_STATUS == '8'" COLOR "BR_PINK" TITLE STR0178 OF oBrowse //--Entrega Parcial
	ADD LEGEND DATA "DT6_STATUS == '9'" COLOR "BR_CANCEL" TITLE STR0163 OF oBrowse //--Anulado
	ADD LEGEND DATA "DT6_STATUS == 'A'" COLOR "BR_BRANCO"	  TITLE STR0183 OF oBrowse //--Retorno Total
	ADD LEGEND DATA "DT6_STATUS == 'B'" COLOR "PMSEDT4"  TITLE STR0192  OF oBrowse //--Cancelamento SEFAZ Aguardando
	ADD LEGEND DATA "DT6_STATUS == 'C'" COLOR "PMSEDT3"  TITLE STR0193 OF oBrowse //--Cancelamento SEFAZ Autorizado
	ADD LEGEND DATA "DT6_STATUS == 'D'" COLOR "PMSEDT1"  TITLE STR0194 OF oBrowse //--Cancelamento SEFAZ Nao Autorizado
	
	//-------------------------------------------------------------------------------------------------
	//				Teclas de Atalho
	//-------------------------------------------------------------------------------------------------
		Aadd(aSetKey, { VK_F4  , {|| TmsA500Dig () } } )
		Aadd(aSetKey, { VK_F5  , {|| TmsA500Fin () } } )
		Aadd(aSetKey, { VK_F7  , {|| TmsA500Tr1 () } } )
		Aadd(aSetKey, { VK_F8  , {|| TmsA500Tr2 () } } )
		Aadd(aSetKey, { VK_F9  , {|| TmsA500Tr3 () } } )
		Aadd(aSetKey, { VK_F10 , {|| TmsA500Viag() } } )
		Aadd(aSetKey, { VK_F11 , {|| TmsA500Man () } } )
		Aadd(aSetKey, { VK_F12 , {|| TmsA500Tab () } } )
	
	//-----------------------------------------------	
	//   Inicializa Teclas de Atalhos
	//-----------------------------------------------
		TmsKeyOn(aSetKey)	
			
	//-----------------------------------------------
	// Ativacao da classe	
	//-----------------------------------------------
	oBrowse:Activate()
	
Return NIL

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Camada Model do MVC.

@author Alex Amaral
@since   27/10/2014
@version 1.8
/*/
//---------------------------------------------------------------------------------------------

Static Function ModelDef()
Local oStruDT6  := FWFormStruct(1, 'DT6')
Local oStruCOMP := FWFormStruct(1, 'DT8')//,{|cCampo| AllTrim(cCampo)+"|" $ "DT8_FILIAL|DT8_CODPAS|DT8_VALPAS|DT8_VALIMP|DT8_VALTOT|"})
Local oStruDYD  := FWFormStruct(1, 'DYD')
Local oStruGWM  := StrModGFE(1)
Local oModel
Local BLoadGWM     := { |oMdl| BLoadGWM(oMdl) }
Local BLoadDYD     := { |oMdl| BLoadDYD(oMdl) }

oStruDYD  := FWFormStruct(1, 'DYD')

	//------------------------------------------------
	//		Cria a estrutura basica manualmente
	//------------------------------------------------
	oModel := MPFormModel():New('TMSC030', /*bPre*/,/*bPost*/, /*bCommit*/, /*bCancel*/)
	oModel:SetActivate({|oModel| TMSC030POS(oModel)})
	
	//------------------------------------------------
	//		Cria a estrutura basica manualmente
	//------------------------------------------------
	oStruCOMP:AddField(	STR0214			, ; // Titulo do campo  ----- Selecionado
						STR0214			, ; // ToolTip do campo ----- Selecionado
						'DT8_DESCRI' 		, ; // Nome do Campo
						'C' 			, ; // Tipo do campo
						20	 			, ; // Tamanho do campo
						0 				, ; // Decimal do campo
						NIL				, ; // Code-block de validação do campo
						NIL				, ; // Code-block de validação When do campo
						{} 				, ; // Lista de valores permitido do campo
						.F.				, ; // Indica se o campo tem preenchimento obrigatório
						{||If(DT8->DT8_CODPAS = "TF","Total do Frete",Posicione("DT3",1,xFilial("DT3")+DT8->DT8_CODPAS,"DT3_DESCRI"))}				, ; // Code-block de inicializacao do campo
						NIL 			, ; // Indica se trata de um campo chave
						NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
						.T. 			) 	// Indica se o campo é virtual
	

	//------
	//------------------------------------------------------
	//		Adiciona o componente de formulario no model 
	//------------------------------------------------------     
	oModel:AddFields('DT6MASTER', /*cOwner*/, oStruDT6)
		
	//-------------------------------------------------------------------
	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	//-------------------------------------------------------------------
	oModel:AddGrid(  'DT8DETAIL' ,'DT6MASTER', oStruCOMP, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/)
	oModel:AddGrid(  'DYDDETAIL' ,'DT6MASTER', oStruDYD, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, BLoadDYD )
	oModel:AddGrid(  'GWMDETAIL' ,'DT6MASTER', oStruGWM, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, BLoadGWM )
	
	//-------------------------------------------------------
	//		Faz relaciomaneto entre os compomentes do model
	//-------------------------------------------------------
	oModel:SetRelation( "DT8DETAIL", { { "DT8_FILIAL", "xFilial('DT8')" }, { "DT8_FILDOC", "DT6_FILDOC" }, { "DT8_DOC", "DT6_DOC" } ,  {"DT8_SERIE"    , "DT6_SERIE" }}, DT8->( IndexKey( 2 ) ) )	
	oModel:SetRelation( "DYDDETAIL", { { "DYD_FILIAL", "xFilial('DYD')" }, { "DYD_NUMAGD", "DT6_NUMAGD" }}, DYD->( IndexKey( 1 ) ) )
	
	
	oModel:GetModel( "DT8DETAIL" ):SetOptional( .T. )
	oModel:GetModel( "DYDDETAIL" ):SetOptional( .T. )
	oModel:GetModel( "GWMDETAIL" ):SetOptional( .T. )
	
	oModel:SetPrimaryKey({"DT6_FILIAL"})
	oModel:SetPrimaryKey({"DT6_FILIAL", "DT6_NUMAGD"})
	//--------------------------------------
	//		Configura descricao dos modelos
	//--------------------------------------		
	oModel:SetDescription( STR0213 )   

	oModel:GetModel( 'DT8DETAIL' ):SetDescription( STR0001 )
	
Return oModel

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Camada View do MVC.

@author Alex Amaral
@since   27/10/2014
@version 1.8
/*/

//---------------------------------------------------------------------------------------------

Static Function ViewDef()
Local oModel    := FWLoadModel('TMSC030')
Local oStruDT6  := FWFormStruct(2, 'DT6')
Local oStruCOMP := FWFormStruct(2, 'DT8',{|cCampo| AllTrim(cCampo)+"|" $ "DT8_FILIAL|DT8_DESCRI|DT8_VALPAS|DT8_VALIMP|DT8_VALTOT|"})
Local oStruDYD  := FWFormStruct(2, 'DYD',{|cCampo| AllTrim(cCampo)+"|" $ "DYD_FILIAL|DYD_NUMAGD|DYD_ITEAGD|DYD_TIPAGD|DYD_DATAGD|DYD_PRDAGD|DYD_INIAGD|DYD_FIMAGD|DYD_DTCAGD|DYD_USUAGD|DYD_NOMUSR|"})
Local oStruGWM  := StrModGFE(2)
Local lTm500BUT := ExistBlock("TM500BUT")	//-- Permite adicionar botoes.
Local oView     := FWFormView():New()       
Local lTMSGFE   := SuperGetMv("MV_TMSGFE",,.T.) 
Local lAgdEntr  := Iif(FindFunction("TMSA018Agd"),TMSA018Agd(),.F.)   //-- Agendamento de Entrega.
Local cFunction := "TMSC030"

Private aValInf	:= {}	

IIf(ExistFunc('FwPDLogUser'),FwPdLogUser(cFunction),)

		//------------------+----------------------------------------
		//		Cria a estrutura View
		//----------------------------------------------------------
		//oView := FWFormView():New()
		
		oView:SetModel(oModel) //-- Define qual o modelo de dados será utilizado
		 
		
		oStruCOMP:AddField(	'DT8_DESCRI'	, ; // Nome do Campo
						'02' 			, ; // Ordem
						STR0214		, ; // Titulo do campo  ---- Selecionado
						STR0214		, ; // Descrição do campo  ---- Selecionado
						{"Descricao Comp"}		, ; // Array com Help  ---- Selecionado
						'C' 			, ; // Tipo do campo
						'@!' 			, ; // Picture
						NIL 			, ; // Bloco de Picture Var
						'' 				, ; // Consulta F3
						.T. 			, ; // Indica se o campo é evitável
						NIL 			, ; // Pasta do campo
						NIL 			, ; // Agrupamento do campo
						{ }				, ; // Lista de valores permitido do campo (Combo)
						NIL 			, ; // Tamanho Maximo da maior opção do combo
						NIL 			, ; // Inicializador de Browse
						.T. 			, ; // Indica se o campo é virtual
						NIL 			  ) // Picture Variável
		
		//--------------------------------------
		//		Insere os componentes na view
		//--------------------------------------
		oView:AddField('VIEW_DT6',oStruDT6,'DT6MASTER')
		
		oView:AddGrid(  'VIEW_DT8COMP', oStruCOMP,'DT8DETAIL' )
		
		If lAgdEntr
			oView:AddGrid(  'VIEW_DYDAGD' , oStruDYD, 'DYDDETAIL' )
		EndIf
		
		If lTMSGFE
			oView:AddGrid(  'VIEW_GWMGFE' , oStruGWM, 'GWMDETAIL' )
		EndIf
	
		//--------------------------------------
		//		Cria os Box's
		//--------------------------------------
		oView:CreateHorizontalBox( 'TOPO'   , 50 )
		oView:CreateHorizontalBox( 'FOLDER' , 50 )
		
		//--------------------------------------
		//		Cria Folder na view
		//--------------------------------------
		oView:CreateFolder( "PASTA", "FOLDER" )
	
		//--------------------------------------
		//		Cria pastas nas folders
		//--------------------------------------
		oView:AddSheet( "PASTA", "ABA01", STR0215 ) 
		
		If lAgdEntr
			oView:AddSheet( "PASTA", "ABA04", STR0182 )
		EndIf
		
		If lTMSGFE
			oView:AddSheet( "PASTA", "ABA05", STR0197 ) 
		EndIf
		
		//-------------------------------------------------------------
		//	Criar "box" horizontal para receber algum elemento da view
		//-------------------------------------------------------------
		oView:CreateHorizontalBox( "TAB_COMP"  , 100,,,"PASTA","ABA01" )
		
		If lAgdEntr
			oView:CreateHorizontalBox( "TAB_DYD"   , 100,,,"PASTA","ABA04" )
		EndIf
		
		If lTMSGFE
			oView:CreateHorizontalBox( "TAB_GWM"   , 100,,,"PASTA","ABA05" )
		EndIf
				
		//--------------------------------------
		//		Associa os componentes
		//--------------------------------------
		oView:SetOwnerView( 'VIEW_DT6'     , 'TOPO'    )
		oView:SetOwnerView( 'VIEW_DT8COMP' , 'TAB_COMP')	
		
		If lAgdEntr
			oView:SetOwnerView( 'VIEW_DYDAGD'  , 'TAB_DYD' )
		EndIf
		
		If lTMSGFE
			oView:SetOwnerView( 'VIEW_GWMGFE'  , 'TAB_GWM' )
		EndIf
	
		//--------------------------------------
		// Botões 
		//--------------------------------------	
					
			aButtons  := {;
			{ STR0009 , 'CLIPS', {|| TmsA500Dig()}},;   //'Mais detalhes - <F4>'	
			{ STR0010 , 'CLIPS', {|| TmsA500Fin()}},;  //"Visualiza Titulos - <F6>"		
			{ STR0011 , 'CLIPS', {|| TmsA500Tr1()}},;  //'Tracking de Operacoes - <F7>'
			{ STR0012 , 'CLIPS', {|| TmsA500Tr2()}},;  //'Tracking de Ocorrencias - <F8>'
			{ STR0013 , 'CLIPS', {|| TmsA500Tr3()}},;  //'Tracking de Operacoes/Ocorrencias - <F9>'
			{ STR0091 , 'CLIPS', {|| TmsA500Viag()}},; //'Viagem - <F10>'
			{ STR0093 , 'CLIPS', {|| TmsA500Man()}},;  //'Manifesto - <F11>' 
			{ STR0095 , 'CLIPS', {|| TmsA500Tab()}},;  //'Tabela de Frete - <F12>' 
			{ STR0097 , 'CLIPS', {|| TmsA500AWB()}},;  //'Awb'
			{ STR0148 , 'CLIPS', {|| TmsA500Seg()}},;  //'Indenizacoes'
			{ STR0150 , 'CLIPS', {|| TmsA500Pen()}},;  //'Valor Informado	
			{ STR0098 , 'CLIPS', {|| TmsValInf(aValInf,'6',,,,,,,,,,,,2,,M->DT6_TABFRE,M->DT6_TIPTAB)}},; //'Pendencia
			{ STR0102 , 'CLIPS', {|| TmsA500Comp(M->DT6_FILDOC,M->DT6_DOC,M->DT6_SERIE) }},; //'Documentos Complementares
			{ STR0140 , 'CLIPS', {|| A500TipVei(2,DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)}},; //'Tipos de Veiculo'
			{ STR0146 , 'CLIPS', {|| TmsA500OBS(2)}},; //'Observacao'
			{ STR0216 , 'CLIPS', {|| TM500CDoc()}},; //'Custo Docto'
			{ STR0217 , 'CLIPS', {|oView| Tms500LAgd()}} } //--'Legenda Age.Entrega'
		
		If  DT6->DT6_TIPTRA = StrZero(4,Len(DT6->DT6_TIPTRA)) //-- Rodoviario Internacional
			Aadd(aButtons,{ STR0152   ,"CLIPS" , {|| TmA500FPais(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)} }) //"Frete por País"###"Fr.País"
			Aadd(aButtons,{ STR0154   , 'CLIPS', {|| TmA500FDAF(DT6->DT6_FILDOC,DT6->DT6_DOC,DT6->DT6_SERIE)} }) //"Frete CIF/FOB"###"Fr.Cif/Fob"
			Aadd(aButtons,{ STR0218   , 'CLIPS', {|| TmA500MIC() } })//-- "MIC/DTA"
			Aadd(aButtons,{ STR0156   , 'CLIPS', {|| TmsCAltCRT()} }) //'Alterações CRT'###'Alt. CRT'
		EndIf
			
		TmsValInf(aValInf,'7',DT6->DT6_FILDOC,,,,,,,,DT6->DT6_DOC,DT6->DT6_SERIE,,2)

		//Ponto de Entrada para adicionar botoes
		If	lTm500BUT
			aButTmp := ExecBlock('TM500BUT',.F.,.F.,{MODEL_OPERATION_VIEW,aButtons})
			If ValType(aButTmp) == "A" .And. Len(aButTmp) > 0
				aButtons := aClone(aButTmp)
			EndIf
		EndIf
		
		AEval( aButtons, { |x| oView:AddUserButton( x[1], x[2], x[3] ,NIL,NIL, {MODEL_OPERATION_VIEW}) } )

Return oView
//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} TMSC030Col
Visualizacao da Coleta

@author Alex Amaral
@since   13/11/2014
@version 1.8
/*/
//---------------------------------------------------------------------------------------------
Function TMSC030Col()
Local aArea    := GetArea()
	
	If DT6->DT6_DOCTMS == StrZero( 1, Len( DT6->DT6_DOCTMS ) )				//-- Coleta
		//-- Posiciona na solicitacao de coleta.
		DT5->( DbSetOrder( 4 ) )
		If	DT5->( MsSeek( xFilial('DT5') + DT6->DT6_FILDOC + DT6->DT6_DOC + DT6->DT6_SERIE, .F. ) )
			TmsA460Mnt( 'DT5', DT5->( Recno() ), 2 )
		EndIf
	Else
		MsgAlert(STR0219)//--"Documento não é coleta"
	EndIf  

RestArea(aArea)    
   
Return aRotina
//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu de Operações MVC

@author Alex Amaral
@since   27/10/2014
@version 1.8
/*/
//---------------------------------------------------------------------------------------------
Static Function MenuDef()
Private  aRotina := {   { STR0002 ,'AxPesqui'        ,0 ,1},;
						   { STR0003 ,'VIEWDEF.TMSC030' ,0 ,2},;
		                 { STR0220 ,'TMSC030Col' ,0 ,2}}	              

If ExistBlock("TM500MNU")
	ExecBlock("TM500MNU",.F.,.F.)
EndIf
   
Return aRotina

//---------------------------------------------------------------------------------------------

/*/{Protheus.doc} TMS030F()
Definicao de qual modelo de dados sera chamado
@author Alex Amaral
@since 28/01/2013
@version 1.0
@return oModel
/*/
//---------------------------------------------------------------------------------------------
Function TMS030F()
Local lExibImp 	:= SuperGetMv("MV_TMSCFIS",,.T.) 
Local lRet			:= .T.

If lExibImp == .T.	
	TMSA500(.T.)
	lRet  := .F.
EndIf	

Return lRet	

//---------------------------------------------------------------------------------------------

/*/{Protheus.doc} BLoadGWM()
Carrega o grid de integração com o GFE
@author Alex Amaral
@since 13/11/2014
@version 1.0
@return oModel
/*/
//---------------------------------------------------------------------------------------------
Function BLoadGWM(oMdl)
Local aItensGfe := Tms500GWM()
Local nX  := 0
Local nY  := 0
Local nLinha	:= 0
Local aLoadGWM	:= {}
Local oStructGWM := oMdl:GetStruct()
Local aCamposGWM := aClone(oStructGWM:GetFields())  
Local aArea      := GetArea()


For nX := 1 To Len(aItensGfe)
	nLinha++
	aAdd(aLoadGWM,{nLinha,Array(Len(aCamposGWM))})
	
	For nY := 1 To Len(aCamposGWM)
		If (aCamposGWM[nY][MODEL_FIELD_IDFIELD] $ ("GFE_TOTAL"))
			aLoadGWM[nLinha][2][nY]	:= aItensGfe[nX,10] 
		ElseIf (aCamposGWM[nY][MODEL_FIELD_IDFIELD] $ ("GFE_QTDENF"))
			aLoadGWM[nLinha][2][nY]	:= aItensGfe[nX,2] 
		ElseIf (aCamposGWM[nY][MODEL_FIELD_IDFIELD] $ ("GFE_QTDVOL"))
			aLoadGWM[nLinha][2][nY]	:= aItensGfe[nX,3]
		ElseIf (aCamposGWM[nY][MODEL_FIELD_IDFIELD] $ ("GFE_PESO"))				
			aLoadGWM[nLinha][2][nY]	:= aItensGfe[nX,4]
		ElseIf (aCamposGWM[nY][MODEL_FIELD_IDFIELD] $ ("GFE_VALMER"))
			aLoadGWM[nLinha][2][nY]	:= aItensGfe[nX,5]
		ElseIf (aCamposGWM[nY][MODEL_FIELD_IDFIELD] $ ("GFE_VALOR"))
			aLoadGWM[nLinha][2][nY]	:= aItensGfe[nX,6]
		ElseIf (aCamposGWM[nY][MODEL_FIELD_IDFIELD] $ ("GFE_VALIMP"))
			aLoadGWM[nLinha][2][nY]	:= aItensGfe[nX,7]
		ElseIf (aCamposGWM[nY][MODEL_FIELD_IDFIELD] $ ("GFE_VALTOT"))
			aLoadGWM[nLinha][2][nY]	:= aItensGfe[nX,8]
		ElseIf (aCamposGWM[nY][MODEL_FIELD_IDFIELD] $ ("GFE_PORC"))
			aLoadGWM[nLinha][2][nY]	:= aItensGfe[nX,9]
		Else
			aLoadGWM[nLinha][2][nY]	:= ""
		EndIf
	Next nY
Next nX

aCamposGWM := aSize(aCamposGWM,0)
RestArea(aArea)    
Return aLoadGWM

//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} BLoadDYD()
Carrega o grid de agendamento
@author Alex Amaral
@since 13/11/2014
@version 1.0
@return oModel
/*/
//---------------------------------------------------------------------------------------------
Function BLoadDYD(oMdl)
Local aItensDYD := Iif(FindFunction("TMSA018Fil"),TMSA018Fil(),{})
Local nX  := 0
Local nY  := 0
Local nLinha	:= 0
Local aLoadDYD	:= {}
Local oStructDYD := oMdl:GetStruct()
Local aCamposDYD := aClone(oStructDYD:GetFields())  
Local aArea      := GetArea()


For nX := 1 To Len(aItensDYD)
	nLinha++
	aAdd(aLoadDYD,{nLinha,Array(Len(aCamposDYD))})
	DYD->(dbGoTo(aItensDYD[nX][1]))
	
	For nY := 1 To Len(aCamposDYD)
		If (aCamposDYD[nY][MODEL_FIELD_IDFIELD] $ ("DYD_NUMAGD"))
			aLoadDYD[nLinha][2][nY]	:= DYD->DYD_NUMAGD
		ElseIf (aCamposDYD[nY][MODEL_FIELD_IDFIELD] $ ("DYD_ITEAGD"))
			aLoadDYD[nLinha][2][nY]	:= DYD->DYD_ITEAGD
		ElseIf (aCamposDYD[nY][MODEL_FIELD_IDFIELD] $ ("DYD_TIPAGD"))				
			aLoadDYD[nLinha][2][nY]	:= DYD->DYD_TIPAGD   
		ElseIf (aCamposDYD[nY][MODEL_FIELD_IDFIELD] $ ("DYD_DATAGD"))
			aLoadDYD[nLinha][2][nY]	:= DYD->DYD_DATAGD
		ElseIf (aCamposDYD[nY][MODEL_FIELD_IDFIELD] $ ("DYD_PRDAGD"))
			aLoadDYD[nLinha][2][nY]	:= DYD->DYD_PRDAGD 
		ElseIf (aCamposDYD[nY][MODEL_FIELD_IDFIELD] $ ("DYD_INIAGD"))
			aLoadDYD[nLinha][2][nY]	:= DYD->DYD_INIAGD
		ElseIf (aCamposDYD[nY][MODEL_FIELD_IDFIELD] $ ("DYD_FIMAGD"))
			aLoadDYD[nLinha][2][nY]	:= DYD->DYD_FIMAGD
		ElseIf (aCamposDYD[nY][MODEL_FIELD_IDFIELD] $ ("DYD_DTCAGD"))
			aLoadDYD[nLinha][2][nY]	:= DYD->DYD_DTCAGD
		ElseIf (aCamposDYD[nY][MODEL_FIELD_IDFIELD] $ ("DYD_USUAGD"))
			aLoadDYD[nLinha][2][nY]	:= DYD->DYD_USUAGD
		ElseIf (aCamposDYD[nY][MODEL_FIELD_IDFIELD] $ ("DYD_NOMUSR"))
			aLoadDYD[nLinha][2][nY]	:= USRRETNAME(DYD->DYD_USUAGD)
		Else
			aLoadDYD[nLinha][2][nY]	:= ""
		EndIf
	Next nY
Next nX

aCamposDYD := aSize(aCamposDYD,0)
RestArea(aArea)    
Return aLoadDYD
//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} StrModMot
Criação do objeto Struct dos campos da aba Gestao de Frete Embarcador
Uso restrito

@sample StrModGFE()
@author Alex Amaral
@since 14/11/14
@version 1.0
/*/
//------------------------------------------------------------------------------------------------
Static Function StrModGFE(nOp)
Local oStruct

//Se for 1 cria o Modelstruc se for 2 cria a viewstruc
If nOp == 1

	oStruct := FWFormModelStruct():New()

	//-------------------------------------------------------------------
	// Tabela
	//-------------------------------------------------------------------
	oStruct:AddTable(			;
	  "GFE"						, ;	// [01] Alias da tabela
	{ "DOC_GFE" }				, ;		// [02] Array com os campos que correspondem a primary key
	  STR0221 		)		          //  [03] Descrição da tabela //"Calculo01"

	//-------------------------------------------------------------------
	// Indices
	//-------------------------------------------------------------------
	oStruct:AddIndex( ;
	01				, ;			// [01] Ordem do indice
	"DOC_GFE"		, ;			// [02] ID
	"DOC_GFE"		, ;			// [03] Chave do indice
	"DOC_GFE"		, ;			// [04] Descrição do indice //"Calculo01"
	''				, ;			// [05] Expressão de lookUp dos campos de indice
	''				, ;			// [06] Nickname do indice
	.T.              )			// [07] Indica se o indice pode ser utilizado pela interface

 	//------------------------------------------------
	//		Cria a estrutura basica manualmente
	//------------------------------------------------
	oStruct:AddField(	" "				, ; // Titulo do campo  ----- Selecionado
							" "				, ; // ToolTip do campo ----- Selecionado
							'GFE_TOTAL'	, ; // Nome do Campo
							'C' 			, ; // Tipo do campo
							35	 			, ; // Tamanho do campo
							0 				, ; // Decimal do campo
							NIL				, ; // Code-block de validação do campo
							NIL				, ; // Code-block de validação When do campo
							{} 				, ; // Lista de valores permitido do campo
							.F.				, ; // Indica se o campo tem preenchimento obrigatório
							NIL				, ; // Code-block de inicializacao do campo
							NIL 			, ; // Indica se trata de um campo chave
							NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 			) 	// Indica se o campo é virtual
							
		oStruct:AddField(	STR0222		, ; // Titulo do campo  ----- Selecionado
							STR0222   		, ; // ToolTip do campo ----- Selecionado
							'GFE_QTDENF'	, ; // Nome do Campo
							'N' 			, ; // Tipo do campo
							12	 			, ; // Tamanho do campo
							0 				, ; // Decimal do campo
							NIL				, ; // Code-block de validação do campo
							NIL				, ; // Code-block de validação When do campo
							{} 				, ; // Lista de valores permitido do campo
							.F.				, ; // Indica se o campo tem preenchimento obrigatório
							NIL				, ; // Code-block de inicializacao do campo
							NIL 			, ; // Indica se trata de um campo chave
							NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 			) 	// Indica se o campo é virtual
		
		oStruct:AddField( STR0202		, ; // Titulo do campo  ----- Selecionado
							STR0202		, ; // ToolTip do campo ----- Selecionado
							'GFE_QTDVOL' 	, ; // Nome do Campo
							'N' 			, ; // Tipo do campo
							14	 			, ; // Tamanho do campo
							0 				, ; // Decimal do campo
							NIL				, ; // Code-block de validação do campo
							NIL				, ; // Code-block de validação When do campo
							{} 				, ; // Lista de valores permitido do campo
							.F.				, ; // Indica se o campo tem preenchimento obrigatório
							NIL				, ; // Code-block de inicializacao do campo
							NIL 			, ; // Indica se trata de um campo chave
							NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 			) 	// Indica se o campo é virtual
		
		oStruct:AddField(	STR0203		, ; // Titulo do campo  ----- Selecionado
							STR0203		, ; // ToolTip do campo ----- Selecionado
							'GFE_PESO' 	, ; // Nome do Campo
							'N' 			, ; // Tipo do campo
							22	 			, ; // Tamanho do campo
							2 				, ; // Decimal do campo
							NIL				, ; // Code-block de validação do campo
							NIL				, ; // Code-block de validação When do campo
							{} 				, ; // Lista de valores permitido do campo
							.F.				, ; // Indica se o campo tem preenchimento obrigatório
							NIL				, ; // Code-block de inicializacao do campo
							NIL 			, ; // Indica se trata de um campo chave
							NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 			) 	// Indica se o campo é virtual
							
		oStruct:AddField(	STR0204		, ; // Titulo do campo  ----- Selecionado
							STR0204		, ; // ToolTip do campo ----- Selecionado
							'GFE_VALMER' 	, ; // Nome do Campo
							'N' 			, ; // Tipo do campo
							22	 			, ; // Tamanho do campo
							2 				, ; // Decimal do campo
							NIL				, ; // Code-block de validação do campo
							NIL				, ; // Code-block de validação When do campo
							{} 				, ; // Lista de valores permitido do campo
							.F.				, ; // Indica se o campo tem preenchimento obrigatório
							NIL				, ; // Code-block de inicializacao do campo
							NIL 			, ; // Indica se trata de um campo chave
							NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 			) 	// Indica se o campo é virtual
							
		oStruct:AddField(	STR0016		, ; // Titulo do campo  ----- Selecionado
							STR0016		, ; // ToolTip do campo ----- Selecionado
							'GFE_VALOR'	, ; // Nome do Campo
							'N' 			, ; // Tipo do campo
							22	 			, ; // Tamanho do campo
							2 				, ; // Decimal do campo
							NIL				, ; // Code-block de validação do campo
							NIL				, ; // Code-block de validação When do campo
							{} 				, ; // Lista de valores permitido do campo
							.F.				, ; // Indica se o campo tem preenchimento obrigatório
							NIL				, ; // Code-block de inicializacao do campo
							NIL 			, ; // Indica se trata de um campo chave
							NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 			) 	// Indica se o campo é virtual
		
		oStruct:AddField(	STR0017		, ; // Titulo do campo  ----- Selecionado
							STR0017		, ; // ToolTip do campo ----- Selecionado
							'GFE_VALIMP'	, ; // Nome do Campo
							'N' 			, ; // Tipo do campo
							18	 			, ; // Tamanho do campo
							2 				, ; // Decimal do campo
							NIL				, ; // Code-block de validação do campo
							NIL				, ; // Code-block de validação When do campo
							{} 				, ; // Lista de valores permitido do campo
							.F.				, ; // Indica se o campo tem preenchimento obrigatório
							NIL				, ; // Code-block de inicializacao do campo
							NIL 			, ; // Indica se trata de um campo chave
							NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 			) 	// Indica se o campo é virtual
							
		oStruct:AddField(	STR0018		, ; // Titulo do campo  ----- Selecionado
							STR0018		, ; // ToolTip do campo ----- Selecionado
							'GFE_VALTOT'	, ; // Nome do Campo
							'N' 			, ; // Tipo do campo
							22	 			, ; // Tamanho do campo
							2 				, ; // Decimal do campo
							NIL				, ; // Code-block de validação do campo
							NIL				, ; // Code-block de validação When do campo
							{} 				, ; // Lista de valores permitido do campo
							.F.				, ; // Indica se o campo tem preenchimento obrigatório
							NIL				, ; // Code-block de inicializacao do campo
							NIL 			, ; // Indica se trata de um campo chave
							NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 			) 	// Indica se o campo é virtual
							
		oStruct:AddField(	"%"			, ; // Titulo do campo  ----- Selecionado
							"%"				, ; // ToolTip do campo ----- Selecionado
							'GFE_PORC'	, ; // Nome do Campo
							'N' 			, ; // Tipo do campo
							10	 			, ; // Tamanho do campo
							0 				, ; // Decimal do campo
							NIL				, ; // Code-block de validação do campo
							NIL				, ; // Code-block de validação When do campo
							{} 				, ; // Lista de valores permitido do campo
							.F.				, ; // Indica se o campo tem preenchimento obrigatório
							NIL				, ; // Code-block de inicializacao do campo
							NIL 			, ; // Indica se trata de um campo chave
							NIL 			, ; // Indica se o campo pode receber valor em uma operação de update.
							.T. 			) 	// Indica se o campo é virtual
							
		
ElseIf nOp == 2

	oStruct := FWFormViewStruct():New()


		oStruct:AddField(	'GFE_TOTAL'	, ; // Nome do Campo
						'01' 			, ; // Ordem
						""			, ; // Titulo do campo  ---- Selecionado
						""		, ; // Descrição do campo  ---- Selecionado
						{""}		, ; // Array com Help  ---- Selecionado
						'C' 			, ; // Tipo do campo
						'@!' 				, ; // Picture
						NIL 			, ; // Bloco de Picture Var
						'' 				, ; // Consulta F3
						.T. 			, ; // Indica se o campo é evitável
						NIL 			, ; // Pasta do campo
						NIL 			, ; // Agrupamento do campo
						{ }				, ; // Lista de valores permitido do campo (Combo)
						NIL 			, ; // Tamanho Maximo da maior opção do combo
						NIL 			, ; // Inicializador de Browse
						.T. 			, ; // Indica se o campo é virtual
						NIL 			  ) // Picture Variável
		
		oStruct:AddField(	'GFE_QTDENF'	, ; // Nome do Campo
						'02' 			, ; // Ordem
						STR0222		, ; // Titulo do campo  ---- Selecionado
						STR0222		, ; // Descrição do campo  ---- Selecionado
						{"Qtde NF"}	, ; // Array com Help  ---- Selecionado
						'N' 			, ; // Tipo do campo
						'' 				, ; // Picture
						NIL 			, ; // Bloco de Picture Var
						'' 				, ; // Consulta F3
						.T. 			, ; // Indica se o campo é evitável
						NIL 			, ; // Pasta do campo
						NIL 			, ; // Agrupamento do campo
						{ }				, ; // Lista de valores permitido do campo (Combo)
						NIL 			, ; // Tamanho Maximo da maior opção do combo
						NIL 			, ; // Inicializador de Browse
						.T. 			, ; // Indica se o campo é virtual
						NIL 			  ) // Picture Variável
						
		oStruct:AddField(	'GFE_QTDVOL'	, ; // Nome do Campo
						'03' 			, ; // Ordem
						STR0202		, ; // Titulo do campo  ---- Selecionado
						STR0202		, ; // Descrição do campo  ---- Selecionado
						{"Qtde Volume"}		, ; // Array com Help  ---- Selecionado
						'N' 			, ; // Tipo do campo
						'' 				, ; // Picture
						NIL 			, ; // Bloco de Picture Var
						'' 				, ; // Consulta F3
						.T. 			, ; // Indica se o campo é evitável
						NIL 			, ; // Pasta do campo
						NIL 			, ; // Agrupamento do campo
						{ }				, ; // Lista de valores permitido do campo (Combo)
						NIL 			, ; // Tamanho Maximo da maior opção do combo
						NIL 			, ; // Inicializador de Browse
						.T. 			, ; // Indica se o campo é virtual
						NIL 			  ) // Picture Variável
						
		oStruct:AddField(	'GFE_PESO'	, ; // Nome do Campo
						'04' 			, ; // Ordem
						STR0203		, ; // Titulo do campo  ---- Selecionado
						STR0203		, ; // Descrição do campo  ---- Selecionado
						{"Peso Real"}	, ; // Array com Help  ---- Selecionado
						'N' 			, ; // Tipo do campo
						PesqPict('DT6','DT6_PESO') 				, ; // Picture
						NIL 			, ; // Bloco de Picture Var
						'' 				, ; // Consulta F3
						.T. 			, ; // Indica se o campo é evitável
						NIL 			, ; // Pasta do campo
						NIL 			, ; // Agrupamento do campo
						{ }				, ; // Lista de valores permitido do campo (Combo)
						NIL 			, ; // Tamanho Maximo da maior opção do combo
						NIL 			, ; // Inicializador de Browse
						.T. 			, ; // Indica se o campo é virtual
						NIL 			  ) // Picture Variável
						
		oStruct:AddField(	'GFE_VALMER'	, ; // Nome do Campo
						'05' 			, ; // Ordem
						STR0204		, ; // Titulo do campo  ---- Selecionado
						STR0204		, ; // Descrição do campo  ---- Selecionado
						{"Valor Mercadoria"}		, ; // Array com Help  ---- Selecionado
						'N' 			, ; // Tipo do campo
						PesqPict('DT6','DT6_VALMER')				, ; // Picture
						NIL 			, ; // Bloco de Picture Var
						'' 				, ; // Consulta F3
						.T. 			, ; // Indica se o campo é evitável
						NIL 			, ; // Pasta do campo
						NIL 			, ; // Agrupamento do campo
						{ }				, ; // Lista de valores permitido do campo (Combo)
						NIL 			, ; // Tamanho Maximo da maior opção do combo
						NIL 			, ; // Inicializador de Browse
						.T. 			, ; // Indica se o campo é virtual
						NIL 			  ) // Picture Variável

		oStruct:AddField(	'GFE_VALOR'	, ; // Nome do Campo
						'06' 			, ; // Ordem
						STR0016		, ; // Titulo do campo  ---- Selecionado
						STR0016		, ; // Descrição do campo  ---- Selecionado
						{"Valor"}		, ; // Array com Help  ---- Selecionado
						'N' 			, ; // Tipo do campo
						PesqPict('GWM','GWM_VLFRET')				, ; // Picture
						NIL 			, ; // Bloco de Picture Var
						'' 				, ; // Consulta F3
						.T. 			, ; // Indica se o campo é evitável
						NIL 			, ; // Pasta do campo
						NIL 			, ; // Agrupamento do campo
						{ }				, ; // Lista de valores permitido do campo (Combo)
						NIL 			, ; // Tamanho Maximo da maior opção do combo
						NIL 			, ; // Inicializador de Browse
						.T. 			, ; // Indica se o campo é virtual
						NIL 			  ) // Picture Variável

		oStruct:AddField(	'GFE_VALIMP'	, ; // Nome do Campo
						'07' 			, ; // Ordem
						STR0017		, ; // Titulo do campo  ---- Selecionado
						STR0017		, ; // Descrição do campo  ---- Selecionado
						{"Imposto"}	, ; // Array com Help  ---- Selecionado
						'N' 			, ; // Tipo do campo
						PesqPict('GWM','GWM_VLICMS')				, ; // Picture
						NIL 			, ; // Bloco de Picture Var
						'' 				, ; // Consulta F3
						.T. 			, ; // Indica se o campo é evitável
						NIL 			, ; // Pasta do campo
						NIL 			, ; // Agrupamento do campo
						{ }				, ; // Lista de valores permitido do campo (Combo)
						NIL 			, ; // Tamanho Maximo da maior opção do combo
						NIL 			, ; // Inicializador de Browse
						.T. 			, ; // Indica se o campo é virtual
						NIL 			  ) // Picture Variável

		oStruct:AddField(	'GFE_VALTOT'	, ; // Nome do Campo
						'08' 			, ; // Ordem
						STR0018		, ; // Titulo do campo  ---- Selecionado
						STR0018    	, ; // Descrição do campo  ---- Selecionado
						{"Valor + Imposto"}		, ; // Array com Help  ---- Selecionado
						'N' 			, ; // Tipo do campo
						PesqPict('GWM','GWM_VLFRET')				, ; // Picture
						NIL 			, ; // Bloco de Picture Var
						'' 				, ; // Consulta F3
						.T. 			, ; // Indica se o campo é evitável
						NIL 			, ; // Pasta do campo
						NIL 			, ; // Agrupamento do campo
						{ }				, ; // Lista de valores permitido do campo (Combo)
						NIL 			, ; // Tamanho Maximo da maior opção do combo
						NIL 			, ; // Inicializador de Browse
						.T. 			, ; // Indica se o campo é virtual
						NIL 			  ) // Picture Variável

		oStruct:AddField(	'GFE_PORC'	, ; // Nome do Campo
						'09' 			, ; // Ordem
						"%"			, ; // Titulo do campo  ---- Selecionado
						"%"		, ; // Descrição do campo  ---- Selecionado
						{"%"}		, ; // Array com Help  ---- Selecionado
						'N' 			, ; // Tipo do campo
						""				, ; // Picture
						NIL 			, ; // Bloco de Picture Var
						'' 				, ; // Consulta F3
						.T. 			, ; // Indica se o campo é evitável
						NIL 			, ; // Pasta do campo
						NIL 			, ; // Agrupamento do campo
						{ }				, ; // Lista de valores permitido do campo (Combo)
						NIL 			, ; // Tamanho Maximo da maior opção do combo
						NIL 			, ; // Inicializador de Browse
						.T. 			, ; // Indica se o campo é virtual
						NIL 			  ) // Picture Variável

EndIf

Return oStruct
 
//---------------------------------------------------------------------------------------------
/*/{Protheus.doc} TmC030LAgd

@Legenda agendamento de entrega
@author Alex Amaral
@since   17/11/2014
@version 1.8
/*/
//---------------------------------------------------------------------------------------------
Function TmC030LAgd()

Local aLegenda := {	{ "BR_VERDE"	, STR0185   },;   //"Ativo"
						{ "BR_AMARELO"	, STR0186 	},; //"Histórico"
						{ "BR_PRETO"	, STR0187 	} }    //"Cancelado"

BrwLegenda( STR0182, STR0055 , aLegenda  )  //"Agendamento de Entrega"

Return( .T. )
 

//-------------------------------------------------------------------
/*{Protheus.doc} TMSC030POS

função para validar e carregar a tela

@author Katia Bianchi
@since 26/01/15
@version 1.0
*/
//-------------------------------------------------------------------

Static Function TMSC030POS(oModel)

Local lRet		:= .T.
Local lUseRedesp := AliasInDic('DFV')
Local cAliasNew  := GetNextAlias()
Local cQuery     := ''
Local aARea  		:= GetArea()

If lUseRedesp
	cQuery := "SELECT DFV.DFV_NUMRED, DFV.DFV_CODFOR, DFV.DFV_LOJFOR, SA2.A2_NOME "
	cQuery += "  FROM " + RetSqlName("DFV") + " DFV "
	cQuery += "       INNER JOIN " + RetSqlName("SA2") + " SA2 ON (SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SA2.A2_COD = DFV.DFV_CODFOR AND SA2.A2_LOJA = DFV.DFV_LOJFOR) "
	cQuery += " WHERE DFV.DFV_FILDOC = '" + M->DT6_FILDOC + "' AND DFV.DFV_DOC = '" + M->DT6_DOC + "' AND DFV.DFV_SERIE = '" + M->DT6_SERIE + "' AND DFV.D_E_L_E_T_ = ''"
	cQuery += "   AND DFV.DFV_NUMRED = (SELECT (MAX(DFV_1.DFV_NUMRED)) FROM " + RetSqlName("DFV") + " DFV_1 "
	cQuery += "   WHERE DFV_1.DFV_FILDOC = '" + M->DT6_FILDOC + "' AND DFV_1.DFV_DOC = '" + M->DT6_DOC + "' AND DFV_1.DFV_SERIE = '" + M->DT6_SERIE + "' AND DFV_1.D_E_L_E_T_ = '')"
	cQuery += " AND SA2.D_E_L_E_T_ = ''"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry( , , cQuery ), cAliasNew, .F., .T. )

	If (cAliasNew)->(!Eof())
						
		oModel:LoadValue( 'DT6MASTER', 'DT6_NUMRED',	(cAliasNew)->DFV_NUMRED)
		oModel:LoadValue( 'DT6MASTER', 'DT6_CODRED',	(cAliasNew)->DFV_CODFOR)
		oModel:LoadValue( 'DT6MASTER', 'DT6_LOJRED',	(cAliasNew)->DFV_LOJFOR)
		oModel:LoadValue( 'DT6MASTER', 'DT6_NOMRED',	Substr((cAliasNew)->A2_NOME,1,30))	
			
	EndIf
	(cAliasNew)->(dBCloseArea())

EndIf
RestArea(aArea)

Return (lRet)
 