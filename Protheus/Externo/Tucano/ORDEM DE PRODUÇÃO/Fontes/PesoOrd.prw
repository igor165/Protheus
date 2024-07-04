#INCLUDE "FWBROWSE.CH"
#Include 'FWMVCDef.ch'
#Include 'FWEditPanel.CH'
#Include "TOTVS.CH"

/* 
	Igor Gomes Oliveira 
	Emp: Tucano 
	Data: 14/05/2024 
	v.1
*/

Static cDescription := "Pesagem Transferência ou Milho Umido"

User Function PESOORD()
	Private cTipoReg 		:= ''
	Private oBrowse 		:= FWMBrowse():New()
	Private aSeek 			:= {}
	Private ExecAutoPesagem	:= ExecAutoPesagem():New()
	
	gerax1("PESOORD")

	oBrowse:SetDescription(cDescription)
	oBrowse:SetAlias("ZPT")
	oBrowse:SetMenuDef("PESOORD")
	oBrowse:SetUseFilter(.T.)
	oBrowse:SetDBFFilter(.T.)

	oBrowse:AddLegend( "!Empty(ZPT->ZPT_DOC)" 							, "RED"    	, "Pesagem e movimentação estoque finalizada" )
	oBrowse:AddLegend( "ZPT->ZPT_PESO1 > 0 .and. ZPT->ZPT_PESO2 == 0"  	, "GREEN"  	, "Pesagem e movimentação Aberta" )
	oBrowse:AddLegend( "ZPT->ZPT_PESO2 > 0"  							, "ORANGE" 	, "Pesagem finalizada e movimentação estornada" )

	// Ativa a oBrowse
	oBrowse:Activate()
Return Nil

Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE 'Incluir' 			ACTION 'ViewDEF.PESOORD' 	 OPERATION MODEL_OPERATION_INSERT   ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar' 			ACTION 'ViewDEF.PESOORD' 	 OPERATION MODEL_OPERATION_UPDATE   ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' 		ACTION 'ViewDEF.PESOORD' 	 OPERATION MODEL_OPERATION_VIEW   	ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir' 			ACTION 'ViewDEF.PESOORD' 	 OPERATION MODEL_OPERATION_DELETE   ACCESS 0
	ADD OPTION aRotina TITLE 'Pesquisar'  		ACTION 'PesqBrw'        	 OPERATION 1                      	ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Impromir Ticket'  ACTION 'U_ImpMotT'        	 OPERATION 1                      	ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Estorno'  		ACTION 'U_PesEstP'        	 OPERATION 1                      	ACCESS 0 //OPERATION 1
	ADD OPTION aRotina TITLE 'Alterar Produto'  ACTION 'U_PesAltP'        	 OPERATION 1                      	ACCESS 0 //OPERATION 1

Return aRotina

Static Function ModelDef()
	Local oModel  := MPFormModel():New("MDLPESOORD")
	Local oStrZPT := FWFormStruct(1, 'ZPT')

	oStrZPT:AddTrigger("ZPT_PESO2","ZPT_PESOL",{ | oModel | oModel:GetValue('ZPT_PESO1') > 0 .And. oModel:GetValue('ZPT_PESO2') > 0},;
		{ |oModel| IIF( oModel:GetValue('ZPT_PESO1') > oModel:GetValue('ZPT_PESO2') ,;
		oModel:GetValue('ZPT_PESO1') -  oModel:GetValue('ZPT_PESO2'),;
		oModel:GetValue('ZPT_PESO2') - oModel:GetValue('ZPT_PESO1') )  } )

	oStrZPT:AddTrigger("ZPT_PESO1","ZPT_PERCEN",{ |  | .T.}, {|| 0 } )
	oStrZPT:AddTrigger("ZPT_PESO1","ZPT_QTMILU",{ |  | .T.}, {|| 0 } )
	oStrZPT:AddTrigger("ZPT_PESO1","ZPT_QTMILH",{ |  | .T.}, {|| 0 } )
	oStrZPT:AddTrigger("ZPT_PESO1","ZPT_QTAGUA",{ |  | .T.}, {|| 0 } )

	oStrZPT:AddTrigger("ZPT_PESO2","ZPT_PERCEN",{ |  | .T.}, {|| 0 } )
	oStrZPT:AddTrigger("ZPT_PESO2","ZPT_QTMILU",{ |  | .T.}, {|| 0 } )
	oStrZPT:AddTrigger("ZPT_PESO2","ZPT_QTMILH",{ |  | .T.}, {|| 0 } )
	oStrZPT:AddTrigger("ZPT_PESO2","ZPT_QTAGUA",{ |  | .T.}, {|| 0 } )
	
	oStrZPT:AddTrigger("ZPT_PESO1","ZPT_DTHRP1",{ |  | .T.},{ |oModel| SubStr(Left(FWTimeStamp(2),TamSx3("ZPT_DTHRP2")[01]),1,Len(Left(FWTimeStamp(2),TamSx3("ZPT_DTHRP1")[01]))-3) } )
	oStrZPT:AddTrigger("ZPT_PESO2","ZPT_DTHRP2",{ |  | .T.},{ |oModel| SubStr(Left(FWTimeStamp(2),TamSx3("ZPT_DTHRP2")[01]),1,Len(Left(FWTimeStamp(2),TamSx3("ZPT_DTHRP2")[01]))-3) } )

	oStrZPT:AddTrigger("ZPT_PESO1","ZPT_PEMAN1",{ |  | .T.},{ || "M"} )
	oStrZPT:AddTrigger("ZPT_PESO2","ZPT_PEMAN2",{ |  | .T.},{ || "M"} )

	oStrZPT:AddTrigger("ZPT_CODPRD","ZPT_DESPRD",{ |  | .T.},{ |oModel| AllTrim(Posicione("SB1",1,FWxFilial("SB1")+oModel:GetValue("ZPT_CODPRD"),"B1_DESC"))}  )
	oStrZPT:AddTrigger("ZPT_CODDES","ZPT_PRDDES",{ |  | .T.},{ |oModel| AllTrim(Posicione("SB1",1,FWxFilial("SB1")+oModel:GetValue("ZPT_CODDES"),"B1_DESC"))}  )
	oStrZPT:AddTrigger("ZPT_CODDES","ZPT_ARMDES",{ |  | .T.},{ |oModel| AllTrim(Posicione("SB1",1,FWxFilial("SB1")+oModel:GetValue("ZPT_CODDES"),"B1_LOCPAD"))}  )

	oStrZPT:SetProperty('ZPT_DTREGI', MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'IIF(INCLUI,Date(),ZPT->ZPT_DTREGI)'))//Iniciador de Campo
	
	oStrZPT:SetProperty("ZPT_DOC"	,MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
	oStrZPT:SetProperty("ZPT_DTREGI",MODEL_FIELD_WHEN, FwBuildFeature(STRUCT_FEATURE_WHEN , ".F."))
	
	oStrZPT:SetProperty("ZPT_CODPRD"	,MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'U_VldLPad()'))
	oStrZPT:SetProperty("ZPT_CODDES"	,MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'ExistCpo("SB1",M->ZPT_CODDES)'))
	oStrZPT:SetProperty("ZPT_TIPO"		,MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'U_ClearPrd()'))
	oStrZPT:SetProperty("ZPT_PERCEN"	,MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'U_VldPZp()'))
	
	oModel:AddFields("FORMCAB", /*cOwner*/, oStrZPT)

	oModel:SetPrimaryKey({"ZPT_FILIAL","ZPT_COD"})
	oModel:SetDescription(cDescription)
   
    oModel:InstallEvent("VLD_MODEL", , cPesoOrd():New(oModel))
	
Return oModel

Static Function ViewDef()
	Local oModel 	:= ModelDef()
	Local oView  	:= FWFormView():New()
	Local oStrZPT 	:= FWFormStruct(2, 'ZPT')

	oView:SetModel(oModel)
	oView:AddField("VIEW_CAB", oStrZPT,"FORMCAB")

	//Habilitando título
	oView:EnableTitleView('VIEW_CAB', cDescription)
	oView:AddUserButton( "Balança - (10)" , 'CLIPS', 	{ || AtBalanca(FwModelActive(),FWViewActive()) },"",VK_F10 )
	oView:AddUserButton( "Alterar Produto", 'CLIPS', 	{ || U_PesAltP() },"",VK_F11 )

Return oView

Static Function AtBalanca(oModel,oView)
	Local oMdlCab	      	:= oModel:GetModel('FORMCAB')
	Local nOpc				as numeric
	Local _nPesoLido		as numeric
	Local lPesagManu        := .F.
	Local nPeso1            := oMdlCab:GetValue('ZPT_PESO1')
	Local nPeso2            := oMdlCab:GetValue('ZPT_PESO2')
	Local aParBal           := AGRX003E( .t., 'OGA050001' )

	if Len(aParBal) > 1 .And. !Empty(aParBal[01])
		if oMdlCab:GetValue('ZPT_PESO1')  == 0
			nOpc := 1
		Elseif oMdlCab:GetValue('ZPT_PESO2')  == 0
			nOpc := 2
		Else
			if MsgYesNo('Peso e tara do caminhão preenchidos, deseja informar o peso do caminhão novamente?')
				nOpc := 1
			Else
				nOpc := 2
			Endif
		Endif

		AGRX003A( @_nPesoLido,.T., aParBal, /*cMask*/,@lPesagManu, nPeso1, nPeso2, nOpc )

		IF _nPesoLido > 0
			if nOpc == 1
				oMdlCab:SetValue('ZPT_PESO1' ,	_nPesoLido ) //SZIPE1 //nOpc ==1
				oMdlCab:SetValue('ZPT_DTHRP1',	FWTimeStamp(2)) //SZIPE1 //nOpc ==1
				if ZPT->(FieldPos("ZPT_PEMAN1"))
					oMdlCab:LoadValue('ZPT_PEMAN1',	iif(lPesagManu,"M","A")) //SZIPE1 //nOpc ==1
				EndIf
			Elseif nOpc == 2
				oMdlCab:SetValue('ZPT_PESO2' ,_nPesoLido )  //SZIPES //nOpc ==2
				oMdlCab:SetValue('ZPT_DTHRP2',	FWTimeStamp(2)) //SZIPE1 //nOpc ==1
				if ZPT->(FieldPos("ZPT_PEMAN2"))
					oMdlCab:LoadValue('ZPT_PEMAN2',	iif(lPesagManu,"M","A")) //SZIPE1 //nOpc ==1
				EndIf
			Endif

			//Peso Liquido
			if oMdlCab:GetValue('ZPT_PESO1') > 0 .and. oMdlCab:GetValue('ZPT_PESO2') > 0
				IF oMdlCab:GetValue('ZPT_PESO1') > oMdlCab:GetValue('ZPT_PESO2')
					nTara := oMdlCab:GetValue('ZPT_PESO1') - oMdlCab:GetValue('ZPT_PESO2')
				Else
					nTara := oMdlCab:GetValue('ZPT_PESO2') - oMdlCab:GetValue('ZPT_PESO1')
				EndIf

				oMdlCab:SetValue('ZPT_PESOL',nTara )
			EndIf
		ELSE
			MsgAlert('Peso retornado da balança inválido.')
		EndIF
	EndIF

	oView:Refresh()
Return

User Function VldPZp()
	Local aArea 	:= FWGetArea()
	Local lRet 		:= .T.
	Local oModel	:= FWModelActive()
	Local oMdlCab 	:= oModel:GetModel('FORMCAB')
	Local cAlias	:= GetNextAlias()
	Local cQry 		:= ""
	Local nPropMil	:= SuperGetMV("MV_MSMILH",.f.,.f.)

	if &(ReadVar()) > 0 
		if oMdlCab:GetValue("ZPT_PESOL") > 0 
			cQry := " select *  " + CRLF 
			cQry += " from "+RetSqlName("ZTM")+"  " + CRLF 
			cQry += " WHERE ZTM_PERUMI = "+lTrim(STR(oMdlCab:GetValue("ZPT_PERCEN")))+"  " + CRLF 
			cQry += " AND ZTM_MSBLQL = '2' " + CRLF 
			cQry += " AND ZTM_DATA <= '"+dtoS(oMdlCab:GetValue("ZPT_DTREGI"))+"' " + CRLF 
			cQry += " AND D_E_L_E_T_ = ''  " + CRLF

			MpSysOpenQry(cQry, cAlias)

			if !(cALias)->(EOF(  ))
				if (cAlias)->ZTM_PRMILH >= 1
					oMdlCab:LoadValue("ZPT_QTMILU",Round(oMdlCab:GetValue("ZPT_PESOL"),0))
					oMdlCab:LoadValue("ZPT_QTMILH",Round(oMdlCab:GetValue("ZPT_PESOL"),0))
					oMdlCab:LoadValue("ZPT_QTAGUA",0)
				else
					oMdlCab:LoadValue("ZPT_QTMILU",Round(((oMdlCab:GetValue("ZPT_PESOL") - (oMdlCab:GetValue("ZPT_PESOL") * (nPropMil / (cAlias)->ZTM_TEORMS)))*1) + oMdlCab:GetValue("ZPT_PESOL"),0))
					oMdlCab:LoadValue("ZPT_QTMILH",Round(oMdlCab:GetValue("ZPT_PESOL"),0))
					oMdlCab:LoadValue("ZPT_QTAGUA",Round(((oMdlCab:GetValue("ZPT_PESOL") - (oMdlCab:GetValue("ZPT_PESOL") * (nPropMil / (cAlias)->ZTM_TEORMS)))*1),0))
				endif
			else
				oModel:SetErrorMessage("","","","",	"Registro Inválido", 'Percentual digitado não foi encontrado na tabela ZTM, Verifique a Rotina [Tabela Umidade Milho Úmido]', "") 
				lRet := .F.
			ENDIF

			(cAlias)->(DBCloseArea())
		else 
			oModel:SetErrorMessage("","","","","Campo inválido", 'Percentual não pode ser digitado enquanto o Peso Liquido estiver vazio!', "") 
			lRet := .F.
		ENDIF
	else 
		oModel:SetErrorMessage("","","","","Campo inválido", 'Percentual não pode ser 0', "") 
		lRet := .F.
	ENDIF
	FwRestArea(aArea)
Return lRet 
User Function ClearPrd()
	Local aArea 		:= FWGetArea()
	Local oModel		:= FWModelActive()
	Local oMdlCab 		:= oModel:GetModel('FORMCAB')
	Local cMilhoOri 	:= Alltrim(SuperGetMV("MV_PRDMILH",.f.,"200100001"))
	Local cMilhoDes 	:= Alltrim(SuperGetMV("MV_PESOORD",.f.,"060200082"))
	Local lRet 			:= .T.

	if EMPTY(oMdlCab:GetValue("ZPT_DOC"))
		oMdlCab:LoadValue("ZPT_CODPRD","")
		oMdlCab:LoadValue("ZPT_DESPRD","")
		oMdlCab:LoadValue("ZPT_ARMORI","")
		oMdlCab:LoadValue("ZPT_CODDES","")
		oMdlCab:LoadValue("ZPT_PRDDES","")
		oMdlCab:LoadValue("ZPT_ARMDES","")
		oMdlCab:LoadValue("ZPT_PERCEN",0)

		if oMdlCab:GetValue("ZPT_TIPO") == 'P'

			DBSELECTAREA( "SB1" )
			SB1->(DBSETORDER( 1 ))

			IF SB1->(DBSEEK(FWxFilial("SB1")+Padr(cMilhoOri,TamSx3("B1_COD")[1])))
				oMdlCab:LoadValue("ZPT_CODPRD",SB1->B1_COD)
				oMdlCab:LoadValue("ZPT_ARMORI",SB1->B1_LOCPAD)
				oMdlCab:LoadValue("ZPT_DESPRD",ALLTRIM(SB1->B1_DESC))
			else 
				oModel:SetErrorMessage("","","","","Inválido", "Produto '"+ALLTRIM(cMilhoOri)+"' definido no parâmetro [MV_PESOORD] não encontrado na tabela de Produtos" , "")
				lRet := .f.
			ENDIF

			IF SB1->(DBSEEK(FWxFilial("SB1")+Padr(cMilhoDes,TamSx3("B1_COD")[1])))
				oMdlCab:LoadValue("ZPT_CODDES",SB1->B1_COD)
				oMdlCab:LoadValue("ZPT_ARMDES",SB1->B1_LOCPAD)
				oMdlCab:LoadValue("ZPT_PRDDES",ALLTRIM(SB1->B1_DESC))
			else 
				oModel:SetErrorMessage("","","","","Inválido", "Produto '"+ALLTRIM(cMilhoDes)+"' definido no parâmetro [MV_PRDMILH] não encontrado na tabela de Produtos" , "")
				lRet := .f.
			ENDIF

		endif
	else 
		oModel:SetErrorMessage("","","","","Não permitido", "Campo não pode ser alterado quando há movimentações realizadas!" , "")
		lRet := .F. 
	endif

	FwRestArea(aArea)
Return lRet

User Function VldLPad()
	Local aArea 		:= FWGetArea()
	Local oModel		:= FWModelActive()
	Local oMdlCab 		:= oModel:GetModel('FORMCAB')
	Local lRet 			:= .t. 
	Local nI 

	//Parametros MV_PRDORIG e MV_PRDDEST sao para sugestao de produtos enquanto o Tipo de Registro for Transferencia
	//Os dois parametros deverao ser cadastrado com separadores ';' (Ponto e Virgula)
	
	//A Rotina irá separar os dois parametros com STRTOKARR, cada um em um array
	
	//A 1ª posição do MV_PRDORIG corresponderá com a 1ª posição do MV_PRDDEST
	//Sendo assim, aPrdOrigem[1]  = Produto Origem
	//			   aPrdDestino[1] = Produto Destino
	
	//OBSERVAÇÃO:
	//Se a quantidade de produtos for diferente nos dois parametros, a rotina não irá preencher a sugestão de produto

	Local aPrdOrigem 	:= Strtokarr( SuperGetMV("MV_PRDORIG", .F., ""), ";")
	Local aPrdDestino 	:= Strtokarr( SuperGetMV("MV_PRDDEST", .F., ""), ";")

	DBSelectArea( "SB1" )
	SB1->(DBSetOrder( 1 ))

	if !Empty(oMdlCab:GetValue("ZPT_CODPRD"))
		if oMdlCab:GetValue("ZPT_TIPO") == 'T'
			if SB1->(DBSeek(FWxFilial("SB1")+oMdlCab:GetValue("ZPT_CODPRD")))
				oMdlCab:LoadValue("ZPT_ARMORI",ALLTRIM(SB1->B1_LOCPAD))
 				oMdlCab:LoadValue("ZPT_DESPRD",ALLTRIM(SB1->B1_DESC))

				if Len(aPrdOrigem) == len(aPrdDestino)
					For nI := 1 to Len(aPrdOrigem)
						IF AllTrim(aPrdOrigem[nI]) == RTRIM(oMdlCab:GetValue("ZPT_CODPRD"))
							IF SB1->(DBSeek(FWxFilial("SB1")+PADR(AllTrim(aPrdDestino[nI]),TAMSX3("B1_COD")[1])))
								oMdlCab:LoadValue("ZPT_CODDES",ALLTRIM(SB1->B1_COD))
								oMdlCab:LoadValue("ZPT_PRDDES",ALLTRIM(SB1->B1_DESC))
								oMdlCab:LoadValue("ZPT_ARMDES",ALLTRIM(SB1->B1_LOCPAD))
							else
								MsgInfo("Produto informado ["+AllTrim(aPrdDestino[nI])+"] no parâmetro [MV_PRDDEST] não encontrado!")
							endif
						endif
					next nI
				else
					MsgInfo("Sugestão de produto não será preenchida porque a Quantidade de produtos informados no parametro [MV_PRDORIG] não confere com a quantidade no parametro [MV_PRDDEST]" )
				endif
			else
				oModel:SetErrorMessage("","","","","Inválido", "Produto '"+ALLTRIM(oMdlCab:GetValue("ZPT_CODPRD"))+"' não encontrado na tabela de Produtos" , "")
				lRet := .F.
			endif
		endif
	endif
	
	if !Empty(aArea)
		FwRestArea(aArea)
	endif
Return lRet
User Function PesAltP()
	Local nVlrParam := SuperGetMV("MV_PESOORD",.f.,.f.) 	

	If MsgYesNo("O produto usado para a produção de milho umido é: [" +RTrim(NVlrParam)+ "] Deseja alterar?")
		If Pergunte("PESOORD", .T.)
			if !Empty(MV_PAR01)
				PutMV("MV_PESOORD", ALLTRIM( MV_PAR01 ))

				Alert("Produto alterado para ["+ALLTRIM( MV_PAR01 )+"]")
			endif
		endif 
	endif 
Return
//Estorno de movimentação
User Function PesEstP()
	if ZPT->ZPT_TIPO == 'T'
		ExecAutoPesagem():MT261EST()
	else 
		ExecAutoPesagem():MT650EST()
	endif 
Return 

Class cPesoOrd From FWModelEvent
    Method New() CONSTRUCTOR
	Method ModelPosVld()
EndClass

//Método para "instanciar" um observador
Method New(oModel) CLASS cPesoOrd
Return

Method ModelPosVld() CLASS cPesoOrd
	Local lRet 		:= .T. 
	Local oModel	:= FWModelActive()
	Local oMdlCab 	:= oModel:GetModel('FORMCAB')
	Local nOpc 		:= oModel:GetOperation()
	Local aArea 	:= FwGetArea()
	Local cMsg		:= ""
	Local cAgua		:= Alltrim(SuperGetMV("MV_PRDAGUA",.f.,"060210007"))

	if nOpc == 3 .or. nOpc == 4
		if Empty(oMdlCab:GetValue("ZPT_PESO1"))
			oModel:SetErrorMessage("","","","","Registro Inválido", "Peso 1 não preenchido", "")
			Return .F.
		endif

		if !Empty(oMdlCab:GetValue("ZPT_PESO2"))
			IF oMdlCab:GetValue("ZPT_PESOL") != ABS(oMdlCab:GetValue("ZPT_PESO2") - oMdlCab:GetValue("ZPT_PESO1"))
				oModel:SetErrorMessage("","","","","Registro Inválido", "Peso Liquido não confere com Peso 1 e Peso 2", "")
				Return .F.
			endif
		endif

		if oMdlCab:GetValue("ZPT_TIPO") == 'T'
			if !EMPTY(oMdlCab:GetValue("ZPT_CODPRD"))
				IF !EMPTY(oMdlCab:GetValue("ZPT_CODDES"))
					
					if oMdlCab:GetValue("ZPT_CODPRD") == oMdlCab:GetValue("ZPT_CODDES") .and. oMdlCab:GetValue("ZPT_ARMDES") == oMdlCab:GetValue("ZPT_ARMORI")
						cMsg := "Produto de Origem igual ao Produto de Destino e Armazem de Origem igual a Armazem de Destino, Confirma?"
					elseif oMdlCab:GetValue("ZPT_CODPRD") == oMdlCab:GetValue("ZPT_CODDES") 
						cMsg := "Produto de Origem igual ao Produto de Destino, Confirma?"
					elseif oMdlCab:GetValue("ZPT_ARMDES") == oMdlCab:GetValue("ZPT_ARMORI")
						cMsg := "Armazem de Origem igual a Armazem de Destino, Confirma?"
					endif

					if !Empty(cMsg)
						if !MsgYesNo(cMsg)
							oModel:SetErrorMessage("","","","","Operação Cancelada", "", "")
							RETURN  .F.
						endif
					endif
				else
					oModel:SetErrorMessage("","","","","Registro Inválido", "Preencha o campo Produto de destino!", "")
					RETURN  .F.
				endif
			endif
		endif

		if oMdlCab:GetValue("ZPT_TIPO") == 'P'
			if !Empty(oMdlCab:GetValue("ZPT_PESO2")) .and. Empty(oMdlCab:GetValue("ZPT_PERCEN"))
				oModel:SetErrorMessage("","","","","Percentual vazio", "Não é permitido gerar ordem de produção [Milho Umido] com o campo percentual [ZPT_PERCEN] vazio!", "")
				Return .F.
			endif
		endif

		if EMPTY(oMdlCab:GetValue("ZPT_DOC")) .and. !EMPTY(oMdlCab:GetValue("ZPT_CODPRD")) .and. oMdlCab:GetValue("ZPT_PESOL") > 0
			DBSELECTAREA("SB1")
			SB1->(DBSETORDER(1))

			DBSELECTAREA("SB2")
			SB2->(DBSETORDER(1))

			IF oMdlCab:GetValue("ZPT_TIPO") == 'T'
				IF SB2->(DBSEEK(FWxFilial("SB2")+padr(rtrim(oMdlCab:GetValue("ZPT_CODPRD")),TAMSX3("B2_COD")[1])+oMdlCab:GetValue("ZPT_ARMORI")))
					if SB2->B2_QATU < oMdlCab:GetValue("ZPT_PESOL")
						oModel:SetErrorMessage("","","","","Produto Inválido", "Não há saldo para o produto informado! " + CRLF +;
						"Saldo disponível: ["+LTRIM(TRANSFORM(SB2->B2_QATU,"@E 999,999,999.999999"))+"]" + CRLF +;
						  "Peso Informado: ["+LTRIM(TRANSFORM(oMdlCab:GetValue("ZPT_PESOL"),"@E 999,999,999.999999"))+"]", "") 
						SB1->(DBCloseArea())
						SB2->(DBCloseArea())
						Return .F.
					endif 
				else
					oModel:SetErrorMessage("","","","","Produto Inválido", "Produto não encontrado na Tabela SB2", "") 
					SB1->(DBCloseArea())
					SB2->(DBCloseArea())
					Return .F.
				ENDIF
			ELSE
				
				IF SB1->(DBSEEK( FWxFilial("SB1")+PADR(oMdlCab:GetValue("ZPT_CODPRD"),TAMSX3("B1_COD")[1])))
					IF SB2->(DBSEEK(FWxFilial("SB2")+PADR(oMdlCab:GetValue("ZPT_CODPRD"),TAMSX3("B1_COD")[1])+oMdlCab:GetValue("ZPT_ARMORI")))
						if SB2->B2_QATU < oMdlCab:GetValue("ZPT_QTMILH")
							oModel:SetErrorMessage("","","","","Produto Inválido", "Não há saldo para o produto "+RTrim(oMdlCab:GetValue("ZPT_CODPRD"))+" - MILHO! " + CRLF +;
							"Saldo disponível: ["+LTRIM(TRANSFORM(SB2->B2_QATU,"@E 999,999,999.999999"))+"]" + CRLF +;
							"Peso Informado: ["+LTRIM(TRANSFORM(oMdlCab:GetValue("ZPT_QTMILH"),"@E 999,999,999.999999"))+"]", "") 
							SB2->(DBCloseArea())
							Return .F.
						endif
					else
						oModel:SetErrorMessage("","","","","Produto Inválido", "Produto "+RTrim(oMdlCab:GetValue("ZPT_CODPRD"))+" - MILHO não encontrado na Tabela SB2", "") 
						SB1->(DBCloseArea())
						SB2->(DBCloseArea())
						Return .F.
					ENDIF
				else
					oModel:SetErrorMessage("","","","","Produto Inválido", "Produto "+RTrim(oMdlCab:GetValue("ZPT_CODPRD"))+" - MILHO não encontrado na Tabela SB1", "") 
					SB1->(DBCloseArea())
					SB2->(DBCloseArea())
					Return .F.
				ENDIF

				if oMdlCab:GetValue("ZPT_QTAGUA") > 0
					IF SB1->(DBSEEK( FWxFilial("SB1")+PADR(cAgua,TAMSX3("B1_COD")[1])))
						IF SB2->(DBSEEK(FWxFilial("SB2")+SB1->B1_COD+SB1->B1_LOCPAD))
							if SB2->B2_QATU < oMdlCab:GetValue("ZPT_QTAGUA")
								oModel:SetErrorMessage("","","","","Produto Inválido", "Não há saldo para o produto "+cAgua+" - AGUA! " + CRLF +;
							    "Saldo disponível: ["+LTRIM(TRANSFORM(SB2->B2_QATU				  ,"@E 999,999,999.999999"))+"]" + CRLF +;
								"Peso Informado: ["+LTRIM(TRANSFORM(oMdlCab:GetValue("ZPT_QTAGUA"),"@E 999,999,999.999999"))+"]", "") 
								SB1->(DBCloseArea())
								SB2->(DBCloseArea())
								Return .F.
							endif
						else
							oModel:SetErrorMessage("","","","","Produto Inválido", "Produto "+cAgua+" - AGUA não encontrado na Tabela SB2", "") 
							SB1->(DBCloseArea())
							SB2->(DBCloseArea())
							Return .F.
						ENDIF
					else
						oModel:SetErrorMessage("","","","","Produto Inválido", "Produto "+cAgua+" - AGUA não encontrado na Tabela SB1", "")
						SB1->(DBCloseArea())
						SB2->(DBCloseArea())
						Return .F.
					ENDIF 
				ENDIF 
			ENDIF 
			SB1->(DBCloseArea())
			SB2->(DBCloseArea())

			lRet := ExecAutoPesagem:lExecAuto()
		endif
	elseif nOpc == 5
		if !Empty(oMdlCab:GetValue("ZPT_DOC"))
			oModel:SetErrorMessage("","","","","Exclusão não permitida", "Não é permitido excluir registros com movimentação realizada.", "")
			lRet := .f.
		endif 
	endif

	FwRestArea(aArea)
Return lRet

Class ExecAutoPesagem from LongClassName
    Method New() CONSTRUCTOR
    Method lExecAuto()	//INCLUSÃO
    Method MT261IN()	//INCLUSÃO
    Method MT261EST()	//ESTORNO
    Method MT650IN()	//INCLUSÃO
    Method MT650EST()	//ESTORNO
EndClass

Method New(oModel) CLASS ExecAutoPesagem
Return

Method lExecAuto(oModel) Class ExecAutoPesagem
	Local oModel	:= FWModelActive()
	Local oMdlCab 	:= oModel:GetModel('FORMCAB')
	Local lRet 		:= .T.

	Private lMsErroAuto := .F.

	if oMdlCab:GetValue("ZPT_TIPO") == 'T'
		lRet := self:MT261IN() //CHAMADA DO MATA261 INCLUSAO
	else
		lRet := self:MT650IN() //CHAMADA DO MATA650 INCLUSAO
	endif
Return lRet

Method MT261IN(oModel) Class ExecAutoPesagem
	Local aArea 		:= FWGetArea()
	Local aAuto 		:= {}
	Local aLinha 		:= {}
	Local cDocumen 		:= ""
	Local lRet 			:= .T. 
	Local oModel		:= FWModelActive()
	Local oMdlCab 		:= oModel:GetModel('FORMCAB')

	lMsErroAuto := .F.
	cDocumen := FWxFilial('ZPT') + oMdlCab:GetValue("ZPT_CODIGO") + oMdlCab:GetValue("ZPT_TIPO")
	aadd(aAuto,{cDocumen,dDataBase}) //Cabecalho

	aLinha := {}

	//Origem
	SB1->(DbSeek(xFilial("SB1")+PadR(oMdlCab:GetValue("ZPT_CODPRD"), tamsx3('D3_COD') [1])))
	aadd(aLinha,{"ITEM"			,'00'+cvaltochar(1)							, Nil})
	aadd(aLinha,{"D3_COD"		, SB1->B1_COD								, Nil}) //Cod Produto origem
	aadd(aLinha,{"D3_DESCRI"	, SB1->B1_DESC								, Nil}) //descr produto origem
	aadd(aLinha,{"D3_UM"		, SB1->B1_UM								, Nil}) //unidade medida origem
	aadd(aLinha,{"D3_LOCAL" 	, oMdlCab:GetValue("ZPT_ARMORI")			, Nil}) //armazem origem
	aadd(aLinha,{"D3_LOCALIZ"	, PadR("ENDER01", tamsx3('D3_LOCALIZ') [1]) , Nil}) //Informar endereÃ§o origem
	
	//Destino
	SB1->(DbSeek(xFilial("SB1")+PadR(oMdlCab:GetValue("ZPT_CODDES"), tamsx3('D3_COD') [1])))
	aadd(aLinha,{"D3_COD"		, SB1->B1_COD									, Nil}) //cod produto destino
	aadd(aLinha,{"D3_DESCRI"	, SB1->B1_DESC									, Nil}) //descr produto destino
	aadd(aLinha,{"D3_UM"		, SB1->B1_UM									, Nil}) //unidade medida destino
	aadd(aLinha,{"D3_LOCAL"		, oMdlCab:GetValue("ZPT_ARMDES")				, Nil}) //armazem destino
	aadd(aLinha,{"D3_LOCALIZ"	, PadR("ENDER02", tamsx3('D3_LOCALIZ') [1]) 	, Nil}) //Informar endereÃ§o destino
	
	aadd(aLinha,{"D3_NUMSERI", ""							, Nil}) //Numero serie
	aadd(aLinha,{"D3_LOTECTL", ""							, Nil}) //Lote Origem
	aadd(aLinha,{"D3_NUMLOTE", ""							, Nil}) //sublote origem
	aadd(aLinha,{"D3_DTVALID", ''							, Nil}) //data validade
	aadd(aLinha,{"D3_POTENCI", 0 							, Nil}) // Potencia
	aadd(aLinha,{"D3_QUANT"  , oMdlCab:GetValue("ZPT_PESOL")	, Nil}) //Quantidade
	aadd(aLinha,{"D3_QTSEGUM", 0 							, Nil}) //Seg unidade medida
	aadd(aLinha,{"D3_ESTORNO", ""							, Nil}) //Estorno
	aadd(aLinha,{"D3_NUMSEQ" , ""							, Nil}) // Numero sequencia D3_NUMSEQ
	
	aadd(aLinha,{"D3_LOTECTL", "", Nil}) //Lote destino
	aadd(aLinha,{"D3_NUMLOTE", "", Nil}) //sublote destino
	aadd(aLinha,{"D3_DTVALID", '', Nil}) //validade lote destino
	aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade
	
	aAdd(aAuto,aLinha)

	MSExecAuto({|x,y| mata261(x,y)},aAuto,3)

	if lMsErroAuto
		MostraErro()
		lRet := .F. 
	else
		SD3->(DBSETORDER( 2 ))
		SD3->(DBSEEK( xFilial("SD3")+cDocumen+oMdlCab:GetValue("ZPT_CODPRD")))
		
		oMdlCab:LoadValue("ZPT_DOC"	 ,SD3->D3_DOC)
		oMdlCab:LoadValue("ZPT_NUMSE",SD3->D3_NUMSEQ)

		MsgAlert("Inclusão de movimentação multipla efetuada com sucesso")
	EndIf

	if SELECT("SD3") > 0 
		SD3->(DBCLOSEAREA(  ))
	endif

	FwRestArea(aArea)
Return lRet

Method MT261EST(oModel) Class ExecAutoPesagem	
	Local aArea 	:= FwGetArea()
	Local aAuto 	:= {}
	Local lRet  	:= .T.

	lMsErroAuto := .F.
	
	aadd(aAuto,{"D3_FILIAL"	, ZPT->ZPT_FILIAL	, Nil})
	aadd(aAuto,{"D3_DOC"	, ZPT->ZPT_DOC		, Nil})
	aadd(aAuto,{"D3_COD"	, ZPT->ZPT_CODPRD	, Nil})
	
	DbSelectArea("SD3")
	DbSetOrder(2)
	DbSeek(xFilial("SD3")+ZPT->ZPT_DOC+ZPT->ZPT_CODPRD)

	MSExecAuto({|x,y| mata261(x,y)},aAuto,6)
	
	If lMsErroAuto
		MostraErro()
		CONOUT("ERRO02")
		lRet := .F. 
	Else
		reclock("ZPT",.F.)
			ZPT->ZPT_DOC 	:= ""
			ZPT->ZPT_NUMSE 	:= ""
		ZPT->(MSUNLOCK())

		MsgAlert("Estorno de movimentação multipla efetuada com sucesso")
	EndIf

	FwRestArea(aArea)
Return
//060200082
Method MT650IN(oModel) Class ExecAutoPesagem
	Local aArea 	:= FwGetArea()
	Local lRet 		:= .T. 
	Local aExec 	:= {}  //-Array com os campos
    Local aCab      := {}
    Local aLine     := {}
    Local aItens    := {}
	Local nOpc 		:= 3
	Local cTM 		:= SuperGetMV("MV_PESOTM",.f.,.f.)
	Local cAgua		:= Alltrim(SuperGetMV("MV_PRDAGUA",.f.,"060210007"))
	Local oModel	:= FWModelActive()
	Local oMdlCab 	:= oModel:GetModel('FORMCAB')
	Local cOp, cDocumen,cProd

	lMsErroAuto := .F.

	DbSelectArea("SD3")
	SD3->(DbSetOrder(1)) // D3_FILIAL+D3_OP+D3_COD+D3_LOCAL

	DbSelectArea("SC2")
	SC2->(DbSetOrder(1)) // C2_FILIAL + C2_NUM + C2_SEQUEN + C2_ITEMGRD

	DbSelectArea("SD4")
	SD4->(DbSetOrder(1)) // D4_FILIAL+D4_COD+D4_OP+D4_TRT+D4_LOTECTL+D4_NUMLOTE

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD

	Begin Transaction
		SB1->(DBSEEK( FWxFilial("SB1")+oMdlCab:GetValue("ZPT_CODDES")))

		aExec := {  {'C2_FILIAL' 	, FWxFilial("ZPT") 					,NIL},;
					{'C2_ITEM' 		, "01" 								,NIL},; 
					{'C2_SEQUEN' 	, "001" 							,NIL},;
					{'C2_TES' 		, cTM 								,NIL},;
					{'C2_PRODUTO' 	, oMdlCab:GetValue("ZPT_CODDES") 	,NIL},;
					{"C2_UM"		, SB1->B1_UM						,Nil},; 
					{'C2_LOCAL' 	, oMdlCab:GetValue("ZPT_ARMDES") 	,NIL},;
					{'C2_QUANT' 	, oMdlCab:GetValue("ZPT_QTMILU")	,NIL},;
					{'C2_DATPRI' 	, oMdlCab:GetValue("ZPT_DTREGI") 	,NIL},;
					{'C2_DATPRF' 	, oMdlCab:GetValue("ZPT_DTREGI") 	,NIL},;
					{'C2_EMISSAO' 	, oMdlCab:GetValue("ZPT_DTREGI") 	,NIL},;
					{'AUTEXPLODE' 	, "N" 								,NIL}}

		msExecAuto({|x,Y| Mata650(x,Y)},aExec,nOpc)
		If lMsErroAuto
			RollbackSX8()
			MostraErro()
			lRet := .F. 
			DisarmTransaction()
		Else
			lMsErroAuto := .F.
			
			SC2->(DbSeek(xFilial("SC2")+SC2->C2_NUM))

			cOp 	:= SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN
			aCab 	:= {{"D4_OP",cOp,NIL}}
			cProd  	:= PADR(oMdlCab:GetValue("ZPT_CODPRD"),Len(SC2->C2_PRODUTO))

			IF SB1->(DBSEEK( FWxFilial("SB1")+cProd))
				aLine := {}
				aAdd(aLine,{"D4_OP"     , cOp     		  				,NIL})
				aAdd(aLine,{"D4_COD"    , cProd            				,NIL})
				aAdd(aLine,{"D4_LOCAL"  , oMdlCab:GetValue("ZPT_ARMORI"),NIL})
				aAdd(aLine,{"D4_DATA"   , oMdlCab:GetValue("ZPT_DTREGI"),NIL})
				aAdd(aLine,{"D4_QTDEORI", oMdlCab:GetValue("ZPT_QTMILH"),NIL})
				aAdd(aLine,{"D4_QUANT"  , oMdlCab:GetValue("ZPT_QTMILH"),NIL})
				aAdd(aLine,{"D4_TRT"    , "001"             			,NIL})
				aAdd(aItens,aLine)
			ELSE
				MsgStop("Produto Milho não encontrado!")
				RollbackSX8()
				lRet:= .F.
				DisarmTransaction()
			ENDIF

			if oMdlCab:GetValue("ZPT_QTAGUA") > 0
				cProd  := PADR(cAgua,Len(SC2->C2_PRODUTO))

				IF SB1->(DBSEEK( FWxFilial("SB1")+cProd))
					aLine := {}
					aAdd(aLine,{"D4_OP"     , cOp     		  				,NIL})
					aAdd(aLine,{"D4_COD"    , cProd            				,NIL})
					aAdd(aLine,{"D4_LOCAL"  , SB1->B1_LOCPAD             	,NIL})
					aAdd(aLine,{"D4_DATA"   , oMdlCab:GetValue("ZPT_DTREGI"),NIL})
					aAdd(aLine,{"D4_QTDEORI", oMdlCab:GetValue("ZPT_QTAGUA"),NIL})
					aAdd(aLine,{"D4_QUANT"  , oMdlCab:GetValue("ZPT_QTAGUA"),NIL})
					aAdd(aLine,{"D4_TRT"    , "001"             			,NIL})
					aAdd(aItens,aLine)
				ELSE 
					MsgStop("Produto água não encontrado!")
					RollbackSX8()
					lRet := .F.
					DisarmTransaction()
				ENDIF
			ENDIF

			MSExecAuto({|x,y,z| mata381(x,y,z)}, aCab, aItens, nOpc)
		
			If lMsErroAuto
				RollbackSX8()
				MostraErro()
				DisarmTransaction()
				lRet := .F.
			else 
				aExec := {}
				cDocumen := FWxFilial('ZPT') + oMdlCab:GetValue("ZPT_CODIGO") + oMdlCab:GetValue("ZPT_TIPO")
				
				aExec := {  {"D3_OP" 		, cOp												,NIL},; 
							{"D3_COD" 		, oMdlCab:GetValue("ZPT_CODDES")					,NIL},;
							{"D3_DOC" 		, cDocumen 											,NIL},;
							{"D3_QUANT" 	, oMdlCab:GetValue("ZPT_QTMILU")					,NIL},; 
							{"D3_TM" 		, cTM  												,NIL}}
				
				MSExecAuto({|x, y| mata250(x, y)},aExec, nOpc )

				If lMsErroAuto
					RollbackSX8()
					MostraErro()
					lRet := .F.
					DisarmTransaction()
				Else
					ConfirmSX8()

					SD3->(DBSETORDER( 2 ))
					SD3->(DBSEEK( FWxFilial("SD3")+cDocumen+oMdlCab:GetValue("ZPT_CODDES")))
					
					oMdlCab:LoadValue("ZPT_OP" 	 , SD3->D3_OP)
					oMdlCab:LoadValue("ZPT_DOC"	 , SD3->D3_DOC)
					oMdlCab:LoadValue("ZPT_NUMSE", SD3->D3_NUMSEQ)

					MsgAlert("Ordem de Produção incluída com sucesso.")
				Endif
			ENDIF
			
			ConOut("Fim : "+Time())
		endif
	End Transaction 
	
    //Aqui você pode fazer as operações após gravar
	if !Empty(aArea)
		FwRestArea(aArea)
	endif
Return lRet 

Method MT650EST(oModel) Class ExecAutoPesagem
	Local aArea 	:= FwGetArea()
	Local aVetor 	:= {}
	Local lRet 		:= .T. 
	Local nOpc 		:= 5
	
	lMsErroAuto 	:= .F. 
	
	DbSelectArea("SD3")
	DbSetOrder(2) // D3_FILIAL+D3_OP+D3_COD+D3_LOCAL

	DbSelectArea("SC2")
	DbSetOrder(1) // C2_FILIAL + C2_NUM + C2_SEQUEN + C2_ITEMGRD

	DbSelectArea("SB1")
	DbSetOrder(1) // B1_FILIAL + B1_COD

	Begin Transaction
		if !EMPTY(ZPT->ZPT_DOC)
			cChave := FWxFilial('SD3')+PADR(ZPT->ZPT_DOC,TAMSX3("D3_DOC")[1])+PADR(ZPT->ZPT_CODDES,TAMSX3("D3_COD")[1])
			If SD3->(DbSeek(cChave))
				While !(SD3->(Eof())) .And. SD3->(D3_FILIAL + D3_DOC + D3_COD ) == cChave
					If SD3->D3_ESTORNO == " "
						aVetor := { {"D3_OP" 	, SD3->D3_OP 	,NIL},;
									{"D3_CF" 	, SD3->D3_CF 	,NIL},;
									{"D3_QUANT" , SD3->D3_QUANT ,NIL},;
									{"D3_TM" 	, SD3->D3_TM	,NIL},;
									{"ABREOP" 	, "S"			,NIL}}
		
						MSExecAuto({|x, y| mata250(x, y)},aVetor, nOpc )     
						If lMsErroAuto
							Mostraerro()
							lRet := .f.
							DisarmTransaction()
						Else
							if SC2->(DBSEEK( FWxFilial("SC2")+ZPT->ZPT_OP+"001"))
								
								aVetor := { {'C2_FILIAL' 	, SC2->C2_FILIAL	,NIL},;
											{'C2_NUM' 		, SC2->C2_NUM		,NIL},;
											{'C2_ITEM' 		, SC2->C2_ITEM 		,NIL},; 
											{'C2_SEQUEN' 	, SC2->C2_SEQUEN 	,NIL},;
											{'AUTEXPLODE' 	, "S" 				,NIL}} 

								msExecAuto({|x,Y| Mata650(x,Y)},aVetor,nOpc)

								If lMsErroAuto
									Mostraerro()
									lRet := .f.
									DisarmTransaction()
								Else
									RECLOCK("ZPT",.F.)
										ZPT->ZPT_DOC	:= ""
										ZPT->ZPT_NUMSE	:= ""
										ZPT->ZPT_OP		:= ""
									ZPT->(MSUNLOCK())
									
									MsgAlert("Estorno de Ordem de Produção realizado com sucesso.")
								Endif
							else 
								MSGSTOP("Ordem de produção não encontrada!")
								lRet := .f.
								DisarmTransaction()
							Endif
						Endif
				Exit
					EndIf
				SD3->(DbSkip()) 
				ENDDO
			else 
				MSGSTOP("Movimentação não encontrada!")
				lRet := .f. 
				DisarmTransaction()
			EndIf
		EndIf
	End Transaction

	if !Empty(aArea)
		FwRestArea(aArea)
	endif
Return lRet

Static Function GeraX1(cPerg)
	Local _aArea	:= GetArea()
	Local aRegs     := {}
	Local nX		:= 0
	Local nPergs	:= 0
	Local j,i

	//Conta quantas perguntas existem ualmente.
	DbSelectArea('SX1')
	DbSetOrder(1)
	SX1->(DbGoTop())
	If SX1->(DbSeek(cPerg))
		While !SX1->(Eof()) .And. X1_GRUPO = cPerg
			nPergs++
			SX1->(DbSkip())
		EndDo
	EndIf

	aAdd(aRegs,{cPerg, "01", "Produto:  		" , "", "", "MV_CH1", "C", TamSX3("ZPT_CODPRD")[1]  , TamSX3("ZPT_CODPRD")[2]  	, 0, "G", "NaoVazio", "MV_PAR01", "","","","","",""   ,"","","","","","","","","","","","","","","","","","","","","","","",""})

	//Se quantidade de perguntas for diferente, apago todas
	SX1->(DbGoTop())  
	If nPergs <> Len(aRegs)
		For nX:=1 To nPergs
			If SX1->(DbSeek(cPerg))		
				If RecLock('SX1',.F.)
					SX1->(DbDelete())
					SX1->(MsUnlock())
				EndIf
			EndIf
		Next nX
	EndIf

	// gravação das perguntas na tabela SX1
	If nPergs <> Len(aRegs)
		dbSelectArea("SX1")
		dbSetOrder(1)
		For i := 1 to Len(aRegs)
			If !dbSeek(cPerg+aRegs[i,2])
				RecLock("SX1",.T.)
					For j := 1 to FCount()
						If j <= Len(aRegs[i])
							FieldPut(j,aRegs[i,j])
						Endif
					Next j
				MsUnlock()
			EndIf
		Next i
	EndIf
	RestArea(_aArea)
Return nil

User Function IniCZPT()
	Local aArea 	:= FwGetArea()
	Local cAlias	:= GetNextAlias()
	Local cQry 		:= ''
	
	cQry := "SELECT MAX(ZPT_CODIGO)+1 AS ZPT_CODIGO FROM "+RetSqlName("ZPT")+" WHERE ZPT_FILIAL = '"+FWxFilial("ZPT")+"'"

	MpSysOpenQry(cQry,cAlias)

	if !(cALias)->(EOF())
		cRet := StrZero((cALias)->ZPT_CODIGO,TamSx3("ZPT_CODIGO")[1])
	else
		cRet := StrZero("1",TamSx3("ZPT_CODIGO")[1])
	endif 

	(cAlias)->(DBCloseArea())

	FWRestArea(aArea)
return cRet
