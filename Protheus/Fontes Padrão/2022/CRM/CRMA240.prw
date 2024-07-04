#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "CRMA240.CH"
 
//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA240 

Estrutura de Negócio

Determina o tipo de interface de abertura: Hierarquica ou em tabela
 
@sample	CRMA240()

@param		Nenhum
             
@return	Nenhum

@author	Thamara Villa 
@since		25/05/2015
@version	12.1.6
/*/
//------------------------------------------------------------------------------ 
Function CRMA240()

Local oDlg      := Nil
Local oPanel	:= Nil
Local oSay   	:= Nil 
Local aFieldsPD := {"AO5_DESCRE"}

Private lRecortar	:= .F.
Private aAllUsers	:= {} 	// Array(ordenado por nome) com todos os usuarios do sistema mas somente os dados necessarios para a tela.


	FATPDLoad(Nil,Nil,aFieldsPD) 
	                
	oDlg := FwDialogModal():New()
	oDlg:SetBackGround( .T. )
	oDlg:SetTitle( STR0066 )//"Modo de exibição"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
	oDlg:SetEscClose( .T. )
	oDlg:SetSize( 100, 150 )
	oDlg:EnableFormBar( .T. )
	
	oDlg:CreateDialog()	

	oPanel := oDlg:GetPanelMain()
	
	oDlg:CreateFormBar()
	
	oSay := TSay():New( 10, 10, { || STR0067 }, oPanel,,,,,,.T. ) //"Deseja abrir a estrutura de negócios em formato: "
	
	oDlg:AddButton( STR0068,{|| CA240Estru(), oDlg:Deactivate() }, STR0068, , .T., .F., .T., )//"Hierárquico"
	oDlg:AddButton( STR0069,{|| FWMsgRun(/*oComponent*/,{|| CRMA900() }, STR0070, STR0071 ), oDlg:Deactivate() }, STR0069, , .T., .F., .T., )//"Tabela" ##"Aguarde" ## "Carregando registros"
			
	oDlg:Activate()
	FATPDUnLoad()

Return .T.

//------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA240

Estrutura de Negócio

@sample		CRMA240()

@param		Nenhum
             
@return		Nenhum

@author		Thiago Tavares
@since		10/02/2013
@version	12.00
/*/
//------------------------------------------------------------------------------
Function CA240Estru()

Local aUser	  := {}
Local cAliasTmp := GetNextAlias()

// Guardando num ARRAY as informacoes necessarias dos usuários
// aAllUsers[1] = Nome Completo       
// aAllUsers[2] = Cargo               
// aAllUsers[3] = Departamento        
// aAllUsers[4] = ID                   
// aAllUsers[5] = Usuario             
  
// carregando o ARRAY com os usuários da tabela AO3 - Usuarios do CRM


BeginSql Alias cAliasTmp
	SELECT AO3.AO3_CODUSR FROM %Table:AO3% AO3 
	WHERE AO3.AO3_FILIAL = %xFilial:AO3% AND  
	AO3.AO3_MSBLQL <> '1' AND AO3.%NotDel%
EndSql
	
While(cAliasTmp)->(!Eof()) 
	aUser := FWSFAllUsers({(cAliasTmp)->AO3_CODUSR})
	If !Empty(aUser)
		aAdd(aAllUsers,{aUser[1][4],aUser[1][7],aUser[1][6],aUser[1][2],aUser[1][3]})
	EndIf
	(cAliasTmp)->(DbSkip())
End
	
(cAliasTmp)->( DbCloseArea() )

aSort(aAllUsers, , , { |x, y| x[1] < y[1] } ) //CRESCENTE Alfabetica

FWMsgRun(/*oComponent*/,{|| CA240MTree() },STR0063,STR0064) // "Aguarde" "Montando a Estrutura de Negócio..."

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240MTree
 
Monta Estrutura Negócio

@sample	CA240MTree()

@param		Nenhum
             
@return	Nenhum

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240MTree()

Local aArea     	:= GetArea()
Local aSizeAut  	:= MsAdvSize( .F. )
Local aObjects  	:= {}
Local aInfo     	:= {} 
Local aObj      	:= {}  
Local aNodes    	:= {}
Local aRecorte  	:= {}
Local oTree     	:= Nil
Local nNiveis   	:= 0
Local nX        	:= 0
Local cNX       	:= ""
Local cDescTree		:= ""
Local cAliasTmp 	:= GetNextAlias()
Local oDlg      	:= Nil
Local oPnlFol   	:= Nil
Local nOpca     	:= 0
Local cDescEnt  	:= ""
Local cCpoDesc		:= ""
Local lRetorno 		:= .T.
Local cBitmap		:= ""
Local aNodesPar 	:= {}	//Array de gravacao parcial (contem apenas alteracoes feitas na estrutura pontualmente)

Local cTEntPai		:= ""	//Alias da entidade PAI
Local cTCODPAI		:= ""	//Codigo da entidade PAI
Local aFather		:= {} 	//Array que recebe os codigos de entidades PAI
Local nLvl			:= 0	//Laco para FOR/NEXT
Local aNodesBkp		:= {}
Local cUsrObfusc    := ""
Local lDescObfus    := .F.

Private oBtnRepro 	:= Nil
Private lChange   	:= .F. 

aAdd( aObjects, { 100, 100, .T., .T. } ) 
aAdd( aObjects, {  70, 100, .F., .T. } ) 

aInfo := { aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3 } 
aObj  := MsObjSize( aInfo, aObjects, , .T. ) 

oDlg := FWDialogModal():New()
oDlg:SetBackground( .F. )  
oDlg:SetTitle( STR0002 )		// "Estrutura de Negócio"
oDlg:SetEscClose( .T. )
oDlg:EnableAllClient() 
oDlg:EnableFormBar( .F. ) 
oDlg:CreateDialog() 

oPnlFol := oDlg:GetPanelMain()

// Cria a Tree    
oTree := DbTree():New( aObj[1,1], aObj[1,2], aObj[1,3], aObj[1,4], oPnlFol,{|| .T.} ,{|| .T.} , .T.)

BeginSql Alias cAliasTmp
	SELECT MAX(AO5_NVESTN) NIVEIS FROM %Table:AO5% AO5 WHERE AO5.AO5_FILIAL = %xFilial:AO5% AND AO5.%NotDel%
EndSql

nNiveis := (cAliasTmp)->NIVEIS

oTree:BeginUpdate() 

// Adicionando os itens da Estrutura de Negocio
If nNiveis > 0
	oTree:AddItem( PADR( STR0002, 100 ), PadR("000-RAIZ", 10), "FOLDER5", "FOLDER6", , , 2 )		// "Estrutura de Negócio"
Else
	oTree:AddItem( PADR( STR0002, 100 ), PadR("000-RAIZ", 10), "FOLDER5", "FOLDER5", , , 2 )		// "Estrutura de Negócio"
EndIf

If nNiveis == 0
	aAdd( aNodes, {} )
Else
	lDescObfus :=  FATPDIsObfuscate("AO5_DESCRE") 

	For nX := 1 To nNiveis
		
		aAdd( aNodes, {} )
		cNX := AllTrim(Str(nX)) 		
		cAliasTmp	:= GetNextAlias()

		BeginSql Alias cAliasTmp 

			SELECT AO5.AO5_ENTPAI, AO5.AO5_CODPAI, AO5.AO5_ENTANE, AO5.AO5_CODANE, 
					AO5.AO5_IDESTN, AO5.AO5_NVESTN
			FROM %Table:AO5% AO5
			WHERE AO5.AO5_FILIAL = %xFilial:AO5% AND AO5.AO5_NVESTN = %Exp:cNX% AND AO5.%NotDel%
			ORDER BY AO5.AO5_IDESTN
						  	
		EndSql

		(cAliasTmp)->( DbGoTop() )
	
		While !(cAliasTmp)->( Eof() )
		
			If (cAliasTmp)->AO5_ENTANE == "USU"
			 	If lDescObfus .And. Empty(cUsrObfusc)
			 		cUsrObfusc := FATPDObfuscate(AllTrim(UsrRetName((cAliasTmp)->AO5_CODANE)))
			 	Endif
				cDescEnt := Iif(Empty(cUsrObfusc), AllTrim(UsrRetName((cAliasTmp)->AO5_CODANE)), cUsrObfusc)
			Else
				If (cAliasTmp)->AO5_ENTANE == "ACA"
					cCpoDesc := "ACA_DESCRI"
				Else
					cCpoDesc := "ADK_NOME"	
				EndIf					
				cDescEnt := AllTrim(Posicione((cAliasTmp)->AO5_ENTANE,1,xFilial((cAliasTmp)->AO5_ENTANE)+(cAliasTmp)->AO5_CODANE,cCpoDesc))
			EndIf
			
			cDescTree := PadR( (cAliasTmp)->AO5_CODANE + " - " + cDescEnt, 100 )
		
			IF	(cAliasTmp)->AO5_ENTPAI + "-" + (cAliasTmp)->AO5_CODPAI <> cTEntPai+"-"+cTCODPAI
	
				oTree:TreeSeek( (cAliasTmp)->AO5_ENTPAI + "-" + (cAliasTmp)->AO5_CODPAI )
					
				aAdd( aFather, { (cAliasTmp)->AO5_ENTPAI + "-" + (cAliasTmp)->AO5_CODPAI , (cAliasTmp)->AO5_NVESTN } ) 
					
				cTEntPai 	:= (cAliasTmp)->AO5_ENTPAI  
				cTCODPAI	:= (cAliasTmp)->AO5_CODPAI
					
			Endif
			
			If (cAliasTmp)->AO5_ENTANE == "ADK"  
				cBitmap 	:= "ATFIMG32"
			ElseIf (cAliasTmp)->AO5_ENTANE == "ACA"
				cBitmap	:= "BMPGROUP"
			Else 
				cBitmap	:= "BMPUSER"
			EndIf
					
			oTree:AddItem( cDescTree, (cAliasTmp)->AO5_ENTANE + "-" + (cAliasTmp)->AO5_CODANE, cBitmap, cBitmap, , , 2)
		
			/*	
			----------------------------------------------------------------------------
			*********Array aNodes ****************
			----------------------------------------------------------------------------
			01- ENTPAI
			02- CODPAI
			03- ENTANE
			04- CODANE
			05- IDESTN
			06- NVESTN
			07- CARGO TREE
			08- DESC TREE
			09- STATUS	(1=Considera, 2=Nao considera, 3=Nivel alterado, 4=Recortado)
			10- DESCRICAO ENTIDADE
			----------------------------------------------------------------------------		 
			*/
			
			If (cAliasTmp)->AO5_ENTANE == "USU"
				cDescEnt := AllTrim(UsrRetName((cAliasTmp)->AO5_CODANE))
			Else
				If (cAliasTmp)->AO5_ENTANE == "ACA"
					cCpoDesc := "ACA_DESCRI"
				Else
					cCpoDesc := "ADK_NOME"	
				EndIf					
				cDescEnt := AllTrim(Posicione((cAliasTmp)->AO5_ENTANE,1,xFilial((cAliasTmp)->AO5_ENTANE)+(cAliasTmp)->AO5_CODANE,cCpoDesc))
			EndIf
			
			aAdd( aNodes[nX], { (cAliasTmp)->AO5_ENTPAI, ;
								   AllTrim( (cAliasTmp)->AO5_CODPAI ), ;
								   (cAliasTmp)->AO5_ENTANE, ;
								   (cAliasTmp)->AO5_CODANE, ;
								   (cAliasTmp)->AO5_IDESTN, ;
								   (cAliasTmp)->AO5_NVESTN, ;
								   (cAliasTmp)->AO5_ENTANE + "-" + (cAliasTmp)->AO5_CODANE, ; 
								   cDescTree, ;
								   1, ;
								   cDescEnt } )
								      
			(cAliasTmp)->( dbSkip() ) 
		End

		(cAliasTmp)->( DbCloseArea() )

	Next nX

	RestArea( aArea ) 
	
	aSort( aFather,,,{|x,y| x[2] > y[2] } )
		
	For nLvl := 1 To Len( aFather )
		oTree:TreeSeek( aFather[nLvl,1] )
		oTree:PTCollapse()
	Next nLvl
		
	//Cria backup do aNodes para comparação.
	aNodesBkp := aClone(aNodes)
	oTree:EndUpdate()
		
EndIf
	
@ aObj[2,1] - 1, aObj[2,2] TO aObj[2,3], aObj[2,4] PIXEL 
         
nLin := aObj[2,1] +  8 
nCol := aObj[2,2] + 10 
 
MENU oMenu POPUP

	MenuAddItem(STR0003	,,,.T.	,{|| CA240Menu( @oTree, "INUDN", oMenu, @aNodes, aRecorte, @aNodesPar) }	,"","ADICIONAR_001"		)	//"Anexar Unidade de Negócio"
	MenuAddItem(STR0005	,,,.T.	,{|| CA240Menu( @oTree, "INEQP", oMenu, @aNodes, aRecorte, @aNodesPar) }	,"","ADICIONAR_001"		)	//"Anexar Equipe de Venda"
	MenuAddItem(STR0105	,,,.T.	,{|| CA240Menu( @oTree, "INUSU", oMenu, @aNodes, aRecorte, @aNodesPar) }	,"","ADICIONAR_001"		)	//"Anexar Usuário"	
	
	MENUITEM "_____________________" Disabled
	
	MenuAddItem(STR0004	,,,.T.	,{|| CA240Menu( @oTree, "EXUDN", oMenu, @aNodes, aRecorte, @aNodesPar) }	,"","EXCLUIR"		)	//"Excluir Unidade de Negócio"
	MenuAddItem(STR0006	,,,.T.	,{|| CA240Menu( @oTree, "EXEQP", oMenu, @aNodes, aRecorte, @aNodesPar) }	,"","EXCLUIR"		)	//"Excluir Equipe de Venda"
	MenuAddItem(STR0106	,,,.T.	,{|| CA240Menu( @oTree, "EXUSU", oMenu, @aNodes, aRecorte, @aNodesPar) }	,"","EXCLUIR"		)	//"Excluir Usuário"		

	MENUITEM "_____________________" Disabled      
	
	MenuAddItem(STR0009	,,,.T.	,{|| CA240Menu( @oTree, "RECOR", oMenu, @aNodes, @aRecorte,@aNodesPar ) }	,"","RECORTAR"		) //"Recortar"
	MenuAddItem(STR0010	,,,.T.	,{|| CA240Menu( @oTree, "COLAR", oMenu, @aNodes, aRecorte, @aNodesPar ) }	,"","COPYUSER"		) //"Colar"
	
	MENUITEM "_____________________" Disabled
	
	MenuAddItem(STR0011	,,,.T.	,{|| CA240Pesq( @oTree )}	,"","PESQUISA"		)	//"Pesquisar" 
	MenuAddItem(STR0012	,,,.T.	,{|| CA240Menu( @oTree, "VISUA", oMenu, @aNodes, aRecorte) }	,"","VERNOTA"		)	//"Visualizar" 
	MenuAddItem(STR0013	,,,.T.	,{|| CA240Menu( @oTree, "LIMPA", oMenu, @aNodes, aRecorte) }	,"","SDUERASE"		)	//"Limpar"
	
ENDMENU

oTree:bRClicked  := { |oTree, x, y | CA240MAct( oTree, x, y, oMenu ) } // Posição x,y em relação a Dialog 

@ aObj[2,1] + 24, aObj[2,4] - 33 BUTTON oOpc PROMPT STR0060 ACTION CA240MAct( oTree, oOpc:nRight - 5, oOpc:nTop - 118, oMenu ) SIZE 27, 11 OF oPnlFol PIXEL  //"Opcoes"

@ aObj[2,1] + 24, aObj[2,4] - 65 BUTTON oBtnRepro ;
								     PROMPT STR0062 ;			// "Gerar"
								     ACTION { || ( ( lChange := .T. , FWMsgRun(/*oComponent*/,{|| lRetorno := CA240Grava(aNodesBkp, aNodes, aNodesPar) },STR0063,STR0065 ) ),;
								     					IIF(lRetorno,( nOpca := 0,oDlg:DeActivate() ), MsgAlert(STR0014)) ) } ;	//"Aguarde"#"Processando a Estrutura de Negócio..."	// "Falha ao gravar a Estrutura."
								     SIZE 27, 11 OF oPnlFol PIXEL 						
If Len ( aNodes[1] ) == 0
	oBtnRepro:Hide()
EndIf	

DEFINE SBUTTON FROM aObj[2,1] + 7, aObj[2,4] - 65 TYPE 1 ENABLE OF oPnlFol ACTION ( nOpca := 1,oDlg:DeActivate() )
DEFINE SBUTTON FROM aObj[2,1] + 7, aObj[2,4] - 33 TYPE 2 ENABLE OF oPnlFol ACTION ( nOpca := 0,oDlg:DeActivate() )

oDlg:Activate() 

If nOpca == 1  
	FWMsgRun(/*oComponent*/,{|| lRetorno := CA240Grava(aNodesBkp, aNodes, aNodesPar) },STR0063,STR0065)
	If !lRetorno
		MsgAlert(STR0014)	//"Falha ao gravar a Estrutura." //"Aguarde"#"Processando a Estrutura de Negócio..."
	EndIf 
EndIf

Return(lRetorno)  

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240MAct

Funcao que monta o menu ao clicar em "Opções" ou botão direito do mouse

@sample	CA240MAct( oTree, nX, nY, oMenu )

@param		oTree 	- Objeto Tree
			nX		- Dimensao X
			nY		- Dimensao Y
			oMenu	- Objeto Menu
             
@return	Nenhum

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240MAct( oTree, nX, nY, oMenu )  

Local lPDWhen := FATPDIsObfuscate("AO5_DESCRE")                            

// 1  - cAction == INUDN -> "Anexar Unid. de Negócio"       
// 2  - cAction == EXUDN -> "Excluir Unid. de Negócio"   
// 3  - cAction == INEQP -> "Anexar Equipe de Venda" 	      
// 4  - cAction == EXEQP -> "Excluir Equipe de Venda"       
// 5  - cAction == INUSU -> "Anexar Usuário"      
// 6  - cAction == EXUSU -> "Excluir Usuário"      
// 7  - cAction == RECOR -> "Recortar"    
// 8  - cAction == COLAR -> "Colar"    
// 9  - cAction == Vazio -> "Pesquisa"   	 
// 10 - cAction == VISUA -> "Visualiza" 			
// 11 - cAction == LIMPA -> "Limpar" 			

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Desabilita todos os itens do menu                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AEval( oMenu:aItems, { |x| x:Disable() } ) 

If !lPDWhen

	cCargo := oTree:GetCargo() 
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Habilita as opcoes de acordo com a entidade do tree          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If AllTrim(cCargo) == "000-RAIZ"
		
		//Anexar
		oMenu:aItems[1]:enable()	//"Unidade de Negócio"
		oMenu:aItems[3]:enable()	//Anexar usuário
		If ( lRecortar ) 
			oMenu:aItems[10]:enable()	//"Colar"
		EndIf
		
		oMenu:aItems[12]:enable()	//"Pesquisar"	
	
	ElseIf Left( cCargo, 3 ) == "ADK"
	
		//Anexar
		oMenu:aItems[01]:enable()	//"Unidade de Negócio"
		oMenu:aItems[02]:enable()	//"Equipe de Venda"
		oMenu:aItems[03]:enable()	//"Usuário"
	
		//Excluir		
		oMenu:aItems[05]:enable() 	//"Unidade de Negócio"
		
		oMenu:aItems[09]:enable()	//"Recortar" 
		
		If ( lRecortar ) 
			oMenu:aItems[10]:enable()	//"Colar"
		EndIf
		
		oMenu:aItems[12]:enable()	//"Pesquisar"
		oMenu:aItems[13]:enable()	//"Visualizar"
	
	ElseIf Left( cCargo, 3 ) == "ACA"
	    
	    //Anexar
		oMenu:aItems[02]:enable()	//"Equipe de Venda"  
	   	oMenu:aItems[03]:enable()	//"Usuário"
	
		//Excluir  
		oMenu:aItems[06]:enable()	//"Equipe de Venda"
		
		oMenu:aItems[09]:enable()	//"Recortar"
		  
		If ( lRecortar ) 
			oMenu:aItems[10]:enable()
		EndIf
		
		oMenu:aItems[12]:enable()	//"Pesquisar"
		oMenu:aItems[13]:enable()	//"Visualizar"
		
	ElseIf Left( cCargo, 3 ) == "USU"
		
		//Anexar
		oMenu:aItems[01]:enable()	//"Unidade de de Negócio"  
		oMenu:aItems[02]:enable()	//"Equipe de Venda"//oMenu:aItems[03]:enable()	//"Usuário"  
	   	
		//Excluir
		oMenu:aItems[07]:enable()	//"Usuário"
		oMenu:aItems[09]:enable()	//"Recortar"
	
		If ( lRecortar ) 
			oMenu:aItems[10]:enable()
		EndIf

		oMenu:aItems[12]:enable()	//"Pesquisar"
		oMenu:aItems[13]:enable()	//"Visualizar"
					
	EndIf 
	
	// Opção LIMPAR sempre fica habilitada
	oMenu:aItems[14]:enable()	//"Limpar"
	
EndIf
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa o Menu PopUp                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nY < 0
	oMenu:Activate( nX - 150, nY + 130, oTree )   // botão "Opções"
Else
	oMenu:Activate( nX - 120, nY - 120, oTree )  // botão direito
EndIf
                                   
Return   

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240Menu

Funcao que executa as ações do menu

@sample	CA240Menu( oTree, cAction, oMenu, aNodes, aRecorte )

@param		oTree		- Objeto Tree
			cAction	- Acao
			oMenu		- Objeto Menu 
			aNodes		- Array de controle dos NODES da Tree
			aRecorte	- Array de controle do NODE recortado
			aNodesPar	- Array de gravacao parcial
             
@return	Nenhum

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240Menu( oTree, cAction, oMenu, aNodes, aRecorte, aNodesPar )

Local cDesc     := ""
Local cCargo	  := ""
Local nScan     := 0     
Local nScan2	  := 0     
Local lFound	  := .F.
Local nX, nY	  := 0
Local cIDEstN	  := ""
Local cEntidade := ""
Local cCodigo	  := ""
Local cCodUsu   := RetCodUsr()
Local nNivel    := 0
Local lContinua := .T.

Private cCadastro := ""
                                                 
// cAction == INUDN -> "Anexar Unid. de Negócio"       
// cAction == EXUDN -> "Excluir Unid. de Negócio"   
// cAction == INEQP -> "Anexar Equipe de Venda" 	      
// cAction == EXEQP -> "Excluir Equipe de Venda"       
// cAction == INUSU -> "Anexar Usuário"      
// cAction == EXUSU -> "Excluir Usuário"      
// cAction == RECOR -> "Recortar"    
// cAction == COLAR -> "Colar"    
// cAction == Vazio -> "Pesquisa"   	 
// cAction == VISUA -> "Visualiza" 			
// cAction == LIMPA -> "Limpar" 			

// indicando que houve mudança na estrutura
lChange := .T.

cCargo  	:= oTree:GetCargo()
cEntidade	:= SubStr( cCargo, 1, Rat( "-", cCargo ) - 1 )
cCodigo 	:= AllTrim( SubStr( cCargo, Rat( "-", cCargo ) + 1, Len( cCargo ) ) )

If cAction != "RECOR" .And. cAction != "COLAR" .And. lRecortar
	CA240DelCut( oTree,aNodes,aRecorte )  
	CA240LStts( @aNodes, 4, 1 )
	lRecortar := .F.
	aRecorte  := {}
	aSize( aRecorte, 0 )
	oTree:TreeSeek( cCargo )
EndIf

oTree:BeginUpdate()

Do Case 

	Case cAction == "INUDN"   // "Anexar Unid. de Negócio"
		
		If ConPad1( , , , "ADK", , , .F. )
			lFound := oTree:TreeSeek("ADK-" + ADK->ADK_COD )
			If lFound 
				Aviso( STR0015, I18N( STR0016 + "#1 - #2" + STR0017, { AllTrim( ADK->ADK_COD ), AllTrim( ADK->ADK_NOME ) } ), { "OK" }, 2 )		// "Atenção"    "A Unidade de Negócio: "   " já está na estrutura"         
			Else
				If Aviso( STR0015, I18N( STR0019 + "#1 - #2 ?", { AllTrim( ADK->ADK_COD), AllTrim( ADK->ADK_NOME ) } ), { STR0020, STR0021 }, 2 ) == 1		// "Atenção"   "Confirma a inclusão da Unidade de Negócio: "     "Sim"    "Não"
					cDesc := PadR( ADK->ADK_COD + " - " + ADK->ADK_NOME , 100 )
					oTree:AddItem( cDesc, "ADK" + "-" + ADK->ADK_COD, "ATFIMG32", "ATFIMG32", , , 2)   
										
					// inserindo na raiz
					If AllTrim(cCargo) == "000-RAIZ"
						For nX := 1 To Len( aNodes[1] )
							If aNodes[1, nX, 9] != 2 
								cIDEstN := Soma1( AllTrim( aNodes[1, nX, 5] ) )
							EndIf
						Next nX
						aAdd( aNodes[1], {"000", "RAIZ", "ADK", ADK->ADK_COD, Iif( cIDEstN == "", "01", cIDEstN ), 1, "ADK-" +  ADK->ADK_COD, cDesc, 1, ADK->ADK_NOME } )

						//Alteracao pontual
						aAdd(aNodesPar,{	"INUDN", ADK->ADK_COD, "000" ,"RAIZ" , "ADK", cIDEstN, 1, 4 })	
						
					Else
						
						// inserindo abaixo de uma entidade já cadastrada como NODE pai
						For nX := 1 To Len( aNodes )
							nScan := aScan( aNodes[nX], { |x| (x[1] == cEntidade .And. AllTrim(x[2]) == alltrim(cCodigo) .And. x[9] != 2 ) } ) //alltrim inserido 
							If nScan > 0
								cIDEstN := Soma1( AllTrim( CA240RIDEN( aNodes, aNodes[nX, nScan, 1], aNodes[nX, nScan, 2] ) ) )
								aAdd( aNodes[nX], { aNodes[nX, nScan, 1], aNodes[nX, nScan, 2], "ADK", ADK->ADK_COD, cIDEstN, nX, "ADK-" +  ADK->ADK_COD, cDesc, 1, ADK->ADK_NOME} )
								
								//Alteracao pontual
								aAdd(aNodesPar,{	"INUDN", ADK->ADK_COD, aNodes[nX, nScan, 1] ,aNodes[nX, nScan, 2] , "ADK", cIDEstN, nX , 4 })	
								
								Exit
							EndIf
						Next nX
						
						// inserindo abaixo de uma entidade ainda não cadastrada como NODE pai
						If nScan == 0
							For nX := 1 To Len( aNodes )
								nScan := aScan( aNodes[nX], { |x| ( x[3] == cEntidade .And. AllTrim(x[4]) == alltrim(cCodigo) .And. x[9] != 2 ) } ) //alltrim inserido
								If nScan > 0
									aAdd( aNodes, {} )
									cIDEstN := AllTrim( aNodes[nX, nScan, 5] ) + "01"
									aAdd( aNodes[nX + 1], { aNodes[nX, nScan, 3], aNodes[nX, nScan, 4], "ADK", ADK->ADK_COD, cIDEstN, nX + 1, "ADK-" +  ADK->ADK_COD, cDesc, 1, ADK->ADK_NOME } )
									
									//Alteracao pontual
									aAdd(aNodesPar,{	"INUDN", ADK->ADK_COD, aNodes[nX, nScan, 3] ,aNodes[nX, nScan, 4] , "ACA", cIDEstN, nX + 1, 4})									
									  
									Exit 
								EndIf
							Next nX
						EndIf
					EndIf
					oTree:TreeSeek( "000-RAIZ" )
					oTree:TreeSeek( "ADK" + "-" + ADK->ADK_COD )
					oTree:Refresh()		                    
				EndIf				
			EndIf 
		EndIf
	
	Case cAction == "EXUDN"   // "Excluir Unid. de Negócio"
		 		
		If Aviso( STR0015, I18N( STR0018 + "#1 ?", { oTree:GetPrompt( .F. ) } ), { STR0020, STR0021 }, 2 ) == 1		// "Atenção"    "Confirma a exclusão da Unidade de Negócio: "   "Sim"    "Não"
			oTree:DelItem() 	
			For nX := 1 To Len( aNodes )
				nScan := aScan( aNodes[nX], { |x| ( x[3] == "ADK" .And. AllTrim(x[4]) == alltrim(cCodigo) ) } ) //alltrim inserido
				If nScan > 0
					aNodes[nX, nScan, 9] := 2
					cIDEstN := AllTrim( aNodes[nX, nScan, 5] ) 
					nNivel  := aNodes[nX, nScan, 6]
					
					//Alteracao pontual
					aAdd(aNodesPar,{	"EXUDN", cCodigo, , , "ADK", cIDEstN, nNivel,1 })					
					
					Exit
				EndIf
			Next nX
			oTree:TreeSeek( "000-RAIZ" )
			oTree:TreeSeek( aNodes[nX, nScan, 1] + "-" + aNodes[nX, nScan, 2] )
			oTree:Refresh()		                    

			// apagando os NODES filhos			
			CA240DelFi( @aNodes, "ADK", cCodigo, nNivel,@aNodesPar)
			// corrigindo o nível da estrutura após a exclusao
			CA240SNvl( @aNodes, "ADK", cCodigo, AllTrim( cIDEstN ), nNivel, 2, .T.)
			// corrigindo o status pra 1
			CA240LStts( @aNodes, 3, 1 )
			// se a arvore ficar vazia, é preciso realizar o reset
			If oTree:Total() == 1
				CA240Reset( @oTree, @aNodes, @aRecorte)
			EndIf			
		EndIf

	Case cAction == "INEQP"   // "Anexar Equipe de Venda"
		
		If ConPad1( , , , "ACA" , , , .F. )
			lFound := oTree:TreeSeek("ACA-" + ACA->ACA_GRPREP )
			cDesc := PadR( ACA->ACA_GRPREP + " - " + ACA->ACA_DESCRI , 100 )
			If lFound 
				Aviso( STR0015, I18N( STR0022 + "#1" + STR0017, { AllTrim( cDesc ) } ), { "OK" }, 2 )			// "Atenção"    "A Equipe de Venda: "    " já está na estrutura"
			Else
				If Aviso( STR0015, I18N( STR0023 + "#1 ?", { AllTrim( cDesc ) } ), { STR0020, STR0021 }, 2 ) == 1		// "Atenção"    "Confirma a inclusão da Equipe de Venda: "   "Sim"   "Não"
					oTree:TreeSeek( cCargo )
					oTree:AddItem( cDesc, "ACA" + "-" + ACA->ACA_GRPREP, "BMPGROUP", "BMPGROUP", , , 2)   
					
					// inserindo abaixo de uma entidade já cadastrada como NODE pai
					For nX := 1 To Len( aNodes )
						nScan := aScan( aNodes[nX], { |x| ( x[1] == cEntidade .And. AllTrim(x[2]) == alltrim(cCodigo) .And. x[9] != 2 ) } ) //alltrim inserido
						If nScan > 0
							cIDEstN := Soma1( AllTrim( CA240RIDEN( aNodes, aNodes[nX, nScan, 1], aNodes[nX, nScan, 2] ) ) )
							aAdd( aNodes[nX], { aNodes[nX, nScan, 1], aNodes[nX, nScan, 2], "ACA", ACA->ACA_GRPREP, cIDEstN, nX, "ACA-" +  ACA->ACA_GRPREP, cDesc, 1, ACA->ACA_DESCRI } )
							
							//Alteracao pontual
							aAdd(aNodesPar,{	"INEQP", ACA->ACA_GRPREP, aNodes[nX, nScan, 1] ,aNodes[nX, nScan, 2] , "ACA", cIDEstN, nX, 5 })	
							  
							Exit
						EndIf
					Next nX
					
					// inserindo abaixo de uma entidade ainda não cadastrada como NODE pai
					If nScan == 0
						For nX := 1 To Len( aNodes )
							nScan := aScan( aNodes[nX], { |x| ( x[3] == cEntidade .And. AllTrim(x[4]) == alltrim(cCodigo) .And. x[9] != 2 ) } ) //alltrim inserido
							If nScan > 0
								aAdd( aNodes, {} )
								cIDEstN := AllTrim( aNodes[nX, nScan, 5] ) + "01"
								aAdd( aNodes[nX + 1], { aNodes[nX, nScan, 3], aNodes[nX, nScan, 4], "ACA", ACA->ACA_GRPREP, cIDEstN, nX + 1, "ACA-" +  ACA->ACA_GRPREP, cDesc, 1, ACA->ACA_DESCRI } )
								
								//Alteracao pontual
								aAdd(aNodesPar,{	"INEQP", ACA->ACA_GRPREP, aNodes[nX, nScan, 3] ,aNodes[nX, nScan, 4] , "ACA", cIDEstN, nX + 1, 5})
								  
								Exit 
							EndIf
						Next nX
					EndIf
					oTree:TreeSeek( "000-RAIZ" )
					oTree:TreeSeek( "ACA" + "-" + ACA->ACA_GRPREP )
					oTree:Refresh()		                    
				EndIf				
			EndIf 
		EndIf
	
	Case cAction == "EXEQP"   // "Excluir Equipe de Venda"
										
		If Aviso( STR0015, I18N( STR0024 + "#1 ?", { oTree:GetPrompt( .F. ) } ), { STR0020, STR0021 }, 2 ) == 1		// "Atenção"	   "Confirma a exclusão da Equipe de Venda: "   "Sim"    "Não"
			oTree:DelItem() 	
			For nX := 1 To Len( aNodes )
				nScan := aScan( aNodes[nX], { |x| ( x[3] == "ACA" .And. AllTrim(x[4]) == alltrim(cCodigo) ) } ) //alltrim inserido
				If nScan > 0
					aNodes[nX, nScan, 9] := 2
					cIDEstN := AllTrim(aNodes[nX, nScan, 5] )  
					nNivel  := aNodes[nX, nScan, 6]
					
					//Alteracao pontual
					aAdd(aNodesPar,{	"EXEQP", cCodigo, , , "ACA", cIDEstN, nNivel,2 })					
					
					Exit
				EndIf
			Next nX
			oTree:TreeSeek( "000-RAIZ" )
			oTree:TreeSeek( aNodes[nX, nScan, 1] + "-" + aNodes[nX, nScan, 2] )
			oTree:Refresh()		                    

			// apagando os NODES filhos
			CA240DelFi( @aNodes, "ACA", cCodigo, nNivel, @aNodesPar )
			// corrigindo o nível da estrutura após a exclusao
			CA240SNvl( @aNodes, "ACA", cCodigo, AllTrim( cIDEstN ), nNivel, 2, .T. )
			// corrigindo o status pra 1
			CA240LStts( @aNodes, 3, 1 )
			// se a arvore ficar vazia, é preciso realizar o reset
			If oTree:Total() == 1
				CA240Reset( @oTree, @aNodes, @aRecorte)
			EndIf			
		EndIf
		
	Case cAction == "INUSU"	   // "Anexar Usuario"
	
		If Len( aAllUsers ) > 0 
			cCodUsu := CA240User()
			If cCodUsu <> ""
				nScan2 := aScan( aAllUsers, { |x| ( x[4] == cCodUsu ) } )
				If nScan2 > 0
					lFound := oTree:TreeSeek("USU-" + aAllUsers[nScan2, 4] )
					cDesc := PadR( aAllUsers[nScan2, 4] + " - " + aAllUsers[nScan2, 1] , 100 )
					If lFound 
						Aviso( STR0015, I18N( STR0025 + "#1" + STR0017, { AllTrim( cDesc ) } ), { "OK" }, 2 )		// "Atenção"    "O Usuário: "      " já está na estrutura"      
					Else
						If Aviso( STR0015, I18N( STR0026 + "#1 ?", { AllTrim( cDesc ) } ), { STR0020, STR0021 }, 2 ) == 1		// "Atenção"    "Confirma a inclusão do Usuário: "   "Sim"    "Não"    
							oTree:TreeSeek( cCargo )
							oTree:AddItem( cDesc, "USU" + "-" + aAllUsers[nScan2, 4], "BMPUSER", "BMPUSER", , , 2)   
							
												// inserindo na raiz
							If AllTrim(cCargo) == "000-RAIZ"
								For nX := 1 To Len( aNodes[1] )
									If aNodes[1, nX, 9] != 2 
										cIDEstN := Soma1( AllTrim( aNodes[1, nX, 5] ) )
									EndIf
								Next nX
								aAdd( aNodes[1], {"000", "RAIZ", "USU",  aAllUsers[nScan2, 4], Iif( cIDEstN == "", "01", cIDEstN ), 1, "USU-" +  aAllUsers[nScan2, 4], cDesc, 1, aAllUsers[nScan2, 1] } )
							 
							Else
							
							// inserindo abaixo de uma entidade já cadastrada como NODE pai
							For nX := 1 To Len( aNodes )
								nScan := aScan( aNodes[nX], { |x| ( x[1] == cEntidade .And. AllTrim(x[2]) == alltrim(cCodigo) .And. x[9] != 2 ) } )
								If nScan > 0
									cIDEstN := Soma1( AllTrim( CA240RIDEN( aNodes, aNodes[nX, nScan, 1], aNodes[nX, nScan, 2] ) ) )
									aAdd( aNodes[nX], { aNodes[nX, nScan, 1], aNodes[nX, nScan, 2], "USU", aAllUsers[nScan2, 4], cIDEstN, nX, "USU-" +  aAllUsers[nScan2, 4], cDesc, 1, aAllUsers[nScan2, 1] } )

									//Alteracao pontual
									aAdd(aNodesPar,{	"INUSU", aAllUsers[nScan2, 4], aNodes[nX, nScan, 1], aNodes[nX, nScan, 2], "USU", cIDEstN, nX, 7 })
									  
									Exit
								EndIf
							Next nX
							
							// inserindo abaixo de uma entidade ainda não cadastrada como NODE pai
							If nScan == 0
								For nX := 1 To Len( aNodes )
									nScan := aScan( aNodes[nX], { |x| ( x[3] == cEntidade .And. AllTrim(x[4]) == alltrim(cCodigo) .And. x[9] != 2 ) } )
									If nScan > 0
									
										aAdd( aNodes, {} )
										cIDEstN := AllTrim( aNodes[nX, nScan, 5] ) + "01"
										aAdd( aNodes[nX + 1], { aNodes[nX, nScan, 3], aNodes[nX, nScan, 4], "USU", aAllUsers[nScan2, 4], cIDEstN, nX + 1, "USU-" +  aAllUsers[nScan2, 4], cDesc, 1, aAllUsers[nScan2, 1] } )
										
										//Alteracao pontual
										aAdd(aNodesPar,{	"INUSU", aAllUsers[nScan2, 4], aNodes[nX, nScan, 3], aNodes[nX, nScan, 4], "USU", cIDEstN, nX + 1, 7 })
										  
										Exit 
									EndIf
								Next nX
								EndIf
							EndIf
							oTree:TreeSeek( "000-RAIZ" )
							oTree:TreeSeek( "USU" + "-" + aAllUsers[nScan2, 4] )
							oTree:Refresh()		                    
						EndIf
					EndIf		
				EndIf 
			EndIf
		Else
			MsgAlert(STR0059)		// "Não existe usuários do CRM cadastrados."
		EndIf
			
	Case cAction == "EXUSU"   // "Excluir Usuário"
										
		If Aviso( STR0015, I18N( STR0027 + "#1 ?", { oTree:GetPrompt( .F. ) } ), { STR0020, STR0021 }, 2 ) == 1		// "Atenção"    "Confirma a exclusão do Usuário: "     "Sim"    "Não"
			oTree:DelItem() 	
			For nX := 1 To Len( aNodes )
				nScan := aScan( aNodes[nX], { |x| ( x[3] == "USU" .And. AllTrim(x[4]) == alltrim(cCodigo) ) } ) //alltrim inserido
				If nScan > 0
				
				
					aNodes[nX, nScan, 9] := 2
					
					cIDEstN := AllTrim(aNodes[nX, nScan, 5] )  
					nNivel  := aNodes[nX, nScan, 6]
				
					//Alteracao pontual
					aAdd(aNodesPar,{"EXUSU", cCodigo, aNodes[nX, nScan, 1], aNodes[nX, nScan, 2], "USU", cIDEstN, nNivel, 3 })
					
					Exit
				EndIf
			Next nX
			
			// posicionando no NODE pai
			oTree:TreeSeek( "000-RAIZ" )
			oTree:TreeSeek( aNodes[nX, nScan, 1] + "-" + aNodes[nX, nScan, 2] )
			oTree:Refresh()
			// apagando os NODES filhos			
			CA240DelFi( @aNodes, "USU", cCodigo, nNivel, @anodespar) //caso o usuário tenha nós filhos
			// corrigindo o nível da estrutura a partir do NODE movido
			CA240SNvl( @aNodes, "USU", cCodigo, AllTrim( cIDEstN ), nNivel, 2, .T. )
			// corrigindo o status pra 1
			CA240LStts( @aNodes, 3, 1 ) // tratamento para exclusão
			// se a arvore ficar vazia, é preciso realizar o reset
			If oTree:Total() == 1
				CA240Reset( @oTree, @aNodes, @aRecorte)
			EndIf
		EndIf
		
	Case cAction == "RECOR"	
	
		If lRecortar
			
			// Proteção caso o Array vir vazio
			If !Empty(aRecorte)
			
				// verificando se é o mesmo NODE recortado anterior
				// caso afirmativo, apenas retirar a palavra RECORTADO 
				If aRecorte[1, 3] == cEntidade .And. AllTrim(aRecorte[1, 4]) == cCodigo
					lContinua := .F.
					lRecortar := .F.
				EndIf
				
				// funcao que posiociona no NODE recortado e remove a palavra "(Recortado)"  
				CA240DelCut(oTree,aNodes,aRecorte,aNodesPar)
								
				// corrigindo o status 
				CA240LStts( @aNodes, 4, 1 )
				aRecorte := {}
			EndIf	
		Else
			lRecortar := .T.
		EndIf 
		
		If lContinua
			For nX := 1 To Len( aNodes )
				// posicionando no NODE recortado
				nScan := aScan( aNodes[nX], { |x| ( x[3] == cEntidade .And. AllTrim(x[4]) == alltrim(cCodigo) .And. x[9] != 2 ) } ) //alltrim inserido
				If nScan > 0 
					If oTree:TreeSeek( aNodes[nX, nScan, 7] )
						oTree:ChangePrompt( PADR( oTree:GetPrompt( .F. ) + STR0028, 100 ), aNodes[nX, nScan, 7] )		// " (Recortado)"
					EndIf
					aNodes[nX, nScan, 9] := 4
					aAdd( aRecorte, aNodes[nX, nScan] )
					
					//Alteracao pontual
					Do Case
						Case	cEntidade == "ADK" 
								aAdd(aNodesPar,{	"EXUDN", cCodigo, , , "ADK", aNodes[nX, nScan, 5], aNodes[nX, nScan, 6], 1 })
						Case	cEntidade == "ACA"
								aAdd(aNodesPar,{	"EXEQP", cCodigo, , , "ACA", aNodes[nX, nScan, 5], aNodes[nX, nScan, 6], 2 })
						Case	cEntidade == "USU"
								aAdd(aNodesPar,{"EXUSU", cCodigo, aNodes[nX, nScan, 1], aNodes[nX, nScan, 2], "USU", aNodes[nX, nScan, 5], aNodes[nX, nScan, 6],3 })						
					EndCase 														
					
					// verificando se é NODE pai
					If nX + 1 <= Len( aNodes ) .And. aScan( aNodes[nX + 1], { |x| ( x[1] == cEntidade .And. AllTrim(x[2]) == alltrim(cCodigo).And. x[9] == 1 ) } ) > 0 
						CA240CUT( aNodes, @aRecorte, cEntidade, cCodigo, nX, aNodesPar )
					EndIf
					Exit
				EndIf
			Next nX
		EndIf
		
	Case cAction == "COLAR"	.And. (Len(aNodes[1]) > 1 .Or. Len(aNodes) > 1)
	
		// validando as entidades
		If cEntidade == "000" .And. aRecorte[1, 3] == "ACA"
			MsgAlert( STR0029 )		// "Não é permitido mover uma Equipe de Negocio para raiz da estrutura."
		ElseIf cEntidade == "ACA" .And. aRecorte[1, 3] == "ADK"
			MsgAlert( STR0030 )		// "Não é permitido mover um Unidade de Negócio para baixo de um Equipe de Vendas."
		Else 
			// verificando se ha NODES no mesmo nível que precisam ser remanejados
			For nX := 1 To Len( aNodes )
				// posicionando no NODE recortado
				nScan := aScan( aNodes[nX], { |x| ( x[9] == 4 ) } )
				If nScan > 0
					// recuperando o ID na estrutura do próximo NODE
					cIDEstN := Soma1( AllTrim( aNodes[nX, nScan, 5] ) )
					nScan := aScan( aNodes[nX], { |x| ( AllTrim( x[5] ) == alltrim(cIDEstN) .And. x[9] == 1 ) } ) //alltrim inserido
					If nScan > 0  
						// corrigindo o nível da estrutura a partir do NODE movido
						CA240SNvl( @aNodes, aRecorte[1, 3], aRecorte[1, 4], AllTrim( aRecorte[1, 5] ), aRecorte[1, 6], 4, .T. )
						// corrigindo o status pra 1
						CA240LStts( @aNodes, 3, 1 ) 
					EndIf
				EndIf
			Next nX
			
			// retirando o NODE recortado da estrutura			
			lRecortar := .F.
			For nX := 1 To Len( aRecorte )
				If oTree:TreeSeek( aRecorte[nX, 7] ) 
					oTree:DelItem()
				EndIf
			Next nX
			oTree:Refresh() 

			// colando os NODES recortados
			For nX := 1 To Len( aRecorte )
				// inserindo o NODE recortado no estrutura na nova posicao
				oTree:TreeSeek( cCargo )
				If aRecorte[nX, 3] == "USU"
					oTree:AddItem( aRecorte[nX, 8], aRecorte[nX, 3] + "-" + aRecorte[nX, 4], "BMPUSER", "BMPUSER", , , 2)
				ElseIf aRecorte[nX, 3] == "ACA"   
					oTree:AddItem( aRecorte[nX, 8], aRecorte[nX, 3] + "-" + aRecorte[nX, 4], "BMPGROUP", "BMPGROUP", , , 2)
				Else   
					oTree:AddItem( aRecorte[nX, 8], aRecorte[nX, 3] + "-" + aRecorte[nX, 4], "ATFIMG32", "ATFIMG32", , , 2)
				EndIf
				oTree:Refresh()
				
				// posiciona no NODE que receberá o recorte  
				For nY := 1 To Len( aNodes )
					nScan := aScan( aNodes[nY], { |x| ( x[3] == cEntidade .And. AllTrim(x[4]) == alltrim(cCodigo) .And. x[9] == 1 ) } ) //alltrim inserido
					If cEntidade == "000" 
						nScan := aScan( aNodes[nY], { |x| ( x[1] == cEntidade .And. AllTrim(x[2]) == alltrim(cCodigo) .And. x[9] == 1 ) } ) //alltrim inserido
					EndIf
					If nScan > 0
						// recuperando a posicao na estrutura do NODE onde será co
						cIDEstN := AllTrim( CA240RIDEN( aNodes, cEntidade, cCodigo ) )
						If cIDEstN != ""
							// se o NODE que receberá o recorte tiver filhos, soma 1
							cIDEstN := Soma1( cIDEstN )
						Else
							// Se o NODE que receberá o recorte não tiver filhos, inicializa						
							cIDEstN := AllTrim( aNodes[nY, nScan, 5] ) + "01"
						EndIf	

						// verificando o nivel onde sera inserido o NODE recortado
						Iif ( cEntidade == "000", nNivel := 1, nNivel := aNodes[nY, nScan, 6] + 1 )
						
						// caso seja um nivel que ainda não exista, cria no ARRAY de controle  
						If nNivel > Len( aNodes )
							aAdd( aNodes, {} )
						EndIf
						
						aAdd( aNodes[nNivel], { cEntidade, cCodigo, aRecorte[nX, 3], aRecorte[nX, 4], cIDEstN, nNivel, aRecorte[nX, 7], aRecorte[nX, 8], 1, aRecorte[nX, 10] } )
						
						//Alteracao pontual
						Do Case
							Case	aRecorte[nX, 3] == "ADK" 
									aAdd(aNodesPar,{	"INUDN", aRecorte[nX, 4], cEntidade ,cCodigo , "ADK", cIDEstN, nNivel, 4 })
							Case	aRecorte[nX, 3] == "ACA"
									aAdd(aNodesPar,{	"INEQP", aRecorte[nX, 4], cEntidade ,cCodigo , "ACA", cIDEstN, nNivel, 5 })
							Case	aRecorte[nX, 3] == "USU"
									aAdd(aNodesPar,{	"INUSU", aRecorte[nX, 4], cEntidade, cCodigo , "USU", cIDEstN, nNivel, 7 })						
						EndCase 														
						
						Exit
					EndIf
				Next nY
				
				If nX == 1 .Or. ( ( nX + 1 ) <= Len( aRecorte ) .And. aRecorte[nX + 1, 6] > aRecorte[nX, 6] ) 
					cEntidade 	:= aRecorte[nX, 3]
					cCodigo	:= AllTrim( aRecorte[nX, 4] )
					cCargo		:= aRecorte[nX, 7]
				ElseIf ( nX + 1 ) <= Len( aRecorte ) .And. aRecorte[nX + 1, 6] < aRecorte[nX, 6] 
					cEntidade 	:= aRecorte[nX + 1, 1]
					cCodigo	:= AllTrim( aRecorte[nX + 1, 2] )
					cCargo		:= aRecorte[nX + 1, 1] + "-" + AllTrim( aRecorte[nX + 1, 2] )
				EndIf
	
			Next nX
		
			// corrigindo o status dos NODES movidos para 2   
			CA240LStts( @aNodes, 4, 2 ) 

			aRecorte := {}
		EndIf
		
	Case cAction == "VISUA"	
	
		If Left( cCargo, 3 ) != "USU" .And. AllTrim(cCargo) != "000-RAIZ"
			CRMXGMnDef( cEntidade, xFilial( cEntidade ) + cCodigo )
		ElseIf Left( cCargo, 3 ) == "USU"
			CA240SwUsr( cCodigo )
		EndIf

	Case cAction == "LIMPA"	
		
		CA240Reset( @oTree, @aNodes, @aRecorte)
		
EndCase

oTree:EndUpdate()

If Len( aNodes[1] ) == 0
	oBtnRepro:Hide()
Else
	oBtnRepro:Show()
EndIf

Return ( .T. ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240Reset

Funcao que reset/zera a estrutura de negocio 

@sample	CA240Reset( oTree, aNodes, aRecorte )

@param		oTree		- Objeto Tree
            aNodes		- Array de controle dos NODES da Tree
            aRecorte	- Array de controle dos NODES recortados
             
@return	Nenhum

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240Reset( oTree, aNodes, aRecorte )

oTree:Reset()
oTree:AddItem( PADR( STR0002, 100 ), PadR("000-RAIZ", 10), "FOLDER5", "FOLDER5", , , 2 )		// "Estrutura de Negócio"
oTree:Refresh()
aNodes := {}
aAdd( aNodes, {} )
aRecorte := {}

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240DelCut

Funcao que posiociona no NODE recortado e remove a palavra "(Recortado)" 

@sample	CA240DelCut( oTree, aNodes, aRecorte )

@param		oTree		- Obejeto Tree
			aNodes		- Array de controle dos NODES da Tree
			aRecorte	- Array de controle dos NODES recortados
			aNodesPar	- Array de gravacao parcial
			            
@return	Nenhum

@author 	Jonatas Martins
@since 		08/04/2015
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240DelCut(oTree,aNodes,aRecorte,aNodesPar)

Local nX 			:= 0
Local nY 			:= 0
Local nScan		:= 0
Local nScanPar	:= 0
Local nPosFim 	:= 0

// Posiciona no NODE recortado anteriormente e removendo a palavra recortado  
For nX := 1 To Len( aNodes )
	
	nScan := aScan( aNodes[nX]		, { |x| ( x[3] == aRecorte[1, 3] .And. x[4] == aRecorte[1, 4] ) } )

	If nScan > 0
		If oTree:TreeSeek( aNodes[nX, nScan, 7] )
			nPosFim :=  Rat( STR0028, oTree:GetPrompt(.F.))
				If nPosFim > 0
					oTree:ChangePrompt( PADR( SubStr( oTree:GetPrompt( .F. ), 1, nPosFim -1), 100 ), aNodes[nX, nScan, 7] ) // "(Recortado)"
				EndIf
		EndIf
	EndIf
Next nX


//Limpa campo OPERACAO do ANODESPAR caso outro item da estrutura tenha sido marcada para recortar ou tenha sido desmarcado
If	nPosFim > 0

	For nY := 1 To Len( aNodesPar )
	
		nScanPar 	:= aScan( aNodesPar	, { |x| ( x[5] == aRecorte[1, 3] .And. x[2] == aRecorte[1, 4] ) } )
		
		If	nScanPar > 0 
			aNodesPar[nY,1] := ""
		Endif 	

	Next nY
	
Endif 	 

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240LStts

Funcao que corrige o status dos NODE manipulados 

@sample	CA240LStts( aNodes, nBusca, nStatus )

@param		aNodes  - Array de controle dos NODES da Tree
			nBusca  - Nível que deve ser corrigido
            nStatus - Status a ser corrigido
             
@return	Nenhum

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240LStts( aNodes, nBusca, nStatus )

Local nX := 0

For nX := 1 To Len( aNodes )
	nScan := aScan( aNodes[nX], { |x| ( x[9] == nBusca ) } )
	While nScan > 0
		aNodes[nX, nScan, 9] := nStatus
		nScan := aScan( aNodes[nX], { |x| ( x[9] == nBusca ) } )
	End
Next Nx 

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240RIDEN

Funcao que retorna o ID do NODE pai na estrutura

@sample	CA240RIDEN( aNodes, cEntidade, cCodigo )

@param		aNodes		- Array de controle dos NODES da Tree
			cEntidade	- Alias da entidade pai
            cCodigo	- Codigo do registro da entidade pai
             
@return	ExpC1 - ID da estrutura

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240RIDEN( aNodes, cEntidade, cCodigo )

Local cIDEstN	:= ""
Local nScan	:= 0
Local nX, nY	:= 0

For nX := 1 To Len( aNodes )
	nScan := aScan( aNodes[nX], { |x| ( x[1] == cEntidade .And. AllTrim(x[2]) == alltrim(cCodigo) .And. x[9] == 1 ) } ) //alltrim inserido
	If nScan > 0
		For nY := nScan To Len( aNodes[nX] )
			If ( aNodes[nX, nY, 1] == cEntidade .And. AllTrim(aNodes[nX, nY, 2]) == cCodigo .And. aNodes[nX, nY, 9] == 1 )
				cIDEstN := AllTrim( aNodes[nX, nY, 5] )
			EndIf 						
		Next nY
	EndIf
Next nX

Return ( cIDEstN )

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240Pesq

Funcao que realiza a pesquisa por entidades no Tree

@sample	CA240Pesq( oTree )

@param		oTree - Objeto Tree
             
@return	ExpL1 - Verdadeiro ou Falso

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240Pesq( oTree )                                                       

Local aItems     := {} 
Local aSeek      := {} 

Local cChavePesq := Space( 20 )        
Local cChave     := Space( 20 )        		
Local cVar       := ""

Local nCombo     := 1 
Local nOpca      := 0 

Local oCombo          
Local oDlg   
Local oBut1 
Local oBut2 
Local oGetPesq 

aAdd( aItems, STR0032 )		// "Selecione" 
aAdd( aItems, STR0033 )		// "Unidade de Negócio" 
aAdd( aItems, STR0034 )		// "Equipe de Venda" 
aAdd( aItems, STR0035 )		// "Usuário"

aAdd( aSeek, { "", 1, "", "",	"" } )
aAdd( aSeek, { "ADK", 1, "@R XXXXXX", STR0036, "ADK" } )		// "Cód. da Unidade de Negócio"
aAdd( aSeek, { "ACA", 1, "@R XXXXXX", STR0037, "ACA" } )		// "Cód. da Equipe de Venda"	  
aAdd( aSeek, { "USU", 1, "@R XXXXXX", STR0038, "AO3" } )		// "Cód. do Usuário"  

DEFINE MSDIALOG oDlg TITLE STR0011 FROM 09,0 TO 21.2,43.5 OF oMainWnd			// "Pesquisar"

DEFINE FONT oBold NAME "Arial" SIZE 0, -13 BOLD
@ 00, 00 BITMAP oBmp RESNAME "LOGIN" oF oDlg SIZE 30, 150 NOBORDER WHEN .F. PIXEL

@ 03, 40 SAY STR0039 FONT oBold PIXEL			// "Pesquisar Entidade"  

@ 14, 30 TO 16 ,400 LABEL '' OF oDlg PIXEL

@ 23, 40 SAY STR0040 SIZE 40, 09 PIXEL			// "Entidade" 
@ 23, 80 COMBOBOX oCombo VAR cVar ITEMS aItems SIZE 80, 10 OF oDlg PIXEL 
                                                      
@ 35, 40 SAY STR0041 SIZE 40, 09 PIXEL			// "Chave" 
@ 35, 80 MSGET oGetPesq1 VAR cChave WHEN .F. SIZE 80, 10 VALID .T. PIXEL 

@ 48, 40 SAY STR0011 SIZE 40, 09 PIXEL			// "Pesquisa" 
@ 48, 80 MSGET oGetPesq VAR cChavePesq SIZE 80, 10 VALID .T. PIXEL 

oGetPesq:bGotFocus := { || oGetPesq:oGet:Picture := aSeek[ oCombo:nAt, 3 ], cChave := aSeek[ oCombo:nAt, 4 ], oGetPesq:cF3 := aSeek[ oCombo:nAt, 5 ], oGetPesq1:Refresh() }   

DEFINE SBUTTON oBut1 FROM 67,  99  TYPE 1 ACTION ( nOpca := 1, nCombo := oCombo:nAt, oDlg:End() ) ENABLE of oDlg
DEFINE SBUTTON oBut2 FROM 67, 132  TYPE 2 ACTION ( nOpca := 0, oDlg:End() ) ENABLE of oDlg

ACTIVATE MSDIALOG oDlg CENTERED  
 
If ( nOpca == 1 .And. aSeek[ nCombo, 1 ] != "" )
	cChavePesq := RTRIM( cChavePesq ) 
	If !oTree:TreeSeek( aSeek[ nCombo, 1 ] + "-" + cChavePesq ) 
		Aviso( STR0015, STR0042, { "OK" } )		// "Atenção"    "Entidade não encontrada."  
	EndIf 
EndIf 

Return ( .T. ) 

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240DelFi

Funcao que realiza a exclusão dos NODES filhos 

@sample	CA240DelFi( aNodes, cEntidade, cCodigo, nNivel )

@param		aNodes 		- Array de controle dos NODES da Tree
			cEntidade 	- Alias da entidade pai 
			cCodigo 	- Codigo do registro da entidade pai
			nNivel		- Nível da entidade na estrutura
			aNodesPar	- Array de gravacao parcial
             
@return	Nenhum

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240DelFi( aNodes, cEntidade, cCodigo, nNivel, aNodesPar )

Local nScan 	:= 0
Local nX 		:= 0   

For nX := nNivel + 1 To Len( aNodes )
	nScan := aScan( aNodes[nX], { |x| ( x[1] == cEntidade .And. AllTrim(x[2]) == alltrim(cCodigo) .And. x[9] != 2 ) } ) //alltrim inserido
	While nScan > 0
		aNodes[nX, nScan, 9] := 2
		
		If	aNodes[nX, nScan, 3] == "USU" 	
			aAdd(aNodesPar,{"EXUSU", aNodes[nX, nScan, 4], aNodes[nX, nScan, 1], aNodes[nX, nScan, 2], "USU", aNodes[nX, nScan, 5], aNodes[nX, nScan, 6],3 })
		Endif
		 
		If (nX + 1) <= Len( aNodes )
			CA240DelFi( @aNodes, aNodes[nX, nScan, 3], aNodes[nX, nScan, 4], aNodes[nX, nScan, 6], @aNodesPar )
		EndIf
		nScan := aScan( aNodes[nX], { |x| ( x[1] == cEntidade .And. AllTrim(x[2]) == alltrim(cCodigo) .And. x[9] != 2 ) } ) //alltrim inserido
	End
Next Nx

Return                                                        

//-------------------------------------------------------------------------------
/*/{Protheus.doc} CA240SNvl

Funcao que realiza a correção do nível da extrutura a partir do NODE excluido 

@sample	CA240SNvl( aNodes, cEntidade, cCodigo, cIDEstN, nNivel, nStatus, lExcluido )

@param		aNodes 		- Array de controle dos NODES da Tree
			cEntidade 	- Alias da entidade pai 
			cCodigo 	- Codigo do registro da entidade pai
			cIDEstN 	- ID da entidade na estrutura
			nNivel 		- Nível da entidade na estrutura
			nStatus 	- Status q sera tratado 2 - node deletado ou 4 - node movido
			lExcluido	- Se .T. posiciona no node excluido
             
@return	Nenhum

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------------------
Static Function CA240SNvl( aNodes, cEntidade, cCodigo, cIDEstN, nNivel, nStatus, lExcluido )

Local nScan 	:= 0
Local nX, nY	:= 0
Local cIDAux	:= ""

If lExcluido
	For nX := nNivel to Len( aNodes )
		// posicionando no NODE excluído  
		nScan := aScan( aNodes[nX], { |x| ( x[3] == cEntidade .And. AllTrim(x[4]) == alltrim(cCodigo) .And. AllTrim( x[5] ) == AllTrim( cIDEstN ) .And. x[9] == nStatus ) } )
		
		If nScan > 0
			// varrendo o array procurando mais registros excluidos (status == 2) da mesma entidade
			nY := nScan + 1
			While nY <= Len( aNodes[nX] )
				If aNodes[nX, nY, 3] == cEntidade .And. AllTrim(aNodes[nX, nY, 4]) == alltrim(cCodigo) .And. AllTrim( aNodes[nX, nY, 5] ) == AllTrim( cIDEstN ) .And. aNodes[nX, nY, 9] == 2
					nScan := nY 		
				EndIf
				nY++
			End
		EndIf

		If nScan > 0
			// varrendo os demais NODES do nivel
			For nY := nScan + 1 To Len( aNodes[nX] )
				// verificando o NODE pai
				If aNodes[nX, nScan, 1]	== aNodes[nX, nY, 1] .And. aNodes[nX, nScan, 2] == aNodes[nX, nY, 2] .And. aNodes[nX, nY, 9] == 1  
					cIDAux := AllTrim( aNodes[nX, nScan, 5] ) 
					aNodes[nX, nY, 5] := cIDAux  
					aNodes[nX, nY, 9] := 3  
					If nX + 1 <= Len( aNodes ) .And. aScan( aNodes[nX + 1], { |x| ( x[1] == aNodes[nX, nY, 3] .And. x[2] == aNodes[nX, nY, 4] .And. x[9] == 1 ) } ) > 0
						CA240SNvl( @aNodes, aNodes[nX, nY, 3], aNodes[nX, nY, 4], AllTrim( aNodes[nX, nY, 5] ), aNodes[nX, nY, 6], 1, .F. )
					EndIf
					cIDEstN := cIDAux
				EndIf
			Next nY
		EndIf 
	Next nX
Else	 
	For nX := nNivel To Len( aNodes )
		nScan := aScan( aNodes[nX], { |x| ( x[1] == cEntidade .And. AllTrim(x[2]) == alltrim(cCodigo) .And. x[9] == nStatus ) } ) //alltrim inserido
		While nScan > 0 
			aNodes[nX, nScan, 5] := cIDEstN + SubStr( aNodes[nX, nScan, 5], (2 * nNivel) + 1, Len( aNodes[nX, nScan, 5] ) ) 
			aNodes[nX, nScan, 9] := 3  
			If (nX + 1) <= Len( aNodes )
				CA240SNvl( @aNodes, aNodes[nX, nScan, 3], aNodes[nX, nScan, 4], AllTrim(aNodes[nX, nScan, 5] ), aNodes[nX, nScan, 6], 1, .F. )
			EndIf
			nScan := aScan( aNodes[nX], { |x| ( x[1] == cEntidade .And. AllTrim(x[2]) == alltrim(cCodigo) .And. x[9] == nStatus  ) } )
		End
	Next Nx
EndIf

Return                                                        

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240Grava

Funcao que realiza a grava da estrutura no banco de dados 

@sample	CA240Grava( ExpA1 )

@param		aNodes 		- Array de controle dos NODES da Tree
			aNodesPar	- Array de gravacao parcial
             
@return	ExpL1 - Tree processada Sim ( .T. ) ou Não ( .F. ) 

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240Grava( aNodesBkp, aNodes, aNodesPar )

Local aArea			:= GetArea()
Local aAreaACA  	:= ACA->(GetArea())
Local aAreaAO3  	:= AO3->(GetArea())
Local aAreaAO4  	:= AO4->(GetArea())
Local aAreaAO5  	:= AO5->(GetArea())
Local aAreaSA3  	:= SA3->(GetArea())
Local nX			:= 0
Local nScan			:= 0
Local cQuery		:= ""
Local aEntidad		:= StrTokArr(CRMXCtrlEnt(),"|") // Entidades controlada pelo controle de acesso.
Local nY			:= 0
Local aCpoFiltro	:= {}
Local cPrxCpo		:= ""
Local nRetSQL		:= 0
Local lRetorno   	:= .T.
Local cConcat		:= ""
Local cCpoFilial	:= ""
Local cCpoIdEstN	:= ""
Local cCpoNvEstN	:= ""
Local lBfrGrv		:= ExistBlock("CRM240BGRV")
Local lAftrGrv		:= ExistBlock("CRM240AGRV")
Local nFormAtu	    := 1

Private lMsErroAuto := .F.

// se houve mudança na estrutura, grava
If lChange

	lRetorno := CA240VldId( aNodes )

	If !lRetorno
		Help(,,"CR240VLDID",, STR0107, 1, 0 ) //"Existem mais níveis do que o suportado, faça manutenção no grupo de campos 075 (Id. Acesso Estrutura de Neg.) para aumentar a quantidade de níveis suportados."
	EndIf

	//Ponto de entrada antes da gravação.
	If lRetorno .And. lBfrGrv
		ExecBlock("CRM240BGRV",.F.,.F.,{aNodesBkp, aNodes, aNodesPar})	
	EndIf
	
	If lRetorno .And. Len(aNodes) > 1
		nFormAtu := CA240TpPro()
	Endif 		
	
	If lRetorno .And. nFormAtu <> 0
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Define o simbolo de concatenacao de acordo com o banco³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"
			cConcat := "||"
		Else
			cConcat := "+"
		Endif
	
		Begin Transaction
	
		If	nFormAtu == 1
		
			//Apagando ESTRUTURA DE NEGOCIO
			TcSqlExec( "DELETE FROM " + RetSqlName("AO5") + " WHERE AO5_FILIAL = '" + xFilial("AO5")+ "'" )
		
			// limpando os dados dos usuários referente a estrutura de negocio
			TcSqlExec("UPDATE " + RetSqlName("AO3") + " SET AO3_CODUND = '', AO3_CODEQP = '', AO3_IDESTN = '', AO3_NVESTN = 0 WHERE AO3_FILIAL = '" + xFilial("AO3")+ "'" )
			
			// limpando os dados dos vendedores referente a estrutura de negocio
			TcSqlExec("UPDATE " + RetSqlName("SA3") + " SET A3_UNIDAD = '' WHERE A3_FILIAL = '" + xFilial("SA3")+ "'" )
			
			// zerando as equipes superiores para posterior preenchimento	
			TcSqlExec("UPDATE " + RetSqlName("ACA") + " SET ACA_GRPSUP = '' WHERE ACA_FILIAL = '" + xFilial("ACA")+ "'" )
			
			// Limpa os privilegios para posterior preenchimento	
			TcSqlExec("UPDATE " + RetSqlName("AO4") + " SET AO4_IDESTN = ' ' , AO4_NVESTN = 0 WHERE AO4_FILIAL = '" + xFilial("AO4")+ "'" )
		Endif 
	
		For nY := 1 To Len(aEntidad)
		
			aCpoFiltro	:= CRMXCpoFil(aEntidad[nY])
		
			// Processa as entidades que possui nivel da estrutura como cache.
			If Len(aCpoFiltro) == 4
				
				cPrxCpo := IIF(Subs(aEntidad[nY],1,1)=="S",SubStr(aEntidad[nY],2,3),aEntidad[nY])
				cCpoFilial	:= cPrxCpo+aCpoFiltro[1]
				cCpoIdEstN	:= cPrxCpo+aCpoFiltro[3]
				cCpoNvEstN	:= cPrxCpo+aCpoFiltro[4]
				
				cQuery := " UPDATE "+RetSqlName(aEntidad[nY])+" SET "+cCpoIdEstN+" = '', "+cCpoNvEstN+" = 0 "
				cQuery += " WHERE "+cCpoFilial+" = '"+xFilial(aEntidad[nY])+"' AND D_E_L_E_T_ = '' "
				
				// Sincroniza as oportunidades em aberto e suspensa.
				If aEntidad[nY] == "AD1"
					cQuery += " AND AD1_STATUS IN ('1','3') "
				EndIf
				
				cQuery += " AND D_E_L_E_T_ = ' ' "
				
				nRetSQL := TCSqlExec(cQuery)
				
				//Aborta a sincronizacao das entidades no segundo laco FOR.
				If nRetSQL < 0
					lRetorno := .F.
					Exit
				EndIf
				
			EndIf
		
		Next nY
		
		cCdsUnNeg := ""
		cCdsEqVen := ""
		cCdsUsurs := ""
		
		If lRetorno .AND. nFormAtu == 2
		
			CA240Parcial(aNodesPar,aNodes)
						
		Endif

		If lRetorno .AND. nFormAtu == 1
		
			// ordenando o array
			aNodes := CA240Ordena( aNodes )
			CA240LStts(@aNodes,7,1 )
			
			DbSelectArea("AO5")	// Estrutura de Venda
			AO5->(DbSetOrder(1)) // AO5_FILIAL+AO5_ENTPAI+AO5_CODPAI+AO5_ENTANE+AO5_CODANE    
			
			DbSelectArea("ACA") 	// Equipe de Venda
			ACA->(DbSetOrder(1))	// ACA_FILIAL+ACA_GRPREP
			
			DbSelectArea("AO4")	// Controle de Privilégios
			AO4->(DbSetOrder(2))	// AO4_FILIAL+AO4_CODUSR+AO4_ENTIDA+AO4_CHVREG
			
			DbSelectArea("AO3")	// Usuarios do CRM
			AO3->(DbSetOrder(1))	// AO3_FILIAL+AO3_CODUSR
								
			DbSelectArea("SA3")	// Vendedores
			SA3->(DbSetOrder(7))	// A3_FILIAL+A3_CODUSR
						
			// inserindo as linhas do Array
			For nX := 1 To Len(aNodes)
				
				nScan := aScan(aNodes[nX],{|x| x[9] == 1 })
				
				If nScan > 0
					
					While nScan <= Len(aNodes[nX])
						
						// inserir apenas os NODES com status igual a 1
						If ( aNodes[nX,nScan,9] == 1 )
							
							// inserindo os NODES
							RecLock( "AO5", .T. )
							AO5->AO5_FILIAL := xFilial("AO5")
							AO5->AO5_ENTPAI := aNodes[nX,nScan,1]
							AO5->AO5_CODPAI := aNodes[nX,nScan,2]
							AO5->AO5_ENTANE := aNodes[nX,nScan,3]
							AO5->AO5_CODANE := aNodes[nX,nScan,4]
							AO5->AO5_IDESTN := aNodes[nX,nScan,5]
							AO5->AO5_NVESTN := aNodes[nX,nScan,6]
							AO5->(MsUnlock())
							
							//Gravação (atualizacao do ID e nivel)
							CA240CpGrv(aNodes[nX,nScan,1], aNodes[nX,nScan,2], aNodes[nX,nScan,3], aNodes[nX,nScan,4], aNodes[nX,nScan,5], aNodes[nX,nScan,6], aNodes, aNodesPar,nX, cConcat )
							
					
							//Aborta processamento da estrutura no primeiro laco While
							If !lRetorno
								Exit
							EndIf
						
						ENDIF
						nScan++
						
						
				
						//Aborta processamento da estrutura no primeiro laco FOR
						If !lRetorno
							Exit
						EndIf
				
					End DO
				EndIf
			
			Next nX
		
			If lRetorno
			// se estrutura foi zerada, desabilitar o filtro do CRM senão habilitar
				If Len(aNodes) == 1
					PutMv("MV_CRMESTN",.F.)
				Else
					PutMv("MV_CRMESTN",.T.)
				EndIf
			EndIf 
	
		EndIf
	
		If !lRetorno
			DisarmTransaction()
		EndIf
		
		End Transaction
	
		If lRetorno .AND. lAftrGrv
			ExecBlock("CRM240AGRV",.F.,.F.,{aNodesBkp, aNodes, aNodesPar})
		EndIf 

	EndIf
	
EndIf 	

RestArea(aAreaSA3)
RestArea(aAreaAO5)
RestArea(aAreaAO4)
RestArea(aAreaAO3)
RestArea(aAreaACA)
RestArea(aArea)

Return(lRetorno)

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240RUnid

Funcao que retorna a Unidade de Negócio de uma Equipe de Venda

@sample	CA240RUnid( aNodes, cEntidade, cCodigo, nNivel )

@param		aNodes 		- Array de controle dos NODES da Tree
			cEntidade 	- Alias da entidade pai 
            cCodigo 	- Codigo da equipe de negócio
            nNivel		- Nível da equipe da estrutura
             
@return	ExpC1 - Codigo da Unidade de Negocio 

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240RUnid( aNodes, cEntidade, cCodigo, nNivel )

Local cUnidade:= ""
Local nScan	:= 0
Local nX		:= 0

// verificando se o NODE pai é uma Unidade de Negocio
For nX := nNivel To Len( aNodes )
	nScan := aScan( aNodes[nX], { |x| ( x[3] == cEntidade .And. AllTrim(x[4]) == alltrim(cCodigo) .And. x[9] == 1 ) } ) //alltrim inserido para o ascan funcionar no momento da inclusão.
	If nScan > 0 .And. aNodes[nX, nScan, 1] == "ADK"
		cUnidade := aNodes[nX, nScan, 2]
		Exit
	ElseIf nScan > 0 .And. aNodes[nX, nScan, 1] != "ADK"
		If (aNodes[nX, nScan, 6] - 1) <> 0 //Verifica se chegou ao último nível da estrutura
			cUnidade := CA240RUnid( aNodes, aNodes[nX, nScan, 1], aNodes[nX, nScan, 2], aNodes[nX, nScan, 6] - 1)
		EndIf
	EndIf
Next nX

Return ( cUnidade )

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240CUT

Funcao que retorna o "pedaço" da estrutura recortada 

@sample	CA240CUT( aNodes, aRecorte, cEntidade, cCodigo, nNivel )

@param		aNodes 		- Array de controle dos NODES da Tree
			aRecorte 	- Array de controle dos NODES recortados
			cEntidade	- Alias da entidade pai 
			cCodigo 	- Codigo do registro da entidade pai
			nNivel 		- Nível da entidade na estrutura
			aNodesPar	- Array de gravacao parcial
             
@return	ExpL1 - "pedaço" recortado da estrutura

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240CUT( aNodes, aRecorte, cEntidade, cCodigo, nNivel, aNodesPar )

Local nScan 	  := 0
Local nX, nY	  := 0

For nX := nNivel + 1 To Len( aNodes )
	nY++
	nScan := aScan( aNodes[nX], { |x| ( x[1] == cEntidade .And. AllTrim(x[2]) == alltrim(cCodigo) .And. x[9] != 2 ) } ) //alltrim inserido para ascan funcionar
	While nScan > 0
		
		aAdd( aRecorte, aNodes[nX, nScan] )
		
		Do Case
			Case	cEntidade == "ADK" 
				aAdd(aNodesPar,{	"EXUDN", cCodigo, , , "ADK", aNodes[nX, nScan, 5], aNodes[nX, nScan, 6], 1 })
			Case	cEntidade == "ACA"
				aAdd(aNodesPar,{	"EXEQP", cCodigo, , , "ACA", aNodes[nX, nScan, 5], aNodes[nX, nScan, 6], 2 })
			Case	cEntidade == "USU"
				aAdd(aNodesPar,{"EXUSU", cCodigo, aNodes[nX, nScan, 1], aNodes[nX, nScan, 2], "USU", aNodes[nX, nScan, 5], aNodes[nX, nScan, 6],3 })						
		EndCase 														
		
		aNodes[nX, nScan, 9] := 4 
		If (nX + 1) <= Len( aNodes )
			CA240CUT( @aNodes, @aRecorte, aNodes[nX, nScan, 3], aNodes[nX, nScan, 4], aNodes[nX, nScan, 6], aNodesPar )
		EndIf
		nScan := aScan( aNodes[nX], { |x| ( x[1] == cEntidade .And. AllTrim(x[2]) == alltrim(cCodigo) .And. ( x[9] != 2 .And. x[9] != 4 ) ) } ) //alltrim inserido para ascan funcionar
	End
Next Nx

Return ( .T. )                                                        

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240User

Funcao para visualização/seleção dos usuários dos sistema 

@sample	CA240User()

@param		Nenhum
             
@return	ExpC1 - Retorna o codigo do usuário  

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240User()

Local nOpcA		:= 0  			// Avalia o botao utilizado
Local nUser		:= 1  			// Variavel para o List
Local oDlg			:= Nil 		// Dialog Principal
Local oUsers		:= Nil 		// Objeto List
Local cNome		:= "" 			// Nome completo selecionado
Local cNReduz		:= "" 			// Nome reduzido
Local cCodUsu		:= ""
Local oSearch		:= Nil			// Objeto TGet com o texto da procura
Local cSearch		:= Space(60)	// Texto da procura
Local oBtnLoc		:= Nil			// Botão para localizar
Local oBtnPro		:= Nil			// Botão para localizar o próximo
Local oPanelInf	:= Nil			// Painel inferior com os botoes
Local oPanelRest	:= Nil	    	// Paines superior com o listbox

DEFINE MSDIALOG oDlg TITLE STR0043 FROM 00,00 TO 250,717 PIXEL OF oMainWnd      // "Lista de Usuários" 
	
oPanelInf		  := TPanel():New(0, 0, "", oDlg, , , , , , 0, 15)
oPanelInf:Align := CONTROL_ALIGN_BOTTOM
	
oPanelRest		   := TPanel():New(0, 0, "", oDlg, , , , , , 0, 0)
oPanelRest:Align := CONTROL_ALIGN_ALLCLIENT

@05,04 LISTBOX oUsers FIELDS HEADER ;  	
				STR0044,;		// "Nome Completo"	
				STR0045,;		// "Cargo"	 
				STR0046,;		// "Departamento"   
				STR0047;		// "Código"       
		   		COLSIZES 80,65,65,6;
				ON DbLCLICK (	nOpcA 		:= 1,;
								cNome		:= aAllUsers[oUsers:nAt,1],;
								cNReduz	:= aAllUsers[oUsers:nAt,5],;
								cCodUsu	:= aAllUsers[oUsers:nAt,4],;
								oDlg:End()  );
				ON CHANGE (nUser := oUsers:nAt) SIZE 0,0 OF oPanelRest PIXEL NOSCROLL					

oUsers:Align := CONTROL_ALIGN_ALLCLIENT
oUsers:SetArray(aAllUsers)
oUsers:bLine := { || {	aAllUsers[oUsers:nAt,1],;	// Nome 	
							aAllUsers[oUsers:nAt,2],;	// Cargo
							aAllUsers[oUsers:nAt,3],;	// Departamento
							aAllUsers[oUsers:nAt,4]}}	// Codigo do Usuario
						
oUsers:Refresh()

DEFINE SBUTTON FROM 03,295 TYPE 1 ENABLE OF oPanelInf ACTION (	nOpcA	:= 1, cNome := aAllUsers[oUsers:nAt,1], cNReduz := aAllUsers[oUsers:nAt,5], cCodUsu	:= aAllUsers[oUsers:nAt,4], oDlg:End() )
DEFINE SBUTTON FROM 03,327 TYPE 2 ENABLE OF oPanelInf ACTION oDlg:End()
	
@ 004,005 SAY STR0048 SIZE 22,10 OF oPanelInf PIXEL		// "Procurar"	

@ 003,028 MSGET oSearch VAR cSearch SIZE 50,8	OF oPanelInf PIXEL COLOR CLR_BLACK

@ 003,080 BUTTON oBtnLoc PROMPT STR0049 SIZE 30,10 OF oPanelInf PIXEL ACTION MsgRun( STR0050, "", { || If ( CA240LcUsr( oUsers, cSearch, .T. ), oSearch:SetColor( CLR_BLACK, CLR_WHITE ), oSearch:SetColor( CLR_WHITE, CLR_HRED ) ) } )     // "Localizar"    // "Localizando"	
@ 003,112 BUTTON oBtnPro PROMPT STR0051 SIZE 30,10 OF oPanelInf PIXEL ACTION MsgRun( STR0050, "", { || If ( CA240LcUsr( oUsers, cSearch, .F. ), oSearch:SetColor( CLR_BLACK, CLR_WHITE ), oSearch:SetColor( CLR_WHITE, CLR_HRED ) ) } )     // "Próximo"      // "Localizando" 	

ACTIVATE MSDIALOG oDlg CENTERED

Return ( cCodUsu )

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240LcUsr

Funcao para localizar um usuário na lista de usuários 

@sample	CA240LcUsr( oList, cString, lInicio )

@param		oList	 - Objeto lista de usuários
			cString - Texto a ser localizado
			lInicio - Parte do inicio Sim (.T.) ou Não (.F.)
             
@return	ExpL1 - Encontrou Sim (.T.) ou Não (.F.) 

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240LcUsr( oList, cString, lInicio )

Static nStartLine		// Controle de próxima procura
Static nStartCol		// Coluna inicial

Local nCount 	:= 0	// Contador temporário
Local nCount2	:= 0	// Contador temporário
Local lAchou	:= .F.	// Se encontrou a informação desejada

// Inicializa a variável da linha inicial de procura
If ValType(nStartLine) <> "N"
	nStartLine := 1
EndIf
	
// Inicializa a variável da coluna inicial de procura.
If ValType(nStartCol) <> "N"
	nStartCol := 1
EndIf	
	
// Se é para procurar desde o início.
If lInicio
	nStartLine	:= 1
	nStartCol	:= 1	
EndIf

// Procura em todas as linhas e colunas pelo conteúdo solicitado.
For nCount := nStartLine To Len( oList:aArray )		
	For nCount2 := nStartCol To Len( oList:aArray[nCount] ) - 1
		If ValType( oList:aArray[nCount][nCount2] ) == "C"
			If Upper( AllTrim( cString ) ) $ Upper( AllTrim( oList:aArray[nCount][nCount2] ) )					
				oList:nAt := nCount
				oList:Refresh()
				nStartLine	:= nCount
				nStartCol	:= nCount2 + 1
				lAchou := .T.
				Exit
			EndIf
		EndIf
	Next
	
	// Se já encontrou um resultado, saia
	If lAchou
		Exit
	Else
		nStartCol := 1
	EndIf		
Next

Return lAchou

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240SwUsr

Funcao para visualizar as informações de um usuário  

@sample	CA240SwUsr( cCodUsu )

@param		cCodUsu - Código do Usuário 
             
@return	Nenhum 

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240SwUsr( cCodUsu )

Local oDlg			:= Nil 		// Dialog Principal
Local aDados 		:= {}
Local oPanelInf	:= Nil			// Painel inferior com os botoes

PswOrder(1)
If PswSeek( cCodUsu, .T. )
	aDados := PSWRET() // Retorna vetor com informações do usuário
EndIf

// montando a tela de visualização do usuário 
DEFINE MSDIALOG oDlg TITLE STR0052 FROM 00,00 TO 240,517 PIXEL OF oMainWnd 

oPanelInf		  := TPanel():New(0, 0, "", oDlg, , , , , , 0, 15)
oPanelInf:Align := CONTROL_ALIGN_BOTTOM
	
@ 005, 003 SAY STR0053 SIZE 045, 007 OF oDlg  PIXEL		// "Código:"
@ 005, 040 MSGET aDados[1, 1] SIZE 027, 007 OF oDlg PIXEL READONLY

@ 020, 003 SAY STR0054 SIZE 045, 007 OF oDlg  PIXEL		// "Usuário:"
@ 020, 040 MSGET aDados[1, 2] SIZE 047, 007 OF oDlg PIXEL READONLY

@ 035, 003 SAY STR0055 SIZE 045, 007 OF oDlg  PIXEL		// "Nome:"
@ 035, 040 MSGET aDados[1, 4] SIZE 147, 007 OF oDlg PIXEL READONLY

@ 050, 003 SAY STR0056 SIZE 045, 007 OF oDlg  PIXEL		// "Departamento:"
@ 050, 040 MSGET aDados[1, 12] SIZE 087, 007 OF oDlg PIXEL READONLY

@ 065, 003 SAY STR0057 SIZE 045, 007 OF oDlg  PIXEL		// "Cargo:"
@ 065, 040 MSGET aDados[1, 13] SIZE 087, 007 OF oDlg PIXEL READONLY

@ 080, 003 SAY STR0058 SIZE 045, 007 OF oDlg  PIXEL		// "E-mail:"
@ 080, 040 MSGET aDados[1, 14] SIZE 147, 007 OF oDlg PIXEL READONLY

DEFINE SBUTTON FROM 003, 227 TYPE 1 ENABLE OF oPanelInf ACTION ( .T., oDlg:End() )

ACTIVATE MSDIALOG oDlg CENTERED	

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240Ordena

Funcao para ordenar o array de nodes  

@sample	CA240Ordena( aNodes )

@param		aNodes - Array de controle dos NODES da Tree 
             
@return	ExpA - array ordenado 

@author 	Thiago Tavares
@since 		04/06/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240Ordena( aNodes )

Local nX        := 0
Local nY        := 0
Local aNodesAux := {}
Local cRaiz     := ""
Local cCount    := ""
Local nScan     := 0
Local nScanUSU  := 0
Local nScanACA  := 0
Local nScanADK  := 0
Local cCodPAI   := ""
Local cEntPAI   := ""

// correndo os níveis
For nX := 1 To Len( aNodes )

	aAdd( aNodesAux, {} )
	If nX == 1 
		For nY := 1 To Len( aNodes[nX] )
			aAdd( aNodesAux[nX], aNodes[nX, nY] ) 		
		Next nY    
	Else
		If Len( aNodes[nX] ) > 0
			nScan := 1
			While nScan > 0
				nY := nScan
				cCount := "00"
				cEntPAI := aNodes[nX, nY, 1]
				cCodPAI := aNodes[nX, nY, 2]
				While nY <= Len( aNodes[nX] ) .And. aScan( aNodes[nX], { |x| ( x[9] == 1 ) } ) > 0
					If cEntPAI == aNodes[nX, nY, 1] .And. cCodPAI == aNodes[nX, nY, 2]
		
						// ordenando os usuarios
						nScanUSU := aScan( aNodes[nX], { |x| (x[1] == cEntPAI .And. x[2] == cCodPAI .And. x[3] == "USU" .And. x[9] == 1 ) } )
						While nScanUSU > 0
							cRaiz := Left( aNodes[nX, nScanUSU, 5], Len( AllTrim( aNodes[nX, nScanUSU, 5] ) ) - 2 )
							cCount := Soma1( cCount )
							aNodes[nX, nScanUSU, 5] := cRaiz + cCount
							aAdd( aNodesAux[nX], aNodes[nX, nScanUSU] )  
							aNodes[nX, nScanUSU, 9] := 7 
							nScanUSU := aScan( aNodes[nX], { |x| (x[1] == cEntPAI .And. x[2] == cCodPAI .And. x[3] == "USU" .And. x[9] == 1 ) } )
						End				
							 
						// ordenando as equipes
						nScanACA := aScan( aNodes[nX], { |x| (x[1] == cEntPAI .And. x[2] == cCodPAI .And. x[3] == "ACA" .And. x[9] == 1 ) } )
						While nScanACA > 0 
							cRaiz := Left( aNodes[nX, nScanACA, 5], Len( AllTrim( aNodes[nX, nScanACA, 5] ) ) - 2 )
							cCount := Soma1( cCount )
							aNodes[nX, nScanACA, 5] := cRaiz + cCount
							aAdd( aNodesAux[nX], aNodes[nX, nScanACA] )  
							aNodes[nX, nScanACA, 9] := 7 
							If ( nX + 1 ) <= Len( aNodes )
								aNodes := CA240Amarra( aNodes, nX + 1, aNodes[nX, nScanACA, 5], aNodes[nX, nScanACA, 3], aNodes[nX, nScanACA, 4] )
								CA240LStts( @aNodes, 8, 1 )
							EndIf			
							nScanACA := aScan( aNodes[nX], { |x| (x[1] == cEntPAI .And. x[2] == cCodPAI .And. x[3] == "ACA" .And. x[9] == 1 ) } )
						End  
						
						// ordenando as unidades
						nScanADK := aScan( aNodes[nX], { |x| (x[1] == cEntPAI .And. x[2] == cCodPAI .And. x[3] == "ADK" .And. x[9] == 1 ) } )
						While nScanADK > 0 
							cRaiz := Left( aNodes[nX, nScanADK, 5], Len( AllTrim( aNodes[nX, nScanADK, 5] ) ) - 2 )
							cCount := Soma1( cCount )
							aNodes[nX, nScanADK, 5] := cRaiz + cCount
							aAdd( aNodesAux[nX], aNodes[nX, nScanADK] )  
							aNodes[nX, nScanADK, 9] := 7 
							If ( nX + 1 ) <= Len( aNodes )
								aNodes := CA240Amarra( aNodes, nX + 1, aNodes[nX, nScanADK, 5], aNodes[nX, nScanADK, 3], aNodes[nX, nScanADK, 4] )
								CA240LStts( @aNodes, 8, 1 )
							EndIf			
							nScanADK := aScan( aNodes[nX], { |x| (x[1] == cEntPAI .And. x[2] == cCodPAI .And. x[3] == "ADK" .And. x[9] == 1 ) } )
						End
						
					EndIf
					nY++
				End	
				nScan := aScan( aNodes[nX], { |x| (x[9] == 1 ) } )
			End
		EndIf
	EndIf

Next nX 

Return ( aNodesAux )

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240Amarra

Funcao para atualizar os nodes filhos do node ordenado  

@sample	CA240Amarra( aNodes, nNvEstN, cIDEstN, cEntida, cCodigo )

@param		aNodes - Array de controle dos NODES da Tree
			nNVEstN - Nível inicial da estrutura
			cIDEstN - Novo ID da raiz    
			cEntida - Entidade que tera os nodes filhos atualizados
			cCodigo - Código da entidade que tera os nodes filhos atualizados
             
@return	ExpA - Array atualizado 

@author 	Thiago Tavares
@since 		11/02/2014
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240Amarra( aNodes, nNvEstN, cIDEstN, cEntida, cCodigo )

Local nX	     := 0
Local nScan		 := 0
Local cCount	 := ""
Local nTamIdEstN := GetSX3Cache("AO4_IDESTN","X3_TAMANHO")

cCount := "00"
For nX := nNvEstN To Len( aNodes )
	nScan := aScan( aNodes[nX], { |x| (x[1] == cEntida .And. AllTrim(x[2]) == alltrim(cCodigo) .And. x[9] == 1 ) } ) //alltrim inserido
	While nScan > 0
		cCount := Soma1( cCount )
		aNodes[nX, nScan, 5] := PadR( AllTrim( cIDEstN ) + cCount, nTamIdEstN )
		aNodes[nX, nScan, 9] := 8
		If aNodes[nX, nScan, 3] <> "USU"
			aNodes := CA240Amarra( aNodes, nX + 1, aNodes[nX, nScan, 5], aNodes[nX, nScan, 3], aNodes[nX, nScan, 4] )
		EndIf	
		nScan := aScan( aNodes[nX], { |x| (x[1] == cEntida .And. AllTrim(x[2]) == alltrim(cCodigo) .And. x[9] == 1 ) } ) //alltrim inserido
	End	
Next nX

Return ( aNodes )	 

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240TpPro

Interface para selecionar o tipo de gravacao da estrutura de negocios   

@sample	CA240TpPro()

@param		Nenhum
             
@return	ExpN - 1=Gravacao completa / 2=Gravacao parcial / 3=Cancelar gravacao 

@author 	Eduardo Gomes Junior
@since 		30/07/2015
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240TpPro()

Local oDlg      	:= Nil
Local oPanel	  	:= Nil
Local oSay			:= Nil
Local nFormAtu	:= 1
Local cAliasTmp 	:= GetNextAlias() 

BeginSql Alias cAliasTmp
	SELECT COUNT(*) NTOTAO5 FROM %Table:AO5% AO5 WHERE AO5.AO5_FILIAL = %xFilial:AO5% AND AO5.%NotDel%
EndSql

If	NTOTAO5 > 0

	oDlg := FwDialogModal():New()
		oDlg:SetBackGround( .T. )
		oDlg:SetTitle( STR0072 )	//"Atualização"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
		oDlg:SetEscClose( .T. )
		oDlg:SetSize( 100, 150 )
		oDlg:EnableFormBar( .T. )
	
		oDlg:CreateDialog()		

		oPanel := oDlg:GetPanelMain()
	
		oDlg:CreateFormBar()
	
		oSay := TSay():New( 10, 10, { || STR0074 }, oPanel,,,,,,.T. )	//"Parcial -> considera apenas as últimas alterações"
		oSay := TSay():New( 30, 10, { || STR0073 }, oPanel,,,,,,.T. )	//"Completa -> toda a estrutura de negócio é atualizada"		  
	
		oDlg:AddButton( STR0075	,{|| nFormAtu := 1 , oDlg:Deactivate() }, STR0075, , .T., .F., .T., )	//Completa
		oDlg:AddButton( STR0076	,{|| nFormAtu := 2 , oDlg:Deactivate() }, STR0076, , .T., .F., .T., )	//Parcial
		oDlg:AddButton( STR0077	,{|| nFormAtu := 0 , oDlg:Deactivate() }, STR0077, , .T., .F., .T., )	//Cancelar 
			
		oDlg:Activate()
		
Endif 		

Return(nFormAtu)

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240Parcial

Realiza a gravacao na estrutura de negocios (gravacao parcial, somente itens que sofreram alguma alteracao)  

@sample	CA240Parcial(aNodesPar,aNodes)

@param		ExpA1 - Array contendo as alteracoes parciais (alteracoes pontuais) realizadas na estrutura de negocio
			ExpA2 - Array completo da estrutura de negocio 
             
@return	Nenhum 

@author 	Eduardo Gomes Junior 
@since 		05/08/2015
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240Parcial(aNodesPar,aNodes)

Local nY 			:= 0
Local nX 			:= 0
Local nW 			:= 0
Local nI			:= 0

Local cSqlAO3		:= ""
Local cSqlAO5a	:= ""
Local cSqlAO5b	:= ""
Local cSqlAO4	:= ""

Local nScan_ADK 	:= 0
Local nScan_ACA 	:= 0
Local nScan_USU 	:= 0

Local cIDPosi		:= ""
Local nNVPosi		:= 0

/*
--------------------------------------
************* Operacoes **************
--------------------------------------
INUDN -> "Anexar Unid. de Negócio"       
INEQP -> "Anexar Equipe de Venda" 	      
INUSU -> "Anexar Usuário"      
--------------------------------------
EXUDN -> "Excluir Unid. de Negócio"   
EXEQP -> "Excluir Equipe de Venda"       
EXUSU -> "Excluir Usuário"      
--------------------------------------
RECOR -> "Recortar"    
COLAR -> "Colar"
--------------------------------------
======================================
--------------------------------------
************* aNodesPar **************
--------------------------------------

01 - OPERACAO (VER TABELA ACIMA)
02 - CODANE
03 - ENTPAI
04 - CODPAI
05 - ENTANE
06 - IDESTN
07 - NVESTN
08 - SEQUENCIA PARA EXECUCAO 

--------------------------------------
************** aNodes ****************
--------------------------------------
01 - ENTPAI
02 - CODPAI
03 - ENTANE
04 - CODANE
05 - IDESTN
06 - NVESTN
07 - CARGO TREE
08 - DESC TREE
09 - STATUS	(1=Considera, 2=Nao considera, 3=Nivel alterado, 4=Recortado)
10 - DESCRICAO ENTIDADE 
--------------------------------------
*/

aNodesPar := aSort(aNodesPar, , , { |x, y| x[8] < y[8] } ) 

//Ordenando o array / Atualizando ID e nivel
aNodes := CA240Ordena( aNodes )
CA240LStts(@aNodes,7,1 )

For nY := 1 To Len(aNodesPar)

	//Realiza exclusao de unidades, equipes e usuarios da estrutura de negocio
	If	aNodesPar[nY,1] $ "EXUDN|EXEQP|EXUSU"

		//Unidade de Negocio	
		If	aNodesPar[nY,1] == "EXUDN"
			cSqlAO3	:= "UPDATE " + RetSqlName("AO3") + " SET AO3_CODUND = '', AO3_CODEQP = '', AO3_IDESTN = '', AO3_NVESTN = 0 WHERE AO3_FILIAL = '" + xFilial("AO3")+ "' AND AO3_CODUND = '"+ aNodesPar[nY,2]+"'"
			cSqlAO5a	:= "DELETE FROM " + RetSqlName("AO5") + " WHERE AO5_FILIAL = '" + xFilial("AO5")+ "' AND AO5_ENTANE = 'ADK' AND AO5_CODANE = '"+aNodesPar[nY,2]+"'" 
			cSqlAO5b	:= "DELETE FROM " + RetSqlName("AO5") + " WHERE AO5_FILIAL = '" + xFilial("AO5")+ "' AND AO5_ENTPAI = 'ADK' AND AO5_CODPAI = '"+aNodesPar[nY,2]+"'"
		Endif 

		//Equipe de Venda 
		If	aNodesPar[nY,1] == "EXEQP"
			cSqlAO3	:= "UPDATE " + RetSqlName("AO3") + " SET AO3_CODUND = '', AO3_CODEQP = '', AO3_IDESTN = '', AO3_NVESTN = 0 WHERE AO3_FILIAL = '" + xFilial("AO3")+ "' AND AO3_CODEQP = '"+ aNodesPar[nY,2]+"'"
			cSqlAO5a	:= "DELETE FROM " + RetSqlName("AO5") + " WHERE AO5_FILIAL = '" + xFilial("AO5")+ "' AND AO5_ENTANE = 'ACA' AND AO5_CODANE = '"+aNodesPar[nY,2]+"'"
			cSqlAO5b	:= "DELETE FROM " + RetSqlName("AO5") + " WHERE AO5_FILIAL = '" + xFilial("AO5")+ "' AND AO5_ENTPAI = 'ACA' AND AO5_CODPAI = '"+aNodesPar[nY,2]+"'"		
		Endif 

		//Usuarios	
		If	aNodesPar[nY,1] == "EXUSU"
			cSqlAO3	:= "UPDATE " + RetSqlName("AO3") + " SET AO3_CODUND = '', AO3_CODEQP = '', AO3_IDESTN = '', AO3_NVESTN = 0 WHERE AO3_FILIAL = '" + xFilial("AO3")+ "' AND AO3_CODUSR = '"+ aNodesPar[nY,2]+"'"
			cSqlAO5a	:= "DELETE FROM " + RetSqlName("AO5") + " WHERE AO5_FILIAL = '" + xFilial("AO5")+ "' AND AO5_ENTANE = 'USU' AND AO5_CODANE = '"+aNodesPar[nY,2]+"'"
			cSqlAO5b	:= ""
			cSqlAO4		:= "UPDATE " + RetSqlName("AO4") + " SET AO4_IDESTN = ' ' , AO4_NVESTN = 0 WHERE AO4_FILIAL = '" + xFilial("AO4")+ "' AND AO4_CODUSR = '"+ aNodesPar[nY,2]+"'"
			If SA3->(DbSeek(xFilial("SA3")+aNodesPar[nY,2]))
				Reclock("SA3",.F.)
					SA3->(A3_UNIDAD) := ""
				SA3->(MSUNLOCK())
			endif
		Endif
		
		If	!Empty(cSqlAO3)	
			TcSqlExec(cSqlAO3)
		Endif
		
		If	!Empty(cSqlAO5a)	
			TcSqlExec(cSqlAO5a)
		Endif 			

		If	!Empty(cSqlAO5b)	
			TcSqlExec(cSqlAO5b)
		Endif 		
		
		If	!Empty(cSqlAO4)	
			TcSqlExec(cSqlAO4)
		Endif 	
		 			
		For nX := aNodesPar[nY,7] to Len( aNodes )

			For nW := 1 To Len( aNodes[nX] )
				
	  			dbSelectArea("AO5")
				dbSetOrder(1)
					  	
			  	If	dbSeek(xFilial("AO5") + aNodes[nX, nW, 1] + aNodes[nX, nW, 2] + aNodes[nX, nW, 3] + aNodes[nX, nW, 4] )
			  	
			  		// Atualiza ID e nivel - UNIDADES
			  		nScan_ADK := aScan( aNodes[nX], { |x| ( x[1] == aNodes[nX, nW, 1] .And. AllTrim(x[2]) == alltrim(aNodes[nX, nW, 2]) .AND. X[3] = "ADK" .AND. AllTrim(x[4]) == alltrim(aNodes[nX, nW, 4]) .And. x[9] == 1 ) } )

			  		If	nScan_ADK > 0	
						RecLock( "AO5", .F. )
						AO5->AO5_IDESTN 	:= AllTrim( aNodes[nX, nScan_ADK, 5] )
						AO5->AO5_NVESTN	:= aNodes[nX, nScan_ADK, 6]
						AO5->(MsUnlock())
					Endif
			  	
			  		// Atualiza ID e nivel - EQUIPES
			  		nScan_ACA := aScan( aNodes[nX], { |x| ( x[1] == aNodes[nX, nW, 1] .And. AllTrim(x[2]) == alltrim(aNodes[nX, nW, 2]) .AND. X[3] = "ACA" .AND. AllTrim(x[4]) == alltrim(aNodes[nX, nW, 4]) .And. x[9] == 1 ) } )

			  		If	nScan_ACA > 0	
						RecLock( "AO5", .F. )
						AO5->AO5_IDESTN 	:= AllTrim( aNodes[nX, nScan_ACA, 5] )
						AO5->AO5_NVESTN	:= aNodes[nX, nScan_ACA, 6]
						AO5->(MsUnlock())
					Endif

			  		// Atualiza ID e nivel - USUARIOS 					
			  		nScan_USU := aScan( aNodes[nX], { |x| ( x[1] == aNodes[nX, nW, 1] .And. AllTrim(x[2]) == alltrim(aNodes[nX, nW, 2]) .AND. X[3] = "USU" .AND. AllTrim(x[4]) == alltrim(aNodes[nX, nW, 4]) .And. x[9] == 1 ) } )
			  		
			  		If	nScan_USU > 0
			  		
						RecLock( "AO5", .F. )
						AO5->AO5_IDESTN 	:= AllTrim( aNodes[nX, nScan_USU, 5] )
						AO5->AO5_NVESTN	:= aNodes[nX, nScan_USU, 6]
						AO5->(MsUnlock())

						//Gravação (atualizacao do ID e nivel)
						CA240CpGrv(aNodes[nX,nScan_USU,1], aNodes[nX,nScan_USU,2], aNodes[nX,nScan_USU,3], aNodes[nX,nScan_USU,4], aNodes[nX,nScan_USU,5], aNodes[nX,nScan_USU,6], aNodes, aNodesPar, nX)
						
					Endif
					 						
			  	Endif
					
			Next nW
				
		Next nX		
	
	Endif 
	
	// ------> ************** ANEXAR: UNIDADE DE NEGOCIO / EQUIPE DE VENDA / USUARIO ************************************	

	IF	aNodesPar[nY,1] $ "INUDN|INEQP|INUSU"
	
		RecLock( "AO5", .T. )
		AO5->AO5_FILIAL := xFilial("AO5")
		AO5->AO5_ENTPAI := aNodesPar[nY,3]
		AO5->AO5_CODPAI := aNodesPar[nY,4]
		AO5->AO5_ENTANE := aNodesPar[nY,5]
		AO5->AO5_CODANE := aNodesPar[nY,2]

		nI:= aNodesPar[nY,7]	 
		
		If	aNodesPar[nY,1] == "INUDN"
		
	  		// Atualiza ID e nivel - UNIDADES
  			nScan_ADK := aScan( aNodes[nI], { |x| ( x[1] == aNodesPar[nY,3] .And. AllTrim(x[2]) == aNodesPar[nY,4] .AND. X[3] = "ADK" .AND. AllTrim(x[4]) == aNodesPar[nY,2] .And. x[9] == 1 ) } )

	  		If	nScan_ADK > 0
				
				AO5->AO5_IDESTN 	:= AllTrim( aNodes[nI, nScan_ADK, 5] )
				AO5->AO5_NVESTN	:= aNodes[nI, nScan_ADK, 6]
				
				cIDPosi		:= AllTrim( aNodes[nI, nScan_ADK, 5] ) 
				nNVPosi		:= aNodes[nI, nScan_ADK, 6]
				
			Endif
		
		Endif
		
		If	aNodesPar[nY,1] == "INEQP"		
			  	
			// Atualiza ID e nivel - EQUIPES
			nScan_ACA := aScan( aNodes[nI], { |x| ( x[1] == aNodesPar[nY,3] .And. AllTrim(x[2]) == aNodesPar[nY,4] .AND. X[3] = "ACA" .AND. AllTrim(x[4]) == aNodesPar[nY,2] .And. x[9] == 1 ) } )

			If	nScan_ACA > 0

				AO5->AO5_IDESTN 	:= AllTrim( aNodes[nI, nScan_ACA, 5] )
				AO5->AO5_NVESTN	:= aNodes[nI, nScan_ACA, 6]
				
				cIDPosi		:= AllTrim( aNodes[nI, nScan_ACA, 5] ) 
				nNVPosi		:= aNodes[nI, nScan_ACA, 6]
				
			Endif
		
		Endif

		If	aNodesPar[nY,1] == "INUSU"

			// Atualiza ID e nivel - USUARIOS 					
			nScan_USU := aScan( aNodes[nI], { |x| ( x[1] == aNodesPar[nY,3] .And. AllTrim(x[2]) == alltrim(aNodesPar[nY,4]) .AND. X[3] = "USU" .AND. AllTrim(x[4]) == alltrim(aNodesPar[nY,2]) .And. x[9] == 1 ) } )
			  		
			If	nScan_USU > 0	

				AO5->AO5_IDESTN 	:= AllTrim( aNodes[nI, nScan_USU, 5] )
				AO5->AO5_NVESTN	:= aNodes[nI, nScan_USU, 6]

				cIDPosi		:= AllTrim( aNodes[nI, nScan_USU, 5] ) 
				nNVPosi		:= aNodes[nI, nScan_USU, 6]
				
				
			Endif
		
		Endif  	

		AO5->(MsUnlock())
	
		//Gravação (atualizacao do ID e nivel)
		CA240CpGrv(aNodesPar[nY,3], aNodesPar[nY,4], aNodesPar[nY,5], aNodesPar[nY,2], cIDPosi, nNVPosi, aNodes, aNodesPar, nNVPosi)
		
	Endif

Next nY 

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240CpGrv

Realiza atualizacao do ID e nivel nas tabelas que usam estrutura de negocio    

@sample	CA240CpGrv(cEntPAI, cCodPAI, cEntANE, cCodANE, cIDESTN, nNveSTN, aNodes, aNodesPar, nLinha, cConcat )

@param		ExpA1 - Entidade pai (ALIAS)
			ExpA2 - Codigo da entidade pai
			ExpA3 - Alias anexo na estrutura
			ExpA4 - Codigo da entidade anexada 
			ExpA5 - ID 
			ExpN1 -	 Nivel
			ExpA1 - Array completo da estrutura
			ExpA2 - Array com as alteracoes pontuais
			ExpC6 - Linha posicionada do ANODES
			ExpC7 - Simbolo de concatenacao de acordo com o banco  
             
@return	Nenhum 

@author 	Eduardo Gomes Junior 
@since 		10/08/2015
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240CpGrv(cEntPAI, cCodPAI, cEntANE, cCodANE, cIDESTN, nNveSTN, aNodes, aNodesPar, nLinha, cConcat )

Local nY			:= 0 
Local aEntidad		:= StrTokArr(CRMXCtrlEnt(),"|") // Entidades controlada pelo controle de acesso.
Local aCpoFiltro	:= {}
Local cPrxCpo		:= ""
Local cCpoFilial	:= ""
Local cCpoVend		:= ""
Local cQuery		:= ""
Local nI			:= 0
Local cEquipe		:= ""
Local cUnidade		:= ""
Local lCtrlPriv			:= SuperGetMv("MV_ESTCTRL",.F.,.T.)

Default cConcat	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Define o simbolo de concatenacao de acordo com o banco³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Upper(TcGetDb()) $ "ORACLE,POSTGRES,DB2,INFORMIX"
	cConcat := "||"
Else
	cConcat := "+"
Endif

// verificando se tem equipe superior
If cEntPAI == "ACA" .And. cEntANE == "ACA"
	If ACA->(DbSeek(xFilial("ACA")+cCodANE))
		RecLock("ACA",.F.)
		ACA->ACA_GRPSUP := cCodPAI
		ACA->(MsUnlock())
	EndIf
EndIf
						
// corrigindo a equipe de venda e a unidade de negócio dos usuários do CRM e vendedor
If cEntANE == "USU"
							
	If cEntPAI  == "ADK"
		cEquipe  := ""
		cUnidade := cCodPAI
	ElseIf cEntPAI == "ACA"
		cEquipe  := cCodPAI
		cUnidade := CA240RUnid(aNodes,cEntPAI,cCodPAI,nLinha-1)
	ElseIf cEntPAI == "USU"
		cEquipe  := cCodPAI
		cUnidade := CA240RUnid(aNodes,cEntPAI,cCodPAI,nLinha-1)
	EndIf
	
	// corrigindo o Id e Nível de acesso dos usuários do CRM na tabela AO4
	cSqlAO4	:= "UPDATE " + RetSqlName("AO4") + " SET AO4_IDESTN = '"+cIDESTN+"', AO4_NVESTN = '"+Str(nNveSTN,2)+"' WHERE AO4_FILIAL = '" + xFilial("AO4")+ "' AND AO4_CODUSR = '"+ cCodANE+"'"
	TcSqlExec(cSqlAO4)	

	If AO3->(DbSeek(xFilial("AO3")+cCodANE))
							
		RecLock("AO3",.F.)
		AO3->AO3_CODUND := cUnidade 
		AO3->AO3_CODEQP := cEquipe
		AO3->AO3_IDESTN := cIDESTN
		AO3->AO3_NVESTN := nNveSTN
		
		//Se o usuario é um vendedor atualiza a AO3.
		// Além disso, atualiza a unidade de negócio do vendedor
		If Empty(AO3->AO3_VEND)
			If SA3->(DbSeek(xFilial("SA3")+cCodANE))
				AO3->AO3_VEND := SA3->A3_COD
			EndIf	
		EndIf
		AO3->(MsUnlock())
		
		If SA3->(DbSeek(xFilial("SA3")+cCodANE))
			Reclock("SA3",.F.)
				SA3->(A3_UNIDAD) := cUnidade
			SA3->(MSUNLOCK())
		EndIf								
		
		If !Empty(AO3->AO3_VEND)
										
			For nY := 1 To Len(aEntidad)
									
				aCpoFiltro	:= CRMXCpoFil(aEntidad[nY])
										
				If Len(aCpoFiltro) > 0
												
					cPrxCpo 	:= IIF(Subs(aEntidad[nY],1,1)=="S",SubStr(aEntidad[nY],2,3),aEntidad[nY])
					cCpoFilial	:= cPrxCpo+aCpoFiltro[1]
					cCpoVend	:= cPrxCpo+aCpoFiltro[2]
												
					// Processa as entidades que possui nivel da estrutura como cache.
					If Len(aCpoFiltro) == 4
													
						cCpoIdEstN	:= cPrxCpo+aCpoFiltro[3]
						cCpoNvEstN	:= cPrxCpo+aCpoFiltro[4]
													
						cQuery := " UPDATE "+RetSqlName(aEntidad[nY])+" SET "+cCpoIdEstN+" = '"+cIDESTN+"', "+cCpoNvEstN+" = "+cValToChar(nNveSTN) "
						cQuery += " WHERE "+cCpoFilial+" = '"+xFilial(aEntidad[nY])+"' AND "+cCpoVend+" = '"+AO3->AO3_VEND+"'"
													
						// Sincroniza as oportunidades em aberto e suspensa.
						If aEntidad[nY] == "AD1"
							cQuery += " AND AD1_STATUS IN ('1','3') "
						EndIf
													
						cQuery += " AND D_E_L_E_T_ = ' ' "
													
						nRetSQL := TCSqlExec(cQuery)
													
						//Aborta a sincronizacao das entidades no segundo laco FOR.
						If nRetSQL < 0
							lRetorno := .F.
							Exit
						EndIf
													
				EndIf
												
				If lCtrlPriv	
													
					aSX2Unq 	:= StrTokArr(cPrxCpo+aCpoFiltro[1]+"+"+AllTrim(CRMXGetSX2(aEntidad[nY],.T.)[4]),"+")
					cSX2Select	:= ""
					cSX2Unq 	:= ""
					cSX2UnqSQL	:= ""
													
					For nI := 1 To Len(aSX2Unq)

						If	nI <> Len(aSX2Unq)
							cSX2Unq 	+= aSX2Unq[nI]+"+"
							cSX2Select	+= aSX2Unq[nI]+","
							cSX2UnqSQL	+= aSX2Unq[nI]+cConcat
						Else
							cSX2Unq 	+= aSX2Unq[nI]
							cSX2Select	+= aSX2Unq[nI]
							cSX2UnqSQL	+= aSX2Unq[nI]
						EndIf
					Next nI
													
					cAliasQry	:= GetNextAlias()

					cQuery 	:= ""
													
					cQuery += " SELECT "+cSX2Select
					cQuery += " FROM "+RetSqlName(aEntidad[nY])+" "+aEntidad[nY]
					cQuery += " WHERE "+cCpoFilial+" = "+"'"+xFilial(aEntidad[nY])+"' AND "
					cQuery +=   cCpoVend+" = "+"'"+AO3->AO3_VEND+"' AND "
					cQuery +=   aEntidad[nY]+".D_E_L_E_T_ = ' ' AND "
					cQuery += " NOT EXISTS "
					cQuery += "( SELECT 1 FROM "+RetSqlName("AO4")+" AO4 "
					cQuery += " WHERE AO4.AO4_FILIAL = '"+xFilial("AO4")+"' AND "
					cQuery += " AO4.AO4_CODUSR = '"+AO3->AO3_CODUSR+"' AND "					
					cQuery += " AO4.AO4_ENTIDA = '"+aEntidad[nY]+"' AND "
					cQuery += " AO4.AO4_CHVREG = "+cSX2UnqSQL+" AND "
					cQuery += " AO4.D_E_L_E_T_ = ' ' )"
													
					IIF(Select(cAliasQry)>0,(cAliasQry)->(DbCloseArea()),Nil)
						cQuery := ChangeQuery(cQuery)
					
						DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

						While (cAliasQry)->(!Eof())
							cChave   := PadR((cAliasQry)->&(cSX2Unq),TAMSX3("AO4_CHVREG")[1])
							aAutoAO4 := CRMA200PAut(3,aEntidad[nY],cChave,AO3->AO3_CODUSR,/*aPermissoes*/,/*aNvlEstrut*/,/*cCodUsrCom*/,/*dDataVld*/)
							lRetorno := CRMA200Auto(aAutoAO4[1],aAutoAO4[2],3)
																
							//Aborta processamento da estrutura no segundo laco While
							If !lRetorno
								Exit
							EndIf
																	
							(cAliasQry)->(DbSkip())
						End
													
						(cAliasQry)->(DbCloseArea())
													
					EndIf
								
				EndIf
											
			Next nY

		Endif
										
	EndIf
									
EndIf
								
Return

//---------------------------------------------------------------------------------------------------------------
/*/{Protheus.doc} CRMA240PStr

Visualização parcial da estrutura de negócios

@sample		CRMA240PStr(cUsrVen)
@param		ExpC - Codigo do usuário
@return		ExpA - Array da estrutura parcial

@author		Bruno Colisse
@since		03/07/2015
@version	12.0.7
/*/
//---------------------------------------------------------------------------------------------------------------
Function CRMA240PStr(cUsrVen)

Local cChave	:= ""
Local cAliasTmp	:= GetNextAlias()
Local cDescEnt	:= ""
Local cCpoDesc	:= ""
Local nx		:= 0
Local aNodes	:= {}

dbSelectArea("AO3")
AO3->(dbSetOrder(1))

If AO3->(dbSeek(xFilial("AO3") + cUsrVen))       // Posiciona no registro do usuário logado na tabela AO3
	
	cChave := AllTrim(Left(Posicione("AO5",2, xFilial("AO5") + "USU" + cUsrVen, "AO5_IDESTN"),4)) 

	BeginSql Alias cAliasTmp 
	
		SELECT	AO5.AO5_ENTPAI, AO5.AO5_CODPAI, AO5.AO5_ENTANE, AO5.AO5_CODANE, 
				AO5.AO5_IDESTN, AO5.AO5_NVESTN 
		FROM 	%Table:AO5% AO5
		WHERE 	AO5.AO5_FILIAL = %xFilial:AO5% AND
				SUBSTRING(AO5.AO5_IDESTN,1,4) = %exp:cChave% AND
				AO5.%NotDel%
		ORDER BY AO5.AO5_NVESTN  	
	
	EndSql

	(cAliasTmp)->(dbGoTop())

	While (cAliasTmp)->(!EOF())
		
		If (cAliasTmp)->AO5_ENTANE == "USU"
			cDescEnt := AllTrim(UsrRetName((cAliasTmp)->AO5_CODANE))
		Else
			If (cAliasTmp)->AO5_ENTANE == "ACA"
				cCpoDesc := "ACA_DESCRI"
			Else
				cCpoDesc := "ADK_NOME"	
			EndIf					
			cDescEnt := AllTrim(Posicione((cAliasTmp)->AO5_ENTANE,1,xFilial((cAliasTmp)->AO5_ENTANE)+(cAliasTmp)->AO5_CODANE,cCpoDesc))
		EndIf
			
		nx++
		aAdd(aNodes,{	(cAliasTmp)->AO5_ENTPAI			,;
						AllTrim((cAliasTmp)->AO5_CODPAI),;
						(cAliasTmp)->AO5_ENTANE			,;
						(cAliasTmp)->AO5_CODANE			,;
						(cAliasTmp)->AO5_IDESTN			,;
						cDescEnt						,;
						nx								})
							   
		(cAliasTmp)->( dbSkip() ) 
	EndDo
	
	(cAliasTmp)->( DbCloseArea() ) 

Else

	aAdd(aNodes,{"","","","","",0})

EndIf

Return(aNodes)

//-------------------------------------------------------------------
/*/{Protheus.doc} CRMA240Role
Converte um usuário para um papel na estrutura de negócio. 

@param cEntity, caracter, Código do nível principal. 
@param cEntityID, caracter, ID do nível principal. 
@return	cID, caracter, Chave do registro depos da conversão para papel.    

@author  Valdiney V GOMES 
@version P12
@since   11/01/2016 
/*/
//-------------------------------------------------------------------
Function CRMA240Role( cEntity, cEntityID )
	Local aArea		:= AO3->( GetArea() )
	Local cSequence	:= ""
	Local cRole		:= ""
	Local cID		:= ""
	Local lRole		:= .T. 
	Local cFilAZS	:= xFilial("AZS")  

	Default cEntity		:= "USU"
	Default cEntityID	:= ""

	If ( cEntity == "USU" )
	 	cSequence	:= "00"
	 	cRole		:= GetMV( "MV_CRMUSRP" ) 
	 	cID			:= cEntityID	

		AO3->( DBSetOrder( 1 ) ) 
	
		//-------------------------------------------------------------------
		// Localiza o usuário do CRM.  
		//-------------------------------------------------------------------	
		If ( AO3->( DBSeek( xFilial("AO3") + cEntityID ) ) )
			AZS->( DBSetOrder( 1 ) )
			
			//-------------------------------------------------------------------
			// Localiza o papel do usuário.  
			//-------------------------------------------------------------------
			lRole := ( AZS->( DBSeek( cFilAZS + cEntityID ) ) )
			
			//-------------------------------------------------------------------
			// Verifica se o usuário já possui o papel padrão cadastrado.  
			//-------------------------------------------------------------------	
			If ( lRole )
				While ( ! AZS->( Eof() ) .And. AZS->AZS_FILIAL == cFilAZS .And. AZS->AZS_CODUSR == cEntityID )
					cSequence	:= AZS->AZS_SEQUEN
					lRole 		:= ( AZS->AZS_PAPEL == cRole )
					
					//-------------------------------------------------------------------
					// Verifica se o usuário possui o papel padrão.  
					//-------------------------------------------------------------------	
					If ( lRole )
						Exit
					EndIf 
					
					AZS->( DBSkip() )
				Enddo
			EndIf
					
			If ! ( lRole )
				//-------------------------------------------------------------------
				// Insere o papel padrão o usuário.  
				//-------------------------------------------------------------------
				RecLock( "AZS", .T. )
					AZS->AZS_FILIAL := xFilial("AZS")
					AZS->AZS_CODUSR	:= cEntityID
					AZS->AZS_SEQUEN := Soma1( cSequence )
					AZS->AZS_PAPEL	:= cRole
					AZS->AZS_VEND 	:= AO3->AO3_VEND
					AZS->AZS_CODUND	:= AO3->AO3_CODUND
					AZS->AZS_CODEQP	:= AO3->AO3_CODEQP
					AZS->AZS_IDESTN	:= AO3->AO3_IDESTN
					AZS->AZS_NVESTN := AO3->AO3_NVESTN
					AZS->AZS_PAPPRI	:= "1"
				MSUnlock()		
				
				//-------------------------------------------------------------------
				// Limpa as informações migradas para o papel.  
				//-------------------------------------------------------------------			
				RecLock( "AO3", .F. )
					AO3->AO3_VEND	:= ""
					AO3->AO3_CODUND := ""
					AO3->AO3_CODEQP := ""
					AO3->AO3_IDESTN := ""
					AO3->AO3_NVESTN := 0
				MSUnlock()
			EndIf 
			
			//-------------------------------------------------------------------
			// Monta o ID do papel do usuário.  
			//-------------------------------------------------------------------	
			cID := ( AZS->AZS_CODUSR + AZS->AZS_SEQUEN + AZS->AZS_PAPEL )
		EndIf
	EndIf
	
	RestArea( aArea ) 
Return cID 


//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDLoad
    @description
    Inicializa variaveis com lista de campos que devem ser ofuscados de acordo com usuario.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cUser, Caractere, Nome do usuário utilizado para validar se possui acesso ao 
        dados protegido.
    @param aAlias, Array, Array com todos os Alias que serão verificados.
    @param aFields, Array, Array com todos os Campos que serão verificados, utilizado 
        apenas se parametro aAlias estiver vazio.
    @param cSource, Caractere, Nome do recurso para gerenciar os dados protegidos.
    
    @return cSource, Caractere, Retorna nome do recurso que foi adicionado na pilha.
    @example FATPDLoad("ADMIN", {"SA1","SU5"}, {"A1_CGC"})
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDLoad(cUser, aAlias, aFields, cSource)
	Local cPDSource := ""

	If FATPDActive()
		cPDSource := FTPDLoad(cUser, aAlias, aFields, cSource)
	EndIf

Return cPDSource

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDUnload
    @description
    Finaliza o gerenciamento dos campos com proteção de dados.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cSource, Caractere, Remove da pilha apenas o recurso que foi carregado.
    @return return, Nulo
    @example FATPDUnload("XXXA010") 
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDUnload(cSource)    

    If FATPDActive()
		FTPDUnload(cSource)    
    EndIf

Return Nil

//-----------------------------------------------------------------------------------
/*/{Protheus.doc} FATPDIsObfuscate
    @description
    Verifica se um campo deve ser ofuscado, esta função deve utilizada somente após 
    a inicialização das variaveis atravez da função FATPDLoad.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @author Squad CRM & Faturamento
    @since  05/12/2019
    @version P12.1.27
    @param cField, Caractere, Campo que sera validado
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado
    @return lObfuscate, Lógico, Retorna se o campo será ofuscado.
    @example FATPDIsObfuscate("A1_CGC",Nil,.T.)
/*/
//-----------------------------------------------------------------------------------
Static Function FATPDIsObfuscate(cField, cSource, lLoad)
    
	Local lObfuscate := .F.

    If FATPDActive()
		lObfuscate := FTPDIsObfuscate(cField, cSource, lLoad)
    EndIf 

Return lObfuscate

//-----------------------------------------------------------------------------
/*/{Protheus.doc} FATPDObfuscate
    @description
    Realiza ofuscamento de uma variavel ou de um campo protegido.
	Remover essa função quando não houver releases menor que 12.1.27

    @type  Function
    @sample FATPDObfuscate("999999999","U5_CEL")
    @author Squad CRM & Faturamento
    @since 04/12/2019
    @version P12
    @param xValue, (caracter,numerico,data), Valor que sera ofuscado.
    @param cField, caracter , Campo que sera verificado.
    @param cSource, Caractere, Nome do recurso que buscar dados protegidos.
    @param lLoad, Logico, Efetua a carga automatica do campo informado

    @return xValue, retorna o valor ofuscado.
/*/
//-----------------------------------------------------------------------------
Static Function FATPDObfuscate(xValue, cField, cSource, lLoad)
    
    If FATPDActive()
		xValue := FTPDObfuscate(xValue, cField, cSource, lLoad)
    EndIf

Return xValue   

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

//-------------------------------------------------------------------
/*/{Protheus.doc} CA240VldId

Funcao para validar o Id. Acesso de Estrura de Negócio no array de nodes  

@sample	CA240VldId( aNodes )

@param		aNodes - Array de controle dos NODES da Tree 
             
@return	lRet, Logico, Indica se o tamanho do Id. está de acordo com o grupo de campos 075 (Id. Acesso Estrutura de Neg.)

@author 	Squad CRM
@since 		20/08/2020
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function CA240VldId( aNodes )
Local lRet 	     := .T.
Local nX		 := 0
Local nY		 := 0
Local nTamIdEstN := GetSX3Cache("AO4_IDESTN","X3_TAMANHO")

If Len(aNodes) > 0
	For nX := 1 To Len( aNodes )
		For nY := 1 To Len( aNodes[nX] )
			If Len( aNodes[nX][nY][5] ) > nTamIdEstN
				lRet := .F.
				Exit
			EndIf
		Next nY
		If !lRet
			Exit
		EndIf
	Next nX
EndIf

Return lRet
