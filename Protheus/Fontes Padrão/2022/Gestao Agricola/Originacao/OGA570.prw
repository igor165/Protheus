#INCLUDE "OGA570.ch"
#INCLUDE "protheus.ch"
#iNCLUDE "parmtype.ch"
#INCLUDE "fwMvcDef.ch"

Static __aFardos := {}

/*{Protheus.doc} OGA570
Seleção de vinculação de fixações x ordens de entrega
@author jean.schulze
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
@param cCodCtr, characters, descricao
@type function
*/
Function OGA570(cCodCtr)
	Private _lAlgodao := .f. //verifica se é algodão
	
	//-- Proteção de Código
	If .Not. TableInDic('N8D')
		MsgNextRel() //-- É necessário a atualização do sistema para a expedição mais recente
		Return()
	Endif

	//verifica se há fixações para o contrato
	if OGX700SDCT(FwxFilial("NJR"), cCodCtr) == 0
		Help( , , STR0003, , STR0004, 1, 0 )  //Não existe Fixação de Preço para este contrato
		return()
	Endif
	
	//posiciona 
	dbSelectArea("NJR")
	dbSetOrder(1)
	if NJR->(dbSeek(FwxFilial("NJR")+cCodCtr))
		_lAlgodao :=  AGRTPALGOD(NJR->NJR_CODPRO)
		FWExecView(alltrim(NJR->NJR_DESCRI), 'VIEWDEF.OGA570', MODEL_OPERATION_UPDATE, , {|| .T. }) 
	endif
	
Return( )

/*{Protheus.doc} ModelDef
Modelo do MVC
@author jean.schulze
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Static Function ModelDef()
	Local oStruNJR  := FWFormStruct( 1, "NJR", { |x|  ALLTRIM(x) $ 'NJR_CODCTR, NJR_CODSAF, NJR_TIPALG, NJR_TOLENT'} )
	Local oStruNN8  := FWFormStruct( 1, "NN8", { |x| !ALLTRIM(x) $ 'NN8_CODCTR'} )
	Local oStruN8D  := FWFormStruct( 1, "N8D", { |x| !ALLTRIM(x) $ 'N8D_CODCTR, N8D_ITEMFX'} )
	Local oModel    := MPFormModel():New( "OGA570",  , {| oModel | PosModelo( oModel ) }, {| oModel | GrvModelo( oModel ) })
	Default _lAlgodao := .F.

	if _lAlgodao
		oStruN8D := FWFormStruct( 1, "N8D", { |x| !ALLTRIM(x) $ 'N8D_CODCTR, N8D_ITEMFX'} )
	else
		oStruN8D := FWFormStruct( 1, "N8D", { |x| !ALLTRIM(x) $ 'N8D_CODCTR'} )
		
		//validações dos campos
		oStruN8D:SetProperty( "N8D_ITEMFX", MODEL_FIELD_KEY, .f.)
		oStruN8D:SetProperty( "N8D_ITEMFX", MODEL_FIELD_VALID, {| oField | OGA570VDFX( oField ) } ) 
		oStruN8D:SetProperty( "N8D_QTDVNC", MODEL_FIELD_VALID, {| oField | OGA570VDQT( oField ) } ) 
		oStruN8D:SetProperty( "N8D_REGRA" , MODEL_FIELD_VALID, {| oField | OGA570VDRF( oField ) } ) 
		oStruN8D:SetProperty( "N8D_REGRA" , MODEL_FIELD_OBRIGAT, .t.) //obrigatório a regra
		//botões de ordenação
		oStruN8D:AddField('BTN BAIXO', "UP3" , 'N8D_MOVUP' 	, 'BT' , 1 , 0, {|| OGA570MOV(1)} , NIL , NIL, NIL, {||"UP3"}, NIL, .F., .T.)
		oStruN8D:AddField('BTN CIMA', "DOWN3", 'N8D_MOVDW' 	, 'BT' , 1 , 0, {|| OGA570MOV(2)} , NIL , NIL, NIL, {||"DOWN3"}, NIL, .F., .T.)
				
	endif
	
	//init padrao 
	oStruN8D:SetProperty( "N8D_SEQVNC" , MODEL_FIELD_INIT , {| x | x := fAutoIncre("N8D_SEQVNC") }  ) 
	oStruN8D:SetProperty( "N8D_ORDEM"  , MODEL_FIELD_INIT , {| x | x := fAutoIncre("N8D_ORDEM") }  ) 
	
	//tratamento de gatilho
	oStruN8D:AddTrigger( "N8D_ITEMFX", "N8D_CODCAD", { || .T. }, { | oField | fTrgCodCad( oField ) } )
	
	//contrato
	oModel:AddFields("NJRVISUL", Nil, oStruNJR )
	oModel:SetDescription( STR0001 ) //Fixações X Ordem de Entregas 
	
	//fixações de preço
	oModel:AddGrid( "NN8VISUL", "NJRVISUL", oStruNN8, , , ,, {|oGrid| LoadNN8(oGrid)})
	oModel:GetModel( "NN8VISUL" ):SetDescription( STR0002 )  //Fixações de Preço
	oModel:SetRelation( "NN8VISUL", { { "NN8_FILIAL", "xFilial( 'NN8' )" }, { "NN8_CODCTR", "NJR_CODCTR" }}, NN8->( IndexKey( 1 ) ) )
	
	if _lAlgodao
		//vinculos de entregas
		oModel:AddGrid( "N8DUNICO", "NN8VISUL", oStruN8D )
		oModel:GetModel( "N8DUNICO" ):SetOptional( .T. )
		oModel:GetModel( "N8DUNICO" ):SetDescription( STR0001 ) //Fixações X Ordem de Entregas 
		oModel:SetRelation( "N8DUNICO", { { "N8D_FILIAL", "xFilial( 'N8D' )" }, { "N8D_CODCTR", "NJR_CODCTR" }, { "N8D_ITEMFX", "NN8_ITEMFX" } }, N8D->( IndexKey( 1 ) ) )
		
		//------------------
		// adiciona calculo 
		//------------------
		oModel:AddCalc( 'OGA570CALC' ,"NN8VISUL" ,"N8DUNICO", 'N8D_QTDFAR' ,'TOTFDI'  , 'SUM',,, STR0006 ) //'Total de Fardos'
		oModel:AddCalc( 'OGA570CALC' ,"NN8VISUL" ,"N8DUNICO", 'N8D_QTDVNC' ,'TOTLIQU' , 'SUM',,, STR0008 ) //'Peso liquido Total'
		oModel:AddCalc( 'OGA570CALC' ,"NN8VISUL" ,"N8DUNICO", 'N8D_QTDBTO' ,'TOTBRUTO', 'SUM',,, STR0007 ) //'Peso Bruto Total'
	else
		oModel:AddGrid( "N8DUNICO", "NJRVISUL", oStruN8D,,{|oGrid| fVldN8D(oGrid)}, {|oGridModel, nLine, cAction| fLinPreN8D(oGridModel, nLine, cAction)} )
		oModel:GetModel( "N8DUNICO" ):SetOptional( .T. )
		oModel:GetModel( "N8DUNICO" ):SetDescription(STR0010 ) //Prioridade da Fixação.
		oModel:SetRelation( "N8DUNICO", { { "N8D_FILIAL", "xFilial( 'N8D' )" }, { "N8D_CODCTR", "NJR_CODCTR" } }, N8D->( IndexKey( 1 ) ) )
		//------------------
		// adiciona calculo 
		//------------------
		oModel:AddCalc( 'OGA570CALC' ,"NJRVISUL" ,"N8DUNICO", 'N8D_QTDVNC' ,'TOTLIQU' , 'SUM',,, STR0008 ) //'Peso liquido Total'
	endif
	
	//inibe a gravação dos modelos abaixo
	oModel:SetOnlyQuery("NJRVISUL")
	oModel:SetOnlyQuery("NN8VISUL")
	

		
	oModel:SetActivate( 	{ | oModel | ActivateMD( oModel, oModel:GetOperation() ) } )
		
Return( oModel )

/*{Protheus.doc} ViewDef
Visualização do MVC
@author jean.schulze
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
@type function
*/
Static Function ViewDef()
	Local oStruNN8 := FWFormStruct( 2, "NN8", { |x|  ALLTRIM(x) $ 'NN8_ITEMFX, NN8_CODCAD, NN8_CODNGC, NN8_VERSAO, NN8_DATA, NN8_QTDFIX, NN8_QTDRES, NN8_QTDENT, NN8_QTDAGL, NN8_MOEDA, NN8_TXMOED, NN8_VLRUNI, NN8_TIPAGL'}  )
	Local oStruN8D := nil
	Local oModel   := FWLoadModel( "OGA570" )
	Local oView    := FWFormView():New()
	Local oCalc    := FWCalcStruct( oModel:GetModel( 'OGA570CALC') ) // Instacia FwCalEstruct
	Default _lAlgodao := .F.
		
	if _lAlgodao
		oStruN8D := FWFormStruct( 2, "N8D", { |x| !ALLTRIM(x) $ 'N8D_CODCTR, N8D_ITEMFX, N8D_SEQVNC, N8D_VALOR, N8D_ORDEM, N8D_REGRA, N8D_CODCAD'} )
	else
		oStruN8D := FWFormStruct( 2, "N8D", { |x| !ALLTRIM(x) $ 'N8D_CODCTR, N8D_BLOCO, N8D_QTDBTO, N8D_TIPO, N8D_QTDFAR, N8D_FILORG, N8D_SEQVNC, N8D_ORDEM, N8D_CODRES'} )
		
		//libera a edição de itens
		oStruN8D:SetProperty( "N8D_QTDVNC" , MVC_VIEW_CANCHANGE, .T. )
		oStruN8D:SetProperty( "N8D_ITEMFX" , MVC_VIEW_CANCHANGE, .T. )
		
		//novos botões
		oStruN8D:AddField( "N8D_MOVUP"  ,'01' , "- ", "UP3"    , {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T. )
		oStruN8D:AddField( "N8D_MOVDW"  ,'02' , "+ ", "DOWN3"  , {} , 'BT' ,'@BMP', NIL, NIL, .T., NIL, NIL, NIL, NIL, NIL, .T. )		
	endif	
	
	oView:SetModel( oModel )
			
	oView:CreateHorizontalBox( "TOP" , 40 )
	oView:CreateHorizontalBox( "BOTTOM" , 50)
	oView:CreateHorizontalBox( "CALC", 10 )
		
	oView:AddGrid( "VIEW_NN8", oStruNN8, "NN8VISUL" )
	oView:AddGrid( "VIEW_N8D", oStruN8D, "N8DUNICO" )
	oView:AddField('VIEW_CALC', oCalc  , "OGA570CALC" )
	
	oView:SetOwnerView( "VIEW_NN8", "TOP" )
	oView:SetOwnerView( "VIEW_N8D", "BOTTOM" )
	oView:SetOwnerView( "VIEW_CALC"	,"CALC" )
		
	oView:EnableTitleView( "VIEW_NN8" )
	oView:EnableTitleView( "VIEW_N8D" )
	oView:EnableTitleView( "VIEW_CALC" )
	
	oView:SetViewProperty("VIEW_N8D", "ENABLENEWGRID")
	oView:SetViewProperty("VIEW_N8D", "GRIDNOORDER")
	
	if _lAlgodao
		oView:SetViewProperty("VIEW_NN8", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| fSelecFard(oView)}}) 
		oView:AddUserButton( STR0005, 'SELFAR', {| oView | fSelecFard(oView) } ) //"Selecionar Fardos"
	else
		oView:SetViewProperty("VIEW_NN8", "GRIDDOUBLECLICK", {{|oFormulario,cFieldName,nLineGrid,nLineModel| fInsertGrao(oFormulario,cFieldName,nLineGrid,nLineModel)}}) 
		oView:SetViewAction( 'DELETELINE', { |oView,cIdView,nNumLine| fUpdQtdVnc( oView,cIdView,nNumLine) } )
		oView:SetViewAction( 'UNDELETELINE', { |oView,cIdView,nNumLine| fUpdQtdVnc( oView,cIdView,nNumLine) } )		
	endif
		
		
	oView:SetCloseOnOk( {||.t.} )
	
Return( oView )

/*{Protheus.doc} ActivateMD
Ativação do Modelo
@author jean.schulze
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@param nOperation, numeric, descricao
@type function
*/
Static Function ActivateMD( oModel, nOperation )
	Local oModelNJR  := oModel:GetModel("NJRVISUL")
	Local oModelNN8  := oModel:GetModel("NN8VISUL")
	Local oModelN8D  := oModel:GetModel("N8DUNICO")
	Local aSaveLines := FWSaveRows()
	Local aBlocos    := {}
	Local nA := 0
	Local nB := 0
	
	//reset
	__aFardos := {}
	/*__aFardos 
	    		[1] //item fixação
	 	    	[2] //dados dos blocos
	 		    [2][1] //sequencia do bloco
	 		    [2][2] //codigo do bloco
	 		    [2][3] //fardos
	 		    [2][3][1] //recno do fardo
	 		    [2][3][2] // está faturado? 	
	*/			
	if _lAlgodao
		//vamos buscar os fardos selecionados
		for nA := 1 to oModelNN8:Length()
			 oModelNN8:GoLine( nA)
			 
			 //reset
			 aBlocos    := {} 
			 //busca os blocos
			 For nB := 1 to oModelN8D:Length()
			     oModelN8D:GoLine( nB )
			     aAdd(aBlocos, {oModelN8D:GetValue("N8D_SEQVNC"), oModelN8D:GetValue("N8D_BLOCO") , fGetVinc(oModelNJR:GetValue("NJR_CODCTR"), oModelNN8:GetValue("NN8_ITEMFX"), oModelN8D:GetValue("N8D_SEQVNC") )})
			 next nB
			 
			 aAdd(__aFardos, { oModelNN8:GetValue("NN8_ITEMFX") , aBlocos })
		next nA 
		
		oModelNN8:goline(1)
		
		oModel:GetModel( "N8DUNICO" ):SetNoInsert( .t. )
		oModel:GetModel( "N8DUNICO" ):SetNoDelete( .t. )
	endif
	
	//bloqueia alteracao de dados
	oModel:GetModel( "NN8VISUL" ):SetNoDelete( .t. )
	oModel:GetModel( "NN8VISUL" ):SetNoInsert( .t. )
	oModel:GetModel( "NN8VISUL" ):SetNoUpdate( .t. )

	FWRestRows(aSaveLines)
		
return .t.

/*{Protheus.doc} LoadNN8
Reload da Grid do NN8
@author jean.schulze
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oGrid, object, descricao
@type function
*/
Static Function LoadNN8(oGrid)
	Local aStruct   := oGrid:oFormModelStruct:GetFields()
	Local nAt       := 0
	Local nX        := 0
	Local aRet      := {}
	Local aGrid     := {}
	
	aGrid := FormLoadGrid( oGrid )

	//remove os registros cancelados e aglutinados e entregues
	If ( nAt := aScan( aStruct, { |aX| aX[MODEL_FIELD_IDFIELD] == 'NN8_QTDFIX' } ) ) > 0 
		
		for nX := 1 to len(aGrid)
			if aGrid[nX][2][nAt] > 0
				aAdd( aRet, aGrid[nX])
			endif 	
		next nX
		
	else 
		aRet := FormLoadGrid( oGrid )
	EndIf

Return aRet

/*{Protheus.doc} PosModelo
Validação do Modelo
@author jean.schulze
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
static function PosModelo(oModel)
	Local oModelNJR  := oModel:GetModel( "NJRVISUL" )
	Local oModelNN8  := oModel:GetModel( "NN8VISUL" )
	Local oModelN8D  := oModel:GetModel( "N8DUNICO" )
	Local nQtdVinTot := 0
	Local aSaveLines := FWSaveRows()
	Local lRet       := .t.
	Local nQtdDisp   := 0
	Local nA         := 0
	
	if !_lAlgodao
		for nA := 1 to oModelNN8:Length()
				
				oModelNN8:GoLine( nA )
				
				//verifica a quantidade disponível
				nQtdDisp := (oModelNN8:GetValue("NN8_QTDFIX") * (1+(oModel:GetValue("NJRVISUL", "NJR_TOLENT") / 100))) // quantidade da fixação + tolerância do contrato - o que já foi entregue
				
				//verifica a quantidade vinculada	
				nQtdVinTot := fQtdVncNN8(oModelN8D, oModelNN8:GetValue("NN8_ITEMFX") )	 
								
				if  nQtdDisp < nQtdVinTot
					Help( , , STR0003, , STR0011, 1, 0 )
					FWRestRows(aSaveLines)
					return .f.
				endif
			  	
		next nA
		
		//valida as regras fiscais 
		DbSelectArea("NNY") 
		NNY->(DbSetOrder(1))
		If NNY->(DbSeek( xFilial("NNY") + oModelNJR:GetValue("NJR_CODCTR") ))
			While NNY->( !Eof() ) .and. alltrim(NNY->(NNY_FILIAL+NNY_CODCTR))= alltrim(xFilial("NNY") + oModelNJR:GetValue("NJR_CODCTR"))
				
				//valida as regras fiscais
				lRet := fGetSldRegra(oModel, NNY->NNY_ITEM , .t.)
				if valtype(lRet) <> "A" .and. !lRet
					Help( , , STR0003, , "A quantidade vinculada para as Regras Fiscais estão excedidas para a Previsão de Entrega: " + NNY->NNY_ITEM , 1, 0 )
					FWRestRows(aSaveLines)
					return .f.
				endif
				
				NNY->(DbSkip())
			EndDo		
		EndIf
		
		
	endif
			
	//reset rows
	FWRestRows(aSaveLines)
return .t.

/*{Protheus.doc} fVldN8D
Validação de quantidade do 
@author jean.schulze
@since 13/12/2017
@version 1.0
@return ${return}, ${return_description}
@param oGrid, object, descricao
@type function
*/
static function fVldN8D(oGrid)
	Local lret := .t.
	
	if !_lAlgodao
		if oGrid:GetValue("N8D_QTDVNC") <= 0
			Help( , , STR0003, , STR0015, 1, 0 )
			lret := .f.
		endif
	endif
	
return lret

/*{Protheus.doc} fTrgCodCad
Trigger de Atualização de Cadência
@author jean.schulze
@since 22/06/2018
@version 1.0
@return ${return}, ${return_description}
@param oField, object, descricao
@type function
*/
static function fTrgCodCad( oField )
	Local oModel     := oField:GetModel()
	Local oModelNN8  := oModel:GetModel("NN8VISUL")
	Local cCodCadenc := ""
		
	if oModelNN8:SeekLine( { {"NN8_ITEMFX", oField:GetValue("N8D_ITEMFX")  } } )
		cCodCadenc := oModelNN8:GetValue("NN8_CODCAD")
	endif
	
return cCodCadenc

/*{Protheus.doc} GrvModelo
Gravação do Modelo
@author jean.schulze
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
static function GrvModelo(oModel)
	Local lRetorno := .t.
	
	Begin Transaction
	
		if OGA570FARD(oModel) //faz as gravações dos fardos 
			lRetorno := FWFormCommit( oModel) //commit dos dados	
		else
			DisarmTransaction()  
			lRetorno := .f.			
		endif
	
	End Transaction
	
	if _lAlgodao .and. lRetorno 
		
		FwMsgRun(, {|| OGX016(FwxFilial("NJR"), oModel:GetValue("NJRVISUL", "NJR_CODCTR"))}, STR0016) // # "Aprovando Take-up..."
	  			
		//Recalcula Valores da regra FISCAL
		OGX055(FwxFilial("NJR"), oModel:GetValue("NJRVISUL", "NJR_CODCTR")) //não se faz necessário para granel, pois o tratamento é feito na fixação
	
	endif
	
return lRetorno

/*{Protheus.doc} OGA570FARD
Tratamento de Gravação para os Fardos e Vinculo
@author jean.schulze
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
*/
function OGA570FARD(oModel)
	Local oModelNN8  := oModel:GetModel("NN8VISUL")
	Local oModelNJR  := oModel:GetModel("NJRVISUL")
	Local oModelN8D  := oModel:GetModel("N8DUNICO")
	Local aSaveLines := FWSaveRows()
	Local lretorno   := .t.
	Local nA         := 0
	Local nB         := 0
	Local nC         := 0
	Local aFarDel    := {}
	Local nPosDel    := 0
	Local aFarInsrt  := {}
	Local aFarInativ := {}
	Local aRetorno   := {}
			
	//busca os fardos vinculados as fixações de preço
	for nA := 1 to oModelNN8:Length()
		 oModelNN8:GoLine( nA )
		 
		 if _lAlgodao
			 //remove os fardos que estão na fixação
			 aRecnos := fGetVinc(oModelNJR:GetValue("NJR_CODCTR"), oModelNN8:GetValue("NN8_ITEMFX"))
			 
			 //fora da consulta principal
			 for nB := 1  to len(aRecnos) 
				
				if (Select("DXI") == 0)
					DbSelectArea("DXI")
				endif
				
				if aRecnos[nB][2] <> "2" //SÓ O QUE NÃO ESTÁ FATURADO				
					DXI->(dbGoto(aRecnos[nB][1]))
					
					aaDD(aFarDel, { aRecnos[nB][1], DXI->DXI_ITEMFX} )		
					
					RecLock( "DXI", .F. )
					  	DXI->DXI_ITEMFX := ""
						DXI->DXI_ORDENT := ""
						DXI->DXI_VLBASE := 0   
					DXI->(MsUnLock())	
								
				endif			
			 next nB
				 
			 //recoloca os fardos na fixação
			 nPosNN8Ar := aScan( __aFardos, { |x| x[1] == oModelNN8:GetValue("NN8_ITEMFX") } )
			 
			 if nPosNN8Ar > 0 .and. len(__aFardos[nPosNN8Ar]) > 0 
			 	
			 	For nB := 1 to oModelN8D:Length()
			    	oModelN8D:GoLine( nB )
			    	
			    	// Localiza os fardos vinculados ao item do contrato no array
					If (nPos := aScan(__aFardos[nPosNN8Ar][2], { |x| x[1]+x[2] == oModelN8D:GetValue("N8D_SEQVNC")+oModelN8D:GetValue("N8D_BLOCO") } ) ) > 0
						aRecnos := aTail(__aFardos[nPosNN8Ar][2][nPos] )
						For nC := 1 To Len(aRecnos)
							
							DXI->(dbGoto(aRecnos[nC][1]))
							
							if aRecnos[nC][2] <> DXI->DXI_FATURA 
								Help( , , STR0003, , STR0019 + DXI->DXI_ETIQ + STR0020, 1, 0 )  //O fardo de etiqueta ... tem diferença em seu status de faturamento.
								FWRestRows(aSaveLines)
								return .f.
							endif
							
							if !(aRecnos[nC][2] = "2" .and. aRecnos[nC][3] = "1") //só o que não está faturado	
								lRegFard := .t.
								
								//verifica se vai ser deletado/Update
								if len(aFarDel) > 0					
									if (nPosDel := aScan( aFarDel, {|x| x[1] == aRecnos[nC][1] } )) > 0 
										if aFarDel[nPosDel][2] == oModelNN8:GetValue("NN8_ITEMFX")
											aDel(aFarDel,nPosDel ) 	//remover dos deletados
											ASIZE(aFarDel, len(aFarDel)-1)
											lRegFard := .f.													   										
										endif								
									endif
								endif
								
								if lRegFard
									//criar mov de fardo
									aaDD(aFarInsrt , {{"N9D_FILIAL", DXI->DXI_FILIAL	},;
													{"N9D_SAFRA" , DXI->DXI_SAFRA  	},;
												 	{"N9D_FARDO" , DXI->DXI_ETIQ	},;
												 	{"N9D_TIPMOV", "03" 			},; //fixação
												 	{"N9D_DATA"  , dDAtaBase 		},;
												 	{"N9D_PESINI", DXI->DXI_PSLIQU 	},;
												 	{"N9D_ENTLOC", DXI->DXI_PRDTOR 	},;
												 	{"N9D_LOJLOC", DXI->DXI_LJPRO 	},;
												 	{"N9D_STATUS", "2" 				},; //Ativo
												 	{"N9D_ITEFIX", oModelNN8:GetValue("NN8_ITEMFX") },;
												 	{"N9D_FILORG", FwXFilial("NJR")	} ;
												   })
								endif
								
								RecLock( "DXI", .F. )
									DXI->DXI_ITEMFX := oModelNN8:GetValue("NN8_ITEMFX")
									DXI->DXI_ORDENT := oModelN8D:GetValue("N8D_SEQVNC") // Item da reserva
									DXI->DXI_VLBASE := oModelNN8:GetValue("NN8_VLRUNI")
								DXI->(MsUnLock())
							endif
						Next nC
					EndIf
						
				nExt nB
			 			
			 endif
		 endif
		 
		 //popula saldo na nn8
		 dbSelectArea( "NN8" )
		 dbSetOrder( 1 )
		 if dbSeek( FwxFilial( "NN8" ) + oModelNJR:GetValue("NJR_CODCTR") + oModelNN8:GetValue("NN8_ITEMFX"))
	
			If RecLock( "NN8", .F. )
				NN8->NN8_QTDRES :=  oModelNN8:GetValue("NN8_QTDRES")
		    	NN8->(MsUnLock())
		    EndIf
			
		 endif	 
	
	next nA 
	
	//inativar itens
	if len(aFarDel) > 0 .and. lretorno
		
		//lista itens que serão deletados
		for nB := 1  to len(aFarDel) 
		
			if (Select("DXI") == 0)
				DbSelectArea("DXI")
			endif
							
			DXI->(dbGoto(aFarDel[nB][1]))
			aAdd(aFarInativ,  { /*aFilds*/{{"N9D_STATUS","3"}}, /*aChave*/{{DXI->DXI_FILIAL},; // Filial Origem Fardo
																		   {FwXFilial("NJR")},; // FILIAL CTR
																		   {DXI->DXI_SAFRA},; // Safra
																		   {DXI->DXI_ETIQ},; // Etiqueta do Fardo
																		   {"03"},; // Tipo de Movimentação ("03" - Fixação)
																		   {"2"}} }) // Ativo
		next nB		
						
		aRetorno := AGRMOVFARD(, 2, 2, , aFarInativ) // Inativa os fardos removidos	
		if !empty(aRetorno[2])
			Help( , , STR0003, , aRetorno[2], 1, 0 )  //erro gravação de fardo
			lretorno := .f.
		endif
														 
	endif
		
	//gravamos os itens da reserva
	if len(aFarInsrt) > 0 .and. lretorno
		aRetorno :=  AGRMOVFARD(aFarInsrt, 1) // Passa os fardos para gravação
		if !empty(aRetorno[2])
			Help( , , STR0003, , aRetorno[2], 1, 0 )  //erro gravação de fardo
			lretorno := .f.
		endif	
	endif
		
	FWRestRows(aSaveLines)	
		
return lretorno


/*{Protheus.doc} fGetVinc
Obtem os Fardos que estão vinculados
@author jean.schulze
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
@param cCodCtr, characters, descricao
@param cItemFx, characters, descricao
@param cOrdem, characters, descricao
@type function
*/
static function fGetVinc(cCodCtr, cItemFx, cSeqVnc)
	Local cAliasDXI   := GetNextAlias()
	Local aRecnos     := {}
	Local cFiltro     := iif(!empty(cSeqVnc), "% AND DXI.DXI_ORDENT = '"+cSeqVnc+"'%", "%%")
	
	Default cSeqVnc := ""
		
	BeginSQL Alias cAliasDXI
		SELECT DXI.DXI_FILIAL, DXI.DXI_SAFRA, DXI.DXI_ETIQ, DXI.DXI_FATURA, DXI.DXI_TIPPRE,  DXI.R_E_C_N_O_ AS DXI_RECNO 
		  FROM %table:DXI% DXI
		  INNER JOIN %table:N9D% N9D ON N9D.N9D_FILIAL = DXI.DXI_FILIAL  
						     		AND N9D.N9D_SAFRA  = DXI.DXI_SAFRA 
									AND N9D.N9D_FARDO  = DXI.DXI_ETIQ 
									AND N9D.%notDel%		
		WHERE DXI.%notDel%	
	      AND N9D.N9D_FILORG  = %xFilial:NJR% //filial da reserva segue a filial do contrato
	      AND N9D.N9D_CODCTR  = %exp:cCodCtr%
	      AND N9D.N9D_STATUS  = "2"
	      AND N9D.N9D_TIPMOV  = "03"
	      %exp:cFiltro%
	      AND DXI.DXI_ITEMFX  = %exp:cItemFx%	    
	EndSql
	
	dbSelectArea(cAliasDXI)
	(cAliasDXI)->( dbGoTop() )
	While (cAliasDXI)->(!Eof())
		
		aAdd(aRecnos, {(cAliasDXI)->DXI_RECNO, (cAliasDXI)->DXI_FATURA, (cAliasDXI)->DXI_TIPPRE  })

		(cAliasDXI)->( dbSkip() )	
	EndDo
		
return aRecnos

/*{Protheus.doc} fSelecFard
Função para seleção de Fardos
@author jean.schulze
@since 23/11/2017
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
*/
Function fSelecFard(oView, lAuto,oModel)
	Local oModel    := Iif(lAuto, oModel, oView:GetModel())
	Local oModelN8D := oModel:GetModel("N8DUNICO")
	Local oModelNN8 := oModel:GetModel("NN8VISUL")	
	Local cTiposCtr := IIF(allTrim(oModel:GetValue("NJRVISUL", "NJR_TIPALG") ) == "-", "", oModel:GetValue("NJRVISUL", "NJR_TIPALG") ) 
	Local nTolen    := oModel:GetValue("NJRVISUL", "NJR_TOLENT")
	Local nQtdCad   := oModel:GetValue("NN8VISUL", "NN8_QTDFIX")
	Local cItemFx   := oModel:GetValue("NN8VISUL", "NN8_ITEMFX")
	Local cCodCtr   := oModel:GetValue("NJRVISUL", "NJR_CODCTR")
	Local cSafra    := oModel:GetValue("NJRVISUL", "NJR_CODSAF")
	Local nQtdUsada := oModel:GetValue("NN8VISUL", "NN8_QTDENT")
	Local cCodCaden := oModel:GetValue("NN8VISUL", "NN8_CODCAD")
	Local aFilHVI   := {}
	Local aGrpBlc   := {}
	Local nCont     := 0
	Local nX        := 0
	Local nA        := 0
	Local nB        := 0
	Local nPosNN8Ar := aScan( __aFardos, { |x| x[1] == cItemFx } ) //acha a posição do nn8 na lista de fardos
	Local aFardos   := aClone(__aFardos[nPosNN8Ar][2])
	Local aFardoExc := {}
	Local aOptions  := {} 
	Local aFaturado := {} 
	Local lFaturado := .f. //informa se temos alguma linha que foi faturada 
	Local nPosFar   := 0
	Local aFarSel   := aClone(__aFardos[nPosNN8Ar][2])
		
	//buscar fardos que não devem estar na listagem
	for nx := 1 to len(__aFardos)
		//verificar todos os outros recnos diferente da fixação, se possui bloco para a fixação e se há fardos selecionados
		if nx <> nPosNN8Ar .and. len(__aFardos[nx][2]) >= 1 .and. !Empty(__aFardos[nx][2][1][2])
			//Bloco
			for nA := 1 to len(__aFardos[nx][2])
				for nB := 1 to len(__aFardos[nx][2][nA][3])
					//Adiciona recnos dos fardos no array aFardoExc
					Aadd(aFardoExc, __aFardos[nx][2][nA][3][nB][1])
				next nB				
			next nA		
		endif
	next nx
	
	//remove segunda posicao de faturado
	for nA := 1 to len(aFarSel)
		for nB := 1 to len(aFarSel[nA][3])
			aFarSel[nA][3][nB] := aFarSel[nA][3][nB][1]
		next nB	
	next nA
		
	if !empty(cTiposCtr) //para ter tipos aceitavéis tem que existir tipo padrão
		dbSelectArea( "N7E" )
		N7E->( dbSetOrder( 1 ) )
		N7E->( dbSeek( xFilial( "N7E" ) + cCodCtr ) )
		While !( Eof() ) .And. N7E->( N7E_FILIAL ) + N7E->( N7E_CODCTR ) == xFilial( "N7E" ) + cCodCtr
		    cTiposCtr += " OU " + N7E->( N7E_TIPACE )
			N7E->( dbSkip() )	
		EndDo
	endif
	
	//monta o array de hvi
	dbSelectArea( "N7H" )
	N7H->( dbSetOrder( 1 ) )
	N7H->( dbSeek( xFilial( "N7H" ) + cCodCtr ) )
	While !( Eof() ) .And. N7H->( N7H_FILIAL ) + N7H->( N7H_CODCTR ) == xFilial( "N7H" ) + cCodCtr
	    aADD(aFilHVI,{N7H->( N7H_CAMPO ),N7H->( N7H_HVIDES ) ,N7H->( N7H_VLRINI ), N7H->( N7H_VLRFIM ) })
		N7H->( dbSkip() )	
	EndDo
	
	//monta filtro da DXI
	cFiltroDXI := "DXI_SAFRA = '"+alltrim(cSafra)+"' AND ((DXI_FATURA < '2') OR (DXI_FATURA = '2' and DXI_TIPPRE  = '2' ))" 

	//monta filtro da N9D
	cFiltroN9D := "N9D_TIPMOV = '02' AND N9D_CODCTR = '"+alltrim(cCodCtr)+"' AND N9D_FILORG = '"+FwXFilial("NJR")+"' AND  N9D_ITEETG = '"+cCodCaden+"'" 
	
	//monta as opções
	if !empty(cCodCtr)
		aAdd(aOptions, {'_cCodCtr', cCodCtr})  
	endif
	
	aFarSelec := AGRX720(cFiltroDXI, cTiposCtr, @aFilHVI, cFiltroN9D, aOptions , aFarSel , aFardoExc , nQtdCad, nTolen, nQtdUsada, ,cCodCtr,lAuto) //consulta especifica de fardos			

	//se for automático e não tiver fardinhos, saimos da rotina
	If lAuto .AND. Empty(aFarSelec[2]) 
		return .t.
	EndIf

	FWModelActive(oModel, .t.) //tratamento para selecionar o model atual
		
	if aFarSelec[1] //foi clicado em ok
	
		//ativar o update do model
		oModelN8D:SetNoInsertLine(.F.)
		oModelN8D:SetNoDeleteLine(.F.)

		oModelNN8:SetNoUpdateLine(.F.)
           
		//monta a agrupação de bloco X fardo
		For nCont := 1  to Len(aFarSelec[2]) //listagem de dados
	        nPos = AScan(aGrpBlc, {|x| AllTrim(x[1]+x[2]+x[4]) ==  AllTrim(aFarSelec[2][nCont][1]+aFarSelec[2][nCont][3]+aFarSelec[2][nCont][8] )} ) /*busca o bloco por filial + bloco + codigo da reserva*/
	        
	        if npos > 0 //já está no array principal
	        	aADD(aGrpBlc[npos][3],aFarSelec[2][nCont][1]+aFarSelec[2][nCont][4]+aFarSelec[2][nCont][5])
	        else 
	        	aADD(aGrpBlc,{aFarSelec[2][nCont][1],aFarSelec[2][nCont][3] ,{aFarSelec[2][nCont][1]+aFarSelec[2][nCont][4]+aFarSelec[2][nCont][5] }, aFarSelec[2][nCont][8]}) //array(filial+bloco, array(filial+fardo))	
	        endif
	    Next nCont
	    
	    nQtdfatur := 0
	    	
				
	    __aFardos[nPosNN8Ar][2] := {} //reset
	      
	    //Deleta td, e verifica se tem algum para reativa, exceto as linhas que foram consumidas
	    For nX := 1 to oModelN8D:Length()
		    	oModelN8D:GoLine( nX )
		    	if oModelN8D:GetValue("N8D_QTDFAT") <= 0
			    	oModelN8D:DeleteLine() //atualiza valores dos calculos também
			    	oModelN8D:LoadValue("N8D_FILORG", "")
					oModelN8D:LoadValue("N8D_BLOCO" , "")	
					oModelN8D:LoadValue("N8D_TIPO"  , "")	
					oModelN8D:LoadValue("N8D_CODRES", "")		
					oModelN8D:LoadValue("N8D_QTDVNC", 0)
					oModelN8D:LoadValue("N8D_QTDFAR", 0)
					oModelN8D:LoadValue("N8D_QTDBTO", 0)
				else
					nQtdfatur += oModelN8D:GetValue("N8D_QTDFAT")
					nPsLiqu   := 0
					nPsBrut   := 0
					//busca o bloco certo no afardos
					nPosFar := aScan( aFardos, { |x| x[1]+x[2] == oModelN8D:GetValue("N8D_SEQVNC")+oModelN8D:GetValue("N8D_BLOCO") } )
					aFaturado := {}
					
					if nPosFar > 0 //já está no array principal.
					   For nA := 1 to len(aFardos[nPosFar][3])
					   		if aFardos[nPosFar][3][nA][2] == "2" //faturado
					   			aadd(aFaturado, aFardos[nPosFar][3][nA])
					   			dbSelectArea( "DXI" )
					   			DXI->( dbGoto( aFardos[nPosFar][3][nA][1] ) )
					   			nPsLiqu    += DXI->DXI_PSLIQU
								nPsBrut    += DXI->DXI_PSBRUT
					   		endif
					   next nA  
					endif
					
					aADD(__aFardos[nPosNN8Ar][2], { oModelN8D:GetValue( "N8D_SEQVNC"), oModelN8D:GetValue( "N8D_BLOCO"), aFaturado } )
					
					oModelN8D:SetValue("N8D_QTDVNC", nPsLiqu)
					oModelN8D:SetValue("N8D_QTDFAR", len(aFaturado))
					oModelN8D:SetValue("N8D_QTDBTO", nPsBrut)
					
				endif
		nExt nX
		
		oModelNN8:SetValue("NN8_QTDRES", nQtdfatur)
							   	  	    
	    nCont     := 1 //counter 
	    lExtsOne  := .f. //verifica se existe a linha 1
	    
	    if Len(aGrpBlc) > 0 //temos seleção

			nTotPsLiqu   := nQtdfatur
	    			    	
	    	while nCont <= Len(aGrpBlc) //while para evitar problemas com o for
	    	 	
	    	 	//reset de dados
				nPsLiqu   := 0
				nPsBrut   := 0	
				aRecnos   := {}
				lExtsUpd  := .f. //somente para update
	    				    
			    if oModelN8D:Length() > 0
			    	
				    //verifica se tem a linha 1
				    if lFaturado //sempre chamamos 
				    	if oModelN8D:SeekLine( { {"N8D_FILORG", aGrpBlc[nCont][1]} , {"N8D_BLOCO",  aGrpBlc[nCont][2]} } )   //posiociona na linha que temos o faturamento
				    		lExtsUpd := .t.
				    		nPsLiqu += oModelN8D:GetValue("N8D_QTDVNC")
				    		nPsBrut += oModelN8D:GetValue("N8D_QTDBTO")
				    	endif
				    elseif !lExtsOne //só será chamada na primeira passagem do while
					    For nX := 1 to oModelN8D:Length()
						    oModelN8D:GoLine( nX )
					    	if val(oModelN8D:GetValue( "N8D_SEQVNC")) == 1 
					    		lExtsOne := .t.
					    		EXIT
					    	endif	
						nExt nX
						
						if !lExtsOne //não existe ainda
							oModelN8D:AddLine()
							oModelN8D:LoadValue( "N8D_SEQVNC",   PADL("1",  TamSX3( "N8D_SEQVNC" )[1], "0"))
							lExtsUpd := .t.
						endif
					endif			    				    
				    
				    //restaura as linhas antigas						    
				    if !lExtsUpd
					    For nX := 1 to oModelN8D:Length() 
					    	oModelN8D:GoLine( nX )
					    	if oModelN8D:isDeleted()
					    		oModelN8D:UnDeleteLine()
					    		lExtsUpd := .t.
					    		EXIT
					    	endif	
						nExt nX
					endif
					
				endif
				
				if !lExtsUpd
					
					oModelN8D:GoLine(oModelN8D:Length()) //ultima linha do grid
					cItemCont := Val(oModelN8D:GetValue("N8D_SEQVNC")) + 1
					
					nX := oModelN8D:Length() + 1
					
					IF nX > 1
						oModelN8D:AddLine()
					EndIF
					
					oModelN8D:GoLine(nX)
					oModelN8D:LoadValue( "N8D_SEQVNC",   PADL(cValToChar(cItemCont),  TamSX3( "N8D_SEQVNC" )[1], "0"))
					
				endif
										
				oModelN8D:LoadValue( "N8D_FILORG" , aGrpBlc[nCont][1])
				oModelN8D:LoadValue( "N8D_BLOCO"  , aGrpBlc[nCont][2])
				oModelN8D:LoadValue( "N8D_CODRES" , aGrpBlc[nCont][4]) 
						
				//-----------------------------------------
				// Insere os dados de tipo
				//-----------------------------------------
				dbSelectArea("DXD")
				dbSetOrder(1)
				If dbSeek( aGrpBlc[nCont][1] + cSafra + aGrpBlc[nCont][2] ) 
					oModelN8D:LoadValue("N8D_TIPO"    , DXD->DXD_CLACOM	)
				Endif		
																													
				//-----------------------------------------
				// Atualiza o array de fardos se vinculados
				//-----------------------------------------
				For nX := 1 To Len(aGrpBlc[nCont][3])
					dbSelectArea( "DXI" )
					DXI->( dbSetOrder( 1 ) )
					if DXI->( dbSeek( aGrpBlc[nCont][3][nx] ) )
						aAdd( aRecnos, {Recno(), DXI->DXI_FATURA, DXI->DXI_TIPPRE}) //não faturado						
						nPsLiqu += DXI->DXI_PSLIQU
						nPsBrut += DXI->DXI_PSBRUT
						nTotPsLiqu += DXI->DXI_PSLIQU                      													
					endif	
				Next nX
				
				//realiza o tratamento para linha faturada
				if (nPos := aScan( __aFardos[nPosNN8Ar][2], { |x| x[1]+x[2] == oModelN8D:GetValue("N8D_SEQVNC") + oModelN8D:GetValue("N8D_BLOCO") } )) = 0	
					aADD(__aFardos[nPosNN8Ar][2], { oModelN8D:GetValue( "N8D_SEQVNC"), aGrpBlc[nCont][2], aRecnos } )
					oModelN8D:SetValue("N8D_QTDFAR", Len( aRecnos ))
				else
					//linha faturada
					oModelN8D:LoadValue("N8D_QTDFAR", Len(__aFardos[nPosNN8Ar][2][nPos][3]) + Len( aRecnos ))
					ACopy( aRecnos , __aFardos[nPosNN8Ar][2][nPos][3]) //copia somente os recnos
				endif
				
				//-----------------------------------------
				// Atualiza item da fixação				
				oModelN8D:SetValue("N8D_QTDVNC", nPsLiqu)
				oModelN8D:SetValue("N8D_QTDBTO", nPsBrut)
				
				nCont++
	    	enddo
	    			
	    	//altera o peso liquido na quantidade reservada da fixação
	    	oModelNN8:SetValue("NN8_QTDRES", nTotPsLiqu)
	    		    	
	    endif			
	    	    	    
	    //devolve a propriedade original
	    oModelN8D:SetNoInsertLine(.T.)
		oModelN8D:SetNoDeleteLine(.T.)	
		oModelNN8:SetNoUpdateLine(.T.)
		
		//posiciona na primeira linha
		oModelN8D:goline(1)
			
	endif	

	If .NOT. lAuto
		oView:Refresh()
	EndIf
	
return .t.

/*{Protheus.doc} fInsertGrao
DbClick para inserção automática de prioridade de grãos
@author jean.schulze
@since 13/12/2017
@version 1.0
@return ${return}, ${return_description}
@param oGrid, object, descricao
@param cFieldName, characters, descricao
@param nLineGrid, numeric, descricao
@param nLineModel, numeric, descricao
@type function
*/
static function fInsertGrao(oGrid,cFieldName,nLineGrid,nLineModel)
	Local oModel    := oGrid:GetModel()
	Local oModelNN8 := oModel:GetModel():GetModel("NN8VISUL")
	Local oModelN8D := oModel:GetModel():GetModel("N8DUNICO")
	Local oView		:= FwViewActive()
	Local aRegras   := {}
	Local nX        := 1
	Local nQtdAVnc := oModelNN8:GetValue("NN8_QTDFIX") - oModelNN8:GetValue("NN8_QTDENT") - oModelNN8:GetValue("NN8_QTDRES")
		 
	if nQtdAVnc > 0
		
		//lista as regras fiscais
		aRegras := fGetSldRegra(oModel:GetModel(), oModelNN8:GetValue("NN8_CODCAD"))	

		for nX := 1 to len(aRegras)	
			if aRegras[nX][2] > 0 .and. nQtdAVnc > 0  //tem quantidade para vincular
				if oModelN8D:Length() > 1 .or. !empty(oModelN8D:GetValue("N8D_ITEMFX"))
				   oModelN8D:AddLine()
				endif
				
				oModelN8D:SetValue("N8D_ITEMFX", oModelNN8:GetValue("NN8_ITEMFX"))				
				oModelN8D:SetValue("N8D_VALOR" , oModelNN8:GetValue("NN8_VLRUNI"))
				oModelN8D:SetValue("N8D_REGRA" , aRegras[nX][1])
				
				if nQtdAVnc > aRegras[nX][2] 
				   oModelN8D:SetValue("N8D_QTDVNC", aRegras[nX][2])
				   nQtdAVnc -= aRegras[nX][2]
				else
				   oModelN8D:SetValue("N8D_QTDVNC", nQtdAVnc)
				   nQtdAVnc := 0 //sem saldo	
				endif
				
			endif
		next 		
	
		if valtype(oView) == "O"
			oView:Refresh("VIEW_N8D")
		endif
	
	endif		
	
return .t.

/*{Protheus.doc} fAutoIncre
Início padrão de sequencial
@author jean.schulze
@since 13/12/2017
@version 1.0
@return ${return}, ${return_description}

@type function
*/
Static function fAutoIncre(cCampo)
	Local oModel	 := FwModelActive()
	Local cSeq       := PADL("1",  TamSX3( cCampo )[1], "0") //sem modelo
	Local aSaveLines := nil
	Local nX         := 0
	
	If ValType(oModel) == 'O' .and. oModel:GetId() == "OGA570"
					
		aSaveLines := FWSaveRows()
		
		for nX:=1 to oModel:GetModel("N8DUNICO"):Length()
			oModel:GetModel("N8DUNICO"):GoLine(nX)
			
			//joga para a uiltima linha
			if oModel:GetModel("N8DUNICO"):GetValue(cCampo) > cSeq
			   cSeq := oModel:GetModel("N8DUNICO"):GetValue(cCampo)
			endif   
			
		Next nX
		
		//soma sequencia
		cSeq := Soma1(cSeq)
		
		//reset rows
		FWRestRows(aSaveLines)	
		
	endif	
return cSeq

/*{Protheus.doc} OGA570VDFX
Valid de fixação
@author jean.schulze
@since 13/12/2017
@version 1.0
@return ${return}, ${return_description}
@param oField, object, descricao
@type function
*/
Static Function OGA570VDFX( oField )
	Local oModel     := oField:GetModel()
	Local oModelNN8  := oModel:GetModel( "NN8VISUL" )
	Local oModelN8D  := oModel:GetModel( "N8DUNICO" )
	Local aSaveLines := FWSaveRows()
	Local lRet       := .t.
	
	//verifica se a linha está ativa
	if !oModelNN8:SeekLine( { {"NN8_ITEMFX", oField:GetValue("N8D_ITEMFX")  } } )  
		oModel:GetModel():SetErrorMessage( oModelN8D:GetId(), , oModelN8D:GetId(), "", "", STR0012, STR0014, "")
		lRet      := .f. 
	else
		oField:SetValue("N8D_VALOR",oModelNN8:GetValue("NN8_VLRUNI") )		
	endif
	
	//reset rows
	FWRestRows(aSaveLines)	
	
return lret

/*{Protheus.doc} OGA570VDRF
Valida Regra Fiscal
@author jean.schulze
@since 21/06/2018
@version 1.0
@return ${return}, ${return_description}
@param oField, object, descricao
@type function
*/
Static Function OGA570VDRF( oField )
	Local oModel     := oField:GetModel()
	Local oModelNJR  := oModel:GetModel( "NJRVISUL" )
	Local oModelN8D  := oModel:GetModel( "N8DUNICO" )
	Local lRet       := .t.
	
	//verifica se a linha está válida
	dbSelectArea("N9A")
	N9A->(dbSetOrder(1))
	if !N9A->(dbSeek(FwXFilial("N9A")+oModelNJR:GetValue("NJR_CODCTR")+oField:GetValue("N8D_CODCAD")+oField:GetValue("N8D_REGRA") ))
		oModel:GetModel():SetErrorMessage( oModelN8D:GetId(), , oModelN8D:GetId(), "", "", "Regra Fiscal Inválida", "Selecione uma regra fiscal válida.", "")
		lRet      := .f. 
	endif

	
return lret

/*{Protheus.doc} OGA570VDQT
Validação de Quantidade
@author jean.schulze
@since 13/12/2017
@version 1.0
@return ${return}, ${return_description}
@param oField, object, descricao
@type function
*/
Static Function OGA570VDQT( oField )
	Local oModel     := oField:GetModel()
	Local oModelNN8  := oModel:GetModel( "NN8VISUL" )
	Local oModelN8D  := oModel:GetModel( "N8DUNICO" )
	Local nQtdVinTot := 0
	Local nQtdAVinc  := oField:GetValue("N8D_QTDVNC")
	Local nQtdFatura := oField:GetValue("N8D_QTDFAT")
	Local aSaveLines := FWSaveRows()
	Local oView		 := FwViewActive()
	Local lRet       := .t.
	Local nQtdDisp   := 0
	
	if oModelNN8:SeekLine( { {"NN8_ITEMFX", oField:GetValue("N8D_ITEMFX")  } } )  
		
		//verifica a quantidade disponível
		nQtdDisp := (oModelNN8:GetValue("NN8_QTDFIX") * (1+(oModel:GetValue("NJRVISUL", "NJR_TOLENT") / 100))) // quantidade da fixação + tolerância do contrato - o que já foi entregue
			
		nQtdVinTot := fQtdVncNN8(oModelN8D, oField:GetValue("N8D_ITEMFX"), oField:GetValue("N8D_SEQVNC") )	 
							
		if nQtdAVinc < nQtdFatura
			oModel:GetModel():SetErrorMessage( oModelN8D:GetId(), , oModelN8D:GetId(), "", "", STR0018, STR0013, "")
			lRet      := .f. 
		elseif nQtdAVinc > nQtdDisp - nQtdVinTot
			oModel:GetModel():SetErrorMessage( oModelN8D:GetId(), , oModelN8D:GetId(), "", "", STR0011, STR0013, "")
			lRet      := .f. 
		else
			oModelNN8:SetNoUpdateLine(.f.)
			oModelNN8:LoadValue("NN8_QTDRES", nQtdVinTot + nQtdAVinc) //informa a quantidade
			oModelNN8:SetNoUpdateLine(.T.)
		endif 
		
	endif
			
	//reset rows
	FWRestRows(aSaveLines)
	
	If valType(oView) == 'O' .and. !IsInCallStack("OGA570VDFX") .and. lret
	   oView:Refresh("VIEW_NN8")
	endif
	
		
return lret

/*{Protheus.doc} fQtdVncNN8
Retorna a quantidade vinculada para a fixação
@author jean.schulze
@since 13/12/2017
@version 1.0
@return ${return}, ${return_description}
@param oModelN8D, object, descricao
@param cItemFx, characters, descricao
@param cSeqVnc, characters, descricao
@type function
*/
Static function fQtdVncNN8(oModelN8D, cItemFx, cSeqVnc )
	Local nA     := 0
	Local nTotal := 0
	
	Default cSeqVnc := ""
	
	for nA := 1 to oModelN8D:Length()
		 oModelN8D:GoLine( nA )
		 
		 if !oModelN8D:IsDeleted()
			 if oModelN8D:GetValue("N8D_ITEMFX") == cItemFx .and. cSeqVnc <> oModelN8D:GetValue("N8D_SEQVNC")
			 	nTotal += oModelN8D:GetValue("N8D_QTDVNC")
			 endif
		 endif
		 
	next nA 	 

return nTotal

/*{Protheus.doc} fUpdQtdVnc
Atualização de quantidade vinculada quando acionado as informações de delete - undelete
@author jean.schulze
@since 13/12/2017
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@param cIdView, characters, descricao
@param nNumLine, numeric, descricao
@type function
*/
static function fUpdQtdVnc(oView, cIdView, nNumLine) 
	Local oModel     := oView:GetModel()
	Local oModelNN8  := oModel:GetModel( "NN8VISUL" )
	Local oModelN8D  := oModel:GetModel( "N8DUNICO" )
	Local nQtdVinTot := 0
	Local aSaveLines := FWSaveRows()
	
	oModelN8D:GoLine(nNumLine) //reposiociona
	
	if oModelNN8:SeekLine( { {"NN8_ITEMFX", oModelN8D:GetValue("N8D_ITEMFX")  } } )  
				
		nQtdVinTot := fQtdVncNN8(oModelN8D, oModelN8D:GetValue("N8D_ITEMFX") )	 
				
		oModelNN8:SetNoUpdateLine(.f.)
		oModelNN8:LoadValue("NN8_QTDRES", nQtdVinTot) //informa a quantidade
		oModelNN8:SetNoUpdateLine(.T.)
				
	endif
			
	//reset rows
	FWRestRows(aSaveLines)
			
	If valType(oView) == 'O' .and. !IsInCallStack("OGA570VDFX")
		oView:Refresh("VIEW_NN8")
	endif
return .t.

/*{Protheus.doc} OGA570MOV
Controle de ordenação de campos.
@author jean.schulze
@since 13/12/2017
@version 1.0
@return ${return}, ${return_description}
@param nTipo, numeric, descricao
@type function
*/
Static Function OGA570MOV(nTipo)
	Local oView     	 := FWViewActive() // View que se encontra Ativa
	Local oModel    	 := FWModelActive() // Model que se encontra Ativo
	Local oModelN8D	     := oModel:GetModel('N8DUNICO') // Submodelo da Grid
	Local nLinhaOld 	 := oView:GetLine('N8DUNICO') // Linha atualmente posicionada
	Local cLinAtu	  	 := oModelN8D:GetValue("N8D_ORDEM", nLinhaOld) // Pega o valor da Ordem na linha atual

	If nTipo == 1 // Para cima

		If nLinhaOld != 1

			oModelN8D:LoadValue("N8D_ORDEM", oModelN8D:GetValue("N8D_ORDEM", nLinhaOld - 1)) // Seta o valor da linha de cima para atual
			oModelN8D:GoLine(nLinhaOld - 1) // Move o posicionamento para a linha de cima
			oModelN8D:LoadValue("N8D_ORDEM", cLinAtu) // Seta o valor da Ordem no qual foi solicitada a movimentação
			oView:LineShift('N8DUNICO',nLinhaOld ,nLinhaOld - 1) // Realiza a troca de linhas
			oModelN8D:GoLine(nLinhaOld - 1)

		EndIf

	Else // Para baixo

		If nLinhaOld < oView:Length('N8DUNICO')

			oModelN8D:LoadValue("N8D_ORDEM", oModelN8D:GetValue("N8D_ORDEM", nLinhaOld + 1)) // Seta o valor da linha de baixo para atual
			oModelN8D:GoLine(nLinhaOld + 1) // Move o posicionamento para a linha de baixo
			oModelN8D:LoadValue("N8D_ORDEM", cLinAtu) // Seta o valor da Ordem no qual foi solicitada a movimentação
			oModelN8D:GoLine(nLinhaOld)
			oView:LineShift('N8DUNICO',nLinhaOld,nLinhaOld + 1) // Realiza a troca de linhas
			oModelN8D:GoLine(nLinhaOld)

		EndIf

	EndIf

	oView:Refresh('N8DUNICO') // Atualiza a SubView da Grid

	If nTipo == 1
		oModelN8D:GoLine(nLinhaOld - 1)
	Else
		oModelN8D:GoLine(nLinhaOld + 1)
	Endif

Return .T.

/*{Protheus.doc} fLinPreN8D
Valida a deletação de linha
@author jean.schulze
@since 09/04/2018
@version 1.0
@return ${return}, ${return_description}
@param oGridModel, object, descricao
@param nLine, numeric, descricao
@param cAction, characters, descricao
@type function
*/
static function	fLinPreN8D(oGridModel, nLine, cAction)
	Local lRet := .t.
	
	If cAction == "DELETE" .and. oGridModel:GetValue("N8D_QTDFAT") > 0 // Se a Ação for Delete
		Help( , , STR0003, , STR0017, 1, 0 ) 
		lret := .f.
	endif
		
return lRet 

/*{Protheus.doc} fGetSldRegra
Retorna as regras fiscais e seus saldos
@author jean.schulze
@since 21/06/2018
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@param cCodCadenc, characters, descricao
@param lValidQTD, boolean, descricao
@type function
*/
static function fGetSldRegra(oModel, cCodCadenc, lValidQTD)
	Local oModelNJR  := oModel:GetModel( "NJRVISUL" )
	Local oModelNN8  := oModel:GetModel( "NN8VISUL" )
	Local oModelN8D  := oModel:GetModel( "N8DUNICO" )
	Local aLstRegra  := {} //lista de regra fiscal
	Local aFixOfCad  := {} //Lista de Cadencias
	Local nA         := 1
	
	Default cCodCadenc := "" 
	Default lValidQTD  := .f. //sem validar as quantidades das regras
	
	//lista as regras fiscais
	DbSelectArea("N9A") 
	N9A->(DbSetOrder(1))
	If N9A->(DbSeek( xFilial("N9A") + oModelNJR:GetValue("NJR_CODCTR") + cCodCadenc ))
		While N9A->( !Eof() ) .and. alltrim(N9A->(N9A_FILIAL+N9A_CODCTR+N9A_ITEM))= alltrim(xFilial("N9A") + oModelNJR:GetValue("NJR_CODCTR") + cCodCadenc)
			aadd(aLstRegra, {N9A->N9A_SEQPRI,N9A->N9A_QUANT})
			N9A->(DbSkip())
		EndDo		
	EndIf
	
	//lista as fixações da cadencia
	for nA := 1 to oModelNN8:Length()
		if oModelNN8:GetValue("NN8_CODCAD",nA) == cCodCadenc 
			aAdd(aFixOfCad, oModelNN8:GetValue("NN8_ITEMFX", nA)) 
		endif				 
	next nA 

	
	//deduz os saldos
	for nA := 1 to oModelN8D:Length()				 
		 if !oModelN8D:IsDeleted(nA)
		 	 //verifica se a fixação é para a cadencia
			 if aScan(aFixOfCad, { |x| Alltrim(x) == alltrim(oModelN8D:GetValue("N8D_ITEMFX",nA) )}) > 0  
			 	//localiza a regra fiscal e diminui a quantidade
			 	if (nPos := aScan(aLstRegra, { |x| Alltrim(x[1]) == alltrim(oModelN8D:GetValue("N8D_REGRA",nA) )})) > 0 
			 		aLstRegra[nPos][2] -= oModelN8D:GetValue("N8D_QTDVNC",nA ) //diminui a quantidade
			 		if aLstRegra[nPos][2] < 0
			 			if lValidQTD
			 				return .f. //retornamos falso
			 			else
			 				aLstRegra[nPos][2] := 0 //reset
			 			endif
			 		endif
			 	endif	
			 endif
		 endif		 
	next nA 

return aLstRegra

/*{Protheus.doc} OGA570SLRG
Retorna as quantidades disponíveis por regra fiscal - executado através de outras telas
@author jean.schulze
@since 22/06/2018
@version 1.0
@return ${return}, ${return_description}
@param cFilCtr, characters, descricao
@param cCodCtr, characters, descricao
@param cCodCadenc, characters, descricao
@type function
*/
Function OGA570SLRG(cFilCtr, cCodCtr, cCodCadenc)
	Local aAreaN9A   := GetArea("N9A")
	Local aAreaN8D   := GetArea("N8D")
	Local aLstRegra  := {} //lista de regra fiscal
	Local nPos       := 0

	//lista as regras fiscais
	DbSelectArea("N9A") 
	N9A->(DbSetOrder(1))
	If N9A->(DbSeek( cFilCtr + cCodCtr + cCodCadenc ))
		While N9A->( !Eof() ) .and. alltrim(N9A->(N9A_FILIAL+N9A_CODCTR+N9A_ITEM))= alltrim(cFilCtr + cCodCtr  + cCodCadenc)
			aadd(aLstRegra, {N9A->N9A_SEQPRI,N9A->N9A_QUANT})
			N9A->(DbSkip())
		EndDo		
	EndIf
			
	//deduz os saldos
	DbSelectArea("N8D") 
	N8D->(DbSetOrder(3))
	If N8D->(DbSeek( cFilCtr + cCodCtr + cCodCadenc ))
		While N8D->( !Eof() ) .and. alltrim(N8D->(N8D_FILIAL+N8D_CODCTR+N8D_CODCAD))= alltrim(cFilCtr + cCodCtr + cCodCadenc)
			if (nPos := aScan(aLstRegra, { |x| Alltrim(x[1]) == alltrim(N8D->(N8D_REGRA) )})) > 0 
			 		aLstRegra[nPos][2] -= N8D->(N8D_QTDVNC) //diminui a quantidade
			 		if aLstRegra[nPos][2] < 0
			 			aLstRegra[nPos][2] := 0 //reset
			 		endif
			 	endif	
			N8D->(DbSkip())
		EndDo		
	EndIf
	
	RestArea(aAreaN9A)
	RestArea(aAreaN8D)
	
return aLstRegra


