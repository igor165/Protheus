#Include "GTPA284.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Static aG284Log     := {}
Static lG284MsgOn   := .f.
Static cG284Opera   := "0"   //1 = Geração; 2 = Estorno

//-------------------------------------------------------------------
/*/{Protheus.doc} GTPA284()
Cadastro de Lotes de Requisições
@author  Renan Ribeiro Brando
@since   29/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GTPA284() 

Local oBrowse := FWMBrowse():New()
oBrowse:SetAlias("GQY")
oBrowse:SetDescription(STR0001) // Lotes de Requisições //"Lotes de Requisições"
oBrowse:DisableDetails()
oBrowse:Activate()

Return oBrowse

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef()
Menu da Rotina
@author  Renan Ribeiro Brando
@since   29/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina TITLE STR0002 ACTION "VIEWDEF.GTPA284" OPERATION 2 ACCESS 0 // Visualizar //"Visualizar
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.GTPA284" OPERATION 3 ACCESS 0 // Incluir //"Incluir
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.GTPA284" OPERATION 4 ACCESS 0 // Alterar //"Alterar
ADD OPTION aRotina TITLE STR0005 ACTION "VIEWDEF.GTPA284" OPERATION 5 ACCESS 0 // Excluir //"Excluir
ADD OPTION aRotina TITLE STR0006 ACTION "GTPA288()" 	  OPERATION 3 ACCESS 0 // Gerar Massa de Lotes //"Gerar Massa de Lotes
ADD OPTION aRotina TITLE STR0007 ACTION "ProcIntFat(.f.)" OPERATION 6 ACCESS 0 // Gerar Fatura //"Pedido de Vendas
ADD OPTION aRotina TITLE STR0008 ACTION "ProcIntFat(.t.)" OPERATION 9 ACCESS 0 // Gerar Fatura //"Estorno P. Vendas
ADD OPTION aRotina TITLE STR0039 ACTION "GTPR283A()"	  OPERATION 2 ACCESS 0 // Imprimir Recibo
ADD OPTION aRotina TITLE STR0044 ACTION "GTPR286()"       OPERATION 8 ACCESS 0 // Recebimento de Requisição

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef()
Modelo de Dados da Rotina
@author  Renan Ribeiro Brando
@since   29/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()

Local oModel
Local oStruGQY     := FWFormStruct(1,"GQY")    //Lote
Local oStruGQW     := FWFormStruct(1,"GQW")    //Requisição
Local oStruG9Y     := FWFormStruct(1,"G9Y")    //Pedidos por Lote
Local aRelation    := {}
Local bCommit      := { |oModel| GA284Commit(oModel), .T.}
Local bPosValidMdl := { |oModel| GA284TdOK(oModel), .T.}
Local bPreLine     := { |a,b,c,d,e| GA284LinePre(a,b,c,d,e)}

SetModelStruct(oStruGQW,oStruGQY)

oModel := MPFormModel():New("GTPA284",/*bPreValidMdl*/, bPosValidMdl, /*bCommit*/, /*bCancel*/ )
oModel:SetCommit(bCommit)

oModel:SetDescription(STR0001) // Lotes de Requisições //"Lotes de Requisições"

oModel:AddFields("FIELDGQY", ,oStruGQY)

oModel:AddGrid("GRIDGQW", "FIELDGQY", oStruGQW, bPreLine, /*bPosLine*/, /*bPre*/, /*bPos*/, /*bLoad*/)
oModel:AddGrid("GRIDG9Y","FIELDGQY",oStruG9Y)

aRelation := {  { "GQW_FILIAL", "xFilial( 'GQY' )" },; 
                { "GQW_CODLOT", "GQY_CODIGO" },;
                { "GQW_CODCLI", "GQY_CODCLI"},;
                { "GQW_CODLOJ", "GQY_CODLOJ"},;
                { "GQW_STATUS", "GQY_STATUS"} }

oModel:SetRelation("GRIDGQW", aRelation , GQW->(IndexKey(1)))

aRelation := {  {"G9Y_FILIAL","XFILIAL('G9Y')"},;
                {"G9Y_LOTE","GQY_CODIGO"}}

oModel:SetRelation("GRIDG9Y", aRelation , G9Y->(IndexKey(1)))

oModel:GetModel("GRIDGQW"):SetMaxLine(9990)

oModel:GetModel("GRIDGQW"):SetOnlyQuery(.T.)
oModel:GetModel("GRIDG9Y"):SetOptional(.T.)
oModel:GetModel("GRIDGQW"):SetUniqueLine({"GQW_CODIGO"})

oModel:SetVldActivate({|oMdl| GA284VldAct(oMdl) })
oModel:SetActivate({|oModel| IniTotLiq(oModel)})

Return(oModel)

/*/{Protheus.doc} SetModelStruct
(long_description)
@type  Static Function
@author user
@since 09/12/2019
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetModelStruct(oStruGQW,oStruGQY)

Local aTrigger     := {}
Local bTrigLiq     := { |oMdl, cField, uValue| RetValLiq(oMdl, cField, uValue)}
Local bFldInit     := { |oMdl,cField,uVal,nLine,uOldValue|FieldInit(oMdl,cField,uVal,nLine,uOldValue)}
    
oStruGQW:AddField(""     , "", "GQW_MARK"  , "L", 1  , 0,{|| .T.},{|| .T.},{} , .T., NIL, .F., .T., .T.)
oStruGQY:AddField(STR0040, "", "GQY_VALIQ" , "N", 9  , 2, NIL    , NIL    ,NIL, .F., NIL, .F., .T., .T.)
oStruGQW:AddField(STR0040, "", "GQW_VALIQ" , "N", 9  , 2, NIL    , NIL    ,NIL, .F., NIL, .F., .T., .T.)

oStruGQY:AddTrigger("GQY_TOTDES", "GQY_TOTDES", {||.T.}, bTrigLiq)
oStruGQW:AddTrigger("GQW_TOTDES", "GQW_TOTDES", {||.T.}, bTrigLiq)

aTrigger := FwStruTrigger("GQY_CODLOJ","GQY_NOMCLI","Posicione('SA1',1,xFilial('SA1')+FwFldGet('GQY_CODCLI')+FwFldGet('GQY_CODLOJ'),'A1_NOME')" )	
oStruGQY:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

aTrigger := FwStruTrigger("GQY_STATUS","GQY_STATUS","GA284UpdStatus()" )	
oStruGQY:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

aTrigger := FwStruTrigger("GQW_CODIGO","GQW_CODIGO","GA284TrigReq()" )	
oStruGQW:AddTrigger(aTrigger[1],aTrigger[2],aTrigger[3],aTrigger[4])

oStruGQW:SetProperty('GQW_CODIGO', MODEL_FIELD_VALID, {|| .T.})
oStruGQW:SetProperty('GQW_MARK'  , MODEL_FIELD_VALID, {|| .T.})
oStruGQY:SetProperty("GQY_DTEMIS", MODEL_FIELD_VALID, {|oModel| GA284VldDate(oModel, "GQY_DTEMIS")})
oStruGQY:SetProperty("GQY_DTFECH", MODEL_FIELD_VALID, {|oModel| GA284VldDate(oModel, "GQY_DTFECH")})

If !GtpIsInPoui()
    oStruGQY:SetProperty('GQY_CODCLI', MODEL_FIELD_VALID, {|| .T.})
    oStruGQY:SetProperty('GQY_CODLOJ', MODEL_FIELD_VALID, {|| .T.})

    oStruGQW:SetProperty('GQW_CODCLI'    , MODEL_FIELD_VALID , {|| .T.})
    oStruGQW:SetProperty('GQW_CODLOJ'    , MODEL_FIELD_VALID , {|| .T.})
EndIf

oStruGQW:SetProperty("GQW_CODIGO", MODEL_FIELD_OBRIGAT, .F.)
oStruGQW:SetProperty("GQW_CODCLI", MODEL_FIELD_OBRIGAT, .F.)
oStruGQW:SetProperty("GQW_CODLOJ", MODEL_FIELD_OBRIGAT, .F.)
oStruGQW:SetProperty("GQW_MARK"  , MODEL_FIELD_OBRIGAT, .F.)
oStruGQW:SetProperty("GQW_CODAGE", MODEL_FIELD_OBRIGAT, .F.)
oStruGQW:SetProperty("GQW_NOMAGE", MODEL_FIELD_OBRIGAT, .F.)

oStruGQW:SetProperty("GQW_CODCLI", MODEL_FIELD_INIT, bFldInit)
oStruGQW:SetProperty("GQW_MARK"  , MODEL_FIELD_INIT, bFldInit)
oStruGQW:SetProperty("GQW_CODAGE", MODEL_FIELD_INIT, bFldInit)
oStruGQW:SetProperty("GQW_CODIGO", MODEL_FIELD_INIT, bFldInit)
oStruGQW:SetProperty("GQW_DATEMI", MODEL_FIELD_INIT, bFldInit)
oStruGQW:SetProperty("GQW_VALIQ" , MODEL_FIELD_INIT, bFldInit)
oStruGQY:SetProperty("GQY_VALIQ" , MODEL_FIELD_INIT, bFldInit)


Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef()
View da Rotina 
@author  Renan Ribeiro Brando
@since   29/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView
Local oModel	:= ModelDef()
Local oStruGQY	:= FWFormStruct(2, "GQY")
Local oStruGQW	:= FWFormStruct(2, "GQW")
Local oStruG9Y  := FWFormStruct(2,"G9Y")    //Pedidos por Lote

SetViewStruct(oStruGQW,oStruGQY)

GTPOrdVwStruct(oStruGQW,{{'GQW_CODIGO','GQW_CODORI'}})

oView := FWFormView():New()

oView:SetModel(oModel)
oView:AddField("VIEWGQY", oStruGQY, "FIELDGQY")
oView:AddGrid("VIEWGRIDGQW", oStruGQW, 'GRIDGQW') 
oView:AddGrid("VIEWGRIDG9Y", oStruG9Y, 'GRIDG9Y')

oView:CreateHorizontalBox( "SUPERIOR", 40)
oView:CreateHorizontalBox( "INFERIOR", 45)
oView:CreateHorizontalBox( "INFERIORPED", 15)

oView:SetOwnerView("VIEWGQY","SUPERIOR")
oView:SetOwnerView("VIEWGRIDGQW","INFERIOR")
oView:SetOwnerView("VIEWGRIDG9Y","INFERIORPED")

oView:GetModel('GRIDG9Y'):SetNoUpdateLine(.T.)


Return oView        

/*/{Protheus.doc} SetViewStruct
(long_description)
@type  Static Function
@author user
@since 09/12/2019
@version version
@param param_name, param_type, param_descr
@return return_var, return_type, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SetViewStruct(oStruGQW,oStruGQY)

oStruGQW:AddField("GQW_MARK"  , "01","","",{""},"GET","@!",NIL,"",.T.,NIL,NIL,{},NIL,NIL,.F.)
oStruGQY:AddField("GQY_VALIQ" , "13", STR0040, "", NIL, "N", "@E 999,999.99", NIL, Nil, .T., NIL, NIL, Nil, NIL, NIL, .F., NIL)
oStruGQW:AddField("GQW_VALIQ" , "13", STR0040, "", NIL, "N", "@E 999,999.99", NIL, Nil, .T., NIL, NIL, Nil, NIL, NIL, .F., NIL)

oStruGQY:AddGroup("GRUPO_DADOSCLI", "", "", 2)
oStruGQY:SetProperty("GQY_CODIGO", MVC_VIEW_GROUP_NUMBER, "GRUPO_DADOSCLI")
oStruGQY:SetProperty("GQY_DESCRI", MVC_VIEW_GROUP_NUMBER, "GRUPO_DADOSCLI")
oStruGQY:SetProperty("GQY_CODCLI", MVC_VIEW_GROUP_NUMBER, "GRUPO_DADOSCLI")
oStruGQY:SetProperty("GQY_CODLOJ", MVC_VIEW_GROUP_NUMBER, "GRUPO_DADOSCLI")
oStruGQY:SetProperty("GQY_NOMCLI", MVC_VIEW_GROUP_NUMBER, "GRUPO_DADOSCLI")
oStruGQY:SetProperty("GQY_DTEMIS", MVC_VIEW_GROUP_NUMBER, "GRUPO_DADOSCLI")
oStruGQY:SetProperty("GQY_DTFECH", MVC_VIEW_GROUP_NUMBER, "GRUPO_DADOSCLI")

oStruGQY:AddGroup("GRUPO_NOTA", "", "", 2)
oStruGQY:SetProperty("GQY_STATUS", MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA")
oStruGQY:SetProperty("GQY_NOTA"  , MVC_VIEW_GROUP_NUMBER, "GRUPO_NOTA")

oStruGQY:AddGroup("GRUPO_VALOR", "", "", 2)
oStruGQY:SetProperty("GQY_TOTAL" , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR")
oStruGQY:SetProperty("GQY_TOTDES", MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR")
oStruGQY:SetProperty("GQY_VALIQ" , MVC_VIEW_GROUP_NUMBER, "GRUPO_VALOR")

oStruGQY:SetProperty("GQY_VALIQ", MVC_VIEW_CANCHANGE, .F.)
oStruGQW:SetProperty("GQW_VALIQ", MVC_VIEW_CANCHANGE, .F.)

oStruGQW:SetProperty("GQW_CODIGO", MVC_VIEW_LOOKUP , "GQW")
oStruGQW:RemoveField("GQW_CODCLI")
oStruGQW:RemoveField("GQW_CODLOJ")
oStruGQW:RemoveField("GQW_NOMCLI")
oStruGQW:RemoveField("GQW_CODAGE")
oStruGQW:RemoveField("GQW_NOMAGE")
oStruGQW:RemoveField("GQW_CODLOT")

oStruGQW:SetProperty("*"			, MVC_VIEW_CANCHANGE , .F.)
oStruGQW:SetProperty("GQW_CODIGO"	, MVC_VIEW_CANCHANGE , .T.)
oStruGQW:SetProperty("GQW_MARK"	    , MVC_VIEW_CANCHANGE , .T.)    
Return 

//-------------------------------------------------------------------
//-------------------------------------------------------------------
/*/{Protheus.doc} GA284VldDate(cDate)
Função que valida datas de emissão e fechamento da requisição
@author  Renan Ribeiro Brando
@since   27/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function GA284VldDate(oModel, cDate)
Local lRet := .T.

DO CASE
    // Verifica se a data de emissão é menor que a data atual
    CASE (cDate == "GQY_DTEMIS")
        IF (oModel:GetValue("GQY_DTEMIS") < dDataBase )
            lRet := .F.
            oModel:GetModel():SetErrorMessage(oModel:GetModel():GetId(),,oModel:GetModel():GetId(),,STR0011, STR0009, STR0010) //"A data de emissão não pode ser inferior a data atual." //"Verifique a data do sistema ou data do campo." //"Data Inválida"
        ENDIF
    // Verifica se a data de fechamento é menor que a data de abertura
    CASE (cDate == "GQY_DTFECH")
         IF (oModel:GetValue("GQY_DTFECH") < oModel:GetValue("GQY_DTEMIS"))
            lRet := .F.
            oModel:GetModel():SetErrorMessage(oModel:GetModel():GetId(),,oModel:GetModel():GetId(),,STR0011, STR0012, STR0013) //"A data de fechamento não pode ser inferior a data de emissão." //"Escolha uma data de fechamento superior." //"Data Inválida"
        ENDIF
    OTHERWISE
        lRet := .F.
ENDCASE

Return lRet
/*/{Protheus.doc} GA284TrigReq()
Gatilho que preenche o grid com os valores da requisição
@author  Renan Ribeiro Brando
@since   30/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Function GA284TrigReq()

Local oModel    := FwModelActive()
Local oGridGQW := oModel:GetModel("GRIDGQW")

GQW->(DbSetOrder(1))

If  GQW->(DbSeek(xFilial("GQW") + oGridGQW:GetValue("GQW_CODIGO")))
	oGridGQW:SetValue("GQW_REQDES" , GQW->GQW_REQDES)     
	oGridGQW:SetValue("GQW_DATEMI" , GQW->GQW_DATEMI)
	oGridGQW:SetValue("GQW_CODCLI" , GQW->GQW_CODCLI)
	oGridGQW:SetValue("GQW_CODAGE" , GQW->GQW_CODAGE)
	oGridGQW:SetValue("GQW_TOTAL"  , GQW->GQW_TOTAL)
	oGridGQW:SetValue("GQW_TOTDES" , GQW->GQW_TOTDES)
	oGridGQW:SetValue("GQW_CONFER" , GQW->GQW_CONFER)
	oGridGQW:SetValue("GQW_STATUS" , GQW->GQW_STATUS)
	oGridGQW:SetValue("GQW_CODLOT" , GQW->GQW_CODLOT)
	oGridGQW:SetValue("GQW_CODORI" , GQW->GQW_CODORI)
Endif
Return NIL

//-------------------------------------------------------------------
/*/{Protheus.doc} GA284Commit(oModel)
Bloco de commit
@author  Renan Ribeiro Brando
@since   30/05/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function GA284Commit(oModel)
Local lRet := .F.
Local nX := 1

GQW->(DBSetOrder(1)) // GQW_FILIAL + GQW_CODIGO

For nX := 1 to oModel:GetModel("GRIDGQW"):Length()

	IF (GQW->(DBSeek(xFilial("GQW") + oModel:GetModel("GRIDGQW"):GetValue("GQW_CODIGO", nX))))

		If !oModel:GetModel("GRIDGQW"):IsDeleted(nX) .And. oModel:GetOperation() <> MODEL_OPERATION_DELETE 
			RECLOCK("GQW",.F.)
                GQW->GQW_CODLOT := oModel:GetModel("FIELDGQY"):GetValue("GQY_CODIGO")
                GQW->GQW_STATUS := oModel:GetModel("GRIDGQW"):GetValue("GQW_STATUS")
            GQW->(MSUNLOCK())

            lRet := .T.
		Else
			RECLOCK("GQW",.F.)
                GQW->GQW_CODLOT := ""
                GQW->GQW_STATUS := oModel:GetModel("GRIDGQW"):GetValue("GQW_STATUS",nX)
            GQW->(MSUNLOCK())

            lRet := .T.
            
		Endif

		IF !( lRet )
			Exit
		ENDIF

	ENDIF

Next

FWFormCommit(oModel)

Return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} GA284LinePre(oModelGIC, nLine, cOperation, cField, uValue)
description
@author  Renan Ribeiro Brando   
@since   13/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function GA284LinePre(oModelGQW, nLine, cOperation, cField, uValue)

Local lRet := .T.

Local oModel := oModelGQW:GetModel()
Local oModelGQY := oModel:GetModel("FIELDGQY")

Local nValTot := oModelGQY:GetValue("GQY_TOTAL")
Local nDesTot := oModelGQY:GetValue("GQY_TOTDES")

Local cLote     := ""         
Local cTitle    := ""
Local cMsgProb  := ""
Local cMsgSolu  := ""

IF (cOperation == "DELETE")
    // Pega o valor do registro posicionado no delete 
    nValTot -= oModelGQW:GetValue("GQW_TOTAL", nLine)
    nDesTot -= oModelGQW:GetValue("GQW_TOTDES", nLine)
    
    oModelGQY:SetValue("GQY_TOTAL", nValTot)
    oModelGQY:SetValue("GQY_TOTDES", nDesTot)
    
ELSEIF (cOperation == "UNDELETE") 
    nValTot += oModelGQW:GetValue("GQW_TOTAL", nLine)
    nDesTot += oModelGQW:GetValue("GQW_TOTDES", nLine)
    
    oModelGQY:SetValue("GQY_TOTAL", nValTot)
    oModelGQY:SetValue("GQY_TOTDES", nDesTot)
    
ELSEIF (cOperation == "SETVALUE" .AND. cField == "GQW_TOTAL")
    If GtpIsInPoui()
        // Se a linha está sendo modificada deve subtrair o valor da requisição atual do total
        IF (oModelGQW:IsUpdated(nLine))
            nValTot -= oModelGQW:GetValue("GQW_TOTAL", nline)
        ENDIF
        // Utiliza o parâmetro uValue que corresponde ao valor do campo GQW_TOTAL (NÃO USAR oModel:GetValue()!)
        nValTot +=  uValue
        oModelGQY:SetValue("GQY_TOTAL", nValTot)
    EndIf
    
ELSEIF (cOperation == "SETVALUE" .AND. cField == "GQW_TOTDES")
    If GtpIsInPoui()
        // Se a linha está sendo modificada deve subtrair o valor da requisição atual do total
        IF (oModelGQW:IsUpdated(nLine))
            nDesTot -= oModelGQW:GetValue("GQW_TOTDES", nline)
        ENDIF
        // Utiliza o parâmetro uValue que corresponde ao valor do campo GQW_TOTAL (NÃO USAR oModel:GetValue()!)
        nDesTot +=  uValue
        oModelGQY:SetValue("GQY_TOTDES", nDesTot)
    EndIf
    
ElseIf ( cOperation == "SETVALUE" )

    If ( cField == "GQW_CODIGO" )
        
        If ( Empty(oModelGQY:GetValue("GQY_CODCLI")) .Or. Empty(oModelGQY:GetValue("GQY_CODLOJ")) )
            
            lRet := .f.
            
            cTitle      := STR0014 //"Inválido"
            cMsgProb    := STR0015 //"Cliente não foi preenchido."
            cMsgSolu    := STR0016  //"Preencha o código e loja do cliente."
            
        Else

            lRet := GA284VldReq(uValue,oModelGQY:GetValue("GQY_CODCLI"),oModelGQY:GetValue("GQY_CODLOJ")) 

            If ( !lRet )
                
                cTitle      := STR0014 //"Inválido"
                cMsgProb    := STR0017 //"Esta requisição para o cliente "
                cMsgProb	+= Alltrim(oModelGQY:GetValue("GQY_NOMCLI")) + ", "
                cMsgProb	+= STR0032 //"não existe ou não foi conferida"
                cMsgSolu    := STR0018 //"Confira o cadastro desta requisição para este cliente."
            EndIf

        EndIf

        If ( lRet )
            
            cLote := GA284ExistLote(uValue,oModelGQY:GetValue("GQY_CODCLI"),oModelGQY:GetValue("GQY_CODLOJ"),oModelGQY:GetValue("GQY_CODIGO"))

            If ( !Empty(cLote) )

                lRet := .F.

                cTitle      := STR0019 //"Requisição possui lote"
                cMsgProb    := STR0020 + Alltrim(cLote) //"Esta requisição foi vinculada a outro lote. O número de lote é "
                cMsgSolu    := STR0021  //"Selecione outra requisição."

            EndIf

        EndIf

    EndIf

    If ( !lRet )
    
        oModelGQW:GetModel():SetErrorMessage(oModelGQW:GetModel():GetId(),,oModelGQW:GetModel():GetId(),,cTitle,cMsgProb,cMsgSolu)

    EndIf
    
ENDIF

Return lRet

//------------------------------------------------------------------------------
/*/{Protheus.doc} ProcIntFat

@type Function
@author 
@since 10/12/2019
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function ProcIntFat(lEstorno,lMsgOn)
Default lEstorno:= .f.
Default lMsgOn  := .t.
    FwMsgRun(,{|| GA284IntFat(lEstorno,lMsgOn) },,STR0041 )
Return 

/*/{Protheus.doc} GA284IntFat
    Função para fazer a integração entre os lotes com o pedido de vendas   
    @type  Function
    @author Fernando Radu Muscalu
    @since 21/06/2017
    @version version
    @param 
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/  
Function GA284IntFat(lEstorno,lMsgOn)

Local oModel    := FwLoadModel("GTPA284")

Local aErro     := {}

Local cLote     := ""
Local cMsgProc	:= ""

Local lOk       := .t.
Local lErroMVC	:= .f.

Default lEstorno:= .f.
Default lMsgOn  := .t.

If ( lEstorno )
	cMsgProc 	:= STR0022 //"Estornando Pedido(s) de Vendas do Lote "
	cStatus		:= "1"
    cG284Opera  := "2"
Else
	cMsgProc := STR0023 //"Gerando Pedido(s) de Vendas do Lote "
	cStatus		:= "2"
    cG284Opera  := "1"
EndIf

If ( GQY->GQY_STATUS == cStatus )

    lG284MsgOn := lMsgOn  //não mostrar interface

    oModel:SetOperation(MODEL_OPERATION_UPDATE)

    If ( oModel:Activate() )
        
        cLote := oModel:GetModel("FIELDGQY"):GetValue("GQY_CODIGO")
    
        Begin Transaction
            
            //FWMsgRun( ,{|| lOk := GA284PedVen(oModel,lEstorno) },,cMsgProc + cLote )
            
            CursorWait()
            
            lOk := GA284PedVen(oModel,lEstorno)
            
            If ( lOk )
    
                If ( oModel:VldData() )
                    lOK := oModel:CommitData()
                Else
                    lOk := .f.
                    lErroMVC := .t.
                EndIf
            
            EndIf
    
            If ( !lOk )
                DisarmTransaction()
            EndIf
    
        End Transaction    
    	
    	CursorArrow()
    	
        If ( !lOk )
            
            If ( lErroMVC )
            
                If ( lG284MsgOn )
                    JurShowErro( oModel:GetModel():GetErrormessage() )
                Else    
                    GA284SetLog("MVC")    
                EndIf
            
            EndIf
            
        EndIf
        
        oModel:DeActivate()	

    Else
        
        lOk := .f.
        
        If ( lG284MsgOn )
            aErro := oModel:GetErrorMessage()
            FWAlertHelp(aErro[6],aErro[7],aErro[5])
        Else
            GA284SetLog("MVC")
        EndIf

    EndIf

    oModel:Destroy()

EndIf

If !IsBlind()
    If lEstorno .AND. lOk
    	MsgAlert(STR0042)
    ElseIf !(lEstorno) .AND. lOk
    	MsgAlert(STR0043)
    EndIf
EndIf

Return(lOk)

/*/{Protheus.doc} GTPCreateTable()
    Define as estruturas do MVC - View e Model
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 13/06/2017
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    (examples)
    @see (links_or_references)
/*/
Function GA284PedVen(oMdlLote,lEstorno)

Local oSubGQY   := oMdlLote:GetModel("FIELDGQY")
Local oSubG9Y	:= oMdlLote:GetModel("GRIDG9Y")
	
Local aSC5      := {}
Local aSC6      := {}
Local aItem     := {}
Local aPedidos  := {}

Local aArea     := GQV->(GetArea())
Local aAreaSC5  := SC5->(GetArea())
Local aAreaSC6  := SC6->(GetArea())

Local cChave    := ""
Local cFilSeek  := ""

Local nI        := 0
Local nQtdPV    := 0    //Total que irá compor o pedido de vendas
Local nTotalAb  := 0    //Soma abatida para 

Local lRet  	:= .T.

Private lMsErroAuto := .f.
Private lMsHelpAuto := .T. 

Default lEstorno	:= .f.

If ( !lEstorno )

	//Busca pelos parâmetros do cliente
	GQV->(DBSetOrder(1))    //GQV_FILIAL+GQV_CODIGO
	
	cChave := XFilial("GQV")
	cChave += PadR(oSubGQY:GetValue("GQY_CODCLI"),TamSX3("GQV_CODIGO")[1])
	cChave += PadR(oSubGQY:GetValue("GQY_CODLOJ"),TamSX3("GQV_CODLOJ")[1])
	
	If ( GQV->(DbSeek(cChave)) )
	    
	    //Cabeçalho do pedido de vendas
	    aAdd(aSC5,{"C5_TIPO","N",Nil})  //Tipo do Pedido = Normal
	    aAdd(aSC5,{"C5_CLIENTE",oSubGQY:GetValue("GQY_CODCLI"),Nil})
	    aAdd(aSC5,{"C5_LOJA",oSubGQY:GetValue("GQY_CODLOJ"),Nil})
	    aAdd(aSC5,{"C5_TIPOCLI","F",Nil})   //Tipo de Cliente = Consumidor final
	    aAdd(aSC5,{"C5_CONDPAG",GQV->GQV_COND,Nil})
	    aAdd(aSC5,{"C5_ORIGEM","GTPA284",Nil})
	
	    lRet := GQV->GQV_GERNOT == "1" .And.;   //Gera Nota, fatura?
	            !Empty(GQV->GQV_TES) .And. GQV->GQV_TES >= '501' .And.;   //Possui TES preenchida e é maior ou igual a 500
	            !Empty(GQV->GQV_COND)           //Possui condição de Pagamento
	
	    If ( lRet )
	        lScatter := GQV->GQV_VALLIM < (oSubGQY:GetValue("GQY_TOTAL") - oSubGQY:GetValue("GQY_TOTDES"))
		Else
			oMdlLote:SetErrorMessage(oMdlLote:GetId(),,oMdlLote:GetId(),,STR0026,STR0024,STR0025) //"TES utilizada no parâmetro do cliente está incorreta."
	    EndIf
	
	Else
	    lRet := .f.
        oMdlLote:SetErrorMessage(oMdlLote:GetId(),,oMdlLote:GetId(),,STR0036, STR0037, STR0038) //"Registro não localizado","Nâo foram localizados parâmetros para este cliente","Cadastre parâmetros"
	EndIf
	
	If ( lRet )
	    
	    If ( lScatter)
	        nQtdPV := (oSubGQY:GetValue("GQY_TOTAL") - oSubGQY:GetValue("GQY_TOTDES")) / GQV->GQV_VALLIM         
	        nQtdPV := GTPRndNextInt(nQtdPV)
	    Else
	        nQtdPV := 1
	    EndIf
	
	    nTotalAb := oSubGQY:GetValue("GQY_TOTAL") - oSubGQY:GetValue("GQY_TOTDES")
	
	    //Laço iterativo para criar a quantidade de pedidos necessários.
	    For nI := 1 to nQtdPV
	
	        If ( nTotalAb > GQV->GQV_VALLIM )
	            nTotalAb -= GQV->GQV_VALLIM
	            nTotalPV := GQV->GQV_VALLIM
	        Else    
	            nTotalPV := nTotalAb
	        EndIf
	
	        //Montagem do pedido de vendas utilizando a variável nTotalPV
	        
	        //Itens do Pedido de Vendas
	        aAdd(aItem,{"C6_ITEM",StrZero(1,TamSx3("C6_ITEM")[1]),Nil})
	        aAdd(aItem,{"C6_PRODUTO",GQV->GQV_PRODUT,Nil})
	        aAdd(aItem,{"C6_QTDVEN",1,Nil})
	        aAdd(aItem,{"C6_PRCVEN",nTotalPV,Nil})
	        aAdd(aItem,{"C6_QTDLIB",1,Nil})
	        aAdd(aItem,{"C6_TES",GQV->GQV_TES,Nil})
	        aAdd(aItem,{"AUTDELETA","N",Nil})
	
	        aAdd(aSC6,aClone(aItem))
	        aItem := {}
	
	        MsExecAuto({|x,y,z| MATA410(x,y,z)},aSC5,aSC6,3)
			aSC6 := {}
			
	        If ( lMsErroAuto )
	            
	            lRet := .f.
	            
	            If ( lG284MsgOn )
	                MostraErro()
	            Else
	                GA284SetLog("MSEXECAUTO")    
	            EndIf    
	
	            Exit
	        
	        Else
	            AAdd(aPedidos,SC5->C5_NUM)            
	        EndIf
	
	    Next nI
	

    Else
        If ( lG284MsgOn )
            JurShowErro( oMdlLote:GetErrormessage() )
        Else    
            GA284SetLog("MVC")    
        EndIf	
    EndIf
	
	RestArea(aArea)
	
	If ( lRet )
	    lRet := GA284UpdLote(oMdlLote,aPedidos)
	EndIf

Else	//Estorno
    
    If ( oSubGQY:GetValue("GQY_STATUS") == "1" )

        SC5->(DbSetOrder(1))
        SC6->(DbSetOrder(1))
        
        cFilSeek := XFilial("SC6")      

        For nI := 1 to oSubG9Y:Length()

            If ( SC5->(DbSeek(XFilial("SC5") + oSubG9Y:GetValue("G9Y_PEDIDO",nI))) )
                
                aAdd(aSC5,{"C5_NUM",SC5->C5_NUM,Nil})

                If ( SC6->(DbSeek(cFilSeek + oSubG9Y:GetValue("G9Y_PEDIDO",nI))) )

                    While ( SC6->(!Eof()) .And.; 
                            Alltrim(SC6->C6_FILIAL) == Alltrim(cFilSeek) .And.; 
                            Alltrim(SC6->C6_NUM) == Alltrim(oSubG9Y:GetValue("G9Y_PEDIDO",nI)) )

                        aAdd(aItem,{"C6_NUM",SC6->C6_NUM,Nil})    
                        aAdd(aItem,{"C6_ITEM",SC6->C6_ITEM,Nil})
                        aAdd(aItem,{"C6_PRODUTO",SC6->C6_PRODUTO,Nil})
                        aAdd(aItem,{"C6_QTDVEN",SC6->C6_QTDVEN,Nil})
                        aAdd(aItem,{"C6_PRCVEN",SC6->C6_PRCVEN,Nil})
                        aAdd(aItem,{"C6_VALOR",SC6->C6_VALOR,Nil})
                        aAdd(aItem,{"C6_QTDLIB",0,Nil})
                        aAdd(aItem,{"C6_TES",SC6->C6_TES,Nil})
                        aAdd(aItem,{"AUTDELETA","N",Nil})

                        SC6->(DbSkip())        

                        If ( Alltrim(SC6->C6_NUM) <> Alltrim(oSubG9Y:GetValue("G9Y_PEDIDO",nI)) )    
                            aAdd(aSC6,aClone(aItem))
                            aItem := {}
                        EndIf

                    EndDo

                    MsExecAuto({|x,y,z| MATA410(x,y,z)},aSC5,aSC6,4)    //Altera, para deixar o pedido não liberado
                    
                    If ( lMsErroAuto )
                        
                        lRet := .f.
                        
                        If ( lG284MsgOn )
                            MostraErro()
                        Else
                            GA284SetLog("MSEXECAUTO")    
                        EndIf    
            
                        Exit
                    
                    Else    

                        MsExecAuto({|x,y,z| MATA410(x,y,z)},aSC5,aSC6,5) //Exclusão do Pedido de Vendas
                        
                        If ( lMsErroAuto )
                        
                            lRet := .f.
                            
                            If ( lG284MsgOn )
                                MostraErro()
                            Else
                                GA284SetLog("MSEXECAUTO")    
                            EndIf    
                
                            Exit

                        EndIf

                    EndIf    

                EndIf
                
                aSC6 := {}
                aSC5 := {}
            
            EndIf
            
            If ( lRet )

                oSubG9Y:GoLine(nI)

                lRet := oSubG9Y:DeleteLine()

            EndIf

            If ( !lRet )
                Exit
            EndIf    

        Next nI

        If ( lRet )
            lRet := oSubGQY:SetValue("GQY_STATUS","2")
        EndIf

        RestArea(aAreaSC5)
        RestArea(aAreaSC6)

    EndIf

EndIf

Return(lRet)

/*/{Protheus.doc} GA284UpdLote()
    Efetua a atualização do Status do Lote e suas requisições
    @type  Static Function
    @author user
    @since date
    @version version
    @param  oMdlLote, objeto, instância da classe FwFormModel
    @return lRet, lógico, .t. - atualização efetuada com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/    

Static Function GA284UpdLote(oMdlLote,aPedidos)

Local oModelGQY := oMdlLote:GetModel("FIELDGQY")
Local oModelG9Y := oMdlLote:GetModel("GRIDG9Y")

Local nI        := 0

Local lRet      := .f.

lRet := oModelGQY:SetValue("GQY_STATUS","1")    //Baixado

If ( lRet )
    
	For nI := 1 to Len(aPedidos)

        If ( !Empty(oModelG9Y:GetValue("G9Y_PEDIDO")) )
            
            nLen := oModelG9Y:Length()
            
            oModelG9Y:AddLine()
            
            lRet := nLen < oModelG9Y:Length()

        EndIf

        If ( lRet )
            lRet := oModelG9Y:SetValue("G9Y_PEDIDO",aPedidos[nI])
        EndIf

        If ( !lRet )
            Exit
		EndIf    

	Next nI
    
EndIf

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} GA284Tdok (oModel)
Pós validação do modelo
@author  Renan Ribeiro Brando
@since   22/06/2017
@version P12
/*/
//-------------------------------------------------------------------
Static Function GA284Tdok(oModel)

Local lRet     := .T.
Local nX       := 0
Local oMdlGQW  := oModel:GetModel("GRIDGQW")
//Verifica chave duplicada
If lRet .And. (oModel:GetModel("FIELDGQY"):GetOperation() == MODEL_OPERATION_INSERT) 
	
	If (!ExistChav("GQY", oModel:GetModel("FIELDGQY"):GetValue("GQY_CODIGO"))) 
        lRet := .F.
        Help( ,, 'Help',"GA284Tdok", STR0028, 1, 0 )//Chave duplicada!
    EndIf
    
EndIf

For nX := 1 To oMdlGQW:Length()
    If !(oMdlGQW:GetValue('GQW_MARK',nX))
        oMdlGQW:GoLine(nX)
        lRet := oMdlGQW:DeleteLine()
    EndIf
Next

Return lRet

/*/{Protheus.doc} GA284VldReq()
    Valida a requsição
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 23/06/2017
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA284VldReq(cReq,cCliente,cLoja)

Local cChave    := ""

cChave := xFilial("GQW")
cChave += Padr(cReq,TamSx3("GQW_CODIGO")[1])
cChave += Padr(cCliente,TamSx3("GQW_CODCLI")[1])
cChave += Padr(cLoja,TamSx3("GQW_CODLOJ")[1])

lRet := Posicione("GQW",1,cChave,"GQW_CONFER") == "1"

Return (lRet)

/*/{Protheus.doc} GA284ExistLote()
    Verifica se existe o lote para a requisição
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 23/06/2017
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA284ExistLote(cReq,cCliente,cLoja,cLote,cFilSeek)

Local cNxtAlias := GetNextAlias()
Local cRetLote  := ""

Default cFilSeek := XFilial("GQW")

BeginSQL Alias cNxtAlias
    
    SELECT
        DISTINCT
        GQW_CODLOT
    FROM
        %Table:GQW% GQW
    WHERE
        GQW_FILIAL = %Exp:cFilSeek%
        AND GQW_CODIGO = %Exp:cReq%
        AND GQW_CODCLI = %Exp:cCliente%
        AND GQW_CODLOJ = %Exp:cLoja%
        AND GQW_CODLOT <> %Exp:cLote%
        AND GQW.%NotDel%
UNION        
SELECT
        DISTINCT
        GQW_CODLOT
    FROM
        %Table:GQW% GQW
    WHERE
        GQW_FILIAL = %Exp:cFilSeek%
        AND GQW_CODIGO = %Exp:cReq%
        AND GQW_CODCLI <> %Exp:cCliente%
        AND GQW_CODLOJ <> %Exp:cLoja%
        AND GQW_CODLOT <> %Exp:cLote%
        AND GQW.%NotDel%

EndSQL

cRetLote := (cNxtAlias)->GQW_CODLOT

(cNxtAlias)->(DbCloseArea())

Return(cRetLote) 

/*/{Protheus.doc} GA284VldAct()
    Valida a requsição
    @type  Static Function
    @author Fernando Radu Muscalu
    @since 23/06/2017
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA284VldAct(oModel)

Local lRet  := .t.

If ( oModel:GetOperation() == MODEL_OPERATION_UPDATE .Or.; 
    oModel:GetOperation() == MODEL_OPERATION_DELETE )
    
    //cG284Opera ("1" - Geração; "2" - Estorno)
    If ( (Empty(cG284Opera) .Or. cG284Opera == "1") .AND. GQY->GQY_STATUS == "1" )
        
        lRet := GA284ChkPedVen(oModel)
        
        If ( !lRet )
        	oModel:SetErrorMessage(oModel:GetId(),,oModel:GetId(),,STR0031,STR0030,STR0029) //"Somente lotes pendentes podem ser manipulados."
        EndIf
        
    EndIf

EndIf

Return(lRet)

/*/{Protheus.doc} GA284UpdStatus()
    Atualiza os Status das requisições de acordo com o status recém atualizado do lote
    @type  Function
    @author Fernando Radu Muscalu
    @since 23/06/2017
    @version version
    @param param, param_type, param_descr
    @return returno,return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA284UpdStatus()

Local oModel    := FwModelActive()

Local nI        := 0
Local nLine     := oModel:GetModel("GRIDGQW"):GetLine()

For nI :=  1 to oModel:GetModel("GRIDGQW"):Length()
    
    oModel:GetModel("GRIDGQW"):GoLine(nI)
    oModel:GetModel("GRIDGQW"):LoadValue("GQW_STATUS",oModel:GetModel("FIELDGQY"):GetValue("GQY_STATUS"))

Next nI

oModel:GetModel("GRIDGQW"):GoLine(nLine)

Return(oModel:GetModel("FIELDGQY"):GetValue("GQY_STATUS"))

/*/{Protheus.doc} GA284GetLog()
    Retornar o Log gerado pela função GA284IntFat()
    @type  Function
    @author Fernando Radu Muscalu
    @since 26/06/2017
    @version version
    @param param, param_type, param_descr
    @return aG284Log, array, Log dos erros de geração de pedidos de vendas
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA284GetLog()

Return(aG284Log)

/*/{Protheus.doc} GA284ResetLog
    Reinicia o array de log aG284Log
    @type  Function
    @author Fernando Radu Muscalu
    @since 26/06/2017
    @version version
    @param 
    @return nil, Nulo, sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA284ResetLog()

aG284Log := {}

Return()

/*/{Protheus.doc} GA284SetLog()
    Configura o Log de Erro
    @type  Function
    @author Fernando Radu Muscalu
    @since 26/06/2017
    @version version
    @param cOrigLog, caractere, a origem do erro é: "MSEXECAUTO" ou "MVC"
    @return nil, nulo, sem retorno
    @example
    (examples)
    @see (links_or_references)
/*/
Function GA284SetLog(cOrigLog)

Local oModel    := nil

Local cMsgLog   := ""
Local cPath     := GetSrvProfString("Rootpath","")
Local cFile     := ""

Default cOrigLog    := "MSEXECAUTO"

If ( cOrigLog == "MSEXECAUTO" )
    
    cFile := "TMP_LOG"+StrTran(Time(),":","")+DToS(Date())
    
    if !IsBlind()
        cMsgLog := MostraErro(cPath,cFile)
    endif

    cPath := Iif(Right(cPath,1) == "\",cPath,cPath+"\")+cFile

    fErase(cPath)

Else
    oModel := FwModelActive()
    cMsgLog := GTPGetErrorMsg(oModel)
EndIf    

AAdd(aG284Log,{Date(),Time(),cMsgLog})

Return()

/*/{Protheus.doc} GA284ChkPedVen()
   	Função que pesquisa por todos os pedidos do lote. Será validado	se todos os pedidos do lote
   	não existem. Nesta situação, a validação para a exclusão está ok.
    @type  Function
    @author Fernando Radu Muscalu
    @since 26/06/2017
    @version version
    @param oModel, objeto, instância da classe FWFormModel
    @return lRet, lógico, .t. - validado com sucesso
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function GA284ChkPedVen(oModel)

Local aAreaSC5	:= SC5->(GetArea())
Local aAreaG9Y  := G9Y->(GetArea())

Local cFilSeek  := xFilial("G9Y")

Local lRet	:= .t.

SC5->(DbSetOrder(1))
G9Y->(DbSetOrder(2))

//Pesquisa o pedido que foi referenciado na tabela G9Y - Pedidos x Lote
//Se não encontra o pedido, significa que para aquele pedido, o Lote estaria apto a ser excluído,
//todavia, deve-se checar todos os pedidos do lote. Para a exclusão do lote, todos os pedidos
//referenciados não devem mais existir cadastrado.
If ( G9Y->(DbSeek(cFilSeek + GQY->GQY_CODIGO)) )

    While ( G9Y->(!Eof()) .And.; 
            Alltrim(cFilSeek) == Alltrim(G9Y->G9Y_FILIAL) .And.;
            Alltrim(GQY->GQY_CODIGO) == Alltrim(G9Y->G9Y_LOTE) )

        lRet := !SC5->(DbSeek(XFilial("SC5") + G9Y->G9Y_PEDIDO))

        If ( !lRet )
            Exit
        EndIf

        G9Y->(DbSkip())
    
    EndDo

EndIf

RestArea(aAreaSC5)
RestArea(aAreaG9Y)

Return(lRet)


/*/
 * {Protheus.doc} RetValLiq()
 * Retorna o Valor liquido
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   oModel, cField, uValue
 * return  lRet
/*/
Static Function RetValLiq(oMdl, cField, uValue)
Do Case 
    Case cField == 'GQY_TOTDES'
        oMdl:LoadValue('GQY_VALIQ', oMdl:GetValue('GQY_TOTAL') - uValue)

    Case cField == 'GQW_TOTDES'
        oMdl:LoadValue('GQW_VALIQ', oMdl:GetValue('GQW_TOTAL') - uValue)

    Case cField == 'GQY_TOTAL'
        oMdl:LoadValue('GQY_VALIQ', uValue)

    Case cField == 'GQW_TOTAL'
        oMdl:LoadValue('GQW_VALIQ', uValue)
EndCase

Return uValue


/*/
 * {Protheus.doc} FieldInit()
 * Inicia o valor Liquido
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   oModel, cField
 * return  nRet
/*/
Static Function FieldInit(oMdl,cField,uVal,nLine,uOldValue)
Local uRet      := uVal
Local lInsert   := oMdl:GetOperation() == MODEL_OPERATION_INSERT

Do Case 
    Case cField == 'GQY_VALIQ'
        If !lInsert
            uRet := GQY->GQY_TOTAL - GQY->GQY_TOTDES
        Else
            uRet := 0   
        Endif
    Case cField == 'GQW_VALIQ'
        If !lInsert
            uRet := GQW->GQW_TOTAL - GQW->GQW_TOTDES
        Else
            uRet := 0   
        Endif
    Case cField == "GQW_CODCLI"
        uRet := ""
    Case cField == "GQW_MARK"  
        uRet := .T.
    Case cField == "GQW_CODAGE"
        uRet := ""
    Case cField == "GQW_CODIGO"
        uRet := ""
    Case cField == "GQW_DATEMI"
        uRet := ""
EndCase

Return uRet

/*/
 * {Protheus.doc} RetValLiq()
 * Inicia o valor Liquido GRID
 * type    Static Function
 * author  Eduardo Ferreira
 * since   06/11/2019
 * version 12.25
 * param   oModel
 * return  Não há
/*/
Static Function IniTotLiq(oModel)
Local oGQW := oModel:GetModel('GRIDGQW')
Local nCon := 0

If (oModel:Getoperation() == MODEL_OPERATION_VIEW) .Or. (oModel:Getoperation() == MODEL_OPERATION_UPDATE)

    for nCon := 1 to oGQW:Length()
        oGQW:GoLine(nCon)
        oGQW:LoadValue('GQW_VALIQ', (oGQW:GetValue('GQW_TOTAL', nCon) - oGQW:GetValue('GQW_TOTDES', nCon)))
    next

EndIf

Return
