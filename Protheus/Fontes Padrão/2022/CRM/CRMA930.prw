#INCLUDE "CRMA930.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE "FWMVCDEF.CH" 


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA930

Cadastro de Rodízio

@sample	MATA030A()

@param		oModel		, objeto  ,	Modelo de dados ativo do Cadastro de Território
@param		nOperDelet	, numerico,	Número da Operação de exclusão

@return	Nenhum

@author	Victor Bitencourt
@since		12/06/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------
Function CRMA930(oModel, nOperDelet)

Local nOperation := 0
Local nOperMod   := 0
Local cOperation := ""

Local aAreaAZ3   := {}

Local lExist     := .F.
Local lProc      := .F.

Default oModel := Nil 
Default nOperDelet	:= 0

If oModel <> Nil 

   nOperation := IIF( nOperDelet <> MODEL_OPERATION_DELETE, oModel:GetOperation(), nOperDelet )
	
   aAreaAZ3 := AZ3->(GetArea())	
   AZ3->(DbSetOrder(1))
   lExist := AZ3->(DbSeek(xFilial("AZ3")+oModel:GetModel("AOYMASTER"):GetValue("AOY_CODTER")))
	
   Do Case

		Case lExist .AND. nOperation == 5			
			cOperation	:= STR0021 //"EXLCUIR"
			nOperMod 	:= MODEL_OPERATION_DELETE
			lProc		:= .T.

		Case lExist .AND. nOperation == 4
			cOperation := STR0001//"ALTERAR"
			nOperMod  :=  MODEL_OPERATION_UPDATE
			lProc     := .T.
				
		Case lExist .AND. nOperation <> 4
			cOperation := STR0002 //"VISUALIZAR"
		 	nOperMod  :=  MODEL_OPERATION_VIEW
		 	lProc     := .T.

		Case !lExist .AND. nOperation <> 4
			Alert(STR0003)//"Rodizio não configurado !"

		Case !lExist .AND. nOperation == 4
			cOperation := STR0004 //"INCLUIR"
			nOperMod  := MODEL_OPERATION_INSERT
			lProc     := .T.
			
		OtherWise
			Alert(STR0005)//"Operação inválida !"

	EndCase

	If lProc
		FWExecView( cOperation, "VIEWDEF.CRMA930", nOperMod, /*oDlg*/, {|| CRM930RodSeg(oModel,nOperation) } ,, /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )
	EndIf	 

	RestArea(aAreaAZ3)
EndIf 

Return

//----------------------------------------------------------
/*/{Protheus.doc} ModelDef()

Model - Modelo de dados do Cadastro de Rodízio. 

@param	  Nenhum

@return  oModel - objeto contendo o modelo de dados

@author   Victor Bitencourt
@since	   12/06/2015
@version  12.1.6
/*/
//----------------------------------------------------------
Static Function ModelDef()

Local oModel := Nil

Local oAZ3Struct	:= FWFormStruct( 1, "AZ3" ) // Rodízio
Local oAZ6Struct	:= FWFormStruct( 1, "AZ6" ) // Filas
Local oAZ7Struct	:= FWFormStruct( 1, "AZ7" ) // Membros

Local bModelInit	:= { |oModel| InitPadrao(oModel)}
	
//------------------------------------------
// Cria campo apra exibir o log do processo
//------------------------------------------	
oAZ7Struct:AddField("","","AZ7_HIST","C",4,0,/*bValid*/,/*bWhen*/,/*aValues*/,/*lObrigat*/,{||"LUPA"},/*lKey*/,/*LNoUpd*/,.T.,/*cValid*/)
	
//---------------------------------------------------
// Define algumas regras para a estrutura do modelo 
//---------------------------------------------------
If AOY->AOY_TPROD == "1" // Rodízio Padrão
	oAZ7Struct:SetProperty("AZ7_TPMEM",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,".F."))
	oAZ7Struct:SetProperty("AZ7_CODMEM",MODEL_FIELD_WHEN,FwBuildFeature(STRUCT_FEATURE_WHEN,".F."))
Else 
	oAZ6Struct:SetProperty("AZ6_CODRGR",MODEL_FIELD_OBRIGAT,.T.)
EndIf

//----------------------------------
// Define a estrutura do modelo
//----------------------------------
oModel	:= MPFormModel():New("CRMA930",/*bPre*/,/*bPos*/,/*bCommit*/,/*bCancel*/)

//----------------------------------------
// Define a estrutura do modelo 
//----------------------------------------
oModel:AddFields("AZ3MASTER",/*cOwner*/,oAZ3Struct,/*bPreValidacao*/,/*bPosValidacao*/,/*bCarga*/)
oModel:AddGrid("AZ6DETAIL", "AZ3MASTER",oAZ6Struct, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid("AZ7DETAIL", "AZ6DETAIL",oAZ7Struct, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

//----------------------------------------------------
// Define os relacionamentos da estrutura do modelo
//----------------------------------------------------
oModel:SetRelation("AZ6DETAIL", { { "AZ6_FILIAL", "xFilial('AZ6')" }, {"AZ6_CODROD", "AZ3_CODROD"}}, AZ6->( IndexKey( 1 ) ) )
oModel:SetRelation("AZ7DETAIL", { { "AZ7_FILIAL", "xFilial('AZ7')" }, {"AZ7_CODROD", "AZ3_CODROD"}, {"AZ7_CODFLA", "AZ6_CODFLA"}}, AZ7->( IndexKey( 1 ) ) )

//-------------------------------------------------------------------
// Define a descrição do modelo de dados. 
//-------------------------------------------------------------------	
oModel:SetDescription( STR0006 )//"Cadastro de Rodízio"
oModel:GetModel("AZ6DETAIL"):SetDescription( STR0007 )  //"Filas"
oModel:GetModel("AZ7DETAIL"):SetDescription( STR0008 ) //"Fila x Membro"

//--------------------------------------------
// Define regras para a estrutura 
//--------------------------------------------
oModel:GetModel("AZ6DETAIL"):SetUniqueLine( { "AZ6_CODROD", "AZ6_CODRGR"  } )
oModel:GetModel("AZ7DETAIL"):SetUniqueLine( { "AZ7_CODROD", "AZ7_CODFLA", "AZ7_TPMEM", "AZ7_CODMEM" } )

//---------------------------------------------------------
// Define Bloco que será processado na Atvivação do Modelo
//---------------------------------------------------------
oModel:SetActivate(bModelInit)

Return oModel

//----------------------------------------------------------
/*/{Protheus.doc} ViewDef()

Interface do modelo de dados do cadastro de Rodízio 

@param	   Nenhum

@return   oView - objeto contendo a visão criada

@author   Victor Bitencourt
@since	   12/06/2015
@version  12.1.6
/*/
//----------------------------------------------------------
Static Function ViewDef()

Local oView	   := Nil
Local oModel 	   := Nil

Local cCpoAZ6    := "AZ6_CODROD|AZ6_CTCNT|AZ6_ULTMEM|"
Local cCpoAZ7    := "AZ7_CODFLA|AZ7_CODROD|"

Local bAvCpoAZ6  := {|cCampo| !(AllTrim(cCampo)+"|" $ cCpoAZ6)}
Local bAvCpoAZ7  := {|cCampo| !(AllTrim(cCampo)+"|" $ cCpoAZ7)}

Local oAZ6MdlStr := Nil
Local oAZ3Struct := FWFormStruct( 2, "AZ3")
Local oAZ6Struct := FWFormStruct( 2, "AZ6", bAvCpoAZ6)
Local oAZ7Struct := FWFormStruct( 2, "AZ7", bAvCpoAZ7)

//------------------------------------------
// Cria campo apra exibir o log do processo
//------------------------------------------
oAZ7Struct:AddField("AZ7_HIST","01","","",{},"C","@BMP",{||}/*bPictVar*/,/*cLookup*/,/*lCanChange*/,/*cFolder*/,/*cGroup*/,/*aComboValues*/,/*nMaxLenCombo*/,/*cIniBrow*/,/*lVirtual*/,/*cPictVar*/,/*lInsertLine*/)

//-------------------------------------------------------------------
// Instancia os Objetos da View e do Model que serão utilizados
//-------------------------------------------------------------------	
oView 	:= FWFormView():New()
oModel	:= FWLoadModel("CRMA930")

//-----------------------------------------
// Define o Model que será usada na View.
//-----------------------------------------
oView:SetModel( oModel )

//-------------------------------------------------------------------
// Define as estruturas de visualização. 
//-------------------------------------------------------------------
oView:AddField("VIEW_AZ3",oAZ3Struct,"AZ3MASTER")
oView:AddGrid("VIEW_AZ6",oAZ6Struct,"AZ6DETAIL")
oView:AddGrid("VIEW_AZ7",oAZ7Struct,"AZ7DETAIL")

//-------------------------------------------------------------------
// Define os Box's da View  
//-------------------------------------------------------------------
oView:CreateHorizontalBox("SUPERIOR",20)
oView:CreateHorizontalBox("MEIO",40)
oView:CreateHorizontalBox("INFERIOR",40)

//-------------------------------------------------------------------
// Define a relação entre Box e estrutura de visualização   
//-------------------------------------------------------------------
oView:SetOwnerView("VIEW_AZ3","SUPERIOR")
oView:SetOwnerView("VIEW_AZ6","MEIO")
oView:SetOwnerView("VIEW_AZ7","INFERIOR")

//------------------------------------
// Habilita título das visualizações   
//------------------------------------
oView:EnableTitleView("VIEW_AZ3",STR0015) //"Rodízio"
oView:EnableTitleView("VIEW_AZ6",STR0016) //"Filas do Rodízio"
oView:EnableTitleView("VIEW_AZ7",STR0017) //"Membros da Fila"

//--------------------------------
// Evento de duplo click no Grid
//--------------------------------
oView:SetViewProperty("VIEW_AZ7","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| CRM930DbClk(oFormulario,cFieldName,nLineGrid,nLineModel,oView)}})

//-----------------------------------------
// Define algumas regras para a estrutura 
//-----------------------------------------
If AOY->AOY_TPROD == "1" 
	//-----------------------------------------------------------
	// Tipo de Rodizio == "1" (Padrão) não é permitido cadastrar  
	// Filas e Membros, porque a rotina criará sozinha essa 
	// configuração.
	//-----------------------------------------------------------
	oModel:GetModel("AZ6DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("AZ6DETAIL"):SetNoUpdateLine(.T.)

	oModel:GetModel("AZ7DETAIL"):SetNoInsertLine(.T.)
	oModel:GetModel("AZ7DETAIL"):SetNoDeleteLine(.T.)
	
ElseIf AOY->AOY_TPROD == "2" 

	oAZ6MdlStr := oModel:GetModel("AZ6DETAIL"):GetStruct()
	oAZ6MdlStr:SetProperty( "AZ6_CODRGR" , MODEL_FIELD_OBRIGAT, .T.)
 	
EndIf

//-------------------------------------------------------------------
// Define campos que terao Auto Incremento
//-------------------------------------------------------------------
oView:AddIncrementField("VIEW_AZ6","AZ6_CODFLA")

Return oView


//----------------------------------------------------------
/*/{Protheus.doc} MenuDef()

Rotina para criar as opções de menu disponiveis 

@param	Nenhum

@return array contendo as opcoes disponiveis

@author  Victor Bitencourt	 
@since	  12/06/2015
@version 12.1.6
/*/
//----------------------------------------------------------
Static Function MenuDef()

Local aRotina := FwMvcMenu("CRMA930")

Return aRotina


//----------------------------------------------------------
/*/{Protheus.doc} InitPadrao()

Rotina para Inicializar o valor da chave da tabela 

@param	  oModel - Modelo de dados

@return  Nenhum

@author  Victor Bitencourt	 
@since	  12/06/2015
@version 12.1.6
/*/
//----------------------------------------------------------
Static Function InitPadrao(oModel)

Default oModel := Nil

If oModel <> Nil .AND. oModel:GetOperation() == MODEL_OPERATION_INSERT
	oModel:GetModel("AZ3MASTER"):SetValue("AZ3_CODROD",AOY->AOY_CODTER)
	oModel:GetModel("AZ3MASTER"):SetValue("AZ3_DTCAD",MSDATE())
EndIf	

Return 


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM940Init()

Inicializado padrão para os campos AZ6_DSCRGR, AZ7_DSCMEM, AZ4_DSCMEM e AZ4_DSCCNT 

@param  cField  -	Nome do campo. 

@return cReturn - Descrição do campo. 

@author  Victor Bitencourt	 
@since	  12/06/2015
@version 12.1.6
/*/
//------------------------------------------------------------------------------
Function CRM930Init(cField)

Local cReturn 	:= ""
Local oModel  	:= FwModelActive()

Default cField	:= ""
	
If ValType(oModel) == "O" .AND. oModel:GetOperation() <> MODEL_OPERATION_INSERT
	
	Do Case
	
		Case cField == "AZ6_DSCRGR" 	
		
			//-------------------------------------------------------------------
			// Recupera a descrição da regra. 
			//-------------------------------------------------------------------
			cReturn := Posicione( "AZ8", 1, xFilial("AZ8") + AZ6->AZ6_CODRGR, "AZ8_DESCRI" )
				
		Case cField == "AZ7_DSCMEM" 
		
			//-------------------------------------------------------------------
			// Recupera a descrição do Membro dá tabela de membros x fila.
			//-------------------------------------------------------------------
			cReturn := CRMA640Gat(AZ7->AZ7_TPMEM, AZ7->AZ7_CODMEM)
		
	EndCase
EndIf	

Return cReturn    


//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM930GENR()

Rotina para gerenciar alterações no rodízio automatico 
quando o tipo de rodízio no território for padrão

@param  cField  -	Nome do campo. 

@return cReturn - Descrição do campo. 

@author  Victor Bitencourt	 
@since	  12/06/2015
@version 12.1.6
/*/
//------------------------------------------------------------------------------
Function CRM930GENR(oModel)

Local aArea     := GetArea() 
Local aAreaAZ3  := {}

Local cLog      := ""
Local lRet 	  := .T.
Local nX        := 0
Local nLinha    := 0

Local oModelROD := Nil
Local oModelAZ3 := Nil
Local oModelAZ6 := Nil
Local oModelAZ7 := Nil
Local oMdlGrid  := Nil

Default oModel  := Nil

If oModel <> Nil .AND. oModel:GetOperation() <> MODEL_OPERATION_DELETE

   aAreaAZ3 := AZ3->(GetArea())	
   AZ3->(DbSetOrder(1))
   
   Do Case
		//-------------------------------------------------------------------
		// Verifica senão existe Rodízio configurado para esse território 
		//-------------------------------------------------------------------   
    	Case !(AZ3->(DbSeek(xFilial("AZ3")+oModel:GetModel("AOYMASTER"):GetValue("AOY_CODTER")))) .AND. ;
   				oModel:GetModel("AOYMASTER"):GetValue("AOY_TPROD") == "1"
				//-------------------------------------------------------------------
				// Efetua a gravação do Rodízio padrão 
				//-------------------------------------------------------------------
				oModelROD := FwLoadModel("CRMA930")
				oModelAZ3 := oModelROD:GetModel("AZ3MASTER")
				oModelAZ6 := oModelROD:GetModel("AZ6DETAIL")
				oModelAZ7 := oModelROD:GetModel("AZ7DETAIL")
				
				oModelROD:SetOperation( MODEL_OPERATION_INSERT )	
				oModelROD:Activate()
				
				oModelAZ3:SetValue("AZ3_CODROD",oModel:GetModel("AOYMASTER"):GetValue("AOY_CODTER"))
				
				oModelAZ6:GoLine(oModelAZ6:AddLine())
				oModelAZ6:SetValue("AZ6_CODFLA","000001")
				oModelAZ6:SetValue("AZ6_CODROD",oModel:GetModel("AOYMASTER"):GetValue("AOY_CODTER"))
				oModelAZ6:SetValue("AZ6_DESCRI",STR0013)//"LISTA PADRÃO"
				
				nLinha	:= oModel:GetModel("A09DETAIL"):GetLine()
				For nX := 1 to oModel:GetModel("A09DETAIL"):Length()
		
					oModel:GetModel("A09DETAIL"):GoLine(nX)
					
					If 	!oModel:GetModel("A09DETAIL"):IsDeleted()			
						oModelAZ7:GoLine(oModelAZ7:AddLine())	
						oModelAZ7:LoadValue("AZ7_TPMEM", oModel:GetModel("A09DETAIL"):GetValue("A09_TPMBRO"))
						oModelAZ7:LoadValue("AZ7_CODMEM",oModel:GetModel("A09DETAIL"):GetValue("A09_CODMBR"))
						oModelAZ7:SetValue("AZ7_PESOM", 9999)
					EndIf
				
				Next nX
				oModel:GetModel("A09DETAIL"):GoLine(nLinha)
				
				If oModelROD:VldData()
		   			oModelROD:CommitData()
				Else
		    		cLog := cValToChar(oModelROD:GetErrorMessage()[4]) + ' - '
		    		cLog += cValToChar(oModelROD:GetErrorMessage()[5]) + ' - '
		    		cLog += cValToChar(oModelROD:GetErrorMessage()[6])        	      
		    		cLog += " - " + STR0020 //"Não foi possível criar o rodízio padrão!"       	      
		    		Help(,1,"CRM930ROD",,cLog, 1, 0 )
		    	EndIf	
				oModelROD:DeActivate()

		//-------------------------------------------------------------------------
		// Verifica se existe Rodízio configurado e é Padrão, Atualiza os Membros 
		//------------------------------------------------------------------------- 		    	
		Case (AZ3->(DbSeek(xFilial("AZ3")+oModel:GetModel("AOYMASTER"):GetValue("AOY_CODTER")))) .AND. ;
   				oModel:GetModel("AOYMASTER"):GetValue("AOY_TPROD") == "1" 
		
				//-------------------------------------------------------------------
				// Efetua a Atualização do Rodízio padrão 
				//-------------------------------------------------------------------
				oModelROD := FwLoadModel("CRMA930")
				oModelAZ6 := oModelROD:GetModel("AZ6DETAIL")
				oModelAZ7 := oModelROD:GetModel("AZ7DETAIL")
				
				oModelROD:SetOperation( MODEL_OPERATION_UPDATE )	
				oModelROD:Activate()
				
				//-------------------------------------------------------------------
				// Verifica se existe mais de uma Fila cadastrada no Rodizio Padrão 
				//-------------------------------------------------------------------
				If oModelAZ6:Length() > 1
						//--------------------------------------------------------------------------------
				 		// Deletando as Filas Existentes do Rodizio Customizado, e criando uma no Padrão  
				 		//--------------------------------------------------------------------------------				
						nLinha	:= oModelAZ6:GetLine()
						For nX := 1 to oModelAZ6:Length()
							oModelAZ6:GoLine(nX)
							oModelAZ6:DeleteLine()
						Next nX
						//oModelAZ6:GoLine(nLinha)
						
						//-------------------------------------------------------
				 		// Criando a Fila Padrão
				 		//-------------------------------------------------------
						oModelAZ6:GoLine(oModelAZ6:AddLine())
						oModelAZ6:SetValue("AZ6_CODFLA","000001")
						oModelAZ6:SetValue("AZ6_CODROD",oModelROD:GetModel("AZ3MASTER"):GetValue("AZ3_CODROD"))
						oModelAZ6:SetValue("AZ6_DESCRI",STR0014)//"LISTA PADRÃO"
						
				EndIf
				
				oMdlGrid := oModel:GetModel("A09DETAIL")
								
				nLinha	:= oMdlGrid:GetLine()
				For nX := 1 to oMdlGrid:Length()
		
					oMdlGrid:GoLine(nX)
					
					If oModelAZ7:SeekLine({{"AZ7_CODMEM", oMdlGrid:GetValue("A09_CODMBR") },{"AZ7_TPMEM",oMdlGrid:GetValue("A09_TPMBRO")}})
						
						If oMdlGrid:IsDeleted()
							
							oModelAZ7:DeleteLine()
						Endif
					Else
					
						oModelAZ7:GoLine(oModelAZ7:AddLine())	
						oModelAZ7:LoadValue("AZ7_TPMEM" , oMdlGrid:GetValue("A09_TPMBRO"))
						oModelAZ7:LoadValue("AZ7_CODMEM", oMdlGrid:GetValue("A09_CODMBR"))
						oModelAZ7:SetValue("AZ7_PESOM" , 9999)
					EndIf

				Next nX
				oMdlGrid:GoLine(nLinha)
				
				If oModelROD:VldData()
		   			oModelROD:CommitData()
				Else
		    		cLog := cValToChar(oModelROD:GetErrorMessage()[4]) + ' - '
		    		cLog += cValToChar(oModelROD:GetErrorMessage()[5]) + ' - '
		    		cLog += cValToChar(oModelROD:GetErrorMessage()[6])        	      
		    		Help(,,"",, cLog, 1, 0 )
		    	EndIf	
				oModelROD:DeActivate()
		
	EndCase
	RestArea(aAreaAZ3)

ElseIf oModel <> Nil .AND. oModel:GetOperation() == MODEL_OPERATION_DELETE

	//-------------------------------------------------------------------
	// Tratando a deleção do Rodizio configurado  
	//-------------------------------------------------------------------
    aAreaAZ3 := AZ3->(GetArea())	
    AZ3->(DbSetOrder(1))
	   
    If (AZ3->(DbSeek(xFilial("AZ3")+oModel:GetModel("AOYMASTER"):GetValue("AOY_CODTER")))) 
    
    	oModelROD := FwLoadModel("CRMA930")

		oModelROD:SetOperation( MODEL_OPERATION_DELETE )	
		oModelROD:Activate()

    	If oModelROD:VldData()
			oModelROD:CommitData()
		Else
			cLog := cValToChar(oModelROD:GetErrorMessage()[4]) + ' - '
			cLog += cValToChar(oModelROD:GetErrorMessage()[5]) + ' - '
			cLog += cValToChar(oModelROD:GetErrorMessage()[6])        	      
		  	Help(,,"",, cLog, 1, 0 )
		EndIf	
		oModelROD:DeActivate()
    
    EndIf
	RestArea(aAreaAZ3)
		
EndIf

RestArea(aArea)

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRM930PERC()

Rotina Responsável por calcular a porcentagem de contas de cada fila.

@param  cField  -	Nome do campo. 

@return cReturn - Descrição do campo. 

@author  Victor Bitencourt	 
@since	  23/06/2015
@version 12.1.6
/*/
//------------------------------------------------------------------------------
Function CRM930PERC(cFila,cRodizio)

Local aArea      := GetArea()

Local nAux       := 0
Local nPerncet   := 0

Local cPerncet   := ""
Local cReturn	   := ""
Local cQuery     := ""

Local cNextAlias  := GetNextAlias()

Default cFila    := ""
Default cRodizio := ""

If !Empty(cFila) .AND. !Empty(cRodizio)
	
	//-------------------------------------------------------------------
	//  Calculando o Contatdor e o numero maximo de contas
	//-------------------------------------------------------------------	
	cQuery := "SELECT  SUM(AZ7.AZ7_PESOM) MAXCONTA, SUM(AZ7.AZ7_CTCNT) CONTADOR "
	cQuery += "FROM "+ RetSQLName("AZ6") +" AZ6"
	cQuery += "	INNER JOIN "+ RetSQLName("AZ7") +" AZ7 ON (AZ7.AZ7_CODFLA = AZ6.AZ6_CODFLA AND AZ7.AZ7_CODROD = AZ6.AZ6_CODROD)"
	cQuery += "WHERE "
	cQuery += " AZ6.D_E_L_E_T_ <> '*' AND AZ7.D_E_L_E_T_ <> '*' AND AZ6.AZ6_CODFLA = '"+cFila+"' AND AZ6.AZ6_CODROD = '"+cRodizio+ "'  "	
	cQuery += "GROUP BY AZ7.AZ7_CODFLA" 
	 	
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry( ,, cQuery ),cNextAlias,.F.,.T.)
	
	If !( (cNextAlias)->(Eof()) )
	
		//---------------------------------------------------------------
		//  Calculando a Porcentagem da Fila
		//---------------------------------------------------------------	
		nAux := ((cNextAlias)->CONTADOR*100) 
		nPerncet := (nAux/(cNextAlias)->MAXCONTA)
		cPerncet := cValToChar(Round(nPerncet,2))+"%"		
	EndIf

	(cNextAlias)->(dbCloseArea())

EndIf

RestArea(aArea)

Return cPerncet

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CRM930DbClk

Rotina do evendo de duplo click no grid

@sample	CRM930DbClk(oFormulario,cFieldName,nLineGrid,nLineModel,oView)

@param		oFormulario - Objeto do Formulário
			cFieldName  - Nome do Campo
			nLineGrid   - Linha do Grid
			nLineModel  - Linha do Model
			oView - Objetio do modelo de interface

@return	lRetorno - Verdadeiro/falso

@author	Jonatas Martins
@since		02/07/2015
@version	12.1.6
/*/
//----------------------------------------------------------------------------------
Static Function CRM930DbClk(oFormulario,cFieldName,nLineGrid,nLineModel,oView)

Local oMdlAZ6		:= Nil
Local oMdlAZ7		:= Nil
Local lRetorno	:= .T.

Default oFormulario := Nil
Default oView       := Nil
Default cFieldName  := ""
Default nLineGrid   := 0
Default nLineModel  := 0

If oView <> Nil .And. ValType(oView) == "O" .And. cFieldName == "AZ7_HIST" 	
	oMdlAZ6 := oView:GetModel("AZ6DETAIL")
	oMdlAZ7 := oView:GetModel("AZ7DETAIL")

	//------------------------------------------------------
	// Executa função de exibição do histórico do processo
	//------------------------------------------------------
   	CRMA930ExView(oMdlAZ6,oMdlAZ7)
			   			
	lRetorno := .F.		   	
EndIf

Return lRetorno

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA930ExView

Rotina que exibe a tela de histórico do processamento

@sample	CRMA930ExView(oMdlAZ7)

@param		oMdlAZ6 	- Objeto do modelo de dados do grid AZ6
			oMdlAZ7	- Objeto do modelo de dados do grid AZ7
			
@return	Nenhum

@author	Jonatas Martins
@since		02/07/2015
@version	12.1.6
/*/
//----------------------------------------------------------------------------------
Static Function CRMA930ExView(oMdlAZ6,oMdlAZ7)

Local aButtons	:= {}
Local aLoadFld	:= {}
Local aLoadGrd	:= {}
Local cCodTer		:= ""
Local cCodFila	:= ""
Local cSeqFila	:= ""
Local cTpMem		:= ""
Local cCodMem		:= ""
Local oModel		:= Nil
Local oMdlAZ4Fld	:= Nil
Local oMdlAZ4Grd	:= Nil

Default oMdlAZ6	:= Nil
Default oMdlAZ7	:= Nil

//------------------------------
// Estância modelo de dados
//------------------------------
oModel:= FWLoadModel("CRMA950A")

If ValType(oModel) == "O"

	//------------------------------------------
	// Obtem os valores do Grid AZ7
	//------------------------------------------	
	cCodTer	:= oMdlAZ7:GetValue("AZ7_CODROD")
	cCodFila	:= oMdlAZ7:GetValue("AZ7_CODFLA")
	cSeqFila	:=	oMdlAZ6:GetValue("AZ6_SEQFLA")
	cTpMem		:= oMdlAZ7:GetValue("AZ7_TPMEM")
	cCodMem	:= oMdlAZ7:GetValue("AZ7_CODMEM")
	
	//----------------------------------------------------
	// Obtem os modelos de dados do cabeçalho e Grid
	//----------------------------------------------------
	oMdlAZ4Fld := oModel:GetModel("AZ4FIELD")
	oMdlAZ4Grd := oModel:GetModel("AZ4GRID")	

	//----------------------------------------------------
	// Função que monta array da valores do Grid
	//----------------------------------------------------
	aLoadGrd := CRM930LdGrd(oMdlAZ4Grd,cCodTer,cSeqFila,cCodFila,cTpMem,cCodMem)
	
	If Len(aLoadGrd) > 0
	
		//----------------------------------------------------
		// Monata array com valores para carregar o cabeçalho
		//----------------------------------------------------
		aAdd(aLoadFld,xFilial("AZ4"))
		aAdd(aLoadFld,cTpMem)
		aAdd(aLoadFld,cCodMem)
		aAdd(aLoadFld,CRMA640Gat(cTpMem,cCodMem))
	
		//---------------------------------------------------------------
		// Atribui arrays de valores no metodo de carregamento do model
		//---------------------------------------------------------------
		oMdlAZ4Grd:bLoad := {|| aLoadGrd }
		oMdlAZ4Fld:bLoad := {|| aLoadFld }
		
		//------------------------------------------------------------
		// Monta array de botões da tela
		//------------------------------------------------------------
		aButtons := {{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}	,;
				 		{.F.,Nil},{.F.,Nil},{.T.,Nil},{.F.,Nil}			,;
				 		{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil},{.F.,Nil}}
		
		//------------------------------
		// Estância visualização
		//------------------------------
		oView := FWLoadView("CRMA950A")
		oView:SetModel(oModel)
		oView:SetOperation(MODEL_OPERATION_UPDATE)
							
		oExecView := FWViewExec():New()
		oExecView:SetTitle(STR0018) //"Histórico do processamento"
		oExecView:SetView(oView)
		oExecView:SetModal(.F.)
		oExecView:SetOperation(MODEL_OPERATION_UPDATE)
		oExecView:SetButtons(aButtons)
		oExecView:SetSize(800,450)
		oExecView:OpenView(.F.)
		FATPDLogUser("CRMA930EXV")
	Else
		Help(,,"CRMA930HIST",,STR0019, 1, 0 ) //"Não existe histórico de processamento para esse membro!"
	EndIf
EndIf

Return Nil

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CRM930LdGrd

Rotina que exibe a tela de histórico do processamento

@sample	CRM930LdGrd(oMdlAZ4Grd,cCodTer,cSeqFila,cCodFila,cTpMem,cCodMem)

@param		oMdlAZ4Grd	- Objeto do modelo de dados do grid AZ4
			cCodTer	- Código do território
			cSeqFila   - Sequência da fila
			cCodFila 	- Código da fila
			cTpMem		- Tipo do membro
			cCodMem	- Código do membro

@return	aDadosGrid	- Array com valores do grid AZ4

@author	Jonatas Martins
@since		02/07/2015
@version	12.1.6
/*/
//----------------------------------------------------------------------------------
Static Function CRM930LdGrd(oMdlAZ4Grd,cCodTer,cSeqFila,cCodFila,cTpMem,cCodMem)

Local aArea		:= GetArea()
Local aAreaAZ4	:= AZ4->(GetArea())
Local aDadosGrid	:= {}
Local oStrAZ4Grd	:= {}
Local aCampos		:= {}
Local nX			:= 0

Default oMdlAZ4Grd	:= Nil
Default cCodTer		:= ""
Default cCodFila		:= ""
Default cSeqFila		:= ""
Default cTpMem		:= ""
Default cCodMem		:= ""

If ValType(oMdlAZ4Grd) == "O"
	oStrAZ4Grd	:= oMdlAZ4Grd:GetStruct()
	aCampos	:= oStrAZ4Grd:GetFields() 

	//--------------------------------------------------
	// Verifica se o registro existe no banco de dados
	//--------------------------------------------------
	DbSelectArea("AZ4")
	DbSetOrder(2) // AZ4_FILIAL + AZ4_CODROD + AZ4_CODFLA + AZ4_SEQFLA + AZ4_TPMEM + AZ4_CODMEM
	If AZ4->(DbSeek(xFilial("AZ4")+cCodTer+cCodFila+cSeqFila+cTpMem+cCodMem))
	
		//------------------------------------------------
		// Obtem valores dos registros do banco de dados 
		//------------------------------------------------
		While AZ4->(!EOF()) .And. AZ4->AZ4_CODROD == cCodTer .And. AZ4->AZ4_CODFLA == cCodFila ;
								.And. AZ4->AZ4_SEQFLA == cSeqFila .And. AZ4->AZ4_TPMEM == cTpMem ;
								.And. AZ4->AZ4_CODMEM == cCodMem
								
			aAdd(aDadosGrid,{AZ4->(Recno()),{}})
			
			For nX := 1 To Len(aCampos)
				If !aCampos[nX][MODEL_FIELD_VIRTUAL]
					cMacro := "AZ4->"+ALlTrim(aCampos[nX][MODEL_FIELD_IDFIELD])
				Else 
					If aCampos[nX][MODEL_FIELD_IDFIELD] == "AZ4_LOG"
						cMacro := "'LUPA'"
					ElseIf aCampos[nX][MODEL_FIELD_IDFIELD] == "AZ4_DSCMEM"
						cMacro := "CRMA640Gat(cTpMem,cCodMem)"
					ElseIf aCampos[nX][MODEL_FIELD_IDFIELD] == "AZ4_DSCCNT"
						cMacro := "CRMA950INIT('AZ4_DSCCNT')"
					EndIf
				EndIf
			
				aAdd(aDadosGrid[Len(aDadosGrid),2] , &cMacro )
			Next nX	
			
			AZ4->(DbSkip())
		End
	EndIf
EndIf

RestArea(aAreaAZ4)
RestArea(aArea)

Return (aDadosGrid)

//----------------------------------------------------------------------------------
/*/{Protheus.doc} CRM930RodSeg

Função que altera o tipo do rodízio para segmentado no cadastro do território,
quando o rodízio é excluido

@sample	CRM930RodSeg(oModel,nOperation)

@param		oModel		, objeto	,	Modelo de dados do território
			nOperation	, numerico,	Tipo da operação do modelo
			
@return	lRet, logico, Veradeiro/Falso

@author	Jonatas Martins
@since		18/07/2015
@version	12.1.6
/*/
//----------------------------------------------------------------------------------
Static Function CRM930RodSeg(oModel,nOperation)

Local lRet := .T.

Default oModel 		:= Nil
Default nOperation	:= 0

If oModel:GetId() == "CRMA640" .And. nOperation == MODEL_OPERATION_DELETE
	lRet := oModel:SetValue("AOYMASTER","AOY_TPROD","2") // Rodízio Segmentado
	
	If lRet .And. oModel:VldData()
		lRet := oModel:CommitData()
	EndIf	
EndIf

Return ( lRet )

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLogUser
    @description
    Realiza o log dos dados acessados, de acordo com as informações enviadas, 
    quando a regra de auditoria de rotinas com campos sensíveis ou pessoais estiver habilitada
	Remover essa função quando não houver releases menor que 12.1.27

   @type  Function
    @sample FATPDLogUser(cFunction, nOpc)
    @author Squad CRM & Faturamento
    @since 06/01/2020
    @version P12
    @param cFunction, Caracter, Rotina que será utilizada no log das tabelas
    @param nOpc, Numerico, Opção atribuída a função em execução - Default=0

    @return lRet, Logico, Retorna se o log dos dados foi executado. 
    Caso o log esteja desligado ou a melhoria não esteja aplicada, também retorna falso.

/*/
//-----------------------------------------------------------------------------
Static Function FATPDLogUser(cFunction, nOpc)

	Local lRet := .F.

	If FATPDActive()
		lRet := FTPDLogUser(cFunction, nOpc)
	EndIf 

Return lRet  

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDActive
    @description
    Função que verifica se a melhoria de Dados Protegidos existe.

    @type  Function
    @sample FATPDActive()
    @author Squad CRM & Faturamento
    @since 17/12/2019
    @version P12    
    @return lRet, Logico, Indica se o sistema trabalha com Dados Protegidos
/*/
//-----------------------------------------------------------------------------
Static Function FATPDActive()

    Static _lFTPDActive := Nil
  
    If _lFTPDActive == Nil
        _lFTPDActive := ( GetRpoRelease() >= "12.1.027" .Or. !Empty(GetApoInfo("FATCRMPD.PRW")) )  
    Endif

Return _lFTPDActive  
