#INCLUDE "TOTVS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "LJFIDELITYCOREINTERFACE.CH"
#INCLUDE "POSCSS.CH"

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjFidelityCoreInterface
Classe responsavel pela interação do usuário com o FidelityCore

@type       Class
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Class LjFidelityCoreInterface
    
    Data oLjFidelityCoreCommunication   as Object
    Data oLjCustomerFidelityCore        as Object
    Data oLjCustomerFidelityCoreReceive as Object
    DAta oLjSaleFidelityCore          as Object
    Data cBusinessUnitId              as Chacter
    Data cPartnerCode                 as Chacter
    Data cStoreId                     as Chacter
    Data nBonusUsed                   as Numeric

    Data oFont                        as Object
    Data lFinalize                    as Logical
    Data bValidExit                   as CodeBlock
    Data FollowFlow                   as Logical

    Data cStep                        as Chacter
    Data cNextStep                    as Chacter
    Data OldStep                      as Chacter

    Data nWidth     // Largura
    Data nHeight //altura

    Data nMinimumPanelWidth
    Data nMinimumPanelHeight

    Method New(oLjFidelityCoreCommunication, cSaleId, nNetSaleValue, oLjCustomerFidelityCore, cBusinessUnitId)
    Method Initiation()
    Method finalization(cPos,cSellerName,cFiscalId,nQtyItens,nNetSaleValue)
    Method Flow(cStep)
    Method Panel(cStep)
    Method ValidExit() 
    Method NextStep(oDialog)
    Method FidelityCSS(oObj,nStyle,xPar01)
    
    Method SetNextStep(cNextStep)
    Method GetNextStep()

    Method StartStep()
    Method StartController(aGetPhone,aGetName,aGetEmail,aGetBirth,aGetCPF,aGetGender)

    Method IdentificationStep()
    Method IdController(cType,cSentCode)

    Method AuthenticationStep()
    Method AuthController(aGetPIN)
    
    Method BonusStep()
    Method BonusController(aBrowse,aBonus)

    Method CampaignStep()
    Method CampaignController(aBrowse,aCampaign)

    Method FinalizeStep()

    Method GetBonus()

EndClass

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} New
Metodo construtor da classe

@type       Method
@param      oLjFidelityCoreCommunication, LjFidelityCoreCommunication, Objeto com as informações de comunicação
@param      cSaleId, Caractere, Identificador da venda
@param      nNetSaleValue, Numérico, Valor líquido da venda
@param      oLjCustomerFidelityCore, LjCustomerFidelityCore, Objeto com a informações do cliente
@return     LjFidelityCoreInterface, Objeto instânciado
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method New(oLjFidelityCoreCommunication, cSaleId, nNetSaleValue, oLjCustomerFidelityCore, cBusinessUnitId) Class LjFidelityCoreInterface

    Default cBusinessUnitId := FWArrFilAtu(,cFilAnt)[18]

    Self:oLjFidelityCoreCommunication   := oLjFidelityCoreCommunication
    Self:oLjSaleFidelityCore            := LjSaleFidelityCore():New(cSaleId, nNetSaleValue)
    Self:oLjCustomerFidelityCoreReceive := oLjCustomerFidelityCore

    Self:nBonusUsed                     := 0

    Self:nWidth                         := 610
    Self:nHeight                        := 554

    Self:nMinimumPanelWidth             := 80
    Self:nMinimumPanelHeight            := 28

    Self:oFont                          := TFont()  :New(,,-16,)
    
    Self:cBusinessUnitId                := cBusinessUnitId
    Self:cStep                          := "start"

    Self:lFinalize                      := .F.
    Self:FollowFlow                     := .T.

Return self

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Initiation
Inicializa componentes da interface

@type       Method
@return     Lógico, Indica se a tela foi finalizada 
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method Initiation() Class LjFidelityCoreInterface
    
    Self:lFinalize := .F.
    While !Empty(Self:GetNextStep()) .AND. Self:FollowFlow
        If Self:GetNextStep() == "campaign"
           EXIT
        EndIf 

         Self:Flow()
    End

Return Self:lFinalize

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Finalization
Finaliza componentes da interface

@type       Method
@param      cPos, Caractere, Código da estação
@param      cSellerName, Caractere, Nome do vendedor
@param      cFiscalId, Caractere, Identificador da venda
@param      nQtyItens, Numérico, Quantidade de itens
@param      nNetSaleValue, Numérico, Valor liquído
@return     Lógico, Indica se a tela foi finalizada 
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method Finalization(cPos,cSellerName,cFiscalId,nQtyItens,nNetSaleValue) Class LjFidelityCoreInterface
    Self:lFinalize := .F.
    
    Self:oLjSaleFidelityCore:SetPosCode(cPos)
    Self:oLjSaleFidelityCore:SetSellerName(cSellerName)
    Self:oLjSaleFidelityCore:SetFiscalId(cFiscalId)
    Self:oLjSaleFidelityCore:SetTotalQuantityItems(nQtyItens)
    Self:oLjSaleFidelityCore:SetNetSaleValue(nNetSaleValue)

    While !Empty(Self:GetNextStep()) .AND. Self:FollowFlow
        Self:Flow()
    End

Return Self:lFinalize

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} Flow
Controla os passos da interface

@type       Method
@param      cStep, Caractere, Passo da interface que será apresentado
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method Flow(cStep) Class LjFidelityCoreInterface
    
    Default cStep := Self:cStep
    
    Self:FollowFlow := .F.
    
    Do Case 
        Case cStep == "start"
            Self:StartStep()
        Case cStep == "identification"
            Self:IdentificationStep()
        Case cStep == "authentication"
            Self:AuthenticationStep()
        Case cStep == "bonus"
            Self:BonusStep()
        Case cStep == "campaign"
            Self:CampaignStep()
        Case cStep == "finalize"
            Self:FinalizeStep()
        Otherwise 
            Self:SetNextStep()
    End Case
   
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} StartStep
Tela com o primeiro passo identificação do cliente

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method StartStep() Class LjFidelityCoreInterface
    Local jResult       := Nil
    Local nColumns      := 3 
    Local nHeaderFooter := 2 // -- 1 = Apenas Cabeçalhos, 2 = Cabeçalho e rodapé
    Local aGetPhone     := {Space(11),.F.,""}
    Local nPosPhone     := 0
    Local aGetName      := {Space(50),.F.,""}
    Local nPosName      := 0
    Local aGetEmail     := {Space(80),.F.,""}
    Local nPosEmail     := 0
    Local aGetBirth     := {CtoD("") ,.F.,""}
    Local nPosBirth     := 0
    Local aGetCPF       := {Space(11),.F.,""}
    Local nPosCPF       := 0
    Local aGetGender    := {Space(10),.F.,""}
    Local nPosGender    := 0
    Local oMessage      := Nil
    Local cMessage      := ""
    local lResult       := .F.
    Local cCliPad 		:= SuperGetMV("MV_CLIPAD",,"")  						// Parametro que indica o CLIENTE PADRAO
    Local cLojPad 		:= SuperGetMV("MV_LOJAPAD",,"") 						// Parametro que indica o LOJA PADRAO
    Local oDialog       := Nil
    Local oPanels       := Nil
    Local oGet          := Nil
    Local oSay          := Nil

    If Self:oLjCustomerFidelityCoreReceive <> Nil
        If Alltrim(Upper(POSICIONE( "SA1", 1, xfilial("SA1") + cCliPad + cLojPad, "A1_NOME" ))) <> Alltrim(Upper(self:oLjCustomerFidelityCoreReceive:GetName()))
            aGetPhone[1] := PadR( self:oLjCustomerFidelityCoreReceive:GetPhone()    , Len( aGetPhone[1] )   )
            aGetName[1]  := PadR( self:oLjCustomerFidelityCoreReceive:GetName()     , Len( aGetName[1]  )   )
            aGetEmail[1] := PadR( self:oLjCustomerFidelityCoreReceive:GetEmail()    , Len( aGetEmail[1] )   )
            aGetBirth[1] := StoD( StrTran(self:oLjCustomerFidelityCoreReceive:GetBirthday(), "-", "")       )
            aGetCPF[1]   := PadR( self:oLjCustomerFidelityCoreReceive:GetDocument() , Len( aGetCPF[1]   )   )
            aGetGender[1]:= PadR( self:oLjCustomerFidelityCoreReceive:GetGender()   , Len( aGetGender[1])   )
        Else
            FreeObj(Self:oLjCustomerFidelityCoreReceive)
        EndIf 
    EndIf
    
    FWMsgRun(,{|| lResult :=Self:oLjFidelityCoreCommunication:Forms(Self:cBusinessUnitId) }, STR0001, STR0028)   //"TOTVS Bonificações"     //"Comunicando com programa de bonificação"
    
    If lResult
        
        jResult := Self:oLjFidelityCoreCommunication:ResultForms()

        If ValType(jResult) == "J"

            oDialog   := TDialog():New(0, 0, Self:nHeight, Self:nWidth, STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .T.) // -- 'TOTVS Bonificações'
           
            nPanelsRequired := Len(jResult["identificationForms"])  
            nAuxCalculation := (nPanelsRequired + nHeaderFooter) * nColumns 
            
            oPanels := tPanel():New(0,0,"",oDialog,Self:oFont,.T.,,,,Self:nWidth * 0.50,Self:nHeight * 0.50)
            
            oLjSmartPanels  := LjSmartPanels():New(.F.,oPanels,Self:nWidth,Self:nHeight,Self:nMinimumPanelWidth,Self:nMinimumPanelHeight,2.5)
            aPanels := oLjSmartPanels:Creat(Iif(nAuxCalculation > 27, nAuxCalculation,27),nColumns)
            
            Self:SetNextStep(jResult["nextStep"])
            Self:cPartnerCode :=  jResult["partnerCode"]

            // -- Cabecalho
            nPanel := 1
            oLjSmartPanels:Rearrange(nPanel,nColumns,1)
            oSay := TSay():New(00,00,{||jResult["operatorText"]},aPanels[nPanel][1],,,,,,.T.,,,300,18)
            oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'18',.T.})) 
            
            // -- Corpo
            nPosPhone := aScan(jResult["identificationForms"],{ |x| Alltrim(Upper(x["type"])) == "PHONE"})
            If nPosPhone > 0 
                nPanel := nPanel + nColumns
                oLjSmartPanels:Rearrange(nPanel,nColumns,1)
                
                oSay := TSay():New(00,00,{|| jResult["identificationForms"][nPosPhone]["operatorText"] },aPanels[nPanel][1],,,,,,.T.,,,150,10)
                oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 

                oGet := TGet():New(10,00,{|u|If( PCount() == 0, aGetPhone[1], aGetPhone[1] := u) },aPanels[nPanel][1],150,14,"@R (99) 99999 - 9999",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetPhone[1]",,,,.T. )
                oGet:SetCSS(PosCss(GetClassName(oGet), CSS_GET_FOCAL)) 

                If jResult["identificationForms"][nPosPhone]["isIdentificationCode"] .Or. jResult["identificationForms"][nPosPhone]["required"]
                    TSay():New(12,151,{||'<font color="red">*</font>'},aPanels[nPanel][1],,,,,,.T.,,,10,10,,,,,,.T.)
                    aGetPhone[2] := .T.
                    aGetPhone[3] := jResult["identificationForms"][nPosPhone]["operatorText"]
                EndIf 

            EndIf 

            nPosName := aScan(jResult["identificationForms"],{ |x| Alltrim(Upper(x["type"])) == "NAME"})
            If nPosName > 0
                nPanel := nPanel + nColumns
                oLjSmartPanels:Rearrange(nPanel,nColumns,1)
                
                oSay := TSay():New(00,00,{|| jResult["identificationForms"][nPosName]["operatorText"] },aPanels[nPanel][1],,,,,,.T.,,,150,10)
                oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 
                
                oGet := TGet():New(10,00,{|u|If( PCount() == 0, aGetName[1], aGetName[1] := u) },aPanels[nPanel][1],150,14,"@",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetName[1]",,,,.T. )
                oGet:SetCSS(PosCss(GetClassName(oGet), CSS_GET_FOCAL)) 

                If jResult["identificationForms"][nPosName]["isIdentificationCode"] .Or. jResult["identificationForms"][nPosName]["required"]
                    TSay():New(12,151,{||'<font color="red">*</font>'},aPanels[nPanel][1],,,,,,.T.,,,10,10,,,,,,.T.)
                    aGetName[2] := .T.
                    aGetName[3] := jResult["identificationForms"][nPosName]["operatorText"]
                EndIf 

            EndIf 

            nPosEmail := aScan(jResult["identificationForms"],{ |x| Alltrim(Upper(x["type"])) == "EMAIL"})
            If nPosEmail > 0
                nPanel := nPanel + nColumns
                oLjSmartPanels:Rearrange(nPanel,nColumns,1)
                
                oSay := TSay():New(00,00,{|| jResult["identificationForms"][nPosEmail]["operatorText"] },aPanels[nPanel][1],,,,,,.T.,,,150,10)
                oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 

                oGet := TGet():New(10,00,{|u|If( PCount() == 0, aGetEmail[1], aGetEmail[1] := u) },aPanels[nPanel][1],150,14,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetEmail[1]",,,,.T. )
                oGet:SetCSS(PosCss(GetClassName(oGet), CSS_GET_FOCAL)) 

                If jResult["identificationForms"][nPosEmail]["isIdentificationCode"] .Or. jResult["identificationForms"][nPosEmail]["required"]
                    TSay():New(12,151,{||'<font color="red">*</font>'},aPanels[nPanel][1],,,,,,.T.,,,10,10,,,,,,.T.)
                    aGetEmail[2] := .T.
                    aGetEmail[3] := jResult["identificationForms"][nPosEmail]["operatorText"] 
                EndIf 

            EndIf 

            nPosBirth := aScan(jResult["identificationForms"],{ |x| Alltrim(Upper(x["type"])) == "BIRTH"})
            If nPosBirth > 0
                nPanel := nPanel + nColumns
                oLjSmartPanels:Rearrange(nPanel,nColumns,1)
                
                oSay := TSay():New(00,00,{|| jResult["identificationForms"][nPosBirth]["operatorText"] },aPanels[nPanel][1],,,,,,.T.,,,150,10)
                oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 
                
                oGet := TGet():New(10,00,{|u|If( PCount() == 0, aGetBirth[1], aGetBirth[1] := u) },aPanels[nPanel][1],150,14,"@D",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetBirth[1]",,,,.T. )
                oGet:SetCSS(PosCss(GetClassName(oGet), CSS_GET_FOCAL)) 

                If jResult["identificationForms"][nPosBirth]["isIdentificationCode"] .Or. jResult["identificationForms"][nPosBirth]["required"]
                    TSay():New(12,151,{||'<font color="red">*</font>'},aPanels[nPanel][1],,,,,,.T.,,,10,10,,,,,,.T.)
                    aGetBirth[2] := .T.
                    aGetBirth[3] := jResult["identificationForms"][nPosBirth]["operatorText"] 
                EndIf

            EndIf

            nPosCPF := aScan(jResult["identificationForms"],{ |x| Alltrim(Upper(x["type"])) == "CPF"})
            If nPosCPF > 0
                nPanel := nPanel + nColumns
                oLjSmartPanels:Rearrange(nPanel,nColumns,1)
                
                oSay := TSay():New(00,00,{|| jResult["identificationForms"][nPosCPF]["operatorText"] },aPanels[nPanel][1],,,,,,.T.,,,150,10)
                oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 
                
                oGet := TGet():New(10,00,{|u|If( PCount() == 0,  aGetCPF[1], aGetCPF[1] := u) },aPanels[nPanel][1],150,14,"@R 999.999.999-99",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetCPF[1]",,,,.T. )
                oGet:SetCSS(PosCss(GetClassName(oGet), CSS_GET_FOCAL)) 

                If jResult["identificationForms"][nPosCPF]["isIdentificationCode"] .Or. jResult["identificationForms"][nPosCPF]["required"]
                    TSay():New(12,151,{||'<font color="red">*</font>'},aPanels[nPanel][1],,,,,,.T.,,,10,10,,,,,,.T.)
                    aGetCPF[2] := .T.
                    aGetCPF[3] := jResult["identificationForms"][nPosCPF]["operatorText"] 
                EndIf 
            EndIf

            nPosGender := aScan(jResult["identificationForms"],{ |x| Alltrim(Upper(x["type"])) == "GENDER"})
            If nPosGender > 0
                nPanel := nPanel + nColumns
                oLjSmartPanels:Rearrange(nPanel,nColumns,1)
                
                oSay := TSay():New(00,00,{|| jResult["identificationForms"][nPosGender]["operatorText"] },aPanels[nPanel][1],,,,,,.T.,,,150,10)
                oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 
                
                oGet := TGet():New(10,00,{|u|If( PCount() == 0,  aGetGender[1], aGetGender[1] := u) },aPanels[nPanel][1],150,14,"@! AAAAAAAAAA",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetGender[1]",,,,.T. )
                oGet:SetCSS(PosCss(GetClassName(oGet), CSS_GET_FOCAL)) 

                If jResult["identificationForms"][nPosGender]["isIdentificationCode"] .Or. jResult["identificationForms"][nPosGender]["required"]
                    TSay():New(12,151,{||'<font color="red">*</font>'},aPanels[nPanel][1],,,,,,.T.,,,10,10,,,,,,.T.)
                    aGetGender[2] := .T.
                    aGetGender[3] := jResult["identificationForms"][nPosGender]["operatorText"] 
                EndIf 
            EndIf  

            nPanel := nPanel + nColumns
            oLjSmartPanels:Rearrange(nPanel,nColumns,1)
            oSay := TSay():New(00,00,{|| I18n(STR0002, {'<font color="red">"*"</font>'} ) },aPanels[nPanel][1],,,,,,.T.,,,aPanels[nPanel][1]:NWIDTH,10,,,,,,.T.)  //"Campos com #1 são obrigatorios."
            oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 
            
            // -- Mensagem de erro
            oMessage :=  TSay():New(12,00,{||'<font color="red">' + cMessage + '</font>'},aPanels[nPanel][1],,,,,,.T.,,,aPanels[nPanel][1]:NWIDTH * 0.50,10,,,,,,.T.)
            oMessage:SetCSS(PosCss(GetClassName(oMessage), CSS_LABEL_FOCAL,{'16',.F.})) 
            oMessage:Hide()

            // -- Rodapé
            oBtn := TButton():New( 00, 00, STR0003, aPanels[Len(aPanels)][1]      ,{ || Iif( ( aResult := Self:StartController(aGetPhone,aGetName,aGetEmail,aGetBirth,aGetCPF,aGetGender) )[1], Self:NextStep(oDialog), ( cMessage := aResult[2], oMessage:Show() ) ) }, aPanels[Len(aPanels)][1]:NWIDTH * 0.50,aPanels[Len(aPanels)][1]:NHEIGHT * 0.50,,,.F.,.T.,.F.,,.F.,,,.F. )          //"Enviar"
            oBtn:SetCSS(PosCss(GetClassName(oBtn), CSS_BTN_FOCAL)) 
            
            oBtn := TButton():New( 00, 00, STR0004, aPanels[Len(aPanels) - 1][1]  ,{ || oDialog:End() }, aPanels[Len(aPanels) - 1][1]:NWIDTH * 0.50,aPanels[Len(aPanels) - 1][1]:NHEIGHT * 0.50,,,.F.,.T.,.F.,,.F.,,,.F. )                                                                         //"Cancelar"
            oBtn:SetCSS(PosCss(GetClassName(oBtn), CSS_BTN_ATIVO)) 

            oDialog:Activate(,,,.T.,,,)     
        Else

            LjxjMsgErr(STR0019 + ValType(jResult), "", "LjFidelityCoreInterface_StartStep")     //"Retorno desconhecido do TOTVS Bonificações: "
            LjGrvLog("LjFidelityCoreInterface_StartStep", "Retorno desconhecido do TOTVS Bonificações: " + ValType(jResult) + " - " + Self:oLjFidelityCoreCommunication:GetError(), /*xVar*/, /*lCallStack*/)
        EndIf
    
    Else

        LjxjMsgErr(STR0020, STR0030, "LjFidelityCoreInterface_StartStep")     //"Não foi possível iniciar processo de comunicação com TOTVS Bonificações: "     //"Verifique os dados informados no cadastro de estação."
    EndIf 

return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} StartController
Inicia o controle para atualizar dados informados na primeira tela

@type       Method
@param      aGetPhone, Caractere, Telefone do cliente
@param      aGetName, Caractere, Nome do cliente
@param      aGetEmail, Caractere, E-mail do cliente
@param      aGetBirth, Caractere, Data de nascimento
@param      aGetCPF, Caractere, CPF do cliente
@param      aGetGender, Caractere, Gênero do cliente
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method StartController(aGetPhone,aGetName,aGetEmail,aGetBirth,aGetCPF,aGetGender) Class LjFidelityCoreInterface
    
    Local aResult := {.T., ""}
    Local oPhone  := Nil
    Local aAux    := {aGetPhone,aGetName,aGetEmail,aGetBirth,aGetCPF,aGetGender}
    Local nAux    := 0

    For nAux:=1 To Len(aAux)
        If aAux[nAux][2] .And. Empty( aAux[nAux][1] )
            aResult[2] += aAux[nAux][3] + ", " 
        EndIf
    Next nAux

    If !Empty( aResult[2] )
        aResult[1] := .F.
        aResult[2] := STR0022 + SubStr(aResult[2], 1, Len(aResult[2]) - 2)  //"Campo(s) obrigatório(s) não preenchido(s): "
    EndIf

    If aResult[1]

        oPhone := LjPhone():New(SubStr(aGetPhone[1],1,2),SubStr(aGetPhone[1],3))

        Self:oLjCustomerFidelityCore := LjCustomerFidelityCore():New(aGetName[1],aGetCPF[1],aGetEmail[1],oPhone,aGetBirth[1]) 
        aResult[1] := Self:oLjSaleFidelityCore:SetCustomer(Self:oLjCustomerFidelityCore)

        If !aResult[1]
            aResult[2] := STR0024   //"Não foi possível atualizar os dados do cliente no TOTVS Bonificações."
        EndIf
    EndIf
    
Return aResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} SetNextStep
Atualiza o próximo passo

@type       Method
@param      cNextStep, Caractere, Próximo passo
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method SetNextStep(cNextStep) Class LjFidelityCoreInterface
    
    Default cNextStep := ""
    
    Self:OldStep := Self:cStep
    Self:cStep   := cNextStep
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetNextStep
retoan o próximo passo

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetNextStep() Class LjFidelityCoreInterface
Return Self:cStep

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IdentificationStep
Tela com o segundo passo identificação\autenticação

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method IdentificationStep() Class LjFidelityCoreInterface

    Local jResult   := Nil
    Local cType     := ""
    Local cSentCode := ""
    Local lResult   := .F.

    FWMsgRun(,{|| lResult := Self:oLjFidelityCoreCommunication:Identification(Self:cBusinessUnitId,Self:cPartnerCode,Self:oLjSaleFidelityCore)}, STR0001, STR0028)    //"TOTVS Bonificações"    //"Comunicando com programa de bonificação"
           
    If lResult
        jResult := Self:oLjFidelityCoreCommunication:ResultIdentification()

        If ValType(jResult) == "J"
            Self:SetNextStep(jResult["nextStep"])

            Self:cStoreId := jResult["identification"]["storeId"]
            Self:oLjSaleFidelityCore:GetCustomer():SetCostumerId(jResult["identification"]["costumerId"])
            
            If Valtype(jResult["authentication"]) == "J"
                cType     := jResult["authentication"]["type"]
                cSentCode := jResult["authentication"]["code"]
            EndIf 

            Self:IdController(cType,cSentCode)
            Self:NextStep()
        Else

            LjxjMsgErr(STR0019 + ValType(jResult) + CRLF + CRLF + CRLF + Self:oLjFidelityCoreCommunication:GetError(), "", "LjFidelityCoreInterface_IdentificationStep")    //"Retorno desconhecido do TOTVS Bonificações: "
        EndIf 
    Else

        LjxjMsgErr(STR0021, "", "LjFidelityCoreInterface_IdentificationStep")       //"Não foi possível identificar o cliente no TOTVS Bonificações."
    EndIf
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} IdController
Efetua validações referente ao segundo passo autenticação

@type       Method
@param      cType, Caractere, Tipo de autenticação
@param      cSentCode, Caractere, Código valido
@return     Array, {Lógico, Caractere}
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method IdController(cType,cSentCode) Class LjFidelityCoreInterface
    Default cType     := ""
    Default cSentCode := ""

    If !Empty(cType) .And. !Empty(cSentCode)
        Self:oLjSaleFidelityCore:GetCustomer():SetAuthentication(,cType,cSentCode)
    EndIf

return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AuthenticationStep
Tela com a validação da autenticação

@type       Method
@return     Lógico, Define se foi feita a autenticação
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method AuthenticationStep() Class LjFidelityCoreInterface

    Local aGetPIN  :={space(4), .T., "", "9999"}
    Local nColumns := 3
    Local aResult  := {}
    Local oMessage := Nil
    Local cMessage := ""
    Local oGet     := Nil
    Local oDialog  := Nil
    Local aPanels  := {}
    Local oPanels  := Nil

    oDialog := TDialog():New(0, 0, Self:nHeight, Self:nWidth, STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .T.) // -- 'TOTVS Bonificações'
    oPanels := tPanel():New(0, 0, "", oDialog, Self:oFont, .T., , , , Self:nWidth * 0.50, Self:nHeight * 0.50)

    oLjSmartPanels  := LjSmartPanels():New(.F.,oPanels,Self:nWidth,Self:nHeight,Self:nMinimumPanelWidth,Self:nMinimumPanelHeight,2.5)
    aPanels := oLjSmartPanels:Creat(27,nColumns)

    // -- Cabeçalho
    nPanel := 1
    oLjSmartPanels:Rearrange(nPanel,nColumns,1)
    oSay := TSay():New(00,00,{|| STR0005},aPanels[nPanel][1],,,,,,.T.,,,300,18) //"Etapa de autenticação!"
    oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'18',.T.})) 

    // -- Corpo

    // -- Se a autenticação for por PIN
    If Alltrim(Upper( Self:oLjSaleFidelityCore:GetCustomer():GetTypeAuthentication())) == "PIN"
        nPanel := nPanel + nColumns
        oLjSmartPanels:Rearrange(nPanel,nColumns,1)
        
        oSay := TSay():New(00,00,{|| STR0029 },aPanels[nPanel][1],,,,,,.T.,,,150,10)    //"Solicite o PIN para o Cliente."
        oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 

        oGet := TGet():New(10,00,{|u|If( PCount() == 0,  aGetPIN[1], aGetPIN[1] := u) },aPanels[nPanel][1],150,14,aGetPIN[4],,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"aGetPIN[1]",,,,.T. )
        oGet:SetCSS(PosCss(GetClassName(oGet), CSS_GET_FOCAL)) 
        oGet:SetFocus()

        oSay := TSay():New(12,151,{||'<font color="red">*</font>'},aPanels[nPanel][1],,,,,,.T.,,,10,10,,,,,,.T.)
        oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 

        nPanel := nPanel + nColumns
        oLjSmartPanels:Rearrange(nPanel,nColumns,1)
        
        oSay := TSay():New(00,00,{|| I18n(STR0002, {'<font color="red">"*"</font>'} )},aPanels[nPanel][1],,,,,,.T.,,,aPanels[nPanel][1]:NWIDTH,10,,,,,,.T.)   //"Campos com #1 são obrigatorios."
        oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 

        //Numero do telefone na tela de autenticação
        oSay := TSay():New(18,00,{|| STR0036 + " (" + AllTrim(Self:oLjSaleFidelityCore:oLjCustomer:oPhone:cDDD) + ") " + Transform(AllTrim(Self:oLjSaleFidelityCore:oLjCustomer:oPhone:cPhone),"@R 99999-9999")},aPanels[nPanel][1],,,,,,.T.,,,aPanels[nPanel][1]:NWIDTH,10,,,,,,.T.) //Celular
        oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 

    EndIF 

    // -- Mensagem de usuaio não autenticado
    nPanel := nPanel + nColumns
    oLjSmartPanels:Rearrange(nPanel,nColumns,1)

    oMessage :=  TSay():New(00,00,{||'<font color="red">' + cMessage + '</font>'},aPanels[nPanel][1],,,,,,.T.,,,aPanels[nPanel][1]:NWIDTH * 0.50,10,,,,,,.T.)
    oMessage:SetCSS(PosCss(GetClassName(oMessage), CSS_LABEL_FOCAL,{'16',.F.})) 
    oMessage:Hide()

    // -- Rodapé
    oBtn := TButton():New( 00, 00, STR0003, aPanels[Len(aPanels)][1]    ,{|| Iif((aResult := Self:AuthController(aGetPIN))[1],Self:NextStep(oDialog),(cMessage := aResult[2],oMessage:Show()))}, aPanels[Len(aPanels)][1]:NWIDTH * 0.50,aPanels[Len(aPanels)][1]:NHEIGHT * 0.50,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Enviar"
    oBtn:SetCSS(PosCss(GetClassName(oBtn), CSS_BTN_FOCAL)) 
    
    oBtn := TButton():New( 00, 00, STR0004, aPanels[Len(aPanels) - 1][1],{|| oDialog:End()}, aPanels[Len(aPanels) - 1][1]:NWIDTH * 0.50,aPanels[Len(aPanels) - 1][1]:NHEIGHT * 0.50,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Cancelar"
    oBtn:SetCSS(PosCss(GetClassName(oBtn), CSS_BTN_ATIVO)) 

    oDialog:Activate(,,,.T.,,,)

Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} AuthController
Efetua validação da autenticação

@type       Method
@param      aGetPIN, Array, Informações refente ao Pin
@return     Array, {Lógico, Caractere}, Define se foi feita a autenticação e a descrição do erro
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method AuthController(aGetPIN) Class LjFidelityCoreInterface
        
    Local jResult
    Local lResult  := .F.
    Local cMessage := STR0025   //"Usuário não autenticado, tente novamente."
    
    If !Empty(aGetPIN[1])
        Self:oLjSaleFidelityCore:GetCustomer():SetTypedCode(aGetPIN[1])
        
        FWMsgRun(,{|| lResult := Self:oLjFidelityCoreCommunication:Authentication(Self:cBusinessUnitId,Self:cPartnerCode,Self:oLjSaleFidelityCore,Self:cStoreId)}, STR0001, STR0028)  //"TOTVS Bonificações"    //"Comunicando com programa de bonificação"

        If lResult

            jResult := Self:oLjFidelityCoreCommunication:ResultAuthentication()

            If ValType(jResult) == "J"

                lResult := jResult["authentication"]["authenticated"]
                If lResult
                    Self:oLjSaleFidelityCore:GetCustomer():SetValidatedByExceptionAuthentication(jResult["authentication"]["validatedByException"])
                    Self:SetNextStep(jResult["nextStep"])
                EndIf
            Else

                LjGrvLog("LjFidelityCoreInterface_AuthenticationStep", "Retorno desconhecido: " + ValType(jResult) + " - " + Self:oLjFidelityCoreCommunication:GetError(), /*xVar*/, /*lCallStack*/)
            EndIf
        Else

            LjGrvLog("LjFidelityCoreInterface_AuthenticationStep", "Erro na autenticação: " + Self:oLjFidelityCoreCommunication:GetError(), /*xVar*/, /*lCallStack*/)
        EndIf 
    Else

        cMessage := I18n(STR0031, {"Pin"})  //"#1 não foi informado."
    EndIf

Return {lResult,cMessage}

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BonusStep
Tela com o terceiro passo disponibilização de bônus

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method BonusStep() Class LjFidelityCoreInterface

    Local jResult
    Local oLjSmartPanels
    Local nColumns      := 3
    Local nLengthBonus  := 0
    Local nX
    Local lRequired
    Local oBrowse
    Local aBrowse       := {}
    Local aFields       := {'', STR0007, STR0008, STR0009}   //"Bônus disponível" //"Parceiro" //"Uso Obrigatório ?"
    Local aLengthF      := {15,75,70,60}
    Local oOK           := LoadBitmap(GetResources(),"LBOK") // Botoes de selecao 
    Local oNO           := LoadBitmap(GetResources(),"LBNO") // Botoes de selecao
    Local oSayAvailable
    Local nAvailable    := 0
    Local oSayUsed
    Local nUsed         := 0
    Local lResult       := .F.
    Local oDialog       := Nil
    Local oPanels       := Nil

    FWMsgRun(,{|| lResult := Self:oLjFidelityCoreCommunication:Bonus(Self:cBusinessUnitId,Self:cPartnerCode,Self:oLjSaleFidelityCore,Self:cStoreId)}, STR0001, STR0028)   //"TOTVS Bonificações"    //"Comunicando com programa de bonificação"

    If lResult
        jResult := Self:oLjFidelityCoreCommunication:ResultBonus()  
        
        If ValType(jResult) == "J"
            
            If ExistFunc("Lj7SetPhone") .AND. ValType(Self:oLjCustomerFidelityCore) == "O"
                Lj7SetPhone(Self:oLjCustomerFidelityCore:GetPhone())
            EndIf

            Self:SetNextStep(jResult["nextStep"])
            
            nLengthBonus := Len(jResult["bonus"])
            
            If nLengthBonus > 0 
               
                For nX := 1 To nLengthBonus
                    lRequired := jResult["bonus"][nX]["mandatoryUseBonuses"] 
                    
                    AAdd(aBrowse,{Iif(lRequired,.T.,.F.),jResult["bonus"][nX]["bonusAmount"],jResult["bonus"][nX]["partner"],jResult["bonus"][nX]["mandatoryUseBonuses"]})
                    
                    If lRequired 
                        nUsed      += jResult["bonus"][nX]["bonusAmount"]
                    Else
                        nAvailable += jResult["bonus"][nX]["bonusAmount"] 
                    EndIf 
                Next 

                If nLengthBonus == 1 .And. lRequired
                    
                    If  nUsed > 0
                        MsgAlert(STR0026 + Transform(nUsed, "@E 999,999.99" ), STR0001)     //"Bônus disponível com uso obrigatório: "      //"TOTVS Bonificações"
                    Else
                        MsgAlert(STR0023, STR0001)                                          //"Cliente não possui bônus para utilizar."     //"TOTVS Bonificações"
                    EndIf

                    Self:BonusController(aBrowse,jResult["bonus"])
                    Self:NextStep()

                Elseif nLengthBonus == 1

                    If MsgYesno( I18n(STR0032, { AllTrim( Transform(nAvailable, "@E 999,999.99") ) } ), STR0001)   //"Deseja resgatar o bônus disponível de R$ #1 ?"   //"TOTVS Bonificações"
                        aBrowse[1][1] := .T.   
                    EndIf

                    Self:BonusController(aBrowse,jResult["bonus"])
                    Self:NextStep()

                Else
                
                    oDialog := TDialog():New(0, 0, Self:nHeight, Self:nWidth, STR0001, , , , , CLR_BLACK, CLR_WHITE, , , .T.) // -- 'TOTVS Bonificações'
                    oPanels := tPanel():New(0,0,"",oDialog,Self:oFont,.T.,,,,Self:nWidth * 0.50,Self:nHeight * 0.50)

                    oLjSmartPanels  := LjSmartPanels():New(.F.,oPanels,Self:nWidth,Self:nHeight,Self:nMinimumPanelWidth,Self:nMinimumPanelHeight,2.5)
                    aPanels := oLjSmartPanels:Creat(27,nColumns)

                    // -- Cabeçalho
                    nPanel := 1
                    oLjSmartPanels:Rearrange(nPanel,nColumns,1)
                    oSay := TSay():New(00,00,{|| STR0010}, aPanels[nPanel][1],,,,,,.T.,,,300,18) //"Escolha um Bônus da lista"
                    oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'18',.T.})) 

                    // -- Corpo
                    nPanel := nPanel + nColumns
                    oLjSmartPanels:Rearrange(nPanel,nColumns,5)
                    oBrowse := TCBrowse():New( 00 , 00, aPanels[nPanel][1]:NWIDTH * 0.50, aPanels[nPanel][1]:NHEIGHT * 0.50,,aFields,aLengthF, aPanels[nPanel][1],,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
                    
                    oBrowse:SetArray(aBrowse)

                    nPanel := nPanel + (nColumns * 5) + (nColumns - 1 ) // Avança a qtd de linha do Grid e vai para a ultima coluna
                    
                    oSay := TSay():New(00,00,{|| STR0011},aPanels[nPanel][1],,,,,,.T.,,,100,18)  //"Bônus disponível"
                    oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 

                    oSayAvailable := TSay():New(10,00,{||"R$: " + Transform(nAvailable, "@E 999,999.99" )},aPanels[nPanel][1],,,,,,.T.,,,100,8)
                    oSayAvailable:SetCSS(PosCss(GetClassName(oSayAvailable), CSS_LABEL_FOCAL,{'16',.F.})) 
                    
                    nPanel := nPanel + nColumns
                    oSay := TSay():New(00,00,{|| STR0012},aPanels[nPanel][1],,,,,,.T.,,,100,8)  //"Bônus utilizado"
                    oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 

                    oSayUsed := TSay():New(10,00,{||"R$: " + Transform(nUsed, "@E 999,999.99" )},aPanels[nPanel][1],,,,,,.T.,,,100,8)
                    oSayUsed:SetCSS(PosCss(GetClassName(oSayUsed), CSS_LABEL_FOCAL,{'16',.F.})) 

                    oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01],oOK,oNO)                   ,;
                                    Transform(aBrowse[oBrowse:nAt,02],'@E 99,999,999,999.99')   ,;
                                    aBrowse[oBrowse:nAt,03]                                     ,;
                                    If(aBrowse[oBrowse:nAT,04], STR0013, STR0014)               }}  //"Sim" //"Não"

                    oBrowse:bLDblClick := {|| Iif(aBrowse[oBrowse:nAt][4] == .F.,;
                                                    (Iif(aBrowse[oBrowse:nAt][1],;
                                                    (nUsed -= aBrowse[oBrowse:nAt][2], nAvailable += aBrowse[oBrowse:nAt][2]),;
                                                    (nUsed += aBrowse[oBrowse:nAt][2],nAvailable -= aBrowse[oBrowse:nAt][2])),;
                                                    aBrowse[oBrowse:nAt][1] := !aBrowse[oBrowse:nAt][1],;
                                                    oBrowse:DrawSelect()    ,;
                                                    oSayAvailable:Refresh() ,;
                                                    oSayUsed:Refresh())     ,;
                                                    Alert(STR0015))         }   //"Uso obrigatório !"
                                
                    // -- Rodapé
                    
                    oBtn := TButton():New( 00, 00, STR0003, aPanels[Len(aPanels)][1]    ,{|| Self:BonusController(aBrowse,jResult["bonus"]),Self:NextStep(oDialog) }, aPanels[Len(aPanels)][1]:NWIDTH * 0.50,aPanels[Len(aPanels)][1]:NHEIGHT * 0.50,,,.F.,.T.,.F.,,.F.,,,.F. )            //"Enviar"
                    oBtn:SetCSS(PosCss(GetClassName(oBtn), CSS_BTN_FOCAL)) 
                    
                    oBtn := TButton():New( 00, 00, STR0004, aPanels[Len(aPanels) - 1][1],{|| oDialog:End()}, aPanels[Len(aPanels) - 1][1]:NWIDTH * 0.50,aPanels[Len(aPanels) - 1][1]:NHEIGHT * 0.50,,,.F.,.T.,.F.,,.F.,,,.F. )                                 //"Cancelar"
                    oBtn:SetCSS(PosCss(GetClassName(oBtn), CSS_BTN_ATIVO)) 

                    oDialog:Activate(,,,.T.,,,)

                Endif 
            Else

                LjxjMsgErr(STR0023, "", "LjFidelityCoreInterface_BonusStep")    //"Cliente não possui bônus para utilizar."
            EndIf 

        EndIf 
    EndIf 
Return 

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} BonusController
Efetua validações referente ao terceiro passo disponibilização de bônus

@type       Method
@param      aBrowse, Array, Bônus selecionados na tela
@param      aBonus, Array, Informações dos bônus disponibilizados pelo FidelityCore
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method BonusController(aBrowse,aBonus) Class LjFidelityCoreInterface

    Local nX
    
    For nX := 1 To len(aBrowse)
        If aBrowse[nX][1]
            Self:oLjSaleFidelityCore:GetCustomer():SetBonus(,aBonus[nX]["bonusId"],aBonus[nX]["bonusAmount"],aBonus[nX]["partnerID"],aBonus[nX]["partner"],aBonus[nX]["bonusReferenceValue"])
            Exit
        EndIf 
    Next

    Self:lFinalize := .T.

Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CampaignStep
Tela com o último passo seleção de campanha para acumulo de bônus

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method CampaignStep() Class LjFidelityCoreInterface

    Local jResult
    Local nLengthCampaign
    Local nX
    Local oLjSmartPanels
    Local aPanels
    Local nColumns      := 3
    Local nPanel
    Local aFields       := {'', STR0033, STR0016}   //"Descrição"   //"Campanha disponível"
    Local aLengthF      := {15,100,100}
    Local oOK           := LoadBitmap(GetResources(),"LBOK") // Botoes de selecao 
    Local oNO           := LoadBitmap(GetResources(),"LBNO") // Botoes de selecao
    Local aBrowse       := {}
    Local oBrowse       := Nil
    Local oMessage      := Nil
    Local cMessage      := STR0027      //"Deve ser selecionada ao menos uma campanha."
    Local lResult       := .F.
    Local bValidExit    := {||Iif(Empty(Self:oLjSaleFidelityCore:GetCustomer():GetIdCampaign()),(oMessage:Show(), .F. ),.T.)}
    local oDialog       := Nil
    local oPanels       := Nil

    FWMsgRun(,{|| lResult := Self:oLjFidelityCoreCommunication:Campaign(Self:cBusinessUnitId,Self:cPartnerCode,Self:oLjSaleFidelityCore,Self:cStoreId)}, STR0001, STR0028)    //"TOTVS Bonificações"    //"Comunicando com programa de bonificação"

    If lResult
        jResult := Self:oLjFidelityCoreCommunication:ResultCampaign()  
        
        If ValType(jResult) == "J"

            Self:SetNextStep(jResult["nextStep"])
            nLengthCampaign := Len(jResult["campaigns"])
            
            If nLengthCampaign > 1

                oDialog := TDialog():New(0, 0, Self:nHeight, Self:nWidth, STR0001, , , ,DS_MODALFRAME, CLR_BLACK, CLR_WHITE, , , .T.) // -- 'TOTVS Bonificações'
                oPanels := tPanel():New(0,0,"",oDialog,Self:oFont,.T.,,,,Self:nWidth * 0.50,Self:nHeight * 0.50)

                // -- Remove Botão de X (Fechar)
                oDialog:lEscClose := .F.
                
                oLjSmartPanels  := LjSmartPanels():New(.F.,oPanels,Self:nWidth,Self:nHeight,Self:nMinimumPanelWidth,Self:nMinimumPanelHeight,2.5)
                aPanels := oLjSmartPanels:Creat(27,nColumns)

                // -- Cabeçalho
                nPanel := 1
                oLjSmartPanels:Rearrange(nPanel,nColumns,1)
                oSay := TSay():New(00,00,{|| STR0017}, aPanels[nPanel][1],,,,,,.T.,,,300,18)    //"Em qual campanha o cliente deseja acumular ?"
                oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'18',.T.})) 

                nPanel := nPanel + nColumns
                oLjSmartPanels:Rearrange(nPanel,nColumns,1)
                oSay := TSay():New(10,00,{|| STR0018}, aPanels[nPanel][1],,,,,,.T.,,,300,10)    //"Escolha uma campanha da lista de campanhas disponíveis"
                oSay:SetCSS(PosCss(GetClassName(oSay), CSS_LABEL_FOCAL,{'16',.F.})) 


                // -- Corpo
                nPanel := nPanel + nColumns
                oLjSmartPanels:Rearrange(nPanel,nColumns,4)
                oBrowse := TCBrowse():New( 00 , 00, aPanels[nPanel][1]:NWIDTH * 0.50, aPanels[nPanel][1]:NHEIGHT * 0.50,,aFields,aLengthF, aPanels[nPanel][1],,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

                For nX := 1 To nLengthCampaign
                    AAdd(aBrowse,{.F.,jResult["campaigns"][nX]["description"],jResult["campaigns"][nX]["operatorText"]})
                Next

                oBrowse:SetArray(aBrowse)
                oBrowse:bLine := {||{ If(aBrowse[oBrowse:nAt,01],oOK,oNO)   ,;
                                        aBrowse[oBrowse:nAt,02]             ,;
                                        aBrowse[oBrowse:nAt,03] }}

                oBrowse:bLDblClick := {|| LjSelectTCB(oBrowse:nAt,@aBrowse,1),oBrowse:DrawSelect(),oBrowse:Refresh() }

                // -- Mensagem de erro
                nPanel := nPanel + nColumns * 4
                oLjSmartPanels:Rearrange(nPanel,nColumns,1)
                
                oMessage :=  TSay():New(00,00,{||'<font color="red">' + cMessage + '</font>'},aPanels[nPanel][1],,,,,,.T.,,,aPanels[nPanel][1]:NWIDTH * 0.50,10,,,,,,.T.)
                oMessage:SetCSS(PosCss(GetClassName(oMessage), CSS_LABEL_FOCAL,{'16',.F.})) 
                oMessage:Hide()

                // -- Rodapé
                oBtn := TButton():New( 00, 00, STR0003, aPanels[Len(aPanels)][1]        ,{|| Iif(Self:CampaignController(aBrowse,jResult["campaigns"]),Self:NextStep(oDialog),oMessage:Show())}, aPanels[Len(aPanels)][1]:NWIDTH * 0.50,aPanels[Len(aPanels)][1]:NHEIGHT * 0.50,,,.F.,.T.,.F.,,.F.,,,.F. ) //"Enviar"
                oBtn:SetCSS(PosCss(GetClassName(oBtn), CSS_BTN_FOCAL)) 
                
                oDialog:Activate(,,,.T.,bValidExit,,)

            ElseIf nLengthCampaign == 1

                AAdd(aBrowse,{.T.,jResult["campaigns"][1]["operatorText"]})
                Self:CampaignController(aBrowse,jResult["campaigns"])
                Self:NextStep()

            Else
                //Nenhuma campanha retornada
            EndIf 
        
        EndIf
    
    Endif 
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} CampaignStep
Tela com o último passo seleção de campanha para acumulo de bônus
Efetua validações referente ao último passo, seleção de campanha para acumulo de bônus

@type       Method
@param      aBrowse, Array, Campanha selecionada na tela
@param      aCampaign, Array, Informações das campanhas disponibilizadas pelo FidelityCore
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method CampaignController(aBrowse,aCampaign) Class LjFidelityCoreInterface

    Local lResult := .F.
    Local nX      := 0

    For nX := 1 To len(aBrowse)
        If aBrowse[nX][1]
            Self:oLjSaleFidelityCore:GetCustomer():SetCampaign( , aCampaign[nX]["id"])
            lResult := .T.
            Exit
        EndIf
    Next nX

Return lResult

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FinalizeStep
Passo de finalização

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method FinalizeStep() Class LjFidelityCoreInterface

    Local lResult := .F.
    
    FWMsgRun(,{|| lResult := Self:oLjFidelityCoreCommunication:Finalize(Self:cBusinessUnitId,Self:cPartnerCode,Self:oLjSaleFidelityCore,Self:cStoreId)}, STR0001, STR0028)   //"TOTVS Bonificações"     //"Comunicando com programa de bonificação"

    If lResult
        jResult := Self:oLjFidelityCoreCommunication:ResultFinalize()  
        
        If ValType(jResult) == "J"
            Self:lFinalize := .T.
        Else
            LjxjMsgErr(STR0034, STR0035, "LjFidelityCoreInterface_FinalizeStep")     //"Não foi possível realizar a baixa do bônus no parceiro de bonificação."     //"Entre em contato com o parceiro de bonificação para realizar a baixa manual."
        EndIf
    Else
        LjxjMsgErr(STR0034, STR0035, "LjFidelityCoreInterface_FinalizeStep")     //"Não foi possível realizar a baixa do bônus no parceiro de bonificação."     //"Entre em contato com o parceiro de bonificação para realizar a baixa manual."
    EndIf

    Self:SetNextStep()

return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBonus
Retorna o bônus do cliente

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method NextStep(oDialog) Class LjFidelityCoreInterface

    If ValType(oDialog) == "O"
        oDialog:End()
    EndIf
    
    Self:FollowFlow := .T.

return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} GetBonus
Retorna o bônus do cliente

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method GetBonus() Class LjFidelityCoreInterface
return Iif(Valtype(Self:oLjSaleFidelityCore:GetCustomer()) == "O", Self:oLjSaleFidelityCore:GetCustomer():GetBonus(),0)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FidelityCSS
Metodo para fins de rastreio na função POSCSS

@type       Method
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Method FidelityCSS(oObj,nStyle,xPar01) Class LjFidelityCoreInterface
Return POSCSS(GetClassName(oObj), nStyle, xPar01)

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} LjSelectTCB
Função executada no duplo clique do grid de campanha

@type       function
@param      nAt, Numérico, Linha posicionada no grid
@param      aBrowse, Array, Dados do grid
@param      nPos, Numérico, Posição do array aBrowse que define se a linha esta selecionada
@author     Lucas Novais (lnovais@)
@since      14/05/2021
@version    12.1.33
/*/
//-------------------------------------------------------------------------------------
Static Function LjSelectTCB(nAt,aBrowse,nPos)
    Local nX 
    
    If aBrowse[nAt][nPos]
        aBrowse[nAt][nPos] := .F.
    Else
        For nX := 1 To len(aBrowse)
            If nX == nAt
                aBrowse[nX][nPos] := .T. 
            Else 
                aBrowse[nX][nPos] := .F.
            EndIf 
        Next 
    EndIf 

Return
