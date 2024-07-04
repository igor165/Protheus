#include "totvs.ch"

/*
Classe para execução de javascript no smartclient.

//Instanciando o objeto. Necessário haver uma janela aberta no smartclient
Local oEasyJS := EasyJS():New()

//Adicionando bibliotecas javascript da internet (nao pode adicionar libs depois do activate)
oEasyJS:AddLib('<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>') 

//Adicionando uma biblioteca javascript compilada no APO (nao pode adicionar libs depois do activate)
oEasyJS:AddLib(GetApoRes('ASYNC.JS'))

oEasyJS:SetTimeout(30) //Segundos de timeout para uso em execuções sincronas

//Método para alterar o block de código de tratamento de erro de javascript. Por padrão, se algum javascript der erro no navegador, o erro será capturado e será lançado um error.log no protheus.
oEasyJS:SetErrorHandler({|e| conout(e) }) //Exemplo que ignora erro de javascript, jogando a mensagem de erro para o console

//Ativando a classe de forma asincrona
oEasyJS:Activate() //Ativa o objeto e não aguarda a conexao com o websocket no smartclient para seguir no advpl

//Ativando a classe de forma sincrona
oEasyJS:Activate(.T.) //Ativa o objeto e aguarda a conexao com o smartclient para seguir no advpl

//Executando um javascript de forma asincrona e retornando um valor fixo para o advpl e um codeblock para processar o retorno, utilizando o callback advpl padrao (retAdvpl)
oEasyJS:runJS("alert('teste'); retAdvpl('teste_ok');",{|x| alert(x) })

//Sobrescrevendo o tratamendo de erro apenas para esse script
oEasyJS:runJS("throw new Error('Erro de javascript'); retAdvpl('teste_ok');",{|x| MsgInfo(x) },{|x| MsgStop(x)})//Nesse exemplo, será executado o msgstop, ja que ocorrerá um erro antes do retAdvpl

//Executando um javascript de forma asincrona e pegando o retorno depois
cId := oEasyJS:runJS("alert('teste'); retAdvpl('teste_ok');") //Segue a vida no advpl enquanto o javascript é processado
..
.. faz outras coisas e depois pega o retorno ...
..
cRet := NIL, cError := NIL
oEasyJS:Wait({|| cret <> NIL .OR. oEasyJS:getJSret(cId,@cret,@cerror) >= 0}) //Espera pelo retorno do javascript, verifica se ja recebeu o retorno do javascript e recebe na variavel cret (se ocorresse erro, retornaria na variavel cerror e não executa o errorhandler padrão (se nao passar o 3o parametro, será disparado o errorhandler padrao)
Alert(cRet)

//Exemplo retornando um javascript para o advpl em partes
oEasyJS:runJS("retAdvplChunk('teste_ok'); retAdvplChunk('teste2_ok'); retAdvpl('teste3_fim');",{|x| alert(x) }) //Irá retornar 3 mensagens para o advpl, e finaliza o retorno na terceira

//Executando um javascript de forma sincrona
cRet := ""
oEasyJS:runJSSync("alert('teste'); retAdvpl('teste_ok');",{|x| cret := x }) //Só sai desta linha quando receber o retorno do javascript
Alert(cRet)

//Executa um javascript de forma sincrona sobrescrevendo o errorhandler padrao
cRet := ""
oEasyJS:runJSSync("throw new Error('teste erro'); retAdvpl('teste_ok');",{|x| cret := x }, {|x| cret := x}) //Só sai desta linha quando receber o retorno do javascript
Alert(cRet) //Seria exibida a mensagem teste erro

*/

Class EasyJS

    Method New(odlg,cUrl)
    Method addLib(cScript)
    Method Activate()
    Method runJS(cscript,bcallback,bErrorHandler)
    Method runJSSync(cscript,bcallback,bErrorHandler)
    Method getJSret(cId,cRet)
    Method Wait(bCond)
    Method isConnected()
    Method CallBack()
    Method Load()
    Method SetTimeout(nTimeOut)
    Method HasReturned(cId)
    Method isSmartClientHtml()
    Method Destroy()
    Method SetErrorHandler()
    Method SetApp()

    data oScriptList
    data cUrl
    data aInclude
    data cPage
    data lConnected
    data odlg
    data cindex
    data oWebEngine
    data oWebChannel
    data nTimeOut
    data bErrorHandler
    data cAppName

End Class

Class EasyScriptJS

    data cid
    data cScript
    data bCallBack
    data cValue
    data lFired
    data lResult
    data lReturned
    data nTimeOut
    data bErrorHandler
    data lError
    data cError

    Method New(cScript,bCallBack)
    Method Fire(oEasyJS) 
    Method CallBack(bCallBack)
    Method SetError(lErro)

End Class

Method New(cScript,bCallBack,bErrorHandler) Class EasyScriptJS
    ::cId       := Upper("EASYJS_SCRIPT_"+FWUUIDV4(.F.))
    ::cScript   := PreparaScript(cScript,::cId)
    ::nTimeOut  := 0
    ::lError    := .F.
    ::lFired    := .F.
    ::lResult   := .F.
    ::lReturned := .F.
    ::cValue    := ''
    ::cError    := ''
    
    If ValType(bCallBack) == "B"
        ::bCallBack := bCallBack
    EndIf
    If ValType(bErrorHandler) == "B"
        ::bErrorHandler := bErrorHandler
    EndIf
    //EasySetBuffers('EASYJS',::cId,Self)
Return Self

Method Fire(oEasyJS) Class EasyScriptJS
    Self:lFired := .T.

    If oEasyJS:isSmartClientHtml()
        oEasyJS:oWebChannel:advplToJS(Self:cId, Self:cScript)
    Else
        oEasyJS:oWebEngine:runJavascript('twebchannel.advplToJs("'+Self:cId+'",`'+strtran(strtran(strtran(Self:cScript,'\','\\'),'$','\$'),'`','\`')+'`)')
    EndIf
    //varinfo('envio_js',Self:cId)
Return .T.

Method CallBack(cValue,lChunk,lError) Class EasyScriptJS
Local uRet

    If !lError
        Self:cValue += cValue
        If !lChunk
            Self:lResult := .T.
        EndIf
        If ValType(::bCallBack) == "B"
            If !lChunk
                Self:lReturned := .T.
            EndIf
            uRet := Eval(::bCallBack,cValue,lChunk)
        EndIf
    Else
        Self:SetError()
        Self:lResult   := .T.
        Self:cError    := cValue
        If ValType(::bErrorHandler) == "B"
            Self:lReturned := .T.
            uRet := Eval(::bErrorHandler,cValue,Self)
            If ValType(Self) == "O"
                Self:SetError(uRet)
            EndIf
        EndIf
    EndIf
Return uRet

Method SetError(lErro) Class EasyScriptJS
If ValType(lErro) == "U"
    Self:lError := .T.
ElseIf ValType(Self:lError) <> "L"
    UserException('EasyJS - Errorhandler must return logical value')
EndIf
Return .T.

Method New(odlg) Class EasyJS
Default odlg := GetWndDefault()

    self:odlg        := odlg
    Self:lConnected  := .F.
    Self:aInclude    := {}
    Self:oScriptList := THashMap():New()
    Self:bErrorHandler := {|e,oScript| UserException(e), .F. }
    Self:cAppName    := ''
    self:cpage:= ""

    //Self:addLib(TWebChannelLib())

    Self:oWebChannel := TWebChannel():New()
    Self:oWebChannel:bJsToAdvpl := {|oWC,key,value| Self:Callback(key,value) }
    Self:oWebChannel:connect()
    
    //conout('WebChannel on port '+cValToChar(Self:oWebChannel:nPort))

    Self:oWebEngine := TWebEngine():New(oDlg,0,0,0,0,,/*if(isSmartClientHtml(),Self:oWebChannel:nPort,)*/)
    //Self:oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

Return .T.

Method SetApp(cAppName) Class EasyJS
Local h, cAppBin
    If !Empty(cAppName) .AND. ValType(cAppBin := GetApoRes(cAppName+".APP")) != "U"
        Self:cAppName := cAppName

        Self:oWebEngine:Align := CONTROL_ALIGN_ALLCLIENT

        cTempFile := GetTempPath() + cAppName + ".zip"
        h := fCreate(cTempFile)
        fwrite(h,cAppBin)
        fclose(h)

        FUnzip(cTempFile,GetTempPath())
    Else
        MsgStop("App '"+cAppName+"' não encontrado no repositório.")
    EndIf
Return .T.

Method SetErrorHandler(bErrorHandler) Class EasyJS
    If ValType(bErrorHandler) == "B"
        Self:bErrorHandler := bErrorHandler
    EndIf
Return Nil

Method Destroy() Class EasyJS
    If ValType(Self:oWebChannel) == "O"
        Self:oWebChannel:Disconnect()
        Self:oWebChannel:DESTROY()
    EndIf
    If ValType(Self:oWebEngine) == "O"
        Self:oWebEngine:DESTROY()
    EndIf
    Self:oScriptList:CLEAN()
Return Nil

Method addLib(cScript) Class EasyJS
Local lScript

cScript := allTrim(cScript)
If (lScript := upper(left(cScript,len('<SCRIPT '))) == '<SCRIPT ')
    cScript := '<SCRIPT onerror="script_load_error(this)" '+SubStr(cScript,len('<SCRIPT '))
EndIf

aAdd(Self:aInclude,{lScript,cScript})
        
Return .T.

Method Activate(lWait) Class EasyJS
Local h, i, cAppName := "", cIndex := "", cBaseUrl := 'http://localhost:8081/'
Local aUrl := {}
Local cFonte := "GetEndPoint"
Default lWait := .F.

    If !Empty(Self:cAppName)
        cAppName := Self:cAppName+ If(Alltrim(Str(GetRemoteType())) $ '2|5' , '/' , '\' )
    EndIf

    Self:lConnected := .F.
  
    If Self:isSmartClientHtml()

        If FindFunction(cFonte) .And. !Empty(&cFonte.())
            cBaseUrl := 'http://'+ &cFonte.()+'/'
        Else
            cBaseUrl := 'http://localhost:'+GetProfString('WEBAPP','PORT','8081')+'/'
        Endif 
        
       // cBaseUrl := If( !ExistFunc('GetEndPoint') .Or. Empty(GetEndPoint()), 'http://localhost:'+GetProfString('WEBAPP','PORT','8081')+'/', GetEndPoint() )
        //Para client HTML, o websocket é feito pela propria conexao com web server HTML (temporário fica no servidor disponível para o client via HTTP)
        //Self:cPage = Self:cPage

        aAdd(Self:aInclude,NIL)
        aIns(Self:aInclude,1)
        Self:aInclude[1] := {.F.,TWebChannelLib()+chr(13)+chr(10)+"var paramlist = '?totvstec_websocket_port="+cValToChar(self:oWebChannel:nPort)+"&totvstec_remote_type=5'"}

        aUrl := strtokarr2(strtran(GetTempPath() + cAppName,'\','/'),'/webapp/')
        if len(aUrl) > 1
            aUrl[2] := strtran(aUrl[2],'user/','USER/')
        endif
       
        If !Empty(cAppName)
            cIndex := "index.html"
            if Len(aUrl) > 1
                self:cPage := strtran(EasyMemoRead(GetTempPath() + cAppName + cIndex),'<base href="/">','<base href="'+replace(cBaseUrl + aUrl[2],"\","/")+'">')
            EndIf
            ferase(strtran(GetTempPath() + cAppName + cIndex,'\','/'),1)
        else
            cIndex := "index_"+cValToChar(self:oWebChannel:nPort)+".html"
        EndIf

        h := fCreate(strtran(GetTempPath() + cAppName + cIndex,'\','/'),,1)
        //fwrite(h,'<script> window.onerror = (message, url, line, col, errorObj) => {alert(`${message}\n${url}, ${line}:${col}, ${errorObj}`) };</script>')

        //Adiciona includes
        for i := 1 to len(self:aInclude)
            If self:aInclude[i][1] // externos (<script>)
                fWrite(h, self:aInclude[i][2]+chr(13)+chr(10))
            Else
                cScriptFile := "script_"+cValToChar(self:oWebChannel:nPort)+"_"+alltrim(str(i))+".js"
                j := fCreate(strtran(GetTempPath() + cAppName + cScriptFile,'\','/'),,1)
                fwrite(j,self:aInclude[i][2]+chr(13)+chr(10))
                fclose(j)

                fwrite(h,'<script language="javascript" src="'+cScriptFile+'"></script>')
            EndIf
        next i

        fwrite(h,'<script language="javascript">window.onload = twebcon;</script>')
        fWrite(h, self:cPage)
        fClose(h)

        //libera a memoria
        Self:cPage    := NIL
        Self:aInclude := NIL

        //aUrl := strtokarr2(strtran(GetTempPath() + cAppName + cIndex,'\','/'),'/webapp/')
        if len(aUrl) > 1
            Self:cUrl := cBaseUrl+aUrl[2] + cIndex
        Else
            Self:cUrl := GetTempPath() + cAppName + cIndex
        EndIf
        Self:oWebEngine:navigate(Self:cUrl)
        
         
    Else
        Self:oWebEngine:bLoadFinished := {|webengine,url| if(at(Self:cUrl,url)>0 .OR. !Empty(self:cAppName),self:load(),) }
        
        If !Empty(cAppName)
            Self:cUrl := GetTempPath() + cAppName + 'index.html'
            cPage := strtran(MemoRead(Self:cUrl),'<base href="/">','<base href="'+GetTempPath() + cAppName+'">')
            If Type('oPOUI') == 'O' //Adiciona mais linhas na página para forçar habilitar o scroll no objeto ADVPL com PO-UI
                cPage := StrTran( cPage , '</body>' , '<div>'+Replicate('<br></br>',5)+'</div></body>' )    
            EndIf
            ferase(Self:cUrl)
            h := fCreate(Self:cUrl)
            fwrite(h,cPage)
            fclose(h)
        ElseIf Empty(Self:cUrl)
            Self:cUrl := "about:blank"//"http://google.com/404"
        EndIf

        Self:oWebEngine:navigate(Self:cUrl)
    EndIf

    if lWait
        self:odlg:refresh()
        processmessage()
        Self:Wait({|| Self:isConnected()})
    EndIf

Return if(lWait,Self:isConnected(),.T.)

Method Load() Class EasyJS
Local i

    Self:oWebEngine:runJavascript(TWebChannelLib())
    Self:oWebEngine:runJavascript("var paramlist = '?totvstec_websocket_port="+cValToChar(self:oWebChannel:nPort)+"&totvstec_remote_type=0'")

    for i := 1 To Len(Self:aInclude)
        if !Self:aInclude[i][1]
            //Self:oWebEngine:runJavascript(Self:aInclude[i][2])
            Self:oWebEngine:runJavascript(Self:aInclude[i][2])
        Else
            Self:oWebEngine:runJavascript("twebchannel.addScriptTag(`"+Self:aInclude[i][2]+"`);")
        EndIf
    next i

    //Self:cPage := cIncludes + Self:cPage
    
    if !Empty(Self:cPage)
        begincontent var cHtml
            var doc = document.getElementsByTagName('html')[0];
            doc.getElementsByTagName('body')[0].innerHTML = `%exp:Self:cPage%`;

            var scripts = document.body.getElementsByTagName('script')

            scriptLoad = ()=>{
                var script, newscript;

                while (scripts.length) {
                    script = scripts[0];
                    script.parentNode.removeChild(script);

                    newscript = document.createElement('script');

                    if (script.src) {
                        waitret = (e)=>{
                            if (e.target === newscript && (!e.readyState || e.readyState === "complete")) {
                                scriptLoad();
                            }
                        };
                        newscript.onerror = waitret;
                        newscript.onload = waitret;
                        newscript.onreadystatechange = waitret;
                        newscript.src = script.src;
                    }
                    else {
                        newscript.text = script.text;
                    }

                    document.documentElement.appendChild(newscript);

                    if (script.src) {
                        return;
                    }
                }
                newscript = undefined;
                if(window.onload)
                    window.onload();
            }
            scriptLoad()
        endcontent
        Self:oWebEngine:runJavascript(strtran(cHtml,'%exp:Self:cPage%',Self:cPage))
     EndIf
     Self:oWebEngine:runJavascript('twebcon()')
     //libera a memoria
     Self:aInclude := NIL
     Self:cPage    := NIL
    //Self:oWebEngine:SetHTML(Self:cpage)

Return .T.

Method isConnected(lSet) Class EasyJS
If ValType(lSet) == "L"
    Self:lConnected := lSet
EndIf
Return Self:lConnected

Static Function JSRefresh(oDlg)
//Local cAdd := GetMemoryAddress(oDlg)

//If !oMap:Get(cAdd)
   //oMap:Set(cAdd,.T.)
   aEval(oDlg:aControls,{|X| X:Refresh()})
   //if(valtype(oDlg:oWnd) == "O",JSRefresh(oDlg),)
   oDlg:Refresh()
//EndIf
Return .T.

Method Wait(bCond,nTimeOut) Class EasyJS
Local oTmpDlg, oTmpTimer
Local nFimTimeout := 0
Local lRet
Local bFim
Default nTimeOut := Self:nTimeOut
Default bCond := {|| aList := {}, Self:oScriptList:List(@aList), aScan(aList,{|X| X[2] <> NIL .AND. !X[2]:lResult }) == 0}

If nTimeOut > 0
    nFimTimeout := Seconds2()+nTimeOut
EndIf

bFim := {|| If((lRet := Eval(bCond)) .OR. nFimTimeout > 0 .AND. Seconds2() > nFimTimeout .OR. KillApp(),(oTmpTimer:deactivate(),oTmpDlg:End()),) }

If !(lRet := Eval(bCond))
    DEFINE MSDIALOG oTmpDlg FROM 0,0 TO 0,0 STYLE nOR( WS_VISIBLE, WS_POPUP ) PIXEL
        oTmpDlg:bInit := bFim
        oTmpTimer := TTimer():New(1, bFim, oTmpDlg )
        oTmpTimer:lLiveAny := .T.
        oTmpTimer:Activate()
        //oTmpDlg:lVisible := .F.//.F.
    ACTIVATE MSDIALOG oTmpDlg
EndIf

Return lRet

/*
Method Wait(bCond,nTimeOut) Class EasyJS
Local nFimTimeout := 0
Local lRet
Local bFim
Default nTimeOut := Self:nTimeOut
Default bCond := {|| aList := {}, Self:oScriptList:List(@aList), aScan(aList,{|X| X[2] <> NIL .AND. !X[2]:lResult }) == 0}
Private oTmpDlg, oTmpTimer

If nTimeOut > 0
    nFimTimeout := Seconds2()+nTimeOut
EndIf

bFim := {|| If((lRet := Eval(bCond)) .OR. nFimTimeout > 0 .AND. Seconds2() > nFimTimeout .OR. KillApp(),.T.,) }

If !(lRet := Eval(bCond))

    oTmpDlg := GetWndDefault()
    oTmpTimer := TTimer():New(1, bFim, oTmpDlg )
    oTmpTimer:lLiveAny := .T.
    oTmpTimer:Activate()

    private oMap := THashMap():New()
    Do While !Eval(bFim)//!IPCWaitEx('WAIT',1)
        sleep(1)
        //JSRefresh(Self:oDlg)
        JSRefresh(Self:oDlg:oWnd)
        SysRefresh()
        processmessage()
        DEFINE MSDIALOG oTmpDlg FROM 0,0 TO 0,0 STYLE 262144 //nOR( WS_VISIBLE, WS_POPUP ) PIXEL
        oTmpDlg:bInit := bFim
        oTmpTimer := TTimer():New(1, {|| oTmpDlg:End()}, oTmpDlg )
        oTmpTimer:lLiveAny := .T.
        oTmpTimer:Activate()
        //oTmpDlg:lVisible := .F.//.F.
        ACTIVATE MSDIALOG oTmpDlg
        freeobj(oTmpDlg)
    EndDo
EndIf

Return lRet
*/

Method CallBack(cId,value) Class EasyJS
Local oScript, xBuffer, lChunk, lError, i, oJson, bBLock, bOldErr, oErr := NIL, xRet := '', lErr := .F.

if((lChunk := rat("_CHUNK",cId) > 0),cId := strtran(cId,"_CHUNK",''),)
if((lError := rat("_ERROR",cId) > 0),cId := strtran(cId,"_ERROR",''),)

//varinfo('retorno_advpl',cId)
If cId == 'EASYJS_STATUS' .AND. value == 'CONNECTED'
    Self:isConnected(.T.)
    //conout('Websocket Connected')
    If Self:oScriptList:List(@xBuffer)//EasyGetBuffers('EASYBUFFERS','EASYJS',@xBuffer)
        For i := 1 To Len(xBuffer)
            If !xBuffer[i][2]:lFired
                xBuffer[i][2]:Fire(Self)
            EndIf
        Next i
    EndIf

ElseIf left(cId,len('RUN_ADVPL')) == 'RUN_ADVPL'
    oJson := JsonObject():New()
    
    ret := oJson:FromJson(value)
 
    if ValType(ret) == "C"
        self:runJS('runAdvplRet("'+oJson['id']+'",null,`'+strtran("Falha ao transformar texto em objeto json. Erro: " + ret,'`','\`')+'`)')
    else
        bBlock := &("{|args| " + oJson['param'][1] + "}")
        aDel(oJson['param'],1)
        aSize(oJson['param'],len(oJson['param']) -1 )
        
        Begin Sequence
            bOldErr := ErrorBlock({|e| oErr := e, pula() })
                xRet := Eval(bBlock,oJson['param'])
            ErrorBlock(bOldErr)
        End Sequence

        if valType(oErr) != "U"
            lErr := .T.
            xRet := oErr:ERRORSTACK
            self:runJS('runAdvplRet("'+oJson['id']+'", null,`'+strtran(xRet,'`','\`')+'`)')//   ((a)=>{return a.id == "'+oJson['id']+'"})[0].accept("'+encode64(httpget(oJson['url']))+'"); window.ADVPL_FETCH = window.ADVPL_FETCH.filter((a)=>{return a.id != "'+oJson['id']+'"});')
        Else
            If ValType(xRet) == "J"
                xRet := xRet:ToJSON()
                self:runJS('runAdvplRet("'+oJson['id']+'", JSON.parse(`'+strtran(xRet,'`','\`')+'`))')//   ((a)=>{return a.id == "'+oJson['id']+'"})[0].accept("'+encode64(httpget(oJson['url']))+'"); window.ADVPL_FETCH = window.ADVPL_FETCH.filter((a)=>{return a.id != "'+oJson['id']+'"});')
            Else
                xRet := If (ValType(xRet) != "C", cValToChar(xRet), xRet)
                self:runJS('runAdvplRet("'+oJson['id']+'", `'+strtran(xRet,'`','\`')+'`)')
            EndIf
        EndIf
    EndIf
ElseIf Self:oScriptList:Get(cId,@oScript)//EasyGetBuffers('EASYJS',cId,@oScript)
    If oScript <> NIL //Ja retornou completamente
        oScript:Callback(value,lChunk,lError)
    EndIf
EndIf

Return .T.

Static Function Pula()
break
Return .T.

Method runJSSync(cscript,bcallback,bErrorHandler) Class EasyJS
Local  oScript, cRet, cLastChunck

If Self:Wait({|| Self:isConnected()})
    
    oScript := EasyScriptJS():New(cscript,{|x,lchunk| cLastChunck := x, If(lchunk .AND. ValType(bcallback)=="B",Eval(bcallback,x),)})
    Self:oScriptList:Set(oScript:cId,oScript)

    oScript:Fire(Self)

    If Self:Wait({|| ValType(oScript) != "O" .OR. oScript:lReturned .OR. oScript:lError})
        If oScript:lError
            oScript:SetError(Eval(if(ValType(bErrorHandler)=="B",bErrorHandler,Self:bErrorHandler),oScript:cError,oScript))
        EndIf

        If !oScript:lError
            cRet := oScript:cValue
            If ValType(bcallback)=="B"
                Eval(bcallback,cLastChunck)
            EndIf
        EndIf
    EndIf

    FreeObj(oScript)
EndIf

Return cRet

Method runJS(cscript,bcallback,bErrorHandler) Class EasyJS
Local oScript

If ValType(bcallback) == "B" //Se tem callback, retorna ou estoura erro assim que tiver resposta
    oScript := EasyScriptJS():New(cScript,{|x,lChunk| Eval(bcallback,x,lChunk), if(!lChunk,FreeObj(oScript),) },{|x| Eval(if(valtype(bErrorHandler)=="B",bErrorHandler,Self:bErrorHandler),x,oScript), FreeObj(oScript) })
Else
    //Se não tem callback, estoura erro só se tiver errorhandler especifico, caso contrario, deixa para o momento em que for solicitado retorno
    oScript := EasyScriptJS():New(cScript,,if(valtype(bErrorHandler)=="B",bErrorHandler,))
EndIf
Self:oScriptList:Set(oScript:cId,oScript)

If Self:lConnected
    oScript:Fire(Self)
EndIf

return oScript:cId

Method getJSret(cId,cret,cError) Class EasyJS
Local oScript
Local nRet := -1//EasyGetBuffers('EASYJS',cId,@oScript)

If Self:oScriptList:Get(cId,@oScript) .AND. oScript <> NIL .AND. oScript:lResult
   If oScript:lError
      nRet := 1
      If PCount() >= 3 //Se recebeu o 3o parametro
         cError := oScript:cError
      ElseIf !oScript:lReturned //Se nao teve errorhandler no retorno, dispara agora
         oScript:SetError(Eval(Self:bErrorHandler,oScript:cError))
      EndIf
   EndIf

   If !oScript:lError //lError pode mudar pelo tratamento de erro acima
      nRet := 0
      cret := oScript:cValue
   EndIf
   FreeObj(oScript)
EndIf

return nRet

Method HasReturned(cId) Class EasyJS
Local uRet := ''
Local lRet := Self:oScriptList:Get(cId,@uRet)//EasyGetBuffers('EASYJS',cId,@uRet)
Return lRet .AND. uRet == NIL

Method SetTimeout(nTimeOut) Class EasyJS
If ValType(nTimeOut) == "N"
    Self:nTimeOut := nTimeOut
EndIf
Return Nil

Method isSmartClientHtml() Class EasyJS
Local cLib
GetRemoteType(@cLib)
return 'HTML' $ cLib

Static Function PreparaScript(cScript,cId)
Local cRet
Begincontent var cRet
{
    let retAdvpl = (value,c)=>{twebchannel.jsToAdvpl("%Exp:cId%"+(c?c:''),value)};
    let retAdvplChunk = (value)=>{retAdvpl(value,'_CHUNK')};
    let retAdvplError = (e)=>{console.log(e); retAdvpl(e,'_ERROR')};
    
    try {
        %Exp:cScript%
    } catch (e) { 
        retAdvplError(e) 
    }
}
endcontent
Return cRet

Static Function Seconds2(dData,cHora)
Default dData := date()
Default cHora := time()
Return (dData-stod('20000101'))*86400 + (val(substr(cHora,1,2))*3600) + (val(substr(cHora,4,2))*60) + val(substr(cHora,7,2))

Static Function UnitTest()
Local cRet := "", i, bOldErr, cRet2
Local oEasyJSSync   := EasyJS():New()
Local oEasyJS       := EasyJS():New()
Local oEasyJSCORS   := EasyJS():New()

conout('Teste de conexão websocket')
oEasyJSSync:AddLib('<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.4.1/jquery.min.js"></script>') //Testa lib da internet
oEasyJSSync:AddLib('<script src="https://ajax.googleapis.com/ajax/libs/threejs/r84/three.min.js"></script>')
oEasyJSSync:SetTimeout(5) //Teste com timeout para sincronas
oEasyJSSync:Activate(.T.) //Ativa o objeto e aguarda a conexao com o websocket no smartclient para seguir no advpl
If !oEasyJSSync:lConnected
    UserException('Falha de conexao com websocket')
EndIf

conout('Teste de execução de javascript (sincrono)')
cRet := oEasyJSSync:runJSSync('retAdvpl(1)')
If cRet <> '1'
    UserException('Falha na execução do javascript')
EndIf

cRet := ''
oEasyJSSync:SetTimeout(1)

conout('Teste para validar o timeout sincrono')
oEasyJSSync:runJSSync('setTimeout(()=>{retAdvpl(1)},3000)',{|x| cRet := x })
If cRet <> ''
    UserException('Falha ao estourar o timeout')
EndIf

//Ativando a classe de forma asincrona
conout('Teste para validar o conexão websocket assincrona')
oEasyJS:AddLib(GetApoRes('ASYNC.JS'))
oEasyJS:Activate() //Ativa o objeto sem aguardar a conexao com o smartclient para seguir no advpl
If oEasyJS:lConnected
    UserException('Falha ao conectar de forma assincrona')
EndIf

cRet := ''
aRet := {}

conout('Teste de javascript assincrono')

cRet := ''
oEasyJS:runJS("retAdvpl('a')",{|x| cRet += x})
oEasyJS:runJS("retAdvpl('b')",{|x| cRet += x})
oEasyJS:runJS("retAdvpl('c')",{|x| cRet += x})

oEasyJS:Wait()//Aguarda a resolução de todas as execuções javascript pendentes
If !'a' $ cRet .OR. !'b' $ cRet .OR. !'c' $ cRet //Pode retornar em ordem diferente, pois a execução é assincrona
    UserException('Falha no teste de javascript assincrono')
EndIf

oEasyJS:runJS("setTimeout(()=>{retAdvpl(2)},2000);",{|x| aAdd(aRet,x) })
oEasyJS:runJS("retAdvpl(window.async ? 1 : 0);",{|x| aAdd(aRet,x) }) //Testando se carregou a lib compilada. Esse retorno ocorrerá primeiro que o anterior.

//Executando um javascript de forma asincrona e pegando o retorno depois
cId := oEasyJS:runJS("retAdvpl(3);") //Segue a vida no advpl enquanto o javascript é processado

if !oEasyJS:Wait({|| len(aRet) == 2},5) //aguarda por 5 segundos os 3 primeiros retornarem
    UserException('Falha para receber retorno de um dos javascripts')
EndIf
for i := 1 To len(aRet)
    if aRet[i] <> alltrim(str(i))
        UserException('Falha no retorno do javascript numero '+alltrim(str(i)))
    EndIf
next i

aRet := {}
cId2 := oEasyJS:runJS("retAdvplChunk('teste_ok'); retAdvplChunk('teste2_ok'); retAdvpl('teste3_fim');",{|x| aAdd(aRet,x) }) //Irá retornar 3 mensagens para o advpl, e finaliza o retorno na terceira

conout('Teste de javascript com retorno em variavel de referencia')
cRet := NIL
oEasyJS:Wait({|| oEasyJS:getJSret(cId,@cret) >= 0},5) //Verifica se ja recebeu o retorno do 4o javascript e recebe na variavel cret
if cRet == NIL .OR. cRet <> '3'
    UserException('Falha ao retornar o 3o javascript')
EndIf

conout('Teste de javascript com retorno em partes')
If !oEasyJS:Wait({||oEasyJS:HasReturned(cId2)}) .OR. Len(aRet) < 3 .OR. aRet[1] <> 'teste_ok' .OR. aRet[2] <> 'teste2_ok' .OR. aRet[3] <> 'teste3_fim'
    UserException('Falha ao retornar o javascript em partes')
EndIf

conout('Teste de errorhandler padrão de forma assincrona')
cRet  := ''
cRet2 := ''

bOldErr := SysErrorBlock({|e| if(e:description == '1', cRet := 'ERROR',),if(e:description == '2', cRet2 := 'FALHA',),.T.})

cId  := oEasyJS:runJS('throw new Error("1")')
cId2 := oEasyJS:runJS('chamada_de_funcao_javascript_inexistente(2)',{|x| cRet2 := 'OK'})

oEasyJS:Wait({|| oEasyJS:getJSRet(cId,@cRet) >= 0 })

If cRet <> 'ERROR'
    UserException('Falha na execução do errorhandler padrão EasyJS')
EndIf

oEasyJS:Wait({|| oEasyJS:HasReturned(cId2) })
If cRet2 <> 'ERROR'
    UserException('Falha na execução do errorhandler padrão EasyJS')
EndIf

SysErrorBlock(bOldErr)

conout('Teste de errorhandler especifico de forma assincrona')
cRetErr := 'OK'
cId := oEasyJS:runJS('throw new Error("Erro2")',{|x| cRet := x},{|x| cRetErr := x})
oEasyJS:Wait({|| oEasyJS:HasReturned(cId)})
If cRetErr <> "Erro2"
    UserException('Falha na execução do errorhandler especifica EasyJS')
EndIf

cRetErr := 'OK'
cId := oEasyJS:runJS('throw new Error("Erro3")',,{|x| cRetErr := x})

oEasyJS:Wait({|| oEasyJS:getJSRet(cId,@cRet) >= 0})

If cRetErr <> "Erro3"
    UserException('Falha na execução do errorhandler especifica EasyJS')
EndIf

conout('Teste de errorhandler especifico tratado por variavel de referencia')
cRetErr := 'OK'
cId := oEasyJS:runJS('throw new Error("Erro4")')

oEasyJS:Wait({|| oEasyJS:getJSRet(cId,@cRet,@cRetErr) >= 0})

If cRetErr <> "Erro4"
    UserException('Falha na execução do errorhandler especifica EasyJS')
EndIf

oEasyJS:Destroy()

conout('Teste em api que nao valida CORS (funciona em todos os smartclients)')
cRet := ''
oEasyJSSync:RunJSSync("fetch('https://api.kwelo.com/v1/media/identicon/some.user@example.com?format=base64').then((a)=>a.text()).then((a)=>retAdvpl(a.length))",{|x| cRet := x})
If cRet == ''
    UserException('Falha ao executar API sem validação de CORS')
EndIf

conout('Teste de errorhandler padrão de forma sincrona')
bOldErr := SysErrorBlock({|| cRet := 'ERROR',.T.})
cRet := oEasyJSSync:runJSSync('retAdvplError(1)')
If cRet <> 'ERROR'
    UserException('Falha na execução do errorhandler padrão EasyJS')
EndIf
SysErrorBlock(bOldErr)

conout('Teste de errorhandler especifico de forma sincrona')
cRetErr := 'OK'
cRet := oEasyJSSync:runJSSync('throw new Error("Erro")',,{|x| cRetErr := x})
If cRetErr <> "Erro"
    UserException('Falha na execução do errorhandler especifico EasyJS')
EndIf

conout('Teste sobrescrevendo o errorhandler padrao de forma sincrona')
cRetErr := 'OK'
oEasyJSSync:SetErrorHandler({|x| cRetErr := x})
cRet := oEasyJSSync:runJSSync('throw new Error("Erro")')
If cRetErr <> "Erro"
    UserException('Falha na execução do errorhandler padrão EasyJS')
EndIf

conout('Teste de execução de javascript de lib da internet (sincrono)')
cRet := ''
oEasyJSSync:runJSSync('retAdvpl(window.jQuery && window.THREE ? 1 : 0)',{|x| cRet := x })
If cRet <> '1
    UserException('Falha ao carregar lib da internet')
EndIf

oEasyJSSync:Destroy()

oEasyJSCORS:SetTimeout(10)
oEasyJSCORS:cUrl := 'https://loripsum.net/404'
oEasyJSCORS:Activate()
conout('Teste em api que valida CORS (funciona apenas em smartclient windows)')
cRet := ''
oEasyJSCORS:RunJSSync("fetch('https://loripsum.net/api/10/short/headers').then((a)=>a.text()).then((a)=>retAdvpl(a.length))",{|x| cRet := x})
If cRet == ''
   If GetRemoteType() <> 5
      UserException('Falha ao executar API com validação de CORS')
   Else
      Conout('Falha esperada no teste de API com validação de CORS em ambiente HTML')
   EndIf
EndIf
oEasyJSCORS:Destroy()

Return .T.

Static Function EasyMemoRead(cFile)
Local cText := ""
Local nHdl  := fopen(cFile,0,1)
 
If nHDL >= 0
    FRead(nHdl,@cText,1024*8192)
    FClose(nHdl)
EndIf
 
Return cText

Static Function TWebChannelLib()
Local cRet, cAdd := ''
begincontent var cRet
"use strict";
/* globals window, document, console, MessageChannel, WebSocket, QWebChannel, CustomEvent */

/* jshint ignore:start */
// QWebChannel.min.js
function QObject(e, n, t) { function o(e, n) { var o = e[0], r = e[1]; i[o] = { connect: function(e) { return "function" != typeof e ? void console.error("Bad callback given to connect to signal " + o) : (i.__objectSignals__[r] = i.__objectSignals__[r] || [], i.__objectSignals__[r].push(e), void (n || "destroyed" === o || t.exec({ type: QWebChannelMessageTypes.connectToSignal, object: i.__id__, signal: r }))) }, disconnect: function(e) { if ("function" != typeof e) return void console.error("Bad callback given to disconnect from signal " + o); i.__objectSignals__[r] = i.__objectSignals__[r] || []; var a = i.__objectSignals__[r].indexOf(e); return -1 === a ? void console.error("Cannot find connection of signal " + o + " to " + e.name) : (i.__objectSignals__[r].splice(a, 1), void (n || 0 !== i.__objectSignals__[r].length || t.exec({ type: QWebChannelMessageTypes.disconnectFromSignal, object: i.__id__, signal: r }))) } } } function r(e, n) { var t = i.__objectSignals__[e]; t && t.forEach(function(e) { e.apply(e, n) }) } function a(e) { var n = e[0], o = e[1]; i[n] = function() { for (var e, n = [], r = 0; r < arguments.length; ++r) "function" == typeof arguments[r] ? e = arguments[r] : n.push(arguments[r]); t.exec({ type: QWebChannelMessageTypes.invokeMethod, object: i.__id__, method: o, args: n }, function(n) { if (void 0 !== n) { var t = i.unwrapQObject(n); e && e(t) } }) } } function s(e) { var n = e[0], r = e[1], a = e[2]; i.__propertyCache__[n] = e[3], a && (1 === a[0] && (a[0] = r + "Changed"), o(a, !0)), Object.defineProperty(i, r, { get: function() { var e = i.__propertyCache__[n]; return void 0 === e && console.warn('Undefined value in property cache for property "' + r + '" in object ' + i.__id__), e }, 
set: function(e) { return void 0 === e ? void console.warn("Property setter for " + r + " called with undefined value!") : (i.__propertyCache__[n] = e, void t.exec({ type: QWebChannelMessageTypes.setProperty, object: i.__id__, property: n, value: e })) } }) } this.__id__ = e, t.objects[e] = this, this.__objectSignals__ = {}, this.__propertyCache__ = {}; var i = this; this.unwrapQObject = function(e) { if (e instanceof Array) { for (var n = new Array(e.length), o = 0; o < e.length; ++o) n[o] = i.unwrapQObject(e[o]); return n } if (!e || !e["__QObject*__"] || void 0 === e.id) return e; var r = e.id; if (t.objects[r]) return t.objects[r]; if (!e.data) return void console.error("Cannot unwrap unknown QObject " + r + " without data."); var a = new QObject(r, e.data, t); return a.destroyed.connect(function() { if (t.objects[r] === a) { delete t.objects[r]; var e = []; for (var n in a) e.push(n); for (var o in e) delete a[e[o]] } }), a.unwrapProperties(), a }, this.unwrapProperties = function() { for (var e in i.__propertyCache__) i.__propertyCache__[e] = i.unwrapQObject(i.__propertyCache__[e]) }, this.propertyUpdate = function(e, n) { for (var t in n) { var o = n[t]; i.__propertyCache__[t] = o } for (var a in e) r(a, e[a]) }, this.signalEmitted = function(e, n) { r(e, n) }, n.methods.forEach(a), n.properties.forEach(s), n.signals.forEach(function(e) { o(e, !1) }); for (var e in n.enums) i[e] = n.enums[e] } var QWebChannelMessageTypes = { signal: 1, propertyUpdate: 2, init: 3, idle: 4, debug: 5, invokeMethod: 6, connectToSignal: 7, disconnectFromSignal: 8, setProperty: 9, response: 10 }, QWebChannel = function(e, n) { if ("object" != typeof e || "function" != typeof e.send) return void console.error("The QWebChannel expects a transport object with a send function and onmessage callback property. Given is: transport: " + typeof e + ", transport.send: " + typeof e.send); var t = this; this.transport = e, this.send = function(e) { "string" != typeof e && (e = JSON.stringify(e)), t.transport.send(e) }, this.transport.onmessage = function(e) { var n = e.data; switch ("string" == typeof n && (n = JSON.parse(n)), n.type) { case QWebChannelMessageTypes.signal: t.handleSignal(n); break; case QWebChannelMessageTypes.response: t.handleResponse(n); break; case QWebChannelMessageTypes.propertyUpdate: t.handlePropertyUpdate(n); break; default: console.error("invalid message received:", e.data) } }, this.execCallbacks = {}, this.execId = 0, this.exec = function(e, n) { return n ? (t.execId === Number.MAX_VALUE && (t.execId = Number.MIN_VALUE), e.hasOwnProperty("id") ? void console.error("Cannot exec message with property id: " + JSON.stringify(e)) : (e.id = t.execId++ , t.execCallbacks[e.id] = n, void t.send(e))) : void t.send(e) }, this.objects = {}, this.handleSignal = function(e) { var n = t.objects[e.object]; n ? n.signalEmitted(e.signal, e.args) : console.warn("Unhandled signal: " + e.object + "::" + e.signal) }, this.handleResponse = function(e) { return e.hasOwnProperty("id") ? (t.execCallbacks[e.id](e.data), void delete t.execCallbacks[e.id]) : void console.error("Invalid response message received: ", JSON.stringify(e)) }, this.handlePropertyUpdate = function(e) { for (var n in e.data) { var o = e.data[n], r = t.objects[o.object]; r ? r.propertyUpdate(o.signals, o.properties) : console.warn("Unhandled property update: " + o.object + "::" + o.signal) } t.exec({ type: QWebChannelMessageTypes.idle }) }, this.debug = function(e) { t.send({ type: QWebChannelMessageTypes.debug, data: e }) }, t.exec({ type: QWebChannelMessageTypes.init }, function(e) { for (var o in e) var r = new QObject(o, e[o], t); for (var o in t.objects) t.objects[o].unwrapProperties(); n && n(t), t.exec({ type: QWebChannelMessageTypes.idle }) }) }; "object" == typeof module && (module.exports = { QWebChannel: QWebChannel });
/* jshint ignore:end */

var getParam = function(queryField) {
	var url = window.location.href;
	queryField = queryField.replace(/[\[\]]/g, "\\$&");

	var regex = new RegExp("[?&]" + queryField + "(=([^&#]*)|&|#|$)", "i"),
		results = regex.exec(url);

	if (!results)
		return null;

	if (!results[2])
		return '';

	return decodeURIComponent(results[2].replace(/\+/g, " "));
}

var origin = getParam('totvstec_remote_origin');
if ((origin === null) || (origin === '')) {
	origin = '*'
}

window.onmessage = function(event) {
	var data = event.data;
	if ((origin !== '*') && (event.origin !== origin)) {
		console.log('unexpected origin', event.origin, origin);
		return;
	}
	if ((data.type ? data.type : '').toUpperCase() !== 'MS_WEBENGINERUNJAVASCRIPT') {
		console.log('unexpected message type');
		return;
	}

	eval(data.value);
}

var twebchannel = {
	// Versao
	version: "1.0.3",
	// Porta do WebSocket
	internalPort: 0,
	// Defines do OpenSettings e TestDevice
	BLUETOOTH_FEATURE: 1,
	NFC_FEATURE: 2,
	WIFI_FEATURE: 3,
	LOCATION_FEATURE: 4,
	CONNECTED_WIFI: 5,
	CONNECTED_MOBILE: 6,
	connect: function(callback) {
		var port = getParam('totvstec_websocket_port'),
			remoteType = getParam('totvstec_remote_type');
		this.init(port, remoteType, callback);
	},
	init: function(port, remoteType, callback) {
		this.internalPort = Number(port);
		this.remoteType = Number(remoteType);
		var fireEvent = function() {
			var event = new CustomEvent('twebchannelready');

			document.dispatchEvent(event);

			if (typeof callback === 'function')
				callback();
		};

		if (this.remoteType !== 5) {
			this.connectWS(fireEvent);
		}
		else {
			this.connectMessageChannel(fireEvent);
		}
	},
	jsToAdvpl: function(key, value) {
        //value = value.split(String.fromCharCode(10)).join('@!_10_@!')
        if(value instanceof Error)
            value = value.message;
        else if(!(typeof value === 'string' || value instanceof String))
            value = JSON.stringify(value)
		//console.log(key,value);
		if (this.remoteType !== 5) {
			window.dialog.jsToAdvpl(key, value);
		}
		else {
			this.sendMessageChannel(key, value);
		}
	},
	advplToJs: function(key, value) {
		console.log('not connected');
	},
	// Conecta WebSocket e prepara mensageria global
	connectWS: function(callback) {
        console.log('Starting Websocket...')
		var baseUrl = "ws://127.0.0.1:" + this.internalPort,
			socket = new WebSocket(baseUrl);

		socket.onclose = function() { console.error("WebChannel closed"); };
		socket.onerror = function(error) { console.error("WebChannel error: " + error); };
		socket.onopen = function() {
			new QWebChannel(socket, function(channel) {
				window.dialog = channel.objects.mainDialog;

				// Carrega mensageria global [CSS, JavaScript]
				window.dialog.advplToJs.connect(twebchannel.onReceiveAdvplToJs.bind(twebchannel));

				// Executa callback
				if (typeof callback === 'function')
					callback();
			});
		};
	},
	onReceiveAdvplToJs: function(key, value) {
		this.advplToJs(key, value);
	},
	connectMessageChannel: function(callback) {
		this.channel = new MessageChannel();
		this.channel.port1.onmessage = function(event) {
			var data = event.data,
				messageType = (data.type || 'UNDEFINED').toUpperCase();
			switch (messageType) {
				case 'CONNECTED':
					window.dialog = window.dialog || {};
					window.dialog.jsToAdvpl = twebchannel.sendMessageChannel.bind(twebchannel);
					if (typeof callback === 'function')
						callback();
					//this.queue.setMaxPendingPromises(1);
					break;
				case 'DISCONNECTED':
					console.log("received a DISCONNECTED message.", event);
					break;
				case 'EXEC':
					twebchannel.onReceiveAdvplToJs(
						data.value.type,
						data.value.content
					);
					break;
				case 'RETURN':
					break;
				default:
					console.error("invalid message: " + messageType, event);
					break;
			}
		};

		window.parent.postMessage({
			type: 'CONNECT',
			port: this.internalPort
		}, origin, [this.channel.port2]);
	},

	sendMessageChannel: function(key, value) {
		var message = {
			type: key,
			content: value,
			port: this.internalPort
		};
		this.channel.port1.postMessage(message);
	},

    addScriptTag: function(scripttag){
        let script = document.createElement('div');
        script.innerHTML = scripttag;
        script = script.getElementsByTagName('script')[0];

        let tag = document.createElement('script');
        tag.src = script.src;
        tag.onload = script.onload;
        tag.onerror = script.onerror;
        tag.text = script.text;
        document.documentElement.appendChild(tag);
    },

    addScript: function(script,accept,reject){
        let tag = document.createElement('script');
        tag.setAttribute("type", "text/javascript");
        tag.appendChild(document.createTextNode(script));
        if(accept){
            tag.onload = accept;
            tag.onerror = reject;
        };
        document.getElementsByTagName("head")[0].appendChild(tag);
    }
};
var script_load_error = async (event) =>{
    console.log(event);

    if(event.src)
    {
        await fetch(event.src).then((a)=>a.text()).then((c)=> new Promise((accept,reject)=>{twebchannel.addScript(c,accept,reject)}));
        //console.log("console c:" + "`" + c + "`");
    }

    return true;
}
var twebcon = function() {
    // Fecha conexao entre o AdvPL e o JavaScript via WebSocket
    twebchannel.connect( () => { 
        console.log('Websocket Connected!');
        twebchannel.jsToAdvpl('EASYJS_STATUS','CONNECTED')
    } );
    twebchannel.advplToJs = function(key, value) {
        //value = atob(value);
        //console.log(key,value)
        if (key.length > "EASYJS_SCRIPT".length && key.substring(0,"EASYJS_SCRIPT".length) === "EASYJS_SCRIPT") {
            twebchannel.addScript(value);
        }
    }
};
function create_UUID(){
    var dt = new Date().getTime();
    var uuid = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = (dt + Math.random()*16)%16 | 0;
        dt = Math.floor(dt/16);
        return (c=='x' ? r :(r&0x3|0x8)).toString(16);
    });
    return uuid;
}

function runAdvplRet(id, ret, retError){
    for(let i=0;i<window.RUN_ADVPL_INSTANCES.length;i++){
        if(window.RUN_ADVPL_INSTANCES[i].id == id){
            if(retError)
                window.RUN_ADVPL_INSTANCES[i].reject.apply(null,[retError]);
            else
                window.RUN_ADVPL_INSTANCES[i].accept.apply(null,[ret]);
            
            window.RUN_ADVPL_INSTANCES.splice(i,1);
        }
    }
};

function runAdvpl(){
    let parameters = Array.from(arguments);
    return new Promise((a,r)=>{
        //console.log('runAdvpl')
        
        let instance = {
            id : create_UUID(), 
            param : parameters,
            accept: a,
            reject: r
        };
        
        if(!window.RUN_ADVPL_INSTANCES)
            window.RUN_ADVPL_INSTANCES = [];
        window.RUN_ADVPL_INSTANCES.push(instance);

        twebchannel.jsToAdvpl("RUN_ADVPL:"+instance.id,{id : instance.id, param : instance.param});
    })
};

function advplFetch(){
    var retval = function(c){
        this.content = c;

        this.blob = ()=>{
            console.log(this.content);
            var binary_string = window.atob(this.content);
            var len = binary_string.length;
            var bytes = new Uint8Array(len);
            for (var i = 0; i < len; i++) {
                bytes[i] = binary_string.charCodeAt(i);
            }
            return bytes.buffer;
        }
    };

    return new Promise((a,r)=>{ runAdvpl('encode64(httpget(args[1][1]))',[...arguments]).then((content)=>a(new retval(content))).catch(r) });
};

endcontent

//If !isSmartClientHtml()
    begincontent var cAdd
        getParam = function(queryField) {
            queryField = queryField.replace(/[\[\]]/g, "\\$&");

            var regex = new RegExp("[?&]" + queryField + "(=([^&#]*)|&|#|$)", "i"),
                results = regex.exec(paramlist);

            if (!results)
                return null;

            if (!results[2])
                return '';

            return decodeURIComponent(results[2].replace(/\+/g, " "));
        }
    endcontent
//Endif
return cRet+cAdd
