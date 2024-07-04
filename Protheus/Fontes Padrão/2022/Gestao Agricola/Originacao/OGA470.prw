//Baseado no o HSPAHP18  , administração hospitalar
#Include 'Protheus.ch'
#INCLUDE "OGA470.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'FWEDITPANEL.CH'

// Constantes
#DEFINE C5PARC 'C5_PARC'
#DEFINE C5DATA 'C5_DATA'

/** {Protheus.doc} 
Função Chama função que permite  digitar as parcelas, 
de um PV. quando a condição de pagamento é do tipo 9
Baseado no o HSPAHP18  do Modulo administração pessoal
@param:     Codigo da condicao, Valor Total do PV 
@return:	array contendo os campos de Data e Parcela Preenchidos
@author: 	Emerson coelho
@since: 	28/05/2016
@Uso: 		Gestão Agricola
*/

Function OGA470( cE4Cond, nPvTotal )
	Local aCoors 		:= FWGetDialogSize(oMainWnd)
	Local oFWMVCWindow
	Local aParcelas		:= {}
	Local aButtons		:= {}

	// nÃO UTILIZEI O FWBUILDSTRUCT por que ele estava passando a condição como numerica e nao caracter (passado '002', inicializado '2  ') 
	bIniPVCond := "{||oview:GETMODEL('OGA470_MDSC5'):GETSTRUCT():SETPROPERTY('C5_CONDPAG'," + STRZERO(MODEL_FIELD_INIT,2) +  ", {|| '" + cE4Cond  				+ "'})}"
	bIniPVTota := "{||oview:GETMODEL('OGA470_MDSC5'):GETSTRUCT():SETPROPERTY('C5_TOTALPV'," + STRZERO(MODEL_FIELD_INIT,2) +  ", {||  " + cValtoChar(nPVTotal)	+ " })}"

	oView	:= FwLoadView("OGA470")
	oView:SetOperation( MODEL_OPERATION_INSERT )
	oView:SetViewCanActive( {|| fVCanActive( bIniPvCond, bIniPvTota ) }  )
	oView:SetCloseOnOk({|oView|aParcelas := fCloseOK( oView ), .T.})
	
	oFWMVCWindow := FWMVCWindow():New()
	oFWMVCWindow:SetUseControlBar( .T. )
	oFWMVCWindow:SetView(oView)
	oFWMVCWindow:SetCentered( .T. )
	oFWMVCWindow:SetPos(aCoors[1],aCoors[2] )
	oFWMVCWindow:SetTitle(STR0001+' ' + Alltrim( Transform(nPvtotal,PesqPict('SE2','E2_VALOR' ) ) ) ) 
	oFWMVCWindow:SetSize(400, 400)

// Trata os Botes da View, Deixando somente os Botoes Confirmar e Fechar

/* Array do enable buttons 
1 - Copiar
2 - Recortar
3 - Colar
4 - Calculadora
5 - Spool
6 - Imprimir
7 - Confirmar
8 - Cancelar
9 - WalkTrhough
10 - Ambiente
11 - Mashup
12 - Help
13 - Formulário HTML
14 - ECM
*/
	aButtons  := {{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil},{.f.,nil}, {.T.,nil},{.T.,nil},{.f.,nil},{.f.,nil},{.f.,nil},;
              	 {.f.,nil},{.f.,nil},{.f.,nil}}
	oFWMVCWindow:Activate(,,abuttons)                

	IF .not. oView:GetbuttonWasPressed() == VIEW_BUTTON_OK
	   aParcelas := {}
	EndIf

	oView:DeActivate()
	FreeObj(oView)
	oFWMVCWindow:DeActivate()
	FreeObj(oFWMVCWindow)
Return( aParcelas )

/** {Protheus.doc} ModelDef
Função que retorna o modelo padrao para a rotina

@param: 	Nil
@return:	oModel - Modelo de dados
@author: 	Emerson coelho
@since: 	28/05/2016
@Uso: 		OGA470
*/
Static Function ModelDef()
	Local oStruSC5 := FWFormStruct( 1,"SC5")
	Local oModel 	  := MPFormModel():New("OGA470",,{|oModel| PosModelo(oModel)})
	
	//Como a Sc5 nao possui um Cpo total irei criar um para Verificar se o Vr. das Parcelas corresponde com o Total do PV

	//----------Estrutura do campo tipo Model----------------------------

	// [01] C Titulo do campo
	// [02] C ToolTip do campo
	// [03] C identificador (ID) do Field
	// [04] C Tipo do campo
	// [05] N Tamanho do campo
	// [06] N Decimal do campo
	// [07] B Code-block de validação do campo
	// [08] B Code-block de validação When do campo
	// [09] A Lista de valores permitido do campo
	// [10] L Indica se o campo tem preenchimento obrigatório
	// [11] B Code-block de inicializacao do campo
	// [12] L Indica se trata de um campo chave
	// [13] L Indica se o campo pode receber valor em uma operação de update.
	// [14] L Indica se o campo é virtual

	// Criando um Campo Total do Pedido Pois o PV, Não Possui ( Até entao )
	IF ascan(oStruSC5:afields,{|x| x[MODEL_FIELD_IDFIELD ] == 'C5_TOTALPV'}) == 0    //Garantindo que o Campos já não existe
		oStruSC5:AddField('C5_TOTALPV',STR0002,'C5_TOTALPV',TamSx3('C6_VALOR')[3],TamSx3('C6_VALOR')[1],TamSx3('C6_VALOR')[2])
	EndIF

	oStruSC5:SetProperty("*",MODEL_FIELD_OBRIGAT,.F.)

	oModel:SetDescription(STR0003) 	//Parcelas de Pagamento

	oModel:AddFields("OGA470_MDSC5",Nil,oStruSC5)
Return( oModel )

/** {Protheus.doc} ViewDef
Função que retorna a view para o modelo padrao da rotina

@param: 	Nil
@return:	oView - View do modelo de dados
@author: 	Emerson coelho
@since: 	28/05/2016
@Uso: 		OGA470
*/
Static Function ViewDef()
	Local oStruSC5 		:= FWFormStruct( 2, "SC5" )
	Local oModel   		:= FWLoadModel( "OGA470" )
	Local oView    		:= FWFormView():New()
	Local aFieldsSC5  := aClone( oStruSC5:GetFields() )
	Local nFor01	     := 0

	//----------Estrutura do campo tipo View----------------------------
	// [01] C Nome do Campo
	// [02] C Ordem
	// [03] C Titulo do campo
	// [04] C Descrição do campo
	// [05] A Array com Help
	// [06] C Tipo do campo
	// [07] C Picture
	// [08] B Bloco de Picture Var
	// [09] C Consulta F3
	// [10] L Indica se o campo é evitável
	// [11] C Pasta do campo
	// [12] C Agrupamento do campo
	// [13] A Lista de valores permitido do campo (Combo)
	// [14] N Tamanho Maximo da maior opção do combo
	// [15] C Inicializador de Browse
	// [16] L Indica se o campo é virtual
	// [17] C Picture Variável

	// Criando um Campo Total do Pedido Pois o PV, Não Possui ( Até entao )
	IF ascan(oStruSC5:afields,{|x| x[MVC_VIEW_IDFIELD] == 'C5_TOTALPV'}) == 0    //Garantindo que o Campos já não existe
		oStruSC5:AddField('C5_TOTALPV','02','C5_TOTALPV',STR0002,{/*hELP*/},TamSx3('C6_VALOR')[3],PESQPICT('SC6','C6_VALOR'),nil,nil,.t.)
	EndIF

	// Atualizando os Cpos apos Inserir cpos de forma manual 
	aFieldsSC5 := aClone( oStruSC5:GetFields() )
	// retirando todos os campos que não sao ref a parcela e data de pagto da view
	For nFor01 := 1 To Len( aFieldsSC5 )
		If .not. ( C5PARC  $ aFieldsSC5[nFor01, MVC_VIEW_IDFIELD ] )   .and. .not. ( C5DATA  $ aFieldsSC5[nFor01, MVC_VIEW_IDFIELD ] )
			// Se as constantes nao estiver contida no nome do cpo lido NAO esta na lista dos Cpos a Editar
			oStruSC5:RemoveField( aFieldsSC5[ nFor01, MVC_VIEW_IDFIELD ] )
		ENDIF
	Next nFor01

	oView:SetModel( oModel )
	oView:AddField( "OGA470VIEW_SC5", oStruSC5, "OGA470_MDSC5" )
	oView:SetViewProperty("OGA470VIEW_SC5","SETLAYOUT",{FF_LAYOUT_VERT_DESCR_TOP ,2})
	oView:SetCloseOnOk( {||.t.} )
Return( oView )

/** {Protheus.doc} fVCanActive
Função que verifica se a View pode Ser Ativada, utilizada para
inicializar os Campos C5_CONDPAG, C5_TOTALPV

@param: 	BIniCond , BIniPvTota
@return:	lRetorno - verdadeiro 
@author: 	Emerson coelho
@since: 	28/05/2016
@Uso: 		OGA470
*/
Static Function fVCanActive ( bIniCond, bIniPvtota )
	Local aAreaATU := GetArea()
	Local aAreaSE4 := SE4->( GetArea() )
	Local cTitulo	  := ''
	eval( &(bInicond  ) )
	eval( &(bIniPvtota) )
		
	cTitulo := STR0004 + IIf(AllTrim(SE4->E4_COND) == '% ',STR0005,STR0006) + STR0006 //"Digite as datas e os "###"percentuais"###"valores"###" dos titulos"
	oView:EnableTitleView( "OGA470VIEW_SC5", cTitulo )
	
  	RestArea( aAreaSE4 )
	RestArea( aAreaATU )
Return(.t.)

/** {Protheus.doc} fCloseOK
Função executada ao clicar o ok da View, retorna array Com
os cpos C5_PARC? e Seus Vrs. , e o C5_DATA? e seus Valors

@param: 	View e Modelo
@return:	Array contendo 
@author: 	Emerson coelho
@since: 	28/05/2016
@Uso: 		OGA470
*/
Static function fCloseOK( Oview )
	Local oModel		 := oView:GetModel() 
	Local oModelSC5	 := oModel:GetModel("OGA470_MDSC5")
	Local aViewSC5Cp := oview:GetViewStruct('OGA470VIEW_SC5'):Getfields()   // Pego os Campos da View
	Local aParcelas	 := {}		// 01 - Nome do campo ( C5_DATA1...C5_DATA? OU C5_PARC1...C5_PARC? ) e o Seu Valor  
	Local nFor01		 := 0

	For nfor01 := 1 to Len( aViewSC5Cp )
		aAdd(aParcelas,{aViewSC5Cp[nFor01,MVC_VIEW_IDFIELD],oModelSC5:GetValue(aViewSC5Cp[nFor01,MVC_VIEW_IDFIELD])})
	nExt nFor01
Return (aParcelas)

/** {Protheus.doc} PosModelo
Função que valida o modelo de dados após a confirmação

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Emerson coelho
@since: 	28/05/2016
@Uso: 		OGA470
*/
Static Function PosModelo( oModel )
	Local oView		:= FwViewActive()
	Local aAreaATU	:= GetArea()
	Local aAreaSE4	:= SE4->( GetArea() )
	Local lContinua	:= .t.		

	lContinua := fVldParc(oview,oModel)   // Validando as Parcelas

	RestArea( aAreaSE4 )
	RestArea( aAreaATU )
Return( lContinua )

/** {Protheus.doc} fVldParc
Função que valida os dados das Parcelas

@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	Emerson coelho
@since: 	28/05/2016
@Uso: 		OGA470
*/
Static function fVldParc( oview,oModel )
	Local oMdSc5		:= oModel:GetModel('OGA470_MDSC5')
	Local nTotalPV	:= oMdsc5:Getvalue('C5_TOTALPV')
	Local cCondPgto	:= oMdsc5:Getvalue('C5_CONDPAG')

	/* Atenção:
	Acima de 9 parcelas deve-se tomar cuidado, pois o nome do campo não poderá ser C5_DATA10, 
	mas sim C5_DATAA, e assim sucessivamente até o máximo de 26 parcelas (C5_DATAQ, C5_PARCQ, CJ_DATAQ, CJ_PARCQ);
	*/
	Local cParcela   := "123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ0"
	Local cMv1Dup    := GetMV("MV_1DUP")
	Local nTotDig    := 0
	Local nMaxTipo9  := 26
	Local nMVNumParc := GetMV("MV_NUMPARC")
	Local nParcAtu   := 0
	Local dDataDig   := CToD("//")
	Local nParcDig   := 0
	Local nDataDig   := 0

	///Verifica se pode estender a tipo 9 ate 36 parcelas   ( Sim é Possivel )                    
	If Len( cMv1Dup ) > 1 .And. Len( cMv1Dup ) == Len( SE1->E1_PARCELA ) .And. cMv1Dup == ( Replicate("0", Len(SE1->E1_PARCELA) - 1) + "1")
		nMaxTipo9 := 36
	EndIf

	///Limita o numero de parcelas do parametro
	If nMvNumParc > nMaxTipo9
		nMvNumParc := nMaxTipo9
	EndIf

	DbSelectArea( 'SE4' )
	SE4->(  DbSetOrder(1) ) 
	IF .not. SE4->(DbSeek( fWXfilial('SE4') + cCondPgto ) )
		oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',STR0008,STR0009,STR0010,'','')
		Return (.f.)
	EndIF

	For nParcAtu := 1 to nMvNumParc  			// Varrendo até o Nr. x de Parcelas;

		dDataDig :=  CToD('//')
		nParcDig :=	0

		cCpoData := ( C5DATA + SubStr(cParcela,nParcAtu,1))
		cCpoParc := ( C5PARC + SubStr(cParcela,nParcAtu,1))

		IF oView:HasField('OGA470VIEW_SC5', cCpoData)    // Verificando se o Campo Data está na View
			dDataDig := oMdSC5:Getvalue( cCpoData )
		EndIF   

		IF oView:HasField('OGA470VIEW_SC5', cCpoParc )    // Verificando se o Campo Parcela está na View
			nParcDig := oMdSC5:Getvalue( cCpoParc )
		EndIF

		If !Empty(dDataDig)
			nDataDig++
			If Empty(nParcDig)
				oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',STR0008,STR0011 + SubStr(cParcela,nParcAtu,1) + STR0012,STR0013,'','')
				Return(.F.)
			EndIf
		ElseIf !Empty(nParcDig)
			If Empty(dDataDig)
				oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',STR0008,STR0014 + SubStr(cParcela,nParcAtu,1) + STR0015,STR0016,'','')
				Return(.F.)
			EndIf
		EndIf
	Next
	
	If nDataDig == 0
		oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',STR0008,STR0017,'','')
		Return(.f.)
	Else
		For nParcAtu := 1 to nMvNumParc
			cCpoParc := ( C5PARC  + SubStr(cParcela, nParcAtu, 1) )
			IF oView:HasField('OGA470VIEW_SC5', cCpoParc )    // Verificando se o Campo Parcela está na View
				nTotDig += oMdSC5:Getvalue( cCpoParc ) 
			EndIF
		Next

		If AllTrim( SE4->E4_COND ) == "0" .And. NoRound( nTotalPV, 2 ) # NoRound( nTotDig, 2 )
			oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',STR0008,STR0018,STR0019,'','')
			Return( .F. )
		ElseIf AllTrim( SE4->E4_COND ) == "%" .And. nTotDig # 100
			oModel:GetModel():SetErrorMessage(,,oModel:GetId(),'',STR0008,STR0020,STR0021,'','')
			Return( .f. )
		EndIf
	EndIf
Return (.t.)