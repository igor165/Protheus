#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FISA001.CH"

//------------------------------------------------------------------
/*/{Protheus.doc} FISA001

Rotina da apuração da EFD Contribuições. 
@author Erick G. Dias
@since 02/04/2014
@version 11.80
@description teste descrição 

/*/
//------------------------------------------------------------------
Function FISA001()

	Private EAI_MESSAGE_MVC := ""
	Private oBrowse 
	Private oPanelBrw
	PRIVATE cMarca     	 := GetMark()

	STATIC NAOCUMULAT		:= '1'
	STATIC CUMULAT 		:= '2'
	STATIC NFENTRADA		:= '1'
	STATIC NFSAIDA 		:= '2'	
	STATIC PIS				:= '1'
	STATIC COFINS 		:= '2'
	STATIC REDUCAO 		:= '0'
	STATIC ACRESCIMO	 	:= '1'
	STATIC CREDITO 		:= '1'
	STATIC DEBITO 		:= '2'
	STATIC LVROFISCAL		:= '1'	
	STATIC FISCALENT		:= '1'		
	STATIC FISCALSAI		:= '2'	
	STATIC TITENTRADA		:= '3'	
	STATIC TITSAIDA		:= '4'
	STATIC ATIVOFIXO		:= '5'
	STATIC CUPOM			:= '6'	
	STATIC CPRB			:= '7'
	STATIC OUTROS			:= '8'
	STATIC cCSTCRED		:= '50/51/52/53/54/55/56/60/61/62/63/64/65/66' //CSTs de PIS e Cofins que dão direito a crédito na apuração do bloco M
	STATIC cCstTrib		:= '01/02/03/05'  //CSts tributáveis
	STATIC cCstNTrib		:= '04/06/07/08/09/49/99' //CSts não tributáveis
	
	 AjustaSX1()
			
	If AliasINdic('CKR')	
		FWExecView(STR0020,'FISA001', MODEL_OPERATION_INSERT,,, { || .T. } )//'Rotina de Apuração EFD Contribuições'
	Else
		Alert(STR0021)//'Tabelas não criadas, por favor processa compatibilizado UPDFIS'
	EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
 
@author Erick G. Dias
@since 02/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}	

ADD OPTION aRotina TITLE STR0024 ACTION 'A001Agrp()' OPERATION 3 ACCESS 0 //'Agrupar Filial -> Matriz'
ADD OPTION aRotina TITLE STR0022 ACTION 'VisualApur' OPERATION 2 ACCESS 0 //"Visualizar"
ADD OPTION aRotina TITLE STR0023 ACTION 'EditaApur' OPERATION 4 ACCESS 0 //'Editar' 
ADD OPTION aRotina TITLE 'Excluir' ACTION 'ExcluApur' OPERATION 5 ACCESS 0 //'Editar'
ADD OPTION aRotina TITLE 'Visualizar Log' ACTION 'ProcLogView("","FISA001")' OPERATION 5 ACCESS 0 //'Editar'
ADD OPTION aRotina TITLE 'Sobre' ACTION 'ISA001Data()' OPERATION 5 ACCESS 0 //'Editar'

If FindFunction('FISR101')
	ADD OPTION aRotina TITLE 'Relatório de Conferência EFD' ACTION 'FSA001REL' OPERATION 1 ACCESS 0 //'Editar'
EndIF

Return ( aRotina )


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
 
@author Erick G. Dias
@since 02/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStructABA := FWFormStruct( 1, 'CKR')   

oModel	:=	MPFormModel():New('MODEL_ABA')
oModel:AddFields( 'MODEL_ABA' ,, oStructABA )
oModel:SetPrimaryKey( { 'ABA_CMP1'} )
oModel:SetDescription( 'TOTVS')
	
Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
 
@author Erick G. Dias
@since 02/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function ViewDef()
Local oModel    := FWLoadModel( 'FISA001' )
Local oView     := FWFormView():New()
Local oStruFilt	:= FWFormStruct( 2, '' )
Local oStruABA   := FWFormStruct( 2, 'CKR' )

oView:SetModel( oModel )

oView:AddField( 'VIEW_ABA', oStruABA, 'MODEL_ABA' )

oView:AddOtherObject( 'PANEL_TREE',  { |oPanel| MONTATREE( oPanel ) } )
oView:AddOtherObject( 'PANEL_EMPTY', { |oPanel| } )						
oView:AddOtherObject( 'PANEL_BROWSE',{ |oPanel| oPanelBrw := oPanel, FBrowseMon( oPanel ) } )

oView:EnableTitleView('PANEL_TREE',STR0025)//'Rotinas Disponíveis'

oView:CreateHorizontalBox( 'INFO_FUNC'	  	,00 ) 
oView:CreateHorizontalBox( 'EVENTO_FUNC'	,98 )
oView:CreateHorizontalBox( 'FIM_TELA'   	,02 )	

oView:CreateVerticalBox( 'INFO_FUNC_ESQ'		, 100	,'INFO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_ESQ'		, 27	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_CENTER'	, 01	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'EVENTO_FUNC_DIR'		, 72	,'EVENTO_FUNC' )
oView:CreateVerticalBox( 'FIM_TELA_EMPTY'		, 100	, 'FIM_TELA' )

oView:SetOwnerView( 'VIEW_ABA'		, 'INFO_FUNC_ESQ' )
oView:SetOwnerView( 'PANEL_TREE'	, 'EVENTO_FUNC_ESQ' )
oView:SetOwnerView( 'PANEL_EMPTY'	, 'EVENTO_FUNC_CENTER' )
oView:SetOwnerView( 'PANEL_BROWSE'	, 'EVENTO_FUNC_DIR' )
oView:SetOwnerView( 'PANEL_EMPTY'	, 'FIM_TELA_EMPTY' )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} MontaTree
Função que cria tree com as rotinas disponíveis
 
@author Erick G. Dias
@since 02/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------

STATIC FUNCTION MontaTree(oPanel)

Local oTree 
Local aCoors := FWGetDialogSize( oPanel )
//Local bChange := { || Processa( { || FChgTree( oTree,oPanel )  }, "Processando", "" ) } 
Local bChange := { || FChgTree( oTree,oPanel )  }

oTree := DbTree():New( aCoors[1] + 20 ,aCoors[2] +5,aCoors[3]-10,aCoors[4]-10, oPanel,bChange , , .T. )

oTree:AddTree( Padr(STR0018,40), .T., "FOLDER5" ,"FOLDER6",,,"000" )
oTree:TreeSeek( "001" )
oTree:AddItem(STR0004,"001","PMSEDT3","",,,2) ////"Processar Apuração da EFD Contribuições"
oTree:AddItem(STR0014,"002","PMSEDT3","",,,2)//diferimento
oTree:AddItem(STR0005,"003","PMSEDT3","",,,2)//"Demais Documentos PIS/COFINS"
oTree:AddItem(STR0006,"004","PMSEDT3","",,,2)//"Exclusões de Sociedade Cooperativa"
oTree:AddItem(STR0007,"005","PMSEDT3","",,,2) //"Deduções Diversas PIS COFINS"
oTree:AddItem(STR0008,"006","PMSEDT3","",,,2) //"Ajuste de créditos PIS/COFINS"
oTree:AddItem(STR0009,"007","PMSEDT3","",,,2)//"Controle de saldo de Crédito de PIS"
oTree:AddItem(STR0010,"008","PMSEDT3","",,,2)//"Controle de saldo de Crédito da COFINS"
oTree:AddItem(STR0011,"009","PMSEDT3","",,,2)//"Crédito Extemporâneo"
oTree:AddItem(STR0012,"010","PMSEDT3","",,,2)//"Crédito Sobre Estoque de Abertura"
oTree:AddItem(STR0013,"011","PMSEDT3","",,,2)//"Ressarcimento de crédito de PIS e COFINS"
oTree:AddItem(STR0015,"012","PMSEDT3","",,,2)//Relatorio
oTree:AddItem('Importação Códigos EFD',"013","PMSEDT3","",,,2)//Rotina de importação dos códigos da Receita Federal

IF Findfunction('FISA006')
	oTree:AddItem('Demais Retenções',"014","PMSEDT3","",,,2)//Rotina de Demais Retenções
EndIF

IF Findfunction('FISA008')
	oTree:AddItem('Geração do Arquivo da EFD Contribuições',"015","PMSEDT3","",,,2)//Rotina de geração do Arquivo
EndIF



return (nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} FChgTree
 
@author Erick G. Dias
@since 02/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------

Static Function FChgTree( oTree )

Local cIdTreePos := ""

Local aInfTree := {}

//Busco a identificação de qual item da Tree estamos posicionadoss
cIdTreePos := oTree:GetCargo()
oPanelBrw:FreeChildren()
oBrowse:DeActivate()	
aInfTree := FChcTpFunc( cIdTreePos ,oTree)
FBrowseMon( oPanelBrw, aInfTree[1], aInfTree[2], aInfTree[3], aInfTree[4] )
oBrowse:Refresh()
	
Return ( Nil )

//-------------------------------------------------------------------
/*/{Protheus.doc} FBrowseMon
 
@author Erick G. Dias
@since 02/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function FBrowseMon( oPanel, cFonteTree, cAliasTree, cFiltroBrw, cDescBrw )

Local aInf, aFields := {}
Local cFunc := "MethIsMemberOf"

Default cFonteTree := ""   
Default cAliasTree := ""
Default cFiltroBrw := ""
Default cDescBrw   := ""

oBrowse := FWmBrowse():New()

If &cFunc.(oBrowse,"SetMainProc")
	oBrowse:SetMainProc("FISA001")
EndIf


If Empty( cFonteTree ) .And. Empty( cAliasTree )
	aInf := FChcTpFunc()
	
	cFonteTree := aInf[1]   
	cAliasTree := aInf[2]
	cFiltroBrw := aInf[3]
	cDescBrw   := aInf[4]
	
	oBrowse:AddLegend( "CKR_STATUS=='1'", "RED"		, STR0026)//"Apuração não gerou título e não contabilizou." 	
	oBrowse:AddLegend( "CKR_STATUS=='2'", "YELLOW" 	, STR0027 )//"Apuração gerou gerou título"
	oBrowse:AddLegend( "CKR_STATUS=='3'", "GREEN" 	, STR0028 )//"Apuração gerou título e contabilizou"	
	oBrowse:AddLegend( "CKR_STATUS=='4'", "BLUE" 		, STR0029 )//"Apuração Considerada para Consolidação na Matriz"	
	 
EndIf

oBrowse:SetOwner( oPanel )
oBrowse:SetDescription( cDescBrw )
oBrowse:SetAlias( cAliasTree )
 
oBrowse:SetMenuDef( cFonteTree ) 
oBrowse:DisableDetails()
oBrowse:SetFilterDefault( cFiltroBrw )

oBrowse:Activate()

Return ( Nil ) 


//-------------------------------------------------------------------
/*/{Protheus.doc} x001GetSX3
 
@author Erick G. Dias
@since 02/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Function x001GetSX3( cAlias )


Local aFields := {}

DBSelectArea( "SX3" )
SX3->( DBSetOrder( 1 ) )
If SX3->( MsSeek( cAlias ) )
	While SX3->( !Eof() ) .and. SX3->X3_ARQUIVO == cAlias
		If X3Usado( SX3->X3_CAMPO ) .and. SX3->X3_CONTEXT <> "V"
			aAdd( aFields, { AllTrim( X3Titulo() ),;
			                 SX3->X3_CAMPO,;
			                 SX3->X3_TIPO,;
			                 SX3->X3_PICTURE,;
			                 SX3->X3_CBOX,;
			                 SX3->X3_TAMANHO,;
			                 SX3->X3_DECIMAL,;
			                 SX3->X3_WHEN,;
			                 SX3->X3_VALID} )
		EndIf
		SX3->( DBSkip() )
	EndDo
EndIf

Return( aFields )


//-------------------------------------------------------------------
/*/{Protheus.doc} x001Struct
 
Função utilizada para criação das tabelas temporárias para as abas
da apuração, já que as tabelas não estão em dicionário, deverão ser 
criadas manualmente.
  
@param  	nOpcao  - indica se foi chamada na criação do Model ou da View.
			cTabela - Indica o alias da tabela temporária
@return	oStru  - Estrutura criada com os campos da tabela temporária qe será exibida na tela.			
@author Erick G. Dias
@since 07/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Function x001Struct(nOpcao,cTabela)

Local aCampos	:= {}
Local nCont	:= 0
Local oStru

//Chama Função para criar os campos conforme tabela processada
aCampos:= a002Tabs(cTabela)

//Quando for chamada para criar Model
If nOpcao == 1
	
	oStru :=  FWFormModelStruct():New()//	FWFormStruct( 1 , '')//
	oStru:AddTable("TRB",{},"TOTVS")	
	For nCont := 1 to len (aCampos)
		oStru:AddField( ; 					// Ord. Tipo Desc.
						aCampos[nCont][1] , ;// [01] C Titulo do campo
						aCampos[nCont][1] , ;// [02] C ToolTip do campo
						aCampos[nCont][2] , ;// [03] C identificador (ID) do Field
						aCampos[nCont][3] , ;// [04] C Tipo do campo
						aCampos[nCont][4] , ;// [05] N Tamanho do campo
						aCampos[nCont][5] , ;	// [06] N Decimal do campo
						NIL				,;	// [07] B Code-block de validação do campo
						NIL 				, ;	// [08] B Code-block de validação When do campo
						{}					, ;	// [09] A Lista de valores permitido do campo
						NIL 				, ;	// [10] L Indica se o campo tem preenchimento obrigatório
						nil					, ;	// [11] B Code-block de inicializacao do campo
						NIL 				, ;	// [12] L Indica se trata de um campo chave
						.F. 				, ;	// [13] L Indica se o campo pode receber valor em uma operação de update.
						.F. ) 					// [14] L Indica se o campo é virtual
	Next nCont
	
//Quando for chamada para criar a View
ElseIF nOpcao == 2
	
	oStru := FWFormStruct( 2, '')		
	For nCont := 1 to len (aCampos)
		oStru:AddField( ; 
		aCampos[nCont][2], ; // [01] C Nome do Campo
		aCampos[nCont][6], ;	// [02] C Ordem
		aCampos[nCont][1], ;	// [03] C Titulo do campo
		aCampos[nCont][1], ;	// [04] C Descrição do campo
	    aCampos[nCont][7], ; // [05] A Array com Help
		aCampos[nCont][3], ; 	// [06] C Tipo do campo
		aCampos[nCont][8], ; // [07] C Picture
		NIL 			   , ;	// [08] B Bloco de Picture Var
		''                 , ; 	// [09] C Consulta F3
		aCampos[nCont][9]	, ; 	// [10] L Indica se o campo é evitável
		nil				   , ; 	// [11] C Pasta do campo
		NIL                , ;	// [12] C Agrupamento do campo
		{}                 , ; 	// [13] A Lista de valores permitido do campo
		NIL                , ;	// [14] N Tamanho Maximo da maior opção do combo
		NIL                , ; 	// [15] C Inicializador de Browse
		.F.                , ; 	// [16] L Indica se o campo é virtual
		NIL ) 		
	Next nCont	

EndIF

Return oStru

//-------------------------------------------------------------------
/*/{Protheus.doc} FChcTpFunc
Função que identifica a opção selecionada pelo usuário e abre a rotina
pertinente a opção selecionada.

@author Erick G. Dias
@since 02/04/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Function FChcTpFunc( cIdTreePos ,oTree, aReprocess)

Local aRet   			:= Array( 04 )
local lReproc			:= .F.
Local lProc			:= .F. 
local lLoad			:= .F.
Local lProcessou		:= .F.
Local aThread			:= {}
Local nX				:= 0
Local aPergunta	:={}
Local aFil			:={}
Local aDiaThread	:= {}
Local lEnd			:= .F.
Local nQtdThread	:= SuperGetMv("MV_QTDTAEC",.F.,0)
Local oProcess
Local lAutomato  	:= .F.

Default aReprocess	:=	{}
Default cIdTreePos 	:= ""

If Len(aReprocess) > 0
	lAutomato := .T.
EndIf

Do Case

	Case EmptY(cIdTreePos)
		aRet[1] := 'FISA001'
		aRet[2] := 'CKR'
		aRet[3] := ""
		aRet[4] := STR0030//"Rotina de Apuração da EFD Contribuições"
	Case cIdTreePos == "001"		

		If lAutomato

			aPergunta	:= GuardaPerg()
			//-------------------------------
			//Verifica se apuração já existe
			//-------------------------------
			If CheckApur() 
				//Aqui deseja reprocessar
				IF CheckDup(lAutomato) //Pergunta se quer excluir os títulos, se houve
					//Deseja excluir os títulos e reprocessar
					lReproc	:= .T.				
				Else
					//Aqui quer somente carregar apuração, sem reprocessamento
					lLoad := .T.	
				EndIF
			Else
				//Não existe apuração
				//Processar normalmente, pois será a primeira vez para esta filial e período
				lProc	:= .T.
			EndIF
			
		ElseIf Pergunte("ISA001",.T.)
			aPergunta	:= GuardaPerg()
			//-------------------------------
			//Verifica se apuração já existe
			//-------------------------------
			If CheckApur() 
				//Já existe apuração processada, deverá perguntar se o usuário quer reprocessatr
				cPerg	:= STR0031 + CRLF //'Já existe apuração processada para este período e filial.'
				cPerg	+= STR0032 + CRLF //'Deseja fazer o reprocessamento?'
				cPerg	+= STR0033			//'(Sim - Reprocessa / Não - Visualiza Apuração)'	

				If ( ApMsgYesNo(cPerg ) )		//Irá apagar os títulos
					//Aqui deseja reprocessar
					IF CheckDup() //Pergunta se quer excluir os títulos, se houve
						//Deseja excluir os títulos e reprocessar
						lReproc	:= .T.
						//-------------------------------------------------------
						//Irá chamar função para verificar quais opções o usuário 
						//deseja considerar no reprocessamento
						//-------------------------------------------------------
						aReprocess	:= ISA001PERG()
					Else
						//Não deseja excluir os títulos, irá somente carregar apuração
						lLoad := .T.
					EndIF					
					
				Else
					//Aqui quer somente carregar apuração, sem reprocessamento
					lLoad := .T.	
				EndIF				
				
			Else
				//Não existe apuração
				//Processar normalmente, pois será a primeira vez para esta filial e período
				lProc	:= .T.
			EndIF
		EndIf	

		IF lReproc .OR. lProc			
			//Somente irá processar se aúração ainda não existe ou se deseja fazer reprocessamento.
			ProcLogIni({})
			ProcLogAtu("INICIO","#### --- Início da ápuração --- #### " + Time(),,upper('FISA001'))
			
			//aPergunta	:= GuardaPerg()
			aFil		:= GetFilial()
			
			//Begin Transaction
			IF Len(aFil) > 0
				
				If lAutomato
					Processa({|lEnd|ProcEFD(oProcess,aReprocess,aPergunta,aFil,.T.,{},,@lProcessou)})
				Else					

					oProcess := FISProgress():New({|lEnd| lEnd :=ProcEFD(oProcess,aReprocess,aPergunta,aFil,.T.,{},,@lProcessou)},STR0034)//'Processado Apuração EFD Contribuições'
					oProcess:Activate()					
				EndIf	
		
				IF !lProcessou 
					//-------------------------
					//Não processou com sucesso, não vai fazer confirmar a gravação das informações
					//no banco de dados
					//-------------------------					
					DisarmTransaction()

				EndIF
				
				//End Transaction
				ProcLogAtu("FIM","#### --- Final da apuração --- #### " + Time(),,upper('FISA001'))
			EndIF
				
		EndIF	
		
		IF lProcessou //Somente carrega se processou com sucesso.
			
			Begin Transaction
			ProcLogIni({})
			ProcLogAtu("INICIO","Início do carregamento da Apuração - " + Time(),,upper('FISA001'))
			If MV_PAR15 == 1  .OR. (MV_PAR15==2 .AND. LEn(aFil) ==1)   //Somente irá exibir a apuração quando for consolidada. Se for individualizada o usuário terá que abrir pela tela
				
				aAreaSM0 := SM0->(GetArea())
				If MV_PAR15==2 .AND. LEn(aFil) ==1
					SM0->(DbGoTop ())
					SM0->(MsSeek (aFil[1][1]+aFil[1][2], .T.))	//Pego a filial mais proxima
					cFilAnt := FWGETCODFILIAL

				EndIF
				
				//Verifica se o valor Desonerado é superior ou igual a 5%, caso seja, as informações serão apagadas das tabelas da CPRB e não será apresentado na tela da Apuração e no arquivo
				ConsCPRB( aFil, aPergunta)
				
				FISA002(lLoad, .F.,MV_PAR06,lAutomato)
				RestArea (aAreaSM0)
				cFilAnt := FWGETCODFILIAL
				
			EndIF
			ProcLogAtu("FIM","Fim do carregamento da Apuração - " + Time(),,upper('FISA001'))			
			End Transaction	
			
		EndIF		

		If !lAutomato		
			oTree:TreeSeek('000')
		EndIf
	Case cIdTreePos == "002"
		FISA054()	
		oTree:TreeSeek('000')
	Case cIdTreePos == "003"
		aRet[1] := 'FISA048'
		aRet[2] := 'CF8'
		aRet[3] := ""
		aRet[4] := STR0005		
	Case cIdTreePos == "004"
		aRet[1] := 'FISA039'
		aRet[2] := 'CE9'
		aRet[3] := ""
		aRet[4] := STR0006		
	Case cIdTreePos == "005"
		aRet[1] := 'FISA041'
		aRet[2] := 'CF2'
		aRet[3] := ""
		aRet[4] := "STR0007	
	Case cIdTreePos == "006"
		aRet[1] := 'FISA042'
		aRet[2] := 'CF5'
		aRet[3] := ""
		aRet[4] := STR0008
	Case cIdTreePos == "007"
		aRet[1] := 'FISA044'
		aRet[2] := 'CCY'
		aRet[3] := ""
		aRet[4] := STR0009	
	Case cIdTreePos == "008"
		aRet[1] := 'FISA045'
		aRet[2] := 'CCW'
		aRet[3] := ""
		aRet[4] := STR0010	
	Case cIdTreePos == "009"
		aRet[1] := 'FISA046'
		aRet[2] := 'CF6'
		aRet[3] := ""
		aRet[4] := STR0011
	Case cIdTreePos == "010"
		aRet[1] := 'FISA049'
		aRet[2] := 'CF9'
		aRet[3] := ""
		aRet[4] := STR0012	
	Case cIdTreePos == "011"
		aRet[1] := 'FISA050'
		aRet[2] := 'CG4'
		aRet[3] := ""
		aRet[4] := STR0013
	Case cIdTreePos == "012"
		FISR020()	
		oTree:TreeSeek('000')

	Case cIdTreePos == "013"
		FISA005('CCZ')	
		oTree:TreeSeek('000')
		
	Case cIdTreePos == "014"		
		aRet[1] := 'FISA006'
		aRet[2] := 'CLG'
		aRet[3] := ""
		aRet[4] := 'Demais Retenções'		
		
	Case cIdTreePos == "015"
		FISA008()	
		oTree:TreeSeek('000')	
			
	OtherWise
		aRet[1] := ""
		aRet[2] := ""
		aRet[3] := ""
		aRet[4] := ""
EndCase
		
Return ( aRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcEFD()
Função que irá processar as informações da EFD Contribuições, irá chamar
as diversas funções, métodos, integrações para processamento de todas 
informações da EFD Contribuições.

@Param		oProcess - Objeto da classe FISXCLASS, que irá exibir a barra 
						de progresso da apuração
			aReprocess	- Array com informações das opções que deverá ser 
						  ou não reprocessadas.
@Return	lProcessou - Irá retornar se apuração foi processar corretamente,
						   sem erro ou cancelamento pelo usuário.							 
@author Erick G. Dias
@since 08/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ProcEFD(oProcess,aReprocess,aParSX1,aSM0,lMain,aThread1,cNomeJob,lProcessou)
 	
Local lBlocI			:= .F.
Local lCPRB			:= .F.
Local lPisSal			:= .F.
Local lSocCoop		:= .F.
Local lProcCred		:= .F.
Local lDifer			:= .F.
Local lPFisEnt		:= .T.
Local lPFisSai		:= .T.
Local lPTitEnt		:= .T.
Local lPTitSai		:= .T.
Local lPATF			:= .T.
Local lPCupom			:= .T.
Local lPCPRB			:= .T.
Local lPOutros		:= .T. 
Local lReprocess		:= .T.
Local lCancel			:= .F.
Local lCupom			:= .F.
Local lindividu		:= .F.
Local lVendaFora		:= GetNewPar('MV_SPDGRNF',.F.)
Local lTelSemLiv		:= GetNewPar('MV_ESTTELE',.F.)
Local aAreaSM0		:= {}
Local aXFilial		:= {}
Local aXFilialRe		:= {}
Local aFil			:= {}
Local nMVM996TPR		:= GetNewPar('MV_M996TPR',.F.)
Local nContFil		:= 0
Local nTotF100		:= 0
Local nBsConsorc		:= 0
Local cFilAte			:= ''
Local cRegime			:= ''
Local nContThr		:= 0
Local lErro			:= .F.
Local nX			 := 0
Local aDiaThread		:= {}
Local nQtdThread		:= SuperGetMv("MV_QTDTAEC",.F.,0)
Local aThread  	:= {}
Local dUltDia			:= LastDay (aParSX1[1]) + 1
Local cProxPer		:=	cvaltochar(strzero(month(dUltDia ) ,2)) + cvaltochar(year(dUltDia ))
Local cFilialMat		:= FWGETCODFILIAL //Busca código da filial da filial logada, pois este código será gravado nas tabelas da apuração.
Local	bWhileSM0		:=	{||!SM0->(Eof ()) .And.  cEmpAnt==SM0->M0_CODIGO .And. ((!"1"$aWizard[1][12] .And. FWGETCODFILIAL<=cFilAte) .Or. ("1"$aWizard[1][12] .And. Len(aLisFil)>0))}

Local oAjustes
Local oApurEnt
local oApurSai
local oCompCred
Local oCPRB
Local TimeInicio
Local TimeFim
Local oSaldoCred
Local oDeducao
Local oApurPIS
Local oApurCOF
Local mvAlqCprb	:=GetNewPar('MV_CPRBALQ','')
Local cCodAtiviv := Substr(mvAlqCprb,1,  At("/",mvAlqCprb)-1  )
Local nAlqCprb :=val( Substr(mvAlqCprb,At("/",mvAlqCprb)+1,  len(mvAlqCprb)  ))
Local aF100	:= {}   
Local lCPRBNF		:= GetNewPar('MV_CPRBNF',.F.) .And. SFT->(ColumnPos("FT_VALCPB")) .And. SFT->(ColumnPos("FT_BASECPB")) .And. SFT->(ColumnPos("FT_ALIQCPB"))
Local cSPCBPSE	:= GetNewPar("MV_SPCBPSE",'')  
Local lCredPAgro := GetNewPar("MV_CPPCAGR",.F.)
Local cCtlDedRet	:= "" //Controle da função DeduzReten ("A" = processa Saldos e Retenção / "S" = Apenas saldos  /  "R" = Apenas retenções)
Local cPrefixE1	:= ''
Local cCmpB1Dif	:=	''
Local cCmpA1Dif	:=	''
Local aParFiltr	:= {}
Local cAliasDIF	:= ''
Local cPerApur	:= ''
Local cDifApur	:= '2'//GetNewPar("MV_DIFPC01",'1') //Indica se o diferimento será calculado através da FISA054 (opção 1) ou através da FISA001 (opção 2)
Local ObjF0T	

DEFAULT cNomeJob := cNomeJob
DEFAULT lProcessou	:= .F.

//Verifica se o processamento é com opção de gravação individualizada.
lindividu	:= .F.
If aParSX1[15] == 2
	lindividu	:= .T.
EndIF	

If nMVM996TPR == 3 .AND. aParSX1[6] == 4
	DbSelectArea ('SA1')
	If ! SA1->(ColumnPos( 'A1_TPREG' ))
		Alert(STR0036)//'O parâmetro MV_M996TPR está configurado para considerar o campo A1_TPREG, porém este campo não existe. Consulte Boletim técnico para consultar configurações.')
		Return
	EndIF
EndIF

IF Empty(aParSX1[1]) .OR. Empty(aParSX1[2])
	Alert(STR0035)//'Necessário informar datas do período a ser processado'
	Return
EndIf

//----------------------------------
//VERIFICA O REGIME DE PIS E COFINS
//----------------------------------
If aParSX1[5] == 1 .OR. aParSX1[5] == 3
	IF aParSX1[6] == 1
		cRegime	:=	'1' //Não Cumulativo Competência	
	ElseIF aParSX1[6] == 2
		cRegime	:=	'2' //Cumulativo Competência
	ElseIF aParSX1[6] == 3
		cRegime	:=	'3'	//Cumulativo Caixa
	ElseIF aParSX1[6] == 4
		cRegime	:=	'4'	//Cumulativo/Não Cumulativo	
	EndIF
EndIF

//----------------------------------------------------------
//Se procesar PIS/COFINS +CPRB ou se processar somente CPRB
//----------------------------------------------------------
If aParSX1[5] == 2 .OR. aParSX1[5] == 3
	lCPRB	:= .T.	//Irá processar bloco P
EndIF

//-------------------------------------------------
//Indica se irá processa PIS Sobre Folha de salário
//-------------------------------------------------
If aParSX1[7] == 1
	lPisSal	:= .T.
EndIF 

//----------------------------------------------------------
//Indica se irá processa PIS e COFINS Sociedade Cooperativa
//----------------------------------------------------------
If aParSX1[8] == 1
	lSocCoop	:= .T.
EndIF

//--------------------------------------------------------------------
//Indica se irá processa PIS COFINS - Instituição Financeira - bloco I
//--------------------------------------------------------------------
If aParSX1[9] == 1
	lBlocI	:= .T.
EndIF

//--------------------------------------------------------------
//Indica se irá processar valores de diferimento de PIS e COFINS
//--------------------------------------------------------------
If aParSX1[10] == 1
	lDifer	:= .T.
EndIF

//-----------------------------------------------
//Indica se irá processar valores de cupom fiscal
//-----------------------------------------------
If aParSX1[11] == 1 .AND. cRegime <> '3'
	lCupom	:= .T.
EndIF

//---------------------------------------------------------------------------
//Processa créditos se regime for Não Cumulativo ou Cumulativo/Não Cumulativo
//---------------------------------------------------------------------------
IF cRegime $ '1/4' .or. (!lBlocI .AND. cRegime <> '2')
	lProcCred	:= .T.
EndIF

If cRegime == '3'
	lProcCred	:= .F.
EndIF
aXFilial:= ASA001AFIL()

 //-----------------------------------------------------------------------------------
 //Verifica se aReprocess está preenchido, se não estiver então não se trata de reprocessamento.
 //Se estiver, então irá preencher as perguntas conforme as opções de reprocessamento 
 //indicadas pelo usuário. 
 //-----------------------------------------------------------------------------------
If Len(aReprocess) > 0
	lReprocess	:= .T.
	lPFisEnt	:= Iif(aReprocess[1] == 1,.T.,.F.)
	lPFisSai	:= Iif(aReprocess[2] == 1,.T.,.F.)
	lPTitEnt	:= Iif(aReprocess[3] == 1,.T.,.F.)
	lPTitSai	:= Iif(aReprocess[4] == 1,.T.,.F.)
	lPATF		:= Iif(aReprocess[5] == 1,.T.,.F.)
	lPCupom	:= Iif(aReprocess[6] == 1,.T.,.F.)
	lPCPRB		:= Iif(aReprocess[7] == 1,.T.,.F.)
	lPOutros	:= .T.	
EndIF		

IF lMain	
	
	//Chama função para limpar taela CF4 antes de popular
	ASA001DCF4(SubStr(DTos(aParSX1[1]),5,2)+SubStr(Dtos(aParSX1[1]),1,4))
	
	//Se for consolidado, então irá zerar aqui aqui todas as operações que foram
	//gravadas com xFilial da Matriz
	If !lindividu //Apuração Consolidada
		//Zera os créditos 
		IniCred(aParSX1,aXFilial)
		//Zera as deduções
		IniDeducao(aParSX1,aXFilial)
		//Zera as retenções
		IniRetenca(aParSX1,aXFilial)
		//Zera as tabelas da apuração
		IniTabApur (aParSX1,aXFilial,.T.,Len(aReprocess) > 0) //Limpa as tabelas de apuração e também as auxiliares
				
		If Len(aReprocess) >0
			If lMain .And. ValType(oProcess)=="O"
				oProcess:Inc2Progress('Reprocessando apuração')
				oProcess:Inc2Progress('Reprocessando apuração')			
				If oProcess:Cancel()
					lCancel:=.T.
//						Exit
				EndIf
			EndIF
			//Aqui chama as funções para realizar o reprocessamento
			ISA001CLA(aParSX1[1],aParSX1[2],,'2',aXFilial)
			ReprocEFD(aParSX1[1],aParSX1[2],'2',aReprocess,aXFilial)
		EndIF								
	EndIF
	
EndIF

ProcLogAtu("MENSAGEM","Fim da Inicialização de Tabelas de Saldos - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)

//--------------------------------------------------------
//AQUI IRÁ INICIAR AS DEMAIS THREADS CASO CONFIGURADO...
//--------------------------------------------------------
IF lMain .AND. nQtdThread > 0
	aDiaThread		:= A001DIATHR(nQtdThread+1,aParSX1[1], aParSX1[2])
	aThread		:= IniThread(aReprocess,aSM0,aParSX1,aDiaThread,nQtdThread)
	aParSX1[1]	:= aDiaThread[1][1]
	aParSX1[2]	:= aDiaThread[1][2]
EndIF

aAreaSM0 := SM0->(GetArea())
DbSelectArea("SM0")
//--------------------------------------------------------
//Irá preencher aSM0 somente com as filiais selecionadas
//pelo cliente  
//--------------------------------------------------------

TimeInicio := Time()
IF lMain .And. ValType(oProcess)=="O"
	oProcess:Set1Progress(len(aSM0)*2)
	oProcess:Set2Progress(1)
			/*"Inicio do processamento"*/
			/*"Fim do Processamento"*/
			/*"Tempo de processamento"*/
			oProcess:SetDetProgress(STR0037,TimeInicio,; 
				STR0038,"" ,;	
				STR0039,"" ,; 
				"","")		
EndIF	

SM0->(RestArea(aAreaSM0))

//--------------------------
//Início do laçp das Filiais  
//--------------------------
aAreaSM0 := SM0->(GetArea())

//-----------------------------------------
//Primeiro Bloco de Processamento:
//- Inicialização das tabelas.
//- Processamento das saídas/receitas.
//-----------------------------------------	
For nContFil := 1 to Len(aSM0)

	IF lMain .And. ValType(oProcess)=="O"
		oProcess:Set2Progress(33)
	EndIF

	SM0->(DbGoTop ())
	SM0->(MsSeek (aSM0[nContFil][1]+aSM0[nContFil][2], .T.))	//Pego a filial mais proxima
	cFilAnt := FWGETCODFILIAL
		
	//--------------------------
	//Tratamento de SCP. Caso MV_PAR18 estiver preenchido como 03/04 então deverá processar somente sócia ostenciva
	//e desconsiderar sócia participante no processamento da apuração.
	//--------------------------
	IF mv_par18 $ '03/04' .AND. GetNewPar("MV_FILSCP",.F.)	//Sócia ostenciva
		//Aqui somente deverão ser gerados sócia ostenciva, ou seja, somente filial com parâmetro MV_FILSCP igual a .F.
		loop
	EndIF

    //Chama funcao para limpar a tabela CKX antes de popular caso exista o campo CKX_FILAPU
    If CKX->(FieldPos("CKX_FILAPU")) > 0
        ISA001CKX(aParSX1[1],aParSX1[2])
    EndIf
    
	//Se for apuração individualizada, então irá atualizar array com o xFilial, para 
	//que as informações sejam gravadas de maneira consolidada na matriz. 
	IF lindividu
		aXFilial:= ASA001AFIL()
		
		//Somente irá inicializar todas as tabelas se apuração for individualizada.
		//Se for consolidada a inicialização não será efetuada aqui.
		//Zera os créditos 
		IniCred(aParSX1,aXFilial)
		//Zera as deduções
		IniDeducao(aParSX1,aXFilial)
		//Zera as retenções
		IniRetenca(aParSX1,aXFilial)
		//Zera as tabelas da apuração
		IniTabApur (aParSX1,aXFilial,.T.,Len(aReprocess) > 0) //Limpa as tabelas de apuração e também as auxiliares		

		If Len(aReprocess) >0
			If lMain .And. ValType(oProcess)=="O"
				oProcess:Inc2Progress('Reprocessando apuração')
				oProcess:Inc2Progress('Reprocessando apuração')			
				If oProcess:Cancel()
					lCancel:=.T.
						Exit
				EndIf
			EndIF
			//Aqui chama as funções para realizar o reprocessamento
			ISA001CLA(aParSX1[1],aParSX1[2],,'2',aXFilial)
			ReprocEFD(aParSX1[1],aParSX1[2],'2',aReprocess,aXFilial)
		EndIF
		
	EndIF
	
	If lMain .And. ValType(oProcess)=="O"
		oProcess:Inc1Progress(STR0040 +FWGETCODFILIAL)//"Processando Filial"				
		If oProcess:Cancel()
			lCancel:=.T.
				Exit
		EndIf		
	EndIF

	//----------------------------------------------------
	//INICIA CLASSE DA APURAÇÃO E LIMPA TABELAS DO PERÍODO
	//---------------------------------------------------- 
	oApurSai := FISX001():New()
	oApurSai:SetDtIni(aParSX1[1])
	oApurSai:SetDtFin(aParSX1[2])
	oApurSai:SetLivro(aParSX1[3])
	oApurSai:SetRegApur(Str(aParSX1[6],1))
	oApurSai:SetFilial(aXFilial)
	oApurSai:SetPrcCPRB(lCPRB)
	
	nTotF100		:= 0
	nBsConsorc		:= 0
	
	//Se for consolidado, irá então inicializar/zerar as tabelas auxiliares
	If !lindividu //Consolidado
		oApurSai:ClearTab(TabAux())
	EndIF	
	
	IF !Empty(cRegime) .AND. cRegime <> '3' .AND. !lBlocI
		
		//---------------------------------------------------------------------------
		//IRÁ PROCESSAR AS OPERAÇÕES DOS DOCUMENTOS DE SAÍDA GRAVADOS NO LIVRO FISCAL
		//---------------------------------------------------------------------------

 		If lMain .And. ValType(oProcess)=="O"
	 		oProcess:Inc2Progress(STR0103,STR0043)//'Processando Notas Fiscais de Saída'			
			If oProcess:Cancel()
				lCancel:=.T.
					Exit
			EndIf
		EnDIF
				
		IF lPFisSai
			ProcLogAtu("MENSAGEM","Início do processamento Documento saídas - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001SFTSai(aParSX1[1], aParSX1[2], oApurSai, Iif(aParSX1[6] == 4, nMVM996TPR, 0), aParSX1[6], lCPRBNF, cSPCBPSE,IIf(valtype(MV_PAR20)=="N",MV_PAR20,2),aXFilial,cFilialMat,lindividu)  
			ProcLogAtu("MENSAGEM","Fim do processamento Documento saídas - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)			
		EndIF	

		If lTelSemLiv .AND. lPFisSai

	 		If lMain .And. ValType(oProcess)=="O"
		 		oProcess:Inc2Progress(STR0103,STR0044)//'Processando Notas Fiscais Telecomunicação'			
				If oProcess:Cancel()
					lCancel:=.T.
						Exit
				EndIf
			EndIf
			ProcLogAtu("MENSAGEM","Início do processamento Operações telecomunicações - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001TELECO(aParSX1[1], aParSX1[2], oApurSai,cRegime,nMVM996TPR,aParSX1[6])
			ProcLogAtu("MENSAGEM","Fim do processamento Operações telecomunicações - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)				
			
		EndIF
	
		If lVendaFora .AND. lPFisSai

	 		If lMain .And. ValType(oProcess)=="O"
		 		oProcess:Inc2Progress(STR0103,STR0045)//'Processando Vendas fora do Estabelecimento'			
				If oProcess:Cancel()
					lCancel:=.T.
						Exit
				EndIf
			EndIF
			ProcLogAtu("MENSAGEM","Início processamento Vendas Fora do Estabelecimento - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001VFORA(aParSX1[1],aParSX1[2],oApurSai,cRegime,nMVM996TPR,aParSX1[6])
			ProcLogAtu("MENSAGEM","Fim processamento Vendas Fora do Estabelecimento - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)				
			
		EndIF
	EndIF

	//---------------------------------------------------------------------------
	//PROCESSA CUPOM FISCAL COM CÁLCULO DE PIS E COFINS
	//---------------------------------------------------------------------------
	If lCupom .AND. lPCupom  	
	
		If lMain .And. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0046)//'Processando Cupom Fiscal'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF
		ProcLogAtu("MENSAGEM","Início processamento Cupom Fiscal - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001CUPOM(aParSX1[1],aParSX1[2],oApurSai,cRegime,aParSX1[3],aParSX1[6],nMVM996TPR)
		ProcLogAtu("MENSAGEM","Fim processamento Cupom Fiscal - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
		
	EndIF	

	If !Empty(cRegime) .AND. cRegime <> '3' .AND. !lBlocI
	
		If lMain .And. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0049)//'Processando Demais Documentos'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF
		ProcLogAtu("MENSAGEM","Início processamento Demais Documentos - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001CF8(aParSX1[1], aParSX1[2],	oApurEnt,	oApurSai,lProcCred,@nTotF100,lPTitEnt,lPTitSai,aParSX1[6],"1",@nBsConsorc,lCPRBNF)
		ProcLogAtu("MENSAGEM","Fim processamento Demais Documentos - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
				
	EndIF

	//Chama neste ponto o processamento dos títulos sem vínculo com documento fiscal?
	If lMain
		ProcLogAtu("MENSAGEM","Início pesquisa Títulos Financeiros - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		aF100:= FinSpdF100(Month(aParSX1[1]),Year(aParSX1[2]),,,,"F100")
		ProcLogAtu("MENSAGEM","Início pesquisa Títulos Financeiros - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
	EndIF
		
	If !EmptY(cRegime) .AND. cRegime <> '3'  .AND. !lBlocI
		//----------------------------------------------------------
		//BUSCA INFORMAÇÕES DO FINANCEIRO REFERENTE AO REGISTRO F100
		//----------------------------------------------------------
	
		If lMain
			If ValType(oProcess)=="O"
				oProcess:Inc2Progress(STR0103,STR0048)//'Processando Títulos sem documento Fiscal'			
				If oProcess:Cancel()
					lCancel:=.T.
					Exit
				EndIf
			EndIf
			ProcLogAtu("MENSAGEM","Início processamento Títulos Financeiros - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001F100Fi(aParSX1[1], aParSX1[2],	oApurEnt,	oApurSai,lProcCred,@nTotF100,lPTitEnt, lPTitSai,aParSX1[6],"1",aF100,lCPRBNF)
			ProcLogAtu("MENSAGEM","Fim processamento Títulos Financeiros - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		EndIF		
		
	EndIF
	

	If lPisSal .and. lPOutros .AND. !lBlocI
		//--------------------------------------------------
		//PROCESSA VALORES REFERENTE AO PIS FOLHA DE SALÁRIO
		//--------------------------------------------------
	
		If lMain .And. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0056)//'Processando Pis Sobre Folha de Salário '			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF
		ProcLogAtu("MENSAGEM","Início processamento PIS Folha - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001FOLHA(aParSX1[1],aParSX1[2],oApurSai)
		ProcLogAtu("MENSAGEM","Fim processamento PIS Folha - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
		
	EndIF
	
	//--------------------------
	//FINALIZA OBJETO DE SAÍDA
	//--------------------------	
	oApurSai:Finaliza('1')
		
Next nContFil

//--------------------------------------------------------
//Segundo Bloco de Processamento:
//- Processamento dos creditos, ajustes, deducoes, etc...
//--------------------------------------------------------	
For nContFil := 1 to Len(aSM0)

	IF lMain .And. ValType(oProcess)=="O"
		oProcess:Set2Progress(33)
	EndIF

	SM0->(DbGoTop ())
	SM0->(MsSeek (aSM0[nContFil][1]+aSM0[nContFil][2], .T.))	//Pego a filial mais proxima
	cFilAnt := FWGETCODFILIAL
		
	//--------------------------------------------------------------------------------------------------------------
	//Tratamento de SCP. Caso MV_PAR18 estiver preenchido como 03/04 então deverá processar somente sócia ostenciva
	//e desconsiderar sócia participante no processamento da apuração.
	//--------------------------------------------------------------------------------------------------------------
	IF mv_par18 $ '03/04' .AND. GetNewPar("MV_FILSCP",.F.)	//Sócia ostenciva
		//Aqui somente deverão ser gerados sócia ostenciva, ou seja, somente filial com parâmetro MV_FILSCP igual a .F.
		Loop
	EndIF
	
	//-----------------------------------------------------------------
	//Se for apuracao individualizada refaço a carga das filiais pois
	//o conteudo do array aXFilial sera o da ultima filial processada
	//no bloco 1. 
	//-----------------------------------------------------------------
	If lIndividu
		aXFilial:= ASA001AFIL()
	EndIf
	
	If lMain .And. ValType(oProcess)=="O"
		oProcess:Inc1Progress(STR0040 +FWGETCODFILIAL)//"Processando Filial"				
		If oProcess:Cancel()
			lCancel:=.T.
			Exit
		EndIf		
	EndIF
	
	//--------------------------------------------
	//INICIALIZA CLASSE PARA APURAÇÃO DOS CRÉDITOS
	//--------------------------------------------
	oApurEnt := FISX001():New()
	oApurEnt:SetFilial(aXFilial)
	oApurEnt:SetDtIni(aParSX1[1])
	oApurEnt:SetDtFin(aParSX1[2])
	oApurEnt:SetLivro(aParSX1[3])
	oApurEnt:SetRegApur(Str(aParSX1[6],1))	
	
	mvAlqCprb	:= GetNewPar('MV_CPRBALQ','')
	cCodAtiviv 	:= Substr(mvAlqCprb,1,  At("/",mvAlqCprb)-1  )
	nAlqCprb 	:= val( Substr(mvAlqCprb,At("/",mvAlqCprb)+1,  len(mvAlqCprb)  ))
		
	//Aqui será efetuado a dedução da CPRB, referente a parcela de receitas de consórcios cadastrados na rotina demais documentos
	IF lCPRB .AND. !empty(cCodAtiviv) .AND. nBsConsorc >0 .AND. nAlqCprb > 0
		
		oCPRB	:= CPRBEFD():New()
		oCPRB:SetDtIni(aParSX1[1])
			
		oCPRB:DeduzBase(cCodAtiviv,nAlqCprb,nBsConsorc)
		FreeObj(oCPRB)
		oCPRB:= nil
		
	EndIF

	oApurEnt:LoadRecBru()
		
	IF lProcCred
	
		//-----------------------------------------------------------------------------------
		//PROCESSA VALORES DE PIS E COFINS DOS DOCUMENTOS DE ENTRADA GRAVADOS NO LIVRO FISCAL
		//-----------------------------------------------------------------------------------
			
		If lMain .And. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0047)//'Processando Documentos de Entrada'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF
	
		IF lPFisEnt
			ProcLogAtu("MENSAGEM","Início processamento Documentos de Entrada - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001SFTEnt(aParSX1[1], aParSX1[1],	oApurEnt)
			ProcLogAtu("MENSAGEM","Fim processamento Documentos de Entrada - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		EndIF		
		
	EndIF
	
	//Chama neste ponto o processamento dos títulos sem vínculo com documento fiscal.
	If lMain
		ProcLogAtu("MENSAGEM","Início pesquisa Títulos Financeiros - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		aF100:= FinSpdF100(Month(aParSX1[1]),Year(aParSX1[2]),,,,"F100")
		ProcLogAtu("MENSAGEM","Início pesquisa Títulos Financeiros - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
	EndIF	
	
	If !EmptY(cRegime) .AND. cRegime <> '3' .AND. !lBlocI
	
		//----------------------------------------------------------
		//BUSCA INFORMAÇÕES DO FINANCEIRO REFERENTE AO REGISTRO F100
		//----------------------------------------------------------
			
		If lMain
			
			If ValType(oProcess)=="O"			
				oProcess:Inc2Progress(STR0103,STR0048)//'Processando Títulos sem documento Fiscal'			
				If oProcess:Cancel()
					lCancel:=.T.
					Exit
				EndIf			
			EndIF
			
			ProcLogAtu("MENSAGEM","Início processamento Títulos Financeiros - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001F100Fi(aParSX1[1], aParSX1[2],	oApurEnt,	oApurSai,lProcCred,@nTotF100,lPTitEnt, lPTitSai,aParSX1[6],"2",aF100,lCPRBNF)
			ProcLogAtu("MENSAGEM","Fim processamento Títulos Financeiros - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			
		EndIF		
		
	EndIF
	
	//--------------------------------------------------------
	//PROCESSA VALORES DOS CRÉDITOS E DÉBITOS DE PIS E COFINS 
	//GRAVADOS NA TABELA CF8 - DEMAIS DOCUMENTOS
	//--------------------------------------------------------	
	
	If !Empty(cRegime) .AND. cRegime <> '3' .AND. !lBlocI
	
		If lMain .And. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0049)//'Processando Demais Documentos'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF
		
		ProcLogAtu("MENSAGEM","Início processamento Demais Documentos - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001CF8(aParSX1[1], aParSX1[2],	oApurEnt,	oApurSai,lProcCred,@nTotF100,lPTitEnt,lPTitSai,aParSX1[6],"2",@nBsConsorc,lCPRBNF)
		ProcLogAtu("MENSAGEM","Fim processamento Demais Documentos - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
				
	EndIF	
	
	IF lProcCred .AND. !lBlocI
	
		//------------------------------------------------------------------
		//PROCESSA OPERAÇÕES DE ABERTRA DE ESTOQUE COM DIREITO AO CRÉDITO  
		//------------------------------------------------------------------
	
		If lMain
		
			If ValType(oProcess)=="O"
				oProcess:Inc2Progress(STR0103,STR0050)//'Processando Estoque de Abertura'			
				If oProcess:Cancel()
					lCancel:=.T.
					Exit
				EndIf
			EndIF
					
			If lPOutros
				ProcLogAtu("MENSAGEM","Início processamento Estoque de Abertura - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
				A001AbeEst(aParSX1[1],oApurEnt)
				ProcLogAtu("MENSAGEM","Fim processamento Estoque de Abertura - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
			EndIF
			
		EndIF
			
		//-------------------------------------------------------------------------
		//PROCESSA VALORES DOS CRÉDITOS DE PIS E COFINS DE ATIVO FIXO - DEPRECIAÇÃO
		//-------------------------------------------------------------------------
	
		If lMain .And. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0051)//'Processando Bens por Depreciação'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF
		
		If lPATF .AND. lMain
			ProcLogAtu("MENSAGEM","Início processamento Bem Depreciação - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001F120(firstday(aParSX1[1]), LastDay(aParSX1[2]),	oApurEnt)
			ProcLogAtu("MENSAGEM","Fim processamento Bem Depreciação - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		EndIF
		
		//-----------------------------------------------------------------------
		//PROCESSA VALORES DOS CRÉDITOS DE PIS E COFINS DE ATIVO FIXO - AQUISIÇÃO
		//-----------------------------------------------------------------------
	
		If lMain .And. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0052)//'Processando bens por aquisição'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF
		
		If lPATF .and. lMain
			ProcLogAtu("MENSAGEM","Início processamento Bem Aquisição - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001F130(firstday(aParSX1[1]), LastDay(aParSX1[2]),	oApurEnt)
			ProcLogAtu("MENSAGEM","Início processamento Bem Aquisição - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		EndIF		
		
	EndIF
	
	//------------------------------------------------------------------------
	//PROCESSA VALORES DO PIS E COFINS COM ORIGEM DO PONTO DE ENTRADA SPDPIS09 
	//------------------------------------------------------------------------
	If ExistBlock("SPDPIS09") 
	
		If lMain .And. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0053)//'Processando Ponto de Entrada SPDPIS09 '			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF
		
		ProcLogAtu("MENSAGEM","Início processamento SPDPIS09 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001PEF100(aParSX1[1],aParSX1[2],oApurSai,oApurEnt,lProcCred,lPTitEnt, lPTitSai,aParSX1[6],lCPRBNF)
		ProcLogAtu("MENSAGEM","Fim processamento SPDPIS09 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
		
	EndIF
	
	//------------------------------------------------------------------------
	//PROCESSA VALORES DE DÉBITOS DE PIS E COFINS DO PONTO DE ENTRADA SPDPisTr  
	//------------------------------------------------------------------------
	If ExistBlock("SPDPisTr") .and. lPOutros
	
		If lMain .And. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0054)//'Processando Ponto de Entrada SPDPisTr '			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF
		
		ProcLogAtu("MENSAGEM","Início processamento SPDPisTr - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001PISSTR(aParSX1[1],aParSX1[2],oApurSai,aParSX1[6])
		ProcLogAtu("MENSAGEM","Fim processamento SPDPisTr - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
			
	EndIF
	
	If ExistBlock("SPDPCIMOB") .and. lPOutros
	
		If lMain .And. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0055)//'Processando Ponto de Entrada SPDPCIMOB '
						
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EnDIF
		
		ProcLogAtu("MENSAGEM","Início processamento SPDPCIMOB - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001IMOB(aParSX1[1],aParSX1[2],oApurSai,oApurEnt,lProcCred,aParSX1[6])
		ProcLogAtu("MENSAGEM","Fim processamento SPDPCIMOB - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
		
	EndIF
	
	//--------------------------------------------------
	//PROCESSA VALORES REFERENTE CRÉDITO PRESUMIDO
	//--------------------------------------------------
	If lCredPAgro .And. cRegime <> '3' 
		ProcLogAtu("MENSAGEM","Início processamento crédito presumido conforme lei 12.058/2009 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		F100Presu(aParSX1[1],aParSX1[2],aParSX1[3],oApurEnt,nTotF100)			
		ProcLogAtu("MENSAGEM","Fim processamento crédito presumido conforme lei 12.058/2009 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
    EndIf	
	
	IF lMain .And. ValType(oProcess)=="O"
		oProcess:Inc2Progress(STR0103,STR0057)//'Finalizando operações de entradas e saídas'			
		If oProcess:Cancel()
			lCancel:=.T.
			Exit
		EndIf
	EndIF

	//FreeObj(oApurSai)
	//oApurSai:= nil
	//--------------------------
	//FINALIZA OBJETO DE ENTRADA
	//--------------------------
	oApurEnt:Finaliza('2')
	//FreeObj(oApurent)
	//oApurent:= nil
	
	//Faz os estornos das devoluções do próprio período
	
	IF lMain .And. ValType(oProcess)=="O"
		oProcess:Inc2Progress(STR0103,STR0058 )//'Devoluções de venda período atual'			
		If oProcess:Cancel()
			lCancel:=.T.
			Exit
		EndIf
	EndIF	

	IF lPFisEnt .AND. !lBlocI
		ProcLogAtu("MENSAGEM","Início processamento Devolução Venda período atual - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		ASA001Devo(aParSX1[1], aParSX1[2],aParSX1[3],'S',nMVM996TPR,cRegime,.T.,aXFilial,FISCALENT,lCPRBNF,cSPCBPSE) //Devolução de Venda
		ProcLogAtu("MENSAGEM","Fim processamento Devolução Venda período atual - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
	EndIF
			
	IF lMain .And. ValType(oProcess)=="O"
		oProcess:Inc2Progress(STR0103,STR0059)//'Devoluções de compra período atual'			
		If oProcess:Cancel()
			lCancel:=.T.
			Exit
		EndIf
	EndIF		

	IF lPFisSai .AND. !lBlocI
		ProcLogAtu("MENSAGEM","Início processamento Devolução Compra período atual - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		ASA001Devo(aParSX1[1], aParSX1[2],aParSX1[3],'E',nMVM996TPR,cRegime,.T.,aXFilial,FISCALSAI,lCPRBNF,cSPCBPSE) //Devolução de COmpra
		ProcLogAtu("MENSAGEM","Fim processamento Devolução Compra período atual - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)	
	EndIF
		
	IF lMain .And. ValType(oProcess)=="O"
		oProcess:Inc2Progress(STR0103,STR0060)//'Ajustes de créditos manuais'			
		If oProcess:Cancel()
			lCancel:=.T.
			Exit
		EndIf
	EndIf	
	
	IF lProcCred .AND. !lBlocI .AND. aParSX1[15] == 2
		//-------------------------------------------
		//PROCESSA VALORES DE AJUSTES DE PIS E COFINS
		//-------------------------------------------	
		oAjustes 	:= AJUSTEEFD():New()
		oAjustes:SetFilial(aXFilial)
		oAjustes:SetDtIni(aParSX1[1])
		oAjustes:SetDtRefer(aParSX1[1])
		oAjustes:LoadCL8()
		ProcLogAtu("MENSAGEM","Início processamento Ajustes CF5 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001AjuCF5(aParSX1[1],aParSX1[2],oAjustes)
		ProcLogAtu("MENSAGEM","Fim processamento Ajustes CF5 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		FreeObj(oAjustes)
		oAjustes:= NIL
	EndIF		
	
	//-------------------------------------------------------------------------------
	//PROCESSA VALORES DE DIFERIMENTO DE PIS E COFINS
	//-------------------------------------------------------------------------------
	IF lDifer .and. lMain .AND. !lBlocI
		
		If ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0061)//'Processando diferimento de PIS e COFINS'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf	
		EndIf
		
		
		If ISA001NDIF() //Se habilitou parâmetro para processar o diferimento dentro da própria apuração.				 
			
			//Deverá processar a gravação da CFA e CFB		
			cCmpB1Dif	:=	GetNewPar("MV_B1M996","")
			cCmpA1Dif	:=	GetNewPar("MV_A1M996","")
			cPrefixE1	:=	GetNewPar("MV_1DUPREF","SF2->F2_SERIE")
			aParFiltr	:=	{mv_par01,mv_par02,cCmpB1Dif,cCmpA1Dif,cPrefixE1}
			cPerApur	:=	Substr(DTOS(mv_par01),5,2)+Substr(DTOS(mv_par01),1,4)
			
			ObjF0T		:= TABELAF0T():New()
			//Executa filtro e chama funcao que ira gravar as Informacoes de Diferimento
			If FSA001QRYD(1,"SE1",@cAliasDIF,aParFiltr) //Chama função para realizar query de diferimento dos títulos
			
				FSA001PRCD(mv_par01,mv_par02,cPerApur,mv_par03,cAliasDIF,;			
							cRegime,,,,,;
							,,cPrefixE1,cCmpB1Dif,cCmpA1Dif,;
							"SE1",.F.,mv_par18,ObjF0T,.F.,aXFilial)
				
			Endif
			
			//Fecha query
			FSA001QRYD(2,,cAliasDIF)
			
			//Mata objeto
			FreeObj(ObjF0T)
			ObjF0T	:= Nil
			
			ObjF0T		:= TABELAF0T():New()
			//Executa filtro e chama funcao que ira gravar as Informacoes de Diferimento
			If FSA001QRYD(1,"CF8",@cAliasDIF,aParFiltr) //Chama função para realizar query de diferimento dos demais documentos
				//
				FSA001PRCD(mv_par01,mv_par02,cPerApur,mv_par03,cAliasDIF,;			
							cRegime,,,,,;
							,,cPrefixE1,cCmpB1Dif,cCmpA1Dif,;
							"CF8",.F.,mv_par18,ObjF0T,.F.,aXFilial)
				
			Endif
			
			//Fecha alias
			FSA001QRYD(2,,cAliasDIF)
			
			//Mata objeto
			FreeObj(ObjF0T)
			ObjF0T	:= Nil
			
			IF lindividu
				
				ProcLogAtu("MENSAGEM","Início processamento Diferimento PIS COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
				A001Difer(mv_par01,mv_par02,aXFilial)
				ProcLogAtu("MENSAGEM","Fim processamento Diferimento PIS COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
				
			EndIF
			
		
		Else
			//Mantem processamento legado, ou seja, ainda o processamento realizado pela FISA054.
			ProcLogAtu("MENSAGEM","Início processamento Diferimento PIS COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001Difer(mv_par01,mv_par02,aXFilial)
			ProcLogAtu("MENSAGEM","Fim processamento Diferimento PIS COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
		EndIF				
	
				
	
	EndIF

	//-------------------------------------------------------------------------------
	//PARA PROCESSAR ESTAS INFORMAÇÕES SERÁ NECESSÁRIO REALIZAR APURAÇÃO ANTES
	//-------------------------------------------------------------------------------
	
	IF lMain .and. ValType(oProcess)=="O"
		oProcess:Inc2Progress(STR0103,STR0063)//'Atualizando apuração'			
		If oProcess:Cancel()
			lCancel:=.T.
			Exit
		EndIf
	EndIF		
	
	//ATÉ AQUI SÃO OPERAÇÕES SEM CONCORRÊNCIA
	//A PARTIR DESTE PONTO A THREAD PRINCIPAL IRÁ FINALIZAR 	

	If lMain
		For nX := 1 to Len(aThread)			

			If ValType(oProcess)=="O"
				oProcess:Set2Progress(100)
				nContThr	:= 0
				oProcess:Inc1Progress('Finalizando a Thread '+ aThread[nX][1],)//'Apuração Finalizada com Sucesso'
			EndIf			
			While .T.				
				IF nContThr == 100
					If ValType(oProcess)=="O"
						oProcess:Set2Progress(100)
						nContThr	:= 0	
					EndIF
				EndIF				
				IF GetGlbValue( aThread[nX][1] ) == '0' 				
					If ValType(oProcess)=="O"
						//conout('Thread ' + aThread[nX][1] + ' ainda processando')
						oProcess:Inc2Progress('Processando...','')//'Apuração Finalizada com Sucesso'
					EndIf								
				ElseIF GetGlbValue( aThread[nX][1] ) == '1'
					ProcLogAtu("MENSAGEM","Thread " + aThread[nX][1]  + " Finalizada com Sucesso! " + Time(),,cNomeJob)
					Exit
				ElseIF GetGlbValue( aThread[nX][1] ) == '2'
					ProcLogAtu("ERRO","Ocorreu erro na Thread " + aThread[nX][1] +" "   + Time(),,cNomeJob)
					lErro	:= .T.
					Exit
				EndIF
				nContThr++
				Sleep(500)
			EndDo
		
		Next nX
	
			//Consolidação das Threads
		IF  Len(aThread) > 0		
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CKZ')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CKS')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CL8')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CL9')			
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CLA')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CKR')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CKT')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CKU')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CL0')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CL3')									
		EndIf
		
		aParSX1[1]	:= MV_PAR01
		aParSX1[2]	:= MV_PAR02
		
	EndIF

	//-----------------------------
	//PROCESSA OPERAÇÕES DO BLOCO I
	//-----------------------------
	If lBlocI .AND. lMain
	
		If ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0041)//'Processando','Processando Operações de Instituições Financeiras'			
			If oProcess:Cancel()
				lCancel:=.T.
					Exit
			EndIf
		EndIF
			
		ProcLogAtu("MENSAGEM","Início do processamento Instituição Financeira - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001BlocoI(mv_par01,mv_par02,oApurSai,aXFilial,cFilialMat)
		ProcLogAtu("MENSAGEM","Fim do processamento Instituição Financeira - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
	
	EndIF


	IF cRegime == '3' .AND. !lBlocI
		
 		If lMain
 		
	 		If ValType(oProcess)=="O"
		 		oProcess:Inc2Progress(STR0103,STR0042) //'Processando Regime de Caixa'			
				If oProcess:Cancel()
					lCancel:=.T.
					Exit
				EndIf	
 			EndIf
 			
			ProcLogAtu("MENSAGEM","In´cio do processamento Regime de Caixa - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001CAIXA(aParSX1[1],aParSX1[2],oApurSai,aParSX1[3],aParSX1[12],aXFilial,lCPRBNF,cSPCBPSE,cFilialMat,lindividu)
			ProcLogAtu("MENSAGEM","Fim do processamento Regime de Caixa - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			
		EndIF			
		
	EndIF

	If lMain
			
		oApurPIS	:= APURPISCOF():New()	
		oApurPIS:SetRegime(aParSX1[6])
		oApurPIS:SetFilial(aXFilial)
		//Passa data inicial
		oApurPIS:SetDtIni(aParSX1[1])
		//Apura o PIS do período
		oApurPIS:Apurar(PIS)
		
		IF cRegime == '4' .AND. Len(aThread) > 0
			oApurPIS:RatBrut(aXFilial)
		EndIF
		
		//Carrega as informações no objeto
		//oApurPIS:LoadApurPC(PIS)
		
		//------------------------------------
		// CRIA OBJETO DA COFINS PARA APURAÇÃO
		//------------------------------------
		//Cria objeto da apuração para a COFINS	
		
		oApurCof	:= APURPISCOF():New()	
		oApurCof:SetRegime(aParSX1[6])
		oApurCof:SetFilial(aXFilial)
		//Passa data inicial
		oApurCof:SetDtIni(aParSX1[1])
		//Apura o PIS do período
		oApurCof:Apurar(COFINS)		
	
		IF lMain .AND. !lBlocI
			
			If ValType(oProcess)=="O"
				oProcess:Inc2Progress(STR0103,STR0064)//'Processando Cancelamentos períodos anteriores'			
				If oProcess:Cancel()
					lCancel:=.T.
					Exit
				EndIf
			EndIF
		
			//---------------------------------------------------------------------------------
			//PROCESSA AS NOTAS CANCELADAS NO PERÍODO QUE FORAM EMITIDAS EM PERÍODOS ANTERIORES
			//---------------------------------------------------------------------------------
			ProcLogAtu("MENSAGEM","Início processamento Notas Canceladas período anterior - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			ASA001CANC(aParSX1[1], aParSX1[2],cRegime,aParSX1[3],aXFilial,aParSX1[6])
			ProcLogAtu("MENSAGEM","Fim processamento Notas Canceladas período anterior - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			
		EndIF	
		
		IF lMain .AND. !lBlocI .And. aParSX1[15] == 2
			//-------------------------------------------
			//PROCESSA VALORES DE AJUSTES DE PIS E COFINS
			//-------------------------------------------	
			oAjustes 	:= AJUSTEEFD():New()
			oAjustes:SetFilial(aXFilial)
			oAjustes:SetDtIni(aParSX1[1])
			oAjustes:SetDtRefer(aParSX1[1])
			oAjustes:LoadCKS()
			ProcLogAtu("MENSAGEM","Início processamento Ajustes de Débito CF5 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001AjuCF5(aParSX1[1],aParSX1[2],oAjustes,.T.)
			ProcLogAtu("MENSAGEM","Fim processamento Ajustes de Débito CF5 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			FreeObj(oAjustes)
			oAjustes:= NIL
		EndIF	
		IF lMain .and. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0065)//'Processando devoluççoes de venda período anterior'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF		
			
		IF lPFisEnt .AND. !lBlocI
			//---------------------------------------------------
			//PROCESSA AS DEVOLUÇÕES DE VENDA DE PERÍODO ANTERIOR 
			//---------------------------------------------------
			ProcLogAtu("MENSAGEM","Início processamento Devoluções de Venda período anterior  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			ASA001Devo(aParSX1[1], aParSX1[2],aParSX1[3],'S',nMVM996TPR,cRegime,.F.,aXFilial,FISCALENT,lCPRBNF,cSPCBPSE) //Devolução de Venda
			ProcLogAtu("MENSAGEM","Fim processamento Devoluções de Venda período anterior  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		EndIF	
		
		IF lMain .and. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0066)//'Processando devoluççoes de compra período anterior'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF		
	
		IF lPFisSai .AND. !lBlocI
			//---------------------------------------------------
			//PROCESSA AS DEVOLUÇÕES DE COMPRA DE PERÍODO ANTERIOR 
			//---------------------------------------------------
			ProcLogAtu("MENSAGEM","Início processamento Devoluções de Compra período anterior  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			ASA001Devo(aParSX1[1], aParSX1[2],aParSX1[3],'E',nMVM996TPR,cRegime,.F.,aXFilial,FISCALSAI,lCPRBNF,cSPCBPSE) //Devolução de COmpra
			ProcLogAtu("MENSAGEM","Início processamento Devoluções de Compra período anterior  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)	
		EndIF

		If  EmpTy(alltrim(GetNewPar('MV_CPRBALQ',''))) .AND. lCPRB .AND. lPCPRB .AND. lMain 
			//------------------------
			//PROCESSA VALORES DA CPRB
			//------------------------	
			If ValType(oProcess)=="O"
				oProcess:Inc2Progress(STR0103,STR0071)//'Buscando Informações da CPRB'	
				oProcess:Inc2Progress('Processando Informações da CPRB',STR0072)//'Processando Informações da CPRB'
				oProcess:Inc2Progress(STR0103,STR0071)//'Buscando Informações da CPRB'	
				oProcess:Inc2Progress('Processando Informações da CPRB',STR0072)//'Processando Informações da CPRB'			
				If oProcess:Cancel()
					lCancel:=.T.
					Exit
				EndIf
			EndIf
			If !lCPRBNF
				ProcLogAtu("MENSAGEM","Início Processamento da CPRB  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
				A001CPRB(aParSX1[1],aParSX1[2],aXFilial,nTotF100,cFilialMat,lindividu)
 				ProcLogAtu("MENSAGEM","Fim Processamento da CPRB  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			Endif		
		EndIF
		
		IF lMain .and. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0073)//'Encerrando processamento da filial'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF	
		
		IF lProcCred .AND. aParSX1[15] == 2 //Se for geração individualizada, então deverá processar para cada filial.
			//---------------------------------------------------------------------------------
			//APÓS TODOS AJUSTES/REDUÇÃO/DIFERIMENTO DOS CRÉDITOS E DÉBITOS, PROCESSAR CRÉDITOS
			//---------------------------------------------------------------------------------
			ProcLogAtu("MENSAGEM","Início Apuração de PIS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			IF lMain .and. ValType(oProcess)=="O"
				oProcess:Inc2Progress(STR0103,STR0069)//'Finalizando apuração de PIS'			
				If oProcess:Cancel()
					lCancel:=.T.
					Exit
				EndIf
			EndIF
		
			oCompCred	:= CMPCREDITO():New()	
			oCompCred:SetFilial(aXFilial)
			oCompCred:SetDtIni(aParSX1[1])
			oCompCred:DedCred('1')	
			ProcLogAtu("MENSAGEM","Fim Apuração de PIS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		
			ProcLogAtu("MENSAGEM","Início Apuração de COFINS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			IF lMain .and. ValType(oProcess)=="O"
				oProcess:Inc2Progress(STR0103,STR0070)//'Finalizando apuração de COFINS'			
				If oProcess:Cancel()
					lCancel:=.T.
					Exit
				EndIf
			EndIF
			oCompCred	:= CMPCREDITO():New()	
			oCompCred:SetFilial(aXFilial)
			oCompCred:SetDtIni(aParSX1[1])
			oCompCred:DedCred('2')
			ProcLogAtu("MENSAGEM","Fim Apuração de COFINS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)	
		EndIF
		
		IF aParSX1[15] == 2 
		//Indic aqui se deverá buscar valores de créditos para próimo período
			oApurPIS:setPCrdFut(lProcCred)
			oApurCof:setPCrdFut(lProcCred)
			
			//Carrega as informações atualizadas da apuração
			oApurPIS:LoadApurPC(PIS)
			
			//Carrega as informações atualizadas da apuração
			oApurCof:LoadApurPC(COFINS)
		EndIF
		
		//-------------------------------------------------------------------------------
		//PROCESSA VALORES DE RETENÇÃO NA FONTE DE PIS E DA COFINS                     
		//-------------------------------------------------------------------------------
		IF lMain .And. IIf(!Empty(mv_par19), mv_par19 == 1, .T.)
			If ValType(oProcess)=="O"
				oProcess:Inc2Progress(STR0103,STR0067)//'Processando Retenções na fonte de PIS e COFINS'			
				If oProcess:Cancel()
					lCancel:=.T.
					Exit
				EndIf
			EndIf
			//-----------------------------------------
			//PROCESSA OS VALORES DE RETENÇÃO NA FONTE. 
			//-----------------------------------------
			ProcLogAtu("MENSAGEM","Início processamento Retenções na Fonte PIS COFINS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001F600(aParSX1[1],oApurPis,oApurCof,aXFilial,cFilialMat,lIndividu)
			ProcLogAtu("MENSAGEM","Fim processamento Retenções na Fonte PIS COFINS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			
			FSA001CLG(aParSX1[1], aParSX1[2])
			
			IF aParSX1[15] == 2
				cCtlDedRet := "A" // Processa saldo e retenção
				DeduzReten(aParSX1[1],aParSX1[2],aXFilial,oApurPis,oApurCof,cCtlDedRet)
			EndIF
				
		EndIF
				
	EndIF

Next nContFil

//-------------------------------------------------
//FIM DO LAÇO DAS FILIAIS, RESTAURA A FILIAL LOGADA
//-------------------------------------------------
RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

If lMain


	//-------------------------------------------------------------------------------
	//PROCESSA VALORES DE DIFERIMENTO DE PIS E COFINS
	//-------------------------------------------------------------------------------
	IF ISA001NDIF() .AND. !lindividu .AND. lDifer .and. lMain .AND. !lBlocI  			
		
		ProcLogAtu("MENSAGEM","Início processamento Diferimento PIS COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001Difer(mv_par01,mv_par02,aXFilial)
		ProcLogAtu("MENSAGEM","Fim processamento Diferimento PIS COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
	
	EndIF

	IF lSocCoop .AND. lMain .AND. !lBlocI
		
		If ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0062)//'Processando Sociedade Cooperativa'			
		EndIF		
			
		//-------------------------------------------------------------------------------
		//PROCESSA AS INFORMAÇÕES DE SOCIEDADE COOPERATIVA GRAVADAS NA TABELA CE9 PARA 
		//REDUZIR A BASE DE CÁLCULO DA CONTRIBUIÇÃO                     
		//-------------------------------------------------------------------------------
		ProcLogAtu("MENSAGEM","Início processamento Sociedade Cooperativa - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		oDebito:= COMPDEBITO():New() 	//Cria Objeto da Classe COMPDEBITO
		oDebito:SetFilial(aXFilial)
		oDebito:SetDtIni(aParSX1[1])   	//Passa data de referência
		oDebito:AtuSocCoop('1') //atualiza os valores de sociedade cooeprativa para regime não cumulatico
		oDebito:AtuSocCoop('2') //atualiza os valores de sociedade cooeprativa para regime  cumulatico
		FreeObj(oDebito)
		oDebito:= NIL
		ProcLogAtu("MENSAGEM","Fim processamento Sociedade Cooperativa - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		

	EndIF			

	IF lMain .AND. !lBlocI .And. aParSX1[15] == 1
		//-------------------------------------------
		//PROCESSA VALORES DE AJUSTES DE PIS E COFINS
		//-------------------------------------------	
		oAjustes 	:= AJUSTEEFD():New()
		oAjustes:SetFilial(aXFilial)
		oAjustes:SetDtIni(aParSX1[1])
		oAjustes:SetDtRefer(aParSX1[1])
		oAjustes:LoadCKS()
		ProcLogAtu("MENSAGEM","Início processamento Ajustes de Débito CF5 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001AjuCF5(aParSX1[1],aParSX1[2],oAjustes,.T.)
		ProcLogAtu("MENSAGEM","Fim processamento Ajustes de Débito CF5 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		FreeObj(oAjustes)
		oAjustes:= NIL
	EndIF
	IF lProcCred .AND. aParSX1[15] == 1 //Se for geração de forma consolidada, então irá processar apuração somente uma vez.
		//---------------------------------------------------------------------------------
		//APÓS TODOS AJUSTES/REDUÇÃO/DIFERIMENTO DOS CRÉDITOS E DÉBITOS, PROCESSAR CRÉDITOS
		//---------------------------------------------------------------------------------
		IF lMain .and. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0074)//'Finalizando apuração de PIS'			
			If oProcess:Cancel()
				lCancel:=.T.
				return .F.
			EndIf
		EndIF
		
		IF lProcCred .AND. !lBlocI
		//-------------------------------------------
		//PROCESSA VALORES DE AJUSTES DE PIS E COFINS
		//-------------------------------------------	
		oAjustes 	:= AJUSTEEFD():New()
		oAjustes:SetFilial(aXFilial)
		oAjustes:SetDtIni(aParSX1[1])
		oAjustes:SetDtRefer(aParSX1[1])
		oAjustes:LoadCL8()
		ProcLogAtu("MENSAGEM","Início processamento Ajustes CF5 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001AjuCF5(aParSX1[1],aParSX1[2],oAjustes)
		ProcLogAtu("MENSAGEM","Fim processamento Ajustes CF5 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		FreeObj(oAjustes)
		oAjustes:= NIL
	EndIF
				
		ProcLogAtu("MENSAGEM","Início atualização valor de PIS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
	
		oCompCred	:= CMPCREDITO():New()	
		oCompCred:SetFilial(aXFilial)
		oCompCred:SetDtIni(aParSX1[1])
		oCompCred:DedCred('1')	
	
		ProcLogAtu("MENSAGEM","Fim atualização valor de PIS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		IF lMain .and. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0075)//'Processando' - 'Finalizando apuração de COFINS'			
			If oProcess:Cancel()
				lCancel:=.T.
				return .F.
			EndIf
		EndIF
		ProcLogAtu("MENSAGEM","Início atualização valor de PIS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		oCompCred	:= CMPCREDITO():New()	
		oCompCred:SetFilial(aXFilial)
		oCompCred:SetDtIni(aParSX1[1])
		oCompCred:DedCred('2')
		ProcLogAtu("MENSAGEM","Início atualização valor de PIS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		
		//Indic aqui se deverá buscar valores de créditos para próimo período
		oApurPIS:setPCrdFut(lProcCred)
		oApurCof:setPCrdFut(lProcCred)			
	
	EndIF

	IF !lCancel

	
		//Carrega as informações atualizadas da apuração
		oApurPIS:LoadApurPC(PIS)
		
		//Carrega as informações atualizadas da apuração
		oApurCof:LoadApurPC(COFINS)
		
		// Processa saldos
		IF aParSX1[15] <> 2	
			cCtlDedRet := "S" // S = Processa saldos
			DeduzReten(aParSX1[1],aParSX1[2],aXFilial,oApurPis,oApurCof,cCtlDedRet)	
		EndIF
			
		If lProcCred
			FreeObj(oCompCred)
			oCompCred:= Nil
		EndIF

	EndIF
	
	IF lMain 
		aAreaSM0 := SM0->(GetArea())
		
		If ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0068)//'Processando Outras Deduções'		
		EndIf
			
		For nContFil := 1 to Len(aSM0)

			SM0->(DbGoTop ())
			SM0->(MsSeek (aSM0[nContFil][1]+aSM0[nContFil][2], .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL					
					
			ProcLogAtu("MENSAGEM","Início processamento Outros Débitos PIS COFINS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001F700(aParSX1[1],str(aParSX1[6],1),oApurPIS,oApurCof,aXFilial)
			ProcLogAtu("MENSAGEM","Fim processamento Outros Débitos PIS COFINS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			
			// Processa retenções
			IF aParSX1[15] <> 2	
				cCtlDedRet := "R" // R = Processa rentenções
				DeduzReten(aParSX1[1],aParSX1[2],aXFilial,oApurPis,oApurCof,cCtlDedRet)	
			EndIF
			
		Next nContFil
		RestArea (aAreaSM0)
		cFilAnt := FWGETCODFILIAL
	EndIF
	
	IF !lCancel	
		FreeObj(oApurPIS)
		oApurPIS:= Nil
		FreeObj(oApurCOF)
		oApurCOF:= Nil
	EndIF
	
	//---------------------------
	//PROCESSA OS AJUSTES DA CPRB
	//---------------------------
	IF lCPRB .AND.  lPCPRB .AND. lMain
		ProcLogAtu("MENSAGEM","Início do Processamento dos Ajustes da CPRB  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)  
		AjusteCPRB(aParSX1[1],aParSX1[2],aSM0,cFilialMat,lindividu)
		ProcLogAtu("MENSAGEM","Fim do Processamento dos Ajustes da CPRB  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)	
	EndIF
	
	IF lMain .and. ValType(oProcess)=="O"
		oProcess:Set2Progress(1)	
		oProcess:Inc2Progress('Concluindo.','')//'Apuração Finalizada com Sucesso'
		oProcess:Set1Progress(Len(aThread)+1)
		oProcess:Inc1Progress('Finalizando as demais Threads iniciadas',)//Apuração Finalizada com Sucesso'
	EndIF
		
	IF lMain .and. ValType(oProcess)=="O"
		//Fim da consolidação das Threads
		oProcess:Set1Progress(1)
		oProcess:Inc1Progress(STR0076,)//'Apuração Finalizada com Sucesso'
		oProcess:Set2Progress(1)
		oProcess:Inc2Progress("","")
	EndIf
		
	IF lCancel .Or. lErro
		DisarmTransaction()
		Alert(Iif(lCancel,"Operação Cancelada!" ,"Verifique o Log de processamento, houveram erros no processamento de Thread." )  ) //'Apuração Finalizada com Sucesso'
	Else
		lProcessou	:= .T.
		TimeFim := Time()
		IF lMain .and. ValType(oProcess)=="O"
			oProcess:Set2Progress(1)
			/*"Inicio do processamento"*/
			/*"Fim do Processamento"*/
			/*"Tempo de processamento"*/
			oProcess:SetDetProgress(STR0037,TimeInicio,;
				STR0038,TimeFim ,;
				STR0039,ELAPTIME(TimeInicio,TimeFim) ,;
				"","")
		EndIF
		
		MsgInfo(Iif( lReprocess,"Apuração Processada com Sucesso",STR0077)) //'Apuração Finalizada com Sucesso' 
	
	EndIF
EndIF
	
Return lProcessou

//-------------------------------------------------------------------
/*/{Protheus.doc} A001AbeEst()
Função que irá buscar valores de abertura de estoque para gerar os créditos
de PIS e COFINS 

@param	dDataDe	- Data inicial do período de apuração
		oApurEnt	-Objeto já criado para apurar os valores dos créditos

@author Erick G. Dias
@since 14/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
 Static Function A001AbeEst(dDataDe,oApurEnt)
 
local cAliasCF9	:= ''
Local cSlctCF9	:= ''
Local cMesIng		:= ''
Local dDtIng		:= firstday(dDataDe)
Local nCont		:= 0
Local nQtdMesAnt	:= 12

For nCont := 1 to nQtdMesAnt
	dDtIng	:=firstday(dDtIng)-1
Next nCont
dDtIng	:=firstday(dDtIng)
cMesIng := month(dDtIng)

DbSelectArea ('CF9')

cSlctCF9 :='%'
cSlctCF9 += 'CF9.CF9_CODBCC,		CF9.CF9_PERING,	CF9.CF9_BASMES,	CF9.CF9_CSTPIS,'
cSlctCF9 += 'CF9.CF9_ALQPIS,		CF9.CF9_VALPIS,	CF9.CF9_CSTCOF,	CF9.CF9_ALQCOF,	CF9.CF9_VALCOF'
cSlctCF9 +='%'
   	
cAliasCF9	:=	GetNextAlias()
   	
BeginSql Alias cAliasCF9
	COLUMN CF9_PERING AS DATE
	SELECT			    
		%Exp:cSlctCF9%
	FROM 
		%Table:CF9% CF9
	WHERE
		CF9.CF9_FILIAL=%xFilial:CF9% AND
		CF9.CF9_PERING>%Exp:DToS (dDtIng)% AND
		CF9.%NotDel%	
EndSql

DbSelectArea (cAliasCF9)
(cAliasCF9)->(DbGoTop ())
Do While !(cAliasCF9)->(Eof ())	
 
	//------------------------------------------
	//Não considera o 13 mes.
	//------------------------------------------
 	If Month((cAliasCF9)->CF9_PERING) = cMesIng 
		(cAliasCF9)->(dbSkip())
		Loop
	Endif	

	oApurEnt:SetRegime(NAOCUMULAT) 
	oApurEnt:SetOrigem(OUTROS)			
	oApurEnt:SetReceita((cAliasCF9)->CF9_BASMES)
	oApurEnt:SetCodBcc((cAliasCF9)->CF9_CODBCC)
	oApurEnt:SetCFOP(	'')
	
	//---------------------
	//Informações de PIS
	//---------------------			
	oApurEnt:SetTributo(PIS)
	oApurEnt:SetCST((cAliasCF9)->CF9_CSTPIS)		
	oApurEnt:SetAlqTrib((cAliasCF9)->CF9_ALQPIS)
	oApurEnt:SetBcTrib((cAliasCF9)->CF9_BASMES)
	oApurEnt:SetValTrib((cAliasCF9)->CF9_VALPIS)			
	oApurEnt:AgrpCred()

	//---------------------
	//Informações da COFINS
	//---------------------		
	oApurEnt:SetTributo(COFINS)		
	oApurEnt:SetCST((cAliasCF9)->CF9_CSTCOF)		
	oApurEnt:SetAlqTrib((cAliasCF9)->CF9_ALQCOF)
	oApurEnt:SetBcTrib((cAliasCF9)->CF9_BASMES)
	oApurEnt:SetValTrib((cAliasCF9)->CF9_VALCOF)
	oApurEnt:AgrpCred()		
	
	//----------------------------------
	//Agrupa valores para resumo de CST
	//----------------------------------
	oApurEnt:GrvResCST()		
 
	(cAliasCF9)->(DbSkip ())			
EndDo

oApurEnt:FechaAlias(cAliasCF9)
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001AjuCF5(dDataDe,dDataAte,oAjustes)
Função que irá buscar as movimentações gravadas na tabela CF5 de ajustes
de créditos de PIS e COFINS, e irá processar para que sejam efetuados
os devidos ajustes

@param	dDataDe	- Data inicial do período de apuração
		dDataAte	-Data final do período de apuração
		oAjustes	-Objeto de ajuste já criado para processamento

@author Erick G. Dias
@since 14/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
 Static Function A001AjuCF5(dDataDe,dDataAte,oAjustes,lDebito)

Local cAliasCF5	:= ''
Local cSelect	:= ''
Local cWhere	:= ''
Local CREDITO 	:= '1'
Local cDebito	:= '2'
Local lDetAju	:= CF5->(ColumnPos('CF5_CST')) > 0
Local lTIPATV	:= CF5->(ColumnPos("CF5_TIPATV")) > 0
Local lProcDeb	:= CF5->(ColumnPos("CF5_TPAJST"))>0 .And. CF5->(ColumnPos("CF5_CODCON"))>0
Local cRegime	:= ''

Default lDebito := .F.

//Indica para objeto que os ajustes serão referentes aos créditos ou debitos
If lProcDeb .And. lDebito
	oAjustes:SetCrdDeb(cDebito)
ElseIF lDebito .And. !lProcDeb
	Return()
Else
	//Indica para objeto que os ajustes serão referentes aos créditos
	oAjustes:SetCrdDeb(CREDITO)
	lDebito := .F.
Endif


cAliasCF5	:=	GetNextAlias()
cSelect :=	"%CF5.*%"
cWhere	:=	"%CF5.CF5_FILIAL='"+xFilial("CF5")+"' AND "
cWhere	+=	"CF5.CF5_DTREF>='"+DTOS(dDataDe)+"' AND "
cWhere	+=	"CF5.CF5_DTREF<='"+DTOS(dDataAte)+"' AND "
cWhere	+=	"CF5.CF5_PISCOF<>'2' AND "

//Caso seja debido considera campo informativo debito ou credito
If lDebito 
	cWhere	+=	"CF5.CF5_TPAJST = '2' AND " 
ElseIf lProcDeb //caso campo não exista, significa que somente existe ajuste de credito no cadastro
	cWhere	+=	"CF5.CF5_TPAJST <> '2' AND "
Endif

cWhere	+= "%" 

BeginSql Alias cAliasCF5    	
    COLUMN CF5_DTREF AS DATE	
	SELECT			    	 
		%Exp:cSelect%		
	FROM 
		%Table:CF5% CF5													
	WHERE
		%Exp:cWhere%
		CF5.%NotDel%
EndSql

DbSelectArea (cAliasCF5)
(cAliasCF5)->(DbGoTop ())
Do While !(cAliasCF5)->(Eof ())

	//Definie regime pelo codigo
	IF lDebito
		//Guarda regime
		cRegime :=  oAjustes:cRegime
		IF (cAliasCF5)->CF5_CODCON $ "01|02|03|04|71" //codigos não cumulativos
			oAjustes:SetRegime('1') //Não cumulativo
		Else
			oAjustes:SetRegime('2') //Cumulativo
		Endif
	Endif

	//Passa as informações do ajuste para a classe
	oAjustes:SetTributo(Iif((cAliasCF5)->CF5_PISCOF=='0',PIS,COFINS))
	oAjustes:SetTpAjust((cAliasCF5)->CF5_INDAJU)
	oAjustes:SetCodAju((cAliasCF5)->CF5_CODAJU)
	oAjustes:SetNumDoc((cAliasCF5)->CF5_NUMDOC)
	oAjustes:SetDescAju((cAliasCF5)->CF5_DESAJU)
	oAjustes:SetVlAju((cAliasCF5)->CF5_VALAJU)
	oAjustes:SetCodDC(Iif(lDebito,(cAliasCF5)->CF5_CODCON,(cAliasCF5)->CF5_CODCRE))
	oAjustes:SetTipAtiv(IIf(lTIPATV,(cAliasCF5)->CF5_TIPATV,""))
	
	//Passa novas informações para classe de ajuste
	If lDetAju
		oAjustes:SetCst((cAliasCF5)->CF5_CST)
		oAjustes:SetConta((cAliasCF5)->CF5_CONTA)
		oAjustes:SetInfComp(Iif(Type("(cAliasCF5)->CF5_INFCOM")<> "U"  ,(cAliasCF5)->CF5_INFCOM  ,(cAliasCF5)->CF5_DESAJU  )  )
		oAjustes:SetBase((cAliasCF5)->CF5_BASE)
		oAjustes:SetAlq((cAliasCF5)->CF5_ALQ)			
	EndIF
	
	//Realiza o Ajuste
	oAjustes:Ajustar()

	//Restaura Regime
	IF lDebito
		oAjustes:SetRegime(cRegime)
	Endif

	(cAliasCF5)->(DbSkip ())			
EndDo

oAjustes:FechaAlias(cAliasCF5)
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001F130()
Função que irá buscar valores de créditos do Ativo Fixo por aquisição,
e irá processar estes ´créditos de PIS e COFINS através da integração 
da função _AtfRegF130, localizada no fonte FISXATF.

@param		dDataDe	- Data inicial do período de apuração
			dDadaAte	-Data Final do período de apuração
			oApurEnt	-Objeto já criado para apurar os valores dos créditos

@author Erick G. Dias
@since 14/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001F130(dDataDe, dDadaAte,	oApurEnt)

Local cF130Aux		:= ''
Local cArqDestino	:= ''
local cAliasF130		:= ''
local aResult			:= {}
Local oF130			:=	TABELACL2():New()

cF130Aux 		:= GetNextAlias()
cArqDestino 	:= "APUREFD"+GetDbExtension()							
aResult 		:= _AtfRegF130(cFilAnt,dDataDe,dDadaAte,"0000000","ZZZZZZZZZ",cF130Aux,.T.,"10")

If Len(aResult) > 0
	cAliasF130	:= aResult[1,2]

	DbSelectArea(cAliasF130)
	(cAliasF130)->(DbGoTop())
	Do While !(cAliasF130)->(Eof ())
	
		oApurEnt:SetRegime('1') //observação : Ajustar para verificar o regime da nota fiscal
		oApurEnt:SetOrigem(ATIVOFIXO)			
		oApurEnt:SetReceita((cAliasF130)->VL_BC_PIS)
		oApurEnt:SetCodBcc((cAliasF130)->NAT_BC_CRE)
		oApurEnt:SetCFOP(	'')	
		oApurEnt:SetImport(IIF(cvaltochar((cAliasF130)->IND_ORIG_C) == '1' ,.T.,.F.))
		
		//--------------------
		//Informações de PIS
		//--------------------			
		oApurEnt:SetTributo(PIS)
		oApurEnt:SetCST(padl(cvaltochar((cAliasF130)->CST_PIS),2,'0'))		
		oApurEnt:SetAlqTrib((cAliasF130)->ALIQ_PIS)
		oApurEnt:SetBcTrib((cAliasF130)->VL_BC_PIS)
		oApurEnt:SetValTrib((cAliasF130)->VL_PIS)			
		oApurEnt:AgrpCred()
	
		//-----------------------
		//Informações da COFINS
		//-----------------------		
		oApurEnt:SetTributo(COFINS)		
		oApurEnt:SetCST(padl(cvaltochar((cAliasF130)->CST_COFINS),2,'0'))				
		oApurEnt:SetAlqTrib((cAliasF130)->ALIQ_COFIN)
		oApurEnt:SetBcTrib((cAliasF130)->VL_BC_COFIN)
		oApurEnt:SetValTrib((cAliasF130)->VL_COFINS)
		oApurEnt:AgrpCred()		
		
		//----------------------------------
		//Agrupa valores para resumo de CST
		//----------------------------------
		oApurEnt:GrvResCST()

		//-----------------------------------------
		//ABAIXO GRAVA OS VALORES DO REGISTRO F130
		//----------------------------------------
		oF130:SetParam('CL2_PER',dDataDe)
		oF130:SetParam('CL2_REG','F130')
		oF130:SetParam('CL2_CODBCC',(cAliasF130)->NAT_BC_CRE)
		oF130:SetParam('CL2_IDBEM',strzero((cAliasF130)->IDENT_BEM,2))
		oF130:SetParam('CL2_MESANO',cvaltochar(strzero((cAliasF130)->MES_OPER_A,6)))
		oF130:SetParam('CL2_VLAQUI',(cAliasF130)->VL_OPER_AQ)
		oF130:SetParam('CL2_VLEXCL',(cAliasF130)->PARC_OPER)
		oF130:SetParam('CL2_INDPAC',cvaltochar((cAliasF130)->IND_NR_PAR))
		oF130:SetParam('CL2_CSTPIS',cvaltochar((cAliasF130)->CST_PIS))
		oF130:SetParam('CL2_BCPIS',(cAliasF130)->VL_BC_PIS)
		oF130:SetParam('CL2_ALQPIS',(cAliasF130)->ALIQ_PIS)	
		oF130:SetParam('CL2_VLPIS',(cAliasF130)->VL_PIS)
		oF130:SetParam('CL2_CSTCOF',cvaltochar((cAliasF130)->CST_COFINS))
		oF130:SetParam('CL2_BCCOF',(cAliasF130)->VL_BC_COFIN)							
		oF130:SetParam('CL2_ALQCOF',(cAliasF130)->ALIQ_COFIN)
		oF130:SetParam('CL2_VLCOF',(cAliasF130)->VL_COFINS)
		oF130:SetParam('CL2_CTA',(cAliasF130)->COD_CTA)
		oF130:SetParam('CL2_CCUS',(cAliasF130)->COD_CCUS)
		oF130:SetParam('CL2_DESCR',(cAliasF130)->DESC_BEM_I)
		oF130:SetParam('CL2_ORICRD',cvaltochar((cAliasF130)->IND_ORIG_C))
		oF130:SetParam('CL2_IDUTI',cvaltochar((cAliasF130)->IND_UTIL_B))
		oF130:SetParam('CL2_INDPRO',(cAliasF130)->INDPRO)		
		oF130:SetParam('CL2_NUMPRO',(cAliasF130)->NUMPRO)
		oF130:SetParam('CL2_CODATF',(cAliasF130)->BEM)
		oF130:SetParam('CL2_ITATF',(cAliasF130)->ITEM)
		oF130:SetParam('CL2_DESATF',(cAliasF130)->DESCRI)
		oF130:SetParam('CL2_CRTCRD','1')//Aquisição	
		oF130:Save()
		//PARA TRATAMENTO DE ALÍQUOTA MAJORADA DEVERÁ SER SOLICITADA ALTERAÇÃO
		//NA FUNÇÃO DE INTEGRAÇÃO DO FINANCEIRO, NÃO DEVERÁ SER TRATADO AQUI.
		
		(cAliasF130)->(DBSKIP())
	EndDo

	//Fechar os arquivos do ativo depois de finalizado o processamento
	(cAliasF130)->(DbCloseArea ())
	FERASE(ARESULT[1,1]+GetDbExtension())
	FERASE(ARESULT[1,1]+OrdBagExt())
	
EndIf 

FreeObj(oF130)
oF130	:= Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001F120()
Função que irá buscar valores de créditos do Ativo Fixo por depreciação,
e irá processar estes ´créditos de PIS e COFINS através da integração 
da função _DeprecAtivo, localizada no fonte FISXATF.

@param		dDataDe	- Data inicial do período de apuração
			dDadaAte	-Data Final do período de apuração
			oApurEnt	-Objeto já criado para apurar os valores dos créditos

@author Erick G. Dias
@since 14/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001F120(dDataDe, dDadaAte,	oApurEnt)

Local aProcItem	:= {}
Local oF120		:=	TABELACL2():New()
lOCAL cAliasF120	:= ''  	 

aAdd(aProcItem,"") 			//Ativo Inicial
aAdd(aProcItem,"zz") 		//Ativo Final
aAdd(aProcItem,CToD("")) 	//Data Inicial da aquisição
aAdd(aProcItem,dDadaAte) 	//Data Final da aquisição
aAdd(aProcItem,"ATI")      	//Tabela Temporaria
aF120Aux := _DeprecAtivo(dDataDe,dDadaAte,.T.,.F.,aProcItem,,.F.,"09/11",SM0->M0_CODFIL,.F.)

DbSelectArea("ATI")
ATI->(DbSetOrder(1))
ATI->(dbGoTop())
cAliasF120:= aF120Aux[1,2]

Do While !(cAliasF120)->(Eof ())

	oApurEnt:SetRegime('1') //observação : Ajustar para verificar o regime da nota fiscal
	oApurEnt:SetOrigem(ATIVOFIXO)			
	oApurEnt:SetReceita((cAliasF120)->VLRBCPIS)
	oApurEnt:SetCodBcc((cAliasF120)->NATBCCRED)
	oApurEnt:SetCFOP(	'')	
	oApurEnt:SetlDeprAtv(.T.)
	oApurEnt:SetImport(IIF((cAliasF120)->INDORIGCRD == '1' ,.T.,.F.))	
	
	//---------------------
	//Informações de PIS
	//---------------------			
	oApurEnt:SetTributo(PIS)
	oApurEnt:SetCST((cAliasF120)->CSTPIS)		
	oApurEnt:SetAlqTrib((cAliasF120)->ALIQPIS)
	oApurEnt:SetBcTrib((cAliasF120)->VLRBCPIS)
	oApurEnt:SetValTrib((cAliasF120)->VLRPIS)			
	oApurEnt:AgrpCred()

	//----------------------
	//Informações da COFINS
	//----------------------		
	oApurEnt:SetTributo(COFINS)		
	oApurEnt:SetCST((cAliasF120)->CSTCOFINS)		
	oApurEnt:SetAlqTrib((cAliasF120)->ALIQCOFINS)
	oApurEnt:SetBcTrib((cAliasF120)->VLRBCCOFIN)
	oApurEnt:SetValTrib((cAliasF120)->VLRCOFINS)
	oApurEnt:AgrpCred()		
	
	//-------------------------------------------------------------------
	//Agrupa valores para resumo de CST
	//-------------------------------------------------------------------
	oApurEnt:GrvResCST()

	//------------------------------------------
	//ABAIXO IRÁ GRAVAR A OPERAÇÃO NA TABELA CL2
	//------------------------------------------
	oF120:SetParam('CL2_PER',dDataDe)
	oF120:SetParam('CL2_REG','F120')
	oF120:SetParam('CL2_VLOPER',(cAliasF120)->VRET)
	oF120:SetParam('CL2_CODBCC',(cAliasF120)->NATBCCRED)
	oF120:SetParam('CL2_IDBEM',(cAliasF120)->INDBEMIMOB)
	oF120:SetParam('CL2_ORICRD',(cAliasF120)->INDORIGCRD)
	oF120:SetParam('CL2_IDUTI',(cAliasF120)->INDUTILBEM)
	oF120:SetParam('CL2_CSTPIS',(cAliasF120)->CSTPIS)
	oF120:SetParam('CL2_BCPIS',(cAliasF120)->VLRBCPIS)
	oF120:SetParam('CL2_ALQPIS',(cAliasF120)->ALIQPIS)	
	oF120:SetParam('CL2_VLPIS',(cAliasF120)->VLRPIS)
	oF120:SetParam('CL2_CSTCOF',(cAliasF120)->CSTCOFINS)
	oF120:SetParam('CL2_BCCOF',(cAliasF120)->VLRBCCOFIN)							
	oF120:SetParam('CL2_ALQCOF',(cAliasF120)->ALIQCOFINS)
	oF120:SetParam('CL2_VLCOF',(cAliasF120)->VLRCOFINS)
	oF120:SetParam('CL2_CTA',(cAliasF120)->CODCONTA)
	oF120:SetParam('CL2_CCUS',(cAliasF120)->CODCCUSTO)
	oF120:SetParam('CL2_DESCR',(cAliasF120)->DESCBEMIMO)
	oF120:SetParam('CL2_INDPRO',(cAliasF120)->INDPRO)		
	oF120:SetParam('CL2_NUMPRO',(cAliasF120)->NUMPRO)
	oF120:SetParam('CL2_CODATF',(cAliasF120)->BEM)
	oF120:SetParam('CL2_ITATF',(cAliasF120)->ITEM)
	oF120:SetParam('CL2_DESATF',(cAliasF120)->DESCRI)
	oF120:SetParam('CL2_CRTCRD','2')//Depreciação	
	oF120:Save()
	
	(cAliasF120)->(DbSkip()) 
EndDo				
oApurEnt:SetlDeprAtv(.F.)
DbSelectArea(aF120Aux[1,2])
dbCloseArea()
Ferase(aF120Aux[1,1]+GetDBExtension())
Ferase(aF120Aux[1,1]+OrdBagExt())

FreeObj(oF120)
oF120:=Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001CF8()
Função que irá buscar valores de créditos do Ativo Fixo por depreciação,
e irá processar estes ´créditos de PIS e COFINS através da integração 
da função _DeprecAtivo, localizada no fonte FISXATF.

@param		dDataDe	-Data inicial do período de apuração
			dDadaAte	-Data Final do período de apuração
			oApurEnt	-Objeto para as operações com créditos já criado 
						 para apurar os valores dos créditos
			oApurSai	-Objeto para as operações com débitos já criado 
						 para apurar os valores dos créditos			
			lProcCred	-Indica se irá processar operações de crédito			 
			nTotF100	-Campos com somatório das receitas utilizadas 
						 para o F100			
			lPTitEnt	-Indica se irá processar as operações de entrada
			lPTitSai	-Indica se irá processar as operações de saída						

@author Erick G. Dias
@since 14/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001CF8(dDataDe,	dDadaAte,	oApurEnt,	oApurSai,	lProcCred,	nTotF100,	lPTitEnt,	lPTitSai,cReg, cDebito,nBsConsorc,lCPRBNF)

Local cAliasCF8	:= ''
Local cCodPart	:= ''
Local cLoja		:= ''
Local cDtOperCF8	:= '' 
Local lCF8EXCPRB	:= CF8->(ColumnPos( 'CF8_EXCPRB' ))
Local oF100		:=	TABELACL2():New() //Cria objeto para gravação do F100
Local lEntDeb	:=	.F. 

cAliasCF8	:=	GetNextAlias()

cSelect	:=	'%CF8.*%'

cWhere		:=	"% CF8.CF8_FILIAL= '" +xFilial("CF8")+ "' AND  "
cWhere		+=	"CF8.CF8_DTOPER>='"+DTOS(dDataDe)+"' AND "
cWhere		+=	"CF8.CF8_DTOPER<='"+DTOS(dDadaAte)+"' AND "
If cDebito=="1" // Débito
	cWhere	+= "CF8.CF8_CSTPIS IN ('01','02','03','04','05','06','07','08','09','49')  AND %"                
ElseIf cDebito=="2" //Crédito
    cWhere	+= "CF8.CF8_CSTPIS IN ('50','51','52','53','54','55','56','60','61','62','63','64','65','66')  AND %"
EndIF

BeginSql Alias cAliasCF8    	
    COLUMN CF8_DTOPER AS DATE	
    COLUMN CF8_DTFIMN AS DATE    
	SELECT			    	 
		%Exp:cSelect%		

	FROM 
		%Table:CF8% CF8													
	WHERE
		%Exp:cWhere%
		CF8.%NotDel%
	
EndSql

DbSelectArea (cAliasCF8)
(cAliasCF8)->(DbGoTop ())
Do While !(cAliasCF8)->(Eof ())

	cCodPart	:= 	''
	cLoja		:= 	''
	cDtOperCF8	:=	''	
	cCodPart 	:=  Padr((cAliasCF8)->CF8_CLIFOR,TamSx3("A1_COD")[1])+PADR((cAliasCF8)->CF8_LOJA,TamSx3("A1_LOJA")[1])
	cDtOperCF8	:=	Substr(DTOS((cAliasCF8)->CF8_DTOPER),7,2)+Substr(DTOS((cAliasCF8)->CF8_DTOPER),5,2)+Substr(DTOS((cAliasCF8)->CF8_DTOPER),1,4)
	cDescCF8	:=	Formula((cAliasCF8)->CF8_DESCPR)
	//Tratamento para debito de piscof em notas de doação que geram receita
	lEntDeb 	:= CF8->(ColumnPos("CF8_DOC"))>0 .And. !Empty((cAliasCF8)->CF8_DOC) .And. (cAliasCF8)->CF8_PART == '2' .And. Alltrim((cAliasCF8)->CF8_INDOPE)$"1/2"

	If (cAliasCF8)->CF8_CSTPIS $ cCstCred //Processa objeto de crédito caso tenha CST de crédito
		IF lProcCred
			If lPTitEnt
				oApurEnt:SetRegime(Iif((cAliasCF8)->CF8_TPREG == '2',NAOCUMULAT,CUMULAT)) 
				oApurEnt:SetOrigem(TITENTRADA)			
				oApurEnt:SetReceita((cAliasCF8)->CF8_VLOPER)
				oApurEnt:SetCodBcc((cAliasCF8)->CF8_CODBCC)
				oApurEnt:SetTNatRec((cAliasCF8)->CF8_TNATRE)
				oApurEnt:SetCNatRec((cAliasCF8)->CF8_CNATRE)		
				oApurEnt:SetGNatRec((cAliasCF8)->CF8_GRPNC)
				oApurEnt:SetDNatRec((cAliasCF8)->CF8_DTFIMN)
				oApurEnt:SetCFOP(	'')
				oApurEnt:SetImport(IIF((cAliasCF8)->CF8_INDORI== '0' ,.F.,.T. ))
		
				//--------------------
				//Informações de PIS
				//--------------------			
				oApurEnt:SetTributo(PIS)
				oApurEnt:SetCST((cAliasCF8)->CF8_CSTPIS)		
				oApurEnt:SetAlqTrib((cAliasCF8)->CF8_ALQPIS)
				oApurEnt:SetBcTrib((cAliasCF8)->CF8_BASPIS)
				oApurEnt:SetValTrib((cAliasCF8)->CF8_VALPIS)			
				oApurEnt:AgrpCred()
		
				//-----------------------
				//Informações da COFINS
				//-----------------------		
				oApurEnt:SetTributo(COFINS)		
				oApurEnt:SetCST((cAliasCF8)->CF8_CSTCOF)		
				oApurEnt:SetAlqTrib((cAliasCF8)->CF8_ALQCOF)
				oApurEnt:SetBcTrib((cAliasCF8)->CF8_BASCOF)
				oApurEnt:SetValTrib((cAliasCF8)->CF8_VALCOF)
				oApurEnt:AgrpCred()		
				
				//----------------------------------
				//Agrupa valores para resumo de CST
				//----------------------------------
				oApurEnt:GrvResCST()
				oApurEnt:SetImport(.F.)			
				
			EndIF

		EndIF

	ElseIF lPTitSai			
		//----------------------
		//OPERAÇÕES DE SAÍDAS
		//----------------------

		If Alltrim((cAliasCF8)->CF8_INDOPE)$"1/2"
			nTotF100	+= (cAliasCF8)->CF8_VLOPER
		EndIf
		oApurSai:SetRegime(Iif((cAliasCF8)->CF8_TPREG == '2',NAOCUMULAT,CUMULAT))
		oApurSai:SetOrigem(TITSAIDA)
		oApurSai:SetReceita((cAliasCF8)->CF8_VLOPER)
		oApurSai:SetTNatRec((cAliasCF8)->CF8_TNATRE)
		oApurSai:SetCNatRec((cAliasCF8)->CF8_CNATRE)		
		oApurSai:SetGNatRec((cAliasCF8)->CF8_GRPNC)
		oApurSai:SetDNatRec((cAliasCF8)->CF8_DTFIMN)
		oApurSai:SetCFOP(	'')
		If cReg== 4
			oApurSai:SetTpReg(Iif((cAliasCF8)->CF8_TPREG == '2',NAOCUMULAT,CUMULAT))
		EndIF
		
		//-------------------------------------------------------------------
		//Informações do PIS
		//-------------------------------------------------------------------		
		oApurSai:SetTributo(PIS)
		oApurSai:SetCST((cAliasCF8)->CF8_CSTPIS)		
		oApurSai:SetAlqTrib((cAliasCF8)->CF8_ALQPIS)
		oApurSai:SetBcTrib((cAliasCF8)->CF8_BASPIS)
		oApurSai:SetValTrib((cAliasCF8)->CF8_VALPIS)
		oApurSai:AgrpContr()	
	
		//-------------------------------------------------------------------
		//Informações da COFINS
		//-------------------------------------------------------------------
		oApurSai:SetTributo(COFINS)
		oApurSai:SetCST((cAliasCF8)->CF8_CSTCOF)		
		oApurSai:SetAlqTrib((cAliasCF8)->CF8_ALQCOF)
		oApurSai:SetBcTrib((cAliasCF8)->CF8_BASCOF)
		oApurSai:SetValTrib((cAliasCF8)->CF8_VALCOF)
		oApurSai:AgrpContr()	
	
		oApurSai:GrvResCST(Iif((cAliasCF8)->CF8_RECBRU <> '2' ,.T. ,.F.))
		
		If lCF8EXCPRB .AND. (cAliasCF8)->CF8_EXCPRB == '1'
			nBsConsorc += (cAliasCF8)->CF8_BASPIS
		EndIF		
		
	EndIF
	//-----------------------------------------
	//ABAIXO GRAVA OS VALORES DO REGISTRO F100 
	//-----------------------------------------
	oF100:SetParam('CL2_PER',dDataDe)
	oF100:SetParam('CL2_REG','F100')
	oF100:SetParam('CL2_INDOP',(cAliasCF8)->CF8_INDOPE)
	oF100:SetParam('CL2_PARTI',cCodPart)
	oF100:SetParam('CL2_ITEM',(cAliasCF8)->CF8_ITEM)		
	oF100:SetParam('CL2_DTOPER',(cAliasCF8)->CF8_DTOPER)		
	oF100:SetParam('CL2_VLOPER',(cAliasCF8)->CF8_VLOPER)
	oF100:SetParam('CL2_CSTPIS',(cAliasCF8)->CF8_CSTPIS)		
	oF100:SetParam('CL2_BCPIS',(cAliasCF8)->CF8_BASPIS)		
	oF100:SetParam('CL2_ALQPIS',(cAliasCF8)->CF8_ALQPIS)		
	oF100:SetParam('CL2_VLPIS',(cAliasCF8)->CF8_VALPIS)		
	oF100:SetParam('CL2_CSTCOF',(cAliasCF8)->CF8_CSTCOF)		
	oF100:SetParam('CL2_BCCOF',(cAliasCF8)->CF8_BASCOF)		
	oF100:SetParam('CL2_ALQCOF',(cAliasCF8)->CF8_ALQCOF)		
	oF100:SetParam('CL2_VLCOF',(cAliasCF8)->CF8_VALCOF)		
	oF100:SetParam('CL2_CODBCC',(cAliasCF8)->CF8_CODBCC)		
	oF100:SetParam('CL2_INDCRD',(cAliasCF8)->CF8_INDORI)		
	oF100:SetParam('CL2_CTA',(cAliasCF8)->CF8_CODCTA)		
	oF100:SetParam('CL2_CCUS',(cAliasCF8)->CF8_CODCCS)		
	oF100:SetParam('CL2_DESCR',Iif(cDescCF8<>Nil,cDescCF8,(cAliasCF8)->CF8_DESCPR))
	oF100:SetParam('CL2_PART',(cAliasCF8)->CF8_PART)
	oF100:SetParam('CL2_IDCF8',(cAliasCF8)->CF8_CODIGO)
	oF100:SetParam('CL2_REGIME',Iif((cAliasCF8)->CF8_TPREG == '2',NAOCUMULAT,CUMULAT))	
	oF100:Save()

	(cAliasCF8)->(DbSkip ())			
EndDo

oF100:FechaAlias(cAliasCF8)
FreeObj(oF100)
oF100:= Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001F100Fi()
Função que irá processar valores de PIS e COFINS de títulos sem vínculo
com documento fiscal gravado no Financeiro, através da função FinSpdF100
no fonte MATXATU.

@param		dDataDe	-Data inicial do período de apuração
			dDadaAte	-Data Final do período de apuração
			oApurEnt	-Objeto para as operações com créditos já criado 
						 para apurar os valores dos créditos
			oApurSai	-Objeto para as operações com débitos já criado 
						 para apurar os valores dos créditos	
			lProcCred	-Indica se irá processar operações de crédito			 
			nTotF100	-Campos com somatório das receitas utilizadas 
						 para o F100			
			lPTitEnt	-Indica se irá processar as operações de entrada
			lPTitSai	-Indica se irá processar as operações de saída							 		

@author Erick G. Dias
@since 14/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001F100Fi(dDataDe, dDadaAte,	oApurEnt,	oApurSai,lProcCred,nTotF100,lPTitEnt, lPTitSai,cReg,cDeb,aF100,lCPRBNF)

Local nPos	:= 0
Local oF100	:=	TABELACL2():New()
Local cIndOper	:= ''
Local lGravaF100	:= .F.	
Local cIndOrig	:= ''
Local cNumTit		:= ''
Local cPrefixo	:= ''
Local cParcela	:= ''
Local cInfComp	:= ''
Local cDescr		:= ''

For nPos	:= 1 To Len (aF100)	
	
	lGravaF100	:= .F.
	cIndOper	:= ''
	If aF100[nPos][3] $ cCstCred
		cIndOper := "0"	
	ElseIf aF100[nPos][3] $ cCstTrib		
		cIndOper := "1"
	ElseIf aF100[nPos][3] $ cCstNTrib	
		cIndOper := "2"
	EndIF   
	cCodPart	:= aF100[nPos][17]	//Aqui o Financeiro já retorna código do cliente + loja, prontos para fazer seek

	lCumulativ	:=	Iif ( aF100[nPos][14] == "0", .T. , .F. )
	cIndOrig	:= ''
	cDescr		:= ''
	cInfComp	:= ''
	If aF100[nPos][3] $ cCstCred //Se tiver CST com direito ao crédito irá processar objeto de crédito
		IF lProcCred .AND. cDeb == '2'
			If lPTitEnt
				//-----------------------
				//Informações do título
				//-----------------------
				lGravaF100	:= .T.
				If SA2->(MsSeek(xFilial("SA2")+ cCodPart))
					cIndOrig:= Iif(SA2->A2_CODPAIS=="01058","0","1")
				EndIF
				oApurEnt:SetRegime(Iif(lCumulativ,CUMULAT ,NAOCUMULAT )) //observação : Ajustar para verificar o regime da nota fiscal
				oApurEnt:SetOrigem(TITENTRADA)			
				oApurEnt:SetReceita(aF100[nPos][2])
				oApurEnt:SetCodBcc(aF100[nPos][11])
				oApurEnt:SetTNatRec(aF100[nPos][18])
				oApurEnt:SetCNatRec(aF100[nPos][19])		
				oApurEnt:SetGNatRec(aF100[nPos][20])
				oApurEnt:SetDNatRec(cTod(aF100[nPos][21]))	
				oApurEnt:SetCFOP(	'')	
				oApurEnt:SetImport(IIF(cIndOrig == '0' ,.F.,.T. ))
		
				//--------------------
				//Informações de PIS
				//--------------------			
				oApurEnt:SetTributo(PIS)
				oApurEnt:SetCST(aF100[nPos][3])		
				oApurEnt:SetAlqTrib(aF100[nPos][5])
				oApurEnt:SetBcTrib(aF100[nPos][4])
				oApurEnt:SetValTrib(aF100[nPos][4]*aF100[nPos][5]/100)
				//oApurEnt:SetValTrib(aF100[nPos][6])
				oApurEnt:AgrpCred()
		
				//-----------------------
				//Informações da COFINS
				//-----------------------		
				oApurEnt:SetTributo(COFINS)		
				oApurEnt:SetCST(aF100[nPos][7])		
				oApurEnt:SetAlqTrib(aF100[nPos][9])
				oApurEnt:SetBcTrib(aF100[nPos][8])
				oApurEnt:SetValTrib(aF100[nPos][10])
				oApurEnt:AgrpCred()		
				
				//----------------------------------
				//Agrupa valores para resumo de CST
				//----------------------------------
				oApurEnt:GrvResCST()	
				oApurEnt:SetImport(.F.)
				
			EndIF
			
		EndIF

	ElseIf lPTitSai .AND. cDeb == '1'
	
		//--------------------
		//OPERAÇÕES DE SAÍDAS
		//--------------------
		lGravaF100	:= .T.
		nTotF100 += aF100[nPos][2]
		oApurSai:SetRegime(Iif(lCumulativ,CUMULAT ,NAOCUMULAT )) //observação : Ajustar para verificar o regime da nota fiscal
		oApurSai:SetOrigem(TITSAIDA)
		oApurSai:SetReceita(aF100[nPos][2])
		oApurSai:SetTNatRec(aF100[nPos][18])
		oApurSai:SetCNatRec(aF100[nPos][19])		
		oApurSai:SetGNatRec(aF100[nPos][20])
		oApurSai:SetDNatRec(cTod(aF100[nPos][21]))
		oApurSai:SetQtde(1)
		oApurSai:SetCFOP(	'')
		If cReg== 4			
			oApurSai:SetTpReg(Iif(lCumulativ,CUMULAT ,NAOCUMULAT ))
		EndIF
	
		//-------------------
		//Informações do PIS
		//-------------------		
		oApurSai:SetTributo(PIS)
		oApurSai:SetCST(aF100[nPos][3])		
		oApurSai:SetAlqTrib(aF100[nPos][5])
		oApurSai:SetBcTrib(aF100[nPos][4])
		oApurSai:SetValTrib(aF100[nPos][4]*aF100[nPos][5]/100)//aF100[nPos][6])
		oApurSai:AgrpContr()	
	
		//----------------------
		//Informações da COFINS
		//----------------------
		oApurSai:SetTributo(COFINS)
		oApurSai:SetCST(aF100[nPos][7])		
		oApurSai:SetAlqTrib(aF100[nPos][9])
		oApurSai:SetBcTrib(aF100[nPos][8])
		oApurSai:SetValTrib(aF100[nPos][8]*aF100[nPos][9]/100)//aF100[nPos][10])
		oApurSai:AgrpContr()	
	
		oApurSai:GrvResCST(Iif(Len(aF100[nPos])>=33,Iif(aF100[nPos][33] <> '2' ,.T. ,.F.),.T.))
			
		cNumTit	 := ''
		cInfComp	:= ''
		IF aF100[nPos][15] == "SE1"
			SE1->(dbGoto( aF100[nPos][16]))
			If IntTms () .AND. DT6->(MsSeek (xFilial("DT6")+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_TIPO))
				cNumTit := "referente o CTe : " + DT6->DT6_DOC
			Else
				cNumTit 	:="referente o Título :" + SE1->E1_NUM
    		EndIF
		ElseIF aF100[nPos][15] == "SE5"
			SE5->(dbGoto( aF100[nPos][16]))
			cNumTit 	:="referente o Título :" + SE5->E5_NUMERO
		ElseIF aF100[nPos][15] == "SEI"
			SEI->(dbGoto( aF100[nPos][16]))
			cNumTit 	:="referente a Aplicação :" + SEI->EI_NUMERO
		EndIF
		If !Empty(Alltrim(cNumTit))
			cInfComp	:= "Operação " + cNumTit
		EndIf
		
	EndIF
	IF lGravaF100
		//---------------------------------------------------
		//ABAIXO GRAVA OS VALORES DO REGISTRO F100 COM DÉBITO
		//---------------------------------------------------
		oF100:SetParam('CL2_PER',dDataDe)
		oF100:SetParam('CL2_REG','F100')
		oF100:SetParam('CL2_INDOP',cIndOper)
		oF100:SetParam('CL2_PARTI',cCodPart)		
		oF100:SetParam('CL2_ITEM','')//Títulos sem documento fiscal não tem código de produto		
		oF100:SetParam('CL2_DTOPER',CTOD(Substr( aF100[nPos][1],7,2)  + '/'+ Substr( aF100[nPos][1],5,2) + '/' + Substr( aF100[nPos][1],1,4)))		
		oF100:SetParam('CL2_VLOPER',aF100[nPos][2])
		oF100:SetParam('CL2_CSTPIS',aF100[nPos][3])		
		oF100:SetParam('CL2_BCPIS',aF100[nPos][4])		
		oF100:SetParam('CL2_ALQPIS',aF100[nPos][5])		
		oF100:SetParam('CL2_VLPIS',aF100[nPos][6])		
		oF100:SetParam('CL2_CSTCOF',aF100[nPos][7])		
		oF100:SetParam('CL2_BCCOF',aF100[nPos][8])		
		oF100:SetParam('CL2_ALQCOF',aF100[nPos][9])		
		oF100:SetParam('CL2_VLCOF',aF100[nPos][10])		
		oF100:SetParam('CL2_CODBCC',aF100[nPos][11])
		oF100:SetParam('CL2_INDCRD',cIndOrig)
		oF100:SetParam('CL2_CTA',Iif(Len(aF100[nPos])>22, aF100[nPos][23], ""))		
		oF100:SetParam('CL2_CCUS',Iif(Len(aF100[nPos])>23, aF100[nPos][24], ""))		
		//oF100:SetParam('CL2_DESCR',Iif(len(aF100[nPos]) >=29,aF100[nPos][29],"" ))
		oF100:SetParam('CL2_INDPRO',aF100[nPos][28])		
		oF100:SetParam('CL2_NUMPRO',aF100[nPos][27])
		oF100:SetParam('CL2_ORICRD','0')
		
		cNumTit	:= ''
		cPrefixo	:= ''
		cParcela	:= ''				
		IF aF100[nPos][15] == "SE1"
		
			SE1->(dbGoto( aF100[nPos][16]))			
			cNumTit	:= SE1->E1_NUM    
			cPrefixo	:= SE1->E1_PREFIXO
			cParcela	:= SE1->E1_PARCELA
			
		ElseIF aF100[nPos][15] == "SE2"
		
			SE2->(dbGoto( aF100[nPos][16]))			
			cNumTit	:= SE2->E2_NUM    
			cPrefixo	:= SE2->E2_PREFIXO
			cParcela	:= SE2->E2_PARCELA
						
		ElseIF aF100[nPos][15] == "SE5"
		
			SE5->(dbGoto( aF100[nPos][16]))			
			cNumTit	:= SE5->E5_NUMERO
			cPrefixo	:= SE5->E5_PREFIXO
			cParcela	:= SE5->E5_PARCELA
			
		EndIF
		
		oF100:SetParam('CL2_NUMTIT', cNumTit)		
		oF100:SetParam('CL2_PREFIX', cPrefixo)
		oF100:SetParam('CL2_PARC', cParcela)
		oF100:SetParam('CL2_REGIME', Iif(lCumulativ,CUMULAT ,NAOCUMULAT ))
		
		IF len(aF100[nPos]) >=29
			cDescr	:= aF100[nPos][29]
		EndIF
		
		If !Empty(cInfComp)
			cDescr	:= cDescr + Iif(!Empty(cDescr),' - ','')  +  cInfComp
		EndIF
		
		oF100:SetParam('CL2_DESCR',cDescr)
		oF100:Save()
	EndIF
	
Next nPos

FreeObj(oF100)
oF100:= Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001SFTEnt()
Função que irá processar operações de entradas gravadas no livro fiscal

@param		dDataDe	-Data inicial do período de apuração
			dDadaAte	-Data Final do período de apuração
			oApurEFD	-Objeto para as operações com créditos já criado 
						 para apurar os valores dos créditos

@author Erick G. Dias
@since 14/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001SFTEnt(dDataDe, dDadaAte,oApurEFD)

local cAliasSFT	:= 'SFT'
local cSlctSFT	:= ''
Local cFiltro		:= ''
local cGroupBy	:= ''
Local cFrom		:= ''

cAliasSFT	:=	GetNextAlias()
oApurEFD:SetOrigem(FISCALENT)

cFrom	:= oApurEFD:GetJoinFrm(0,.F.,NFENTRADA)

//Chama método para retornar campos de forma agrupada		
cSlctSFT   :=	oApurEFD:GetCmpSFT()		
//Chama método para voltar filtro das operações de saídas
cFiltro 	:= oApurEFD:GetWhrSFT(NFENTRADA)
//Chama método para retornar group by de saída
cGroupBy	:=	oApurEFD:GetGrpSFT()

cFiltro:= '%' + cFiltro + '%'
cGroupBy := '%' + cGroupBy +'%'

BeginSql Alias cAliasSFT    	
    COLUMN FT_DTFIMNT AS DATE	
	SELECT			    	 
		%Exp:cSlctSFT%		

	FROM	
		%Exp:cFrom%													
	WHERE
		%Exp:cFiltro%
		SFT.%NotDel% 
        
	%Exp:cGroupBy%	
EndSql		

ProcRegua ((cAliasSFT)->(RecCount ()))	
DbSelectArea (cAliasSFT)
(cAliasSFT)->(DbGoTop ())
Do While !(cAliasSFT)->(Eof ())	
	If oApurEFD:ChkRegraNf((cAliasSFT)->FT_ESPECIE,(cAliasSFT)->FT_CFOP,NFENTRADA) 		
		//-------------------------------------------------------------------
		//Informações da Nota Fiscal
		//-------------------------------------------------------------------
		oApurEFD:SetOrigem(FISCALENT)
		oApurEFD:SetRegime(NAOCUMULAT) 	
		oApurEFD:SetCFOP(	(cAliasSFT)->FT_CFOP)		
		oApurEFD:SetReceita((cAliasSFT)->FT_VALCONT)
		oApurEFD:SetCodBcc((cAliasSFT)->FT_CODBCC)
		oApurEFD:SetTNatRec((cAliasSFT)->ft_tnatrec)
		oApurEFD:SetCNatRec((cAliasSFT)->ft_cnatrec)		
		oApurEFD:SetGNatRec((cAliasSFT)->ft_gruponc)
		oApurEFD:SetDNatRec((cAliasSFT)->FT_DTFIMNT)
		oApurEFD:SetImport(IIF(SubStr((cAliasSFT)->FT_CFOP,1,1) == '3' ,.T.,.F. ))		
		oApurEFD:SetQtde((cAliasSFT)->FT_QUANT)
				
		//-------------------------------------------------------------------
		//Informações de PIS
		//-------------------------------------------------------------------			
		oApurEFD:SetTributo(PIS)
		oApurEFD:SetCST((cAliasSFT)->FT_CSTPIS)		
		oApurEFD:SetAlqTrib((cAliasSFT)->FT_ALIQPIS)
		oApurEFD:SetBcTrib((cAliasSFT)->FT_BASEPIS)
		oApurEFD:SetValTrib((cAliasSFT)->FT_VALPIS)
		oApurEFD:SetBaseST((cAliasSFT)->FT_BASEPS3)
		oApurEFD:SetValST((cAliasSFT)->FT_VALPS3)
		oApurEFD:SetAlqSt((cAliasSFT)->FT_ALIQPS3)		
		oApurEFD:SetAlqMaj((cAliasSFT)->FT_MALQPIS)
		oApurEFD:SetValMaj((cAliasSFT)->FT_MVALPIS)
		oApurEFD:SetVlPauta((cAliasSFT)->ft_pautPIS)
		oApurEFD:OperPauta()			
		oApurEFD:AgrpCred()		

		//-------------------------------------------------------------------
		//Informações da COFINS
		//-------------------------------------------------------------------		
		oApurEFD:SetTributo(COFINS)		
		oApurEFD:SetCST((cAliasSFT)->FT_CSTcof)
		oApurEFD:SetAlqTrib((cAliasSFT)->FT_ALIQCOF)
		oApurEFD:SetBcTrib((cAliasSFT)->FT_BASECOF)
		oApurEFD:SetValTrib((cAliasSFT)->FT_VALCOF)
		oApurEFD:SetBaseST((cAliasSFT)->FT_BASECF3)
		oApurEFD:SetValST((cAliasSFT)->FT_VALCF3)
		oApurEFD:SetAlqSt((cAliasSFT)->FT_ALIQCF3)
		oApurEFD:SetAlqMaj((cAliasSFT)->FT_MALQCOF)
		oApurEFD:SetValMaj((cAliasSFT)->FT_MVALCOF)
		oApurEFD:SetVlPauta((cAliasSFT)->ft_pautCOF)
		oApurEFD:OperPauta()
		oApurEFD:AgrpCred()		
		
		//Agrupa valores para resumo de CST
		oApurEFD:GrvResCST()		
		oApurEFD:SetImport(.F.)	
		
	EndIF	

	(cAliasSFT)->(DbSkip ())			
EndDo


oApurEFD:FechaAlias(cAliasSFT)

//Finaliza operações de entrada
oApurEFD:Finaliza('2')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001SFTSai()
Função que irá processar operações de saídas gravadas no livro fiscal

@param		dDataDe	-Data inicial do período de apuração
			dDadaAte	-Data Final do período de apuração
			oApurEFD	-Objeto para as operações com débito já criado 
						 para apurar os valores das notas de saídas
			nM996Tpr	- Conteúdo do parâmetro MV_M996TPR
			cReg		- Define valor receita
			lCPRBNF	- CPRB calculado no documento fiscal	

@author Erick G. Dias
@since 14/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001SFTSai(dDataDe,dDadaAte,oApurEFD,nM996Tpr,cReg,lCPRBNF,cSPCBPSE,cReg2,aXFilial,cFilialMat,lindividu)

local cAliasSFT	:= 'SFT'
local cSlctSFT	:= ''
Local cFiltro	:= ''
local cGroupBy	:= ''
Local cFrom		:= ''
Local lPeWhere	:= ExistBlock("EFDCON01")
Local lPeBase	:= ExistBlock("EFDCON02")
Local nBaseCalc	:= 0
Local lValdAux	:= .F.
Local lAtuCPRB	:= .F.
Local lMoto		:= .F.
Local nReceita	:= 0
Local cRegime	:= ""

DbSelectArea (cAliasSFT)
(cAliasSFT)->(DbSetOrder(2))
cAliasSFT	:=	GetNextAlias()

//traz campos para fazer from e join 
cFrom    := oApurEFD:GetJoinFrm(nM996Tpr,lPeWhere,NFSAIDA)
//Chama método para retornar campos de forma agrupada
cSlctSFT := oApurEFD:GetCmpSFT(nM996Tpr,!lPeWhere)
//Chama método para voltar filtro das operações de saídas
cFiltro  := oApurEFD:GetWhrSFT(NFSAIDA)

//VERIFICA SE EXISTE PONTO DE ENTRADA PARA PERMITIR ALTERAÇÃO NO WHERE DA QUERY
If lPeWhere
	cFiltro	:= ExecBlock("EFDCON01",.F.,.F.,{cFiltro})
EndIF

cFiltro := '%' + cFiltro + '%'

//Chama método para retornar group by de saída
If !lPeWhere .AND. !lPeBase
	//Caso seja efetuado join com SC5, não deverá realizar group by
	cGroupBy	:=	oApurEFD:GetGrpSFT(nM996Tpr)
EndIF
cGroupBy := '%' + cGroupBy + '%'
BeginSql Alias cAliasSFT
	COLUMN FT_DTFIMNT AS DATE
	SELECT
		%Exp:cSlctSFT%

	FROM
		%Exp:cFrom%

	WHERE
		%Exp:cFiltro%
		SFT.%NotDel%

	%Exp:cGroupBy%

EndSql

DbSelectArea (cAliasSFT)
(cAliasSFT)->(DbGoTop ())
ProcRegua ((cAliasSFT)->(RecCount ()))

If lCPRBNF
	oCPRB:=CPRBEFD():New()
	oCPRB:SetDtIni(dDataDe)
	oCPRB:SetFilial(aXFilial)
Endif

Do While !(cAliasSFT)->(Eof ())

	lValdAux	:= .T.
	If lPeBase
		nBaseCalc := 0
		nBaseCalc := ExecBlock("EFDCON02",.F.,.F.,{cAliasSFT})
		//Processa ponto de entrada passando chave da nota
		//Se retornar valor zero, deverá pular a geração desta nota
		If nBaseCalc == 0
			lValdAux := .F.
		EndIf
	EndIF

	If oApurEFD:ChkRegraNf((cAliasSFT)->FT_ESPECIE,(cAliasSFT)->FT_CFOP,NFSAIDA) .AND. lValdAux

		//---------------------
		//Informações da nota
		//---------------------
		oApurEFD:SetOrigem(FISCALSAI)
		oApurEFD:SetCFOP(	(cAliasSFT)->FT_CFOP)
		nReceita:= Iif(cReg == 2 .And. cReg2 == 1,(cAliasSFT)->FT_VALCONT + (cAliasSFT)->FT_DESCONT,(cAliasSFT)->FT_TOTAL+Iif((cAliasSFT)->FT_TIPO <> "D",(cAliasSFT)->FT_DESCZFR,0))
		oApurEFD:SetReceita(nReceita)
		oApurEFD:SetEspecie((cAliasSFT)->FT_ESPECIE)
		oApurEFD:SetTNatRec((cAliasSFT)->ft_tnatrec)
		oApurEFD:SetCNatRec((cAliasSFT)->ft_cnatrec)
		oApurEFD:SetGNatRec((cAliasSFT)->ft_gruponc)
		oApurEFD:SetDNatRec((cAliasSFT)->FT_DTFIMNT)
		oApurEFD:SetQtde((cAliasSFT)->FT_QUANT)
		If cReg == 4
			oApurEFD:SetTpReg(DefRegime(nM996Tpr,cAliasSFT))
		EndIF

		//Verifica se operação de motocicleta
		lMoto	:= Iif((cAliasSFT)->ft_tnatrec  == '4312' .AND. SubStr((cAliasSFT)->ft_cnatrec,1,2) $ '20/30',.T.,.F.)
		//--------------------
		//Informações do PIS
		//--------------------
		oApurEFD:SetTributo(PIS)
		oApurEFD:SetCST((cAliasSFT)->FT_CSTPIS)
		oApurEFD:SetAlqTrib((cAliasSFT)->FT_ALIQPIS)
		oApurEFD:SetBcTrib((cAliasSFT)->FT_BASEPIS)
		oApurEFD:SetValTrib((cAliasSFT)->FT_VALPIS)
		oApurEFD:SetBaseST((cAliasSFT)->FT_BASEPS3)
		oApurEFD:SetValST((cAliasSFT)->FT_VALPS3)
		oApurEFD:SetAlqSt((cAliasSFT)->FT_ALIQPS3)
		oApurEFD:SetVlPauta((cAliasSFT)->ft_pautpis)
		oApurEFD:SetConta((cAliasSFT)->FT_CONTA)
		IF lPeBase
			oApurEFD:SetBcTrib(nBaseCalc)
			oApurEFD:SetValTrib(nBaseCalc *(cAliasSFT)->FT_ALIQCOF / 100)
		EndIF

		oApurEFD:AgrpContr()

		//----------------------
		//Informações da COFINS
		//----------------------
		oApurEFD:SetTributo(COFINS)
		oApurEFD:SetCST((cAliasSFT)->FT_CSTCOF)
		oApurEFD:SetAlqTrib((cAliasSFT)->FT_ALIQCOF)
		oApurEFD:SetBcTrib((cAliasSFT)->FT_BASECOF)
		oApurEFD:SetValTrib((cAliasSFT)->FT_VALCOF)
		oApurEFD:SetBaseST((cAliasSFT)->FT_BASECF3)
		oApurEFD:SetValST((cAliasSFT)->FT_VALCF3)
		oApurEFD:SetAlqSt((cAliasSFT)->FT_ALIQCF3)
		oApurEFD:SetVlPauta((cAliasSFT)->ft_pautCOF)
		oApurEFD:SetConta((cAliasSFT)->FT_CONTA)
		IF lPeBase
			oApurEFD:SetBcTrib(nBaseCalc)
			oApurEFD:SetValTrib(nBaseCalc *(cAliasSFT)->FT_ALIQCOF / 100)
		EndIF

		oApurEFD:AgrpContr()

		//Grava CST PIS COFINS ST
		IF lMoto
			oApurEFD:SetCST((cAliasSFT)->FT_CSTCOF)
			oApurEFD:SetBcTrib((cAliasSFT)->FT_BASECF3)
			oApurEFD:SetReceita(0)
			cRegime:= oApurEFD:self:CREGIMEOPE //Quando for PIS COFINS ST Sempre grava como cumulativo Aliq: 0.65 e 3
			oApurEFD:self:CREGIMEOPE := '2'
			oApurEFD:GrvResCST()
			
			//Restauda valores			
			oApurEFD:self:CREGIMEOPE := cRegime
			oApurEFD:SetCST('01') //processa substituição tributária de motocicleta adicionando cst 01
			oApurEFD:SetBcTrib((cAliasSFT)->FT_BASECOF)
			oApurEFD:SetReceita(nReceita)
		Endif

		//--------------------
		//Informações da CPRB
		//--------------------
		If lCPRBNF
			//Verifica parâmetro para definir se utilizará código de serviço ou de outros serviços.
			lAtuCPRB := .T.
			oCPRB:SetDtRefer(dDataDe)
			oCPRB:SetCodAtiv((cAliasSFT)->FT_ATIVCPB)
			oCPRB:SetVlBrut((cAliasSFT)->FT_VALCONT)
			oCPRB:SetVlExcl((cAliasSFT)->FT_VALIPI+(cAliasSFT)->FT_ICMSRET)
			oCPRB:SetVlCPRB((cAliasSFT)->FT_VALCPB)
			oCPRB:SetAliq((cAliasSFT)->FT_ALIQCPB)
			oCPRB:SetBase((cAliasSFT)->FT_BASECPB)
			oCPRB:SetVlAtiv((cAliasSFT)->FT_VALCONT)
			oCPRB:SetConta((cAliasSFT)->FT_CONTA)
			oCPRB:SetCodRec(Iif(AllTrim((cAliasSFT)->FT_ATIVCPB)$cSPCBPSE,mv_par16,mv_par17)) 
			oCPRB:SetFilApu(IIf(lIndividu,oCPRB:BuscaxFil('CKY'),cFilialMat)) 
			oCPRB:AgrupaCPRB()
		Endif

		//Passo FT_VALCONT neste trecho somente para que a primeira aba da apuração o valor da receita seja o valor contábil, considerando
		//valores de despesas acessórias, frete,seguro, desconto etc...
		oApurEFD:SetReceita((cAliasSFT)->FT_VALCONT )
		oApurEFD:GrvResCST()

	EndIF

	(cAliasSFT)->(DbSkip ())
EndDo

If lCPRBNF .And. lAtuCPRB
	//Grava os valores alterados.
	oCPRB:GravaCPRB()
Endif

oApurEFD:FechaAlias(cAliasSFT)

//FINALIZA GRAVAÇÃO DAS RECEITAS.
oApurEFD:Finaliza('1')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001Difer()
Função que irá buscar valores de diferimento dos débitos para serem processados
na apuração

@param		dDataDe	-Data inicial do período de apuração
			dDataAte	-Data final do período de apuração
			aXFilial	-Array com conteúdo do xFilial das tabelas da apuração			

@author Erick G. Dias
@since 14/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001Difer(dDataDe,dDataAte,aXFilial)
Local cAliasCFA			:= 'CFA'
Local cAliasCFB			:= 'CFB'
Local	aTpContr		:=	{"PIS","COF"}
Local cSelect			:= ''
Local cWhere			:= ''
Local	cPeriod			:=	Substr(DTOS(dDataDe),5,2)+Substr(DTOS(dDataDe),1,4)
Local nCont				:= 0
Local oDifer			
Local lNewProc			:= ISA001NDIF()   

//Cria objeto para tratar os valores da apuração
oDifer 	:= DIFPISCOF():New()
oDifer:SetFilial(aXFilial)
oDifer:SetDtIni(dDataDe)
oDifer:LoadDebito()
oDifer:LoadCredit()

For nCont := 1 to Len(aTpContr)
	
	cAliasCFA	:=	GetNextAlias()
	cSelect		:=	"%CFA.CFA_CODCON, CFA.CFA_TPCON, CFA.CFA_CNPJ, CFA.CFA_TOTVEN, CFA.CFA_VLNREC, CFA.CFA_CONDIF, "
	cSelect		+=	"CFA.CFA_PERAPU, CFA.CFA_ALIQ, CFA_CREDIF, CFA_CODCRE%"
	cWhere		:=	"%CFA.CFA_FILIAL='"+xFilial("CFA")+"' AND "
	cWhere		+=	"CFA.CFA_PERAPU='"+cPeriod+"' AND "
	cWhere		+=	"CFA.CFA_TPCON='"+aTpContr[nCont]+"' AND "
	
	IF lNewProc
		cWhere		+=	"CFA.CFA_CONSOL= '2' AND "
	EndIF
	
	cWhere		+= "%"
	
	BeginSql Alias cAliasCFA   	
	    
		SELECT			    	 
			%Exp:cSelect%		
	
		FROM 
			%Table:CFA% CFA													
		WHERE
			%Exp:cWhere%
			CFA.%NotDel%	
	EndSql
		
	DbSelectArea (cAliasCFA)
	(cAliasCFA)->(DbGoTop ())
	Do While !(cAliasCFA)->(Eof ())	
		//-------------------------------------------------------------------------------
		//Processa informações da tabela CFA, referente ao diferimento do próprio período
		//-------------------------------------------------------------------------------		
					
		oDifer:SetTributo(Iif(nCont == 1,PIS,COFINS))
		oDifer:SetTpDif('1') //Indica diferimento de valores do período de débito
		oDifer:SetCodigo((cAliasCFA)->CFA_CODCON)
		oDifer:SetAliq((cAliasCFA)->CFA_ALIQ)
		oDifer:SetVlDif((cAliasCFA)->CFA_CONDIF)
		oDifer:Diferir()
		
		//Faz diferimento dos valores dos créditos
		oDifer:SetTributo(Iif(nCont == 1,PIS,COFINS))
		oDifer:SetTpDif('1') //Indica diferimento de valores do período
		oDifer:SetCodigo((cAliasCFA)->CFA_CODCRE)
		oDifer:SetVlDif((cAliasCFA)->CFA_CREDIF)
		oDifer:Diferir()			
		
		(cAliasCFA)->(DbSkip())
	EndDo
	
	oDifer:FechaAlias(cAliasCFA)
	
	cAliasCFB	:=	GetNextAlias()
	cSelect		:=	"%CFB.CFB_CODCON, CFB.CFB_TPCON, CFB.CFB_DTPGTO, CFB.CFB_PERDIF, CFB.CFB_CONREC, "
	cSelect		+=	"CFB.CFB_PERAPU, CFB.CFB_ALIQ,CFB.CFB_NATCRE, CFB.CFB_CREDES%"
	cWhere		:=	"%CFB.CFB_FILIAL='"+xFilial("CFB")+"' AND "
	cWhere		+=	"CFB.CFB_PERAPU='"+cPeriod+"' AND "
	cWhere		+=	"CFB.CFB_TPCON='"+aTpContr[nCont]+"' AND "

	IF lNewProc
		cWhere		+=	"CFB.CFB_CONSOL='2' AND "
	EndIF
	
	cWhere		+= "%"
		
	BeginSql Alias cAliasCFB   	
	    
		SELECT			    	 
			%Exp:cSelect%		
	
		FROM 
			%Table:CFB% CFB													
		WHERE
			%Exp:cWhere%
			CFB.%NotDel%	
	EndSql
	
	DbSelectArea (cAliasCFB)
	(cAliasCFB)->(DbGoTop ())
	Do While !(cAliasCFB)->(Eof ())	

		//-------------------------------------------------------------------------------
		//Processa informações da tabela CFA, referente ao diferimento de período anterior
		//-------------------------------------------------------------------------------
		
		oDifer:SetTributo(Iif(nCont == 1,PIS,COFINS))
		oDifer:SetTpDif('2') //Indica diferimento de período anterior
		oDifer:SetCodigo((cAliasCFB)->CFB_CODCON)
		oDifer:SetAliq((cAliasCFB)->CFB_ALIQ)
		oDifer:SetVlDif((cAliasCFB)->CFB_CONREC - (cAliasCFB)->CFB_CREDES )
		oDifer:Diferir()				
		
		(cAliasCFB)->(DbSkip())
	EndDo

	oDifer:FechaAlias(cAliasCFB)

Next nCont


//-------------------------------------------------------------------------------
//CHAMA FUNÇÃO PARA PROCESSAR OS VALORES DE DIFERIMENTO DE PERÍODOS ATUAL
//-------------------------------------------------------------------------------
If ExistBlock("SPDPCD") 
	A001PEDFAT(dDataDe,dDataAte,oDifer)
EndIF

//-------------------------------------------------------------------------------
//CHAMA FUNÇÃO PARA PROCESSAR OS VALORES DE DIFERIMENTO DE PERÍODOS ANTERIORES
//-------------------------------------------------------------------------------
If ExistBlock("SPDPCANT")
	A001PEDFAN(dDataDe,dDataAte,oDifer)
EndIF

FreeObj(oDifer)
oDifer:= nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001F700()
Função que ir[a buscar os valores de Outras Deduções de PIS e COFINS,
Irá fazer a dedução ou gravar no saldo de deduções.

@param		dDataDe	-Data inicial do período de apuração
			cRegime	-Regime da Apuração escolhido pelo usuário			
			oApurPIS	-Objeto da apuração de PIS
			oApurCof	-Objeto da Apuração da COFINS			
			aXFilial	-Array com conteúdo do xFilial das tabelas de apuração

@author Erick G. Dias
@since 14/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001F700(dDataDe,cRegime,oApurPIS,oApurCof,aXFilial)

Local cSelect			:= ''
Local cWhere			:= ''
Local cAliasCF2		:= ''
Local cIndNat			:= ''
Local cPerido			:= strzero(Month(dDataDe),2)+str(Year(dDataDe),4)
Local oOutDed

oOutDed := DEDUCAOPC():New() 
oOutDed:SetFilial(aXFilial)
oOutDed:SetDtIni(dDataDe)
oOutDed:SetTpDed('1') // Indica que será realizado dedução referente a outras deduções.

If cRegime == '1'
	//Exclusivo não cumulativo
	cIndNat	:= '0'
ElseIF cRegime $ '2/3/'
	//Exclusivo Cumulativo
	cIndNat	:= '1'
EndIF

cAliasCF2	:=	GetNextAlias()
cSelect	:=	"%CF2.*%"
cWhere	:=	"%CF2.CF2_FILIAL='"+xFilial("CF2")+"' AND "
cWhere	+=	"CF2.CF2_PER='"+cPerido+"' AND "
If !Empty(cIndNat)
	cWhere	+=	"CF2.CF2_INDNAT='"+cIndNat+"' AND "
Endif
cWhere	+= '%'

BeginSql Alias cAliasCF2   	
    
	SELECT			    	 
		%Exp:cSelect%		

	FROM 
		%Table:CF2% CF2													
	WHERE
		%Exp:cWhere%
		CF2.%NotDel%	
EndSql
	
DbSelectArea (cAliasCF2)
(cAliasCF2)->(DbGoTop ())

If !(cAliasCF2)->(Eof ())

	//Carrega as informações atualizadas da apuração
	oApurPIS:LoadApurPC(PIS)
	
	//Carrega as informações atualizadas da apuração
	oApurCof:LoadApurPC(COFINS)
EndIF


Do While !(cAliasCF2)->(Eof ())

	//---------------------
	//FAZ A DEDUÇÃO DO PIS
	//---------------------
	oOutDed:SetTributo(PIS)
	oOutDed:SetValDed((cAliasCF2)->CF2_DEDPIS)
	oOutDed:SetRegime(IiF((cAliasCF2)->CF2_INDNAT=='0',NAOCUMULAT,CUMULAT))
	oOutDed:Deduz(oApurPIS)

	//------------------------
	//FAZ A DEDUÇÃO DA COFINS
	//------------------------
	oOutDed:SetTributo(COFINS)
	oOutDed:SetValDed((cAliasCF2)->CF2_DEDCOF)
	oOutDed:SetRegime(IiF((cAliasCF2)->CF2_INDNAT=='0',NAOCUMULAT,CUMULAT))
	oOutDed:Deduz(oApurCof)

	(cAliasCF2)->(DBSKIP())
EndDo

oOutDed:FechaAlias(cAliasCF2)

FreeObj(oOutDed)
oOutDed:= NIL		

Return

Static Function GetRetCKY(dDataDe,dDataAte,aXFilial)

Local cAliasCKY	:= ''
Local cSlct		:= ''
Local cFrom		:= ''
Local cFiltro		:= ''
Local cGroupBy	:= ''
Local oEFDGen	:= EFDGEN():New()

oEFDGen:SetFilial(aXFilial)

cSlct	 := "%SUM(CKY.CKY_PISRET) CKY_PISRET , SUM(CKY.CKY_COFRET) CKY_COFRET, CKY_INDRET , CKY_INDREC%"
cFiltro += "%CKY.CKY_FILIAL= '"+ oEFDGen:BuscaxFil('CKY') + "' AND "
cFiltro += "CKY.CKY_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CKY.CKY_PER<= '" + %Exp:DToS (dDataAte)% + "' AND %"

cGroupBy	:=	"%GROUP BY CKY.CKY_INDRET,	CKY_INDREC %"

cAliasCKY	:=	GetNextAlias()

BeginSql Alias cAliasCKY
	SELECT			    	 
		%Exp:cSlct%		

	FROM 
		%Table:CKY% CKY													
	WHERE
		%Exp:cFiltro%
		CKY.%NotDel% 
        
	%Exp:cGroupBy%	
EndSql
 

Return cAliasCKY

Static Function DeduzReten(dDataDe,dDataAte,aXFilial,oApurPis,oApurCof,cCtlDedRet)

Local aF600Aux	:= {}
Local nCont		:= 0
Local cRegime		:= ''
Local dDtAnt		:= firstday(dDataDe) - 1
Local nContAnt	:= 0
Local cPerAnt		:= Strzero(Month(dDtAnt),2)+cvaltochar(Year(dDtAnt))
Local cPerAtu		:= Strzero(Month(dDataDe),2)+cvaltochar(Year(dDataDe))
Local oOutRet	
Local cAliasCKY	:= ''
Local lSaldo	:= .F.	

If cCtlDedRet $ "S|A"  // Controle para execução do bloco de saldos.
	
	For nContAnt := 1 to 2	
		oOutRet := DEDUCAOPC():New() 
		oOutRet:SetFilial(aXFilial)
		oOutRet:SetDtIni(dDataDe)
		oOutRet:SetPergrva(cPerAnt)
		oOutRet:SetTpDed('2') // Indica que será realizado dedução referente a retenção na fonte
		oOutRet:SetTributo(Alltrim(str(nContAnt)))
		oOutRet:LoadSaldo()
		aSaldo	:= oOutRet:GetSldRet()
		oOutRet:SetPergrva(cPerAtu)
		oOutRet:SetProcAnt('1')
		For nCont:= 1 to Len(aSaldo)
		
			//---------------------------
			//FAZ A DEDUÇÃO DO PIS/COFINS
			//---------------------------
			lSaldo := .T.			
			oOutRet:SetTributo(Alltrim(str(nContAnt)))
			oOutRet:SetValDed(aSaldo[nCont][6])
			oOutRet:SetRegime(aSaldo[nCont][4])
			oOutRet:SetNatRet(aSaldo[nCont][1])
			oOutRet:SetMesAno(aSaldo[nCont][3])
			oOutRet:SetPergrva(cPerAtu)
			oOutRet:Deduz(Iif (nContAnt==1 ,oApurPIS ,oApurCOF  ), lSaldo)
		
		Next nCont
		FreeObj(oOutRet)
		oOutRet:= nil
	Next nContAnt

EndIf
If cCtlDedRet $ "R|A" // Controle para execução do bloco de retenção.
	oOutRet := DEDUCAOPC():New() 
	oOutRet:SetFilial(aXFilial)
	oOutRet:SetDtIni(dDataDe)

	oOutRet:SetTpDed('2') // Indica que será realizado dedução referente a retenção na fonte

	oOutRet:SetPergrva(cPerAtu)
	oOutRet:SetMesAno(cPerAtu)
	oOutRet:SetProcAnt('2')
	
	cAliasCKY:= GetRetCKY(dDataDe,dDataAte,aXFilial)
	
	While !(cAliasCKY)->(EOF())
		
		//---------------------
		//FAZ A DEDUÇÃO DO PIS
		//---------------------
		oOutRet:SetTributo(PIS)
		oOutRet:SetValDed((cAliasCKY)->CKY_PISRET)
		oOutRet:SetRegime((cAliasCKY)->CKY_INDREC)
		oOutRet:SetNatRet((cAliasCKY)->CKY_INDRET)		
		
		oOutRet:Deduz(oApurPIS, lSaldo)	
	
		//------------------------
		//FAZ A DEDUÇÃO DA COFINS
		//------------------------
		oOutRet:SetTributo(COFINS)
		oOutRet:SetValDed((cAliasCKY)->CKY_COFRET)
		oOutRet:SetRegime((cAliasCKY)->CKY_INDREC)
		oOutRet:SetNatRet((cAliasCKY)->CKY_INDRET)
			
		oOutRet:Deduz(oApurCof, lSaldo)
		
		(cAliasCKY)->(DbSkip())
		
	EndDo
	oOutRet:FechaAlias(cAliasCKY)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001F600()
Função que irá chamar integração com Financeiro para buscar as informações
de retenções na fonte de PIS e COFINS

@param		dDataDe	-Data inicial do período de apuração
			oApurPIS	-Objeto da apuração de PIS
			oApurCof	-Objeto da Apuração da COFINS			
			aXFilial	-Array com conteúdo do xFilial das tabelas de apuração

@author Erick G. Dias
@since 15/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001F600(dDataDe,oApurPIS,oApurCof,aXFilial,cFilialMat,lIndividu)

Local aF600Aux	:= {}
Local nCont		:= 0
Local cRegime		:= ''
Local dDtAnt		:= firstday(dDataDe) - 1
Local nContAnt	:= 0
Local cPerAnt		:= Strzero(Month(dDtAnt),2)+cvaltochar(Year(dDtAnt))
Local cPerAtu		:= Strzero(Month(dDataDe),2)+cvaltochar(Year(dDataDe))
Local oOutRet
Local oF600		:=	TABELACKY():New() //Cria objeto para gravação do F100

aF600Aux:= FinSpdF600(Month(dDataDe),Year(dDataDe))

For nCont:= 1 To Len(aF600Aux)
	cRegime :=""
	If aF600Aux[nCont][5] == "0"
		cRegime := '2' //cumulativo
	ElseIf aF600Aux[nCont][5] == "1"
		cRegime := '1' //nao cumulativo
	EndIF	
	oF600:SetParam('CKY_PER',dDataDe)
	oF600:SetParam('CKY_INDRET',aF600Aux[nCont][1])
	oF600:SetParam('CKY_DTRET',cTod(SubStr(aF600Aux[nCont][2],7,2)+"/"+SubStr(aF600Aux[nCont][2],5,2)+"/"+SubStr(aF600Aux[nCont][2],1,4)))
	oF600:SetParam('CKY_CODREC',aF600Aux[nCont][12])
	oF600:SetParam('CKY_INDREC',cRegime) 				
	oF600:SetParam('CKY_CNPJ',aF600Aux[nCont][6])		
	oF600:SetParam('CKY_BASE',aF600Aux[nCont][3])		
	oF600:SetParam('CKY_TOTRET',aF600Aux[nCont][4])	
	oF600:SetParam('CKY_PISRET',aF600Aux[nCont][7])	
	oF600:SetParam('CKY_COFRET',aF600Aux[nCont][8])	
	oF600:SetParam('CKY_INDCON',aF600Aux[nCont][9])	
	oF600:SetParam('CKY_FILAPU',IIf(lIndividu,oF600:BuscaxFil('CKY'),cFilialMat))
	If aF600Aux[nCont][10] == 'SE5'
		SE5->(dbGoto( aF600Aux[nCont][11]))		
		oF600:SetParam('CKY_NUMTIT'	,SE5->E5_NUMERO)
		oF600:SetParam('CKY_PREFIX'	,SE5->E5_PREFIXO)
		oF600:SetParam('CKY_PARC'	,SE5->E5_PARCELA)
		oF600:SetParam('CKY_DTEMIS'	,SE5->E5_DTDIGIT)
		oF600:SetParam('CKY_ORIG'	,SE5->E5_ORIGEM)
	EndIF
	oF600:Save()

Next nCont

FreeObj(oF600)
oF600:= nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001PEF100()
Função que irá chamar o ponto de entrada SPDPIS09 e gravar esta informações
na apuração

@param		dDataDe	-Data inicial do período de apuração
			dDadaAte	-Data Final do período de apuração
			oApurSai	-Objeto para as operações com débitos já criado 
						 para apurar os valores dos créditos
			oApurEnt	-Objeto para as operações com créditos já criado 
						 para apurar os valores dos créditos						 	
			lProcCred	-Indica se irá processar operações de crédito			 
			nTotF100	-Campos com somatório das receitas utilizadas 
						 para o F100			
			lPTitEnt	-Indica se irá processar as operações de entrada
			lPTitSai	-Indica se irá processar as operações de saída		

@author Erick G. Dias
@since 21/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001PEF100(dDataDe,dDataAte,oApurSai,oApurEnt,lProcCred,lPTitEnt, lPTitSai,cReg)

Local aPEF100		:= {}
Local x			:= 0

aPEF100 := ExecBlock("SPDPIS09",.F.,.F.,{FWGETCODFILIAL,dDataDe,dDataAte})
For x := 1 To Len(aPEF100)
		                                                        
	If aPEF100[x][2] == "0"  //Entradas
		If lProcCred		
			If lPTitEnt
				//----------------------------
				//Informações da Nota Fiscal
				//----------------------------
				oApurEnt:SetRegime(NAOCUMULAT)			
				oApurEnt:SetReceita(aPEF100[x][6])
				oApurEnt:SetCodBcc(aPEF100[x][15])
		
				//-------------------------
				//Informações de PIS
				//-------------------------			
				oApurEnt:SetOrigem(TITENTRADA)
				oApurEnt:SetTributo(PIS)
				oApurEnt:SetCST(aPEF100[x][7])		
				oApurEnt:SetAlqTrib(aPEF100[x][9])
				oApurEnt:SetBcTrib(aPEF100[x][8])
				oApurEnt:SetValTrib(aPEF100[x][10])
				oApurEnt:SetBaseST(aPEF100[x][8])
				oApurEnt:SetValST(aPEF100[x][10])
				oApurEnt:SetAlqSt(aPEF100[x][9])
				oApurEnt:AgrpCred()	
				//----------------------------
				//Informações da COFINS
				//----------------------------		
				oApurEnt:SetTributo(COFINS)		
				oApurEnt:SetCST(aPEF100[x][11])
				oApurEnt:SetAlqTrib(aPEF100[x][13])
				oApurEnt:SetBcTrib(aPEF100[x][12])
				oApurEnt:SetValTrib(aPEF100[x][14])
				oApurEnt:SetBaseST(aPEF100[x][12])
				oApurEnt:SetValST(aPEF100[x][14])
				oApurEnt:SetAlqSt(aPEF100[x][13])
				oApurEnt:AgrpCred()	
				
				//Agrupa valores para resumo de CST
				oApurEnt:GrvResCST()
			EndIF
		EndIF

	ElseIf lPTitSai
		//---------------------
		//Informações da nota
		//---------------------
		oApurSai:SetOrigem(TITSAIDA)
		oApurSai:SetReceita(aPEF100[x][6])
		oApurSai:SetTNatRec(aPEF100[x][41])
		oApurSai:SetCNatRec(aPEF100[x][42])		
		oApurSai:SetGNatRec(aPEF100[x][43])
		oApurSai:SetDNatRec(aPEF100[x][44])
		If cReg == 4
			oApurSai:SetTpReg(Iif(aPEF100[x][21] == "0",CUMULAT,NAOCUMULAT))
		EndIF

		//--------------------
		//Informações do PIS
		//--------------------		
		oApurSai:SetTributo(PIS)
		oApurSai:SetCST(aPEF100[x][7])		
		oApurSai:SetAlqTrib(aPEF100[x][9])
		oApurSai:SetBcTrib(aPEF100[x][8])
		oApurSai:SetValTrib(aPEF100[x][10])
		oApurSai:SetBaseST(aPEF100[x][8])
		oApurSai:SetValST(aPEF100[x][10])
		oApurSai:SetAlqSt(aPEF100[x][9])
		oApurSai:AgrpContr()	
	
		//----------------------
		//Informações da COFINS
		//----------------------
		oApurSai:SetTributo(COFINS)
		oApurSai:SetCST(aPEF100[x][11])		
		oApurSai:SetAlqTrib(aPEF100[x][13])
		oApurSai:SetBcTrib(aPEF100[x][12])
		oApurSai:SetValTrib(aPEF100[x][14])
		oApurSai:SetBaseST(aPEF100[x][12])
		oApurSai:SetValST(aPEF100[x][14])
		oApurSai:SetAlqSt(aPEF100[x][13])
		oApurSai:AgrpContr()	

		oApurSai:GrvResCST()
			
	EndIF
	 			 
Next x

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001PISSTR()
Função que irá processar as informações de débito do ponto de entrada SPDPISTR

@param		dDataDe 	- Data de início da apuração
			dDataAte 	- Data final da apuração
			oApurSai 	- Objeto de apuração que irá tratar os valores dos débitos
			 	
@author Erick G. Dias
@since 21/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001PISSTR(dDataDe,dDataAte,oApurSai,cReg)

Local aSPDPisTR	:= {}
Local nCont		:= 0

aSPDPisTR := ExecBlock("SPDPISTR",.F.,.F.,{FWGETCODFILIAL,dDataDe,dDataAte}) 

If Len(aSPDPisTR)>0 .AND. !Empty(aSPDPisTR[1])
	For nCont:=1 to Len(aSPDPisTR[01])
		
		//Se não tiver todas as posições no arra não irá processar valores do D350
		If Len(aSPDPisTR[1,nCont]) >= 23
			//---------------------
			//Informações da nota
			//--------------------- 
			oApurSai:Setorigem(OUTROS)
			oApurSai:SetReceita(aSPDPisTR[1,nCont,10])
			oApurSai:SetTNatRec(aSPDPisTR[1,nCont,24])
			oApurSai:SetCNatRec(aSPDPisTR[1,nCont,25])		
			oApurSai:SetGNatRec(aSPDPisTR[1,nCont,26])
			oApurSai:SetDNatRec(aSPDPisTR[1,nCont,27])			
			If cReg== 4
				//-------------------------------------------------------------------------------------------------------------
				//NESTA SITUAÇÃO NA EXISTE NENHUMA INFORMAÇÃO NO PONTO DE ENTRADA PARA DEFINIR QUAL O REGIME
				//SEMPRE FOI PROCESSADO DE FORMA ERRADA QUANDO O REGIME DA APURAÇÃO FOR CUMULATIVO E NÃO CUMULATIVO
				//O LEGAL ESTÁ ERRADO. PARA NÃO TER QUE REALIZAR ALTERAÇÃO NO PONTO DE ENTRADA, IREI UTILIZAR COMO
				//CRITÉRIO AS ALÍQUOTA, JÁ QUE ESTE REGISTRO ACEITA SOMENTE ALÍQUOTA BÁSICA CUMULATIVA OU BÁSICA NÃO CUMULATIVA
				//--------------------------------------------------------------------------------------------------------------				
				oApurSai:SetTpReg(Iif(aSPDPisTR[1,nCont,13] == 0.65,CUMULAT,NAOCUMULAT))

			EndIF
	
	
			//--------------------
			//Informações do PIS
			//--------------------		
			oApurSai:SetTributo(PIS)
			oApurSai:SetCST(aSPDPisTR[1,nCont,11])		
			oApurSai:SetAlqTrib(aSPDPisTR[1,nCont,13])
			oApurSai:SetBcTrib(aSPDPisTR[1,nCont,12])
			oApurSai:SetValTrib(aSPDPisTR[1,nCont,16])
			oApurSai:SetBaseST(aSPDPisTR[1,nCont,12])
			oApurSai:SetValST(aSPDPisTR[1,nCont,16])
			oApurSai:SetAlqSt(aSPDPisTR[1,nCont,13])
			oApurSai:AgrpContr()	
		
			//----------------------
			//Informações da COFINS
			//----------------------
			oApurSai:SetTributo(COFINS)
			oApurSai:SetCST(aSPDPisTR[1,nCont,17])		
			oApurSai:SetAlqTrib(aSPDPisTR[1,nCont,19])
			oApurSai:SetBcTrib(aSPDPisTR[1,nCont,18])
			oApurSai:SetValTrib(aSPDPisTR[1,nCont,22])
			oApurSai:SetBaseST(aSPDPisTR[1,nCont,18])
			oApurSai:SetValST(aSPDPisTR[1,nCont,22])
			oApurSai:SetAlqSt(aSPDPisTR[1,nCont,19])
			oApurSai:AgrpContr()	
	
			oApurSai:GrvResCST()

		EndIF	
   				
	Next nCont 
EndIF
	  
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001PEDFAN()
Função que irá processar os valores de difermento de períodos anteriores
tratando os valores de origem do ponto de entrada SPDPCANT

@param		dDataDe 	- Data de início da apuração
			dDataAte 	- Data final da apuração
			oDifer	 	- Objeto de apuração que irá tratar os valores de diferimento
			 	
@author Erick G. Dias
@since 21/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------

Static Function A001PEDFAN(dDataDe,dDataAte,oDifer)

Local aSPDPCAnt	:= {}
Local aRegMX00	:= {}
Local nCont		:= 0

//-----------------------------------------------------------------------------------
//FAZ CHAMADA PARA O PONTO DE ENTRADA DE CONTRIBUIÇÃO DIFERIDA EM PERÍODOS ANTERIORES
//-----------------------------------------------------------------------------------
aSPDPCAnt := ExecBlock("SPDPCANT", .F., .F., { aRegM300,aRegM700,dDataDe,dDataAte } )

//------------------------------------------------------------------
//PROCESSA OS VALORES DE PIS DIFERIDO COM ORIGEM DO PONTO DE ENTRADA
//------------------------------------------------------------------
aRegMX00	:= aSPDPCAnt[1]	//Valores de PIS
For nCont:= 1 to len(aRegMX00)
	oDifer:SetTributo(PIS)	//PIS
	oDifer:SetTpDif('2') 		//Indica diferimento de período anterior
	oDifer:SetCodigo(aRegMX00[nCont][2])
	oDifer:SetVlDif(aRegMX00[nCont][6])
	oDifer:Diferir()
Next nCont

//---------------------------------------------------------------------
//PROCESSA OS VALORES DE COFINS DIFERIDO COM ORIGEM DO PONTO DE ENTRADA
//---------------------------------------------------------------------
aRegMX00	:= aSPDPCAnt[2] //Valores da COFINS
For nCont:= 1 to len(aRegMX00)
	oDifer:SetTributo(COFINS)	//COFINS
	oDifer:SetTpDif('2') 		//Indica diferimento de período anterior
	oDifer:SetCodigo(aRegMX00[nCont][2])
	oDifer:SetVlDif(aRegMX00[nCont][6])
	oDifer:Diferir()
Next nCont

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001PEDFAT()
Função que irá processar os valores de difermento do período atual

@param		dDataDe 	- Data de início da apuração
			dDataAte 	- Data final da apuração
			oDifer	 	- Objeto de apuração que irá tratar os valores de diferimento
			 	
@author Erick G. Dias
@since 21/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001PEDFAT(dDataDe,dDataAte,oDifer)

Local aSPDDif	:= {}
Local nX		:= 0

aSPDDif := ExecBlock("SPDPCD", .F., .F., { dDataDe, dDataAte } )

If Len(aSPDDif) > 0 .And. Len(aSPDDif[1])>0
				
	//-----------------------
	//PROCESSA VALORES DE PIS
	//-----------------------
	For nX:=1 to Len(aSPDDif[1])		
		oDifer:SetTributo(PIS) //PIS
		oDifer:SetTpDif('1') //Indica diferimento de valores do período de débito
		oDifer:SetCodigo(aSPDDif[1][nX][1])
		oDifer:SetAliq(aSPDDif[1][nX][3])
		oDifer:SetVlDif(aSPDDif[1][nX][7])
		oDifer:Diferir()
		
	Next nX
	
	//--------------------------
	//PROCESSA VALORES DA COFINS
	//--------------------------
	For nX:=1 to Len(aSPDDif[2])
		
		oDifer:SetTributo(COFINS) //COFINS
		oDifer:SetTpDif('1') //Indica diferimento de valores do período de débito
		oDifer:SetCodigo(aSPDDif[2][nX][1])
		oDifer:SetAliq(aSPDDif[2][nX][3])
		oDifer:SetVlDif(aSPDDif[2][nX][7])
		oDifer:Diferir()
		
	Next nX

EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001IMOB()
Função que irá tratar sobre os valores de débitos do registro F200
e dos créditos dos registros F205 e F210.
Foi mantido o legado da rotina spedpiscof, por este motivo estãá sendo
tratado com diversos arrays e loops.

@param		dDataDe 	- Data de início da apuração
			dDataAte 	- Data final da apuração
			oApurSai  - Objeto de apuração do débito
			oApurEnt  - Objeto de apuração do crédito
			lProcCred - Indica se os créditos deverão ser processados
			 	
@author Erick G. Dias
@since 22/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001IMOB(dDataDe,dDataAte,oApurSai,oApurEnt,lProcCred,cReg)

Local aRetImob		:= {}
Local nX				:= 0
Local nY				:= 0
Local cCumulat   		:= '1'
Local aRegF200		:= {} 
Local aRegF205		:= {}
Local aRegF210		:= {}
Local nPost			:= 0

aRetImob :=ExecBlock("SPDPCIMOB",.F.,.F.,{{},dDataDe,dDataAte})
    		    
If Len(aRetImob)>0 .And. ValType(aRetImob[1]) == "A" 	

	For nX:=1 To Len(aRetImob[1])
	
		//-------------------------------------------------------------------
		//Processa primeiro informações do F200 que são referente aos débitos
		//-------------------------------------------------------------------
		aRegF200	:= aRetImob[1][nX]
		//---------------------
		//Informações da nota
		//---------------------		
		cCumulat	:= '1'
		If aRegF200[Len(aRegF200)] == "0" //Regime Cumulativo
			cCumulat	:= '2'
		EndIf
 
		oApurSai:SetReceita(aRegF200[11])
		If cReg == 4			 
			oApurSai:SetTpReg(Iif(aRegF200[23] == "0",'1','2'))
		EndIF
		
		//--------------------
		//Informações do PIS
		//--------------------		
		oApurSai:Setorigem(OUTROS)
		oApurSai:SetTributo(PIS)
		oApurSai:SetCST(aRegF200[12])		
		oApurSai:SetAlqTrib(aRegF200[14])
		oApurSai:SetBcTrib(aRegF200[13])
		oApurSai:SetValTrib(aRegF200[15])
		oApurSai:AgrpContr()
		
		//---------------------
		//Informações DA COFINS
		//---------------------
		oApurSai:SetTributo(COFINS)
		oApurSai:SetCST(aRegF200[16])		
		oApurSai:SetAlqTrib(aRegF200[18])
		oApurSai:SetBcTrib(aRegF200[17])
		oApurSai:SetValTrib(aRegF200[19])
		oApurSai:AgrpContr()
		oApurSai:setImob(.T.)
		oApurSai:GrvResCST()

		IF lProcCred
			//---------------------------------------------------------------------------------------
			//Processa primeiro informações do F205 que são referente aos créditos de custo incorrido
			//---------------------------------------------------------------------------------------
			If Len(aRetImob)>1 .And. ValType(aRetImob[2]) == "A" .And. Len(aRetImob[2])>=nX .And. ValType(aRetImob[2][nX])=="A" .And. Len(aRetImob[2][nX])>18 .And. aRetImob[2][nX][2]=="F205"
				aRegF205	:= aRetImob[2][nX]
			
				//-------------------------------------------------------------------
				//Informações da Nota Fiscal
				//-------------------------------------------------------------------
				oApurEnt:Setorigem(OUTROS)
				oApurEnt:SetRegime(NAOCUMULAT)  //observação : Ajustar para verificar o regime da nota fiscal			
				oApurEnt:SetReceita(aRegF205[6])
				oApurEnt:SetCodBcc('15') //Código exclusivo para crédito de custo incorrido na unidade imobiliária
		
				//-------------------------------------------------------------------
				//Informações de PIS
				//-------------------------------------------------------------------			
				oApurEnt:SetTributo(PIS)
				oApurEnt:SetCST(aRegF205[7])		
				oApurEnt:SetAlqTrib(aRegF205[8])
				oApurEnt:SetBcTrib(aRegF205[6])
				oApurEnt:SetValTrib(aRegF205[11])
				oApurEnt:AgrpCred()		
		
				//-------------------------------------------------------------------
				//Informações da COFINS
				//-------------------------------------------------------------------		
				oApurEnt:SetTributo(COFINS)		
				oApurEnt:SetCST(aRegF205[13])
				oApurEnt:SetAlqTrib(aRegF205[14])
				oApurEnt:SetBcTrib(aRegF205[6])
				oApurEnt:SetValTrib(aRegF205[17])
				oApurEnt:AgrpCred()		
				
				//Agrupa valores para resumo de CST
				oApurEnt:GrvResCST()
									 				 	
			EndIf
		
			//---------------------------------------------------------------------------------------
			//Processa primeiro informações do F205 que são referente aos créditos de custo orçado
			//---------------------------------------------------------------------------------------
			If Len(aRetImob)>2 .And. ValType(aRetImob[3]) == "A" 
				aRegF210	:= aRetImob[3]
				
				nPost := aScan(aRegF210,{|x| x[1] == nX})
				
				If Len(aRegF210) > 0 .AND. nPost > 0
				
					For nY:=nPost To Len(aRegF210) 
						If ValType(aRegF210[nY])=="A" .AND. Len(aRegF210[nY]) > 11 .AND. aRegF210[nY][1] == nX .AND. aRegF210[nY][2] == "F210" 
		
							//-------------------------------------------------------------------
							//Informações da Nota Fiscal
							//-------------------------------------------------------------------
							oApurEnt:Setorigem(OUTROS)
							oApurEnt:SetRegime(NAOCUMULAT)			
							oApurEnt:SetReceita(aRegF210[nY][5])
							oApurEnt:SetCodBcc('16') //Código exclusivo para crédito de custo incorrido na unidade imobiliária
					
							//-------------------------------------------------------------------
							//Informações de PIS
							//-------------------------------------------------------------------			
							oApurEnt:SetTributo(PIS)
							oApurEnt:SetCST(aRegF210[nY][6])		
							oApurEnt:SetAlqTrib(aRegF210[nY][7])
							oApurEnt:SetBcTrib(aRegF210[nY][5])
							oApurEnt:SetValTrib(aRegF210[nY][8])
							oApurEnt:AgrpCred()		
					
							//-------------------------------------------------------------------
							//Informações da COFINS
							//-------------------------------------------------------------------		
							oApurEnt:SetTributo(COFINS)		
							oApurEnt:SetCST(aRegF210[nY][9])
							oApurEnt:SetAlqTrib(aRegF210[nY][10])
							oApurEnt:SetBcTrib(aRegF210[nY][5])
							oApurEnt:SetValTrib(aRegF210[nY][11])
							oApurEnt:AgrpCred()		
							
							//Agrupa valores para resumo de CST
							oApurEnt:GrvResCST()
			 
						EndIf
					Next
					
				EndIF
		
			EndIf 
		EndIF
	Next nX
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001FOLHA()
Função que irá gravar os valores referente ao PIS Folha de Salário,
gerado através da integração com módulo de RH.

@param		dDataDe 	- Data de início da apuração
			dDataAte 	- Data final da apuração
			oApurEFD	- Objeto de apuração

			 	
@author Erick G. Dias
@since 23/05/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001FOLHA(dDataDe,dDataAte,oApurEFD)

Local aM350Aux	:= {}

If FindFunction("fM350VlPis")

	aM350Aux:=fM350VlPis( FWGETCODFILIAL, FWGETCODFILIAL, dDataDe, dDataAte)
	IF Len(aM350Aux) > 0 .AND. aM350Aux[1][6] > 0
		oApurEFD:SetOrigem(OUTROS)
		oApurEFD:SetReceita(aM350Aux[1][2])
		oApurEFD:SetTributo(PIS)
		oApurEFD:SetCST('')		
		oApurEFD:SetAlqTrib(aM350Aux[1][5])
		oApurEFD:SetBcTrib(aM350Aux[1][4])
		oApurEFD:SetValTrib(aM350Aux[1][6])
		oApurEFD:SetExclPis(aM350Aux[1][3])
		oApurEFD:SetPisFolh('1')
		oApurEFD:AgrpContr()
		oApurEFD:SetExclPis(0)
		oApurEFD:SetTpReg(' ')
	EndIF
	
EndIF 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001BlocoI()
Função que irá processar as informações referente ao Bloco I
Instituições Financeiras

@param		dDataDe 	- Data de início da apuração
			dDataAte 	- Data final da apuração
			oApurSai	- Objeto de apuração
			aXFilial	-Array com conteúdo xFilial das tabelas de apuração
				
@author Erick G. Dias
@since 17/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001BlocoI(dDataDe,dDataAte,oApurSai,aXFilial,cFilialMat)
Local cIntegra	:= SuperGetMv("MV_INTBLCI",.F.,"")
Local nCont		:= 0
Local cAliasI		:= ''
Local lProc		:= .F.
Local lI300		:= .F.
Local oI100		:= TABELACL5():New()
Local oI200I300	:= TABELACL6():New()
Local oRecNTrib	:= TABELACKT():New()
Local lF07				:= AliasINdic('F07')
Local lRecnoTit	:= .F.
Local cNumTit		:= ''
Local cPrefixo	:= ''
Local cParcela	:= ''

ObjF0T	:= TABELAF0T():New()

oI100:SetFilial(aXFilial)
oI200I300:SetFilial(aXFilial)
oRecNTrib:SetFilial(aXFilial)
dbSelectArea("CCZ")
dbSetOrder(1)

For nCont :=1 to 2
	cAliasI	:= GetNextAlias()
	lProc	:= .F.	
	If nCont ==1 .and. cIntegra $ "1/3" .AND. FindFunction("FinSpdBlcI") 
		//Função do Financeiro
		FinSpdBlcI(Month(dDataDe),Year(dDataDe),cAliasI)
		lProc	:= .T.
	ElseIF nCont ==2 .and. cIntegra $ "2/3" .AND. FindFunction("PLSPISCOF")
		//Função de Saúde		
		 lProc:=PLSPISCOF(dDataDe,dDataAte,cAliasI)		 
	EndIF
	
	If lProc		
		(cAliasI)->(dbGoTop())
		lRecnoTit	:= .F.
		lRecnoTit	:=  nCont ==1 .AND. (cAliasI)->(ColumnPos('RECNO')) > 0 .AND. (cAliasI)->(ColumnPos('ALIAS')) > 0
		While !(cAliasI)->(EOF())

			aParNaoTri	:= {}
			nValRec	:= 0
			cExclGer	:= 0
			cExclEsp	:= 0
			nAlqPis	:= 0
			nAlqCof 	:= 0
			n713714	:= 0
			cCst		:= ""
			cInf		:= ""
			cCampo		:= ""
			c711712	:= ""
			c713714	:= ""
			cConta		:= ""
			cNota		:= ""
			cSerie		:= ""
			cClieFor	:= ""
			cLoja		:= ""
			lI300		:= .F.
			cIndProc	:= ''
			cProcRef	:= ''
			cNumTit		:= ''
			cPrefixo	:= ''
			cParcela	:= ''
			
			If nCont ==1	//Valores Financeiro
				nValRec	:= (cAliasI)->VALOR	
				cCst		:= (cAliasI)->CSTPIS
				nAlqPis	:= (cAliasI)->ALIQPIS
				nAlqCof	:= (cAliasI)->ALIQCOF			
				cConta		:= (cAliasI)->CONTA
				IF !Empty((cAliasI)->CDRECA)
					c711712	:= Substr((cAliasI)->CDRECA,1,5)
					c713714	:= (cAliasI)->CDRECA
					IF Len(Alltrim((cAliasI)->CDRECA)) == 8
						lI300 := .T.
					EndIF				
				Elseif !Empty((cAliasI)->CDDEDA)
					c711712	:= Substr((cAliasI)->CDDEDA,1,5)
					c713714	:= (cAliasI)->CDDEDA				
					IF Len(Alltrim((cAliasI)->CDDEDA)) == 8
						lI300 := .T.
					EndIF														
				EndIF				
				cProcRef	:= (cAliasI)->NUMPRO
				cIndProc	:= (cAliasI)->INDPRO				
				cTnatRec	:= (cAliasI)->TABCCZ
				cCnatRec	:= (cAliasI)->CODCCZ
				cGrpRec	:= (cAliasI)->GRUCCZ 
				dDtNatRec	:= (cAliasI)->DTFCCZ			
			ElseIF nCont ==2  //Valores Saúde
				nValRec	:= (cAliasI)->VALOR
				cCst		:= (cAliasI)->CSTPIS
				nAlqPis	:= (cAliasI)->ALIQPIS
				nAlqCof	:= (cAliasI)->ALIQCOF
				c711712	:=	SubStr((cAliasI)->CLASS,1,5) 
				c713714	:= (cAliasI)->CLASS
				IF Len(Alltrim((cAliasI)->CLASS)) == 8
					lI300 := .T.
				EndIF
				cNota		:= (cAliasI)->NOTA
				cSerie		:= (cAliasI)->SERIE
				cClieFor	:= (cAliasI)->CLIENTE
				cLoja		:= (cAliasI)->LOJA	
				cTnatRec	:= (cAliasI)->NATREC
				cCnatRec	:= (cAliasI)->CNATREC
				cGrpRec	:= (cAliasI)->GRUPONC
				dDtNatRec	:= (cAliasI)->DTFIMNT
				//Comentei a utilização dos campos CONTA e INFO, pois na versão 12 estes campos não são tratados ainda na função PLSPISCOF no PLSXFUN.PRW
				/*cConta		:= (cAliasI)->CONTA
				cInf		:= (cAliasI)->INFO*/
			EndIF
			
			IF !Empty(c711712)		

				If SubStr(c711712,1,1) == "D" //Deduções/Exclusões
					If SubStr(c711712,1,4) == "D000" //Exclusções e Deduções de caráter Geral
						cExclGer	:= nValRec
						nValRec	:= 0	
					Else
						cExclEsp	:= nValRec
						nValRec	:= 0			
					EndIF
				EndIF
				
				If SubStr(c711712 ,1,1) == "R"	//Receita
					cCampo		:= "02"
					n713714	:= nValRec
				ElseIf SubStr(c711712 ,1,4) == "D000" //Dedução Geral
					cCampo		:= "04"
					n713714	:=	cExclGer			
				Else	//Dedução Específica
					cCampo		:= "05"
					n713714	:=	cExclEsp			
				EndIF

				//------------------------------------------------
				//Processa valores para gravar informações do I100
				//------------------------------------------------
				oI100:SetParam('CL5_PER'		,dDataDe)
				oI100:SetParam('CL5_ID'		,'')
				oI100:SetParam('CL5_CST'		,cCst)				
				oI100:SetParam('CL5_ALQPIS'	,nAlqPis)
				oI100:SetParam('CL5_ALQCOF'	,nAlqCof)
				oI100:SetParam('CL5_VLFAT'	,nValRec)
				oI100:SetParam('CL5_NUMNF'	,cNota)
				oI100:SetParam('CL5_SER'		,cSerie)
				oI100:SetParam('CL5_CLIFOR'	,cClieFor)
				oI100:SetParam('CL5_LOJA'	,cLoja)
				oI100:SetParam('CL5_DEDG'	,cExclGer)
				oI100:SetParam('CL5_DEDESP'	,cExclEsp)
				oI100:SetParam('CL5_INDPRO'	,cIndProc)
				oI100:SetParam('CL5_NUMPRO'	,cProcRef)				
				oI100:SetParam('CL5_INFCOM'	,'')				
				oI100:Insert()
								
				//------------------------------------------------
				//Processa valores para gravar informações do I200
				//------------------------------------------------
				oI200I300:SetParam('CL6_PER'		,dDataDe)
				oI200I300:SetParam('CL6_CST'		,cCst)
				oI200I300:SetParam('CL6_ALQPIS'		,nAlqPis)
				oI200I300:SetParam('CL6_ALQCOF'		,nAlqCof)
				oI200I300:SetParam('CL6_REG'		,"I200")
				oI200I300:SetParam('CL6_NUMCPO'		,cCampo)
				oI200I300:SetParam('CL6_CODIGO'		,c711712)
				oI200I300:SetParam('CL6_VALOR'		,n713714)
				oI200I300:SetParam('CL6_CONTA'		,cConta)
				oI200I300:SetParam('CL6_INFCOM'		,cInf)
				oI200I300:Insert()
				
				If lI300				
					//------------------------------------------------
					//Processa valores para gravar informações do I300
					//------------------------------------------------
					oI200I300:SetParam('CL6_PER'		,dDataDe)
					oI200I300:SetParam('CL6_CST'		,cCst)
					oI200I300:SetParam('CL6_ALQPIS'		,nAlqPis)
					oI200I300:SetParam('CL6_ALQCOF'		,nAlqCof)
					oI200I300:SetParam('CL6_REG'		,"I300")
					oI200I300:SetParam('CL6_CODIGO'		,c713714)
					oI200I300:SetParam('CL6_VALOR'		,n713714)
					oI200I300:SetParam('CL6_CONTA'		,cConta)
					oI200I300:SetParam('CL6_INFCOM'		,cInf)
					oI200I300:Insert()
				EndIF				
				
				IF cCst $ "04/06/07/08/09"
					
					If CCZ->(MsSeek(xFilial("CCZ")+ cTnatRec + cCnatRec + cGrpRec  + dDtNatRec))
						//Processa valores não tributados do PIS
						oRecNTrib:SetParam('CKT_PER'	,dDataDe)
						oRecNTrib:SetParam('CKT_TRIB'	,'1')					
						oRecNTrib:SetParam('CKT_CST'	,cCst)					
						oRecNTrib:SetParam('CKT_CODNAT'	,cCnatRec)					
						oRecNTrib:SetParam('CKT_VLREC'	,nValRec)					
						oRecNTrib:SetParam('CKT_CONTA'	,cConta)					
						oRecNTrib:SetParam('CKT_DESCR'	,CCZ->CCZ_DESC)					
						oRecNTrib:Insert()

						//Processa valores não tributados da COFINS						
						oRecNTrib:SetParam('CKT_PER'	,dDataDe)
						oRecNTrib:SetParam('CKT_TRIB'	,'2')					
						oRecNTrib:SetParam('CKT_CST'	,cCst)					
						oRecNTrib:SetParam('CKT_CODNAT'	,cCnatRec)					
						oRecNTrib:SetParam('CKT_VLREC'	,nValRec)					
						oRecNTrib:SetParam('CKT_CONTA'	,cConta)					
						oRecNTrib:SetParam('CKT_DESCR'	,CCZ->CCZ_DESC)					
						oRecNTrib:Insert()						
											
					EndIF
					
				EndIF
				
				//se for integração financeiro e s existir novo campo d financeiro, posicionar no títulos e grava F0T
				If lF07 .AND. lRecnoTit
					IF (cAliasI)->ALIAS == "SE1"							
						SE1->(dbGoto( (cAliasI)->RECNO)	)		
						cNumTit	:= SE1->E1_NUM    
						cPrefixo	:= SE1->E1_PREFIXO
						cParcela	:= SE1->E1_PARCELA
						
					ElseIF (cAliasI)->ALIAS == "SE2"
					
						SE2->(dbGoto( (cAliasI)->RECNO)	)		
						cNumTit	:= SE2->E2_NUM    
						cPrefixo	:= SE2->E2_PREFIXO
						cParcela	:= SE2->E2_PARCELA
									
					ElseIF (cAliasI)->ALIAS == "SE5"
					
						SE5->(dbGoto( (cAliasI)->RECNO)	)		
						cNumTit	:= SE5->E5_NUMERO
						cPrefixo	:= SE5->E5_PREFIXO
						cParcela	:= SE5->E5_PARCELA
						
						
					EndIF			
					ObjF0T:Clear()
					ObjF0T:SetValue("F0T_PER",dDataDe)
					ObjF0T:SetValue("F0T_FILAPU",cFilialMat)
					ObjF0T:SetValue("F0T_TIPO",'8') //Bloco I
					ObjF0T:SetValue("F0T_NUMTIT",cNumTit)
					ObjF0T:SetValue("F0T_PREFIX",cPrefixo)
					ObjF0T:SetValue("F0T_PARC",cParcela)
					ObjF0T:SetValue("F0T_VLCONT",nValRec)
					ObjF0T:SetValue("F0T_IFEXCL",cExclGer + cExclEsp)
					ObjF0T:SetValue("F0T_CDBLCI",c713714)											
					ObjF0T:SetValue("F0T_CSTPIS",cCst)
					ObjF0T:SetValue("F0T_CSTCOF",cCst)
					
					
					ObjF0T:Grava()
				EndIF
				
			EndIF
			(cAliasI)->(dbSkip())
		EndDo

		DbSelectArea(cAliasI)
		dbCloseArea()
		Ferase(cAliasI+GetDBExtension())
		Ferase(cAliasI+OrdBagExt())	

	EndIF

Next nCont

//------------------------------------------------
//Irá processar os valores de I100 considerando as 
//deduções e irá gravar nas tabelas de débitos detalhados
//e consolidados
//------------------------------------------------
oI100:ApurarI100(oApurSai) 
oI100:Save()
FreeObj(oI100)
oI100:= nil

//------------------------------------------------
//Grava informações de I200 e I300 na base de dados
//------------------------------------------------
oI200I300:Save()
FreeObj(oI200I300)
oI200I300:= nil

//-------------------------------------------------------------
//Grava os valores das receitas não tributadas na base de dados
//-------------------------------------------------------------
oRecNTrib:Save()
FreeObj(oRecNTrib)
oRecNTrib:= nil

oApurSai:Finaliza('1')

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001CPRB()
Função que irá realizar a integração módulos de Faturamento, RH ou o Documento Fiscal 
para processamento das informações da CPRB.

@param		dDataDe 	- Data de início da apuração
			dDataAte 	- Data final da apuração
			aXFilial	- Array com conteúdo xFilial das tabelas de apuração
			nTotF100	- Valor total utilizado na geração do registro F100
			 	
@author Erick G. Dias
@since 18/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001CPRB(dDataDe,dDataAte,aXFilial,nTotF100,cFilialMat,lindividu)

Local nTotal		:= 0
Local nAliq		:= 0
Local nContrib	:= 0
Local nExclusao	:= 0
Local nExcluAnt	:= 0
Local nBase		:= 0
Local nDiferenca	:= 0
Local nPos		:= 0
Local cAliasP		:= ''
Local lProcRH 	:= GetNewPar("MV_SPCBPRH",.F.)
Local cSPCBPSE	:= GetNewPar("MV_SPCBPSE",'')
Local oCPRB		:= CPRBEFD():New()
local oCKX		:= TABELACKX():New()
Local aSldExc		:= {}
Local cCodRec		:= ''
Local lProcessou	:= .F.

oCPRB:SetDtRefer(dDataDe)
oCPRB:SetFilial(aXFilial)

//Traz saldo de exclusão de período anterior.
aSldExc:=oCPRB:GetSldExcl()

If lProcRH		// IRÁ PROCESSAR ATRAVÉS DO MÓDULO DE RH
	cAliasP:= fS033Sped(Alltrim(StrZero(Month(dDataDe),2))+Alltrim(Str(Year(dDataDe))) )
Else			// IRÁ PROCESSAR ATRAVÉS DO MÓDULO DE FATURAMENTO
	cAliasP:= RhInssPat(Alltrim(StrZero(Month(dDataDe),2))+Alltrim(Str(Year(dDataDe))))
EndIf

DbSelectArea(cAliasP)
(cAliasP)->(DbSetOrder(1))
(cAliasP)->(dbGoTop())
Do While !(cAliasP)->(Eof ())
	lProcessou	:= .T.
	nExclusao	:= 0
	nDiferenca	:= 0
	nBase		:= 0 
	nExcluAnt	:= 0

	If lProcRH
		nTotal		:= (cAliasP)->TOTAL
		nAliq		:= (cAliasP)->ALIQ
		nContrib	:= (cAliasP)->TOTCONTR
		nExclusao	:= (cAliasP)->(TOTCODAT-TCDEVEXP)
		nBase		:= (cAliasP)->TCDEVEXP
	Else		
		
		//Verifica se existe para este código de atividade saldo de exclusão de período a		
		nPos := aScan(aSldExc,{|x| x[1] == AllTrim((cAliasP)->CODATV)})
		IF nPos > 0
			nExcluAnt	:= aSldExc[nPos][2] //Pega o valor de exclusão de período anterior
			aSldExc[nPos][2] := 0
		EndIF

		//Aqui teremos as exclusões de período anterior com as do período atual.
		nExcluAnt +=	(cAliasP)->(TOTCODAT-TCDEVEXP)
		
		If nExcluAnt> (cAliasP)->TOTCODAT
			//Exclusão é maior que o valor da receita do mês, neste caso teriamos valores negativos
			nExclusao := (cAliasP)->TOTCODAT
			//Guardo a diferença de exclusão para que possa ser transportado para próximo mês.
			nDiferenca	:= nExcluAnt - (cAliasP)->TOTCODAT
		Else
			//A exclusão é menor que o valor da contribuição
			nExclusao	:= nExcluAnt
		EndIF

		nTotal		:= (cAliasP)->TOTAL + nTotF100	
		nAliq		:= SpedPCCG1((cAliasP)->CODATV,dDataAte)
		nBase		:= (cAliasP)->TOTCODAT - nExclusao
		nContrib	:= (nBase *(nAliq/100))
	EndIf

	//Verifica parâmetro para definir se utilizará código de serviço ou de outros serviços.
	cCodRec	:= Iif(AllTrim((cAliasP)->CODATV)$ cSPCBPSE  ,mv_par16  ,mv_par17  )
	
	//Popula objeto para gravar a CPRB
	oCPRB:SetDtRefer(dDataDe)	
	oCPRB:SetCodAtiv(AllTrim((cAliasP)->CODATV))
	oCPRB:SetVlBrut(nTotal)
	oCPRB:SetVlExcl(nExclusao)	
	oCPRB:SetVlCPRB(nContrib)
	oCPRB:SetAliq(nAliq)	
	oCPRB:SetBase(nBase)	
	oCPRB:SetVlAtiv((cAliasP)->TOTCODAT)
	oCPRB:SetConta('')
	oCPRB:SetInform('')
	oCPRB:SetCodRec(cCodRec)
	oCPRB:SetFilApu(IIf(lIndividu,oCPRB:BuscaxFil('CKR'),cFilialMat)) 
	//Grava valores de CPRB
	oCPRB:AgrupaCPRB()
	

	
	If nDiferenca > 0
		//Se houver valor de diferença, quer dizer que existe valor de exclusão maior
		//que a receita do período, e deverá ser gravada e transportada para próximo 
		//período.
		//Irei gravar somente a chave do registro com valor de exclusão. 
				
		oCKX:SetConsol('2')
		oCKX:SetParam('CKX_PER'			,dDataDe)
		oCKX:SetParam('CKX_CODATI'		,AllTrim((cAliasP)->CODATV)	)
		oCKX:SetParam('CKX_CODREC'		,cCodRec)
		oCKX:SetParam('CKX_VLBRUT'		,0)
		oCKX:SetParam('CKX_VLATI'		,0)
		oCKX:SetParam('CKX_EXCLU'		,nDiferenca)
		oCKX:SetParam('CKX_BASE'			,0)
		oCKX:SetParam('CKX_ALIQ'			,0)
		oCKX:SetParam('CKX_VLCPRB'		,0)
		oCKX:SetParam('CKX_CONTA'		,'')
		oCKX:SetParam('CKX_INFORM'		,'')
		oCKX:SetParam('CKX_SALDO'		,'1') //INdica que trata de saldo de exclusão
		oCKX:Insert()
		
	EndIF	

	(cAliasP)->(DbSkip ())
EndDo

If lProcessou .AND. AliasINdic('F0T')
	DetCPRB(dDataDe,dDataAte,cFilialMat,lProcRH)
EndIF

oCPRB:FechaAlias(cAliasP)
oCPRB:GravaCPRB()
FreeObj(oCPRB)
oCPRB:= Nil

oCKX:Save()
FreeObj(oCKX)
oCKX:= Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001TELECO()
Função que irá tratar as operações de telecomunicação a faturar, estas
operações não são gravadas no Livro Fiscal, pois não existe a nota, já que
se trata de serviço pré-pago, a nota fiscal será emitida em período posterior
quando o serviço for faturado.

@param		dDataDe 	- Data de início da apuração
			dDataAte 	- Data final da apuração
			oApurSai	- Objeto de processamento das operações de débito
			cRegime	- Indica qual o regime de PIS e COFINS indicado pelo usuário
			nM996Tpr   - Conteúdo do parâmetro M996TPR			
			 	
@author Erick G. Dias
@since 24/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001TELECO(dDataDe,dDataAte,oApurSai,cRegime,nM996Tpr,cReg)

Local cSlct			:= ""
Local cSlctSD2		:= ""
Local cSlctSF2		:= ""
Local cSlctSF4		:= ""
Local cSlctSFX		:= ""
Local cJoinSD2		:= ""
Local cJoinSF4		:= ""
Local cJoin			:= ""
Local cFiltro			:= ""
Local cAliasSD2		:= "SD2"
Local cAliasSF2		:= "SF2"
Local aFieldDt		:= {}
LOcal lB1Tpreg		:= SB1->(ColumnPos( 'B1_TPREG' ))
Local cCfoTele		:= GetNewPar("MV_CFOTELE",'')  
							
DbSelectArea (cAliasSD2)
(cAliasSD2)->(DbSetOrder (3))

//Campos da tabela SF2
cSlctSF2:= "SF2.F2_ESPECIE,		SF2.F2_SERIE,		SF2.F2_TIPO, 		SF2.F2_CLIENTE,		SF2.F2_LOJA "

If lB1Tpreg	
	cSlctSF2+= ", 	SB1.B1_TPREG "		
EndIF    	

//Campos da tabela SD2
cSlctSD2 := ",SD2.D2_CONTA,		SD2.D2_SERIE,		SD2.D2_VALIMP5,		SD2.D2_BASIMP5 ,	SD2.D2_ALQIMP5,		"
cSlctSD2 +=	"SD2.D2_VALIMP6,	SD2.D2_BASIMP6,		SD2.D2_ALQIMP6,		SD2.D2_DTFIMNT,		SD2.D2_DESC,		"	
cSlctSD2 +=	"SD2.D2_TNATREC,	SD2.D2_CNATREC,		SD2.D2_GRUPONC,		SD2.D2_TOTAL,		SD2.D2_DESPESA,		"	
cSlctSD2 +=	"SD2.D2_SEGURO,	SD2.D2_BASEICM,		SD2.D2_VALICM,		SD2.D2_CLIENTE,		SD2.D2_LOJA,	SD2.D2_CF"


    	
//Campos da TES
cSlctSf4:= ",SF4.F4_CSTPIS, 	SF4.F4_CSTCOF, 		SF4.F4_TPREG "    	

//Campos do complemento de telecomunicacao
cSlctSFX:= ",SFX.FX_TIPOREC, 	SFX.FX_VALTERC,		SFX.FX_GRPCLAS,		SFX.FX_GRPCLAS,		SFX.FX_CLASSIF "    					

//Join com SD2, SF4 e SFX
cJoinSD2	:=	"LEFT JOIN "+RetSqlName("SD2")+" SD2 ON(SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE AND SD2.D2_CLIENTE=SF2.F2_CLIENTE AND SD2.D2_LOJA=SF2.F2_LOJA AND  SD2.D_E_L_E_T_=' ') "		
cJoinSF4	:=	"LEFT JOIN "+RetSqlName("SF4")+" SF4 ON(SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_=' ') "				
cJoinSFX	:=	"LEFT JOIN "+RetSqlName("SFX")+" SFX ON(SFX.FX_FILIAL='"+xFilial("SFX")+"' AND SFX.FX_TIPOMOV = 'S' AND SFX.FX_SERIE = SD2.D2_SERIE AND SFX.FX_DOC = SD2.D2_DOC AND SFX.FX_CLIFOR = SD2.D2_CLIENTE AND SFX.FX_LOJA = SD2.D2_LOJA AND SFX.FX_ITEM = SD2.D2_ITEM  AND SFX.D_E_L_E_T_=' ') "								

cJoin	:=  cJoinSD2 + cJoinSF4 + cJoinSFX   	
cJoin := "%" + cJoin + "%"

cSlct := cSlctSF2+cSlctSD2+cSlctSf4+cSlctSFX

cSlct := "%" + cSlct + "%"											

cFiltro 	:= "%"		
cFiltro		+= "(SF2.F2_ESPECIE = 'NFSC' OR SF2.F2_ESPECIE = 'NTSC' or SF2.F2_ESPECIE = 'NTST') AND SFX.FX_TIPOREC = '6' AND "
cFiltro		+= "SF4.F4_LFICM = 'N' and  SF4.F4_LFIPI = 'N' and  SF4.F4_ISS = 'N'"
cFiltro 	+= "%"
    	    	
aAdd(aFieldDt,"D2_DTFIMNT")
aAdd(aFieldDt,"D2_ENTRADA")
    	
cAliasSF2	:=	GetNextAlias()    	 			
    	
BeginSql Alias cAliasSF2
	
	SELECT			    
		%Exp:cSlct%
	FROM 
		%Table:SF2% SF2
		%Exp:cJoin%
		LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SD2.D2_COD AND SB1.%NotDel%)
		LEFT JOIN %Table:SA1% SA1 ON(SA1.A1_FILIAL=%xFilial:SA1%  AND SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA AND SA1.%NotDel%)						
	WHERE

		SF2.F2_FILIAL=%xFilial:SF2% AND 
		SF2.F2_EMISSAO>=%Exp:DToS (dDataDe)% AND 
		SF2.F2_EMISSAO<=%Exp:DToS (dDataAte)% AND
		%Exp:cFiltro% AND
		SF2.%NotDel% 				
EndSql
	
DbSelectArea (cAliasSF2)
(cAliasSF2)->(DbGoTop ())
ProcRegua ((cAliasSF2)->(RecCount ()))
Do While !(cAliasSF2)->(Eof ())										
	If AllTrim((cAliasSD2)->D2_CF) $ cCfoTele

		//---------------------
		//Informações da nota
		//---------------------
		oApurSai:SetReceita((cAliasSF2)->D2_TOTAL)
		oApurSai:SetOrigem(FISCALSAI)
		oApurSai:SetTNatRec((cAliasSF2)->D2_TNATREC)
		oApurSai:SetCNatRec((cAliasSF2)->D2_CNATREC)		
		oApurSai:SetGNatRec((cAliasSF2)->D2_GRUPONC)
		oApurSai:SetDNatRec((cAliasSF2)->D2_DTFIMNT)			
		If cReg == 4
			oApurSai:SetTpReg(DefRegime(nM996Tpr,cAliasSF2))
		EndIF
	 
		//--------------------
		//Informações do PIS
		//--------------------		
		oApurSai:SetTributo(PIS)
		oApurSai:SetCST((cAliasSF2)->F4_CSTPIS)		
		oApurSai:SetAlqTrib((cAliasSF2)->D2_ALQIMP6)
		oApurSai:SetBcTrib((cAliasSF2)->D2_BASIMP6)
		oApurSai:SetValTrib((cAliasSF2)->D2_VALIMP6)
		oApurSai:AgrpContr()	
	
		//----------------------
		//Informações da COFINS
		//----------------------
		oApurSai:SetTributo(COFINS)
		oApurSai:SetCST((cAliasSF2)->F4_CSTCOF)		
		oApurSai:SetAlqTrib((cAliasSF2)->D2_ALQIMP5)
		oApurSai:SetBcTrib((cAliasSF2)->D2_BASIMP5)
		oApurSai:SetValTrib((cAliasSF2)->D2_VALIMP5)
		oApurSai:AgrpContr()	
	
		oApurSai:GrvResCST()
	EndIF

	(cAliasSF2)->(dbSkip())
EndDo		

oApurSai:FechaAlias(cAliasSF2)

//FINALIZA GRAVAÇÃO DAS RECEITAS.
oApurSai:Finaliza('1')
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001VFORA()
Função que irá processar as operações de venda fora do estabelecimento,
esta operações não estão gravadas no Livro Fiscal, por este motivo será
lido diretamente da SD2.

@param		dDataDe 	- Data de início da apuração
			dDataAte 	- Data final da apuração
			oApurSai	- Objeto de processamento das operações de débito
			cRegime	- Indica qual o regime de PIS e COFINS indicado pelo usuário
			nM996Tpr   - Conteúdo do parâmetro M996TPR			
			 	
@author Erick G. Dias
@since 24/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001VFORA(dDataDe,dDataAte,oApurSai,cRegime,nM996Tpr,cReg)

Local cAliasSD2	:= 'SD2'
Local cAliasSF4	:= 'SF4'
Local cAliasSB1	:= 'SB1'
Local cAliasSF2	:= 'SF2'
Local cSlct		:= ''
Local cSlctSF2	:= ''
Local cJoin		:= ''
Local cJoinSD2	:= ''
Local cJoinSF4 	:= ''
Local cFiltro		:= ''
Local lAchouCCZ	:= .F.
Local lB1TPREG	:= SB1->(ColumnPos( 'B1_TPREG' ))
Local lA1TPREG	:= SA1->(ColumnPos( 'A1_TPREG' ))

DbSelectArea (cAliasSD2)
(cAliasSD2)->(DbSetOrder (3))

//Campos da tabela SF2
cSlctSF2 := "SF2.F2_FILIAL,SF2.F2_ESPECIE,SF2.F2_SERIE,SF2.F2_TIPO,SF2.F2_CLIENTE,SF2.F2_LOJA,SF2.F2_DOC,SF2.F2_CHVNFE,SF2.F2_EMISSAO,"
cSlctSF2 += "SF2.F2_VALBRUT,SF2.F2_DESCONT,SF2.F2_FRETE,SF2.F2_SEGURO,SF2.F2_DESPESA,SF2.F2_BASEICM,"
cSlctSF2 += "SF2.F2_VALICM,SF2.F2_BRICMS,SF2.F2_ICMSRET,SF2.F2_VALIPI,SF2.F2_VALIMP6,SF2.F2_VALIMP5,"
cSlctSF2 += "SB1.B1_COD,SB1.B1_DESC,SB1.B1_POSIPI,SB1.B1_EX_NCM,SB1.B1_TNATREC,SB1.B1_CNATREC,"    	
cSlctSF2 += "SB1.B1_TIPO,SB1.B1_CODISS,SB1.B1_CODBAR,SB1.B1_CODANT,SB1.B1_UM,SB1.B1_PICM,SB1.B1_FECP,SB1.B1_DATREF,"
cSlctSF2 += "SB1.B1_TNATREC,SB1.B1_CNATREC,SB1.B1_GRPNATR,SB1.B1_DTFIMNT"

IF lB1TPREG
	cSlctSF2 += ",SB1.B1_TPREG"
EndIF

IF lA1TPREG
	cSlctSF2 += ",SA1.A1_TPREG"
EndIF

//Campos da tabela SD2
cSlctSF2 += ",SD2.D2_CONTA,SD2.D2_SERIE,SD2.D2_VALIMP5,SD2.D2_BASIMP5,SD2.D2_ALQIMP5,SD2.D2_VALIMP6,SD2.D2_BASIMP6,SD2.D2_ALQIMP6,"
cSlctSF2 += "SD2.D2_DTFIMNT,SD2.D2_DESC,SD2.D2_TNATREC,SD2.D2_CNATREC,SD2.D2_GRUPONC,SD2.D2_TOTAL,SD2.D2_DESPESA,SD2.D2_SEGURO,"
cSlctSF2 += "SD2.D2_BASEICM,SD2.D2_VALICM,SD2.D2_CLIENTE,SD2.D2_LOJA,SD2.D2_CF,SD2.D2_QUANT,SD2.D2_UM,SD2.D2_CLASFIS,SD2.D2_DESCON,
cSlctSF2 += "SD2.D2_PICM,SD2.D2_BRICMS,SD2.D2_BASEIPI,SD2.D2_IPI,SD2.D2_VALIPI,SD2.D2_ICMSRET,SD2.D2_COD,SD2.D2_PEDIDO"

//colocar join da tabela SA1 caso o campo A1_TPREG exista   
    	
//Campos da TES
cSlctSF2 += ",SF4.F4_CSTPIS,SF4.F4_CSTCOF,SF4.F4_TPREG,SF4.F4_PISCOF,SF4.F4_ESTOQUE,SF4.F4_CTIPI,SF4.F4_TEXTO,"
cSlctSF2 += "SF4.F4_TNATREC,SF4.F4_CNATREC,SF4.F4_GRPNATR,SF4.F4_DTFIMNT"
//Join com SD2, SF4
cJoinSD2	:=	"LEFT JOIN "+RetSqlName("SD2")+" SD2 ON(SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_DOC=SF2.F2_DOC AND SD2.D2_SERIE=SF2.F2_SERIE AND SD2.D2_CLIENTE=SF2.F2_CLIENTE AND SD2.D2_LOJA=SF2.F2_LOJA AND  SD2.D_E_L_E_T_=' ') "		
cJoinSF4	:=	"LEFT JOIN "+RetSqlName("SF4")+" SF4 ON(SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_=' ') "				

cJoin	:=  cJoinSD2 + cJoinSF4
cJoin := "%" + cJoin + "%"

cSlct := cSlctSF2

cSlct := "%" + cSlct + "%"											

cFiltro 	:= "%"		
cFiltro	+= "SD2.D2_CF IN ('5103','5104','6103','6104') AND SF4.F4_LFICM = 'N' AND  SF4.F4_LFIPI = 'N' AND SF4.F4_ISS = 'N' AND "
cFiltro	+= "SF4.F4_CSTPIS <> ' ' AND SF4.F4_CSTCOF <> ' ' AND SF4.F4_PISCOF <> '4'"
cFiltro 	+= "%"
    	
cAliasSF2	:=	GetNextAlias()    	 			
    	
BeginSql Alias cAliasSF2
	
	SELECT			    
		%Exp:cSlct%
	FROM 
		%Table:SF2% SF2
		%Exp:cJoin%
		LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SD2.D2_COD AND SB1.%NotDel%)						
		LEFT JOIN %Table:SA1% SA1 ON(SA1.A1_FILIAL=%xFilial:SA1%  AND SA1.A1_COD=SD2.D2_CLIENTE AND SA1.A1_LOJA = SD2.D2_LOJA AND SA1.%NotDel%)		

	WHERE
		SF2.F2_FILIAL=%xFilial:SF2% AND 
		SF2.F2_EMISSAO>=%Exp:DToS (dDataDe)% AND 
		SF2.F2_EMISSAO<=%Exp:DToS (dDataAte)% AND
		%Exp:cFiltro% AND
		SF2.%NotDel%
	ORDER BY SF2.F2_SERIE, SF2.F2_DOC, SF2.F2_CLIENTE, SF2.F2_LOJA				
EndSql
 
cAliasSD2	:= cAliasSF2
cAliasSF4	:= cAliasSF2
cAliasSB1	:= cAliasSF2

DbSelectArea (cAliasSF2)
(cAliasSF2)->(DbGoTop ())

Do While !(cAliasSF2)->(Eof ())
 	
	If AModNot((cAliasSF2)->F2_ESPECIE) $ "01/04/1B/55"  
		If (cAliasSF4)->F4_CSTPIS $ "04/05/06/07/08/09" .Or. (cAliasSF4)->F4_CSTCOF $ "04/05/06/07/08/09"
			dbSelectArea("CCZ")
			dbSetOrder(1)
			If CCZ->(MsSeek(xFilial("CCZ")+ (cAliasSB1)->B1_TNATREC + (cAliasSB1)->B1_CNATREC + (cAliasSB1)->B1_GRPNATR  + (cAliasSB1)->B1_DTFIMNT))		
				lAchouCCZ := .T.
			ElseIf !lAchouCCZ .And. CCZ->(MsSeek(xFilial("CCZ")+ (cAliasSF4)->F4_TNATREC + (cAliasSF4)->F4_CNATREC + (cAliasSF4)->F4_GRPNATR  + (cAliasSF4)->F4_DTFIMNT))		
				lAchouCCZ := .T.	
			EndIf  
		EndIf
		//---------------------
		//Informações da nota
		//---------------------
		oApurSai:SetReceita((cAliasSD2)->D2_TOTAL)
		oApurSai:SetOrigem(FISCALSAI)
		If cReg == 4
			oApurSai:SetTpReg(DefRegime(nM996Tpr,cAliasSF2))
		EndIF
		
		IF lAchouCCZ
			oApurSai:SetTNatRec(CCZ->CCZ_TABELA)
			oApurSai:SetCNatRec(CCZ->CCZ_COD)		
			oApurSai:SetGNatRec(CCZ->CCZ_GRUPO )
			oApurSai:SetDNatRec(CCZ->CCZ_DTFIM )
		EndIF
	 
		//--------------------
		//Informações do PIS
		//--------------------		
		oApurSai:SetTributo(PIS)
		oApurSai:SetCST((cAliasSF2)->F4_CSTPIS)		
		oApurSai:SetAlqTrib((cAliasSD2)->D2_ALQIMP6)
		oApurSai:SetBcTrib((cAliasSD2)->D2_BASIMP6)
		oApurSai:SetValTrib((cAliasSD2)->D2_VALIMP6)
		oApurSai:AgrpContr()	
	
		//----------------------
		//Informações da COFINS
		//----------------------
		oApurSai:SetTributo(COFINS)
		oApurSai:SetCST((cAliasSF2)->F4_CSTCOF)		
		oApurSai:SetAlqTrib((cAliasSD2)->D2_ALQIMP5)
		oApurSai:SetBcTrib((cAliasSD2)->D2_BASIMP5)
		oApurSai:SetValTrib((cAliasSD2)->D2_VALIMP5)
		oApurSai:AgrpContr()	
	
		oApurSai:GrvResCST()

    EndIf

	(cAliasSF2)->(dbSkip())
EndDo		

oApurSai:FechaAlias(cAliasSF2)

//FINALIZA GRAVAÇÃO DAS RECEITAS.
oApurSai:Finaliza('1')

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} A001CUPOM()
Função que irá processar as operações de cupom fiscal com PIS e COFINS
gravadas através do módulo SIGALOJA. 

@param		dDataDe 	- Data de início da apuração
			dDataAte 	- Data final da apuração
			oApurSai	- Objeto de processamento das operações de débito
			cRegime	- Indica qual o regime de PIS e COFINS indicado pelo usuário
			cNrLivro	- Número do Livro Processado.			
			 	
@author Erick G. Dias
@since 25/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001CUPOM(dDataDe,dDataAte,oApurSai,cRegime,cNrLivro,cReg,nMVM996TPR)
     
Local cAliasSFT	:= "SFT"
Local cSlctSFT	:= ""
Local cFiltro		:= "" 
Local cOrderBy	:= ""
Local lProcessou	:= .F.
                                    
// ==============================================
// Query Principal - ECF
// ==============================================  
cSlctSFT := "SFT.FT_CLIEFOR,		SFT.FT_LOJA,			SFT.FT_ALIQPIS,		SFT.FT_ALIQCOF,"
cSlctSFT += "SFT.FT_CSTPIS,		SFT.FT_CSTCOF,		SFT.FT_ALIQCF3,		SFT.FT_ALIQPS3,"
cSlctSFT += "SFT.FT_TNATREC,		SFT.FT_CNATREC,		SFT.FT_GRUPONC,		SFT.FT_DTFIMNT, SFT.FT_CFOP,"
cSlctSFT += "SFT.FT_PAUTPIS,		SFT.FT_PAUTCOF,		SF4.F4_TPREG,			SB1.B1_TPREG,"
cSlctSFT +="SUM(SFT.FT_VALPIS)	AS	FT_VALPIS, 	SUM(SFT.FT_VALCOF)	AS	FT_VALCOF,	SUM(SFT.FT_TOTAL)	AS	FT_TOTAL,"
cSlctSFT +="SUM(SFT.FT_BASEPIS) AS	FT_BASEPIS,	SUM(SFT.FT_BASECOF)  AS	FT_BASECOF,	SUM(SFT.FT_VALCF3) AS	FT_VALCF3,"
cSlctSFT +="SUM(SFT.FT_BASEPS3) AS	FT_BASEPS3,	SUM(SFT.FT_VALPS3)   AS	FT_VALPS3,	SUM(SFT.FT_BASECF3) AS	FT_BASECF3,"
cSlctSFT +="SUM(SFT.FT_QUANT)   AS	FT_QUANT"
      	    	
cAliasSFT	:=	GetNextAlias()
    	
cFiltro := "%"
If (cNrLivro<>"*")
	cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:cNrLivro% +"' AND "
EndiF  
cFiltro += "%"

cOrderBy += "GROUP BY "
cOrderBy += "SFT.FT_CLIEFOR,		SFT.FT_LOJA,			SFT.FT_ALIQPIS,		SFT.FT_ALIQCOF,"
cOrderBy += "SFT.FT_CSTPIS,		SFT.FT_CSTCOF,		SFT.FT_ALIQCF3,		SFT.FT_ALIQPS3, SFT.FT_CFOP,"
cOrderBy += "SFT.FT_TNATREC,		SFT.FT_CNATREC,		SFT.FT_GRUPONC,		SFT.FT_DTFIMNT,"
cOrderBy += "SFT.FT_PAUTPIS,		SFT.FT_PAUTCOF,		SF4.F4_TPREG,			SB1.B1_TPREG"

cSlctSFT	:=	"%"+cSlctSFT+"%"
cOrderBy	:= '%'+cOrderBy+'%'
    	
BeginSql Alias cAliasSFT
	COLUMN FT_DTFIMNT AS DATE
	
	SELECT			    
		%Exp:cSlctSFT%
	FROM 
		%Table:SFT% SFT 
		JOIN %Table:SFI% SFI ON (SFI.FI_FILIAL=%xFilial:SFI% AND SFI.FI_PDV=SFT.FT_PDV AND SFI.FI_DTMOVTO=SFT.FT_ENTRADA AND SFI.%NotDel%    )
		JOIN %Table:SLG% SLG ON (SLG.LG_FILIAL=%xFilial:SLG% AND SLG.LG_PDV=SFT.FT_PDV AND SLG.%NotDel%    )
		LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%) 
		LEFT JOIN %Table:SD2% SD2 ON(SD2.D2_FILIAL=%xFilial:SD2%  AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.%NotDel%)
		LEFT JOIN %Table:SF4% SF4 ON(SF4.F4_FILIAL=%xFilial:SF4%  AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.%NotDel%) 				

	WHERE 
		SFT.FT_FILIAL=%xFilial:SFT% 				AND 					
		SFT.FT_TIPOMOV  = 'S'   					AND 
		SFT.FT_ENTRADA>=%Exp:DToS(dDataDe)% AND 
		SFT.FT_ENTRADA<=%Exp:DToS(dDataAte)% AND 
		SFT.FT_DTCANC = ' ' AND 
		(SFT.FT_ESPECIE='CF' OR SFT.FT_ESPECIE='ECF') AND
		((SFT.FT_BASEPIS > 0 OR SFT.FT_CSTPIS IN ('07','08','09','49' ))  OR (SFT.FT_BASECOF > 0 OR SFT.FT_CSTCOF IN ('07','08','09','49'))) AND				
		%Exp:cFiltro%
		SFT.%NotDel%  
			 
	%Exp:cOrderBy%
						
EndSql  
                                       
// Processa Registros.
Do While !(cAliasSFT)->(Eof())
	lProcessou	:= .T.
	lCumulativ := .F. 
	IF cRegime == '1'
		//Não Cumulativo
		lCumulativ	:= .F.				
	Elseif cRegime =='2'
		//Cumulativo
		lCumulativ	:= .T.
	ElseIF cRegime == '4'
		//Cumulativo/Nao Cumulativo
		IF nMVM996TPR == 1 //TES
			If (cAliasSFT)->F4_TPREG == "2"	//Cumulativo
				lCumulativ := .T.				
			ElseIF (cAliasSFT)->F4_TPREG == "3"	//Ambos, neste caso irei no produto para definir qual o regime				
				IF (cAliasSFT)->B1_TPREG == "2" //Cumulativo 
					lCumulativ := .T. 
				EndIF  				                        	
			EndIF
		Elseif nMVM996TPR == 2 //PRODUTO
			IF (cAliasSFT)->B1_TPREG == "2" //Cumulativo
				lCumulativ := .T.   
			EndIF									
		Elseif nMVM996TPR == 3 //CLIENTE
			If SPEDSeek("SA1",1,xFilial("SA1")+(cAliasSFT)->(FT_CLIEFOR+FT_LOJA))
				IF SA1->A1_TPREG == "2" //Cumulativo
					lCumulativ := .T.   
				EndIF
			Endif											
		EndIF  				
		
	EndIF
	
	oApurSai:SetOrigem(CUPOM)			
	oApurSai:SetCFOP(	(cAliasSFT)->FT_CFOP)				
	oApurSai:SetReceita((cAliasSFT)->FT_TOTAL)
	oApurSai:SetTNatRec((cAliasSFT)->FT_TNATREC)
	oApurSai:SetCNatRec((cAliasSFT)->FT_CNATREC)		
	oApurSai:SetGNatRec((cAliasSFT)->FT_GRUPONC)
	oApurSai:SetDNatRec((cAliasSFT)->FT_DTFIMNT)
	oApurSai:SetQtde((cAliasSFT)->FT_QUANT)				
	If cReg == 4
		oApurSai:SetTpReg(Iif (lCumulativ ,CUMULAT ,NAOCUMULAT ))
	EndIF


	//-------------------------------------------------------------------
	//Informações de PIS
	//-------------------------------------------------------------------			
	oApurSai:SetTributo(PIS)
	oApurSai:SetCST((cAliasSFT)->FT_CSTPIS)		
	oApurSai:SetAlqTrib((cAliasSFT)->FT_ALIQPIS)
	oApurSai:SetBcTrib((cAliasSFT)->FT_BASEPIS)
	oApurSai:SetValTrib((cAliasSFT)->FT_VALPIS)
	oApurSai:SetBaseST((cAliasSFT)->FT_BASEPS3)
	oApurSai:SetValST((cAliasSFT)->FT_VALPS3)
	oApurSai:SetAlqSt((cAliasSFT)->FT_ALIQPS3)		
	oApurSai:SetVlPauta((cAliasSFT)->FT_PAUTPIS)
	oApurSai:AgrpContr()			

	//-------------------------------------------------------------------
	//Informações da COFINS
	//-------------------------------------------------------------------		
	oApurSai:SetTributo(COFINS)		
	oApurSai:SetCST((cAliasSFT)->FT_CSTCOF)
	oApurSai:SetAlqTrib((cAliasSFT)->FT_ALIQCOF)
	oApurSai:SetBcTrib((cAliasSFT)->FT_BASECOF)
	oApurSai:SetValTrib((cAliasSFT)->FT_VALCOF)
	oApurSai:SetBaseST((cAliasSFT)->FT_BASECF3)
	oApurSai:SetValST((cAliasSFT)->FT_VALCF3)
	oApurSai:SetAlqSt((cAliasSFT)->FT_ALIQCF3)
	oApurSai:SetVlPauta((cAliasSFT)->FT_PAUTCOF)
	oApurSai:AgrpContr()	

	oApurSai:GrvResCST()

	(cAliasSFT)->(dbSkip())
	          	
EndDo

oApurSai:FechaAlias(cAliasSFT)

If lProcessou
	//FINALIZA GRAVAÇÃO DAS RECEITAS.
	oApurSai:Finaliza('1')
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001CAIXA()
Função que irá processar as operações de PIS e COFINS através do regime de
Caixa, utilizando a função disponibilizada através de equipe de Financeiro

@param		dDataDe 	- Data de início da apuração
			dDataAte 	- Data final da apuração
			oApurSai	- Objeto de processamento das operações de débito
			cNrLivro	- Livro a ser processado
			cIndCompRe	- Indicador da composição da receita
			aXFilial	- Conteúdo do xFilial das tabelas da apuração.									

@author Erick G. Dias
@since 25/06/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001CAIXA(dDataDe,dDataAte,oApurSai,cNrLivro,cIndCompRe,aXFilial,lCPRBNF,cSPCBPSE,cFilialMat,lindividu)

Local cAliasF500	:= 'F500'
Local aParFil			:=	{}
Local lPauta			:=	.F.
Local lProcFin		:= .F.
Local lCmpVrDes		:=	.F.
Local cAliasSFT		:=	'SFT'
Local cCnpj			:=	''
Local nPerReceb		:=	0
Local nDesconto		:=	0
Local cChaveCl1		:= ''
Local lF07				:= AliasINdic('F07')
Local lF0T				:= AliasINdic('F0T')
Local cAliasCDG		:=	"CDG"	
Local aParCDG			:= {}
Local oCaixa					
Local oProcRef	
Local lAtuCPRB		:=	.F.
Local ObjF0T

ObjF0T	:= TABELAF0T():New()

IF FindFunction('FinSpdF500')		
	
	//Cria objeto para gravação das informações na tabela CL1
	oCaixa	:= TABELACL1():New()
	oCaixa:SetPer(dDataDe)
	oCaixa:SetFilial(aXFilial)
	
	oProcRef	:= TABELAF07():New()
	oProcRef:SetPer(dDataDe)
	oProcRef:SetFilial(aXFilial)	
	
	//Cria objeto para gravação da CPRB
	If lCPRBNF
		oCPRB	:= CPRBEFD():New()
		oCPRB:SetDtIni(dDataDe)
	Endif
	
	//Chama função de integração com Financeiro
	FinSpdF500(Month(dDataDe),Year(dDataDe),cAliasF500)
	(cAliasF500)->( DBGOTOP())
	lProcFin	:= (cAliasF500)->(FieldPos('NUMPRO')) > 0 .AND.(cAliasF500)->(FieldPos('INDPRO')) > 0
	lCmpVrDes	:=	(cAliasF500)->(FieldPos('VRDESCON')) > 0

	Do While !(cAliasF500)->( EOF())
		cChaveCl1	:=''
		IF !(cAliasF500)->ORIFIN
	
			aParFil	:=	{}
			aAdd(aParFil,(cAliasF500)->EMISSAO)
			aAdd(aParFil,(cAliasF500)->SERIE)
			aAdd(aParFil,(cAliasF500)->NUMERO)
			aAdd(aParFil,(cAliasF500)->CLIENTE)
			aAdd(aParFil,(cAliasF500)->LOJA)
			aAdd(aParFil,cNrLivro)
			aAdd(aParFil,'01')
		    
			//³Considera o percentual de baixa enviado pelo financeiro³
			nPerReceb	:= (cAliasF500)->PERC / 100
		    IF nPerReceb > 0
				//³Irá buscar os itens da nota fiscal referente a baixa que o Financeiro enviou³
				If SPEDFFiltro(1,"SFT3",@cAliasSFT,aParFil)		
			
					Do While !(cAliasSFT)->( EOF())
	
						lPauta			:=	.F.
						nPerReceb		:=  (cAliasF500)->VALOR /(cAliasSFT)->F2_VALBRUT
						nDesconto		:= Iif(lCmpVrDes,(cAliasF500)->VRDESCON,0)
						If (cAliasSFT)->FT_PAUTPIS > 0 .OR. (cAliasSFT)->FT_PAUTCOF > 0
							lPauta 		:= .T.
						EndIF
											
						oCaixa:SetCstPis((cAliasSFT)->FT_CSTPIS								)
						oCaixa:SetCstCof((cAliasSFT)->FT_CSTCOF								)
						oCaixa:SetModelo(AModNot ((cAliasSFT)->FT_ESPECIE)					)
						oCaixa:SetCfop((cAliasSFT)->FT_CFOP									)	
						oCaixa:SetValRec((cAliasSFT)->FT_VALCONT * nPerReceb					)
						oCaixa:SetDescPis(nDesconto + (cAliasSFT)->FT_VALIPI * nPerReceb	)
						oCaixa:SetBasePis(((cAliasSFT)->FT_BASEPIS * nPerReceb) - nDesconto)
						oCaixa:SetDescCof(nDesconto + (cAliasSFT)->FT_VALIPI * nPerReceb	)
						oCaixa:SetBaseCof(((cAliasSFT)->FT_BASECOF * nPerReceb) - nDesconto)
						oCaixa:SetConta((cAliasSFT)->FT_CONTA									)
						oCaixa:SetNumDoc((cAliasSFT)->FT_NFISCAL 								)
						oCaixa:SetSerie((cAliasSFT)->FT_SERIE									)
						oCaixa:SetClieFor((cAliasSFT)->FT_CLIEFOR								)
						oCaixa:SetLoja((cAliasSFT)->FT_LOJA									)
						oCaixa:SetTNatRec((cAliasSFT)->FT_TNATREC								)
						oCaixa:SetCNatRec((cAliasSFT)->FT_CNATREC								)
						oCaixa:SetGrupo((cAliasSFT)->FT_GRUPONCA								)
						oCaixa:SetDtFim((cAliasSFT)->FT_DTFIMNT								)
						oCaixa:SetQuantid((cAliasSFT)->FT_QUANT								)
	
						IF lPauta
							oCaixa:SetPauta('1')
							oCaixa:SetAlqPis((cAliasSFT)->FT_PAUTPIS)
							oCaixa:setAlqCof((cAliasSFT)->FT_PAUTCOF)							
						Else
							oCaixa:SetPauta('0')
							oCaixa:SetAlqPis((cAliasSFT)->FT_ALIQPIS)
							oCaixa:setAlqCof((cAliasSFT)->FT_ALIQCOF)						
						EndIF
	
						oCaixa:SetIndRec(cIndCompRe												)
	
						If cIndCompRe == 1	//Agrupa por CNPJ de Cliente
							oCaixa:SetCnPj((cAliasSFT)->A1_CGC									)					
						Elseif cIndCompRe == 2	//Agrupar por número do título
							oCaixa:SetNfTit((cAliasF500)->NUMERO								)
						Elseif cIndCompRe == 3	//Agrupar por número do título
							oCaixa:SetNfTit((cAliasSFT)->FT_NFISCAL							)
						Elseif cIndCompRe == 4 //agrupa por código de produto
							oCaixa:SetItem((cAliasSFT)->B1_COD									)					
						EndIF
	
						cChaveCl1	:= oCaixa:Save()	
						
						IF !Empty(cChaveCL1) .AND. lF07

							//³Preenche array para pesquisar os processos referenciados vinculados a nota fiscal³
							aParCDG	:= {}
							aAdd(aParCDG,(cAliasSFT)->FT_TIPOMOV)
							aAdd(aParCDG,(cAliasSFT)->FT_NFISCAL)
							aAdd(aParCDG,(cAliasSFT)->FT_SERIE)
							aAdd(aParCDG,(cAliasSFT)->FT_CLIEFOR)
							aAdd(aParCDG,(cAliasSFT)->FT_LOJA)						
						
							IF SPEDFFiltro(1,"CDG2",@cAliasCDG,aParCDG)
			
								Do while !(cAliasCDG)->(EOF())
									oProcRef:SetId(cChaveCL1)
									oProcRef:SetPer(dDataDe)
									oProcRef:SetNumPro((cAliasCDG)->CDG_PROCES)
									oProcRef:SetIndPro((cAliasCDG)->CDG_TPPROC)
									oProcRef:Save()
									(cAliasCDG)->(DBSKIP())
								EndDo
							EndIF
						EndIF
						//Grava aqui as informações da nota
						ObjF0T:Clear()
						ObjF0T:SetValue("F0T_PER",dDataDe)
						ObjF0T:SetValue("F0T_FILAPU",cFilialMat)
						ObjF0T:SetValue("F0T_TIPO",'1')
						ObjF0T:SetValue("F0T_NUMNF",(cAliasSFT)->FT_NFISCAL)
						ObjF0T:SetValue("F0T_SER",(cAliasSFT)->FT_SERIE)
						ObjF0T:SetValue("F0T_DTEMI",(cAliasSFT)->FT_ENTRADA)
						ObjF0T:SetValue("F0T_DTRECB",ctod(substr((cAliasF500)->DTMOV,7,2) + "/" + substr((cAliasF500)->DTMOV,5,2) + "/" + substr((cAliasF500)->DTMOV,1,4)))
						ObjF0T:SetValue("F0T_CFOP",(cAliasSFT)->FT_CFOP)
						ObjF0T:SetValue("F0T_ITEM",(cAliasSFT)->FT_ITEM)
						ObjF0T:SetValue("F0T_MODELO",AModNot ((cAliasSFT)->FT_ESPECIE)	)
						ObjF0T:SetValue("F0T_PERREC",nPerReceb*100)
						ObjF0T:SetValue("F0T_VLCONT",(cAliasSFT)->FT_VALCONT)
						ObjF0T:SetValue("F0T_CSTPIS",oCaixa:getCST(PIS))
						ObjF0T:SetValue("F0T_BASPIS",oCaixa:getBase(PIS))
						ObjF0T:SetValue("F0T_ALQPIS",oCaixa:getAliq(PIS))
						ObjF0T:SetValue("F0T_VALPIS",Round(oCaixa:getBase(PIS)*oCaixa:getAliq(PIS)/Iif(lPauta,1,100),2))
						ObjF0T:SetValue("F0T_CSTCOF",oCaixa:getCST(COFINS))
						ObjF0T:SetValue("F0T_BASCOF",oCaixa:getBase(COFINS))
						ObjF0T:SetValue("F0T_ALQCOF",oCaixa:getAliq(COFINS))
						ObjF0T:SetValue("F0T_VALCOF",Round(oCaixa:getBase(COFINS)*oCaixa:getAliq(COFINS)/Iif(lPauta,1,100),2))
						ObjF0T:Grava()						
						oCaixa:clear()

						//--------------------
						//Informações da CPRB
						//--------------------
						If lCPRBNF
							//Verifica parâmetro para definir se utilizará código de serviço ou de outros serviços.
							lAtuCPRB := .T.
							oCPRB:SetDtRefer(dDataDe)
							oCPRB:SetCodAtiv((cAliasSFT)->FT_ATIVCPB)
							oCPRB:SetVlBrut((cAliasSFT)->FT_VALCONT)
							oCPRB:SetVlExcl((cAliasSFT)->FT_VALIPI+(cAliasSFT)->FT_ICMSRET)
							oCPRB:SetVlCPRB((cAliasSFT)->FT_VALCPB)
							oCPRB:SetAliq((cAliasSFT)->FT_ALIQCPB)
							oCPRB:SetBase((cAliasSFT)->FT_BASECPB) 
							oCPRB:SetVlAtiv((cAliasSFT)->FT_VALCONT)
							oCPRB:SetConta((cAliasSFT)->FT_CONTA)
							oCPRB:SetCodRec(Iif(AllTrim((cAliasSFT)->FT_ATIVCPB)$cSPCBPSE,mv_par16,mv_par17)) 
							oCPRB:SetFilApu(IIf(lIndividu,oCPRB:BuscaxFil('CKY'),cFilialMat)) 
							oCPRB:AgrupaCPRB()
							//Grava o detalhamento da nota fiscal
							ObjF0T:Clear()
							ObjF0T:SetValue("F0T_PER",dDataDe)
							ObjF0T:SetValue("F0T_FILAPU",cFilialMat)
							ObjF0T:SetValue("F0T_TIPO",'3') //CPRB Regime de Caixa							
							ObjF0T:SetValue("F0T_NUMNF",(cAliasSFT)->FT_NFISCAL)
							ObjF0T:SetValue("F0T_SER",(cAliasSFT)->FT_SERIE)
							ObjF0T:SetValue("F0T_DTEMI",(cAliasSFT)->FT_ENTRADA)							
							ObjF0T:SetValue("F0T_CFOP",(cAliasSFT)->FT_CFOP)
							ObjF0T:SetValue("F0T_ITEM",(cAliasSFT)->FT_ITEM)
							ObjF0T:SetValue("F0T_MODELO",AModNot ((cAliasSFT)->FT_ESPECIE)	)
							ObjF0T:SetValue("F0T_VLCONT",(cAliasSFT)->FT_VALCONT)
							ObjF0T:SetValue("F0T_EXCPRB",(cAliasSFT)->FT_VALIPI+(cAliasSFT)->FT_ICMSRET)
							ObjF0T:SetValue("F0T_CODATV",(cAliasSFT)->FT_ATIVCPB)
							ObjF0T:SetValue("F0T_BCCPRB",(cAliasSFT)->FT_BASECPB)
							ObjF0T:SetValue("F0T_AQCPRB",(cAliasSFT)->FT_ALIQCPB)
							ObjF0T:SetValue("F0T_VLCPRB",(cAliasSFT)->FT_VALCPB)							
							ObjF0T:Grava()						
						Endif			
											
						(cAliasSFT)->( DBSKIP())						
					EndDo	                 
					//³Fecha alias dos itens da nota fiscal³
					SPEDFFiltro(2,,cAliasSFT)
				EndIF 
			EndIF
		Else
			//Se (cAliasF500)->ORIFIN igual a .T. indica que o titulo nao possui vinculo com documento fiscal	
			//Se tiver valor no campo VRDESC, foi baixa que não caracteriza um recebimento
		
			IF (cAliasF500)->VRDESC == 0
	
				cInfCompl		:= ''
				cCnpj			:= ''
				nDesconto		:= Iif(lCmpVrDes,(cAliasF500)->VRDESCON,0)
				If SPEDSeek("SA1",1,xFilial("SA1")+(cAliasF500)->CHVCLIENTE)				
					cCnpj	:= SA1->A1_CGC
				EndIF
	
				IF (cAliasF500)->TABELA=="SEI" .AND. cIndCompRe <> 2
					cIndCompRe:= 9
					cInfCompl:= STR0078 + (cAliasF500)->CHVCLIENTE //"Juros Referente Aplicação Financeira - (Banco + Agência + Conta) :  "			
				EndIF
	
				oCaixa:SetCstPis((cAliasF500)->CSTPIS					)
				oCaixa:SetCstCof((cAliasF500)->CSTCOF					)
				oCaixa:SetValRec((cAliasF500)->VALOR					)
				oCaixa:SetDescPis(nDesconto								)
				oCaixa:SetBasePis((cAliasF500)->BASEPIS - nDesconto	)
				oCaixa:SetDescCof(nDesconto								)
				oCaixa:SetBaseCof((cAliasF500)->BASECOF - nDesconto	)
				oCaixa:SetConta((cAliasF500)->CONTA					)
				oCaixa:SetNumDoc((cAliasF500)->NUMERO					)
				oCaixa:SetTNatRec((cAliasF500)->ED_TABCCZ				)
				oCaixa:SetCNatRec((cAliasF500)->ED_CODCCZ				)
				oCaixa:SetGrupo((cAliasF500)->ED_GRUCCZ				)
				oCaixa:SetDtFim((cAliasF500)->ED_DTFCCZ				)
				oCaixa:SetPauta('0'										)//Não existe tratamento de conversão de puata para operações do módulo Financeiro
				oCaixa:SetAlqPis((cAliasF500)->ALIQPIS					)
				oCaixa:setAlqCof((cAliasF500)->ALIQCOF					)
				oCaixa:SetInfCom(cInfCompl								)
				oCaixa:SetIndRec(cIndCompRe								)
	
				IF lProcFin .AND. !Empty((cAliasF500)->NUMPRO) .AND. !Empty((cAliasF500)->INDPRO)
					oCaixa:SetIndPro((cAliasF500)->INDPRO)
					oCaixa:SetNumPro((cAliasF500)->NUMPRO)
				EndIF
	
				If cIndCompRe == 1	//Agrupa por CNPJ de Cliente
					oCaixa:SetCnPj(cCnpj)					
				Elseif cIndCompRe == 2 .OR. cIndCompRe == 3 .OR. cIndCompRe == 4 //Agrupar por número do título
					oCaixa:SetNfTit((cAliasF500)->NUMERO)
				EndIF
	
				cChaveCL1	:= oCaixa:Save()
				
				//Grava aqui as informações da nota	
				ObjF0T:Clear()
				ObjF0T:SetValue("F0T_PER",dDataDe)
				ObjF0T:SetValue("F0T_FILAPU",cFilialMat)
				ObjF0T:SetValue("F0T_TIPO",'2')				
				ObjF0T:SetValue("F0T_NUMTIT",(cAliasF500)->NUMERO)
				ObjF0T:SetValue("F0T_PREFIX",(cAliasF500)->PREFIXO)
				ObjF0T:SetValue("F0T_PARC",(cAliasF500)->PARCELA)
				ObjF0T:SetValue("F0T_DTEMI",ctod(substr((cAliasF500)->EMISSAO,7,2) + "/" + substr((cAliasF500)->EMISSAO,5,2) + "/" + substr((cAliasF500)->EMISSAO,1,4)))
				ObjF0T:SetValue("F0T_DTRECB",ctod(substr((cAliasF500)->DTMOV,7,2) + "/" + substr((cAliasF500)->DTMOV,5,2) + "/" + substr((cAliasF500)->DTMOV,1,4)))
				ObjF0T:SetValue("F0T_PERREC",(cAliasF500)->PERC)
				ObjF0T:SetValue("F0T_VLCONT",(cAliasF500)->VALOR)
				ObjF0T:SetValue("F0T_CSTPIS",oCaixa:getCST(PIS))
				ObjF0T:SetValue("F0T_BASPIS",oCaixa:getBase(PIS))
				ObjF0T:SetValue("F0T_ALQPIS",oCaixa:getAliq(PIS))
				ObjF0T:SetValue("F0T_VALPIS",Round(oCaixa:getBase(PIS)*oCaixa:getAliq(PIS)/Iif(lPauta,1,100),2))
				ObjF0T:SetValue("F0T_CSTCOF",oCaixa:getCST(COFINS))
				ObjF0T:SetValue("F0T_BASCOF",oCaixa:getBase(COFINS))
				ObjF0T:SetValue("F0T_ALQCOF",oCaixa:getAliq(COFINS))
				ObjF0T:SetValue("F0T_VALCOF",Round(oCaixa:getBase(COFINS)*oCaixa:getAliq(COFINS)/Iif(lPauta,1,100),2))				
				ObjF0T:Grava()
			
				oCaixa:clear()
				
				IF !Empty(cChaveCL1) .AND. lF07
					oProcRef:SetId(cChaveCL1)
					oProcRef:SetPer(dDataDe)
					oProcRef:SetNumPro((cAliasF500)->NUMPRO)
					oProcRef:SetIndPro((cAliasF500)->INDPRO)
					oProcRef:Save()
				EndIF
				
			EndIF	
		EndIF
						
		(cAliasF500)->( DBSKIP())	
	EndDo	
	
	oCaixa:CalcCaixa(oApurSai)
	oCaixa:FechaAlias(cAliasF500)
	
	If lF07
		oProcRef:GravaF07()
	EndIF

	If lCPRBNF .And. lAtuCPRB				
		//Grava os valores alterados.
		oCPRB:GravaCPRB()
	Endif
	
	FreeObj(oCaixa)
	oCaixa	:= Nil
	
	FreeObj(oProcRef)
	oProcRef	:= Nil
	
	If lCPRBNF				
		FreeObj(oCPRB)
		oCPRB	:= Nil
	Endif
	
	FERASE(cAliasF500)
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} DefRegime()
Função que define o regime da operação. Somente deverá ser utilizada quando
no alias houver os campos F4_TPREG, B1_TPREG e/ou A1_TPREG.

@param		nM996Tpr 	- Conteúdo do parâmetro MV_M996TPR
			cAlias 	- Alias da query realizada com os campos F4_TPREG, B1_TPREG e A1_TPREG.

@author Erick G. Dias
@since 07/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function DefRegime(nM996Tpr,cAlias)

Local cRegime	:= ''

If nM996Tpr == 1 	
	//TES
	//Se o regime definido no TES for igual a ambos ou por algum motivo não encontrar o TES, o produto irá definir o regime
	If (cAlias)->F4_TPREG $ '1/2'
		cRegime	:= (cAlias)->F4_TPREG
	ElseIf (cAlias)->F4_TPREG == '3'
		cRegime	:= (cAlias)->B1_TPREG
	Else
		cRegime	:= NAOCUMULAT //O legado será mantido, nesta situação onde o TES não resolve é adotado regime Não Cumulativo
	EndiF	
	
ElseIF nM996Tpr == 2
	//PRODUTO
	cRegime	:= (cAlias)->B1_TPREG
ElseIF nM996Tpr == 3
	//CLIENTE
	cRegime	:= (cAlias)->A1_TPREG
EndIF	

Return cRegime

//-------------------------------------------------------------------
/*/{Protheus.doc} ASA001CANC()
Função que irá buscar as notas canceladas e gravar na tabela CF4 para 
que possa ser utilizada no estorno da contribuição.
Estas informações gravadas na CF4 serão utilizadas posteriormente na geração
do arquivo texto.

@param		dDataDe 	- Data inicial do processamento
			dDataAte 	- Data Final do processamento
			cRegime 	- Regime da apuração escolhido pelo usuário
			cNrLivro 	- Livro de processamento
			aXFilial 	- Array conteúdo xFilial das tabelas de apuração									

@author Erick G. Dias
@since 08/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ASA001CANC(dDataDe, dDataAte,cRegime,cNrLivro,aXFilial,cReg)


Local 	nQtdMesAnt	:=	SuperGetMv("MV_NMCSPC",.F.,12)
Local	dCorte		:= 	SuperGetMv("MV_SPDAJCA",.F.,CTOD("01/01/2011") )
Local nMVM996TPR	:=  SuperGetMv("MV_M996TPR",.F.,1)
Local cMvDCODRSE	:= 	SuperGetMv("MV_DCODRSE", .F., "'110'") 
Local dDtCanc		:=	Firstday(dDataDe)
Local cDtAlt		:= 	SubStr(DTos(dDataDe),5,2)+SubStr(Dtos(dDataDe),1,4)
Local nX			:=  0
Local cAliasSFT	:= GetNextAlias()
local cSelect		:= ''
Local cFrom		:= ''
Local cWhere		:= ''
Local cChvSFT		:= ''
Local cCdCtPis	:= '' 
Local cCdCtCof	:= ''
Local oApurSai 
Local lCF4FLORIG	:= .F.
Local lCF4FIL	:=CF4->(ColumnPos('CF4_FLORIG')) > 0
cMvDCODRSE  := IIF(Empty(cMvDCODRSE), "'110'", cMvDCODRSE)

//Verificação se existe o 4 índice na CF4
DbSelectArea("SIX")
DbSetOrder(1)
If MsSeek("CF4" + "4")
	lCF4FLORIG	:= .T.
EndIF

dbSelectArea("CF4")
IF lCF4FLORIG
	dbSetOrder(4)
Else
	dbSetOrder(1)
EndIF
//Verifica qual será o mês inicial a ser considerado
For nX := 1 to nQtdMesAnt
	dDtCanc	:= Firstday(dDtCanc)-1
Next nX

dDtCanc	:= Firstday(dDtCanc) 

oApurSai := FISX001():New()
//Passa o regime da apuração para a classe.
oApurSai:SetFilial(aXFilial)
oApurSai:SetRegApur(Str(cReg,1))
oApurSai:SetDtIni(dDataDe)
oApurSai:SetDtFin(dDataDe)

cSelect	:=	'SFT.FT_FILIAL,	SFT.FT_ENTRADA,	SFT.FT_DTCANC,	SFT.FT_CFOP,		SFT.FT_TIPO,		SFT.FT_BASEPIS,'
cSelect	+=	'SFT.FT_CSTPIS,	SFT.FT_BASECOF,	SFT.FT_CSTCOF,	SFT.FT_ESPECIE,	SFT.FT_NRLIVRO,	SFT.FT_NFISCAL,'
cSelect	+=	'SFT.FT_SERIE,	SFT.FT_ITEM,		SFT.FT_CLIEFOR,	SFT.FT_LOJA,		SFT.FT_TIPOMOV,	SFT.FT_VALPIS,'
cSelect	+=	'SFT.FT_BASEPIS,	SFT.FT_VALCOF,	SFT.FT_BASECOF,	SFT.FT_EMISSAO,	SFT.FT_ALIQPIS,	SFT.FT_ALIQCOF,'
cSelect	+=	'SFT.FT_CFOP,		SFT.FT_CSTPIS,	SFT.FT_CSTCOF,	SFT.FT_PAUTPIS,	SFT.FT_PAUTCOF, 	SFT.FT_MVALCOF,'
cSelect	+=	'SFT.FT_MALQCOF,'
cSelect	+=	'SF3.F3_CODRSEF'

cFrom		:=	RetSqlName("SFT")+" SFT "

cFrom		+= "INNER JOIN "+RetSqlName("SF3")+" SF3 ON SF3.F3_FILIAL='"+xFilial("SF3")+"' AND SFT.FT_NFISCAL=SF3.F3_NFISCAL AND SFT.FT_SERIE=SF3.F3_SERIE AND SFT.FT_ESPECIE=SF3.F3_ESPECIE AND SFT.FT_CLIEFOR=SF3.F3_CLIEFOR AND SFT.FT_LOJA=SF3.F3_LOJA AND SFT.FT_IDENTF3=SF3.F3_IDENTFT AND SFT.FT_ENTRADA=SF3.F3_ENTRADA "

cWhere		:=	"SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
cWhere		+=	"SFT.FT_TIPOMOV='S' AND "
cWhere		+=	"SFT.FT_ENTRADA<'"+DTOS(dDataDe)+"' AND "
cWhere		+=	"SFT.FT_ENTRADA>='"+DTOS(dDtCanc)+"' AND "
cWhere		+=	"SFT.FT_DTCANC>='"+DTOS(dDataDe)+"' AND "
cWhere		+=	"SFT.FT_DTCANC<='"+DTOS(dDataAte)+"' AND "
cWhere		+=	"((SFT.FT_CFOP NOT LIKE '000' AND SFT.FT_CFOP NOT LIKE '999') OR SFT.FT_TIPO='S') AND "
cWhere		+=	"(SFT.FT_BASEPIS > 0   OR  SFT.FT_BASECOF > 0  OR SFT.FT_CFOP LIKE '7') AND SFT.FT_ESPECIE <> 'CF' AND "
If (cNrLivro<>"*")
 	cWhere += " SFT.FT_NRLIVRO = '" +cNrLivro+"' AND "
EndiF

cWhere	+=	"SF3.F3_CODRSEF NOT IN(" + cMvDCODRSE + ") AND "

cWhere		+=	"SFT.D_E_L_E_T_=' ' AND "
cWhere		+=	"SF3.D_E_L_E_T_=' '"
		  		
If cRegime $'4' //Cumulativo e não cumulativo
	If nMVM996TPR==1  .And. SF4->(ColumnPos( 'F4_TPREG' )) .And. SB1->(ColumnPos( 'B1_TPREG' ))
		cSelect	+=	" ,SF4.F4_TPREG,SB1.B1_TPREG"
		cFrom		+=	" LEFT JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND "
		cFrom		+=	" SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_ITEM=SFT.FT_ITEM "
		cFrom		+=	" LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_=' ' "
		cFrom		+=	" LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' '"
	Elseif nMVM996TPR==2 .And. SB1->(ColumnPos( 'B1_TPREG' ))
		cSelect	+=	" ,SB1.B1_TPREG"
		cFrom		+=	" LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' '"   
	Elseif nMVM996TPR==3 .And. SA1->(ColumnPos( 'A1_TPREG' ))
		cSelect	+=	" ,SA1.A1_TPREG"
		cFrom		+=	" LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND "
		cFrom		+=	" SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_=' '"
	Endif
Endif

cSelect	:= '%'+cSelect+'%'
cFrom		:= '%'+cFrom+'%'
cWhere		:= '%'+cWhere+'%'
   	
BeginSql Alias cAliasSFT
	COLUMN FT_ENTRADA AS DATE
	COLUMN FT_DTCANC AS DATE
	COLUMN FT_EMISSAO AS DATE
	SELECT			    
		%Exp:cSelect%
	FROM 
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%
EndSql

DbSelectArea (cAliasSFT)
(cAliasSFT)->(DbGoTop ())
Do While !(cAliasSFT)->(Eof ())

   	If Alltrim(AModNot((cAliasSFT)->FT_ESPECIE))=="55" .And. (cAliasSFT)->FT_DTCANC>=dCorte
   		(cAliasSFT)->(DbSkip())
   		Loop
   	EndIf
   	IF lCF4FLORIG		
		cChvSFT	:=	(cAliasSFT)->FT_FILIAL+DTOS((cAliasSFT)->FT_EMISSAO)+(cAliasSFT)->(FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM)
	Else
		cChvSFT	:=	(cAliasSFT)->(FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM)
	EndIF
   		
	//Passa o regime da operação
	If cReg == 4
		oApurSai:SetTpReg(DefRegime(nMVM996TPR,cAliasSFT))
	EndIF
	//Chama método para classe definir o regime
	oApurSai:DefRegime()
	//Passa CST de PIS para classe
	oApurSai:SetCST((cAliasSFT)->FT_CSTPIS) 	
	//Pega código da contribuição processada pela classe
	cCdCtPis:=oApurSai:CodCon()
	//Processa código da ~contribuição da COFINS
	oApurSai:SetCST((cAliasSFT)->FT_CSTCOF) 	
	//Pega código da contribuição processada pela classe
	cCdCtCof:=oApurSai:CodCon()	 
	
	If !CF4->(MsSeek(xFilial("CF4")+cChvSFT))
		RecLock ("CF4", .T.)
		CF4->CF4_FILIAL	:= xFilial("CF4")
		CF4->CF4_NOTA 		:=(cAliasSFT)->FT_NFISCAL 										// 01- NOTA FISCAL
		CF4->CF4_SERIE 	:=(cAliasSFT)->FT_SERIE  										// 02- SERIE DA NOTA FISCAL					
		CF4->CF4_ITEM 		:=(cAliasSFT)->FT_ITEM  											// 03- ITEM DA NOTA FISCAL
		CF4->CF4_CLIFOR 	:=(cAliasSFT)->FT_CLIEFOR  										// 04- CLIENTE OU FORNECEDOR
		CF4->CF4_LOJA 		:=(cAliasSFT)->FT_LOJA	  										// 05- LOJA
		CF4->CF4_TIPMOV 	:=(cAliasSFT)->FT_TIPOMOV  										// 06- TIPO DE MOVIMENTO
		CF4->CF4_VALPIS 	:=(cAliasSFT)->FT_VALPIS								  			// 07- VALOR DO PIS
		CF4->CF4_ALIPIS 	:=(cAliasSFT)->FT_ALIQPIS  										// 08- ALIQUOTA DO PIS
		CF4->CF4_BASPIS 	:=(cAliasSFT)->FT_BASEPIS  										// 09- BASE DE CALCULO DO PIS
		CF4->CF4_VALCOF 	:=(cAliasSFT)->FT_VALCOF - (cAliasSFT)->FT_MVALCOF			// 10- VALOR COFINS
		CF4->CF4_ALICOF 	:=(cAliasSFT)->FT_ALIQCOF - (cAliasSFT)->FT_MALQCOF			// 11- ALIQUOTA COFINS
		CF4->CF4_BASCOF 	:=(cAliasSFT)->FT_BASECOF  										// 12- BASE COFINS
		CF4->CF4_DATAE 	:=(cAliasSFT)->FT_ENTRADA  										// 13- DATA DE ENTRADA
		CF4->CF4_CFOP 		:=(cAliasSFT)->FT_CFOP	  										// 14- CFOP DA NOTA FISCAL
		CF4->CF4_CSTPIS 	:=(cAliasSFT)->FT_CSTPIS  										// 15- SIT. TRIBUTARIA PIS
		CF4->CF4_CSTCOF 	:=(cAliasSFT)->FT_CSTCOF 							 			// 16- SIT. TRIBUTARIA COFINS
		CF4->CF4_CONPIS 	:= cCdCtPis														// 17- COD. CONTRIBUICAO PIS
		CF4->CF4_CONCOF 	:= cCdCtCof														// 18- COD. CONTRIBUICAO COFINS
		CF4->CF4_PATPIS 	:=Iif((cAliasSFT)->FT_PAUTPIS==0,0,(cAliasSFT)->FT_PAUTPIS) // 19- VALOR PAUTA PIS
		CF4->CF4_PATCOF 	:=Iif((cAliasSFT)->FT_PAUTCOF==0,0,(cAliasSFT)->FT_PAUTCOF)	// 20- VALOR PAUTA COFINS
		CF4->CF4_ORIPIS	:=(cAliasSFT)->FT_VALPIS 										// 21- VALOR DO PIS ORIGINAL
		CF4->CF4_ORICOF	:=(cAliasSFT)->FT_VALCOF 										// 22- VALOR DO PIS ORIGINAL
		CF4->CF4_DTALT 	:= cDtAlt
		If lCF4FIL
			CF4->CF4_FLORIG 	:= (cAliasSFT)->FT_FILIAL
		EndIF
		MsUnLock ()
	Else
		RecLock ("CF4", .F.)	
		CF4->CF4_VALPIS		+=(cAliasSFT)->FT_VALPIS 									// 01- VALOR DO PIS
		CF4->CF4_ORIPIS		+=(cAliasSFT)->FT_VALPIS 									// 02- VALOR DO PIS ORIGINAL
		CF4->CF4_VALCOF		+=(cAliasSFT)->FT_VALCOF										// 03- VALOR COFINS
		CF4->CF4_ORICOF		+=(cAliasSFT)->FT_VALCOF 									// 04- VALOR DO PIS ORIGINAL
		MsUnLock ()
	EndIF	

	(cAliasSFT)->(DbSkip ())			
EndDo


oApurSai:FechaAlias(cAliasSFT)

oApurSai:EstornCanc(NAOCUMULAT)
oApurSai:EstornCanc(CUMULAT)

FreeObj(oApurSai)
oApurSai	:= Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ASA001DCF4()
Função que irá limpar a tabela CF4 antes de popular com as operações de
cancelamentos efetuadas no período, porém com emissão em períodos anteriores.

@author Erick G. Dias
@since 10/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ASA001DCF4(cDtAlt)

If !Empty(cDtAlt)	
	DbSelectArea ("CF4") 
	CF4->(DbSetOrder (2))
	CF4->(DbGoTop ())
	If CF4->( MsSeek(xFilial("CF4")+cDtAlt) )
		Do While CF4->( !Eof() .And. CF4_FILIAL==xFilial("CF4") .And. CF4_DTALT==cDtAlt )
			RecLock("CF4",.F.)
			CF4->(dbDelete())
			MsUnLock()
			CF4->(FKCommit())
	
			CF4->(DbSkip ())
		EndDo
	EndIf	
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ASA001Devo()
Esta função irá realizar tratamento das devoluções de venda e compra, 
do período atual ou de período anterior.

Devoluções de Compras Regime Não Cumulativo: 
	Estas devoluções no próprio período, deverão estornar a base de cálculo
	do crédito. Se a devolução ocorrer em período posterior, então
	deverá ser efetuado ajuste de redução de crédito na apuração.
	A devolução de compra somente terá tratamento no regime Não Cumualtivo,
	já que no regime Cumulativo não dão direito ao crédito.

Devoluções de Compras Regime Cumulativo:
	Não existem, pois as compras não dão direito ao crédito.	

Devoluções de Vendas Regime Não Cumulativo:
	As devoluções de venda neste regime sempre dão direito ao crédito, ão 
	deverá proceder com ajuste de redução da contribuição.
	A única exceção é quando a devolução de venda é feita com formulário próprio,
	ai neste caso deverá proceder com ajuste de redução do débito.
	
Devolução de vendas Regime Cumulativo:
	Neste caso se for devolução no mesmo período, deverá realizar ajuste de redução
	de base de cálculo, se for em período posterior, deverá então gerar ajuste
	de redução da contribuição.


@param 	dDataDe 	 - Data inicial do processamento
			dDataAte	 - Data Final do processamento
			cNrLivro    - Livro que deverá ser processado.
			cTpMov   	 - Tipo de movimento Entrada/Saída
			nMVM996TPR - Conteúdo do parâmetro MV_M996TPR
			cRegime    - Regime da apuração escolhido pelo usuário
			lPerAtu 	- Indica se o processamento é do período atual
			aXFilial 	- Array com conteúdo do xFilial das tabelas da apuração
			cOrigem 	- Data Final do processamento						
			lCPRBNF	- Indica que é operação CPRB
			cSPCBPSE	- Parâmetro referente ao código de recolhimento 																								
																		
@author Erick G. Dias
@since 10/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ASA001Devo(dDataDe,dDataAte,cNrLivro,cTpMov,nMVM996TPR,cRegime,lPerAtu,aXFilial,cOrigem,lCPRBNF,cSPCBPSE)

Local cAliasSFT	:= 'SFT'
Local cSerOri		:=	''
Local cNotaOri	:=	''
Local cIteOri		:=	''
Local cRegDev		:= ''
Local cCodCon		:= ''
Local cDescr		:= ''
Local cCodCred	:= ''
Local cChave		:= ''
Local cDtAlt		:= 	SubStr(DTos(dDataDe),5,2)+SubStr(Dtos(dDataDe),1,4)
Local aAreaSFT	:= {}
Local cTpMovQry	:= Iif(cTpMov=="S","E","S")
Local lGravaCF4	:= .F.
Local oAjuCred
Local oAjuDeb
Local oApurEFD
Local lCF4FLORIG	:= .F.
Local lCF4FIL		:=CF4->(ColumnPos('CF4_FLORIG')) > 0
Local lAtuCPRB	:= .F.
Local lBlocoD := .F. 
Local nBaseCalc	:= 0
Local nAlq	:= 0
Local nBseTot := 0
Local nValCrd := 0
Local nBseProp := 0

//Verificação se existe o 4 índice na CF4
DbSelectArea("SIX")
DbSetOrder(1)
If MsSeek("CF4" + "4")
	lCF4FLORIG	:= .T.
EndIF

oAjuCred	:= AJUSTEEFD():New()
oAjuCred:SetFilial(aXFilial)
oAjuCred:SetDtIni(dDataDe)
oAjuCred:SetCrdDeb(CREDITO) //crédito
oAjuCred:LoadCL8()

oApurEFD := FISX001():New()
//Passa o regime da apuração para a classe.
oApurEFD:SetFilial(aXFilial)
oApurEFD:SetRegApur(cRegime)
oApurEFD:SetDtIni(dDataDe)
oApurEFD:SetDtFin(dDataAte)
oApurEFD:LoadRecBru()

oAjuDeb	:= AJUSTEEFD():New()
oAjuDeb:SetFilial(aXFilial)
oAjuDeb:SetDtIni(dDataDe)
oAjuDeb:SetCrdDeb(DEBITO) //débito
oAjuDeb:LoadCKS()

If lCPRBNF
	oCPRB	:= CPRBEFD():New()
	oCPRB:SetDtIni(dDataDe)
Endif

dbSelectArea("CF4")
IF lCF4FLORIG
	dbSetOrder(4)
Else
	dbSetOrder(1)
EndIF


//CHAMA FUNÇÃO QUE FAZ QUERY PARA BUSCAR AS DEVOLUÇÕES
cAliasSFT	:= QRYDEVOL(dDataDe,dDataAte,cTpMovQry,cNrLivro,cRegime,nMVM996TPR)

Do While !(cAliasSFT)->(Eof ())
	cClie:= (cAliasSFT)->FT_CLIEFOR
	SFT->(DbSetOrder(6))
    //FT_FILIAL+FT_TIPOMOV+FT_NFISCAL+FT_SERIE 
    IF SFT->(MsSeek(xFilial("SFT")+cTpMov+Alltrim((cAliasSFT)->FT_NFORI+(cAliasSFT)->FT_SERORI))) .And. cTpMov == "S"
    	//Busca o código do cliente, pois existem casos nas devoluções de cupom fiscal onde o 
    	//código do fornecedor não é o mesmo da venda, por isso busca da nota original.
    	cClie:= SFT->FT_CLIEFOR
    EndIF 
	             	    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Para as devolucoes de venda, preciso verificar qual o regime da operacao  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cTpMov == "S"
		
		IF cRegime == "4"
			cRegDev := DefRegime(nMVM996TPR,cAliasSFT)		
		Elseif cRegime == "2"
			cRegDev := "2"
		Else
			cRegDev := "1"
		Endif
	Endif
		
	SFT->(DbSetOrder(1))
	aAreaSFT	:= SFT->(GetArea())
	cNotaOri	:=	(cAliasSFT)->FT_NFISCAL
	cIteOri	:=	(cAliasSFT)->FT_ITEM
	cSerOri	:= (cAliasSFT)->FT_SERIE
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Posiciono na nota fiscal original, para calcular a porcentagem de devolucao³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SFT->(MsSeek(xFilial("SFT")+cTpMov+(cAliasSFT)->(FT_SERORI+FT_NFORI+cClie+FT_LOJA+FT_ITEMORI+FT_PRODUTO))) .And.;
		SFT->FT_VALPIS > 0 .OR. SFT->FT_VALCOF  > 0		

		IF (cAliasSFT)->FT_BASEPIS > 0 .AND. (cAliasSFT)->FT_BASEPIS <= SFT->FT_BASEPIS
			nPercDevP :=	(cAliasSFT)->FT_BASEPIS / SFT->FT_BASEPIS
		Else
			nPercDevP := (((cAliasSFT)->FT_QUANT * 100) / SFT->FT_QUANT ) / 100
		EndIF			
					
		IF (cAliasSFT)->FT_BASECOF > 0 .AND. (cAliasSFT)->FT_BASECOF <= SFT->FT_BASECOF
			nPercDevC := (cAliasSFT)->FT_BASECOF / SFT->FT_BASECOF
		Else
			nPercDevC := (((cAliasSFT)->FT_QUANT * 100) / SFT->FT_QUANT ) / 100
		EndIF
		
		lBlocoD := If(aModNot(Alltrim(SFT->FT_ESPECIE)) $ '07|08|8B|09|10|11|26|27|57', .T., .F.)			
		nBseTot := 0
		nValCrd := 0
		nBseProp := 0			
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Devolucao no proprio periodo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If DTOS(SFT->FT_ENTRADA) >= DTOS(dDataDe) .And. DTOS(SFT->FT_ENTRADA) <= DTOS(dDataAte) .And. !lBlocoD
			
			//Somente irá gravar a nota de devolução na tabela CF4 se a nota original realmente foi considerada
			//para apuração de PIS e COFINS, para poder efetuar a redução da base de cálculo, caso contrário
			//não fará redução e não grava CF4.
			lGravaCF4	:= .F.
			
			If cTpMov == 'S' .AND. oApurEFD:ChkRegraNf(SFT->FT_ESPECIE,SFT->FT_CFOP,NFSAIDA)

				lGravaCF4	:= IIF(SFT->FT_CSTPIS  $ cCstTrib,.T. ,.F.  )			
			ElseIF cTpMov == 'E' .AND. oApurEFD:ChkEspecie(AModNot(SFT->FT_ESPECIE))

				lGravaCF4	:= IIF(SFT->FT_CSTPIS  $ cCSTCRED,.T. ,.F.  )			
			EndIF

			If lGravaCF4 .AND. lPerAtu
				
				If lCF4FLORIG
					//CF4_FLORIG+DTOS(CF4_DATAE)+CF4_TIPMOV+CF4_SERIE+CF4_NOTA+CF4_CLIFOR+CF4_LOJA+CF4_ITEM
					cChvSFT	:=	SFT->FT_FILIAL+DTOS(SFT->FT_EMISSAO)+SFT->(FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM)
				Else				
					//CF4_TIPMOV+CF4_SERIE+CF4_NOTA+CF4_CLIFOR+CF4_LOJA+CF4_ITEM
					cChvSFT	:=	SFT->(FT_TIPOMOV+FT_SERIE+FT_NFISCAL+FT_CLIEFOR+FT_LOJA+FT_ITEM)
				EndIF
				
				If !CF4->(MsSeek(xFilial("CF4")+cChvSFT))
					RecLock ("CF4", .T.)
					CF4->CF4_FILIAL	:= xFilial("CF4")
					CF4->CF4_NOTA 		:=SFT->FT_NFISCAL 										// 01- NOTA FISCAL
					CF4->CF4_SERIE 	:=SFT->FT_SERIE  										// 02- SERIE DA NOTA FISCAL					
					CF4->CF4_ITEM 		:=SFT->FT_ITEM  											// 03- ITEM DA NOTA FISCAL
					CF4->CF4_CLIFOR 	:=SFT->FT_CLIEFOR  										// 04- CLIENTE OU FORNECEDOR
					CF4->CF4_LOJA 		:=SFT->FT_LOJA	  										// 05- LOJA
					CF4->CF4_TIPMOV 	:=SFT->FT_TIPOMOV  										// 06- TIPO DE MOVIMENTO
					CF4->CF4_VALPIS 	:=Round(SFT->FT_VALPIS*nPercDevP,2)					// 07- VALOR DO PIS
					CF4->CF4_ALIPIS 	:=SFT->FT_ALIQPIS  										// 08- ALIQUOTA DO PIS
					CF4->CF4_VALCOF 	:=Round(SFT->FT_VALCOF*nPercDevC,2)					// 10- VALOR COFINS
					CF4->CF4_ALICOF 	:=SFT->FT_ALIQCOF											// 11- ALIQUOTA COFINS
					CF4->CF4_DATAE 	:=SFT->FT_EMISSAO  										// 13- DATA DE ENTRADA
					CF4->CF4_CSTPIS 	:=SFT->FT_CSTPIS  										// 15- SIT. TRIBUTARIA PIS
					CF4->CF4_CSTCOF 	:=SFT->FT_CSTCOF 							 				// 16- SIT. TRIBUTARIA COFINS
					CF4->CF4_PATPIS 	:=Iif(SFT->FT_PAUTPIS==0,0,SFT->FT_PAUTPIS) 			// 19- VALOR PAUTA PIS
					CF4->CF4_PATCOF 	:=Iif(SFT->FT_PAUTCOF==0,0,SFT->FT_PAUTCOF)			// 20- VALOR PAUTA COFINS					
					CF4->CF4_BASPIS	:= Round(SFT->FT_BASEPIS*nPercDevP,2)
					CF4->CF4_BASCOF	:= Round(SFT->FT_BASECOF*nPercDevP,2)					
					CF4->CF4_TIPO		:= 'D'
					CF4->CF4_DTALT 	:= cDtAlt
					
					IF lCF4FIL
						CF4->CF4_FLORIG	:= SFT->FT_FILIAL
					EndIF
						
					MsUnLock ()
				Else
					RecLock ("CF4", .F.)	
					CF4->CF4_VALPIS		+=Round(SFT->FT_VALPIS*nPercDevP,2)	
					CF4->CF4_VALCOF		+=Round(SFT->FT_VALCOF*nPercDevC,2)
					CF4->CF4_BASPIS		+=Round(SFT->FT_BASEPIS*nPercDevP,2)	
					CF4->CF4_BASCOF		+=Round(SFT->FT_BASECOF*nPercDevP,2)						
				
					MsUnLock ()
				EndIF
				
				If cTpMov == 'S' .and. (cRegime $ '2/4' .OR.	(cAliasSFT)->FT_FORMUL == 'S')			
					oApurEFD:Clear()
					//Realiza o estorno da contribuição considerando as devoluções de venda no próprio período.

					//PROCESSA ESTORNO DE PIS
					oApurEFD:SetTributo(PIS)
					oApurEFD:SetAlqTrib(SFT->FT_ALIQPIS)
					oApurEFD:SetCST(SFT->FT_CSTPIS)
					
					//Verifica se documento original é Cupom Fiscal
					If !Empty(SFT->FT_PDV) .AND. AllTrim(SFT->FT_ESPECIE)$"CF/ECF"
						oApurEFD:SetOrigem(CUPOM)					
					Else
						oApurEFD:SetOrigem(FISCALSAI)					
					EndIF					
					oApurEFD:SetTpReg(cRegDev)					
					oApurEFD:DefRegime()
					oApurEFD:SetCodDC(oApurEFD:CodCon())
					cChave	:=	oApurEFD:BuscaChave()
					oApurEFD:ReduzBase(Round(SFT->FT_BASEPIS*nPercDevP,2),Round(SFT->FT_VALPIS*nPercDevP,2),DEBITO,cChave, SFT->FT_CSTPIS,SFT->FT_CODBCC,Iif(SFT->FT_PAUTPIS > 0,'1','2'))
					oApurEFD:ReduzCL0(Round(SFT->FT_BASEPIS*nPercDevP,2),Round(SFT->FT_VALCONT*nPercDevP,2))	
										
					
					//PROCESSA ESTORNO DA COFINS					
					oApurEFD:SetTributo(COFINS)
					oApurEFD:SetAlqTrib(SFT->FT_ALIQCOF)
					oApurEFD:SetCST(SFT->FT_CSTCOF)
					//Verifica se documento original é Cupom Fiscal
					If !Empty(SFT->FT_PDV) .AND. AllTrim(SFT->FT_ESPECIE)$"CF/ECF"
						oApurEFD:SetOrigem(CUPOM)					
					Else
						oApurEFD:SetOrigem(FISCALSAI)					
					EndIF	
					oApurEFD:SetTpReg(cRegDev)					
					oApurEFD:DefRegime()
					oApurEFD:SetCodDC(oApurEFD:CodCon())
					cChave	:=	oApurEFD:BuscaChave()
					oApurEFD:ReduzBase(Round(SFT->FT_BASECOF*nPercDevP,2),Round(SFT->FT_VALCOF*nPercDevP,2),DEBITO,cChave, SFT->FT_CSTCOF,SFT->FT_CODBCC,Iif(SFT->FT_PAUTCOF > 0,'1','2'))	
					//oApurEFD:ReduzCL0(Round(SFT->FT_BASECOF*nPercDevP,2),Round(SFT->FT_VALCONT*nPercDevP,2))					
						
				ElseIf cTpMov == 'E' .AND. cRegime $ '1/4'
				
					oApurEFD:Clear() 
					
					oApurEFD:SetTributo(PIS)
					oApurEFD:SetAlqTrib(SFT->FT_ALIQPIS)
					oApurEFD:SetOrigem(FISCALENT)
					oApurEFD:SetTpReg(NAOCUMULAT)
					oApurEFD:SetCST(SFT->FT_CSTPIS)
					oApurEFD:SetCodBcc(SFT->FT_CODBCC)
					oApurEFD:SetPauta(Iif(SFT->FT_PAUTPIS > 0 ,'1' ,'' ))
					oApurEFD:SetImport(IIF(SubStr(SFT->FT_CFOP,1,1) == '3' ,.T.,.F. ))
					oApurEFD:SetAlqBas(Iif(SFT->FT_ALIQPIS == 0.65 .OR. SFT->FT_ALIQPIS == 1.65 ,'1' ,'2'))
					oApurEFD:SetTNatRec(SFT->FT_TNATREC)
					oApurEFD:SetCNatRec(SFT->FT_CNATREC)		
					oApurEFD:SetGNatRec(SFT->FT_GRUPONC)
					oApurEFD:SetDNatRec(SFT->FT_DTFIMNT)
					oApurEFD:DefRegime() 			
						
					oApurEFD:ReduzCL0(Round(SFT->FT_BASEPIS*nPercDevP,2),Round(SFT->FT_VALCONT*nPercDevP,2))										
					
					// Tributado no mercado interno
					If SFT->FT_CSTPIS $ '50|60|53|63|54|64|56|66'						
						oApurEFD:SetCodDC('1' + oApurEFD:CodCred())
						cChave	:=	oApurEFD:BuscaChave()
						nBseTot := Round(SFT->FT_BASEPIS * nPercDevP, 2) 
						nValCrd := Round(SFT->FT_VALPIS * nPercDevP * oApurEFD:CalcBAseRC('1'), 2)
						nBseProp := Round(SFT->FT_BASEPIS * nPercDevP * oApurEFD:CalcBAseRC('1'), 2) // Base proporcional vinculada ao tipo de credito.
						oApurEFD:ReduzBase(nBseTot,nValCrd,CREDITO,cChave,SFT->FT_CSTPIS,SFT->FT_CODBCC,Iif(SFT->FT_PAUTPIS > 0,'1','2'),nBseProp)								
					EndIF
					
					// Não Tributado no mercado interno
					If SFT->FT_CSTPIS $ '51|61|53|63|55|65|56|66'
						oApurEFD:SetCodDC('2' + oApurEFD:CodCred())
						cChave	:=	oApurEFD:BuscaChave()
						nBseTot := Round(SFT->FT_BASEPIS * nPercDevP, 2) 
						nValCrd := Round(SFT->FT_VALPIS * nPercDevP * oApurEFD:CalcBAseRC('2'), 2)
						nBseProp := Round(SFT->FT_BASEPIS * nPercDevP * oApurEFD:CalcBAseRC('2'), 2) // Base proporcional vinculada ao tipo de credito.
						oApurEFD:ReduzBase(nBseTot,nValCrd,CREDITO,cChave,SFT->FT_CSTPIS,SFT->FT_CODBCC,Iif(SFT->FT_PAUTPIS > 0,'1','2'),nBseProp)							
					EndIF
					
					// Exportacao
					If SFT->FT_CSTPIS $ '52|62|54|64|55|65|56|66'
						oApurEFD:SetCodDC('3' + oApurEFD:CodCred())
						cChave	:=	oApurEFD:BuscaChave()
						nBseTot := Round(SFT->FT_BASEPIS * nPercDevP, 2) 
						nValCrd := Round(SFT->FT_VALPIS * nPercDevP * oApurEFD:CalcBAseRC('3'), 2)
						nBseProp := Round(SFT->FT_BASEPIS * nPercDevP * oApurEFD:CalcBAseRC('3'), 2) // Base proporcional vinculada ao tipo de credito.
						oApurEFD:ReduzBase(nBseTot,nValCrd,CREDITO,cChave,SFT->FT_CSTPIS,SFT->FT_CODBCC,Iif(SFT->FT_PAUTPIS > 0,'1','2'),nBseProp)				
					EndIF														
															
					oApurEFD:SetTributo(COFINS)
					oApurEFD:SetAlqTrib(SFT->FT_ALIQCOF)
					oApurEFD:SetOrigem(FISCALENT)
					oApurEFD:SetTpReg(NAOCUMULAT)
					oApurEFD:SetCST(SFT->FT_CSTCOF)
					oApurEFD:SetCodBcc(SFT->FT_CODBCC)
					oApurEFD:SetPauta(Iif(SFT->FT_PAUTCOF > 0 ,'1' ,'' ))
					oApurEFD:SetImport(IIF(SubStr(SFT->FT_CFOP,1,1) == '3' ,.T.,.F. ))
					oApurEFD:SetAlqBas(Iif(SFT->FT_ALIQCOF == 3 .OR. SFT->FT_ALIQCOF == 7.6 ,'1' ,'2'))
					oApurEFD:SetTNatRec(SFT->FT_TNATREC)
					oApurEFD:SetCNatRec(SFT->FT_CNATREC)		
					oApurEFD:SetGNatRec(SFT->FT_GRUPONC)
					oApurEFD:SetDNatRec(SFT->FT_DTFIMNT)
					oApurEFD:DefRegime()
										
					//oApurEFD:ReduzCL0(Round(SFT->FT_BASECOF*nPercDevP,2),Round(SFT->FT_VALCONT*nPercDevP,2))
					
					// Tributado no mercado interno
					If SFT->FT_CSTCOF $ '50|60|53|63|54|64|56|66'
						oApurEFD:SetCodDC('1' + oApurEFD:CodCred())
						cChave	:=	oApurEFD:BuscaChave()
						nBseTot := Round(SFT->FT_BASECOF * nPercDevP, 2) 
						nValCrd := Round(SFT->FT_VALCOF * nPercDevP * oApurEFD:CalcBAseRC('1'), 2)
						nBseProp := Round(SFT->FT_BASECOF * nPercDevP * oApurEFD:CalcBAseRC('1'), 2) // Base proporcional vinculada ao tipo de credito. 
						oApurEFD:ReduzBase(nBseTot,nValCrd,CREDITO,cChave,SFT->FT_CSTCOF,SFT->FT_CODBCC,Iif(SFT->FT_PAUTCOF > 0,'1','2'),nBseProp) 					
					EndIF
					
					// Não Tributado no mercado interno
					If SFT->FT_CSTCOF $ '51|61|53|63|55|65|56|66'
						oApurEFD:SetCodDC('2' + oApurEFD:CodCred())
						cChave	:=	oApurEFD:BuscaChave()
						nBseTot := Round(SFT->FT_BASECOF * nPercDevP, 2) 
						nValCrd := Round(SFT->FT_VALCOF * nPercDevP * oApurEFD:CalcBAseRC('2'), 2)
						nBseProp := Round(SFT->FT_BASECOF * nPercDevP * oApurEFD:CalcBAseRC('2'), 2) // Base proporcional vinculada ao tipo de credito. 
						oApurEFD:ReduzBase(nBseTot,nValCrd,CREDITO,cChave,SFT->FT_CSTCOF,SFT->FT_CODBCC,Iif(SFT->FT_PAUTCOF > 0,'1','2'),nBseProp) 
					EndIF		
					
					// Exportacao
					If SFT->FT_CSTCOF $ '52|62|54|64|55|65|56|66'
						oApurEFD:SetCodDC('3' + oApurEFD:CodCred())
						cChave	:=	oApurEFD:BuscaChave()
						nBseTot := Round(SFT->FT_BASECOF * nPercDevP, 2) 
						nValCrd := Round(SFT->FT_VALCOF * nPercDevP * oApurEFD:CalcBAseRC('3'), 2)
						nBseProp := Round(SFT->FT_BASECOF * nPercDevP * oApurEFD:CalcBAseRC('3'), 2) // Base proporcional vinculada ao tipo de credito. 
						oApurEFD:ReduzBase(nBseTot,nValCrd,CREDITO,cChave,SFT->FT_CSTCOF,SFT->FT_CODBCC,Iif(SFT->FT_PAUTCOF > 0,'1','2'),nBseProp)			
					EndIF
					
					oApurEFD:SetImport(.F.)					
				
				EndIF
				
			EndIF
				
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Devolucao em outro periodo  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
		Else
			If cTpMov == "E" .AND. !lPerAtu
								
				cDescr	:=  "Dev. comp. ref. doc.:" + AllTrim(SFT->FT_NFISCAL) + ",série:" + AllTrim(SFT->FT_SERIE)
				cDescr +=  ",item:" + AllTrim(SFT->FT_ITEM) + ", Filial:" + SFT->FT_FILIAL  +",Doc. Dev.:" + AllTrim((cAliasSFT)->FT_NFISCAL)
				cDescr +=  ",série:" + AllTrim((cAliasSFT)->FT_SERIE) + ", item:" + Alltrim((cAliasSFT)->FT_ITEM) 

				//------------------------------------------------
				//PASSA INFORMAÇÕES PARA OBTER O CÓDIGO DO CRÉDITO
				//------------------------------------------------
				oApurEFD:SetCST(SFT->FT_CSTPIS)
				oApurEFD:SetCodBcc(SFT->FT_CODBCC)
				oApurEFD:SetPauta(Iif(SFT->FT_PAUTPIS > 0 ,'1' ,'' ))
				oApurEFD:SetImport(IIF(SubStr(SFT->FT_CFOP,1,1) == '3' ,.T.,.F. ))
				oApurEFD:SetAlqBas(Iif(SFT->FT_ALIQPIS == 0.65 .OR. SFT->FT_ALIQPIS == 1.65 ,'1' ,'2'))
				oApurEFD:SetTNatRec(SFT->ft_tnatrec)
				oApurEFD:SetCNatRec(SFT->ft_cnatrec)		
				oApurEFD:SetGNatRec(SFT->ft_gruponc)
				oApurEFD:SetDNatRec(SFT->FT_DTFIMNT)
				oApurEFD:SetQtde(SFT->FT_QUANT)
				oApurEFD:SetVlPauta(SFT->ft_pautPIS)
				
				//Considera alíquota e base de cálculo considerando cálculo alíquota com percentual
				nBaseCalc	:= SFT->FT_BASEPIS
				nAlq		:= SFT->FT_ALIQPIS
				
				If oApurEFD:OperPauta()
					//Busca a base de cálculo e alíquota em quantidade convertida em quantidade e em reais respectivamente
					nBaseCalc	:= oApurEFD:GetBcTrib()
					nAlq		:= oApurEFD:GetAlqTrib()
				EndIF
				cCodCred := oApurEFD:CodCred()

				//---------------------
				//FAZ OS AJUSTES DE PIS
				//---------------------
				oAjuCred:SetTributo(PIS)
				oAjuCred:SetTpAjust(REDUCAO)
				oAjuCred:SetCodAju('06')
				oAjuCred:SetNumDoc(SFT->FT_NFISCAL)
				oAjuCred:SetDescAju(cDescr)
				oAjuCred:SetDtRefer((cAliasSFT)->FT_ENTRADA)
				oAjuCred:SetOrigem('C') //Devolução de compra de período anterior		 //ok
				oAjuCred:SetNumDev((cAliasSFT)->FT_NFISCAL)
				oAjuCred:SetNumOri(SFT->FT_NFISCAL)
				oAjuCred:SetCst(SFT->FT_CSTPIS)
				oAjuCred:SetConta(SFT->FT_CONTA)
				oAjuCred:SetInfComp('Ajuste de redução de crédito de PIS em função da devolução de compra de período anterior')
				oAjuCred:SetAlq(nAlq)

				//-----------------------------------------------------
				//FAZ AJUSTE COM CÓDIGO DE TRIBUTADO NO MERCADO INTERNO
				//-----------------------------------------------------
				If SFT->FT_CSTPIS $ '50|60|53|63|54|64|56|66'
					oAjuCred:SetCodDC('1'+cCodCred)
					oAjuCred:SetVlAju( Round(SFT->FT_VALPIS*nPercDevP * oApurEFD:CalcBAseRC('1'),2))
					oAjuCred:SetBase(Round(nBaseCalc * nPercDevP * oApurEFD:CalcBAseRC('1'),2))
					oAjuCred:Ajustar()								
				EndIF

				//---------------------------------------------------------
				//FAZ AJUSTE COM CÓDIGO DE NÃO TRIBUTADO NO MERCADO INTERNO
				//---------------------------------------------------------
				If SFT->FT_CSTPIS $ '51|61|53|63|55|65|56|66'
					oAjuCred:SetCodDC('2'+cCodCred)
					oAjuCred:SetVlAju( Round(SFT->FT_VALPIS*nPercDevP * oApurEFD:CalcBAseRC('2'),2))
					oAjuCred:SetBase(Round(nBaseCalc * nPercDevP * oApurEFD:CalcBAseRC('2'),2))
					oAjuCred:Ajustar()							
				EndIF			

				//--------------------------------
				//FAZ AJUSTE COM CÓDIGO EXPORTAÇÃO
				//--------------------------------				
				If SFT->FT_CSTPIS $ '52|62|54|64|55|65|56|66'
					oAjuCred:SetCodDC('3'+cCodCred)
					oAjuCred:SetVlAju( Round(SFT->FT_VALPIS*nPercDevP * oApurEFD:CalcBAseRC('3'),2))
					oAjuCred:SetBase(Round(nBaseCalc * nPercDevP * oApurEFD:CalcBAseRC('3'),2))
					oAjuCred:Ajustar()				
				EndIF
	
				//--------------------------------------------------------
				//PASSA INFORMAÇÕES PARA OBTER CÓDIGO DE CRÉDITO DA COFINS
				//--------------------------------------------------------
				oApurEFD:SetCST(SFT->FT_CSTCOF)
				oApurEFD:SetCodBcc(SFT->FT_CODBCC)
				oApurEFD:SetPauta(Iif(SFT->FT_PAUTCOF > 0 ,'1' ,'' ))
				oApurEFD:SetImport(IIF(SubStr(SFT->FT_CFOP,1,1) == '3' ,.T.,.F. ))
				oApurEFD:SetAlqBas(Iif(SFT->FT_ALIQCOF == 3 .OR. SFT->FT_ALIQCOF == 7.6 ,'1' ,'2'))
				oApurEFD:SetTNatRec(SFT->ft_tnatrec)
				oApurEFD:SetCNatRec(SFT->ft_cnatrec)		
				oApurEFD:SetGNatRec(SFT->ft_gruponc)
				oApurEFD:SetDNatRec(SFT->FT_DTFIMNT)
				oApurEFD:SetQtde(SFT->FT_QUANT)
				oApurEFD:SetVlPauta(SFT->ft_pautCOF)
				
				//Considera alíquota e base de cálculo considerando cálculo alíquota com percentual
				nBaseCalc	:= SFT->FT_BASECOF
				nAlq		:= SFT->FT_ALIQCOF
				
				If oApurEFD:OperPauta()
					//Busca a base de cálculo e alíquota em quantidade convertida em quantidade e em reais respectivamente
					nBaseCalc	:= oApurEFD:GetBcTrib()
					nAlq		:= oApurEFD:GetAlqTrib()
				EndIF
				cCodCred := oApurEFD:CodCred()
				
				//------------------------
				//REALIZA AJUSTE DA COFINS
				//------------------------
				oAjuCred:SetTributo(COFINS)
				oAjuCred:SetTpAjust(REDUCAO)
				oAjuCred:SetCodAju('06')
				oAjuCred:SetNumDoc(SFT->FT_NFISCAL)
				oAjuCred:SetDescAju(cDescr)
				oAjuCred:SetDtRefer((cAliasSFT)->FT_ENTRADA)			
				oAjuCred:SetOrigem('E') //Devolução de compra de período anterior		 //ok
				oAjuCred:SetNumDev((cAliasSFT)->FT_NFISCAL)
				oAjuCred:SetNumOri(SFT->FT_NFISCAL)
				
				//---------------------------------------------------------
				//DETALHAMENTO DOS AJUSTES COM INFORMAÇÕES DA NOTA ORIGINAL
				//---------------------------------------------------------
				oAjuCred:SetCst(SFT->FT_CSTCOF)
				oAjuCred:SetConta(SFT->FT_CONTA)
				oAjuCred:SetInfComp('Ajuste de redução de crédito de COFINS em função de devolução de compra de período anterior')
				oAjuCred:SetAlq(nAlq) 

				//-----------------------------------------------------
				//FAZ AJUSTE COM CÓDIGO DE TRIBUTADO NO MERCADO INTERNO
				//-----------------------------------------------------
				If SFT->FT_CSTCOF $ '50|60|53|63|54|64|56|66'
					oAjuCred:SetCodDC('1'+cCodCred)
					oAjuCred:SetVlAju( Round(SFT->FT_VALCOF*nPercDevP * oApurEFD:CalcBAseRC('1'),2))
					oAjuCred:SetBase(Round(nBaseCalc * nPercDevP * oApurEFD:CalcBAseRC('1'),2))
					oAjuCred:Ajustar()								
				EndIF

				//---------------------------------------------------------
				//FAZ AJUSTE COM CÓDIGO DE NÃO TRIBUTADO NO MERCADO INTERNO
				//---------------------------------------------------------
				If SFT->FT_CSTCOF $ '51|61|53|63|55|65|56|66'
					oAjuCred:SetCodDC('2'+cCodCred)
					oAjuCred:SetVlAju( Round(SFT->FT_VALCOF*nPercDevP * oApurEFD:CalcBAseRC('2'),2))
					oAjuCred:SetBase(Round(nBaseCalc * nPercDevP * oApurEFD:CalcBAseRC('2'),2))					
					oAjuCred:Ajustar()							
				EndIF		
				
				//--------------------------------
				//FAZ AJUSTE COM CÓDIGO EXPORTAÇÃO
				//--------------------------------
				If SFT->FT_CSTCOF $ '52|62|54|64|55|65|56|66'
					oAjuCred:SetCodDC('3'+cCodCred)
					oAjuCred:SetVlAju( Round(SFT->FT_VALCOF*nPercDevP * oApurEFD:CalcBAseRC('3'),2))
					oAjuCred:SetBase(Round(nBaseCalc * nPercDevP * oApurEFD:CalcBAseRC('3'),2))					
					oAjuCred:Ajustar()				
				EndIF
				
				oApurEFD:SetImport(.F.)
				
			ElseIf cTpMov == 'S' .AND. !lPerAtu
				
				cDescr	:=  "Dev. venda. ref. doc.:" + AllTrim(SFT->FT_NFISCAL) + ",série:" + AllTrim(SFT->FT_SERIE)
				cDescr +=  ",item:" + AllTrim(SFT->FT_ITEM) + ", Filial:" + SFT->FT_FILIAL  +",Doc. Dev.:" + AllTrim((cAliasSFT)->FT_NFISCAL)
				cDescr +=  ",série:" + AllTrim((cAliasSFT)->FT_SERIE) + ", item:" + Alltrim((cAliasSFT)->FT_ITEM)
				
				//Passa o regime da operação
				oApurEFD:SetTpReg(cRegDev)
				//Chama método para classe definir o regime
				oApurEFD:DefRegime()

				//Passa CSTde PIS para classe
				oApurEFD:SetCST(SFT->FT_CSTPIS) 	
				//Pega código da contribuição processada pela classe
				cCodCon:=oApurEFD:CodCon()

				oApurEFD:SetTNatRec(SFT->ft_tnatrec)
				oApurEFD:SetCNatRec(SFT->ft_cnatrec)		
				oApurEFD:SetGNatRec(SFT->ft_gruponc)
				oApurEFD:SetDNatRec(SFT->FT_DTFIMNT)
				oApurEFD:SetQtde(SFT->FT_QUANT)
				oApurEFD:SetVlPauta(SFT->ft_pautPIS)

				//Considera alíquota e base de cálculo considerando cálculo alíquota com percentual
				nBaseCalc	:= SFT->FT_BASEPIS
				nAlq		:= SFT->FT_ALIQPIS
				
				If oApurEFD:OperPauta()
					//Busca a base de cálculo e alíquota em quantidade convertida em quantidade e em reais respectivamente
					nBaseCalc	:= oApurEFD:GetBcTrib()
					nAlq		:= oApurEFD:GetAlqTrib()
				EndIF

				//Realiza Ajuste para o PIS
				oAjuDeb:SetTributo(PIS)
				oAjuDeb:SetTpAjust(REDUCAO)
				oAjuDeb:SetCodAju('06')
				oAjuDeb:SetNumDoc((cAliasSFT)->FT_NFISCAL)
				oAjuDeb:SetDescAju(cDescr)
				oAjuDeb:SetDtRefer((cAliasSFT)->FT_ENTRADA)
				oAjuDeb:SetCodDC(cCodCon)
				oAjuDeb:SetRegime(cRegDev)
				oAjuDeb:SetOrigem(cOrigem)		
				oAjuDeb:SetVlAju(IIf(SFT->FT_QUANT==(cAliasSFT)->FT_QUANT, SFT->FT_VALPIS, (cAliasSFT)->FT_QUANT*SFT->FT_VALPIS/SFT->FT_QUANT))
				oAjuDeb:SetNumDev((cAliasSFT)->FT_NFISCAL)
				oAjuDeb:SetNumOri(SFT->FT_NFISCAL)
				oAjuDeb:SetCst(SFT->FT_CSTCOF)
				oAjuDeb:SetConta(SFT->FT_CONTA)
				oAjuDeb:SetInfComp('Ajuste de redução de débito de PIS em função de retorno de mercadoria vendida em período anterior')
				oAjuDeb:SetBase(Round(nBaseCalc*nPercDevP,2))
				oAjuDeb:SetAlq(nAlq)
				oAjuDeb:Ajustar()				

				//Processa código da ~contribuição da COFINS
				oApurEFD:SetCST(SFT->FT_CSTCOF) 	
				//Pega código da contribuição processada pela classe
				cCodCon:=oApurEFD:CodCon()	
				 oApurEFD:SetTNatRec(SFT->ft_tnatrec)
				oApurEFD:SetCNatRec(SFT->ft_cnatrec)		
				oApurEFD:SetGNatRec(SFT->ft_gruponc)
				oApurEFD:SetDNatRec(SFT->FT_DTFIMNT)
				oApurEFD:SetQtde(SFT->FT_QUANT)
				oApurEFD:SetVlPauta(SFT->ft_pautcof)

				//Considera alíquota e base de cálculo considerando cálculo alíquota com percentual
				nBaseCalc	:= SFT->FT_BASECOF
				nAlq		:= SFT->FT_ALIQCOF
				
				If oApurEFD:OperPauta()
					//Busca a base de cálculo e alíquota em quantidade convertida em quantidade e em reais respectivamente
					nBaseCalc	:= oApurEFD:GetBcTrib()
					nAlq		:= oApurEFD:GetAlqTrib()
				EndIF
								
				//Realiza Ajuste para a COFINS
				oAjuDeb:SetTributo(COFINS)
				oAjuDeb:SetTpAjust(REDUCAO)
				oAjuDeb:SetCodAju('06')
				oAjuDeb:SetNumDoc((cAliasSFT)->FT_NFISCAL)
				oAjuDeb:SetDescAju(cDescr)
				oAjuDeb:SetDtRefer((cAliasSFT)->FT_ENTRADA)
				oAjuDeb:SetCodDC(cCodCon)
				oAjuDeb:SetRegime(cRegDev)
				oAjuDeb:SetOrigem(cOrigem)
				oAjuDeb:SetVlAju(IIf(SFT->FT_QUANT==(cAliasSFT)->FT_QUANT, SFT->FT_VALCOF, (cAliasSFT)->FT_QUANT*SFT->FT_VALCOF/SFT->FT_QUANT))
				oAjuDeb:SetNumDev((cAliasSFT)->FT_NFISCAL)
				oAjuDeb:SetNumOri(SFT->FT_NFISCAL)
				oAjuDeb:SetCst(SFT->FT_CSTCOF)
				oAjuDeb:SetConta(SFT->FT_CONTA)
				oAjuDeb:SetInfComp('Ajuste de redução de débito de COFINS em função de retorno de mercadoria vendida em período anterior')
				oAjuDeb:SetBase(Round(nBaseCalc*nPercDevP,2))
				oAjuDeb:SetAlq(nAlq)
				oAjuDeb:Ajustar()

				//Realiza Ajustes da CPRB			
				If lCPRBNF				
					lAtuCPRB	:= .T.
					oCPRB:SetCodRec(Iif(AllTrim((cAliasSFT)->FT_ATIVCPB)$cSPCBPSE,mv_par16,mv_par17)) 
					oCPRB:SetTpAju(REDUCAO)
					oCPRB:SetValAju(IIf(SFT->FT_QUANT==(cAliasSFT)->FT_QUANT,SFT->FT_VALCPB,(cAliasSFT)->FT_QUANT*SFT->FT_VALCPB/SFT->FT_QUANT))
					oCPRB:SetCodAjus('06')
					oCPRB:SetNumero((cAliasSFT)->FT_NFISCAL)
					oCPRB:SetDescr("Devolução da nota fiscal " + SFT->FT_NFISCAL)		
					oCPRB:SetDtRefer((cAliasSFT)->FT_ENTRADA)
					oCPRB:GravaAju()					
				Endif				
			Endif
		Endif
	Endif
	RestArea (aAreaSFT)
	(cAliasSFT)->(DbSkip())
EndDo

If lCPRBNF .AND. lAtuCPRB				
	//Grava os valores alterados.
	oCPRB:AtualizaCPRB()
Endif

oAjuDeb:FechaAlias(cAliasSFT)
//Chama função para poder buscar possíveis saldos de deduções
//de período anterior para deduzir o débito do período atual.
If !lPerAtu
	ASA001DANT(dDataDe,oAjuDeb,oAjuCred,cTpMov,aXFilial)
EndIf
 
FreeObj(oAjuDeb)
FreeObj(oApurEFD)
FreeObj(oAjuCred)
oAjuDeb 	:= Nil
oApurEFD	:= Nil
oAjuCred	:= Nil

If lCPRBNF				
	FreeObj(oCPRB)
	oCPRB := Nil
Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ASA001DANT()
Função que irá buscar na tabela CF3 saldos de duções ou ajustes
de períodos anteriores, e fazer o devido ajuste no processamento
atual.

As SALDODED irá fazer o controle se o saldo foi totalmente consumido ou
não, e irá automaticamente atualizar a tabela de saldo com os valores
atualizados.

@param	 	dDataDe 	 - Data inicial do processamento
			oAjuDeb	 - Objeto de ajuste de débito
			oAjuCred    - Objeto de ajuste de crédito
			cTpMov   	 - Tipo de movimento entrada/saída
			aXFilial 	 - Conteúdo xFilial das tabelas de apuração. 
		
@author Erick G. Dias
@since 10/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ASA001DANT(dDataDe,oAjuDeb,oAjuCred,cTpMov,aXFilial)

Local oSaldoDed
Local cAliasCF3	:= ''
Local cDescr	:= ''
Local oDebito		

oSaldoDed	:= 	SALDODED():New()
oSaldoDed:SetFilial(aXFilial)
oSaldoDed:SetDtIni(dDataDe)			
oSaldoDed:SetPerOri(dDataDe)
If cTpMov == 'S'
	//CARREGA as deduções de débito de período anterior
	cAliasCF3	:= oSaldoDed:LoadDedAnt('E')
	
	DbSelectArea (cAliasCF3)
	(cAliasCF3)->(DbGoTop ())
	Do While !(cAliasCF3)->(Eof ())
	
		//Realiza os ajustes de redução do débito.
		//Realizado somente para as operações Exclusivamente CUmulativas, pois no regime Não Cumulativo
		//As devoluções de venda dão direito ao crédito.
		cDescr	:= STR0079 +  (cAliasCF3)->CF3_NFORI // "Devolução da nota fiscal "
		oAjuDeb:SetTributo(PIS)
		oAjuDeb:SetTpAjust(REDUCAO)
		oAjuDeb:SetCodAju('06')
		oAjuDeb:SetNumDoc((cAliasCF3)->CF3_NFDEV)
		oAjuDeb:SetDescAju(cDescr)
		oAjuDeb:SetDtRefer((cAliasCF3)->CF3_PERORI)
		oAjuDeb:SetMsmCod(.F.) // Com este parâmetro com .F. não irá efetuar o ajuste exatamente no mesmo código
		oAjuDeb:SetRegime(CUMULAT)
		oAjuDeb:SetOrigem('E')
		oAjuDeb:SetVlAju((cAliasCF3)->CF3_VLRPIS)
		oAjuDeb:SetNumDev((cAliasCF3)->CF3_NFDEV)
		oAjuDeb:SetNumOri((cAliasCF3)->CF3_NFORI)
		oAjuDeb:SetInfComp('Ajuste de Redução da Contribuição, referente a Redução de período anterior não realizado, em função de não ter Contribuição suficiente para ser reduzido.')
		oAjuDeb:Ajustar()		
	
		//Realiza Ajuste para a COFINS
		oAjuDeb:SetTributo(COFINS)
		oAjuDeb:SetTpAjust(REDUCAO)
		oAjuDeb:SetCodAju('06')
		oAjuDeb:SetNumDoc((cAliasCF3)->CF3_NFDEV)
		oAjuDeb:SetDescAju(cDescr)
		oAjuDeb:SetDtRefer((cAliasCF3)->CF3_PERORI)
		oAjuDeb:SetMsmCod(.F.) // Com este parâmetro com .F. não irá efetuar o ajuste exatamente no mesmo código
		oAjuDeb:SetRegime(CUMULAT)
		oAjuDeb:SetOrigem('E')
		oAjuDeb:SetVlAju((cAliasCF3)->CF3_VLRCOF)
		oAjuDeb:SetNumDev((cAliasCF3)->CF3_NFDEV)
		oAjuDeb:SetNumOri((cAliasCF3)->CF3_NFORI)
		oAjuDeb:SetInfComp('Ajuste de Redução da Contribuição, referente a Redução de período anterior não realizado, em função de não ter Contribuição suficiente para ser reduzido.')
		oAjuDeb:Ajustar()
	
		(cAliasCF3)->(DbSkip ())
	EndDo

	oAjuDeb:FechaAlias(cAliasCF3)
	
	oDebito:= COMPDEBITO():New()
	oDebito:SetFilial(aXFilial)
	oDebito:SetDtIni(dDataDe) 
	oDebito:AtuDebito(CUMULAT,PIS)
	oDebito:AtuDebito(CUMULAT,COFINS)			 
	FreeObj(oDebito)
	oDebito	:= nil
EndIf

If cTpMov == 'E'
	//Carrega saldo de dedução de crédito de período anterior
	cAliasCF3	:= oSaldoDed:LoadDedAnt('C')
	
	DbSelectArea (cAliasCF3)
	(cAliasCF3)->(DbGoTop ())
	Do While !(cAliasCF3)->(Eof ())
	
		//Realiza os ajustes de redução do débito.
		//Realizado somente para as operações Exclusivamente CUmulativas, pois no regime Não Cumulativo
		//As devoluções de venda dão direito ao crédito.
		cDescr	:= STR0080 + (cAliasCF3)->CF3_NFORI // 'Estorno referente a devolução, documento fiscal: '
		oAjuCred:SetTributo(PIS)
		oAjuCred:SetTpAjust(REDUCAO)
		oAjuCred:SetCodAju('06')
		oAjuCred:SetNumDoc("")
		oAjuCred:SetDescAju(cDescr)
		oAjuCred:SetDtRefer((cAliasCF3)->CF3_PERORI)
		oAjuCred:SetMsmCod(.F.) // Com este parâmetro com .F. não irá efetuar o ajuste exatamente no mesmo código
		oAjuCred:SetRegime(NAOCUMULAT)
		oAjuCred:SetOrigem('C')
		oAjuCred:SetVlAju((cAliasCF3)->CF3_VLRPIS)
		oAjuCred:SetNumDev((cAliasCF3)->CF3_NFDEV)
		oAjuCred:SetNumOri((cAliasCF3)->CF3_NFORI)
		oAjuCred:SetInfComp('Ajuste de Redução do Crédito, referente a Redução de período anterior não realizado, em função de não ter Crédito suficiente para ser reduzido.')
		oAjuCred:Ajustar()		
	
		//Realiza Ajuste para a COFINS
		oAjuCred:SetTributo(COFINS)
		oAjuCred:SetTpAjust(REDUCAO)
		oAjuCred:SetCodAju('06')
		oAjuCred:SetNumDoc("")
		oAjuCred:SetDescAju(cDescr)
		oAjuCred:SetDtRefer((cAliasCF3)->CF3_PERORI)
		oAjuCred:SetMsmCod(.F.) // Com este parâmetro com .F. não irá efetuar o ajuste exatamente no mesmo código
		oAjuCred:SetRegime(NAOCUMULAT)
		oAjuCred:SetOrigem('C')
		oAjuCred:SetVlAju((cAliasCF3)->CF3_VLRCOF)
		oAjuCred:SetNumDev((cAliasCF3)->CF3_NFDEV)
		oAjuCred:SetNumOri((cAliasCF3)->CF3_NFORI)
		oAjuCred:SetInfComp('Ajuste de Redução do Crédito, referente a Redução de período anterior não realizado, em função de não ter Crédito suficiente para ser reduzido.')
		oAjuCred:Ajustar()			
	
		(cAliasCF3)->(DbSkip ())
	EndDo
	
	oAjuCred:FechaAlias(cAliasCF3)

EndIF
FreeObj(oSaldoDed)
oSaldoDed:= Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QRYDEVOL()
Função que monta query para buscar os documentos de devoluções e devolve
o alias com query já efetuada.

@param	 	dDataDe 	 - Data Inicial de Processamento
			dDataAte	 - Data Final de processamento
			cTpMovQry   - Tipo do movimento a ser considerado na query Entrada/Saída
			cNrLivro    - Número do Livro a ser processado
			cRegime 	 - regime escolhido pelo usuário na apuração 
			nMVM996TPR  - Conteúdo do `parâmetro MV_M996TPR	
@return	Alias da STF com as devoluções conforme parâmetros passados		
@author Erick G. Dias
@since 10/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function QRYDEVOL(dDataDe,dDataAte,cTpMovQry,cNrLivro,cRegime,nMVM996TPR)

Local cSelect 	:= ''
Local cFrom 		:= ''
Local cWhere 		:= ''
Local cAliasSFT	:= 'SFT'
Local lCooperat	:= SA1->(ColumnPos((SuperGetMv("MV_COOPERA",,""))))>0
Local cCooperat	:= IIF(lCooperat,SuperGetMv("MV_COOPERA",,""),"")

cSelect :=	"SFT.FT_FILIAL,SFT.FT_TIPOMOV,SFT.FT_NFORI,SFT.FT_SERORI,SFT.FT_ITEMORI,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,"
cSelect +=	"SFT.FT_LOJA,SFT.FT_ITEM,SFT.FT_VALCOF,SFT.FT_VALPIS,SFT.FT_PRODUTO,SFT.FT_QUANT,SFT.FT_BASEPIS,SFT.FT_BASECOF, SFT.FT_ENTRADA,"
cSelect +=	"SFT.FT_CSTPIS,SFT.FT_CSTCOF,SFT.FT_FORMUL,SFT.FT_SERIE "

If SFT->(ColumnPos('FT_ATIVCPB')) .And. SFT->(ColumnPos('FT_VALCPB'))
	cSelect += ",SFT.FT_ATIVCPB,SFT.FT_VALCPB "
EndIf

cFrom	:=	""+RetSqlName("SFT")+" SFT "
cWhere	:=	"SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
cWhere	+=	"SFT.FT_TIPOMOV='"+cTpMovQry+"' AND "
cWhere	+=	"SFT.FT_ENTRADA>='"+DTOS(dDataDe)+"' AND "
cWhere	+=	"SFT.FT_ENTRADA<='"+DTOS(dDataAte)+"' AND "
cWhere	+=	"SFT.FT_DTCANC='' AND "
cWhere	+=	"SFT.FT_TIPO='D' AND "
If cNrLivro<>"*"
	cWhere += " SFT.FT_NRLIVRO = '"+cNrLivro+"' AND "
Endif
cWhere	+=	"SFT.D_E_L_E_T_=''"
  	
If cRegime$"4"
	//Regime Cumulativo e Não Cumulativo
	If nMVM996TPR==1
		//PARÂMETRO INDICA QUE DEVERÁ VER F4_TPREG PARA DEFINIR O REGIME		
		If cTpMovQry=="E" 
			//DEVOLUÇÃO DE VENDA
			cSelect	+=	" ,SF4.F4_TPREG ,SB1.B1_TPREG"
			cFrom	+=	" LEFT JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND "
			cFrom	+=	" SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_='' "
			cFrom	+=	" LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_='' "
			cFrom	+=	" LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_='' "
			cWhere	+=	" AND ((SF4.F4_TPREG='2') OR (SF4.F4_TPREG='3' AND SB1.B1_TPREG='2') OR (SFT.FT_FORMUL='S' AND (SFT.FT_CSTPIS IN ('98','99') OR SFT.FT_CSTCOF IN ('98','99')) ) )"
			If lCooperat .And. !Empty(cCooperat)
			 cWhere += " AND SA1."+cCooperat+" <> '1' "
			EndIf
		Else
			//DEVOLUÇÃO DE COMPRA
			cSelect	+=	" ,SF4.F4_TPREG ,SB1.B1_TPREG"
			cFrom	+=	" LEFT JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND "
			cFrom	+=	" SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_ITEM=SFT.FT_ITEM  AND SD2.D_E_L_E_T_='' "
			cFrom	+=	" LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_='' "
			cWhere	+=	" AND ((SF4.F4_TPREG='1') OR (SF4.F4_TPREG='3' AND SB1.B1_TPREG='1'))"
		Endif
				
		cFrom	+=	" LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=''"
				
	Elseif nMVM996TPR==2
		//PARÂMETRO INDICA QUE DEVERÁ VER B1_TPREG PARA DEFINIR O REGIME
		cSelect	+=	" ,SB1.B1_TPREG"
		cFrom	+=	" LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=''"   
				
		If cTpMovQry=="E"
			IF lCooperat .And. !Empty(cCooperat) 
				cFrom	+=	" LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_='' "
			EndIf
			cWhere	+=	" AND ((SB1.B1_TPREG='2') OR (SFT.FT_FORMUL='S' AND (SFT.FT_CSTPIS IN ('98','99') OR SFT.FT_CSTCOF IN ('98','99')) )  )"
			If lCooperat .And. !Empty(cCooperat)
			 cWhere += " AND SA1."+cCooperat+" <> '1' "
			EndIf
		Else
			cWhere	+=	" AND SB1.B1_TPREG='1'"
		Endif
			
	Elseif nMVM996TPR==3  
		//PARÂMETRO INDICA QUE DEVERÁ VER a1_TPREG PARA DEFINIR O REGIME
  		If cTpMovQry=="E" .And. SA1->(ColumnPos( 'A1_TPREG' ))
			cSelect	+=	" ,SA1.A1_TPREG"
			cFrom	+=	" LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND "
			cFrom	+=	" SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_=''" 
			cWhere	+=	" AND ((SA1.A1_TPREG='2') OR (SFT.FT_FORMUL='S' AND (SFT.FT_CSTPIS IN ('98','99') OR SFT.FT_CSTCOF IN ('98','99')) )  ) AND SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_=''"
			If lCooperat .And. !Empty(cCooperat)
			 cWhere += " AND SA1."+cCooperat+" <> '1' "
			EndIf
		Elseif SA2->(ColumnPos( 'A2_TPREG' ))
			cSelect	+=	" ,SA2.A2_TPREG"
			cFrom	+=	" LEFT JOIN "+RetSqlName("SA2")+" SA2 ON SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD=SFT.FT_CLIEFOR AND "
			cFrom	+=	" SA2.A2_LOJA=SFT.FT_LOJA AND SA2.D_E_L_E_T_=''" 
			cWhere	+=	" AND SA2.A2_TPREG='1'"
		Endif
	Endif
ElseIf cRegime$"1" .And. cTpMovQry=="E"      			   	
	//Regime Não Cumulativo
	If SF4->(ColumnPos( 'F4_OPERGAR' ))		   
		cFrom		+=	" LEFT JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND "
		cFrom		+=	" SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_='' "
		cFrom		+=	" LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_='' "
		cFrom		+=	" LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND "
		cFrom		+=	" SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_='' " 
		cWhere	+=	" AND (SFT.FT_FORMUL='S' AND SF4.F4_OPERGAR<>'1') AND (SFT.FT_CSTPIS IN ('98','99') OR SFT.FT_CSTCOF IN ('98','99')) "
		If lCooperat .And. !Empty(cCooperat)
			cWhere += " AND SA1."+cCooperat+" <> '1' "
		EndIf
	Else
		cFrom		+=	" LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND "
		cFrom		+=	" SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_='' " 
		cWhere	+=	" AND SFT.FT_FORMUL='S' AND (SFT.FT_CSTPIS IN ('98','99') OR SFT.FT_CSTCOF IN ('98','99')) "
		If lCooperat .And. !Empty(cCooperat)
			cWhere += " AND SA1."+cCooperat+" <> '1' "
		EndIf		
	Endif
EndIF

cSelect := '%'+cSelect+'%
cFrom	:= '%'+cFrom+'%'
cWhere	:= '%'+cWhere+'%'

cAliasSFT	:=	GetNextAlias()
BeginSql Alias cAliasSFT
	COLUMN FT_ENTRADA AS DATE
	SELECT 
		%Exp:cSelect%

	FROM 
		%Exp:cFrom%

	WHERE 
		%Exp:cWhere%

EndSql

Return cAliasSFT

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckDup()
Função que verifica se já existem títulos a pagar de PIS e COFINS
gerados pela apuração. Deleta o título se necessário conforme interação do usuário

@return	indica se deletou ou não o título,
		
@author Erick G. Dias
@since 10/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------

Static Function CheckDup(lAutomato)

Local cSelect	:= ''
Local cFrom	:= ''
Local cWhere	:= ''
Local cPerg	:= ''
Local cCodLp	:= ''
Local cNumTitAux	:= ''
Local cFiltroBrw	:= ''

Local nCont		:= 0

local lDeletou	:= .F.
Local lContinua	:= .T.
Local lExistTit	:= .F.
Local lProcessa  	:= .F.
Local lContab		:= MV_PAR14==1

Local oTitulo		:= TITPAGAR():New()
Local oEstDifer	

Default lAutomato := .F.

Begin Transaction	
/*
'Existem títulos gravados no Financeiro para este período e filial.'
'Deseja prosseguir com reprocessamento e apagar os títulos?'
'(Sim - Reprocessa / Não - Visualiza Apuração)'
*/

cPerg	:= STR0081 + CRLF
cPerg	+= STR0082 + CRLF
cPerg	+= STR0083

If CL3->(ColumnPos( 'CL3_NUMTIT' ))
	For nCont := 1 to 4
	
		if CL3->(MSSEEK(xFilial('CL3')+dTos(MV_PAR01)+alltrim(str(nCont))+'2')) .and. !Empty(CL3->CL3_NUMTIT)
			lExistTit	:= .T.
			//Códigos de lançamento padrão para estorno.
			cCodLp := Iif(CL3->CL3_TPTIT=='PIS','611','608')
			//Passa informações para a classe poder deletar o título
			//e fazer a contabilização de estorno.
			oTitulo:SetPrefixo(CL3->CL3_PRETIT)
			oTitulo:SetNumTit(CL3->CL3_NUMTIT)
			oTitulo:SetParcela(CL3->CL3_PARTIT)
			oTitulo:SetTipo(CL3->CL3_TPTIT)												
			oTitulo:SetFornece(CL3->CL3_FORTIT)
			oTitulo:SetLoja(CL3->CL3_LOJTIT)
			oTitulo:SetOrigem('FISA001')
			oTitulo:SetContab(lContab)
			oTitulo:SetCodLp(cCodLp)
			If !oTitulo:ChkDelTit()
				cNumTitAux	+= 'Número: '+ CL3->CL3_NUMTIT +' Prefixo: ' +CL3->CL3_PRETIT + ' Tipo: ' + CL3->CL3_TPTIT + CRLF 
				lContinua	:= .F.
			EndIF
		endif
	
	Next nCont
				
	If lContinua
		
		If lAutomato .And. lExistTit
			lProcessa := .T.
		Else
			If lExistTit .AND. ( ApMsgYesNo(cPerg ) )
				lProcessa := .T.
			EndIf
		EndIf
		
		If lProcessa
			
			For nCont := 1 to 4
				
				//Verificar antes se existe algum título já baixado. Caso existir, então
				//exibir para o cliente os títulos que já possuem baixa no Financeiro, e não 
				//permitir que prossiga com apuração.	
			
				if CL3->(MSSEEK(xFilial('CL3')+dTos(MV_PAR01)+alltrim(str(nCont))+'2')) .and. !Empty(CL3->CL3_NUMTIT)
					//Códigos de lançamento padrão para estorno.
					cCodLp := Iif(CL3->CL3_TPTIT=='PIS','611','608')
					//Passa informações para a classe poder deletar o título
					//e fazer a contabilização de estorno.
					oTitulo:SetPrefixo(CL3->CL3_PRETIT)
					oTitulo:SetNumTit(CL3->CL3_NUMTIT)
					oTitulo:SetParcela(CL3->CL3_PARTIT)
					oTitulo:SetTipo(CL3->CL3_TPTIT)												
					oTitulo:SetFornece(CL3->CL3_FORTIT)
					oTitulo:SetLoja(CL3->CL3_LOJTIT)
					oTitulo:SetOrigem('FISA001')
					oTitulo:SetContab(lContab)
					oTitulo:SetCodLp(cCodLp)	
					oTitulo:SetExibCtb(.t.) 	
					oTitulo:DelTitulo()
					lDeletou	:= .T.	
				endif
			Next nCont
			
			FreeObj(oTitulo)
			oTitulo:= Nil
			
			// Tratamento para gerar lançamento contábil para Diferimento de PIS / COFINS ( dentro do mesmo período e período anterior )
			//Validação para verifiar se foi deletado algum titulo e se está solicitando para contabilizar
			if lDeletou .and. lContab
							
				DBSelectArea( 'CKS' )
				CKS->( DBSetOrder( 1 ) )
				if CKS->( MsSeek(xFilial("CKS")+ dTos(MV_PAR01)))
				
					oEstDifer:= TITPAGAR():New()
									
						do while !CKS->( eof () ) .and. CKS->CKS_FILIAL == xFilial('CKS') .and. CKS->CKS_PER == MV_PAR01
						
							//ESTORNO DIFERIMENTO PIS/COFINS NO MÊS (Período)
							if CKS->CKS_DIF > 0 										
								cCodLp	:= 	iif(CKS->CKS_TRIB == '1','761','762')				
								CtbDifer(oEstDifer, cCodLp, lContab)
							endif
								
							//ESTORNO DIFERIMENTO PIS/COFINS MESES ANTERIORES	
							if CKS->CKS_DIFANT > 0 									
								cCodLp	:= 	iif(CKS->CKS_TRIB == '1','763','764')						
								CtbDifer(oEstDifer, cCodLp, lContab)		
							endif	
								
							CKS->(dbSkip())
						enddo
					
					FreeObj(oEstDifer)
					oEstDifer:= Nil
				endif
			endif
		Else
			lContinua := .F.
		EndIF	
	Else
		//Exibe aqui a mensagem orientando o usuário a verificar os seguintes títulos
		//e apuração não irá prosseguir.
		
		Alert("Os seguintes títulos no Contas a Pagar " +CRLF+CRLF+ cNumTitAux + CRLF+"Não podem ser apagados,verificar se existem baixas para estes títulos no Financeiro."+CRLF+"O Reprocessamento será interrompido.")
		
	EndIF

EndIF
End Transaction
	
Return lContinua .OR. !lExistTit

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckApur()
Verifica se já existe apuração processada para este período

@return	Indica se existe ou não apuração gravada para filial e período
		
@author Erick G. Dias
@since 10/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function CheckApur()

Local lApurado	:= .F.

DbSelectArea ('CKR')
CKR->(DbSetOrder(1))
If CKR->(MSSEEK(xFilial('CKR')+dTos(MV_PAR01)))
	lApurado := .T.
EndIF

Return lApurado

//-------------------------------------------------------------------
/*/{Protheus.doc} ASA001AFIL()
Função que popula array com xFilial das tabelas de apuração.
Estas informações são utilizadas quando apuração for processada
com mais de uma filial e de forma consolidada, já que todas as informações
deverá ser gravadas na matriz, por este motivo guardo o xFilial da Matriz.

@return	aRet - Array com xFilial das tabelas de apuração conforme Matriz.
		
@author Erick G. Dias
@since 10/07/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ASA001AFIL()

Local aRet	:= {}

AADD(aRet,{'CL8',xFilial('CL8')})
AADD(aRet,{'CL9',xFilial('CL9')})
AADD(aRet,{'CLA',xFilial('CLA')})
AADD(aRet,{'CKR',xFilial('CKR')})
AADD(aRet,{'CKS',xFilial('CKS')})
AADD(aRet,{'CKT',xFilial('CKT')})
AADD(aRet,{'CKU',xFilial('CKU')})
AADD(aRet,{'CKV',xFilial('CKV')})
AADD(aRet,{'CKW',xFilial('CKW')})
AADD(aRet,{'CKZ',xFilial('CKZ')})
AADD(aRet,{'CL0',xFilial('CL0')})
AADD(aRet,{'CL3',xFilial('CL3')})
AADD(aRet,{'CL4',xFilial('CL4')})
AADD(aRet,{'CCY',xFilial('CCY')})
AADD(aRet,{'CCW',xFilial('CCW')})
AADD(aRet,{'SFV',xFilial('SFV')})
AADD(aRet,{'SFW',xFilial('SFW')})
If ISA001NDIF()
	AADD(aRet,{'CFA',xFilial('CFA')})
	AADD(aRet,{'CFB',xFilial('CFB')})
EndIF

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VisualApur()
Esta função irá carregar a apuração já processada em modo de visualização,
considerando a filial selecionada no grid pelo usuário.
		
@author Erick G. Dias
@since 
@version 11.80
/*/
//-------------------------------------------------------------------
Function VisualApur()

MV_PAR01 :=  CKR->CKR_PER
MV_PAR02 :=  LASTDAY(CKR->CKR_PER)
MV_PAR06 := CKR->CKR_REGIME
MV_PAR13 := 2	
MV_PAR14 := 2

FISA002(.T.,CKR->CKR_CONSOL == '1',CKR->CKR_REGIME)

Return


//Chama rotina de relatório
Function FSA001REL()	
	
	//Chama rotina de relatório
	FISR101(CKR->CKR_PER,alltrim(str(CKR->CKR_REGIME)))

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} ExcluApur()
Está função realiza a exclusão da apuração, limpando as tabelas.
Somente irá fazer exclusão de apuração que não gerou título e/ou não contabilizou
Para as outras apurações deverá realizar reprocessamento.
		
@author Erick G. Dias
@since 
@version 11.80
/*/
//-------------------------------------------------------------------
Function ExcluApur()
Local oApurSai
Local lConsolid	:= CKR_CONSOL == '1'

IF CKR->CKR_STATUS == '1'
	
	//If CKR_CONSOL <> '1'
	
		//Aqui apuração não teve geração de títulos ou contabilização, irá permitir edição
		MV_PAR01 :=  CKR->CKR_PER
		MV_PAR02 :=  LASTDAY(CKR->CKR_PER)
		MV_PAR06 := CKR->CKR_REGIME
		MV_PAR13 := 3 //Irá pedir solicitação do usuário para gerar ou não os títulos	
		MV_PAR14 := 3	//Irá pedir solicitação do usuário para contabilizar	
		If ( ApMsgYesNo('Deseja realmente excluir apuração da filial: ' + FWGETCODFILIAL + ' do período de ' + MesExtenso(mv_par01) + '/' +  Str(year(mv_par01),4) + ' ?') )		//Irá apagar os títulos 
			Begin Transaction		
	
			oApurSai := FISX001():New()
			oApurSai:SetFilial(ASA001AFIL())
			oApurSai:SetDtIni(MV_PAR01)
			oApurSai:SetDtFin(MV_PAR02)	
			Processa({|lEnd|oApurSai:ClearTab(ALIASREPRO(Iif(lConsolid,'3' ,'2' )),lConsolid) },"Excluindo Apuração",,,.T.)		
				
			oApurSai	:= Nil
				
			End Transaction
			
			//Deverá percorrer SM0 buscando CKR e tirando o STATUS de consolidada.
			IF lConsolid
				DesfazCon()
			EndIF
			
			MsgInfo('Apuração Excluída com Sucesso')
		EndIF
	/*Else
		Alert('Esta é uma apuração concolidada na visão da Matriz, não poderá ser excluída.')
	EndIF*/


Else
	//Aqui apuração já teve geração de título ou lançamento padrão, não irá permitir
	//'Foram gerados títulos e/ou contabilizações para esta apuração, para edição será necessário efetuar o reprocessamento desta filial e período.'
	Alert('Apuração já gravou título ou já realizou contabilização, não poderá ser excluído!')

EndIF


return

//-------------------------------------------------------------------
/*/{Protheus.doc} EditaApur()
Esta função carrega apuração em modo de edição
		
@author Erick G. Dias
@since 
@version 11.80
/*/
//-------------------------------------------------------------------
Function EditaApur()

IF CKR->CKR_STATUS == '1'
	//Aqui apuração não teve geração de títulos ou contabilização, irá permitir edição
	MV_PAR01 :=  FIRSTDAY(CKR->CKR_PER)
	MV_PAR02 :=  LASTDAY(CKR->CKR_PER)
	MV_PAR06 := CKR->CKR_REGIME
	MV_PAR13 := 3 //Irá pedir solicitação do usuário para gerar ou não os títulos	
	MV_PAR14 := 3	//Irá pedir solicitação do usuário para contabilizar
	Begin Transaction
	FISA002(.F.,CKR->CKR_CONSOL == '1',CKR->CKR_REGIME)	
	End Transaction


Else
	//Aqui apuração já teve geração de título ou lançamento padrão, não irá permitir
	//'Foram gerados títulos e/ou contabilizações para esta apuração, para edição será necessário efetuar o reprocessamento desta filial e período.'
	Alert(STR0084)

EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001Agrp()
Esta função é responsável por realiza o agrupamento das apurações
já processadas nas filiais individualizadas na matriz. Irá somar todos os 
valores nas tabelas de apuração e criar na matriz(empresa logada) novas linhas
nas tabelas de forma consolidada.
		
@author Erick G. Dias
@since 
@version 11.80
/*/
//-------------------------------------------------------------------
Function A001Agrp()

Local aFil	:= {}
Local nFil	:= 0
Local aSM0	:= {}
Local cFilLog	:= AllTrim(SM0->M0_CODFIL)
Local oProcess
			
ProcLogIni({})
ProcLogAtu("INICIO","Início da Consolidação na Visão da Matriz - " + Time(),,upper('FISA001'))
IF ApMsgYesNo(STR0085)//'Esta opção irá consolidar apurações já processadas das filiais na apuração da Matriz. Deseja Continuar?'
	If Pergunte("ISA002",.T.)
		Begin Transaction
			oProcess := FISProgress():New({|lEnd| IniciaCon(oProcess)},STR0086)//'Processado Consolidação Filial->Matriz'
			oProcess:Activate()
		End Transaction		
	EndIF
EndIF
ProcLogAtu("INICIO","Fim da Consolidação na Visão da Matriz - " + Time(),,upper('FISA001'))


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IniciaCon()
Esta função irá tratar as filiais que deverão fazer parte do agrupamento
e tualizar a barra de progresso.
		
@param oProcess  - Objeto da classe FISXCLASS para barra de progressão.
@author Erick G. Dias
@since 
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function IniciaCon(oProcess)

Local aFil	:= {}
Local nFil	:= 0
Local aSM0	:= {}
Local aCKR	:= {}
Local cREgime	:= ''
Local cFilLog	:= AllTrim(SM0->M0_CODFIL)
Local aXFilial	:= {}
Local lCancel	:= 	.F.
Local TimeInicio
Local TimeFim
Local lConsolid	:= .F.

aXFilial:= ASA001AFIL	()

aFil:= MatFilCalc( .T. )
aAreaSM0 := SM0->(GetArea())
aCKR	  := CKR->(GetArea())
DbSelectArea("SM0")

aAreaSM0 := SM0->(GetArea())

DbSelectArea ('CKR')
CKR->(DbSetOrder(1))


SM0->(DbGoTop())
If SM0->(MsSeek(cEmpAnt))
	Do While !SM0->(Eof()) 
		nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
		If nFil > 0 .And. aFil[nFil][1] 			
			Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})			
			//Busca linha de apuração para filial, na data de processamento, não consolidada e tributo igual a pis
			//CKR_FILIAL+dTos(CKR_PER)+CKR_CONSOL+CKR_TRIB
			nFil := Len(aSM0)
			SM0->(DbGoTop ())
			SM0->(MsSeek (aSM0[nFil][1]+aSM0[nFil][2], .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL
			If CKR->(MSSEEK(xFilial('CKR')+dTos(MV_PAR01)+'21'))
				IF	CKR->CKR_STATUS <> '1'
					//Verifica aqui se apuração gerou título/contabilizou, se sim deverá abortar
					//Apuração gerou título e/ou contabilização, não poderá continua
					If CKR->CKR_STATUS == '4'
						lConsolid	:= .T. //Indica que apuração já foi consolidada
					EndIF
					lCancel	:= .T.
				EndIF
				
				If !Empty(cRegime)
					IF CKR->CKR_REGIME <> cRegime
						//Todos os regimes deverão ser o mesmo, se algum diferente deverá abortar
						//Não poderá ser regime diferente para consolidação, não poderá continuar.
						lCancel	:= .T.	
					EndIF
				Else
					cRegime	:= CKR->CKR_REGIME
				EndIF				
			EndIF		
		EndIf
		SM0->(dbSkip())
	Enddo
EndIf
RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

SM0->(RestArea(aAreaSM0))
aAreaSM0 := SM0->(GetArea())

If lConsolid
	Alert('Esta apuração já foi considerada em uma consolidação. Por favor, exclua a apuração consolidada antes de prosseguir.')
ElseIF lCancel
	Alert('Não poderão ser consolidadas apurações que já tenham gerado título/contabilização ou apurações com regimes diferentes'+CHR(10)+CHR(13)+'Verifique estas informações para poder prosseguir com a consolidação')
Else
	TimeInicio :=Time()
	oProcess:Set1Progress(len(aSM0))
	oProcess:Set2Progress(1)
			oProcess:SetDetProgress("Inicio do processamento",TimeInicio,;
				"Fim do Processamento","" ,;
				"Tempo de processamento","" ,;
				"","")			
	
	For nFil := 1 to Len(aSM0)
	
		SM0->(DbGoTop ())
		SM0->(MsSeek (aSM0[nFil][1]+aSM0[nFil][2], .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL
		oProcess:Inc1Progress('Processando Filial'+FWGETCODFILIAL)//"Processando Filial"
		ProcConFil(oProcess,aXFilial,cFilLog,lConsolid)
	
	Next nFil	
	
	RestArea (aAreaSM0)
	cFilAnt := FWGETCODFILIAL
	
	CKR->(RestArea(aCKR))
	
	TimeFim := Time()
	oProcess:Set2Progress(1)
			oProcess:SetDetProgress("Inicio do processamento",TimeInicio,;
				"Fim do Processamento",TimeFim ,;
				"Tempo de processamento",ELAPTIME(TimeInicio,TimeFim) ,;
				"","")
	MsgInfo(STR0087)//'Consolidação Concluída com Sucesso'
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001QRYCON()
Função que irá realizar query para consolidar as filiais na matriz.
		
@param 	cTab  		- Tabela que será pesquisada
			cCmpoFil   -Nome do campo filial da tabela 
			cCmpPer    -Nome do Campo Período da tabela
			cCmpConsol -Nome do campos de consolidação da tabela 
			lData     - Indica se deverá fazer comparação com data menor/maior e igual ou somente igual
						
@return Alias já processado.
@author Erick G. Dias
@since 
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001QRYCON(cTab,cCmpoFil,cCmpPer,cCmpConsol,lData)

Local cAlias			:= ''
Local 		cSlct		:= ''
Local 		cFiltro	:= ''
Local 		cFrom		:= ''
Local 		cPerAtu	:= Strzero(Month(MV_PAR01),2)+cvaltochar(Year(MV_PAR01))
Default	lData 		:= .T.

DbSelectArea (cTab)

cSlct:= cTab+'.*'

cFiltro := cCmpoFil + "= '"+ xFilial(cTAb)+ "' AND "

IF lData
	cFiltro += cCmpPer + " >= '" +  %Exp:DToS (MV_PAR01)% + "' AND "
	cFiltro += cCmpPer + " <= '" +  %Exp:DToS (MV_PAR02)% + "' AND "
Else
	cFiltro += cCmpPer + " = '" +  cPerAtu + "' AND "
EndIF

cFiltro += cCmpConsol + " = '2' AND " //somente irá trazer os individualizados.

cFiltro+=	cTab+".D_E_L_E_T_=''"

cFrom	:=	RetSqlName(cTab)+" " + cTab

cSlct := '%'+cSlct+'%'
cFiltro := '%'+cFiltro+'%'
cFrom := '%'+cFrom+'%'

cAlias	:=	GetNextAlias()
BeginSql Alias cAlias
	SELECT
	%Exp:cSlct%

	FROM
	%Exp:cFrom%
	WHERE
	%Exp:cFiltro%

EndSql
Return cAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcConFil()

@return Alias já processado.
@author Erick G. Dias
@since 
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ProcConFil(oProcess,aXFilial,cFilialMat,lIndividu)

Local cAliasRet	:= ''
Local aTab		:= {}
Local lContinue	:= .F.
Local nContTab	:= 0


AADD(aTab,{'CL8','CL8.CL8_FILIAL','CL8.CL8_PER','CL8.CL8_CONSOL'		,STR0088,.T.})//'Créditos'
AADD(aTab,{'CL9','CL9.CL9_FILIAL','CL9.CL9_PER','CL9.CL9_CONSOL'		,STR0089,.T.})//'Créditos Detalhados'
AADD(aTab,{'CLA','CLA.CLA_FILIAL','CLA.CLA_DTREF','CLA.CLA_CONSOL'		,STR0090,.T.})//'Ajustes'
AADD(aTab,{'CKS','CKS.CKS_FILIAL','CKS.CKS_PER','CKS.CKS_CONSOL'		,STR0091,.T.})//'Débitos'
AADD(aTab,{'CKT','CKT.CKT_FILIAL','CKT.CKT_PER','CKT.CKT_CONSOL'		,STR0092,.T.})//'Receitas Não Tributadas'
AADD(aTab,{'CKU','CKU.CKU_FILIAL','CKU.CKU_PER','CKU.CKU_CONSOL'		,STR0093,.T.})//'Totais de Receitas'
AADD(aTab,{'CKV','CKV.CKV_FILIAL','CKV.CKV_PER','CKV.CKV_CONSOL'		,STR0094,.T.})//'CPRB Consolidado'
AADD(aTab,{'CKW','CKW.CKW_FILIAL','CKW.CKW_PER','CKW.CKW_CONSOL'		,STR0095,.T.})//'Ajustes CPRB'
AADD(aTab,{'CKZ','CKZ.CKZ_FILIAL','CKZ.CKZ_PER','CKZ.CKZ_CONSOL'		,'',.T.})
AADD(aTab,{'CL0','CL0.CL0_FILIAL','CL0.CL0_PER','CL0.CL0_CONSOL'		,STR0096,.T.})//'Resumo CST/REgime'
AADD(aTab,{'CL3','CL3.CL3_FILIAL','CL3.CL3_PER','CL3.CL3_CONSOL'		,STR0097,.T.})//'Receita x Vl. Recolher'
AADD(aTab,{'CCY','CCY.CCY_FILIAL','CCY.CCY_PERIOD','CCY.CCY_CONSOL'	,STR0098,.F.})//'Saldo de crédito de PIS'
AADD(aTab,{'CCW','CCW.CCW_FILIAL','CCW.CCW_PERIOD','CCW.CCW_CONSOL'	,STR0099,.F.})
AADD(aTab,{'SFV','SFV.FV_FILIAL','SFV.FV_PER','SFV.FV_CONSOL'			,STR0100,.F.})//'Saldo de retenção de PIS'
AADD(aTab,{'SFW','SFW.FW_FILIAL','SFW.FW_PER','SFW.FW_CONSOL'			,STR0101,.F.}) //'Saldo de retenção da COFINS'
IF ISA001NDIF()
	AADD(aTab,{'CFA','CFA.CFA_FILIAL','CFA.CFA_PERAPU','CFA.CFA_CONSOL'			,'Diferimento do Período',.F.}) //'Diferimento do Período'
	AADD(aTab,{'CFB','CFB.CFB_FILIAL','CFB.CFB_PERAPU','CFB.CFB_CONSOL'			,'Diferimento de Período Anterior',.F.}) //'Diferimento de Período Anterior'
EndIF

oProcess:Set2Progress(Len(aTab)+1)

oProcess:Inc2Progress(STR0103,STR0102)//'Consolidação de Apuracao'
cAliasRet	:= A001QRYCON('CKR','CKR.CKR_FILIAL','CKR.CKR_PER','CKR.CKR_CONSOL')
lContinue:= ConsCKR(cAliasRet,aXFilial)

DbSelectArea (cAliasRet)
(cAliasRet)->(DbCloseArea ())

IF lContinue

	For nContTab := 1 to Len(aTab)
		oProcess:Inc2Progress(STR0103, STR0104+ aTab[nContTab][5])//'Consolidação de'
		cAliasRet	:= A001QRYCON(aTab[nContTab][1],aTab[nContTab][2],aTab[nContTab][3],aTab[nContTab][4],aTab[nContTab][6])
		
		Do case	
			Case aTab[nContTab][1] == 'CL8'
				ConsCL8(cAliasRet,aXFilial)
				
			Case aTab[nContTab][1] == 'CL9'
				ConsCL9(cAliasRet,aXFilial)	

			Case aTab[nContTab][1] == 'CLA'
				ConsCLA(cAliasRet,aXFilial)


			Case aTab[nContTab][1] == 'CKS'
				ConsCKS(cAliasRet,aXFilial)
				
			Case aTab[nContTab][1] == 'CKU'
				ConsCKU(cAliasRet,aXFilial)
				
			Case aTab[nContTab][1] == 'CKV'
				ConsCKV(cAliasRet,aXFilial,cFilialMat,lIndividu)

			Case aTab[nContTab][1] == 'CKX'
				ConsCKX(cAliasRet,aXFilial)

			Case aTab[nContTab][1] == 'CKZ'
				ConsCKZ(cAliasRet,aXFilial)
				
			Case aTab[nContTab][1] == 'CL0'
				ConsCL0(cAliasRet,aXFilial)

			Case aTab[nContTab][1] == 'CL3'
				ConsCL3(cAliasRet,aXFilial)
				
			Case aTab[nContTab][1] == 'CCY'
				ConsCCY(cAliasRet,aXFilial)	


			Case aTab[nContTab][1] == 'CCW'
				ConsCCW(cAliasRet,aXFilial)	


			Case aTab[nContTab][1] == 'SFV'
				ConsSFV(cAliasRet,aXFilial)	

			Case aTab[nContTab][1] == 'SFW'
				ConsSFW(cAliasRet,aXFilial)
					
			Case aTab[nContTab][1] == 'CFA'
				ConsCFA(cAliasRet,aXFilial)														

			Case aTab[nContTab][1] == 'CFB'
				ConsCFB(cAliasRet,aXFilial)														




													
		EndCase
			
		DbSelectArea (cAliasRet)
		(cAliasRet)->(DbCloseArea ())
	
	Next nContTab

EndIF

Return

Static Function ConsCKR(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCKR	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cFilMatriz	:= ''
Local cConsol		:= '1'
Local lRet	:= .F.
Local dtAux		:= CTod("  /  /    ")

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.


oTabCKR:setIndice(1)
oTabCKR:setAlias('CKR')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CKR')
TcSetField(cAlias,"CKR_PER","D",8,0)

Do While !(cAlias)->(Eof ())
	
	dtAux		:= (cAlias)->CKR_PER
	If lAgrupaT		
		cConsol		:= '2'
		dtAux	:= dtNewPer		
	EndIF

	If (cAlias)->CKR_STATUS <> '4' .AND. (cAlias)->CKR_CONSOL <> '1'
		//Não irá considerar apurações já consideradas para consolidação e apurações que já são é a consolidada
		lREt	:= .T.
		cChave:= cFilMatriz+DTOS(dtAux) +cConsol+(cAlias)->CKR_TRIB 
	
		oTabCKR:setChave(cChave)
		oTabCKR:Inclui()	
		//Somente passa campos de valores a serem acumulados

		oTabCKR:SetCampo('CKR_FILIAL'  	,cFilMatriz)
		oTabCKR:SetCampo('CKR_PER'  		,dtAux)
		oTabCKR:SetCampo('CKR_TRIB' 		,(cAlias)->CKR_TRIB)
		oTabCKR:SetCampo('CKR_STATUS'   ,(cAlias)->CKR_STATUS)
		oTabCKR:SetCampo('CKR_REGIME'   ,(cAlias)->CKR_REGIME)
		oTabCKR:SetCampo('CKR_CONNC' 	,(cAlias)->CKR_CONNC,lAcumula)	
		oTabCKR:SetCampo('CKR_CRDANT'	,(cAlias)->CKR_CRDANT,lAcumula)	
		oTabCKR:SetCampo('CKR_CRDATU'	,(cAlias)->CKR_CRDATU,lAcumula)	
		oTabCKR:SetCampo('CKR_RTANTN'	,(cAlias)->CKR_RTANTN,lAcumula)	
		oTabCKR:SetCampo('CKR_RTATUN'	,(cAlias)->CKR_RTATUN,lAcumula)	
		oTabCKR:SetCampo('CKR_OUTDNC'	,(cAlias)->CKR_OUTDNC,lAcumula)	
		oTabCKR:SetCampo('CKR_NCREC' 	,(cAlias)->CKR_NCREC,lAcumula)	
		oTabCKR:SetCampo('CKR_CONC'  	,(cAlias)->CKR_CONC,lAcumula)	
		oTabCKR:SetCampo('CKR_RTANTC'	,(cAlias)->CKR_RTANTC,lAcumula)	
		oTabCKR:SetCampo('CKR_RTATUC'	,(cAlias)->CKR_RTATUC,lAcumula)	
		oTabCKR:SetCampo('CKR_OUTDC' 	,(cAlias)->CKR_OUTDC,lAcumula)		
		oTabCKR:SetCampo('CKR_CREC'  	,(cAlias)->CKR_CREC,lAcumula)
		oTabCKR:SetCampo('CKR_CONSOL'   ,cConsol)	
	
		oTabCKR:Finaliza()
	
		IF !lAgrupaT .AND. CKR->(MSSEEK( xFilial('CKR')+DTOS((cAlias)->CKR_PER) +'2'+(cAlias)->CKR_TRIB))
			RecLock('CKR',.F.)
			CKR->CKR_STATUS = '4' // Utilizada para consolidação
			MsUnLock()		
		EndIF
	EndIF

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCKR )
oTabCKR:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
	
Return lRet

Static Function ConsCL8(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCL8	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cConsol		:= '1'
Local cFilMatriz	:= ''
Local cChv			:= ''
Local dtAux		:= CTod("  /  /    ")

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.

oTabCL8:setIndice(1)
oTabCL8:setAlias('CL8')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CL8')
TcSetField(cAlias,"CL8_PER","D",8,0)

Do While !(cAlias)->(Eof ())

	cChv		:= (cAlias)->CL8_CHV
	dtAux		:= (cAlias)->CL8_PER
	If lAgrupaT
		cChv	:= DTOS(dtNewPer)+ SubStr((cAlias)->CL8_CHV,9)
		dtAux	:= dtNewPer
		cConsol	:= '2'		
	EndIF

	cChave:= cFilMatriz+DTOS(dtAux)+cChv+(cAlias)->CL8_INDCRE+(cAlias)->CL8_CODBCC+(cAlias)->CL8_CST+cConsol

	oTabCL8:setChave(cChave)
	oTabCL8:Inclui()
	
	oTabCL8:SetCampo('CL8_FILIAL' 	,cFilMatriz)	
	oTabCL8:SetCampo('CL8_PER' 		,dtAux)	
	oTabCL8:SetCampo('CL8_CHV' 		,cChv)
	oTabCL8:SetCampo('CL8_CODBCC'	 ,(cAlias)->CL8_CODBCC)	
	oTabCL8:SetCampo('CL8_CST' 		,(cAlias)->CL8_CST)	
	oTabCL8:SetCampo('CL8_TRIB' 		,(cAlias)->CL8_TRIB)
	oTabCL8:SetCampo('CL8_INDCRE'	 ,(cAlias)->CL8_INDCRE)	
	oTabCL8:SetCampo('CL8_BSCALC' 	,(cAlias)->CL8_BSCALC,lAcumula)
	oTabCL8:SetCampo('CL8_VLCRED' 	,(cAlias)->CL8_VLCRED,lAcumula)	
	oTabCL8:SetCampo('CL8_AJAC' 	,(cAlias)->CL8_AJAC,lAcumula)
	oTabCL8:SetCampo('CL8_AJRD' 		,(cAlias)->CL8_AJRD,lAcumula)
	oTabCL8:SetCampo('CL8_DIF' 		,(cAlias)->CL8_DIF,lAcumula)
	oTabCL8:SetCampo('CL8_TOTCRD' ,(cAlias)->CL8_TOTCRD,lAcumula)
	oTabCL8:SetCampo('CL8_CRDUTI' ,(cAlias)->CL8_CRDUTI,lAcumula)
	oTabCL8:SetCampo('CL8_CRDFUT' ,(cAlias)->CL8_CRDFUT,lAcumula)
	oTabCL8:SetCampo('CL8_CONSOL'   ,cConsol)						

	oTabCL8:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCL8 )
oTabCL8:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil

Return

Static Function ConsCLA(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCLA	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cConsol		:= '1'
Local cFilMatriz	:= ''
Local cChv			:= ''
Local dtAux		:= CTod("  /  /    ")

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.

oTabCLA:setIndice(1)
oTabCLA:setAlias('CLA')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CLA')
TcSetField(cAlias,"CLA_DTREF","D",8,0)
//TcSetField(cAlias,"CLA_PERUTI","D",8,0)

Do While !(cAlias)->(Eof ())

	cChv		:= (cAlias)->CLA_CHV
	dtAux		:= (cAlias)->CLA_DTREF
	If lAgrupaT
		cChv	:= DTOS(dtNewPer)+ SubStr((cAlias)->CLA_CHV,9)
		dtAux	:= dtNewPer	
		cConsol		:= '2'	
	EndIF

	cChave:= cFilMatriz+cChv+(cAlias)->CLA_TPAJU+(cAlias)->CLA_COD+PAdr((cAlias)->CLA_NUM,50)+DTOS(dtAux)+cConsol+(cAlias)->CLA_DESCR

	oTabCLA:setChave(cChave)
	oTabCLA:Inclui()	
	//Somente passa campos de valores a serem acumulados
	oTabCLA:SetCampo('CLA_FILIAL'	 	,cFilMatriz)	
	oTabCLA:SetCampo('CLA_CHV'			 ,cChv)
	oTabCLA:SetCampo('CLA_ID' 			,(cAlias)->CLA_ID)
	oTabCLA:SetCampo('CLA_TPAJU'		 ,(cAlias)->CLA_TPAJU)
	oTabCLA:SetCampo('CLA_VLAJU'		 ,(cAlias)->CLA_VLAJU,lAcumula)			
	oTabCLA:SetCampo('CLA_COD'			 ,(cAlias)->CLA_COD)	
	oTabCLA:SetCampo('CLA_NUM'			 ,(cAlias)->CLA_NUM)
	oTabCLA:SetCampo('CLA_DESCR' 		,(cAlias)->CLA_DESCR)
	oTabCLA:SetCampo('CLA_DTREF' 		,dtAux)
	oTabCLA:SetCampo('CLA_CTA' 	    	,(cAlias)->CLA_CTA)
	oTabCLA:SetCampo('CLA_PERUTI'		 ,(cAlias)->CLA_PERUTI)
	oTabCLA:SetCampo('CLA_CONSOL'   	,cConsol)	
	

	oTabCLA:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCLA )
oTabCLA:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil



Return

Static Function ConsCKS(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCKS	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cConsol		:= '1'
Local cFilMatriz	:= ''
Local cChv			:= ''
Local dtAux		:= CTod("  /  /    ")

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.

oTabCKS:setIndice(1)
oTabCKS:setAlias('CKS')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CKS')
TcSetField(cAlias,"CKS_PER","D",8,0)

Do While !(cAlias)->(Eof ())

	cChv		:= (cAlias)->CKS_CHV
	dtAux		:= (cAlias)->CKS_PER
	If lAgrupaT
		cChv	:= DTOS(dtNewPer)+ SubStr((cAlias)->CKS_CHV,9)
		dtAux	:= dtNewPer
		cConsol		:= '2'		
	EndIF

	cChave:= cFilMatriz+DTOS(dtAux)+cChv+cConsol
	oTabCKS:setChave(cChave)

	oTabCKS:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCKS:SetCampo('CKS_FILIAL'	 	,cFilMatriz)	
	oTabCKS:SetCampo('CKS_PER'			,dtAux)
	oTabCKS:SetCampo('CKS_CHV' 			,cChv)
	oTabCKS:SetCampo('CKS_TRIB'			,(cAlias)->CKS_TRIB)
	oTabCKS:SetCampo('CKS_PAUTA'		,(cAlias)->CKS_PAUTA)			
	oTabCKS:SetCampo('CKS_VLREC'		,(cAlias)->CKS_VLREC,lAcumula)	
	oTabCKS:SetCampo('CKS_BASE'			,(cAlias)->CKS_BASE,lAcumula)
	oTabCKS:SetCampo('CKS_VLTRIB' 		,(cAlias)->CKS_VLTRIB,lAcumula)
	oTabCKS:SetCampo('CKS_AJAC' 		 ,(cAlias)->CKS_AJAC,lAcumula)
	oTabCKS:SetCampo('CKS_AJRD' 	   	,(cAlias)->CKS_AJRD,lAcumula)
	oTabCKS:SetCampo('CKS_DIF'		    ,(cAlias)->CKS_DIF,lAcumula)
	oTabCKS:SetCampo('CKS_DIFANT'		,(cAlias)->CKS_DIFANT,lAcumula)
	oTabCKS:SetCampo('CKS_VLDISP'		,(cAlias)->CKS_VLDISP,lAcumula)
	oTabCKS:SetCampo('CKS_CONSOL'   	,cConsol)	

	oTabCKS:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCKS )
oTabCKS:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil



Return

Static Function ConsCKU(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCKU	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cConsol		:= '1'
Local cFilMatriz	:= ''
Local dtAux		:= CTod("  /  /    ")

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.

oTabCKU:setIndice(1)
oTabCKU:setAlias('CKU')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CKU')
TcSetField(cAlias,"CKU_PER","D",8,0)

Do While !(cAlias)->(Eof ())
	
	dtAux		:= (cAlias)->CKU_PER
	If lAgrupaT	
		dtAux	:= dtNewPer	
		cConsol		:= '2'	
	EndIF


	cChave:= cFilMatriz+DTOS(dtAux)+cConsol
	oTabCKU:setChave(cChave)

	oTabCKU:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCKU:SetCampo('CKU_FILIAL'	 	,cFilMatriz)	
	oTabCKU:SetCampo('CKU_PER'			,dtAux)
	oTabCKU:SetCampo('CKU_RTNC' 		,(cAlias)->CKU_RTNC,lAcumula)
	oTabCKU:SetCampo('CKU_RNTNC'		,(cAlias)->CKU_RNTNC,lAcumula)
	oTabCKU:SetCampo('CKU_EXP'			,(cAlias)->CKU_EXP,lAcumula)			
	oTabCKU:SetCampo('CKU_RTC'			,(cAlias)->CKU_RTC,lAcumula)
	oTabCKU:SetCampo('CKU_CONSOL'   	,cConsol)		


	oTabCKU:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCKU )
oTabCKU:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return


//
Static Function ConsCKT(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCKT	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cConsol		:= '1'
Local cFilMatriz	:= ''
Local dtAux		:= CTod("  /  /    ")
Local nTamCONTA	:= TamSx3("CKT_CONTA")[1]

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.

oTabCKT:setIndice(1)
oTabCKT:setAlias('CKT')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CKT')
TcSetField(cAlias,"CKT_PER","D",8,0)

Do While !(cAlias)->(Eof ())
	
	dtAux		:= (cAlias)->CKT_PER
	If lAgrupaT	
		dtAux	:= dtNewPer
		cConsol		:= '2'		
	EndIF	

	cChave:= cFilMatriz+dTos(dtAux)+(cAlias)->CKT_TRIB+(cAlias)->CKT_CST+(cAlias)->CKT_CODNAT+PADR((cAlias)->CKT_CONTA,nTamCONTA)+cConsol+(cAlias)->CKT_ORIGEM
	oTabCKT:setChave(cChave)

	oTabCKT:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCKT:SetCampo('CKT_FILIAL'	 	,cFilMatriz)	
	oTabCKT:SetCampo('CKT_PER'			,dtAux)
	oTabCKT:SetCampo('CKT_TRIB' 		,(cAlias)->CKT_TRIB)
	oTabCKT:SetCampo('CKT_CST'			,(cAlias)->CKT_CST)
	oTabCKT:SetCampo('CKT_CODNAT'		,(cAlias)->CKT_CODNAT)			
	oTabCKT:SetCampo('CKT_VLREC'		,(cAlias)->CKT_VLREC,lAcumula)
	oTabCKT:SetCampo('CKT_CONTA'       ,(cAlias)->CKT_CONTA)
	oTabCKT:SetCampo('CKT_DESCR'		,(cAlias)->CKT_DESCR)	
	oTabCKT:SetCampo('CKT_CONSOL'		,cConsol)
	oTabCKT:SetCampo('CKT_ORIGEM'		,(cAlias)->CKT_ORIGEM)
	
	oTabCKT:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCKT )
oTabCKT:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return
//
Static Function ConsCL9(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCL9	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cConsol		:= '1'
Local cFilMatriz	:= ''
Local dtAux		:= CTod("  /  /    ")
Local cChv			:= ''
DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.

oTabCL9:setIndice(1)
oTabCL9:setAlias('CL9')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CL9')
TcSetField(cAlias,"CL9_PER","D",8,0)

Do While !(cAlias)->(Eof ())
	
	cChv		:= (cAlias)->CL9_CHV
	dtAux		:= (cAlias)->CL9_PER
	If lAgrupaT
		cChv	:= DTOS(dtNewPer)+ SubStr((cAlias)->CL9_CHV,9)
		dtAux	:= dtNewPer
		cConsol	:= '2'			
	EndIF	
	
	cChave:= cFilMatriz+dTos(dtAux)+cChv+(cAlias)->CL9_CODBCC+(cAlias)->CL9_CST+(cAlias)->CL9_PAUTA+cConsol
	oTabCL9:setChave(cChave)

	oTabCL9:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCL9:SetCampo('CL9_FILIAL'	 	,cFilMatriz)	
	oTabCL9:SetCampo('CL9_PER'			,dtAux)
	oTabCL9:SetCampo('CL9_CHV' 			,cChv)
	oTabCL9:SetCampo('CL9_CODBCC' 		,(cAlias)->CL9_CODBCC)
	oTabCL9:SetCampo('CL9_CST' 			,(cAlias)->CL9_CST)	
	oTabCL9:SetCampo('CL9_PAUTA' 		,(cAlias)->CL9_PAUTA)	
	oTabCL9:SetCampo('CL9_TOTBSE' 		,(cAlias)->CL9_TOTBSE,lAcumula)	
	oTabCL9:SetCampo('CL9_BSCUM' 		,(cAlias)->CL9_BSCUM,lAcumula)	
	oTabCL9:SetCampo('CL9_BSNCUM' 		,(cAlias)->CL9_BSNCUM,lAcumula)	
	oTabCL9:SetCampo('CL9_BSTCRD' 		,(cAlias)->CL9_BSTCRD,lAcumula)
	oTabCL9:SetCampo('CL9_DESCR' 		,(cAlias)->CL9_DESCR)
	oTabCL9:SetCampo('CL9_CONSOL' 		,cConsol)	
	
	oTabCL9:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCL9 )
oTabCL9:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return

Static Function ConsCKV(cAlias,aXFilial,cFilialMat,lIndividu)

Local cChave	:=''
Local oTabCKV	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cConsol		:= '1'
Local cFilMatriz	:= ''

oTabCKV:setIndice(1)
oTabCKV:setAlias('CKV')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CKV')
TcSetField(cAlias,"CKV_PER","D",8,0)

Do While !(cAlias)->(Eof ())

	cChave:= cFilMatriz+DTOS((cAlias)->CKV_PER)+(cAlias)->CKV_COD+cConsol
	oTabCKV:setChave(cChave)

	oTabCKV:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCKV:SetCampo('CKV_FILIAL'	 	,cFilMatriz)	
	oTabCKV:SetCampo('CKV_PER'			,(cAlias)->CKV_PER)
	oTabCKV:SetCampo('CKV_COD' 			,(cAlias)->CKV_COD)
	oTabCKV:SetCampo('CKV_TOTAP'		,(cAlias)->CKV_TOTAP,lAcumula)
	oTabCKV:SetCampo('CKV_AJAC'			,(cAlias)->CKV_AJAC,lAcumula)			
	oTabCKV:SetCampo('CKV_AJRD'			,(cAlias)->CKV_AJRD,lAcumula)
	oTabCKV:SetCampo('CKV_VLREC' 		,(cAlias)->CKV_VLREC,lAcumula)
	oTabCKV:SetCampo('CKV_RECBRU' 		,(cAlias)->CKV_RECBRU,lAcumula)
	oTabCKV:SetCampo('CKV_RECATI' 		,(cAlias)->CKV_RECATI,lAcumula)
	oTabCKV:SetCampo('CKV_EXCLU' 		,(cAlias)->CKV_EXCLU,lAcumula)
	oTabCKV:SetCampo('CKV_BASE' 		,(cAlias)->CKV_BASE,lAcumula)
	oTabCKV:SetCampo('CKV_CONSOL'   	,cConsol)	
	If CKV->(ColumnPos('CKV_FILAPU'))
		oTabCKV:SetCampo('CKV_FILAPU'   	,IIf(lIndividu,oTabCKV:BuscaxFil('CKV'),cFilialMat)) 
	Endif
	oTabCKV:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCKV )
oTabCKV:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return






//ckx
Static Function ConsCKX(cAlias,aXFilial)

Local cChave	:=''
Local oTabCKX	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cConsol		:= '1'
Local cFilMatriz	:= ''

oTabCKX:setIndice(1)
oTabCKX:setAlias('CKX')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CKX')
TcSetField(cAlias,"CKX_PER","D",8,0)

Do While !(cAlias)->(Eof ())

	cChave:= cFilMatriz+DTOS((cAlias)->CKX_PER)+(cAlias)->CKX_CODATI+(cAlias)->CKX_CODREC+STR((cAlias)->CKX_ALIQ,8,4)+cConsol
	oTabCKX:setChave(cChave)

	oTabCKX:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCKX:SetCampo('CKX_FILIAL'	 	,cFilMatriz)	
	oTabCKX:SetCampo('CKX_PER'			,(cAlias)->CKX_PER)
	oTabCKX:SetCampo('CKX_CODATI' 		,(cAlias)->CKX_CODATI)
	oTabCKX:SetCampo('CKX_CODREC'		,(cAlias)->CKX_CODREC)
	oTabCKX:SetCampo('CKX_VLBRUT'		,(cAlias)->CKX_VLBRUT,lAcumula)			
	oTabCKX:SetCampo('CKX_VLATI'		,(cAlias)->CKX_VLATI,lAcumula)
	oTabCKX:SetCampo('CKX_EXCLU' 		,(cAlias)->CKX_EXCLU,lAcumula)
	oTabCKX:SetCampo('CKX_BASE' 			,(cAlias)->CKX_BASE,lAcumula)
	oTabCKX:SetCampo('CKX_ALIQ'			,(cAlias)->CKX_ALIQ)
	oTabCKX:SetCampo('CKX_VLCPRB'		,(cAlias)->CKX_VLCPRB,lAcumula)			
	oTabCKX:SetCampo('CKX_CONTA'		,(cAlias)->CKX_CONTA)
	oTabCKX:SetCampo('CKX_INFORM' 		,(cAlias)->CKX_INFORM)
	oTabCKX:SetCampo('CKX_CONSOL'   	,cConsol)	


	oTabCKX:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCKX )
oTabCKX:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return


Static Function ConsCKZ(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCKZ	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cConsol		:= '1'
Local cFilMatriz	:= ''
Local cID			:= ''
Local dtAux		:= CTod("  /  /    ")

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.
oTabCKZ:setIndice(1)
oTabCKZ:setAlias('CKZ')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CKZ')
TcSetField(cAlias,"CKZ_PER","D",8,0)

Do While !(cAlias)->(Eof ())
	
	
	cID		:= (cAlias)->CKZ_ID
	dtAux	:=(cAlias)->CKZ_PER
	If lAgrupaT
		cID		:= DTOS(dtNewPer)+ SubStr((cAlias)->CKZ_ID,9)
		dtAux	:= dtNewPer
		cConsol		:= '2'
		
	EndIF	
	 	 	
	cChave:= cFilMatriz+DTOS(dtAux)+(cAlias)->CKZ_REGIME+cID+cConsol
	oTabCKZ:setChave(cChave)

	oTabCKZ:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCKZ:SetCampo('CKZ_FILIAL'	 	,cFilMatriz)	
	oTabCKZ:SetCampo('CKZ_PER'			,dtAux)
	oTabCKZ:SetCampo('CKZ_TRIB' 		,(cAlias)->CKZ_TRIB)
	oTabCKZ:SetCampo('CKZ_ALIQ'			,(cAlias)->CKZ_ALIQ)
	oTabCKZ:SetCampo('CKZ_COD'			,(cAlias)->CKZ_COD)			
	oTabCKZ:SetCampo('CKZ_ORIGEM'		,(cAlias)->CKZ_ORIGEM)
	oTabCKZ:SetCampo('CKZ_REGIME' 		,(cAlias)->CKZ_REGIME)
	oTabCKZ:SetCampo('CKZ_DEBCRD' 		,(cAlias)->CKZ_DEBCRD)
	oTabCKZ:SetCampo('CKZ_ID'			,cID)
	oTabCKZ:SetCampo('CKZ_CONSOL'   	,cConsol)	

	oTabCKZ:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCKZ )
oTabCKZ:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return

Static Function ConsCL0(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCL0	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cFilMatriz	:= ''
Local cConsol		:= '1'
Local dtAux		:= CTod("  /  /    ")

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.

oTabCL0:setIndice(1)
oTabCL0:setAlias('CL0')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CL0')
TcSetField(cAlias,"CL0_PER","D",8,0)

Do While !(cAlias)->(Eof ())
	
	dtAux		:= (cAlias)->CL0_PER
	If lAgrupaT
		dtAux	:= dtNewPer	
		cConsol		:= '2'
	EndIF

	cChave:= cFilMatriz+DTOS(dtAux)+(cAlias)->CL0_CST+cConsol+(cAlias)->CL0_ORIGEM
	oTabCL0:setChave(cChave)

	oTabCL0:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCL0:SetCampo('CL0_FILIAL'	 	,cFilMatriz)	
	oTabCL0:SetCampo('CL0_PER'			,dtAux)
	oTabCL0:SetCampo('CL0_CST' 			,(cAlias)->CL0_CST)
	oTabCL0:SetCampo('CL0_BASENC'		,(cAlias)->CL0_BASENC,lAcumula)
	oTabCL0:SetCampo('CL0_VLOPNC'		,(cAlias)->CL0_VLOPNC,lAcumula)			
	oTabCL0:SetCampo('CL0_BASEC'		,(cAlias)->CL0_BASEC,lAcumula)
	oTabCL0:SetCampo('CL0_VLOPC' 		,(cAlias)->CL0_VLOPC,lAcumula)
	oTabCL0:SetCampo('CL0_ORIGEM' 		,(cAlias)->CL0_ORIGEM)	
	oTabCL0:SetCampo('CL0_CONSOL'   	,cConsol)	

	oTabCL0:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCL0 )
oTabCL0:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return

Static Function ConsCL3(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCL3	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cFilMatriz	:= ''
Local cConsol		:= '1'
Local dtAux		:= CTod("  /  /    ")

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.

TcSetField(cAlias,"CL3_PER","D",8,0)
TcSetField(cAlias,"CL3_DTVENC","D",8,0)

oTabCL3:setIndice(1)
oTabCL3:setAlias('CL3')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CL3')

Do While !(cAlias)->(Eof ())
	
	dtAux		:= (cAlias)->CL3_PER
	If lAgrupaT		
		dtAux	:= dtNewPer
		cConsol		:= '2'		
	EndIF

	cChave:= cFilMatriz+DTOS(dtAux)+(cAlias)->CL3_TRIB+cConsol+(cAlias)->CL3_CODREC

	oTabCL3:setChave(cChave)

	oTabCL3:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCL3:SetCampo('CL3_FILIAL'	 	,cFilMatriz)	
	oTabCL3:SetCampo('CL3_PER'			,dtAux)
	oTabCL3:SetCampo('CL3_TRIB' 		,(cAlias)->CL3_TRIB)
	oTabCL3:SetCampo('CL3_CODREC'		,(cAlias)->CL3_CODREC)
	oTabCL3:SetCampo('CL3_VALOR'		,(cAlias)->CL3_VALOR,lAcumula)			
	oTabCL3:SetCampo('CL3_DTVENC'		,(cAlias)->CL3_DTVENC)
	oTabCL3:SetCampo('CL3_CONSOL'   	,cConsol)	

	oTabCL3:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCL3 )
oTabCL3:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return

Static Function ConsCCY(cAlias,aXFilial)

Local cChave	:=''
Local oTabCCY	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cFilMatriz	:= ''
Local cConsol		:= '1'
lOCAL oSaldoCred	
 
oSaldoCred:= SALDOCRED():New()
oSaldoCred:SetConsol(cConsol)
oSaldoCred:SetFilial(aXFilial)
oSaldoCred:SetDtIni(mv_par01)
oSaldoCred:SetTributo(PIS)
oSaldoCred:SetPer(Strzero(Month(mv_par01),2)+cvaltochar(Year(mv_par01)))
oSaldoCred:LimpaSaldo() //Limpa tabela de saldos somente do período

oSaldoCred:= Nil

oTabCCY:setIndice(5)
oTabCCY:setAlias('CCY')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CCY')

Do While !(cAlias)->(Eof ())

	cChave:= cFilMatriz+(cAlias)->CCY_PERIOD+(cAlias)->CCY_ANO+(cAlias)->CCY_MES+(cAlias)->CCY_ORICRE+(cAlias)->CCY_CNPJ+(cAlias)->CCY_COD+cConsol

	oTabCCY:setChave(cChave)

	oTabCCY:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCCY:SetCampo('CCY_FILIAL'	 	,cFilMatriz)	
	oTabCCY:SetCampo('CCY_PERIOD'		,(cAlias)->CCY_PERIOD)
	oTabCCY:SetCampo('CCY_REFER ' 		,(cAlias)->CCY_REFER)
	oTabCCY:SetCampo('CCY_COD'			,(cAlias)->CCY_COD)
	oTabCCY:SetCampo('CCY_UTIANT'		,(cAlias)->CCY_UTIANT,lAcumula)			
	oTabCCY:SetCampo('CCY_TOTCRD'		,(cAlias)->CCY_TOTCRD,lAcumula)
	oTabCCY:SetCampo('CCY_CREDUT'   	,(cAlias)->CCY_CREDUT,lAcumula)
	oTabCCY:SetCampo('CCY_CRDISP'   	,(cAlias)->CCY_CRDISP,lAcumula)
	oTabCCY:SetCampo('CCY_LEXTEM'   	,(cAlias)->CCY_LEXTEM,lAcumula)
	oTabCCY:SetCampo('CCY_ANO'		   	,(cAlias)->CCY_ANO)
	oTabCCY:SetCampo('CCY_MES'   		,(cAlias)->CCY_MES)
	oTabCCY:SetCampo('CCY_REANTE'   	,(cAlias)->CCY_REANTE,lAcumula)
	oTabCCY:SetCampo('CCY_COANTE'   	,(cAlias)->CCY_COANTE,lAcumula)
	oTabCCY:SetCampo('CCY_RESSA'	   	,(cAlias)->CCY_RESSA,lAcumula)
	oTabCCY:SetCampo('CCY_COMP'	   		,(cAlias)->CCY_COMP,lAcumula)
	oTabCCY:SetCampo('CCY_CNPJ' 		  	,(cAlias)->CCY_CNPJ)
	oTabCCY:SetCampo('CCY_ORICRE'   	,(cAlias)->CCY_ORICRE)					
	oTabCCY:SetCampo('CCY_CONSOL'   	,cConsol)	
	oTabCCY:SetCampo('CCY_FILAPU'	 	,cFilMatriz)
	oTabCCY:SetCampo('CCY_RESCRE'	 	,IIf(CCY->(ColumnPos('CCY_RESCRE'))>0,(cAlias)->CCY_RESCRE,"2"))

	oTabCCY:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCCY )
oTabCCY:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return

Static Function ConsCCW(cAlias,aXFilial)

Local cChave	:=''
Local oTabCCW	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cFilMatriz	:= ''
Local cConsol		:= '1'

Local oSaldoCred	
 
oSaldoCred:= SALDOCRED():New()
oSaldoCred:SetConsol(cConsol)
oSaldoCred:SetFilial(aXFilial)
oSaldoCred:SetDtIni(mv_par01)
oSaldoCred:SetTributo(COFINS)
oSaldoCred:SetPer(Strzero(Month(mv_par01),2)+cvaltochar(Year(mv_par01)))
oSaldoCred:LimpaSaldo() //Limpa tabela de saldos somente do período

oSaldoCred:= Nil

oTabCCW:setIndice(5)
oTabCCW:setAlias('CCW')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CCW')

Do While !(cAlias)->(Eof ())

	cChave:= cFilMatriz+(cAlias)->CCW_PERIOD+(cAlias)->CCW_ANO+(cAlias)->CCW_MES+(cAlias)->CCW_ORICRE+(cAlias)->CCW_CNPJ+(cAlias)->CCW_COD+cConsol

	oTabCCW:setChave(cChave)

	oTabCCW:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCCW:SetCampo('CCW_FILIAL'	 	,cFilMatriz)	
	oTabCCW:SetCampo('CCW_PERIOD'		,(cAlias)->CCW_PERIOD)
	oTabCCW:SetCampo('CCW_REFER ' 		,(cAlias)->CCW_REFER)
	oTabCCW:SetCampo('CCW_COD'			,(cAlias)->CCW_COD)
	oTabCCW:SetCampo('CCW_UTIANT'		,(cAlias)->CCW_UTIANT,lAcumula)			
	oTabCCW:SetCampo('CCW_TOTCRD'		,(cAlias)->CCW_TOTCRD,lAcumula)
	oTabCCW:SetCampo('CCW_CREDUT'   	,(cAlias)->CCW_CREDUT,lAcumula)
	oTabCCW:SetCampo('CCW_CRDISP'   	,(cAlias)->CCW_CRDISP,lAcumula)
	oTabCCW:SetCampo('CCW_LEXTEM'   	,(cAlias)->CCW_LEXTEM,lAcumula)
	oTabCCW:SetCampo('CCW_ANO'		   	,(cAlias)->CCW_ANO)
	oTabCCW:SetCampo('CCW_MES'   		,(cAlias)->CCW_MES)
	oTabCCW:SetCampo('CCW_REANTE'   	,(cAlias)->CCW_REANTE,lAcumula)
	oTabCCW:SetCampo('CCW_COANTE'   	,(cAlias)->CCW_COANTE,lAcumula)
	oTabCCW:SetCampo('CCW_RESSA'	   	,(cAlias)->CCW_RESSA,lAcumula)
	oTabCCW:SetCampo('CCW_COMP'	   		,(cAlias)->CCW_COMP,lAcumula)
	oTabCCW:SetCampo('CCW_CNPJ' 		  	,(cAlias)->CCW_CNPJ)
	oTabCCW:SetCampo('CCW_ORICRE'   	,(cAlias)->CCW_ORICRE)					
	oTabCCW:SetCampo('CCW_CONSOL'   	,cConsol)
	oTabCCW:SetCampo('CCW_RESCRE'	 	,IIf(CCW->(ColumnPos('CCW_RESCRE'))>0,(cAlias)->CCW_RESCRE,"2"))

	oTabCCW:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCCW )
oTabCCW:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return

Static Function ConsSFV(cAlias,aXFilial)

Local cChave	:=''
Local oTabSFV	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cFilMatriz	:= ''
Local cConsol		:= '1'

oTabSFV:setIndice(2)
oTabSFV:setAlias('SFV')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('SFV')

Do While !(cAlias)->(Eof ())
	
	cChave:= cFilMatriz+(cAlias)->FV_NATRET+(cAlias)->FV_TPREG+(cAlias)->FV_PER+(cAlias)->FV_MESANO+cConsol

	oTabSFV:setChave(cChave)

	oTabSFV:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabSFV:SetCampo('FV_FILIAL'	 	,cFilMatriz)	
	oTabSFV:SetCampo('FV_NATRET'		,(cAlias)->FV_NATRET)
	oTabSFV:SetCampo('FV_PER' 			,(cAlias)->FV_PER)
	oTabSFV:SetCampo('FV_TOTRET'		,(cAlias)->FV_TOTRET,lAcumula)
	oTabSFV:SetCampo('FV_VLDISP'		,(cAlias)->FV_VLDISP,lAcumula)			
	oTabSFV:SetCampo('FV_TPREG'			,(cAlias)->FV_TPREG)
	oTabSFV:SetCampo('FV_MESANO'   		,(cAlias)->FV_MESANO)
	oTabSFV:SetCampo('FV_APURPER'   	,(cAlias)->FV_APURPER,lAcumula)
	oTabSFV:SetCampo('FV_CONSOL'   		,cConsol)	

	oTabSFV:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabSFV )
oTabSFV:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return

Static Function ConsSFW(cAlias,aXFilial)

Local cChave	:=''
Local oTabSFW	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cFilMatriz	:= ''
Local cConsol		:= '1'

oTabSFW:setIndice(2)
oTabSFW:setAlias('SFW')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('SFW')

Do While !(cAlias)->(Eof ())
	
	cChave:= cFilMatriz+(cAlias)->FW_NATRET+(cAlias)->FW_TPREG+(cAlias)->FW_PER+(cAlias)->FW_MESANO+cConsol

	oTabSFW:setChave(cChave)

	oTabSFW:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabSFW:SetCampo('FW_FILIAL'	 	,cFilMatriz)	
	oTabSFW:SetCampo('FW_NATRET'		,(cAlias)->FW_NATRET)
	oTabSFW:SetCampo('FW_PER' 			,(cAlias)->FW_PER)
	oTabSFW:SetCampo('FW_TOTRET'		,(cAlias)->FW_TOTRET,lAcumula)
	oTabSFW:SetCampo('FW_VLDISP'		,(cAlias)->FW_VLDISP,lAcumula)			
	oTabSFW:SetCampo('FW_TPREG'			,(cAlias)->FW_TPREG)
	oTabSFW:SetCampo('FW_MESANO'   		,(cAlias)->FW_MESANO)
	oTabSFW:SetCampo('FW_APURPER'   	,(cAlias)->FW_APURPER,lAcumula)
	oTabSFW:SetCampo('FW_CONSOL'   		,cConsol)	

	oTabSFW:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabSFW )
oTabSFW:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return


//CFA
Static Function ConsCFA(cAlias,aXFilial)

Local cChave		:=''
Local oTabCFA		:= TABELAEFD():New()
Local oEFDGen		:= EFDGEN():New()
Local lAcumula		:= .T.
Local cFilMatriz	:= ''
Local cConsol		:= '1'

oTabCFA:setIndice(1)
oTabCFA:setAlias('CFA')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CFA')

Do While !(cAlias)->(Eof ())                                                            
	
	cChave:= cFilMatriz+(cAlias)->CFA_PERAPU+(cAlias)->CFA_TPCON+(cAlias)->CFA_CODCON+(cAlias)->CFA_CNPJ+STR((cAlias)->CFA_ALIQ,5,2)+(cAlias)->CFA_CODCRE+cConsol

	oTabCFA:setChave(cChave)

	oTabCFA:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCFA:SetCampo('CFA_FILIAL'	 	,cFilMatriz)		
	oTabCFA:SetCampo('CFA_CODCON'		,(cAlias)->CFA_CODCON)
	oTabCFA:SetCampo('CFA_TPCON ' 		,(cAlias)->CFA_TPCON)
	oTabCFA:SetCampo('CFA_CNPJ  '		,(cAlias)->CFA_CNPJ)
	oTabCFA:SetCampo('CFA_TOTVEN'		,(cAlias)->CFA_TOTVEN,lAcumula)			
	oTabCFA:SetCampo('CFA_TOTDIF'		,(cAlias)->CFA_TOTDIF,lAcumula)
	oTabCFA:SetCampo('CFA_CONDIF'   	,(cAlias)->CFA_CONDIF,lAcumula)
	oTabCFA:SetCampo('CFA_CREDIF'   	,(cAlias)->CFA_CREDIF,lAcumula)	
	oTabCFA:SetCampo('CFA_ALIQ  '   	,(cAlias)->CFA_ALIQ)
	oTabCFA:SetCampo('CFA_CODCRE'   	,(cAlias)->CFA_CODCRE)
	oTabCFA:SetCampo('CFA_CONREC'   	,(cAlias)->CFA_CONREC,lAcumula)
	oTabCFA:SetCampo('CFA_VLRREC'   	,(cAlias)->CFA_VLRREC,lAcumula)
	oTabCFA:SetCampo('CFA_VLNREC'   	,(cAlias)->CFA_VLNREC,lAcumula)
	oTabCFA:SetCampo('CFA_PERAPU'   	,(cAlias)->CFA_PERAPU)
	oTabCFA:SetCampo('CFA_CONSOL'   	,cConsol)	

	oTabCFA:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCFA )
oTabCFA:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return

//CFB
Static Function ConsCFB(cAlias,aXFilial)

Local cChave		:=''
Local oTabCFB		:= TABELAEFD():New()
Local oEFDGen		:= EFDGEN():New()
Local lAcumula		:= .T.
Local cFilMatriz	:= ''
Local cConsol		:= '1'

oTabCFB:setIndice(1)
oTabCFB:setAlias('CFB')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CFB')
TcSetField(cAlias,"CFB_DTPGTO","D",8,0)
Do While !(cAlias)->(Eof ())
	                                                                 
	cChave:= cFilMatriz+(cAlias)->CFB_PERAPU+(cAlias)->CFB_TPCON+(cAlias)->CFB_CODCON+(cAlias)->CFB_PERDIF+ DTOS((cAlias)->CFB_DTPGTO )+ STR((cAlias)->CFB_ALIQ,5,2)+(cAlias)->CFB_NATCRE +cConsol

	oTabCFB:setChave(cChave)

	oTabCFB:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCFB:SetCampo('CFB_FILIAL'	 	,cFilMatriz)		
	oTabCFB:SetCampo('CFB_CODCON'		,(cAlias)->CFB_CODCON)
	oTabCFB:SetCampo('CFB_TPCON' 		,(cAlias)->CFB_TPCON)
	oTabCFB:SetCampo('CFB_VLRREC'		,(cAlias)->CFB_VLRREC,lAcumula)
	oTabCFB:SetCampo('CFB_CONREC'		,(cAlias)->CFB_CONREC,lAcumula)			
	oTabCFB:SetCampo('CFB_PERDIF'		,(cAlias)->CFB_PERDIF)
	oTabCFB:SetCampo('CFB_DTPGTO'   	,(cAlias)->CFB_DTPGTO)
	oTabCFB:SetCampo('CFB_NATCRE'   	,(cAlias)->CFB_NATCRE)	
	oTabCFB:SetCampo('CFB_CREDES'   	,(cAlias)->CFB_CREDES,lAcumula)
	oTabCFB:SetCampo('CFB_PERAPU'   	,(cAlias)->CFB_PERAPU)
	oTabCFB:SetCampo('CFB_ALIQ  '   	,(cAlias)->CFB_ALIQ)
	oTabCFB:SetCampo('CFB_CONSOL'  		,cConsol)	

	oTabCFB:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCFB )
oTabCFB:= Nil

FreeObj( oEFDGen )
oEFDGen:= Nil
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AjusteCPRB
 
 Função que irá chamar o ponto de entrada SPEDCP210 e trazer os valores 
 de ajustes da CPRB. Estes valores erão excluídos da tabela de CPRB consolidada CKX,
 e deverá ser chamada somente quando apuração for processada de maneira consolidada.
 
@author Erick G. Dias
@since 30/07/2014
@version 11.80

/*/
//-------------------------------------------------------------------

Static Function AjusteCPRB(dDataDe,dDataAte,aSM0,cFilialMat,lindividu)

Local 	aAreaSM0 	:= SM0->(GetArea())
Local aRegPE210 	:= {}
Local nP210	   	:= 0	
Local oCPRB		:= CPRBEFD():New()

If ExistBlock('SPEDCP210')
	aRegPE210 := ExecBlock("SPEDCP210", .F., .F.,{ dDataDe, dDataAte, aSm0,mv_par16  ,mv_par17 }  )
Else	
	aRegPE210 := FSA001CPRB(dDataDe,dDataAte)
Endif	

RestArea (aAreaSM0)

If Len(aRegPE210) > 0 // Processou
	oCPRB:SetConsol('2')
	oCPRB:SetDtIni(MV_PAR01)
EndIF

For nP210 := 1 to Len(aRegPE210)
	oCPRB:SetCodRec(aRegPE210[nP210][7])
	oCPRB:SetTpAju(Iif(aRegPE210[nP210][1] == '0',REDUCAO ,ACRESCIMO ))
	oCPRB:SetValAju(aRegPE210[nP210][2])
	oCPRB:SetCodAjus(aRegPE210[nP210][3])
	oCPRB:SetNumero(aRegPE210[nP210][4])
	oCPRB:SetDescr(aRegPE210[nP210][5])		
	oCPRB:SetDtRefer(ctod(substr(aRegPE210[nP210][6],1,2)+'/'+substr(aRegPE210[nP210][6],3,2)+'/'+substr(aRegPE210[nP210][6],5,4)))
	oCPRB:SetFilApu(IIf(lIndividu,oCPRB:BuscaxFil('CKR'),cFilialMat))  
	oCPRB:GravaAju()
Next nP210

If Len(aRegPE210) > 0 // Processou
	//Grava os valores alterados.
	oCPRB:AtualizaCPRB()
EndIF


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ReprocEFD
 
Função que irá realizar o reprocessamento da EFD, conforme opções
selecionadas pelo usuário na tela inicial da apuração.
 
@author Erick G. Dias
@since 30/07/2014
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function ReprocEFD(dDataDe,dDataAte,cConsl,aReprocess,aXFilialRe)

Local cAliasCKZ	:= ''
Local aReproc	:= {}
Local nCont
Local oEFDGen	:= EFDGEN():New()

oEFDGen:SetFilial(aXFilialRe)

Aadd(aReproc,{FISCALENT		,Iif(aReprocess[1] == 1,.T.,.F.)})
Aadd(aReproc,{FISCALSAI		,Iif(aReprocess[2] == 1,.T.,.F.)})
Aadd(aReproc,{TITENTRADA	,Iif(aReprocess[3] == 1,.T.,.F.)})
Aadd(aReproc,{TITSAIDA		,Iif(aReprocess[4] == 1,.T.,.F.)})
Aadd(aReproc,{ATIVOFIXO		,Iif(aReprocess[5] == 1,.T.,.F.)})
Aadd(aReproc,{CUPOM			,Iif(aReprocess[6] == 1,.T.,.F.)})
Aadd(aReproc,{CPRB			,Iif(aReprocess[7] == 1,.T.,.F.)})
Aadd(aReproc,{OUTROS			,.T.})

For nCont := 1 to len(aReproc)		
	Do Case
	
		Case aReproc[nCont][2] .AND. aReproc[nCont][1] == FISCALENT
			ISA001CL8(dDataDe,dDataAte,FISCALENT,cConsl,oEFDGen)
						
		Case aReproc[nCont][2] .AND. aReproc[nCont][1] == FISCALSAI
			ISA001CKS(dDataDe,dDataAte,FISCALSAI,cConsl,oEFDGen)			

		Case aReproc[nCont][2] .AND. aReproc[nCont][1] == TITENTRADA
			ISA001CL8(dDataDe,dDataAte,TITENTRADA,cConsl,oEFDGen)	
			ISA001CL2(dDataDe,dDataAte,TITENTRADA,cConsl,'F100',oEFDGen)

		Case aReproc[nCont][2] .AND. aReproc[nCont][1] == TITSAIDA
			ISA001CKS(dDataDe,dDataAte,TITSAIDA,cConsl,oEFDGen)	
			ISA001CL2(dDataDe,dDataAte,TITSAIDA,cConsl,'F100',oEFDGen)			
			
		Case aReproc[nCont][2] .AND. aReproc[nCont][1] == ATIVOFIXO
			ISA001CL8(dDataDe,dDataAte,ATIVOFIXO,cConsl,oEFDGen)
			ISA001CL2(dDataDe,dDataAte,ATIVOFIXO,cConsl,'F120',oEFDGen)
			ISA001CL2(dDataDe,dDataAte,ATIVOFIXO,cConsl,'F130',oEFDGen)
			
		Case aReproc[nCont][2] .AND. aReproc[nCont][1] == CUPOM
			ISA001CKS(dDataDe,dDataAte,CUPOM,cConsl,oEFDGen)
			
		Case aReproc[nCont][2] .AND. aReproc[nCont][1] == OUTROS
			ISA001CL8(dDataDe,dDataAte,OUTROS,cConsl,oEFDGen)
			ISA001CKS(dDataDe,dDataAte,OUTROS,cConsl,oEFDGen)			
			
		Case aReproc[nCont][2] .AND. aReproc[nCont][1] == CPRB
			ISA001CKV(dDataDe,dDataAte,CPRB,cConsl,oEFDGen)
					
	EndCase
	
Next nCont

ZeraCKS(dDataDe,dDataAte,cConsl,oEFDGen)
ZeraCL8(dDataDe,dDataAte,cConsl,oEFDGen)

FreeObj( oEFDGen )
oEFDGen:= Nil

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ISA001CKZ
 
Função que irá buscar os valores da tabela CKZ, para que a partir da chave
desta tabela possa ir reprocessando somente as informações solicitadas
pelo usuário na tela de reprocessamento.
 

@author Erick G. Dias
@return	cAliasCKZ  - Resultado da query da CKZ.
@since 05/08/2014
@version 11.80

/*/
//-------------------------------------------------------------------

Static Function ISA001CKZ(dDataDe,dDataAte,cFilCKZ,cConsl,cOrigem)

Local cAliasCKZ	:= 'CKZ'
Local cSlctCKZ	:= ''
Local cFiltro		:= ''

cSlctCKZ:= '%CKZ.CKZ_ID%'

cFiltro := "%"
cFiltro += "CKZ.CKZ_FILIAL= '"+ cFilCKZ+ "' AND "
cFiltro += "CKZ.CKZ_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CKZ.CKZ_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += "CKZ.CKZ_ORIGEM = '" +cOrigem + "' AND "
cFiltro += "CKZ.CKZ_CONSOL = '" +cConsl + "' AND "
cFiltro += "%"

cAliasCKZ	:=	GetNextAlias()
BeginSql Alias cAliasCKZ
    	
	SELECT
	%Exp:cSlctCKZ%

	FROM
	%Table:CKZ% CKZ	
	WHERE
	%Exp:cFiltro%
	CKZ.%NotDel%

EndSql

Return cAliasCKZ



Static Function ISA001CL8(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)


Local cAliasCL8	:= ''
Local cCampos	:= ''
Local cFiltro	:= ''

Local cSubQuery	:= ''

cSubQuery := "select CKZ.CKZ_ID FROM " +  RetSqlName('CKZ')+ " CKZ WHERE "
cSubQuery += "(CKZ_ORIGEM = '" + cOrigem + "' OR CKZ_ORIGEM = ' ') AND CKZ_PER >= '" + dTos(dDataDe) + "' "
cSubQuery += " AND CKZ_PER <=  '" + dTos(dDataAte) + "' AND CKZ.CKZ_CONSOL = '" +cConsl + "' AND D_E_L_E_T_ <> '*'"

cCampos	:= '%CL8.CL8_CHV ,CL8.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CL8.CL8_FILIAL= '"+ oEFDGen:BuscaxFil('CL8')+ "' AND "
cFiltro += "CL8.CL8_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CL8.CL8_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += ' CL8.CL8_CHV IN  (' + cSubQuery + ') AND '
cFiltro += "CL8.CL8_CONSOL = '" +cConsl + "' AND "

cFiltro += "%"
cAliasCL8	:=	GetNextAlias()

BeginSql Alias cAliasCL8
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CL8% CL8	
	WHERE
	%Exp:cFiltro%
	CL8.%NotDel%

EndSql

Do While !(cAliasCL8)->(EOF())
	CL8->(dbGoto((cAliasCL8)->NRECNO))		
	RecLock("CL8",.F.)
	CL8->(dbDelete())
	MsUnLock()
	CL8->(FKCommit())
	(cAliasCL8)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCL8)
(cAliasCL8)->(DbCloseArea ())

ISA001CL9(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)
ISA001CL0(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)

Return




Static Function ISA001CKS(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)


Local cAliasCKS	:= ''
Local cCampos	:= ''
Local cFiltro	:= ''

Local cSubQuery	:= ''

cSubQuery := "select CKZ.CKZ_ID FROM " +  RetSqlName('CKZ')+ " CKZ WHERE "
cSubQuery += "(CKZ_ORIGEM = '" + cOrigem + "' OR CKZ_ORIGEM = ' ' )AND CKZ_PER >= '" + dTos(dDataDe) + "' "
cSubQuery += " AND CKZ_PER <=  '" + dTos(dDataAte) + "' AND CKZ.CKZ_CONSOL = '" +cConsl + "' AND D_E_L_E_T_ <> '*'"

cCampos	:= '%CKS.CKS_CHV ,CKS.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CKS.CKS_FILIAL= '"+ oEFDGen:BuscaxFil('CKS')+ "' AND "
cFiltro += "CKS.CKS_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CKS.CKS_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += ' CKS.CKS_CHV IN  (' + cSubQuery + ') AND '
cFiltro += "CKS.CKS_CONSOL = '" +cConsl + "' AND "

cFiltro += "%"
cAliasCKS	:=	GetNextAlias()

BeginSql Alias cAliasCKS
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKS% CKS	
	WHERE
	%Exp:cFiltro%
	CKS.%NotDel%

EndSql

Do While !(cAliasCKS)->(EOF())
	CKS->(dbGoto((cAliasCKS)->NRECNO))		
	RecLock("CKS",.F.)
	CKS->(dbDelete())
	MsUnLock()
	CKS->(FKCommit())
	(cAliasCKS)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCKS)
(cAliasCKS)->(DbCloseArea ())


ISA001CL9(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)
ISA001CL0(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)
ISA001CKU(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)
ISA001CKT(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)

Return


Static Function ISA001CL9(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)


Local cAliasCL9	:= ''
Local cCampos	:= ''
Local cFiltro	:= ''

Local cSubQuery	:= ''

cSubQuery := "select CKZ.CKZ_ID FROM " +  RetSqlName('CKZ')+ " CKZ WHERE "
cSubQuery += "(CKZ_ORIGEM = '" + cOrigem + "' OR CKZ_ORIGEM = ' ' )AND CKZ_PER >= '" + dTos(dDataDe) + "' "
cSubQuery += " AND CKZ_PER <=  '" + dTos(dDataAte) + "' AND CKZ.CKZ_CONSOL = '" +cConsl + "' AND D_E_L_E_T_ <> '*'"

cCampos	:= '%CL9.CL9_CHV ,CL9.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CL9.CL9_FILIAL= '"+ oEFDGen:BuscaxFil('CL9')+ "' AND "
cFiltro += "CL9.CL9_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CL9.CL9_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += ' CL9.CL9_CHV IN  (' + cSubQuery + ') AND '
cFiltro += "CL9.CL9_CONSOL = '" +cConsl + "' AND "

cFiltro += "%"
cAliasCL9	:=	GetNextAlias()

BeginSql Alias cAliasCL9
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CL9% CL9	
	WHERE
	%Exp:cFiltro%
	CL9.%NotDel%

EndSql

Do While !(cAliasCL9)->(EOF())
	CL9->(dbGoto((cAliasCL9)->NRECNO))		
	RecLock("CL9",.F.)
	CL9->(dbDelete())
	MsUnLock()
	CL9->(FKCommit())
	(cAliasCL9)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCL9)
(cAliasCL9)->(DbCloseArea ())

Return

Static Function ISA001CLA(dDataDe,dDataAte,cOrigem,cConsl,aXFilial)


Local cAliasCLA	:= ''
Local cCampos	:= ''
Local cFiltro	:= ''

Local cSubQuery	:= ''
Local oEFDGen	:= EFDGEN():New()
oEFDGen:SetFilial(aXFilial)


cSubQuery := "select CKZ.CKZ_ID FROM " +  RetSqlName('CKZ')+ " CKZ WHERE "
cSubQuery += "CKZ_PER >= '" + dTos(dDataDe) + "' "
cSubQuery += " AND CKZ_PER <=  '" + dTos(dDataAte) + "' AND CKZ.CKZ_CONSOL = '" +cConsl + "' AND D_E_L_E_T_ <> '*'"

cCampos	:= '%CLA.CLA_CHV ,CLA.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CLA.CLA_FILIAL= '"+ oEFDGen:BuscaxFil('CLA')+ "' AND "
cFiltro += ' CLA.CLA_CHV IN  (' + cSubQuery + ') AND '
cFiltro += "CLA.CLA_CONSOL = '" +cConsl + "' AND "

cFiltro += "%"
cAliasCLA	:=	GetNextAlias()

BeginSql Alias cAliasCLA
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CLA% CLA	
	WHERE
	%Exp:cFiltro%
	CLA.%NotDel%

EndSql

Do While !(cAliasCLA)->(EOF())
	CLA->(dbGoto((cAliasCLA)->NRECNO))		
	RecLock("CLA",.F.)
	CLA->(dbDelete())
	MsUnLock()
	CLA->(FKCommit())
	(cAliasCLA)->(DBSKIP())
EndDo		

DbSelectArea (cAliasCLA)
(cAliasCLA)->(DbCloseArea ())

ISA001CL4(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)

Return

Static Function ISA001CL4(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)


Local cAliasCL4	:= ''
Local cCampos	:= ''
Local cFiltro	:= ''

Local cSubQuery	:= ''

cSubQuery := "select CKZ.CKZ_ID FROM " +  RetSqlName('CKZ')+ " CKZ WHERE "
cSubQuery += " CKZ_PER >= '" + dTos(dDataDe) + "' "
cSubQuery += " AND CKZ_PER <=  '" + dTos(dDataAte) + "' AND CKZ.CKZ_CONSOL = '" +cConsl + "' AND D_E_L_E_T_ <> '*'"

cCampos	:= '%CL4.CL4_CHV ,CL4.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CL4.CL4_FILIAL= '"+ oEFDGen:BuscaxFil('CL4')+ "' AND "
cFiltro += ' CL4.CL4_CHV IN  (' + cSubQuery + ') AND '

cFiltro += "%"
cAliasCL4	:=	GetNextAlias()

BeginSql Alias cAliasCL4
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CL4% CL4	
	WHERE
	%Exp:cFiltro%
	CL4.%NotDel%

EndSql

Do While !(cAliasCL4)->(EOF())
	CL4->(dbGoto((cAliasCL4)->NRECNO))		
	RecLock("CL4",.F.)
	CL4->(dbDelete())
	MsUnLock()
	CL4->(FKCommit())
	(cAliasCL4)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCL4)
(cAliasCL4)->(DbCloseArea ())

Return

Static Function ISA001CKV(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)

Local cAliasCKV	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''

ISA001CKW(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)


cCampos	:= '%CKV.CKV_COD ,CKV.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CKV.CKV_FILIAL= '"+ oEFDGen:BuscaxFil('CKV')+ "' AND "
cFiltro += "CKV.CKV_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CKV.CKV_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "

cFiltro += "%"
cAliasCKV	:=	GetNextAlias()

BeginSql Alias cAliasCKV
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKV% CKV	
	WHERE
	%Exp:cFiltro%
	CKV.%NotDel%

EndSql

Do While !(cAliasCKV)->(EOF())
	CKV->(dbGoto((cAliasCKV)->NRECNO))		
	RecLock("CKV",.F.)
	CKV->(dbDelete())
	MsUnLock()
	CKV->(FKCommit())
	(cAliasCKV)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCKV)
(cAliasCKV)->(DbCloseArea ())

Return

Static Function ISA001CKW(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)

Local cAliasCKW	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''

Local cSubQuery	:= ''

cSubQuery := "select CKV.CKV_COD FROM " +  RetSqlName('CKV')+ " CKV WHERE "
cSubQuery += "CKV_PER >= '" + dTos(dDataDe) + "' "
cSubQuery += "AND CKV_PER <=  '" + dTos(dDataAte) + "' AND D_E_L_E_T_ <> '*'"

cCampos	:= '%CKW.CKW_CODREC ,CKW.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CKW.CKW_FILIAL= '"+ oEFDGen:BuscaxFil('CKW')+ "' AND "
cFiltro += "CKW.CKW_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CKW.CKW_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += 'CKW.CKW_CODREC IN  (' + cSubQuery + ') AND '
cFiltro += "CKW.CKW_CONSOL = '" +cConsl + "' AND "

cFiltro += "%"
cAliasCKW	:=	GetNextAlias()

BeginSql Alias cAliasCKW
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKW% CKW	
	WHERE
	%Exp:cFiltro%
	CKW.%NotDel%

EndSql

Do While !(cAliasCKW)->(EOF())
	CKW->(dbGoto((cAliasCKW)->NRECNO))		
	RecLock("CKW",.F.)
	CKW->(dbDelete())
	MsUnLock()
	CKW->(FKCommit())
	(cAliasCKW)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCKW)
(cAliasCKW)->(DbCloseArea ())

Return

Static Function ISA001CKX(dDataDe,dDataAte)

Local cAliasCKX	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''

cCampos := '%CKX.R_E_C_N_O_ as NRECNO%'
cFiltro := "%"
cFiltro += "CKX.CKX_FILIAL= '"+ xFilial("CKX") + "' AND "
cFiltro += "CKX.CKX_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CKX.CKX_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += "CKX.CKX_FILAPU = ' ' AND "
cFiltro += "%"

cAliasCKX	:=	GetNextAlias()

BeginSql Alias cAliasCKX
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKX% CKX	
	WHERE
	%Exp:cFiltro%
	CKX.%NotDel%

EndSql

Do While !(cAliasCKX)->(EOF())
	CKX->(dbGoto((cAliasCKX)->NRECNO))		
	RecLock("CKX",.F.)
	CKX->(dbDelete())
	MsUnLock()
	CKX->(FKCommit())
	(cAliasCKX)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCKX)
(cAliasCKX)->(DbCloseArea ())

Return

Static Function ISA001CL2(dDataDe,dDataAte,cOrigem,cConsl,cReg,oEFDGen)

Local cAliasCL2	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''

cCampos	:= '%CL2.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CL2.CL2_FILIAL= '"+ oEFDGen:BuscaxFil('CL2')+ "' AND "
cFiltro += "CL2.CL2_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CL2.CL2_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += "CL2.CL2_REG = '" + cReg + "' AND "
cFiltro += "%"

cAliasCL2	:=	GetNextAlias()

BeginSql Alias cAliasCL2
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CL2% CL2	
	WHERE
	%Exp:cFiltro%
	CL2.%NotDel%

EndSql

Do While !(cAliasCL2)->(EOF())
	CL2->(dbGoto((cAliasCL2)->NRECNO))		
	RecLock("CL2",.F.)
	CL2->(dbDelete())
	MsUnLock()
	CL2->(FKCommit())
	(cAliasCL2)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCL2)
(cAliasCL2)->(DbCloseArea ())

ISA001CL0(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)
ISA001CKU(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)
ISA001CKT(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)

Return


Static Function ISA001CKT(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)

Local cAliasCKT	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''

cCampos	:= '%CKT.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CKT.CKT_FILIAL= '"+ oEFDGen:BuscaxFil('CKT')+ "' AND "
cFiltro += "CKT.CKT_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CKT.CKT_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += "CKT.CKT_ORIGEM= '" + cOrigem + "' AND "

cFiltro += "%"
cAliasCKT	:=	GetNextAlias()

BeginSql Alias cAliasCKT
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKT% CKT	
	WHERE
	%Exp:cFiltro%
	CKT.%NotDel%

EndSql

Do While !(cAliasCKT)->(EOF())
	CKT->(dbGoto((cAliasCKT)->NRECNO))		
	RecLock("CKT",.F.)
	CKT->(dbDelete())
	MsUnLock()
	CKT->(FKCommit())
	(cAliasCKT)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCKT)
(cAliasCKT)->(DbCloseArea ())

Return

Static Function ISA001CKU(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)

Local cAliasCKU	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''

cCampos	:= '%CKU.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CKU.CKU_FILIAL= '"+ oEFDGen:BuscaxFil('CKU')+ "' AND "
cFiltro += "CKU.CKU_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CKU.CKU_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += "(CKU.CKU_ORIGEM= '" + cOrigem + "' OR CKU.CKU_ORIGEM = ' ') AND "

cFiltro += "%"
cAliasCKU	:=	GetNextAlias()

BeginSql Alias cAliasCKU
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKU% CKU	
	WHERE
	%Exp:cFiltro%
	CKU.%NotDel%

EndSql

Do While !(cAliasCKU)->(EOF())
	CKU->(dbGoto((cAliasCKU)->NRECNO))		
	RecLock("CKU",.F.)
	CKU->(dbDelete())
	MsUnLock()
	CKU->(FKCommit())
	(cAliasCKU)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCKU)
(cAliasCKU)->(DbCloseArea ())

Return



Static Function ISA001CL0(dDataDe,dDataAte,cOrigem,cConsl,oEFDGen)

Local cAliasCL0	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''

cCampos	:= '%CL0.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CL0.CL0_FILIAL= '"+ oEFDGen:BuscaxFil('CL0')+ "' AND "
cFiltro += "CL0.CL0_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CL0.CL0_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += "(CL0.CL0_ORIGEM= '" + cOrigem + "' or CL0.CL0_ORIGEM = ' '  ) AND "

cFiltro += "%"
cAliasCL0	:=	GetNextAlias()

BeginSql Alias cAliasCL0
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CL0% CL0	
	WHERE
	%Exp:cFiltro%
	CL0.%NotDel%

EndSql

Do While !(cAliasCL0)->(EOF())
	CL0->(dbGoto((cAliasCL0)->NRECNO))		
	RecLock("CL0",.F.)
	CL0->(dbDelete())
	MsUnLock()
	CL0->(FKCommit())
	(cAliasCL0)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCL0)
(cAliasCL0)->(DbCloseArea ())

Return


Static Function ALIASREPRO(cOpcao)

Local aAlias	:= {}
Local cDifApur	:= GetNewPar("MV_DIFPC01",'1')

IF cOpcao == '1'
	//Reprocessamento
	AAdd(aAlias,{'CKR',.T.	 })//apaga
	AAdd(aAlias,{'CL1',.T.    })//apaga	
	If AliasINdic('F07')
		AAdd(aAlias,{'F07',.T.    })//apaga
	EndIF
	AAdd(aAlias,{'CL2',.T.    })//apaga
	AAdd(aAlias,{'CL3',.T.    })//apaga
	AAdd(aAlias,{'CL5',.T.    })//apaga	
	AAdd(aAlias,{'CL6',.T.    })//apaga
	AAdd(aAlias,{'CL7',.T.    })//apaga
	AAdd(aAlias,{'CKY',.T.    })//apaga
	If AliasINdic('F0T')
		AAdd(aAlias,{'F0T',.T. })//apaga
	EndIF	
	IF ISA001NDIF()
		AAdd(aAlias,{'CFA',.T.    })//apaga
		AAdd(aAlias,{'CFB',.T.    })//apaga
	EndIf
	
ElseIF cOpcao == '2'
	//Primeiro processamento
	AAdd(aAlias,{'CL8',.T.})//reprocessa    C
	AAdd(aAlias,{'CL9',.T.})//reprocessa    c
	AAdd(aAlias,{'CKR',.T.	 })//apaga      c
	AAdd(aAlias,{'CKS',.T.})//reprocessa	  c
	AAdd(aAlias,{'CKT',.T.})//reprocessa    c
	AAdd(aAlias,{'CKU',.T.})//reprocessa    c
	AAdd(aAlias,{'CKV',.T.})//reprocessa    c
	AAdd(aAlias,{'CKW',.T.})//reprocessa    c
	AAdd(aAlias,{'CKX',.T.})//reprocessa
	AAdd(aAlias,{'CKZ',.T.})//reprocessa    c
	AAdd(aAlias,{'CL0',.T.})//reprocessa    c
	AAdd(aAlias,{'CL1',.T. })//apaga
	If AliasINdic('F07')
		AAdd(aAlias,{'F07',.T. })//apaga
	EndIF
	If AliasINdic('F0T')
		AAdd(aAlias,{'F0T',.T. })//apaga
	EndIF
	AAdd(aAlias,{'CL2',.T.})//reprocessa
	AAdd(aAlias,{'CL3',.T. })//apaga        c
	AAdd(aAlias,{'CL4',.T.})//reprocessa
	AAdd(aAlias,{'CL5',.T. })//apaga	
	AAdd(aAlias,{'CL6',.T. })//apaga
	AAdd(aAlias,{'CL7',.T. })//apaga
	AAdd(aAlias,{'CKY',.T. })//apaga

	IF ISA001NDIF()
		AAdd(aAlias,{'CFA',.T.    })//apaga
		AAdd(aAlias,{'CFB',.T.    })//apaga
	EndIF
	

ElseIF cOpcao == '3' //Exclusão da apuração agrupada

	AAdd(aAlias,{'CL8',.T.})//reprocessa    C
	AAdd(aAlias,{'CL9',.T.})//reprocessa    c
	AAdd(aAlias,{'CKR',.T. })//apaga        c
	AAdd(aAlias,{'CKS',.T.})//reprocessa	  c
	AAdd(aAlias,{'CKT',.T.})//reprocessa    c
	AAdd(aAlias,{'CKU',.T.})//reprocessa    c
	AAdd(aAlias,{'CKV',.T.})//reprocessa    c
	AAdd(aAlias,{'CKW',.T.})//reprocessa    c	
	AAdd(aAlias,{'CKZ',.T.})//reprocessa    c
	AAdd(aAlias,{'CL0',.T.})//reprocessa    c	
	AAdd(aAlias,{'CL3',.T. })//apaga        c
	IF ISA001NDIF()
		AAdd(aAlias,{'CFA',.T.    })//apaga
		AAdd(aAlias,{'CFB',.T.    })//apaga
	EndiF	

EndIF	

Return aAlias



Static Function ISA001PERG()

Local mvpar01	:= MV_par01
Local mvpar02	:= MV_par02
Local mvpar03	:= MV_par03
Local mvpar04	:= MV_par04
Local mvpar05	:= MV_par05
Local mvpar06	:= MV_par06
Local mvpar07	:= MV_par07
Local mvpar08	:= MV_par08
Local mvpar09	:= MV_par09
Local mvpar10	:= MV_par10
Local mvpar11	:= MV_par11
Local mvpar12	:= MV_par12
Local mvpar13	:= MV_par13
Local mvpar14	:= MV_par14
Local mvpar15	:= MV_par15

Local aRet	:= {}

If Pergunte ('ISA003',.T.,'Selecione opções que deseja reprocessar')

	aAdd(aRet,MV_par01) //NF ENTRADA
	aAdd(aRet,MV_par02) //NF SAÍDA
	aAdd(aRet,MV_par03) //TITULO ENTRADA
	aAdd(aRet,MV_par04) //TITULO SAÍDA
	aAdd(aRet,MV_par05) //ATIVO FIXO
	aAdd(aRet,MV_par06) //CUPOM FISCALK
	aAdd(aRet,MV_par07) //CPRB			
EndIF

MV_PAR01 := mvpar01
MV_PAR02 := mvpar02
MV_PAR03 := mvpar03
MV_PAR04 := mvpar04
MV_PAR05 := mvpar05
MV_PAR06 := mvpar06
MV_PAR07 := mvpar07
MV_PAR08 := mvpar08
MV_PAR09 := mvpar09
MV_PAR10 := mvpar10
MV_PAR11 := mvpar11
MV_PAR12 := mvpar12
MV_PAR13 := mvpar13
MV_PAR14 := mvpar14
MV_PAR15 := mvpar15	

Return aRet

Static Function ZeraCKS(dDataDe,dDataAte,cConsl,oEFDGen)

Local cAliasCKU	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''

cCampos	:= '%CKS.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CKS.CKS_FILIAL= '"+ oEFDGen:BuscaxFil('CKS')+ "' AND "
cFiltro += "CKS.CKS_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CKS.CKS_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += "CKS.CKS_CONSOL = '" +cConsl + "' AND "

cFiltro += "%"
cAliasCKS	:=	GetNextAlias()

BeginSql Alias cAliasCKS
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CKS% CKS	
	WHERE
	%Exp:cFiltro%
	CKS.%NotDel%

EndSql

Do While !(cAliasCKS)->(EOF())
	CKS->(dbGoto((cAliasCKS)->NRECNO))		
	RecLock("CKS",.F.)
	CKS->CKS_AJAC 		:= 0
	CKS->CKS_AJRD 		:= 0
	CKS->CKS_DIF 		:= 0	
	CKS->CKS_DIFANT 	:= 0	
	CKS->CKS_VLDISP 	:=CKS->CKS_VLTRIB	
	
	MsUnLock()
	CKS->(FKCommit())
	(cAliasCKS)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCKS)
(cAliasCKS)->(DbCloseArea ())

Return



Static Function ZeraCL8(dDataDe,dDataAte,cConsl,oEFDGen)

Local cAliasCKU	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''

cCampos	:= '%CL8.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CL8.CL8_FILIAL= '"+ oEFDGen:BuscaxFil('CL8')+ "' AND "
cFiltro += "CL8.CL8_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "CL8.CL8_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += "CL8.CL8_CONSOL = '" +cConsl + "' AND "

cFiltro += "%"
cAliasCL8	:=	GetNextAlias()

BeginSql Alias cAliasCL8
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:CL8% CL8	
	WHERE
	%Exp:cFiltro%
	CL8.%NotDel%

EndSql

Do While !(cAliasCL8)->(EOF())
	CL8->(dbGoto((cAliasCL8)->NRECNO))		
	RecLock("CL8",.F.)
	CL8->CL8_AJAC 		:= 0
	CL8->CL8_AJRD 		:= 0
	CL8->CL8_DIF 		:= 0	
	CL8->CL8_TOTCRD 	:= 0	
	CL8->CL8_CRDUTI 	:= CL8->CL8_VLCRED	
	CL8->CL8_CRDFUT 	:= 0	
	
	MsUnLock()
	CL8->(FKCommit())
	(cAliasCL8)->(DBSKIP())
EndDo		


DbSelectArea (cAliasCL8)
(cAliasCL8)->(DbCloseArea ())

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} IniThread
 
Função que irá iniciar as Threads para processamento.

@author Erick G. Dias
@return aThread,Array,Retorna os nomes de todas as Threads iniciadas.
@since 11/08/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function IniThread(aReprocess,aFil,aPergunta,aDiaThread,nLimite)

Local aThread		:= {} //Array com os nomes das Threads Iniciadas
Local nCont		:= 0
Local cNomeJob	:= ''

If nLimite >= Len(aDiaThread)
	nLimite	:=  Len(aDiaThread)-1
EndIF

//Chama função para guardar as informações de parâmetros da pergunta inicial da rotina.
//Deverá passar array com as perguntas para função ProcEFD
For nCont := 1 to nLimite 	
	aPergunta[1] :=aDiaThread[nCont+1][1]
	aPergunta[2] :=aDiaThread[nCont+1][2]
		
	// Cada Thread terá uma identificação
	cNomeJob	:=	"FISA001"+ strZERO(nCont+1,2) 
	PutGlbValue( cNomeJob , "0" )
	GlbUnLock()
	
	// Adiciona o nome do arquivo de Job no array aJobAux
	aAdd( aThread ,{ cNomeJob } )
	StartJob('PreProcEFD',GetEnvServer(),.F.,cEmpAnt,cFilAnt,cNomeJob,aReprocess,aPergunta,aFil,.F.)
Next nCont

Return aThread

//-------------------------------------------------------------------
/*/{Protheus.doc} PreProcEFD
 
Função que será chamada quando iniciar uma nova Thread. 

@author Erick G. Dias
@since 11/08/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Function PreProcEFD(cEmp,cFil,cNomeJob,aReprocess,aParSX1,aFil)

Local cError		:= ''
Local lErro		:= .F.
Local bError      := { |e| oError := e , Break(e) }
Local bErrorBlock := ErrorBlock( bError )
Local oError
Local n := 0
Local lEnd	:= .F.
Local oProcess 

PutGlbValue( cNomeJob , "0" ) //Iniciou
GlbUnLock()

//ABRE NOVO AMBIENTE

RpcSetType(3)
RpcSetEnv(cEmp,cFil)

BEGIN SEQUENCE
	//TRY
	//EXECUTA FUNÇÃO DO SPED
	
	ProcEFD(,aReprocess,aParSX1,aFil,.F.,,cNomeJob)
  
  	//CATCH e as IdxException
		//ConOut( ProcName() + " " + Str(ProcLine()) + " Erro na geração no processamento - " +SM0->M0_CODFIL+" / "+AllTrim(SM0->M0_FILIAL) + " - "   + oError:Description )
  	//END TRY
RECOVER

lErro	:= .T. 

END SEQUENCE 
ErrorBlock( bErrorBlock )

IF lErro
	PutGlbValue( cNomeJob , '2' )//Ocorreu algum erro
	ConOut(" Erro na geração no processamento - " +SM0->M0_CODFIL+" / "+AllTrim(SM0->M0_FILIAL) + " - "   + oError:Description )
	ProcLogAtu("ERRO",oError:Description +"- Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)	
Else
	PutGlbValue( cNomeJob , '1' )//Finalizado sem erro
EndIF
GlbUnLock()
//Somente fecha ambiente se não houve nenhum erro.
RpcClearEnv()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GuardaPerg
 
Função que guarda as informações do parâmetro em array 

@return array com informações da pergunta MV_PARXX
@author Erick G. Dias
@since 11/08/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function GuardaPerg()

Local aRet	:= {}

aAdd(aRet,MV_PAR01) 
aAdd(aRet,MV_PAR02)
aAdd(aRet,MV_PAR03)
aAdd(aRet,MV_PAR04)
aAdd(aRet,MV_PAR05)
aAdd(aRet,MV_PAR06)
aAdd(aRet,MV_PAR07)
aAdd(aRet,MV_PAR08)
aAdd(aRet,MV_PAR09)
aAdd(aRet,MV_PAR10)
aAdd(aRet,MV_PAR11)
aAdd(aRet,MV_PAR12)
aAdd(aRet,MV_PAR13)
aAdd(aRet,MV_PAR14)
aAdd(aRet,MV_PAR15)
aAdd(aRet,MV_PAR16)
aAdd(aRet,MV_PAR17)
aAdd(aRet,MV_PAR18)

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} GetFilial
 
Esta função retorna um array com as filiais selecionadas pelo
usuário através da MatFilCacl. 

@return array com informações da pergunta MV_PARXX
@author Erick G. Dias
@since 11/08/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function GetFilial()

Local aFil	:= {}
Local aSM0	:= {}
Local aAreaSM0	:= {}
Local nFil	:= 0

If MV_PAR04 == 1
	//chama função para usuário escolher filial
	aFil:= MatFilCalc( .T. )
	If len(aFil) ==0
			MsgAlert('Nenhuma filial foi selecionada, o processamento não será realizado.')
	EndiF	
EndIF

If MV_PAR15 == 1 .AND. Len(aFil) > 0
	nFil	:= Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
	
	If nFil > 0 .AND. !aFil[nFil,1]
		MsgAlert('Apuração no modo agrupado necessita ter a filial logada no processamento. A filial logada não foi selecionada porém será considerada automaticamente no processamento')
		aFil[nFil,1]:= .T.			
	EndIF	
EndIF


IF MV_PAR04 <> 1  
	//Adiciona filial logada para realizar o processamento
	AADD(aFil,{.T.,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_CGC})
EndIF
IF  Len(aFil) > 0

	aAreaSM0 := SM0->(GetArea())
	DbSelectArea("SM0")
	//--------------------------------------------------------
	//Irá preencher aSM0 somente com as filiais selecionadas
	//pelo cliente  
	//--------------------------------------------------------
	
	SM0->(DbGoTop())
	If SM0->(MsSeek(cEmpAnt))
		Do While !SM0->(Eof()) 
			nFil := Ascan(aFil,{|x|AllTrim(x[2])==Alltrim(SM0->M0_CODFIL) .And. x[4] == SM0->M0_CGC})
			If nFil > 0 .And. aFil[nFil][1] .AND. cEmpAnt == SM0->M0_CODIGO
				Aadd(aSM0,{SM0->M0_CODIGO,SM0->M0_CODFIL,SM0->M0_FILIAL,SM0->M0_NOME,SM0->M0_CGC})
			EndIf
			SM0->(dbSkip())
		Enddo
	EndIf
	
	SM0->(RestArea(aAreaSM0))
EndIF

Return  aSM0


Static Function ThreadOK(oProcess,aThread)
Local nX	:= 0
Local lErro	:= .F.
oProcess:Set1Progress(len(aThread))

For nX := 1 to Len(aThread)
	oProcess:Inc1Progress('Finalizando Thread ' + Str(nX,2))					
	While .T.

		IF GetGlbValue( aThread[nX][1] ) == '0' 
			
		ElseIF GetGlbValue( aThread[nX][1] ) == '1'
			
			Exit
		ElseIF GetGlbValue( aThread[nX][1] ) == '2'
			lErro	:= .T.
			Exit
		EndIF
		
		Sleep(3000)
	EndDo

Next nX	

IF lErro
	Alert("Threads finalizadas. Verifique o log para verificação de erro(s)!")
Else
	MsgInfo("Threads Finalizadas com Sucesso!")
EndIF
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} A001DIATHR
 
Função que irá fazer divisão dos dias para cada Thread, considendo
período passado e número de Threads passada.   

@return array com data inicial e final que cada Thread deverá processar.
@author Erick G. Dias
@since 12/08/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001DIATHR(nThread,dtIni, dtFin)
Local nRestoDia	:= 0
Local nCont		:= 0
Local nDiasThread	:= 0
Local nDiaAux		:= 0
Local nTotDias	:=(dtFin - dtIni) + 1
Local dtI			:= dtIni			
Local dtF			:= dtIni
Local aPer			:= {}

//VERIFICA SE NÚMERO DE THREAD É MENOR QUE O NÚMERO DE DIAS
If nThread > 6
	nThread	:= 6
EndIF

If nThread <= nTotDias  
	
	For nCont := 1 to nTotDias
		If mod(nTotDias,nThread) == 0
			//Divisão exata
			nDiasThread	:= nTotDias/nThread
			exit		
		Else
			nRestoDia++
			nTotDias -=1					
		EndIF
	
	Next nCont
	
Else
	//O NÚMERO DE THREAD SERÁ O MESMO QUE A QUANTIDADE DE DIA.
	nThread := nTotDias
	nDiasThread	:= 1
EndIF

For nCont := 1 to nThread
	
	nDiaAux := 0
	If nRestoDia > 0
		nDiaAux := 1
		nRestoDia -= 1		
	EndIF
	dtI	:= dtI
	dtF	:= dtI + (nDiasThread-1) + nDiaAux	

	AADD(aPer,{dtI,dtF})
	dtI	:=  dtF + 1
	
Next nCont

Return aPer

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AgrupaThr
 
Função que irá agrupar as informações processadas separadamente pelas Threads
em uma única apuração.
@param dDtIni - Data inicial que as informações deverão ser buscadas
@param dDtFin - Data final que as informações deverão ser buscadas
@param dtGrava - Data que as informações deverão ser agrupadas.
@param cConsl - Indica se apuração é agrupada ou não
@param cTab - Tabela que deverá ser agrupada.

@author Erick G. Dias
@since 13/08/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function AgrupaThr(dDtIni, dDtFin, dtGrava,cConsl, cTab)

Local cAlias		:= ''
Local cFrom		:= ''
Local cSlct		:= ''
local cFiltro		:= ''
Local aQry			:= {}
Local aXFilial	:= ASA001AFIL()
Local oEFDGen		:= EFDGEN():New()

oEFDGen:SetFilial(aXFilial)
//CHAMA FUNÇÃO QUE RETORNA STRING DA QUERY REFERENTE A TABELA PROCESSADA
aQry	:= QryAgrupa(cTab,dDtIni,dDtFin,cConsl,oEFDGen)

cSlct		:= aQry[1][1]
cFrom		:= aQry[1][2]
cFiltro	:= aQry[1][3]

cAlias	:=	GetNextAlias()
BeginSql Alias cAlias
    	
	SELECT
		%Exp:cSlct%

	FROM
		%Exp:cFrom%
	WHERE
		%Exp:cFiltro%
	
EndSql

Do case
	Case cTab == 'CKZ'
		ConsCKZ(cAlias,aXFilial,.T.,dtGrava)
	Case ctab == 'CKS'
		ConsCKS(cAlias,aXFilial,.T.,dtGrava)		
	Case ctab == 'CL8'
		ConsCL8(cAlias,aXFilial,.T.,dtGrava)
	Case ctab == 'CL9'
		ConsCL9(cAlias,aXFilial,.T.,dtGrava)		
	Case ctab == 'CLA'
		ConsCLA(cAlias,aXFilial,.T.,dtGrava)			
	Case ctab == 'CKR'
		ConsCKR(cAlias,aXFilial,.T.,dtGrava)
	Case ctab == 'CKT'
		ConsCKT(cAlias,aXFilial,.T.,dtGrava)		
	Case ctab == 'CKU'
		ConsCKU(cAlias,aXFilial,.T.,dtGrava)		
	Case ctab == 'CL0'
		ConsCL0(cAlias,aXFilial,.T.,dtGrava)		
	Case ctab == 'CL3'
		ConsCL3(cAlias,aXFilial,.T.,dtGrava)		
EndCase

(cAlias)->(DbGoTop ())
Do While !(cAlias)->(Eof ())
	
	(cTab)->(dbGoto((cAlias)->R_E_C_N_O_))	
	RecLock(cTab,.F.)
	(cTab)->(dbDelete())
	MsUnLock()
	(cTab)->(FKCommit())
	(cAlias)->(DbSkip())
	
Enddo
	
DbSelectArea (cAlias)
(cAlias)->(DbCloseArea())

Return


Static Function QryAgrupa(cAlias,dDtIni,dDtFin,cConsl,oEFDGen)

Local aRet			:= {}
Local cSlct		:= ''
Local cFiltro 	:= ''
Local cFrom	 	:= ''

Do case
	Case cAlias == 'CKZ'

		cSlct	 := "%CKZ.*%"	
		cFrom	   := '%'+ RetSqlName('CKZ')+' CKZ %
		cFiltro += "%CKZ.CKZ_FILIAL= '"+ oEFDGen:BuscaxFil('CKZ') + "' AND "
		cFiltro += "CKZ.CKZ_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CKZ.CKZ_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "CKZ.CKZ_CONSOL = '" +cConsl + "' AND "
		cFiltro += "CKZ.D_E_L_E_T_=' ' "	
		cFiltro += "%"
	Case cAlias == 'CKS'

		cSlct	 := "%CKS.*%"	
		cFrom	   := '%'+ RetSqlName('CKS')+' CKS %
		cFiltro += "%CKS.CKS_FILIAL= '"+ oEFDGen:BuscaxFil('CKS') + "' AND "
		cFiltro += "CKS.CKS_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CKS.CKS_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "CKS.CKS_CONSOL = '" +cConsl + "' AND "
		cFiltro += "CKS.D_E_L_E_T_=' ' "	
		cFiltro += "%"

	Case cAlias == 'CL8'

		cSlct	 := "%CL8.*%"	
		cFrom	   := '%'+ RetSqlName('CL8')+' CL8 %
		cFiltro += "%CL8.CL8_FILIAL= '"+ oEFDGen:BuscaxFil('CL8') + "' AND "
		cFiltro += "CL8.CL8_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CL8.CL8_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "CL8.CL8_CONSOL = '" +cConsl + "' AND "
		cFiltro += "CL8.D_E_L_E_T_=' ' "	
		cFiltro += "%"

	Case cAlias == 'CL9'	

		cSlct	 := "%CL9.*%"	
		cFrom	   := '%'+ RetSqlName('CL9')+' CL9 %
		cFiltro += "%CL9.CL9_FILIAL= '"+ oEFDGen:BuscaxFil('CL9') + "' AND "
		cFiltro += "CL9.CL9_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CL9.CL9_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "CL9.CL9_CONSOL = '" +cConsl + "' AND "
		cFiltro += "CL9.D_E_L_E_T_=' ' "	
		cFiltro += "%"

	Case cAlias == 'CLA'
		cSlct	 := "%CLA.*%"	
		cFrom	   := '%'+ RetSqlName('CLA')+' CLA %
		cFiltro += "%CLA.CLA_FILIAL= '"+ oEFDGen:BuscaxFil('CLA') + "' AND "
		cFiltro += "CLA.CLA_DTREF>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CLA.CLA_DTREF<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "CLA.CLA_CONSOL = '" +cConsl + "' AND "
		cFiltro += "CLA.D_E_L_E_T_=' ' "	
		cFiltro += "%"
	Case cAlias == 'CKR'
		cSlct	 := "%CKR.*%"	
		cFrom	   := '%'+ RetSqlName('CKR')+' CKR %
		cFiltro += "%CKR.CKR_FILIAL= '"+ oEFDGen:BuscaxFil('CKR') + "' AND "
		cFiltro += "CKR.CKR_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CKR.CKR_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "CKR.CKR_CONSOL = '" +cConsl + "' AND "
		cFiltro += "CKR.D_E_L_E_T_=' ' "	
		cFiltro += "%"	
	
	Case cAlias == 'CKT'
		cSlct	 := "%CKT.*%"	
		cFrom	   := '%'+ RetSqlName('CKT')+' CKT %
		cFiltro += "%CKT.CKT_FILIAL= '"+ oEFDGen:BuscaxFil('CKT') + "' AND "
		cFiltro += "CKT.CKT_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CKT.CKT_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "CKT.CKT_CONSOL = '" +cConsl + "' AND "
		cFiltro += "CKT.D_E_L_E_T_=' ' "	
		cFiltro += "%"	

	
	Case cAlias == 'CKU'
	
		cSlct	 := "%CKU.*%"	
		cFrom	   := '%'+ RetSqlName('CKU')+' CKU %
		cFiltro += "%CKU.CKU_FILIAL= '"+ oEFDGen:BuscaxFil('CKU') + "' AND "
		cFiltro += "CKU.CKU_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CKU.CKU_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "CKU.CKU_CONSOL = '" +cConsl + "' AND "
		cFiltro += "CKU.D_E_L_E_T_=' ' "	
		cFiltro += "%"		
	
	Case cAlias == 'CL0'

		cSlct	 := "%CL0.*%"	
		cFrom	   := '%'+ RetSqlName('CL0')+' CL0 %
		cFiltro += "%CL0.CL0_FILIAL= '"+ oEFDGen:BuscaxFil('CL0') + "' AND "
		cFiltro += "CL0.CL0_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CL0.CL0_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "CL0.CL0_CONSOL = '" +cConsl + "' AND "
		cFiltro += "CL0.D_E_L_E_T_=' ' "	
		cFiltro += "%"		

	
	Case cAlias == 'CL3'	
		cSlct	 := "%CL3.*%"	
		cFrom	   := '%'+ RetSqlName('CL3')+' CL3 %
		cFiltro += "%CL3.CL3_FILIAL= '"+ oEFDGen:BuscaxFil('CL3') + "' AND "
		cFiltro += "CL3.CL3_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CL3.CL3_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "CL3.CL3_CONSOL = '" +cConsl + "' AND "
		cFiltro += "CL3.D_E_L_E_T_=' ' "	
		cFiltro += "%"			
	
	
EndCase

AADD(aRet,{cSlct,cFrom,cFiltro})

Return aRet

//-------------------------------------------------------------------
/*/{Protheus.doc} IniCred
 
Função que irá inicializar/zerar os valores de créditos

@author Erick G. Dias
@since 04/09/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function IniCred(aParSX1,aXFilial)

local oSaldoCred

oSaldoCred:= SALDOCRED():New()
oSaldoCred:SetFilial(aXFilial)
oSaldoCred:SetTributo(PIS)
oSaldoCred:SetPer(Strzero(Month(aParSX1[1]),2)+cvaltochar(Year(aParSX1[1])))
oSaldoCred:LimpaSaldo() //Limpa tabela de saldos somente do período

oSaldoCred:SetTributo(COFINS)
oSaldoCred:LimpaSaldo() //Limpa tabela de saldos somente do período
FreeObj(oSaldoCred)
oSaldoCred:= Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IniDeducao
 
Função que irá inicializar/zerar os valores de dedução

@author Erick G. Dias
@since 04/09/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function IniDeducao(aParSX1,aXFilial)

Local dUltDia		:= LastDay (aParSX1[1]) + 1
Local cProxPer	:=	cvaltochar(strzero(month(dUltDia ) ,2)) + cvaltochar(year(dUltDia ))
Local oSaldoDed
oSaldoDed	:= 	SALDODED():New()
oSaldoDed:SetFilial(aXFilial)
oSaldoDed:LimpaSaldo(cProxPer)
FreeObj(oSaldoDed)
oSaldoDed	:= Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IniRetenca
 
Função que irá inicializar/zerar os valores de retenções

@author Erick G. Dias
@since 04/09/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function IniRetenca(aParSX1,aXFilial)

oOutRet := DEDUCAOPC():New() 
oOutRet:SetFilial(aXFilial)
oOutRet:SetPergrva(Strzero(Month(aParSX1[1]),2)+cvaltochar(Year(aParSX1[1])))
oOutRet:SetTributo(PIS)
oOutRet:LimpaSaldo()
oOutRet:SetTributo(COFINS)
oOutRet:LimpaSaldo()
FreeObj( oOutRet ) 
oOutRet:= Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IniTabApur
 
Função que irá inicializar/zerar as tabelas da apuração

@author Erick G. Dias
@since 04/09/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function IniTabApur (aParSX1,aXFilial,lTabAux,lReproc,lTabCPRB)

Local oApurSai

default lTabCPRB := .f.

oApurSai := FISX001():New()
oApurSai:SetFilial(aXFilial)
oApurSai:SetDtIni(aParSX1[1])
oApurSai:SetDtFin(aParSX1[2])
oApurSai:SetLivro(aParSX1[3])
oApurSai:SetRegApur(Str(aParSX1[6],1))

if !lTabCPRB
	oApurSai:ClearTab(TabApur(lReproc))
else 
	oApurSai:ClearTab(TabCPRB())
endif

If lTabAux
	oApurSai:ClearTab(TabAux())
EndIF
	
oApurSai	:= Nil

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} TabApur
 
Função que irá retornar os alias das tabelas da apuração.

@author Erick G. Dias
@since 04/09/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function TabApur(lReproc)

Local aAlias	:= {}


If lReproc
	AAdd(aAlias,{'CKR',.T.})
	AAdd(aAlias,{'CL3',.T.})
	IF ISA001NDIF()
		AAdd(aAlias,{'CFA',.T.})
		AAdd(aAlias,{'CFB',.T.})
	EndIF
Else
	AAdd(aAlias,{'CKR',.T.})
	AAdd(aAlias,{'CL3',.T.})	
	AAdd(aAlias,{'CL8',.T.})
	AAdd(aAlias,{'CL9',.T.})
	AAdd(aAlias,{'CKS',.T.})	
	AAdd(aAlias,{'CKT',.T.})
	AAdd(aAlias,{'CKU',.T.})
	AAdd(aAlias,{'CKV',.T.})
	AAdd(aAlias,{'CKW',.T.})
	AAdd(aAlias,{'CKX',.T.})
	AAdd(aAlias,{'CKZ',.T.})
	AAdd(aAlias,{'CL0',.T.})
	AAdd(aAlias,{'CL4',.T.})
	IF ISA001NDIF()
		AAdd(aAlias,{'CFA',.T.})
		AAdd(aAlias,{'CFB',.T.})
	EndIF
	//AAdd(aAlias,{'CLA',.T.})

EndIF
	

Return aAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} TabAux
 
Função que irá retornar os alias das tabelas auxiliares.

@author Erick G. Dias
@since 04/09/2014
@version 11.80
/*/
//-------------------------------------------------------------------

Static Function TabAux()

Local aAlias	:= {}

If AliasINdic('F07')
	AAdd(aAlias,{'F07',.T.})
EndIF
If AliasINdic('F0T')
	AAdd(aAlias,{'F0T',.T. })//apaga
EndIF	
AAdd(aAlias,{'CL1',.T.})
AAdd(aAlias,{'CL2',.T.})
AAdd(aAlias,{'CL3',.T.})
AAdd(aAlias,{'CL5',.T.})
AAdd(aAlias,{'CL6',.T.})
AAdd(aAlias,{'CL7',.T.})
AAdd(aAlias,{'CKY',.T.})
AAdd(aAlias,{'CKX',.T.})

If ISA001NDIF()
	AAdd(aAlias,{'CFA',.T.    })//apaga
	AAdd(aAlias,{'CFB',.T.    })//apaga
EndIF

Return aAlias

//-------------------------------------------------------------------
/*/{Protheus.doc} TabCPRB
 
Função que irá retornar os alias das tabelas CPRB.

@author Simone Oliveira
@since 29/04/2016
@version 11.80
/*/
//-------------------------------------------------------------------

static function TabCPRB()

local aAlias	:= {}

aadd(aAlias,{'CKV',.T.})
aadd(aAlias,{'CKW',.T.})
aadd(aAlias,{'CKX',.T.})

return aAlias


Static Function DesfazCon()

Local nFil	:= 0
Local aFil:= MatFilCalc( .F. )
Local aAreaSM0 := SM0->(GetArea())

SM0->(DbGoTop ())
For nFil := 1 to Len(aFil)

	SM0->(MsSeek (FWGrpCompany()+aFil[nFil][2], .T.))	//Pego a filial mais proxima
	cFilAnt := FWGETCODFILIAL	
	
	IF CKR->(MSSEEK( xFilial('CKR')+dTos(MV_PAR01)+'2'+'1')) //PIS
		RecLock('CKR',.F.)
		CKR->CKR_STATUS = '1' // Volta Status para normal
		MsUnLock()		
	EndIF
	
	If CKR->(MSSEEK( xFilial('CKR')+dTos(MV_PAR01)+'2'+'2')) //COFINS 
		RecLock('CKR',.F.)
		CKR->CKR_STATUS = '1' // Volta Status para normal
		MsUnLock()		
	EndIF	
	
	
Next nFil

RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

Return



//-------------------------------------------------------------------
/*/{Protheus.doc} FSA001CLG
 
@description Função que irá buscar os lançamentos na tabela CLG referente
				registro F600 incluídos manualmente, e irá considerar na geração
				da retenção. Esta situação se deve ao motivo de existirem retenções
				de operações de consórcios, onde não existe documento fiscal
				e nem título, desta maneira a receita é incluída na rodina FISA048,
				porém estas receitas estão sujeitas a retenção, que por suas vez
				são inerídas na rotina FISA006.

@param dDtIni,Date,Data Inicial do processamento
@param dDtFin,Date,Data final do processamento

@author Erick G. Dias
@since 04/09/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function FSA001CLG(dDtIni, dDtFin)

Local cSlct		:= ''
Local cAliasCLG	:= GetNextAlias()
Local cGroup		:= ''
Local cRegime		:= ''
Local oF600		

If AliasIndic('CLG') .AND.  CLG->(ColumnPos( 'CLG_NATRET' ))
	oF600		:=	TABELACKY():New() 
	DbSelectArea ('CLG')
	
	cSlct :='%'
	cSlct += 'CLG.CLG_FILIAL, CLG.CLG_DTRET, CLG.CLG_NATRET, CLG.CLG_CODREC, CLG.CLG_REGIME, CLG.CLG_CNPJ, CLG.CLG_INDRET,'
	cSlct += 'SUM(CLG.CLG_BSRET) AS CLG_BSRET, SUM(CLG.CLG_VLTOTR) AS CLG_VLTOTR, SUM(CLG.CLG_PISRET) AS CLG_PISRET,'
	cSlct += 'SUM(CLG.CLG_COFRET) AS CLG_COFRET'
	cSlct +='%'
	   
	cGroup := '%group by CLG_FILIAL,CLG_DTRET,CLG_NATRET,CLG_CODREC,CLG_REGIME,CLG_CNPJ,CLG_INDRET%'
	   	
	BeginSql Alias cAliasCLG
		COLUMN CLG_DTRET AS DATE
		
		SELECT			    
			%Exp:cSlct%
		FROM 
			%Table:CLG% CLG
		WHERE
			CLG.CLG_FILIAL=%xFilial:CLG% AND
			CLG.CLG_DTRET>=%Exp:DToS (dDtIni)% AND
			CLG.CLG_DTRET<=%Exp:DToS (dDtFin)% AND
			CLG.%NotDel%	
		%Exp:cGroup%
	EndSql
	
	DbSelectArea (cAliasCLG)
	(cAliasCLG)->(DbGoTop ())
	Do While !(cAliasCLG)->(Eof ())	
	 
		cRegime :=""
		If (cAliasCLG)->CLG_REGIME == "0"
			cRegime := '2' //cumulativo
		ElseIf (cAliasCLG)->CLG_REGIME == "1"
			cRegime := '1' //nao cumulativo
		EndIF	
		oF600:SetParam('CKY_PER',dDtIni)
		oF600:SetParam('CKY_INDRET',(cAliasCLG)->CLG_NATRET)
		oF600:SetParam('CKY_DTRET',(cAliasCLG)->CLG_DTRET)
		oF600:SetParam('CKY_CODREC',(cAliasCLG)->CLG_CODREC)
		oF600:SetParam('CKY_INDREC',cRegime) 				
		oF600:SetParam('CKY_CNPJ',(cAliasCLG)->CLG_CNPJ)		
		oF600:SetParam('CKY_BASE',(cAliasCLG)->CLG_BSRET)		
		oF600:SetParam('CKY_TOTRET',(cAliasCLG)->CLG_VLTOTR)	
		oF600:SetParam('CKY_PISRET',(cAliasCLG)->CLG_PISRET)	
		oF600:SetParam('CKY_COFRET',(cAliasCLG)->CLG_COFRET)	
		oF600:SetParam('CKY_INDCON',(cAliasCLG)->CLG_INDRET)	
		If CKY->(COLUMNPOS("CKY_FILAPU")) > 0
			oF600:SetParam('CKY_FILAPU',(cAliasCLG)->CLG_FILIAL)  
		Endif		
		oF600:Save()		
	 
		(cAliasCLG)->(DbSkip ())			
	EndDo
	
	oF600:FechaAlias(cAliasCLG)
EndIF
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA001CPRB
 
Função que irá realizar o reprocessamento da EFD, conforme opções
selecionadas pelo usuário na tela inicial da apuração.
 
@author Mauro A. Gonçalves
@since 27/08/2015
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function FSA001CPRB(dDataDe,dDataAte)
Local cAliasCF5	:= ''
Local cSelect		:= ''
Local cWhere		:= ''
Local aReg			:= {}
Local lTIPATV		:= CF5->(ColumnPos("CF5_TIPATV"))

cAliasCF5	:=	GetNextAlias()
cSelect :=	"%CF5.*%"
cWhere	:=	"%CF5.CF5_FILIAL='"+xFilial("CF5")+"' AND "
cWhere	+=	"CF5.CF5_DTREF>='"+DTOS(dDataDe)+"' AND "
cWhere	+=	"CF5.CF5_DTREF<='"+DTOS(dDataAte)+"' AND "
cWhere	+=	"CF5.CF5_PISCOF='2' AND %"

BeginSql Alias cAliasCF5    	
    COLUMN CF5_DTREF AS DATE	
	SELECT			    	 
		%Exp:cSelect%
	FROM 
		%Table:CF5% CF5													
	WHERE
		%Exp:cWhere%
		CF5.%NotDel%	
EndSql

Do While !(cAliasCF5)->(Eof ())
	aAdd(aReg,{(cAliasCF5)->CF5_INDAJU,;
			    (cAliasCF5)->CF5_VALAJU,;
			    (cAliasCF5)->CF5_CODAJU,;
			    (cAliasCF5)->CF5_NUMDOC,;
			    (cAliasCF5)->CF5_DESAJU,;
			    STRTRAN(DTOC((cAliasCF5)->CF5_DTREF),"/",""),;
				 IIf(lTIPATV,IIf((cAliasCF5)->CF5_TIPATV=="0",mv_par16,mv_par17),"")})
	(cAliasCF5)->(DbSkip())			
EndDo
dbSelectArea(cAliasCF5)

Return aReg


//-------------------------------------------------------------------
/*/{Protheus.doc} F100Presu
 
Função que irá processar o cálculo do crédito presumido conforme lei 12.058/2009
para escrituração do F100
 
@author Henrique Pereira
@since 27/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------

Static Function F100Presu(dDataDe,dDataAte,cNrLivro,oApurEnt,nTotF100)
Local nX         := 0
Local oF100	   :=	TABELACL2():New() //Cria objeto para gravação do F100
Local aTotSai    := {}
Local aTotEnt    := {}
Local aCrePresu  := {}
Local cCstPres   := GetNewPar("MV_CSTPRES","62")

aTotSai   := F100PreTSai(dDataDe,dDataAte,cNrLivro)
aTotEnt   := F100PreTEnt(dDataDe,dDataAte,cNrLivro)

         
         For nX := 1 to Len(aTotEnt)
          If !Empty(aTotEnt[nX,3])
             aCrePresu := F100CrePreG(aTotSai,aTotEnt,dDataAte, nX)  		
			
              lGravaF100	:= .T.
				oApurEnt:SetRegime(NAOCUMULAT) 
			    oApurEnt:SetOrigem(OUTROS)			
				oApurEnt:SetReceita(aCrePresu[8])
				oApurEnt:SetCodBcc('13')
				oApurEnt:SetTNatRec("")
				oApurEnt:SetCNatRec("")		
				oApurEnt:SetGNatRec("")
				oApurEnt:SetDNatRec("")	
				oApurEnt:SetCFOP(	'')	
		
				//--------------------
				//Informações de PIS
				//--------------------			
				oApurEnt:SetTributo(PIS)
				oApurEnt:SetCST(cCstPres)		
				oApurEnt:SetAlqTrib(aCrePresu[9])
				oApurEnt:SetBcTrib(aCrePresu[8])
				oApurEnt:SetValTrib(aCrePresu[1])				
				oApurEnt:AgrpCred()
		
				//-----------------------
				//Informações da COFINS
				//-----------------------		
				oApurEnt:SetTributo(COFINS)		
				oApurEnt:SetCST(cCstPres)		
				oApurEnt:SetAlqTrib(aCrePresu[10])
				oApurEnt:SetBcTrib(aCrePresu[8])
				oApurEnt:SetValTrib(aCrePresu[2])
				oApurEnt:AgrpCred()		
				
				//----------------------------------
				//Agrupa valores para resumo de CST
				//----------------------------------
				oApurEnt:GrvResCST()	
				
				//-----------------------------------------
				//ABAIXO GRAVA OS VALORES DO REGISTRO F100 
				//-----------------------------------------
				oF100:SetParam('CL2_PER',dDataDe)
				oF100:SetParam('CL2_REG','F100')
				oF100:SetParam('CL2_INDOP','0')
				oF100:SetParam('CL2_PARTI',aCrePresu[11])
				oF100:SetParam('CL2_ITEM', aCrePresu[12])		
				oF100:SetParam('CL2_DTOPER',dDataAte)		
				oF100:SetParam('CL2_VLOPER',aCrePresu[8])
				oF100:SetParam('CL2_CSTPIS',cCstPres)		
				oF100:SetParam('CL2_BCPIS',aCrePresu[8])		
				oF100:SetParam('CL2_ALQPIS',aCrePresu[9])		
				oF100:SetParam('CL2_VLPIS',aCrePresu[1])		
				oF100:SetParam('CL2_CSTCOF',cCstPres)		
				oF100:SetParam('CL2_BCCOF',aCrePresu[8])		
				oF100:SetParam('CL2_ALQCOF',aCrePresu[10])		
				oF100:SetParam('CL2_VLCOF',aCrePresu[2])		
				oF100:SetParam('CL2_CODBCC','13')		
				oF100:SetParam('CL2_INDCRD',aCrePresu[13])		
				oF100:SetParam('CL2_CTA','')		
				oF100:SetParam('CL2_CCUS','')		
				oF100:SetParam('CL2_DESCR',aCrePresu[14]+aCrePresu[15]+aCrePresu[5])
				oF100:Save()
			EndIf
		Next nX
		 //MATO O OBJETO oF100
       FreeObj(oF100)
		oF100:= nil 
         


Return
//-------------------------------------------------------------------
/*/{Protheus.doc} F100PreTEnt
 
Função que irá retornar as entrada para  cálculo do crédito 
presumidoconforme lei 12.058/2009
 
@author Henrique Pereira
@since 27/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function F100PreTSai(dDataDe,dDataAte,cNrLivro)
Local cAliasSFT 	:= "SFT"
Local aRetorno 	:= {0,0}
Local cFiltro 	:= ""
Local cCampos 	:= ""
Local aCFOPs     := XFUNCFRec() // Funcao que retorna array com CFOPS / [1]-Considera Receita / [2]-NAO considera como Receita
Local aNCMS   := GetNewPar('MV_NCMCPPC',{""}) // Saída - Exportação 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um array com os códigos NCMs que serão considerados como exportação para percentual do cálculo da base de cálculo de crédito Presumido.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aNCMS   			:= Iif (Len(aNCMS) > 1,&(aNCMS),aNCMS)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄV¿
	//³Irá trazer valores de receitas para totalizar percentual de receita de exportação, para calcular crédito presumido.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄVÙ
	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbSetOrder (2))
	
	    If (TcSrvType ()<>"AS/400")
	    	cAliasSFT	:=	GetNextAlias()

			cFiltro := "%"

			If (cNrLivro<>"*")
        		cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:cNrLivro% +"' AND "
      		EndiF

			cFiltro += "%"
			cCampos := "%"

	    	BeginSql Alias cAliasSFT

				COLUMN FT_EMISSAO AS DATE
		    	COLUMN FT_ENTRADA AS DATE
		    	COLUMN FT_DTCANC AS DATE

				SELECT
					SUM(SFT.FT_VALCONT) FT_VALCONT , SFT.FT_ESPECIE, SFT.FT_CFOP , SFT.FT_PRODUTO, SFT.FT_CSTPIS, SFT.FT_CSTCOF, SB1.B1_POSIPI
					%Exp:cCampos%
				FROM
					%Table:SFT% SFT
					LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%)
				WHERE
					SFT.FT_FILIAL=%xFilial:SFT% AND
					SFT.FT_TIPOMOV = 'S' AND
					SFT.FT_ENTRADA>=%Exp:DToS (dDataDe)% AND
					SFT.FT_ENTRADA<=%Exp:DToS (dDataAte)% AND
					(SFT.FT_DTCANC = ' ' OR SFT.FT_DTCANC > %Exp:DToS (dDataAte)% )  AND
					SFT.FT_TIPO NOT IN ('D','B') AND
					%Exp:cFiltro%
					SFT.%NotDel%

				GROUP BY SFT.FT_ESPECIE, SFT.FT_CFOP, SFT.FT_PRODUTO, SB1.B1_POSIPI, SFT.FT_CSTPIS, SFT.FT_CSTCOF

				ORDER BY SFT.FT_CFOP

			EndSql
		EndIf
	
	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbGoTop ())
	ProcRegua ((cAliasSFT)->(RecCount ()))

	
	Do While !(cAliasSFT)->(Eof ())

		cEspecie	:=	AModNot ((cAliasSFT)->FT_ESPECIE)		//Modelo NF

		If cEspecie$"  " .Or. ( (AllTrim((cAliasSFT)->FT_CFOP)$aCFOPs[01])	.AND. !(AllTrim((cAliasSFT)->FT_CFOP)$aCFOPs[02]) ) .And. NCMCPPC((cAliasSFT)->B1_POSIPI, aNCMS)// Verifica se o CFOP é gerador de receita
      
				If SubStr((cAliasSFT)->FT_CFOP,1,1) == "7" 
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Acumula valor de receita exportação³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					
					 aRetorno[1] += (cAliasSFT)->FT_VALCONT
					 
				EndIf
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Acumula valor de receita total³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				    aRetorno[2] += (cAliasSFT)->FT_VALCONT		   
			
		EndIf
   
		(cAliasSFT)->(DbSkip ())
	EndDo

		If (TcSrvType ()<>"AS/400")
			DbSelectArea (cAliasSFT)
			(cAliasSFT)->(DbCloseArea ())
		EndIf
	

	cAliasSFT	:=	"SFT"


Return aRetorno
//-------------------------------------------------------------------
/*/{Protheus.doc} F100PreTEnt
 
Função que irá retornar as entrada para  cálculo do crédito 
presumidoconforme lei 12.058/2009
 
@author Henrique Pereira
@since 27/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function F100PreTEnt(dDataDe,dDataAte,cNrLivro)
Local cAliasSFT 	:= "SFT"
Local aRetorno 	:= {}
Local cFiltro 	:= ""
Local cCampos 	:= ""
Local nPos			:= 0
Local aNCME		:= GetNewPar('MV_NCMCREP',"{}")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Monta um array com os códigos NCMs que serão considerados como exportação para percentual do cálculo da base de cálculo de crédito Presumido.³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	aNCME   			:= Iif (Len(aNCME) > 1,&(aNCME),aNCME)

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³A querry irá trazer o valor de compra de gado para montar a base de cálculo, para gerar valor de crédito presumido.³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbSetOrder (2))
	
	    If (TcSrvType ()<>"AS/400")
	    	cAliasSFT	:=	GetNextAlias()

			cFiltro := "%"

			If (cNrLivro<>"*")
        		cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:cNrLivro% +"' AND "
      		EndiF

			cFiltro += "%"
			cCampos := "%"

	    	BeginSql Alias cAliasSFT

				COLUMN FT_EMISSAO AS DATE
		    	COLUMN FT_ENTRADA AS DATE
		    	COLUMN FT_DTCANC AS DATE

				SELECT
					SUM(SFT.FT_VALCONT) FT_VALCONT , SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_PRODUTO, SB1.B1_POSIPI, SFT.FT_CFOP, SFT.FT_NFISCAL, SFT.FT_SERIE
					%Exp:cCampos%
				FROM
					%Table:SFT% SFT
					LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%)
				WHERE
					SFT.FT_FILIAL=%xFilial:SFT% AND
					SFT.FT_TIPOMOV = 'E' AND
					SFT.FT_ENTRADA>=%Exp:DToS (dDataDe)% AND
					SFT.FT_ENTRADA<=%Exp:DToS (dDataAte)% AND
					SFT.FT_TIPO NOT IN ('D','B') AND
					(SFT.FT_DTCANC = ' ' OR SFT.FT_DTCANC > %Exp:DToS (dDataAte)% )  AND
					%Exp:cFiltro%
					SFT.%NotDel%

				GROUP BY SFT.FT_NFISCAL, SFT.FT_SERIE, SFT.FT_CLIEFOR,SFT.FT_LOJA, SFT.FT_PRODUTO, SB1.B1_POSIPI,FT_CFOP

				ORDER BY SFT.FT_NFISCAL

			EndSql
		EndIf
	

	DbSelectArea (cAliasSFT)
	(cAliasSFT)->(DbGoTop ())
	ProcRegua ((cAliasSFT)->(RecCount ()))

	Do While !(cAliasSFT)->(Eof ()) .And. NCMCPPC((cAliasSFT)->B1_POSIPI, aNCME)

			If !ASCAN(aRetorno,{|X|X[3]== (cAliasSFT)->FT_PRODUTO .And. X[2] == (cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA .AND.;
				                            X[5] == (cAliasSFT)->FT_NFISCAL .AND. X[6] == (cAliasSFT)->FT_SERIE }) > 0

					AADD(aRetorno,{})
					nPos := Len(aRetorno)
					AADD(aRetorno[nPos], (cAliasSFT)->FT_VALCONT)  
					AADD(aRetorno[nPos], (cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA) 
					AADD(aRetorno[nPos], (cAliasSFT)->FT_PRODUTO)
					If SubStr((cAliasSFT)->FT_CFOP,1,1) > '2'
					    AADD(aRetorno[nPos], '1') // Crédito originário do Mercado externo
					Else
					    AADD(aRetorno[nPos], '0') // Crédito originário do Mercado interno
					EndIf
					AADD(aRetorno[nPos], (cAliasSFT)->FT_NFISCAL)
					AADD(aRetorno[nPos], (cAliasSFT)->FT_SERIE)					 
					
			Else
			       aRetorno[LEN(aRetorno), 1] += (cAliasSFT)->FT_VALCONT
					
			EndIf
					
		
        
		(cAliasSFT)->(DbSkip ())
	EndDo

	
		If (TcSrvType ()<>"AS/400")
			DbSelectArea (cAliasSFT)
			(cAliasSFT)->(DbCloseArea ())
		EndIf
	


Return aRetorno
//-------------------------------------------------------------------
/*/{Protheus.doc} F100CrePreG
 
Função que irá realizar o cálculo do crédito presumidoconforme lei 12.058/2009
 
@author Henrique Pereira
@since 27/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------

Static Function F100CrePreG(aVlrRec,aVlrCompra,dDataAte,nX)
Local nAlqPis		:= 0
Local nAlqCof		:= 0
Local nValPis		:= 0
Local nValCof		:= 0
Local nPerExport	:= 0
Local nBaseCalc	:= 0
Local nValRec1	:= 0
Local nValRec2	:= 0
Local nValComp	:= 0
Local aRetorno		:= {0,0,"","","","","",0,0,0,"","","","",""}
Local cCodAjust		:= GetNewPar("MV_CAJCPPC","03")
Local cNumProc		:= GetNewPar("MV_DAPCCPA",	"Crédito presumido conforme lei 12.058/2009 e IN Instrução Normativa RFB nº 977, de 14 de dezembro de 2009")
local cDescr			:= cNumProc
Local aAliquota		:= GetNewPar("MV_ACPPCAG",	{{0.495,2.28}})



aAliquota   		:= Iif (Len(aAliquota) > 1,&(aAliquota),aAliquota)
nAlqPis				:= aAliquota[1]
nAlqCof				:= aAliquota[2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Faz regra de 3 para descobrir o percentual de exportação³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPerExport	:= (aVlrRec[1] * 100) / aVlrRec[2]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Aplica o percentual no total de compra de gado, para saber qual a base de cálculo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nBaseCalc	:= Round((aVlrCompra[nX,1] * nPerExport) /100,2)


//³Cálculo dos valores de créditos.³

nValPis		:= Round((nBaseCalc * nAlqPis ) /100,2)
nValCof 	:= Round((nBaseCalc * nAlqCof ) /100,2)

aRetorno[1]  := nValPis  		//Valor de crédito de PIS
aRetorno[2]  := nValCof  	 	//Valor de crédito de Cofins
aRetorno[3]  := "1" 				//Indicador de ajuste de acréscimo
aRetorno[4]  := cCodAjust	 	//Código do Ajuste
aRetorno[5]  := cNumProc 		//Número do processo
aRetorno[6]  := cDescr    		//Descrição
aRetorno[7]  := dDataAte  		//Data
aRetorno[8]  := nBaseCalc
aRetorno[9]  := nAlqPis
aRetorno[10] := nAlqCof
aRetorno[11] := aVlrCompra[nX,2] // Código do fornecedor
aRetorno[12] := aVlrCompra[nX,3] //Código do produto  
aRetorno[13] := aVlrCompra[nX,4] //Origem do crédito
aRetorno[14] := aVlrCompra[nX,5] //Codigo Nota fiscal
aRetorno[15] := aVlrCompra[nX,6] //Serie Nota Fiscal    

Return aRetorno

//-------------------------------------------------------------------
/*/{Protheus.doc} F100Presu
 
Função que retorna verifica o NCM válido para o álculo do crédito presumidoconforme lei 12.058/2009
 
@author Henrique Pereira
@since 27/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function NCMCPPC(cNcm, aNCM)

Local nPos		:= 0
local lRet		:= .F.

Default cNcm  := ""
Default aNCM  := {}
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Irá fazer for para verificar todos NCMs³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
For nPos := 1 to len(aNCM)

	IF aNCM[nPos] $ Alltrim(cNcm)
		lRet := .T.
		exit
	EndIf
Next nPos
Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustaSX1
 
Função que realizar ajuste da pergunta 19 na apuração.
 
@author Henrique Pereira
@since 27/01/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function AjustaSX1()

Local aPHelpPor	:=	{}
Aadd( aPHelpPor	, "Indica se devem ser processadas as ")
Aadd( aPHelpPor	, "retenções das NF's de saída (F600).")
Aadd( aPHelpPor	, "1-Sim;")
Aadd( aPHelpPor	, "2-Não;")

PutSx1("ISA001","19",'Processa Retenções - Saídas?','Processa Retenções - Saídas?','Processa Retenções - Saídas?',"MV_CHJ","N",1,0,1,"C","","","","","mv_par19",'1-Sim          ','1-Sim          ','1-Sim          ',"",'2-Nao          ','2-Nao          ','2-Nao          ',"","","","","","","","","",aPHelpPor,aPHelpPor,aPHelpPor)	

aPHelpPor	:=	{}
Aadd( aPHelpPor	, "Indica se será consolidado")
Aadd( aPHelpPor	, " ou detalhado, leva valores ")
Aadd( aPHelpPor	, "diferentes para os registro")
Aadd( aPHelpPor	, "de apuração")

PutSx1("ISA001","20",'Indicador Regime Cumulativo','Indicador Regime Cumulativo','Indicador Regime Cumulativo',"MV_CHK","N",1,0,1,"C","","","","","mv_par20",'1-Consolidado','1-Consolidado','1-Consolidado',"",'2-Detalhado','2-Detalhado','2-Detalhado',"","","","","","","","","",aPHelpPor,aPHelpPor,aPHelpPor)



Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ConsCPRB
 
Função que verifica se a receita desonerada é superior a 5%. Caso não seja, as informações serão apagadas das devidas tabelas da apuração.
 
@author Simone Oliveira
@since 26/04/2016
@version 11.80

/*/
//-------------------------------------------------------------------
static function ConsCPRB( aFil, aPergunta )

local aAreaSM0 		:= SM0->(GetArea())
local aXFilial		:= {}

local oCPRB			:= nil

local nValBrut		:= 0
local nVlAtiv		:= 0
local nPerc			:= 0
local nX			:= 0

local lTabCPRB		:= .f.	
local lIndividu		:= .f.	

default aFil		:= {}
default aPergunta	:= {}

//Verifico se é Individualizado ou Consolidado
if aPergunta[15] == 2
	lIndividu	:= .t.
endif	

// Se for consolidado já busco filial
if !lIndividu
	aXFilial:= ASA001AFIL()
endif

//Cria Objeto da CPRB
oCPRB:= CPRBEFD():New()	
oCPRB:SetConsol(.f.)
oCPRB:SetDtIni(MV_PAR01)
oCPRB:LoadCPRB()


//Atribui os valores nas devidas variáveis para realizar o cálculo e verificar se 
nValBrut	:= oCPRB:GetVlBrut()
nVlAtiv	:= oCPRB:GetVlAtiv()

//Realiza o cálculo para descobrir o percentual de Desoneração
nPerc := (nVlAtiv/nValBrut)*100

//Se menor/igual a 5% Zera as tabelas da apuração
if nPerc <= 5
	lTabCPRB := .t.
	
	for nX:=1 to len( aFil ) //Processamento por Filial
		
		SM0->(DbGoTop ())
		SM0->(MsSeek (aFil[nX][1]+aFil[nX][2], .T.))
		cFilAnt := FWGETCODFILIAL	
		
		
		//Se for individualizado, busco a devida filial
		if lIndividu
			aXFilial:= ASA001AFIL()
		endif
		
		IniTabApur (aPergunta,aXFilial,.f.,.f., lTabCPRB) //Limpa as tabelas de apuração
	 
	 next nX
endif

RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL

return

Static Function DetCPRB(dDataDe,dDataAte,cFilialMat,lProcRH)
Local cPreNome	:= ''
Local cNomeReal	:= ''
Local cAliasTMP	:= ''
Local cArqRh		:= "13Sal" 
Local cExtDBF		:= GetDBExtension()
Local cPeriodo	:= Alltrim(StrZero(Month(dDataDe),2))+Alltrim(Str(Year(dDataDe)))
Local nCont		:= 0
Local ObjF0T	:= TABELAF0T():New()
Local nAlq		:= 0
Local nPos		:= 0
Local aAliqAtv	:= {}

cPreNome	:= 'FAT'+cFilAnt+'DES'+ Iif(lProcRH,cArqRh,cPeriodo)

//O trecho abaixo está seguindo a mesma lógica que na função da INSSPAT no FATXFUN, para definição do nome do arquivo com log das notas
If File(cPreNome+cExtDBF) // verifico se já existe um arquivo com o nome a ser gerado para criar com outro nome
	cNomeReal	:= cPreNome+cExtDBF //Considera este nome como último arquivo temporário criado
	cAliasTMP	:= cPreNome
	For nCont 	:= 1 to 100
		If File(cPreNome+"_"+AllTrim(Str(nCont))+cExtDBF)
			cNomeReal	:= cPreNome+"_"+AllTrim(Str(nCont))+cExtDBF
			cAliasTMP	:= cPreNome+"_"+AllTrim(Str(nCont))
		Else
			Exit
		EndIF
	Next nCont
	If nCont > 100
		cNomeReal	:= cPreNome+cExtDBF
		cAliasTMP	:= cPreNome
	EndIF
	//Abrir o arquivo
	//o Alias urilizado no FATXFUN é informação correspondente na cAliasTMP
	
	DbUseArea(.T., __LocalDriver, cAliasTMP, cAliasTMP,.T.,.T.)
	DbSelectArea(cAliasTMP)
	//cAliasTMP->(DbSetOrder(1))
	(cAliasTMP)->(dbGoTop()) 	
	If (cAliasTMP)->(ColumnPos('ITEMNF')) > 0 
	
		Do While !(cAliasTMP)->(Eof ())
			If (cAliasTMP)->TIPO $ 'N/C/P' 
			
				nPos := aScan (aAliqAtv, {|aX| aX[1] ==  Alltrim((cAliasTMP)->CODATIV)})
				//Guardo as alíquotas e códigos de atividades processados para não chamar a SpedPCCG1 para todos os itens
				IF nPos == 0		
					nAlq	:= SpedPCCG1((cAliasTMP)->CODATIV,dDataAte)
					aAdd(aAliqAtv, {})
					nPos := Len(aAliqAtv)
					aAdd (aAliqAtv[nPos], Alltrim((cAliasTMP)->CODATIV))
					aAdd (aAliqAtv[nPos], nAlq)
				Else
					nAlq	:= aAliqAtv[nPos][2]
				EndIF
				
				ObjF0T:Clear()
				ObjF0T:SetValue("F0T_PER",dDataDe)
				ObjF0T:SetValue("F0T_FILAPU",cFilialMat)
				ObjF0T:SetValue("F0T_TIPO",Iif(lProcRH,'7' ,'6' )) //CPRB Regime de Caixa							
				ObjF0T:SetValue("F0T_NUMNF",(cAliasTMP)->NUMNF)
				ObjF0T:SetValue("F0T_SER",(cAliasTMP)->SERIE)
				ObjF0T:SetValue("F0T_DTEMI",CTOD(Substr( (cAliasTMP)->DATANF,7,2)  + '/'+ Substr( (cAliasTMP)->DATANF,5,2) + '/' + Substr( (cAliasTMP)->DATANF,1,4)))										
				ObjF0T:SetValue("F0T_CFOP",(cAliasTMP)->CFOP)
				ObjF0T:SetValue("F0T_VLCONT",(cAliasTMP)->TOTAL)
				
				//-------------------------------
				//Campos abaixo serão adicionados pela equipe de Faturamento
				ObjF0T:SetValue("F0T_ITEM",(cAliasTMP)->ITEMNF)
				ObjF0T:SetValue("F0T_MODELO",(cAliasTMP)->ESPECNF)
				ObjF0T:SetValue("F0T_EXCPRB",(cAliasTMP)->TOTBRUTO -  (cAliasTMP)->TOTAL)			
				ObjF0T:SetValue("F0T_CODATV",(cAliasTMP)->CODATIV)
				//-------------------------------			
				//Campos abaixo serão calculados por nós, considerando alíquota do código de atividade
				ObjF0T:SetValue("F0T_BCCPRB",(cAliasTMP)->TOTAL)			
				ObjF0T:SetValue("F0T_AQCPRB",nAlq)
				ObjF0T:SetValue("F0T_VLCPRB",  Round( ((cAliasTMP)->TOTAL * nAlq)/100 ,2)  )							
				
				ObjF0T:Grava()
			EndIf											
			(cAliasTMP)->(DBSKIP())
		Enddo
	EndIF
	
	DbSelectArea(cAliasTMP)
	dbCloseArea()		
	
EndIF		


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA001QRYD
Funcao que efetua filtros em tabelas. Ela deve ser chamada como 1 para criar, 2 para fechar a area
criada e 3 para deletar registros
	
@param	nOpc -> Parametro que define se criara o filtro, fecha um filtro jah criado ou 
				deleta registros. 1=Criar, 2=Fechar, 3=Deletar
		cCompon -> 	Se trata de um flag atraves do componente a ser criado o filtro. 
					No caso de haver mais de um filtro para a mesma tabela em situacoes diferentes, 
					basta acrescentar um identificador na quarta posicao do nome. Ex: SFT, SFT1, SF2, etc..
		cAlias -> Variavel passada por referencia para retornar o alias criado para o componente em questao.
		aPar -> Parametros para execucao dos filtros
		nRecCount ->Se esta variavel for passada diferente de NIL,significa que a query deve retornar a 
					quantidade de registros. Utilizado para montar a regua de processamento mais precisa.
					O retorno serah nesta mesma variavel que deve ser passada como referencia. O retorno 
					da funcao ainda continua sendo .T. quando tiver registros ou .F. quando nao tiver.
	
@return lRet -> Booleano para identificar se a tabela possui registros ou nao. No caso de retornar .F., 
				nao eh necessário chamar a funcao com o primeiro parametro igual a 2, pois se nao houver 
				movimento, ela fecha o alias automaticamente.
		

@author Luccas Curcio
@since 10/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------

Function FSA001QRYD(nOpc,cCompon,cAlias,aPar,nRecCount,dDataDe)
Local	cSelect		:=	""
Local	cFrom		:=	""
Local	cWhere		:=	""
Local	cOrderBy	:=	""
Local	cIndex		:=	""
Local	lCountReg	:=	nRecCount<>Nil
Local	lRet		:=	.F.
Local	aSetField	:=	{}
Local	nI			:=	0
Local lF0T			:= AliasINdic('F0T')
Local cChaveF0T	:= ''
DEFAULT dDataDe	:= cTod('  /  /    ')

If nOpc == 1

	If cCompon == "SE1"
   
		//SELECT
		If lCountReg
			cSelect	:=	"%COUNT(*) COUNTREG%"
		Else
		
			//Campos que utilizarao Alias no Processamento
			cSelect	:=	"%SE1.E1_EMISSAO EMISSAO, SE1.E1_NUM DOC, SE1.E1_SALDO SALDO, SE1.E1_VALOR VALOR, "
			cSelect	+=	"SED.ED_CSTPIS CSTPIS, SED.ED_CSTCOF CSTCOF, SED.ED_TPREG TPREG, SED.ED_PCAPPIS ALIQPIS, "
			cSelect	+=	"SED.ED_PCAPCOF ALIQCOF, SA1.A1_CGC CNPJCLI, SE5.E5_DATA DATABX, SE5.E5_TIPODOC TIPODOC, "
			cSelect	+=	"SE5.E5_VALOR VALORBX, SFT.FT_NFISCAL NFISCAL, SFT.FT_ENTRADA  , SFT.FT_NRLIVRO NRLIVRO, SB1.B1_COD CODPROD, SD2.D2_PROJPMS PROJETO, "            
			
			//Outros campos
			cSelect	+=	"SE1.E1_FILIAL,	SE1.E1_PREFIXO,  SE1.E1_PARCELA,SE1.E1_TIPO, SE1.E1_PARCELA, SE1.R_E_C_N_O_, SE1.E1_CLIENTE, SE1.E1_LOJA, "
			cSelect	+=	"SFT.FT_VALCONT, SFT.FT_ALIQPIS, SFT.FT_ALIQCOF, SFT.FT_CSTPIS, SFT.FT_CSTCOF, SFT.FT_VALPIS, SFT.FT_VALCOF, SFT.FT_BASEPIS, SFT.FT_BASECOF, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_ITEM, "
			cSelect	+=	"SF4.F4_TPREG, "
			cSelect	+=	"SB1.B1_PPIS, SB1.B1_PCOFINS, SB1.B1_PCSLL, SE6.E6_FILDEB, "
			
			If SB1->(FieldPos(aPar[3])) > 0
				cSelect	+=	"SB1."+aPar[3]+", " 
			Endif
			
			cSelect	+=	"SB1.B1_TPREG, "			
						
			cSelect	+=	"SA1.A1_COD, SA1.A1_LOJA, "
			
			If SA1->(FieldPos(aPar[4])) > 0
				cSelect	+=	"SA1."+aPar[4]+", "
			Endif
			
			If SA1->(FieldPos("A1_TPREG"))>0 //Adicionado o Fieldpos pois esse campo eh criado pelo usuario.
				cSelect	+=	"SA1.A1_TPREG, "
			Endif
			
			cSelect	+=	"SED.ED_CODIGO,	SED.ED_PERCPIS,	SED.ED_PERCCOF,	SED.ED_PERCCSL, "
			cSelect	+=	"SE5.E5_MOTBX,SE5.E5_NUMERO,	SE5.E5_PREFIXO,	SE5.E5_MOEDA,	SE5.E5_PARCELA,	SE5.E5_VRETPIS, SE5.E5_VRETCOF,	SE5.E5_VRETCSL,	E5_VRETISS,	E5_VRETIRF,	SE5.E5_VLJUROS, SE5.E5_VLMULTA,	SE5.E5_VLDESCO,	SE5.E5_DATA%"		
		Endif
	    
	    //FROM
		//Tabela Principal: SE1
		//Joins: 	SE1->SFT->SB1 / SE1->SF2->SFT->SB1
		//			SE1->SFT->SD2->SF4 / SE1->SF2->SFT->SD2->SF4
		//			SE1->SE5
		//			SE1->SED
		//			SE1->SA1
		cFrom	:=	"%"+RetSqlName("SE1")+" SE1 "
		
		// -- JOIN SA1 --
		cFrom	+=	"JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SE1.E1_CLIENTE AND SA1.A1_LOJA=SE1.E1_LOJA AND SA1.D_E_L_E_T_ = '' "

		// -- LEFT JOIN SED --
		cFrom	+=	"LEFT JOIN "+RetSqlName("SED")+" SED ON SED.ED_FILIAL='"+xFilial("SED")+"' AND SED.ED_CODIGO=SE1.E1_NATUREZ AND "
		//Cadastro indica que utiliza Pis/Cofins
		cFrom	+=	"(SED.ED_APURCOF<>'' OR SED.ED_APURPIS<>'') AND SED.D_E_L_E_T_ = '' "

		// -- LEFT JOIN SE6 --
		cFrom	+=	"LEFT JOIN "+RetSqlName("SE6")+" SE6 ON SE6.E6_FILORIG= '"+xFilial("SE6")+"' AND SE6.E6_PREFIXO=SE1.E1_PREFIXO AND SE6.E6_NUM=SE1.E1_NUM and SE6.E6_PARCELA=SE1.E1_PARCELA  and SE6.E6_TIPO=SE1.E1_TIPO AND SE6.D_E_L_E_T_ = '' "
		
		// -- LEFT JOIN SE5 --
		cFrom	+=	"LEFT JOIN "+RetSqlName("SE5")+" SE5 ON (SE5.E5_FILIAL='"+xFilial("SE5")+"' AND SE5.E5_TIPODOC NOT IN ('DC','JR','MT') AND SE5.E5_PREFIXO=SE1.E1_PREFIXO AND SE5.E5_NUMERO=SE1.E1_NUM AND SE5.E5_PARCELA=SE1.E1_PARCELA AND SE5.E5_TIPO=SE1.E1_TIPO AND "
		cFrom	+=	"SE5.E5_CLIFOR=SE1.E1_CLIENTE AND SE5.E5_LOJA=SE1.E1_LOJA AND "		
		//Elimina estorno, Motivos de Baixa, Situacao de Documento 
		cFrom	+=	"SE5.E5_TIPODOC	<> 'ES' AND "
		cFrom	+=	"SE5.E5_MOTBX NOT IN ('LIQ','CEC') AND "
		cFrom	+=	"SE5.E5_SITUACA <> 'C' AND "	
		cFrom	+=	"SE5.D_E_L_E_T_ =  ' ') "
		
		// -- LEFT JOIN SFT/SF2 --
		//Verifico conteudo do parametro MV_1DUPREF, pois se utilizar o padrao (SF2->F2_SERIE), o prefixo do titulo eh gravado
		//com a serie da nota fiscal. Porem se utilizar outro conteudo, devera utilizar o campo F2_PREFIXO para encontrar a nota
		//vinculada ao titulo, entao precisa utilizar a tabela SF2 no JOIN antes da SFT.
		If aPar[5] <> "SF2->F2_SERIE"
			cFrom	+=	"LEFT JOIN "+RetSqlName("SF2")+" SF2 ON SF2.F2_FILIAL='"+xFilial("SF2")+"' AND SF2.F2_DOC=SE1.E1_NUM AND SF2.F2_PREFIXO=SE1.E1_PREFIXO AND SF2.F2_CLIENT=SE1.E1_CLIENTE AND SF2.F2_LOJA=SE1.E1_LOJA AND SF2.D_E_L_E_T_ = '' "
			cFrom	+=	"LEFT JOIN "+RetSqlName("SFT")+" SFT ON SFT.FT_FILIAL='"+xFilial("SFT")+"' AND SFT.FT_SERIE=SF2.F2_SERIE AND SFT.FT_NFISCAL=SF2.F2_DOC AND SFT.FT_CLIEFOR=SF2.F2_CLIENT AND SFT.FT_LOJA=SF2.F2_LOJA AND " 
		Else
			cFrom	+=	"LEFT JOIN "+RetSqlName("SFT")+" SFT ON SFT.FT_FILIAL='"+xFilial("SFT")+"' AND SFT.FT_SERIE=SE1.E1_SERIE AND SFT.FT_NFISCAL=SE1.E1_NUM AND SFT.FT_CLIEFOR=SE1.E1_CLIENTE AND SFT.FT_LOJA=SE1.E1_LOJA AND "
		Endif
		//Condicoes do SPED Contribuicoes
	    cFrom	+=	"(((SFT.FT_BASEPIS>0 OR SFT.FT_BASEPS3>0) OR SFT.FT_CSTPIS IN ('07','08','09','49')) OR ((SFT.FT_BASECOF>0 OR SFT.FT_BASECF3>0) OR SFT.FT_CSTCOF IN ('07','08','09','49'))) AND "
	    cFrom	+=	"SFT.D_E_L_E_T_ = '' "
		
		// -- LEFT JOIN SD2 --
		cFrom	+=	"LEFT JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM  AND SD2.D_E_L_E_T_='' "
		
		// -- LEFT JOIN SF4 --
		cFrom	+=	"LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_='' "
		
		// -- LEFT JOIN SB1 --		
		cFrom	+=	"LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_ = ''%"
		
	    //WHERE
	    //Filial
		cWhere	+=	"%SE1.E1_FILIAL='"+xFilial("SE1")+"'	AND "
	
		//Titulos emitido dentro do periodo ou Titulos emitidos anteriormente com baixa no periodo e baixa depois do periodo
		cWhere	+=	"((SE1.E1_EMISSAO>='"+DTOS(aPar[1])+"' AND SE1.E1_EMISSAO<='"+DTOS(aPar[2])+"' AND SE1.E1_SALDO>0 ) OR "
		cWhere	+=	"(SE1.E1_EMISSAO<'"+DTOS(aPar[1])+"' AND (SE5.E5_DATA>='"+DTOS(aPar[1])+"' AND SE5.E5_DATA<='"+DTOS(aPar[2])+"') )  OR " 
		cWhere	+=	"(SE1.E1_EMISSAO>='"+DTOS(aPar[1])+"' AND SE1.E1_EMISSAO<='"+DTOS(aPar[2])+"' AND (SE5.E5_DATA>'"+DTOS(aPar[2])+"' OR SE1.E1_SALDO=0) ) ) AND "
		
		//Titulos emitidos para Orgao Publico
		cWhere	+=	"SE1.E1_SCORGP='1' AND "
		cWhere	+=	"SE1.E1_TIPO NOT IN ('PR ','PRE') AND " 
		cWhere	+=	"SE1.E1_ORIGEM NOT IN ('FINA460 ','FINA280') AND " 
		cWhere	+=	"SE1.E1_FATURA	= ' ' AND "
		cWhere	+=	"SE1.D_E_L_E_T_ = '' AND "
				
		//Subquery utilizada para eliminar sequencias que possuem estorno de baixas
		cWhere	+=	"SE5.E5_SEQ NOT IN (SELECT SE5SEQ.E5_SEQ " 
		cWhere	+=	"FROM "+RetSqlName("SE5")+" SE5SEQ " 
		cWhere	+=	"WHERE SE5SEQ.E5_FILIAL	=	SE5.E5_FILIAL AND " 
		cWhere	+=	"SE5SEQ.E5_PREFIXO	=	SE5.E5_PREFIXO AND "
		cWhere	+=	"SE5SEQ.E5_NUMERO	=	SE5.E5_NUMERO AND "
		cWhere	+=	"SE5SEQ.E5_PARCELA	=	SE5.E5_PARCELA AND "
		cWhere	+=	"SE5SEQ.E5_TIPO		= 	SE5.E5_TIPO AND "
		cWhere	+=	"SE5SEQ.E5_CLIFOR	= 	SE5.E5_CLIFOR AND "
		cWhere	+=	"SE5SEQ.E5_LOJA		= 	SE5.E5_LOJA AND "
		cWhere	+=	"SE5SEQ.E5_TIPODOC	=	'ES' AND "
		cWhere	+=	"SE5SEQ.D_E_L_E_T_	= '') "
		
		//ORDER BY
		If !lCountReg
			cOrderBy	:=	"ORDER BY SE5.E5_NUMERO, SE5.E5_PREFIXO%"
		Else
			cOrderBy	:=	"%"
		Endif
		
		aAdd(aSetField,{"EMISSAO","D",8,0})
		aAdd(aSetField,{"DATABX","D",8,0})
		aAdd(aSetField,{"FT_ENTRADA","D",8,0})
	
	
	Elseif cCompon == "CF8"
	    
		//SELECT
		If lCountReg
			cSelect	:=	"%COUNT(*) COUNTREG%"
		Else
			cSelect	:=	"%SA1.A1_CGC CNPJCLI, CF8.CF8_DTOPER EMISSAO, CF0.CF0_DATA DATABX, CF8.CF8_CODIGO DOC, "
			cSelect	+=	"CF8.CF8_ITEM CODPROD, CF8.CF8_SALDO SALDO, CF0.CF0_RECBAS VALORBX, CF8.CF8_BASPIS VALOR, "
			cSelect	+=	"CF8.CF8_CSTPIS CSTPIS, CF8.CF8_CSTCOF CSTCOF, CF8.CF8_TPREG TPREG, CF8.CF8_ALQPIS ALIQPIS, CF8.CF8_ALQCOF ALIQCOF%"
		Endif
		
		//FROM
		//Tabela Principal: CF8
		//Joins: 	CF8->CF0
		//			CF8->SA1
		//			CF8->SB1
		cFrom	:=	"%"+RetSqlName("CF8")+" CF8 "
		
		// -- LEFT JOIN CF0 --
		cFrom	+=	"LEFT JOIN "+RetSqlName("CF0")+" CF0 ON CF0.CF0_FILIAL='"+xFilial("CF0")+"' AND CF0.CF0_CODIGO=CF8.CF8_CODIGO AND CF0.CF0_DATA >= '"+DTOS(aPar[1])+"' AND CF0.CF0_DATA <= '"+DTOS(aPar[2])+"' AND CF0.D_E_L_E_T_='' "
		
        // -- LEFT JOIN SB1 --
		cFrom	+=	"LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=CF8.CF8_ITEM AND SB1.D_E_L_E_T_ = '' "
		
		// -- LEFT JOIN SA1 --
		cFrom	+=	"LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=CF8.CF8_CLIFOR AND SA1.A1_LOJA=CF8.CF8_LOJA AND SA1.D_E_L_E_T_=''%"
		
		//WHERE
		//Filial
		cWhere	+=	"%CF8.CF8_FILIAL	= '"+xFilial("CF8")+"' AND "
		
		//Documentos emitidos para Orgao Publico
		cWhere	+=	"CF8.CF8_SCORGP='1' AND "
		
		//Documentos emitido dentro do periodo ou Documentos emitidos anteriormente com baixa no periodo
		cWhere	+=	"( (CF8.CF8_DTOPER>='"+DTOS(aPar[1])+"' AND CF8.CF8_DTOPER<='"+DTOS(aPar[2])+"' AND CF8.CF8_SALDO>0 ) OR "
		cWhere	+=	"(CF8.CF8_DTOPER<'"+DTOS(aPar[1])+"' AND (CF0.CF0_DATA >= '"+DTOS(aPar[1])+"' AND CF0.CF0_DATA <= '"+DTOS(aPar[2])+"') ) ) AND "
		cWhere	+=	"CF8.D_E_L_E_T_ = '' "
		
		If !lCountReg
			cOrderBy	:=	"ORDER BY CF8.CF8_CODIGO%"
		Else
			cOrderBy	:=	"%"
		Endif
		
		aAdd(aSetField,{"EMISSAO","D",8,0})
		aAdd(aSetField,{"DATABX","D",8,0})
		
	Endif
	If (TcSrvType ()<>"AS/400")
		cAlias	:=	SPEDGetAlias(cCompon)
		BeginSql Alias cAlias
		COLUMN E5_DATA AS DATE
			SELECT 
				%Exp:cSelect%
		
			FROM 
				%Exp:cFrom%
		
			WHERE 
				%Exp:cWhere+cOrderBy%
		
		EndSql
			
		If !lCountReg
			For nI := 1 To Len(aSetField)
				TcSetField(cAlias,aSetField[nI,1],aSetField[nI,2],aSetField[nI,3],aSetField[nI,4])
			Next
		Else
			//Se o retorno deve ser a quantidade de registros, armazeno em uma variavel para retornar
			nRecCount	:=	(cAlias)->COUNTREG
		EndIf
	Else

		DbSetIndex(cIndex+OrdBagExt())
		
	EndIf

	//Como jah armazenei em uma variavel o valor da quantidade de registros, posso fechar a area. 
	//O retorno da quantidade eh atraves de um parametro passado por referencia. O retorno da funcao ainda continua
	//sendo .T. quando tiver registros ou .F. quando nao tiver.
	If lCountReg
		FSA001QRYD(2,"",cAlias)	
		
		lRet	:=	nRecCount>0

	ElseIf !(cAlias)->(Eof())
		lRet	:=	.T.
		
	Else
		FSA001QRYD(2,"",cAlias)
	EndIf
	
Elseif nOpc == 2

		If (TcSrvType ()<>"AS/400")
			If Select(cAlias)<>0
				(cAlias)->(DbCloseArea())
			EndIf
		Else
			RetIndex(cAlias)
		EndIf

Elseif nOpc == 3
	
	//DIFERIMENTO
	If aPar[1] == "CFA" .Or. aPar[1] == "CFB" 
        
		If SPEDSeek("CFA",aPar[2],aPar[3])
			Do While CFA->(CFA_FILIAL+CFA_PERAPU) == aPar[3]
			    RecLock("CFA",.F.)
				CFA->(DbDelete())
				MsUnLock()
				CFA->(DbSkip())
			Enddo
		Endif
		
		If SPEDSeek("CFB",aPar[2],aPar[3])
			Do While CFB->(CFB_FILIAL+CFB_PERAPU) == aPar[3]
			    RecLock("CFB",.F.)
				CFB->(DbDelete())
				MsUnLock()
				CFB->(DbSkip())
			Enddo
		Endif
		
		IF lF0T
			DbSelectArea('F0T')
			DbSetOrder(2)
			cChaveF0T	:= xFilial('F0T') +dTos(dDataDe)
		EndIF
		
		If lF0T .AND.  aPar[1] == "CFA" .AND. F0T->(MsSeek(cChaveF0T+'4'))
			//Deleta F0T do tipo 4
			Do While F0T->(F0T_FILIAL+DTOS(F0T_PER)+F0T_TIPO) == cChaveF0T+'4'
			   RecLock("F0T",.F.)
				F0T->(DbDelete())
				MsUnLock()
				F0T->(DbSkip())
			Enddo		
		EndIf
		
		IF lF0T .AND. aPar[1] == "CFB" .AND. F0T->(MsSeek(cChaveF0T+'5'))
			Do While F0T->(F0T_FILIAL+DTOS(F0T_PER)+F0T_TIPO) == cChaveF0T+'5'
			   RecLock("F0T",.F.)
				F0T->(DbDelete())
				MsUnLock()
				F0T->(DbSkip())
			Enddo				
		EndIF 
		
	Endif
	
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PrcInfDif
Funcao que ira processar os registros referente ao Diferimento de Orgao Publico. 
Serao alimentadas as tabelas CFA e CFB, que apos processamento do Arquivo magnetico, 
irao gerar os registro M230, M630, M300 e M700.
	
@param	dDataDe -> Data Inicial de Processamento
		dDataAte -> Data Final de Processamento
		cPerApur -> Periodo do processamento
		cNrLivro -> Numero do Livro fiscal
		cAlias -> Alias da query que esta sendo processada
		cRegime -> Regime selecionado nas perguntas da rotina (1,2,3)
		lEnd -> Flag de cancelamento do processamento
		aColsCFAP -> Informacoes que serao mostradas na Dialog
		aColsCFAC -> Informacoes que serao mostradas na Dialog
		aColsCFBP -> Informacoes que serao mostradas na Dialog
		aColsCFBC -> Informacoes que serao mostradas na Dialog
		nRecCount -> Numero de registros do processamento, para montagem da regua
		cPrefixE1 -> Conteudo do parametro MV_1DUPREF
		cCmpB1Dif -> Campo da tabela SB1 que indica Diferimento de Org. Publico
		cCmpA1Dif -> Campo da tabela SA1 que indica Diferimento de Org. Publico
		cOrigem -> Origem do processamento (SE1 ou CF8)
		lProcDfCrd	-> Indica se ira realizar o processamento de Diferimento dos créditos de PIS e COFINS
		cIndNatPJ	-> Indicador da Natureza da Pessoa Juridica
		ObjF0T	-> Objeto da tabela F0T, para gravação do detalhamento do diferimento analítico
		
@return	Nil
		
@author Luccas Curcio
@since 10/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Function FSA001PRCD(dDataDe,dDataAte,cPerApur,cNrLivro,cAlias,; //5
					cRegime,lEnd,aColsCFAP,aColsCFAC,aColsCFBP,;//10
					aColsCFBC,nRecCount,cPrefixE1,cCmpB1Dif,cCmpA1Dif,;//15
					cOrigem,lProcDfCrd,cIndNatPJ,ObjF0T,LFISA054,aXFilial)//20					
							 
Local	cNtFiscal	:=	""
Local	cCSTPis		:=	""
Local	cCSTCof		:=	""
Local	cTpReg		:=	""
Local	cTimeDocs	:=	""
Local	cMsgProcess	:=	""
Local	cTpReten	:=	GetNewPar("MV_BR10925","")
Local	cChvDoc		:=	""
Local  	cCodBCPIS	:= ""
Local  	cCodBCCOF	:= ""
Local	nAlqPis		:=	0
Local	nAlqCof		:=	0
Local	nPisDifer	:=	0
Local	nPisPago	:=	0
Local	nCofDifer	:=	0
Local	nCofPago	:=	0
Local	nPercVlrNt	:=	0
Local	nPercRec	:=	0
Local	nTotDifer	:=	0
Local	nTotVend	:=	0
Local	nVlrReten	:=	0
Local	nDocsXTime	:=	0
Local	nRegsProc	:=	0
Local	nTotTit		:=	0
Local	nTranStat	:=	0
Local	cPerEmis	:=	0
Local	nPerBx		:=	0
Local	nPos		:=	0
Local  	nCredPisDf	:=  0
Local  	nX			:= 0 
Local	aValores	:=	{}
Local	aDocs		:=	{}
Local  	aCred		:= {}
Local	lBxCanc		:=	.F.
Local	lBxPerPos	:=	.F.
Local 	lIsBlind	:=	IsBlind()
Local   cNatCre		:= ""
Local	lTransfere	:= .F.
Local	 lF0T	:= AliasINdic('F0T')
Local nCredCOFDf	:= 0
Default	cPrefixE1	:=	""
Default	cCmpB1Dif	:=	""
Default	cCmpA1Dif	:=	""
DEFAULT LFISA054	:= .F.
DEFAULT aColsCFAP	:= {}
DEFAULT aColsCFAC	:= {}
DEFAULT aColsCFBP	:= {}
Default aColsCFBC	:= {}
DEFAULT nRecCount	:= 0
DEfault lEnd		:= .F.
Default aXFilial	:= {}

dbSelectArea("SE6")
SE6->(dbSetOrder(5))
Do While !(cAlias)->(Eof())

	nTotRec		:=	0
	nVlrReten	:=	0
	lBxCanc		:=	.F.
	lBxPerPos	:=	.F.
	cPerEmis	:=	Substr(DTOS((cAlias)->EMISSAO),5,2)+Substr(DTOS((cAlias)->EMISSAO),1,4)
	nPerBx		:=	Substr(DTOS((cAlias)->DATABX),5,2)+Substr(DTOS((cAlias)->DATABX),1,4)
	lTransfere	:= .F.	
	
    // --------------------------------------> INCREMENTO DA REGUA <--------------------------------------
	//Definindo o segundo incremento da regua e seu controle de detalhes
	IF LFISA054 
		If Type("oProcess")=="O"
			oProcess:Inc2Progress("Processando Documento: "+(cAlias)->DOC+" emitido em: "+DTOC((cAlias)->EMISSAO),StrZero(nRegsProc,6)+"/"+StrZero(nRecCount,6))//"Processando Documento: "###" emitido em: "###
	
			//Condicao implementada para controlar os numeros apresentadas na tela de processamento da rotina, os detalhes.
			If cTimeDocs<>Time()
				oProcess:SetDetProgress("Total de registros do periodo solicitado",nRecCount,;//"Total de registros do periodo solicitado"
						"Total de registros processados por segundo",nDocsXTime,;//"Total de registros processados por segundo"
						"Total de registros pendentes para processamento",nRecCount-nRegsProc,;//"Total de registros pendentes para processamento"
						"Tempo estimado para termino do processamento (Seg.)",Round((nRecCount-nRegsProc)/nDocsXTime,0))//"Tempo estimado para termino do processamento (Seg.)"
						
				cTimeDocs	:=	Time()
				nDocsXTime	:=	1
			Else
				nDocsXTime	+=	1
			EndIf
			
			//Controle do cancelamento da rotina
			If oProcess:Cancel()
				Exit
			EndIf
		Else
	
			aEval(aSM0,{|x| cMsgProcess := Iif(x[SM0_GRPEMP]==cEmpAnt .And. x[SM0_CODFIL]==cFilAnt .And. x[SM0_USEROK] .And. (x[SM0_EMPOK] .Or. lIsBlind),x[SM0_CODFIL]+"/"+x[SM0_FILIAL],"")})
			cMsgProcess	:=	AllTrim(cMsgProcess)
		
			IncProc("Processando Filial: "+cMsgProcess)//"Processando Filial: "
			
			//Controle do cancelamento da rotina
			If Interrupcao(@lEnd)
				Exit
			EndIf
		EndIf
	EndIF
	// --------------------------------------> ------------------- <--------------------------------------
	
	If cOrigem == "SE1"
		If cCmpB1Dif <> "" .And. !Empty((cAlias)->NFISCAL) .And. (cAlias)->(&(cCmpB1Dif)) <> "1"
			(cAlias)->(DbSkip())
			Loop
		Endif

		If cNrLivro <> "*"
			If !Empty((cAlias)->NFISCAL) .And. !(cAlias)->NRLIVRO==cNrLivro
				(cAlias)->(DbSkip())
				Loop
			Endif
		Endif
		
		//Se o título estiver gravado na SE6 com a filial de origem diferente da filial corrente processada, deverá desconsiderar esta operação			
		//E6_FILDEB+E6_PREFIXO+E6_NUM+E6_PARCELA+E6_TIPO                                                                                                                  
		If SE6->(MsSeek(xFilial("SE6")+(cAlias)->E1_PREFIXO+(cAlias)->DOC+(cAlias)->E1_PARCELA+(cAlias)->E1_TIPO)) .AND. SE6->E6_FILORIG <> xFilial('SE6')
			(cAlias)->(DbSkip())
			Loop
		EndIF		

		//Verificar aqui se o título foi transferido. Se foi, teremos aqui no campo E5_MOTBX a informação 'TRF'. Neste caso não deverá ser considerado

		If (cAlias)->E5_MOTBX == 'TRF'	//verificar o quanto foi baixado na matriz	
			lTransfere	:= .T.		
		Endif

		
		//Calcula valores de retencao. Verifica o parametro MV_BR10925.
		//Se feito na Emissao (MV_BR10925 = 2), verifico os titulos de abatimento e posteriormente calculo a proporcao da baixa
		//Se feito na Baixa (MV_BR10925 = 1), utilizo os campos da tabela SE5, pois ja estarao preenchidos com abatimento correto.
		If !lBxCanc .And. !lBxPerPos
			If cTpReten == "2"
				DbSelectArea("SE1")
				nVlrReten	:=	SomaAbat((cAlias)->E5_PREFIXO,(cAlias)->E5_NUMERO,(cAlias)->E5_PARCELA,"R",Val((cAlias)->E5_MOEDA),(cAlias)->E5_DATA,(cAlias)->A1_COD,(cAlias)->A1_LOJA)
			Else
				nVlrReten	:=	(cAlias)->E5_VRETPIS+(cAlias)->E5_VRETCOF+(cAlias)->E5_VRETCSL+(cAlias)->E5_VRETISS+(cAlias)->E5_VRETIRF
			Endif
		Endif
	Endif
	
	
	//Calculo do valor Total Recebido no Periodo: (- Juros e Multa) + Desconto    
    If !lBxCanc .And. !lBxPerPos .And. Iif(cOrigem=="SE1",(cAlias)->E5_DATA >= dDataDe .And. (cAlias)->E5_DATA <= dDataAte,.T.) 
		If lTransfere//Transfereicna
			nTotRec := A054PTit(dDataDe,dDataAte,(cAlias)->E6_FILDEB,(cAlias)->E1_PREFIXO,(cAlias)->DOC,(cAlias)->E1_PARCELA,(cAlias)->E1_CLIENTE, (cAlias)->E1_LOJA)
		Else // Sem transferência
			nTotRec	:=	(cAlias)->VALORBX - (Iif(cOrigem=="SE1",(cAlias)->E5_VLJUROS - (cAlias)->E5_VLMULTA + (cAlias)->E5_VLDESCO,0))
		EndIF
	Endif
	
	// Se for baixa PARCIAL, fazer validacao abaixo:	
	// Valor recebido + Abatimentos = Valor da Baixa
	// Faco essa validacao para que o percentual da baixa nao fique divergente, pois pode acontecer de baixar totalmente
	// mas devido as retencoes o percentual nao ser o correto
	// Por exemplo: VALORDOC=1000,00 / RETENCOES=50,00 / BAIXA=950,00
	// se nao somar as retencoes, o percentual da baixa ficaria 95%, porem na verdade eh 100%
	If ((nTotRec + nVlrReten) <> (cAlias)->VALOR)
		
		//Percentual do valor da baixa sobre o valor total do titulo
		nPercRec	:=	nTotRec / (cAlias)->VALOR
		
		//Calcula valores de retencao, usando a proporcao da baixa. Faz apenas se houver retencao na
		//Emissao (MV_BR10925 = 2), pois se realiza retencao na baixa, os valores da tabela SE5 ja estao corretos
		If cTpReten == "2"
	   		nVlrReten	:=	nVlrReten * nPercRec
	   	Endif
	Endif
   	//+abatimentos
   	nTotRec	:=	nTotRec + nVlrReten
	
	If cOrigem == "SE1"
		//A funcao Fa620Stat() verifica transferencia de titulos. Se o retorno for 2, significa que o titulo eh originado de
		//outra filial, portanto devo procurar a nota na filial de origem, atraves da funcao CkTranTit()
		If (nTranStat := Fa620Stat((cAlias)->R_E_C_N_O_)) == 2
			// CkTranTit() --> Retorna .T. se processou diferimento, faco loop para nao processar novamente
	 		If CkTranTit(cPrefixE1,cCmpB1Dif,cCmpA1Dif,nTotRec,cAlias,cRegime,cPerApur,@aColsCFAP,@aColsCFAC,@aColsCFBP,@aColsCFBC,dDataDe,aXFilial)
				(cAlias)->(DbSkip())
				Loop
			Endif
		Elseif nTranStat == 1
			(cAlias)->(DbSkip())
			Loop
		Endif
	Endif
 	
	//Se o titulo possui vinculo com nota fiscal, devo calcular proporcionalmente o valor do item com o valor
	//total do titulo financeiro. Utilizo todos os dados da tabela SFT (Aliquota, CST, Valor)
	DbSelectArea("SFT")
	If cOrigem == "SE1" .And. !Empty((cAlias)->NFISCAL)
	
		//Somatorio das parcelas do titulo, para calcular percentual real do registro que esta sendo processado
		If !Empty((cAlias)->E1_PARCELA)
			nTotTit 	:=	SumParcE1( (cAlias)->E1_FILIAL, (cAlias)->E1_CLIENTE, (cAlias)->E1_LOJA, (cAlias)->E1_PREFIXO, (cAlias)->DOC )
		Else
			nTotTit		:=	(cAlias)->VALOR
		Endif 
	
		cNtFiscal	:=	(cAlias)->NFISCAL
		cCSTPis		:=	(cAlias)->FT_CSTPIS
		cCSTCof		:=	(cAlias)->FT_CSTCOF
		
		If !cRegime $ "3/4"
			cTpReg		:=	cRegime
		Else
			If SPEDRegime(cRegime,cAlias,cAlias,cAlias) == "C"
				cTpReg		:=	"2"
			Else
				cTpReg		:=	"1"
			Endif
		Endif	 
		
		//Aliquotas - PIS e COFINS
		nAlqPis		:=	(cAlias)->FT_ALIQPIS	
		nAlqCof		:=	(cAlias)->FT_ALIQCOF
		
		//Valor total da venda do item
		nTotVend	:=	(cAlias)->FT_VALCONT
		
		//Percentual do valor deste item em relacao ao valor total do titulo
		nPercVlrNt	:=	((cAlias)->FT_VALCONT / nTotTit)
		nPercVlrNt	:= Iif(nPercVlrNt>1,1,nPercVlrNt)
		//Calculo do valor Total Recebido no Periodo com a proporcao sobre a nota fiscal
		nTotRec		:=	nTotRec * nPercVlrNt 
		
		//Calculo do valor Total Diferido no Periodo
		nTotDifer	:=	nTotVend - nTotRec
		
		cChvDoc	:=	(cAlias)->(NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ITEM)
		
	Else
	
		cCSTPis		:=	(cAlias)->CSTPIS
		cCSTCof		:=	(cAlias)->CSTCOF
		
		If !cRegime $ "3/4"
			cTpReg		:=	cRegime
		Else
			If 	(cAlias)->TPREG =="1"
				cTpReg := "2"
			Else 
			    cTpReg := "1"
			Endif
		Endif
				 
		//Aliquotas - PIS e COFINS
		nAlqPis		:=	(cAlias)->ALIQPIS
		nAlqCof		:=	(cAlias)->ALIQCOF
		
		//Valor total do titulo
		nTotVend	:=	(cAlias)->VALOR
		
		//Calculo do valor Total Diferido no Periodo
		nTotDifer	:=	((cAlias)->VALOR - nTotRec)
		
		cChvDoc	:=	Iif(cOrigem == "CF8",(cAlias)->DOC,(cAlias)->(DOC+E1_PREFIXO+E1_CLIENTE+E1_LOJA))
	
	Endif
	
	//Calcula valores da Contribuicao Diferida/Paga no periodo
	nPisDifer	:=	(nTotDifer * nAlqPis) / 100
	nCofDifer	:=	(nTotDifer * nAlqCof) / 100
	nPisPago	:=	(nTotRec * nAlqPis) / 100
	nCofPago	:=	(nTotRec * nAlqCof) / 100
	
	
	//Titulos emitidos no mesmo periodo do Processamento.
	//Serao gerados para a tabela CFA - Informacoes Adicionais de Diferimento (Registros M230 e M630)
	If cPerEmis == cPerApur
	    	    
		//aDocs -> utilizado para aglutinar os documentos, para que as tabelas do diferimento nao tenham valores duplicados
		//lNewDoc -> Indica se o documento esta sendo gravado pela primeira vez. Tratamento para nao duplicar valores
		If (nPos := aScan(aDocs,{|x| x[1]==cChvDoc})) == 0
			aAdd(aDocs,{})
			nPos := Len(aDocs)
			aAdd(aDocs[nPos],cChvDoc)					//CHAVE DO DOCUMENTO
			aAdd(aDocs[nPos],nTotVend)					//TOTAL VENDIDO
			aAdd(aDocs[nPos],nTotVend - nTotRec)		//TOTAL NAO RECEBIDO
			aAdd(aDocs[nPos],nTotDifer)					//TOTAL DIFERIDO
			aAdd(aDocs[nPos],nPisDifer)					//PIS DIFERIDO
			aAdd(aDocs[nPos],nCofDifer)					//COFINS DIFERIDO
			aAdd(aDocs[nPos],.T.)						//NOVO DOCUMENTO			
			aAdd(aDocs[nPos],cCodBCPIS)					//CÓDIGO CRÉDITO PIS
			aAdd(aDocs[nPos],nCredPisDf)				//CRÉDITO PIS DIFERIDO						
			aAdd(aDocs[nPos],cCodBCCOF)					//CÓDIGO CRÉDITO COFINS
			aAdd(aDocs[nPos],nCredCOFDf)				//CRÉDITO COFINS DIFERIDO			
		Else
			aDocs[nPos][3] -= nTotRec					//TOTAL NAO RECEBIDO
			aDocs[nPos][4] -= nTotRec					//TOTAL DIFERIDO
			aDocs[nPos][5] -= nPisPago					//PIS DIFERIDO
			aDocs[nPos][6] -= nCofPago					//COFINS DIFERIDO
			aDocs[nPos][7] := .F.						//NOVO DOCUMENTO
		Endif
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³aValores[1] -> Total Diferido	³
		//³aValores[2] -> Total Vendido     ³
		//³aValores[3] -> Total Recebido	³
		//³aValores[4] -> Aliquota PIS		³
		//³aValores[5] -> Aliquota COFINS	³
		//³aValores[6] -> PIS Diferido		³
		//³aValores[7] -> COFINS Diferido	³
		//³aValores[8] -> PIS Recolhido		³
		//³aValores[9] -> COFINS Recolhido	³
		//³aValores[10] -> Total N Recebido	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aValores	:=	{	aDocs[nPos][4],aDocs[nPos][2],nTotRec,nAlqPis,nAlqCof,;
							aDocs[nPos][5],aDocs[nPos][6],nPisPago,nCofPago,aDocs[nPos][3],;
							aDocs[nPos][9],"",aDocs[nPos][8],aDocs[nPos][10]}
							
		lNewDoc	:=	aDocs[nPos][7]
	   
		GrvInfDif(1,cAlias,cNtFiscal,cCSTPis,cCSTCof,aValores,cTpReg,cRegime,cPerApur,@aColsCFAP,@aColsCFAC,lNewDoc,cIndNatPJ,aXFilial,,lF0T,cOrigem,ObjF0T)
		
		//Aqui deverá gravar as informações na tabela F0T...verificar se é operação com documento fiscal, somente título ou CF8.
		IF lF0T
			ObjF0T:Clear()
			ObjF0T:SetValue("F0T_PER"		,dDataDe)
			ObjF0T:SetValue("F0T_FILAPU"	,cFilAnt)
			ObjF0T:SetValue("F0T_TIPO"		,'4') //Diferimento período atual
			IF cOrigem == "SE1"
				//Possui somente título ou  título + nota fiscal
				ObjF0T:SetValue("F0T_NUMNF"		,(cAlias)->NFISCAL)
				ObjF0T:SetValue("F0T_SER"		,(cAlias)->FT_SERIE)
				ObjF0T:SetValue("F0T_DTEMI"		,Iif(empty((cAlias)->FT_ENTRADA),(cAlias)->EMISSAO,(cAlias)->FT_ENTRADA)  )
				ObjF0T:SetValue("F0T_ITEM"		,(cAlias)->FT_ITEM)
				ObjF0T:SetValue("F0T_NUMTIT"	,(cAlias)->DOC)
				ObjF0T:SetValue("F0T_PREFIX"	,(cAlias)->E1_PREFIXO)
				ObjF0T:SetValue("F0T_PARC"		,(cAlias)->E1_PARCELA)		
						
			ElseIF cOrigem == "CF8"
				//Operações em Demais Documentos			
				ObjF0T:SetValue("F0T_DTEMI"		,(cAlias)->EMISSAO)
				ObjF0T:SetValue("F0T_IDCF8"		,(cAlias)->DOC)
			 
			EndIF
			ObjF0T:SetValue("F0T_VLCONT"	,aValores[2])
			ObjF0T:SetValue("F0T_VALREC"	,aValores[3])
			ObjF0T:SetValue("F0T_RECDIF"	,aValores[1])			
			ObjF0T:SetValue("F0T_VALPIS"	,aValores[6])
			ObjF0T:SetValue("F0T_VALCOF"	,aValores[7])
			ObjF0T:Grava()
		EndIF
						
	//Titulos emitidos em periodo anterior ao Processamento.
	//Serao gerados para a tabela CFB - Contribuicao Diferida em Periodos Anteriores (Registros M300 e M700)
	Elseif (cAlias)->EMISSAO < dDataDe
		
		//Buscar informações na CFA considerando CNPJ, CODCON, TRIB e período de emissão.
										
		aValores	:=	{nTotDifer,nTotVend,nTotRec,nAlqPis,nAlqCof,nPisDifer,nCofDifer,nPisPago,nCofPago,nCredPisDf,nCredCOFDf,cNatCre}
	
		GrvInfDif(2,cAlias,cNtFiscal,cCSTPis,cCSTCof,aValores,cTpReg,cRegime,cPerApur,@aColsCFBP,@aColsCFBC,,cIndNatPJ,aXFilial,nPercRec,lF0T,cOrigem,ObjF0T)
			
		IF lF0T
			ObjF0T:Clear()
			ObjF0T:SetValue("F0T_PER"		,dDataDe)
			ObjF0T:SetValue("F0T_FILAPU"	,cFilAnt)
			ObjF0T:SetValue("F0T_TIPO"		,'5') //Diferimento período anterior
			IF cOrigem == "SE1"
				//Possui somente título ou  título + nota fiscal
				ObjF0T:SetValue("F0T_NUMNF"		,(cAlias)->NFISCAL)
				ObjF0T:SetValue("F0T_SER"		,(cAlias)->FT_SERIE)
				ObjF0T:SetValue("F0T_DTEMI"		,Iif(empty((cAlias)->FT_ENTRADA),(cAlias)->EMISSAO,(cAlias)->FT_ENTRADA)  )
				ObjF0T:SetValue("F0T_ITEM"		,(cAlias)->FT_ITEM)
				ObjF0T:SetValue("F0T_NUMTIT"	,(cAlias)->DOC)
				ObjF0T:SetValue("F0T_PREFIX"	,(cAlias)->E1_PREFIXO)
				ObjF0T:SetValue("F0T_PARC"		,(cAlias)->E1_PARCELA)		
						
			ElseIF cOrigem == "CF8"
				//Operações em Demais Documentos			
				ObjF0T:SetValue("F0T_DTEMI"		,(cAlias)->EMISSAO)
				ObjF0T:SetValue("F0T_IDCF8"		,(cAlias)->DOC)
			 
			EndIF
			ObjF0T:SetValue("F0T_DTRECB"	,(cAlias)->DATABX)
			ObjF0T:SetValue("F0T_VALREC"	,nTotRec)
			ObjF0T:SetValue("F0T_VALPIS"	,nPisPago)
			ObjF0T:SetValue("F0T_VALCOF"	,nCofPago)
			ObjF0T:Grava()
		EndIF
		
	Endif
	
	nRegsProc	+=	1	
	(cAlias)->(DbSkip())
Enddo

(DbCloseArea())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CkTranTit
Funcao que processa os titulos que foram transferidos entre filiais e verifica 
se existe nota fiscal relacionada ao titulo na filial de origem.

	
@param	cPrefixE1 -> Conteudo do parametro MV_1DUPREF
		cCmpB1Dif -> Campo da tabela SB1 que indica Diferimento de Org. Publico
		cCmpA1Dif -> Campo da tabela SA1 que indica Diferimento de Org. Publico
		nTotRecE5 -> Total Recebido no registro de baixa
		cAliasOri -> Alias da query de origem
		cRegime -> Regime selecionado nas perguntas da rotina (1,2,3)
		cPerApur -> Periodo do processamento
		aColsCFAP -> Informacoes que serao mostradas na Dialog
		aColsCFAC -> Informacoes que serao mostradas na Dialog
		aColsCFBP -> Informacoes que serao mostradas na Dialog
		aColsCFBC -> Informacoes que serao mostradas na Dialog
		dDataDe -> Data Inicial de Processamento
					
@return	lAchouNota -> 	Indica que foi encontrada nota na filial de origem, portanto
						aborta processamento do registro no retorno desta funcao (loop)		
		
@author Luccas Curcio
@since 10/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function CkTranTit(cPrefixE1,cCmpB1Dif,cCmpA1Dif,nTotRecE5,cAliasOri,cRegime,cPerApur,aColsCFAP,aColsCFAC,aColsCFBP,aColsCFBC,dDataDe,aXFilial)
Local	lNewDoc	:=	.F.
Local	lAchouNota	:=	.F.
Local	cSelect	:=	""
Local	cFrom		:=	""
Local	cWhere		:=	""
Local	cAliasSFT	:=	"SFT"
Local	cAliasSB1	:=	"SB1"
Local	cAliasSA1	:=	"SA1"
Local	cAliasSF4	:=	"SF4"
Local	cAliasSF2	:=	"SF2"
Local	cTpReg		:=	""
Local	cFilOrig	:=	SE6->E6_FILORIG
Local	cChvSF		:=	""	
Local	nPercVlrNt	:=	0
Local	nTotDifer	:=	0
Local	nPisDifer	:=	0
Local	nCofDifer	:=	0
Local	nPisPago	:=	0
Local	nCofPago	:=	0
Local	nTotRec		:=	0
Local	nPos		:=	0
Local	nMVM996TPR	:=	GetNewPar("MV_M996TPR",1)
Local	aValores	:=	{}
Local	aDocs		:=	{}
Default aXFilial	:= {}

//Verifica conteudo do paramentro na filial de origem
cPrefixE1 := ChkX6Orig(cFilOrig,"MV_1DUPREF",cPrefixE1)

//Se o conteudo do parametro MV_1DUPREF for diferente do default(SF2->F2_SERIE), preciso fazer uma query a partir da
//tabela SF2, utilizando o campo F2_PREFIXO como relacao do titulo e nota fiscal, pois o conteudo dos campo E1_PREFIXO,
//E6_PREFIXO e F2_SERIE estara diferente.
If cPrefixE1<>"SF2->F2_SERIE"
	
	//Select na nota fiscal pela filial de origem
	cSelect	+=	"%SFT.FT_FILIAL,	SFT.FT_TIPOMOV,	SFT.FT_NFISCAL,	SFT.FT_VALCONT,	SFT.FT_ALIQPIS,	SFT.FT_ALIQCOF,	SFT.FT_CSTPIS, "
	cSelect	+=	"SFT.FT_CSTCOF,		SFT.FT_VALPIS,	SFT.FT_VALCOF, 	SFT.FT_BASEPIS,	SFT.FT_BASECOF,	SFT.FT_SERIE,	SFT.FT_CLIEFOR, "
	cSelect	+=	"SFT.FT_LOJA,		SFT.FT_ITEM, "
	
	cSelect	+=	"SF2.F2_PREFIXO,"
	
	cSelect	+=	"SF4.F4_TPREG, "
	
	cSelect	+=	"SD2.D2_PROJPMS, "	
	
	cSelect	+=	"SB1.B1_COD,		SB1.B1_PPIS,	SB1.B1_PCOFINS,	SB1.B1_PCSLL,	SA1.A1_COD,	SA1.A1_LOJA" 
	
	cSelect	+=	", SB1.B1_TPREG"

	If SB1->(FieldPos(cCmpB1Dif)) > 0
		cSelect	+=	", SB1."+cCmpB1Dif+"" 
	Endif
	
	cSelect	+=	", SA1.A1_TPREG"
		
	If SA1->(FieldPos(cCmpA1Dif)) > 0
		cSelect	+=	", SA1."+cCmpA1Dif+""
	Endif
			
	cSelect	+=	"%"
	
	//From tabela SF2
	cFrom	:=	"%"+RetSqlName("SF2")+" SF2 "
	// JOIN SFT
	cFrom	+=	"LEFT JOIN "+RetSqlName("SFT")+" SFT ON SFT.FT_FILIAL='"+Iif(!Empty(xFilial("SFT")),cFilOrig,xFilial("SFT"))+"' AND SFT.FT_NFISCAL=SF2.F2_DOC AND SFT.FT_SERIE=SF2.F2_SERIE AND SFT.FT_CLIEFOR=SF2.F2_CLIENT AND SFT.FT_LOJA=SF2.F2_LOJA AND SFT.D_E_L_E_T_ = '' " 
	//JOIN SD2
	cFrom	+=	"LEFT JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL='"+Iif(!Empty(xFilial("SD2")),cFilOrig,xFilial("SD2"))+"' AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_ITEM=SFT.FT_ITEM  AND SD2.D_E_L_E_T_='' "
	//JOIN SF4
	cFrom	+=	"LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+Iif(!Empty(xFilial("SF4")),cFilOrig,xFilial("SF4"))+"' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_='' "
	
	//JOIN SB1
	cFrom	+=	"LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+Iif(!Empty(xFilial("SB1")),cFilOrig,xFilial("SB1"))+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND "
	cFrom	+=	"SB1.D_E_L_E_T_ = '' "
	
	//JOIN SA1
	cFrom	+=	"LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+Iif(!Empty(xFilial("SA1")),cFilOrig,xFilial("SA1"))+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND SA1.A1_LOJA=SFT.FT_LOJA AND "
		
	cFrom	+=	"SA1.D_E_L_E_T_ = ''%"
	cWhere	:=	"%SF2.F2_FILIAL	=	'"+SE6->E6_FILORIG+"'		AND "
	cWhere	+=	"SF2.F2_DOC		=	'"+SE6->E6_NUM+"' 			AND "
	cWhere	+=	"SF2.F2_PREFIXO	=	'"+SE6->E6_PREFIXO+"'		AND " 
	//cWhere	+=	"SF2.F2_CLIENTE	=	'"+SE6->E6_CLIENTE+"'		AND "  
	cWhere	+=	"SF2.F2_LOJA	=	'"+SE6->E6_LOJA+"'"
	
	If SB1->(FieldPos(cCmpB1Dif)) > 0
		cWhere	+=	" AND SB1."+cCmpB1Dif+"='1' "
	Endif
	
	If SA1->(FieldPos(cCmpA1Dif)) > 0
		cWhere	+=	" AND SA1."+cCmpA1Dif+"='1' "
	Endif
	cWhere	+= "%"
	
	cAlias := SPEDGetAlias("SF2")
	BeginSql Alias cAlias
				
		SELECT 
			%Exp:cSelect%
	
		FROM 
			%Exp:cFrom%
	
		WHERE 
			%Exp:cWhere%
	EndSql
	
	If !(cAlias)->(Eof())
		lAchouNota	:=	.T.
		cAliasSFT	:=	cAlias
		
		cAliasSB1	:=	cAlias
		cAliasSA1	:=	cAlias
		cAliasSF4	:=	cAlias
		cAliasSF2	:=	cAlias
	Endif
	cChvSF	:=cFilOrig+"S"+SE6->E6_PREFIXO+SE6->E6_NUM //+SE6->E6_CLIENTE+SE6->E6_LOJA

//Se utilizar o default para o parametro MV_1DUPREF, utilizo Seek para acelerar o processamento
Else
	DbSelectArea("SFT")
	SFT->(DbSetOrder(1))
	
	cChvSF	:=cFilOrig+"S"+SE6->E6_PREFIXO+SE6->E6_NUM+SE6->E6_CLIENTE+SE6->E6_LOJA	
	
	If SFT->(MsSeek(cChvSF))
		
		SPEDSeek("SF2",2,Iif(!Empty(xFilial("SF2")),cFilOrig,xFilial("SF2"))+SFT->(FT_CLIEFOR+FT_LOJA+FT_NFISCAL+FT_SERIE))
		SPEDSeek("SB1",1,Iif(!Empty(xFilial("SB1")),cFilOrig,xFilial("SB1"))+SFT->FT_PRODUTO)
		
		//Verifica conteudo do parametro MV_M996TPR para que posicione as tabelas abaixo apenas se necessario
		If nMVM996TPR == 1
			SPEDSeek("SD2",1,Iif(!Empty(xFilial("SD2")),cFilOrig,xFilial("SD2"))+SFT->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_PRODUTO+FT_ITEM))
			SPEDSeek("SF4",1,Iif(!Empty(xFilial("SF4")),cFilOrig,xFilial("SF4"))+SD2->D2_TES)
			
		Elseif nMVM996TPR == 3 
			SPEDSeek("SA1",1,Iif(!Empty(xFilial("SA1")),cFilOrig,xFilial("SA1"))+SFT->(FT_CLIEFOR+FT_LOJA))
		Endif
		
		lAchouNota	:=	.T.
	Endif
Endif

If lAchouNota

	//Se encontrou nota fiscal, usa os valores da SFT e o retorno da funcao eh TRUE, para que nao continue o processamento
	//Se nao encontrar nota fiscal, o retorno da funcao eh FALSE e mantem o processamento atraves do titulo financeiro
	//Do While !(cAliasSFT)->(Eof()) .And. (cAliasSFT)->(FT_FILIAL+FT_TIPOMOV)+(cAliasSF2)->F2_PREFIXO+(cAliasSFT)->(FT_NFISCAL+FT_CLIEFOR+FT_LOJA) == cChvSF
	Do While !(cAliasSFT)->(Eof()) .And. (cAliasSFT)->(FT_FILIAL+FT_TIPOMOV)+(cAliasSF2)->F2_PREFIXO+(cAliasSFT)->FT_NFISCAL == cChvSF
	
		If !Empty((cAliasSFT)->FT_NFISCAL) .And. Empty((cAliasSB1)->B1_COD)
			(cAliasSFT)->(DbSkip())
			Loop
		Endif

		If !cRegime $ "3/4"
			cTpReg		:=	cRegime
		Else
			//TODO analisar como substituir a função SPEDREGIME
			If SPEDRegime(cRegime,cAliasSF4,cAliasSB1,cAliasSA1,nMVM996TPR) == "C"
				cTpReg		:=	"2"
			Else
				cTpReg		:=	"1"
			Endif
		Endif	 
		
		//Valor total da venda do item
		nTotVend	:=	(cAliasSFT)->FT_VALCONT
		
		//Percentual do valor deste item em relacao ao valor total do titulo
		nPercVlrNt	:=	(cAliasSFT)->FT_VALCONT / (cAliasOri)->VALOR
		
		//Calculo do valor Total Recebido no Periodo com a proporcao sobre a nota fiscal
		nTotRec		:=	nTotRecE5 * nPercVlrNt 
		
		//Calculo do valor Total Diferido no Periodo
		nTotDifer	:=	((cAliasOri)->VALOR - nTotRec)

		nPisDifer	:=	(nTotDifer * (cAliasSFT)->FT_ALIQPIS) / 100
		nCofDifer	:=	(nTotDifer * (cAliasSFT)->FT_ALIQCOF) / 100
		nPisPago	:=	(nTotRec * (cAliasSFT)->FT_ALIQPIS) / 100
		nCofPago	:=	(nTotRec * (cAliasSFT)->FT_ALIQCOF) / 100
		
		//Buscar aqui os valores de crpedito de PIS e COFINS que fora diferidos e adicionar do aDocs
		// depois adicionar no avalores
		
		
		//Titulos emitidos no mesmo periodo do Processamento.
		//Serao gerados para a tabela CFA - Informacoes Adicionais de Diferimento (Registros M230 e M630)
		If Substr(DTOS((cAliasOri)->EMISSAO),5,2)+Substr(DTOS((cAliasOri)->EMISSAO),1,4) == cPerApur
		
			//aDocs -> utilizado para aglutinar os documentos, para que as tabelas do diferimento nao tenham valores duplicados
			//lNewDoc -> Indica se o documento esta sendo gravado pela primeira vez. Tratamento para nao duplicar valores
			If (nPos := aScan(aDocs,{|x| x[1]==(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ITEM)})) == 0
				aAdd(aDocs,{})
				nPos := Len(aDocs)
				aAdd(aDocs[nPos],(cAliasSFT)->(FT_NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ITEM))	//CHAVE DO DOCUMENTO
				aAdd(aDocs[nPos],nTotVend)													//TOTAL VENDIDO
				aAdd(aDocs[nPos],nTotVend - nTotRec)										//TOTAL NAO RECEBIDO
				aAdd(aDocs[nPos],nTotDifer)													//TOTAL DIFERIDO
				aAdd(aDocs[nPos],nPisDifer)													//PIS DIFERIDO
				aAdd(aDocs[nPos],nCofDifer)													//COFINS DIFERIDO
				aAdd(aDocs[nPos],.T.)														//NOVO DOCUMENTO
			Else
				aDocs[nPos][3] -= nTotRec													//TOTAL NAO RECEBIDO
				aDocs[nPos][4] -= nTotRec													//TOTAL DIFERIDO
				aDocs[nPos][5] -= nPisPago													//PIS DIFERIDO
				aDocs[nPos][6] -= nCofPago													//COFINS DIFERIDO
				aDocs[nPos][7] := .F.														//NOVO DOCUMENTO
			Endif
		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³aValores[1] -> Total Diferido	³
			//³aValores[2] -> Total Vendido     ³
			//³aValores[3] -> Total Recebido	³
			//³aValores[4] -> Aliquota PIS		³
			//³aValores[5] -> Aliquota COFINS	³
			//³aValores[6] -> PIS Diferido		³
			//³aValores[7] -> COFINS Diferido	³
			//³aValores[8] -> PIS Recolhido		³
			//³aValores[9] -> COFINS Recolhido	³
			//³aValores[10] -> Total N Recebido	³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
			aValores	:=	{	aDocs[nPos][4],aDocs[nPos][2],nTotRec,(cAliasSFT)->FT_ALIQPIS,(cAliasSFT)->FT_ALIQCOF,;
								aDocs[nPos][5],aDocs[nPos][6],nPisPago,nCofPago,aDocs[nPos][3],;
								0,"","",""}
								
			lNewDoc	:=	aDocs[nPos][7]
		
		   
			GrvInfDif(1,cAliasOri,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CSTPIS,(cAliasSFT)->FT_CSTCOF,aValores,cTpReg,cRegime,cPerApur,@aColsCFAP,@aColsCFAC,lNewDoc,cIndNatPJ,aXFilial)
							
		//Titulos emitidos em periodo anterior ao Processamento.
		//Serao gerados para a tabela CFB - Contribuicao Diferida em Periodos Anteriores (Registros M300 e M700)
		Elseif (cAliasOri)->EMISSAO < dDataDe
		
			aValores	:=	{nTotDifer,nTotVend,nTotRec,(cAliasSFT)->FT_ALIQPIS,(cAliasSFT)->FT_ALIQCOF,nPisDifer,nCofDifer,nPisPago,nCofPago,0,0,"","",""}

			GrvInfDif(2,cAliasOri,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CSTPIS,(cAliasSFT)->FT_CSTCOF,aValores,cTpReg,cRegime,cPerApur,@aColsCFBP,@aColsCFBC,,cIndNatPJ,aXFilial)
		Endif
		
		(cAliasSFT)->(DbSkip())
	Enddo
Endif

//So fecha a tabela se for processamento da query
If cPrefixE1<>"SF2->F2_SERIE"
	(cAliasSFT)->(DbCloseArea())
Endif

Return lAchouNota

//-------------------------------------------------------------------
/*/{Protheus.doc} ChkX6Orig
Funcao que busca conteudo de determinado paramentro na filial de origem

	
@param	cFilOrig -> Filial de Origem
		cParam -> Parametro a ser verificado
		cContAtu -> Conteudo utilizado na filial corrente (default)
					
@return	cConteud -> Conteudo do parametro na filial de origem, se existir
					ou o conteudo default, passado como parametro na funcao.
		
@author Luccas Curcio
@since 10/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ChkX6Orig(cFilOrig,cParam,cContAtu)
Local	cConteud	:=	cContAtu

If SX6->(MsSeek(cFilOrig+cParam))
	cConteud	:=	Alltrim(SX6->X6_CONTEUD)
Endif

Return cConteud


//-------------------------------------------------------------------
/*/{Protheus.doc} GrvInfDif
Funcao que grava as tabelas relacionadas ao Diferimento. Passar o primeiro parametro, 
indicando qual o tipo de registro: 1 - Diferimento de emissao no proprio Periodo. 2 - Diferimento de Periodos anteriores
	
@param	nOpc -> Opcao de processamento (1 - Diferimento de emissao no proprio 
				Periodo. 2 - Diferimento de Periodos anteriores)
		cAlias -> Alias da query que esta sendo processada
		cNtFiscal -> Numero da nota fiscal, se existir
		cCSTPis -> CST de Pis
		cCSTCof -> CST de Cofins
		aValores -> Valores que serao gravados
		cTpReg -> Tipo do regime do documento
		cRegime -> Regime selecionado nas perguntas da rotina
		cPerApur -> Periodo do processamento
		aColsPis -> Valores de PIS que serao apresentados na tela
		aColsCof -> Valores de Cofins que serao apresentados na tela
		lNewDoc -> 	Indica se eh um novo documento, ou documento ja foi processado 1 vez
					afim de evitar duplicidade de valores
		cIndNatPJ-> Indicador da Natureza da Pessoa Juridica
					
@return	Nil
		
@author Luccas Curcio
@since 10/09/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function GrvInfDif(nOpc,cAlias,cNtFiscal,cCSTPis,cCSTCof,aValores,cTpReg,cRegime,cPerApur,aColsPis,aColsCof,lNewDoc,cIndNatPJ,aXFilial,nPercRec,lF0T,cOrigem,ObjF0T)
Local	cCNPJ		:=	""
Local	cCodCont	:=	""
Local	cChvCFA		:=	""
Local	cDtPgto		:=	""
Local	cChvCFB		:=	""
Local	cPerDif		:=	""
Local	nPos		:=	0   
Local   lScp		:= GetNewPar("MV_FILSCP",.F.)
Local   cFilCFA		:= BuscaFil(aXFilial,'CFA')
Local   cFilCFB		:= BuscaFil(aXFilial,'CFV')
Local 	aRetCrdDif	:= {}
Local 	nPosCrd		:= 0
Local   lNewProc	:= ISA001NDIF()  
Default	lNewDoc		:=	.F.	
DEFAULT nPercRec	:= 0
DEFAULT lF0T		:= .F.
DEFAULT cOrigem		:= ''
DEFAULT ObjF0T		:= NIL
If cIndNatPJ$"03#04#05"
	lScp:= .F.
EndIf



//Registro M230 e M630 - Tabela CFA
If nOpc == 1

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³aValores[1] -> Total Diferido			  ³
	//³aValores[2] -> Total Vendido     		  ³
	//³aValores[3] -> Total Recebido			  ³
	//³aValores[4] -> Aliquota PIS				  ³
	//³aValores[5] -> Aliquota COFINS			  ³
	//³aValores[6] -> PIS Diferido				  ³
	//³aValores[7] -> COFINS Diferido			  ³
	//³aValores[8] -> PIS Recolhido				  ³
	//³aValores[9] -> COFINS Recolhido			  ³
	//³aValores[10] -> Total N Recebido	          ³
	//³aValores[11] -> Crédito de PIS Diferido	  ³
	//³aValores[12] -> Crédito de COFINS Diferido ³
	//³aValores[13] -> Código do Crédito de PIS	  ³
	//³aValores[14] -> Código do Crédito da COFINS³
	//³aValores[15] -> Natureza do Credito        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	cCNPJ		:=	(cAlias)->CNPJCLI
	
	//Registro para Contribuicao de PIS 
	cCodCont	:=	SPDCodCont("PIS",Empty(cNtFiscal),cCSTPis,aValores[4],cTpReg=="2",, Iif(cRegime $ '4/3' ,'3' ,cRegime ) ,lScp)
	cChvCFA		:=	cFilCFA+cPerApur+"PIS"+cCodCont+cCNPJ+str(aValores[4],5,2)
	
	If SPEDSeek("CFA",1,cChvCFA)
		RecLock("CFA",.F.)
		
		CFA->CFA_CONREC	+=	aValores[8]
		CFA->CFA_VLRREC	+=	aValores[3]
		If lNewDoc
			CFA->CFA_CONDIF	+=	aValores[6]
			CFA->CFA_TOTVEN	+=	aValores[2]
			CFA->CFA_TOTDIF	+=	aValores[1]
			CFA->CFA_VLNREC	+=	aValores[10]
		Else
			CFA->CFA_CONDIF	-=	aValores[8]
			CFA->CFA_TOTDIF	-=	aValores[3]
			CFA->CFA_VLNREC	-=	aValores[3]
		Endif
		MsUnLock()
	Else
		RecLock("CFA",.T.)
		CFA->CFA_FILIAL	:=	cFilCFA
		CFA->CFA_CODCON	:=	cCodCont
		CFA->CFA_TPCON	:=	"PIS"
		CFA->CFA_CNPJ	:=	cCNPJ
		CFA->CFA_TOTVEN	:=	aValores[2]
		CFA->CFA_TOTDIF	:=	aValores[1]
		CFA->CFA_CONDIF	:=	aValores[6]
		CFA->CFA_CREDIF	:=	aValores[11]	
		CFA->CFA_CODCRE	:=	aValores[13] 
		CFA->CFA_ALIQ	:=	aValores[4]
		CFA->CFA_CONREC	:=	aValores[8]
		CFA->CFA_VLRREC	:=	aValores[3]
		CFA->CFA_VLNREC	:=	aValores[10]
		CFA->CFA_PERAPU	:=	cPerApur
		IF lNewProc 
			CFA->CFA_CONSOL	:=	'2' //Gravo indicando que não é consolidado, pois veio da movimentação
		EndIF
		MsUnLock()
	Endif
	
	//Adiciona conteudo para aColsPis, onde as informacoes serao mostradas na Dialog apos o processamento
	If (nPos := aScan(aColsPis, {|x| x[1] == cCNPJ .And. x[2]==cCodCont .And. x[4]==aValores[4]})) > 0
		
		If lNewDoc
			aColsPis[nPos][3]	+=	aValores[2]
			aColsPis[nPos][5]	+=	aValores[1]
			aColsPis[nPos][6]	+=	aValores[6]	
		Else
			aColsPis[nPos][5]	-=	aValores[3]
			aColsPis[nPos][6]	-=	aValores[8]
		Endif
	
	Else
		aAdd(aColsPis,{cCNPJ,;
					cCodCont,;
					aValores[2],;
					aValores[4],;
					aValores[1],;
					aValores[6],;
					aValores[11],;
					aValores[13],;
					.F.})
	Endif
	
	//Registro para Contribuicao de COFINS 
	cCodCont	:=	SPDCodCont("COF",Empty(cNtFiscal),cCSTCof,aValores[5],cTpReg=="2",,Iif(cRegime $ '3/4' ,'3' ,cRegime ),lScp)
	cChvCFA		:=	cFilCFA+cPerApur+"COF"+cCodCont+cCNPJ+str(aValores[5],5,2)
	
	If SPEDSeek("CFA",1,cChvCFA)
		RecLock("CFA",.F.)
		
		CFA->CFA_CONREC	+=	aValores[9]
		CFA->CFA_VLRREC	+=	aValores[3]
		If lNewDoc
			CFA->CFA_CONDIF	+=	aValores[7]
			CFA->CFA_TOTVEN	+=	aValores[2]
			CFA->CFA_TOTDIF	+=	aValores[1]
			CFA->CFA_VLNREC	+=	aValores[10]
		Else
			CFA->CFA_CONDIF	-=	aValores[9]
			CFA->CFA_TOTDIF	-=	aValores[3]
			CFA->CFA_VLNREC	-=	aValores[3]
		Endif
	Else
		RecLock("CFA",.T.)
		CFA->CFA_FILIAL	:=	cFilCFA
		CFA->CFA_CODCON	:=	cCodCont
		CFA->CFA_TPCON	:=	"COF"
		CFA->CFA_CNPJ	:=	cCNPJ
		CFA->CFA_TOTVEN	:=	aValores[2]
		CFA->CFA_TOTDIF	:=	aValores[1]
		CFA->CFA_CONDIF	:=	aValores[7]
		CFA->CFA_CREDIF	:=	0 //aValores[12]
		CFA->CFA_CODCRE	:=	aValores[14]
		CFA->CFA_ALIQ	:=	aValores[5]
		CFA->CFA_CONREC	:=	aValores[9]
		CFA->CFA_VLRREC	:=	aValores[3]
		CFA->CFA_VLNREC	:=	aValores[10]
		CFA->CFA_PERAPU	:=	cPerApur
		IF lNewProc
			CFA->CFA_CONSOL	:=	'2' //Gravo indicando que não é consolidado, pois veio da movimentação
		EndIF		
		MsUnLock()
	Endif	
	
	//Adiciona conteudo para aColsCof, onde as informacoes serao mostradas na Dialog apos o processamento
	If (nPos := aScan(aColsCof, {|x| x[1] == cCNPJ .And. x[2]==cCodCont .And. x[4]==aValores[5]})) > 0
		
		If lNewDoc
			aColsCof[nPos][3]	+=	aValores[2]
			aColsCof[nPos][5]	+=	aValores[1]
			aColsCof[nPos][6]	+=	aValores[7]	
		Else
			aColsCof[nPos][5]	-=	aValores[3]
			aColsCof[nPos][6]	-=	aValores[9]
		Endif	
	
	Else
		aAdd(aColsCof,{cCNPJ,;
					cCodCont,;
					aValores[2],;
					aValores[5],;
					aValores[1],;
					aValores[7],;
					aValores[12],;
					aValores[14],;
					.F.})
	Endif
//Registro M300 e M700 - Tabela CFB
Else

	
	cDtPgto		:=	DTOS((cAlias)->DATABX)
	cPerDif		:=	Substr(DTOS((cAlias)->EMISSAO),5,2)+Substr(DTOS((cAlias)->EMISSAO),1,4)	
	//Registro para Contribuicao de PIS 
	cCodCont	:=	SPDCodCont("PIS",Empty(cNtFiscal),cCSTPis,aValores[4],cTpReg=="2",,Iif(cRegime $ '3/4' ,'3' ,cRegime ),lScp)
			
	IF lNewProc
		nPosCrd		:= 0	
		aRetCrdDif	:= CrdDifAnt(cFilCFA,cPerDif,"PIS",cCodCont,(cAlias)->CNPJCLI,aValores[4], nPercRec)
	EndIF
	
	If Len(aRetCrdDif) == 0
		cChvCFB		:=	cFilCFB+cPerApur+"PIS"+cCodCont+cPerDif+cDtPgto+str(aValores[4],5,2)+'   2'
		If SPEDSeek("CFB",1,cChvCFB)
			RecLock("CFB",.F.)
			CFB->CFB_VLRREC	+=	aValores[3]
			CFB->CFB_CONREC	+=	aValores[8]
			CFB->CFB_CREDES	+=	0		
			MsUnLock()
		Else
			RecLock("CFB",.T.)
			CFB->CFB_FILIAL	:=	cFilCFB
			CFB->CFB_CODCON	:=	cCodCont
			CFB->CFB_TPCON	:=	"PIS"
			CFB->CFB_VLRREC	:=	aValores[3]
			CFB->CFB_CONREC	:=	aValores[8]
			CFB->CFB_PERDIF	:=	cPerDif
			CFB->CFB_DTPGTO	:=	STOD(cDtPgto)
			CFB->CFB_NATCRE	:=	''
			CFB->CFB_CREDES	:=	0
			CFB->CFB_PERAPU	:=	cPerApur
			CFB->CFB_ALIQ	:=	aValores[4]
			IF lNewProc
				CFB->CFB_CONSOL	:=	'2'
			EndIF
			MsUnLock()
		Endif
	Else
		
		For nPosCrd	:= 1 to len(aRetCrdDif)
			cChvCFB		:=	cFilCFB+cPerApur+"PIS"+cCodCont+cPerDif+cDtPgto+str(aValores[4],5,2)+aRetCrdDif[nPosCrd][1]+'2'
			If SPEDSeek("CFB",1,cChvCFB)
				RecLock("CFB",.F.)
				CFB->CFB_VLRREC	+=	Round(aValores[3] * aRetCrdDif[nPosCrd][3] / 100,2)
				CFB->CFB_CONREC	+=	Round(aValores[8] * aRetCrdDif[nPosCrd][3] / 100,2)
				CFB->CFB_CREDES	+=	aRetCrdDif[nPosCrd][2]		
				MsUnLock()
			Else
				RecLock("CFB",.T.)
				CFB->CFB_FILIAL	:=	cFilCFB
				CFB->CFB_CODCON	:=	cCodCont
				CFB->CFB_TPCON	:=	"PIS"
				CFB->CFB_DTPGTO	:=	STOD(cDtPgto)
				CFB->CFB_PERDIF	:=	cPerDif
				CFB->CFB_NATCRE	:=	aRetCrdDif[nPosCrd][1]
				CFB->CFB_PERAPU	:=	cPerApur
				CFB->CFB_ALIQ	:=	aValores[4]
				CFB->CFB_CREDES	:=	aRetCrdDif[nPosCrd][2]
				
				CFB->CFB_VLRREC	:=	Round(aValores[3] * aRetCrdDif[nPosCrd][3] / 100,2)
				CFB->CFB_CONREC	:=	Round(aValores[8] * aRetCrdDif[nPosCrd][3] / 100,2)

				IF lNewProc
					CFB->CFB_CONSOL	:=	'2'
				EndIF
									
				MsUnLock()
			Endif
			
			//Gravat F0T com opção A

			IF lF0T
				ObjF0T:Clear()
				ObjF0T:SetValue("F0T_FILIAL"	,cFilCFB)
				ObjF0T:SetValue("F0T_PER"		,firstday(STOD(cDtPgto)))
				ObjF0T:SetValue("F0T_FILAPU"	,cFilAnt)
				ObjF0T:SetValue("F0T_TIPO"		,'A') //Diferimento de créditos de PIS de período anterior
				ObjF0T:SetValue("F0T_DTEMI"		,STOD(cDtPgto) )
				IF cOrigem == "SE1"
					//Possui somente título ou  título + nota fiscal
					ObjF0T:SetValue("F0T_NUMNF"		,(cAlias)->NFISCAL)
					ObjF0T:SetValue("F0T_SER"		,(cAlias)->FT_SERIE)
					
					ObjF0T:SetValue("F0T_ITEM"		,(cAlias)->FT_ITEM)
					ObjF0T:SetValue("F0T_NUMTIT"	,(cAlias)->DOC)
					ObjF0T:SetValue("F0T_PREFIX"	,(cAlias)->E1_PREFIXO)
					ObjF0T:SetValue("F0T_PARC"		,(cAlias)->E1_PARCELA)		
							
				ElseIF cOrigem == "CF8"
					//Operações em Demais Documentos
					ObjF0T:SetValue("F0T_IDCF8"		,(cAlias)->DOC)
				 
				EndIF
				
				ObjF0T:SetValue("F0T_PERREC"	,nPercRec * 100) //Percentual recebido
				ObjF0T:SetValue("F0T_MODELO"	,aRetCrdDif[nPosCrd][1]) //Natureza do crédito
				ObjF0T:SetValue("F0T_BASPIS"	,aRetCrdDif[nPosCrd][4]) //VAlor de PIS diferido anteriormente
				ObjF0T:SetValue("F0T_VALPIS"	,aRetCrdDif[nPosCrd][2]) //VAlor de PIS a descontar no período atual
				ObjF0T:Grava()				
							
			EndIF			
		
		Next nPosCrd
	
	EndIF
	
	//Adiciona conteudo para aColsPis, onde as informacoes serao mostradas na Dialog apos o processamento
	If (nPos := aScan(aColsPis, {|x| x[1]==cCodCont .And. x[3]==aValores[4] .And. x[4]==aValores[12] .And. x[6]==cPerDif .And. x[7]==STOD(cDtPgto)})) > 0
	
		aColsPis[nPos][2]	+=	aValores[8]
		aColsPis[nPos][5]	+=	aValores[10]		
	
	Else
		aAdd(aColsPis,{cCodCont,;
					aValores[8],;
					aValores[4],;
					aValores[12],;
					aValores[10],;
					cPerDif,;
					STOD(cDtPgto),;
					.F.})
	Endif
	
	//Registro para Contribuicao de COFINS 
	cCodCont	:=	SPDCodCont("COF",Empty(cNtFiscal),cCSTCof,aValores[5],cTpReg=="2",,Iif(cRegime $ '3/4' ,'3' ,cRegime ),lScp)
	
	IF lNewProc
		nPosCrd		:= 0	
		aRetCrdDif	:= CrdDifAnt(cFilCFA,cPerDif,"COF",cCodCont,(cAlias)->CNPJCLI,aValores[5], nPercRec)
	EndiF
	
	If Len(aRetCrdDif) == 0
		cChvCFB		:=	cFilCFB+cPerApur+"COF"+cCodCont+cPerDif+cDtPgto+str(aValores[5],5,2)+'   2'
		If SPEDSeek("CFB",1,cChvCFB)
			RecLock("CFB",.F.)
			CFB->CFB_VLRREC	+=	aValores[3]
			CFB->CFB_CONREC	+=	aValores[9]
			CFB->CFB_CREDES	+=	0
			MsUnLock()
		Else
			RecLock("CFB",.T.)
			CFB->CFB_FILIAL	:=	cFilCFB
			CFB->CFB_CODCON	:=	cCodCont
			CFB->CFB_TPCON	:=	"COF"
			CFB->CFB_VLRREC	:=	aValores[3]
			CFB->CFB_CONREC	:=	aValores[9]
			CFB->CFB_PERDIF	:=	cPerDif
			CFB->CFB_DTPGTO	:=	STOD(cDtPgto)
			CFB->CFB_NATCRE	:=	''
			CFB->CFB_CREDES	:=	0
			CFB->CFB_PERAPU	:=	cPerApur
			CFB->CFB_ALIQ	:=	aValores[5]
			IF lNewProc
				CFB->CFB_CONSOL	:=	'2'
			EndIF
			MsUnLock()
		Endif
	Else
		For nPosCrd	:= 1 to len(aRetCrdDif)
			cChvCFB		:=	cFilCFB+cPerApur+"COF"+cCodCont+cPerDif+cDtPgto+str(aValores[5],5,2)+aRetCrdDif[nPosCrd][1]+'2'
			If SPEDSeek("CFB",1,cChvCFB)
				RecLock("CFB",.F.)
				CFB->CFB_VLRREC	+=	Round(aValores[3] * aRetCrdDif[nPosCrd][3] / 100,2)
				CFB->CFB_CONREC	+=	Round(aValores[9] * aRetCrdDif[nPosCrd][3] / 100,2)
				CFB->CFB_CREDES	+=	aRetCrdDif[nPosCrd][2]		
				MsUnLock()
			Else
				RecLock("CFB",.T.)
				CFB->CFB_FILIAL	:=	cFilCFB
				CFB->CFB_CODCON	:=	cCodCont
				CFB->CFB_TPCON	:=	"COF"
				CFB->CFB_DTPGTO	:=	STOD(cDtPgto)
				CFB->CFB_PERDIF	:=	cPerDif
				CFB->CFB_NATCRE	:=	aRetCrdDif[nPosCrd][1]
				CFB->CFB_PERAPU	:=	cPerApur
				CFB->CFB_ALIQ	:=	aValores[5]
				CFB->CFB_CREDES	:=	aRetCrdDif[nPosCrd][2]
				
				CFB->CFB_VLRREC	:=	Round(aValores[3] * aRetCrdDif[nPosCrd][3] / 100,2)
				CFB->CFB_CONREC	:=	Round(aValores[9] * aRetCrdDif[nPosCrd][3] / 100,2)
				IF lNewProc
					CFB->CFB_CONSOL	:=	'2'
				EndIF								
				MsUnLock()
			Endif
			
			//Gravat F0T com opção B			

			IF lF0T
				ObjF0T:Clear()
				ObjF0T:SetValue("F0T_FILIAL"	,cFilCFB)
				ObjF0T:SetValue("F0T_PER"		,firstday(STOD(cDtPgto)))
				ObjF0T:SetValue("F0T_FILAPU"	,cFilAnt)
				ObjF0T:SetValue("F0T_TIPO"		,'B') //Diferimento de créditos de PIS de período anterior
				ObjF0T:SetValue("F0T_DTEMI"		,STOD(cDtPgto) )
				IF cOrigem == "SE1"
					//Possui somente título ou  título + nota fiscal
					ObjF0T:SetValue("F0T_NUMNF"		,(cAlias)->NFISCAL)
					ObjF0T:SetValue("F0T_SER"		,(cAlias)->FT_SERIE)
					
					ObjF0T:SetValue("F0T_ITEM"		,(cAlias)->FT_ITEM)
					ObjF0T:SetValue("F0T_NUMTIT"	,(cAlias)->DOC)
					ObjF0T:SetValue("F0T_PREFIX"	,(cAlias)->E1_PREFIXO)
					ObjF0T:SetValue("F0T_PARC"		,(cAlias)->E1_PARCELA)		
							
				ElseIF cOrigem == "CF8"
					//Operações em Demais Documentos
					ObjF0T:SetValue("F0T_IDCF8"		,(cAlias)->DOC)
				 
				EndIF
				
				ObjF0T:SetValue("F0T_PERREC"	,nPercRec * 100) //Percentual recebido
				ObjF0T:SetValue("F0T_MODELO"	,aRetCrdDif[nPosCrd][1]) //Natureza do crédito
				ObjF0T:SetValue("F0T_BASPIS"	,aRetCrdDif[nPosCrd][4]) //VAlor de PIS diferido anteriormente
				ObjF0T:SetValue("F0T_VALPIS"	,aRetCrdDif[nPosCrd][2]) //VAlor de PIS a descontar no período atual
				ObjF0T:Grava()				
							
			EndIF			
		Next nPosCrd
	EndIF
	
	//Adiciona conteudo para aColsCof, onde as informacoes serao mostradas na Dialog apos o processamento
	If (nPos := aScan(aColsCof, {|x| x[1]==cCodCont .And. x[3]==aValores[5] .And. x[4]==aValores[12] .And. x[6]==cPerDif .And. x[7]==STOD(cDtPgto)})) > 0
	
		aColsCof[nPos][2]	+=	aValores[9]
		aColsCof[nPos][5]	+=	aValores[11]		
	
	Else
		aAdd(aColsCof,{cCodCont,;
					aValores[9],;
					aValores[5],;
					aValores[12],;
					aValores[11],;
					cPerDif,;
					STOD(cDtPgto),;
					.F.})
	Endif
Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} SumParcE1
Funcao que busca conteudo de determinado paramentro na filial de origem

	
@param	cFilE1 -> Filial do Titulo
		cCliente -> Codigo do cliente
		cLoja -> Loja do cliente
		cPrefixo -> Prefixo do titulo
		cDoc -> Numero do titulo
					
@return	nVlrTot -> Valor total de todas as parcelas somadas do titulo que esta
					sendo processado
		
@author Luccas Curcio
@since 19/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SumParcE1(cFilE1,cCliente,cLoja,cPrefixo,cDoc)
Local	nVlrTot	:=	0

DbSelectArea("SE1")
SE1->(DbSetOrder(2))

If SE1->(MsSeek(cFilE1+cCliente+cLoja+cPrefixo+cDoc))
	While !SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == cFilE1+cCliente+cLoja+cPrefixo+cDoc
		If !(SE1->E1_TIPO $ MVABATIM)
			nVlrTot += SE1->E1_VALOR
		Endif
		SE1->(DbSkip())
	End
Endif

Return nVlrTot


//-------------------------------------------------------------------
/*/{Protheus.doc} A054PTit
Função que irá realizar verificação de recebimentos dos títulos transferidos
entre as filiais, gravados na tabela SE6. Se o título foi transferido, para 
efeitos de diferimento, o valor recebido na filial de transferência 
será considerado na filial de origem.
	
@param	dDataDe 	  -> Data inicial do processamento
		dDataAte  	  -> Data Final do Processamento
		cFili     	 -> Filial de Origem
		cPrefixo	  -> Prefixo do Título processado
		cNumero	  -> Número do Título Processado
		cParcela	  -> Parcela do título processado
		cCliFor	  -> Cliente do Título Processado
		cLoja		  -> Loja do Título Processado
					
@return nValLiq - Valor de recebimento líquido do Título
		
@author Erick Dias
@since 18/09/2014
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function A054PTit(dDataDe,dDataAte,cFili,cPrefixo,cNumero,cParcela,cCliFor,cLoja)

Local nValLiq		:= 0
Local lConsCmp	:= .F.
Local cBR10925	:= SuperGetMV("MV_BR10925",.F.,"2")
Local nTamTit	:= TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]+1

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Query SE5    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


If TcSrvType()<>"AS/400"

	lQuery 		:= .T.
	cAliasSE5	:= GetNextAlias()   

	BeginSql Alias cAliasSE5
		COLUMN E5_DATA AS DATE
			SELECT 	SE5.E5_FILIAL, SE5.E5_NUMERO, SE5.E5_DATA, SE5.E5_VALOR, SE5.E5_RECPAG, SE5.E5_TIPODOC, SE5.E5_PREFIXO, 
				SE5.E5_PARCELA, SE5.E5_MOTBX, SE5.E5_BANCO, SE5.E5_AGENCIA, SE5.E5_CONTA, SE5.E5_NUMCHEQ, SE5.E5_TIPO, 
				SE5.E5_CLIFOR, SE5.E5_LOJA, SE5.E5_SEQ, SE5.E5_DOCUMEN, SE5.E5_NATUREZ,  SE5.E5_VRETCOF, SE5.E5_VRETPIS,
				SE5.E5_VRETCSL, SE5.E5_VRETIRF, SE5.E5_VRETISS, SE5.E5_MOEDA, SE5.E5_VLJUROS, SE5.E5_VLMULTA,SE5.E5_VLDESCO

		FROM 	%table:SE5% SE5
		
		WHERE 	SE5.E5_FILIAL = %Exp:cFili% AND 	
				SE5.E5_DATA >= %Exp:dDataDe% AND 
				SE5.E5_DATA <= %Exp:dDataAte% AND 
				SE5.E5_PREFIXO = %Exp:cPrefixo% AND
				SE5.E5_NUMERO = %Exp:cNumero% AND
				SE5.E5_PARCELA = %Exp:cParcela% AND	
				SE5.E5_CLIFOR = %Exp:cCliFor% AND
				SE5.E5_LOJA = %Exp:cLoja% AND				
           	SE5.E5_TIPODOC IN ('BA','CP','VL','V2','LJ','ES') AND
				SE5.E5_MOTBX <> 'FAT' AND
				SE5.%NotDel%
				
		ORDER BY %Order:SE5%
	EndSql

	dbSelectArea(cAliasSE5)
EndIF
	    
While !(cAliasSE5)->(Eof()) 
	//Verifica se tem baixa cancelada
 	If TemBxCanc((cAliasSE5)->E5_PREFIXO+(cAliasSE5)->E5_NUMERO+(cAliasSE5)->E5_PARCELA+(cAliasSE5)->E5_TIPO+(cAliasSE5)->E5_CLIFOR+(cAliasSE5)->E5_LOJA+(cAliasSE5)->E5_SEQ)
		(cAliasSE5)->(dbskip())
		Loop
	EndIf
	//Compensacao com NCC nao deve ser considerada para calculo do PIS/Cofins
	//MV_CRNEG --> inversao do calculo para titulo a receber
	If ((cAliasSE5)->E5_MOTBX == "CMP" .And. SUBSTR((cAliasSE5)->E5_DOCUMEN,nTamTit,3)$MV_CRNEG).Or.((cAliasSE5)->E5_TIPO$MV_CRNEG) //NCC
		(cAliasSE5)->(dbskip())
		Loop
	Endif  
	//Compensacao com RA deve ser considerada para calculo do PIS/Cofins e Liquidacao
	If (((cAliasSE5)->E5_MOTBX == "CMP" .And. SUBSTR((cAliasSE5)->E5_DOCUMEN,nTamTit,3)$MVRECANT)) .Or. ((cAliasSE5)->E5_MOTBX == "LIQ") //MVRECANT = RA
   		lConsCmp :=.T.
	Endif
	//Desconsidera Baixa por Dacao
	If !(cAliasSE5)->E5_MOTBX == "CEC" // Compensacao entre Carteiras considera na apuracao
		If !lConsCmp .And. !MovBcoBx((cAliasSE5)->E5_MOTBX,.T.)
			(cAliasSE5)->(dbskip())
			Loop
		Endif
	Endif
	//Adiciona o valor baixado + os Abatimentos - Juros e Multa + Desconto.
	If cBR10925 == "2"
		nValLiq += (cAliasSE5)->E5_VALOR + SomaAbat((cAliasSE5)->E5_PREFIXO,(cAliasSE5)->E5_NUMERO,(cAliasSE5)->E5_PARCELA,"R",Val((cAliasSE5)->E5_MOEDA),dDataBase,(cAliasSE5)->E5_CLIFOR, (cAliasSE5)->E5_LOJA) - (cAliasSE5)->E5_VLJUROS - (cAliasSE5)->E5_VLMULTA + (cAliasSE5)->E5_VLDESCO
	Else
		nValLiq += (cAliasSE5)->E5_VALOR + SumPCC130((cAliasSE5)->E5_PREFIXO,(cAliasSE5)->E5_NUMERO,(cAliasSE5)->E5_PARCELA,(cAliasSE5)->E5_DATA,(cAliasSE5)->E5_CLIFOR,(cAliasSE5)->E5_LOJA,Val((cAliasSE5)->E5_MOEDA)) - (cAliasSE5)->E5_VLJUROS - (cAliasSE5)->E5_VLMULTA + (cAliasSE5)->E5_VLDESCO
	EndIf
	(cAliasSE5)->(dbSkip())
EndDo          

DbSelectArea (cAliasSE5)
(cAliasSE5)->(DbCloseArea())


Return(nValLiq)


Static Function BuscaFil(aXFilial,cTAb)

Local nPos	:= 0
Local cRet	:= ''

nPos:=	aScan(aXFilial	,{|aX| aX[1]==cTAb}) 
If nPos > 0	
	cRet := aXFilial[nPos][2]
Else
	cRet := xFilial(cTab)
EndIF
			 

Return cRet
		
		
		
Static Function CrdDifAnt(cFilCFA,cPerApur,cTrib,cCodCon,cCnpj,nAliq, nPerc)

Local cChave	:= cFilCFA +  cPerApur + cTrib + cCodCon + cCnpj + STR(nAliq,5,2)   
Local aRet		:= {}
Local nPos		:= 0
Local cNatCred	:= ''
Local nTotCrd	:= 0
Local nValCrd	:= 0
Local nCont		:= 0

If cCodCon $ '01/02/03/04/71' .AND. CFA->(MSSEEK(cChave))

	Do While !CFA->(Eof ()) .AND. CFA->(CFA_FILIAL+CFA_PERAPU+CFA_TPCON+CFA_CODCON+CFA_CNPJ+STR(CFA_ALIQ,5,2)) == cChave
		
		//Deverá aqui aplicar ércentual de recebimento nos códigos
		If CFA->CFA_CONSOL == '2' .AND. CFA->CFA_CREDIF > 0 
			
			cNatCred	:=  substr(CFA->CFA_CODCRE,2,2) 			
			
			//Para as naturezas de créditos 01, 02 e 03 é exatamente o final do código de crédito, porém natureza da agro industria é 06, por este motivo
			//altero de 06 para 04, que é o código exigido no layout do M300/M700
			If cNatCred == '06'
				cNatCred	:= '04'
			EndIF
			
			nPos:=aScan(aRet,{|aX| aX[1]==cNatCred})
			
			nValCrd	:= Round(CFA->CFA_CREDIF * nPerc ,2) 
			
			IF nPos == 0
				aAdd(aRet, {})
				nPos := Len(aRet)
				aAdd (aRet[nPos], cNatCred)
				aAdd (aRet[nPos], nValCrd)
				aAdd (aRet[nPos], 0)												
				aAdd (aRet[nPos], CFA->CFA_CREDIF)
			Else
				aRet[nPos][2] += nValCrd
				
			EndIF
			nTotCrd += nValCrd			
						
		EndIf
	
		CFA->(DbSkip ())
	EndDo
	
	For nCont	:= 1 to Len(aRet)
		aRet[nCont][3] := Round(aRet[nCont][2] * 100 / nTotCrd,2)
	Next nCont


EndIF

Return aRet

//Função que irá definir se novo processamento de diferimento está ou não habilitado.
Function ISA001NDIF()

Return GetNewPar('MV_DIFCRD1','1') == '2' .AND. CFA->(ColumnPos( 'CFA_CONSOL' )) > 0 .AND. CFB->(ColumnPos( 'CFB_CONSOL' )) > 0


Function ISA001Data()

Local cMsg	:= ''

cMsg	+= 'FISA001 - ' + dtoc(GetAPOInfo("FISA001.prw")[4]) + ' - ' +  GetAPOInfo("FISA001.prw")[5]  + CHR(10)+CHR(13)  
cMsg	+= 'FISA002 - ' + dtoc(GetAPOInfo("FISA002.prw")[4]) + ' - ' +  GetAPOInfo("FISA002.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'FISA003 - ' + dtoc(GetAPOInfo("FISA003.prw")[4]) + ' - ' +  GetAPOInfo("FISA003.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'FISA004 - ' + dtoc(GetAPOInfo("FISA004.prw")[4]) + ' - ' +  GetAPOInfo("FISA004.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'FISA005 - ' + dtoc(GetAPOInfo("FISA005.prw")[4]) + ' - ' +  GetAPOInfo("FISA005.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'FISA006 - ' + dtoc(GetAPOInfo("FISA006.prw")[4]) + ' - ' +  GetAPOInfo("FISA006.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'FISA007 - ' + dtoc(GetAPOInfo("FISA007.prw")[4]) + ' - ' +  GetAPOInfo("FISA007.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'FISA008 - ' + dtoc(GetAPOInfo("FISA008.prw")[4]) + ' - ' +  GetAPOInfo("FISA008.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCO0 - ' + dtoc(GetAPOInfo("EFDBLOCO0.prw")[4]) + ' - ' +  GetAPOInfo("EFDBLOCO0.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCO1 - ' + dtoc(GetAPOInfo("EFDBLOCO1.prw")[4]) + ' - ' +  GetAPOInfo("EFDBLOCO1.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCOA - ' + dtoc(GetAPOInfo("EFDBLOCOA.prw")[4]) + ' - ' +  GetAPOInfo("EFDBLOCOA.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCOC - ' + dtoc(GetAPOInfo("EFDBLOCOC.prw")[4]) + ' - ' +  GetAPOInfo("EFDBLOCOC.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCOD - ' + dtoc(GetAPOInfo("EFDBLOCOD.prw")[4]) + ' - ' +  GetAPOInfo("EFDBLOCOD.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCOF - ' + dtoc(GetAPOInfo("EFDBLOCOF.prw")[4]) + ' - ' +  GetAPOInfo("EFDBLOCOF.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCOI - ' + dtoc(GetAPOInfo("EFDBLOCOI.prw")[4]) + ' - ' +  GetAPOInfo("EFDBLOCOI.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCOM - ' + dtoc(GetAPOInfo("EFDBLOCOM.prw")[4]) + ' - ' +  GetAPOInfo("EFDBLOCOM.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCOP - ' + dtoc(GetAPOInfo("EFDBLOCOP.prw")[4]) + ' - ' +  GetAPOInfo("EFDBLOCOP.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'FISX001 - ' + dtoc(GetAPOInfo("FISX001.prw")[4]) + ' - ' +  GetAPOInfo("FISX001.prw")[5]  + CHR(10)+CHR(13)
cMsg	+= 'FISX002 - ' + dtoc(GetAPOInfo("FISX002.prw")[4]) + ' - ' +  GetAPOInfo("FISX002.prw")[5]  + CHR(10)+CHR(13)


 
MSGINFO(cMsg)

Return





