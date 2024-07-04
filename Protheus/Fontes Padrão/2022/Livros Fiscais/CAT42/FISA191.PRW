#include "protheus.ch"
#include "FWMBROWSE.CH"
#include "FWMVCDEF.CH"
#include "FISA191.ch"
//-------------------------------------------------------------------
/*/{Protheus.doc} FISA191()

Carga de estoque inicial.
PORTARIA CAT 42/2018 - SISTEMA DE APURAÇÃO E RESSARCIMENTO OU 
COMPLEMENTO DO ICMS RETIDO POR SUBSTITUIÇÃO TRIBUTÁRIA. 
Esta rotina faz o Cadastro dos saldos iniciais em estoque dos produtos.

@author Eduardo Vicente da Silva
@since 22/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function FISA191()

Local   oBrowse := Nil

//Verifico se as tabelas existem antes de prosseguir
If AliasIndic("F2V") 
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("F2V")
    oBrowse:SetDescription(STR0002) // Cadastro dos Saldos Iniciais - Ressarcimento ICMS-ST
    oBrowse:SetFilterDefault("F2V_FILIAL == " + ValToSql(xFilial("F2V")))
    oBrowse:Activate()
Else
    Help("",1,"Help","Help",STR0001,1,0) // Dicionário desatualizado, verifique as atualizações da PORTARIA CAT 42/2018 - SISTEMA DE APURAÇÃO E RESSARCIMENTO OU COMPLEMENTO DO ICMS RETIDO POR SUBSTITUIÇÃO TRIBUTÁRIA.
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc}MenuDef
Funcao responsável por gerar menu

@author Eduardo Vicente da Silva
@since 22/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function MenuDef()
Local aRotina	:= {}

ADD OPTION aRotina Title STR0021       Action 'VIEWDEF.FISA191' OPERATION 2 ACCESS 0 // 'Visualizar'
ADD OPTION aRotina Title STR0022       Action 'VIEWDEF.FISA191' OPERATION 3 ACCESS 0 // 'Incluir'
ADD OPTION aRotina Title STR0023       Action 'VIEWDEF.FISA191' OPERATION 4 ACCESS 0 // 'Alterar'
ADD OPTION aRotina Title STR0024       Action 'F191ConfExc()'   OPERATION 5 ACCESS 0 // 'Excluir'
ADD OPTION aRotina Title STR0025       Action 'F191ExcLote()'   OPERATION 5 ACCESS 0 // 'Excluir em Lote'
ADD OPTION aRotina Title STR0007       Action 'F191Proc()'      OPERATION 3 ACCESS 0 // Carregar Saldos Iniciais 

Return aRotina

//-------------------------------------------------------------------
/*/{Protheus.doc}  ModelDef
Função que criará o modelo o cadastro de saldo incial com a tabela F2V

@author Eduardo Vicente da Silva
@since 22/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ModelDef()

//Criação do objeto do modelo de dados
Local oModel := Nil

//Estrutura correspondete a tabela de Saldo Inicial F2V
Local oCabecalho := FWFormStruct(1, "F2V" )

//Instanciando o modelo
oModel	:=	MPFormModel():New('FISA191',{|oModel|VldApur(oModel)},{|oModel|VALIDACAO(oModel) .And. VldApur(oModel)}) 

//Atribuindo estruturas para o modelo
oModel:AddFields("FISA191",,oCabecalho)

//Inicializa o campo F2V_TPREG com o conteúdo igual a 2 - Saldo Inicial - Manual.
oCabecalho:SetProperty('F2V_TPREG' , MODEL_FIELD_INIT ,{||"2"} )

//Validação do campo F2V_PRODUT para garantir que o produto atende a regra de preenchimento.
oCabecalho:SetProperty('F2V_PRODUT' , MODEL_FIELD_VALID ,{||VldProd(oModel)} )

//Validação do campo F2V_ANOMES para garantir que seja uma informação válida.
oCabecalho:SetProperty('F2V_ANOMES' , MODEL_FIELD_VALID ,{||VldAnoMes(oModel)} )

//Habilita o campo F2V_ANOMES apenas na inclusão.
oCabecalho:SetProperty('F2V_ANOMES' , MODEL_FIELD_WHEN ,{||oModel:GetOperation()==3} )

//Habilita o campo F2V_PRODUT apenas na inclusão.
oCabecalho:SetProperty('F2V_PRODUT' , MODEL_FIELD_WHEN ,{||oModel:GetOperation()==3} )

oModel:SetPrimaryKey( {"F27_FILIAL","F2V_ANOMES","F2V_PRODUT"} )

//Adicionando descrição ao modelo
oModel:SetDescription(STR0002) // Cadastro dos Saldos Iniciais - Ressarcimento ICMS-ST

Return oModel

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
Funcao generica MVC do View

@author Eduardo Vicente da Silva
@since 22/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function ViewDef()

//Criação do objeto do modelo de dados da Interface do Cadastro
Local oModel     := FWLoadModel( "FISA191" )

//Criação da estrutura de dados utilizada na interface do cadastro
Local oCabecalho    := FWFormStruct(2, "F2V")
Local oView         := Nil
Local cVersao       := GetVersao(.F.)

oView := FWFormView():New()
oView:SetModel( oModel )

//Atribuindo formulários para interface
oView:AddField( 'VIEW_CABECALHO'    , oCabecalho  , 'FISA191')

//Criando um container com nome tela com 100%
oView:CreateHorizontalBox( 'SUPERIOR'  , 100 )

//O formulário da interface será colocado dentro do container
oView:SetOwnerView( 'VIEW_CABECALHO'   , 'SUPERIOR' )

//Colocando título do formulário
oView:EnableTitleView('VIEW_CABECALHO'      , STR0002 )

If cVersao == '12'
	oView:SetViewProperty("*", "ENABLENEWGRID")
	oView:SetViewProperty( "*", "GRIDNOORDER" )
EndIf

Return oView

//-------------------------------------------------------------------
/*/{Protheus.doc} Validacao
Funcao generica de validação do cadastro

@author Eduardo Vicente da Silva
@since 22/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function Validacao(oModel)
Local nOperation 	:= oModel:GetOperation()
Local lRet          := .T.
Local nQtde         := oModel:GetValue ('FISA191',"F2V_QTDSLD")
Local nValUni       := oModel:GetValue ('FISA191',"F2V_VUNSLD")
Local nValTot       := oModel:GetValue ('FISA191',"F2V_VTOSLD")
Local cAnoMes       := oModel:GetValue ('FISA191',"F2V_ANOMES")
Local cProduto      := oModel:GetValue ('FISA191',"F2V_PRODUT")

If nOperation == MODEL_OPERATION_INSERT
    F2V->(dbSetOrder(1))
    If F2V->(dbSeek(xFilial("F2V")+cAnoMes+cProduto))
        lRet := .F.
        Help( ,, 'Help',, STR0006, 1, 0 ) //"Ano/Mês e Produto já estão cadastrados."
    EndIf 
EndIf

If nOperation == MODEL_OPERATION_INSERT .Or. nOperation == MODEL_OPERATION_UPDATE
    If (nQtde*nValUni) != nValTot
        lRet := .F.
        Help( ,, 'Help',, STR0003, 1, 0 ) //"Valor informado do total do saldo inválido."
    EndIf
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldProd
Funcao generica de validação do produto

@author Eduardo Vicente da Silva
@since 22/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function VldProd(oModel)
Local nOperation 	:= oModel:GetOperation()
Local lRet          := .T.
Local cProduto      := oModel:GetValue ('FISA191',"F2V_PRODUT")
Local lFuncApur     := FWIsInCallStack("FISA192")

If nOperation == MODEL_OPERATION_INSERT
    
    If (lRet := lFuncApur .Or. ExistCpo("SB1", cProduto))
        SB1->(dbSetOrder(1))
        SB1->(dbSeek(xFilial("SB1")+cProduto, .F.))
        If SB1->B1_CRICMS != '1'
            lRet := .F.
            //Comentado o help deste campo, por se tratar de uma rotina de apuração, pois em um cenario em que exista uma grande base de dados, 
            //serao mostradas uma mensagem por registro a serem tratadas. DSERFIS1-14197
            If !lFuncApur
                Help( ,, 'Help',, STR0005, 1, 0 ) //"Produto não pode ser utilizado devido ao campo Art. 271 estar diferente de Sim."
            EndIf    
        EndIf
    EndIf
 
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldAnoMes
Funcao generica de validação do produto

@author Eduardo Vicente da Silva
@since 22/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function VldAnoMes(oModel)
Local nOperation 	:= oModel:GetOperation()
Local cAnoMes       := oModel:GetValue ('FISA191',"F2V_ANOMES")
Local lRet          := .T.

If nOperation == MODEL_OPERATION_INSERT
    
    If Empty(StoD(cAnoMes+'01'))
        lRet := .F.
        Help( ,, 'Help',, STR0014, 1, 0 ) //"Informe um Ano/Mês válido."
    EndIf        
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} VldApur
Função para validar se existe apuração para permitir alteração/gravar as informações de saldo de estoque e financeiro.

@author Eduardo Vicente da Silva
@since 26/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function VldApur(oModel)
Local lRet       := .T.
Local nOperation  := oModel:GetOperation()
Local cTpReg      := oModel:GetValue ('FISA191',"F2V_TPREG ")

If nOperation == MODEL_OPERATION_UPDATE

    If cTpReg != "2"
        lRet := .F.
        Help( ,, 'Help',, STR0016, 1, 0 ) //"Apenas registro do tipo 2 - Saldo Inicial Manual pode sofrer alteração."
    EndIf
    
EndIf

Return lRet

//-------------------------------------------------------------------
/*/{Protheus.doc} F191Proc
Funcao generica para processamento do saldo inicial dos produtos

@author Eduardo Vicente da Silva
@since 22/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Function F191Proc()
Local cDescric	:= ""
Local dDtFecham := CtoD("")
Local oProcess
Local lRet      := .T.

If Pergunte("FISA191",.T.)
	dDtFecham := MV_PAR01
    FwMsgRun(,{|oSay| SelSalIni(oSay,dDtFecham) },STR0007,"")
EndIf

MsgInfo(STR0010,STR0007)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} SelSalIni
Funcao generica para selecionar e gravar o saldo inicial dos produtos

@author Eduardo Vicente da Silva
@since 22/10/2018
@version P12.1.17

/*/
//-------------------------------------------------------------------
Static Function SelSalIni(oSay,dDtFecham)
Local cAliasEst	    := ''
Local cProduto      := ''
Local nVlrUnit      := 0
Local nVlrTot       := 0
Local cAnoMes       := ""
Local aDadosSld     := {}
Local oMovEnProt    := Nil
Local oModel        := FWLoadModel('FISA191')
Local nMVICMPAD     := SuperGetMV('MV_ICMPAD')
Local nAliqInt      := 0

AtualizaMsg( oSay, STR0008 )

SPDBlocH(@cAliasEst,'',dDtFecham)

If Empty(cAliasEst)
	Help( ,, 'Help',, STR0009, 1, 0 ) //"Nenhum registro foi encontrado com a data de fechamento informada. Verifique a data de fechamento."
	Return
Endif	
	
cAnoMes := SubStr(DtoS(LastDay(dDtFecham) + 1), 1, 6)

dbSelectArea(cAliasEst)
(cAliasEst)->(dbGoTop())

While !(cAliasEst)->(Eof())

    cProduto := (cAliasEst)->COD_ITEM

    SB1->(dbSetOrder(1))
    SB1->(dbSeek(xFilial("SB1")+cProduto))

    If SB1->B1_CRICMS != '1'
        (cAliasEst)->(dbSkip())
        Loop
    EndIf

    //---Define a alíquota interna do ICMS para o produto---//
    nAliqInt := Iif(SB1->B1_PICM>0, SB1->B1_PICM, nMVICMPAD)

    nQtde := (cAliasEst)->QTD

    aDadosSld := {}

    //Calcula o saldo financeiro dos movimentos de entrada de acordo com a quantidade de estoque na data do fechamento informado.
    //Exemplo, Se a quantidade em estoque do produto for de 10, irá buscar o saldo financeiro nos movimentos de entrada enquanto a
    // quantidade do movimento for menor que 10.
    oMovEnProt := FISA190MOVIMENTOENTPROTHEUS():New()
    oMovEnProt:cTipoRet := 'C'
    oMovEnProt:cCodProd := cProduto
    oMovEnProt:nQtdade  := nQtde
    oMovEnProt:dDataMov := dDtFecham
    oMovEnProt:nAliqInt := nAliqInt
    oMovEnProt:DefICMSEnt()
    nVlrTot  := oMovEnProt:nVlrICMSSu
    aDadosSld := oMovEnProt:aSldVlrDet

    //Caso retorne zero significa que não possui quantidade suficiente para compor o saldo financeiro, sendo assim o produto é desconsiderado.
    If nVlrTot == 0
        (cAliasEst)->(dbSkip())
        Loop    
    EndIf

    nVlrUnit := nVlrTot / nQtde

    //Grava as informações nas tabelas F2V e F2U.
    GrvSaldo(cAnoMes, cProduto, nQtde, nVlrUnit, nVlrTot, aDadosSld, oModel)

    (cAliasEst)->(dbSkip())

EndDo

(cAliasEst)->(dbCloseArea())

AtualizaMsg( oSay, STR0010 )

oModel:Destroy()
 
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} GrvSaldo
Função para gravar as informações de saldo de estoque e financeiro.

@author Eduardo Vicente da Silva
@since 26/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function GrvSaldo(cAnoMes, cProduto, nQtde, nVlrUnit, nVlrTot, aDadosSld, oModel)
Local nPos      := 0
Local aArea     := GetArea()
Local oSubF2V
Local cOrdem    := "000000001"

oModel:SetOperation(3) //Inclusão
oModel:Activate()

oSubF2V := oModel:GetModel( "FISA191" )

oSubF2V:SetValue( "F2V_ANOMES", cAnoMes )
oSubF2V:SetValue( "F2V_PRODUT", cProduto )
oSubF2V:SetValue( "F2V_TPREG " , "1" )
oSubF2V:SetValue( "F2V_QTDSLD", nQtde )
oSubF2V:SetValue( "F2V_VUNSLD", nVlrUnit )
oSubF2V:SetValue( "F2V_VTOSLD", nVlrTot )
oSubF2V:SetValue( "F2V_QTDFIM", 0 )
oSubF2V:SetValue( "F2V_VUNFIM", 0 )
oSubF2V:SetValue( "F2V_VTOFIM", 0 )

If oModel:VldData()

    Begin Transaction
    For nPos := 1 to Len(aDadosSld)
   
        RecLock("F2U",.T.)
        F2U->F2U_FILIAL := xFilial("F2U")
        F2U->F2U_ANOMES := cAnoMes
        F2U->F2U_NFISCA := aDadosSld[nPos, 1] 
        F2U->F2U_SERIE  := aDadosSld[nPos, 2]
        F2U->F2U_PARTIC := aDadosSld[nPos, 3]
        F2U->F2U_LOJA   := aDadosSld[nPos, 4]
        F2U->F2U_ITEM   := aDadosSld[nPos, 5]
        F2U->F2U_PRODUT := aDadosSld[nPos, 6] 
        F2U->F2U_CFOP   := aDadosSld[nPos, 7]
        F2U->F2U_QTDSLD := aDadosSld[nPos, 8] 
        F2U->F2U_VUNSLD := aDadosSld[nPos, 9]
        F2U->F2U_VTOSLD := aDadosSld[nPos,10]
        F2U->F2U_TPREG  := "1"
        F2U->F2U_TPMOV  := "E"
        F2U->F2U_ORDEM  := cOrdem
        MsUnLock()

        cOrdem := Soma1(cOrdem)
        
    Next nPos

    oModel:CommitData()
    End Transaction

Endif

oModel:DeActivate()

RestArea(aArea)

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ConfExc
Função para exibir a tela e confirmar a exclusão do registro.

@author Eduardo Vicente da Silva
@since 26/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function F191ConfExc()

Local lRet := IIf (F2V->F2V_TPREG == "3" ,VldExcl (F2V->F2V_PRODUT, F2V->F2V_FILIAL), .T.) 

If F2V->F2V_TPREG == "3" .And. !lRet
    Help( ,, 'Help',, STR0026, 1, 0 )
Else
    FWExecView(STR0024,"FISA191",MODEL_OPERATION_DELETE, , ,{ || ExcTabApur() } , , ) //"Excluir"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcTabApur
Função para deletar as informações de saldo de estoque e financeiro.

@author Eduardo Vicente da Silva
@since 26/10/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ExcTabApur()
Local cChave := xFilial("F2U")+F2V->F2V_ANOMES + F2V->F2V_PRODUT 
Local lRet   := .T.
 
Begin Transaction
F2U->(dbSetOrder(1))
If F2U->(dbSeek(cChave))
    While !F2U->(EOF()) .And. F2U->F2U_FILIAL+F2U->F2U_ANOMES+F2U->F2U_PRODUT = cChave
        If F2U->F2U_TPREG == "1"
            RecLock("F2U", .F.)
            F2U->(dbDelete())
            MsUnLock()
        EndIf

        F2U->(dbSkip())
    EndDo
EndIf

RecLock("F2V", .F.)
F2V->(dbDelete())
MsUnLock()
End Transaction

Return lRet

//------------------------------------------------------------------
/*/{Protheus.doc} AtualizaMsg

Função que será chamada para atualizar descrição da barra de status

@author Eduardo Vicente da Silva
@since 22/11/2018
@version 12.1.17
/*/
//------------------------------------------------------------------
Static Function AtualizaMsg( oSay, cMsg )

oSay:cCaption := (cMsg)
ProcessMessages()

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcTabApur
Função para deletar as informações de saldo de estoque e financeiro.

@author Eduardo Vicente da Silva
@since 22/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Function F191ExcLote()
Local cAnoMes := ""
Local lManual := .F. //Indica se fará exclusão dos saldos cadastrados manualmente.

If Pergunte("FISA191E",.T.)
	cAnoMes := MV_PAR01
    lManual := Iif(MV_PAR02 == 1,.T.,.F.)

    FwMsgRun(,{|oSay| ExcTabLote(oSay,cAnoMes,lManual) },STR0019,"") //"Exclusão em Lote"
Else
    Return
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} ExcTabApur
Função para deletar as informações de saldo em lote.

@author Eduardo Vicente da Silva
@since 22/11/2018
@version 12.1.17
/*/
//-------------------------------------------------------------------
Static Function ExcTabLote(oSay, cAnoMes, lManual)
Local lAchou := .F.
Local lPermExc := .F.
AtualizaMsg( oSay, STR0018 ) //"Selecionando os registros para exclusão"

Begin Transaction
F2U->(dbSetOrder(3))
F2U->(dbSeek(xFilial("F2U")+cAnoMes))

While !F2U->(EOF()) .And. F2U->F2U_FILIAL+F2U->F2U_ANOMES = xFilial("F2U")+cAnoMes
    If F2U->F2U_TPREG == "1"
        RecLock("F2U", .F.)
        F2U->(dbDelete())
        MsUnLock()
    EndIf

    F2U->(dbSkip())
EndDo

F2V->(dbSetOrder(1))
F2V->(dbSeek(xFilial("F2V")+cAnoMes))

While !F2V->(EOF()) .And. F2V->F2V_FILIAL+F2V->F2V_ANOMES = xFilial("F2V")+cAnoMes
    
    lPermExc := IIf (F2V->F2V_TPREG == "3" ,VldExcl (F2V->F2V_PRODUT, F2V->F2V_FILIAL), .F.) // Validação para permitir exclusão dos registros com saldo 0 criados na primeira apuração 
    
    If F2V->F2V_TPREG == "1" .Or. (lManual .And. F2V->F2V_TPREG == "2") .Or. (F2V->F2V_TPREG == "3" .And. lPermExc)  
        lAchou := .T.

        RecLock("F2V", .F.)
        F2V->(dbDelete())
        MsUnLock()
    EndIf

    F2V->(dbSkip())
EndDo
End Transaction

If lAchou 
    MsgInfo(STR0010,STR0019) //"Processamento Concluído", "Exclusão em Lote"
Else
    MsgInfo(STR0020,STR0019) //"Nenhum registro do Tipo 1 - Carga Automática foi encontrado para o Ano/Mês informado", "Exclusão em Lote"
EndIf

Return 

//-------------------------------------------------------------------
/*/{Protheus.doc} VldExcl
Função para deletar as informações de saldo em lote.

@author Erich Buttner
@since 03/07/2019
@version 12.1.17
/*/
//-------------------------------------------------------------------

Static Function VldExcl (cProduto, cFilExcl) 

Local lRet := .F.
Local cAliasExc := GetNextAlias()

BeginSql Alias cAliasExc
    SELECT COUNT(F2V.F2V_PRODUT) CNT 
    FROM %Table:F2V% F2V 
    WHERE F2V.F2V_FILIAL = %Exp:cFilExcl%  AND 
          F2V.F2V_PRODUT = %Exp:cProduto% AND
       	  F2V.%NotDel%
EndSql

DbSelectArea(cAliasExc)

lRet := Iif((cAliasExc)->CNT > 1 , .F., .T.)


Return lRet