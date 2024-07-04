#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "FWCSS.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FWBROWSE.CH"

#DEFINE PROFILE_ID cEmpAnt+cFilAnt+"_"+RetCodUsr() 
#DEFINE GLB_PARAMS "__MATC300_"+"PARAMS_"+PROFILE_ID
#DEFINE GLB_ESTNEG "__MATC300_"+"ESTNEG_"+PROFILE_ID
#DEFINE GLB_PRDCLI "__MATC300_"+"PRDCLI_"+PROFILE_ID
#DEFINE GLB_DESMON "__MATC300_"+"DESMON_"+PROFILE_ID
#DEFINE GLB_RETRAB "__MATC300_"+"RETRAB_"+PROFILE_ID

Static oDlgWA       := Nil
Static oBrwSB2      := Nil
Static oBrwSC2      := Nil
Static oBrwSX6      := Nil
Static oBrwSD3      := Nil
Static oBrwRET      := Nil
Static oCoverPanel  := Nil
Static cAliEstNeg   := ""
Static cAliPrdCli   := ""
Static cAliParam    := ""
Static cAliDesmon   := ""
Static cAliRetrab   := ""

Static cPanelContext := "MAIN"
Static lBuildBrw     := .F.
Static lInTimer      := .F.
Static lInClick      := .F.
 
//-------------------------------------------------------------------
/*/{Protheus.doc} MATC300
Diagnóstico do Bloco K
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Function MATC300()
    Local aSize         := FWGetDialogSize( oMainWnd )
    Local oDlgWA        := Nil
    Local oWorkArea     := Nil
    Local oMenu         := Nil
    Local oSVG          := Nil
    Local cMenuFld1     := ""
    Local cMenuFld2     := ""
    Local cValid        := ""
    Local oMenuItem     := Nil
    Local nSayLimit     := 0
    Local nX            := 0
    Local oFwProfile    := Nil
    Local lUpdated      := AliasInDic("D3K")
    Local cContentPf    := ""


    Private aParams     := {}
    Private aSvgRef     := {}
    Private cGetMes     := Space(3)
    Private cGetAno     := Space(4)
    Private aParametros := {}
    Private oTimer      := Nil
    Private lProc       := .T.

	If lUpdated

        PutGlbValue(GLB_ESTNEG, "READY")
        PutGlbValue(GLB_PRDCLI, "READY")
        PutGlbValue(GLB_PARAMS, "READY")
        PutGlbValue(GLB_DESMON, "READY")
        PutGlbValue(GLB_RETRAB, "READY")

        cCadastro := "Diagnóstico do Bloco K"

        oDlgWA := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "Diagnóstico do Bloco K", , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) 

        oWorkArea := FWUIWorkArea():New( oDlgWA )
        oWorkArea:SetMenuWidth( 215 )

        oMenu := FWMenu():New()
        oMenu:Init()

        cMenuFld1  := oMenu:AddFolder( "Principal", "E" )
        oMenuItem   := oMenu:GetItem(cMenuFld1) 
        oMenuItem:AddSeparator()
        oMenuItem:AddContent( "Início"              , "E", {|| SetContext('MAIN',oTimer),MATC300Main(oWorkArea )      })
        oMenuItem:AddContent( "Sair"                        , "E", {|| If(CloseScreen(),oDlgWA:End(),.T.) } )
        oMenuItem:AddSeparator()
        cMenuFld2   := oMenu:AddFolder( "Regras", "E" )
        oMenuItem   := oMenu:GetItem(cMenuFld2) 
        oMenuItem:AddSeparator()
        oMenuItem:AddContent( "Configurações Para Envio"                , "E", {|| SetContext('PARAMS',oTimer), ParamSetup( oWorkArea, @oBrwSX6 )            })
        oMenuItem:AddContent( "Estoque Negativo"                        , "E", {|| SetContext('ESTNEG',oTimer), GenericRule( oWorkArea,@oBrwSB2,'ESTNEG')    })
        oMenuItem:AddContent( "Amarração do Produto"                    , "E", {|| SetContext('PRDCLI',oTimer), GenericRule( oWorkArea,@oBrwSC2,'PRDCLI')    })
        oMenuItem:AddContent( "Desmontagem"                             , "E", {|| SetContext('DESMON',oTimer), GenericRule( oWorkArea,@oBrwSD3,'DESMON')    })
        oMenuItem:AddContent( "OP. de Retrabalho"                       , "E", {|| SetContext('RETRAB',oTimer), GenericRule( oWorkArea,@oBrwRET,'RETRAB')    })

        oWorkArea:SetMenu( oMenu )

        oWorkArea:CreateHorizontalBox( "LINE01", aSize[3], .T.)
        oWorkArea:SetBoxCols( "LINE01", { "WDGT01" } )

        oWorkArea:Activate()

        //Ao adicionar um item no menu, adicionar também o componente svg.
        For nX := 8 To 12
            oMnuOpc := oWorkArea:oMenuNav:oUiMenuNav:aItem[nX]:oSay
            oMnuOpc:Disable()
            nSayLimit  := (oMnuOpc:nClientWidth/2)-20
            oSVG := TSVG():New(4.5, nSayLimit,oMnuOpc,20,20,SvgWait())
            oSVG:SetCSS( FWCSSVerify( GetClassName(oSVG), "QWidget", "QWidget{border: none; background: transparent;}" ) )
            oSVG:Hide()
            aAdd(aSVGRef,@oSVG)
        Next nX

        oTimer      := TTimer():New( 3000, {|| SvgUpdt(aSvgRef),BrwUpdate() }  ,oDlgWA )

        oDlgWA:Activate(,,,,,,{|| MATC300Main( oWorkArea ), oTimer:Activate() }) 

        oFwProfile    := FWPROFILE():New()
        oFwProfile:SetUser(RetCodUsr())
        oFwProfile:SetProgram('MATC300')
        oFwProfile:SetTask('BLOCOKVLD')
        oFwProfile:SetType('VALIDATION')
        oFwProfile:Activate()

        If  GetGlbValue(GLB_ESTNEG) == 'ZERO';
            .And. GetGlbValue(GLB_PRDCLI) == 'ZERO';
            .And. GetGlbValue(GLB_DESMON) == 'ZERO'

            cValid := "VALID"
            cContentPf := "Dados válidos para a geração do Bloco K"
        Else
            cValid := "PROBLEMS"
            cContentPf := "Divergências encontradas no diagnóstico"
        Endif

        oFwProfile:SetProfile({cValid,cContentPf,dDatabase})
        oFwProfile:Save(.T.)
        oFwProfile:DeActivate()

        ClearTMP() 

    Else
        MsgInfo("Necessário Pacote de Atualização BlocoK."+CRLF+"Consulte o Administrador do sistema.")
    Endif

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetContext
Informa para o workarea qual é a opção selecionada atualmente
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function SetContext(cOption,oTimer)
    oTimer:Deactivate()
    lInClick := .T.
    lBuildBrw     := .F.

    While lInTimer
        //Utilizado para aguardar o processamento do timer.
    EndDo
    
    Do Case
        Case cPanelContext == 'ESTNEG'
            If ValType(oBrwSX6) == 'O' 
                oBrwSB2:Destroy()
                oBrwSB2 := Nil
            Endif
        Case cPanelContext == 'PRDCLI' 
            If ValType(oBrwSX6) == 'O' 
                oBrwSC2:Destroy()
                oBrwSC2 := Nil
            Endif
        Case cPanelContext == 'PARAMS'
            If ValType(oBrwSX6) == 'O' 
                oBrwSX6:Destroy()
                oBrwSX6 := Nil
            Endif
        Case cPanelContext == 'DESMON'
            If ValType(oBrwSX6) == 'O'
                oBrwSD3:Destroy()
                oBrwSD3 := Nil
            Endif
        Case cPanelContext == 'RETRAB'
            If ValType(oBrwSX6) == 'O'
                oBrwRET:Destroy()
                oBrwRET := Nil
            Endif            
    EndCase

    cPanelContext := cOption
    lInClick := .F.
    oTimer:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SvgUpdt
Atuliza o componente SVG do menu. Chamado pelo timer da tela.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function SvgUpdt(aSvgRef)
    Local cThrdNeg      := GetGlbValue(GLB_ESTNEG)
    Local cThrdPrCli    := GetGlbValue(GLB_PRDCLI)
    Local cThrdParam    := GetGlbValue(GLB_PARAMS)
    Local cThrdDesm     := GetGlbValue(GLB_DESMON)
    Local cThrdRetrb    := GetGlbValue(GLB_RETRAB)
    Local nX            := 0
    Local oSVG          := Nil

    For nX := 1 To Len(aSvgRef)
        oSVG := aSvgRef[nX]
        Do Case
            Case nX == 1
                Do Case 
                    Case cThrdParam == 'ZERO'
                        oSVG:LoadSVG( SvgCheck() )
                    Case cThrdParam == 'FULL'
                        oSVG:LoadSVG( SvgWarn() )
                EndCase
            Case nX == 2
                Do Case
                    Case cThrdNeg == "FULL"
                        oSVG:LoadSVG( SvgWarn() )
                    Case cThrdNeg == "ZERO"
                        oSVG:LoadSVG( SvgCheck() )  
                EndCase
            Case nX == 3
                Do Case
                    Case cThrdPrCli == 'FULL'
                        oSVG:LoadSVG( SvgWarn() )
                    Case cThrdPrCli == 'ZERO'
                        oSVG:LoadSVG( SvgCheck() )
                EndCase
            Case nX == 4
                Do Case
                    Case cThrdDesm == 'FULL' 
                        oSVG:LoadSVG( SvgWarn() )
                    Case cThrdDesm == 'ZERO'
                        oSVG:LoadSVG( SvgCheck() )
                EndCase
            Case nX == 5
                Do Case
                    Case cThrdRetrb == 'FULL' 
                        oSVG:LoadSVG( SvgWarn() )
                    Case cThrdRetrb == 'ZERO'
                        oSVG:LoadSVG( SvgCheck() )
                EndCase                
        EndCase
    Next nX

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MATC300Main
Tela principal
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Function MATC300Main( oWaMain )
    Local oPanel        := oWaMain:GetPanel( "WDGT01" )
    Local oLogo         := Nil
    Local oPanelFull    := Nil
    Local oPanelLogo    := Nil
    Local oPanelTit     := Nil
    Local oTextTit      := Nil
    Local oPanelLeft    := Nil
    Local oPanelRight   := Nil
    Local oPanelFilter  := Nil
    Local oPanelDesc    := Nil
    Local oPanelProc    := Nil
    Local oBtProc       := Nil
    Local oBtRpt        := Nil
    Local oGetAno       := Nil
    Local oGetMes       := Nil
    Local oGetDtDe      := Nil
    Local oGetDtAte     := Nil
    Local aPeriodo      := {'Jan','Fev','Mar','Abr','Mai','Jun','Jul','Ago','Set','Out','Nov','Dez'}
    Local lVld          := .F.
    Local dGetDtDe      := Ctod("//")
    Local dGetDtAte     := Ctod("//") 
    Local cPerg         := "MATC300"
    Local bProcBloc     := Nil
    
    Aadd(aParametros,{1,"Mês" ,cGetMes ,"@" 	 ,""  ,""    ,"" ,120 ,.F. })
    Aadd(aParametros,{1,"Ano" ,cGetAno ,"@" 	 ,""  ,""    ,"" ,120 ,.F. })

    SetPrvt("MV_PAR01")
    MV_PAR01 := ParamLoad(cPerg,aParametros,1,aParametros[1,3],Iif(Len(aParametros[1])>9,aParametros[1,10],.F.))
    SetPrvt("MV_PAR02")
    MV_PAR02 := ParamLoad(cPerg,aParametros,2,aParametros[2,3],Iif(Len(aParametros[2])>9,aParametros[2,10],.F.))

    If !Empty(MV_PAR01) .And. !Empty(MV_PAR02)
        dGetDtDe    := RetData('DE',MV_PAR02,MV_PAR01,aPeriodo)
        dGetDtAte   := RetData('ATE',MV_PAR02,MV_PAR01,aPeriodo)
    Endif

    //Limpa o Painel
    oPanel:freeChildren()
    
    oPanelFull := TPanelCss():New(0,0,"",oPanel,,.F.,.F.,,,oPanel:nWidth/2,oPanel:nHeight/2,.T.,.F.)
    oPanelFull:SetCSS("TPanelCss { background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; }")
    
    oPanelLogo := TPanelCss():New(0,(oPanelFull:nWidth/4)-40,"",oPanelFull,,.F.,.F.,,,83.5,80,.T.,.F.)
    oPanelLogo:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
    oPanelLogo:Align := CONTROL_ALIGN_TOP
    oPanelLogo:ReadClientCoors(.T.,.T.)
    
    oLogo := TBitmap():New(0,(oPanelLogo:nWidth/4) -40,0,0,'FW_TOTVS.png',,.T.,oPanelLogo,,,.F.,.F.,,,.F.,,.T.,,)
    oLogo:lAutoSize := .T.

    oPanelTit := TPanelCss():New(0,(oPanelFull:nWidth/4)-40,"",oPanelFull,,.F.,.F.,,,0,70,.T.,.F.)
    oPanelTit:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
    oPanelTit:Align := CONTROL_ALIGN_TOP
    oPanelTit:ReadClientCoors(.T.,.T.)

    oTextTit := tSimpleEditor():New(0,(oPanelTit:nWidth/4)-150, oPanelTit,300 ,70,,.T.,,,.T. )
    oTextTit:Setcss("color: #757776; font-size: 20px; background-color : transparent; border: 0px; ") 
    oTextTit:Load("<h1 align='center'>Diagnóstico Bloco K</h1>")

    oPanelLeft := TPanelCss():New(0,(oPanelFull:nWidth/4)-40,"",oPanelFull,,.F.,.F.,,,(oPanelFull:nWidth/4)+2,80,.T.,.F.)
    oPanelLeft:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
    oPanelLeft:Align := CONTROL_ALIGN_LEFT
    oPanelLeft:ReadClientCoors(.T.,.T.)
    
    oPanelDesc := TPanelCss():New(2,2,"",oPanelLeft,,.F.,.F.,,,(oPanelLeft:nWidth/2)-4,(oPanelLeft:nHeight/2)-4 ,.T.,.F.)
    oPanelDesc:SetCSS("TPanelCss { background-color : #FCFAF9; border: 1px solid #DCDCDC;  border-radius: 4px;}") 

    oTextDesc := tSimpleEditor():New(2,2, oPanelDesc,(oPanelDesc:nWidth/2)-4,(oPanelDesc:nHeight/2)-32,,.T.,,,.T. )
    oTextDesc:Setcss("background-color : transparent; border: 1px solid #DCDCDC;  border-radius: 4px; ") 
    oTextDesc:Load("<strong>O Diagnóstico do Bloco K irá te auxiliar a identificar os principais " + ;
                    "problemas que possam causar divergências no processamento do Bloco K.</strong><br />" +;
                    "<p>Selecione os filtros desejados e clique em Processar para iniciar o diagnóstico.</p><br />"+;
                    "Atenção: Algumas das regras podem demorar para processar, porém é possível consultar "+;
                    "o conteúdo prévio enquanto o sistema está em processamento.")
    
    oPanelLink := TPanelCss():New((oPanelLeft:nHeight/2)-30,4,"",oPanelLeft,,.F.,.F.,,,(oPanelLeft:nWidth/2)-8,26 ,.T.,.F.)
    oPanelLink:SetCSS("TPanelCss { background-color : #FCFAF9; border: 0px solid #DCDCDC;  border-radius: 4px;}") 
    
    oBtnLei1 := TButton():New( 0, 0, "Guia de Referência do Bloco K"   ,oPanelLink,, oPanelLink:nWidth/2 ,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
    oBtnLei1:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 1px solid #DCDCDC; border-radius: 4px;}")
    oBtnLei1:bLClicked := {|| ShellExecute("open", "http://tdn.totvs.com/pages/releaseview.action?pageId=235589625" ,"","",SW_SHOW) }

    oBtnLei2 := TButton():New(14, 0, "Guia do Diagnóstico do Bloco K"   ,oPanelLink,, oPanelLink:nWidth/2 ,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
    oBtnLei2:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 1px solid #DCDCDC; border-radius: 4px;}")
    oBtnLei2:bLClicked := {|| ShellExecute("open", "http://tdn.totvs.com/pages/viewpage.action?pageId=442045336" ,"","",SW_SHOW) }

    oPanelRight := TPanelCss():New(0,(oPanelFull:nWidth/4)-40,"",oPanelFull,,.F.,.F.,,,(oPanelFull:nWidth/4)-4,80,.T.,.F.)
    oPanelRight:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
    oPanelRight:Align := CONTROL_ALIGN_RIGHT
    oPanelRight:ReadClientCoors(.T.,.T.)
    
    oPanelFilter := TPanelCss():New(2,2,"",oPanelRight,,.F.,.F.,,,(oPanelRight:nWidth/2)-4,(oPanelRight:nHeight/2)-34 ,.T.,.F.)
    oPanelFilter:SetCSS("TPanelCss { background-color : #FCFAF9; border: 1px solid #DCDCDC;  border-radius: 4px;}") 
    
    oFont3 := TFont():New("Arial",,-11,,.T.,,,,,,.F.)
    oSayTitle:= TSay():New(2,2,{|| ""},oPanelFilter,,oFont3,,,,.T.,,,(oPanelFilter:nWidth/2)-4,15,,,,,,.T.)
    oSayTitle:SetCss("background-color : #E9F0F6; border: 1px #DCDCDC; border-top-left-radius: 4px; border-top-right-radius: 4px;")

    oSayTitle2:= TSay():New(6,6,{|| "Filtros"},oPanelFilter,,oFont3,,,,.T.,,,100,20,,,,,,.T.)
    oSayTitle2:SetCss("background-color : transparent; color : #757776}")

    oSay := tSay():New(25,4,{|| "Período/Ano:" },oPanelFilter,,,,,,.T.,,,40,10)
    oGetMes := TComboBox():New(23,40,{|u|if(PCount()>0,MV_PAR01:=u,MV_PAR01)},aPeriodo,28,13,oPanelFilter,,{||MV_PAR02:=Space(4),dGetDtDe:=dGetDtAte:=Ctod("//")},,,,.T.,,,,,,,,,'MV_PAR01')


    oSay := tSay():New(25,70,{|| "/" },oPanelFilter,,,,,,.T.,,,40,10)
    oGetAno := TGet():New(23, 75, { |u| If( PCount() == 0, MV_PAR02, MV_PAR02 := u ) },oPanelFilter,020,010,"@9999",{|| Empty(MV_PAR02) .Or. VldAno(MV_PAR02,.T.) },0,16777215,,.F.,,.T.,,.F.,{||.T.}/*When*/,.F.,.F.,{|| dGetDtDe := RetData('DE',MV_PAR02,MV_PAR01,aPeriodo),dGetDtAte := RetData('ATE',MV_PAR02,MV_PAR01,aPeriodo) },,.F. ,,"MV_PAR02",,,,.T. )

    oSay := tSay():New(45,4,{|| "Data De:" },oPanelFilter,,,,,,.T.,,,40,10)
    oGetDtDe := TGet():New(43, 40, { |u| If( PCount() == 0, dGetDtDe, dGetDtDe := u ) },oPanelFilter,060,010,"@D",,0,16777215,,.F.,,.T.,,.F.,{||.F.}/*When*/,.F.,.F.,,.T.,.F. ,,"dGetDtDe",,,,.T. )


    oSay := tSay():New(65,4,{|| "Data Até:" },oPanelFilter,,,,,,.T.,,,40,10)
    oGetDtAte := TGet():New(63, 40, { |u| If( PCount() == 0, dGetDtAte, dGetDtAte := u ) },oPanelFilter,060,010,"@D",,0,16777215,,.F.,,.T.,,.F.,{||.F.}/*When*/,.F.,.F.,,.T.,.F. ,,"dGetDtAte",,,,.T. )

    oPanelProc := TPanelCss():New((oPanelRight:nHeight/2)-30,2,"",oPanelRight,,.F.,.F.,,,(oPanelRight:nWidth/4)-4,28 ,.T.,.F.)
    oPanelProc:SetCSS("TPanelCss { background-color : #FCFAF9; border: 1px solid #DCDCDC;  border-radius: 4px;}") 
    
    
    bProcBloc:= {|| SaveFilter(MV_PAR01,MV_PAR02),;
                    StartProc(oWaMain:oMenuNav:oUiMenuNav,MV_PAR02,dGetDtDe,dGetDtAte,oBtProc,oGetMes,oGetAno)}

    oBtProc := TButton():New( 2, 2, "Processar",oPanelProc,bProcBloc, (oPanelProc:nWidth/2)-4,(oPanelProc:nHeight/2)-4,,,.F.,.T.,.F.,,.F.,,,.F. )

    If !lProc
        oBtProc:Disable()
        oGetMes:Disable()
        oGetAno:bWhen:= {||.F.}
    Endif
    //oBtRpt := TButton():New( 2, (((oPanelProc:nWidth/2)-4)/2)+2, "Relatório",oPanelProc,{|| }, (((oPanelProc:nWidth/2)-4)/2),(oPanelProc:nHeight/2)-4,,,.F.,.T.,.F.,,.F.,,,.F. )
    //oBtRpt:Disable()
    
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} SaveFilter
Salva os dados do filtro 
    
@author Flavio Lopes Rasta
@since  Nov 28, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function SaveFilter(cMes,cGetAno)
    Local cPerg       := "MATC300"

    cGetMes := MV_PAR01
    cGetAno := MV_PAR02

    ParamSave(cPerg,aParametros,"1")

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VldAno
Valida o campo ano do filtro
    
@author Flavio Lopes Rasta
@since  Nov 28, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function VldAno(cGetAno,lScreen)
    Local lRet := .F.
    Default lScreen := .F.

    If Len(AllTrim(cGetAno)) == 4
        If Val(cGetAno) > 0
            lRet := .T.
        Endif
    Endif

    If !lRet .And. lScreen
        Help(" ",1,"MATC300ANO",,"O Ano informado é inválido",1,1)
    Endif

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} RetData
Retorna a data completa baseado no per~iodo do filtro 
    
@author Flavio Lopes Rasta
@since  Nov 28, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function RetData(cRef,cAno,cMes,aPeriodo)
    Local cData := Stod(cAno + StrZero(aScan(aPeriodo,{|x| x == cMes }),2) + "01")
    Local dDataRet := Ctod("//") 

    If VldAno(cAno,.F.)
        If cRef == 'DE'
            dDataRet := FirstDate(cData)
        ElseIf cRef == 'ATE'
            dDataRet := LastDate(cData)
        Endif
    Endif

Return dDataRet

//-------------------------------------------------------------------
/*/{Protheus.doc} StartProc
Inicia o processamento
    
@author Flavio Lopes Rasta
@since  Nov 28, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function StartProc(oMenuNav,cGetAno,dDataDe,dDataAte,oBtProc,oGetMes,oGetAno)
    Local lRet := VldAno(cGetAno,.T.)

    If lRet
        //Bloqueia tela inicial para alteração.

        oBtProc:Disable()
        oGetMes:Disable()
        oGetAno:bWhen:= {||.F.}
        lProc:=.F.

        //Altera Icones do menu para Loading
        MenuLoad(oMenuNav) 

        //Limpa tabelas temporárias
        ClearTMP()

        //Start job dos Parâmetros
        ProcParams(@cAliParam)

        //Start job do Estoque negativo
        ProcEstNeg(@cAliEstNeg,dDataDe,dDataAte)

        //Start job da Amarração do Produto com o Cliente
        ProcPrdCli(@cAliPrdCli,dDataDe,dDataAte)

        //Start job da Desmontagem
        ProcDesmon(@cAliDesmon,dDataDe,dDataAte)

        //Start job da OP. de Retrabalho
        ProcRetrab(@cAliRetrab,dDataDe,dDataAte)

    Endif

Return lRet
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuLoad
Realiza a carga inicial dos componentes visuais do menu
    
@author Flavio Lopes Rasta
@since  Nov 28, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MenuLoad(oMenuNav)
    Local oMnuOpc   := Nil
    Local nX        := 0

    For nX := 8 To 12
        oMnuOpc := oMenuNav:aItem[nX]:oSay
        oMnuOpc:Enable()
    Next nX

    For nX:=1 To Len(aSVGRef)
        aSVGRef[nX]:Show()
        aSVGRef[nX]:LoadSVG(SvgWait())
    Next nX

Return aSVGRef

//-------------------------------------------------------------------
/*/{Protheus.doc} Matc300OK
Exemplo de implementação da tela vazia 2.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function Matc300OK(oWaMain)
    Local oPanel := oWaMain:GetPanel( "WDGT01" )

    oPanel:freeChildren()

    oPanelFull := TPanelCss():New(0,0,"",oPanel,,.F.,.F.,,,oPanel:nWidth/2,oPanel:nHeight/2,.T.,.F.)
    oPanelFull:SetCSS("TPanelCss { background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; }")

    oTextDesc := tSimpleEditor():New((oPanel:nHeight/4)-55,(oPanel:nWidth/4)-10, oPanelFull,240,100,,.T.,,,.T. )
    oTextDesc:Setcss("color: #757776; background-color : transparent; border: none; font-size: 60px;") 
    oTextDesc:Load("<strong>&#9786;</strong>")

    oTextDesc := tSimpleEditor():New((oPanel:nHeight/4)-30,(oPanel:nWidth/4)-115, oPanelFull,240,100,,.T.,,,.T. )
    oTextDesc:Setcss("color: #757776; background-color : transparent; border: none; font-size: 25px;") 
    oTextDesc:Load("<br /><strong>Não existem itens para serem exibidos.</strong>")
    
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SvgWait
XML do ícone de loading animado em SVG.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function SvgWait( cBGColor )

    Local cSVG As Char
    Default cBGColor    := "#FFFFFF"

    cSVG := "<?xml version='1.0' standalone='no'?> <!DOCTYPE svg PUBLIC '-//W3C//DTD SVG 1.1//EN' "
    cSVG += "'http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd'>"
    cSVG += "<svg viewBox='0 0 90 90' width='36' height='36' version='1.1' xmlns='http://www.w3.org/2000/svg'>"
    cSVG += "<g transform='translate(18,18)' >"
    cSVG += " <g transform='rotate(45)' >"
    cSVG += " <circle fill='none' stroke='#424142' cx='0' cy='0' r='16' stroke-width='3' />"
    cSVG += " <line x1='-13' y1='-13' x2='13' y2='13' stroke='"+ cBGColor +"' stroke-width='4' />"
    cSVG += " <animateTransform attributeName='transform' type='rotate' values='0; 360'"
    cSVG += " dur='2s' repeatCount='indefinite' rotate='auto'/>"
    cSVG += " </g>"
    cSVG += "</g>"
    cSVG += "<circle fill='"+ cBGColor +"' cx='18' cy='18' r='11' stroke-width='3'/>"
    cSVG += "<g transform='translate(18,18)' >"
    cSVG += " <g transform='rotate(45)' >"
    cSVG += "   <circle fill='none' stroke='#9C9A9C' cx='0' cy='0' r='11' stroke-width='3'/>"
    cSVG += "   <circle fill='"+ cBGColor +"' cx='2' cy='0' r='11.5' stroke-width='3'/>"
    cSVG += "   <line x1='0' y1='13' x2='2' y2='-12' stroke='"+ cBGColor +"' stroke-width='5' />"
    cSVG += "   <line x1='2' y1='14' x2='4' y2='-14' stroke='"+ cBGColor +"' stroke-width='2' />"
    cSVG += "   <line x1='4' y1='13' x2='6' y2='-13' stroke='"+ cBGColor +"' stroke-width='2' />"
    cSVG += "   <animateTransform attributeName='transform' type='rotate' values='360; 0'"
    cSVG += "    dur='1.3s' repeatCount='indefinite' rotate='auto'/>"
    cSVG += " </g>"
    cSVG += "</g>"
    cSVG += "</svg>"

Return cSVG

//-------------------------------------------------------------------
/*/{Protheus.doc} SvgCheck
XML do ícone de check positivo em SVG.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function SvgCheck()
    Local cSVG As Char

    cSVG := "<?xml version='1.0' encoding='UTF-8' standalone='no'?>"
    cSVG += "<svg viewBox='0 0 60 60' width='38' height='38' xmlns='http://www.w3.org/2000/svg'>"
    cSVG += "	<g stroke='#2ca02c' stroke-width='2.3' fill='#fff'> "
	cSVG += "	<circle cx='10' cy='10' r='8.5'/> "
	cSVG += "</g> "
    cSVG += "<g transform='scale(0.48) translate(9,10)' fill='#2ca02c'> "
  	cSVG += "<path d='M20.285 2l-11.285 11.567-5.286-5.011-3.714 3.716 9 8.728 15-15.285z'/> "
    cSVG += " </g>
    cSVG += "</svg>

Return cSVG

//-------------------------------------------------------------------
/*/{Protheus.doc} SvgWarn
XML do ícone de aviso em SVG.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function SvgWarn()

    Local cSVG As Char

    cSVG := "<?xml version='1.0' ?>"
    cSVG +="<svg height='15px' version='1.1' viewBox='0 0 32 32' width='15px'"
    cSVG +="    xmlns='http://www.w3.org/2000/svg'"
    cSVG +="    xmlns:xlink='http://www.w3.org/1999/xlink'>"
    cSVG +="    <g fill='none' fill-rule='evenodd' stroke='none' stroke-width='1'>
    cSVG +="        <g fill='#FFD700' id='icon-61-warning'>"
    cSVG +="            <path d='M14.3077969,"
    cSVG +="            6.05448962 C15.177863,"
    cSVG +="            4.64682663 16.5905922,"
    cSVG +="            4.65018129 17.4585848,"
    cSVG +="            6.05448962 L28.2436741,"
    cSVG +="            23.5034768 C29.4052031,"
    cSVG +="            25.382692 28.5591104,"
    cSVG +="            26.9060969 26.3549711,"
    cSVG +="            26.9060969 L5.41141065,"
    cSVG +="            26.9060969 C3.20677982,"
    cSVG +="            26.9060969 2.35742742,"
    cSVG +="            25.388761 3.52270757,"
    cSVG +="            23.5034768 L14.3077969,"
    cSVG +="            6.05448962 L14.3077969,"
    cSVG +="            6.05448962 Z M15.8835643,"
    cSVG +="            11.9060969 C15.3312795,"
    cSVG +="            11.9060969 14.8835643,"
    cSVG +="            12.3591332 14.8835643,"
    cSVG +="            12.903127 L14.8835643,"
    cSVG +="            18.9090667 C14.8835643,"
    cSVG +="            19.4597113 15.3274291,"
    cSVG +="            19.9060969 15.8835643,"
    cSVG +="            19.9060969 C16.435849,"
    cSVG +="            19.9060969 16.8835643,"
    cSVG +="            19.4530606 16.8835643,"
    cSVG +="            18.9090667 L16.8835643,"
    cSVG +="            12.903127 C16.8835643,"
    cSVG +="            12.3524825 16.4396994,"
    cSVG +="            11.9060969 15.8835643,"
    cSVG +="            11.9060969 L15.8835643,"
    cSVG +="            11.9060969 Z M15.8835643,"
    cSVG +="            23.9060969 C16.435849,"
    cSVG +="            23.9060969 16.8835643,"
    cSVG +="            23.4583816 16.8835643,"
    cSVG +="            22.9060969 C16.8835643,"
    cSVG +="            22.3538121 16.435849,"
    cSVG +="            21.9060969 15.8835643,"
    cSVG +="            21.9060969 C15.3312795,"
    cSVG +="            21.9060969 14.8835643,"
    cSVG +="            22.3538121 14.8835643,"
    cSVG +="            22.9060969 C14.8835643,"
    cSVG +="            23.4583816 15.3312795,"
    cSVG +="            23.9060969 15.8835643,"
    cSVG +="            23.9060969 L15.8835643,"
    cSVG +="            23.9060969 Z' id='warning'/>"
    cSVG +="        </g>"
    cSVG +="    </g>"
    cSVG +="</svg>"

Return cSVG

//-------------------------------------------------------------------
/*/{Protheus.doc} BrwUpdate
Realiza o refresh nos browses ativos.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function BrwUpdate()

    While lInClick
        //Utilizado para aguardar o processamento do click no menu.
    EndDo

    lInTimer := .T.

    Do Case
        Case cPanelContext == 'PARAMS'
            If lBuildBrw .And. ValType(oBrwSX6) == 'O' .And. oBrwSX6:lActivate 
                oBrwSX6:Execute( "RefreshFake()",3,0)
            Endif
        Case cPanelContext == 'ESTNEG'   
            If lBuildBrw .And. ValType(oBrwSB2) == 'O' .And. oBrwSB2:lActivate 
                oBrwSB2:Execute( "RefreshFake()",3,0)
            Endif 
        Case cPanelContext == 'PRDCLI'
            If lBuildBrw .And. ValType(oBrwSC2) == 'O'  .And. oBrwSC2:lActivate
                oBrwSC2:Execute( "RefreshFake()",3,0)
            Endif
        Case cPanelContext == 'DESMON'
            If lBuildBrw .And. ValType(oBrwSD3) == 'O'  .And. oBrwSD3:lActivate
                oBrwSD3:Execute( "RefreshFake()",3,0)
            Endif
        Case cPanelContext == 'RETRAB'
            If lBuildBrw .And. ValType(oBrwRET) == 'O'  .And. oBrwRET:lActivate
                oBrwRET:Execute( "RefreshFake()",3,0)
            Endif            
    EndCase

    lInTimer := .F. 

Return 
//-------------------------------------------------------------------
/*/{Protheus.doc} RefreshFake
Função para ser executada pelo browse apenas para atualizar o 
conteúdo. Não precisa executar nada.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function RefreshFake()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ClearTMP
Exclui as tabelas temporárias criadas pela rotina
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ClearTMP()
    //--Desativa Browse

    If(ValType(oBrwSB2) == 'O')
        oBrwSB2:Destroy()
        oBrwSB2 := Nil
    Endif

    If(ValType(oBrwSC2) == 'O')
        oBrwSC2:Destroy()
        oBrwSC2 := Nil
    Endif

    If(ValType(oBrwSX6) == 'O')
        oBrwSX6:Destroy()
        oBrwSx6 := Nil
    Endif

    If(ValType(oBrwSD3) == 'O')
        oBrwSD3:Destroy()
        oBrwSD3 := Nil
    Endif

    If(ValType(oBrwRET) == 'O')
        oBrwRET:Destroy()
        oBrwRET := Nil
    Endif

    //--Deleta tabela temporária do browse
    If !Empty(cAliParam)
        (cAliParam)->(dbCloseArea())
        TcDelFile(cAliParam)
        cAliParam := ""
    Endif

    If !Empty(cAliEstNeg)
        (cAliEstNeg)->(dbCloseArea())
        TcDelFile(cAliEstNeg)
        cAliEstNeg := ""
    Endif

    If !Empty(cAliPrdCli)
        (cAliPrdCli)->(dbCloseArea())
        TcDelFile(cAliPrdCli)
        cAliPrdCli := ""
    Endif

    If !Empty(cAliDesmon)
        (cAliDesmon)->(dbCloseArea())
        TcDelFile(cAliDesmon)
        cAliDesmon := ""
    Endif

    If !Empty(cAliRetrab)
        (cAliRetrab)->(dbCloseArea())
        TcDelFile(cAliRetrab)
        cAliRetrab := ""
    Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} GenericRule
Regras Genérica do sistema.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GenericRule(oWaMain,oBrwRef, cRegra)

    Local oPanel        := oWaMain:GetPanel( "WDGT01" )
    Local oWorkArea     := Nil
    Local oWDGT01       := Nil
    Local oWDGT02       := Nil
    Local oWDGT03       := Nil
    Local oGetPrblm     := Nil
    Local oLinkPrblm    := Nil
    Local oBtnLei1      := Nil
    Local oBtnLei2      := Nil
    Local cTitle        := ""
    Local cDesc         := ""
    Local cTGet1        := ""
    Local cTGet2        := ""
    Local cTGet3        := ""
    Local cTexto1       := ""
    Local cQuery        := ""
    Local cPrblmDesc    := ""
    Local cAliasBrw     := ""
    Local aSize         := {}
    Local aFields       := {}
    Local aSizeWg1      := {}
    Local aSizeWg2      := {}
    Local aIndex        := {}
    Local aLegend       := {}
    Local nX            := 0
    Local nHeightPrbl   := 0
    Local lLinkLei      := .F.
    Local cTitleLei1    := ""
    Local cTitleLei2    := ""
    Local cLinkLei1     := ""
    Local cLinkLei2     := ""
    

    oPanel:freeChildren()

    aSize     := FWGetDialogSize( oPanel )

    oWorkArea := FWUIWorkArea():New( oPanel )


    oWorkArea:CreateHorizontalBox( "LINE01X", 100, .T. )
    oWorkArea:SetBoxCols( "LINE01X", { "WDGT01X" } )

    oWorkArea:CreateHorizontalBox( "LINE01", (aSize[3]-130)/2, .T. )
    oWorkArea:SetBoxCols( "LINE01", { "WDGT01" } )

    oWorkArea:CreateHorizontalBox( "LINE02", (aSize[3]-130)/2 , .T. )
    oWorkArea:SetBoxCols( "LINE02", { "WDGT02","WDGT03" } )

    oWorkArea:Activate()

    oWDGT01X := oWorkArea:GetPanel("WDGT01X")
    aSizeWg1 := FWGetDialogSize( oWDGT01X )

    oTopBar := TPanel():New( 0 , 0 ,,oWDGT01X,,,,,, aSizeWg1[4]-2.5, 40.4) 
    oTopBar:SetCss( FWGetCSS( GetClassName(oTopBar), CSS_FORMBAR_TOP_BG ) ) 

    oFont := TFont():New("Arial",,-20,,.T.,,,,,,.F.)	
    oFont2 := TFont():New("Arial",,-10,,.T.,,,,,,.F.)

    Do Case
        Case cRegra == 'ESTNEG'
            cTitle    := "Estoque Negativo"
            cDesc     := "Produtos com saldo negativo no estoque"

            cPrblmDesc := "<p><b>Os itens exibidos acima possuem saldo negativo no estoque e não poderão ser processados no bloco K.</b></p>"
            cPrblmDesc += "<p><b>Além disso, de acordo com o Artigo 41, da Lei Federal nº 9.430/96 e o Artigo 286, do Decreto Federal nº 3.000/99, "
            cPrblmDesc += "a presença de estoque negativo poderá ser considerada como omissão de receita, levando a autuação da empresa. </b></p>"

            Aadd(aFields,{FWX3Titulo('B9_LOCAL')    ,'B9_LOCAL' ,'C',TamSx3('B9_LOCAL')[1]  ,Nil                    ,'@!'}) 
            Aadd(aFields,{FWX3Titulo('B9_COD')      ,'B9_COD'   ,'C',TamSx3('B9_COD')[1]    ,TamSx3('B9_COD')[2]    ,'@!'}) 
            Aadd(aFields,{FWX3Titulo('B9_QINI')     ,'B9_QINI'  ,'C',TamSx3('B9_QINI')[1]   ,TamSx3('B9_QINI')[2]   ,'@!'}) 

            cAliasBrw := cAliEstNeg

            lLinkLei    := .T.
            cTitleLei1   := "Artigo 41, da Lei Federal nº 9.430/96"
            cLinkLei1    := "http://www.planalto.gov.br/ccivil_03/LEIS/L9430.htm"

            cTitleLei2   := "Artigo 286, do Decreto Federal nº 3.000/99"
            cLinkLei2    := "http://www2.camara.leg.br/legin/fed/decret/1999/decreto-3000-26-marco-1999-369704-publicacaooriginal-1-pe.html"

        Case cRegra == 'PRDCLI'
            cTitle    := "Amarração do Produto"
            cDesc     := "Produção de terceiros sem amarração com o cliente"

            cPrblmDesc := "<p><b>As Ordens de Produção exibidas acima possuem itens de terceiros os quais o sistema não consegue identificar o proprietário.</b></p>"
            cPrblmDesc += "<p><b>Para o processamento do Bloco K, é necessário que seja informado detalhadamente o saldo dos itens de terceiro em posse do informante, caso contrário haverão divergências na apuração.</b></p>"

            Aadd(aFields,{FWX3Titulo('D3_OP')    ,'D3_OP' ,'C',TamSx3('D3_OP')[1]  ,Nil                    ,'@!'})
            
            Aadd(aLegend,{'STATS == " " .Or. STATS == "0" ' ,"RED"      , "Ordem de produção sem amarração"})
            Aadd(aLegend,{'STATS == "2" '                   ,"YELLOW"   , "Ordem de produção com amarração parcial"})

            cAliasBrw := cAliPrdCli

            lLinkLei := .F.

        Case cRegra == 'DESMON'
            cTitle    := "Desmontagem"
            cDesc     := "Itens desmontados com divergências"

            cPrblmDesc := "<p><b>Os itens exibidos acima possuem divergências no processo de desmontagem de produtos.</b></p>" 
            cPrblmDesc += "<p><b>Os tipos de divergência estão destacados nas legendas.</b></p>"
            cPrblmDesc += "<p><b>Para o envio do Bloco K, o sistema considera os itens desmontados através do processo padrão no programa MATA242 - Desmontagem, "
            cPrblmDesc += "sendo assim, qualquer divergência nesse processo impede o item de ser transmitido no seu devido bloco. Além do mais, qualquer processo não padrão será desconsiderado.</b></p>"            

            Aadd(aFields,{FWX3Titulo('D3_DOC')    ,'D3_DOC' ,'C',TamSx3('D3_DOC')[1]  ,Nil                    ,'@!'})
            Aadd(aFields,{FWX3Titulo('D3_COD')    ,'D3_COD' ,'C',TamSx3('D3_COD')[1]  ,Nil                    ,'@!'})
            Aadd(aFields,{FWX3Titulo('D3_NUMSEQ')    ,'D3_NUMSEQ' ,'C',TamSx3('D3_NUMSEQ')[1]  ,Nil            ,'@!'})
            
            Aadd(aLegend,{'STATS == "0" '   ,"RED"      , "Item Origem igual ao Item destino"   })
            Aadd(aLegend,{'STATS == "1" '   ,"BLUE"     , "Sem item destino (DE7)"              })
            Aadd(aLegend,{'STATS == "2" '   ,"YELLOW"   , "Sem item origem (RE7)"               })

            cAliasBrw := cAliDesmon

            lLinkLei := .F.

        Case cRegra == 'RETRAB'
            cTitle    := "OP. de Retrabalho"
            cDesc     := "OPs. de Retrabalho com inconsistência nas movimentações."

            cPrblmDesc := "<p><b>As ordens de produção exibidas acima estão definidas com o tipo de produção igual a retrabalho e neste período não possuem movimentação para o produto a ser retrabalhado.</b></p>"

            Aadd(aFields,{FWX3Titulo('D3_OP')    ,'D3_OP' ,'C',TamSx3('D3_OP')[1]  ,Nil                    ,'@!'})
            Aadd(aFields,{FWX3Titulo('D3_COD')    ,'D3_COD' ,'C',TamSx3('D3_COD')[1]  ,Nil                    ,'@!'})

            cAliasBrw := cAliRetrab

            lLinkLei := .F.

    EndCase

    oSayTitle:=     TSay():New(10,10,{|| cTitle }   ,oTopBar,,oFont,,,,.T.,,,300,20,,,,,,.T.)
    oSayTitle2:=    TSay():New(25,10,{|| cDesc }    ,oTopBar,,oFont2,,,,.T.,,,200,20,,,,,,.T.)

    oSayTitle:SetCss("background-color : transparent; color: #0B9BBF}")
    oSayTitle2:SetCss("background-color : transparent; color: #0B9BBF}")

    oWDGT01 := oWorkArea:GetPanel("WDGT01")

    //oGroupX:= TGroup():New(0,0,(oWDGT01:nHeight/2),oWDGT01:nWidth/2,,oWDGT01,,,.T.)

    oGroupX := TPanelCss():New(0,0,"",oWDGT01,,.F.,.F.,,,oWDGT01:nWidth/2,oWDGT01:nHeight/2,.T.,.F.) 

    //CoverPanel

    oCoverPanel := TPanelCss():New(0,0,"",oWDGT01,,.F.,.F.,,,oWDGT01:nWidth/2,oWDGT01:nHeight/2,.T.,.F.)
    oCoverPanel:SetCSS("TPanelCss { background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; }")

    oTextDesc := tSimpleEditor():New((oWDGT01:nHeight/4)-55,(oWDGT01:nWidth/4)-10, oCoverPanel,240,100,,.T.,,,.T. )
    oTextDesc:Setcss("color: #757776; background-color : transparent; border: none; font-size: 60px;") 
    oTextDesc:Load("<strong>&#9786;</strong>")

    oTextDesc := tSimpleEditor():New((oWDGT01:nHeight/4)-30,(oWDGT01:nWidth/4)-115, oCoverPanel,240,100,,.T.,,,.T. )
    oTextDesc:Setcss("color: #757776; background-color : transparent; border: none; font-size: 25px;") 
    oTextDesc:Load("<br /><strong>Não existem itens para serem exibidos.</strong>")

    oCoverPanel:Hide()

    oWDGT02 := oWorkArea:GetPanel("WDGT02")

    oFont3 := TFont():New("Arial",,-12,,.T.,,,,,,.F.)
    oSayTitle:= TSay():New(0,0,{|| ""},oWDGT02,,oFont3,,,,.T.,,,oWDGT02:nWidth/2,15,,,,,,.T.)
    oSayTitle:SetCss("background-color : #E9F0F6; border-top-left-radius: 4px; border-top-right-radius: 4px;}")

    oSayTitle2:= TSay():New(4,4,{|| "Descrição do Problema"},oWDGT02,,oFont3,,,,.T.,,,100,20,,,,,,.T.)

    oSayTitle2:SetCss("background-color : transparent; color : #757776;}")

    oGroup1 := TPanelCss():New(18,0,"",oWDGT02,,.F.,.F.,,,oWDGT02:nWidth/2,(oWDGT02:nHeight/2)-18,.T.,.F.)

    If lLinkLei
        
        nHeightPrbl := 14

        oLinkPrblm := TPanelCss():New((oGroup1:nHeight/2)-12,0,"",oGroup1,,.F.,.F.,,,(oGroup1:nWidth/2),12,.T.,.F.)
        oLinkPrblm:SetCSS("TPanelCss { background-color : transparent; border-radius: 4px; border: 0px solid #DCDCDC; }")

        oBtnLei1 := TButton():New( 0, 0, cTitleLei1   ,oLinkPrblm,, ((oLinkPrblm:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
        oBtnLei1:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 1px solid #DCDCDC; border-radius: 4px;}")
        oBtnLei1:bLClicked := {|| ShellExecute("open", cLinkLei1 ,"","",SW_SHOW) }

        oBtnLei2 := TButton():New( 0, ((oLinkPrblm:nWidth/2)/2)+1, cTitleLei2   ,oLinkPrblm,, ((oLinkPrblm:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
        oBtnLei2:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 1px solid #DCDCDC; border-radius: 4px;}")
        oBtnLei2:bLClicked := {|| ShellExecute("open", cLinkLei2 ,"","",SW_SHOW) }
    Else
        nHeightPrbl := 0
    Endif

    oGetPrblm := tSimpleEditor():New(0, 0, oGroup1 ,(oGroup1:nWidth/2) , (oGroup1:nHeight/2)-nHeightPrbl,,.T.,,,.T. )
    oGetPrblm:Load(cPrblmDesc)
    oGetPrblm:Setcss("background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; ") 


    oWDGT03 := oWorkArea:GetPanel("WDGT03")

    oFont3 := TFont():New("Arial",,-11,,.T.,,,,,,.F.)
    oSayTitle:= TSay():New(0,0,{|| ""},oWDGT03,,oFont3,,,,.T.,,,oWDGT03:nWidth/2,15,,,,,,.T.)
    oSayTitle:SetCss("background-color : #E9F0F6; border-top-left-radius: 4px; border-top-right-radius: 4px;}")

    oSayTitle2:= TSay():New(4,4,{|| "O que verificar?"},oWDGT03,,oFont3,,,,.T.,,,100,20,,,,,,.T.)
    oSayTitle2:SetCss("background-color : transparent; color : #757776}")

    oGroup2 := TPanelCss():New(18,0,"",oWDGT03,,.F.,.F.,,,oWDGT03:nWidth/2,(oWDGT03:nHeight/2)-18,.T.,.F.)
    oGroup2:SetCSS("TPanelCss { background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; }")

    MenuSoluc(oGroup2, cRegra)


    oBrwRef := FWMBrowse():New()
    oBrwRef:SetAlias(cAliasBrw)
    oBrwRef:Setfields(aFields)
    oBrwRef:DisableReport()
    oBrwRef:DisableDetails()

    For nX := 1 To Len(aLegend)
        oBrwRef:AddLegend(aLegend[nX,1],aLegend[nX,2],aLegend[nX,3])
    Next nX

    oBrwRef:Activate(oGroupX)
    lBuildBrw := .T.

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuSoluc
Monta o menu de soluções.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MenuSoluc(oContainer, cRegra)

    Local oDlg
    Local oFWMultiPanel
    Local oPanel
    Local oSay
    Local oBorder
    Local oMenu
    Local cMenuItem
    Local oMenuItem
    Local oMenuNav
    Local cID
    Local oPanelRight   := Nil
    Local oGetSolution  := Nil
    Local oPanelSol     := Nil
    Local oSolSup       := Nil
    Local oSolInf       := Nil
    Local cSolution     := ""

    oMenu := FWMenu():New()
    oMenu:Init()

    Do Case
        Case cRegra == 'ESTNEG'          
            
            oMenu:AddContent( "Kardex"      , "E", {|| oPanelSol:Show(), MontaSoluc('KARDEX'      ,oGetSolution, oSolInf) } )
            oMenu:AddContent( "Refaz Saldos", "E", {|| oPanelSol:Show(), MontaSoluc('REFAZSALDOS' ,oGetSolution, oSolInf ) } )
            oMenu:AddContent( "Inventário"  , "E", {|| oPanelSol:Show(), MontaSoluc('INVENTARO'   ,oGetSolution, oSolInf ) } )
        
        Case cRegra == 'PRDCLI'

            oMenu:AddContent( "Amarração"      , "E", {|| oPanelSol:Show(), MontaSoluc('AMARRACAO'      ,oGetSolution, oSolInf) } )
        
        Case cRegra == 'DESMON'

            oMenu:AddContent( "Desmontagem"      , "E", {|| oPanelSol:Show(), MontaSoluc('DESMONTAGEM'      ,oGetSolution, oSolInf) } )

        Case cRegra == 'RETRAB'

            oMenu:AddContent( "Produto"      , "E", {|| oPanelSol:Show(), MontaSoluc('PRODUTO'      ,oGetSolution, oSolInf) } )
            oMenu:AddContent( "Empenho"      , "E", {|| oPanelSol:Show(), MontaSoluc('EMPENHO'      ,oGetSolution, oSolInf) } )
            oMenu:AddContent( "Ordem"        , "E", {|| oPanelSol:Show(), MontaSoluc('ORDEM'        ,oGetSolution, oSolInf) } )

    EndCase

    oPanelCont := TPanelCss():New(0,60,"",oContainer,,.F.,.F.,,,((oContainer:nWidth)/2)-60,((oContainer:nHeight)/2),.T.,.F.)
    oPanelCont:SetCSS("TPanelCss { background-color : #DCDCDC; border: 0px ; border-top-left-radius: 0px; border-bottom-left-radius: 0px; }")

    oPanelMenu := TPanelCss():New(0,0,"",oContainer,,.F.,.F.,,,60,(oContainer:nHeight)/2,.T.,.F.)
    oPanelMenu:SetCSS("TPanelCss { border: 4px solid #DCDCDC; border-top-right-radius: 0px; border-bottom-right-radius: 0px;  }")

    oMenuNav := FWMenuNav():New(oPanelMenu,oMenu)
    oMenuNav:CSSItem({|oItem| FWGetCss("TSay",CSS_MTPANEL_ITEM,cValToChar((oItem:nLevel*15)+5))})
    oMenuNav:CSSItemSelected(   "   TSay { background-color: #DCDCDC; color: #000000;  qproperty-alignment: 'AlignVCenter | AlignLeft'; " +;
                                "   border: 1px solid #DCDCDC; " +;
                                "   border-top-left-radius: 5px; border-bottom-left-radius: 5px;}")

    oMenuNav:CSSSeparator({|oItem| FWGetCss("TSay",CSS_MTPANEL_ITEM_SEPARATE,cValToChar(oItem:nLevel*15))})

    oMenuNav:Activate()

    oPanelSol := TPanelCss():New(2,0,"",oPanelCont,,.F.,.F.,,,(oPanelCont:nWidth/2)-2,(oPanelCont:nHeight/2)-4,.T.,.F.)
    oPanelSol:SetCSS("TPanelCss { background-color : #DCDCDC; border: 0px; border-radius: 4px;}")

    oSolSup := TPanelCss():New(0,0,"",oPanelSol,,.F.,.F.,,,(oPanelSol:nWidth/2),(oPanelSol:nHeight/2)-14,.T.,.F.)
    oSolSup:SetCSS("TPanelCss { background-color : transparent; border: 0px; border-radius: 4px;}")

    oGetSolution := tSimpleEditor():New(0, 0, oSolSup,oSolSup:nWidth/2 , oSolSup:nHeight/2,,.T.,,,.T. )
    oGetSolution:Setcss("background-color : #E9F0F6; border-radius: 4px; border: 0px; ") 

    oSolInf := TPanelCss():New((oPanelSol:nHeight/2)-12,0,"",oPanelSol,,.F.,.F.,,,(oPanelSol:nWidth/2),12,.T.,.F.)
    oSolInf:SetCSS("TPanelCss { background-color : transparent; border: 0px; border-radius: 4px;}")

    oPanelSol:Hide()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaSoluc
Monta opções do menu de soluções para o problema do estoque negativo.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MontaSoluc(cSolOpc,oGet,oContainer)

    Local cContent  := "" 
    Local oSolInf   := Nil
    Local oBtnTDN   := Nil
    Local oBtnRot1  := Nil
    Local oBtnRot2  := Nil

    oContainer:freeChildren()

    Do Case
        Case cSolOpc == 'KARDEX'

            cContent += "<h3>Verifique se o Kardex do produto está de acordo com Saldo Atual.</h3>" 
            cContent += "<p>Execute o relatório Kardex disponível no menu SIGAEST-> Relatórios-> Legais-> Kardex Diário, preencha os parâmetros e imprima o relatório.</p>"
            cContent += "<p>Execute a consulta Saldo Atual disponível no menu SIGAEST->Atualizações-> Saldos-> Atual, localize o produto e verifique as colunas de Quantidade</p>"
            cContent += "<strong>Atenção: No Bloco K, o KARDEX pode ser usado apenas para a análise do estoque negativo.</strong>"

            
            oBtnTDN := TButton():New( 0, 0, "Link do TDN"   ,oContainer,, ((oContainer:nWidth/2)/3)-2,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnTDN:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")
            oBtnTDN:bLClicked := {|| ShellExecute("open", "https://tdn.totvs.com/display/public/PROT/Estoque+e+Custos+-+Protheus+12" ,"","",SW_SHOW) }

            oBtnRot1 := TButton():New( 0, ((oContainer:nWidth/2)/3), "Kardex"       ,oContainer,{|| MATR470() }, ((oContainer:nWidth/2)/3)-2,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnRot1:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")

            oBtnRot2 := TButton():New( 0, ((oContainer:nWidth/2)/1.5), "Saldo Atual"  ,oContainer,{|| MATA225()}, ((oContainer:nWidth/2)/3),12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnRot2:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")
    
        Case cSolOpc == 'REFAZSALDOS'

            cContent += "<h3>Verifique se há necessidade de reprocessar os saldos.</h3>"
            cContent += "<p>A rotina Refaz Saldos tem como objetivo principal calcular e fornecer "
            cContent += "a posição do estoque mediante os movimentos do Sistema (notas fiscais de entrada e "
            cContent += "saída e movimentos internos no estoque).</p><p>Para cada item do estoque, o Sistema recalcula, "
            cContent += "em quantidade e valor, os saldos em estoque e os saldos iniciais.</p>"
            cContent += "<p>A rotina Refaz Saldos está disponível no menu SIGAEST->Miscelânea-> Processamentos-> Refaz Saldos </p>"

            oBtnTDN := TButton():New( 0, 0, "Link do TDN"   ,oContainer,, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnTDN:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")
            oBtnTDN:bLClicked := {|| ShellExecute("open", "https://tdn.totvs.com/display/public/PROT/Estoque+e+Custos+-+Protheus+12" ,"","",SW_SHOW) }

            oBtnRot1 := TButton():New( 0, ((oContainer:nWidth/2)/2)+1, "Refaz Saldos"       ,oContainer,{|| MATA300() }, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnRot1:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")

            
        Case cSolOpc == 'INVENTARO'

            cContent += "<h3>Verifique se há necessidade de inventariar os itens.</h3>"
            cContent += "<p>Uma forma adequada de corrigir divergências nos saldos em estoque é por meio do inventário. "
            cContent += "Desta forma é possível fazer a recontagem física de materiais, confrontando os resultados com os saldos fornecidos pelo Sistema.</p>"
            cContent += "<p>A rotina Inventário está disponível no menu SIGAEST->Atualizações-> Movimentações-> Internas-> Inventário </p>"

            oBtnTDN := TButton():New( 0, 0, "Link do TDN"   ,oContainer,, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnTDN:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")
            oBtnTDN:bLClicked := {|| ShellExecute("open", "https://tdn.totvs.com/display/public/PROT/Estoque+e+Custos+-+Protheus+12" ,"","",SW_SHOW) }

            oBtnRot1 := TButton():New( 0, ((oContainer:nWidth/2)/2)+1, "Inventário"       ,oContainer,{|| MATA270() }, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnRot1:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")
        
        Case cSolOpc == 'AMARRACAO'
            
            cContent += "<h3>Verifique a amarração dos itens produzidos com seus respectivos terceiros.</h3>"
            cContent += "<p>Após a produção, quando de terceiros, é possível discriminar a quantidade dos itens produzidos que pertencem a um ou mais terceiros.</p>"
            cContent += "<p>A rotina Produções de Terceiros está disponível no menu SIGAEST ->Atualizações ->Movimentações ->Internas ->Produção ->Produções de Terceiros </p>"

            oBtnTDN := TButton():New( 0, 0, "Link do TDN"   ,oContainer,, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnTDN:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")
            oBtnTDN:bLClicked := {|| ShellExecute("open", "http://tdn.totvs.com/display/PROT/Registro+K200%3A+Estoque+Escriturado" ,"","",SW_SHOW) }

            oBtnRot1 := TButton():New( 0, ((oContainer:nWidth/2)/2)+1, "Produções de Terceiros"       ,oContainer,{|| MATA037() }, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnRot1:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")
        
        Case cSolOpc == 'DESMONTAGEM'
            cContent += "<h3>Verifique se as desmontagens foram feitas corretamente pelo processo padrão.</h3>"
            cContent += "<p>A rotina de desmontagem gera registros de movimentação no estoque (tabela SD3) identificados como processo de desmontagem. O item origem é do tipo RE7 e o item (ou itens) destino, do tipo DE7. </p>"
            cContent += "<p>A rotina Desmontagem - MATA242 está disponível no menu SIGAEST ->Atualizações ->Movimentações ->Internas ->Desmontagem </p>"

            oBtnTDN := TButton():New( 0, 0, "Link do TDN"   ,oContainer,, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnTDN:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")
            oBtnTDN:bLClicked := {|| ShellExecute("open", "https://tdn.totvs.com/display/public/PROT/Estoque+e+Custos+-+Protheus+12" ,"","",SW_SHOW) }

            oBtnRot1 := TButton():New( 0, ((oContainer:nWidth/2)/2)+1, "Desmontagem"       ,oContainer,{|| MATA242() }, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnRot1:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")

        Case cSolOpc == 'PRODUTO'
            cContent += "<h3>Verifique o preenchimento do campo Prd. Origem do cadastro do produto que será retrabalhado.</h3>"
            cContent += "<p>O produto que será retrabalhado deverá ter o campo Prd. Origem preenchido na seção Complemento PCP do cadastro de Produtos para identificar que o saldo desse produto passará pelo processo de retrabalho e retornará ao produto origem no final do processo.</p>"
            cContent += "<p>A rotina de cadastro de Produtos - MATA010 está disponível em SIGAEST -> Atualizações -> Cadastros -> Produto -> Produtos </p>"

            
            //oContainer:SetCSS("TPanelCss { background-color : #E9F0F6; border: 0px; border-radius: 4px;}")

            oBtnTDN := TButton():New( 0, 0, "Link do TDN"   ,oContainer,, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnTDN:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")
            oBtnTDN:bLClicked := {|| ShellExecute("open", "http://tdn.totvs.com/pages/viewpage.action?pageId=259560367" ,"","",SW_SHOW) }

            
            oBtnRot1 := TButton():New( 0, ((oContainer:nWidth/2)/2)+1, "Produtos"       ,oContainer,{|| MATA010() }, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. )
            oBtnRot1:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")

        Case cSolOpc == 'EMPENHO'
            cContent += "<h3>Verifique se o produto que será retrabalhado foi empenhado na ordem de produção do produto origem.</h3>"
            cContent += "<p>Quando o saldo do produto origem é transferido ao produto a ser retrabalhado, o mesmo deve ser empenhado manualmente na ordem de retrabalho do produto origem para que seja consumido no processo.</p>"
            cContent += "<p>A rotina de Empenhos - MATA381 está disponível em SIGAPCP -> Atualizações -> Movimentações -> Produção -> Empenho Múltiplo </p>"

            //oContainer:SetCSS("TPanelCss { background-color : #E9F0F6; border: 0px; border-radius: 4px;}")

            oBtnTDN := TButton():New( 0, 0, "Link do TDN"   ,oContainer,, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnTDN:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")
            oBtnTDN:bLClicked := {|| ShellExecute("open", "http://tdn.totvs.com/pages/viewpage.action?pageId=259560367" ,"","",SW_SHOW) }
            
            oBtnRot1 := TButton():New( 0, ((oContainer:nWidth/2)/2)+1, "Empenhos"       ,oContainer,{|| MATA381() }, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. )
            oBtnRot1:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")

        Case cSolOpc == 'ORDEM'
            cContent += "<h3>Verifique o preenchimento do campo Tp. Produção no cadastro da ordem de produção.</h3>"
            cContent += "<p>O preenchimento do campo Tp. Produção com o valor igual a Retrabalho é específico para quando há produção ou consumo de um produto a ser retrabalhado, e somente nesses casos deve ser utilizado.</p>"
            cContent += "<p>A rotina de Ordens de Produção - MATA650 está disponível em SIGAPCP -> Atualizações -> Movimentações -> Produção -> Ordens de Produção </p>"

            //oContainer:SetCSS("TPanelCss { background-color : #E9F0F6; border: 0px; border-radius: 4px;}")

            oBtnTDN := TButton():New( 0, 0, "Link do TDN"   ,oContainer,, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. ) 
            oBtnTDN:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")
            oBtnTDN:bLClicked := {|| ShellExecute("open", "http://tdn.totvs.com/pages/viewpage.action?pageId=259560367" ,"","",SW_SHOW) }
            
            oBtnRot1 := TButton():New( 0, ((oContainer:nWidth/2)/2)+1, "Ordens de Produção"       ,oContainer,{|| MATA650() }, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. )
            oBtnRot1:SetCSS("QPushButton {background-color : #E9F0F6; text-decoration: underline; color: blue; border: 0px solid #DCDCDC; border-radius: 4px;}")

    EndCase

    oGet:Load(cContent)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ParamSetup
Monta a tela de parâmetros para envio
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ParamSetup(oWaMain,oBrwRef, cRegra)

    Local oPanel    := oWaMain:GetPanel( "WDGT01" )
    Local oLogo         := Nil
    Local oPanelFull    := Nil
    Local oPanelLogo    := Nil
    Local oPanelTit     := Nil
    Local oTextTit      := Nil
    Local oPanelLeft    := Nil
    Local oPanelRight   := Nil
    Local oPanelParam   := Nil
    Local oPanelDesc    := Nil
    Local oGetDesc      := Nil
    Local oGetAtu       := Nil
    Local oGetOk        := Nil
    Local oGetJust      := Nil
    Local oFont3        := TFont():New("Arial",,-11,,.T.,,,,,,.F.)
    Local aBrowse       := {}
    Local nParamAtu     := 1
    Local aList         := {}
    Local aFields       := {}
    Local oBrowse       := Nil
    Local cAliasBrw     := ""
    Local nX            := 1 
    Local cContAtu      := Space(10)
    Local cContOk       := Space(10)
    Local aSize         := {}
    Local oWorkArea     := Nil
    Local oWDGT01       := Nil
    Local oTopBar       := Nil
    Local aSizeWg1      := {}
    Local oFont         := Nil
    Local oFont2        := Nil
    Local oSayTitle     := Nil
    Local oSayTitle2    := Nil

    oPanel:freeChildren()

    aSize     := FWGetDialogSize( oPanel )

    oWorkArea := FWUIWorkArea():New( oPanel )


    oWorkArea:CreateHorizontalBox( "LINE01X", 100, .T. )
    oWorkArea:SetBoxCols( "LINE01X", { "WDGT01X" } )

    oWorkArea:CreateHorizontalBox( "LINE01", (aSize[3]-130), .T. )
    oWorkArea:SetBoxCols( "LINE01", { "WDGT01" } )

    oWorkArea:Activate()

    oWDGT01X := oWorkArea:GetPanel("WDGT01X")
    aSizeWg1 := FWGetDialogSize( oWDGT01X )

    oTopBar := TPanel():New( 0 , 0 ,,oWDGT01X,,,,,, aSizeWg1[4]-2.5, 40.4) 
    oTopBar:SetCss( FWGetCSS( GetClassName(oTopBar), CSS_FORMBAR_TOP_BG ) ) 

    oFont := TFont():New("Arial",,-20,,.T.,,,,,,.F.)	
    oFont2 := TFont():New("Arial",,-10,,.T.,,,,,,.F.)


    oSayTitle:=     TSay():New(10,10,{|| "Configurações Para Envio" },oTopBar,,oFont,,,,.T.,,,300,20,,,,,,.T.)
    oSayTitle2:=    TSay():New(25,10,{|| "Parametrização ideal para o envio do bloco K" },oTopBar,,oFont2,,,,.T.,,,200,20,,,,,,.T.)

    oSayTitle:SetCss("background-color : transparent; color: #0B9BBF}")
    oSayTitle2:SetCss("background-color : transparent; color: #0B9BBF}")

    
    oWDGT01 := oWorkArea:GetPanel("WDGT01")

    //oPanelFull := TPanelCss():New(0,0,"",oWDGT01,,.F.,.F.,,,oWDGT01:nWidth/2,oWDGT01:nHeight/2,.T.,.F.)
    //oPanelFull:SetCSS("TPanelCss { background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; }")
    
    //--Divisão Esquerda-Direita

    oPanelLeft := TPanelCss():New(0,0,"",oWDGT01,,.F.,.F.,,,oWDGT01:nWidth/5,oWDGT01:nHeight/2,.T.,.F.)
    oPanelLeft:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
    oPanelLeft:Align := CONTROL_ALIGN_LEFT
    oPanelLeft:ReadClientCoors(.T.,.T.)

    oPanelRight := TPanelCss():New(0,(oWDGT01:nWidth/5),"",oWDGT01,,.F.,.F.,,,oWDGT01:nWidth/4,oWDGT01:nHeight/2,.T.,.F.)
    oPanelRight:SetCSS("TPanelCss { background-color : transparent; border: 0px;  }") 
    oPanelRight:Align := CONTROL_ALIGN_ALLCLIENT
    oPanelRight:ReadClientCoors(.T.,.T.)
    
    //--Parâmetros
    oPanelParam := TPanelCss():New(2,2,"",oPanelLeft,,.F.,.F.,,,(oPanelLeft:nWidth/2)-4,(oPanelLeft:nHeight/2)-4 ,.T.,.F.)
    oPanelParam:SetCSS("TPanelCss { background-color : #FFFFFF; border: 1px solid #DCDCDC;  border-radius: 4px;}") 
  
    oSayTitle:= TSay():New(2,2,{|| ""},oPanelParam,,oFont3,,,,.T.,,,(oPanelParam:nWidth/2)-4,15,,,,,,.T.)
    oSayTitle:SetCss("background-color : #E9F0F6; border: 1px #DCDCDC; border-top-left-radius: 4px; border-top-right-radius: 4px;")

    oSayTitle2:= TSay():New(6,6,{|| "Parâmetros"},oPanelParam,,oFont3,,,,.T.,,,100,20,,,,,,.T.)
    oSayTitle2:SetCss("background-color : transparent; color : #757776}")

    oPanelBrw := TPanelCss():New(20,4,"",oPanelParam,,.F.,.F.,,,(oPanelParam:nWidth/2)-8,(oPanelParam:nHeight/2)-22 ,.T.,.F.)
    oPanelBrw:SetCSS("TPanelCss { background-color : #FCFAF9; border: 1px solid #DCDCDC;  border-radius: 4px;}") 



    //--Descrição

    oPanelDesc := TPanelCss():New(2,2,"",oPanelRight,,.F.,.F.,,,(oPanelRight:nWidth/2)-4,(oPanelRight:nHeight/4)-24 ,.T.,.F.)
    oPanelDesc:SetCSS("TPanelCss { background-color : #FFFFFF; border: 1px solid #DCDCDC;  border-radius: 4px;}") 

    oSayDesc:= TSay():New(2,2,{|| ""},oPanelDesc,,oFont3,,,,.T.,,,(oPanelDesc:nWidth/2)-4,15,,,,,,.T.)
    oSayDesc:SetCss("background-color : #E9F0F6; border: 1px #DCDCDC; border-top-left-radius: 4px; border-top-right-radius: 4px;")

    oDescTitle:= TSay():New(6,6,{|| "Descrição"},oPanelDesc,,oFont3,,,,.T.,,,100,20,,,,,,.T.)
    oDescTitle:SetCss("background-color : transparent; color : #757776}")

    oGroup1 := TPanelCss():New(20,2,"",oPanelDesc,,.F.,.F.,,,(oPanelDesc:nWidth/2)-4,(oPanelDesc:nHeight/2)-22,.T.,.F.)
    oGroup1:SetCSS("TPanelCss { background-color : transparent; border: 0px solid #DCDCDC;  border-radius: 4px;}") 

    oGetDesc := tSimpleEditor():New(0, 0, oGroup1,(oGroup1:nWidth/2) , (oGroup1:nHeight/2),,.T.,,,.T. )
    oGetDesc:Setcss("QTextEdit {background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC;} ") 

    //--Conteúdo
    
    oPanelCont := TPanelCss():New((oPanelRight:nHeight/4)-20,2,"",oPanelRight,,.F.,.F.,,,(oPanelRight:nWidth/2)-4,42 ,.T.,.F.)
    oPanelCont:SetCSS("TPanelCss { background-color : transparent; border: 1px solid #DCDCDC;  border-radius: 4px;}") 

    oContAtu := tSay():New(15,10,{|| "Conteúdo Atual:" },oPanelCont,,,,,,.T.,,,80,10)
    oContAtu:SetCss("QLabel {color : #757776; font-size: 12px; font-weight: bold;}")

    oGetAtu := TGet():New(13, 100, { |u| If( PCount() == 0, cContAtu, cContAtu := u ) },oPanelCont,060,010,"@!",,0,16777215,,.F.,,.T.,,.F.,{||.F.}/*When*/,.F.,.F.,,,.F. ,,"cContAtu",,,,.T. )

    cContAtu:= ".T."

    //--Detalhe

    oPanelJust := TPanelCss():New((oPanelRight:nHeight/4)+24,2,"",oPanelRight,,.F.,.F.,,,(oPanelRight:nWidth/2)-4,(oPanelRight:nHeight/4)-26 ,.T.,.F.)
    oPanelJust:SetCSS("TPanelCss { background-color : #FFFFFF; border: 1px solid #DCDCDC;  border-radius: 4px;}") 

    oSayJust:= TSay():New(2,2,{|| ""},oPanelJust,,oFont3,,,,.T.,,,(oPanelJust:nWidth/2)-4,15,,,,,,.T.)
    oSayJust:SetCss("background-color : #E9F0F6; border: 1px #DCDCDC; border-top-left-radius: 4px; border-top-right-radius: 4px;")

    oJustTitle:= TSay():New(6,6,{|| "Detalhe"},oPanelJust,,oFont3,,,,.T.,,,100,20,,,,,,.T.)
    oJustTitle:SetCss("background-color : transparent; color : #757776}")

    oGroup2 := TPanelCss():New(20,2,"",oPanelJust,,.F.,.F.,,,(oPanelJust:nWidth/2)-4,(oPanelJust:nHeight/2)-22,.T.,.F.)
    oGroup2:SetCSS("TPanelCss { background-color : transparent; border: 0px solid #DCDCDC;  border-radius: 4px;}") 

    oGetJust := tSimpleEditor():New(0, 0, oGroup2,(oGroup2:nWidth/2) , (oGroup2:nHeight/2),,.T.,,,.T. )
    oGetJust:Setcss("QTextEdit {background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC;} ") 
    

    oBrwRef := FWMBrowse():New()

    Aadd(aFields,{'Parâmetros','VAR' ,'C',12  ,Nil ,'@!'}) 

    oBrwRef:SetAlias(cAliParam)
    oBrwRef:Setfields(aFields)
    oBrwRef:DisableReport()
    oBrwRef:DisableDetails()
    oBrwRef:DisableFilter()

    oBrwRef:AddLegend('STATS == "0"','GREEN',"Ok")
    oBrwRef:SetChange({|| SetParInfo(oGetDesc,@cContAtu,oGetAtu, oGetJust) })
    oBrwRef:Activate(oPanelBrw)

    lBuildBrw := .T.

Return

Static Function SetParInfo(oDesc, cContAtu,oContAtu, oJust)

    oDesc:Load('<p><font size=4>'+(cAliParam)->DESCR +'</font></p>')
    oJust:Load('<p><font size=4>'+(cAliParam)->JUSTI +'</font></p>')

    cContAtu := (cAliParam)->CONTENT
    oContAtu:CtrlRefresh()

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcParams
Cria o alias temporário das OPs de terceiros e inicia thread
que processa as OPs com itens que precisam de amarração.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ProcParams(cAliParam)
    Local cArqTmp   := ""
    Local aCampos   := {}

    PutGlbValue(GLB_PARAMS, "READY")

    Aadd(aCampos,   {"STATS","C",1,0}       )
    Aadd(aCampos,   {"VAR","C",12,0}        )
    Aadd(aCampos,   {"CONTENT","C",12,0}    )
    Aadd(aCampos,   {"DESCR","C",160,0}    )
    Aadd(aCampos,   {"JUSTI","M",500,0}    )

    cArqTmp := CriaTrab(,.F.)
    FWDbCreate(cArqTmp,aCampos,'TOPCONN')
    cAliParam := cArqTmp
    DbUseArea(.T.,'TOPCONN',cArqTmp,cAliParam,.T.)

    StartJob("C300JobPar",GetEnvServer(),.F.,cEmpAnt,  cFilAnt  ,cAliParam,GLB_PARAMS)

Return .T.

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcEstNeg
Cria o alias temporário dos produtos do bloco K200 e inicia thread
que processa o itens com estoque negativo.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ProcEstNeg(cAliEstNeg,dDataDe,dDataAte)
    Local cArqTmp   := ""
    Local aCampos   := {}
    Local aTam      := {}


    PutGlbValue(GLB_ESTNEG, "READY")

    Aadd(aCampos,{"STATS","C",1,0})

    aTam := TamSX3("B9_COD")
    Aadd(aCampos,{"B9_COD",aTam[3],aTam[1],aTam[2]})

    aTam := TamSX3("B9_LOCAL")
    Aadd(aCampos,{"B9_LOCAL",aTam[3],aTam[1],aTam[2]})

    aTam := TamSX3("B9_QINI")
    Aadd(aCampos,{"B9_QINI",aTam[3],aTam[1],aTam[2]})

    cArqTmp := CriaTrab(,.F.)
    FWDbCreate(cArqTmp,aCampos,'TOPCONN')
    cAliEstNeg := cArqTmp
    DbUseArea(.T.,'TOPCONN',cArqTmp,cAliEstNeg,.T.)

    StartJob("C300JobNeg",GetEnvServer(),.F.,cEmpAnt,  cFilAnt ,cAliEstNeg,dDataDe,dDataAte,GLB_ESTNEG)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcPrdCli
Cria o alias temporário das OPs de terceiros e inicia thread
que processa as OPs com itens que precisam de amarração.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ProcPrdCli(cAliPrdCli,dDataDe,dDataAte)
    Local cArqTmp   := ""
    Local aCampos   := {}
    Local aTam      := {}

    PutGlbValue(GLB_PRDCLI, "READY")

    Aadd(aCampos,{"STATS","C",1,0})

    aTam := TamSX3("D3_OP")
    Aadd(aCampos,{"D3_OP",aTam[3],aTam[1],aTam[2]})


    cArqTmp := CriaTrab(,.F.)
    FWDbCreate(cArqTmp,aCampos,'TOPCONN')
    cAliPrdCli := cArqTmp
    DbUseArea(.T.,'TOPCONN',cArqTmp,cAliPrdCli,.T.)

    StartJob("C300JobPrC",GetEnvServer(),.F.,cEmpAnt,  cFilAnt  ,cAliPrdCli,dDataDe,dDataAte,GLB_PRDCLI)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcPrdCli
Cria o alias temporário das OPs de terceiros e inicia thread
que processa as OPs com itens que precisam de amarração.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ProcDesmon(cAliDesmon,dDataDe,dDataAte)
    Local cArqTmp   := ""
    Local aCampos   := {}
    Local aTam      := {}

    PutGlbValue(GLB_DESMON, "READY")

    Aadd(aCampos,{"STATS","C",1,0})

    aTam := TamSX3("D3_DOC")
    Aadd(aCampos,{"D3_DOC",aTam[3],aTam[1],aTam[2]})

    aTam := TamSX3("D3_COD")
    Aadd(aCampos,{"D3_COD",aTam[3],aTam[1],aTam[2]})

    aTam := TamSX3("D3_NUMSEQ")
    Aadd(aCampos,{"D3_NUMSEQ",aTam[3],aTam[1],aTam[2]})


    cArqTmp := CriaTrab(,.F.)
    FWDbCreate(cArqTmp,aCampos,'TOPCONN')
    cAliDesmon := cArqTmp
    DbUseArea(.T.,'TOPCONN',cArqTmp,cAliDesmon,.T.)

    StartJob("C300JobDes",GetEnvServer(),.F.,cEmpAnt,  cFilAnt  ,cAliDesmon,dDataDe,dDataAte,GLB_DESMON)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcRetrab
Cria o alias temporário das OPs de retrabalho inconsistentes e inicia
thread que faz o processamento..
    
@author Renan Roeder
@since  Jan 28, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ProcRetrab(cAliRetrab,dDataDe,dDataAte)
    Local cArqTmp   := ""
    Local aCampos   := {}
    Local aTam      := {}

    PutGlbValue(GLB_RETRAB, "READY")

    aTam := TamSX3("D3_OP")
    Aadd(aCampos,{"D3_OP",aTam[3],aTam[1],aTam[2]})

    aTam := TamSX3("D3_COD")
    Aadd(aCampos,{"D3_COD",aTam[3],aTam[1],aTam[2]})

    cArqTmp := CriaTrab(,.F.)
    FWDbCreate(cArqTmp,aCampos,'TOPCONN')
    cAliRetrab := cArqTmp
    DbUseArea(.T.,'TOPCONN',cArqTmp,cAliRetrab,.T.)

    StartJob("C300JobRet",GetEnvServer(),.F.,cEmpAnt,  cFilAnt  ,cAliRetrab,dDataDe,dDataAte,GLB_RETRAB)

Return

//-------------------------------------------------------------------

/*/{Protheus.doc} C300JobNeg
Thread que realiza o cálculo do estoque para verificar se o saldo 
do produto está negativo.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function C300JobPar(cEmpx,  cFilx  ,cAliParam,cGlbName)
    Local cThrdStat     := "ZERO"
    Local nX            := 1
    Local aParamList    := {}
    Local cContent      := ""

    RpcSetType(3)
    RpcSetEnv( cEmpX,cFilX)

    DbUseArea(.T.,'TOPCONN',cAliParam,cAliParam,.T.)

    aParamList := GetParList()

    For nX:=1 To Len(aParamList)

        cContent := cValToChar(SuperGetMv(AllTrim(aParamList[nX][1]),.F.))

        RecLock(cAliParam,.T.)
        (cAliParam)->STATS      := '0'
        (cAliParam)->VAR        := aParamList[nX][1]
        (cAliParam)->CONTENT    := If(Empty(cContent),"Vazio",cContent)
        (cAliParam)->DESCR      := aParamList[nX][2]
        (cAliParam)->JUSTI      := aParamList[nX][3]
        (cAliParam)->(MsUnLock())

    Next nX

    (cAliParam)->(dbCloseArea())

    PutGlbValue(cGlbName, cThrdStat)

    RpcClearEnv()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} C300JobNeg
Thread que realiza o cálculo do estoque para verificar se o saldo 
do produto está negativo.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function C300JobNeg(cEmpx,  cFilx ,cAliEstNeg,dDataDe,dDataAte,cGlbName)
    Local nSaldo        := 0
    Local cLocProc      := ""
    Local nlSldTesN3	:= 0
    Local lSubtrai		:= .F.
    Local cThrdStat     := "FULL"
    Local cAliasTRB     := ""

    RpcSetType(3)
    RpcSetEnv( cEmpX,cFilX)

    //--------------------------------------------------------------------------
    //Variáves necessárias para a chamada da lista do bloco K200 no MATXSPED.PRW

    Private cTipo00		:= If(SuperGetMv("MV_BLKTP00",.F.,"'ME'")== " ","'ME'", SuperGetMv("MV_BLKTP00",.F.,"'ME'")) // 00: Mercadoria Revenda
    Private cTipo01		:= If(SuperGetMv("MV_BLKTP01",.F.,"'MP'")== " ","'MP'", SuperGetMv("MV_BLKTP01",.F.,"'MP'")) // 01: Materia-Prima
    Private cTipo02		:= If(SuperGetMv("MV_BLKTP02",.F.,"'EM'")== " ","'EM'", SuperGetMv("MV_BLKTP02",.F.,"'EM'")) // 02: Embalagem
    Private cTipo03		:= If(SuperGetMv("MV_BLKTP03",.F.,"'PP'")== " ","'PP'", SuperGetMv("MV_BLKTP03",.F.,"'PP'")) // 03: Produto em Processo
    Private cTipo04		:= If(SuperGetMv("MV_BLKTP04",.F.,"'PA'")== " ","'PA'", SuperGetMv("MV_BLKTP04",.F.,"'PA'")) // 04: Produto Acabado
    Private cTipo05		:= If(SuperGetMv("MV_BLKTP05",.F.,"'SP'")== " ","'SP'", SuperGetMv("MV_BLKTP05",.F.,"'SP'")) // 05: SubProduto
    Private cTipo06		:= If(SuperGetMv("MV_BLKTP06",.F.,"'PI'")== " ","'PI'", SuperGetMv("MV_BLKTP06",.F.,"'PI'")) // 06: Produto Intermediario
    Private cTipo10		:= If(SuperGetMv("MV_BLKTP10",.F.,"'OI'")== " ","'OI'", SuperGetMv("MV_BLKTP10",.F.,"'OI'")) // 10: Outros Insumos
    Private lNegEst		:= SuperGetMv("MV_NEGESTR",.F.,.F.)
    Private nRegsto		:= 0	// Quantidade de Registros Gerados
    Private lCpoBZTP	:= SBZ->(ColumnPos("BZ_TIPO")) > 0
    Private cVersao		:= VerBlocoK(Stod("01/01/2018"))

    //---------------------------------------------------------------------------

    cLocProc        := GetMvNNR('MV_LOCPROC','99')
    nlSldTesN3	    := SuperGetMV("MV_SDTESN3",.F.,0) 
    lSubtrai		:= nlSldTesN3 == 1  

    GetListPrd(@cAliasTRB,dDataDe,dDataAte)

    DbUseArea(.T.,'TOPCONN',cAliEstNeg,cAliEstNeg,.T.)

    (cAliasTRB)->(DbGoTop())

    While !(cAliasTRB)->(Eof())

        If (cAliasTRB)->STATS == "S" .Or. (cAliasTRB)->B9_LOCAL == cLocProc
            nSaldo += CalcEst((cAliasTRB)->B9_COD,(cAliasTRB)->B9_LOCAL,dDataAte+1,Nil,lSubtrai)[1]
        ElseIf (cAliasTRB)->STATS == "N"
            nSaldo += (cAliasTRB)->B9_QINI
        EndIf
        
        If nSaldo < 0
        
            PutGlbValue(cGlbName, 'ONE')

            RecLock(cAliEstNeg,.T.)
            (cAliEstNeg)->STATS		:= (cAliasTRB)->STATS
            (cAliEstNeg)->B9_COD	:= (cAliasTRB)->B9_COD
            (cAliEstNeg)->B9_LOCAL	:= (cAliasTRB)->B9_LOCAL
            (cAliEstNeg)->B9_QINI	:= nSaldo
            (cAliEstNeg)->(MsUnLock())
            Sleep(1500)    
        Endif

        (cAliasTRB)->(DbSkip())
        nSaldo := 0
        
    EndDo

    (cAliEstNeg)->(DbGoTop())
    If (cAliEstNeg)->(EoF())
        cThrdStat := "ZERO"
    Else 
        cThrdStat  := "FULL"
    Endif

    (cAliasTRB)->(dbCloseArea())
    TcDelFile(cAliasTRB)

    (cAliEstNeg)->(dbCloseArea())

    PutGlbValue(cGlbName, cThrdStat)

    RpcClearEnv()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C300JobPrC
Thread que realiza a busca pelas OPs de terceiros que não tem saldo
distribuido.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function C300JobPrC(cEmpX,  cFilX  ,cAliPrdCli,dDataDe,dDataAte,cGlbName)
    Local cThrdStat     := "FULL"
    Local cAliasTRB     := GetNextAlias()
    Local cQuery        := ""
    Local lD3kLote

    RpcSetType(3)
    RpcSetEnv( cEmpX,cFilX)

    DbSelectArea("D3K")
    lD3kLote := FieldPos("D3K_LOTE") > 0
    
    cQuery+="SELECT "
    cQuery+=    "SC2.C2_STTERCE, "
    cQuery+=    "SD3.D3_OP "
    cQuery+=	"FROM   "+RetSqlName("SD3")+" SD3 "
    cQuery+=       "LEFT JOIN "+RetSqlName("SC2")+" SC2 " "
    cQuery+=              "ON SD3.D3_OP = SC2.C2_NUM " + MatiConcat()+" SC2.C2_ITEM " + MatiConcat()+" SC2.C2_SEQUEN " + MatiConcat()+" SC2.C2_ITEMGRD "
    cQuery+=                 "AND SC2.C2_FILIAL = '"+xFilial('SC2')+"' "
    cQuery+=                 "AND SC2.D_E_L_E_T_ = ' ' "
    cQuery+=       "LEFT JOIN "+RetSqlName("D3K")+" D3K " "
    cQuery+=              "ON D3K_FILIAL = '"+xFilial('D3K')+"' "
    cQuery+=                 "AND D3K.D3K_COD = SD3.D3_COD "
    cQuery+=                 "AND D3K.D3K_NUMSEQ = SD3.D3_NUMSEQ "
    cQuery+=                 "AND D3K.D3K_OP = SD3.D3_OP "
    If lD3kLote
        cQuery+=             "AND D3K.D3K_LOTE = SD3.D3_LOTECTL "
    Endif
    cQuery+=				 "AND D3K.D_E_L_E_T_ = ' ' "
    cQuery+="WHERE  SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
    cQuery+=       "AND SD3.D_E_L_E_T_ = ' ' "
    cQuery+=       "AND SD3.D3_ESTORNO = ' ' "
    cQuery+=       "AND SD3.D3_OP <> ' ' "
    cQuery+=	   "AND SD3.D3_CF IN ( 'RE5','RE9','RE6','RE3','RE2','RE0','RE1','PR0','PR1') "
    cQuery+=       "AND SD3.D_E_L_E_T_ = ' ' "
    cQuery+=	   "AND SC2.C2_OPTERCE = '1' "
    cQuery+=	   "AND (SC2.C2_EMISSAO >='" + DToS(dDataDe) + "' AND SC2.C2_EMISSAO <='"+DToS(dDataAte)+"') "
    cQuery+=       "AND SC2.C2_STTERCE <> '1' "
    cQuery+="GROUP BY SD3.D3_COD, SD3.D3_OP,SD3.D3_NUMSEQ, SD3.D3_QUANT, SC2.C2_STTERCE"

    cQuery := ChangeQuery(cQuery)

    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTRB,.T.,.T.)
    DbUseArea(.T.,'TOPCONN',cAliPrdCli,cAliPrdCli,.T.)

    (cAliasTRB)->(DbGoTop())

    While !(cAliasTRB)->(Eof())
        
        PutGlbValue(cGlbName, 'ONE')

        RecLock(cAliPrdCli,.T.)
        (cAliPrdCli)->STATS		:= (cAliasTRB)->C2_STTERCE
        (cAliPrdCli)->D3_OP		:= (cAliasTRB)->D3_OP

        (cAliPrdCli)->(MsUnLock())    

        (cAliasTRB)->(DbSkip())
    EndDo

    (cAliPrdCli)->(DbGoTop())
    If (cAliPrdCli)->(EoF())
        cThrdStat := "ZERO"
    Else 
        cThrdStat  := "FULL"
    Endif

    (cAliasTRB)->(dbCloseArea())
    (cAliPrdCli)->(dbCloseArea())

    PutGlbValue(cGlbName, cThrdStat)

    RpcClearEnv()

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} C300JobDes
Thread que realiza a busca das desmontagens incorretas
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function C300JobDes(cEmpX,  cFilX  ,cAliDesmon,dDataDe,dDataAte,cGlbName)
    Local cThrdStat     := "FULL"
    Local cAliasTmp     := ""
    Local cQuery        := ""
    Local cDadosProd    := ""
    Local lCpoBZTP	    := .F.
    Local cTipo00		:= ""
    Local cTipo01		:= ""
    Local cTipo02		:= ""
    Local cTipo03		:= ""
    Local cTipo04		:= ""
    Local cTipo05		:= ""
    Local cTipo06		:= ""
    Local cTipo10		:= ""
    Local aDesmont      := {}
    Local nX            := 1

    RpcSetType(3)
    RpcSetEnv( cEmpX, cFilX )

    cAliasTmp   := GetNextAlias()
    cDadosProd  := SuperGetMV("MV_ARQPROD",.F.,"SB1")
    lCpoBZTP	:= SBZ->(ColumnPos("BZ_TIPO")) > 0

    cTipo00		:= If(SuperGetMv("MV_BLKTP00",.F.,"'ME'")== " ","'ME'", SuperGetMv("MV_BLKTP00",.F.,"'ME'")) // 00: Mercadoria Revenda
    cTipo01		:= If(SuperGetMv("MV_BLKTP01",.F.,"'MP'")== " ","'MP'", SuperGetMv("MV_BLKTP01",.F.,"'MP'")) // 01: Materia-Prima
    cTipo02		:= If(SuperGetMv("MV_BLKTP02",.F.,"'EM'")== " ","'EM'", SuperGetMv("MV_BLKTP02",.F.,"'EM'")) // 02: Embalagem
    cTipo03		:= If(SuperGetMv("MV_BLKTP03",.F.,"'PP'")== " ","'PP'", SuperGetMv("MV_BLKTP03",.F.,"'PP'")) // 03: Produto em Processo
    cTipo04		:= If(SuperGetMv("MV_BLKTP04",.F.,"'PA'")== " ","'PA'", SuperGetMv("MV_BLKTP04",.F.,"'PA'")) // 04: Produto Acabado
    cTipo05		:= If(SuperGetMv("MV_BLKTP05",.F.,"'SP'")== " ","'SP'", SuperGetMv("MV_BLKTP05",.F.,"'SP'")) // 05: SubProduto
    cTipo06		:= If(SuperGetMv("MV_BLKTP06",.F.,"'PI'")== " ","'PI'", SuperGetMv("MV_BLKTP06",.F.,"'PI'")) // 06: Produto Intermediario
    cTipo10		:= If(SuperGetMv("MV_BLKTP10",.F.,"'OI'")== " ","'OI'", SuperGetMv("MV_BLKTP10",.F.,"'OI'")) // 10: Outros Insumos

    cQuery := "SELECT SD3.D3_FILIAL, SD3.D3_COD, SD3.D3_EMISSAO, SD3.D3_NUMSEQ, SD3.D3_DOC, SD3.D3_CF, Sum(SD3.D3_QUANT) D3_QUANT "
    cQuery += "FROM "+RetSqlName("SD3")+" SD3 "
    cQuery += "JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial('SB1')+"' "
    cQuery += "		AND SB1.B1_COD = SD3.D3_COD AND SB1.B1_COD NOT LIKE 'MOD%' "
    cQuery += "		AND SB1.B1_CCCUSTO = ' ' "
    cQuery += "		AND SB1.D_E_L_E_T_ = ' ' "
    If cDadosProd == 'SBZ' .And. lCpoBZTP
        cQuery += "LEFT JOIN "+RetSqlName("SBZ")+" SBZ ON SBZ.BZ_FILIAL = '"+xFilial('SBZ')+"' AND SBZ.BZ_COD = SB1.B1_COD AND SBZ.D_E_L_E_T_ = ' ' "
    EndIf
    cQuery += "WHERE SD3.D3_FILIAL = '"+xFilial('SD3')+"' "
    cQuery += "		AND SD3.D3_ESTORNO = ' ' AND SD3.D3_CF IN ('DE7','RE7') "
    cQuery += "		AND SD3.D3_EMISSAO BETWEEN '"+DtoS(dDataDe)+"' AND '"+DtoS(dDataAte)+"' AND	SD3.D_E_L_E_T_ = ' ' "
    If cDadosProd == 'SBZ'.And. lCpoBZTP
        cQuery += "		AND "+MatIsNull()+"(SBZ.BZ_TIPO,SB1.B1_TIPO) "
    Else
        cQuery += "		AND SB1.B1_TIPO "
    EndIf
    cQuery += " IN ("+cTipo00+","+cTipo01+","+cTipo02+","+cTipo03+","+cTipo04+","+cTipo05+","+cTipo10+") "
    cQuery += "GROUP BY SD3.D3_FILIAL, SD3.D3_COD, SD3.D3_EMISSAO, SD3.D3_NUMSEQ, SD3.D3_DOC, SD3.D3_CF "
    cQuery += "ORDER BY 4,6 DESC"

    cQuery := ChangeQuery(cQuery)

    DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.T.,.T.)
    DbUseArea(.T.,'TOPCONN',cAliDesmon,cAliDesmon,.T.)

    While !(cAliasTmp)->(Eof())
        aDesmont	:= {}

        If (cAliasTmp)->D3_CF == "RE7"
            aDesmont	:= {{},{}}
            aDesmont[1] := {	(cAliasTmp)->D3_FILIAL,;
                                StoD((cAliasTmp)->D3_EMISSAO),;
                                (cAliasTmp)->D3_NUMSEQ,;
                                (cAliasTmp)->D3_DOC,;
                                (cAliasTmp)->D3_COD,;
                                (cAliasTmp)->D3_QUANT,;
                                (cAliasTmp)->D3_CF}

            cNumSeq := (cAliasTmp)->D3_NUMSEQ
            (cAliasTmp)->(dbSkip())

            While !(cAliasTmp)->(Eof()) .And. cNumSeq == (cAliasTmp)->D3_NUMSEQ .And. (cAliasTmp)->D3_CF == "DE7"
                Aadd(aDesmont[2],	{(cAliasTmp)->D3_FILIAL,;
                                    (cAliasTmp)->D3_NUMSEQ,;
                                    (cAliasTmp)->D3_DOC,;
                                    (cAliasTmp)->D3_COD,;
                                    (cAliasTmp)->D3_QUANT,;
                                    (cAliasTmp)->D3_CF})
                (cAliasTmp)->(dbSkip())
            EndDo
        Else
            RecLock(cAliDesmon,.T.)
            (cAliDesmon)->STATS     := '2'
            (cAliDesmon)->D3_DOC    := (cAliasTmp)->D3_DOC
            (cAliDesmon)->D3_COD    := (cAliasTmp)->D3_COD
            (cAliDesmon)->D3_NUMSEQ := (cAliasTmp)->D3_NUMSEQ
            MsUnLock()
            (cAliasTmp)->(dbSkip())
        EndIf

        If Len(aDesmont) == 2 
            If Len(aDesmont[2]) > 0
                For nX := 1 To Len(aDesmont[2]) 
                    If aDesmont[1][5] == aDesmont[2][nX][4]
                        RecLock(cAliDesmon,.T.)
                        (cAliDesmon)->STATS     := '0'
                        (cAliDesmon)->D3_DOC    := aDesmont[1][4]
                        (cAliDesmon)->D3_COD    := aDesmont[1][5]
                        (cAliDesmon)->D3_NUMSEQ := aDesmont[1][3]
                        MsUnLock()
                        Exit
                    Endif
                Next nX
            Else
                RecLock(cAliDesmon,.T.)
                (cAliDesmon)->STATS     := '1'
                (cAliDesmon)->D3_DOC    := aDesmont[1][4]
                (cAliDesmon)->D3_COD    := aDesmont[1][5]
                (cAliDesmon)->D3_NUMSEQ := aDesmont[1][3]
                MsUnLock()
            Endif
        EndIf
    EndDo

    (cAliDesmon)->(DbGoTop())
    If (cAliDesmon)->(EoF())
        cThrdStat := "ZERO"
    Else 
        cThrdStat  := "FULL"
    Endif

    (cAliDesmon)->(dbCloseArea())

    PutGlbValue(cGlbName, cThrdStat)

    RpcClearEnv()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} C300JobDes
Thread que realiza a busca das OPs de Retrabalho com inconsistencia.
    
@author Renan Roeder
@since  Jan 28, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function C300JobRet(cEmpX,  cFilX  ,cAliRetrab,dDataDe,dDataAte,cGlbName)
    Local cThrdStat := "ZERO"
    Local cArqTmp   := ""
    Local aCampos   := {}
    Local aTam      := {}
    Local cAliasK265 := ""
    Local cAliasK260 := ""
    Local cMes       := Month(dDataDe)
    Local cAno       := Year(dDataDe)

    Private cTipo00		:= ""
    Private cTipo01		:= ""
    Private cTipo02		:= ""
    Private cTipo03		:= ""
    Private cTipo04		:= ""
    Private cTipo05		:= ""
    Private cTipo06		:= ""
    Private cTipo10		:= ""
    Private nRegsto     := 0
    Private lCpoBZTP    := .T.
    Private cVersSped   := ""

    RpcSetType(3)
    RpcSetEnv( cEmpX, cFilX )

    //-------------------------------------------------------------------------------
    //Variáves necessárias para a chamada da lista do bloco K265/K260 no PCPXSPED.PRW

    cTipo00		:= If(SuperGetMv("MV_BLKTP00",.F.,"'ME'")== " ","'ME'", SuperGetMv("MV_BLKTP00",.F.,"'ME'")) // 00: Mercadoria Revenda
    cTipo01		:= If(SuperGetMv("MV_BLKTP01",.F.,"'MP'")== " ","'MP'", SuperGetMv("MV_BLKTP01",.F.,"'MP'")) // 01: Materia-Prima
    cTipo02		:= If(SuperGetMv("MV_BLKTP02",.F.,"'EM'")== " ","'EM'", SuperGetMv("MV_BLKTP02",.F.,"'EM'")) // 02: Embalagem
    cTipo03		:= If(SuperGetMv("MV_BLKTP03",.F.,"'PP'")== " ","'PP'", SuperGetMv("MV_BLKTP03",.F.,"'PP'")) // 03: Produto em Processo
    cTipo04		:= If(SuperGetMv("MV_BLKTP04",.F.,"'PA'")== " ","'PA'", SuperGetMv("MV_BLKTP04",.F.,"'PA'")) // 04: Produto Acabado
    cTipo05		:= If(SuperGetMv("MV_BLKTP05",.F.,"'SP'")== " ","'SP'", SuperGetMv("MV_BLKTP05",.F.,"'SP'")) // 05: SubProduto
    cTipo06		:= If(SuperGetMv("MV_BLKTP06",.F.,"'PI'")== " ","'PI'", SuperGetMv("MV_BLKTP06",.F.,"'PI'")) // 06: Produto Intermediario
    cTipo10		:= If(SuperGetMv("MV_BLKTP10",.F.,"'OI'")== " ","'OI'", SuperGetMv("MV_BLKTP10",.F.,"'OI'")) // 10: Outros Insumos

    nRegsto     := 0    // Quantidade de Registros Gerados
    lCpoBZTP    := SBZ->(ColumnPos("BZ_TIPO")) > 0
    cVersSped   := VerBlocoK(dDataDe)
    //-------------------------------------------------------------------------------

    cAliasK265 := PCPTabTemp("K265")
    REGK265(cAliasK265,dDataDe,dDataAte,.F.,.T.)
    cAliasK260 := PCPTabTemp("K260")
    REGK260(cAliasK260,dDataDe,dDataAte,.F.,.T.)

    DbUseArea(.T.,'TOPCONN',cAliRetrab,cAliRetrab,.T.)

    T4E->(dbSetOrder(3))
    If T4E->(dbSeek(xFilial("T4E")+STR(cMes,2)+STR(cAno,4)+"MATC300   "+"S"))
        cThrdStat := "FULL"
        While T4E->(!Eof()) .And. T4E->T4E_FILIAL == xFilial("T4E") .And. T4E->T4E_MESAPU == STR(cMes,2) .And. T4E->T4E_ANOAPU == STR(cAno,4) .And. T4E->T4E_PRGORI == "MATC300   " .And. T4E->T4E_SEMRET == "S"
            RecLock(cAliRetrab,.T.)
            (cAliRetrab)->D3_OP  := T4E->T4E_OP
            (cAliRetrab)->D3_COD := T4E->T4E_PRODUT
            (cAliRetrab)->(MsUnLock())
            T4E->(dbSkip())
        EndDo
    EndIf

    PutGlbValue(cGlbName, cThrdStat)

    RpcClearEnv()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetParList
Monta descrição dos parâmetros.
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------

Static Function GetParList()
    Local aParamList := {}

    aAdd(aParamList, {  'MV_BLKTP00',;
                        'Tipo de produto para definição do Bloco K Mercadoria para Revenda.',;
                        'Os produtos do tipo 00 são os adquiridos para comercialização, ou seja, não passão por nenhum outro processo além da compra e venda.';
                    })
    aAdd(aParamList, {  'MV_BLKTP01',;
                        'Tipo de produto para definição do Bloco K Matéria Prima.',;
                        'Mercadoria que componha, física e/ou quimicamente, um produto em processo ou produto acabado e que não seja oriunda do processo produtivo. A mercadoria recebida para industrialização é classificada como Tipo 01, pois não decorre do processo produtivo, mesmo que no processo de produção se produza mercadoria similar classificada como Tipo 03.';
                    })
    aAdd(aParamList, {  'MV_BLKTP02',;
                        'Tipo de produto para definição do Bloco K Embalagem.',;
                        'O produto do tipo Embalagem não possui definição no Guia Prático EFD ICMS IPI.';
                    })
    aAdd(aParamList, {  'MV_BLKTP03',;
                        'Tipo de produto para definição do Bloco K Produto em processo.',;
                        'O produto que possua as seguintes características, cumulativamente: oriundo do processo produtivo e, preponderantemente, consumido no processo produtivo.'+;
                        'Dentre os produtos em processo está incluído o produto resultante caracterizado como retorno de produção. Um produto em processo é caracterizado como retorno '+;
                        'de produção quando é resultante de uma fase de produção e é destinado, rotineira e exclusivamente, a uma fase de produção anterior à qual o mesmo foi gerado. '+;
                        'No "retorno de produção", o produto retorna (é consumido) a uma fase de produção anterior à qual ele foi gerado. Isso é uma excepcionalidade, pois o normal é o produto '+;
                        'em processo ser consumido em uma fase de produção posterior à qual ele foi gerado, e acontece, portanto, em poucos processos produtivos.';
                    })
    aAdd(aParamList, {  'MV_BLKTP04',;
                        'Tipo de produto para definição do Bloco K Produto Acabado.',;
                        '<p>O produto que possua as seguintes características, cumulativamente:</p>'+;
                        '<ul>'+;
                        '<li>Oriundo do processo produtivo.</li>'+;
                        '<li>Produto final resultante do objeto da atividade econômica do contribuinte.</li>'+;
                        '<li>Pronto para ser comercializado.'+;
                        '</ul>';
                    })
    aAdd(aParamList, {  'MV_BLKTP05',;
                        'Tipo de produto para definição do Bloco K Subproduto.',;
                        'O produto que possua as seguintes características, cumulativamente: oriundo do processo produtivo e não é objeto da produção principal do estabelecimento; tem aproveitamento econômico; não se enquadre no conceito de produto em processo (Tipo 03) ou de produto acabado (Tipo 04).';
                    })
    aAdd(aParamList, {  'MV_BLKTP06',;
                        'Tipo de produto para definição do Bloco K Produto intermediário.',;
                        'Aquele que, embora não se integrando ao novo produto, for consumido no processo de industrialização.';
                    })
    aAdd(aParamList, {  'MV_BLKTP10',;
                        'Tipo de produto para definição do Bloco K Outros insumos.',;
                        'O produto do tipo Outros insumos não possui definição no Guia Prático EFD ICMS IPI.';
                    })
    aAdd(aParamList, {  'MV_NEGESTR',;
                        'Permite incluir itens negativos na estrutura, sendo que estes itens irão gerar devoluções no arquivo de movimentos nos módulos de Estoque/PCP.',;
                        'Quando for utilizado o conceito de Estrutura Negativa (MV_NEGESTR), ao apontar uma produção serão geradas as devoluções dos itens com valor negativo na estrutura. '+;
                        'Cada produto que gerar devolução será incluído no Registro K230 com o mesmo número de Ordem de Produção. '+;
                        'Os insumos cadastrados na estrutura que não são negativos e que foram requisitados conta a OP possuirão apenas uma entrada no Registro K235. '+;
                        'Estes mesmos insumos serão rateados entre o PA e os componentes negativos para a gravação do Registro 0210.';
                    })
    aAdd(aParamList, {  'MV_BLKMTHR',;
                        'Define o número de threads que serão utilizadas no processamento do Bloco K do SPED Fiscal. (1 a 20 threads).',;
                        'Devido a quantidade de registros no sistema, muitas vezes a performance do processamento do Bloco K fica comprometida. '+;
                        'As threads realizam o processamento paralélo, auxiliando no tempo de resposta. Elas devem ser dimensionadas de acordo '+;
                        'com a quantidade de registros na base de dados e a infra estrutura do servidor.';
                    })
    aAdd(aParamList, {  'MV_SDTESN3',;
                        'Considera saldo poder de terceiros com TES que NÃO atualiza estoque? 0 = Não | 1= Sim | 2 = Sim, mas não subtrair saldo de TES F4_PODER3 = NÃO',;
                        '<p>O parâmetro MV_SDTESN3 considera o saldo de poder de terceiros no Tipo de Entrada/Saída (TES) que não atualiza estoque e pode assumir os seguintes critérios:</p>'+;
                        '<ul>'+;
                        '<li>0 (zero): desconsidera saldo com registro da tabela SB6 (Saldo em/de poder de terceiros) que contém TES que não atualiza estoque (comportamento padrão).</li>'+;
                        '<li>1 (um): considera saldo com TES que não atualiza estoque e, inclusive, subtrai da composição do saldo em estoque os itens que estão em poder de terceiros.</li>'+;
                        '<li>2 (dois): considera saldo com TES que não atualiza estoque, porém, não realiza a subtração do saldo em poder de terceiros para composição do saldo em estoque.</li>'+;
                        '</ul>';
                    })
    aAdd(aParamList, {  'MV_ARQPROD',;
                        'O parâmetro configura se os dados de indicadores de produto serão considerados pela tabela "SB1" ou se serão considerados pela da tabela "SBZ".',;
                        '<p>Este parâmetro permite definir a tabela que será considerada para coletar as informações de Markup. Pode ser configurado com:</p>'+;
                        '<ul>'+;
                        '<li>SB1 : O Sistema utiliza os campos da tabela Produtos (SB1).</li>'+;
                        '<li>SBZ: O Sistema utiliza os campos da tabela de Complemento de Produtos (SBZ).</li>'+;
                        '</ul>';
                    })
    aAdd(aParamList, {  'MV_BLKPERD',;
                        'Realiza calculo de perda por movimento no bloco 0210.',;
                        'O percentual de perda no processo produtivo, quando utilizada a extração do Registro 0210 por movimento, é habilitada através do parâmetro MV_BLKPERD.'+;
                        'Para a composição deste valor, a rotina de extração utilizará os lançamentos realizados através da rotina de Apontamento de perda (MATA685), '+;
                        'considerando somente registros que geraram movimento de requisição (configuração através dos parâmetros F12 da referida rotina) e não geraram saldo em produto destino.';
                    })
    aAdd(aParamList, {  'MV_CONTERC',;
                        'Indica se deverá controlar o armazém de terceiros ( T = Controla / F = Não Controla ).',;
                        'O parâmetro MV_CONTERC e o campo no Cadastro de TES F4_CONTERC, que tem como objetivo ativar o Controle do Armazém de Poder de Terceiros, '+;
                        'fazendo com que o material enviado (Remessa) para um terceiro, seja transferido do armazém onde possui saldo para o armazém definido no parâmetro MV_ALMTERC. '+;
                        'Esta funcionalidade permite que se possa controlar o custo médio do produto que está em poder de terceiros, '+;
                        'apurando o valor do custo desses produtos através do custo médio atual.';
                    })
    aAdd(aParamList, {  'MV_ALMTERC',;
                        'Indica se armazém e armazém de terceiros.',;
                        'No parâmetro MV_ALMTERC é possível definir o armazém de terceiros. Por padrão ele vem com o valor "80”. '+;
                        'O armazém definido no MV_ALMTERC é bloqueado para que não sejam efetuadas movimentações nele. Apenas as movimentações automáticas, '+;
                        'produzidas pela remessa e devolução de produtos, irão gerar movimentos no armazém de terceiros.';
                    })


Return aParamList

//-------------------------------------------------------------------
/*/{Protheus.doc} CloseScreen
Monta tela de saída
    
@author Flavio Lopes Rasta
@since  Nov 10, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function CloseScreen()
    Local oModal
    Local oContainer
    Local oSay := Nil
    Local lRet := .F.
    
    oModal  := FWDialogModal():New()        
    oModal:SetEscClose(.T.)
    oModal:setTitle("SAIR")
    oModal:setSize(100, 150)
    oModal:createDialog()
    oModal:addYesNoButton()

    oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
    oContainer:Align := CONTROL_ALIGN_ALLCLIENT
        
    oSay := TSay():New(4,4,{|| "Deseja realmente sair do programa? "},oContainer,,,,,,.T.,,,98,98,,,,,,.T.)

    oModal:Activate()

    If oModal:getButtonSelected()
        lRet := .T.
    EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} A300Aceite()
Monta tela de aceite e grava no perfil do usuário.
    
@author Flavio Lopes Rasta
@since  Dez 21, 2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function C300Aceite()

    Local oModal
    Local oContainer
    Local oSayInfo1 := Nil
    Local oSayInfo2 := Nil 
    Local lRet := .F.
    Local oFwProfile    := Nil
    Local aProfile  := {}
    Local lShowScreen := .F.
    Local cAviso   := ""

    oFwProfile  := FWPROFILE():New()
    oFwProfile:SetUser(RetCodUsr())
    oFwProfile:SetProgram('MATC300')
    oFwProfile:SetTask('BLOCOKVLD')
    oFwProfile:SetType('VALIDATION')

    oFwProfile:Activate()
    aProfile := oFwProfile:Load(.T.)

    If Empty(aProfile)
        cAviso := "O sistema detectou que o Diagnóstico do Bloco K não foi executado previamente. Tem certeza que deseja prosseguir?"
    Else 
        If aProfile[1] == 'PROBLEMS'
            lShowScreen := .T. 
            cAviso := "O Diagnóstico do Bloco K detectou divergências na geração do registros e isso pode causar problemas fiscais. Tem certeza que deseja prosseguir? "
        ElseIf aProfile[1] == 'VALID'
            lShowScreen := .F.
            lRet := .T.
        EndIf
    Endif

    If lShowScreen    
        oModal  := FWDialogModal():New()        
        oModal:SetEscClose(.T.)
        oModal:setTitle("Atenção")
        oModal:setSize(150, 150)
        oModal:createDialog()
        oModal:addYesNoButton()

        oContainer := TPanel():New( ,,, oModal:getPanelMain() ) 
        oContainer:Align := CONTROL_ALIGN_ALLCLIENT
            
        oSayInfo1 := TSay():New(4,4,{|| cAviso },oContainer,,,,,,.T.,,,98,98,,,,,,.T.)
        
        oSayInfo2 := TSay():New(4,4,{|| "Importante: ao clicar em sim, o usuário está ciente e assume os riscos dos problemas fiscais que podem ocorrer. "},oContainer,,,,,,.T.,,,98,98,,,,,,.T.)

        oModal:Activate()

        If oModal:getButtonSelected()
            lRet := .T.
            aProfile[2] := "O usuário portador do código '"+RetCodUsr()+"' está de acordo com a geração do Bloco K, mesmo com as divergências apontadas no diagnóstico."
            oFwProfile:SetProfile({aProfile[1],aProfile[2],dDataBase})
            oFwProfile:Save(.T.)
        Else
            lRet := .F.
            aProfile[2] := "Divergências encontradas no diagnóstico"
            oFwProfile:SetProfile({aProfile[1],aProfile[2]})
            oFwProfile:Save(.T.)
        EndIf
    Endif

    oFwProfile:DeActivate()

Return lRet
