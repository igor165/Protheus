#include "totvs.ch"
#include "easypoui.ch"

Class EasyPOUI
    Method New()
    Method SetSX3Field(cCampo)
    Method SetField(cJSON)

    Method GRDColAdd( oStrGridFd ) // Adicionar coluna no Grid 
    Method GRDColDel( cNameField ) // Remover coluna do Grid - cNameField = Property
    Method GRDLinAdd( aDataLines ) // Adiciona o array de dados das linhas do Grid
    Method GRDSetAct( xOperation ) // Adicionar ações permitidas no Header do Grid (3-INSERT / 4-EDIT / 5-DELETE )
    
    Method FRMSetVld( cField , bFuncValid ) //Método para setar uma validação em campo do Formulário POUI
    Method GRDSetVld( cField , bFuncValid ) //Método para setar uma validação em campo do Grid do POUI
    Method LINESetVld( cField , bFuncValid ) //Método para setar uma validação na linha do Grid do POUI    
    Method FRMSetTrg( cField , bFuncTrigg ) //Método para setar um gatilho em campo do Formulário POUI
    Method GRDSetTrg( cField , bFuncTrigg ) //Método para setar um gatilho em campo do Grid POUI
    MEthod FRMExeVld( xField , xNewValue, xOldValue )  //Método para executar validação\gatilho para campo do Formulário POUI
    Method GRDExeVld( xField , xNewValue, xOldValue)   //Método para executar validação\gatilho para campo do Grid POUI
    Method LINEExeVld(cRegra , jSonLine)  //Método para executar a validação do grid da linha do Grid POUI

    Method SetSXBF3()
    Method F3Service()
    Method CallBack()
    Method GetData()
    Method ClassName()
    Method Activate()

    data oAdapters
    data oForm
    data oFormData
    data oGridCols
    data oGridData
    data oGridActs
    data JFldFrmVld
    data JFldLineVld
    data JFldGrdVld
    data JFldFrmTrg
    data JFldGrdTrg
    data oEasyJS
    data cClassName

End Class

Method New(oDlg) Class EasyPOUI

    Local oEasyAutTt := Nil
    ::oForm     := JsonObject():New()
    ::oAdapters := JsonObject():New()
    ::oEasyJS   := EasyJS():New(oDlg)
    ::oFormData := JsonObject():New()
 
    ::oGridCols := JsonObject():New()
    ::oGridData := JsonObject():New()
    ::oGridActs := JsonObject():New()
    
    ::oForm['model'] := JsonObject():New()
    ::oForm['model']['code'] := "00000000000001"
    ::oForm['model']['name'] := STR0001 // "Tela de Cadastro Padrão"
    ::oForm['listFields'] := {}

    ::oGridCols['model'] := JsonObject():New()
    ::oGridCols['model']['code'] := "00000000000001"
    ::oGridCols['model']['name'] := "Detalhes de Cadastro Padrão"//STR0001 // "Tela de Cadastro Padrão"
    ::oGridCols['listColumns'] := {}

    ::JFldFrmVld := JsonObject():New()  //Armazena validações dos campos de formulário POUI
    ::JFldGrdVld := JsonObject():New()  //Armazena validações dos campos de grid POUI
    ::JFldLineVld := JsonObject():New()  //Armazena validações da linha do grid POUI    
    ::JFldFrmTrg := JsonObject():New()  //Armazena gatilhos dos campos de formulário POUI
    ::JFldGrdTrg := JsonObject():New()  //Armazena gatilhos dos campos de grid POUI
  
    ::oEasyJS:oWebChannel:bJsToAdvpl := {|oWC,key,value| Self:Callback(key,value) }

    ::oEasyJS:SetApp("EASYPOAPP")

    ::cClassName := "EASYPOUI"

    If EXISTBLOCK("EASYPOUI") 
        EXECBLOCK("EASYPOUI",.F.,.F.,{"INICIALIZA_OBJ_POUI",Self})
    EndIf

Return Self

Method ClassName() Class EasyPOUI
Return ::cClassName

Method CallBack(key,value) Class EasyPOUI
    Private oPOUI := Self
Return ::oEasyJS:CallBack(key,value)

Method Activate() Class EasyPOUI
Local lRet := .F.
Local aFiedsVld,aFieldsTRG,aFieldsGeral
Local cLib :=""

	::oEasyJS:AddLib(F3ServJS())
    

    ::oEasyJS:AddLib(setJS())

	::oEasyJS:SetTimeOut(10)
	If ::oEasyJS:Activate(.T.)

       //Carga de Visualização do formulário Capa/Detalhe
 // Carrega fields master
        aFieldsGeral:={}
        aFieldsVLD := ::JFldFrmVld:GetNames()
        aFieldsTRG := ::JFldFrmTrg:GetNames()

        AEval(aFieldsVLD,{|x| AAdd(aFieldsGeral,x)})
        AEval(aFieldsTRG,{|x| if(ASCAN(aFieldsGeral, x) == 0,AAdd(aFieldsGeral,x),.t.)})

        If Len( aFieldsGeral ) > 0
            cLib += SetFieldsVld(aFieldsGeral,"MASTER")+';' // AppComponent.fieldsValidation = ["empresa", "nome"];
        EndIf

        // Carrega fields detalhe
        aFieldsGeral:={}
        aFieldsVLD := ::JFldGrdVld:GetNames()
        aFieldsTRG := ::JFldGrdTrg:GetNames()

        AEval(aFieldsVLD,{|x| AAdd(aFieldsGeral,x)})
        AEval(aFieldsTRG,{|x| if(ASCAN(aFieldsGeral, x) == 0,AAdd(aFieldsGeral,x),.t.)})


        If Len( aFieldsGeral ) > 0
            cLib += SetFieldsVld(aFieldsGeral,"DETAIL")+';' // AppComponent.fieldsDetailValidation = ["empresa", "nome"];
        EndIf

       ::oEasyJS:runJSsync(cLib+'setJsExec();AppComponent.loadMasterByConsole('+Self:oForm:ToJSON()+'); AppComponent.loadDetailByConsole('+Self:oGridCols:ToJSON()+','+Self:oGridData:ToJSON()+'); retAdvpl("ok")',{|| lRet := .T.})

       If EXISTBLOCK("EASYPOUI")
          EXECBLOCK("EASYPOUI",.F.,.F.,{"ACTIVATE",Self})
       EndIf
    EndIf
Return lRet

Method GetData() Class EasyPOUI
    Self:oFormData := JsonObject():New()
    Self:oFormData:fromJSON(Self:oEasyJS:runJSSync('let oRet = {}; Object.keys(AppComponent.formData).map((key)=> oRet[key.toUpperCase()] = AppComponent.formData[key]); retAdvpl(oRet);'))
Return Self:oFormData

Method F3Service(cRequest) Class EasyPOUI
Local oAdapter, oReq, aParams, cRet, i, aF3, cWhere, cFilter

oReq := JsonObject():New()
oReq:fromJSON(cRequest)
aF3 := StrTokArr(oReq['url'],'/')

If (left(oReq['url'],3) == "DB/" .OR. left(oReq['url'],3) == "X5/" ) .AND. len(aF3) > 1

    oAdapter := FWAdapterBaseV2():New('GET',.T.)
    
    oReq['urlWithParams'] := StrTokArr(oReq['urlWithParams'],'?')
    if(len(oReq['urlWithParams']) > 1)
        aParams := StrTokArr(oReq['urlWithParams'][2],'&')
        oReq['urlWithParams'] := JsonObject():New()
        aEval(aParams,{|X| Y := StrTokArr(X,'='), oReq['urlWithParams'][Y[1]] := if(len(Y)>1,Y[2],nil) })
    
        oAdapter:setpage(val(oReq['urlWithParams']['page']))
        oAdapter:setPageSize(val(oReq['urlWithParams']['pageSize']))
        cFilter := oReq['urlWithParams']['filter']
    EndIf

    /*
    oAdapter:AddMapFields( AvSX3('YD_TEC',5)   , 'YD_TEC'    , .T., .T., { 'YD_TEC'   , 'C', TamSX3( 'YD_TEC'    )[1], 0 } )
    oAdapter:AddMapFields( AvSX3('YD_DESC_P',5), 'YD_DESC_P' , .T., .F., { 'YD_DESC_P', 'C', TamSX3( 'YD_DESC_P' )[1], 0 } )
    oAdapter:AddMapFields( AvSX3('YD_EX_NCM',5), 'YD_EX_NCM' , .T., .F., { 'YD_EX_NCM', 'C', TamSX3( 'YD_EX_NCM' )[1], 0 } )
    oAdapter:AddMapFields( AvSX3('YD_EX_NBM',5), 'YD_EX_NBM' , .T., .F., { 'YD_EX_NBM', 'C', TamSX3( 'YD_EX_NBM' )[1], 0 } )
    //oAdapter:SetFields(AvSX3('YD_TEC',5))
	oAdapter:SetWhere(" YD_FILIAL = '"+ FWxFilial('SYD') +"' AND SYD.D_E_L_E_T_ = ' '" )
    oAdapter:SetQuery("SELECT #QueryFields# FROM " + RetSqlName( 'SYD' ) + " SYD WHERE #QueryWhere#")
    oAdapter:SetOrder("YD_TEC,YD_DESC_P,YD_EX_NCM,YD_EX_NBM")
    */
    
    oF3 := Self:oAdapters[aF3[1]+'/'+aF3[2]]

    If left(oReq['url'],3) == "X5/"
        cFields := 'x5_chave,x5_descri'
        cFieldLabels := "código,descrição"

        oAdapter:AddMapFields( 'value', 'x5_chave' , .T., .F., {'x5_chave' , AvSx3('X5_CHAVE',2), AvSX3('X5_CHAVE',3), AvSX3('X5_CHAVE',4) } )
        oAdapter:AddMapFields( 'x5_chave', 'x5_chave' , .T., .F., {'x5_chave' , AvSx3('X5_CHAVE',2), AvSX3('X5_CHAVE',3), AvSX3('X5_CHAVE',4) } )
        oAdapter:AddMapFields( 'x5_descri', 'x5_descri' , .T., .F., {'x5_descri' , AvSx3('X5_DESCRI',2), AvSX3('X5_DESCRI',3), AvSX3('X5_DESCRI',4) } )
        If cFilter == nil
           cWhere :=  ""
        Else
           cWhere := " AND (X5_CHAVE LIKE '%" + cFilter + "%' OR X5_DESCRI LIKE '%" + cFilter + "%')"
        EndIf
    Else 

        cFields := ""
        cFieldLabels := ""
        //aEval(oF3['columns'],{|oCol|  })

        //oAdapter:SetFields(cFieldLabels)
        cWhere := if(cFilter== nil,""," AND (")
        For i := 1 To Len(oF3['columns'])
            oCol := oF3['columns'][i]
            cFieldLabels += Lower(oCol['label'])+','
            cFields      += oCol['property']+','
            oAdapter:AddMapFields( if(oCol['tipo']=='5','value',oCol['property']), oCol['property'] , .T., .F., {oCol['property'] , AvSx3(Upper(oCol['property']),2), AvSx3(Upper(oCol['property']),3), AvSx3(Upper(oCol['property']),4) } )
            if cFilter!= nil
              cWhere += if(i==1,""," OR ") + oCol['property'] + if(oCol['tipoDado'] == "N", " = " + cFilter, " like '%" + cFilter + "%'")
            EndIf 
        Next i
        cWhere += if(cFilter== nil,"",")")
        cFields := left(cFields,len(cFields)-1)
        cFieldLabels := left(cFieldLabels,len(cFieldLabels)-1)
    EndIf       
    oAdapter:SetQuery(oF3['query'])
    oAdapter:SetWhere(oF3['where']+if(len(aF3)>2,' AND '+Upper(oF3['ret'])+" = '"+aF3[3]+"' ",cWhere))
    oAdapter:SetOrder(cFields)
    oAdapter:SetFields(cFields)

    //oAdapter:SetFields(left(cFieldLabels,len(cFieldLabels)-1))
    //oAdapter:SetWhere(cWhere)
    //oAdapter:SetOrder(left(cFields,len(cFields)-1))
    //oAdapter:SetQuery("SELECT #QueryFields# FROM "+RetSqlName(cTab)+" "+cTab+" WHERE #QueryWhere#")

    if oAdapter:Execute()
        oAdapter:FillGetResponse()
        IF oAdapter:lOk
            cRet := oAdapter:GetJSONResponse()
            oRet := JsonObject():New()
            oRet:FromJSON(cRet)
            for i := 1 to len(oRet['items'])
               oRet['items'][i]['label'] := oRet['items'][i]['value'] := /*oRet['items'][i]['id'] :=*/ oRet['items'][i][oF3['ret']]
            next i
            If len(aF3) > 2
                If len(oRet['items']) > 0
                    cRet := oRet['items'][1]:toJSON()
                Else
                    cRet := ""
                EndIf
            else
                cRet := oRet:toJSON()
            EndIf
        Else
            UserException(oAdapter:CMESSAGE)
        EndIf
    Else
        UserException(oAdapter:CMESSAGE)
    EndIf
EndIf

Return cRet

static function setJS()
Local cRet
BeginContent var cRet
    function setJsExec(){
          AppComponent.protheusValidMaster = function protheusValidMaster(field, newValue, old){return runAdvpl('oPOUI:FRMExeVld(args[1],args[2],args[3])',field,newValue,old )}
          AppComponent.protheusValidDetail = function protheusValidDetail(field, newValue, old){return runAdvpl('oPOUI:GRDExeVld(args[1],args[2],args[3])',field,newValue,old )}
          AppComponent.protheusValidLine   = function protheusValidLine(jsonLine) {return runAdvpl('oPOUI:LINEExeVld(args[1])',jsonLine)}    
    }
EndContent
return cRet

static function F3ServJS()
Local cRet
BeginContent var cRet
    function searchService(request,HttpResponse){
        return new Promise((ac,rj) => {
            return runAdvpl("oPOUI:F3Service(args[1])",JSON.stringify(request)).then( (ret)=>{ 
                ac(new HttpResponse(
                    {
                        status: 200, 
                        body: (ret ? JSON.parse(ret) : '')
                    }
                ))
            }).catch((ret)=>{
                ac(new HttpResponse(
                    {
                        status: 400, 
                        body: ret
                    }
                ))
            })
        })
    }
EndContent
return cRet

Method SetSX3Field(cCampo) Class EasyPOUI
Local oCampo, oDePara, cF3, aColumns

Begin Sequence

    If ValType(cCampo) == "A"
        aEval(cCampo,{|X| Self:SetSX3Field(X)})
        Break
    EndIf

    oCampo  := JsonObject():New()
    oDePara := JsonObject():New()
    cF3     := avsx3(cCampo,8)
    aColumns:= {}

    oDePara:fromJSON('{ "types" : { "N" : "number", "C" : "string", "D" : "date", "undefined" : "currency", "undefined2" : "time"} }')

    oCampo['property']      := lower(allTrim(cCampo))
    oCampo['label']         := avsx3(cCampo,5)
    oCampo['type']          := oDePara['types'][avsx3(cCampo,2)]
    oCampo['order']         := avsx3(cCampo,1)
    //oCampo['divider']       := avsx3(cCampo,15)
    oCampo['required']      := X3Obrigat(cCampo)
    oCampo['optional']      := !X3Obrigat(cCampo)
    oCampo['gridColumns']   := 6
    oCampo['gridSmColumns'] := 12
    oCampo['maxLength']     := avsx3(cCampo,3)
    oCampo['value']         := ""

    If !Empty(cF3)
        Self:SetSXBF3(cF3,oCampo)
    EndIf

    Self:SetField(oCampo)

End Sequence

return Nil

Method SetField(oCampo) Class EasyPOUI
    aAdd(::oForm['listFields'],oCampo)
Return .T.

Method GRDColAdd( oStrGridFd ) Class EasyPOUI
   Local lRet := .F.
   If ValType(oStrGridFd) == "J"
      aAdd( ::oGridCols['listColumns'] , oStrGridFd )
      //::oGridCols['listColumns']:Set(jStrGridFd)
      If Valtype( ::oGridCols['listColumns'][Len(::oGridCols['listColumns'])]["order"] ) <> "U" .And. ;
      Empty(::oGridCols['listColumns'][Len(::oGridCols['listColumns'])]["order"])
         ::oGridCols['listColumns'][Len(::oGridCols['listColumns'])]["order"] := Alltrim(Str(Len(::oGridCols['listColumns'])))
      EndIf
      lRet := .T.
   EndIf
Return lRet

Method GRDColDel( cNameField ) Class EasyPOUI
   Local lRet := .F.
   Local nPos
   If ( nPos := aScan( ::oGrid['listColumns'] , {|x| x["property"] == cNameField} ) ) > 0
      aDel( ::oGrid['listColumns'] , nPos )
      aSize( ::oGrid['listColumns'] , Len(::oGrid['listColumns']) - 1 )
      lRet := .T.
   EndIf
Return lRet

Method GRDLinAdd( aDataLines ) Class EasyPOUI
Local lRet := .F.
If ValType(aDataLines) == "A"
    ::oGridData:Set(aDataLines)
    lRet := .T.
ENDIF
Return lRet

Method GRDSetAct( xOperation )  Class EasyPOUI
Local lRet := .F.
Local oAction,oIcon
Local lRet := .F.
Local cJson3, cJson4, cJson5,i
Default xOperation := 3

    If Valtype(xOperation) <> "A"
        xOperation := {xOperation}
    EndIf

    If aScan(xOperation,{|x| !(Alltrim(Str(x)) $ '3|4|5') }) == 0

        oAction  := JsonObject():New()
       // cJson3 := '{"action": "permite_insert","icon": "po-icon po-icon-plus-circle","tooltip": "Adiciona Linha","value": "insert"}'
       // cJson4 := '{"action": "permite_edit","icon": "po-icon po-icon-edit","tooltip": "Edita Linha","value": "edit"}'
        cJson5 := '{"action": "permite_remove","icon": "po-icon po-icon-delete","tooltip": "Remove Linha","value": "remove"}'

        oAction['property']      := "action"
        oAction['label']         := "Actions"
        oAction['type']          := "icon"
        oAction['icons']          := {}
        
        For i:=1 To Len(xOperation)
            oIcon := JsonObject():New()
            oIcon:FromJson(  If( xOperation[i] == 5, cJson5 , If( xOperation[i] == 4 , cJson4 , cJson3 )  )  )
            aAdd(oAction['icons'],oIcon)
        Next i

        aAdd(::oGridCols['listColumns'],oAction)

        FreeObj(oIcon)
        FreeObj(oAction)

        lRet := .T.
    EndIf

Return lRet

Method FRMSetVld( cField , bFuncValid ) class EasyPOUI
    ::JFldFrmVld[lower(cField)] := bFuncValid
Return .T.

Method LINESetVld( cRule , bFuncValid ) class EasyPOUI
    ::JFldLineVld[lower(cRule)] := bFuncValid
Return .T.

Method GRDSetVld( cField , bFuncValid ) class EasyPOUI
    ::JFldGrdVld[lower(cField)] := bFuncValid
Return .T.

Method FRMSetTrg( cField , bFuncTrigg , aFieldValue ) class EasyPOUI
Local i,JField,aJFields := {}

    If Len(aFieldValue) > 0
        JField := JsonObject():New()
        For i:= 1 To Len(aFieldValue)
            JField[ lower(aFieldValue[i][1]) ] := aFieldValue[i][2]
        Next i
        aAdd( aJFields , JField  )
    EndIf

    ::JFldFrmTrg[lower(cField)] := { bFuncTrigg , aJFields }

Return .T.

Method GRDSetTrg( cField , bFuncTrigg , aFieldValue ) class EasyPOUI
Local i,JField,aJFields := {}

    If Len(aFieldValue) > 0
        JField := JsonObject():New()
        For i:= 1 To Len(aFieldValue)
            JField[ lower(aFieldValue[i][1]) ] := aFieldValue[i][2]
        Next i
        aAdd( aJFields , JField  )
    EndIf

    ::JFldGrdTrg[lower(cField)] := { bFuncTrigg , aJFields }

Return .T.

Method SetSXBF3(cF3,oCampo) Class EasyPOUI
Local cTab, oCol, aCampo, cWhere, cSearch, cRetField

If ValType(Self:oAdapters[cSearch := 'DB/'+AllTrim(cF3)]) != "U" .OR. ValType(Self:oAdapters[cSearch := 'X5/'+AllTrim(cF3)]) != "U"
    oCampo['searchService'] := cSearch
    oCampo['columns']       := Self:oAdapters[cSearch]['columns']
ElseIf SXB->(dbSeek(cF3))
    Do While SXB->(!Eof() .AND. XB_ALIAS == cF3)

        If SXB->XB_TIPO == '1'
            If SXB->XB_COLUNA == 'DB'
                cTab := AllTrim(SXB->XB_CONTEM)
                oCampo['searchService'] := 'DB/'+AllTrim(cF3)
            Else
                EXIT
            EndIf
        ElseIf SXB->XB_TIPO == '2'
            
        ElseIf SXB->XB_TIPO == '4' .AND. SXB->XB_SEQ == '01'
            oCol := JsonObject():New()
            aCampo := strTokArr(AllTrim(SXB->XB_CONTEM),'>')

            If avsx3(if(Len(aCampo)>1,aCampo[2],aCampo[1]),,,.T.)
                oCol['property'] := lower(AllTrim(if(Len(aCampo)>1,aCampo[2],aCampo[1])))
                oCol['label']    := AllTrim(SXB->XB_DESCRI)
                oCol['tipo']     := AllTrim(SXB->XB_TIPO)  
                oCol['tipoDado'] :=  avsx3(aCampo[1],2)                

                if ValType(oCampo['columns']) != "A"
                    oCampo['columns'] := {}
                EndIf
                aAdd(oCampo['columns'], oCol )
            EndIf
        ElseIf SXB->XB_TIPO == '5' .AND. SXB->XB_SEQ == '01'
            aCampo := strTokArr(AllTrim(SXB->XB_CONTEM),'>')
            If avsx3(if(Len(aCampo)>1,aCampo[2],aCampo[1]),,,.T.)
                cRetField := lower(AllTrim(if(Len(aCampo)>1,aCampo[2],aCampo[1])))
            EndIf
        EndIf
        
        SXB->(dbSkip())
    EndDo

    cWhere := cTab+'.'+if(left(cTab,1)=="S",substr(cTab,2,2),cTab)+"_FILIAL = '"+ FWxFilial(cTab) +"' AND "+cTab+".D_E_L_E_T_ = ' '" 
ElseIf SX5->(dbSeek(xFilial()+AllTrim(cF3)))
    cTab := 'SX5'
    oCampo['searchService'] := 'X5/'+AllTrim(cF3)

    oCampo['columns'] := {}

    oCol := JsonObject():New()
    oCol['property'] := 'x5_chave'
    oCol['label']    := 'Código'
    oCol['tipo']     := '4'
    aAdd(oCampo['columns'], oCol )
    
    oCol := JsonObject():New()
    oCol['property'] := 'x5_descri'
    oCol['label']    := 'Descrição'
    oCol['tipo']     := '4'
    aAdd(oCampo['columns'], oCol )

    /*oCol := JsonObject():New()
    oCol['property'] := 'x5_chave'
    oCol['label']    := 'Código'
    oCol['tipo']     := '5'
    aAdd(oCampo['columns'], oCol )*/
    cRetField := 'x5_chave'

    cWhere := cTab+'.'+if(left(cTab,1)=="S",substr(cTab,2,2),cTab)+"_FILIAL = '"+ FWxFilial(cTab) +"' AND "+cTab+".D_E_L_E_T_ = ' ' AND X5_TABELA = '"+AllTrim(cF3)+"'" 
EndIf

If !Empty(cWhere)
    Self:oAdapters[oCampo['searchService']] := JsonObject():New()
    Self:oAdapters[oCampo['searchService']]['columns'] := oCampo['columns']
    Self:oAdapters[oCampo['searchService']]['ret']   := cRetField
    Self:oAdapters[oCampo['searchService']]['where'] := cWhere
    Self:oAdapters[oCampo['searchService']]['query'] := "SELECT #QueryFields# FROM "+RetSqlName(cTab)+" "+cTab+" WHERE #QueryWhere#"
EndIf

Return !Empty(cWhere)

//=========================================================//
 Method LINEExeVld(jSonLine) Class EasyPOUI
//=========================================================//
Local cMsgUnit:=""
Local jRet
Local aRules
Local aMsgVld:={}
Local i

jRet   := JsonObject():New()

aRules:= ::JFldLineVld:GetNames()
if Len(aRules) == 0
    jRet['valid']        := .T.
    jRet['errorMessage'] := ""
    jRet['fieldTrigged'] := {}   
Else
    For i:=1 to len(aRules)
        cMsgUnit := Eval(::JFldLineVld[aRules[i]],aRules[i],jSonLine )  
        if !Empty(cMsgUnit)      
           aAdd(aMsgVld,cMsgUnit)
        EndIf   
    Next    

    If len(aMsgVld)==0
        //Monta json de retorno OK
       jRet['valid']        := .T.
       jRet['errorMessage'] := {}
       jRet['fieldTrigged'] := {}    
    Else
        //Monta json de retorno ERRO da regra aplicada a este campo
       jRet['valid']        := .F.
       jRet['errorMessage'] := aMsgVld 
       jRet['fieldTrigged'] := {}         
    EndIf
EndIf

Return jRet


//=========================================================//
 Method FRMExeVld(xField,xNewValue,xOldValue) Class EasyPOUI
//=========================================================//
Local nPos     := 0
Local cJsonRet := ""
Local cMsgRet  := ""
Local cMsgVldFld := cMsgVldTrg := ""
Local jRet,lHasTrigg
Local aFieldsVld    

jRet   := JsonObject():New()
lHasTrigg := aScan(::JFldFrmTrg:GetNames(),Lower(xField)) > 0

//Verifica se existe e valida uma regra comum à todos os campos
If aScan(::JFldFrmVld:GetNames(),'*') > 0
    cMsgVldFld := Eval( ::JFldFrmVld['*'] ,xField,xNewValue,xOldValue )
EndIf

If Empty(cMsgVldFld)  //Valida uma regra específica deste campo
    If Empty(  cMsgVldFld := Eval( ::JFldFrmVld[xField] ,xField,xNewValue,xOldValue )    )
        //Monta json de retorno OK
        jRet['valid']        := .T.
        jRet['errorMessage'] := ""
        If lHasTrigg .And. Empty( cMsgVldTrg := Eval( ::JFldFrmTrg[xField][1] ,xField,xNewValue,xOldValue ) )
            jRet['fieldTrigged'] := ::JFldFrmTrg[xField][2]
        else
            jRet['fieldTrigged'] := {} 
        EndIf
    Else
        //Monta json de retorno ERRO da regra aplicada a este campo
        jRet['valid']        := .F.
        jRet['errorMessage'] := cMsgVldFld
        jRet['fieldTrigged'] := {}         
    EndIf
Else
    //Monta json de retorno ERRO da regra comum aplicada a todos os campos
    jRet['valid']        := .F.
    jRet['errorMessage'] := cMsgVldFld
    jRet['fieldTrigged'] := {}      
EndIf

Return jRet

Method GRDExeVld(xField,xNewValue,xOldValue) Class EasyPOUI
Local nPos     := 0
Local cJsonRet := ""
Local cMsgRet  := ""
Local cMsgVldFld := cMsgVldTrg := ""
Local jRet,lHasTrigg
Local aFieldsVld    

jRet   := JsonObject():New()
lHasTrigg := aScan(::JFldGrdTrg:GetNames(),Lower(xField)) > 0

//Verifica se existe e valida uma regra comum à todos os campos
If aScan(::JFldGrdVld:GetNames(),'*') > 0
    cMsgVldFld := Eval( ::JFldGrdVld['*'] ,xField,xNewValue,xOldValue )
EndIf
If Empty(cMsgVldFld)  //Valida uma regra específica deste campo
    If Empty(  cMsgVldFld := Eval( ::JFldGrdVld[xField] ,xField,xNewValue,xOldValue )    )
        //Monta json de retorno OK
        jRet['valid']        := .T.
        jRet['errorMessage'] := ""
        If lHasTrigg .And. Empty( cMsgVldTrg := Eval( ::JFldGrdTrg[xField][1] ,xField,xNewValue,xOldValue ) )
            jRet['fieldTrigged'] := ::JFldGrdTrg[xField][2]
        else
            jRet['fieldTrigged'] := {} 
        EndIf
    Else
        //Monta json de retorno ERRO da regra aplicada a este campo
        jRet['valid']        := .F.
        jRet['errorMessage'] := cMsgVldFld
        jRet['fieldTrigged'] := {}         
    EndIf
Else
    //Monta json de retorno ERRO da regra comum aplicada a todos os campos
    jRet['valid']        := .F.
    jRet['errorMessage'] := cMsgVldFld
    jRet['fieldTrigged'] := {}      
EndIf

Return jRet


Static Function SetFieldsVld(aFields,cModel)
Local cScript := If( cModel == "MASTER",'AppComponent.fieldsValidation = [','AppComponent.fieldsDetailValidation = [' )
Local i 

    For i:=1 To Len(aFields)
        cScript += '"'+Lower(aFields[i])+'"'
        If i < Len(aFields)
            cScript += ','
        EndIf 
    NExt i

    cScript += '];'

Return cScript
