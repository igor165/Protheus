#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PLSA260.CH"
//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260MVC
Funcao para abrir a tela de cadastro
@author Totver
@since 26/07/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260MVC(lAutomato)
LOCAL cFil260    := ""
LOCAL aCores 	 := {}
LOCAL nX 		 := 0

Private cCodFor	:= ''
Private inclui   := .F.
Private lPrim260 := .F.
Private aCdCores := {}
Private cFilBA1	 := ""
Private aRotina  := {}
Private cKeySubCon := BQC->BQC_CODIGO+BQC->BQC_NUMCON+BQC->BQC_VERCON+BQC->BQC_SUBCON+BQC->BQC_VERSUB
Default lAutomato	:= .F.

	oBrowse := FWmBrowse():New()
	aRotina := MenuDef()
	oBrowse:SetAlias( 'BA1' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:setMainProc("PLSA260MVC")	
	oBrowse:SetMenuDef( 'PLSA260MVC' )

	If lJuridico .and. !lAmbos
  	                
		cFil260 := "BA1_FILIAL = '" + xFilial("BA1") + "' AND BA1_CODINT = '"+Left(BQC->BQC_CODIGO,4)+"' AND BA1_CODEMP = '"+Substr(BQC->BQC_CODIGO,5,4)+"' "
		cFil260 += "AND BA1_CONEMP = '"+BQC->BQC_NUMCON+"' AND BA1_VERCON = '"+BQC->BQC_VERCON+"' "
		cFil260 += "AND BA1_CONEMP = '"+BQC->BQC_NUMCON+"' AND BA1_VERCON = '"+BQC->BQC_VERCON+"' "
		cFil260 += "AND BA1_SUBCON = '"+BQC->BQC_SUBCON+"' AND BA1_VERSUB = '"+BQC->BQC_VERSUB+"' "
		cFil260 += "AND D_E_L_E_T_ = ' '"

		oBrowse:SetDescription(Posicione("BG9",1,xFilial("BG9")+BQC->(BQC_CODIGO),"BG9_DESCRI")) 
	
	Elseif !lJuridico .and. !lAmbos
 
		cFil260 := "BA1_CODINT = '"+BG9->BG9_CODINT + "' AND BA1_CODEMP = '"+BG9->BG9_CODIGO+"' "

   		oBrowse:SetDescription(BG9->BG9_DESCRI)
    
	Endif

	cFilBA1:="@"+cFil260

	
	BA1->(DbSetOrder(1))

	If lAmbos
		BA1->(MsSeek(xFilial("BA1")))
	Else
		oBrowse:SetFilterDefault(cFilBA1)
	EndIF

	Pl260Cores(@aCores,@aCdCores)

	If !ExistBlock('PL260COR')
		oBrowse:AddLegend("PLLegBloq()=='BR_VERMELHO'", "RED"	 , 'Beneficiario Bloqueado')//"Pendente com a Operadora"
		oBrowse:AddLegend("PLLegBloq()=='BR_VERDE'"   , "GREEN"	 , 'Beneficiario ativo')//"Pendente com a Operadora"
		oBrowse:AddLegend("PLLegBloq()=='BR_AMARELO'" , "YELLOW" , 'Beneficiario com bloqueio futuro')//"Pendente com a Operadora"
		oBrowse:AddLegend("PLLegBloq()=='BR_BRANCO'"  , "WHITE"	 , 'Inclusão futura')//"Pendente com a Operadora"		
		If(!lAutomato,oBrowse:Activate(),)
	Else
		For nX:= 1 to Len(aCores)
			oBrowse:AddLegend(aCores[nx,1], aCores[nx,2]	, '')
		Next
	    oBrowse:Activate()

	Endif
	
Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260MVC 
@author  Totver
@version P12
@since   26/07/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina  	:= {}

aBenefMenu := {	{ 'Incluir Titular'	  	,"PLSA260VLMVC(3)"	, 0, 3, 0, NIL },;  	
				{ 'Incluir Dependente'	,"PLA260VLDEP(3)"	, 0, 3, 0, NIL },;  	
				{ 'Visualizar'			,"PLSACHKMENU(1)"	, 0, 2, 0, NIL },;	
				{ 'Alterar'	  			,"PLSACHKMENU(4)"	, 0, 4, 0, NIL },;  	
				{ 'Excluir'	 		 	,"PLSACHKMENU(5)"	, 0, 5, 0, NIL }} 

//Abre BA1 em edição com campos especificos 
aBenefBA1 := {	{ OemtoAnsi('Dados Pessoais'),        'PLSA260MENU(9)',  0, 4 },;  	
				{ OemtoAnsi('Relativos ao Plano'),    'PLSA260MENU(10)', 0, 4 },;
				{ OemtoAnsi('Dados da Cobrança'),     'PLSA260MENU(11)', 0, 4 },;
				{ OemtoAnsi('Dados da ANS'),          'PLSA260MENU(12)', 0, 4 },; 
				{ OemtoAnsi('Outros Dados'),          'PLSA260MENU(13)', 0, 4 },;
				{ OemtoAnsi('Regras de Parcelamento'),'PLSA260MENU(14)', 0, 4 },;
				{ OemtoAnsi('Outras Informações'),    'PLSA260MENU(15)', 0, 4 } } 
				
//Abre outroas tabelas relacionadas a BA1
aBenefRel  := {	{ OemtoAnsi('Doenças Pré-Existentes')	       		   , "PLSA260MENU(33)" , 0 , 2 },;  	
				{ OemtoAnsi('Documentos Obrigatórios')        		   , "PLSA260MENU(28)" , 0 , 4 },; 
				{ OemtoAnsi('Opcional do Beneficiario')                , 'PLSA260MENU(18)' , 0 , 4 },; 
				{ OemtoAnsi('Gratuidade do Beneficiario') 	           , 'PLSA260MENU(19)' , 0 , 4 },;
				{ OemtoAnsi('Cobertura - Grupos Determinados')         , 'PLSA260MENU(24)' , 0 , 4 },;
				{ OemtoAnsi('Cobertura - Procedimentos')               , 'PLSA260MENU(25)' , 0 , 4 },;
				{ OemtoAnsi('Cobertura - Grupo de Quantidade')         , 'PLSA260MENU(26)' , 0 , 4 },;
				{ OemtoAnsi('Cobertura - Classe de Carência')          , 'PLSA260MENU(27)' , 0 , 4 },;
				{ OemtoAnsi('Faixa Etaria Especifica do Beneficiario') , "PLSA260MENU(29)" , 0 , 4 },;
				{ OemtoAnsi('Situações Adversas') 					   , "PLSA260MENU(34)" , 0 , 4 },;
				{ OemtoAnsi('Histórico Bloqueio do Usuário') 		   , "PLSA260MENU(35)" , 0 , 4 },;
				{ OemtoAnsi('Cancelamento Reajuste') 				   , "" 			   , 0 , 5 },;
				{ OemtoAnsi('(Des)Bloqu. &Usu')						   , 'PLBlqUMenu'	   , 0 , 4 }}  	 //(Des)Bloqu. &Usu  				

//Abre BA3 em edição com campos especificos 
aFamBA3 := {	{ OemtoAnsi('Demais Dados Cadastrais'),     'PLSA260MENU(8)', 0, 4 },;
				{ OemtoAnsi('Dados do Plano da Familia'),   'PLSA260MENU(5)', 0, 4 },;
				{ OemtoAnsi('Dados da Cobrança da Familia'),'PLSA260MENU(2)', 0, 4 },;
				{ OemtoAnsi('Logs'),                        'PLSA260MENU(4)', 0, 4 },;
				{ OemtoAnsi('Dados da ANS'),                'PLSA260MENU(6)', 0, 4 },;				
				{ OemtoAnsi('Dados Comerciais da Familia'), 'PLSA260MENU(3)', 0, 4 },;
				{ OemtoAnsi('Outros Dados'),                'PLSA260MENU(7)', 0, 4 }}
					
// Abre o historico de parcelamento, Abatimento de Saldo, Transferência de Saldo
aHistParc := {}
aHistParc := {  { 'Histórico', 				'PLSA260MENU(36)'	, 0, 4 },;
				{ 'Abatimento de Saldo', 	'PL260ABASMVC(.F.)'		, 0, 4 },;
				{ 'Transferência de Saldo', 'PL260SALDMVC(.F.)'		, 0, 4 }}				

//Abre outroas tabelas relacionadas a BA3
aFamRel := {	{ OemtoAnsi('Forma de Cobrança da Familia')             , 'PLSA260MENU(1)', 0, 4 },;
				{ OemtoAnsi('Taxa de Adesão')                           , 'PLSA260MENU(16)' , 0 , 4 },; 
				{ OemtoAnsi('Gratuidade') 	         				    , 'PLSA260MENU(17)' , 0 , 4 },;
				{ OemtoAnsi('Grupo de Cobertura - Cobertura')   	    , 'PLSA260MENU(20)' , 0 , 4 },;
				{ OemtoAnsi('Grupo de Cobertura - Procedimentos')   	, 'PLSA260MENU(21)' , 0 , 4 },;
				{ OemtoAnsi('Grupo de Cobertura - Grupo de Quantidade')	, 'PLSA260MENU(22)' , 0 , 4 },;
				{ OemtoAnsi('Grupo de Cobertura - Classe de Carência') 	, 'PLSA260MENU(23)' , 0 , 4 },;
				{ OemtoAnsi('Valor de Cobrança') 						, 'PLSA260VCB' 		, 0 , 4 },;
				{ OemtoAnsi('Histórico Financeiro') 					, 'PLSA260MENU(30)'	, 0 , 4 },;
				{ OemtoAnsi('Histórico Cobrança Carteirinha')			, 'PLSA260MENU(31)'	, 0 , 4 },;
				{ OemtoAnsi('Histórico Bloqueio da Família') 			, 'PLSA260MENU(32)'	, 0 , 4 },;
				{ OemtoAnsi('Parcelamento') 							, aHistParc			, 0 , 2, , .F. },;
				{ OemtoAnsi('(Des)Bloqu. &Fam')							,'PLBlqFMenu' 		, 0 , 4  }} //(Des)Bloqu. &Fam

If FindFunction("PLTermConsBenef")
	aAdd(aFamRel, {OemtoAnsi('Termo de Consentimento de Dados Pessoais'), 'PLTermoBenef', 0, 2}) 
EndIf

aBenef :=	{}
aBenef := {	{ 'Beneficiários'					, aBenefMenu	, 0, 2			},;
			{ 'Dados Cadastrais do Beneficiario', aBenefBA1 	, 0, 2, , .F.	},;
			{ 'Demais Dados do Beneficiario'    , aBenefRel 	, 0, 2, , .F.	}}


aFam := {}
aFam := {{'Dados Cadastrais da Família', aFamBA3, 0, 2,	, .F.},;
		{ 'Demais Dados da Família'    , aFamRel, 0, 2,	, .F.}}	

aBot := {}
aBot := {	{ OemtoAnsi('Posicao Financeira') , 'PosFinBenef()', 0, 2 },;
			{OemtoAnsi("Interc Hab."), 'VIEWDEF.PLSA272', 0,2 }}  //Intercambio Habitual

aadd(aRotina,{ 'Familia'    			 , aFam  		, 0 , 0, , .F.} )
aadd(aRotina,{ 'Outros'					 , aBot 		, 0 , 1, , .F.} ) 
aadd(aRotina,{ 'Beneficiario'			 , aBenef		, 0 , 2, , .F.} )

If ExistBlock("PLS260INC")
	aadd(aRotina,{ OemtoAnsi("Reemissao")	, 'PLSA260REM' , 0 , 4    	}) //"Reemissao"
Endif

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260MVC 
@author  Totver
@version P12
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()											
	Static oModel	
	Local aCampBA3:={}			
	Local aCampBA1:={}			
	Local oStruBA3 := FWFormStruct( 1, 'BA3'    , { |cCampo| PLS260CamMenu('BA3',cCampo,'S',@aCampBA3) })
	Local oStruBA1 := FWFormStruct( 1, 'BA1'    , { |cCampo| PLS260CamMenu('BA1',cCampo,'S',@aCampBA1) })
	Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC","BA1_CONEMP","BA1_VERCON","BA1_SUBCON","BA1_VERSUB"} // Campos a serem adicionado na estrutura
	Local nNx
	Local oEvent   := PLSA260EVDEF():New()	
	
	//Proteção ao instanciar a classe, sem a variável private lJuridico
	lJuridico := iif( type("lJuridico") <> "L", .f.,  lJuridico) 

	oModel := MPFormModel():New('PLSA260MVC')	
	inclui := .F.

	oStruBA1:RemoveField( 'BA1_EQUIPE') 
	oStruBA1:RemoveField( 'BA1_NOMEQ' )
	oStruBA1:RemoveField( 'BA1_CODVEN')
	oStruBA1:RemoveField( 'BA1_NOMVEN')
	oStruBA1:RemoveField( 'BA1_NOMVE2')
	oStruBA1:RemoveField( 'BA1_CODVE2')	
	oStruBA3:RemoveField( 'BA3_EQUIPE')
	oStruBA3:RemoveField( 'BA3_NOMEQ' )

	If lJuridico
		BG9->(DbSelectArea("BG9"))
		BG9->(DbSeek(xFilial("BG9")+ BQC->BQC_CODIGO))
	Endif	

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(1,oStruBA1,aCampos[nNx]) 
	Next
	
	//Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( 'BA1MASTER',NIL, oStruBA1 )
    oModel:AddFields( 'BA3DETAIL', 'BA1MASTER', oStruBA3) 
		
	oModel:GetModel( "BA3DETAIL" ):SetOptional( .T. )

	oModel:SetPrimaryKey({})

	//Faz relaciomaneto entre os componentes do model
	oModel:SetRelation( 'BA3DETAIL', { { 'BA3_FILIAL', 'xFilial( "BA3" )' }, { 'BA3_CODINT', 'BA1_CODINT'}, { 'BA3_CODEMP', 'BA1_CODEMP'}, { 'BA3_MATRIC', 'BA1_MATRIC' } }, BA3->( IndexKey( 1 ) ) )

	//Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( FunDesc() )	

	//Adiciona a descricao do Componente do Modelo de Dados
	oModel:GetModel( 'BA1MASTER' ):SetDescription( 'Beneficiario' )	
	oModel:GetModel( 'BA3DETAIL' ):SetDescription( 'Familia' )	

	/*Inicializadores Padrão*/
	oStruBA1:setProperty( 'BA1_TIPUSU', MODEL_FIELD_INIT, { || P260TipUsu()} )	


	//-------------------------REVALIDAR CAMPOS AO SALVAR-----------------------------------------------------------------------------
	oStruBA1:setProperty( 'BA1_CODINT', MODEL_FIELD_INIT,  { || PLSINTPAD()} )
	oStruBA1:setProperty( 'BA1_CODEMP', MODEL_FIELD_INIT,  { || BG9->BG9_CODIGO })
	oStruBA3:setProperty( 'BA3_CODEMP', MODEL_FIELD_INIT,  { || BG9->BG9_CODIGO })
	oStruBA3:setProperty( 'BA3_CODINT', MODEL_FIELD_INIT,  { || PLSINTPAD()})
	oStruBA3:setProperty( 'BA3_VERSAO', MODEL_FIELD_INIT,  { || "001" })
	oStruBA3:setProperty( 'BA3_FORPAG', MODEL_FIELD_INIT,  { || "101" })
	
	oStruBA3:setProperty('BA3_CODPLA',MODEL_FIELD_VALID, { || PLSABA3MVC(oModel) .And. PLSA260GCMvc(oModel) })
	oStruBA3:setProperty('BA3_VERSAO',MODEL_FIELD_VALID, { || EXISTCPO("BIL", RetFilPla(oModel),1) .And. PLSA260GCMvc(oModel) })
	oStruBA3:setProperty('BA3_FORPAG',MODEL_FIELD_VALID, { || PLS260COFZ(.T.,oModel) .And. PLSA260GCMvc(oModel)})
	oStruBA3:setProperty('BA3_FORCTX',MODEL_FIELD_VALID, { || PL260VldAde(oModel:GetValue('BA3DETAIL','BA3_CODINT'),oModel:GetValue('BA3DETAIL','BA3_CODPLA'),oModel:GetValue('BA3DETAIL','BA3_VERSAO'),oModel:GetValue('BA3DETAIL','BA3_FORCTX'))})
	
	oStruBA1:setProperty( 'BA1_DTVLCR', MODEL_FIELD_INIT, { || PL260VLD()} )	
	oStruBA1:setProperty( 'BA1_MATRIC', MODEL_FIELD_INIT, { || "AUTO" } )
	oStruBA1:setProperty( 'BA1_TIPUSU', MODEL_FIELD_INIT, { || GetNewPar("MV_PLCDTIT", "T")} )
	oStruBA1:setProperty( 'BA1_GRAUPA', MODEL_FIELD_INIT, { || GetNewPar("MV_PLCDTGP", "01")} )
	
	oStruBA1:setProperty( 'BA1_DATINC', MODEL_FIELD_INIT, { || Date()} )
	oStruBA1:setProperty( 'BA1_DATCAR', MODEL_FIELD_INIT, { || Date()} )
	oStruBA1:setProperty( 'BA1_CPFUSR', MODEL_FIELD_VALID, { || VldCpfUsrMVC(oModel)} )
	
	
 
	//Instala o evento padrão do programa.
	oModel:InstallEvent("PLSA260EVDEF",/*cOwner*/,oEvent)



Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  Totver
@version P2
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 
Local aCampBA1 := {} 
Local aCampBA3 := {} 
Local oStruBA3 := FWFormStruct( 2, 'BA3'    , { |cCampo| PLS260CamMenu('BA3',cCampo,'N',@aCampBA3) },.T./*lViewUsado*/)
Local oStruBA1 := FWFormStruct( 2, 'BA1'    , { |cCampo| PLS260CamMenu('BA1',cCampo,'N',@aCampBA1) },.T./*lViewUsado*/)
Local oModel   := FWLoadModel( 'PLSA260MVC' )
Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
Local nNx	

	oView := FWFormView():New()
	oView:SetModel( oModel )

	oView:AddField( 'VIEW_BA1', oStruBA1, 'BA1MASTER' )
	oView:AddField( 'VIEW_BA3', oStruBA3, 'BA3DETAIL' )


	oStruBA3:SetNoFolder(.T.)
	oStruBA1:SetNoFolder(.T.)

	// Cria os campos na estrutura que estão como não usados no dicionario
	For nNx := 1 To Len(aCampos)
		oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
	Next
		
	
	
    // Adiciona um painel com os campos para filtrar as informações do grid		
	oStruBA3:SetProperty( "BA3_CODINT" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_CODEMP" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_MATRIC" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_FORCTX" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )

	//Grupo 02
	oStruBA3:AddGroup( 'GrupoBA3_2', OemToAnsi('Campos Obrigatórios') , '1', 2 )
	oStruBA3:SetProperty( "BA3_TIPPGO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_CODPLA" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_DESPLA" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_VERSAO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_FORPAG" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_DESFOR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )	
	oStruBA3:SetProperty( "BA3_DATBAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	oStruBA3:SetProperty( "BA3_VENCTO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )

	For nNx := 1 to Len(aCampBA3)
		oStruBA3:SetProperty( aCampBA3[nNx] ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA3_2' )
	Next nNx



	//Grupo 01 BA1
	oStruBA1:AddGroup( 'GrupoBA1_1', OemToAnsi('Dados do Titular') , '1', 2 )
	oStruBA1:SetProperty( "BA1_CODEMP" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_INFANS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_MATRIC" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DTVLCR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_CPFUSR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_MATVID" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_NOMUSR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_CODINT" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DATNAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DRGUSR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )		
	oStruBA1:SetProperty( "BA1_CDMNAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )	
	oStruBA1:SetProperty( "BA1_MUNNAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_SEXO"   ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_PISPAS" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_ESTCIV" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_TIPREG" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DIGITO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_TIPUSU" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DESUSU" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DESCIV" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_GRAUPA" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DATINC" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_MAE"    ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DATADM" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DATCAR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_DESGRA" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_IDADE"  ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_OPEORI" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	oStruBA1:SetProperty( "BA1_OPEDES" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )	
	oStruBA1:SetProperty( "BA1_RESFAM" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	
	For nNx := 1 to Len(aCampBA1)
		oStruBA1:SetProperty( aCampBA1[nNx] ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_1' )
	Next nNx

	
	oStruBA1:AddGroup( 'GrupoBA1_2', OemToAnsi('Endereço') , '1', 2 )
	oStruBA1:SetProperty( "BA1_CEPUSR" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_ENDERE" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_NR_END" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_COMEND" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )	
	oStruBA1:SetProperty( "BA1_BAIRRO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_CODMUN" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )	
	oStruBA1:SetProperty( "BA1_MUNICI" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_ESTADO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_DDD"    ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	oStruBA1:SetProperty( "BA1_TELEFO" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )		
	oStruBA1:SetProperty( "BA1_ORIEND" ,MVC_VIEW_GROUP_NUMBER, 'GrupoBA1_2' )
	
	oView:CreateHorizontalBox( 'SUPERIOR', 40 )
	oView:CreateHorizontalBox( 'INFERIOR', 60 )

	
	//oView:EnableTitleView('VIEW_BA1','Cadastro do Beneficiário Titular')
	
	oView:SetOwnerView( 'VIEW_BA3', 'SUPERIOR'  )
	oView:SetOwnerView( 'VIEW_BA1', 'INFERIOR' )


	oStruBA1:SetProperty( 'BA1_TIPUSU',MVC_VIEW_CANCHANGE,.F.)
	oStruBA1:SetProperty( 'BA1_GRAUPA',MVC_VIEW_CANCHANGE,.F.)	

	
	
	/*Não permito alteração nos campos*/
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260MENU
Verifica se os dados podem ser inclusos/alterados 
@author Totver
@since 13/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260VLMVC(nOperation,lAutomato)
Local lRet := .T.
Local aArea		 := GetArea()
Local aAreaBA3   := BA3->(GetArea())
Local nOrdBA1    := BA1->(IndexOrd())
Local nRecBA1    := BA1->(Recno())
Local nOrdBQC    := BQC->(IndexOrd())
Local nRecBQC    := BQC->(Recno())
Local bRest      := { || BA1->(DbSetOrder(nOrdBA1)), BA1->(DbGoTo(nRecBA1)) }
Local bRestBQC   := { || BQC->(dbSetorder(nOrdBQC)), BQC->(dbGoto(nRecBQC)) }
Local lExcluiUsu :=.T.

Default	lAutomato:= .F.

If lJuridico 

	If (!Empty(BQC->BQC_DATBLO) .and. !Empty(BQC->BQC_CODBLO)) .and. (nOperation <> MODEL_OPERATION_VIEW)
		If !lAutomato
			Aviso(OemtoAnsi(STR0011),OemtoAnsi(STR0012) ,;//"Este subcontrato encontra-se bloqueado. So sera permitido a visualizacao dos registros ja existentes!"
			{OemtoAnsi(STR0015)})
		Endif	
        lRet := .F.
		DbSelectArea("BA1")

		Return
	
	ElseIf (nOperation == MODEL_OPERATION_INSERT) .or. (nOperation == MODEL_OPERATION_UPDATE)
		BA3->( MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
		If !Empty(BA3->BA3_MOTBLO) 
			If !lAutomato
				Aviso(OemtoAnsi(STR0013),OemtoAnsi(STR0014) ,; //"Esta familia encontra-se bloqueada, o registro somente podera ser visualizado."
				{OemtoAnsi(STR0015)})
			Endif	
			lRet := .F.
			DbSelectArea("BA1")
			Return
		Endif				
	EndIF
EndIF

If nOperation == MODEL_OPERATION_DELETE
	If BA1->BA1_TIPUSU	== 'T'	

		If(!lAutomato, lExcluiUsu:=MsgYesNo(OemtoAnsi(STR0054)),)	 //"Deseja realmente excluir o Usuario/Familia?"

		If lExcluiUsu
			If ! PLSA260Exc(BA1->BA1_CODINT,BA1->BA1_CODEMP,BA1->BA1_MATRIC,If(lAutomato,.F.,.T.))
				Eval(bRest)
				Eval(bRestBQC)
				//Refaz o filtro...							
				DbSelectArea("BA1")
				Return  
			Endif
		Else
			Return(nil)
		Endif
	Else
		Help( ,, 'HELP',,'Para exclusão nessa rotina somente titular.', 1, 0)
		Return(nil)			
	Endif 			

Endif

If lRet .and. !lAmbos 
	If lAutomato .or. FWExecView('','PLSA260MVC', nOperation,, { || .T. } ) == 0
		If nOperation = 3

			If lAutomato .or. MsgYesNo("Deseja incluir dependentes ?")
					If (!lAutomato,FWExecView('','PL260DEPMVC', nOperation,, { || .T. } ) <> 0 ,.T.)
				While .T.
					If !lAutomato .And. MsgYesNo("Deseja incluir mais algum dependente ?")
						If (!lAutomato,FWExecView('','PL260DEPMVC', nOperation,, { || .T. } ) <> 0 ,.T.)
					Else
						Exit
					EndIf
				Enddo	
			EndIf 


			If lAutomato .or. MsgYesNo("Deseja configurar a cobrança na Familia ?")	
				If(!lAutomato,FWExecView('Edição','PLSA260FD1COB', MODEL_OPERATION_UPDATE,, { || .T. } ),.T.)
			Endif 

			
		Endif		

	Endif
ElseIf lRet .and. lAmbos .AND. nOperation == MODEL_OPERATION_INSERT
	If (!lAutomato,	MsgAlert('Não é possivel realizar inclusão ao selecionar a opção Pesquisar no Pergunte.','Aviso'),)
EndIF

RestArea(aAreaBA3)
RestArea(aArea)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260MENU
Monta o Menu do PLSA260MVC 
@author Totver
@since 14/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Static Function PLS260CamMenu(cAlias,cCampo,cModel,aCampos)
Local lRet := .F.

Default  aCampos:= {}

BI3->(DbSetOrder(1))
cCampo := AllTrim(cCampo)

If cAlias == "BA3"
	 If cCampo $ "BA3_CODPLA,BA3_DESPLA,BA3_DATBAS,BA3_TIPPGO,BA3_VERSAO,BA3_FORPAG,BA3_DESFOR,BA3_CODINT,BA3_CODEMP,BA3_MATRIC,BA3_FORCTX,BA3_VENCTO" .OR.;
	 		 (cModel == 'S' .AND. cCampo $ ("BA3_RATSAI,BA3_DESMEN,BA3_TIPOUS,BA3_CONEMP,BA3_SUBCON,BA3_VERCON,BA3_VERSUB,BA3_ROTINA,BA3_DEFOTX,BA3_MODPAG"))
		lRet := .T.		
	EndIF
ElseIf cAlias == "BA1" 
	If cCampo $ "BA1_CPFUSR,BA1_MATVID,BA1_NOMUSR,BA1_DATNAS,BA1_DRGUSR,BA1_CDMNAS,BA1_MUNNAS,BA1_SEXO,BA1_PISPAS,BA1_ESTCIV,BA1_TIPREG,BA1_DIGITO,BA1_TIPUSU,BA1_DESUSU,BA1_RESFAM" .or.;
			cCampo $	"BA1_DESCIV,BA1_GRAUPA,BA1_DATINC,BA1_MAE,BA1_DATCAR,BA1_DESGRA,BA1_IDADE,BA1_OPEORI,BA1_OPEDES,BA1_CEPUSR,BA1_ENDERE,BA1_NR_END,BA1_COMEND,BA1_BAIRRO" .or.;
				cCampo $ "BA1_DATADM,BA1_CODMUN,BA1_MUNICI,BA1_ESTADO,BA1_DDD,BA1_TELEFO,BA1_ORIEND,BA1_CODINT,BA1_CODEMP,BA1_MATRIC,BA1_DTVLCR,BA1_INFANS" .OR.;
					(cModel == 'S' .AND. cCampo $ ("BA1_CODPLA,BA1_VERSAO,BA1_DATINC,BA1_CONEMP,BA1_SUBCON,BA1_VERCON,BA1_VERSUB,BA1_INTERD,BA1_OPERES,BA1_LOCANS,BA1_LOCATE,BA1_LOCEMI,BA1_REEWEB,BA1_10ANOS,BA1_INSALU,BA1_INFCOB,BA1_MUDFAI,BA1_LOCSIB"))
					

		lRet := .T.		
	EndIF
EndIF



// Incluindo os campos customizados
IF !lret .And. GetSx3Cache(cCampo, "X3_PROPRI") = "U"
	lRet := .T.		
	AaDD(aCampos,cCampo)
Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCpfUsrMVC
Valida o CPF
@author Totver
@since 30/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function VldCpfUsrMVC(oModel)
Local lRet:= .T.

If Cgc(oModel:GetValue('BA1MASTER','BA1_CPFUSR')) 
	If  !Empty(oModel:GetValue('BA1MASTER','BA1_CPFUSR'))
		lRet := PLS260VIDMVC('I',oModel)
	EndIF
EndIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCpfUsrMVC
Chama cadastro de vidas caso nao exista o CPF.
@author Totver
@since 30/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLS260VIDMVC(ctipo,oModel)

Local cCpf 	  	:= oModel:GetValue('BA1MASTER','BA1_CPFUSR')
Local lRet		:=.t.


Default ctipo :="I"

BTS->( dbSetorder(03) )
oModel:LoadValue('BA1MASTER','BA1_MATVID', Space(TamSx3('BTS_MATVID')[1]))

Do Case
Case ctipo == "I"
	If !BTS->( MsSeek(xFilial("BTS")+cCpf) ) .Or. Empty(cCpf)
		If !IsBlind()
			FWExecView('Incluir','PLSA955', MODEL_OPERATION_INSERT,, { || .T. } )
		EndIf
	Else
		If PLSBA1VLDINC(oModel)						
			 oModel:LoadValue('BA1MASTER','BA1_MATVID', BTS->BTS_MATVID)
		Else
			Help(" ",1,"JAGRAVADO")
			lRet:=.F.
		EndIf
	Endif
Endcase

oModel:LoadValue('BA1MASTER','BA1_MATVID', BTS->BTS_MATVID)

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} VldCpfUsrMVC
Valida se o CPF já foi utilizado na familia
@author Totver
@since 30/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLSBA1VLDINC(oModel)
LOCAL lRet := .T.
LOCAL aAreaBA1 := BA1->(GetArea())
LOCAL cChaveBA1:= oModel:GetValue('BA3DETAIL','BA3_CODINT')+oModel:GetValue('BA3DETAIL','BA3_CODEMP')+oModel:GetValue('BA3DETAIL','BA3_MATRIC')

BA1->( dbSetorder(04) )//BA1_FILIAL+BA1_CPFUSR
If BA1->(MsSeek(xFilial('BA1')+oModel:GetValue('BA1MASTER','BA1_CPFUSR')))
	If BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == cChaveBA1
		lRet := .F.
	EndIF
EndIF

RestArea(aAreaBA1)

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PL260VldAde
Valida se o o codigo de adesão esta configurada para o produto digitado
@author Totver
@since 29/09/2019
@version P12
/*/
//-------------------------------------------------------------------

 Function PL260VldAde(cCodInt,cCodPla,cVersao,cForcTx)

 Local lRet:= .F.

 Default cCodInt := ''
 Default cCodPla := ''
 Default cVersao := '' 
 Default cForcTx := ''

 If BJ9->(DbSeek(xFiliAl("BJ9")+cCodInt+cCodPla+cVersao+cForcTx))
	lRet:= .T.
 Endif

If !lRet
	MsgAlert("Taxa de adesão não configurada para esse produto!","Atenção")
Endif

Return lRet

//--------------------------------------------------------------------
/*/ {Protheus.doc} PLTermoBenef
Visualiza o Termo de Consentimento do Beneficiário selecionado

@author Vinicius Queiros Teixeira
@since 07/05/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Function PLTermoBenef()

	Local cOperadora := BA1->BA1_CODINT
    Local cEmpresa := BA1->BA1_CODEMP
    Local cMatricula := BA1->BA1_MATRIC
         
    PLTermConsBenef(cOperadora, cEmpresa, cMatricula)

Return

//--------------------------------------------------------------------
/*/ {Protheus.doc} PLMVCDesUsu
Inicializador padrão do campo BA1_TIPUSU da Rotina MVC

@author Giovanna Charlo
@since 30/12/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Function PLMVCDesUsu()

	Local oModel := FWModelActive()
	Local cTipuUsuario := ""
	Local cDescUsuario := ""

	If oModel:GetOperation() == MODEL_OPERATION_INSERT

		If IsInCallStack("PLSA260VLMVC")
			cTipuUsuario  := SuperGetMv("MV_PLCDTIT")
		Else
			cTipuUsuario  := SuperGetMv("MV_PLCDDEP", .F., "D")
		Endif

	Else
		cTipuUsuario  := BA1->BA1_TIPUSU
	EndIf

	If  !Empty(cTipuUsuario)
		cDescUsuario := Posicione("BIH", 1, xFilial("BIH") + cTipuUsuario, "BIH_DESCRI")	
	EndIf

Return cDescUsuario

//--------------------------------------------------------------------
/*/ {Protheus.doc} PLMVCDesGra
Inicializador padrão do campo BA1_GRAUPA da Rotina MVC

@author Giovanna Charlo
@since 30/12/2021
@version Protheus 12
/*/
//--------------------------------------------------------------------
Function PLMVCDesGra() 

	Local oModel := FWModelActive()
	Local cGrauParentesco := ""
	Local cDescParentesco := ""

	If oModel:GetOperation() == MODEL_OPERATION_INSERT

		If IsInCallStack("PLSA260VLMVC")
			cGrauParentesco := SuperGetMv("MV_PLCDTGP")
		Else
			cGrauParentesco := ""
		Endif

	Else
		cGrauParentesco := BA1->BA1_GRAUPA
	EndIf

	If !Empty(cGrauParentesco)
		cDescParentesco := Posicione("BRP", 1, xFilial("BRP")+cGrauParentesco, "BRP_DESCRI")
	EndIf

Return cDescParentesco
