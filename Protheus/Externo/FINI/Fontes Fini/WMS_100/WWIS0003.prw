#INCLUDE "PROTHEUS.CH" 
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH" 
#INCLUDE "FWMVCDEF.CH" 
#INCLUDE "FWBROWSE.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} WWIS0003

WMS 100% - Integraçãoes de Entradas no Protheus originadas do WIS

@author  Allan Constantino Bonfim
@since   04/04/2018
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
User Function WWIS0003()

Local aArea		:= GetArea()
Local oBrowse

oBrowse := FWMarkBrowse():New()
oBrowse:SetAlias("ZWI")
oBrowse:SetDescription("Entradas - Retorno do WIS")
oBrowse:DisableDetails()

oBrowse:AddLegend("EMPTY(ZWI_STATUS)"		, "BR_PRETO"		, "Erro Inderteminado")
oBrowse:AddLegend("VAL(ZWI_STATUS) > 50 "	, "BR_VERMELHO"	, "Integração com erro")
oBrowse:AddLegend("VAL(ZWI_STATUS) < 50 "	, "BR_AMARELO"	, "Integração em andamentto")
oBrowse:AddLegend("VAL(ZWI_STATUS) = 50 "	, "BR_VERDE"		, "Integração concluída")
	
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
ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.WWIS0003"	OPERATION 2 ACCESS 0 
ADD OPTION aRotina TITLE "Incluir"		ACTION "VIEWDEF.WWIS0003" 	OPERATION 3 ACCESS 0 
ADD OPTION aRotina TITLE "Alterar"		ACTION "VIEWDEF.WWIS0003" 	OPERATION 4 ACCESS 0
//ADD OPTION aRotina TITLE "Copiar"		ACTION "VIEWDEF.WWIS0003" 	OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE "Reprocessar"	ACTION "U_WWIS3REP"		 	OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"		ACTION "VIEWDEF.WWIS0003" 	OPERATION 5 ACCESS 0
					
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
Local oModel

oModel		:= MPFormModel():New("WWIS03MOD",, /*{|oModel| WWI3VLD(oModel)}*/, {|oModel| WWIS3GRV(oModel)}) //MPFormModel():New("WWIS03MOD",, /*{|oModel| WWI3VLD(oModel)}*/, {|oModel| WWIS3GRV(oModel)})

oStruct1	:= FWFormStruct(1, "ZWI")
oStruct2	:= FWFormStruct(1, "ZWJ")


//Estrutura Model
oModel:AddFields("ZWI_ENTRADAS",, oStruct1)
oModel:AddGrid("ZWJ_ENTRADAS", "ZWI_ENTRADAS", oStruct2)

oModel:GetModel("ZWJ_ENTRADAS"):SetOptional(.T.)

//oModel:SetRelation("ZWJ_ENTRADAS",{{"ZWJ_FILIAL", "ZWI_FILIAL"}, {"ZWJ_EMPRES", "ZWI_EMPRES"}, {"ZWJ_CODIGO", "ZWI_CODIGO"}, {"ZWJ_PROCES", "ZWI_PROCES"}, {"ZWJ_SITUAC", "ZWI_SITUAC"}}, ZWJ->(IndexKey(1)))
//oModel:SetRelation("ZWJ_ENTRADAS",{{"ZWJ_FILIAL", "ZWI_FILIAL"}, {"ZWJ_EMPRES", "ZWI_EMPRES"}, {"ZWJ_CODIGO", "ZWI_CODIGO"}, {"ZWJ_DEPOSI", "ZWI_DEPOSI"}, {"ZWJ_PROCES", "ZWI_PROCES"}, {"ZWJ_SITUAC", "ZWI_SITUAC"}}, "ZWJ_FILIAL+ZWJ_EMPRES+ZWJ_CODIGO+ZWJ_DEPOSI+ZWJ_PROCES+ZWJ_SITUAC")
oModel:SetRelation("ZWJ_ENTRADAS",{{"ZWJ_FILIAL", "ZWI_FILIAL"}, {"ZWJ_EMPRES", "ZWI_EMPRES"}, {"ZWJ_CODIGO", "ZWI_CODIGO"}, {"ZWJ_DEPOSI", "ZWI_DEPOSI"}, {"ZWJ_PROCES", "ZWI_PROCES"}}, "ZWJ_FILIAL+ZWJ_EMPRES+ZWJ_CODIGO+ZWJ_DEPOSI+ZWJ_PROCES")

oModel:SetPrimaryKey({})

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

oModel    := FWLoadModel("WWIS0003") //Chamada do model utilizando o nome do fonte (PRW)

oStruct1	:= FWFormStruct(2, "ZWI")
oStruct2	:= FWFormStruct(2, "ZWJ")


oView     := FWFormView():New() //View da MVC

oView:SetModel(oModel)

//Estrutura View
oView:AddField("VIEW_ZWI", oStruct1, "ZWI_ENTRADAS")
oView:AddGrid("VIEW_ZWJ", oStruct2, "ZWJ_ENTRADAS")

//Formatação da Tela
oView:CreateHorizontalBox("BOXZWI"	, 40)
oView:CreateHorizontalBox("BOXZWJ"	, 60)

oView:SetOwnerView("VIEW_ZWI"	, "BOXZWI")
oView:SetOwnerView("VIEW_ZWJ"	, "BOXZWJ")

oView:AddIncrementField("VIEW_ZWJ", "ZWJ_ITEM")

oView:SetCloseOnOk({|| .T.})

Return oView


//------------------------------------------------------------------------------------------------
/*/{Protheus.doc} WIIWENT

Rotina para geração da Interface de Integração de Entrada WIS -> PROTHEUS.

@author Allan Constantino Bonfim
@since  06/04/2018
@version P12
@return lRet, variavel logica
/*/
//-------------------------------------------------------------------------------------------------
User Function WIIWENT(cAliasA, nOper, aDadosCab, aDadosItem)

Local aArea			:= GetArea()
Local lRet				:= .T.
Local aLog				:= {}
Local aLogTMP			:= {}
Local cModel			:= "WWIS0003"
Local cIdMdlCb		:= "ZWI_ENTRADAS"
Local cIdModelI		:= "ZWJ_ENTRADAS"
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
Private oModelTmp

Default cAliasA		:= "ZWI"
Default nOper 		:= 1
Default aDadosCab		:= {}
Default aDadosItem	:= {}

lRet := Len(aDadosCab) > 0

If lRet
	
	Begin Transaction
		
		oModelTmp 	:= FWLoadModel(cModel)
		
		If Len(aDadosItem) > 0			
			FWMVCRotAuto(oModelTmp, "ZWI", nOper, {{cIdMdlCb, aDadosCab}, {cIdModelI, aDadosItem}}, .T.) //Model //Alias //Operacao //Dados
		Else
			FWMVCRotAuto(oModelTmp, "ZWI", nOper, {{cIdMdlCb, aDadosCab}}, .T.) //Model //Alias //Operacao //Dados
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
				
	     	//aLog := GetAutoGRLog()
	     	aLogTMP := oModelTmp:GetErrorMessage()   
	
		    nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWI_EMPRES"}) 	
	    	If nPosCpo > 0
	    		cEmpWis := aDadosCab[nPosCpo][2]
	    	EndIf
	    		    	
	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWI_DEPOSI"}) 	
	    	If nPosCpo > 0
	    		cFilWis := aDadosCab[nPosCpo][2]
	    	EndIf
	    	
	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWI_CODIGO"})   	
	    	If nPosCpo > 0
	    		cCodigo := aDadosCab[nPosCpo][2]
	    	EndIf

	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWI_SITUAC"})   	
	    	If nPosCpo > 0
	    		cSituac := aDadosCab[nPosCpo][2]
	    	EndIf
	    		    	
	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWI_CALIAS"}) 	
	    	If nPosCpo > 0
	    		cAliasX := aDadosCab[nPosCpo][2]
	    	EndIf
	    	    	
	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWI_RECORI"})   	
	    	If nPosCpo > 0
	    		nRecTab := aDadosCab[nPosCpo][2]
	    	EndIf
			
	    	nPosCpo := ASCAN(aDadosCab, {|x| x[1] == "ZWI_STATUS"})   	
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
	    	AADD(aLog, {"ZWH_ERRO"	, "FALHA NA GERAÇÃO DA TABELA INTEGRADORA DE RETORNO DA INTERFACE (WIS -> PROTHEUS)", Nil})
	    	
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
	    	
	    	//AADD(aLog, {"ZWH_SOLUCA"	, cDescErro, Nil})
			AADD(aLog, {"ZWH_OBSERV"	, cDescErro, Nil})    
			AADD(aLog, {"ZWH_STATUS"	, "96", Nil})	        	
	    	AADD(aLog, {"ZWH_DATA"	, dDatabase, Nil})
	    	AADD(aLog, {"ZWH_HORA"	, Substr(TIME(),1, TamSx3("ZWH_HORA")[01]), Nil})  		
		Else
			If !nOper == 5
				If lGrvLogOk
					U_WIIWLOG(3,, "ZWI", ZWI->(RECNO()), ZWI->ZWI_EMPRES, ZWI->ZWI_DEPOSI, ZWI->ZWI_CODIGO,, ZWI->ZWI_SITUAC, "WIIWENT",, "0",,,,, ZWI->ZWI_STATUS) 	 
			    EndIf
		    EndIf	 	   
	    EndIf
	    
	    If Len(aLog) > 0
	    	//http://tdn.totvs.com/display/public/PROT/FWMVCRotAuto
	    	U_WIIWLOG(3, aLog)
	    EndIf

	End Transaction	  
		
	oModelTmp:Deactivate()
	oModelTmp:Destroy()	
	FreeObj(oModelTmp)
	oModelTmp 	:= NIL
	aSize(aDadosCab,0)
	aDadosCab	:= NIL
	aSize(aDadosItem,0)			
	aDadosItem	:= NIL
			      
 EndIf
 
RestArea(aArea)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} WWIS3GRV

Gravação customizada do Model

@author  Allan Constantino Bonfim
@since   04/07/2018
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
STATIC FUNCTION WWIS3GRV(oModelAtu)

Local aArea		:= GetArea()
Local lRet			:= .T. 
Local nOper		:= oModelAtu:GetOperation()   
Local oModelCab	:= oModelAtu:GetModel("ZWI_ENTRADAS")
Local oModelGrid	:= oModelAtu:GetModel("ZWJ_ENTRADAS")
Local cEmpres		:= IIf(FWCodEmp() == '01', '2', IIF(FWCodEmp() == '02', '1', ''))
Local cCodTmp		:= ""
//Local cStatErr	:= ""
//Local cStatOk		:= ""
Local cCodZWI		:= ""
Local nX			:= 0
Local nLinha		:= 1
Local lGrava		:= .F.

If nOper == 3
	
	If !Alltrim(oModelCab:GetValue("ZWI_CALIAS")) $ "SC5/SD3/SF1/SF2" //.OR. Alltrim(oModelCab:GetValue("ZWI_SITUAC")) == "1"
		DbSelectArea("ZWK")
		ZWK->(DbSetOrder(1)) //ZWK_FILIAL, ZWK_EMPRES, ZWK_CODIGO, ZWK_SITUAC
		
		DbSelectArea("ZWI")
		ZWI->(DbSetOrder(1)) //ZWI_FILIAL, ZWI_EMPRES, ZWI_CODIGO, ZWI_SITUAC
		
		If cEmpres <> Alltrim(oModelCab:GetValue("ZWI_EMPRES"))
			cCodTmp 	:= REPLICATE("0", TamSX3("ZWI_CODIGO")[01]) 
			cCodZWI	:= STRTRAN(cCodTmp, "0", "Z", 1, 1)
		Else
			cCodZWI := oModelCab:GetValue("ZWI_CODIGO")
		EndIf
				
		While !lGrava
			If ZWI->(DbSeek(oModelCab:GetValue("ZWI_FILIAL")+oModelCab:GetValue("ZWI_EMPRES")+cCodZWI))
				cCodZWI := Soma1(cCodZWI)
			ElseIf ZWK->(DbSeek(oModelCab:GetValue("ZWI_FILIAL")+oModelCab:GetValue("ZWI_EMPRES")+cCodZWI))
				cCodZWI := Soma1(cCodZWI)
			Else
				lGrava := .T.
				
				If cCodZWI <> oModelCab:GetValue("ZWI_CODIGO")			
					nLinha := oModelGrid:GetLine()
				
					For nX := 1 to oModelGrid:Length()
						oModelGrid:GoLine(nX)
						If !oModelGrid:IsDeleted()
							oModelGrid:SetValue("ZWJ_CODIGO", cCodZWI)
						EndIf
					Next
					
					oModelGrid:GoLine(nLinha)
					
					oModelCab:SetValue("ZWI_CODIGO", cCodZWI)
				EndIf			
			EndIf
		EndDo	
	EndIf
	
ElseIf nOper == 4
/*	
	If !IsInCallStack("U_WIIWPFW")
		nLinha := oModelGrid:GetLine()
		
		For nX := 1 to oModelGrid:Length()
			oModelGrid:GoLine(nX)
			If !oModelGrid:IsDeleted()
				If VAL(oModelGrid:GetValue("ZWJ_STATUS")) > 50
					If Empty(cStatErr) .OR. VAL(cStatErr) > VAL(oModelGrid:GetValue("ZWJ_STATUS"))
						cStatErr := oModelGrid:GetValue("ZWJ_STATUS")
					EndIf			
				Else
					If Empty(cStatOk) .OR. VAL(cStatOk) > VAL(oModelGrid:GetValue("ZWJ_STATUS"))
						cStatOk := oModelGrid:GetValue("ZWJ_STATUS")
					EndIf	
				EndIf
			EndIf
		Next
		
		oModelGrid:GoLine(nLinha)
		
		If !EMPTY(cStatErr)
			If oModelCab:GetValue("ZWI_STATUS") <> cStatErr
				oModelCab:SetValue("ZWI_STATUS", cStatErr) 
			EndIf	
		ElseIf !EMPTY(cStatOk)
			If oModelCab:GetValue("ZWI_STATUS") <> cStatOk
				oModelCab:SetValue("ZWI_STATUS", cStatOk) 
			EndIf
		EndIf
	EndIf
*/
EndIf

lRet := FWFormCommit(oModelAtu)

RestArea(aArea)
  
Return lRet 


//-------------------------------------------------------------------
/*/{Protheus.doc}WWIS3REP

Reprocessamento do registro com erro

@author  Allan Constantino Bonfim
@since   13/07/2018
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
USER FUNCTION WWIS3REP()

Local lRet			:= .T. 
Local oModelTmp	 	//:= FwModelActive()
Local oModelCab	//:= oModel:GetModel("ZWI_ENTRADAS")
Local oModelGrid	//:= oModel:GetModel("ZWJ_ENTRADAS")
Local nStatus		:= 0
Local nStatusCab 	:= 0
Local nX			:= 0

If lRet .And. VAL(ZWI->ZWI_STATUS) <= 50
	Help(" ",1, "WWIS0003",, "Operação não permitida para o status "+ZWI->ZWI_STATUS+".",1,0)
	lRet := .F.
EndIf

If lRet
	If MsgYesNo("Confirma o reprocessamento do processo "+ZWI->ZWI_CODIGO+" ?", "WWIS0003")
		oModelTmp := FWLoadModel('WWIS0003')
		oModelTmp:SetOperation(4)
		oModelTmp:Activate()
		oModelCab	:= oModelTmp:GetModel("ZWI_ENTRADAS")	
		oModelGrid	:= oModelTmp:GetModel("ZWJ_ENTRADAS")
	
		For nX := 1 To oModelGrid:Length()
			oModelGrid:GoLine(nX)
			If VAL(oModelGrid:GetValue("ZWJ_STATUS")) > 50
				nStatus := 100 - VAL(oModelGrid:GetValue("ZWJ_STATUS")) - 1
				
				If nStatus <= 0
					nStatus := 4 //Menor Status possível dos processos de entrada
				EndIf
				
				oModelGrid:SetValue("ZWJ_STATUS", STRZERO(nStatus, 2))
				
				If Empty(nStatusCab) 
					nStatusCab := nStatus
				Else
					If nStatusCab < nStatus
						nStatusCab := nStatus
					EndIf
				EndIf
			EndIf
		Next
	
		//Allan Constantino Bonfim - 26/10/2018 - CM Solutions - Projeto WMS 100% - Ajuste no status inicial no reprocessamento da interface	
		If !Empty(nStatusCab) .OR. VAL(oModelCab:GetValue("ZWI_STATUS")) > 50			
			If nStatusCab == 0
				nStatusCab := 100 - VAL(oModelCab:GetValue("ZWI_STATUS")) - 1
			EndIf
	 
			oModelCab:SetValue("ZWI_STATUS", STRZERO(nStatusCab, 2))
		EndIf

		If oModelTmp:VldData()
			oModelTmp:CommitData()
						
			DbSelectArea("ZWH")
			ZWH->(DbSetOrder(1)) //ZWH_FILIAL, ZWH_EMPRES, ZWH_CODIGO, ZWH_SITUAC
			If ZWH->(DbSeek(xFilial("ZWH")+ZWI->ZWI_EMPRES+ZWI->ZWI_CODIGO+ZWI->ZWI_SITUAC))
				While 	!ZWH->(EOF()) .AND. ZWH->ZWH_FILIAL = ZWI->ZWI_FILIAL .AND.; 
						ZWH->ZWH_EMPRES = ZWI->ZWI_EMPRES .AND. ZWH->ZWH_CODIGO = ZWI->ZWI_CODIGO .AND.; 
						ZWH->ZWH_SITUAC = ZWI->ZWI_SITUAC
					
					If ZWH->ZWH_CALIAS $ "ZWI/ZWJ" .AND. EMPTY(ZWH->ZWH_ACAO)
						oModelZWH := FWLoadModel('WWIS0002')
						oModelZWH:SetOperation(4)
						oModelZWH:Activate()
						oMdlCabEr	:= oModelZWH:GetModel("ZWH_LOG")	
						
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
	EndIf
EndIf

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} WWIS3STA

Reprocessamento do registro com erro

@author  Allan Constantino Bonfim - CM Solutions
@since   24/05/2019
@version P12 
@return NIL

/*/
//-------------------------------------------------------------------   
USER FUNCTION WWIS3STA(lFinaliza)

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

If lRet .And. (VAL(ZWI->ZWI_STATUS) = 50 .OR. (!lFinaliza .AND. VAL(ZWI->ZWI_STATUS) = 6)) 
	Help(" ",1, "WWIS0003",, "Operação não permitida para o status "+ZWI->ZWI_STATUS+".",1,0)
	lRet := .F.
EndIf

If lRet
	If lFinaliza
		nStatus := 50
	EndIf
	
	If nStatus == 50
		cMsgInfo := "Confirma a finalização do processo "+ZWI->ZWI_CODIGO+" ?"
	Else
		cMsgInfo := "Confirma o avanço do status do processo "+ZWI->ZWI_CODIGO+" ?"
	EndIf
	
	If MsgYesNo(cMsgInfo, "WWIS0003")
		oModelTmp := FWLoadModel('WWIS0003')
		oModelTmp:SetOperation(4)
		oModelTmp:Activate()
		oModelCab	:= oModelTmp:GetModel("ZWI_ENTRADAS")	
		oModelGrid	:= oModelTmp:GetModel("ZWJ_ENTRADAS")
		
		If EMPTY(nStatus)
			If VAL(oModelCab:GetValue("ZWI_STATUS")) > 50
				nStatus := 100 - VAL(oModelCab:GetValue("ZWI_STATUS")) - 1
				
				If nStatus <= 0
					nStatus := 4 //Menor Status possível dos processos de entrada
				EndIf
				
				nStatus := nStatus + 1
			Else		
				nStatus := VAL(oModelCab:GetValue("ZWI_STATUS")) + 1
			EndIf			
			
			If !lFinaliza
				If nStatus > 6
					nStatus := 6 //Maior Status possível
				EndIf
			EndIf			
		EndIf
			
		For nX := 1 To oModelGrid:Length()
			oModelGrid:GoLine(nX)
				
			oModelGrid:SetValue("ZWJ_STATUS", STRZERO(nStatus, 2))
		Next	

		oModelCab:SetValue("ZWI_STATUS", STRZERO(nStatus, 2))

		If oModelTmp:VldData()
			oModelTmp:CommitData()
						
			DbSelectArea("ZWH")
			ZWH->(DbSetOrder(1)) //ZWH_FILIAL, ZWH_EMPRES, ZWH_CODIGO, ZWH_SITUAC
			If ZWH->(DbSeek(xFilial("ZWH")+ZWI->ZWI_EMPRES+ZWI->ZWI_CODIGO+ZWI->ZWI_SITUAC))
				While 	!ZWH->(EOF()) .AND. ZWH->ZWH_FILIAL = ZWI->ZWI_FILIAL .AND.; 
						ZWH->ZWH_EMPRES = ZWI->ZWI_EMPRES .AND. ZWH->ZWH_CODIGO = ZWI->ZWI_CODIGO .AND.; 
						ZWH->ZWH_SITUAC = ZWI->ZWI_SITUAC
					
					If ZWH->ZWH_CALIAS $ "ZWI/ZWJ" .AND. EMPTY(ZWH->ZWH_ACAO)
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
	EndIf
EndIf

Return
