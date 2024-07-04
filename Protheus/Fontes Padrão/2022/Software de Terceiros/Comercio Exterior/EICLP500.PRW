#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "EICLP500.CH"
#INCLUDE "AVERAGE.CH"

#define ENTER CHR(13)+CHR(10)
#define MYCSS "QTableView { selection-background-color: #1C9DBD; }"
#define DUIMP_INTEGRADA "1"

Static  __aLstFrmNCM   := {}
Static  __oQtdSumSWV   := tHashMap():New()
Static  __oLstQtdInf   := tHashMap():New()
static _EIJVERSAO      := VerCampos("EIJ", {"EIJ_VRSFOR", "EIJ_VRSFAB"} )
static _nRecEV1        := 0
static _oSeqHash       := tHashMap():New()
static _lForceAtu      := .F.
static _aCposEKQ       := nil
static _aCposEIJ       := nil
static _aCposEINA      := nil
static _aCposEIND      := nil
static _aCposEIK       := nil
static _aCposEJ9       := nil
static _nSeqDUIMP      := 0
static _DIC_22_4     := nil

/*
Programa   : EICLP500
Objetivo   : Rotina - Vinculação de LPCO/ Itens DUIMP
Retorno    : Nil
Autor      : Ramon Prado
Data/Hora  : Agosto /2021
Obs.       :
*/
Function EICLP500(aCapaAuto,aItensSWVAuto,aItensEKQAuto,nOpcAuto)
   Local aArea         := GetArea()
   Local cFilProc      := xFilial("SW6")
   Local cProcesso     := ""

   Private lLP500Auto   := ValType(aCapaAuto) <> "U" .Or. ValType(aItensSWVAuto) <> "U" .Or. ValType(aItensEKQAuto) <> "U" .Or. ValType(nOpcAuto) <> "U"
   Private aRotina      := {}

   If !lLP500Auto
      oBrowse := FWMBrowse():New() //Instanciando a Classe
      oBrowse:SetAlias("SW6") //Informando o Alias
      oBrowse:SetMenuDef("EICLP500") //Nome do fonte do MenuDef
      oBrowse:SetDescription(STR0001) //"Itens DUIMP"

      //Ativa o Browse
      oBrowse:Activate()
   Else
      If (nPos := aScan(aCapaAuto, {|x| x[1] == "W6_FILIAL" })) > 0
         cFilProc := aCapaAuto[nPos][2]
      EndIf
      If (nPos := aScan(aCapaAuto, {|x| x[1] == "W6_HAWB" })) > 0
         cProcesso := aCapaAuto[nPos][2]
      EndIf

      SW6->(DbSetOrder(1)) //Filial + Hawb
      If !Empty(cProcesso) .And. SW6->(DbSeek(cFilProc+cProcesso))

         aRotina := MenuDef()
         addLinpos(aItensSWVAuto, "SWV")
         addLinpos(aItensEKQAuto, "EKQ")
         FWMVCRotAuto(ModelDef(), "SW6", nOpcAuto, {{"SW6MASTER",aCapaAuto}, {"SWVDETAIL", aItensSWVAuto}, {"EKQDETAIL", aItensEKQAuto}},.T.)
      Else
         lMsErroAuto := .T.
         EasyHelp(STR0019,STR0003/*Atenção*/)
      EndIf
   EndIf

   RestArea(aArea)
Return

/*
Função     : LP500VINC
Objetivo   : Criada originalmente para vinculação de LPCO; convertida para tela de Itens da DUIMP
Retorno    :
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Function LP500VINC()
   Local cTitulo := STR0001 //Itens DUIMP
   Local lTipReg := SW6->(FieldPos("W6_TIPOREG")) > 0
   Local nOpc    := 0
   local lVisual := .F.

   Begin Sequence

      If !lTipReg .Or. SW6->W6_TIPOREG <> "2"
         EasyHelp(STR0005, STR0003, STR0006) //"A rotina 'Itens DUIMP' é indicada apenas para processos do tipo 'DUIMP'.' //"Verifique o conteúdo do campo Tipo de Registro"
         Break
      EndIf

      If SW6->(IsLocked()) .or. !SoftLock("SW6")
         EasyHelp(STR0035,STR0003) //"Registro em uso por outro usuário!" # "Atenção"
         Break
      EndIf

//      SoftLock("SW6")

      If !IsMemVar("lLP500Auto")
         lLP500Auto := .F.
      EndIf

      LP500Atu(.F.)
      lVisual := !empty(SW6->W6_DI_NUM ) .and. !empty(SW6->W6_VERSAO ) .and. !empty(SW6->W6_DTREG_D) .and. !FwIsInCallStack("DI154NFE")
      if lVisual
         EasyHelp(STR0108, STR0003, STR0109) // "A rotina será aberta em modo de visualização." # "Atenção" # "Caso seja necessário realizar alguma atualização nos Itens DUIMP, será necessário remover as informações dos campos do número da DUIMP, sua data de registro e sua versão."
      endif

      nOpc := if( lVisual, MODEL_OPERATION_VIEW, MODEL_OPERATION_UPDATE )
      FWExecView(cTitulo,'EICLP500', nOpc,, { || .T. } )

      SW6->(MsUnlock())

   End Sequence

Return

/*
Função     : ModelDef
Objetivo   : Cria a estrutura a ser usada no Modelo de Dados - Regra de Negocios
Retorno    : oModel
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function ModelDef()
   Local oStruSW6  := FWFormStruct( 1, "SW6", { |x| ALLTRIM(x) $ 'W6_FILIAL|W6_HAWB' })
   Local oMdlEvent := LP500EV():New()
   Local oModel    := nil
   Local bCommit   := {|oModel| LP500COMMIT(oModel)}
   Local bPosVld   := {|oModel| LP500PVldModel( oModel )}
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA

   // Criação do Modelo
   oModel := MPFormModel():New( "EICLP500", /*bPreValidacao*/, bPosVld, bCommit, /*bCancel*/ )
   //Modelo para a tabela SW6 - Chave Principal de relacionamento das tabelas
   oModel:AddFields('SW6MASTER',/*cOwner*/,oStruSW6)
   oModel:SetPrimaryKey( { "W6_FILIAL","W6_HAWB"} )

   //Instala o gerenciador de eventos para validações
   oModel:InstallEvent("LP500EV", , oMdlEvent)

   //Carrega os modelos das tabealas filhas
   SetModSW9(oModel)
   SetModSWV(oModel)
   SetModEKQ(oModel)
   SetModEIJ(oModel)
   SetModEIK(oModel)
   SetModEINA(oModel)
   SetModEIND(oModel)
   SetModEJ9(oModel)
   oModel:SetOptional("EINADETAIL",.T.)
   oModel:SetOptional("EINDDETAIL",.T.)

   if !IsInCallStack("EICLP501")
      SetMSWVTrb(oModel)
      SetModII(oModel)
      SetModIPI(oModel)
      SetModPISCOFINS(oModel)
      SetModICMS(oModel)
      if lDuimpInt .and. DUIMP2310()
         SetMObsTrb(oModel)
      endif
   endif

Return oModel

/*
Função     : SetModSW9
Objetivo   : Cria a instância do model para a tabela SW9 (Dados de capa da Invoice)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModSW9(oModel)
   Local oStruSW9  := FWFormStruct( 1, "SW9", {|x| CheckField(x, EasyStrSplit(LP500Model("SW9"), "|")) })
   Local cOrderBy:= "W9_FILIAL+W9_HAWB+W9_INVOICE+W9_FORN+W9_FORLOJ"

   oModel:AddGrid('SW9DETAIL', 'SW6MASTER', oStruSW9,,,,,)
   oModel:GetModel("SW9DETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("SW9DETAIL"):SetNoDeleteLine(.T.)
   oModel:GetModel("SW9DETAIL"):SetUniqueLine({"W9_FILIAL" ,"W9_HAWB" ,"W9_INVOICE","W9_FORN" ,"W9_FORLOJ"} )
   oModel:SetRelation('SW9DETAIL', {{ 'W9_FILIAL', 'xFilial("SW9")'},;
      { 'W9_HAWB'  , 'W6_HAWB'       }},;
      cOrderBy )

Return Nil


/*
Função     : SetModSWV
Objetivo   : Cria a instância do model para a tabela SWV (Dados de capa do Lote/LPCO)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModSWV(oModel)
   Local oStruSWV      := FWFormStruct( 1, "SWV", {|x| CheckField(x, EasyStrSplit(LP500Model("SWV"), "|")) })
   Local bPreVLnSWV    := {|oGridSWV, nLine, cAction, cCampo, cVlNew, cVlOld| PreVldLSWV(oGridSWV, nLine, cAction, cCampo, cVlNew, cVlOld)}
   Local bPosVLnSWV    := {|oGridSWV, nLine| PosVldLSWV(oGridSWV, nLine)}   
   Local bLoadSuperior := {|oModel| LP500SWVLoad( oModel ) }
   Local cOrderBy:= "WV_FILIAL+WV_HAWB+WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_SEQUENC"

   //STRUCT_FEATURE_VALID
   oStruSWV:SetProperty('WV_SEQDUIM', MODEL_FIELD_VALID, {|a,b,c,d,e| FWInitCpo(a,b,c),lRet:=(LP500VALID(b,a,c,d,e)),FWCloseCpo(a,b,c,lRet),lRet  }) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )

  //STRUCT_FEATURE_WHEN
   oStruSWV:SetProperty('WV_SEQDUIM', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("WV_SEQDUIM")'    )) //Monta When diferente do dicionário

   oStruSWV:AddTrigger("WV_NCM", "WV_NCM",, {|oModel| LP500Gatil("WV_NCM")} )

   oModel:AddGrid('SWVDETAIL', 'SW9DETAIL', oStruSWV, bPreVLnSWV,bPosVlnSWV,,, bLoadSuperior) //aqui MFR

   oModel:GetModel("SWVDETAIL"):SetNoInsertLine(.T.)
   oModel:GetModel("SWVDETAIL"):SetUniqueLine({"WV_FILIAL" ,"WV_HAWB" ,"WV_INVOICE","WV_FORN" ,"WV_FORLOJ","WV_PO_NUM" ,"WV_POSICAO","WV_SEQUENC"} )

   oModel:SetRelation('SWVDETAIL', {   { 'WV_FILIAL'   ,'xFilial("SWV")' },;
      { 'WV_HAWB'     ,'W9_HAWB'        },;
      { 'WV_INVOICE'  ,'W9_INVOICE'     },;
      { 'WV_FORN'     ,'W9_FORN'        },;
      { 'WV_FORLOJ'   ,'W9_FORLOJ'      }},;
      cOrderBy )

Return Nil


/*
Função     : SetModEKQ
Objetivo   : Cria a instância do model para a tabela EKQ (Necessidades de LPCO x N.c.m )
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModEKQ(oModel)
   Local bPreVLnEKQ    := {|oGridEKQ, nLine, cAction| PreVldLEKQ(oGridEKQ, nLine, cAction)}
   Local bPosVLnEKQ    := {|oGridEKQ, nLine, cAction| PosVldLEKQ(oGridEKQ, nLine, cAction)}
   Local bLoadInferior := {|oModel| LP500EKQLoad( oModel ) }
   Local oStruEKQ := FWFormStruct(1, "EKQ", {|x| CheckField(x, EasyStrSplit(LP500Model("EKQ"), "|")) })

   oStruEKQ:SetProperty("EKQ_FILIAL"   , MODEL_FIELD_INIT  , {|| LP500INI('EKQ_FILIAL')})
   oStruEKQ:SetProperty("EKQ_HAWB"     , MODEL_FIELD_INIT  , {|| LP500INI('EKQ_HAWB')})
   oStruEKQ:SetProperty("EKQ_INVOIC"   , MODEL_FIELD_INIT  , {|| LP500INI('EKQ_INVOIC')})
   oStruEKQ:SetProperty("EKQ_PO_NUM"   , MODEL_FIELD_INIT  , {|| LP500INI('EKQ_PO_NUM')})
   oStruEKQ:SetProperty("EKQ_POSICA"   , MODEL_FIELD_INIT  , {|| LP500INI('EKQ_POSICA')})
   oStruEKQ:SetProperty("EKQ_SEQUEN"   , MODEL_FIELD_INIT  , {|| LP500INI('EKQ_SEQUEN')})

   oModel:AddGrid('EKQDETAIL','SWVDETAIL'  ,oStruEKQ, bPreVLnEKQ, bPosVLnEKQ,,, bLoadInferior)

   oModel:SetRelation('EKQDETAIL', {   { 'EKQ_FILIAL'   ,'xFilial("EKQ")'},;
      { 'EKQ_HAWB'     ,'WV_HAWB'       },;
      { 'EKQ_INVOIC'   ,'WV_INVOICE'    },;
      { 'EKQ_PO_NUM'   ,'WV_PO_NUM'     },;
      { 'EKQ_POSICA'   ,'WV_POSICAO'    },;
      { 'EKQ_SEQUEN'   ,'WV_SEQUENC'    }},;
      EKQ->(IndexKey(1)) )

   oModel:GetModel("EKQDETAIL"):SetUniqueLine({"EKQ_FILIAL","EKQ_HAWB","EKQ_INVOIC","EKQ_PO_NUM","EKQ_POSICA","EKQ_SEQUEN","EKQ_ORGANU","EKQ_FRMLPC"} )
   oModel:GetModel("EKQDETAIL"):SetDelAllLine(.T.) //Permite utilizar o método delAllLine para deletar todas as linhas, após deleção da linha do grid de cima(SWV)
   oModel:GetModel("EKQDETAIL"):CanDeleteLine(.T.)

Return Nil

/*
Função     : SetModEIJ
Objetivo   : Cria a instância do model para a tabela EIJ ( Dados de tributação do item )
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModEIJ(oModel)
   Local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJ"), "|")) })
   Local bLoadEIJ := {|oModel| LP500EIJLoad( oModel ) }

   //MODEL_FIELD_OBRIGAT
   oStruEIJ:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )
   //STRUCT_FEATURE_WHEN
   oStruEIJ:SetProperty('EIJ_FABR'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_FABR")'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_FABLOJ', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_FABLOJ")'  )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_PAISOR', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_PAISOR")'  )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_TIPCOB', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TIPCOB")'    ))
   oStruEIJ:SetProperty('EIJ_MODALI', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_MODALI")'    ))
   oStruEIJ:SetProperty('EIJ_MOEDA' , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_MOEDA")'    ))
   oStruEIJ:SetProperty('EIJ_VL_FIN', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_VL_FIN")'    ))
   oStruEIJ:SetProperty('EIJ_MOTIVO', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_MOTIVO")'    ))
   oStruEIJ:SetProperty('EIJ_VRSFOR', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_VRSFOR")'    ))
   oStruEIJ:SetProperty('EIJ_VRSFAB', MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_VRSFAB")'    ))   
   
   //STRUCT_FEATURE_VALID
   oStruEIJ:SetProperty('EIJ_FABR'  , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIJ:SetProperty('EIJ_FABLOJ', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIJ:SetProperty('EIJ_PAISOR', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIJ:SetProperty('EIJ_IDPTCP', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIJ:SetProperty('EIJ_VRSACP', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIJ:SetProperty('EIJ_VRSFOR', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )   
   oStruEIJ:SetProperty('EIJ_VRSFAB', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )      
   //STRUCT_FEATURE_INIPAD
   oStruEIJ:SetProperty('EIJ_FABRVM', MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD,'LP500INI(b,a,c)'         )) //Monta Inicializador Padrão diferente do dicionário
   //TRIGGER
   oStruEIJ:AddTrigger("EIJ_FABR"  , "EIJ_FABLOJ",, {|oModel| LP500Gatil("EIJ_FABR_LOJA"  )} )
   oStruEIJ:AddTrigger("EIJ_FABLOJ", "EIJ_PAISOR",, {|oModel| LP500Gatil("EIJ_FABLOJ_PAISOR")} )
   oStruEIJ:AddTrigger("EIJ_FABLOJ", "EIJ_TINFA" ,, {|oModel| LP500Gatil("EIJ_FABLOJ_TINFA" )} )
   oStruEIJ:AddTrigger("EIJ_FABLOJ", "EIJ_FABRVM",, {|oModel| LP500Gatil("EIJ_FABLOJ_FABRVM")} )

   if _EIJVERSAO .and. DUIMP2310()
      oStruEIJ:AddTrigger("EIJ_FORLOJ", "EIJ_VRSFOR",, {|oModel| LP500Gatil("EIJ_FORLOJ_VRS")} )
      oStruEIJ:AddTrigger("EIJ_FABLOJ", "EIJ_VRSFAB",, {|oModel| LP500Gatil("EIJ_FABLOJ_VRS")} )
      oStruEIJ:AddTrigger("EIJ_IDPTCP", "EIJ_VRSFOR",, {|oModel| LP500Gatil("EIJ_IDPTCP_VRSFOR"  )} )
      oStruEIJ:AddTrigger("EIJ_IDPTCP", "EIJ_VRSFAB",, {|oModel| LP500Gatil("EIJ_IDPTCP_VRSFAB"  )} )
      oStruEIJ:AddTrigger("EIJ_VRSACP", "EIJ_VRSFOR",, {|oModel| LP500Gatil("EIJ_IDPTCP_VRSFOR"  )} )
      oStruEIJ:AddTrigger("EIJ_VRSACP", "EIJ_VRSFAB",, {|oModel| LP500Gatil("EIJ_IDPTCP_VRSFAB"  )} )
   endif

   oModel:AddFields('EIJMASTER',"SWVDETAIL",oStruEIJ,,,bLoadEIJ)

   //Rules - a loja apenas será preenchida após o fabricante
   oModel:addRules('EIJMASTER', 'EIJ_FABLOJ', 'EIJMASTER', 'EIJ_FABR', 3)

   oModel:SetRelation('EIJMASTER', {   { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; //Aviso: Falta tratar a adição (vinculo com o item)
      EIJ->(IndexKey(3)) )

Return Nil

/*
Função     : SetModEIK
Objetivo   : Cria a instância do model para a tabela EIK ( Documentos vinculados )
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModEIK(oModel)
   Local oStruEIK := FWFormStruct( 1, "EIK", {|x| CheckField(x, EasyStrSplit(LP500Model("EIK"), "|")) })
   Local bLoadEIK := {|oModel| LP500EIKLoad( oModel ) }
   Local bPosValid:= {|oGridModel, nLine| PosValEIK(oGridModel, nLine)}
   Local cOrderBy:= "EIK_FILIAL+EIK_HAWB+EIK_IDWV+EIK_TIPVIN+EIK_DOCVIN"

   //MODEL_FIELD_OBRIGAT
   oStruEIK:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )

   //MODEL_FIELD_INIT
   oStruEIK:SetProperty('EIK_FILIAL', MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'LP500INI(b)'          )) //Monta Inicializador Padrão diferente do dicionário
   oStruEIK:SetProperty('EIK_HAWB'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'LP500INI(b)'          )) //Monta Inicializador Padrão diferente do dicionário
   oStruEIK:SetProperty('EIK_IDWV'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'LP500INI(b)'          )) //Monta Inicializador Padrão diferente do dicionário

   oModel:AddGrid('EIKDETAIL','SWVDETAIL'  ,oStruEIK,,bPosValid,,, bLoadEIK)
   oModel:SetRelation('EIKDETAIL', {   { 'EIK_FILIAL'   ,'xFilial("EIK")'},;
      { 'EIK_HAWB'     ,'WV_HAWB'       },;
      { 'EIK_IDWV'     ,'WV_ID'         }},; //Aviso: Falta tratar a adição (vinculo com o item)
      cOrderBy )

   oModel:GetModel("EIKDETAIL"):SetDelAllLine(.T.)

Return Nil


/*
Função     : SetModEINA
Objetivo   : Cria a instância do model para a tabela EIN (Acréscimos)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModEINA(oModel)
   Local bLoadEIN := {|oModel| LP500EINLoad( oModel, "1" ) }
   Local oStruEIN := FWFormStruct( 1, "EIN",{|x| CheckField(x, EasyStrSplit(LP500Model("EINA"), "|")) } )
   Local bPosValid:= {|oGridModel, nLine| PosValEIN(oGridModel, nLine)}
   Local cOrderBy:= "EIN_FILIAL+EIN_HAWB+EIN_IDWV+EIN_TIPO+EIN_CODACR"

   oStruEIN:SetProperty('EIN_CODACR', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIN:SetProperty('EIN_FOBMOE', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIN:SetProperty('EIN_VLMLE' , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )

   oStruEIN:SetProperty('EIN_FILIAL', MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'LP500INI(b)'          )) //Monta Inicializador Padrão diferente do dicionário
   oStruEIN:SetProperty('EIN_HAWB'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'LP500INI(b)'          )) //Monta Inicializador Padrão diferente do dicionário
   oStruEIN:SetProperty('EIN_IDWV'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'LP500INI(b)'          )) //Monta Inicializador Padrão diferente do dicionário
   oStruEIN:SetProperty('EIN_DESC'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'LP500INI(b,a,c)'      )) //Monta Inicializador Padrão diferente do dicionário

   oStruEIN:AddTrigger("EIN_CODACR"  , "EIN_CODIGO",, {|oModel| LP500Gatil("EIN_CODACR_CODIGO"  )} )
   oStruEIN:AddTrigger("EIN_CODACR"  , "EIN_DESC",, {|oModel| LP500Gatil("EIN_CODACR_DESC"  )} )

   oStruEIN:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )

   oModel:AddGrid('EINADETAIL','SWVDETAIL'  ,oStruEIN,,bPosValid,,, bLoadEIN)
   oModel:SetRelation('EINADETAIL', {  { 'EIN_FILIAL'  ,'xFilial("EIN")'},;
      { 'EIN_HAWB'    ,'WV_HAWB'       },;
      { 'EIN_IDWV'    ,'WV_ID'         },;
      { 'EIN_TIPO'    , '1'            }},;
      cOrderBy )

   oModel:GetModel("EINADETAIL"):SetDelAllLine(.T.)

Return Nil

/*
Função     : SetModEIND
Objetivo   : Cria a instância do model para a tabela EIN (Acréscimos)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModEIND(oModel)
   Local bLoadEIN := {|oModel| LP500EINLoad( oModel, "2" ) } //
   Local oStruEIN := FWFormStruct( 1, "EIN",{|x| CheckField(x, EasyStrSplit(LP500Model("EIND"), "|")) } )
   Local bPosValid:= {|oGridModel, nLine, cAction| PosValEIN(oGridModel, nLine)}
   Local cOrderBy:= "EIN_FILIAL+EIN_HAWB+EIN_IDWV+EIN_TIPO+EIN_CODDED"

   oStruEIN:SetProperty('EIN_CODDED', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIN:SetProperty('EIN_FOBMOE', MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEIN:SetProperty('EIN_VLMLE' , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID , 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )

   oStruEIN:SetProperty('EIN_FILIAL', MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'LP500INI(b)'          )) //Monta Inicializador Padrão diferente do dicionário
   oStruEIN:SetProperty('EIN_HAWB'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'LP500INI(b)'          )) //Monta Inicializador Padrão diferente do dicionário
   oStruEIN:SetProperty('EIN_IDWV'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'LP500INI(b)'          )) //Monta Inicializador Padrão diferente do dicionário
   oStruEIN:SetProperty('EIN_DESC'  , MODEL_FIELD_INIT , FwBuildFeature(STRUCT_FEATURE_INIPAD, 'LP500INI(b,a,c)'      )) //Monta Inicializador Padrão diferente do dicionário

   oStruEIN:AddTrigger("EIN_CODDED"  , "EIN_CODIGO",, {|oModel| LP500Gatil("EIN_CODDED_CODIGO"  )} )
   oStruEIN:AddTrigger("EIN_CODDED"  , "EIN_DESC",, {|oModel| LP500Gatil("EIN_CODDED_DESC"  )} )

   oStruEIN:SetProperty('*',MODEL_FIELD_OBRIGAT, .F. )

   //Aqui acho que não precisa chamar o bLoadEin de novo, pois já gerou na EINA
   oModel:AddGrid('EINDDETAIL','SWVDETAIL'  ,oStruEIN,,bPosValid,,, bLoadEIN)

   oModel:SetRelation('EINDDETAIL', {  { 'EIN_FILIAL'  ,'xFilial("EIN")'},;
      { 'EIN_HAWB'    ,'WV_HAWB'       },;
      { 'EIN_IDWV'    ,'WV_ID'         },;
      { 'EIN_TIPO'    , '2'            }},;
      cOrderBy )

   oModel:GetModel("EINDDETAIL"):SetDelAllLine(.T.)

Return Nil

/*
Função     : SetModEJ9
Objetivo   : Cria a instância do model para a tabela ej9
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetModEJ9(oModel)
   Local oStruEJ9 := FWFormStruct( 1, "EJ9", {|x| CheckField(x, EasyStrSplit(LP500Model("EJ9"), "|")) })
   Local bPosVLnEJ9 := {|oGridEJ9, nLine| PosVldEJ9(oGridEJ9, nLine)}
   Local bLoadEJ9 := {|oModel| LP500EJ9Load( oModel ) }
   oStruEJ9:SetProperty('EJ9_IDCERT',MODEL_FIELD_OBRIGAT, .F. )
   oStruEJ9:SetProperty('EJ9_DEMERC',MODEL_FIELD_OBRIGAT, .F. )
   oStruEJ9:SetProperty('EJ9_QTDCER',MODEL_FIELD_OBRIGAT, .F. )

   oStruEJ9:SetProperty('EJ9_DEMERC'  , MODEL_FIELD_VALID, FwBuildFeature(STRUCT_FEATURE_VALID, 'LP500VALID(b,a,c,d)'      )) //Monta valid diferente do dicionário ( b=cCAMPO, a=oModel, c=xNovoValor, d=xAntigoValor )
   oStruEJ9:SetProperty("EJ9_FILIAL" , MODEL_FIELD_INIT  , {|| LP500INI('EJ9_FILIAL')})
   oStruEJ9:SetProperty("EJ9_HAWB"   , MODEL_FIELD_INIT  , {|| LP500INI('EJ9_HAWB')})
   oStruEJ9:SetProperty("EJ9_IDWV"   , MODEL_FIELD_INIT  , {|| LP500INI('EJ9_IDWV')})

   oModel:AddGrid('EJ9DETAIL','SWVDETAIL'  ,oStruEJ9,,bPosVLnEJ9,,, bLoadEJ9)
   oModel:SetRelation('EJ9DETAIL', {   { 'EJ9_FILIAL'   ,'xFilial("EJ9")'},;
      { 'EJ9_HAWB'     ,'WV_HAWB'       },;
      { 'EJ9_IDWV'     ,'WV_ID'    }},;
      EJ9->(IndexKey(2)) )
   oModel:GetModel("EJ9DETAIL"):SetUniqueLine({"EJ9_FILIAL","EJ9_HAWB","EJ9_IDWV","EJ9_DEMERC"} )
   oModel:GetModel("EJ9DETAIL"):SetDelAllLine(.T.)
Return Nil

/*
Função     : SetMSWVTrb
Objetivo   : Cria a instância do model para a tabela SWV (Tributação)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetMSWVTrb(oModel)
   local oStruSWV   := FWFormStruct( 1, "SWV", {|x| CheckField(x, EasyStrSplit(LP500Model("SWV"), "|")) })
   local bLoadSup   := {|oModel| LP500LdTrb( oModel , "SWVDETAIL_TRIBUTACAO") }
   local cOrderBy   := "WV_FILIAL+WV_HAWB+WV_INVOICE+WV_FORN+WV_FORLOJ+WV_PO_NUM+WV_POSICAO+WV_SEQUENC"

   oModel:AddGrid('SWVDETAIL_TRIBUTACAO',"SW6MASTER", oStruSWV,,,,, bLoadSup)

   oModel:GetModel("SWVDETAIL_TRIBUTACAO"):SetNoInsertLine(.T.)
   oModel:GetModel("SWVDETAIL_TRIBUTACAO"):SetNoDeleteLine(.T.)
   oModel:GetModel("SWVDETAIL_TRIBUTACAO"):SetNoUpdateLine(.T.)
   oModel:GetModel("SWVDETAIL_TRIBUTACAO"):SetOnlyQuery(.T.)
   oModel:GetModel("SWVDETAIL_TRIBUTACAO"):SetUniqueLine({"WV_FILIAL","WV_HAWB","WV_INVOICE","WV_FORN","WV_FORLOJ","WV_PO_NUM","WV_POSICAO","WV_SEQUENC"} )

   oModel:SetRelation('SWVDETAIL_TRIBUTACAO', { ;
      { 'WV_FILIAL'   ,'xFilial("SWV")' },;
      { 'WV_HAWB'     ,'W6_HAWB'        }},;
      cOrderBy )

return nil

/*
Função     : SetModII
Objetivo   : Cria a instância do model para a tabela EIJ (Imposto de importação)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetModII(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_II"), "|")) })
   local bLoadEIJ := {|oModel| LP500LdTrb( oModel , "EIJMASTER_II") }
   local lCpos    := DUIMP2310()

   oStruEIJ:SetProperty('EIJ_REGTRI'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_REGTRI")'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_FUNREG'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_FUNREG")'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_TPAII'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TPAII" )'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_ALI_II'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALI_II")'    )) //Monta When diferente do dicionário

   if lCpos
      oStruEIJ:SetProperty('EIJ_VLCII'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VRDII'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VLDII'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VLSII'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VRCII'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
   endif

   oStruEIJ:AddTrigger("EIJ_REGTRI", "EIJ_REGTRI",, {|oModel| LP500Gatil("EIJ_REGTRI")} )
   oStruEIJ:AddTrigger("EIJ_FUNREG", "EIJ_FUNREG",, {|oModel| LP500Gatil("EIJ_FUNREG")} )
   oStruEIJ:AddTrigger("EIJ_ALI_II", "EIJ_ALI_II",, {|oModel| LP500Gatil("EIJ_ALI_II")} )

   oModel:AddFields('EIJMASTER_II',"SWVDETAIL_TRIBUTACAO",oStruEIJ,,, bLoadEIJ)

   oModel:GetModel("EIJMASTER_II"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_II', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )

return nil

/*
Função     : SetModIPI
Objetivo   : Cria a instância do model para a tabela EIJ (IPI)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetModIPI(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_IPI"), "|")) })
   local bLoadEIJ := {|oModel| LP500LdTrb( oModel , "EIJMASTER_IPI" ) }
   local lCpos    := DUIMP2310()

   oStruEIJ:SetProperty('EIJ_REGIPI'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_REGIPI")'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_ASSIPI'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ASSIPI")'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_TPAIPI'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TPAIPI")'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_ALAIPI'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALAIPI")'    )) //Monta When diferente do dicionário

   if lCpos
      oStruEIJ:SetProperty('EIJ_VLCIPI'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VRDIPI'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VDIPI'    , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VLSIPI'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VRCIPI'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
   endif
     
   oStruEIJ:AddTrigger("EIJ_REGIPI", "EIJ_REGIPI",, {|oModel| LP500Gatil("EIJ_REGIPI")} )
   oStruEIJ:AddTrigger("EIJ_ASSIPI", "EIJ_ASSIPI",, {|oModel| LP500Gatil("EIJ_ASSIPI")} )
   oStruEIJ:AddTrigger("EIJ_ALAIPI", "EIJ_ALAIPI",, {|oModel| LP500Gatil("EIJ_ALAIPI")} )

   oModel:AddFields('EIJMASTER_IPI',"SWVDETAIL_TRIBUTACAO",oStruEIJ,,, bLoadEIJ)

   oModel:GetModel("EIJMASTER_IPI"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_IPI', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )

return nil

/*
Função     : SetModPISCOFINS
Objetivo   : Cria a instância do model para a tabela EIJ (PIS/COFINS)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetModPISCOFINS(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_PISCOFINS"), "|")) })
   local bLoadEIJ := {|oModel| LP500LdTrb( oModel , "EIJMASTER_PISCOFINS" ) }
   local lCpos    := DUIMP2310()

   oStruEIJ:SetProperty('EIJ_REG_PC'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_REG_PC")'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_FUN_PC'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_FUN_PC")'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_TPAPIS'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TPAPIS")'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_ALAPIS'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALAPIS")'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_TPACOF'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_TPACOF")'    )) //Monta When diferente do dicionário
   oStruEIJ:SetProperty('EIJ_ALACOF'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_ALACOF")'    )) //Monta When diferente do dicionário

   if lCpos
      oStruEIJ:SetProperty('EIJ_VLCPIS'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VRDPIS'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VDEPIS'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VLSPIS'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VRCPIS'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VLCCOF'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VRDCOF'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VDECOF'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VLSCOF'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
      oStruEIJ:SetProperty('EIJ_VRCCOF'   , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário
   endif

   oStruEIJ:AddTrigger("EIJ_REG_PC", "EIJ_REG_PC",, {|oModel| LP500Gatil("EIJ_REG_PC")} )
   oStruEIJ:AddTrigger("EIJ_FUN_PC", "EIJ_FUN_PC",, {|oModel| LP500Gatil("EIJ_FUN_PC")} )
   oStruEIJ:AddTrigger("EIJ_ALAPIS", "EIJ_ALAPIS",, {|oModel| LP500Gatil("EIJ_ALAPIS")} )
   oStruEIJ:AddTrigger("EIJ_ALACOF", "EIJ_ALACOF",, {|oModel| LP500Gatil("EIJ_ALACOF")} )

   oModel:AddFields('EIJMASTER_PISCOFINS',"SWVDETAIL_TRIBUTACAO",oStruEIJ,,, bLoadEIJ)

   oModel:GetModel("EIJMASTER_PISCOFINS"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_PISCOFINS', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )

return nil

/*
Função     : SetModICMS
Objetivo   : Cria a instância do model para a tabela EIJ (ICMS)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function SetModICMS(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_ICMS"), "|")) })
   local bLoadEIJ := {|oModel| LP500LdTrb( oModel , "EIJMASTER_ICMS" ) }

   oStruEIJ:SetProperty('EIJ_OPERAC'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , 'LP500WHEN("EIJ_OPERAC")'    )) //Monta When diferente do dicionário

   oStruEIJ:AddTrigger("EIJ_OPERAC", "EIJ_OPERAC",, {|oModel| LP500Gatil("EIJ_OPERAC")} )

   oModel:AddFields('EIJMASTER_ICMS',"SWVDETAIL_TRIBUTACAO",oStruEIJ,,, bLoadEIJ)

   oModel:GetModel("EIJMASTER_ICMS"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_ICMS', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )

return nil


/*
Função     : SetMObsTrb
Objetivo   : Cria a instância do model para a tabela EIJ (Integração)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       :
*/
static function SetMObsTrb(oModel)
   local oStruEIJ := FWFormStruct( 1, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500Model("EIJMASTER_OBSTRB"), "|")) })
   local bLoadEIJ := {|oModel| LP500LdTrb( oModel , "EIJMASTER_OBSTRB" ) }

   oStruEIJ:SetProperty('EIJ_OBSTRB'  , MODEL_FIELD_WHEN , FwBuildFeature(STRUCT_FEATURE_WHEN , '.F.'    )) //Monta When diferente do dicionário

   oModel:AddFields('EIJMASTER_OBSTRB',"SWVDETAIL_TRIBUTACAO",oStruEIJ,,, bLoadEIJ)

   oModel:GetModel("EIJMASTER_OBSTRB"):SetOnlyQuery(.T.)

   oModel:SetRelation('EIJMASTER_OBSTRB', { ;
      { 'EIJ_FILIAL'   ,'xFilial("EIJ")'},;
      { 'EIJ_HAWB'     ,'WV_HAWB'       },;
      { 'EIJ_IDWV'     ,'WV_ID'         }},; 
      EIJ->(IndexKey(3)) )

return nil

/*
Função     : ViewDef
Objetivo   : Cria a estrutura Visual - Interface
Retorno    : oView
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function ViewDef()
   Local oStruSW6  := FWFormStruct( 2, "SW6", { |x| ALLTRIM(x) $ 'W6_FILIAL|W6_HAWB' }, /*lViewUsado*/ )
   Local oModel    := FWLoadModel( "EICLP500" )
   Local oView     := nil
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA

   //Cria o objeto de View
   oView := FWFormView():New()

   IF !lDuimpInt
      oView:AddUserButton(STR0055, 'CLIPS', {|| GerSeqDuimp(.T.)}) //"Gerar Sequência Automaticamente"
      oView:AddUserButton(STR0054, 'CLIPS', {|| DelSeqDuimp(.T.)}) //"Apagar Sequências"
   EndIf   

   // Adiciona no nosso View um controle do tipo formulário
   //Define qual o Modelo de dados será utilizado na View
   oView:SetModel( oModel )

   //Cria grupo de folders principal (100% da tela)
   oView:CreateHorizontalBox("MAINB", 100)
   oView:CreateFolder("MAIN", "MAINB")

   //Cria abas do grupo de folders principal
   oView:addSheet("MAIN", "DUIMP", STR0079) //"Itens"
   oView:addSheet("MAIN", "TRIB" , STR0080) //"Tributação" //escopo migrado para o release 12.1.2210

   //Cria Form oculto para o SW6 (Modelo Base), na aba DUIMP
   oView:CreateHorizontalBox( 'NAOEXIBIDO', 0,,,'MAIN', 'DUIMP')
   oView:AddField( 'VIEW_SW6', oStruSW6, 'SW6MASTER' )
   oView:SetOwnerView( 'VIEW_SW6', 'NAOEXIBIDO' )

   //Aba DUIMP
   //Cria Box superior da Aba DUIMP
   oView:CreateHorizontalBox( 'SUPERIOR', 60,,,'MAIN', 'DUIMP')
   //Cria Box a esquerda para dados das Invoices
   oView:CreateVerticalBox('SUP_ESQ', 30, "SUPERIOR",,'MAIN', 'DUIMP')
   //Cria Box a Direita para dados dos itens da DUIMP (SWV)
   oView:CreateVerticalBox('SUP_DIR', 70,"SUPERIOR",,'MAIN', 'DUIMP')

   //Cria Box inferior da Aba DUIMP
   oView:CreateHorizontalBox( 'INFERIOR', 40,,,'MAIN', 'DUIMP')

   //Cria Grupo de folders do Box inferior da Aba DUIMP
   oView:CreateFolder("INFERIORF", "INFERIOR")

   //Cria abas do grupo de folders para apresentar detalhes do item
   oView:addSheet("INFERIORF", "MERCADORIA", STR0056) //"Mercadoria"
   //oView:addSheet("INFERIORF", "FABFOR"    , STR0057, {||oView:Refresh("FABFOR")    }) //"Fabricante/Fornecedor"
   //oView:addSheet("INFERIORF", "CONDVEND"  , STR0058, {||oView:Refresh("CONDVEND")  }) //"Condição de Venda/Cambiais"
   oView:addSheet("INFERIORF", "ACRESDED"  , STR0059) //"Acréscimos/Deduções"
   oView:addSheet("INFERIORF", "LPCO"      , STR0060) //"LPCO"
   oView:addSheet("INFERIORF", "DOCS"      , STR0061) //"Documentos Vinculados"
   oView:addSheet("INFERIORF", "CERTMERC"  , STR0062) //"Certificado Mercosul"

   //Carrega as Views para os Sub Modelos:
   SetViewInvoices(oView)
   SetViewItens(oView)
   SetViewMercadoria(oView)
   /* as duas views foram comentadas e os campos passaram a ser exibidos na view Mercadoria, até que ocorra a correção do refresh pela equipe de Framework - DFRM1-28263
   SetViewFabFor(oView) 
   SetViewCondVend(oView) */
   SetViewLPCO(oView)
   SetViewDocs(oView)
   SetViewAcr(oView)
   SetViewCMs(oView)

   //Aba Tributação
   //Cria Box superior da Aba DUIMP
   oView:CreateHorizontalBox( 'SUPERIORTRIB', 50,,,'MAIN', 'TRIB')
   oView:CreateHorizontalBox( 'INFERIORTRIB', 50,,,'MAIN', 'TRIB')

   oView:CreateFolder("INFERIOR_TRIB", "INFERIORTRIB")
   oView:addSheet("INFERIOR_TRIB", "FOLDER_II"        , STR0099) // "Imposto de Importação"
   oView:CreateHorizontalBox( 'BOX_II', 100,,,'INFERIOR_TRIB', 'FOLDER_II')

   oView:addSheet("INFERIOR_TRIB", "FOLDER_IPI"       , "IPI") // "IPI"
   oView:CreateHorizontalBox( 'BOX_IPI', 100,,,'INFERIOR_TRIB', 'FOLDER_IPI')

   oView:addSheet("INFERIOR_TRIB", "FOLDER_PISCOFINS" , "PIS/COFINS") // "PIS/COFINS"
   oView:CreateHorizontalBox( 'BOX_PISCOFINS', 100,,,'INFERIOR_TRIB', 'FOLDER_PISCOFINS')

   oView:addSheet("INFERIOR_TRIB", "FOLDER_ICMS"      , "ICMS") // "ICMS"
   oView:CreateHorizontalBox( 'BOX_ICMS', 100,,,'INFERIOR_TRIB', 'FOLDER_ICMS')

   if lDuimpInt .and. DUIMP2310()
      oView:addSheet("INFERIOR_TRIB", "FOLDER_OBSTRB" , STR0110 ) // "Integração"
      oView:CreateHorizontalBox( 'BOX_OBSTRB', 100,,,'INFERIOR_TRIB', 'FOLDER_OBSTRB')
   endif

   //Carrega as Views para os Sub Modelos:
   SetVSWVTrb(oView)
   SetViewII(oView)
   SetViewIPI(oView)
   SetViewPISCOFINS(oView)
   SetViewICMS(oView)
   if lDuimpInt .and. DUIMP2310()
      SetVObsTrb(oView)
   endif

Return oView

/*
Função     : SetViewInvoices
Objetivo   : Cria a instância da View para a tabela SW9 (Dados de capa da Invoice)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewInvoices(oView)
   Local oStruSW9 := FWFormStruct( 2, "SW9", {|x| CheckField(x, EasyStrSplit(LP500View("SW9"), "|")) }   )

   oStruSW9:SetProperty('W9_INVOICE'	,MVC_VIEW_CANCHANGE ,.F.)
   oStruSW9:SetProperty('W9_FORN'   	,MVC_VIEW_CANCHANGE ,.F.)
   oStruSW9:SetProperty('W9_FORLOJ'	,MVC_VIEW_CANCHANGE ,.F.)

   oView:AddGrid("VIEW_SW9",oStruSW9 , "SW9DETAIL")
   oView:SetOwnerView( 'VIEW_SW9', 'SUP_ESQ' )

   oView:EnableTitleView( "VIEW_SW9", STR0081) //"Invoices"
   oView:SetViewProperty( "VIEW_SW9", "GRIDFILTER", {.T.} )
   oView:SetViewProperty( "VIEW_SW9", "GRIDSEEK"  , {.T.} )
   oView:SetViewProperty( "VIEW_SW9", "SETCSS", { MYCSS } )

Return Nil

/*
Função     : SetViewItens
Objetivo   : Cria a instância da View para a tabela SWV (Itens da DUIMP)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewItens(oView)
   Local oStruSWV := FWFormStruct( 2, "SWV", {|x| CheckField(x, EasyStrSplit(LP500View("SWV"), "|")) })

   //Altera a ordem de visualização dos campos na tela
   oStruSWV:SetProperty('WV_SEQDUIM' , MVC_VIEW_ORDEM ,'01')
   oStruSWV:SetProperty('WV_PO_NUM'  , MVC_VIEW_ORDEM ,'02')
   oStruSWV:SetProperty('WV_POSICAO' , MVC_VIEW_ORDEM ,'03')
   oStruSWV:SetProperty('WV_SEQUENC' , MVC_VIEW_ORDEM ,'04')
   oStruSWV:SetProperty('WV_COD_I'   , MVC_VIEW_ORDEM ,'05')
   oStruSWV:SetProperty('WV_DESC_DI' , MVC_VIEW_ORDEM ,'06')
   oStruSWV:SetProperty('WV_NCM'     , MVC_VIEW_ORDEM ,'07')
   oStruSWV:SetProperty('WV_QTDE'    , MVC_VIEW_ORDEM ,'08')
   oStruSWV:SetProperty('WV_LOTE'	 , MVC_VIEW_ORDEM ,'09')
   oStruSWV:SetProperty('WV_DT_VALI' , MVC_VIEW_ORDEM ,'10')
   oStruSWV:SetProperty('WV_DFABRI'	 , MVC_VIEW_ORDEM ,'11')
   oStruSWV:SetProperty('WV_OBS'	 , MVC_VIEW_ORDEM ,'12')
   oStruSWV:SetProperty('WV_LPCOPND' , MVC_VIEW_ORDEM ,'13')
   oStruSWV:SetProperty('WV_ID'	     , MVC_VIEW_ORDEM ,'14')

   //Define quais campos são editáveis
   IF SW6->W6_FORMREG != DUIMP_INTEGRADA
      oStruSWV:SetProperty('WV_SEQDUIM',MVC_VIEW_CANCHANGE ,.T.)
   EndIf

   oStruSWV:SetProperty('WV_PO_NUM'	 , MVC_VIEW_CANCHANGE ,.F.)
   oStruSWV:SetProperty('WV_POSICAO' , MVC_VIEW_CANCHANGE ,.F.)
   oStruSWV:SetProperty('WV_COD_I'	 , MVC_VIEW_CANCHANGE ,.F.)
   oStruSWV:SetProperty('WV_LOTE'	 , MVC_VIEW_CANCHANGE ,.T.)

   oView:AddGrid("VIEW_SWV", oStruSWV , "SWVDETAIL")
   oView:SetOwnerView('VIEW_SWV', 'SUP_DIR' )

   oView:EnableTitleView( "VIEW_SWV", STR0079) //"Itens"
   oView:SetViewProperty( "VIEW_SWV", "GRIDFILTER", {.T.} ) // Habilita o Filtro no grid superior (Itens\Lotes)
   oView:SetViewProperty( "VIEW_SWV", "GRIDSEEK"  , {.T.} ) // HAbilita a pesquisa no grid superior (Itens\Lotes)
   oView:SetViewProperty( 'VIEW_SWV', "CHANGELINE", {{ |oView, cViewID| ChangeLnWV(oView, cViewID) }} ) //Seta Função a ser executada quando trocar de linha no grid superior (SWV)
   oView:SetViewProperty( "VIEW_SWV", "SETCSS", { MYCSS } )//Habilita a mudança de cor na linha selecionada

Return Nil

/*
Função     : SetViewMercadoria
Objetivo   : Cria a instância da View para a tabela EIJ (Tributação dos itens da DUIMP)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewMercadoria(oView)
   Local aCampos := {}
   Local oStruct := nil

   aCampos := { {"EIJ_IDPTCP","01"}, {"EIJ_VRSACP","01"},;
      {"EIJ_IMPORT","02"}, {"EIJ_NOMIMP","02"}, {"EIJ_CNPJRZ","02"}, {"EIJ_VINCCO","02"}, {"EIJ_APLICM","02"}, {"EIJ_MATUSA","02"}, {"EIJ_DSCCIT","02"},;
      {"EIJ_UNIDCO","03"}, {"EIJ_QTDECO","03"}, {"EIJ_UNDEST","03"}, {"EIJ_QT_EST","03"}, {"EIJ_PESOL" ,"03"}, {"EIJ_MOEDA" ,"03"}, {"EIJ_VLMLE" ,"03"},;
      {"EIJ_FORN", "04"} , {"EIJ_FORLOJ", "04"} , {"EIJ_FORNVM", "04"} , {"EIJ_TINFO" , "04"} , {"EIJ_PAISPR" , "04"} ,;
      {"EIJ_FABR", "05"} , {"EIJ_FABLOJ", "05"} , {"EIJ_FABRVM", "05"} , {"EIJ_FABFOR", "05"} , {"EIJ_TINFA"  , "05"} , {"EIJ_PAISOR", "05"},;
      {"EIJ_METVAL", "06"} , {"EIJ_INCOTE", "06"} , {"EIJ_TIPCOB", "07"} , {"EIJ_MODALI", "07"} , {"EIJ_NRROF", "07"} , {"EIJ_INSTFI", "07"}, {"EIJ_MOEDA", "07"},{"EIJ_MOTIVO", "07"},{"EIJ_VL_FIN", "07"} }

   if _EIJVERSAO
      aAdd( aCampos, {"EIJ_VRSFOR", "04"} )
      aAdd( aCampos, {"EIJ_VRSFAB", "05"} )
   endif

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) } )
   oStruct:AddGroup("01", STR0063, "01", 2) //"Catálogo de Produtos"
   oStruct:AddGroup("02", STR0064, "01", 2) //"Dados Gerais"
   oStruct:AddGroup("03", STR0065, "01", 2) //"Valores"
   oStruct:AddGroup("04", STR0066, "01", 2) //"Dados do Fornecedor"
   oStruct:AddGroup("05", STR0067, "01", 2) //"Dados do Fabricante"
   oStruct:AddGroup("06", STR0068 , "01", 2) //"Valoração"
   oStruct:AddGroup("07", STR0069 , "01", 2) //"Dados Cambiais"

   //Remove os Folders
   oStruct:aFolders := {}

   //Adiciona os Grupos
   aEval(aCampos, {|x| oStruct:SetProperty(x[1], MVC_VIEW_GROUP_NUMBER, x[2]) })

   oView:CreateHorizontalBox('V_MERCADORIA',100,,,'INFERIORF', 'MERCADORIA')

   oView:AddField( 'MERCADORIA', oStruct, 'EIJMASTER' )
   oView:SetOwnerView( 'MERCADORIA', 'V_MERCADORIA' )

Return Nil

/*
Função     : SetViewFabFor
Objetivo   : Cria a instância da View para a tabela EIJ (Tributação dos itens da DUIMP) separando por
             dados de fornecedor/fabricante
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
/*  as duas views foram comentadas e os campos passaram a ser exibidos na view Mercadoria, até que ocorra a correção do refresh pela equipe de Framework - DFRM1-28263
Static Function SetViewFabFor(oView)
   Local aCampos := {{"EIJ_FORN", "01"} , {"EIJ_FORLOJ", "01"} , {"EIJ_FORNVM", "01"} , {"EIJ_TINFO" , "01"} , {"EIJ_PAISPR" , "01"} , ;
      {"EIJ_FABR", "02"} , {"EIJ_FABLOJ", "02"} , {"EIJ_FABRVM", "02"} , {"EIJ_FABFOR", "02"} , {"EIJ_TINFA"  , "02"} , {"EIJ_PAISOR", "02"}}
   Local oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) })

   oStruct:AddGroup("01", STR0066 , "01", 2) //"Dados do Fornecedor"
   oStruct:AddGroup("02", STR0067 , "01", 2) //"Dados do Fabricante"

   //Remove os Folders
   oStruct:aFolders := {}

   //Adiciona os Grupos
   aEval(aCampos, {|x| oStruct:SetProperty(x[1], MVC_VIEW_GROUP_NUMBER, x[2]) })

   oView:CreateHorizontalBox('V_FABFOR',100,,,'INFERIORF', 'FABFOR')

   oView:AddField( 'FABFOR', oStruct, 'EIJMASTER' )
   oView:SetOwnerView( 'FABFOR', 'V_FABFOR' )

Return Nil
*/
/*
Função     : SetViewCondVend
Objetivo   : Cria a instância da View para a tabela EIJ (Tributação dos itens da DUIMP) separando por
             dados de câmbio
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
/* as duas views foram comentadas e os campos passaram a ser exibidos na view Mercadoria, até que ocorra a correção do refresh pela equipe de Framework - DFRM1-28263
Static Function SetViewCondVend(oView)
   //Aviso: Os campos não usados precisam ser tratados no dicionário, caso contrário não são incluídos na estrutura
   Local aCampos := {{"EIJ_METVAL", "01"} , {"EIJ_INCOTE", "01"} , {"EIJ_TIPCOB", "02"} , {"EIJ_MODALI", "02"} , {"EIJ_NRROF", "02"} , {"EIJ_INSTFI", "02"}, {"EIJ_MOEDA", "02"},{"EIJ_MOTIVO", "02"},{"EIJ_VL_FIN", "02"} }
   Local oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) })

   oStruct:AddGroup("01", STR0068 , "01", 2) //"Valoração"
   oStruct:AddGroup("02", STR0069 , "01", 2) //"Dados Cambiais"

   //Remove os Folders
   oStruct:aFolders := {}

   //Adiciona os Grupos
   aEval(aCampos, {|x| oStruct:SetProperty(x[1], MVC_VIEW_GROUP_NUMBER, x[2]) })

   oView:CreateHorizontalBox('V_CONDVEND',100,,,'INFERIORF', 'CONDVEND')

   oView:AddField( 'CONDVEND', oStruct, 'EIJMASTER' )
   oView:SetOwnerView( 'CONDVEND', 'V_CONDVEND' )

Return Nil
*/
/*
Função     : SetViewLPCO
Objetivo   : Cria a instância da View para a tabela EKQ (Dados de LPCO)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewLPCO(oView)
   Local oStruEKQ := FWFormStruct(2, "EKQ", {|x| CheckField(x, EasyStrSplit(LP500View("EKQ"), "|")) })

   oView:CreateHorizontalBox( 'LPCOBOX', 100,,,'INFERIORF', 'LPCO')

   oStruEKQ:SetProperty('EKQ_ORGANU'	,MVC_VIEW_ORDEM ,'01')
   oStruEKQ:SetProperty('EKQ_FRMLPC'	,MVC_VIEW_ORDEM ,'02')
   oStruEKQ:SetProperty('EKQ_DSCFRM'	,MVC_VIEW_ORDEM ,'03')
   oStruEKQ:SetProperty('EKQ_OBRFRM'	,MVC_VIEW_ORDEM ,'04')
   oStruEKQ:SetProperty('EKQ_LPCO'	    ,MVC_VIEW_ORDEM ,'05')
   oStruEKQ:SetProperty('EKQ_VERSAO'   ,MVC_VIEW_ORDEM ,'06')

   oView:AddGrid("VIEW_EKQ", oStruEKQ, "EKQDETAIL")
   oView:SetOwnerView('VIEW_EKQ', 'LPCOBOX' )
   oView:EnableTitleView("VIEW_EKQ", "LPCO" )
   oView:SetViewProperty("VIEW_EKQ", "SETCSS", { MYCSS } )

Return Nil

/*
Função     : SetViewDocs
Objetivo   : Cria a instância da View para a tabela EIK (Documentos Vinculados)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewDocs(oView)
   Local oStruct := FWFormStruct( 2, "EIK", {|x| CheckField(x, EasyStrSplit(LP500View("EIK"), "|")) })

   oView:CreateHorizontalBox('V_DOCS',100,,,'INFERIORF', 'DOCS')
   oView:AddGrid( 'DOCS', oStruct, 'EIKDETAIL' )
   oView:SetOwnerView( 'DOCS', 'V_DOCS' )
   oView:SetViewProperty( "DOCS", "SETCSS", { MYCSS } )
   oView:EnableTitleView("DOCS", STR0061 ) //"Documentos Vinculados"

Return Nil

/*
Função     : SetViewAcr
Objetivo   : Cria a instância da View para a tabela EKQ (Dados de LPCO)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewAcr(oView)
   Local oStruEINAc := FWFormStruct(2, "EIN", {|x| CheckField(x, EasyStrSplit(LP500View("EINA"), "|")) })
   Local oStruEINDd := FWFormStruct(2, "EIN", {|x| CheckField(x, EasyStrSplit(LP500View("EIND"), "|")) })

   oView:CreateHorizontalBox( 'ACRESDEDBOX', 100,,,'INFERIORF', 'ACRESDED')

   //Cria Box a esquerda para dados dos acrescimos
   oView:CreateVerticalBox('BOXVACRES', 50, "ACRESDEDBOX",,"INFERIORF", "ACRESDED")
   //Cria Box a Direita para dados das deduções
   oView:CreateVerticalBox('BOXVDEDUC', 50, "ACRESDEDBOX",,"INFERIORF", "ACRESDED")

   oStruEINAc:SetProperty('EIN_CODACR'	,MVC_VIEW_ORDEM ,'01')
   oStruEINAc:SetProperty('EIN_DESC'	,MVC_VIEW_ORDEM ,'02')
   oStruEINAc:SetProperty('EIN_FOBMOE'	,MVC_VIEW_ORDEM ,'03')
   oStruEINAc:SetProperty('EIN_VLMLE'	,MVC_VIEW_ORDEM ,'04')
   oStruEINAc:SetProperty('EIN_VLMMN'	,MVC_VIEW_ORDEM ,'05')

   oView:AddGrid("VIEW_EINACR", oStruEINAc, "EINADETAIL")
   oView:SetOwnerView('VIEW_EINACR', 'BOXVACRES' )
   oView:EnableTitleView("VIEW_EINACR", STR0082) //"Acréscimos"
   oView:SetViewProperty("VIEW_EINACR", "SETCSS", { MYCSS } )

   oStruEINDd:SetProperty('EIN_CODDED'	,MVC_VIEW_ORDEM ,'01')
   oStruEINDd:SetProperty('EIN_DESC'	,MVC_VIEW_ORDEM ,'02')
   oStruEINDd:SetProperty('EIN_FOBMOE'	,MVC_VIEW_ORDEM ,'03')
   oStruEINDd:SetProperty('EIN_VLMLE'	,MVC_VIEW_ORDEM ,'04')
   oStruEINDd:SetProperty('EIN_VLMMN'	,MVC_VIEW_ORDEM ,'05')

   oView:AddGrid("VIEW_EINDED", oStruEINDd, "EINDDETAIL")
   oView:SetOwnerView('VIEW_EINDED', 'BOXVDEDUC' )
   oView:EnableTitleView("VIEW_EINDED", STR0083) //"Deduções"
   oView:SetViewProperty("VIEW_EINDED", "SETCSS", { MYCSS } )


Return Nil


/*
Função     : SetViewCMs
Objetivo   : Cria a instância da View para a tabela EJ9 (DE Mercosul)
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function SetViewCMs(oView)
   Local oStruEJ9 := FWFormStruct(2, "EJ9", {|x| CheckField(x, EasyStrSplit(LP500View("EJ9"), "|")) })

   oView:CreateHorizontalBox( 'CERTMERCBOX', 100,,,'INFERIORF', 'CERTMERC')

   oView:AddGrid("VIEW_EJ9", oStruEJ9, "EJ9DETAIL")
   oView:SetOwnerView('VIEW_EJ9', 'CERTMERCBOX' )
   oView:EnableTitleView("VIEW_EJ9", STR0084) //"Certificados Mercosul"
   oView:SetViewProperty("VIEW_EJ9", "SETCSS", { MYCSS } )

   oStruEJ9:SetProperty('EJ9_IDCERT'	,MVC_VIEW_ORDEM ,'04')
   oStruEJ9:SetProperty('EJ9_DEMERC'	,MVC_VIEW_ORDEM ,'05')
   oStruEJ9:SetProperty('EJ9_QTDCER'	,MVC_VIEW_ORDEM ,'06')

Return Nil

/*
Função     : SetVSWVTrb
Objetivo   : Cria a instância da View para a tabela SWV (Itens da DUIMP) - aba Tributação
Retorno    : Nenhum
Autor      : RMD/WFS/Nilson César
Data/Hora  : Novembro/2021
Obs.       :
*/
static function SetVSWVTrb(oView)
   Local oStruSWV := FWFormStruct( 2, "SWV", {|x| CheckField(x, EasyStrSplit(LP500View("SWV",1), "|")) })

   oStruSWV:SetProperty('WV_SEQDUIM' , MVC_VIEW_ORDEM ,'01')
   oStruSWV:SetProperty('WV_PO_NUM'  , MVC_VIEW_ORDEM ,'02')
   oStruSWV:SetProperty('WV_POSICAO' , MVC_VIEW_ORDEM ,'03')
   oStruSWV:SetProperty('WV_SEQUENC' , MVC_VIEW_ORDEM ,'04')
   oStruSWV:SetProperty('WV_COD_I'   , MVC_VIEW_ORDEM ,'05')
   oStruSWV:SetProperty('WV_DESC_DI' , MVC_VIEW_ORDEM ,'06')
   oStruSWV:SetProperty('WV_NCM'     , MVC_VIEW_ORDEM ,'07')
   oStruSWV:SetProperty('WV_QTDE'    , MVC_VIEW_ORDEM ,'08')

   oView:AddGrid("VIEW_SWV_TRIB", oStruSWV , "SWVDETAIL_TRIBUTACAO")
   oView:SetOwnerView('VIEW_SWV_TRIB', 'SUPERIORTRIB' )

   oView:EnableTitleView( "VIEW_SWV_TRIB", STR0079) //"Itens"
   oView:SetViewProperty( "VIEW_SWV_TRIB", "SETCSS", { MYCSS } )//Habilita a mudança de cor na linha selecionada

Return Nil

/*
Função     : SetViewII
Objetivo   : Cria a instância da View para a tabela EIJ (Imposto de importaçao)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2021
Obs.       :
*/
static function SetViewII(oView)
   local aCampos   := {}
   local oStruct   := nil
   local nCpo      := 0
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA
   local lCpos     := .F.

   if lDuimpInt
      lCpos := DUIMP2310()
   endif

   aCampos := { ;
               {"EIJ_REGTRI","01"},;
               {"EIJ_FUNREG","02"},;
               {"EIJ_TPAII" ,"03"},{"EIJ_ALI_II","03"};
              }

   if lCpos
      aAdd( aCampos, {"EIJ_VLCII" ,"04"} )
      aAdd( aCampos, {"EIJ_VRDII" ,"04"} )
      aAdd( aCampos, {"EIJ_VLDII" ,"04"} )
      aAdd( aCampos, {"EIJ_VLSII" ,"04"} )
      aAdd( aCampos, {"EIJ_VRCII" ,"04"} )
   endif

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) } )
   oStruct:AddGroup("01", STR0100, "01", 2) // "Regime de Tributação"
   oStruct:AddGroup("02", STR0101, "01", 2) // "Fundamento"
   oStruct:AddGroup("03", STR0102, "01", 2) // "Alíquotas"
 
   if lCpos
      oStruct:AddGroup("04", STR0111, "01", 2) // "Tributos Registrados"
   endif

   //Remove os Folders
   oStruct:aFolders := {}

   for nCpo := 1 to len(aCampos)
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2] )
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM       , StrZero(nCpo,2) )
   next
 
   if lCpos
      oStruct:SetProperty( "EIJ_VLCII" , MVC_VIEW_TITULO , "II " + STR0112 ) // "II Calculado"
      oStruct:SetProperty( "EIJ_VRDII" , MVC_VIEW_TITULO , "II " + STR0113 ) // "II a Reduzir"
      oStruct:SetProperty( "EIJ_VLDII" , MVC_VIEW_TITULO , "II " + STR0114 ) // "II Devido"
      oStruct:SetProperty( "EIJ_VLSII" , MVC_VIEW_TITULO , "II " + STR0115 ) // "II Suspenso"
      oStruct:SetProperty( "EIJ_VRCII" , MVC_VIEW_TITULO , "II " + STR0116 ) // "II a Recolher"
   endif

   oView:AddField( 'VIEW_EIJ_II', oStruct, 'EIJMASTER_II' )
   oView:SetOwnerView( 'VIEW_EIJ_II', 'BOX_II' )

return nil

/*
Função     : SetViewIPI
Objetivo   : Cria a instância da View para a tabela EIJ (IPI)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2021
Obs.       :
*/
static function SetViewIPI(oView)
   local aCampos  := {}
   local oStruct  := nil
   local nCpo     := 0
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA
   local lCpos     := .F.

   if lDuimpInt
      lCpos := DUIMP2310()
   endif
 
   aCampos := { ;
               {"EIJ_REGIPI","01"},;
               {"EIJ_ASSIPI","02"},;
               {"EIJ_TPAIPI","03"},{"EIJ_ALAIPI","03"};
              }

   if lCpos
      aAdd( aCampos, {"EIJ_VLCIPI" ,"04"} )
      aAdd( aCampos, {"EIJ_VRDIPI" ,"04"} )
      aAdd( aCampos, {"EIJ_VDIPI"  ,"04"} )
      aAdd( aCampos, {"EIJ_VLSIPI" ,"04"} )
      aAdd( aCampos, {"EIJ_VRCIPI" ,"04"} )
   endif

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) } )
   oStruct:AddGroup("01", STR0100, "01", 2) // "Regime de Tributação"
   oStruct:AddGroup("02", STR0101, "01", 2) // "Fundamento"
   oStruct:AddGroup("03", STR0102, "01", 2) // "Alíquotas"
 
   if lCpos
      oStruct:AddGroup("04", STR0111, "01", 2) // "Tributos Registrados"
   endif

   //Remove os Folders
   oStruct:aFolders := {}

   for nCpo := 1 to len(aCampos)
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2] )
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM       , StrZero(nCpo,2) )
   next

   if lCpos
      oStruct:SetProperty( "EIJ_VLCIPI" , MVC_VIEW_TITULO , "IPI " + STR0112 ) // "IPI Calculado"
      oStruct:SetProperty( "EIJ_VRDIPI" , MVC_VIEW_TITULO , "IPI " + STR0113 ) // "IPI a Reduzir"
      oStruct:SetProperty( "EIJ_VDIPI"  , MVC_VIEW_TITULO , "IPI " + STR0114 ) // "IPI Devido"
      oStruct:SetProperty( "EIJ_VLSIPI" , MVC_VIEW_TITULO , "IPI " + STR0115 ) // "IPI Suspenso"
      oStruct:SetProperty( "EIJ_VRCIPI" , MVC_VIEW_TITULO , "IPI " + STR0116 ) // "IPI a Recolher"
   endif

   oView:AddField( 'VIEW_EIJ_IPI', oStruct, 'EIJMASTER_IPI' )
   oView:SetOwnerView( 'VIEW_EIJ_IPI', 'BOX_IPI' )

return nil

/*
Função     : SetViewPISCOFINS
Objetivo   : Cria a instância da View para a tabela EIJ ( PIS COFINS )
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2021
Obs.       :
*/
static function SetViewPISCOFINS(oView)
   local aCampos  := {}
   local oStruct  := nil
   local nCpo     := 0
   local lDuimpInt := SW6->W6_FORMREG == DUIMP_INTEGRADA
   local lCpos     := .F.

   if lDuimpInt
      lCpos := DUIMP2310()
   endif

   aCampos := { ;
               {"EIJ_REG_PC","01"},;
               {"EIJ_FUN_PC","02"},;
               {"EIJ_TPAPIS","03"},{"EIJ_ALAPIS","03"},;
               {"EIJ_TPACOF","04"},{"EIJ_ALACOF","04"};
              }

   if lCpos
      aAdd( aCampos, {"EIJ_VLCPIS" ,"05"} )
      aAdd( aCampos, {"EIJ_VRDPIS" ,"05"} )
      aAdd( aCampos, {"EIJ_VDEPIS" ,"05"} )
      aAdd( aCampos, {"EIJ_VLSPIS" ,"05"} )
      aAdd( aCampos, {"EIJ_VRCPIS" ,"05"} )
      aAdd( aCampos, {"EIJ_VLCCOF" ,"06"} )
      aAdd( aCampos, {"EIJ_VRDCOF" ,"06"} )
      aAdd( aCampos, {"EIJ_VDECOF" ,"06"} )
      aAdd( aCampos, {"EIJ_VLSCOF" ,"06"} )
      aAdd( aCampos, {"EIJ_VRCCOF" ,"06"} )
   endif

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, aCampos) } )
   oStruct:AddGroup("01", STR0100, "01", 2) // "Regime de Tributação"
   oStruct:AddGroup("02", STR0101, "01", 2) // "Fundamento"
   oStruct:AddGroup("03", STR0102 + " - PIS"   , "01", 2) // "Alíquotas"
   oStruct:AddGroup("04", STR0102 + " - COFINS", "01", 2) // "Alíquotas"

   if lCpos
      oStruct:AddGroup("05", STR0111 + " - PIS", "01", 2) // "Tributos Registrados"
      oStruct:AddGroup("06", STR0111 + " - COFINS", "01", 2) // "Tributos Registrados"
   endif

   //Remove os Folders
   oStruct:aFolders := {}

   for nCpo := 1 to len(aCampos)
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_GROUP_NUMBER, aCampos[nCpo][2] )
      oStruct:SetProperty( aCampos[nCpo][1] , MVC_VIEW_ORDEM       , StrZero(nCpo,2) )
   next

   oStruct:SetProperty( "EIJ_TPAPIS" , MVC_VIEW_TITULO , STR0106 ) // "Tip. Aliq. PIS"
   oStruct:SetProperty( "EIJ_ALAPIS" , MVC_VIEW_TITULO , STR0105 ) // "% Ad Val PIS"
   oStruct:SetProperty( "EIJ_TPACOF" , MVC_VIEW_TITULO , STR0104 ) // "Tip. Aliq. COFINS"
   oStruct:SetProperty( "EIJ_ALACOF" , MVC_VIEW_TITULO , STR0103 ) // "% Ad Val COFINS"

   if lCpos
      oStruct:SetProperty( "EIJ_VLCPIS" , MVC_VIEW_TITULO , "PIS " + STR0112 ) // "PIS/COFINS Calculado"
      oStruct:SetProperty( "EIJ_VRDPIS" , MVC_VIEW_TITULO , "PIS " + STR0113 ) // "PIS/COFINS a Reduzir"
      oStruct:SetProperty( "EIJ_VDEPIS" , MVC_VIEW_TITULO , "PIS " + STR0114 ) // "PIS/COFINS Devido"
      oStruct:SetProperty( "EIJ_VLSPIS" , MVC_VIEW_TITULO , "PIS " + STR0115 ) // "PIS/COFINS Suspenso"
      oStruct:SetProperty( "EIJ_VRCPIS" , MVC_VIEW_TITULO , "PIS " + STR0116 ) // "PIS/COFINS a Recolher"
      oStruct:SetProperty( "EIJ_VLCCOF" , MVC_VIEW_TITULO , "COFINS " + STR0112 ) // "PIS/COFINS Calculado"
      oStruct:SetProperty( "EIJ_VRDCOF" , MVC_VIEW_TITULO , "COFINS " + STR0113 ) // "PIS/COFINS a Reduzir"
      oStruct:SetProperty( "EIJ_VDECOF" , MVC_VIEW_TITULO , "COFINS " + STR0114 ) // "PIS/COFINS Devido"
      oStruct:SetProperty( "EIJ_VLSCOF" , MVC_VIEW_TITULO , "COFINS " + STR0115 ) // "PIS/COFINS Suspenso"
      oStruct:SetProperty( "EIJ_VRCCOF" , MVC_VIEW_TITULO , "COFINS " + STR0116 ) // "PIS/COFINS a Recolher"
   endif

   oView:AddField( 'VIEW_EIJ_PISCOFINS', oStruct, 'EIJMASTER_PISCOFINS' )
   oView:SetOwnerView( 'VIEW_EIJ_PISCOFINS', 'BOX_PISCOFINS' )

return nil

/*
Função     : SetViewICMS
Objetivo   : Cria a instância da View para a tabela EIJ (ICMS)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2021
Obs.       :
*/
static function SetViewICMS(oView)
   local oStruct  := nil

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500View("EIJMASTER_ICMS"), "|")) }   )

    //Remove os Folders
   oStruct:aFolders := {}

   oView:AddField( 'VIEW_EIJ_ICMS', oStruct, 'EIJMASTER_ICMS' )
   oView:SetOwnerView( 'VIEW_EIJ_ICMS', 'BOX_ICMS' )

return nil

/*
Função     : SetVObsTrb
Objetivo   : Cria a instância da View para a tabela EIJ (Integração)
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2021
Obs.       :
*/
static function SetVObsTrb(oView)
   local oStruct  := nil

   oStruct := FWFormStruct( 2, "EIJ", {|x| CheckField(x, EasyStrSplit(LP500View("EIJMASTER_OBSTRB"), "|")) }   )

   oStruct:SetProperty( "EIJ_OBSTRB" , MVC_VIEW_TITULO , STR0117 ) // "Obs. Tributos"

    //Remove os Folders
   oStruct:aFolders := {}

   oView:AddField( 'VIEW_EIJ_OBSTRB', oStruct, 'EIJMASTER_OBSTRB' )
   oView:SetOwnerView( 'VIEW_EIJ_OBSTRB', 'BOX_OBSTRB' )

return nil

Static Function CheckField(cField, aFields, lUser)
   Local lRet := .F.
   Default lUser := .T.

   If ValType(aFields) == "A" .And. Len(aFields) > 0
      lRet := (ValType(aFields[1]) == "A" .And. aScan(aFields, {|x| AllTrim(x[1]) == AllTrim(cField) }) > 0) .Or. (ValType(aFields[1]) == "C" .And.  aScan(aFields, AllTrim(cField)) > 0) .Or. (lUser .and. GetSx3Cache(cField, "X3_PROPRI") == "U")
   Else
      lRet := .T.
   EndIf

Return lRet

/*
Função     : Menudef
Objetivo   : Estrutura do MenuDef
Retorno    : aClone(aRotina)
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function MenuDef()
   Local aRotina := {}
   ADD OPTION aRotina TITLE STR0024               ACTION "VIEWDEF.EICLP500" OPERATION 1 ACCESS 0 //"Pesquisar"
   ADD OPTION aRotina TITLE STR0025               ACTION "VIEWDEF.EICLP500" OPERATION 2 ACCESS 0 //"Visualizar"
   ADD OPTION aRotina TITLE STR0026               ACTION "VIEWDEF.EICLP500" OPERATION 3 ACCESS 0 //"Incluir"
   ADD OPTION aRotina TITLE STR0008               ACTION "LP500VINC"        OPERATION 4 ACCESS 0 //Itens DUIMP
   ADD OPTION aRotina TITLE STR0027               ACTION "VIEWDEF.EICLP500" OPERATION 5 ACCESS 0   //"Excluir"

Return aRotina

/*
Class      : LP500EV
Objetivo   : CLASSE PARA CRIAÇÃO DE EVENTOS E VALIDAÇÕES NOS FORMULÁRIOS
Retorno    : Nil
Autor      :
Data       :
Revisão    :
*/
Class LP500EV FROM FWModelEvent

   Method New()
   Method Activate()
   Method VldActivate()

End Class

/*
Class      : Método New Class LP500EV
Objetivo   : Método para criação do objeto
Retorno    : Nil
Autor      :
Data       :
Revisão    :
*/
Method New() Class LP500EV
Return

/*
Class      : Método New Class CP400EV
Objetivo   : Método para ativar o objeto
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Method Activate(oModel) Class LP500EV
   Local oModelSW6	:= oModel:GetModel("SW6MASTER")

   oModelSW6:LoadValue("W6_HAWB", SW6->W6_HAWB)
   ManLstFrm(oModel,'__oQtdSumSWV','SET','')
   ManLstFrm(oModel,'__oLstQtdInf','SET' )
   AllEvPLPCO(oModel)

Return

/*
Class      : Método New Class CP400EV
Objetivo   : Método para ativar o objeto
Retorno    : Nil
Autor      : THTS - Tiago Tudisco
Data       : Mar/2020
Revisão    :
*/
Method VldActivate(oModel) Class LP500EV
   local lRet        := .T.
   local cHelpLP500  := ""
   local cSolLP500   := ""
   local nOperation  := oModel:GetOperation()

   If nOperation == 4
      SW8->(DBSETORDER(1)) //W8_FILIAL + W8_HAWB + W8_INVOICE + W8_FORN + W8_FORLOJ
      If !SW8->(DBSEEK(xFilial("SW8")+SW6->W6_HAWB))
         cHelpLP500 := STR0002 //"Processo não possui Invoices para associação de LPCOs"
         cSolLP500  := STR0004 //"Verifique o processo de embarque e se necessário cadastre Invoice(s)"
         lRet := .F.
      EndIf

      ManLstFrm(oModel,'_nRecEV1','CLEAR')

      if lRet .and. !IsInCallStack("EICLP501") .and. existFunc("DU100VdSW6") .and. !DU100VdSW6( @_nRecEV1, SW6->W6_HAWB )
         lRet := .F.
         cHelpLP500 := STR0107 // "Operação cancelada."
      endif

   EndIf

   If !lRet
      EasyHelp(cHelpLP500, STR0003/*Atenção*/, cSolLP500)
   EndIf

   If lRet

      ManLstFrm(oModel,'__aLstFrmNcm',"CLEAR")
      ManLstFrm(oModel,'__oQtdSumSWV','CLEAR')
      ManLstFrm(oModel,'__oLstQtdInf','CLEAR')

      ManLstFrm(oModel,'__aLstFrmNcm',"SET",'')

      ManLstFrm(oModel,'_oSeqHash','CLEAR')

      ManLstFrm(oModel,'_aCposEKQ',"CLEAR")
      ManLstFrm(oModel,'_aCposEIJ',"CLEAR")
      ManLstFrm(oModel,'_aCposEINA',"CLEAR")
      ManLstFrm(oModel,'_aCposEIND',"CLEAR")
      ManLstFrm(oModel,'_aCposEIK',"CLEAR")
      ManLstFrm(oModel,'_aCposEJ9',"CLEAR")

      ManLstFrm(oModel,'_aCposEKQ',"SET")
      ManLstFrm(oModel,'_aCposEIJ',"SET")
      ManLstFrm(oModel,'_aCposEINA',"SET")
      ManLstFrm(oModel,'_aCposEIND',"SET")
      ManLstFrm(oModel,'_aCposEIK',"SET")
      ManLstFrm(oModel,'_aCposEJ9',"SET")
      ManLstFrm(oModel,'_nSeqDUIMP',"SET",,0)

   EndIf

Return lRet


/*
Função     : LP500Model
Objetivo   : Função que retorna string de campos a serem utilizados pelo modeldef(regra de negócios). Contém campos carregados também internamente
mesmo que não mostrados na tela
Parâmetro  :
Retorno    : String
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function LP500Model(cAlias)
   Local cRet      := ""
   local lCpos     := .F.

   Do CASE
      CASE cAlias == 'SW9'
         cRet := "|W9_FILIAL|W9_HAWB|W9_INVOICE|W9_FORN|W9_FORLOJ|W9_NOM_FOR|W9_INCOTER|W9_COND_PA|W9_MOE_FOB|"

      CASE cAlias == 'SWV'
         cRet := '|WV_FILIAL|WV_SEQDUIM|WV_PO_NUM|WV_POSICAO|WV_REG|WV_CC|WV_SI_NUM|WV_FORN|WV_FORLOJ|WV_INVOICE|WV_COD_I|WV_PGI_NUM|WV_HAWB|WV_SEQUENC|WV_DESC_DI'+;
            '|WV_NCM|WV_QTDE|WV_DT_VALI|WV_LOTE|WV_DT_VALI|WV_OBS|WV_DFABRI|WV_LPCOPND|WV_NOMEFOR|WV_ID|'

      CASE cAlias == 'EKQ'
         cRet := '|EKQ_FILIAL|EKQ_HAWB|EKQ_INVOIC|EKQ_PO_NUM|EKQ_POSICA|EKQ_SEQUEN|EKQ_ORGANU|EKQ_FRMLPC|EKQ_DSCFRM|EKQ_LPCO|EKQ_OBRFRM|EKQ_VERSAO|EKQ_IDLPCO|'

      CASE substr(cAlias, 1, 3) == 'EIJ'
         cRet := '|EIJ_FILIAL|EIJ_HAWB|EIJ_IDWV'
         
         if cAlias == "EIJ"
            cRet += '|EIJ_VINCCO|EIJ_APLICM|EIJ_MATUSA|EIJ_QT_EST|EIJ_PESOL|EIJ_MOEDA|EIJ_VLMLE|EIJ_FORN'+;
               '|EIJ_FABFOR|EIJ_PO_NUM|EIJ_EX_NCM|EIJ_EX_NBM|EIJ_NROLI|EIJ_ASSVIC|EIJ_ASSVIB|EIJ_ATOVIC|EIJ_ATOVIB'+; //ANALISER SE VAI REMOVER TODOS OS CAMPOS DESTA LINHA NA PRÓXIMA ESTÓRIA
               '|EIJ_EX_VIB|EIJ_EX_VIC|EIJ_ORGVIC|EIJ_ORGVIB|EIJ_NROVIC|EIJ_NROVIB|EIJ_ANOVIC|EIJ_ANOVIB|EIJ_NALASH|EIJ_NALANC|EIJ_UM_EST|EIJ_EXOICM|EIJ_REGICM|EIJ_VLMMN|EIJ_BENSEN|EIJ_INCOTE|EIJ_METVAL|EIJ_VSEGMN|EIJ_VFREMN|EIJ_LOCVEN|EIJ_MOTADI|EIJ_TACOII|EIJ_ACO_II|EIJ_ASSII|EIJ_BAS_II|EIJ_EX_II|EIJ_ATO_II|EIJ_ORG_II|EIJ_NRATII|EIJ_ANO_II|EIJ_ALA_II|EIJ_ALR_II|EIJ_PR_II|EIJ_CALCII|EIJ_ALU_II|EIJ_QTU_II|EIJ_VL_II|EIJ_VLR_II|EIJ_DEVII|EIJ_VLARII|EIJ_BASIPI|EIJ_EX_IPI|EIJ_ATOIPI|EIJ_ORGIPI|EIJ_NROIPI|EIJ_ANOIPI|EIJ_ALRIPI|EIJ_NCTIPI|EIJ_CALIPI|EIJ_ALUIPI|EIJ_PRIPI'+;  //ANALISER SE VAI REMOVER TODOS OS CAMPOS DESTA LINHA NA PRÓXIMA ESTÓRIA
               '|EIJ_QTUIPI|EIJ_UNUIPI|EIJ_QTRIPI|EIJ_TPRECE|EIJ_VLDIPI|EIJ_VLAIPI|EIJ_TPADUM|EIJ_VLD_DU|EIJ_EXDUMP|EIJ_VLR_DU|EIJ_ATODUM|EIJ_ALEADU|EIJ_BAE_AD|EIJ_ORGDUM|EIJ_UNE_AD|EIJ_BAD_AD|EIJ_ALADDU|EIJ_ASSDUM|EIJ_ANODUM|EIJ_NRODUM|EIJ_TIPCOB|EIJ_MODALI|EIJ_INSTFI|EIJ_MOTIVO|EIJ_TXB_JU|EIJ_NRROF|EIJ_TXA_JU|EIJ_TEMJUR|EIJ_TEMVAR|EIJ_VL_FIN|EIJ_QTPARC|EIJ_PERPAR|EIJ_PERIOD|EIJ_COMIAG|EIJ_COMIVL|EIJ_TPAGE|EIJ_AGENID|EIJ_AGENOM|EIJ_AGEEND|EIJ_AGEBCO|EIJ_AGEAGE|EIJ_VLM360|EIJ_TX_FRE|EIJ_COBDES|EIJ_VLFRET|EIJ_CONDPG|EIJ_MOEFRE|EIJ_DIASPG|EIJ_COMPLE|EIJ_VLICMS|EIJ_MOESEG|EIJ_FLGICM|EIJ_URFENT|EIJ_TX_SEG|EIJ_VSEGLE|EIJ_PAISPR|EIJ_TX_FOB|EIJ_FRB_PC|EIJ_RATACR|EIJ_PRB_PC|EIJ_TEC_CL'+; //ANALISER SE VAI REMOVER TODOS OS CAMPOS DESTA LINHA NA PRÓXIMA ESTÓRIA
               '|EIJ_MERCOS|EIJ_TAXSIS|EIJ_REDPIS|EIJ_NVE|EIJ_ALUPIS|EIJ_QTUPIS|EIJ_REDCOF|EIJ_ALUCOF|EIJ_QTUCOF|EIJ_UNUPIS|EIJ_BASPIS|EIJ_BR_PIS|EIJ_VLDPIS|EIJ_VLRPIS|EIJ_UNUCOF|EIJ_BASCOF|EIJ_BR_COF|EIJ_VLDCOF|EIJ_VLRCOF|EIJ_PAISEM|EIJ_DICERT|EIJ_ITDICE|EIJ_DEMERC|EIJ_REINIC|EIJ_QTDCER|EIJ_REFINA|EIJ_ARDPIS|EIJ_IDCERT|EIJ_ARDCOF|EIJ_ALPROP|EIJ_VLICMD|EIJ_VLRIPI|EIJ_PAISOR|EIJ_CODMAT|EIJ_ALCOFM|EIJ_ALPISM|EIJ_BASICM'+; //ANALISER SE VAI REMOVER TODOS OS CAMPOS DESTA LINHA NA PRÓXIMA ESTÓRIA
               '|EIJ_MOTIVO|EIJ_FORLOJ|EIJ_FORNVM|EIJ_FABR|EIJ_FABLOJ|EIJ_FABRVM|EIJ_METVAL|EIJ_INCOTE|EIJ_MODALI|EIJ_NRROF|EIJ_INSTFI|EIJ_ADICAO'+; //REMOVER O CAMPO EIJ_aDICAO NA PRÓXIMA ESTÓRIA'
               '|EIJ_IDPTCP|EIJ_VRSACP|EIJ_IMPORT|EIJ_NOMIMP|EIJ_CNPJRZ|EIJ_DSCCIT|EIJ_UNIDCO|EIJ_QTDECO|EIJ_UNDEST|EIJ_TINFA|EIJ_TINFO'

            if _EIJVERSAO
               cRet += '|EIJ_VRSFOR|EIJ_VRSFAB'
            endif
         endif

         lCpos := DUIMP2310()

         if cAlias == "EIJMASTER_II" .or. cAlias == "EIJ"
            cRet += '|EIJ_REGTRI|EIJ_FUNREG|EIJ_TPAII|EIJ_ALI_II'
            if lCpos
               cRet += '|EIJ_VLCII|EIJ_VRDII|EIJ_VLDII|EIJ_VLSII|EIJ_VRCII'
            endif
         endif

         if cAlias == "EIJMASTER_IPI" .or. cAlias == "EIJ"
            cRet += '|EIJ_REGIPI|EIJ_ASSIPI|EIJ_TPAIPI|EIJ_ALAIPI'
            if lCpos
               cRet += '|EIJ_VLCIPI|EIJ_VRDIPI|EIJ_VDIPI|EIJ_VLSIPI|EIJ_VRCIPI'
            endif
         endif

         if cAlias == "EIJMASTER_PISCOFINS" .or. cAlias == "EIJ"
            cRet += '|EIJ_REG_PC|EIJ_FUN_PC|EIJ_TPAPIS|EIJ_ALAPIS|EIJ_TPACOF|EIJ_ALACOF'
            if lCpos
               cRet += '|EIJ_VLCPIS|EIJ_VRDPIS|EIJ_VDEPIS|EIJ_VLSPIS|EIJ_VRCPIS'
               cRet += '|EIJ_VLCCOF|EIJ_VRDCOF|EIJ_VDECOF|EIJ_VLSCOF|EIJ_VRCCOF'
            endif
         endif

         if cAlias == "EIJMASTER_ICMS" .or. cAlias == "EIJ"
            cRet += '|EIJ_OPERAC'
         endif

         if ( cAlias == "EIJMASTER_OBSTRB" .or. cAlias == "EIJ") .and. lCpos
            cRet += '|EIJ_OBSTRB'
         endif

         cRet += '|'

      CASE cAlias == 'EIK'
         cRet := '|EIK_FILIAL|EIK_HAWB|EIK_IDWV|EIK_TIPVIN|EIK_DOCVIN|'

      CASE cAlias == 'EINA'
         cRet := '|EIN_FILIAL|EIN_HAWB|EIN_IDWV|EIN_TIPO|EIN_CODACR|EIN_CODIGO|EIN_DESC|EIN_FOBMOE|EIN_VLMLE|EIN_VLMMN|'

      CASE cAlias == 'EIND'
         cRet := '|EIN_FILIAL|EIN_HAWB|EIN_IDWV|EIN_TIPO|EIN_CODDED|EIN_CODIGO|EIN_DESC|EIN_FOBMOE|EIN_VLMLE|EIN_VLMMN|'

      CASE cAlias == 'EJ9'
         cRet := '|EJ9_FILIAL|EJ9_HAWB|EJ9_IDWV|EJ9_DEMERC|EJ9_IDCERT|EJ9_QTDCER|'

   END CASE

Return  cRet

/*
Função     : LP500View
Objetivo   : Função que retorna string de campos a serem exibidos e utilizados pela rotina(tela)
Parâmetro  :
Retorno    : String
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function LP500View(cAlias,nType)
   Local cRet := ""
   Default nType := 0
   Do CASE
      CASE cAlias == 'SW9'
         cRet := '|W9_FILIAL|W9_HAWB|W9_INVOICE|W9_FORN|W9_FORLOJ|W9_NOM_FOR|'

      CASE cAlias == 'SWV'
         If nType == 0
            cRet := '|WV_SEQDUIM|WV_PO_NUM|WV_POSICAO|WV_SEQUENC|WV_COD_I|WV_DESC_DI|WV_NCM|WV_QTDE|WV_DT_VALI'+;
               '|WV_LOTE|WV_DT_VALI|WV_OBS|WV_DFABRI|WV_LPCOPND|WV_ID|'
         ElseIf nType == 1
            cRet := '|WV_SEQDUIM|WV_PO_NUM|WV_POSICAO|WV_SEQUENC|WV_COD_I|WV_DESC_DI|WV_NCM|WV_QTDE|'
         EndIf

      CASE cAlias == 'EKQ'
         cRet := '|EKQ_ORGANU|EKQ_FRMLPC|EKQ_DSCFRM|EKQ_LPCO|EKQ_OBRFRM|EKQ_VERSAO|'

/*    CASE cAlias == 'EIJ'
         cRet := '|EIJ_VINCCO|EIJ_APLICM|EIJ_MATUSA|EIJ_QT_EST|EIJ_PESOL|EIJ_MOEDA|EIJ_VLMLE'+;
            '|EIJ_IDPTCP|EIJ_VRSACP|EIJ_IMPORT|EIJ_NOMIMP|EIJ_CNPJRZ|EIJ_DSCCIT|EIJ_UNIDCO|EIJ_QTDECO|EIJ_UNDEST|EIJ_TIPCOB|EIJ_MODALI|'
*/
      CASE cAlias == 'EIK'
         cRet := '|EIK_TIPVIN|EIK_DOCVIN|'

      CASE cAlias == 'EINA'
         cRet := 'EIN_CODACR|EIN_DESC|EIN_FOBMOE|EIN_VLMLE|EIN_VLMMN|'

      CASE cAlias == 'EIND'
         cRet := 'EIN_CODDED|EIN_DESC|EIN_FOBMOE|EIN_VLMLE|EIN_VLMMN|'

      CASE cAlias == 'EJ9'
         cRet := '|EJ9_DEMERC|EJ9_IDCERT|EJ9_QTDCER|'

      Case cAlias == "EIJMASTER_ICMS"
         cRet := '|EIJ_OPERAC|'

      Case cAlias == "EIJMASTER_OBSTRB"
         cRet := '|EIJ_OBSTRB|'

   END CASE

Return cRet

/*
Função     : LP500VALID
Objetivo   : Função de validação
Parâmetro  : 1. Id do campo alterado
             2. submodelo
             3. valor atribuído ao campo
             4. se for formgrid, o número da linha alterada; se for formfields, valor anterior do campo
             5. se for formgrid, valor anterior do campo
Retorno    : .T. ou .F. se validou
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Function LP500VALID(cCampo, oSubModel, xNewVl, xValue1, xValue2)
   Local aArea          := GetArea()
   Local oModel         := FWModelActive()
   Local oModelEKQ
   Local cVersaoUlt     := ""
   Local lRet := .T.
   Local cHelpProbl, cCNPJProc
   Local cPais
   Local cIdCatalogo:= ""
   Local cFabricante
   Local cProduto
   Local nLine
   Local xOldValue
   Local cVersao
   Local cNcm
   Local cVerFabFor

   If oSubModel <> Nil
      If oSubModel:ClassName() == "FWFORMGRID"
         nLine:= xValue1
         xOldValue:= xValue2
      Else //FWFORMFIELDS
         xOldValue:= xValue1
      EndIf
   EndIf

   If ValType(oModel) == 'O'
      oModelEKQ := oModel:GetModel("EKQDETAIL")
      Do Case
         Case cCampo == 'EKQ_LPCO'
            If !Empty(oModelEKQ:GetValue("EKQ_ORGANU"))
               If !Empty(oModelEKQ:GetValue("EKQ_FRMLPC"))
                  lRet := Vazio() .OR. ExistCpo("EKO", oModelEKQ:GetValue("EKQ_ORGANU")+oModelEKQ:GetValue("EKQ_FRMLPC")+oModelEKQ:GetValue("EKQ_LPCO"), 3)
               Else
                  EasyHelp(STR0020, STR0003, STR0021) //"O campo Formulário do LPCO não foi preenchido", "Atenção", "Será necessário prencher o Formulário do LPCO antes de digitar LPCO")
               EndIf
            Else
               EasyHelp(STR0022, STR0003, STR0023) //"O campo Órgão anuente não foi preenchido", "Atenção", "Será necessário prencher o Órgão anuente antes de digitar LPCO"
            EndIf
         Case cCampo == 'EKQ_VERSAO'
            If NaoVazio()
               If !Empty(oModelEKQ:GetValue("EKQ_LPCO"))
                  If !Empty(oModelEKQ:GetValue("EKQ_VERSAO"))
                     lRet := Vazio() .OR. ExistCpo("EKO", oModelEKQ:GetValue("EKQ_LPCO")+oModelEKQ:GetValue("EKQ_VERSAO"), 2)
                     If lRet
                        EKO->(DbSetOrder(2)) //Filial + LPCO + Versão
                        If EKO->(AvSeekLAst(xFilial("EKO") + oModelEKQ:GetValue("EKQ_LPCO")))
                           cVersaoUlt := EKO->EKO_VERSAO
                        EndIf
                        If !Empty(cVersaoUlt) .And. cVersaoUlt <> oModelEKQ:GetValue("EKQ_VERSAO")
                           If IsMemVar("lLP500Auto") .And. !lLP500Auto .And. !MsgYesNo(STR0010)  //"Versão digitada/escolhida não é a última existente para o LPCO. Deseja prosseguir?"
                              lRet := .F.
                           EndIf
                        EndIf
                     Else
                        EasyHelp(STR0011, STR0003, STR0012) //"Versão digitada não encontrada na Base de dados para o LPCO" #Atenção # "Digite uma versão válida. "
                        lRet := .F.
                     EndIf
                  EndIf
               Else
                  EasyHelp(STR0013, STR0003, STR0014) //"O campo LPCO não foi preenchido." #Atenção # "Preencha um LPCO válido antes de preencher a Versão do LPCO"
                  lRet := .F.
               EndIf
            EndIf
         Case cCampo == 'EKQ_ORGANU'
            lRet := Vazio() .Or. ExistCpo( "SJJ", oModelEKQ:GetValue("EKQ_ORGANU" ))
         Case cCampo == 'EKQ_FRMLPC'
            if !Vazio()
               lRet := ExistCpo( "EKL", oModelEKQ:GetValue("EKQ_ORGANU" )+oModelEKQ:GetValue("EKQ_FRMLPC" ))
               if lRet
                  lRet := VldEKQ( oModelEKQ )
               endif
            endif
         Case cCampo == 'WV_QTDE'
            lRet := AltQtdLote(oModel)
         Case cCampo == 'EIJ_IDPTCP'
            If !Vazio()
               cNCM := oModel:GetModel():GetValue("SWVDETAIL","WV_NCM")
               EKD->(DbSetOrder(2)) // EKD_FILIAL + EKD_NCM + EKD_IDPORT + EKD_VERSAO
               If EKD->(AvSeekLast( xFilial("EKD") + cNcm  + AvKey(xNewVl,"EKD_IDPORT")  ))
                  Begin Sequence
                     /*If EKD->EKD_NCM <> oModel:GetModel():GetValue("SWVDETAIL","WV_NCM")
                            cHelpProbl := StrTran( STR0070,    'XXXXXXXXXX', EKD->EKD_NCM                                      ) //"A N.c.m 'XXXXXXXXXX' do catálogo de produtos para o ID informado não corresponde à N.c.m 'YYYYYYYYYY' do item da invoice deste processo!"
                            cHelpProbl := StrTran( cHelpProbl, 'YYYYYYYYYY', oModel:GetModel():GetValue("SWVDETAIL","WV_NCM")  )
                            EasyHelp(cHelpProbl, STR0003,STR0071 )                                                    //"Informe outro ID ou ajuste o cadastro do catálogo de produtos ou ainda ajuste a N.c.m do item do processo para corresponder à N.c.m do catálogo!"
                            lRet := .F.
                            Break
                     EndIf*/
                     cVersao := oModel:GetModel():GetValue("EIJMASTER","EIJ_VRSACP")
                     If !empty(cVersao) .And. cVersao != EKD->EKD_VERSAO
                        EasyHelp(StrTran(STR0076,'#####',cNcm), STR0003, StrTran(STR0077,'#####',cNcm)) // "ID Portal informado não existe no catálogo de produtos ou não encontrado no histórico de integrações do Catálogo de Produtos ou não pertence a NCM:" !" ### "Informe um ID existente no catálogo de produtos e que já esteja integrado e pertencente a NCM:"
                        lRet := .F.
                        break
                     EndIf

                     If !(EKD->EKD_MODALI $ "1|3")
                        EasyHelp(STR0072, STR0003,STR0073 )    //"A modalidade deste item no catálogo de produtos é incompatível com a modalidade deste processo!"
                        lRet := .F.                                       //"Informe outro ID o qual a modalidade seja '1-Importação' ou '3-Ambos' ou ajuste o cadastro do catálogo de produtos para este ID informado!"
                        Break
                     EndIf
                     If EKD->EKD_CNPJ <> (cCNPJProc := Left( POSICIONE("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC") ,8 ) ) //Somente a raíz do CNPJ
                        cHelpProbl := StrTran( STR0074,    'XXXXXXXX', EKD->EKD_CNPJ ) //"A Raíz do CNPJ deste item no catálogo de produtos 'XXXXXXXX' diverge da raíz de CNPJ do importador do processo 'YYYYYYYY' "
                        cHelpProbl := StrTran( cHelpProbl, 'YYYYYYYY', cCNPJProc     )
                        EasyHelp(cHelpProbl, STR0003,STR0075)               //"Informe outro ID que tenha a raíz de CNPJ no cadastro compatível com a raíz de CNPJ do importador do processo ou ajuste o cadastro do catálogo de produtos para este ID informado!"
                        lRet := .F.
                        Break
                     EndIf
                  End Sequence
               else
                  EasyHelp(StrTran(STR0076,'#####',cNcm), STR0003, StrTran(STR0077,'#####',cNcm)) // "ID Portal informado não existe no catálogo de produtos ou não encontrado no histórico de integrações do Catálogo de Produtos ou não pertence a NCM:" !" ### "Informe um ID existente no catálogo de produtos e que já esteja integrado e pertencente a NCM:"
                  lRet := .F.
               EndIf
            EndIf
         Case cCampo == 'EIJ_VRSACP'
            lRet := Vazio()
            If !lRet
               EKD->(DbSetOrder(2)) // EKD_FILIAL + EKD_NCM + EKD_IDPORT + EKD_VERSAO
               If EKD->(DbSeek( xFilial("EKD") + oModel:GetModel():GetValue("SWVDETAIL","WV_NCM") + oModel:GetModel():GetValue("EIJMASTER","EIJ_IDPTCP") + AvKey(xNewVl,"EKD_VERSAO")  ))
                  EKD->(AvSeekLast( xFilial("EKD") + oModel:GetModel():GetValue("SWVDETAIL","WV_NCM") + oModel:GetModel():GetValue("EIJMASTER","EIJ_IDPTCP")  ))
                  If AvKey(xNewVl,"EKD_VERSAO") == EKD->EKD_VERSAO
                     lRet := .T.
                  else
                     cHelpProbl := StrTran( STR0085,    'XXXXXXXX', xNewVl ) //A versão do produto no catálogo informada "XXXXXXXX" não é a atual "YYYYYYYY" !
                     cHelpProbl := StrTran( cHelpProbl, 'YYYYYYYY', EKD->EKD_VERSAO)
                     EasyHelp(cHelpProbl, STR0003,STR0086) //"Informe a versão mais atualizada do produto no catálogo conforme identificada pelo sistema!"
                  EndIf
               else
                  EasyHelp( STR0087, STR0003, STR0088) //'A versão informada não existe para este item no catálogo ou não está registrada no portal único!', STR0003, 'Informe a última versão válida para este produto no catálogo!'
               EndIf
            EndIf
         Case cCampo == 'EIJ_FABR'
            lRet := Vazio() .Or. ExistCpo( "SA2" , oModel:GetModel():GetValue("EIJMASTER","EIJ_FABR") )
         Case cCampo == 'EIJ_FABLOJ'

            lRet := Vazio()
            If !lRet

               cFabricante:= AllTrim(oModel:GetModel():GetValue("EIJMASTER","EIJ_FABR")) + " / " + oModel:GetModel():GetValue("EIJMASTER","EIJ_FABLOJ")
               cProduto:= oModel:GetModel():GetValue("SWVDETAIL","WV_COD_I")

               If ExistCpo( "SA2" , oModel:GetModel():GetValue("EIJMASTER","EIJ_FABR") + oModel:GetModel():GetValue("EIJMASTER","EIJ_FABLOJ") )

                  EKD->(DbSetOrder(2)) // EKD_FILIAL + EKD_NCM + EKD_IDPORT + EKD_VERSAO
                  EKD->(DbSeek( xFilial("EKD") + oModel:GetModel():GetValue("SWVDETAIL","WV_NCM") + oModel:GetModel():GetValue("EIJMASTER","EIJ_IDPTCP") + oModel:GetModel():GetValue("EIJMASTER","EIJ_VRSACP")  ))

                  cIdCatalogo:= AllTrim(EKD->EKD_IDPORT) + " / " + AllTrim(EKD->EKD_VERSAO)

                  //Verifica se o produto está nesta versão de catálogo, bem como o fabricante
                  EKE->(DBSetOrder(2)) //EKE_FILIAL+EKE_COD_I+EKE_VERSAO+EKE_PRDREF
                  EKF->(DbSetOrder(1)) //EKF_FILIAL+EKF_COD_I+EKF_VERSAO+EKF_CODFAB+EKF_LOJA+EKF_PAIS
                  If EKE->(DBSeek(xFilial("EKE") + EKD->EKD_COD_I + oModel:GetModel():GetValue("EIJMASTER","EIJ_VRSACP") + cProduto)) .And.;
                        EKF->(DbSeek( xFilial("EKF") + EKD->EKD_COD_I + oModel:GetModel():GetValue("EIJMASTER","EIJ_VRSACP") + oModel:GetModel():GetValue("EIJMASTER","EIJ_FABR") + oModel:GetModel():GetValue("EIJMASTER","EIJ_FABLOJ") ))
                     lRet := .T.
                  else
                     EasyHelp(StrTran(StrTran(StrTran(STR0089, "###", cFabricante), "***", cIdCatalogo), "$$$", AllTrim(cProduto)), STR0003, STR0090) //"O Fabricante ### não está vinculado ao produto $$$ da versão *** do Catálogo de Produtos."/// 'Informe um Fabricante válido vinculado ao item!'
                  EndIf
               else
                  EasyHelp(StrTran(STR0093, "###", cFabricante), STR0003, STR0094) //'O Fabricante ### não está cadastrado.' //"Verifique o cadastro de Fornecedores/ Fabricantes."
               EndIf
            EndIf
         Case cCampo == 'EIJ_PAISOR'
            lRet := Vazio() .Or. ExistCpo("SYA")

         Case cCampo == 'EIN_FOBMOE'
            lRet := Vazio() .OR. ExistCpo("SYF",xNewVl)
         Case cCampo == 'EIN_VLMLE'
            lRet := Positivo(xNewVl)
         Case cCampo == 'EJ9_DEMERC'
            SYA->(dbSetOrder(1))
            cPais := oModel:GetModel():GetValue("EIJMASTER","EIJ_PAISPR")
            IF !EMPTY(xNewVl) .AND.  (Empty(cPais) .or. !(POSICIONE("SYA",1,xFilial("SYA") + cPais,"YA_MERCOSU") $ cSim) )
               EasyHelp(STR0078, STR0003) //Atenção  // A declaração só deve ser informada se o país de procedência for membro do Mercosul.
               lRet := .F.
            EndIf

         Case cCampo == 'EIN_CODACR'
            lRet:= Vazio() .Or. ExistCpo("SJN", xNewVl)

         Case cCampo == 'EIN_CODDED'
            lRet:= Vazio() .Or. ExistCpo("SJO", xNewVl)

         Case cCampo == 'EIK_TIPVIN'
            //Opções para a DUIMP
            lRet:= Vazio() .Or. Pertence("1234")
         Case cCampo == "WV_SEQDUIM"

            xNewVl := if (xNewVl == nil .Or. ValType("cVlNew") # "C" ,"",StrZero(Val(xNewVl), AVSX3("WV_SEQDUIM", AV_TAMANHO)))
            If  !Empty(xNewVl) .And. xNewVl # xOldValue
               lRet:= ValidaItemDuimp(oModel, oSubModel, cCampo, xNewVl, nLine )
               If !lRet
                  EasyHelp(STR0047,STR0048,STR0049) //"Sequência DUIMP repetida","AVISO","Informe uma sequência ainda não utilizada"
               EndIf
            EndIf
         CASE cCampo == 'EIJ_VRSFOR' .or. cCampo == 'EIJ_VRSFAB'
            cVerFabFor  := xNewVl
            cIdCatalogo := oModel:GetModel():GetValue("EIJMASTER","EIJ_IDPTCP")
            cVersao     := oModel:GetModel():GetValue("EIJMASTER","EIJ_VRSACP")
            lRet := Empty(xNewVl) .or. xNewVl == GetFabFor("VERSAO", if(cCampo == "EIJ_VRSFOR", "FOR", "FAB"), cIdCatalogo , cVersao, oModel )
            if !lRet 
               EasyHelp(STR0124,STR0003,STR0125) //"Versão não encontrada no cadastro do operador estrangeiro","ATENÇÃO","Informe uma versão válida"
            EndIf   
      EndCase
   EndIf
   RestArea(aArea)

Return lRet

/*
Função     : LP500WHEN
Objetivo   : Função para saber se campo pode ou nao ser habilitado para edição na tela
Parâmetro  :
Retorno    : .T. ou .F.
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Function LP500WHEN(cCampo)
   Local aArea          := GetArea()
   Local oModel         := FWModelActive()
   Local lRet := .T.

   Do CASE
      Case cCampo == 'EIJ_TINFA'
         lRet :=  LP500GetInfo('SA2', 1, xFilial('SA2') + oModel:GetModel():GetValue('EIJMASTER','EIJ_FABR') + oModel:GetModel():GetValue('EIJMASTER','EIJ_FABLOJ') , "A2_PAIS" )  <> '105'
      Case cCampo == 'EIJ_TINFO'
         lRet :=  LP500GetInfo('SA2', 1, xFilial('SA2') + oModel:GetModel():GetValue('EIJMASTER','EIJ_FORN') + oModel:GetModel():GetValue('EIJMASTER','EIJ_FORLOJ') , "A2_PAIS" )  <> '105'
      Case cCampo == 'EIJ_FABR'
         lRet := .T.
      Case cCampo == 'EIJ_FABLOJ'
         lRet := .T.
      Case cCampo == 'EIJ_PAISOR'
         lRet := .T.
      Case cCampo == 'EIJ_MODALI'
         lRet := .F.
      Case cCampo == 'EIJ_TIPCOB'
         lRet := .F.
      Case cCampo == 'EIJ_MOEDA'
         lRet := .F.
      Case cCampo == 'EIJ_VL_FIN'
         lRet := .F.
      Case cCampo == 'EIJ_MOTIVO'
         lRet := .F.
      Case cCampo == 'WV_SEQDUIM'    
         lRet := SW6->W6_FORMREG != DUIMP_INTEGRADA
      // campo EIJ - II 
      CASE cCampo == 'EIJ_REGTRI'
         lRet := .T.
      CASE cCampo == 'EIJ_FUNREG'
         lRet := !alltrim(oModel:GetModel():GetValue('EIJMASTER_II','EIJ_REGTRI')) == "1"
      CASE cCampo == 'EIJ_TPAII'
         lRet := .F.
      CASE cCampo == 'EIJ_ALI_II'
         lRet := .T.
      // campo EIJ - IPI
      CASE cCampo == 'EIJ_REGIPI'
         lRet := .T.
      CASE cCampo == 'EIJ_ASSIPI'
         lRet := !alltrim(oModel:GetModel():GetValue('EIJMASTER_IPI','EIJ_REGIPI')) == "4"
      CASE cCampo == 'EIJ_TPAIPI'
         lRet := .F.
      CASE cCampo == 'EIJ_ALAIPI'
         lRet := .T.
      // campo EIJ - PIS COFINS
      CASE cCampo == 'EIJ_REG_PC'
         lRet := .T.
      CASE cCampo == 'EIJ_FUN_PC'
         lRet := !alltrim(oModel:GetModel():GetValue('EIJMASTER_PISCOFINS','EIJ_REG_PC')) == "1"
      CASE cCampo == 'EIJ_TPAPIS'
         lRet := .F.
      CASE cCampo == 'EIJ_ALAPIS'
         lRet := .T.
      CASE cCampo == 'EIJ_TPACOF'
         lRet := .F.
      CASE cCampo == 'EIJ_ALACOF'
         lRet := .T.
      // campo EIJ - ICMS 
      CASE cCampo == 'EIJ_OPERAC'
         lRet := .T.
      CASE cCampo == 'EIJ_VRSFOR' .or. cCampo =='EIJ_VRSFAB'
         lRet := !Empty(oModel:GetModel():GetValue('EIJMASTER','EIJ_IDPTCP')) .and. !Empty(oModel:GetModel():GetValue('EIJMASTER','EIJ_VRSACP')) 
   EndCase

   RestArea(aArea)

Return lRet

/*
Objetivo      : Função para carregar dados na SWV - Grid da porção superior da tela
Retorno    : Nil
Autor      : Ramon Prado
Data       : Agosto/2021
Revisão    :
*/
Static Function LP500SWVLoad(oModel)
   Local cQuery        := ""
   Local aFilCpos      := {}
   Local cCposMostra   := LP500Model("SWV")
   Local oStrGrdSWV	   := oModel:getStruct()
   Local aCpoSWV       := {}
   Local nContCpo      := 0
   Local cCpoNao       := LP500NAO()
   Local cCampo        := ""
   Local cChavForn     := ""
   Local nRecnoSWV     := 0
   Local aDados        := {}
   Local cSeqDuim      := ""
   local nSeqDuim      := ManLstFrm(oModel,'_nSeqDUIMP',"GET")
   local oMdl          := oModel:GetModel()
   local oModelSW9     := oMdl:GetModel("SW9DETAIL")

   aCpoSWV := oStrGrdSWV:GetFields()

   cQuery := " SELECT "
   cQuery += "SW8.W8_FILIAL, SW8.W8_HAWB, SW8.W8_PGI_NUM, SW8.W8_FORN, SW8.W8_FORLOJ, SW8.W8_QTDE, " + ENTER
   cQuery += " SW8.W8_INVOICE, SW8.W8_PO_NUM, SW8.W8_CC, SW8.W8_SI_NUM, SW8.W8_COD_I, SW8.W8_DESC_DI," + ENTER
   cQuery += " SW8.W8_POSICAO, SW8.W8_REG, SW8.W8_TEC, SWV.WV_FILIAL, SWV.WV_PGI_NUM, SWV.WV_FORN, SWV.WV_FORLOJ ," + ENTER
   cQuery += " SWV.WV_PO_NUM, SWV.WV_CC, SWV.WV_SI_NUM, SWV.WV_COD_I, SWV.WV_POSICAO, SWV.WV_REG, SWV.WV_HAWB, SWV.WV_SEQDUIM, SWV.WV_INVOICE, SWV.WV_LOTE," + ENTER
   cQuery += " SWV.WV_QTDE, SWV.WV_OBS, SWV.WV_LPCOPND, SWV.WV_DFABRI, SWV.WV_DT_VALI, SWV.WV_SEQUENC,  SWV.WV_ID, SWV.R_E_C_N_O_ SWVRECNO FROM " + RetSQLName("SW8") + " SW8" + ENTER
   cQuery += "	LEFT JOIN " + RetSQLName("SWV") + " SWV" + ENTER
   cQuery += "		ON SW8.W8_FILIAL = SWV.WV_FILIAL " + ENTER
   cQuery += "		AND SW8.W8_HAWB = SWV.WV_HAWB " + ENTER
   cQuery += "     AND SW8.W8_INVOICE = SWV.WV_INVOICE " + ENTER
   cQuery += "     AND SW8.W8_COD_I = SWV.WV_COD_I " + ENTER
   cQuery += "     AND SW8.W8_PO_NUM = SWV.WV_PO_NUM " + ENTER
   cQuery += "     AND SW8.W8_POSICAO = SWV.WV_POSICAO " + ENTER
   cQuery += "     AND SW8.W8_FORN = SWV.WV_FORN " + ENTER
   cQuery += "     AND SW8.W8_FORLOJ = SWV.WV_FORLOJ " + ENTER
   cQuery += "     AND SWV.D_E_L_E_T_ = ' ' " + ENTER
   cQuery += "	WHERE SW8.W8_FILIAL = '" + xFilial("SW8") + "' " + ENTER
   cQuery += "		AND SW8.W8_HAWB  = '" + SW6->W6_HAWB + "' " + ENTER
   cQuery += "		AND SW8.D_E_L_E_T_ = ' ' " + ENTER
   cQuery += "     AND SW8.W8_INVOICE = '"+oModelSW9:GetValue("W9_INVOICE")+"'"
   cQuery += "     AND SW8.W8_FORN = '"+oModelSW9:GetValue("W9_FORN")+"'"
   cQuery += "     AND SW8.W8_FORLOJ = '"+oModelSW9:GetValue("W9_FORLOJ")+"'"
   cQuery += " ORDER BY W8_FILIAL, W8_HAWB, W8_INVOICE, W8_FORN, W8_FORLOJ, W8_PO_NUM, W8_POSICAO, WV_SEQUENC "

   cQuery:= ChangeQuery(cQuery)
   EasyQry(cQuery, "WkQuery")

   WkQuery->(DBGoTop())
   While WkQuery->(!EOF())
      nSeqDuim += 1
      nRecnoSWV := WkQuery->SWVRECNO
      For nContCpo := 1 to Len(aCpoSWV)
         cCampo := aCpoSWV[nContCpo][3]
         If cCampo == "WV_SEQUENC"
            aAdd(aFilCpos, If(nRecnoSWV == 0, STRZERO(1, AVSX3("WV_SEQUENC",3)), WkQuery->WV_SEQUENC ))
         ElseIf cCampo == "WV_NCM"
            aAdd(aFilCpos, WkQuery->&("W8_TEC"))
         ElseIf cCampo == "WV_LOTE"
            aAdd(aFilCpos, If(nRecnoSWV == 0, SPACE(AVSX3("WV_LOTE",3)), WkQuery->WV_LOTE ))
         ElseIf cCampo $ "WV_DFABRI"
            aAdd(aFilCpos, If(nRecnoSWV == 0,STOD(""), WkQuery->WV_DFABRI ))
         ElseIf cCampo $ "WV_DT_VALI"
            aAdd(aFilCpos, If(nRecnoSWV == 0,STOD(""), WkQuery->WV_DT_VALI ))
         ElseIf cCampo $ "WV_QTDE"
            aAdd(aFilCpos, If(nRecnoSWV == 0,  WkQuery->W8_QTDE, WkQuery->WV_QTDE ))
         ElseIf cCampo $ "WV_OBS"
            aAdd(aFilCpos, If(nRecnoSWV == 0, CRIAVAR(cCampo), WkQuery->WV_OBS ))
         ElseIf cCampo $ "WV_LPCOPND"
            aAdd(aFilCpos, If(nRecnoSWV == 0, CRIAVAR(cCampo), WkQuery->WV_LPCOPND ))
         ElseIf cCampo == "WV_DESC_DI"
            aAdd(aFilCpos, LP500GetInfo("SB1",1,XFILIAL("SB1") + If( nRecnoSWV == 0, WkQuery->W8_COD_I, WkQuery->WV_COD_I),"B1_DESC"))
         ElseIf cCampo == "WV_NOMEFOR"
            cChavForn := If( nRecnoSWV == 0, WkQuery->W8_FORN + WkQuery->W8_FORLOJ, WkQuery->WV_FORN + WkQuery->WV_FORLOJ)
            aAdd(aFilCpos, LP500GetInfo("SA2",1,xFilial("SA2") + cChavForn,"A2_NREDUZ"))
         ElseIF cCampo == "WV_SEQDUIM"
            cSeqDuim := if(nRecnoSWV == 0 .And. SW6->W6_FORMREG == DUIMP_INTEGRADA,strZero(nSeqDuim,AVSX3("WV_SEQDUIM",AV_TAMANHO)),"")
            cSeqDuim := If(nRecnoSWV == 0, cSeqDuim, WkQuery->WV_SEQDUIM )
            nSeqDuim := val(cSeqDuim)
            aAdd(aFilCpos, cSeqDuim )
         ElseIf cCampo == "WV_ID"
            aAdd(aFilCpos, If(nRecnoSWV == 0, LP500GetIdSWV(.F.), LP500SetHash(WkQuery->WV_ID) ))
         ElseIf Alltrim(cCampo) $ cCposMostra .And. !(Alltrim(cCampo) $ cCpoNao)
            aAdd(aFilCpos, IF(nREcnoSWV == 0, WkQuery->&("W8"+RIGHT(cCampo, LEN(cCampo) - 2)), WkQuery->&("WV"+RIGHT(cCampo, LEN(cCampo) - 2))))
         Else
            aAdd(aFilCpos, CRIAVAR(cCampo))
         EndIf
      Next nContCpo

      aAdd(aDados, {nRecnoSWV, aFilCpos})
      aFilCpos := {}
      WkQuery->(DbSkip())
   EndDo
   WkQuery->(dbcloseArea())

   ManLstFrm(oModel,'_nSeqDUIMP',"SET",,nSeqDuim)

   //Carrega Obrigatoriedade de Formulario para Ncm x produtos
   //ManLstFrm(oModel,'__aLstFrmNcm',"SET",'') //GetNCMLPCO( )

Return aDados

/*
Objetivo   : Função para atualizar o hash com a maior sequência já usada na base
Retorno    : Retorna o mesmo valor para a funcao load
Autor      : Maurício Frison
Data       : Novembro/2021
Revisão    :
*/
Static Function LP500SetHash(cSeq)
   Local cProcesso := SW6->W6_HAWB
   Local nSeq := val(cSeq)
   Local nSeqHash
   Local lHash
   lHash := getHashSeq(cProcesso, @nSeqHash)
   if (lHash .And. nSeq > nSeqHash) .or. !lHash //atualiza o hash se o nSeq for maior que o hash atual ou se não tiver hash
     setHashSeq(cProcesso, nSeq)
   EndIf
return cSeq

/*
Objetivo   : Função gerar o próximo ID a ser usado na tabela SWV
Retorno    : Retorna uma string com zeros a esquerda do próximo id
Autor      : Maurício Frison
Data       : Novembro/2021
Revisão    :
*/
Static Function LP500GetIdSWV(lGrid)
   Local cProcesso := SW6->W6_HAWB
   Local nIdSWV := 0
   Local lHash
   local cTmpAlias

   lHash := getHashSeq(cProcesso, @nIdSWV)
   if !lGrid
      If !lHash
         cTmpAlias := GetNextAlias()
         BeginSQL Alias cTmpAlias
            SELECT
               MAX(SWV.WV_ID) WV_ID
            FROM
               %table:SWV% SWV
            WHERE
               SWV.%notDel%
               AND SWV.WV_FILIAL = %xfilial:SWV%
               AND SWV.WV_HAWB = %exp:cProcesso%
         EndSql
         nIdSWV := val((cTmpAlias)->WV_ID)
         (cTmpAlias)->(dbCloseArea())
      EndIf
   EndIf

   nIdSWV += 1
   setHashSeq(cProcesso, nIdSWV)

return Strzero(nIdSWV,AVSX3("WV_ID",AV_TAMANHO))

/*
Objetivo   : Função retornar o ID a ser usado na tabela SWV
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data       : Abril/2022
Revisão    :
*/
static function getHashSeq(cProcesso, nIdSWV)
   local lHash    := .F.

   default cProcesso := ""
   default nIdSWV    := 0

   if valtype(_oSeqHash) == "O"
      lHash := _oSeqHash:get(cProcesso, @nIdSWV)
   endif

return lHash

/*
Objetivo   : Função armazenar o ID a ser usado na tabela SWV
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data       : Abril/2022
Revisão    :
*/
static function setHashSeq(cProcesso, nIdSWV)

   default cProcesso := ""
   default nIdSWV    := 0

   if valtype(_oSeqHash) == "O" 
      _oSeqHash:Set(cProcesso, nIdSWV)
   endif

return

/*
Objetivo      : Função para carregar dados na SWV - Grid da porção inferior da tela
Retorno    : Nil
Autor      : Ramon Prado
Data       : Agosto/2021
Revisão    :
*/
Static Function LP500EKQLoad(oModel)
   Local aFilCpos      := {}
   Local oMdl          := oModel:GetModel()	// Carrega Model Master
   Local oModelSWV     := oMdl:GetModel("SWVDETAIL") //teste da carga do model
   Local aCpoEKQ       := {}
   Local nContCpo      := 0
   Local cCampo        := ""
   Local aDados        := {}
   Local aForms        := {}
   Local i,nPosNcm

   aCpoEKQ := ManLstFrm(oModel,'_aCposEKQ',"GET")

   cChaveEKQ := xFilial("EKQ") + oModelSWV:GetValue("WV_HAWB")    + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC")
   EKQ->(DbSetOrder(1))
   If EKQ->(DbSeek( cChaveEKQ  ))
      Do While EKQ->( !Eof() .AND. Left(&(IndexKey()),Len(cChaveEKQ)) == cChaveEKQ )
         For nContCpo := 1 to Len(aCpoEKQ)
            aAdd( aFilCpos ,  If( aCpoEKQ[nContCpo][2] <> "V"  ,  EKQ->&(aCpoEKQ[nContCpo][1]) ,  LoadCpoVir(aCpoEKQ[nContCpo][1],"EKQ")  /*Eval( &( "{||"+Alltrim(GetSx3Cache( aCpoEKQ[nContCpo][3], "X3_RELACAO"))+"}" ) , aCpoEKQ[nContCpo][3] , oMdl )*/   )     )
         Next nContCpo
         aAdd(aDados, {EKQ->(Recno()), aFilCpos})
         aFilCpos := {}
         EKQ->(DbSkip())
      EndDo
   Else
      aForms   := ManLstFrm(oModel,'__aLstFrmNcm',"GET",'')
      nPosNcm  := aScan(aForms,{|x| x[1] == oModelSWV:GetValue("WV_NCM") })
      If nPosNcm > 0 //Existem Formulários para carregar para o item
         For i := 1 To Len(aForms[nPosNcm][2])
            For nContCpo := 1 to Len(aCpoEKQ)
               cCampo := aCpoEKQ[nContCpo][1]
               If cCampo == "EKQ_FILIAL"
                  aAdd(aFilCpos, xFilial("EKQ"))
               ElseIf cCampo == "EKQ_HAWB"
                  aAdd(aFilCpos, oModelSWV:GetValue("WV_HAWB"))
               ElseIf cCampo == "EKQ_INVOIC"
                  aAdd(aFilCpos, oModelSWV:GetValue("WV_INVOICE"))
               ElseIf cCampo == "EKQ_PO_NUM"
                  aAdd(aFilCpos, oModelSWV:GetValue("WV_PO_NUM"))
               ElseIf cCampo == "EKQ_POSICA"
                  aAdd(aFilCpos, oModelSWV:GetValue("WV_POSICAO"))
               ElseIf cCampo == "EKQ_SEQUEN"
                  aAdd(aFilCpos, oModelSWV:GetValue("WV_SEQUENC"))
               ElseIf cCampo == "EKQ_ORGANU"
                  aAdd(aFilCpos, aForms[nPosNcm][2][i][1])
               ElseIf cCampo == "EKQ_FRMLPC"
                  aAdd(aFilCpos, aForms[nPosNcm][2][i][2])
               ElseIf cCampo == "EKQ_OBRFRM"
                  aAdd(aFilCpos, If( (nPos := aScan(aForms[nPosNcm][2][i][4],{|x| x[1] == oModelSWV:GetValue("WV_COD_I") } )) > 0  , aForms[nPosNcm][2][i][4][nPos][2]  ,  aForms[nPosNcm][2][i][3] )  )
               ElseIf cCampo == "EKQ_DSCFRM"
                  aAdd(aFilCpos, LoadCpoVir(cCampo, { aForms[nPosNcm][2][i][1] , aForms[nPosNcm][2][i][2] } ) )
               Else
                  aAdd(aFilCpos, CRIAVAR(cCampo))
               EndIf
            Next nContCpo

            aAdd(aDados, {0, aFilCpos})
            aFilCpos := {}
         Next i
      else
         //Cria linha com a chave preenchida mas com dados em branco
         aAdd(aDados, LoadWhLine(oModel))
      endif
   EndIf

Return aDados

/*
Objetivo   : Função para carregar dados na tabela EIJ
Retorno    : Nil
Autor      : Maurício Frison
Data       : Novembro/2021
Revisão    :
*/
Static Function LP500EIJLoad(oModel)
   local aFilCpos   := {}
   local aCpoEIJ    := {}
   local oMdl       := nil
   local oModelSWV  := nil
   local oModelSW9  := nil
   local cChaveEIJ  := ""
   local lSeek      := .F.
   local nContCpo   := 0
   local cCampo     := ""
   local lLoadCpo   := .F.
   local lAltDesc   := GetNewpar("MV_DESCDI",.T.)
   local cProcDesc  := alltrim(getSX3Cache("EIJ_DSCCIT","X3_VISUAL"))

   aCpoEIJ := ManLstFrm(oModel,'_aCposEIJ',"GET")
   oMdl := oModel:GetModel()
   oModelSWV := oMdl:GetModel("SWVDETAIL")
   oModelSW9 := oMdl:GetModel("SW9DETAIL")
   cChaveEIJ := xFilial("EIJ") + oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_ID")

   EIJ->(DbSetOrder(3))
   lSeek := EIJ->(DbSeek( cChaveEIJ ))

   for nContCpo := 1 to Len(aCpoEIJ)

      cCampo := aCpoEIJ[nContCpo][1]
      lLoadCpo := getForceAtu() .and. lSeek .and. cCampo $ "EIJ_DSCCIT||EIJ_QT_EST||EIJ_VLMLE||EIJ_PESOL||EIJ_INCOTE||EIJ_MOEDA||EIJ_TIPCOB||EIJ_MODALI||EIJ_VL_FIN||EIJ_MOTIVO"

      if lSeek 
         if !lLoadCpo
            aAdd( aFilCpos ,  If( aCpoEIJ[nContCpo][2] <> "V"  ,  EIJ->&(cCampo) ,  LoadCpoVir(cCampo,"EIJ")   )     )
         endif
      endif

      if !lSeek .or. lLoadCpo 
         aAdd( aFilCpos , EIJLoad(cCampo, oModel, oModelSWV, oModelSW9, lAltDesc, cProcDesc, lSeek ) )
      EndIf

   Next nContCpo

Return aFilCpos

/*
Objetivo   : Função para carregar dados na tabela EIN
Retorno    : Nil
Autor      : Maurício Frison
Data       : Novembro/2021
Revisão    :
*/
Static Function LP500EINLoad(oModel, cTipo)
   Local aFilCpos      := {}
   Local oMdl          := oModel:GetModel()	// Carrega Model Master
   Local oModelSWV     := oMdl:GetModel("SWVDETAIL") //teste da carga do model
   Local aCpoEIN       := {}
   Local aDados        := {}
   Local nContCpo      := 0
   Local cCampo        := ""

   aCpoEIN := ManLstFrm(oModel, if(cTipo == "1", '_aCposEINA', '_aCposEIND') ,"GET")

   cChaveEIN := xFilial("EIN") + oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_ID") + cTipo
   EIN->(DbSetOrder(2))
   If EIN->(DbSeek( cChaveEIN  ))
      Do While EIN->( !Eof() .AND. Left(&(IndexKey()),Len(cChaveEIN)) == cChaveEIN )

         For nContCpo := 1 to Len(aCpoEIN)
            aAdd( aFilCpos ,  If( aCpoEIN[nContCpo][2] <> "V"  ,  EIN->&(aCpoEIN[nContCpo][1]) ,  LoadCpoVir(aCpoEIN[nContCpo][1],"EIN")     )     )
         Next nContCpo
         aAdd(aDados, {EIN->(Recno()), aFilCpos})
         aFilCpos := {}

         EIN->(DbSkip())
      EndDo
   Else    //Precisa criar uma linha correspondente a cada grid (uma de acréscimo e outra de dedução)
      For nContCpo := 1 to Len(aCpoEIN)
         cCampo := aCpoEIN[nContCpo][1]
         If cCampo == "EIN_FILIAL"
            aAdd(aFilCpos, xFilial("EIN"))
         ElseIf cCampo == "EIN_HAWB"
            aAdd(aFilCpos, oModelSWV:GetValue("WV_HAWB"))
         ElseIf cCampo == "EIN_IDWV"
            aAdd(aFilCpos, oModelSWV:GetValue("WV_ID"))
         elseIf cCampo == "EIN_TIPO"
            aAdd(aFilCpos, cTipo )
         Else
            aAdd(aFilCpos, CRIAVAR(cCampo))
         EndIf
      Next nContCpo
      aAdd(aDados, {0, aFilCpos})
      aFilCpos := {}
   EndIf
Return aDados


/*
Objetivo   : Função para carregar dados na tabela EIN
Retorno    : Nil
Autor      : Maurício Frison
Data       : Novembro/2021
Revisão    :
*/
Static Function LP500EIKLoad(oModel)
   Local aFilCpos      := {}
   Local oMdl          := oModel:GetModel()	// Carrega Model Master
   Local oModelSWV     := oMdl:GetModel("SWVDETAIL") //teste da carga do model
   Local aCpoEIK       := {}
   Local aDados        := {}
   Local nContCpo      := 0
   Local cCampo        := ""

   aCpoEIK := ManLstFrm(oModel,'_aCposEIK',"GET")

   cChaveEIK := xFilial("EIK") + oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_ID")
   EIK->(DbSetOrder(2))
   If EIK->(DbSeek( cChaveEIK  ))
      Do While EIK->( !Eof() .AND. Left(&(IndexKey()),Len(cChaveEIK)) == cChaveEIK )
         For nContCpo := 1 to Len(aCpoEIK)
            aAdd( aFilCpos ,  If( aCpoEIK[nContCpo][2] <> "V"  ,  EIK->&(aCpoEIK[nContCpo][1]) ,  LoadCpoVir(aCpoEIK[nContCpo][1],"EIK")     )     )
         Next nContCpo
         aAdd(aDados, {EIK->(Recno()), aFilCpos})
         aFilCpos := {}
         EIK->(DbSkip())
      EndDo
   Else
      For nContCpo := 1 to Len(aCpoEIK)
         cCampo := aCpoEIK[nContCpo][1]
         If cCampo == "EIK_FILIAL"
            aAdd(aFilCpos, xFilial("EIK"))
         ElseIf cCampo == "EIK_HAWB"
            aAdd(aFilCpos, oModelSWV:GetValue("WV_HAWB"))
         ElseIf cCampo == "EIK_IDWV"
            aAdd(aFilCpos, oModelSWV:GetValue("WV_ID"))
         Else
            aAdd(aFilCpos, CRIAVAR(cCampo))
         EndIf
      Next nContCpo
      aAdd(aDados, {0, aFilCpos})
      aFilCpos := {}
   EndIf
Return aDados


/*
Objetivo   : Função para carregar dados na tabela EJ9
Retorno    : Nil
Autor      : Maurício Frison
Data       : Novembro/2021
Revisão    :
*/
Static Function LP500EJ9Load(oModel)
   Local aFilCpos      := {}
   Local oMdl          := oModel:GetModel()	// Carrega Model Master
   Local oModelSWV     := oMdl:GetModel("SWVDETAIL") //teste da carga do model
   Local aCpoEJ9       := {}
   Local aDados        := {}
   Local nContCpo      := 0
   Local cCampo        := ""

   aCpoEJ9 := ManLstFrm(oModel,'_aCposEJ9',"GET")
   cChaveEJ9 := xFilial("EJ9") + oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_ID")
   EJ9->(DbSetOrder(2))
   If EJ9->(DbSeek( cChaveEJ9  ))
      Do While EJ9->( !Eof() .AND.  Left(&(IndexKey()),Len(cChaveEJ9)) == cChaveEJ9 )
         For nContCpo := 1 to Len(aCpoEJ9)
            aAdd( aFilCpos ,  If( aCpoEJ9[nContCpo][2] <> "V"  ,  EJ9->&(aCpoEJ9[nContCpo][1]) ,  LoadCpoVir(aCpoEJ9[nContCpo][1],"EJ9")     )     )
         Next nContCpo
         aAdd(aDados, {EJ9->(Recno()), aFilCpos})
         aFilCpos := {}
         EJ9->(DbSkip())
      EndDo
   Else
      For nContCpo := 1 to Len(aCpoEJ9)
         cCampo := aCpoEJ9[nContCpo][1]
         If cCampo == "EJ9_FILIAL"
            aAdd(aFilCpos, xFilial("EJ9"))
         ElseIf cCampo == "EJ9_HAWB"
            aAdd(aFilCpos, oModelSWV:GetValue("WV_HAWB"))
         ElseIf cCampo == "EJ9_IDWV"
            aAdd(aFilCpos, oModelSWV:GetValue("WV_ID"))
         Else
            aAdd(aFilCpos, CRIAVAR(cCampo))
         EndIf
      Next nContCpo
      aAdd(aDados, {0, aFilCpos})
      aFilCpos := {}
   EndIf
Return aDados


/*
Função     : LP500NAO
Objetivo   : Função que retorna String de campos que existem na SWV e nao existem na SW8
Parâmetro  :
Retorno    : String de campos que existem na SWV e nao existem na SW8
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function LP500NAO()
Return 'WV_SEQUENC|WV_DT_VALI|WV_LOTE|WV_DT_VALI|WV_OBS|WV_DFABRI'+If(SWV->(FieldPos("WV_LPCOPND")) > 0, '|WV_LPCOPND','' )

/*
Função     : LP500INI
Objetivo   : Função que retorna String de campos que existem na SWV e nao existem na SW8
Parâmetro  :
Retorno    : String de campos que existem na SWV e nao existem na SW8
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Function LP500INI(cCampo,oMdl, c)
   Local oModelSWV, oModelEKQ
   Local cRet := ""
   local aRet := {}
   Local cOrgAnu, cForm
   Default oMdl := FwModelActive()

   If AvFlags("DUIMP")
      If ValType(oMdl) == "O" //Objeto oMdl quando é chamado pelo Load do grid não está ativo ainda
         //Estará ativo quando for chamado pela inclusão de linha(manual ou automatica)
         oModelSWV := oMdl:GETMODEL("SWVDETAIL")
         oModelEKQ := oMdl:GETMODEL("EKQDETAIL")
         Do Case
            //inicializacao de campos da chave - inclusao de linha nova
            Case cCampo == "EKQ_FILIAL"
               cRet := xFilial("EKQ")
            Case cCampo == "EKQ_HAWB"
               cRet := oModelSWV:GETVALUE("WV_HAWB")
            Case cCampo == "EKQ_INVOIC"
               cRet := oModelSWV:GETVALUE("WV_INVOICE")
            Case cCampo == "EKQ_PO_NUM"
               cRet := oModelSWV:GETVALUE("WV_PO_NUM")
            Case cCampo == "EKQ_POSICA"
               cRet := oModelSWV:GETVALUE("WV_POSICAO")
            Case cCampo == "EKQ_SEQUEN"
               cRet := oModelSWV:GETVALUE("WV_SEQUENC")
            Case cCampo == "EKQ_OBRFRM"
               If !oModelSWV:IsDeleted()
                  cRet := "2" //Não - inicialização do campo 'Obrigatorio?'
               else
                  cRet := ""
               EndIf
            Case cCampo == "EKQ_VERSAO"
               cRet := ""
            Case cCampo == "EKQ_IDLPCO"
               cRet := ""
            Case cCampo == "EKQ_DSCFRM"
               If !oModelSWV:IsDeleted() .And. !Empty( cOrgAnu := If(oModelEKQ:GetLine() <> 0,oModelEKQ:GETVALUE("EKQ_ORGANU"),"") ) .And. !Empty( cForm := If(oModelEKQ:GetLine() <> 0,oModelEKQ:GETVALUE("EKQ_FRMLPC"),"") )
                  cRet := LP500GetInfo("EKL",1,xFilial("EKL") + cOrgAnu + cForm , "EKL_DESC"  )
               Else
                  cRet := ""
               EndIf
            Case cCampo == "EIJ_IMPORT"
               cRet := SW6->W6_IMPORT
            Case cCampo == "EIJ_NOMIMP"
               cRet := LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_NOME")
            Case cCampo == "EIJ_CNPJRZ"
               cRet := LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" )
            Case cCampo == "EIJ_UNIDCO"
               aRet := GetInfW7W8(oModelSWV,"W8_UNID")
               cRet := ""
               if len(aRet) > 0
                  cRet := aRet[1]
               endIf
            Case cCampo == "EIJ_QTDECO"
               cRet := oModelSWV:GETVALUE("WV_QTDE")
            Case cCampo == "EIJ_UNDEST"
               cRet := AvKey( if( !empty(oModelSWV:getValue("WV_NCM")), LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:GETVALUE("WV_NCM"), "YD_UNID"), "" ) , "EIJ_UNDEST")
            Case cCampo == "EIJ_FABRVM"
               cRet := LP500GetInfo("SA2", 1, xFilial("SA2") + oMdl:GETMODEL():GetValue("EIJMASTER","EIJ_FABR") + oMdl:GETMODEL():GetValue("EIJMASTER","EIJ_FABLOJ"), "A2_NREDUZ" )
               cRet := AvKey(cRet, "EIJ_FABRVM")
            Case cCampo == "EIN_DESC"
               cRet := ""
            Case cCampo == "EIN_FILIAL"
               cRet :=  xFilial("EIN")
            Case cCampo == "EIN_HAWB"
               cRet := oModelSWV:GETVALUE("WV_HAWB")
            Case cCampo == "EIN_IDWV"
               cRet := oModelSWV:GETVALUE("WV_ID")
            Case cCampo == "EJ9_FILIAL"
               cRet :=  xFilial("EJ9")
            Case cCampo == "EJ9_HAWB"
               cRet := oModelSWV:GETVALUE("WV_HAWB")
            Case cCampo == "EJ9_IDWV"
               cRet := oModelSWV:GETVALUE("WV_ID")
            Case cCampo == "EIK_FILIAL"
               cRet :=  xFilial("EIK")
            Case cCampo == "EIK_HAWB"
               cRet := oModelSWV:GETVALUE("WV_HAWB")
            Case cCampo == "EIK_IDWV"
               cRet := oModelSWV:GETVALUE("WV_ID")
            Otherwise
               cRet := CRIAVAR(cCampo)
         EndCase
      EndIf
   EndIf

Return cRet

/*
Programa   : LP500COMMIT
Objetivo   : Funcao de Commit -
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/

Static Function LP500COMMIT(oMdl)
   Local oModelSW9  := oMdl:GetModel("SW9DETAIL")
   Local oModelSWV  := oMdl:GetModel("SWVDETAIL")
   Local nOpc       := oMdl:GetOperation()
   Local nSWV,nSW9
   Local lRet := .T.
   local oModelEIJ  := nil
   local aCposEIJ   := {}
   local oModelEINA := nil
   local aCposEINA  := {}
   local oModelEIND := nil
   local aCposEIND  := {}
   local oModelEIK  := nil
   local aCposEIK   := {}
   local oModelEJ9  := nil
   local aCposEJ9   := {}
   local oModelEKQ  := nil

   If nOpc == MODEL_OPERATION_UPDATE

      oModelEIJ := oMdl:GetModel("EIJMASTER")
      aCposEIJ := ExistField('EIJ', oModelEIJ:getStruct():GetFields()) 

      oModelEINA := oMdl:GetModel("EINADETAIL")
      aCposEINA := ExistField('EIN', oModelEINA:getStruct():GetFields())

      oModelEIND := oMdl:GetModel("EINDDETAIL")
      aCposEIND := ExistField('EIN', oModelEIND:getStruct():GetFields())

      oModelEIK := oMdl:GetModel("EIKDETAIL")
      aCposEIK := ExistField('EIK', oModelEIK:getStruct():GetFields())

      oModelEJ9 := oMdl:GetModel("EJ9DETAIL")
      aCposEJ9 := ExistField('EJ9', oModelEJ9:getStruct():GetFields())

      oModelEKQ := oMdl:GetModel("EKQDETAIL")

      DbSelectArea("SWV")
      SWV->(DbSetOrder(3)) //WV_FILIAL+WV_HAWB+WV_INVOICE+WV_PO_NUM+WV_POSICAO+WV_SEQUENC

      DbSelectArea("EKQ")
      EKQ->(DbSetOrder(1)) //EKQ_FILIAL+EKQ_HAWB+EKQ_INVOIC+EKQ_PO_NUM+EKQ_POSICA+EKQ_SEQUEN+EKQ_ORGANU+EKQ_FRMLPC

      DbSelectArea("EIJ")
      EIJ->(DbSetOrder(3)) //EIJ_FILIAL+EIJ_HAWB+EIJ_IDWV

      For nSW9 := 1 To oModelSW9:Length()
         oModelSW9:GoLine(nSW9)
         For nSWV := 1 To oModelSWV:Length()
            oModelSWV:GoLine(nSWV)
            LP500SWVCOMMIT(oModelSWV)
            LP500EKQCOMMIT(oModelSWV, oModelEKQ)
            LP500EIJCOMMIT(oModelSWV, oModelEIJ, aCposEIJ)
            LP500EINCOMMIT(oModelSWV, oModelEINA, aCposEINA, oModelEIND, aCposEIND)
            LP500EIKCOMMIT(oModelSWV, oModelEIK, aCposEIK)
            LP500EJ9COMMIT(oModelSWV, oModelEJ9, aCposEJ9)
         Next nSWV
      Next nSW9

      if(existFunc("DU100AtuEV"),DU100AtuEV( ManLstFrm(oMdl,'_nRecEV1','GET') ),nil)

   EndIf

Return lRet

/*
Programa   : ExistField
Objetivo   : Funcao para verificar se o campo existe
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2021
Obs.       :
*/
static function ExistField(cTabela, aCampos)
   local aRet     := {}
   local nCpo     := {}

   default cTabela := ""
   default aCampos := {}

   for nCpo := 1 to len(aCampos)
      if (cTabela)->(ColumnPos(aCampos[nCpo][3])) > 0
         aAdd( aRet, aCampos[nCpo][3] )
      endif
   next

return aRet

/*
Programa   : LP500SWVCOMMIT
Objetivo   : Funcao de Commit -  SWV
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function LP500SWVCOMMIT(oModelSWV)
   Local lRet := .T.
   Local lIncluiLn  := .F.

   lIncluiLn := !SWV->(DbSeek(xFilial("SWV")+oModelSWV:GetValue("WV_HAWB")+oModelSWV:GetValue("WV_INVOICE")+;
      oModelSWV:GetValue("WV_PO_NUM")+oModelSWV:GetValue("WV_POSICAO")+;
      oModelSWV:GetValue("WV_SEQUENC")))

   If !oModelSWV:IsDeleted()
      RecLock("SWV", lIncluiLn) //Alteração, registro ja existente
      If lIncluiLn //inclusao, registro novo
         SWV->WV_Filial  := xFilial("SWV")
         SWV->WV_HAWB    := oModelSWV:GetValue("WV_HAWB")
         SWV->WV_PO_NUM  := oModelSWV:GetValue("WV_PO_NUM")
         SWV->WV_POSICAO := oModelSWV:GetValue("WV_POSICAO")
         SWV->WV_REG     := oModelSWV:GetValue("WV_REG")
         SWV->WV_FORN    := oModelSWV:GetValue("WV_FORN")
         SWV->WV_FORLOJ  := oModelSWV:GetValue("WV_FORLOJ")
         SWV->WV_INVOICE := oModelSWV:GetValue("WV_INVOICE")
         SWV->WV_COD_I   := oModelSWV:GetValue("WV_COD_I")
         SWV->WV_CC      := oModelSWV:GetValue("WV_CC")
         SWV->WV_PGI_NUM := oModelSWV:GetValue("WV_PGI_NUM")
         SWV->WV_SI_NUM := oModelSWV:GetValue("WV_SI_NUM")
         SWV->WV_SEQUENC := oModelSWV:GetValue("WV_SEQUENC")
      EndIf
      SWV->WV_SEQDUIM := oModelSWV:GetValue("WV_SEQDUIM")
      SWV->WV_LOTE    := oModelSWV:GetValue("WV_LOTE")
      SWV->WV_QTDE    := oModelSWV:GetValue("WV_QTDE")
      SWV->WV_DFABRI  := oModelSWV:GetValue("WV_DFABRI")
      SWV->WV_DT_VALI := oModelSWV:GetValue("WV_DT_VALI")
      SWV->WV_OBS     := oModelSWV:GetValue("WV_OBS")
      SWV->WV_LPCOPND := oModelSWV:GetValue("WV_LPCOPND")
      SWV->WV_ID      := oModelSWV:GetValue("WV_ID")
      SWV->(MsUnlock())

   ElseIf !lIncluiLn
      RecLock("SWV", lIncluiLn)
      SWV->(DbDelete())
      SWV->(MsUnlock())
   EndIf
Return lRet


/*
Programa   : LP500EKQCOMMIT
Objetivo   : Funcao de Commit -   EKQ
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function LP500EKQCOMMIT(oModelSWV, oModelEKQ)
   Local nY         := 0
   Local lRet := .T.
   Local lIncluiLn  := .F.

   For nY := 1 To oModelEKQ:Length()
      oModelEKQ:GoLine(nY)
      If !Empty( oModelEKQ:GetValue("EKQ_ORGANU") ) .And. !Empty( oModelEKQ:GetValue("EKQ_FRMLPC") )  //Prevenção de gravação de linha em branco na EKQ.
         lIncluiLn := !EKQ->(DbSeek(xFilial("EKQ")+oModelEKQ:GetValue("EKQ_HAWB")+oModelEKQ:GetValue("EKQ_INVOIC")+;
            oModelEKQ:GetValue("EKQ_PO_NUM")+oModelEKQ:GetValue("EKQ_POSICA")+oModelEKQ:GetValue("EKQ_SEQUEN")+;
            oModelEKQ:GetValue("EKQ_ORGANU")+oModelEKQ:GetValue("EKQ_FRMLPC")))

         If !oModelEKQ:IsDeleted()
            RecLock("EKQ", lIncluiLn) //Alteração, registro ja existente
            If lIncluiLn //inclusao, registro novo
               EKQ->EKQ_Filial  := xFilial("EKQ")
               EKQ->EKQ_HAWB    := oModelEKQ:GetValue("EKQ_HAWB")
               EKQ->EKQ_INVOIC  := oModelEKQ:GetValue("EKQ_INVOIC")
               EKQ->EKQ_PO_NUM  := oModelEKQ:GetValue("EKQ_PO_NUM")
               EKQ->EKQ_POSICA  := oModelEKQ:GetValue("EKQ_POSICA")
               EKQ->EKQ_SEQUEN  := oModelEKQ:GetValue("EKQ_SEQUEN")
            EndIf
            EKQ->EKQ_ORGANU  := oModelEKQ:GetValue("EKQ_ORGANU")
            EKQ->EKQ_FRMLPC  := oModelEKQ:GetValue("EKQ_FRMLPC")
            EKQ->EKQ_LPCO    := oModelEKQ:GetValue("EKQ_LPCO")
            EKQ->EKQ_VERSAO  := oModelEKQ:GetValue("EKQ_VERSAO")
            EKQ->EKQ_OBRFRM  := oModelEKQ:GetValue("EKQ_OBRFRM")
            EKQ->EKQ_IDLPCO  := oModelEKQ:GetValue("EKQ_IDLPCO")
            EKQ->(MsUnlock())
         ElseIf !lIncluiLn
            RecLock("EKQ", lIncluiLn)
            EKQ->(DbDelete())
            EKQ->(MsUnlock())
         EndIf
      EndIf
   Next nY

Return lRet

/*
Programa   : LP500EIJCOMMIT
Objetivo   : Funcao de Commit -  EIJ
Retorno    : Logico
Autor      : Maurício
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function LP500EIJCOMMIT(oModelSWV, oModelEIJ, aCposEIJ)
   Local nEIJ:=0
   Local lRet := .T.
   Local lIncluiLn  := .F.
   Local cField:= ""
   LOcal xValue

   lIncluiLn := !EIJ->(DbSeek( xFilial("EIJ") + oModelEIJ:getValue("EIJ_HAWB") + oModelEIJ:getValue("EIJ_IDWV") ))

   If !oModelSWV:IsDeleted() //aqui é o oModelSWV mesmo, pois se ele foi excluído, excluir também a tabela filha
      RecLock("EIJ", lIncluiLn) //Alteração, registro ja existente
      For nEIJ := 1 to len(aCposEIJ)
         cField := aCposEIJ[nEIJ]
         xValue := oModelEIJ:getValue(cField)
         IF EIJ->&(cField) <> xValue
            EIJ->&(cField) := xValue
         EndIf
      Next nEIJ
      EIJ->(MsUnlock())
   ElseIf !lIncluiLn
      RecLock("EIJ", lIncluiLn)
      EIJ->(DbDelete())
      EIJ->(MsUnlock())
   EndIf

Return lRet


/*
Programa   : LP500EINCOMMIT
Objetivo   : Funcao de Commit -  EIN
Retorno    : Logico
Autor      : Maurício
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function LP500EINCOMMIT(oModelSWV, oModelEINA, aCposEINA, oModelEIND, aCposEIND)
   Local oModelEIN
   Local nEIN:=0, i := 0, nCps
   Local lRet := .T.
   Local lIncluiLn  := .F.
   Local aCposEIN := {}

   Local cField:= ""
   Local xValue

   For i := 1 To 2
      oModelEIN := If(i==1,oModelEINA,oModelEIND) 
      aCposEIN := If(i==1,aCposEINA,aCposEIND) 
      For nEIN := 1 To oModelEIN:Length()
         oModelEIN:GoLine(nEIN)
         If !Empty(oModelEIN:GetValue("EIN_HAWB"))  .And. !Empty(oModelEIN:GetValue("EIN_IDWV")) .And. !Empty(oModelEIN:getValue("EIN_CODIGO"))
            lIncluiLn := .T.
            If oModelEIN:getDataId() <> 0
               EIN->(DBGoTo(oModelEIN:getDataId()))
               lIncluiLn:= .F.
            EndIf
            If !oModelEIN:IsDeleted()
               RecLock("EIN", lIncluiLn) //Alteração, registro ja existente
               For nCps := 1 to len(aCposEIN)
                  cField:= aCposEIN[nCps]
                  xValue:= oModelEIN:getValue(cField)
                  IF EIN->&(cField) <> xValue
                     EIN->&(cField) := xValue
                  EndIf
               Next nCps
               EIN->(MsUnlock())
            ElseIf !lIncluiLn
               RecLock("EIN", lIncluiLn)
               EIN->(DbDelete())
               EIN->(MsUnlock())
            EndIf
         EndIf
      Next nEIN
   Next i

Return lRet

/*
Programa   : LP500EIKCOMMIT
Objetivo   : Funcao de Commit -  EIK
Retorno    : Logico
Autor      : Maurício
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function LP500EIKCOMMIT(oModelSWV, oModelEIK, aCposEIK)
   Local nEIK:=0, nCps
   Local lRet := .T.
   Local lIncluiLn  := .F.
   Local cField:= ""
   Local xValue

   For nEIK := 1 To oModelEIK:Length()
      oModelEIK:GoLine(nEIK)
      If !Empty( oModelEIK:GetValue("EIK_HAWB"))  .And. !Empty( oModelEIK:GetValue("EIK_IDWV")) .And. !Empty(oModelEIK:getValue("EIK_TIPVIN"))
         lIncluiLn := .T.
         If oModelEIK:getDataId() <> 0
            EIK->(DBGoTo(oModelEIK:getDataId()))
            lIncluiLn:= .F.
         EndIf
         If !oModelEIK:IsDeleted()
            RecLock("EIK", lIncluiLn) //Alteração, registro ja existente
            For nCps := 1 to len(aCposEIK)
               cField:= aCposEIK[nCps]
               xValue:= oModelEIK:getValue(cField)
               IF EIK->&(cField) <> xValue
                  EIK->&(cField) := xValue
               EndIf
            Next nCps
            EIK->(MsUnlock())
         ElseIf !lIncluiLn
            RecLock("EIK", lIncluiLn)
            EIK->(DbDelete())
            EIK->(MsUnlock())
         EndIf
      EndIf
   Next nEIK

Return lRet

/*
Programa   : LP500EJ9COMMIT
Objetivo   : Funcao de Commit -  EJ9
Retorno    : Logico
Autor      : Maurício
Data/Hora  : Novembro/2021
Obs.       :
*/
Static Function LP500EJ9COMMIT(oModelSWV, oModelEJ9, aCposEJ9)
   Local nEJ9:=0, nCps
   Local lRet := .T.
   Local nRecno
   Local cField:= ""
   Local xValue

   For nEJ9 := 1 To oModelEJ9:Length()
      oModelEJ9:GoLine(nEJ9)
      If  !empty(oModelEJ9:getValue("EJ9_HAWB")) .And. !empty(oModelEJ9:getValue("EJ9_IDWV")) .And. !empty(oModelEJ9:getValue("EJ9_IDCERT")) .And. !empty(oModelEJ9:getValue("EJ9_DEMERC"))
         nRecno := oModelEJ9:GetDataId(nEJ9)
         EJ9->(DBGOTO(nRecno))
         If !oModelSWV:IsDeleted() .And. !oModelEJ9:IsDeleted()
            RecLock("EJ9", nRecno == 0) //Alteração, registro ja existente
            For nCps := 1 to len(aCposEJ9)
               cField:= aCposEJ9[nCps]
               xValue:= oModelEJ9:getValue(cField)
               IF EJ9->&(cField) <> xValue
                  EJ9->&(cField) := xValue
               EndIf
            Next nCps
            EJ9->(MsUnlock())
         ElseIf nRecno # 0
            RecLock("EJ9", .F.)
            EJ9->(DbDelete())
            EJ9->(MsUnlock())
         EndIf
      EndIf
   Next nEJ9

Return lRet

/*
Função     : ManLstFrm
Objetivo   : Manipular o array estático de NcmxForms LPCO - o Array __aLstFrmNCM é carregado no LOAD do grid superior
Retorno    : Logico/array
Autor      : Nilson Cesar
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function ManLstFrm(oMdl,cVar,cCmd,cKey,xValue)
   Local xRet := .T.

   If cVar == '__aLstFrmNcm'
      If cCmd == "SET"
         __aLstFrmNCM := GetNCMLPCO()
         xRet := .T.
      elseif cCmd == "GET"
         xRet := aClone(__aLstFrmNCM)
      elseif cCmd == "CLEAR"
         xRet := aSize(__aLstFrmNCM,0)
      EndIf
   ElseIf cVar == '__oQtdSumSWV'
      If cCmd == 'SET'
         GetQtdSWV(oMdl)
      ElseIf cCmd == "GET"
         xRet := GetQtdSWV(oMdl,cKey)
      ElseIf cCmd == 'CLEAR'
         __oQtdSumSWV := Nil
      EndIf
   ElseIf cVar == '__oLstQtdInf'
      If cCmd == 'SET'
         BkpQtdSWV(oMdl,cKey,xValue)
      ElseIf cCmd == "GET"
         xRet := BkpQtdSWV(oMdl,cKey)
      ElseIf cCmd == 'CLEAR'
         __oLstQtdInf := Nil
      EndIf
   elseif cVar == '_nRecEV1'
      if cCmd == "GET"
         xRet := _nRecEV1
      elseif cCmd == 'CLEAR'
         _nRecEV1 := 0
      endif
   elseif cVar == '_oSeqHash'
      if cCmd == 'CLEAR'
         _oSeqHash := tHashMap():New()
      endif
   elseif cVar == '_aCposEKQ'
      if cCmd == 'SET'
         _aCposEKQ := DefCpoSX3(oMdl:getModel():getModel("EKQDETAIL"):getStruct():GetFields(), 16) 
      elseif cCmd == "GET"
         xRet := _aCposEKQ
      elseif cCmd == 'CLEAR'
         _aCposEKQ := {}
         aSize(_aCposEKQ, 0)
      endif
   elseif cVar == '_aCposEIJ'
      if cCmd == 'SET'
         _aCposEIJ := DefCpoSX3(oMdl:getModel():getModel("EIJMASTER"):getStruct():GetFields(), 16) 
      elseif cCmd == "GET"
         xRet := _aCposEIJ
      elseif cCmd == 'CLEAR'
         _aCposEIJ := {}
         aSize(_aCposEIJ, 0)
      endif
   elseif cVar == '_aCposEINA'
      if cCmd == 'SET'
         _aCposEINA := DefCpoSX3(oMdl:getModel():getModel("EINADETAIL"):getStruct():GetFields(), 16) 
      elseif cCmd == "GET"
         xRet := _aCposEINA
      elseif cCmd == 'CLEAR'
         _aCposEINA := {}
         aSize(_aCposEINA, 0)
      endif
   elseif cVar == '_aCposEIND'
      if cCmd == 'SET'
         _aCposEIND := DefCpoSX3(oMdl:getModel():getModel("EINDDETAIL"):getStruct():GetFields(), 16) 
      elseif cCmd == "GET"
         xRet := _aCposEIND
      elseif cCmd == 'CLEAR'
         _aCposEIND := {}
         aSize(_aCposEIND, 0)
      endif
   elseif cVar == '_aCposEIK'
      if cCmd == 'SET'
         _aCposEIK := DefCpoSX3(oMdl:getModel():getModel("EIKDETAIL"):getStruct():GetFields(), 16) 
      elseif cCmd == "GET"
         xRet := _aCposEIK
      elseif cCmd == 'CLEAR'
         _aCposEIK := {}
         aSize(_aCposEIK, 0)
      endif
   elseif cVar == '_aCposEJ9'
      if cCmd == 'SET'
         _aCposEJ9 := DefCpoSX3(oMdl:getModel():getModel("EJ9DETAIL"):getStruct():GetFields(), 16) 
      elseif cCmd == "GET"
         xRet := _aCposEJ9
      elseif cCmd == 'CLEAR'
         _aCposEJ9 := {}
         aSize(_aCposEJ9, 0)
      endif
   elseif cVar == '_nSeqDUIMP'
      if cCmd == 'SET'
         _nSeqDUIMP := xValue
      elseif cCmd == "GET"
         xRet := _nSeqDUIMP
      endif
   EndIf

Return xRet

/*
Programa   : DefCpoSX3
Objetivo   : Funcao para verificar se os atributos de um determinado campo
Retorno    : 
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2021
Obs.       :
*/
static function DefCpoSX3(aCampos, nCpoSX3)
   local aRet      := {}
   local nCpo      := {}
   local cCampo    := ""
   local aDefCampo := {}

   default aCampos    := {}
   default nCpoSX3    := 0

   for nCpo := 1 to len(aCampos)
      cCampo := aCampos[nCpo][3]
      aDefCampo := AvSX3(cCampo, nCpoSX3 )
      aAdd( aRet, { cCampo, aDefCampo })
   next

return aRet

/*
Função     : GetNCMLPCO
Objetivo   : Carrega uma única vez as exigências de formulários das n.c.m's de todos os itens de
             invoice do processo.
Retorno    : Array
Autor      : Nilson Cesar
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function GetNCMLPCO()
   Local cQryNCMPRD := ""
   Local aFrmNcmPrd := {}

   cQryNCMPRD += " SELECT EKM1.EKM_NCM,EKM1.EKM_OBRIGA,EKM1.EKN_COD_I,EKM1.EKN_OBRIGA, EKM1.EKM_ORGANU, EKM1.EKM_FRMLPC "
   cQryNCMPRD += " FROM (SELECT EKM.EKM_ORGANU,EKM.EKM_FRMLPC,EKM.EKM_NCM,EKM.EKM_OBRIGA,EKN.EKN_COD_I,EKN.EKN_OBRIGA "
   cQryNCMPRD += "       FROM " + RetSQLName("EKM") + " EKM LEFT JOIN " + RetSQLName("EKN") + " EKN "
   cQryNCMPRD += "	      ON EKM.D_E_L_E_T_ = '' "
   cQryNCMPRD += "	      AND EKN.D_E_L_E_T_ = '' "
   cQryNCMPRD += "	      AND EKM.EKM_FILIAL =  EKN.EKN_FILIAL "
   cQryNCMPRD += "	      AND EKM.EKM_ORGANU =  EKN.EKN_ORGANU "
   cQryNCMPRD += "	      AND EKM.EKM_FRMLPC =  EKN.EKN_FRMLPC ) EKM1 "
   cQryNCMPRD += " WHERE EKM1.EKM_NCM IN ( SELECT DISTINCT W8_TEC FROM " + RetSQLName("SW8") + " WHERE D_E_L_E_T_ = ' ' AND W8_FILIAL = '"+xFilial("SW8")+"'  AND W8_HAWB = '"+SW6->W6_HAWB+"' ) "
   cQryNCMPRD += " AND "+ IF(Upper(TCGetDb()) == "ORACLE","LPAD(EKM1.EKM_FRMLPC,1)","LEFT(EKM1.EKM_FRMLPC,1)") +" = 'I'"
   cQryNCMPRD += " ORDER BY EKM1.EKM_NCM "

   cQryNCMPRD:= ChangeQuery(cQryNCMPRD)
   EasyQry(cQryNCMPRD, "WKFRMEXIG")
   WKFRMEXIG->(DbGoTop())

   Do While WKFRMEXIG->(!Eof())
      If ( nPosNcm := aScan(aFrmNcmPrd,{|x| x[1] == WKFRMEXIG->EKM_NCM }) ) == 0                                                                       // Adiciona tudo para a nova N.c.m
         aAdd( aFrmNcmPrd , { WKFRMEXIG->EKM_NCM , { { WKFRMEXIG->EKM_ORGANU, WKFRMEXIG->EKM_FRMLPC,WKFRMEXIG->EKM_OBRIGA, {} } }   }   )
         If !Empty(WKFRMEXIG->EKN_COD_I)
            aAdd( aFrmNcmPrd[Len(aFrmNcmPrd)][2][1][4] , {WKFRMEXIG->EKN_COD_I,WKFRMEXIG->EKN_OBRIGA})
         EndIf
      else                                                                                                                                             // Adiciona o orgão/formulário para a n.c.m existente
         If ( nPosForm := aScan( aFrmNcmPrd[nPosNCM][2] , {|y| y[1] == WKFRMEXIG->EKM_ORGANU .And. y[2] == WKFRMEXIG->EKM_FRMLPC  }  ) ) == 0
            aAdd( aFrmNcmPrd[nPosNcm][2] , { WKFRMEXIG->EKM_ORGANU, WKFRMEXIG->EKM_FRMLPC,WKFRMEXIG->EKM_OBRIGA, {} }   )
            If !Empty(WKFRMEXIG->EKN_COD_I)                                                                                                          // Adiciona o item excessão para o novo formulário
               aAdd( aFrmNcmPrd[nPosNcm][2][Len(aFrmNcmPrd[nPosNcm][2])][4] , {WKFRMEXIG->EKN_COD_I,WKFRMEXIG->EKN_OBRIGA})
            EndIf
         else                                                                                                                                         // Adiciona o item excessão para o formulário já existente
            If !Empty(WKFRMEXIG->EKN_COD_I)
               aAdd( aFrmNcmPrd[nPosNcm][2][nPosForm][4] , {WKFRMEXIG->EKN_COD_I,WKFRMEXIG->EKN_OBRIGA})
            EndIf
         EndIf
      EndIf
      WKFRMEXIG->(DbSkip())
   EndDo

   WKFRMEXIG->(DbCloseArea())


Return aFrmNcmPrd

/*
Função     : LP500FilF3
Objetivo   : Funcao para Filtrar os registros da consulta padrão EKO
Retorno    : .T. OU .F.
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Function LP500FilF3()
   Local oMdl := FWModelActive()
   Local oModelEKQ := oMdl:GetModel("EKQDETAIL")
   Local lRet := .T.

   If ValType(oModelEKQ) == "O"
      lRet := !Empty(EKO->EKO_LPCO) .And. EKO->EKO_ORGANU == oModelEKQ:GetValue("EKQ_ORGANU") .And. EKO->EKO_FRMLPC == oModelEKQ:GetValue("EKQ_FRMLPC")
   EndIf

Return lRet


Function LP500PVldModel(oMdl)
   Local oModelSW9,oModelSWV
   Local lRet := .t.
   Local nSW9,nI
   Local cMsg := ""
   Local aSaveLines := FWSaveRows()
   Local nLenSW9
   Local aData, aSeq:={}, nData
   Local nField
   Local lIntegrado := SW6->W6_FORMREG == DUIMP_INTEGRADA
   Local lSeqValida :=.T.

   If ValType(oMdl) == 'O'
      oModelSW9     := oMdl:GetModel("SW9DETAIL")
      oModelSWV     := oMdl:GetModel("SWVDETAIL")
      nField        := oModelSWV:getIdField("WV_SEQDUIM")
      nLenSW9 := oModelSW9:Length(.T.)     
      For nSW9:=1 to nLenSW9
         oModelSW9:goline(nSW9)
         if oModelSWV:SeekLine({{"WV_SEQDUIM"," "}}, .F., .F. ) .OR. oModelSWV:SeekLine({{"WV_SEQDUIM",""}}, .F., .F. ) //se encontrar alguma linha com o campo seqduimp vazio não é para validar a sequência
            if !lIntegrado
               Return .T. //Se tem sequência em branco e não é integrado não precisa verificar mais nada
            else
               lSeqValida := .F.
               exit
            EndIf
         EndIf
        
         aDataModel:= AClone(oModelSW9:aDataModel[nSW9][MODEL_GRID_CHILDREN])
         nPosSubModel := AScan(aDataModel, {|x| x[MODEL_GRID_CHILDREN_ID] == "SWVDETAIL"})
         If nPosSubModel > 0
            aData := AClone(aDataModel[nPosSubModel][MODEL_GRID_CHILDREN_DATA])
            For nData:= 1 to Len(aData)
               if !aData[nData][MODEL_GRID_DELETE] // desconsidera as linhas deletadas
                  AADD(aSeq,aData[nData][MODEL_GRID_DATA][MODEL_GRIDLINE_VALUE][nField])                  
               endif
            Next      
         EndIf
      Next
 
      If (lIntegrado .and. lSeqValida) .or. !lIntegrado
         For nI:=1 to len(aSeq)
            nPos := aScan(aSeq,Strzero(ni,AVSX3("WV_SEQDUIM",AV_TAMANHO)))
            If nPos == 0 
               cMsg:= cMsg + StrTran(STR0050,"####",Strzero(nI,AVSX3("WV_SEQDUIM",AV_TAMANHO))) + ENTER //Sequência #### não existe"
               If !lIntegrado
                  lRet:=.f.
               else
                  lSeqValida := .F.
                  exit
               EndIF
            EndIf   
         Next   
      EndIf   
      If lIntegrado .And. !lSeqValida
         DelSeqDuimp(.F.)
         GerSeqDuimp(.F.)
      EndIf   
      if !Empty(cMsg) .And. !lIntegrado
         EasyHelp(cMsg,STR0048,STR0051) //"Deixe a sequência DUIMP sem intervalos ou valores repetidos, exemplo (0001,0002,0003...)
      EndIf
   EndIf   
   FWRestRows(aSaveLines)
return lRet       

/*
Função     : LP500CNGAT
Objetivo   : Retornar se o gatilho será executado.
Retorno    : Lógico - Define se o gatilho será disparado.
Autor      : Nilson César
Data/Hora  : Dezembro/2021
Obs.       :
*/
Function LP500CNGAT(cCampo)
   Local oMdl := FWModelActive()
   Local lRet := .F.

   Begin Sequence

      //Não executar para processos que não forem DUIMP
      If SW6->W6_TIPOREG <> "2"
         Break
      EndIf

      Do Case
         Case cCampo == 'EIN_VLMLE'
            lRet :=  !Empty(oMdl:GETMODEL():GetValue(oMdl:aERRORMESSAGE[1],"EIN_FOBMOE"))
      EndCase

   End Sequence

Return lRet

/*
Função     : LP500Gatil
Objetivo   : Funcao para utilização de gatilhos
Retorno    : conteúdo a ser gatilhado
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Function LP500Gatil(cCampo, lVeioDelec, cAction)
   Local oMdl          := FWModelActive()
   Local oView         := FWViewActive()
   Local cRet          := ""
   Local nQtdAntSWV    := nQtdInf := 0
   Local aLoadCpos     := {}
   Local nLineSWV      := 0
   Local nLine         := 0
   Local aSaveRows     := {}
   Local nQtdPai       := 0
   Local nQtdFilha     := 0
   Local i
   Local oStrGrdSWV, aCposSWV, aPosCposKey, cSeqAtu
   Local aPKeyWV
   Local aLinGDEKQ, aLinEIJ
   Local aSeek          := {}
   local nAtuSWV        := 0
   local lAtuTribut     := .F.
   local oModelSW9      := nil
   local aSaveLines     := {}

   Default lVeioDelec  := .F.
   Default cAction     := ""

   Private lDelAllLine := .F.
   // OSSME-6929 incluído este controle pois quando alterado a quantidade do lote pela L.I. dava erro de gatilho
   If oMdl != nil
      
      If ValType(oMdl:GetModel("EKQDETAIL")) == "O"

         oModelSW9 := oMdl:GetModel("SW9DETAIL")
         oModelSWV := oMdl:GetModel("SWVDETAIL")
         oModelEKQ := oMdl:GetModel("EKQDETAIL")
         oModelEIJ := oMdl:GetModel("EIJMASTER")
         oModelEINA:= oMdl:GetModel("EINADETAIL")
         oModelEIND:= oMdl:GetModel("EINDDETAIL")
         oModelEIK := oMdl:GetModel("EIKDETAIL")
         oModelEJ9 := oMdl:GetModel("EJ9DETAIL")


         If cCampo == "EKQ_VERSAO"
            cRet      := EKO->EKO_ID
            aSaveLines := FWSaveRows()
            oModelSWV:LoadValue("WV_LPCOPND",EvalPdLPCO(oMdl))
            FWRestRows(aSaveLines)
         ElseIf cCampo == "WV_QTDE"
            nQtdInf   := oModelSWV:GetValue("WV_QTDE")
            nLineSWV  := oModelSWV:GetLine()

            If !oModelSWV:IsDeleted() .And. !lVeioDelec

               hashItemWV :=  oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC")
               nQtdAntSWV :=  ManLstFrm(oMdl,'__oLstQtdInf', "GET" , hashItemWV ) // ManLstFrm(oMdl,'__oQtdSumSWV','GET',hashItemWV) //GetQtdSWV(oMdl,hashItemWV)
               cSeqAtu    :=  oModelSWV:GetValue("WV_SEQUENC")
               If nQtdInf > 0 .And. nQtdInf <> nQtdAntSWV
                  oStrGrdSWV  := oModelSWV:getStruct()
                  aCposSWV    := oStrGrdSWV:GetFields()
                  For i := 1 to Len(aCposSWV)
                     If aCposSWV [i][3] $ 'WV_FILIAL|WV_SEQUENC|WV_QTDE|WV_SEQDUIM|WV_ID'
                        If aCposSWV [i][3] == 'WV_FILIAL'
                           aAdd( aLoadCpos , {"WV_FILIAL" ,xFilial("SWV")})
                        ElseIf aCposSWV [i][3] == 'WV_SEQUENC'
                           aAdd( aLoadCpos , {"WV_SEQUENC",GetNextSeq(oModelSWV)/*SomaIt(oModelSWV:GetValue("WV_SEQUENC"))*/ }) // Adiciona nova sequência
                        ElseIf aCposSWV [i][3] == 'WV_QTDE'
                           aAdd( aLoadCpos , {"WV_QTDE"   ,nQtdAntSWV - nQtdInf                    }) // Adiciona a quantidade atualizada
                        ElseIf aCposSWV [i][3] == 'WV_SEQDUIM'
                           aAdd( aLoadCpos , {"WV_SEQDUIM"   ,""})
                        ElseIf aCposSWV [i][3] == 'WV_ID'
                           aAdd( aLoadCpos , {"WV_ID"   ,LP500GetIdSWV(.T.)})
                        EndIf
                     Else
                        aAdd( aLoadCpos , {aCposSWV[i][3]   ,oModelSWV:GetValue(aCposSWV[i][3])           })
                     EndIf
                  Next i

                  //BACKUP DA EKQ, EIJ, EKN, EJ9
                  aLinGDEKQ := BkpLinesGD(oModelEKQ)
                  oModelEIJ:LoadValue( "EIJ_QT_EST", EIJLoad("EIJ_QT_EST", oModelEIJ, oModelSWV, oModelSW9 ) )
                  oModelEIJ:LoadValue( "EIJ_PESOL", EIJLoad("EIJ_PESOL", oModelEIJ, oModelSWV, oModelSW9 ) )
                  oModelEIJ:LoadValue( "EIJ_VL_FIN", EIJLoad("EIJ_VL_FIN", oModelEIJ, oModelSWV, oModelSW9 ) )
                  aLinEIJ   := aClone(oModelEIJ:ADATAMODEL)[1] //pega os dados do registro posicionado da eij

                  aLinEINA  := BkpLinesGD(oModelEINA)
                  aLinEIND  := BkpLinesGD(oModelEIND)
                  aLinEIK   := BkpLinesGD(oModelEIK)
                  aLinEJ9   := BkpLinesGD(oModelEJ9)

                  //Criar nova linha no SWV
                  nAtuSWV := 0
                  GridAddLn(oModelSWV,aLoadCpos,{"WV_LOTE"},,@nAtuSWV)

                  //EKQ - LPCO's
                  For i := 1 To Len(aLinGDEKQ)
                     aLinGDEKQ[i][aScan(aLinGDEKQ[i],{|x|x[1] == "EKQ_SEQUEN" })][2] := oModelSWV:GetValue("WV_SEQUENC")
                     GridAddLn(oModelEKQ,aLinGDEKQ[i],{"EKQ_LPCO","EKQ_VERSAO"}, i <> 1)
                  Next i
                  oModelEKQ:GoLine(1)

                  //Atualiza a linha em branco da EIJ
                  oModelEIJ:ADATAMODEL[1] := aClone(aLinEIJ)
                  oModelEIJ:LoadValue("EIJ_IDWV",oModelSWV:GetValue("WV_ID"))
                  oModelEIJ:LoadValue( "EIJ_QT_EST", EIJLoad("EIJ_QT_EST", oModelEIJ, oModelSWV, oModelSW9 ) )
                  oModelEIJ:LoadValue( "EIJ_PESOL", EIJLoad("EIJ_PESOL", oModelEIJ, oModelSWV, oModelSW9 ) )
                  oModelEIJ:LoadValue( "EIJ_VL_FIN", EIJLoad("EIJ_VL_FIN", oModelEIJ, oModelSWV, oModelSW9 ) )

                  //Atualiza EINA (acréscimos)
                  For i := 1 To Len(aLinEINA)
                     aLinEINA[i][aScan(aLinEINA[i],{|x|x[1] == "EIN_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                     GridAddLn(oModelEINA,aLinEINA[i],{}, i <> 1)
                  Next i

                  //Atualiza EIND (deduções)
                  For i := 1 To Len(aLinEIND)
                     aLinEIND[i][aScan(aLinEIND[i],{|x|x[1] == "EIN_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                     GridAddLn(oModelEIND,aLinEIND[i],{}, i <> 1)
                  Next i

                  //Atualiza EIK (documentos vinculados)
                  For i := 1 To Len(aLinEIK)
                     aLinEIK[i][aScan(aLinEIK[i],{|x|x[1] == "EIK_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                     GridAddLn(oModelEIK,aLinEIK[i],{}, i <> 1)
                  Next i

                  //Atualiza EJ9 (documentos mercosul)
                  For i := 1 To Len(aLinEJ9)
                     aLinEJ9[i][aScan(aLinEJ9[i],{|x|x[1] == "EJ9_IDWV" })][2] := oModelSWV:GetValue("WV_ID")
                     GridAddLn(oModelEJ9,aLinEJ9[i],{}, i <> 1)
                  Next i

                  aPosCposKey := { ascan(aLoadCpos,{|x|x[1]=="WV_HAWB"}) , ascan(aLoadCpos,{|x|x[1]=="WV_INVOICE"}) , ascan(aLoadCpos,{|x|x[1]=="WV_PO_NUM"}) , ascan(aLoadCpos,{|x|x[1]=="WV_POSICAO"}) , ascan(aLoadCpos,{|x|x[1]=="WV_SEQUENC"}) , ascan(aLoadCpos,{|x|x[1]=="WV_QTDE"}) }
                  ManLstFrm(oMdl,'__oLstQtdInf','SET', aLoadCpos[aPosCposKey[1]][2] + aLoadCpos[aPosCposKey[2]][2] + aLoadCpos[aPosCposKey[3]][2] + aLoadCpos[aPosCposKey[4]][2] + cSeqAtu                      , nQtdInf                      ) //Grava na variável de backup o último valor digitado para a linha
                  ManLstFrm(oMdl,'__oLstQtdInf','SET', aLoadCpos[aPosCposKey[1]][2] + aLoadCpos[aPosCposKey[2]][2] + aLoadCpos[aPosCposKey[3]][2] + aLoadCpos[aPosCposKey[4]][2] + aLoadCpos[aPosCposKey[5]][2] , aLoadCpos[aPosCposKey[6]][2] ) //Grava na variável de backup o valor gerado para a nova linha
                  aSize(aLoadCpos,0)
                  aLoadCpos := Nil
                  lAtuTribut := .T.
               EndIf
            Elseif cAction == "DELETE" .or. cAction == "UNDELETE"

               aSaveRows := FWSaveRows()
               nQtdFilha := oModelSWV:GetValue("WV_QTDE")
               nLine     := LP500DevolvePai(oModelSWV:GetValue("WV_SEQUENC"), oModelSWV)
               If nLine > 0 //encontrou e posicionou na linha do pai
                  nAtuSWV := nLine
                  oModelSWV:GoLine(nLine)
                  nQtdPai := oModelSWV:GetValue("WV_QTDE")
               EndIf

               If cAction == "DELETE"
                  oModelSWV:LoadValue("WV_QTDE", nQtdPai + nQtdFilha) //restaurar qtde do pai já que linha filha foi deletada
                  oModelEIJ:LoadValue( "EIJ_QT_EST", EIJLoad("EIJ_QT_EST", oModelEIJ, oModelSWV, oModelSW9 ) )
                  oModelEIJ:LoadValue( "EIJ_PESOL", EIJLoad("EIJ_PESOL", oModelEIJ, oModelSWV, oModelSW9 ) )
                  oModelEIJ:LoadValue( "EIJ_VL_FIN", EIJLoad("EIJ_VL_FIN", oModelEIJ, oModelSWV, oModelSW9 ) )
                  //Atualiza o hashmap com a última quantidade informada (neste caso, restaurada para a linha)
                  ManLstFrm(oMdl,'__oLstQtdInf','SET', oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC") , oModelSWV:GetValue("WV_QTDE") )
                  oModelSWV:GoLine(nLineSWV) //reposiciona na linha que foi deletada
                  lDelAllLine := .T.
                  LP500DelEKQ(oMdl, cAction) //chama função para deleção da EKQ
                  If !lLP500Auto
                     oModelEKQ:SetNoInsertLine(.T.)
                  EndIf
               ElseIf cAction == "UNDELETE"
                  oModelSWV:LoadValue("WV_QTDE", nQtdPai - nQtdFilha) //subtrair qtde do pai já que linha filha foi 'desdeletada'
                  oModelEIJ:LoadValue( "EIJ_QT_EST", EIJLoad("EIJ_QT_EST", oModelEIJ, oModelSWV, oModelSW9 ) )
                  oModelEIJ:LoadValue( "EIJ_PESOL", EIJLoad("EIJ_PESOL", oModelEIJ, oModelSWV, oModelSW9 ) )
                  oModelEIJ:LoadValue( "EIJ_VL_FIN", EIJLoad("EIJ_VL_FIN", oModelEIJ, oModelSWV, oModelSW9 ) )
                  //Atualiza o hashmap com a última quantidade informada (neste caso, restaurada para a linha)
                  ManLstFrm(oMdl,'__oLstQtdInf','SET', oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC") , oModelSWV:GetValue("WV_QTDE") )
                  oModelSWV:GoLine(nLineSWV) //reposiciona na linha que foi DesDeletada
                  LP500DelEKQ(oMdl, cAction) //chama função para DesDeleção da EKQ
                  If !lLP500Auto
                     oModelEKQ:SetNoInsertLine(.F.)
                  EndIf
               EndIf
               lAtuTribut := cAction == "DELETE" .or. cAction == "UNDELETE"
               FWRestRows(aSaveRows)
            EndIf

            oModelSWV:GoLine(nLineSWV)

            if lAtuTribut
               if valtype(oMdl:GetModel("SWVDETAIL_TRIBUTACAO")) == "O"
                  LP500LdTrb(oMdl:GetModel("SWVDETAIL_TRIBUTACAO"), "SWVDETAIL_TRIBUTACAO", .T., nAtuSWV, if( empty(cAction), "NEWLINE", cAction))
               endif

               cRet := oModelSWV:GetValue("WV_LOTE")
               aSeek := {  {"WV_FILIAL" ,xFilial("SWV")}                  , {"WV_HAWB"   ,oModelSWV:GetValue("WV_HAWB")}    , {"WV_INVOICE",oModelSWV:GetValue("WV_INVOICE")} , ;
                  {"WV_PO_NUM" ,oModelSWV:GetValue("WV_PO_NUM")} , {"WV_POSICAO" ,oModelSWV:GetValue("WV_POSICAO")},{"WV_SEQUENC" , oModelSWV:GetValue("WV_SEQUENC")}}

               //Reordenação do Modelo para nova linha ser gerada logo abaixo da linha original após o refresh da View.
               aPKeyWV := { aScan(oModelSWV:AHEADER,{|x| x[2] == "WV_INVOICE" }) ,;
                  aScan(oModelSWV:AHEADER,{|x| x[2] == "WV_PO_NUM"  }) ,;
                  aScan(oModelSWV:AHEADER,{|x| x[2] == "WV_POSICAO" }) ,;
                  aScan(oModelSWV:AHEADER,{|x| x[2] == "WV_SEQUENC" })  }

               aSort(oModelSWV:aDATAMODEL,,, {|x,y| x[1][1][aPKeyWV[1]] + x[1][1][aPKeyWV[2]] + x[1][1][aPKeyWV[3]] + x[1][1][aPKeyWV[4]]  <  ;
                  y[1][1][aPKeyWV[1]] + y[1][1][aPKeyWV[2]] + y[1][1][aPKeyWV[3]] + y[1][1][aPKeyWV[4]]  } )

               If !lLP500Auto
                  oView:Refresh("VIEW_SWV")
               EndIf

               oModelSWV:SeekLine(aSeek, .F., .T.)
            endif
         ElseIf cCampo == "EKQ_ORGANU"
            cRet := "" //Space( TamSx3("EKQ_FRMLPC")[1] )

         ElseIf cCampo == "EKQ_FRMLPC"
            If Empty( oModelEKQ:GetValue("EKQ_FRMLPC") )
               cRet := Space( TamSx3("EKQ_DSCFRM")[1] )
            Else
               cRet := POSICIONE("EKL",1,xFilial("EKL") +  oModelEKQ:GetValue("EKQ_ORGANU") + oModelEKQ:GetValue("EKQ_FRMLPC")   ,"EKL_DESC")
            EndIf
         ElseIf cCampo == "EIJ_FABR_LOJA"
            //Loja
            //não gatilha se o preenchimento será pela consulta padrão
            If !FwIsInCallStack("GETLKRET")
               //apaga o valor anterior para forçar a validação
               oModelEIJ:loadValue("EIJ_FABLOJ", "")
               cRet:= AvGatilho(oMdl:GetModel():GetValue('EIJMASTER',"EIJ_FABR"), "SA2")
               oModelEIJ:setValue("EIJ_FABLOJ", cRet)

               //Se apagar a informação do fornecedor, apaga a loja, o nome, o pais e o TIN
               If Empty(cRet)
                  oModelEIJ:LoadValue("EIJ_FABRVM", cRet)
                  oModelEIJ:LoadValue("EIJ_PAISOR", cRet)
                  oModelEIJ:LoadValue("EIJ_TINFA", cRet)
               EndIf
            Else
               oModelEIJ:loadValue("EIJ_FABLOJ", "")
            EndIf

         ElseIf cCampo == "EIJ_FABLOJ_PAISOR"
            EKD->(DbSetOrder(2)) // EKD_FILIAL + EKD_NCM + EKD_IDPORT + EKD_VERSAO
            If EKD->(DbSeek( xFilial("EKD") + oModelSWV:GetModel():GetValue("SWVDETAIL","WV_NCM") + oMdl:GetModel():GetValue('EIJMASTER',"EIJ_IDPTCP") + oMdl:GetModel():GetValue('EIJMASTER',"EIJ_VRSACP")  ))
               EKF->(DbSetOrder(1)) //EKF_FILIAL+EKF_COD_I+EKF_VERSAO+EKF_CODFAB+EKF_LOJA+EKF_PAIS
               If EKF->(DbSeek( xFilial("EKF") + EKD->EKD_COD_I + oMdl:GetModel():GetValue('EIJMASTER',"EIJ_VRSACP") + oMdl:GetModel():GetValue('EIJMASTER',"EIJ_FABR") + oMdl:GetModel():GetValue('EIJMASTER',"EIJ_FABLOJ") ))
                  cRet:= EKF->EKF_PAIS
                  oModelEIJ:LoadValue("EIJ_PAISOR", cRet)
               EndIf
            EndIf
         ElseIf cCampo == "EIJ_FABLOJ_TINFA"
            EKJ->(DbSetOrder(1))
            If EKJ->(DbSeek( xFilial("EKJ") + Left( POSICIONE("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" ) , 8) + EKF->EKF_CODFAB + EKF->EKF_LOJA    ))
               cRet:= EKJ->EKJ_TIN
               oModelEIJ:LoadValue("EIJ_TINFA", cRet)
            EndIf
         ElseIf cCampo == "EIJ_FABLOJ_FABRVM"
            cRet:= AvKey(POSICIONE("SA2", 1, xFilial("SA2") + oMdl:GetModel():GetValue('EIJMASTER',"EIJ_FABR") + oMdl:GetModel():GetValue('EIJMASTER',"EIJ_FABLOJ"), "A2_NREDUZ" ), "EIJ_FABRVM")
            oModelEIJ:LoadValue("EIJ_FABRVM", cRet)
         ElseIf cCampo == "EIN_VLMLE"
            If AllTrim(oMdl:GETMODEL():GetValue(oMdl:aERRORMESSAGE[1],"EIN_FOBMOE")) == "R$"
               cRet := oMdl:GETMODEL():GetValue(oMdl:aERRORMESSAGE[1],"EIN_VLMLE")
            Else
               cRet:= oMdl:GETMODEL():GetValue(oMdl:aERRORMESSAGE[1],"EIN_VLMLE") * BuscaTaxa(oMdl:GETMODEL():GetValue(oMdl:aERRORMESSAGE[1],"EIN_FOBMOE"),dDataBase,.T.,.F.,.T.)
            EndIf
         ElseIf cCampo == "WV_SEQDUIM" .or. cCampo == "WV_NCM" // .or. cCampo == "WV_LOTE" .or. cCampo == "WV_DT_VALI" .or. cCampo == "WV_DFABRI" .or. cCampo == "WV_OBS" 
            cRet := oModelSWV:GetValue(cCampo)
            If cCampo == "WV_SEQDUIM" .and. !Empty(oModelSWV:GetValue("WV_SEQDUIM"))
               cRet := StrZero(Val(oModelSWV:GetValue("WV_SEQDUIM")), AVSX3("WV_SEQDUIM",AV_TAMANHO))
               oModelSWV:LoadValue("WV_SEQDUIM", cRet)
            EndIf

            if valtype(oMdl:GetModel("SWVDETAIL_TRIBUTACAO")) == "O"
               LP500LdTrb(oMdl:GetModel("SWVDETAIL_TRIBUTACAO"), "SWVDETAIL_TRIBUTACAO", .T.,, "GATILHO", cCampo)
            endif

         ElseIf cCampo == "EIN_CODACR_CODIGO"
            cRet:= oModelEINA:getValue("EIN_CODACR")
            oModelEINA:loadValue("EIN_CODIGO", cRet)
            oModelEINA:loadValue("EIN_TIPO", "1")

         ElseIf cCampo == "EIN_CODACR_DESC"
            SJN->(DBSetOrder(1)) //JN_FILIAL+JN_CODIGO
            SJN->(DBSeek(xFilial() + oModelEINA:getValue("EIN_CODACR")))
            cRet:= SJN->JN_DESC
            oModelEINA:loadValue("EIN_DESC", cRet)


         ElseIf cCampo == "EIN_CODDED_CODIGO"
            cRet:= oModelEIND:getValue("EIN_CODDED")
            oModelEIND:loadValue("EIN_CODIGO", cRet)
            oModelEIND:loadValue("EIN_TIPO", "2")

         ElseIf cCampo == "EIN_CODDED_DESC"
            SJO->(DBSetOrder(1)) //JO_FILIAL+JO_CODIGO
            SJO->(DBSeek(xFilial() + oModelEIND:getValue("EIN_CODDED")))
            cRet:= SJO->JO_DESC
            oModelEIND:loadValue("EIN_DESC", cRet)

         elseif cCampo == "EIJ_REGTRI" .or. cCampo == "EIJ_FUNREG" .or. cCampo == "EIJ_ALI_II"
            cRet := oMdl:GetModel("EIJMASTER_II"):GetValue(cCampo)
            LP500LdTrb(oMdl:GetModel("EIJMASTER_II"), "EIJMASTER_II", .T.,, "GATILHO", cCampo)
         elseif cCampo == "EIJ_REGIPI" .or. cCampo == "EIJ_ASSIPI" .or. cCampo == "EIJ_ALAIPI"
            cRet := oMdl:GetModel("EIJMASTER_IPI"):GetValue(cCampo)
            LP500LdTrb(oMdl:GetModel("EIJMASTER_IPI"), "EIJMASTER_IPI", .T.,, "GATILHO", cCampo)
         elseif cCampo == "EIJ_REG_PC" .or. cCampo == "EIJ_FUN_PC" .or. cCampo == "EIJ_ALAPIS" .or. cCampo == "EIJ_ALACOF"
            cRet := oMdl:GetModel("EIJMASTER_PISCOFINS"):GetValue(cCampo)
            LP500LdTrb(oMdl:GetModel("EIJMASTER_PISCOFINS"), "EIJMASTER_PISCOFINS", .T.,, "GATILHO", cCampo)
         elseif cCampo == "EIJ_OPERAC"
            cRet := oMdl:GetModel("EIJMASTER_ICMS"):GetValue(cCampo)
            LP500LdTrb(oMdl:GetModel("EIJMASTER_ICMS"), "EIJMASTER_ICMS", .T.,, "GATILHO", cCampo)

         elseif cCampo == "EIJ_IDPTCP_VRSFOR" .or. cCampo == "EIJ_IDPTCP_VRSFAB" .or. cCampo == "EIJ_FORLOJ_VRS" .or. cCampo == "EIJ_FABLOJ_VRS"
            cRet := GetFabFor("VERSAO", if(cCampo == "EIJ_IDPTCP_VRSFOR" .or. cCampo == "EIJ_FORLOJ_VRS", "FOR", "FAB"), oModelEIJ:GetValue("EIJ_IDPTCP") , oModelEIJ:GetValue("EIJ_VRSACP"), oMdl )
         endif

      EndIf
   elseif cCampo='WV_QTDE' .AND.  FwIsInCallStack("EICGI210")
      cRet := M->WV_LOTE //retorno necessário, pois quando alterava a quantidade pela L.I. e retornava "", apagava o campo No. Lote.
   EndIf

Return cRet

/*
Função     : PreVldLEKQ
Objetivo   : Funcao para validar ação na Linha - não permissao de exclusao de registro com
"Obrigatorio" = Sim
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function PreVldLEKQ(oGridEKQ, nLine, cAction)
   Local lRet := .T.

   If cAction == "DELETE" .And. oGridEKQ:GetValue("EKQ_OBRFRM") == "1" .And. (!IsMemVar("lDelAllLine") .Or. !lDelAllLine)
      EasyHelp(STR0017, STR0003, STR0018) //"Não é possível excluir linha cujo campo 'Obrigatorio?' está preenchido como 'Sim' " #Atenção# "Avalie a necessidade de exclusão da linha"
      lRet := .F.
   EndIf

Return lRet

/*
Programa   : PosVldLEKQ
Objetivo   : Funcao para validar se Linha está Ok
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function PosVldLEKQ(oGridEKQ, nLine, cAction)
   Local lRet := .T.

   If !Empty(oGridEKQ:GetValue("EKQ_LPCO"))
      If Empty(oGridEKQ:GetValue("EKQ_VERSAO"))
         EasyHelp(STR0015, STR0003, STR0016) //"Ao preencher a Versão o LPCO também deverá ser preenchido" #Atenção# "Preencha também o campo Versão do LPCO"
         lRet := .F.
      EndIf
   EndIf

Return lRet

/*
Programa   : PosVldLEJ9
Objetivo   : Funcao para validar se Linha está Ok
Retorno    : Logico
Autor      : Maurício Frison
Data/Hora  : Dezembro/2021
Obs.       :
*/
Static Function PosVldEJ9(oGridModel, nLine)
   Local aExceptions := {"EJ9_IDCERT","EJ9_DEMERC","EJ9_QTDCER"}
Return ValidLine(oGridModel, nLine,aExceptions)

/*
Função     : ValidLine
Objetivo   : Validação da linha - verifica se todos os campos foram preenchidos quando à ao menos um foi atribuído valor
Parâmetros : oGridModel, nLine, aExceptions
Retorno    : Lógico
Obs.       :
Autor      : wfs
Data/Hora  : dez/2021
*/
Static Function ValidLine(oGridModel, nLine, aExceptions)
   Local oStruct:= oGridModel:getStruct()
   Local aFields:= oStruct:getFields()
   Local lRet:= .T.
   Local i
   Local nPos
   Local aEmpty:= {}
   Local aNoEmpty:= {}
   Local cField
   Local cEmptyFields:= ""
   Local cHelpP
   Local cHelpS


   For i := 1 to Len(aExceptions)

      cField:= aExceptions[i]

      If Empty(oGridModel:getValue(cField))
         AAdd(aEmpty, cField)

         If !Empty(cEmptyFields)
            cEmptyFields += ", "
         EndIf

         nPos:= AScan(aFields, {|x| x[3] == cField})
         cEmptyFields += aFields[nPos][1]
      Else
         AAdd(aNoEmpty, cField)
      EndIf


   Next i

   If Len(aEmpty) > 0 .And. Len(aNoEmpty) > 0

      cHelpP:= STR0095 //"Existem campos não informados na linha ### da pasta ***."
      cHelpP:= StrTran(cHelpP, "###", AllTrim(str(nLine)))
      cHelpP:= StrTran(cHelpP, "***", getFolder(oGridModel:getId()))

      cHelpS:= STR0096 //"Revise o(s) campo(s) '###' da pasta $$$, linha ***."
      cHelpS:= StrTran(cHelpS, "###",  cEmptyFields)
      cHelpS:= StrTran(cHelpS, "$$$",  getFolder(oGridModel:getId()))
      cHelpS:= StrTran(cHelpS, "***", AllTrim(str(nLine)))

      EasyHelp(cHelpP, STR0003, cHelpS)

      lRet:= .F.
   EndIf

Return lRet

/*
Função     : getFolder
Objetivo   : Recuperar o nome da pasta onde o grid se encontra
Parâmetros : cIdModel
Retorno    : nome do folder
Obs.       :
Autor      : wfs
Data/Hora  : dez/2021
*/
Static Function getFolder(cIdModel)
   Local oView:= FWViewActive()
Return oView:GetViewObj(cIdModel)[7]

/*
Função     : LoadWhLine
Objetivo   : Funcao para retornar um array com dados para criação de
             nova linha do grid EKQ em branco.
Retorno    : Array
Autor      : Nilson César
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function LoadWhLine(oModel)
   Local oMdl          := oModel:GetModel()	// Carrega Model Master
   Local oStrGrdEKQ    := oModel:getStruct()
   Local aCpoEKQ       := oStrGrdEKQ:GetFields()
   Local aFilCpos      := {}
   Local aRet, i

   For i := 1 to Len(aCpoEKQ)
      aAdd(aFilCpos, LP500INI(aCpoEKQ[i][3], oMdl))
   Next nContCpo

   aRet := {0 , aFilCpos}

Return aRet


/*
Função     : AltQtdLote
Objetivo   : Valida e atualiza o modelo conforme alteração na quantidade do Lote.
Retorno    : Lógico
Autor      : Nilson César
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function AltQtdLote(oModel)

   Local oMdl
   Local oModelSWV
   Local lRet          := .T.
   Local nQtdAntSWV := nQtdInf := 0

   If ValType(oModel) == 'O'

      oMdl          := oModel:GetModel()
      oModelSWV     := oMdl:GetModel("SWVDETAIL")
      oModelEKQ     := oMdl:GetModel("EKQDETAIL")
      nQtdInf       := oModelSWV:GetValue("WV_QTDE")

      hashItemW8 :=  oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC")
      nQtdAntSWV := ManLstFrm(oModel,'__oLstQtdInf' ,'GET',hashItemW8)

      If nQtdInf == 0
         EasyHelp( STR0036 + GetMsgErrIt(oModelSWV) , STR0003 , STR0037 ) // "Quantidade informada para o lote não pode ser zero !" # "Informe uma quantidade menor que a exibida para esta linha!"
         lRet := .F.
      EndIf

      If nQtdInf > nQtdAntSWV
         EasyHelp(STR0038  + GetMsgErrIt(oModelSWV), STR0003 , STR0037 ) // "Quantidade informada para o lote não pode ser maior que a quantidade original do item na invoice!" # Informe uma quantidade menor que a exibida para esta linha!"
         lRet := .F.
      EndIf

   EndIf

Return lRet


/*
Função     : GetEModSWV
Objetivo   : Retorna o saldo original em invoice (somatório) carregado
             para determinada linha de lote no grid SWV
Retorno    : Lógico
Autor      : Nilson César
Data/Hora  : Agosto/2021
Obs.       :
*/

Static Function GetQtdSWV(oModel,hashItemWV)

   Local aAux
   Local nQtdSWV := 0
   Local oMdl         := oModel:GetModel()
   Local oModelSWV    := oMdl:GetModel("SWVDETAIL")
   Local nLineAtu     := oModelSWV:GetLine()
   Local i
   Local aSaveRows    := FWSaveRows()
   Default hashItemWV := ''

   If ValType( __oQtdSumSWV ) == "U"
      __oQtdSumSWV := tHashMap():New()
   EndIf

   __oQtdSumSWV:List(@aAux)

   If Len(aAux) == 0
      //Roda o oModel obtendo a soma das linhas com mesmo hashItemWV e adiciona no __oQtdSumSWV, já retornando o nQtde
      oModelSWV:GoLine(1)
      For i:=1 To oModelSWV:GetQtdLine()
         oModelSWV:GoLine(i)
         cHashLinWV := oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO")
         If !__oQtdSumSWV:Get( cHashLinWV , @nQtdSWV  )
            __oQtdSumSWV:Set( cHashLinWV , oModelSWV:GetValue("WV_QTDE")  )
         Else
            __oQtdSumSWV:Set( cHashLinWV , nQtdSWV + oModelSWV:GetValue("WV_QTDE")  )
         EndIf
      Next i
      oModelSWV:GoLine(nLineAtu)
      If !Empty(hashItemWV)
         __oQtdSumSWV:Get( hashItemWV , @nQtdSWV  )
      EndIf
   Else
      If !__oQtdSumSWV:Get(hashItemWV, @nQtdSWV)
         EasyHelp(STR0034+hashItemWV ) //"Não foi possível obter a quantidade do item chave: "
      EndIf
   EndIf

   FwRestRows(aSaveRows)

Return nQtdSWV


/*
Função     : GetMsgErrIt
Objetivo   : Formata e retorna mensagem indicando o item posicionado no grid SWV
Retorno    : Lógico
Autor      : Nilson César
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function GetMsgErrIt(oModelSWV)

   Local cMsgRet

   cMsgRet := StrTran( STR0045 , 'W8_HAWB'    , oModelSWV:GetValue("WV_HAWB")    ) //"Processo: 'W8_HAWB' , Invoice: 'W8_INVOICE', P.O.: 'W8_PO_NUM' e Posição: 'W8_POSICAO' "
   cMsgRet := StrTran( cMsgRet , 'W8_INVOICE' , oModelSWV:GetValue("WV_INVOICE") )
   cMsgRet := StrTran( cMsgRet , 'W8_PO_NUM'  , oModelSWV:GetValue("WV_PO_NUM")  )
   cMsgRet := StrTran( cMsgRet , 'W8_POSICAO' , oModelSWV:GetValue("WV_POSICAO") )
   cMsgRet := ENTER + cMsgRet

Return cMsgRet


/*
Função     : GridAddLn
Objetivo   : Formata e retorna mensagem indicando o item posicionado no grid SWV
Retorno    : Lógico
Autor      : Nilson César
Data/Hora  : Agosto/2021
Obs.       :
*/
Static Function GridAddLn(oMdlGrid, aLoadCpos, aNoLoadCpos, lAddLine, nLine)
   Local lRet := .T.

   Default aNoLoadCpos := {}
   Default lAddLine:= .T.

   default nLine := 0

   If oMdlGrid:getId() == "SWVDETAIL"
      oMdlGrid:SetNoInsertLine(.F.)
   EndIf

   nLine := AddLine(oMdlGrid, aLoadCpos, aNoLoadCpos, lAddLine)

   If oMdlGrid:getId() == "SWVDETAIL"
      oMdlGrid:SetNoInsertLine(.T.)
   EndIf

Return lRet

/*
Função     : BkpLinesGD
Objetivo   : Retornar um array com os campos e o dado dos campos para cada linha do grid indicado.
Retorno    : Array
Autor      : Nilson César
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function BkpLinesGD(oMdlGrid)
   Local aRet := {}, aAux := {}
   Local i,j
   Local aSaveRows := FWSaveRows()

   For i := 1 To oMdlGrid:GetQtdLine()
      oMdlGrid:Goline(i)
      For j := 1 to Len(oMdlGrid:OFORMMODELSTRUCT:AFIELDS)
         aAdd(aAux,{oMdlGrid:OFORMMODELSTRUCT:AFIELDS[j][3], oMdlGrid:GetValue(oMdlGrid:OFORMMODELSTRUCT:AFIELDS[j][3])})
      Next j
      aAdd(aRet,aClone(aAux))
      aSize(aAux,0)
   Next i

   FwRestRows(aSaveRows)

Return aRet


/*
Função     : PosVldLSWV
Objetivo   : Função para verificar se o id do portal está preenchido com a versão
Retorno    : .T. se o id do portal e a versão estiverem preenchidas ou as duas estiverem sem preenchimento
             .F. se uma infomraçõa estiver preenchida e outra sem preencher
Autor      : Maurício Frison
Data/Hora  : Setembro/2022
Obs.       :
*/
Static Function PosVldLSWV(oGridSWV, nLine )
Local lRet      :=.T.
Local oMdl      := FWModelActive()
Local cIdPortal := oMdl:GetModel():GetValue('EIJMASTER',"EIJ_IDPTCP")
Local cVersao   := oMdl:GetModel():GetValue('EIJMASTER',"EIJ_VRSACP")
Local cFab      := oMdl:GetModel():GetValue('EIJMASTER',"EIJ_FABR")
Local cFabLoj   := oMdl:GetModel():GetValue('EIJMASTER',"EIJ_FABLOJ")
Local cForn     := oMdl:GetModel():GetValue('EIJMASTER',"EIJ_FORN")
Local cForLoj   := oMdl:GetModel():GetValue('EIJMASTER',"EIJ_FORLOJ")
Local cNcm      := oMdl:GetModel():GetValue("SWVDETAIL","WV_NCM")
Local cMsg      := ''
Local cCodPortal:= Posicione("EKD",2,xFilial("EKD") + cNcm  + cIdPortal + cVersao,'EKD_COD_I')
Begin Sequence
   if !Empty(cIdPortal) .and. !Empty(cVersao)
      If !EKF->(dbSeek( xFilial("EKF") + cCodPortal + cVersao + cForn + cForLoj))
         lRet := .F.
         cMsg:=STR0120 //'O fornecedor informado no item não possui vínculo com o Catálogo de Produtos informado'
      EndIf    
      If !EKF->(dbSeek( xFilial("EKF") + cCodPortal + cVersao + cFab + cFabLoj))         
         cMsg:= If(!lREt,STR0121,STR0122) //O fornecedor e o fabricante informados no item não possuem vínculo com o Catálogo de produtos informado','O fabricante informado no item não possui vínculo com o Catálogo de produtos informado'
         lRet:=.f.
      EndIf   
      if !lRet
         EasyHelp(cMsg, STR0003, STR0123) //Revise os dados dos operadores estrangeiros antes de prosseguir."      
      EndIF   
   EndIF
End Sequence
Return lRet


/*
Função     : PreVldLSWV
Objetivo   : Função para saber se linha do grid de vinculação(SWV) pode ou não ser excluída
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function PreVldLSWV(oGridSWV, nLine, cAction, cCampo, cVlNew, cVlOld)
   Local oModel         := nil
   Local oModelEKQ      := nil
   Local lRet           := .T.
   Local lTemLPCO       := .F.
   Local lTemLote       := .F.
   Local cRetMsg        := ""
   Local cSeqLnPai      := ""
   Local nX

   Begin Sequence

      If cAction == "DELETE"
         cSeqLnPai := STRZERO(1, AVSX3("WV_SEQUENC",3))
         //Procura se há linha pai - saber se linha a ser excluída é originada a partir de uma quebra
         If oGridSWV:GetValue("WV_SEQUENC") <> cSeqLnPai
            //cRetMsg := STR0028 + ENTER //"Esta linha foi originada a partir de uma quebra de linha. "
            If !Empty(oGridSWV:GetValue("WV_LOTE"))
               lTemLote := .T.
            EndIf
            oModel := FWModelActive()
            oModelEKQ := oModel:GetModel("EKQDETAIL")
            For nX := 1 To oModelEKQ:Length()
               oModelEKQ:GoLine(nX)
               If !Empty(oModelEKQ:GetValue("EKQ_LPCO"))
                  lTemLPCO := .T.
                  exit
               EndIf
            Next nX
            If lTemLPCO
               cRetMsg += STR0029 + ENTER //"Esta linha foi originada a partir de uma quebra de linha. " # " Existe LPCO vinculado a este registro. "
            EndIf
            If lTemLote
               cRetMsg += STR0030 + ENTER //"Esta linha foi originada a partir de uma quebra de linha. " # " Existe Lote vinculado a este registro. "
            EndIf
         Else
            lRet := .F.
            EasyHelp(STR0031, STR0003, STR0032) //"Não é possível excluir esta linha. ", "Atenção", "Apenas será possível excluir linha originada a partir de uma quebra")
            Break
         EndIf

         If !lLP500Auto
            If MsgYesNo(STR0028 + ENTER + cRetMsg + STR0033) //STR0028 "Esta linha foi originada a partir de uma quebra de linha. "- STR0033 - Confirma a Exclusão?
               lRet := .T.
               LP500GATIL("WV_QTDE", .T., cAction)
            Else
               lRet := .F.
               EasyHelp(cRetMsg,STR0003, STR0046) // Serão informadas na mensagem as pendências ## "Operação cancelada pelo usuário"
               Break
            EndIf
         Else
            If Empty(cRetMsg)
               lRet := .T.
               LP500GATIL("WV_QTDE", .T., cAction)
            Else
               lRet := .F.
               EasyHelp(STR0039 + cRetMsg,STR0003,STR0040) // "Registro não pôde ser excluído!" # "Verifique as pendências que impedem que o registro seja excluído!"
               Break
            EndIf
         EndIf

      ElseIf cAction == "UNDELETE"
         LP500GATIL("WV_QTDE", .T., cAction)
      EndIf

   End Sequence

Return lRet

/*
Função     : BkpQtdSWV
Objetivo   : Função para armazenar/recuperar o último valor digitado no campo de
             quantidade do lote no grid.
Retorno    : Logico
Autor      : Ramon Prado
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function BkpQtdSWV(oModel,hashItemWV,xValue)

   Local aAux
   Local nQtdSWV := 0
   Local oMdl         := oModel:GetModel()
   Local oModelSW9    := oMdl:GetModel("SW9DETAIL")
   Local oModelSWV    := oMdl:GetModel("SWVDETAIL")
   Local nAtLnSW9     := oModelSW9:GetLine()
   Local nAtLnSWV     := oModelSWV:GetLine()
   Local h,i
   Local aSaveRows := FWSaveRows()
   Default hashItemWV := ''

   If ValType( __oLstQtdInf ) == "U"
      __oLstQtdInf := tHashMap():New()
   EndIf

   __oLstQtdInf:List(@aAux)

   If Len(aAux) == 0
      //Roda o oModel obtendo a soma das linhas com mesmo hashItemWV e adiciona no __oLstQtdInf, já retornando o nQtde
      oModelSW9:Goline(1)
      For h := 1 To oModelSW9:GetQtdLine()
         oModelSW9:Goline(h)
         oModelSWV:GoLine(1)
         For i:=1 To oModelSWV:GetQtdLine()
            oModelSWV:GoLine(i)
            cHashLinWV := oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_SEQUENC")
            __oLstQtdInf:Set( cHashLinWV , nQtdSWV + oModelSWV:GetValue("WV_QTDE")  )
         Next i
      Next h
      oModelSW9:GoLine(nAtLnSW9)
      oModelSWV:GoLine(nAtLnSWV)
      If !Empty(hashItemWV)
         If xValue == Nil
            __oLstQtdInf:Get( hashItemWV , @nQtdSWV  )
         else
            __oLstQtdInf:Set( hashItemWV , xValue  )
         EndIf
      EndIf
   Else
      If ValType(xValue) == "N"
         __oLstQtdInf:Set( hashItemWV , xValue  )
      else
         If !__oLstQtdInf:Get(hashItemWV, @nQtdSWV)
            EasyHelp(STR0041+hashItemWV ) //"Não foi possível obter a quantidade do item chave: "
         EndIf
      EndIf
   EndIf

   FWRestRows(aSaveRows)

Return nQtdSWV


/*
Função     : LP500DevolvePai
Objetivo   : Função para recompor saldo da linha pai quando linha filha foi excluída
Retorno    : Array contendo na primeira posição a linha do pai, e quantidade atual do pai
Autor      : Ramon Prado
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function LP500DevolvePai(cSeqFilha, oModelSWV)
   Local aSeek := {}
   Local nSubTrai  := 1
   Local cSeqPai   := STRZERO(VAL(cSeqFilha) - nSubTrai, AVSX3("WV_SEQUENC",3)) //vai subtraindo a sequencia a procura do pai
   Local cSeqPrimPai := STRZERO(1, AVSX3("WV_SEQUENC",3))
   Local lAchou    := .F.
   Local nLineRet  := 0

   //ate achar o pai nao deletado
   While !lAchou .And. VAL(cSeqPai) >= VAL(cSeqPrimPai)
      aSeek := { {"WV_FILIAL" ,xFilial("SWV")}                  , {"WV_HAWB"   ,oModelSWV:GetValue("WV_HAWB")}    , {"WV_INVOICE",oModelSWV:GetValue("WV_INVOICE")} , ;
         {"WV_PO_NUM" ,oModelSWV:GetValue("WV_PO_NUM")} , {"WV_POSICAO" ,oModelSWV:GetValue("WV_POSICAO")},{"WV_SEQUENC" , cSeqPai}}
      If oModelSWV:SeekLine(aSeek , .F. , .T. )
         nLineRet := oModelSWV:GetLine()
         lAchou  := .T.
      EndIf

      cSeqPai := STRZERO(VAL(cSeqFilha) - nSubTrai, AVSX3("WV_SEQUENC",3)) //vai subtraindo a sequencia a procura do pai
      nSubTrai++
   EndDo

Return nLineRet

/*
Função     : LP500DelEKQ
Objetivo   : Função para deleção de todas as linhas do grid EKQ
Retorno    : Array contendo na primeira posição a linha do pai, e quantidade atual do pai
Autor      : Ramon Prado
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function LP500DelEKQ(oModel, cAction)
   Local oModelEKQ := oModel:GetModel("EKQDETAIL")
   Local nX        := 0

   If ValType(oModelEKQ) == "O"
      If cAction == "DELETE"
         oModelEKQ:DelAllline()
      Elseif cAction == "UNDELETE"
         For nX := 1 to oModelEKQ:Length()
            oModelEKQ:GoLIne(nX)
            If oModelEKQ:IsDeleted()
               oModelEKQ:UnDeleteLine()
            EndIf
         Next nX
      EndIf
   EndIf

Return

/*
Programa   : addLinpos
Objetivo   : Funcao para Adicionar um atributo LINPOS para cada item do array. O array é um conjunto de itens para o MSExecAuto
Retorno    : Array
Autor      : Adaptação de Função do Nilson - EECNF400
Data/Hora  : Setembro/2021
Obs.       :
*/
//
Static Function addLinpos(aItens, cAlias)
   Local cLinPos := ""
   Local aLinPos := {}
   Local i := 0
   Local j            := 0
   Local nIndexAtr := 0
   Local aUmItem   := {}
   Local aSeek      := {}
   Local cSeek     := ""


   if aItens == Nil
      Return
   EndIf

   If cAlias == 'SWV'
      SWV->(DbSetOrder(3))
      cLinPos := SWV->(IndexKey(3))
   ElseIf cAlias == 'EKQ'
      EKQ->(DbSetOrder(1))
      cLinPos := EKQ->(IndexKey(1))
   EndIf

   aLinPos := StrTokArr(cLinPos,'+')
   For i := 1 To Len(aItens)
      cLinPos := ""
      cSeek   := xFilial(cAlias)
      aUmItem := aClone(aItens[i])
      aSeek   := {}
      For j := 1 to Len(aLinPos)
         If !('_FILIAL' $ aLinPos[j])
            nIndexAtr := getExecInd(aUmItem, aLinPos[j])
            If nIndexAtr > 0
               cLinPos += If(!Empty(cLinPos), "+"+aLinPos[j] , aLinPos[j] )
               cSeek += AvKey(aUmItem[nIndexAtr][2], aLinPos[j])
               aAdd(aSeek, aUmItem[nIndexAtr][2])
            EndIf
         Endif
      Next j
      If (cAlias)->(DbSeek(cSeek))
         addOneLinp(aItens[i], cLinPos, aSeek)
      EndIf
   Next

Return

/*
Programa   : getExecInd
Objetivo   :  Retorna o índice que tenha o attributo do array aItem
Retorno    : Array
Autor      : Adaptação de Função do Nilson - EECNF400
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function getExecInd(aItem, cAttr)
Return aScan(aItem, {|x| x[1] == cAttr})

/*
Programa   : addOneLinp
Objetivo   :  Adiciona uma nova linha de LinPos
Retorno    : Array
Autor      : Adaptação de Função do Nilson - EECNF400
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function addOneLinp(aUmItem, cAttr, aLinPos)
   Local i := 0
   Local aDados := {}

   aAdd(aDados, "LINPOS")
   aAdd(aDados, cAttr)
   For i := 1 to Len(aLinPos)
      aAdd(aDados, aLinPos[i])
   Next i

   aAdd(aUmItem, aDados)

Return

/*
Função     : EvalPdLPCO
Objetivo   : Avaliar as linhas de grid EKQ relacionadas à linha de grid SWV
             posicionada de forma a determinar o valor do campo WV_LPCOPND
Retorno    : Status para o campo WV_LPCOPND
Autor      : Nilson César
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function EvalPdLPCO(oModel)

   Local i, cSttRet:= ''
   Local oMdlEKQ     := oModel:GetModel("EKQDETAIL")
   Local aPendLPCO   := {}
   Local aLnOKLPCO   := {}

   For i:=1 To oMdlEKQ:GetQtdLine()
      oMdlEKQ:GoLine(i)
      If oMdlEKQ:GetValue("EKQ_OBRFRM") == "1"
         If Empty(oMdlEKQ:GetValue("EKQ_LPCO")) .Or. Empty(oMdlEKQ:GetValue("EKQ_VERSAO"))
            aAdd( aPendLPCO, { oMdlEKQ:GetValue("EKQ_ORGANU"),oMdlEKQ:GetValue("EKQ_FRMLPC") } )
         Else
            aAdd( aLnOKLPCO, { oMdlEKQ:GetValue("EKQ_ORGANU"),oMdlEKQ:GetValue("EKQ_FRMLPC") } )
         EndIf
      EndIf
   Next i
   oMdlEKQ:GoLine(1)

   If Len(aPendLPCO) > 0
      For i := 1 To Len(aPendLPCO)
         cSttRet += Alltrim(aPendLPCO[i][1]) + '/' + Alltrim(aPendLPCO[i][2]) + If(i<Len(aPendLPCO),",","")
      Next i
      cSttRet := STR0042 + cSttRet //"Pendente informar LPCO Órgão Anuente/Form.:  "
   ElseIf Len(aLnOKLPCO) > 0
      cSttRet := STR0043 //"Sem pendências de LPCO"
   Else
      cSttRet := STR0044 //"Sem necessidade de LPCO"
   EndIf

Return cSttRet

/*
Função     : AllEvPLPCO
Objetivo   : Avaliar as linhas de grid EKQ relacionadas às linhas de grid SWV
             carregadas de forma a determinar o valor do campo WV_LPCOPND
Retorno    : Nenhum
Autor      : Nilson César
Data/Hora  : Setembro/2021
Obs.       :
*/
Static Function AllEvPLPCO(oModel)
   Local aSaveLines  := FWSaveRows()
   Local oMdl     := oModel:GetModel()
   Local oMdlSW9  := oMdl:GetModel("SW9DETAIL")
   Local oMdlSWV  := oMdl:GetModel("SWVDETAIL")
   Local h,i, cStatusSWV := ""
   Local nAtLnSW9 := oMdlSW9:GetLine()
   Local nAtLnSWV := oMdlSWV:GetLine()

   oMdlSW9:GoLine(1)
   For h := 1 To oMdlSW9:GetQtdLine()
      oMdlSW9:GoLine(h)
      For i := 1 To oMdlSWV:GetQtdLine()
         oMdlSWV:GoLine(i)
         cStatusSWV := EvalPdLPCO(oModel)
         oMdlSWV:LoadValue("WV_LPCOPND",cStatusSWV)
      Next
   Next h

   oMdlSW9:GoLine(nAtLnSW9)
   oMdlSWV:GoLine(nAtLnSWV)
   FWRestRows(aSaveLines)

Return .T.

/*
Função     : GetNextSeq
Objetivo   : Função para buscar a próxima sequencia disponível na inclusão de linha no grid SWV
Retorno    : código da próxima sequência disponível
Autor      : Nilson César
Data/Hora  : Setembro/2021
Obs.       : Considera as linhas deletadas na busca
*/
Static Function GetNextSeq(oModelSWV)
   Local lSeek     := .T.
   Local nLineAt   := oModelSWV:GetLine()
   Local cSeqIndex := oModelSWV:GetValue("WV_SEQUENC")
   Local aSeek     := { {"WV_FILIAL" ,xFilial("SWV")}                  , {"WV_HAWB"    ,oModelSWV:GetValue("WV_HAWB")}    , {"WV_INVOICE",oModelSWV:GetValue("WV_INVOICE")} , ;
      {"WV_PO_NUM" ,oModelSWV:GetValue("WV_PO_NUM")} , {"WV_POSICAO" ,oModelSWV:GetValue("WV_POSICAO")} , {"WV_SEQUENC" , cSeqIndex}}
   While lSeek
      If ( lSeek := oModelSWV:SeekLine(aSeek , .T. , .T. ) )
         cSeqIndex  := SomaIt(cSeqIndex)
         aSeek[6,2] := cSeqIndex
      EndIf
   EndDo

   oModelSWV:GoLine(nLineAt)

Return cSeqIndex

/*
Função     : LoadCpoVir
Objetivo   : Retornar valores para campos virtuais baseado nos dados do registro
Retorno    : xRet - valor a ser colocado no campo
Autor      : Nilson César
Data/Hora  : Outubro/2021
Obs.       : Considera tabelas posicionadas (SWV,EKQ) no registro
*/
Static Function LoadCpoVir(cCpo,xOrig)

   Local xRet

   Do Case

      Case cCpo == "EKQ_DSCFRM"
         If Valtype(xOrig) == "C" .And. xOrig == "EKQ"
            xRet := Posicione("EKL",1,xFilial("EKL")+EKQ->EKQ_ORGANU+EKQ->EKQ_FRMLPC,"EKL_DESC")
         elseif Valtype(xOrig) == "A"
            xRet := Posicione("EKL",1,xFilial("EKL") + xOrig[1] + xOrig[2],"EKL_DESC")
         EndIf

      Case cCpo == "EIN_CODACR" .Or. cCpo == "EIN_CODDED"
         xRet:= EIN->EIN_CODIGO

   End Case

Return xRet

/*
Função     : ChangeLnWV
Objetivo   : Executar uma ação a cada mudança de linha no grid SWV
Retorno    : Nenhum
Autor      : Nilson César
Data/Hora  : Outubro/2021
*/
Static Function ChangeLnWV(oView, cViewID)

   Local oMdl    := FWModelActive()
   Local oMdlSWV := oMdl:GetModel("SWVDETAIL")
   Local oMdlEKQ := oMdl:GetModel("EKQDETAIL")

   oMdlEKQ:SetNoInsertLine(  oMdlSWV:IsDeleted()  )

Return

/*
Função     : GerSeqDuimp
Objetivo   : Gera sequência DUIMP automaticamente
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Outubro/2021
*/
Static Function GerSeqDuimp(lPergunta)

   Local oMdl       := FWModelActive()
   Local oModelSW9  := oMdl:GetModel("SW9DETAIL")
   Local oMdlSWV    := oMdl:GetModel("SWVDETAIL")
   Local i,nLines,nSeq:=0,nSW9
   Local lContinua  := .T.
   Local lExit      := .F.
   Local aSaveLines := FWSaveRows()
   local oMdlSWVTrb := nil
   local lModSWVTrb := .F.

   //Verifica se tem alguma linha com o campo sequência duimp preenchido
   if lPergunta
      For nSW9 := 1 To oModelSW9:Length()
         oModelSW9:GoLine(nSW9)
         for i:=1 to 10
            if oMdlSWV:SeekLine({{"WV_SEQDUIM",strzero(i-1,1)}}, .F., .F. ) //pesquisa se existe alguma linha começando com a sequenciad duimp entre 0 e 9, se não encontrar é pq não existe nenhum item preenchdio
               lExit:=.T.
               lContinua := MsgNoYes(STR0052,STR0048) //"Existe um ou mais registos com o campo sequência DUIMP preenchido, se continuar os valores serão sobrepostos, deseja continuar?","AVISO"
               Exit
            EndIf
         NEXT i
         if lExit
            EXIt
         EndIf
      Next nSW9
   EndIf   

   if lContinua
      oMdlSWVTrb := oMdl:GetModel("SWVDETAIL_TRIBUTACAO")
      lModSWVTrb := valtype(oMdlSWVTrb) == "O"
      For nSW9 := 1 To oModelSW9:Length()
         oModelSW9:GoLine(nSW9)
         nLines :=  oMdlSWV:Length()
         For i:=1 To nLines
            oMdlSWV:GoLine(i)
            If !oMdlSWV:IsDeleted()
               nSeq += 1
               oMdlSWV:LoadValue("WV_SEQDUIM",strZero(nSeq,AVSX3("WV_SEQDUIM",AV_TAMANHO)))
               if lModSWVTrb
                  LP500LdTrb(oMdlSWVTrb, "SWVDETAIL_TRIBUTACAO", .T.,, "GATILHO", "WV_SEQDUIM")
               endif
            EndIf
         Next i
      Next SW9
   EndIf
   FWRestRows(aSaveLines)
Return

/*
Função     : DelSeqDuimp
Objetivo   : Apagar as sequências DUIMP
Retorno    : Nenhum
Autor      : Maurício Frison
Data/Hora  : Outubro/2021
*/
Static Function DelSeqDuimp(lPergunta)
   Local oMdl       := FWModelActive()
   Local oModelSW9  := oMdl:GetModel("SW9DETAIL")
   Local oMdlSWV    := oMdl:GetModel("SWVDETAIL")
   Local i,nLines,nSW9
   Local aSaveLines := {}
   Local lContinua  := .T.
   local oMdlSWVTrb := nil
   local lModSWVTrb := .F.

   default lPergunta := .F.

   lContinua := if(lPergunta,MsgNoYes(STR0053,STR0048),.T.) //"Deseja apagar todas as sequências da DUIMP?","AVISO"

   if lContinua
      aSaveLines := FWSaveRows()
      oMdlSWVTrb := oMdl:GetModel("SWVDETAIL_TRIBUTACAO")
      lModSWVTrb := valtype(oMdlSWVTrb) == "O"
      For nSW9 := 1 To oModelSW9:Length()
         oModelSW9:GoLine(nSW9)
         nLines:=oMdlSWV:Length()
         For i:=1 To nLines
            oMdlSWV:GoLine(i)
            oMdlSWV:LoadValue("WV_SEQDUIM","")
            if lModSWVTrb
               LP500LdTrb(oMdlSWVTrb, "SWVDETAIL_TRIBUTACAO", .T.,, "GATILHO", "WV_SEQDUIM")
            endif
         Next i
      Next nSW9
      FWRestRows(aSaveLines)
   EndIf
Return

/*
Função     : GetInfW7W8
Objetivo   : Posicionar o registro da SW8 e retornar a informação dos campos passados
             por parâmetro na variável xCpos
Parâmetros : oModel -> Objeto - modelo de dados ativo
             xCpos  -> Caracter/Array - campo ou campos das tabelas SW7 ou SW8 para retornar o valor
Retorno    : aRet - Array com os dados de cada campo para o registo, na mesma ordem de
                    indicação dos campos.
Obs.       : A tabela é definida pelo nome do primeiro campo passado no parâmetro
             Não passar campos de tabelas diferentes no mesmo array!
Autor      : Nilson César
Data/Hora  : Outubro/2021
*/
Static Function GetInfW7W8(oModelSWV,xCpos)
   Local i
   Local aRet := {}
   Local cAlias, nOrdSeek, cKeySeek

   If Valtype(xCpos) <> "A"
      xCpos := {xCpos}
   EndIf
   cAlias   := If( Left(xCpos[1],2) == "W7", "SW7","SW8"  )
   nOrdSeek := If(cAlias == "SW7",4,6)                     //W7_FILIAL+W7_HAWB+W7_PO_NUM+W7_POSICAO+W7_PGI_NUM  #### //W8_FILIAL+W8_HAWB+W8_INVOICE+W8_PO_NUM+W8_POSICAO+W8_PGI_NUM
   (cAlias)->(DbSetOrder( nOrdSeek ))

   If cAlias == "SW7"
      cKeySeek := xFilial("SW7") + oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_PGI_NUM")
   Else
      cKeySeek := xFilial("SW8") + oModelSWV:GetValue("WV_HAWB") + oModelSWV:GetValue("WV_INVOICE") + oModelSWV:GetValue("WV_PO_NUM") + oModelSWV:GetValue("WV_POSICAO") + oModelSWV:GetValue("WV_PGI_NUM")
   EndIf

   If cKeySeek <> (cAlias)->&(IndexKey())
      (cAlias)->(DbSeek( cKeySeek ))
   EndIf

   If (cAlias)->(!Eof())
      For i := 1 To Len(xCpos)
         aAdd( aRet, (cAlias)->&(xCpos[i])  )
      Next i
   EndIf

Return aRet


/*
Função     : PosValEIN
Objetivo   : Validação da linha EIN do grid de acréscimos e deduções
Parâmetros : oGridModel, nLine
Retorno    : Lógico
Obs.       :
Autor      : wfs
Data/Hora  : dez/2021
*/
Static Function PosValEIN(oGridModel, nLine)
   Local aExceptions:= {"EIN_CODIGO", "EIN_FOBMOE", "EIN_VLMLE", "EIN_VLMMN"}
Return ValidLine(oGridModel, nLine, aExceptions)

/*
Função     : PosValEIK
Objetivo   : Validação da linha EIK do grid de documentos vinculados
Parâmetros : oGridModel, nLine
Retorno    : Lógico
Obs.       :
Autor      : wfs
Data/Hora  : dez/2021
*/
Static Function PosValEIK(oGridModel, nLine)
   Local aExceptions:= {"EIK_TIPVIN", "EIK_DOCVIN"}
Return ValidLine(oGridModel, nLine, aExceptions)

/*
Função     : LP500CBOX
Objetivo   : Retorna a lista de opções conforme o tipo de processo
Parâmetros :
Retorno    : lista de opções
Obs.       :
Autor      : wfs
Data/Hora  : dez/2021
*/
Function LP500CBOX()
   Local cRet:= ""

   If (IIF (ISMEMVAR('M->W6_TIPOREG'),M->W6_TIPOREG # '2',SW6->W6_TIPOREG # '2'))
      cRet:= "2=Declaração de Importação;3=Registro de Importação"   
   Else
      cRet:= "1=DUIMP;2=DUE;3=DI;4=DE"
   EndIf

Return cRet

/*
Função     : ValidaItemDuimp
Objetivo   : Verifica se o item da duimp informado para o item existe em outro item do processo
Parâmetros :
Retorno    :
Obs.       :
Autor      : wfs
Data/Hora  : dez/2021
*/
Static Function ValidaItemDuimp(oModel, oModelSWV, cField, cNewValue, nLineSwv)
   Local nPosSubModel
   Local lFind:= .F.
   Local nSW9, nLineSW9
   Local aDataModel
   Local aData
   Local nData
   Local nField

   Begin Sequence

      nField:= oModelSWV:getIdField(cField)
      nLineSW9 := oModel:getModel("SW9DETAIL"):getline()
      For nSW9 := 1 To oModel:getModel("SW9DETAIL"):Length()

         aDataModel:= AClone(oModel:getModel("SW9DETAIL"):aDataModel[nSW9][MODEL_GRID_CHILDREN])

         nPosSubModel := AScan(aDataModel, {|x| x[MODEL_GRID_CHILDREN_ID] == "SWVDETAIL"})
         If nPosSubModel > 0
            aData := AClone(aDataModel[nPosSubModel][MODEL_GRID_CHILDREN_DATA])

            For nData:= 1 to Len(aData)
               If!(nSw9 == nLineSW9 .And. nLineSwv == nData) //Não pesquisa para o próprio registro que está sendo editado
                  lFind:= aData[nData][MODEL_GRID_DATA][MODEL_GRIDLINE_VALUE][nField] == cNewValue

                  If lFind
                     Break
                  EndIf
               EndIf   
            Next nData

         EndIf

      Next nSW9

   End Sequence

Return !lFind

/*
Função     : VerCampos
Objetivo   : Verifica se os campos exitem e estão configurados como usado
Parâmetros :
Retorno    :
Obs.       :
Autor      : bak
Data/Hora  : 03/2022
*/
static function VerCampos(cAlias, aCampos)
   local lRet       := .F.
   local nCpo       := 0
   local cAliasOld  := ""

   default cAlias    := ""
   default aCampos   := {}

   if !empty(cAlias) .and. valtype(aCampos) == "A" .and. len(aCampos) > 0
      cAliasOld := Alias()

      dbSelectArea(cAlias)
      begin sequence
      for nCpo := 1 to len(aCampos)
         if (cAlias)->(columnPos(aCampos[nCpo])) == 0 .or. !X3USO(GetSX3Cache(aCampos[nCpo], "X3_USADO"))
            break
         endif
      next

      lRet := .T.
      end sequence

      if ( !empty(cAliasOld), dbSelectArea(cAliasOld), nil)

   endif

return lRet

/*
Função     : VldEKQ
Objetivo   : Valida se o orgão anuente e o formulario já foram informados
Parâmetros :
Retorno    :
Obs.       :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 03/2022
*/
static function VldEKQ( oModelEKQ )
   local lRet       := .T.
   local aLinesEKQ  := {}
   local cOrgao     := ""
   local cFormul    := ""
   local nLinePos   := 0
   local nLine      := 0
   local nLenEKQ    := 0

   if !empty(oModelEKQ:GetValue("EKQ_ORGANU")) .and. !empty(oModelEKQ:GetValue("EKQ_FRMLPC"))

      aLinesEKQ := FWSaveRows()

      cOrgao := oModelEKQ:GetValue("EKQ_ORGANU")
      cFormul := oModelEKQ:GetValue("EKQ_FRMLPC")
      nLinePos := oModelEKQ:getLine()
      nLenEKQ := oModelEKQ:Length( .T. )

      for nLine := 1 to nLenEKQ
         if nLinePos <> nLine
            oModelEKQ:goline(nLine)
            if !oModelEKQ:IsDeleted() .and. oModelEKQ:GetValue("EKQ_ORGANU") == cOrgao .and. oModelEKQ:GetValue("EKQ_FRMLPC") == cFormul
               lRet := .F.
               EasyHelp(STR0097 , STR0003, STR0098 + " " + alltrim(str(nLine)) + ".") // "O orgão anuente e formulário já foram informados." ### "Atenção" ### "Verifique a linha"
               exit
            endif
         endif
      next

      FWRestRows(aLinesEKQ)
   endif

return lRet

/*
Função     : LP500LdTrb
Objetivo   : Carrega os itens na pasta Tributação
Parâmetros :
Retorno    :
Obs.       :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : 03/2022
*/
static function LP500LdTrb(oModelo, cType, lEdit, nAtuSWV, cAction, cCampo)
   local aDados     := {}
   local lNoInsLine := .F.
   local lNoUpdLine := .F.
   local lNoDelLine := .F.
   local oModel     := oModelo:getModel()
   local oStruct    := nil
   local aCposMod   := {}
   local oModSWV    := nil
   local aLines     := {}
   local oModSW9    := nil
   local nLenSW9    := 0
   local nLenSWV    := 0
   local nInvoices  := 0
   local nItens     := 0
   local nCampos    := {}
   local aCposLoads := {}
   local nLineSWV   := 0
   local aSeek      := {}
   local aPKeyWV    := {}
   local oModSWVTrb := nil
   local oModEIJ    := nil

   default cType   := ""
   default lEdit   := .F.
   default nAtuSWV := 0
   default cAction := ""
   default cCampo  := ""
            
   oStruct := oModelo:getStruct()
   aCposMod := oStruct:GetFields()

   do case

      case cType == "SWVDETAIL_TRIBUTACAO"

         if !oModelo:CanInsertLine()
            oModelo:SetNoInsertLine(.F.)
            lNoInsLine := .T.
         endif

         if !oModelo:CanUpdateLine()
            oModelo:SetNoUpdateLine(.F.)
            lNoUpdLine := .T.
         endif

         if !oModelo:CanDeleteLine()
            oModelo:SetNoDeleteLine(.F.)
            lNoDelLine := .T.
         endif

         if lEdit

            oModSWV := oModel:getModel("SWVDETAIL")
            aSeek := {  {"WV_FILIAL"  , xFilial("SWV")                  },;
                        {"WV_HAWB"    , oModSWV:GetValue("WV_HAWB")     },;
                        {"WV_INVOICE" , oModSWV:GetValue("WV_INVOICE")  },;
                        {"WV_FORN"    , oModSWV:GetValue("WV_FORN")     },;
                        {"WV_FORLOJ"  , oModSWV:GetValue("WV_FORLOJ")   },;
                        {"WV_PO_NUM"  , oModSWV:GetValue("WV_PO_NUM")   },;
                        {"WV_POSICAO" , oModSWV:GetValue("WV_POSICAO")  },;
                        {"WV_SEQUENC" , oModSWV:GetValue("WV_SEQUENC")  }}

            // posiciona no array do modelo SWVDETAIL_TRIBUTACAO
            if oModelo:SeekLine(aSeek, cAction == "UNDELETE", .T.)

               if cAction == "NEWLINE"

                  // atualiza a quantidade
                  oModelo:loadValue("WV_QTDE", oModSWV:GetValue("WV_QTDE") )

                  nLineSWV := oModSWV:getLine()

                  // Adicionar a linha quebrada
                  oModSWV:goline(nAtuSWV)

                  aCposLoads := {}
                  for nCampos := 1 to len(aCposMod)
                     aAdd( aCposLoads,  { aCposMod[nCampos][3], oModSWV:getValue(aCposMod[nCampos][3]) } )
                  next
                  AddLine(oModelo, aCposLoads, , .T., aCposMod)

                  // Orderna os registros dos itens da tributação
                  aPKeyWV := { aScan(oModelo:AHEADER,{|x| x[2] == "WV_INVOICE" }) ,;
                              aScan(oModelo:AHEADER,{|x| x[2] == "WV_PO_NUM"  }) ,;
                              aScan(oModelo:AHEADER,{|x| x[2] == "WV_POSICAO" }) ,;
                              aScan(oModelo:AHEADER,{|x| x[2] == "WV_SEQUENC" })  }

                  aSort(oModelo:aDATAMODEL,,, {|x,y| x[1][1][aPKeyWV[1]] + x[1][1][aPKeyWV[2]] + x[1][1][aPKeyWV[3]] + x[1][1][aPKeyWV[4]]  <  ;
                     y[1][1][aPKeyWV[1]] + y[1][1][aPKeyWV[2]] + y[1][1][aPKeyWV[3]] + y[1][1][aPKeyWV[4]]  } )

                  oModSWV:goline(nLineSWV)

               elseif cAction == "DELETE" .or. cAction == "UNDELETE"
                  if cAction == "DELETE"
                     oModelo:DeleteLine()
                  else
                     oModelo:UnDeleteLine()
                  endif

                  if nAtuSWV > 0
                     nLineSWV := oModSWV:getLine()
                     oModSWV:goline(nAtuSWV)
                     LP500LdTrb(oModelo, "SWVDETAIL_TRIBUTACAO", .T., nAtuSWV, "GATILHO" , "WV_QTDE")
                     oModSWV:goline(nLineSWV)
                  endif

               elseif cAction == "GATILHO" .and. !empty(cCampo)
                  oModelo:loadValue(cCampo, oModSWV:GetValue(cCampo) )

               endif

               oModelo:goline(1)

            endif

         else

            aLines := FWSaveRows()

            oModSW9 := oModel:getModel("SW9DETAIL")
            nLenSW9 := oModSW9:Length( .T. )

            for nInvoices := 1 to nLenSW9

               oModSW9:goline(nInvoices)

               oModSWV := oModel:getModel("SWVDETAIL")
               nLenSWV := oModSWV:Length( .T. )

               for nItens := 1 to nLenSWV

                  oModSWV:goline(nItens)
                  aCposLoads := {}
                  for nCampos := 1 to len(aCposMod)
                     aAdd( aCposLoads,  oModSWV:getValue(aCposMod[nCampos][3])  )
                  next
                  aAdd(aDados, {0, aClone(aCposLoads)})
                  aSize(aCposLoads,0)

               next nItens
            next nInvoices

            FWRestRows(aLines)

         endif

         oModelo:SetNoInsertLine(lNoInsLine)
         oModelo:SetNoUpdateLine(lNoUpdLine)
         oModelo:SetNoDeleteLine(lNoDelLine)

      case cType == "EIJMASTER_II" .or. cType == "EIJMASTER_IPI" .or. cType == "EIJMASTER_PISCOFINS" .or. cType == "EIJMASTER_ICMS" .or. cType == "EIJMASTER_OBSTRB"

         oModSW9 := oModel:getModel("SW9DETAIL")

         oModSWVTrb := oModel:getModel("SWVDETAIL_TRIBUTACAO")

         aLines := FWSaveRows()

         aSeek := {  {"W9_FILIAL"  , xFilial("SW9")                     },;
                     {"W9_HAWB"    , oModSWVTrb:GetValue("WV_HAWB")     },;
                     {"W9_INVOICE" , oModSWVTrb:GetValue("WV_INVOICE")  },;
                     {"W9_FORN"    , oModSWVTrb:GetValue("WV_FORN")     },;
                     {"W9_FORLOJ"  , oModSWVTrb:GetValue("WV_FORLOJ")   }}

         if oModSW9:SeekLine(aSeek, .F., .T.)

            aSeek := {  {"WV_FILIAL"  , xFilial("SWV")                     },;
                        {"WV_HAWB"    , oModSWVTrb:GetValue("WV_HAWB")     },;
                        {"WV_INVOICE" , oModSWVTrb:GetValue("WV_INVOICE")  },;
                        {"WV_FORN"    , oModSWVTrb:GetValue("WV_FORN")     },;
                        {"WV_FORLOJ"  , oModSWVTrb:GetValue("WV_FORLOJ")   },;
                        {"WV_PO_NUM"  , oModSWVTrb:GetValue("WV_PO_NUM")   },;
                        {"WV_POSICAO" , oModSWVTrb:GetValue("WV_POSICAO")  },;
                        {"WV_SEQUENC" , oModSWVTrb:GetValue("WV_SEQUENC")  }}

            oModSWV := oModel:getModel("SWVDETAIL")
            if oModSWV:SeekLine(aSeek, .F., .T.)

               oModEIJ := oModel:getModel("EIJMASTER")

               if lEdit
                  if cAction == "GATILHO" .and. !empty(cCampo)
                     oModEIJ:loadValue(cCampo, oModelo:GetValue(cCampo) )
                  endif

               else
                  aCposLoads := {}
                  for nCampos := 1 to len(aCposMod)
                     aAdd( aCposLoads,  oModEIJ:getValue(aCposMod[nCampos][3])  )
                  next
                  aDados := aClone(aCposLoads)
                  aSize(aCposLoads,0)

               endif

            endif

         endif

         FWRestRows(aLines)

   end case

return aDados

/*
Função     : AddLine
Objetivo   : Adiciona uma linha no grid
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Março/2022
Obs.       :
*/
static function AddLine(oModelDet, aLoadCpos, aNoLoadCpos, lAddLine, aCposGrd)
   local nLine     := 0
   local nCpo      := 0
   local nPos      := 0
   local oStrGrd   := nil

   default aLoadCpos   := {}
   default aNoLoadCpos := {}
   default lAddLine    := .F.
   default aCposGrd    := {}

   nLine := oModelDet:GetLine()
   if lAddLine
      nLine := oModelDet:AddLine()
   endif

   if len(aCposGrd) == 0
      oStrGrd  := oModelDet:getStruct()
      aCposGrd := oStrGrd:GetFields()
   endif

   for nCpo := 1 to Len(aCposGrd)
      if ( nPos := aScan(aLoadCpos,{|x|x[1] == aCposGrd[nCpo][3] }) ) > 0 .And. aScan(aNoLoadCpos,aCposGrd[nCpo][3]) == 0
         oModelDet:LoadValue( aLoadCpos[nPos][1], aLoadCpos[nPos][2] )
      else
         oModelDet:LoadValue( aCposGrd[nCpo][3] , CriaVar(aCposGrd[nCpo][3]) )
      endif
   next

return nLine

/*
Função     : getForceAtu
Objetivo   : Retorna a variavel de controle para atualização de dados
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function getForceAtu()
return _lForceAtu

/*
Função     : LP500Atu
Objetivo   : Atribui a variavel de controle para atualização de dados
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
function LP500Atu(lForce)
   default lForce := .F.
   _lForceAtu := lForce
return

/*
Função     : EIJLoad
Objetivo   : Carrega a informação para os campos da tabela EIJ
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       :
*/
static function EIJLoad(cCampo, oModelEIJ, oModelSWV, oModelSW9, lAltDesc, cProcDesc, lSeek)
   local xSetValue
   local aDadosSW8  := {}
   local cUnid_Ncm  := ""
   local cCnpjRaiz  := ""

   default lAltDesc   := GetNewpar("MV_DESCDI",.T.)
   default cProcDesc  := alltrim(getSX3Cache("EIJ_DSCCIT","X3_VISUAL"))
   default lSeek      := .F.

   do case
      case cCampo == "EIJ_FILIAL"
         xSetValue := xFilial("EIJ")

      case cCampo == "EIJ_HAWB"
         xSetValue := oModelSWV:GetValue("WV_HAWB")

      case cCampo == "EIJ_IDWV"
         xSetValue := oModelSWV:GetValue("WV_ID")

      case cCampo == "EIJ_QT_EST"
         aDadosSW8 := GetInfW7W8(oModelSWV,"W8_UNID")
         xSetValue := 0
         if Len(aDadosSW8) > 0 .and. !empty(oModelSWV:getValue("WV_NCM"))
            cUnid_Ncm := AvKey( LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM"), "YD_UNID") , "EIJ_UNDEST")
            xSetValue := AVTransUnid( aDadosSW8[1], cUnid_Ncm, oModelSWV:GETVALUE("WV_COD_I"), oModelSWV:GETVALUE("WV_QTDE") )
         endif

      case cCampo == "EIJ_PESOL"
         aDadosSW8 := GetInfW7W8(oModelSWV,"W7_PESO")
         xSetValue := 0
         if Len(aDadosSW8) > 0
            xSetValue := DI500TRANS( aDadosSW8[1] * oModelSWV:GETVALUE("WV_QTDE") , AvSX3("EIJ_PESOL",AV_DECIMAL) )
         endif

      case cCampo == "EIJ_MOEDA"
         xSetValue := oModelSW9:GetValue("W9_MOE_FOB")

      case cCampo = "EIJ_VLMLE"
         aDadosSW8 := GetInfW7W8(oModelSWV,"W8_PRECO")
         xSetValue := 0
         If Len(aDadosSW8) > 0
            xSetValue := aDadosSW8[1]
         EndIf

      case cCampo == "EIJ_FABFOR"
         aDadosSW8 := GetInfW7W8(oModelSWV,{"W8_FABR","W8_FABLOJ","W8_FORN","W8_FORLOJ"})
         xSetValue := ""
         If Len(aDadosSW8) > 0
            If aDadosSW8[1]+aDadosSW8[2] == aDadosSW8[3]+aDadosSW8[4]
               xSetValue := '1'
            Else
               xSetValue := '2'
            EndIf
         EndIf

      case cCampo == "EIJ_FABR"
         aDadosSW8 := GetInfW7W8(oModelSWV,"W8_FABR")
         xSetValue := ""
         If Len(aDadosSW8) > 0
            xSetValue := aDadosSW8[1]
         EndIf

      case cCampo == "EIJ_FABLOJ"
         aDadosSW8 := GetInfW7W8(oModelSWV,{"W8_FABR","W8_FABLOJ"})
         xSetValue := ""
         If Len(aDadosSW8) > 0
            xSetValue := aDadosSW8[2]
         EndIf

      case cCampo == "EIJ_TINFA"
         aDadosSW8 := GetInfW7W8(oModelSWV,{"W8_FABR","W8_FABLOJ"})
         xSetValue := ""
         If Len(aDadosSW8) > 0
            cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" ) , 8 )
            EKJ->(DbSetOrder(1))
            If EKJ->(DbSeek( xFilial("EKJ") + cCnpjRaiz + aDadosSW8[1] + aDadosSW8[2]  ))
               xSetValue := EKJ->EKJ_TIN
            EndIf
         EndIf

      case cCampo == "EIJ_PAISOR"
         aDadosSW8 := GetInfW7W8(oModelSWV,{"W8_FABR","W8_FABLOJ"})
         xSetValue := ""
         If Len(aDadosSW8) > 0
            xSetValue := LP500GetInfo("SA2", 1, xFilial("SA2")+aDadosSW8[1]+aDadosSW8[2], "A2_PAIS" )
         EndIf

      case cCampo == "EIJ_FORN"
         xSetValue := ""
         aDadosSW8 := GetInfW7W8(oModelSWV,"W8_FORN")
         If Len(aDadosSW8) > 0
            xSetValue := aDadosSW8[1]
         EndIf

      case cCampo == "EIJ_FORLOJ"
         xSetValue := ""
         aDadosSW8 := GetInfW7W8(oModelSWV,{ "W8_FORN", "W8_FORLOJ"})
         If Len(aDadosSW8) > 0
            xSetValue := aDadosSW8[2]
         EndIf

      case cCampo == "EIJ_TINFO"
         xSetValue := ''
         aDadosSW8 := GetInfW7W8(oModelSWV,{"W8_FORN","W8_FORLOJ"})
         If Len(aDadosSW8) > 0
            cCnpjRaiz := Left( LP500GetInfo("SYT", 1, xFilial("SYT")+AvKey(SW6->W6_IMPORT,"YT_COD_IMP"), "YT_CGC" ) , 8 )
            EKJ->(DbSetOrder(1))
            If EKJ->(DbSeek( xFilial("EKJ") + cCnpjRaiz + aDadosSW8[1] + aDadosSW8[2]    ))
               xSetValue := EKJ->EKJ_TIN
            EndIf
         EndIf

      case cCampo == "EIJ_PAISPR"
         aDadosSW8 := GetInfW7W8(oModelSWV,{"W8_FORN","W8_FORLOJ"})
         xSetValue := ""
         If Len(aDadosSW8) > 0
            xSetValue := LP500GetInfo("SA2", 1, xFilial("SA2")+aDadosSW8[1]+aDadosSW8[2], "A2_PAIS" )
         EndIf

      case cCampo == "EIJ_INCOTE"
         xSetValue := oModelSW9:GetValue("W9_INCOTER")

      case cCampo == "EIJ_TIPCOB"
         xSetValue := LP500GetInfo("SY6",1,xFilial("SY6")+oModelSW9:GetValue("W9_COND_PA"),"Y6_TIPOCOB")

      case cCampo == "EIJ_MODALI"
         xSetValue := LP500GetInfo("SY6",1,xFilial("SY6")+oModelSW9:GetValue("W9_COND_PA"),"Y6_TABELA")

      case cCampo == "EIJ_MOTIVO"
         xSetValue := LP500GetInfo("SY6",1,xFilial("SY6")+oModelSW9:GetValue("W9_COND_PA"),"Y6_MOTIVO")

      case cCampo == "EIJ_VL_FIN"
         If LP500GetInfo("SY6",1,xFilial("SY6")+oModelSW9:GetValue("W9_COND_PA"),"Y6_TIPOCOB") == '4'
            xSetValue := 0
         Else
            aDadosSW8 := GetInfW7W8(oModelSWV,"W8_PRECO")
            xSetValue:= 0
            If Len(aDadosSW8) > 0
               xSetValue:= aDadosSW8[1]
            EndIf
            xSetValue := DI500Trans(oModelSWV:GetValue("WV_QTDE") * xSetValue )
         EndIf

      case cCampo == "EIJ_DSCCIT"
         xSetValue := ""
         if !lSeek .or. (lAltDesc .and. cProcDesc == "V") 
            aDadosSW8 := GetInfW7W8(oModelSWV,{"W8_DESC_DI","W8_COD_I"})
            If Len(aDadosSW8) > 0
               If !EMPTY(aDadosSW8[1])
                  xSetValue := MSMM(aDadosSW8[1],AvSx3("W8_DESC_VM",3))
               EndIf
            EndIf
         endif

      case cCampo == "EIJ_TPAII"
         xSetValue := "1" // 1-Ad Valorem

      case cCampo == "EIJ_ALI_II"
         xSetValue := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM"), "YD_PER_II" )

      case cCampo == "EIJ_TPAIPI"
         xSetValue := "1" //1-Ad Valorem por padrão

      case cCampo == "EIJ_ALAIPI"
         xSetValue := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM"), "YD_PER_IPI")

      case cCampo == "EIJ_TPAPIS"
         xSetValue := "1" //1-Ad Valorem por padrão

      case cCampo == "EIJ_ALAPIS"
         xSetValue := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM"), "YD_PER_PIS")

      case cCampo == "EIJ_TPACOF"
         xSetValue := "1" //1-Ad Valorem por padrão"

      case cCampo == "EIJ_ALACOF"
         xSetValue := LP500GetInfo("SYD", 1, xFilial("SYD") + oModelSWV:getValue("WV_NCM"), "YD_PER_COF")

      otherwise
         xSetValue := CRIAVAR(cCampo)

   end case

return xSetValue

/*
Função     : LP500GetInfo
Objetivo   : Função para retornar o valor de um determinado campo
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Maio/2022
Obs.       : Cuidado ao chamar essa função dentro de um dbseek, devido a alias ficar selecionada do parametro cAliasTb
*/
function LP500GetInfo(cAliasTb, nIndice, cKeySeek, cCampo)
   local xRet       := nil

   default cAliasTb := ""
   default nIndice  := 0
   default cKeySeek := ""
   default cCampo   := ""

   if !empty(cAliasTb) .and. nIndice > 0 .and. !empty(cKeySeek) .and. !empty(cCampo)

      dbSelectArea(cAliasTb)
      if !( cKeySeek == (cAliasTb)->&(IndexKey()) )
         (cAliasTb)->(dbSetOrder( nIndice ))
         (cAliasTb)->(dbSeek( cKeySeek ))
      endif

      if (cAliasTb)->(!eof())
         xRet := (cAliasTb)->&(cCampo)
      endif

   endif

return xRet

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
Função     : GetFabFor
Objetivo   : Retorna dados do Fabricante/Fornecedor (EKJ) relacionado ao Catálogo de Produto
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Agosto/2022
Obs.       : 
*/
static function GetFabFor(cInfo, cTipo, cIDPTCP, cVRSACP, oMdl, cCodCat)
   local cRet      := ""
   local cCnpjRaiz := ""
   local lSeek     := .F.

   default cInfo   := ""
   default cTipo   := ""
   default cIDPTCP := ""
   default cVRSACP := ""
   default cCodCat := EKD->EKD_COD_I

   do case
      case cInfo == "VERSAO"
         if !empty(cIDPTCP) .and. !empty(cVRSACP)
            EKF->(dbSetOrder(1))
            cCnpjRaiz := Left( oMdl:GetModel():GetValue("EIJMASTER","EIJ_CNPJRZ" ), 8 )

            if cTipo == "FOR"
               cCod := oMdl:GetModel():GetValue("EIJMASTER","EIJ_FORN") 
               cLoja := oMdl:GetModel():GetValue("EIJMASTER","EIJ_FORLOJ") 
            elseif cTipo == "FAB"
               cCod := oMdl:GetModel():GetValue("EIJMASTER","EIJ_FABR") 
               cLoja := oMdl:GetModel():GetValue("EIJMASTER","EIJ_FABLOJ") 
            endif

            if EKF->(dbSeek( xFilial("EKF") + cCodCat + cVRSACP + cCod + cLoja ))
               EKJ->(dbSetOrder(1))
               lSeek := EKJ->(dbSeek( xFilial("EKJ") + cCnpjRaiz + cCod + cLoja ))
            endif

            if lSeek 
               cRet := EKJ->EKJ_VERSAO
            endif

         endif

   end case

return cRet

/*
Função     : LP500ClrSq
Objetivo   : Função para executar DelSeqDuimp
Parâmetro  :
Retorno    :
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Setembro/2022
Obs.       : 
*/
function LP500ClrSq( lPergunte )
return DelSeqDuimp( lPergunte )

/*
Função     : LP500SeqD
Objetivo   : Função para verificar se já existe sequencia da DUIMP informada
Retorno    : Nenhum
Autor      : Bruno Akyo Kubagawa
Data/Hora  : Setembro/2021
*/
function LP500SeqD(oMdl, oModelSW9, oMdlSWV)
   local lRet       := .F.
   local aSaveLines := {}
   local nSW9       := 0
   local nSWV       := 0

   default oMdl       := FWModelActive()
   default oModelSW9  := oMdl:GetModel("SW9DETAIL")
   default oMdlSWV    := oMdl:GetModel("SWVDETAIL")

   aSaveLines := FWSaveRows()

   begin sequence

   for nSW9 := 1 To oModelSW9:Length()
      oModelSW9:GoLine(nSW9)
      for nSWV := 1 To 10
         if oMdlSWV:SeekLine({{"WV_SEQDUIM",strzero(nSWV-1,1)}}, .F., .F. )
            lRet := .T.
            break
         endif
      next nSWV
   next nSW9

   end sequence

   FWRestRows(aSaveLines)

return lRet
