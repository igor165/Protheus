#INCLUDE "PLSEVNOT.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSEVNOT

@author Thiago Guilherme
@since 30/01/2014
@version P12
@description Cadastro de Notícias do Portal
/*/
//-------------------------------------------------------------------
Function PLSEVNOT()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'BPL' )
oBrowse:SetDescription(STR0001) //'Cadastro de Notícias'
oBrowse:Activate()

Return( NIL )

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef

@author Thiago Guilherme
@since 30/01/2014
@version P12
@description MenuDef
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Private aRotina := {}

aAdd( aRotina, { 'Pesquisar' , 				'PesqBrw'         , 0, 1, 0, .T. } )
aAdd( aRotina, { 'Visualizar', 				'VIEWDEF.PLSEVNOT', 0, 2, 0, NIL } )
aAdd( aRotina, { 'Incluir'   , 				'VIEWDEF.PLSEVNOT', 0, 3, 0, NIL } ) 
aAdd( aRotina, { 'Alterar'   , 				'VIEWDEF.PLSEVNOT', 0, 4, 0, NIL } ) 
aAdd( aRotina, { 'Excluir'   , 				'VIEWDEF.PLSEVNOT', 0, 5, 0, NIL } )
aAdd( aRotina, { 'Imprimir'  , 				'VIEWDEF.PLSEVNOT', 0, 8, 0, NIL } )
aAdd( aRotina, { 'Copiar'    , 				'VIEWDEF.PLSEVNOT', 0, 9, 0, NIL } )
aAdd( aRotina, { 'Anexar arquivo',			'PLSNOTBCO'	  	  , 0, 9, 0, NIL } )
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef

@author Thiago Guilherme
@since 30/01/2014
@version P12
@description ModelDef
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

STATIC oModelNOT

// Cria o objeto do Modelo de Dados

Local oStrBPL:= FWFormStruct(1,'BPL')
Local oStrBPM:= FWFormStruct(1,'BPM')
Local oStrBPO:= FWFormStruct(1,'BPO')
Local oStrBPP:= FWFormStruct(1,'BPP')

oModelNOT := MPFormModel():New( STR0001, /*bPreValidacao*/, {|oModelNOT|ExcArqNot(oModelNOT)}/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ ) //cadastro de noticias

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModelNOT:AddFields( 'BPLMASTER', NIL, oStrBPL )

// Faz relaciomaneto entre os compomentes do model
oModelNOT:addGrid('BPM','BPLMASTER',oStrBPM)
oModelNOT:SetRelation('BPM', { { 'BPM_FILIAL', 'xFilial( "BPM" )'  }, { 'BPM_CODIGO', 'BPL_CODIGO' } }, BPM->(IndexKey(1)) )

oModelNOT:addGrid('BPO','BPLMASTER',oStrBPO)
oModelNOT:SetRelation('BPO', { { 'BPO_FILIAL', 'xFilial( "BPO" ) ' }, { 'BPO_CODIGO', 'BPL_CODIGO' } }, BPO->(IndexKey(1)) )

oModelNOT:addGrid('BPP','BPLMASTER',oStrBPP)
oModelNOT:SetRelation('BPP', { { 'BPP_FILIAL', 'xFilial( "BPP" ) ' }, { 'BPP_CODIGO', 'BPL_CODIGO' } }, BPP->(IndexKey(1)) )

// Adiciona a descricao do Modelo de Dados
oModelNOT:SetDescription( STR0001 ) //'Cadastro de Notícias'

// Adiciona a descricao do Componente do Modelo de Dados
oModelNOT:GetModel( 'BPLMASTER' ):SetDescription( STR0001 ) //'Cadastro de Notícias'
oModelNOT:GetModel( 'BPM' ):SetDescription( STR0002 ) //'Especialidades' 
oModelNOT:GetModel( 'BPO' ):SetDescription( STR0003 ) //'Prestadores' 
oModelNOT:GetModel( 'BPP' ):SetDescription( STR0004 ) //'Produto'  

//Valida se existem codigos duplicados no aCols
oModelNOT:GetModel('BPM'):SetUniqueLine( { 'BPM_CODESP' } )
oModelNOT:GetModel('BPO'):SetUniqueLine( { 'BPO_CODRDA' } )
oModelNOT:GetModel('BPP'):SetUniqueLine( { 'BPP_CODPLA' } )

//permite salvar linha vazia no grid 
oModelNOT:GetModel('BPM'):SetOptional( .T. )
oModelNOT:GetModel('BPO'):SetOptional( .T. )
oModelNOT:GetModel('BPP'):SetOptional( .T. )

Return oModelNOT

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef

@author Thiago Guilherme
@since 30/01/2014
@version P12
@description ViewDef
/*/
//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oStrBPM := FWFormStruct( 2, 'BPM' )
Local oStrBPO := FWFormStruct( 2, 'BPO' )
Local oStrBPP := FWFormStruct( 2, 'BPP' )

// Cria a estrutura a ser usada na View
Local oModel   := FWLoadModel( 'PLSEVNOT' )
Local oStruBPL := FWFormStruct(2, 'BPL')
Local oView    := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )
oView:AddField('BPL' , oStruBPL,'BPLMASTER' )
oView:AddGrid('VIEW_BPM' , oStrBPM,'BPM')
oView:AddGrid('VIEW_BPO' , oStrBPO,'BPO')
oView:AddGrid('VIEW_BPP' , oStrBPP,'BPP')  

oView:SetViewAction( 'BUTTONOK', { |oView| } )

oView:CreateHorizontalBox( 'BOX1', 50)
oView:CreateVerticalBox( 'FORMBPL', 100, 'BOX1')
oView:CreateHorizontalBox( 'BOX4', 50)
oView:CreateFolder( 'FOLDER5', 'BOX4')

oView:AddSheet('FOLDER5','BPM',STR0002) //'Especialidades' 
oView:AddSheet('FOLDER5','BPO',STR0003) //'Prestadores' 
oView:AddSheet('FOLDER5','BPP',STR0004) //'Produto'

oView:CreateHorizontalBox( 'FORMBPM', 100, /*owner*/, /*lUsePixel*/, 'FOLDER5', 'BPM')
oView:CreateHorizontalBox( 'FORMBPO', 100, /*owner*/, /*lUsePixel*/, 'FOLDER5', 'BPO')
oView:CreateHorizontalBox( 'FORMBPP', 100, /*owner*/, /*lUsePixel*/, 'FOLDER5', 'BPP')

oView:SetOwnerView('BPL','FORMBPL')
oView:SetOwnerView('VIEW_BPM','FORMBPM')
oView:SetOwnerView('VIEW_BPO','FORMBPO')
oView:SetOwnerView('VIEW_BPP','FORMBPP')

// Define campos que terao Auto Incremento
oView:AddIncrementField('VIEW_BPM', 'BPM_ITEM' )
oView:AddIncrementField('VIEW_BPO', 'BPO_ITEM' )
oView:AddIncrementField('VIEW_BPP', 'BPP_ITEM' )

//Remove os campos da tela
oStrBPM:RemoveField('BPM_CODIGO')
oStrBPO:RemoveField('BPO_CODIGO')
oStrBPP:RemoveField('BPP_CODIGO')

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcArqNot

@author Thiago Guilherme
@since 30/01/2014
@version P12
@description Deleta os arquivos da pasta após a exclusão da notícia
/*/
//-------------------------------------------------------------------
Function ExcArqNot(oModel)

LOCAL cDir	 	:= getWebDir()
LOCAL nQtdArq
LOCAL nI
LOCAL cCodNot := BPL->BPL_CODIGO
LOCAL nOperation := oModel:GetOperation()

If nOperation == MODEL_OPERATION_DELETE
	
	//³Deleta os arquivos relacionados a noticia								   
	If !Empty(cDir)
		
		cDir := cDir + "imagens-pls\arquivonoticia\"+ cCodNot + "\" 
		
		aArqDir := DIRECTORY(cDir + PLSMUDSIS("\*.*"),"D")	
		
		nQtdArq := Len(aArqDir)
		
		If nQtdArq > 0
			
			For nI := 1 To nQtdArq
				
				If aArqDir[nI][5] == "A"
					
					//³Deleta o registro do arquivo na AC9, para que nao permaneça numa nova
					//mensagem com o mesmo código.													   
					dbSelectArea("ACB")
					dbSetOrder(2)
					
					If dbSeek(xFilial("ACB")+aArqDir[nI][1])
						
						dbSelectArea("AC9")
						dbSetOrder(1)
						
						If dbSeek(xFilial("AC9")+ACB->(ACB_CODOBJ))
							AC9->(RecLock("AC9",.F.))
					       AC9->(DbDelete())
					       AC9->(MsUnLock())
						EndIf
					EndIf
					
					//³Deleta os arquivos da pasta												   
					fErase(cDir+aArqDir[nI][1])
				EndIf
			Next
		EndIf
	EndIf
EndIf

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSNOTBCO

@author Thiago Guilherme
@since 30/01/2014
@version P12
@description Banco de conhecimento das noticias do portal
/*/
//-------------------------------------------------------------------
Function PLSNOTBCO()

LOCAL aArea		:= GetArea()
LOCAL aAreaBPL	:= BPL->(GetArea())
LOCAL cQuery	:= ""
LOCAL cIndex	:= ""
LOCAL cChaveInt  	:= BPL->BPL_CODIGO

PRIVATE aRotina  := {}
PRIVATE CCADASTRO := STR0005 //'Arquivo de notícias'
  
aRotina := {{"Conhecimento",'MsDocument',0/*permite exclusao do registro*/,1/*visualizar arquivo*/},{"Inclusão Rápida",'PLSDOcs',0,3}}

BPL->( DbSetOrder(1) ) //BPL_FILIAL + BPL_CODIGO
BPL->( MsSeek( xFilial("BPL") + cChaveInt ) )

cIndex := CriaTrab(NIL,.F.)
cQuery := "BPL_FILIAL == '" + xFilial("BPL") + "' "
cQuery += " .And. BPL_CODIGO == '" + BPL->BPL_CODIGO + "'"

IndRegua("BPL",cIndex,BPL->(IndexKey()),,cQuery)

If BPL->(!Eof())
	MaWndBrowse(0,0,300,600,"Retorno de Doctos. de Saida","BPL",,aRotina,,,,.T.,,,,,,.F.) //"Retorno de Doctos. de Saida"
EndIf

RetIndex( "BPL" )    
dbClearFilter()

dbSelectArea("BPL")
dbSetOrder(1)

BPL->( RestArea(aAreaBPL) )
RestArea(aArea)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSBLQFLD

@author Thiago Guilherme
@since 30/01/2014
@version P12
@description Permite alteração nos campos dos folders de
			 acordo com o Tipo do portal selecionado.
/*/
//-------------------------------------------------------------------
function PLSBLQFLD()

//Retorna o dado atualizado do campo
LOCAL cTipPort  := oModelNOT:GetValue('BPLMASTER','BPL_TIPUSU')

	/*
	Controla a inclusão, alteração ou exclusão de acordo com o
	tipo de portal selecionado
	*/
	If cTipPort == "1"
		
		oModelNOT:GetModel('BPM'):SetNoInsertLine( .F. )
		oModelNOT:GetModel('BPM'):SetNoUpdateLine( .F. )
		oModelNOT:GetModel('BPM'):SetNoDeleteLine( .F. )
		
		oModelNOT:GetModel('BPO'):SetNoInsertLine( .F. )
		oModelNOT:GetModel('BPO'):SetNoUpdateLine( .F. )
		oModelNOT:GetModel('BPO'):SetNoDeleteLine( .F. )
		
		oModelNOT:GetModel('BPP'):SetNoInsertLine( .T. )
		oModelNOT:GetModel('BPP'):SetNoUpdateLine( .T. )
		oModelNOT:GetModel('BPP'):SetNoDeleteLine( .T. )
	
	ElseIf cTipPort == "2"
		
		oModelNOT:GetModel('BPM'):SetNoInsertLine( .T. )
		oModelNOT:GetModel('BPM'):SetNoUpdateLine( .T. )
		oModelNOT:GetModel('BPM'):SetNoDeleteLine( .T. )
		
		oModelNOT:GetModel('BPO'):SetNoInsertLine( .T. )
		oModelNOT:GetModel('BPO'):SetNoUpdateLine( .T. )
		oModelNOT:GetModel('BPO'):SetNoDeleteLine( .T. )
		
		oModelNOT:GetModel('BPP'):SetNoInsertLine( .F. )
		oModelNOT:GetModel('BPP'):SetNoUpdateLine( .F. )
		oModelNOT:GetModel('BPP'):SetNoDeleteLine( .F. )
		
	ElseIf cTipPort == "3"
	
		oModelNOT:GetModel('BPM'):SetNoInsertLine( .F. )
		oModelNOT:GetModel('BPM'):SetNoUpdateLine( .F. )
		oModelNOT:GetModel('BPM'):SetNoDeleteLine( .F. )
		
		oModelNOT:GetModel('BPO'):SetNoInsertLine( .F. )
		oModelNOT:GetModel('BPO'):SetNoUpdateLine( .F. )
		oModelNOT:GetModel('BPO'):SetNoDeleteLine( .F. )
		
		oModelNOT:GetModel('BPP'):SetNoInsertLine( .F. )
		oModelNOT:GetModel('BPP'):SetNoUpdateLine( .F. )
		oModelNOT:GetModel('BPP'):SetNoDeleteLine( .F. )
	
	Else
		oModelNOT:GetModel('BPM'):SetNoInsertLine( .T. )
		oModelNOT:GetModel('BPM'):SetNoUpdateLine( .T. )
		oModelNOT:GetModel('BPM'):SetNoDeleteLine( .T. )
		
		oModelNOT:GetModel('BPO'):SetNoInsertLine( .T. )
		oModelNOT:GetModel('BPO'):SetNoUpdateLine( .T. )
		oModelNOT:GetModel('BPO'):SetNoDeleteLine( .T. )
		
		oModelNOT:GetModel('BPP'):SetNoInsertLine( .T. )
		oModelNOT:GetModel('BPP'):SetNoUpdateLine( .T. )
		oModelNOT:GetModel('BPP'):SetNoDeleteLine( .T. )
	
	EndIf
return .T.