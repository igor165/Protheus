#INCLUDE "PLSA999.ch"
#INCLUDE "PROTHEUS.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PLSA999   ºAutor  ³Microsiga           º Data ³  06/01/2015º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro das Distribuição das Consultas Médicas ou         º±±
±±º          ³ Dimensionamento da rede                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SEGMENTO SAUDE VERSAO 12                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function PLSA999()
Local oBrowse

oBrowse := FWmBrowse():New()
oBrowse:SetAlias( 'B9D' )
oBrowse:SetDescription(STR0001) //'Distribuição das Consultas Médicas'
oBrowse:Activate()

Return( NIL )


//-------------------------------------------------------------------
Static Function MenuDef()
Private aRotina := {}

aAdd( aRotina, { STR0005,'PesqBrw'         , 0, 1, 0, .T. } )//'Pesquisar'
aAdd( aRotina, { STR0006,'VIEWDEF.PLSA999', 0, 2, 0, NIL } ) //'Visualizar'
aAdd( aRotina, { STR0007,'VIEWDEF.PLSA999', 0, 3, 0, NIL } ) //'Incluir'
aAdd( aRotina, { STR0008,'VIEWDEF.PLSA999', 0, 4, 0, NIL } ) //'Alterar'
aAdd( aRotina, { STR0009,'VIEWDEF.PLSA999', 0, 5, 0, NIL } ) //'Excluir'
aAdd( aRotina, { STR0010,'VIEWDEF.PLSA999', 0, 8, 0, NIL } ) //'Imprimir'
aAdd( aRotina, { STR0011,'VIEWDEF.PLSA999', 0, 9, 0, NIL } ) //'Copiar'

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados

Local oStruB9D := FWFormStruct( 1, 'B9D', , )
Local oStruB9E := FWFormStruct( 1, 'B9E', , )
Local oModel

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New( 'PLSA999MD', /*bPreValidacao*/,{|| PL999ValDel(oModel) } /*bPosValidacao*/,  /*bCommit*/ , /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'B9DMASTER', NIL, oStruB9D )

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'B9EDETAIL', 'B9DMASTER', oStruB9E, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


oModel:SetPrimaryKey({"B9D_FILIAL","B9D_CODINT","B9D_CODDCM"})


// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'B9EDETAIL', { { 'B9E_FILIAL', 'xFilial( "B9E" ) ' } ,;
	                                { 'B9E_CODDCM', 'B9D_CODDCM' } } ,  "B9E_FILIAL+B9E_CODDCM" )

// Indica que é opcional ter dados informados na Grid
oModel:GetModel( 'B9EDETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'B9DMASTER' ):SetDescription(STR0001 ) //'Distribuição das Consultas Médicas'

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(STR0001) //'Distribuição das Consultas Médicas'

//Valida se existem codigos duplicados no aCols
oModel:GetModel('B9EDETAIL'):SetUniqueLine({'B9E_ESPECI'})

Return oModel

//-------------------------------------------------------------------
Static Function ViewDef()  

// Cria a estrutura a ser usada na View
Local oStruB9E := FWFormStruct( 2, 'B9E' , {|cCampo| PL999B9E(cCampo)})
Local oStruB9D := FWFormStruct( 2, 'B9D' )

Local oModel   := FWLoadModel( 'PLSA999' )
Local oView    := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_B9D' , oStruB9D, 'B9DMASTER'   )     

//Adiciona no nosso View um controle do tipo FormGrid(antiga newgetdados)
oView:AddGrid(  'VIEW_B9E' , oStruB9E, 'B9EDETAIL'   )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'GERAL', 50 )
oView:CreateHorizontalBox( 'GRID', 50 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_B9D' , 'GERAL'  )
oView:SetOwnerView( 'VIEW_B9E' , 'GRID'  )

oView:EnableTitleView( 'VIEW_B9E' )

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_B9E', 'B9E_SEQ' )   

oView:SetViewAction( 'BUTTONOK', { |oView|  PL999CalTotal() } )

Return oView  

//-------------------------------------------------------------------
//Calcula a porcentagem de utilizacao da especialidade
Function PL999PORCUTI()
Local oModel 		:= FwModelActive()
Local oModelB9D 	:= oModel:GetModel('B9DMASTER')
Local oModelB9E 	:= oModel:GetModel('B9EDETAIL')
Local cTipo 		:= oModelB9E:GetValue('B9E_TIPOAT' )
Local nValor      := 0
Local nTotal     := 0

If cTipo == "1" //Basica
  ntotal := (oModelB9D:GetValue('B9D_ATENCA') * oModelB9D:GetValue('B9D_TOTANO'))/ 100 //=> alteracao que nao subiu
  If ntotal < 1
  	ntotal := ntotal * 10
  Endif 
  nValor := (oModelB9E:GetValue('B9E_TOTSOL') * 100) / ntotal //oModelB9D:GetValue('B9D_ATENCA')
Else
  ntotal := (oModelB9D:GetValue('B9D_MESESP') * oModelB9D:GetValue('B9D_TOTANO')) / 100
  If ntotal < 1
  	ntotal := ntotal * 10
  Endif 
  nValor := (oModelB9E:GetValue('B9E_TOTSOL') * 100) / ntotal //oModelB9D:GetValue('B9D_MESESP')
Endif

oModelB9E:SetValue('B9E_UTILIZ', nValor)

Return .T.


//-------------------------------------------------------------------
//Calcula se o total de consultas informado confere com o total de consultas ano informado
Function PL999CalTotal()
Local oModel 		:= FwModelActive()
Local oModelB9D 	:= oModel:GetModel('B9DMASTER')
Local oModelB9E 	:= oModel:GetModel('B9EDETAIL')
Local nTotal 		:= oModelB9D:GetValue('B9D_TOTANO' )
Local nSoma       := 0
Local lRet 		:= .F.
Local aEntidades 	:= {}
Local nX         := 0
Local nY         := 0
local nOpc			:=oModel:GetOperation()

If (nOpc == 3) .Or. (nOpc == 4)//Inclusão ou Alteração
	aAdd(aEntidades,{oModelB9E,"B9E_TOTSOL"})
	
	For nX := 1 To Len(aEntidades)
		For nY := 1 To aEntidades[nX][1]:Length()
			aEntidades[nX][1]:GoLine(nY)
			nSoma := nSoma + aEntidades[nX][1]:GetValue(aEntidades[nX][2]) 		
		Next nY	
	Next nX
	
	If nSoma == nTotal
		lRet := .T.
	Else
		Help(" ",1,STR0003)//'O somatório das solicitações por especialidade não confere com valor anual de consultas!'
	Endif 
	
	lRet:= PL999PORCE()
	
Else
 
If nOpc == 5
	dbSelectArea("BIB")
	dbSetOrder(3)
	If BIB->(MSSEEK(xFilial("BIB")+B9D->B9D_CODINT+B9D->B9D_CODDCM))
		Help(" ",1,"Registro não pode ser excluído porque está associado ao cadastro de região "+alltrim (BIB->BIB_CODREG ))
		lRet := .F.
	Endif                  
Endif

Endif 

Return lRet

//-------------------------------------------------------------------
//Calcula se a porcentagem informada ultrapassa 100%
Function PL999PORCE()
Local oModel 		:= FwModelActive()
Local oModelB9D 	:= oModel:GetModel('B9DMASTER')
Local lRet        :=  .T.

nValor := oModelB9D:GetValue('B9D_ATENCA') + oModelB9D:GetValue('B9D_MESESP') 

If (nValor < 100) .Or. (nValor > 100) 
	MSGALERT(STR0004)//"As porcentagens informado no campo Atencao basica e Especialidade não totalizam 100 %"
	lRet := .F.
Endif


Return lRet

//-------------------------------------------------------------------
//Tratamento para campos que não devem ir na View
Function PL999B9E(cCampo)

Local lRet	:= .T.

If cCampo == "B9E_FILIAL"
	lRet := .F.
EndIf

If cCampo == "B9E_CODDCM"
	lRet := .F.
EndIf

Return lRet


//-------------------------------------------------------------------
//Calcula se o total de consultas informado confere com o total de consultas ano informado
Function PL999ValDel(oModel)
Local nOpc := oModel:GetOperation()
Local lRet    := .T. 

If nOpc == 5
	dbSelectArea("BIB")
	dbSetOrder(3)
	If BIB->(MSSEEK(xFilial("BIB")+B9D->B9D_CODINT+B9D->B9D_CODDCM))
		Help( ,, STR0013,, STR0012+alltrim (BIB->BIB_CODREG), 1, 0 )//"Permissão de exclusão"##"Registro não pode ser excluído porque está associado ao cadastro de região "
		lRet := .F.
	Endif                  
Endif

Return lRet

