#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI85.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAI85
Filiais de Integração
@author Carlos A. Gomes Jr.
@since 25/05/2022
*/
Function TMSAI85()
Local oBrowse := Nil
Private aRotina := MenuDef()

    oBrowse:= FWMBrowse():New()   
    oBrowse:SetAlias("DN8")
    oBrowse:SetMenuDef("TMSAI85")
    oBrowse:SetDescription(STR0001)	//-- Filiais de Integração
    oBrowse:Activate()

Return

/*{Protheus.doc} MenuDef
Definição do aRotina (Menu funcional)
@author Carlos A. Gomes Jr.
@since 25/05/2022
*/
Static Function MenuDef()
Local aRotina := {}

    ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0	//-- Pesquisar
    ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAI85" OPERATION 2 ACCESS 0	//-- Visualizar
    ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.TMSAI85" OPERATION 3 ACCESS 0	//-- Incluir
    ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.TMSAI85" OPERATION 4 ACCESS 0	//-- Alterar
    ADD OPTION aRotina TITLE STR0006 ACTION "VIEWDEF.TMSAI85" OPERATION 5 ACCESS 0	//-- Excluir

Return (aRotina)

/*{Protheus.doc} ModelDef
Definição do Modelo
@author Carlos A. Gomes Jr.
@since 25/05/2022
*/
Static Function ModelDef()
Local oModel
Local oStruDN8 := FwFormStruct(1,"DN8")

    oModel := MpFormModel():New("TMSAI85", /*bPreValidacao*/, /*bPosValidacao*/ , /*bCommit*/ , /*bCancel*/ )
    oModel:SetDescription(STR0001)	//-- Fontes de Integração
    oModel:AddFields("MdFieldDN8",,oStruDN8,,,)
    oModel:SetPrimaryKey({"DN8_CODIGO"})
    oModel:GetModel("MdFieldDN8"):SetDescription(STR0001)	//-- Fontes de Integração

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@author Carlos A. Gomes Jr.
@since 25/05/2022
*/
Static Function ViewDef()
Local oModel   := FwLoadModel("TMSAI85")
Local oStruDN8 := FwFormStruct(2,"DN8")
Local oView

    oView := FwFormView():New()
    oView:SetModel(oModel)

    oView:CreateHorizontalBox("Cabecalho",100)
    oView:AddField("VwFieldDN8",oStruDN8,"MdFieldDN8") 
    oView:EnableTitleView("VwFieldDN8",STR0001)	//-- Fontes de Integração
    oView:SetOwnerView("VwFieldDN8","Cabecalho")

Return oView

/*{Protheus.doc} TMSAI85Fil
Realiza a consulta no rac pelas unidades cadastradas no tenant
@author Carlos A. Gomes Jr.
@since 26/05/22
*/
Function TMSAI85Fil()

Local lRet := .F.
Local aExec		As Array
Local oDlg		As Object
Local oListBox	As Object

    Var_IXB := ""
    aExec   := TMSAI85GUn(M->DN8_CODFON)
	If Len(aExec) > 0
		DEFINE MSDIALOG oDlg TITLE STR0007 FROM 180, 180 TO 530, 910 PIXEL
			@ 005, 005 LISTBOX oListBox FIELDS HEADER STR0008, STR0009, STR0010 SIZE 360, 150 OF oDlg PIXEL
			oListBox:SetArray( aExec )
			oListBox:bLine := { | | { 	aExec[oListBox:nAt][1],;
										aExec[oListBox:nAt][2],;
										aExec[oListBox:nAt][3] } }
			DEFINE SButton FROM 160, 300 TYPE 1 ENABLE OF oDlg ACTION ( lRet := .T., Var_IXB := aExec[oListBox:nAt][3], oDlg:End() )
			DEFINE SButton FROM 160, 335 TYPE 2 ENABLE Of oDlg ACTION oDlg:End()
		ACTIVATE MSDIALOG oDlg CENTERED
	EndIf
    FwFreeArray(aExec)
    FWFreeObj(oDlg)
    FWFreeObj(oListBox)
    
Return lRet

/*{Protheus.doc} TMSAI85Fil
Realiza a consulta no rac pelas unidades cadastradas no tenant
@author Carlos A. Gomes Jr.
@since 26/05/22
*/
Static Function TMSAI85GUn(cCodFon)

Local nCount    := 0
Local aRet      := {}
Local aAlias    := {"DLZ","DN1"}
Local nN        := 0
Local lHasNext  := .F.
Local nPage     := 1
Local oColEnt As Object
Local oResult As Object
    
    For nN := 1 To Len(aAlias)
        If AliasInDic(aAlias[nN])
            oColEnt := TMSBCACOLENT():New(aAlias[nN])
            If oColEnt:DbGetToken() .And. oColEnt:codfon == cCodFon
                lHasNext := .T.
                Exit
            EndIf
            FWFreeObj(oColEnt)
        EndIf
    Next

    If lHasNext
        Do While lHasNext
            lHasNext := .F.
            If ( aResGet := oColEnt:Get( "foundation/query/api/v1/unidades/", "?page=" + cValtoChar(nPage) ) )[1]
                If FWJsonDeserialize( aResGet[2], @oResult )
                    If ( lHasNext := AttIsMemberOf( oResult, "hasNext" ) )
                        lHasNext := oResult:hasNext
                        nPage++
                    EndIf
                    If AttIsMemberOf( oResult, "items" )
                        For nCount := 1 To Len( oResult:items )
                            If oResult:items[nCount]:SITUACAO == "ATIVO"
                                AAdd( aRet, { Iif(!Empty(oResult:items[nCount]:NOME),DeCodeUTF8(oResult:items[nCount]:NOME),""),;
                                            Iif(!Empty(oResult:items[nCount]:APELIDO),DeCodeUTF8(oResult:items[nCount]:APELIDO),""),;
                                            oResult:items[nCount]:ID } )
                            EndIf
                        Next 
                    EndIf
                EndIf
            Else
                Help(" ", , "TMSAI8501-" + oColEnt:last_error, , oColEnt:desc_error, 2, 1)
                Exit
            EndIf
        EndDo

        If !Empty(aRet)
            ASort(aRet,,,{|x,y| x[1] < y[1]})
        EndIf

    EndIf

    FwFreeObj(oResult)
    FwFreeObj(oColEnt)

Return aRet
