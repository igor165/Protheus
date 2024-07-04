#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSA260BCP
Funcao para abrir a tela de cadastro de documentos obrigatorios 
@author Vinicius Queiros
@since 20/09/2019
@version P12
/*/
//-------------------------------------------------------------------

Function PLSA260BCP(lAutomato)

Local oBrowse := FWmBrowse():New()
oBrowse:SetAlias("BA1")
oBrowse:SetDescription(FunDesc())
oBrowse:SetMenuDef("PLSA260BCP")
If(!lAutomato,oBrowse:Activate(),)

Return (NIL)

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Definicao do modelo MVC PLSA260BCP 
@author  Vinicius Queiros
@version P12
@since 20/09/2019   
/*/
//-------------------------------------------------------------------

Static Function ModelDef()

Local oModel
Local oStruBA1      := FWFormStruct(1,"BA1" , {|x|  Alltrim(x)+"|" $ "BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_TIPREG!BA1_NOMUSR"})
Local oStruBCP      := FWFormStruct(1,"BCP")
Local aCamposBA1	:= {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC","BA1_TIPREG","BA1_NOMUSR"} // Campos a serem adicionado na estrutura
Local aCamposBCP	:= {} 
Local nNx
Local oEvent        := PL260BCPEVDEF():New()	

oModel := MPFormModel():New("PLSA260BCP")

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCamposBA1)
    oStruBA1 := CriaCampMVC(1,oStruBA1,aCamposBA1[nNx]) 
Next

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCamposBCP)
    oStruBCP := CriaCampMVC(1,oStruBCP,aCamposBCP[nNx]) 
Next

oModel:AddFields("BA1MASTER",/*cOwner*/,oStruBA1)
oModel:AddGrid("BCPDETAIL","BA1MASTER",oStruBCP)

oModel:GetModel("BCPDETAIL"):SetOptional( .T. )

oModel:SetRelation("BCPDETAIL",{{"BCP_FILIAL","xFilial('BCP')"},;
                                {"BCP_CODOPE","BA1_CODINT"},;
                                {"BCP_CODEMP","BA1_CODEMP"},;
                                {"BCP_MATRIC","BA1_MATRIC"},;
                                {"BCP_TIPREG","BA1_TIPREG"}},;
                                BCP->(IndexKey(1)))
oModel:SetDescription(FunDesc())

oModel:GetModel("BA1MASTER"):SetDescription("Beneficiário")
oModel:GetModel("BCPDETAIL"):SetDescription("Documentos Obrigatórios")

oModel:GetModel("BA1MASTER"):SetOnlyQuery(.T.)
oModel:GetModel("BA1MASTER"):SetOnlyView(.T.)
	
oStruBCP:setProperty( 'BCP_CODOPE', MODEL_FIELD_INIT, { || BA1->BA1_CODINT} )
oStruBCP:setProperty( 'BCP_CODEMP', MODEL_FIELD_INIT, { || BA1->BA1_CODEMP} )
oStruBCP:setProperty( 'BCP_MATRIC', MODEL_FIELD_INIT, { || BA1->BA1_MATRIC} )
oStruBCP:setProperty( 'BCP_TIPREG', MODEL_FIELD_INIT, { || BA1->BA1_TIPREG} )
oStruBCP:setProperty( 'BCP_DATINC', MODEL_FIELD_VALID, { || PLVALVIDCMVC("BCP",oModel)})
oStruBCP:setProperty( 'BCP_DATVAL', MODEL_FIELD_VALID, { || PLVALVIDCMVC("BCP",oModel)})
oStruBCP:setProperty( 'BCP_CODDOC', MODEL_FIELD_VALID, { || VAZIO() .OR. (ExistCpo("BD2",oModel:GetValue("BCPDETAIL","BCP_CODDOC"),1) .AND. PLVALVIDCMVC("BCP",oModel)) })

oModel:SetPrimaryKey( { "BCP_FILIAL", "BCP_CODDOC","BCP_CODOPE", "BCP_CODEMP", "BCP_MATRIC","BCP_TIPREG" } )


//Instala o evento padrão do programa.
oModel:InstallEvent("PL260BCPEVDEF",/*cOwner*/,oEvent)


Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Definicao da view MVC PLSA260BCP 
@author  Vinicius Queiros
@version P12
@since 20/09/2019  
/*/
//-------------------------------------------------------------------

Static Function ViewDef()

Local oView
Local oStruBA1 := FWFormStruct(2,"BA1",{ |cCampo| AllTrim(cCampo) $ "BA1_CODINT|BA1_CODEMP|BA1_MATRIC|BA1_NOMUSR|" } )
Local oStruBCP := FWFormStruct(2,"BCP")
Local oModel   := FWLoadModel("PLSA260BCP")
Local aCampos  := {"BA1_CODINT","BA1_CODEMP","BA1_MATRIC"} // Campos a serem adicionado na estrutura
Local nNx

oView := FWFormView():New()
oView:SetModel(oModel)

// Cria os campos na estrutura que estão como não usados no dicionario
For nNx := 1 To Len(aCampos)
    oStruBA1 := CriaCampMVC(2,oStruBA1,aCampos[nNx],StrZero(nNx,2))
Next

oView:AddField("VIEWBA1",oStruBA1,"BA1MASTER")
oView:AddGrid("VIEWBCP",oStruBCP,"BCPDETAIL")

//Remove os campos da tela
oStruBCP:RemoveField("BCP_CODOPE")
oStruBCP:RemoveField("BCP_CODEMP")
oStruBCP:RemoveField("BCP_MATRIC")
oStruBCP:RemoveField('BCP_TIPREG')

oStruBA1:SetNoFolder()
oStruBCP:SetNoFolder()

oView:CreateHorizontalBox("SUPERIOR",25)
oView:CreateHorizontalBox("INFERIOR",75)

oView:SetOwnerView("VIEWBA1","SUPERIOR")
oView:SetOwnerView("VIEWBCP","INFERIOR")

oView:EnableTitleView("VIEWBA1","Beneficiário")
oView:EnableTitleView("VIEWBCP","Documentos Obrigatórios")

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Definicao do menu MVC PLSA260BCP 
@author  Vinicius Queiros
@version P12
@since 20/09/2019   
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

Return aRotina

//----------------------------------------------------------------
/*/{Protheus.doc} PLVALVIDCMVC
--Substitui a função PLSVLDVIG
Validacao da vigencia
@author  Vinicius Queiros
@version P12
@since   20/09/2019
/*/
//----------------------------------------------------------------
Function PLVALVIDCMVC(cAlias, oModel)

Local lRet      := .T.
Local nQTD      := ""
Local nLinha    := ""
Local dVigIni   := ""
Local dVigFim   := ""
Local nI        := 0
Local cModel    := ""
Local cCmpIni   := ""
Local cCmpFim   := ""
Local cCmpCod   := ""

If EMPTY(oModel:GetValue("BCPDETAIL","BCP_DATINC"))
	Return lRet
EndIf

cModel  := "BCPDETAIL"
cCmpIni := "BCP_DATINC"
cCmpFim := "BCP_DATVAL"
cCmpCod := "BCP_CODDOC"

nQTD    := oModel:GetModel(cModel):Length(.T.)
nLinha  := oModel:GetModel(cModel):GetLine()
dVigIni := oModel:GetValue(cModel,cCmpIni)
dVigFim := oModel:GetValue(cModel,cCmpFim)
cCodDoc := oModel:GetValue(cModel,cCmpCod)  

//Verifico se a vigência final é maior que a inicial.
If !Empty(dVigFim) .AND. dVigIni > dVigFim
    Help( ,, "Atenção",, "Vigência Final maior que a Inicial", 1, 0 )
    lRet := .F.
    Return(lRet)
EndIf

//Verifico se já existe uma vigência em aberto
If nQtd > 1
    For nI := 1 To nQtd
        If nI <> nLinha
            oModel:GetModel(cModel):GoLine(nI)
            If !Empty(cCodDoc) .AND. !oModel:GetModel(cModel):IsDeleted()
                If cCodDoc == oModel:GetValue(cModel,cCmpCod)//Tipos diferentes podem ter vigencias iguais.
                    Do Case
                    Case dVigIni >= oModel:GetValue(cModel,cCmpIni) .AND. dVigIni <= oModel:GetValue(cModel,cCmpFim)//Verifico se estão no mesmo intervalo                
                        Help( ,, "Atenção",, "Já existe um intervalo de data que compreende a data selecionada!", 1, 0 )
                        lRet := .F.
                        EXIT
                    EndCase
                EndIf
            EndIf

        EndIf        
    Next nI
else
   lRet := .T.
EndIf

//Retorno o Grid para a posição original
If nQtd > 1
    oModel:GetModel(cModel):GoLine(nLinha)
EndIf

Return (lRet)
