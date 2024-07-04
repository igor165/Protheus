#Include "Average.ch"  
#Include "Protheus.ch" //Nao retirar o Protheus.CH (Falta o parametro HTML no average.ch para o comando SAY)
#INCLUDE "APWizard.ch"

Static Function getTemplates()
aTemplates := {;
               "ETplCOImp",;   //Conta e Ordem - Perfil Importador
               "ETplCOAdq",;   //Conta e Ordem - Perfil Adquirente
               "ETplExpCafe",; //Exportação de Café
               "ETplIntMsgUnica",; // Integração SIGAEEC via mensagem unica 
               "ETpImportCSV";
              }
Return aTemplates

Class EasyTemplate From AvObject
   
   Data cModulo
   Data cFunc
   Data oMenu
   Data cTitulo
   Data cDescription
   Data aUpdates
   Data aParTela
   Data aVarTela
   Data aParValues
   Data cCondSucesso
   Data cLogAtu
   
   Method New()
   Method LoadParams()
   Method AtuParam()
   Method ChkTemplate()
   Method AtuTemplate()
   Method ChkCondSus()
EndClass

Method New(cFunc) Class EasyTemplate
   
   _Super:New()
   Self:setClassName("EasyTemplate")
   
   Self:cModulo := ""
   Self:cFunc   := cFunc
   Self:oMenu   := AvUpdate01():New()
   Self:cTitulo := ""
   Self:cDescription := ""
   Self:aParTela  := {}
   Self:aVarTela := {}
   Self:aParValues:= {}
   Self:aUpdates     := {}
   Self:cCondSucesso := ""
   Self:cLogAtu      := ""
   
Return Self

Method AtuTemplate() Class EasyTemplate
Local lRet := .T.

Self:cLogAtu := ""

//Atualiza Menu
Self:oMenu:Init(,.T.)
lRet := !Self:oMenu:lError

If !lRet
   Self:cLogAtu += Self:oMenu:GetStrErrors()
ElseIf !Empty(Self:oMenu:aWarning)
   Self:cLogAtu += Self:oMenu:GetStrErrors(Self:oMenu:aWarning)
EndIf

lRet := lRet .AND. Self:ChkCondSus()
Return lRet

Method ChkCondSus() Class EasyTemplate
Local lRet := .T.

If !Empty(Self:cCondSucesso)
   TRY
      lRet := Eval(&("{|o| "+Self:cCondSucesso+"}"),Self)
   CATCH
   
   ENDTRY
   
   If Type("__oError") == "O"
      lRet := .F.
      Self:cLogAtu += StrTran(__OError:Errorstack,Chr(10),Chr(13)+Chr(10))
   EndIf
EndIf

Return lRet

Method ChkTemplate() Class EasyTemplate
Local lRet := .T.
Local i
Local oErros, oUpdTpl

Self:aUpdates := {}  // GFP - 11/08/2015 - Para a versão 12, o Template não deve executar updates.
Self:cLogAtu := ""
oErrors := AvObject():New()

oUpdTpl := Self:oMenu:Clone()
oUpdTpl:lSimula := .T.
oUpdTpl:Init(,.T.)

If oUpdTpl:lError
   oErrors:Error("Não será possível configurar o template pois ocorreram erros.")
   oErrors:Error(oUpdTpl:aError)
   lRet := .F.
Else
   If oUpdTpl:lAtualizado .AND. !Empty(oUpdTpl:aError)
      oErrors:Warning(oUpdTpl:aError)
      lRet := .F.
   EndIf 
EndIf

For i := 1 To Len(Self:aUpdates)
   oTesteUpd := AvUpdate01():New()
   oTesteUpd:lSimula := .T.
   
   If FindFunction("U_"+Self:aUpdates[i])
      Eval(&("{|o| U_"+Self:aUpdates[i]+"(o)}"),oTesteUpd)
   
      oTesteUpd:Init(,.T.)
   
      If oTesteUpd:lError
         oErrors:Error("Error ao verificar o update "+Self:aUpdates[i]+"("+oTesteUpd:cTitulo+").")
         oErrors:Error(oTesteUpd:aError)
         lRet := .F.
      Else
         If oTesteUpd:lAtualizado
            oErrors:Warning("U_"+Self:aUpdates[i]+"()"+if(!Empty(oTesteUpd:cTitulo)," - "+oTesteUpd:cTitulo,"")+".")
            lRet := .F.
         EndIf 
      EndIf
   Else
      oErrors:Error("O update "+Self:aUpdates[i]+" não existe neste ambiente. Entre em contato com o suporte para obter uma atualização.")
      lRet := .F.
   EndIf
Next i

If !Empty(oErrors:aError)
   Self:cLogAtu += "Ocorreram erros na verificação do ambiente. Entre em contato com o suporte."+ENTER
   Self:cLogAtu += oErrors:GetStrErrors(oErrors:aError)
   lRet := .F.
EndIf

If !Empty(oErrors:aWarning)
   Self:cLogAtu += "É necessário executar o(s) seguinte(s) update(s) para prosseguir com a configuração do template. Solicite a execução do(s) update(s) para o administrador."+ENTER+ENTER
   Self:cLogAtu += oErrors:GetStrErrors(oErrors:aWarning) 
   lRet := .F.
EndIf

Return lRet

Method AtuParam() Class EasyTemplate
Local i

For i := 1 To Len(Self:aParTela)
   If ValType(&(AllTrim(Self:aParTela[i]))) == "C"
      SetMV(Self:aParTela[i],&(AllTrim(Self:aParTela[i])))
   EndIf
Next i

For i := 1 To Len(Self:aParValues)
   If ValType(AllTrim(Self:aParValues[2])) == "C"
      SetMV(Self:aParValues[i][1],Self:aParValues[i][2])
   EndIf
Next i

Return Nil

Method LoadParams() Class EasyTemplate
Local aGetParams := {}
Local i

For i := 1 To Len(Self:aParTela)
   EasyGParam(Self:aParTela[i])
   If SX6->(!EoF())
      _SetNamedPrvt(AllTrim(SX6->X6_VAR),SX6->X6_CONTEUD, "EasyTemplate")
      aAdd(aGetParams,{AllTrim(SX6->X6_VAR),AllTrim(SX6->X6_VAR),})
   EndIf
Next i

For i := 1 To Len(Self:aVarTela)
   _SetNamedPrvt(Self:aVarTela[i][1],Self:aVarTela[i][2], "EasyTemplate")
   aAdd(aGetParams,{Self:aVarTela[i][1],Self:aVarTela[i][1],Self:aVarTela[i][3]})
Next i

Return aGetParams

Function EasyTemplate()
Private aRotina := MenuDef()
Return Easy2Template()

Function Easy2Template()

Local oWizard
Local aTmplObjs
Local lRet := .T.
Local oPanel, oPrc, oSeg, oTer, oBox, oQua, oRad1, oPanelVer
Local oPanSeg, oPanPrc, oPanTer, oPanBox, oPanQua, oSay2
Local oProcPrc, oProcSeg, oProcTer, oProcBox, oProcQua, oSayProc, oSay3, oPanelFinal
Local cList
Private oPanelConf
Private oPanelProc
Private nOpcao     := 0
Private lFinalizar := .F.
Private cAtuLogWiz := ""
Private oSay1
Private cStatProc

//RpcSetType(3)
//RpcSetEnv("99","01")
//cModulo := "E"

MSGINFO("A funcionalidade de template foi descontinuada. Para informações sobre a configuração das funcionalidades Conta e Ordem - Perfil Adquirente, Conta e Ordem - Perfil Importador, Exportador de Café, Importação de dados contidos no arquivo no formato CSV(Logix Comex) e Integração SIGAEEC via mensagem única, acesse o documento de referência dos módulos de Comércio Exterior no TDN: https://tdn.totvs.com/pages/viewpage.action?pageId=284872382 ", "Aviso")
RETURN

aTmplObjs := LoadTemplates()

  DEFINE WIZARD oWizard	TITLE   "Wizard para aplicação de templates";
     					HEADER  "Bem-Vindo";
						MESSAGE "Apresentação";
						TEXT    "Este aplicativo tem por objetivo a configuração de ambientes dos módulos de Comércio Exterior.";
						PANEL NEXT {|| .T.};
                        FINISH     {|| .T.}

      CREATE PANEL oWizard HEADER "Seleção de Template"	MESSAGE "";
                                                PANEL;
                                                BACK   {|| .F. };
                                                NEXT   {|| nOpcao > 0};
                                                FINISH {|| .T. };
                                                EXEC   {|| .T. }
            oPanel := oWizard:oMPanel[Len(oWizard:oMPanel)]
            oPanel:cName := "SEL_DEF"
            
            oPrc := TPanel():New(01,01,"",oPanel,,,,,,oPanel:nClientWidth,oPanel:nHeight/15)
            oPrc:Align := CONTROL_ALIGN_TOP
            
            oSeg := TPanel():New(01,01,"",oPanel,,,,,,oPanel:nWidth,14*oPanel:nHeight/15)
            oSeg:Align := CONTROL_ALIGN_ALLCLIENT

            oTer := TPanel():New(01,01,"",oSeg,,,,,,oSeg:nWidth,oSeg:nHeight/10)
            oTer:Align := CONTROL_ALIGN_BOTTOM
            
            cList := "Selecione o template a ser ativado:"
            @ 05, 10 Say cList  Size oPrc:nClientWidth,oPrc:nClientHeight Pixel Of oPrc HTML
            
            oBox := TScrollArea():New(oSeg,15,10,oSeg:nHeight/4,oSeg:nWidth/2-15,.T.,.F.)
            //oBox := TScrollBox():New(oSeg,15,10,oSeg:nHeight/4,oSeg:nWidth/2-15,.T.,.F.,.T.)
            oBox:Align := CONTROL_ALIGN_ALLCLIENT
            
            oQua := TPanel():New(01,01,"",oBox,,,,,,oBox:nWidth,Len(aTmplObjs)*10)
            oQua:Align := CONTROL_ALIGN_BOTTOM
            
            oBox:SetFrame(oQua)
            
            oRad1 := TRadMenu():New(5,5,getTemplList(aTmplObjs),{|x| if(x=nil,nopcao,nopcao:=x)},oQua,,,,,,,,Len(aTmplObjs)*10,oQua:nWidth/2,,,.T.,.T.)
            oRad1:bChange := {|| oSay1:Refresh()}
            oRad1:Align := CONTROL_ALIGN_ALLCLIENT
            
            //oBox := TListBox():New(15,10,,[ aItems], [ nWidth], [ nHeight], [ bChange], [ oWnd], [ bValid], [ nClrFore], [ nClrBack], [ lPixel], [ uParam13], [ bLDBLClick], [ oFont], [ uParam16], [ uParam17], [ bWhen], [ uParam19], [ uParam20], [ uParam21], [ uParam22], [ bRClick] )
            //oBox:Align := CONTROL_ALIGN_ALLCLIENT
            
            //@ 100, 08 Say (if(nOpcao==0,"",aTmplObjs[nOpcao]:cDescription)) Size oPanel:nClientHeight, oPanel:nClientWidth Pixel Of oPanel HTML
            oSay1 := TSay():New(2,2,{||StrTran(if(nOpcao==0,"",aTmplObjs[nOpcao]:cDescription+"<BR><BR>Clique em 'Avançar' para continuar."),Chr(13)+Chr(10),"<BR>")},oTer,,,,,,.T.,,,oTer:nClientWidth/2-10,oTer:nHeight/2,,,,,,.T.)
            oSay1:lWordWrap := .T.
            oSay1:Align := CONTROL_ALIGN_ALLCLIENT
            
            //@ 130, 08 Say "Clique em 'Avançar' para continuar." Size oPanel:nClientHeight, oPanel:nClientWidth Pixel Of oPanel HTML

      CREATE PANEL oWizard HEADER "Verificando integridade do ambiente" ;
                                                           MESSAGE "";
                                                           PANEL;
                                                           BACK   {|| cMsgVer2 := "Aguarde...", cMsgVer3 := "", .T. };
                                                           NEXT   {|| lFinalizar };
                                                           FINISH {|| .T. };
                                                           EXEC   {|| lFinalizar := .F., ProcessMessage(),/*msgYesNo("Esta verificacao podera demorar alguns minutos. Deseja continuar?") .AND.*/ Eval(bExec) }
            
            bExec := {|| ProcessMessage(), If(aTmplObjs[nOpcao]:ChkTemplate(),(cMsgVer2 := "Verificação finalizada com sucesso.",cMsgVer3 := "Clique em 'Avançar' para continuar.",lFinalizar := .T.),;
                                                            (cMsgVer2 := "Foram identificados pre-requisitos necessarios para continuar com a configuracao do ambiente:"+ENTER+aTmplObjs[nOpcao]:cLogAtu,.F.)) }
            
            oPanelVer := oWizard:oMPanel[Len(oWizard:oMPanel)]
            oPanelVer:cName := "VER_DEF"
            
            cMsgVer  := "Verificando pre-requisitos para configuracao do ambiente."+ENTER+ENTER
            cMsgVer2 := "Aguarde..."
            cMsgVer3 := ""
            
            @ 10, 10 Say cMsgVer+cMsgVer2 Size oPanelVer:nClientHeight, oPanelVer:nClientWidth Pixel Of oPanelVer HTML
            @ 130, 08 Say cMsgVer3 Size oPanelVer:nClientHeight, oPanelVer:nClientWidth Pixel Of oPanelVer HTML
            
      CREATE PANEL oWizard HEADER "Configuracao de Parametros";
                                                           MESSAGE "";
                                                           PANEL;
                                                           BACK   {|| .T. };
                                                           NEXT   {|| .T. };
                                                           FINISH {|| .T. };
                                                           EXEC   {|| aGets := aTmplObjs[nOpcao]:LoadParams(),AtuTelaPar(aGets,oPanQua)}
            
            oPanelConf := oWizard:oMPanel[Len(oWizard:oMPanel)]
            oPanelConf:cName := "PAR_DEF"
            
            oPanPrc := TPanel():New(01,01,"",oPanelConf,,,,,,oPanelConf:nClientWidth,oPanelConf:nHeight/15)
            oPanPrc:Align := CONTROL_ALIGN_TOP
            
            oPanSeg := TPanel():New(01,01,"",oPanelConf,,,,,,oPanelConf:nWidth,14*oPanelConf:nHeight/15)
            oPanSeg:Align := CONTROL_ALIGN_ALLCLIENT

            oPanTer := TPanel():New(01,01,"",oPanSeg,,,,,,oPanSeg:nWidth,oPanSeg:nHeight/10)
            oPanTer:Align := CONTROL_ALIGN_BOTTOM
            
            @ 05, 10 Say "Parametros do template:"  Size oPanPrc:nClientWidth,oPanPrc:nClientHeight Pixel Of oPanPrc HTML
            
            oPanBox := TScrollArea():New(oPanSeg,15,10,oPanSeg:nHeight/4,oPanSeg:nWidth/2-15,.T.,.F.)
            oPanBox:Align := CONTROL_ALIGN_ALLCLIENT
            
            oPanQua := TPanel():New(01,01,"",oPanBox,,,,,,oPanBox:nWidth,oPanBox:nHeight)
            oPanQua:Align := CONTROL_ALIGN_ALLCLIENT
            
            oPanBox:SetFrame(oPanQua)
            
            oSay2 := TSay():New(2,2,{||"<BR><BR>Clique em 'Avançar' para continuar."},oPanTer,,,,,,.T.,,,oPanTer:nClientWidth/2-10,oPanTer:nHeight/2,,,,,,.T.)
            oSay2:lWordWrap := .T.
            oSay2:Align := CONTROL_ALIGN_ALLCLIENT
              		 
      //Tela da aplicação do update.
      CREATE PANEL oWizard HEADER "Processamento"  MESSAGE "Atualização";
                                                   PANEL;
                                                   BACK   {|| .F. };
                                                   NEXT   {|| lFinalizar };
                                                   EXEC   {|| lFinalizar := .F., Eval(bExecProc)};
                                                   FINISH {|| .T. }
            
            bExecProc := {|| ProcessMessage(), aTmplObjs[nOpcao]:AtuParam(),If(lFinalizar := aTmplObjs[nOpcao]:AtuTemplate(),;
                             (aTmplObjs[nOpcao]:cLogAtu+="<font color=blue>Template configurado com sucesso.</font>",cStatProc := "Processado!"),;
                             (aTmplObjs[nOpcao]:cLogAtu+="<font color=red>Nao foi possivel configurar o template.</font>",cStatProc := "Ocorreram erros no processamento:")),cAtuLogWiz := ""}
            
            oPanelProc := oWizard:oMPanel[Len(oWizard:oMPanel)]
            oPanelProc:cName := "UPD_DEF"
            
            oProcPrc := TPanel():New(01,01,"",oPanelProc,,,,,,oPanelProc:nClientWidth,oPanelProc:nHeight/15)
            oProcPrc:Align := CONTROL_ALIGN_TOP
            
            oProcSeg := TPanel():New(01,01,"",oPanelProc,,,,,,oPanelProc:nWidth,14*oPanelProc:nHeight/15)
            oProcSeg:Align := CONTROL_ALIGN_ALLCLIENT

            oProcTer := TPanel():New(01,01,"",oProcSeg,,,,,,oProcSeg:nWidth,oProcSeg:nHeight/10)
            oProcTer:Align := CONTROL_ALIGN_BOTTOM
            
            cStatProc := "Processando..."
            @ 05, 10 Say cStatProc  Size oProcPrc:nClientWidth,oProcPrc:nClientHeight Pixel Of oProcPrc HTML
            
            oProcBox := TScrollArea():New(oProcSeg,15,10,9*oProcSeg:nHeight/10,oProcSeg:nWidth/2-15,.T.,.F.)
            oProcBox:Align := CONTROL_ALIGN_ALLCLIENT
            
            oProcQua := TPanel():New(01,01,"",oProcBox,,,,,,oProcBox:nWidth,9*oProcSeg:nHeight/10)
            oProcQua:Align := CONTROL_ALIGN_ALLCLIENT
            
            oProcBox:SetFrame(oProcQua)
            
            oSayProc := TSay():New(2,2,{||StrTran(cAtuLogWiz+if(nOpcao>0,aTmplObjs[nOpcao]:cLogAtu,""),Chr(13)+Chr(10),"<BR>")},oProcQua,,,,,,.T.,,,oProcQua:nWidth,oProcQua:nHeight,,,,,,.T.)
            oSayProc:lWordWrap := .T.
            oSayProc:Align := CONTROL_ALIGN_ALLCLIENT
            
            cAtuLogWiz := "Configuracao em andamento.<BR>Aguarde...<BR><BR>"
            
            //@ 002, 005 Get (cPreLogWiz+aTmplObjs[nOpcao]:cLogAtu) Size oPanel:nClientHeight, 120 MEMO HSCROLL ReadOnly Pixel Of oPanel
            //@ 002, 005 Say (StrTran(cAtuLogWiz+if(nOpcao>0,aTmplObjs[nOpcao]:cLogAtu,""),Chr(13)+Chr(10),"<BR>")) Size oPanel:nClientHeight, 120 Pixel Of oPanel HTML
            
            //TSay():New(002,005,&("{||'"+StrTran(cMsg,Chr(13)+Chr(10),"<br>")+"'}"),oPanel,,,,,,.T.,,,120,oPanel:nClientHeight,,,,,,.T.)
            oSay3 := TSay():New(002,005,{||if(lFinalizar,"<BR><BR>Clique em 'Avançar' para continuar.",)},oProcTer,,,,,,.T.,,,120,oProcTer:nHeight,,,,,,.T.)
            //@ 130, 008 Say cMsgUpdDef Size oPanel:nClientHeight, oPanel:nClientWidth Pixel Of oPanel
            
            //@ 128, 250 Button "&Gravar Log" Size 040,011 Pixel Action GravarLog() OF oPanel WHEN (IF(!Empty(cLogWiz).And.Empty(cNLogWiz),.T.,.F.))

      //Tela de Finalização.
      CREATE PANEL oWizard HEADER "Finalização de atualização"  MESSAGE "Finalização";
                                                                PANEL;
                                                                BACK   {|| .F. };
                                                                NEXT   {|| .F. };
                                                                FINISH {|| .T. }
                                                                //EXEC   {|| ValMsgFnz()}
            oPanelFinal := oWizard:oMPanel[Len(oWizard:oMPanel)]
            oPanelFinal:cName := "FNZ_DEF"

            @ 010, 10 Say "Configuracao finalizada com sucesso." Size oPanelFinal:nClientHeight, oPanelFinal:nClientWidth Pixel Of oPanelFinal HTML
            
            @ 030, 10 Say "Para que as alterações sejam aplicadas, será necessário reiniciar o SmartClient." Size oPanelFinal:nClientHeight, oPanelFinal:nClientWidth Pixel FONT oPanelFinal:oFont COLOR CLR_HRED Of oPanelFinal HTML //MCF - 07/01/2016

            //@ 075, 08 BITMAP oBitmap2 SIZE 090, 035 OF oPanel FILENAME (cDestSys + "trade-easy.jpg") NOBORDER SCROLL ADJUST PIXEL

            @ 130, 08 Say "Clique em 'Finalizar' para fechar." Size oPanelFinal:nClientHeight, oPanelFinal:nClientWidth Pixel Of oPanelFinal HTML

  ACTIVATE WIZARD oWizard CENTERED VALID {|| .T. }

Return lRet

Static Function getTemplList(aTmplObjs)
Local aTemplList := {}
Local i
Local lOError:= .F.

If IsMemVar("__oError") .And. ValType(__oError) == "O"
   lOError:= .T.
EndIf

For i := 1 To Len(aTmplObjs)
   aAdd(aTemplList,aTmplObjs[i]:cTitulo)
Next i

Return aTemplList

Static Function LoadTemplates()
Local aTmplObjs := {}
Local i, aTemplates
Local oTempl
Local lOError:= .F. //LRS - 11/07/2018

If IsMemVar("__oError") .And. ValType(__oError) == "O"
   lOError:= .T.
EndIf

aTemplates := getTemplates()
For i := 1 To Len(aTemplates)
   TRY
      Eval(&("{|o|"+aTemplates[i]+"(o)}"),oTempl := EasyTemplate():New(aTemplates[i]))
      If cModulo $ oTempl:cModulo
         aAdd(aTmplObjs,oTempl)
      EndIf
   CATCH
   
   ENDTRY
   
   If lOError
      EECView(StrTran(__OError:Errorstack,Chr(10),Chr(13)+Chr(10)))
   EndIf
   
Next i

Return aTmplObjs

Static Function HelpTemplate(cParam,cTit)
Local cDescr := ""

If Empty(cTit)
   EasyGParam(cParam)
   If SX6->(!EoF())
//      cDescr := SX6->(X6_DESCRIC+X6_DESC1+X6_DESC2)
      cDescr := AllTrim(SX6->X6_DESCRIC) + AllTrim(SX6->X6_DESC1) + AllTrim(SX6->X6_DESC2)
   EndIf
Else
   cDescr := cTit
EndIf

Return cDescr

Static Function AtuTelaPar(aGets,oObj)
Local i
nRow := 0

oObj:nHeight := Len(aGets)*70

For i := 1 To Len(aGets)
   
   TSay():New(nRow,15,&("{||HelpTemplate('"+aGets[i][1]+"','"+if(aGets[i][3]<>NIL,aGets[i][3],"")+"')}"),oObj,,,,,,.T.,,,Len(aGets[i][1])*20,15)
   //aAdd(::oGets[i],TSay():New(::aPosCols[i][1][1],::aPosCols[i][1][2],&("{|| '"+::aPosCols[i][3][1]+"'}"),::oBox,,::oBox:oFont,.F.,.F.,.F.,.T., , ,::aPosCols[i][1][3],::aPosCols[i][1][4],.F.,.F.,.F.,.F.,.F.))
   TGet():New(nRow+15, 15, &("{|x| if(x<>NIL,"+aGets[i][2]+" := x,"+aGets[i][2]+") }"),oObj,Len(aGets[i][2])*20,10,,,,,,.F.,, .T.,, .F.,, .F., .F.,, .F., .F.,,/*cvar*/,,,,.T.)
   nRow += 30
      
   //aAdd(::oGets[i],TGet():New(::aPosCols[i][2][1],::aPosCols[i][2][2],&("{|x| if(x<>NIL,"+::aPosCols[i][3][2]+" := x,"+::aPosCols[i][3][2]+") }"),::oBox,::aPosCols[i][2][3],::aPosCols[i][2][4],::aPosCols[i][3][3], If(::aPosCols[i][3][4],{||.T.},{||.F.}),,,::oBox:oFont,.F.,,.T.,"",.F.,NIL,.F.,.F.,,.F.,.F.,"",::aPosCols[i][3][2],"",.F.,0,.T.))
Next i

oObj:Refresh()

Return

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Nilson César C. Filho
Data       : 10/03/2011 13:00
*/
Static Function MenuDef()

Local aRotina := {{"Incluir" , "Easy2Template", 0, 3}}   //"Incluir"

Return aRotina