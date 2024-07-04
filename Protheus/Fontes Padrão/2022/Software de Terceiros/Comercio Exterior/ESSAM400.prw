#include 'protheus.ch'
#include 'parmtype.ch'
#Include "Average.ch"
#Include "FWMVCDEF.CH"
#include "Fileio.ch"

Static aModels := {}

/*
Funcao     : ESSAM400()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Rotina de Amarração de Empresas
Autor      : Guilherme Fernandes Pilan - GFP
Data/Hora  : 16/03/2016 :: 16:44
*/
*-------------------*
Function ESSAM400()
*-------------------*
Local oBrowse
oBrowse := FWMBrowse():New()
oBrowse:SetAlias("ELM")
oBrowse:SetMenuDef("ESSAM400")
oBrowse:SetDescription(TESX2Name("ELM"))
oBrowse:Activate()

Return Nil

*----------------------------------------*
Function ESSAM400_MVC(nOpcAuto,xAutoCab)
*----------------------------------------*
Private lAM400Auto  := ValType(xAutoCab) <> "U" .And. ValType(nOpcAuto) <> "U"
Private lMsErroAuto := .F.
Private aRotina
Private oModelAuto

/* trecho nopado por RNLP função declarada como static em outro fonte(ESSRS400)
nOpcAuto := ValidaOperacao(nOpcAuto, aCab, aItens, aAnexos)
*/

INCLUI := nOpcAuto == INCLUIR
ALTERA := nOpcAuto == ALTERAR
EXCLUI := nOpcAuto == EXCLUIR
      
aRotina := MenuDef()
      
If (nPos := aScan(aModels,{|X| X[1] == cTipo})) == 0
   aAdd(aModels,{cTipo,ModelDef()})
   nPos := Len(aModels)
EndIf
oModelAuto := aModels[nPos][2]

If lAM400Auto      
   lMsErroAuto := !EasyMVCAuto("ESSAM400",nOpcAuto,{"ELMMASTER" , xAutoCab})
   If lMsErroAuto
      AEval(oAvObject:aError,{|X| AutoGrLog(x)})
   EndIf
EndIf

Return lMsErroAuto

*------------------------*
Static Function MenuDef()
*------------------------*
Local aRotina  := {}

ADD OPTION aRotina TITLE "Pesquisar"            ACTION "AxPesqui"         OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE "Visualizar"           ACTION "VIEWDEF.ESSAM400" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Incluir"              ACTION "VIEWDEF.ESSAM400" OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE "Alterar"              ACTION "VIEWDEF.ESSAM400" OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE "Excluir"              ACTION "VIEWDEF.ESSAM400" OPERATION 5 ACCESS 0

Return aRotina

*-------------------------*
Static Function ModelDef()
*-------------------------*
Local oStruELM      := FWFormStruct(1,"ELM",,)
Local oModel

oModel := MPFormModel():New("ESSAM400", /*bGridValidacao*/, /*bPosValidacao*/ , /*bCommit*/, /*bCancel*/)

//Modelo para criação da antiga Enchoice com a estrutura da tabela ELM
oModel:AddFields("ELMMASTER", /*nOwner*/, oStruELM) 

//Adiciona a descrição do Modelo de Dados
oModel:SetDescription(TESX2Name("ELM"))
oModel:GetModel("ELMMASTER"):SetDescription(TESX2Name("ELM")) //Título da Capa

Return oModel
*------------------------*
Static Function ViewDef()
*------------------------*
//Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel("ESSAM400")
//Cria a estrutura a ser usada na View
Local oStruELM := FWFormStruct(2,"ELM",,)
Local oView

oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( 'VIEW_ELM', oStruELM, 'ELMMASTER' )

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TOTAL' , 100 )

oView:SetOwnerView( 'VIEW_ELM', 'TOTAL' )

//Liga a identificação do componente
oView:EnableTitleView("VIEW_ELM", "Relação Adquirente X Vendedor", RGB(240,248,255)) 

//Habilita ButtonsBar
oView:EnableControlBar(.T.)


Return oView

*---------------------------*
Function AM400Valid(cCampo)
*---------------------------*
Local lRet := .T.
Local cLojaCli := ""
Local cLojaFor := ""
Local oModel := FWModelActive()
Local cAdquirente := AllTrim(oModel:GetValue("ELMMASTER", "ELM_CODCLI")) + "/" + AllTrim(oModel:GetValue("ELMMASTER", "ELM_LOJCLI"))
Local cVendedor   := AllTrim(oModel:GetValue("ELMMASTER", "ELM_CODFOR")) + "/" + AllTrim(oModel:GetValue("ELMMASTER", "ELM_LOJFOR"))
Local cDescricao  := "Vinculação "
Default cCampo := StrTran(ReadVar(),"M->","")

   Do Case
      Case cCampo == "ELM_CODCLI" .OR. cCampo == "ELM_LOJCLI"
         SA1->(DbSetOrder(1))
         If !SA1->(DbSeek(xFilial("SA1") + oModel:GetValue("ELMMASTER", "ELM_CODCLI") + If(!Empty(oModel:GetValue("ELMMASTER", "ELM_LOJCLI")),oModel:GetValue("ELMMASTER", "ELM_LOJCLI"),"")))
            lRet := .F.
            EasyHelp("Registro não localizado. Informe um registro válido.","Aviso")
         EndIf
         
         cDescricao += If(cAdquirente <> "/","Adquirente " + cAdquirente,"")
         cDescricao += If(cAdquirente <> "/" .AND. cVendedor <> "/"," X ","")
         cDescricao += If(cVendedor <> "/","Vendedor " + cVendedor,"")
         oModel:LoadValue("ELMMASTER", "ELM_DESC", cDescricao)
         
         /*If Empty(oModel:GetValue("ELMMASTER", "ELM_LOJCLI"))
            oModel:SetValue("ELMMASTER", "ELM_LOJCLI", SA1->A1_LOJA)
         EndIf*/
         
         If cCampo == "ELM_LOJCLI"
            cLojaFor := AvKey(Posicione("SA1",1,xFilial("SA1") + M->ELM_CODCLI + M->ELM_LOJCLI,"A1_NOME"),"ELM_DESCLI")
            oModel:SetValue("ELMMASTER", "ELM_DESCLI", cLojaFor)
         EndIf
         
         //MCF - 03/08/2016
         If !ExistChav("ELM",oModel:GetValue("ELMMASTER", "ELM_CODCLI") + oModel:GetValue("ELMMASTER", "ELM_LOJCLI") + oModel:GetValue("ELMMASTER", "ELM_CODFOR") + oModel:GetValue("ELMMASTER", "ELM_LOJFOR"))
            lRet := .F.
         EndIf
         
      Case cCampo == "ELM_CODFOR" .OR. cCampo == "ELM_LOJFOR"
         SA2->(DbSetOrder(1))
         If !SA2->(DbSeek(xFilial("SA2") + oModel:GetValue("ELMMASTER", "ELM_CODFOR") + If(!Empty(oModel:GetValue("ELMMASTER", "ELM_LOJFOR")),oModel:GetValue("ELMMASTER", "ELM_LOJFOR"),"")))
            lRet := .F.
            EasyHelp("Registro não localizado. Informe um registro válido.","Aviso")
         EndIf
         
         cDescricao += If(cAdquirente <> "/","Adquirente " + cAdquirente,"")
         cDescricao += If(cAdquirente <> "/" .AND. cVendedor <> "/"," X ","")
         cDescricao += If(cVendedor <> "/","Vendedor " + cVendedor,"")
         oModel:LoadValue("ELMMASTER", "ELM_DESC", cDescricao)

         /*If Empty(oModel:GetValue("ELMMASTER", "ELM_LOJFOR"))
            oModel:SetValue("ELMMASTER", "ELM_LOJFOR", SA2->A2_LOJA)
         EndIf*/
         
         If cCampo == "ELM_LOJFOR"
            cLojaCli := AvKey(Posicione("SA2",1,xFilial("SA2") + M->ELM_CODFOR + M->ELM_LOJFOR,"A2_NOME"),"ELM_DESCFO")
            oModel:SetValue("ELMMASTER", "ELM_DESCFO", cLojaCli)
         EndIf
         
         //MCF - 03/08/2016
         If cCampo == "ELM_LOJFOR"
            If !ExistChav("ELM",oModel:GetValue("ELMMASTER", "ELM_CODCLI") + oModel:GetValue("ELMMASTER", "ELM_LOJCLI") + oModel:GetValue("ELMMASTER", "ELM_CODFOR") + oModel:GetValue("ELMMASTER", "ELM_LOJFOR"))
               lRet := .F.
            EndIf
         EndIf
         
   End Case

Return lRet

*---------------------------*
Function AM400Relacao(cCampo)
*---------------------------*
Local cConteudo := ""
Local oModel := FWModelActive()
Local nOperacao := oModel:GetOperation()

If cCampo == "ELM_DESCLI"
   cConteudo := If(nOperacao <> 3,AvKey(Posicione("SA1",1,xFilial("SA1") + ELM->ELM_CODCLI + ELM->ELM_LOJCLI,"A1_NOME"),"ELM_DESCLI"),"")
ElseIf cCampo == "ELM_DESCFO"
   cConteudo := If(nOperacao <> 3,AvKey(Posicione("SA2",1,xFilial("SA2") + ELM->ELM_CODFOR + ELM->ELM_LOJFOR,"A2_NOME"),"ELM_DESCFO"),"")
EndIf

Return cConteudo
