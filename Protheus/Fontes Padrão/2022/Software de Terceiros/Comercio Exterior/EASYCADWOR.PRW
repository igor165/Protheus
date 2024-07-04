#INCLUDE "Average.ch"
#Include "EASYCADWORKFLOW.CH"
/*
Funcao      : EASYCADWORKFLOW
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Cadastro de WorkFlows
Autor       : Thiago Rinaldi Pinto - TRP
Data/Hora   : 03/03/2011 15:10
Revisao     :
Obs.        :
*/
*-------------------------*
Function EASYCADWOR()
*-------------------------* 
PRIVATE aRotina := MenuDef("EASYCADWOR")
Return EASY2CADWORKFLOW()

*-------------------------*
Function EASY2CADWORKFLOW()
*-------------------------*  
Local lRet := .T.
   
DBSelectArea("EJ7")
   
Private oUpdAtu
Private cCadastro := AVTITCAD("EJ7")
// BAK - Tratamento para carga padrão da tabela WF2 e EJ7 19/08/2011
If FindFunction("AvUpdate01")
   oUpdAtu := AvUpdate01():New()
EndIf

If ValType(oUpdAtu) == "O" .AND. &("MethIsMemberOf(oUpdAtu,'TABLEDATA')") .AND. Type("oUpdAtu:lSimula") == "L"
   If ChkFile("WF2") .And. ChkFile("EJ7")
      oUpdAtu:aChamados := {{nModulo,{|o| EDadosEJ7(o)}}}
      oUpdAtu:Init(,.T.)
   EndIf
EndIf

//GFP - 13/08/2012 - Filtro para MBrowse - Importação/Exportação
If nModulo == 17
   EJ7->(DBSetFilter( {|| EJ7->EJ7_MODULO == 'EIC'}, "EJ7->EJ7_MODULO == 'EIC'"))
Elseif nModulo == 29
   EJ7->(DBSetFilter( {|| EJ7->EJ7_MODULO == 'EEC'}, "EJ7->EJ7_MODULO == 'EEC'"))
Endif

mBrowse(6,1,40,90,"EJ7")

Return lRet

Static Function EDadosEJ7(o)

o:TableStruct("EJ7",{'EJ7_FILIAL'   , 'EJ7_COD' , 'EJ7_DESC'                               , 'EJ7_ATIVO' , 'EJ7_HTML'                , 'EJ7_HTMLI'    , 'EJ7_HTMAN'     , 'EJ7_VMDEST' , 'EJ7_COPIA' , 'EJ7_COPOC' , 'EJ7_ASSUNT'                                    , 'EJ7_TIMEOU' , 'EJ7_TIMEHR' , 'EJ7_TIMEMI' , 'EJ7_FUNCEN' , 'EJ7_FUNCRE' , 'EJ7_TIPO'   , 'EJ7_FUNCVA' , 'EJ7_TIPORE' , 'EJ7_TIPSRV' , 'EJ7_SERVID', 'EJ7_CHAVES'                                      , 'EJ7_MODULO' , 'EJ7_FASE'         },  1 )
o:TableData("EJ7"  ,{xFilial("EJ7") , 'SI'      , 'SOLICITAÃ+O DE IMPORTAÃ+O'              , '2'         , "EasyExecWF('EASYWFSI')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - SolicitaþÒo de ImportaþÒo'          , ''           , ''           , ''           , 'EICWFSIENV' , ''           , '1'          , 'EICWFSIVAR' , '1'          , '1'          , ''          , 'If(Inclui,xFilial("SW0")+M->(W0__CC+W0__NUM),)'  , 'EIC'        , 'SOLIC IMPORT'     },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'PO'      , 'ITENS ANUENTES DO PURCHASE ORDER'       , '2'         , "EasyExecWF('EASYWFPO')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Purchase Order'                     , ''           , ''           , ''           , 'EICWFPOENV' , ''           , '1'          , 'EICWFPOVAR' , '1'          , '1'          , ''          , 'EICWFPOCOND()'                                   , 'EIC'        , 'PURCHASE ORDER'   },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'PU'      , 'PREVISAO DE EMBARQUE DO PURCHASE ORDER' , '2'         , "EasyExecWF('EASYWFPU')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Purchase Order'                     , ''           , ''           , ''           , 'EICWFPUENV' , ''           , '1'          , 'EICWFPUVAR' , '1'          , '1'          , ''          , 'EICWFPUCOND()'                                   , 'EIC'        , 'PURCHASE ORDER'   },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'PLI'     , 'PREPARAÃ+O DE LICENÃA DE IMPORTAÃ+O'    , '2'         , "EasyExecWF('EASYWFPLI')" , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - PreparaþÒo de Licenþa de ImportaþÒo', ''           , ''           , ''           , 'EICWFLIENV' , ''           , '1'          , 'EICWFLIVAR' , '1'          , '1'          , ''          , 'If(Inclui,xFilial("SW4")+M->W4_PGI_NUM,)'        , 'EIC'        , 'LICENCA IMPORT'   },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'EMB'     , 'EMBARQUE'                               , '2'         , "EasyExecWF('EASYWFEMB')" , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Embarque'                           , ''           , ''           , ''           , 'EICWFEBENV' , ''           , '1'          , 'EICWFEBVAR' , '1'          , '1'          , ''          , 'EICWFEBCOND()'                                   , 'EIC'        , 'EMBARQUE_EIC'     },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'DES'     , 'ENCERRAMENTO'                           , '2'         , "EasyExecWF('EASYWFDES')" , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Processo encerrado'                 , ''           , ''           , ''           , 'EICWFDSENV' , ''           , '1'          , 'EICWFDSVAR' , '1'          , '1'          , ''          , 'EICWFDSCOND()'                                   , 'EIC'        , 'EMBARQUE_EIC'     },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'PRV'     , 'PREVISAO DE ENTREGA'                    , '2'         , "EasyExecWF('EASYWFPRV')" , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - PrevisÒo de Entrega'                , ''           , ''           , ''           , 'EICWFPVENV' , ''           , '1'          , 'EICWFPVVAR' , '1'          , '1'          , ''          , 'EICWFPVCOND()'                                   , 'EIC'        , 'EMBARQUE_SCH'     },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'NF'      , 'NOTA FISCAL'                            , '2'         , "EasyExecWF('EASYWFNF')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Nota Fiscal'                        , ''           , ''           , ''           , 'EICWFNFENV' , ''           , '1'          , 'EICWFNFVAR' , '1'          , '1'          , ''          , 'xFilial("SW6")+SW6->W6_HAWB'                     , 'EIC'        , 'NOTA FISCAL'      },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'NM'      , 'ADIANTAMENTO NUMERARIO'                 , '2'         , "EasyExecWF('EASYWFNM')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Numerario'                          , ''           , ''           , ''           , 'EICWFNMENV' , ''           , '1'          , 'EICWFNMVAR' , '1'          , '1'          , ''          , 'EICWFNM2COND(1)'                                 , 'EIC'        , 'NUMERARIO_EIC'    },,.F.) // GFP - 14/08/2012
o:TableData("EJ7"  ,{xFilial("EJ7") , 'CB'      , 'CAMBIO'                                 , '2'         , "EasyExecWF('EASYWFCB')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - CÔmbio'                             , ''           , ''           , ''           , 'EICWFCBENV' , ''           , '1'          , 'EICWFCBVAR' , '1'          , '1'          , ''          , 'EICWFCBCOND()'                                   , 'EIC'        , 'CAMBIO_SCH_EIC'   },,.F.) // GFP - 26/09/2012
o:TableData("EJ7"  ,{xFilial("EJ7") , 'LQ'      , 'LIQUIDACAO DE CAMBIO'                   , '2'         , "EasyExecWF('EASYWFLQ')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - LiquidaþÒo de Parcela de CÔmbio'    , ''           , ''           , ''           , 'EICWFLQENV' , ''           , '1'          , 'EICWFLQVAR' , '1'          , '1'          , ''          , 'EICWFLQCOND()'                                   , 'EIC'        , 'CAMBIO_EIC'       },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'PEDIDO'  , 'APROVACAO DE CREDITO'                   , '2'         , "EasyExecWF('EASYWFPE')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - AprovaþÒo de CrÚdito'               , ''           , ''           , ''           , 'EECWFPEENV' , 'EECWFPERET' , '1'          , 'EECWFPEVAR' , '1'          , '1'          , ''          , 'EECWFPECOND()'                                   , 'EEC'        , 'PEDIDO EXPORT'    },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'PRECO'   , 'APROVACAO DE PRECO'                     , '2'         , "EasyExecWF('EASYWFAP')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - AprovaþÒo de Preþo'                 , ''           , ''           , ''           , 'EECWFAPENV' , 'EECWFAPRET' , '1'          , 'EECWFAPVAR' , '1'          , '1'          , ''          , 'EECWFAPCOND()'                                   , 'EEC'        , 'APROV PRECO'      },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'CR'      , 'LIBERACAO DE CREDITO'                   , '2'         , "EasyExecWF('EASYWFCR')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - LiberaþÒo de CrÚdito'               , ''           , ''           , ''           , 'EECWFCRENV' , ''           , '1'          , 'EECWFCRVAR' , '1'          , '1'          , ''          , 'EECWFCRCOND()'                                   , 'EEC'        , 'PEDIDO EXPORT'    },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'LC'      , 'CARTA DE CREDITO'                       , '2'         , "EasyExecWF('EASYWFLC')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Carta de CrÚdito'                   , ''           , ''           , ''           , 'EECWFLCENV' , ''           , '1'          , 'EECWFLCVAR' , '1'          , '1'          , ''          , 'EECWFLCCOND()'                                   , 'EEC'        , 'EMBARQUE_EEC'     },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'EX'      , 'PEDIDO DE EXPORTAÇÃO'                   , '2'         , "EasyExecWF('EASYWFEX')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Pedido de ExportaþÒo'               , ''           , ''           , ''           , 'EECWFEXENV' , ''           , '1'          , 'EECWFEXVAR' , '1'          , '1'          , ''          , 'If(Inclui,xFilial("EE7")+M->EE7_PEDIDO,)'        , 'EEC'        , 'PEDIDO EXPORT'    },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'EM'      , 'EMBARQUE'                               , '2'         , "EasyExecWF('EASYWFEC')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Embarque'                           , ''           , ''           , ''           , 'EECWFEMENV' , ''           , '1'          , 'EECWFEMVAR' , '1'          , '1'          , ''          , 'If(Inclui,xFilial("EEC")+M->EEC_PREEMB,)'        , 'EEC'        , 'EMBARQUE_EEC'     },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'LB'      , 'LIBERACAO PARA SISCOMEX'                , '2'         , "EasyExecWF('EASYWFLB')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Liberacao para Siscomex'            , ''           , ''           , ''           , 'EECWFLBENV' , ''           , '1'          , 'EECWFLBVAR' , '1'          , '1'          , ''          , 'EECWFLBCOND()'                                   , 'EEC'        , 'EMBARQUE_EEC'     },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'NR'      , 'ADIANTAMENTO NUMERARIO'                 , '2'         , "EasyExecWF('EASYWFNR')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Numerario'                          , ''           , ''           , ''           , 'EECWFNRENV' , ''           , '1'          , 'EECWFNRVAR' , '1'          , '1'          , ''          , 'xFilial("EEU")+M->EEU_PREEMB'                    , 'EEC'        , 'NUMERARIO_EEC'    },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'CA'      , 'CAMBIO'                                 , '2'         , "EasyExecWF('EASYWFCA')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Atraso em Parcela de CÔmbio'        , ''           , ''           , ''           , 'EECWFCAENV' , ''           , '1'          , 'EECWFCAVAR' , '1'          , '1'          , ''          , 'EECWFCACOND()'                                   , 'EEC'        , 'CAMBIO_SCH_EEC'   },,.F.) // GFP - 26/09/2012
o:TableData("EJ7"  ,{xFilial("EJ7") , 'LI'      , 'LIQUIDACAO DE CAMBIO'                   , '2'         , "EasyExecWF('EASYWFLD')"  , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - LiquidaþÒo de CÔmbio'               , ''           , ''           , ''           , 'EECWFLIENV' , ''           , '1'          , 'EECWFLIVAR' , '1'          , '1'          , ''          , 'EECWFLICOND()'                                   , 'EEC'        , 'CAMBIO_EEC'       },,.F.)
o:TableData("EJ7"  ,{xFilial("EJ7") , 'NM2'     , 'APROVACAO DE NUMERARIO'                 , '2'         , "EasyExecWF('EASYWFN2M')" , 'H_EASYWFLINK' , 'H_EASYWFANEXO' , ''           , ''          , ''          , 'WorkFlow - Aprovacao de Numerario'             , ''           , ''           , ''           , 'EICWFNM2ENV', 'EICWFNM2RET', '1'          , 'EICWFNM2VAR', '1'          , '1'          , ''          , 'EICWFNM2COND(2)'                                 , 'EIC'        , 'NUMERARIO_EIC'    },,.F.) // GFP - 18/01/2016	

o:TableStruct("WF2",{'WF2_FILIAL'   , 'WF2_PROC'  , 'WF2_STATUS'  , 'WF2_DESCR'        },1)  
o:TableData("WF2"  ,{xFilial("WF2") , 'SI'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'SI'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'SI'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PO'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PO'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PO'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PU'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PU'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PU'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PLI'       , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PLI'       , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PLI'       , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'EMB'       , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'EMB'       , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'EMB'       , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'DES'       , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'DES'       , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'DES'       , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PRV'       , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PRV'       , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PRV'       , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'NF'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'NF'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'NF'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'NM'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'NM'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'NM'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'CB'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'CB'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'CB'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'LQ'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'LQ'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'LQ'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'CR'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'CR'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'CR'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'LC'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'LC'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'LC'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'EM'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'EM'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'EM'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'EX'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'EX'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'EX'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'LB'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'LB'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'LB'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'NR'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'NR'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'NR'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PRECO'     , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PRECO'     , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PRECO'     , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'CA'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'CA'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'CA'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'LD'        , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'LD'        , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'LD'        , '10003'       , 'TIME OUT'         },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PEDIDO'    , '10001'       , 'EMAIL ENVIADO'    },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PEDIDO'    , '10002'       , 'EMAIL RESPONDIDO' },,.F.)
o:TableData("WF2"  ,{xFilial("WF2") , 'PEDIDO'    , '10003'       , 'TIME OUT'         },,.F.)

Return nil

*---------------------------------------*
Function DetCadWF(cAlias,nReg,nOpc)
*---------------------------------------*   
LOCAL lRet := .T.
LOCAL bCancel := {|| oDlg:End()}
LOCAL lOk := .F.
Local bOk := {|| If(ValidaEJ7b(),(lOk := .T., oDlg:End()),)}
Local nInc
PRIVATE aTela[0][0],aGets[0]

   BEGIN SEQUENCE
      If nOpc == 3
         For nInc := 1 To EJ7->(FCount())
            M->&(EJ7->(FieldName(nInc))) := CriaVar(EJ7->(FieldName(nInc)))
         Next
      Elseif nOpc == 2 .Or. nOpc == 4 .Or. nOpc == 5
         For nInc := 1 To EJ7->(FCount())
            M->&(EJ7->(FieldName(nInc))) := EJ7->(FieldGet(nInc))
         Next
      Endif
      
      DEFINE MSDIALOG oDlg TITLE STR0001 FROM DLG_LIN_INI, DLG_COL_INI ;
      													TO DLG_LIN_FIM, DLG_COL_FIM OF oMainWnd PIXEL  //"Cadastro de WorkFlow"
      aPos := PosDlg(oDlg)
      oMsmget := Msmget():New(cAlias, nReg, nOpc,,,,, aPos,)
      oMsmget:oBox:Align := CONTROL_ALIGN_ALLCLIENT
      
      ACTIVATE MSDIALOG oDlg ON INIT EnChoiceBar(oDlg, bOK, bCancel)
      
    
      If lOk .And. (nOpc == 3 .Or. nOpc == 4 .Or. nOpc == 5)
      
         IF nOpc == INCLUIR
            RecLock("EJ7", .T.)   
            AvReplace("M", "EJ7") 
            EJ7->(MsUnlock())       
         ELSEIF nOpc == ALTERAR
            RecLock("EJ7", .F.)
            AvReplace("M", "EJ7")
            EJ7->(MsUnlock())
         ELSE
            RecLock("EJ7", .F.)
            EJ7->(dbDelete())
            EJ7->(MsUnlock())
         ENDIF
      
      Endif
   END SEQUENCE

Return lRet 

/*
Funcao      : ValidaEJ7b
Parametros  : Nil
Retorno     : Nenhum
Objetivos   : Validacões do WorkFlow
Autor       : Thiago Rinaldi Pinto - TRP
Data/Hora   : 10/03/2011 10:50
Revisao     :
Obs.        :
*/
*--------------------*
Function ValidaEJ7b()
*--------------------*
Local lRet:= .T.

If M->EJ7_TIPSRV == "2"
   
   If M->EJ7_TIPO == "1" .OR. M->EJ7_TIPO == "2"
      MsgInfo(STR0003,STR0002)  //"Tipo de envio de WorkFlow não pode ser selecionado uma vez que não se está utilizando um servidor Web Protheus!" ## "Atenção"
      lRet:= .F.
   Endif
     
   If M->EJ7_TIPORE == "2"
      MsgInfo(STR0004,STR0002)  //"Tipo de retorno de WorkFlow não pode ser selecionado uma vez que não se está utilizando um servidor Web Protheus!" ## "Atenção"
      lRet:= .F.
   Endif

Endif
   
Return lRet

/*
Funcao     : MenuDef()
Parametros : Nenhum
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Thiago Rinaldi Pinto - TRP
Data       : 10/03/2011 13:00
*/
Static Function MenuDef(cOrigem, lMBrowse)

Local aRotina :=  {}
Default cOrigem  := AvMnuFnc()
Default lMBrowse := OrigChamada()

Do Case
   Case cOrigem == "EASYCADWOR"   
   
      aAdd(aRotina, {STR0005 , "AxPesqui", 0, 1})   //"Pesquisar"
      aAdd(aRotina, {STR0006 , "DetCadWF", 0, 2})   //"Visualizar"
      aAdd(aRotina, {STR0007 , "DetCadWF", 0, 3})   //"Incluir"
      aAdd(aRotina, {STR0008 , "DetCadWF", 0, 4})   //"Alterar"
      aAdd(aRotina, {STR0009 , "DetCadWF", 0, 5})   //"Excluir"
             	  	
   EndCase

   // P.E. utilizado para adicionar itens no Menu da mBrowse
   If EasyEntryPoint("EASYCADWORMNU")
      aRotAdic := ExecBlock("EASYCADWORMNU",.f.,.f.)
	  If ValType(aRotAdic) == "A"
	     AEval(aRotAdic,{|x| AAdd(aRotina,x)})
	  EndIf
   EndIf
   
Return aRotina