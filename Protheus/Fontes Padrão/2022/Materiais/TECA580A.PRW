#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PONCALEN.CH"
#INCLUDE "TECA580A.CH"

STATIC aEfetivo 	:= {} 	// Cabeçalho dos dados do Efetivo
STATIC aCobertura	:= {} 	// Cabeçalho dos dados da Cobertura

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Model - Visualização da Escala

@Return 	model
@author 	Serviços
@since 		09/06/2014
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruTDW := FWFormStruct(1,"TDW")
Local oStruZZX := FWFormModelStruct():New()
Local oStruZZY := FWFormModelStruct():New()
Local bLoadZZX := { || At580AEst("ZZX") }
Local bLoadZZY := { || At580AEst("ZZY") }
Local bCommit  := { || .T. }	
					
oStruZZX:AddTable("ZZX",{},STR0001)		//"Efetivos"
oStruZZY:AddTable("ZZY",{},STR0002)	//"Cobertura"

At580AStru( oStruTDW, .T., "TDW" )
At580AStru( oStruZZX, .T., "ZZX" )
At580AStru( oStruZZY, .T., "ZZY" )

oModel := MPFormModel():New("TECA580A", /*bPreValidacao*/, /*bPosValidacao*/, bCommit, /*bCancel*/ )

oModel:AddFields("TDWMASTER",/*cOwner*/,oStruTDW, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )

oModel:AddGrid( "ZZXDETAIL","TDWMASTER",oStruZZX,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, bLoadZZX )
oModel:AddGrid( "ZZYDETAIL","TDWMASTER",oStruZZY,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/, /*bPosVal*/, bLoadZZY )

oModel:SetDescription(STR0003) // "Visualização da Escala"
oModel:GetModel("ZZXDETAIL"):SetDescription(STR0001) // "Efetivos"
oModel:GetModel("ZZYDETAIL"):SetDescription(STR0002) // "Cobertura"

oModel:SetActivate( {|oModel| InitDados( oModel ) } )

Return(oModel)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View - Log de Eventos dos alertas

@Return 	view
@author 	Serviços
@since 		20/09/2013
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel := FWLoadModel("TECA580A")

Local oStruTDW := FWFormStruct( 2, "TDW", {|cCampo| ( Alltrim( cCampo )$"TDW_COD+TDW_DESC" ) } )
Local oStruZZX := FWFormViewStruct():New()
Local oStruZZY := FWFormViewStruct():New()

At580AStru( oStruTDW, .F., "TDW" )
At580AStru( oStruZZX, .F., "ZZX" )
At580AStru( oStruZZY, .F., "ZZY" )

oView := FWFormView():New()
oView:SetModel( oModel )

oView:SetDescription( STR0003 ) // "Visualização da Escala"
oView:SetCloseOnOk({|| .T. } )

oStruTDW:SetProperty( "*", MVC_VIEW_CANCHANGE, .F. )
oStruZZX:SetProperty( "*", MVC_VIEW_CANCHANGE, .F. )
oStruZZY:SetProperty( "*", MVC_VIEW_CANCHANGE, .F. )

oView:AddField("TDW_CABEC", oStruTDW, "TDWMASTER" )
oView:AddGrid( "ZZX_GRID" , oStruZZX, "ZZXDETAIL" )
oView:AddGrid( "ZZY_GRID" , oStruZZY, "ZZYDETAIL" )

//--------------------------------------
//		Cria os Box's
//--------------------------------------
oView:CreateHorizontalBox( "TOP"   , 16 )  
oView:CreateHorizontalBox( "MIDDLE", 42 )  
oView:CreateHorizontalBox( "DOWN"	, 42 )  

//--------------------------------------
//		Associa os componentes ao Box
//--------------------------------------
oView:SetOwnerView( "TDW_CABEC", "TOP"   ) 
oView:SetOwnerView( "ZZX_GRID", "MIDDLE" )
oView:SetOwnerView( "ZZY_GRID", "DOWN"   )

oView:EnableTitleView( "ZZX_GRID", STR0001 ) 	// "Efetivos"
oView:EnableTitleView( "ZZY_GRID", STR0002 ) 	// "Cobertura"

Return(oView)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} InitDados()
Inicializa as informações da visualização da escala

@sample 	InitDados()

@param  	oModel, Objeto, objeto geral do model que será alterado

@author 	Serviços
@since 		09/06/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function InitDados(oModel)

Local aSaveRows  	:= {}
Local oModelTDW  	:= oModel:GetModel("TDWMASTER")
Local oModelZZX  	:= oModel:GetModel("ZZXDETAIL")
Local oModelZZY  	:= oModel:GetModel("ZZYDETAIL")
Local oMdlEsc    	:= At580GetMdl()
Local oMdlTDX    	:= oMdlEsc:GetModel("TDXDETAIL")
Local oMdlTGW    	:= oMdlEsc:GetModel("TGWDETAIL")
Local dDataIni   	:= MV_PAR01
Local dDataFim   	:= MV_PAR02
Local cCalend    	:= MV_PAR03 //Calendario
Local cFilSR6    	:= xFilial("SR6")
Local aTabPadrao 	:= {}
Local aTabCalend 	:= {}
Local aFuncEfe   	:= {}
Local aFuncCob   	:= {}
Local aCfgCob    	:= {}
Local lRetCalend 	:= .T.
Local cOrdem     	:= ""
Local cHorario   	:= ""
Local nPos       	:= 0
Local nPosHor    	:= 0
Local nHorExt    	:= 0
Local nI		 	:= 0
local lPEEscala		:= FindFunction('U_PNMSEsc') .And. FindFunction('U_PNMSCal') 
Local lTecPnm		:= FindFunction( "TecExecPNM" ) .AND. TecExecPNM()
Local cTurno, cSeq, cEscala, nJ, nX

aSaveRows := FwSaveRows()

cEscala := oModelTDW:GetValue( "TDW_COD" ) 

oModelTDW:LoadValue( "TDW_DATINI", MV_PAR01 )
oModelTDW:LoadValue( "TDW_DATFIM", MV_PAR02 )
oModelTDW:LoadValue( "TDW_CALEND", MV_PAR03 )
oModelTDW:LoadValue( "TDW_DESCAL", Posicione( "AC0", 1, xFilial("AC0")+MV_PAR03, "AC0_DESC" ) )

For nI:=1 To oMdlTDX:Length()

	oMdlTDX:GoLine(nI)
	
	If !oMdlTDX:IsDeleted()
	
		cTurno := oMdlTDX:GetValue("TDX_TURNO") 
		cSeq   := oMdlTDX:GetValue("TDX_SEQTUR")
		
		If lPEEscala	
			U_PNMSEsc(cEscala) // informar escala
			U_PNMSCal(cCalend) // informar calendario 
		ElseIf lTecPnm
			TecPNMSEsc( cEscala )
			TecPNMSCal( cCalend )
		EndIf
		
		lRetCalend := CriaCalend( 	dDataIni   ,;    //01 -> Data Inicial do Periodo
	                           		dDataFim   ,;    //02 -> Data Final do Periodo
	                            	cTurno     ,;    //03 -> Turno Para a Montagem do Calendario
	                            	cSeq       ,;    //04 -> Sequencia Inicial para a Montagem Calendario
	                            	@aTabPadrao,;    //05 -> Array Tabela de Horario Padrao
	                            	@aTabCalend,;    //06 -> Array com o Calendario de Marcacoes  
	                            	cFilSR6    ,;    //07 -> Filial para a Montagem da Tabela de Horario
	                            	Nil, Nil )
	    
	    If lPEEscala                        	
			U_PNMSEsc(Nil) // Limpar as variaveis estaticas
			U_PNMSCal(Nil)
		ElseIf lTecPnm
			TecPNMSEsc(Nil)
			TecPNMSCal(Nil)                              		
		EndIf
		
		aCfgCob := {}
		
		varinfo('a',aTabCalend)
		
		// Carrega as informacoes para a cobertura
		For nJ:=1 To oMdlTGW:Length()
		
			oMdlTGW:GoLine(nJ)	
			
			If Empty(oMdlTGW:GetValue("TGW_COBTDX"))
				Loop
			EndIf
			
			nPos := aScan( aCfgCob, { |x| x[1] == oMdlTGW:GetValue("TGW_DIASEM") } )
			
			If nPos == 0		
				aAdd( aCfgCob, { oMdlTGW:GetValue("TGW_DIASEM"),; 
								{ { oMdlTGW:GetValue("TGW_COBTDX"), oMdlTGW:GetValue("TGW_HORINI"), oMdlTGW:GetValue("TGW_HORFIM") } } } )
			Else
				aAdd( aCfgCob[nPos,2], { oMdlTGW:GetValue("TGW_COBTDX"), oMdlTGW:GetValue("TGW_HORINI"), oMdlTGW:GetValue("TGW_HORFIM") } )		
			EndIf
		
		Next nJ
		
		cOrdem  := "#@$"
		
		// Alimenta as informacoes de efetivos e coberturas
		For nJ:=1 To Len(aTabCalend)
			
			If cOrdem <> aTabCalend[ nJ, CALEND_POS_ORDEM ]
			
				cOrdem := aTabCalend[ nJ, CALEND_POS_ORDEM ]
							
				nPos := aScan( aFuncEfe, { |x| x[1] == aTabCalend[ nJ, CALEND_POS_DATA ] } )
				
				At580ACob( aTabCalend[ nJ, CALEND_POS_DATA ],;
								 DiaSemana( aTabCalend[ nJ , CALEND_POS_DATA ] ), aCfgCob, @aFuncCob )
				
				If nPos == 0
					
					aAdd( aFuncEfe, { aTabCalend[ nJ, CALEND_POS_DATA ],; 
										 DiaSemana( aTabCalend[ nJ , CALEND_POS_DATA ] ),;
										 { { If( 	aTabCalend[ nJ, CALEND_POS_TIPO_DIA ] == "S" .Or. ; 
										 		 	aTabCalend[ nJ, CALEND_POS_TIPO_DIA ] == "N", ; 
										 		 	aTabCalend[ nJ, CALEND_POS_HORA ], "Folga" ) } } } )
					
					nPos := Len(aFuncEfe)							 
				Else
					aAdd( aFuncEfe[nPos,3], { If( 	aTabCalend[ nJ, CALEND_POS_TIPO_DIA ] == "S" .Or. ; 
														aTabCalend[ nJ, CALEND_POS_TIPO_DIA ] == "N",; 
														aTabCalend[ nJ, CALEND_POS_HORA ], "Folga" ) } )				 
				EndIf
				
				nPosHor := Len(aFuncEfe[nPos,3])
				
			Else
			
				aAdd( aFuncEfe[nPos,3,nPosHor], If( 	aTabCalend[ nJ, CALEND_POS_TIPO_DIA ] == "S" .Or. ;
															aTabCalend[ nJ, CALEND_POS_TIPO_DIA ] == "N",;
															aTabCalend[ nJ, CALEND_POS_HORA ], "Folga" ) )
				
			EndIf
			
		Next nJ
	
	EndIf

Next nI

oModelZZX:SetNoInsertLine(.F.)
oModelZZX:SetNoDeleteLine(.F.)
oModelZZY:SetNoInsertLine(.F.)
oModelZZY:SetNoDeleteLine(.F.)

// Carrega todos as informacoes do efetivo
For nI:=1 To Len(aFuncEfe)

	If nI > 1
		oModelZZX:AddLine()	
	EndIf
	
	oModelZZX:LoadValue( aEfetivo[1,2], aFuncEfe[nI,2] )
	oModelZZX:LoadValue( aEfetivo[2,2], aFuncEfe[nI,1] )

	For nJ:=1 To Len(aFuncEfe[nI,3])
	
		cHorario := ""			
		nHorExt  := 0
			
		If MV_PAR04 == 1		
			
			For nX:=1 To Len(aFuncEfe[nI,3,nJ])
			
				If AllTrim(aFuncEfe[nI,3,nJ,nX]) == "Folga"
					cHorario := aFuncEfe[nI,3,nJ,nX]
					Exit	
				EndIf
			
				nHorExt += aFuncEfe[nI,3,nJ,nX]			
				cHorario += TransForm(aFuncEfe[nI,3,nJ,nX], "@E 99.99")
				
				If (nX+1) <= Len(aFuncEfe[nI,3,nJ])
					If (nX%2) == 0
						cHorario += " / "
					Else
						cHorario += " - "
					EndIf
				EndIf					
								
			Next nX
			
			If nHorExt == 0
				cHorario := "Folga"
			EndIf				
			
		Else 	
		
			If AllTrim(aFuncEfe[nI,3,nJ,1]) == "Folga"
				cHorario := "Folga"
			Else
				For nX:=1 To Len(aFuncEfe[nI,3,nJ])
					nHorExt += aFuncEfe[nI,3,nJ,nX]				
				Next nX
				If nHorExt == 0
					cHorario := "Folga"
				Else 
					cHorario := aFuncEfe[nI,3,nJ,1]															
				EndIf
			EndIf
						
			If Alltrim(cHorario) <> "Folga"
				cHorario := TransForm( cHorario, "@E 99.99" )
				cHorario += " - " + TransForm( aFuncEfe[nI,3,nJ,Len(aFuncEfe[nI,3,nJ])], "@E 99.99" )	
			EndIf					
			
		EndIf
		
		oModelZZX:LoadValue( aEfetivo[(nJ+2),2], Alltrim(cHorario) )	
		
	Next nJ

Next nI

// Carrega todos as informacoes da cobertura
For nI:=1 To Len(aFuncCob)

	If nI > 1
		oModelZZY:AddLine()
	EndIf
	
	For nJ:=1 To Len(aFuncCob[nI])
		oModelZZY:LoadValue( aCobertura[nJ,2], aFuncCob[nI,nJ] )
	Next nJ

Next nI

oModelZZX:SetNoInsertLine(.T.)
oModelZZX:SetNoDeleteLine(.T.)
oModelZZY:SetNoInsertLine(.T.)
oModelZZY:SetNoDeleteLine(.T.)

//Retirar mensagem de alteração de formulario no momento de fechar
oModel:lModify := .F.

FwRestRows( aSaveRows )

Return(Nil)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580AStru()
Carrega a estrutura do objeto para a visualização da escala

@sample 	At580AStru()

@param  	oStruct, Objeto, objeto da estrutura a ser carregada
@param  	lView, Logico, Indica se a estrutura a ser carregada é do Model
@param  	cTipo, String, Indica qual tipo de estrutura deve ser carregada

@author 	Serviços
@since 		09/06/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At580AStru( oStruct, lModel, cTipo )

Local aCfgEsc  := {}
Local aCabGrid := {}
Local aAuxGrid := {}
Local oMdlEsc  := At580GetMdl()
Local cTitCmp  := ""
Local cNomCmp  := ""
Local cNumVis  := ""
Local cTipCob  := ""

Local nI, nFunc, cFunc
Local oMdlAux
                
If lModel

	/* Estutura para a criação de campos no model

		[01] C Titulo do campo
		[02] C ToolTip do campo
		[03] C identificador (ID) do Field
		[04] C Tipo do campo
		[05] N Tamanho do campo
		[06] N Decimal do campo
		[07] B Code-block de validação do campo
		[08] B Code-block de validação When do campo
		[09] A Lista de valores permitido do campo
		[10] L Indica se o campo tem preenchimento obrigatório
		[11] B Code-block de inicializacao do campo
		[12] L Indica se trata de um campo chave
		[13] L Indica se o campo pode receber valor em uma operação de update.
		[14] L Indica se o campo é virtual
                    	
	*/  

	If cTipo == "TDW" // Dados da Escala	
	
		oStruct:AddField(	STR0004, STR0004, "TDW_DATINI", "D", 8, 0, Nil, Nil, Nil, Nil,;
							Nil, Nil, Nil, .T. ) // "Data Inicial"

		oStruct:AddField(	STR0005, STR0005, "TDW_DATFIM", "D", 8, 0, Nil, Nil, Nil, Nil,;
                    		Nil, Nil, Nil, .T. )	// "Data Final"

		oStruct:AddField(	STR0006, STR0006, "TDW_CALEND", "C", 6, 0, Nil, Nil, Nil, Nil,;
                    		Nil, Nil, Nil, .T. )	// "Calendario"
                    	
		oStruct:AddField(	STR0007, STR0007, "TDW_DESCAL", "C", 50, 0, Nil, Nil, Nil, Nil,; 
                    		Nil, Nil, Nil, .T. )  // "Descrição"                  		
                    		
	ElseIf cTipo == "ZZX" .Or. cTipo == "ZZY" 	
		
		oStruct:AddField(	STR0008, STR0008, cTipo + "_SEMANA", "C", 14, 0, Nil, Nil, Nil, Nil,;
							Nil, Nil, Nil, .T. )	// "Semana"
				
		oStruct:AddField(	STR0009, STR0009, cTipo + "_DATA", "D", 8, 0, Nil, Nil, Nil, Nil,;
							Nil, Nil, Nil, .T. ) // "Data"
							
	EndIf

Else

	/* Estutura para a criação de campos na view	
		
		[01] C Nome do Campo
		[02] C Ordem
		[03] C Titulo do campo  
		[04] C Descrição do campo  
		[05] A Array com Help
		[06] C Tipo do campo
		[07] C Picture
		[08] B Bloco de Picture Var
		[09] C Consulta F3
		[10] L Indica se o campo é editável
		[11] C Pasta do campo
		[12] C Agrupamento do campo
		[13] A Lista de valores permitido do campo (Combo)
		[14] N Tamanho Maximo da maior opção do combo
		[15] C Inicializador de Browse
		[16] L Indica se o campo é virtual
		[17] C Picture Variável
	
	*/

	If cTipo == "TDW" // Dados da Escala
	
		oStruct:AddField( "TDW_DATINI", "04", STR0004, STR0004, Nil, "D", "@!", NIL, "", .F.,; 
							NIL	, NIL, NIL, NIL, NIL, .T., NIL )	// "Data Inicial"
							
		oStruct:AddField( "TDW_DATFIM", "05", STR0005, STR0005, Nil, "D", "@!", NIL, "", .F.,; 
							NIL	, NIL, NIL, NIL, NIL, .T., NIL )	// "Data Final"
							
		oStruct:AddField( "TDW_CALEND", "06", STR0006, STR0006, Nil, "C", "@!", NIL, "", .F.,; 
							NIL	, NIL, NIL, NIL, NIL, .T., NIL )	// "Calendario"
							
		oStruct:AddField( "TDW_DESCAL", "07", STR0007, STR0007, Nil, "C", "@!", NIL, "", .F.,; 
							NIL	, NIL, NIL, NIL, NIL, .T., NIL )	// "Descrição"
	
	ElseIf cTipo == "ZZX" .Or. cTipo == "ZZY"  
	
		oStruct:AddField( cTipo + "_SEMANA", "01", STR0008, STR0008, Nil, "C", Nil, NIL, "", .F.,;		 
							NIL	, NIL, NIL, NIL, NIL, .T., NIL )	// "Semana"	
							
		oStruct:AddField( cTipo + "_DATA", "02", STR0009, STR0009, Nil, "D", "@!", NIL, "", .F.,; 
							NIL	, NIL, NIL, NIL, NIL, .T., NIL )	// "Data"							
							
	EndIf
 
EndIf    

// Grid dinamico para a construção da visualização da escala
If cTipo == "ZZX" .Or. cTipo == "ZZY"

	If cTipo == "ZZX" .AND. VALTYPE(oMdlEsc) == 'O'
		oMdlAux := oMdlEsc:GetModel("TDXDETAIL")
		cTipCob := "TDX_TIPO"
	ElseIf VALTYPE(oMdlEsc) == 'O'
		oMdlAux := oMdlEsc:GetModel("TGXDETAIL")
		cTipCob := "TGX_TIPO"
	EndIf
	If VALTYPE(oMdlAux) == "O"
		For nI:=1 To oMdlAux:Length()
		
			oMdlAux:GoLine(nI)
			
			If oMdlAux:IsDeleted()
				Loop
			EndIf
			
			cNomCmp := If( cTipo == "ZZX", STR0010 + Alltrim(oMdlAux:GetValue("TDX_TURNO")) + ;	// "(Turno: " 
												STR0011 + Alltrim(oMdlAux:GetValue("TDX_SEQTUR")) + STR0012,; 	// " Seq.: " #") Funcionario"
			 					     			X3Combo(cTipCob, oMdlAux:GetValue(cTipCob) ) )
			
			aAdd( aCfgEsc,  { cNomCmp, oMdlAux:GetValue(cTipCob) } )
			aAdd( aCabGrid, { cNomCmp, "", oMdlAux:GetValue(cTipCob),;
								If( cTipo == "ZZY", oMdlAux:GetValue("TGX_ITEM"), "" ) } )
			
	
		Next nI
	EndIf
	// Ordena os tipos de configuração
	If cTipo == "ZZY"
		aSort( aCfgEsc , Nil, Nil, {|x,y| x[2] < y[2] } )
		aSort( aCabGrid, Nil, Nil, {|x,y| x[3] < y[3] } )
	EndIf
		
	cFunc := "@#"
			
	For nI:=1 To Len(aCfgEsc)				
				
		If cFunc <> aCfgEsc[nI,2]
			cFunc := aCfgEsc[nI,2]
			nFunc := 0
		EndIf 
		
		nFunc ++
		
		cTitCmp := AllTrim(aCfgEsc[nI,1] + " " + StrZero(nFunc,2))						
		cNomCmp := cTipo + "_F" + StrZero(nI,3)
		cNumVis := StrZero(nI+3,2)
		
		aCabGrid[nI,1] := cTitCmp
		aCabGrid[nI,2] := cNomCmp		
		
		If lModel
		
			oStruct:AddField(	cTitCmp, cTitCmp, cNomCmp, "C",; 
								If( MV_PAR04 == 1, 61, 20 ), 0, Nil, Nil, Nil, Nil,;
								Nil, Nil, Nil, .T. )
							
		Else
		
			oStruct:AddField( cNomCmp, cNumVis, cTitCmp, cTitCmp, Nil, "C", "@!", Nil, "", .F.,; 
								NIL	, NIL, NIL, Nil, NIL, .T., NIL )
										
		EndIf
	
	Next nI

	If Len(aCabGrid) > 0
		
		aAdd( aAuxGrid, { STR0013, cTipo + "_SEMANA", "", "" } )	// "Semana"
		aAdd( aAuxGrid, { STR0014, cTipo + "_DATA"  , "", "" } )	// "Data"
		
		For nI:=1 To Len(aCabGrid)
			aAdd( aAuxGrid, aCabGrid[nI] )			
		Next nI
		
		If cTipo == "ZZX"
			aEfetivo := aAuxGrid
		ElseIf cTipo == "ZZY"
			aCobertura	:= aAuxGrid		
		EndIf
	
	EndIf

EndIf 
            
                
Return(Nil)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580AEst()
	Carrega as estruturas dos grids para a visualizacao da escala

@sample 	At580AEst(cTipo)

@param 		cTipo, String, Tipo da estrutura a ser carregada

@author 	Serviços
@since 		26/06/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Static Function At580AEst(cTipo)

Local aRet  := {}
Local aCols := {}
Local aEstr := {}

Local nI

If cTipo == "ZZX"
	aEstr := aEfetivo
ElseIf cTipo == "ZZY"
	aEstr := aCobertura
EndIf

For nI:=1 To Len(aEstr)
	aAdd( aCols, "" )
Next nI

aAdd( aRet,{ 1, aCols } )

Return(aRet)


//--------------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} At580ACob()
	Carrega as informacoes da cobertura da visualizacao da escala

@sample 	At580ACob(dData,cDiaSem,aFunCob)

@param 		dData, Date, Data para verificacao da cobertura
@param 		cDiaSem, String, Dia da semana da data selecionada
@param 		aCfgCob, Array, Array com as configs de cobertura
@param 		aFunCob, Array, Array que devera receber a cobertura

@author 	Serviços
@since 		26/06/2014
/*/
//--------------------------------------------------------------------------------------------------------------------
Function At580ACob( dData, cDiaSem, aCfgCob, aFunCob )

Local cSemDia, nI, nJ, nLenCob

Local nPosCfg  := 0
Local nPosCob  := 0
Local nPosDat  := 0
Local nProcura := 0
Local cHorario := ""

Do Case
	Case Alltrim(cDiaSem) == STR0015	; cSemDia := "1"		// "Domingo"
	Case Alltrim(cDiaSem) == STR0016	; cSemDia := "2"		// "Segunda"
	Case Alltrim(cDiaSem) == STR0017	; cSemDia := "3"		// "Terca"
	Case Alltrim(cDiaSem) == STR0018	; cSemDia := "4"		// "Quarta"
	Case Alltrim(cDiaSem) == STR0019	; cSemDia := "5"		// "Quinta"
	Case Alltrim(cDiaSem) == STR0020	; cSemDia := "6"		// "Sexta"
	Case Alltrim(cDiaSem) == STR0021	; cSemDia := "7"		// "Sabado"
EndCase

nPosDat := aScan( aFunCob, { |x| x[2] == dData } ) 

If nPosDat > 0
	nLenCob := nPosDat
Else
	
	aAdd(aFunCob, Array(Len(aCobertura)) )
	
	nLenCob := Len(aFunCob)
	
	aFunCob[nLenCob,1] := cDiaSem
	aFunCob[nLenCob,2] := dData
	
EndIf

nPosCfg := aScan( aCfgCob, { |x| x[1] == cSemDia } )

If nPosCfg > 0

	For nI:=1 To Len(aCfgCob[nPosCfg,2])
	
		nPosCab  := aScan( aCobertura, { |x| x[4] == aCfgCob[nPosCfg,2,nI,1] } )
		cHorario := ""
		
		If MV_PAR04 == 1
			// Verifica a proxima posicao livre para preencher as informacoes da cobertura
			If !Empty(aFunCob[nLenCob,nPosCab]) .And. Alltrim(aFunCob[nLenCob,nPosCab]) <> "---" 						
				cHorario := aFunCob[nLenCob,nPosCab] + " / "		
			EndIf
								
			For nJ:=2 To Len(aCfgCob[nPosCfg,2,nI])		
				
				cHorario += TransForm(aCfgCob[nPosCfg,2,nI,nJ], "@E 99.99")
				
				If (nJ+1) <= Len(aCfgCob[nPosCfg,2,nI])
					If ((nJ-1)%2) == 0
						cHorario += " / "
					Else
						cHorario += " - "
					EndIf
				EndIf
				
			Next nJ
		
		Else 
		
			cHorario := TransForm( aCfgCob[nPosCfg,2,nI,2], "@E 99.99" )
			cHorario += " - " + TransForm( aCfgCob[nPosCfg,2,nI,Len(aCfgCob[nPosCfg,2,nI])], "@E 99.99" )
			
		EndIf
		
		aFunCob[nLenCob,nPosCab] := cHorario 
	
	Next nI
	
EndIf

For nI:=3 To Len(aFunCob[nLenCob])
	If Empty(aFunCob[nLenCob,nI])
		aFunCob[nLenCob,nI] := PadC("---", 20)
	EndIf
Next nI 

Return(Nil)