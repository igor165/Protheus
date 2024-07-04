#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "CRMA910.CH"

#DEFINE ALLOWED	"1"
#DEFINE DENIED	"2"

Static _oTree	 := Nil
Static aRetGrid  := {}
Static aVldVar	 := {"",""}

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Monta modelo de dados do Níveis do Agrupador Dinamico.
@sample		CRMA910A()
@param		Nenhum
@return		ExpO - Array com niveis selecionados
@author		SI2901 - Cleyton F.Alves
@since		11/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRMA910A( cVarClie,cVarPros )
	
Local oMdlProp	  := FwModelActivate()
Local oModel 	  := Nil
Local oMdlAOL	  := Nil
Local oMdlAOM	  := Nil
Local oView		  := Nil
Local oExecView   := Nil
Local aButtons    := {}
Local aReturn     := {}
Local lReleaseV12 := .F.

aVldVar := {cVarClie,cVarPros}

AOL->(dbSetOrder(1))

lReleaseV12 := StaticCall( CRMA910B, checkV1227 )
If lReleaseV12
	AOM->(dbSetOrder(3)) //AOM_FILIAL+AOM_CODAGR+AOM_NIVPAI
Else
	AOM->(dbSetOrder(1)) //AOM_FILIAL+AOM_CODAGR+AOM_CODNIV
EndIf

AZ0->(dbSetOrder(1))
AZ1->(dbSetOrder(1))
AZ2->(dbSetOrder(1))

oModel:= FWLoadModel("CRMA910A")

oModel:SetOperation(MODEL_OPERATION_UPDATE)

oModel:GetModel('AOLDETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('AOLDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('AOLDETAIL'):SetNoUpdateLine(.F.)
		
oModel:GetModel('AOMDETAIL'):SetNoDeleteLine(.T.)
oModel:GetModel('AOMDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('AOMDETAIL'):SetNoUpdateLine(.F.)

oModel:Activate()
		
If oModel:IsActive()

	aButtons := { {.F.,Nil},{.F.,Nil}    ,{.F.,Nil}    ,{.F.,Nil},{.F.,Nil},;
			  {.F.,Nil},{.T.,STR0020},{.T.,STR0021},{.F.,Nil},{.F.,Nil},;
			  {.F.,Nil},{.F.,Nil}    ,{.F.,Nil}    ,{.F.,Nil}}
	
	oView := FWLoadView("CRMA910A")
	oView:SetModel(oModel)
	
	oMdlAOL  := oModel:GetModel("AOLDETAIL")
	oMdlAOM  := oModel:GetModel("AOMDETAIL")
		
	If !oMdlAOL:IsEmpty()			
		oExecView := FWViewExec():New()
		oExecView:SetTitle(STR0001) //"Regras para Comercialização"
		oExecView:SetView(oView)
		oExecView:SetModal(.F.)
		oExecView:SetOperation(MODEL_OPERATION_UPDATE)
		oExecView:SetButtons(aButtons)
		oExecView:OpenView(.F.)
		aReturn  := aClone(aRetGrid)
		aRetGrid := {}	
	Else
		MsgAlert(STR0024) //"Cadastre uma regra de comercialização válida."
	EndIf
Else
	aError := oModel:GetErrorMessage()
	If !Empty( aError )
		Help("",1,"CRMA910A",,aError[6],1)
	EndIf
EndIf


oModel:DeActivate()
aRetGrid := {}	
FwModelActivate(oMdlProp)	

Return(aReturn)

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Monta modelo de dados do Níveis do Agrupador Dinamico.
@sample		ModelDef()
@param		Nenhum
@return		ExpO - Modelo de Dados
@author		SI2901 - Cleyton F.Alves
@since		11/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()

Local oModel 	 := Nil
Local oMdlAOL    := Nil
Local oMdlAOM    := Nil

Local oStructCAB := FWFormModelStruct():New()
Local oStructAOL := FWFormStruct(1,"AOL"  ,/*bAvalCampo*/,/*lViewUsado*/)
Local oStructAOM := FWFormStruct(1,"AOM"  ,/*bAvalCampo*/,/*lViewUsado*/)
Local bCarga	 := {|| {xFilial("AOL")}}

oStructCAB:AddField("","","CABEC_FILIAL","C",FwSizeFilial(),0)
oStructAOL:AddField("","","AOL_MARK"	,"L",1,0,{|oMdlAOL| CRMVMarkAOL(oMdlAOL)},Nil,Nil,Nil,Nil,Nil,Nil,.T.)
oStructAOM:AddField("","","AOM_MARK"	,"L",1,0,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

oModel := MPFormModel():New("CRMA910A",/*bPreValidacao*/,/*bPosVldMdl*/,/*bCommitMdl*/,/*bCancel*/)

oModel:AddFields("CABMASTER",/*cOwner*/,oStructCAB,/*bPreValidacao*/,/*bPosVldMdl*/,bCarga)
oModel:AddGrid("AOLDETAIL" ,"CABMASTER",oStructAOL,/*bPreValid*/    ,/*bPosVldMdl*/,/*bLoad*/  )
oModel:AddGrid("AOMDETAIL" ,"AOLDETAIL",oStructAOM,/*bLinPre  */    ,/*bLinePost */,/*bPreVal*/,/*bPosVldGrid*/,/*bLoad*/)

oModel:SetRelation("AOLDETAIL",{{"AOL_FILIAL","xFilial('AOL')"}},AOL->(IndexKey(1)))
oModel:SetRelation("AOMDETAIL",{{"AOM_FILIAL","xFilial('AOM')"},{"AOM_CODAGR","AOL_CODAGR"}},AOM->(IndexKey(1)))

oModel:GetModel("AOLDETAIL"):bLoad:={|oMdlAOL| CRM910AOL(oMdlAOL) }
oModel:GetModel("AOLDETAIL"):SetOptional(.T.)
oModel:GetModel("AOLDETAIL"):SetOnlyQuery(.T.)

oModel:GetModel("AOMDETAIL"):bLoad:={|oMdlAOM| CRM910AOM(oMdlAOM,oModel:GetModel("AOLDETAIL"):GetValue("AOL_CODAGR")) }
oModel:GetModel("AOMDETAIL"):SetOptional(.T.)
oModel:GetModel("AOMDETAIL"):SetOnlyQuery(.T.)

oModel:SetPrimaryKey({""})

oModel:GetModel("CABMASTER"):SetDescription(STR0002) //"Agrupador de Registros"
oModel:GetModel("AOLDETAIL"):SetDescription(STR0003) //"Agrupadores"
oModel:GetModel("AOMDETAIL"):SetDescription(STR0004) //"Níveis do Agrupador"

oModel:SetDescription(STR0001) //"Regras para Comercialização"

oModel:bCommit := {|oModel| (CRM910Agrv(oModel),.T.) }

Return oModel

//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Monta interface do Níveis do Agrupador Dinamico.

@sample	ViewDef()
@param		Nenhum

@return	ExpO - Interface do Agrupador de Registros
@author	SI2901 - Cleyton F.Alves
@since		11/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()

Local oStructAOL	:= FWFormStruct(2,"AOL",{|cCampo| AllTrim(cCampo) $ "AOL_CODAGR|AOL_RESUMO|AOL_ENTIDA|AOL_DSCENT|AOL_TIPO|"},/*lViewUsado*/)
Local oStructAOM	:= FWFormStruct(2,"AOM",/*bAvalCampo*/,/*lViewUsado*/)
Local oModel   		:= FWLoadModel('CRMA910A')
Local oView			:= Nil
Local oPanel		:= Nil

oStructAOL:AddField("AOL_MARK","01","Forecast","Forecast",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)
oStructAOM:AddField("AOM_MARK","01","","",{},"L","@BMP",Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil,.T.)

oView:=FWFormView():New()
oView:SetModel(oModel)
oView:AddGrid("VIEW_AOL",oStructAOL,"AOLDETAIL")

oView:CreateHorizontalBox("SUPERIOR",30)
oView:CreateHorizontalBox("INFERIOR",70)

oView:AddOtherObject ("OBJ_TREE",{|oPanel| CRM910ATree(oPanel,oView,oView:GetModel())})
oView:SetViewProperty('VIEW_AOL',"CHANGELINE",{ { || Processa( {|| CRMA910ALdTree( Nil, oView:GetModel() ) }, STR0045, "" ) } } ) //"Carregando níveis do agrupador..."

//Painel Superior
oView:SetOwnerView("VIEW_AOL","SUPERIOR")
oView:EnableTitleView("VIEW_AOL",STR0003) //"Agrupadores"

//Painel Inferior Direito
oView:SetOwnerView("OBJ_TREE","INFERIOR" )
oView:EnableTitleView("OBJ_TREE",STR0004) //"Agrupadores"


Return oView

//------------------------------------------------------------------------------
/*/	{Protheus.doc} CRM910ATree

Cria o objeto DbTree.

@sample		(oPanel,oViewActive,oMdlActive)

@param		ExpO1 - Panel AddOtherObject
ExpO2 - FWFormView Ativa
ExpO3 - MPFormModel Ativo

@return		Nenhum

@author		Cleyton F.Alves
@since		11/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Function CRM910ATree(oPanel,oViewActive,oMdlActive)
	
Local oTree	 		:= Nil
Local oMdlAOLGrid	:= oMdlActive:GetModel("AOLDETAIL")
Local oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
Local cAOLResumo	:= AOL->AOL_RESUMO

oTree := DbTree():New(0,0,000,000,oPanel,{|| .T. },{|| .T. },.T.)	// Adiciona a tree na view
oTree:Align := CONTROL_ALIGN_ALLCLIENT
oTree:AddItem(cAOLResumo+Space(200),CRMA580Root(),"FOLDER12","FOLDER13",,,1)  // RAIZ //"Entidades

// carregando a tree com os dados
If ! ( oMdlAOMGrid:IsEmpty() )
	Processa( {|| CRMA910ALdTree( oTree, oMdlActive ) }, STR0045, "" ) //"Carregando níveis do agrupador..."
EndIf

//Clique com botao esquerdo do mouse
oTree:BLClicked	:= {|| CRM910ATClick(oTree,oViewActive,oMdlActive) }

oTree:EndTree()
CRMA580DSTree(oTree)

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM910ATClick

Funcao que marca e desmarca o DbTree

@sample		CRM910ATClick(oTree,oViewActive,oMdlActive)

@param		ExpO1 - Componente DBTree
			ExpO2 - FwFormView do Agrupador de Registros
			ExpO3 - MPFormModel do Agrupador de Registros

@return		Nenhum

@author		Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRM910ATClick(oTree,oViewActive,oMdlActive)

Local oMdlAOMGrid	:= oMdlActive:GetModel("AOMDETAIL")
Local cIdTree		:= AllTrim(oTree:GetCargo())
Local cCodIntPos	:= ""
Local nLinAtu		:= 0
Local cCodAgr       := ""
Local cCodNiv       := ""
Local cCodTab		:= GetNextAlias()
Local cCodUsr		:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr())
Local cQuery		:= ""
Local nTamGrid		:= 1
Local nx			:= 0
Local lAcess		:= .T.
Local lMarkUniq		:= .F.
Local lC910AUNQ		:= ExistBlock("CR910AUNQ")

If lC910AUNQ
	lMarkUniq := ExecBlock("CR910AUNQ",.F.,.F.,{oMdlAOMGrid})
EndIf

If lMarkUniq
	nTamGrid := oMdlAOMGrid:Length()
EndIf

If cIdTree <> CRMA580Root() .AND. oMdlAOMGrid:SeekLine({{"AOM_CODNIV",cIdTree}})
	
	If oMdlAOMGrid:GetValue("AOM_MSBLQL") <> "1"
		
		nLinAtu	:= oMdlAOMGrid:GetLine()
		
		For nx := 1 To nTamGrid

			If lMarkUniq
				oMdlAOMGrid:GoLine(nx)
			Else
				oMdlAOMGrid:GoLine(nLinAtu)
			EndIf
		
			lAcess := CRM910Access( oMdlAOMGrid:GetValue( 'AOM_CODAGR' ), oMdlAOMGrid:GetValue( 'AOM_CODNIV' ) ) 	
		
			If lAcess
				If lMarkUniq
					If nx == nLinAtu
						oTree:ChangeBmp("LBOK","LBOK",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
						oMdlAOMGrid:SetValue("AOM_MARK",.T.)
					Else
						oTree:ChangeBmp("LBNO","LBNO",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
						oMdlAOMGrid:SetValue("AOM_MARK",.F.)
					EndIf
				Else
					If oMdlAOMGrid:GetValue("AOM_MARK")
						oTree:ChangeBmp("LBNO","LBNO",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
						oMdlAOMGrid:SetValue("AOM_MARK",.F.)
					Else
						oTree:ChangeBmp("LBOK","LBOK",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
						oMdlAOMGrid:SetValue("AOM_MARK",.T.)
					EndIf
				EndIf	
			Else
				oTree:ChangeBmp("","",,,oMdlAOMGrid:GetValue("AOM_CODNIV"))
				oMdlAOMGrid:SetValue("AOM_MARK",.F.)
			Endif
		
		Next nx
		
		oMdlAOMGrid:GoLine(nLinAtu)
		
	Else
		MsgAlert(STR0005) //"Registro Bloqueado!"
	EndIf
	
EndIf

oViewActive:Refresh()

Return Nil

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA910ALdTree
Carrega o componente DbTree com os Níveis do Agrupador.

@param	oTree, objeto, Objeto do DBTree.
@param	oActive, objeto, Modelo de dados ativo. 

@author		Cleyton F Alves
@author		Valdiney V GOMES
@version	12
@since		10/06/2015
/*/
//------------------------------------------------------------------------------
Static Function CRMA910ALdTree( oTree, oActive )
	Local oAOMGrid		:= Nil 
	Local oAOLGrid		:= Nil
	Local cImage		:= ""
	Local cFather		:= ""
	Local nLevel		:= 0
	Local lAddItem		:= .T.
	Local cTree			:= ""
	Local lCRM910ldT	:= ExistBlock("CRMA910LdT") // PE Load Tree para validar se o item pode ser carregado
	Local aBanned		:= {}
	Local aDeleta		:= {} //Array para verificar se o item será deletado depois
	Local nBitmap		
	Local nI
	Default oActive := FWModelActive()
	Default oTree 	:= CRMA580DGTree()
	
	//-------------------------------------------------------------------
	// Recupera o modelo de dados.    
	//-------------------------------------------------------------------
	oAOMGrid 	:= oActive:GetModel("AOMDETAIL")
	oAOLGrid	:= oActive:GetModel("AOLDETAIL")

	//-------------------------------------------------------------------
	// Inicia a montagem de árvore.    
	//-------------------------------------------------------------------
	oTree:Reset()
	oTree:AddItem( oAOLGrid:GetValue("AOL_RESUMO") + Space(200) , CRMA580Root(), "FOLDER12" , "FOLDER13",,,1 )
	
	//-------------------------------------------------------------------
	// Define o tamanho da régua de processamento.    
	//-------------------------------------------------------------------
	ProcRegua( oAOMGrid:Length() )

	//-------------------------------------------------------------------
	// Percorre todos os níveis do agrupador.    
	//-------------------------------------------------------------------
	For nLevel := 1 To oAOMGrid:Length()
		oAOMGrid:GoLine( nLevel )

		//-------------------------------------------------------------------
		// Incrementa a régua de processamento.    
		//-------------------------------------------------------------------
		IncProc( oAOMGrid:GetValue("AOM_DESCRI") )

		//-------------------------------------------------------------------
		// Localiza o nó pai.    
		//-------------------------------------------------------------------			
		If ! ( cFather == oAOMGrid:GetValue("AOM_NIVPAI") )	
			cFather := oAOMGrid:GetValue("AOM_NIVPAI")
			oTree:TreeSeek( cFather )
		EndIf 
		
		//-------------------------------------------------------------------
		// Executa ponto de entrada para limitar itens.    
		//-------------------------------------------------------------------        
        If lCRM910ldT
        	
        	nPos := aScan( aBanned,{ |x| x == cFather  } ) 
        	
        	If nPos == 0 
	        	
	        	lFallSafe := ExecBlock("CRMA910ldT", .F., .F., { oAOMGrid, nLevel } )
	       
	        	If (Valtype (lFallSafe) == "L")	
	        		lAddItem := lFallSafe
	        	EndIf
	       
	        	If !lAddItem  
	         		Aadd (aBanned, oAOMGrid:GetValue("AOM_CODNIV") )	
	        		Loop
	        	EndIf
	        Else
	        	Aadd (aBanned, oAOMGrid:GetValue("AOM_CODNIV") )
	        	Loop
	        EndIf
	        
        EndIf 
			
		//-------------------------------------------------------------------
		// Define a imagem de acordo com privilégio e o status do nó.    
		//-------------------------------------------------------------------
		If ! ( CRM910Access( oAOMGrid:GetValue("AOM_CODAGR"), oAOMGrid:GetValue("AOM_CODNIV") ) )	
			cImage 	:= ""
			
			//--------------------------------------------------------------
			//Pula itens bloqueados
			//--------------------------------------------------------------
			If oAOMGrid:GetValue("AOM_MSBLQL") == "1" 
				Loop
			EndIf
			
		Else
			If ( oAOMGrid:GetValue("AOM_MARK") )
				cImage 	:= "LBOK"				
			Else
				cImage 	:= "LBNO"
			EndIf
		EndIf
			
		//-------------------------------------------------------------------
		// Adiciona o nó filho.    
		//-------------------------------------------------------------------	
		oTree:AddItem( AllTrim( oAOMGrid:GetValue("AOM_CODNIV") ) + " - " + oAOMGrid:GetValue("AOM_DESCRI"), oAOMGrid:GetValue("AOM_CODNIV"), cImage, cImage,,,2 )
		
	Next nLevel	
	
	//------------------------------------------------------
	// Posiciona na primeira linha do Nivel do Agrupador.    
	//------------------------------------------------------	
	oAOMGrid:GoLine( 1 )
	
	//-------------------------
	//Retorna o alias da árvore
	//-------------------------
	cTree := oTree:cArqTree
	(cTree)->(dbSetOrder(4))//CODNIV
	(cTree)->(dbGoTop())
	
	//Verifica qual é número do Bitmap do itens que não podem ser selecionados
	For nI := 1 to Len( oTree:aBmps ) 
	
	    nBitmap := aScan( oTree:aBmps[nI] , "" ) //Bitmap "vazio"
	    If nBitmap > 0 
	        
	       Exit 
	    EndIf
	
	Next nI
	
	nBitmap := nI
		
	//--------------------------------------------------------------------
	//Varre a árvore para deletar os itens que o usuário não pode utilizar
	//--------------------------------------------------------------------
	While !(cTree)->(EoF())
	
		//Se o Bitmap for vazio e não for um node, deleta o item
		If (cTree)->T_BMP001 == nBitmap .AND. (cTree)->T_ISTREE <> 'S'
			
			oTree:TreeSeek( (cTree)->T_CARGO )
			oTree:DelItem()
							
		EndIf 
		(cTree)->( dbSkip() )

	EndDo
	
	(cTree)->(dbGoTop())
	oTree:TreeSeek( (cTree)->T_CARGO )
	oTree:PTRefresh()
	
Return

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM910AOL
Retorna os agrupador selecionado pelo usuario.

@param oMdlAOL, objeto, modelo de dados da tabela AOL.
@return	aLoad, array, String dos Agrupadores Selecionados.

@author		Cleyton F.Alves
@author		Valdiney V GOMES
@version	12
@since		10/06/2015
/*/
//-----------------------------------------------------------------------------
Static Function CRM910AOL( oMdlAOL )
	Local oStruct 	:= oMdlAOL:GetStruct()	
	Local aField    := oStruct:GetFields()
	Local aLoad   	:= {}
	Local cTemp  	:= GetNextAlias()
	Local cFilter	:= SuperGetMV( "MV_CRMAGOP", .F., "" )
	Local cMacro    := ""
	Local cQuery    := ""
	Local nField	:= 0 
	Local lMarked  	:= .T.
	Local cFilAZ0   := xFilial("AZ0")
	Local cFilAZ1   := xFilial("AZ1") 
	Local cFilAZ2   := xFilial("AZ2")

	//-------------------------------------------------------------------
	// Monta a instrução SQL para recuperar os níveis.  
	//-------------------------------------------------------------------	
	cQuery := " SELECT * FROM " 
	cQuery += 		RetSQLName("AOL") + " AOL "
	cQuery += " WHERE "
	cQuery += " 	AOL.AOL_ENTIDA = 'SB1'"
	cQuery += " 	AND "
	cQuery += " 	AOL.AOL_MSBLQL <> '1'"
	cQuery += " 	AND "
	cQuery += " 	AOL.AOL_FILIAL = '" + xFilial( "AOL" ) + "'"
	cQuery += " 	AND "
	cQuery += " 	AOL.D_E_L_E_T_ = ' '"
	
	If ! ( Empty( cFilter ) )
		cQuery += " AND "
		cQuery += " AOL.AOL_CODAGR = '" + AllTrim( cFilter ) + "'"
	EndIf

	//-------------------------------------------------------------------
	// Executa a instrução SQL.  
	//-------------------------------------------------------------------	
	DBUseArea( .T., "TOPCONN", TCGenQry( ,, ChangeQuery( cQuery ) ), cTemp, .F., .T. )	
	
	//-------------------------------------------------------------------
	// Percorre todos os agrupadores.  
	//-------------------------------------------------------------------	
	While ( ! ( cTemp )->( Eof() ) )
		//-------------------------------------------------------------------
		// Verifica as regras de comercialização.  
		//-------------------------------------------------------------------			
		If ( AZ0->( DBSeek( cFilAZ0 + (cTemp)->AOL_CODAGR ) ) .Or.;
		 	 AZ1->( DBSeek( cFilAZ1 + (cTemp)->AOL_CODAGR ) ) .Or.;
		 	 AZ2->( DBSeek( cFilAZ2 + (cTemp)->AOL_CODAGR ) ) )
		 	 
			//-------------------------------------------------------------------
			// Carrega o R_E_C_N_O_.  
			//-------------------------------------------------------------------			
			aAdd( aLoad, { (cTemp)->R_E_C_N_O_, {} } )	
			
			//-------------------------------------------------------------------
			// Carrega os demais campo do modelo.  
			//-------------------------------------------------------------------					
			For nField := 1 To Len( aField )	
				If ! ( aField[nField][MODEL_FIELD_VIRTUAL] )
					cMacro := "(cTemp)->" + AllTrim( aField[nField][MODEL_FIELD_IDFIELD] )
				Else 
					If ( aField[nField][MODEL_FIELD_IDFIELD] == "AOL_DSCENT" )
						cMacro 	:= "AllTrim( Posicione('SX2', 1,'" + (cTemp)->AOL_ENTIDA + "','X2NOME()') )"
					ElseIf ( aField[nField][MODEL_FIELD_IDFIELD] == "AOL_MARK" )
						cMacro := ".F."
					Else
						cMacro 	:= AllTrim( aField[nField][MODEL_FIELD_INIT] )
					EndIf
				EndIf
					
				aAdd( aLoad[Len(aLoad)][2] , &cMacro )
			Next nField
		EndIf	
			
		(cTemp)->( DBSkip() )
	EndDo	
	
	(cTemp)->( DBCloseArea() )
Return aLoad

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM910AOM

Retorna os agrupador selecionado pelo usuario.

@sample	CRM910AOL(oMdlAOL,aCodAgrup)

@param		Nenhum
@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM910AOM(oMdlAOM,cCodAgr)

Local aLoadAOM   := {}
Local oStructAOM := oMdlAOM:GetStruct()
Local aCampos    := oStructAOM:GetFields()
Local cMacro     := ""
local nY := 0 


If AOM->(dbSeek(xFilial("AOM")+cCodAgr))
	WHile AOM->(!Eof()) .And. AOM->AOM_FILIAL == xFilial("AOM") .And. AllTrim(AOM->AOM_CODAGR) == AllTrim(cCodAgr)
		aAdd(aLoadAOM,{AOM->(Recno()) ,{} })	
		For nY := 1 To Len(aCampos)	
			If !aCampos[nY][MODEL_FIELD_VIRTUAL]
				cMacro := "AOM->"+ALlTrim(aCampos[nY][MODEL_FIELD_IDFIELD])
			Else
				If aCampos[nY][MODEL_FIELD_IDFIELD] == "AOM_MARK"
					cMacro := ".F."
				Else
					cMacro := AllTrim(aCampos[nY][MODEL_FIELD_INIT])
				EndIf
			EndIf

			aAdd(aLoadAOM[Len(aLoadAOM),2] , &cMacro )
		Next nY
		AOM->(dbSkip())
	EndDo	
EndIf

Return(aLoadAOM)

//-----------------------------------------------------------------------------
/*/{Protheus.doc} CRM910Agrv

Retorna os agrupador selecionado pelo usuario.

@sample	CRM910AOL(oMdlAOL,aCodAgrup)

@param		Nenhum
@return	ExpC - String dos Agrupadores Selecionados.

@author	SI2901 - Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//-----------------------------------------------------------------------------
Static Function CRM910AGRV(oModel)

Local aReturn  := {}
Local oMdlAOL  := oModel:GetModel("AOLDETAIL")
Local oMdlAOM  := oModel:GetModel("AOMDETAIL")
Local nz       := 0
Local nx       := 0
Local cCodAgr  := ""
Local cCodNiv  := ""
Local cDescNiv := ""

For nz := 1 To oMdlAOL:Length()
	oMdlAOL:GoLine(nz)
	For nx := 1 To oMdlAOM:Length()
		oMdlAOM:GoLine(nx)
		If oMdlAOM:GetValue("AOM_MARK")
			aAdd(aReturn,{oMdlAOM:GetValue("AOM_CODAGR"),oMdlAOL:GetValue("AOL_RESUMO"),oMdlAOM:GetValue("AOM_CODNIV"),oMdlAOM:GetValue("AOM_DESCRI"),oMdlAOL:GetValue("AOL_MARK"), oMdlAOM:GetValue( "AOM_IDINT" ) } )
		EndIf
	Next nx

Next nz

aRetGrid := aClone(aReturn)

Return(aReturn)

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMVMarkAOL

Controla o campo AOL_MARK do GRID AOL para permitir apenas uma linha marcada.

@sample	CRMVMarkAOL(oMdlAOL)

@param		oMdlAOL	- Objeto do modelo de dados atual.
@return	.T.			- Sempre retorna verdadeiro para efetivar a validacao.

@author	Cleyton F.Alves
@since		10/06/2015
@version	12
/*/
//------------------------------------------------------------------------------
Static Function CRMVMarkAOL(oMdlAOL)

Local oView		:= FwViewActive()
Local nLinAtu	:= oMdlAOL:GetLine()  
Local lMark	 	:= oMdlAOL:GetValue("AOL_MARK")
Local nX		:= 0

For nX := 1 To oMdlAOL:Length()
	oMdlAOL:GoLine(nX)
	oMdlAOL:LoadValue("AOL_MARK",.F.)
Next nX

oMdlAOL:GoLine(nLinAtu)
oMdlAOL:LoadValue("AOL_MARK",.T.)

oView:Refresh()

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM910Access
Valida se o usuário tem acesso ao item da tree para seleção.

@param	cPool, caracter, Código do agrupador.
@param	cLevel, caracter, Nível do agrupador.
@return	lAccess, lógico,Lógico que informa se é possível manipular o item da tree

@author	 Thamara Villa
@author	 Valdiney V GOMES
@version 12
@since	 05/10/2015
/*/
//------------------------------------------------------------------------------
Function CRM910Access( cPool, cLevel  )

	Local aArea			:= GetArea()
	Local aGetPaper		:= CRMXGetPaper()
	Local cCRMUser		:= ""
	Local cSequen		:= ""
	Local cPaper		:= ""
	Local cTemp			:= ""
	Local cPermission	:= ""
	Local cQuery		:= ""
	Local lAccess		:= .F.

	Default cPool		:= ""
	Default cLevel		:= ""

	If ! SuperGetMv("MV_CRMUAZS",, .F.)
		Return CRMVAccess( cPool, cLevel )
	EndIf
	
	If Len(aGetPaper) > 0 
		cCRMUser	:= aGetPaper[1]
		cSequen		:= aGetPaper[2]
		cPaper		:= aGetPaper[3]
	EndIf
	//-------------------------------------------------------------------
	// Monta a instrução SQL para recuperar as regras.  
	//-------------------------------------------------------------------
	AZ0->( DBSetOrder( 1 )  )
	
	If ( AZ0->( MSSeek( xFilial("AZ0") + cPool + cLevel ) ) )
		cQuery := " SELECT" 
		cQuery += " 	AZ0.AZ0_ENTIDA, AZ0.AZ0_CONDIC, AZ0.AZ0_DE"
		cQuery += " FROM " 
		cQuery += 		RetSQLName("AZ0") + " AZ0 "
		cQuery += " WHERE"
		cQuery += " 	("
		cQuery += "			( AZ0.AZ0_ENTIDA = 'SA1' AND AZ0.AZ0_DE = '" + aVldVar[1] + "' )"
		cQuery += " 		OR"
		cQuery += " 		( AZ0.AZ0_ENTIDA = 'SUS' AND AZ0.AZ0_DE = '" + aVldVar[2] + "' )"
		cQuery += " 		OR"
		cQuery += " 		( AZ0.AZ0_ENTIDA = 'AO3' AND AZ0.AZ0_DE = '" + cCRMUser + "' )"
		cQuery += "		)"		
		cQuery += " 	AND"		
		cQuery += " 	AZ0.AZ0_CODAGR = '" + cPool + "'"
		cQuery += " 	AND"
		cQuery += " 	AZ0.AZ0_CODNIV = '" + cLevel + "'"
		cQuery += " 	AND"		
		cQuery += " 	AZ0.AZ0_FILIAL = '" + xFilial( "AZ0" ) + "'"
		cQuery += " 	AND"
		cQuery += " 	AZ0.D_E_L_E_T_ = ' '"		

		//-------------------------------------------------------------------
		// Define o alias.  
		//-------------------------------------------------------------------	
		cTemp := GetNextAlias()

		//-------------------------------------------------------------------
		// Executa a instrução SQL.  
		//-------------------------------------------------------------------	
		DBUseArea( .T., "TOPCONN", TCGenQry( ,, ChangeQuery( cQuery ) ), cTemp, .F., .T. )	
		
		//-------------------------------------------------------------------
		// Recupera o acesso atribuído por meio da regra.  
		//-------------------------------------------------------------------
		While ( ! (cTemp)->( Eof() ) )
			cPermission := (cTemp)->AZ0_CONDIC
	
			If ( cPermission == ALLOWED .Or. cPermission == DENIED  )
				Exit
			EndIf 
	
			(cTemp)->( DBSkip() )	
		Enddo	
			
		//-------------------------------------------------------------------
		// Fecha a área de trabalho temporária.
		//-------------------------------------------------------------------	
		(cTemp)->( DBCloseArea() )
	EndIf

	//-------------------------------------------------------------------
	// Verifica se é necessário verificar o acesso por usuário.  
	//-------------------------------------------------------------------	
	If ( Empty( cPermission ) )
		AZ2->( DBSetOrder( 1 ) )
	
		If ( AZ2->( MSSeek( xFilial("AZ2") + cPool + cLevel ) ) )
			//-------------------------------------------------------------------
			// Monta a instrução SQL para recuperar os usuários.  
			//-------------------------------------------------------------------
			cQuery := " SELECT" 
			cQuery += " 	AZ2.AZ2_CODENT"
			cQuery += " FROM " 
			cQuery += 		RetSQLName("AZ2") + " AZ2 "
			cQuery += " WHERE"	
			cQuery += " 	AZ2.AZ2_ENTIDA = 'AO3'" 
			cQuery += " 	AND"
			cQuery += " 	AZ2.AZ2_CODENT = '" + cCRMUser + "'"
			cQuery += " 	AND"		
			cQuery += " 	AZ2.AZ2_CODAGR = '" + cPool + "'"
			cQuery += " 	AND"
			cQuery += " 	AZ2.AZ2_CODNIV = '" + cLevel + "'"
			cQuery += " 	AND"		
			cQuery += " 	AZ2.AZ2_FILIAL = '" + xFilial( "AZ2" ) + "'"
			cQuery += " 	AND"
			cQuery += " 	AZ2.D_E_L_E_T_ = ' '"		

			//-------------------------------------------------------------------
			// Define o alias.  
			//-------------------------------------------------------------------	
			cTemp := GetNextAlias()
			
			//-------------------------------------------------------------------
			// Executa a instrução SQL.  
			//-------------------------------------------------------------------	
			DBUseArea( .T., "TOPCONN", TCGenQry( ,, ChangeQuery( cQuery ) ), cTemp, .F., .T. )	
			
			//-------------------------------------------------------------------
			// Verifica se o usuário possui acesso.  
			//-------------------------------------------------------------------
			If ( ! (cTemp)->( Eof() ) )
				cPermission := ALLOWED
			EndIf
			
			//-------------------------------------------------------------------
			// Fecha a área de trabalho temporária.
			//-------------------------------------------------------------------			
			(cTemp)->( DBCloseArea() )	
		EndIf		
	EndIf 
	
	//-------------------------------------------------------------------
	// Verifica se é necessário verificar o acesso por equipe.  
	//-------------------------------------------------------------------	
	If ( Empty( cPermission ) )
		AZ2->( DBSetOrder( 1 ) )
	
		If ( AZ2->( MSSeek( xFilial("AZ2") + cPool + cLevel ) ) )
			//-------------------------------------------------------------------
			// Monta a instrução SQL para recuperar as equipes.  
			//-------------------------------------------------------------------
			cQuery := " SELECT "
			cQuery += " 	AZS.AZS_CODUSR" 
			cQuery += " FROM " 
			cQuery += 		RetSQLName("AZS") + " AZS "
			cQuery += " WHERE"
			cQuery += " 	AZS.AZS_CODUSR = '" + cCRMUser + "'"		
			cQuery += " 	AND"	
			cQuery += " 	AZS.AZS_SEQUEN = '" + cSequen + "'"		
			cQuery += " 	AND"	
			cQuery += " 	AZS.AZS_PAPEL = '" + cPaper + "'"		
			cQuery += " 	AND"		
			cQuery += " 	AZS.AZS_CODEQP IN ("
			cQuery += " 		SELECT" 
			cQuery += " 			AZ2.AZ2_CODENT"
			cQuery += " 		FROM" 
			cQuery += 				RetSQLName("AZ2") + " AZ2 "
			cQuery += " 		WHERE"	
			cQuery += " 			AZ2.AZ2_ENTIDA = 'ACA'" 
			cQuery += " 			AND"		
			cQuery += " 			AZ2.AZ2_CODAGR = '" + cPool + "'"
			cQuery += " 			AND"
			cQuery += " 			AZ2.AZ2_CODNIV = '" + cLevel + "'"
			cQuery += " 			AND"		
			cQuery += " 			AZ2.AZ2_FILIAL = '" + xFilial( "AZ2" ) + "'"
			cQuery += " 			AND"
			cQuery += " 			AZ2.D_E_L_E_T_ = ' '"	
			cQuery += "		)"
			cQuery += "		AND"		
			cQuery += " 	AZS.AZS_FILIAL = '" + xFilial( "AZS" ) + "'"
			cQuery += " 	AND"
			cQuery += " 	AZS.D_E_L_E_T_ = ' '"		

			//-------------------------------------------------------------------
			// Define o alias.  
			//-------------------------------------------------------------------	
			cTemp := GetNextAlias()
			
			//-------------------------------------------------------------------
			// Executa a instrução SQL.  
			//-------------------------------------------------------------------	
			DBUseArea( .T., "TOPCONN", TCGenQry( ,, ChangeQuery( cQuery ) ), cTemp, .F., .T. )	
			
			//-------------------------------------------------------------------
			// Verifica se a equipe do usuário possui acesso.  
			//-------------------------------------------------------------------
			If ( ! (cTemp)->( Eof() ) )
				cPermission := ALLOWED
			EndIf
				
			//-------------------------------------------------------------------
			// Fecha a área de trabalho temporária.
			//-------------------------------------------------------------------			
			(cTemp)->( DBCloseArea() )		
		EndIf
	EndIf	
	
	//-------------------------------------------------------------------
	// Verifica se é necessário verificar o acesso por unidade de negócio.  
	//-------------------------------------------------------------------	
	If ( Empty( cPermission ) )
		AZA->( DBSetOrder( 1 ) )
	
		If ( AZA->( MSSeek( xFilial("AZA") + cPool + cLevel ) ) )
			//-------------------------------------------------------------------
			// Monta a instrução SQL para recuperar as unidades de negócio.
			//-------------------------------------------------------------------
			cQuery := " SELECT "
			cQuery += " 	AZS.AZS_CODUSR" 
			cQuery += " FROM " 
			cQuery += 		RetSQLName("AZS") + " AZS "
			cQuery += " WHERE"
			cQuery += " 	AZS.AZS_CODUSR = '" + cCRMUser + "'"		
			cQuery += " 	AND"		
			cQuery += " 	AZS.AZS_SEQUEN = '" + cSequen + "'"		
			cQuery += " 	AND"
			cQuery += " 	AZS.AZS_PAPEL = '" + cPaper + "'"		
			cQuery += " 	AND"
			cQuery += " 	AZS_CODUND IN ("
			cQuery += " 		SELECT"
			cQuery += " 			AZA.AZA_COD" 
			cQuery += " 		FROM"
			cQuery += 				RetSQLName("AZA") + " AZA "
			cQuery += "			 WHERE"	
			cQuery += " 			AZA.AZA_CODAGR = '" + cPool + "'"
			cQuery += " 			AND"
			cQuery += " 			AZA.AZA_CODNIV = '" + cLevel + "'"
			cQuery += " 			AND"		
			cQuery += " 			AZA.AZA_FILIAL = '" + xFilial( "AZA" ) + "'"
			cQuery += " 			AND"
			cQuery += " 			AZA.D_E_L_E_T_ = ' '"
			cQuery += "		)"
			cQuery += "		AND"		
			cQuery += " 	AZS.AZS_FILIAL = '" + xFilial( "AZS" ) + "'"
			cQuery += " 	AND"
			cQuery += " 	AZS.D_E_L_E_T_ = ' '"			
			
			//-------------------------------------------------------------------
			// Define o alias.  
			//-------------------------------------------------------------------	
			cTemp := GetNextAlias()			
			
			//-------------------------------------------------------------------
			// Executa a instrução SQL.  
			//-------------------------------------------------------------------	
			DBUseArea( .T., "TOPCONN", TCGenQry( ,, ChangeQuery( cQuery ) ), cTemp, .F., .T. )	
			
			//-------------------------------------------------------------------
			// Verifica se a unidade de negócio do usuário possui acesso.    
			//-------------------------------------------------------------------
			If ( ! (cTemp)->( Eof() ) )
				cPermission := ALLOWED
			EndIf	
			
			//-------------------------------------------------------------------
			// Fecha a área de trabalho temporária.
			//-------------------------------------------------------------------		
			(cTemp)->( DBCloseArea() )	
		EndIf	
	EndIf	
	
	//-------------------------------------------------------------------
	// Verifica se o usuário possui acesso.  
	//-------------------------------------------------------------------	
	lAccess := ( cPermission == ALLOWED )
	RestArea(aArea) 
Return lAccess

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMVAccess

Valida se o usuário tem acesso ao item da tree para seleção.

@sample	CRMVAccess(oMdlAOL)

@param		oMdlAOMGrid	- Objeto do modelo de dados da grid AOM.
@return	lAccess	- Lógico que informa se é possível manipular o item da tree

@author	Thamara Villa
@since		05/10/2015
@version	12.1.7
/*/
//------------------------------------------------------------------------------
Static Function CRMVAccess( cCodAgr, cCodNiv )

Local cCodTab	:= GetNextAlias()
Local cCodUsu	:= If(SuperGetMv("MV_CRMUAZS",, .F.), CRMXCodUser(), RetCodUsr()) 
Local cQuery	:= ""
Local lAccess	:= .F.
Local nFindReg	:= 0 //Verifica se atendeu alguma regra de liberação de regra
Local nFindAcc	:= 0 //Verifica se atendeu alguma regra de liberação de acesso

If	AZ0->(dbSeek(xFilial("AZ0")+cCodAgr+cCodNiv)) .Or.;
		AZ1->(dbSeek(xFilial("AZ1")+cCodAgr+cCodNiv)) .Or.;
		AZ2->(dbSeek(xFilial("AZ2")+cCodAgr+cCodNiv)) .Or.;
		AZA->(dbSeek(xFilial("AZA")+cCodAgr+cCodNiv))
	lAccess := .T.
Else
	lAccess := .F.
EndIf

If lAccess
	//-----------------------------------------------------------------------------
	// Faz a análise do folder de Regras
	//-----------------------------------------------------------------------------
	If AZ0->(dbSeek(xFilial("AZ0")+cCodAgr+cCodNiv))
		While AZ0->(!EOF()) .AND.  AZ0->AZ0_CODAGR == cCodAgr .AND. AZ0->AZ0_CODNIV  == cCodNiv
			
			If AZ0->AZ0_ENTIDA == "SA1"
				
				If AZ0->AZ0_CONDIC == "1"
					If AllTrim(aVldVar[1]) >= AllTrim(AZ0->AZ0_DE) .And. AllTrim(aVldVar[1]) <= AllTrim(AZ0->AZ0_ATE)
						nFindReg++
					EndIf
				Else
					If AllTrim(aVldVar[1]) < AllTrim(AZ0->AZ0_DE) .Or. AllTrim(aVldVar[1]) > AllTrim(AZ0->AZ0_ATE)
						nFindReg++
					EndIf
				EndIf
				
			ElseIf AZ0->AZ0_ENTIDA == "SUS"
				
				If AZ0->AZ0_CONDIC == "1"
					If AllTrim(aVldVar[2]) >= AllTrim(AZ0->AZ0_DE) .And. AllTrim(aVldVar[2]) <= AllTrim(AZ0->AZ0_ATE)
						nFindReg++
					EndIf
				Else
					If AllTrim(aVldVar[2]) < AllTrim(AZ0->AZ0_DE) .Or. AllTrim(aVldVar[2]) > AllTrim(AZ0->AZ0_ATE)
						nFindReg++
					EndIf
				EndIf
				
			ElseIf AZ0->AZ0_ENTIDA == "AO3"
				
				If AZ0->AZ0_CONDIC == "1"
					If AllTrim(cCodUsu) >= AllTrim(AZ0->AZ0_DE) .And. AllTrim(cCodUsu) <= AllTrim(AZ0->AZ0_ATE)
						nFindReg++
					EndIf
				Else
					If AllTrim(cCodUsu) < AllTrim(AZ0->AZ0_DE) .Or. AllTrim(cCodUsu) > AllTrim(AZ0->AZ0_ATE)
						nFindReg++
					EndIf
				EndIf
				
			EndIf
			
			AZ0->(dbSkip())
		EndDo
	EndIf
	
	lAccess := .F.
	//-----------------------------------------------------------------------------
	// Analisa os acessos para o nível do agrupador do folder de usuário e equipe
	//-----------------------------------------------------------------------------
	If AZ2->(dbSeek(xFilial("AZ2")+cCodAgr+cCodNiv))
		While AZ2->(!EOF()) .AND.  AZ2->AZ2_CODAGR == cCodAgr .AND. AZ2->AZ2_CODNIV  == cCodNiv
			
			If AZ2->AZ2_ENTIDA == 'AO3'
				If AZ2->AZ2_CODENT == cCodUsu
					nFindAcc++
				EndIf
				
			ElseIf AZ2->AZ2_ENTIDA == 'ACA'
				
				BeginSQL Alias cCodTab
					
					SELECT 	TAB001.AO5_CODANE AS CODUSR
					FROM 	%Table:AO5% TAB001
					WHERE	TAB001.AO5_FILIAL = %xFilial:AO5% 	AND
					TAB001.%NotDel%	 					AND
					TAB001.AO5_ENTANE = 'USU'			AND
					TAB001.AO5_CODANE = %exp:cCodUsu% 	AND
					SUBSTRING(TAB001.AO5_IDESTN,1,4) = (SELECT	SUBSTRING(TAB002.AO5_IDESTN,1,4)
					FROM	%Table:AO5% TAB002
					WHERE	TAB002.AO5_FILIAL = %xFilial:AO5% 	AND
					TAB002.%NotDel%						AND
					TAB002.AO5_ENTANE = 'ACA' 			AND
					TAB002.AO5_CODANE = %exp:AZ2->AZ2_CODENT%)
				EndSql
				cQuery := GetLastQuery()[2]
				
				(cCodTab)->(dbGoTop())
				If !(cCodTab)->(Bof())
					nFindAcc++
				EndIf
				(cCodTab)->(dbCloseArea())
				
			EndIf
			
			AZ2->(dbSkip())
		EndDo
		
		//-----------------------------------------------------------------------------
		// Analisa os acessos para o nível do agrupador do folder de Unidade
		//-----------------------------------------------------------------------------
	ElseIf AZA->(dbSeek(xFilial("AZA")+cCodAgr+cCodNiv))
		While AZA->(!EOF()) .AND.  AZA->AZA_CODAGR == cCodAgr .AND. AZA->AZA_CODNIV  == cCodNiv
			
			DbSelectArea( "AO3" )
			AO3->( DbSetOrder( 1 ) )
			If AO3->( DbSeek( xFilial( "AO3" ) + cCodUsu ) )
				If AZA->AZA_COD == AO3->AO3_CODUND
					nFindAcc++
				EndIf
			EndIf
			AZA->(dbSkip())
		EndDo
		//-----------------------------------------------------------------------------
		// Se não encontrou registro é porque o acesso é full para todos
		//-----------------------------------------------------------------------------
	Else
		lAccess := .T.
	EndIf
	
	//---------------------------------------------------------------------------------
	// Verifica se atende a alguma regra e se não possui nenhum bloqueio de acesso OU
	// Verifica se atende a alguma regra e se possui liberação de acesso específico OU
	// Caso não haja regra, mas haja restrição de acesso, verifica se possui acesso.
	//---------------------------------------------------------------------------------
	If ( nFindReg > 0 .And. lAccess )  .Or. (  nFindReg > 0 .And. nFindAcc > 0 )  .Or. ( nFindReg == 0 .And. nFindAcc > 0 ) .Or. lAccess
		lAccess := .T.
	Else
		lAccess := .F.
	EndIf
	
EndIf

Return( lAccess )
