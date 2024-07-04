#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE 'PCOA298.CH'

Static __cCodPPA := Space(6)
Static __cVerPPA := Space(3)

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA298
Cadastro de Fontes de Financiamento PPA
@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PCOA298()
Local oBrowse

dbSelectArea("A21")
dbSetOrder(1)

dbSelectArea("A22")
dbSetOrder(1)

oBrowse := FWmBrowse():New()

oBrowse:SetAlias( 'A21' )

oBrowse:AddLegend( "A21_STATUS == '1'"		, "GREEN"	, "Ativo"	) 
oBrowse:AddLegend( "A21_STATUS == '2'"		, "RED"		, "Inativo"	) 

oBrowse:SetDescription( STR0001 ) //"Cadastro Fontes de Financiamento PPA"

oBrowse:Activate()

Return Nil

//-------------------------------------------------------------------
/*/{Protheus.doc} MenuDef
Menu da Rotina

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title STR0002 Action 'VIEWDEF.PCOA298' OPERATION 2 ACCESS 0 //'Visualizar'
ADD OPTION aRotina Title STR0003 Action 'VIEWDEF.PCOA298' OPERATION 3 ACCESS 0 //'Incluir'
ADD OPTION aRotina Title STR0004 Action 'VIEWDEF.PCOA298' OPERATION 4 ACCESS 0 //'Alterar'
ADD OPTION aRotina Title STR0005 Action 'VIEWDEF.PCOA298' OPERATION 5 ACCESS 0 //'Excluir'
ADD OPTION aRotina Title STR0006 Action 'VIEWDEF.PCOA298' OPERATION 8 ACCESS 0 //"Imprimir"
ADD OPTION aRotina TITLE STR0007 Action 'VIEWDEF.PCOA298' OPERATION 9 ACCESS 0 //"Copiar"

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
Modelo de Dados da Rotina

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ModelDef()
Local oStruA21 := FWFormStruct(1,'A21')
Local oStruA22 := FWFormStruct(1,'A22')
Local oModel

//Criação de gatilho
oStruA22:AddTrigger("A22_CONTA","A22_TIPREC",{|| .T. },{|| If( Subs(M->A22_CONTA,1,1)$"17", "1", "2" ) })

//Adiciona valid

//Adicionando o When 

//Inicializador padrão

oModel := MPFormModel():New('PCOA298',{|oModel|P298PREVLD(oModel)},{|oModel|P298VLD(oModel)}/*PosValidacao*/,/*commit*/)
oModel:SetVldActivate({|oModel|P298ACTIVAT(oModel)})

oModel:AddFields('A21MASTER',,oStruA21)

oModel:AddGrid('A22DETAIL','A21MASTER',oStruA22, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Define o número máximo de linhas que o model poderá receber
oModel:GetModel("A22DETAIL"):SetMaxLine(9999)

oModel:SetRelation('A22DETAIL',{{'A22_FILIAL','XFilial("A22")'},{'A22_CODPPA','A21_CODPPA'},{'A22_VERPPA','A21_VERPPA'},{'A22_ANOREF', 'A21_ANOREF'}}, A22->(IndexKey(1)) )

// Liga o controle de não repetição de linha
oModel:GetModel( 'A22DETAIL' ):SetUniqueLine( { 'A22_CONTA' } )

oModel:SetPrimarykey({'A21_FILIAL','A21_CODPPA','A21_VERPPA', 'A21_ANOREF'})

oModel:SetDescription( STR0001 )  //'Cadastro Fontes de Financimento PPA'
 
oModel:GetModel( 'A22DETAIL' ):SetOptional( .T. )

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Tela da Rotina

@author TOTVS
@since 16/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oStruA21	:= FWFormStruct(2,'A21')
Local oStruA22	:= FWFormStruct(2,'A22')
Local oModel	:= FWLoadModel('PCOA298')
Local oView

oView := FWFormView():New()

oView:SetModel(oModel)

oView:AddField('VIEW_A21',oStruA21,'A21MASTER')
oView:AddGrid('VIEW_A22',oStruA22,'A22DETAIL')

// Cria Folder na view
oView:CreateFolder( 'FONTES_FINANC' )

// Cria pastas nas folders
oView:AddSheet( 'FONTES_FINANC', 'ABA1', 'Itens' )  

// Criar "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'CEMCIMA' 	,  25,,, 'FONTES_FINANC', 'ABA1' )
oView:CreateHorizontalBox( 'CEMBAIXO'	,  75,,, 'FONTES_FINANC', 'ABA1' )

oView:SetOwnerView('VIEW_A21','CEMCIMA'		)
oView:SetOwnerView('VIEW_A22','CEMBAIXO'	)

//Retira Campos da tela

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_A22', 'A22_ITEM' )

oView:SetCloseOnOk({||.T.})

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} P298ACTIVAT
Funçao para realizar validação antes de abrir a tela

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P298ACTIVAT(oModel)
Local nOper     := oModel:getOperation()
Local lRet      := .T.

If nOper == 3
    __cCodPPA := Space(6)
    __cVerPPA := Space(3)
Else
    __cCodPPA := A21->A21_CODPPA
    __cVerPPA := A21->A21_VERPPA
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P298PREVLD
Funçaõ para colocar status como 1 quando for gerar nova revisão

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P298PREVLD(oModel)

Local lRet := .T.
Local oModelA21	:= oModel:GetModel("A21MASTER")
Local nOper := oModel:GetOperation()

If nOper == 3

ElseIf nOper == 4

    M->A21_CODPPA := oModel:GetValue("A21MASTER", "A21_CODPPA")
    M->A21_VERPPA := oModel:GetValue("A21MASTER", "A21_VERPPA")
    AK0->( dbSetOrder(1) )
    AK0->( dbSeek( xFilial("AK0")+M->A21_CODPPA+M->A21_VERPPA ) )
    M->A21_ANOINI := AK0->AK0_ANOINI
    M->A21_ANOFIM := AK0->AK0_ANOFIM
    oModelA21:LoadValue( "A21_ANOINI" , M->A21_ANOINI )
    oModelA21:LoadValue( "A21_ANOFIM" , M->A21_ANOFIM )
    __cCodPPA := M->A21_CODPPA
    __cVerPPA := M->A21_VERPPA

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} P298VLD
Funçaõ chamada na confirmação da tela

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function P298VLD(oModel)
Local lRet      := .T.
Local oModelA21 := oModel:GetModel("A21MASTER")
Local nRecA21 

Local nAnoIni   := VAL(oModelA21:GetValue("A21_ANOINI"))
Local nAnoFim   := VAL(oModelA21:GetValue("A21_ANOFIM"))
Local nAnoRef   := VAL(oModelA21:GetValue("A21_ANOREF"))
Local cAnoRef   := oModelA21:GetValue("A21_ANOREF")
Local cCodPPA   := oModelA21:GetValue("A21_CODPPA")
Local cVerPPA   := oModelA21:GetValue("A21_VERPPA")
Local nOper     := oModel:GetOperation()

If lRet .And. ( Empty(cCodPPA) .OR. Empty(cVerPPA) )
    HELP(' ',1,"PPANAO" ,,STR0008,1,0)//"O Código/Versão do PPA nao informado."
    lRet := .F.
EndIf

//Verifica se existe o PPA na filial corrente pois as tabelas PPA e Fontes de Financiamento tem que ter mesmo  compartilhamento
If lRet
    AK0->( dbSetOrder(1) )
    If AK0->( ! dbSeek( xFilial("A21")+cCodPPA+cVerPPA ) )
        HELP(' ',1,"PPAFILIAL" ,,STR0009,1,0) //"Não encontrado o PPA informado, o PPA e fontes de financiamento tem que ter mesmo compartilhamento."
        lRet := .F.
    Else
        If AK0->AK0_STATUS != "2"
            HELP(' ',1,"PPAATIVO" ,,STR0010,1,0) //"Encontrado o PPA informado, mas o Status não está ativo.Verifique!"
            lRet := .F.
        EndIf
    EndIf
EndIf

//verifica se ano referencia esta dentro do ano inicio e fim do PPA
If  lRet .And. ( nAnoRef < nAnoIni .OR. nAnoRef > nAnoFim )
    HELP(' ',1,"ANOPPA" ,,STR0011,1,0) //"O ano referencia deve estar entre ano inicio e final do PPA."
    lRet := .F.
EndIf

If lRet
    
    If nOper == 3
        A21->( dbSeek( xFilial("A21") + cCodPPA + cVerPPA + cAnoRef ) )
        If A21->( Found() ) 
            HELP(' ',1,"JAEXSTPPA" ,,STR0012,1,0) //"O PPA+ano referencia ja existe."
            lRet := .F.
        EndIf
    Else
        If A21->A21_ANOREF <> cAnoRef
            nRecA21 := A21->( Recno() )

            A21->( dbSeek( xFilial("A21") + cCodPPA + cVerPPA + cAnoRef ) ) 
            If A21->(! Found()  ) 
                HELP(' ',1,"PPANOTEXIST" ,,STR0016,1,0) //"O PPA+ano referencia não existe."
                lRet := .F.
            Else
                If ( nRecA21 != A21->( Recno() ) )
                    HELP(' ',1,"PPADIF" ,,STR0013,1,0) //"O PPA+ano nao pode ser alterado."
                    lRet := .F.
                EndIf
            EndIf
            A21->( dbGoto( nRecA21 ) )
        EndIf  
    EndIf

    //VALIDA SE GRADE FOI PREENCHIDA -INCLUSAO OU ALTERACAO
    If lRet .And. ( nOper == 3 .OR. nOper == 4 )
        lRet :=  A22LPOS()
    EndIf

EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} PCOA298VLD
Validacao de Campos do cabecalho  

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------

Function PCOA298VLD(nOpcao)
Local lRet := .T.
Local oModel   := FWModelActive()
Local oModelA21:= oModel:GetModel("A21MASTER")

Local nAnoIni   := VAL(oModelA21:GetValue("A21_ANOINI"))
Local nAnoFim   := VAL(oModelA21:GetValue("A21_ANOFIM"))
Local nAnoRef   := VAL(oModelA21:GetValue("A21_ANOREF"))
Local cCodPPA   := oModelA21:GetValue("A21_CODPPA")
Local cVerPPA   := oModelA21:GetValue("A21_VERPPA")

If nOpcao == 1
    //RETIRADO VALIDACAO DO CODIGO DO PPA E COLOCADO NA VERSAO
    AK0->( dbSetOrder(1) )
    lRet := AK0->(  dbSeek( xFilial("AK0")+cCodPPA ) )
    If !lRet
      HELP(' ',1,"PPANOEXST" ,,STR0017,1,0)//"O Código do PPA nao existe. Verifique!"
    EndIf
ElseIf nOpcao ==2 
    If ( Empty(cCodPPA) .OR. Empty(cVerPPA) ) .And. !IsBlind()
        lRet := PCO298F3PPA()
    Else
        __cCodPPA := cCodPPA
        __cVerPPa := cVerPPA
        lRet := A298VldPPA()
    EndIf
ElseIf nOpcao ==3
    //verifica se ano referencia esta dentro do ano inicio e fim do PPA
    If  lRet .And. ( nAnoRef < nAnoIni .OR. nAnoRef > nAnoFim )
        HELP(' ',1,"ANOPPA" ,,STR0011,1,0)//"O ano referencia deve estar entre ano inicio e final do PPA."
        lRet := .F.
    EndIf
    If  lRet .And. A21->( dbSeek( xFilial("A21")+cCodPPA+cVerPPA+StrZero(nAnoRef,4)))
        HELP(' ',1,"JAEXSTPPA" ,,STR0012,1,0) //"O PPA+ano referencia ja existe."
        lRet := .F.
    EndIf
EndIf

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} A298VldPPA
Validacao de Codigo do PPA

@author TOTVS
@since 13/10/2020
@version P12
/*/
//-------------------------------------------------------------------

Static Function A298VldPPA()
Local lRet := .T.

AK0->( dbSetOrder(1) )
lRet := AK0->(  dbSeek( xFilial("AK0")+__cCodPPA+__cVerPPa ) )

Return(lRet)

//-------------------------------------------------------------------
/*/{Protheus.doc} A22LPOS
ValidaÃ§Ã£o 

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Static Function A22LPOS()
Local lRet		:= .T.
Local oModel	:= FWModelActive()
Local nCtdReg   := 0
Local oModelA22 := oModel:GetModel( 'A22DETAIL' )
Local nX

//----------------------------------------
// Valida 
//----------------------------------------
If oModelA22:IsEmpty()
	Help( , ,"A22LPOS", ,STR0014,1,0,,,,,,{ STR0015 })	         //"Grid não preenchido!" ### 
																//"Preencha a grade de digitação de valores."                    
	lRet := .F.
Else
    //valida se dados estao preenchidos na grade
    For nX := 1 TO oModelA22:Length()
        oModelA22:GoLine( nX )							
        If ! oModelA22:IsDeleted()
           nCtdReg++ 
        EndIf
    Next 
    If nCtdReg == 0
    	Help( , ,"A22LPOS", ,STR0014,1,0,,,,,,{ STR0015 })	    //"Grid não preenchido!" ### 
																//"Preencha a grade de digitação de valores."                    
	    lRet := .F.
    Else
        //valida se valores estao preenchidos
        For nX := 1 TO oModelA22:Length()
            oModelA22:GoLine( nX )							
            If ! oModelA22:IsDeleted()
                If oModelA22:GetValue("A22_VLRDIR") + oModelA22:GetValue("A22_VLRIND") == 0
                    Help( , ,"A22LPOS", ,STR0014,1,0,,,,,,{ STR0015 + " ( L: "+Alltrim(Str(nX))+" ) " })	//"Grid não preenchido!" ### 
																                                            //"Preencha a grade de digitação de valores."                    
	                lRet := .F.
                    Exit
                EndIf
            EndIf
        Next 
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Function PCO298F3Cta( )

Funcao que chama consulta padrao conta orçamentaria

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PCO298F3Cta( )

Local aArea := GetArea()
Local lRet  := .F.

lRet := Conpad1( , , , "AK5RC1" )

RestArea(aArea)

Return( lRet )

//-------------------------------------------------------------------
/*/{Protheus.doc} Function PCO298F3PPA( )

Funcao que chama consulta padrao PPA ativos

@author TOTVS
@since 23/03/2020
@version P12
/*/
//-------------------------------------------------------------------
Function PCO298F3PPA()
Local lRet  := .F.
Local oModel   := FWModelActive()
Local oModelA21:= oModel:GetModel("A21MASTER")

lRet := Conpad1( , , , "AK0PPA" )

If lRet

    M->A21_CODPPA := AK0->AK0_CODIGO
    M->A21_VERPPA := AK0->AK0_VERSAO
    M->A21_ANOINI := AK0->AK0_ANOINI
    M->A21_ANOFIM := AK0->AK0_ANOFIM
    oModelA21:LoadValue( "A21_CODPPA" , M->A21_CODPPA )
    oModelA21:LoadValue( "A21_VERPPA" , M->A21_VERPPA )
    oModelA21:LoadValue( "A21_ANOINI" , M->A21_ANOINI )
    oModelA21:LoadValue( "A21_ANOFIM" , M->A21_ANOFIM )
    __cCodPPA := M->A21_CODPPA
    __cVerPPA := M->A21_VERPPA

Else

    M->A21_CODPPA := Space(Len(AK0->AK0_CODIGO))
    M->A21_VERPPA := Space(Len(AK0->AK0_VERSAO))
    M->A21_ANOINI := Space(Len(AK0->AK0_ANOINI))
    M->A21_ANOFIM := Space(Len(AK0->AK0_ANOFIM))
    oModelA21:LoadValue( "A21_CODPPA" , M->A21_CODPPA )
    oModelA21:LoadValue( "A21_VERPPA" , M->A21_VERPPA )
    oModelA21:LoadValue( "A21_ANOINI" , M->A21_ANOINI )
    oModelA21:LoadValue( "A21_ANOFIM" , M->A21_ANOFIM )
    __cCodPPA := Space(6)
    __cVerPPA := Space(3)

EndIf

Return( lRet )