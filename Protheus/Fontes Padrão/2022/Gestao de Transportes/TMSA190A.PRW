#include "protheus.ch"
#include "fwmvcdef.ch"
#include "TMSA190A.ch"


/*/{Protheus.doc} TMSA190A
    (Visao de monitoramento do histórico de manifesto eletronico)
    @type  Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function TMSA190A(nOption)
 Local oBrowse   := NIL
 Local cMatchKey := ""
 Local nViewRes  := 0
 private aRotina := MenuDef()

 default nOption := 1

    If nOption == 1
        oBrowse := FWMBrowse():New()
        oBrowse:SetAlias("DTQ")
        oBrowse:SetDescription(STR0001)
        //oBrowse:AddLegend("<Condicao>","BR_<Color |BLUE|ORANGE|>")
        oBrowse:SetCacheView(.F.)
        oBrowse:Activate()
    Else
        DbSelectArea("DLH")
        //-- Por Viagem 1-DLH_FILIAL+DLH_FILORI+DLH_VIAGEM
        If SubStr(funname(),1,7) $ "TMSA144|TMSA141|TMSA140|TMSAF60" 
            DbSetOrder(1)
            cMatchKey := xFilial("DLH") + DTQ->(DTQ_FILORI+DTQ_VIAGEM)

        //-- Por Manifesto 2-DLH_FILMAN+DLH_MANIFE+DLH_SERMAN
        ElseIf IsInCallStack("TMSA190")  //|
            DbSetOrder(2)
            cMatchKey := xFilial("DLH") + DTX->(DTX_FILMAN+DTX_MANIFE+DTX_SERMAN)
        
        //-- Por Documento de transporte 3-DLH_FILDOC+DLH_DOC+DLH_SERIE
        Else 
            DbSetOrder(3)
            cMatchKey := xFilial("DLH") + DT6->(DT6_FILDOC+DT6_DOC+DT6_SERIE)
        EndIf
        If DLH->(MsSeek(cMatchKey))
            //-- MODEL_OPERATION_VIEW
            //-- MODEL_OPERATION_INSERT
            //-- MODEL_OPERATION_UPDATE
            //-- MODEL_OPERATION_DELETE
            FWExecView( STR0001 ,'TMSA190A',MODEL_OPERATION_VIEW,, { || .T. },{ || .T. },nViewRes,,{ || .T. })  //"Visualizar"
        Else
            Help('',1,'TMSA190A01',,STR0012,03,00) //"--Manifesto não localizado para a viagem selecionada."
        EndIf
    Endif

Return Nil

/*/{Protheus.doc} MenuDef(
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function MenuDef()
 Local aRotinas := {}

        Aadd(aRotinas,{STR0002,"VIEWDEF.TMSA190A",0,1,0,NIL}) //| Pesquisa
        Aadd(aRotinas,{STR0003,"VIEWDEF.TMSA190A",0,2,0,NIL}) //| Visualizar
        Aadd(aRotinas,{STR0004,"VIEWDEF.TMSA190A",0,3,0,NIL}) //| Retransmitir

Return aRotinas

/*/{Protheus.doc} ModelDef()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ModelDef()
 Local oModel    := NIL
 Local oMDLHStru := FwFormStruct(1,"DLH")
 Local oMDTXStru := GenStruct(1,"DTX")
 Local oMDTQStru := GenStruct(1,"DTQ") // FwFormStruct(1,"DTQ",{|xCampo| !(xCampo $ "DTQ_DSTPOP|DTQ_DSCLFR|")})
 Local oMDT6Stru := GenStruct(1,"DT6") //FwFormStruct(1,"DT6")
 Local aPKDLH   := Strtokarr2( DLH->(IndexKey(1)),"+",.F.)
 
    oModel := MPFormModel():New("TMSA190A",,,/*bMdlCommit*/)
    oModel:AddFields("MODEL_DLH",,oMDLHStru)
    oModel:SetPrimaryKey(aPKDLH)
    oModel:getModel("MODEL_DLH"):SetDescription(STR0001)

    //+------------------------------------------------------------
    //-- Grid Viagens
    //+------------------------------------------------------------
    oModel:AddGrid("MGRID_DTQ","MODEL_DLH",oMDTQStru,/*bLinePre*/,/*bLinhaOk*/,/*bpre*/,/*bPost*/,{ |oMDGDTQ,lCopia| LdDataSet(oMDGDTQ,lCopia,"DTQ") } )
    oModel:GetModel("MGRID_DTQ"):SetDescription(STR0006)

    //+------------------------------------------------------------
    //-- Grid Manifesto
    //+------------------------------------------------------------
    oModel:AddGrid("MGRID_DTX","MGRID_DTQ",oMDTXStru,,,,,{|oMDGDTX,lCopia| LdDataSet(oMDGDTX,lCopia,"DTX")})
    oModel:GetModel("MGRID_DTX"):SetDescription(STR0005)
    oModel:GetModel("MGRID_DTX"):SetOptional(.T.)
    oModel:GetModel("MGRID_DTX"):SetNoInsertLine(.T.)
    oModel:GetModel("MGRID_DTX"):SetForceLoad(.T.)
    oModel:GetModel("MGRID_DTX"):SetOnlyQuery(.T.)
    oModel:GetModel("MGRID_DTX"):SetNoDeleteLine(.T.)

    oModel:GetModel("MGRID_DTX"):SetLPre({|| .T.})

    //+------------------------------------------------------------
    //-- Grid Documentos de Transportes
    //+------------------------------------------------------------
    oModel:AddGrid("MGRID_DT6","MGRID_DTX",oMDT6Stru,,,,,{ |oGdMDT6,lCopia| LdDataSet(oGdMDT6,lCopia,"DT6")})
    oModel:GetModel("MGRID_DT6"):SetDescription(STR0007)

    //+------------------------------------------------------------
    //-- Settings
    //+------------------------------------------------------------
    oModel:GetModel('MGRID_DTQ'):SetOnlyQuery(.T.)
    oModel:GetModel('MGRID_DTQ'):SetOptional(.T.)
    oModel:GetModel('MGRID_DTQ'):SetNoInsertLine(.T.)
    
    oModel:GetModel('MGRID_DT6'):SetOnlyQuery(.T.)
    oModel:GetModel('MGRID_DT6'):SetOptional(.T.)
    oModel:GetModel('MGRID_DT6'):SetNoInsertLine(.T.)
    oModel:GetModel("MGRID_DT6"):SetNoDeleteLine(.T.)
    oModel:GetModel("MGRID_DT6"):SetMaxLine(999)

Return oModel

/*/{Protheus.doc} ModelView()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function ViewDef()
 Local oView     := Nil
 Local oModel    := FwLoadModel("TMSA190A")
 Local oVDHLStru := FwFormStruct(2,"DLH") // Tabela de historico do MDF-e Automatico
 Local oVDTXStru := GenStruct(2,"DTX")    // FwFormStruct(2,"DTX",{|xCampo| (getSx3Cache(xCampo,"X3_BROWSE") != "S") }) //-- Tabela de Manifesto
 Local oVDTQStru := GenStruct(2,"DTQ")    // FwFormStruct(2,"DTQ",{|xCampo| !(xCampo $ "DTQ_DSTPOP|DTQ_DSCLFR|")}) //-- Tabela de Viagens
 Local oVDT6Stru := GenStruct(2,"DT6")    // FwFormStruct(2,"DT6") //-- Tabela de Documentos de Transporte

        oView := FwFormView():New()
        oView:SetModel(oModel)
        oView:SetDescription(STR0001)

        oView:AddField("VIEW_DLH",oVDHLStru,"MODEL_DLH")

        //+------------------------------------------------------------
        //-- Viagem
        //+------------------------------------------------------------
        oView:CreateHorizontalBox("BOX_GRID_B",28)
        oView:AddGrid("VGRID_DTQ",oVDTQStru,"MGRID_DTQ")
        oView:AddIncrementField("VGRID_DTQ","DTQ_ITEM")
        oView:EnableTitleView("VGRID_DTQ",STR0006)
        oView:SetOwnerView("VGRID_DTQ","BOX_GRID_B")

        //+------------------------------------------------------------
        //-- Divisao da View
        //+------------------------------------------------------------
        //-- Manifesto
        //+------------------------------------------------------------
        oView:CreateHorizontalBox("BOX_GRID_A",28)

        oView:AddGrid("VGRID_DTX",oVDTXStru,"MGRID_DTX")
        oView:AddIncrementField("VGRID_DTX","DTX_ITEM")
        oView:EnableTitleView("VGRID_DTX",STR0005)
        oView:SetOwnerView("VGRID_DTX","BOX_GRID_A")
        
        //+------------------------------------------------------------
        //-- Documentos
        //+------------------------------------------------------------
        oView:CreateHorizontalBox("BOX_GRID_C",44)
        oView:AddGrid("VGRID_DT6",oVDT6Stru,"MGRID_DT6")
        oView:AddIncrementField("VGRID_DT6","DT6_ITEM")
        oView:EnableTitleView("VGRID_DT6",STR0007)
        oView:SetOwnerView("VGRID_DT6","BOX_GRID_C")

        //+------------------------------------------------------------
        //| Work Around para ocultar os campos da DLH - Cabeçalho
        //+------------------------------------------------------------                
        oView:CreateHorizontalBox("FOLDER_AREA_BOX",0)
        oView:CreateFolder("FOLDER_GROUP_01","FOLDER_AREA_BOX")
        oView:AddSheet("FOLDER_GROUP_01","FOLDER_VIEW_DLH","CAMPOS_DLH")
        oView:CreateHorizontalBox("DLH_FOLDER_HBOX",100,,,"FOLDER_GROUP_01","FOLDER_VIEW_DLH")
        oView:SetOwnerView("VIEW_DLH","DLH_FOLDER_HBOX")

        oView:bAfterViewActivate := { |oView| TMA190AAct(oView)}

        oView:SetViewProperty("VGRID_DTQ","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| gdDblClick(oFormulario,cFieldName,nLineGrid,nLineModel,oView,"DTQ")}})
        oView:SetViewProperty("VGRID_DTX","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| gdDblClick(oFormulario,cFieldName,nLineGrid,nLineModel,oView,"DTX")}})
        oView:SetViewProperty("VGRID_DT6","GRIDDOUBLECLICK",{{|oFormulario,cFieldName,nLineGrid,nLineModel| gdDblClick(oFormulario,cFieldName,nLineGrid,nLineModel,oView,"DT6")}})


        //- Fields properties
        oVDT6Stru:SetProperty("DT6_STATUS", MVC_VIEW_PICT   ,"@BMP")

        // oView:SetViewProperty( 'VGRID_DTX', "CHANGELINE", {{ |oView, cViewID| chglDTXGrid(oView, cViewID) }} )
        //+-------------------------------------------------------------
        //| Botoes acoes relacionadas
        //+-------------------------------------------------------------
        oView:AddUserButton("Leg. Documentos",'',{|| TMA190ALeg("DT6") })  //| Legenda DT6-Documentos Transportes
        oView:AddUserButton("Leg. Viagens"   ,'',{|| TMA190ALeg("DTQ") })  //| Legenda DTQ-Viagens
        oView:AddUserButton("Vis.Manifesto"  ,"",{|| showSub("TMSA190")})  //| Exibe visualização do Manifesto
        oView:AddUserButton("Vis.Documentos" ,"",{|| showSub("TMSA500")})  //| Exibe visualização do Documento de frete

Return oView

/*/{Protheus.doc} showSub(rotina)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function showSub(cRotina)
 Local oModel  := FwModelActive()//FwLoadModel("TMSA190A")
 Local oMGrid  := NIL
 Local nLin    := 0
 Local cCampo1 := ""
 Local cCampo2 := ""
 Local cCampo3 := ""
 Local cBKPRot := FunName()
 Local aAreaDTX:= DTX->(GetArea())
    //+----------------------------------------------------------------
    //- VISUALIZA MANIFESTO
    //+----------------------------------------------------------------
    If cRotina == "TMSA190"
        oMGrid  := oModel:getModel("MGRID_DTX")
        nLin    := oMGrid:getLine()
        cCampo1 := oMGrid:getValue("DTX_FILMAN")
        cCampo2 := oMGrid:getValue("DTX_MANIFE")
        cCampo3 := oMGrid:getValue("DTX_SERMAN")
        //cCampo4 := oMGrid:getValue("DTX_SERMAN")
        //cCampo5 := oMGrid:getValue("DTX_SERMAN")
                             //-- 2-DTX_FILIAL+DTX_FILMAN+DTX_MANIFE+DTX_SERMAN
        DTX->(DbSetorder(2)) //-- 3-DTX_FILIAL+DTX_FILORI+DTX_VIAGEM+DTX_FILMAN+DTX_MANIFE+DTX_SERMAN
        If DTX->(MsSeek(xFilial("DTX") + cCampo1 + cCampo2 + cCampo3 ))
            SetFunName("TMSA190")
            TmsA190Mnt("DTX", 0, 2, cCampo1,cCampo2)
        EndIf

    //+----------------------------------------------------------------    
    //- VISUALIZA DOCUMENTOS
    //+----------------------------------------------------------------    
    ElseIf cRotina == "TMSA500"
        oMGrid  := oModel:getModel("MGRID_DT6")
        nLin    := oMGrid:getLine()
        cCampo1 := oMGrid:getValue("DT6_FILORI")
        cCampo2 := oMGrid:getValue("DT6_LOTNFC")

        DTP->(DbSetOrder(2))
        If DTP->(MsSeek(xFilial("DTP")+cCampo1+cCampo2))
        	SetFunName("TMSA200")
	        aRotina := { { "", "", 0, 1 },; 
			    	 	 { "", "", 0, 2 },;
				     	 { "", "", 0, 3 },;
			 		     { "", "", 0, 4 },;
			 		    { "", "", 0, 5 },;
			 		    { "", "", 0, 6 }}
            TmsA200Vis("DTP", DTP->(RecNo()), 6)
        EndIf
    EndIf
    SetFunName(cBKPRot)

    RestArea(aAreaDTX)
Return Nil

/* Static Function chglDTXGrid(oView,cViewID)
 Local oModel    := FwModelActive()
 Local oModelRld := FwLoadModel("TMSA190A")
 Local oModelDT6 := oModelRld:GetmODEL("MGRID_DTX")

        oView:Refresh()
Return .T. */

/**
    Executado após a ativação da view
*/
Function TMA190AAct(oView)
      oView:HideFolder('FOLDER_GROUP_01',1,2)
      oView:HideFolder('FOLDER_GROUP_01',1,1)
Return 

/*/{Protheus.doc} DTQStruct(nTipo)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function GenStruct(nTipo,cTbl)
 Local oForm    := NIL
 Local nI       := 1
 Local aCampos  := {}
 Local cX3Campo := ""
 Local aX3Box   := {}
 Local lVirtual := .F.
 Local aOrdem   := {}
 Local cOrdem   := "000"
 Local cCmpTipo := "C"
 Local cCmpPict := "@!" 
 Local cTitulo  := ""
 Local nTamanho := 0
 Local bBlock   := {|| .T.}
 Local bIniPad  := ""
 Local cTblId   := ""
 Local cTblOrd  := ""
 default nTipo  := 1

    //+------------------------------------------------------------------------------
    //| Define os campos que serao utilizados
    //+------------------------------------------------------------------------------
    If     cTbl == "DTQ"
           aCampos     := {"DTQ_FILORI","DTQ_VIAGEM","DTQ_ROTA","DTQ_DESROT","DTQ_TIPVIA","DTQ_DATGER","DTQ_HORGER","DA3_PLACA","DA4_NOME","DTQ_STATUS"}
                        //      1           2            3           4           5             6           7            8           9           10
                        //"DTQ_STATUS","DTQ_FILORI","DTQ_VIAGEM","DTQ_ROTA","DTQ_DESROT","DTQ_TIPVIA","DTQ_DATGER","DTQ_HORGER","DA3_PLACA","DA4_NOME"
           aOrdem      := {"002"      ,"003"       ,"004"       ,"005"     ,"006"       ,"007"       ,"008"       ,"009"       ,"010"      ,"001"      }
           cTblId      := "MVC_DTQ_ORD"
           cTblOrd     := "1"
           cTblKey     := "DTQ_FILORI+DTQ_VIAGEM"
           cTblDescr   := "INDICE VIRTUAL DTQ"

    ElseIf cTbl == "DTX"
           aCampos := {"DTX_DATMAN","DTX_HORMAN","DTX_FILORI","DTX_VIAGEM","DTX_FILMAN","DTX_MANIFE","DTX_SERMAN","DTX_CODVEI","DTX_RTIMDF","DTX_RTFMDF","DTX_FILDCA"}
                     //     1            2              3           4           5            6            7             8           9           10          11
                     //"DTX_FILORI","DTX_VIAGEM","DTX_FILMAN","DTX_MANIFE","DTX_SERMAN","DTX_FILDCA","DTX_DATMAN","DTX_HORMAN","DTX_CODVEI","DTX_RTIMDF","DTX_RTFMDF"
           aOrdem  := {"007"       ,"008"       ,"001"       ,"002"       ,"003"       ,"004"       ,"005"       ,"009"       ,"010"       ,"011"       ,"006"       }
           cTblId      := "MVC_DTX_ORD"
           cTblOrd     := "1"
           cTblKey     := "DTX_FILORI+DTX_VIAGEM+DTX_FILMAN+DTX_MANIFE"
           cTblDescr   := "INDICE VIRTUAL DTX"

    ElseIf cTbl == "DT6"
           aCampos := {	"DT6_FILDOC","DT6_DOC"   ,"DT6_SERIE" ,"DT6_VALTOT","REMETENTE"   ,"UF_REM"  ,"MUN_REM","DESTINATARIO"   ,"UF_DEST","MUN_DEST","UF_CALC","MUN_CALC","DT6_SITCTE" ,"DT6_RETCTE","DT6_STATUS","DT6_FILVGA","DT6_NUMVGA","DUD_FILMAN","DUD_MANIFE" ,"DT6_FILORI","DT6_LOTNFC"}
                      //     1               2           3           4           5            6            7          8           9           10          11        12            13          14            15             16           17           18            19       20            21
                      //"DT6_STATUS","DT6_FILVGA","DT6_NUMVGA","DT6_FILDOC","DT6_DOC"   ,"DT6_SERIE","DT6_VALTOT","A1_NOME"  ,"DUY_EST" ,"DUY_DESCRI","A1_NOME","DUY_EST"   , "DUY_DESCRI","DUY_EST"   ,"DUY_DESCRI","DT6_SITCTE", "DT6_RETCTE","DUD_FILMAN", "DUD_MANIFE,DT6_FILORI  ,DT6_LOTNFC "
           aOrdem  := { "004"       ,"005"       ,"006"       ,"007"       ,"008"       ,"009"      ,"010"       ,"011"       ,"012"    ,"013"       ,"014"    ,"015"       , "016"       ,"017"       ,"001"       ,"002"       ,"003"        ,"018"       ,"019"       ,"020"       ,"021"       }
           cTblId      := "MVC_DT6_ORD"
           cTblOrd     := "1"
           cTblKey     := "DUD_FILMAN+DUD_MANIFE"
           cTblDescr   := "INDICE VIRTUAL DT6"
    EndIf
    
    //+------------------------------------------------------------------------------
    //-- Modelo
    //+------------------------------------------------------------------------------
    If nTipo == 1
        oForm := FwFormModelStruct():New()
        //oForm:AddTable(cTblId, {} ,  STR0001 )
        oForm:AddIndex(1,cTblOrd,cTblKey,cTblDescr,"","",.F.)
        oForm:AddField("ITEM" ,"",cTbl+"_ITEM","C"   , 4 , 0, NIL       ,NIL         ,NIL ,NIL ,NIL ,NIL ,NIL ,.T.) //--Campo AutoIncremental
    Else
         oForm := FWFormViewStruct():NEW()
         oForm:AddField(cTbl+"_ITEM" ,"000" ,"ITEM"  ,STR0011 , {} ,"C" ,"@!"  , NIL, NIL, .F., NIL, NIL, NIL, NIL, NIL, .T. )
    EndIf

    //+-------------------------------------------------------------------------------
    For nI := 1 To Len(aCampos)
                
        //+-----------------------------------------------------------
        //| Define titulos de campos e X3_CAMPO correspondente 
        //+-----------------------------------------------------------
        cX3Campo := aCampos[nI]
        cTitulo  := getSx3Cache(cX3Campo,"X3_TITULO" )

        If cTbl == "DT6"
            If nI == 5
                cTitulo := STR0013 // "Remetente"
                cX3Campo:= "A1_NOME"
            ElseIf nI == 6
                cTitulo := STR0014 // "UF Reg.Remetente"
                cX3Campo:= "DUY_EST"
            ElseIf nI == 7
                cTitulo := STR0015 // "Mun.Remetente"
                cX3Campo:= "DUY_DESCRI"
            ElseIf nI == 8
                cTitulo := STR0016 // Destinatario
                cX3Campo:= "A1_NOME"
            ElseIf nI == 9
                cTitulo := STR0017 // "UF Reg. Destinatário"
                cX3Campo:= "DUY_EST"
            ElseIf nI == 10 
                cTitulo := STR0018 // Mun. Destinatario
                cX3Campo:= "DUY_DESCRI"
            ElseIf nI == 11
                cTitulo := STR0019 // UF Reg. Calculo
                cX3Campo:= "DUY_EST"
            ElseIf nI == 12
                cTitulo := STR0020 // Mun.Reg.Calculo
                cX3Campo:= "DUY_DESCRI"
            ENDIF
        EndIf
        
        nTamanho := getSx3Cache(cX3Campo,"X3_TAMANHO")
        lVirtual := (getSx3Cache(cX3Campo,"X3_CONTEXT") == "V")
        cCmpTipo := getSx3Cache(cX3Campo,"X3_TIPO"   )
        bBlock   := getSx3Cache(cX3Campo,"X3_VALID"  )
        bIniPad  := getSx3Cache(cX3Campo,"X3_RELACAO")
        cCmpTipo := getSx3Cache(cX3Campo,"X3_TIPO"   )
        cCmpPict := getSx3Cache(cX3Campo,"X3_PICTURE")

        //-- Tipo e Pictures para campos de status do tipo action/buttom
        If cX3Campo $ "DT6_STATUS|DTQ_STATUS"
            cCmpTipo := "C"
            cCmpPict := "@BMP"
            //cTitulo  := ""
        EndIf

        If nTipo == 1

                oForm:AddField( AllTrim(cTitulo)                             ,; //| [01] Titulo
                                ""                                           ,; //| [02] ToolTip/Dica de Campo
                                aCampos[nI]                                  ,; //| [03] Id Campo
                                cCmpTipo                                     ,; //| [04] Tipo
                                nTamanho                                     ,; //| [05] Tamanho
                                getSx3Cache(cX3Campo,"X3_DECIMAL" )       ,; //| [06] decimal
                                FwBuildFeature( STRUCT_FEATURE_VALID,bBlock) ,; //| [07] B Code-block de validação do campo
                                NIL                                          ,; //| [08] B Code-block de validação When do campo
                                NIL                                          ,; //| [09] A Lista de valores permitido do campo
                                .F.                                          ,; //| [10] L Indica se o campo tem preenchimento obrigatório
                                FwBuildFeature(STRUCT_FEATURE_INIPAD,bIniPad),; //| [11] B Code-block de inicializacao do campo
                                .F.                                          ,; //| [12] L Indica se trata de um campo chave
                                .F.                                          ,; //| [13] L Indica se o campo pode receber valor em uma operação de update.
                                lVirtual )                                      //| [14] L Indica se o campo é virtual
        //-- Visao
        Else
            

                aX3Box  := {}
                lEdit   := ((getSx3Cache(cX3Campo,"X3_VISUAL") != "V") .And. (getSx3Cache(cX3Campo,"X3_CONTEXT") != "V"))
                
                If !(cX3Campo $ "DT6_STATUS|DTQ_STATUS")
                   cX3Box := GetSX3Cache(cX3Campo,"X3_CBOX") //| carrega X3 Box se estiver preenchido.
                EndIf
                If !Empty(cX3Box)
                    aX3Box := Strtokarr2(cX3Box,";") // neste caso substitui o RetSx3Box( cX3Box,,, 1 ) pois o addfield espera um vetor na posicao [13]
                EndIf


                //--Define ordem dos campos
                cOrdem := aOrdem[nI]
                
                //--Adiciona configuracao de campo
                oForm:AddField( aCampos[nI]                               ,; //| [01] C ID do Campo/X3_CAMPO
                                cOrdem                                    ,; //| [02] C Ordem
                                AllTrim(cTitulo)                          ,; //| [03] C Titulo do campo
                                getSx3Cache(cX3Campo,"X3_DESCRIC")        ,; //| [04] C Descrição do campo
                                {}                                        ,; //| [05] A Array com Help
                                cCmpTipo                                  ,; //| [06] C Tipo do campo
                                cCmpPict                                  ,; //| [07] C Picture
                                NIL                                       ,; //| [08] B Bloco de Picture Var
                                getSx3Cache(cX3Campo,"X3_F3"     )        ,; //| [09] C Consulta F3
                                lEdit                                     ,; //| [10] L Indica se o campo é editável
                                getSx3Cache(cX3Campo,"X3_FOLDER" )        ,; //| [11] C Pasta do campo
                                NIL                                       ,; //| [12] C Agrupamento do campo
                                aX3Box                                    ,; //| [13] A Lista de valores permitido do campo (Combo)
                                NIL                                       ,; //| [14] N Tamanho Maximo da maior opção do combo
                                AllTrim(getSx3Cache(cX3Campo,"X3_INIBRW")),; //| [15] C Inicializador de Browse
                               (getSx3Cache(cX3Campo,"X3_VISUAL")=="S")   ,; //| [16] L Indica se o campo é virtual
                                )                                              //| [17] C Picture Variável
        EndIf //--Fim do 'If nTipo'
    Next nI

Return oForm

// ================================================================================================================================================
/*/{Protheus.doc} LoadVgm(oGridModel,lCopy)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function LdDataSet(oGridModel,lCopy,cTipo)
 Local aResult  := {}
 Local cFilOri  := ""
 Local cViagem  := ""
 Local cFilMan  := ""
 Local cManife  := ""
 Local oGdOwner := oGridModel:getOwner()
 Local nLnOwner := 0 

    //-- Carrega dados dos Manifestos...
    If cTipo == "DTX"
        // If IsBlind()
        //     FWMsgRun(, {|| aResult := DataSetRes(oGridModel,queryDTX(),"DTX") }, "Processando", STR0008)
        // Else
            nLnOwner:= oGdOwner:getLine()
            cFilOri := oGdOwner:getValue("DTQ_FILORI",nLnOwner)
            cViagem := oGdOwner:getValue("DTQ_VIAGEM",nLnOwner)
            aResult := DataSetRes(oGridModel,queryDTX(cFilori,cViagem),"DTX")
        // EndIf

    //-- Carrega dados das Viagens...
    ElseIf cTipo == "DTQ"
        // If IsBlind()
        //     FWMsgRun(, {|| aResult := DataSetRes(oGridModel,queryDTQ(),"DTQ") }, "Processando", STR0009)
        // Else
        aResult := DataSetRes(oGridModel,queryDTQ(),"DTQ")
        // EndIf
    
    //-- Carrega dados dos Documentos...
    ElseIf cTipo == "DT6"
        
        // If IsBlind()
        //     FWMsgRun(, {|| aResult := DataSetRes(oGridModel,queryDT6(),"DT6") }, "Processando", STR0010)
        // Else
        oGdOwner := oGridModel:getOwner()
        nLnOwner := oGdOwner:GetLine()
        cFilMan  := oGdOwner:getValue("DTX_FILMAN",nLnOwner)
        cManife  := oGdOwner:getValue("DTX_MANIFE",nLnOwner)
        aResult := DataSetRes(oGridModel,queryDT6(cFilMan,cManife),"DT6")
        // EndIf
    EndIf

Return aResult

// ================================================================================================================================================
/*/{Protheus.doc} DataSetDTX(oModel)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function DataSetRes(oModel,cQuery,cAlias)
 
 Local aAreas     := {(cAlias)->(GetArea()),GetArea()}
 Local aResult    := {}
 Local aliasTB    := GetNextAlias()
 Local oStructDb  := NIL
 Local aCampos    := {}
 Local nLine      := 0
 Local nCampo     := 1
 Local nTotFields := 0
 Local lBkpInclui := Iif(Type("INCLUI") == "L", INCLUI, Nil )

INCLUI := .F.

 Default cQuery   := ""

    If ValType(oModel) == "O"
        oStructDb   := oModel:GetStruct()
        aCampos     := aClone(oStructDb:GetFields())
        nTotFields  := Len(aCampos)
    Else
        Return aResult
    EndIf

    //+------------------------------------------------------------------------------
    //| Load dos Campos
    //+------------------------------------------------------------------------------
    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),aliasTB,.T.,.F.)

    If cAlias == "DT6"
        TcSetField(aliasTB,"DT6_DATEMI","D",8,0)
        DT6->(DbSetOrder(1))
    ElseIf cAlias == "DTX"
        TcSetField(aliasTB,"DTX_DATMAN","D",8,0)
        DTX->(DbSetOrder(1))
    ElseIf cAlias == "DTQ"
        TcSetField(aliasTB,"DTQ_DATGER","D",8,0)
        DTQ->(DbSetOrder(2))
    EndIf

    While((aliasTB)->(!EOF()))

        //Posiciona registros para inicializadores de campos virtuais funcionarem
        If cAlias == "DT6"
            DT6->( MsSeek( xFilial("DT6") + (aliasTB)->( DT6_FILDOC + DT6_DOC + DT6_SERIE ) ) )
        ElseIf cAlias == "DTX"
            DTX->( MsSeek( xFilial("DTX") + (aliasTB)->( DTX_MANIFE + DTX_SERMAN ) ) )
        ElseIf cAlias == "DTQ"
            DTQ->( MsSeek( xFilial("DTQ") + (aliasTB)->( DTQ_FILORI + DTQ_VIAGEM ) ) )
        EndIf

        //-- Adiciona uma nova linha para o modelo
        nLine += 1
        AADD(aResult,{nLine,Array(nTotFields)})

        //-- Set os valores de cada campo da linha adicionada ao modelo
        For nCampo := 1 To nTotFields

            //-- Campos Reais
            If .Not. aCampos[nCampo][MODEL_FIELD_VIRTUAL]
                aResult[nLine][2][nCampo] := (aliasTB)->&(aCampos[nCampo][MODEL_FIELD_IDFIELD])
                If aCampos[nCampo][MODEL_FIELD_IDFIELD] $ "DT6_STATUS|DTQ_STATUS"
                    aResult[nLine][2][nCampo] := getStatus(aResult[nLine][2][nCampo],cAlias)
                EndIf
            //--Campos virtuais
            Else
                If aCampos[nCampo][MODEL_FIELD_IDFIELD] == "FLAG"
                    aResult[nLine][2][nCampo] := "BR_BRANCO_OCEAN"
                Else
                    If (aCampos[nCampo][MODEL_FIELD_IDFIELD] $ "DTX_ITEM|DTQ_ITEM|DT6_ITEM")
                        aResult[nLine][2][nCampo] := ""
                    Else
                        aResult[nLine][2][nCampo] := CriaVar(aCampos[nCampo][MODEL_FIELD_IDFIELD],.T.)
                    EndIf
                EndIf
            EndIf
        
        Next nCampo
        (aliasTB)->(DbSkip())
    EndDo
    (aliasTB)->(DbCloseArea())

    AEval(aAreas,{|aArea| RestArea(aArea) })
    INCLUI := lBkpInclui

Return aResult

// ================================================================================================================================================
/*/{Protheus.doc} queryDTQ()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function queryDTQ()
 Local cQuery    := ""
 Local cFilori   := DLH->DLH_FILORI
 Local cViagem   := DLH->DLH_VIAGEM



        //+------------------------------------------------------------------------------
        //| Query de busca dos dados da(s) Viagem(ns)
        //+------------------------------------------------------------------------------
        cQuery := "SELECT "
        cQuery += "DTQ.DTQ_FILORI, "
        cQuery += "DTQ.DTQ_VIAGEM, "
        cQuery += "DTQ.DTQ_ROTA, "
        cQuery += "' ' DTQ_DESROT, "
        cQuery += "DTQ.DTQ_TIPVIA, "
        cQuery += "DTQ.DTQ_DATGER, "
        cQuery += "DTQ.DTQ_HORGER, "
        cQuery += "DA3.DA3_PLACA, "
        cQuery += "DA4.DA4_NOME, "
        cQuery += "DTQ.DTQ_STATUS "
        cQuery += " FROM " + RetSqlName("DTQ") + " DTQ " 
        
        cQuery += " LEFT JOIN " + RetSqlName("DTR") + " DTR ON " //| VEICULOS DA VIAGEM
        cQuery += " DTR.D_E_L_E_T_ = ' ' "
        cQuery += " AND DTR.DTR_FILIAL = '" + xFilial("DTR") + "' "
        cQuery += " AND DTR.DTR_FILORI = DTQ.DTQ_FILORI "
        cQuery += " AND DTR.DTR_VIAGEM = DTQ.DTQ_VIAGEM "
        
        cQuery += " LEFT JOIN " + RetSqlName("DUP") + " DUP ON " //| MOTORISTA DA VIAGEM
        cQuery += " DUP.D_E_L_E_T_ = ' ' "
        cQuery += " AND DUP.DUP_FILIAL = '" + xFilial("DUP") + "' "
        cQuery += " AND DUP.DUP_FILORI = DTR.DTR_FILORI "
        cQuery += " AND DUP.DUP_VIAGEM = DTR.DTR_VIAGEM "
        cQuery += " AND DUP.DUP_ITEDTR = DTR.DTR_ITEM " 

        cQuery += " LEFT JOIN " + RetSqlName("DA3") + " DA3 ON " //| VEICULOS
        cQuery += " DA3.DA3_FILIAL = '" + xFilial("DA3") + "' "
        cQuery += " AND DA3.D_E_L_E_T_ = ' ' "
        cQuery += " AND DA3.DA3_COD = DTR.DTR_CODVEI "

        cQuery += " LEFT JOIN " + RetSqlName("DA4") + " DA4 ON " //| MOTORISTAS
        cQuery += " DA4.DA4_FILIAL = '" + xFilial("DA4") + "' "
        cQuery += " AND DA4.D_E_L_E_T_ = ' ' "
        cQuery += " AND DA4.DA4_COD = DUP.DUP_CODMOT "

        If funname() $ "TMSA500|TMSA200|TMSC030"
            cQuery += " LEFT JOIN " + RetSqlName("DUD") + " DUD ON " //| Movimento das Viagens
            cQuery += "     DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
            cQuery += " AND DUD.D_E_L_E_T_ =  ' ' "
            cQuery += " AND DUD.DUD_FILORI = DTQ.DTQ_FILORI "
            cQuery += " AND DUD.DUD_VIAGEM = DTQ.DTQ_VIAGEM "
        EndIf

        //| FILTRO
        cQuery += " WHERE "
        If funname() $ "TMSA500|TMSA200|TMSC030"
            cQuery += " DUD.D_E_L_E_T_ = ' ' "
            cQuery += " AND DUD.DUD_FILIAL = '" + xFilial("DUD")  + "' "
            cQuery += " AND DUD.DUD_FILDOC = '" + DLH->DLH_FILDOC + "' "
            cQuery += " AND DUD.DUD_DOC    = '" + DLH->DLH_DOC    + "' "
            cQuery += " AND DUD.DUD_SERIE  = '" + DLH->DLH_SERIE  + "' "
        Else
            cQuery += " DTQ.D_E_L_E_T_ = ' ' "
            cQuery += " AND DTQ.DTQ_FILIAL = '" + xFilial("DTQ") + "' "
            cQuery += " AND DTQ.DTQ_FILORI = '" + cFilOri + "' "
            cQuery += " AND DTQ.DTQ_VIAGEM = '" + cViagem + "' "
        EndIf
        cQuery := ChangeQuery(cQuery)
Return cQuery

// ============================================================================================================================================
/*/{Protheus.doc} QueryDTX()
    (Retorna query para buscar os dados da Manifesto tabela DTX)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function queryDTX(cFilOri,cViagem)
 Local cQuery    := ""

 Default cFilori := DLH->DLH_FILORI
 Default cViagem := DLH->DLH_VIAGEM
        
        cQuery := "SELECT * FROM( "
        
	    cQuery += " SELECT "
	    cQuery += " '1' FLAG, "
	    cQuery += " DTX_DATMAN, "
	    cQuery += " DTX_HORMAN, "
	    cQuery += " DTX_FILORI, "
	    cQuery += " DTX_VIAGEM, "
	    cQuery += " DTX_FILMAN, "
	    cQuery += " DTX_MANIFE, "
        cQuery += " DTX_SERMAN, "
	    cQuery += " DTX_CODVEI, "
        cQuery += " DTX_RTIMDF, "
	    cQuery += " DTX_RTFMDF, "
        cQuery += " DTX_FILDCA  "
	    cQuery += " FROM " + RetSqlName("DTX") + " DTX "
	    cQuery += " INNER JOIN " + RetSqlName("DLH") + " DLH ON "
	    cQuery += "     DLH.D_E_L_E_T_ = ' ' "
	    cQuery += " AND  DLH.DLH_FILIAL = '" + xFilial("DLH") + "' "
	    cQuery += " AND  DLH.DLH_FILORI = DTX.DTX_FILORI "
	    cQuery += " AND  DLH.DLH_VIAGEM = DTX.DTX_VIAGEM "
	    cQuery += " AND  DLH.DLH_FILMAN = DTX.DTX_FILMAN "
	    cQuery += " AND  DLH.DLH_MANIFE = DTX.DTX_MANIFE "
	    cQuery += " WHERE DTX.D_E_L_E_T_ = ' ' "
	    cQuery += " AND   DTX.DTX_FILIAL = '" + xFilial("DTX") + "' "
        
        //-- DYN - MANIFESTO ELETRONICO CANCELADO
	    cQuery += " UNION "
        //-- Quando DTX é excluída a DYN é incluída como histórico do cancelamento
	    cQuery += " SELECT "
	    cQuery += " '0'	FLAG, "
	    cQuery += " DYN.DYN_DATMAN DTX_DATMAN, "
	    cQuery += " DYN.DYN_HORMAN DTX_HORMAN, "
	    cQuery += " DYN.DYN_FILORI DTX_FILORI, "
	    cQuery += " DYN.DYN_VIAGEM DTX_VIAGEM, "
	    cQuery += " DYN.DYN_FILMAN DTX_FILMAN, "
	    cQuery += " DYN.DYN_MANIFE DTX_MANIFE, "
        cQuery += " DYN.DYN_SERMAN DTX_SERMAN, "
	    cQuery += " DYN.DYN_CODVEI DTX_CODVEI, "
        cQuery += " DYN.DYN_RTIMDF DTX_RTIMDF, "
	    cQuery += " DYN.DYN_RTCMDF DTX_RTFMDF, "
        cQuery += " DYN.DYN_FILDCA DTX_FILDCA  "
	    cQuery += " FROM " + RetSqlName("DYN") + " DYN "
        cQuery += " INNER JOIN " + RetSqlName("DLHT") + " DLH ON "
	    cQuery += "     DLH.D_E_L_E_T_ = ' ' "
        cQuery += " AND  DLH.DLH_FILIAL = '" + xFilial("DLH") + "' "
        cQuery += " AND  DLH.DLH_FILORI = DYN.DYN_FILORI "
        cQuery += " AND  DLH.DLH_VIAGEM = DYN.DYN_VIAGEM "
	    cQuery += " AND  DLH.DLH_FILMAN = DYN.DYN_FILMAN "
	    cQuery += " AND  DLH.DLH_MANIFE = DYN.DYN_MANIFE "
	    cQuery += " WHERE DYN.D_E_L_E_T_ = ' ' "
	    cQuery += " AND   DYN.DYN_FILIAL = '" + xFilial("DYN") + "' "
	    
        cQuery += " ) TEMP "
	    cQuery += " WHERE TEMP.DTX_FILORI = '" + cFilOri + "' "
        cQuery += "  AND  TEMP.DTX_VIAGEM = '" + cViagem + "' "
	    cQuery += " ORDER BY TEMP.DTX_FILMAN,TEMP.DTX_DATMAN,TEMP.DTX_HORMAN,TEMP.DTX_MANIFE "

        cQuery := ChangeQuery(cQuery)

Return cQuery

// ============================================================================================================================================
/*/{Protheus.doc} QueryDT6()
    (Retorna query para buscar os dados da Manifesto tabela DTX)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function queryDT6(cFilMan,cManife)
 Local cQuery := ""
        
        cQuery := "SELECT DISTINCT "
        cQuery += " DT6.DT6_FILDOC, "
        cQuery += " DT6.DT6_DOC, "
        cQuery += " DT6.DT6_SERIE, "
        cQuery += " DT6.DT6_VALTOT, "
        //-- DADOS DA ORIGEM E DESTINO
        cQuery += " REM.A1_NOME REMETENTE, "
        cQuery += " RORI.DUY_EST UF_REM, "
        cQuery += " RORI.DUY_DESCRI MUN_REM, "
        cQuery += " DES.A1_NOME DESTINATARIO, "
        cQuery += " RDES.DUY_EST UF_DEST, "
        cQuery += " RDES.DUY_DESCRI MUN_DEST, "
        cQuery += " RCAL.DUY_EST UF_CALC, "
        cQuery += " RCAL.DUY_DESCRI MUN_CALC, " 
        //-- SITUACAO DO CT-E
        cQuery += " DT6.DT6_SITCTE, "
        cQuery += " DT6.DT6_RETCTE, "
        cQuery += " DT6.DT6_STATUS, "
        //-- DADOS DA VIAGEM
        cQuery += " DUD.DUD_FILORI DT6_FILVGA, "
        cQuery += " DUD.DUD_VIAGEM DT6_NUMVGA, "
        cQuery += " DUD.DUD_FILMAN DUD_FILMAN, "
        cQuery += " DUD.DUD_MANIFE DUD_MANIFE, "
        //-- ID do Lote de NF
        cQuery += " DT6.DT6_FILORI, "
        cQuery += " DT6.DT6_LOTNFC "

        cQuery += " FROM " + RetSqlName("DT6") + " DT6 " 

        //-- DESCRICAO DO REMETENTE
        cQuery += " LEFT JOIN( SELECT	A1_FILIAL,D_E_L_E_T_,A1_COD,A1_LOJA,A1_NOME	FROM " + RetSqlName("SA1") + " ) REM ON "
        cQuery += " REM.D_E_L_E_T_ = ' ' "
        cQuery += " AND REM.A1_FILIAL = '" + xFILIAL("SA1") + "' "
        cQuery += " AND REM.A1_COD = DT6.DT6_CLIREM "
        cQuery += " AND REM.A1_LOJA = DT6.DT6_LOJREM "

        //-- DESCRICAO DA REGIAO DO REMETENTE
        cQuery += " LEFT JOIN (SELECT DUY_GRPVEN,DUY_DESCRI,DUY_EST,DUY_FILIAL,D_E_L_E_T_ FROM " + RetSqlName("DUY") + ") RORI ON "
        cQuery += " RORI.D_E_L_E_T_ = ' ' "
        cQuery += " AND RORI.DUY_FILIAL = '" + xFILIAL("DUY") + "' "
        cQuery += " AND RORI.DUY_GRPVEN = DT6.DT6_CDRORI "

        //-- DESCRICAO DO DESTINATARIO
        cQuery += " LEFT JOIN( SELECT A1_FILIAL,D_E_L_E_T_,A1_COD,A1_LOJA,A1_NOME FROM " + RetSqlName("SA1") + " ) DES ON "
        cQuery += " DES.D_E_L_E_T_ = ' ' "
        cQuery += " AND DES.A1_FILIAL = '" + xFILIAL("SA1") + "' "
        cQuery += " AND DES.A1_COD = DT6.DT6_CLIDES "
        cQuery += " AND DES.A1_LOJA = DT6.DT6_LOJDES "

        //-- DESCRICAO DA REGIAO DO DESTINATARIO
        cQuery += " LEFT JOIN (SELECT DUY_GRPVEN,DUY_DESCRI,DUY_EST,DUY_FILIAL,D_E_L_E_T_ FROM " + RetSqlName("DUY") + ") RDES ON "
        cQuery += " RDES.D_E_L_E_T_ = ' ' "
        cQuery += " AND RDES.DUY_FILIAL = '" + xFILIAL("DUY") + "' "
        cQuery += " AND RDES.DUY_GRPVEN = DT6.DT6_CDRDES "

        //-- REGIAO DE CALCULO
        cQuery += " LEFT JOIN (SELECT DUY_GRPVEN,DUY_DESCRI,DUY_EST,DUY_FILIAL,D_E_L_E_T_ FROM " + RetSqlName("DUY") + ") RCAL ON "
	    cQuery += " RCAL.D_E_L_E_T_ = ' ' "
	    cQuery += " AND RCAL.DUY_FILIAL = '" + xFilial("DUY") +"' "
	    cQuery += " AND RCAL.DUY_GRPVEN = DT6.DT6_CDRCAL "

        // HISTORICO MANIFESTOS X DOCUMENTOS DE TRANSPORTE
        cQuery += " LEFT JOIN " + RetSqlName("DLH") + " DLH ON "
        cQuery += " DLH.D_E_L_E_T_ = ' ' "
        cQuery += " AND DLH.DLH_FILIAL = '" + xFILIAL("DLH") + "' "
        cQuery += " AND DLH.DLH_FILDOC = DT6.DT6_FILDOC "
        cQuery += " AND DLH.DLH_DOC    = DT6.DT6_DOC "
        cQuery += " AND DLH.DLH_SERIE  = DT6.DT6_SERIE "
        // DUD - MOVIMENTO VIAGEM
        cQuery += " INNER JOIN " + RetSqlName("DUD") + " DUD ON "
        cQuery += " DUD.DUD_FILIAL = '" + xFilial("DUD") + "' "
        cQuery += " AND  DUD.DUD_FILDOC = DT6.DT6_FILDOC "
        cQuery += " AND  DUD.DUD_DOC    = DT6.DT6_DOC "
        cQuery += " AND  DUD.DUD_SERIE  = DT6.DT6_SERIE "

        //-- WHERE
        cQuery += " WHERE DT6.D_E_L_E_T_ = ' ' "
        cQuery += " AND DT6.DT6_FILIAL = '" + xFILIAL("DT6") + "' "
        cQuery += " AND DT6.DT6_DOC = DLH.DLH_DOC "
        cQuery += " AND DLH.DLH_FILMAN = '" + cFilMan + "' "
        cQuery += " AND DLH.DLH_MANIFE = '" + cManife + "' "

        cQuery += " ORDER BY DT6_NUMVGA "
        cQuery := ChangeQuery(cQuery)

Return cQuery

// ============================================================================================================================================
/*/{Protheus.doc} CommitMDL()
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    Local aResult := {}

    @see (links_or_referaResult
    /*/
Static Function CommitMdl(oModel)
 Local   lRet      := .T.
 Local   bIntegEAI := {|oModel| 0 }
 Default oModel    := FwModelActive()

        nOpc := oModel:GetOperation()
        
        // Realiza o Commit
        If lRet
	        lRet := FWFormCommit(oModel,,,,,,bIntegEAI)
        EndIf

Return oModel

/*/{Protheus.doc} StString
    (long_descricResult
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function StString(cCampo)
 Local cResult := ""
 Local aTmp    := {}
 Local nI      := 1

    aTmp := TMSValField(cCampo,.F.,,,.T.)
    
    For nI := 1 To Len(aTmp)
        cResult += aTmp[nI][1]+"="+aTmp[nI][2] + ";"
    Next nI

Return cResult

/*/{Protheus.doc} getStatus(cStatus)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function getStatus(cStatus,cAlias)
 Local cResult := ""
 Local aStatus := {}
 Local nPos    := 0

    If cAlias == "DT6"
        AADD(aSTATUS,{"1","BR_VERDE_OCEAN"   }) //-- 1-Em aberto 
        AADD(aSTATUS,{"2","BR_VERMELHO_OCEAN"}) //-- 2-Carregado ### Indicado para Coleta
        AADD(aSTATUS,{"3","BR_AMARELO_OCEAN" }) //-- 3-Em Transito
        AADD(aSTATUS,{"4","BR_LARANJA_OCEAN" }) //-- 4-Chegada parcial ### Documento Informado
        AADD(aSTATUS,{"5","BR_AZUL_OCEAN"    }) //-- 5-Chegada final   ### Encerrad
        AADD(aSTATUS,{"6","BR_CINZA_OCEAN"   }) //-- 6-Indicado p/ entrega
        AADD(aSTATUS,{"7","BR_MARRON_OCEAN"  }) //-- 7-Entregue
        AADD(aSTATUS,{"8","BR_PINK_OCEAN"    }) //-- 8-Entrega Parcial
        AADD(aSTATUS,{"9","BR_CANCEL_OCEAN"  }) //-- 9-Anulado
        AADD(aSTATUS,{"A","BR_BRANCO_OCEAN"  }) //-- A-Retorno Total
        AADD(aSTATUS,{"B","PMSEDT4_OCEAN"    }) //-- B-Cancelamento SEFAZ Aguardando
        AADD(aSTATUS,{"C","PMSEDT3_OCEAN"    }) //-- C-Cancelamento SEFAZ Autorizado
        AADD(aSTATUS,{"D","PMSEDT1_OCEAN"    }) //-- D-Cancelamento SEFAZ Nao Autorizado

    ElseIf cAlias == "DTQ"
        AADD(aSTATUS,{"1","BR_VERDE_OCEAN"   }) //-- 1-Em aberto 
        AADD(aSTATUS,{"5","BR_VERMELHO_OCEAN"}) //-- 2-Fechada
        AADD(aSTATUS,{"2","BR_AMARELO_OCEAN" }) //-- 3-Em Transito
        AADD(aSTATUS,{"4","BR_LARANJA_OCEAN" }) //-- 4-Chegada em Filial
        AADD(aSTATUS,{"3","BR_AZUL_OCEAN"    }) //-- 5-Encerrada
        AADD(aSTATUS,{"3","BR_PRETO_OCEAN"   }) //-- 9-Cancelada

    EndIf

    If (nPos:=AScan(aStatus,{|y| y[1] == Upper(cStatus)})) > 0
        cResult := aStatus[nPos][2]
    EndIf

Return cResult

/*
*/
Function Tma190ALeg(cAlias)

 Local aLegenda := {}
 Local cTitulo  := STR0001
 Local cDescr   := ""

 Default cAlias := ""

    If cAlias == "DT6"
        aLegenda := {	{ "BR_VERDE"	, "Em Aberto"            },; //"Em Aberto"
                        { "BR_VERMELHO"	, "Indicado para Coleta" },; //"Carregado" ### "Indicado para Coleta"
                        { "BR_AMARELO"	, "Em Transito"          },; //"Em Transito"
                        { "BR_LARANJA"	, "Chegada Parcial/Documento Informado" },; //"Chegada Parcial" ### "Documento Informado"
                        { "BR_AZUL"		, "Chegada Final / Encerrada" },; //"Chegada Final" ### "Encerrada"
                        { "BR_CINZA"	, "Indicado para Entrega" },; //"Indicado para Entrega"
                        { "BR_MARRON"	, "Entregue" },; //"Entregue"
                        { "BR_PINK"		, "Entrega Parcial" },; //"Entrega Parcial"
                        { "BR_PRETO"	, "Ordem de Coleta Cancelada" },; //"Ordem de Coleta Cancelada"
                        { "BR_BRANCO"	, "Retorno Total" },; //"Retorno Total"
                        { "BR_CANCEL"	, "CTRC Anulado" },; // "CTRC Anulado"
                        { "PMSEDT4"		, "Cancelamento SEFAZ Aguardando" },; //"Cancelamento SEFAZ Aguardando"
                        { "PMSEDT3"		, "Cancelamento SEFAZ Autorizado" },; //"Cancelamento SEFAZ Autorizado"
                        { "PMSEDT1"		, "Cancelamento SEFAZ Nao Autorizado" } } //"Cancelamento SEFAZ Nao Autorizado"

    ElseIf cAlias == "DTQ"
            aLegenda := {{"BR_VERDE_OCEAN"   ,"Em Aberto"},;       //-- 1-Em aberto 
                         {"BR_VERMELHO_OCEAN","Fechada"},;         //-- 2-Fechada
                         {"BR_AMARELO_OCEAN" ,"Em Transito"},;     //-- 3-Em Transito
                         {"BR_LARANJA_OCEAN" ,"Chega em Filial"},; //-- 4-Chegada em Filial
                         {"BR_AZUL_OCEAN"    ,"Encerrada"},;       //-- 5-Encerrada
                         {"BR_PRETO_OCEAN"   ,"Cancelada"}}        //-- 9-Cancelada
    EndIf

    If !Empty(cAlias)
        BrwLegenda( cTitulo, cDescr, aLegenda  )  //"Status"
    EndIf

Return( Nil )

/*/{Protheus.doc}  gridDblDT6(oFormulario,cFieldName,nLineGrid,nLineModel,oView)
    (long_description)
    @type  Static Function
    @author user
    @since date
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function  gdDblClick(oFormulario,cFieldName,nLineGrid,nLineModel,oView,cAlias)
 Local oModel      := Nil
 Local aParam      := {}
 private lInCond   := .F. //-- Indica se é uma inclusão de condutor na transmissão do MDF-e, adicionado por ser solicitado pela rotina WsMDFeMnt(SPEDNFE.PRX)
 Private lUsaColab := .F.

    If cFieldName $ "DT6_STATUS|DTQ_STATUS" 
        TMA190Aleg(cAlias)
    ElseIf cFieldName $ "DTX_RTIMDF|DTX_RTFMDF"
         oModel := FwModelActive()
         AADD(aParam,oModel:getModel("MGRID_DTX"):getValue("DTX_SERMAN")) //- 1-Man.Serie
         AADD(aParam,oModel:getModel("MGRID_DTX"):getValue("DTX_MANIFE")) //- 2-Nr. Manifesto De
         AADD(aParam,oModel:getModel("MGRID_DTX"):getValue("DTX_MANIFE")) //- 3-Nro Manifesto Ate
         AADD(aParam,.T.) //-- 4-lCTe
         AADD(aParam,.T.) //-- 5-lMdfe
         AADD(aParam,"")  //-- 6-cModel
         AADD(aParam,.T.) //-- 7-lTMS
         
         //SpedNFe6Mnt(cSerie,cNotaIni,cNotaFim, lCTe, lMDFe, cModel,lTMS, lAutoColab,lExibTela,lUsaColab,lNFCE)
          SpedNFe6Mnt(aParam[1],aParam[2],aParam[3], aParam[4],aParam[5],aParam[6],aParam[7], ,,,)
    EndIf

Return
