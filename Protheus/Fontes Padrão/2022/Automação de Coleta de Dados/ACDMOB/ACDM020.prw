#INCLUDE "AcdM020.ch" 
#INCLUDE "protheus.ch"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "FWTABLEATTACH.CH"
#INCLUDE "FWCSS.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FWBROWSE.CH"

/*/{Protheus.doc} ACDM020
    (long_description)
    @type  Function
    @author André Maximo
    @since  Maio 06, 2019
    @version 12.1.17
/*/
Function AcdM020()

Local aSize         := FWGetDialogSize( oMainWnd )
Local cLink 		:= "http://tdn.totvs.com/pages/viewpage.action?pageId=494961694"
Local oDlgWA        := Nil
Local oWorkArea     := Nil
Local oMenu         := Nil
Local cMenuFld1     := ""
Local cMenuFld2     := ""
Local oMenuItem     := Nil
Local lUpdated      := AliasInDic("D3V")


If lUpdated
    cCadastro := STR0001 //"Divergência do Meu Coletor de dados"

    oDlgWA := MSDialog():New( aSize[1], aSize[2], aSize[3], aSize[4], cCadastro, , , , nOr( WS_VISIBLE, WS_POPUP ), , , , , .T., , , , .F. ) 

    oWorkArea := FWUIWorkArea():New( oDlgWA )
    oWorkArea:SetMenuWidth( 215 )

    oMenu := FWMenu():New()
    oMenu:Init()

    cMenuFld1   := oMenu:AddFolder( STR0051, "E" ) //Rotinas
    oMenuItem   := oMenu:GetItem(cMenuFld1) 
    oMenuItem:AddSeparator()
    oMenuItem:AddContent( STR0002           , "E", {||  ConfPreNt( oWorkArea)}) //"Conferencia Pre/Doc"
    oMenuItem:AddContent( STR0003           , "E", {||  TransMT261( oWorkArea)}) //Transferencia
    oMenuItem:AddContent( STR0004           , "E", {||  Invent( oWorkArea)})//Inventario
    If D3V->( ColumnPos( "D3V_INFO" ) ) > 0
        oMenuItem:AddContent( STR0058           , "E", {||  Enderec( oWorkArea ) } ) //Endereçamento
    EndIf

    cMenuFld2  := oMenu:AddFolder( STR0005, "E" ) //Outras Ações
    oMenuItem   := oMenu:GetItem(cMenuFld2) 
    oMenuItem:AddSeparator()
    oMenuItem:AddContent( STR0006                      , "E", {|| ShellExecute("open",cLink  ,"","",SW_SHOW) } ) //Ajuda
    oMenuItem:AddContent( STR0007                      , "E", {|| If(CloseScreen(),oDlgWA:End(),.T.) } ) //Sair

    oWorkArea:SetMenu( oMenu )

    oWorkArea:CreateHorizontalBox( "LINE01", aSize[3], .T.)
    oWorkArea:SetBoxCols( "LINE01", { "WDGT01" } )

    oWorkArea:Activate()
    oDlgWA:Activate( , , , , , , EnchoiceBar( oDlgWA, {||}, { || oDlgWA:End() }, , , , , , , .F., .F. ) )
Else
    MsgInfo(STR0008,STR0009) //"Necessário Pacote de Atualização pacote ACD mobile" // Atenção                                                                                                                                                                                                                                                                                                                                                                                                                                                              
Endif

 
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ConfPreNt
Monta Tela de divergencia da conferencia 
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ConfPreNt(oWaMain)

Local oPanel    := oWaMain:GetPanel( "WDGT01" )
Local aSize         := {}
Local aLegend       := {}
Local aFields       := {}
Local cTexto        := " "
Local nX            := 0
Local oWorkArea     := Nil
Local oWDGT01       := Nil
Local oTopBar       := Nil
Local aSizeWg1      := {}
Local oFont         := Nil
Local oFont2        := Nil
Local oFont3        := Nil
Local oSayTitle     := Nil
Local oSayTitle2    := Nil
Local oCoverPanel   := Nil
Local oTextDesc     := Nil
Local oGroupX       := Nil 
Local oGroup1       := Nil
Local oGroup2       := Nil
Local oWDGT02       := Nil
Local oWDGT03       := Nil 
Local oGetPrblm     := Nil


TelaBrWPad(@oPanel,@oFont,@oFont2,@oTopBar,@aSize,@aSizeWg1,@oWorkArea,@oWDGT01,"CONF")
FilaFields("CONF",@aFields,@aLegend)
TPainelBrw(@oCoverPanel,@oCoverPanel,@oTextDesc,@oWDGT01)
TPainelCFG(@oWorkArea,@oGroup1,@oGroup2,@oWDGT01,@oWDGT02,@oWDGT03,@oGroupX,"CONF")


oBrwRef := FWMBrowse():New()
oBrwRef:SetAlias("D3V")
oBrwRef:Setfields(aFields)
oBrwRef:SetFilterDefault( "D3V_ORIGEM =='1'" )
oBrwRef:DisableReport()
oBrwRef:DisableDetails()

MenuSoluc(oGroup2,'CONF',@oBrwRef)

For nX := 1 To Len(aLegend)
    oBrwRef:AddLegend(aLegend[nX,1],aLegend[nX,2],aLegend[nX,3])
Next nX

oBrwRef:Activate(oGroupX)
lBuildBrw := .T.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MontaSoluc
Monta opções do menu para cadastro de produto
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MontaSoluc(cSolOpc,oGet,oContainer)

Local cContent  := "" 
Local oSolInf   := Nil
Local oBtnRot1   := Nil
Local oBtnRot2  := Nil


oContainer:freeChildren()

cContent += "<h3>"+STR0010+"</h3>"//"Verifique o cadastro do produto ou preenchimento do campo Código de barras (B1_COBBAR)  ou amarração Produto X Código de barras (SLK)."
cContent += "<p>"+STR0011+"</p>"  //"Ao termino do cadastramento pressione 'ESC' para sair da rotina de cadastro. Entre na opção de reprocessar será realizado a contagem ou recontagem se for encontrar divergência na PreNota/Documento."

oBtnRot1 := TButton():New( 0, 0, STR0012   ,oContainer,{|| loja210() }, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. )//"Amarração CodBar X SLK"  
oBtnRot2 := TButton():New( 0, ((oContainer:nWidth/2)/2)+1, STR0013       ,oContainer,{|| MATA010() }, ((oContainer:nWidth/2)/2)-1,12,,,.F.,.T.,.F.,,.F.,,,.F. )//"Produtos"


oGet:Load(cContent)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Reprocessa
Monta opções do menu de soluções para o problema de contagem da conferencia
e recontagem do inventario.
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function Reprocessa(cSolOpc,oGet,oContainer,cRegra,oBrwRef)

Local cContent  := "" 
Local oBtnRot1   := Nil
Local oBtnRot2  := Nil


oContainer:freeChildren()

If cRegra == "CONF"
    cContent += "<h3>"+STR0014+"</h3>" //Recontagem do item
    cContent += "<p> "+STR0015+"</p>"//Caso a conferencia esteja em andamento o item será contado se estiver em divergencia sera liberado a prénota para recontagem

    oBtnRot1 := TButton():New( 0, 0, STR0016   ,oContainer,{|| RecontNot(oBrwRef) }, (oContainer:nWidth/2),12,,,.F.,.T.,.F.,,.F.,,,.F. ) //Reprocessa
    oGet:Load(cContent)
Else    
    cContent += "<h3>"+STR0014+"</h3>" //Recontagem do item:
    cContent += "<p> "+STR0033+"</p>"//Caso o inventário esteja em aberto será incluído a contagem referente ao produto que foi identificado corretamente.

    oBtnRot1 := TButton():New( 0, 0, STR0016   ,oContainer,{|| RecontInv(oBrwRef) }, (oContainer:nWidth/2),12,,,.F.,.T.,.F.,,.F.,,,.F. ) //Reprocessa
    oGet:Load(cContent)
EndIf


Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuSoluc
Monta opções do menu de soluções 
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MenuSoluc(oContainer,cRegra,oBrwRef)

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

If cRegra == "CONF"
    oMenu:AddContent( STR0013      , "E", {|| oPanelSol:Show(), MontaSoluc('PRODUTO'      ,oGetSolution, oSolInf) } )//Produto
    oMenu:AddContent( STR0016      , "E", {|| oPanelSol:Show(), Reprocessa('PRODUTO'      ,oGetSolution, oSolInf,'CONF',oBrwRef) } )// Reprocessa
Else
    oMenu:AddContent( STR0013      , "E", {|| oPanelSol:Show(), MontaSoluc('PRODUTO'      ,oGetSolution, oSolInf) } )//Produto
    oMenu:AddContent( STR0016      , "E", {|| oPanelSol:Show(), Reprocessa('PRODUTO'      ,oGetSolution, oSolInf,'INV', oBrwRef) } )// Reprocessa
EndIf
    


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
/*/{Protheus.doc} TransMT261
Monta a tela de divergencia de transferencias de armazem   
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function TransMT261(oWaMain)

Local oPanel    := oWaMain:GetPanel( "WDGT01" )
Local aSize         := {}
Local aLegend       := {}
Local aFields       := {}
Local nX            := 0
Local oWorkArea     := Nil
Local oWDGT01       := Nil
Local oTopBar       := Nil
Local aSizeWg1      := {}
Local oFont         := Nil
Local oFont2        := Nil
Local oFont3        := Nil
Local oSayTitle     := Nil
Local oSayTitle2    := Nil
Local oCoverPanel   := Nil
Local oTextDesc     := Nil
Local oGroupX       := Nil 
Local oGroup1       := Nil
Local oGroup2       := Nil
Local oWDGT02       := Nil
Local oWDGT03       := Nil
Local oGetPrblm     := Nil

TelaBrWPad(@oPanel,@oFont,@oFont2,@oTopBar,@aSize,@aSizeWg1,@oWorkArea,@oWDGT01,"TRANS")
FilaFields("TRANS",@aFields,@aLegend)
TPainelBrw(@oCoverPanel,@oCoverPanel,@oTextDesc,@oWDGT01)
TPainelCFG(@oWorkArea,@oGroup1,@oGroup2,@oWDGT01,@oWDGT02,@oWDGT03,@oGroupX,"TRANS")


oBrwRef := FWMBrowse():New()
oBrwRef:SetAlias("D3V")
oBrwRef:Setfields(aFields)
oBrwRef:SetFilterDefault( "D3V_ORIGEM =='4'" )
oBrwRef:DisableReport()
oBrwRef:DisableDetails()
oBrwRef:Refresh()

MenuTrans(oGroup2,@oBrwRef)



For nX := 1 To Len(aLegend)
    oBrwRef:AddLegend(aLegend[nX,1],aLegend[nX,2],aLegend[nX,3])
Next nX

oBrwRef:Activate(oGroupX)
lBuildBrw := .T.

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuTrans
Monta opções do menu de soluções da transferencia 
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function MenuTrans(oContainer,oBrwRef)

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

    
oMenu:AddContent( STR0017  , "E", {|| oPanelSol:Show(), Anali261('PRODUTO' ,oGetSolution, oSolInf) } ) // Analise de Saldo
oMenu:AddContent( STR0016       , "E", {|| oPanelSol:Show(), Reproc261('PRODUTO' ,oGetSolution, oSolInf,oBrwRef) } ) // Reprocessa

    


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
/*/{Protheus.doc} Anali261
Monta opções do menu para acessar o saldo atual     
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function Anali261(cSolOpc,oGet,oContainer)

Local cContent  := "" 
Local oBtnRot1   := Nil


oContainer:freeChildren()

cContent := "<h3>"+STR0017+"</h3>"
cContent +=  "<p>"+STR0046+"</p>"


oBtnRot1 := TButton():New( 0, 0, STR0018   ,oContainer,{|| MATA225() }, (oContainer:nWidth/2),12,,,.F.,.T.,.F.,,.F.,,,.F. )//"Saldo Atual" 

oGet:Load(cContent)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} Reprocessa
Monta opções do menu para reprocessar a transferencia.  
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function Reproc261(cSolOpc,oGet,oContainer,oBrwRef)

Local cContent  := "" 
Local oBtnRot1   := Nil


oContainer:freeChildren()

cContent := "<h3>"+STR0019+"</h3>"
cContent += "<h3>"+STR0047+"</h3>"//"Ao executar o reprocessamento será realizado a execução da transferência entre armazém se não houver nenhuma inconsistência."                                                                                                                                                                                                                                                                                                                                                                                      

oBtnRot1 := TButton():New( 0, 0, STR0016 ,oContainer,{|| ExeC261(oBrwRef) }, (oContainer:nWidth/2),12,,,.F.,.T.,.F.,,.F.,,,.F. )// "Reprocessa"   
oGet:Load(cContent)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExeC261
Reprocessa a transferencia com base no MATA261
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static function ExeC261(oBrwRef)

Local aTransf := {}
Local nCount := 1
Local cPath     	:= GetSrvProfString("StartPath","")
Local cFile     	:= NomeAutoLog()
Local cNumDoc       := " "
Local lRet          := .T.
Private lMsHelpAuto , lMsErroAuto, lMsFinalAuto := .f.
Private cCodBar   := Iif(D3V->D3V_CODBAR  <> NIL,D3V->D3V_CODBAR ," ") 
Private cProduto  := Iif(D3V->D3V_CODPROD <> NIL,D3V->D3V_CODPROD," ")

If EMPTY(cProduto) .And. EMPTY(cCodBar)
    lRet := .F.
EndIf 

If lRet
    SB1->(dbSetOrder(1))
	SB1->(dbSeek(xFilial('SB1')+D3V->D3V_CODPROD))
    aTransf	:= {}
    cNumDoc:= nextnumero("SD3",2,"D3_DOC",.t.)
	aadd (aTransf,{ cNumDoc, ddatabase})
    nCount++
    aAdd(aTransf,{})

    aTransf [nCount]:=   {{"D3_COD"   ,D3V->D3V_CODPROD             		,NIL}}  
    aAdd(aTransf[nCount],{"D3_DESCRI" , SB1->B1_DESC               	    	,NIL}) 
    aAdd(aTransf[nCount],{"D3_UM"     , D3V->D3V_UM                   		,NIL}) 
    aAdd(aTransf[nCount],{"D3_LOCAL"  , D3V->D3V_LOCORI                     ,NIL}) 
    aAdd(aTransf[nCount],{"D3_LOCALIZ", D3V->D3V_LCZORI                     ,NIL}) 
    //Destino
    aAdd(aTransf[nCount] ,{"D3_COD"    , D3V->D3V_CODPROD            	  	,NIL}) 
    aAdd(aTransf[nCount] ,{"D3_DESCRI" , SB1->B1_DESC               		,NIL}) 
    aAdd(aTransf[nCount] ,{"D3_UM"     , D3V->D3V_UM                  	  	,NIL}) 
    aAdd(aTransf[nCount] ,{"D3_LOCAL"  , D3V->D3V_LOCDES                    ,NIL}) 
    aAdd(aTransf[nCount] ,{"D3_LOCALIZ", D3V->D3V_LCZDES                 	,NIL}) 
    
    //Origem
    aAdd(aTransf[nCount],{"D3_NUMSERI", D3V->D3V_NUMSER                     ,NIL})
    aAdd(aTransf[nCount],{"D3_LOTECTL", D3V->D3V_LOTECT                		,NIL})
    aadd(aTransf[nCount],{"D3_NUMLOTE", ""                                  ,Nil}) 
    aAdd(aTransf[nCount],{"D3_DTVALID", D3V->D3V_DTVLD     					,NIL}) 
    
    aAdd(aTransf[nCount],{"D3_POTENCI", criavar("D3_POTENCI")               ,NIL}) 
    aAdd(aTransf[nCount],{"D3_QUANT"  , D3V->D3V_QTDE                  		,NIL}) 
    aAdd(aTransf[nCount],{"D3_QTSEGUM", criavar("D3_QTSEGUM")      	        ,NIL}) 
    aAdd(aTransf[nCount],{"D3_ESTORNO", criavar("D3_ESTORNO")      	        ,NIL}) 
    aAdd(aTransf[nCount],{"D3_NUMSEQ" , criavar("D3_NUMSEQ")		  	    ,NIL}) 
    
    //Destino
    aAdd(aTransf[nCount],{"D3_LOTECTL", D3V->D3V_LOTECT                     ,NIL})
    aadd(aTransf[nCount],{"D3_NUMLOTE", " "                                 , Nil})
    aAdd(aTransf[nCount],{"D3_DTVALID", D3V->D3V_DTVLD    				    ,NIL})

  	lMsErroAuto := .F.
    MSExecAuto({|x,y| mata261(x,y)},aTransf,3)
    If lMsErroAuto
    	lRet := .F.
		cMsgErro := MostraErro(cPath,cFile) 
		MSgAlert( cMsgErro )
	Else
        Reclock("D3V",.F.)
		D3V->(dbDelete())
		D3V->(msUnlock())
        MSGAlert(STR0055 + cNumDoc + STR0056) //"Realizada Transferência, número : "   " , pode ser consultada na rotina de transferência de armazém "
    Endif
    nCount:=0
EndIf
    //Atualza a tela
oBrwRef:Refresh ( .T. )

Return 



//-------------------------------------------------------------------
/*/{Protheus.doc} Invent
divergencia do inventario    
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function Invent(oWaMain)

Local oPanel    := oWaMain:GetPanel( "WDGT01" )
Local aSize         := {}
Local aLegend       := {}
Local aFields       := {}
Local nX            := 0
Local oWorkArea     := Nil
Local oWDGT01       := Nil
Local oTopBar       := Nil
Local aSizeWg1      := {}
Local oFont         := Nil
Local oFont2        := Nil
Local oFont3        := Nil
Local oSayTitle     := Nil
Local oSayTitle2    := Nil
Local oCoverPanel   := Nil
Local oTextDesc     := Nil
Local oGroupX       := Nil 
Local oGroup1       := Nil
Local oGroup2       := Nil
Local oWDGT02       := Nil
Local oWDGT03       := Nil
Local oGetPrblm     := Nil

TelaBrWPad(@oPanel,@oFont,@oFont2,@oTopBar,@aSize,@aSizeWg1,@oWorkArea,@oWDGT01,"INV")
FilaFields("INV",@aFields,@aLegend)
TPainelBrw(@oCoverPanel,@oCoverPanel,@oTextDesc,@oWDGT01)
TPainelCFG(@oWorkArea,@oGroup1,@oGroup2,@oWDGT01,@oWDGT02,@oWDGT03,@oGroupX,"INV")

oBrwRef := FWMBrowse():New()
oBrwRef:SetAlias("D3V")
oBrwRef:Setfields(aFields)
oBrwRef:SetFilterDefault( "D3V_ORIGEM =='3'" )
oBrwRef:DisableReport()
oBrwRef:DisableDetails()

MenuSoluc(oGroup2,'INV',@oBrwRef)

For nX := 1 To Len(aLegend)
    oBrwRef:AddLegend(aLegend[nX,1],aLegend[nX,2],aLegend[nX,3])
Next nX

oBrwRef:Activate(oGroupX)
lBuildBrw := .T.

Return

 

//-------------------------------------------------------------------
/*/{Protheus.doc} RecontNot
Ajusta a contagem da conferencia depois de criado cadastro de produto    
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------

Static Function RecontNot(oBrwRef)

Local cAliasB1  := CriaTrab(Nil,.F.)
Local cID       := Space(10)
Local lAchouPRD := .T.
Local lRet      := .T.
Local lPesqSA5  	:= SuperGetMv("MV_CBSA5",.F.,.F.)

Private cProduto  := Iif(D3V->D3V_CODPROD <> NIL,D3V->D3V_CODPROD," ")
Private cNota     := Iif(D3V->D3V_NOTA    <> NIL,D3V->D3V_NOTA,   " ")
Private cSerie    := Iif(D3V->D3V_SERIE   <> NIL,D3V->D3V_SERIE,  " ")
Private cFornec   := Iif(D3V->D3V_FORNEC  <> NIL,D3V->D3V_FORNEC, " ")
Private cLoja     := Iif(D3V->D3V_LOJA    <> NIL,D3V->D3V_LOJA ,  " ")
Private cLote     := Iif(D3V->D3V_LOTECT  <> NIL,D3V->D3V_LOTECT, " ")
Private dValid    := Iif(D3V->D3V_DTVLD   <> NIL,D3V->D3V_DTVLD,  STOD('//')) 
Private nQuant    := Iif(D3V->D3V_QTDE    <> NIL,D3V->D3V_QTDE ,    0)
Private cCodOpe   := Iif(D3V->D3V_CODUSR  <> NIL,D3V->D3V_CODUSR ," ")
Private cOrig     := Iif(D3V->D3V_ORIGEM  <> NIL,D3V->D3V_ORIGEM ," ")
Private cCodBar   := Iif(D3V->D3V_CODBAR  <> NIL,D3V->D3V_CODBAR ," ")

If EMPTY(cProduto) .And. EMPTY(cCodBar)
    lRet := .F.
elseif EMPTY(cProduto)
   cProduto := cCodBar 
EndIf 

If lRet                                                                        
    BeginSQL Alias cAliasB1

    SELECT B1_COD
    FROM 
        %Table:SB1% SB1
    WHERE 
        SB1.B1_FILIAL = %xFilial:SB1%
        AND (SB1.B1_CODBAR	= %Exp:cProduto% OR SB1.B1_COD	= %Exp:cProduto%)
        AND SB1.%NotDel%
    EndSQL	
            
    If (cAliasB1)->(!EOF())		
        cProduto := (cAliasB1)->B1_COD	
    Else
        SA5->(dbSetorder(8)) //A5_CODBAR
        If lPesqSA5 .and. SA5->(dbSeek(padr(xFilial("SA5"),TAMSX3("A5_FILIAL")[1])+cFornec+cLoja+Padr(AllTrim(cProduto),TamSX3("A5_CODBAR")[1])))
            cProduto := SA5->A5_PRODUTO
            SB1->(DbSetOrder(1))
            If !SB1->(DBSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+cProduto))
                lAchouPRD	:= .F.
            Endif
        Else
            SLK->( dbSetOrder(1) )
            If SLK->( DBSeek(padr(xFilial("SLK"),TAMSX3("LK_FILIAL")[1])+cProduto) )
                cProduto := SLK->LK_CODIGO				
                If !SB1->(DBSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+cProduto))
                    lAchouPRD	:= .F.
                Endif
            Else
                lAchouPRD	:= .F.
            Endif
        Endif

    Endif
    (cAliasB1)->(dbCloseArea())


    If lAchouPRD
        SF1->(DbSetOrder(1))
        If SF1->( DbSeek( padr(xFilial("SF1"),TAMSX3("F1_FILIAL")[1])+cNota+cSerie+cFornec+cLoja) )
            If  SF1->F1_STATCON <> '1'
                DistQtdConf(cProduto,nQuant,NIL,cLote,dValid,cNota,cSerie,cFornec,cLoja,.T.)
                GrVCBE(cID,cProduto,nQuant,cLote,dValid)
                StatusSF1(cNota,cSerie,cFornec,cLoja,.T.)
                If SF1->F1_STATCON == '1'
                    D3V->(DbSetOrder(2))
                    While D3V->( !Eof() .And. ((xFilial('D3V')+cOrig+cNota+cSerie+cFornec+cLoja) == (D3V->(xFilial('D3V')+D3V_ORIGEM+D3V_NOTA+D3V_SERIE+D3V_FORNEC+D3V_LOJA))))
                        Reclock("D3V",.F.)
                        D3V->(dbDelete())
                        D3V->(msUnlock())
                        D3V->(DbSkip())  
                    EndDo
                EndIf 
                MSGAlert(STR0057)//"Realizada conferencia"
            Else
            lRet:=Aviso(OemToAnsi(STR0034),STR0048,{OemToAnsi(STR0039),OemToAnsi(STR0040)}) == 1 //'Não será possível ajuste pois a conferencia foi finalizada, apagar o log de divergência?'
                If lRet
                    Reclock("D3V",.F.)
                    D3V->(dbDelete())
                    D3V->(msUnlock())
                    D3V->(DbSkip())  
                EndIf
            Endif
        Else
            lRet:=Aviso(OemToAnsi(STR0034),STR0049,{OemToAnsi(STR0039),OemToAnsi(STR0040)}) == 1 //'A PreNota/Documento ja consta como liberada, o log de registro de divergencia pode ser apagado.?'
            If lRet
                Reclock("D3V",.F.)
                D3V->(dbDelete())
                D3V->(msUnlock())
            EndIf
        EndIf 
    Else
        lRet:=Aviso(OemToAnsi(STR0013),STR0050,{OemToAnsi(STR0039),OemToAnsi(STR0040)}) == 1 //'Produto não localizado, apagar o log de registro de divergencia, pois foi gerado incorretamente?'
        If lRet
            Reclock("D3V",.F.)
            D3V->(dbDelete())
            D3V->(msUnlock())
        EndIf
    EndIf
EndIf
//Atualiza a tela 
 oBrwRef:Refresh ( .T. )


Return




//-------------------------------------------------------------------
/*/{Protheus.doc} TelaBrWPad
Monta browser principal dentro da WorkArea   
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function TelaBrWPad(oPanel,oFont,oFont2,oTopBar,aSize,aSizeWg1,oWorkArea,oWDGT01X,cRotina)
Local nHeight := 0

oPanel:freeChildren()

aSize     := FWGetDialogSize( oPanel )
oWorkArea := FWUIWorkArea():New( oPanel )

nHeight := aSize[3] - 130

oWorkArea:CreateHorizontalBox( "LINE01X", 100, .T. )
oWorkArea:SetBoxCols( "LINE01X", { "WDGT01X" } )

// Tratamento para não criar os box inferiores referentes a problema e solução 
If cRotina != "END"
    nHeight := nHeight / 2
EndIf

oWorkArea:CreateHorizontalBox( "LINE01", nHeight, .T. )
oWorkArea:SetBoxCols( "LINE01", { "WDGT01" } )

If cRotina != "END"
    oWorkArea:CreateHorizontalBox( "LINE02", nHeight , .T. )
    oWorkArea:SetBoxCols( "LINE02", { "WDGT02","WDGT03" } )
EndIf

oWorkArea:Activate()

oWDGT01X := oWorkArea:GetPanel("WDGT01X")
aSizeWg1 := FWGetDialogSize( oWDGT01X )

oTopBar := TPanel():New( 0 , 0 ,,oWDGT01X,,,,,, aSizeWg1[4]-2.5, 40.4) 
oTopBar:SetCss( FWGetCSS( GetClassName(oTopBar), CSS_FORMBAR_TOP_BG ) ) 

oFont := TFont():New("Arial",,-20,,.T.,,,,,,.F.)	
oFont2 := TFont():New("Arial",,-10,,.T.,,,,,,.F.)


If cRotina == "CONF"
    oSayTitle:=TSay():New(10,10,{|| STR0021 },oTopBar,,oFont,,,,.T.,,,300,20,,,,,,.T.)//"Divergencia conferencia de Pré nota/Documento de entrada"
    oSayTitle:SetCss("background-color : transparent; color: #0B9BBF}")

ElseIf cRotina == "TRANS"
    oSayTitle:=TSay():New(10,10,{|| STR0023 },oTopBar,,oFont,,,,.T.,,,300,20,,,,,,.T.) //"Divergencia Transferencia entre armazéns"
    oSayTitle:SetCss("background-color : transparent; color: #0B9BBF}")
ElseIf cRotina == "INV"
    oSayTitle:=TSay():New(10,10,{|| STR0022 },oTopBar,,oFont,,,,.T.,,,300,20,,,,,,.T.) //"Divergencia inventario"
    oSayTitle:SetCss("background-color : transparent; color: #0B9BBF}")
ElseIf cRotina == "END"
    oSayTitle := TSay():New( 10, 10, {|| STR0059 }, oTopBar, , oFont, , , , .T., , , 300, 20, , , , , , .T. ) //"Divergência de endereçamento"
    oSayTitle:SetCss( "background-color : transparent; color: #0B9BBF}" )
EndIf

Return 



//-------------------------------------------------------------------
/*/{Protheus.doc} FilaFields
Prioriza campos de acordo com a rotina  

@param cRotina, caracter, opção do menu
@param @aFields, array, vetor com a estrutura dos campos a visualizar no browse
@param @aLegend, arrray, vetor com as legendas
@param aList, array, vetor com a lista de campos

@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function FilaFields(cRotina, aFields, aLegend, aList)
Default aList := {}

If cRotina == "CONF"
    Aadd(aFields,{FWX3Titulo('D3V_NOTA')    ,'D3V_NOTA' ,'C',TamSx3('D3V_NOTA')[1]  ,Nil                    ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_SERIE')   ,'D3V_SERIE' ,'C',TamSx3('D3V_SERIE')[1]  ,Nil                  ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_FORNEC')  ,'D3V_FORNEC' ,'C',TamSx3('D3V_FORNEC')[1]  ,Nil                ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_LOJA')    ,'D3V_LOJA' ,'C',TamSx3('D3V_LOJA')[1]  ,Nil                    ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_QTDE')    ,'D3V_QTDE' ,'C',TamSx3('D3V_QTDE')[1]  ,Nil                    ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_DATA')    ,'D3V_DATA' ,'C',TamSx3('D3V_DATA')[1]  ,Nil                    ,'@!'})

    Aadd(aLegend,{'D3V_STATUS == "1" ' ,"RED"  , STR0052 })//"Código do item não localizado"

ElseIf cRotina == "TRANS"
    Aadd(aFields,{FWX3Titulo('D3V_CODPROD')    ,'D3V_CODPROD' ,'C',TamSx3('D3V_CODPROD')[1]  ,Nil ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_DESCRI')    ,'D3V_DESCRI' ,'C',TamSx3('D3V_DESCRI')[1]  ,Nil ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_LOCORI')   ,'D3V_LOCORI' ,'C',TamSx3('D3V_LOCORI')[1]  ,Nil  ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_QTDE')  ,'D3V_QTDE' ,'N',TamSx3('D3V_QTDE')[1]  ,Nil         ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_DATA')    ,'D3V_DATA' ,'D',TamSx3('D3V_DATA')[1]  ,Nil       ,'@!'})

    Aadd(aLegend,{'D3V_MOTIVO == "2" ' ,"RED"      , STR0054})//Saldo Divergente
    Aadd(aLegend,{'D3V_MOTIVO == "3"'  ,"YELLOW"   , STR0053})//Bloqueio por inventario
    Aadd(aLegend,{'D3V_MOTIVO == "1"'  ,"WHITE"     ,STR0052})//"Código do produto não localizado"
Elseif cRotina == "INV"
    Aadd(aFields,{FWX3Titulo('D3V_CODINV')    ,'D3V_CODINV','C',TamSx3('D3V_CODINV')[1]  ,Nil  ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_CODBAR')    ,'D3V_CODBAR','C',TamSx3('D3V_CODBAR')[1]  ,Nil  ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_QTDE')      ,'D3V_QTDE'  ,'N',TamSx3('D3V_QTDE')[1]    ,Nil  ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_DATA')      ,'D3V_DATA'  ,'D',TamSx3('D3V_DATA')[1]    ,Nil  ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_LOTECT')    ,'D3V_LOTECT','C',TamSx3('D3V_LOTECT')[1]  ,Nil  ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_CODPRO')    ,'D3V_CODPRO','C',TamSx3('D3V_CODPRO')[1]  ,Nil  ,'@!'})
    Aadd(aFields,{FWX3Titulo('D3V_DESCRI')    ,'D3V_DESCRI','C',TamSx3('D3V_DESCRI')[1]  ,Nil  ,'@!'})

    Aadd(aLegend,{'D3V_MOTIVO == "1" ' ,"RED"      , STR0052})//"Código do item não localizado"

Elseif cRotina == "END"
    aFields := FieldsInfo( aList )
   
    Aadd( aLegend, { 'D3V_MOTIVO == "5"', "ORANGE", STR0060 } )  //"Inconsistência no modelo" 
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} FilaFields
Cria painel principal para colocar as opções de menu 
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
 Static Function TPainelBrw(oCoverPanel,oCoverPanel,oTextDesc,OWDGT01)

oCoverPanel := TPanelCss():New(0,0,"",oWDGT01,,.F.,.F.,,,oWDGT01:nWidth/2,oWDGT01:nHeight/2,.T.,.F.)
oCoverPanel:SetCSS("TPanelCss { background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; }")

oTextDesc := tSimpleEditor():New((oWDGT01:nHeight/2)-55,(oWDGT01:nWidth/4)-10, oCoverPanel,240,100,,.T.,,,.T. )
oTextDesc:Setcss("color: #757776; background-color : transparent; border: none; font-size: 60px;") 
oTextDesc:Load("<strong>&#9786;</strong>")

oTextDesc := tSimpleEditor():New((oWDGT01:nHeight/4)-30,(oWDGT01:nWidth/4)-115, oCoverPanel,240,100,,.T.,,,.T. )
oTextDesc:Setcss("color: #757776; background-color : transparent; border: none; font-size: 25px;") 
oTextDesc:Load("<br /><strong>"+STR0024+"</strong>")//Não existem itens para serem exibidos.

oCoverPanel:Hide()

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} TPainelCFG
Criar o espaço para colocar as informações do painel. 
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
 Static Function TPainelCFG(oWorkArea,oGroup1,oGroup2,oWDGT01,oWDGT02,oWDGT03,oGroupX,cRotina)

 Local oSayTitle := Nil
 Local oSayTitle2:= Nil
 Local oGetPrblm := Nil
 Local oFont3    := Nil
 Local cTexto    := " "

 If cRotina == "CONF"
   cTexto:= "<p><h3>"+STR0028+"</b></h3></p>"//Situações de divergencia:
   cTexto+="<p> "+STR0025+"<b>"+STR0026+"</b></p>" //Antes de iniciar um conferencia certifique-se que todos os itens estão devidamente cadastrados na rotina de //
   cTexto+="<p> "+STR0027+"</b></p>" //"A rotina Cadastro de Produto está disponível no menu <b>SIGAEST ->Atualizações ->Cadastros ->Produtos
ElseIf cRotina == "TRANS"
   cTexto:= "<p><h3>"+STR0028+"</b></h3></p>"//Situações de divergencia:
   cTexto+= "<p>"+STR0029+"</p>"//- Verifique o saldo do produto pois não foi possivel realizar a transferencia, caso necessário ajuste de saldo, pode ser realizado inventário ou outra medida que seja de praxe da empresa.
   cTexto+= "<p>"+STR0030+"</p>"//- Produto com bloqueio de inventário não pode ser movimento, ao termino do mesmo utilize o recurso de reprocessamento ára concluirmos a transferencia
   cTexto+= "<p>"+STR0031+"</p>"//Execute a consulta Saldo Atual disponível no menu SIGAEST->Atualizações-> Saldos-> Atual, localize o produto e verifique as colunas de Quantidade
Else
   cTexto:= "<p><h3>"+STR0028+"</b></h3></p>"//Situações de divergencia:
   cTexto+= "<p>"+STR0044+"</p>"//- Antes de iniciar um inventário certifique-se que todos os itens estão devidamente cadastrados na rotina de Cadastro de produto.
   cTexto+= "<p>"+STR0045+"</p>"//- A rotina Cadastro de Produto está disponível no menu SIGAEST ->Atualizações ->Cadastros ->Produtos
EndIf
  
oWDGT01 := oWorkArea:GetPanel("WDGT01")
oGroupX := TPanelCss():New(0,0,"",oWDGT01,,.F.,.F.,,,oWDGT01:nWidth/2,oWDGT01:nHeight/2,.T.,.F.) 

// Tratamento para não criar os box inferiores referentes a problema e solução 
If cRotina != "END"
    oWDGT02 := oWorkArea:GetPanel("WDGT02")

    oFont3 := TFont():New("Arial",,-12,,.T.,,,,,,.F.)
    oSayTitle:= TSay():New(0,0,{|| ""},oWDGT02,,oFont3,,,,.T.,,,oWDGT02:nWidth/2,15,,,,,,.T.)
    oSayTitle:SetCss("background-color : #E9F0F6; border-top-left-radius: 4px; border-top-right-radius: 4px;}")

    oSayTitle2:= TSay():New(4,4,{||STR0042 },oWDGT02,,oFont3,,,,.T.,,,100,20,,,,,,.T.) //"Descrição do Problema"
    oSayTitle2:SetCss("background-color : transparent; color : #757776;}")

    oGroup1 := TPanelCss():New(18,0,"",oWDGT02,,.F.,.F.,,,oWDGT02:nWidth/2,(oWDGT02:nHeight/2)-18,.T.,.F.)
    nHeightPrbl := 0

    oGetPrblm := tSimpleEditor():New(0, 0, oGroup1 ,(oGroup1:nWidth/2) , (oGroup1:nHeight/2)-nHeightPrbl,,.T.,,,.T. )
    oGetPrblm:Load(cTexto)
    oGetPrblm:Setcss("background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; ") 


    oWDGT03 := oWorkArea:GetPanel("WDGT03")

    oFont3 := TFont():New("Arial",,-11,,.T.,,,,,,.F.)

    oSayTitle:= TSay():New(0,0,{|| ""},oWDGT03,,oFont3,,,,.T.,,,oWDGT03:nWidth/2,15,,,,,,.T.)

    oSayTitle:SetCss("background-color : #E9F0F6; border-top-left-radius: 4px; border-top-right-radius: 4px;}")

    oSayTitle2:= TSay():New(4,4,{|| STR0043},oWDGT03,,oFont3,,,,.T.,,,100,20,,,,,,.T.)//"O que verificar?"

    oSayTitle2:SetCss("background-color : transparent; color : #757776}")

    oGroup2 := TPanelCss():New(18,0,"",oWDGT03,,.F.,.F.,,,oWDGT03:nWidth/2,(oWDGT03:nHeight/2)-18,.T.,.F.)
    oGroup2:SetCSS("TPanelCss { background-color : #E9F0F6; border-radius: 4px; border: 1px solid #DCDCDC; }")
EndIf
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} CloseScreen
Monta tela de saída
@author André Maximo
@since  Maio 06, 2019
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
    
oSay := TSay():New(4,4,{|| STR0032},oContainer,,,,,,.T.,,,98,98,,,,,,.T.)//"Deseja realmente sair do programa? "

oModal:Activate()

If oModal:getButtonSelected()
    lRet := .T.
EndIf

Return lRet



//-------------------------------------------------------------------
/*/{Protheus.doc} GrVCBE
Grava dados na tabela CBE apois ter conseguido 
incluir dados da conferencia 
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GrVCBE(cID,cProduto,nQuant,cLote,dValid)

If	CBE->(DBSeek(xFilial("CBE")+cID+cNota+cSerie+cFornec+cLoja+cProduto+cLote+dtos(dValid)))
    If ! UsaCB0("01")
        RecLock("CBE",.f.)
        CBE->CBE_CODUSR	:= cCodOpe
        CBE->CBE_DATA	:= dDatabase
        CBE->CBE_HORA	:= Time()
        CBE->CBE_QTDE   += nQuant
        CBE->(MsUnLock())
    EndIf
Else
    RecLock("CBE",.t.)
    CBE->CBE_FILIAL	:= xFilial("CBE")
    CBE->CBE_NOTA	:= cNota
    CBE->CBE_SERIE  := cSerie
    CBE->CBE_FORNEC	:= cFornec
    CBE->CBE_LOJA	:= cLoja
    CBE->CBE_CODPRO	:= cProduto
    CBE->CBE_QTDE	:= nQuant
    CBE->CBE_LOTECT	:= cLote
    CBE->CBE_CODUSR	:= cCodOpe
    CBE->CBE_DTVLD	:= dValid
    CBE->CBE_CODETI	:= cID
    CBE->CBE_DATA	:= dDatabase
    CBE->CBE_HORA	:= Time()
    CBE->(MsUnLock())
EndIf

Return




//-------------------------------------------------------------------
/*/{Protheus.doc} GrvCBA()
Função para gravar inventario de produto
@author Totvs
@since 13/12/2016
@version P118
@return nil
/*/
//-------------------------------------------------------------------
Function GrvCBA(aLog)

Default aLog	:= { }

Pergunte("AIA032",.F.)

cCodInv := GetSXENum("CBA","CBA_CODINV")
RecLock("CBA",.T.)
CBA->CBA_Filial := xFilial("CBA")
CBA->CBA_CODINV := cCodInv
CBA->CBA_DATA   := dDatabase
CBA->CBA_CONTS  := MV_PAR04
CBA->CBA_STATUS := "0"
CBA->CBA_TIPINV := "1"
CBA->CBA_PROD   := cProduto
CBA->CBA_LOCAL  := cArm 
CBA->CBA_CLASSA := Str(MV_PAR07,1)
CBA->CBA_CLASSB := Str(MV_PAR08,1)
CBA->CBA_CLASSC := Str(MV_PAR09,1)
MsUnlock()	
If __lSX8
    ConfirmSx8()
EndIf
//Mestres de Inventario gerados
aadd(aLog,{"AI031","01",CBA_CODINV,cProduto,cArm})

Return nil


//-------------------------------------------------------------------
/*/{Protheus.doc} RecontNot
Ajusta a contagem da conferencia depois de criado cadastro de produto    
@author André Maximo
@since  Maio 06, 2019
@version 12.1.17
/*/
//-------------------------------------------------------------------
*/
Static Function RecontInv(oBrwRef)

Local cAliasB1  := CriaTrab(Nil,.F.)
Local lAchouPRD := .T.
Local lPesqSA5  := SuperGetMv("MV_CBSA5",.F.,.F.)
Local lRet      := .T.
Local aLog      := { } 
Local nRet      := 0

Private cProduto  := Iif(D3V->D3V_CODPROD <> NIL,D3V->D3V_CODPROD," ")
Private cLote     := Iif(D3V->D3V_LOTECT  <> NIL,D3V->D3V_LOTECT, " ")
Private dValid    := Iif(D3V->D3V_DTVLD   <> NIL,D3V->D3V_DTVLD,  STOD('//')) 
Private nQuant    := Iif(D3V->D3V_QTDE    <> NIL,D3V->D3V_QTDE ,    0)
Private cCodOpe   := Iif(D3V->D3V_CODUSR  <> NIL,D3V->D3V_CODUSR ," ")
Private cOrig     := Iif(D3V->D3V_ORIGEM  <> NIL,D3V->D3V_ORIGEM ," ")
Private cCodInv   := Iif(D3V->D3V_CODINV  <> NIL,D3V->D3V_CODINV ," ")
Private cEnd      := Iif(D3V->D3V_LCZORI  <> NIL,D3V->D3V_LCZORI ," ")
Private cSer      := Iif(D3V->D3V_NUMSER  <> NIL,D3V->D3V_NUMSER ," ")
Private cArm      := Iif(D3V->D3V_LOCORI  <> NIL,D3V->D3V_LOCORI ," ")
Private cNum      := Iif(D3V->D3V_NUMINV  <> NIL,D3V->D3V_NUMINV ," ")
Private cCodBar   := Iif(D3V->D3V_CODBAR  <> NIL,D3V->D3V_CODBAR ," ")

If EMPTY(cProduto) .And. EMPTY(cCodBar)
    lRet := .F.
elseif EMPTY(cProduto)
   cProduto := cCodBar 
EndIf 
If lRet                                                                         
    BeginSQL Alias cAliasB1

    SELECT B1_COD
    FROM 
        %Table:SB1% SB1
    WHERE 
        SB1.B1_FILIAL = %xFilial:SB1%
        AND (SB1.B1_CODBAR	= %Exp:cProduto% OR SB1.B1_COD	= %Exp:cProduto%)
        AND SB1.%NotDel%
    EndSQL	
            
    If (cAliasB1)->(!EOF())		
        cProduto := (cAliasB1)->B1_COD	
    Else
        SA5->(dbSetorder(8)) //A5_CODBAR
        If lPesqSA5 .and. SA5->(dbSeek(padr(xFilial("SA5"),TAMSX3("A5_FILIAL")[1])+cFornec+cLoja+Padr(AllTrim(cProduto),TamSX3("A5_CODBAR")[1])))
            cProduto := SA5->A5_PRODUTO
            SB1->(DbSetOrder(1))
            If !SB1->(DBSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+cProduto))
                lAchouPRD	:= .F.
            Endif
        Else
            SLK->( dbSetOrder(1) )
            If SLK->( DBSeek(padr(xFilial("SLK"),TAMSX3("LK_FILIAL")[1])+cProduto) )
                cProduto := SLK->LK_CODIGO				
                If !SB1->(DBSeek(padr(xFilial("SB1"),TAMSX3("B1_FILIAL")[1])+cProduto))
                    lAchouPRD	:= .F.
                Endif
            Else
                lAchouPRD	:= .F.
            Endif
        Endif

    Endif
    (cAliasB1)->(dbCloseArea())

    If lAchouPRD
        CBA->(dbSetOrder(1))
        If CBA->(dbSeek(PADR(xFilial('CBA'),TamSX3("CBA_FILIAL")[1])+cCodInv))
            If CBA->CBA_STATUS =="1" 
            
                CBC->(dbSetOrder(2))                                                            
                If CBC->(dbSeek(xFilial('CBC')+cNum+cProduto+cArm+cEnd+cLote))
                    RecLock('CBC',.F.)
                    IiF(CBC->CBC_QUANT == 0,  CBC->CBC_QUANT:= D3V->D3V_QTDE, CBC->CBC_QUANT+= D3V->D3V_QTDE)
                    CBC->(msUnlock())

                    CBB->(dbSetOrder(3))                                                                                                                  
                    If CBB->(dbSeek(xFilial('CBB')+cCodInv+cNum))
                        RecLock('CBB',.F.)
                        CBB->CBB_STATUS :='2'
                        CBB->(msUnlock())
                    EndIf

                    ACD35CBM(3,cCodInv,cProduto,cArm,cEnd,cLote)
                    Reclock("D3V",.F.)
                    D3V->(dbDelete())
                    D3V->(msUnlock())
                EndIf
            Else
                nRet := Aviso(OemToAnsi(STR0034),STR0035 ,{OemToAnsi(STR0036),OemToAnsi(STR0037),OemToAnsi(STR0007)}) //documento , O Status do inventário não permite mais movimentações, Deseja criar um novo mestre de inventário para o produto ou apagar o log de divergência?, apagar Log
                If nRet == 1 
                    GrvCBA(@aLog)
                ElseIf nRet == 2
                    Reclock("D3V",.F.)
                    D3V->(dbDelete())
                    D3V->(msUnlock())
                EndIf
            EndIf
        Else
            lRet:=Aviso(OemToAnsi(STR0034),STR0038,{OemToAnsi(STR0039),OemToAnsi(STR0040)}) == 1 //Documento, 'O inventário não foi localizado, Deseja apagar o log de divergencia ?' , Sim, Não
            If lRet 
            Reclock("D3V",.F.)
            D3V->(dbDelete())
            D3V->(msUnlock())
            EndIf
        EndIf     
    Else
        lRet:=Aviso(OemToAnsi(STR0013),STR0041,{OemToAnsi(STR0039),OemToAnsi(STR0040)}) == 1 // Produto , 'Produto não localizado, apagar o log de registro de divergencia, pois foi gerado incorretamente?', Sim , Não
        If lRet
            Reclock("D3V",.F.)
            D3V->(dbDelete())
            D3V->(msUnlock())
        EndIf
    EndIf
EndIf

//Atualiza a tela 
 oBrwRef:Refresh ( .T. )
 
Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} Enderec
Tela de endereçamento

@param oWaMain, object, tela onde os componentes serão gerados

@author Marcia Junko
@since  15/03/2021
/*/
//-------------------------------------------------------------------
Static Function Enderec( oWaMain )

    Local oPanel    := oWaMain:GetPanel( "WDGT01" )
    Local aSize         := {}
    Local aLegend       := {}
    Local aFields       := {}
    Local aList         := { 'D3V_IDENT', 'D3V_INFO', 'D3V_DATA', 'D3V_HORA', 'D3V_CODUSR', 'D3V_NOMUSR' }
    Local nX            := 0
    Local oWorkArea     := Nil
    Local oWDGT01       := Nil
    Local oTopBar       := Nil
    Local aSizeWg1      := {}
    Local oFont         := Nil
    Local oFont2        := Nil
    Local oCoverPanel   := Nil
    Local oTextDesc     := Nil
    Local oGroupX       := Nil 
    Local oGroup1       := Nil
    Local oGroup2       := Nil
    Local oWDGT02       := Nil
    Local oWDGT03       := Nil

    TelaBrWPad( @oPanel, @oFont, @oFont2, @oTopBar, @aSize, @aSizeWg1, @oWorkArea, @oWDGT01, "END" )
    FilaFields( "END", @aFields, @aLegend, aList )
    TPainelBrw( @oCoverPanel, @oCoverPanel, @oTextDesc, @oWDGT01 )
    TPainelCFG( @oWorkArea, @oGroup1, @oGroup2, @oWDGT01, @oWDGT02, @oWDGT03, @oGroupX, "END" )

    oBrwRef := FWMBrowse():New()
    oBrwRef:SetAlias( "D3V" )
    oBrwRef:Setfields( aFields )
    oBrwRef:SetOnlyFields( aList )
    oBrwRef:SetFilterDefault( "D3V_ORIGEM =='5'" )
    oBrwRef:DisableReport()
    
    For nX := 1 To Len( aLegend )
        oBrwRef:AddLegend( aLegend[ nX, 1 ], aLegend[ nX, 2 ], aLegend[ nX, 3 ] )
    Next nX

    oBrwRef:Activate( oGroupX )

    // Força que o painel de detalhes seja apresesentado logo na abertura da tela.
    Eval( oBrwRef:oBrowseUI:oBtnSplit:bAction )
    
    lBuildBrw := .T.

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} ACDM020GRV
Função responsável por gravar os dados de divergência na tabela D3V 
em ações realizadas pelo app Meu Coletor. 

@param aData, array, vator com os dados a gravar

@author Marcia Junko
@since 15/03/2021
/*/
//-------------------------------------------------------------------
Function ACDM020GRV( aData )
    Local aSvAlias := GetArea()
    Local nI := 0 

    IF Ascan( aData, {|x| x[1] == 'D3V_FILIAL' } ) == 0
        Aadd( aData, { 'D3V_FILIAL', xFilial( "D3V" ) } )
    EndIf

    IF Ascan( aData, {|x| x[1] == 'D3V_CODIGO' } ) == 0
        Aadd( aData, { 'D3V_CODIGO', GetSXENum( "D3V", "D3V_CODIGO" ) } )
    EndIf

    IF Ascan( aData, {|x| x[1] == 'D3V_CODUSR' } ) == 0
        Aadd( aData, { 'D3V_CODUSR', __cUserId } )
    EndIf

    IF Ascan( aData, {|x| x[1] == 'D3V_DATA' } ) == 0
        Aadd( aData, { 'D3V_DATA', dDatabase } )
    EndIf
    
    IF Ascan( aData, {|x| x[1] == 'D3V_HORA' } ) == 0
        Aadd( aData, { 'D3V_HORA', Time() } )
    EndIf

    IF !Empty( aData )
        Reclock( "D3V", .T. )
            For nI := 1 to len( aData )
                D3V->( FieldPut( FieldPos( Trim( aData[nI][1] ) ), aData[nI][2] ) )
            Next
        D3V->( MsUnLock() )
    EndIf

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
Return


//----------------------------------------------------------------------------------
/*/{Protheus.doc} FieldsInfo
Função responsável por montar a estrutura do vetor com os dados do campo

@param aFields, array, lista de campos para pesquisa

@return array, vetor com os dados relativo aos campos passados no parâmetro, onde:
    [1] = Título
    [2] = Nome do campo
    [3] = Tipo do campo
    [4] = Tamanho do campo
    [5] = Reservado
    [6] = Picture
@author Marcia Junko
@since 15/03/2021
/*/
//----------------------------------------------------------------------------------
Static Function FieldsInfo( aList )
    Local aSvAlias := GetArea()
    Local aInfo := {}
    Local aFields := {}
    Local nI := 0

    For nI := 1 to len( aList )
        SX3->( DBSetOrder(2) )
        If SX3->( MsSeek( aList[ nI ] ) )
            aInfo := FWSX3Util():GetFieldStruct( aList[ nI ] )

            Aadd( aFields, { TRIM( FWX3Titulo( aList[ nI ] ) ), ;   
                Alltrim( aInfo[1] ), ;               
                aInfo[2], ;                          
                aInfo[3], ;                          
                NIL, ;                               
                X3Picture( aList[ nI ] ) } )        
        EndIf
    Next 

    RestArea( aSvAlias )

    FWFreeArray( aSvAlias )
    FWFreeArray( aInfo )
Return aClone( aFields )
