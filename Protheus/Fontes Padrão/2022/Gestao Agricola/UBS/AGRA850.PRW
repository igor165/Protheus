#INCLUDE "AGRA850.ch"
#INCLUDE "Protheus.ch"
#INCLUDE "FWMVCDEF.CH"


Static __oViewNPE := Nil 
/*/{Protheus.doc} AGRA850
Cadastro de Amostras do Lote de Sementes

@param: Nil
@author: Aecio Ferreira Gomes
@since: 16/02/2013
@Uso: AGRA850
/*/
// -------------------------------------------------------------------------------------
Function AGRA850()

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('NPE')
oBrowse:SetDescription( STR0001 )

oBrowse:Activate()

Return

/*/{Protheus.doc} MenuDef
Menu Padrão da Rotina 

@param: Nil
@author: Aecio Ferreira Gomes
@since: 16/02/2013
@Uso: AGRA850
/*/
// -------------------------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}    

ADD OPTION aRotina Title STR0002		Action 'VIEWDEF.AGRA850' 	OPERATION 2 ACCESS 0
ADD OPTION aRotina Title STR0003		Action 'VIEWDEF.AGRA850'	OPERATION 3 ACCESS 0
ADD OPTION aRotina Title STR0004		Action 'VIEWDEF.AGRA850' 	OPERATION 4 ACCESS 0
ADD OPTION aRotina Title STR0005		Action 'VIEWDEF.AGRA850'	OPERATION 5 ACCESS 0
ADD OPTION aRotina Title STR0006		Action 'VIEWDEF.AGRA850'	OPERATION 7 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
Modelo de dados da rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 16/02/2013
@Uso: SIGAAGR(UBS)
/*/
// -------------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel   	:= Nil
Local oStruNPF 	:= FwFormStruct( 1, "NPE" ) // Amostra do Lote de Sementes

// Instancia o model
oModel := MpFormModel():New( 'AGRA850',/*bPre*/,,/*bPos*/, /*bCancel*/ )
oModel:SetDescription( STR0007 )

oModel:AddFields( 'NPEMASTER', /*cOwner*/, oStruNPF )
oModel:GetModel( 'NPEMASTER' ):SetDescription( STR0001 )

Return oModel

/*/{Protheus.doc} ViewDef
Interface da Rotina

@param: Nil
@author: Aecio Ferreira Gomes
@since: 16/02/2013
@Uso: AGRA850
/*/
// -------------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= Nil
Local oModel	:= FwLoadModel( "AGRA850" )
Local oStruNPE  := FwFormStruct( 2, "NPE" ) // Amostra do Lote de Sementes
               
// Instancia a View
oView := FwFormView():New()

// Seta o modelo de dados
oView:SetModel( oModel )

// Adiciona os atributos da estrutura da view
oView:AddField( 'VIEW_NPE', oStruNPE, 'NPEMASTER' )

// Monta o box horizontal
oView:CreateHorizontalBox( 'TOTAL', 100 )

// Seta Owner da Interface
oView:SetOwnerView( 'VIEW_NPE', 'TOTAL' )

Return oView

/*/{Protheus.doc} AGR850CPO
Validação de campos

@param: Nil
@author: Aecio Ferreira Gomes
@since: 16/02/2013
@Uso: AGRA850
/*/
// -------------------------------------------------------------------------------------
Function AGR850CPO()
Local aArea     := GetArea()
Local oModel    := Nil
Local lRet      := .T.
Local oModelNPE := nil
Local cCodSaf   := ""

    If ValType( __oViewNPE) != "U" // Verifica se a View NPE não é Nula
		oModel := VIEW_NPE:GetModel() // Obtém o Model
	Else
		oModel := FWModelActive() // Obtém o Model Ativo
	EndIf

oModelNPE := oModel:GetModel("NPEMASTER") // Obtém o submodelo da NPE
 
If ReadVar() == "M->NPE_CODSAF"
	lRet := Vazio() .Or.	ExistCPO("NJU") 
	
	If lRet .And. !Empty(M->NPE_LOTE)
		NP9->(dbSetOrder(3))
		If !(lRet := NP9->(dbSeek(xFilial("NP9")+M->( NPE_CODSAF+NPE_LOTE) ) ) )
			Help( ,1,"AGR850LOTE", , "O Lote informado não pertence a está safra!" , 1 , 0)
		EndIf

		If lRet
			lRet := ExistChav("NPE",M->( NPE_CODSAF+NPE_LOTE+NPE_CODIGO ),2)
		EndIf

	EndIf 	
ElseIf 'NPE_CODPRO' $ Readvar()
       oModelNPE:ClearField('NPE_LOTE')
       oModelNPE:ClearField('NPE_2UM')
       oModelNPE:ClearField('NPE_QTDEL')
       oModelNPE:ClearField('NPE_CTVAR')
       oModelNPE:ClearField('NPE_CATEG')
       oModelNPE:ClearField('NPE_PENE')
ElseIf ReadVar() == "M->NPE_LOTE"
   IF M->NPE_CODSAF == NIL   //INDICA QUE NAO FOI NO F3LOOKUP
      cCodSaf := CriaVar("NPE_CODSAF", .F.)
      cCodSaf := NPE->NPE_CODSAF
   ELSE
      cCodSaf := M->NPE_CODSAF 
   ENDIF
 	lRet :=	Vazio() .Or.;
		    ExistCPO("NP9", (cCodSaf+M->NPE_LOTE),3) .And.;
		    ExistChav("NPE",(cCodSaf+M->NPE_LOTE+M->NPE_CODIGO),2)	 	
EndIf

RestArea(aArea)
Return lRet
