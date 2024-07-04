#include "CRMA130A.CH" 
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
  
Static oTree := Nil 

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

Modelo de dados do Cadastro de Especificações.

@sample		ModelDef()

@param			Nenhum

@return		ExpO1 - Objeto MPFormModel

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStruAO0 		:= FWFormStruct(1,"AO0",/*bAvalCampo*/,/*lViewUsado*/,/*lVirtual*/)
Local bCommit	 		:= {|oModel| CRMA130Cmt(oModel)}		

oModel := MPFormModel():New("CRMA130A",/*bPreValidacao*/,/*bPosValidacao*/,bCommit,/*bCancel*/)

oModel:AddFields("AO0MASTER",/*cOwner*/,oStruAO0,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:SetPrimaryKey({ 'AO0_FILIAL', 'AO0_CODESP' })	

oModel:SetDescription(STR0001)  //"Cadastro de Especificações"
oModel:GetModel("AO0MASTER"):SetDescription("AO0")

Return (oModel)


//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

Interface do Cadastro de Especificações.	

@sample		ViewDef()

@param			Nenhum

@return		ExpO1 - Objeto FWFormView

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oModel   := FWLoadModel("CRMA130A") 
Local oStruAO0 := FWFormStruct(2,"AO0")

oView := FWFormView():New()
oView:SetModel(oModel)

//Remove da View
oStruAO0:RemoveField( "AO0_DTULTM" )
oStruAO0:RemoveField( "AO0_HRULTM" )

oView:AddField("VIEW_AO0",oStruAO0,"AO0MASTER")
oView:AddOtherObject("VIEW_OBJ", {|oPanel| AddTreeEnt(oPanel, oModel)})

//Especificações
oView:CreateHorizontalBox("SUPERIOR",20)
oView:EnableTitleView("VIEW_AO0",STR0002)//"Especificações"

//Entidades
oView:CreateHorizontalBox("INFERIOR",80)
oView:EnableTitleView("VIEW_OBJ",STR0003)//"Entidades"

oView:SetOwnerView("VIEW_AO0","SUPERIOR")
oView:SetOwnerView("VIEW_OBJ","INFERIOR")

oView:SetCloseOnOk({|| .T.} )

//Ações Relacionadas
If FunName() == "CRMA130"
	oView:AddUserButton(STR0004,"",{|oView| SaveInter(), MsDocument("AO0",AO0->(RECNO()),4), RestInter() },,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} )//"Anexar"
EndIf
oView:AddUserButton(STR0005,"",{|oView| SaveInter(), MsDocument("AO0",AO0->(RECNO()),1), RestInter() },,,{MODEL_OPERATION_VIEW,MODEL_OPERATION_UPDATE} )//"Visualizar Anexo"
Return (oView)


//------------------------------------------------------------------------------
/*/{Protheus.doc} AddTreeEnt

Função para adicionar a árvore na tela.

@sample		AddTreeEnt(oPanel, oModel)

@param			ExpO1 - Objeto Panel
				ExpO2 - Objeto MPFormModel

@return		ExpL - Verdadeiro

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function AddTreeEnt(oPanel, oModel)

Local lRet			:= .T.
Local oMenuPop	:= Nil
Local aMenuPop	:= {}
Local aArea 		:= GetArea() 
Local aAreaAO1	:= AO1->(GetArea())
Local cAliasAO1  	:= GetNextAlias()
Local cIdTree		:= "AO0"+Space(100)
Local cCodEsp		:= ""
Local dDataAtu	:= Date()
Local dHoraAtu	:= Time()
Local nOperation	:= oModel:GetOperation()

If nOperation == MODEL_OPERATION_UPDATE
	//Passa a data e hora da modificação da tree
	oModel:SetValue("AO0MASTER","AO0_DTULTM",dDataAtu)
	oModel:SetValue("AO0MASTER","AO0_HRULTM",dHoraAtu)
EndIf
	
oTree := DbTree():New(0,0,000,000,oPanel,,,.T.)	// Adiciona a tree na view
oTree:Align := CONTROL_ALIGN_ALLCLIENT
oTree:AddItem(STR0006+Space(200),cIdTree,"FOLDER12","FOLDER12",,,1)  // PAI //"Entidades"
oTree:Cargo := {}

aAdd(oTree:Cargo,{cIdTree,"RAIZ","NMOD"})
aAdd(oTree:Cargo[1],{})

//Monta a tree inicial baseada na tabela AO1
CRMA130MntTree(oTree)

MENU oMenuPop POPUP OF oTree

aAdd(aMenuPop,MenuAddItem(STR0007,,,.T.,,,,oMenuPop,{|| CRMA130ActTree(oTree,"EXCPAI") 	},,,,,{ || .T. } )) 	//"Limpar Entidades"
aAdd(aMenuPop,MenuAddItem(STR0008,,,.T.,,,,oMenuPop,{|| CRMA130ActTree(oTree,"ANXENT") 	},,,,,{ || .T. } )) 																				//"Anexar Entidade"
aAdd(aMenuPop,MenuAddItem(STR0009,,,.T.,,,,oMenuPop,{|| CRMA130ActTree(oTree,"EXCENT")   	},,,,,{ || .T. } ))  																			//"Excluir Entidade"
aAdd(aMenuPop,MenuAddItem(STR0010,,,.T.,,,,oMenuPop,{|| CRMA130ActTree(oTree,"ANXREG") 	},,,,,{ || .T. } ))																			 //"Anexar Registro"
aAdd(aMenuPop,MenuAddItem(STR0011,,,.T.,,,,oMenuPop,{|| CRMA130ActTree(oTree,"EXCREG") 	},,,,,{ || .T. } ))		//"Excluir Registro"
aAdd(aMenuPop,MenuAddItem(STR0012,,,.T.,,,,oMenuPop,{|| CRMA130ActTree(oTree,"VIS" ) } ))	//"Visualizar"

ENDMENU

oTree:BrClicked := {|oTree,x,y| MenuAct(oTree,x,y,oMenuPop,nOperation) } // Posição x,y em relação a Dialog	

oTree:EndTree() 

RestArea(aAreaAO1)
RestArea(aArea)

Return lRet


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA130MntTree

Função para montar a estrutura de entidades.

@sample		CRMA130MntTree(oTree)

@param			ExpO1 - Objeto Tree

@return		Nenhum

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function CRMA130MntTree(oTree)

Local aArea 		:= GetArea()
Local aAreaAO1 	:= AO1->(GetArea())
Local cCodEsp		:= AO0->AO0_CODESP
Local cAliasAO1		:= GetNextAlias()
Local cDescAlias	:= ""
Local aDadosSX2	:= {}
Local nPosEnt		:= 0
Local cChave		:= ""
Local cIdTree		:= ""
Local cEntidad	:= ""
Local aCargo 		:= oTree:Cargo[1][4] // Entidades

BeginSql Alias cAliasAO1

	SELECT AO1.AO1_CODESP CODESP, AO1.AO1_ALIAS ALIAS_ENT, AO1.AO1_UNICO UNICO	
	FROM %Table:AO1% AO1		
	WHERE AO1.AO1_CODESP = %Exp:cCodEsp% 			
	AND AO1.%notDel%		
	ORDER BY AO1.R_E_C_N_O_
 	 
EndSql

While (cAliasAO1)->(!Eof())
	
	// Se não possui AO1_UNICO, posiciona no pai para incluir entidade
	If Empty((cAliasAO1)->UNICO) .And. oTree:TreeSeek("AO0") 
		// Chave da amarracao entidade ou registro.
		cChave := (cAliasAO1)->ALIAS_ENT
		
		// Varre o array a procura da chave da entidade
		nPosEnt := aScan(aCargo,{|x| x[2] == AllTrim(cChave) })	 
		 
		If nPosEnt == 0
			cIdTree := AllTrim(cChave)
			cChave  := AllTrim(cChave)
			// Adiciona a entidade ao array
			aAdd(aCargo,{cIdTree,cChave,"NMOD",{}})
			cDescAlias	:= Posicione("AO2",1,xFilial("AO2")+cChave,"AO2->AO2_DESCR")
			oTree:AddItem(cDescAlias,cIdTree,"PMSTASK6","PMSTASK6",,,2)
		EndIf
		
	// Posiciona na entidade para incluir os registros
	ElseIf oTree:TreeSeek(AllTrim((cAliasAO1)->ALIAS_ENT))

		cChave := (cAliasAO1)->UNICO
		// Pega a posição no array da entidade a qual o registro pertence
		nPosEnt := aScan(aCargo,{|x| x[1] == AllTrim((cAliasAO1)->ALIAS_ENT) })
		
		If nPosEnt > 0
			// Varre o array a procura da chave do registro
			nPosReg := aScan(aCargo[nPosEnt][4],{|x| x[2] == AllTrim(cChave) })	
			
			If nPosReg == 0
				cEntidad := aCargo[nPosEnt][2]
				cIdTree  := AllTrim(cEntidad+"|"+AllTrim(cChave))
				// Adiciona o registro ao array
				aAdd(aCargo[nPosEnt][4],{cIdTree,cChave,"NMOD"})
				cDisplay := Alltrim(CRMXGetSX2(AllTrim((cAliasAO1)->ALIAS_ENT))[2])
				DbSelectArea(cEntidad)
				DbSetOrder(1)
				If (cEntidad)->(DbSeek(AllTrim(cChave))) // Posiciona no registro para pegar o X2_DISPLAY
					cDescri := (cEntidad)->&(cDisplay) 
					oTree:AddItem(cDescri,cIdTree,"PMSTASK4","PMSTASK4",,,2) 
				EndIf
			EndIf
	
		EndIf
	
	EndIf
	
	(cAliasAO1)->(DbSkip())
End

RestArea(aAreaAO1)
RestArea(aArea)

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA130ActTree

Consulta para trazer as entidades relacionadas à especificação (Especificações X Entidades (AO1)).

@sample		CRMA130ActTree(oTree,cAction)

@param			ExpO1 - Objeto Tree
				ExpC1 - Ação do menu

@return		Nenhum

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function CRMA130ActTree(oTree,cAction)

Local cCargo 		:= ""
Local cEntidade	:= ""
Local aDadosSX2	:= {}
Local cChave	 	:= ""
Local nPosEnt 	:= 0
Local cIdTree		:= ""
Local aCargo 		:= oTree:Cargo[1][4] // Entidades
Local nX			:= 0
Local nY			:= 0
Local cUnico		:= ""

//----Status da entidade/ registro no array-----

// [NMOD] 	Não modificado
// [MOD] 	Modificado
// [INC] 	Incluído
// [EXC] 	Excluído

Do Case

	Case cAction == "EXCPAI"
		
		oTree:Cargo[1][3] := "EXC"
		
		For nX := 1 To Len(aCargo)
			//Marca como excluido todas as entidades 
			aCargo[nX][3] := "EXC"			
			//Marca como excluido todos os registros
			For nY := 1 To Len(aCargo[nX][4])
				aCargo[nX][4][nY][3] := "EXC"
			Next nY
		Next nX
		
		oTree:Reset()
		
		cIdTree		:= "AO0"+Space(100)
		oTree:AddItem(STR0013+Space(200),cIdTree,"FOLDER12","FOLDER12",,,1)  // Adiciona o PAI novamente //"Entidades"
		
		oTree:Refresh()
		
	Case cAction == "ANXENT"
	
		If ConPad1(,,,"AO2",,,.F.)
			
			cChave := AO2->AO2_ENTID
			nPosEnt := aScan(aCargo,{|x| AllTrim(x[2]) == AllTrim(cChave) })	 
		 
		 	If oTree:Cargo[1][3] == "EXC"
				oTree:Cargo[1][3] := "NMOD"
			EndIf
		 
			If nPosEnt == 0
				cIdTree := AllTrim(cChave)
				cChave  := AllTrim(cChave)
				aAdd(aCargo,{cIdTree,cChave,"INC",{}})
				oTree:AddItem(AO2->AO2_DESCR,cIdTree,"PMSTASK6","PMSTASK6",,,2) 
			Else 			
				If aCargo[nPosEnt][3] 	== "EXC"
					aCargo[nPosEnt][3]	:= "INC"
					cIdTree := AllTrim(aCargo[nPosEnt][1])
					oTree:AddItem(AO2->AO2_DESCR,cIdTree,"PMSTASK6","PMSTASK6",,,2)
				Else
					Help("",1,"HELP",,STR0014,1)//"Esta entidade já pertence à estrutura."
				EndIf
			EndIf
				 
		EndIf	
		
	Case cAction == "EXCENT"
		
		nPosEnt := aScan(aCargo,{|x| AllTrim(x[1]) == AllTrim(oTree:GetCargo()) })	
		 
		If nPosEnt > 0
			aCargo[nPosEnt][3] := "EXC"
			//Marca como excluido todos os registros da entidade
			For nY := 1 To Len(aCargo[nPosEnt][4])
				aCargo[nPosEnt][4][nY][3] := "EXC"
			Next nY
			
			oTree:DelItem()
		Else
			Help("",1,"HELP",,STR0015,1)//"Problemas para excluir a entidade."
		EndIf
			
	Case cAction == "ANXREG" 
		
		cEntidade := AllTrim(CRMA130RetEnt(oTree))
		
		If ConPad1(,,,cEntidade,,,.F.) 
				
			aDadosSX2 := CRMXGetSX2(cEntidade)
			If Len(aDadosSX2) > 0
				cChave  := xFilial(cEntidade)+(cEntidade)->&(aDadosSX2[1])
				cDescri := (cEntidade)->&(aDadosSX2[2])
				
				nPosEnt := aScan(aCargo,{|x| AllTrim(x[1]) == AllTrim(oTree:GetCargo()) })
			
				If nPosEnt > 0
					
					nPosReg := aScan(aCargo[nPosEnt][4],{|x| AllTrim(x[2]) == AllTrim(cChave)})	
					
					If nPosReg == 0
						cEntidade := aCargo[nPosEnt][2]
						cIdTree  := AllTrim(cEntidade+"|"+AllTrim(cChave))
						aAdd(aCargo[nPosEnt][4],{cIdTree,cChave,"INC"}) 
						aCargo[nPosEnt][3] := "MOD"
						oTree:AddItem(cDescri,cIdTree,"PMSTASK4","PMSTASK4",,,2)
					Else
						If aCargo[nPosEnt][4][nPosReg][3] == "EXC"
							aCargo[nPosEnt][4][nPosReg][3] := "INC"
							cIdTree  := aCargo[nPosEnt][4][nPosReg][1]
							oTree:AddItem(cDescri,cIdTree,"PMSTASK4","PMSTASK4",,,2)
						Else
							Help("",1,"HELP",,STR0016,1)//"Este registro já pertence à estrutura."
						EndIf
					EndIf
			
				EndIf
			Else
				Help("",1,"HELP",,STR0017,1)//"Problemas incluir o registro."
			EndIf
				
		EndIf
		
	Case cAction == "EXCREG"
	
		nPosEnt := aScan(aCargo,{|x| SubStr(x[1],1,3) $ AllTrim(oTree:GetCargo()) })
	
		If nPosEnt > 0
			nPosReg := aScan(aCargo[nPosEnt][4],{|x| x[1] == AllTrim(oTree:GetCargo()) })	 
			If nPosReg > 0
				aCargo[nPosEnt][4][nPosReg][3] := "EXC"
				aCargo[nPosEnt][3] 				:= "MOD"
				oTree:DelItem()
			Else
				Help("",1,"HELP",,STR0018,1)//"Problemas excluir o registro."
			EndIf
		EndIf
				
	Case cAction == "VIS"
		 
		cEntidade	:= Left(AllTrim(oTree:GetCargo()),3)
		cUnico		:= SubStr(AllTrim(oTree:GetCargo()),5)
		CRMXGMnDef(cEntidade,cUnico) 

EndCase

Return


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA130RetEnt

Busca a entidade do registro.

@sample		CRMA130RetEnt(oTree)

@param			ExpO1 - Objeto Tree

@return		ExpC - Entidade

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function CRMA130RetEnt(oTree)

Local nPos 		:= aScan(oTree:Cargo[1][4],{|x| AllTrim(x[1]) == AllTrim(oTree:GetCargo()) }) //Retorna o ID da entidade
Local cRetorno 	:= ""

If nPos > 0 
	cRetorno := oTree:Cargo[1][4][nPos][2] //Retorna o Alias da entidade
EndIf

Return(cRetorno)


//------------------------------------------------------------------------------
/*/{Protheus.doc} MenuAct

Funcao de chamada do menu.

@sample 		MenuAct( oTree, nX, nY, oMenuPop ) 

@param			ExpO1		Objeto Tree
				ExpN1		Dimensao X
				ExpN2		Dimensao Y
				ExpO2	 	Objeto Menu		

@return		Nenhum

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function MenuAct( oTree, nX, nY, oMenuPop, nOperation)

Local cEntidade 	:= ""
Local cCargo		:= ""
            
//Desabilita todos os itens do menu 
AEval( oMenuPop:aItems, { |x| x:Disable() } ) 

cCargo 	:= AllTrim(oTree:GetCargo()) 
cEntidade	:= Left(AllTrim(oTree:GetCargo()),3)
If nOperation <> 1 //Visualizar
	If cCargo == "AO0"
		oMenuPop:aItems[1]:enable()//"Limpar Entidades"
		oMenuPop:aItems[2]:enable()//"Anexar Entidade"
	ElseIf Len(cCargo) == 3
		oMenuPop:aItems[3]:enable()//"Excluir Entidade"
		oMenuPop:aItems[4]:enable()//"Anexar Registro"
	Else	
		oMenuPop:aItems[5]:enable()//"Excluir Registro"
		If !Empty(CRMXGetSX2(cEntidade)[3])
			oMenuPop:aItems[6]:enable()//"Visualizar"
		EndIf
	EndIf
EndIf	

oMenuPop:Activate( nX-40, nY-280, oTree )
                                   
Return()   


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA130Cmt

Bloco de commit.

@sample 		CRMA130Cmt( oModel ) 

@param			ExpO1			Objeto MPFormModel	

@return		Nenhum

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function CRMA130Cmt(oModel)
Local bAfterTTS := {|| .T. }
	FWModelActive(oModel)
	FWFormCommit(oModel,{|oModel,cId,cAlias|CRMA130Bef(oModel,cId,cAlias)},Nil,bAfterTTS)
Return(.T.) 


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA130Bef

Chama exec auto.

@sample 		CRMA130Bef( oMdl130A,cId,cAlias ) 

@param			ExpO1			Objeto MPFormModel 
				ExpC1			ID 
				ExpC2			Alias

@return		Nenhum

@author		Cristiane Nishizaka
@since			07/02/2014
@version		12.0
/*/
//------------------------------------------------------------------------------

Static Function CRMA130Bef(oMdl130A,cId,cAlias)

Local aArea := GetArea()
Local nX := 0
Local nY := 0
Local cCodEsp		:= oMdl130A:GetValue("AO0_CODESP")
Local aCargo 		:= oTree:Cargo[1][4] // Entidades
Local aExecAuto	:= {}
Local nOperation	:= 0
Local lSeek		:= .F.

DbSelectArea("AO1")
AO1->(DbSetOrder(1))

If oTree:Cargo[1][3] == "EXC"

	If AO1->(DbSeek(xFilial("AO1")+cCodEsp))
		While  (AO1->(!Eof()) .AND. AO1->AO1_FILIAL == xFilial("AO1") .AND. AO1->AO1_CODESP == cCodEsp) 
			RecLock("AO1",.F.)
					AO1->(DbDelete())
			AO1->(MsUnLock())
			AO1->(DbSkip())
		End
	EndIf	 
	
Else

	For nX := 1 To Len(aCargo)
		// Processa entidades.
		If aCargo[nX][3] == "INC" .OR. aCargo[nX][3] == "MOD"
			If !AO1->(DbSeek(xFilial("AO1")+cCodEsp+aCargo[nX][2]+Space(TAMSX3("AO1_UNICO")[1])))
				RecLock("AO1",.T.)
					AO1->AO1_FILIAL := xFilial("AO1")
					AO1->AO1_CODESP := cCodEsp 
					AO1->AO1_ALIAS  := aCargo[nX][2]
				AO1->(MsUnLock())
			EndIf
		ElseIf aCargo[nX][3] == "EXC"		
			If AO1->(DbSeek(xFilial("AO1")+cCodEsp+aCargo[nX][2]))
				While ( AO1->(!Eof()) .AND. AO1->AO1_FILIAL == xFilial("AO1") .AND.;
						 AO1->AO1_CODESP == cCodEsp .AND. AO1->AO1_ALIAS == aCargo[nX][2])
						RecLock("AO1",.F.)
							AO1->(DbDelete())
						AO1->(MsUnLock())
					AO1->(DbSkip())
				End 
			EndIf
		ElseIf aCargo[nX][3] == "NMOD"
			Loop
		EndIf			
		// Processa registros
		For nY := 1 To Len(aCargo[nX][4])
		
			If aCargo[nX][4][nY][3] == "INC"
				If !AO1->(DbSeek(xFilial("AO1")+cCodEsp+aCargo[nX][2]+aCargo[nX][4][nY][2]))
					RecLock("AO1",.T.)
						AO1->AO1_FILIAL 	:= xFilial("AO1")
						AO1->AO1_CODESP	:= cCodEsp 
						AO1->AO1_ALIAS 	:= aCargo[nX][2]
						AO1->AO1_UNICO 	:= aCargo[nX][4][nY][2]
					AO1->(MsUnLock())
				Else // Verifica o proximo registro pois o mesmo já esta gravado.
					Loop
				EndIf
			ElseIf aCargo[nX][4][nY][3] == "EXC"
				If AO1->(DbSeek(xFilial("AO1")+cCodEsp+aCargo[nX][2]+aCargo[nX][4][nY][2]))
					While 	( AO1->(!Eof()) .AND. AO1->AO1_FILIAL == xFilial("AO1") .AND. AO1->AO1_CODESP == cCodEsp .AND.;
							 AO1->AO1_ALIAS == aCargo[nX][2] .AND. AO1->AO1_UNICO == aCargo[nX][4][nY][2] )
							RecLock("AO1",.F.)
								AO1->(DbDelete())
							AO1->(MsUnLock())
						AO1->(DbSkip())
					End 
				EndIf
			ElseIf aCargo[nX][3] == "NMOD"
				Loop
			EndIf			
		Next nY		
	Next nX  

EndIf
 
RestArea(aArea)

Return(.T.)

//Dummy Function
Function CR130ADummy()

Return Nil
