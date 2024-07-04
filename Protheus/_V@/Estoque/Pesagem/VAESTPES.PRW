#INCLUDE 'PROTHEUS.CH'
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#include "TOPCONN.CH"
#include "RWMAKE.CH"
#Include "TryException.ch"
#include "fwmvcdef.ch"

Static cTitulo := "Cadastro de Peso do Balanção"
Static aParBal      := nil      // -- Será inicializada na funcao no Activate do Model (Devido a Error log se executado em MDI )--/

#DEFINE oFBar      TFont():New( "Courier New"/*cName*/, /*uPar2*/, -04/*nHeight*/, /*uPar4*/, .F./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFTitLabel TFont():New( "Courier New"/*cName*/, /*uPar2*/, -16/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFLabel    TFont():New( "Courier New"/*cName*/, /*uPar2*/, -08/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfo     TFont():New( "Arial"      /*cName*/, /*uPar2*/, -12/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFInfoOBS  TFont():New( "Arial"      /*cName*/, /*uPar2*/, -09/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )
#DEFINE oFontRecor TFont():New( "Tahoma"     /*cName*/, /*uPar2*/, -07/*nHeight*/, /*uPar4*/, .T./*lBold*/, /*uPar6*/, /*uPar7*/, /*uPar8*/, /*uPar9*/, .F./*lUnderline*/, .F./*lItalic*/ )

User Function VAESTPES()
    Local aArea   		:= FwGetArea()
    Local oBrowse  		:= NIL
	Local cFunBkp 		:= FunName()  
    
	Private oMBSaveLog	:= MBSaveLog():New() as object
    Private cF3CodCFPes  := ""
    Private cF3LojCFPes  := ""
    Private cF3NomCFPes  := ""
    Private cPlacaTGet   := Iif(ValType(cPlacaTGet)=="U", CriaVar( 'DA3_PLACA' , .F.), cPlacaTGet )
    Private nQualPesagem := 0
    
    SetFunName("VAESTPES")
	
    oBrowse := FWMBrowse():New()
	oBrowse:SetAlias( "ZPB" )
	oBrowse:SetDescription( cTitulo )
	
	oBrowse:AddLegend( "ZPB->ZPB_STATUS <> 'F'", "GREEN" , "Aberto" )
    oBrowse:AddLegend( "ZPB->ZPB_STATUS == 'F'", "RED"   , "Finalizada" )
	
	oBrowse:Activate()
	
    SetFunName(cFunBkp)
	FwRestArea(aArea)
Return 

Static Function MenuDef()
	Local aRot := {}
	
	ADD OPTION aRot TITLE 'Pesagens'    	ACTION 'U_Tela1Pesagem' 			OPERATION MODEL_OPERATION_INSERT ACCESS 0 //OPERATION 3
	ADD OPTION aRot TITLE 'Alterar'    		ACTION 'U_Tela2Pesagem' 			OPERATION MODEL_OPERATION_UPDATE ACCESS 0 //OPERATION 4
	ADD OPTION aRot TITLE 'Visualizar' 		ACTION 'VIEWDEF.VAESTPES' 			OPERATION MODEL_OPERATION_VIEW   ACCESS 0 //OPERATION 1
	ADD OPTION aRot TITLE 'Excluir'    		ACTION 'VIEWDEF.VAESTPES' 			OPERATION MODEL_OPERATION_DELETE ACCESS 0 //OPERATION 5
	ADD OPTION aRot TITLE 'Legenda'    		ACTION 'U_LegPesagem'      			OPERATION  6 ACCESS 0 //OPERATION X
	ADD OPTION aRot TITLE 'Imprimir Ticket' ACTION 'U_PPeso2'      				OPERATION  7 ACCESS 0 //OPERATION X

Return aRot
User Function LegPesagem()
	Local aLegenda := {}

    //Monta as cores
    AAdd(aLegenda, {"BR_VERDE"		, "Aberto"  })
    AAdd(aLegenda, {"BR_VERMELHO"	, "Pesagem Finalizada"})

    BrwLegenda("Transferências", "Procedencia", aLegenda, 30)
Return

Static Function ModelDef()
	Local oModel   	:= Nil
	Local oStr1   	:= FWFormStruct(1, 'ZPB',{|cCampo| AllTrim(cCampo) $ "ZPB_FILIAL|ZPB_PLACA|ZPB_CODIGO|ZPB_STATUS" }) 
	Local oStr2   	:= FWFormStruct(1, 'ZPB',{|cCampo| AllTrim(cCampo) $ "ZPB_CPFMOT|ZPB_CODMOT|ZPB_NOMMOT|ZPB_CLIFOR|ZPB_CODFOR|ZPB_LOJFOR|ZPB_NOMFOR" }) 
	Local oStr3   	:= FWFormStruct(1, 'ZPB',{|cCampo| AllTrim(cCampo) $ "ZPB_OPESOE|ZPB_PESOE|ZPB_DATA|ZPB_HORA|ZPB_PEMAN1|ZPB_USRP1"}) 
	Local oStr4   	:= FWFormStruct(1, 'ZPB',{|cCampo| AllTrim(cCampo) $ "ZPB_OPESOS|ZPB_PESOS|ZPB_DATAF|ZPB_HORAF|ZPB_PEMAN2|ZPB_USRP2|ZPB_PESOL" }) 
	Local oStr5   	:= FWFormStruct(1, 'ZPB',{|cCampo| AllTrim(cCampo) $ "ZPB_NOTAFI|ZPB_NOTFIS|ZPB_PRODUT|ZPB_DESC|ZPB_BAIA|ZPB_LOCAL|ZPB_OBSERV|ZPB_NROGTA|ZPB_QTANIM" }) 
	Local bVldCom  	:= {|| u_zSaveZPB()	}
	
	//Criando o FormModel, adicionando o CabeÃ§alho e Grid
	oModel := MPFormModel():New("ESTPESV",/* bVldPre */, /* bVldPos */ /*Pos-Validacao*/, bVldCom /*Commit*/,/*Cancel*/)

	oModel:AddFields("ZPB_1",/*cOwner*/ ,oStr1  )
	oModel:AddFields("ZPB_2","ZPB_1" 	   ,oStr2  )
	oModel:AddFields("ZPB_3","ZPB_1" 	   ,oStr3  )
	oModel:AddFields("ZPB_4","ZPB_1" 	   ,oStr4  )
	oModel:AddFields("ZPB_5","ZPB_1" 	   ,oStr5  )

	oModel:SetPrimaryKey({ })

	//Setando outras informaÃ§Ãµes do Modelo de Dados
	oModel:SetDescription(cTitulo)
	oModel:GetModel("ZPB_1"):SetDescription("Dados da "+cTitulo)
	oModel:GetModel("ZPB_2"):SetDescription("Dados da "+cTitulo)
	oModel:GetModel("ZPB_3"):SetDescription("Dados da "+cTitulo)
	oModel:GetModel("ZPB_4"):SetDescription("Dados da "+cTitulo)
	oModel:GetModel("ZPB_5"):SetDescription("Dados da "+cTitulo)
	
Return oModel

Static Function ViewDef()
	Local oModel     	:= FWLoadModel("VAESTPES")
	Local oStr1   		:= FWFormStruct(2, 'ZPB',{|cCampo| AllTrim(cCampo) $ "ZPB_FILIAL|ZPB_PLACA|ZPB_CODIGO|ZPB_STATUS" }) 
	Local oStr2   		:= FWFormStruct(2, 'ZPB',{|cCampo| AllTrim(cCampo) $ "ZPB_CPFMOT|ZPB_CODMOT|ZPB_NOMMOT|ZPB_CLIFOR|ZPB_CODFOR|ZPB_LOJFOR|ZPB_NOMFOR" }) 
	Local oStr3   		:= FWFormStruct(2, 'ZPB',{|cCampo| AllTrim(cCampo) $ "ZPB_OPESOE|ZPB_PESOE|ZPB_DATA|ZPB_HORA|ZPB_PEMAN1|ZPB_USRP1"}) 
	Local oStr4   		:= FWFormStruct(2, 'ZPB',{|cCampo| AllTrim(cCampo) $ "ZPB_OPESOS|ZPB_PESOS|ZPB_DATAF|ZPB_HORAF|ZPB_PEMAN2|ZPB_USRP2|ZPB_PESOL" }) 
	Local oStr5   		:= FWFormStruct(2, 'ZPB',{|cCampo| AllTrim(cCampo) $ "ZPB_NOTAFI|ZPB_NOTFIS|ZPB_PRODUT|ZPB_DESC|ZPB_BAIA|ZPB_LOCAL|ZPB_OBSERV|ZPB_NROGTA|ZPB_QTANIM" }) 
	Local nI 		
	Local aAux		:= {}
	Local aAuxC 	:= {}
	Local oView     := NIL

	aAux    := oStr4:GetFields()
	aAuxC	:= aClone(aAux)
	For nI := 1 to Len(aAuxC)
		if aAuxC[nI,1] == "ZPB_DATA" .OR. aAuxC[nI,1] == "ZPB_HORA" 
			oStr4:RemoveField(aAuxC[nI,1])
		endif
	Next

	oView     := FWFormView():New()
    //oModel :=
	oView:SetModel(oModel)

	oView:AddField("VIEW_1" , oStr1  , "ZPB_1")
	oView:AddField("VIEW_2" , oStr2  , "ZPB_2")
	oView:AddField("VIEW_3" , oStr3  , "ZPB_3")
	oView:AddField("VIEW_4" , oStr4  , "ZPB_4")
	oView:AddField("VIEW_5" , oStr5  , "ZPB_5")

	//Setando o dimensionamento de tamanho
	oView:CreateHorizontalBox('CAB_1', 12)
	oView:CreateHorizontalBox('CAB_2', 22)
	oView:CreateHorizontalBox('CAB_3', 22)
	oView:CreateHorizontalBox('CAB_4', 22)
	oView:CreateHorizontalBox('CAB_5', 22)

	oView:AddOtherObject("BTNPESO1",{|o1Panel,o1OtherObject| CriaBt1(o1Panel,o1OtherObject)})
	oView:AddOtherObject("BTNPESO2",{|o2Panel,o2OtherObject| CriaBt2(o2Panel,o2OtherObject)})

	oView:CreateVerticalBox('PESAR1'	, 10 , 'CAB_3' )
	oView:CreateVerticalBox('PESAGEM1'	, 90 , 'CAB_3' )
	oView:CreateVerticalBox('PESAR2'	, 10 , 'CAB_4' )
	oView:CreateVerticalBox('PESAGEM2'	, 90 , 'CAB_4' )

	//Amarrando a view com as box
	oView:SetOwnerView('VIEW_1'  	,'CAB_1'	)
	oView:SetOwnerView('VIEW_2'  	,'CAB_2'	)
	oView:SetOwnerView('BTNPESO1'  	,'PESAR1'	)
	oView:SetOwnerView('VIEW_3'  	,'PESAGEM1'	)
	oView:SetOwnerView('BTNPESO2'  	,'PESAR2'	)
	oView:SetOwnerView('VIEW_4'  	,'PESAGEM2'	)
	oView:SetOwnerView('VIEW_5'  	,'CAB_5'	)

    oView:EnableTitleView('VIEW_1'	, 'Dados da Pesagem' 		) 
    oView:EnableTitleView('VIEW_2'	, 'Fornecedor / Motorista'	) 
    oView:EnableTitleView('BTNPESO1', '1º Pesagem' 				) 
    oView:EnableTitleView('VIEW_4'	, '|'						) 
    oView:EnableTitleView('BTNPESO2', '2º Pesagem' 				) 
    oView:EnableTitleView('VIEW_3'	, '|'						) 
    oView:EnableTitleView('VIEW_5'	, 'Nota Fiscal / GTA' 		) 

    SetKey( VK_F11, { || U_PPeso1() } )

Return oView
User Function zSaveZPB()
	Local aArea      	:= GetArea()
	Local lRet       	:= .T.
	Local oModel	  	:= FWModelActive()
	Local oMdl1 		:= oModel:GetModel('ZPB_1')
	Local oMdl2 		:= oModel:GetModel('ZPB_2')
	Local oMdl3 		:= oModel:GetModel('ZPB_3')
	Local oMdl4 		:= oModel:GetModel('ZPB_4')
	Local oMdl5 		:= oModel:GetModel('ZPB_5')
	Local nOpc       	:= oModel:GetOperation()
	Local lRecLock   	:= .T.

	DbSelectArea('ZPB')
	ZPB->(DbSetOrder(1))  //ZPB_FILIAL+DTOS(ZPB_DATA)+ZPB_CODIGO
	
	//Se for InclusÃ£o
	If nOpc == MODEL_OPERATION_INSERT .OR. nOpc == MODEL_OPERATION_UPDATE

		RecLock('ZPB', lRecLock := !DbSeek( FwXFilial("ZPB") +;
									dToS(oMdl3:GetValue('ZPB_DATA'))+;
									oMdl1:GetValue('ZPB_CODIGO') ))

			ZPB->ZPB_FILIAL	:= FwXFilial("ZPB")
			ZPB->ZPB_CODIGO	:= oMdl1:GetValue("ZPB_CODIGO")
			ZPB->ZPB_PLACA 	:= oMdl1:GetValue("ZPB_PLACA")
			
			if  oMdl4:GetValue("ZPB_PESOS") > 0 
				ZPB->ZPB_STATUS	:= "F"
			else 
				ZPB->ZPB_STATUS	:= oMdl1:GetValue("ZPB_STATUS")
			endif 
			
			ZPB->ZPB_CPFMOT	:= oMdl2:GetValue("ZPB_CPFMOT")
			ZPB->ZPB_CODMOT	:= oMdl2:GetValue("ZPB_CODMOT")
			ZPB->ZPB_NOMMOT	:= oMdl2:GetValue("ZPB_NOMMOT")
			ZPB->ZPB_CLIFOR	:= oMdl2:GetValue("ZPB_CLIFOR")
			ZPB->ZPB_CODFOR	:= oMdl2:GetValue("ZPB_CODFOR")
			ZPB->ZPB_LOJFOR	:= oMdl2:GetValue("ZPB_LOJFOR")
			ZPB->ZPB_NOMFOR	:= oMdl2:GetValue("ZPB_NOMFOR")

			ZPB->ZPB_PEMAN1	:= oMdl3:GetValue("ZPB_PEMAN1")
			ZPB->ZPB_USRP1 	:= oMdl3:GetValue("ZPB_USRP1")

			IF ZPB->ZPB_OPESOE != oMdl3:GetValue("ZPB_PESOE")
				ZPB->ZPB_OPESOE	:= oMdl3:GetValue("ZPB_PESOE")
			ENDIF 

			ZPB->ZPB_PESOE 	:= oMdl3:GetValue("ZPB_PESOE")
			ZPB->ZPB_DATA  	:= oMdl3:GetValue("ZPB_DATA")
			ZPB->ZPB_HORA  	:= oMdl3:GetValue("ZPB_HORA")

			IF ZPB->ZPB_OPESOS != oMdl4:GetValue("ZPB_PESOS")
				ZPB->ZPB_OPESOS	:= oMdl4:GetValue("ZPB_PESOS")
			ENDIF 

			ZPB->ZPB_PESOS 	:= oMdl4:GetValue("ZPB_PESOS")
			ZPB->ZPB_DATAF 	:= oMdl4:GetValue("ZPB_DATAF")
			ZPB->ZPB_HORAF 	:= oMdl4:GetValue("ZPB_HORAF")
			ZPB->ZPB_PESOL 	:= oMdl4:GetValue("ZPB_PESOL")
			ZPB->ZPB_PEMAN2	:= oMdl4:GetValue("ZPB_PEMAN2")
			ZPB->ZPB_USRP2 	:= oMdl4:GetValue("ZPB_USRP2")

			ZPB->ZPB_LOCAL 	:= oMdl5:GetValue("ZPB_LOCAL")
			ZPB->ZPB_OBSERV	:= oMdl5:GetValue("ZPB_OBSERV")
			ZPB->ZPB_NROGTA	:= oMdl5:GetValue("ZPB_NROGTA")
			ZPB->ZPB_QTANIM	:= oMdl5:GetValue("ZPB_QTANIM")
			ZPB->ZPB_NOTFIS	:= oMdl5:GetValue("ZPB_NOTFIS")
			ZPB->ZPB_PRODUT	:= oMdl5:GetValue("ZPB_PRODUT")
			ZPB->ZPB_DESC  	:= oMdl5:GetValue("ZPB_DESC")
			ZPB->ZPB_BAIA  	:= oMdl5:GetValue("ZPB_BAIA")
		ZPB->(MsUnlock())
	//Se for ExclusÃ£o
	ElseIf nOpc == MODEL_OPERATION_DELETE

		//Se conseguir posicionar, exclui o regist
		If ZPB->(DbSeek( FwXFilial("ZPB") +;
						dToS(oMdl3:GetValue('ZPB_DATA'))+;
						oMdl1:GetValue('ZPB_CODIGO') ))


			RecLock('ZPB', .F.)
				ZPB->(DbDelete())
			ZPB->(MsUnlock())
		EndIf
	EndIf

	//Se nÃ£o for inclusÃ£o, volta o INCLUI para .T. (bug ao utilizar a ExclusÃ£o, antes da InclusÃ£o)
	If nOpc != MODEL_OPERATION_INSERT
		INCLUI := .T.
	EndIf

	RestArea(aArea)
Return lRet

User Function ESTPESV()
	Local aParam 		:= PARAMIXB
	Local lRet 			:= .T.
	Local cIdPonto 		:= ''
	Local cIdModel 		:= ''
	Local cIdIXB5		:= ''
	Local cIdIXB4		:= ''
	Local oModel 	 	:= nil
	Local oMdl1 	 	:= nil
	Local oStr1			:= nil
	Local oStr2			:= nil
	Local oStr3			:= nil
	Local oStr4			:= nil
	Local oStr5			:= nil
	Local nOper      	:= 0
	Local _aMotorista	:= {}
	
	If aParam <> NIL
		oModel 	 := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]

		if len(aParam) >= 4
			cIdIXB4  := aParam[4]
		endif 

		if len(aParam) >= 5
			cIdIXB5  := aParam[5]
		endif 
		
		if cIdPonto == "MODELVLDACTIVE"
			nOper := oModel:nOperation

			//Se for inclusão, define o ini padrão
			If nOper == 3 .or. nOper == 4
				oStr1 := oModel:GetModel( 'ZPB_1' ):GetStruct()
				oStr2 := oModel:GetModel( 'ZPB_2' ):GetStruct()
				oStr3 := oModel:GetModel( 'ZPB_3' ):GetStruct()
				oStr4 := oModel:GetModel( 'ZPB_4' ):GetStruct()
				oStr5 := oModel:GetModel( 'ZPB_5' ):GetStruct()
				If (nQualPesagem==0)
					oStr1:SetProperty( 'ZPB_PLACA', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "'"+cPlacaTGet+"'" ) )
					//oMdl1:GetValue("ZPB_PLACA") := cPlacaTGet
					_aMotorista  := UltPesagemXPlaca(cPlacaTGet)
					If (!Empty(_aMotorista)) // preenchimento de campos automaticamente de acordo com a ultima pesagem do caminhao
						oStr2:SetProperty( 'ZPB_CODMOT', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "'"+_aMotorista[01, 01]+"'" ) )
						oStr2:SetProperty( 'ZPB_CPFMOT', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "'"+_aMotorista[01, 02]+"'" ) )
						oStr2:SetProperty( 'ZPB_NOMMOT', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "'"+_aMotorista[01, 03]+"'" ) )
						oStr5:SetProperty( 'ZPB_PRODUT', MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "'"+_aMotorista[01, 04]+"'" ) )
						oStr5:SetProperty( 'ZPB_DESC'  , MODEL_FIELD_INIT, FwBuildFeature( STRUCT_FEATURE_INIPAD, "'"+_aMotorista[01, 05]+"'" ) )
					EndIf
				EndIf
			endif 			
		elseif Alltrim(cIdPonto) == 'MODELPOS' 
			nOper := oModel:nOperation
			if nOper == 3 .or. nOper == 4
				oMdl1 := oModel:GetModel( 'ZPB_1' )
				oMdl2 := oModel:GetModel( 'ZPB_2' )
				oMdl3 := oModel:GetModel( 'ZPB_3' )
				oMdl4 := oModel:GetModel( 'ZPB_4' )
				oMdl5 := oModel:GetModel( 'ZPB_5' )
				
				if Empty(oMdl2:GetValue("ZPB_NOMMOT"))
					oModel:SetErrorMessage("","","","","HELP", 'Campo Obrigatório', "Preencha o Campo Motorista. [ABA 02]")
					lRet := .F.
				elseif Empty(oMdl2:GetValue("ZPB_CLIFOR"))
					oModel:SetErrorMessage("","","","","HELP", 'Campo Obrigatório', "Preencha o Campo Cli/For. [ABA 02]")
					lRet := .F.
				elseif Empty(oMdl2:GetValue("ZPB_CODFOR"))
					oModel:SetErrorMessage("","","","","HELP", 'Campo Obrigatório', "Preencha o Campo Nome Cli/For. [ABA 02]!")
					lRet := .F.
				elseif Empty(oMdl3:GetValue("ZPB_PESOE" ))
					oModel:SetErrorMessage("","","","","HELP", 'Campo Obrigatório', "Preencha o Campo Peso de entrada. [ABA 03]")
					lRet := .F.
				elseif (oMdl3:GetValue("ZPB_PESOE" ) > 0 .and. oMdl4:GetValue("ZPB_PESOS" ) > 0 ) .and. Empty(oMdl4:GetValue("ZPB_PESOL" ))
					oModel:SetErrorMessage("","","","","HELP", 'Campo Obrigatório', "Preencha o Campo Peso Liquido. [ABA 04]")
					lRet := .F.
				elseif Empty(oMdl5:GetValue("ZPB_NOTFIS"))
					oModel:SetErrorMessage("","","","","HELP", 'Campo Obrigatório', "Preencha o Campo Nota Fiscal. [ABA 05]")
					lRet := .F.
				elseif Empty(oMdl5:GetValue("ZPB_DESC"  ))
					oModel:SetErrorMessage("","","","","HELP", 'Campo Obrigatório', "Preencha o Campo Produto. [ABA 05]")
					lRet := .F.
				end

				//Static Function VldPesagem()
				If AllTrim(oMdl5:GetValue("ZPB_PRODUT")) $ GetMV("MB_PSGARM",,"030001,020023,020017") // os produtos configurados obrigam o preenchimento do campo armazem;
					// se VAZIO entao nao continuar o processo
					If Empty(oMdl5:GetValue("ZPB_LOCAL"))
						oModel:SetErrorMessage("","","","","HELP", 'Campo Obrigatório', "Para o produto selecionado é preciso informar o campo armazem.  [ABA 05] ")
						lRet := .F.
					EndIf
				EndIf

				//Static Function VldPesagem()
				//If !Empty(oMdl5:GetValue("ZPB_NROGTA")) .AND. Empty(oMdl5:GetValue("ZPB_QTANIM"))
				//	Alert("O campo de quant. de animal [ZPB_QTANIM] não foi informado. O mesmo é obrigatório" + CRLF +;
				//		"Esta operacao foi cancelada.")
				//	Return .F.
				//EndIf

			endif 			
		endif 			
	endif 
Return lRet 
User Function PegaPeso( lGravPeso, nBalanca )
	Local aArea         := GetArea()
	Local oModel 		:= FwModelActivate()
	Local oMdl1 		:= oModel:GetModel("ZPB_1")
	Local oMdl3 		:= oModel:GetModel("ZPB_3")
	Local oMdl4 		:= oModel:GetModel("ZPB_4")
	Local oView 		:= FWViewActive()
	Local nPeso 		:= 0
	Local nPeso1      	:= oMdl3:GetValue("ZPB_PESOE")
	Local nPeso2      	:= oMdl4:GetValue("ZPB_PESOS")
	Local lPesagManu	:= .f.
	
	if nBalanca == 1
		cBalanca := '000002' // CRIAR PARAMETRO PARA DX6_CODBAL
		nOpcA := 1
		
		if nPeso1 > 0 .and. !MsgYesNo('Peso de entrada do caminhão preenchido, deseja informar o peso do caminhão novamente?')
			lGravPeso := .F. 
		endif
	else
		if nPeso1 == 0
			MsgAlert("Informe o peso de entrada antes do peso de Saida!")
			lGravPeso := .F. 
		else 
			cBalanca := '000002' // CRIAR PARAMETRO PARA DX6_CODBAL
			nOpcA := 2
			
			if nPeso2 > 0 .and. !MsgYesNo('Peso de saida do caminhão preenchido, deseja informar o peso do caminhão novamente?')
				lGravPeso := .F. 
			endif
		endif 
	endif
	
	if lGravPeso .and. (INCLUI .or. ALTERA)

		IF aParBal == nIl     // Para Ser Inicializado Somente Qdo ainda não foi
			aParBal := AGRX003E( .f., 'OGA050001', cBalanca )
		EndIF

		AGRX003A( @nPeso, .t.,aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2, nOpcA )
		
		if nPeso > 0
			//if Empty(oSZJGtDad:aCols[nLinha,nPZJTARA]) // verificar linha que esta posicionado e ver se a primeira pesagem já está preenchida //oSZJGtDad:aCols[nPos,nPZJQTEMB]
			if nOpcA == 1 // verificar linha que esta posicionado e ver se a primeira pesagem já está preenchida //oSZJGtDad:aCols[nPos,nPZJQTEMB]
				//M->ZPB_OPESOE := nPeso
				if oMdl3:GetValue("ZPB_PESOE") > 0
			    	MBSaveLog():FULLWrite(, .F., "PegaPeso Entrada / Placa: - "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) +;
												" - Peso Anterior: " + AllTrim( cValToChar(oMdl3:GetValue("ZPB_PESOE")) )+;
												" - Tipo: " + iif(oMdl3:GetValue("ZPB_PEMAN1")== 'M' ,"Manual","Automatica")+;
												" - Usuario: " + oMdl3:GetValue("ZPB_USRP1"))
				endif

				MBSaveLog():FULLWrite(, .F., "PegaPeso Entrada / Placa: "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) +;
										     " - Peso Capturado: " + AllTrim( cValToChar(nPeso) )+;
										     " - Tipo: " + iif(lPesagManu,"Manual","Automatica")+;
										     " - Usuario: " + UsrFullName( ))

				oMdl1:LoadValue("ZPB_PLACA" 	, "")
				oMdl1:LoadValue("ZPB_PLACA" 	, cPlacaTGet)
				
				oMdl3:SetValue("ZPB_HORA" 	, Time())
				oMdl3:SetValue("ZPB_PESOE" 	, nPeso )
				oMdl4:SetValue("ZPB_PESOL" 	, ABS(nPeso - iIf(ValType(oMdl4:GetValue("ZPB_PESOS"))=="U", 0, oMdl4:GetValue("ZPB_PESOS"))))
				oMdl3:SetValue("ZPB_PEMAN1" , iif(lPesagManu,"M","A") )
				oMdl3:SetValue("ZPB_USRP1" 	, UsrFullName( ))
				oView:lModify := .T.

			elseif nOpcA == 2
				if oMdl4:GetValue("ZPB_PESOS") > 0
					MBSaveLog():FULLWrite(, .F., "PegaPeso Saida / Placa: - "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) +;
												" - Peso Anterior: " + AllTrim( cValToChar(oMdl4:GetValue("ZPB_PESOS")) )+;
												" - Tipo: " + iif(oMdl4:GetValue("ZPB_PEMAN2")== 'M' ,"Manual","Automatica")+;
												" - Usuario: " + oMdl4:GetValue("ZPB_USRP2"))
				endif

				MBSaveLog():FULLWrite(, .F., "PegaPeso Saida / Placa: "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) +;
										     " - Peso Capturado: " + AllTrim( cValToChar(nPeso) )+;
										     " - Tipo: " + iif(lPesagManu,"Manual","Automatica")+;
										     " - Usuario: " + UsrFullName( ))
				
				oMdl1:LoadValue("ZPB_PLACA" 	, "")
				oMdl1:LoadValue("ZPB_PLACA" 	, cPlacaTGet)

				oMdl4:SetValue("ZPB_DATAF"	, Date())
				oMdl4:SetValue("ZPB_HORAF"	, Time())
				oMdl4:SetValue("ZPB_PESOS"	, nPeso )
				oMdl4:SetValue("ZPB_PESOL"	, ABS(nPeso - iIf(ValType(oMdl3:GetValue("ZPB_PESOE"))=="U", 0, oMdl3:GetValue("ZPB_PESOE"))))
				oMdl4:SetValue("ZPB_PEMAN2" , iif(lPesagManu,"M","A") )
				oMdl4:SetValue("ZPB_USRP2" 	, UsrFullName( ))
				oView:lModify := .T.
			else
				MsgAlert("Linha posicionada já possui os dois pesos preenchidos.")
			endif
		endif
	endif

	if lGravPeso
		if oModel:VldData()
			if oModel:CommitData() 
				MBSaveLog():FULLWrite(, .F., "PegaPeso COMMIT / Placa: "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) )
			endif
		endif
	endif

	oView:Refresh()
	RestArea(aArea)
Return nPeso

User Function ReLoadLiquido()
	Local oModel 	:= FwModelActivate()
	Local oMdl3 	:= oModel:GetModel("ZPB_3")
	Local oMdl4 	:= oModel:GetModel("ZPB_4")
	Local nValor 	:= 0

	nValor := oMdl4:GetValue("ZPB_PESOL") := ABS(oMdl3:GetValue("ZPB_PESOE")  -  oMdl4:GetValue("ZPB_PESOS"))

Return nValor

User Function ZADSalvar(lAuto)
    Local aAreaZPB  := ZPB->(GetArea())
    Local lRecLock  := nQualPesagem == 0 // .T.
	Local oModel 	:= FwModelActivate()
	Local oMdl1 	:= oModel:GetModel("ZPB_1")
	Local oMdl3 	:= oModel:GetModel("ZPB_3")
	Local oMdl4 	:= oModel:GetModel("ZPB_4")
    Local cChave    := ""

    Default lAuto  := .T.

    MBSaveLog():FULLWrite(, .F., "ZADSALVAR Manual: Placa - "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) + " Peso - "   + AllTrim( cValToChar(oMdl3:GetValue("ZPB_PESOE")) ) )
    MBSaveLog():FULLWrite(, .F., "ZADSALVAR Auto:   Placa - "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) + " Peso - "   + AllTrim( cValToChar(M->ZPB_OPESOE) ) )
    MBSaveLog():FULLWrite(, .F., "ZADSALVAR Manual: Placa - "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) + " Peso - "   + AllTrim( cValToChar(oMdl4:GetValue("ZPB_PESOS")) ) )
    MBSaveLog():FULLWrite(, .F., "ZADSALVAR Auto:   Placa - "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) + " Peso - "   + AllTrim( cValToChar(M->ZPB_OPESOS) ) )

    If oMdl3:GetValue("ZPB_PESOE") == 0
        MSGSTOP('<font color="#FF0000" size="5"><b>PESO DE ENTRADA NÃO INFORMADO. SAIDA BLOQUEADA.</b></font>', "Atenção")
        Return .F.
    EndIf

    If lAuto .AND. oMdl4:GetValue("ZPB_PESOS") ==0
        MSGSTOP('<font color="#FF0000" size="5"><b>PESO DE SAÍDA NÃO INFORMADO. SAIDA BLOQUEADA.</b></font>', "Atenção")
        Return .F.
    ENDIF

    If lAuto .OR. oMdl3:GetValue("ZPB_PESOE") >0.AND. oMdl4:GetValue("ZPB_PESOS")>0
        If !Obrigatorio(aGets, aTela) .OR. !VldPesagem()
            Return .F.
        EndIf
    EndIf

	cChave := dToS(oMdl3:GetValue("ZPB_DATA"))+ oMdl1:GetValue("ZPB_CODIGO")

    BeginTran()
    TryException
        ZPB->( DbSetOrder(1) )
        lRecLock:=!ZPB->(DbSeek( xFilial("ZPB") + cChave))
        RecLock( "ZPB", lRecLock )
        ZPB->ZPB_FILIAL	:= FwXFilial('ZPB')
        U_GrvCpo("ZPB")
       		oMdl1:SetValue("ZPB_STATUS", IiF( oMdl3:GetValue("ZPB_PESOE") >0.AND. oMdl4:GetValue("ZPB_PESOS")>0, "F", "1"))
        ZPB->(MsUnlock())

        MSUnlockAll()

        If !lAuto
            cPlacaTGet   := CriaVar( 'DA3_PLACA' , .F.)
            nQualPesagem := 0
        EndIf

    CatchException Using oException
        Alert("Erro ao Gravar Pessagem: " + CRLF + oException:Description)
        u_ShowException(oException)
        DisarmTransaction()
    EndException
    EndTran()
    RestArea(aAreaZPB)

    //SetKey( VK_F10, NIL)
    SetKey( VK_F11, NIL)
    SetKey( VK_F4 , NIL)

Return .T.

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		              	  |
 | Func:  fDefinePessagem 	            	          	            	          |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  25.09.2020                   	          	            	              |
 | Desc:  0=Nao localizado pesagem                                                |
 |        1=Existe pesagem, portanto agora é a 2ª pesagem, ou seja, peso de saida |
 |        PROGRAMAR SQL DE VERIFICACAO DA EXISTENCIA DE PESAGEM                   |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
            '--------------------------------------------------------------------------------*/
Static Function UltPesagemXPlaca(cPlaca)
	Local aArea    := GetArea()
	Local _cQry    := ""
	Local aRetorno := {}

	_cQry := " SELECT	TOP 1 R_E_C_N_O_ RECNO--, * " + CRLF
	_cQry += " FROM	"+RetSqlName("ZPB")+" " + CRLF
	_cQry += " WHERE	ZPB_PLACA = '"+ cPlaca +"' " + CRLF
	_cQry += "     AND D_E_L_E_T_=' ' " + CRLF
	_cQry += " ORDER BY R_E_C_N_O_ DESC "
	If lower(UsrFullName( )) $ 'bernardo,mbernardo,atoshio,admin,administrador,ioliveira'
		MemoWrite("C:\totvs_relatorios\UltPesagemXPlaca "+cPlacaTGet+".sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
	if !TEMPSQL->(Eof())
		ZPB->(DbGoTo(TEMPSQL->RECNO))
		aAdd( aRetorno, { ZPB->ZPB_CODMOT,;
							ZPB->ZPB_CPFMOT,;
							ZPB->ZPB_NOMMOT,;
							ZPB->ZPB_PRODUT,;
							ZPB->ZPB_DESC  ,;
							ZPB->ZPB_CLIFOR,;
							ZPB->ZPB_CODFOR,;
							ZPB->ZPB_LOJFOR,;
							ZPB->ZPB_NOMFOR,;
							ZPB->ZPB_LOCAL ,;
							ZPB->ZPB_BAIA  ,;
							ZPB->ZPB_OBSERV } )
	EndIf
	TEMPSQL->(DbCloseArea())
	RestArea(aArea)
Return aRetorno

Static Function CriaBt1(o1Panel,o1OtherObject)
	Local cCssBtn := "QPushButton { font-family: Arial, Helvetica, sans-serif;"+;
									" font-size: 16px;" +;
									" margin: 2px;" +;
									" font-weight: bold;" +;
									" background-color: #2C2;" +;
									" border: 2px solid; " +;
									" border-radius: 20px; }" +;
			"QPushButton:hover { color: #000000;" +;
								" border: 2px solid #000000;" +;
								" background-color: #FFFF00; }" +;
			"QPushButton:pressed { color: #ffa500;" +;
									" border: 1px solid #000000;" +;
									" background-color: #FFFFFF; }"

    //TButton():New( 10, 10, "Pesar",oPanel,{|| SelGrid(oOtherObject)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtPeso1 := 	TButton():New(20,10, "ENTRADA", o1Panel,;
        {|| U_PegaPeso(.T.,1) }, 50, 35,,,, .T./*lPixel*/)
    
	oBtPeso1:SetCss(cCssBtn)
	//oBtPeso1:SetCss("QPushButton { background-color: #0000ff; color: #FFF; margin: 2px; font-weight: bold; font-size: 16pt;border: 2px solid blue; border-radius: 20px;}")
Return

Static Function CriaBt2(o2Panel,o2OtherObject)
	Local cCssBtn := "QPushButton { font-family: Arial, Helvetica, sans-serif;"+;
									" font-size: 16px;" +;
									" margin: 2px;" +;
									" font-weight: bold;" +;
									" background-color: #FF0000;" +;
									" border: 2px solid; " +;
									" border-radius: 20px; }" +;
			"QPushButton:hover { color: #000000;" +;
								" border: 2px solid #000000;" +;
								" background-color: #FFFF00; }" +;
			"QPushButton:pressed { color: #ffa500;" +;
									" border: 1px solid #000000;" +;
									" background-color: #FFFFFF; }"

    //TButton():New( 10, 10, "Pesar",oPanel,{|| SelGrid(oOtherObject)}, 60,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oBtPeso2 := TButton():New(20,10, "SAÍDA", o2Panel,;
        		{|| U_PegaPeso(.T.,2) }, 50, 35,,,, .T./*lPixel*/)
    
	oBtPeso2:SetCss(cCssBtn)
	//oBtPeso2:SetCss("QPushButton { background-color: #2C2; color: #FFF; margin: 2px; font-weight: bold; font-size: 16pt;border: 2px solid green; border-radius: 20px;}")
Return

User Function PPeso1()
	Local oModel	  	:= FWModelActive()
	Local oMdl1 		:= oModel:GetModel('ZPB_1')
	Local oMdl2 		:= oModel:GetModel('ZPB_2')
	Local oMdl3 		:= oModel:GetModel('ZPB_3')
	Local oMdl4 		:= oModel:GetModel('ZPB_4')
	Local oMdl5 		:= oModel:GetModel('ZPB_5')
	Local aPeso 		:= {}
	
	if Empty(oMdl2:GetValue("ZPB_CPFMOT"))
		MSGSTOP("Informe o campo CPF Motorista [ABA 02] antes de imprimir o ticket")
	elseif Empty(oMdl2:GetValue("ZPB_CODFOR"))
		MSGSTOP("Informe o campo Codigo Fornecedor [ABA 02] antes de imprimir o ticket")
	elseif Empty(oMdl5:GetValue("ZPB_PRODUT"))
		MSGSTOP("Informe o campo Produto [ABA 05] antes de imprimir o ticket")
	elseif Empty(oMdl3:GetValue("ZPB_PESOE"))
		MSGSTOP("Informe o campo Peso de Entrada [ABA 03] antes de imprimir o ticket")
	elseif Empty(oMdl4:GetValue("ZPB_PESOS"))
		MSGSTOP("Informe o campo Peso de Saida [ABA 04] antes de imprimir o ticket")
	else 
		aAdd(aPeso, {;
				{"ZPB_CODIGO", oMdl1:GetValue("ZPB_CODIGO")},;
				{"ZPB_STATUS", oMdl1:GetValue("ZPB_STATUS")},;
				{"ZPB_PLACA" , oMdl1:GetValue("ZPB_PLACA")},;
				{"ZPB_DATA"  , oMdl3:GetValue("ZPB_DATA")},;
				{"ZPB_HORA"  , oMdl3:GetValue("ZPB_HORA")},;
				{"ZPB_CPFMOT", oMdl2:GetValue("ZPB_CPFMOT")},;
				{"ZPB_CODMOT", oMdl2:GetValue("ZPB_CODMOT")},;
				{"ZPB_NOMMOT", oMdl2:GetValue("ZPB_NOMMOT")},;
				{"ZPB_CLIFOR", oMdl2:GetValue("ZPB_CLIFOR")},;
				{"ZPB_CODFOR", oMdl2:GetValue("ZPB_CODFOR")},;
				{"ZPB_LOJFOR", oMdl2:GetValue("ZPB_LOJFOR")},;
				{"ZPB_NOMFOR", oMdl2:GetValue("ZPB_NOMFOR")},;
				{"ZPB_NOTFIS", oMdl5:GetValue("ZPB_NOTFIS")},;
				{"ZPB_PRODUT", oMdl5:GetValue("ZPB_PRODUT")},;
				{"ZPB_DESC"  , oMdl5:GetValue("ZPB_DESC")},;
				{"ZPB_PESOE" , oMdl3:GetValue("ZPB_PESOE")},;
				{"ZPB_PESOS" , oMdl4:GetValue("ZPB_PESOS")},;
				{"ZPB_DATAF" , oMdl4:GetValue("ZPB_DATAF")},;
				{"ZPB_HORAF" , oMdl4:GetValue("ZPB_HORAF")},;
				{"ZPB_PESOL" , oMdl4:GetValue("ZPB_PESOL")},;
				{"ZPB_LOCAL" , oMdl5:GetValue("ZPB_LOCAL")},;
				{"ZPB_BAIA"  , oMdl5:GetValue("ZPB_BAIA")},;
				{"ZPB_OBSERV", oMdl5:GetValue("ZPB_OBSERV")},;
				{"ZPB_NROGTA", oMdl5:GetValue("ZPB_NROGTA")},;
				{"ZPB_QTANIM", oMdl5:GetValue("ZPB_QTANIM")};
		})

		if Len(aPeso) > 0
			FWMsgRun(, {|| mbPesoPrint(aPeso) },;
						'Por Favor Aguarde...',; 
						'Imprimindo ticket')
		endif 

		if oModel:VldData()
			if oModel:CommitData()
				if oModel:CommitData() 
					AtualPsgemNF() //colocar atualiza pesagem aqui
					MBSaveLog():FULLWrite(, .F., "PPeso1 - Imprimindo ticket/ Placa: "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) )
					cPlacaTGet   := CriaVar( 'DA3_PLACA' , .F.)
					nQualPesagem := 0
				endif
			endif 
		endif
	endif 
return

User Function PPeso2()
	Local aPeso 		:= {}

	if Empty(ZPB->ZPB_CPFMOT)
		MSGSTOP("Informe o campo CPF Motorista [ABA 02] antes de imprimir o ticket")
	elseif Empty(ZPB->ZPB_CODFOR)
		MSGSTOP("Informe o campo Codigo Fornecedor [ABA 02] antes de imprimir o ticket")
	elseif Empty(ZPB->ZPB_PRODUT)
		MSGSTOP("Informe o campo Produto [ABA 05] antes de imprimir o ticket")
	elseif Empty(ZPB->ZPB_PESOE)
		MSGSTOP("Informe o campo Peso de Entrada [ABA 03] antes de imprimir o ticket")
	elseif Empty(ZPB->ZPB_PESOS)
		MSGSTOP("Informe o campo Peso de Saida [ABA 04] antes de imprimir o ticket")
	else 
		aAdd(aPeso, {;
				{"ZPB_CODIGO", ZPB->ZPB_CODIGO},;
				{"ZPB_STATUS", ZPB->ZPB_STATUS},;
				{"ZPB_PLACA" , ZPB->ZPB_PLACA},;
				{"ZPB_DATA"  , ZPB->ZPB_DATA},;
				{"ZPB_HORA"  , ZPB->ZPB_HORA},;
				{"ZPB_CPFMOT", ZPB->ZPB_CPFMOT},;
				{"ZPB_CODMOT", ZPB->ZPB_CODMOT},;
				{"ZPB_NOMMOT", ZPB->ZPB_NOMMOT},;
				{"ZPB_CLIFOR", ZPB->ZPB_CLIFOR},;
				{"ZPB_CODFOR", ZPB->ZPB_CODFOR},;
				{"ZPB_LOJFOR", ZPB->ZPB_LOJFOR},;
				{"ZPB_NOMFOR", ZPB->ZPB_NOMFOR},;
				{"ZPB_NOTFIS", ZPB->ZPB_NOTFIS},;
				{"ZPB_PRODUT", ZPB->ZPB_PRODUT},;
				{"ZPB_DESC"  , ZPB->ZPB_DESC},;
				{"ZPB_PESOE" , ZPB->ZPB_PESOE},;
				{"ZPB_PESOS" , ZPB->ZPB_PESOS},;
				{"ZPB_DATAF" , ZPB->ZPB_DATAF},;
				{"ZPB_HORAF" , ZPB->ZPB_HORAF},;
				{"ZPB_PESOL" , ZPB->ZPB_PESOL},;
				{"ZPB_LOCAL" , ZPB->ZPB_LOCAL},;
				{"ZPB_BAIA"  , ZPB->ZPB_BAIA},;
				{"ZPB_OBSERV", ZPB->ZPB_OBSERV},;
				{"ZPB_NROGTA", ZPB->ZPB_NROGTA},;
				{"ZPB_QTANIM", ZPB->ZPB_QTANIM};
		})

		if Len(aPeso) > 0
			FWMsgRun(, {|| mbPesoPrint(aPeso) },;
						'Por Favor Aguarde...',; 
						'Imprimindo ticket')
		endif 
	endif 
return

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  mbPesoPrint 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  29.09.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function mbPesoPrint(aPeso)

	// Local cFilePrinter := "Ticket-" + AllTrim(cPlacaTGet) + "-" + DtoS(dDataBase) + '-' + StrTran(Time(),":","") + ".rel"
	Local cFilePrinter := "Ticket-" + AllTrim(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_PLACA"})][2]) + "-" + DtoS(dDataBase) + "-" + AllTrim(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_CODIGO"})][2]) + iIf(GetServerIP()=="192.168.0.250", " " + StrTran(Time(),":",""), "") + ".rel"
	Private oPrinter   := nil

	oPrinter := FWMSPrinter():New( cFilePrinter, IMP_PDF/*nDevice*/ , .F./*lAdjustToLegacy*/, /*cPathInServer*/, .T./*lDisabeSetup*/,;
		/*lTReport*/, /*@oPrintSetup*/, /*cPrinter*/, /*lServer*/, .F./*lPDFAsPNG*/, /*lRaw*/,;
		.T. /*lViewPDF*/, /*nQtdCopy*/ )
	oPrinter:StartPage()
	// oPrinter:SetResolution(72)
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4) // DMPAPER_A4 = A4 210 x 297 mm
	oPrinter:SetMargin(60,60,60,60) // nEsquerda, nSuperior, nDireita, nInferior
	oPrinter:cPathPDF := "C:\TOTVS_RELATORIOS\" // Caso seja utilizada impressão em IMP_PDF

	RptStatus({|lEnd| ImpTicket(@lEnd,aPeso)}, "Imprimindo relatorio...") //"A imprimir relatório..."

Return nil


/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  ImpTicket 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  29.09.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
            '--------------------------------------------------------------------------------*/
Static Function ImpTicket( lEnd ,aPeso)
	// Local nSizePage    := 0
	Local _cBaia       := ""

	Private nRow       := 30, nColLabel:=30, nColInfo :=110
	Private cTxtAux    := ""
	Private cLogo      := "\system\lgrl" + AllTrim(cEmpAnt) + ".bmp"
	// Private nBckTamLin := nTamLin
	Private cReplc     := 65
	Private nTotLinOBS := 4

	Private cUltTrato  := ""

	_cBaia := aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_BAIA"})][2]
	If ( aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_CLIFOR"})][2] == "C" ) .AND.;
			(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_CODFOR"})][2] == GetMV("MB_PSGCFOR",,"000001")) .AND.;
			!Empty(_cBaia)
		cUltTrato := fQryUltTrato( _cBaia )
	EndIf

	nTotLinha := (14/* linhas de textos */+3 /* linhas graficas de separacao */+nTotLinOBS/*linhas do campo de observacao*/)+2
	nTamLin   := /* 20 */ /* 19 */ 18.5

	// nSizePage := oPrinter:nPageWidth / oPrinter:nFactorHor //Largura da página em cm dividido pelo fator horizontal, retorna tamanho da página em pixels

	oPrinter:Box( nRow*0.6, nBoxCol:=nColLabel*0.6, nBoxBottom:=(nTamLin*nTotLinha)*0.95, nBoxRight:=int(oPrinter:nPageWidth/4.15), cBoxPixel:="-4" )// ( 130, 10, 600, 900, "-4")
	fQuadro(1,aPeso)

	// nRow+=nTamLin
	cTxtAux := Replicate("-", cReplc) + "recorte-aqui" + Replicate("-", cReplc)
	// oPrinter:Say ( nRow+=nTamLin/* *0.8 */, nColLabel    ,  cTxtAux /*cText>*/, oFontRecor/*oFont*/, /*nWidth*/, RGB(255,0,0)/*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow:=nBoxBottom+(nTamLin/2)+(nTamLin/5), nColLabel    ,  cTxtAux /*cText>*/, oFontRecor/*oFont*/, /*nWidth*/, RGB(255,0,0)/*nClrText*/, /*nAngle*/ )

	oPrinter:Box( nRow+=(nTamLin/2), nBoxCol, nBoxBottom*2, nBoxRight/*nRight*/, "-4"/*cPixel*/ )// ( 130, 10, 600, 900, "-4")
	nRow+=(nTamLin/2)+(nTamLin/5)
	fQuadro(2,aPeso)

	oPrinter:EndPage()
	oPrinter:Preview()
	FreeObj(oPrinter)
	oPrinter := Nil

	/// nTamLin := nBckTamLin

Return nil

// ##########################################################################
Static Function fQuadro( nQuadro ,aPeso)
	Local cAux      := ""
	Local nCol2     := 305
	Default nQuadro := 0

	oPrinter:Say ( nRow         , nColLabel, PADC(AllTrim(upper(SM0->M0_NOMECOM)), cReplc*1.1 )/*cText>*/, oFTitLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
	oPrinter:Line( nRow+=nTamLin-10/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "CNPJ...........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo , Transform(SM0->M0_CGC, X3Picture("A2_CGC"))/*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	oPrinter:Say ( nRow         , nColLabel+nCol2, "Inscr. Estadual:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo +nCol2, Transform(SM0->M0_INSC, X3Picture("@R 999.999.999.999"))/*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Fone...........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo , "(18) 99658-4721 / (18) 99665-4013"/*SM0->M0_TEL*/ /*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	oPrinter:Say ( nRow         , nColLabel+nCol2, "E-Mail.........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo +nCol2, "balanca@vistaalegre.agr.br"/*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	cTxtAux := AllTrim( SM0->M0_ENDENT )+" - "+AllTrim(SM0->M0_BAIRENT)+" - CEP: "+AllTrim(SM0->M0_CEPENT)
	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Endereço.......:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo , cTxtAux/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	// ----------------------------------------------------------------------------------------------------------------------------
	// Linha
	oPrinter:Line( nRow+=nTamLin-5/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
	oPrinter:Say ( nRow+=nTamLin, nColLabel      , "Ticket.........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow       , nColInfo , dToS(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_DATA"})][2])+'-'+aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_CODIGO"})][2];
		/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	oPrinter:Say ( nRow         , nColLabel+nCol2, "Impressão......:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, RGB(0,0,0)/*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo+nCol2, DtoC(MsDate())+" às "+SubS(Time(),1,5) /*cText>*/,oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Line( nRow+=nTamLin-5/*nTop*/, nBoxCol/*nLeft*/, nRow/*nBottom*/, nBoxRight/*nRight*/, /*nColor*/, cBoxPixel/*cPixel*/ )
	// Linha
	// ----------------------------------------------------------------------------------------------------------------------------

	if nQuadro==2
		nBitMWidth:=150
		oPrinter:SayBitmap ( nRow+10/* -nColLabel *//*nRow*/, nBoxRight-nBitMWidth-5/* -nColLabel *//*nCol*/, cLogo/*cBitmap*/, nBitMWidth, int(nBitMWidth/2)/*nHeight*/ )
	EndIf

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Placa de cavalo:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo , aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_PLACA"})][2]/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	If ( aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_CLIFOR"})][2] == "C" )
		cAux := "Cliente........:"
	Else
		cAux := "Fornecedor.....:"
	EndIf
	oPrinter:Say ( nRow+=nTamLin, nColLabel, cAux/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo , aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_NOMFOR"})][2]/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "CPF / CNPJ.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	If !Empty(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_CPFMOT"})][2])
		oPrinter:Say ( nRow     , nColInfo , Transform(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_CPFMOT"})][2], X3Picture("ZPB_CPFMOT"))/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	EndIf

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Motorista......:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo , aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_NOMMOT"})][2]/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Notas Fiscais..:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo , aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_NOTFIS"})][2]/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Produto........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo , aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_DESC"})][2]/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	oPrinter:Say ( nRow         , nColLabel+nCol2, "Baia........:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo+nCol2 , aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_BAIA"})][2]/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Peso Entrada...:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo ,  AllTrim(Transform( aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_PESOE"})][2], X3Picture("ZBC_PESO") ) )/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	If !Empty(StrTran(DtoC(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_DATAF"})][2]),"/","")+StrTran(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_HORAF"})][2],":",""))
		cAux := DtoC(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_DATA"})][2])+" - "+SubS(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_HORA"})][2],1,5)
		oPrinter:Say ( nRow         , nColInfo+nCol2, cAux /*cText>*/, oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	EndIf

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Peso Saida.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo ,  AllTrim(Transform( aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_PESOS"})][2], X3Picture("ZBC_PESO") ) )/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	If !Empty(StrTran(DtoC(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_DATAF"})][2]),"/","")+StrTran(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_HORAF"})][2],":",""))
		cAux := DtoC(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_DATAF"})][2])+" - "+SubS(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_HORAF"})][2],1,5)
		oPrinter:Say ( nRow         , nColInfo+nCol2, cAux /*cText>*/, oFInfo /*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	EndIf

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Peso Líquido...:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo , AllTrim(Transform( aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_PESOL"})][2], X3Picture("ZBC_PESO") ) )/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )

	If !Empty( cUltTrato )
		oPrinter:Say ( nRow     , nColLabel+nCol2, "Ultimo Trato:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
		oPrinter:Say ( nRow     , nColInfo+nCol2 , cUltTrato/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	EndIf

	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Observação.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	nCountLinOBS := 0
	cTamOBS      := 123
	cTexto       := StrTran( AllTrim(aPeso[1][aScan(aPeso[1], {|x| Upper(x[1]) == "ZPB_OBSERV"})][2]), Chr(13)+Chr(10), " ")
	nRow         -= nTamLin
	While .T.
		nCountLinOBS += 1
		oPrinter:Say ( nRow +=nTamLin, nColInfo , SubS(Upper(cTexto),1,cTamOBS)/*cText>*/, oFInfoOBS/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
		cTexto := SubS(cTexto, cTamOBS+1)
		if (nCountLinOBS==nTotLinOBS) .OR. Empty(cTexto)
			exit
		Endif
	EndDo
	nRow += (nTamLin*(nTotLinOBS-nCountLinOBS))
	oPrinter:Say ( nRow+=nTamLin, nColLabel, "Responsável pela Pesagem.....:"/*cText>*/, oFLabel/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
	oPrinter:Say ( nRow         , nColInfo+65 , UsrFullName( )/*cText>*/, oFInfo/*oFont*/, /*nWidth*/, /*nClrText*/, /*nAngle*/ )
Return

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_Tela1Pesagem()          		              |
 | Func:  Tela1Pesagem 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  23.09.2020                   	          	            	              |
 | Desc:  Captura inicial, neste momento sera feito manualmente;                  |
 |        projeto futuro é fazer a leitura automatica via RFID;                   |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
User Function Tela1Pesagem(cAlias, nReg)
	Local nOpc 		:= 3
    Local nOpcA 	:= 0
    Local nDlgLinFim, nDlgColFim
    Local nTS1Row   , nTS1Col, nTSWidth
    Local nTG1Row   , nTG1Col, nTGWidth
    Local nTBRow    , nTBCol , nTBWidth

    Private oDlg1 	:= nil
    Private __cBorderMB := ""

	cPlacaTGet   := CriaVar( 'DA3_PLACA' , .F.)

    // Private __cCorFundo := ""

    DbSelectArea("SA2")
    SA2->(DbSetOrder(1))

    DbSelectArea("DA4")
    DA4->(DbSetOrder(1))

    DEFINE DIALOG oDlg1 TITLE OemToAnsi("Definição do Caminhão") FROM 0,0 TO nLinFim:=470, nColFim:=622 PIXEL;
        STYLE nOR( DS_MODALFRAME, WS_POPUP, WS_CAPTION, WS_VISIBLE )  // tirar o X da tela | tirar o botao X da tela |

    oPanel := tPanel():New( 01, 01, /*cText*/, oDlg1,,,, /*CLR_YELLOW*/, /*CLR_BLUE*/, nDlgLinFim, nDlgColFim, /* lLowered */, .T. /* lRaised */)
    oPanel:Align := CONTROL_ALIGN_ALLCLIENT
    oPanel:SetCss("QLabel {" + (__cCorFundo:=" background: #e6ffe6; " ) + "}")

    oSay     := TSay():New(nTS1Row:=35, nTS1Col:=115, {|| "PLACA"}, oPanel, /*cPicture*/, /*oFont*/, , , , .T., , , nTSWidth:=110, 60)
    oSay:SetCss("QLabel {" + __cCorFundo + "color: #00ff00; font-size: 36pt}")

    /*  https://tdn.totvs.com/display/tec/Construtor+TGet%3ANew#
    TGet():New( [ nRow ], [ nCol ], [ bSetGet ], [ oWnd ], [ nWidth ], [ nHeight ], [ cPict ], [ bValid ], [ nClrFore ], [ nClrBack ], [ oFont ], [ uParam12 ], [ uParam13 ], [ lPixel ], [ uParam15 ], [ uParam16 ], [ bWhen ], [ uParam18 ], [ uParam19 ], [ bChange ], [ lReadOnly ], [ lPassword ], [ uParam23 ], [ cReadVar ], [ uParam25 ], [ uParam26 ], [ uParam27 ], [ lHasButton ], [ lNoButton ], [ uParam30 ], [ cLabelText ], [ nLabelPos ], [ oLabelFont ], [ nLabelColor ], [ cPlaceHold ], [ lPicturePriority ], [ lFocSel ] )  */
    oTGet := TGet():New( nTG1Row:=85 /*nRow*/, nTG1Col:=40/*nCol*/, {|u|If(PCount()>0,cPlacaTGet:=u,cPlacaTGet)} /*bSetGet*/, oPanel/*oWnd*/,;
        nTGWidth:=240/*nWidth*/, /*nHeight*/ 50, "@! AAA-9N99"/*cPict*/, /*bValid*/, /*nClrFore*/, /*nClrBack*/, /*oFont*/, /*uParam12*/, /*uParam13*/,/*lPixel*/.T., /*uParam15*/, /*uParam16*/, /*bWhen*/, /*uParam18*/, /*uParam19*/, /*bChange*/, .F. /*lReadOnly*/, .F./*lPassword*/, /*uParam23*/,;
        "cPlacaTGet" /*cReadVar*/, /*uParam25*/, /*uParam26*/, /*uParam27*/, /*lHasButton*/,;
        /*lNoButton*/, /*uParam30*/, /*cLabelText*/, /*nLabelPos Indica a posição da label, sendo 1=Topo e 2=Esquerda*/, /*oLabelFont*/, /*nLabelColor*/, /*cPlaceHold*/, /*lPicturePriority*/, /*lFocSel*/.F. )
    oTGet:SetCss("QLineEdit {" + __cCorFundo + "color: #000; font-weight: bold; font-size: 72pt;" + (__cBorderMB:=" border: 2px solid green; border-radius: 20px; ") + "}")

    // https://tdn.totvs.com/display/tec/TButton
    oT1_1Button := tButton():New(nTBRow:=170, nTBCol:=30, "CONFIRMAR (F10)", oPanel,;
        {|| nOpcA := 1,  U_Tela2Pesagem(cAlias, nReg, nOpc)/*, oDlg1:End()*/}, nTBWidth:=120, 40/*nHeight*/,,,, .T./*lPixel*/)
    oT1_1Button:SetCss("QPushButton { background: #2C2; color: #FFF; margin: 2px; font-weight: bold; font-size: 14pt; border-radius: 15px; }")

    oT1_2Button := tButton():New(nTBRow, nTBCol+nTBWidth+15, "SAIR (ESC)", oPanel,;
        {|| nOpcA := 1, oDlg1:End() }, nTBWidth, 40/*nHeight*/,,,, .T./*lPixel*/)
    oT1_2Button:SetCss(oT1_1Button:GetCss())

    SetKey( VK_F10, {|| U_Tela2Pesagem(cAlias, nReg, nOpc)/* , oDlg1:End() */ } )

    MBSaveLog():FULLWrite(, .F., "Carregado Tela 1")

    ACTIVATE DIALOG oDlg1 CENTERED // ON INIT EnchoiceBar(oDlg1,;
    //                     {|| nOpcA := 1, oDlg1:End()},;
    //                     {|| nOpcA := 0, oDlg1:End()} ) CENTERED
    If nOpcA == 0
        cPlacaTGet   := CriaVar( 'DA3_PLACA' , .F.)
        MBSaveLog():FULLWrite(, .F., cPlacaTGet)
        nQualPesagem := 0
        // Else
        //      Alert('[T1] CONFIRMAR')
    EndIf
Return nil

User Function Tela2Pesagem(cAlias, nReg, nOpc)
    Local aArea          := GetArea()

    Private _cNotaFiscal := CriaVar( 'D2_DOC', .F.)

    If IsInCallStack("U_TELA1PESAGEM")
        If (AllTrim(cPlacaTGet) == "-" .OR. Empty(cPlacaTGet))
            _cHTML := '<h3><span style="color: #00ff00;">Placa n&atilde;o informada</span></h3>'+;
                '<p>Esta opera&ccedil;&atilde;o ser&aacute; cancelada.</p>'

            MBSaveLog():FULLWrite(, .F., _cHTML)

            MsgInfo(_cHTML)
            return nil
        EndIf
    EndIf

    If nOpc == 3 // nao pode ter o nReg aqui ....
        If (nQualPesagem:=fDefinePessagem())>0
            (cAlias)->(DbGoTo(nReg := nQualPesagem))
            nOpc := 4
            INCLUI := .F.
            ALTERA := .T.
        Else
            nOpc := 3
            nReg := 0
            INCLUI := .T.
            ALTERA := .F.
        EndIf
    Else
        nQualPesagem := nReg
    EndIf
	
	RegToMemory( cAlias, nQualPesagem == 0 )

    cFunBkp := FunName()
    
    If INCLUI 
	    MBSaveLog():FULLWrite(, .F., "Carregado Tela 2 - Inclusão, Placa: " + cPlacaTGet)
        SetFunName("VAESTPES")
        FWExecView('Inclusão: [ 1º Pesagem: Placa '+cPlacaTGet+' ] '+Space(10)+' [ IMPRIMIR (F11) ] ', 'VAESTPES', MODEL_OPERATION_INSERT,,{||.T.})
        SetFunName(cFunBkp)
    ElseIf ALTERA
	    MBSaveLog():FULLWrite(, .F., "Carregado Tela 2 - Alteração, Placa: " + cPlacaTGet)
        SetFunName("VAESTPES")
        FWExecView('Alterar: [ 2º Pesagem: Placa '+cPlacaTGet+' ] '+Space(10)+' [ IMPRIMIR (F11) ] ', 'VAESTPES', MODEL_OPERATION_UPDATE,,{||.T.})
        SetFunName(cFunBkp)
    EndIf 
	
	oDlg1:End()

    RestArea(aArea)
Return nil

User Function VldNotFis()
	Local oModel	  	:= FWModelActive()
	Local oMdl5 		:= oModel:GetModel('ZPB_5')

    Local lRet := .T.
    if At(&(ReadVar()), oMdl5:GetValue("ZPB_NOTFIS")) > 0
        Return .F.
    EndIf
Return lRet

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  AtualPsgemNF	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  02.12.2020                                                              |
 | Desc:  Atualizar dados da pesagem apos a finalizacao da pesagem;               |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function AtualPsgemNF()
	Local oModel	  	:= FWModelActive()
	Local oMdl1 		:= oModel:GetModel('ZPB_1')
	Local oMdl2 		:= oModel:GetModel('ZPB_2')
	Local oMdl3 		:= oModel:GetModel('ZPB_3')
	Local oMdl4 		:= oModel:GetModel('ZPB_4')
	Local oMdl5 		:= oModel:GetModel('ZPB_5')
    Local aArea   := GetArea()
    Local _cQry   := ""
    Local nI      := 0
    Local aNotFis := StrToKarr(AllTrim(oMdl5:GetValue("ZPB_NOTFIS")),";")
    Local nLinAtu := 0

    If Empty(oMdl5:GetValue("ZPB_NOTFIS")) .OR.;
             oMdl2:GetValue("ZPB_CLIFOR") <> 'C' .OR.;
            !(AllTrim(oMdl2:GetValue("ZPB_CODFOR"))==GetMV("MB_PSGCFOR",,"000001") .AND. (oMdl3:GetValue("ZPB_PESOE")>0.AND.oMdl4:GetValue("ZPB_PESOS")>0))// MB_PSGCFOR : Cliente/Fornecedor na pesagem
        Return nil
    EndIf

    For nI:=1 to Len(aNotFis)

        _cQry := " WITH " + CRLF +;
            "  SD2 AS ( " + CRLF +;
            " 		SELECT R_E_C_N_O_ RECNO, D2_QUANT  " + CRLF +;
            " 		FROM SD2010   " + CRLF +;
            " 		WHERE D2_FILIAL  = '"  + xFilial("SD2") + "' " + CRLF +;
            " 		AND D2_DOC     = '"  + aNotFis[nI]    + "' " + CRLF +;
            " 		AND D2_CLIENTE = '"  + oMdl2:GetValue("ZPB_CODFOR")  + "' " + CRLF +;
            " 		AND D2_QUANT   > 0  " + CRLF +;
            " 		AND D_E_L_E_T_ = ' '  " + CRLF +;
            " ) " + CRLF +;
            "" + CRLF +;
            " , SOMA_QTD_SD2 AS ( " + CRLF +;
            " 	SELECT SUM(D2_QUANT) QTD_TOTAL " + CRLF +;
            " 	FROM SD2 " + CRLF +;
            " ) " + CRLF +;
            "" + CRLF +;
            " SELECT *, '" + cValToChar(oMdl4:GetValue("ZPB_PESOL")) + "'*(( D2_QUANT*100)/QTD_TOTAL/100) PESO_RATEADO " + CRLF +;
            " FROM SD2 " + CRLF +;
            " CROSS JOIN SOMA_QTD_SD2 "

        If lower(UsrFullName( )) $ 'bernardo,mbernardo,atoshio,admin,administrador'
            MemoWrite("C:\totvs_relatorios\AtualPsgemNF.sql" , _cQry)
        EndIf
        dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
        While !TEMPSQL->(Eof())
            nLinAtu += 1

            MBSaveLog():FULLWrite(, .F., "AtualPsgemNF Lock: Placa - "+ AllTrim(oMdl1:GetValue("ZPB_PLACA")) + " Peso Entrada - "   + AllTrim( cValToChar(oMdl3:GetValue("ZPB_PESOE")) ) + " Peso Saida - "   + AllTrim( cValToChar(oMdl4:GetValue("ZPB_PESOS")) ) )

            SD2->(DbGoTo(TEMPSQL->RECNO))
            RecLock("SD2", .F.)
            SD2->D2_XNRPSAG := xFilial("ZPB")+DtoS(oMdl3:GetValue("ZPB_DATA"))+oMdl1:GetValue("ZPB_CODIGO")
            SD2->D2_XPESLIQ := TEMPSQL->PESO_RATEADO
            SD2->D2_XDTABAT := DataValida(oMdl4:GetValue("ZPB_DATAF")+1, .T.)
            SD2->(MsUnlock())
            
            MBSaveLog():FULLWrite(, .F., "AtualPsgemNF Unlock: Placa - "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) + " Peso Entrada - "   + AllTrim( cValToChar(oMdl3:GetValue("ZPB_PESOE")) ) + " Peso Saida - "   + AllTrim( cValToChar(oMdl4:GetValue("ZPB_PESOS")) ) )

            TEMPSQL->(DBSkip())

        EndDo
        TEMPSQL->(DbCloseArea())
    Next nI

    If nLinAtu>0
        MsgInfo("Em " + cValToChar(Len(aNotFis)) + " notas fiscais foram atualizadas " + cValToChar(nLinAtu) + " linhas." )
    EndIf

    RestArea(aArea)
Return nil

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  BuscaCurral	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  02.12.2020                                                              |
 | Desc:  Localiza curral na nota fiscal SD2                                      |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
User Function BuscaCurral()
	Local oModel	  	:= FWModelActive()
	Local oMdl1 		:= oModel:GetModel('ZPB_1')
	Local oMdl2 		:= oModel:GetModel('ZPB_2')
	Local oMdl3 		:= oModel:GetModel('ZPB_3')
	Local oMdl5 		:= oModel:GetModel('ZPB_5')
    Local aArea   := GetArea()
    Local cCurral := CriaVar( 'ZPB_BAIA', .F.)
    Local _cQry   := ""

    MBSaveLog():FULLWrite(, .F., "BuscaCurral Entrada: Placa - "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) + " Peso - "   + AllTrim( cValToChar(oMdl3:GetValue("ZPB_PESOE")) ) )

    _cQry := " SELECT  DISTINCT D2_LOTECTL " + CRLF+;
        " FROM    SD2010 " + CRLF+;
        " WHERE   D2_FILIAL='" + xFilial('SD2') + "' " + CRLF+;
        " 	   AND D2_DOC IN (" + U_cValToSQL(oMdl5:GetValue("ZPB_NOTFIS"), ";") + ") " + CRLF+;
        " 	   AND D2_CLIENTE = '" + AllTrim(oMdl2:GetValue("ZPB_CODFOR")) + "' " + CRLF+;
        " 	   AND D_E_L_E_T_=' '"
    If lower(UsrFullName( )) $ 'bernardo,mbernardo,atoshio,admin,administrador'
        MemoWrite("C:\totvs_relatorios\BuscaCurral.sql" , _cQry)
    EndIf
    
    dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
    
    if !TEMPSQL->(Eof())
        cCurral := TEMPSQL->D2_LOTECTL
    EndIf
    
    TEMPSQL->(DbCloseArea())
    
    MBSaveLog():FULLWrite(, .F., "BuscaCurral Saida: Placa - "+ AllTrim(oMdl1:GetValue("ZPB_PLACA") ) + " Peso - "   + AllTrim( cValToChar(oMdl3:GetValue("ZPB_PESOE")) ) )

    RestArea(aArea)
Return PadR(cCurral, TamSX3('ZPB_BAIA')[1])


/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  fDefinePessagem 	            	          	            	          |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  25.09.2020                   	          	            	              |
 | Desc:  0=Nao localizado pesagem                                               |
 |        1=Existe pesagem, portanto agora é a 2ª pesagem, ou seja, peso de saida|
 |        PROGRAMAR SQL DE VERIFICACAO DA EXISTENCIA DE PESAGEM                   |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function fDefinePessagem()

	Local _cQry    := ""
	Local nRetorno := 0

	_cQry := " SELECT TOP 1 * -- ZPB_PESOE, ZPB_PESOS " + CRLF
	_cQry += " FROM ZPB010 " + CRLF
	_cQry += " WHERE ZPB_FILIAL='"+FWxFilial("ZPB")+"' " + CRLF
	_cQry += "   AND ZPB_PLACA='" + cPlacaTGet + "' " + CRLF
	_cQry += "   AND ZPB_STATUS<>'F' " + CRLF
	_cQry += "   AND D_E_L_E_T_=' ' " + CRLF
	_cQry += " ORDER BY R_E_C_N_O_ DESC " + CRLF
	If lower(UsrFullName( )) $ 'bernardo,mbernardo,atoshio,admin,administrador,ioliveira'
		MemoWrite("C:\totvs_relatorios\fDefinePessagem "+cPlacaTGet+".sql" , _cQry)
	EndIf
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
	if !TEMPSQL->(Eof())
		If TEMPSQL->ZPB_PESOE > 0 // .AND. TEMPSQL->ZPB_PESOS == 0
			nRetorno := TEMPSQL->R_E_C_N_O_
		EndIf
	EndIf
	TEMPSQL->(DbCloseArea())

Return nRetorno // 0 = nao localizado pesagem
/*
MB : 30.11.2020
-> Consulta Especifica
	De acordo com o definido no campo: ZPB_CLIFOR, fazer SQL de Cliente ou Fornecedor;
	*/
User Function F3CliForPes()
	Local oModel	  	:= FWModelActive()
	Local oMdl2 		:= oModel:GetModel('ZPB_2')

	Local lRet   := .F.

	If  oMdl2:GetValue("ZPB_CLIFOR") == "C"
		If lRet := U_PesqCli()
			cF3CodCFPes := SA1->A1_COD
			cF3LojCFPes := SA1->A1_LOJA
			cF3NomCFPes := SA1->A1_NOME
		EndIf
	ElseIf  oMdl2:GetValue("ZPB_CLIFOR") == "F"
		If lRet := U_PesqFor()
			cF3CodCFPes := SA2->A2_COD
			cF3LojCFPes := SA2->A2_LOJA
			cF3NomCFPes := SA2->A2_NOME
		EndIf
	Else
		Alert("Por favor selecione o campo CLIENTE/FORNECEDOR !!!")
	EndIf
Return lRet

/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  ceDocBaia             	          	            	                  |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  15.12.2020                                                              |
 | Desc:  Consulta Especifica de Notas Fiscais de Saida x Baia;                   |
 |         Doc x Baia;                                                            |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
User Function ceDocBaia()
	Local oDlg, oLbx
	Local aCpos  := {}
	Local aRet   := {}
	Local _cQry := ""
	Local oModel	  	:= FWModelActive()
	Local oMdl2 		:= oModel:GetModel('ZPB_2')
	Local oMdl3 		:= oModel:GetModel('ZPB_3')
	Local cAlias := GetNextAlias()
	Local lRet   := .F.

	_cQry := " SELECT D2_LOTECTL, " + CRLF+;
		"        D2_DOC, " + CRLF+;
		"        SUM(D2_QUANT) QTDE " + CRLF+;
		"  FROM SD2010 " + CRLF+;
		"  WHERE D2_FILIAL  = '" + xFilial('SD2')         + "'" + CRLF+;
		"    AND D2_EMISSAO = '" + DtoS(oMdl3:GetValue("ZPB_DATA"))      + "'" + CRLF+;
		"    AND D2_CLIENTE = '" + AllTrim(oMdl2:GetValue("ZPB_CODFOR")) + "'" + CRLF+;
		"    AND D2_QUANT > 0 " + CRLF+;
		"    AND D2_GRUPO IN ('BOV','01')" + CRLF+;
		"    AND D2_LOTECTL NOT IN (" + CRLF+;
		"		                SELECT ZPB_BAIA " + CRLF+;
		"						  FROM ZPB010 " + CRLF+;
		"						 WHERE ZPB_FILIAL = D2_FILIAL" + CRLF+;
		"						   AND ZPB_BAIA = D2_LOTECTL " + CRLF+;
		"						   AND ZPB_NOTFIS LIKE '%' + D2_DOC + '%'" + CRLF+;
		"						   AND D_E_L_E_T_ = ' ' " + CRLF+;
		"						)" + CRLF+;
		"    AND D_E_L_E_T_ = ' '" + CRLF+;
		" GROUP BY D2_DOC, D2_LOTECTL" + CRLF+;
		" ORDER BY CAST(REPLACE(SUBSTRING(D2_LOTECTL, 1, CHARINDEX('-',D2_LOTECTL)),'-','') AS INT), 2"

	// _cQry := ChangeQuery(_cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),cAlias,.T.,.T.)

	While (cAlias)->(!Eof())
		aAdd(aCpos,{(cAlias)->D2_LOTECTL, (cAlias)->D2_DOC, (cAlias)->QTDE })
		(cAlias)->(dbSkip())
	End
	(cAlias)->(dbCloseArea())

	If Len(aCpos) < 1
		aAdd(aCpos,{" "," "," "})
	EndIf

	DEFINE MSDIALOG oDlg TITLE /*STR0083*/ "Listagem de Notas Fiscais x Baia" FROM 0,0 TO 240,500 PIXEL

	@ 10,10 LISTBOX oLbx FIELDS HEADER 'Lote x Baia' /*"Roteiro"*/,;
		'N. Fiscal' /*"Produto"*/,;
		'Quant.' SIZE 230,95 OF oDlg PIXEL

	oLbx:SetArray( aCpos )
	oLbx:bLine     := {|| {aCpos[oLbx:nAt,1],;
		aCpos[oLbx:nAt,2],;
		aCpos[oLbx:nAt,3]}}
	oLbx:bLDblClick := {|| {oDlg:End(), lRet:=.T., aRet := {oLbx:aArray[oLbx:nAt,1],;
		oLbx:aArray[oLbx:nAt,2],;
		oLbx:aArray[oLbx:nAt,3]}}}

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), lRet:=.T.,;
		aRet := {oLbx:aArray[oLbx:nAt,1],;
		oLbx:aArray[oLbx:nAt,2],;
		oLbx:aArray[oLbx:nAt,3]})  ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER

	If Len(aRet) > 0 .And. lRet
		If Empty(aRet[1])
			lRet := .F.
		Else
			_cNotaFiscal := aRet[2]
		EndIf
	EndIf
Return lRet


/*--------------------------------------------------------------------------------,
 | Principal: 					     U_MBESTPES()          		                  |
 | Func:  fQryUltTrato 	            	          	            	              |
 | Autor: Miguel Martins Bernardo Junior	            	          	          |
 | Data:  15.12.2020                   	          	            	              |
 | Desc:                                                                          |
 |                                                                                |
 '--------------------------------------------------------------------------------|
 | Alter:                                                                         |
 | Obs.:                                                                          |
'--------------------------------------------------------------------------------*/
Static Function fQryUltTrato( cBaia )
	Local cRetorno := ""

	_cQry := " SELECT Z0W_LOTE, " + CRLF +;
		" 	      MAX(Z0W_DATA) DATA," + CRLF +;
		" 	      SUBSTRING(MAX(Z0W_DATA+Z0W_HORFIN),9,5) HORA" + CRLF +;
		" FROM Z0W010" + CRLF +;
		" WHERE Z0W_FILIAL = '" + xFilial('Z0W') + "'" + CRLF +;
		" AND Z0W_LOTE = '" + cBaia + "'" + CRLF +;
		" AND (Z0W_QTDREA > 0 OR Z0W_PESDIG > 0)" + CRLF +;
		" AND D_E_L_E_T_ = ' '" + CRLF +;
		" GROUP BY Z0W_LOTE"
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,, _cQry ),"TEMPSQL",.F.,.F.)
	If !TEMPSQL->(Eof())
		cRetorno := /*AllTrim(TEMPSQL->Z0W_LOTE) + ': ' +*/dToC(sToD(TEMPSQL->DATA)) + ' - ' + TEMPSQL->HORA
		// TEMPSQL->(DBSkip())
	EndIf
	TEMPSQL->(DbCloseArea())

Return cRetorno
