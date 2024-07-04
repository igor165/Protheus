#INCLUDE "PROTHEUS.CH"
#INCLUDE "TMSAI84.CH"
#INCLUDE "FWMVCDEF.CH"

/*{Protheus.doc} TMSAI84
Histórico de Integrações
@type Function
@author Valdemar Roberto Mognon
@since 02/03/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example TMSAI84()
(examples)
@see (links_or_references)
*/

Function TMSAI84()
Local oBrowse := Nil

Private aRotina := MenuDef()

oBrowse:= FWMBrowse():New()   
oBrowse:SetAlias("DNC")
oBrowse:SetMenuDef("TMSAI84")
oBrowse:SetDescription(STR0001)	//-- Histórico de Integrações

oBrowse:AddLegend("DNC->DNC_STATUS=='1'","GREEN" ,STR0022)	//-- Integrado
oBrowse:AddLegend("DNC->DNC_STATUS=='2'","BLUE"  ,STR0023)	//-- Não Integrado
oBrowse:AddLegend("DNC->DNC_STATUS=='3'","YELLOW",STR0024)	//-- Erro Envio
oBrowse:AddLegend("DNC->DNC_STATUS=='4'","PINK"  ,STR0025)	//-- Erro Retorno
oBrowse:AddLegend("DNC->DNC_STATUS=='5'","BROWN" ,STR0026)	//-- Estornado
oBrowse:AddLegend("DNC->DNC_STATUS=='6'","BLACK" ,STR0027)	//-- Estornado Envio

oBrowse:Activate()

Return

/*{Protheus.doc} MenuDef
    Definição do aRotina (Menu funcional)
    @type Static Function
    @author Valdemar Roberto Mognon
    @since 02/03/2022
    @version P12 R12.1.29
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example MenuDef()
    (examples)
    @see (links_or_references)
*/
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"        OPERATION 1 ACCESS 0	//-- Pesquisar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.TMSAI84" OPERATION 2 ACCESS 0	//-- Visualizar

Return (aRotina)

/*{Protheus.doc} ModelDef
Definição do Modelo
@type Static Function
@author Valdemar Roberto Mognon
@since 02/03/2022
@version P12 R12.1.20
@param param, param_type, param_descr
@return return, return_type, return_description
@example ModelDef()
(examples)
@see (links_or_references)
*/

Static Function ModelDef()
Local oModel
Local oStruDNC := FwFormStruct(1,"DNC")
Local oStruDN5 := FwFormStruct(1,"DN5")

oModel := MpFormModel():New("TMSAI84", /*bPreValidacao*/, /*bPosValidacao*/ , /*bCommit*/ , /*bCancel*/ )
oModel:SetDescription(STR0001)	//-- Histórico de Integrações

//-- Cabeçalho
oModel:AddFields("MdFieldDNC",,oStruDNC,,,)
oModel:SetPrimaryKey({"DNC_CODFON","DNC_PROCES","DNC_LOCALI"})
oModel:GetModel("MdFieldDNC"):SetDescription(STR0001)	//-- Histórico de Integrações

//-- Itens
//-- Histórico
oModel:AddGrid("MdGridDN5","MdFieldDNC",oStruDN5,,,,,)
oModel:SetRelation("MdGridDN5",{{"DN5_FILIAL","xFilial('DN5')"},;
								{"DN5_CODFON","DNC_CODFON"},;
								{"DN5_PROCES","DNC_PROCES"}},;
								DN5->(IndexKey(5)))
oModel:GetModel("MdGridDN5"):SetDescription(STR0007)	//-- Histórico
oModel:GetModel("MdGridDN5"):SetUniqueLine({"DN5_SEQUEN"})

Return oModel

/*{Protheus.doc} ViewDef
Definição da View
@type Static Function
@author Valdemar Roberto Mognon
@since 02/03/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example ViewDef()
(examples)
@see (links_or_references)
*/
Static Function ViewDef()
Local oModel   := FwLoadModel("TMSAI84")
Local oStruDNC := FwFormStruct(2,"DNC")
Local oStruDN5 := FwFormStruct(2,"DN5")
Local oView

//oStruDN5:RemoveField("DN5_CONTEU")
//oStruDN5:RemoveField("DN5_MOTIVO")
oStruDN5:RemoveField("DN5_CHAVE")
oStruDN5:RemoveField("DN5_PROCES")
oStruDN5:RemoveField("DN5_LOCALI")
oStruDN5:RemoveField("DN5_FILORI")

oView := FwFormView():New()
oView:SetModel(oModel)

//-- Define o tamanho da tela principal
oView:CreateHorizontalBox("Cabecalho",030)
oView:CreateHorizontalBox("Itens",069)

//-- Cria área da tabela pai
oView:AddField("VwFieldDNC",oStruDNC,"MdFieldDNC") 
oView:EnableTitleView("VwFieldDNC",STR0001)	//-- Histórico de Integrações
oView:SetOwnerView("VwFieldDNC","Cabecalho")

//-- Cria área das tabelas filhas
//-- Histórico
oView:AddGrid("VwGridDN5",oStruDN5,"MdGridDN5")
oView:EnableTitleView("VwGridDN5",STR0007)	//-- Histórico
oView:SetOwnerView("VwGridDN5","Itens")
oView:AddIncrementField("VwGridDN5","DN5_SEQUEN")

oView:AddUserButton(STR0013,"",{|oModel| I84NewRepr() })	//-- Reprocessa

oView:SetViewProperty("VwGridDN5","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| I84DblClick(oFormulario,cFieldName,nLineGrid,nLineModel)}})

Return oView

/*{Protheus.doc} VisReg
Visualiza o Registro
@type Static Function
@author Valdemar Roberto Mognon
@since 15/03/2022
@version P12 R12.1.29
@param param, param_type, param_descr
@return return, return_type, return_description
@example VisReg()
(examples)
@see (links_or_references)
*/
Function VisReg()
Local aCpos     := {}
Local aObjs     := {}
Local aCoors    := FWGetDialogSize( oMainWnd )
Local aLayout   := {}
Local nCntFor1  := 0
Local oDlgReg AS Object
Local lOpcOk    := .F.
Local cConteudo := ""
Local aButtons  := { { 'BMPUSER', {|| TMSAI84Edt() }, STR0033, STR0033 } }

Private aConteudo := {}
Private lAlter    := .F.

    aLayout   := BscLayout(FwFldGet("DNC_CODFON"),FwFldGet("DN5_CODREG"))
    aConteudo := QuebraReg(FwFldGet("DNC_CODFON"),FwFldGet("DN5_CODREG"),FwFldGet("DN5_SEQUEN"),Aclone(aLayout))
    For nCntFor1 := 1 To Len(aLayout)
        Aadd(aCpos,{"aConteudo[" + StrZero(nCntFor1,4) + "]",1,aLayout[nCntFor1,1],{aLayout[nCntFor1,5],aLayout[nCntFor1,6],aLayout[nCntFor1,4]},AllTrim(X3Picture(aLayout[nCntFor1,3])),.F.,"lAlter",,,,})
    Next nCntFor1

    If !Empty(aConteudo)
        DEFINE MSDIALOG oDlgReg TITLE STR0008 FROM aCoors[1], aCoors[2] TO aCoors[3], aCoors[4] PIXEL	//-- Registro
        DinamicEnc(oDlgReg,aCpos,,@aObjs)
        ACTIVATE MSDIALOG oDlgReg CENTERED ON INIT EnchoiceBar( oDlgReg, {|| oDlgReg:End(), lOpcOk := .T. }, {|| oDlgReg:End() }, , aButtons )
    EndIf

    If lAlter .And. lOpcOk
        DN5->(DbSetOrder(1))
        If DN5->(MsSeek(xFilial("DN5")+FwFldGet("DNC_CODFON")+FwFldGet("DN5_CODREG")+FwFldGet("DN5_SEQUEN")))
            AEval(aConteudo,{|x| cConteudo += x })
            RecLock("DN5",.F.)
            DN5->DN5_CONTEU := cConteudo
            MsUnLock()
            If MsgYesNo(STR0031)
                I84NewRepr(.T.)
                FWMsgrun(,{|| TMSAI86AUX(FwFldGet("DNC_PROCES")) }, STR0029, STR0030 )
            EndIf
        EndIf
    EndIf
Return lOpcOk

/*{Protheus.doc} I84DblClick
Apresenta histórico de integração do Registro (campo DN5_MOTIVO)
@author Carlos Alberto Gomes Junior
@since 30/05/22
*/
Static Function I84DblClick(oModel,cFieldName,nLineGrid,nLineModel)
DEFAULT cFieldName := ""
    Do Case
        Case cFieldName == "DN5_MOTIVO"
            TMSErrDtl(FwFldGet("DN5_MOTIVO"))
        Case cFieldName == "DN5_CONTEU"
            VisReg()
    EndCase
Return

/*{Protheus.doc} I84NewRepr
Gera novo registro de histórico do registro posicionado para reprocessamento
@author Carlos Alberto Gomes Junior
@since 30/05/22
*/
Static Function I84NewRepr(lEdit)
Local aAreas    := {DN5->(GetArea()),GetArea()}
Local cQuery    := ""
Local cAliasQry := GetNextAlias()
DEFAULT lEdit := .F.

    cQuery := "SELECT "
    cQuery += "R_E_C_N_O_ DN5REG FROM "+RetSQLName("DN5")+" " + CRLF
    cQuery += "WHERE " + CRLF
    cQuery += "DN5_FILIAL = '" + xFilial("DN1") + "' AND " + CRLF
    cQuery += "DN5_CODFON = '" + FwFldGet("DNC_CODFON") + "' AND " + CRLF
    cQuery += "DN5_PROCES = '" + FwFldGet("DNC_PROCES") + "' AND " + CRLF
    cQuery += "DN5_STATUS IN ('3','4','7') AND " + CRLF
    cQuery += "D_E_L_E_T_ = '' " + CRLF

    cQuery := ChangeQuery(cQuery)
    DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),cAliasQry,.F.,.T.)

    If !(cAliasQry)->(Eof()) 
        Do While !(cAliasQry)->(Eof())
            DN5->(DbGoTo((cAliasQry)->DN5REG))
            RecLock("DN5",.F.)
            If DN5->DN5_STATUS $ "37" // Erro de envio
                DN5->DN5_SITUAC := "1"
                DN5->DN5_STATUS := "2"
            ElseIf DN5->DN5_STATUS == "4" // Erro de Retorno
                DN5->DN5_SITUAC := "2"
                DN5->DN5_STATUS := "1"
            EndIf
            MsUnlock()
            (cAliasQry)->(DbSkip()) 
        EndDo
        If lEdit .Or. MsgYesNo(STR0031)
            FWMsgrun(,{|| TMSAI86AUX(FwFldGet("DNC_PROCES")) }, STR0029, STR0030 )
        EndIf
    Else
        Help(" ", , "TMSAI84001" + "-" + STR0018, , STR0028 , 2, 1)
    EndIf

    (cAliasQry)->(DbCloseArea())
    AEval(aAreas,{|aArea| RestArea(aArea), FwFreeArray(aArea) })
    FwFreeArray(aAreas)

Return

/*{Protheus.doc} TMSAI84Edt
Habilita a edição de registros
@author Carlos Alberto Gomes Junior
@since 26/08/22
*/
Function TMSAI84Edt
    If FwFldGet("DN5_STATUS") == "3"
        lAlter := MsgNoYes(STR0032)
    Else
        Help(" ", , STR0033, , STR0034, 2, 1)    
    EndIf
Return
