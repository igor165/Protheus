#INCLUDE "FINA673.ch"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'

//-------------------------------------------------------------------
/*/{Protheus.doc} FINA673
Cadastro de tabela de conversao entre o codigo da empresa dentro Site
Reserve e o Codigo da empresa dentro do sistema Protheus

@author Alexandre Circenis
@since 29-08-2013
@version P11.9
/*/
//-------------------------------------------------------------------
Function FINA673()
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('FL4')
oBrowse:SetDescription(STR0008)
oBrowse:Activate()

Return NIL

//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0009	ACTION 'VIEWDEF.FINA673' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE STR0010	ACTION 'VIEWDEF.FINA673' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE STR0011    ACTION 'VIEWDEF.FINA673' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE STR0012    ACTION 'VIEWDEF.FINA673' OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE STR0013	ACTION 'VIEWDEF.FINA673' OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE STR0014    ACTION 'VIEWDEF.FINA673' OPERATION 9 ACCESS 0

Return aRotina


//-------------------------------------------------------------------
Static Function ModelDef()
// Cria a estrutura a ser acrescentada no Modelo de Dados
Local oStru := FWFormStruct( 1, 'FL4', /*bAvalCampo*/,/*lViewUsado*/ )
// Inicia o Model com um Model ja existente
Local oModel := MPFormModel():New( 'FINA673A',,{|oModel| Fina673vld(oModel)} )

oModel:AddFields( 'FL4MASTER', /*cOwner*/, oStru )
// Adiciona a descrição do Modelo de Dados
oModel:SetDescription(STR0015)
// Adiciona a descrição do Componente do Modelo de Dados
oModel:GetModel( 'FL4MASTER' ):SetDescription( STR0001 ) //'Campos Obrigatorios Reserve'
// Retorna o Modelo de dados

Return oModel


//-------------------------------------------------------------------
Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oModel := FWLoadModel( 'FINA673' )
// Cria a estrutura a ser usada na View
Local oStru := FWFormStruct( 2, 'FL4' )
// Interface de visualização construída
Local oView
// Cria o objeto de View
oView := FWFormView():New()
// Define qual o Modelo de dados será utilizado na View
oView:SetModel( oModel )
// Adiciona no nosso View um controle do tipo formulário
// (antiga Enchoice)
oView:AddField( 'VIEW_FL4', oStru, 'FL4MASTER' )
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )
// Relaciona o identificador (ID) da View com o "box" para
oView:SetOwnerView( 'VIEW_FL4', 'TELA' )
// Retorna o objeto de View criado
Return oView                                                                           



Function FinA673SX3() 

Local oMdl   :=FWModelActive()
Local oMdlF3 := oMdl:GetModel('FINA673')
Local aCpos     := {}       //Array com os dados
Local aRet      := {}       //Array do retorno da opcao selecionada
Local oDlg                  //Objeto Janela
Local oLbx                  //Objeto List box
Local cTitulo   := STR0002  //Titulo da janela --Campos do sitema //"Campos do Sistema"
Local cNoCpos   := ""
Local lRet 		:= .F.
	    
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar campo no SX3³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("SX3")
SX3->(dbSetOrder(1))
SX3->(dbSeek(M->FL4_ALIAS))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega o vetor com os campos da tabela selecionada³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

While !SX3->(Eof()) .And. X3_ARQUIVO == M->FL4_ALIAS
   
   If X3USO(SX3->X3_USADO) .AND. SX3->X3_CONTEXT <> "V" .AND. !AllTrim(SX3->X3_CAMPO) $ cNoCpos
	   aAdd( aCpos, { SX3->X3_CAMPO, X3Titulo(SX3->X3_CAMPO) } )
   EndIf
   
   SX3->(DbSkip())
   
Enddo

If Len( aCpos ) > 0

	DEFINE MSDIALOG oDlg TITLE cTitulo FROM 0,0 TO 240,500 PIXEL
	
	   @ 10,10 LISTBOX oLbx FIELDS HEADER STR0003, STR0004  SIZE 230,95 OF oDlg PIXEL	 //"Campo"###"Titulo"
	
	   oLbx:SetArray( aCpos )
	   oLbx:bLine     := {|| {aCpos[oLbx:nAt,1], aCpos[oLbx:nAt,2]}}
	   oLbx:bLDblClick := {|| {oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]}}} 	                   

	DEFINE SBUTTON FROM 107,213 TYPE 1 ACTION (oDlg:End(), aRet := {oLbx:aArray[oLbx:nAt,1],oLbx:aArray[oLbx:nAt,2]})  ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg CENTER
	
   	M->FL4_CAMPO  := iIF(Len(aRet) > 0, aRet[1],"")
	M->FL4_CPODES := iIF(Len(aRet) > 0, aRet[2],"") 
	 
	If Len(aRet) > 0  
		lRet := .T.
		SX3->(dbSetOrder(2))
		SX3->(dbSeek(aRet[1]))
	EndIf
	
EndIf	

Return lRet     


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA673ObrºAutor  ³Alexandre Circenis  º Data ³  09/12/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se os campos Obrigatorios para a integracao com   º±±
±±º          ³ o Reserve estao preenchidos                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Fina673Obr(cAliasOb)              
Local aArea := GetArea()
Local cCampos := ""
Local lRet := .T.

dbSelectArea("FL4")
dbGotop()
dbSeek(xFilial("FL4")+cAliasOb)

while !Eof() .and. FL4->FL4_FILIAL = xFilial("FL4") .and. FL4->FL4_ALIAS = cAliasOb
	if Empty(&(FL4->FL4_CAMPO)) // Campo Obrigatorio Vazio
		if !Empty(cCampos) 
			cCampos += ", "
		endif
		cCampos += AllTrim(Atf012x3titulo(FL4->FL4_CAMPO))
		lRet := .F.
	endif
	FL4->(dbSkip())
enddo              

if !lRet
	Help(" ",1,STR0005,,STR0006+cCampos+STR0007,1,0) //"Obrig Reserve"###"Os campos: "###". São obrigatórios para integração com o Reserve."
endif     

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA673VldºAutor  ³Marcello Gabriel    º Data ³ 18/08/2014  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida os dados para gravacao.                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Fina673Vld(oModel)
Local lRet	:= .T.

If oModel:GetOperation() == MODEL_OPERATION_INSERT .Or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
	nReg := FL4->(Recno()) 
	If FL4->(DbSeek(xFilial("FL4") + oModel:GetValue("FL4MASTER","FL4_ALIAS") + oModel:GetValue("FL4MASTER","FL4_CAMPO")))
		Help( ,, "EXISTECPO",,STR0016, 1, 0)		//"Este campo já existe no cadastro de campos obrigatórios."
		lRet := .F.
	Endif
Endif
Return(lRet)