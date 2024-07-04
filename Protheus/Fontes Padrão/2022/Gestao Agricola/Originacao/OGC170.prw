#include "protheus.ch"
#include 'parmtype.ch'
#include "fwmvcdef.ch"
#Include 'FWEditPanel.ch'
#Include 'OGC170.ch'

/*/{Protheus.doc} OGC170
    Tela para consulta das despesas logisticas por regra fiscal no contrato posicionado
    @type  Function
    @author mauricio.joao
    @since 22/08/2018
    @version 1.0
    @param cContrato, char, codigo do contrato  
/*/

Function OGC170(cContrato as Char)
Private oView
Private cCtr := cContrato

    FWExecView( STR0001 ,'OGC170',MODEL_OPERATION_UPDATE,,{|| .T.},{|| .T.} )  //'consulta'

Return 

/*/{Protheus.doc} ModelDef()
    cria o modelo da função
    @type  Static Function
    @author mauricio.joao
    @since 27/08/2018
    @version 1.0
    @return oModel, object, modelo da função
/*/

Static Function ModelDef()

Local oStrField     as Object 
Local oStrMN9A  as Object
Local oStrMNC9  as Object 
Local oModel        as Object 
Local nField        as Numeric
Local cIdField      as Char
Local bLoadN9A 

//Load das Variaveis
oStrField       := GetMField() //model do master
oStrMN9A        := FWFormStruct( 1,'N9A' ) //model da grid n9a
oStrMNC9        := FWFormStruct( 1,'NC9' ) //model da grid nc9
bLoadN9A        := {||LoadN9A( oStrMN9A )}
oModel          := MPFormModel():New( 'OGC170', , , {|| .T.} )

//Gatilhos
oStrMN9A:AddTrigger( 'MARK' , 'MARK' ,,{||LoadNC9(oModel,oStrMNC9)} )

//Adiciono o Mark no Model
oStrMN9A:AddField('Mark',;//ctitulo
    'Mark',;//cTooltip
    'MARK',;//cIdField
    'L',;//cTipo
    1,;//nTamanho
    0,;//nDecimal
    ,;//bValid
    ,;//bWhen
    {},;//aValues
    .F.,;//lObrigat
    ,;//bInit
    ,;//lKey
    .F.,;//lNoUpd
    .F.,;//lVirtual
    ,)//cValid

For nField := 1 To Len(oStrMN9A:aFields)

    cIdField := oStrMN9A:aFields[nField][3]

    oStrMN9A:SetProperty(cIdField ,MODEL_FIELD_VALID      ,{|| .T.}  )
    oStrMN9A:SetProperty(cIdField ,MODEL_FIELD_WHEN       ,{|| .T.}  )
    oStrMN9A:SetProperty(cIdField ,MODEL_FIELD_OBRIGAT    ,.F.       )
    oStrMN9A:SetProperty(cIdField ,MODEL_FIELD_NOUPD      ,.F.       )
    oStrMN9A:SetProperty(cIdField ,MODEL_FIELD_INIT       ,' '       )

Next nField

For nField := 1 To Len(oStrMNC9:aFields)

    cIdField := oStrMNC9:aFields[nField][3]

    oStrMNC9:SetProperty(cIdField ,MODEL_FIELD_VALID      ,{|| .T.})
    oStrMNC9:SetProperty(cIdField ,MODEL_FIELD_WHEN       ,{|| .T.})
    oStrMNC9:SetProperty(cIdField ,MODEL_FIELD_OBRIGAT    ,.F.     )
    oStrMNC9:SetProperty(cIdField ,MODEL_FIELD_NOUPD      ,.F.     )
    oStrMNC9:SetProperty(cIdField ,MODEL_FIELD_INIT       ,' '     )
 
Next nField

oModel:AddFields('MASTER' , ,oStrField ,,,{|| /*Load()*/ } )
oModel:AddGrid('N9A' ,'MASTER' ,oStrMN9A , , , , ,bLoadN9A )
oModel:AddGrid('NC9' ,'MASTER' ,oStrMNC9 , , , , , )


oModel:SetDescription( STR0002 ) //'Despesas Logisticas'

oModel:GetModel('MASTER'):SetDescription( STR0003 ) //'Contrato'
oModel:GetModel('N9A'):SetDescription( STR0004 )//'Regras Fiscais'
oModel:GetModel('NC9'):SetDescription( STR0002 )//'Despesas Logisticas'

oModel:SetPrimaryKey({})

Return oModel

/*/{Protheus.doc} GetMField()
    Monta a estrutura do model Master
    @type  Static Function
    @author mauricio.joao
    @since 25/08/2018
    @version 1.0
    @return oStruct, Object, Estrutura do model
/*/

Static Function GetMField()
Local oStruct := FWFormModelStruct():New()
	
oStruct:AddField('MASTER',;//ctitulo
    'MASTER',;//cTooltip
    'MASTER',;//cIdField
    'L',;//cTipo
    1,;//nTamanho
    0,;//nDecimal
    ,;//bValid
    ,;//bWhen
    {},;//aValues
    .F.,;//lObrigat
    ,;//bInit
    .F.,;//lKey
    .F.,;//lNoUpd
    .F.,;//lVirtual
    ,)//cValid
                    
Return oStruct

/*/{Protheus.doc} ViewDef()
    cria o view da função
    @type  Static Function
    @author mauricio.joao
    @since 27/08/2018
    @version 1.0
    @return oView, object, view da função
/*/

Static Function ViewDef()
Local cIdField      as Char
Local nField        as Numeric
Local nOrdem        as Numeric
Local oModel        as Object
Local oStrVN9A      as Object
Local oStrVNC9      as Object

//Load Variaveis
oModel      := FWLoadModel( 'OGC170' )
oStrVN9A    := FWFormStruct(2,'N9A')
oStrVNC9    := FWFormStruct(2,'NC9')
oView       := FWFormView():New()
nOrdem      := 2

For nField := 1 To Len(oStrVN9A:aFields)
    
    cIdField := oStrVN9A:aFields[nField][1]

    oStrVN9A:SetProperty(cIdField ,MVC_VIEW_CANCHANGE     ,.F.)
    oStrVN9A:SetProperty(cIdField ,MVC_VIEW_ORDEM         ,cValToChar(StrZero(nOrdem,2))) 

    nOrdem++

Next nField

//Adiciono o Mark na View
oStrVN9A:AddField('MARK',; //cIdField
    '01' ,;//cOrdem
    '',;//cTitulo
    '',;//cDescric
    ,;//aHelp
    'L',;//cType
    ,;//cPicture
    ,;//bPictVar
    ,;//cLookUp
    .T.,;//lCanChange
    ,;//cFolder
    ,;//cGroup
    ,;//aComboValues
    ,;//nMaxLenCombo
    ,;//cIniBrow
    ,;//lVirtual
    ,;//cPictVar
    ,;//lInsertLine
    ,)//nWidth                    

For nField := 1 To Len(oStrVNC9:aFields)
    
    cIdField := oStrVNC9:aFields[nField][1]

    oStrVNC9:SetProperty(cIdField ,MVC_VIEW_CANCHANGE     ,.F.)

Next nField

oView:SetModel( oModel )

oView:AddGrid( 'VIEW_N9A',oStrVN9A ,'N9A' )
oView:AddGrid( 'VIEW_NC9',oStrVNC9 ,'NC9' )

oView:CreateHorizontalBox( 'SUPERIOR' ,50 )
oView:CreateHorizontalBox( 'INFERIOR' ,50 )

oView:SetOwnerView( 'VIEW_N9A' ,'SUPERIOR' )
oView:SetOwnerView( 'VIEW_NC9' ,'INFERIOR' )

oView:EnableTitleView( 'VIEW_N9A' )
oView:EnableTitleView( 'VIEW_NC9' )

 oView:showUpdateMsg(.f.)


Return oView

/*/{Protheus.doc} LoadN9A()
    Load da grid N9A com os dados das regras fiscais
    @type  Static Function
    @author mauricio.joao
    @since 27/08/2018
    @version 1.0
    @param oStrN9A, obejct, estrutra do model N9A
    @return aLoad, array, load da grid n9a
/*/

Static Function LoadN9A(oStrN9A)
Local aLoad     as Array
Local nTam      as Numeric
Local nField    as Numeric
Local nPos      as Numeric
Local oViewN9A  as Object  
Local aAreaN9A  as Array

//Load das Variaveis
aAreaN9A    := GetArea('N9A')
oViewN9A    := oView:GetViewStruct('N9A') 
aLoad       := {}
nTam        := Len(oStrN9A:aFields)
nField      := 0
nPos        := 0

N9A->(DbSetOrder(1))
If N9A->(DbSeek(xFilial('N9A')+cCtr))

        nField := 0

        While !(N9A->(Eof())) .AND. ( N9A->N9A_CODCTR == cCtr )
           nField++
           AAdd(aLoad,{ N9A->(Recno()) ,{} } )

            For nPos := 1 to nTam
                If oStrN9A:aFields[nPos][3] == 'MARK'
                    AAdd(aLoad[nField, 2], .F.  )
                Else
                    If oStrN9A:aFields[nPos][14] == .F.         
                        AAdd(aLoad[nField, 2], N9A->&(oStrN9A:aFields[nPos][3] )  )
                    Else
                        AAdd(aLoad[nField, 2], &(oViewN9A:aFields[nPos-1][15]) )            
                    EndIf
                EndIf
            Next nPos 

           N9A->(DbSkip())  

        EndDo

EndIf

RestArea(aAreaN9A)

Return aLoad

/*/{Protheus.doc} LoadNC9()
    gatilho para dar load na grid NC9 com os dados das despesas logisticas
    @type  Static Function
    @author mauricio.joao
    @since 27/08/2018
    @version 1.0
    @param oModel, object, model
    @param oStrMNC9, object, estrutura do model NC9 
    /*/    

Static Function LoadNC9(oModel as Object,oStrMNC9 as Object)
Local oStrN9A  as Object
Local oStrNC9  as Object
Local nStr     as Numeric
Local nGrid    as Numeric
Local nLinha   as Numeric
Local aAreaN9A as Array
Local aAreaNC9 as Array

oStrN9A  := oModel:GetModel('N9A')
oStrNC9  := oModel:GetModel('NC9')
nStr     := 0
nGrid    := 0
nLinha   := 0
aAreaN9A := GetArea('N9A')
aAreaNC9 := GetArea('NC9')


oStrNC9:SetNoInsertLine(.F.)
oStrNC9:SetNoDeleteLine(.F.)  
    
oStrNC9:ClearData(.T.,.T.)

For nGrid := 1 To oStrN9A:Length()

    oStrN9A:GoLine(nGrid)
        If oStrN9A:GetValue('MARK') == .T.
            NC9->(DbSetOrder(1))    
            If NC9->(DbSeek(xFilial('NC9')+oStrN9A:GetValue('N9A_CODCTR')))
               
                While NC9->(!Eof()) .AND. NC9->NC9_CODCTR == oStrN9A:GetValue('N9A_CODCTR')
                    If NC9->NC9_REGFIS == oStrN9A:GetValue('N9A_SEQPRI')                    

                        If nLinha > 0
                            oStrNC9:AddLine()
                        Else
                            nLinha++
                        EndIf

                        oStrNC9:GoLine(oStrNC9:Length())   

                        For nStr := 1 To Len(oStrMNC9:aFields)
                            oStrNC9:SetValue(oStrMNC9:aFields[nStr][3],;
                                    NC9->&(oStrMNC9:aFields[nStr][3] ))

                        Next nStr  
                    EndIf

                    NC9->(DbSkip())
                    
                EndDo
            EndIf
        EndIf
Next nGrid

oStrNC9:GoLine(1)
oStrNC9:SetNoInsertLine(.T.)
oStrNC9:SetNoDeleteLine(.T.)  

oView:Refresh('VIEW_NC9')

RestArea(aAreaN9A)
RestArea(aAreaNC9)

Return