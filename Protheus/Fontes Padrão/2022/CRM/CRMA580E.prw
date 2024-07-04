#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA580E.CH"

#DEFINE NTAM_COD_INT  2

Static _lMarkAll	:= .F.
Static _F3NvlSel	:= ""
Static _F3FilNiv	:= {}
Static _lEvalLogic	:= .F.
 
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580E
Rotina que monta tela para seleção dos agrupadores.

@sample	CRMA580E()

@param		aCodAgrup	- Array com codigo dos agrupadores
@param		lParents	- Se .T. retorna somente os niveis pais do agrupador.
@param		lMarkAll	- Se .T. na tela de selecao do niveis permite selecoes multiplas.
@param		lExecView	- Se .T. exibe interface grafica para selecao.
@param		lSelection	- Se .T. exibe campo de controle para selecao do Grid dos agrupadores.
@param		aFilEnt		- Array com as entidades a ser considerada na montagem dos agrupadores.
@param		lF3			- Logico que indica se a funcao está sendo executada atraves de consulta padrao.
@param		lEvalLogic  - Indica que a interface será de um agrupador logico.

@return	aRetorno - String dos agruapdores selecionados.

@author		SI2901 - Cleyton F.Alves
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580E(aCodAgrup,lParents,lMarkAll,lExecView,cTitView,lSelection,aFilEnt,lF3,lEvalLogic)

Local aArea			:= GetArea()
Local aAreaAOL		:= AOL->(GetArea())
Local aAreaAOM		:= AOM->(GetArea())
Local oMdlActive	:= FwModelActive()
Local oView			:= Nil
Local oExecView		:= Nil
Local aButtons		:= {}
Local cCodAgr		:= ""
Local aLoadAOL		:= {}
Local oStructAOL	:= Nil 
Local nX			:= 0
Local nY			:= 0
Local oMdlAOL		:= Nil
Local oMdlAOM		:= Nil
Local oMdlAOMGrid	:= Nil
Local oMdlAOLGrid	:= Nil
Local lMark			:= .T.
Local aRetorno		:= {}
Local bCommit		:= {|| .T. }
Local lSalvar		:= .T. 
 
Default aCodAgrup 	:= {}
Default lParents  	:= .F.
Default lMarkAll  	:= .F.
Default lExecView 	:= .F.
Default cTitView  	:= STR0001 //Agrupador de Registros 
Default lSelection	:= .F.
Default aFilEnt   	:= {}
Default lF3			:= .F.
Default lEvalLogic	:= .F.

// Criado o model como estatico para evitar de carregar o model quando a rotina automatica é chamada mais de uma vez. Evitando assim estouro de memoria.
Static oModel 		:= Nil

_lMarkAll 			:= lMarkAll
_lEvalLogic			:= lEvalLogic

If _lEvalLogic
	lSalvar := .F.	
EndIf

If !Empty(aCodAgrup) .OR. !Empty(aFilEnt) 

	DbSelectArea("AOL")
	DbSetOrder(1)
	
	DbSelectArea("AOM")
	DbSetOrder(1)
	
	If oModel == Nil		
		oModel := ModelDef()
	EndIf
	
	oMdlAOL := oModel:GetModel("AOLDETAIL")
	oMdlAOM := oModel:GetModel("AOMDETAIL")	
	
	If lSelection 
		oStructAOL := oMdlAOL:GetStruct()
		oStructAOL:AddField("","","AOL_MARK","L",1,0,{|oMdlAOM| CRMVMarkAOL(oMdlAOM)},Nil,Nil,Nil,Nil,Nil,Nil,.T.)
	EndIf
	
	aLoadAOL := CRM580LAOL(oMdlAOL,aCodAgrup,aFilEnt)
	
	If Len(aLoadAOL) > 0 
	
		oMdlAOL:bLoad:={|| aLoadAOL }
		oMdlAOM:bLoad:={|| CRM580LAOM(oMdlAOM,oMdlAOL:GetValue("AOL_CODAGR")) }
		
		oModel:SetOperation(MODEL_OPERATION_UPDATE)
		
		oModel:GetModel('AOLDETAIL'):SetNoDeleteLine(.T.)
		oModel:GetModel('AOLDETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('AOLDETAIL'):SetNoUpdateLine(.F.)
		
		oModel:GetModel('AOMDETAIL'):SetNoDeleteLine(.T.)
		oModel:GetModel('AOMDETAIL'):SetNoInsertLine(.T.)
		oModel:GetModel('AOMDETAIL'):SetNoUpdateLine(.F.)
		
		If !lF3
			bCommit := {|| (aRetorno := CRM580ERNvl(oModel,lSelection),.T.) }
		Else
			bCommit := {|| (_F3NvlSel := CRM580EF3Nvl(),.T.) }
		EndIf
		
		oModel:bCommit := bCommit
		oModel:Activate()
										
		If lExecView
			
			aButtons := { {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
						  {.F.,Nil},{lSalvar,"OK"},{.T.,"Fechar"},{.F.,Nil}		,;
						  {.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil} }
			
			oView := FWLoadView("CRMA580E")
			
			If lSelection
				oStructAOL := oView:GetViewStruct("AOLDETAIL")
				oStructAOL:AddField("AOL_MARK","01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)
			EndIf
			
			oView:SetModel(oModel)
			oView:SetOperation(MODEL_OPERATION_UPDATE)
								
			oExecView := FWViewExec():New()
			oExecView:SetTitle(cTitView)
			oExecView:SetView(oView)
			oExecView:SetModal(.F.)
			oExecView:SetOperation(MODEL_OPERATION_UPDATE)
			oExecView:SetButtons(aButtons)
			
			oExecView:SetSize(450,450)
			
			oExecView:OpenView(.F.)
		
		Else
			
			oMdlAOLGrid := oModel:GetModel("AOLDETAIL")
			
			For nX := 1 To oMdlAOLGrid:Length()
	
				oMdlAOLGrid:GoLine(nX)
			
				oMdlAOMGrid := oModel:GetModel("AOMDETAIL")
				For nY := 1 To oMdlAOMGrid:Length()
					oMdlAOMGrid:GoLine(nY)
					If lParents
						If Len(AllTrim(oMdlAOMGrid:GetValue("AOM_IDINT"))) == NTAM_COD_INT
							oMdlAOMGrid:SetValue("AOM_MARK",.T.)
						EndIf
					Else
						oMdlAOMGrid:SetValue("AOM_MARK",.T.)
					EndIf
				Next nY
				
			Next nX
							
			If CRMA580VldMdl(oModel)
				oModel:CommitData()
			EndIf
							
		EndIf
		
	EndIf
	
	oModel:DeActivate()
	
EndIf

// Tratativa para manter o model da chamada anterior sempre ativo
If oMdlActive <> Nil
	FwModelActive(oMdlActive)
EndIf 

_lMarkAll := .F. 

RestArea(aAreaAOM)
RestArea(aAreaAOL)
RestArea(aArea)

Return(aRetorno)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Monta modelo de dados do Níveis do Agrupador Dinamico.
@sample		ModelDef()
@param		Nenhum
@return		ExpO - Modelo de Dados
@author		SI2901 - Cleyton F.Alves
@since		11/03/2015
@version	12 
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oStructCAB	:= FWFormModelStruct():New()
Local oStructAOL	:= FWFormStruct(1,"AOL"  ,/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAOM	:= FWFormStruct(1,"AOM"  ,/*bAvalCampo*/,/*lViewUsado*/)
Local bCarga		:= {|| {xFilial("AOL")}}
Local oModel 	 	:= Nil

oStructCAB:AddField("","","CABEC_FILIAL","C",FwSizeFilial(),0)
oStructAOM:AddField("","","AOM_MARK","L",1,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

oModel := MPFormModel():New("CRMA580E",/*bPreValidacao*/,/*bPosVldMdl*/,/*bCommitMdl*/,/*bCancel*/)

oModel:AddFields("CABMASTER",/*cOwner*/,oStructCAB,/*bPreValidacao*/,/*bPosVldMdl*/,bCarga)
oModel:AddGrid("AOLDETAIL","CABMASTER" ,oStructAOL,/*bLinPre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVldGrid*/,/*bLoad*/)
oModel:AddGrid("AOMDETAIL","AOLDETAIL" ,oStructAOM,/*bLinPre*/,/*bLinePost*/,/*bPreVal*/,/*bPosVldGrid*/,/*bLoad*/)

oModel:SetRelation("AOLDETAIL",{{"AOL_FILIAL","xFilial('AOL')"}},AOL->(IndexKey(1)))
oModel:SetRelation("AOMDETAIL",{{"AOM_FILIAL","xFilial('AOM')"},{"AOL_CODAGR","AOM_CODAGR"}},AOM->(IndexKey(1)))

oModel:GetModel("AOLDETAIL"):SetOptional(.T.)
oModel:GetModel("AOMDETAIL"):SetOptional(.T.)
oModel:GetModel("AOLDETAIL"):SetOnlyQuery(.T.)
oModel:GetModel("AOMDETAIL"):SetOnlyQuery(.T.)

oModel:SetPrimaryKey({""})

oModel:GetModel("CABMASTER"):SetDescription(STR0001) //Agrupador de Registros 

oModel:SetDescription(STR0001) //Agrupador de Registros 

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Monta interface do Níveis do Agrupador Dinamico.

@sample	ViewDef()
@param		Nenhum

@return	ExpO - Interface do Agrupador de Registros
@author	SI2901 - Cleyton F.Alves
@since		11/03/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oStructAOL	:= FWFormStruct(2,"AOL",{|cCampo| AllTrim(cCampo) $ "AOL_CODAGR|AOL_RESUMO|AOL_ENTIDA|AOL_DSCENT|AOL_TIPO|"},/*lViewUsado*/)
Local oStructAOM	:= FWFormStruct(2,"AOM",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel   		:= FWLoadModel('CRMA580E')
Local oView			:= Nil
Local oPanel		:= Nil

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Campo de marca da tabela ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oStructAOM:AddField("AOM_MARK","01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)
 
oView:=FWFormView():New()
oView:SetModel(oModel)
oView:AddGrid("VIEW_AOL",oStructAOL,"AOLDETAIL")

//Painel Superior
oView:CreateHorizontalBox("QUAD01",35)
oView:CreateHorizontalBox("QUAD02",65)
	
//Cria objetos
oView:AddOtherObject("OBJ_TREE"	,{|oPanel| CRM580DTree(oPanel,oView,oView:GetModel(),_lEvalLogic)})
oView:EnableTitleView("OBJ_TREE",STR0002) //Agrupadores
oView:SetViewProperty('VIEW_AOL',"CHANGELINE",{ { || CRMA580DLdTree(Nil,oView:GetModel()) }})

oView:SetOwnerView("VIEW_AOL","QUAD01")
oView:SetOwnerView("OBJ_TREE","QUAD02") 

Return oView

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM580LAOL
Retorna os agrupador selecionado pelo usuario.

@sample	CRM580LAOL(oMdlAOL,aCodAgrup,aFilEnt)

@param		Nenhum
@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		05/04/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM580LAOL(oMdlAOL,aCodAgrup,aFilEnt)

Local aAreaAOL	:= AOL->(GetArea())
Local aLoadAOL   := {}
Local oStructAOL := oMdlAOL:GetStruct()
Local aCampos    := oStructAOL:GetFields()
Local cMacro     := ""
Local cCodAgr    := ""
Local cAliasAgr  := ""
Local nX         := 0
Local nY		 := 0

If Empty(aFilEnt) 

	DbSelectArea("AOL")
	AOL->(DbSetOrder(1)) //AOL_FILIAL + AOL_CODAGR
	
	For nX := 1 To Len(aCodAgrup)
	
		cCodAgr := aCodAgrup[nX]
		
		If AOL->(dbSeek(xFilial("AOL")+cCodAgr)) .And. AOL->AOL_MSBLQL <> '1'
			
			aAdd(aLoadAOL,{AOL->(Recno()) ,{} })	
			
			For nY := 1 To Len(aCampos)	
			
				If !aCampos[nY][MODEL_FIELD_VIRTUAL]
					cMacro := "AOL->"+ALlTrim(aCampos[nY][MODEL_FIELD_IDFIELD])
				Else 
					If aCampos[nY][MODEL_FIELD_IDFIELD] == "AOL_DSCENT"
						cMacro := "AllTrim(Posicione('SX2',1,AOL->AOL_ENTIDA,'X2NOME()'))"
					ElseIf aCampos[nY][MODEL_FIELD_IDFIELD] == "AOL_MARK"
						cMacro := ".F."
					EndIf
				EndIf
			
				aAdd(aLoadAOL[Len(aLoadAOL),2] , &cMacro )
			Next nY
			
		EndIf
	
	Next nX
	
Else

	DbSelectArea("AOL")
	AOL->(DbSetOrder(2)) //AOL_FILIAL + AOL_ENTIDA
	
	For nX := 1 To Len(aFilEnt)
	
		cAliasAgr := aFilEnt[nX]
			
		If AOL->(dbSeek(xFilial("AOL")+cAliasAgr))
			
			While AOL->AOL_ENTIDA == cAliasAgr
			
				If AOL->AOL_MSBLQL <> '1' 
				
					aAdd(aLoadAOL,{AOL->(Recno()) ,{} })	
					
					For nY := 1 To Len(aCampos)	
						If !aCampos[nY][MODEL_FIELD_VIRTUAL]
							cMacro := "AOL->"+ALlTrim(aCampos[nY][MODEL_FIELD_IDFIELD])
						Else
							If aCampos[nY][MODEL_FIELD_IDFIELD] == "AOL_DSCENT"
								cMacro := "AllTrim(Posicione('SX2',1,AOL->AOL_ENTIDA,'X2NOME()'))"
							ElseIf aCampos[nY][MODEL_FIELD_IDFIELD] == "AOL_MARK"
								cMacro := ".F."
							EndIf
						EndIf
					
						aAdd(aLoadAOL[Len(aLoadAOL),2] , &cMacro )
					Next nY
					
				EndIf
				
				AOL->(DbSkip())
			End
				
		EndIf
		
	Next nX
	
EndIf

RestArea(aAreaAOL)

Return(aLoadAOL)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM580LAOM

Retorna os agrupador selecionado pelo usuario.

@sample	CRM580LAOM(oMdlAOM,cCodAgr)

@param		Nenhum
@return		ExpC - String dos Agrupadores Selecionados.

@author		SI2901 - Cleyton F.Alves
@since		05/04/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM580LAOM(oMdlAOM,cCodAgr)

Local aLoadAOM   := {}
Local oStructAOM := oMdlAOM:GetStruct()
Local aCampos    := oStructAOM:GetFields()
Local cMacro     := ""
Local nY		 := 0

Private INCLUI 	:= .F.

If AOM->(dbSeek(xFilial("AOM")+cCodAgr))
	WHile AOM->(!Eof()) .And. AOM->AOM_FILIAL == xFilial("AOM") .And. AllTrim(AOM->AOM_CODAGR) == AllTrim(cCodAgr)
		aAdd(aLoadAOM,{AOM->(Recno()) ,{} })	
		For nY := 1 To Len(aCampos)	
			If !aCampos[nY][MODEL_FIELD_VIRTUAL]
				cMacro := "AOM->"+ALlTrim(aCampos[nY][MODEL_FIELD_IDFIELD])
			Else
				cMacro := ALlTrim(aCampos[nY][MODEL_FIELD_INIT])
			EndIf

			aAdd(aLoadAOM[Len(aLoadAOM),2] , &cMacro )
		Next nY
		AOM->(dbSkip())
	EndDo	
EndIf

Return(aLoadAOM)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580EMrkAll
Define que usuario poderá selecionar todos os niveis do agrupador fixo ou dinamico.

@sample		CRMA580EMrkAll()

@param		Nenhum
@return	ExpL - Flag para permitir selecionar todos os níveis do agrupador.

@author	Anderson
@since		05/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580EMrkAll()
Return(_lMarkAll)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580EF3Nvl
Retorna o nivel do agrupador selecionado no model. 

@sample	CRM580EF3Nvl

@param		Nenhum

@return		Nenhum
@author		Anderson Silva
@since		12/05/2015
@version	12.5
/*/
//------------------------------------------------------------------------------
Static Function CRM580EF3Nvl()
Local oModel		:= FwModelActive()
Local oMdlAOMGrid	:= oModel:GetModel("AOMDETAIL")
Local cCodNiv		:= ""

If oMdlAOMGrid:GetValue("AOM_MSBLQL") == "2"
	cCodNiv := oMdlAOMGrid:GetValue("AOM_CODNIV") 
EndIf

Return(cCodNiv)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580EGNvl
Retorna o nivel do agrupador para a consulta padrao.

@sample	CRMA580EGNvl

@param		Nenhum

@return	Nenhum
@author	Anderson Silva
@since		12/05/2015
@version	12.5
/*/
//------------------------------------------------------------------------------
Function CRMA580EGNvl() 
Return(_F3NvlSel)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580ERNvl
Retorna os niveis do agrupador selecionado pelo usuario.

@sample		CRM580ERNvl()

@param		Nenhum

@return		ExpA - Array com os níveis do agrupador.

@author		Anderson
@since		05/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRM580ERNvl(oModel,lSelection)

Local oMdlAOLGrid		:= oModel:GetModel("AOLDETAIL")
Local oMdlAOMGrid		:= oModel:GetModel("AOMDETAIL")
Local aGroupMark		:= {}
Local nX				:= 0
Local nY				:= 0
Local nZ            	:= 0
Local aFilAux			:= {}
Local cAliasAgr			:= ""
Local cXml				:= ""
Local aFilters			:= {}
Local nPosGroup			:= 0 
Local cCodAgr			:= ""
Local cTypeAgr			:= ""
Local lMark				:= .T.

For nX := 1 To oMdlAOLGrid:Length()
	
	oMdlAOLGrid:GoLine(nX)
	
	// Verificar se controle de selecao do GRID AOL esta ativo
	If lSelection
		lMark := oMdlAOLGrid:GetValue("AOL_MARK")	
	EndIf
	
	If lMark
		cCodAgr		:= oMdlAOLGrid:GetValue("AOL_CODAGR")
		cTypeAgr	:= oMdlAOLGrid:GetValue("AOL_TIPO")
		cAliasAgr	:= oMdlAOLGrid:GetValue("AOL_ENTIDA")
	
		For nY := 1 To oMdlAOMGrid:Length()
		
			oMdlAOMGrid:GoLine(nY)
			
			If oMdlAOMGrid:GetValue("AOM_MARK") .OR. _lEvalLogic
			
				cXml := oMdlAOMGrid:GetValue("AOM_FILXML") 
				
				If !Empty(cXml)
					aFilAux := CRMA580XTA( cXml )
					
					For nZ := 1 To Len(aFilAux)
						aAdd(aFilters,{ IIF(!Empty(aFilAux[nZ][8]),aFilAux[nZ][8],cAliasAgr)	,;
										aFilAux[nZ][1]										 		,;
										aFilAux[nZ][2]										 		,;
										aFilAux[nZ][3] 										 		,;
										aFilAux[nZ][11]										 		,;
										aFilAux[nZ][12]										 		})
					Next nZ
				EndIf
				
				nPosGroup := aScan(aGroupMark,{|z| z[1] == cCodAgr})		
				If nPosGroup > 0
					aAdd(aGroupMark[nPosGroup][4],{oMdlAOMGrid:GetValue("AOM_CODNIV"),oMdlAOMGrid:GetValue("AOM_NIVPAI"),aFilters})
				Else
					aAdd(aGroupMark,{cCodAgr,cTypeAgr,cAliasAgr, { {oMdlAOMGrid:GetValue("AOM_CODNIV"),oMdlAOMGrid:GetValue("AOM_NIVPAI"),aFilters} } })	
				EndIf
				aFilters	:= {}
				
			EndIf
			
		Next nY
		
	EndIf
	
Next nX

Return(aGroupMark)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMVMarkAOL

Controla o campo AOL_MARK do GRID AOL para permitir apenas uma linha marcada.

@sample	CRMVMarkAOL(oMdlAOL)

@param		oMdlAOL	- Objeto do modelo de dados atual.
@return	.T.			- Sempre retorna verdadeiro para efetivar a validacao.

@author	Jonatas Martins
@since		23/04/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRMVMarkAOL(oMdlAOL)

Local oView		:= FwViewActive()
Local nLinAtu		:= oMdlAOL:GetLine()  
Local lMark	 	:= oMdlAOL:GetValue("AOL_MARK")
Local nX			:= 0

For nX := 1 To oMdlAOL:Length()
	oMdlAOL:GoLine(nX)
	oMdlAOL:LoadValue("AOL_MARK",.F.)
Next nX

oMdlAOL:GoLine(nLinAtu)
oMdlAOL:LoadValue("AOL_MARK",lMark)

oView:Refresh()

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580EF3N
F3 do Agrupador para retornar o nivel selecionado. 

@sample	CRMA580EF3N

@param		Nenhum

@return	Nenhum
@author	Anderson Silva
@since		12/05/2015
@version	12.5
/*/
//------------------------------------------------------------------------------
Function CRMA580EF3N()
Local aAreaA00	:= A00->(GetArea())
Local aAreaAOM	:= AOM->(GetArea())
Local oMdlActive	:= FwModelActive()
Local cCodTerPai	:= ""
Local cCodAgr		:= ""

If oMdlActive <> Nil
	Do Case
		Case oMdlActive:GetId() == "CRMA640"	
			cCodTerPai	:= FwFldGet("AOY_SUBTER")
			cCodAgr	:= FwFldGet("AOZ_CODAGR")
			
			If !Empty(cCodTerPai)					
				//-------------------------------------------------------------------
				// Função que monta filtros do F3 na hierarquia de territórios pais
				//-------------------------------------------------------------------			
				CRM580EF3Fil(cCodAgr)				
			Else
				cCodAgr := FwFldGet('AOZ_CODAGR')
			EndIf
						
		Case oMdlActive:GetId() == "CRMA650"
			cCodAgr := FwFldGet('A01_CODAGR')
		Case oMdlActive:GetId() == "CRMA940"
			cCodAgr := FwFldGet('AZ9_CODAGR')
		Case oMdlActive:GetId() == "CRMA720"
			cCodAgr := FwFldGet('AOT_CODAGR')
		Case oMdlActive:GetId() == "CNTA230"
			cCodAgr := FwFldGet('CNL_CODAGR')
	EndCase
	
	If ! Empty(cCodAgr)	
		CRMA580ELookup( cCodAgr )
	Else
		MsgStop(STR0005) //"Código do agrupador não foi informado!"
	EndIf
	
Else
	MsgStop(STR0005) //"Código do agrupador não foi informado!"
EndIf

RestArea(aAreaAOM)
RestArea(aAreaA00)
Return .T. 

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM580EF3Fil
Função que busca o níves que devem ser filtrados no F3. 

@sample	CRM580EFilF3()

@param		cCodAgr, caracter, Código do agrupador

@return	Nenhum
@author	Jonatas Martins
@since		28/07/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Static Function CRM580EF3Fil(cCodAgr)

Local aFather	:= {}
Local aAgrup	:= {}
Local nX		:= 0
Local nPos		:= 0

Default cCodAgr := ""

_F3FilNiv := {}

//---------------------------------------------------
// Função que obtem a estrutura de territórios pais
//---------------------------------------------------
aFather := CRMA640AFather(FwFldGet("AOY_CODTER"))


For nX := 1 To Len(aFather)
	//----------------------------------------------------------------------
	// Função que obtem a estrutura de agrupadores e níveis dos territórios
	//----------------------------------------------------------------------
	aAgrup := CRMA640AgrTer(aFather[nX])
	
	nPos := aScan( aAgrup, { |x| x == cCodAgr } )
	
	//--------------------------------------------------------------------------------
	// Verifica se o agrupador existe na estrutura e busca os níveis para filtrar
	//--------------------------------------------------------------------------------
	If nPos > 0
		_F3FilNiv := CRMA640ANivAgr(aFather[nX],cCodAgr)
		Exit
	EndIf
Next nX			
				
Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580EGFil

Função que retorna o array de agrupadores filtrados no território

@sample	CRMA580EGFil()

@param		Nenhum

@return	_F3FilNiv, array, Variável de filtros dos agrupadores

@author	Jonatas Martins
@since		28/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580EGFil()
Return(_F3FilNiv)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA580EClF

Função que limpa o array de filtros dos níveis dos agrupadores 

@sample	CRMA580EClF()

@param		Nenhum

@return	.T., lógico, Indicando que o array está vazio 

@author	Jonatas Martins
@since		28/05/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA580EClF()
_F3FilNiv := {}
Return(.T.)

///-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580ELookup
Monta a consulta específica de níveis de agrupadores com carga dinâmica. 

@param cPool, caracter, Código do agrupador. 

@author  Valdiney V GOMES 
@version P12
@since   15/10/2015 
/*/
//-------------------------------------------------------------------
Function CRMA580ELookup( cPool ) 
	Local oDialog	:= Nil  
	Local oPanel	:= Nil
	Local oTree		:= Nil 
	Local aLevel	:= {}
	Local cRoot		:= CRMA580Root()
	Local bOK  	   	:= {|| _F3NvlSel := oTree:GetCargo(), oDialog:DeActivate() } 
	Local bCancel	:= {||  oDialog:DeActivate() } 
	
	Default cPool 	:= ""	
	
	//-------------------------------------------------------------------
	// Monta o janela de seleção de território. 
	//-------------------------------------------------------------------  
	oDialog := FWDialogModal():New()
	oDialog:SetBackground( .T. )
	oDialog:SetTitle( STR0002 ) 
	oDialog:SetSize( 200, 300 ) 
	oDialog:EnableFormBar( .T. )
	oDialog:SetCloseButton( .F. )
	oDialog:SetEscClose( .F. ) 
	oDialog:CreateDialog() 
	oDialog:CreateFormBar()
	oDialog:AddButton( STR0006, bOK, STR0006, , .T., .F., .T., ) //"Confirmar"
	oDialog:AddButton( STR0007, bCancel, STR0007, , .T., .F., .T., ) //"Cancelar"
	
	//-------------------------------------------------------------------
	// Recupera o container para a DBTree.  
	//-------------------------------------------------------------------		
	oPanel := oDialog:GetPanelMain()
	
	//-------------------------------------------------------------------
	// Monta a DBTree.  
	//-------------------------------------------------------------------		
	oTree := DBTree():New( 0, 0, 0, 0, oPanel, {|| CRMA580ETree( oTree, cPool, oTree:GetCargo(), aLevel ) },, .T. )	//"Carregando subníveis!"
	oTree:Align := CONTROL_ALIGN_ALLCLIENT
	oTree:BeginUpdate() 

	//-------------------------------------------------------------------
	// Adiciona o nó pai.    
	//-------------------------------------------------------------------	
	If ( AOL->( DBSeek( xFilial("AOL") + cPool ) ) )	
		oTree:AddItem( PadR( AOL->AOL_RESUMO, 200 ), PadR( cRoot, Len( cRoot ) + 1 ) , "FOLDER12" ,"FOLDER13",,, 1 )
	EndIf 
	
	//-------------------------------------------------------------------
	// Insere os níveis no DBTree.    
	//-------------------------------------------------------------------	
	CRMA580ETree( oTree, cPool, cRoot, aLevel )
	
	oDialog:Activate()
Return 

///-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580ETree
Insere os níveis dinâmicamente na árvore. 

@param oTree, objeto, Objeto do DBTree. 
@param cPool, caracter, Código do agrupador. 
@param cLevel, caracter, Código do nível. 
@param aLevel, array, Interno. 

@author  Valdiney V GOMES 
@version P12
@since   15/10/2015 
/*/
//-------------------------------------------------------------------
Static Function CRMA580ETree( oTree, cPool, cLevel, aLevel  )
	Local nLevel	:= 0

	Default aLevel	:= {}	
	Default cPool	:= ""
	Default cLevel	:= ""
 
	nLevel := aScan( aLevel ,{|x| x == cLevel } )
 
	If ( Empty( nLevel ) )
		//-------------------------------------------------------------------
		// Verifica se deve carregar os filhos do nível.    
		//-------------------------------------------------------------------
		If ( oTree:TreeSeek( "_" + cLevel ) .Or. ( cLevel == CRMA580Root() ) )
			//-------------------------------------------------------------------
			// Adiciona o nível na lista de níveis carregados.    
			//-------------------------------------------------------------------
			aAdd( aLevel, cLevel )
			
			//-------------------------------------------------------------------
			// Adiciona os níveis dinâmicamente no DBTree.    
			//-------------------------------------------------------------------
			Processa( {|| CRMA580ENode( oTree, cPool, cLevel, aLevel ) }, STR0008, "" ) //"Carregando níveis..."
		EndIf
	EndIf 
Return

///-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580ENode
Adiciona os níveis dinâmicamente na árvore. 

@param oTree, objeto, Objeto do DBTree. 
@param cPool, caracter, Código do agrupador. 
@param cLevel, caracter, Código do nível. 
@param aLevel, array, Interno. 

@author  Valdiney V GOMES 
@version P12
@since   15/10/2015 
/*/
//-------------------------------------------------------------------
Static Function CRMA580ENode( oTree, cPool, cLevel, aLevel  )
	Local aChild	:= {}
	Local aFilter	:= {}
	Local nChild	:= 0
	Local nFilter	:= 0
	Local cParent	:= ""

	Default aLevel	:= {}	
	Default cPool	:= ""
	Default cLevel	:= ""

	oTree:BeginUpdate() 
	
	//-------------------------------------------------------------------
	// Recupera os filhos do nível.    
	//-------------------------------------------------------------------		
	aChild 	:= CRMA580EChild( cPool, cLevel )
	aFilter := CRMA580EGFil()
	
	//-------------------------------------------------------------------
	// Define a régua de processamento.    
	//-------------------------------------------------------------------		
	ProcRegua( Len( aChild ) )		

	//-------------------------------------------------------------------
	// Remove o "aguarde" do nível.    
	//-------------------------------------------------------------------	
	If ( oTree:TreeSeek( "_" + cLevel ) )
		oTree:DelItem()
	EndIf

	//-------------------------------------------------------------------
	// Percorre todos os itens do nível.    
	//-------------------------------------------------------------------	
	For nChild := 1 To Len( aChild )
		IncProc( aChild[nChild][4] )

		//-------------------------------------------------------------------
		// Localiza o item pai.    
		//-------------------------------------------------------------------		
		If ! ( cParent == aChild[nChild][3] )	
			cParent := aChild[nChild][3]
			oTree:TreeSeek( cParent )
		EndIf 	

		//-------------------------------------------------------------------
		// Verifica se tem filtro por nível.    
		//-------------------------------------------------------------------	
		nFilter := aScan( aFilter, {|x| x == aChild[nChild][2] } )
		
		//-------------------------------------------------------------------
		// Adiciona os nós filhos.    
		//-------------------------------------------------------------------		
		If ( Empty( aFilter ) .Or. ( ! Empty( nFilter ) ) )
			oTree:AddItem( aChild[nChild][2] + " - " + aChild[nChild][4], aChild[nChild][2], "", "",,,2 )
		EndIf 
		
		If ( ! Empty( aChild[nChild][5] ) )
			cParent := ""
			
			//-------------------------------------------------------------------
			// Localiza o item.    
			//-------------------------------------------------------------------	
			oTree:TreeSeek( aChild[nChild][2] )
			
			//-------------------------------------------------------------------
			// Adiciona o "aguarde" no nível.     
			//-------------------------------------------------------------------	
			oTree:AddItem( STR0009, "_" + aChild[nChild][2], "", "",,,2 ) //"Aguarde..."	
		EndIf 	
	Next nChild 

	oTree:TreeSeek( cLevel )
	oTree:EndUpdate()
	oTree:EndTree()
Return

///-------------------------------------------------------------------
/*/{Protheus.doc} CRMA580EChild
Retorna a lista de todos os níveis filhos de um agrupador e nível informado. 

@param cPool, caracter, Código do agrupador. 
@param cLevel, caracter, Código do nível. 

@author  Valdiney V GOMES 
@version P12
@since   15/10/2015 
/*/
//-------------------------------------------------------------------
Static Function CRMA580EChild( cPool, cLevel )
	Local aArea		:= GetArea()
	Local aChild 	:= {}
	Local aField	:= {}
	Local cTemp		:= GetNextAlias()
	Local cQuery	:= ""
	Local cSubQuery	:= ""
	Local cIDPool	:= ""
	Local cIDLevel 	:= ""
	Local cParent	:= ""
	Local cTitle	:= ""
	Local nChild	:= 0
	
	Default cPool	:= ""
	Default cLevel 	:= ""

	//-------------------------------------------------------------------
	// Monta a instrução SQL para recuperar filhos de um nível.  
	//-------------------------------------------------------------------
	cSubQuery := " SELECT"
	cSubQuery += "		COUNT( R_E_C_N_O_ )"
	cSubQuery += " FROM "
	cSubQuery +=		RetSQLName("AOM") 
	cSubQuery += " WHERE "
	cSubQuery += "		AOM_CODAGR = '" + cPool + "'"
	cSubQuery += " 		AND "
	cSubQuery += " 		AOM_FILIAL = '" + xFilial( "AOM" ) + "'"
	cSubQuery += "		AND" 
	cSubQuery += "		AOM_NIVPAI = AOM.AOM_CODNIV" 
	cSubQuery += " 		AND "
	cSubQuery += " 		AOM.D_E_L_E_T_ = ' '"

	//-------------------------------------------------------------------
	// Monta a instrução SQL para recuperar os níveis.  
	//-------------------------------------------------------------------	
	cQuery := " SELECT " 
	cQuery += " 	AOM.AOM_CODAGR, AOM.AOM_CODNIV, AOM.AOM_NIVPAI, AOM.AOM_DESCRI, ( " + cSubQuery + " ) AOM_FILHO"
	cQuery += " FROM " 
	cQuery += 		RetSQLName("AOM") + " AOM "
	cQuery += " WHERE "
	cQuery += " 	AOM.AOM_CODAGR = '" + cPool + "'"
	cQuery += " 	AND "
	cQuery += " 	AOM.AOM_NIVPAI = '" + cLevel + "'"
	cQuery += " 	AND "
	cQuery += " 	AOM.AOM_FILIAL = '" + xFilial( "AOM" ) + "'"
	cQuery += " 	AND "
	cQuery += " 	AOM.D_E_L_E_T_ = ' '"
	cQuery += " ORDER BY" 
	cQuery += " 	AOM.AOM_NIVPAI"

	//-------------------------------------------------------------------
	// Executa a instrução SQL.  
	//-------------------------------------------------------------------	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, ChangeQuery( cQuery ) ), cTemp, .F., .T. )	

	//-------------------------------------------------------------------
	// Percorre todos os subníveis de um nível.  
	//-------------------------------------------------------------------
	While ( ! (cTemp)->( Eof() ) )
		//-------------------------------------------------------------------
		// Recupera os atributos do nível.  
		//-------------------------------------------------------------------
		cIDPool		:= (cTemp)->AOM_CODAGR
		cIDLevel 	:= (cTemp)->AOM_CODNIV	
		cParent		:= (cTemp)->AOM_NIVPAI
		cTitle		:= AllTrim( (cTemp)->AOM_DESCRI )
		nChild		:= (cTemp)->AOM_FILHO
		
		//-------------------------------------------------------------------
		// Lista todos os subníveis de um nível.   
		//-------------------------------------------------------------------
		aAdd( aChild, { cIDPool, cIDLevel, cParent, cTitle, nChild  } )

		(cTemp)->( DBSkip() )	
	Enddo

	//-------------------------------------------------------------------
	// Fecha a área de trabalho temporária.    
	//-------------------------------------------------------------------
	(cTemp)->( DBCloseArea() )	
	RestArea(aArea) 
Return aChild 