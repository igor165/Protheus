#Include "Protheus.ch"
#Include "RwMake.ch"
#Include "FwBrowse.ch"
#INCLUDE "FWMVCDEF.CH"
#Include "FISA303.ch"


/*/{Protheus.doc} FISA303

    Tela de Cadastro de complemento de tributos

    @type  Function
    @author Erich Buttner
    @since 25/03/2020
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function FISA303 (cNumPed)

 	Local   oBrowse
    Local cAttIsMemberOf := "AttIsMemberOf"
    Private aRotina := MenuDef()
    
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias("CIP")
	oBrowse:SetDescription(STR0004) //Complemento de Tributos 
    oBrowse:SetFilterDefault( "CIP_PEDIDO=='"+cNumPed+"'" ) 

    If &cAttIsMemberOf.(oBrowse,"lBrwFilOn",.T.)
        oBrowse:lBrwFilOn := .F.
    EndIf

	oBrowse:Activate()
	
Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef                                     
Funcao generica MVC com as opcoes de menu

@author Erich Buttner
@since 25.03.2020
@version 1.0

/*/
//-------------------------------------------------------------------                                                                                            

Static Function MenuDef()

	Local aRotina := {}
	
	ADD OPTION aRotina TITLE STR0005 ACTION 'VIEWDEF.FISA303' OPERATION 2 ACCESS 0 //'Visualizar'
	ADD OPTION aRotina TITLE STR0006 ACTION 'VIEWDEF.FISA303' OPERATION 3 ACCESS 0 //'Incluir'
	ADD OPTION aRotina TITLE STR0007 ACTION 'VIEWDEF.FISA303' OPERATION 4 ACCESS 0 //'Alterar'
	ADD OPTION aRotina TITLE STR0008 ACTION 'VIEWDEF.FISA303' OPERATION 5 ACCESS 0 //'Excluir'
		
Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Funcao generica MVC do model

@author Erich Buttner
@since 25.03.2020
@version 1.0

/*/
//-------------------------------------------------------------------

Static Function ModelDef()

	Local oModel
	Local oStructCIP := NIL

    Default aCols := {}

    oStructCIP := FWFormStruct(1,"CIP")
	
	oModel	:=	MPFormModel():New('FISA303MOD',,{ |oModel| ValidForm(oModel) })
	
	oModel:AddFields('FISA303MOD',,oStructCIP)	

    oStructCIP:SetProperty('CIP_TPIMP'  , MODEL_FIELD_WHEN,  { || FSA303VLD() })
    oStructCIP:SetProperty('CIP_ITEM'   , MODEL_FIELD_WHEN,  { || FSA303VLD() })
    oStructCIP:SetProperty('CIP_VLTRIB' , MODEL_FIELD_VALID, { || FSAVLDVLR() })


Return oModel 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Erich Buttner
@since 25.03.2020
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

	Local oView      := FWFormView():New()
	Local oModel     := FWLoadModel("FISA303")
	Local oStructCIP := FWFormStruct(2,"CIP")	

	oView:SetModel(oModel)

	oView:AddField("VIEW_CAB",oStructCIP,'FISA303MOD')

	oStructCIP:SetProperty('CIP_ITEM'  , MVC_VIEW_ORDEM, "01" )
	oStructCIP:SetProperty('CIP_TPIMP' , MVC_VIEW_ORDEM, "02" )
	oStructCIP:SetProperty('CIP_VLTRIB', MVC_VIEW_ORDEM, "03" )
    
    oStructCIP:RemoveField('CIP_PEDIDO')
    oStructCIP:RemoveField('CIP_CLIENT')
    oStructCIP:RemoveField('CIP_LOJA')
    oStructCIP:RemoveField('CIP_PRODUT')
    oStructCIP:RemoveField('CIP_DOCORI')
    oStructCIP:RemoveField('CIP_SERORI')
    oStructCIP:RemoveField('CIP_ITORI')

	oView:CreateHorizontalBox("CABEC",100)

	oView:SetOwnerView("VIEW_CAB","CABEC")	
	
Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} ValidForm
Validação das informações digitadas

@author Rafael dos Santos
@since 22.02.2016
@version 1.0

/*/
//-------------------------------------------------------------------
Static Function ValidForm(oModel)    

	Local cTpImp	:= oModel:GetValue('FISA303MOD','CIP_TPIMP')
	Local nOp		:= oModel:GetOperation()
	Local lRet 		:= .T.
    Local cItem     := oModel:GetValue('FISA303MOD','CIP_ITEM')
    Local nVlr      := oModel:GetValue('FISA303MOD','CIP_VLTRIB')
    Local nProd     := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
    Local nDocOri   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_NFORI"})
    Local nSerOri   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_SERIORI"})
    Local nItemOri  := aScan(aHeader,{|x| AllTrim(x[2])=="C6_ITEMORI"})

    Local lAutomato := (Type("lAutoCom") <> "U" .And. (lAutoCom))
    Local aPedCom   := IF(lAutomato,aAutoPed,{})

    Public  aDadosCIP := {}

    If nOp == MODEL_OPERATION_INSERT
        
        If Empty(cItem)
            MsgAlert(STR0021) //"Favor preencher o item"
            Return .F.
        EndIf
        
        If Empty(cTpImp)
            MsgAlert(STR0020) //"Favor preencher o tipo do complemento"
            Return .F.
        EndIf

        DbSelectArea("CIP")
        CIP->(DbSetOrder(1))
        If CIP->(DbSeek(xFilial("CIP")+Iif(lAutomato,aPedCom[1],M->C5_NUM)+cItem+cTpImp))
            MsgAlert(STR0019) //Já existe registro cadastrado
            Return .F.
        EndIf     
    
    EndIf
    
    If nOp == MODEL_OPERATION_INSERT .Or. nOp == MODEL_OPERATION_UPDATE

        nPosItem := Ascan(aCols,{|x| x[1] == cItem })

        oModel:SetValue("FISA303MOD","CIP_PRODUT", aCols[nPosItem][nProd] )
        oModel:SetValue("FISA303MOD","CIP_ITEM"  , cItem )
        oModel:SetValue("FISA303MOD","CIP_DOCORI", aCols[nPosItem][nDocOri])
        oModel:SetValue("FISA303MOD","CIP_SERORI", aCols[nPosItem][nSerOri])
        oModel:SetValue("FISA303MOD","CIP_ITORI" , aCols[nPosItem][nItemOri])
        oModel:SetValue("FISA303MOD","CIP_CLIENT", Iif(lAutomato,aPedCom[2],M->C5_CLIENT))
        oModel:SetValue("FISA303MOD","CIP_LOJA"  , Iif(lAutomato,aPedCom[3],M->C5_LOJACLI))
        oModel:SetValue("FISA303MOD","CIP_PEDIDO", Iif(lAutomato,aPedCom[1],M->C5_NUM   ))
        
        If !lAutomato .and. !Empty(oComplTrib:aArray[1][1])
            aDadosCIP := aClone(oComplTrib:aArray)
        EndIf

        If nOp == MODEL_OPERATION_INSERT 

            Do Case
                Case cTpImp == "01"
                    aAdd(aDadosCIP,{cItem,STR0009 /*ICMS Proprio*/,nVlr})
                Case cTpImp == "02"
                    aAdd(aDadosCIP,{cItem,STR0010 /*FECP Proprio*/,nVlr})
                Case cTpImp == "03"
                    aAdd(aDadosCIP,{cItem,STR0011 /*ICMS ST*/,nVlr})
                Case cTpImp == "04"
                    aAdd(aDadosCIP,{cItem,STR0012 /*FECP ST*/,nVlr})
                Case cTpImp == "05"
                    aAdd(aDadosCIP,{cItem,STR0013 /*ICMS Complementar*/,nVlr})
                Case cTpImp == "06"
                    aAdd(aDadosCIP,{cItem,STR0014 /*FECP Complementar*/,nVlr})
                Case cTpImp == "07"
                    aAdd(aDadosCIP,{cItem,STR0015 /*DIFAL Origem*/,nVlr})
                Case cTpImp == "08"
                    aAdd(aDadosCIP,{cItem,STR0016 /*FECP DIFAL Origem*/,nVlr})
                Case cTpImp == "09"
                    aAdd(aDadosCIP,{cItem,STR0017 /*DIFAL Destino*/,nVlr})
                Case cTpImp == "10"
                    aAdd(aDadosCIP,{cItem,STR0018 /*FECP DIFAL Destino*/,nVlr})
            EndCase    

        ElseIf nOp == MODEL_OPERATION_UPDATE

            cDescTpImp := RetDesTp(cTpImp) 

            nPosItem := Ascan(aDadosCIP,{|x| x[1] == cItem .And. x[2] $ cDescTpImp })

            If nPosItem > 0
                aDadosCIP[nPosItem][3] := nVlr
            EndIf    

        EndIf

    ElseIf nOp == MODEL_OPERATION_DELETE
    	If !Empty(oComplTrib:aArray[1][1]) .And. Len(oComplTrib:aArray) > 1
            aDadosCIP := aClone(oComplTrib:aArray)
            cDescTpImp := RetDesTp(cTpImp) 
            nPosItem := Ascan(aDadosCIP,{|x| x[1] == cItem .And. x[2] $ cDescTpImp })
            If nPosItem > 0
                aDel(aDadosCIP,nPosItem)
                aSize(aDadosCIP,Len(aDadosCIP)-1)
            EndIf
        Else
            aAdd(aDadosCIP,{"","",0})
        EndIf    
    EndIf
    If !lAutomato
        oComplTrib:SetArray(aDadosCIP)
        oComplTrib:bLine := {|| {aDadosCIP[oComplTrib:nAt,01],aDadosCIP[oComplTrib:nAt,02],aDadosCIP[oComplTrib:nAt,03]}}
    Endif

Return lRet

/*/{Protheus.doc} COMPTRIB
    Aba de complemento de tributos
    @author Erich Buttner
    @since 20/03/2020
    @version 
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function COMPTRIB(oDlg,aPos,aHeadCIP,aColsCIP,lVisual,lInclui,cNumPed,aColsSC6,lAutoCom)

Local   oComplTrib
Default lAutoCom := .F.

Public aDadosCIP  :=  FSA303(cNumPed)

DbSelectArea("CIP")

aHeadCIP := {RetTitle("CIP_ITEM"),RetTitle("CIP_TPIMP"),RetTitle("CIP_VLTRIB")}

If Len(aDadosCIP)==0
	aDadosCIP	:=	{{"","",0}}
EndIf

If !lAutoCom
    oComplTrib	:=	TWBrowse():New( aPos[1],aPos[2],aPos[3],aPos[4],,aHeadCIP,,oDlg,,,,,,,,,,,,.F.,,.T.,,.F.,,, )
    oComplTrib:SetArray(aDadosCIP)
    oComplTrib:bLine := {|| {aDadosCIP[oComplTrib:nAt,01],aDadosCIP[oComplTrib:nAt,02],aDadosCIP[oComplTrib:nAt,03]} }
Endif

Return oComplTrib   


/*/{Protheus.doc} FSA303
    Retorna os valores gravados dos impostos
    @type  Static Function
    @author Erich Buttner
    @since 25/03/2020
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function FSA303 (cNumPed)

Local aDadosCIP := {}

DbSelectArea("CIP")
CIP->(DbSetOrder(1))
If CIP->(DbSeek(xFilial("CIP")+cNumPed))

    While CIP->(!EoF()) .And. CIP->CIP_FILIAL == xFilial("CIP") .And. CIP->CIP_PEDIDO == cNumPed

        cTpImp := CIP->CIP_TPIMP
        nVlr := CIP->CIP_VLTRIB

        Do Case
            Case cTpImp == "01"
                aAdd(aDadosCIP,{CIP->CIP_ITEM,AllTrim(STR0009) /*ICMS Proprio*/,nVlr})
            Case cTpImp == "02"
                aAdd(aDadosCIP,{CIP->CIP_ITEM,AllTrim(STR0010) /*FECP Proprio*/,nVlr})
            Case cTpImp == "03"
                aAdd(aDadosCIP,{CIP->CIP_ITEM,AllTrim(STR0011) /*ICMS ST*/,nVlr})
            Case cTpImp == "04"
                aAdd(aDadosCIP,{CIP->CIP_ITEM,AllTrim(STR0012) /*FECP ST*/,nVlr})
            Case cTpImp == "05"
                aAdd(aDadosCIP,{CIP->CIP_ITEM,AllTrim(STR0013) /*ICMS Complementar*/,nVlr})
            Case cTpImp == "06"
                aAdd(aDadosCIP,{CIP->CIP_ITEM,AllTrim(STR0014) /*FECP Complementar*/,nVlr})
            Case cTpImp == "07"
                aAdd(aDadosCIP,{CIP->CIP_ITEM,AllTrim(STR0015) /*DIFAL Origem*/,nVlr})
            Case cTpImp == "08"
                aAdd(aDadosCIP,{CIP->CIP_ITEM,AllTrim(STR0016) /*FECP DIFAL Origem*/,nVlr})
            Case cTpImp == "09"
                aAdd(aDadosCIP,{CIP->CIP_ITEM,AllTrim(STR0017) /*DIFAL Destino*/,nVlr})
            Case cTpImp == "10"
                aAdd(aDadosCIP,{CIP->CIP_ITEM,AllTrim(STR0018) /*FECP DIFAL Destino*/,nVlr})
        EndCase    

        CIP->(DbSkip())

    EndDo
EndIf

 Return aDadosCIP

 //-------------------------------------------------------------------
/*/{Protheus.doc} FSA303CB
Função responsável por montar as opções do combo de tipo de Complemento
tributos no pedido de venda

@author Erich Buttner    
@since 25/03/2020
@version P12.1.27

/*/
//-------------------------------------------------------------------
Function FSA303CB()                                                                                                                   

Local cRet  := ""

cRet	:= '01='+AllTrim(STR0009)+';'//ICMS Proprio
cRet	+= '02='+AllTrim(STR0010)+';'//FECP Proprio
cRet	+= '03='+AllTrim(STR0011)+';'//ICMS ST
cRet	+= '04='+AllTrim(STR0012)+';'//FECP ST
cRet	+= '05='+AllTrim(STR0013)+';'//ICMS Complementar
cRet	+= '06='+AllTrim(STR0014)+';'//FECP Complementar
cRet	+= '07='+AllTrim(STR0015)+';'//DIFAL Origem
cRet	+= '08='+AllTrim(STR0016)+';'//FECP DIFAL Origem
cRet	+= '09='+AllTrim(STR0017)+';'//DIFAL Destino
cRet	+= '10='+AllTrim(STR0018)+';'//FECP DIFAL Destino

Return cRet

 //-------------------------------------------------------------------
/*/{Protheus.doc} FSA303CB
Função responsável por montar as opções do combo de tipo de Complemento
tributos no pedido de venda

@author Erich Buttner    
@since 25/03/2020
@version P12.1.27

/*/
//-------------------------------------------------------------------
Function FSA303VLD()                                                                                                                   
    
Local oModel	:= 	FWModelActive()
Local lRet		:= .T.
Local cTpImp	:= oModel:GetValue ('FISA303MOD','CIP_TPIMP')
Local nOp		:= oModel:GetOperation()

If nOp == MODEL_OPERATION_UPDATE
   	lRet		:= .F.
EndIf        	

Return lRet

/*/{Protheus.doc} FSAVLDVLR
    Validação de complemento do tributo 
    com o valor total do item
    @type  Static Function
    @author Erich Buttner
    @since 01/04/2020
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function FSAVLDVLR()

Local oModel	:= FWModelActive()
Local cItem     := oModel:GetValue ('FISA303MOD','CIP_ITEM')
Local nVlTrib   := oModel:GetValue ('FISA303MOD','CIP_VLTRIB')
Local nOp		:= oModel:GetOperation()
Local lRet      := .T.
Local nPosVlr   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_VALOR"})

nPosItem := Ascan(aCols,{|x| x[1] == cItem })

If (nOp == MODEL_OPERATION_UPDATE .Or. nOp == MODEL_OPERATION_INSERT) .And. nPosItem > 0 .And. nPosVlr > 0 

    If nVlTrib > aCols[nPosItem][nPosVlr] 
        MsgAlert(STR0023+cValToChar(nVlTrib)+STR0024+cValToChar(aCols[nPosItem][nPosVlr]))//"Valor do Tributo digitado: " //" é maior do que o Valor digitado no item: "
        lRet := .F.
    EndIf
EndIf

Return lRet

/*/{Protheus.doc} RetDesTp ()
    (long_description)
    @type  Static Function
    @author Erich Buttner
    @since 27/03/2020
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
 Static Function RetDesTp(cTpImp)

Local cRet := ""

Do Case
    Case cTpImp == "01"
        cRet := AllTrim(STR0009) /*ICMS Proprio*/
    Case cTpImp == "02"
        cRet := AllTrim(STR0010) /*FECP Proprio*/
    Case cTpImp == "03"
        cRet := AllTrim(STR0011) /*ICMS ST*/
    Case cTpImp == "04"
        cRet := AllTrim(STR0012) /*FECP ST*/
    Case cTpImp == "05"
        cRet := AllTrim(STR0013) /*ICMS Complementar*/
    Case cTpImp == "06"
        cRet := AllTrim(STR0014) /*FECP Complementar*/
    Case cTpImp == "07"
        cRet := AllTrim(STR0015) /*DIFAL Origem*/
    Case cTpImp == "08"
        cRet := AllTrim(STR0016) /*FECP DIFAL Origem*/
    Case cTpImp == "09"
        cRet := AllTrim(STR0017) /*DIFAL Destino*/
    Case cTpImp == "10"
        cRet := AllTrim(STR0018) /*FECP DIFAL Destino*/
    EndCase    


Return cRet

/*/{Protheus.doc} F303CBOX(aCols)
    Combo box dos itens do pedido de venda
    (long_description)
    @type  Static Function
    @author Erich Buttner
    @since 27/03/2020
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function F303CBOX(aCols)

Local cRet := ""
Local nX := 0

For nX := 1 To Len(aCols)
    cRet += aCols[nX][01]+';'
Next nX


Return cRet

/*/{Protheus.doc} nomeFunction
    (long_description)
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
Function FSA303ALT(cNumPed,cItem,nItem)

Local cTabCIP := GetNextAlias()
Local cReferencia := ""


BeginSQL Alias cTabCIP

    SELECT CIP_ITEM, CIP_PEDIDO, CIP_TPIMP, CIP_VLTRIB
    FROM %table:CIP% CIP
    WHERE 
    CIP_FILIAL = %xfilial:CIP%
    AND CIP_PEDIDO =  %exp:cNumPed%
    AND CIP_ITEM = %exp:cItem%
    AND CIP.%NotDel%

EndSql

DbSelectArea (cTabCIP)

While (cTabCIP)->(!Eof())

    Do Case
        Case (cTabCIP)->CIP_TPIMP == "01" /*ICMS Proprio*/
            cReferencia := "IT_VALICM"
        Case (cTabCIP)->CIP_TPIMP == "02" /*FECP Proprio*/
            cReferencia := "IT_VALFECP"
        Case (cTabCIP)->CIP_TPIMP == "03" /*ICMS ST*/
            cReferencia := "IT_VALSOL"
        Case (cTabCIP)->CIP_TPIMP == "04" /*FECP ST*/
            cReferencia := "IT_VFECPST"
        Case (cTabCIP)->CIP_TPIMP == "05" /*ICMS Complementar*/
            cReferencia := "IT_VALCMP"
        Case (cTabCIP)->CIP_TPIMP == "06" /*FECP Complementar*/
            cReferencia := "IT_ALFCCMP"
        Case (cTabCIP)->CIP_TPIMP == "07" /*DIFAL Origem*/
            cReferencia := "IT_DIFAL"
        Case (cTabCIP)->CIP_TPIMP == "08" /*FECP DIFAL Origem*/
            cReferencia := "IT_VALFECP"
        Case (cTabCIP)->CIP_TPIMP == "09" /*DIFAL Destino*/
            cReferencia := "IT_DIFAL"
        Case (cTabCIP)->CIP_TPIMP == "10" /*FECP DIFAL Destino*/
            cReferencia := "IT_VFCPDIF"
    
    EndCase

    If !Empty(cReferencia)
        MaFisAlt(cReferencia,(cTabCIP)->CIP_VLTRIB,nItem, .T.)
    EndIf

    (cTabCIP)->(DbSkip())

EndDo

(cTabCIP)->(DBCloseArea())

Return

/*/{Protheus.doc} FSA303DEL(cNumPed)
    Exclusão de registros do complemento de tributos
    @type  Function
    @author Erich Buttner
    @since 28/03/2020
    @version version
    @param param, param_type, param_descr
    @return return, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Function FSA303DEL(cNumPed)

DbSelectArea("CIP")
CIP->(DbSetOrder(1))

If CIP->(DBSeek(xFilial("CIP")+cNumPed))

    While CIP->(!Eof()) .And. CIP->CIP_FILIAL == xFilial("CIP") .And. CIP->CIP_PEDIDO == cNumPed
        RecLock("CIP", .F.)
        CIP->(DBDelete())
        CIP->(MsUnlock())
        CIP->(DBSkip())
    EndDo
EndIf

Return .T.