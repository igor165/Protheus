#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "GTPA808.CH"

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTPA808
Função responsavel pelo monitor das Averbações
@type Function
@author jacomo.fernandes
@since 05/11/2019
@version 1.0
@param cId, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Function GTPA808(nOpc,cTitulo,lPos)
Local aEnableButtons := GtpBtnView(.F.,,.T.,)
Local oModel    := FwLoadModel('GTPA808')
Local oMdlCab   := oModel:GetModel("MASTER")

Default lPos    := .F.

oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()
oMdlCab:SetValue('CAB_OPERATION',nOpc)

If lPos
    oMdlCab:SetValue('CAB_AGENCIA'  ,G99->G99_CODEMI)
    oMdlCab:SetValue('CAB_CODCTE'   ,G99->G99_CODIGO)
    SetDadosCTe(oModel,.F.)
Endif

FWExecView(cTitulo, "GTPA808",MODEL_OPERATION_INSERT,,,,,aEnableButtons,,,, oModel)

oModel:DeActivate()
oModel:Destroy()

SetKey( VK_F5 , ) 
SetKey( VK_F8 , ) 

Return

//------------------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Função responsavel pela definição do modelo
@type Static Function
@author jacomo.fernandes
@since 05/11/2019
@version 1.0
@return oModel, retorna o Objeto do Menu
/*/
//------------------------------------------------------------------------------
Static Function ModelDef()
Local oModel	:= nil
Local oStrCab	:= FWFormModelStruct():New()
Local oStrGIJ	:= FWFormStruct(1,'GIJ')


SetModelStruct(oStrCab,oStrGIJ)

oModel := MPFormModel():New('GTPA808', /*bPreValidacao*/, /*bPosValid*/,/*bCommit*/, /*bCancel*/ )

oModel:AddFields('MASTER',/*cOwner*/,oStrCab,/*bPre*/,/*bPos*/,/*bLoad*/)
oModel:AddGrid('GIJDETAIL','MASTER',oStrGIJ,/*bLinePre*/,/*bLinePost*/, /*bPreVal*/,/*bPosVld*/,/*bLoad*/)

oModel:SetDescription(STR0034) //'Averbação'

oModel:GetModel('MASTER'):SetDescription(STR0004)//'Dados para Filtro'
oModel:GetModel('GIJDETAIL'):SetDescription(STR0005)//'Averbações'

oModel:GetModel('MASTER'):SetOnlyQuery( .T. )
oModel:GetModel('GIJDETAIL'):SetOnlyQuery( .T. )

oModel:GetModel('GIJDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('GIJDETAIL'):SetNoDeleteLine(.T.)

oModel:SetPrimaryKey({})

Return oModel

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetModelStruct

@type Static Function
@author jacomo.fernandes
@since 05/11/2019
@version 1.0
@param oStrCab, object, (Descrição do parâmetro)
@param oStrGIJ, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetModelStruct(oStrCab,oStrGIJ)
Local bTrig		:= {|oMdl,cField,uVal| FieldTrigger(oMdl,cField,uVal)}
Local bFldVld	:= {|oMdl,cField,uNewValue,uOldValue|FieldValid(oMdl,cField,uNewValue,uOldValue) }

If ValType(oStrCab) == "O"
    oStrCab:AddTable("   ",{" "}," ")

    oStrCab:AddField(STR0006 ,STR0006 ,"CAB_OPERATION","C",1                      ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Tp Operação"

    oStrCab:AddField(STR0007 ,STR0008 ,"CAB_AGENCIA" ,"C",TamSx3("GI6_CODIGO")[1],0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Ag. Emissora" ,"Agencia Emissora" 
    oStrCab:AddField(STR0009 ,STR0009 ,"CAB_AGDESC"  ,"C",TamSx3("GI6_DESCRI")[1],0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Nome Emissora"
    oStrCab:AddField(STR0010 ,STR0011 ,"CAB_DTINI"   ,"D",8                      ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Dt Inicial"   ,"Data Inicial"
    oStrCab:AddField(STR0012 ,STR0013 ,"CAB_DTFIM"   ,"D",8                      ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Dt Final"     ,"Data Final"
    oStrCab:AddField(STR0014 ,STR0014 ,"CAB_SERIE"   ,"C",TamSx3("G99_SERIE")[1] ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Série"
    oStrCab:AddField(STR0015 ,STR0015 ,"CAB_NUMDOC"  ,"C",TamSx3("G99_NUMDOC")[1] ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Documento"

    oStrCab:AddField(STR0016 ,STR0016 ,"CAB_CODSEG"   ,"C",TamSx3("DL6_CODSEG")[1],0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Seguradora"
    oStrCab:AddField(STR0017 ,STR0017 ,"CAB_NOMSEG"   ,"C",TamSx3("A2_NOME")[1]   ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Nome"      
    oStrCab:AddField(STR0046 ,STR0046 ,"CAB_CODCTE"   ,"C",TamSx3("G99_CODIGO")[1]   ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)//"Cod CT-e"
    
    oStrCab:AddTrigger('CAB_AGENCIA','CAB_AGENCIA'	,{||.T.}, bTrig )
    oStrCab:AddTrigger('CAB_CODSEG' ,'CAB_CODSEG'	,{||.T.}, bTrig )
    
    oStrCab:SetProperty('CAB_AGENCIA'	,MODEL_FIELD_OBRIGAT, .T. )
    oStrCab:SetProperty('CAB_CODSEG'	,MODEL_FIELD_OBRIGAT, .T. )
    oStrCab:SetProperty('*'	            ,MODEL_FIELD_VALID	, bFldVld)
    
Endif

If ValType(oStrGIJ) == "O"
    oStrGIJ:SetProperty('*'	    ,MODEL_FIELD_OBRIGAT, .F. )

    oStrGIJ:AddField(""         ,""         ,"GIJ_MARK"   ,"L",1                    ,0,NIL,NIL,NIL,.F.,NIL,.F.,.F.,.T.)
    oStrGIJ:AddField(""         ,""         ,"GIJ_LEGEND" ,"C",20                   ,0,NIL,NIL,NIL,.F.,Nil,.F.,.F.,.T.)
    oStrGIJ:AddField(STR0018    ,STR0018    ,"GIJ_NOME"   ,"C",TamSx3("A1_NOME")[1] ,0,NIL,NIL,NIL,.F.,Nil,.F.,.F.,.T.)//"Nome do Tomador"
    oStrGIJ:AddField("G99RECNO" ,"G99RECNO" ,"G99RECNO"   ,"N",16                   ,0,Nil,Nil,Nil,.F.,NIL,.F.,.T.,.T.)
    oStrGIJ:AddField("GIJRECNO" ,"GIJRECNO" ,"GIJRECNO"   ,"N",16                   ,0,Nil,Nil,Nil,.F.,NIL,.F.,.T.,.T.)

    GTPxCriaCpo(oStrGIJ,{"G99_CODPRO","G99_DESPRO","G99_SERIE","G99_NUMDOC","G99_VALOR","G99_DESEMI","G99_DTEMIS","G99_HREMIS","G99_TOMADO","G99_CODIGO"},.T.)

Endif

Return 

//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldTrigger
Função responsavel pelo gatilho dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param , character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function FieldTrigger(oMdl,cField,uVal)
Local oView		:= FwViewActive()
Local aAreaAux  := {}

Do Case
    Case cField == 'CAB_AGENCIA'
        oMdl:SetValue('CAB_AGDESC', Posicione('GI6',1,xFilial('GI6')+uVal,"GI6_DESCRI") ) 
    Case cField =='CAB_CODSEG' 
        aAreaAux    := DL6->(GetArea())
        DL6->(DbSetOrder(1))//DL6_FILIAL+DL6_CODSEG
        If DL6->(DbSeek(xFilial('DL6')+uVal ))
            oMdl:SetValue('CAB_NOMSEG', Posicione('SA2',1,xFilial('SA2')+DL6->(DL6_CODFOR+DL6_LOJFOR),"A2_NOME") ) 
        Else
            oMdl:SetValue('CAB_NOMSEG', '') 
        Endif
        RestArea(aAreaAux)
EndCase



If !IsBlind() .and. ValType(oView) == "O" .AND. oView:IsActive()
	oView:Refresh()
Endif

GtpDestroy(aAreaAux)

Return uVal


//------------------------------------------------------------------------------
/*/{Protheus.doc} FieldValid
Função responsavel pela validação dos campos
@type function
@author 
@since 10/06/2019
@version 1.0
@param oMdl, character, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param uNewValue, character, (Descrição do parâmetro)
@param uOldValue, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function FieldValid(oMdl,cField,uNewValue,uOldValue)
Local lRet      := .T.
Local oModel	:= oMdl:GetModel()
Local cMdlId    := oMdl:GetId()
Local cMsgErro	:= ""
Local cMsgSol	:= ""

Do Case
	Case Empty(uNewValue)
        lRet := .T.
    Case cField == "CAB_AGENCIA"
        IF !GTPExistCpo('GI6',uNewValue)
            lRet        := .F.
            cMsgErro	:= STR0019//"Agencia selecionada não encontrada ou se encontra inativa"
            cMsgSol	    := STR0020//"Selecione uma agencia valida"
        ElseIf !ValidUserAg(oMdl,cField,uNewValue,uOldValue)
            lRet        := .F.
        Endif
    Case cField == "CAB_CODSEG"
        IF !GTPExistCpo('DL6',uNewValue)
            lRet        := .F.
            cMsgErro	:= STR0021//"Seguradora selecionada não encontrada ou se encontra inativa"
            cMsgSol	    := STR0022//"Selecione uma Seguradora valida"
        Endif
    Case cField == "CAB_DTINI" .or. cField == "CAB_DTFIM"
        If !Empty(oMdl:GetValue("CAB_DTINI")) .and. ;
            !Empty(oMdl:GetValue("CAB_DTFIM")) .and. ;
            ( oMdl:GetValue("CAB_DTINI") > oMdl:GetValue("CAB_DTFIM") )

            lRet		:= .F.
            cMsgErro	:= STR0023//"Data Inicial maior que a Data Final"
            cMsgSol		:= STR0024//"Informe uma Data menor que a Data Final"
        Endif
            
EndCase

If !lRet .and. !Empty(cMsgErro)
	oModel:SetErrorMessage(cMdlId,cField,cMdlId,cField,"FieldValid",cMsgErro,cMsgSol,uNewValue,uOldValue)
Endif

Return lRet
//------------------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Função responsavel pela definição da view
@type Static Function
@author jacomo.fernandes
@since 05/11/2019
@version 1.0
@return oView, retorna o Objeto da View
/*/
//------------------------------------------------------------------------------
Static Function ViewDef()
Local oView		:= FWFormView():New()
Local oModel	:= FwLoadModel('GTPA808')
Local oStrCAB	:= FWFormViewStruct():New()
Local oStrGIJ	:= FWFormStruct(2, 'GIJ')

SetViewStruct(oStrCAB,oStrGIJ)

oView:SetModel(oModel)

oView:AddField('VIEW_CAB' ,oStrCAB,'MASTER')
oView:AddGrid('VIEW_GIJ',oStrGIJ,'GIJDETAIL')

oView:CreateHorizontalBox('UPPER', 30)
oView:CreateHorizontalBox('BOTTOM', 70)

oView:SetOwnerView('VIEW_CAB','UPPER')
oView:SetOwnerView('VIEW_GIJ','BOTTOM')

oView:SetDescription(STR0005) //'Averbações'

oView:EnableTitleView("VIEW_GIJ")

oView:SetViewProperty("VIEW_GIJ", "GRIDSEEK", {.T.})
oView:SetViewProperty("VIEW_GIJ", "GRIDFILTER", {.T.})
oView:SetViewProperty("VIEW_GIJ", "GRIDDOUBLECLICK", {{|oGrid,cField| SetDoubleClick(oGrid,cField)}})


oView:AddUserButton( STR0047+" <F5>", "", {|oView| FwMsgRun(,{|| ExecFilter(oView)}	, STR0048, STR0049)} ,,VK_F5,,.T./* lShowBar */) //"Filtrar","Filtro", "Realizando o filtro dos registros..."
oView:AddUserButton( STR0050+" <F8>", "", {|oView| FwMsgRun(,{|| GravaDados(oView)}	, STR0051, STR0052)} ,,VK_F8,,.T./* lShowBar */) //"Transmitir","Transmitindo", "Realizando a transmissão dos registros..."
oView:AddUserButton( STR0053        , "", {|oView| FwMsgRun(,{|| MarcarTodos(oView)}, STR0054, STR0055)} ,,,,.T./* lShowBar */)//"(Des)Marcar Todos","(Des)Marcando", "Realizando a (Des)marcação dos registros..."

SetKey( VK_F5 ,{|| ExecFilter(oView)} ) 
SetKey( VK_F8 ,{|| GravaDados(oView)} ) 

Return oView
//------------------------------------------------------------------------------
/*/{Protheus.doc} SetDoubleClick
(long_description)
@type function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param oGrid, objeto, (Descrição do parâmetro)
@param cField, character, (Descrição do parâmetro)
@param nLineGrid, numérico, (Descrição do parâmetro)
@param nLineModel, numérico, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetDoubleClick(oGrid,cField)

If cField == "GIJ_LEGEND"
    GetLegenda()
Endif

Return .T. 


//------------------------------------------------------------------------------
/*/{Protheus.doc} GetLegenda
(long_description)
@type function
@author jacomo.fernandes
@since 09/07/2019
@version 1.0
@param cField, character, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function GetLegenda()
Local oLegenda  :=  FWLegend():New()

oLegenda:Add("GIJ_AVERBA=='0'", "WHITE"        , STR0027) //"Averbação não transmitida"    
oLegenda:Add("GIJ_AVERBA=='1'", "YELLOW"       , STR0028) //"Averbação aguardando retorno" 
oLegenda:Add("GIJ_AVERBA=='2'", "GREEN"        , STR0029) //"Averbação aceita"             
oLegenda:Add("GIJ_AVERBA=='3'", "RED"          , STR0030) //"Averbação rejeitada"          
oLegenda:Add("GIJ_AVERBA=='4'", "BLACK"        , STR0031) //"Averbação cancelada"          
     
oLegenda:Activate()
oLegenda:View()
oLegenda:DeActivate()

GtpDestroy(oLegenda)

Return()

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetViewStruct

@type Static Function
@author jacomo.fernandes
@since 05/11/2019
@version 1.0
@param oStrCab, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function SetViewStruct(oStrCab,oStrGIJ)

If ValType(oStrCab) == "O"
    oStrCab:AddField("CAB_AGENCIA"  ,"01",STR0007 ,STR0008 ,NIL,"C",""     ,NIL,Nil,.T.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)//"Ag. Emissora" ,"Agencia Emissora"
    oStrCab:AddField("CAB_AGDESC"   ,"02",STR0009 ,STR0009 ,NIL,"C",""     ,NIL,Nil,.F.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)//"Nome Emissora","Nome Emissora"   
    oStrCab:AddField("CAB_DTINI"    ,"03",STR0010 ,STR0011 ,NIL,"D","@D"   ,NIL,Nil,.T.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)//"Dt Inicial"   ,"Data Inicial"    
    oStrCab:AddField("CAB_DTFIM"    ,"04",STR0012 ,STR0013 ,NIL,"D","@D"   ,NIL,Nil,.T.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)//"Dt Final"     ,"Data Final"      
    oStrCab:AddField("CAB_SERIE"    ,"05",STR0014 ,STR0014 ,NIL,"C",""     ,NIL,Nil,.T.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)//"Série"        ,"Série"           
    oStrCab:AddField("CAB_NUMDOC"   ,"06",STR0015 ,STR0015 ,NIL,"C",""     ,NIL,Nil,.T.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)//"Documento"    ,"Documento"       

    oStrCab:AddField("CAB_CODSEG"   ,"07",STR0016 ,STR0016 ,NIL,"C",""     ,NIL,Nil,.T.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)//"Seguradora"   ,"Seguradora"      
    oStrCab:AddField("CAB_NOMSEG"   ,"08",STR0017 ,STR0017 ,NIL,"C",""     ,NIL,Nil,.F.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)//"Nome"         ,"Nome"            

    oStrCab:SetProperty("CAB_AGENCIA" , MVC_VIEW_LOOKUP , "GI6FIL")
    oStrCab:SetProperty("CAB_SERIE"   , MVC_VIEW_LOOKUP , "G99SER")
    oStrCab:SetProperty("CAB_CODSEG"  , MVC_VIEW_LOOKUP , "GTPDL6")


    oStrCab:AddGroup('FILTRO'       ,STR0032, '', 2 )//"Informe os campos para filtrar os CT-es: "
    oStrCab:AddGroup('SEGURADORA'   ,STR0033, '', 2 )//"Informe a seguradora a ser utilizada: "
    
    oStrCab:SetProperty("*"	         , MVC_VIEW_GROUP_NUMBER, "FILTRO" )
    oStrCab:SetProperty("CAB_CODSEG" , MVC_VIEW_GROUP_NUMBER, "SEGURADORA" )
    oStrCab:SetProperty("CAB_NOMSEG" , MVC_VIEW_GROUP_NUMBER, "SEGURADORA" )
    
Endif

If ValType(oStrGIJ) == "O"
  
    oStrGIJ:RemoveField('GIJ_CODIGO')   
    oStrGIJ:RemoveField('GIJ_SEQ'   )   
    oStrGIJ:RemoveField('GIJ_STATUS')
    oStrGIJ:RemoveField('GIJ_TIPAVB')
    oStrGIJ:RemoveField('GIJ_MSBLQL')

	GTPxCriaCpo(oStrGIJ,{"G99_CODPRO","G99_DESPRO","G99_SERIE","G99_NUMDOC","G99_VALOR","G99_DESEMI","G99_DTEMIS","G99_HREMIS","G99_TOMADO"},.F.)
     
    oStrGIJ:AddField("GIJ_MARK"   ,"00","","",NIL,"L"  ,""     ,NIL,Nil,.T.,NIL,NIL,Nil,NIL,NIL,.T.,NIL)
    oStrGIJ:AddField("GIJ_LEGEND" ,'00',"","",NIL,'BT' ,'@BMP' ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrGIJ:AddField("GIJ_NOME"   ,'00',"","",NIL,'C'  ,'@!'   ,NIL,NIL,.F.,NIL,NIL,NIL,NIL,NIL,.T.,'' )
    oStrGIJ:SetProperty("*", MVC_VIEW_CANCHANGE, .F.)

    oStrGIJ:SetProperty("GIJ_MARK"      , MVC_VIEW_CANCHANGE, .T.)
    oStrGIJ:SetProperty("GIJ_NUMAVB"    , MVC_VIEW_CANCHANGE, .T.)
    oStrGIJ:SetProperty("GIJ_CNPJSE"    , MVC_VIEW_CANCHANGE, .T.)
    oStrGIJ:SetProperty("GIJ_NOMESE"    , MVC_VIEW_CANCHANGE, .T.)
    oStrGIJ:SetProperty("GIJ_NUMAPO"    , MVC_VIEW_CANCHANGE, .T.)  
    oStrGIJ:SetProperty("GIJ_DATAVB"    , MVC_VIEW_CANCHANGE, .T.) 
    oStrGIJ:SetProperty("GIJ_HORAVB"    , MVC_VIEW_CANCHANGE, .T.)   
 

    oStrGIJ:SetProperty("GIJ_MARK"   , MVC_VIEW_ORDEM, '01')
    oStrGIJ:SetProperty("GIJ_LEGEND" , MVC_VIEW_ORDEM, '02')
    oStrGIJ:SetProperty("G99_CODPRO" , MVC_VIEW_ORDEM, '03')
    oStrGIJ:SetProperty("G99_DESPRO" , MVC_VIEW_ORDEM, '04')
    oStrGIJ:SetProperty("G99_SERIE"  , MVC_VIEW_ORDEM, '05')
    oStrGIJ:SetProperty("G99_NUMDOC" , MVC_VIEW_ORDEM, '06')
    oStrGIJ:SetProperty("G99_VALOR"  , MVC_VIEW_ORDEM, '07')
    oStrGIJ:SetProperty("G99_DESEMI" , MVC_VIEW_ORDEM, '08')
    oStrGIJ:SetProperty("G99_DTEMIS" , MVC_VIEW_ORDEM, '09')
    oStrGIJ:SetProperty("G99_HREMIS" , MVC_VIEW_ORDEM, '10')
    oStrGIJ:SetProperty("G99_TOMADO" , MVC_VIEW_ORDEM, '11')
    oStrGIJ:SetProperty("GIJ_NOME"   , MVC_VIEW_ORDEM, '12')
    
    oStrGIJ:SetProperty("GIJ_CODSEG" , MVC_VIEW_ORDEM, '13')
    oStrGIJ:SetProperty("GIJ_DATEMI" , MVC_VIEW_ORDEM, '14')
    oStrGIJ:SetProperty("GIJ_HOREMI" , MVC_VIEW_ORDEM, '15')
    oStrGIJ:SetProperty("GIJ_DATAVB" , MVC_VIEW_ORDEM, '16')
    oStrGIJ:SetProperty("GIJ_HORAVB" , MVC_VIEW_ORDEM, '17')
    oStrGIJ:SetProperty("GIJ_PROTOC" , MVC_VIEW_ORDEM, '18')
    oStrGIJ:SetProperty("GIJ_NUMAVB" , MVC_VIEW_ORDEM, '19')
    oStrGIJ:SetProperty("GIJ_CNPJSE" , MVC_VIEW_ORDEM, '20')
    oStrGIJ:SetProperty("GIJ_NOMESE" , MVC_VIEW_ORDEM, '21')
    oStrGIJ:SetProperty("GIJ_NUMAPO" , MVC_VIEW_ORDEM, '22')
    oStrGIJ:SetProperty("GIJ_RAMO"   , MVC_VIEW_ORDEM, '23')
    oStrGIJ:SetProperty("GIJ_VALAVB" , MVC_VIEW_ORDEM, '24')
    oStrGIJ:SetProperty("GIJ_TPDDR"  , MVC_VIEW_ORDEM, '25')
    oStrGIJ:SetProperty("GIJ_TPMOV"  , MVC_VIEW_ORDEM, '26')
    oStrGIJ:SetProperty("GIJ_MSERRO" , MVC_VIEW_ORDEM, '27')

    
Endif

Return 



//------------------------------------------------------------------------------
/* /{Protheus.doc} ExecFilter
Função responsavel pelo filtro dos dados para serem exibidos na tela
@type Static Function
@author jacomo.fernandes
@since 06/11/2019
@version 1.0
@param oView, object, (Descrição do parâmetro)
/*/
//------------------------------------------------------------------------------
Static Function ExecFilter(oView,lAsk)
Local oModel    := oView:GetModel()
Default lAsk    := .T.
CursorWait()

If CheckFilter(oModel,lAsk)
    SetDadosCTe(oModel,lAsk)
Endif

oView:Refresh()

CursorArrow()

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} CheckFilter

@type Static Function
@author jacomo.fernandes
@since 06/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return lRet, retorno logico
/*/
//------------------------------------------------------------------------------
Static Function CheckFilter(oModel,lAsk)
Local lRet      := .T.
Local oMdlCab   := oModel:GetModel("MASTER")
Local oMdlGIJ   := oModel:GetModel("GIJDETAIL")

If GtpIsInMsg()
    lRet    := .F.
ElseIf Empty(oMdlCab:GetValue('CAB_AGENCIA'))
    FwAlertHelp(STR0035, STR0036 ,STR0037)//"Não foi informado a agencia emissora", "Selecione uma agencia para realizar a busca dos dados","Atenção!!"
    lRet := .F.

ElseIf !oMdlGIJ:IsEmpty()  .and. lAsk .AND. !FwAlertYesNo(STR0038,STR0037)//"Existem registro filtrados, deseja refazer o filtro?","Atenção!!"
    lRet    := .F.

Endif

Return lRet

//------------------------------------------------------------------------------
/* /{Protheus.doc} SetDadosCTe
Função responsavel pelo preenchimento da grid

@type Function
@author jacomo.fernandes
@since 06/11/2019
@version 1.0
@param oModel, object, (Descrição do parâmetro)

/*/
//------------------------------------------------------------------------------
Static Function SetDadosCTe(oModel,lAsk)
Local oMdlCab   := oModel:GetModel('MASTER')
Local oMdlGIJ   := oModel:GetModel('GIJDETAIL')
Local cAliasTmp := GetDadosCTe(oMdlCab,lAsk)
Local oStrGIJ   := oMdlGIJ:GetStruct()
Local aFldGIJ   := (cAliasTmp)->(DbStruct())
Local lFirst    := .T.
Local n1        := 0

oModel:GetModel('GIJDETAIL'):SetNoInsertLine(.F.)
oModel:GetModel('GIJDETAIL'):SetNoDeleteLine(.F.)

If !oMdlGIJ:IsEmpty()
    oMdlGIJ:ClearData()
Endif

While (cAliasTmp)->(!Eof())

    If !lFirst
        oMdlGIJ:AddLine()
    Endif
    
    For n1	:= 1 To Len(aFldGIJ)
        If oStrGIJ:HasField(aFldGIJ[n1][1])
            oMdlGIJ:LoadValue(aFldGIJ[n1][1],(cAliasTmp)->&(aFldGIJ[n1][1]))
        Endif
    Next
    
    lFirst := .F.
    
    
    (cAliasTmp)->(DbSkip())
End

oMdlGIJ:GoLine(1)

oModel:GetModel('GIJDETAIL'):SetNoInsertLine(.T.)
oModel:GetModel('GIJDETAIL'):SetNoDeleteLine(.T.)

(cAliasTmp)->(DbCloseArea())

Return


//------------------------------------------------------------------------------
/* /{Protheus.doc} GetDadosCTe
Função responsavel pela busca dos dados conforme filtro definido

@type Function
@author jacomo.fernandes
@since 06/11/2019
@version 1.0
@param oMdlCab, object, (Descrição do parâmetro)
@return lRet, returno logico
/*/
//------------------------------------------------------------------------------
Static Function GetDadosCTe(oMdlCab,lAsk)
Local cAliasTmp := GetNextAlias()
Local cWhere    := ""
Local cFields   := ""

If !Empty(oMdlCab:GetValue("CAB_AGENCIA"  ))
    cWhere += " AND G99.G99_CODEMI ='"+oMdlCab:GetValue("CAB_AGENCIA")+"' "
Endif

If !Empty(oMdlCab:GetValue("CAB_DTINI"    ))
    cWhere += " AND G99.G99_DTEMIS >='"+DtoS(oMdlCab:GetValue("CAB_DTINI"))+"' "
Endif

If !Empty(oMdlCab:GetValue("CAB_DTFIM"    ))
    cWhere += " AND G99.G99_DTEMIS <='"+DtoS(oMdlCab:GetValue("CAB_DTFIM"))+"' "
Endif

If !Empty(oMdlCab:GetValue("CAB_SERIE"    ))
    cWhere += " AND G99.G99_SERIE ='"+oMdlCab:GetValue("CAB_SERIE")+"' "
Endif

If !Empty(oMdlCab:GetValue("CAB_NUMDOC"   ))
    cWhere += " AND G99.G99_NUMDOC ='"+oMdlCab:GetValue("CAB_NUMDOC")+"' "
Endif

If oMdlCab:GetValue("CAB_OPERATION") == "1" //Envio
    cWhere += " AND G99.G99_AVERBA in (' ','0','3','4') "
    cWhere += " AND G99.G99_STATRA = '2' " //CTE-Autorizado
ElseIf oMdlCab:GetValue("CAB_OPERATION") == "2" //Cancelamento
    cWhere += " AND G99.G99_AVERBA in ('1','2','3') "
    cWhere += " AND G99.G99_STATRA = '8' " //CTe Cancelado
Endif


If !Empty(oMdlCab:GetValue("CAB_CODCTE"   ))
    cWhere += " AND G99.G99_CODIGO ='"+oMdlCab:GetValue("CAB_CODCTE")+"' "
Endif

cFields += " 'F' as GIJ_MARK,"  
cFields += " (CASE G99.G99_AVERBA 
cFields += " WHEN ' ' THEN 'BR_BRANCO' "
cFields += " WHEN '0' THEN 'BR_BRANCO' "
cFields += " WHEN '1' THEN 'BR_AMARELO' "
cFields += " WHEN '2' THEN 'BR_VERDE' "
cFields += " WHEN '3' THEN 'BR_VERMELHO' "
cFields += " WHEN '4' THEN 'BR_PRETO' "
cFields += " END) AS GIJ_LEGEND,"

cFields += " G99_CODPRO,"
cFields += " SB1.B1_DESC AS G99_DESPRO,"
cFields += " G99_SERIE," 
cFields += " G99_NUMDOC,"
cFields += " G99_VALOR," 
cFields += " GI6.GI6_DESCRI AS G99_DESEMI,"
cFields += " G99_DTEMIS,"
cFields += " G99_HREMIS,"
cFields += " G99_TOMADO,"
cFields += " SA1.A1_NOME AS GIJ_NOME," 
cFields += " G99_CODIGO,"
cFields += " GIJ_CODSEG,"
cFields += " GIJ_DATEMI,"
cFields += " GIJ_HOREMI,"
cFields += " GIJ_STATUS,"
cFields += " GIJ_DATAVB,"
cFields += " GIJ_HORAVB,"
cFields += " GIJ_PROTOC,"
cFields += " GIJ_NUMAVB,"
cFields += " GIJ_CNPJSE,"
cFields += " GIJ_NOMESE,"
cFields += " GIJ_NUMAPO,"
cFields += " GIJ_RAMO,"
cFields += " GIJ_VALAVB,"
cFields += " GIJ_TPDDR,"
cFields += " GIJ_TPMOV,"
cFields += " GIJ_MSERRO,"
        
cFields   := "%"+cFields+"%"
cWhere    := "%"+cWhere+"%"

BeginSql Alias cAliasTmp

    Column GIJ_MARK as Logical
    Column G99_DTEMIS as Date
    Column GIJ_DATAVB as Date
    Column GIJ_DATEMI as Date
    Column G99RECNO as Numeric(16,0)
    Column GIJRECNO as Numeric(16,0)
    Select 
        %Exp:cFields%
        G99.R_E_C_N_O_ as G99RECNO,
        GIJ.R_E_C_N_O_ as GIJRECNO
    From %Table:G99% G99
        INNER JOIN %Table:SB1% SB1 ON	
            SB1.B1_FILIAL = %xFilial:SB1%
            AND SB1.B1_COD = G99.G99_CODPRO
            AND SB1.%NotDel%
        INNER JOIN %Table:GI6% GI6 ON
            GI6.GI6_FILIAL = %xFilial:GI6%
            AND GI6.GI6_CODIGO = G99.G99_CODEMI
            AND GI6.%NotDel%
        INNER JOIN %Table:SA1% SA1 ON
            SA1.A1_FILIAL = %xFilial:SA1%
            AND SA1.A1_COD = (CASE G99.G99_TOMADO 
                                    WHEN '0' THEN G99.G99_CLIREM
                                    WHEN '3' THEN G99.G99_CLIDES
                            End)
            AND SA1.A1_LOJA = (CASE G99.G99_TOMADO 
                                    WHEN '0' THEN G99.G99_LOJREM
                                    WHEN '3' THEN G99.G99_LOJDES
                            End)
            AND SA1.%NotDel%
        LEFT JOIN %Table:GIJ% GIJ ON
            GIJ.GIJ_FILIAL = G99.G99_FILIAL
            AND GIJ.GIJ_CODIGO = G99.G99_CODIGO
            AND GIJ.GIJ_MSBLQL = '2'
            AND GIJ.%NotDel%
    Where
        G99.G99_FILIAL = %xFilial:G99%
        AND G99.%NotDel%
        AND G99.G99_TIPCTE = '0'  //Apenas CT-es normais
        %Exp:cWhere%

EndSql

If (cAliasTmp)->(EOF()) .and. lAsk
    FwAlertHelp(STR0039,STR0040,STR0037)//"Não foram encontrados nenhum dados com os parametros informados","Altere os dados para filtro ou verifique se o registro de fato exista","Atenção!!"
Endif

Return cAliasTmp



//------------------------------------------------------------------------------
/* /{Protheus.doc} GravaDados

@type Static Function
@author jacomo.fernandes
@since 07/11/2019
@version 1.0
@param oModel, object, (Descrição do parâmetro)
@return lRet, Retorno logico
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function GravaDados(oView)
Local lRet      := .T.
Local oModel    := oView:GetModel()
Local oMdlCab   := oModel:GetModel("MASTER")
Local oMdlGIJ   := oModel:GetModel("GIJDETAIL")
Local oMdlAvb   := Nil

Local n1        := 0

If oMdlCab:GetValue('CAB_OPERATION') == "3" //diferente de Consulta
    FwAlertHelp(STR0041,STR0042,STR0037)//"Não é possível realizar a gravação na operação de Consulta","Selecione a operação de Envio ou Cancelamento para realizar a gravação","Atenção!!"
    lRet := .F.
ElseIf Empty(oMdlCab:GetValue('CAB_CODSEG')) .or. !GTPExistCpo('DL6',oMdlCab:GetValue('CAB_CODSEG'))
    FwAlertHelp(STR0043,STR0044,STR0037)//"Código da Seguradora não informado ou inexistente","Verifique o código informado da seguradora","Atenção!!"
    lRet := .F.
Else
    oMdlAvb   := FwLoadModel("GTPA808a")
    oMdlAvb:SetOperation(MODEL_OPERATION_INSERT)

    If !(oMdlGIJ:SeekLine({{"GIJ_MARK", .T.}})) .Or. oMdlGIJ:isEmpty()
        FwAlertHelp('Encomendas não selecionadas ou não encontradas para averbação',"Selecione ao menos uma encomenda para realizar a averbação","Atenção")
        oMdlAvb:Destroy()
        Return .F.
    Endif

    For n1  := 1 to oMdlGIJ:Length() 
        If oMdlGIJ:GetValue("GIJ_MARK",n1)
            oMdlGIJ:GoLine(n1)
            oMdlAvb:Activate()
            
            oMdlAvb:GetModel("GIJMASTER"):SetValue("GIJ_CODIGO" , oMdlGIJ:GetValue('G99_CODIGO'    ) )
            oMdlAvb:GetModel("GIJMASTER"):SetValue("GIJ_CODSEG" , oMdlCab:GetValue('CAB_CODSEG'    ) )
            oMdlAvb:GetModel("GIJMASTER"):SetValue("GIJ_TIPAVB" , oMdlCab:GetValue('CAB_OPERATION' ) )
            oMdlAvb:GetModel("GIJMASTER"):SetValue("G99RECNO"   , oMdlGIJ:GetValue('G99RECNO'      ) )
            oMdlAvb:GetModel("GIJMASTER"):SetValue("GIJRECNO"   , oMdlGIJ:GetValue('GIJRECNO'      ) )

            If !GTP808ATM(oMdlCab:GetValue('CAB_CODSEG') )
                oMdlAvb:GetModel("GIJMASTER"):SetValue("GIJ_NUMAVB" , oMdlGIJ:GetValue('GIJ_NUMAVB'    ) )
                oMdlAvb:GetModel("GIJMASTER"):SetValue("GIJ_CNPJSE" , oMdlGIJ:GetValue('GIJ_CNPJSE'    ) )
                oMdlAvb:GetModel("GIJMASTER"):SetValue("GIJ_NOMESE" , oMdlGIJ:GetValue('GIJ_NOMESE'    ) )
                oMdlAvb:GetModel("GIJMASTER"):SetValue("GIJ_NUMAPO" , oMdlGIJ:GetValue('GIJ_NUMAPO'    ) )
                oMdlAvb:GetModel("GIJMASTER"):SetValue("GIJ_DATAVB" , oMdlGIJ:GetValue('GIJ_DATAVB'    ) )
                oMdlAvb:GetModel("GIJMASTER"):SetValue("GIJ_HORAVB" , oMdlGIJ:GetValue('GIJ_HORAVB'    ) )
                oMdlAvb:GetModel("GIJMASTER"):SetValue("GIJ_PROTOC" , STR0057)   //'AVERBACAO-MANUAL'
     
            EndIf

            If oMdlAvb:VldData() 
                oMdlAvb:CommitData()
            Endif
            
            If oMdlAvb:GetModel("GIJMASTER"):GetValue("GIJ_STATUS") $ "2|3"
                lRet := .F.
            Endif

            oMdlGIJ:SetValue("GIJ_MARK",.F.)
        Endif
        oMdlAvb:DeActivate()
    Next

    If !IsBlind() .and. ValType(oView) == "O" .AND. oView:IsActive()
        ExecFilter(oView,.F.)    
        oView:Refresh()
    Endif

    oMdlAvb:Destroy()

Endif

If lRet 
   FwAlertSuccess(STR0056,STR0037) //"Registros marcados enviados com sucesso!","Atenção!!"
Else
    FwAlertWarning(STR0045 ,STR0037)//"Houve falhas na gravação da(s) averbação(ões), verifque os registros pelo campo de Msg de Erro" ,"Atenção!!"
Endif

Return lRet



//------------------------------------------------------------------------------
/* /{Protheus.doc} MarcarTodos

@type Static Function
@author jacomo.fernandes
@since 21/11/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Static Function MarcarTodos(oView)
Local oModel	:= oView:GetModel()
Local oMdlGIJ	:= oModel:GetModel("GIJDETAIL")
Local nX		:= ""
Local lMark		:= .T.

If oMdlGIJ:Length() > 0
	lMark		:= !oMdlGIJ:GetValue('GIJ_MARK')

	For nX := 1 to oMdlGIJ:Length()
		If !oMdlGIJ:IsDeleted(nX)
			oMdlGIJ:GoLine(nX)
			oMdlGIJ:SetValue('GIJ_MARK',lMark)

		Endif
	Next
	oMdlGIJ:GoLine(1)
Endif

Return 

//------------------------------------------------------------------------------
/* /{Protheus.doc} GTP808ATM
@type Function
@author GTP
@since 12/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTP808ATM(cCodSeg)
Local lRet := .T.
Local aAreaDL6 := DL6->(GetArea())

    dbSelectArea("DL6")
    DL6->(dbSetOrder(1))	
    If DL6->( dbSeek( xFilial('DL6')+cCodSeg ) ) .AND. Empty(DL6->DL6_ENDSOA)
        lRet := .F.
    EndIf
    RestArea(aAreaDL6)
Return lRet    
