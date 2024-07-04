#Include 'Protheus.ch'
#Include 'FWMVCDEF.CH'
#Include 'FWBROWSE.CH'
#Include 'topconn.ch'
#include 'PLSP500NF.CH'

static cCodLanD := getNewPar("MV_PLLAND") //Codigo de lançamento de Débito
static cCodLanC := getNewPar("MV_PLLANC") //Código de lançamento de Credito
static cFilB19  := xFilial("B19")
static cOpePad  := PLSINTPAD()

/*/{Protheus.doc} PLSP500NF
    (monta o Browse da tela de nota fiscal do fornecedor)
    @type  Function
    @author Thiago Rodrigues
    @since 03/05/2022
    @version version
/*/
Function PLSP500NF(BrjSeqImp)
local cFiltro   := " "
local aColumns  := {}
local aCampos   := {}
local cSql      := ""
Default BrjSeqImp :=""
Private cTempB19 := GetNextAlias()
Private oBrowse	:= nil

//Como a mesma tabela é para cabeçalho e item se faz necessário a criação de uma tabela temporaria 
//para realizar o agrupamento por nota fiscal.
//Adiona os campos da Tabela temporaria 
aAdd( aColumns, { "B19_FILIAL",	"C",	08,00 })
aAdd( aColumns, { "B19_NRONFF",	"C",	20,00 })
aAdd( aColumns, { "B19_OPEORI",	"C",	04,00 })
aAdd( aColumns, { "B19_IDBENE",	"C",	17,00 })
aAdd( aColumns, { "B19_SEQIMP",	"C",	12,00 })
aAdd( aColumns, { "B19_STATUS",	"C",	1,00 })

//Campos que aparecerão no Browse
aAdd( aCampos,   {"FILIAL "	,"B19_FILIAL"	,"C","@!",1,08,00})
aAdd( aCampos,   {"Nro. Nota Fiscal"	,"B19_NRONFF"	,"C","@!",1,20,00})
aAdd( aCampos,   {"Operadora"	,"B19_OPEORI"	,"C","@!",1,04,00})
aAdd( aCampos,   {"Seq. Importação"	,"B19_SEQIMP"	,"C","@!",1,12,00})
aAdd( aCampos,   {"Beneficiário"	,"B19_IDBENE"	,"C","@!",1,17,00})


oTmpTable := FWTemporaryTable():New(cTempB19)
oTmpTable:SetFields( aColumns )
oTmpTable:Create()

//Insere os dados da nota fiscal (itens+cabeçalho) agrupados na temporária
cSql := "INSERT INTO " + oTmpTable:getrealName()
cSql += "(B19_FILIAL,B19_NRONFF,B19_OPEORI,B19_IDBENE,B19_SEQIMP,B19_STATUS) " 
cSql += "SELECT B19_FILIAL,B19_NRONFF,B19_OPEORI,B19_IDBENE,B19_SEQIMP,B19_STATUS from " + RetSqlName("B19") + " B19 "
cSql += "WHERE B19_FILIAL='" + cFilB19 + "' "
cSql += "AND D_E_L_E_T_ = ' ' "
if !Empty(BrjSeqImp) .and. isInCallStack("PLSP500X")
    cSql += "AND B19_SEQIMP = 'BRJ" +BrjSeqImp+ "' "
else
    cSql += "AND B19_SEQIMP <> ' ' "
endif
cSql += "GROUP BY B19_FILIAL,B19_NRONFF,B19_OPEORI,B19_IDBENE,B19_SEQIMP,B19_STATUS " 

PLSCOMMIT(cSql)

dbSelectArea(cTempB19)

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(cTempB19)
oBrowse:SetFields(aCampos)
oBrowse:SetFilterDefault(cFiltro)
oBrowse:SetMenuDef( "PLSP500NF" )
oBrowse:SetOnlyFields({'B19_FILIAL','B19_NRONFF','B19_OPEORI','B19_IDBENE','B19_SEQITE',;
                     'B19_IDUNIC','B19_TPTABE','B19_CDSERV','B19_DSSERV','B19_SEQIMP','B19_TPCOB'})
oBrowse:SetDescription(STR0001) //Nota fiscal do Fornecedor
oBrowse:setMainProc('PLSP500NF')

oBrowse:AddLegend( cTempB19+"->B19_STATUS == '1'",	'BR_VERDE'   ,	 "Liberado para pagamento"  )
oBrowse:AddLegend( cTempB19+"->B19_STATUS == ' '",	'BR_VERMELHO',	 "Não liberado para pagamento"  )

oBrowse:Activate()

If oTmpTable <> Nil
    oTmpTable:Delete()
    oTmpTable := Nil
Endif

Return 

/*/
@author    Thiago Rodrigues
@version   V12
@since     09/2020
/*/
static function menuDef()
local aRotina := {}

Add Option aRotina Title  STR0002   Action 'Visualizar()' Operation 1 Access 0  //Visualizar
Add Option aRotina Title  STR0003   Action 'Analisar()' Operation 4 Access 0  //Analisar
Add Option aRotina Title  STR0004   Action 'PlsLibPAg()' Operation 4 Access 0  //Alterar
return aRotina


//-------------------------------------------------------------------
/*/{Protheus.doc} ModelDef
definição do modelo de dados
@author Thiago Rodrigues
@since 05/2022
@version P12
/*/
//-------------------------------------------------------------------
Static function ModelDef()
local oModel
local oCabB19 := FWFormStruct(1,'B19', { |cCampo| PlCmpCab(cCampo)})// cria as estruturas a serem usadas no modelo de dados
local oGridB19 := FWFormStruct(1,'B19', { |cCampo| PlCmpGri(cCampo)})

oModel := MPFormModel():New( 'PLSP500NF', ,{ |oModel| PLSCADOK(oModel) }) // cria o objeto do modelo de dados

oModel:addFields('B19MASTER',/*cOwner*/, oCabB19)  // adiciona ao modelo um componente de formulário
oModel:AddGrid('B19Detail', 'B19MASTER', oGridB19) // adiciona ao modelo uma componente de grid

oModel:SetRelation( 'B19Detail', { ;
	{ 'B19_FILIAL'	, 'xFilial("B19")' },;
    { 'B19_OPEORI'	, 'B19_OPEORI' },;
	{ 'B19_NRONFF'	, 'B19_NRONFF' },;
    { 'B19_SEQIMP'	, 'B19_SEQIMP' };
    }, 	B19->( IndexKey(4) ) )

oModel:SetPrimaryKey( {"B19_FILIAL", "B19_NRONFF", "B19_OPEORI", "B19_SEQIMP"} )//Chave primaria do model
oModel:GetModel('B19MASTER'):SetDescription(STR0001) //Nota Fiscal do fornecedor

//Modo de edição
oGridB19:SetProperty( "*" , MODEL_FIELD_WHEN,{ ||.F.})
oGridB19:SetProperty( "B19_VLRPGT" , MODEL_FIELD_WHEN,{ ||.T.})
oGridB19:SetProperty( "B19_VLTXPG" , MODEL_FIELD_WHEN,{ ||.T.})
oGridB19:SetProperty( "B19_CODGLO" , MODEL_FIELD_WHEN,{ ||PLWhenGlo()})

//Obrigatorio?
oGridB19:SetProperty( "*",MODEL_FIELD_OBRIGAT, .F.)
oCabB19:SetProperty( "*" ,MODEL_FIELD_OBRIGAT, .F.)

//Valid
oGridB19:SetProperty( 'B19_CODGLO' , MODEL_FIELD_VALID, { || ExistCpo("BCT",cOpePad+oModel:GetModel('B19Detail'):getValue("B19_CODGLO"),1)} )

Return oModel // Retorna o modelo de dados

//-------------------------------------------------------------------
/*/{Protheus.doc} ViewDef
definição do interface
@author Thiago Silva
@since 05/2022
@version P12
/*/
//-------------------------------------------------------------------
Static function ViewDef()
local oView  // interface de visualização construída
local oModel  := FWLoadModel( 'PLSP500NF' ) // cria as estruturas a serem usadas na View
local oCabB19 := FWFormStruct(2, 'B19', { |cCampo| PlCmpCab(cCampo)})
local oGridB19 := FWFormStruct(2, 'B19',{ |cCampo| PlCmpGri(cCampo)} )

oView := FWFormView():New() // cria o objeto de View
oView:SetModel(oModel)		// define qual Modelo de dados será utilizado

oView:AddField('ViewB19' , oCabB19,'B19MASTER') // adiciona no nosso View um controle do tipo formulário
oView:AddGrid('GridB19' , oGridB19,'B19Detail') // adiciona no nosso view um controle do tipo grid

oView:CreateHorizontalBox( 'CABECALHO', 30 ) // cria um "box" horizontal para receber os campos do cabeçalho
oView:CreateHorizontalBox( 'INFERIOR' , 70 ) // cria um "box" horizontal para receber o grid de pegs

oView:SetOwnerView('ViewB19','CABECALHO') // relaciona o identificador (ID) da View com o "box" para exibição
oView:SetOwnerView('GridB19','INFERIOR') // relaciona o identificador (ID) da View com o "box" para exibição

//Não deixa deletar/inserir linhas no grid
oView:SetNoDeleteLine("B19Detail")
oView:SetNoInsertLine("B19Detail")

//Descrição da view
oView:SetDescription(STR0001)

//Ordem dos campos (B19)
oGridB19:SetProperty( 'B19_TPTABE'  , MVC_VIEW_ORDEM, "00" )
oGridB19:SetProperty( 'B19_CDSERV'  , MVC_VIEW_ORDEM, "01" )
oGridB19:SetProperty( 'B19_DSSERV'  , MVC_VIEW_ORDEM, "02" )
oGridB19:SetProperty( 'B19_QTDCOB'  , MVC_VIEW_ORDEM, "03" )
oGridB19:SetProperty( 'B19_VLRAPR'  , MVC_VIEW_ORDEM, "04" )
oGridB19:SetProperty( 'B19_VLRPGT'  , MVC_VIEW_ORDEM, "05" )
oGridB19:SetProperty( 'B19_VLRGLO'  , MVC_VIEW_ORDEM, "06" )
oGridB19:SetProperty( 'B19_VLTXAP'  , MVC_VIEW_ORDEM, "07" )
oGridB19:SetProperty( 'B19_VLTXPG'  , MVC_VIEW_ORDEM, "08" )
oGridB19:SetProperty( 'B19_VLRGTX'  , MVC_VIEW_ORDEM, "09" )

Return oView


//-------------------------------------------------------------------
/*/{Protheus.doc} PlCmpNF
Campos que devem ser exibidos no form
@since 04/2020
@version P12
/*/
//-------------------------------------------------------------------
static function PlCmpCab(cCampo)
Local lRet := .f.
local cString := 'B19_SEQIMP,B19_OPEORI,B19_IDBENE,B19_NRONFF,B19_TPCOB'
      
if (alltrim(cCampo) $ cString)
	lRet := .t.
endif

return lRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PlCmpGri
Campos que devem ser exibidos no form
@since 04/2020
@version P12
/*/
//-------------------------------------------------------------------
static function PlCmpGri(cCampo)
Local lRet := .f.
Local cString := 'B19_TPTABE,B19_CDSERV,'
Local cString += 'B19_DSSERV,B19_QTDCOB,B19_VLRAPR,B19_VLRPGT,B19_VLTXAP,B19_VLTXPG,B19_VLRGLO,B19_VLRGTX'

if (alltrim(cCampo) $ cString)
	lRet := .t.
elseif alltrim(cCampo) == 'B19_CODGLO' //Se colocar na String geral vai aparecer o B19_COD que não é desta rotina
   	lRet := .t.
endif
return lRet


/*{Protheus.doc} Analisar
    (efetua a glosa)
    @type  Static Function
    @author Thiago Rodrigues
    @since 12/05/2022
    @version version
*/
Function Analisar()
local aButtons := {{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,"Confirmar"},{.t.,'Cancelar'},{.t.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.f.,nil}}

PosB19() // Posiciona no primeiro recno da B19 (usado como cabeçalho)
FwMsgRun( , {|| FWExecView(STR0003,'PLSP500NF', 4,,,,,aButtons )}, ,STR0005) //Analisar / Carregando informações

B19->(dbclosearea())
Return 

/*{Protheus.doc} Visualizar
    (long_description)
    @type  Static Function
    @author Thiago Rodrigues
    @since 12/05/2022
    @version version
*/
Function Visualizar()
local aButtons := {{.f.,Nil},{.f.,Nil},{.f.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,"Confirmar"},{.t.,'Cancelar'},{.t.,Nil},{.f.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.t.,Nil},{.f.,nil}}

PosB19() // Posiciona no primeiro recno da B19 (usado como cabeçalho)
FwMsgRun( , {|| FWExecView(STR0002,'PLSP500NF', 1,,,,,aButtons )}, ,STR0005)//Visualizar / Carregando informações

B19->(dbclosearea())
Return 


/*/{Protheus.doc} PosB19
    (Posiciona no primeiro recno da B19 (é o "cabeçalho"))
    @type  Static PosB19
    @author Thiago Rodrigues
    @since 13/05/2022
    @version version
    @see (links_or_references)
/*/
Static Function PosB19()
DbSelectArea( "B19" )
DbSetOrder( 4 )
B19->(DbSeek( cFilB19 + (cTempB19)->(B19_SEQIMP+B19_NRONFF+B19_OPEORI)))
Return 

/*/{Protheus.doc} PLVLDGLO
    Validação dos campos B19_VLRAPR e B19_VLTXAP 
    Conforme os valores recebidos nos campos de pagamento: (B19_VLRPGT e B19_VLTXPG) será calculado a glosa
    @type  Static Function
    @author Thiago Rodrigues
    @since 16/05/2022
    @version version
    @param  VlrApr,VlrPgt,TipVlr (Valor Apresentado, Valor Pago, taxa ou valor)
    @return .T. ou .F.
    @see (links_or_references)
/*/
Function PLVLDGLO(cTipVlr)
local lret      := .F.
local oView     := FWViewActive()
local cCampApr  := iif(cTipVlr =="1","B19_VLRAPR","B19_VLTXAP")
local oModel    := FWModelActive()
local oGridB19	:= oModel:getmodel("B19Detail")

nVlrApr := iif(cTipVlr =="1",oGridB19:GetValue("B19_VLRAPR"),oGridB19:GetValue("B19_VLTXAP"))
nVlrPgt := iif(cTipVlr =="1",oGridB19:GetValue("B19_VLRPGT"),oGridB19:GetValue("B19_VLTXPG"))

if empty(B19->B19_STATUS)
    if nVlrPgt < 0
        Help(nil, nil , STR0006, nil, STR0007, 1, 0, nil, nil, nil, nil, nil, {STR0014} ) //Atenção Valor informado para pagamento não pode ser negativo, Informe um numero positivo
    else 
        if nVlrPgt > nVlrApr 
            Help(nil, nil , STR0006, nil, STR0008 + cCampApr, 1, 0, nil, nil, nil, nil, nil, {STR0023} ) //Atenção O valor informado para pagamento não pode ser maior que o valor apresentado no campo: (B19_VLRAPR ou B19_VLTXAP)
        else
            oGridB19:loadvalue(iif(cCampApr =="B19_VLRAPR","B19_VLRGLO","B19_VLRGTX"),nVlrApr - nVlrPgt)
            oView:Refresh("B19Detail")
            lret := .t.
        endif
    endif
else 
    Help(nil, nil , STR0006, nil, STR0009, 1, 0, nil, nil, nil, nil, nil, {""} ) //Atenção esta nota já foi liberada para pagamento, não é possível realizar alterações
endif

Return lret

/*/{Protheus.doc} PlsLibPAg
    (Marca os itens como liberado para pagamento (B19_STATUS) 1 e cria o BGQ)
    @type   Function
    @author Thiago Rodrigues
    @since 18/05/2022
    @version version
/*/
Function PlsLibPAg()
local cChave := cFilB19+(cTempB19)->(B19_NRONFF+B19_OPEORI+B19_SEQIMP)

PosB19() // Posiciona no Primeiro RECNO deste lote na B19

if empty(cCodLanD) .or. empty(cCodLanC) //Caso não informado o tipo de lançamento Débito/Crédito não irá prosseguir
     Help(nil, nil , STR0006, nil, STR0016, 1, 0, nil, nil, nil, nil, nil, {""} )  //Não é possivel prosseguir com a liberação pois não foi informado o tipo de lançamento Débito/Crédito
    return
endif

If !B19->(eof()) .and. empty(B19->B19_STATUS)
    if PlItemGlo() //Verifica se tem itens com pagamento informado = 0 e glosa caso o cliente confirme
        if PlCriaBGQ() //Cria o BGQ
            while !B19->(eof()) .and. B19->(B19_FILIAL+B19_NRONFF+B19_OPEORI+B19_SEQIMP) = cChave 
                //Marca como liberado para pagamento  
                B19->(RecLock("B19",.F.))
                    B19->B19_STATUS:="1"
                B19->( MsUnLock() )
            
                B19->(DBSkip())
            end
            Help(nil, nil ,STR0006 , nil, STR0010+Alltrim((cTempB19)->(B19_NRONFF)) + STR0011, 1, 0, nil, nil, nil, nil, nil, {""} ) // Nota fiscal: NF liberada para pagamento

            (cTempB19)->(RecLock(cTempB19,.F.))//Atualiza a temporiaria para mudar a legenda no browse
            (cTempB19)->(B19_STATUS):="1"
            (cTempB19)->( MsUnLock() )
            oBrowse:Refresh(.T.)
        endif    
    endif    
else 
    Help(nil, nil , STR0006, nil, STR0010+Alltrim((cTempB19)->(B19_NRONFF))+STR0012, 1, 0, nil, nil, nil, nil, nil, {""} ) //Atenção Nota fiscal: NF  Já foi liberada para pagamento
endif

B19->(dbclosearea())
Return


/*/{Protheus.doc} PlItemGlo
    (Verifica itens que não foram informados valores de pagamento, pois serão considerados glosa)
    @type  Static Function
    @author Thiago Rodrgues
    @since 23/05/2022
/*/
Static Function PlItemGlo()
Local lRet   := .t.
local cSql := ""
local cChave := cFilB19+(cTempB19)->(B19_NRONFF+B19_OPEORI+B19_SEQIMP)
local aArea  := B19->(GetArea())
local aGlosa :={}

cSql = "SELECT 1 QTDE "
cSql += "from " + RetSqlName("B19") + " B19 "
cSql += "WHERE B19_FILIAL='" + cFilB19 + "' "
cSql += "AND B19_NRONFF =  '" + (cTempB19)->(B19_NRONFF) + "' "
cSql += "AND B19_OPEORI =  '" + (cTempB19)->(B19_OPEORI) + "' " 
cSql += "AND B19_SEQIMP =  '" + (cTempB19)->(B19_SEQIMP) + "' " 
cSql += "AND ((B19_VLRPGT = 0 AND  B19_VLRGLO = 0) OR (B19_VLTXPG=0 AND B19_VLRGTX=0)) " 
cSql += "AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,Changequery(cSql)),"TrbQTD",.F.,.T.)

//Se há itens com valores de pagamento e glosa zerados  so continua se o usuario confirmar.
if !TrbQTD->(eof())
    if MsgYesNo(STR0013, STR0006) //Os itens que não foram informados valores para pagamento serão considerados como glosa, deseja continuar?     
        aGlosa:= PlDlgGlo() //senão informar o motivo de glosa não continua
        if aGlosa[1] == .f. 
            lRet :=.f.
        else
            while !B19->(eof()) .and. B19->(B19_FILIAL+B19_NRONFF+B19_OPEORI+B19_SEQIMP) = cChave
                B19->(RecLock("B19",.F.))
                
                if B19->B19_VLRPGT == 0 
                    B19->B19_VLRGLO := B19->B19_VLRAPR //Adiciona o valor de glosa
                endif 

                if  B19->B19_VLTXPG == 0
                    B19->B19_VLRGTX := B19->B19_VLTXAP // Adiciona o valor de glosa da taxa
                endif    

                if (B19->B19_VLRGLO > 0 .or. B19->B19_VLRGTX > 0) .and. empty(B19->B19_CODGLO)
                    B19->B19_CODGLO := aGlosa[2] //Adiciona codigo da glosa
                endif

                B19->( MsUnLock() )
                B19->(DBSkip())
            end
        endif
    else 
        lRet :=.f.
    endif    
endif    
TrbQTD->(dbclosearea())

RestArea(aArea)
Return lRet


/*/{Protheus.doc} PlCriaBGQ
    (Gera um BGQ de credito
    e também um de Debito para utilização na exportação do A550)
    @type  Static Function
    @author Thiago Rodrigues
    @since 24/05/2022
/*/
Static Function PlCriaBGQ()
local oModel as object
local aCodLan :={cCodLanC,cCodLanD} //Codigo de lançamento: [1]Crédito/[2]Debito
local cAno    := cValToChar(YEAR(Date()))
local cMes    := Strzero(MONTH(Date()),2)
local nI      :=1
local lOk     :=.T.
local cCodrda := PlRetRda()
local aValor  := PlRetVlr()
local aArea   := B19->(GetArea())
local cLog    := ""

Begin Transaction

for nI:=1 to len(aCodLan)

//Caso valor esteja zero não vai criar o BGQ
if aValor[nI] ==0 
    exit
endif

oModel := FWLoadModel( 'PLSA755' ) 
oModel:SetOperation( 3 )
oModel:Activate()

oModel:getModel("BGQMASTER"):setValue("BGQ_CODIGO", cCodrda)
oModel:getModel("BGQMASTER"):setValue("BGQ_ANO   ", cAno)
oModel:getModel("BGQMASTER"):setValue("BGQ_MES   ", cMes)
oModel:getModel("BGQMASTER"):setValue("BGQ_CODLAN", aCodLan[nI]) //Codigo de lançamento: [1]Crédito/[2]Debito
oModel:getModel("BGQMASTER"):setValue("BGQ_SEQIMP", B19->B19_SEQIMP)
oModel:getModel("BGQMASTER"):setValue("BGQ_VALOR ",aValor[nI]) // Valor  [1]Credito/[2]Debito
oModel:getModel("BGQMASTER"):setValue("BGQ_LANAUT ","1")


if oModel:vldData()
    oModel:CommitData()
    lOk := .T.
else
    lOk := .F.
	cLog += cValToChar(oModel:GetErrorMessage()[6])             
    Help(nil, nil , STR0006, nil,STR0017+cLog, 1, 0, nil, nil, nil, nil, nil, {""} )//Houve um erro na geração: Erro
    disarmTransaction()
endif

Next nI

end transaction 
RestArea(aArea)
Return lOk


/*/{Protheus.doc} PlRetRda
    (Retorna Rda da Operadora de intercambio)
    @type  Static Function
    @author Thiago Rodrigues
    @since 25/05/2022
    @version version
/*/
Static Function PlRetRda()
local cSql := ""

cSql = "SELECT BAU_CODIGO "
cSql += "from " + RetSqlName("BRJ") + " BRJ "
cSql += "JOIN BAUT10 BAU "
cSql += "ON	BRJ.BRJ_FILIAL = BAU.BAU_FILIAL "
cSql += "AND BRJ.BRJ_OPEORI = BAU.BAU_CODOPE "
cSql += "AND BAU.D_E_L_E_T_ =' ' " 
cSql += "WHERE BRJ_CODIGO =  '" + SubStr((cTempB19)->(B19_SEQIMP), 4, 12) + "' " 
cSql += "AND BRJ.D_E_L_E_T_=' '" 

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,Changequery(cSql)),"TrbBAU",.F.,.T.)
if !TrbBAU->(eof())
    cCodrda := TrbBAU->BAU_CODIGO
endif

TrbBAU->(dbclosearea())
Return cCodrda

/*/{Protheus.doc} PlRetVlr
    (Retorna soma dos valores para criar o titulo de débito e credito)
    @type  Static Function
    @author Thiago Rodrigues
    @since 25/05/2022
/*/
Static Function PlRetVlr()
local cSql := ""
local aVlr := {}

//Valores
cSql = "SELECT SUM(B19_VLRPGT) + SUM(B19_VLTXPG) TotalPAgo, sum(B19_VLRGLO)+Sum(B19_VLRGTX) TotalGlosa "
cSql += "from " + RetSqlName("B19") + " B19 "
cSql += "WHERE B19_FILIAL='" + cFilB19 + "' "
cSql += "AND B19_NRONFF =  '" + (cTempB19)->(B19_NRONFF) + "' "
cSql += "AND B19_OPEORI =  '" + (cTempB19)->(B19_OPEORI) + "' " 
cSql += "AND B19_SEQIMP =  '" + (cTempB19)->(B19_SEQIMP) + "' " 
cSql += "AND D_E_L_E_T_ = ' ' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,Changequery(cSql)),"TrbVlr",.F.,.T.)

if!TrbVlr->(eof())
    aadd(aVlr,TrbVlr->TotalPAgo)//Credito para o prestador
    aadd(aVlr,TrbVlr->TotalGlosa)//Debito para  o prestador
endif

TrbVlr->(dbclosearea())
Return aVlr

/*/{Protheus.doc} PLWhenGlo()
    (when do campo B19_CODGLO)
    @type  Function
    @author Thiago R
    @since 30/05/2022
    @version version
    @see (links_or_references)
    /*/
Static Function PLWhenGlo()
local lRet :=.f.
local oModel    := FWModelActive()
local oGridB19	:= oModel:getmodel("B19Detail")

if (( !empty(oGridB19:getValue("B19_VLRGLO")) .or. !empty(oGridB19:getValue("B19_VLRGTX"))) .AND. B19->B19_STATUS=' ' )
    lRet:=.t.
endif

Return lRet

/*/{Protheus.doc} PlDlgGlo
    (Cria tela para usuario informar o motivo da glosa)
    @type  Static Function
    @author Thiago
    @since 30/05/2022
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function PlDlgGlo()
local ndLinIni	:= 100
local ndColIni 	:= 100
local ndLinFin	:= 250
local ndColFin	:= 400

local nLinS		:= 5
local nLinG		:= 10
local nColS		:= 0
local nColG		:= 0
local cCodGlo   := Space( 3 )
Local oGlo	    := Nil
local nposBTI   :=54.8
local nposBTF   :=30
local nOpca     := 0
local aRet      := {.F.,""}

local ntexLarg  :=200
local nTexAlt   :=30
local nTextSize :=100
local nTextSiz2 :=100

DEFINE MSDIALOG oDlg FROM ndLinIni,ndColIni TO ndLinFin,ndColFin PIXEL TITLE "Motivo da Glosa" //"Contabilização Off-line de Despesa"

@ (02,02),(ntexLarg,nTexAlt)  SAY "O motivo de glosa selecionado será enviado no arquivo de contestação A550" SIZE nTextSize,nTextSiz2 OF oDlg PIXEL COLOR CLR_BLUE
@ (nLinS += 15), (nColS += 30) SAY OEMTOANSI("Informe o código da Glosa:") PIXEL of oDlg //'Operadora.'
@ (nLinG += 19), (nColG += 30) MSGet oGlo VAR cCodGlo SIZE 30,10 OF oDlg PIXEL  PICTURE "@!" F3 "BCTPLS" 

DEFINE SBUTTON FROM nposBTI,nposBTF TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
DEFINE SBUTTON FROM nposBTI,nposBTF+30 TYPE 2 ACTION oDlg:End() ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTERED 

if nOpca == 1 .and. !empty(cCodGlo)
    aRet := {.T.,cCodGlo}
else 
    Help(nil, nil , STR0006, nil,STR0021, 1, 0, nil, nil, nil, nil, nil, {""} )
endif

Return aRet

/*/{Protheus.doc} PLSCADOK
    @type  Static Function
    @author Thiago Rodrigues
    @since 31/05/2022
    @version version
/*/
Static Function PLSCADOK(oModel)
Local lRet		:= .T.
Local oGrid     := oModel:getmodel("B19Detail")
local nfor    := 1
local nTamGrid  := oGrid:length()

for nfor := 1 To nTamGrid
    oGrid:GoLine(nfor)
    if empty(oGrid:Getvalue("B19_CODGLO")) .and.  (!empty(oGrid:getValue("B19_VLRGLO")) .or. !empty(oGrid:getValue("B19_VLRGTX")))
        lRet:=.f.
        Help(nil, nil , STR0006, nil,STR0022+ cValtochar(nfor), 1, 0, nil, nil, nil, nil, nil, {""} )
        oGrid:GoLine(nfor)  
        exit
    endif
next nfor
Return lRet
