#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260FD1COB
Tela com campos para o preenchimento do Folder Cobrança BA3
@author DEV TOTVS
@since 05/08/19
@version P12
/*/
//-------------------------------------------------------------------
Function PLSA260FD1COB(lAutomato)
	
	Local oBrowse
	Default lAutomato := .F.

	oBrowse := FWmBrowse():New()
	oBrowse:SetAlias( 'BA3' )
	oBrowse:SetDescription( Fundesc() )	
	oBrowse:SetMenuDef( 'PLSA260FD1COB' )
	If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao de menu PLSA260FD1COB 
@author  DEV TOTVS
@version P12
@since   26/07/19
/*/          
//-------------------------------------------------------------------
Static Function MenuDef()

	Private aRotina := {}

Return aRotina    

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao do modelo MVC PLSA260FD1COB 
@author  DEV TOTVS
@version P12
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function ModelDef()	

	Local oModel
	Local oStruBA3 := FWFormStruct( 1, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','Cobranca') })
	Local oEvent   := PL260FD1EVDEF():New()

	BA3->(MsSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_CONEMP+BA1_VERCON+BA1_SUBCON+BA1_VERSUB)))
    // Cria o objeto do Modelo de Dados	 
	oModel := MPFormModel():New('PLSA260FD1COB')	
    
	oModel:addFields('BA3MASTER' , ,oStruBA3) 							
    oModel:SetDescription( FunDesc() )	
	oModel:GetModel( 'BA3MASTER' ):SetDescription( 'Cobrança Familia' )
	oModel:SetPrimaryKey({})

	oStruBA3:setProperty('BA3_COBNIV', MODEL_FIELD_WHEN,  { || .T.} )
	oStruBA3:setProperty('BA3_ENDCOB', MODEL_FIELD_VALID, { || PLSEndCobMVC(oModel)} )
	oStruBA3:setProperty('BA3_CODCLI', MODEL_FIELD_VALID, { || SA1->(ExistCpo("SA1",oModel:GetValue("BA3MASTER","BA3_CODCLI"),1)) } )
	oStruBA3:setProperty('BA3_CODCLI', MODEL_FIELD_WHEN,  { || PL260CFMvc(4,"C",oModel)} )
	oStruBA3:setProperty('BA3_CODFOR', MODEL_FIELD_WHEN,  { || PL260CFMvc(4,"F",oModel)} )
	oStruBA3:setProperty('BA3_VENCTO', MODEL_FIELD_VALID, { || Entre(01,31,oModel:GetValue("BA3MASTER","BA3_VENCTO")) .And. ;
						PLSA260Ven(BA3->BA3_CODINT,BA3->BA3_CODEMP,BA3->(BA3_CONEMP+BA3_VERCON),BA3->(BA3_SUBCON+BA3_VERSUB))} )
	oStruBA3:setProperty('BA3_VENCTO', MODEL_FIELD_WHEN,  { || oModel:GetValue("BA3MASTER","BA3_COBNIV") == "1" } )
		
	//Instala o evento padrão do programa.
    oModel:InstallEvent("PL260FD1EVDEF",/*cOwner*/,oEvent)

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Define o modelo de dados da aplicação 
@author  DEV TOTVS
@version P2
@since   26/07/19
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  

	Local oStruBA3 := FWFormStruct( 2, 'BA3'    , { |cCampo| PLS260CAMPOS(cCampo, 'BA3','Cobranca') })
	Local oModel   := FWLoadModel( 'PLSA260FD1COB' )
	Local oView

	oView := FWFormView():New()

	oView:SetModel( oModel )
    oView:AddField( 'VIEW_BA3' ,  oStruBA3,  'BA3MASTER' )

    oStruBA3:SetNoFolder()
	oView:CreateHorizontalBox( 'SUPERIOR' 	, 100) 
	oView:SetOwnerView('VIEW_BA3', 'SUPERIOR')

	oView:AddUserButton("Forma de Cobrança"     ,"", {|| PL260BTN(oModel,1)  },,,,.T./*lShowBar*/ )
	oView:AddUserButton("Taxa de Adesão"        ,"", {|| PL260BTN(oModel,2)  },,,,.T./*lShowBar*/)
	oView:AddUserButton("Gratuidade da Familia" ,"", {|| PL260BTN(oModel,3)  },,,,.T./*lShowBar*/)	
	oView:AddUserButton("Opcional"              ,"", {|| PL260BTN(oModel,4)  },,,,.T./*lShowBar*/)

	oView:EnableTitleView('VIEW_BA3','Cobrança Familia')
	
Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PL260BTN
Botões da tela
@author DEV TOTVS
@since 31/07/2019
@version P12
1 - Forma de cobrança 
2 - Taxa de Adesão
3 - Gratuidade da Familia
4 - Opcional
/*/
//-------------------------------------------------------------------
Function PL260BTN(oModel, nOpc)
	Local lAutomato := !IsInCallStack("PLSA124")
	Local oBA3    := oModel:GetModel("BA3MASTER")
	Local cMatric := oBA3:GetValue("BA3_CODINT") + oBA3:GetValue("BA3_CODEMP") +oBA3:GetValue("BA3_MATRIC") 

	Do Case
		Case nOpc = 1
			BJK->(dbSetorder(1))

			BJK->( MsSeek(xFilial("BJK") + cMatric ) )
			If(!lAutomato,FWExecView('Visualização','PLSA260BJK', MODEL_OPERATION_UPDATE,, { || .T. } ),)
			
		Case nOpc = 2
			BJL->(dbSetorder(1))

			BJL->( MsSeek(xFilial("BJL") + cMatric ) )
			If(!lAutomato,FWExecView('Visualização','PLSA260BJL', MODEL_OPERATION_UPDATE,, { || .T. } ),)
						
		Case nOpc = 3
			BH5->(dbSetorder(1))

			BH5->( MsSeek(xFilial("BH5") + cMatric ) )								
			If(!lAutomato,FWExecView('Visualização','PLSA260BH5', MODEL_OPERATION_UPDATE,, { || .T. } ),)
			
		Case nOpc = 4
			BF1->(dbSetorder(1))

			BF1->( MsSeek(xFilial("BF1") + cMatric ) )
			If(!lAutomato,FWExecView('Visualização','PLS260BF1MVC', MODEL_OPERATION_UPDATE,, { || .T. } ),)
			
	End case

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSEndCobMVC
Preenche o endereco da familia, caso o endereco de cobranca
seja para o titular,cliente, responsavel da familia 
@author DEV TOTVS
@since 26/08/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PLSEndCobMVC(oModel)

	Local cTipUsu  := SuperGetMv("MV_PLCDTIT")
	Local ba3Num   := ""
	Local cEndCob  := oModel:GetValue( 'BA3MASTER', 'BA3_ENDCOB')
	Local cCobNiv  := oModel:GetValue( 'BA3MASTER', 'BA3_COBNIV')
	Local aAreaBA1 := BA1->(GetArea())

	//Analiso se ja existe algum dado na acols do usuario
	If cEndCob == "2" .AND. cCobNiv == '1'
		BA1->(DBSetOrder(1))
		If BA1->(MsSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
			While !BA1->(EOF()) .AND. BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC) 			
				//Verifico se o Tipo do Usuario do a acols e o titular			
				If AllTrim(BA1->BA1_TIPUSU) == AllTrim(cTipUsu)
					SA1->(DBSetOrder(1))
					If SA1->(MsSeek(xFilial("SA1")+BA3->BA3_CODCLI+BA3->BA3_LOJA))
					//Gravo na base o endereco do titular para a familia
						oModel:LoadValue( 'BA3MASTER', 'BA3_CEP'   ,BA1->BA1_CEPUSR )
						oModel:LoadValue( 'BA3MASTER', 'BA3_END'   ,BA1->BA1_ENDERE )
						oModel:LoadValue( 'BA3MASTER', 'BA3_NUMERO',BA1->BA1_NR_END )
						oModel:LoadValue( 'BA3MASTER', 'BA3_COMPLE',BA1->BA1_COMEND )
						oModel:LoadValue( 'BA3MASTER', 'BA3_BAIRRO',BA1->BA1_BAIRRO )
						oModel:LoadValue( 'BA3MASTER', 'BA3_CODMUN',BA1->BA1_CODMUN )
						oModel:LoadValue( 'BA3MASTER', 'BA3_MUN'   ,BA1->BA1_MUNICI )
						oModel:LoadValue( 'BA3MASTER', 'BA3_ESTADO',BA1->BA1_ESTADO )							
					Endif
				Endif
				BA1->(DbSkip())
			Enddo
		EndIF

	Elseif cEndCob == "3" .AND. cCobNiv == '1'// Responsável Familia					
		BA1->(DBSetOrder(1))
		If BA1->(MsSeek(xFilial("BA1")+BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)))
			While !BA1->(EOF()) .AND. BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC) == BA3->(BA3_CODINT+BA3_CODEMP+BA3_MATRIC)
				
				If (BA1->BA1_RESFAM == '1' .AND. Empty(BA1->BA1_DATBLO)) .OR. ;
					(Empty(BA1->BA1_RESFAM) .AND. AllTrim(BA1->BA1_TIPUSU) == AllTrim(cTipUsu))
						// Atualiza o endereco do dependente utilizando o endereco do responsável.
						oModel:LoadValue( 'BA3MASTER', 'BA3_CEP'   ,BA1->BA1_CEPUSR )
						oModel:LoadValue( 'BA3MASTER', 'BA3_END'   ,BA1->BA1_ENDERE )
						oModel:LoadValue( 'BA3MASTER', 'BA3_NUMERO',BA1->BA1_NR_END )
						oModel:LoadValue( 'BA3MASTER', 'BA3_COMPLE',BA1->BA1_COMEND )
						oModel:LoadValue( 'BA3MASTER', 'BA3_BAIRRO',BA1->BA1_BAIRRO )
						oModel:LoadValue( 'BA3MASTER', 'BA3_CODMUN',BA1->BA1_CODMUN )
						oModel:LoadValue( 'BA3MASTER', 'BA3_MUN'   ,BA1->BA1_MUNICI )
						oModel:LoadValue( 'BA3MASTER', 'BA3_ESTADO',BA1->BA1_ESTADO )	
				EndIF
				BA1->(DbSkip())
			Enddo

		EndIF
			
	Elseif cEndCob == "1" .AND. cCobNiv == '1'
		SA1->( dbSetorder(01) )
		If SA1->( msSeek(xFilial("SA1")+oModel:GetValue('BA3MASTER', 'BA3_CODCLI')+oModel:GetValue('BA3MASTER', 'BA3_LOJA')) )
			oModel:LoadValue('BA3MASTER', 'BA3_CEP',Alltrim(SA1->A1_CEP))
			oModel:LoadValue('BA3MASTER', 'BA3_END',Alltrim(SA1->A1_END))
			oModel:LoadValue('BA3MASTER', 'BA3_BAIRRO',Alltrim(SA1->A1_BAIRRO))		
			If AT( ",", SA1->A1_END)
				ba3Num := StrTokArr(SA1->A1_END, ",")
				oModel:LoadValue( 'BA3MASTER', 'BA3_END',ba3Num[1])
				oModel:LoadValue( 'BA3MASTER', 'BA3_NUMERO',Alltrim(ba3Num[2]))
			Endif
			oModel:LoadValue( 'BA3MASTER', 'BA3_COMPLE',Alltrim(SA1->A1_COMPLEM))
			BID->(dbSetorder(02))
			If BID->( msSeek(xFilial("BID")+Alltrim(Upper(SA1->A1_MUN))))
				oModel:LoadValue('BA3MASTER', 'BA3_CODMUN',BID->BID_CODMUN)
				oModel:LoadValue('BA3MASTER', 'BA3_MUN',BID->BID_DESCRI)
				oModel:LoadValue('BA3MASTER', 'BA3_ESTADO',BID->BID_EST)
			Endif	
		Endif
	Endif
	RestArea(aAreaBA1)

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PL260CFMvc
When dos campos Cliente/Fornecedor...
cTipo := F - Fornecedor, C - Cliente
nNum  := 4 - Familia , 5 - Usuario
@author DEV TOTVS
@since 11/09/2019
@version P12
/*/
//-------------------------------------------------------------------
Function PL260CFMvc(nNum,cTipo,oModel)

	Local cCobNiv := oModel:GetValue("BA3MASTER", "BA3_COBNIV") 
	Local cCodCli := oModel:GetValue("BA3MASTER", "BA3_CODCLI") 
	Local cCodFor := oModel:GetValue("BA3MASTER", "BA3_CODFOR")
	Local lFlag   := .T.

	if nNum == 4
		if cCobNiv == "1"
			if(cTipo == "F",lFlag := Empty(cCodCli),lFlag := Empty(cCodFor))
		Endif
	Endif

Return(lFlag)