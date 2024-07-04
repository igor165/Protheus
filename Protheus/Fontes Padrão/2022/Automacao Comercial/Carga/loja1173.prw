#INCLUDE "PROTHEUS.CH"
#INCLUDE "LOJA1173.CH"
#INCLUDE "COLORS.CH"

#INCLUDE "MSGRAPHI.CH"
#INCLUDE "DBTREE.CH"
#INCLUDE "PRCONST.CH"

#DEFINE ENTIRE "1"
#DEFINE INCREMENTAL "2"

//Indices do array das cargas (incremental e inteira)
#DEFINE LBINDEX	1 
#DEFINE LBCODE 	2
#DEFINE LBNAME 	3
#DEFINE LBCOLORST	4
#DEFINE LBSTATUS	5
#DEFINE LBDESC	6
#DEFINE LBDATE	7
#DEFINE LBHOUR	8
#DEFINE LBORDER	9


// O protheus necessita ter ao menos uma função pública para que o fonte seja exibido na inspeção de fontes do RPO.
Function LOJA1173() ; Return 



//-------------------------------------------------------------------
/*/{Protheus.doc} LJCInitialLoadSelector
Classe para selecao das cargas que serao importadas na requisicao
 
@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------

Class LJCInitialLoadSelector

	Data oLoadGroups				//lista de grupos de carga (LJCInitialLoadGroupConfig)
	Data oRequest					//requisicao de carga
	Data oGroupStatus				//Status de cada carga
	Data lShowStatus				//Define se mostra os status ou nao (quando vier do monitor e tiver varios ambientes selecionados, nao da pra mostrar o status por carga, o status teria que ser por ambiente por carga )
	Data lShowDelete				//define se mostra o botao de excluir uma carga
	Data aSelection				//array com as cargas selecionadas
	Data lExecute					//Determina se ira realizar o carregamento da carga ou apenas fechar a tela
	
	//Listbox
	Data oLbxEntire				//cargas inteiras 
	Data oLbxIncremental			//cargas incrementais
	Data oLbxTables				//Tabelas exportadas
	Data oLbxStatus				//Status carga/embiente
	
	//conteudo do listbox
	Data aEntireLoads				//cargas inteiras  
	Data aIncrementalLoads			//cargas incrementais
	Data aTables					//Tabelas exportadas
	
		
	Method New()
	Method Show()
	
	//selecionadores automaticos de cargas
	Method MarkIncLoad()		//seleciona as cargas pendentes (incrementais) em relacao ao ambiente, para atualizar td
	Method MarkEntire()		//seleciona as ultimas cargas inteiras da lista de grupos de cargas recebido
	
	//metodos da tela 
	Method ConfigLoadList() 	//configura o listbox de cargas
	Method ConfigTableList()	//configura o listbox de tabelas da carga 
	Method MakeGroupArray() 	//Monta o array dos grupos de carga
	Method MakeTableArray() 	//Monta o array das tabelas exportadas na carga
	Method ReverseItemSelection()
	Method SelectActions()//tela para marcar as acoes a serem executadas... download, importar, matar threads, aplicar nos filhos

	//facilitadores para marcar os checkbox das cargas
	Method SelectAll() 			//marcar ou desmarcar tudo - cargas inteiras ou incrementais
	Method SelectSpecificInc()		//marcar tipos especificos (soh pendentes, soh baixadas) - apenas cargas incrementais

	//auxiliares
	Method GetStatus() 	//pega o status da carga no ambiente cliente (se nao for passado nenhum cliente, pega local)
	Method DeleteLoad()	//Inicia processo para apagar uma carga (baseado nas cargas selecionadas em aSelection)
	Method CheckMBU()		//verifica se o ambiente eh o servidor (retaguarda) que gera as cargas
	Method DefineGroupStatusClient() //define o status das cargas do cliente passado por parametro
	
EndClass

//--------------------------------------------------------------------------------
/*/{Protheus.doc} New()

Construtor

@param oLoadGroups lista com os grupos de cargas
@param oRequest objeto da requisicao (LJCInitialLoadRequest)
@param lShowStatus determina se mostra o status das cargas no ambiente
@param lShowDelete determina se mostra os botoes para exclusao da carga

@return Self

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method New(oLoadGroups, oRequest, lShowStatus, lShowDelete) Class LJCInitialLoadSelector

Default lShowStatus := .T. //o padrao eh mostrar o status
Default lShowDelete := .F. //o padrao eh nao mostrar o botao de deletar cargas
	
Self:oLoadGroups 		:= oLoadGroups
Self:aSelection		:= Array( Len( oLoadGroups:aoGroups ) ) //define array de selecao com mesma qtde do array das cargas
Self:oRequest			:= oRequest
Self:lShowStatus		:= lShowStatus
Self:lShowDelete		:= lShowDelete

Self:aEntireLoads		:= {}  
Self:aIncrementalLoads	:= {}
Self:aTables			:= {}

aFill( Self:aSelection, .F. )

Self:lExecute			:= .F.

Self:DefineGroupStatusClient(nil)

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MarkIncLoad()


Marca todas as cargas incrementais para deixar o ambiente atualizado
Serao atualizadas (marcadas no array aSelection) todas as cargas que estiverem com status menor que a acao... 
ou seja todas as cargas pendentes daquela acao (independente da ordem)
Dessa forma, cargas puladas tambem serao atualizadas.
Importante: soh serao avaliadas cargas incrementais

Processo:
1)percorre todo o array de cargas ativas
2)para cada carga incremental, verifica o status no ambiente atraves da GetStatus(cCodeLoad)
3)analisa a acao a ser executada e o status atual
	Se acao = importar, marca carga se tiver status <> importado 
	Senao, Se acao = baixar, marca carga se tiver status = pendente 
	
obs: Status existentes -> Pendente / Baixado / Importado


@param oClient cliente, ambiente que sera feita as acoes
@param lUpdateComp Logico, Indica que mesmo que seja uma carga completa ela deve ser atualizada
@return nil

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------
Method MarkIncLoad(oClient, lUpdateComp) Class LJCInitialLoadSelector
Local nI	:= 0
Default lUpdateComp := .F.
If oClient <> Nil
	Self:DefineGroupStatusClient(oClient)
EndIf
 
If Self:oRequest <> Nil 

	For nI := 1 to Len(Self:oLoadGroups:aoGroups) //percorre lista de cargas existentes
		If Self:oLoadGroups:aoGroups[nI]:cEntireIncremental == "2" .Or. lUpdateComp //avalia a carga, se ela for incremental, ou eu realmente preciso que atualize todas as cargas.
			If (Self:oRequest:lImport) .AND. (Self:GetStatus(Self:oLoadGroups:aoGroups[nI]:cCode) <> "2") //se a acao marcada for importar, marca a carga se ela nao estiver importada
				Self:aSelection[nI] := .T.
				Self:lExecute := .T. //determina que ha cargar para atualizar
			ElseIf (Self:oRequest:lDownload) .AND. (Self:GetStatus(Self:oLoadGroups:aoGroups[nI]:cCode) == " ") //se a acao marcada for somente baixar, marca a carga se ela nao estiver nem como baixada nem como importada (se estiver pendente) 
				Self:aSelection[nI] := .T.
				Self:lExecute := .T. //determina que ha cargar para atualizar
			EndIf
		EndIf
	Next nI
	
	Self:oRequest:aSelection := Self:aSelection

EndIf



Return 

//--------------------------------------------------------------------------------
/*/{Protheus.doc} MarkEntire()

Busca as cargas inteiras dos grupos de cargas recebidos no parametro aEntireLoad. 
Se marcado para atualizar apenas os novos, avalia se a carga jah foi aplicada ao ambiente.
Marca apenas a ultima carga inteira daquele grupo
(marca array aSelection com mesmo indice do aoGroups)

@param aEntireLoad array com as cargas do tipo inteira
@param lOnlyIfNewer determina se marca somente as cargas mais novas
@param oClient cliente que recebera as acoes

@return nil

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method MarkEntire(aEntireLoad, lOnlyIfNewer, oClient) Class LJCInitialLoadSelector

Local nI	:= 0
Local nJ	:= 0
Local nAuxLoadMark := 0 //contador para cada carga do grupo (utilizado para saber se essa eh a primeira carga a ser marcada ou nao)
Local nOldIndex := 0   //indice da ultima carga desse grupo que foi marcada (utilizado para desmarcar a atualizacao, caso seja encontrado uma carga mais recente do mesmo grupo)

If oClient <> Nil
	Self:DefineGroupStatusClient(oClient)
EndIf
/*Atencao: o array aEntireLoad possui o codigo de grupo do template (nao da carga em si)
para utilizar o codigo de grupo da carga, sera necessario buscar no aoGroups pelo codigo do template 
e usar o Self:oLoadGroups:aoGroups[nJ]:cCode  */
For nI := 1 to Len(aEntireLoad)
	nAuxLoadMark := 0
	nOldIndex := 0
	For nJ := 1 to Len(Self:oLoadGroups:aoGroups)
		If Self:oLoadGroups:aoGroups[nJ]:cCodeTemplate == aEntireLoad[nI] .AND. Self:oLoadGroups:aoGroups[nJ]:cEntireIncremental == "1" 
			If !lOnlyIfNewer .OR. (GetStatus(Self:oLoadGroups:aoGroups[nJ]:cCode) <> "2" ) //Se atualiza mesmo nao estando pendente, ou se estiver pendente
				
				//verifica se alguma carga desse grupo ja foi marcada e entao desmarca a anterior (pra garantir que apenas a ultima seja atualizada)
				If nAuxLoadMark > 0 
					Self:aSelection[nOldIndex] := .F.
				EndIf
								
				Self:aSelection[nJ] := .T. //marca a carga pra atualizar
				Self:lExecute := .T. //determina que ha cargar para atualizar
				
				nAuxLoadMark++ 
				nOldIndex := nJ 
				
				
			EndIf
		EndIf
	
	Next nJ
	
	
Next nI

If Self:oRequest <> Nil
	Self:oRequest:aSelection := Self:aSelection
EndIf

Return

//--------------------------------------------------------------------------------
/*/{Protheus.doc} Show()

exibe a tela

@return nil

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method Show() Class LJCInitialLoadSelector


Local cVar					:= ""
Local oPanel 					:= Nil	//tela principal
Local oFWLayer				:= Nil	//organizador de janelas

Local oLEntire				:= Nil	//janela das cargas inteiras
Local oLIncremental			:= Nil	//janela das cargas incrementais
Local oLAdditionalData			:= Nil	//janela dos dados adicionais
Local oLStatus				:= Nil	//janela dos status nos ambientes
Local oLActions				:= Nil	//janela das acoes

Local aCoors					:= FWGetDialogSize(oMainWnd)	

Local oActInChildren			:= Nil
Local lActInChildren			:= Self:oRequest:lActInChildren
Local oCancel					:= Nil
Local oDownload				:= Nil
Local lDownload				:= Self:oRequest:lDownload
Local oExecute				:= Nil
Local oImport					:= Nil
Local lImport					:= Self:oRequest:lImport
Local oKillOtherThreads		:= Nil
Local lKillOtherThreads 		:= Self:oRequest:lKillOtherThreads
Local oText					:= Nil
Local oDelete					:= Nil	


Local oChkAllEntire			:= Nil	
Local oChkAllIncremental		:= Nil	
Local oChkPendingInc			:= Nil
Local oChkDownloadedInc		:= Nil


Local lAllEntire				:= .F.	
Local lAllIncremental			:= .F.	
Local lPendingInc				:= .F.
Local lDownloadedInc			:= .F.
	


DEFINE MSDIALOG oPanel TITLE STR0001 FROM aCoors[1],aCoors[2] TO aCoors[3]-100,aCoors[4]-100 PIXEL "


oPanel:ReadClientCoors(.T.,.T.)	
	


// Configura o FWLayer	
oFWLayer := FWLayer():New()
oFWLayer:Init( oPanel, .F. )


//Cargas inteiras
oFWLayer:AddCollumn( "Coluna 1", 70 )
oFWLayer:AddWindow( "Coluna 1", "Window 1", STR0002, 50, .F., .T., , , , CONTROL_ALIGN_CENTER ) // "Cargas Inteiras"
oLEntire := oFWLayer:GetWinPanel( "Coluna 1", "Window 1" )	

//Cargas incrementais
oFWLayer:AddWindow( "Coluna 1", "Window 2", STR0003, 50, .F., .T., , , , CONTROL_ALIGN_CENTER )	// "Cargas Incrementais"
oLIncremental := oFWLayer:GetWinPanel( "Coluna 1", "Window 2" )

//Dados adicionais
oFWLayer:AddCollumn( "Coluna 2", 30 )
oFWLayer:AddWindow( "Coluna 2", "Window 3", STR0004, 50, .F., .T., , , , CONTROL_ALIGN_CENTER ) // "Dados da carga"
oLAdditionalData := oFWLayer:GetWinPanel( "Coluna 2", "Window 3" )	

//acoes
oFWLayer:AddWindow( "Coluna 2", "Window 5", STR0005 , 50, .F., .T., , , , CONTROL_ALIGN_CENTER )	// "Ações"
oLActions := oFWLayer:GetWinPanel( "Coluna 2", "Window 5" )

// Grid das cargas incrementais

@ 09,09 LISTBOX Self:oLbxEntire VAR cVar FIELDS HEADER "", STR0006, STR0007, "", STR0008, STR0009, STR0010, STR0011, STR0012  SIZE 330,150 OF oLEntire PIXEL //
Self:oLbxEntire:Align := CONTROL_ALIGN_ALLCLIENT

// Grid das cargas inteiras
@ 09,09 LISTBOX Self:oLbxIncremental VAR cVar FIELDS HEADER "", STR0006, STR0007, "", STR0008, STR0009, STR0010, STR0011, STR0012 SIZE 330,150 OF oLIncremental PIXEL // 
Self:oLbxIncremental:Align := CONTROL_ALIGN_ALLCLIENT

//Grid das tabelas da carga
@ 09,09 LISTBOX Self:oLbxTables VAR cVar FIELDS HEADER STR0013, STR0014, STR0015 , STR0016 SIZE 330,150 OF oLAdditionalData PIXEL // 
Self:oLbxTables:Align := CONTROL_ALIGN_ALLCLIENT


@ 010,010 CHECKBOX oChkAllEntire VAR lAllEntire PROMPT STR0017 + " - " + STR0002 SIZE 150, 008 OF oLActions COLORS 0, 16777215 PIXEL ON CHANGE Self:SelectAll(lAllEntire, ENTIRE, oFWLayer)
@ 025,010 CHECKBOX oChkAllIncremental VAR lAllIncremental PROMPT STR0017 + " - " + STR0003 SIZE 150, 008 OF oLActions COLORS 0, 16777215 PIXEL ON CHANGE Self:SelectAll(lAllIncremental, INCREMENTAL, oFWLayer)

If Self:lShowStatus
	@ 040,010 CHECKBOX oChkPendingInc VAR lPendingInc PROMPT STR0018 SIZE 150, 008 OF oLActions COLORS 0, 16777215 PIXEL ON CHANGE Self:SelectSpecificInc(lPendingInc, " " , oFWLayer)
	@ 055,010 CHECKBOX oChkDownloadedInc VAR lDownloadedInc PROMPT STR0019 SIZE 150, 008 OF oLActions COLORS 0, 16777215 PIXEL ON CHANGE  Self:SelectSpecificInc(lDownloadedInc, "1", oFWLayer)
EndIf

//modo de exclusao de carga
If Self:lShowDelete
	@ 070, 026 BUTTON oDelete PROMPT STR0020 SIZE 036, 012 OF oLActions PIXEL ACTION (Self:DeleteLoad() , oPanel:End()) // "Excluir" //atusx
Else //modo de carregamento de carga
	@ 070, 026 BUTTON oExecute PROMPT STR0021 SIZE 036, 012 OF oLActions PIXEL ACTION (Self:SelectActions(), oPanel:End()) // "Executar"
EndIf
@ 070, 077 BUTTON oCancel PROMPT STR0022 SIZE 036, 012 OF oLActions PIXEL ACTION (oPanel:End()) // "Cancelar"
 
Self:ConfigLoadList( Self:oLbxEntire, oFWLayer, Self:aEntireLoads, ENTIRE ) 
Self:ConfigLoadList( Self:oLbxIncremental, oFWLayer, Self:aIncrementalLoads, INCREMENTAL ) 
  

ACTIVATE MSDIALOG oPanel CENTERED



Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ConfigLoadList()

configura a lista das cargas especificas

@param oList objeto da lista com as cargas
@param oFWLayer FWLayer que possui o objeto da lista (oList)
@param aData array de dados que sera usado na oList
@param cLoadType 1 = carga inteira / 2 = carga incremental

@return nil

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method ConfigLoadList( oList, oFWLayer, aData, cLoadType ) Class LJCInitialLoadSelector

aData := Self:MakeGroupArray(cLoadType) //Busca dados para o array
oList:SetArray(aData) //Associa o array de dados ao listbox

If Len(aData) > 0
	//Configura os listbox 
	oList:bLine := {|| { 	aData[oList:nAt,1],;
						aData[oList:nAt,2],;
						aData[oList:nAt,3],;
						aData[oList:nAt,4],;
						aData[oList:nAt,5],;
						aData[oList:nAt,6],; 
						aData[oList:nAt,7],;
						aData[oList:nAt,8],;
						aData[oList:nAt,9] }  }
	
	
	oList:bChange := {|| Self:ConfigTableList(oList, aData, oFWLayer)   }   //atualiza o grid com as tabelas de cada carga
	oList:bLDblClick := {|| Self:ReverseItemSelection(oList, aData, cLoadType ) } //marca/desmarca o checkbox para a selecao das cargas  
EndIf	
	
	oList:Refresh()
				
					

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} ConfigTableList()

Configura a lista com as tabelas da carga selecionada

@param oList objeto da lista com as cargas
@param aData array de dados que sera usado na oList
@param oFWLayer FWLayer que possui o objeto da lista (oList)

@return nil

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method ConfigTableList(oList, aData, oFWLayer) Class LJCInitialLoadSelector

If Len(aData) > 0
	//busca as tabelas da carga selecionada
	Self:aTables := Self:MakeTableArray(aData[oList:nAt][LBCODE])
	
	//se nao tiver nada define o array como vazio (para nao dar erro nem manter valores antigos)
	If Len(Self:aTables) = 0
		Self:aTables := Array(1,4) 
	EndIf
	
	Self:oLbxTables:SetArray(Self:aTables)
	Self:oLbxTables:bLine := {|| { 	Self:aTables[Self:oLbxTables:nAt,1],;
								Self:aTables[Self:oLbxTables:nAt,2],;
								Self:aTables[Self:oLbxTables:nAt,3],;
								Self:aTables[Self:oLbxTables:nAt,4]   }  }
	Self:oLbxTables:Refresh()
	
	oFWLayer:SetWinTitle("Coluna 2", "Window 3",STR0004 + " " + aData[oList:nAt][LBCODE]) //mostra o codigo da carga selecionada no titulo
EndIf
Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} MakeGroupArray()

monta o array de cargas especificas (inteira ou incremental)

@param cLoadType 1 = carga inteira / 2 = carga incremental

@return aRet array com as cargas

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method MakeGroupArray( cLoadType ) Class LJCInitialLoadSelector

Local aRet		:= {}
Local nI			:= 0
Local cCodStatus	:= ""
Local cStatus		:= ""
Local cColor		:= ""
Local cSelected	:= ""

For nI := 1 to Len(Self:oLoadGroups:aoGroups)
	
	If Self:oLoadGroups:aoGroups[nI]:cEntireIncremental == cLoadType
	
		//define se a carga esta selecionada
		If Self:aSelection[nI]
			cSelected := "LBOK"
		Else
			cSelected := "LBNO"
		EndIf
		
		If Self:lShowStatus
			//define o status e a legenda
			cCodStatus := Self:GetStatus(Self:oLoadGroups:aoGroups[nI]:cCode)
			Do Case
				Case cCodStatus == "1"
					cStatus :=  STR0023 //atusx
					cColor := "BR_AMARELO"
				Case cCodStatus == "2"
					cStatus :=  STR0024 
					cColor := "BR_VERDE"
				Otherwise
					cStatus :=  STR0025 
					cColor := "BR_VERMELHO"
			EndCase
		Else
			cStatus 	:= " "
			cColor 	:= "BR_Cinza"
		EndIf		
		
		//monta o array
		Aadd(aRet,{ 	LoadBitmap( GetResources(), cSelected ),;
					Self:oLoadGroups:aoGroups[nI]:cCode ,;
					Self:oLoadGroups:aoGroups[nI]:cName ,;
					LoadBitmap( GetResources(), cColor ),;
					cStatus,;
					Self:oLoadGroups:aoGroups[nI]:cDescription,;
					Self:oLoadGroups:aoGroups[nI]:oDateTime:GetDate(), ;
					Self:oLoadGroups:aoGroups[nI]:oDateTime:GetTime(), ;
					Self:oLoadGroups:aoGroups[nI]:cOrder 	  }  )	
	
	EndIf


Next nI


Return aRet


//--------------------------------------------------------------------------------
/*/{Protheus.doc} MakeTableArray()

Monta o array das tabelas da carga baseada na carga selecionada

@param cCodeGroup codigo da carga

@return aRet array com os detalhes das tabelas exportadas na carga

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method MakeTableArray( cCodeGroup ) Class LJCInitialLoadSelector

Local aRet	:= {}
Local nI		:= 0
Local nJ		:= 0

For nI := 1 to Len(Self:oLoadGroups:aoGroups)
	
	If Self:oLoadGroups:aoGroups[nI]:cCode == cCodeGroup
		
		For nJ := 1 to Len (Self:oLoadGroups:aoGroups[nI]:oTransferFiles:aoFiles)
			
			Aadd(aRet,{ 	Self:oLoadGroups:aoGroups[nI]:oTransferFiles:aoFiles[nJ]:cTable, ;
						Self:oLoadGroups:aoGroups[nI]:oTransferFiles:aoFiles[nJ]:nRecords, ;
						Self:oLoadGroups:aoGroups[nI]:oTransferFiles:aoFiles[nJ]:cCompany, ;
						Self:oLoadGroups:aoGroups[nI]:oTransferFiles:aoFiles[nJ]:cBranch	 }  )
		Next	nJ
	EndIf

Next nI


Return aRet

//--------------------------------------------------------------------------------
/*/{Protheus.doc} GetStatus()

busca o status da carga na lista de cargas que estiver instanciada

@param cCodeLoad codigo da carga

@return cCodStatus status da carga

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method GetStatus(cCodeLoad) Class LJCInitialLoadSelector
Local cCodStatus 			:= " "
Local oGroupStatus			:= Nil
Local nI 				:= 0

//procura no array de status a carga em questao e pega o status dela
If Self:oGroupStatus <> Nil
	For nI := 1 to Len(Self:oGroupStatus:aoStatus)
		If Self:oGroupStatus:aoStatus[nI]:cCodeLoad == cCodeLoad
			cCodStatus := Self:oGroupStatus:aoStatus[nI]:cStatus
			Exit
		EndIf
	Next nI
EndIf


Return cCodStatus

//--------------------------------------------------------------------------------
/*/{Protheus.doc} ReverseItemSelection()

Inverte a selecao atual das cargas

@param oList objeto com a lista de cargas
@param aData array com os dados da lista
@param cListType tipo da lista (1-inteira ou 2-incremental)

@return nil

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method ReverseItemSelection(oList, aData, cListType) Class LJCInitialLoadSelector

Local nItem	:= 0  
Local nI		:= 0 

//busca qual o indice do array geral (todas as cargas) corresponde a carga selecionada no array especifico (inteira ou incremental)
For nI := 1 to Len(Self:oLoadGroups:aoGroups)
	If Self:oLoadGroups:aoGroups[nI]:cCode == aData[oList:nAt][LBCODE]
		nItem := nI
		Exit
	EndIf
Next nI


Self:aSelection[nItem] := !Self:aSelection[nItem] 
aData := Self:MakeGroupArray(cListType)

oList:Refresh()

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} SelectActions()

exibe tela para marcar as acoes a serem executadas
[download, importar, matar threads, aplicar nos filhos]

@return nil

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method SelectActions() Class LJCInitialLoadSelector


Local oActInChildren			:= Nil
Local lActInChildren			:= Self:oRequest:lActInChildren
Local oCancel					:= Nil
Local oDownload				:= Nil
Local lDownload				:= Self:oRequest:lDownload
Local oExecute				:= Nil
Local oImport					:= Nil
Local lImport					:= Self:oRequest:lImport
Local oKillOtherThreads		:= Nil
Local lKillOtherThreads 		:= Self:oRequest:lKillOtherThreads
Local oText					:= Nil	
	

DEFINE MSDIALOG oDlg TITLE STR0034 FROM 000, 000  TO 175, 280 COLORS 0, 16777215 PIXEL STYLE DS_MODALFRAME // "Iniciar carga"
//Acoes
 @ 004, 006 SAY oText PROMPT STR0026 SIZE 133, 007 OF oDlg COLORS 0, 16777215 PIXEL // "Selecione as ações que serão executadas no ambiente:"
 @ 017, 006 CHECKBOX oDownload VAR lDownload PROMPT STR0027 SIZE 047, 008 OF oDlg COLORS 0, 16777215 PIXEL // "Baixar carga"
 @ 030, 006 CHECKBOX oImport VAR lImport PROMPT STR0028 SIZE 047, 008 OF oDlg COLORS 0, 16777215 PIXEL ON CHANGE If( lImport, oKillOtherThreads:Enable(), oKillOtherThreads:Disable() ) // "Importar"
 @ 043, 016 CHECKBOX oKillOtherThreads VAR lKillOtherThreads PROMPT STR0029 SIZE 107, 008 OF oDlg COLORS 0, 16777215 PIXEL // "Derrubar processos quando necessário"
 @ 056, 006 CHECKBOX oActInChildren VAR lActInChildren PROMPT STR0030 SIZE 089, 008 OF oDlg COLORS 0, 16777215 PIXEL // "Executar ações nos dependentes"
 @ 073, 056 BUTTON oExecute PROMPT STR0021 SIZE 036, 012 OF oDlg PIXEL ACTION (Self:lExecute := .T., oDlg:End()) // "Executar"
 @ 073, 097 BUTTON oCancel PROMPT STR0022 SIZE 036, 012 OF oDlg PIXEL ACTION (Self:lExecute := .F. , oDlg:End()) // "Cancelar"

oDlg:LESCCLOSE := .F.	// Não permite nenhuma ação com o botão ESC

If lImport
	oKillOtherThreads:Enable()
Else	
	 oKillOtherThreads:Disable()
EndIf

If FunName() == "STIPOSMAIN"
	oDownload:bWhen         := {|| .F.}
	oImport:bWhen           := {|| .F.}
	oKillOtherThreads:bWhen := {|| .F.}
	oActInChildren:bWhen    := {|| .F.}
EndIf  
 
 
 ACTIVATE MSDIALOG oDlg CENTERED
 
 
 
If Self:lExecute

	Self:oRequest:lImport			:= lImport
	Self:oRequest:lDownload		:= lDownload
	Self:oRequest:lActInChildren 	:= lActInChildren		
	Self:oRequest:lKillOtherThreads	:= lKillOtherThreads
	
	Self:oRequest:aSelection		:= Self:aSelection //cargas selecionadas para serem processadas (download/importacao)
EndIf

Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} SelectAll()

Facilitador para selecionar as carags. Marcar tudo e desmarcar tudo avaliando o tipo de carga

@param lSelect Define se marca ou desmarca 
@param cLoadType tipo da carga (1-inteira ou 2-incremental)
@param oFWLayer Layer que possui o objeto da lista das cargas

@return nil

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method SelectAll(lSelect, cLoadType, oFWLayer) Class LJCInitialLoadSelector

Local nI		:= 0 

//busca qual o indice do array geral (todas as cargas) corresponde a carga selecionada no array especifico (inteira ou incremental)
For nI := 1 to Len(Self:oLoadGroups:aoGroups)
	If Self:oLoadGroups:aoGroups[nI]:cEntireIncremental == cLoadType
		Self:aSelection[nI] := lSelect 
	EndIf
Next nI

If cLoadType == ENTIRE
	Self:ConfigLoadList( Self:oLbxEntire, oFWLayer, Self:aEntireLoads, ENTIRE ) 
ElseIf cLoadType == INCREMENTAL
	Self:ConfigLoadList( Self:oLbxIncremental, oFWLayer, Self:aIncrementalLoads, INCREMENTAL )
EndIf


Return



//--------------------------------------------------------------------------------
/*/{Protheus.doc} SelectSpecificInc()

Facilitador para selecionar as carags pendentes, baixadas ou importadas  - apenas incremental

@param lSelect Define se marca ou desmarca 
@param cStatus define o status que sera marcado (pendente, baixada ou importada)
@param oFWLayer Layer que possui o objeto da lista das cargas

@return nil

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------   
Method SelectSpecificInc(lSelect, cStatus, oFWLayer) Class LJCInitialLoadSelector

Local nI		:= 0
Local nJ		:= 0  

Self:aIncrementalLoads := Self:MakeGroupArray(INCREMENTAL) //Busca dados para o array

//busca qual o indice do array geral (todas as cargas) corresponde a carga selecionada no array especifico (inteira ou incremental)
For nI := 1 to Len(Self:aIncrementalLoads)	
	If (Self:GetStatus(Self:aIncrementalLoads[nI][LBCODE]) == cStatus) //se estiver com status = pendente
		For nJ := 1 to Len(Self:oLoadGroups:aoGroups) //procura indice e seleciona
			If Self:oLoadGroups:aoGroups[nJ]:cCode == Self:aIncrementalLoads[nI][LBCODE]
				Self:aSelection[nJ] := lSelect
			EndIf
		Next nJ
	EndIf	
Next nI

Self:ConfigLoadList( Self:oLbxIncremental, oFWLayer, Self:aIncrementalLoads, INCREMENTAL )



Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} DeleteLoad()

Deleta a(s) carga(s) selecionada(s)

@return nil

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method DeleteLoad() Class LJCInitialLoadSelector

Local oEraser := Nil
Local lRestMSEXP := .F.

If MsgYesNo( STR0031 ) //atusx
	
	lRestMSEXP := MsgYesNo( STR0032 ) //"Deseja restaurar o MSEXP das cargas incrementais selecionadas para exclusão ? Se restaurado, todas as cargas incrementais posteriores também serão excluídas. Caso a carga incremental já tenha sido aplicada em algum ambiente, selecione a opção para NÃO restaurar o MSEXP. Opção valida apenas para cargas incrementais. "
	If (lRestMSEXP)
		lRestMSEXP :=  MsgYesNo( STR0033 ) //"Confirma a exclusão de todas as cargas posteriores em relação à primeira carga incremental selecionada para permitir restaurar o MSEXP?"   
	EndIf
	oEraser := LJCInitialLoadDeleteLoad():New(Self:oLoadGroups, Self:aSelection)
	oEraser:Start(lRestMSEXP)
	
EndIf

Return


//--------------------------------------------------------------------------------
/*/{Protheus.doc} DefineGroupStatusClient()

Busca o status das cargas para um determinado cliente

@param oClient Cliente que sera avaliado

@return nil

@author Vendas CRM
@since 28/06/2012
/*/
//--------------------------------------------------------------------------------    
Method DefineGroupStatusClient(oClient) Class LJCInitialLoadSelector

Local oLJCMessageManager 	:= GetLJCMessageManager()	
Local oLJMessenger			:= Nil

Local nI := 0

If oClient <> Nil //se for chamado pelo monitor, busca status de um cliente especifico
	oLJMessenger := LJCInitialLoadMessenger():New( oClient )
	If !oLJCMessageManager:HasError()
		oLJMessenger:CheckCommunication()
		If !oLJCMessageManager:HasError()	
			Self:oGroupStatus := oLJMessenger:GetStatusLoad()
		EndIf	
	EndIf
Else//se for chamado pelo carregamento de carga, busca status local
	Self:oGroupStatus := GetStatusLoad()
EndIf


Return

 
