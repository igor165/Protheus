#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "LOJA1149.CH"


//Indices do array com os grupos de tabela selecionados
#DEFINE 	TGCODE 	1
#DEFINE 	TGNAME 	2
#DEFINE 	TGDESC 	3
#DEFINE 	TGTABLE 4
#DEFINE		TGTYPE 	5

Static cTabPRV := "1" //Tabela de preco 1 (B0_PRV1)

// O protheus necessita ter ao menos uma função pública para que o fonte seja exibido na inspeção de fontes do RPO.
Function LOJA1149() ; Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadMakerWizard()

Assistênte de geração de carga.

@author Vendas CRM
@since 07/02/10
/*/
//-------------------------------------------------------------------------------- 
Class LJCInitialLoadMakerWizard
	// Objetos e métodos gerais
	Data oWizard
	Data aTableGroups
	Data cPathOfRepository	
	Data lHasChange
	Data cCodInitialLoad //MBU_CODIGO - codigo da carga que esta sendo gerada 
	
	Method New()	
	Method Show()	
	Method Initialize()
	Method ButtonClick()
	
	// Objetos e métodos de tela da primeira página
	Data oPanTabGroup
	Data oLbxTabGroup
	Data oBtnGAdd
	Data oBtnGRen
	Data oBtnGRem	
	Method AddTableGroup()
	Method RenTableGroup()
	Method RemTableGroup()
	Method ConTableGroup()	
	Method PopTabGroups()	
	Method ListBoxSearch()
	Method GetStrArrayOf()
	Method GetDefaultListFor()
	Method ConLbxDefault()
	Method ConLbxArray()	
	Method CheckSelectedGroup()
	
	// Objetos e métodos de tela da segunda página
	Data oPanTabSel
	Data oLbxAvalTables	
	Data oMGTAvalSearch
	Data cMGTAvalSearch
	Data oBtnTAvalSearch
	Method PopAvalTables()
	Data oLbxSeleTables
	Data oMGTSeleSearch
	Data cMGTSeleSearch	
	Data oBtnTSeleSearch
	Method PopSeleTables()	
	Data oBtnTAdd
	Data oBtnTRemove	
	Data oBtnTConfigure
	Method AddTable()
	Method RemoveTable()
	Method ConTable()
	Method SelectMode()
	Method ConCompleteTable()
	Method ConPartialTable()
	Method ConSpecialTable()
	Method Lj1149LdTb()
	
	// Objetos e métodos de tela da terceira página
	Data oPanelMakeLoad
	Data oLblState
	Data oLblTable
	Data oLblSpeed
	Data oLblProgress
	Data cMeter
	Data oMeter
	Data oBtnMakeLoad
	Data oBtnSaveLoad			
	Method ResetState()
	Method MakeInitialLoad()
	Method Update()
	
	
	Method SetOnlyView()
EndClass



//--------------------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor

@param aTableGroups grupo de tabelas

@return Self

@author Vendas CRM
@since 07/02/10
/*/
//-------------------------------------------------------------------------------- 
Method New( aTableGroups ) Class LJCInitialLoadMakerWizard
	Self:cPathOfRepository	:= ""
	Self:cMGTAvalSearch		:= Space(30)
	Self:cMGTSeleSearch		:= Space(30)
	Self:aTableGroups		:= aTableGroups
	Self:lHasChange 		:= .F.	
Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} Show()

Exibe a tela do assistênte.

@return Nenhum

@author Vendas CRM
@since 07/02/10
/*/
//-------------------------------------------------------------------------------- 
Method Show() Class LJCInitialLoadMakerWizard
	Self:Initialize()
	
	ACTIVATE WIZARD Self:oWizard CENTERED
Return Self:lHasChange



//--------------------------------------------------------------------------------
/*/{Protheus.doc} Initialize()

Inicia e configura os componentes de tela do assistênte

@return Nenhum

@author Vendas CRM
@since 07/02/10
/*/
//-------------------------------------------------------------------------------- 
Method Initialize() Class LJCInitialLoadMakerWizard
	Local nP1Row	:= 0
	Local nP1Col	:= 0
	Local nP2Row	:= 0
	Local nP2Col	:= 0	
	Local nP3Row	:= 0
	Local nP3Col	:= 0	
	Local nP4Row	:= 0
	Local nP4Col	:= 0	
	Local lProfile := .F.
	
	DEFINE WIZARD Self:oWizard TITLE STR0001 HEADER STR0002 MESSAGE STR0003; // "Assistente de geração de carga" "Assistente de configuração e geração de carga do Controle de Lojas" "Introdução"
		TEXT STR0004 + CRLF + STR0005 + CRLF + STR0006 + CRLF + STR0007 PANEL ; //	"Esse assistente lhe auxiará na configuração e disponibilização da carga."	"Na página 'Seleção do grupo de tabelas' você irá selecionar o grupo de tabelas a ser utilizado." "Logo em seguida, na página 'Seleção das tabelas a serem geradas' você irá selecionar as tabelas que serão geradas." "Finalmente na página 'Geração da carga' poderá executar a geração de carga e assim disponibilizar os arquivos para serem baixados pelo terminal através do Servidor de Arquivos do Controle de Lojas."
		NEXT {|| MsgRun(STR0056, STR0009, {|| Self:PopTabGroups() } ), .T. } FINISH {|| .T. } // "Aguarde..."	 "Carregando grupos de tabelas."
		
	CREATE PANEL Self:oWizard HEADER STR0010 MESSAGE STR0057 PANEL; // "Assistente de configuração e geração de carga do Controle de Lojas" "Seleção do grupo de tabelas"
		BACK {|| .T.} NEXT {|| If( Self:CheckSelectedGroup(), (Self:Lj1149LdTb(), MsgRun(STR0008,STR0009, {|| Self:PopAvalTables(), Self:PopSeleTables() } ), .T.), .F.) } FINISH {|| .T. } EXEC {|| .T.} // "Criando lista de tabelas." "Aguarde..."

	Self:oPanTabGroup := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 0 )
	Self:oPanTabGroup:Align := CONTROL_ALIGN_ALLCLIENT		
			
	nP1Row	:= 05
	nP1Col	:= 20
		
	@ nP1Row		 , nP1Col Say STR0058 Size 200,020 COLOR CLR_BLACK Pixel Of Self:oPanTabGroup // "Selecione o grupo a ser utilizado, ou utilize os botões para renomear ou excluir o grupo selecionado e incluir para adicionar um novo grupo."
	@ nP1Row + 20 , nP1Col ListBox Self:oLbxTabGroup Fields Header STR0059, STR0093, STR0060, STR0061 Size 265, 60 Pixel Of Self:oPanTabGroup //atusx	// "Código" "Nome" "Descrição"
	@ nP1Row + 90, nP1Col + 155 Button Self:oBtnGAdd Prompt STR0019 Size 030,012 Pixel Of Self:oPanTabGroup Action MsgRun(STR0020,STR0009,{||Self:ButtonClick( Self:oBtnGAdd )}) PIXEL OF Self:oPanTabSel // "Adicionar" "Adicionando." "Aguarde..."
	@ nP1Row + 90, nP1Col + 195 Button Self:oBtnGRen Prompt STR0062 Size 030,012 Pixel Of Self:oPanTabGroup Action MsgRun(STR0062,STR0063,{||Self:ButtonClick( Self:oBtnGRen )}) PIXEL OF Self:oPanTabSel // "Renomear" "Renomeando." "Aguarde..." 
	@ nP1Row + 90, nP1Col + 235 Button Self:oBtnGRem Prompt STR0021 Size 030,012 Pixel Of Self:oPanTabGroup Action MsgRun(STR0022,STR0009,{||Self:ButtonClick( Self:oBtnGRem )}) PIXEL OF Self:oPanTabSel // "Remover" "Removendo." "Aguarde..."
	@ nP1Row + 110, nP1Col Say STR0109 Size 250,020 COLOR CLR_BLACK Pixel Of Self:oPanTabGroup // "Lembre-se de executar o 'UPDCARGA - Facilitador para a criação dos campos reservados da carga'."
	
	Self:ConLbxDefault( Self:oLbxTabGroup )
	
	CREATE PANEL Self:oWizard HEADER STR0010 MESSAGE STR0011 PANEL; // "Assistente de configuração e geração de carga do Controle de Lojas" "Seleção das tabelas a serem geradas"
		BACK {|| .T. } NEXT {|| Lj1149TbPV(aClone(Self:oLbxSeleTables:aArray)) } FINISH {|| .T. } EXEC {|| .T.} 
	
	Self:oPanTabSel := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 0 )
	Self:oPanTabSel:Align := CONTROL_ALIGN_ALLCLIENT		
	
	nP2Row	:= 3
	nP2Col	:= 4
	
	nP21Row := nP2Row
	nP21Col := nP2Col
		
	@ nP21Row + 10	,nP21Col + 6 ListBox Self:oLbxAvalTables Fields HEADER STR0013, STR0014 Size 100,100 Of Self:oPanTabSel Pixel // "Tabela" "Descrição"
	@ nP21Row + 115	,nP21Col + 6 MsGet Self:oMGTAvalSearch Var Self:cMGTAvalSearch Size 065,009 COLOR CLR_BLACK Picture "@!" PIXEL OF Self:oPanTabSel
	@ nP21Row + 114 ,nP21Col + 75 Button Self:oBtnTAvalSearch Prompt STR0015 Size 030,012 Action MsgRun(STR0017, STR0009, {|| Self:ButtonClick( Self:oBtnTAvalSearch ) } ) PIXEL OF Self:oPanTabSel  // "Procurar" "Procurando." "Aguarde..."
	@ nP21Row,nP21Col TO nP21Row + 130,nP21Col + 113 LABEL STR0018 PIXEL OF Self:oPanTabSel // "Tabelas disponíveis"
	
	Self:ConLbxDefault( Self:oLbxAvalTables )	

	nP22Row := nP2Row
	nP22Col := nP2Col + 116
	
	@ nP22Row + 010,nP22Col Button Self:oBtnTAdd Prompt STR0019 + " >>" Size 052,012 Action MsgRun(STR0020,STR0009,{||Self:ButtonClick( Self:oBtnTAdd )}) PIXEL OF Self:oPanTabSel // "Adicionar" "Adicionando." "Aguarde..."
	@ nP22Row + 025,nP22Col Button Self:oBtnTRemove Prompt "<< " + STR0021 Size 052,012 Action MsgRun(STR0022,STR0009,{||Self:ButtonClick( Self:oBtnTRemove )}) PIXEL OF Self:oPanTabSel // "Remover" "Removendo." "Aguarde..."
	@ nP22Row + 040,nP22Col Button Self:oBtnTConfigure Prompt STR0064 + " >>" Size 052,012 Action MsgRun(STR0065,STR0009,{||Self:ButtonClick( Self:oBtnTConfigure )}) PIXEL OF Self:oPanTabSel // "Configurar" "Configurando." "Aguarde..."	
	
	nP23Row := nP2Row + 1
	nP23Col := nP2Col + 170
	
	@ nP23Row + 10	,nP23Col + 6 ListBox Self:oLbxSeleTables Fields HEADER STR0013, STR0014, STR0023 Size 100,100 Of Self:oPanTabSel Pixel // "Tabela" "Descrição" "Modo"
	@ nP23Row + 115	,nP23Col + 6 MsGet Self:oMGTSeleSearch Var Self:cMGTSeleSearch Size 065,009 COLOR CLR_BLACK Picture "@!" PIXEL OF Self:oPanTabSel
	@ nP23Row + 114 ,nP23Col + 75 Button Self:oBtnTSeleSearch Prompt STR0015 Size 030,012 Action MsgRun(STR0017, STR0009, {|| Self:ButtonClick( Self:oBtnTSeleSearch ) } ) PIXEL OF Self:oPanTabSel  // "Procurar" "Aguarde..."	
	@ nP23Row,nP23Col TO nP23Row + 130,nP23Col + 113 LABEL STR0024 PIXEL OF Self:oPanTabSel // "Tabelas selecionadas"
	
	Self:ConLbxDefault( Self:oLbxSeleTables )
	
	CREATE PANEL Self:oWizard HEADER STR0031 MESSAGE STR0032 PANEL; // "Assistente de configuração e geração de carga do Controle de Lojas" "Geração da carga"
		BACK {|| .T.} NEXT {|| .T. } FINISH {|| .T. } EXEC {|| .T.}	
		
	Self:oPanelMakeLoad := TPanel():New( 0, 0, , Self:oWizard:oMPanel[Len(Self:oWizard:oMPanel)], , , , , , 0, 0 )
	Self:oPanelMakeLoad:Align := CONTROL_ALIGN_ALLCLIENT		

	nP3Row := 15
	nP3Col := 62
	
	@ nP3Row + 000, nP3Col + 000 To nP3Row + 60, nP3Col + 160 LABEL STR0039 PIXEL OF Self:oPanelMakeLoad // "Progresso da geração da carga"
	@ nP3Row + 010, nP3Col + 016 Say STR0040 Size 018,008 COLOR CLR_BLACK PIXEL OF Self:oPanelMakeLoad	// "Status:"
	@ nP3Row + 020, nP3Col + 016 Say STR0041 Size 018,008 COLOR CLR_BLACK PIXEL OF Self:oPanelMakeLoad // "Tabela:"
	@ nP3Row + 030, nP3Col + 005 Say STR0042 Size 028,008 COLOR CLR_BLACK PIXEL OF Self:oPanelMakeLoad // "Velocidade:"
	@ nP3Row + 040, nP3Col + 006 Say STR0043 Size 028,008 COLOR CLR_BLACK PIXEL OF Self:oPanelMakeLoad // "Progresso:"
				
	@ nP3Row + 010, nP3Col + 036 Say Self:oLblState PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF Self:oPanelMakeLoad				
	@ nP3Row + 020, nP3Col + 036 Say Self:oLblTable PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF Self:oPanelMakeLoad
	@ nP3Row + 030, nP3Col + 036 Say Self:oLblSpeed PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF Self:oPanelMakeLoad
	@ nP3Row + 040, nP3Col + 036 Say Self:oLblProgress PROMPT "" Size 120,008 COLOR CLR_BLACK PIXEL OF Self:oPanelMakeLoad
	@ nP3Row + 050, nP3Col + 005 METER Self:oMeter Var Self:cMeter Size 150,008 NOPERCENTAGE PIXEL OF Self:oPanelMakeLoad	
	
	@ 85, 62 Button Self:oBtnSaveLoad Prompt STR0100 Size 057,012 Action Self:ButtonClick( Self:oBtnSaveLoad ) PIXEL OF Self:oPanelMakeLoad // "Salvar Configuração"
	@ 85, 165 Button Self:oBtnMakeLoad Prompt STR0044 Size 057,012 Action Self:ButtonClick( Self:oBtnMakeLoad ) PIXEL OF Self:oPanelMakeLoad // "Gerar"
	
	lProfile := FindFunction('FWIsProfile') .and. FWIsProfile()
	If lProfile
		::oWizard:ACBVALID[LEN(::oWizard:ACBVALID)][3] := { || Self:oBtnSaveLoad:Click(), FWVldFinishWizard( Self:oLbxTabGroup:aArray[Self:oLbxTabGroup:nAt][1] ) }
		//::oWizard:ACBVALID[2][2] := {|lRet| lRet := FWVldAlterWizard(Self:oLbxTabGroup:aArray[Self:oLbxTabGroup:nAt][1],1), ::SetOnlyView(!lRet),If( Self:CheckSelectedGroup(), ( MsgRun(STR0008,STR0009, {|| Self:PopAvalTables(), Self:PopSeleTables() } ), .T.), .F.),.T. }
		::oWizard:ACBVALID[2][1] := {|| ::SetOnlyView(.F.),.T. }
		//::oWizard:ACBEXECUTE[3] := { |lRet| lRet := FWVldAlterWizard(Self:oLbxTabGroup:aArray[Self:oLbxTabGroup:nAt][1]), iIf(lRet,::SetOnlyView(), )}
		::oBtnGRem:Disable()
		::oBtnSaveLoad:Hide()
		::oBtnMakeLoad:Hide()
	Else
		::oWizard:ACBVALID[2][1] := {|| ::SetOnlyView(.F.),::oBtnSaveLoad:Show(),.T. }
	EndIf
		::oWizard:ACBVALID[1][1] := {|lRet| lRet := FWVldAlterWizard(Self:oLbxTabGroup:aArray[Self:oLbxTabGroup:nAt][1],1,lProfile), ::SetOnlyView(!lRet),iIf(!lRet .Or. lProfile, ::oBtnSaveLoad:Hide(),::oBtnSaveLoad:Show() ),If( Self:CheckSelectedGroup(), ( MsgRun(STR0008,STR0009, {|| Self:PopAvalTables(), Self:PopSeleTables() } ), .T.), .F.),.T. }

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ButtonClick()

Método que recebe os eventos de clique do assistênte. 

@param oSender Objeto que gerou o evento de clique.
@return Nil

@author Vendas CRM
@since 07/02/10
/*/
//-------------------------------------------------------------------------------- 
Method ButtonClick( oSender ) Class LJCInitialLoadMakerWizard
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local uTemp1		   		:= Nil

	If oSender == Self:oBtnTAvalSearch
		uTemp1 := Self:ListBoxSearch( Self:oLbxAvalTables, Self:oMGTAvalSearch:cText )
		If uTemp1 > 0
			Self:oLbxAvalTables:nAt := uTemp1
			Self:oMGTAvalSearch:nClrText := CLR_BLACK			
			Self:oMGTAvalSearch:nClrPane := CLR_WHITE
		Else
			Self:oMGTAvalSearch:nClrText := CLR_WHITE
			Self:oMGTAvalSearch:nClrPane := CLR_HRED
		EndIf
	ElseIf oSender == Self:oBtnTSeleSearch
		uTemp1 := Self:ListBoxSearch( Self:oLbxSeleTables, Self:oMGTSeleSearch:cText )	
		If uTemp1 > 0		
			Self:oLbxSeleTables:nAt := uTemp1
			Self:oMGTSeleSearch:nClrText := CLR_BLACK			
			Self:oMGTSeleSearch:nClrPane := CLR_WHITE			
		Else
			Self:oMGTSeleSearch:nClrText := CLR_WHITE
			Self:oMGTSeleSearch:nClrPane := CLR_HRED			
		EndIf
	ElseIf oSender == Self:oBtnGAdd
		Self:AddTableGroup()
		Self:PopTabGroups()
		Self:oLbxTabGroup:nAt := Len( Self:oLbxTabGroup:aArray)
		Self:oLbxTabGroup:Refresh()
	ElseIf oSender == Self:oBtnGRen
		Self:RenTableGroup()
		Self:PopTabGroups()
	ElseIf oSender == Self:oBtnGRem
		Self:RemTableGroup()
		Self:PopTabGroups()	
		LOJA1156WDB( @Self:aTableGroups ) //grava remocao no banco
	ElseIf oSender == Self:oBtnTAdd
		Self:AddTable()    
		Self:PopSeleTables()
	ElseIf oSender == Self:oBtnTRemove
		Self:RemoveTable()
		Self:PopSeleTables()
	ElseIf oSender == Self:oBtnTConfigure
		Self:ConTable()			
	ElseIf oSender == Self:oBtnMakeLoad
		If MsgYesNo( STR0045 ) // "Deseja iniciar a geração de carga?"
			Self:ResetState()
			Self:oWizard:oBack:Disable()
			Self:oWizard:oNext:Disable()
			Self:oWizard:oCancel:Disable()
			Self:oWizard:oFinish:Disable()
			Self:oBtnMakeLoad:Disable()
			Self:oBtnSaveLoad:Disable()
			
			//grava no banco os dados do grupo de carga utilizado. 
			//Passa o array como referencia pq qdo for uma inclusao, vai receber o valor do codigo na coluna 1
			LOJA1156WDB( @Self:aTableGroups )
			//cria uma replicacao do grupo de tabelas (template) registrando a carga que sera gerada
			LOJA1156WDB( {Self:aTableGroups[Self:oLbxTabGroup:nAt]}, .T., @Self:cCodInitialLoad )
			
			If Self:MakeInitialLoad() .AND. Valtype( Self:cCodInitialLoad ) == "C" //gera a carga de fato
				MsgAlert( STR0107 + Self:cCodInitialLoad)//"Carga gerada com sucesso. "
			EndIf
			
			Self:oWizard:oBack:Enable()
			Self:oWizard:oNext:Enable()
			Self:oWizard:oCancel:Enable()
			Self:oWizard:oFinish:Enable()
			Self:oBtnMakeLoad:Enable()
			Self:oBtnSaveLoad:Enable()
		EndIf
	ElseIf oSender == Self:oBtnSaveLoad
		//grava no banco os dados do grupo de carga utilizado. 
		//Passa o array como referencia pq qdo for uma inclusao, vai receber o valor do codigo na coluna 1
		LOJA1156WDB( @Self:aTableGroups )
		MsgAlert(STR0102)//"Configurações salvas com sucesso."
		
	EndIf
	
	If (FindFunction('FWIsProfile') .AND. !FWIsProfile() .AND. oLJCMessageManager:HasMessage() ) .OR.;
		(!FindFunction('FWIsProfile') .AND. oLJCMessageManager:HasMessage())
		oLJCMessageManager:Show( STR0046 ) // "Houve um erro ao tentar executar a operação."
		oLJCMessageManager:Clear()
	EndIf
Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} ListBoxSearch()

Efetua a procura de um termo em um determinado listbox. 

@param oListBox Listbox onde será efetuada a procura
@param cTerm Termo a ser procurado

@return nLocalizedLine Linha localizada

@author Vendas CRM
@since 07/02/10
/*/
//-------------------------------------------------------------------------------- 
Method ListBoxSearch( oListBox, cTerm ) Class LJCInitialLoadMakerWizard
	Local nCount1 			:= 0
	Local nCount2 			:= 0
	Local nLocalizedLine	:= -1  	
	Local lLocalized		:= .F.
	Local nPos				:= 0
	Local nICount1			:= 1
	Local nICount2			:= 1
	Static aHistory
	
	If aHistory == NiL
		aHistory := {}
	EndIf
	
	If Len(aHistory) >= 1
		nPos := aScan( aHistory, {|x| x[1] == oListBox .And. x[2] == AllTrim(cTerm) } )
		If nPos > 0
			nICount1 := aHistory[nPos][3]
			nICount2 := aHistory[nPos][4]
			nICount1++
		Else
			aHistory := {}
		EndIf
	EndIf
	
	For nCount1 := nICount1 To Len( oListBox:aArray )
		For nCount2 := nICount2 To Len( oListBox:aArray[nCount1] )		
			If AllTrim(Upper(cTerm)) $ Upper(oListBox:aArray[nCount1][nCount2])
				nLocalizedLine	:= nCount1
				lLocalized		:= .T.
				If nPos > 0
					aHistory[nPos][3] := nCount1
					aHistory[nPos][4] := nCount2
				Else
					aAdd( aHistory, { oListBox, AllTrim(cTerm), nCount1, nCount2 } )
				EndIf
				Exit
			EndIf
		Next
		If lLocalized
			Exit
		EndIf
	Next
Return nLocalizedLine



//--------------------------------------------------------------------------------
/*/{Protheus.doc} AddTableGroup()

Adiciona um novo grupo de tabelas.         

@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method AddTableGroup() Class LJCInitialLoadMakerWizard
	Local aNewTableGroup	:= { "", "", "", LJCInitialLoadTransferTables():New(), "" }
	
	If Self:ConTableGroup( aNewTableGroup )	
		aAdd( Self:aTableGroups, aNewTableGroup )
		Self:lHasChange := .T.
	EndIf
Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} RenTableGroup()

Renomeia o grupo de tabelas. 

@return Nenhum

@author Vendas CRM
@since 07/02/10
/*/
//-------------------------------------------------------------------------------- 
Method RenTableGroup() Class LJCInitialLoadMakerWizard
	If Self:oLbxTabGroup:nAt > 0 .And. Self:oLbxTabGroup:nAt <= Len(Self:oLbxTabGroup:aArray)	
		Self:ConTableGroup( Self:aTableGroups[Self:oLbxTabGroup:nAt] )
		Self:lHasChange := .T.
	EndIf
Return
	


//--------------------------------------------------------------------------------
/*/{Protheus.doc} RemTableGroup()

Remove um grupo de tabelas

@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method RemTableGroup() Class LJCInitialLoadMakerWizard
	If Self:oLbxTabGroup:nAt > 0 .And. Self:oLbxTabGroup:nAt <= Len(Self:oLbxTabGroup:aArray)	.And. Self:oLbxTabGroup:nAt <= Len(Self:aTableGroups)
		aDel( Self:aTableGroups, Self:oLbxTabGroup:nAt )
		aSize( Self:aTableGroups, Len( Self:aTableGroups ) - 1 )
		Self:lHasChange := .T.
	EndIf
Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ConTableGroup()

Exibe a janela de manutenção do grupo de tabelas.     

@param aTableGroup Grupo de tabelas a ser alterado/incluido.
@return lSave Se houve alteração no grupo de tabelas passado por parâmetro.

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method ConTableGroup( aTableGroup ) Class LJCInitialLoadMakerWizard
	Local oDlgConfigureGroupTable	:= Nil
	Local oBtnCancel   			:= Nil
	Local oBtnSave				:= Nil
	Local oGetName				:= Nil
	Local cGetName				:= PadR( aTableGroup[2], 200 )	
	Local oGetDescription			:= Nil
	Local cGetDescription			:= PadR( aTableGroup[3], 200 )
	Local oLblDescription			:= Nil
	Local oLblName				:= Nil
	Local oTipoIntInc				:= Nil
	Local nTipoIncInc				:= 0  //tipo da carga (1 = inteira, 2 = incremental)
	Local lSave						:= .F.
	
	DEFINE MSDIALOG oDlgConfigureGroupTable TITLE STR0025 FROM 000, 000  TO 165, 200 COLORS 0, 16777215 PIXEL	// "Configurar grupo de tabelas"
	
	@ 006, 005 SAY oLblName PROMPT STR0026 SIZE 017, 007 OF oDlgConfigureGroupTable COLORS 0, 16777215 PIXEL	// "Nome:"
	@ 005, 032 MSGET oGetName VAR cGetName SIZE 060, 010 OF oDlgConfigureGroupTable COLORS 0, 16777215 PIXEL
	@ 020, 005 SAY oLblDescription PROMPT STR0030 SIZE 025, 007 OF oDlgConfigureGroupTable COLORS 0, 16777215 PIXEL		// "Descrição:"
	@ 019, 032 MSGET oGetDescription VAR cGetDescription SIZE 060, 010 OF oDlgConfigureGroupTable COLORS 0, 16777215 PIXEL
	@ 035, 032 RADIO oTipoIntInc VAR nTipoIncInc 3D SIZE 055, 10 PROMPT STR0094, STR0095 OF oDlgConfigureGroupTable // 'Carga Inteira', 'Carga Incremental'
	@ 060, 010 BUTTON oBtnSave PROMPT STR0066 SIZE 037, 012 OF oDlgConfigureGroupTable PIXEL ACTION ( lSave := .T., (IIF(nTipoIncInc <> 0, oDlgConfigureGroupTable:End(), Alert("Selecione um tipo de carga (Inteira ou Incremental)")))  )	// "Salvar"
	@ 060, 050 BUTTON oBtnCancel PROMPT STR0067 SIZE 037, 012 OF oDlgConfigureGroupTable PIXEL ACTION ( lSave := .F., oDlgConfigureGroupTable:End()	)	// "Cancelar"
	
	ACTIVATE MSDIALOG oDlgConfigureGroupTable CENTERED
	
	If lSave
		aTableGroup[2] := cGetName
		aTableGroup[3] := cGetDescription
		aTableGroup[5] := cValtoChar(nTipoIncInc)
	EndIf
Return lSave



//--------------------------------------------------------------------------------
/*/{Protheus.doc} GetStrArrayOf()

Cria uma array de strings vazias com o tamanho solicitado.  
Usado normalmente para configurar o bLine de ListBoxes vazios.

@param nSize Tamaho desejado do array.
@return aEmptyStrArray: Array de strings com o tamanho desejado

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method GetStrArrayOf( nSize ) Class LJCInitialLoadMakerWizard
	Local aEmptyStrArray 	:= Array(nSize)
	Local nCount			:= nSize

	For nCount := 1 To Len( aEmptyStrArray )
		aEmptyStrArray[nCount] := ""
	Next	
Return aEmptyStrArray



//--------------------------------------------------------------------------------
/*/{Protheus.doc} GetDefaultListFor()

Pega um array de strings para um determinado listbox. 

@param oLbx Listbox utilizado para determinar o tamanho da array de strings.
@return aRet: Array de strings vazias para o ListBox oLbx.

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method GetDefaultListFor( oLbx ) Class LJCInitialLoadMakerWizard	
Return Self:GetStrArrayOf( Len(oLbx:aHeaders) )


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ConLbxDefault()

Faz a configuração inicial de um ListBox. 

@param oLbx: Listbox a ser configurado
@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method ConLbxDefault( oLbx ) Class LJCInitialLoadMakerWizard
	oLbx:SetArray( { Self:GetDefaultListFor( oLbx ) } )
	oLbx:bLine := {|| oLbx:aArray[Len(oLbx:aArray)] }
	oLbx:Refresh()
Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} ConLbxArray()

Faz a configuração de um ListBox com uma array especifica.   

@param oLbx: Listbox a ser configurado.
@param aArray: Array com os itens do ListBox
@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method ConLbxArray( oLbx, aArray ) Class LJCInitialLoadMakerWizard
	Local nValidAt := -1
	
	If Len( aArray ) > 0
		If oLbx:nAt > Len(aArray)
			oLbx:nAt := Len(aArray)
		ElseIf nValidAt < 1
			oLbx:nAt := 1
		EndIf
		oLbx:SetArray( aArray )
		oLbx:bLine := {|| If( oLbx:nAt > 0, oLbx:aArray[oLbx:nAt], Self:GetDefaultListFor(oLbx) ) }
		oLbx:Refresh()		
	Else
		Self:ConLbxDefault( oLbx )
	EndIf	
Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} PopTabGroups()

Popula o ListBox com a lista dos grupos de tabelas disponíveis

@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method PopTabGroups() Class LJCInitialLoadMakerWizard
	Self:oLbxTabGroup:SetArray( Self:aTableGroups )
	Self:oLbxTabGroup:bLine := { || If( Len( Self:oLbxTabGroup:aArray ) > 0, ;
		{ Self:oLbxTabGroup:aArray[Self:oLbxTabGroup:nAt][TGCODE],;
			 IIF(Self:oLbxTabGroup:aArray[Self:oLbxTabGroup:nAt][TGTYPE] = '2', STR0096, STR0097),; 
			 Self:oLbxTabGroup:aArray[Self:oLbxTabGroup:nAt][TGNAME],;
			 Self:oLbxTabGroup:aArray[Self:oLbxTabGroup:nAt][TGDESC]},;			
		{ "", "", "", "" } ) }
Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} AddGroup()

Popula o ListBox com a lista das tabelas disponíveis para a seleção.

@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method PopAvalTables() Class LJCInitialLoadMakerWizard
Local aAvaliableTables	:= {}

DbSelectArea( "SX2" )
DbSetOrder(1)
DbGoTop()

While !SX2->(EOF())
	aAdd( aAvaliableTables, {FWX2CHAVE(), FWX2Nome(FWX2CHAVE())} )
	SX2->(DbSkip())
End
	
	// Tabelas que não estão no SX5
	aAdd( aAvaliableTables, { "SX6", STR0068 } ) // "Parâmetros"
	
	If FindFunction('FWIsProfile') .and. FWIsProfile()
		aAdd( aAvaliableTables, { "SX1", "Perguntas" } ) // ""
		aAdd( aAvaliableTables, { "SX2", "Tabelas" } ) // ""
		aAdd( aAvaliableTables, { "SX3", "Campos" } ) // ""
		aAdd( aAvaliableTables, { "SX7", "Gatilhos" } ) // ""
		aAdd( aAvaliableTables, { "SXA", "Pastas de Cadastro" } ) // ""
		aAdd( aAvaliableTables, { "SXB", "Consulta Padrão" } ) // ""
		aAdd( aAvaliableTables, { "SXG", "Grupo de Campos" } ) // ""
		aAdd( aAvaliableTables, { "SIX", "Índices" } ) // ""
		
		If SX1->(FieldPos("X1_IDFIL")) > 0
			aAdd( aAvaliableTables, { "SXQ", "Filtros" } ) // ""
		EndIf
	EndIf
	
aSort( aAvaliableTables, , , { |x, y| x[1] < y[1] } )

Self:ConLbxArray( Self:oLbxAvalTables, aAvaliableTables )
Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} PopSeleTables()

Popula o ListBox com a lista das tabelas selecionadas.


@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method PopSeleTables() Class LJCInitialLoadMakerWizard
	Local nCount				:= 0
	Local aSelectedTables		:= {}
	
	For nCount := 1 To Len( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables )
		aAdd( aSelectedTables, Self:GetDefaultListFor(Self:oLbxSeleTables) )
		
		aSelectedTables[Len(aSelectedTables)][1] := Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables[nCount]:cTable
		aSelectedTables[Len(aSelectedTables)][2] := FWX2Nome( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables[nCount]:cTable )
		
		If Lower(GetClassName( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables[nCount] )) == Lower("LJCInitialLoadCompleteTable")
			aSelectedTables[Len(aSelectedTables)][3] := STR0069 // "Completo"
		ElseIf Lower(GetClassName( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables[nCount] )) == Lower("LJCInitialLoadPartialTable")
			aSelectedTables[Len(aSelectedTables)][3] := STR0070 // "Parcial"
		ElseIf Lower(GetClassName( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables[nCount] )) == Lower("LJCInitialLoadSpecialTable")				
			aSelectedTables[Len(aSelectedTables)][3] := STR0071 // "Especial"
		EndIf
	Next	
	
	Self:ConLbxArray( Self:oLbxSeleTables, aSelectedTables )
Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} AddTable()

Adiciona uma nova tabela na lista de tabelas selecionadas.


@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method AddTable() Class LJCInitialLoadMakerWizard
	Local nMode				:= 0
	Local cSelectedTable	:= ""
	Local oTable			:= Nil
	Local lShowComplete		:= .T.
	Local lShowPartial		:= .T.
	Local lShowSpecial		:= .F.
	Local oFactory			:= LJCInitialLoadSpecialTableFactory():New()
	Local lAddAI0			:= .F. //Adiciona AI0
	
	If Self:oLbxAvalTables:nAt > 0 .And. Self:oLbxAvalTables:nAt <= Len(Self:oLbxAvalTables:aArray)	
		cSelectedTable := AllTrim(Self:oLbxAvalTables:aArray[Self:oLbxAvalTables:nAt][1])
		
		If Left(cSelectedTable,2) == "SX" .Or. Left(cSelectedTable,2) == "XX"
			lShowComplete := .F.
		EndIf
		
		If cSelectedTable == "SA1" .AND. MsgYesNo(STR0108)//"Deseja Adicionar Tabela Complemento de Cliente AI0"
			lAddAI0 := .T.
		EndIf
		
		
		If oFactory:IsSpecial( cSelectedTable )
			lShowSpecial 	:= .T.
			lShowComplete	:= .F.
			lShowPartial 	:= .F.
		EndIf
			
		nMode := Self:SelectMode( lShowComplete, lShowPartial, lShowSpecial )
	
		If nMode == 1
			oTable := LJCInitialLoadCompleteTable():New()
			oTable:cTable := cSelectedTable
			If Self:ConCompleteTable( oTable )
				Self:lHasChange := .T.
				aAdd( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables, oTable ) 
			EndIf
			If lAddAI0
				oTable := LJCInitialLoadCompleteTable():New()
				oTable:cTable := "AI0"
				If Self:ConCompleteTable( oTable )
					Self:lHasChange := .T.
					aAdd( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables, oTable ) 
				EndIf				
			EndIf
		ElseIf nMode == 2
			oTable := LJCInitialLoadPartialTable():New()		
			oTable:cTable := cSelectedTable
			If Self:ConPartialTable( oTable )
				Self:lHasChange := .T.
				aAdd( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables, oTable ) 
			EndIf	
			If lAddAI0
				oTable := LJCInitialLoadPartialTable():New()		
				oTable:cTable := 'AI0"
				If Self:ConPartialTable( oTable )
					Self:lHasChange := .T.
					aAdd( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables, oTable ) 
				EndIf	
			EndIf
		ElseIf nMode == 3
			oTable := LJCInitialLoadSpecialTable():New()		
			oTable:cTable := cSelectedTable
			If Self:ConSpecialTable( oTable )
				Self:lHasChange := .T.
				aAdd( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables, oTable ) 
			EndIf		
		EndIf
	EndIf
Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} RemoveTable()

Remove uma tabela da lista de tabelas selecionadas. 

@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method RemoveTable() Class LJCInitialLoadMakerWizard
	If Self:oLbxSeleTables:nAt > 0 .And. Self:oLbxSeleTables:nAt <= Len(Self:oLbxSeleTables:aArray) .And. Self:oLbxSeleTables:nAt <= Len(Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables)
		cSelectedTable := AllTrim(Self:oLbxSeleTables:aArray[Self:oLbxSeleTables:nAt][1])
	
		Self:lHasChange := .T.		
		aDel( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables, Self:oLbxSeleTables:nAt )
		aSize( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables, Len(Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables) - 1 )
	EndIf	
Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} ConTable()

Seleciona e exibe a configurados ideal para o tipo de tabela a ser adicionado.

@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method ConTable() Class LJCInitialLoadMakerWizard
	If !Empty(Self:oLbxSeleTables:AARRAY[1][1]) .And. Self:oLbxSeleTables:nAt <= Len(Self:oLbxSeleTables:aArray)	
		If Lower(GetClassName( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables[Self:oLbxSeleTables:nAt] )) == Lower("LJCInitialLoadCompleteTable")
			If Self:ConCompleteTable( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables[Self:oLbxSeleTables:nAt] )
				Self:lHasChange := .T.
			EndIf
		ElseIf Lower(GetClassName( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables[Self:oLbxSeleTables:nAt] )) == Lower("LJCInitialLoadPartialTable")
			If Self:ConPartialTable( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables[Self:oLbxSeleTables:nAt] )
				Self:lHasChange := .T.
			EndIf
		ElseIf Lower(GetClassName( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables[Self:oLbxSeleTables:nAt] )) == Lower("LJCInitialLoadSpecialTable")				
			If Self:ConSpecialTable( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables[Self:oLbxSeleTables:nAt] )
				Self:lHasChange := .T.
			EndIf
		EndIf						
	EndIf
Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} ConCompleteTable()

Exibe o diálogo de configuração de uma tabela completa.  

@param  oCompleteTable Objeto do tipo LJCInitialLoadCompleteTable. 
@return  lSave Se houve alteração na tabela configurada

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method ConCompleteTable( oCompleteTable ) Class LJCInitialLoadMakerWizard
	Local oDlgConfigure		:= Nil
	Local oLblTableName		:= Nil	
	Local oTableName		:= Nil	
	Local oLblFilter		:= Nil	
	Local oFilter			:= Nil
	Local cFilter			:= PaDR(oCompleteTable:cFilter,200)
	Local oBtnWizard		:= Nil	
	Local oLbxBranches		:= Nil
	Local nLbxBranches		:= 0
	Local oLblBranches		:= Nil
	Local oLblObs			:= Nil
	Local oBtnSave			:= Nil
	Local oBtnCancel		:= Nil
	Local lSave				:= .F.
	Local aBranches			:= {}
	Local nCount			:= 0
	Local aNewBranches		:= {}
	Local lExclusiveTable	:= AllTrim(FWModeAccess(oCompleteTable:cTable, 3)) ==  "E" //Verifica se o tabela é exclusiva
	Local oGetFilial		:= Nil  								
	Local cFilDigita		:= Space(12)								
	Local oBtnSelFil		:= Nil 									
	Local oChkAllFil		:= Nil 									
	Local lChkAllFil		:= Nil 
	

	
	DEFINE MSDIALOG oDlgConfigure TITLE STR0072 FROM 000, 000  TO 330, 360 COLORS 0, 16777215 PIXEL // "Configurar transferência completa"

	@ 005, 005 SAY oLblTableName PROMPT STR0041 SIZE 020, 007 OF oDlgConfigure  PIXEL	// "Tabela:"
	@ 005, 025 SAY oTableName PROMPT oCompleteTable:cTable SIZE 038, 007 OF oDlgConfigure PIXEL	
	@ 015, 005 SAY oLblFilter PROMPT STR0073 SIZE 015, 007 OF oDlgConfigure PIXEL // "Filtro:"
	@ 015, 020 GET oFilter VAR cFilter OF oDlgConfigure MULTILINE SIZE 092, 040 HSCROLL PIXEL READONLY
	@ 015, 120 BUTTON oBtnWizard PROMPT STR0074 SIZE 037, 012 OF oDlgConfigure PIXEL ACTION (cFilter := BuildExpr( oCompleteTable:cTable,, @cFilter ))	// "Assistente"

	@ 085, 005 SAY oLblObs PROMPT STR0101 SIZE 170, 007 OF oDlgConfigure PIXEL	 // "Para tabelas compartilhadas não será possível selecionar a filial."
	@ 095, 005 SAY oLblBranches PROMPT STR0075 SIZE 015, 007 OF oDlgConfigure PIXEL	 // "Filiais:"
	@ 095, 020 LISTBOX oLbxBranches Fields Header "", STR0027, STR0028, STR0029 When lExclusiveTable Size 150, 048 Pixel Of oDlgConfigure ON DBLCLICK ( oLbxBranches:aArray[oLbxBranches:nAt][1] := !oLbxBranches:aArray[oLbxBranches:nAt][1], oLbxBranches:Refresh() )
	@ 150, 070 BUTTON oBtnSave PROMPT STR0066 SIZE 037, 012 OF oDlgConfigure ACTION (If(Loj1149Vld(lExclusiveTable,oLbxBranches:aArray),(lSave := .T., aBranches := oLbxBranches:aArray, oDlgConfigure:End()),Nil)) PIXEL	// "Salvar"	
	@ 150, 130 BUTTON oBtnCancel PROMPT STR0067 SIZE 037, 012 OF oDlgConfigure ACTION oDlgConfigure:End() PIXEL	 // "Cancelar"

	If lExclusiveTable
		@ 070, 005 SAY oFilial PROMPT STR0120 SIZE 020, 012 OF oDlgConfigure PIXEL //"Filial:"	 
		@ 067, 028 GET  oGetFilial VAR  cFilDigita  OF oDlgConfigure PIXEL SIZE 040, 012 PIXEL VALID Len(cFilDigita) > 0  
		@ 068, 070 BUTTON oBtnSelFil PROMPT STR0119 SIZE 030, 012 OF oDlgConfigure PIXEL ACTION (Lj1149SlFi(oLbxBranches, @cFilDigita), oGetFilial:SetFocus())	// "Selecionar"
		@ 098, 025 CHECKBOX oChkAllFil VAR  lChkAllFil SIZE 007, 007 OF  DIALOG oDlgConfigure  ON CHANGE (Lj1149CkAl(oLbxBranches, lChkAllFil), oLbxBranches:Refresh()) PIXEL 
	Endif 

	DbSelectArea( "SM0" )
	DbSetOrder(1)
	DbGoTop()
	
	aBranches := {}
	While !SM0->(EOF())
		If cEmpAnt == SM0->M0_CODIGO
			aAdd( aBranches, { If(aScan( oCompleteTable:aBranches, {|x| x == AllTrim(SM0->M0_CODFIL)}) > 0,.T.,.F.), AllTrim(SM0->M0_CODIGO), AllTrim(SM0->M0_CODFIL), AllTrim(SM0->M0_NOME) } )		
		EndIf
		SM0->(DbSkip())
	End
	
	oLbxBranches:SetArray( aBranches )
	oLbxBranches:bLine := {||	{	If( aBranches[oLbxBranches:nAt][1], LoadBitmap( GetResources(), "LBOK" ), LoadBitmap( GetResources(), "LBNO" ) ),;
									aBranches[oLbxBranches:nAt][2],;
									aBranches[oLbxBranches:nAt][3],;
									aBranches[oLbxBranches:nAt][4];
								} }								
	
	ACTIVATE MSDIALOG oDlgConfigure CENTERED
	
	If lSave
		oCompleteTable:cFilter := cFilter		
		
		If lExclusiveTable
			aNewBranches := {}
			For nCount := 1 To Len( aBranches )
				If aBranches[nCount][1]
					aAdd( aNewBranches, aBranches[nCount][3] )
				EndIf
			Next
			oCompleteTable:aBranches := aNewBranches
		Else
			oCompleteTable:aBranches := { xFilial(oCompleteTable:cTable) }
		EndIf
	EndIf
	
	
Return lSave



//--------------------------------------------------------------------------------
/*/{Protheus.doc} ConPartialTable()

Exibe o diálogo de configuração de uma tabela parcial. 

@param oPartialTable Objeto do tipo LJCInitialLoadPartialTable
@return lSave Se houve alteração na tabela configurada.

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method ConPartialTable( oPartialTable ) Class LJCInitialLoadMakerWizard

Local oDlgConfigure			:= Nil
Local oBtnAdd				:= Nil
Local oBtnCancel			:= Nil
Local oBtnRemove			:= Nil
Local oBtnSave				:= Nil
Local oBtnWizard			:= Nil
Local oCmbIndex				:= Nil
Local nCmbIndex				:= 1
Local oGetFilter			:= Nil
Local cGetFilter			:= PadR(oPartialTable:cFilter, 200)
Local oGetRecord			:= Nil
Local cGetRecord			:= Space(200)
Local oGrpFilter			:= Nil
Local oGrpRecords			:= Nil
Local oLblIndex				:= Nil
Local oLblRecord			:= Nil
Local oLblTableName			:= Nil
Local oLbxSelectedRecords	:= Nil
Local oTableName			:= Nil
Local lSave					:= .F.
Local aIndexes				:= {}
Local nCount				:= 0
Local cIndexKey				:= ""
Local aRecords				:= {}
Local oTpFiltro				:= Nil
Local nTpFiltro				:= 0

// Determina os índices para a tabela oPartialTable:cTable
DbSelectArea( oPartialTable:cTable )
nCount := 1
While !Empty((cIndexKey := IndexKey(nCount)))
	aAdd( aIndexes, cIndexKey )
	nCount++
End

DEFINE MSDIALOG oDlgConfigure TITLE STR0076 FROM 000, 000  TO 290, 687 COLORS 0, 16777215 PIXEL	// "Configurar transferência parcial"

@ 005, 005 SAY oLblTableName PROMPT STR0041 SIZE 020, 007 OF oDlgConfigure COLORS 0, 16777215 PIXEL	// "Tabela"
@ 005, 025 SAY oTableName PROMPT oPartialTable:cTable SIZE 048, 007 OF oDlgConfigure COLORS 0, 16777215 PIXEL

@ 015, 005 GROUP oGrpRecords TO 035, 340 PROMPT STR0115 OF oDlgConfigure COLOR 0, 16777215 PIXEL // "Selecione o tipo de filtro:"
@ 023, 010 RADIO oTpFiltro VAR nTpFiltro SIZE 390, 10 PROMPT STR0116, STR0117 ON CHANGE Lj1149RdBt(@nTpFiltro, @oTpFiltro, @oGetRecord, @oBtnAdd, @oBtnRemove, @oBtnWizard) OF oDlgConfigure PIXEL // "por Indice / por Expressão"
	oTpFiltro:lHoriz := .T.
	
@ 037, 005 GROUP oGrpRecords TO 140, 200 PROMPT STR0080 OF oDlgConfigure COLOR 0, 16777215 PIXEL // "Chave"
@ 046, 010 SAY oLblIndex PROMPT STR0081 SIZE 020, 007 OF oDlgConfigure COLORS 0, 16777215 PIXEL // "Índice:"
@ 045, 027 MSCOMBOBOX oCmbIndex VAR nCmbIndex ITEMS aIndexes SIZE 122, 010 OF oDlgConfigure COLORS 0, 16777215 PIXEL
@ 059, 010 SAY oLblRecord PROMPT STR0082 SIZE 025, 007 OF oDlgConfigure COLORS 0, 16777215 PIXEL // "Registro:"
@ 057, 032 MSGET oGetRecord VAR cGetRecord SIZE 116, 010 OF oDlgConfigure COLORS 0, 16777215 PIXEL
	oGetRecord:lActive := .F.
@ 044, 156 BUTTON oBtnAdd PROMPT STR0019 SIZE 037, 012 OF oDlgConfigure PIXEL ACTION ( aAdd( aRecords, { oCmbIndex:nAt, RTrim(cGetRecord) } ), Self:ConLbxArray( oLbxSelectedRecords, aRecords ), oLbxSelectedRecords:Refresh() )  // "Adicionar"
	oBtnAdd:lActive := .F.
@ 057, 156 BUTTON oBtnRemove PROMPT STR0021 SIZE 037, 012 OF oDlgConfigure PIXEL ACTION	(	;
																							IF( Len(aRecords) > 0,;
																								( aDel( aRecords, oLbxSelectedRecords:nAt), aSize ( aRecords, Len(aRecords) - 1 ), Self:ConLbxArray( oLbxSelectedRecords, aRecords ), oLbxSelectedRecords:Refresh() );
																							,;
																							);
																						)	// "Remover"
																						oBtnRemove:lActive := .F.
@ 075, 010 LISTBOX oLbxSelectedRecords FIELDS HEADER STR0078,STR0079 SIZE 185, 060 PIXEL OF oDlgConfigure // "Índice" "Registro"

@ 037, 202 GROUP oGrpFilter TO 125, 340 PROMPT "Expressão" OF oDlgConfigure COLOR 0, 16777215 PIXEL // "Filtro"
@ 059, 207 GET oGetFilter VAR cGetFilter OF oDlgConfigure MULTILINE SIZE 127, 058 COLORS 0, 16777215 HSCROLL PIXEL READONLY
@ 044, 207 BUTTON oBtnWizard PROMPT STR0083 SIZE 037, 012 OF oDlgConfigure PIXEL  ACTION (cGetFilter := BuildExpr( oPartialTable:cTable,, @cGetFilter )) // "Assistente"
	oBtnWizard:lActive := .F.

@ 128, 255 BUTTON oBtnSave PROMPT STR0066 SIZE 037, 012 OF oDlgConfigure PIXEL ACTION (lSave := .T., aRecords := oLbxSelectedRecords:aArray, Lj1149VldS(@oDlgConfigure, nTpFiltro, oPartialTable, cGetFilter)) // "Salvar"
@ 128, 303 BUTTON oBtnCancel PROMPT STR0067 SIZE 037, 012 OF oDlgConfigure PIXEL ACTION (oDlgConfigure:End()) // "Cancelar"

// Configura os registros
aRecords := oPartialTable:aRecords
Self:ConLbxArray( oLbxSelectedRecords, aRecords )		

ACTIVATE MSDIALOG oDlgConfigure CENTERED

If lSave
	// Remove registros em branco
	For nCount := 1 To Len( aRecords )
		If Empty(aRecords[nCount][1]) .And. Empty(aRecords[nCount][2])
			aDel( aRecords, nCount )
			aSize( aRecords, Len( aRecords ) - 1 )
		EndIf
	Next

	If nTpFiltro == 1
		oPartialTable:cFilter := ""
		oPartialTable:aRecords := aRecords
	ElseIf nTpFiltro == 2
		oPartialTable:aRecords := {}
		oPartialTable:cFilter := cGetFilter
	EndIf
EndIf

Return lSave


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ConSpecialTable()

 elecione e exibide o dialogo de configuração da tabela especial.

@param oSpecialTable: Objeto do tipo LJCInitialLoadSpecialTable.      
@return lRet: Se houve alteração na tabela configurada.

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method ConSpecialTable( oSpecialTable ) Class LJCInitialLoadMakerWizard
	Local oFactory				:= LJCInitialLoadSpecialTableFactory():New()
	Local oLJCMessageManager	:= GetLJCMessageManager()	
	Local lRet					:= .F.
	Local oConfigurator			:= Nil
	
	oConfigurator := oFactory:GetConfiguratorByName( oSpecialTable:cTable )
	
	If !oLJCMessageManager:HasError()
		lRet := oConfigurator:Configure( oSpecialTable )
	EndIf
Return lRet



//--------------------------------------------------------------------------------
/*/{Protheus.doc} CheckSelectedGroup()

Verifica se foi selecionado algum grupo de tabela. 

@return lRet: Se foi selecionado ou não algum grupo de tabela

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method CheckSelectedGroup() Class LJCInitialLoadMakerWizard
	Local lRet := Self:oLbxTabGroup:nAt > 0 .And. Self:oLbxTabGroup:nAt <= Len(Self:oLbxTabGroup:aArray)	.And. Self:oLbxTabGroup:nAt <= Len(Self:aTableGroups)
	
	If !lRet
		Alert( STR0084 ) // "Selecione um grupo de tabelas"
	EndIf
Return lRet



//--------------------------------------------------------------------------------
/*/{Protheus.doc} ResetState()

Reinicializa as informações da geração da carga  

@return Nenhum

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method ResetState() Class LJCInitialLoadMakerWizard
	Self:oLblState:SetText("")
	Self:oLblTable:SetText("")
	Self:oLblSpeed:SetText("")
	Self:oLblProgress:SetText("")
	Self:oMeter:Set(0)
Return .T.


//--------------------------------------------------------------------------------
/*/{Protheus.doc} MakeInitialLoad()

Executa a geração de carga. 

@return lRet //Controla se gerou a carga corretamente.

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Method MakeInitialLoad() Class LJCInitialLoadMakerWizard
	Local oLJCMessageManager	:= GetLJCMessageManager()
	Local oLJInitialLoadMaker	:= Nil
	Local lRet := .F.				//Controla se gerou a carga corretamente.					
	
	If Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables == Nil .Or. Len( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE]:aoTables ) == 0
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadMakerWizardRequiredInformationError", 1, STR0050 ) ) // "Tabelas da carga inicial não informadas."
	EndIf	
	
	// Valida as informações necessárias para a criação da carga inicial           
	If Empty(Self:cPathOfRepository)
		oLJCMessageManager:ThrowMessage( LJCMessage():New( "LJCInitialLoadMakerWizardRequiredInformationError", 1, STR0049 ) ) // "Caminho do reposiório do servidor de arquivo não configurado."
	EndIf
	
	If !oLJCMessageManager:HasError()
		oLJInitialLoadMaker := LJCInitialLoadMaker():New( Self:cPathOfRepository + Self:cCodInitialLoad ) //concatena no path o codigo da carga 	
		oLJInitialLoadMaker:SetTransferTables( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE] )
		oLJInitialLoadMaker:SetExportType( Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTYPE] )
		oLJInitialLoadMaker:SetCodInitialLoad( Self:cCodInitialLoad )
		oLJInitialLoadMaker:AddObserver( Self )
		lRet := oLJInitialLoadMaker:Execute()
		If ValType(lRet) <> "L"
			lRet := .F.
		EndIf					
	EndIf
	
	If !oLJCMessageManager:HasError()	
		LJ1156XMLResult() //gera um xml atualizado com as atuais cargas disponiveis		
	EndIf
	
Return lRet    



//--------------------------------------------------------------------------------
/*/{Protheus.doc} Update()

Atualiza o progresso de geração de carga.     

@param oMakerProgress: Objeto LJCInitialLoadMakerProgress   
@return Nenhum

@author Vendas CRM
@since 07/02/10
/*/
//-------------------------------------------------------------------------------- 
Method Update( oMakerProgress ) Class LJCInitialLoadMakerWizard
	Do Case
		Case oMakerProgress:nStatus == 1
			Self:oLblState:SetText( STR0052 ) // "Iniciado"
		Case oMakerProgress:nStatus == 2
			Self:oLblState:SetText( STR0053 ) // "Exportando"
		Case oMakerProgress:nStatus == 3
			Self:oLblState:SetText( STR0054 ) // "Compactando"
		Case oMakerProgress:nStatus == 4
			Self:oLblState:SetText( STR0055 ) // "Finalizado"
		Case oMakerProgress:nStatus == 5
			Self:oLblState:SetText( STR0098 ) // "Analisando tabela a exportar"
		Case oMakerProgress:nStatus == 6
			Self:oLblState:SetText( STR0099 ) // "Atualizando registros exportados"

			
			
	EndCase
	
	If ValType(oMakerProgress:aTables) != "U"
		If Len(oMakerProgress:aTables) > 0 .And. (oMakerProgress:nActualTable >= 0 .And. oMakerProgress:nActualTable <= Len(oMakerProgress:aTables) )
			Self:oLblTable:SetText( oMakerProgress:aTables[oMakerProgress:nActualTable] + " (" + AllTrim(Str(oMakerProgress:nActualTable)) + "/" + AllTrim(Str(Len(oMakerProgress:aTables))) + ")" )
		EndIf
	EndIf
	
	If ValType( oMakerProgress:nActualRecord ) != "U" .And. ValType(oMakerProgress:nTotalRecords) != "U"
		If oMakerProgress:nActualRecord > 0 .And. oMakerProgress:nTotalRecords > 0
			Self:oLblProgress:SetText( AllTrim(Str(oMakerProgress:nActualRecord)) + "/" + AllTrim(Str(oMakerProgress:nTotalRecords)) + " (" + AllTrim(Str(Round((oMakerProgress:nActualRecord*100)/oMakerProgress:nTotalRecords,2))) + "%)" )
			
			Self:oMeter:Set( (oMakerProgress:nActualRecord*100)/oMakerProgress:nTotalRecords )
			Self:oMeter:SetTotal(100)		
		EndIf
	EndIf
	
	If ValType( oMakerProgress:nRecordsPerSecond ) != "U"
		Self:oLblSpeed:SetText( AllTrim(Str(oMakerProgress:nRecordsPerSecond)) + "r/s" )
	EndIf

Return      
      


//--------------------------------------------------------------------------------
/*/{Protheus.doc} SelectMode()

Exibe o diálogo de seleção do tipo de tabela que deve ser incluída. 

@param lShowComplete: Se deve ser exibido o botão do tipo "Completo".
@param lShowPartial: Se deve ser exibido o botão do tipo "Parcial". 
@param lShowSpecial: Se deve ser exibido o botão do tipo "Especial".  
@return nMode: Tipo de tabela selecionado. 

@author Vendas CRM
@since 07/02/10
/*/
//-------------------------------------------------------------------------------- 
Method SelectMode( lShowComplete, lShowPartial, lShowSpecial ) Class LJCInitialLoadMakerWizard
	Local oDlgII				:= Nil
	Local oFntTit				:= Nil
	Local oFntMsg				:= Nil
	Local oBmp					:= Nil
	Local oMsgDet				:= Nil
	Local nMode					:= 0
	Local cMessage				:= STR0085 + Chr(13) + Chr(10) + STR0086 + Chr(13) + Chr(10) + STR0087 // "Completo - Substitui a tabela de destino;" "Parcial - Transfere somente os registros selecionados;" "Especial - Transferências pré-desenvolvidas para tabelas especiais"
	
	Default lShowComplete	:= .T.
	Default lShowPartial	:= .T.
	Default lShowSpecial	:= .F.
	
	DEFINE MSDIALOG oDlgII TITLE STR0088 FROM 0,0 TO 135,600 PIXEL // "Selecione o modo de transferência."
	
	DEFINE FONT oFntTit NAME "Arial"  SIZE 6,16	BOLD
	DEFINE FONT oFntMsg NAME "Arial"  SIZE 5,15
	
	@ 0,0  BITMAP oBmp RESNAME "LOGIN" oF oDlgII SIZE 100,600 NOBORDER WHEN .F. PIXEL
	@05,50 TO 45,300 PROMPT STR0089 PIXEL // "Informação"
	@11,52 GET cMessage FONT oFntMsg MULTILINE NOBORDER READONLY HSCROLL SIZE 245,30 PIXEL
	
	@50,80 BUTTON STR0090 PIXEL ACTION (nMode := 1, oDlgII:End()) WHEN lShowComplete // "Completo"
	@50,160 BUTTON STR0091 PIXEL ACTION (nMode := 2,  oDlgII:End()) WHEN lShowPartial // "Parcial"
	@50,230 BUTTON STR0051 PIXEL ACTION (nMode := 3,  oDlgII:End())	WHEN lShowSpecial // "Especial"
	
	ACTIVATE MSDIALOG oDlgII CENTERED
Return nMode

//--------------------------------------------------------------------------------
/*/{Protheus.doc} SetOnlyView()


@author 
@since 
/*/
//-------------------------------------------------------------------------------- 
Method SetOnlyView( lRet ) Class LJCInitialLoadMakerWizard
If lRet
	::oBtnTAdd:Disable()
	::oBtnTRemove:Disable()
	::oBtnTConfigure:Disable()
Else
	::oBtnTAdd:Enable()
	::oBtnTRemove:Enable()
	::oBtnTConfigure:Enable()
EndIf
Return 


//--------------------------------------------------------------------------------
/*/{Protheus.doc} Loj1149Vld()

 Efetua validacao ao clicar no botao SALVAR. 

@param oTable: Objeto do tipo LJCInitialLoadTable.
@return lRet

@author Vendas CRM
@since 16/10/10
/*/
//-------------------------------------------------------------------------------- 
Function Loj1149Vld(lExclusiveTable,aFils)
Local lRet := .T.
Local nI	:= 0

//Se for tabela Exclusiva (X2_MODO = E), verifica se selecionou pelo menos uma filial
If lExclusiveTable
	lRet := .F.
	
	For nI := 1 To Len(aFils)
		If aFils[nI][1] 
			lRet := .T.
			Exit
		EndIf
	Next nI
	
	If !lRet
		MsgAlert(STR0092) //"Pelo menos uma filial deve ser selecionada para esta tabela."
	EndIf			
EndIf

Return lRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} Lj1149TbPV()

Apresenta telinha para que o usuario informe a tabela de preco a ser considerada.
Ou seja, campo a ser considerado da tabela SB0 (B0_PRV1, B0_PRV2,...)

@param aTables: Array com a relacao de tabelas para geracao de carga.
@param nTabela: Numero da tabela de preco.
@return lRet: Retorna false (.F.) caso nao seja informada a tabela pelo usuario

@author Vendas CRM
@since 08/04/2013
/*/
//-------------------------------------------------------------------------------- 
Static Function Lj1149TbPV( aTables )
Local oDlg
Local oCmbBox
Local oBtnOK
Local lRet 		:= .T.
Local nPos 		:= aScan( aTables, { |x| x[1] == "SBI" } )
Local cOpcCmb 	:= "1"
Local aTabsPRV 	:= {"1","2","3","4","5","6","7","8","9"} //Tabelas de preco 1 a 9 (referente aos campos B0_PRV)
Local lConfirm 	:= .F.

//Caso a tabela SBI esteja na relacao de tabelas para geracao de carga
If nPos > 0
	cOpcCmb := cTabPRV
	
	DEFINE MSDIALOG oDlg TITLE STR0103 FROM  165,115 TO 300,600 PIXEL //"Seleção da tabela de preço"
		@ 03, 10 TO 43, 230 LABEL "" OF oDlg PIXEL
		@ 10, 15 SAY STR0104 SIZE 200, 8 OF oDlg PIXEL //"Selecione a tabela de preço a ser considerada na geração de carga da tabela SBI."
		
		@ 26, 15 SAY STR0013 SIZE 100, 8 OF oDlg PIXEL //"Tabela"
		@ 25, 40 MSCOMBOBOX oCmbBox VAR cOpcCmb ITEMS aTabsPRV SIZE 30, 10 OF oDlg PIXEL
		
		DEFINE SBUTTON oBtnOK FROM 50, 141 TYPE 1  ACTION (lConfirm := .T., cTabPRV := cOpcCmb, oDlg:End()  ) ENABLE OF oDlg ONSTOP STR0105 //"OK"
		oBtnOK:cCaption := STR0105 //"OK"
		DEFINE SBUTTON            FROM 50, 170 TYPE 2  ACTION (lConfirm := .F., oDlg:End()) ENABLE OF oDlg  //Botao Cancelar
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If !lConfirm
		MsgAlert(STR0106) //"Para prosseguir com a geração da carga, deve ser informada a tabela de preço a ser considerada para geração do preço na tabela SBI."
		lRet := .F.
	EndIf
EndIf

Return lRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} Lj1149Tab()

Retorna a tabela de preco selecionada para gerar o preco na tabela SBI.

@return nRetTab: Retorna a tabela de preco.

@author Vendas CRM
@since 08/04/2013
/*/
//-------------------------------------------------------------------------------- 
Function Lj1149Tab()
Return cTabPRV

//--------------------------------------------------------------------------------
/*/{Protheus.doc} Lj1149LdTb()

Preenche o aTableGroups com as tabelas MBV e MBX do Grupo de Carga Selecionado

@return Nenhum
@author eduardo.sales
@since  25/08/2018
/*/
//--------------------------------------------------------------------------------
Method Lj1149LdTb() Class LJCInitialLoadMakerWizard

Local oTransferTables	:= Nil
Local cTableGroup		:= ""
Local aArea     		:= GetArea()         //Area atual
Local aAreaMBU  		:= MBU->(GetArea())  //Area do MBU
Local aAreaMBV  		:= MBV->(GetArea())  //Area do MBV
Local aAreaMBX 			:= MBX->(GetArea())  //Area do MBX

DbSelectArea("MBU")
MBU->(dbGoTop())

DbSelectArea("MBV")
MBV->(dbGoTop())

DbSelectArea("MBX")
MBX->(dbGoTop())

If !(MBU->(EOF()) .AND. MBV->(EOF()) .AND. MBX->(EOF())) .and. MBU->MBU_TIPO = "1"
	
	cTableGroup := Self:aTableGroups[Self:oLbxTabGroup:nAt][TGCODE]

	// Preenche o objeto oTransferTables com a MBV e MBX (ou MBW) do Grupo de Tabelas selecionado.
	oTransferTables := LOJA1156RTG(cTableGroup)
	
	Self:aTableGroups[Self:oLbxTabGroup:nAt][TGTABLE] := oTransferTables

EndIf

RestArea(aAreaMBU)
RestArea(aAreaMBV)
RestArea(aAreaMBX)
RestArea(aArea)

Return .T.

// Função criada somente para validar no fonte LOJA1156 se o metodo Lj1149LdTb()
// esta implementado, através do ExistFunc.
Function Lj1149NwLd() ; Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj1149RdBt
Habilita e desabilita os campos de acordo com o tipo de filtro selecionado

@author  eduardo.sales
@since   08/01/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function Lj1149RdBt(nTpFiltro	, oTpFiltro	, oGetRecord	, oBtnAdd		,; 
					oBtnRemove	, oBtnWizard)

// Tratamento para Habilitar e Desabilitar campos de acordo com a Seleção do Tipo de Filtro
If nTpFiltro == 1
	oBtnWizard:lActive := .F.
	oGetRecord:lActive := .T.
	oBtnAdd:lActive := .T.
	oBtnRemove:lActive := .T.
ElseIf nTpFiltro == 2
	oBtnWizard:lActive := .T.
	oGetRecord:lActive := .F.
	oBtnAdd:lActive := .F.
	oBtnRemove:lActive := .F.
EndIf

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj1149VldS
Valida se os campos de filtro foram preenchidos, pois para carga parcial é 
necessário preencher algum filtro.

@author  eduardo.sales
@since   08/01/2021
@version P12
/*/
//-------------------------------------------------------------------
Static Function Lj1149VldS(oDlgConfigure, nTpFiltro, oPartialTable, cGetFilter)

If nTpFiltro == 0 .Or. ;
	nTpFiltro == 1 .And. Len(oPartialTable:aRecords) == 0 .Or. ;
	nTpFiltro == 2 .And. Empty(cGetFilter)

	MsgAlert(STR0118) // Para a carga parcial é preciso selecionar e preencher um dos tipos de filtro.
Else
	oDlgConfigure:End()
EndIf

Return Nil


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj1149SlFi
Marca/Desmarca na grid a filial digitada  
@param 		oLbxBranches : Objeto listbox das filiais
@param  	cFilDig 	 : Filial digitada
@return		Nil
@author 	caio.okamoto
@since  	03/08/2021
@version	P12
/*/
//-------------------------------------------------------------------
Static Function Lj1149SlFi(oLbxBranches, cFilDig )
Local nPos 	:= 0 

If Empty(cFilDig)
	MsgAlert(STR0121)//"Filial não foi informada!"
Else
	nPos := aScan( oLbxBranches:aArray, {|x| x[3] == AllTrim(cFilDig) } )
	If nPos > 0
		oLbxBranches:aArray[nPos][1] := !oLbxBranches:aArray[nPos][1]
		oLbxBranches:Refresh()
		oLbxBranches:nAT := nPos 
	Else 
		MsgAlert(STR0028 +" " + cFilDig + STR0122 )//"Filial não encontrada na lista!"
	Endif 
Endif 

cFilDig:= Space(12)

Return Nil 

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj1149CkAl
Marca/Desmarca todas as filiais da grid  
@param 		oLbxBranches :objeto listbox das filiais
@param		lChkAllFil   :parâmetro lógico define se marca ou desmarca todas as filiais
@return		Nil
@author  	caio.okamoto
@since   	03/08/2021
@version 	P12
/*/
//-------------------------------------------------------------------
Static Function Lj1149CkAl(oLbxBranches, lChkAllFil)
Local nX  := 0 

For nX:=1 to Len(oLbxBranches:aArray)
	oLbxBranches:aArray[nX][1] := lChkAllFil
Next nX 

Return Nil 
