#INCLUDE "OGA830.ch"
#include "protheus.ch"
#include "fwmbrowse.ch"
#include "fwmvcdef.ch"


Static _cFilter    
Static _aN9AVend   := {}
	
	
/*/{Protheus.doc} OGA830()
Rotina para cadastro de Itens do Plano de Vendas
@type  Function
@author tamyris ganzenmueller
@since 28/06/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Function OGA830()
	 
	FWExecView("Alterar", 'VIEWDEF.OGA830', MODEL_OPERATION_UPDATE, , {|| .T. })

Return()


/*/{Protheus.doc} ModelDef()
Função que retorna o modelo padrao para a rotina
@type  Function
@author tamyris ganzenmueller
@since 28/06/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ModelDef()
	
	Local oStruN8Y  := FWFormStruct( 1, "N8Y")
	Local oStruN8W  := FWFormStruct( 1, "N8W")
	Local oStruNCU  := FWFormStruct( 1, "NCU")
	Local oModel    := MPFormModel():New( "OGA830", , {| oModel | PosModelo( oModel ) }, )
    Local aLisMoe  := {'1=REAL','2=DOLAR'}
    Local cDesMo   := ''    
          
    oStruN8W:AddTrigger( "N8W_PERVEN", "N8W_PERVEN", { || .T. }, { | oStrGrid | fTrgN8WPer( oStrGrid, "N8W_PERVEN" ) } )
    oStruN8W:AddTrigger( "N8W_PERREC", "N8W_PERREC", { || .T. }, { | oStrGrid | fTrgN8WPer( oStrGrid, "N8W_PERREC" ) } )
    oStruNCU:AddTrigger( "NCU_PERREC", "NCU_PERREC", { || .T. }, { | oStrGrid | fTrgN8WPer( oStrGrid, "NCU_PERREC" ) } )
    
    oStruN8W:SetProperty( "N8W_MESANO" , MODEL_FIELD_VALID  , {|oStrGrid,cCampo|OGA830VLMA(oStrGrid,cCampo)})
    oStruNCU:SetProperty( "NCU_MESANO" , MODEL_FIELD_VALID  , {|oStrGrid,cCampo|OGA830VLMA(oStrGrid,cCampo)})
        
    oStruN8W:SetProperty( "N8W_MESANO", MODEL_FIELD_OBRIGAT , .T.  ) 
    oStruN8W:SetProperty( "N8W_TIPMER", MODEL_FIELD_OBRIGAT , .T.  ) 
    oStruN8W:SetProperty( "N8W_MOEDA2", MODEL_FIELD_OBRIGAT , .T.  )    
    oStruNCU:SetProperty( "NCU_MESANO", MODEL_FIELD_OBRIGAT , .T.  ) 
    oStruNCU:SetProperty( "NCU_PERREC", MODEL_FIELD_OBRIGAT , .T.  )
    
     	 
     //Buscar moeda e descricao da moeda do plano para mostrar no combo 
	IF  N8Y->N8Y_MOEDA  != 0 .and. N8Y->N8Y_MOEDA  != 1 
	    cDesMo:= FGetMoPV(N8Y->N8Y_MOEDA)		 
	    //Ter as opcoes : moeda padrao e moeda do plano no combo
		aLisMoe:= {'1=REAL', cDesMo }
	EndIF
	 	 
	oStruN8W:SetProperty('N8W_MOEDA2', MODEL_FIELD_TAMANHO, 1)
    oStruN8W:SetProperty('N8W_MOEDA2', MODEL_FIELD_VALUES ,aLisMoe)
    oStruN8W:SetProperty( "N8W_MOEDA2" , MODEL_FIELD_INIT, {| oField,cCampo | fN8WInit( oField, "N8W_MOEDA2"  ) } )
    oStruN8W:SetProperty( "N8W_MOEDA"  , MODEL_FIELD_INIT, {| oField,cCampo | fN8WInit( oField, "N8W_MOEDA"  ) } )
    oStruN8W:SetProperty( "N8W_TIPMER", MODEL_FIELD_INIT, {| oField,cCampo | fN8WInit( oField, "N8W_TIPMER" ) } )
    
	oModel:AddFields("N8YVISUL", Nil, oStruN8Y )
	//inibe a gravação dos modelos abaixo
	oModel:SetOnlyQuery("N8YVISUL")
	
	//Itens do plano de vendas
 	oModel:AddGrid( "N8WUNICO", "N8YVISUL", oStruN8W, {|oStrGrid,nLine,cAction,cField|PREVLINN8W(oStrGrid,nLine,cAction,cField)} , , , { | oGrid | PosVldN8W( oGrid)} ,) 
	oModel:GetModel( "N8WUNICO" ):SetOptional( .T. )
	oModel:GetModel( "N8WUNICO" ):SetDescription( STR0001)  //"Itens do Plano de Vendas"
	oModel:GetModel( "N8WUNICO" ):SetUniqueLine( { "N8W_TIPMER", "N8W_MOEDA", "N8W_MESANO" } )
	oModel:SetRelation( "N8WUNICO", { { "N8W_FILIAL", "N8Y_FILIAL" }, { "N8W_CODPLA", "N8Y_CODPLA" }, { "N8W_SAFRA", "N8Y_SAFRA" }, { "N8W_GRPROD", "N8Y_GRPROD" },{ "N8W_CODPRO", "N8Y_CODPRO" } }, N8W->( IndexKey( 5 ) ) )

	//Condições de Recebimento
	oModel:AddGrid( "NCUUNICO", "N8WUNICO", oStruNCU, {|oStrGrid,nLine,cAction,cField|PREVLINNCU(oStrGrid,nLine,cAction,cField)} , , , { | oGridNCU | PosVldNCU( oGridNCU)},)
	oModel:GetModel( "NCUUNICO" ):SetOptional( .T. )
	oModel:GetModel( "NCUUNICO" ):SetDescription( STR0026 ) //"Condições de Recebimento"  
	oModel:GetModel( "NCUUNICO" ):SetUniqueLine( { "NCU_MESANO" } )
	oModel:SetRelation( "NCUUNICO", { { "NCU_FILIAL", "N8Y_FILIAL" }, { "NCU_SAFRA", "N8Y_SAFRA" }, { "NCU_CODPLA", "N8Y_CODPLA" }, { "NCU_SEQITE", "N8W_SEQITE" } }, NCU->( IndexKey( 1 ) ) )
		
Return oModel

/*/{Protheus.doc} ViewDef()
Função que retorna a view para o modelo padrao da rotina
@type  Function
@author tamyris ganzenmueller
@since 28/06/2018
@version 1.0
@param param, param_type, param_descr
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ViewDef()
	Local oStruN8Y := FWFormStruct( 2, "N8Y", { |x| ALLTRIM(x)  $ 'N8Y_QTDCOM, N8Y_PERVEN, N8Y_QTDVEN, N8Y_PERSAL, N8Y_QTDSAL,N8Y_QTDCON,N8Y_PERCON'})
	Local oStruN8W := FWFormStruct( 2, "N8W", { |x| ALLTRIM(x)  $ 'N8W_TIPMER, N8W_MOEDA2, N8W_MESANO, N8W_PERVEN, N8W_QTPRVE, N8W_SLDVEN, N8W_QTDVEN, N8W_ N8W_PERREC, N8W_QTPRRE,N8W_PERCON'})
    Local oStruNCU := FWFormStruct( 2, "NCU", { |x| ALLTRIM(x)  $ 'NCU_MESANO, NCU_PERREC, NCU_QTPRRE'})
	Local oModel   := FWLoadModel( "OGA830" )
	Local oView    := FWFormView():New()	
	Local aLisMoe  := {'1=REAL','2=DOLAR'}
	Local cDesMo   := ''

	If N8Y->N8Y_TIPVOL == "1"
		oStruN8W:RemoveField( "N8W_PERREC" )
		oStruN8W:RemoveField( "N8W_QTPRRE" )		
	Else
		oStruN8W:RemoveField( "N8W_PERVEN" )
		oStruN8W:RemoveField( "N8W_QTPRVE" )		
	EndIf
	
	oStruN8W:RemoveField( "N8W_MOEDA" )			  
    
     
	oView:SetModel( oModel )
           
    oView:AddField( "VIEW_N8Y", oStruN8Y, "N8YVISUL" )
   
     //Buscar moeda e descricao da moeda do plano para mostrar no combo 
	IF  N8Y->N8Y_MOEDA  != 0 .and. N8Y->N8Y_MOEDA  != 1 
	    cDesMo:= FGetMoPV(N8Y->N8Y_MOEDA)		 
	    //Ter as opcoes : moeda padrao e moeda do plano no combo
		aLisMoe:= {'1=REAL', cDesMo }
	EndIF
	
    oStruN8W:SetProperty('N8W_MOEDA2', MVC_VIEW_COMBOBOX, aLisMoe)
        
    oView:AddGrid(  "VIEW_N8W", oStruN8W, "N8WUNICO" )
	oView:AddGrid(  "VIEW_NCU", oStruNCU, "NCUUNICO" )
    
	oView:CreateHorizontalBox( 'SUP', 30 )
	oView:CreateHorizontalBox( 'INF', 70 )
		
	oView:CreateVerticalBox( "BOXV_ITENS", 70, "INF")
	oView:CreateVerticalBox( "BOXV_COND" , 30, "INF")
	
	oView:SetOwnerView( "VIEW_N8Y", "SUP" )
	oView:SetOwnerView( "VIEW_N8W", "BOXV_ITENS" )
	oView:SetOwnerView( "VIEW_NCU", "BOXV_COND" )
		
	oView:EnableTitleView( "VIEW_N8W" )
	oView:EnableTitleView( "VIEW_NCU" )
	
	oView:SetCloseOnOk( {||.t.} )
	
	oView:SetAfterViewActivate({|oView| fAftViewActiv(oView)})
	
	oView:AddUserButton( STR0022 , "", { | oModel | OGA830CPRE( oModel ) } ) //"Consultar Preços"
	oView:AddUserButton( STR0024 , "", { | oModel | OGA830DSLD( oModel ) } ) //"Distribuir Saldos"
	
	
Return oView

/*/{Protheus.doc} fAftViewActiv
//TODO Função executado após ativação da view - SetAfterViewActivate
@author claudineia.reinert
@since 06/01/2019
@version 1.0
@return ${return}, ${return_description}
@param oView, object, descricao
@type function
/*/
Static Function fAftViewActiv(oView)
	Local oModel     := FwModelActive()
	
	OGA830ATVD(oModel) //Atualiza os Totalizadores do Volume Disponível

Return .T.

 /** {Protheus.doc} fTrgN8YPer
Gatilhar % Vendas
@return:    cRet - conteudo do campo
@author:    Tamyris Ganzenmueller / Vanilda.moggio
@since:     03/07/2018 - 14/02/19
@Uso:       OGA830
*/
Static Function fTrgN8WPer(oStrN8W, cCampo)
	Local oModel	:= oStrN8W:GetModel()
	Local oGridN8Y := oModel:GetModel( "N8YVISUL" )
	Local oGridN8W  := oModel:GetModel( "N8WUNICO")
	Local oGridNCU  := oModel:GetModel( "NCUUNICO")
	Local nTotPerc  := 0
	Local nx := 0
	
	If cCampo == "N8W_PERVEN"		
		nRet := (oStrN8W:GetValue("N8W_PERVEN") *  oGridN8Y:GetValue('N8Y_QTDCOM'))/100
		oStrN8W:SetValue("N8W_QTPRVE",nRet)
		
	ElseIF cCampo == "N8W_PERREC"		
		nRet := (oStrN8W:GetValue("N8W_PERREC") *  oGridN8Y:GetValue('N8Y_QTDCOM'))/100
		oStrN8W:SetValue("N8W_QTPRRE",nRet)

    ElseIF cCampo == "NCU_PERREC"
	    
	    If N8Y->N8Y_TIPVOL == "1"
	    	nTotQtd := oGridN8W:GetValue('N8W_QTPRVE')
    	else
    		nTotQtd := oGridN8W:GetValue('N8W_QTPRRE') 
    	EndIF 
	    nRet := (oStrN8W:GetValue("NCU_PERREC") *  nTotQtd ) / 100
		oStrN8W:SetValue("NCU_QTPRRE",nRet)
		
		nLinha := oGridNCU:GetLine()//guarda a linha posicionada
		For nX := 1 to oGridNCU:Length() //percorre a grid
			oGridNCU:GoLine( nX )
			If .not. oGridNCU:IsDeleted(nX) 
				lReg := .T.
				nTotPerc += oGridNCU:GetValue('NCU_PERREC') //armazena a soma do percentual 
			EndIf	
		Next nX
		oGridNCU:GoLine( nLinha )
		
		oGridN8W:SetValue("N8W_PERCON",nTotPerc)
		
	EndIF
			
		
	OGA830ATVD(oModel)

return


/*/{Protheus.doc} PREVLINN8W
//TODO Pre-validação da linha N8W
@author claudineia.reinert
@since 09/01/2019
@version 1.0
@return ${return}, ${return_description}
@param oStrGrid, object, Objeto da grid
@param nLine, numeric, numero da linha posicionada
@param cAction, characters, ação realizada na grid
@param cField, characters, campo a ser atualizado quando ação de setar valor
@type function
/*/
Static Function PREVLINN8W(oStrN8W,nLine,cAction,cField)
	Local lRet 		:= .T.
	
	If !oStrN8W:IsInserted() .and. (cAction == "DELETE" .OR. cAction == "CANSETVALUE") 
		If !VUPDLINN8W(oStrN8W) //verifica se a linha pode ser alterada/deletada
			lRet := .F.
			Help( , ,"HELP", , "Não é permitido alterar/deletar periodos anteriores.", 1, 0)
		ElseIf cAction == "DELETE" 
			OGA830ATVD(oStrN8W:GetModel(),nLine)//pos-valid não ajusta, então adicionado aqui quando deleta a linha
		EndIf
		
	EndIf
	
	If cAction == "UNDELETE" //DESFAZER DELETE DA LINHA
		/*If !OGA830VPCIPV(oStrN8W,nLine) //VALIDA O PERCENTUAL
			oStrN8W:DeleteLine()//mantem deletado a linha da grid
			lRet := .F.
		Else*/
			OGA830ATVD(oStrN8W:GetModel(),nLine)
		//EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} VUPDLINN8W
//TODO Valida se a linha da N8W posicionada pode ser alterada/deletada 
@author claudineia.reinert
@since 09/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function VUPDLINN8W(oStrN8W, lValidMark, oSelec )
	Local lRet := .T.
	
	Default lValidMark := .F.
	Default oSelec := Nil  
	
	If AnoMes(oStrN8W:getValue("N8W_DTFINA")) < AnoMes(dDataBase)
		lRet := .F. //não pode ser alterada pois periodo é menor ou igual ao periodo atual(mes/ano)
	EndIf
	
	If lRet .And. lValidMark
		lRet := .F.
		//N8W - Itens do Plano de Vendas (Registros marcados)	
		dbSelectArea('N8W')
		N8W->(DbGoTop()) 
		N8W->(DbSetOrder(1))
		If N8W->(dbSeek(N8Y->N8Y_FILIAL + N8Y->N8Y_CODPLA + oStrN8W:GetValue('N8W_SEQITE') ))
	
			//Verifica se produtor foi selecionado
			If oSelec:IsMark()
				lRet := .T.
			EndIF
		EndIf
	EndIF

Return lRet 

Static Function PREVLINNCU(oStrNCU,nLine,cAction,cField)
	Local lRet 	   := .T.
	Local oModel := oStrNCU:GetModel()
	Local oStrN8W := oModel:GetModel("N8WUNICO")
	
	If cAction == "DELETE" .OR. cAction == "CANSETVALUE"
		If !VUPDLINN8W(oStrN8W) //valida a linha da N8W se ela pode ser alterada
			//não permite alterar/excluir linha da NCU
			lRet := .F.
			Help( , ,"HELP", , "Não é permitido alterar/deletar periodos anteriores.", 1, 0)
		EndIf
	EndIf
	
	If cAction == "UNDELETE"
		If !OGA830VPCCR(oStrNCU,nLine)
			oStrNCU:DeleteLine()//deleta a linha atual da grid
			lRet := .F.
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} PosVldNCU
//TODO Função de pós-validação da grid N8W - Itens do Plano de Vendas
@author claudineia.reinert
@since 08/01/2019
@version 1.0
@return ${return}, ${return_description}
@param oGride, object, Objeto com a estrutura da grid
@type function
/*/
Static Function PosVldN8W(oStrN8W)
	Local lRet := .T.
	
	If !OGA830VPCIPV(oStrN8W,0,.t.)
		lRet := .F.
	EndIf

Return lRet

/*/{Protheus.doc} PosVldNCU
//TODO Função de pós-validação da grid NCU - condição de recebimento
@author claudineia.reinert
@since 08/01/2019
@version 1.0
@return ${return}, ${return_description}
@param oGridNCU, object, Objeto com a estrutura da grid
@type function
/*/
Static Function PosVldNCU(oStrNCU)
	Local lRet := .T.
	
	If !OGA830VPCCR(oStrNCU,0,.t.)
		lRet := .F.
	EndIf

Return lRet

 /** {Protheus.doc} OGA830ATVD
Atualiza os Totalizadores do Volume Disponível
@return:    
@author:    Tamyris Ganzenmueller
@since:     28/12/2018
@Uso:       OGAA880 
*/
Function OGA830ATVD(oModel,nLinDel)
	Local oView     := FwViewActive()
	Local oStrN8Y := oModel:GetModel( "N8YVISUL" )
	Local oStrN8W := oModel:GetModel( "N8WUNICO" )
	Local aSaveLines := FWSaveRows() //Salva as posicoes das FWFormGrids do Model 
	Local nLinha    := 0
	Local nX        := 0
	Local nSomaPer  := 0
	Local nSomaQtd  := 0
	Local nSomaCon  := 0
	Local nPerCon   := 0
	
	Default nLinDel := 0 //linha da grid 
	
	nLinha := oStrN8W:GetLine()
	for nX := 1 to oStrN8W:Length()
		oStrN8W:GoLine( nX )		
		If !oStrN8W:IsDeleted() .and. nX != nLinDel
			If N8Y->N8Y_TIPVOL == "1"
				nSomaPer += oStrN8W:GetValue("N8W_PERVEN")
				nSomaQtd += oStrN8W:GetValue("N8W_QTPRVE")
				nSomaCon += oStrN8W:GetValue("N8W_QTPRVE") * oStrN8W:GetValue("N8W_PERCON") / 100
			Else
				nSomaPer += oStrN8W:GetValue("N8W_PERREC")
				nSomaQtd += oStrN8W:GetValue("N8W_QTPRRE")
				nSomaCon += oStrN8W:GetValue("N8W_QTPRRE") * oStrN8W:GetValue("N8W_PERCON") / 100
			EndIf
		ElseIf oStrN8W:IsDeleted() .and. nX == nLinDel
			If N8Y->N8Y_TIPVOL == "1"
				nSomaPer += oStrN8W:GetValue("N8W_PERREC")
				nSomaQtd += oStrN8W:GetValue("N8W_QTPRVE")
				nSomaCon += oStrN8W:GetValue("N8W_QTPRVE") * oStrN8W:GetValue("N8W_PERCON") / 100
			Else
				nSomaPer += oStrN8W:GetValue("N8W_PERVEN")
				nSomaQtd += oStrN8W:GetValue("N8W_QTPRRE")
				nSomaCon += oStrN8W:GetValue("N8W_QTPRRE") * oStrN8W:GetValue("N8W_PERCON") / 100
			EndIf
		EndIf
	next nX
	oStrN8W:GoLine( nLinha )
	
	oStrN8Y:LoadValue('N8Y_PERVEN',nSomaPer)
	oStrN8Y:LoadValue('N8Y_QTDVEN',nSomaQtd)
	oStrN8Y:LoadValue('N8Y_PERSAL',100 - nSomaPer)
	oStrN8Y:LoadValue('N8Y_QTDSAL',oStrN8Y:GetValue('N8Y_QTDCOM') - nSomaQtd )
	oStrN8Y:LoadValue('N8Y_QTDCON',nSomaCon)
	
	If oStrN8Y:GetValue('N8Y_QTDCOM') <> 0
		nPerCon := Round((nSomaCon / oStrN8Y:GetValue('N8Y_QTDCOM') * 100),6)
	EndIF
	
	If nPerCon > 0 .And. nPerCon < 999
		oStrN8Y:LoadValue('N8Y_PERCON',nPerCon)
	EndIf
	
	FWRestRows( aSaveLines ) //Restaura as posicoes das FWFormGrids do Model 
	
	If !FwIsInCallStack("OGX820IMP")
		oView:Refresh()
	EndIf

Return .T.

/*/{Protheus.doc} OGA830VPCIPV
//TODO Função de validação da soma do percentual previsto(N8W_PERVEN) do item do plano de venda por tipo de mercado e moeda
@author claudineia.reinert
@since 04/01/2019
@version 1.0
@param nLinDel, numeric, linha deletada que deve ser considerada
@param lPosGrid, logical, Se é chamado pela pós-validação da grid
@return ${return}, ${return_description}
@type function
/*/
Function OGA830VPCIPV(oStrN8W,nLinDel,lPosGrid)
	Local lRet := .T.
	Local nLinha	:= 0
	Local nX		:= 0
	Local nTotPerc  := 0
	Local cCampo := IIf(N8Y->N8Y_TIPVOL == "1","N8W_PERVEN","N8W_PERREC")
	Local lPerAnt := .F.
	
	Default nLinDel := 0 //line que deve ser considerada mesmo deletada
	Default lPosGrid := .F. //Pós-valição da Grid
	  
	nLinha := oStrN8W:GetLine()//guarda a linha posicionada
	For nX := 1 to oStrN8W:Length() //percorre a grid
		oStrN8W:GoLine( nX )
		If .not. oStrN8W:IsDeleted(nX) .or. nLinDel == nX 
			//If cInd = cValToChar(oStrN8W:GetValue('N8W_TIPMER')) + cValToChar(oStrN8W:GetValue('N8W_MOEDA')) //busca itens conforme o indice
				nTotPerc += oStrN8W:GetValue(cCampo) //armazena a soma do percentual 
			//EndIf	
		EndIf	
		
		//Verifica se foi incluído registro com valor informado para um período anterior
		If oStrN8W:IsInserted() .and. !VUPDLINN8W(oStrN8W) .And. oStrN8W:GetValue(cCampo)
			lPerAnt := .T.
		EndIF
	Next nX
	oStrN8W:GoLine( nLinha )
	
	If nTotPerc > 100 
		lRet := .F.
		//cMsg := "Mercado:"+cValToChar(oStrN8W:GetValue("N8W_TIPMER"))+", Moeda:"+cValToChar(oStrN8W:GetValue("N8W_MOEDA"))+", Soma do %: "+cValToChar(nTotPerc)
		//Help( ,,"AJUDA",, "A soma do % diferente de 100% para:  " + cMsg, 1, 0,,,,,,{"Ajuste o percentual dos itens do plano de vendas."} )
		Help( ,,"AJUDA",, "A soma do % dos itens do plano de venda é diferente de 100%", 1, 0,,,,,,{"Ajuste o percentual dos itens do plano de vendas."} )
	ElseIf oStrN8W:GetValue(cCampo) > 100 .OR. oStrN8W:GetValue(cCampo) <= 0
		lRet := .F.
	EndIf
	
	
	If lRet .And. lPerAnt
		Help( , ,"HELP", , "Não é permitido informar valores para períodos anteriores.", 1, 0)
		lRet := .F.
	EndIF
	
Return lRet

/*/{Protheus.doc} OGA830VPCCR
//TODO Função de validação da soma do percentual previsto(NCU_PERREC) da condição de recebimento
@author claudineia.reinert
@since 04/01/2019
@version 1.0
@param nLinDel, numeric, linha deletada que deve ser considerada
@param lPosGrid, logical, Se é chamado pela pós-validação da grid
@return ${return}, ${return_description}

@type function
/*/
Function OGA830VPCCR(oGridNCU, nLinDel,lPosGrid)
	Local lRet := .T.
	Local nLinha	:= 0
	Local nX		:= 0
	Local nTotPerc  := 0
	Local cMsg		:= ''
	Local lReg		:= .F. //se tem registro na grid que não esteja deletado
	
	Default nLinDel := 0 //line que deve ser considerada mesmo deletada
	Default lPosGrid := .F. //Pós-valição da Grid
	  
	nLinha := oGridNCU:GetLine()//guarda a linha posicionada
	For nX := 1 to oGridNCU:Length() //percorre a grid
		oGridNCU:GoLine( nX )
		If .not. oGridNCU:IsDeleted(nX) .or. nLinDel == nX 
			lReg := .T.
			nTotPerc += oGridNCU:GetValue('NCU_PERREC') //armazena a soma do percentual 
		EndIf	
	Next nX
	oGridNCU:GoLine( nLinha )
	
	If lReg .and. (nTotPerc > 100 .or. (lPosGrid .and. nTotPerc < 100))
		lRet := .F.
		cMsg := "A soma do % das condições de recebimento diferente de 100% para o item do plano de vendas. "
		Help( ,,"AJUDA",, cMsg , 1, 0,,,,,,{"Ajuste o percentual das condições de recebimento."} )
	ElseIf oGridNCU:GetValue("NCU_PERREC") > 100 .OR. oGridNCU:GetValue("NCU_PERREC") < 0
		lRet := .F.
	EndIf
	
Return lRet

/*/{Protheus.doc} OGA830VLMA
//TODO Função de validação do campo Mes/Ano(N8W_MESNAO ou NCU_MESANO)
@author claudineia.reinert
@since 04/01/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OGA830VLMA(oStrGrid,cCampo)
	Local lRet   	:= .T.
	Local dDataIni 	:= CTOD("01/" + Alltrim(oStrGrid:GetValue(cCampo)))
	Local dDataFim 	:= LastDate(dDataIni)
	Local cMesAno 	:= ''
	
	If empty(dDataIni)
		lRet := .F.
	Else
		If cCampo == "N8W_MESANO"
			cMesAno := Month2Str(dDataIni)+'/'+Year2Str(dDataIni) //valor mes/ano no formato MM/AAAA
			oStrGrid:loadValue("N8W_MESANO",cMesAno)//load para não passar pela função de validação novamente
			oStrGrid:setValue("N8W_DTINIC",dDataIni) //seta valor para data inicial 
			oStrGrid:setValue("N8W_DTFINA",dDataFim) //seta valor para data final
			
			If AnoMes(oStrGrid:getValue("N8W_DTFINA")) < AnoMes(dDataBase) .AND.  !Empty(oStrGrid:getValue("N8W_QTPRVE"))
				Help( , ,"HELP", , "Não é permitido alterar periodos anteriores.", 1, 0)
			EndIf
	
		ElseIf cCampo == "NCU_MESANO"
			cMesAno := Month2Str(dDataIni)+'/'+Year2Str(dDataIni) //valor mes/ano no formato MM/AAAA
			If AnoMes(dDataIni) < AnoMes(dDataBase) //DAGROCOM-7575 - Ñ permitir data menor que a PASSADA
				Return .F.
			EndIf
			oStrGrid:loadValue(cCampo,cMesAno)//load para não passar pela função de validação novamente
		EndIf
	EndIf
	
Return lRet

/*/{Protheus.doc} OGA830CPRE
//TODO Chama a tela de componentes de preço conforme registro N8W posicionado
@author claudineia.reinert
@since 14/01/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel830, object, descricao
@type function
/*/
Function OGA830CPRE( oModel )
	Local oStrN8Y		:= oModel:getModel("N8YVISUL")
	Local oStrN8W		:= oModel:getModel("N8WUNICO")
    Local cProduto 		:= oStrN8W:getValue("N8W_CODPRO")
	Local cSimula		:= "SIM"
	Local cTipoSim		:= "V" //VENDA
	Local cSafra        := oStrN8Y:getValue("N8Y_SAFRA") 
	Local cUm1Pro   	:= oStrN8Y:getValue("N8Y_UM1PRO")
	Local cUm1Pre   	:= Posicione("SB5", 1, FwxFilial("SB5")+cProduto, "B5_UMPRC")
	Local dDtBase  		:= oStrN8W:getValue("N8W_DTFINA") //database para busca dos índices para a composição de preço
	Local dDEntrIni 	:= oStrN8W:getValue("N8W_DTINIC")
	Local dDEntrFim 	:= oStrN8W:getValue("N8W_DTFINA")
	Local nMoeda 		:= Val(oStrN8W:getValue("N8W_MOEDA2"))
	Local nMercado		:= oStrN8W:getValue("N8W_TIPMER")
	Local nQtSimula  	:= oStrN8W:getValue("N8W_QTPRVE")
	Local cGrupo        := oStrN8W:getValue("N8W_GRPROD")
	Local cMoeda     	:= AGRMVMOEDA(nMoeda)     
	Local nTaxCon       := oStrN8W:getValue("N8W_TAXCON")
	Local lEditar   	:= .T.
	
	Private _aCompPrc := {}
	Private _lLerComp := .F.
	
	OGA420 (cSimula , cProduto , dDtBase , dDEntrIni , dDEntrFim , nQtSimula , cTipoSim   , cUm1Pro    ,cUm1Pre    , nMoeda    , _aCompPrc, lEditar, nMercado, cMoeda, cSafra, cGrupo, nTaxCon )
	_lLerComp := .F.
Return .T.

/*/{Protheus.doc} OGA830DSLD
//TODO Distribui o saldo da N8Y na N8W
@author claudineia.reinert
@since 16/01/2019
@version 1.0
@return ${return}, ${return_description}
@param oModel, object, descricao
@type function
/*/
Function OGA830DSLD( oModel )
	Local oStrN8Y := oModel:GetModel( "N8YVISUL" )
	Local oStrN8W := oModel:GetModel( "N8WUNICO" )
	Local aSaveLines := FWSaveRows() //Salva as posicoes das FWFormGrids do Model 
	Local nX	 := 0
	Local nTotPerVal := 0
	Local nNewPer := 0
	Local nPerSaldo := 0
	Local cCpoPerc := "N8W_PERVEN"
	Local cCpoQtde := "N8W_QTPRVE"
	
	If N8Y->N8Y_TIPVOL == "2" //Financeiro
		cCpoPerc := "N8W_PERREC"
		cCpoQtde := "N8W_QTPRRE"
	EndIf
	
	//Selecionar registros para distribuição de saldo
	oSelec := selRegDist()
	
	If Empty(oSelec)
		Return .T.
	endIF
	
	For nX := 1 to oStrN8W:Length() //percorre a grid
		oStrN8W:GoLine( nX )
		If .not. oStrN8W:IsDeleted(nX)
			//RECALCULA O PERCENTUAL DA LINHA COM BASE NA QTD COMERCIAL
			nNewPer := (oStrN8W:GetValue( cCpoQtde ) * 100) / oStrN8Y:GetValue('N8Y_QTDCOM')
			oStrN8W:SetValue( cCpoPerc ,nNewPer) //seta valor para atualizar o %
			If VUPDLINN8W(oStrN8W, .T., oSelec ) //valida se a linha da N8W pode ser alterada pelo usuario
				nTotPerVal += oStrN8W:GetValue( cCpoPerc ) //soma do percentual das linhas que pode editar pelo usuario
			EndIf
		EndIf	
	Next nX
	oStrN8W:GoLine( 1 )
	nPerSaldo := (oStrN8Y:GetValue('N8Y_QTDSAL') * 100) / oStrN8Y:GetValue('N8Y_QTDCOM') //percentual de saldo que falta distribuir
	
	For nX := 1 to oStrN8W:Length() //percorre a grid
		oStrN8W:GoLine( nX )//posiciona na linha nX
		If .not. oStrN8W:IsDeleted(nX) .AND. VUPDLINN8W(oStrN8W, .T., oSelec) //se a linha não esta deletada e linha pode ser alterada pelo usuario
			//calcula o novo percentual da linha redistribuindo o saldo nas linhas que podem ser alterada pelo usuario
			// e para que a soma do % de todas as linhas fechem 100%
			nNewPer := (oStrN8W:GetValue( cCpoPerc ) * (nTotPerVal + nPerSaldo) ) / nTotPerVal 
			oStrN8W:SetValue( cCpoPerc ,(nNewPer))
		EndIf	
	Next nX
	oStrN8W:GoLine( 1 )
	
	FWRestRows( aSaveLines ) //Restaura as posicoes das FWFormGrids do Model 
	
Return .T.

/*/{Protheus.doc} selRegDist
Selecionar os registros para distribuição de saldo 
@author tamyris.g
@since 22/01/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
Static Function selRegDist()
	Local aArea     := GetArea()
	Local oDlg	    := Nil
	Local oFwLayer  := Nil
	Local oSize     := Nil
	Local oReturn   := Nil
	Local aButtons  := {}
	Local nOpcX     := 0
	Local cFiltro   := ""
	Local aCampos   := { 'N8W_TIPMER', 'N8W_DESMOE', 'N8W_MESANO', 'N8W_PERVEN', 'N8W_PERREC'}
	Local lMarkAll	:= .f.
		
	oSize := FWDefSize():New(.T.)
	oSize:AddObject( "ALL", 100, 100, .T., .T. )    
	oSize:lLateral	:= .F.  // Calculo vertical	
	oSize:Process() //executa os calculos

	oDlg := TDialog():New( oSize:aWindSize[1], oSize:aWindSize[2], oSize:aWindSize[3]*0.85, oSize:aWindSize[4]*0.85,STR0024,,,,,CLR_BLACK,CLR_WHITE,,, .t. ) //"Distribuir Saldos"  
		
	// Instancia o layer
	oFwLayer := FWLayer():New()

	// Inicia o Layer
	oFwLayer:init( oDlg, .F. )

	// Cria as divisões horizontais
	oFwLayer:addLine('UP'  , 100, .F.)
	oFwLayer:addCollumn('ALL', 100, .F., 'UP')
	
	//cria as janelas
	oFwLayer:addWindow('ALL', 'WndUp'  , STR0025 , 90, .F., .T.,, 'UP') //"Selecione os registros para distribuição de saldo"  
	
	// Recupera os Paineis das divisões do Layer
	oPnlUP  := oFwLayer:getWinPanel('ALL' , 'WndUp'  , 'UP')
					
	/**** GRID PARA SELECAO DOS DADOS *****/
	 
	cFiltro := " N8W_FILIAL='" + N8Y->N8Y_FILIAL + "' "
	cFiltro += " .And. N8W_SAFRA ='" + N8Y->N8Y_SAFRA  + "' "
	cFiltro += " .And. N8W_CODPLA='" + N8Y->N8Y_CODPLA + "' "
	cFiltro += " .And. N8W_DTFINA>='" + DtoS(LastDay(dDatabase)) + "' "
	
	dbSelectArea('N8W')
	N8W->(DbSetOrder(3))
	
	oBrwMrk:=FWMarkBrowse():NEW()   // Cria o objeto oMark - MarkBrowse
	oBrwMrk:SetFilterDefault(cFiltro)
	oBrwMrk:SetAlias("N8W") 
	oBrwMrk:SetOnlyFields( aCampos )
	oBrwMrk:SetFieldMark("N8W_OK")	
	oBrwMrk:SetCustomMarkRec({|| fmarcar( oBrwMrk ) })
	oBrwMrk:bAllMark := { ||SetMarkAll(oBrwMrk, lMarkAll := ! lMarkAll ), oBrwMrk:Refresh(.T.)    }
	oBrwMrk:SetSemaphore(.F.)
	oBrwMrk:DisableFilter()
	oBrwMrk:DisableReport()
	oBrwMrk:DisableDetails()
	oBrwMrk:DisableSeek()
	oBrwMrk:DisableSaveConfig()
	oBrwMrk:SetMenuDef("")
	oBrwMrk:Activate(oPnlUP)	// Ativa o MarkBrowse
	
	oDlg:Activate( , , , .t., { || .t. }, , { || EnchoiceBar( oDlg, {|| nOpcX := 1, oDlg:End() },{|| nOpcX := 0, oDlg:End() },, @aButtons ) } )
	
	If nOpcX = 1  
		oReturn := oBrwMrk
	EndIf
	
	RestArea(aArea)
Return oReturn


/** {Protheus.doc} PosModelo
Função para criação automática da tabela NCX após a confirmação
@param: 	oModel - Modelo de dados
@return:	lRetorno - verdadeiro ou falso
@author: 	tamyris.g
@since: 	31/01/2019
@Uso: 	
*/
Function PosModelo(oModel)
	Local aAreaAtu   := GetArea()
	Local oN8W		 := oModel:GetModel( "N8WUNICO" )
	Local nOperation := oModel:GetOperation()
    Local nX      := 0
    Local cSafra := ""
    Local lTemComp := .F.
    
    If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
	    nLinha := oN8W:GetLine()
	    
	    For nX := 1 to oN8W:Length()
	        oN8W:GoLine( nX )
	        if !(oN8W:isDeleted()) .And. oN8W:VldLineData() 
	        	
	        	//Criação da Tabela NCX - Itens x Componentes (Tabela Auxiliar)
	        	cAliasQry  := GetNextAlias()
	        	cQuery := "SELECT * "
				cQuery += "  FROM " + RetSqlName("NCX") + " NCX "
				cQuery += " WHERE NCX.NCX_FILIAL = '" + FwxFilial('NCX') + " '"
				cQuery += "   AND NCX.NCX_SAFRA  = '" + N8Y->N8Y_SAFRA + "' "
				cQuery += "   AND NCX.NCX_GRPROD = '" + N8Y->N8Y_GRPROD + "' "
				cQuery += "   AND NCX.NCX_CODPRO = '" + N8Y->N8Y_CODPRO + "' "
				cQuery += "   AND NCX.NCX_TIPMER = '" + oN8W:GetValue("N8W_TIPMER") + "' "
				cQuery += "   AND NCX.NCX_MOEDA  = '" + AllTrim(oN8W:GetValue("N8W_MOEDA2")) + "' "
				cQuery += "   AND NCX.D_E_L_E_T_ = ' ' "
				cQuery := ChangeQuery(cQuery)
				DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry,.F.,.T.)
			
				dbSelectArea(cAliasQry)
				(cAliasQry)->(dbGoTop())
				If (cAliasQry)->( Eof() )
					RecLock("NCX", .T.)
						NCX->NCX_FILIAL := FwxFilial('NCX')
						NCX->NCX_SAFRA  := N8Y->N8Y_SAFRA
						NCX->NCX_GRPROD := N8Y->N8Y_GRPROD             
						NCX->NCX_CODPRO := N8Y->N8Y_CODPRO             
						NCX->NCX_TIPMER := oN8W:GetValue("N8W_TIPMER")  
						NCX->NCX_MOEDA  := Val(oN8W:GetValue("N8W_MOEDA2"))   
					NCX->(MsUnLock())
					
					//Verificar se possui componentes de preço cadastrados em uma safra antiga e realiza a cópia
					lTemComp := .F.
					DbSelectArea("N8Z") 
					N8Z->(DbGoTop()) 
					N8Z->(DbSetOrder(1)) //N8Z_FILIAL+N8Z_SAFRA+N8Z_GRPROD+N8Z_CODPRO+N8Z_TIPMER+STR(N8Z_MOEDA)+N8Z_CODCOM
					If N8Z->(DbSeek(xFilial("N8Z")+N8Y->(N8Y_SAFRA+N8Y_GRPROD+N8Y_CODPRO)+oN8W:GetValue("N8W_TIPMER")+PadR(Alltrim(oN8W:GetValue("N8W_MOEDA2")),TamSx3('N8Z_MOEDA')[1] )))
						lTemComp := .T.
					EndIf
										
					If !lTemComp
						
						cAliasQry2  := GetNextAlias()
			        	cQuery := "SELECT * "
						cQuery += "  FROM " + RetSqlName("N8Z") + " N8Z "
						cQuery += " WHERE N8Z.N8Z_FILIAL = '" + FwxFilial('N8Z') + " '"
						cQuery += "   AND N8Z.N8Z_SAFRA  <> '" + N8Y->N8Y_SAFRA + "' "
						cQuery += "   AND N8Z.N8Z_GRPROD = '" + N8Y->N8Y_GRPROD + "' "
						cQuery += "   AND N8Z.N8Z_CODPRO = '" + N8Y->N8Y_CODPRO + "' "
						cQuery += "   AND N8Z.N8Z_TIPMER = '" + oN8W:GetValue("N8W_TIPMER") + "' "
						cQuery += "   AND N8Z.N8Z_MOEDA  = '" + AllTrim(oN8W:GetValue("N8W_MOEDA2")) + "' "
						cQuery += "   AND N8Z.D_E_L_E_T_ = ' ' "
						cQuery += " ORDER BY N8Z_SAFRA " 
						cQuery := ChangeQuery(cQuery)
						DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasQry2,.F.,.T.)
					
						dbSelectArea(cAliasQry2)
						(cAliasQry2)->(dbGoTop())
						If (cAliasQry2)->( !Eof() )
							While ( cAliasQry2 )->( !Eof() ) .And. (Empty(cSafra) .Or. cSafra == (cAliasQry2)->N8Z_SAFRA) 
								cOrdem :=  GetSXENum("N8Z","N8Z_ORDEM") 
								ConfirmSX8()
								
								DbSelectArea("N8Z")
								RecLock("N8Z", .T.)
									N8Z->N8Z_FILIAL := FwxFilial('N8Z')
									N8Z->N8Z_SAFRA  := N8Y->N8Y_SAFRA
									N8Z->N8Z_GRPROD := N8Y->N8Y_GRPROD             
									N8Z->N8Z_CODPRO := N8Y->N8Y_CODPRO             
									N8Z->N8Z_TIPMER := oN8W:GetValue("N8W_TIPMER")  
									N8Z->N8Z_MOEDA  := Val(oN8W:GetValue("N8W_MOEDA2"))  
									N8Z->N8Z_ORDEM  := cOrdem 
									N8Z->N8Z_CODCOM := (cAliasQry2)->N8Z_CODCOM 
									N8Z->N8Z_UNIMED := (cAliasQry2)->N8Z_UNIMED 
									N8Z->N8Z_MOEDA2 := (cAliasQry2)->N8Z_MOEDA2 
									N8Z->N8Z_CALCUL := (cAliasQry2)->N8Z_CALCUL 
									N8Z->N8Z_TIPPRC := (cAliasQry2)->N8Z_TIPPRC 
									N8Z->N8Z_TIPVAL := (cAliasQry2)->N8Z_TIPVAL
									N8Z->N8Z_PERAPL := 100 
									
									cSafra :=  (cAliasQry2)->N8Z_SAFRA 
									
								N8Z->(MsUnLock())
								
								(cAliasQry2)->( DbSkip() )
							EndDo
						EndIf
						(cAliasQry2)->(DbcloseArea())
					EndIF
					
				EndIf
				(cAliasQry)->(DbcloseArea())
	        EndIf
	    Next nX
	    oN8W:GoLine( nLinha )
    EndIF
    
	RestArea( aAreaAtu )

Return .T.


/*{Protheus.doc} fMarcar(oMrkBrowse)
Marca ou desmarca itens do Browse Inferior
@param     Objeto do Browse inferior
@sample    fMarcar(oMrkBrowse)
@return    Linha do Browse Recebe ou retira a Marca
@author    tamyris.g
@since      25/01/2019
@version    P11
*/
Static Function fMarcar( oMrkBrowse )
	Local aAreaAtu	:= GetArea()

	If ( !oMrkBrowse:IsMark() )
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->N8W_OK  := oMrkBrowse:Mark()
		(oMrkBrowse:Alias())->(MsUnLock())
	Else
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->N8W_OK  := ""
		(oMrkBrowse:Alias())->(MsUnLock())
	EndIf

	RestArea( aAreaAtu )
Return( .T. )

/*{Protheus.doc} SetMarkAll
Função q Marca ou desmarca todos os Registros da N8W 
@param     	objeto Browse da N8W	
Flag de Marcar ou Desmarcar
@return    Itens Marcados ou Desmarcados no Browse
@author    tamyris.g
@since      25/01/2019
/*/
Static Function SetMarkAll(oMrkBrowse,lMarcar )

	(oMrkBrowse:Alias())->( DbGotop() )
	While !( oMrkBrowse:Alias() )->( Eof() )
		RecLock(oMrkBrowse:Alias(),.F.)
		(oMrkBrowse:Alias())->N8W_OK  :=  IIf( lMarcar, oMrkBrowse:Mark(), "" )
		(oMrkBrowse:Alias())->(MsUnLock())
		(oMrkBrowse:Alias())->(DbSkip() )
	EndDo

Return .T.

/*/{Protheus.doc} fN8WInit
Função responsavel em iniciar o valor copiado da linha superior
@type  Static Function
@author tamyris.g	
@since 26/02/2019
@version 1.0
@param oField, object, objeto do campo
@return nValor, numeric, valor inicial copiado da linha superior
@example
(examples)
@see (links_or_references)
/*/
Static Function fN8WInit(oField, cCampo)
Local aValor := 0
Local oModel := oField:GetModel()
Local oN8W   := oModel:GetModel( "N8WUNICO" )

If oN8W:Length() >= 1
	
	If cCampo == "N8W_TIPMER" 
		aValor := oN8W:GetValue("N8W_TIPMER", oN8W:Length())
	Elseif cCampo == "N8W_MOEDA2" 
		aValor := oN8W:GetValue("N8W_MOEDA2", oN8W:Length())
	Else
	    aValor := oN8W:GetValue("N8W_MOEDA", oN8W:Length())
	EndIF
EndIf

Return aValor

/*/{Protheus.doc} OGA880CONTR
@author vanilda.moggio
@since 21/02/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Function OG830CONTR(oModel)
	Local oStrN8Y		:= oModel:getModel("N8YVISUL")
	Local oStrN8W		:= oModel:getModel("N8WUNICO")
	Local dDEntrFim 	:= oStrN8W:getValue("N8W_DTFINA")
	Local cFiliN8y      := oStrN8Y:getValue("N8Y_FILIAL")

	_cFilter    :=  ''	
	
	OG830FILT(oModel, .F.)

	If  (MOnth(dDEntrFim) = MOnth(dDatabase))
		OG830FILT(oModel, .T.)
	EndIf
	
	IF Empty(_cFilter) 
	   _cFilter := " N9A_CODCTR = ' ' "
	Else 
	   _cFilter += IIF(Empty(_cFilter), "'" + AllTrim(_cFiliN8Y) + "' $ N9A_FILORG " ,  ") .AND. '" + AllTrim(cFiliN8Y) + "' $ N9A_FILORG ")	  
	EndIF
	 
	OGC062(_cFilter, _aN9AVend ) 
	_cFilter  := ''
	_aN9AVend := {}

Return .T.


/*/{Protheus.doc} FGetMoPV
//TODO Descrição auto-gerada.
@author vanilda.moggio
@since 14/03/2019
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function FGetMoPV (nMoeda)

Local cMoeda:= cValtochar(nMoeda) + '=' + SuperGetMv("MV_MOEDA"+AllTrim(Str(nMoeda,2)), .F., "" ) 

return cMoeda


/*/{Protheus.doc} OG830FILT
Monta a query de filtro e array com as quantidades a serem exibidas no OGC062
@type  Static Function
@author rafael.kleestadt / vanilda.moggio
@since date
@version version
@param oModel, object, objeto do modelo principal
@param lMesAtual, Logycal, indica se deve ser agutinado os dados para o mês atual
@return return, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function OG830FILT(oModel, lMesAtual)
	Local oStrN8Y		:= oModel:getModel("N8YVISUL")
	Local oStrN8W		:= oModel:getModel("N8WUNICO")
    Local cProduto 		:= oStrN8W:getValue("N8W_CODPRO")
	Local cSafra        := oStrN8Y:getValue("N8Y_SAFRA") 
	Local dDEntrIni 	:= oStrN8W:getValue("N8W_DTINIC")
	Local dDEntrFim 	:= oStrN8W:getValue("N8W_DTFINA")
	Local nMoeda 		:= Val(oStrN8W:getValue("N8W_MOEDA2"))
	Local nTipMer		:= oStrN8W:getValue("N8W_TIPMER")
	Local cGrupo        := oStrN8W:getValue("N8W_GRPROD") 
	Local cQuery        := ''
	Local nPosC         := 0
		
	_cFilter    :=  IIF(!lMesAtual,'',_cFilter)
	
	cQuery := ""
	cQuery += " SELECT DISTINCT NNY_FILIAL,NJR_CODCTR,NNY_ITEM, NNY_DATFIM"
	
	IF (MOnth(dDEntrFim) <= month(dDatabase)) .and. !lMesAtual 
	   cQuery += " , NJM_SEQPRI, NJM_QTDFIS " 	
	EndIF 
	
	cQuery += " FROM " + RetSqlName('NJR') + ' NJR '
	
    IF Empty(cProduto) //Por grupo   
       cQuery += "INNER JOIN " +  RetSqlName("SB1") + " SB1"
       cQuery += "  ON SB1.B1_FILIAL = '" + xFilial('SB1') + "'"
       cQuery += "  AND SB1.B1_GRUPO =  '" + cGrupo + "'"
       cQuery += "  AND SB1.D_E_L_E_T_ = '' "      
    EndIF

    cQuery += " INNER JOIN " + RetSqlName("NNY") + " NNY ON NNY.NNY_FILIAL = '" + xFilial("NNY") + "' AND NNY.NNY_CODCTR = NJR_CODCTR AND NNY.D_E_L_E_T_  = '' "
	
	IF (MOnth(dDEntrFim) > MOnth(dDatabase)) .or. lMesAtual 
	    cQuery += "  AND NNY_DATFIM <= '"+  dtos(dDEntrFim) + "' AND NNY_DATFIM >= '" + dtos(dDEntrIni) + "'"
    Else         
        cQuery += " INNER JOIN " +  RetSqlName('NJM') + " NJM "
        cQuery += "   ON NJM_FILIAL LIKE '" + AllTrim(N8Y->N8Y_FILIAL) + "%'"
        cQuery += "   AND NJM_CODCTR = NJR_CODCTR "
	    cQuery += "   AND NJM_DOCEMI >= '"+ dtos(dDEntrIni) +"'"
	    cQuery += "   AND NJM_DOCEMI <= '"+ dtos(dDEntrFim) +"'"
	    cQuery += "   AND NJM_DOCNUM <> '' "
		cQuery += "   AND NJM.D_E_L_E_T_ = '' "
		cQuery += "   AND NNY_ITEM = NJM_ITEM "		
    EndIF       
    
    cQuery += " WHERE NJR.NJR_FILIAL  = '" + xFilial("NJR") + "' AND NJR.D_E_L_E_T_ = '' AND NJR.NJR_CODSAF =  '" + cSafra + "'"
    
    IF !Empty(cProduto) //Por produto   
       	cQuery += "   AND NJR.NJR_CODPRO = '" + cProduto + "'
    Else //Por grupo de produto
		cQuery += " AND   NJR.NJR_CODPRO = SB1.B1_COD "
	EndIf
	
    cQuery += " AND NJR.NJR_TIPMER = '" + nTipMer 
    
    IF  nMoeda = 1	       
        cQuery += "'AND NJR.NJR_MOEDA = " + str(nMoeda)
    Else
    	cQuery += "'AND NJR.NJR_MOEDA <>  1 " 
    EndIF
    
    cQuery:=ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"QryNJR",.F.,.T.)
	QryNJR->(DbGoTop())
	 
	While !QryNJR->(EOF())	
	  IF (MOnth(dDEntrFim) > MOnth(dDatabase))  .or. lMesAtual
	     IF !Empty(QRYNJR->NNY_DATFIM)
	        IF  QRYNJR->NNY_DATFIM <= dtos(dDEntrFim) .AND. QRYNJR->NNY_DATFIM >= dtos(dDEntrIni)
	            If !Empty(_aN9AVend)
					If aScan( _aN9AVend, { |x| AllTrim( x[4] ) == AllTrim(QRYNJR->NNY_FILIAL + QRYNJR->NJR_CODCTR + QRYNJR->NNY_ITEM ) } ) == 0
						_cFilter += IIF(Empty(_cFilter) , "((N9A_FILIAL='"+QRYNJR->NNY_FILIAL+"'" , " .OR. (N9A_FILIAL='"+QRYNJR->NNY_FILIAL+"'")                 
						_cFilter += " .AND. N9A_CODCTR='"+QRYNJR->NJR_CODCTR+"'"
						_cFilter += " .AND. N9A_ITEM='"+QRYNJR->NNY_ITEM+"' )"
					EndIf
				Else
					_cFilter += IIF(Empty(_cFilter) , "((N9A_FILIAL='"+QRYNJR->NNY_FILIAL+"'" , " .OR. (N9A_FILIAL='"+QRYNJR->NNY_FILIAL+"'")                 
					_cFilter += " .AND. N9A_CODCTR='"+QRYNJR->NJR_CODCTR+"'"
					_cFilter += " .AND. N9A_ITEM='"+QRYNJR->NNY_ITEM+"' )"
				EndIf
					   	            	        
	        ENDIF
	     ENDIF
	  Else	   
		   	nPosC := aScan( _aN9AVend, { |x| AllTrim( x[1] ) == AllTrim(QRYNJR->NNY_FILIAL + QRYNJR->NJR_CODCTR + QRYNJR->NNY_ITEM + QRYNJR->NJM_SEQPRI) } )
			If nPosC == 0
				aAdd( _aN9AVend, { AllTrim(QRYNJR->NNY_FILIAL + QRYNJR->NJR_CODCTR + QRYNJR->NNY_ITEM +  QRYNJR->NJM_SEQPRI), QRYNJR->NJM_QTDFIS,dDEntrFim, AllTrim(QRYNJR->NNY_FILIAL + QRYNJR->NJR_CODCTR + QRYNJR->NNY_ITEM) } )
				
				_cFilter += IIF(Empty(_cFilter), "((N9A_FILIAL='"+QRYNJR->NNY_FILIAL+"'" , " .OR. (N9A_FILIAL='"+QRYNJR->NNY_FILIAL+"'")                 
				_cFilter += " .AND. N9A_CODCTR='"+QRYNJR->NJR_CODCTR+"'"
				_cFilter += " .AND. N9A_ITEM='"+QRYNJR->NNY_ITEM + "' 
				_cFilter += " .AND. N9A_SEQPRI='"+QRYNJR->NJM_SEQPRI +"' )"	 
			Else
				_aN9AVend[nPosC,2] +=  QRYNJR->NJM_QTDFIS
			EndIf
	   ENDIF  
       QryNJR->(dbSkip())
	EndDo	
	QryNJR->(dbCloseArea())	

Return 
