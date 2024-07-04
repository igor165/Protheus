#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "TAFA441.CH" 
//-------------------------------------------------------------------
/*/{Protheus.doc} TAFA441
Cadastro de grupo de eventos de transmissão

@author Paulo V.B. Santana
@since 11/11/2015
@version 1.0

/*/ 
//-------------------------------------------------------------------
Function TAFA441()
Local cTitulo := ""
Local cMensagem := ""

Private oBrw  :=  FWmBrowse():New()

oBrw:SetDescription(STR0003)    //Cadastro de Grupo de Eventos  
oBrw:SetAlias( 'LE6')
oBrw:SetMenuDef( 'TAFA441' )
oBrw:Activate() 

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Funcao generica MVC com as opcoes de menu

@author Paulo V.B. Santana
@since 11/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aFuncao := {}
Local aRotina := {}

Aadd( aFuncao, { "" , 'FWMsgRun(,{||TAF441Car()},,"Carregando Grupos de Eventos... ")' , "1", 3 } ) //A Quarta posição refere-se ao tipo de operação 2=Visualizar, 3=Inclusão, 4=Exclusão
Aadd( aFuncao, { "" , "TAF441Sche()" , "2", 4 } )

aRotina	:=	xFunMnuTAF( "TAFA441" ,,aFuncao )

Return( aRotina )
//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Funcao generica MVC do model

@return oModel - Objeto do Modelo MVC

@author Paulo V.B. Santana
@since 11/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruLE6  := FWFormStruct( 1, 'LE6' )
Local oStruLE8  := FWFormStruct( 1, 'LE8' )
Local oModel    := MPFormModel():New( 'TAFA441',,,{ |oModel| SaveModel( oModel ) } )  

oModel:AddFields('MODEL_LE6', /*cOwner*/, oStruLE6)

//===================================
//Periculosidade e Insalubridade
//===================================
oModel:AddGrid("MODEL_LE8","MODEL_LE6",oStruLE8)
oModel:GetModel("MODEL_LE8"):SetUniqueLine({"LE8_IDEVEN"})

//Relacionamentos
oModel:SetRelation("MODEL_LE8",{ {"LE8_FILIAL","xFilial('LE8')"}, {"LE8_ID","LE6_ID"}},LE8->(IndexKey(1)) )

oModel:GetModel("MODEL_LE6"):SetPrimaryKey({"LE6_CODIGO"})

Return oModel
//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@return oView - Objeto da View MVC

@author Paulo V.B. Santana
@since 11/11/2015
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oModel   := FWLoadModel( 'TAFA441' )
Local oStruLE6 := FWFormStruct( 2, 'LE6' )
Local oStruLE8 := FWFormStruct( 2, 'LE8' )
Local oView    := FWFormView():New()

oView:SetModel( oModel )

oView:AddField( "VIEW_LE6", oStruLE6, "MODEL_LE6" )
oView:EnableTitleView( "VIEW_LE6", STR0003 ) //Cadastro de Grupo de Eventos

oView:AddGrid( "VIEW_LE8", oStruLE8, "MODEL_LE8" )
oView:EnableTitleView( "VIEW_LE8", STR0004 ) //Eventos Relacionados

/*-----------------------------------------------------------------------------------
Estrutura do Folder
-------------------------------------------------------------------------------------*/
oView:CreateHorizontalBox("PAINEL_PRINCIPAL",40)
oView:CreateFolder("FOLDER_PRINCIPAL","PAINEL_PRINCIPAL")

oView:CreateHorizontalBox("PAINEL_INFERIOR",60)
oView:CreateFolder("FOLDER_INFERIOR","PAINEL_INFERIOR") 

oView:AddSheet("FOLDER_INFERIOR","ABA01","Eventos Relacionados") //"Plano Contas Referencial"
oView:CreateHorizontalBox("PAINEL_LE8",100,,,"FOLDER_INFERIOR","ABA01") //LE8

oView:SetOwnerView( "VIEW_LE6", "PAINEL_PRINCIPAL" )
oView:SetOwnerView( "VIEW_LE8", "PAINEL_LE8" )

oStruLE8:RemoveField("LE8_ID")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF441Car    
Função de efetuar a carga dos grupos de eventos atendendo as regras
descritas no manual de orientação do eSocial.
@Return    

@author Paulo Sérgio Santana
@since 17/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Function TAF441Car()    
Local oModel	 := Nil
Local aGrpEven   := {}
Local aGrpEven1  := {}
Local aGrpEven2  := {}
Local aGrpEven3  := {}
Local aDescEvt   := {}
Local nX		 := 0
Local nY		 := 0
Local nI         := 0
Local x 		 := 0
Local cCodGrp    := ""
Local cEnter	 := Chr(13) + Chr(10)

//"Eventos Diários"
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2190' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2200' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2205' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)		
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2206' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2220' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2230' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2240' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2241' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2250' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2298' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2299' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2300' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2306' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2399' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-3000' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)	
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-4000' + space(8),"C8E_ID")),aAdd (aGrpEven1,{"000001",1,C8E->C8E_ID}),)

//"Eventos Mensais"
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-1200' + space(8),"C8E_ID")),aAdd (aGrpEven2,{"000002",2,C8E->C8E_ID}),)
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-1202' + space(8),"C8E_ID")),aAdd (aGrpEven2,{"000002",2,C8E->C8E_ID}),)
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-1210' + space(8),"C8E_ID")),aAdd (aGrpEven2,{"000002",2,C8E->C8E_ID}),)
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-1250' + space(8),"C8E_ID")),aAdd (aGrpEven2,{"000002",2,C8E->C8E_ID}),)
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-1260' + space(8),"C8E_ID")),aAdd (aGrpEven2,{"000002",2,C8E->C8E_ID}),)
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-1270' + space(8),"C8E_ID")),aAdd (aGrpEven2,{"000002",2,C8E->C8E_ID}),)
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-1280' + space(8),"C8E_ID")),aAdd (aGrpEven2,{"000002",2,C8E->C8E_ID}),)
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-1298' + space(8),"C8E_ID")),aAdd (aGrpEven2,{"000002",2,C8E->C8E_ID}),)
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-1299' + space(8),"C8E_ID")),aAdd (aGrpEven2,{"000002",2,C8E->C8E_ID}),)
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-1300' + space(8),"C8E_ID")),aAdd (aGrpEven2,{"000002",2,C8E->C8E_ID}),)

//"Eventos Críticos"
If(!Empty(Posicione("C8E",2,xFilial("C8E") + 'S-2210' + space(8),"C8E_ID")),aAdd (aGrpEven3,{"000003",3,C8E->C8E_ID}),)

aAdd(aGrpEven,aGrpEven1) 
aAdd(aGrpEven,aGrpEven2)
aAdd(aGrpEven,aGrpEven3)

For nI:=1 to Len(aGrpEven)

	If Taf441vld( aGrpEven[nI] )
		Begin Transaction
			nX:= 1
			
			While nX <= len(aGrpEven[nI])
			
				omodel:= FWLoadModel("TAFA441")
				omodel:SetOperation( 3 )
				omodel:Activate()
				
				aAdd(aDescEvt,{Iif(aGrpEven[nI][nX][2]==1,STR0005,IIF(aGrpEven[nI][nX][2]==2,STR0006,STR0007))})
				
				cCodGrp := aGrpEven[nI][nX][1]
				oModel:GetModel( 'MODEL_LE6' ):LVALID	:= .T.
					
				omodel:LoadValue( "MODEL_LE6","LE6_FILIAL", xFilial("LE6") )
				omodel:LoadValue( "MODEL_LE6","LE6_CODIGO", cCodGrp )
				omodel:LoadValue( "MODEL_LE6","LE6_DESCRI", aDescEvt[len(aDescEvt)][1] )
				nY := 1
				While nX <= Len(aGrpEven[nI]) .And. cCodGrp == aGrpEven[nI][nX][1]
					oModel:GetModel( 'MODEL_LE8' ):LVALID	:= .T.
					If nY > 1
						oModel:GetModel( "MODEL_LE8" ):AddLine()
					EndIf
					omodel:LoadValue( "MODEL_LE8","LE8_FILIAL"   ,xFilial( "LE8" ) )
					omodel:LoadValue( "MODEL_LE8","LE8_IDEVEN"   ,aGrpEven[nI][nX][3] )
					nX++
					nY++
				End
				FwFormCommit( oModel )
				fwFormCancel( oModel )
				FreeObj( oModel )
				
			End
		End Transaction
		
	Endif 
Next  
IF Len(aDescEvt) > 0 
	cMensagem := STR0008 + cEnter //Grupos de Eventos Carregados com Sucesso!
	For x:=1 to Len(aDescEvt) 
		cMensagem += "Grupo de Eventos: '" + aDescEvt[x][1] + "'" + cEnter
	End
	msgInfo(cMensagem)          
Endif
Return  

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf441vld
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados

@return .T.

@author Paulo Sérgio V.B. Santana
@since 17/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function Taf441vld( aGrpEven, oModel, cOper )
Local nX 		:= 0
Local cIdEvento := ""	
Local cDescEven := ""
Local cCodEvent := ""
Local aErros	:= {}
Local lReturn   := .T.
Local cSelect   := ""
Local cAliasTrb := GetNextAlias()

Default cOper	:= "I"
Default oModel  := Nil

For nX:= 1 to Len(aGrpEven)
	LE8->( dbSetOrder( 2 ) )
	If cOper == "I"
		IF LE8->( msSeek( xFilial("LE8") + aGrpEven[nX][3] ) )
			cIdEvento:= LE8->LE8_ID
			cIdGrpEvt:= LE8->LE8_IDEVEN
			cDescEven:= Posicione("C8E",1,xFilial("C8E") + cIdGrpEvt, "C8E_DESCRI")
			cCodEvent:= Posicione("C8E",1,xFilial("C8E") + cIdGrpEvt, "C8E_CODIGO")
			aadd(aErros, { cCodEvent,cIdEvento,cDescEven }) 
		Endif
		
	//=================================================================================||
	//Caso seja uma alteração eu preciso utilizar o select para verificar se existe o  ||
	//Evento Relacionado a um outro Grupo que não seja oque está sendo alterado.       ||
	//=================================================================================++
	Else 
		cSelect :=  "SELECT LE8_ID, LE8_IDEVEN FROM "  + RetSqlName("LE8") +" WHERE LE8_FILIAL = '" + xFilial("LE8")
		cSelect += "' AND LE8_ID <> '" + aGrpEven[nX][1] + "' AND LE8_IDEVEN = '" + aGrpEven[nX][3] + "' AND D_E_L_E_T_ <> '*'"
	
		dbUseArea( .T. , "TOPCONN" , TcGenQry( , , cSelect ) , cAliasTrb)
		IF (cAliasTrb)->(!Eof())		
			cIdEvento:= (cAliasTrb)->(LE8_ID)
			cIdGrpEvt:= (cAliasTrb)->(LE8_IDEVEN)
			cDescEven:= Posicione("C8E",1,xFilial("C8E") + cIdGrpEvt, "C8E_DESCRI")
			cCodEvent:= Posicione("C8E",1,xFilial("C8E") + cIdGrpEvt, "C8E_CODIGO")
			aadd(aErros, { cCodEvent,cIdEvento,cDescEven })
		Endif
		(cAliasTrb)->(dbCloseArea())	
	Endif
Next 

If Len(aErros) > 0
	TAF441Log(aErros, oModel)
	ASORT(aErros, , , { | x,y | x[2] < y[2] } ) //Ordeno o Array pelo Id do Grupo de eventos LE8->LE8_ID
	lReturn  := .F.
Endif

Return lReturn

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveModel
Funcao de gravacao dos dados, chamada no final, no momento da
confirmacao do modelo
                                                                                                                               
@param  oModel -> Modelo de dados

@return .T.

@author Paulo Sérgio V.B. Santana
@since 17/06/2016
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function SaveModel( oModel )
Local nOperation := oModel:GetOperation()
Local aGravaLE8  := {}
Local oModel_LE8 := oModel:GetModel( "MODEL_LE8" )
Local nI		 := 0
Local lReturn    := .T.
Local cOpera	 := IIF(nOperation == MODEL_OPERATION_INSERT,"I","A")

Begin Transaction

	For nI := 1 to oModel:GetModel( "MODEL_LE8" ):Length()
			oModel:GetModel( "MODEL_LE8" ):GoLine(nI)
			If !oModel:GetModel( 'MODEL_LE8' ):IsEmpty()
				If !oModel:GetModel( "MODEL_LE8" ):IsDeleted()
					aAdd(aGravaLE8,{oModel_LE8:GetValue("LE8_ID"),;
	              "",;
	              oModel_LE8:GetValue("LE8_IDEVEN")})
				EndIf
			EndIf
		Next nI
	
			 		
	IF Taf441vld( aGravaLE8, @oModel, cOpera  )
		FwFormCommit( oModel )
	Else
		lReturn := .F.
	Endif
		
	
End Transaction

Return( lReturn )

//-------------------------------------------------------------------
/*/{Protheus.doc} Taf441Log

@param aLogErro - Array contendo as caracteristicas do erro 
                
Função responsavel por gerar apresentar os erros encontrados na 
inclusão do grupo de eventos.

@author Paulo V.B. Santana
@since 05/06/2016
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Static Function Taf441Log(aLogErro, oModel)
Local cMsgErro  := "" 
Local nX  		:= 1
Local cGrpEvent := ""

cMsgErro := STR0009 + CRLF + CRLF //"Não foi possível carregar Grupo de Eventos, pois existe(m) evento(s) já relacionado(s) a outro Grupo, conforme abaixo:"

While nX <= Len(aLogErro) 
	cGrpEvent := aLogErro[nX][2]
	cMsgErro  += STR0010 + cGrpEvent + ":" + CRLF //"Grupo de Eventos ID. '"
	
	While nX <= Len(aLogErro) .And. cGrpEvent == aLogErro[nX][2]
		cMsgErro  += "'" + aLogErro[nX][1] + "' - "+ aLogErro[nX][3] + CRLF
		nX++
	End
	cMsgErro  += CRLF
End  
 
If Valtype(oModel) <> "U" 
	oModel:SetErrorMessage(, , , , , cMsgErro, , , )
Else
	Aviso(STR0011,cMsgErro,{STR0012},3) //"Log de Validação" # Fechar 
Endif	

Return (Nil)

//-------------------------------------------------------------------
/*/{Protheus.doc} TAF441Sche

@param aLogErro - Array contendo as caracteristicas do erro 
                
Função responsavel por gerar apresentar os erros encontrados na 
inclusão do grupo de eventos.

@author Paulo V.B. Santana
@since 05/06/2016
@version 1.0
/*/                                                                                                                                          
//-------------------------------------------------------------------
Function TAF441Sche()

Local oFWUISchedulePersist := FWUISchedulePersist():new()
Local oDlg := MSDialog():New(50,50,900,1200,STR0013,,,,,CLR_BLACK,CLR_WHITE,,,.T.) //'Agendamentos'

oFWUISchedulePersist:Init(oDlg)

oDlg:Activate(,,,.T.,,, )

Return()