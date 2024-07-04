#INCLUDE "PROTHEUS.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "GTPA042A.CH"

Static oModel
Static oMdlTree1
Static oMdlTree2
//------------------------------------------------------------------------------------------
/*/{Protheus.doc} GTPA42TREE()
Regra de envio de emails
 
@sample	GTPA42TREE()
 
@return	oBrowse  Retorna o Cadastro de Eventos
 
@author	Renan Ribeiro Brando -  Inovação
@since		19/05/2017
@version	P12
/*/
//------------------------------------------------------------------------------------------
Function GTPA42TREE(oPanel)

Local oTree     := nil
Local oMenu     := TMenu():New(0, 0, 0, 0, .T., , oPanel) 
Local bAction   := {|oTree| GTPA042Act(oTree,oMenu)}

oModel  := FwModelActive()
oMdlTree1 := oModel:GetModel('TREE1')
oMdlTree2 := oModel:GetModel('TREE2')

oTree   := XTree():New(0, 0, 0, 0, oPanel,bAction ) 
oTree:Align := CONTROL_ALIGN_ALLCLIENT

LoadTree(oTree)

CreateMenu(oTree,oMenu)
oTree:SetPopUp(oMenu)

Return oTree

/*/{Protheus.doc} LoadTree()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
/*/
Static Function LoadTree(oTree)
Local n1, n2

oTree:AddTree( STR0001, 'SDUSTRUCT', 'SDUSTRUCT', "XXX")//"Regra de Aplicação"

For n1 := 1 to oMdlTree1:Length()
    If !Empty(oMdlTree1:GetValue('GY5_IDTREE',n1))
        oMdlTree1:GoLine(n1)
        
        If oMdlTree1:GetValue('GY5_IDTREE') <> 'REL'
            oTree:AddTree(oMdlTree1:GetValue('GY5_DESCRI'), 'RPMTABLE','RPMTABLE',oMdlTree1:GetValue('GY5_IDTREE'))
        Else
            oTree:AddTree(STR0002, 'RPMGROUP', 'RPMGROUP','REL') //"Relacionamento"
        Endif
        
        For n2 := 1 to oMdlTree2:Length()
            If !Empty(oMdlTree2:GetValue('GY6_SEQ',n2))
                oMdlTree2:GoLine(n2)
                oTree:AddTreeItem(oMdlTree2:GetValue('GY6_DESCRI'), "FILTRO",oMdlTree1:GetValue('GY5_IDTREE')+"_"+oMdlTree2:GetValue('GY6_SEQ'))
            Endif
        Next
        oTree:TreeSeek(oMdlTree1:GetValue('GY5_IDTREE'))
        oTree:EndTree()
    Endif
Next
Return 

/*/{Protheus.doc} GTPA042Act
    (long_description)
    @type  Static Function
    @author jacomo.fernandes
    @since 20/07/17
    @version 12
/*/
Static Function GTPA042Act(oTree,oMenu)
Local nNivel    := oTree:PtGetNivel()
Local cCargo    := oTree:GetCargo()

CreateMenu(oTree,oMenu)
If nNivel <> 1
    oMdlTree1:SeekLine({ {'GY5_IDTREE',SubStr(cCargo,1,3)} })
    If nNivel == 3
        oMdlTree2:SeekLine({ {'GY6_SEQ',SubStr(cCargo,5,3)} })
    Endif
Endif

Return nil

/*/{Protheus.doc} GTPA042Act
    (long_description)
    @type  Static Function
    @author jacomo.fernandes
    @since 20/07/17
    @version 12
/*/
Static Function CreateMenu(oTree,oMenu)
Local nNivel    := oTree:PTGetNivel()
Local cCargo    := oTree:GetCargo()
Local bDelTree  := {|| TreeDelete(oTree,oMenu)}

oMenu:Reset()

Do Case
    Case nNivel == 1 .and. (oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
        oMenu:Add(tMenuItem():new(oMenu, STR0003, , , , {|| TreeUpsert(oTree,"E",3,oMenu)}, , , , , , , , , .T.))//"Incluir Entidade"
        If aScan(oTree:ACARGO,{|x| x[1] == 'REL'}) == 0 .and. oMdlTree1:Length(.T.) >= 2
            oMenu:Add(tMenuItem():new(oMenu, STR0004, , , , {|| TreeUpsert(oTree,"R",3,oMenu)}, , , , , , , , , .T.))//"Incluir Relacionamento"
        Endif
    Case nNivel == 2 .and. (oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE)
        If SubStr(cCargo,1,3) == "REL"
            oMenu:Add(tMenuItem():new(oMenu, STR0005, , , , {|| TreeUpsert(oTree,"R",3,oMenu)}, , , , , , , , , .T.))//"Incluir Filtro"
            oMenu:Add(tMenuItem():new(oMenu, STR0006, , , , bDelTree, , , , , , , , , .T.))//"Excluir Relacionamento"
        Else
            oMenu:Add(tMenuItem():new(oMenu, STR0005, , , , {|| TreeUpsert(oTree,"E",3,oMenu)}, , , , , , , , , .T.))//"Incluir Filtro"
            oMenu:Add(tMenuItem():new(oMenu, STR0007, , , , bDelTree, , , , , , , , , .T.))//"Excluir Entidade"
        Endif
        
    Case nNivel == 3
        If oModel:GetOperation() == MODEL_OPERATION_INSERT .or. oModel:GetOperation() == MODEL_OPERATION_UPDATE
            If SubStr(cCargo,1,3) == "REL"
                oMenu:Add(tMenuItem():new(oMenu, STR0008, , , , {|| TreeUpsert(oTree,"R",1,oMenu)}, , , , , , , , , .T.))//"Visualizar Filtro"
                oMenu:Add(tMenuItem():new(oMenu, STR0009, , , , {|| TreeUpsert(oTree,"R",4,oMenu)}, , , , , , , , , .T.))//"Alterar Filtro"
            Else
                oMenu:Add(tMenuItem():new(oMenu, STR0008, , , , {|| TreeUpsert(oTree,"E",1,oMenu)}, , , , , , , , , .T.))//"Visualizar Filtro"
                oMenu:Add(tMenuItem():new(oMenu, STR0009, , , , {|| TreeUpsert(oTree,"E",4,oMenu)}, , , , , , , , , .T.))//"Alterar Filtro"
            Endif
            oMenu:Add(tMenuItem():new(oMenu, STR0010, , , , bDelTree, , , , , , , , , .T.))//"Excluir Filtro"
        Else
            If SubStr(cCargo,1,3) == "REL"
                oMenu:Add(tMenuItem():new(oMenu, STR0008, , , , {|| TreeUpsert(oTree,"R",1,oMenu)}, , , , , , , , , .T.))//"Visualizar Filtro"
            Else
                oMenu:Add(tMenuItem():new(oMenu, STR0008, , , , {|| TreeUpsert(oTree,"E",1,oMenu)}, , , , , , , , , .T.))//"Visualizar Filtro"
            Endif
        Endif
EndCase

Return oMenu

/*/{Protheus.doc} 
    (long_description)
    @type  Static Function
    @author jacomo.fernandes
    @since 20/07/17
    @version 12
/*/
Static Function TreeUpsert(oTree,cTipo,nOpc,oMenu, lAut)
Local oView     := FwViewActive()
Local nNivel    := oTree:PTGetNivel()
Local cCargo    := oTree:GetCargo()
Default cTipo   := ""
Default lAut    := .F.
oModel:lModify  := .T.
oView:lModify   := .T.

IF nNivel == 1
    cCargo  := Ga042AddEnt(oTree,cTipo)
    If cTipo <> "R" .and. oTree:TreeSeek('REL')
        AjustTree(oTree,oMenu)
    Endif    
Else
    cCargo  := Ga042AddFil(oTree,cTipo,nOpc)
EndIf

oTree:PTReset()
oTree:Display()
oTree:TreeSeek(cCargo)
CreateMenu(oTree,oMenu)

Return nil

/*/{Protheus.doc} GetNextCargo
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GetNewCarg(oTree)

Local aSaveLines:= FWSaveRows()
Local nNivel    := oTree:PTGetNivel()
Local cCargo    := "001"
Local cRet      := ""
Local n1        := 0

If nNivel == 1
    If oMdlTree1:GetLine() > 1
        For n1 := oMdlTree1:Length() -1 to 1 STEP -1
            oMdlTree1:GoLine(n1)
            If oMdlTree1:GetValue('GY5_IDTREE') <> "REL"
                cCargo := StrZero( Val( oMdlTree1:GetValue('GY5_IDTREE') ) +1 ,TamSx3('GY5_IDTREE')[1] )    
                Exit
            Endif
        Next
    Endif

    cRet := cCargo
ElseiF nNivel == 2
    If oMdlTree2:GetLine() > 1
        cCargo := StrZero(Val(oMdlTree2:GetValue('GY6_SEQ',oMdlTree2:Length()-1))+1,TamSx3('GY6_SEQ')[1])
    Endif
    cRet := oMdlTree1:GetValue('GY5_IDTREE') +"_"+ cCargo
EndIf
FWRestRows( aSaveLines )

Return cRet

/*/{Protheus.doc} 
    (long_description)
    @type  Static Function
    @author jacomo.fernandes
    @since 20/07/17
    @version 12
/*/
Static Function TreeDelete(oTree,oMenu, lAuto)
Local oView     := FwViewActive()
Local nNivel    := oTree:PTGetNivel()
oModel:lModify := .T.
oView:lModify := .T.
Default lAuto   := .F.

If !FwIsInCall('AJUSTTREE')
    IF nNivel == 2
        If oMdlTree1:DeleteLine()
            oTree:DelItem()
            oTree:TreeSeek("XXX")
        Endif
    ElseIf nNivel == 3
        oMdlTree2:DeleteLine()
        oTree:DelItem()
        oTree:TreeSeek(oMdlTree1:GetValue('GY5_IDTREE'))
    Endif
Else
    oTree:DelItem()
Endif

If !(lAuto)
    CreateMenu(oTree,oMenu)
Endif
Return nil

//-------------------------------------------------------------------
/*/{Protheus.doc} AjustTree(oTree)
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function AjustTree(oTree,oMenu)
Local n1        := 0

TreeDelete(oTree,oMenu)

If oMdlTree1:SeekLine({{'GY5_IDTREE','REL'}})
    oTree:AddTree(STR0002, 'RPMGROUP', 'RPMGROUP','REL')//"Relacionamento"
    oTree:TreeSeek('REL')

    For n1 := 1 To oMdlTree2:Length()
        If !oMdlTree2:IsDeleted(n1) .and. !Empty(oMdlTree2:GetValue('GY6_SEQ',n1))
            cCargo := oMdlTree1:GetValue('GY5_IDTREE') +"_"+ oMdlTree2:GetValue('GY6_SEQ',n1)
            oTree:AddTreeItem(oMdlTree2:GetValue('GY6_DESCRI',n1), "FILTRO",cCargo)
            oTree:TreeSeek('REL')
        Endif
    Next
    oTree:EndTree()
Endif
CreateMenu(oTree,oMenu)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Ga042AddEnt(oTree)
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function Ga042AddEnt(oTree,cTipo, lAuto)

Local oModelGY5 := nil
Local cNewCargo := ""
Default lAuto   := .F.

If cTipo == "E"
    oModelGY5 := FwLoadModel('GTPA042D')
    oModelGY5:SetCommit( {|oModel|  Ga042Comit( oModel,oTree, lAuto ) } )
    oModelGY5:SetOperation(3)
    oModelGY5:Activate()

    FWExecView( STR0014,"VIEWDEF.GTPA042D",3, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,75/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,oModelGY5 )	//"'Entidade'"
Else
    IF !lAuto
        If !Empty(oMdlTree1:GetValue('GY5_IDTREE'))
            oMdlTree1:Addline()
        Endif
    Endif

    cNewCargo := "REL"

    IF !lAuto
        oTree:AddTree(STR0002, 'RPMGROUP', 'RPMGROUP','REL')//"Relacionamento"
        oMdlTree1:SetValue('GY5_IDTREE','REL')
        oMdlTree1:SetValue('GY5_DESCRI',STR0002)//"Relacionamento"
        oTree:EndTree()
    EndIf
EndIf

Return cNewCargo

/*/{Protheus.doc} VldLine(cTipo)
    (long_description)
    @author user
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
/*/
Function Ga042VldEnt(oModelGY5,cField,xValue,nTipo)
Local oMdl      := oModelGY5:GetModel()
Local lRet      := .T.
Local aArea     := GetArea()
Local nLinePai  := oMdlTree1:GetLine()
Default nTipo   := 1

    SX2->(DbSetOrder(1))
    If !SX2->(DbSeek(xValue))
        lRet    := .F.
        oMdl:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"Ga042VldEnt",STR0015,STR0016+Chr(13)+Chr(10)+STR0017+Chr(13)+Chr(10)+STR0018)//"Não existe registro relacionado a este código."##"1) Informe um código que exista no cadastro"##"2)Efetue o cadastro no programa de manutenção do respectivo cadastro"##"3) Escolha um registro válido")
    ElseIf nTipo == 1 .and. oMdlTree1:SeekLine({{'GY5_ENTIDA',xValue}})
        lRet    := .F.
        oMdl:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"Ga042VldEnt",STR0012,STR0013)//'Já existe essa entidade selecionada'##'Selecione outra entidade'
    ElseIf nTipo == 2 .and. !oMdlTree1:SeekLine({{"GY5_ENTIDA",xValue }})
        lRet := .F.
        oMdl:SetErrorMessage(oMdl:GetId(),cField,oMdl:GetId(),cField,"Ga042VldEnt",STR0015,STR0016+Chr(13)+Chr(10)+STR0017+Chr(13)+Chr(10)+STR0018)//"Não existe registro relacionado a este código."##"1) Informe um código que exista no cadastro"##"2)Efetue o cadastro no programa de manutenção do respectivo cadastro"##"3) Escolha um registro válido")
    Endif

oMdlTree1:GoLine(nLinePai)

RestArea(aArea)

Return lRet

/*/{Protheus.doc} Ga042AddFil(oTree,cTipo)
    (long_description)
    @author user
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
/*/
Static Function Ga042AddFil(oTree,cTipo,nOpc, lAuto)

Local oModelGY6 := FwLoadModel('GTPA042B')
Local oStruGY6  := oModelGY6:GetModel('GY6MASTER'):GetStruct()
Local aFields   := oMdlTree2:GetStruct():GetFields()
Local n1        := 0
Default lAuto   := .F.

If cTipo == 'R'
    oStruGY6:SetProperty('GY6_ENTID2',MODEL_FIELD_OBRIGAT, .T.)
    oStruGY6:SetProperty('GY6_CAMPO2',MODEL_FIELD_OBRIGAT, .T.)
Endif

oModelGY6:SetCommit( {|oModel|  Ga042Comit( oModel,oTree, lAuto ) } )
oModelGY6:SetOperation(nOpc)
oModelGY6:Activate()

If nOpc == MODEL_OPERATION_UPDATE .OR. nOpc == MODEL_OPERATION_VIEW
    For n1 := 1 to Len(aFields)
        oModelGY6:GetModel('GY6MASTER'):LoadValue(aFields[n1][3], oMdlTree2:GetValue(aFields[n1][3]) )  
    Next
ElseIf nOpc == MODEL_OPERATION_INSERT .and. cTipo == "E"
    oModelGY6:GetModel('GY6MASTER'):SetValue('GY6_ENTID1',oMdlTree1:GetValue('GY5_ENTIDA'))
Endif

If cTipo == "R"
    FWExecView( STR0011,"VIEWDEF.GTPA042B",nOpc, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,30/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,oModelGY6 ) //'"Filtro"'	
Else
    FWExecView( STR0011,"VIEWDEF.GTPA042C",nOpc, /*oDlg*/, {||.T.} /*bCloseOk*/, {||.T.}/*bOk*/,30/*nPercRed*/,/*aButtons*/, {||.T.}/*bCancel*/,,,oModelGY6 ) //'"Filtro"'	
Endif

Return oMdlTree1:GetValue('GY5_IDTREE')+"_"+oMdlTree2:GetValue('GY6_SEQ')

/*/{Protheus.doc} Ga042Comit
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function Ga042Comit( oAuxModel,oTree, lAuto)

Local aFields   := nil
Local nOpc      := oAuxModel:GetOperation()
Local n1
Default lAuto   := .F.

If oAuxModel:GetId() == "GTPA042D"

    If !Empty(oMdlTree1:GetValue('GY5_IDTREE'))
        oMdlTree1:Addline()
    Endif
    aFields := oAuxModel:GetModel('GY5MASTER'):GetStruct():GetFields()
    
    For n1 := 1 to Len(aFields)
        If oMdlTree1:HasField(aFields[n1][3])
            oMdlTree1:SetValue(aFields[n1][3], oAuxModel:GetModel('GY5MASTER'):GetValue(aFields[n1][3]) )  
        Endif
    Next

    cNewCargo := GetNewCarg(oTree)
    oMdlTree1:SetValue('GY5_IDTREE',cNewCargo)
    oTree:AddTree(oMdlTree1:GetValue('GY5_DESCRI'), 'RPMTABLE', 'RPMTABLE',oMdlTree1:GetValue('GY5_IDTREE'))
    oTree:EndTree()

Else
    
    If nOpc == MODEL_OPERATION_INSERT .and. !Empty(oMdlTree2:GetValue('GY6_SEQ'))
        oMdlTree2:Addline()
    Endif
    
    GA042ATRIG(oAuxModel:GetModel('GY6MASTER'))
    
    aFields := oAuxModel:GetModel('GY6MASTER'):GetStruct():GetFields()
    
    For n1 := 1 to Len(aFields)
        If oMdlTree2:HasField(aFields[n1][3])
            oMdlTree2:SetValue(aFields[n1][3], oAuxModel:GetModel('GY6MASTER'):GetValue(aFields[n1][3]) )  
        Endif
    Next

    If nOpc == MODEL_OPERATION_INSERT
        cNewCargo  := GetNewCarg(oTree)
        If !(lAuto)
            oTree:AddItem(oMdlTree2:GetValue('GY6_DESCRI'),cNewCargo,"FILTRO","FILTRO",2)
            oMdlTree2:SetValue('GY6_SEQ',SubStr(cNewCargo,5,3))
        Else
            oMdlTree2:SetValue('GY6_SEQ','001')
        Endif
    ElseIf nOpc == MODEL_OPERATION_UPDATE
        oTree:ChangePrompt(oMdlTree2:GetValue('GY6_DESCRI'),oTree:GetCargo()) 
    Endif
Endif

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} G042GetEnt(aNomEnt,aAlias,nTipo)
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function G042GetEnt(nTipo,oModel, lAut)

Local n1       := 0
Local aAlias   := {}

Default lAut   := .F.

If nTipo == 1
    If ValType( oModel ) == "O" .and. ValType( oMdlTree1 ) == "U"
        oMdlTree1 := oModel:GetModel('TREE1')
    Endif

    if !lAut
        For n1 := 1 to oMdlTree1:Length()
            If !oMdlTree1:IsDeleted(n1) .and. oMdlTree1:GetValue('GY5_IDTREE',n1) <> 'REL'
                aAdd(aAlias, oMdlTree1:GetValue('GY5_ENTIDA',n1) )
            Endif
        Next
    Endif
Else
    aAlias := { "G52","G53","G54","G55","G56","G57","G58","G59","G5A","G5B","G5C","G5D","G5E","G5F","G5G","G5H","G5I","G5J","G5K","G5L","G6Q","G6R","G6S","G6T","G6U","G6V","G6W","G6X","G6Y","G6Z","G94","G95",;
                "G96","G97","G98","G99","G9A","G9B","G9C","G9D","G9E","G9O","G9P","G9Q","G9R","G9S","G9T","G9U","G9V","G9X","G9Y","G9Z","GI0","GI1","GI2","GI3","GI4","GI5","GI6","GI7","GI8","GI9","GIA","GIB",;
                "GIC","GID","GIE","GIF","GIG","GIH","GII","GIJ","GIK","GIL","GIM","GIN","GIO","GIP","GIQ","GIR","GIS","GIT","GIU","GIV","GIW","GIX","GIY","GIZ","GQ1","GQ2","GQ3","GQ4","GQ5","GQ6","GQ7","GQ8",;
                "GQ9","GQA","GQB","GQC","GQD","GQE","GQF","GQG","GQH","GQI","GQJ","GQK","GQL","GQM","GQN","GQO","GQP","GQQ","GQR","GQS","GQT","GQU","GQV","GQW","GQX","GQY","GQZ","GY0","GY1","GY2","GY3","GY4",;
                "GY5","GY6","GY7","GY8","GY9","GYA","GYB","GYC","GYD","GYE","GYF","GYG","GYH","GYI","GYJ","GYK","GYL","GYM","GYN","GYO","GYP","GYQ","GYR","GYS","GYT","GYU","GYV","GYW","GYX","GYY","GYZ","GZ0",;
                "GZ1","GZ2","GZ3","GZ4","GZ5","GZ6","GZ7","GZ8","GZ9","GZA","GZB","GZC","GZD","GZE","GZF","GZG","GZH"}
Endif

Return aAlias


//-------------------------------------------------------------------
/*/{Protheus.doc} GA042BTRIG(a,b,c,d,e,f)
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Function GA042ATRIG(oMdl)

Local cCondic   := ""
Local cDesc     := ""
Local cEnt1     := Alltrim(oMdl:GetValue('GY6_ENTID1'))
Local cCpo1     := Alltrim(oMdl:GetValue('GY6_CAMPO1'))
Local cEnt2     := Alltrim(oMdl:GetValue('GY6_ENTID2'))
Local cCpo2     := Alltrim(oMdl:GetValue('GY6_CAMPO2'))
Local cTipo     := Alltrim(oMdl:GetValue('GY6_TIPOFI'))
Local cConteu   := Alltrim(oMdl:GetValue('GY6_CONTEU'))
Local cOper     := oMdl:GetValue('GY6_OPERAD')
Local cOperador := Alltrim(GA042RETOP(cOper))

If !Empty(cConteu) //Filtro
    If cTipo == "1"
        If cOperador <> "LIKE"
            If TamSx3(cCpo1)[3] == "D"
                cCondic := cEnt1+'.'+cCpo1+' '+cOperador+" '"+DtoS(CtoD(cConteu))+"'"
            ElseIf TamSx3(cCpo1)[3] == "N"
                cCondic := cEnt1+'.'+cCpo1+' '+cOperador+" '"+cValToChar(Val(cConteu))+"'"
            Else
                cCondic := cEnt1+'.'+cCpo1+' '+cOperador+" '"+cConteu+"'"
            Endif
        Elseif cOper == '7' //Contem
            If TamSx3(cCpo1)[3] == "D"
                cCondic := cEnt1+'.'+cCpo1+' '+cOperador+" '%"+DtoS(CtoD(cConteu))+"%'"
            ElseIf TamSx3(cCpo1)[3] == "N"
                cCondic := cEnt1+'.'+cCpo1+' '+cOperador+" '%"+cValToChar(Val(cConteu))+"%'"
            Else
                cCondic := cEnt1+'.'+cCpo1+' '+cOperador+" '%"+cConteu+"%'"
            Endif
            
        Elseif cOper == '8' //Está Contido
            If TamSx3(cCpo1)[3] == "D"
                cCondic := "'"+DtoS(CtoD(cConteu))+"'"+cOperador+" '%'+"+cEnt1+'.'+cCpo1+"+'%'"
            ElseIf TamSx3(cCpo1)[3] == "N"
                cCondic := "'"+cValToChar(Val(cConteu))+"' "+cOperador+" '%'+"+cEnt1+'.'+cCpo1+"+'%'"
            Else
                cCondic := "'"+cConteu +"' "+cOperador+" '%'+"+cEnt1+'.'+cCpo1+"+'%'"
            Endif
            
        Endif
    Else
        If cOperador <> "LIKE"
            cCondic := cEnt1+'.'+cCpo1+' '+cOperador+' [|'+cConteu+'|]'
        Elseif cOper == '7' //Contem
            cCondic := cEnt1+'.'+cCpo1+' '+cOperador+' %[|'+cConteu+'|]%'
        Elseif cOper == '8' //Está Contido
            cCondic := "'[|"+cConteu+"'|]"+' '+cOperador+" '%"+cEnt1+'.'+cCpo1+"%'"
        Endif
    Endif
    cDesc   := Alltrim(GTPX2Name( cEnt1 ) )+'.'+Alltrim(GTPX3TIT(cCpo1) )+' '+Alltrim(GTPXCBox('GY6_OPERAD',Val(cOper)))+" '"+cConteu+"'"
Else //Relacionamento
    If cOperador <> "LIKE"
        cCondic := cEnt1+'.'+cCpo1+' '+cOperador+' '+cEnt2+'.'+cCpo2
    Elseif cOper == '7' //Contem
        cCondic := cEnt1+'.'+cCpo1+' '+cOperador+" '%"+cEnt2+'.'+cCpo2+"%'"
    Elseif cOper == '8' //Está Contido
        cCondic := cEnt2+'.'+cCpo2+' '+cOperador+" '%"+cEnt1+'.'+cCpo1+"%'"
    Endif
    cDesc   := Alltrim(GTPX2Name( cEnt1 ) )+'.'+Alltrim(GTPX3TIT(cCpo1) )+' '+Alltrim(GTPXCBox('GY6_OPERAD',Val(cOper)))+' '+Alltrim(GTPX2Name( cEnt2 ) )+'.'+Alltrim(GTPX3TIT(cCpo2) )
Endif

oMdl:SetValue('GY6_CONDIC',cCondic)
oMdl:SetValue('GY6_DESCRI',cDesc)

Return NIL


//-------------------------------------------------------------------
/*/{Protheus.doc} GA042RETOP(cTipo)
description
@author  author
@since   date
@version version
/*/
//-------------------------------------------------------------------
Static Function GA042RETOP(cTipo)

Local cRet  := ""

Do Case 
    Case cTipo == '1' //Igual a
        cRet  := "="
    Case cTipo == '2' //Diferente de
        cRet  := "<>"
    Case cTipo == '3'// Maior que
        cRet  := ">"
    Case cTipo == '4' //Maior ou Igual a
        cRet  := ">="
    Case cTipo == '5' //Menor que
        cRet  := "<"
    Case cTipo == '6'//Menor ou igual a
        cRet  := "<="
    Case cTipo == '7' .or. cTipo == '8'//Esta contido ou está Contido
        cRet  := "LIKE"
EndCase    

Return cRet

Function GTPA042AUT(oView)
Local lRet 		:= .F.
Local oModel 	:= oView:GetModel()
Local oPanel 	:= nil
Local oTree 	:= nil
Local lAuto		:= .F.

oTree := GTPA42TREE(oPanel)

Ga042AddEnt(oTree,'E', .F.)
Ga042AddFil(oTree,'E',3,.T.)

oModel:GetModel('GRIDGY7'):SetValue('GY7_CAMPO','G57_AGENCI')
oModel:GetModel('GRIDGY7'):SetValue('GY7_SEQ','001')
oModel:GetModel('GRIDGY7'):SetValue('GY7_ENTIDA','G57')

TreeDelete(oTree,,.T.)

Return lRet


