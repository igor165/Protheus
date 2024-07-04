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

@history Vogas Júnior, 05/06/2018, (DSERFIS1-4280) imprimir relartório conforme período apurado.

/*/ 
//------------------------------------------------------------------
Function FISA001()

	Local lVerpesssen := Iif(FindFunction("Verpesssen"),Verpesssen(),.T.)

	Private EAI_MESSAGE_MVC := ""
	Private oBrowse 
	Private oPanelBrw
	PRIVATE cMarca     	 := GetMark()
	PRIVATE CLIVROAPU		:= ""

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
	STATIC cCstNTrib	:= '04/06/07/08/09/49/99' //CSts não tributáveis

	If lVerpesssen		
		If AliasINdic('CKR')	
			FWExecView(STR0020,'FISA001', MODEL_OPERATION_INSERT,,, { || .T. } )//'Rotina de Apuração EFD Contribuições'
		Else
			Alert(STR0021)//'Tabelas não criadas, por favor processa compatibilizado UPDFIS'
		EndIF
	EndIf	

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
Local aCoors := {}
Local bChange := { || FChgTree( oTree,oPanel )  }

oSize := FwDefSize():New(.T.,,,.T.)
oSize:AddObject('PANEL_TREE'  ,100,100,.T.,.T.)
oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 0, 0, 0, 0 } // Espaco ao lado dos objetos 0, entre eles 3 
oSize:Process()

aAdd(aCoors,{oSize:GetDimension("PANEL_TREE", "COLINI"),oSize:GetDimension("PANEL_TREE", "LININI"),oSize:GetDimension("PANEL_TREE", "YSIZE")*0.97,oSize:GetDimension("PANEL_TREE", "COLEND")*0.26})

oTree := DbTree():New( aCoors[1][2], aCoors[1][1], aCoors[1][3], aCoors[1][4], oPanel,bChange , , .T. )

oTree:AddTree( Padr(STR0018,40), .T., "FOLDER5" ,"FOLDER6",,,"000" ) 
oTree:TreeSeek( "001" )
oTree:AddItem(STR0004,"001","PMSEDT3","",,,2) ////"Processar Apuração da EFD Contribuições"
IF Findfunction('FISA076') .AND. ISA001NDIF()
	oTree:AddItem(STR0110,"003","PMSEDT3","",,,2)//"Informacões Adic. Diferimento"
EndIf
oTree:AddItem(STR0005,"004","PMSEDT3","",,,2)//"Demais Documentos PIS/COFINS"
oTree:AddItem(STR0006,"005","PMSEDT3","",,,2)//"Exclusões de Sociedade Cooperativa"
oTree:AddItem(STR0007,"006","PMSEDT3","",,,2) //"Deduções Diversas PIS COFINS"
oTree:AddItem(STR0008,"007","PMSEDT3","",,,2) //"Ajuste de créditos PIS/COFINS/CPRB"

IF FindFunction("FISA210") .AND. AliasIndic("F2Z")
	oTree:AddItem(STR0116 ,"008","PMSEDT3","",,,2) //"Ajustes da Base de Cálculo de PIS e COFINS"
EndIF

oTree:AddItem(STR0009,"009","PMSEDT3","",,,2)//"Controle de saldo de Crédito de PIS"
oTree:AddItem(STR0010,"010","PMSEDT3","",,,2)//"Controle de saldo de Crédito da COFINS"

IF SFV->(FieldPos("FV_RESSA")) > 0 .And. SFV->(FieldPos("FV_COMP")) > 0 .And. SFV->(FieldPos("FV_RESRET")) > 0 .And. ;
	FindFunction("FISA216") .And. FindFunction("FISA217")

	oTree:AddItem(STR0120,"023","PMSEDT3","",,,2)//"Controle de retencoes do PIS"
	oTree:AddItem(STR0121,"024","PMSEDT3","",,,2)//"Controle de retencoes da COFINS"
EndIf

oTree:AddItem(STR0012,"011","PMSEDT3","",,,2)//"Crédito Sobre Estoque de Abertura"
oTree:AddItem(STR0013,"012","PMSEDT3","",,,2)//"Ressarcimento de crédito de PIS e COFINS"

oTree:AddItem(STR0105,"014","PMSEDT3","",,,2)//Rotina de importação dos códigos da Receita Federal

IF Findfunction('FISA006')
	oTree:AddItem(STR0106,"015","PMSEDT3","",,,2)//Rotina de Demais Retenções
EndIF

IF Findfunction('FISA124') .And. AliasINdic('F0X')
	oTree:AddItem(STR0107,"016","PMSEDT3","",,,2)//Rotina escrituração do F800
EndIf

IF Findfunction('FISA089')
	oTree:AddItem(STR0108,"017","PMSEDT3","",,,2)//Rotina Período Dispensado
EndIf

IF Findfunction('FISA009') .And. AliasINdic('F3F')
	oTree:AddItem(STR0111,"018","PMSEDT3","",,,2)//Bloco I X Contabilidade
EndIf

IF FindFunction("FISA211") .AND. AliasIndic("F3N")
	oTree:AddItem(STR0117 ,"019","PMSEDT3","",,,2) //"Recibos de Transmissão do SPED" 
EndIF

//A rotina de cadastro somente será exibida na tela se a tabela existir e o parâmetro for configurado
IF FindFunction("FISA212") .AND. AliasIndic("F3U") .AND. GetNewPar('MV_ESTCRDA',"") $ "1/2"
	oTree:AddItem(STR0118 ,"020","PMSEDT3","",,,2) //"Códigos de Créditos a Serem Estornados" 
EndIF

//A rotina de cadastro somente será exibida na tela se a tabela existir e o parâmetro for configurado
IF FindFunction("FISA213") .AND. AliasIndic("F3V") .AND. GetNewPar('MV_ESTCRDA',"") == "1"
	oTree:AddItem(STR0119 ,"021","PMSEDT3","",,,2) //"Percentuais de Estorno de Créditos" 
EndIF

IF Findfunction('FISA008')
	oTree:AddItem(STR0109,"022","PMSEDT3","",,,2)//Rotina de geração do Arquivo 
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
	oBrowse:SetMainProc(cFonteTree)
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
	 
ElseIf cAliasTree == "F3F"
	
	//Tratamento para legendas da tela filha do bloco I
	If F3F->(FieldPos("F3F_CTB")) > 0
		oBrowse:AddLegend( "F3F_CTB== '1'", "GREEN", "Realizou Integração com Contábil" ) // "Ajuste de Redução"
		oBrowse:AddLegend( "F3F_CTB<> '1' ", "RED", 	"Integração com Contábil pendente" ) // "Ajuste de Redução"
	EndIF

ElseIf cAliasTree == "F2Z"

	oBrowse:AddLegend( "F2Z_TRIB == '1' .AND. F2Z_INDAJU == '0' ", "BR_AMARELO", STR0113 ) //"Ajuste de Acréscimo da Base de Cálculo do PIS"
	oBrowse:AddLegend( "F2Z_TRIB == '1' .AND. F2Z_INDAJU == '1' ", "BR_AZUL", STR0112 ) //"Ajuste de Redução da Base de Cálculo do PIS"
	oBrowse:AddLegend( "F2Z_TRIB == '2' .AND. F2Z_INDAJU == '0' ", "BR_BRANCO", STR0115 ) //"Ajuste de Acréscimo da Base de Cálculo da COFINS"
	oBrowse:AddLegend( "F2Z_TRIB == '2' .AND. F2Z_INDAJU == '1' ", "BR_VERDE", STR0114 ) //"Ajuste de Redução da Base de Cálculo da COFINS"

ElseIf cAliasTree == "SFV"

	If SFV->(FieldPos("FV_RESRET")) > 0															
		oBrowse:AddLegend( "FV_RESRET == '1' ", "RED"		, STR0122) //"Reserva de Retenção bloqueada." 	
		oBrowse:AddLegend( "FV_RESRET == '2' ", "GREEN" 	, STR0123)//"Reserva de Retenção disponível."
	EndIf	

ElseIf cAliasTree == "SFW"

	If SFW->(FieldPos("FW_RESRET")) > 0
		oBrowse:AddLegend( "FW_RESRET == '1' ", "RED"		, STR0122) //"Reserva de Retenção bloqueada." 	
		oBrowse:AddLegend( "FW_RESRET == '2' ", "GREEN" 	, STR0123)//"Reserva de Retenção disponível."
	EndIf	

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
	
	oStru := FWFormViewStruct():New()		
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
Function FChcTpFunc( cIdTreePos ,oTree, aReprocess, aAutoFil)

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
Local cChkTabApu	:= ''
Local lProcComp		:= .F. //Controle se deverá processar considerando o compartilhamento das tabelas

Default aReprocess	:= {}
Default aAutoFil	:= {{.T., cFilAnt}}
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
					lProcComp  := .T.			
				Else
					//Aqui quer somente carregar apuração, sem reprocessamento
					lLoad := .T.	
				EndIF
			Else
				//Não existe apuração
				//Processar normalmente, pois será a primeira vez para esta filial e período
				lProc	:= .T.
				lProcComp  := .T.
			EndIF
			
		ElseIf Pergunte("ISA001",.T.)
			aPergunta	:= GuardaPerg()
			
			//Trecho abaixo realiza verificação das tabelas CCW, CCY, SFV, SFW, CF3, CF4 e CF5. 
			//Para apuração agrupada estas tabelas devem estar com as tabelas compartilhadas.
			//Para apuração individualizada esta tabelas devem estar com compartilhamento exclusívo.
			//Rotina irá alertar usuário se houver inconsist~encia, mas se usuário desejar continuar ainda será permitido.
			lProcComp	:= .T.
			cChkTabApu:= CompTabEFD(MV_PAR15 == 2)			
			IF !Empty(Alltrim(cChkTabApu))
				If ( ApMsgYesNo(cChkTabApu + CHR(10)+CHR(13) + 'Realmente deseja continuar?' ) )	
					lProcComp	:= .T.
				Else
					lProcComp	:= .F.				
				EndIF
			EndIF
			
			//-------------------------------
			//Verifica se apuração já existe
			//-------------------------------
			If lProcComp .AND. CheckApur() 
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

		IF lProcComp .AND. ( lReproc .OR. lProc)			
			//Somente irá processar se apuração ainda não existe ou se deseja fazer reprocessamento.
			ProcLogIni({})
			ProcLogAtu("INICIO","#### --- Início da ápuração --- #### " + Time(),,upper('FISA001'))
			
			//aPergunta	:= GuardaPerg()
			aFil		:= GetFilial(lAutomato, aAutoFil)
			
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
				
				
				//Verifica condições de porcentagem da desoneração
				//Quando menor que 5% não havera bloco P
				//Quando superior ou igual a 95% utilzia 100% da receita bruta para desoneração
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

	Case cIdTreePos == "003" .And. Findfunction('FISA076')  .AND. ISA001NDIF()
		aRet[1] := 'FISA076'
		aRet[2] := 'CFA'
		aRet[3] := ""
		aRet[4] := STR0110 // "Informacões Adic. Diferimento"
	Case cIdTreePos == "004"
		aRet[1] := 'FISA048'
		aRet[2] := 'CF8'
		aRet[3] := ""
		aRet[4] := STR0005		
	Case cIdTreePos == "005"
		aRet[1] := 'FISA039'
		aRet[2] := 'CE9'
		aRet[3] := ""
		aRet[4] := STR0006		
	Case cIdTreePos == "006"
		aRet[1] := 'FISA041'
		aRet[2] := 'CF2'
		aRet[3] := ""
		aRet[4] := STR0007	
	Case cIdTreePos == "007"
		aRet[1] := 'FISA042'
		aRet[2] := 'CF5'
		aRet[3] := ""
		aRet[4] := STR0008

	Case cIdTreePos == "008"
		aRet[1] := 'FISA210'
		aRet[2] := 'F2Z'
		aRet[3] := "F2Z_ORIG == '1'"
		aRet[4] := STR0116//"Ajustes da Base de Cálculo de PIS e COFINS"

	Case cIdTreePos == "009"
		aRet[1] := 'FISA044'
		aRet[2] := 'CCY'
		aRet[3] := ""
		aRet[4] := STR0009	
	Case cIdTreePos == "010"
		aRet[1] := 'FISA045'
		aRet[2] := 'CCW'
		aRet[3] := ""
		aRet[4] := STR0010	
	Case cIdTreePos == "011"
		aRet[1] := 'FISA049'
		aRet[2] := 'CF9'
		aRet[3] := ""
		aRet[4] := STR0012	
	Case cIdTreePos == "012"
		aRet[1] := 'FISA050'
		aRet[2] := 'CG4'
		aRet[3] := ""
		aRet[4] := STR0013
	
	Case cIdTreePos == "014"
		FISA005('CCZ')	
		oTree:TreeSeek('000')
		
	Case cIdTreePos == "015"		
		aRet[1] := 'FISA006'
		aRet[2] := 'CLG'
		aRet[3] := ""
		aRet[4] := STR0106
	Case cIdTreePos == "016" .And. Findfunction('FISA124') .And. AliasINdic('F0X')
		aRet[1] := 'FISA124'
		aRet[2] := 'F0X'
		aRet[3] := ""
		aRet[4] := STR0107
	Case cIdTreePos == "017"
		aRet[1] := 'FISA089'
		aRet[2] := 'CKN'
		aRet[3] := ""
		aRet[4] := STR0108
	Case cIdTreePos == "018"
		aRet[1] := 'FISA009'
		aRet[2] := 'F3F'
		aRet[3] := "F3F_TPREG=='1'" 
		aRet[4] := STR0111
	Case cIdTreePos == "019"
		aRet[1] := 'FISa211'
		aRet[2] := 'F3N'
		aRet[3] := "" 
		aRet[4] := "Recibos de Transmissão do SPED"
	Case cIdTreePos == "020"
		aRet[1] := 'FISA212'
		aRet[2] := 'F3U'
		aRet[3] := "" 
		aRet[4] := STR0118
	Case cIdTreePos == "021"
		aRet[1] := 'FISA213'
		aRet[2] := 'F3V'
		aRet[3] := "" 
		aRet[4] := STR0119
	Case cIdTreePos == "022"
		FISA008()	
		oTree:TreeSeek('000')
	Case cIdTreePos == "023"
		aRet[1] := 'FISA216'
		aRet[2] := 'SFV'
		aRet[3] := ""
		aRet[4] := STR0124
	Case cIdTreePos == "024"
		aRet[1] := 'FISA217'
		aRet[2] := 'SFW'
		aRet[3] := ""
		aRet[4] := STR0125
			
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
 	
Local lBlocI     := .F.
Local lCPRB      := .F.
Local lPisSal    := .F.
Local lSocCoop   := .F.
Local lProcCred  := .F.
Local lDifer     := .F.
Local lPFisEnt   := .T.
Local lPFisSai   := .T.
Local lPTitEnt   := .T.
Local lPTitSai   := .T.
Local lPATF      := .T.
Local lPCupom    := .T.
Local lPCPRB     := .T.
Local lPOutros   := .T.
Local lReprocess := .T.
Local lCancel    := .F.
Local lCupom     := .F.
Local lindividu  := .F.
Local lVendaFora := GetNewPar( 'MV_SPDGRNF' ,.F.)
Local lTelSemLiv := GetNewPar( 'MV_ESTTELE' ,.F.)
Local aAreaSM0   := {}
Local aXFilial   := {}
Local aXFilialRe := {}
Local aFil       := {}
Local nMVM996TPR := GetNewPar( 'MV_M996TPR' ,.F.)
Local nContFil   := 0
Local nTotF100   := 0
Local nBsConsorc := 0
Local cFilAte    := ''
Local cRegime    := ''
Local nContThr   := 0
Local lErro      := .F.
Local nX         := 0
Local aDiaThread := {}
Local nQtdThread := SuperGetMv("MV_QTDTAEC",.F.,0)
Local aThread    := {}
Local dUltDia    := LastDay (aParSX1[1]) + 1
Local cProxPer   := cvaltochar(strzero(month(dUltDia ) ,2)) + cvaltochar(year(dUltDia ))
Local cFilialMat := FWGETCODFILIAL //Busca código da filial da filial logada, pois este código será gravado nas tabelas da apuração.
Local bWhileSM0  :={||!SM0->(Eof ()) .And. cEmpAnt==SM0->M0_CODIGO .And. ((!"1"$aWizard[1][12] .And. FWGETCODFILIAL<=cFilAte) .Or. ("1"$aWizard[1][12] .And. Len(aLisFil)>0))}
Local lAjBase    := aParSX1[24]==2 // Dev./Canc. período anterior ?  1=Aju. Contribu. ,2=Aju. Base Calc.
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
Local mvAlqCprb  := GetNewPar( 'MV_CPRBALQ' , '' )
Local cCodAtiviv := Substr(mvAlqCprb,1, At("/",mvAlqCprb)-1 )
Local nAlqCprb   := val( Substr(mvAlqCprb,At("/",mvAlqCprb)+1, len(mvAlqCprb) ))
Local aF100      := {}
Local lCPRBNF    := GetNewPar( 'MV_CPRBNF' ,.F.) .And. SFT->(FieldPos("FT_VALCPB")) > 0 .And. SFT->(FieldPos("FT_BASECPB")) > 0 .And. SFT->(FieldPos("FT_ALIQCPB")) > 0
Local cSPCBPSE   := GetNewPar("MV_SPCBPSE", '' )
Local lCredPAgro := GetNewPar("MV_CPPCAGR",.F.)
Local aMvSpcxCp1 := &( GetNewPar( "MV_SPCXCP1" , "{}" ) ) //NCM dos produtos adquiridos como insumos das receitas classificadas como crédito presumido.
Local cMvEfdCP   := Substr(SpedPrSeq("MV_EFDCP","/{}"),2) //Utilizar quando não couber informações no parametro MV_SPCXCP1.
Local aMvEfdCP   := {}
Local aMvSpcxCp2 := &( GetNewPar( "MV_SPCXCP2" , "{}" ) ) //Alíquotas que serão utilizadas no cálculos dos ajustes de PIS e COFINS para crédito presumido.
Local aMvSpcxCp3 := &( GetNewPar( "MV_SPCXCP3" , "{}" ) ) //NCM dos produtos classificados na tabela TIPI nos capítulos 2 a 4 e 15 a 16.
Local cCtlDedRet := "" //Controle da função DeduzReten ("A" = processa Saldos e Retenção / "S" = Apenas saldos  /  "R" = Apenas retenções) 
Local IndF0X     := AliasINdic( 'F0X' )
Local n          := 0
Local cPrefixE1  := ''
Local cCmpB1Dif  := ''
Local cCmpA1Dif  := ''
Local aParFiltr  := {}
Local cAliasDIF  := ''
Local cPerApur   := ''
Local ObjF0T
Local oDebBlcI
Local nIcmsRec   := 0
Local aICMS      := {}
Local a1050      := {}
Local aMVRLCSPD  := {}
Local aLiv1900   := {}
Local nReducao   := 0
Local aRecBloco  := {}
Local nTotRecCD  := 0
Local nTotBlocos := 0
Local nY         := 0
Local cInfCompl  := "Ajuste de Base de Cálculo referente decisão judicial determinando a exclusão do ICMS a recolher."
Local cInfComplA := ""
Local nTotICMS   := 0
Local lF2Z       := AliasIndic("F2Z")
Local aAjuPISCOF := {}
Local cCtaMx15   := GetNewPar("MV_CTAMX15","")
Local lIntGTP    := FindFunction('GtpXFis') .And. GtpXFis(aParSX1[1], aParSX1[2])
Local lCIE       := AliasIndic("CIE")
Local dMVICMDSDT := StoD(" / / ")
Local cTabDif    := "" // definir quais tabelas precessar no diferimento 1 - CFA / 2 - CFB / 3 ambos
Local cSemaphore := 'AICMS' +Alltrim(Str(ThreadID()))
Local aProcAICMS := {}
Local lFirst	 := .T.
Local oJSF100 	 := JsonObject():new()

DEFAULT cNomeJob := cNomeJob
DEFAULT lProcessou	:= .F.

CLIVROAPU := aParSX1[3]

//Verifica se o processamento é com opção de gravação individualizada.
lindividu	:= .F.
If aParSX1[15] == 2
	lindividu	:= .T.
EndIF	
If	"/" $ cMvEfdCP
	cMvEfdCP := STRTRAN(cMvEfdCP,"/{",",")
	cMvEfdCP := STRTRAN(cMvEfdCP,"},",",")
Endif
aMvEfdCP := &(cMvEfdCP) 
For n:=1 to len(aMvEfdCP)	
	aadd(aMvSpcxCp1,aMvEfdCP[n])
Next

If nMVM996TPR == 3 .AND. aParSX1[6] == 4
	DbSelectArea ('SA1')
	If ! SA1->(FieldPos("A1_TPREG"))>0
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
	lPCupom		:= Iif(aReprocess[6] == 1,.T.,.F.)
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

		IniCred(aParSX1,aXFilial,cFilialMat)
		//Zera as deduções
		IniDeducao(aParSX1,aXFilial,cFilialMat)
		//Zera as retenções
		IniRetenca(aParSX1,aXFilial,cFilialMat)
		//Zera as tabelas da apuração
		IniTabApur(aParSX1,aXFilial,.T.,Len(aReprocess) > 0) //Limpa as tabelas de apuração e também as auxiliares
				
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

	If AliasIndic("F3Z")
		If F3Z->(FieldPos("F3Z_FILAPU")) > 0
			ISA001F3Z(aParSX1[1],aParSX1[2],aSM0)
		EndIf
	EndIf
    
	//Se for apuração individualizada, então irá atualizar array com o xFilial, para 
	//que as informações sejam gravadas de maneira consolidada na matriz. 
	IF lindividu
		aXFilial:= ASA001AFIL()

		//Chama função para limpar taela CF4 antes de popular
		ASA001DCF4(SubStr(DTos(aParSX1[1]),5,2)+SubStr(Dtos(aParSX1[1]),1,4))

		//Somente irá inicializar todas as tabelas se apuração for individualizada.
		//Se for consolidada a inicialização não será efetuada aqui.
		//Zera os créditos 
		IniCred(aParSX1,aXFilial,cFilialMat)  
		//Zera as deduções
		IniDeducao(aParSX1,aXFilial,cFilialMat)
		//Zera as retenções
		IniRetenca(aParSX1,aXFilial,cFilialMat)
		//Zera as tabelas da apuração
		IniTabApur(aParSX1,aXFilial,.T.,Len(aReprocess) > 0) //Limpa as tabelas de apuração e também as auxiliares		

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
	oApurSai:SetFilApu(cFilialMat) 
	oApurSai:SetRecBlc(aRecBloco)	
	
	nTotF100		:= 0 
	nBsConsorc		:= 0
	
	//Se for consolidado, irá então inicializar/zerar as tabelas auxiliares
	If !lindividu //Consolidado
		oApurSai:ClearTab(TabAux(.T.))
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
			A001SFTSai(aParSX1[1], aParSX1[2], oApurSai, Iif(aParSX1[6] == 4, nMVM996TPR, 0), aParSX1[6], lCPRBNF, cSPCBPSE,IIf(valtype(MV_PAR20)=="N",MV_PAR20,2),aXFilial,cFilialMat,lindividu,aParSX1)  			
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

	//---------------------------------------------------------------------------
	//PROCESSA BILHETES DE PASSAGEM SE INTEGRAÇÃO COM SIGAGTP ESTIVER ATIVA
	//---------------------------------------------------------------------------
	If lIntGTP

		If lMain .And. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,"Bilhetes de passagem - Integração GTP")//'Processando Cupom Fiscal'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF

		ProcLogAtu("MENSAGEM","Início processamento bilhetes de passagem (GTP) - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001CUPOM(aParSX1[1],aParSX1[2],oApurSai,cRegime,aParSX1[3],aParSX1[6],nMVM996TPR, .T.)
		ProcLogAtu("MENSAGEM","Fim processamento bilhetes de passagem (GTP) - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)	

	EndIf	

	If !Empty(cRegime) .AND. cRegime <> '3' .AND. !lBlocI
	
		If lMain .And. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0049)//'Processando Demais Documentos'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF
		ProcLogAtu("MENSAGEM","Início processamento Demais Documentos - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001CF8(aParSX1,	oApurEnt,	oApurSai,lProcCred,@nTotF100,lPTitEnt,lPTitSai,"1",@nBsConsorc,lCPRBNF,cFilialMat)
		ProcLogAtu("MENSAGEM","Fim processamento Demais Documentos - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
				
	EndIF

	//Chama neste ponto o processamento dos títulos sem vínculo com documento fiscal?
	If lMain
		ProcLogAtu("MENSAGEM","Início pesquisa Títulos Financeiros - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		aF100:= FinSpdF100(Month(aParSX1[1]),Year(aParSX1[2]),,dtos(mv_par01),dtos(mv_par02),"F100")
		oJSF100[FWGETCODFILIAL]:=aF100
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
			A001F100Fi(aParSX1,	oApurEnt,	oApurSai,lProcCred,@nTotF100,lPTitEnt, lPTitSai,aParSX1[6],"1",aF100, lCPRBNF,cFilialMat)
			ProcLogAtu("MENSAGEM","Fim processamento Títulos Financeiros - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		EndIF		
          If ExistBlock("SPDPIS09") 
		   ProcLogAtu("MENSAGEM","Início processamento SPDPIS09 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		   A001PEF100(aParSX1,oApurSai,oApurEnt,lProcCred,lPTitEnt, lPTitSai,aParSX1[6],'1',cFilialMat)
		   ProcLogAtu("MENSAGEM","Fim processamento SPDPIS09 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
		Endif
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
		A001BlocoI(aParSX1[1],aParSX1[2],oApurSai,aXFilial,cFilialMat)
		ProcLogAtu("MENSAGEM","Fim do processamento Instituição Financeira - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
	
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
		A001IMOB(aParSX1[1],aParSX1[2],oApurSai,oApurEnt,lProcCred,aParSX1[6],.F.,.T.)
		ProcLogAtu("MENSAGEM","Fim processamento SPDPCIMOB - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
		
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

			dMVICMDSDT := GetNewPar('MV_ICMDSDT', StoD("  /  /   ")) 
 			
			ProcLogAtu("MENSAGEM","Início do processamento Regime de Caixa - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001CAIXA(aParSX1[1],aParSX1[2],oApurSai,aParSX1[3],aParSX1[12],aXFilial,lCPRBNF,cSPCBPSE,cFilialMat,lindividu,aParSX1, @aAjuPISCOF, dMVICMDSDT)
			ProcLogAtu("MENSAGEM","Fim do processamento Regime de Caixa - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			
		EndIF			
		
	EndIF

	aRecBloco	:= oApurSai:GetRecBlc()
	//------------------------------------------------------------------------------------------------
	//Aqui chamarei a função para buscar o valor do ICMS a recolher da apuração de ICMS desta filial
	//------------------------------------------------------------------------------------------------
	If (lMain) .And. ;
		!lindividu .AND. lF2Z .AND. aParSX1[22] == 2 .AND. Year(aParSX1[1]) >= 2019//DSERFIS1-15641 - tem que lançar nota no dia 20 e 3 threads configuradas retirada da variavel lmain, pois a função ICMSRecolher apesar de chamar o spedfiltro na CDH, nao passa data ate, so se baseia na data inicial trazendo todos os dados da apuração			

		//Chama função para buscar icms a recolher da apuração do ICMS próprio
		nIcmsRec := ICMSRecolher(aParSX1[3], aParSX1[1], lastday(aParSX1[2]), "IC")

		//Busca os livros de sub apurações definidos no parâmetro MV_RLCSPD
		aMVRLCSPD:= &(GetNewPar('MV_RLCSPD',"{}"))
		For nX := 1 to Len(aMVRLCSPD)
			IF !Empty(aMVRLCSPD[nX,2])				
				//Busca valores de ICMS a recolher das sub apurações
				nIcmsRec += ICMSRecolher(aMVRLCSPD[nX,2], aParSX1[1], lastday(aParSX1[2]), "IC")				
			EndIF			
		Next nX			
		
		//Adiciona array com código da filial e seu respectivo valor de ICMS a recolher do período.
		aAdd(aICMS,{cFilAnt, nIcmsRec, SM0->M0_CGC, GetRecibo(aParSX1[1]), GetProcICMS(), 0 })		

	EndIF		

	//aRecBloco	:= oApurSai:GetRecBlc()
	//--------------------------
	//FINALIZA OBJETO DE SAÍDA
	//--------------------------	
	oApurSai:Finaliza('1')
		
Next nContFil

//-------------------------------------------------
//FIM DO LAÇO DAS FILIAIS, RESTAURA A FILIAL LOGADA
//-------------------------------------------------
RestArea (aAreaSM0)
cFilAnt := FWGETCODFILIAL


//Obtem variavel Global para controde de AICMS
//Caso não exista Cria variavel Global
If nQtdThread > 0 .and. !lindividu .AND. lF2Z .AND. aParSX1[22] == 2 .AND. Year(aParSX1[1]) >= 2019	
	IF lMain
		PutGlbVars("FISPROCICMS",aProcAICMS)		
		
		For nX := 1 to Len(aICMS)
			nTotICMS += aICMS[nX][2]
		Next

		IF nTotICMS > 0
			PutGlbVars("FISAICMS",aICMS)						
		Endif
	Else
		GetGlbVars("FISAICMS",@aICMS)		
	Endif
Endif

//----------------------------------------------------------------------------------------------------------------------
//Trecho que fará o rateio dos valores de ICMS a recolher, gerando ajsute de redução de base de cálculo de PIS e COFINS
//----------------------------------------------------------------------------------------------------------------------
If lF2Z .AND. aParSX1[22] == 2 .AND. Year(aParSX1[1]) >= 2019

	If lMain
		If ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,"Processando redução de base de cálculo de PIS e COFINS")//'Processando redução de base de cálculo de PIS e COFINS'
		EndIf
	Endif

	ProcLogAtu("MENSAGEM","Início do processamento redução de base de cálculo de PIS e COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)

	//Totalizando as receitas dos blocos C e D (Receitas sujeitas ao ICMS)
	//Totalizando também a receita de todos os blocos A, C, D e F.
	aRecBloco	:= oApurSai:GetRecBlc()
	For nX := 1  to Len(aRecBloco)
		//Total das receitas sujeitas ao ICMS (blocos C e D)
		nTotRecCD	+= aRecBloco[nX][5] + aRecBloco[nX][6]
		
		//Total de todas as receitas (blocos A, C, D e F)
		 nTotBlocos	+= aRecBloco[nX][4] + aRecBloco[nX][5] + aRecBloco[nX][6] + aRecBloco[nX][7]
	Next nX
	
	nPercRec	:= 100	
	//Percorrer e obter os percentuais de rateio por CST e Regime
	For nX := 1  to Len(aRecBloco)				
	
		//Para controlar eventuais diferenças de centavos, irei truncat os cálculos e descarregar eventuais diferenças no último item.
		//Desta forma a soma dos percentuais sempre bateram 100%		
		IF aParSX1[23] == 1
			//Receita do CST dividido pelo total de todas as receitas
			aRecBloco[nx][8]	:= Round(((aRecBloco[nX][4] + aRecBloco[nX][5] + aRecBloco[nX][6] + aRecBloco[nX][7]) / nTotBlocos) * 100, 8)
		ElseIF aParSX1[23] == 2
			//Receita do CST dividido pelo total das receitas sujeitas ao ICMS
			aRecBloco[nx][8]	:= Round(((aRecBloco[nX][5] + aRecBloco[nX][6]) / nTotRecCD) * 100, 8)
		EndIF
		
		If aRecBloco[nx][8] < nPercRec
			nPercRec -= aRecBloco[nx][8]
		Else
			aRecBloco[nx][8] := nPercRec
			nPercRec	:= 0 
		EndIF

	Next nX


	//Incluido pausa na thread quando utilizado Multthread
	//Esta pausa se ocorre pelo motivo do array aICMS não possuir valor equiparado a receita da Thread, gerando problema na redução da base
	//Array aICMS sempre possui valor total do ICMS no periodo, já a receita da Thread possui apenas dados de alguns dias.
	//Esta pausa visa atualizar aICMS conforme for sendo abatido nas Threads
	If  nQtdThread > 0

		IF Len(aICMS) > 0 .and. Iif(lMain, nTotICMS > 0, .T.)
			
			GetGlbVars("FISPROCICMS",@aProcAICMS)					
			Aadd(aProcAICMS,{Threadid(),nTotRecCD,nTotBlocos,.F.})
			PutGlbVars("FISPROCICMS",aProcAICMS)					
			
			While .T.
				IPCWaitEx( cSemaphore, 2000 )
				GetGlbVars("FISPROCICMS",@aProcAICMS)
				
				IF lMain .and. lFirst // Aguarda Todas as Threads estarem no array
					//verifica se Quantidade de Threads ativas no EFD é a mesma acumulada
					IF Len(CheckThread()) + 1 == Len(aProcAICMS)
						GetGlbVars("FISPROCICMS",@aProcAICMS)
						//conout(TIME() + ' SegunGetUserInfoArray( [ lShowMoreInfo* ] )dos: '+Str(Seconds())+ '- 1 Chegou na ultima Thread: '+Alltrim(Str(ThreadID())))
						nTotRecCD  := nTotBlocos := 0

						// Ordena as Threads para processar primeiro a de maior valor de receita
						IF aParSX1[23] == 1
							Asort(aProcAICMS,,,{|x,y|x[3]>y[3]})
						ElseIF aParSX1[23] == 2
							Asort(aProcAICMS,,,{|x,y|x[2]>y[2]})
						Endif

						//Soma todas as receitas
						For nX := 1  to Len(aProcAICMS)
							nTotRecCD  += aProcAICMS[nX][2]
							nTotBlocos += aProcAICMS[nX][3]
						Next nX						

						//Atualiza todas as Threads com novo valor
						For nX := 1  to Len(aProcAICMS)
							aProcAICMS[nX] := {aProcAICMS[nX][1],nTotRecCD,nTotBlocos,.T.}																
						Next nX					

						PutGlbVars("FISPROCICMS",aProcAICMS)
						Sleep(1000)
						GetGlbVars("FISPROCICMS",@aProcAICMS)
						lFirst := .F.
					Else
						Sleep(5000)
					Endif				
				Endif

				//Processa Primeira Thread da lista 	
				IF aProcAICMS[1][4] .and. aProcAICMS[1][1] == ThreadID() 
					//Conout(TIME() + ' Segundos: '+Str(Seconds())+ '- 2 Thread Em processamento: '+Alltrim(Str(ThreadID())))						
					GetGlbVars("FISAICMS",@aICMS)							

					nPercRec	:= 100
					//Percorrer e obter os percentuais de rateio por CST e Regime
					For nX := 1  to Len(aRecBloco)				
					
						//Para controlar eventuais diferenças de centavos, irei truncat os cálculos e descarregar eventuais diferenças no último item.
						//Desta forma a soma dos percentuais sempre bateram 100%		
						IF aParSX1[23] == 1
							//Receita do CST dividido pelo total de todas as receitas
							aRecBloco[nx][8]	:= Round(((aRecBloco[nX][4] + aRecBloco[nX][5] + aRecBloco[nX][6] + aRecBloco[nX][7]) / aProcAICMS[1][3] /*nTotBlocos*/) * 100, 8)
						ElseIF aParSX1[23] == 2
							//Receita do CST dividido pelo total das receitas sujeitas ao ICMS
							aRecBloco[nx][8]	:= Round(((aRecBloco[nX][5] + aRecBloco[nX][6]) / aProcAICMS[1][2] /*nTotRecCD*/) * 100, 8)
						EndIF
						
						If aRecBloco[nx][8] < nPercRec
							nPercRec -= aRecBloco[nx][8]
						Else
							aRecBloco[nx][8] := nPercRec
							nPercRec	:= 0 
						EndIF

					Next nX

					Exit	
				Endif
										
				//conout(TIME() + ' Segundos: '+Str(Seconds())+ '- 0 Thread em Espera: '+Alltrim(Str(ThreadID())))
			Enddo
		Endif	
	Endif
	
	IF Len(aRecBloco) > 0
		//Instancia classe de ajustes da EFD
		oAjustes 	:= AJUSTEEFD():New()
		oAjustes:SetFilial(aXFilial)
		oAjustes:SetFilApu(cFilialMat)
		oAjustes:SetDtIni(aParSX1[1])
		oAjustes:LoadCKS(.T.) // Chama a LoadCKS para montar os arrays considerando base de cálculo			

		//Laço nos valores de ICMS obtidos por filial, valores que foram obtidos da apuração de ICMS de cada filial selecioanda
		For nX := 1 to Len(aICMS)

			//Força atualização da CKS quando valor houve ajuste de redução de base 
			//para evitar problema de arredondamento, mesmo que em outra thread.
			IF (nQtdThread > 0 .and. aICMS[nX][6] > 0  .and. aICMS[nX][2] > 0 .and. Len(aRecBloco) > 0)
				oAjustes:SetAtuaCKS(.T.)
			Else
				oAjustes:SetAtuaCKS(.F.)
			Endif		

			//Verifica se existe valor de ICMS a recolher no período.
			//Quando for MultThread e não possuir mais valor a descontar deve processar CKS para evitar problemas de arredondamento.		
			If aICMS[nX][2] > 0 			
				
				nTotICMS	:= aICMS[nX][2] - aICMS[nX][6]
				
				//Precisamos percorrer os valores de receitas separados por CST e Regime, para obter os percentuais
				For nY := 1 to Len(aRecBloco)
					
					//Aplica percentual no valor total do ICMS da filial
					nReducao	:= Round((aICMS[nX][2] * aRecBloco[nY][8]) / 100, 2)
					
					If nReducao < nTotICMS
						nTotICMS -= nReducao
					Else
						nReducao := nTotICMS
						nTotICMS	:= 0 
					EndIF				
					
					//Se existe código da contribuição e se o CST for diferente de 03 então fará o ajuste
					IF !Empty(aRecBloco[nY][2]) .AND. aRecBloco[nY][1] <> "03"					

						//Verifica se o código da contribuição é tributado, para estes casos será necessário fazer ajuste 
						//de redução de base de cálculo.
						If aRecBloco[nY][2] $ "01/02/31/51/52"
							
							cInfComplA := cInfCompl
							
							//Recibo do SPED Fiscal
							IF !Empty(aICMS[nX][4]) 
								cInfComplA += " Número do Recibo do Sped Fiscal " + Alltrim(aICMS[nX][4]) + ". "
							EndIF

							//Número do Processo
							IF !Empty(aICMS[nX][5]) 
								cInfComplA += " Número do Processo " + Alltrim(aICMS[nX][5]) + ". "
							EndIF						

							//Ajuste de redução de base de cálculo de PIS
							AjuBasICMS(oAjustes, DEBITO, aRecBloco[nY][2], REDUCAO, nReducao, ;
									"21", aICMS[nX][5], cInfComplA, aParSX1[1], cCtaMx15, ;
									aICMS[nX][3], cInfCompl, PIS, aRecBloco[nY][2],	aRecBloco[nY][1])
							
							//Ajuste de redução de base de cálculo de COFINS
							AjuBasICMS(oAjustes, DEBITO, aRecBloco[nY][2], REDUCAO, nReducao, ;
									"21", aICMS[nX][5], cInfComplA, aParSX1[1], cCtaMx15, ;
									aICMS[nX][3], cInfCompl, COFINS, aRecBloco[nY][2],	aRecBloco[nY][1])					
							
						EndIF

					EndIF
										
					Proc1050(@a1050, aRecBloco[nY][1], nReducao, aICMS[nX][3], aICMS[nX][4], cInfCompl, aICMS[nX][2], aRecBloco[nY][3])					
			
				Next nY	
				
			EndIF

			//Atualiza variavel Global
			IF nQtdThread > 0 .and. GetGlbVars("FISAICMS",aICMS)
				//Guarda Valor do ajuste
				aICMS[nX][6] += oAjustes:GetVlAjGrv()
				PutGlbVars("FISAICMS",aICMS)			
			Endif
			oAjustes:SetAtuaCKS(.F.)
			
		Next nX

		//-------------------------------------------------------------
		//Faz gravação dos informações do registro 1050 na tabela F3P
		//-------------------------------------------------------------
		//-------------------------------------------------------------------------
		//Faz gravação do detalhamento das receitas sujeitas e não sujeitas ao ICMS
		//-------------------------------------------------------------------------
		If Len(a1050) > 0 .AND. Len(aRecBloco) > 0
			X001GRVF3O(aRecBloco, FirstDate(aParSX1[1]), "2", cVAlToChar(aParSX1[23])) // As tabelas F3O e F3P responsaveis pelo reg1050 devem ser geradas com data inicial do periodo, pos na geração do arquivo é esperado o dia inicial. e nao as datas de cada thread.
			X001GRVF3P(a1050, FirstDate(aParSX1[1]), "2")
		EndIF

		//Destrói o objeto do ajuste
		FreeObj(oAjustes)
		oAjustes:= NIL
	Endif
	
	//Libera Função para uso
	IF nQtdThread > 0
		GetGlbVars("FISPROCICMS",@aProcAICMS)
		IF Len(aProcAICMS) > 0
			ADEL(aProcAICMS, 1)
			aSize(aProcAICMS,Len(aProcAICMS)-1)
			PutGlbVars("FISPROCICMS",aProcAICMS)
			//conout(TIME() + ' Segundos: '+Str(Seconds())+ '- 3 - Thread liberada: '+Alltrim(Str(ThreadID())))			
		Endif
	Endif

ProcLogAtu("MENSAGEM","Início do processamento redução de base de cálculo de PIS e COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
EndIF



//Preciso fazer este laço nas filiais para processar as devoluções de compras e cancelamentos de períodos anteriores, para fazer
//ajustes de base de cálculo. Preciso ajustar a base aqui antes de processar os créditos, a base da contribuição precisa ser 
//ajustada antes de processar os créditos, se não teria que refazer todos os créditos e retenções novamente a cada ajuste de base.
IF lF2Z .And. lMain .AND. !lBlocI .AND. aParSX1[5] <> 2 .AND. Year(aParSX1[1])>= 2019

	If lAjBase //Se os estorno de cancelamentos e devoluções de períodos anteriores estiverem como ajuste de base, chamarei as funções abaixo

		For nContFil := 1 to Len(aSM0)

			IF lMain .And. ValType(oProcess)=="O"
				oProcess:Set2Progress(33)
			EndIF

			SM0->(DbGoTop ())
			SM0->(MsSeek (aSM0[nContFil][1]+aSM0[nContFil][2], .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL
			If lIndividu
				aXFilial:= ASA001AFIL()	
			EndIf	
			
			//Chamo a função para processar ajuste de base de cálculo, com exceção do CST 03
			ASA001CANC(aParSX1[1], aParSX1[2],cRegime,aParSX1[3],aXFilial,aParSX1[6], "3")
			//Devolução venda período anterior
			ASA001Devo(aParSX1[1], aParSX1[2],aParSX1[3],'S',nMVM996TPR,cRegime,.F.,aXFilial,FISCALENT,lCPRBNF,cSPCBPSE,"3",lAjBase) //Devolução de Venda	

		Next nContFil
	EndIF
EndIF

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

	//-----------------------------------------------------------------
	//Se for apuracao individualizada refaço a carga das filiais pois
	//o conteudo do array aXFilial sera o da ultima filial processada
	//no bloco 1. 
	//-----------------------------------------------------------------
	If lIndividu
		aXFilial:= ASA001AFIL()
	EndIf	

	If lMain	
		oApurPIS	:= APURPISCOF():New()	
		oApurPIS:SetRegime(aParSX1[6])
		oApurPIS:SetFilial(aXFilial)
		oApurPIS:SetFilApu(cFilialMat)
		//Passa data inicial
		oApurPIS:SetDtIni(aParSX1[1])
		//Passa Data Final
		oApurPIS:SetDtFim(aParSx1[2])
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
		oApurCof:SetFilaPU(cFilialMat)
		//Passa data inicial
		oApurCof:SetDtIni(aParSX1[1])
		//Passa Data Final
		oApurCof:SetDtFim(aParSx1[2])
		//Apura o PIS do período
		oApurCof:Apurar(COFINS)
	EndIf
	
	//--------------------------------------------------------------------------------------------------------------
	//Tratamento de SCP. Caso MV_PAR18 estiver preenchido como 03/04 então deverá processar somente sócia ostenciva
	//e desconsiderar sócia participante no processamento da apuração.
	//--------------------------------------------------------------------------------------------------------------
	IF mv_par18 $ '03/04' .AND. GetNewPar("MV_FILSCP",.F.)	//Sócia ostenciva
		//Aqui somente deverão ser gerados sócia ostenciva, ou seja, somente filial com parâmetro MV_FILSCP igual a .F.
		Loop
	EndIF
	
	If lMain .And. ValType(oProcess)=="O"
		oProcess:Inc1Progress(STR0040 +FWGETCODFILIAL)//"Processando Filial"				
		If oProcess:Cancel()
			lCancel:=.T.
			Exit
		EndIf		
	EndIF
	
	//Todo processamento da thread main deve ter a data inicial e final conforme a quantidade de threads configuradas, não pode ter o mês inteiro
	IF lMain .AND. nQtdThread > 0
		aParSX1[1]	:= aDiaThread[1][1]
		aParSX1[2]	:= aDiaThread[1][2]
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
	oApurEnt:SetFilApu(cFilialMat)
	
	mvAlqCprb	:= GetNewPar('MV_CPRBALQ','')
	cCodAtiviv 	:= Substr(mvAlqCprb,1,  At("/",mvAlqCprb)-1  )
	nAlqCprb 	:= val( Substr(mvAlqCprb,At("/",mvAlqCprb)+1,  len(mvAlqCprb)  ))
		
	//Aqui será efetuado a dedução da CPRB, referente a parcela de receitas de consórcios cadastrados na rotina demais documentos
	IF lCPRB .AND. !empty(cCodAtiviv) .AND. nBsConsorc >0 .AND. nAlqCprb > 0
		
		oCPRB	:= CPRBEFD():New()
		oCPRB:SetDtIni(aParSX1[1])
		oCPRB:SetFilApu(cFilialMat)
			
		oCPRB:DeduzBase(cCodAtiviv,nAlqCprb,nBsConsorc)
		FreeObj(oCPRB)
		oCPRB:= nil
		
	EndIF

	oApurEnt:LoadRecBru()
	oApurEnt:cfgParamPres( aMvSpcXCp1 )		
		
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
			A001SFTEnt(aParSX1[1], aParSX1[2],	oApurEnt,lCPRBNF,aXFilial)
			ProcLogAtu("MENSAGEM","Fim processamento Documentos de Entrada - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		EndIF		
		If lMain .And. IndF0X
			A001Suced(aParSX1[1], aParSX1[1],	oApurEnt)
		EndIf	
		
	EndIF
	
	//Chama neste ponto o processamento dos títulos sem vínculo com documento fiscal.
	If lMain
		ProcLogAtu("MENSAGEM","Início pesquisa Títulos Financeiros - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		
		if !oJSF100:GetJsonValue(FWGETCODFILIAL, @aF100) //Se não encontrar a filial no JSON
			aF100:= FinSpdF100(Month(aParSX1[1]),Year(aParSX1[2]),,dtos(mv_par01),dtos(mv_par02),"F100")
		endif

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
			A001F100Fi(aParSX1,	oApurEnt,	oApurSai,lProcCred,@nTotF100,lPTitEnt, lPTitSai,aParSX1[6],"2",aF100, lCPRBNF,cFilialMat)
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
		A001CF8(aParSX1,	oApurEnt,	oApurSai,lProcCred,@nTotF100,lPTitEnt,lPTitSai,"2",@nBsConsorc,lCPRBNF,cFilialMat)
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
				A001AbeEst(aParSX1[1],aParSX1[2],oApurEnt)
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
			A001F120(firstday(aParSX1[1]), LastDay(aParSX1[2]),	oApurEnt,(aParSX1[15]==2),cfilialMat)
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
			A001F130(firstday(aParSX1[1]), LastDay(aParSX1[2]),	oApurEnt,(aParSX1[15]==2),cFilialMat)
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
		A001PEF100(aParSX1,oApurSai,oApurEnt,lProcCred,lPTitEnt, lPTitSai,aParSX1[6],'2',cFilialMat)
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
		A001IMOB(aParSX1[1],aParSX1[2],oApurSai,oApurEnt,lProcCred,aParSX1[6],.T.,.F.)
		ProcLogAtu("MENSAGEM","Fim processamento SPDPCIMOB - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		
		
	EndIF
	
	//--------------------------------------------------
	//PROCESSA VALORES REFERENTE CRÉDITO PRESUMIDO
	//--------------------------------------------------
	If lCredPAgro .And. cRegime <> '3' 
		ProcLogAtu("MENSAGEM","Início processamento crédito presumido conforme lei 12.058/2009 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		F100Presu(aParSX1[1],aParSX1[2],aParSX1[3],oApurEnt,nTotF100,cFilialMat,lindividu)			
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
		ASA001Devo(aParSX1[1], aParSX1[2],aParSX1[3],'S',nMVM996TPR,cRegime,.T.,aXFilial,FISCALENT,lCPRBNF,cSPCBPSE,,lAjBase) //Devolução de Venda
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
		ASA001Devo(aParSX1[1], aParSX1[2],aParSX1[3],'E',nMVM996TPR,cRegime,.T.,aXFilial,FISCALSAI,lCPRBNF,cSPCBPSE,,lAjBase) //Devolução de COmpra
		ProcLogAtu("MENSAGEM","Fim processamento Devolução Compra período atual - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)	
	EndIF
		
	//---------------------------------------------------------------------
	//Irá processar ajustes de redução de contribuição vinda do Financeiro
	//---------------------------------------------------------------------
	If lMain .AND. cRegime <> '3' .AND. !lBlocI .AND. FindFunction("FinSpdM220")
		
		ProcLogAtu("MENSAGEM","Início processamento Ajuste de kredução Tìtulo Financeiro - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)

		oAjustes 	:= AJUSTEEFD():New()
		oAjustes:SetFilial(aXFilial)
		oAjustes:SetFilApu(cFilialMat)
		oAjustes:SetDtIni(aParSX1[1])
		oAjustes:LoadCKS()
		oAjustes:SetCrdDeb(DEBITO)
		
		oApurSai:SetRegApur(cRegime) 		
		ProcAjuFin( MV_PAR01, MV_PAR02, oAjustes, oApurSai)
		
		FreeObj(oAjustes)
		oAjustes:= NIL
		ProcLogAtu("MENSAGEM","Fim processamento Ajuste de redução Tìtulo Financeiro - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
	EndiF		
		
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
		oAjustes:SetFilApu(cFilialMat)
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
			
			cTabDif := IIf(lindividu, "3", "2") // T=Processa CFA e CFB, F=Processa só CFB

			ProcLogAtu("MENSAGEM","Início processamento Diferimento PIS COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001Difer(mv_par01,mv_par02,aXFilial,cTabDif)
			ProcLogAtu("MENSAGEM","Fim processamento Diferimento PIS COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)	
	
		   

			A001DifCPB(mv_par01, mv_par02, aXFilial, aParSX1)
		
		Else
			//Mantem processamento legado, ou seja, ainda o processamento realizado pela FISA054.
			ProcLogAtu("MENSAGEM","Início processamento Diferimento PIS COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001Difer(mv_par01,mv_par02,aXFilial,"3")
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
			//AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CLA')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CKR')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CKT')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CKU')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CL0')
			AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CL3')
			//Agrupa CPRB quando for processado por nota.
			IF lCPRBNF
				AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CKX')
				AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CKV')
			Endif
			IF AliasINdic('F3J')
				//Se a tabela F3J existir, então deverá ser consolidada também
				AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'F3J')
			EndIF
			IF AliasINdic('CIC')
				//Verifico se a tabela CIC existe antes de realizar a consolidação
				AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'CIC')
			EndIF
			IF AliasINdic('F2Z')
				//Verifico se a tabela F2Z existe antes de realizar a consolidação
				AgrupaThr(MV_PAR01+1, MV_PAR02, MV_PAR01,'2', 'F2Z')
			EndIF
		EndIf
		
		aParSX1[1]	:= MV_PAR01
		aParSX1[2]	:= MV_PAR02
		
	EndIF

	If lMain		

		IF lMain .AND. !lBlocI .AND. aParSX1[5] <> 2
			
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
			
			If lF2Z .AND. aParSX1[24] == 2 .AND. Year(aParSX1[1])>= 2019
				//Neste caso somente deo chamar esta função para processar eventuais ajustes do CST 03
				ASA001CANC(aParSX1[1], aParSX1[2],cRegime,aParSX1[3],aXFilial,aParSX1[6], '2')
			Else
				//Aqui mantem todos ajustes da contribuição normal
				ASA001CANC(aParSX1[1], aParSX1[2],cRegime,aParSX1[3],aXFilial,aParSX1[6], '1')
			EndIF
			
			ProcLogAtu("MENSAGEM","Fim processamento Notas Canceladas período anterior - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			
		EndIF	
		
		IF lMain .AND. !lBlocI .And. aParSX1[15] == 2
			//-------------------------------------------
			//PROCESSA VALORES DE AJUSTES DE PIS E COFINS
			//-------------------------------------------	
			oAjustes 	:= AJUSTEEFD():New()
			oAjustes:SetFilial(aXFilial)
			oAjustes:SetFilApu(cFilialMat)
			oAjustes:SetDtIni(aParSX1[1])
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
			If lF2Z .And. aParSX1[24] == 2 .AND. Year(aParSX1[1])>= 2019
				ASA001Devo(aParSX1[1], aParSX1[2],aParSX1[3],'S',nMVM996TPR,cRegime,.F.,aXFilial,FISCALENT,lCPRBNF,cSPCBPSE,"2",lAjBase) //Devolução de Venda
			Else
				ASA001Devo(aParSX1[1], aParSX1[2],aParSX1[3],'S',nMVM996TPR,cRegime,.F.,aXFilial,FISCALENT,lCPRBNF,cSPCBPSE,"1",lAjBase) //Devolução de Venda
			EndIF
			
			ProcLogAtu("MENSAGEM","Fim processamento Devoluções de Venda período anterior  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		ElseIf lBlocI
			
			oDebBlcI:= COMPDEBITO():New()
			oDebBlcI:SetFilial(aXFilial)
			oDebBlcI:SetDtIni(aParSX1[1]) 
			oDebBlcI:AtuDebito(CUMULAT,PIS)
			oDebBlcI:AtuDebito(CUMULAT,COFINS)			 
			FreeObj(oDebBlcI)
			oDebBlcI	:= nil
			
		EndIF	
		
		IF lMain .and. ValType(oProcess)=="O"
			oProcess:Inc2Progress(STR0103,STR0066)//'Processando devoluççoes de compra período anterior'			
			If oProcess:Cancel()
				lCancel:=.T.
				Exit
			EndIf
		EndIF		
	
		IF lPFisSai .AND. !lBlocI .And. aParSX1[15] == 2
			//---------------------------------------------------
			//PROCESSA AS DEVOLUÇÕES DE COMPRA DE PERÍODO ANTERIOR 
			//---------------------------------------------------
			ProcLogAtu("MENSAGEM","Início processamento Devoluções de Compra período anterior  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			ASA001Devo(aParSX1[1], aParSX1[2],aParSX1[3],'E',nMVM996TPR,cRegime,.F.,aXFilial,FISCALSAI,lCPRBNF,cSPCBPSE,,lAjBase) //Devolução de COmpra
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
			oCompCred:SetFilApu(cFilialMat)
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
			oCompCred:SetFilApu(cFilialMat)
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
		
		//Chama função que processará as informações da exigibilidade suspensa
		If lCIE .AND. Year(aParSX1[1]) >= 2020 .and. !cRegime == '3'

			//Processa exigibilidade suspensa para as notas fiscais
			ExigibSusp(oApurSai, nMVM996TPR,aParSX1[1],aParSX1[2], "NF", .F.,aParSX1[3])
			
			If lCupom .AND. lPCupom  	
				//Processa a exigibilidade suspensa para os cupons fiscais
				ExigibSusp(oApurSai, nMVM996TPR,aParSX1[1],aParSX1[2], "CUPOM", .F.,aParSX1[3])
			EndIF
			
			If lIntGTP
				//Processa a exigibilidade suspensa para as movimentações de intergração com SIGAGTP
				ExigibSusp(oApurSai, nMVM996TPR,aParSX1[1],aParSX1[2], "CUPOM", .T.,aParSX1[3])
			EndIF			
			
		EndIF		

	EndIF

Next nContFil

//Mata objeto
FreeObj(oJSF100)
oJSF100	:= Nil

//--------------------------------------------------------
//Terceiro Bloco de Processamento:
//- Processamentos adicionais
//--------------------------------------------------------	
For nContFil := 1 to Len(aSM0)

	IF lMain .And. ValType(oProcess)=="O"
		oProcess:Set2Progress(33)
	EndIF

	SM0->(DbGoTop ())
	SM0->(MsSeek (aSM0[nContFil][1]+aSM0[nContFil][2], .T.))	//Pego a filial mais proxima
	cFilAnt := FWGETCODFILIAL

	IF lPFisSai .AND. !lBlocI .And. aParSX1[15] == 1 .And. lMain
		//--------------------------------------------------------------------------------------
		//PROCESSA AS DEVOLUÇÕES DE COMPRA DE PERÍODO ANTERIOR PARA GERAÇÃO DE FORMA CONSOLIDADA
		//--------------------------------------------------------------------------------------
		ProcLogAtu("MENSAGEM","Início processamento Devoluções de Compra período anterior  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		ASA001Devo(aParSX1[1], aParSX1[2],aParSX1[3],'E',nMVM996TPR,cRegime,.F.,aXFilial,FISCALSAI,lCPRBNF,cSPCBPSE,,lAjBase) //Devolução de COmpra
		ProcLogAtu("MENSAGEM","Início processamento Devoluções de Compra período anterior  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)	
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
		cTabDif := "1" // Processa CFA

		ProcLogAtu("MENSAGEM","Início processamento Diferimento PIS COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001Difer(mv_par01,mv_par02,aXFilial,cTabDif)
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
		oDebito:SetFilApu(cFilialMat)
		oDebito:AtuSocCoop('1') //atualiza os valores de sociedade cooeprativa para regime não cumulatico
		oDebito:AtuSocCoop('2') //atualiza os valores de sociedade cooeprativa para regime  cumulatico
		FreeObj(oDebito)
		oDebito:= NIL
		ProcLogAtu("MENSAGEM","Fim processamento Sociedade Cooperativa - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)		

	EndIF			

	//Ajustes de redução da contribuição no regime de caixa.
	IF cRegime == '3' .AND. !lBlocI
		//Faz chamada de ajustes de redução da contribuição nas situações de alteração de regime de competência para caixa
		AjuAltRegCx(aAjuPISCOF, aXFilial, aParSX1[1], DEBITO)
	EndIF

	IF lMain .AND. !lBlocI .And. aParSX1[15] == 1
		//-------------------------------------------
		//PROCESSA VALORES DE AJUSTES DE PIS E COFINS
		//-------------------------------------------	
		oAjustes 	:= AJUSTEEFD():New()
		oAjustes:SetFilial(aXFilial)
		oAjustes:SetFilApu(cFilialMat)
		oAjustes:SetDtIni(aParSX1[1])
		oAjustes:LoadCKS()
		ProcLogAtu("MENSAGEM","Início processamento Ajustes de Débito CF5 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		A001AjuCF5(aParSX1[1],aParSX1[2],oAjustes,.T.)
		ProcLogAtu("MENSAGEM","Fim processamento Ajustes de Débito CF5 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		FreeObj(oAjustes)
		oAjustes:= NIL
	EndIF

	//Preciso fazer este laço nas filiais para processar as devoluções de compras e cancelamentos de períodos anteriores, para fazer
	//ajustes de base de cálculo. Preciso ajustar a base aqui antes de processar os créditos, a base da contribuição precisa ser 
	//ajustada antes de processar os créditos, se não teria que refazer todos os créditos e retenções novamente a cada ajuste de base.
	IF lF2Z .And. lMain .AND. !lBlocI .AND. aParSX1[5] <> 2 .AND. Year(aParSX1[1])>= 2019

		//Aqui irá processar os ajustes da base de cálculo de PIS e COFINS			
		oAjustes 	:= AJUSTEEFD():New()
		oAjustes:SetFilial(aXFilial)
		oAjustes:SetFilApu(cFilialMat)
		oAjustes:SetDtIni(aParSX1[1])
		oAjustes:LoadCKS(.T.) // Chama a LoadCKS para montar os arrays considerando base de cálculo

		//Chama função para buscar informações de eventuais saldos da CF3
		ASA001DANT(aParSX1[1],oAjustes,oAjustes,"S",aXFilial,"3")

		AjBaseCalc(aParSX1[1], aParSX1[2], oAjustes)
		oAjustes:AtuCKR("1")
		oAjustes:AtuCKR("2")
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
			oAjustes:SetFilApu(cFilialMat)
			oAjustes:SetDtIni(aParSX1[1])
			oAjustes:LoadCL8()

			//Processamento do estorno de créditos da Agro Indústria
			IF GetNewPar('MV_ESTCRDA',"") $ "1/2" .AND. AliasIndic("F3U") .AND. AliasIndic("F3V")
				EstCrdAgro( Year2Str(aParSX1[1]) + Month2Str(aParSX1[1]) , oAjustes, aParSX1[2])
			EndIF

			ProcLogAtu("MENSAGEM","Início processamento Ajustes CF5 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			A001AjuCF5(aParSX1[1],aParSX1[2],oAjustes)
			ProcLogAtu("MENSAGEM","Fim processamento Ajustes CF5 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			FreeObj(oAjustes)
			oAjustes:= NIL
		EndIF
				
		IF lProcCred .and. len( aMvSpcXCp1 ) > 0 .and. len( aMvSpcXCp2 ) > 0 
			//-------------------------------------------
			//PROCESSA VALORES DE AJUSTES DE PIS E COFINS
			//-------------------------------------------	
			oAjustes 	:= AJUSTEEFD():New()
			oAjustes:SetFilial(aXFilial)
			oAjustes:SetFilaPU(cFilialMat)
			oAjustes:SetDtIni(aParSX1[1])
			oAjustes:SetDtRefer(aParSX1[1])
			oAjustes:LoadCL8()
			
			ProcLogAtu("MENSAGEM","Início processamento Presumido - Lei 12.350/2010 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			
			A001AjuPresumido( aParSX1 , oAjustes , aMvSpcXCp1 , aMvSpcXCp2 , aMvSpcXCp3 , cRegime , aXFilial , cFilialMat )
			
			ProcLogAtu("MENSAGEM","Fim processamento Presumido - Lei 12.350/2010 - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
			
			FreeObj(oAjustes)
			oAjustes:= NIL
		EndIF
		
	EndIF

	If aParSX1[15] == 1 .And. (lProcCred .Or. (!lBlocI .And. cRegime == '2')) //DSERFIS1-14706 

		ProcLogAtu("MENSAGEM","Início atualização valor de PIS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)	
		oCompCred	:= CMPCREDITO():New()	
		oCompCred:SetFilial(aXFilial)
		oCompCred:SetFilApu(cFilialMat)
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
		ProcLogAtu("MENSAGEM","Início atualização valor de COFINS - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		oCompCred	:= CMPCREDITO():New()	
		oCompCred:SetFilial(aXFilial)
		oCompCred:SetFilApu(cFilialMat)
		oCompCred:SetDtIni(aParSX1[1])
		oCompCred:DedCred('2')
		ProcLogAtu("MENSAGEM","Início atualização valor de COFINS  - Filial " + FWGETCODFILIAL + " " + Time(),,cNomeJob)
		
		//Indic aqui se deverá buscar valores de créditos para próimo período
		oApurPIS:setPCrdFut(lProcCred)
		oApurCof:setPCrdFut(lProcCred)
	EndIf
	
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
			A001F700(aParSX1[1],str(aParSX1[6],1),oApurPIS,oApurCof,aXFilial,cFilialMat)
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

	//Atuliza Percentuais De ICMS na F3O
	IF  lMain .and. nQtdThread > 0
		X001ATUF3O(aParSX1)
	Endif
	
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

//Limpa variaveis globais
IF lMain 
	IF GetGlbVars("FISAICMS")		
		ClearGlbValue("FISAICMS")
	Endif
	IF  GetGlbVars("FISPROCICMS")		
		ClearGlbValue("FISPROCICMS")
	Endif
	
Endif

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
Static Function A001AbeEst(dDataDe,dDataAte,oApurEnt)
 
local cAliasCF9	:= ''
Local cSlctCF9	:= ''
Local cMesIng		:= ''
Local dDtIng		:= firstday(dDataDe)
Local nCont		:= 0
Local nQtdMesAnt	:= 12
Local dDtLimite  := LastDay(dDataAte)

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
		CF9.CF9_FILIAL = %xFilial:CF9% AND
		CF9.CF9_PERING > %Exp:DToS(dDtIng)% AND 
		CF9.CF9_PERING <= %Exp:DToS(dDtLimite)% AND  
		CF9.%NotDel%	
EndSql

DbSelectArea (cAliasCF9)
(cAliasCF9)->(DbGoTop ())
Do While !(cAliasCF9)->(Eof ())	
 
	//------------------------------------------
	//Não considera o 13 mes.
	//------------------------------------------
 	If Month((cAliasCF9)->CF9_PERING) = cMesIng .And. Year(dDataDe) > Year((cAliasCF9)->CF9_PERING) 
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
Local lDetAju	:= CF5->(FieldPos('CF5_CST')) > 0
Local lCF5Ativ	:= CF5->(FieldPos('CF5_TIPATV')) > 0
Local lProcDeb	:= CF5->(FieldPos("CF5_TPAJST"))>0 .And. CF5->(FieldPos("CF5_CODCON"))>0
Local cRegime	:= ''
Local aStruCF5	:= CF5->(DBStruct())
Local nCF5		:= 0
Local nTamCF5	:= Len(aStruCF5)
Local cCmpMemo  := ""

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

For nCF5 := 1 To nTamCF5	
	IF aStruCF5[nCF5][2] <> 'M' //Campos Memo devem ser ultimos campos
		IF nCF5 == 1
			cSelect += "CF5."+aStruCF5[nCF5][1]	
		Else
			cSelect += ", CF5."+aStruCF5[nCF5][1]	
		Endif
	Else
		cCmpMemo += ", CF5."+aStruCF5[nCF5][1]	
	Endif
	
Next (nCF5)

cAliasCF5	:=	GetNextAlias()
cSelect :=	'%' + (cSelect + cCmpMemo) + '%' //"%CF5.*%"
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
	
	If lCF5Ativ
		oAjustes:SetTipAtiv((cAliasCF5)->CF5_TIPATV)
	EndIF 
	
	//Passa novas informações para classe de ajuste
	If lDetAju
		oAjustes:SetCst((cAliasCF5)->CF5_CST)
		oAjustes:SetConta((cAliasCF5)->CF5_CONTA)
		oAjustes:SetInfComp(Iif(Type("(cAliasCF5)->CF5_INFCOM")<> "U"  ,(cAliasCF5)->CF5_INFCOM  ,(cAliasCF5)->CF5_DESAJU  )  )
		oAjustes:SetBase((cAliasCF5)->CF5_BASE)
		oAjustes:SetAlq((cAliasCF5)->CF5_ALQ)			
	EndIF
	
	oAjustes:SetDtRefer((cAliasCF5)->CF5_DTREF)
	
	//Realiza o Ajuste
	oAjustes:Ajustar()

	//Restaura Regime
	IF lDebito
		oAjustes:SetRegime(cRegime)
	Endif

	(cAliasCF5)->(DbSkip ())			
EndDo

oAjustes:FechaAlias(cAliasCF5)
FwFreeArray(aStruCF5)
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001AjuPresumido


@param	dDataDe	- Data inicial do período de apuração
		dDataAte	-Data final do período de apuração
		oAjustes	-Objeto de ajuste já criado para processamento

@author Erick G. Dias
@since 14/04/2014
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function A001AjuPresumido( aSX1 ,oAjustes , aMvSpcXCp1 , aMvSpcXCp2 , aMvSpcXCp3 , cRegime , aXFilial ,cFilialMat  )

Local	aCredPres	:=	{}

Local	cAliasSFT	:=	""
Local	cFiltro		:=	""
Local	cWhere		:=	""
Local	cCampos		:=	""
Local 	dDataDe		:= aSX1[1]
Local 	dDataAte	:= aSX1[2]
Local 	cNrLivro	:= aSX1[3]
Local	nX			:=	0
Local	nReceita	:=	0
Local	nPercRecMI	:=	0
Local	nPercRecEX	:=	0
Local	nBcCpMI		:=	0
Local	nBcCpEX		:=	0
Local	nDifOutPrd	:=	0
Local	nEntrada	:=	0
Local 	cConta		:= ""
Local 	nLencXCp1	:= len(aMvSpcXCp1)

Local	oApurEFD	:=	nil

// -----------------------------------------------------------------------------------------------------------------------------
//totaliza o valor de receita para proporcionalizar o calculo do credito presumido

cAliasSFT	:=	GetNextAlias()
	
cFiltro := "%"

If (cNrLivro<>"*")
	cFiltro += " SFT.FT_NRLIVRO = '" + cNrLivro + "' "
EndiF

if len( aMvSpcXCp3 ) > 0
	cFiltro	+=	" ("
	for nX := 1 to len( aMvSpcXCp3 )
		cFiltro	+= " SB1.B1_POSIPI LIKE '" + aMvSpcXCp3[ nX ] + "%' OR "
	next nX
	cFiltro	:=	substr( cFiltro , 1 , Len( cFiltro ) - 3 ) + ") AND "
endif

cFiltro	+=	"%"

BeginSql Alias cAliasSFT

	COLUMN FT_EMISSAO AS DATE
	COLUMN FT_ENTRADA AS DATE
	COLUMN FT_DTCANC AS DATE

	SELECT
		SUM(SFT.FT_VALCONT) FT_VALCONT
		
	FROM
		%Table:SFT% SFT
		LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%)
		
	WHERE
		SFT.FT_FILIAL=%xFilial:SFT% AND
		SFT.FT_TIPOMOV = 'S' AND
		SFT.FT_ENTRADA>=%Exp:DToS (dDataDe)% AND
		SFT.FT_ENTRADA<=%Exp:DToS (dDataAte)% AND
		(SFT.FT_DTCANC = ' ' OR SFT.FT_DTCANC > %Exp:DToS (dDataAte)% )  AND
		SFT.FT_TIPO <> 'D' AND
		SFT.FT_CFOP NOT LIKE ( '7%' ) AND
		SFT.FT_CSTPIS = '01' AND SFT.FT_CSTCOF = '01' AND
		%Exp:cFiltro%
		SFT.%NotDel%	

EndSql

if ( cAliasSFT )->FT_VALCONT > 0
	nReceita	:=	( cAliasSFT )->FT_VALCONT		
endif

DbSelectArea( cAliasSFT )
( cAliasSFT )->( dbCloseArea () )
// -----------------------------------------------------------------------------------------------------------------------------

// -----------------------------------------------------------------------------------------------------------------------------

cAliasSFT2	:=	GetNextAlias()

cWhere := "%"

cWhere += "SFT.FT_FILIAL = '" + xFilial('SFT') + "' AND "
cWhere += "SFT.FT_TIPOMOV = 'E' AND "
cWhere += "SFT.FT_ENTRADA >= '" + DToS (dDataDe) + "' AND "
cWhere += "SFT.FT_ENTRADA <= '" + DToS (dDataAte) + "' AND "
cWhere += "(SFT.FT_DTCANC = ' ' OR SFT.FT_DTCANC > '" + DToS (dDataAte) + "' ) AND "
cWhere += "SFT.D_E_L_E_T_ = '' AND "

cCampos := "%"

// para o calculo do credito presumido proporcional, sempre utilizar o CST 64 ou CST 66
cWhere	+=	" ((SFT.FT_CSTPIS = '64'AND SFT.FT_CSTCOF = '64') OR (SFT.FT_CSTPIS = '66'AND SFT.FT_CSTCOF = '66')) AND "

//cWhere	+=	" "
if nLencXCp1>0
	cWhere	+= " ("
	for nX := 1 to nLencXCp1
		cWhere	+= "( SB1.B1_POSIPI LIKE '" + aMvSpcXCp1[ nX ] + "%' ) "
		if nX == nLencXCp1
			cWhere	+= ")"
		endif
		cWhere	+= " OR " 
	next nX
endif

cWhere	:=	substr( cWhere , 1 , Len( cWhere ) - 3 )

If (cNrLivro<>"*")
	cWhere += " AND SFT.FT_NRLIVRO = '" + cNrLivro + "' "
EndiF

cWhere += "%"

BeginSql Alias cAliasSFT2

	COLUMN FT_EMISSAO AS DATE
	COLUMN FT_ENTRADA AS DATE
	COLUMN FT_DTCANC AS DATE

	SELECT
		SUM(SFT.FT_BASEPIS) FT_BASEPIS, FT_CSTPIS, MAX(SFT.FT_CONTA) FT_CONTA
		%Exp:cCampos%
	FROM
		%Table:SFT% SFT
		LEFT JOIN %Table:SB1% SB1 ON(SB1.B1_FILIAL=%xFilial:SB1%  AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.%NotDel%)
	WHERE
		%Exp:cWhere%
	GROUP BY FT_CSTPIS
		
EndSql

DbSelectArea( cAliasSFT2 )
( cAliasSFT2 )->( DbGoTop( ) )

// -----------------------------------------------------------------------------------------------------------------------------

// carrega receita bruta do periodo
oApurEFD := FISX001():New()
oApurEFD:SetFilial(aXFilial)
oApurEFD:SetFilApu(cfilialMat)
oApurEFD:SetRegApur(cRegime)
oApurEFD:SetDtIni(dDataDe)
oApurEFD:SetDtFin(dDataAte)
aRecBruta	:=	oApurEFD:LoadRecBru()

nPercRecMI	:=	( nReceita / ( aRecBruta[ 1 , 1 ] +  aRecBruta[ 1 , 3 ] )  ) //Rec.Trib.NCM / Rec.Bruta Trib. + Rec.Bruta Exp

nPercRecEX	:=	( aRecBruta[ 1 , 3 ] / ( aRecBruta[ 1 , 3 ] +  aRecBruta[ 1 , 2 ] )  ) // Rec.Exp / Rec.Trib.NCM + Rec.Exp 

nDifOutPrd	:=	( nReceita * 100 ) / aRecBruta[ 1 , 1 ]

// -----------------------------------------------------------------------------------------------------------------------------

While !( cAliasSFT2 )->( Eof() )
	if ( cAliasSFT2 )->( FT_BASEPIS ) > 0
		nEntrada	:=	( cAliasSFT2 )->( FT_BASEPIS )
	endif

	cConta		:= ( cAliasSFT2 )->FT_CONTA

	nBcCpMI		:=	nEntrada * nPercRecMI
	nBcCpEX		:=	nEntrada * nPercRecEX
	aCredPres	:=	{ { 0 , 0 } , { 0 , 0 } , { 0 , 0 } }

	//o calculo abaixo eh utilizado para definir os valores de credito presumido de pis e cofins

	//apenas dos produtos informados no parametro MV_SPCXCP3, pois possuem aliquota diferente das demais vendas internas
	//para o calculo do presumido para mercado interno deve ser deduzido o calculo do presumido para exportacao
	if aMvSpcXCp2[ 1 , 1 ] > 0 .and. aMvSpcXCp2[ 3 , 1 ] > 0
		aCredPres[ 1 , 1 ]	:=	( nBcCpMI * ( nDifOutPrd / 100 ) ) * ( aMvSpcXCp2[ 1 , 1 ] / 100 ) - ( nBcCpMI ) * ( aMvSpcXCp2[ 3 , 1 ] / 100 )	//pis para venda nacional dos produtos do parametro MV_SPCXCP3
		aCredPres[ 1 , 2 ]	:=	( nBcCpMI * ( nDifOutPrd / 100 ) ) * ( aMvSpcXCp2[ 1 , 2 ] / 100 ) - ( nBcCpMI ) * ( aMvSpcXCp2[ 3 , 2 ] / 100 )	//cofins para venda nacional dos produtos do parametro MV_SPCXCP3
	endif

	//o calculo abaixo eh utilizado para o credito presumido das vendas internas, com excecao dos produtos que
	//ja foram calculados acima
	if aMvSpcXCp2[ 2 , 1 ] > 0
		aCredPres[ 2 , 1 ]	:=	( nBcCpMI * ( ( ( nDifOutPrd / 100 ) - 1 ) *-1 ) ) * ( aMvSpcXCp2[ 2 , 1 ] / 100 )	//pis para venda nacional
		aCredPres[ 2 , 2 ]	:=	( nBcCpMI * ( ( ( nDifOutPrd / 100 ) - 1 ) *-1 ) ) * ( aMvSpcXCp2[ 2 , 2 ] / 100 )	//cofins para venda nacional
	endif

	if aMvSpcXCp2[ 3 , 1 ] > 0
		aCredPres[ 3 , 1 ]	:=	nBcCpEX * ( aMvSpcXCp2[ 3 , 1 ] / 100 )	//pis exportacao
		aCredPres[ 3 , 2 ]	:=	nBcCpEX * ( aMvSpcXCp2[ 3 , 2 ] / 100 )	//cofins exportacao
	endif

	// -----------------------------------------------------------------------------------------------------------------------------

	for nx := 1 to len(  aCredPres )

		if aCredPres[ nX , 1 ] > 0

			//Passa as informações do ajuste para a classe
			oAjustes:SetTributo( PIS )
			oAjustes:SetTpAjust( ACRESCIMO )
			oAjustes:SetCodAju( GetNewPar( "MV_CAJCPPC" , "03" ) )
			oAjustes:SetDescAju( "Credito Presumido Lei 12.350/2010,10.925/2004" )
			oAjustes:SetVlAju( aCredPres[ nx , 1 ] )
			oAjustes:SetCodDC( Iif(( cAliasSFT2 )->FT_CSTPIS == '66', "306", "106") ) // Caso a CST seja 66 Foi definido para que o ajuste seja feito no 306 ao invés do 106
			
			oAjustes:SetCst( ( cAliasSFT2 )->FT_CSTPIS )
			oAjustes:SetBase( 0 )
			oAjustes:SetAlq( aMvSpcXCp2[ nX , 1 ] ) // Seta a CST com base na query
			
			oAjustes:SetMsmCod(.T.)
			oAjustes:SetConta(cConta)
			oAjustes:SetCrdDeb('1')
			
			//Realiza o Ajuste
			oAjustes:Ajustar()
			
			oAjustes:SetTributo( COFINS )
			oAjustes:SetTpAjust( ACRESCIMO )
			oAjustes:SetCodAju( GetNewPar( "MV_CAJCPPC" , "03" ) )
			oAjustes:SetDescAju( "Credito Presumido Lei 12.350/2010,10.925/2004" )
			oAjustes:SetVlAju( aCredPres[ nX , 2 ] )
			oAjustes:SetCodDC( Iif(( cAliasSFT2 )->FT_CSTPIS == '66', "306", "106") )
			
			oAjustes:SetCst( ( cAliasSFT2 )->FT_CSTPIS )
			oAjustes:SetBase( 0 )
			oAjustes:SetAlq( aMvSpcXCp2[ nX , 2 ] )
			oAjustes:SetConta(cConta)
			oAjustes:SetMsmCod(.T.)
			
			oAjustes:SetCrdDeb('1')
				
			//Realiza o Ajuste
			oAjustes:Ajustar()
			
			//o ajuste deve ser feito apenas para uma situacao, caso seja efetuado ajuste nao continua para os demais
			exit
			
		endif

	next nX

	( cAliasSFT2 )->( DbSkip() )
EndDo

DbSelectArea( cAliasSFT2 )
( cAliasSFT2 )->( DbCloseArea( ) )

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
Static Function A001F130(dDataDe, dDadaAte,	oApurEnt,lIndividu,cFilApu)

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
		oF130:SetParam('CL2_FILAPU',IIf(lIndividu,oF130:BuscaxFil('CL2'),cFilApu))
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
Static Function A001F120(dDataDe, dDadaAte,	oApurEnt,lIndividu,cFilialMat)

Local aProcItem		:= {}
Local oF120			:=	TABELACL2():New()
lOCAL cAliasF120	:= ''  	 
Local lVlrBcExc		:= .F.

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

lVlrBcExc	:= (cAliasF120)->(FieldPos("VLRBCEXC"))>0

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
	oF120:SetParam('CL2_FILAPU',IIf(lIndividu,oF120:BuscaxFil('CL2'),cFilialMat) )
	oF120:SetParam('CL2_CODATF',(cAliasF120)->BEM)
	oF120:SetParam('CL2_ITATF',(cAliasF120)->ITEM)
	oF120:SetParam('CL2_DESATF',(cAliasF120)->DESCRI)
	oF120:SetParam('CL2_CRTCRD','2')//Depreciação	
	
	IF lVlrBcExc
		oF120:SetParam('CL2_VLEXCL',(cAliasF120)->VLRBCEXC)
	EndIF

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
Static Function A001CF8(aSX1,oApurEnt,oApurSai,lProcCred,nTotF100,lPTitEnt,lPTitSai,cDebito,nBsConsorc,lCPRBNF,cFilialMat)
Local dDataDe	:= aSX1[1]
Local dDadaAte	:= aSX1[2]
Local cReg		:= aSX1[6]
Local lIndividu:= (aSX1[15] == 2)
Local cAliasCF8	:= ''
Local cCodPart	:= ''
Local cLoja		:= ''
Local cDtOperCF8	:= '' 
Local lCF8EXCPRB	:= CF8->(FIELDPOS("CF8_EXCPRB")) > 0
Local oF100		:=	TABELACL2():New() //Cria objeto para gravação do F100
Local lEntDeb	:=	.F. 
Local lPart	:= CF8->(FieldPos("CF8_PART")) > 0
Local cPart	:= ""
Local cTab := ""

cAliasCF8	:=	GetNextAlias()

cSelect	:=	'%CF8.*%'

cWhere		:=	"% CF8.CF8_FILIAL= '" +xFilial("CF8")+ "' AND  "
cWhere		+=	"CF8.CF8_DTOPER>='"+DTOS(dDataDe)+"' AND "
cWhere		+=	"CF8.CF8_DTOPER<='"+DTOS(dDadaAte)+"' AND "
If cDebito=="1" // Débito
	cWhere	+= "CF8.CF8_CSTPIS IN ('01','02','03','04','05','06','07','08','09','49','99')  AND %"                
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

DbSelectArea('SA1')
dbSetOrder(01)

DbSelectArea('SA2')
dbSetOrder(01)

DbSelectArea(cAliasCF8)
(cAliasCF8)->(DbGoTop())
Do While !(cAliasCF8)->(Eof())

	cCodPart	:= 	''
	cLoja		:= 	''
	cDtOperCF8	:=	''	
	cCodPart 	:=  Padr((cAliasCF8)->CF8_CLIFOR,TamSx3("A1_COD")[1])+PADR((cAliasCF8)->CF8_LOJA,TamSx3("A1_LOJA")[1])
	cDtOperCF8	:=	Substr(DTOS((cAliasCF8)->CF8_DTOPER),7,2)+Substr(DTOS((cAliasCF8)->CF8_DTOPER),5,2)+Substr(DTOS((cAliasCF8)->CF8_DTOPER),1,4)
	cDescCF8	:=	Formula((cAliasCF8)->CF8_DESCPR)
	//Tratamento para debito de piscof em notas de doação que geram receita
	lEntDeb 	:= CF8->(FieldPos("CF8_DOC"))>0 .And. !Empty((cAliasCF8)->CF8_DOC) .And. (cAliasCF8)->CF8_PART == '2' .And. Alltrim((cAliasCF8)->CF8_INDOPE)$"1/2"

	//Se o campo CF8_PART existir, pego seu conteúdo
	If lPart
		cPart:= ((cAliasCF8)->CF8_PART)
	EndiF

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
				oApurEnt:SetConta((cAliasCF8)->CF8_CODCTA)
		
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
		oApurSai:SetOrigem(Iif(lEntDeb,TITENTRADA,TITSAIDA))		
		oApurSai:SetReceita((cAliasCF8)->CF8_VLOPER)
		oApurSai:SetTNatRec((cAliasCF8)->CF8_TNATRE)
		oApurSai:SetCNatRec((cAliasCF8)->CF8_CNATRE)		
		oApurSai:SetGNatRec((cAliasCF8)->CF8_GRPNC)
		oApurSai:SetDNatRec((cAliasCF8)->CF8_DTFIMN)
		oApurSai:SetCFOP(	'')
		oApurSai:SetConta((cAliasCF8)->CF8_CODCTA)
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

		cTab	:= ""
		If lPart .AND. !Empty(cPart)
			cTab := Iif(cPart == "1" , "SA1" ,"SA2" )			
		Else
			cTab := Iif(Alltrim((cAliasCF8)->CF8_INDOPE) == "0" , "SA2" ,"SA1" )
		EndIF 

		oApurSai:SetExport(.F.)
		IF cTab == "SA1"
			If SA1->(dbSeek(xFilial("SA1") + (cAliasCF8)->CF8_CLIFOR + (cAliasCF8)->CF8_LOJA)) .AND. SA1->A1_EST == 'EX'
				oApurSai:SetExport(.T.)
			EndIf
		ElseIf cTab == "SA2"
			IF SA2->(dbSeek(xFilial("SA2") + (cAliasCF8)->CF8_CLIFOR + (cAliasCF8)->CF8_LOJA)) .AND. SA2->A2_EST == 'EX'
				oApurSai:SetExport(.T.)
			EndIf
		EndIF
		//oApurSai:SetExport(.F.)

		//Aqui somente será gerado bloco F, por exte motivo método abaixo com bloco fixo.
		oApurSai:RecBlocos("F")
	
		oApurSai:GrvResCST(Iif((cAliasCF8)->CF8_RECBRU <> '2' ,.T. ,.F.), "F")
		
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
	oF100:SetParam('CL2_FILAPU',IIf(lIndividu,oF100:BuscaxFil('CL2'),cFilialMat) )
	oF100:SetParam('CL2_IDCF8',(cAliasCF8)->CF8_CODIGO)
	oF100:SetParam('CL2_REGIME',Iif((cAliasCF8)->CF8_TPREG == '2',NAOCUMULAT,CUMULAT))	
	oF100:SetParam('CL2_CLIFOR',(cAliasCF8)->CF8_CLIFOR)
	oF100:SetParam('CL2_LOJA',(cAliasCF8)->CF8_LOJA)
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
Static Function A001F100Fi(aSX1,oApurEnt,oApurSai,lProcCred,nTotF100,lPTitEnt,lPTitSai,cReg,cDeb,aF100,lCPRBNF,cFilialMat)

Local nPos			:= 0
Local dDataDe 		:= aSX1[1]
Local dDadaAte		:= aSX1[2]
Local lIndividu		:= (aSX1[15] == 2)
Local oF100			:=	TABELACL2():New()
Local cIndOper		:= ''
Local lGravaF100	:= .F.	
Local cIndOrig		:= ''
Local cNumTit		:= ''
Local cPrefixo		:= ''
Local cParcela		:= ''
Local cInfComp		:= ''
Local cDescr		:= ''
Local cAlsSA		:= ''
Local lAliasPart	:= Cl2->(FIELDPOS('CL2_ALIAS')) > 0
Local cConta		:= ""
Local lEFDCON03		:= ExistBlock("EFDCON03")

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
				//Executa ponto de entrada que altera conta contábil do registro F100
				If lEFDCON03
					//Chamar ponto de entrada
					cConta	:= ExEFDCON03( aF100[nPos][15], aF100[nPos][16] )
				Else
					cConta	:= Iif( Len( aF100[nPos] ) > 22, aF100[nPos][23] , "" )
				EndIF

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

		//Executa ponto de entrada que altera conta contábil do registro F100
		If lEFDCON03
			//Chamar ponto de entrada
			cConta	:= ExEFDCON03( aF100[nPos][15], aF100[nPos][16] )
		Else
			cConta	:= Iif( Len( aF100[nPos] ) > 22, aF100[nPos][23] , "" )
		EndIF

		nTotF100 += Iif(Len(aF100[nPos]) >= 34 .And. aF100[nPos][34] <> "2", aF100[nPos][2], 0)
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

		oApurSai:SetConta( cConta )
			
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

		//Aqui também somente será gerado informações do bloco F.
		oApurSai:RecBlocos("F")
	
		oApurSai:GrvResCST(Iif(Len(aF100[nPos])>=33,Iif(aF100[nPos][33] <> '2' ,.T. ,.F.),.T.), "F")
			
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
		oF100:SetParam('CL2_CTA', cConta )		
		oF100:SetParam('CL2_CCUS',Iif(Len(aF100[nPos])>23, aF100[nPos][24], ""))		
		//oF100:SetParam('CL2_DESCR',Iif(len(aF100[nPos]) >=29,aF100[nPos][29],"" ))
		oF100:SetParam('CL2_INDPRO',aF100[nPos][28])		
		oF100:SetParam('CL2_NUMPRO',aF100[nPos][27])
		oF100:SetParam('CL2_ORICRD','0')
		oF100:SetParam('CL2_FILAPU',IIf(lIndividu,oF100:BuscaxFil('CL2'),cFilialMat) )		
		oF100:SetParam('CL2_CLIFOR' , Substr(aF100[nPos][17] , 1                       , TamSx3("A1_COD")[1])  )
		oF100:SetParam('CL2_LOJA'   , Substr(aF100[nPos][17] , TamSx3("A1_COD")[1] + 1 , TamSx3("A1_LOJA")[1]) )
		
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
		IF Len(aF100[nPos])>=32 .and. aF100[nPos][32] == "P"	
			cAlsSA   := "SA2"
		Elseif Len(aF100[nPos])>=32 .and. aF100[nPos][32] == "R"
			cAlsSA   := "SA1"
		Else
			IF cIndOper == "0" // Movimentação de entrada, irei buscar na SA2 - Fornecedor
				cAlsSA   := "SA2"
			Else // Se for venda, irei buscar cliente na SA1
				cAlsSA   := "SA1"
			EndIF
		Endif
		If lAliasPart
			oF100:SetParam('CL2_ALIAS',cAlsSA)
		EndIF
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
Static Function A001SFTEnt(dDataDe, dDadaAte,oApurEFD,lCPRBNF,aXFilial)

local cAliasSFT	:= 'SFT'
local cSlctSFT	:= ''
Local cFiltro		:= ''
local cGroupBy	:= ''
Local cFrom		:= ''
Local oCPRB := Nil
Local lAtuCPRB := .F.

If lCPRBNF
	oCPRB:=CPRBEFD():New()
	oCPRB:SetDtIni(dDataDe)
	oCPRB:SetFilial(aXFilial)
Endif

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
	If oApurEFD:ChkRegraNf((cAliasSFT)->FT_ESPECIE,(cAliasSFT)->FT_CFOP,NFENTRADA,,,(cAliasSFT)->FT_CSTPIS) 		
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
		oApurEFD:SetAgrIndust(oApurEFD:isAgrIndust())
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
		oApurEFD:SetAgrIndust(oApurEFD:isAgrIndust())
		oApurEFD:OperPauta()
		oApurEFD:AgrpCred()		
		
		//Agrupa valores para resumo de CST
		oApurEFD:GrvResCST()		
		oApurEFD:SetImport(.F.)	

		/* Retirada dedução de base do CPRB neste local, pois esta rotina ja é executada na função ASA001Devo, que causava dedução de base duplicada para notas de devolução
		If lCPRBNF .and. (cAliasSFT)->FT_TIPO == 'D' .And. !Empty((cAliasSFT)->FT_ATIVCPB)
			lAtuCPRB := .T.
			oCPRB:SetDtRefer(dDataDe)
			oCPRB:SetCodAtiv((cAliasSFT)->FT_ATIVCPB)
			oCPRB:DeduzBase((cAliasSFT)->FT_ATIVCPB,(cAliasSFT)->FT_ALIQCPB,(cAliasSFT)->FT_BASECPB,(cAliasSFT)->FT_VALCONT)
			oCPRB:DetalhCPRB()
		Endif
		*/
	EndIF	

	(cAliasSFT)->(DbSkip ())			
EndDo

If lCPRBNF .And. lAtuCPRB
	//Grava os valores alterados.
	oCPRB:GravaCPRB()
Endif

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
Static Function A001SFTSai(dDataDe,dDadaAte,oApurEFD,nM996Tpr,cReg,lCPRBNF,cSPCBPSE,cReg2,aXFilial,cFilialMat,lindividu,aParSX1)

local cAliasSFT	:= 'SFT'
local cSlctSFT	:= ''
Local cFiltro	:= ''
local cGroupBy	:= ''
Local cFrom		:= ''
Local lPeWhere	:= ExistBlock("EFDCON01")
Local lPeBase	:= ExistBlock("EFDCON02")
Local lPeCTB	:= ExistBlock("SPDPIS07")
Local nBaseCalc	:= 0
Local lValdAux	:= .F.
Local lAtuCPRB	:= .F.
Local cModNF		:= ''  
Local lMoto		:= .F.
Local nReceita	:= 0
Local cRegime	:= ""
Local cOutRec	:= SuperGetMv("MV_CODGEN",.F.,"")
Local lNTrib 	:= CKX->(FieldPos('CKX_NTRIB'))>0 .And. !EmpTy(cOutRec)
Local cMVEstado	 :=  GetNewPar("MV_ESTADO","") 
Local cMVSUBTRIB :=  SpedPrSeq("MV_SUBTRI")
Local cMVCFE210	 :=	LeParSeq("MV_CFE210","1410,1411,1414,1415,1660,1661,1662,2410,2411,2414,2415,2660,2661,2662")
Local cStUfs	:= GetNewPar("MV_STUFS","") 
Local cStUf		:= GetNewPar("MV_STUF","") 
Local lRESF3FT	:= GetNewPar("MV_RESF3FT",.F.)
Local lDSTRB 	:= GetNewPar("MV_DSTRB",.F.)
Local lIPIRB    := GetNewPar("MV_DIPIRB",.F.) 												 
Local cSTNIEUF	:= GetNewPar("MV_STNIEUF","")
Local cMV_EXPIND := GetNewPar("MV_EXPIND","") //"5501", "5502", "6501", "6502"
Local nValST	:= 0
Local nValExport:= 0
Local cConta := ""
Local nPos		:= 0
Local lDFSRVAC	:= GetNewPar("MV_DFSRVAC",.F.)
Local cBloco	:= ""
Local cAliasSON	:= ""
Local nValipi   := 0	
Local nDescZFR	:= 0
		

DbSelectArea (cAliasSFT)
(cAliasSFT)->(DbSetOrder(2))
cAliasSFT	:=	GetNextAlias()

//traz campos para fazer from e join 
cFrom    := oApurEFD:GetJoinFrm(nM996Tpr,lPeWhere,NFSAIDA)
//Chama método para retornar campos de forma agrupada
lGroup := Iif(lPeWhere .Or. lPeCTB .Or. lPeBase , .F.,.T.)
cSlctSFT := oApurEFD:GetCmpSFT(nM996Tpr,lGroup,lPeWhere)
//Chama método para voltar filtro das operações de saídas
cFiltro  := oApurEFD:GetWhrSFT(NFSAIDA)

cFiltro := '%' + cFiltro + '%'

//Chama método para retornar group by de saída
If !lPeWhere .And. !lPeBase .And. !lPeCTB
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
	nValExport	:= 0
	If lPeBase
		nBaseCalc := 0
		nBaseCalc := ExecBlock("EFDCON02",.F.,.F.,{(cAliasSFT)})
		//Processa ponto de entrada passando chave da nota
		//Se retornar valor zero, deverá pular a geração desta nota
		If nBaseCalc == 0
			lValdAux := .F.
		EndIf
	EndIF
	cModNF := ''
	If oApurEFD:ChkRegraNf((cAliasSFT)->FT_ESPECIE,(cAliasSFT)->FT_CFOP,NFSAIDA,,@cModNF,(cAliasSFT)->FT_CSTPIS) .AND. lValdAux

		If lPeCTB
			cConta := ""
			cConta	:=	ExecBlock("SPDPIS07", .F., .F., {	(cAliasSFT)->FT_FILIAL,;
			(cAliasSFT)->FT_TIPOMOV,;
			(cAliasSFT)->FT_SERIE,;
			(cAliasSFT)->FT_NFISCAL,;
			(cAliasSFT)->FT_CLIEFOR,;
			(cAliasSFT)->FT_LOJA,;
			(cAliasSFT)->FT_ITEM,;
			(cAliasSFT)->FT_PRODUTO,;
			(cAliasSFT)->FT_CONTA})
		Endif

		//---------------------
		//Informações da nota
		//---------------------


		//Busca valor de ICMS ST para abater do registro 0111 caso o parâmetro MV_DSTRB esteja habilitado 
		IF lDSTRB
			nValST	:= FSA008VLST(cAliasSFT,'2',cMVEstado,cMVSUBTRIB,cMVCFE210, cStUfs , cStUf , lRESF3FT, cSTNIEUF)		
			oApurEFD:setIcmsSt( nValST )
		EndIF
		//Busca valor dO IPI para abater do registro 0111 caso o parâmetro MV_DIPIRB esteja habilitado
		IF lIPIRB 
		    nValipi :=(cAliasSFT)->FT_VALIPI
			oApurEFD:setValIpi( nValipi )
		Endif

		nDescZFR := Iif((cAliasSFT)->FT_TIPO <> "D",(cAliasSFT)->FT_DESCZFR,0)

		oApurEFD:SetOrigem(FISCALSAI)
		oApurEFD:SetCFOP(	(cAliasSFT)->FT_CFOP)
		If cModNF $'07/08/09/10/11/26/27/57/67/8B' //Alteração realizada para que gere a partir do FT_VALCONT na Apuração e no arquivo magnético para as especies identificadas.
			nReceita:= (cAliasSFT)->FT_VALCONT 
			oApurEFD:SetReceita(nReceita)
		Else			
			nReceita:= Iif(cReg == 2 .And. cReg2 == 1,(cAliasSFT)->FT_VALCONT + (cAliasSFT)->FT_DESCONT -(nValipi + nValST),(cAliasSFT)->FT_TOTAL + nDescZFR) 
			oApurEFD:SetReceita(nReceita)
		Endif

		oApurEFD:SetEspecie((cAliasSFT)->FT_ESPECIE)
		oApurEFD:SetTNatRec((cAliasSFT)->FT_TNATREC) 
		oApurEFD:SetCNatRec((cAliasSFT)->FT_CNATREC)
		oApurEFD:SetGNatRec((cAliasSFT)->FT_GRUPONC)
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
		oApurEFD:SetVlPauta((cAliasSFT)->FT_PAUTPIS)
		oApurEFD:SetConta((cAliasSFT)->FT_CONTA)

		If !lPeCTB
			oApurEFD:SetConta((cAliasSFT)->FT_CONTA)
		Else
			oApurEFD:SetConta(cConta)
		EndIf

		IF lPeBase
			oApurEFD:SetBcTrib(nBaseCalc)
			oApurEFD:SetValTrib(nBaseCalc *(cAliasSFT)->FT_ALIQPIS / 100)
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
		oApurEFD:SetVlPauta((cAliasSFT)->FT_PAUTCOF)
		oApurEFD:SetConta((cAliasSFT)->FT_CONTA)
		
		If !lPeCTB
			oApurEFD:SetConta((cAliasSFT)->FT_CONTA)
		Else
			oApurEFD:SetConta(cConta)
		EndIf

		IF lPeBase
			oApurEFD:SetBcTrib(nBaseCalc)
			oApurEFD:SetValTrib(nBaseCalc *(cAliasSFT)->FT_ALIQCOF / 100)
		EndIF

		oApurEFD:AgrpContr()
		
		//---------------------------------------------------------
		//Identificar qual bloco esta receita pertence, A, C ou D.		
		//---------------------------------------------------------
		IF Empty(cModNF) .OR. (!lDFSRVAC .AND. cModNF == '55' .AND. cMVEstado == 'DF') 
			//Bloco A
			cBloco	:= "A"
		ElseIf cModNF $ '07/08/09/10/11/26/27/57/63/67/8B/13/18/21/22'
			//Bloco D
			cBloco	:= "D"
		Else
			//BLoco C
			cBloco	:= "C"
		EndIF		
		
		//Método que acumula as receitas por blocos A, C, D e F.
		oApurEFD:RecBlocos(cBloco)		

		//Grava CST PIS COFINS ST
		IF lMoto
			oApurEFD:SetCST((cAliasSFT)->FT_CSTCOF)
			oApurEFD:SetBcTrib((cAliasSFT)->FT_BASECF3)
			oApurEFD:SetReceita(0)
			cRegime := oApurEFD:GetRegOpe()
			oApurEFD:SetRegOpe('2') //Quando for PIS COFINS ST Sempre grava como cumulativo Aliq: 0.65 e 3
			oApurEFD:GrvResCST(,cBloco)
			
			//Restauda valores			
			oApurEFD:SetRegOpe(cRegime)
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
			oCPRB:SetVlBrut((cAliasSFT)->FT_VALCONT + (cAliasSFT)->FT_DESCONT - nValipi -nValST)
			
			If SubStr((cAliasSFT)->FT_CFOP,1,1) == "7" .Or. Alltrim((cAliasSFT)->FT_CFOP)$cMV_EXPIND //Acumula valor de receita exportação											
				nValExport := (cAliasSFT)->FT_VALCONT					 
			EndIf

			If !Empty((cAliasSFT)->FT_ATIVCPB)            
				nExclusao = (cAliasSFT)->FT_DESCONT + nValExport

				If !lIPIRB
					nExclusao += (cAliasSFT)->FT_VALIPI
				EndIF

				If !lDSTRB .And.  oCPRB:GetVlBrut() - (cAliasSFT)->FT_ICMSRET >= Max((cAliasSFT)->FT_BASECPB - nValExport, 0)
					nExclusao += (cAliasSFT)->FT_ICMSRET
				EndIF
			Else
			nExclusao = 0

			EndIF           
            oCPRB:SetVlExcl(nExclusao)
			oCPRB:SetVlCPRB(IIF(nValExport > 0, 0, (cAliasSFT)->FT_VALCPB))
			oCPRB:SetAliq((cAliasSFT)->FT_ALIQCPB)
			oCPRB:SetBase(Max((cAliasSFT)->FT_BASECPB - nValExport, 0))// Aqui devo retirar o valor da base e validar para nao gerar valor negativo pois quando exportação o matxfis ainda nao gera o valor da base do CPRB zerada.
			oCPRB:SetVlAtiv((cAliasSFT)->FT_VALCONT + (cAliasSFT)->FT_DESCONT - nValipi -nValST)
			oCPRB:SetVlAtiv(Iif((cAliasSFT)->FT_VALCPB > 0,(cAliasSFT)->FT_VALCONT + (cAliasSFT)->FT_DESCONT - nValipi -nValST,0))
			oCPRB:SetConta((cAliasSFT)->FT_CONTA)
			oCPRB:SetCodRec(Iif(AllTrim((cAliasSFT)->FT_ATIVCPB)$cSPCBPSE,aParSX1[16],aParSX1[17])) 
			oCPRB:SetFilApu(IIf(lIndividu,oCPRB:BuscaxFil('CKY'),cFilialMat)) 
			// Verifica se codigo é não desonerado
			If lNTrib
				IF (cAliasSFT)->FT_ATIVCPB $ cOutRec
					oCPRB:SetNTrib(.T.)					
				Endif
			Endif

			oCPRB:AgrupaCPRB()

			If !Empty((cAliasSFT)->FT_ATIVCPB) .And. AliasIndic('F2S')
				If (cAliasSFT)->FT_VALIPI > 0
					oCPRB:SetDetExcl('07', (cAliasSFT)->FT_VALIPI, 'IPI')
					oCPRB:DetalhCPRB()
				EndIf
				If(cAliasSFT)->FT_ICMSRET > 0
					oCPRB:SetDetExcl('08', (cAliasSFT)->FT_ICMSRET,'ICMS-ST')
					oCPRB:DetalhCPRB()
				EndIf
			EndIf

		Endif

		//Conforme consultoria tributária o campo 06 do registro 0111, o campo 03 do registro 0145 e o campo 04 do registro P100 devem possuir o mesmo valor de receita bruta
		oApurEFD:SetReceita((cAliasSFT)->FT_TOTAL + nDescZFR)
		oApurEFD:SetRecBrut((cAliasSFT)->FT_VALCONT + (cAliasSFT)->FT_DESCONT + nDescZFR)
		oApurEFD:AcumRecBru()
		//Passo FT_VALCONT neste trecho somente para que a primeira aba da apuração o valor da receita seja o valor contábil, considerando
		//valores de despesas acessórias, frete,seguro, desconto etc...
		oApurEFD:SetReceita((cAliasSFT)->FT_VALCONT + (cAliasSFT)->FT_DESCONT - nValipi - nValST)   
		oApurEFD:GrvResCST(.F.,"P")
		oApurEFD:setIcmsSt(0)

	EndIF

	(cAliasSFT)->(DbSkip ())
EndDo

If AliasIndic("F3Z") .AND. lCPRBNF
	cAliasSON	:=	GetNextAlias()
	CPRBxCNO(@cAliasSON, oApurEFD)

	Do While !(cAliasSON)->(Eof())
		
		cModNF := ''
		If oApurEFD:ChkRegraNf((cAliasSON)->FT_ESPECIE,(cAliasSON)->FT_CFOP,NFSAIDA,,@cModNF,(cAliasSFT)->FT_CSTPIS)
			oCPRB:SetDtRefer(dDataDe)
			oCPRB:SetCodAtiv((cAliasSON)->FT_ATIVCPB)
			oCPRB:SetVlBrut((cAliasSON)->FT_VALCONT + (cAliasSON)->FT_DESCONT - nValipi -nValST) 
			If !Empty((cAliasSON)->FT_ATIVCPB)             
				nExclusao = (cAliasSON)->FT_DESCONT + nValExport

				If !lIPIRB
					nExclusao += (cAliasSON)->FT_VALIPI
				EndIF

				If !lDSTRB
					nExclusao += (cAliasSON)->FT_ICMSRET
				EndIF
			Else
			nExclusao = 0
			EndIF 
			oCPRB:SetVlExcl(nExclusao) 
			oCPRB:SetVlCPRB((cAliasSON)->FT_VALCPB)
			oCPRB:SetAliq((cAliasSON)->FT_ALIQCPB)
			oCPRB:SetBase((cAliasSON)->FT_BASECPB) 
			oCPRB:SetVlAtiv((cAliasSON)->FT_VALCONT + (cAliasSON)->FT_DESCONT - nValipi -nValST) 
			oCPRB:SetVlAtiv(Iif((cAliasSON)->FT_VALCPB > 0,(cAliasSON)->FT_VALCONT + (cAliasSON)->FT_DESCONT - nValipi -nValST,0))
			oCPRB:SetConta((cAliasSON)->FT_CONTA)
			oCPRB:SetFilApu(IIf(lIndividu,oCPRB:BuscaxFil('F3Z'),cFilialMat)) 
			oCPRB:SetCNO((cAliasSON)->ON_CNO)

			oCPRB:CNOxCPRB()
		EndIf

		(cAliasSON)->(DbSkip())
	EndDo
	
	(cAliasSON)->(DbCloseArea())
EndIf

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
Static Function A001Difer(dDataDe,dDataAte,aXFilial,cTabDif)
Local cAliasCFA		:= 'CFA'
Local cAliasCFB		:= 'CFB'
Local	aTpContr		:=	{"PIS","COF"}
Local cSelect			:= ''
Local cWhere			:= ''
Local	cPeriod		:=	Substr(DTOS(dDataDe),5,2)+Substr(DTOS(dDataDe),1,4)
Local nCont			:= 0
Local oDifer			
Local lNewProc		:= ISA001NDIF()   
Local aRegM300		:={}
Local aRegM700		:={}

Default cTabDif := "3"

//Cria objeto para tratar os valores da apuração
oDifer 	:= DIFPISCOF():New()
oDifer:SetFilial(aXFilial)
oDifer:SetDtIni(dDataDe)
oDifer:LoadDebito()
oDifer:LoadCredit()

For nCont := 1 to Len(aTpContr)
	
	If cTabDif $"1|3"

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
		
	EndIf
	
	If cTabDif $"2|3"

		cAliasCFB	:=	GetNextAlias()
		cSelect		:=	"%CFB.CFB_CODCON, CFB.CFB_TPCON, CFB.CFB_DTPGTO, CFB.CFB_PERDIF, CFB.CFB_CONREC, "
		cSelect		+=	"CFB.CFB_VLRREC,CFB.CFB_PERAPU, CFB.CFB_ALIQ,CFB.CFB_NATCRE, CFB.CFB_CREDES%"
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
		
		
		
	//********************************************************************************************************************************
	// Criando Array valores diferidos em períodos anteriores  
		
		
		aAdd(aRegM300, {})		
		nPos := Len(aRegM300)
		aAdd (aRegM300[npos],"M300")									//01 - REG		
		aAdd (aRegM300[nPos],(cAliasCFB)->CFB_CODCON)				   	//02 - COD. CONTRIBUICAO (preencher conforme tabela descrita no layout)		
		aAdd (aRegM300[nPos],(cAliasCFB)->CFB_VLRREC)					//03 - VALOR APURADO		
		aAdd (aRegM300[nPos],(cAliasCFB)->CFB_NATCRE)					//04 - NAT. CREDITO DIFERIDO		
		aAdd (aRegM300[nPos],(cAliasCFB)->CFB_CREDES)					//05 - VALRO CRED. DESCONTAR		
		aAdd (aRegM300[nPos],(cAliasCFB)->CFB_CONREC)			 		//06 - VALOR CONTRIBUICAO A RECOLHER		
		aAdd (aRegM300[nPos],(cAliasCFB)->CFB_PERAPU)					//07 - PERIODO DA APURACAO (MMAAAA)		
		aAdd (aRegM300[nPos],(cAliasCFB)->CFB_PERDIF)					//08 - DATA RECEBIMENTO				
		
		
		aAdd(aRegM700, {})		
		nPos := Len(aRegM700)
		aAdd (aRegM700[npos],"M700")									//01 - REG		
		aAdd (aRegM700[nPos],(cAliasCFB)->CFB_CODCON)					//02 - COD. CONTRIBUICAO (preencher conforme tabela descrita no layout)		
		aAdd (aRegM700[nPos],(cAliasCFB)->CFB_VLRREC)					//03 - VALOR APURADO		
		aAdd (aRegM700[nPos],(cAliasCFB)->CFB_NATCRE)					//04 - NAT. CREDITO DIFERIDO		
		aAdd (aRegM700[nPos],(cAliasCFB)->CFB_CREDES)					//05 - VALRO CRED. DESCONTAR		
		aAdd (aRegM700[nPos],(cAliasCFB)->CFB_CONREC)			 		//06 - VALOR CONTRIBUICAO A RECOLHER		
		aAdd (aRegM700[nPos],(cAliasCFB)->CFB_PERAPU)					//07 - PERIODO DA APURACAO (MMAAAA)		
		aAdd (aRegM700[nPos],(cAliasCFB)->CFB_PERDIF)					//08 - DATA RECEBIMENTO

	//*************************************************************************************************************************************

		oDifer:FechaAlias(cAliasCFB)

	EndIf

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
	A001PEDFAN(dDataDe,dDataAte,oDifer,aRegM300,aRegM700)
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
Static Function A001F700(dDataDe,cRegime,oApurPIS,oApurCof,aXFilial,cFilialMat)

Local cSelect			:= ''
Local cWhere			:= ''
Local cAliasCF2			:= ''
Local cIndNat			:= ''
Local cPerido			:= strzero(Month(dDataDe),2)+str(Year(dDataDe),4)
Local oOutDed
Local lConta			:= CF2->(FieldPos("CF2_CONTA") > 0)

oOutDed := DEDUCAOPC():New() 
oOutDed:SetFilial(aXFilial)
oOutDed:SetDtIni(dDataDe)
oOutDed:SetTpDed('1') // Indica que será realizado dedução referente a outras deduções.
oOutDed:SetFilApu(cFilialMat) // Indica que será realizado dedução referente a outras deduções.

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
	oOutDed:SetConta(Iif(lConta,(cAliasCF2)->CF2_CONTA,""))
	oOutDed:Deduz(oApurPIS)

	//------------------------
	//FAZ A DEDUÇÃO DA COFINS
	//------------------------
	oOutDed:SetTributo(COFINS)
	oOutDed:SetValDed((cAliasCF2)->CF2_DEDCOF)
	oOutDed:SetRegime(IiF((cAliasCF2)->CF2_INDNAT=='0',NAOCUMULAT,CUMULAT))
	oOutDed:SetConta(Iif(lConta,(cAliasCF2)->CF2_CONTA,""))	
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

Static Function DeduzReten(dDataDe,dDataAte,aXFilial,oApurPis,oApurCof,cCtlDedRet,cFilialMat)

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

			//Quando saldo desbloqueado é necessario decrescer o valor de (Ressarcimento+Compensacao) do valor da dedução(VLDISP) a ser realizada(gravada) na CKR.
			oOutRet:SetValDed(aSaldo[nCont][6] - IIF(aSaldo[nCont][10] $ "2", (aSaldo[nCont][8] + aSaldo[nCont][9]), 0))

			oOutRet:SetVlDisp(aSaldo[nCont][6])  //aSaldo,(cAlias)->VLDISP  6
			oOutRet:SetApurPer(cPerAtu)

			oOutRet:SetTotRet(aSaldo[nCont][5])  //aSaldo,(cAlias)->TOTRET  5
			oOutRet:SetRessar(aSaldo[nCont][8])  //aSaldo,(cAlias)->RESSA   8
			oOutRet:SetCompen(aSaldo[nCont][9])  //aSaldo,(cAlias)->COMP    9
			oOutRet:SetBloque(aSaldo[nCont][10]) //aSaldo,(cAlias)->RESRET  10

			oOutRet:SetRegime(aSaldo[nCont][4])
			oOutRet:SetNatRet(aSaldo[nCont][1])
			oOutRet:SetMesAno(aSaldo[nCont][3])
			oOutRet:SetPergrva(cPerAtu)			

			//Quando somatoria de Ressarcimento e Compensação ja forem iguais ao Valor Disponivel, significa que neste mes o valor das retencoes ja foram consumidos. 
			If aSaldo[nCont][6] > (aSaldo[nCont][8] + aSaldo[nCont][9]) .Or. aSaldo[nCont][10] $ " 2"

				//Quando periodos anteriores seto o parametro /*lPerAnt*/ para que o metodo Deduz, analise a tabela SFV|SFW 
				//de forma a analisar e incluir dados de historico de retencoes 
				oOutRet:Deduz(Iif (nContAnt==1 ,oApurPIS ,oApurCOF  ), lSaldo, /*lPerAnt*/ .T.)
			EndIf	
		
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
	
	lSaldo := .F.
	
	if !(cAliasCKY)->(EOF())
		//Carrega as informações atualizadas da apuração
		oApurPIS:LoadApurPC(PIS)
		
		//Carrega as informações atualizadas da apuração
		oApurCof:LoadApurPC(COFINS)
	endif
	
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
	oF600:SetParam('CKY_CODREC',Iif(Len(aF600Aux[nCont])>11,aF600Aux[nCont][12],""))
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
Static Function A001PEF100(aSX1,oApurSai,oApurEnt,lProcCred,lPTitEnt, lPTitSai,cReg, cCredDeb,cFilialMat)
Local dDataDe := aSX1[1]
Local dDataAte:= aSX1[2]
Local lIndividu:=(aSX1[15]==2)
Local aPEF100		:= {}
Local x			:= 0
Local oF100		:=	TABELACL2():New() //Cria objeto para gravação do F100
Local lGravaF100	:= .F.
local cAlsPart	:= ''
Local lAliasPart	:= Cl2->(FIELDPOS('CL2_ALIAS')) > 0

aPEF100 := ExecBlock("SPDPIS09",.F.,.F.,{FWGETCODFILIAL,dDataDe,dDataAte})
For x := 1 To Len(aPEF100)
	lGravaF100	:= .F.                                           	
	If aPEF100[x][2] == "0"  //Entradas
		If lProcCred		
			If lPTitEnt .AND. cCredDeb == '2'
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
				lGravaF100	:= .T.
			EndIF
		EndIF

	ElseIf lPTitSai .AND. cCredDeb == '1'
		//---------------------
		//Informações da nota
		//---------------------
		oApurSai:SetOrigem(TITSAIDA)
		oApurSai:SetReceita(aPEF100[x][6])
		oApurSai:SetTNatRec(aPEF100[x][42])
		oApurSai:SetCNatRec(aPEF100[x][43])		
		oApurSai:SetGNatRec(aPEF100[x][44])
		oApurSai:SetDNatRec(aPEF100[x][45])
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

		//Bloco fixo, pois este ponto de entrada somente gera receita no bloco F.
		oApurSai:RecBlocos("F")

		oApurSai:GrvResCST(,"F")
		lGravaF100	:= .T.
			
	EndIF
	 			 
	//gravar cl2

	//ABAIXO GRAVA OS VALORES DO REGISTRO F100 COM DÉBITO
	//---------------------------------------------------
	If lGravaF100
		oF100:SetParam('CL2_PER',dDataDe)
		oF100:SetParam('CL2_REG','F100')
		oF100:SetParam('CL2_INDOP',aPEF100[x][2]) //ok
		oF100:SetParam('CL2_PARTI',aPEF100[x][3]+aPEF100[x][20])//ok
		oF100:SetParam('CL2_ITEM',aPEF100[x][4])//OK
		If Valtype(aPEF100[x][5]) == 'C'
			oF100:SetParam('CL2_DTOPER',ctod(SubStr(aPEF100[x][5],1,2)+"/"+SubStr(aPEF100[x][5],3,2)+"/"+SubStr(aPEF100[x][5],5,4))) //OK
		ElseIf Valtype(aPEF100[x][5]) == 'D'
			oF100:SetParam('CL2_DTOPER',aPEF100[x][5]) //OK
		EndIF		
		oF100:SetParam('CL2_VLOPER',aPEF100[x][6]) //ok
		oF100:SetParam('CL2_CSTPIS',aPEF100[x][7])//ok		
		oF100:SetParam('CL2_BCPIS',aPEF100[x][8])		 //ok
		oF100:SetParam('CL2_ALQPIS',aPEF100[x][9])	//ok	
		oF100:SetParam('CL2_VLPIS',aPEF100[x][10])	//ok	
		oF100:SetParam('CL2_CSTCOF',aPEF100[x][11])	//ok	
		oF100:SetParam('CL2_BCCOF',aPEF100[x][12])		//ok
		oF100:SetParam('CL2_ALQCOF',aPEF100[x][13])	//ok	
		oF100:SetParam('CL2_VLCOF',aPEF100[x][14])	//ok	
		oF100:SetParam('CL2_CODBCC',aPEF100[x][15]) //ok
		oF100:SetParam('CL2_INDCRD',aPEF100[x][16]) //verificar
		oF100:SetParam('CL2_CTA',aPEF100[x][17]) //ok		
		oF100:SetParam('CL2_CCUS',aPEF100[x][18])		//ok
		oF100:SetParam('CL2_DESCR',aPEF100[x][19])
		oF100:SetParam('CL2_FILAPU',IIf(lIndividu,oF100:BuscaxFil('CL2'),cFilialMat) )
		oF100:SetParam('CL2_CLIFOR' , aPEF100[x][3]  )
		oF100:SetParam('CL2_LOJA'   , aPEF100[x][20] )


		IF lAliasPart
			If Len(aPEF100[x]) >= 49
				cAlsPart	:= 	aPEF100[x][49]
			ElseIF aPEF100[x][2] == "0"
				cAlsPart	:= 	'SA2'
			Else
				cAlsPart	:= 	'SA1'
			EndIF
			oF100:SetParam('CL2_ALIAS',cAlsPart)
		EndIF		

		oF100:Save()	 	
	EndIF
Next x
FreeObj(oF100)
oF100:= Nil

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
	
			oApurSai:GrvResCST(,"D")

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

Static Function A001PEDFAN(dDataDe,dDataAte,oDifer,aRegM300,aRegM700)

Local aSPDPCAnt	:= {}
Local aRegMX00	:= {}
Local nCont		:= 0

Default aRegM300 	:= {}
Default aRegM700 	:= {}
  

//-----------------------------------------------------------------------------------
//FAZ CHAMADA PARA O PONTO DE ENTRADA DE CONTRIBUIÇÃO DIFERIDA EM PERÍODOS ANTERIORES
//-----------------------------------------------------------------------------------
aSPDPCAnt := ExecBlock("SPDPCANT", .F., .F., {aRegM300,aRegM700,dDataDe,dDataAte } )

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
Static Function A001IMOB(dDataDe,dDataAte,oApurSai,oApurEnt,lProcCred,cReg,lEntrada,lSaida)

Local aRetImob		:= {}
Local nX			:= 0
Local nY			:= 0
Local cCumulat   	:= '1'
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
		
		If lSaida
			oApurSai:SetReceita(aRegF200[11])
			If cReg == 4			 
				oApurSai:SetTpReg(Iif(aRegF200[23] == "0",CUMULAT,NAOCUMULAT))			
			EndIF
			oApurSai:SetAtvImob(.T.)

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
			oApurSai:GrvResCST(,"F")

			//Receitas com origem do bloco F.
			oApurSai:RecBlocos("F")

		Endif

		IF lProcCred .And. lEntrada // .And. cCumulat == '1' //Não cumulativo		

			oApurEnt:SetAtvImob(.T.)
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
				oApurEnt:SetReceita(aRegF205[7])
				oApurEnt:SetCodBcc('15') //Código exclusivo para crédito de custo incorrido na unidade imobiliária
		
				//-------------------------------------------------------------------
				//Informações de PIS
				//-------------------------------------------------------------------			
				oApurEnt:SetTributo(PIS)
				oApurEnt:SetCST(aRegF205[8])		
				oApurEnt:SetAlqTrib(aRegF205[9])
				oApurEnt:SetBcTrib(aRegF205[7])
				oApurEnt:SetValTrib(aRegF205[12]) 
				oApurEnt:AgrpCred()		
		
				//-------------------------------------------------------------------
				//Informações da COFINS
				//-------------------------------------------------------------------		
				oApurEnt:SetTributo(COFINS)		
				oApurEnt:SetCST(aRegF205[14])
				oApurEnt:SetAlqTrib(aRegF205[15])
				oApurEnt:SetBcTrib(aRegF205[7])
				oApurEnt:SetValTrib(aRegF205[18])
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
							oApurEnt:SetReceita(aRegF210[nY][6])
							oApurEnt:SetCodBcc('16') //Código exclusivo para crédito de custo incorrido na unidade imobiliária
					
							//-------------------------------------------------------------------
							//Informações de PIS
							//-------------------------------------------------------------------			
							oApurEnt:SetTributo(PIS)
							oApurEnt:SetCST(aRegF210[nY][7])		
							oApurEnt:SetAlqTrib(aRegF210[nY][8])
							oApurEnt:SetBcTrib(aRegF210[nY][6])
							oApurEnt:SetValTrib(aRegF210[nY][9]) 
							oApurEnt:AgrpCred()		
					
							//-------------------------------------------------------------------
							//Informações da COFINS
							//-------------------------------------------------------------------		
							oApurEnt:SetTributo(COFINS)		
							oApurEnt:SetCST(aRegF210[nY][10])
							oApurEnt:SetAlqTrib(aRegF210[nY][11])
							oApurEnt:SetBcTrib(aRegF210[nY][6])
							oApurEnt:SetValTrib(aRegF210[nY][12]) 
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
Local nVlTotSal := 0	// Valor Total da Folha de Salários
Local nVlTotExc := 0	// Valor Total das Exclusões à Base de Cálculo
Local nVlTotBas := 0	// Valor Total da Base de Cálculo
Local nVlAliPis := 0	// Alíquota do PIS/PASEP – Folha de Salários
Local nVlTotPis := 0	// Valor Total da Contribuição Social sobre a Folha de Salários

If ExistBlock('SPEDM350')
	aM350Aux := ExecBlock("SPEDM350", .F., .F.,{FWGETCODFILIAL, dDataDe, dDataAte})

	nVlTotSal := aM350Aux[1]
	nVlTotExc := aM350Aux[2]
	nVlTotBas := aM350Aux[3]
	nVlAliPis := aM350Aux[4]
	nVlTotPis := aM350Aux[5]
ElseIf FindFunction("fM350VlPis")
	aM350Aux:=fM350VlPis( FWGETCODFILIAL, FWGETCODFILIAL, dDataDe, dDataAte)

	nVlTotSal := aM350Aux[1,2]
	nVlTotExc := aM350Aux[1,3]
	nVlTotBas := aM350Aux[1,4]
	nVlAliPis := aM350Aux[1,5]
	nVlTotPis := aM350Aux[1,6]
EndIf

IF Len(aM350Aux) > 0 .AND. nVlTotPis > 0
	oApurEFD:SetOrigem(OUTROS)
	oApurEFD:SetReceita(nVlTotSal)
	oApurEFD:SetTributo(PIS)
	oApurEFD:SetCST('')		
	oApurEFD:SetAlqTrib(nVlAliPis)
	oApurEFD:SetBcTrib(nVlTotBas)
	oApurEFD:SetValTrib(nVlTotPis)
	oApurEFD:SetExclPis(nVlTotExc)
	oApurEFD:SetPisFolh('1')
	oApurEFD:AgrpContr()
	oApurEFD:SetExclPis(0)
	oApurEFD:SetTpReg(' ')
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
Local lCanDelTmp:=.T.

oI100:SetFilial(aXFilial)
oI200I300:SetFilial(aXFilial)
oRecNTrib:SetFilial(aXFilial)
If lF07
	ObjF0T	:= TABELAF0T():New()
EndIf 
dbSelectArea("CCZ")
dbSetOrder(1)

For nCont :=1 to 3
	cAliasI	:= GetNextAlias()
	lProc	:= .F.	
	If nCont ==1 .and. cIntegra $ "1/3" .AND. FindFunction("FinSpdBlcI") 
		//Função do Financeiro
		cAliasI:=FinSpdBlcI(Month(dDataDe),Year(dDataDe),cAliasI)
		lProc	:= .T.
	ElseIF nCont ==2 .and. cIntegra $ "2/3" .AND. FindFunction("PLSPISCOF")
		//Função de Saúde		
		 lProc:=PLSPISCOF(dDataDe,dDataAte,cAliasI)		 
	ElseIF nCont ==3 .and. cIntegra $ "4" .AND. AliasINdic('F3F') .AND. FindFunction("FisCtbBlcI")
		//Função Fiscal x Contabilidade		
		 lProc:= FisCtbBlcI(dDataDe,dDataAte,cAliasI)
	EndIF
	
	If lProc		
		(cAliasI)->(dbGoTop())
		lRecnoTit	:= .F.
		lRecnoTit	:=  nCont ==1 .AND. (cAliasI)->(FieldPos('RECNO')) > 0 .AND. (cAliasI)->(FieldPos('ALIAS')) > 0
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
				c711712	:=	SubStr((cAliasI)->CLASSE,1,5) 
				c713714	:= (cAliasI)->CLASSE
				IF Len(Alltrim((cAliasI)->CLASSE)) == 8
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
			ElseIF nCont ==3  //Fiscal x Contabilidade
				nValRec	:= (cAliasI)->VALOR
				cCst		:= (cAliasI)->CSTPIS
				nAlqPis	:= (cAliasI)->ALIQPIS
				nAlqCof	:= (cAliasI)->ALIQCOF
				c711712	:=	SubStr((cAliasI)->CLASSE,1,5) 
				c713714	:= (cAliasI)->CLASSE
				IF Len(Alltrim((cAliasI)->CLASSE)) == 8
					lI300 := .T.
				EndIF
				cNota		:= (cAliasI)->NOTA
				cSerie		:= (cAliasI)->SERIE
				cClieFor	:= (cAliasI)->CLIENTE
				cLoja		:= (cAliasI)->LOJA	
				cTnatRec	:= (cAliasI)->NATREC
				cCnatRec	:= (cAliasI)->CNATREC
				cGrpRec		:= (cAliasI)->GRUPONC
				dDtNatRec	:= (cAliasI)->DTFIMNT
				cConta		:= (cAliasI)->CONTA
				cInf		:= (cAliasI)->INFO	
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
						oRecNTrib:SetParam('CKT_ORIGEM'	,OUTROS)
						oRecNTrib:SetParam('CKT_PER'	,dDataDe)
						oRecNTrib:SetParam('CKT_TRIB'	,'1')					
						oRecNTrib:SetParam('CKT_CST'	,cCst)					
						oRecNTrib:SetParam('CKT_CODNAT'	,cCnatRec)					
						oRecNTrib:SetParam('CKT_VLREC'	,nValRec)					
						oRecNTrib:SetParam('CKT_CONTA'	,cConta)					
						oRecNTrib:SetParam('CKT_DESCR'	,CCZ->CCZ_DESC)					
						oRecNTrib:Insert()

						//Processa valores não tributados da COFINS						
						oRecNTrib:SetParam('CKT_ORIGEM'	,OUTROS)
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

		// [ nCont==1 ] controle da temporaria do Financeiro em FinSpdBlcI()
		lCanDelTmp:=Iif( nCont==1 , Iif(FindFunction('FinSpdDel'),FinSpdDel(3),.T.) , .T. )//Verifica se pode fechar a area da tabela temporaria
		IF lCanDelTmp
			DbSelectArea(cAliasI)
			dbCloseArea()
		EndIf
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
para processamento das informações da  CPRB.

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
Local cOutRec	:= SuperGetMv("MV_CODGEN",.F.,"")
Local lNTrib 	:= CKX->(FieldPos('CKX_NTRIB'))>0 .And. !EmpTy(cOutRec)
Local lTmpFAt	:= FindFunction("CloseTRBDF")
Local lCONTARECE	:= .F.

oCPRB:SetDtRefer(dDataDe)
oCPRB:SetFilial(aXFilial)

//Traz saldo de exclusão de período anterior.
aSldExc:=oCPRB:GetSldExcl()

If lProcRH		// IRÁ PROCESSAR ATRAVÉS DO MÓDULO DE RH
	cAliasP:= fS033Sped(Alltrim(StrZero(Month(dDataDe),2))+Alltrim(Str(Year(dDataDe))) )
Else			// IRÁ PROCESSAR ATRAVÉS DO MÓDULO DE FATURAMENTO
	cAliasP:= RhInssPat(Alltrim(StrZero(Month(dDataDe),2))+Alltrim(Str(Year(dDataDe))),,,,.T.)
EndIf

DbSelectArea(cAliasP)
(cAliasP)->(DbSetOrder(1))
(cAliasP)->(dbGoTop())

lCONTARECE	:= (cAliasP)->(FieldPos("CONTARECE"))>0

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
	
	//Verifica a existência do campo CONTARECE, caso cliente não tenha o FATXFUN atualizado.
	IF lCONTARECE
		oCPRB:SetConta((cAliasP)->CONTARECE)
	Else
		oCPRB:SetConta("")
	EndIF
	
	oCPRB:SetInform('')
	oCPRB:SetCodRec(cCodRec)
	oCPRB:SetFilApu(IIf(lIndividu,oCPRB:BuscaxFil('CKR'),cFilialMat)) 
	// Verifica se codigo é não desonerado
	If lNTrib
		IF (cAliasP)->CODATV $ cOutRec
			oCPRB:SetNTrib(.T.)
		Endif
	Endif
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

IF lTmpFAt
	CloseTRBDF()
Else
	oCPRB:FechaAlias(cAliasP)
EndIF

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
LOcal lB1Tpreg		:= SB1->(FieldPos("B1_TPREG"))>0
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

		//Método que acumula as receitas por blocos A, C, D e F.
		//Operações de telecomunicação são escrituradas todas no bloco D, por este motivo chamei o método abaixo com o bloco D fixo.
		oApurSai:RecBlocos("D")		

		oApurSai:GrvResCST(,"D")
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
Local lB1TPREG	:= SB1->(FieldPos("B1_TPREG")) > 0
Local lA1TPREG	:= SB1->(FieldPos("A1_TPREG")) > 0

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

		//Venda fora do estabelecimento que não foram escirturads no livro, somente serão geradas para os modelos 01/04/1B/55, 
		//estes modelos pertencem ao bloco C., por este motivo está fixo no método abaixo
		oApurSai:RecBlocos("C")
	
		oApurSai:GrvResCST(,"C")

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
Static Function A001CUPOM(dDataDe,dDataAte,oApurSai,cRegime,cNrLivro,cReg,nMVM996TPR,lBilhete)
     
Local cAliasSFT	:= "SFT"
Local lProcessou	:= .F.
Local lPeCTB := ExistBlock("SPDPIS07")
Local cConta := ""
Local cBloco := ""

DEFAULT lBilhete := .F.

cAliasSFT	:= FSA001QECF(!lPeCTB,cNrLivro,dDataDe,dDataAte,lBilhete)
                                       
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

	If lPeCTB
		cConta := ""
		cConta	:=	ExecBlock("SPDPIS07", .F., .F., {	(cAliasSFT)->FT_FILIAL,;
			(cAliasSFT)->FT_TIPOMOV,;
			(cAliasSFT)->FT_SERIE,;
			(cAliasSFT)->FT_NFISCAL,;
			(cAliasSFT)->FT_CLIEFOR,;
			(cAliasSFT)->FT_LOJA,;
			(cAliasSFT)->FT_ITEM,;
			(cAliasSFT)->FT_PRODUTO,;
			(cAliasSFT)->FT_CONTA})
	Endif


	oApurSai:SetOrigem(CUPOM)			
	oApurSai:SetCFOP(	(cAliasSFT)->FT_CFOP)				
	oApurSai:SetReceita((cAliasSFT)->FT_TOTAL)
	oApurSai:SetTNatRec((cAliasSFT)->FT_TNATREC)
	oApurSai:SetCNatRec((cAliasSFT)->FT_CNATREC)		
	oApurSai:SetGNatRec((cAliasSFT)->FT_GRUPONC)
	oApurSai:SetDNatRec((cAliasSFT)->FT_DTFIMNT)
	oApurSai:SetQtde((cAliasSFT)->FT_QUANT)				
	If !lPeCTB
		oApurSai:SetConta((cAliasSFT)->FT_CONTA)
	Else
		oApurSai:SetConta(cConta)
	EndIf

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
	
	If lBilhete
		//As receitas de cupom fiscal são escrituradas na famíla do bloco D, no registro D350, por este motivo chamei o método abaixo com bloc fixo.
		cBloco	:= "D"		
	Else
		//As receitas de cupom fiscal são escrituradas na famíla do bloco C, nos registro C400 ou C490, por este motivo chamei o método abaixo com bloc fixo.		
		cBloco	:= "C"
	EndIf
	oApurSai:RecBlocos(cBloco)

	//Passo FT_VALCONT neste trecho somente para que a primeira aba da apuração o valor da receita seja o valor contábil, considerando
	//valores de despesas acessórias, frete,seguro, desconto etc...
	oApurSai:SetReceita((cAliasSFT)->FT_VALCONT )
	oApurSai:GrvResCST(,cBloco)

	(cAliasSFT)->(dbSkip())
	          	
EndDo

oApurSai:FechaAlias(cAliasSFT)

If lProcessou
	//FINALIZA GRAVAÇÃO DAS RECEITAS.
	oApurSai:Finaliza('1')
EndIF

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao    ³SPEDFSFT| Autor Bruce Mello  			   ³    Data ³29.01.2020     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Funcao que efetua filtro na Tabela SFT para gerar CPRB Regime Caixa³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpL1 := SPEDFSFT(nPar,cPar,cPar,aPar)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³nPar - Parametro que define se criara o filtro ou feche um filtro  ³±±
±±³          ³       jah criado. 1=Criar, 2=Fechar.                              ³±±
±±³          ³cPar - Se trata de um flag atraves do nome da tabela a ser criada o³±±
±±³          ³       o filtro. No caso de haver mais de um filtro para a mesma   ³±±
±±³          ³       tabela em situacoes diferentes, basta acrescentar um identi-³±±
±±³          ³       ficador na quarta posicao do nome. Ex: SFT, SFT1, SF2, etc..³±±
±±³          ³cPar - Variavel passada por referencia para retornar o alias criado³±±
±±³          ³       para a tabela em questao.                                   ³±±
±±³          ³aPar - Parametros para execucao dos filtros                        ³±±
±±³          ³nPar - Se esta variavel for passada diferente de NIL, significa que³±±
±±³          ³       a query deve retornar a quantidade de registros. Utilizado  ³±±
±±³          ³       para montar a regua de processamento mais precisa. O retorno³±±
±±³          ³       serah nesta mesma variavel que deve ser passada como        ³±±
±±³          ³       referencia. O retorno da funcao ainda continua sendo .T.    ³±±
±±³          ³       quando tiver registros ou .F. quando nao tiver.             ³±±
±±³          ³nPar - Indica o indice a ser usado (base Codebase)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAFIS - SPED EFD Contribuições                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function SPEDFSFT(nOpc,cTabela,cAlias,aPar,nRecCount,nOrdDBF)

Local	ApeF500		:=	{}
Local	cFiltro		:=	""
Local	cIndex		:=	""
Local	cSelect		:= 	""
Local	cFrom		:= 	""
Local	cWhere		:=	""
Local	lRet		:=	.F.
Local	lCountReg	:=	nRecCount<>Nil
Local	nIndex		:=	0

STATIC lNotAs400 := (TcSrvType()<>"AS/400")
STATIC aExistBloc	:= {	ExistBlock("SPDFIS02"),;		// 01
							ExistBlock("SPDFIS06"),;		// 02
							ExistBlock("SPEDRTMS"),;		// 03
							ExistBlock("SPDFIS08"),;		// 04
							ExistBlock("SPEDPROD"),;		// 05
							ExistBlock("SPEDPTMS"),;		// 06
							ExistBlock("SPED1300"),;		// 07
							ExistBlock("SPED1390"),;		// 08
							ExistBlock("SPEDREGD"),;		// 09
							ExistBlock("SPDFIS001",,.T.),;	// 10
							ExistBlock("SPDFIS05"),;		// 11
							ExistBlock("SPDFIS04"),;		// 12
							ExistBlock("SPEDR450"),;		// 13
							ExistBlock("SPEDR460"),;		// 14
							ExistBlock("SPEDG126"),;		// 15
							ExistBlock("SPDFIS07"),;		// 16
							ExistBlock("SPDFIS10",,.T.),;	// 17
							ExistBlock("SPDPISIC"),;		// 18
							ExistBlock("SPDFIS09"),;		// 19
							ExistBlock("SPED0205"),;		// 20
							ExistBlock("SPED0150"),;		// 21
							ExistBlock("SPDFIS03"),;		// 22
							ExistBlock("SPDPINFO"),;		// 23
							ExistBlock("SPDFISBLCK"),;		// 24
							ExistBlock("SPEDFANT"),;		// 25
							ExistBlock("SPEDH020"),;		// 26
							ExistBlock("SPDFIS27"),;		// 27
							ExistBlock("SPDF500A"),;		// 28
							ExistBlock("SPDF500C"),;		// 29
							ExistBlock("SPED1400"),;		// 30
							ExistBlock("SPEDALTH"),;		// 31
							ExistBlock("SPDFIS11")}			// 32


#IFDEF TOP
	Local	aSetField	:=	{}
	Local	nI			:=	0
	Local	cOrderBy	:=	""
#ENDIF
Default nOrdDBF := 0

If nOpc==1
	If cTabela=="SFT4" // Uso do SPEDPISCOF
	
		#IFDEF TOP
			If lNotAs400
	        	cSelect :=	"SFT.FT_FILIAL,SFT.FT_VALCONT,SFT.FT_CSTPIS,SFT.FT_BASEPIS,SFT.FT_ALIQPIS,SFT.FT_CSTCOF,SFT.FT_BASECOF,SFT.FT_ALIQCOF,SFT.FT_TIPO,"
    			cSelect	+=	"SFT.FT_ESPECIE,SFT.FT_CFOP ,SFT.FT_CONTA,SFT.FT_TNATREC,SFT.FT_CNATREC,SFT.FT_GRUPONC, SFT.FT_DTFIMNT,SFT.FT_PAUTPIS,SFT.FT_PAUTCOF,"
    			cSelect	+=  "SFT.FT_NFISCAL,SFT.FT_CLIEFOR,SFT.FT_PRODUTO,SFT.FT_TIPOMOV,SFT.FT_SERIE,SFT.FT_LOJA,SFT.FT_ENTRADA,SFT.FT_QUANT,SFT.FT_VALPIS,SFT.FT_VALCOF,"    			
    			cSelect	+=  "SFT.FT_SERORI,SFT.FT_NFORI,SFT.FT_ITEMORI,SFT.FT_ITEM,SFT.FT_VALIPI,SFT.FT_ICMSRET,SFT.FT_EMISSAO,SFT.FT_VALICM,SFT.FT_DESCONT, " 
				cSelect	+=	"SB1.B1_COD, SB1.B1_TIPO, SB1.B1_CODISS, SB1.B1_POSIPI, SB1.B1_DESC, SB1.B1_CODBAR,SB1.B1_CODGTIN, "
				cSelect	+=	"SB1.B1_CODANT, SB1.B1_UM, SB1.B1_EX_NCM,SB1.B1_PICM, SB1.B1_FECP, SB1.B1_DATREF, SB1.B1_VLR_PIS, SB1.B1_VLR_COF, SB1.B1_TNATREC, "
				cSelect	+=	"SB1.B1_CNATREC, SB1.B1_GRPNATR, SF2.F2_VALBRUT, SF2.F2_VALFAT "
				cSelect	+=	", SFT.FT_ATIVCPB, SFT.FT_VALCPB, SFT.FT_ALIQCPB, SFT.FT_BASECPB "

    			cFrom	:=	""+RetSqlName("SFT")+" SFT "
				cFrom	+=	" LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=''"   
				cFrom	+=	" LEFT JOIN "+RetSqlName("SF2")+" SF2 ON(SF2.F2_FILIAL='"+xFilial("SF2")+"'  AND SF2.F2_DOC=SFT.FT_NFISCAL AND SF2.F2_SERIE=SFT.FT_SERIE AND SF2.F2_CLIENTE=SFT.FT_CLIEFOR AND SF2.F2_LOJA=SFT.FT_LOJA AND SF2.D_E_L_E_T_=' ') "
				IF aPar[7]=="01"
			   		cSelect	+= " ,SA1.A1_CGC "
			   		cFrom += " LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND "
			   		cFrom += " SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_=''"
				EndIF
				
    			cWhere	:=	"SFT.FT_FILIAL='"+xFilial("SFT")+"' AND "
				cWhere	+=	"SFT.FT_TIPOMOV='S' AND "
				cWhere	+=	"SFT.FT_ENTRADA='"+aPar[1]+"' AND "
				cWhere	+=	"SFT.FT_SERIE='"+aPar[2]+"' AND "
				cWhere	+=	"SFT.FT_NFISCAL='"+aPar[3]+"' AND "
				cWhere	+=	"SFT.FT_CLIEFOR='"+aPar[4]+"' AND "
				cWhere	+=	"SFT.FT_LOJA='"+aPar[5]+"' AND "
				cWhere	+=	"(SFT.FT_BASEPIS > 0 OR SFT.FT_BASEPS3 > 0 OR  SFT.FT_BASECOF > 0 OR SFT.FT_BASECF3 > 0 OR SFT.FT_CSTPIS IN ('07','08','09','49') OR SFT.FT_CSTCOF IN ('07','08','09','49')) AND "
				If (aPar[6]<>"*")
		        	cWhere += " SFT.FT_NRLIVRO = '" +aPar[6]+"' AND "
		  		EndiF
		  		cWhere	+=	"SFT.D_E_L_E_T_=''"

				If aExistBloc[28] // PE para SCP com Filial unica - TTUXH9
					ApeF500 := ExecBlock("SPDF500A", .F. , .F. , {cFrom,cWhere})
					cFrom 	:= ApeF500[1]
					cWhere	:= ApeF500[2]
				Endif
				
				cSelect	:= "%"+cSelect+"%"
				cFrom 	:= "%"+cFrom+"%"
				cWhere	:= "%"+cWhere+"%"
			  		
		  		aAdd(aSetField,{"FT_EMISSAO","D",8,0})
		  		aAdd(aSetField,{"FT_ENTRADA","D",8,0})
		  		aAdd(aSetField,{"FT_DTCANC","D",8,0})
		  Else
		#ENDIF
		       cFiltro	:= 'FT_FILIAL=="'+xFilial ("SFT")+'" .And. '
			   cFiltro += ' FT_TIPOMOV = "S" .AND. DTOS(FT_ENTRADA)="'+aPar[1]+'" .And. FT_SERIE == "' + aPar[2]  + '" .AND.  '
			   cFiltro += 'FT_NFISCAL =="'+aPar[3]+'" .And. FT_CLIEFOR =="'+aPar[4]+'"  .AND. FT_LOJA =="'+aPar[5] + '" .AND.  '
			   cFiltro	+= '(FT_BASEPIS > 0 .OR. FT_BASEPS3 > 0 .OR. FT_VALCOF > 0 .OR. FT_BASECF3 > 0 .OR. FT_CSTPIS $"07#08#09#49" .OR. FT_CSTCOF $"07#08#09#49")'
				If (aPar[6]<>"*")
				    cFiltro	+=	'.And. FT_NRLIVRO ="'+aPar[6]+'" '
			   	EndIf
		#IFDEF TOP
			EndIf
		#ENDIF
    EndiF

    #IFDEF TOP
		If lNotAs400
			cAlias	:=	SPEDGetAlias(cTabela)
			BeginSql Alias cAlias
				SELECT
					%Exp:cSelect%

				FROM
					%Exp:cFrom%

				WHERE
					%Exp:cWhere+cOrderBy%

				//%Exp:cOrderBy%
			EndSql

			If !lCountReg
				For nI := 1 To Len(aSetField)
					TcSetField(cAlias,aSetField[nI,1],aSetField[nI,2],aSetField[nI,3],aSetField[nI,4])
				Next
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o retorno deve ser a quantidade de registros, armazeno em uma variavel para retornar³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCountReg
				nRecCount := (cAlias)->COUNTREG
			EndIf
		Else
	#ENDIF	
		    cIndex  := CriaTrab(Nil,.F.)
		    cTabela := SubStr(cTabela,1,3)
		    IndRegua(cAlias,cIndex,(cTabela)->(IndexKey (nOrdDBF)),,cFiltro,,.F.)
		    nIndex  := RetIndex(cAlias)
			#IFNDEF TOP
				DbSetIndex(cIndex+OrdBagExt())
			#ENDIF
			DbSelectArea(cAlias)
		    DbSetOrder(nIndex+1)
			(cAlias)->(DbGoTop())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se o retorno deve ser a quantidade de registros, armazeno em uma variavel para retornar³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCountReg
				nRecCount := (cAlias)->(RecCount())
			EndIf
	#IFDEF TOP
		EndIf
	#ENDIF

    //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Como jah armazenei em uma variavel o valor da quantidade de registros, ³
	//³  posso fechar a area. O retorno da quantidade eh atraves de um        ³
	//³  parametro passado por referencia. O retorno da funcao ainda continua ³
	//³  sendo .T. quando tiver registros ou .F. quando nao tiver.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lCountReg
		SPEDFFiltro(2,"",cAlias)
		lRet := nRecCount>0
	ElseIf !(cAlias)->(Eof())
		lRet := .T.
	Else
		SPEDFFiltro(2,"",cAlias)
	EndIf

Else
	#IFDEF TOP
		If lNotAs400
			If Select(cAlias)<>0
				(cAlias)->(DbCloseArea())
			EndIf
		Else
	#ENDIF
			RetIndex(cAlias)
	#IFDEF TOP
		EndIf
	#ENDIF
EndIf
Return lRet
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
Static Function A001CAIXA(dDataDe,dDataAte,oApurSai,cNrLivro,cIndCompRe,aXFilial,lCPRBNF,cSPCBPSE,cFilialMat,lindividu,aParSX1, aAjuPISCOF, dMVICMDSDT)

Local cAliasF500		:=  'F500'
Local aParFil			:=	{}
Local lPauta			:=	.F.
Local lProcFin		:= .F.
Local lCmpVrDes		:=	.F.
Local lValIcms      :=  .F.
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
Local cNome			:= ""
Local cOutRec	:= SuperGetMv("MV_CODGEN",.F.,"")
Local lNTrib 	:= CKX->(FieldPos('CKX_NTRIB'))>0 .And. !EmpTy(cOutRec)
Local oAjuDeb   := NIL
Local dDtMudReg := SuperGetMV("MV_DTMREG",.F.,cToD("//"))
Local nX := 0
Local nPosAj := 0
Local cDescAj := 'Ajuste de redução da contribuição em função de mudança de regime de competência para caixa ocorrida em ' + DtoC(dDtMudReg)
Local cInfCompAj := ""
Local dEmisTit := cToD("//")
Local cCodCon := ""
Local cChvNF := ""
Local cChvTit := ""
Local cDedbpis := SuperGetMv("MV_DEDBPIS")
Local cDedbcof := SuperGetMv("MV_DEDBCOF")
Local cTipoNf  := ''
Local cEspecie	:= ''
Local lDFSRVAC	:= GetNewPar("MV_DFSRVAC",.F.)
Local cMVEstado	 :=  GetNewPar("MV_ESTADO","") 
Local nValReceita	:= 0
Local lSF2ValFat := .F.
Local aCFOPs     := XFUNCFRec()
Local cCfop      := ''
Local lTabCID	:= aliasindic("CID") .AND. Year(dDataDe) >= 2020
Local aExigiSusp	:= {}
Local lDSTRB 	:= GetNewPar("MV_DSTRB",.F.) 
Local lIPIRB    := GetNewPar("MV_DIPIRB",.F.) 
Local nExclusao := 0 // Grava os valores de receita para os registros de exclusão, caso o cliente opte em deixar os MV_DSTRB e MV_DIPIRB, .F., por que caso um deles fique falso tenho que gravar no registro de exclusão
Local nValST	:= 0
Local nValipi	:= 0
Local nExcluRB  :=0 // Somo IPI e ST de acordo com os parametros para subtrai do FT_VALCONT para compor o nReceita.
Local lMudReg := .F.
Local lIntPFS   := SuperGetMv("MV_JESCJUR",,.F.) // Integração PFS Juridico

Private oHExigSusp	:= HMNew() //Cria o Hash para apoio ao array aExigiSusp

IF FindFunction('FinSpdF500')	
	If !Empty(dDtMudReg) 
		lMudReg := .T.  // controle de ratreio função do financeiro para posicionar o TITULO PAI e EMISSAO do TITULO PAI
	Endif
	
	//Chama função de integração com Financeiro
	cNome := FinSpdF500(Month(dDataDe),Year(dDataDe),cAliasF500,lMudReg)
	
	//Quando retornar F500 possui dados para processamento
	IF 	Empty(cNome) 
		If !ChkFile(cAliasF500)
			Return
		Else
			If Iif(FindFunction('FinSpdDel'),FinSpdDel(2),.T.)//Verifica se pode fechar a area da tabela temporaria
				DbSelectArea(cAliasF500)
				dbCloseArea()
			EndIf
			Ferase(cAliasF500+GetDBExtension())
			Ferase(cAliasF500+OrdBagExt()) 
			Return
		Endif	
	Endif

	If lF0T
		ObjF0T	:= TABELAF0T():New()
	EndIF
	
	//Cria objeto para gravação das informações na tabela CL1
	oCaixa	:= TABELACL1():New()
	oCaixa:SetPer(dDataDe)
	oCaixa:SetFilial(aXFilial)
	oCaixa:SetFilApu(cFilialMat)
	
	oProcRef	:= TABELAF07():New()
	oProcRef:SetPer(dDataDe)
	oProcRef:SetFilial(aXFilial)	
	
	//Cria objeto para gravação da CPRB
	If lCPRBNF
		oCPRB	:= CPRBEFD():New()
		oCPRB:SetDtIni(dDataDe)
	Endif
	
	// Instancia o objeto de apuração
	oApurEFD := FISX001():New()
	oApurEFD:SetFilial(aXFilial)
	oApurEFD:SetRegApur(CUMULAT)
	oApurEFD:SetDtIni(dDataDe)
	oApurEFD:SetDtFin(dDataAte)
	oApurEFD:DefRegime()
	oApurSai:DefRegime()
	
	//Chama função de integração com Financeiro
	(cAliasF500)->( DBGOTOP())
	lProcFin	:= (cAliasF500)->(FieldPos('NUMPRO')) > 0 .AND.(cAliasF500)->(FieldPos('INDPRO')) > 0
	lCmpVrDes	:=	(cAliasF500)->(FieldPos('VRDESCON')) > 0
	lDtTitPai   :=  (cAliasF500)->(FieldPos('DTPAI')) > 0
	lTitPai   :=  (cAliasF500)->(FieldPos('RASTRO')) > 0

	Do While !(cAliasF500)->( EOF())

		cChaveCl1	:= ''
		cChvNF      := ''
		cChvTit     := ''

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
				If SPEDFSFT(1,"SFT4",@cAliasSFT,aParFil)//SPEDFFiltro(1,"SFT3",@cAliasSFT,aParFil)		
					lValIcms	:= (cAliasSFT)->(FieldPos('FT_VALICM')) > 0
					lSF2ValFat  := (cAliasSFT)->(FieldPos('F2_VALFAT')) > 0
					Do While !(cAliasSFT)->( EOF())
						cCfop := AllTrim((cAliasSFT)->FT_CFOP)

						//---Verificar os CFOPs de receita para poder gerar os registros---//
						If (cCfop$aCFOPs[01] .Or. cCfop$aCFOPs[03]) .AND. !(cCfop$aCFOPs[02])
							lPauta	  := .F.
							nDesconto := Iif(lCmpVrDes .And. nPerReceb > 0,(cAliasF500)->VRDESCON,0) //DSERFIS1-16353
							nPerReceb := ((cAliasF500)->VALOR +nDesconto)  / Iif(lSF2ValFat .And. !lIntPFS,(cAliasSFT)->F2_VALFAT,(cAliasSFT)->F2_VALBRUT)							
							cCodCon   := ""
							nValICMS  := Iif(lValIcms,(cAliasSFT)->FT_VALICM,0)
							cTipoNf   := (cAliasSFT)->FT_TIPO
							nValDesco := DedPisCof(cDedbpis,cDedbcof,'2',nValICMS,'',cTipoNf, dMVICMDSDT) 						

							If (cAliasSFT)->FT_PAUTPIS > 0 .OR. (cAliasSFT)->FT_PAUTCOF > 0
								lPauta 		:= .T.
							EndIF

							cEspecie	:= AModNot((cAliasSFT)->FT_ESPECIE)

	                        // Nessa variavel vai receber os valores de IPI e ICMS ST para diminuir do valor contabil , com isso caso o cliente optar em tirar o IPI ou ST consigo controlar.
							If lIPIRB
								nExcluRB := (cAliasSFT)->FT_VALIPI 
							EndIF

							If lDSTRB
								nExcluRB +=  (cAliasSFT)->FT_ICMSRET
							Endif
  

							nValReceita	:= ((cAliasSFT)->FT_VALCONT + (cAliasSFT)->FT_DESCONT - nExcluRB - nDesconto) * nPerReceb 

							oCaixa:SetCstPis((cAliasSFT)->FT_CSTPIS								)
							oCaixa:SetCstCof((cAliasSFT)->FT_CSTCOF								)
							oCaixa:SetModelo(Iif(!Empty(cEspecie),cEspecie,"98"))
							oCaixa:SetCfop((cAliasSFT)->FT_CFOP									)	
							oCaixa:SetValRec(nValReceita)
							oCaixa:SetDescPis(nDesconto + (((cAliasSFT)->FT_VALIPI + nValDesco) * nPerReceb) )
							oCaixa:SetBasePis(((cAliasSFT)->FT_BASEPIS * nPerReceb))
							oCaixa:SetDescCof(nDesconto + (((cAliasSFT)->FT_VALIPI + nValDesco) * nPerReceb) )
							oCaixa:SetBaseCof(((cAliasSFT)->FT_BASECOF * nPerReceb))
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
							
							//Método que acumula as receitas por blocos A, C, D e F.						
							oApurSai:SetCST(oCaixa:getCST(PIS))
							oApurSai:SetReceita(nValReceita)
							oApurSai:CodCon()
							IF Empty(cEspecie) .OR. (!lDFSRVAC .AND. cEspecie == '55' .AND. cMVEstado == 'DF')
								oApurSai:RecBlocos("A")
							Else
								oApurSai:RecBlocos("C")
							EndIF
							
							IF !Empty(cChaveCL1) .AND. lF07

								//³Preenche array para pesquisar os processos referenciados vinculados a nota fiscal³
								aParCDG	:= {}
								aAdd(aParCDG,(cAliasSFT)->FT_TIPOMOV)
								aAdd(aParCDG,(cAliasSFT)->FT_NFISCAL)
								aAdd(aParCDG,(cAliasSFT)->FT_SERIE)
								aAdd(aParCDG,(cAliasSFT)->FT_CLIEFOR)
								aAdd(aParCDG,(cAliasSFT)->FT_LOJA)
								aAdd(aParCDG,(cAliasSFT)->FT_ITEM)
																
								cAliasCDG	:= QryCDGCaixa(aParCDG, lTabCID)
								Do while !(cAliasCDG)->(EOF())
									oProcRef:SetId(cChaveCL1)
									oProcRef:SetPer(dDataDe)
									oProcRef:SetNumPro((cAliasCDG)->CDG_PROCES)
									oProcRef:SetIndPro((cAliasCDG)->CDG_TPPROC)
									oProcRef:SetIndAut((cAliasCDG)->CCF_INDAUT)
									oProcRef:SetIdItem((cAliasCDG)->CCF_IDITEM)

									oProcRef:Save()

									//Verifica se terá que processar informações da exigibilidade suspensa
									If lTabCID .AND. (cAliasCDG)->CCF_TRIB $ ("7#8") .AND. (cAliasCDG)->CCF_NATJU $ "12#13#14#15#16#17#19" .AND. (cAliasCDG)->CCF_TPCOMP $ "1#2"
										//Processa informações da exigibilidade suspensa										
										ProcExigi(@aExigiSusp, cAliasCDG, cAliasCDG, cAliasSFT, dDataDe, dDataAte, nPerReceb, cChaveCL1,.T.)
									EndIF

									(cAliasCDG)->(DBSKIP())
								EndDo
								DbSelectArea (cAliasCDG)
								(cAliasCDG)->(DbCloseArea())
								
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

							//Busca valor de ICMS ST para abater do registro 0111 e na composição de Receita Bruta caso o parâmetro MV_DSTRB esteja habilitado 
							IF lDSTRB
								nValST	:= (cAliasSFT)->FT_ICMSRET
							EndIF
							//Busca valor dO IPI para abater do registro 0111 e na composição de Receita Bruta caso o parâmetro MV_DIPIRB esteja habilitado
							IF lIPIRB 
								nValipi :=(cAliasSFT)->FT_VALIPI
							Endif	

							//--------------------
							//Informações da CPRB
							//--------------------
							If lCPRBNF
								//Verifica parâmetro para definir se utilizará código de serviço ou de outros serviços.
								lAtuCPRB := .T.
								oCPRB:SetDtRefer(dDataDe)
								oCPRB:SetCodAtiv((cAliasSFT)->FT_ATIVCPB)
								oCPRB:SetVlBrut(((cAliasSFT)->FT_VALCONT + (cAliasSFT)->FT_DESCONT - nValipi - nValST ) * nPerReceb) 
								
								// Grava os valores de receita para os registros de exclusão, caso o cliente opte em deixar os MV_DSTRB e MV_DIPIRB, .F., por que caso um deles fique falso tenho que gravar no registro de exclusão
								If !Empty((cAliasSFT)->FT_ATIVCPB)               
									nExclusao = 0

									If !lIPIRB
										nExclusao += (cAliasSFT)->FT_VALIPI * nPerReceb
									EndIF

									If !lDSTRB
										nExclusao += (cAliasSFT)->FT_ICMSRET * nPerReceb
									EndIF
								Else
									nExclusao = 0
								EndIF 
								           
								oCPRB:SetVlExcl((cAliasSFT)->FT_DESCONT + nExclusao) 
								oCPRB:SetVlCPRB((cAliasSFT)->FT_VALCPB * nPerReceb)
								oCPRB:SetAliq((cAliasSFT)->FT_ALIQCPB)
								oCPRB:SetBase((cAliasSFT)->FT_BASECPB * nPerReceb) 
								oCPRB:SetVlAtiv(((cAliasSFT)->FT_VALCONT + (cAliasSFT)->FT_DESCONT - nValipi -nValST) * nPerReceb) 
								oCPRB:SetConta((cAliasSFT)->FT_CONTA)
								oCPRB:SetCodRec(Iif(AllTrim((cAliasSFT)->FT_ATIVCPB)$cSPCBPSE,aParSX1[16],aParSX1[17])) 
								oCPRB:SetFilApu(IIf(lIndividu,oCPRB:BuscaxFil('CKY'),cFilialMat)) 
								// Verifica se codigo é não desonerado
								If lNTrib
									IF (cAliasSFT)->FT_ATIVCPB $ cOutRec
										oCPRB:SetNTrib(.T.)
									Endif
								Endif
								
								oCPRB:AgrupaCPRB()
								
								If !Empty((cAliasSFT)->FT_ATIVCPB) .And. AliasIndic('F2S')
									If ((cAliasSFT)->FT_VALIPI * nPerReceb) > 0
										oCPRB:SetDetExcl('07', (cAliasSFT)->FT_VALIPI * nPerReceb,'IPI')
									EndIf
									If((cAliasSFT)->FT_ICMSRET * nPerReceb) > 0
										oCPRB:SetDetExcl('08', (cAliasSFT)->FT_ICMSRET * nPerReceb,'ICMS-ST')
									EndIf
								EndIf

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
								ObjF0T:SetValue("F0T_EXCPRB",If(EmpTy((cAliasSFT)->FT_ATIVCPB),0,(cAliasSFT)->FT_VALIPI * nPerReceb + (cAliasSFT)->FT_ICMSRET * nPerReceb))							
								ObjF0T:SetValue("F0T_CODATV",(cAliasSFT)->FT_ATIVCPB)
								ObjF0T:SetValue("F0T_BCCPRB",(cAliasSFT)->FT_BASECPB * nPerReceb)
								ObjF0T:SetValue("F0T_AQCPRB",(cAliasSFT)->FT_ALIQCPB)
								ObjF0T:SetValue("F0T_VLCPRB",(cAliasSFT)->FT_VALCPB * nPerReceb)							
								ObjF0T:Grava()						
							Endif			
												
							// Caso tenha ocorrido mudança de regime - de competência para caixa - 
							// Neste caso não posso tributar novamente a receita decorrente da baixa do título pois a 
							// mesma já foi tributada no período da emissão (competência). 
							// Devo, então, gerar um ajuste de redução para "zerar" os valores referentes à baixa.
							// Aqui só adiciono as informações no array aAjuPISCOF, depois do processamento do regime de caixa
							// vou efetivar os ajustes.
							If !Empty(dDtMudReg) .And. (cAliasSFT)->FT_EMISSAO < dDtMudReg

								// Define descrição do ajuste.
								cInfCompAj := "Doc.:" + AllTrim((cAliasSFT)->FT_NFISCAL) +;
											",Série:" + AllTrim((cAliasSFT)->FT_SERIE) +;
											",Cli/Loja:" + AllTrim((cAliasSFT)->FT_CLIEFOR + (cAliasSFT)->FT_LOJA) +; 
											",Emis.:" + DtoC((cAliasSFT)->FT_EMISSAO)

								// Chave da NF p/ agrupamento
								cChvNF := oCaixa:getNumDoc() + oCaixa:getSerie() + oCaixa:getClieFor() + oCaixa:getLoja()

								// PIS

								//Passa CST de PIS para classe
								oApurEFD:SetCST(oCaixa:getCST(PIS))
								cCodCon := oApurEFD:CodCon()

								// Verifica se trata-se de uma receita tributada p/ fazer o ajuste.
								If AllTrim(cCodCon) $ "51|52|53|54"
									If (nPosAj := aScan(aAjuPISCOF, { |x| x[1] == PIS .And. x[18] == cChvNF  .And. x[7] == cCodCon .And. Str(x[15]) == Str(oCaixa:getAliq(PIS)) })) == 0
										aAdd(aAjuPISCOF, {})
										nPosAj := Len(aAjuPISCOF)                            
										aAdd(aAjuPISCOF[nPosAj], PIS)						// 01 - TRIBUTO
										aAdd(aAjuPISCOF[nPosAj], REDUCAO)					// 02 - INDICADOR DO TIPO DE AJUSTE
										aAdd(aAjuPISCOF[nPosAj], '05')						// 03 - CÓDIGO DO AJUSTE (Ajuste Oriundo de Outras Situações)
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getNumDoc())		// 04 - NUMERO DO DOCUMENTO
										aAdd(aAjuPISCOF[nPosAj], cDescAj + " - " + cInfCompAj)		// 05 - DESCRIÇÃO DO AJUSTE
										aAdd(aAjuPISCOF[nPosAj], (cAliasSFT)->FT_EMISSAO)	// 06 - DATA DE REFERÊNCIA DO AJUSTE
										aAdd(aAjuPISCOF[nPosAj], cCodCon)					// 07 - CÓDIGO DA CONTRIBUIÇÃO
										aAdd(aAjuPISCOF[nPosAj], CUMULAT)					// 08 - REGIME
										aAdd(aAjuPISCOF[nPosAj], '4')						// 09 - ORIGEM (4 - FINANCEIRO)
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getBase(PIS) * oCaixa:getAliq(PIS) / Iif(lPauta,1,100)) // 10 - VALOR DO AJUSTE
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getCST(PIS))		// 11 - CST
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getConta())			// 12 - CONTA
										aAdd(aAjuPISCOF[nPosAj], cInfCompAj)				// 13 - INFOS. COMPLEMENTARES (M225)
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getBase(PIS))		// 14 - BASE
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getAliq(PIS))		// 15 - ALIQUOTA
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getTNatRec())		// 16 - TABELA - NATUREZA DA RECEITA
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getCNatRec())		// 17 - CODIGO - NATUREZA DA RECEITA
										aAdd(aAjuPISCOF[nPosAj], cChvNF)					// 18 - CHAVE DA NOTA (Não vai no ajuste - Só p/ agrupar)

									Else
										aAjuPISCOF[nPosAj, 10] += oCaixa:getBase(PIS) * oCaixa:getAliq(PIS) / Iif(lPauta,1,100) // 10 - VALOR DO AJUSTE
										aAjuPISCOF[nPosAj, 14] += oCaixa:getBase(PIS)											// 14 - BASE
									EndIf
									
								EndIf

								// COFINS

								//Passa CST de COFINS para classe
								oApurEFD:SetCST(oCaixa:getCST(COFINS))
								cCodCon := oApurEFD:CodCon()

								// Verifica se trata-se de uma receita tributada p/ fazer o ajuste.
								If AllTrim(cCodCon) $ "51|52|53|54"
									If (nPosAj := aScan(aAjuPISCOF, { |x| x[1] == COFINS .And. x[18] == cChvNF  .And. x[7] == cCodCon .And. Str(x[15]) == Str(oCaixa:getAliq(COFINS)) })) == 0
										aAdd(aAjuPISCOF, {})
										nPosAj := Len(aAjuPISCOF)
										aAdd(aAjuPISCOF[nPosAj], COFINS)					// 01 - TRIBUTO
										aAdd(aAjuPISCOF[nPosAj], REDUCAO)					// 02 - INDICADOR DO TIPO DE AJUSTE
										aAdd(aAjuPISCOF[nPosAj], '05')						// 03 - CÓDIGO DO AJUSTE (Ajuste Oriundo de Outras Situações)
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getNumDoc())		// 04 - NUMERO DO DOCUMENTO
										aAdd(aAjuPISCOF[nPosAj], cDescAj + " - " + cInfCompAj) // 05 - DESCRIÇÃO DO AJUSTE
										aAdd(aAjuPISCOF[nPosAj], (cAliasSFT)->FT_EMISSAO)	// 06 - DATA DE REFERÊNCIA DO AJUSTE
										aAdd(aAjuPISCOF[nPosAj], cCodCon)					// 07 - CÓDIGO DA CONTRIBUIÇÃO
										aAdd(aAjuPISCOF[nPosAj], CUMULAT)					// 08 - REGIME
										aAdd(aAjuPISCOF[nPosAj], '4')						// 09 - ORIGEM (4 - FINANCEIRO)
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getBase(COFINS) * oCaixa:getAliq(COFINS) / Iif(lPauta,1,100)) // 10 - VALOR DO AJUSTE
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getCST(COFINS))		// 11 - CST
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getConta())			// 12 - CONTA
										aAdd(aAjuPISCOF[nPosAj], cInfCompAj)				// 13 - INFOS. COMPLEMENTARES (M225)
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getBase(COFINS))	// 14 - BASE
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getAliq(COFINS))	// 15 - ALIQUOTA
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getTNatRec())		// 16 - TABELA - NATUREZA DA RECEITA
										aAdd(aAjuPISCOF[nPosAj], oCaixa:getCNatRec())		// 17 - CODIGO - NATUREZA DA RECEITA
										aAdd(aAjuPISCOF[nPosAj], cChvNF)					// 18 - CHAVE DA NOTA (Não vai no ajuste - Só p/ agrupar)
									Else
										aAjuPISCOF[nPosAj, 10] += oCaixa:getBase(COFINS) * oCaixa:getAliq(COFINS) / Iif(lPauta,1,100)  // 10 - VALOR DO AJUSTE
										aAjuPISCOF[nPosAj, 14] += oCaixa:getBase(COFINS)											   // 14 - BASE	
									EndIf
								EndIf
							EndIf

							oCaixa:Clear()
											
						EndIf
						(cAliasSFT)->( DBSKIP())						
					EndDo	                 
					//³Fecha alias dos itens da nota fiscal³
					SPEDFFiltro(2,,cAliasSFT)

					//Aqui verifica se existem informações de exigibilidade suspensa processados no laço das notas, se sim gravará as informações
					If Len(aExigiSusp) > 0
						x001GrvCIE(aExigiSusp, dDataDe)
						aSize(aExigiSusp,0) //Limpo o array que não era limpo
						aExigiSusp:=Nil
					EndIf					

				EndIF 
			EndIF
		Else
			//Se (cAliasF500)->ORIFIN igual a .T. indica que o titulo nao possui vinculo com documento fiscal	
			//Se tiver valor no campo VRDESC, foi baixa que não caracteriza um recebimento
		
			IF (cAliasF500)->VRDESC == 0
	
				cInfCompl		:= ''
				cCnpj			:= ''
				nDesconto		:= Iif(lCmpVrDes,(cAliasF500)->VRDESCON,0)
				// Quando temos uma Reliquidação de uma liquidação, o Financeiro tem o controle na TABELA Fi7, na função FinSpdF500 eles criaram outras 2 funções para rastrear o TITULO Principal quando temos mudança de regime Competencia para CAIXA.
				// Dessa forma iremos buscar no (cAliasF500)->DTPAI a data do TITULO PAI que foi gerando as liquidações e Re-Liquidações.
				// Essa situação é somente quanto tenho LIquidação e Reliquidação; Verifico se DTPAI e RASTRO tem conteudo.
				If lDtTitPai .And. lTitPai .And. (cAliasF500)->DTPAI <> " " .And.  (cAliasF500)->RASTRO <> " "
					dEmisTit    	:= cToD((cAliasF500)->DTPAI)
				Else
					dEmisTit    	:= cToD(SubStr((cAliasF500)->EMISSAO,7,2) + "/" + SubStr((cAliasF500)->EMISSAO,5,2) + "/" + SubStr((cAliasF500)->EMISSAO,1,4))
				Endif
				cCodCon         := ""

				If nDesconto > 0 .And. ;
				   (Max((cAliasF500)->BASEPIS - nDesconto, 0) == 0 .Or.;
				    Max((cAliasF500)->BASECOF - nDesconto, 0) == 0)   //Verifico se o valor de desconto é maior que zero e se este é maior que as bases de PIS e Cofins evitando valores negativos na apuração
					nDesconto := 0
				EndiF
				
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

				oApurSai:SetCST(oCaixa:getCST(PIS))
				oApurSai:SetReceita((cAliasF500)->VALOR)
				oApurSai:CodCon()
				oApurSai:RecBlocos("F")				
				
				//Grava aqui as informações da nota	
				ObjF0T:Clear()
				ObjF0T:SetValue("F0T_PER",dDataDe)
				ObjF0T:SetValue("F0T_FILAPU",cFilialMat)
				ObjF0T:SetValue("F0T_TIPO",'2')				
				ObjF0T:SetValue("F0T_NUMTIT",(cAliasF500)->NUMERO)
				ObjF0T:SetValue("F0T_PREFIX",(cAliasF500)->PREFIXO)
				ObjF0T:SetValue("F0T_PARC",(cAliasF500)->PARCELA)
				ObjF0T:SetValue("F0T_DTEMI",dEmisTit)
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
			
				// Caso tenha ocorrido mudança de regime - de competência para caixa - 
				// Neste caso não posso tributar novamente a receita decorrente da baixa do título pois a 
				// mesma já foi tributada no período da emissão (competência). 
				// Devo, então, gerar um ajuste de redução para "zerar" os valores referentes à baixa.
				// Aqui só adiciono as informações no array aAjuPISCOF, depois do processamento do regime de caixa
				// vou efetivar os ajustes.
				If !Empty(dDtMudReg) .And. dEmisTit < dDtMudReg
					
					cInfCompAj := "Tit.:" + AllTrim((cAliasF500)->NUMERO) +;
					 		      ",Pref.:" + AllTrim((cAliasF500)->PREFIXO) +; 
								  ",Parc.:" + AllTrim((cAliasF500)->PARCELA) +;
								  ",Tipo:" + AllTrim((cAliasF500)->TIPO) +;
								  ",Cli/Loja:" + AllTrim((cAliasF500)->CHVCLIENTE) +;
								  ",Emis.:" + DtoC(dEmisTit)

					cChvTit    := (cAliasF500)->PREFIXO + (cAliasF500)->NUMERO + (cAliasF500)->PARCELA + (cAliasF500)->TIPO + (cAliasF500)->CHVCLIENTE

					// PIS

					//Passa CST de PIS para classe
					oApurEFD:SetCST(oCaixa:getCST(PIS))
					cCodCon := oApurEFD:CodCon()

					// Verifica se trata-se de uma receita tributada p/ fazer o ajuste.
					If AllTrim(cCodCon) $ "51|52|53|54"
						If (nPosAj := aScan(aAjuPISCOF, { |x| x[1] == PIS .And. x[18] == cChvTit  .And. x[7] == cCodCon .And. Str(x[15]) == Str(oCaixa:getAliq(PIS)) })) == 0
							aAdd(aAjuPISCOF, {})
							nPosAj := Len(aAjuPISCOF)                            
							aAdd(aAjuPISCOF[nPosAj], PIS)						// 01 - TRIBUTO
							aAdd(aAjuPISCOF[nPosAj], REDUCAO)					// 02 - INDICADOR DO TIPO DE AJUSTE
							aAdd(aAjuPISCOF[nPosAj], '05')						// 03 - CÓDIGO DO AJUSTE (Ajuste Oriundo de Outras Situações)
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getNumDoc())		// 04 - NUMERO DO DOCUMENTO
							aAdd(aAjuPISCOF[nPosAj], cDescAj + " - " +cInfCompAj)// 05 - DESCRIÇÃO DO AJUSTE
							aAdd(aAjuPISCOF[nPosAj], dEmisTit)					// 06 - DATA DE REFERÊNCIA DO AJUSTE
							aAdd(aAjuPISCOF[nPosAj], cCodCon)					// 07 - CÓDIGO DA CONTRIBUIÇÃO
							aAdd(aAjuPISCOF[nPosAj], CUMULAT)					// 08 - REGIME
							aAdd(aAjuPISCOF[nPosAj], '4')						// 09 - ORIGEM (4 - FINANCEIRO)
							aAdd(aAjuPISCOF[nPosAj], (oCaixa:getBase(PIS) * (oCaixa:getAliq(PIS) / 100))) // 10 - VALOR DO AJUSTE
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getCST(PIS))		// 11 - CST
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getConta())			// 12 - CONTA
							aAdd(aAjuPISCOF[nPosAj], cInfCompAj)				// 13 - INFOS. COMPLEMENTARES (M225)
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getBase(PIS))		// 14 - BASE
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getAliq(PIS))		// 15 - ALIQUOTA
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getTNatRec())		// 16 - TABELA - NATUREZA DA RECEITA
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getCNatRec())		// 17 - CODIGO - NATUREZA DA RECEITA
							aAdd(aAjuPISCOF[nPosAj], cChvTit)					// 18 - CHAVE DO TITULO (Não vai no ajuste - Só p/ agrupar)
						Else
							aAjuPISCOF[nPosAj, 10] += (oCaixa:getBase(PIS) * (oCaixa:getAliq(PIS) / 100))	// 10 - VALOR DO AJUSTE
							aAjuPISCOF[nPosAj, 14] += oCaixa:getBase(PIS)									// 14 - BASE
						EndIf
					EndIf

					// COFINS

					//Passa CST de COFINS para classe
					oApurEFD:SetCST(oCaixa:getCST(COFINS))
					cCodCon := oApurEFD:CodCon()

					// Verifica se trata-se de uma receita tributada p/ fazer o ajuste.
					If AllTrim(cCodCon) $ "51|52|53|54"
						If (nPosAj := aScan(aAjuPISCOF, { |x| x[1] == COFINS .And. x[18] == cChvTit  .And. x[7] == cCodCon .And. Str(x[15]) == Str(oCaixa:getAliq(COFINS)) })) == 0
							aAdd(aAjuPISCOF, {})
							nPosAj := Len(aAjuPISCOF)
							aAdd(aAjuPISCOF[nPosAj], COFINS)					// 01 - TRIBUTO
							aAdd(aAjuPISCOF[nPosAj], REDUCAO)					// 02 - INDICADOR DO TIPO DE AJUSTE
							aAdd(aAjuPISCOF[nPosAj], '05')						// 03 - CÓDIGO DO AJUSTE (Ajuste Oriundo de Outras Situações)
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getNumDoc())		// 04 - NUMERO DO DOCUMENTO
							aAdd(aAjuPISCOF[nPosAj], cDescAj + " - " +cInfCompAj)// 05 - DESCRIÇÃO DO AJUSTE
							aAdd(aAjuPISCOF[nPosAj], dEmisTit)					// 06 - DATA DE REFERÊNCIA DO AJUSTE
							aAdd(aAjuPISCOF[nPosAj], cCodCon)					// 07 - CÓDIGO DA CONTRIBUIÇÃO
							aAdd(aAjuPISCOF[nPosAj], CUMULAT)					// 08 - REGIME
							aAdd(aAjuPISCOF[nPosAj], '4')						// 09 - ORIGEM (4 - FINANCEIRO)
							aAdd(aAjuPISCOF[nPosAj], (oCaixa:getBase(COFINS) * (oCaixa:getAliq(COFINS) / 100))) // 10 - VALOR DO AJUSTE
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getCST(COFINS))		// 11 - CST
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getConta())			// 12 - CONTA
							aAdd(aAjuPISCOF[nPosAj], cInfCompAj)				// 13 - INFOS. COMPLEMENTARES (M225)
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getBase(COFINS))	// 14 - BASE
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getAliq(COFINS))	// 15 - ALIQUOTA
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getTNatRec())		// 16 - TABELA - NATUREZA DA RECEITA
							aAdd(aAjuPISCOF[nPosAj], oCaixa:getCNatRec())		// 17 - CODIGO - NATUREZA DA RECEITA
							aAdd(aAjuPISCOF[nPosAj], cChvTit)					// 18 - CHAVE DO TITULO (Não vai no ajuste - Só p/ agrupar)							
						Else
							aAjuPISCOF[nPosAj, 10] += (oCaixa:getBase(COFINS) * (oCaixa:getAliq(COFINS) / 100)) // 10 - VALOR DO AJUSTE
							aAjuPISCOF[nPosAj, 14] += oCaixa:getBase(COFINS)									// 14 - BASE
						EndIf
					EndIf

				EndIf

				oCaixa:Clear()
				
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

	If Iif(FindFunction('FinSpdDel'),FinSpdDel(2),.T.)//Verifica se pode fechar a area da tabela temporaria
		oCaixa:FechaAlias(cAliasF500)
	EndIF	
	
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

	 // Limpa os dados do HashMap
	HMClean(oHExigSusp)
	// Libera o objeto de HashMap
	FreeObj(oHExigSusp)
	oHExigSusp := Nil

	
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
	If Empty((cAlias)->F4_TPREG) .And. (cAlias)->(FieldPos("FT_TES"))>0 .And. !Empty((cAlias)->FT_TES) .And. SPEDSeek("SF4",1,xFilial("SF4")+(cAlias)->FT_TES)		
		If SF4->F4_TPREG $ '1/2'
			cRegime	:= SF4->F4_TPREG
		ElseIf SF4->F4_TPREG == '3'
			cRegime	:= (cAlias)->B1_TPREG
		Else
			cRegime	:= NAOCUMULAT //O legado será mantido, nesta situação onde o TES não resolve é adotado regime Não Cumulativo
		EndIf
	Else	
		//TES
		//Se o regime definido no TES for igual a ambos ou por algum motivo não encontrar o TES, o produto irá definir o regime
		If (cAlias)->F4_TPREG $ '1/2'
			cRegime	:= (cAlias)->F4_TPREG
		ElseIf (cAlias)->F4_TPREG == '3'
			cRegime	:= (cAlias)->B1_TPREG
		Else
			cRegime	:= NAOCUMULAT //O legado será mantido, nesta situação onde o TES não resolve é adotado regime Não Cumulativo
		EndIf
	Endif
ElseIf nM996Tpr == 2
	//PRODUTO
	cRegime	:= (cAlias)->B1_TPREG
ElseIf nM996Tpr == 3
	//CLIENTE
	cRegime	:= (cAlias)->A1_TPREG
EndIf

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
Static Function ASA001CANC(dDataDe, dDataAte,cRegime,cNrLivro,aXFilial,cReg, cOpAju)

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
Local lCF4FIL		:= CF4->(FieldPos("CF4_FLORIG"))>0
Local cVersao 	:= GetVersao(.F.)

Default cOpAju	:= "1" //Ajuste da contribuição
cMvDCODRSE  := IIF(Empty(cMvDCODRSE), "'110'", cMvDCODRSE)

/*1-Ajuste da contribuição normal
2-Ajuste da contribuição somente do cst 03
3-Ajuste da base de cálculo
*/
//Verificação se existe o 4 índice na CF4
DbSelectArea("SIX")
DbSetOrder(1)
IF cVersao <> '12'
	If MsSeek("CF4" + "3")
		lCF4FLORIG	:= .T.
	EndIF
Else
	If MsSeek("CF4" + "4")
		lCF4FLORIG	:= .T.
	EndIF
EndIF	

dbSelectArea("CF4")
IF lCF4FLORIG
	IF cVersao <> '12'
		dbSetOrder(3)
	Else
		dbSetOrder(4)
	EndIF
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
	If nMVM996TPR==1  .And. SF4->(FieldPos("F4_TPREG"))>0 .And. SB1->(FieldPos("B1_TPREG"))>0
		If	SFT->(FieldPos("FT_TES"))>0
			cSelect += ",SFT.FT_TES"
		Endif
		cSelect	+=	" ,SF4.F4_TPREG,SB1.B1_TPREG"
		cFrom		+=	" LEFT JOIN "+RetSqlName("SD2")+" SD2 ON SD2.D2_FILIAL='"+xFilial("SD2")+"' AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND "
		cFrom		+=	" SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.D_E_L_E_T_=' ' "
		cFrom		+=	" LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_=' ' "
		cFrom		+=	" LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' '"
	Elseif nMVM996TPR==2 .And. SB1->(FieldPos("B1_TPREG"))>0
		cSelect	+=	" ,SB1.B1_TPREG"
		cFrom		+=	" LEFT JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL='"+xFilial("SB1")+"' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' '"   
	Elseif nMVM996TPR==3 .And. SA1->(FieldPos("A1_TPREG")) > 0
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

	If cOpAju == '3' .AND. (cAliasSFT)->FT_CSTPIS == '03'
   		(cAliasSFT)->(DbSkip())
   		Loop
	EndIF
	
	If cOpAju == '2' .AND. (cAliasSFT)->FT_CSTPIS <> '03'
   		(cAliasSFT)->(DbSkip())
   		Loop
	EndIF	

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

oApurSai:EstornCanc(NAOCUMULAT,cOpAju)
oApurSai:EstornCanc(CUMULAT, cOpAju)

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
Static Function ASA001Devo(dDataDe,dDataAte,cNrLivro,cTpMov,nMVM996TPR,cRegime,lPerAtu,aXFilial,cOrigem,lCPRBNF,cSPCBPSE, cOpAju,lAjBase)

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
Local lCF4FLORIG := .F. //Se existe o indice na CF4 correcriado corretamente
Local lCF4FIL	 := CF4->(FieldPos("CF4_FLORIG"))>0 //Se existe o campo criado 
Local lAtuCPRB	:= .F.
Local nBaseCalc	:= 0
Local nAlq	:= 0
Local lBlocoD := .F.
Local nBseTot := 0
Local nValCrd := 0
Local nBseProp := 0
Local cVersao := GetVersao(.F.)
Local cCodRec := ''
Local nBsReduz 	:= 0 //Tratativa para CST 05 com relação a Base de redução ReduzBase()
Local nVlReduz	:= 0 //Tratativa para CST 05 com relação ao valor de Redução para o Metodo ReduzBase()
Local nValorAj	:= 0 //Tratativa para CST 05 com relação ao valor de PIS ou Cofins no calculo de valor de Ajuste de Base pelas devoluções

Default cOpAju	:= "1"
//Verificação se existe o 4 índice na CF4
DbSelectArea("SIX")
DbSetOrder(1)
IF cVersao <> '12'
	If MsSeek("CF4" + "3")
		lCF4FLORIG	:= .T.
	EndIF
Else
	If MsSeek("CF4" + "4")
		lCF4FLORIG	:= .T.
	EndIF
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
oAjuDeb:LoadCKS( Iif(cOpAju == '3', .T., .F.))

If lCPRBNF
	oCPRB	:= CPRBEFD():New()
	oCPRB:SetDtIni(dDataDe)
Endif

dbSelectArea("CF4")
IF lCF4FLORIG // Se existe o campo CF4_FLORIG e se 
	IF cVersao <> '12'
		dbSetOrder(3)
	Else
		dbSetOrder(4)	
	EndIF
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
		
		lBlocoD := If(aModNot(Alltrim(SFT->FT_ESPECIE)) $ '07|08|8B|09|10|11|26|27|57|67', .T., .F.)	
		lMoto	:= Iif(SFT->FT_TNATREC == '4312' .AND. SubStr(SFT->FT_CNATREC,1,2) $ '20/30',.T.,.F.)			
		nBseTot := 0
		nValCrd := 0
		nBseProp := 0	
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Devolucao no proprio periodo³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If DTOS(SFT->FT_ENTRADA) >= DTOS(FirstDay(dDataDe)) .And. DTOS(SFT->FT_ENTRADA) <= DTOS(LastDay(dDataAte)) .And. !lBlocoD
			
			//Somente irá gravar a nota de devolução na tabela CF4 se a nota original realmente foi considerada
			//para apuração de PIS e COFINS, para poder efetuar a redução da base de cálculo, caso contrário
			//não fará redução e não grava CF4.
			lGravaCF4	:= .F.
			
			If cTpMov == 'S' .AND. oApurEFD:ChkRegraNf(SFT->FT_ESPECIE,SFT->FT_CFOP,NFSAIDA,,,(cAliasSFT)->FT_CSTPIS)

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
					CF4->CF4_FILIAL		:= xFilial("CF4")
					CF4->CF4_NOTA 		:=SFT->FT_NFISCAL 										// 01- NOTA FISCAL
					CF4->CF4_SERIE 		:=SFT->FT_SERIE  										// 02- SERIE DA NOTA FISCAL					
					CF4->CF4_ITEM 		:=SFT->FT_ITEM  											// 03- ITEM DA NOTA FISCAL
					CF4->CF4_CLIFOR 	:=SFT->FT_CLIEFOR  										// 04- CLIENTE OU FORNECEDOR
					CF4->CF4_LOJA 		:=SFT->FT_LOJA	  										// 05- LOJA
					CF4->CF4_TIPMOV 	:=SFT->FT_TIPOMOV  										// 06- TIPO DE MOVIMENTO
					CF4->CF4_VALPIS 	:=Round(SFT->FT_VALPIS*nPercDevP,2)					// 07- VALOR DO PIS
					CF4->CF4_ALIPIS 	:=SFT->FT_ALIQPIS  										// 08- ALIQUOTA DO PIS
					CF4->CF4_VALCOF 	:=Round(SFT->FT_VALCOF*nPercDevC,2)					// 10- VALOR COFINS
					CF4->CF4_ALICOF 	:=SFT->FT_ALIQCOF											// 11- ALIQUOTA COFINS
					CF4->CF4_DATAE 		:=SFT->FT_EMISSAO  										// 13- DATA DE ENTRADA
					CF4->CF4_CSTPIS 	:=SFT->FT_CSTPIS  										// 15- SIT. TRIBUTARIA PIS
					CF4->CF4_CSTCOF 	:=SFT->FT_CSTCOF 							 				// 16- SIT. TRIBUTARIA COFINS
					CF4->CF4_PATPIS 	:=Iif(SFT->FT_PAUTPIS==0,0,SFT->FT_PAUTPIS) 			// 19- VALOR PAUTA PIS
					CF4->CF4_PATCOF 	:=Iif(SFT->FT_PAUTCOF==0,0,SFT->FT_PAUTCOF)			// 20- VALOR PAUTA COFINS					
					CF4->CF4_BASPIS		:= Round(SFT->FT_BASEPIS*nPercDevP,2)
					CF4->CF4_BASCOF		:= Round(SFT->FT_BASECOF*nPercDevP,2)					
					CF4->CF4_TIPO		:= 'D'
					CF4->CF4_DTALT 		:= cDtAlt
					
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
					oApurEFD:SetAlqSt(SFT->FT_ALIQPS3)
					oApurEFD:SetCST(SFT->FT_CSTPIS)
					oApurEFD:SetTNatRec(SFT->FT_TNATREC)
					oApurEFD:SetCNatRec(SFT->FT_CNATREC)
					
					//Verifica se documento original é Cupom Fiscal
					If !Empty(SFT->FT_PDV) .AND. AllTrim(SFT->FT_ESPECIE)$"CF/ECF"
						oApurEFD:SetOrigem(CUPOM)					
					Else
						oApurEFD:SetOrigem(FISCALSAI)					
					EndIF					
					oApurEFD:SetTpReg(cRegDev)					
					oApurEFD:DefRegime()
					oApurEFD:SetCodDC(oApurEFD:CodCon())
					cChave	 :=	oApurEFD:BuscaChave()
					nBsReduz := Iif(SFT->FT_CSTPIS=='05',Round(SFT->FT_BASEPS3*nPercDevP,2),Round(SFT->FT_BASEPIS*nPercDevP,2))
					nVlReduz := Iif(SFT->FT_CSTPIS=='05',Round(SFT->FT_VALPS3*nPercDevP,2),Round(SFT->FT_VALPIS*nPercDevP,2))
					oApurEFD:ReduzBase(nBsReduz,nVlReduz,DEBITO,cChave, SFT->FT_CSTPIS,SFT->FT_CODBCC,Iif(SFT->FT_PAUTPIS > 0,'1','2'))
					oApurEFD:ReduzCL0(nBsReduz,Round(SFT->FT_VALCONT*nPercDevP,2))	
					
					If lMoto
						oApurEFD:SetCST("01")
						oApurEFD:SetCodDC(oApurEFD:CodCon())
						cChave	:=	oApurEFD:BuscaChave()
						oApurEFD:ReduzBase(Round(SFT->FT_BASEPIS*nPercDevP,2),Round(SFT->FT_VALPIS*nPercDevP,2),DEBITO,cChave, '01',SFT->FT_CODBCC,Iif(SFT->FT_PAUTPIS > 0,'1','2'))
						oApurEFD:ReduzCL0(Round(SFT->FT_BASEPIS*nPercDevP,2),Round(SFT->FT_VALCONT*nPercDevP,2))
					EndIf				
					
					//PROCESSA ESTORNO DA COFINS					
					oApurEFD:SetTributo(COFINS)
					oApurEFD:SetAlqTrib(SFT->FT_ALIQCOF)
					oApurEFD:SetAlqSt(SFT->FT_ALIQCF3)
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
					nBsReduz := Iif(SFT->FT_CSTCOF=='05',Round(SFT->FT_BASECF3*nPercDevP,2),Round(SFT->FT_BASECOF*nPercDevP,2))
					nVlReduz := Iif(SFT->FT_CSTCOF=='05',Round(SFT->FT_VALCF3*nPercDevP,2),Round(SFT->FT_VALCOF*nPercDevP,2))
					oApurEFD:ReduzBase(nBsReduz,nVlReduz,DEBITO,cChave,  SFT->FT_CSTCOF ,SFT->FT_CODBCC,Iif(SFT->FT_PAUTCOF > 0,'1','2'))	
					//oApurEFD:ReduzCL0(Round(SFT->FT_BASECOF*nPercDevP,2),Round(SFT->FT_VALCONT*nPercDevP,2))					
					
					If lMoto
						oApurEFD:SetCST("01")
						oApurEFD:SetCodDC(oApurEFD:CodCon())
						cChave	:=	oApurEFD:BuscaChave()
						oApurEFD:ReduzBase(Round(SFT->FT_BASECOF*nPercDevP,2),Round(SFT->FT_VALCOF*nPercDevP,2),DEBITO,cChave, '01' ,SFT->FT_CODBCC,Iif(SFT->FT_PAUTCOF > 0,'1','2'))
					EndIf	

					//Aqui será efetuado a dedução da CPRB, referente a parcela de receitas de consórcios cadastrados na rotina demais documentos
					IF lCPRBNF .AND. !Empty((cAliasSFT)->FT_ATIVCPB) .AND. (cAliasSFT)->FT_BASECPB >0 .AND. (cAliasSFT)->FT_ALIQCPB > 0
						
						//Verifica parâmetro para definir se utilizará código de serviço ou de outros serviços.
						cCodRec := Iif(AllTrim((cAliasSFT)->FT_ATIVCPB)$ cSPCBPSE ,mv_par16 ,mv_par17 )
							
						oCPRB:= CPRBEFD():New()
						oCPRB:SetCodRec(cCodRec)
						oCPRB:SetDtIni(dDataDe)
						oCPRB:SetFilApu(FWGETCODFILIAL)
						//Preciso passar a somatoria do valor do ipi e St para que a dedução de base de CPRB nao fique com valores incorretos no tocante as tabelas CKV e CKX.
						oCPRB:DeduzBase((cAliasSFT)->FT_ATIVCPB,(cAliasSFT)->FT_ALIQCPB,(cAliasSFT)->FT_BASECPB,(cAliasSFT)->FT_VALCONT, (cAliasSFT)->FT_VALIPI + (cAliasSFT)->FT_ICMSRET )
						FreeObj(oCPRB)
						oCPRB:= nil

					EndIF

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
				oAjuCred:SetCodBcc(SFT->FT_CODBCC)
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
				oAjuCred:SetOrigem('C') //Devolução de compra de período anterior		 //ok
				oAjuCred:SetNumDev((cAliasSFT)->FT_NFISCAL)
				oAjuCred:SetNumOri(SFT->FT_NFISCAL)
				
				//---------------------------------------------------------
				//DETALHAMENTO DOS AJUSTES COM INFORMAÇÕES DA NOTA ORIGINAL
				//---------------------------------------------------------
				oAjuCred:SetCst(SFT->FT_CSTCOF)
				oAjuCred:SetCodBcc(SFT->FT_CODBCC)
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
				
			ElseIf cTpMov == 'S' .AND. !lPerAtu .AND. ;
					(cOpAju == "1" .Or. (cOpAju == "2" .AND. SFT->FT_CSTCOF == "03")  .Or. (cOpAju == "3" .AND. SFT->FT_CSTCOF <> "03"))

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
				oApurEFD:SetAlqSt(SFT->FT_ALIQPS3)
				cCodCon:=oApurEFD:CodCon()
				oApurEFD:SetTNatRec(SFT->ft_tnatrec)
				oApurEFD:SetCNatRec(SFT->ft_cnatrec)		
				oApurEFD:SetGNatRec(SFT->ft_gruponc)
				oApurEFD:SetDNatRec(SFT->FT_DTFIMNT)
				oApurEFD:SetQtde(SFT->FT_QUANT)
				oApurEFD:SetVlPauta(SFT->ft_pautPIS)

				//Considera alíquota e base de cálculo considerando cálculo alíquota com percentual
				nBaseCalc	:= Iif(SFT->FT_CSTPIS=='05',SFT->FT_BASEPS3,SFT->FT_BASEPIS)
				nAlq		:= Iif(SFT->FT_CSTPIS=='05',SFT->FT_ALIQPS3,SFT->FT_ALIQPIS)
				nValorAj	:= Iif(SFT->FT_CSTPIS=='05',SFT->FT_VALPS3,SFT->FT_VALPIS)
				
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
				If lAjBase
					oAjuDeb:SetVlAju(IIf(SFT->FT_QUANT==(cAliasSFT)->FT_QUANT, nBaseCalc, (cAliasSFT)->FT_QUANT * (nBaseCalc/SFT->FT_QUANT)))	
				Else
					oAjuDeb:SetVlAju(IIf(SFT->FT_QUANT==(cAliasSFT)->FT_QUANT, nValorAj, (cAliasSFT)->FT_QUANT*nValorAj/SFT->FT_QUANT))
				EndIf
				
				oAjuDeb:SetNumDev((cAliasSFT)->FT_NFISCAL)
				oAjuDeb:SetNumOri(SFT->FT_NFISCAL)
				oAjuDeb:SetCst(SFT->FT_CSTCOF)
				oAjuDeb:SetConta(SFT->FT_CONTA)
				oAjuDeb:SetInfComp('Ajuste de redução de débito de PIS em função de retorno de mercadoria vendida em período anterior')
				oAjuDeb:SetBase(Round(nBaseCalc*nPercDevP,2))
				oAjuDeb:SetAlq(nAlq)
				oAjuDeb:SetTNatRec(SFT->ft_tnatrec)
				oAjuDeb:SetCNatRec(SFT->ft_cnatrec)				
				oAjuDeb:SetAjuBase(.F.)				
				
				If cOpAju == "3"
					//Ajustes de base de cálculo
					oAjuCred:SetOrigem('A') //Ajuste de base de cálculo
					oAjuDeb:SetCNPJ(SM0->M0_CGC)
					oAjuDeb:SetCodAju('02')
					oAjuDeb:SetAjuBase(.T.)
				EndIF
				
				oAjuDeb:Ajustar()
				
				If lMoto
					oAjuDeb:SetVlAju(IIf(SFT->FT_QUANT==(cAliasSFT)->FT_QUANT, SFT->FT_VALPIS, (cAliasSFT)->FT_QUANT*(SFT->FT_VALPIS)/SFT->FT_QUANT))
					oAjuDeb:SetBase(Round(SFT->FT_BASEPIS*nPercDevP,2))
					oAjuDeb:SetCst('01')
					oAjuDeb:SetCodDC(cCodCon)
					oAjuDeb:Ajustar()
				EndIf			

				//Processa código da ~contribuição da COFINS
				oApurEFD:SetCST(SFT->FT_CSTCOF) 	
				//Pega código da contribuição processada pela classe
				oApurEFD:SetAlqSt(SFT->FT_ALIQCF3)
				cCodCon:=oApurEFD:CodCon()	
				oApurEFD:SetTNatRec(SFT->ft_tnatrec)
				oApurEFD:SetCNatRec(SFT->ft_cnatrec)		
				oApurEFD:SetGNatRec(SFT->ft_gruponc)
				oApurEFD:SetDNatRec(SFT->FT_DTFIMNT)
				oApurEFD:SetQtde(SFT->FT_QUANT)
				oApurEFD:SetVlPauta(SFT->ft_pautcof)

				//Considera alíquota e base de cálculo considerando cálculo alíquota com percentual
				nBaseCalc	:= Iif(SFT->FT_CSTPIS=='05',SFT->FT_BASECF3,SFT->FT_BASECOF)
				nAlq		:= Iif(SFT->FT_CSTPIS=='05',SFT->FT_ALIQCF3,SFT->FT_ALIQCOF)
				nValorAj	:= Iif(SFT->FT_CSTPIS=='05',SFT->FT_VALCF3,SFT->FT_VALCOF)
				
				
				If oApurEFD:OperPauta()
					//Busca a base de cálculo e alíquota em quantidade convertida em quantidade e em reais respectivamente
					nBaseCalc	:= oApurEFD:GetBcTrib()
					nAlq		:= oApurEFD:GetAlqTrib()
				EndIF
								
				//todo ajuste da base de cálculo

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
				If lAjBase
					oAjuDeb:SetVlAju(IIf(SFT->FT_QUANT==(cAliasSFT)->FT_QUANT, nBaseCalc, (cAliasSFT)->FT_QUANT * (nBaseCalc/SFT->FT_QUANT)))	
				Else
					oAjuDeb:SetVlAju(IIf(SFT->FT_QUANT==(cAliasSFT)->FT_QUANT, nValorAj, (cAliasSFT)->FT_QUANT*nValorAj/SFT->FT_QUANT))
				EndIf
				
				oAjuDeb:SetNumDev((cAliasSFT)->FT_NFISCAL)
				oAjuDeb:SetNumOri(SFT->FT_NFISCAL)
				oAjuDeb:SetCst(SFT->FT_CSTCOF)
				oAjuDeb:SetConta(SFT->FT_CONTA)
				oAjuDeb:SetInfComp('Ajuste de redução de débito de COFINS em função de retorno de mercadoria vendida em período anterior')
				oAjuDeb:SetBase(Round(nBaseCalc*nPercDevP,2))
				oAjuDeb:SetAlq(nAlq)
				oAjuDeb:SetTNatRec(SFT->ft_tnatrec)
				oAjuDeb:SetCNatRec(SFT->ft_cnatrec)				
				oAjuDeb:SetAjuBase(.F.)
				
				If cOpAju == "3"
					//Ajustes de base de cálculo
					oAjuDeb:SetCNPJ(SM0->M0_CGC)
					oAjuDeb:SetCodAju('02')
					oAjuDeb:SetAjuBase(.T.)
				EndIF
				
				oAjuDeb:Ajustar()

				If lMoto
					oAjuDeb:SetVlAju(IIf(SFT->FT_QUANT==(cAliasSFT)->FT_QUANT,SFT->FT_VALCOF, (cAliasSFT)->FT_QUANT*(SFT->FT_VALCOF)/SFT->FT_QUANT))
					oAjuDeb:SetBase(Round(SFT->FT_BASECOF*nPercDevP,2))
					oAjuDeb:SetCst('01')
					oAjuDeb:SetCodDC(cCodCon)
					oAjuDeb:Ajustar()
				EndIf

				//Realiza Ajustes da CPRB			
				If lCPRBNF .And. SFT->FT_VALCPB > 0
					lAtuCPRB	:= .T.
					oCPRB:SetCodRec(Iif(AllTrim((cAliasSFT)->FT_ATIVCPB)$cSPCBPSE,mv_par16,mv_par17)) 
					oCPRB:SetTpAju(REDUCAO)
					oCPRB:SetValAju(IIf(SFT->FT_QUANT==(cAliasSFT)->FT_QUANT,SFT->FT_VALCPB,(cAliasSFT)->FT_QUANT*SFT->FT_VALCPB/SFT->FT_QUANT))
					oCPRB:SetCodAjus('06')
					oCPRB:SetNumero((cAliasSFT)->FT_NFISCAL)
					oCPRB:SetDescr("Devolução da nota fiscal " + SFT->FT_NFISCAL)		
					oCPRB:SetDtRefer((cAliasSFT)->FT_ENTRADA)
					oCPRB:GravaAju()	
					oCPRB:AtualizaCPRB()
					oCPRB:Clear()				
				Endif				
			Endif
		Endif
	Endif
	RestArea (aAreaSFT)
	(cAliasSFT)->(DbSkip())
EndDo

oAjuDeb:FechaAlias(cAliasSFT)
//Chama função para poder buscar possíveis saldos de deduções
//de período anterior para deduzir o débito do período atual.

If !lPerAtu .AND. cOpAju <> "3"
	ASA001DANT(dDataDe,oAjuDeb,oAjuCred,cTpMov,aXFilial,cOpAju)
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
Static Function ASA001DANT(dDataDe,oAjuDeb,oAjuCred,cTpMov,aXFilial,cOpAju)

Local oSaldoDed
Local cAliasCF3	:= ''
Local cDescr	:= ''
Local cDescPis := ''
Local cDescCof := ''
Local oDebito		
Local lConta := Iif(('CF3')->(FieldPos("CF3_CONTA")) > 0, .T., .F.)

oSaldoDed	:= 	SALDODED():New()
oSaldoDed:SetFilial(aXFilial)
oSaldoDed:SetDtIni(dDataDe)			
oSaldoDed:SetPerOri(dDataDe)

If cTpMov == 'S' .AND. cOpAju $ "1/2"
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
		If lConta
			oAjuDeb:SetConta((cAliasCF3)->CF3_CONTA)
		EndIf
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
		If lConta
			oAjuDeb:SetConta((cAliasCF3)->CF3_CONTA)
		EndIf
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

If cTpMov == 'S' .AND. cOpAju $ "1/2"
	//CARREGA as deduções de débito de período anterior
	cAliasCF3	:= oSaldoDed:LoadDedAnt('D')
	
	DbSelectArea (cAliasCF3)
	(cAliasCF3)->(DbGoTop ())
	Do While !(cAliasCF3)->(Eof ())
	
		//Realiza os ajustes de redução do débito.
		//Realizado somente para as operações Exclusivamente CUmulativas, pois no regime Não Cumulativo
		//As devoluções de venda dão direito ao crédito.
		cDescPis	:= "Saldo de Dedução de PIS referênte ao período anterior, proveniente do registro F700"
		oAjuDeb:SetTributo(PIS)
		oAjuDeb:SetTpAjust(REDUCAO)
		oAjuDeb:SetCodAju('05')
		oAjuDeb:SetDescAju(cDescPis)
		oAjuDeb:SetDtRefer((cAliasCF3)->CF3_PERORI)
		oAjuDeb:SetMsmCod(.F.) // Com este parâmetro com .F. não irá efetuar o ajuste exatamente no mesmo código
		oAjuDeb:SetRegime((cAliasCF3)->CF3_REGIME)
		oAjuDeb:SetOrigem('D')
		oAjuDeb:SetVlAju((cAliasCF3)->CF3_VLRPIS)
		If lConta
			oAjuDeb:SetConta((cAliasCF3)->CF3_CONTA)
		EndIf
		oAjuDeb:SetInfComp('Ajuste de Redução da Contribuição, referente a Redução de período anterior não realizado, em função de não ter Contribuição suficiente para ser reduzido.')
		oAjuDeb:Ajustar()		
	
		//Realiza Ajuste para a COFINS
		cDescCof	:= "Saldo de Dedução de Cofins referênte ao período anterior, proveniente do registro F700"
		oAjuDeb:SetTributo(COFINS)
		oAjuDeb:SetTpAjust(REDUCAO)
		oAjuDeb:SetCodAju('05')
		oAjuDeb:SetDescAju(cDescCof)
		oAjuDeb:SetDtRefer((cAliasCF3)->CF3_PERORI)
		oAjuDeb:SetMsmCod(.F.) // Com este parâmetro com .F. não irá efetuar o ajuste exatamente no mesmo código
		oAjuDeb:SetRegime((cAliasCF3)->CF3_REGIME)
		oAjuDeb:SetOrigem('D')
		oAjuDeb:SetVlAju((cAliasCF3)->CF3_VLRCOF)
		If lConta
			oAjuDeb:SetConta((cAliasCF3)->CF3_CONTA)
		EndIf
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

Endif

//Aqui deverá processar somente os ajustes de base de cálculo
If cTpMov == 'S' .AND. cOpAju == "3"

	//CARREGA as deduções de ajustes de base de cálculo de período anterior
	cAliasCF3	:= oSaldoDed:LoadDedAnt('A')
	
	DbSelectArea (cAliasCF3)
	(cAliasCF3)->(DbGoTop ())
	Do While !(cAliasCF3)->(Eof ())
	
		//Realiza os ajustes de redução do débito.
		//Realizado somente para as operações Exclusivamente CUmulativas, pois no regime Não Cumulativo
		//As devoluções de venda dão direito ao crédito.				
		
		cDescPis	:= "Saldo de Redução de Base de Cálculo de PIS referênte ao período anterior, proveniente do registro M215."
		oAjuDeb:SetCNPJ(SM0->M0_CGC) 
		oAjuDeb:SetCrdDeb("2")
		oAjuDeb:SetTributo(PIS)
		oAjuDeb:SetTpAjust(REDUCAO)
		oAjuDeb:SetCodAju('42')
		oAjuDeb:SetDescAju(cDescPis)
		oAjuDeb:SetDtRefer(dDataDe)
		oAjuDeb:SetMsmCod(.F.) // Com este parâmetro com .F. não irá efetuar o ajuste exatamente no mesmo código
		oAjuDeb:SetRegime((cAliasCF3)->CF3_REGIME)
		oAjuDeb:SetOrigem('A')
		oAjuDeb:SetVlAju((cAliasCF3)->CF3_VLRPIS)
		If lConta
			oAjuDeb:SetConta((cAliasCF3)->CF3_CONTA)
		EndIf
		oAjuDeb:SetInfComp('Ajuste de Redução da Base de Cálculo, referente ao ajuste de período anterior não realizado, em função de não ter Contribuição suficiente para ser reduzido.')
		oAjuDeb:SetAjuBase(.T.)
		oAjuDeb:Ajustar()		
	
		//Realiza Ajuste para a COFINS
		cDescCof	:= "Saldo de Redução de Base de Cálculo de COFINS referênte ao período anterior, proveniente do registro M615."
		oAjuDeb:SetCNPJ(SM0->M0_CGC) 
		oAjuDeb:SetCrdDeb("2")
		oAjuDeb:SetTributo(COFINS)
		oAjuDeb:SetTpAjust(REDUCAO)
		oAjuDeb:SetCodAju('42')
		oAjuDeb:SetDescAju(cDescCof)
		oAjuDeb:SetDtRefer(dDataDe)
		oAjuDeb:SetMsmCod(.F.) // Com este parâmetro com .F. não irá efetuar o ajuste exatamente no mesmo código
		oAjuDeb:SetRegime((cAliasCF3)->CF3_REGIME)
		oAjuDeb:SetOrigem('A')
		oAjuDeb:SetVlAju((cAliasCF3)->CF3_VLRCOF)
		If lConta
			oAjuDeb:SetConta((cAliasCF3)->CF3_CONTA)
		EndIf
		oAjuDeb:SetInfComp('Ajuste de Redução da Base de Cálculo, referente ao ajuste de período anterior não realizado, em função de não ter Contribuição suficiente para ser reduzido.')
		oAjuDeb:SetAjuBase(.T.)
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

EndIF

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
		If lConta
			oAjuCred:SetConta((cAliasCF3)->CF3_CONTA)
		EndIf
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
		If lConta
			oAjuCred:SetConta((cAliasCF3)->CF3_CONTA)
		EndIf
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
Local lCooperat	:= SA1->(FieldPos((SuperGetMv("MV_COOPERA",.F.,""))))>0 
Local cCooperat	:= IIF(lCooperat,SuperGetMv("MV_COOPERA",.F.,""),"")

cSelect :=	"SFT.FT_FILIAL,SFT.FT_TIPOMOV,SFT.FT_NFORI,SFT.FT_SERORI,SFT.FT_ITEMORI,SFT.FT_NFISCAL,SFT.FT_CLIEFOR,"
cSelect +=	"SFT.FT_LOJA,SFT.FT_ITEM,SFT.FT_VALCOF,SFT.FT_VALPIS,SFT.FT_PRODUTO,SFT.FT_QUANT,SFT.FT_BASEPIS,SFT.FT_BASECOF, SFT.FT_ENTRADA,"
cSelect +=	"SFT.FT_CSTPIS,SFT.FT_CSTCOF,SFT.FT_FORMUL,SFT.FT_SERIE,SFT.FT_VALCONT, SFT.FT_ICMSRET, SFT.FT_VALIPI "

If	SFT->(FieldPos("FT_TES"))>0
	cSelect += ",SFT.FT_TES "
Endif

If SFT->(FieldPos('FT_VALCPB')) > 0 .AND. SFT->(FieldPos('FT_ATIVCPB')) > 0
	cSelect += ",SFT.FT_ATIVCPB,SFT.FT_VALCPB,FT_BASECPB,FT_ALIQCPB "
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
  		If cTpMovQry=="E" .And. SA1->(FieldPos("A1_TPREG"))>0
			cSelect	+=	" ,SA1.A1_TPREG"
			cFrom	+=	" LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND "
			cFrom	+=	" SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_=''" 
				cWhere	+=	" AND ((SA1.A1_TPREG='2') OR (SFT.FT_FORMUL='S' AND (SFT.FT_CSTPIS IN ('98','99') OR SFT.FT_CSTCOF IN ('98','99')) )  ) AND SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_=''"
			If lCooperat .And. !Empty(cCooperat)
			 cWhere += " AND SA1."+cCooperat+" <> '1' "
			EndIf
		Elseif SA2->(FieldPos("A2_TPREG"))>0
			cSelect	+=	" ,SA2.A2_TPREG"
			cFrom	+=	" LEFT JOIN "+RetSqlName("SA2")+" SA2 ON SA2.A2_FILIAL='"+xFilial("SA2")+"' AND SA2.A2_COD=SFT.FT_CLIEFOR AND "
			cFrom	+=	" SA2.A2_LOJA=SFT.FT_LOJA AND SA2.D_E_L_E_T_=''" 
			cWhere	+=	" AND SA2.A2_TPREG='1'"
		Endif
	Endif
ElseIf cRegime$"1" .And. cTpMovQry=="E"      			   	
	//Regime Não Cumulativo
	If SF4->(FieldPos("F4_OPERGAR"))>0		   
		cFrom		+=	" LEFT JOIN "+RetSqlName("SD1")+" SD1 ON SD1.D1_FILIAL='"+xFilial("SD1")+"' AND SD1.D1_DOC=SFT.FT_NFISCAL AND SD1.D1_SERIE=SFT.FT_SERIE AND "
		cFrom		+=	" SD1.D1_FORNECE=SFT.FT_CLIEFOR AND SD1.D1_LOJA=SFT.FT_LOJA AND SD1.D1_ITEM=SFT.FT_ITEM AND SD1.D_E_L_E_T_='' "
		cFrom		+=	" LEFT JOIN "+RetSqlName("SF4")+" SF4 ON SF4.F4_FILIAL='"+xFilial("SF4")+"' AND SF4.F4_CODIGO=SD1.D1_TES AND SF4.D_E_L_E_T_='' "
		cFrom		+=	" LEFT JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL='"+xFilial("SA1")+"' AND SA1.A1_COD=SFT.FT_CLIEFOR AND "
		cFrom		+=	" SA1.A1_LOJA=SFT.FT_LOJA AND SA1.D_E_L_E_T_='' " 
			cWhere		+=	" AND (SFT.FT_FORMUL='S' AND SF4.F4_OPERGAR<>'1' ) AND (SFT.FT_CSTPIS IN ('98','99') OR SFT.FT_CSTCOF IN ('98','99')) "
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
/*/{Protheus.doc} QryCL3()
Função que faz query na CL3 para verificar se algum título foi gerado
		
@author Erick G. Dias
@since 09/05/17
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function QryCL3(dData)

Local cAliasCL3	:= "CL3"
Local cSlctCL3	:= ''

cSlctCL3 :='%'
cSlctCL3 += 'CL3.* '
cSlctCL3 +='%'
   	
cAliasCL3	:=	GetNextAlias()
   	
BeginSql Alias cAliasCL3	
	SELECT			    
		%Exp:cSlctCL3%
	FROM 
		%Table:CL3% CL3
	WHERE
		CL3.CL3_FILIAL=%xFilial:CL3% AND		
		CL3.CL3_PER=%Exp:DToS(dData)% and
		CL3.CL3_VALOR > 0 AND
		CL3.CL3_NUMTIT <> ' ' AND
		CL3.%NotDel%	
EndSql

Return cAliasCl3 

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
Local cAliasCL3	:= ''

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

If  CL3->(FieldPos("CL3_NUMTIT"))>0 
	
	cAliasCL3	:= QryCL3(MV_PAR01)
	
	Do While !(cAliasCL3)->(Eof ())
	
		lExistTit	:= .T.
		//Códigos de lançamento padrão para estorno.
		cCodLp := Iif((cAliasCL3)->CL3_TPTIT=='PIS','611','608')
		//Passa informações para a classe poder deletar o título
		//e fazer a contabilização de estorno.
		oTitulo:SetPrefixo((cAliasCL3)->CL3_PRETIT)
		oTitulo:SetNumTit((cAliasCL3)->CL3_NUMTIT)
		oTitulo:SetParcela((cAliasCL3)->CL3_PARTIT)
		oTitulo:SetTipo((cAliasCL3)->CL3_TPTIT)												
		oTitulo:SetFornece((cAliasCL3)->CL3_FORTIT)
		oTitulo:SetLoja((cAliasCL3)->CL3_LOJTIT)
		oTitulo:SetOrigem('FISA001')
		oTitulo:SetContab(lContab)
		oTitulo:SetCodLp(cCodLp)
		If !oTitulo:ChkDelTit()
			cNumTitAux	+= 'Número: '+ (cAliasCL3)->CL3_NUMTIT +' Prefixo: ' +(cAliasCL3)->CL3_PRETIT + ' Tipo: ' + (cAliasCL3)->CL3_TPTIT + CRLF 
			lContinua	:= .F.
		EndIF
	
		(cAliasCL3)->(DbSkip ())
	EndDo
					
	If lContinua
		
		If lAutomato .And. lExistTit
			lProcessa := .T.
		Else
			If lExistTit .AND. ( ApMsgYesNo(cPerg ) )
				lProcessa := .T.
			EndIf
		EndIf
		
		If lProcessa
			
			(cAliasCL3)->(DBGOTOP ())
			Do While !(cAliasCL3)->(Eof ())
				//Verificar antes se existe algum título já baixado. Caso existir, então
				//exibir para o cliente os títulos que já possuem baixa no Financeiro, e não 
				//permitir que prossiga com apuração.	
				
				//Códigos de lançamento padrão para estorno.
				cCodLp := ''				
				if alltrim( (cAliasCL3)->CL3_TPTIT ) =='PIS'
					cCodLp := '611'
				elseif alltrim( (cAliasCL3)->CL3_TPTIT ) =='COF'
					cCodLp := '608'
				elseif alltrim( (cAliasCL3)->CL3_TPTIT ) == 'CPR'
					cCodLp := '766'
				endif

				//Passa informações para a classe poder deletar o título
				//e fazer a contabilização de estorno.
				oTitulo:SetPrefixo((cAliasCL3)->CL3_PRETIT)
				oTitulo:SetNumTit((cAliasCL3)->CL3_NUMTIT)
				oTitulo:SetParcela((cAliasCL3)->CL3_PARTIT)
				oTitulo:SetTipo((cAliasCL3)->CL3_TPTIT)												
				oTitulo:SetFornece((cAliasCL3)->CL3_FORTIT)
				oTitulo:SetLoja((cAliasCL3)->CL3_LOJTIT)
				oTitulo:SetOrigem('FISA001')
				oTitulo:SetContab(lContab)
				oTitulo:SetCodLp(cCodLp)	
				oTitulo:SetExibCtb(.t.) 	
				oTitulo:DelTitulo()
				lDeletou	:= .T.	
			
				(cAliasCL3)->(DbSkip ())
			EndDo								
			
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
	DbSelectArea (cAliasCL3)
	(cAliasCL3)->(DbCloseArea())
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
If AliasINdic('F3G')
	AADD(aRet,{'F3G',xFilial('F3G')})
EndIF

If AliasINdic('F2Z')
	AADD(aRet,{'F2Z',xFilial('F2Z')})
EndIF

If AliasINdic('F3P')
	AADD(aRet,{'F3P',xFilial('F3P')})
EndIF

If AliasINdic('F3O')
	AADD(aRet,{'F3O',xFilial('F3O')})
EndIF

If AliasINdic('F3J')
	AADD(aRet,{'F3J',xFilial('F3J')})
EndIF

If AliasINdic('CIC')
	AADD(aRet,{'CIC',xFilial('CIC')})
EndIF

If ISA001NDIF()
	AADD(aRet,{'CFA',xFilial('CFA')})
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
Local cCKRLiv := ""
Local dDtIni  := IIf( CKR->(FieldPos('CKR_DTINI')) > 0, CKR->CKR_DTINI, CtoD(''))//IIf( CKR->(FieldPos('CKR_DTINI')) > 0, CKR->CKR_DTINI, CtoD(''))	
Local dDtFim  := IIf( CKR->(FieldPos('CKR_DTFIM')) > 0, CKR->CKR_DTFIM, CtoD(''))//IIf( CKR->(FieldPos('CKR_DTFIM')) > 0, LASTDAY(CKR->CKR_PER), CtoD(''))

If CKR->(Fieldpos("CKR_LIVRO")) > 0
	cCKRLiv:= CKR->CKR_LIVRO
Endif

	//Chama rotina de relatório
	FISR101(CKR->CKR_PER,alltrim(str(CKR->CKR_REGIME)),cCKRLiv, dDtINi, dDtFim )

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
Local aParSX1
Local aXFilial

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
	
			aParSX1 := {MV_PAR01}
			axFilial:= ASA001AFIL()

			oApurSai := FISX001():New()
			oApurSai:SetFilial(axFilial)
			oApurSai:SetFilApu(FWGETCODFILIAL)
			oApurSai:SetDtIni(MV_PAR01)
			oApurSai:SetDtFin(MV_PAR02)	
			Processa({|lEnd| IniCred(aParSX1,axFilial, ,lConsolid),;
								IniDeducao(aParSX1,aXFilial),;
								IniRetenca(aParSX1,aXFilial),;
								 oApurSai:ClearTab(ALIASREPRO(Iif(lConsolid,'3' ,'2' )),lConsolid) },"Excluindo Apuração",,,.T.)		
				
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
	Alert('Apuração já gravou título ou já realizou contabilização ou foi considerada em uma consolidação, não poderá ser excluída!')

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

aXFilial:= ASA001AFIL()

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
		SM0->(MsSeek(aSM0[nFil][1]+aSM0[nFil][2], .T.))	//Pego a filial mais proxima
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
AADD(aTab,{'F2Z','F2Z.F2Z_FILIAL','F2Z.F2Z_PERAPU','F2Z.F2Z_CONSOL'		,STR0094,.T.})//'F2Z Ajuste de redução de PIS e COFINS'

IF ISA001NDIF()
	AADD(aTab,{'CFA','CFA.CFA_FILIAL','CFA.CFA_PERAPU','CFA.CFA_CONSOL'			,'Diferimento do Período',.F.}) //'Diferimento do Período'
	AADD(aTab,{'CFB','CFB.CFB_FILIAL','CFB.CFB_PERAPU','CFB.CFB_CONSOL'			,'Diferimento de Período Anterior',.F.}) //'Diferimento de Período Anterior'
EndIF
If AliasIndic("CIC")
	AADD(aTab,{'CIC','CIC.CIC_FILIAL','CIC.CIC_PER','CIC.CIC_CONSOL'			,"Totais de Receitas",.F.}) //"Totais de Receitas"
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
				
			Case aTab[nContTab][1] == 'CKT'
				ConsCKT(cAliasRet,aXFilial)

			Case aTab[nContTab][1] == 'CIC'
				ConsCIC(cAliasRet,aXFilial)

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
				
			Case aTab[nContTab][1] == 'F2Z'
				ConsF2Z(cAliasRet,aXFilial)														
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
Local lLivro	:= .F.
Local dtAux		:= CTod("  /  /    ")

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.


oTabCKR:setIndice(1)
oTabCKR:setAlias('CKR')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CKR')
TcSetField(cAlias,"CKR_PER","D",8,0)

If CKR->(Fieldpos("CKR_LIVRO")) > 0
	lLivro := .T.
Endif

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
		If lLivro
			oTabCKR:SetCampo('CKR_LIVRO'    ,(cAlias)->CKR_LIVRO)
		Endif
		oTabCKR:SetCampo('CKR_DTFIM' ,mv_par02)
	
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
	oTabCLA:SetCampo('CLA_FILIAL'		,cFilMatriz)	
	oTabCLA:SetCampo('CLA_CHV'			,cChv)
	oTabCLA:SetCampo('CLA_ID'			,(cAlias)->CLA_ID)
	oTabCLA:SetCampo('CLA_TPAJU'		,(cAlias)->CLA_TPAJU)
	oTabCLA:SetCampo('CLA_VLAJU'		,(cAlias)->CLA_VLAJU,lAcumula)			
	oTabCLA:SetCampo('CLA_COD'			,(cAlias)->CLA_COD)	
	oTabCLA:SetCampo('CLA_NUM'			,(cAlias)->CLA_NUM)
	oTabCLA:SetCampo('CLA_DESCR'		,(cAlias)->CLA_DESCR)
	oTabCLA:SetCampo('CLA_DTREF'		,dtAux)
	oTabCLA:SetCampo('CLA_CTA'			,(cAlias)->CLA_CTA)
	oTabCLA:SetCampo('CLA_PERUTI'		,(cAlias)->CLA_PERUTI)
	If CLA->(FieldPos("CLA_FILORI"))>0
		oTabCLA:SetCampo('CLA_FILORI'	,(cAlias)->CLA_FILORI)
	EndIf
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
Local lCmpAjuBas := CKS->(FieldPos("CKS_BCAJUS"))>0 

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

	If lCmpAjuBas
		oTabCKS:SetCampo('CKS_AJBCA'	,(cAlias)->CKS_AJBCA,lAcumula)
		oTabCKS:SetCampo('CKS_AJBCR'	,(cAlias)->CKS_AJBCR,lAcumula)
		oTabCKS:SetCampo('CKS_BCAJUS'	,(cAlias)->CKS_BCAJUS,lAcumula)
	EndIf

	oTabCKS:SetCampo('CKS_VLTRIB' 		,(cAlias)->CKS_VLTRIB,lAcumula)
	oTabCKS:SetCampo('CKS_AJAC' 		,(cAlias)->CKS_AJAC,lAcumula)
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

Static Function ConsCIC(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCIC	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cConsol		:= '1'
Local cFilMatriz	:= ''
Local dtAux		:= CTod("  /  /    ")

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.

oTabCIC:setIndice(1)
oTabCIC:setAlias('CIC')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CIC')
TcSetField(cAlias,"CIC_PER","D",8,0)

Do While !(cAlias)->(Eof ())
	
	dtAux		:= (cAlias)->CIC_PER
	If lAgrupaT	
		dtAux	:= dtNewPer	
		cConsol		:= '2'	
	EndIF


	cChave:= cFilMatriz+DTOS(dtAux)+cConsol+(cAlias)->CIC_BLOCO
	oTabCIC:setChave(cChave)

	oTabCIC:Inclui()	
	
	//Somente passa campos de valores a serem acumulados
	oTabCIC:SetCampo('CIC_FILIAL'	,cFilMatriz)
	oTabCIC:SetCampo('CIC_PER'		,dtAux)
	oTabCIC:SetCampo('CIC_CONSOL' 	,cConsol)
	oTabCIC:SetCampo('CIC_BLOCO'	,(cAlias)->CIC_BLOCO)
	oTabCIC:SetCampo('CIC_REC'		,(cAlias)->CIC_REC,lAcumula)
	oTabCIC:SetCampo('CIC_RECNB'   	,(cAlias)->CIC_RECNB,lAcumula)


	oTabCIC:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabCIC )
oTabCIC:= Nil

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

Static Function ConsCKV(cAlias,aXFilial,cFilialMat,lIndividu,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCKV	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cConsol		:= '1'
Local cFilMatriz	:= ''
Local dtAux			:= CTod("  /  /    ")
Local lFilApu		:= CKV->(FieldPos('CKV_FILAPU')) > 0

DEFAULT lAgrupaT := .F.
DEFAULT dtNewPer := CTod("  /  /    ")
DEFAULT cFilialMat := ""
DEFAULT lIndividu := .F.

oTabCKV:setIndice(1)
oTabCKV:setAlias('CKV')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CKV')
TcSetField(cAlias,"CKV_PER","D",8,0)

Do While !(cAlias)->(Eof ())
	
	
	dtAux	:= (cAlias)->CKV_PER
	
	If lAgrupaT		
		dtAux	:= dtNewPer
		cConsol	:= '2'			
	EndIF	
	
	cChave:= cFilMatriz+DTOS(dtAux)+(cAlias)->CKV_COD+cConsol
	oTabCKV:setChave(cChave)

	oTabCKV:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCKV:SetCampo('CKV_FILIAL'	 	,cFilMatriz)	
	oTabCKV:SetCampo('CKV_PER'			,dtAux)
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
	If lFilApu
		oTabCKV:SetCampo('CKV_FILAPU'   	,IIf(lIndividu,oEFDGen:BuscaxFil('CKV'),cFilialMat)) 
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
Static Function ConsCKX(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabCKX	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cFilMatriz	:= ''
Local dtAux		:= CTod("  /  /    ")
Local lNTrib 	:= CKX->(FieldPos('CKX_NTRIB'))>0 

DEFAULT lAgrupaT := .F.
DEFAULT dtNewPer := CTod("  /  /    ")

oTabCKX:setIndice(1)
oTabCKX:setAlias('CKX')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('CKX')
TcSetField(cAlias,"CKX_PER","D",8,0)

Do While !(cAlias)->(Eof ())

	dtAux	:= (cAlias)->CKX_PER
	
	If lAgrupaT		
		dtAux	:= dtNewPer		
	EndIF	

	cChave:= cFilMatriz+DTOS(dtAux)+(cAlias)->CKX_CODATI+(cAlias)->CKX_CODREC+STR((cAlias)->CKX_ALIQ,8,4)
	oTabCKX:setChave(cChave)

	oTabCKX:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabCKX:SetCampo('CKX_FILIAL'	 	,cFilMatriz)	
	oTabCKX:SetCampo('CKX_PER'			,dtAux)
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
	
	If lNTrib
		oTabCKX:SetCampo('CKX_NTRIB'   	,(cAlias)->CKX_NTRIB)
	Endif

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

//-------------------------------------------------------------------
/*/{Protheus.doc} ConsF3J()

@Description Função que realiza a consolidação da tabela F3J quando processada
por multithread
@author Erick G. Dias
@since 09/05/17
@version 11.80
/*/
//-------------------------------------------------------------------
Static Function ConsF3J(cAlias,aXFilial,lAgrupaT,dtNewPer)

Local cChave	:=''
Local oTabF3J	:= TABELAEFD():New()
Local oEFDGen	:= EFDGEN():New()
Local lAcumula	:= .T.
Local cFilMatriz	:= ''
Local cConsol		:= '1'
Local dtAux		:= CTod("  /  /    ")

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.

TcSetField(cAlias,"F3J_PER","D",8,0)

oTabF3J:setIndice(1)
oTabF3J:setAlias('F3J')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('F3J')

Do While !(cAlias)->(Eof ())
	
	dtAux		:= (cAlias)->F3J_PER
	If lAgrupaT		
		dtAux	:= dtNewPer
		cConsol		:= '2'		
	EndIF	

	cChave:= cFilMatriz+DTOS(dtAux)+(cAlias)->F3J_CODREC+cConsol

	oTabF3J:setChave(cChave)

	oTabF3J:Inclui()	

	//Somente passa campos de valores a serem acumulados
	oTabF3J:SetCampo('F3J_FILIAL'	 	,cFilMatriz)	
	oTabF3J:SetCampo('F3J_PER'			,dtAux)
	oTabF3J:SetCampo('F3J_CODREC' 		,(cAlias)->F3J_CODREC)
	oTabF3J:SetCampo('F3J_VLTRIB'		,(cAlias)->F3J_VLTRIB,lAcumula)
	oTabF3J:SetCampo('F3J_CONSOL'		,cConsol)			
		

	oTabF3J:Finaliza()

	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabF3J )
oTabF3J:= Nil

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

//Função inibida pois ao chamar a LimpaSaldo quando se esta agrupando filiais a Matriz, no momento que eu vou processar a 2º filial do array aSM0 ele deleta o registro da 1º filial  
//fazendo com que os valores não sejam aglutinados.
//oSaldoCred:LimpaSaldo() //Limpa tabela de saldos somente do período  

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
	oTabCCY:SetCampo('CCY_RESCRE'	 	,IIf(CCY->(FieldPos('CCY_RESCRE'))>0,(cAlias)->CCY_RESCRE,"2"))

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

//Função inibida pois ao chamar a LimpaSaldo quando se esta agrupando filiais a Matriz, no momento que eu vou processar a 2º filial do array aSM0 ele deleta o registro da 1º filial  
//fazendo com que os valores não sejam aglutinados.se
//oSaldoCred:LimpaSaldo() //Limpa tabela de saldos somente do período

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
	oTabCCW:SetCampo('CCW_RESCRE'	 	,IIf(CCW->(Fieldpos('CCW_RESCRE'))>0,(cAlias)->CCW_RESCRE,"2"))	

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
Local lFV_RESSA		:=	SFV->( FieldPos( "FV_RESSA"  ) ) > 0
Local lFV_COMP		:=	SFV->( FieldPos( "FV_COMP"   ) ) > 0
Local lFV_RESRET	:=	SFV->( FieldPos( "FV_RESRET" ) ) > 0

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

	If lFV_RESSA .And. lFV_COMP .And. lFV_RESRET
		oTabSFV:SetCampo('FV_RESSA'		,(cAlias)->FV_RESSA,lAcumula)
		oTabSFV:SetCampo('FV_COMP'		,(cAlias)->FV_COMP,lAcumula)
		oTabSFV:SetCampo('FV_RESRET'	,(cAlias)->FV_RESRET)
	EndIf

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
Local lFW_RESSA		:=	SFW->( FieldPos( "FW_RESSA"  ) ) > 0
Local lFW_COMP		:=	SFW->( FieldPos( "FW_COMP"   ) ) > 0
Local lFW_RESRET	:=	SFW->( FieldPos( "FW_RESRET" ) ) > 0

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

	If lFW_RESSA .And. lFW_COMP .And. lFW_RESRET
		oTabSFW:SetCampo('FW_RESSA'		,(cAlias)->FW_RESSA,lAcumula)
		oTabSFW:SetCampo('FW_COMP'		,(cAlias)->FW_COMP,lAcumula)
		oTabSFW:SetCampo('FW_RESRET'	,(cAlias)->FW_RESRET)
	EndIf

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

Static Function ConsF2Z(cAlias,aXFilial,cFilialMat,lIndividu,lAgrupaT,dtNewPer)

Local cChave     := ''
Local lAcumula   := .T.
Local cFilMatriz := ''
Local cConsol    := '1'
Local oTabF2Z    := TABELAEFD():New()
Local oEFDGen    := EFDGEN()   :New()
Local dtAux      := CtoD("  /  /    ")

DEFAULT dtNewPer	:= CTod("  /  /    ")
DEFAULT lAgrupaT	:= .F.

oTabF2Z:setIndice(1) // F2Z_FILIAL+DTOS(F2Z_PERAPU)+F2Z_TRIB+F2Z_INDAJU+F2Z_CHV+F2Z_ID
oTabF2Z:setAlias('F2Z')
oEFDGen:SetFilial(aXFilial) 
cFilMatriz := oEFDGen:BuscaxFil('F2Z')
TcSetField(cAlias,"F2Z_DTREF","D",8,0)
TcSetField(cAlias,"F2Z_PERAPU","D",8,0)

Do While !(cAlias)->(Eof ())
	
	IF (cAlias)->F2Z_ORIG == '2' //Indica a origem automática do sistema/apuração		
		
		If Empty(dtNewPer) 
			dtNewPer := (cAlias)->F2Z_PERAPU
		EndIf
		cID			:= DTOS(dtNewPer)+ SubStr((cAlias)->F2Z_ID,9)
		cChv		:= (cAlias)->F2Z_CHV
		dtAux		:= (cAlias)->F2Z_DTREF

		If lAgrupaT	
			cID		:= DTOS(dtNewPer)+ SubStr((cAlias)->F2Z_ID,9)
			cChv	:= DTOS(dtNewPer)+ SubStr((cAlias)->F2Z_CHV,9)
			dtAux	:= dtNewPer
			cConsol	:= '2'		
		EndIF	
         
		cChave:= cFilMatriz+dTos(dtAux)+(cAlias)->F2Z_TRIB+(cAlias)->F2Z_INDAJU
		
		F2Z->(DbSetOrder(1) ) //F2Z_FILIAL+DTOS(F2Z_PERAPU)+F2Z_TRIB+F2Z_INDAJU+F2Z_CHV+F2Z_ID
		//se ja existir não gravo novamente para não duplicar o registro M215 e M615
		If !F2Z->(DbSeek(cFilMatriz + DTOS((cAlias)->F2Z_PERAPU)+(cAlias)->F2Z_TRIB+(cAlias)->F2Z_INDAJU+(cAlias)->F2Z_CHV )) .OR. cFilMatriz <> (cAlias)->F2Z_FILIAL
			
			If (cAlias)->F2Z_CODAJU <> F2Z->F2Z_CODAJU 
				cChave := cChv  // Se for codigo de ajuste e tiver a mesma chave não deve somar
			EndIf		
			oTabF2Z:setChave(cChave)

			oTabF2Z:Inclui()	

			//Somente passa campos de valores a serem acumulados
			oTabF2Z:SetCampo('F2Z_FILIAL'	, cFilMatriz)
			oTabF2Z:SetCampo('F2Z_CHV'		, cChv)
			oTabF2Z:SetCampo('F2Z_ID'		, cID)
			oTabF2Z:SetCampo('F2Z_INDAJU'	, (cAlias)->F2Z_INDAJU)		
			oTabF2Z:SetCampo('F2Z_VALAJU'	, (cAlias)->F2Z_VALAJU, lAcumula)
			oTabF2Z:SetCampo('F2Z_CODAJU'	, (cAlias)->F2Z_CODAJU)		
			oTabF2Z:SetCampo('F2Z_NUM'		, (cAlias)->F2Z_NUM)		
			oTabF2Z:SetCampo('F2Z_DESCR'	, (cAlias)->F2Z_DESCR)		
			oTabF2Z:SetCampo('F2Z_DTREF'	, dtAux)		
			oTabF2Z:SetCampo('F2Z_PERAPU'	, (cAlias)->F2Z_PERAPU)		
			oTabF2Z:SetCampo('F2Z_CONTA'	, (cAlias)->F2Z_CONTA)		
			oTabF2Z:SetCampo('F2Z_CNPJ'		, (cAlias)->F2Z_CNPJ)		
			oTabF2Z:SetCampo('F2Z_COMPL'	, (cAlias)->F2Z_COMPL)		
			oTabF2Z:SetCampo('F2Z_TRIB'		, (cAlias)->F2Z_TRIB)		
			oTabF2Z:SetCampo('F2Z_CODCON'	, (cAlias)->F2Z_CODCON)		
			oTabF2Z:SetCampo('F2Z_ORIG'		, '2')		
			oTabF2Z:SetCampo('F2Z_CONSOL'	, cConsol)
			
			oTabF2Z:Finaliza()

		EndIf	
			
	Endif
	(cAlias)->(DbSkip ())			
EndDo

FreeObj( oTabF2Z )
oTabF2Z:= Nil

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

Local aAreaSM0 	:= SM0->(GetArea())
Local aRegPE210 	:= {}
Local nP210	   	:= 0	
Local oCPRB		:= CPRBEFD():New()

If ExistBlock('SPEDCP210')
	aRegPE210 := ExecBlock("SPEDCP210", .F., .F.,{ dDataDe, dDataAte, aSm0,mv_par16  ,mv_par17 }  )
ElseIf CF5->(FieldPos('CF5_TIPATV')) > 0	
	aRegPE210 := FSA001CPRB(dDataDe,dDataAte)
Endif	

RestArea (aAreaSM0)

For nP210 := 1 to Len(aRegPE210)
	oCPRB:SetConsol('2')
	oCPRB:SetDtIni(MV_PAR01)
	oCPRB:SetCodRec(aRegPE210[nP210][7])
	oCPRB:SetTpAju(Iif(aRegPE210[nP210][1] == '0',REDUCAO ,ACRESCIMO ))
	oCPRB:SetValAju(aRegPE210[nP210][2])
	oCPRB:SetCodAjus(aRegPE210[nP210][3])
	oCPRB:SetNumero(aRegPE210[nP210][4])
	oCPRB:SetDescr(aRegPE210[nP210][5])		
	oCPRB:SetDtRefer(ctod(substr(aRegPE210[nP210][6],1,2) +'/'+ substr(aRegPE210[nP210][6],3,2) +'/'+ substr(aRegPE210[nP210][6],5,4)))		
	oCPRB:SetFilApu(IIf(lIndividu,oCPRB:BuscaxFil('CKR'),cFilialMat))  
	oCPRB:GravaAju()
	oCPRB:AtualizaCPRB()
	oCPRB:Clear()
Next nP210


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
oEFDGen:SetFilApu(FWGETCODFILIAL)

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

Static Function ISA001F3Z(dDataDe,dDataAte,aSM0)

Local cAliasF3Z		:= ''
Local cCampos		:= ''
Local cFiltro		:= ''
Local cIn			:= ''
Local x				:= 0

DEFAULT aSM0		:= {} 

For x:=1 to Len(aSM0)

	cIn += "'"+SubStr(aSM0[x][2], 1, TamSX3("F3Z_FILIAL")[1])+"'"
	
	If x != Len(aSM0)
		cIn += ', '
	EndIf
Next

cIn := '('+cIn+')'

cCampos := '%F3Z.R_E_C_N_O_ as NRECNO%'
cFiltro := "%"
cFiltro += "F3Z.F3Z_FILIAL= '"+ xFilial("F3Z") + "' AND "
cFiltro += "F3Z.F3Z_PER>= '" + %Exp:DToS (dDataDe)% + "' AND "
cFiltro += "F3Z.F3Z_PER<= '" + %Exp:DToS (dDataAte)% + "' AND "
cFiltro += "F3Z.F3Z_FILAPU IN "+cIn+" AND "
cFiltro += "%"

cAliasF3Z	:=	GetNextAlias()

BeginSql Alias cAliasF3Z
    	
	SELECT
	%Exp:cCampos%

	FROM
	%Table:F3Z% F3Z	
	WHERE
	%Exp:cFiltro%
	F3Z.%NotDel%

EndSql

Do While !(cAliasF3Z)->(EOF())
	F3Z->(dbGoto((cAliasF3Z)->NRECNO))		
	RecLock("F3Z",.F.)
	F3Z->(dbDelete())
	MsUnLock()
	F3Z->(FKCommit())
	(cAliasF3Z)->(DBSKIP())
EndDo		


DbSelectArea (cAliasF3Z)
(cAliasF3Z)->(DbCloseArea ())

Return

Static Function ISA001CL2(dDataDe,dDataAte,cOrigem,cConsl,cReg,oEFDGen) 

Local cAliasCL2	:= ''
Local cCampos		:= ''
Local cFiltro		:= ''

cCampos	:= '%CL2.R_E_C_N_O_ as NRECNO%'

cFiltro := "%"
cFiltro += "CL2.CL2_FILAPU = '"+  xFilial("CL2")+ "' AND " //cFiltro += "CL2.CL2_FILIAL = '"+ oEFDGen:BuscaxFil('CL2')+ "' AND " , Nesse momento sempre vou recuperar a FILIAL que estou posicionado com isso preciso selecionar somente a FILAPU da selecionada e deletar para gerar novamente.
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
	If AliasINdic('F3J')
		AAdd(aAlias,{'F3J',.T. })//apaga
	EndIF			
	IF ISA001NDIF()
		AAdd(aAlias,{'CFA',.T.    })//apaga
		AAdd(aAlias,{'CFB',.T.    })//apaga
	EndIf
	If AliasINdic('F2Z')
		AAdd(aAlias,{'F2Z',.T. })//apaga
	EndIF
	If AliasINdic('F3P')
		AAdd(aAlias,{'F3P',.T. })//apaga
	EndIF
	If AliasINdic('F3O')
		AAdd(aAlias,{'F3O',.T. })//apaga
	EndIF
	If AliasINdic('F2S')
		AAdd(aAlias,{'F2S',.T. })//apaga
	EndIF
	If AliasINdic('CIE')
		AAdd(aAlias,{'CIE',.T. })//apaga
	EndIF	
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
	If AliasINdic('CIC')
		AAdd(aAlias,{'CIC',.T. })//apaga
	EndIF	
	AAdd(aAlias,{'CL2',.T.})//reprocessa
	AAdd(aAlias,{'CL3',.T. })//apaga        c
	AAdd(aAlias,{'CL4',.T.})//reprocessa
	AAdd(aAlias,{'CL5',.T. })//apaga	
	AAdd(aAlias,{'CL6',.T. })//apaga
	AAdd(aAlias,{'CL7',.T. })//apaga
	AAdd(aAlias,{'CKY',.T. })//apaga
	If AliasINdic('F3J')
		AAdd(aAlias,{'F3J',.T. })//apaga
	EndIF

	If AliasINdic('F2Z')
		AAdd(aAlias,{'F2Z',.T. })//apaga
	EndIF
	
	If AliasINdic('F3P')
		AAdd(aAlias,{'F3P',.T. })//apaga
	EndIF	
	If AliasINdic('F3O')
		AAdd(aAlias,{'F3O',.T. })//apaga
	EndIF		

	IF ISA001NDIF()
		AAdd(aAlias,{'CFA',.T.    })//apaga
		AAdd(aAlias,{'CFB',.T.    })//apaga
	EndIF
	If AliasINdic('F2S')
		AAdd(aAlias,{'F2S',.T. })//apaga
	EndIF
	If AliasINdic('CIE')
		AAdd(aAlias,{'CIE',.T. })//apaga
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
	If AliasINdic('F3J')
		AAdd(aAlias,{'F3J',.T. })//apaga
	EndIF
	If AliasINdic('CIC')
		AAdd(aAlias,{'CIC',.T. })//apaga
	EndIF	
	If AliasINdic('F2Z')
		AAdd(aAlias,{'F2Z',.T. })//apaga
	EndIF	
	If AliasINdic('F3P')
		AAdd(aAlias,{'F3P',.T. })//apaga
	EndIF		
	If AliasINdic('F3O')
		AAdd(aAlias,{'F3O',.T. })//apaga
	EndIF			
	IF ISA001NDIF()
		AAdd(aAlias,{'CFA',.T.    })//apaga
		AAdd(aAlias,{'CFB',.T.    })//apaga
	EndiF	
	If AliasINdic('F2S')
		AAdd(aAlias,{'F2S',.T. })//apaga
	EndIF
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
	ProcLogAtu("ERRO",oError:Description +"- Filial " + FWGETCODFILIAL + " " + Time(),oError:ErrorStack,cNomeJob)	
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
aAdd(aRet,MV_PAR19)
aAdd(aRet,MV_PAR20)
aAdd(aRet,MV_PAR21)
aAdd(aRet,MV_PAR22)
aAdd(aRet,MV_PAR23)
aAdd(aRet,MV_PAR24)

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
Static Function GetFilial(lAutomato, aAutoFil)

Local aFil	:= {}
Local aSM0	:= {}
Local aAreaSM0	:= {}
Local nFil	:= 0

If MV_PAR04 == 1
	If lAutomato
		aFil:= MatFilCalc( .F., aAutoFil )
	Else
		//chama função para usuário escolher filial
		aFil:= MatFilCalc( .T. )
		If len(aFil) ==0
				MsgAlert('Nenhuma filial foi selecionada, o processamento não será realizado.')
		EndiF
	EndIf	
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
cFiltro		:= aQry[1][3]

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
	Case ctab = "CIC"		
		ConsCIC(cAlias,aXFilial,.T.,dtGrava)							
	Case ctab == 'CL0'
		ConsCL0(cAlias,aXFilial,.T.,dtGrava)		
	Case ctab == 'CL3'
		ConsCL3(cAlias,aXFilial,.T.,dtGrava)		
	Case ctab == 'F3J'
		ConsF3J(cAlias,aXFilial,.T.,dtGrava)
	Case ctab == 'CKX'
		ConsCKX(cAlias,aXFilial,.T.,dtGrava)
	Case ctab == 'CKV'
		ConsCKV(cAlias,aXFilial,,.F.,.T.,dtGrava)
	Case ctab == 'F2Z'
		ConsF2Z(cAlias,aXFilial,,.F.,.T.,dtGrava)		
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

	Case cAlias == 'CIC'
	
		cSlct	 := "%CIC.*%"	
		cFrom	   := '%'+ RetSqlName('CIC')+' CIC %
		cFiltro += "%CIC.CIC_FILIAL= '"+ oEFDGen:BuscaxFil('CIC') + "' AND "
		cFiltro += "CIC.CIC_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CIC.CIC_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "CIC.CIC_CONSOL = '" +cConsl + "' AND "
		cFiltro += "CIC.D_E_L_E_T_=' ' "	
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
	
	Case cAlias == 'F3J'	
		cSlct	 := "%F3J.*%"	
		cFrom	   := '%'+ RetSqlName('F3J')+' F3J %
		cFiltro += "%F3J.F3J_FILIAL= '"+ oEFDGen:BuscaxFil('F3J') + "' AND "
		cFiltro += "F3J.F3J_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "F3J.F3J_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "F3J.F3J_CONSOL = '" +cConsl + "' AND "
		cFiltro += "F3J.D_E_L_E_T_=' ' "	
		cFiltro += "%"
	Case cAlias == 'CKV'	
		cSlct	 := "%CKV.*%"	
		cFrom	   := '%'+ RetSqlName('CKV')+' CKV %
		cFiltro += "%CKV.CKV_FILIAL= '"+ oEFDGen:BuscaxFil('CKV') + "' AND "
		cFiltro += "CKV.CKV_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CKV.CKV_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "
		cFiltro += "CKV.CKV_CONSOL = '" +cConsl + "' AND "
		cFiltro += "CKV.D_E_L_E_T_=' ' "	
		cFiltro += "%"
	Case cAlias == 'CKX'	
		cSlct	 := "%CKX.*%"	
		cFrom	   := '%'+ RetSqlName('CKX')+' CKX %
		cFiltro += "%CKX.CKX_FILIAL= '"+ oEFDGen:BuscaxFil('CKX') + "' AND "
		cFiltro += "CKX.CKX_PER>= '" + %Exp:DToS (dDtIni)% + "' AND "
		cFiltro += "CKX.CKX_PER<= '" + %Exp:DToS (dDtFin)% + "' AND "		
		cFiltro += "CKX.D_E_L_E_T_=' ' "	
		cFiltro += "%"	
	Case cAlias == 'F2Z'

		cSlct	:= "%F2Z.*%"	
		cFrom	:= '%'+ RetSqlName('F2Z')+' F2Z %'
		cFiltro	+= "%F2Z.F2Z_FILIAL='"+oEFDGen:BuscaxFil('F2Z')+"' AND "
		cFiltro	+= "F2Z.F2Z_DTREF>='"+%Exp:DToS (dDtIni)%+"' AND "
		cFiltro	+= "F2Z.F2Z_DTREF<='"+%Exp:DToS (dDtFin)%+"' AND "
		cFiltro += "F2Z.F2Z_CONSOL = '" +cConsl + "' AND "
		cFiltro	+= "F2Z.F2Z_ORIG ='2' AND "
		cFiltro += "F2Z.D_E_L_E_T_ = ' '"
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
Static Function IniCred(aParSX1,aXFilial,cFilialMat,lConsolid)

local oSaldoCred
DEFAULT lConsolid := .F.

oSaldoCred:= SALDOCRED():New()
oSaldoCred:SetFilial(aXFilial)
oSaldoCred:SetFilApu(cFilialMat)
If lConsolid 
	oSaldoCred:SetConsol('1') //Quando se tratar de uma apuração agrupadora será setado o CONSOL = 1 para que seja apagado o registro correto na CCW e CCY
Endif
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
Static Function IniDeducao(aParSX1,aXFilial,cFilialMat)

Local dUltDia		:= LastDay (aParSX1[1]) + 1
Local cProxPer	:=	cvaltochar(strzero(month(dUltDia ) ,2)) + cvaltochar(year(dUltDia ))
Local oSaldoDed
oSaldoDed	:= 	SALDODED():New()
oSaldoDed:SetFilial(aXFilial)
oSaldoDed:SetFilApu(cFilialMat)
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
Static Function IniRetenca(aParSX1,aXFilial,cFilialMat)

oOutRet := DEDUCAOPC():New() 
oOutRet:SetFilial(aXFilial)
oOutRet:SetFilApu(cFilialMat)
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
	oApurSai:ClearTab(TabAux())//BRUCE
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
	AAdd(aAlias,{'CKS',.T.})
	If AliasIndic('F2S')
		AAdd(aAlias,{'F2S',.T.}) 	
	EndIf
	If AliasINdic('F2Z')
		AAdd(aAlias,{'F2Z',.T. })
	EndIF	
	If AliasINdic('F3P')
		AAdd(aAlias,{'F3P',.T. })
	EndIF		
	If AliasINdic('F3O')
		AAdd(aAlias,{'F3O',.T. })
	EndIF		

	IF ISA001NDIF()
		AAdd(aAlias,{'CFA',.T.})
		AAdd(aAlias,{'CFB',.T.})
	EndIF
	If AliasINdic('CIC')
		AAdd(aAlias,{'CIC',.T. })
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
	If AliasINdic('F2Z')
		AAdd(aAlias,{'F2Z',.T. })
	EndIF	
	If AliasINdic('F3P')
		AAdd(aAlias,{'F3P',.T. })
	EndIF		
	If AliasINdic('F3O')
		AAdd(aAlias,{'F3O',.T. })
	EndIF
	If AliasINdic('CIC')
		AAdd(aAlias,{'CIC',.T. })
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

Static Function TabAux(lExcFil)

Local aAlias	:= {}
Default lExcFil	:= .F.

If AliasINdic('F07')
	AAdd(aAlias,{'F07',.T.})
EndIF
If AliasINdic('F0T')
	AAdd(aAlias,{'F0T',.T. })//apaga
EndIF	
AAdd(aAlias,{'CL1',.T.})

If !lExcFil .AND. CL2->(FieldPos('CL2_FILAPU'))>0 // se lExcFil == F ele deleta a CL2 //BRUCE
	//Na exclusão das informações por filial, a CL2 não será adicionada, já que a exclusão ocorrerá de uma vez devio ao campo CL2_FILAPU.
	AAdd(aAlias,{'CL2',.T.})
EndIF

AAdd(aAlias,{'CL3',.T.})
AAdd(aAlias,{'CL5',.T.})
AAdd(aAlias,{'CL6',.T.})
AAdd(aAlias,{'CL7',.T.})
AAdd(aAlias,{'CKY',.T.})
If !lExcFil .AND. CKX->(FieldPos('CKX_FILAPU'))>0
	//Na exclusão das informações por filial, a CKX não será adicionada, já que a exclusão ocorrerá de uma vez devio ao campo CKX_FILAPU.
	AAdd(aAlias,{'CKX',.T.})
EndIF

If AliasINdic('F3J')
	AAdd(aAlias,{'F3J',.T.})
EndIF
If ISA001NDIF()
	AAdd(aAlias,{'CFA',.T.    })//apaga
	AAdd(aAlias,{'CFB',.T.    })//apaga
EndIF
If AliasINdic('F2S')
	AAdd(aAlias,{'F2S',.T. })//apaga
EndIF
If AliasINdic('CIE')
	AAdd(aAlias,{'CIE',.T. })//apaga
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
If AliasIndic('F2S')
	aadd(aAlias,{'F2S',.T.})
EndIf
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

If AliasINdic('CLG') .AND.  CLG->(FieldPos("CLG_NATRET"))>0
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
		If CKY->(FIELDPOS("CKY_FILAPU")) > 0
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
Local cAliasCF5		:= ''
Local cSelect		:= ''
Local cWhere		:= ''
Local aReg			:= {}
Local lTIPATV		:= CF5->(fieldpos("CF5_TIPATV")) > 0
Local aStruCF5		:= CF5->(DBStruct())
Local nCF5			:= 0
Local nTamCF5		:= Len(aStruCF5)
Local cCmpMemo 		:= ""

For nCF5 := 1 To nTamCF5	
	IF aStruCF5[nCF5][2] <> 'M' //Campos Memo devem ser ultimos campos
		IF nCF5 == 1
			cSelect += "CF5."+aStruCF5[nCF5][1]	
		Else
			cSelect += ", CF5."+aStruCF5[nCF5][1]	
		Endif
	Else
		cCmpMemo += ", CF5."+aStruCF5[nCF5][1]	
	Endif
	
Next (nCF5)

cAliasCF5	:=	GetNextAlias()
cSelect :=	'%' + (cSelect + cCmpMemo) + '%' //"%CF5.*%"
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
FwFreeArray(aStruCF5)

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

Static Function F100Presu(dDataDe,dDataAte,cNrLivro,oApurEnt,nTotF100,cFilialMat,lIndividu)
Local nX         := 0
Local oF100	   :=	TABELACL2():New() //Cria objeto para gravação do F100
Local aTotSai    := {}
Local aTotEnt    := {}
Local aCrePresu  := {}
Local cCstPres   := GetNewPar("MV_CSTPRES","62")

aTotSai   := F100PreTSai(dDataDe,dDataAte,cNrLivro)
aTotEnt   := F100PreTEnt(dDataDe,dDataAte,cNrLivro)
 
//Somente irá processar crédito presumido se houver valor de base de cálculo/Exportação. Caso contrário não deverá gerar F100 na apuração e na CL2.
If aTotSai[1] > 0
        
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
				oF100:SetParam('CL2_FILAPU',IIf(lIndividu,oF100:BuscaxFil('CL2'),cFilialMat) )				
				oF100:SetParam('CL2_CLIFOR' , aCrePresu[16] )
				oF100:SetParam('CL2_LOJA'   , aCrePresu[17] )
				
				oF100:Save()
			EndIf
		Next nX
		 //MATO O OBJETO oF100
       FreeObj(oF100)
		oF100:= nil 
         
EndIf

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

		If cEspecie$"  " .Or. ( (AllTrim((cAliasSFT)->FT_CFOP)$aCFOPs[01])	.AND. !(AllTrim((cAliasSFT)->FT_CFOP)$aCFOPs[02]) ).And. NCMCPPC((cAliasSFT)->B1_POSIPI, aNCMS)// Verifica se o CFOP é gerador de receita
      
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
					AADD(aRetorno[nPos], (cAliasSFT)->FT_CLIEFOR)
					AADD(aRetorno[nPos], (cAliasSFT)->FT_LOJA)
					
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
Local aRetorno		:= {0,0,"","","","","",0,0,0,"","","","","","",""}
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
aRetorno[16] := aVlrCompra[nX,7] //Código do cliente/fornecedor
aRetorno[17] := aVlrCompra[nX,8] //Loja do cliente fornecedor

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
Local cOutRec	:= SuperGetMv("MV_CODGEN",.F.,"")
Local lNTrib 	:= CKX->(FieldPos('CKX_NTRIB'))>0 .And. !EmpTy(cOutRec)
local lTabCPRB		:= .f.	
local lIndividu		:= .f.
Local lCPRBNF		:= GetNewPar('MV_CPRBNF',.F.)

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

// Quando Apuração ocorrer por Nota, deve consolidar tabela CKX e CKV com valor final da receita bruta
IF lCPRBNF
	oCPRB:ConsolCPRB(aFil)
Endif

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
		
		IniTabApur(aPergunta,aXFilial,.f.,.f., lTabCPRB) //Limpa as tabelas de apuração
	 
	 next nX
endif


//Quando a receita bruta decorrente de atividades desoneradas for igual ou superior a 95% da receita bruta total aplicar-se-á a desoneração sobre o valor total das operações.
If lNTrib // Verifica se parametro esta diferente de branco
	
	IF nPerc > 5 .And. nPerc < 95
		for nX:=1 to len( aFil ) //Processamento por Filial
			
			SM0->(DbGoTop ())
			SM0->(MsSeek (aFil[nX][1]+aFil[nX][2], .T.))
			cFilAnt := FWGETCODFILIAL			
			
			//Se for individualizado, busco a devida filial
			if lIndividu
				aXFilial:= ASA001AFIL()
			endif			
			
			//Limpa tabela CKX com Flag
			oCPRB:ClrNtrib()		
		 
		 next nX		 
	Endif

	IF nPerc >= 95		
		
		for nX:=1 to len( aFil ) //Processamento por Filial
			
			SM0->(DbGoTop ())
			SM0->(MsSeek (aFil[nX][1]+aFil[nX][2], .T.))
			cFilAnt := FWGETCODFILIAL			
			
			//Se for individualizado, busco a devida filial
			if lIndividu
				aXFilial:= ASA001AFIL()
			endif
			
			//Acumula valores e codigos existente na tabela CKX com flag não desenerados
			//Carrega CKX com Flag
			oCPRB:LoadNTrib()		
		 
		 next nX	
	Endif
Endif

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
Local lTabSv5	:=  AliasINdic('SV5') .AND. FindFunction("NewDesFol")
Local lProcSV5	:= .F.
Local cFilSV5	:= ''

//Verifica se exiete a tabela SV5 e se existem informações a serem processadas
//se existir então o relatório será gerado com as informações desta tabela, pois o faturamento não irá mais gerar o arquivo temporário em DBF, foi subistituído por TemporaryTable
If lTabSv5 
	DbSelectArea('SV5')
	DbSetOrder(1)
	cFilSV5		:= 	xFilial('SV5')
	IF SV5->(MsSeek(cFilSV5+cPeriodo))
		lProcSV5	:= .T.
	EndIF
EndIF	
	
If lProcSV5	
	Do While !SV5->(Eof ())	.AND. SV5->V5_FILIAL == cFilSV5 .AND. SV5->V5_PERIODO == 	cPeriodo
	
		If SV5->V5_TIPO $ 'N/C/P' 
				
			nPos := aScan (aAliqAtv, {|aX| aX[1] ==  Alltrim(SV5->V5_CODATIV)})
			//Guardo as alíquotas e códigos de atividades processados para não chamar a SpedPCCG1 para todos os itens
			IF nPos == 0		
				nAlq	:= SpedPCCG1(SV5->V5_CODATIV,dDataAte)
				aAdd(aAliqAtv, {})
				nPos := Len(aAliqAtv)
				aAdd (aAliqAtv[nPos], Alltrim(SV5->V5_CODATIV))
				aAdd (aAliqAtv[nPos], nAlq)
			Else
				nAlq	:= aAliqAtv[nPos][2]
			EndIF

			ObjF0T:Clear()
			ObjF0T:SetValue("F0T_PER",dDataDe)
			ObjF0T:SetValue("F0T_FILAPU",cFilialMat)
			ObjF0T:SetValue("F0T_TIPO",Iif(lProcRH,'7' ,'6' )) //CPRB Regime de Caixa							
			ObjF0T:SetValue("F0T_NUMNF", SV5->V5_NUMNF)
			ObjF0T:SetValue("F0T_SER",SV5->V5_SERIE)
			ObjF0T:SetValue("F0T_DTEMI",SV5->V5_DATANF )										
			ObjF0T:SetValue("F0T_CFOP",SV5->V5_CFOP)
			ObjF0T:SetValue("F0T_VLCONT",SV5->V5_TOTAL)
			
			//-------------------------------
			//Campos abaixo serão adicionados pela equipe de Faturamento
			ObjF0T:SetValue("F0T_ITEM",SV5->V5_ITEMNF)
			ObjF0T:SetValue("F0T_MODELO",SV5->V5_ESPECNF)
			ObjF0T:SetValue("F0T_EXCPRB",Iif(SubStr(SV5->V5_CFOP,1,1)=="7",SV5->V5_TOTAL,SV5->V5_TOTBRUT-SV5->V5_TOTAL))					
			ObjF0T:SetValue("F0T_CODATV",SV5->V5_CODATIV)
			//-------------------------------			
			//Campos abaixo serão calculados por nós, considerando alíquota do código de atividade
			ObjF0T:SetValue("F0T_BCCPRB",Iif(SubStr(SV5->V5_CFOP,1,1)=="7",SV5->V5_TOTBRUT-SV5->V5_TOTAL,SV5->V5_TOTAL))					
			ObjF0T:SetValue("F0T_AQCPRB",nAlq)
			ObjF0T:SetValue("F0T_VLCPRB",Iif(SubStr(SV5->V5_CFOP,1,1)=="7",Round((SV5->(V5_TOTBRUT-V5_TOTAL)* nAlq)/100 ,2),Round((SV5->V5_TOTAL * nAlq)/100 ,2)))							
			
			ObjF0T:Grava()
		
		EndIF
		
		SV5->(DBSKIP())
	Enddo
	
Else
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
		If (cAliasTMP)->(FieldPos('ITEMNF')) > 0 
		
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
					ObjF0T:SetValue("F0T_EXCPRB",Iif(SubStr((cAliasTMP)->CFOP,1,1)=="7",(cAliasTMP)->TOTAL,(cAliasTMP)->TOTBRUTO-(cAliasTMP)->TOTAL))			
					ObjF0T:SetValue("F0T_CODATV",(cAliasTMP)->CODATIV)
					//-------------------------------			
					//Campos abaixo serão calculados por nós, considerando alíquota do código de atividade
					ObjF0T:SetValue("F0T_BCCPRB",Iif(SubStr((cAliasTMP)->CFOP,1,1)=="7",(cAliasTMP)->TOTBRUTO-(cAliasTMP)->TOTAL,(cAliasTMP)->TOTAL))			
					ObjF0T:SetValue("F0T_AQCPRB",nAlq)
					ObjF0T:SetValue("F0T_VLCPRB",Iif(SubStr((cAliasTMP)->CFOP,1,1)=="7",Round(((cAliasTMP)->(TOTBRUTO-(cAliasTMP)->TOTAL)* nAlq)/100 ,2),Round(((cAliasTMP)->TOTAL * nAlq)/100 ,2)))							
					
					ObjF0T:Grava()
				EndIf											
				(cAliasTMP)->(DBSKIP())
			Enddo
		EndIF
		
		DbSelectArea(cAliasTMP)
		dbCloseArea()		
		
	EndIF
	
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} A001Suced
 
Função de geração dos valores do F800 para o objeto
 
@author Henrique Pereira
@since 23/06/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Static Function A001Suced(dDataDe, dDataAte,	oApurEFD)
Local cAliasF0X	:= 'F0X'
Local oGetF0X    := FISX001():New()

cAliasF0X	:=	GetNextAlias()
oGetF0X:GetF0X(dDataDe)

//Shiny acerto para evitar error.log
BeginSql Alias cAliasF0X

	SELECT
		%Exp:oGetF0X:GetcSlctF0X()%

	FROM
		%Exp:oGetF0X:GetcFromF0X()%
	WHERE
		%Exp:oGetF0X:GetcWhereF0X()%
EndSql

ProcRegua ((cAliasF0X)->(RecCount ()))	
DbSelectArea (cAliasF0X)
(cAliasF0X)->(DbGoTop ())
Do While !(cAliasF0X)->(Eof ())	
	
		oApurEFD:SetRegime(NAOCUMULAT)
		oApurEFD:SetOrigem(OUTROS)		
		oApurEFD:SetCodBcc('13')
		oApurEFD:SetDNatRec((cAliasF0X)->F0X_DTEVEN)
		oApurEFD:setCredSBse(.T.) // F800	
		oApurEFD:setIndCre('1')	
		//-------------------------------------------------------------------
		//Informações de PIS
		//-------------------------------------------------------------------			
		oApurEFD:SetTributo(PIS)
		oApurEFD:SetCST('  ')		
		oApurEFD:SetAlqTrib(0)
		oApurEFD:SetBcTrib(0)
		oApurEFD:SetValTrib((cAliasF0X)->F0X_VALPIS)
		oApurEFD:SetCodDC((cAliasF0X)->F0X_CODCRE)		
		oApurEFD:AgrpCred()
		

		//-------------------------------------------------------------------
		//Informações da COFINS
		//-------------------------------------------------------------------		
		oApurEFD:SetTributo(COFINS)		
		oApurEFD:SetCST('  ')
		oApurEFD:SetAlqTrib(0)
		oApurEFD:SetBcTrib(0)
		oApurEFD:SetValTrib((cAliasF0X)->F0X_VALCOF)
		oApurEFD:SetCodDC((cAliasF0X)->F0X_CODCRE)
		oApurEFD:AgrpCred()
		
		
		//Agrupa valores para resumo de CST
		oApurEFD:GrvResCST()		
		oApurEFD:SetImport(.F.)		
		
	(cAliasF0X)->(DbSkip ())			
EndDo

	DbSelectArea(cAliasF0X)
	dbCloseArea()
	oApurEFD:setCredSBse(.F.)
	oApurEFD:setIndCre('0')	

return

//-------------------------------------------------------------------
/*/{Protheus.doc} FSA001QECF
 
Função que irá montar a query para extrair as movimentações de cupom fiscal
do SigaLoja gravados na SFT. Esta query é utilizando de forma agrupada na apuração ou
então de forma individualizada no relatório de conferência FISR101.
 
@param lGroup 		- Booleano - Indica se é agrupado ou individualizado
@param cNrLivro 	- Caracter - Número do Livro
@param dDataDe 	- Date 		- Data inicial de processamento
@param dDataAte 	- Date 		- Data final de processamento

@author Erick G Dias
@since 29/08/2016
@version 11.80

/*/
//-------------------------------------------------------------------
Function FSA001QECF(lGroup,cNrLivro,dDataDe,dDataAte,lBilhete,lExigSusp)
     
Local cAliasSFT	:= "SFT"
Local cSlctSFT	:= ""
Local cFiltro		:= "" 
Local cOrderBy	:= ""
Local cExpIN := ""
Local cFrom	:= ""

Default lGroup	:= .T.
Default lBilhete := .F.
Default lExigSusp	:= .F.
// Definição da clausula IN do WHERE p/ bilhetes e cupons normais, conforme a chamada da função.
cExpIN := IIf(lBilhete, FormatIn('BPR',"|") , FormatIn('CF|ECF',"|"))
					

// ==============================================
// Query Principal - ECF
// ==============================================  

cSlctSFT := "SFT.FT_CLIEFOR,	SFT.FT_LOJA,		SFT.FT_ALIQPIS,		SFT.FT_ALIQCOF,"
cSlctSFT += "SFT.FT_CSTPIS,		SFT.FT_CSTCOF,		SFT.FT_ALIQCF3,		SFT.FT_ALIQPS3,"
cSlctSFT += "SFT.FT_TNATREC,	SFT.FT_CNATREC,		SFT.FT_GRUPONC,		SFT.FT_DTFIMNT,"
cSlctSFT += "SFT.FT_CFOP,		SFT.FT_PAUTPIS,		SFT.FT_PAUTCOF,		SF4.F4_TPREG,"
cSlctSFT += "SB1.B1_TPREG, 		SFT.FT_CONTA,		SFT.FT_FILIAL,		SFT.FT_TIPOMOV,"
cSlctSFT += "SFT.FT_SERIE,		SFT.FT_NFISCAL,		SFT.FT_NFELETR,		SFT.FT_ITEM,"
cSlctSFT +=	"SFT.FT_PRODUTO,	SFT.FT_ENTRADA,		SFT.FT_DTCANC, 		SFT.FT_OBSERV, 		SFT.FT_TIPO, "

If lGroup
	cSlctSFT +="SUM(SFT.FT_VALPIS)	AS	FT_VALPIS, 	SUM(SFT.FT_VALCOF)	 AS	FT_VALCOF,		SUM(SFT.FT_TOTAL)	AS	FT_TOTAL,"
	cSlctSFT +="SUM(SFT.FT_BASEPIS) AS	FT_BASEPIS,	SUM(SFT.FT_BASECOF)  AS	FT_BASECOF,	    SUM(SFT.FT_VALCF3)  AS	FT_VALCF3,"
	cSlctSFT +="SUM(SFT.FT_BASEPS3) AS	FT_BASEPS3,	SUM(SFT.FT_VALPS3)   AS	FT_VALPS3,		SUM(SFT.FT_BASECF3) AS	FT_BASECF3,"
	cSlctSFT +="SUM(SFT.FT_QUANT)   AS	FT_QUANT,	SUM(SFT.FT_VALCONT)	 AS	FT_VALCONT"
Else
	cSlctSFT +="SFT.FT_VALPIS,	SFT.FT_VALCOF,	SFT.FT_TOTAL,	SFT.FT_BASEPIS,"
	cSlctSFT +="SFT.FT_BASECOF,	SFT.FT_VALCF3,	SFT.FT_QUANT,	SFT.FT_VALCONT,"
	cSlctSFT +="SFT.FT_BASEPS3,	SFT.FT_VALPS3,	SFT.FT_BASECF3"
EndIF

If lExigSusp
	cSlctSFT += " , SFT.FT_ESPECIE  , SFT.FT_EMISSAO, SFT.FT_VALICM, SFT.FT_VALICM, SFT.FT_CHVNFE, CCF.CCF_NUMERO, CCF.CCF_IDITEM, CCF.CCF_INDAUT, CCF.CCF_NATJU, CCF.CCF_TIPO, CCF.CCF_TRIB, CID.CID_CST, CID.CID_REDUC, CID.CID_ICMS, CID.CID_ISS, CID.CID_ALIQ, CID.CID_CODREC"
EndIF

cSlctSFT	:=	'%'+cSlctSFT+'%'

cFrom	:= RetSqlName('SFT')+' SFT '
cFrom	+= " INNER JOIN "+RetSqlName("SFI")+" SFI ON (SFI.FI_FILIAL = '" + xFilial("SFI") + "' AND SFI.FI_PDV=SFT.FT_PDV AND SFI.FI_DTMOVTO=SFT.FT_ENTRADA AND SFI.D_E_L_E_T_=' ')"
cFrom	+= " INNER JOIN "+RetSqlName("SLG")+" SLG ON (SLG.LG_FILIAL = '" + xFilial("SLG") + "' AND SLG.LG_PDV=SFT.FT_PDV AND SLG.D_E_L_E_T_=' ' )"
cFrom	+= " INNER JOIN "+RetSqlName("SB1")+" SB1 ON(SB1.B1_FILIAL  = '" + xFilial("SB1") + "' AND SB1.B1_COD=SFT.FT_PRODUTO AND SB1.D_E_L_E_T_=' ')"
cFrom	+= " INNER JOIN "+RetSqlName("SD2")+" SD2 ON(SD2.D2_FILIAL  = '" + xFilial("SD2") + "' AND SD2.D2_DOC=SFT.FT_NFISCAL AND SD2.D2_SERIE=SFT.FT_SERIE AND SD2.D2_CLIENTE=SFT.FT_CLIEFOR AND SD2.D2_LOJA=SFT.FT_LOJA AND SD2.D2_COD=SFT.FT_PRODUTO AND SD2.D2_ITEM=SFT.FT_ITEM AND SD2.D_E_L_E_T_=' ')"
cFrom	+= " INNER JOIN "+RetSqlName("SF4")+" SF4 ON(SF4.F4_FILIAL  = '" + xFilial("SF4") + "' AND SF4.F4_CODIGO=SD2.D2_TES AND SF4.D_E_L_E_T_=' ')" 				

If lExigSusp
	//Aqui faço join com as tabelas CDG e CCF
	cFrom	   +="INNER JOIN "+RetSqlName("CDG")+" CDG ON(CDG.CDG_FILIAL='"+xFilial("CDG")+"'  AND CDG.CDG_TPMOV=SFT.FT_TIPOMOV  AND CDG.CDG_DOC=SFT.FT_NFISCAL AND CDG.CDG_SERIE=SFT.FT_SERIE AND CDG.CDG_CLIFOR=SFT.FT_CLIEFOR AND CDG.CDG_LOJA=SFT.FT_LOJA AND CDG.D_E_L_E_T_=' ') "		
	cFrom	   +="INNER JOIN "+RetSqlName("CCF")+" CCF ON(CCF.CCF_FILIAL='"+xFilial("CCF")+"'  AND CCF.CCF_NUMERO=CDG.CDG_PROCES  AND CCF.CCF_TIPO=CDG.CDG_TPPROC AND CCF.CCF_IDITEM=CDG.CDG_ITPROC AND CCF.CCF_TRIB IN('7','8') AND CCF.CCF_NATJU IN('12','13','14','15','16','17','19') AND CCF.CCF_TPCOMP IN ('1','2') AND CCF.D_E_L_E_T_=' ') "
	cFrom	   +="INNER JOIN "+RetSqlName("CID")+" CID ON(CID.CID_FILIAL='"+xFilial("CID")+"'  AND CID.CID_NUMERO=CCF.CCF_NUMERO  AND CID.CID_TIPO=CCF.CCF_TIPO AND CID.CID_INDAUT=CCF.CCF_INDAUT AND CID.CID_IDITEM = CCF.CCF_IDITEM AND CID.D_E_L_E_T_=' ') "
EndIF

cFrom	:=	'%'+cFrom+'%'

cAliasSFT	:=	GetNextAlias()

cFiltro	:= "%SFT.FT_FILIAL= '" + xFilial("SFT") + "'        AND "
cFiltro	+= "SFT.FT_TIPOMOV= 'S'                            AND "
cFiltro += "SFT.FT_ENTRADA>= '" + %Exp:DToS(dDataDe)% + "' AND "
cFiltro += "SFT.FT_ENTRADA<= '" + %Exp:DToS(dDataAte)% + "'AND "
cFiltro	+= "SFT.FT_DTCANC = ' '                            AND "
cFiltro	+= "SFT.FT_ESPECIE IN " + %Exp:cExpIN% + "       AND"
cFiltro	+= "((SFT.FT_BASEPIS > 0 OR SFT.FT_CSTPIS IN ('07','08','09','49' ))  OR (SFT.FT_BASECOF > 0 OR SFT.FT_CSTCOF IN ('07','08','09','49'))) AND "

If (cNrLivro <> "*")
	cFiltro += " SFT.FT_NRLIVRO = '" +%Exp:cNrLivro% +"' AND "
EndiF  

cFiltro += " SFT.D_E_L_E_T_=' '"

If lGroup
	cOrderBy += " GROUP BY "
	cOrderBy += "SFT.FT_CLIEFOR,		SFT.FT_LOJA,		SFT.FT_ALIQPIS,		SFT.FT_ALIQCOF,"
	cOrderBy += "SFT.FT_CSTPIS,			SFT.FT_CSTCOF,		SFT.FT_ALIQCF3,		SFT.FT_ALIQPS3, 	SFT.FT_CFOP,"
	cOrderBy += "SFT.FT_TNATREC,		SFT.FT_CNATREC,		SFT.FT_GRUPONC,		SFT.FT_DTFIMNT,"
	cOrderBy += "SFT.FT_PAUTPIS,		SFT.FT_PAUTCOF,		SF4.F4_TPREG,		SB1.B1_TPREG,"
	cOrderBy += "SFT.FT_FILIAL,			SFT.FT_TIPOMOV,		SFT.FT_SERIE,		SFT.FT_NFISCAL,		SFT.FT_NFELETR,"
	cOrderBy += "SFT.FT_CONTA,			SFT.FT_ITEM,		SFT.FT_PRODUTO, 	SFT.FT_ENTRADA, 	SFT.FT_DTCANC,	SFT.FT_OBSERV, SFT.FT_TIPO%"
Else
	cFiltro += "%"
EndIF


BeginSql Alias cAliasSFT
	COLUMN FT_DTFIMNT AS DATE
	COLUMN FT_ENTRADA As DATE
	COLUMN FT_DTCANC  AS DATE
	
	SELECT			    
		%Exp:cSlctSFT%
	FROM 
		%Exp:cFrom%

	WHERE 		
		%Exp:cFiltro+cOrderBy%	
						
EndSql  

Return cAliasSFT
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
Local   lB1TPREG    := SB1->(FieldPos("B1_TPREG")) > 0
Local	lRet		:=	.F.
Local	aSetField	:=	{}
Local	nI			:=	0
Local   lF0T		:= AliasINdic('F0T')
Local   cChaveF0T	:= ''
Local   lCPRBNF		:= GetNewPar('MV_CPRBNF',.T.) .And. SFT->(FieldPos("FT_VALCPB")) > 0 .And. SFT->(FieldPos("FT_BASECPB")) > 0 .And. SFT->(FieldPos("FT_ALIQCPB")) > 0  
Local 	lSe1MsFil	:= SE1->(FieldPos("E1_MSFIL")) > 0
Local 	lSe5MsFil	:= SE5->(FieldPos("E5_MSFIL")) > 0
Local 	lUnidNeg 	:= FWSizeFilial() > 2	// Indica se usa Gestao Corporativa
Local 	cFilSe1		:= xFilial("SE1")
Local 	cFilSe5		:= xFilial("SE5")
Local 	cCpoFilSE5  := ""
Local 	dDataMaior	:= cTod('  /  /    ')

DEFAULT dDataDe	    := cTod('  /  /    ')

If nOpc == 1

	If cCompon == "SE1"

		//SELECT
		If lCountReg
			cSelect	:=	"%COUNT(*) COUNTREG%"
		Else
			//Como o left join do SE5 filtra somente o mês processado, preciso pegar a próxima data do aPar[2] - Data Até
			//para ajustar o SE5 nulo do filtro da query.
			dDataMaior	:= IIf(Len(aPar)>1, DaySum(aPar[2],1), dDataMaior) 

			//Campos que utilizarao Alias no Processamento
			cSelect	:=	"%SE1.E1_EMISSAO EMISSAO, SE1.E1_NUM DOC, SE1.E1_SALDO SALDO, SE1.E1_VALOR VALOR, "
			cSelect	+=	"SED.ED_CSTPIS CSTPIS, SED.ED_CSTCOF CSTCOF, CASE WHEN SED.ED_TPREG=' ' THEN SED.ED_INDCMLT ELSE (CASE WHEN SED.ED_TPREG='1' THEN '2' WHEN SED.ED_TPREG='2' THEN '1' ELSE '' END) END TPREG, SED.ED_PCAPPIS ALIQPIS, "
			cSelect	+=	"SED.ED_PCAPCOF ALIQCOF, SA1.A1_CGC CNPJCLI, SE5.E5_DATA DATABX, SE5.E5_TIPODOC TIPODOC, "
			cSelect	+=	"(SE5.E5_VALOR + SE5.E5_VLDESCO) VALORBX, SFT.FT_NFISCAL NFISCAL, SFT.FT_ENTRADA  , SFT.FT_NRLIVRO NRLIVRO, SB1.B1_COD CODPROD, SD2.D2_PROJPMS PROJETO, "            
			
			//Outros campos
			cSelect	+=	"SE1.E1_FILIAL,	SE1.E1_PREFIXO,  SE1.E1_PARCELA,SE1.E1_TIPO, SE1.E1_PARCELA, SE1.R_E_C_N_O_, SE1.E1_CLIENTE, SE1.E1_LOJA, "
			cSelect	+=	"SFT.FT_VALCONT, SFT.FT_ALIQPIS, SFT.FT_ALIQCOF, SFT.FT_CSTPIS, SFT.FT_CSTCOF, SFT.FT_VALPIS, SFT.FT_VALCOF, SFT.FT_BASEPIS, SFT.FT_BASECOF, SFT.FT_SERIE, SFT.FT_CLIEFOR, SFT.FT_LOJA, SFT.FT_ITEM, "
			cSelect	+=	"SF4.F4_TPREG, "
			cSelect	+=	"SB1.B1_PPIS, SB1.B1_PCOFINS, SB1.B1_PCSLL, SE6.E6_FILDEB, SF2.F2_VALBRUT, SFT.FT_TIPO, SFT.FT_TIPOMOV, SFT.FT_VALIPI, "

			If lCPRBNF
				cSelect	+=	"SFT.FT_VALCPB, SFT.FT_BASECPB, SFT.FT_ALIQCPB, SFT.FT_ATIVCPB, "
			EndIf
			
			If SB1->(FieldPos(aPar[3])) > 0
				cSelect	+=	"SB1."+aPar[3]+", " 
			Endif
			
			IF lB1TPREG
				cSelect	+=	"SB1.B1_TPREG, "			
			EndIF
						
			cSelect	+=	"SA1.A1_COD, SA1.A1_LOJA, "
			
			If SA1->(FieldPos(aPar[4])) > 0
				cSelect	+=	"SA1."+aPar[4]+", "
			Endif
			
			If SA1->(FieldPos("A1_IRBAX"))>0
				cSelect	+=	"SA1.A1_IRBAX, "
			Endif

			If SA1->(FieldPos("A1_TPREG"))>0 //Adicionado o Fieldpos pois esse campo eh criado pelo usuario.
				cSelect	+=	"SA1.A1_TPREG, "
			Endif

			cSelect	+= "SA1.A1_CGC CNPJCLI, "
			
			cSelect	+=	"SED.ED_CODIGO,	SED.ED_PERCPIS,	SED.ED_PERCCOF,	SED.ED_PERCCSL, "
			cSelect	+=	"SE5.E5_MOTBX,SE5.E5_NUMERO,	SE5.E5_PREFIXO,	SE5.E5_MOEDA,	SE5.E5_PARCELA,	SE5.E5_VRETPIS, SE5.E5_VRETCOF,	SE5.E5_VRETCSL,	E5_VRETISS,	E5_VRETIRF,	SE5.E5_VLJUROS, SE5.E5_VLMULTA,	SE5.E5_VLDESCO, SE5.E5_TIPO, SE5.E5_SEQ, SE5.E5_DATA%"
		Endif
	    
	    //FROM
		//Tabela Principal: SE1
		//Joins: 	SE1->SFT->SB1 / SE1->SF2->SFT->SB1
		//			SE1->SFT->SD2->SF4 / SE1->SF2->SFT->SD2->SF4
		//			SE1->SE5
		//			SE1->SED
		//			SE1->SA1
		If lUnidNeg
			cFilSe5 := SM0->M0_CODFIL
			cFilSe1 := SM0->M0_CODFIL
		EndIF

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
		// Tratamento de Filiais quando SE5 Compartilhada/Exclusiva
		If !Empty( Iif( lUnidNeg, FWFilial("SE5") , xFilial("SE5") ) )
			cCpoFilSE5 	:= "SE5.E5_FILIAL = '"  +   xFilial("SE5") + "'"
		Else
			If lSe5MsFil
				cCpoFilSE5 	:= "SE5.E5_MSFIL = '" + Iif(lUnidNeg, cFilSe5, cFilAnt) + "' "
			Else
				cCpoFilSE5 	:= "SE5.E5_FILORIG = '" + Iif(lUnidNeg, cFilSe5, cFilAnt) + "' "
			Endif
		EndIf
		cFrom	+=	"LEFT JOIN "+RetSqlName("SE5")+" SE5 ON (" + cCpoFilSE5 + " AND SE5.E5_TIPODOC NOT IN ('DC','JR','MT') AND SE5.E5_PREFIXO=SE1.E1_PREFIXO AND SE5.E5_NUMERO=SE1.E1_NUM AND SE5.E5_PARCELA=SE1.E1_PARCELA AND SE5.E5_TIPO=SE1.E1_TIPO AND "
		cFrom	+=	"SE5.E5_DATA>='"+DTOS(aPar[1])+"' AND SE5.E5_DATA<='"+DTOS(aPar[2])+"' AND "
		cFrom	+=	"SE5.E5_CLIFOR=SE1.E1_CLIENTE AND SE5.E5_LOJA=SE1.E1_LOJA AND "		


		//Subquery utilizada para eliminar sequencias que possuem estorno de baixas
		cFrom	+=	"SE5.E5_SEQ NOT IN (SELECT SE5SEQ.E5_SEQ " 
		cFrom	+=	"FROM "+RetSqlName("SE5")+" SE5SEQ " 
		cFrom	+=	"WHERE SE5SEQ.E5_FILIAL	=	SE5.E5_FILIAL AND " 
		cFrom	+=	"SE5SEQ.E5_PREFIXO	=	SE5.E5_PREFIXO AND "
		cFrom	+=	"SE5SEQ.E5_NUMERO	=	SE5.E5_NUMERO AND "
		cFrom	+=	"SE5SEQ.E5_PARCELA	=	SE5.E5_PARCELA AND "
		cFrom	+=	"SE5SEQ.E5_TIPO		= 	SE5.E5_TIPO AND "
		cFrom	+=	"SE5SEQ.E5_CLIFOR	= 	SE5.E5_CLIFOR AND "
		cFrom	+=	"SE5SEQ.E5_LOJA		= 	SE5.E5_LOJA AND "
		cFrom	+=	"SE5SEQ.E5_TIPODOC	=	'ES' AND "
		cFrom	+=	"SE5SEQ.D_E_L_E_T_	= ' ') AND "

		//Elimina estorno, Motivos de Baixa, Situacao de Documento 
		cFrom	+=	"SE5.E5_TIPODOC	<> 'ES' AND "
		cFrom	+=	"SE5.E5_MOTBX NOT IN ('LIQ','CEC') AND "
		cFrom	+=	"SE5.E5_SITUACA <> 'C' AND "	
		cFrom	+=	"SE5.D_E_L_E_T_ =  ' ') "
		
		// -- LEFT JOIN SFT/SF2 --
		//Verifico conteudo do parametro MV_1DUPREF, pois se utilizar o padrao (SF2->F2_SERIE), o prefixo do titulo eh gravado
		//com a serie da nota fiscal. Porem se utilizar outro conteudo, devera utilizar o campo F2_PREFIXO para encontrar a nota
		//vinculada ao titulo, entao precisa utilizar a tabela SF2 no JOIN antes da SFT.
		// Comentei e deixei sempre buscando da SF2, pois necessitaremos do F2_valbrut para fazer a proporção do item em relação ao total
//		If aPar[5] <> "SF2->F2_SERIE"
			cFrom	+=	"LEFT JOIN "+RetSqlName("SF2")+" SF2 ON SF2.F2_FILIAL='"+xFilial("SF2")+"' AND SF2.F2_DOC=SE1.E1_NUM AND SF2.F2_PREFIXO=SE1.E1_PREFIXO AND SF2.F2_CLIENT=SE1.E1_CLIENTE AND SF2.F2_LOJA=SE1.E1_LOJA AND SF2.D_E_L_E_T_ = '' "
			cFrom	+=	"LEFT JOIN "+RetSqlName("SFT")+" SFT ON SFT.FT_FILIAL='"+xFilial("SFT")+"' AND SFT.FT_SERIE=SF2.F2_SERIE AND SFT.FT_NFISCAL=SF2.F2_DOC AND SFT.FT_CLIEFOR=SF2.F2_CLIENT AND SFT.FT_LOJA=SF2.F2_LOJA AND " 
//		Else
//			cFrom	+=	"LEFT JOIN "+RetSqlName("SFT")+" SFT ON SFT.FT_FILIAL='"+xFilial("SFT")+"' AND SFT.FT_SERIE=SE1.E1_PREFIXO AND SFT.FT_NFISCAL=SE1.E1_NUM AND SFT.FT_CLIEFOR=SE1.E1_CLIENTE AND SFT.FT_LOJA=SE1.E1_LOJA AND "
//		Endif
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
		// Tratamento de Filiais quando SE1 Compartilhada/Exclusiva
		If !Empty( Iif( lUnidNeg , FWFilial("SE1") , xFilial("SE1") ) )
			cWhere 	+= "%SE1.E1_FILIAL = '"  +   xFilial("SE1") + "' AND "
		Else
			If lSe1MsFil
				cWhere 	+= "%SE1.E1_MSFIL = '" + Iif(lUnidNeg, cFilSe1, cFilAnt) + "' AND "
			Else
				cWhere 	+= "%SE1.E1_FILORIG = '" + Iif(lUnidNeg, cFilSe1, cFilAnt) + "' AND "
			Endif
		EndIf
	
		//Titulos emitido dentro do periodo ou Titulos emitidos anteriormente com baixa no periodo e baixa depois do periodo
		cWhere	+=	"((SE1.E1_EMISSAO>='"+DTOS(aPar[1])+"' AND SE1.E1_EMISSAO<='"+DTOS(aPar[2])+"' AND SE1.E1_SALDO>0 ) OR "
		cWhere	+=	"(SE1.E1_EMISSAO<'"+DTOS(aPar[1])+"' AND (SE5.E5_DATA>='"+DTOS(aPar[1])+"' AND SE5.E5_DATA<='"+DTOS(aPar[2])+"') )  OR " 
		cWhere	+=	"(SE1.E1_EMISSAO>='"+DTOS(aPar[1])+"' AND SE1.E1_EMISSAO<='"+DTOS(aPar[2])+"' AND (COALESCE(SE5.E5_DATA,'"+DTOS(dDataMaior)+"')>'"+DTOS(aPar[2])+"' AND SE1.E1_SALDO=0) ) ) AND "
		
		//Titulos emitidos para Orgao Publico
		cWhere	+=	"SE1.E1_SCORGP='1' AND "
		cWhere	+=	"SE1.E1_TIPO NOT IN ('PR ','PRE') AND " 
		cWhere	+=	"SE1.E1_ORIGEM NOT IN ('FINA460 ','FINA280') AND " 
		cWhere	+=	"SE1.E1_FATURA	= ' ' AND "
		cWhere	+=	"SE1.D_E_L_E_T_ = ' ' "
		
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
		COLUMN EMISSAO AS DATE
		COLUMN DATABX  AS DATE
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
		
		If lF0T  .AND. F0T->(MsSeek(cChaveF0T+'4'))
			//Deleta F0T do tipo 4
			Do While F0T->(F0T_FILIAL+DTOS(F0T_PER)+F0T_TIPO) == cChaveF0T+'4'
			   RecLock("F0T",.F.)
				F0T->(DbDelete())
				MsUnLock()
				F0T->(DbSkip())
			Enddo		
		EndIf
		
		IF lF0T  .AND. F0T->(MsSeek(cChaveF0T+'5'))
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

//CPRB
Local  	cCodBCCPB	:= ""
Local	nAlqCpb		:=	0
Local	nPCpbDifer	:=	0
Local	nCpbPago	:=	0
Local  	nCredCpbDf	:=  0
Local   cCodAtvCPB	:= ""
Local 	lCPRBNF		:= GetNewPar('MV_CPRBNF',.T.) .And. SFT->(FieldPos("FT_VALCPB")) > 0 .And. SFT->(FieldPos("FT_BASECPB")) > 0 .And. SFT->(FieldPos("FT_ALIQCPB")) > 0  
Local 	nValIPI		:= 0

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
Local	lA1IRBAX	:= SA1->(FieldPos("A1_IRBAX"))>0
Local	lUltBx := .F.
Local   cNatCre		:= ""
Local	lTransfere	:= .F.
Local	 lF0T	:= AliasINdic('F0T')
Local nCredCOFDf	:= 0
Local aSldCrdDif	:= {}
Local nSomaAbat		:= 0
Local nTotNF		:= 0
Local nDiferenca	:= 0
Local nRRecebida	:= 0
Local aF0T			:= {}
Local nF0T			:= 0
Local cF0T 			:= ""
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
	nSomaAbat	:= 0
	nTotNF		:= 0
	nTotTit		:= 0
	nDiferenca	:= 0
	nRRecebida	:= 0
	
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
		// TRATAMENTO ABAIXO RETIRADO, POIS ABATIMENTOS NA BAIXA E NA EMISSÃO PODEM OCORRER SIMULTANEAMENTE, CONSIDETANDO QUE SÃO N TRIBUTOS.
		/*
		//Calcula valores de retencao. Verifica o parametro MV_BR10925.
		//Se feito na Emissao (MV_BR10925 = 2), verifico os titulos de abatimento e posteriormente calculo a proporcao da baixa
		//Se feito na Baixa (MV_BR10925 = 1), utilizo os campos da tabela SE5, pois ja estarao preenchidos com abatimento correto.
		If !lBxCanc .And. !lBxPerPos
			If cTpReten == "2"
				DbSelectArea("SE1")				
				nVlrReten	:=	SomaAbat((cAlias)->E5_PREFIXO,(cAlias)->E5_NUMERO,(cAlias)->E5_PARCELA,"R",Val((cAlias)->E5_MOEDA),(cAlias)->E5_DATA,(cAlias)->A1_COD,(cAlias)->A1_LOJA,,dDataAte,(cAlias)->E1_TIPO)
			Else			
				//Se calculo IR na baixa, pego seu valor da SE5, caso seja na emissão, tenha baixa parcial e seu saldo seja zeros 
				//devo obte-lo a partir da função SomaAbat.				
				If lA1IRBAX .And. (cAlias)->A1_IRBAX == "2"
					nVlrReten	:=	(cAlias)->E5_VRETPIS+(cAlias)->E5_VRETCOF+(cAlias)->E5_VRETCSL+(cAlias)->E5_VRETISS				
					lUltBx :=	IsLastBx((cAlias)->E1_PREFIXO,(cAlias)->DOC,(cAlias)->E1_PARCELA,(cAlias)->E1_TIPO,(cAlias)->E1_CLIENTE,(cAlias)->E1_LOJA,(cAlias)->E5_SEQ) 
					If lUltBx .And. (cAlias)->SALDO == 0
						DbSelectArea("SE1")
						nVlrReten	+= SomaAbat((cAlias)->E5_PREFIXO,(cAlias)->E5_NUMERO,(cAlias)->E5_PARCELA,"R",Val((cAlias)->E5_MOEDA),(cAlias)->E5_DATA,(cAlias)->A1_COD,(cAlias)->A1_LOJA,,dDataAte,(cAlias)->E1_TIPO)
					Endif
				Else
					nVlrReten	:=	(cAlias)->E5_VRETPIS+(cAlias)->E5_VRETCOF+(cAlias)->E5_VRETCSL+(cAlias)->E5_VRETISS+(cAlias)->E5_VRETIRF
				EndIF
			Endif
		Endif
		*/
		If !lBxCanc .And. !lBxPerPos
			// Valor Retido na emissão, posso sempre subtrair do valor principal do titulo para encontrar o percentual de BX
			nSomaAbat 	:= SomaAbat((cAlias)->E5_PREFIXO,(cAlias)->E5_NUMERO,(cAlias)->E5_PARCELA,"R",Val((cAlias)->E5_MOEDA),(cAlias)->E5_DATA,(cAlias)->A1_COD,(cAlias)->A1_LOJA,,dDataAte,(cAlias)->E1_TIPO)
			//Valor Retido na baixa, posso somar ao valor baixado para comparar com o valor principal esperado  (Não trata INSS nesse ponto pois INSS é sempre na emissão)
			nVlrReten	:=	(cAlias)->E5_VRETPIS+(cAlias)->E5_VRETCOF+(cAlias)->E5_VRETCSL+(cAlias)->E5_VRETISS+(cAlias)->E5_VRETIRF
		EndIf
	
	Endif
	
	//Calculo do valor Total Recebido no Periodo: (- Juros e Multa) + Desconto    
    If !lBxCanc .And. !lBxPerPos .And. Iif(cOrigem=="SE1",(cAlias)->E5_DATA >= dDataDe .And. (cAlias)->E5_DATA <= dDataAte,.T.) 
		If lTransfere//Transfereicna
			nTotRec := A054PTit(dDataDe,dDataAte,(cAlias)->E6_FILDEB,(cAlias)->E1_PREFIXO,(cAlias)->DOC,(cAlias)->E1_PARCELA,(cAlias)->E1_CLIENTE, (cAlias)->E1_LOJA)
		Else // Sem transferência
			nTotRec	:=	((cAlias)->VALORBX - (Iif(cOrigem=="SE1",(cAlias)->E5_VLJUROS - (cAlias)->E5_VLMULTA,0)) )
		EndIF
	Endif

	//obter valor da receita recebida (Valor da baixa + impostos na baixa proporcionais)
	nRRecebida	:=  nTotRec + nVlrReten

	//obter percentual do recebimento (Receita Recebida * 100 / (Total do Tìtulo - Impostos na emissão))
	nPercRec	:= ( nRRecebida * 100 / ( (cAlias)->VALOR - nSomaAbat ) ) / 100

/*
	//Percentual do valor da baixa sobre o valor total do titulo
	//Esse trecho teve o conceito alterado em Fev/2018. Vide histórico
	nPercRec	:=	nTotRec / ( (cAlias)->VALOR - nSomaAbat - nVlrReten ) // Aqui estou retirando os abatimentos gerados na emissão do total esperado a receber
*/
	If cOrigem == "SE1"
		//A funcao Fa620Stat() verifica transferencia de titulos. Se o retorno for 2, significa que o titulo eh originado de
		//outra filial, portanto devo procurar a nota na filial de origem, atraves da funcao CkTranTit()
		If (nTranStat := Fa620Stat((cAlias)->R_E_C_N_O_)) == 2
			// CkTranTit() --> Retorna .T. se processou diferimento, faco loop para nao processar novamente
	 		If CkTranTit(cPrefixE1,cCmpB1Dif,cCmpA1Dif,nTotRec,cAlias,cRegime,cPerApur,@aColsCFAP,@aColsCFAC,@aColsCFBP,@aColsCFBC,dDataDe,aXFilial,@aSldCrdDif,cIndNatPJ)
				(cAlias)->(DbSkip())
				Loop
			Endif
		Elseif nTranStat == 1
			(cAlias)->(DbSkip())
			Loop
		Endif

		If Alltrim((cAlias)->FT_TIPOMOV) == 'S' .And. !((cAlias)->FT_TIPO $ 'D|B')	
			nValipi := (cAlias)->FT_VALIPI
		Else
			nValipi := 0
		EndIf	
	Endif

	//Se o titulo possui vinculo com nota fiscal, devo calcular proporcionalmente o valor do item com o valor
	//total do titulo financeiro. Utilizo todos os dados da tabela SFT (Aliquota, CST, Valor)
	DbSelectArea("SFT")
	If cOrigem == "SE1" .And. !Empty((cAlias)->NFISCAL)
	
		//Somatorio das parcelas do titulo, para calcular percentual real do registro que esta sendo processado
		If !Empty((cAlias)->E1_PARCELA)
			nTotTit 	:=	SumParcE1( (cAlias)->E1_FILIAL, (cAlias)->E1_CLIENTE, (cAlias)->E1_LOJA, (cAlias)->E1_PREFIXO, (cAlias)->DOC, dDataAte ) // Utiliza o SomaAbat
		Else
			nTotTit		:=	(cAlias)->VALOR - nSomaAbat
		Endif

		//Mudei para o VAlBRUT, assim posso comparar com FT_VALCONT
		nTotNF		:= (cAlias)->F2_VALBRUT 

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
		
		//Aliquotas - PIS e COFINS e CPRB
		nAlqPis		:=	(cAlias)->FT_ALIQPIS	
		nAlqCof		:=	(cAlias)->FT_ALIQCOF

		If lCPRBNF
			nAlqCpb		:=	(cAlias)->FT_ALIQCPB
		EndIf	
		
		// Preparando o valor que recebi, precisamos transformar no valor bruto
		nDiferenca	:= 	(nTotNF - nTotTit)	// Diferença do valor da NF para o valor que posso receber
		nTotRec		+=	(nDiferenca * nPercRec) 	  
		nTotRec		+=	nVlrReten // O valor das Retenções gravadas na SE5 já são proporcionais a baixa, por isso não preciso fazer a mesma regra acima.
		
		//Valor total da venda do item
		nTotVend	:=	(cAlias)->FT_VALCONT	  
		//Percentual do valor deste item em relacao ao valor total da NF
		nPercVlrNt	:=	((cAlias)->FT_VALCONT / nTotNF)
		nPercVlrNt	:= Iif(nPercVlrNt>1,1,nPercVlrNt)
		//Calculo do valor Total Recebido no Periodo com a proporcao sobre o item da nota fiscal
		nTotRec		:=	nTotRec * nPercVlrNt 

		//Calculo do valor Total Diferido no Periodo
		nTotDifer	:=	nTotVend - nTotRec - nValipi//Necessario descontar o valor do IPI da base de calculo, pois este nao deve compor a base novamente 

		// Ajustando o percentual recebido, considerando agora os abatimentos
		nPercRec :=  nTotRec / nTotVend
		
		// Realiza abatimento do valor do IPI proporcional ao valor da baixa para compor valor da contribuição diferida em período anterior
		if 	(cAlias)->EMISSAO < dDataDe
			nTotRec	 -= (nValIpi * nPercRec)
		endif

		cChvDoc	:=	(cAlias)->(NFISCAL+FT_SERIE+FT_CLIEFOR+FT_LOJA+FT_ITEM)
		
	Else
	
		cCSTPis		:=	(cAlias)->CSTPIS
		cCSTCof		:=	(cAlias)->CSTCOF
		
		If !cRegime $ "3/4"
			cTpReg		:=	cRegime
		Else
			If (cAlias)->TPREG == "1" // TPREG - 1=Cumulativo;2=Não Cumulativo 
				cTpReg := "2" // Cumulativo
			Else 
				cTpReg := "1" // Não Cumulativo
			Endif
		Endif
				 
		//Aliquotas - PIS e COFINS
		nAlqPis		:=	(cAlias)->ALIQPIS
		nAlqCof		:=	(cAlias)->ALIQCOF

		If lCPRBNF
			nAlqCpb		:=	(cAlias)->FT_ALIQCPB
		EndIf	
		
		// Preparando o valor que recebi, precisamos transformar no valor bruto
		nTotRec		+= (nSomaAbat * nPercRec) 	// Preciso proporcionalizar os abatimentos em relação ao valor da baixa 
		nTotRec		+= nVlrReten				// O valor das retenções da SE5 já estão proporcionalizados pela baixa
		//Valor total do titulo
		nTotVend	:=	(cAlias)->VALOR
		
		//Calculo do valor Total Diferido no Periodo
		nTotDifer	:=	((cAlias)->VALOR - nTotRec) - nValipi//Necessario descontar o valor do IPI da base de calculo, pois este nao deve compor a base novamente 
		// Ajustando o percentual recebido, considerando agora os abatimentos
		nPercRec :=  nTotRec / (cAlias)->VALOR
		
		cChvDoc	:=	Iif(cOrigem == "CF8",(cAlias)->DOC,(cAlias)->(DOC+E1_PREFIXO+E1_CLIENTE+E1_LOJA))
	
	Endif
	
	//Calcula valores da Contribuicao Diferida/Paga no periodo
	nPisDifer	:=	(nTotDifer * nAlqPis) / 100
	nCofDifer	:=	(nTotDifer * nAlqCof) / 100
	nPisPago	:=	(nTotRec * nAlqPis) / 100
	nCofPago	:=	(nTotRec * nAlqCof) / 100

	//Calcula valores da Contribuicao Diferida/Paga no periodo de CPRB
	nCpbDifer	:=	(nTotDifer * nAlqCpb) / 100
	nCpbPago	:=	(nTotRec * nAlqCpb) / 100

	If lCPRBNF
		cCodAtvCPB	:= 	(cAlias)->FT_ATIVCPB 
	EndIf	
	
	//Titulos emitidos no mesmo periodo do Processamento.
	//Serao gerados para a tabela CFA - Informacoes Adicionais de Diferimento (Registros M230 e M630)
	If cPerEmis == cPerApur
	    	    
		//aDocs -> utilizado para aglutinar os documentos, para que as tabelas do diferimento nao tenham valores duplicados
		//lNewDoc -> Indica se o documento esta sendo gravado pela primeira vez. Tratamento para nao duplicar valores
		If (nPos := aScan(aDocs,{|x| x[1]==cChvDoc})) == 0
			aAdd(aDocs,{})
			nPos := Len(aDocs)
			aAdd(aDocs[nPos],cChvDoc)					//CHAVE DO DOCUMENTO      1
			aAdd(aDocs[nPos],nTotVend)					//TOTAL VENDIDO           2
			aAdd(aDocs[nPos],nTotVend - nTotRec)		//TOTAL NAO RECEBIDO      3
			aAdd(aDocs[nPos],nTotDifer)					//TOTAL DIFERIDO          4
			aAdd(aDocs[nPos],nPisDifer)					//PIS DIFERIDO            5
			aAdd(aDocs[nPos],nCofDifer)					//COFINS DIFERIDO         6
			aAdd(aDocs[nPos],.T.)						//NOVO DOCUMENTO	      7		 
 			aAdd(aDocs[nPos],cCodBCPIS)					//CÓDIGO CRÉDITO PIS      8
			aAdd(aDocs[nPos],nCredPisDf)				//CRÉDITO PIS DIFERIDO    9		 				
			aAdd(aDocs[nPos],cCodBCCOF)					//CÓDIGO CRÉDITO COFINS   10
			aAdd(aDocs[nPos],nCredCOFDf)				//CRÉDITO COFINS DIFERIDO 11	

			//CPRB
			aAdd(aDocs[nPos],nCpbDifer)					//CPRB DIFERIDO		      12
			aAdd(aDocs[nPos],cCodBCCPB)					//CÓDIGO CRÉDITO CPRB     13
			aAdd(aDocs[nPos],nCredCpbDf)				//CRÉDITO CPRB DIFERIDO   14
			aAdd(aDocs[nPos],cCodAtvCPB)				//CODIGO ATIVIDADE CPRB   15						
		Else
			aDocs[nPos][3] -= nTotRec					//TOTAL NAO RECEBIDO
			aDocs[nPos][4] -= nTotRec					//TOTAL DIFERIDO
			aDocs[nPos][5] -= nPisPago					//PIS DIFERIDO
			aDocs[nPos][6] -= nCofPago					//COFINS DIFERIDO
			aDocs[nPos][7] := .F.						//NOVO DOCUMENTO

			//CPRB
			aDocs[nPos][12] -= nCpbPago					//CPRB DIFERIDO	

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
		aValores	:=	{	aDocs[nPos][4],aDocs[nPos][2],nTotRec,nAlqPis,nAlqCof,;//5
							aDocs[nPos][5],aDocs[nPos][6],nPisPago,nCofPago,aDocs[nPos][3],;//10
							aDocs[nPos][9],aDocs[nPos][11],aDocs[nPos][8],aDocs[nPos][10],;//14
							nAlqCpb, aDocs[nPos][12], nCpbPago, aDocs[nPos][14], aDocs[nPos][13], aDocs[nPos][15]}
							
		lNewDoc	:=	aDocs[nPos][7]
	   
		GrvInfDif(1,cAlias,cNtFiscal,cCSTPis,cCSTCof,aValores,cTpReg,cRegime,cPerApur,@aColsCFAP,@aColsCFAC,lNewDoc,cIndNatPJ,aXFilial,,lF0T,cOrigem,ObjF0T,, .T.)
		
		IF lF0T
			//Trecho abaixo irá agrupar as informações do mesmo título, para que nas situações onde existam diversas baixas o título não seja repetido
			nF0T			:= 0
			cF0T			:= dtos( dDataDe ) + cFilAnt 
						
			IF cOrigem == "SE1"
				cF0T	+= ( cAlias )->NFISCAL + (cAlias)->NFISCAL +  DTOS(Iif( empty((cAlias)->FT_ENTRADA),(cAlias)->EMISSAO,(cAlias)->FT_ENTRADA )) + (cAlias)->FT_ITEM + (cAlias)->DOC + (cAlias)->E1_PREFIXO + (cAlias)->E1_PARCELA	
			ElseIF cOrigem == "CF8"
				cF0T	+= DTos( (cAlias)->EMISSAO ) + (cAlias)->DOC 
			EndIF
			
			If Len(aF0T) > 0
				nF0T :=	aScan(aF0T	,{|aX| aX[1]==cF0T})				
			EndIf 

			If nF0T == 0
				IF cOrigem == "SE1"
					aAdd(aF0T,{})
					nF0T := Len(aF0T)
					
					aAdd(aF0T[nF0T], cF0T )											//1-CHAVE DO DOCUMENTO
					aAdd(aF0T[nF0T],dDataDe )										//2-EMISSAO
					aAdd(aF0T[nF0T],cFilAnt )										//3-FILIAL
					aAdd(aF0T[nF0T],(cAlias)->NFISCAL)								//4-NUMERO DOCUMENTO
					aAdd(aF0T[nF0T],(cAlias)->FT_SERIE)								//5-SERIE
					aAdd(aF0T[nF0T],Iif(empty((cAlias)->FT_ENTRADA),(cAlias)->EMISSAO,(cAlias)->FT_ENTRADA) )//6-COFINS DIFERIDO
					aAdd(aF0T[nF0T],(cAlias)->FT_ITEM)								//7-ITEM NF
					aAdd(aF0T[nF0T],(cAlias)->DOC)									//8-NUMERO DO TÍTULO
					aAdd(aF0T[nF0T],(cAlias)->E1_PREFIXO)							//9-PREFIXO TÍTULO
					aAdd(aF0T[nF0T],(cAlias)->E1_PARCELA)							//10-PARCELA TÍTULO				
					aAdd(aF0T[nF0T],aValores[2])									//11-Valor da  Operação
					aAdd(aF0T[nF0T],aValores[3])									//12-Valor recebido
					aAdd(aF0T[nF0T],aValores[1])									//13-Receita Diferida
					aAdd(aF0T[nF0T],aValores[6])									//14-PIS DIferido
					aAdd(aF0T[nF0T],aValores[7])									//15-Cofins Diferida
					aAdd(aF0T[nF0T],CTOD("  /  /    "))								//16-Emissão CF8
					aAdd(aF0T[nF0T],"")											    //17-ID CF8
					aAdd(aF0T[nF0T],(cAlias)->CNPJCLI)								//18-CNPJ Órgão Público
					//CPRB
					aAdd(aF0T[nF0T],aValores[16])									//19-CPRB DIferido

				ElseIf cOrigem == "CF8"
					aAdd(aF0T,{})
					nF0T := Len(aF0T)
					
					aAdd(aF0T[nF0T], cF0T )											//1-CHAVE DO DOCUMENTO 
					aAdd(aF0T[nF0T],dDataDe )										//2-EMISSAO
					aAdd(aF0T[nF0T],cFilAnt )										//3-FILIAL
					aAdd(aF0T[nF0T], "" )											//4-NUMERO DOCUMENTO
					aAdd(aF0T[nF0T], "" )											//5-SERIE
					aAdd(aF0T[nF0T],CTOD( "  /  /    " ) )							//6-COFINS DIFERIDO
					aAdd(aF0T[nF0T], "" )											//7-ITEM NF
					aAdd(aF0T[nF0T], "" )											//8-NUMERO DO TÍTULO
					aAdd(aF0T[nF0T], "" )											//9-PREFIXO TÍTULO
					aAdd(aF0T[nF0T], "" )											//10-PARCELA TÍTULO				
					aAdd(aF0T[nF0T],aValores[2])									//11-Valor da  Operação
					aAdd(aF0T[nF0T],aValores[3])									//12-Valor recebido
					aAdd(aF0T[nF0T],aValores[1])									//13-Receita Diferida
					aAdd(aF0T[nF0T],aValores[6])									//14-PIS DIferido
					aAdd(aF0T[nF0T],aValores[7])									//15-Cofins Diferida
					aAdd(aF0T[nF0T],(cAlias)->EMISSAO)								//16-Emissão CF8
					aAdd(aF0T[nF0T],(cAlias)->DOC)									//17-ID CF8	
					aAdd(aF0T[nF0T],(cAlias)->CNPJCLI)								//18-CNPJ Órgão Público
					//CPRB
					aAdd(aF0T[nF0T],aValores[16])									//19-CPRB DIferido

				EndIF
			Else
				//O valor recebido irei acumular
				aF0T[nF0T][12] += aValores[3]

				//Os valores abaixo preciso sempre refazer, pois deverá exibir o status atual do título.
				aF0T[nF0T][11] := aValores[2]
				aF0T[nF0T][13] := aValores[1]
				aF0T[nF0T][14] := aValores[6]
				aF0T[nF0T][15] := aValores[7]
			EndIF

		EndIF		
	
	//Titulos emitidos em periodo anterior ao Processamento.
	//Serao gerados para a tabela CFB - Contribuicao Diferida em Periodos Anteriores (Registros M300 e M700)
	ElseIf  (cAlias)->EMISSAO < dDataDe
		
		//Buscar informações na CFA considerando CNPJ, CODCON, TRIB e período de emissão.
										
		aValores	:=	{nTotDifer,nTotVend,nTotRec,nAlqPis,nAlqCof,nPisDifer,nCofDifer,nPisPago,nCofPago,nCredPisDf,nCredCOFDf,cNatCre,;//12
						"", "", nAlqCpb, nCpbDifer, nCpbPago, nCredCpbDf, "", cCodAtvCPB}
	
		GrvInfDif(2,cAlias,cNtFiscal,cCSTPis,cCSTCof,aValores,cTpReg,cRegime,cPerApur,@aColsCFBP,@aColsCFBC,,cIndNatPJ,aXFilial,nPercRec,lF0T,cOrigem,ObjF0T,@aSldCrdDif, .T.)

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
			ObjF0T:SetValue("F0T_CNPJ"	    ,(cAlias)->CNPJCLI)
			ObjF0T:SetValue("F0T_DTRECB"	,(cAlias)->DATABX)
			ObjF0T:SetValue("F0T_VALREC"	,nTotRec)
			ObjF0T:SetValue("F0T_VALPIS"	,nPisPago)
			ObjF0T:SetValue("F0T_VALCOF"	,nCofPago)

			//CPRB
			ObjF0T:SetValue("F0T_VLCPRB"	,nCpbPago)

			ObjF0T:Grava()
		EndIF
		
	Endif
	
	nRegsProc	+=	1	
	(cAlias)->(DbSkip())
Enddo

(DbCloseArea())


//Laço para gravar informações na F0T referente os títulos com diferimento no período.
For nF0T:= 1 to Len(aF0T) 

	ObjF0T:Clear()
	ObjF0T:SetValue("F0T_PER"		,aF0T[nF0T][2])
	ObjF0T:SetValue("F0T_FILAPU"	,aF0T[nF0T][3])
	ObjF0T:SetValue("F0T_TIPO"		,'4') //Diferimento período atual
	//Possui somente título ou  título + nota fiscal
	ObjF0T:SetValue("F0T_NUMNF"		,aF0T[nF0T][4])
	ObjF0T:SetValue("F0T_SER"		,aF0T[nF0T][5])
	ObjF0T:SetValue("F0T_DTEMI"		,aF0T[nF0T][6])
	ObjF0T:SetValue("F0T_ITEM"		,aF0T[nF0T][7])
	ObjF0T:SetValue("F0T_NUMTIT"	,aF0T[nF0T][8])
	ObjF0T:SetValue("F0T_PREFIX"	,aF0T[nF0T][9])
	ObjF0T:SetValue("F0T_PARC"		,aF0T[nF0T][10])		
	ObjF0T:SetValue("F0T_VLCONT"	,aF0T[nF0T][11])
	ObjF0T:SetValue("F0T_VALREC"	,aF0T[nF0T][12])
	ObjF0T:SetValue("F0T_RECDIF"	,aF0T[nF0T][13])			
	ObjF0T:SetValue("F0T_VALPIS"	,aF0T[nF0T][14])
	ObjF0T:SetValue("F0T_VALCOF"	,aF0T[nF0T][15])
	//Operações em Demais Documentos			
	ObjF0T:SetValue("F0T_DTEMI"		,aF0T[nF0T][16])
	ObjF0T:SetValue("F0T_IDCF8"		,aF0T[nF0T][17])
	ObjF0T:SetValue("F0T_CNPJ"		,aF0T[nF0T][18])

	//CPRB
	ObjF0T:SetValue("F0T_VLCPRB"	,aF0T[nF0T][19])

	ObjF0T:Grava()

Next nF0T

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
Static Function CkTranTit(cPrefixE1,cCmpB1Dif,cCmpA1Dif,nTotRecE5,cAliasOri,cRegime,cPerApur,aColsCFAP,aColsCFAC,aColsCFBP,aColsCFBC,dDataDe,aXFilial,aSldCrdDif,cIndNatPJ)
Local	lNewDoc	:=	.F.
Local	lAchouNota	:=	.F.
Local  lB1TPREG	:= SB1->(FieldPos("B1_TPREG")) > 0
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
Default aSldCrdDif	:= {}

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
	
	IF lB1TPREG		
		cSelect	+=	", SB1.B1_TPREG"
	EndIF	

	If SB1->(FieldPos(cCmpB1Dif)) > 0
		cSelect	+=	", SB1."+cCmpB1Dif+"" 
	Endif
	
	If SA1->(FieldPos("A1_TPREG"))>0
		cSelect	+=	", SA1.A1_TPREG"
	Endif
		
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
	
	cChvSF	:=cFilOrig+"S"+SE6->E6_PREFIXO+SE6->E6_NUM
	
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
								0,"","","",;
								0, 0, 0, 0, "", ""}

								
			lNewDoc	:=	aDocs[nPos][7]
		
		   
			GrvInfDif(1,cAliasOri,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CSTPIS,(cAliasSFT)->FT_CSTCOF,aValores,cTpReg,cRegime,cPerApur,@aColsCFAP,@aColsCFAC,lNewDoc,cIndNatPJ,aXFilial)
							
		//Titulos emitidos em periodo anterior ao Processamento.
		//Serao gerados para a tabela CFB - Contribuicao Diferida em Periodos Anteriores (Registros M300 e M700)
		Elseif (cAliasOri)->EMISSAO < dDataDe
		
			aValores	:=	{nTotDifer,nTotVend,nTotRec,(cAliasSFT)->FT_ALIQPIS,(cAliasSFT)->FT_ALIQCOF,nPisDifer,nCofDifer,nPisPago,nCofPago,0,0,"","","",;
							0, 0, 0, 0, "", ""}

			GrvInfDif(2,cAliasOri,(cAliasSFT)->FT_NFISCAL,(cAliasSFT)->FT_CSTPIS,(cAliasSFT)->FT_CSTCOF,aValores,cTpReg,cRegime,cPerApur,@aColsCFBP,@aColsCFBC,,cIndNatPJ,aXFilial,,,,,@aSldCrdDif)
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
Static Function GrvInfDif(nOpc,cAlias,cNtFiscal,cCSTPis,cCSTCof,aValores,cTpReg,cRegime,cPerApur,aColsPis,aColsCof,lNewDoc,cIndNatPJ,aXFilial,nPercRec,lF0T,cOrigem,ObjF0T,aSldCrdDif, lAjuCPRB)
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
Default aSldCrdDif	:= {}
DEFAULT lAjuCPRB	:= .F.
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
		MsUnLock()
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

	If lAjuCPRB
		//Registro para Contribuicao de CPRB 
		cCodCont	:=	'  '
		cChvCFA		:=	cFilCFA+cPerApur+"CPR"+cCodCont+cCNPJ+str(aValores[15],5,2)
		
		If SPEDSeek("CFA",1,cChvCFA)
			RecLock("CFA",.F.)
			
			CFA->CFA_CONREC	+=	aValores[17]
			CFA->CFA_VLRREC	+=	aValores[3]
			If lNewDoc
				CFA->CFA_CONDIF	+=	aValores[16]
				CFA->CFA_TOTVEN	+=	aValores[2]
				CFA->CFA_TOTDIF	+=	aValores[1]
				CFA->CFA_VLNREC	+=	aValores[10]
			Else
				CFA->CFA_CONDIF	-=	aValores[17]
				CFA->CFA_TOTDIF	-=	aValores[3]
				CFA->CFA_VLNREC	-=	aValores[3]
			Endif
			MsUnLock()
		Else
			RecLock("CFA",.T.)
			CFA->CFA_FILIAL	:=	cFilCFA
			CFA->CFA_CODCON	:=	cCodCont
			CFA->CFA_TPCON	:=	"CPR"
			CFA->CFA_CNPJ	:=	cCNPJ
			CFA->CFA_TOTVEN	:=	aValores[2]
			CFA->CFA_TOTDIF	:=	aValores[1]
			CFA->CFA_CONDIF	:=	aValores[16]
			CFA->CFA_CREDIF	:=	aValores[18]	
			CFA->CFA_CODCRE	:=	aValores[19] 
			CFA->CFA_ALIQ	:=	aValores[15] 
			CFA->CFA_CONREC	:=	aValores[17]
			CFA->CFA_VLRREC	:=	aValores[3]
			CFA->CFA_VLNREC	:=	aValores[10]
			CFA->CFA_PERAPU	:=	cPerApur

			IF lNewProc 
				CFA->CFA_CONSOL	:=	'2' //Gravo indicando que não é consolidado, pois veio da movimentação
			EndIF
			MsUnLock()
		Endif
	EndIf	

//Registro M300 e M700 - Tabela CFB
Else

	
	cDtPgto		:=	DTOS((cAlias)->DATABX)
	cPerDif		:=	Substr(DTOS((cAlias)->EMISSAO),5,2)+Substr(DTOS((cAlias)->EMISSAO),1,4)	
	//Registro para Contribuicao de PIS 
	cCodCont	:=	SPDCodCont("PIS",Empty(cNtFiscal),cCSTPis,aValores[4],cTpReg=="2",,Iif(cRegime $ '3/4' ,'3' ,cRegime ),lScp)
			
	IF lNewProc
		nPosCrd		:= 0	
		
		aRetCrdDif	:= CrdDifAnt(cFilCFA,cPerDif,"PIS",cCodCont,(cAlias)->CNPJCLI,aValores[4], nPercRec,@aSldCrdDif, aValores[3],cPerApur)
	EndIF
	
	If Len(aRetCrdDif) == 0
		cChvCFB		:=	cFilCFB+cPerApur+"PIS"+cCodCont+cPerDif+cDtPgto+str(aValores[4],5,2)+'  2'
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
				CFB->CFB_VLRREC	+= 	Iif(aRetCrdDif[nPosCrd][3] > 0 , Round(aValores[3] * aRetCrdDif[nPosCrd][3] / 100,2), aValores[3])  
				CFB->CFB_CONREC	+=	Iif(aRetCrdDif[nPosCrd][3] > 0 , Round(aValores[8] * aRetCrdDif[nPosCrd][3] / 100,2), aValores[8])  
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
				
				CFB->CFB_VLRREC	:=	IIf(aRetCrdDif[nPosCrd][3] > 0 , Round(aValores[3] * aRetCrdDif[nPosCrd][3] / 100,2) , aValores[3]) 
				CFB->CFB_CONREC	:=	Iif(aRetCrdDif[nPosCrd][3] > 0 , Round(aValores[8] * aRetCrdDif[nPosCrd][3] / 100,2) , aValores[8])  

				IF lNewProc
					CFB->CFB_CONSOL	:=	'2'
				EndIF
									
				MsUnLock()
			Endif
			
			//Gravat F0T com opção A

			IF lF0T .AND. aRetCrdDif[nPosCrd][2] > 0
				ObjF0T:Clear()
				ObjF0T:SetValue("F0T_FILIAL"	,cFilCFB)
				ObjF0T:SetValue("F0T_PER"		,firstday(STOD(cDtPgto)))
				ObjF0T:SetValue("F0T_FILAPU"	,cFilAnt)
				ObjF0T:SetValue("F0T_TIPO"		,'A') //Diferimento de créditos de PIS de período anterior
				ObjF0T:SetValue("F0T_DTEMI"		,STOD(cDtPgto) )
				ObjF0T:SetValue("F0T_DTRECB"	,(cAlias)->EMISSAO)		
				ObjF0T:SetValue("F0T_VLCONT"	,(cAlias)->VALOR)		
				ObjF0T:SetValue("F0T_VALREC"	,(cAlias)->VALORBX)		
				ObjF0T:SetValue("F0T_CNPJ"	    ,(cAlias)->CNPJCLI)		
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
				
				ObjF0T:SetValue("F0T_PERREC"	,nPercRec * 100 ) //Percentual recebido do título
				ObjF0T:SetValue("F0T_VALCOF"	,aRetCrdDif[nPosCrd][5] * 100 ) //Percentual recebido
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
		
		aRetCrdDif	:= CrdDifAnt(cFilCFA,cPerDif,"COF",cCodCont,(cAlias)->CNPJCLI,aValores[5], nPercRec,@aSldCrdDif, aValores[3],cPerApur)
	EndiF
	
	If Len(aRetCrdDif) == 0
		cChvCFB		:=	cFilCFB+cPerApur+"COF"+cCodCont+cPerDif+cDtPgto+str(aValores[5],5,2)+'  2'
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
				CFB->CFB_VLRREC	+=	Iif(aRetCrdDif[nPosCrd][3] > 0 , Round(aValores[3] * aRetCrdDif[nPosCrd][3] / 100,2), aValores[3])
				CFB->CFB_CONREC	+=	Iif(aRetCrdDif[nPosCrd][3] > 0 , Round(aValores[9] * aRetCrdDif[nPosCrd][3] / 100,2), aValores[9]) 
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
				
				CFB->CFB_VLRREC	:=	Iif(aRetCrdDif[nPosCrd][3] > 0 , Round(aValores[3] * aRetCrdDif[nPosCrd][3] / 100,2), aValores[3]) 
				CFB->CFB_CONREC	:=	Iif(aRetCrdDif[nPosCrd][3] > 0 , Round(aValores[9] * aRetCrdDif[nPosCrd][3] / 100,2), aValores[9])
				IF lNewProc
					CFB->CFB_CONSOL	:=	'2'
				EndIF								
				MsUnLock()
			Endif
			
			//Gravat F0T com opção B			

			IF lF0T .AND. aRetCrdDif[nPosCrd][2] > 0
				ObjF0T:Clear()
				ObjF0T:SetValue("F0T_FILIAL"	,cFilCFB)
				ObjF0T:SetValue("F0T_PER"		,firstday(STOD(cDtPgto)))
				ObjF0T:SetValue("F0T_FILAPU"	,cFilAnt)
				ObjF0T:SetValue("F0T_TIPO"		,'B') //Diferimento de créditos de PIS de período anterior
				ObjF0T:SetValue("F0T_DTEMI"		,STOD(cDtPgto) )
				ObjF0T:SetValue("F0T_DTRECB"	,(cAlias)->EMISSAO)		
				ObjF0T:SetValue("F0T_VLCONT"	,(cAlias)->VALOR)		
				ObjF0T:SetValue("F0T_VALREC"	,(cAlias)->VALORBX)		
				ObjF0T:SetValue("F0T_CNPJ"	    ,(cAlias)->CNPJCLI)		
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
				
				ObjF0T:SetValue("F0T_PERREC"	,nPercRec * 100 ) //Percentual recebido do título
				ObjF0T:SetValue("F0T_VALCOF"	,aRetCrdDif[nPosCrd][5] * 100 ) //Percentual recebido
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


	If lAjuCPRB

		cDtPgto		:=	DTOS((cAlias)->DATABX)
		cPerDif		:=	Substr(DTOS((cAlias)->EMISSAO),5,2)+Substr(DTOS((cAlias)->EMISSAO),1,4)	
		//Registro para Contribuicao de CPRB 
		cCodCont	:=	"  "
				
		IF lNewProc
			nPosCrd		:= 0	
			
			aRetCrdDif	:= CrdDifAnt(cFilCFA,cPerDif,"CPR",cCodCont,(cAlias)->CNPJCLI,aValores[15], nPercRec,@aSldCrdDif, aValores[3],cPerApur) //Analisar Shiny
		EndIF
		
		If Len(aRetCrdDif) == 0
			cChvCFB		:=	cFilCFB+cPerApur+"CPR"+cCodCont+cPerDif+cDtPgto+str(aValores[15],5,2)+'  2'
			If SPEDSeek("CFB",1,cChvCFB)
				RecLock("CFB",.F.)
				CFB->CFB_VLRREC	+=	aValores[3]
				CFB->CFB_CONREC	+=	aValores[17]
				CFB->CFB_CREDES	+=	0		
				MsUnLock()
			Else
				RecLock("CFB",.T.)
				CFB->CFB_FILIAL	:=	cFilCFB
				CFB->CFB_CODCON	:=	cCodCont
				CFB->CFB_TPCON	:=	"CPR"
				CFB->CFB_VLRREC	:=	aValores[3]
				CFB->CFB_CONREC	:=	aValores[17]
				CFB->CFB_PERDIF	:=	cPerDif
				CFB->CFB_DTPGTO	:=	STOD(cDtPgto)
				CFB->CFB_NATCRE	:=	''
				CFB->CFB_CREDES	:=	0
				CFB->CFB_PERAPU	:=	cPerApur
				CFB->CFB_ALIQ	:=	aValores[15]

				IF lNewProc
					CFB->CFB_CONSOL	:=	'2'
				EndIF
				MsUnLock()
			Endif
		Else
			
			For nPosCrd	:= 1 to len(aRetCrdDif)
				cChvCFB		:=	cFilCFB+cPerApur+"CPRB"+cCodCont+cPerDif+cDtPgto+str(aValores[15],5,2)+aRetCrdDif[nPosCrd][1]+'2'
				If SPEDSeek("CFB",1,cChvCFB)
					RecLock("CFB",.F.)
					CFB->CFB_VLRREC	+= 	Iif(aRetCrdDif[nPosCrd][3] > 0 , Round(aValores[3] * aRetCrdDif[nPosCrd][3] / 100,2), aValores[3])  
					CFB->CFB_CONREC	+=	Iif(aRetCrdDif[nPosCrd][3] > 0 , Round(aValores[17] * aRetCrdDif[nPosCrd][3] / 100,2), aValores[17])  
					CFB->CFB_CREDES	+=	aRetCrdDif[nPosCrd][2]		
					MsUnLock()
				Else
					RecLock("CFB",.T.)
					CFB->CFB_FILIAL	:=	cFilCFB
					CFB->CFB_CODCON	:=	cCodCont
					CFB->CFB_TPCON	:=	"CPRB"
					CFB->CFB_DTPGTO	:=	STOD(cDtPgto)
					CFB->CFB_PERDIF	:=	cPerDif
					CFB->CFB_NATCRE	:=	aRetCrdDif[nPosCrd][1]
					CFB->CFB_PERAPU	:=	cPerApur
					CFB->CFB_ALIQ	:=	aValores[15]
					CFB->CFB_CREDES	:=	aRetCrdDif[nPosCrd][2]
					
					CFB->CFB_VLRREC	:=	IIf(aRetCrdDif[nPosCrd][3] > 0 , Round(aValores[3] * aRetCrdDif[nPosCrd][3] / 100,2) , aValores[3]) 
					CFB->CFB_CONREC	:=	Iif(aRetCrdDif[nPosCrd][3] > 0 , Round(aValores[17] * aRetCrdDif[nPosCrd][3] / 100,2) , aValores[17])  
					//CFB->CFB_ATVCPB	:=	aValores[20]

					IF lNewProc
						CFB->CFB_CONSOL	:=	'2'
					EndIF
										
					MsUnLock()
				Endif
				
				//Gravat F0T com opção A

				IF lF0T .AND. aRetCrdDif[nPosCrd][2] > 0
					ObjF0T:Clear()
					ObjF0T:SetValue("F0T_FILIAL"	,cFilCFB)
					ObjF0T:SetValue("F0T_PER"		,firstday(STOD(cDtPgto)))
					ObjF0T:SetValue("F0T_FILAPU"	,cFilAnt)
					ObjF0T:SetValue("F0T_TIPO"		,'C') //Diferimento de créditos de PIS de período anterior
					ObjF0T:SetValue("F0T_DTEMI"		,STOD(cDtPgto) )
					ObjF0T:SetValue("F0T_DTRECB"	,(cAlias)->EMISSAO)		
					ObjF0T:SetValue("F0T_VLCONT"	,(cAlias)->VALOR)		
					ObjF0T:SetValue("F0T_VALREC"	,(cAlias)->VALORBX)		
					ObjF0T:SetValue("F0T_CNPJ"	    ,(cAlias)->CNPJCLI)		
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
					
					ObjF0T:SetValue("F0T_PERREC"	,nPercRec * 100 ) //Percentual recebido do título
					//ObjF0T:SetValue("F0T_VALCOF"	,aRetCrdDif[nPosCrd][5] * 100 ) //Percentual recebido
					ObjF0T:SetValue("F0T_MODELO"	,aRetCrdDif[nPosCrd][1]) //Natureza do crédito
					ObjF0T:SetValue("F0T_BCCPRB"	,aRetCrdDif[nPosCrd][4]) //VAlor de PIS diferido anteriormente
					ObjF0T:SetValue("F0T_VLCPRB"	,aRetCrdDif[nPosCrd][2]) //VAlor de PIS a descontar no período atual
					ObjF0T:Grava()				
								
				EndIF			
			
			Next nPosCrd
		
		EndIF
	EndIf	
	

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
		dDataAte -> dATA FINALIZAÇÃO DE PROCESSAMENTO
					
@return	nVlrTot -> Valor total de todas as parcelas somadas do titulo que esta
					sendo processado
		
@author Luccas Curcio
@since 19/10/2012
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SumParcE1(cFilE1,cCliente,cLoja,cPrefixo,cDoc, dDataAte)
Local	nVlrTot	:=	0
Local	nSomaAbat := 0

DbSelectArea("SE1")
SE1->(DbSetOrder(2))

If SE1->(MsSeek(cFilE1+cCliente+cLoja+cPrefixo+cDoc))
	While !SE1->(Eof()) .And. SE1->(E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM) == cFilE1+cCliente+cLoja+cPrefixo+cDoc
		If !(SE1->E1_TIPO $ MVABATIM)
			nSomaAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA, SE1->E1_EMISSAO, SE1->E1_CLIENTE, SE1->E1_LOJA,,dDataAte,SE1->E1_TIPO) 
			nVlrTot += SE1->E1_VALOR - nSomaAbat 
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
           	SE5.E5_TIPODOC IN ('BA','CP','VL','V2','LJ','ES','DC') AND
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
	// Retirei, pois queremos a baixa líquida, e ao chamar o somaabat estamos somando com TODOS abatimentos da SE1
	/*If cBR10925 == "2"
		nValLiq += (cAliasSE5)->E5_VALOR + SomaAbat((cAliasSE5)->E5_PREFIXO,(cAliasSE5)->E5_NUMERO,(cAliasSE5)->E5_PARCELA,"R",Val((cAliasSE5)->E5_MOEDA),dDataBase,(cAliasSE5)->E5_CLIFOR, (cAliasSE5)->E5_LOJA,,dDataAte) - (cAliasSE5)->E5_VLJUROS - (cAliasSE5)->E5_VLMULTA + (cAliasSE5)->E5_VLDESCO
	ElseIF FindFunction('SumPCC130') // essa parte foi retirada só pq não entendemos o sentido mesmo....
		nValLiq += (cAliasSE5)->E5_VALOR + SumPCC130((cAliasSE5)->E5_PREFIXO,(cAliasSE5)->E5_NUMERO,(cAliasSE5)->E5_PARCELA,(cAliasSE5)->E5_DATA,(cAliasSE5)->E5_CLIFOR,(cAliasSE5)->E5_LOJA,Val((cAliasSE5)->E5_MOEDA)) - (cAliasSE5)->E5_VLJUROS - (cAliasSE5)->E5_VLMULTA + (cAliasSE5)->E5_VLDESCO
	EndIf */
	
	nValLiq += (cAliasSE5)->E5_VALOR
	
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
		
		
		
Static Function CrdDifAnt(cFilCFA,cPerDif,cTrib,cCodCon,cCnpj,nAliq, nPerc,aSldCrdDif, nTotBaixa, cPerApur)

Local cChave	:= cFilCFA +  cPerDif + cTrib + cCodCon + cCnpj + STR(nAliq,5,2)   
Local aRet		:= {}
Local nPos		:= 0
Local cNatCred	:= ''
Local nTotCrd	:= 0
Local nValCrd	:= 0
Local nCont		:= 0
Local nPosSld	:= 0

Default aSldCrdDif	:= {}

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
			
			//Porporcionaliza o total da recebido do título em quetão em função do total da base do diferimento gravado na CFA do período
			//Pois o total de vendas da CFA pode contemplar diversos títulos no período para o mesmo CNPJ.
			nPerc := nTotBaixa/ CFA->CFA_TOTDIF
						
			nValCrd	:= Round(CFA->CFA_CREDIF * nPerc,2)
			
			nPosSld:=aScan(aSldCrdDif,{|aX| aX[1]==cChave})

			If nPosSld == 0	
				aRetVlDif := SldCredDif(cPerApur,cPerDif,Iif(cTrib == 'PIS', 'A',Iif(cTrib == 'COF', 'B', 'C')),cCnpj,cNatCred)

				aAdd(aSldCrdDif, {})
				nPosSld := Len(aSldCrdDif)
				aAdd (aSldCrdDif[nPosSld], cChave)//Chave																
				aAdd (aSldCrdDif[nPosSld], CFA->CFA_CREDIF - aRetVlDif[1])//Total do Crédito Disponível da chave
				aAdd (aSldCrdDif[nPosSld], CFA->CFA_TOTDIF - aRetVlDif[2])//SALDO A RECEBER ATÉ O MOMENTO

			EndIF

			
			If nValCrd < aSldCrdDif[nPosSld][2] .AND. nTotBaixa < aSldCrdDif[nPosSld][3]
				//Se o valor do crédito desta baixa não for superior ao total do crédito diferido ou o valor baixado não é superior ao saldo a receber, então pode utilizar de forma integral
				aSldCrdDif[nPosSld][2] -= nValCrd
				aSldCrdDif[nPosSld][3] -= nTotBaixa
			Else
				//Caso o valor da baixa do crédito seja maior que o crédito diferido inicialmente ou o Valor de Baixa for maior que o saldo a receber, então irá considerar somente a diferença
				nValCrd	:= aSldCrdDif[nPosSld][2] 
				aSldCrdDif[nPosSld][2]	:= 0
				aSldCrdDif[nPosSld][3]  := 0				
			EndIF
			
			IF nPos == 0
				aAdd(aRet, {})
				nPos := Len(aRet)
				aAdd (aRet[nPos], cNatCred)
				aAdd (aRet[nPos], nValCrd)
				aAdd (aRet[nPos], 0)												
				aAdd (aRet[nPos], CFA->CFA_CREDIF)
				aAdd (aRet[nPos], nPerc)
			Else
				aRet[nPos][2] += nValCrd
				aRet[nPos][5] += nPerc
				
			EndIF
			nTotCrd += nValCrd			
						
		EndIf
	
		CFA->(DbSkip ())
	EndDo
	
	For nCont	:= 1 to Len(aRet)
		aRet[nCont][3] := aRet[nCont][2] * 100 / nTotCrd
	Next nCont


EndIF

Return aRet

//Função que irá definir se novo processamento de diferimento está ou não habilitado.
Function ISA001NDIF()

Return GetNewPar('MV_DIFCRD1','1') == '2' .AND. CFA->(FieldPos( 'CFA_CONSOL' )) > 0 .AND. CFB->(FieldPos( 'CFB_CONSOL' )) > 0


Function ISA001Data()

Local cMsg	:= ''

cMsg	+= 'FISA001 - ' 	+ dtoc(GetAPOInfo("FISA001.prw")[4]) + ' - ' 	+  GetAPOInfo("FISA001.prw")[5] 	+ '  |  '   
cMsg	+= 'FISA002 - ' 	+ dtoc(GetAPOInfo("FISA002.prw")[4]) + ' - ' 	+  GetAPOInfo("FISA002.prw")[5]  	+ CHR(10)+CHR(13)
cMsg	+= 'FISA003 - ' 	+ dtoc(GetAPOInfo("FISA003.prw")[4]) + ' - ' 	+  GetAPOInfo("FISA003.prw")[5]  	+ '  |  '
cMsg	+= 'FISA004 - ' 	+ dtoc(GetAPOInfo("FISA004.prw")[4]) + ' - ' 	+  GetAPOInfo("FISA004.prw")[5]  	+ CHR(10)+CHR(13)
cMsg	+= 'FISA005 - ' 	+ dtoc(GetAPOInfo("FISA005.prw")[4]) + ' - ' 	+  GetAPOInfo("FISA005.prw")[5]  	+ '  |  '
cMsg	+= 'FISA006 - ' 	+ dtoc(GetAPOInfo("FISA006.prw")[4]) + ' - ' 	+  GetAPOInfo("FISA006.prw")[5]  	+ CHR(10)+CHR(13)
cMsg	+= 'FISA007 - ' 	+ dtoc(GetAPOInfo("FISA007.prw")[4]) + ' - ' 	+  GetAPOInfo("FISA007.prw")[5]  	+ '  |  '
cMsg	+= 'FISA008 - ' 	+ dtoc(GetAPOInfo("FISA008.prw")[4]) + ' - ' 	+  GetAPOInfo("FISA008.prw")[5]  	+ CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCO0 - ' 	+ dtoc(GetAPOInfo("EFDBLOCO0.prw")[4]) + ' - ' 	+  GetAPOInfo("EFDBLOCO0.prw")[5]  	+ '  |  '
cMsg	+= 'EFDBLOCO1 - ' 	+ dtoc(GetAPOInfo("EFDBLOCO1.prw")[4]) + ' - ' 	+  GetAPOInfo("EFDBLOCO1.prw")[5]  	+ CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCOA - ' 	+ dtoc(GetAPOInfo("EFDBLOCOA.prw")[4]) + ' - ' 	+  GetAPOInfo("EFDBLOCOA.prw")[5]  	+ '  |  '
cMsg	+= 'EFDBLOCOC - ' 	+ dtoc(GetAPOInfo("EFDBLOCOC.prw")[4]) + ' - ' 	+  GetAPOInfo("EFDBLOCOC.prw")[5]  	+ CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCOD - ' 	+ dtoc(GetAPOInfo("EFDBLOCOD.prw")[4]) + ' - ' 	+  GetAPOInfo("EFDBLOCOD.prw")[5] 	+ '  |  '
cMsg	+= 'EFDBLOCOF - ' 	+ dtoc(GetAPOInfo("EFDBLOCOF.prw")[4]) + ' - ' 	+  GetAPOInfo("EFDBLOCOF.prw")[5] 	+ CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCOI - ' 	+ dtoc(GetAPOInfo("EFDBLOCOI.prw")[4]) + ' - ' 	+  GetAPOInfo("EFDBLOCOI.prw")[5]  	+ '  |  '
cMsg	+= 'EFDBLOCOM - '	+ dtoc(GetAPOInfo("EFDBLOCOM.prw")[4]) + ' - ' 	+  GetAPOInfo("EFDBLOCOM.prw")[5]  	+ CHR(10)+CHR(13)
cMsg	+= 'EFDBLOCOP - ' 	+ dtoc(GetAPOInfo("EFDBLOCOP.prw")[4]) + ' - ' 	+  GetAPOInfo("EFDBLOCOP.prw")[5]  	+ '  |  '
cMsg	+= 'FISR101 - ' 	+ dtoc(GetAPOInfo("FISR101.prw")[4]) + ' - ' 	+  GetAPOInfo("FISR101.prw")[5]  	+ CHR(10)+CHR(13)
cMsg	+= 'FISX001 - ' 	+ dtoc(GetAPOInfo("FISX001.prw")[4]) + ' - ' 	+  GetAPOInfo("FISX001.prw")[5]  	+ '  |  '
cMsg	+= 'FISX002 - ' 	+ dtoc(GetAPOInfo("FISX002.prw")[4]) + ' - ' 	+  GetAPOInfo("FISX002.prw")[5]  


 
MSGINFO(cMsg)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} IsLastBx
Funcão que retorna a baixa que está sendo processada é a ultima do titulo.
	
@param	cPrefixo -> Prefixo do titulo baixado
		cNum -> Número do titulo baixado
		cParcela -> Parcela do titulo
		cTipo -> Tipo do titulo
		cFornece -> Cliente/Fornecedor
		cLoja -> Loja
		Seq -> Sequencia da baixa
				
@return	lRet
		
@author Marsaulo Dias de Souza
@since 16/02/2017
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function IsLastBx(cPrefixo,cNum,cParcela,cTipo,cFornece,cLoja,Seq)
Local lRet := .F.
Local cSeq := Seq
Local cQuery
Local cSeqMax := ""

If !Empty(Alltrim(cNum)) 

	cQuery := "SELECT MAX(SE5.E5_SEQ) SEQMAX"
	cQuery += " FROM " + RetSqlName("SE5") +" SE5 "
	cQuery += " WHERE SE5.E5_FILIAL = '" + xFilial("SE5") + "' AND"
	cQuery += "    	SE5.E5_RECPAG = 'R' AND "
	cQuery += "    	SE5.E5_SITUACA != 'C' AND "
	cQuery += "    	SE5.D_E_L_E_T_ = ' ' AND "
	cQuery += "       SE5.E5_PREFIXO = '" + cPrefixo + "' AND"
	cQuery += "       SE5.E5_NUMERO  = '" + cNum + "' AND"
	cQuery += "       SE5.E5_PARCELA = '" + cParcela + "' AND"
	cQuery += "       SE5.E5_TIPO = '" + cTipo + "' AND"
	cQuery += "       SE5.E5_CLIFOR = '" + cFornece + "' AND"
	cQuery += "       SE5.E5_LOJA = '" + cLoja + "' "
	
	cQuery := ChangeQuery(cQuery)
	
	dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"SEQUEN",.F.,.T.)
	
	/*ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Se a maior sequencia de baixa desse título for igual  ³
	//³a sequencia que está sendo tratada, significa que é a ³
	//³ultima baixa que ocorreu no título.                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ*/
	If SEQUEN->SEQMAX == cSeq
		lRet := .T.
	EndIf
	
	SEQUEN->(dbCloseArea())
Endif

Return lRet

Static Function CompTabEFD(lIndivid)

Local lErro		:= .F.
Local aAlias	:= {}
Local nCont		:= 0
Local cTit		:= 'Atenção, o compartilhamento das tabelas abaixo não condizem com o modo de apuração selecionado (' + Iif(lIndivid,'Individualizada','Agrupada') + '):'
Local cMsg		:= ''
Local cRet		:= ''

AADD(aAlias,{'CCY'})
AADD(aAlias,{'CCW'})
AADD(aAlias,{'SFV'})
AADD(aAlias,{'SFW'})
AADD(aAlias,{'CF5'})
AADD(aAlias,{'CF4'})
AADD(aAlias,{'CF3'})

//Verifica compatibilidade das tabelas de acordo com opção de apuração consolidada ou individualizada.	
For nCont	:=1 to Len(aAlias)
	
	IF FWModeAccess( aAlias[nCont][1] , 3 ) == Iif(lIndivid,'C' ,'E' )		
		cMsg +=aAlias[nCont][1] + Iif( nCont == Len(aAlias),'' ,',' )
		lErro	:= .T. 
	EndIf
	
Next nCont

If lErro
	cRet :=  cTit  + CHR(10)+CHR(13) + cMsg + CHR(10)+CHR(13) + 'Isso poderá ocasionar incosistências na apuração.' 
EndIF

Return cRet 

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcAjuFin
Função que fará ajuste de redução da contribuição, nas situações onde
existem títulos emitidos em período anterior que foram excluídos em 
período posterior, gerando assim registros M220 e M620 estornando 
a contribuição. Utiliza função do Financeiro FinSpdM220 que está no finxspd.prx

	
@param	dDtIni -> Data inicial de processamento'
		dDtFim -> Data final de processamento
		oAjustes -> Objeto para tratar os ajustes na apuração
		oApurSai -> Objeto para tratar a composição do código da contribuição
		
@author Erick G Dias
@since 19/01/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ProcAjuFin( dDtIni, dDtFim, oAjustes, oApurSai)

Local	aTitulo		:=	{}
Local	nX			:=	0
Local	cCondCont	:=	""
Local   lDetAju		:= CF5->(FieldPos('CF5_CST')) > 0

//Alimenta o array aTitulo com o conteudo retornado da funcao do Financeiro
aTitulo	:=	FinSpdM220(Month(dDtIni),Year(dDtFim))

For nX := 1 To Len(aTitulo)

	//Se tem valor de PIS fará o ajuste
	If aTitulo[nX][6] > 0 
		
		//Define o regime dos objetos oAjustes e oApursai
		IF aTitulo[nX][12] == '0' //Cumulativo
			oAjustes:SetRegime( CUMULAT )
			oApurSai:SetTpReg( CUMULAT )
		ElseIF aTitulo[nX][12] == '1' //Não Cumulativo
			oAjustes:SetRegime( NAOCUMULAT )
			oApurSai:SetTpReg( NAOCUMULAT )
		EndIF
				
		oApurSai:SetCST( aTitulo[nX][8] ) //CST de PIS		
		oApurSai:DefRegime()
		//----------------------
		//AJUSTE DE REDUÇÃO PIS
		//----------------------
		oAjustes:SetTributo( PIS ) 
		oAjustes:SetTpAjust( REDUCAO )
		oAjustes:SetCodAju( aTitulo[nX][2] )
		oAjustes:SetNumDoc( aTitulo[nX][3] )
		oAjustes:SetDescAju( aTitulo[nX][4] )
		oAjustes:SetVlAju( aTitulo[nX][6] )
		oAjustes:SetCodDC( oApurSai:CodCon() )
		oAjustes:SetCst(aTitulo[nX][8])			
		oAjustes:SetInfComp(aTitulo[nX][4])			
		oAjustes:SetAlq(aTitulo[nX][10])					
		oAjustes:SetDtRefer(stod(aTitulo[nX][5]))			
		//Tratamento para a base de PIS
		If len(aTitulo[nX]) >= 14
			oAjustes:SetBase(aTitulo[nX][13])
		Else
			oAjustes:SetBase(0)
		EndIf

		If Len(aTitulo[nX]) >= 15 
			oAjustes:SetConta(aTitulo[nX][15])
		EndIf 

		oAjustes:Ajustar()		
	EndIF

	//Se tem valor de COFINS fará o ajuste
	IF aTitulo[nX][7] > 0
		//-----------------
		//Ajustes de COFINS
		//-----------------
		//Define o regime dos objetos oAjustes e oApursai
		IF aTitulo[nX][12] == '0' //Cumulativo
			oAjustes:SetRegime( CUMULAT )
			oApurSai:SetTpReg( CUMULAT )
		ElseIF aTitulo[nX][12] == '1' //Não Cumulativo
			oAjustes:SetRegime( NAOCUMULAT )
			oApurSai:SetTpReg( NAOCUMULAT )
		EndIF		
		oApurSai:SetCST( aTitulo[nX][8] ) //CST de PIS		
		oApurSai:DefRegime()
		
		oAjustes:SetTributo(COFINS) 
		oAjustes:SetTpAjust(REDUCAO)
		oAjustes:SetCodAju(aTitulo[nX][2])
		oAjustes:SetNumDoc(aTitulo[nX][3])
		oAjustes:SetDescAju(aTitulo[nX][4])
		oAjustes:SetVlAju(aTitulo[nX][7])
		oAjustes:SetCodDC(oApurSai:CodCon() )
		oAjustes:SetCst(aTitulo[nX][9]) 			
		oAjustes:SetInfComp(aTitulo[nX][4])			
		oAjustes:SetAlq(aTitulo[nX][11])					
		oAjustes:SetDtRefer( stod(aTitulo[nX][5]) )			 		
		//Tratamento para base da COFINS
		If len(aTitulo[nX]) >= 14
			oAjustes:SetBase(aTitulo[nX][14])
		Else
			oAjustes:SetBase(0)
		EndIf
		
		If Len(aTitulo[nX]) >= 15 
			oAjustes:SetConta(aTitulo[nX][15])
		EndIf
		
		oAjustes:Ajustar()				
		
	Endif
	

Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExEFDCON03
Função que executará o ponto de entrada EFDCON03, que altera a conta
contábil do registro F100. Como o registro F100 pode ser gerado através
da SE1, SE2 ou SE5, verifico o alias, posiciono na tabela através do DBGOTOP()
e envio as informações para o ponto de entrada. 
A conta retornada pelo ponto de entrada será gerada no registro F100.

	
@param	cAlias - Caracter - Alias do título SE1/SE2/SE5
		nReco  - Numerico - Recno do título processado		

@return - Conta contábil retornada pelo ponto de entrada EFDCON03		

@author Erick G Dias
@since 24/04/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ExEFDCON03( cAlias, nReco )

Local cConta	:= ""

//Posiciona na tabela do título, e envia as informações para o ponto de entrada.
If cAlias == "SE1"
	SE1->(dbGoto( nReco ))
	cConta	:= ExecBlock("EFDCON03",.F.,.F.,{ cAlias, SE1->E1_NUM, SE1->E1_PREFIXO, SE1->E1_PARCELA, SE1->E1_TIPO, SE1->E1_CLIENTE, SE1->E1_LOJA, SE1->E1_NATUREZ, nReco })
ElseIF cAlias == "SE2"
	SE2->(dbGoto( nReco ))
	cConta	:= ExecBlock("EFDCON03",.F.,.F.,{ cAlias, SE2->E2_NUM, SE2->E2_PREFIXO, SE2->E2_PARCELA, SE2->E2_TIPO, SE2->E2_FORNECE, SE2->E2_LOJA, SE2->E2_NATUREZ, nReco })
ElseIF cAlias == "SE5"
	SE5->(dbGoto( nReco ))
	cConta	:= ExecBlock("EFDCON03",.F.,.F.,{ cAlias, SE5->E5_NUMERO, SE5->E5_PREFIXO, SE5->E5_PARCELA, SE5->E5_TIPO, Iif( !Empty( Alltrim( SE5->E5_CLIENTE ) ) , SE5->E5_CLIENTE , SE5->E5_FORNECE ) , SE5->E5_LOJA, SE5->E5_NATUREZ, nReco })
EndIF

Return cConta

//-------------------------------------------------------------------
/*/{Protheus.doc} AjBaseCalc
Função que fará leitura das informações da tabela F2Z para processar
os ajustes da base de cálculo de PIS e COFINS, buscando sempre as 
informações gravadas manualmente pelo usuário

@author Erick G. Dias
@since 31/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
 Static Function AjBaseCalc(dDataDe,dDataAte, oAjustes)

Local cAliasF2Z	:= GetNextAlias()
Local cSelect	:= ''
Local cWhere	:= ''
Local cFrom		:= ""
Local lF2ZALQ	:= F2Z->(FieldPos("F2Z_ALIQ")) > 0

//Seção do select com os campos necessários
cSelect :=	"F2Z.F2Z_INDAJU, F2Z.F2Z_VALAJU , F2Z.F2Z_CODAJU , F2Z.F2Z_NUM    , F2Z.F2Z_DESCR,"
cSelect +=	"F2Z.F2Z_DTREF , F2Z.F2Z_CONTA  , F2Z.F2Z_CNPJ   , F2Z.F2Z_COMPL   , F2Z.F2Z_TRIB  ,F2Z.F2Z_CODCON "

If lF2ZALQ
	cSelect +=	" ,F2Z.F2Z_ALIQ "
EndIF

//Seção do FROM e dos eventuais JOINS
cFrom := RetSqlName("F2Z") + " F2Z "

//Seção do Where da query
cWhere	:= "F2Z.F2Z_FILIAL='"+xFilial("F2Z")+"' AND "
cWhere	+= "F2Z.F2Z_DTREF>='"+DTOS(dDataDe)+"' AND "
cWhere	+= "F2Z.F2Z_DTREF<='"+DTOS(dDataAte)+"' AND "
cWhere	+= "F2Z.F2Z_ORIG ='1' AND "
cWhere  += "F2Z.D_E_L_E_T_ = ' '"

//Seção de Order By e eventual Group By
cOrder	:= " ORDER BY F2Z.F2Z_DTREF, F2Z.F2Z_TRIB, F2Z.F2Z_INDAJU"

// Preparação da query para execução do BeginSQL
cSelect := "%" + cSelect + "%"
cFrom   := "%" + cFrom   + "%"
cWhere  := "%" + cWhere  + cOrder + "%"

//Executa a query
BeginSql Alias cAliasF2Z
	COLUMN F2Z_DTREF AS DATE
    SELECT
        %Exp:cSelect%
    FROM
        %Exp:cFrom%
    WHERE
        %Exp:cWhere%

EndSql

//Processamento do resultado da query.
DbSelectArea (cAliasF2Z)
(cAliasF2Z)->(DbGoTop ())
Do While !(cAliasF2Z)->(Eof ())

	oAjustes:SetCrdDeb("2") //ajustes da base de débitos de PIS e COFINS
	
	//Definição do regime
	IF (cAliasF2Z)->F2Z_CODCON $ "01|02|03|04|71" //codigos não cumulativos
		oAjustes:SetRegime('1') //Não cumulativo
	Else
		oAjustes:SetRegime('2') //Cumulativo
	Endif

	oAjustes:SetTpAjust((cAliasF2Z)->F2Z_INDAJU) 
	oAjustes:SetVlAju((cAliasF2Z)->F2Z_VALAJU)
	oAjustes:SetCodAju((cAliasF2Z)->F2Z_CODAJU)
	oAjustes:SetNumDoc((cAliasF2Z)->F2Z_NUM)
	oAjustes:SetDescAju((cAliasF2Z)->F2Z_DESCR)
	oAjustes:SetDtRefer((cAliasF2Z)->F2Z_DTREF)
	oAjustes:SetConta((cAliasF2Z)->F2Z_CONTA)	
	oAjustes:SetCNPJ((cAliasF2Z)->F2Z_CNPJ)
	oAjustes:SetOrigem("A")//Origem de redução de base de cálculo
	oAjustes:SetInfComp((cAliasF2Z)->F2Z_COMPL)
	oAjustes:SetTributo((cAliasF2Z)->F2Z_TRIB)
	oAjustes:SetCodDC((cAliasF2Z)->F2Z_CODCON)
	
	//Se o campo de alíquota existir e estiver preenchido será enviado para a classe de ajustes
	If lF2ZALQ .AND. !Empty((cAliasF2Z)->F2Z_ALIQ)
		oAjustes:SetAlq((cAliasF2Z)->F2Z_ALIQ)
	EndIF 
	
	oAjustes:SetAjuBase(.T.)   
	oAjustes:SetAjuCKR(.T.)
	oAjustes:SetAjuF2Z(.T.)

	//Realiza o Ajuste
	oAjustes:Ajustar(,lF2ZALQ .AND. !Empty((cAliasF2Z)->F2Z_ALIQ))

	(cAliasF2Z)->(DbSkip ())			
EndDo

oAjustes:FechaAlias(cAliasF2Z)
 
Return

//-------------------------------------------------------------------
/*/
@description Função para tratar o valor o FT_VALICM para compor
@description no campo setiVaDesc - FT_DESCONT + FT_VALICM   
@description Com base na Regra do MV_DEDBPIS e DEDBCOF e A2_DEDBSPC
@author Bruce Mello
@since 01/11/2018
@version 12.17
/*/
//-------------------------------------------------------------------
Function DedPisCof(cDedbpis,cDedbcof,cEntSai,nValICMS,cDedbspc,cTipoNf,dEmissao, dMVICMDSDT)

//Local dMVICMDSDT := GetNewPar('MV_ICMDSDT', StoD("  /  /   "))
Local nValDesco	 := 0	
				// Opcoes do aNFCab[NF_DEDBSPC]:
				// 1 - Legado - Considera as regras dos parâmetros MV_DEDBPIS e MV_DEDBCOF.
				// 2 - Deduz ICMS e IPI.
				// 3 - Deduz Apenas ICMS.
				// 4 - Deduz Apenas IPI.
				// 5 - Não Deduz Nenhum.
				// 6 - Soma IP	
				
DEFAULT dEmissao := StoD("  /  /   ")

If (cEntSai =='2' .And. (dEmissao == StoD("  /  /   ") .Or. Iif(dMVICMDSDT == StoD("  /  /   "), .T., dEmissao >= dMVICMDSDT))) .Or. (cEntSai =='1' .And. cTipoNf =='D')
		If (cDedbPis $ "S,I" .and. cDedbcof $ "S,I")
			nValDesco := nValICMS
		EndIf
ElseIf cEntSai == '1' .or. (cEntSai =='2' .And. cTipoNf =='D' )
		If cDedbspc == '1' .and. (cDedbPis $ "S,I" .and. cDedbcof $ "S,I") 
			nValDesco := nValICMS
		Elseif cDedbspc $ ('23')
			nValDesco := nValICMS
		ElseIf cDedbspc $ ('456')
			nValDesco := 0
		Endif
Endif

Return nValDesco

//-------------------------------------------------------------------
/*/{Protheus.doc} ICMSRecolher
Função que busca os valores da apuração de ICMS, retornando o valor do 
ICMS a recolher e o valor de Débito Especial

@author Erick G. Dias
@since 12/12/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function ICMSRecolher(cLivro, dDataDe, dDataAte, cImp)

Local nValIcms		:= 0
Local aApICM		:= {}
Local cMVEstado	 	:= GetNewPar("MV_ESTADO","")
Local aParametros	:= {}
Local cAliasCDH		:= "CDH"

aAdd(aParametros,cImp)
aAdd(aParametros,"3")
aAdd(aParametros,"1")
//aAdd(aParametros,DTOS(dDataDe))
aAdd(aParametros,Dtos(FirstDate(dDataDe)))//DSERFIS1-15641 - tem que lançar nota no dia 20 e 3 threads configuradas retirada da variavel lmain, pois a função ICMSRecolher apesar de chamar o spedfiltro na CDH, nao passa data ate, so se baseia na data inicial trazendo todos os dados da apuração			
aAdd(aParametros,cLivro)

//Faço consulta na tabela CDH
If SPEDFFiltro(1,"CDH",@cAliasCDH,aParametros)
	While !(cAliasCDH)->(Eof())
		
		If (cAliasCDH)->CDH_LINHA == "013"
			
			//Valor do ICMS
			nValIcms += (cAliasCDH)->CDH_VALOR
		
		ElseIf (cAliasCDH)->CDH_LINHA$"900" .And. Alltrim((cAliasCDH)->CDH_SUBITE)<>"900.00" .And. !Empty((cAliasCDH)->CDH_CODLAN)
			
			//Considera valores do débito especial
			If Len(Alltrim((cAliasCDH)->CDH_CODLAN))==10 .OR.(SubStr((cAliasCDH)->CDH_CODLAN,3,1)=="0" .And. SubStr((cAliasCDH)->CDH_CODLAN,4,1)=="5")		
				nValIcms += (cAliasCDH)->CDH_VALOR
			EndIf

		EndIF

		(cAliasCDH)->(dbSkip())
	EndDo
	SPEDFFiltro(2,,cAliasCDH)
EndIF

Return nValIcms

//-------------------------------------------------------------------
/*/{Protheus.doc} AjuBasICMS
Função para auxiliar a geração dos ajustes da base de cálculo, excluindo o 
valor do ICMS a recolher.

@author Erick G. Dias
@since 13//12/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function AjuBasICMS(oAjustes, cCredDeb, cReg, cTpAju, nVlAju, cCodAju, cNumDoc, cDesc, dDrRefer, cConta, cCnpj, cInfComp, cTrib, cCodCon, cCst)

oAjustes:SetCrdDeb(cCredDeb)
oAjustes:SetRegime(cReg)
oAjustes:SetTpAjust(cTpAju)
oAjustes:SetVlAju(nVlAju)
oAjustes:SetCodAju(cCodAju)
oAjustes:SetNumDoc(cNumDoc)
oAjustes:SetDescAju(cDesc)
oAjustes:SetDtRefer(dDrRefer)
oAjustes:SetConta(cConta)
oAjustes:SetCNPJ(cCnpj) 
oAjustes:SetInfComp(cInfComp)
oAjustes:SetTributo(cTrib)
oAjustes:SetCst(cCst)
oAjustes:SetCodDC(cCodCon)
oAjustes:SetOrigem("A") //Origem de redução de base de cálculo
oAjustes:SetAjuBase(.T.)
oAjustes:Ajustar(.F.)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Proc1050
Função que fará processamento das ifnormações do registro 1050.

@author Erick G. Dias
@since 14/12/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function Proc1050(a1050, cCst, nReducao, cCnpj, cRecibo, cInfCompl, nValICMS, cRegime)

//Verifica se já existe informação do registro 1050
nPos := aScan(a1050,{|x| x[2] == cCnpj .ANd. x[16] == cRecibo .AND. x[19] == cRegime  })

IF nPos == 0
	//Adicionar informações no array
	aAdd(a1050, {})
	nPos := Len(a1050)
	aAdd (a1050[npos],"21")//Código de ajuste 4.3.18
	aAdd (a1050[npos],cCnpj)//CNPJ do estabelecimento
	aAdd (a1050[npos],nReducao)//Valor total do ajuste
	aAdd (a1050[npos],RetValAju('01', cCst, nReducao))//Parcela do CST 01
	aAdd (a1050[npos],RetValAju('02', cCst, nReducao))//Parcela do CST 02
	aAdd (a1050[npos],RetValAju('03', cCst, nReducao))//Parcela do CST 03
	aAdd (a1050[npos],RetValAju('04', cCst, nReducao))//Parcela do CST 04
	aAdd (a1050[npos],RetValAju('05', cCst, nReducao))//Parcela do CST 05
	aAdd (a1050[npos],RetValAju('06', cCst, nReducao))//Parcela do CST 06
	aAdd (a1050[npos],RetValAju('07', cCst, nReducao))//Parcela do CST 07
	aAdd (a1050[npos],RetValAju('08', cCst, nReducao))//Parcela do CST 08
	aAdd (a1050[npos],RetValAju('09', cCst, nReducao))//Parcela do CST 09
	aAdd (a1050[npos],RetValAju('49', cCst, nReducao))//Parcela do CST 49
	aAdd (a1050[npos],RetValAju('99', cCst, nReducao))//Parcela do CST 99
	aAdd (a1050[npos],"01")//Inddicador Apropriação				
	aAdd (a1050[npos],cRecibo)//Número do recibo do SPED Fiscal
	aAdd (a1050[npos],cInfCompl)//Informação Complementar
	aAdd (a1050[npos],nValICMS)//Valor do ICMS a recolher da filial
	aAdd (a1050[npos],cRegime)//Regime

Else
	a1050[nPos][3] += nReducao //Total do Ajuste
	a1050[nPos][4] += RetValAju('01', cCst, nReducao) //CST 01
	a1050[nPos][5] += RetValAju('02', cCst, nReducao) //CST 02
	a1050[nPos][6] += RetValAju('03', cCst, nReducao) //CST 03
	a1050[nPos][7] += RetValAju('04', cCst, nReducao) //CST 04
	a1050[nPos][8] += RetValAju('05', cCst, nReducao) //CST 05
	a1050[nPos][9] += RetValAju('06', cCst, nReducao) //CST 06
	a1050[nPos][10] += RetValAju('07', cCst, nReducao) //CST 07
	a1050[nPos][11] += RetValAju('08', cCst, nReducao) //CST 08
	a1050[nPos][12] += RetValAju('09', cCst, nReducao) //CST 09
	a1050[nPos][13] += RetValAju('49', cCst, nReducao) //CST 49
	a1050[nPos][14] += RetValAju('99', cCst, nReducao) //CST 99	

EndIF	

Return

//--------------------------------------------------
/*/{Protheus.doc} RetValAju
Função que retorna o valor de ajuste conforme o CST.

@author Erick G. Dias
@since 14/12/2018
@version 12.1.17
/*/
//--------------------------------------------------
Static Function RetValAju(cCstCmp, cCstAju, nValAju)

Local nVlrReten:= 0

IF cCstCmp == cCstAju
	nVlrReten	:= nValAju
EndIF

Return nVlrReten

//--------------------------------------------------
/*/{Protheus.doc} GetRecibo
Função que buscará o número do recibo de transmissão 
do SPED Fiscal.

@author Erick G. Dias
@since 14/12/2018
@version 12.1.17
/*/
//--------------------------------------------------
Static Function GetRecibo(dDataIni)

Local cRecibo	:= ""

If AliasIndic("F3N") .And. F3N->(MsSeek( xFilial("F3N") + Year2Str(dDataIni) + Month2Str(dDataIni)))
	cRecibo	:= F3N->F3N_RECIBO
EndIF

Return cRecibo

//--------------------------------------------------
/*/{Protheus.doc} GetProcICMS
Função que busca o número de processo da exclusão do ICMS
da base de cálculo de PIS e COFINS

@author Erick G. Dias
@since 20/12/2018
@version 12.1.17
/*/
//--------------------------------------------------
Static Function GetProcICMS()

Local cNProcICMS	:= ''
Local aProcICMS		:= StrTokArr2(GetNewPar("MV_PRICMS",''), "|" ,.T.)

If Len(aProcICMS) >= 4
	cNProcICMS	:= aProcICMS[1]
EndIF

Return cNProcICMS

//--------------------------------------------------
/*/{Protheus.doc} AjuAltRegCx
Função que fará as chamadas de ajuste da contribuição na 
hipótese de alteração de regime de competência para regime de
caixa.

@author Erick G. Dias
@since 21/12/2018
@version 12.1.17
/*/
//--------------------------------------------------
Static Function AjuAltRegCx(aAjuPISCOF, aXFilial, dDataDe, DEBITO)

Local oAjuDeb	:= Nil
Local nX		:= 0

// Se houverem ajustes p/ gerar - mudança de regime -
If Len(aAjuPISCOF) > 0

	oAjuDeb	:= AJUSTEEFD():New()
	oAjuDeb:SetFilial(aXFilial)
	oAjuDeb:SetDtIni(dDataDe)
	oAjuDeb:SetCrdDeb(DEBITO)
	oAjuDeb:LoadCKS()

	For nX := 1 to Len(aAjuPISCOF)
		oAjuDeb:SetTributo(aAjuPISCOF[nX, 1])
		oAjuDeb:SetTpAjust(aAjuPISCOF[nX, 2])
		oAjuDeb:SetCodAju(aAjuPISCOF[nX, 3])
		oAjuDeb:SetNumDoc(aAjuPISCOF[nX, 4])
		oAjuDeb:SetDescAju(aAjuPISCOF[nX, 5])
		oAjuDeb:SetDtRefer(aAjuPISCOF[nX, 6])
		oAjuDeb:SetCodDC(aAjuPISCOF[nX, 7])
		oAjuDeb:SetRegime(aAjuPISCOF[nX, 8])
		oAjuDeb:SetOrigem(aAjuPISCOF[nX, 9])
		oAjuDeb:SetVlAju(Round(aAjuPISCOF[nX, 10], 2))
		oAjuDeb:SetCst(aAjuPISCOF[nX, 11])
		oAjuDeb:SetConta(aAjuPISCOF[nX, 12])
		oAjuDeb:SetInfComp(aAjuPISCOF[nX, 13])
		oAjuDeb:SetBase(aAjuPISCOF[nX, 14])
		oAjuDeb:SetAlq(aAjuPISCOF[nX, 15])
		oAjuDeb:SetTNatRec(aAjuPISCOF[nX, 16])
		oAjuDeb:SetCNatRec(aAjuPISCOF[nX, 17])
		oAjuDeb:Ajustar()
	Next nX

	EndIf

Return

//--------------------------------------------------
/*/{Protheus.doc} EstCrdAgro
Função que buscará as informações das tabelas F3U e F3V 
para realizar os estornos de créditos, referente ao benefício
da agro indústria.

@author Erick G. Dias
@since 06/02/2019
@version 12.1.17
/*/
//--------------------------------------------------
Static Function EstCrdAgro(cPerApu, oAjustes, dDtRef)

Local aVlrCL8 		:= {}
Local aEstCrd		:= {}
Local nX			:= 0
Local nPos			:= 0
Local nValAjuste	:= 0
Local nPercDet		:= 0
Local cDescHP		:= ""
Local cCodCta		:= ""
Local cCodAju		:= ""

//Busca os percentuais dos estornos calculados no período
cAliasF3V	:= QryEstCred("F3V", cPerApu)

//Somente prosseguirá se houver algum percentual de estorno para este período
IF !(cAliasF3V)->(Eof())	

	//Carrega os valores dos créditos processados no período
	aVlrCL8 := oAjustes:GetVlrCL8()		

	//Laço dos valores de créditos calculados no período
	For nX:= 1 to Len(aVlrCL8)
		//Busca o código de crédito + COD BCC na tabela F3U	
		If F3U->(MsSeek( xFilial("F3U") + aVlrCL8[nX][2] + aVlrCL8[nX][8] ))		
			
			//Monto no array aEstCrd os valores de créditos passíveis de estorno por código de crédito e tributo
			nPos:= aScan(aEstCrd,{|x| x[1] == aVlrCL8[nX][1] .AND. x[2] == aVlrCL8[nX][2] })
			
			//Aqui estou acumulando os valores de créditos do período que são passíveis de estorno, por códgo de crédito, para ser utilizado posteriormente no ajustes
			IF nPos > 0
				aEstCrd[npos][3] += aVlrCL8[nX][4]
			Else
				aAdd(aEstCrd,{})
				nPos := Len(aEstCrd)
				aAdd(aEstCrd[npos], aVlrCL8[nX][1])
				aAdd(aEstCrd[npos], aVlrCL8[nX][2])
				aAdd(aEstCrd[npos], aVlrCL8[nX][4])
				aAdd(aEstCrd[npos], 0)
			EndIF

		EndIF

	Next nx

	//Aqui estou atualizando o valor que deverá ser ajustado, aplicando o percentual total do ajuste
	For nX	:= 1 to Len(aEstCrd)
		aEstCrd[nX][3] :=  Round(aEstCrd[nX][3] * (cAliasF3V)->F3V_PEREST  / 100, 2)
		aEstCrd[nX][4] :=  aEstCrd[nX][3] //Esta posição será utilizada como "saldo", para evitar problema de arredondamento.
	Next nX
	
	//Faz laço nos percentuais para disparar os valores de ajustes de redução do crédito de PIS e COFINS
	Do While !(cAliasF3V)->(Eof())		
		
		//Informações da F3V que serão utilizadas para realizar ajuste.
		cDescHP		:= (cAliasF3V)->F3V_DESCHP
		nPercDet	:= (cAliasF3V)->F3V_PERDET
		cCodCta		:= (cAliasF3V)->F3V_CODCTA
		cCodAju		:= (cAliasF3V)->F3V_CODAJU
		
		(cAliasF3V)->(DbSkip())
		
		//Laço nos créditos que foram acumulados por código de crédito
		For nX:= 1 to Len(aEstCrd)
			
			nValAjuste	:= 0
			If (cAliasF3V)->(Eof())
				//Se for o último percentual de detalhamento, então o ajuste será o valor restante no saldo do array , para evitar problema de arredondamento
				nValAjuste	:= aEstCrd[nX][4]
			Else
				//O valor do ajuste será calculado com percentual do detalhamento
				nValAjuste	:= Round(aEstCrd[nX][3] * nPercDet / 100, 2)
				
				//Atualiza controle para evitar eventual erro de arredondamento
				aEstCrd[nX][4] -= nValAjuste
			EndIF			

			//Chama função auxiliar para geração dos ajustes
			AjustePC(oAjustes, CREDITO, aEstCrd[nX][1], REDUCAO, cCodAju, "", cDescHP, nValAjuste, aEstCrd[nX][2], "", cCodCta, "", 0, 0, dDtRef)

		Next nX
		
	EndDo
	
EndIF

(cAliasF3V)->(dbCloseArea())

Return

//--------------------------------------------------
/*/{Protheus.doc} QryEstCred
Função que terá as queries para processar os valores de 
estornos da agro indústria

@author Erick G. Dias
@since 06/02/2019
@version 12.1.17
/*/
//--------------------------------------------------
Static Function QryEstCred(cTab, cPerApu)

Local cAliasRet	:= GetNextAlias()
Local cSelect	:= ""

IF cTab == "F3V"	
	//Tabela com os percentuais de estorno do período	
	cSelect :=	"F3V.F3V_PEREST, F3V.F3V_DESCHP, F3V.F3V_PERDET, F3V.F3V_CODCTA, F3V.F3V_CODAJU"
	
	cFrom := RetSqlName("F3V") + " F3V "

	//Seção do Where da query
	cWhere	:= "F3V.F3V_FILIAL=" + valToSql(xFilial("F3V")) + " AND "
	cWhere  += "F3V.F3V_PERAPU = " + valToSql(cPerApu) + " AND "
	cWhere  += "F3V.D_E_L_E_T_ = ' '"

	//Seção de Order By e eventual Group By
	cOrder	:= " ORDER BY F3V_DESCHP"

	// Preparação da query para execução do BeginSQL
	cSelect := "%" + cSelect + "%"
	cFrom   := "%" + cFrom   + "%"
	cWhere  := "%" + cWhere  + cOrder + "%"	

EndIF

//Executa a query
BeginSql Alias cAliasRet	
    SELECT
        %Exp:cSelect%
    FROM
        %Exp:cFrom%
    WHERE
        %Exp:cWhere%
EndSql

Return cAliasRet

//--------------------------------------------------
/*/{Protheus.doc} AjustePC
Função auxiliar para realizar os ajustes de PIS e COFINS

@author Erick G. Dias
@since 06/02/2019
@version 12.1.17
/*/
//--------------------------------------------------
Static Function AjustePC(oAjustes, cCrdDeb, cTrib, cTpAju, cCodAju, cNumDoc, cDescAju, nValAju, cCodDC, cCST, cConta, cInfComp, nBase, nAlq, dDtRef)

oAjustes:SetCrdDeb(cCrdDeb)
oAjustes:SetTributo(cTrib)
oAjustes:SetTpAjust(cTpAju)
oAjustes:SetCodAju(cCodAju)
oAjustes:SetNumDoc(cNumDoc)
oAjustes:SetDescAju(cDescAju)
oAjustes:SetVlAju(nValAju)
oAjustes:SetCodDC(cCodDC)			
oAjustes:SetCst(cCST)
oAjustes:SetConta(cConta)
oAjustes:SetInfComp(cInfComp)
oAjustes:SetBase(nBase)
oAjustes:SetAlq(nAlq)
oAjustes:SetDtRefer(dDtRef)		
oAjustes:Ajustar()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SldCredDif()
Função retorna o valor do crédito diferido usado até o momento. cOpc = 1
       retorna o valor recebido até o momento do que foi diferido cOpc =2
@author ricardo.cavalcante
@since 12/09/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function SldCredDif(cPerApur,cPerDif,cTipo,cCNPJ,cNatCred)

Local cFiltro	:= ''
Local cSelect	:= ''
Local aRetDif	:= {0,0}	
Local dData     := CtoD("01/"+SUBSTR(cPerApur,1,2)+"/"+ SUBSTR(cPerApur,3,4))-1
Local dDtDifde	:= CtoD("01/"+SUBSTR(cPerDif,1,2)+"/"+ SUBSTR(cPerApur,3,4))
Local dDtDifAte := MonthSum(CtoD("01/"+SUBSTR(cPerDif,1,2)+"/"+ SUBSTR(cPerApur,3,4)),1)-1
Local cQuery	:= GetNextAlias()

If cTipo == 'C'
	cSelect	:= " SUM(F0T.F0T_VLCPRB) VLCRED ,"
Else
	cSelect	:= " SUM(F0T.F0T_VALPIS) VLCRED ," //PARA O F0T.F0T_TIPO  A CRÉDITO DIFERIDO PIS E B CRÉDITO DIFERIDO COFINS O CAMPO F0T.F0T_VALPIS É O VALOR DE CRÉDITO DIFERIDO, E O CAMPO F0T.F0T_VALCOFINS É O PERCENTUAL QUE ESSE CRÉDITO REPRESENTA DA TABELA CFA, POR ESSE MOTIVO USA SEMPRE O CAMPO F0T.F0T_VALPIS NÃO LEVAR EM CNTA O NOME DO CAMPO.
EndIf
cSelect	+= " SUM(SF2.F2_VALBRUT * (F0T.F0T_PERREC / 100))  VLRECEB" // RETORNA O VALOR RECEBIDO ATÉ O MOMENTO DOS TITULOS DIFERIDOS

cFrom   := RetSqlName("F0T") + " F0T "

cInner	:= RetSqlName("SA1") + " SA1 ON(SA1.A1_FILIAL = '" + xFilial("SA1") + "' AND F0T.F0T_CNPJ = SA1.A1_CGC AND SA1.D_E_L_E_T_ = ' '  )"

cInner2	:= RetSqlName("SF2") + " SF2 ON(SF2.F2_FILIAL = '" + xFilial("SF2") + "' AND SA1.A1_COD = SF2.F2_CLIENTE AND SA1.A1_LOJA = SF2.F2_LOJA AND" +;
           " F0T.F0T_NUMNF = SF2.F2_DOC AND F0T.F0T_SER = SF2.F2_SERIE AND SF2.F2_EMISSAO >= '" + %Exp:DToS (dDtDifde)% + "' AND SF2.F2_EMISSAO <= '" +;
		   %Exp:DToS (dDtDifate)% + "' AND SF2.D_E_L_E_T_ = ' ') "

cSelect	:= "%" + cSelect 	+ "%"
cFrom	:= "%" + cFrom		+ "%"
cInner	:= "%" + cInner		+ "%"
cInner2	:= "%" + cInner2	+ "%"

cFiltro = "%"
cFiltro += "F0T.F0T_CNPJ			=   '"	+ cCNPJ    					+ "' AND "
cFiltro += "F0T.F0T_FILIAL			=   '"	+ xFilial('F0T')			+ "' AND "
cFiltro += "F0T.F0T_PER				>=  	  SF2.F2_EMISSAO 			     AND "
cFiltro += "F0T.F0T_PER				<=  '" 	+ %Exp:DToS (dData)%	+     "' AND "	
cFiltro += "F0T.F0T_TIPO 			=   '"	+ cTipo						+ "' AND "
cFiltro += "F0T.F0T_MODELO 			=   '"	+ cNatCred					+ "' AND "
cFiltro += "F0T.D_E_L_E_T_			= ' '"
cFiltro += "%"

BeginSql Alias cQuery
	SELECT			    	 
		%Exp:cSelect%	
	
	FROM   
		%Exp:cFrom%
	
	INNER JOIN
		%Exp:cInner%

	INNER JOIN
		%Exp:cInner2% 
						
	WHERE
		%Exp:cFiltro%	
	
EndSql

aRetDif := Iif(!(cQuery)->(Eof()),{(cQuery)->VLCRED,(cQuery)->VLRECEB},{0,0})

( cQuery )->( dbCloseArea () )

Return aRetDif

//-------------------------------------------------------------------
/*/{Protheus.doc} CPRBxCNO()
Função que executa a query para retornar os valores da apuração de 
CPRB quebrados por CNO
@author Matheus Prada
@since 04/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function CPRBxCNO(cAliasSON, oApurEFD)

Local cSelect	:= ""
Local cFrom		:= ""
Local cWhere	:= ""
Local cGroupBy	:= ""
Local nM996Tpr	:= SuperGetMv("MV_M996TPR",.F.,1)  
Local lCNO		:= .T.

Default cAliasSON := ""

cSelect	:= oApurEFD:GetCmpSFT(nM996Tpr, , , lCNO)

cFrom	:= oApurEFD:GetJoinFrm(nM996Tpr, , , lCNO)

cWhere  := oApurEFD:GetWhrSFT(NFSAIDA)

cGroupBy	:= oApurEFD:GetGrpSFT(nM996Tpr, lCNO)

cWhere := '%' + cWhere + '%'
cGroupBy := '%' + cGroupBy + '%'

BeginSql Alias cAliasSON
	COLUMN FT_DTFIMNT AS DATE
	SELECT
		%Exp:cSelect%

	FROM
		%Exp:cFrom%

	WHERE
		%Exp:cWhere%
		SFT.%NotDel%

	%Exp:cGroupBy%

EndSql

DbSelectArea (cAliasSON) 
(cAliasSON)->(DbGoTop ())

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExigibSusp()

Função que buscará as notas fiscais que possuem processo referenciado no
complemento da nota fiscal, com exigibilidade suspensa, e para os tributos
de PIS e COFINS.

@author Erick G Dias
@since 22/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ExigibSusp(oApurEFD, nM996Tpr,dDataDe, dDataAte, cOpc,lBilhete,cNrLivro)

Local cFrom			:= ""
Local cSlctSFT		:= ""
Local cFiltro		:= ""
Local cAliasSFT		:= GetNextAlias()
Local lPeWhere  	:= ExistBlock("EFDCON01")
Local aExigiSusp 	:= {}

Private oHExigSusp	:= HMNew() //Cria o Hash para apoio ao array aExigiSusp

Default lBilhete 	:= .F.
Default cNrLivro	:= ""

If cOpc == "NF"
	cFrom    := oApurEFD:GetJoinFrm(nM996Tpr,lPeWhere,NFSAIDA,, .T.)
	cSlctSFT := oApurEFD:GetCmpSFT(nM996Tpr,.F.,lPeWhere, ,.T.)
	cFiltro  := oApurEFD:GetWhrSFT(NFSAIDA,,,,, .T.)
	cFiltro  := '%' + cFiltro + '%'

	BeginSql Alias cAliasSFT	
		COLUMN FT_EMISSAO AS DATE	
		SELECT
			%Exp:cSlctSFT%

		FROM
			%Exp:cFrom%

		WHERE
			%Exp:cFiltro%
			SFT.%NotDel%	

	EndSql
ElseIf cOpc = "CUPOM"	//Cupom 
	
	cAliasSFT	:= FSA001QECF(.F.,cNrLivro,dDataDe,dDataAte,lBilhete, .T.)

EndIF

//Processando notas que possuem processo referenciado com exigibilidade suspensa sem transito em julgado.
(cAliasSFT)->(DbGoTop ())
Do While !(cAliasSFT)->(Eof ())		
	If !Empty((cAliasSFT)->CID_CST) .AND. !Empty((cAliasSFT)->CCF_TRIB) .AND. ( cOpc = "CUPOM" .OR. oApurEFD:ChkRegraNf((cAliasSFT)->FT_ESPECIE,(cAliasSFT)->FT_CFOP,NFSAIDA,,,(cAliasSFT)->FT_CSTPIS) )

		//Processo informações das regras informadas na tabela CDI		
		ProcExigi(@aExigiSusp, cAliasSFT, cAliasSFT, cAliasSFT, dDataDe, dDataAte, 1, "",.F.,.T.)

	EndiF

	(cAliasSFT)->(DbSkip ())			
EndDo

DbSelectArea( cAliasSFT )
( cAliasSFT )->( dbCloseArea () )

//Função para gravação da tabewla CIE
If Len(aExigiSusp) > 0
	x001GrvCIE(aExigiSusp, dDataDe)
	aSize(aExigiSusp,0) //Limpo o array que não era limpo
	aExigiSusp:=Nil
EndIf

 // Limpa os dados do HashMap
  HMClean(oHExigSusp)
  // Libera o objeto de HashMap
  FreeObj(oHExigSusp)
  oHExigSusp := Nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} AddExigSusp()

Função que trata os valores de cabeçalho do registro 1011

@author Erick G Dias
@since 22/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function AddExigSusp(aExigiSusp, cAliasSFT, cAliasCCF, cCstSusp, nBaseSusp, nAliqSusp, nValSusp, cTrib, cCodRec, nPerc, cChaveCL1)

Local cKey		:= (cAliasSFT)->FT_NFISCAL+(cAliasSFT)->FT_SERIE+(cAliasSFT)->FT_CLIEFOR+(cAliasSFT)->FT_LOJA+;
							(cAliasSFT)->FT_ITEM+(cAliasCCF)->CCF_NUMERO+(cAliasCCF)->CCF_TIPO+(cAliasCCF)->CCF_INDAUT+;
							(cAliasCCF)->CCF_IDITEM+(cAliasCCF)->CCF_NATJU
Local nPosCab	:= 0
Local lRet	:=.F.							
//Verifica se a combinação abaixo já existe no array/hash
lRet := HMGet(oHExigSusp, cKey, @nPosCab)
								 
If !lRet
	aAdd(aExigiSusp, {})
	nPosCab := Len(aExigiSusp)
	HMSet(oHExigSusp, cKey, nPosCab) //adiciono a chave e a posição 

	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_NFISCAL)	//01
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_SERIE)  
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_CLIEFOR)
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_LOJA)	
	aAdd(aExigiSusp[nPosCab], (cAliasCCF)->CCF_NUMERO)	//05
	aAdd(aExigiSusp[nPosCab], (cAliasCCF)->CCF_TIPO)		
	aAdd(aExigiSusp[nPosCab], (cAliasCCF)->CCF_NATJU)	
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_ITEM)		
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_EMISSAO)	
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_VALCONT * iif(empty(nPerc),1,nPerc))	//10
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_CSTPIS)
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_BASEPIS * nPerc)
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_ALIQPIS)
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_VALPIS * nPerc)	
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_CSTCOF)	//15
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_BASECOF * nPerc)
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_ALIQCOF)
	aAdd(aExigiSusp[nPosCab], (cAliasSFT)->FT_VALCOF * nPerc)
	aAdd(aExigiSusp[nPosCab], cCstSusp)
	aAdd(aExigiSusp[nPosCab], 0)	//20
	aAdd(aExigiSusp[nPosCab], 0)
	aAdd(aExigiSusp[nPosCab], 0)	
	aAdd(aExigiSusp[nPosCab], cCstSusp)	                      
	aAdd(aExigiSusp[nPosCab], 0)	
	aAdd(aExigiSusp[nPosCab], 0)	//25
	aAdd(aExigiSusp[nPosCab], 0)		
	aAdd(aExigiSusp[nPosCab], "")		
	aAdd(aExigiSusp[nPosCab], "")		
	aAdd(aExigiSusp[nPosCab], (cAliasCCF)->CCF_IDITEM)		
	aAdd(aExigiSusp[nPosCab], cChaveCL1)	//30
	aAdd(aExigiSusp[nPosCab], (cAliasCCF)->CCF_INDAUT)

EndiF

If cTrib == "PIS"
	//Atualizo os valores da exigibilidade suspenso
	aExigiSusp[nPosCab][20] += nBaseSusp
	aExigiSusp[nPosCab][21] := nAliqSusp
	aExigiSusp[nPosCab][22] += nValSusp
	aExigiSusp[nPosCab][27] := cCodRec
ElseIf cTrib == "COFINS"
	//Atualizo os valores da exigibilidade suspenso
	aExigiSusp[nPosCab][24] += nBaseSusp
	aExigiSusp[nPosCab][25] := nAliqSusp
	aExigiSusp[nPosCab][26] += nValSusp
	aExigiSusp[nPosCab][28] := cCodRec
EndIF

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} QryCDGCaixa()

Função que realiza que buscará os processos referenciados informados na CDG 
no complemento do documento fiscal por item, bem como informações da tabela CID 
para exigibilidade suspensa

@author Erick G Dias
@since 29/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function QryCDGCaixa(aPar, lTabCID)

Local cSelect		:= ""
Local cFrom			:= ""
Local cWhere		:= ""
Local ApeF500		:= {}
Local cAliasCDG		:= GetNextAlias()

cSelect	:=	"%CDG.CDG_FILIAL,CDG.CDG_TPMOV,CDG.CDG_DOC,CDG.CDG_SERIE,CDG.CDG_CLIFOR,CDG.CDG_LOJA,CDG.CDG_PROCES,CDG.CDG_TPPROC,CDG.CDG_IFCOMP,CDG.CDG_PROCES,CDG.CDG_TPPROC,"
cSelect +=  "CCF.CCF_NUMERO, CCF.CCF_IDSEJU,CCF.CCF_IDVARA, CCF.CCF_NATJU,CCF.CCF_DESCJU, CCF.CCF_DTSENT,CCF.CCF_NATAC, CCF.CCF_DTADM,CCF.CCF_TPCOMP, CCF.CCF_TRIB, CCF.CCF_TIPO, CCF.CCF_IDITEM, CCF.CCF_INDAUT"

If lTabCID
	//Adiciona os campos da tabela CID
	cSelect +=  ",CID.CID_CST, CID.CID_ICMS, CID.CID_ISS, CID.CID_REDUC, CID.CID_ALIQ, CID.CID_CODREC"
EndIf

cSelect += "%"

cFrom	:=	""+RetSqlName("CDG")+" CDG "
cFrom	+=	"INNER JOIN "+RetSqlName("CCF")+" CCF ON CCF.CCF_FILIAL='"+xFilial("CCF")+"' AND CDG.CDG_PROCES=CCF.CCF_NUMERO AND CDG.CDG_TPPROC=CCF.CCF_TIPO AND CCF.CCF_IDITEM=CDG.CDG_ITPROC AND CCF.D_E_L_E_T_=' '"

If lTabCID
	//Adiciona left join com tabela CID
	cFrom	   +="LEFT JOIN "+RetSqlName("CID")+" CID ON(CID.CID_FILIAL='"+xFilial("CID")+"'  AND CID.CID_NUMERO=CCF.CCF_NUMERO  AND CID.CID_TIPO=CCF.CCF_TIPO AND CID.CID_INDAUT=CCF.CCF_INDAUT AND CID.CID_IDITEM = CCF.CCF_IDITEM AND CID.D_E_L_E_T_=' ') "	
EndIF


cWhere	:=	"CDG.CDG_FILIAL='"+xFilial("CDG")+"' AND "
cWhere	+=	"CDG.CDG_TPMOV   ='"+aPar[1]+"' AND "
cWhere	+=	"CDG.CDG_DOC     ='"+aPar[2]+"' AND "
cWhere	+=	"CDG.CDG_SERIE   ='"+aPar[3]+"' AND "
cWhere	+=	"CDG.CDG_CLIFOR  ='"+aPar[4]+"' AND "
cWhere	+=	"CDG.CDG_LOJA    ='"+aPar[5]+"' AND "
cWhere	+=	"CDG.CDG_ITEM    ='"+aPar[6]+"' AND "
cWhere	+=	"CDG.D_E_L_E_T_=' '"

If ExistBlock("SPDF500C")  // PE para SCP com Filial unica - TTUXH9
	ApeF500 := ExecBlock("SPDF500C", .F. , .F. , {cFrom,cWhere})
	cFrom 	:= ApeF500[1]
	cWhere	:= ApeF500[2]
Endif

cFrom 	:= "%"+cFrom+"%"
cWhere	:= "%"+cWhere+"%"

BeginSql Alias cAliasCDG    	    
	SELECT			    	 
		%Exp:cSelect%		
	FROM 
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%		
EndSql

Return cAliasCDG

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcExigi()

Função que fará o processamento dos valores da Exigibilidade suspensa, interpretando as regras
definidas na tabela CID, conforme determinação do processo judicial

@author Erick G Dias
@since 30/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ProcExigi(aExigiSusp, cAliasCID, cAliasCCF, cAliasSFT, dDataDe, dDataAte, nPercCaixa, cChaveCL1, lCaixa, lExigSusp)

Local cCstSusp		:= ""
Local cCstOri		:= ""
Local cTrib			:= ""
Local nBCSusp		:= 0
Local nAliqSusp		:= 0
Local nValorSusp	:= 0
Local nPercDev 		:= 1
Local nPercExig		:= 1

Default nPercCaixa	:= 1
Default cChaveCL1	:= ""
Default lCaixa		:= .F.
Default lExigSusp	:= .F.

cTrib		:= Iif((cAliasCCF)->CCF_TRIB == "7","PIS","COFINS")
cCstSusp    := (cAliasCID)->CID_CST
cCstOri		:= Iif(cTrib == "PIS",(cAliasSFT)->FT_CSTPIS,(cAliasSFT)->FT_CSTCOF)
nBCSusp		:= Iif(cTrib == "PIS",(cAliasSFT)->FT_BASEPIS,(cAliasSFT)->FT_BASECOF)
nAliqSusp	:= Iif(cTrib == "PIS",(cAliasSFT)->FT_ALIQPIS,(cAliasSFT)->FT_ALIQCOF)
nValorSusp	:= Iif(cTrib == "PIS",(cAliasSFT)->FT_VALPIS,(cAliasSFT)->FT_VALCOF)

If !lCaixa
	//Verifica se a nota foi devolvida dentro do período
	if !lExigSusp .or. (lExigSusp .and. (cAliasSFT)->FTTEMDEV == "D") //quando for Exigibilidade suspensa, o alias ja terá se aquela nota possui devoluções para entrar
		nPercDev -= FindDev({(cAliasSFT)->FT_NFISCAL, ;
								(cAliasSFT)->FT_SERIE, ;
								(cAliasSFT)->FT_CLIEFOR, ;
								(cAliasSFT)->FT_LOJA, ;
								(cAliasSFT)->FT_ITEM, ;
								(cAliasSFT)->FT_QUANT, ;
								dDataDe, ;
								dDataAte })
	endif
	nPercExig	:= nPercDev

	//Deduzo o valor da devolução na base e valor
	nBCSusp 	*= nPercDev
	nValorSusp  *= nPercDev
EndIF

If !Empty(cCstSusp)

	//Alíquota zero, valor zero e mesma base de cálculo, aqui a exigibilidade é integral				
	//Aqui foi suspenso integralmente, terá base, alíquota e valor zerado, uma vez que a exigibilidade também é integral
	//Para os CSTs 04/05/06/07/08/09/49, por se tratar de suspensão integral não farei nenhum cálculo.			
	If cCstSusp $ "01/02" .AND. cCstOri <> "03" //Aqui como possui CST tributado, significa que a exigibilidade é parcial. Não se aplica para operações com Pauta, já que a base é em quantidade e não daria para reduzir base ou mesmo subtrair o ICMS/ISS
		//Subtrair ICMS/ da base de cálculo
		If (cAliasCID)->CID_ICMS == "2" .AND. (cAliasSFT)->FT_TIPO <> "S"
			nBCSusp -= ( (cAliasSFT)->FT_VALICM * nPercDev )
		Endif

		//Subtrair ISS da base de cálculo
		If (cAliasCID)->CID_ISS == "2" .AND. (cAliasSFT)->FT_TIPO == "S"
			nBCSusp -= ( (cAliasSFT)->FT_VALICM * nPercDev )
		Endif

		// Percentual de redução de base de cálculo
		If (cAliasCID)->CID_REDUC > 0
			nBCSusp *= (1 - ((cAliasCID)->CID_REDUC/100))
		EndIf

		//Alíquota será informada no cadastro. Somente considera da cadastro se estiver preenchida.
		If (cAliasCID)->CID_ALIQ > 0
			nAliqSusp	:= (cAliasCID)->CID_ALIQ
		EndIF

		//Cálculo do valor da exigibilidade suspensa
		nValorSusp	:= Round(nBCSusp * nAliqSusp / 100,2)

	EndIf

	//Aqui aplica percentual de baixa caso seja processo no regime de caixa
	If lCaixa
		nPercExig	:= nPercCaixa 
		nBCSusp     *= nPercCaixa 
		nValorSusp  *= nPercCaixa 	
	EndIF

	//Adiciona valores calculados da exigibilidade suspensa
	AddExigSusp(@aExigiSusp, cAliasSFT, cAliasCCF, cCstSusp, nBCSusp, nAliqSusp, nValorSusp, cTrib, (cAliasCID)->CID_CODREC, nPercExig, cChaveCL1)
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FindDev()

Função que verifica se a nota foi devolvida dentro do período, e retorna
o percentual de devolução.

@author Erick G Dias
@since 31/10/2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function FindDev(aPar )

Local nPerc			:= 0
Local cSelect		:= ""
Local cFrom			:= ""
Local cWhere		:= ""
Local cAliasSFT		:= GetNextAlias()

cSelect	:=	"%SUM(SFT.FT_QUANT) FT_QUANT%"
cFrom	:=	""+RetSqlName("SFT")+" SFT "

cWhere	:=	"SFT.FT_FILIAL		= '"+xFilial("SFT")+"' AND "
cWhere	+=	"SFT.FT_NFORI   	='"+aPar[1]+"'         AND "
cWhere	+=	"SFT.FT_SERORI  	='"+aPar[2]+"'         AND "
cWhere	+=	"SFT.FT_CLIEFOR     ='"+aPar[3]+"'         AND "
cWhere	+=	"SFT.FT_LOJA     	='"+aPar[4]+"'         AND "
cWhere	+=	"SFT.FT_ITEMORI   	='"+aPar[5]+"'         AND "
cWhere	+=	"SFT.FT_ENTRADA     >='"+DTOS(aPar[7])+"'  AND "
cWhere	+=	"SFT.FT_ENTRADA     <='"+DTOS(aPar[8])+"'  AND "
cWhere	+=	"SFT.FT_DTCANC      =' '                   AND "
cWhere	+=	"SFT.FT_TIPO        ='D'                   AND "
cWhere	+=	"SFT.D_E_L_E_T_		=' '"

cFrom 	:= "%"+cFrom+"%"
cWhere	:= "%"+cWhere+"%"

BeginSql Alias cAliasSFT    	    
	SELECT			    	 
		%Exp:cSelect%		
	FROM 
		%Exp:cFrom%
	WHERE
		%Exp:cWhere%		
EndSql

If !(cAliasSFT)->(Eof ())
	//Obtenho o percentual de devolução através da quantidade da nota original e da nota de devolução
	nPerc := ( ( (cAliasSFT)->FT_QUANT * 100 ) / aPar[6] ) / 100
EndIF

DbSelectArea( cAliasSFT )
( cAliasSFT )->( dbCloseArea () )

Return nPerc


//-------------------------------------------------------------------
/*/{Protheus.doc} A001DifCPB()
Função que irá buscar valores de diferimento dos débitos para serem processados
na apuração

@param		dDataDe	-Data inicial do período de apuração
			dDataAte	-Data final do período de apuração
			aXFilial	-Array com conteúdo do xFilial das tabelas da apuração			

@author Thiago Y.M.N - Shiny
@since 26/03/2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function A001DifCPB(dDataDe,dDataAte,aXFilial, aParSX1)
Local cAliasCFA	:= 'CFA'
Local cAliasCFB	:= 'CFB'
Local aTpContr	:=	{"CPR"}
Local cSelect	:= ''
Local cWhere	:= ''
Local cPeriod	:= Substr(DTOS(dDataDe),5,2)+Substr(DTOS(dDataDe),1,4)
Local nCont		:= 0
Local lNewProc	:= ISA001NDIF()   
Local oCPRB		:= CPRBEFD():New()

For nCont := 1 to Len(aTpContr)
	
	cAliasCFA	:=	GetNextAlias()
	
	cSelect		:=	"%CFA.CFA_CODCON, CFA.CFA_TPCON, CFA.CFA_CNPJ, CFA.CFA_TOTVEN, CFA.CFA_VLNREC, CFA.CFA_CONDIF, "
	cSelect		+=	"CFA.CFA_PERAPU, CFA.CFA_ALIQ, CFA_CREDIF, CFA_CODCRE%"
	
	cWhere		:=	"%CFA.CFA_FILIAL = '"+xFilial("CFA")+"' AND "
	cWhere		+=	"CFA.CFA_PERAPU  = '"+cPeriod+"' AND "
	cWhere		+=	"CFA.CFA_TPCON   = '"+aTpContr[nCont]+"' AND "
	
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
		oCPRB:SetDtIni(dDataDe)
		oCPRB:SetFilial(aXFilial)					

		oCPRB:SetCodRec(aParSX1[16]) 
        oCPRB:SetTpAju(REDUCAO)
        oCPRB:SetValAju((cAliasCFA)->CFA_CONDIF)
        oCPRB:SetCodAjus('08')
        oCPRB:SetNumero("")
        oCPRB:SetDescr("Diferimento da CPRB ")		
		oCPRB:SetDtRefer(lastDay(dDataDe))
        oCPRB:GravaAju()	
        oCPRB:AtualizaCPRB()
        oCPRB:Clear()				
		
		(cAliasCFA)->(DbSkip())
	EndDo
	
	oCPRB:FechaAlias(cAliasCFA)
	
	cAliasCFB	:=	GetNextAlias()
	cSelect		:=	"%CFB.CFB_CODCON, CFB.CFB_TPCON, CFB.CFB_DTPGTO, CFB.CFB_PERDIF, CFB.CFB_CONREC, "
	cSelect		+=	"CFB.CFB_VLRREC,CFB.CFB_PERAPU, CFB.CFB_ALIQ,CFB.CFB_NATCRE, CFB.CFB_CREDES%"
	cWhere		:=	"%CFB.CFB_FILIAL = '"+xFilial("CFB")+"' AND "
	cWhere		+=	"CFB.CFB_PERAPU  = '"+cPeriod+"' AND "
	cWhere		+=	"CFB.CFB_TPCON   = '"+aTpContr[nCont]+"' AND "

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
        
		oCPRB:SetDtIni(dDataDe)
		oCPRB:SetFilial(aXFilial)					
		
		oCPRB:SetCodRec(aParSX1[16]) 
        oCPRB:SetTpAju(ACRESCIMO)
        oCPRB:SetValAju((cAliasCFB)->CFB_CONREC)
        oCPRB:SetCodAjus('09')
        oCPRB:SetNumero("")
        oCPRB:SetDescr("Diferimento da CPRB do periodo anterior")		
		oCPRB:SetDtRefer(lastDay(dDataDe))
        oCPRB:GravaAju()	
        oCPRB:AtualizaCPRB()
        oCPRB:Clear()				
		
		(cAliasCFB)->(DbSkip())
	EndDo
	
	oCPRB:FechaAlias(cAliasCFB)

Next nCont

FreeObj(oCPRB)
oCPRB := nil

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CheckThread()
Função que irá Checar quantras Threads estão ativas para "PREPROCEFD"



@author Rafael Oliveira
@since 10/06/2021
@version 12.1.27
/*/
//-------------------------------------------------------------------

Static Function CheckThread()
Local aUserInfo := {}
Local aThreads	:= {}
Local nX		:= 0

	// Retorna um array multidimensional com as informações de cada um do processos em execução
	aUserInfo := GetUserInfoArray()
	
	//Adiciona no Array quando for Thread do EFD Contribuições
	For nX := 1 to Len(aUserInfo)
		IF Upper(aUserInfo[nX][5]) == Upper("PREPROCEFD")
			Aadd(aThreads,aUserInfo[nX][3])
		Endif
	Next

	aSize(aUserInfo,0)	
Return aThreads
