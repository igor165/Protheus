#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICDU100.CH"
#INCLUDE "AVERAGE.CH"

#define MYCSS "QTableView { selection-background-color: #1C9DBD; }"
#define DUIMP "2"
#define DUIMP_INTEGRADA "1"

// define EV1_STATUS
#define PENDENTE_INTEGRACAO        "1"
#define PROCESSO_PENDENTE_REVISAO  "2"
#define PENDENTE_REGISTRO          "3"
#define DUIMP_REGISTRADA           "4"
#define OBSOLETO                   "5"

static _nRecEV1  := 0
static _DIC_22_4 := nil

/*
Programa        : EICDU100.PRW
Objetivo        : Manutenção do cadastro de Integração DUIMP
Autor           : Maurício Frison
Data/Hora       : 26/01/2022
Obs. 
*/
Function EICDU100()
Local aArea         := GetArea()
Private lInclui :=.F.
Private oBufSeqEV1 := tHashMap():New()

oBrowse := FWMBrowse():New() //Instanciando a Classe
oBrowse:SetAlias("EV1") //Informando o Alias
oBrowse:SetMenuDef("EICDU100") //Nome do fonte do MenuDef
oBrowse:SetDescription(STR0001) //"Integração DUIMP"

oBrowse:SetUseFilter()
oBrowse:DisableDetails( )
oBrowse:AddFilter("Filtrar" , "EV1->EV1_TIPREG == '2'", .T., .T.)

oBrowse:AddLegend( "EV1_STATUS == '1' .or. empty(EV1_STATUS)", "BR_AZUL"      , STR0055) // "Pendente de Integração"
oBrowse:AddLegend( "EV1_STATUS == '2'"                       , "BR_AMARELO"   , STR0056) // "Processo Pendente de Revisão"
oBrowse:AddLegend( "EV1_STATUS == '3'"                       , "BR_VERMELHO"  , STR0057) // "Pendente de Registro"
oBrowse:AddLegend( "EV1_STATUS == '4'"                       , "BR_VERDE"     , STR0058) // "Duimp Registrada"
oBrowse:AddLegend( "EV1_STATUS == '5'"                       , "BR_CINZA"     , STR0059) // "Obsoleto"

oBrowse:SetOnlyFields( { 'EV1_STATUS', 'EV1_LOTE', 'EV1_SEQUEN', 'EV1_HAWB', 'EV1_USRGER','EV1_DATGER', 'EV1_HORGER' } ) 

oBrowse:Activate()

RestArea(aArea)

Return      

/*
Funcao      : MenuDef
Parametros  : Nenhum
Retorno     : 
Objetivos   : Efetuar manutenção no cadastro 
Autor       : Maurício Frison
Data/Hora   : 26/01/2022
Revisão     : 
Obs         : 
*/
*-----------------------
Static Function MenuDef()
*-----------------------
Local aRotina := {}
//Adiciona os botões na MBROWSE
ADD OPTION aRotina TITLE STR0002 ACTION "AxPesqui"         OPERATION 1 ACCESS 0 // "Pesquisar"
ADD OPTION aRotina TITLE STR0003 ACTION "VIEWDEF.EICDU100" OPERATION 2 ACCESS 0 // "Visualizar"
ADD OPTION aRotina TITLE STR0004 ACTION "VIEWDEF.EICDU100" OPERATION 3 ACCESS 0 // "Incluir"
ADD OPTION aRotina TITLE STR0062 ACTION "DU101PrcInt"      OPERATION 4 ACCESS 0 // "Integrar"
ADD OPTION aRotina TITLE STR0005 ACTION "DU100Manut"       OPERATION 5 ACCESS 0 // "Excluir"
ADD OPTION aRotina TITLE STR0090 ACTION "DU101PrcInt"      OPERATION 6 ACCESS 0 // "Registrar"
ADD OPTION aRotina TITLE STR0061 ACTION "EICDULegen"       OPERATION 7 ACCESS 0 // "Legenda"

Return aRotina  

/*
Função     : DU100Manut
Objetivo   : Função para manutenção do modelo EICDU100
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
function DU100Manut(cAlias, nRecno, nOpc)
   local cTitulo := ""

   default cAlias     := "EV1"
   default nRecno     := 0
   default nOpc       := 0

   if nOpc == MODEL_OPERATION_DELETE .and. EV1->(!eof()) .and. EV1->(!bof())
      cTitulo := STR0001 + " - " + STR0005 // "Integração DUIMP" ### "Excluir"
      if EV1->EV1_STATUS == DUIMP_REGISTRADA .or. EV1->EV1_STATUS == OBSOLETO
         EasyHelp(  StrTran( STR0088, "####", if( EV1->EV1_STATUS == DUIMP_REGISTRADA, STR0058 , STR0059 ) )  , STR0014 , "") // "O status deste processo é de '####'. Não é possível prosseguir com a ação de exclusão do registro." ### "Atenção" ### "Duimp Registrada" #### "Obsoleto"
      else
         if MsgYesNo(STR0089 , STR0014 ) // "Caso o registro tenha histórico de integração com o Portal Único, esta operação o tornará Obsoleto. Deseja prosseguir com esta operação?" ### "Atenção"
            FWExecView(cTitulo,'EICDU100', MODEL_OPERATION_DELETE,, { || .T. }  )
         endif
      endif

   endif

return .T.

/*
Função     : EICDULegen
Objetivo   : Opção de Legenda
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
function EICDULegen()
   local aCores := {}
 
   aCores := { { "BR_AZUL"      , STR0055},; // "Pendente de Integração"
               { "BR_AMARELO"   , STR0056},; // "Processo Pendente de Revisão"
               { "BR_VERMELHO"  , STR0057},; // "Pendente de Registro"
               { "BR_VERDE"     , STR0058},; // "Duimp Registrada"
               { "BR_CINZA"     , STR0059}}  // "Obsoleto"

   BrwLegenda(STR0001,STR0061,aCores)

return .T.

*-------------------------*
Static Function ModelDef()
*-------------------------*
   local oModel     := nil
   local bCancel    := {|oModel| DU100VdCan(oModel)}
   local bPostVld   := { |oModel| DU100PVldModel(oModel) }
   local bCommit    := { |oModel| DU100Commit(oModel) }

   // Define o modelo principal da rotina
   oModel := MPFormModel():New( 'EICDU100', /*bPreValidacao*/, bPostVld, bCommit, bCancel )
   oModel:SetDescription(STR0001)//"Integração DUIMP"

   // Capa da rotina
   setMdlEV1(oModel)
   setMdlEV9(oModel)
   setMdlEVB(oModel)

   // Itens da rotina
   setMdlSWV(oModel)
   setMdlEV2MC(oModel)
   setMdlEV2FF(oModel)
   setMdlEV2CV(oModel)
   if DUIMP2310()
      setMdlEV2TR(oModel)
   endif
   setMdlEV3(oModel)
   setMdlEV4(oModel)
   setMdlEVE(oModel)
   setMdlEVI(oModel)
   setMdlEV6(oModel)

Return oModel

/*
Função     : setMdlEV1
Objetivo   : Define o modelo para Cadastrais (EV1)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV1(oModel)
   local oStruEV1   := nil

   oStruEV1 := FWFormStruct( 1, "EV1", {|x| CheckField(x, EasyStrSplit(DU100Model("EV1"), "|")) })

   oStruEV1:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )
   oStruEV1:SetProperty('EV1_LOTE',MODEL_FIELD_OBRIGAT, .T. )
   oStruEV1:SetProperty('EV1_HAWB',MODEL_FIELD_OBRIGAT, .T. )
   oStruEV1:SetProperty('EV1_SEQUEN',MODEL_FIELD_OBRIGAT, .T. )

   //STRUCT_FEATURE_WHEN
   oStruEV1:SetProperty('*'         , MODEL_FIELD_WHEN , {|| .F. }) //Monta When diferente do dicionário   
   oStruEV1:SetProperty('EV1_HAWB'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'DU100WHEN("EV1_HAWB")'    )) //Monta When diferente do dicionário
  
   //STRUCT_FEATURE_VALID
   oStruEV1:SetProperty('EV1_HAWB'  , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'DU100VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV1:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  

   //                    N A O    A L T E R A R    A    O R D E M   D O S    G A T I L H O S
   //
   //Alguns gatilhos utilizam o registro já posicionado no gatilho anterior
   //
   //TRIGGER
   oStruEV1:AddTrigger("EV1_HAWB"  , "EV1_TIPREG",, {|oModel| DU100GATIL("EV1_TIPREG")} )
   oStruEV1:AddTrigger("EV1_HAWB"  , "EV1_SEQUEN",, {|oModel| DU100GATIL("EV1_SEQUEN")} )
   oStruEV1:AddTrigger("EV1_HAWB"  , "EV1_IMPNOM",, {|oModel| DU100GATIL("EV1_IMPNOM")} )      
   oStruEV1:AddTrigger("EV1_HAWB"  , "EV1_IMPNRO",, {|oModel| DU100GATIL("EV1_IMPNRO")} )         
   oStruEV1:AddTrigger("EV1_HAWB"  , "EV1_INFCOM",, {|oModel| DU100GATIL("EV1_INFCOM")} )      
   oStruEV1:AddTrigger("EV1_HAWB" , "EV1_COIDM",,  {|oModel| DU100GATIL("EV1_COIDM")} )      
   oStruEV1:AddTrigger("EV1_HAWB" , "EV1_URFDES",, {|oModel| DU100GATIL("EV1_URFDES")} )      
   oStruEV1:AddTrigger("EV1_HAWB" , "EV1_SEGMOE",, {|oModel| DU100GATIL("EV1_SEGMOE")} )      
   oStruEV1:AddTrigger("EV1_HAWB" , "EV1_SETOMO",, {|oModel| DU100GATIL("EV1_SETOMO")} )       
   oStruEV1:AddTrigger("EV1_HAWB" , "EV1_HAWB",, {|oModel| DU100GATIL("EVB_CODPV")} )
   oStruEV1:AddTrigger("EV1_HAWB" , "EV1_HAWB",, {|oModel| DU100GATIL("EV9_DETAIL")} )
   oStruEV1:AddTrigger("EV1_HAWB" , "EV1_HAWB",, {|oModel| DU100GATIL("SWV_DETAIL")} )   

   //STRUCT_FEATURE_INIPAD 
   oStruEV1:SetProperty('EV1_LOTE'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD,'DU100EV1LO(b,a,c)'         ))  //Monta Inicializador Padrão diferente do dicionário   

   oModel:AddFields( 'EV1MASTER',/*nOwner*/, oStruEV1, /*bPreValidacao*/, /*bPosValidacao*/,/*bCarga*/)
   oModel:SetPrimaryKey({'EV1_FILIAL','EV1_HAWB','EV1_LOTE'})

return nil

/*
Função     : setMdlEV9
Objetivo   : Define o modelo para Documentos de Instrução (EV9)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV9(oModel)
   local oStruEV9   := nil

   oStruEV9 := FWFormStruct( 1, "EV9", {|x| CheckField(x, EasyStrSplit(DU100Model("EV9"), "|")) })

   oStruEV9:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )

   oModel:AddGrid('EV9DETAIL', 'EV1MASTER', oStruEV9)

   oModel:GetModel("EV9DETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EV9DETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EV9DETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EV9DETAIL"):SetOptional( .T. )

   oModel:GetModel("EV9DETAIL"):SetUniqueLine({"EV9_FILIAL" ,"EV9_HAWB" ,"EV9_LOTE","EV9_CODIN", "EV9_SEQUEN"} )

   oModel:SetRelation('EV9DETAIL', {{ 'EV9_FILIAL', 'xFilial("EV9")'},;
      { 'EV9_HAWB'  , 'EV1_HAWB'       },;
      { 'EV9_LOTE'  , 'EV1_LOTE'       }},;
       EV9->(IndexKey(1)) )

return

/*
Função     : setMdlEVB
Objetivo   : Define o modelo para Processos Vinculados (EVB)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEVB(oModel)
   local oStruEVB   := nil

   oStruEVB := FWFormStruct( 1, "EVB", {|x| CheckField(x, EasyStrSplit(DU100Model("EVB"), "|")) })

   oStruEVB:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )

   oModel:AddGrid('EVBDETAIL', 'EV1MASTER', oStruEVB)
   oModel:GetModel("EVBDETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EVBDETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EVBDETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EVBDETAIL"):SetOptional( .T. )

   oModel:GetModel("EVBDETAIL"):SetUniqueLine({"EVB_FILIAL" ,"EVB_HAWB" ,"EVB_LOTE","EVB_CODPV"} )

   oModel:SetRelation('EVBDETAIL', {   { 'EVB_FILIAL'   ,'xFilial("EVB")'},;
      { 'EVB_HAWB'     ,'EV1_HAWB'       },;
      { 'EVB_LOTE'     ,'EV1_LOTE'         }},; 
      EVB->(IndexKey(1)) )

return nil

/*
Função     : setMdlSWV
Objetivo   : Define o modelo para Dados do item da duimp (SWV)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlSWV(oModel)
   local oStruSWV := FWFormStruct( 1, "SWV", {|x| CheckField(x, EasyStrSplit(DU100Model("SWV"), "|")) })

   oStruSWV:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )

   oModel:AddGrid('SWVDETAIL', 'EV1MASTER', oStruSWV)
   oModel:GetModel("SWVDETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("SWVDETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("SWVDETAIL"):SetOnlyQuery(.T.) //Retira o modelo do commit
   //oModel:GetModel("EVBDETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("SWVDETAIL"):SetOptional( .F. )

   oModel:SetRelation('SWVDETAIL', {   { 'WV_FILIAL'   ,'xFilial("SWV")'},;
                                       { 'WV_HAWB'     ,'EV1_HAWB'      }},;                                       
   SWV->(IndexKey(1)) )

return nil

/*
Função     : setMdlEV2MC
Objetivo   : Define o modelo para Mercadorias (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV2MC(oModel)
   local oStruEV2   := FWFormStruct( 1, "EV2", {|x| CheckField(x, EasyStrSplit(DU100Model("EV2_MERCADORIA"), "|")) })   
   local bLoadEV2MC := {|oModel| DU100EV2Load( oModel) }
   oStruEV2:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEV2:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV2:SetProperty('*', MODEL_FIELD_NOUPD, .F.)   
    
   oModel:AddFields( 'EV2MSTR_MC', 'SWVDETAIL', oStruEV2, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2MC)
   
   oModel:SetRelation('EV2MSTR_MC', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

return nil

/*
Função     : setMdlEV2FF
Objetivo   : Define o modelo para Fabricante / Fornecedor (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV2FF(oModel)
   local oStruEV2   := nil
   local bLoadEV2FF := {|oModel| DU100EV2Load( oModel) }
   oStruEV2 := FWFormStruct( 1, "EV2", {|x| CheckField(x, EasyStrSplit(DU100Model("EV2_FABR_FORN"), "|")) })

   oStruEV2:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEV2:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV2:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddFields( 'EV2MSTR_FF', 'SWVDETAIL', oStruEV2, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2FF)
   oModel:GetModel("EV2MSTR_FF"):SetOnlyQuery(.T.) //Retira o modelo do commit
   oModel:SetRelation('EV2MSTR_FF', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

return nil

/*
Função     : setMdlEV2CV
Objetivo   : Define o modelo para Condição de Venda / Cambiais (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV2CV(oModel)
   local oStruEV2   := nil
   local bLoadEV2CV := {|oModel| DU100EV2Load( oModel) }
   oStruEV2 := FWFormStruct( 1, "EV2", {|x| CheckField(x, EasyStrSplit(DU100Model("EV2_COND_VENDA"), "|")) })

   oStruEV2:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEV2:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV2:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddFields( 'EV2MSTR_CV', 'SWVDETAIL', oStruEV2, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
   oModel:GetModel("EV2MSTR_CV"):SetOnlyQuery(.T.) //Retira o modelo do commit
   oModel:SetRelation('EV2MSTR_CV', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

return nil

/*
Função     : setMdlEV2TR
Objetivo   : Define o modelo para Tributos (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV2TR(oModel)
   local oStrII     := nil
   local oStrIPI    := nil
   local oStrPISCOF := nil
   local oStrInteg  := nil
   local bLoadEV2CV := {|oModel| DU100EV2Load( oModel ) }

   oStrII := FWFormStruct( 1, "EV2", {|x| CheckField(x, EasyStrSplit(DU100Model("EV2_TRIBUTOS_II"), "|")) })
   oStrII:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
   oStrII:SetProperty('*', MODEL_FIELD_WHEN , {|| .F. })
   oStrII:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddFields( 'EV2MSTR_TRIB_II', 'SWVDETAIL', oStrII, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
   oModel:GetModel("EV2MSTR_TRIB_II"):SetOnlyQuery(.T.) //Retira o modelo do commit
   oModel:SetRelation('EV2MSTR_TRIB_II', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

   oStrIPI := FWFormStruct( 1, "EV2", {|x| CheckField(x, EasyStrSplit(DU100Model("EV2_TRIBUTOS_IPI"), "|")) })
   oStrIPI:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
   oStrIPI:SetProperty('*', MODEL_FIELD_WHEN , {|| .F. })
   oStrIPI:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddFields( 'EV2MSTR_TRIB_IPI', 'SWVDETAIL', oStrIPI, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
   oModel:GetModel("EV2MSTR_TRIB_IPI"):SetOnlyQuery(.T.) //Retira o modelo do commit
   oModel:SetRelation('EV2MSTR_TRIB_IPI', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

   oStrPISCOF := FWFormStruct( 1, "EV2", {|x| CheckField(x, EasyStrSplit(DU100Model("EV2_TRIBUTOS_PISCOFINS"), "|")) })
   oStrPISCOF:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
   oStrPISCOF:SetProperty('*', MODEL_FIELD_WHEN , {|| .F. })
   oStrPISCOF:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddFields( 'EV2MSTR_TRIB_PISCOFINS', 'SWVDETAIL', oStrPISCOF, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
   oModel:GetModel("EV2MSTR_TRIB_PISCOFINS"):SetOnlyQuery(.T.) //Retira o modelo do commit
   oModel:SetRelation('EV2MSTR_TRIB_PISCOFINS', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

   oStrInteg := FWFormStruct( 1, "EV2", {|x| CheckField(x, EasyStrSplit(DU100Model("EV2_TRIBUTACAO"), "|")) })
   oStrInteg:SetProperty('*', MODEL_FIELD_OBRIGAT, .F. )
   oStrInteg:SetProperty('*', MODEL_FIELD_WHEN , {|| .F. })
   oStrInteg:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddFields( 'EV2MSTR_TRIB_OBS', 'SWVDETAIL', oStrInteg, /*bPreValidacao*/, /*bPosValidacao*/,bLoadEV2CV)
   oModel:GetModel("EV2MSTR_TRIB_OBS"):SetOnlyQuery(.T.) //Retira o modelo do commit
   oModel:SetRelation('EV2MSTR_TRIB_OBS', { ;
      { 'EV2_FILIAL'   ,'xFilial("EV2")'},;
      { 'EV2_LOTE'     ,'EV1_LOTE'      },;
      { 'EV2_HAWB'     ,'WV_HAWB'       },;
      { 'EV2_SEQDUI'   ,'WV_SEQDUIM'    };
      },; 
      EV2->(dbSetOrder(3)) ) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI

return nil

/*
Função     : setMdlEV3
Objetivo   : Define o modelo para Acréscimos (EV3)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV3(oModel)
   local oStruEV3   := nil

   oStruEV3 := FWFormStruct( 1, "EV3", {|x| CheckField(x, EasyStrSplit(DU100Model("EV3"), "|")) })

   oStruEV3:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEV3:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV3:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddGrid('EV3DETAIL', 'EV2MSTR_MC', oStruEV3)

   oModel:GetModel("EV3DETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EV3DETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EV3DETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EV3DETAIL"):SetOptional( .T. )
   oModel:GetModel("EV3DETAIL"):SetUniqueLine({"EV3_FILIAL","EV3_LOTE","EV3_HAWB","EV3_SEQDUI","EV3_ACRES"} )

   oModel:SetRelation('EV3DETAIL', {;
      { 'EV3_FILIAL'   ,'xFilial("EV3")'},;
      { 'EV3_LOTE'     ,'EV2_LOTE'      },;
      { 'EV3_HAWB'     ,'EV2_HAWB'      },;
      { 'EV3_SEQDUI'   ,'EV2_SEQDUI'    };
      },; 
      EV3->(dbSetOrder(3)) ) // EV3_FILIAL+EV3_LOTE+EV3_HAWB+EV3_SEQDUI

return nil

/*
Função     : setMdlEV4
Objetivo   : Define o modelo para Deduções (EV4)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV4(oModel)
   local oStruEV4   := nil

   oStruEV4 := FWFormStruct( 1, "EV4", {|x| CheckField(x, EasyStrSplit(DU100Model("EV4"), "|")) })

   oStruEV4:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEV4:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV4:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  

   oModel:AddGrid('EV4DETAIL', 'EV2MSTR_MC', oStruEV4)

   oModel:GetModel("EV4DETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EV4DETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EV4DETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EV4DETAIL"):SetOptional( .T. )
   oModel:GetModel("EV4DETAIL"):SetUniqueLine({"EV4_FILIAL","EV4_LOTE","EV4_HAWB","EV4_SEQDUI","EV4_DEDU"} )

   oModel:SetRelation('EV4DETAIL', {;
      { 'EV4_FILIAL'   ,'xFilial("EV4")'},;
      { 'EV4_LOTE'     ,'EV2_LOTE'      },;
      { 'EV4_HAWB'     ,'EV2_HAWB'      },;
      { 'EV4_SEQDUI'   ,'EV2_SEQDUI'    };
      },; 
      EV4->(dbSetOrder(3)) ) // EV4_FILIAL+EV4_LOTE+EV4_HAWB+EV4_SEQDUI

return nil

/*
Função     : setMdlEVE
Objetivo   : Define o modelo para LPCO's (EVE)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEVE(oModel)
   local oStruEVE   := nil

   oStruEVE := FWFormStruct( 1, "EVE", {|x| CheckField(x, EasyStrSplit(DU100Model("EVE"), "|")) })

   oStruEVE:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEVE:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEVE:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  
 
   oModel:AddGrid('EVEDETAIL', 'EV2MSTR_MC', oStruEVE)

   oModel:GetModel("EVEDETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EVEDETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EVEDETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EVEDETAIL"):SetOptional( .T. )

   oModel:GetModel("EVEDETAIL"):SetUniqueLine({"EVE_FILIAL","EVE_LOTE","EVE_SEQDUI","EVE_LPCO"} )

   oModel:SetRelation('EVEDETAIL', {;
      { 'EVE_FILIAL'   ,'xFilial("EVE")'},;
      { 'EVE_LOTE'     ,'EV2_LOTE'      },;
      { 'EVE_SEQDUI'   ,'EV2_SEQDUI'    };
      },; 
      EVE->(dbSetOrder(2)) ) // EVE_FILIAL+EVE_LOTE+EVE_SEQDUI

return nil

/*
Função     : setMdlEVI
Objetivo   : Define o modelo para Certificado Mercosul (EVI)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEVI(oModel)
   local oStruEVI   := nil

   oStruEVI := FWFormStruct( 1, "EVI", {|x| CheckField(x, EasyStrSplit(DU100Model("EVI"), "|")) })

   oStruEVI:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEVI:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEVI:SetProperty('*', MODEL_FIELD_NOUPD, .F.)

   oModel:AddGrid('EVIDETAIL', 'EV2MSTR_MC', oStruEVI)

   oModel:GetModel("EVIDETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EVIDETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EVIDETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EVIDETAIL"):SetOptional( .T. )
   oModel:GetModel("EVIDETAIL"):SetUniqueLine({"EVI_FILIAL","EVI_LOTE","EVI_HAWB","EVI_SEQDUI","EVI_NUM"} )

   oModel:SetRelation('EVIDETAIL', {;
      { 'EVI_FILIAL'   ,'xFilial("EVI")'},;
      { 'EVI_LOTE'     ,'EV2_LOTE'      },;
      { 'EVI_HAWB'     ,'EV2_HAWB'      },;
      { 'EVI_SEQDUI'   ,'EV2_SEQDUI'    };
      },; 
      EVI->(dbSetOrder(2)) ) // EVI_FILIAL+EVI_LOTE+EVI_HAWB+EVI_SEQDUI

return nil

/*
Função     : setMdlEV6
Objetivo   : Define o modelo para Documentos Vinculados (EV6)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setMdlEV6(oModel)
   local oStruEV6   := nil

   oStruEV6 := FWFormStruct( 1, "EV6", {|x| CheckField(x, EasyStrSplit(DU100Model("EV6"), "|")) })

   oStruEV6:SetProperty('*' , MODEL_FIELD_OBRIGAT, .F. )

   //STRUCT_FEATURE_WHEN
   oStruEV6:SetProperty('*' , MODEL_FIELD_WHEN, {|| .F. }) //Monta When diferente do dicionário   

   //MODEL_FIELD_NOUPD - Indica se o campo pode receber valor em uma operação de update.
   oStruEV6:SetProperty('*', MODEL_FIELD_NOUPD, .F.)  

   oModel:AddGrid('EV6DETAIL', 'EV2MSTR_MC', oStruEV6)

   oModel:GetModel("EV6DETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("EV6DETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("EV6DETAIL"):SetNoUpdateLine(.T.)
   oModel:GetModel("EV6DETAIL"):SetOptional( .T. )
   oModel:GetModel("EV6DETAIL"):SetUniqueLine({'EV6_FILIAL','EV6_LOTE','EV6_HAWB','EV6_SEQDUI','EV6_TIPVIN','EV6_DOCVIN'})

   oModel:SetRelation('EV6DETAIL', {;
      { 'EV6_FILIAL'   ,'xFilial("EV6")'},;
      { 'EV6_LOTE'     ,'EV2_LOTE'      },;
      { 'EV6_HAWB'     ,'EV2_HAWB'      },;
      { 'EV6_SEQDUI'   ,'EV2_SEQDUI'    };
      },; 
      EV6->(dbSetOrder(3)) ) // EV6_FILIAL+EV6_LOTE+EV6_HAWB+EV6_SEQDUI

return nil

*------------------------*
Static Function ViewDef()
*------------------------*
   local oModel     := nil
   local oView      := nil
   local bInteg     := { |oView| if( oView:oModel:VldData(), DU101PrcInt(,,oView:GetOperation()), nil) }

   oView := FWFormView():New() // Cria o objeto de View
   oModel := FWLoadModel("EICDU100") // Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
   oView:SetModel( oModel ) // Define qual o Modelo de dados a ser utilizado
   oView:SetDescription(STR0001) // "Integração DUIMP" 

   SetViewStuc(oView)

   // Capa da rotina
   SetViewEV1(oView)
   SetViewEV9(oView)
   SetViewEVB(oView)
   SetViewCmp(oView)

   // Itens da rotina
   SetViewSWV(oView)
   setViewMC(oView)
   setViewFF(oView)
   setViewCV(oView)
   if DUIMP2310()
      setViewTR(oView)
   endif
   setViewAcDe(oView)
   setViewEVE(oView)
   setViewEVI(oView)
   setViewEV6(oView)

   oView:SetAfterOkButton(bInteg)

Return oView 
/*
Função     : SetViewStuc
Objetivo   : Define o layout da tela
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Fevereiro/2022
Obs.       :
*/
Static Function SetViewStuc(oView)

   oView:CreateHorizontalBox("CAPA", 40)
   oView:CreateFolder("FOLDER_CAPA", "CAPA")
   oView:addSheet("FOLDER_CAPA", "CADASTRAIS", STR0006 ) //"Cadastrais"
   oView:addSheet("FOLDER_CAPA", "DOCINSTR"  , STR0007 ) //"Documentos de Instrução"
   oView:addSheet("FOLDER_CAPA", "PROCVINC"  , STR0008 ) //"Processos Vinculados"
   oView:addSheet("FOLDER_CAPA", "DADOS_COMP", STR0063 ) //"Dados Complementares"

   oView:CreateHorizontalBox("ITEM", 60)
   oView:CreateVerticalBox('INF_ESQ', 30,"ITEM",,,)    //Cria Box a esquerda para dados da SWV
   oView:CreateVerticalBox('INF_DIR', 70,"ITEM",,,)     ////Cria Box a Direita para Pastas do item

   oView:CreateFolder("FOLDER_ITEM", "INF_DIR")
   oView:addSheet("FOLDER_ITEM", "MERCADORIA", STR0030 ) // "Mercadoria"
   oView:addSheet("FOLDER_ITEM", "FABR_FORN" , STR0031 ) // "Fabricante / Fornecedor"
   oView:addSheet("FOLDER_ITEM", "COND_VENDA", STR0032 ) // "Condição de Venda / Cambiais"
   oView:addSheet("FOLDER_ITEM", "ACRES_DEDU", STR0033 ) // "Acréscimos e Deduções"
   oView:addSheet("FOLDER_ITEM", "LPCO"      , "LPCO's" )
   oView:addSheet("FOLDER_ITEM", "CERT_MERC" , STR0034 ) // "Certificado Mercosul"
   oView:addSheet("FOLDER_ITEM", "DOC_VINCUL", STR0035 ) // "Documentos Vinculados"
   if DUIMP2310()
      oView:addSheet("FOLDER_ITEM", "TRIBUTOS"  , STR0091 ) // "Tributos"
   endif
Return nil

/*
Função     : SetViewEV1
Objetivo   : Cria a instância da View para a tabela EV1 (Cadastrais)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Fevereiro/2022
Obs.       :
*/
Static Function SetViewEV1(oView)
   local aCampos    := {}
   local nCpo       := 0
   local oStruEV1   := nil

   aCampos := {{"EV1_LOTE","01"},{"EV1_HAWB","01"},{"EV1_SEQUEN","01"},{"EV1_USRGER","01"},{"EV1_DATGER","01"},{"EV1_HORGER","01"},; 
      {"EV1_IMPNOM"  ,"02"}, {"EV1_IMPNRO","02"}, {"EV1_INFCOM","02"},;
      {"EV1_COIDM","03"},{"EV1_URFDES","03"},;
      {"EV1_SEGMOE","04"}, {"EV1_SETOMO","04"}}

   oStruEV1 := FWFormStruct( 2, "EV1", {|x| CheckField(x, aCampos) } )
   oStruEV1:AddGroup("01", STR0009 , "01", 2) //"Dados Gerais"
   oStruEV1:AddGroup("02", STR0010 , "01", 2) //"Identificação"
   oStruEV1:AddGroup("03", STR0011 , "01", 2) //"Carga"
   oStruEV1:AddGroup("04", STR0012 , "01", 2) //"Seguro"

   //Remove os Folders
   oStruEV1:aFolders := {}

   //Títulos
   oStruEV1:SetProperty('EV1_HAWB'    , MVC_VIEW_TITULO, STR0024) // Embarque
   oStruEV1:SetProperty('EV1_IMPNOM'  , MVC_VIEW_TITULO, STR0025) // Importador
   oStruEV1:SetProperty('EV1_IMPNRO'  , MVC_VIEW_TITULO, STR0026) // CNPJ Importador  
   oStruEV1:SetProperty('EV1_COIDM'   , MVC_VIEW_TITULO, STR0027) // Ident. Carga  
 
   for nCpo := 1 to len(aCampos)
      oStruEV1:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2])
      oStruEV1:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM , strZero(nCpo,2))
   next

   // Consulta Padrão SW6
   oStruEV1:SetProperty("EV1_HAWB"  , MVC_VIEW_LOOKUP , "SW6DUI" )

   oView:CreateHorizontalBox( 'VIEW_CADASTRAIS', 100,,,'FOLDER_CAPA', "CADASTRAIS")
   oView:AddField( 'VIEW_EV1', oStruEV1, 'EV1MASTER' )
   oView:SetOwnerView( 'VIEW_EV1', 'VIEW_CADASTRAIS' )

Return Nil

/*
Função     : SetViewEV9
Objetivo   : Cria a instância da View para a tabela EV9 (Documentos de Instrução)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetViewEV9(oView)
   local oStruEV9   := nil

   oStruEV9 := FWFormStruct( 2, "EV9", {|x| CheckField(x, EasyStrSplit(DU100View("EV9"), "|")) }   )

   oStruEV9:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
   oStruEV9:SetProperty('EV9_CODIN'   , MVC_VIEW_TITULO, STR0044) // "Código"
   oStruEV9:SetProperty('EV9_DOCTO'   , MVC_VIEW_TITULO, STR0045) // "Número do Documento"

   oView:CreateHorizontalBox( 'VIEW_DOCINSTR', 100,,,'FOLDER_CAPA', "DOCINSTR")
   oView:AddGrid( 'VIEW_EV9', oStruEV9, 'EV9DETAIL' )
   oView:SetOwnerView( 'VIEW_EV9', 'VIEW_DOCINSTR' )
   oView:SetViewProperty( "VIEW_EV9", "SETCSS", { MYCSS } )

return nil

/*
Função     : SetViewEVB
Objetivo   : Cria a instância da View para a tabela EVB (Processo Vinculados)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetViewEVB(oView)
   local oStruEVB   := nil

   oStruEVB := FWFormStruct( 2, "EVB", {|x| CheckField(x, EasyStrSplit(DU100View("EVB"), "|")) }   )

   oStruEVB:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
   oStruEVB:SetProperty('EVB_CODPV', MVC_VIEW_TITULO, STR0023) // Tipo
   oStruEVB:SetProperty('EVB_DESPV', MVC_VIEW_TITULO, STR0022) // Identificação  

   oView:CreateHorizontalBox( 'VIEW_PROCVINC', 100,,,'FOLDER_CAPA', "PROCVINC")
   oView:AddGrid( 'VIEW_EVB', oStruEVB, 'EVBDETAIL' )
   oView:SetOwnerView( 'VIEW_EVB', 'VIEW_PROCVINC' )
   oView:SetViewProperty( "VIEW_EVB", "SETCSS", { MYCSS } )

Return Nil

/*
Função     : SetViewCmp
Objetivo   : Cria a instância da View para a tabela EV1 (Dados Complementares)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
Static Function SetViewCmp(oView)
   local oStruEV1   := nil

   oStruEV1 := FWFormStruct( 2, "EV1", {|x| CheckField(x, EasyStrSplit(DU100View("EV1"), "|")) } )

   //Remove os Folders
   oStruEV1:aFolders := {}

   //Títulos
   oStruEV1:SetProperty('EV1_LOGINT'  , MVC_VIEW_TITULO, STR0060) // Log Geral da Integração 

   oView:CreateHorizontalBox( 'VIEW_DADOS_COMP', 100,,,'FOLDER_CAPA', "DADOS_COMP")
   oView:AddField( 'VIEW_EV1_DADOS_COMP', oStruEV1, 'EV1MASTER' )
   oView:SetOwnerView( 'VIEW_EV1_DADOS_COMP', 'VIEW_DADOS_COMP' )

Return Nil

/*
Função     : SetViewSWV
Objetivo   : Cria a instância da View para a tabela SWV (Dados itens duimp)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetViewSWV(oView)
   local oStruSWV   := nil

   oStruSWV := FWFormStruct( 2, "SWV", {|x| alltrim(x) $ DU100View("SWV") } )

   oStruSWV:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
   //ordem dos campos
   oStruSWV:SetProperty('WV_SEQDUIM', MVC_VIEW_ORDEM, '01') 
   oStruSWV:SetProperty('WV_INVOICE', MVC_VIEW_ORDEM, '02') 
   oStruSWV:SetProperty('WV_FORN'   , MVC_VIEW_ORDEM, '03') 
   oStruSWV:SetProperty('WV_FORLOJ' , MVC_VIEW_ORDEM, '04') 
   oStruSWV:SetProperty('WV_NOMEFOR', MVC_VIEW_ORDEM, '05') 
   oStruSWV:SetProperty('WV_PO_NUM' , MVC_VIEW_ORDEM, '06') 
   oStruSWV:SetProperty('WV_POSICAO', MVC_VIEW_ORDEM, '07') 
   oStruSWV:SetProperty('WV_SEQUENC', MVC_VIEW_ORDEM, '08') 
   oStruSWV:SetProperty('WV_COD_I'  , MVC_VIEW_ORDEM, '09') 
   oStruSWV:SetProperty('WV_DESC_DI', MVC_VIEW_ORDEM, '10') 
   oStruSWV:SetProperty('WV_NCM'    , MVC_VIEW_ORDEM, '11') 
   oStruSWV:SetProperty('WV_QTDE'   , MVC_VIEW_ORDEM, '12') 
   oStruSWV:SetProperty('WV_LOTE'   , MVC_VIEW_ORDEM, '13') 
   oStruSWV:SetProperty('WV_DT_VALI', MVC_VIEW_ORDEM, '14') 
   oStruSWV:SetProperty('WV_DFABRI' , MVC_VIEW_ORDEM, '15') 
   oStruSWV:SetProperty('WV_OBS'    , MVC_VIEW_ORDEM, '16') 


   oView:AddGrid( 'VIEW_SWV', oStruSWV, 'SWVDETAIL' )
   oView:SetOwnerView( 'VIEW_SWV', 'INF_ESQ' )
   oView:SetViewProperty( "VIEW_SWV", "SETCSS", { MYCSS } )

Return Nil

/*
Função     : setViewMC
Objetivo   : Define o view para Mercadorias (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewMC(oView)
   local aCampos    := {}
   local nCpo       := 0
   local oStruEV2   := nil

   aCampos := {;
      {"EV2_IDPTCP","01"},{"EV2_VRSACP","01"},{"EV2_CNPJRZ","01"},;
      {"EV2_VINCCO","02"},{"EV2_APLME" ,"02"},{"EV2_MATUSA","02"},{"EV2_DSCCIT","02"},;
      {"EV2_IMPCO" ,"03"},{"EV2_CNPJAD","03"},;
      {"EV2_NMCOM" ,"04"},{"EV2_QTCOM" ,"04"},{"EV2_QT_EST","04"},{"EV2_PESOL" ,"04"},{"EV2_MOE1","04"},{"EV2_VLMLE","04"}}
      
   oStruEV2 := FWFormStruct( 2, "EV2", {|x| CheckField(x, aCampos) } )
   oStruEV2:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   oStruEV2:AddGroup("01", STR0036 , "01", 2) // "Catálogo de Produtos"
   oStruEV2:AddGroup("02", STR0037 , "01", 2) // "Dados Gerais"
   oStruEV2:AddGroup("03", STR0038 , "01", 2) // "Caracterização da Importação"
   oStruEV2:AddGroup("04", STR0039 , "01", 2) // "Valores"

   //Remove os Folders
   oStruEV2:aFolders := {}

   //Títulos
   oStruEV2:SetProperty('EV2_VINCCO'  , MVC_VIEW_TITULO, STR0046) // Código
   oStruEV2:SetProperty('EV2_MATUSA'  , MVC_VIEW_TITULO, STR0047) // Condição
   oStruEV2:SetProperty('EV2_NMCOM'   , MVC_VIEW_TITULO, STR0048) // Unidade Comercial

   oStruEV2:SetProperty('EV2_APLME'   , MVC_VIEW_COMBOBOX, {" ",STR0064, STR0065 } ) // "1=Consumo","2=Revenda"
   oStruEV2:SetProperty('EV2_MATUSA'  , MVC_VIEW_COMBOBOX, {" ",STR0066, STR0067 } ) // "1=Usado","2=Nao Usado"
   oStruEV2:SetProperty('EV2_VINCCO'  , MVC_VIEW_COMBOBOX, {" ",STR0068, STR0069, STR0070 } ) // "1=Sem Vinculação","2=Com vinculação, sem influência no preço","3=Com vinculação, com influência no preço"
   oStruEV2:SetProperty('EV2_IMPCO'   , MVC_VIEW_COMBOBOX, {" ",STR0071, STR0072 } ) // "1=Sim","2=Não"

   oStruEV2:SetProperty("EV2_MOE1"   , MVC_VIEW_LOOKUP , "SYF" )

   for nCpo := 1 to len(aCampos)
      oStruEV2:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2])
      oStruEV2:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM, strZero(nCpo,2))
   next

   oView:CreateHorizontalBox( 'VIEW_MERCADORIAS', 100,,,'FOLDER_ITEM', "MERCADORIA")
   oView:AddField( 'VIEW_EV2_MC', oStruEV2, 'EV2MSTR_MC' )
   oView:SetOwnerView( 'VIEW_EV2_MC', 'VIEW_MERCADORIAS' )

return nil

/*
Função     : setViewFF
Objetivo   : Define o view para Fabricante / Fornecedor (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewFF(oView)
   local aCampos    := {}
   local nCpo       := 0
   local oStruEV2   := nil

   aCampos := {;
      {"EV2_FABFOR","01"},{"EV2_TINFA" ,"01"},{"EV2_VRSFAB","01"},{"EV2_PAIOME","01"},;
      {"EV2_TINFO" ,"02"},{"EV2_VRSFOR","02"},{"EV2_PAISPR","02"}}
      
   oStruEV2 := FWFormStruct( 2, "EV2", {|x| CheckField(x, aCampos) } )
   oStruEV2:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   oStruEV2:AddGroup("01", STR0040 , "01", 2) // "Dados do Fabricante"
   oStruEV2:AddGroup("02", STR0041 , "01", 2) // "Fornecedor"

   //Remove os Folders
   oStruEV2:aFolders := {}

   //Títulos
   oStruEV2:SetProperty('EV2_FABFOR'  , MVC_VIEW_TITULO, STR0049) // Indicador Fabricante
   oStruEV2:SetProperty('EV2_PAIOME'  , MVC_VIEW_TITULO, STR0050) // País de Origem

   oStruEV2:SetProperty('EV2_FABFOR'  , MVC_VIEW_COMBOBOX, {" ", STR0073, STR0074, STR0075 } ) // "1=Fabricante / Produtor é o Exportador" , "2=Fabricante / Produtor não é o Exportador" , "3=O Fabricante / Produtor é Desconhecido"

   for nCpo := 1 to len(aCampos)
      oStruEV2:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2])
      oStruEV2:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM, strZero(nCpo,2))
   next

   oView:CreateHorizontalBox( 'VIEW_FAB_FORN', 100,,,'FOLDER_ITEM', "FABR_FORN")
   oView:AddField( 'VIEW_EV2_FF', oStruEV2, 'EV2MSTR_FF' )
   oView:SetOwnerView( 'VIEW_EV2_FF', 'VIEW_FAB_FORN' )

return nil

/*
Função     : setViewCV
Objetivo   : Define o view para Condição de Venda / Cambiais (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewCV(oView)
   local aCampos    := {}
   local nCpo       := 0
   local oStruEV2   := nil

   aCampos := {;
      {"EV2_METVAL","01"},{"EV2_INCOTE","01"},;
      {"EV2_TIPCOB","02"},{"EV2_NRROF" ,"02"},{"EV2_INSTFI","02"},{"EV2_VL_FIN","02"},{"EV2_MOTIVO","02"}}

   oStruEV2 := FWFormStruct( 2, "EV2", {|x| CheckField(x, aCampos) } )
   oStruEV2:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   oStruEV2:AddGroup("01", STR0042 , "01", 2) // "Valoração"
   oStruEV2:AddGroup("02", STR0043 , "01", 2) // "Dados Cambiais"

   //Remove os Folders
   oStruEV2:aFolders := {}

   oStruEV2:SetProperty('EV2_TIPCOB'  , MVC_VIEW_COMBOBOX, {" ", STR0076, STR0077, STR0078, STR0079 } ) // "1=180 DD" ,"2=De 181 a 360 DD" ,"3=Acima de 360 DD" ,"4=Sem Cobertura"

   oStruEV2:SetProperty("EV2_METVAL"  , MVC_VIEW_LOOKUP , "SJM" )
   oStruEV2:SetProperty("EV2_INCOTE"  , MVC_VIEW_LOOKUP , "SYJ" )
   oStruEV2:SetProperty("EV2_INSTFI"  , MVC_VIEW_LOOKUP , "SJ7" )
   oStruEV2:SetProperty("EV2_MOTIVO"  , MVC_VIEW_LOOKUP , "SJ8" )

   for nCpo := 1 to len(aCampos)
      oStruEV2:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2])
      oStruEV2:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM, strZero(nCpo,2))
   next

   oView:CreateHorizontalBox( 'VIEW_COND_VENDA', 100,,,'FOLDER_ITEM', "COND_VENDA")
   oView:AddField( 'VIEW_EV2_CC', oStruEV2, 'EV2MSTR_CV' )
   oView:SetOwnerView( 'VIEW_EV2_CC', 'VIEW_COND_VENDA' )

return nil

/*
Função     : setViewTR
Objetivo   : Define o view para Tributos (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewTR(oView)
   local aCampos    := {}
   local oStrII     := nil
   local oStrIPI    := nil
   local oStrPISCOF := nil
   local oStrInteg  := nil

   aCampos := { {"EV2_VLRCII","01", "II " + STR0092},{"EV2_VRDII","01", "II " + STR0093},{"EV2_VLDII","01", "II " + STR0094},{"EV2_VLSII","01", "II " + STR0095},{"EV2_VRCII","01", "II " + STR0096}} // "Calculado" ### "a Reduzir" ### "Devido" ### "Suspenso" ### "a Recolher"
   oStrII := FWFormStruct( 2, "EV2", {|x| alltrim(upper(x)) $ "EV2_VLRCII||EV2_VRDII||EV2_VLDII||EV2_VLSII||EV2_VRCII" } )
   setStruEV2(@oStrII, aCampos)

   aCampos := { {"EV2_VLCIPI","01", "IPI " + STR0092},{"EV2_VRDIPI","01", "IPI " + STR0093},{"EV2_VDIPI","01", "IPI " + STR0094},{"EV2_VLSIPI","01", "IPI " + STR0095},{"EV2_VRCIPI","01", "IPI " + STR0096}} // "Calculado" ### "a Reduzir" ### "Devido" ### "Suspenso" ### "a Recolher"
   oStrIPI := FWFormStruct( 2, "EV2", {|x| alltrim(upper(x)) $ "EV2_VLCIPI||EV2_VRDIPI||EV2_VDIPI||EV2_VLSIPI||EV2_VRCIPI" } )
   setStruEV2(@oStrIPI, aCampos)

   aCampos := { {"EV2_VLCPIS","01", "PIS " + STR0092},{"EV2_VRDPIS","01", "PIS " + STR0093},{"EV2_VDEPIS","01", "PIS " + STR0094},{"EV2_VLSPIS","01", "PIS " + STR0095},{"EV2_VRCPIS","01", "PIS " + STR0096},; // "Calculado" ### "a Reduzir" ### "Devido" ### "Suspenso" ### "a Recolher"
                {"EV2_VLCCOF","02", "COFINS " + STR0092},{"EV2_VRDCOF","02", "COFINS " + STR0093},{"EV2_VDECOF","02", "COFINS " + STR0094},{"EV2_VLSCOF","02", "COFINS " + STR0095},{"EV2_VRCCOF","02", "COFINS " + STR0096}} // "Calculado" ### "a Reduzir" ### "Devido" ### "Suspenso" ### "a Recolher"

   oStrPISCOF := FWFormStruct( 2, "EV2", {|x| alltrim(upper(x)) $ "EV2_VLCPIS||EV2_VRDPIS||EV2_VDEPIS||EV2_VLSPIS||EV2_VRCPIS||EV2_VLCCOF||EV2_VRDCOF||EV2_VDECOF||EV2_VLSCOF||EV2_VRCCOF" } )
   setStruEV2(@oStrPISCOF, aCampos, "PISCOFINS")

   oStrInteg := FWFormStruct( 2, "EV2", {|x| alltrim(upper(x)) $ "EV2_OBSTRB" } )
   oStrInteg:SetProperty( "EV2_OBSTRB", MVC_VIEW_TITULO, STR0097) // "Obs. Tributos"

   oView:CreateHorizontalBox( 'VIEW_TRIBUTOS', 100,,,'FOLDER_ITEM', "TRIBUTOS") 
   oView:CreateFolder("FOLDER_TRIBUTOS", "VIEW_TRIBUTOS")
   oView:addSheet("FOLDER_TRIBUTOS", "II"          , STR0098 ) //"Imposto de Importação"
   oView:addSheet("FOLDER_TRIBUTOS", "IPI"         , "IPI" ) //"IPI"
   oView:addSheet("FOLDER_TRIBUTOS", "PIS_COFINS"  , "PIS/COFINS" ) //"PIS/COFINS"
   oView:addSheet("FOLDER_TRIBUTOS", "INTEGRACAO"  , STR0099 ) //"Integração"

   oView:CreateHorizontalBox( 'BOX_II', 100,,,'FOLDER_TRIBUTOS', "II")
   oView:AddField( 'VIEW_EV2_TR_II', oStrII, 'EV2MSTR_TRIB_II' )
   oView:SetOwnerView( 'VIEW_EV2_TR_II', 'BOX_II' )

   oView:CreateHorizontalBox( 'BOX_IPI', 100,,,'FOLDER_TRIBUTOS', "IPI")
   oView:AddField( 'VIEW_EV2_TR_IPI', oStrIPI, 'EV2MSTR_TRIB_IPI' )
   oView:SetOwnerView( 'VIEW_EV2_TR_IPI', 'BOX_IPI' )

   oView:CreateHorizontalBox( 'BOX_PISCOFINS', 100,,,'FOLDER_TRIBUTOS', "PIS_COFINS")
   oView:AddField( 'VIEW_EV2_TR_PISCOFINS', oStrPISCOF, 'EV2MSTR_TRIB_PISCOFINS' )
   oView:SetOwnerView( 'VIEW_EV2_TR_PISCOFINS', 'BOX_PISCOFINS' )

   oView:CreateHorizontalBox( 'BOX_INTEGRACAO', 100,,,'FOLDER_TRIBUTOS', "INTEGRACAO")
   oView:AddField( 'VIEW_EV2_TR_INTEGRACAO', oStrInteg, 'EV2MSTR_TRIB_OBS' )
   oView:SetOwnerView( 'VIEW_EV2_TR_INTEGRACAO', 'BOX_INTEGRACAO' )

return nil

/*
Função     : setStruEV2
Objetivo   : Define as propriedades para a view dos Tributos (EV2)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setStruEV2(oStruct, aCampos, cTipo)
   local nCpo       := 0

   default oStruct := FWFormStruct( 2, "EV2" )
   default aCampos := {}
   default cTipo   := ""

   oStruct:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   if empty(cTipo)
      oStruct:AddGroup("01", STR0100 , "01", 2) // "Tributos Registrados"
   else
      oStruct:AddGroup("01", STR0100 + " - PIS" , "01", 2) // "Tributos Registrados"
      oStruct:AddGroup("02", STR0100 + " - COFINS", "01", 2) // "Tributos Registrados"
   endif

   //Remove os Folders
   oStruct:aFolders := {}

   for nCpo := 1 to len(aCampos)
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2])
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM, strZero(nCpo,2))
      if len(aCampos[nCpo]) > 2 .and. !empty(aCampos[nCpo][3])
         oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_TITULO, aCampos[nCpo][3])
      endif
   next

return

/*
Função     : setViewAcDe
Objetivo   : Define o view para Acréscimos (EV3) e Deduções (EV4)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewAcDe(oView)
   local oStruEV3   := nil
   local oStruEV4   := nil

   oView:CreateHorizontalBox( 'VIEW_ACRES_DED', 100,,,'FOLDER_ITEM', "ACRES_DEDU")
   oView:CreateVerticalBox('VIEW_ACRES', 50,"VIEW_ACRES_DED",,'FOLDER_ITEM', "ACRES_DEDU")
   oView:CreateVerticalBox('VIEW_DEDU' , 50,"VIEW_ACRES_DED",,'FOLDER_ITEM', "ACRES_DEDU")

   oStruEV3 := FWFormStruct( 2, "EV3", {|x| CheckField(x, EasyStrSplit(DU100View("EV3"), "|")) }   )
   oStruEV3:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
   oStruEV3:SetProperty("EV3_MOE"  , MVC_VIEW_LOOKUP , "SYF" )

   oView:AddGrid( 'VIEW_EV3', oStruEV3, 'EV3DETAIL' )
   oView:SetOwnerView( 'VIEW_EV3', 'VIEW_ACRES' )
   oView:SetViewProperty( "VIEW_EV3", "SETCSS", { MYCSS } )

   oStruEV4 := FWFormStruct( 2, "EV4", {|x| CheckField(x, EasyStrSplit(DU100View("EV4"), "|")) }   )
   oStruEV4:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)
   oStruEV4:SetProperty("EV4_MOE"  , MVC_VIEW_LOOKUP , "SYF" )

   oView:AddGrid( 'VIEW_EV4', oStruEV4, 'EV4DETAIL' )
   oView:SetOwnerView( 'VIEW_EV4', 'VIEW_DEDU' )
   oView:SetViewProperty( "VIEW_EV4", "SETCSS", { MYCSS } )

return nil

/*
Função     : setViewEVE
Objetivo   : Define o view para LPCO's (EVE)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewEVE(oView)
   local oStruEVE   := nil

   oStruEVE := FWFormStruct( 2, "EVE", {|x| CheckField(x, EasyStrSplit(DU100View("EVE"), "|")) }   )
   oStruEVE:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   oView:CreateHorizontalBox( 'VIEW_LPCO', 100,,,'FOLDER_ITEM', "LPCO")
   oView:AddGrid( 'VIEW_EVE', oStruEVE, 'EVEDETAIL' )
   oView:SetOwnerView( 'VIEW_EVE', 'VIEW_LPCO' )
   oView:SetViewProperty( "VIEW_EVE", "SETCSS", { MYCSS } )

return nil

/*
Função     : setViewEVI
Objetivo   : Define o view para Certificado Mercosul (EVI)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewEVI(oView)
   local oStruEVI   := nil

   oStruEVI := FWFormStruct( 2, "EVI", {|x| CheckField(x, EasyStrSplit(DU100View("EVI"), "|")) }   )
   oStruEVI:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   oStruEVI:SetProperty( "EVI_IDCERT", MVC_VIEW_ORDEM, "01")
   oStruEVI:SetProperty( "EVI_DEMERC", MVC_VIEW_ORDEM, "02")
   oStruEVI:SetProperty( "EVI_QTDCER", MVC_VIEW_ORDEM, "03")

   oView:CreateHorizontalBox( 'VIEW_CERT_MERC', 100,,,'FOLDER_ITEM', "CERT_MERC")
   oView:AddGrid( 'VIEW_EVI', oStruEVI, 'EVIDETAIL' )
   oView:SetOwnerView( 'VIEW_EVI', 'VIEW_CERT_MERC' )
   oView:SetViewProperty( "VIEW_EVI", "SETCSS", { MYCSS } )

return nil

/*
Função     : setViewEV6
Objetivo   : Define o view para Documentos Vinculados (EV6)
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function setViewEV6(oView)
   local oStruEV6   := nil

   oStruEV6 := FWFormStruct( 2, "EV6", {|x| CheckField(x, EasyStrSplit(DU100View("EV6"), "|")) }   )
   oStruEV6:SetProperty('*', MVC_VIEW_CANCHANGE, .F.)

   oView:CreateHorizontalBox( 'VIEW_DOC_VINC', 100,,,'FOLDER_ITEM', "DOC_VINCUL")
   oView:AddGrid( 'VIEW_EV6', oStruEV6, 'EV6DETAIL' )
   oView:SetOwnerView( 'VIEW_EV6', 'VIEW_DOC_VINC' )
   oView:SetViewProperty( "VIEW_EV6", "SETCSS", { MYCSS } )

return nil

/*
Função     : DU100Model
Objetivo   : Função que retorna string de campos a serem utilizados pelo modeldef(regra de negócios). Contém campos carregados também internamente
mesmo que não mostrados na tela
Parâmetro  :
Retorno    : String
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
Static Function DU100Model(cAlias)
   Local cRet := ""

   Do CASE
      CASE cAlias == 'EV1'
         cRet := "|EV1_FILIAL|EV1_HAWB|EV1_LOTE|EV1_SEQUEN|EV1_DATGER|EV1_HORGER|EV1_USRGER|EV1_IMPNOM|EV1_IMPNRO|EV1_COIDM|EV1_URFDES|EV1_SEGMOE|EV1_SETOMO|EV1_TIPREG|EV1_INFCOM|EV1_LOGINT|EV1_STATUS|EV1_DI_NUM|EV1_VERSAO"
      CASE cAlias == 'EVB'         
         cRet := "|EVB_FILIAL|EVB_HAWB|EVB_LOTE|EVB_CODPV|EVB_DESPV|"
      CASE cAlias == 'EV9'
         cRet := "|EV9_FILIAL|EV9_HAWB|EV9_LOTE|EV9_CODIN|EV9_SEQUEN|EV9_DOCTO|"
      CASE cAlias == 'SWV'   
         cRet := "|WV_HAWB|WV_SEQDUIM|WV_ID|WV_INVOICE|WV_FORN|WV_NOMEFOR|WV_FORLOJ|WV_PO_NUM|WV_POSICAO|WV_COD_I|WV_DESC_DI|WV_NCM|WV_SEQUENC|WV_QTDE|WV_LOTE|WV_DT_VALI|WV_DFABRI|WV_OBS|WV_PGI_NUM|"
      CASE cAlias == 'EV2_MERCADORIA'
           cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_IDPTCP|EV2_VRSACP|EV2_CNPJRZ|EV2_VINCCO|EV2_APLME|EV2_MATUSA|EV2_DSCCIT|EV2_IMPCO|EV2_NMCOM|EV2_QTCOM|EV2_QT_EST|EV2_PESOL|EV2_MOE1|EV2_VLMLE|EV2_FABFOR|EV2_TINFA|EV2_VRSFAB|EV2_PAIOME|EV2_TINFO|EV2_VRSFOR|EV2_PAISPR|EV2_METVAL|EV2_INCOTE|EV2_TIPCOB|EV2_NRROF|EV2_INSTFI|EV2_MOTIVO|EV2_VL_FIN|EV2_CNPJAD|"         
           if DUIMP2310()
              cRet += "EV2_VLRCII|EV2_VLDII|EV2_VRDII|EV2_VLSII|EV2_VRCII|EV2_VLCIPI|EV2_VDIPI|EV2_VRDIPI|EV2_VLSIPI|EV2_VRCIPI|EV2_VLCPIS|EV2_VRDPIS|EV2_VDEPIS|EV2_VLSPIS|EV2_VRCPIS|EV2_VLCCOF|EV2_VRDCOF|EV2_VDECOF|EV2_VLSCOF|EV2_VRCCOF|EV2_OBSTRB|"
           endif
      CASE cAlias == 'EV2_FABR_FORN'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_FABFOR|EV2_TINFA|EV2_VRSFAB|EV2_PAIOME|EV2_TINFO|EV2_VRSFOR|EV2_PAISPR|"
      CASE cAlias == 'EV2_COND_VENDA'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_METVAL|EV2_INCOTE|EV2_TIPCOB|EV2_NRROF|EV2_INSTFI|EV2_MOTIVO|EV2_VL_FIN|"
      CASE cAlias == 'EV2_TRIBUTOS_II'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_VLRCII|EV2_VLDII|EV2_VRDII|EV2_VLSII|EV2_VRCII|"
      CASE cAlias == 'EV2_TRIBUTOS_IPI'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_VLCIPI|EV2_VDIPI|EV2_VRDIPI|EV2_VLSIPI|EV2_VRCIPI|"
      CASE cAlias == 'EV2_TRIBUTOS_PISCOFINS'
         cRet := "|EV2_FILIAL|EV2_HAWB|EV2_LOTE|EV2_SEQDUI|EV2_VLCPIS|EV2_VRDPIS|EV2_VDEPIS|EV2_VLSPIS|EV2_VRCPIS|EV2_VLCCOF|EV2_VRDCOF|EV2_VDECOF|EV2_VLSCOF|EV2_VRCCOF|"
      CASE cAlias == 'EV2_TRIBUTACAO'
         cRet := "|EV2_OBSTRB|"
      CASE cAlias == 'EV3'
         cRet := "|EV3_FILIAL|EV3_HAWB|EV3_LOTE|EV3_SEQDUI|EV3_MOE|EV3_VLMLE|EV3_ACRES|"
      CASE cAlias == 'EV4'
         cRet := "|EV4_FILIAL|EV4_HAWB|EV4_LOTE|EV4_SEQDUI|EV4_MOE|EV4_VLMLE|EV4_DEDU|"
      CASE cAlias == 'EVE'
         cRet := "|EVE_FILIAL|EVE_LOTE|EVE_SEQDUI|EVE_LPCO|"
      CASE cAlias == 'EVI'
         cRet := "|EVI_FILIAL|EVI_HAWB|EVI_LOTE|EVI_SEQDUI|EVI_NUM|EVI_IDCERT|EVI_DEMERC|EVI_QTDCER|"
      CASE cAlias == 'EV6'
         cRet := "|EV6_FILIAL|EV6_HAWB|EV6_LOTE|EV6_SEQDUI|EV6_TIPVIN|EV6_DOCVIN|"
   END CASE

Return  cRet

/*
Função     : DU100View
Objetivo   : Função que retorna string de campos a serem utilizados pelo viewdef(regra de negócios). Contém campos carregados também internamente
mesmo que não mostrados na tela
Parâmetro  :
Retorno    : String
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
Static Function DU100View(cAlias)
   Local cRet := ""
   Do CASE
      CASE cAlias == 'EV1'
         cRet := "|EV1_LOGINT|"
      CASE cAlias == 'EVB'         
         cRet := "|EVB_DESPV|EVB_CODPV|"
      CASE cAlias == 'EV9'
         cRet := "|EV9_CODIN|EV9_DOCTO|"
      CASE cAlias == 'SWV'   
         cRet := "|WV_SEQDUIM|WV_INVOICE|WV_FORN|WV_NOMEFOR|WV_FORLOJ|WV_PO_NUM|WV_POSICAO|WV_COD_I|WV_DESC_DI|WV_NCM|WV_SEQUENC|WV_QTDE|WV_LOTE|WV_DT_VALI|WV_DFABRI|WV_OBS|"
      CASE cAlias == 'EV3'
         cRet := "|EV3_MOE|EV3_VLMLE|EV3_ACRES"
      CASE cAlias == 'EV4'
         cRet := "|EV4_MOE|EV4_VLMLE|EV4_DEDU"
      CASE cAlias == 'EVE'
         cRet := "|EVE_LPCO|"
      CASE cAlias == 'EVI'
         cRet := "|EVI_IDCERT|EVI_DEMERC|EVI_QTDCER|"
      CASE cAlias == 'EV6'
         cRet := "|EV6_TIPVIN|EV6_DOCVIN|"
   END CASE

Return  cRet

/*
Função     : CheckField
Objetivo   : Função para avaliar os campos para serem apresentados
Parâmetro  :
Retorno    : String
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
Static Function CheckField(cField, aFields, lUser)
   Local lRet := .F.
   Default lUser := .T.
   lRet := (ValType(aFields[1]) == "A" .And. aScan(aFields, {|x| AllTrim(x[1]) == AllTrim(cField) }) > 0) .Or. (ValType(aFields[1]) == "C" .And.  aScan(aFields, AllTrim(cField)) > 0) .Or. (lUser .and. GetSx3Cache(cField, "X3_PROPRI") == "U")
Return lRet

Function DU100EV1LO(cCampo) 
Local xValue
      Do Case
         Case cCampo == 'EV1_LOTE' 
              xValue := NextSeq(cCampo) //Função em desenvolvimento
      EndCase

Return xValue

/*---------------------------------------------------------------------*
 | Func:  NextSeq                                                    |
 | Autor: Maurício Frison                                              |
 | Data:  08/03/2022                                                   |
 | Desc:  Buscar próxima sequência dos campos sequenciais do modelo    |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function NextSeq(cCampo) 
Local cLastSeq 
Local oMdl     := FWModelActive()
Local oMdlEV1Master := oMdl:GetModel():GetModel("EV1MASTER")

Do CASE 
   Case cCampo='EV1_LOTE'
      cLastSeq := EasyGetMVSeq('CTRL_EV0')
   Case cCAmpo='EV1_SEQUEN'     
      cLastSeq := GetSql( oMdlEV1Master:GetValue("EV1_HAWB") )     
      cLastSeq := Soma1(cLastSeq)   
   EndCase
Return cLastSeq

/*---------------------------------------------------------------------*
 | Func:  GetSql                                                       |
 | Autor: Maurício Frison                                              |
 | Data:  10/03/2022                                                   |
 | Desc:  Executar o sql para buscar a próxima sequência               |
 | Obs.:  /                                                            |
 *---------------------------------------------------------------------*/
Static Function GetSql(cHawb)
Local cQryTab   := ""
Local cLastSeq  := '000'
Local nOldArea, cAliasQry
Local cAlias    := "EV1"
local cQryMax   := ""
local cQryWhere := ""

default cHawb := ""

   cQryMax   := "% MAX(EV1_SEQUEN) LASTSEQ %"
   cQryWhere := "% EV1_FILIAL = '"+xFilial("EV1")+"' AND EV1_HAWB = '" + cHawb + "' %"
   cQryTab := "% "+RetSQLName(cAlias)+" %"
   nOldArea = Select()
   cAliasQry := GetNextAlias()
   BeginSQL Alias cAliasQry
      SELECT %Exp:cQryMax% 
      FROM %Exp:cQryTab%
      WHERE %Exp:cQryWhere% 
      AND %notDel%
   EndSql
   If (cAliasQry)->(!Eof()) .And. (cAliasQry)->(!Bof())
      cLastSeq := (cAliasQry)->LASTSEQ
   EndIf
   (cAliasQry)->(DBCloseArea())
   If( nOldArea > 0 , DbSelectArea(nOldArea) , ) 

Return cLastSeq

/*
Função     : DU100Gatil
Objetivo   : Funcao para utilização de gatilhos
Retorno    : conteúdo a ser gatilhado
Autor      : Maurício Frison
Data/Hora  : Fevereiro/2022
Obs.       :
*/
Function DU100Gatil(cCampo)
   Local oMdl      := FWModelActive()
   Local cRet      := "" 
   local oModelEV1 := nil

   If ValType(oMdl:GetModel("EV1MASTER")) == "O"

      oModelEV1 := oMdl:GetModel("EV1MASTER")

      Do Case
         Case cCampo == "EV1_TIPREG"
              cRet  := LP500GetInfo("SW6",1,xFilial("SW6")+oModelEV1:GetValue("EV1_HAWB"),"W6_TIPOREG")
         Case cCampo == "EV1_SEQUEN"
              cRet := NextSeq(cCampo)
         Case cCampo == "EV1_IMPNOM"  
              cRet := LP500GetInfo("SYT",1,xFilial("SYT")+SW6->W6_IMPORT,"YT_NOME")
         Case cCampo == "EV1_IMPNRO"    
              cRet := SYT->YT_CGC //Entendo qeu já etá posicionado pela execução do gatilho acima
         Case cCampo == "EV1_INFCOM"   
              cRet := MSMM(SW6->W6_COMPLEM,AVSX3("W6_VM_COMP",03))
         Case cCampo == "EV1_COIDM"  
              cRet := SW6->W6_PRCARGA
         Case cCampo == "EV1_URFDES"   
              cRet := SW6->W6_URF_DES
         Case cCampo == "EV1_SEGMOE"
              cRet := getMoeda(SW6->W6_SEGMOED) // Posicione("SYF",1,xFilial("SYF")+SW6->W6_SEGMOED,"YF_COD_GI")    
         Case cCampo == "EV1_SETOMO"
              cRet := transform(SW6->W6_VL_USSE,GetSX3Cache("W6_VL_USSE","X3_PICTURE")) 
         Case cCampo == "EVB_CODPV"   
              cRet := oModelEV1:getValue("EV1_HAWB")
              Processa({|| GetInfDet(oMdl, "EVBDETAIL", "VIEW_EVB", cRet) }, STR0081 + "...") // "Carregando Processos Vinculados"
         Case cCampo == "EV9_DETAIL"
              cRet := oModelEV1:getValue("EV1_HAWB")
              Processa({|| GetInfDet(oMdl, "EV9DETAIL", "VIEW_EV9", cRet) }, STR0082 + "...") // "Carregando Documentos de Instrução"
         Case cCampo == "SWV_DETAIL"
              cRet := oModelEV1:getValue("EV1_HAWB")
              Processa({|| GetInfDet(oMdl, "SWVDETAIL", "VIEW_SWV", cRet) }, STR0083 + "...") // "Carregando Informações dos Itens da DUIMP"
      EndCase

   EndIf

Return cRet

/*
Função     : DU100WHEN
Objetivo   : Função para saber se campo pode ou nao ser habilitado para edição na tela
Parâmetro  :
Retorno    : .T. ou .F.
Autor      : Maurício Frison
Data/Hora  : Fevereiro/2022
Obs.       :
*/
Function DU100WHEN(cCampo)
   Local aArea          := GetArea()
   Local oModel         := FWModelActive()
   Local lRet := .T.

   Do CASE
      Case cCampo == 'EV1_HAWB'
         lRet :=  oModel:getOperation() == 3
      EndCase
   RestArea(aArea)
Return lRet

 /*
Função     : DU100VALID
Objetivo   : Função de validação
Parâmetro  :
Retorno    : .T. ou .F. se validou
Autor      : Maurício Frison
Data/Hora  : Fevereiro/2022
Obs.       :
*/
Function DU100VALID(cCampo,oMdl,xNewVl,xOldVl)
   Local aArea     := GetArea()
   Local oModel    := FWModelActive()
   Local lRet      := .T.
   Local cHawb     := ""
   Local oModelEV1 := nil
   Local lVerSeq   := .T.

   If ValType(oModel) == 'O'
      oModelEV1 := oModel:GetModel("EV1MASTER")
      Do Case
         Case cCampo == 'EV1_HAWB'
            if !empty( cHawb := oModelEV1:GetValue("EV1_HAWB"))

               aAreaSW6 := SW6->(getArea())
               SW6->(dbSetOrder(1))

               lRet := SW6->(dbSeek( xFilial("SW6") + cHawb ))
               if !lRet 
                  lRet := .F.
                  EasyHelp(STR0020, STR0014, STR0021) // "Embarque não encontrado." ### "Atenção" ### "Informe um Embarque correto."
               elseif SW6->W6_TIPOREG != DUIMP .OR. SW6->W6_FORMREG != DUIMP_INTEGRADA
                  lRet := .F.
                  EasyHelp(STR0013, STR0014, STR0015) // "Embarque inválido." ### "Atenção" ### "Somente será permitido Embarque do tipo 'DUIMP' e com a forma de registro 'Integrado'."
               endif

               if lRet
                  lRet := DU100VdPrc( oModel, oModelEV1, cHawb )
               endif

               If lRet //aqui
                  Do while lVerSeq
                     If DI154SeqVazia()
                        If MsgYesNo(STR0052,STR0051) //A sequência de registro da DUIMP não foi informada para todos os itens do processo. Deseja revisar a sequência dos itens?
                           Processa( { || LP500VINC() } , STR0084 + "...") // "Carregando itens DUIMP"
                        Else
                           EasyHelp(STR0054,STR0051,STR0053)  // ""Sequência do itens da DUIMP inválido" É necessário informar o campo sequência DUIMP de todos os itens para gerar o registro para a integração"                                                                                                                                                                                                                                                                                                                                                                                                                          
                           lVerSeq :=.F.
                           lRet := .F.
                        EndIf   
                     else
                        lVerSeq:=.F.   
                     EndIf   
                  EndDo   
               EndIf   
               If lRet
                  If !SoftLock("SW6")
                     EasyHelp(STR0029,STR0028) //"Registro em uso por outro usuário!" # "Atenção"
                     lRet:=.f.
                  EndIf
               EndIF
               restArea(aAreaSW6)

            endif
      EndCase
   EndIf

   RestArea(aArea)

Return lRet

/*
Função     : DU100VdPrc
Objetivo   : Função para validação do processo
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function DU100VdPrc( oModelo, oModelEV1, cHawb )
   local lRet       := .T.
   local nOperation := 0
   local aAreaEV1   := {}

   default oModelo   := FWModelActive()
   default oModelEV1 := oModelo:GetModel("EV1MASTER")
   default cHawb     := ""

   nOperation := oModelo:GetOperation()
   if nOperation == MODEL_OPERATION_INSERT .and. !empty(cHawb)

      dbSelectArea("EV1")
      aAreaEV1 := EV1->(getArea())
      EV1->(dbSetOrder(1)) // EV1_FILIAL+EV1_HAWB+EV1_LOTE
      if EV1->(AvSeekLast( xFilial("EV1") + cHawb ))
         if EV1->EV1_STATUS == DUIMP_REGISTRADA
            lRet := .F.
            EasyHelp(STR0085, STR0014, "") // "O status deste processo é de 'Duimp Registrada'. Não é possível prosseguir com a ação de inclusão do registro." ### "Atenção"
         else
            lRet := EV1->EV1_STATUS == OBSOLETO .or. MsgYesNo(STR0086, STR0014 ) // "Ao incluir um novo registro para integração, a sequência atual ficará obsoleta. Deseja prosseguir com a operação?" ### "Atenção"
            if lRet
               if !(EV1->EV1_STATUS == OBSOLETO)
                  _nRecEV1 := EV1->(recno())
               endif
               oModelEV1:loadValue("EV1_DI_NUM", EV1->EV1_DI_NUM )
               oModelEV1:loadValue("EV1_VERSAO", EV1->EV1_VERSAO )
            else
               EasyHelp(STR0087, STR0014, "") // "Operação cancelada." ### "Atenção"
            endif
         endif

      endif

      restArea(aAreaEV1)

   endif

return lRet

/*
Função     : DU100VdCan
Objetivo   : Função para tratar o cancelamento da inclusão ou alteração
Parâmetro  :
Retorno    : sem retorno
Autor      : Maurício Frison
Data/Hora  : Março/2022
Obs.       :
*/
static function DU100VdCan(oModel)
   FWFormCancel(oModel)
   RollbackSx8()
Return .T.

/*
Função     : DU100Commit
Objetivo   : Função para gravação do modelo
Parâmetro  :
Retorno    : sem retorno
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function DU100Commit(oModel)
   local nOperation := oModel:GetOperation()
   local cTabela    := ""

   if nOperation == MODEL_OPERATION_INSERT
      FWFormCommit(oModel)
      DU100AtuEV( _nRecEV1 , OBSOLETO )
   endif

   if nOperation == MODEL_OPERATION_DELETE

      if empty(EV1->EV1_DI_NUM) .and. empty(EV1->EV1_VERSAO)

         begin transaction

            EV9->(IndexKey(1)) // EV9_FILIAL+EV9_HAWB+EV9_LOTE+EV9_CODIN
            if EV9->(dbSeek( xFilial("EV9") + EV1->EV1_HAWB + EV1->EV1_LOTE ))
               cTabela := RetSQLName("EV9")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EV9_FILIAL = '" + xFilial("EV9") + "' AND EV9_HAWB = '" + EV1->EV1_HAWB + "' AND EV9_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EVB->(IndexKey(1)) // EVB_FILIAL+EVB_HAWB+EVB_LOTE
            if EVB->(dbSeek( xFilial("EVB") + EV1->EV1_HAWB + EV1->EV1_LOTE ))
               cTabela := RetSQLName("EVB")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EVB_FILIAL = '" + xFilial("EVB") + "' AND EVB_HAWB = '" + EV1->EV1_HAWB + "' AND EVB_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EV2->(dbSetOrder(3)) // EV2_FILIAL+EV2_LOTE+EV2_HAWB+EV2_SEQDUI
            if EV2->(dbSeek( xFilial("EV2") + EV1->EV1_LOTE + EV1->EV1_HAWB ))
               cTabela := RetSQLName("EV2")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EV2_FILIAL = '" + xFilial("EV2") + "' AND EV2_HAWB = '" + EV1->EV1_HAWB + "' AND EV2_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EV3->(dbSetOrder(3)) // EV3_FILIAL+EV3_LOTE+EV3_HAWB+EV3_SEQDUI
            if EV3->(dbSeek( xFilial("EV3") + EV1->EV1_LOTE + EV1->EV1_HAWB ))
               cTabela := RetSQLName("EV3")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EV3_FILIAL = '" + xFilial("EV3") + "' AND EV3_HAWB = '" + EV1->EV1_HAWB + "' AND EV3_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EV4->(dbSetOrder(3)) // EV4_FILIAL+EV4_LOTE+EV4_HAWB+EV4_SEQDUI
            if EV4->(dbSeek( xFilial("EV4") + EV1->EV1_LOTE + EV1->EV1_HAWB ))
               cTabela := RetSQLName("EV4")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EV4_FILIAL = '" + xFilial("EV4") + "' AND EV4_HAWB = '" + EV1->EV1_HAWB + "' AND EV4_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EVE->(dbSetOrder(2)) // EVE_FILIAL+EVE_LOTE+EVE_SEQDUI
            if EVE->(dbSeek( xFilial("EVE") + EV1->EV1_LOTE ))
               cTabela := RetSQLName("EVE")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EVE_FILIAL = '" + xFilial("EVE") + "' AND EVE_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EVI->(dbSetOrder(2)) // EVI_FILIAL+EVI_LOTE+EVI_HAWB+EVI_SEQDUI
            if EVI->(dbSeek( xFilial("EVI") + EV1->EV1_LOTE + EV1->EV1_HAWB ))
               cTabela := RetSQLName("EVI")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EVI_FILIAL = '" + xFilial("EVI") + "' AND EVI_HAWB = '" + EV1->EV1_HAWB + "' AND EVI_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            EV6->(dbSetOrder(3)) // EV6_FILIAL+EV6_LOTE+EV6_HAWB+EV6_SEQDUI
            if EV6->(dbSeek( xFilial("EV6") + EV1->EV1_LOTE + EV1->EV1_HAWB ))
               cTabela := RetSQLName("EV6")
               ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EV6_FILIAL = '" + xFilial("EV6") + "' AND EV6_HAWB = '" + EV1->EV1_HAWB + "' AND EV6_LOTE = '" + EV1->EV1_LOTE + "'")
            endif

            cTabela := RetSQLName("EV1")
            ExecSql(cTabela, "UPDATE " + cTabela + " SET D_E_L_E_T_ = '*', R_E_C_D_E_L_ = R_E_C_N_O_ WHERE EV1_FILIAL = '" + xFilial("EV1") + "' AND EV1_HAWB = '" + EV1->EV1_HAWB + "' AND EV1_LOTE = '" + EV1->EV1_LOTE + "'")
            
         end transaction

      endif

   endif
   _nRecEV1 := 0

return .T.

/*
Função     : ExecSql
Objetivo   : Função para realizar um comando direto no banco de dados
Parâmetro  :
Retorno    : .T. ou .F. se validou
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function ExecSql(cTabela, cSqlExec)
   local nExec := 0

   default cTabela   := ""
   default cSqlExec  := ""

   if !empty(cTabela) .and. !empty(cSqlExec)
      nExec := TCSqlExec(cSqlExec)
      TCRefresh( cTabela )
   endif

return nExec

/*
Função     : DU100PVldModel
Objetivo   : Função para validação do commit do modelo (TUDOOK)
Parâmetro  :
Retorno    : .T. ou .F. se validou
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function DU100PVldModel(oModelo)
   local aArea      := getArea()
   local lRet       := .F.
   local nOpc       := 0
   local oModelEV1  := nil
   local cSequencia := ""
   local cLastSeq   := ""
   local cMsg       := ""

   begin sequence

      nOpc := oModelo:GetOperation()
      if nOpc == MODEL_OPERATION_DELETE // avaliar se tambem será validado na opção de alteração (reenviar)

         oModelEV1 := oModelo:GetModel("EV1MASTER")
         cSequencia := oModelEV1:getValue("EV1_SEQUEN")
         cLastSeq := GetSql(oModelEV1:getValue("EV1_HAWB"))
         if !cSequencia == cLastSeq
            cMsg := if( nOpc == MODEL_OPERATION_DELETE , StrTran( STR0017, "###", STR0019 )  , StrTran( STR0017, "###", STR0018 ) ) // "Só será permitido ### da última sequência do Embarque." ### "alteração" ### "exclusão"
            EasyHelp(STR0016, STR0014, cMsg ) // "Registro inválido." ### "Atenção" ### 
            break
         endif

      endif

      lRet := .T.

   end sequence

   restArea(aArea)

return lRet

/*
Função     : GetInfDet
Objetivo   : Busca informação de tabela para preenchimento de grid
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function GetInfDet(oModelo, cIdModel, cIdView, cHawb, oModelSWV, oModelEV3, oModelEV4, oModelEVE, oModelEVI, oModelEV6)
   local aArea      := {}
   local oModelDet  := nil
   local aConfig    := {}
   local aAreaSW6   := {}
   local aAreaSWV   := {}   
   local aProformas := {}
   local nTamSeq    := 0
   local nTamCodIn  := 0
   local nTamDocTo  := 0
   local aCposLoad  := {}
   local cAliasQry  := ""
   local lAddLine   := .F.
   local aAreaEIG   := {}
   local aCfgEV3    := {}
   local aCfgEV4    := {}
   local aCfgEVE    := {}
   local aCfgEVI    := {}
   local aCfgEV6    := {}
   local oModelEV2MC:= nil
   local oGrdEV2MC  := nil
   local aCpoEV2MC  := {}
   local oModelEV2FF:= nil
   local oGrdEV2FF  := nil
   local aCpoEV2FF  := {}
   local oModelEV2CV:= nil
   local oGrdEV2CV  := nil
   local aCpoEV2CV  := {}   
   local oModelEV1  := nil
   local lEIJ       := .F.
   local oMdlEV2II  := nil 
   local oGrdEV2II  := nil
   local aCpoEV2II  := {}
   local oMdlEV2IPI := nil
   local oGrdEV2IPI := nil
   local aCpoEV2IPI := {}
   local oMdlEV2PCO := nil
   local oGrdEV2PCO := nil
   local aCpoEV2PCO := {}
   local oMdlEV2TRB := nil
   local oGrdEV2TRB := nil
   local aCpoEV2TRB := {}

   default oModelo    := FWModelActive()
   default cIdModel   := ""
   default cIdView    := ""
   default cHawb      := ""

   if !empty(cIdModel) .and. !valtype(oModelo) == "U"

      oModelDet := oModelo:GetModel(cIdModel)

      if cIdModel == "EVBDETAIL" .or. cIdModel == "EV9DETAIL" .or. cIdModel == "SWVDETAIL"
         aArea := getArea()
         aConfig := gUpdDelIns(oModelDet)
      endif

      if !empty(cHawb)

         oModelDet:DelAllline()
         oModelDet:ClearData(.F., .T.)

         do case
            case cIdModel == "EVBDETAIL"

               aAreaEIG := EIG->(getArea())
               EIG->(dbSetOrder(1))
               if EIG->(dbSeek( xFilial("EIG") + cHawb))
                  lAddLine := .F.
                  Do While EIG->(!Eof()) .and. EIG->EIG_FILIAL == xFilial("EIG") .and. EIG->EIG_HAWB == cHawb
                     aCposLoad := {}
                     aAdd( aCposLoad, {"EVB_CODPV", EIG->EIG_CODIGO } )
                     aAdd( aCposLoad, {"EVB_DESPV", EIG->EIG_NUMERO } )
                     AddLine(oModelDet, aCposLoad, lAddLine)
                     lAddLine := .T.
                     EIG->(DbSkip())                   
                  EndDo
               endif
               restArea(aAreaEIG)

            case cIdModel == "EV9DETAIL"

               aAreaSW6 := SW6->(getArea())
               SW6->(dbSeek( xFilial("SW6") + cHawb))

               nTamSeq := getSX3Cache("EV9_SEQUEN", "X3_TAMANHO")
               nTamCodIn := getSX3Cache("EV9_CODIN", "X3_TAMANHO")
               nTamDocTo := getSX3Cache("EV9_DOCTO", "X3_TAMANHO")

               /// ***********************************************
               // Carregando 30 - Conhecimento de Embarque
               if !empty(SW6->W6_HOUSE)
                  aCposLoad := {}
                  lAddLine := .F.
                  aAdd( aCposLoad, {"EV9_SEQUEN", StrZero(1, nTamSeq) } )
                  aAdd( aCposLoad, {"EV9_CODIN", PadR("30", nTamCodIn) } )
                  aAdd( aCposLoad, {"EV9_DOCTO", PadR(SW6->W6_HOUSE, nTamDocTo)} )
                  AddLine(oModelDet, aCposLoad, lAddLine)
               endif
               /// ***********************************************

               /// ***********************************************
               // Carregando 49 - Fatura Comercial
               cAliasQry := getNextAlias()
               beginSQL Alias cAliasQry
                  SELECT DISTINCT SW9.W9_INVOICE INVOICE
                  FROM %table:SW9% SW9
                  WHERE SW9.%notDel%
                     AND SW9.W9_FILIAL = %xfilial:SW9%
                     AND SW9.W9_HAWB = %Exp:cHawb% 
               endSql

               (cAliasQry)->(dbGoTop())
               lAddLine := !empty(SW6->W6_HOUSE)
               nSeq := 1
               while (cAliasQry)->(!eof())
                  aCposLoad := {}
                  aAdd( aCposLoad, {"EV9_SEQUEN", StrZero(nSeq, nTamSeq) } )
                  aAdd( aCposLoad, {"EV9_CODIN", PadR("49", nTamCodIn) } )
                  aAdd( aCposLoad, {"EV9_DOCTO", PadR((cAliasQry)->INVOICE, nTamDocTo)} )
                  
                  AddLine(oModelDet, aCposLoad, lAddLine )
                  lAddLine := .T.
                  nSeq += 1
                  (cAliasQry)->(dbSkip())
               end
               (cAliasQry)->(DBCloseArea())
               /// ***********************************************

               /// ***********************************************
               // Carregando 50 - Fatura Proforma
               aProformas := {}
               nSeq := 1
               cAliasQry := getNextAlias()
               beginSQL Alias cAliasQry
                  SELECT DISTINCT EW0.EW0_NR_PRO
                  FROM %table:SW7% SW7
                     INNER JOIN %table:EW0% EW0 ON EW0.%notDel% 
                        AND EW0.EW0_FILIAL = %xfilial:EW0%
                        AND EW0.EW0_PO_NUM = SW7.W7_PO_NUM
                        AND EW0.EW0_POSICA = SW7.W7_POSICAO
                  WHERE SW7.%notDel%  
                     AND SW7.W7_FILIAL = %xfilial:SW7%
                     AND SW7.W7_HAWB = %Exp:cHawb% 
               endSql

               (cAliasQry)->(dbGoTop())
               lAddLine := !empty(SW6->W6_HOUSE) .or. lAddLine
               while (cAliasQry)->(!eof())
                  aAdd( aProformas, (cAliasQry)->EW0_NR_PRO )
                  aCposLoad := {}
                  aAdd( aCposLoad, {"EV9_SEQUEN", StrZero(nSeq, nTamSeq) } )
                  aAdd( aCposLoad, {"EV9_CODIN", PadR("50", nTamCodIn) } )
                  aAdd( aCposLoad, {"EV9_DOCTO", PadR((cAliasQry)->EW0_NR_PRO, nTamDocTo)} )
                  AddLine(oModelDet, aCposLoad, lAddLine)
                  lAddLine := .T.
                  nSeq += 1
                  (cAliasQry)->(dbSkip())
               end
               (cAliasQry)->(DBCloseArea())

               cAliasQry := getNextAlias()
               beginSQL Alias cAliasQry
                  SELECT DISTINCT SW2.W2_NR_PRO
                  FROM %table:SW7% SW7
                     INNER JOIN %table:SW3% SW3 ON SW3.%notDel% 
                        AND SW3.W3_FILIAL = %xfilial:SW3%
                        AND SW3.W3_PO_NUM = SW7.W7_PO_NUM
                        AND SW3.W3_POSICAO = SW7.W7_POSICAO
                     INNER JOIN %table:SW2% SW2 ON SW2.%notDel% 
                        AND SW2.W2_FILIAL = %xfilial:SW2%
                        AND SW2.W2_PO_NUM = SW3.W3_PO_NUM
                  WHERE SW7.%notDel%  
                     AND SW7.W7_FILIAL = %xfilial:SW7%
                     AND SW7.W7_HAWB = %Exp:cHawb% 
               endSql

               (cAliasQry)->(dbGoTop())
               lAddLine := !empty(SW6->W6_HOUSE) .or. lAddLine
               while (cAliasQry)->(!eof())
                  if !empty((cAliasQry)->W2_NR_PRO) .and. aScan( aProformas, { |X| alltrim(X) == alltrim((cAliasQry)->W2_NR_PRO)} ) == 0
                     aCposLoad := {}
                     aAdd( aCposLoad, {"EV9_SEQUEN", StrZero(nSeq, nTamSeq) } )
                     aAdd( aCposLoad, {"EV9_CODIN", PadR("50", nTamCodIn) } )
                     aAdd( aCposLoad, {"EV9_DOCTO", PadR( (cAliasQry)->W2_NR_PRO , nTamDocTo)} )
                     AddLine(oModelDet, aCposLoad, lAddLine)
                     lAddLine := .T.
                     nSeq += 1
                  endif
                  (cAliasQry)->(dbSkip())
               end
               (cAliasQry)->(DBCloseArea())

               restArea(aAreaSW6)
               /// ***********************************************
            case cIdModel == "SWVDETAIL"
               aAreaSWV := SWV->(getArea())
               SWV->(dbSetOrder(1))
               if SWV->(dbSeek( xFilial("SWV") + cHawb))

                  oModelEV3 := oModelo:GetModel("EV3DETAIL")
                  aCfgEV3 := gUpdDelIns(oModelEV3)

                  oModelEV4 := oModelo:GetModel("EV4DETAIL")
                  aCfgEV4 := gUpdDelIns(oModelEV4)

                  oModelEVE := oModelo:GetModel("EVEDETAIL")
                  aCfgEVE := gUpdDelIns(oModelEVE)

                  oModelEVI := oModelo:GetModel("EVIDETAIL")
                  aCfgEVI := gUpdDelIns(oModelEVI)

                  oModelEV6 := oModelo:GetModel("EV6DETAIL")
                  aCfgEV6 := gUpdDelIns(oModelEV6)

                  oModelEV2MC := oModelo:GetModel("EV2MSTR_MC") 
                  oGrdEV2MC := oModelEV2MC:getStruct()
                  aCpoEV2MC := oGrdEV2MC:GetFields()

                  oModelEV2FF := oModelo:GetModel("EV2MSTR_FF") 
                  oGrdEV2FF := oModelEV2FF:getStruct()
                  aCpoEV2FF := oGrdEV2FF:GetFields()

                  oModelEV2CV := oModelo:GetModel("EV2MSTR_CV") 
                  oGrdEV2CV := oModelEV2CV:getStruct()
                  aCpoEV2CV := oGrdEV2CV:GetFields()

                  if DUIMP2310()
                     oMdlEV2II := oModelo:GetModel("EV2MSTR_TRIB_II") 
                     oGrdEV2II := oMdlEV2II:getStruct()
                     aCpoEV2II := oGrdEV2II:GetFields()

                     oMdlEV2IPI := oModelo:GetModel("EV2MSTR_TRIB_IPI") 
                     oGrdEV2IPI := oMdlEV2IPI:getStruct()
                     aCpoEV2IPI := oGrdEV2IPI:GetFields()

                     oMdlEV2PCO := oModelo:GetModel("EV2MSTR_TRIB_PISCOFINS") 
                     oGrdEV2PCO := oMdlEV2PCO:getStruct()
                     aCpoEV2PCO := oGrdEV2PCO:GetFields()

                     oMdlEV2TRB := oModelo:GetModel("EV2MSTR_TRIB_OBS") 
                     oGrdEV2TRB := oMdlEV2TRB:getStruct()
                     aCpoEV2TRB := oGrdEV2TRB:GetFields()
                  endif

                  oModelSWV := oModelo:GetModel("SWVDETAIL") 
                  oModelEV1 := oModelo:GetModel("EV1MASTER")

                  oModelDet:SetMaxLine(10000) // avaliar se tem necessidade de verificar a quantidade de item no processo do embarque
                  lAddLine := .F.
                  Do While SWV->(!Eof()) .and. SWV->WV_FILIAL == xFilial("SWV") .and. SWV->WV_HAWB == cHawb
                     aCposLoad := {}
                     LP500GetInfo("EIJ",3,xFilial("EIJ") + SWV->WV_HAWB + SWV->WV_ID,"EIJ_IDWV")
                     lEIJ := SWV->WV_ID == EIJ->EIJ_IDWV
                     aAdd( aCposLoad, {"WV_HAWB"   , SWV->WV_HAWB} )
                     aAdd( aCposLoad, {"WV_SEQDUIM", SWV->WV_SEQDUIM} )
                     aAdd( aCposLoad, {"WV_ID"     , SWV->WV_ID} )                     
                     aAdd( aCposLoad, {"WV_INVOICE", SWV->WV_INVOICE} )
                     aAdd( aCposLoad, {"WV_FORN"   , SWV->WV_FORN} )
                     aAdd( aCposLoad, {"WV_NOMEFOR", LP500GetInfo("SA2",1,xFilial("SA2") + SWV->WV_FORN + SWV->WV_FORLOJ,"A2_NREDUZ")} )
                     aAdd( aCposLoad, {"WV_FORLOJ" , SWV->WV_FORLOJ} )
                     aAdd( aCposLoad, {"WV_PO_NUM" , SWV->WV_PO_NUM} )
                     aAdd( aCposLoad, {"WV_POSICAO", SWV->WV_POSICAO} )
                     aAdd( aCposLoad, {"WV_COD_I"  , SWV->WV_COD_I} )
                     aAdd( aCposLoad, {"WV_DESC_DI", Left( if( lEIJ, EIJ->EIJ_DSCCIT, ""),AvSx3("WV_DESC_DI", AV_TAMANHO))} )
                     aAdd( aCposLoad, {"WV_NCM"    , LP500GetInfo("SW8",6,xFilial("SW8") + SWV->WV_HAWB + SWV->WV_INVOICE + SWV->WV_PO_NUM + SWV->WV_POSICAO + SWV->WV_PGI_NUM,"W8_TEC")} ) 
                     aAdd( aCposLoad, {"WV_SEQUENC", SWV->WV_SEQUENC} )
                     aAdd( aCposLoad, {"WV_QTDE"   , SWV->WV_QTDE} )
                     aAdd( aCposLoad, {"WV_LOTE"   , SWV->WV_LOTE} )
                     aAdd( aCposLoad, {"WV_DT_VALI", SWV->WV_DT_VALI} )
                     aAdd( aCposLoad, {"WV_DFABRI" , SWV->WV_DFABRI} )
                     aAdd( aCposLoad, {"WV_OBS"    , SWV->WV_OBS} )
                     aAdd( aCposLoad, {"WV_PGI_NUM", SWV->WV_PGI_NUM})

                     AddLine(oModelDet, aCposLoad, lAddLine)
                     lAddLine := .T.
                     if lEIJ
                        DU100EV2Inc(oModelEV2MC, aCpoEV2MC, oModelEV2FF, aCpoEV2FF, oModelEV2CV, aCpoEV2CV, oModelSWV, oModelEV1, oMdlEV2II, aCpoEV2II, oMdlEV2IPI, aCpoEV2IPI, oMdlEV2PCO, aCpoEV2PCO, oMdlEV2TRB, aCpoEV2TRB )
                     endif
                     GetInfDet(oModelo,"EV3DETAIL",,cHawb, oModelDet, oModelEV3, oModelEV4) // Acréscimos e deduções
                     GetInfDet(oModelo,"EVEDETAIL",,cHawb, oModelDet, , , oModelEVE) // LPCO's
                     GetInfDet(oModelo,"EVIDETAIL",,cHawb, oModelDet, , , , oModelEVI) // Certificado Mercosul
                     GetInfDet(oModelo,"EV6DETAIL",,cHawb, oModelDet, , , , , oModelEV6) // Documentos Vinculados

                     SWV->(DbSkip())
                  EndDo

               endif

               sUpdDelIns(oModelEV3, aCfgEV3)
               sUpdDelIns(oModelEV4, aCfgEV4)
               sUpdDelIns(oModelEVE, aCfgEVE)
               sUpdDelIns(oModelEVI, aCfgEVI)
               sUpdDelIns(oModelEV6, aCfgEV6)

               restArea(aAreaSWV)

            case cIdModel == "EV3DETAIL"
               oModelEV4 := oModelo:GetModel("EV4DETAIL")
               oModelEV4:DelAllline()
               oModelEV4:ClearData(.F., .T.)
               LoadEV3EV4(oModelSWV, oModelEV3, oModelEV4)

            case cIdModel == "EVEDETAIL"
               LoadEVE(oModelSWV, oModelEVE)

            case cIdModel == "EVIDETAIL"
               LoadEVI(oModelSWV, oModelEVI)

            case cIdModel == "EV6DETAIL"
               LoadEV6(oModelSWV, oModelEV6)

         end case

      endif

      oModelDet:GoLine(1)
      if cIdModel == "EVBDETAIL" .or. cIdModel == "EV9DETAIL" .or. cIdModel == "SWVDETAIL"
         sUpdDelIns(oModelDet, aConfig)
         restArea(aArea)
      endif

   endif

return nil

/*
Função     : sUpdDelIns
Objetivo   : Verifica a permissão de inclusão, alteração ou exclusão da grid
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function gUpdDelIns(oModelDet)
   local aRet       := {}
   local lNoInsLine := .F.
   local lNoUpdLine := .F.
   local lNoDelLine := .F.

   if !oModelDet:CanInsertLine()
      oModelDet:SetNoInsertLine(.F.)
      lNoInsLine := .T.
   endif

   if !oModelDet:CanUpdateLine()
      oModelDet:SetNoUpdateLine(.F.)
      lNoUpdLine := .T.
   endif

   if !oModelDet:CanDeleteLine()
      oModelDet:SetNoDeleteLine(.F.)
      lNoDelLine := .T.
   endif
   aRet := {lNoInsLine,lNoUpdLine,lNoDelLine}

return aRet

/*
Função     : sUpdDelIns
Objetivo   : Atualiza a permissão de inclusão, alteração ou exclusão da grid
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function sUpdDelIns(oModelDet, aConfig)

   default aConfig   := {.F.,.F.,.F.}

   oModelDet:SetNoInsertLine(aConfig[1])
   oModelDet:SetNoUpdateLine(aConfig[2])
   oModelDet:SetNoDeleteLine(aConfig[3])

return

/*
Função     : AddLine
Objetivo   : Adiciona uma linha no grid
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function AddLine(oModelDet, aCposLoad, lAddLine)
   local nCpo      := 0

   default lAddLine := .F.

   if lAddLine
      oModelDet:AddLine()
   endif

   for nCpo := 1 to Len(aCposLoad)
      oModelDet:LoadValue( aCposLoad[nCpo][1], aCposLoad[nCpo][2] )
   next

return

/*
Objetivo   : Função para carregar dados na tabela EV2
Retorno    : Nil
Autor      : Maurício Frison
Data       : Março/2022
Revisão    :
*/
Static Function DU100EV2Load(oModel)
   Local aFilCpos      := {}
   Local oMdl          := oModel:GetModel()	// Carrega Model Master
   Local oGrdEV2MC    :=  oModel:getStruct() 
   Local oModelSWV     := oMdl:GetModel("SWVDETAIL") 
   Local oModelEV1     := oMdl:GetModel("EV1MASTER")  
   Local oModelEV2MC   := oMdl:GetModel("EV2MSTR_MC")           
   Local aCpoEV2       := {}
   Local nContCpo      := 0
   Local cCampo        := ""
   aCpoEV2 := oGrdEV2MC:GetFields()

   cChaveEV2 := xFilial("EV2") + oModelEV1:GetValue("EV1_LOTE")  + oModelSWV:GetValue("WV_HAWB") + "" + oModelSWV:GetValue("WV_SEQDUIM") 
   EV2->(DbSetOrder(3))
   If EV2->(DbSeek( cChaveEV2  ))
      For nContCpo := 1 to Len(aCpoEV2)
          //trata campos virtual quando houver na tabela
          //aAdd( aFilCpos ,  If( GetSx3Cache( aCpoEV2[nContCpo][3], "X3_CONTEXT") <> "V"  ,  EV2->&(aCpoEV2[nContCpo][3]) ,  LoadCpoVir(aCpoEV2[nContCpo][3],"EV2")   )     )
         cCampo := aCpoEV2[nContCpo][3]          
         aAdd( aFilCpos , iif(oModel:cid $ "EV2MSTR_FF|EV2MSTR_CV|EV2MSTR_TRIB_II|EV2MSTR_TRIB_IPI|EV2MSTR_TRIB_PISCOFINS|EV2MSTR_TRIB_OBS", oModelEV2MC:getValue(cCampo), EV2->&(aCpoEV2[nContCpo][3])))
      Next nContCpo
   EndIf   
Return aFilCpos

/*
Objetivo   : Função para carregar dados na tabela EV2MC
Retorno    : Nil
Autor      : Maurício Frison
Data       : Março/2022
Revisão    :
*/
Static Function DU100EV2Inc(oModelEV2MC, aCpoEV2MC, oModelEV2FF, aCpoEV2FF, oModelEV2CV, aCpoEV2CV, oModelSWV, oModelEV1, oMdlEV2II, aCpoEV2II, oMdlEV2IPI, aCpoEV2IPI, oMdlEV2PCO, aCpoEV2PCO, oMdlEV2TRB, aCpoEV2TRB )
   Local nContCpo      := 0
   Local cCampo        := ""   

   For nContCpo := 1 to Len(aCpoEV2MC)
      cCampo := aCpoEV2MC[nContCpo][3]
      oModelEV2MC:loadValue(cCampo,GetValor(cCampo,oModelSWV,oModelEV1))
   Next nContCpo

   For nContCpo := 1 to Len(aCpoEV2FF)
      cCampo := aCpoEV2FF[nContCpo][3]
      oModelEV2FF:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
   Next nContCpo

   For nContCpo := 1 to Len(aCpoEV2CV)
      cCampo := aCpoEV2CV[nContCpo][3]
      oModelEV2CV:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
   Next nContCpo

   if DUIMP2310()
      For nContCpo := 1 to Len(aCpoEV2II)
         cCampo := aCpoEV2II[nContCpo][3]
         oMdlEV2II:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
      Next nContCpo
      For nContCpo := 1 to Len(aCpoEV2IPI)
         cCampo := aCpoEV2IPI[nContCpo][3]
         oMdlEV2IPI:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
      Next nContCpo
      For nContCpo := 1 to Len(aCpoEV2PCO)
         cCampo := aCpoEV2PCO[nContCpo][3]
         oMdlEV2PCO:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
      Next nContCpo
      For nContCpo := 1 to Len(aCpoEV2TRB)
         cCampo := aCpoEV2TRB[nContCpo][3]
         oMdlEV2TRB:loadValue(cCampo,oModelEV2MC:getValue(cCampo))
      Next nContCpo
   endif

Return 

/*
Função     : GetValor
Objetivo   : Pegar o valor conforme o campo
Retorno    : Retorna o valor
Autor      : Maurício Frison
Data/Hora  : Março/2022
*/
Static Function getValor(cCampo,oModelSWV,oModelEV1)
Local cUnid         := ""
Local cCnpjad      := ""
Local xRet
Do Case
         Case cCampo == "EV2_FILIAL"
            xRet:= xFilial("EV2")
         Case cCampo == "EV2_HAWB"
            xRet:= oModelSWV:GetValue("WV_HAWB")
         Case cCampo == "EV2_IDPTCP"   
            xRet:= EIJ->EIJ_IDPTCP
         Case cCampo == "EV2_VRSACP"
            xRet:= EIJ->EIJ_VRSACP
         Case cCampo == "EV2_CNPJRZ"                               
            xRet:= GetCNPJ( oModelSWV:GetValue("WV_NCM"), EIJ->EIJ_IDPTCP, EIJ->EIJ_VRSACP) 
         Case cCampo == "EV2_VINCCO"
            xRet:= EIJ->EIJ_VINCCO
         Case cCampo == "EV2_APLME"
            xRet:= EIJ->EIJ_APLICM
         Case cCampo = "EV2_MATUSA"
            xRet:= EIJ->EIJ_MATUSA
         Case cCampo == "EV2_DSCCIT"
            xRet:= EIJ->EIJ_DSCCIT
         Case cCampo == "EV2_IMPCO"
            xRet:= SW6->W6_IMPCO
         Case cCampo == "EV2_CNPJAD" 
              If SW6->W6_IMPCO=="1"
                 LP500GetInfo("SW2",1,xFilial("SW2") + SWV->WV_PO_NUM,"W2_CLIENTE")
                 cCnpjad  := LP500GetInfo("SA1",1,xFilial("SA1") + SW2->W2_CLIENTE + SW2->W2_CLILOJ,"A1_CGC")
              EndIf   
              xRet:= cCnpjad
         Case cCampo == "EV2_NMCOM"
            cUnid :=  LP500GetInfo("SW8",6,xFilial("SW8") + oModelSWV:GETVALUE("WV_HAWB") + oModelSWV:GETVALUE("WV_INVOICE") + oModelSWV:GETVALUE("WV_PO_NUM") + oModelSWV:GETVALUE("WV_POSICAO") + oModelSWV:GETVALUE("WV_PGI_NUM") ,"W8_UNID")
            xRet:= LP500GetInfo("SAH",1,xFilial("SAH") + cUnid,"AH_DESCPO")
         Case cCampo == "EV2_QTCOM"
            xRet:= transform(SWV->WV_QTDE,GetSX3Cache("WV_QTDE","X3_PICTURE")) 
         Case cCampo == "EV2_QT_EST"
            xRet:= transform(EIJ->EIJ_QT_EST,GetSX3Cache("EIJ_QT_EST","X3_PICTURE"))
         Case cCampo == "EV2_PESOL"
            xRet:= transform(EIJ->EIJ_PESOL,GetSX3Cache("EIJ_PESOL","X3_PICTURE")) 
         Case cCampo == "EV2_MOE1"
            xRet:= getMoeda(EIJ->EIJ_MOEDA) // POSICIONE("SYF",1,xFilial("SYF") + EIJ->EIJ_MOEDA,"YF_COD_GI")
         Case cCampo == "EV2_VLMLE"
            xRet:= transform(EIJ->EIJ_VLMLE,GetSX3Cache("EIJ_VLMLE","X3_PICTURE")) 
         Case cCampo == "EV2_LOTE"
            xRet:= oModelEV1:GetValue("EV1_LOTE") 
         Case cCampo == "EV2_SEQDUI"
            xRet:= oModelSWV:GetValue("WV_SEQDUIM")
         Case cCampo == "EV2_FABFOR"
            xRet:= EIJ->EIJ_FABFOR
         Case cCampo == "EV2_TINFA"
            xRet:= EIJ->EIJ_TINFA            
         Case cCampo == "EV2_VRSFAB"         
            xRet:= EIJ->EIJ_VRSFAB
         Case cCampo == "EV2_PAIOME"         
            xRet:= GetPais(EIJ->EIJ_PAISOR)
         Case cCampo == "EV2_TINFO"  
            xRet:= EIJ->EIJ_TINFO
         Case cCampo == "EV2_VRSFOR"           
            xRet:= EIJ->EIJ_VRSFOR
         Case cCampo == "EV2_PAISPR"                    
            xRet:= GetPais(EIJ->EIJ_PAISPR)
         Case cCampo == "EV2_METVAL" 
            xRet:= EIJ->EIJ_METVAL
         Case cCampo == "EV2_INCOTE" 
            xRet:= EIJ->EIJ_INCOTE
         Case cCampo == "EV2_TIPCOB" 
            xRet:= EIJ->EIJ_TIPCOB
         Case cCampo == "EV2_NRROF" 
            xRet:= EIJ->EIJ_NRROF
         Case cCampo == "EV2_INSTFI" 
            xRet:= EIJ->EIJ_INSTFI
         Case cCampo == "EV2_MOTIVO"
            xRet:= EIJ->EIJ_MOTIVO
         Case cCampo == "EV2_VL_FIN"
            xRet:= transform(EIJ->EIJ_VL_FIN,AvSX3("EIJ_VLMLE",AV_PICTURE)) 
         otherwise
            xRet := criavar(cCampo)

ENDCASE
return xRet

/*
Função     : LoadEV3EV4
Objetivo   : Carrega a grid da EV3 e EV4 - Acréscimos e Deduções
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function LoadEV3EV4(oModelSWV, oModelEV3, oModelEV4)
   local aAreaEIN   := {}
   local cChaveEIN  := ""
   local aCposLoad  := {}
   local cPicture   := ""
   local cValor     := ""
   local cTipo      := ""
   local lAddLinEV3 := .F.
   local lAddLinEV4 := .F.

   dbSelectArea("EIN")
   aAreaEIN := EIN->(getArea())
   cChaveEIN := xFilial("EIN") + oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_ID")

   EIN->(dbSetOrder(2)) // EIN_FILIAL+EIN_HAWB+EIN_IDWV+EIN_TIPO
   if EIN->(dbSeek( cChaveEIN ))

      cPicture := GetSX3Cache("EIN_VLMLE","X3_PICTURE")
      while EIN->(!eof()) .and. (EIN->(EIN_FILIAL+EIN_HAWB+EIN_IDWV)) == cChaveEIN

         cValor := transform(EIN->EIN_VLMLE,cPicture) 
         cTipo := alltrim(EIN->EIN_TIPO)
         aCposLoad := {}

         if cTipo == "1" // Acréscimos

            aAdd( aCposLoad, {"EV3_MOE"   , EIN->EIN_FOBMOE} )
            aAdd( aCposLoad, {"EV3_VLMLE" , cValor} )
            aAdd( aCposLoad, {"EV3_ACRES" , EIN->EIN_CODIGO} )
            AddLine(oModelEV3, aCposLoad, lAddLinEV3)
            lAddLinEV3 := .T.

         elseif cTipo == "2" // Deduções

            aAdd( aCposLoad, {"EV4_MOE"   , EIN->EIN_FOBMOE} )
            aAdd( aCposLoad, {"EV4_VLMLE" , cValor} )
            aAdd( aCposLoad, {"EV4_DEDU" , EIN->EIN_CODIGO} )
            AddLine(oModelEV4, aCposLoad, lAddLinEV4)
            lAddLinEV4 := .T.

         endif

         EIN->(dbSkip())
      end

   endif

   restArea(aAreaEIN)

return

/*
Função     : LoadEVE
Objetivo   : Carrega a grid da EVE - LPCO's
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function LoadEVE(oModelSWV, oModelEVE)
   local aAreaEKQ   := {}
   local cChaveEKQ  := ""
   local aCposLoad  := {}
   local lAddLinEVE := .F.
   local aDados     := {}

   dbSelectArea("EKQ")
   aAreaEKQ := EKQ->(getArea())

   EKQ->(dbSetOrder(1)) // EKQ_FILIAL+EKQ_HAWB+EKQ_INVOIC+EKQ_PO_NUM+EKQ_POSICA+EKQ_SEQUEN+EKQ_ORGANU+EKQ_FRMLPC
   cChaveEKQ := xFilial("EKQ") + oModelSWV:GetValue("WV_HAWB")  + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC")

   if EKQ->(dbSeek( cChaveEKQ ))
 
      while EKQ->(!eof()) .and. (EKQ->(EKQ_FILIAL+EKQ_HAWB+EKQ_INVOIC+EKQ_PO_NUM+EKQ_POSICA+EKQ_SEQUEN)) == cChaveEKQ

         if !empty(EKQ->EKQ_LPCO) .and. aScan( aDados, { |X| X == EKQ->EKQ_LPCO } ) == 0
            aCposLoad := {}
            aAdd( aCposLoad, {"EVE_LPCO"   , EKQ->EKQ_LPCO} )
            AddLine(oModelEVE, aCposLoad, lAddLinEVE)
            lAddLinEVE := .T.
            aAdd( aDados , EKQ->EKQ_LPCO)
         endif
         EKQ->(dbSkip())
      end

   endif

   restArea(aAreaEKQ)

return

/*
Função     : LoadEVI
Objetivo   : Carrega a grid da EVI- Certificado Mercosul
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function LoadEVI(oModelSWV, oModelEVI)
   local aAreaEJ9   := {}
   local cChaveEJ9  := ""
   local cPicture   := ""
   local aCposLoad  := {}
   local lAddLinEVI := .F.
 
   dbSelectArea("EJ9")
   aAreaEJ9 := EJ9->(getArea())

   EJ9->(dbSetOrder(2)) // EJ9_FILIAL+EJ9_HAWB+EJ9_IDWV+EJ9_IDCERT+EJ9_DEMERC
   cChaveEJ9 := xFilial("EJ9") + oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_ID")

   if EJ9->(dbSeek( cChaveEJ9 ))

      cPicture := GetSX3Cache("EJ9_QTDCER","X3_PICTURE") 
      while EJ9->(!eof()) .and. (EJ9->(EJ9_FILIAL+EJ9_HAWB+EJ9_IDWV)) == cChaveEJ9

         aCposLoad := {}
         aAdd( aCposLoad, {"EVI_NUM"    , EJ9->EJ9_DEMERC} )
         aAdd( aCposLoad, {"EVI_IDCERT" , EJ9->EJ9_IDCERT} )
         aAdd( aCposLoad, {"EVI_DEMERC" , EJ9->EJ9_DEMERC} )
         aAdd( aCposLoad, {"EVI_QTDCER" , transform(EJ9->EJ9_QTDCER,cPicture) } )
      
         AddLine(oModelEVI, aCposLoad, lAddLinEVI)
         lAddLinEVI := .T.

         EJ9->(dbSkip())
      end

   endif

   restArea(aAreaEJ9)

return

/*
Função     : LoadEV6
Objetivo   : Carrega a grid da EV6 - Documentos Vinculados
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function LoadEV6(oModelSWV, oModelEV6)
   local aAreaEIK   := {}
   local cChaveEIK  := ""
   local aCposLoad  := {}
   local lAddLinEV6 := .F.
 
   dbSelectArea("EIK")
   aAreaEIK := EIK->(getArea())

   EIK->(dbSetOrder(2)) // EIK_FILIAL+EIK_HAWB+EIK_IDWV
   cChaveEIK := xFilial("EIK") + oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_ID")

   if EIK->(dbSeek( cChaveEIK ))

      while EIK->(!eof()) .and. (EIK->(EIK_FILIAL+EIK_HAWB+EIK_IDWV)) == cChaveEIK

         aCposLoad := {}
         aAdd( aCposLoad, {"EV6_TIPVIN" , EIK->EIK_TIPVIN} )
         aAdd( aCposLoad, {"EV6_DOCVIN" , EIK->EIK_DOCVIN } )
         AddLine(oModelEV6, aCposLoad, lAddLinEV6)
         lAddLinEV6 := .T.

         EIK->(dbSkip())
      end

   endif

   restArea(aAreaEIK)

return

/*
Função     : GetMoeda
Objetivo   : Função para retornar o campo YF_ISO, caso esteja preenchido
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function GetMoeda(cMoeda)
   local cRet       := ""
   local cKeySeek   := ""

   default cMoeda := ""

   dbSelectArea("SYF") // YF_FILIAL+YF_MOEDA

   cKeySeek := xFilial("SYF") + cMoeda

   if cKeySeek <> SYF->&(IndexKey())
      SYF->(dbSetOrder(1))
      SYF->(DbSeek( cKeySeek ))
   endif

   cRet := cMoeda
   if SYF->(!eof())
      cRet := if(!empty(SYF->YF_ISO),SYF->YF_ISO,SYF->YF_MOEDA)
   endif

return cRet

/*
Função     : GetPais
Objetivo   : Função para retornar o campo YA_PAISDUE
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function GetPais(cPais)
   local cRet       := ""
   local cKeySeek   := ""

   default cPais := ""

   dbSelectArea("SYA") // YA_FILIAL+YA_CODGI

   cKeySeek := xFilial("SYA") + cPais

   if cKeySeek <> SYA->&(IndexKey())
      SYA->(dbSetOrder(1))
      SYA->(DbSeek( cKeySeek ))
   endif

   if SYA->(!eof())
      cRet := SYA->YA_PAISDUE
   endif

return cRet

/*
Função     : GetCNPJ
Objetivo   : Função para retornar o campo EKD_CNPJ (Raiz do CNPJ declarante)
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
static function GetCNPJ(cNCM, cIdPortal, cVersao)
   local cRet       := ""
   local cKeySeek   := ""

   default cNCM       := ""
   default cIdPortal  := ""
   default cVersao    := ""

   dbSelectArea("EKD") 

   cKeySeek := xFilial("EKD") + cNCM + cIdPortal + cVersao

   if cKeySeek <> EKD->&(IndexKey())
      EKD->(dbSetOrder(2)) // EKD_FILIAL + EKD_NCM + EKD_IDPORT + EKD_VERSAO
      EKD->(DbSeek( cKeySeek ))
   endif

   if EKD->(!eof())
      cRet := EKD->EKD_CNPJ
   endif

return cRet

/*
Função     : DU100VdSW6
Objetivo   : Função para validar se irá prosseguir com a manutenção do Embarque ou Desembaraço, dependendo do status das tabelas EV's
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
function DU100VdSW6(nRecEV1, cHawb)
   local cAliasSel := alias()
   local lRet      := .T.
   local aAreaEV1  := {}

   default nRecEV1   := 0
   default cHawb     := SW6->W6_HAWB

   dbSelectArea("EV1")
   if EV1->(columnPos("EV1_STATUS")) > 0

      aAreaEV1 := EV1->(getArea())
      EV1->(dbSetOrder(1)) // EV1_FILIAL+EV1_HAWB+EV1_LOTE
      if EV1->(AvSeekLast( xFilial("EV1") + cHawb ))
         if EV1->EV1_STATUS $ PENDENTE_INTEGRACAO + "||" + PENDENTE_REGISTRO
            lRet := MsgYesNo(StrTran( STR0080 , "####", if(EV1->EV1_STATUS $ PENDENTE_INTEGRACAO, "1-" + STR0055, "3-" + STR0057 )), STR0014) // "A declaração deste processo encontra-se com o Status '####'. Ao atualizar os dados, o Status será atualizado para '2-Processo Pendente de Revisão' e devem ser gerados novos registros para integração com o Portal Único. Deseja prosseguir?" ### "Pendente de Integração" ### "Pendente de Registro"
            if lRet
               nRecEV1 := EV1->(recno())
            endif
         endif
      endif
      restArea(aAreaEV1)

   endif

   if !empty(cAliasSel)
      dbSelectArea(cAliasSel)
   endif

return lRet

/*
Função     : DU100AtuEV
Objetivo   : Função para atualizar a tabela EV1
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Abril/2022
Obs.       :
*/
function DU100AtuEV( nRecEV1 , cStatus)
   local cAliasSel := alias()
   local aAreaEV1  := {}

   default nRecEV1   := 0
   default cStatus   := PROCESSO_PENDENTE_REVISAO

   if nRecEV1 > 0 .and. EV1->(columnPos("EV1_STATUS")) > 0

      aAreaEV1 := EV1->(getArea())

      EV1->(dbGoTo(nRecEV1))
      if (EV1->(recno()) == nRecEV1 .and. RecLock("EV1", .F.))
         EV1->EV1_STATUS := cStatus
         EV1->(MsUnLock())
      endif

      restArea(aAreaEV1)

   endif

   if !empty(cAliasSel)
      dbSelectArea(cAliasSel)
   endif

return

/*
Função     : DUIMP2310
Objetivo   : Função para validação do dicionario de dados para DUIMP release 12.1.2310
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function DUIMP2310()
   local lRet := .F.

   if _DIC_22_4 == nil
      _DIC_22_4 := AvFlags("DUIMP_12.1.2310-22.4")
   endif

   lRet := _DIC_22_4

return lRet

/*
Função     : DU100MtArr - Monta Array
Objetivo   : Função para montar um array com os campos para validação
Parâmetro  : cHawb -> Hawb do processo para posicionar as tabelas
Retorno    : Array
Autor      : Nícolas Castellani Brisque
Data/Hora  : Setembro/2022
Obs.       : 
*/
Function DU100MtArr(cHawb)
Local aCampos := {}
     SW6->(DbSeek(xFilial()+cHawb))
     AAdd(aCampos, cHawb)
     AAdd(aCampos, E_MSMM(SW6->W6_COMPLEM,60))
     AAdd(aCampos, SW6->W6_PRCARGA)
     AAdd(aCampos, SW6->W6_HOUSE)
     AAdd(aCampos, SW6->W6_URF_DES)
     AAdd(aCampos, SW6->W6_SEGMOED)
     AAdd(aCampos, SW6->W6_VL_USSE)
     If EIG->(DbSeek(xFilial()+cHawb))
        Do While !EIG->(Eof()) .AND. EIG->EIG_HAWB == cHawb
          AAdd(aCampos, {EIG->EIG_CODIGO, EIG->EIG_NUMERO})
          EIG->(DbSkip())
        EndDo
     EndIf
Return aCampos

/*
Função     : DU100VdAlt - Valida Alteração
Objetivo   : Função para validação de alteração para mudança de status do processo
Parâmetro  : 
Retorno    : Lógico
Autor      : Nícolas Castellani Brisque
Data/Hora  : Setembro/2022
Obs.       : 
*/
Function DU100VdAlt(aValidacao)
Local lRet    := .F.
Local aCampos := {}
Local i

   aCampos := DU100MtArr(aValidacao[1])
   Begin Sequence
   If Len(aCampos) == Len(aValidacao)
      For i := 1 to Len(aCampos)
         If i >= 8
            If aCampos[i][1] != aValidacao[i][1] .or. aCampos[i][2] != aValidacao[i][2]
               lRet := .T.
               Break
            EndIf
         ElseIf aCampos[i] != aValidacao[i]
            lRet := .T.
            Break
         EndIf
      Next
   Else 
      lRet := .T.
   EndIf
   End Sequence

Return lRet