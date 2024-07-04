#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WWIS0004

WMS 100% - Integraçãoes de Saídas do Protheus para o WIS 

@author  Allan Constantino Bonfim
@since   04/04/2018
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
User Function WWIS0004()

Local aArea		:= GetArea()
Local oBrowse

oBrowse := FWMarkBrowse():New()
oBrowse:SetAlias("ZWK")
oBrowse:SetDescription("Saídas - Envio para o WIS")
oBrowse:DisableDetails()

oBrowse:AddLegend("EMPTY(ZWK_STATUS)"		, "BR_PRETO"		, "Erro Inderteminado")
oBrowse:AddLegend("VAL(ZWK_STATUS) > 50 "	, "BR_VERMELHO"	, "Integração com erro")
oBrowse:AddLegend("VAL(ZWK_STATUS) < 50 "	, "BR_AMARELO"	, "Integração em andamentto")
oBrowse:AddLegend("VAL(ZWK_STATUS) = 50 "	, "BR_VERDE"		, "Integração concluída")

//ADD STATUSCOLUMN oColumn DATA {|| If (ZWK_STATUS == '01', "LBOK", "LBNO") } DOUBLECLICK {|oBrowse|}  OF oBrowse
//oBrowse:AddStatusColumns(< bStatus >, {|oBrowse|})-> NIL

oBrowse:Activate()

RestArea(aArea)

Return         


//-------------------------------------------------------------------
/*/{Protheus.doc} MENUDEF

MenuDef - Padrão MVC

@author  Allan Constantino Bonfim
@since   04/04/2018
@version P12
@return array, Funções da Rotina

/*/
//-------------------------------------------------------------------   
Static Function MENUDEF()

Local aRotina 	:= {} 

ADD OPTION aRotina TITLE "Pesquisar"	ACTION "PesqBrw"          	OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.WWIS0004"	OPERATION 2 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"		ACTION "VIEWDEF.WWIS0004" 	OPERATION 3 ACCESS 0 
ADD OPTION aRotina TITLE "Alterar"		ACTION "VIEWDEF.WWIS0004" 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Reprocessar"	ACTION "U_WWIS4REP"		 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"		ACTION "VIEWDEF.WWIS0004" 	OPERATION 5 ACCESS 0
					
Return aRotina     


//-------------------------------------------------------------------
/*/{Protheus.doc} MODELDEF

ModelDef - Padrão MVC

@author  Allan Constantino Bonfim
@since   04/04/2018
@version P12
@return objeto, Objeto do Model

/*/
//-------------------------------------------------------------------   
STATIC FUNCTION MODELDEF()

Local oStruct1
Local oStruct2
//Local oStruct3
Local oModel

oModel		:= MPFormModel():New("WWIS04MOD",, /*{|oModel| WWI4VLD(oModel)}*/, {|oModel| WWIS4GRV(oModel)})
 
oStruct1	:= FWFormStruct(1, "ZWK")
oStruct2	:= FWFormStruct(1, "ZWL")
//oStruct3	:= FWFormStruct(1, "ZWH")

//Estrutura Model
oModel:AddFields("ZWK_SAIDAS",, oStruct1)
oModel:AddGrid("ZWL_SAIDAS", "ZWK_SAIDAS", oStruct2)
//oModel:AddGrid("ZWH_ERROS", "ZWK_SAIDAS", oStruct3)

oModel:GetModel("ZWL_SAIDAS"):SetOptional(.T.)
//oModel:GetModel("ZWH_ERROS"):SetOptional(.T.)

oModel:SetRelation("ZWL_SAIDAS", {{"ZWL_FILIAL", "xFilial('ZWL')"}, {"ZWL_EMPRES", "ZWK_EMPRES"}, {"ZWL_CODIGO", "ZWK_CODIGO"}, {"ZWL_DEPOSI", "ZWK_DEPOSI"}, {"ZWL_PROCES", "ZWK_PROCES"}, {"ZWL_SITUAC", "ZWK_SITUAC"}}, "ZWL_FILIAL+ZWL_EMPRES+ZWL_CODIGO+ZWL_DEPOSI+ZWL_PROCES+ZWL_SITUAC")
////oModel:SetRelation("ZWL_SAIDAS", {{"ZWL_FILIAL", "xFilial('ZWL')"}, {"ZWL_EMPRES", "ZWK_EMPRES"}, {"ZWL_CODIGO", "ZWK_CODIGO"}, {"ZWL_PROCES", "ZWK_PROCES"}, {"ZWL_SITUAC", "ZWK_SITUAC"}}, ZWL->(IndexKey(1)))
oModel:GetModel("ZWL_SAIDAS"):SetUniqueLine({"ZWL_FILIAL","ZWL_EMPRES", "ZWL_DEPOSI", "ZWL_CODIGO", "ZWL_ITEM", "ZWL_SITUAC"})

//oModel:SetRelation("ZWH_ERROS", {{"ZWH_FILIAL", "xFilial('ZWH')"}, {"ZWH_EMPRES", "ZWK_EMPRES"}, {"ZWH_CODIGO", "ZWK_CODIGO"},  {"ZWH_DEPOSI", "ZWK_DEPOSI"}, {"ZWH_PROCES", "ZWK_PROCES"}, {"ZWH_SITUAC", "ZWK_SITUAC"}}, "ZWH_FILIAL+ZWH_EMPRES+ZWH_CODIGO+ZWH_DEPOSI+ZWH_PROCES+ZWH_SITUAC")
    
//oModel:SetPrimaryKey({})
//oModel:SetActivate({|oModel| FINA694Act(oModel)})

Return oModel


//-------------------------------------------------------------------
/*/{Protheus.doc} VIEWDEF

ViewDef - Padrão MVC

@author  Allan Constantino Bonfim
@since   04/04/2018
@version P12
@return objeto, Objeto da View

/*/
//-------------------------------------------------------------------   
STATIC FUNCTION VIEWDEF()

Local oStruct1
Local oStruct2
Local oModel
Local oView

oModel    := FWLoadModel("WWIS0004") //Chamada do model utilizando o nome do fonte (PRW)

oStruct1	:= FWFormStruct(2, "ZWK")
oStruct2	:= FWFormStruct(2, "ZWL")

oView     := FWFormView():New() //View da MVC

oView:SetModel(oModel)

//Estrutura View
oView:AddField("VIEW_ZWK", oStruct1, "ZWK_SAIDAS")
oView:AddGrid("VIEW_ZWL", oStruct2, "ZWL_SAIDAS")

//Formatação da Tela
oView:CreateHorizontalBox("BOXZWK"	, 40)
oView:CreateHorizontalBox("BOXZWL"	, 60)

oView:SetOwnerView("VIEW_ZWK"	, "BOXZWK")
oView:SetOwnerView("VIEW_ZWL"	, "BOXZWL")

oView:AddIncrementField("VIEW_ZWL", "ZWL_ITEM")

oView:SetCloseOnOk({|| .T.})

Return oView


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WIIWSAI

Rotina para geração da Interface de Integração de Saída PROTHEUS -> WIS.

@author Allan Constantino Bonfim
@since  06/04/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WIIWSAI(cAliasA, nOper, aDadosCab, aDadosItem, lSeek)

Local aArea			:= GetArea()
Local lRet				:= .T.
Local aLog				:= {}
Local aLogTMP			:= {}
Local cModel			:= "WWIS0004"
Local cIdMdlCb		:= "ZWK_SAIDAS"
Local cIdModelI		:= "ZWL_SAIDAS"
Local cCodigo			:= ""
Local cStatus			:= ""
Local cEmpWis			:= ""
Local cFilWis			:= ""
Local cSituac			:= ""
Local nPosCpo			:= 0
Local cDescErro		:= ""
Local nRecTab			:= 0
Local cAliasX			:= ""
Local nX				:= 0
Local lGrvLogOk		:= GetMv("MV_ZZWMSLT",, .T.)

Private aRotina		:= MENUDEF()
Private lMsErroAuto	:= .F.
Private oMdlZWK

Default cAliasA		:= "ZWK"
Default nOper 		:= 1
Default aDadosCab		:= {}
Default aDadosItem	:= {}
Default lSeek			:= .T.

lRet := Len(aDadosCab) > 0

If lRet

	Begin Transaction
		
		oMdlZWK 	:= FWLoadModel(cModel)
		
		If Len(aDadosItem) > 0			
			FWMVCRotAuto(oMdlZWK, "ZWK", nOper, {{cIdMdlCb, aDadosCab}, {cIdModelI, aDadosItem}}, lSeek) //Model //Alias //Operacao //Dados
		Else
			FWMVCRotAuto(oMdlZWK, "ZWK", nOper, {{cIdMdlCb, aDadosCab}}, lSeek) //Model //Alias //Operacao //Dados
		EndIf
	
	    //Se houve erro no ExecAuto, mostra mensagem
	    If lMsErroAuto
	    	lRet := .F.
	
				// A estrutura do vetor com erro é:
				//  [1] Id do formulário de origem
				//  [2] Id do campo de origem
				//  [3] Id do formulário de erro
				//  [4] Id do campo de erro
				//  [5] Id do erro
				//  [6] mensagem do erro
				//  [7] mensagem da solução
				//  [8] Valor atribuido
				//  [9] Valor anterior
				
	     	aLogTMP := oMdlZWK:GetErrorMessage()   

	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWK_EMPRES"}) 	
	    	If nPosCpo > 0
	    		cEmpWis := aDadosCab[nPosCpo][2]
	    	EndIf
	    		    	
	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWK_DEPOSI"}) 	
	    	If nPosCpo > 0
	    		cFilWis := aDadosCab[nPosCpo][2]
	    	EndIf
	    	
	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWK_CODIGO"})   	
	    	If nPosCpo > 0
	    		cCodigo := aDadosCab[nPosCpo][2]
	    	EndIf

	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWK_SITUAC"})   	
	    	If nPosCpo > 0
	    		cSituac := aDadosCab[nPosCpo][2]
	    	EndIf
	    		    	
	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWK_CALIAS"}) 	
	    	If nPosCpo > 0
	    		cAliasX := aDadosCab[nPosCpo][2]
	    	EndIf
	    	    	
	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWK_RECORI"})   	
	    	If nPosCpo > 0
	    		nRecTab := aDadosCab[nPosCpo][2]
	    	EndIf
			
	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWK_STATUS"})   	
	    	If nPosCpo > 0
	    		cStatus := aDadosCab[nPosCpo][2]
	    	EndIf
	    				
	    	AADD(aLog, {"ZWH_FILIAL"	, xFilial("ZWH"), Nil})
			AADD(aLog, {"ZWH_EMPRES"	, cEmpWis, Nil})
			AADD(aLog, {"ZWH_DEPOSI"	, cFilWis, Nil})	 
   			AADD(aLog, {"ZWH_CODIGO"	, cCodigo, Nil})
			AADD(aLog, {"ZWH_SITUAC"	, cSituac, Nil})
	    	AADD(aLog, {"ZWH_DATA"	, dDatabase, Nil})
	    	AADD(aLog, {"ZWH_HORA"	, Substr(TIME(),1, TamSx3("ZWH_HORA")[01]), Nil})    	
	    	AADD(aLog, {"ZWH_TPOCOR"	, "1", Nil})
	    	AADD(aLog, {"ZWH_CALIAS"	, cAliasX, Nil})
	    	AADD(aLog, {"ZWH_RECORI"	, nRecTab, Nil})
	    	AADD(aLog, {"ZWH_FUNAME"	, "WIIWSAI", Nil})
	    	
			If nOper == 4
				If cStatus == "07"
					AADD(aLog, {"ZWH_STATUS"	, "93", Nil})
					AADD(aLog, {"ZWH_ERRO"	, "ERRO NA ATUALIZACAO DO REGISTRO DE FINALIZACAO - SITUACAO 3 - AVISO DE FATURAMENTO. (WIS -> PROTHEUS).", Nil})
					AADD(aLog, {"ZWH_ERRTEC"	, "FALHA NA GERACAO DA TABELA INTEGRADORA ZWK/ZWL - SITUACAO 3 - AVISO DE FATURAMENTO. (WIS -> PROTHEUS)", Nil})				
				Else
					AADD(aLog, {"ZWH_STATUS"	, "97", Nil})
					AADD(aLog, {"ZWH_ERRO"	, "ERRO NA ATUALIZACAO DO PROCESSAMENTO DO RETORNO DA INTERFACE DO WIS. (WIS -> PROTHEUS).", Nil})
					AADD(aLog, {"ZWH_ERRTEC"	, "FALHA NA ATUALIZACAO DA TABELA INTEGRADORA DO RETORNO DA INTERFACE DO WIS. (WIS -> PROTHEUS)", Nil})
				EndIf	        	
			//ElseIf nOper == 5    
			//	AADD(aLog, {"ZWH_STATUS"	, "00", Nil})
			//	AADD(aLog, {"ZWH_ERRO"	, "FALHA NA EXCLUSÃO DO PROCESSO WMS ATRAVÉS DO PROCESSO GERADOR.", Nil})	        	
	    	ElseIf nOper == 3
	    		If cStatus == "07"
					AADD(aLog, {"ZWH_STATUS"	, "93", Nil})
					AADD(aLog, {"ZWH_ERRO"	, "ERRO NA GERACAO DO REGISTRO DE FINALIZACAO - SITUACAO 3 - AVISO DE FATURAMENTO. (WIS -> PROTHEUS).", Nil})
					AADD(aLog, {"ZWH_ERRTEC"	, "FALHA NA GERACAO DA TABELA INTEGRADORA ZWK/ZWL - SITUACAO 3 - AVISO DE FATURAMENTO. (WIS -> PROTHEUS)", Nil})				
				Else
		    		AADD(aLog, {"ZWH_STATUS"	, "99", Nil})
		    		AADD(aLog, {"ZWH_ERRTEC"	, "FALHA NA GERACAO DA TABELA INTEGRADORA. (PROTHEUS -> WIS)", Nil})
				EndIf	        		    	
	    	EndIf	    				   						  
	    	
	    	If Len(aLogTMP) > 0
	    		If Len(aLogTMP) >= 7
	    			If EMPTY(Alltrim(AllToChar(aLogTMP[7])))
	    				AADD(aLog, {"ZWH_SOLUCA"	, "REPROCESSAR A INTEGRAÇÃO", Nil})
	    			Else
	    				AADD(aLog, {"ZWH_SOLUCA"	, (Alltrim(AllToChar(aLogTMP[7]))), Nil})
	    			EndIf
	    		EndIf
	    		For nX := 1 to Len(aLogTMP)
	    			If !EMPTY(cDescErro)
	    				cDescErro += " - "	
	    			EndIf
	    			
	    			cDescErro += AllToChar(aLogTMP[nX])			    		
	    		Next					
			EndIf
			
			AADD(aLog, {"ZWH_OBSERV"	, cDescErro, Nil})
		Else
			If !nOper == 5
				If lGrvLogOk 				
					U_WIIWLOG(3,, "ZWK", ZWK->(RECNO()), ZWK->ZWK_EMPRES, ZWK->ZWK_DEPOSI, ZWK->ZWK_CODIGO,, ZWK->ZWK_SITUAC, "WIIWSAI",, "0",,,,, ZWK->ZWK_STATUS)
			    EndIf
			EndIf
	    EndIf

	    If Len(aLog) > 0
	    	//http://tdn.totvs.com/display/public/PROT/FWMVCRotAuto
	    	U_WIIWLOG(3, aLog)
	    EndIf
  	
  	End Transaction   	    
	
	oMdlZWK:Deactivate()
	oMdlZWK:Destroy()	
	FreeObj(oMdlZWK)
	oMdlZWK 	:= NIL
	aSize(aDadosCab,0)
	aDadosCab	:= NIL
	aSize(aDadosItem,0)			
	aDadosItem	:= NIL
					
 EndIf

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} WWIS4GRV

Gravação customizada do Model

@author  Allan Constantino Bonfim
@since   04/07/2018
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
STATIC FUNCTION WWIS4GRV(oModelAtu)

Local aArea		:= GetArea()
Local lRet			:= .T. 
Local nOper		:= oModelAtu:GetOperation()   
Local oModelCab	:= oModelAtu:GetModel("ZWK_SAIDAS")
Local oModelGrid	:= oModelAtu:GetModel("ZWL_SAIDAS")
Local cEmpres		:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
//Local cCodTmp		:= ""
Local cCodZWK		:= ""
//Local cStatErr	:= ""
//Local cStatOk		:= ""
Local nX			:= 0
Local nLinha		:= 1
Local lGrava		:= .F.

If nOper == 3
	
	If Alltrim(oModelCab:GetValue("ZWK_SITUAC")) == "1"
		DbSelectArea("ZWI")
		ZWI->(DbSetOrder(1)) //ZWI_FILIAL, ZWI_EMPRES, ZWI_CODIGO, ZWI_SITUAC
		
		DbSelectArea("ZWK")
		ZWK->(DbSetOrder(1)) //ZWK_FILIAL, ZWK_EMPRES, ZWK_CODIGO, ZWK_SITUAC
		
		//cCodZWK := oModelCab:GetValue("ZWK_CODIGO")
		If cEmpres <> Alltrim(oModelCab:GetValue("ZWK_EMPRES"))
			//cCodTmp := REPLICATE("0", TamSX3("ZWK_CODIGO")[01]) 
			//cCodZWK := STRTRAN(cCodTmp, "0", "Z", 1, 1)
			cCodZWK := STUFF(oModelCab:GetValue("ZWK_CODIGO"), 1, 1, "Z")
			
		Else
			cCodZWK := oModelCab:GetValue("ZWK_CODIGO")
		EndIf
		
		
		While !lGrava
			If ZWK->(DbSeek(oModelCab:GetValue("ZWK_FILIAL")+oModelCab:GetValue("ZWK_EMPRES")+cCodZWK))
				If cEmpres <> Alltrim(oModelCab:GetValue("ZWK_EMPRES"))
					cCodZWK := STUFF(cCodZWK, 1, 1, "0")
					cCodZWK := Soma1(cCodZWK)
					cCodZWK := STUFF(cCodZWK, 1, 1, "Z")
				Else
					cCodZWK := Soma1(cCodZWK)
				EndIf
			ElseIf ZWI->(DbSeek(oModelCab:GetValue("ZWK_FILIAL")+oModelCab:GetValue("ZWK_EMPRES")+cCodZWK))
				If cEmpres <> Alltrim(oModelCab:GetValue("ZWK_EMPRES"))
					cCodZWK := STUFF(cCodZWK, 1, 1, "0")
					cCodZWK := Soma1(cCodZWK)
					cCodZWK := STUFF(cCodZWK, 1, 1, "Z")
				Else
					cCodZWK := Soma1(cCodZWK)
				EndIf
			Else
				lGrava := .T.
				
				If cCodZWK <> oModelCab:GetValue("ZWK_CODIGO")			
					nLinha := oModelGrid:GetLine()
				
					For nX := 1 to oModelGrid:Length()
						oModelGrid:GoLine(nX)
						If !oModelGrid:IsDeleted()
							oModelGrid:SetValue("ZWL_CODIGO", cCodZWK)
						EndIf
					Next
					
					oModelGrid:GoLine(nLinha)
					
					oModelCab:SetValue("ZWK_CODIGO", cCodZWK)
				EndIf			
			EndIf
		EndDo	
	EndIf
	
ElseIf nOper == 4

	/*If !IsInCallStack("U_WIIWPFW")	
		nLinha := oModelGrid:GetLine()
		
		For nX := 1 to oModelGrid:Length()
			oModelGrid:GoLine(nX)
			If !oModelGrid:IsDeleted()
				If VAL(oModelGrid:GetValue("ZWL_STATUS")) > 50
					If Empty(cStatErr) .OR. VAL(cStatErr) > VAL(oModelGrid:GetValue("ZWL_STATUS"))
						cStatErr := oModelGrid:GetValue("ZWL_STATUS")
					EndIf			
				Else
					If Empty(cStatOk) .OR. VAL(cStatOk) > VAL(oModelGrid:GetValue("ZWL_STATUS"))
						cStatOk := oModelGrid:GetValue("ZWL_STATUS")
					EndIf	
				EndIf
			EndIf
		Next
		
		oModelGrid:GoLine(nLinha)
		
		If !EMPTY(cStatErr)
			If oModelCab:GetValue("ZWK_STATUS") <> cStatErr
				oModelCab:SetValue("ZWK_STATUS", cStatErr) 
			EndIf			
		ElseIf !EMPTY(cStatOk)
			If oModelCab:GetValue("ZWK_STATUS") <> cStatOk
				oModelCab:SetValue("ZWK_STATUS", cStatOk) 
			EndIf
		EndIf
	EndIf*/
	
EndIf

//lRet := FWFormCommit(oModelAtu)
lRet := FWFormCommit(oModelAtu ,, {|oModelAtu, cID, cAlias| WWIS4PVC(oModelAtu, cID, cAlias)})

RestArea(aArea)
  
Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc} WWIS4PVC

Pós validação na gravação customizada do Model (COMMIT)

@author  Allan Constantino Bonfim
@since   04/07/2018
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
STATIC FUNCTION WWIS4PVC(oModelTmp, cID, cAliasMdl)

Local aArea 		:= GetArea()
Local nOperation 	:= 0
Local lRet			:= .T.
Local cAliasTmp	:= ""

Default oModelTmp	:= FwModelActive()
Default cID		:= ""
Default cAliasMdl	:= ""

nOperation := oModelTmp:GetOperation()

If nOperation == 3
	
	If cAliasMdl == "ZWL" .AND. ALLTRIM(cID) == "ZWL_SAIDAS"
		If Alltrim(oModelTmp:GetValue("ZWL_SITUAC")) == "1"
			cAliasTmp := ZWL->ZWL_CALIAS
		
			aAreaTmp := (cAliasTmp)->(GetArea())		
				DbSelectArea(cAliasTmp)
				(cAliasTmp)->(DbGoto(ZWL->ZWL_RECORI))
				
				If 	cAliasTmp == "SC6" .AND. SC6->(FieldPos("C6_XWMSPRO")) > 0 .OR.;  
					cAliasTmp == "SD1" .AND. SD1->(FieldPos("D1_XWMSPRO")) > 0 .OR.;
					cAliasTmp == "SD2" .AND. SD2->(FieldPos("D2_XWMSPRO")) > 0 .OR.;
					cAliasTmp == "SD3" .AND. SD3->(FieldPos("D3_XWMSPRO")) > 0
					
					Reclock(cAliasTmp, .F.)	
						If cAliasTmp == "SC6"
							If SC6->(FieldPos("C6_XWMSPRO")) > 0
								(cAliasTmp)->C6_XWMSPRO := ZWL->ZWL_PROCES
							Endif
						ElseIf cAliasTmp == "SD1"
							If SD1->(FieldPos("D1_XWMSPRO")) > 0
								(cAliasTmp)->D1_XWMSPRO := ZWL->ZWL_PROCES
							EndIf
						ElseIf cAliasTmp == "SD2"
							If SD2->(FieldPos("D2_XWMSPRO")) > 0
								(cAliasTmp)->D2_XWMSPRO := ZWL->ZWL_PROCES
							EndIf
						ElseIf cAliasTmp == "SD3"
							If SD3->(FieldPos("D3_XWMSPRO")) > 0
								(cAliasTmp)->D3_XWMSPRO := ZWL->ZWL_PROCES
							EndIf
						EndIf		
					(cAliasTmp)->(MsUnlock())
				EndIf
			RestArea(aAreaTmp)
		EndIf
	EndIf
		
EndIf

RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc}WWIS4REP

Reprocessamento do registro com erro

@author  Allan Constantino Bonfim
@since   13/07/2018
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
USER FUNCTION WWIS4REP()

Local lRet			:= .T. 
Local oModelTmp	 	//:= FwModelActive()
Local oModelCab	//:= oModel:GetModel("ZWI_ENTRADAS")
Local oModelGrid	//:= oModel:GetModel("ZWJ_ENTRADAS")
Local nStatus		:= 0
Local nStatusCab 	:= 0
Local nX			:= 0
Local oMdlCabEr	 	//:= FwModelActive()
Local oModelZWH	//:= oModel:GetModel("ZWI_ENTRADAS")

If lRet .And. VAL(ZWK->ZWK_STATUS) <= 50
	Help(" ",1, "WWIS0004",, "Operação não permitida para o status "+ZWK->ZWK_STATUS+".",1,0)
	lRet := .F.
EndIf

If lRet
	If MsgYesNo("Confirma o reprocessamento do processo "+ZWK->ZWK_CODIGO+" ?", "WWIS0004")
	
		Begin Transaction		
			oModelTmp := FWLoadModel('WWIS0004')
			oModelTmp:SetOperation(4)
			oModelTmp:Activate()
			oModelCab	:= oModelTmp:GetModel("ZWK_SAIDAS")	
			oModelGrid	:= oModelTmp:GetModel("ZWL_SAIDAS")
		
			For nX := 1 To oModelGrid:Length()
				oModelGrid:GoLine(nX)
				If VAL(oModelGrid:GetValue("ZWL_STATUS")) > 50
					nStatus := 100 - VAL(oModelGrid:GetValue("ZWL_STATUS")) - 1
					
					If nStatus == 0
						nStatus := 1
					EndIf
					
					oModelGrid:SetValue("ZWL_STATUS", STRZERO(nStatus, 2))
					
					If Empty(nStatusCab) 
						nStatusCab := nStatus
					Else
						If nStatusCab < nStatus
							nStatusCab := nStatus //Menor Status possível dos processos de saida
						EndIf
					EndIf
				EndIf
			Next
			
			If !Empty(nStatusCab) .OR. VAL(oModelCab:GetValue("ZWK_STATUS")) > 50
				//Allan Constantino Bonfim - 26/10/2018 - CM Solutions - Projeto WMS 100% - Ajuste no status inicial no reprocessamento da interface
				If nStatusCab == 0
					nStatusCab := 100 - VAL(oModelCab:GetValue("ZWK_STATUS")) - 1
				EndIf
				
				oModelCab:SetValue("ZWK_STATUS", STRZERO(nStatusCab, 2))
			EndIf
			
			If oModelTmp:VldData()
				oModelTmp:CommitData()
							
				DbSelectArea("ZWH")
				ZWH->(DbSetOrder(1)) //ZWH_FILIAL, ZWH_EMPRES, ZWH_CODIGO, ZWH_SITUAC
				If ZWH->(DbSeek(xFilial("ZWH")+ZWK->ZWK_EMPRES+ZWK->ZWK_CODIGO+ZWK->ZWK_SITUAC))
					While 	!ZWH->(EOF()) .AND. ZWH->ZWH_FILIAL = ZWK->ZWK_FILIAL .AND.; 
							ZWH->ZWH_EMPRES = ZWK->ZWK_EMPRES .AND. ZWH->ZWH_CODIGO = ZWK->ZWK_CODIGO .AND.; 
							ZWH->ZWH_SITUAC = ZWK->ZWK_SITUAC
						
						If ZWH->ZWH_CALIAS $ "ZWK/ZWL" .AND. EMPTY(ZWH->ZWH_ACAO)
							oModelZWH := FWLoadModel('WWIS0002')
							oModelZWH:SetOperation(4)
							oModelZWH:Activate()
							oMdlCabEr	:= oModelZWH:GetModel("ZWH_LOG")	
							
							//ZWH->ZWH_ACAO	
							//ZWH->ZWH_USUARI	
							//ZWH->ZWH_DATACT	
							//ZWH->ZWH_HORACT						
							
							oMdlCabEr:SetValue("ZWH_ACAO"	, "1")
							oMdlCabEr:SetValue("ZWH_USUARI"	, cUserName)
							oMdlCabEr:SetValue("ZWH_DATACT"	, dDatabase)
							oMdlCabEr:SetValue("ZWH_HORACT"	, Substr(TIME(),1, TamSx3("ZWH_HORA")[01]))
									
							If oModelZWH:VldData()
								oModelZWH:CommitData()
							EndIf
													
							oModelZWH:DeActivate()
							oModelZWH:Destroy()	
							FreeObj(oModelZWH)			
							oModelZWH := Nil  
						EndIf
						                         	        	     
						ZWH->(DbSkip())				
					EndDo
				EndIf
				
				oModelTmp:DeActivate()
				oModelTmp:Destroy()	
				FreeObj(oModelTmp)			
				oModelTmp:= Nil
			EndIf
		End Transaction
	EndIf
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc}WWIS4STA

Reprocessamento do registro com erro

@author  Allan Constantino Bonfim - CM Solutions
@since   24/05/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
USER FUNCTION WWIS4STA(lFinaliza)

Local lRet			:= .T. 
Local nStatus		:= 0
Local nX			:= 0
Local cMsgInfo	:= ""
Local oModelTmp
Local oModelCab
Local oModelGrid
Local oMdlCabEr
Local oModelZWH

Default lFinaliza	:= .F.

If lRet .And. (VAL(ZWK->ZWK_STATUS) = 50 .OR. (!lFinaliza .AND. (VAL(ZWK->ZWK_STATUS) = 3 .OR. VAL(ZWK->ZWK_STATUS) = 9))) 
	Help(" ",1, "WWIS0004",, "Operação não permitida para o status "+ZWK->ZWK_STATUS+".",1,0)
	lRet := .F.
EndIf

If lRet
	If lFinaliza
		nStatus := 50
	EndIf

	If nStatus == 50
		cMsgInfo := "Confirma a finalização do processo "+ZWK->ZWK_CODIGO+" ?"
	Else
		cMsgInfo := "Confirma o avanço do status do processo "+ZWK->ZWK_CODIGO+" ?"
	EndIf
	
	If MsgYesNo(cMsgInfo, "WWIS0004")
	
		Begin Transaction		
			oModelTmp := FWLoadModel('WWIS0004')
			oModelTmp:SetOperation(4)
			oModelTmp:Activate()
			oModelCab	:= oModelTmp:GetModel("ZWK_SAIDAS")	
			oModelGrid	:= oModelTmp:GetModel("ZWL_SAIDAS")
			
			If Empty(nStatus)
				If VAL(oModelCab:GetValue("ZWK_STATUS")) > 50
					nStatus := 100 - VAL(oModelCab:GetValue("ZWK_STATUS")) - 1
					
					If nStatus <= 0
						nStatus := 4 //Menor Status possível dos processos de entrada
					EndIf
					
					nStatus := nStatus + 1
				Else		
					nStatus := VAL(oModelCab:GetValue("ZWK_STATUS")) + 1
				EndIf
								
				If !lFinaliza
					If nStatus > 9
						nStatus := 9 //Maior Status possível
					EndIf
				EndIf			
			EndIf
					
			For nX := 1 To oModelGrid:Length()
				oModelGrid:GoLine(nX)
					
				oModelGrid:SetValue("ZWL_STATUS", STRZERO(nStatus, 2))
			Next	
	
			oModelCab:SetValue("ZWK_STATUS", STRZERO(nStatus, 2))
						
			If oModelTmp:VldData()
				oModelTmp:CommitData()
							
				DbSelectArea("ZWH")
				ZWH->(DbSetOrder(1)) //ZWH_FILIAL, ZWH_EMPRES, ZWH_CODIGO, ZWH_SITUAC
				If ZWH->(DbSeek(xFilial("ZWH")+ZWK->ZWK_EMPRES+ZWK->ZWK_CODIGO+ZWK->ZWK_SITUAC))
					While 	!ZWH->(EOF()) .AND. ZWH->ZWH_FILIAL = ZWK->ZWK_FILIAL .AND.; 
							ZWH->ZWH_EMPRES = ZWK->ZWK_EMPRES .AND. ZWH->ZWH_CODIGO = ZWK->ZWK_CODIGO .AND.; 
							ZWH->ZWH_SITUAC = ZWK->ZWK_SITUAC
						
						If ZWH->ZWH_CALIAS $ "ZWK/ZWL" .AND. EMPTY(ZWH->ZWH_ACAO)
							oModelZWH := FWLoadModel('WWIS0002')
							oModelZWH:SetOperation(4)
							oModelZWH:Activate()
							oMdlCabEr	:= oModelZWH:GetModel("ZWH_LOG")	
							
							oMdlCabEr:SetValue("ZWH_ACAO"	, IIF (nStatus == 50, "3", "2"))
							oMdlCabEr:SetValue("ZWH_USUARI"	, cUserName)
							oMdlCabEr:SetValue("ZWH_DATACT"	, dDatabase)
							oMdlCabEr:SetValue("ZWH_HORACT"	, Substr(TIME(),1, TamSx3("ZWH_HORA")[01]))
									
							If oModelZWH:VldData()
								oModelZWH:CommitData()
							EndIf
													
							oModelZWH:DeActivate()
							oModelZWH:Destroy()	
							FreeObj(oModelZWH)			
							oModelZWH := Nil  
						EndIf
						                         	        	     
						ZWH->(DbSkip())				
					EndDo
				EndIf
				
				oModelTmp:DeActivate()
				oModelTmp:Destroy()	
				FreeObj(oModelTmp)			
				oModelTmp:= Nil
			EndIf
		End Transaction
	EndIf
EndIf

Return