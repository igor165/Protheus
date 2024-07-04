#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "FWCSS.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "DGMES.CH"

#DEFINE PROFILE_ID cEmpAnt+cFilAnt+"_"+RetCodUsr()
#DEFINE GLB_PARAMS "__VALIDA_"+"PARAMS_"+PROFILE_ID
#DEFINE GLB_COMUNI "__VALIDA_"+"COMUNI_"+PROFILE_ID
#DEFINE GLB_PROGRA "__VALIDA_"+"PROGRA_"+PROFILE_ID
#DEFINE GLB_AVISOS "__VALIDA_"+"AVISOS_"+PROFILE_ID

#DEFINE LEN_ARRAY_COMUNICACAO 2

Static oDlgWA       := Nil
Static oBrwSX6      := Nil
Static oBrwCom      := Nil
Static oBrwPrg      := Nil
Static oBrwAvi      := Nil
Static oCoverPanel  := Nil
Static cAliParam    := ""
Static cAliComuni   := ""
Static cAliProgra   := ""
Static cAliAvisos   := ""
Static oTTComuni    := Nil
Static oTTProgra    := Nil
Static oTTAvisos    := Nil

Static oGetPrblm     := Nil

Static cPanelContext := "MAIN"
Static lBuildBrw     := .F.
Static lInTimer      := .F.
Static lInClick      := .F.
Static aSize         := {80,80,650,850}

//-------------------------------------------------------------------
/*/{Protheus.doc} VALIDAMES
Diagnóstico TOTVS MES - função principal

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------

Function DGMES()
    Local oDlgWA        := Nil
    Local oWorkArea     := Nil
    Local oMenu         := Nil
    Local oSVG          := Nil
    Local cMenuFld1     := ""
    Local oMenuItem     := Nil
    Local nSayLimit     := 0
    Local nX            := 0

    Private aSvgRef     := {}
    Private aPrgList    := {}
    Private oTimer      := Nil
    Private lExec       := .F.
    Default lAutoMacao  := .F.

    PutGlbValue(GLB_COMUNI, "READY")
    PutGlbValue(GLB_PROGRA, "READY")
    PutGlbValue(GLB_AVISOS, "READY")

    IF !lAutoMacao
        oDlgWA := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], "Diagnóstico TOTVS MES", , , , /*nOr( WS_VISIBLE, WS_POPUP )*/, , , , , .T., , , , .F. )

        oWorkArea := FWUIWorkArea():New( oDlgWA )
        oWorkArea:SetMenuWidth( 150 )

        oMenu := FWMenu():New()
        oMenu:Init()

        cMenuFld1  := oMenu:AddFolder( "Principal", "E" )
        oMenuItem   := oMenu:GetItem(cMenuFld1)
        oMenuItem:AddContent( "Início"              , "E", {|| PAINELINI( oWorkArea ) })
        oMenuItem:AddContent( "Sair"        , "E", {|| If(CloseScreen(),oDlgWA:End(),.T.) } )
        oMenuItem:AddSeparator()
        cMenuFld2  := oMenu:AddFolder( "Diagnósticos", "E" )
        oMenuItem   := oMenu:GetItem(cMenuFld2)
        oMenuItem:AddContent( "Comunicação" , "E", {|| SetContext('COMUNI',oTimer), PainelVal( oWorkArea,@oBrwCom,'COMUNI') })
        oMenuItem:AddContent( "Programas"   , "E", {|| SetContext('PROGRA',oTimer), PainelVal( oWorkArea,@oBrwPrg,'PROGRA') })
        oMenuItem:AddContent( "Avisos"      , "E", {|| SetContext('AVISOS',oTimer), PainelVal( oWorkArea,@oBrwAvi,'AVISOS') })



        oWorkArea:SetMenu( oMenu )

        oWorkArea:CreateHorizontalBox( "LINE01", aSize[3]-80, .T.)
        oWorkArea:SetBoxCols( "LINE01", { "WDGT01" } )

        oWorkArea:Activate()

        //Ao adicionar um item no menu, adicionar também o componente svg.
        For nX := 6 To 8
            oMnuOpc := oWorkArea:oMenuNav:oUiMenuNav:aItem[nX]:oSay
            oMnuOpc:Disable()
            nSayLimit  := (oMnuOpc:nClientWidth/2)-20
            oSVG := TSVG():New(4.5, nSayLimit,oMnuOpc,20,20,SvgWait())
            oSVG:SetCSS( FWCSSVerify( GetClassName(oSVG), "QWidget", "QWidget{border: none; background: transparent;}" ) )
            oSVG:Hide()
            aAdd(aSVGRef,@oSVG)
        Next nX

        oTimer      := TTimer():New( 3000, {|| SvgUpdt(aSvgRef) }  ,oDlgWA )

        oDlgWA:Activate(,,,,,,{|| PAINELINI( oWorkArea ), oTimer:Activate() })
    ENDIF

    ClearTMP()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SetContext
Informa para o workarea qual é a opção selecionada atualmente

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
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
        Case cPanelContext == 'COMUNI'
            If ValType(oBrwCom) == 'O'
                oBrwCom:Destroy()
                oBrwCom := Nil
            Endif
        Case cPanelContext == 'PROGRA'
            If ValType(oBrwPrg) == 'O'
                oBrwPrg:Destroy()
                oBrwPrg := Nil
            Endif
        Case cPanelContext == 'AVISOS'
            If ValType(oBrwAvi) == 'O'
                oBrwAvi:Destroy()
                oBrwAvi := Nil
            Endif
    EndCase

    cPanelContext := cOption
    lInClick := .F.
    oTimer:Activate()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SvgUpdt
Atuliza o componente SVG do menu. Chamado pelo timer da tela.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function SvgUpdt(aSvgRef)
    Local cThrdCom := GetGlbValue(GLB_COMUNI)
    Local cThrdPrg := GetGlbValue(GLB_PROGRA)
    Local cThrdAvi := GetGlbValue(GLB_AVISOS)
	Local lUpdate  := .F.
    Local nX       := 0
    Local oSVG     := Nil

    For nX := 1 To Len(aSvgRef)
        oSVG := aSvgRef[nX]
        Do Case
            Case nX == 1
				If cThrdCom == "OK" .Or. cThrdCom == "ERROR"
					AtuTabCom()
					oSVG:LoadSVG(IIf(cThrdCom == "OK", SvgCheck(), SvgWarn()))
					PutGlbValue(GLB_COMUNI, "STOP")
					lUpdate := .T.
				EndIf

            Case nX == 2
				If cThrdPrg == "OK" .Or. cThrdPrg == "ERROR"
					oSVG:LoadSVG(IIf(cThrdPrg == "OK", SvgCheck(), SvgWarn()))
					PutGlbValue(GLB_PROGRA, "STOP")
					lUpdate := .T.
				EndIf

            Case nX == 3
				If cThrdAvi == "OK" .Or. cThrdAvi == "ERROR"
					oSVG:LoadSVG(IIf(cThrdAvi == "OK", SvgCheck(), SvgWarn()))
					PutGlbValue(GLB_AVISOS, "STOP")
					lUpdate := .T.
				EndIf
        EndCase
    Next nX

	If lUpdate
		BrwUpdate()
	EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} PAINELINI
Tela de início

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------

Static Function PAINELINI( oWaMain )
    Local oPanel := oWaMain:GetPanel( "WDGT01" )

    oPanel:freeChildren()

    oPanelFull := TPanelCss():New(0,0,"",oPanel,,.F.,.F.,,,oPanel:nWidth/2,oPanel:nHeight/2,.T.,.F.)
    oPanelFull:SetCSS("TPanelCss { background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; }")

    oTextDesc := tSimpleEditor():New((oPanel:nHeight/4)-30,(oPanel:nWidth/4)-115, oPanelFull,240,100,,.T.,,,.T. )
    oTextDesc:Setcss("color: #757776; background-color : transparent; border: none; font-size: 25px;")
    oTextDesc:Load("<br /><strong>Selecione o painel a ser exibido.</strong>")

    If !lExec
        StartProc(oWaMain:oMenuNav:oUiMenuNav)
        lExec := .T.
    EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} StartProc
Inicia o processamento

@author Renan Roeder
@since  Nov 28, 2018
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function StartProc(oMenuNav)

        //Altera Icones do menu para Loading
        MenuLoad(oMenuNav)

        //Limpa tabelas temporárias
        ClearTMP()

        //Start job do teste de comunicação
        ProcComuni(@cAliComuni)

        //Start job da validação das datas dos programas
        ProcProgra(@cAliProgra)

        //Start job dos avisos relacionados as regras de negócio
        ProcAvisos(@cAliAvisos)

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} MenuLoad
Realiza a carga inicial dos componentes visuais do menu

@author Renan Roeder
@since  Nov 28, 2018
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function MenuLoad(oMenuNav)
    Local oMnuOpc   := Nil
    Local nX        := 0

    For nX := 6 To 8
        oMnuOpc := oMenuNav:aItem[nX]:oSay
        oMnuOpc:Enable()
    Next nX

    For nX:=1 To Len(aSVGRef)
        aSVGRef[nX]:Show()
        aSVGRef[nX]:LoadSVG(SvgWait())
    Next nX

Return aSVGRef

//-------------------------------------------------------------------
/*/{Protheus.doc} SvgWait
XML do ícone de loading animado em SVG.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
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

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
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

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
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

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function BrwUpdate()

    While lInClick
        //Utilizado para aguardar o processamento do click no menu.
    EndDo

    lInTimer := .T.

    Do Case
        Case cPanelContext == 'COMUNI'
            If lBuildBrw .And. ValType(oBrwCom) == 'O' .And. oBrwCom:lActivate
                oBrwCom:Execute( "RefBrw()",3,0)
            Endif
        Case cPanelContext == 'PROGRA'
            If lBuildBrw .And. ValType(oBrwPrg) == 'O'  .And. oBrwPrg:lActivate
                oBrwPrg:Execute( "RefBrw()",3,0)
            Endif
        Case cPanelContext == 'AVISOS'
            If lBuildBrw .And. ValType(oBrwAvi) == 'O'  .And. oBrwAvi:lActivate
                oBrwAvi:Execute( "RefBrw()",3,0)
            Endif
    EndCase

    lInTimer := .F.

Return
//-------------------------------------------------------------------
/*/{Protheus.doc} RefBrw
Função para ser executada pelo browse apenas para atualizar o
conteúdo. Não precisa executar nada.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Function RefBrw()
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ClearTMP
Exclui as tabelas temporárias criadas pela rotina

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ClearTMP()
    //--Desativa Browse

    If(ValType(oBrwCom) == 'O')
        oBrwCom:Destroy()
        oBrwCom := Nil
    Endif

    If(ValType(oBrwPrg) == 'O')
        oBrwPrg:Destroy()
        oBrwPrg := Nil
    Endif

    If(ValType(oBrwAvi) == 'O')
        oBrwAvi:Destroy()
        oBrwAvi := Nil
    Endif

    If !Empty(cAliComuni)
        oTTComuni:Delete()
        cAliComuni := ""
    Endif

    If !Empty(cAliProgra)
        oTTProgra:Delete()
        cAliProgra := ""
    Endif

    If !Empty(cAliAvisos)
        oTTAvisos:Delete()
        cAliAvisos := ""
    Endif

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PainelVal
Painel de diagnóstico.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function PainelVal(oWaMain,oBrwRef, cRegra)

    Local oPanel        := Nil
    Local oWorkArea     := Nil
    Local oWDGT01       := Nil
    Local oWDGT02       := Nil
    Local cTitle        := ""
    Local cDesc         := ""

    Local cAliasBrw     := ""
    Local aFields       := {}
    Local aSizeWg1      := {}
    Local aLegend       := {}
    Local nX            := 0
    Local nHeightPrbl   := 0

    Private cPrblmDesc  := ""

    Default lAutoMacao  := .F.

    IF !lAutoMacao

        oPanel := oWaMain:GetPanel( "WDGT01" )

        oPanel:freeChildren()

        oWorkArea := FWUIWorkArea():New( oPanel )


        oWorkArea:CreateHorizontalBox( "LINE01X", 100, .T. )
        oWorkArea:SetBoxCols( "LINE01X", { "WDGT01X" } )

        oWorkArea:CreateHorizontalBox( "LINE01", (aSize[3])/2, .T. )
        oWorkArea:SetBoxCols( "LINE01", { "WDGT01" } )

        oWorkArea:CreateHorizontalBox( "LINE02", (aSize[3]-400)/2 , .T. )
        oWorkArea:SetBoxCols( "LINE02", { "WDGT02" } )

        oWorkArea:Activate()

        oWDGT01X := oWorkArea:GetPanel("WDGT01X")
        aSizeWg1 := aSize

        oTopBar := TPanel():New( 0 , 0 ,,oWDGT01X,,,,,, aSizeWg1[4]-2.5, 40.4)
        oTopBar:SetCss( FWGetCSS( GetClassName(oTopBar), CSS_FORMBAR_TOP_BG ) )

        oFont := TFont():New("Arial",,-20,,.T.,,,,,,.F.)
        oFont2 := TFont():New("Arial",,-10,,.T.,,,,,,.F.)
    ENDIF

    Do Case
        Case cRegra == 'COMUNI'
            cTitle    := "Comunicação"
            cDesc     := "Teste de Envio e Retorno de Mensagem"

            cPrblmDesc := "Descrição default"

            Aadd(aLegend,{'STATS == "1" ', "RED"  , "Ocorreram problemas"})
            Aadd(aLegend,{'STATS == "2" ', "GREEN", "Sucesso"            })

            Aadd(aFields,{'Decrição','SEQ_DESC' ,'C', 50, "@!"})

            cAliasBrw := cAliComuni

        Case cRegra == 'PROGRA'
            cTitle    := "Programas"
            cDesc     := "Validação das datas dos programas"

            cPrblmDesc := "Descrição default"

            Aadd(aLegend,{'STATS == "1" ', "RED"  , "Ocorreram problemas"})
            Aadd(aLegend,{'STATS == "2" ', "GREEN", "Sucesso"            })

            Aadd(aFields,{"Programa","PRG_DESC","C",14,Nil,"@!"})
            Aadd(aFields,{"RPO Cliente","PRG_DTRPO","C",10,Nil,"@!"})
            Aadd(aFields,{"RPO Atualizado","PRG_RPOFM","C",10,Nil,"@!"})

            cAliasBrw := cAliProgra

        Case cRegra == 'AVISOS'
            cTitle    := "Avisos"
            cDesc     := "Validações relacionadas a regras de negócio"

            cPrblmDesc := "Descrição default"

            Aadd(aLegend,{'STATS == "1" ', "RED"  , "Ocorreram problemas"})
            Aadd(aLegend,{'STATS == "2" ', "GREEN", "Sucesso"            })

            Aadd(aFields,{"Descrição","STATS_DESC","C",250,Nil,"@!"})

            cAliasBrw := cAliAvisos

    EndCase

    IF !lAutoMacao
        oSayTitle:=     TSay():New(10,10,{|| cTitle }   ,oTopBar,,oFont,,,,.T.,,,300,20,,,,,,.T.)
        oSayTitle2:=    TSay():New(25,10,{|| cDesc }    ,oTopBar,,oFont2,,,,.T.,,,200,20,,,,,,.T.)

        oSayTitle:SetCss("background-color : transparent; color: #0B9BBF}")
        oSayTitle2:SetCss("background-color : transparent; color: #0B9BBF}")

        oWDGT01 := oWorkArea:GetPanel("WDGT01")

        oGroupX := TPanelCss():New(0,0,"",oWDGT01,,.F.,.F.,,,oWDGT01:nWidth/2,oWDGT01:nHeight/2,.T.,.F.)

        //CoverPanel
        /*
            oCoverPanel := TPanelCss():New(0,0,"",oWDGT01,,.F.,.F.,,,oWDGT01:nWidth/2,oWDGT01:nHeight/2,.T.,.F.)
            oCoverPanel:SetCSS("TPanelCss { background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; }")

            oTextDesc := tSimpleEditor():New((oWDGT01:nHeight/4)-55,(oWDGT01:nWidth/4)-10, oCoverPanel,240,100,,.T.,,,.T. )
            oTextDesc:Setcss("color: #757776; background-color : transparent; border: none; font-size: 60px;")
            oTextDesc:Load("<strong>&#9786;</strong>")

            oTextDesc := tSimpleEditor():New((oWDGT01:nHeight/4)-30,(oWDGT01:nWidth/4)-115, oCoverPanel,240,100,,.T.,,,.T. )
            oTextDesc:Setcss("color: #757776; background-color : transparent; border: none; font-size: 25px;")
            oTextDesc:Load("<br /><strong>Não existem itens para serem exibidos.</strong>")

            oCoverPanel:Hide()
        */
        oWDGT02 := oWorkArea:GetPanel("WDGT02")

        oFont3 := TFont():New("Arial",,-12,,.T.,,,,,,.F.)
        oSayTitle:= TSay():New(0,0,{|| ""},oWDGT02,,oFont3,,,,.T.,,,oWDGT02:nWidth,15,,,,,,.T.)
        oSayTitle:SetCss("background-color : #E9F0F6; border-top-left-radius: 4px; border-top-right-radius: 4px;}")

        oSayTitle2:= TSay():New(4,4,{|| "Descrição do Programa"},oWDGT02,,oFont3,,,,.T.,,,100,20,,,,,,.T.)

        oSayTitle2:SetCss("background-color : transparent; color : #757776;}")

        oGroup1 := TPanelCss():New(18,0,"",oWDGT02,,.F.,.F.,,,oWDGT02:nWidth,(oWDGT02:nHeight/2)-18,.T.,.F.)

        oGetPrblm := tSimpleEditor():New(0, 0, oGroup1 ,(oGroup1:nWidth/2) , (oGroup1:nHeight/2)-nHeightPrbl,,.T.,,,.T. )
        oGetPrblm:Load(cPrblmDesc)
        oGetPrblm:Setcss("background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; ")


        oBrwRef := FWMBrowse():New()
        oBrwRef:SetAlias(cAliasBrw)
        oBrwRef:Setfields(aFields)

        For nX := 1 To Len(aLegend)
            oBrwRef:AddLegend(aLegend[nX,1],aLegend[nX,2],aLegend[nX,3])
        Next nX

        //oBrwRef:SetColumns(aFields)
        oBrwRef:SetTemporary(.T.)
        oBrwRef:DisableReport()
        oBrwRef:DisableDetails()

        oBrwRef:SetChange({|| oGetPrblm:Load(STATS_DESC) })

        oBrwRef:Activate(oGroupX)
    ENDIF
    lBuildBrw := .T.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcComuni
Cria temporária e adiciona os registros que identificarão
o teste de comunicação.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ProcComuni(cAliComuni)
    Local aCampos  := {}
    Local aComList := {}
    Local nIndex   := 0

    oTTComuni := FwTemporaryTable():New()

    PutGlbValue(GLB_COMUNI, "READY")
	VarSetUID(GLB_COMUNI + "_TABLE")

    Aadd(aCampos,{"STATS"     , "C",   1, 0})
    Aadd(aCampos,{"SEQ"       , "N",   1, 0})
    Aadd(aCampos,{"SEQ_DESC"  , "C",  50, 0})
    Aadd(aCampos,{"STATS_DESC", "C", 250, 0})

	oTTComuni:SetFields(aCampos)
	oTTComuni:AddIndex("01",{"SEQ"})
	oTTComuni:Create()

    cAliComuni := oTTComuni:GetAlias()
    aComList   := GetComList()

    For nIndex := 1 To LEN_ARRAY_COMUNICACAO
        RecLock(cAliComuni,.T.)
			(cAliComuni)->SEQ        := nIndex
			(cAliComuni)->STATS      := aComList[nIndex][1]
			(cAliComuni)->SEQ_DESC   := aComList[nIndex][2]
			(cAliComuni)->STATS_DESC := aComList[nIndex][3]
        MsUnLock()

		VarSetAD(GLB_COMUNI + "_TABLE", cValToChar(nIndex), aComList[nIndex])
    Next nIndex

    StartJob("VALJOBCOM", GetEnvServer(), .F., cEmpAnt, cFilAnt, cAliComuni, GLB_COMUNI, AllTrim(cCaminho))

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} VALJOBCOM
Job para envio dos xmls para o teste de comunicação.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Function VALJOBCOM(cEmpx, cFilx, cAliComuni, cGlbName, cCaminho)
	Local aRetWS     := {}
	Local cGenerated := SubStr(DTOS(Date()), 1, 4) + '-' + SubStr(DTOS(Date()), 5, 2) + '-' + SubStr(DTOS(Date()), 7, 2) + 'T' + Time()
	Local cServerIni := GetAdv97()
	Local cServerIp  := GetServerIP()
	Local cProduct   := "PROTHEUS"
	Local cVersion   := GetRPORelease()
	Local cEndPoint  := ""
	Local cActiveSFC := ""
	Local cXml       := ""
	Local nInicio    := 0
	Local nFim       := 0
	Local cPortaHTTP := "0"

    RpcSetType(3)
    RpcSetEnv(cEmpx,cFilx)

	If GetPvProfString("HTTP", "ENABLE", "0", cServerIni) == "1"
		cPortaHTTP := GetPvProfString("HTTP", "PORT", "", cServerIni)
		cEndPoint  := cServerIp + ":" + cPortaHTTP + "/WSPCP?WSDL"
	EndIf
	cActiveSFC := IIf(SuperGetMV("MV_INTSFC",.F.,0) == 1, "TRUE", "FALSE")

	cXml := '<?xml version="1.0" encoding="UTF-8"?>'
	cXml += '<TOTVSMessage xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="whois_1_000.xsd">'
	cXml +=    '<MessageInformation version="">'
	cXml +=       '<UUID>UUID</UUID>''
	cXml +=       '<Type>BusinessMessage</Type>'
	cXml +=       '<Transaction>WhoIs</Transaction>'
	cXml +=       '<ContextName>PROTHEUS</ContextName>'
	cXml +=       '<StandardVersion>1.0</StandardVersion>'
	cXml +=       '<SourceApplication>SIGAPCP</SourceApplication>'
	cXml +=       '<CompanyId>' + cEmpx + '</CompanyId>'
	cXml +=       '<BranchId>' + cFilx + '</BranchId>'
	cXml +=       '<UserId>000000</UserId>'
	cXml +=       '<Product name="PCPA109" version="' + cVersion + '"/>'
	cXml +=       '<GeneratedOn>' + cGenerated + '</GeneratedOn>'
	cXml +=       '<DeliveryType>Sync</DeliveryType>'
	cXml +=    '</MessageInformation>'
	cXml +=    '<BusinessMessage>'
	cXml +=       '<BusinessEvent>'
	cXml +=          '<Entity>Entity</Entity>'
	cXml +=          '<Event>upsert</Event>'
	cXml +=          '<Identification>'
	cXml +=             '<key name="PRODUCT_NAME">'     + cProduct   + '</key>'
	cXml +=             '<key name="PRODUCT_VERSION">'  + cVersion   + '</key>'
	cXml +=             '<key name="PRODUCT_ENDPOINT">' + cEndPoint  + '</key>'
	cXml +=             '<key name="ACTIVE_SFC">'       + cActiveSFC + '</key>'
	cXml +=          '</Identification>'
	cXml +=       '</BusinessEvent>'
	cXml +=       '<BusinessContent/>'
	cXml +=    '</BusinessMessage>'
	cXml += '</TOTVSMessage>'

	nInicio := MicroSeconds()
	aRetWS  := PCPWebsPPI(cXml, cCaminho)
	nFim    := MicroSeconds()
	/*
		aRetWS[1] - Status do envio (1 - OK, 2 - Pendente, 3 - Erro.)
		aRetWS[2] - Mensagem de retorno do PPI
		aRetWS[3] - XML enviado
		aRetWS[4] - XML recebido
	*/
	If aRetWS[1] == "1"
		VarSetAD(cGlbName + "_TABLE", "1", {"2"                , ;
		                                    "Mensagem de Envio", ;
		                                    IIf(Upper(aRetWS[2]) == "OK", "Mensagem enviada com sucesso.", AllTrim(aRetWS[2]))})
		VarSetAD(cGlbName + "_TABLE", "2", {"2"                  , ;
		                                    "Mensagem de Retorno", ;
											IIf(Upper(aRetWS[2]) == "OK", "Mensagem recebida com sucesso.", AllTrim(aRetWS[2]))})
    	PutGlbValue(cGlbName, "OK")
	Else
		If aRetWS[1] == "2"
			VarSetAD(cGlbName + "_TABLE", "1", {IIf(aRetWS[1] == "2", "1", "2"), ;
												"Mensagem de Envio"            , ;
												"Erro ao enviar a mensagem.<br>" + aRetWS[2]})
		Else
			VarSetAD(cGlbName + "_TABLE", "1", {"2"                , ;
												"Mensagem de Envio", ;
												"Mensagem enviada com sucesso."})
		EndIf

		If Empty(aRetWS[4])
			VarSetAD(cGlbName + "_TABLE", "2", {"1"                  , ;
			                                    "Mensagem de Retorno", ;
												"Retorno não recebido."})
		Else
			VarSetAD(cGlbName + "_TABLE", "2", {"1"                  , ;
			                                    "Mensagem de Retorno", ;
												"Erro ao interpretar a mensagem de retorno.<br>" + aRetWS[2]})
		EndIf

    	PutGlbValue(cGlbName, "ERROR")
	EndIf

    RpcClearEnv()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetComList
Monta o array com os registros a serem exibidos no grid de comunicação.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function GetComList()
	Local aComList := Array(LEN_ARRAY_COMUNICACAO)

    aComList[1] := {"0", "Mensagem de Envio"  , "Preparando o envio da mensagem."}
    aComList[2] := {"0", "Mensagem de Retorno", "Aguardando o retorno da mensagem."}

Return aComList

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcProgra
Cria temporária e adiciona os registros que identificarão
o teste de datas dos programas.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ProcProgra(cAliProgra)
    Local aCampos   := {}
    Local aPrgList := {}
    Local nX := 0

    oTTProgra := FwTemporaryTable():New()

    PutGlbValue(GLB_PROGRA, "READY")

    Aadd(aCampos,{"STATS","C",1,0})
    Aadd(aCampos,{"SEQ","N",2,0})
    Aadd(aCampos,{"PRG_DESC" ,"C" ,20,0})
    Aadd(aCampos,{"PRG_DTRPO","C",10,0})
    Aadd(aCampos,{"PRG_RPOFM","C",10,0})
    Aadd(aCampos,{"STATS_DESC","C",250,0})

	oTTProgra:SetFields(aCampos)
	oTTProgra:AddIndex("01",{"SEQ"})
	oTTProgra:Create()

    cAliProgra := oTTProgra:GetAlias()

    aPrgList := GetPrgList()

    For nX:=1 To Len(aPrgList)
        RecLock(cAliProgra,.T.)
        If GetApoInfo(aPrgList[nX][3])[4] < cToD(aPrgList[nX][4])
            aPrgList[nX][1] := "1"
        Else
            aPrgList[nX][1] := "2"
        EndIf
        (cAliProgra)->STATS     := aPrgList[nX][1]
        (cAliProgra)->SEQ       := aPrgList[nX][2]
        (cAliProgra)->PRG_DESC  := aPrgList[nX][3]
        (cAliProgra)->PRG_RPOFM := aPrgList[nX][4]
        (cAliProgra)->PRG_DTRPO := dToC(GetApoInfo(aPrgList[nX][3])[4])
        (cAliProgra)->STATS_DESC:= aPrgList[nX][5]

        MsUnLock()
    Next nX

    StartJob("VALJOBPRG",GetEnvServer(),.F.,cEmpAnt,  cFilAnt ,cAliProgra,GLB_PROGRA)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetPrgList
Monta o array com os registros a serem exibidos no grid de programas.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function GetPrgList()

    aAdd(aPrgList, {"0",  1, "AGRI045.PRW"     , "30/01/2020", STR0001})
    aAdd(aPrgList, {"0",  2, "AGRA045.PRW"     , "16/06/2020", STR0002})
    aAdd(aPrgList, {"0",  3, "MATA010.PRX"     , "23/07/2020", STR0004})
    aAdd(aPrgList, {"0",  4, "MATA010M.PRX"    , "17/07/2020", STR0005})
    aAdd(aPrgList, {"0",  5, "MATA010PPI.PRW"  , "06/05/2020", STR0006})
    aAdd(aPrgList, {"0",  6, "MATA015.PRX"     , "09/07/2018", STR0007})
    aAdd(aPrgList, {"0",  7, "PCPA200.PRW"     , "14/02/2022", STR0008})
    aAdd(aPrgList, {"0",  8, "MATA220.PRX"     , "13/12/2019", STR0009})
    aAdd(aPrgList, {"0",  9, "MATA240.PRX"     , "26/06/2020", STR0010})
    aAdd(aPrgList, {"0", 10, "MATA241.PRX"     , "15/07/2020", STR0011})
    aAdd(aPrgList, {"0", 11, "MATA250.PRX"     , "17/07/2020", STR0012})
    aAdd(aPrgList, {"0", 12, "MATA265.PRX"     , "23/07/2020", STR0013})
    aAdd(aPrgList, {"0", 13, "MATA380.PRX"     , "12/12/2019", STR0014})
    aAdd(aPrgList, {"0", 14, "MATA381.PRX"     , "01/06/2020", STR0015})
    aAdd(aPrgList, {"0", 15, "MATA620EVDEF.PRW", "07/12/2018", STR0016})
    aAdd(aPrgList, {"0", 16, "PCPA124.PRW"     , "31/05/2021", STR0017})
    aAdd(aPrgList, {"0", 17, "MATA637.PRW"     , "09/07/2020", STR0018})
    aAdd(aPrgList, {"0", 18, "MATA650.PRX"     , "28/07/2020", STR0019})
    aAdd(aPrgList, {"0", 19, "MATA680.PRX"     , "29/06/2020", STR0020})
    aAdd(aPrgList, {"0", 20, "MATA681.PRX"     , "08/04/2020", STR0021})
    aAdd(aPrgList, {"0", 21, "MATA685.PRX"     , "21/07/2020", STR0022})
    aAdd(aPrgList, {"0", 22, "MATA805.PRX"     , "17/07/2020", STR0024})
    aAdd(aPrgList, {"0", 23, "MATI010.PRX"     , "06/05/2010", STR0025})
    aAdd(aPrgList, {"0", 24, "MATI015.PRW"     , "29/12/2018", STR0026})
    aAdd(aPrgList, {"0", 25, "MATI200.PRW"     , "18/06/2020", STR0027})
    aAdd(aPrgList, {"0", 26, "MATI225.PRW"     , "31/01/2020", STR0028})
    aAdd(aPrgList, {"0", 27, "MATI250.PRW"     , "12/03/2018", STR0029})
    aAdd(aPrgList, {"0", 28, "MATI261.PRX"     , "06/06/2018", STR0030})
    aAdd(aPrgList, {"0", 29, "MATI610.PRW"     , "11/07/2019", STR0031})
    aAdd(aPrgList, {"0", 30, "MATI682.PRW"     , "20/12/2018", STR0032})
    aAdd(aPrgList, {"0", 31, "MATI685.PRW"     , "12/03/2018", STR0033})
    aAdd(aPrgList, {"0", 32, "PCPA109.PRW"     , "11/06/2020", STR0036})
    aAdd(aPrgList, {"0", 33, "PCPA111.PRW"     , "18/06/2020", STR0037})
    aAdd(aPrgList, {"0", 34, "PCPA114.PRW"     , "08/02/2018", STR0038})
    aAdd(aPrgList, {"0", 35, "PCPA124.PRW"     , "02/07/2020", STR0039})
    aAdd(aPrgList, {"0", 36, "PCPA124EVDEF.PRW", "09/07/2020", STR0040})
    aAdd(aPrgList, {"0", 37, "PCPA145.PRW"     , "18/06/2021", STR0049})
    aAdd(aPrgList, {"0", 38, "PCPA381EVDEF.PRW", "28/11/2019", STR0041})
    aAdd(aPrgList, {"0", 39, "PCPA712.PRW"     , "18/06/2021", STR0023})
    aAdd(aPrgList, {"0", 40, "PCPXFUN.PRX"     , "03/08/2020", STR0042})
    aAdd(aPrgList, {"0", 41, "SFCI003.PRW"     , "03/01/2019", STR0043})
    aAdd(aPrgList, {"0", 42, "SFCI004.PRW"     , "20/12/2018", STR0044})
    aAdd(aPrgList, {"0", 43, "SFCI006.PRW"     , "11/12/2018", STR0045})
    aAdd(aPrgList, {"0", 44, "SIGACUSB.PRX"    , "29/07/2020", STR0046})
    aAdd(aPrgList, {"0", 45, "WSPCFACTORY.PRW" , "28/08/2019", STR0047})
    aAdd(aPrgList, {"0", 46, "WSPCP.PRW"       , "23/01/2020", STR0048})

Return aPrgList

//-------------------------------------------------------------------
/*/{Protheus.doc} VALJOBPRG
Job para envio dos xmls para o teste das datas dos programas.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Function VALJOBPRG(cEmpx,cFilx,cAliProgra,cGlbName)

    RpcSetType(3)
    RpcSetEnv(cEmpx,cFilx)

    PutGlbValue(cGlbName, "OK")

    RpcClearEnv()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcAvisos
Cria temporária e adiciona os registros que identificarão
o teste dos assuntos relacionados aos avisos.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function ProcAvisos(cAliAvisos)
    Local aCampos   := {}
    Local aAviList := {}
    Local nX := 0

    oTTAvisos := FwTemporaryTable():New()

    PutGlbValue(GLB_AVISOS, "READY")

    Aadd(aCampos,{"STATS","C",1,0})
    Aadd(aCampos,{"SEQ","N",1,0})
    Aadd(aCampos,{"STATS_DESC" ,"C" ,250,0})

	oTTAvisos:SetFields(aCampos)
	oTTAvisos:AddIndex("01",{"SEQ"})
	oTTAvisos:Create()

    cAliAvisos := oTTAvisos:GetAlias()

    aAviList := GetAviList()

    For nX:=1 To Len(aAviList)
        RecLock(cAliAvisos,.T.)
        (cAliAvisos)->STATS         := aAviList[nX][1]
        (cAliAvisos)->SEQ           := aAviList[nX][2]
        (cAliAvisos)->STATS_DESC    := aAviList[nX][3]
        MsUnLock()
    Next nX

   StartJob("VALJOBAVI",GetEnvServer(),.F.,cEmpAnt,cFilAnt,cAliAvisos,GLB_AVISOS)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GetAviList
Monta o array com os registros a serem exibidos no grid de avisos.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
/*/
//-------------------------------------------------------------------
Static Function GetAviList()
Local aAviList := {}

    aAdd(aAviList, {"0",1,"Localização"})
    aAdd(aAviList, {"0",2,"Filial"})
    aAdd(aAviList, {"0",3,"Endereçamento"})
    aAdd(aAviList, {"0",4,"Operações"})
    aAdd(aAviList, {"0",5,"Segurança"})
    aAdd(aAviList, {"0",6,"Sequencial Estrutura"})
    aAdd(aAviList, {"0",7,"Ordens APS"})
    aAdd(aAviList, {"0",8,"Versão Build"})

Return aAviList

Function VALJOBAVI(cEmpx,cFilx,cAliAvisos,cGlbName)

    RpcSetType(3)
    RpcSetEnv(cEmpx,cFilx)

    PutGlbValue(cGlbName, "OK")

    RpcClearEnv()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CloseScreen
Função responsável por encerrar o programa.

@author Renan Roeder
@since  Jul 12, 2019
@version 12.1.25
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


//---------------------------------------------------------------------------
// Copia arquivos do FTP
//---------------------------------------------------------------------------
Function CopiaFtp(cArqs, cServer, cPort ,cUser, cPass, cSource, cDestiny )

Local cServidor := cServer
Local cPorta    := cPort
Local cLogin    := cUser
Local cSenha    := cPass
Local cOrigem   := cSource
Local cDestino  := cDestiny
Local n := 0

Local lRet         := .T.
Default lAutoMacao := .F.

FTPDisconnect()

IF !lAutoMacao
    If !FTPConnect( cServidor, cPorta, cLogin, cSenha )
        APMsgInfo( 'Falha na conexão!' )
        lRet := .F.
    Else
        If FTPDirChange(cOrigem)
            aArqs := FTPDIRECTORY( cArqs )
            If Len(aArqs) = 0
                APMsgInfo( 'Nenhum pedido encontrado no site, verificar arquivos locais' )
                lRet := .F.
            Else
                For n := 1 to Len(aArqs)
                    If !FTPDOWNLOAD(cDestino+aArqs[n][1], aArqs[n][1] )
                        APMsgInfo( 'Problemas ao copiar arquivo '+ aArqs[n][1] )
                    Else
                        If !FTPERASE( aArqs[n][1] )
                            APMsgInfo('Problemas ao apagar o arquivo ' + aArqs[n][1] )
                        EndIf
                    EndIf
                Next
            EndIf
        EndIf
    EndIf
ENDIF

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} AtuTabCom
Função responsável por atualizar a tabela temporária da Comunicação

@author Marcelo Neumann
@since  Ago 03, 2020
@version 12.1.27
/*/
//-------------------------------------------------------------------
Static Function AtuTabCom()

	Local aValues := {}
	Local nIndex  := 1

	For nIndex := 1 To LEN_ARRAY_COMUNICACAO
		VarGetAD(GLB_COMUNI + "_TABLE", cValToChar(nIndex), aValues)

		(cAliComuni)->(dbSetOrder(1))
		(cAliComuni)->(dbSeek(cValToChar(nIndex)))

		If aValues != Nil
			RecLock(cAliComuni,.F.)
				(cAliComuni)->SEQ        := nIndex
				(cAliComuni)->STATS      := aValues[1]
				(cAliComuni)->SEQ_DESC   := aValues[2]
				(cAliComuni)->STATS_DESC := aValues[3]
			MsUnLock()
		EndIf

		aSize(aValues, 0)
	Next nIndex

	(cAliComuni)->(dbGoTop())

Return
