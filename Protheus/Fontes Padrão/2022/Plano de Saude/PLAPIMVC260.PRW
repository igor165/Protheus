#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"
  
PUBLISH  MODEL REST NAME PLAPIMVC260 RESOURCE OBJECT oRestMvc260
  
Class oRestMvc260 From FwRestModel
    Data lBA1Closed
   	Data qryOrder  AS STRING
	Data searchKey AS STRING
	Data exists    as STRING
	Data pkAssJur  as STRING
 
    Method Activate()
   
EndClass
 
Method Activate() Class oRestMvc260
    self:lBA1Closed := .F.
Return _Super:Activate()
 
// MODELO DE DADOS 
Static Function Modeldef()
Local oStruBA1 := DefStrModel()

    oModel := FWFormModel():New( 'BENEFICIARIOS', {|| }, {|| }, {|| }, {|| } )
    oModel:AddFields( 'BA1MASTER', , oStruBA1, {|| }, {|| },{|oM| MyLoad() })
    oModel:SetDescription( "Beneficiarios" )
    oModel:GetModel( 'BA1MASTER' ):SetDescription( "Beneficiarios" )
    oModel:SetPrimaryKey( {"BA1_CPFUSR"} )

Return oModel
  
Static Function DefStrModel()
Local oStruct  := FWFormModelStruct():New()
Local bValid   := { || .T.}
Local bWhen    := { || }
Local bRelac   := { || }
     
    // TABELA
    oStruct:AddTable( "BA1", {}, "Filiais", {|| })                
        
    // INDICES
    oStruct:AddIndex(1, "1", "BA1_CPFUSR", "CPF", "", "", .T.)
    
    // CAMPOS
    oStruct:AddField( "Operadora   "  , "Operadora   "   , "BA1_CODINT" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )                              
    oStruct:AddField( "Cód. Empresa"  , "Cód. Empresa"   , "BA1_CODEMP" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "Matrícula   "  , "Matrícula   "   , "BA1_MATRIC" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "Tp. Registro"  , "Tp. Registro"   , "BA1_TIPREG" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "Dígito"        , "Dígito"         , "BA1_DIGITO" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "CPF"           , "CPF"            , "BA1_CPFUSR" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "Nome Usuário"  , "Nome Usuário"   , "BA1_NOMUSR" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "Dt. Nascto."   , "Dt. Nascto."    , "BA1_DATNAS" , "D", 08, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "Filial"        , "Filial"         , "BA1_FILIAL" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , ) 
    oStruct:AddField( "Dt. Inclusão"  , "Dt. Inclusão"   , "BA1_DATINC" , "D", 08, 0, bValid, bWhen, , , bRelac, .F., , , ) 
    oStruct:AddField( "Recém-Nascid"  , "Recém-Nascid"   , "BA1_RECNAS" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , ) 
    oStruct:AddField( "Dt. Carência"  , "Dt. Carência"   , "BA1_DATCAR" , "D", 08, 0, bValid, bWhen, , , bRelac, .F., , , ) 
    oStruct:AddField( "Data Bloq.  "  , "Data Bloq.  "   , "BA1_DATBLO" , "D", 08, 0, bValid, bWhen, , , bRelac, .F., , , ) 
    oStruct:AddField( "Grau Parent."  , "Grau Parent."   , "BA1_GRAUPA" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , ) 
    oStruct:AddField( "Tp. Usuário "  , "Tp. Usuário "   , "BA1_TIPUSU" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., ,.T. , ) 
    oStruct:AddField( "Estado Civil"  , "Estado Civil"   , "BA1_ESTCIV" , "C", 50, 0, bValid, bWhen, , , { || Posicione("SX5",1,xFilial("SX5")+"33"+BA1->BA1_ESTCIV,"X5_DESCRI") }, .F., ,.T. , ) 
    oStruct:AddField( "Dt Casamento"  , "Dt Casamento"   , "BA1_DATCAS" , "D", 08, 0, bValid, bWhen, , , bRelac, .F., , , ) 

    oStruct:AddField( "Codigo      "  , "Codigo      "   , "BI3_CODIGO" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , ) 
    oStruct:AddField( "Produto     "  , "Produto     "   , "BI3_DESCRI" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , ) 
    oStruct:AddField( "Cód.Plano   "  , "Cód.Plano   "   , "BA3_CODPLA" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , ) 
    oStruct:AddField( "Versão      "  , "Versão      "   , "BA3_VERSAO" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , ) 
    oStruct:AddField( "Forma Cobran"  , "Forma Cobran"   , "BA3_FORPAG" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , ) 
    oStruct:AddField( "Cód. Empresa"  , "Cód. Empresa"   , "BA3_CODEMP" , "C", 50, 0, bValid, bWhen, , , bRelac, .F., , , )
    oStruct:AddField( "Descricão   "  , "Descricão   "   , "BA3_DESFOR" , "C", 50, 0, bValid, bWhen, , , { || Posicione("BJ1",1,xFilial("BJ1")+BA3->BA3_FORPAG,"BJ1_DESCRI")}, .F., , , ) 
    
Return oStruct
 
Static Function MyLoad()
Local aRet := {}

    DbSelectArea("BA3")
    BA3->(DbSetOrder(1))
    If BA3->(dBseek(xFilial("BA3")+BA1->BA1_CODINT+BA1->BA1_CODEMP+BA1->BA1_MATRIC))
        If BI3->(dBseek(xFilial("BI3")+BA3->BA3_CODPLA+BA3->BA3_VERSAO))
            DbSelectArea("BI3")
            BI3->(DbSetOrder(1))
            aRet := {{BA1->BA1_CODINT, BA1->BA1_CODEMP, BA1->BA1_MATRIC, BA1->BA1_TIPREG, BA1->BA1_DIGITO, BA1->BA1_CPFUSR, BA1->BA1_NOMUSR, BA1->BA1_DATNAS,;
                    BA1->BA1_FILIAL, BA1->BA1_DATINC, BA1->BA1_RECNAS, BA1->BA1_DATCAR, Dtoc(BA1->BA1_DATBLO), BA1->BA1_GRAUPA,BA1->BA1_TIPUSU, Posicione("SX5",1,xFilial("SX5")+"33"+BA1->BA1_ESTCIV,"X5_DESCRI") ,dtoc(BA1->BA1_DATCAS),;
                    BI3->BI3_CODIGO,BI3->BI3_DESCRI,BA3->BA3_CODPLA,BA3->BA3_VERSAO,;
                    BA3->BA3_FORPAG, BA3->BA3_CODEMP,Posicione("BJ1",1,xFilial("BJ1")+BA3->BA3_FORPAG,"BJ1_DESCRI")}, BA1->(Recno())}
        Endif
    Endif    

Return aRet