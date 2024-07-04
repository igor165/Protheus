#Include 'Protheus.ch'
#Include "FWMVCDEF.ch"
#INCLUDE 'FwEditPanel.CH'
#Include 'FINA694B.CH'

/*/{Protheus.doc} ViewDef
Interface do modelo de dados.
@author William Matos
@since 30/10/15
/*/
Static Function ViewDef()
Local oView := FWFormView():New()
Local oFO4  := FWFormStruct(2,"FO4", {|x| !AllTrim(x)$ "FO4_CODIGO|FO4_NRCART"})
Local oFWN  := FWFormStruct(2,"FWN", {|x| AllTrim(x) $ "FWN_VTRANS|FWN_DESCRI"})
Local oModel:= ModelDef()
Local oCalc := Nil

// Cria o objeto de Estrutura
oCalc := FWCalcStruct( oModel:GetModel('FCALC') )
//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddField( 'VIEW_CALC', oCalc, 'FCALC' )
//
oFO4:SetProperty("FO4_VALOR"	, MVC_VIEW_CANCHANGE, .F.)
oFO4:SetProperty("FO4_VCONFE"  , MVC_VIEW_CANCHANGE, .F.)
oFWN:SetProperty("*"			, MVC_VIEW_CANCHANGE, .F.)
oView:SetModel(oModel)
//
oView:CreateHorizontalBox('BOX_FWN',030)
oView:CreateVerticalBox("BOX_ID1",65,'BOX_FWN')
oView:CreateVerticalBox("BOX_ID2",35,'BOX_FWN')
oView:CreateHorizontalBox('BOX_FO4',070)
oView:CreateHorizontalBox( 'TOTAL' ,100,"BOX_ID2" )
//
oView:AddField("VIEW_FWN",oFWN,"FWNMASTER")
oView:AddGrid( "VIEW_FO4",oFO4,"FO4DETAIL")
//
oView:SetViewProperty("VIEW_FWN","SETLAYOUT",{FF_LAYOUT_HORZ_DESCR_TOP ,1}) 
oView:SetViewProperty("VIEW_CALC","SETLAYOUT",{FF_LAYOUT_HORZ_DESCR_TOP ,1}) 
//
oView:SetOwnerView("VIEW_FO4","BOX_FO4")
oView:SetOwnerView("VIEW_FWN","BOX_ID1")
oView:SetOwnerView('VIEW_CALC','TOTAL' )
oView:EnableTitleView('VIEW_FO4' , STR0006 ) 
oView:AddIncrementField('VIEW_FO4','FO4_ITEM' )

Return oView

/*/{Protheus.doc} ModelDef
Modelo de dados.
@author William Matos
@since 30/10/15
/*/
Static Function ModelDef()
Local oModel694A  	:= FWModelActive()
Local oView694A		:= FWViewActive()
Local oModel 			:= Nil
// Inclusão de FindFunction pois a rotina nao foi encontrada no repositorio.
Local bValid 			:=  {|| .T. } 
Local oFO4 	 		:= FWFormStruct(1,"FO4")
Local oFWN 	 		:= FWFormStruct(1,"FWN")
Local aRelac		:= {}
Local bVldVInfor	:= Nil

oModel := MPFormModel():New("FINA694B",/*Pre*/,bValid,{|x,y,z| FN694BGRV(oModel,oModel694A,oView694A)}/*Commit/*,/*bCancel*/)

FWN->(dbSetOrder(3))
FWN->(dbSeek( xFilial("FWN") + oModel694A:GetValue("FWNDETAIL","FWN_EBTA")))

oFO4:AddTrigger("FO4_VALOR","FO4_VALOR",{|| .T. }, {|oModel| F694BVal(oModel) } )
oFO4:AddField(' ','ENCERRADO','FO4_ENCERRADO', 'L', 1, 0,/*bValid*/,/*bWhen*/,/*aValues*/,/*lObrigat*/,{||.F.} )
bVldVInfor := FwBuildFeature( STRUCT_FEATURE_VALID,"Positivo() .and. F694BVldV()")
oFO4:SetProperty("FO4_VINFOR" , MODEL_FIELD_VALID , bVldVInfor )
//
aAdd(aRelac, {"FO4_FILIAL", "xFilial('FO4')"})
aAdd(aRelac, {"FO4_NRCART", "FWN_EBTA" })
//
oModel:AddFields("FWNMASTER",/*cOwner*/,oFWN)
oModel:AddGrid('FO4DETAIL','FWNMASTER',oFO4)
//
oModel:AddCalc( 'FCALC', 'FWNMASTER', 'FO4DETAIL', 'FO4_VINFOR', 'FWN_TOTCALC', 'SUM',,,STR0001 ) 
//
oModel:GetModel( 'FWNMASTER'):SetOnlyQuery ( .T. )
oModel:GetModel( 'FO4DETAIL' ):SetUniqueLine( { 'FO4_IDRESE' } )
oModel:SetRelation("FO4DETAIL",aRelac, FO4->(IndexKey(2)) )
oModel:SetActivate({|| FN694BAct(oModel694A)})

Return oModel


/*/{Protheus.doc} FN694BAct
Ativação do modelo de dados.
@param oModel - Modelo da rotina FINA694A.
@author William Matos
@since 30/10/15
/*/
Function FN694BAct(oModel694A)
Local oModel := FWModelActive()
Local oAux	 := oModel:GetModel("FO4DETAIL")
Local aArea	 := GetArea()

	oModel:LoadXMLData( oModel694A:GetValue("FWNDETAIL","FWN_XML") )

RestArea(aArea)

Return 

/*/{Protheus.doc} FN694BAct
Gravação do modelo de dados.
@param oModel - modelo ativo.
@param oModel694A - Modelo da rotina FINA694A.
@param oView694A - interface da rotina FINA694A
@author William Matos
@since 30/10/15
/*/
Function FN694BGRV(oModel,oModel694A, oView694A)

	oModel694A:SetValue("FWNDETAIL","FWN_XML"  , oModel:GetXMLData() )
	oModel694A:SetValue("FWNDETAIL","FL6_TOTAL", oModel:GetValue("FCALC","FWN_TOTCALC") )
	oModel694A:SetValue("FWNDETAIL","STSVIAG"  , FN694ImgSt("4",1)) //Conciliado manualmente.
	oModel694A:SetValue("FWNDETAIL","SEPCOL"   , FN694ImgSt("4",2))
	oModel694A:SetValue("FWNDETAIL","FWN_VIAGEM", oModel:GetValue("FO4DETAIL","FO4_IDRESE") )	
	//
	oModel694A:SetValue('FLQMASTER','FLQ_TOTAL', oModel694A:GetValue('FLQMASTER','FLQ_TOTAL') + oModel:GetValue("FCALC","FWN_TOTCALC") )
	oView694A:Refresh()
	oModel:DeActivate()

Return .T.

/*/{Protheus.doc} F694BVal
Gatilho do campo valor, utilizado para preencher os outros valores.
@param oAux - modelo ativo.
@author William Matos
@since 30/10/15
/*/
Function F694BVal(oAux)
Local aArea	 := GetArea()
Local oModel := FWModelActive()
Local nValue := oAux:GetValue("FO4_VALOR")

	oModel:SetValue("FO4DETAIL","FO4_VINFOR", nValue )
	oModel:SetValue("FO4DETAIL","FO4_VCONFE", nValue )
	
Return nValue

/*/{Protheus.doc} F694BVal
Pós validação do submodelo FO4DETAIL.
@author William Matos
@since 30/10/15
/*/
Function F694BVldV()
Local lRet 		    := .T.
Local oModel        := FWModelActive()
Local oView			:= FWViewActive()
Local nValInfo      := oModel:GetValue("FO4DETAIL","FO4_VINFOR")
Local nTotal		:= oModel:GetValue("FO4DETAIL","FO4_VALOR")

	If !FWIsInCallStack("FINA694")
		If nValInfo > nTotal
			
			lRet := MsgYesNo( STR0002,STR0003)
			
		ElseIf nValInfo < nTotal
			If MsgYesNo( STR0004 ,STR0005)	//"O Valor informado para o Pedido é menor que o valor previsto."###"" ?"###
				//Coloca o item como encerrado.
				oModel:LoadValue("FO4DETAIL", "FO4_ENCERRADO","S")
			Else
				oModel:LoadValue("FO4DETAIL", "FO4_ENCERRADO","N")	
			EndIf
			lRet := .T.
		EndIf	
				
		If oView != Nil
			oView:Refresh()
		EndIf
	EndIf	
	
Return lRet


/*/{Protheus.doc} FN694BAtu
Atualização do status da viagem.
@param oModel - Modelo de dados.
@author William Matos
@since 30/10/15
/*/
Function FN694BAtu(oModel)
Local oAux	  	:= oModel:GetModel("FWNDETAIL") 
Local cIDRese 	:= ""
Local nX	  	:= 0
Local nA		:= 0 
Local nVlrConf	:= 0
Local oIDRese	:= Nil

	//Atualiza o status das viagens
	dbSelectArea("FL5")
	dbSetOrder(1)
	FL6->(DbSetOrder(3)) //FILIAL + IDRESE
	//
	For nX := 1 To oAux:Length()	
		
		oAux:GoLine( nX )
		//
		If !Empty(oAux:GetValue("FL6_IDRESE", nX))

			cIDRese 	:= oAux:GetValue("FL6_IDRESE", 	nX)
			nVlrConf 	:= oAux:GetValue("FWN_VTRANS",	nX)
			oAux:LoadValue('FWN_CONFER', oModel:GetValue("FLQMASTER","FLQ_CONFER") )
			oAux:LoadValue('FWN_TPDESP',"2") //Hotel
			//
			If FL6->(dbSeek( xFilial("FL6") + cIDRese ))
	
				/*Atualiza o valor conferido e o status da viagem */
				RecLock("FL6",.F.)
				nVlrConf := FL6->FL6_VCONFE + (nVlrConf * (FL6->FL6_TOTAL / oAux:GetValue("FL6_TOTAL",nX)))
				Replace FL6->FL6_VCONFE	With nVlrConf
				If nVlrConf >= FL6->FL6_TOTAL
					Replace FL6->FL6_STATUS	With "2"		//totalmente conferido
				Else
					Replace FL6->FL6_STATUS	With "1"		//parcialmente conferido
				EndIf 					
				//Grava tabela FLV - Pedido vs Conferencia
				RecLock("FLV",.T.)
				FLV->FLV_FILIAL := xFilial("FLV")
				FLV->FLV_CONFER	:= oModel:GetValue("FLQMASTER","FLQ_CONFER") 
				FLV->FLV_VIAGEM := FL6->FL6_VIAGEM
				FLV->FLV_ITEM   := FL6->FL6_ITEM
				FLV->FLV_VALOR  := oAux:GetValue("FL6_TOTAL", nX)
				FLV->FLV_STATUS := '1'
				MsUnlock()			
			EndIf
			
		ElseIf !Empty(oAux:GetValue("FWN_XML", nX))
			
			oAux:LoadValue('FWN_CONFER', oModel:GetValue("FLQMASTER","FLQ_CONFER") )
			oAux:LoadValue('FWN_TPDESP',"2") //Hotel
			oIDRese := FWLoadModel("FINA694B")
			oIDRese:SetOperation( MODEL_OPERATION_VIEW )
			oIDRese:Activate()
			oIDRese:LoadXMLData( oAux:GetValue("FWN_XML", nX) )
			//
			For nA := 1 To oIDRese:GetModel("FO4DETAIL"):Length()
			
				cIDRese 	:= oIDRese:GetValue("FO4DETAIL","FO4_IDRESE", 	nA)
				nVlrConf 	:= oIDRese:GetValue("FO4DETAIL","FO4_VINFOR",	nA)
				
				//
				If FL6->(dbSeek( xFilial("FL6") + cIDRese ))
			
					/*Atualiza o valor conferido e o status da viagem */
					RecLock("FL6",.F.)
					nVlrConf := FL6->FL6_VCONFE + nVlrConf 
					Replace FL6->FL6_VCONFE	With nVlrConf
					If nVlrConf >= FL6->FL6_TOTAL
						Replace FL6->FL6_STATUS	With "2"		//Totalmente.
					Else
						Replace FL6->FL6_STATUS	With "1"		//Parcialmente.
					EndIf 					
					//Grava tabela FLV - Pedido vs Conferencia
					RecLock("FLV",.T.)
					FLV->FLV_FILIAL := xFilial("FLV")
					FLV->FLV_CONFER	:= oModel:GetValue("FLQMASTER","FLQ_CONFER") 
					FLV->FLV_VIAGEM := FL6->FL6_VIAGEM
					FLV->FLV_ITEM   := FL6->FL6_ITEM
					FLV->FLV_VALOR  := oIDRese:GetValue("FO4DETAIL","FO4_VALOR",nA)
					FLV->FLV_STATUS := '1'
					MsUnlock()	
				
				EndIf
			
			Next nA
			
			oIDRese:DeActivate()
			oIDRese:Destroy()
			
		EndIf	
		
	Next nX

Return 
