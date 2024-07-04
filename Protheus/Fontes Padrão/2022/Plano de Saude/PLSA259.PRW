#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//#include 'PLSA259.CH'
		
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA259   บAutor  Roberto Barbosa       บ Data ณ  17/07/18  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para altera็ใo do Hist๓rico de Bloqueio             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/ 
Function PLSA259()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BA1' )
oBrowse:SetDescription( Fundesc() )	
oBrowse:SetMenuDef( 'PLSA259' )
oBrowse:aOnlyFields := {'BA1_CODINT','BA1_CODEMP', 'BA1_NOMUSR', 'BA1_MATRIC','BA1_TIPREG'}

oBrowse:Activate()

Return NIL            

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA259   บAutor  ณRoberto Barbosa      บ Data ณ  17/07/18  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao de menu PLSA259								  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ TOTVS - SIGAPLS                                            ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/             
Static Function MenuDef()
Private aRotina := {}
  
  aAdd( aRotina, { 'Pesquisar'  , 				'PesqBrw'         , 0, 1, 0, .T. } )//'Pesquisar'
  aAdd( aRotina, { 'Visualizar'  , 			   	'VIEWDEF.PLSA259', 0, 2, 0, NIL } ) //'Visualizar'
  aAdd( aRotina, { 'Alterar'  , 				'VIEWDEF.PLSA259', 0, 4, 0, NIL } )//'Alterar'

Return aRotina
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPLSA259   บAutor  ณRoberto Barbosa      บ Data ณ  17/07/18  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณDefinicao do modelo MVC PLSA259							  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑณ Uso      ณ TOTVS - SIGAPLS                                            ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/              
Static Function ModelDef()											
	Static oModelB	
	Local oStruBA1 := FWFormStruct( 1, 'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_TIPREG|BA1_NOMUSR|BA1_DIGITO|' } )
	Local oStruBCA := FWFormStruct( 1, 'BCA' )
	
	// Cria o objeto do Modelo de Dados	 
	oModelB := MPFormModel():New('PLSA259')
		
	// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
	oModelB:AddFields( 'BA1MASTER',NIL, oStruBA1 )
	oModelB:SetPrimaryKey({})

	//Faz relaciomaneto entre os compomentes do model
	oModelB:AddGrid( 'BCADETAIL', 'BA1MASTER', oStruBCA) 
	oModelB:GetModel( 'BCADETAIL' ):SetMaxLine(999999999)

	oModelB:SetRelation( 'BCADETAIL', { { 'BCA_FILIAL', 'xFilial( "BCA" )' }, { 'BCA_MATRIC', 'BA1->(BA1_CODINT + BA1_CODEMP + BA1_MATRIC)' }, { 'BCA_TIPREG', 'BA1->BA1_TIPREG' } } )								
	
	//Adiciona a descricao do Modelo de Dados
	oModelB:SetDescription( FunDesc() )	

	//Adiciona a descricao do Componente do Modelo de Dados
	oModelB:GetModel( 'BA1MASTER' ):SetDescription( 'Beneficiario' )	
	oModelB:GetModel( 'BCADETAIL' ):SetDescription( 'Hist๓rico de Bloqueio' )	

	oModelB:GetModel( 'BA1MASTER' ):SetOnlyQuery(.T.)
	oModelB:GetModel( 'BA1MASTER' ):SetOnlyView(.T.)	

	/*Valido a altera็ใo do campo no Grid*/
	oStruBCA:setProperty( 'BCA_DATA', MODEL_FIELD_VALID, { || VldMovBlo(oModelB)} )	
	oStruBCA:setProperty( 'BCA_MOTBLO', MODEL_FIELD_VALID, { || VldMovBlo(oModelB)} )		
	
Return oModelB

//-------------------------------------------------------------------
Static Function ViewDef()  
local oStruBA1 := FWFormStruct( 2, 'BA1', { |cCampo| AllTrim(cCampo) $ 'BA1_CODINT|BA1_CODEMP|BA1_TIPREG|BA1_DIGITO|BA1_NOMUSR' } )
Local oStruBCA := FWFormStruct( 2, 'BCA', { |cCampo| AllTrim(cCampo) $ 'BCA_TIPREG|BCA_TIPO|BCA_DATA|BCA_MOTBLO|BCA_DESBLO|BCA_OBS|BCA_USUOPE|BCA_BLOFAT|BCA_DATPED|BCA_DATLAN|BCA_HORLAN|BCA_SOL412' } )
Local oModelB  := FWLoadModel( 'PLSA259' )

	oView := FWFormView():New()
	oView:SetModel( oModelB )

	oView:AddField( 'VIEW_BA1', oStruBA1, 'BA1MASTER' )
	oView:AddGrid(  'VIEW_BCA', oStruBCA, 'BCADETAIL' )

	oView:CreateHorizontalBox( 'SUPERIOR', 25 )
	oView:CreateHorizontalBox( 'INFERIOR', 75 )
	
	oView:EnableTitleView('VIEW_BCA','Hist๓rico de Bloqueio')
	
	oView:SetOwnerView( 'VIEW_BA1', 'SUPERIOR'  )
	oView:SetOwnerView( 'VIEW_BCA', 'INFERIOR' )
	
	/*Nใo permito adicionar linhas no Grid*/
	oModelB:GetModel( 'BCADETAIL' ):SetNoInsertLine( .T. )
	
	/*Nใo permito altera็ใo nos campos*/
	oStruBCA:SetProperty( 'BCA_TIPREG',MVC_VIEW_CANCHANGE,.F.)	
	oStruBCA:SetProperty( 'BCA_TIPO',  MVC_VIEW_CANCHANGE,.F.)	
	oStruBCA:SetProperty( 'BCA_DESBLO',MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( 'BCA_USUOPE',MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( 'BCA_BLOFAT',MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( 'BCA_DATPED',MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( 'BCA_DATLAN',MVC_VIEW_CANCHANGE,.F.)
	oStruBCA:SetProperty( 'BCA_HORLAN',MVC_VIEW_CANCHANGE,.F.)	
	oStruBCA:SetProperty( 'BCA_SOL412',MVC_VIEW_CANCHANGE,.F.)

Return oView


/*ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldMovBlo()   บAutor  ณRoberto Barbosa   บ Data ณ  20 /07/18บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida็ใo dos campos de data de Bloqueio 		  		  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function VldMovBlo(oModelB)
	Local oBCA
	Local oBA1
	Local nLinhaAtual := 0
	Local lPermAlt := .T.
	Local nI
	Local cMatric
	Local cTipReg 
	Local dData // Data ap๓s a altera็ใo em tela
	Local aDados := {} 	
	Local cChave    := " "
	Local aDadSIB := {}	
	Local I := 0
	Local aDadBCA   := {}		
	LOCAL cHoraLan  := "" //Hora antes da altera็ใo.
	LOCAL cHoraAtu  := ""	
	Local cAutomato := ""
	Local lContinua := .F.
	Local dDataAnt  := CTOD('')//Data antes da altera็ใo
	Local cMBloAnt  := "" 
	

	lPermAlt := oModelB:Activate()	

	//Preparo os dados
	if oModelB <> nil .and. lPermAlt
		oBCA	    := oModelB:GetModel('BCADETAIL')
		oBA1		:= oModelB:GetModel('BA1MASTER')
		nLinhaAtual := oBCA:GetLine()
		oBCA:GoLine(nLinhaAtual)
		cAutomato := AllTrim(oBCA:GetValue("BCA_OBS"))		

		If cAutomato != "lAutomato" 
			aDados   := _aDados(oModelB)
			dDatAnt  := aDados[nLinhaAtual][1][1][6] //Data antes da altera็ใo do Grid
			cMBloAnt := aDados[nLinhaAtual][1][1][7]
		Else
			dDatAnt := CTOD("29/11/2018")
		EndIf
		cMatric  := oBCA:GetValue("BCA_MATRIC")
		cTipReg  := oBCA:GetValue("BCA_TIPREG") 
		cDigito  := oBA1:GetValue("BA1_DIGITO")
		cHoraLan := oBCA:GetValue("BCA_HORLAN")  				

		dData   := oBCA:GetValue("BCA_DATA")//Data ap๓s a altera็ใo do Grid

	Else
		cMatric := BCA->BCA_MATRIC
		cTipReg := BCA->BCA_TIPREG 
		cDigito := BA1->BA1_DIGITO		
		dData := BCA->BCA_DATA 
		If cAutomato != "lAutomato" 
			aDados  := _aDados(oModelB)
			dDatAnt := aDados[nLinhaAtual][1][1][6] //Data antes da altera็ใo do Grid
		Else
			dDatAnt := CTOD("29/11/2018")
		EndIf		 

	EndIf		

	aDadBCA := aClone(oBCA:aDataModel)

	//Pesquiso movimenta็ใo na BD5 - Digita็ใo de Contas     
	cChave := cMatric + cTipReg	+ cDigito	

	BD5->(DbSetOrder(5)) 
	If	BD5->(MsSeek(xFilial("BD5") + cChave))		
		While !BD5->(Eof())	.and. BD5->(BD5_FILIAL+BD5_OPEUSR+BD5_CODEMP+BD5_MATRIC+BD5_TIPREG+BD5_DIGITO) ==  xFilial("BD5")+cChave				
			If (BD5->BD5_DATPRO >= dData .and. BD5->BD5_DATPRO <= dDatAnt) .or. (BD5->BD5_DATPRO>= dDatAnt .and. BD5->BD5_DATPRO <= dData )
				lPermAlt := .F.
				If cAutomato != "lAutomato" 
					Help( ,, 'Help',, 'Movimenta็ใo na BD5 ' + cvaltochar(nI) + ' '/*"บ linha."*/, 1, 0 )
				EndIf					
				Return(lPermAlt)				
			EndIf
			BD5->(DbSkip())
		EndDo		
	EndIf

	//Pesquiso movimenta็ใo na BE4 - Digita็ใo de contas - Interna็๕es     
	BE4->(DbSetOrder(4))
	If	BE4->(MsSeek(xFilial("BE4") + cChave))		
		While !BE4->(Eof()) .and. BE4->(BE4_FILIAL+BE4_OPEUSR+BE4_CODEMP+BE4_MATRIC+BE4_TIPREG) == xFilial("BE4")+cChave					
			If (BE4->BE4_DTDIGI >= dData .and. BE4->BE4_DTDIGI <= dDatAnt) .or. (BE4->BE4_DTDIGI>= dDatAnt .and. BE4->BE4_DTDIGI <= dData )
				lPermAlt := .F.
				If cAutomato != "lAutomato"
					Help( ,, 'Help',, 'Movimenta็ใo na BE4 ' + cvaltochar(nI) + ' '/*"บ linha."*/, 1, 0 )
				EndIf					
				Return(lPermAlt)				
			EndIf
			BE4->(DbSkip())
		EndDo		
	EndIf

	//Pesquiso movimenta็ใo na BOW - Protocolo de Reembolso		
	BOW->(DbSetOrder(5))	
	If BOW->(MsSeek(xFilial("BOW") + cChave ))								 			
		While !BOW->(Eof()) .and. BOW->(BOW_FILIAL+BOW_USUARI) == xFilial("BOW")+ cChave 
			If (BOW->BOW_DTDIGI >= dData .and. BOW->BOW_DTDIGI <= dDatAnt) .or. (BOW->BOW_DTDIGI >= dDatAnt .and. BOW->BOW_DTDIGI <= dData )
				lPermAlt := .F.
				If cAutomato != "lAutomato"
					Help( ,, 'Help',, 'Movimenta็ใo na BOW ' + cvaltochar(nI) + ' '/*"บ linha."*/, 1, 0 )
				EndIf
				Return(lPermAlt)				
			EndIf
			BOW->(DbSkip())
		EndDo

	EndIf	

	//Pesquiso movimenta็ใo no SIB		
	For I:= 1 to Len(aDadBCA)		
		aadd( aDadSib, { aDadBCA[I][1][1] } )
	Next
	
	If cAutomato != "lAutomato" 
		If MsgYesNo("Ao realizar a altera็ใo, as tabelas da Central de Obriga็๕es serใo atualizadas. Deseja prosseguir?")
			lContinua := .T.			
		EndIf
	Else
		lContinua := .T.
	EndIf

	If lContinua	
		If !PLSVLDHIST(cChave, aDadSib, dDatAnt,nLinhaAtual, cHoraLan)							
			lPermAlt := .F.
			If cAutomato != "lAutomato"
				Help( ,, 'Help',, 'Nใo ้ possivel alterar a data pois jแ houve movimenta็ใo no SIB '+ cvaltochar(nI) + ' '/*"บ linha."*/, 1, 0 )
			EndIf	
		EndIf
	ENdIf						

	If PLSALIASEXI("BH4") .AND. lContinua
		GrvAltHis(oModelB,dDatAnt,cMBloAnt)
	EndIf 

return lPermAlt

/*ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ_aDados()   บAutor  ณRoberto Barbosa   บ Data ณ  23/07/18บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Carrego a informa็ใo antes da altera็ใo em tela  		  บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function _aDados(oModelB)  
	Local oBCA
	Local aDados :=  {}
	Local lDad   := .T.
		
	oModelB := FWLoadModel( 'PLSA259' )		
	lDad := oModelB:Activate()		

	If lDad
		oBCA   := oModelB:GetModel('BCADETAIL')
		aDados := aClone(oBCA:aDataModel)
	EndIf
			
Return aDados

/*ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma   บAutor  ณRoberto Barbosa   บ Data ณ  08/08/18บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fun็ใo responsแvel por gravar hist๓rico de Altera็๕es 		บฑฑ
			   Na tabela BCA
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Static Function GrvAltHis(oModelB,dData,cMBloAnt)
	Local oBCA	  := oModelB:GetModel('BCADETAIL')
	Local oBA1	  := oModelB:GetModel('BA1MASTER')	
	Local dDatAtu := CTOD(" ") //Data ap๓s a altera็ใo
	Local cUsuOpe := UsrFullName(RetCodUsr()) 	
	Local cMatric := ""
	Local cDigito := ""
	Local cObs    := ""
	Local cLog    := ""
	Local cTipo   := ""	
	Local cTipReg := ""

	if oModelB <> nil
		
	dDatAtu := oBCA:GetValue("BCA_DATA")
	cMatric := oBCA:GetValue("BCA_MATRIC") + oBCA:GetValue("BCA_TIPREG")
	cDigito	:= oBA1:GetValue("BA1_DIGITO")
	cObs    := oBCA:GetValue("BCA_OBS")
	cTipo   := oBCA:GetValue("BCA_TIPO")
	cTipReg := oBCA:GetValue("BCA_TIPREG")
	
	DbSelectArea("BH4")

	BH4->(DbSetOrder(1))
	RecLock("BH4",.T.)	
		BH4->BH4_FILIAL := xFilial("BH4")
		BH4->BH4_MATRIC := cMatric + cDigito 
		BH4->BH4_DIGITO := cDigito
		BH4->BH4_DATA	:= Date() //Data da altera็ใo
		BH4->BH4_HORA	:= Time() //Hora da Altera็ใo
		BH4->BH4_DTANT	:= dData//Remover
		BH4->BH4_DTATU	:= dDatAtu
		BH4->BH4_MOTBLO := cMBloAnt
		BH4->BH4_OBS 	:= cObs
		BH4->BH4_USUOPE	:= cUsuOpe
		BH4->BH4_TIPO	:= cTipo
		BH4->BH4_TIPREG	:= cTipReg		
	BH4->(MsUnlock())	
		cLog += "Altera็๕es no Hist๓rico de Bloqueios gravado com sucesso!" + CRLF
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "Altera็ใo no Hist๓rico de bloqueio/desbloqueio gravado com sucesso!" + CRLF , 0, 0, {})

	EndIf
		
Return Nil