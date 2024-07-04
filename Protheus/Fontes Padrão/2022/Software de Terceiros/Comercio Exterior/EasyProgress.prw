#INCLUDE "AVERAGE.CH"

Function EasyProgress()
RETURN NIL

Class EasyProgress From AvObject

Data oMeter
Data oDlgPrg
Data nInc
Data nSize
Data nType
Data bProcess
Data nStart
Data lElapsed
Data nElapsed 
Data lEstimated
Data nEstimated
Data lPerc
Data nPerc
Data cTitle
Data lAbort
Data lCancel

Method New()
Method SetProcess()
Method SetType()
Method SetRegua()
Method SetElapsedTime()
Method SetEstimatedTime()
Method SetPercentage()
Method IncRegua()
Method Init()
Method GetTextTime()
Method Refresh()
Method GetStatus()

End Class

Method New(lCanc) Class EasyProgress
   Default lCanc   := .T.
   Self:nType      := 1
   Self:lElapsed   := .T.
   Self:lEstimated := .T.
   Self:lPerc      := .T.
   Self:nInc       := 0
   Self:nPerc      := 0
   Self:nStart:= 0
   Self:nElapsed:= 0
   Self:nEstimated:= 0
   Self:lAbort := .F.
   Self:lCancel := lCanc
Return Self

Method SetType(nType) Class EasyProgress
   Self:nType := nType
Return nType

Method SetRegua(nSize) Class EasyProgress
   Self:nSize := nSize
   Self:nInc  := 0
   Self:nPerc := 0
   Self:nStart:= Seconds()
   Self:nElapsed:= 0
   Self:nEstimated:= 0
   Self:lAbort := .F.
   Self:oMeter:SetTotal(100)
   //ProcRegua(nSize)
Return Nil

Method SetElapsedTime(lElapsed) Class EasyProgress
   Self:lElapsed   := lElapsed
Return lElapsed

Method SetEstimatedTime(lEstimated) Class EasyProgress
   Self:lEstimated   := lEstimated
Return lEstimated

Method SetPercentage(lPerc) Class EasyProgress
   Self:lPerc := lPerc
Return lPerc

Method SetProcess(bProcess,cTitle) Class EasyProgress
   Self:bProcess := bProcess
   Self:cTitle   := cTitle
Return bProcess

Method Init() Class EasyProgress
Local xRet
Local oSay, oPanel1, oPanel2

If !Empty(Self:bProcess)
   //Processa({|| Eval(Self:bProcess)},Self:cTitle)
   
   bRefresh := {|| Self:Refresh()}
   
   DEFINE DIALOG Self:oDlgPrg TITLE Self:cTitle FROM 180,180 TO 280,700 PIXEL
   
   //DEFINE TIMER oTimer INTERVAL 1000 ACTION Eval(bRefresh) OF Self:oDlgPrg
   //oTimer:Activate()
   
   oPanel1:= TPanel():New(0, 0, "",Self:oDlgPrg, , .F., .F., , , 700, 300, , )
   oPanel1:Align := CONTROL_ALIGN_ALLCLIENT

   oPanel2:= TPanel():New(0, 0, "",Self:oDlgPrg, , .F., .F., , , 700, 10, , )
   oPanel2:Align := CONTROL_ALIGN_BOTTOM

   oSay := TSay():New(00,5,{|| Self:GetStatus() }, oPanel1, , Self:oDlgPrg:oFont, , , , .T., , , 200, 100, , , , , , .T. )
   oSay:Align := CONTROL_ALIGN_ALLCLIENT
   //oSay1 := TSay():New(15,5,{|| "<B>Tempo decorrido:</B> "+Self:GetTextTime(Seconds()-Self:nStart) }, oPanel1, , Self:oDlgPrg:oFont, , , , .T., , , 200, 100, , , , , , .T. )
   //oSay2 := TSay():New(30,5,{|| "<B>Tempo restante aproximado:</B> "+if(Self:nEstimated==0,"Calculando...",Self:GetTextTime(Max(Self:nEstimated-Seconds(),1))) }, oPanel1, , Self:oDlgPrg:oFont, , , , .T., , , 200, 100, , , , , , .T. )
   
   Self:oMeter := TMeter():Create(oPanel1,{|u|if(Pcount()>0,Self:nPerc:=u,Self:nPerc)},65,02,100,100,10,,.T.,,,,,,,,,.T.)
   Self:oMeter:Align := CONTROL_ALIGN_BOTTOM 
   Self:oMeter:setFastMode(.T.)
   //RRC - 06/05/2013 - Verifica se deve exibir o botão de cancelar
   If Self:lCancel
      oBtn := TButton():New(10,10,"Cancelar",oPanel2,{|| if(MsgYesNo("Deseja realmente cancelar o processamento?"),(Self:lAbort := .T., Self:oDlgPrg:End()),)},50,14,,,.F.,.T.,.F.,,.F.,,,.F.)
      //O CSS abaixo irá inserir uma imagem posicionada à esquerda/superior do botão
      //oBtn:SetCss("QPushButton{ background-image: url(rpo:copyuser.png);background-repeat: none; margin: 2px; vertical-align: middle; horizontal-align: middle }")
      oBtn:Align := CONTROL_ALIGN_ALLCLIENT
   EndIf
   
   Self:oDlgPrg:lEscClose := .T.
   Self:oDlgPrg:bStart := {|| (xRet := Eval(Self:bProcess),Self:oDlgPrg:End()) }
   
   ACTIVATE DIALOG Self:oDlgPrg CENTERED 
   
EndIf

Return xRet

Method IncRegua() Class EasyProgress
Local cRet := ""

Self:nInc++

If Self:lPerc
   Self:nPerc := Int(100*Self:nInc/Self:nSize)
EndIf

If Self:lEstimated
   Self:nEstimated := Self:nStart + Int(Seconds() - Self:nStart)*(Self:nSize/Self:nInc)
Endif

Self:Refresh()

Return !Self:lAbort

Method Refresh() Class EasyProgress
Static nLast := Seconds()

If (Seconds()-nLast)> 0.6
   Self:oMeter:Set(Self:nPerc)
   
   //({|| Self:lAbort := .T.})
   aEval(Self:oDlgPrg:aControls,{|X| X:Refresh()})
   Self:oDlgPrg:Refresh()
   
   SysRefresh()
   ProcessMessage()
   nLast := Seconds()
EndIf

Return Nil

Method GetTextTime(nSegundos) Class EasyProgress
Local cRet
Local nHoras, nMins, nSegs

   nHoras   := Int(nSegundos/3600)
   nMins    := Int((nSegundos-nHoras*3600)/60)
   nSegs    := Int(nSegundos-nHoras*3600-nMins*60)
                  
   cRet := if(nHoras>1,AllTrim(Str(nHoras))+" horas ",if(nHoras>0,"1 hora ","0 horas "))
   cRet += if(nMins>1,AllTrim(Str(nMins))+" minutos ",if(nMins>0,"1 minuto ","0 minutos "))
   cRet += if(!Empty(cRet),"e ","")+if(nSegs>1,AllTrim(Str(nSegs))+" segundos.",if(nSegs>0,"1 segundo.","0 segundos"))
   
Return cRet

Method GetStatus() Class EasyProgress
Local cRet := ""

If Self:nSize<>NIL
   If Self:lPerc
      cRet += "<B>Progresso:</B> "+AllTrim(Str(NoRound(100*Self:nInc/Self:nSize,2)))+"%.<BR>"
   EndIf
   
   If Self:lElapsed
      cRet += "<B>Tempo decorrido:</B> "+Self:GetTextTime(Seconds()-Self:nStart)+"<BR>"
   EndIf
   
   If Self:lEstimated
      cRet += "<B>Tempo restante aproximado:</B> "+if(Self:nEstimated==0,"Calculando estimativa...",Self:GetTextTime(Max(Self:nEstimated-Seconds(),0)))
   EndIf
Else
   cRet += "<center>Iniciando processamento...</center>"
EndIf

Return cRet