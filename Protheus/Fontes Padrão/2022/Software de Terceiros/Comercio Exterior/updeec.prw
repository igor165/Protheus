#Include 'Protheus.ch'
#Include "Average.ch"
#Include "TOPCONN.CH"

/*
Funcao                     : UPDEEC007
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			   : Lucas Raminelli LRS
Data/Hora   			   : 13/10/2015
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEEC007(o)
Local aOrd := SaveOrd("SX3") , aOrdSXB := {}

o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_VALID"                                                              },2)
o:TableData('SX3'  ,{'EE9_UNPRC' ,StrTran(Upper(SX3->X3_VALID), "AP104GATPRECO()", "Ap104GatPreco(,.F.)") })

//LRS - 20/10/2015 - alteração no campo SC6
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_USADO"},2)
o:TableData('SX3'  ,{'C6_OPC'    ,TODOS_MODULOS})

AjustaEEQ(o)  // GFP - 16/10/2015

//MCF - 02/09/2015 - Correção teste sistemico
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"       ,"XB_DESCSPA"      ,"XB_DESCENG"   ,"XB_CONTEM"              ,"XB_WCONTEM"})
o:TableData("SXB"  ,{ "EEA"    , "1"     ,"01"    ,"DB"       ,"Atividades"      ,"Actividades"     ,"Activities"   ,'EEA'                    ,            })
o:TableData("SXB"  ,{ "EEA"    , "2"     ,"01"    ,"01"       ,"Codigo Atividade","Codigo Actividad","Activity Code",""                       ,            })
o:TableData("SXB"  ,{ "EEA"    , "4"     ,"01"    ,"01"       ,"Codigo"          ,"Codigo"          ,"Code"         ,"EEA->EEA_COD"           ,            })
o:TableData("SXB"  ,{ "EEA"    , "4"     ,"01"    ,"02"       ,"Titulo"          ,"Titulo"          ,"Title"        ,"EEA->EEA_TITULO"        ,            })
o:TableData("SXB"  ,{ "EEA"    , "5"     ,"01"    ,""         ,""                ,""                ,""             ,"EEA->EEA_COD"           ,            })
o:TableData("SXB"  ,{ "EEA"    , "6"     ,"01"    ,""         ,""                ,""                ,""             ,"#AP100FilEEA(cOcorre)"  ,            })

o:TableStruct('SX2',{'X2_CHAVE','X2_UNICO'                                                                     })
o:TableData  ('SX2',{"EEJ"     ,'EEJ_FILIAL+EEJ_PEDIDO+EEJ_OCORRE+EEJ_TIPOBC+EEJ_CODIGO+EEJ_AGENCI+EEJ_NUMCON' }) //LRS - 14/09/2017

o:TableStruct("SX7",{'X7_CAMPO'   ,'X7_SEQUENC','X7_REGRA'     ,'X7_CDOMIN'  ,'X7_TIPO' ,'X7_SEEK' ,'X7_ALIAS' ,'X7_ORDEM' ,'X7_CHAVE'                    ,'X7_CONDIC' ,'X7_PROPRI'})
o:TableData  ('SX7',{'EE7_IMPORT' ,'010'       ,'SA1->A1_NOME' ,'EE7_IMPODE' ,'P'       ,'S'       ,'SA1'      ,1          ,'xFilial("SA1")+M->EE7_IMPORT',            ,'S'        })

o:TableStruct("SX7",{'X7_CAMPO'   ,'X7_SEQUENC','X7_REGRA'        ,'X7_CDOMIN','X7_CONDIC'          })
o:TableData  ('SX7',{'EE7_IMPORT' ,'002'       ,'AP102ViaTrans()' ,'EE7_VIA'  ,'AP102ViaTrans(.T.)' })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_F3" ,"X3_VALID"                     ,"X3_TRIGGER","X3_CBOX","X3_CBOXSPA","X3_CBOXENG"},2)
o:TableData( "SX3", {"A2_ID_FBFN" ,"48"    ,"AC115ValCpo('A2_ID_FBFN')"    ,""          ,""       ,""          ,""          })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2)
o:TableData  ("SX3",{"EE7_IMPORT" ,"13"       })
o:TableData  ("SX3",{"EE7_IMLOJA" ,"14"       })
o:TableData  ("SX3",{"EE7_IMPODE" ,"15"       })
o:TableData  ("SX3",{"EE7_TABPRE" ,"16"       })
o:TableData  ("SX3",{"EE7_STTDES" ,"17"       })
o:TableData  ("SX3",{"EE7_MOTSIT" ,"18"       })
o:TableData  ("SX3",{"EE7_DSCMTS" ,"19"       })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2)
o:TableData  ("SX3",{"EEC_IMPORT" ,"11"       })
o:TableData  ("SX3",{"EEC_IMLOJA" ,"12"       })
o:TableData  ("SX3",{"EEC_IMPODE" ,"13"       })
o:TableData  ("SX3",{"EEC_STTDES" ,"14"       })
o:TableData  ("SX3",{"EEC_MOTSIT" ,"15"       })
o:TableData  ("SX3",{"EEC_DSCMTS" ,"16"       })

o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_VALID"                                   ,"X3_RELACAO"  ,"X3_BROWSE","X3_INIBRW"                ,"X3_CBOX"                                               },2)
o:TableData("SX3"  ,{"EE7_AMOSTR","PERTENCE('124').AND.AP100CRIT('EE7_AMOSTR')","'2'"         ,"N"        ,                           ,"1=Sim – Sem Faturamento;2=Não;4=Sim – Com Faturamento" })
o:TableData("SX3"  ,{"EE7_VM_AMO",                                             ,              ,"S"        ,"AP102IniBrw('EE7_AMOSTR')",                                                        })
o:TableData("SX3"  ,{"EEC_AMOSTR","PERTENCE('124').AND.AE100CRIT('EEC_AMOSTR')","'2'"         ,"N"        ,                           ,"1=Sim – Sem Faturamento;2=Não;4=Sim – Com Faturamento" })
o:TableData("SX3"  ,{"EEC_VM_AMO",                                             ,              ,"S"        ,"AP102IniBrw('EEC_AMOSTR')",                                                        })

o:TableStruct("SX7",{'X7_CAMPO'   ,'X7_SEQUENC','X7_CONDIC'      },1)
o:TableData  ('SX7',{'EE7_IMPORT' ,'008'       ,'AP102CondGat()' })
o:TableData  ('SX7',{'EEC_IMPORT' ,'008'       ,'AP102CondGat()' })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID"      },2)
o:TableData  ("SX3",{"YE_MOEDA"   ,"At140ValInt()" })

o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                     ,"X6_DSCSPA"                                      ,"X6_DSCENG"                                      ,"X6_DESC1"                                     ,"X6_DSCSPA1"                                   ,"X6_DSCENG1"                                   ,"X6_DESC2"                               ,"X6_DSCSPA2"                             ,"X6_DSCENG2"                              ,"X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"})
o:TableData("SX6"  ,{"  "       ,"MV_EEC0041" ,"L"      ,"Desabilita a pergunta se deseja vincular um"    ,"Desabilita a pergunta se deseja vincular um"    ,"Desabilita a pergunta se deseja vincular um"    ,"embarque a uma carta de crédito caso não haja","embarque a uma carta de crédito caso não haja","embarque a uma carta de crédito caso não haja","saldo disponível na carta de crédito"   ,"saldo disponível na carta de crédito"   ,"saldo disponível na carta de crédito"    ,".F."       ,".F."       ,".F."       ,".T."      ,"S"      })
o:TableData("SX6"  ,{"  "       ,"MV_EEC0042" ,"L"      ,"Permite a compensação dos embarques que possuam","Permite a compensação dos embarques que possuam","Permite a compensação dos embarques que possuam","adiantamento, valores .T. ou .F."             ,"adiantamento, valores .T. ou .F."             ,"adiantamento, valores .T. ou .F."             ,""                                       ,""                                       ,""                                        ,".F."       ,".F."       ,".F."       ,".T."      ,"S"      })
o:TableData("SX6"  ,{"  "       ,"MV_EEC0043" ,"L"      ,"Caso habilitado, cria um pedido de compras"     ,"Caso habilitado, cria um pedido de compras"     ,"Caso habilitado, cria um pedido de compras"     ,"para cada despesa nacional e desabilita a"    ,"para cada despesa nacional e desabilita a"    ,"criação de um titulo no financeiro."          ,"criação de um titulo no financeiro."    ,"criação de um titulo no financeiro."    ,"criação de um titulo no financeiro."     ,".F."       ,".F."       ,".F."       ,".T."      ,"S"      })
o:TableData("SX6"  ,{"  "       ,"MV_EEC0044" ,"C"      ,"Define a condição de pagamento padrão para"     ,"Define a condição de pagamento padrão para"     ,"Define a condição de pagamento padrão para"     ,"os pedidos de compras criados para as"        ,"os pedidos de compras criados para as"        ,"os pedidos de compras criados para as"        ,"despesas nacionais (módulo de compras).","despesas nacionais (módulo de compras).","despesas nacionais (módulo de compras)." ,""          ,""          ,""          ,".T."      ,"S"      })

o:TableStruct('SX3',{'X3_ARQUIVO','X3_ORDEM','X3_CAMPO'    ,'X3_TIPO','X3_TAMANHO','X3_DECIMAL','X3_TITULO','X3_TITSPA','X3_TITENG','X3_DESCRIC'       ,'X3_DESCSPA'       ,'X3_DESCENG'       ,'X3_PICTURE','X3_VALID','X3_USADO'     ,'X3_RELACAO','X3_F3','X3_NIVEL','X3_RESERV','X3_CHECK','X3_TRIGGER','X3_PROPRI','X3_BROWSE','X3_VISUAL','X3_CONTEXT','X3_OBRIGAT','X3_VLDUSER','X3_CBOX','X3_CBOXSPA','X3_CBOXENG','X3_PICTVAR','X3_WHEN','X3_INIBRW','X3_GRPSXG','X3_FOLDER','X3_PYME','X3_CONDSQL','X3_CHKSQL','X3_IDXSRV','X3_ORTOGRA','X3_IDXFLD'})
o:TableData("SX3"  ,{"EET"       ,"43"      ,"EET_PEDCOM"  ,"C"      ,6           ,0           ,"Ped.Com." ,"Ped.Com." ,"Ped.Com." ,"Pedido de Compras","Pedido de Compras","Pedido de Compras",""          ,""        , TODOS_MODULOS ,""          ,""     ,""        ,""         ,""        ,""          ,""         ,""         , "V"       ,""          ,""          ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,""         ,""       ,""          ,""         ,""         ,""          ,""         })
//o:TableData("SX3"  ,{'SYB'       ,'62'      ,'YB_PRODUTO'  ,'C'      ,AVSX3("B1_COD",3) ,0     ,'Cod.Produto','Cod.Produto','Cod.Produto','Codigo do Produto','Codigo del Producto','Product Code','@!'     ,'ExistCpo("SB1")',TODOS_MODULOS,''     ,'PRT'  ,1         ,NOME+TIPO+TAM+DEC,''       ,''           ,''          ,'S'         ,'A'          ,'R'         ,''            ,''          ,''                             ,''          ,''          ,''           ,''        ,''          ,'030'       ,''          ,'S'        ,''          ,''         ,'S'        ,'N'        ,'N'       })

o:TableStruct("EYC",{"EYC_FILIAL"   ,"EYC_CODAC","EYC_CODINT","EYC_CODEVE","EYC_CODSRV","EYC_CONDIC"                },1)
o:TableData("EYC"  ,{xFilial("EYC") ,"015"      ,"001"       ,"001"       ,"012"       ,"!EasyGParam('MV_EEC0043',,.F.)" })
o:TableData("EYC"  ,{xFilial("EYC") ,"016"      ,"001"       ,"001"       ,"013"       ,"!EasyGParam('MV_EEC0043',,.F.)" })
o:TableData("EYC"  ,{xFilial("EYC") ,"015"      ,"001"       ,"002"       ,"017"       ,"EasyGParam('MV_EEC0043',,.F.)"  })
o:TableData("EYC"  ,{xFilial("EYC") ,"016"      ,"001"       ,"002"       ,"018"       ,"EasyGParam('MV_EEC0043',,.F.)"  })

//UE_CERT_ORI() //LGS-06/11/2015
   //NCF - Ajustes para rotina de câmbio com movimentação no exterior.
   o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_WHEN"              },2)
   o:TableData("SX3"  ,{"EEQ_SOL"     ,"AF200W('EEQ_SOL')"      })
   o:TableData("SX3"  ,{"EEQ_DTNEGO"  ,"AF200W('EEQ_DTNEGO')"   })
   o:TableData("SX3"  ,{"EEQ_PGT"     ,"AF200W('EEQ_PGT')"      })
   o:TableData("SX3"  ,{"EEQ_TX"      ,"AF200W('EEQ_TX')"       })
   o:TableData("SX3"  ,{"EEQ_EQVL"    ,"AF200W('EEQ_EQVL')"     })
   o:TableData("SX3"  ,{"EEQ_DTCE"    ,"AF200W('EEQ_DTCE')"     })

   o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_VALID"               },2)
   o:TableData("SX3"  ,{"EEQ_MODAL"   ,"AF200VALID('EEQ_MODAL')"  })
   o:TableData("SX3"  ,{"EEQ_DTCE"    ,"AF200VALID('EEQ_DTCE')"   })

   o:TableStruct("SX7",{"X7_CAMPO"   ,"X7_SEQUENC","X7_REGRA"                                                                                    ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC"                                ,"X7_PROPRI"},1)
   o:TableData("SX7"  ,{"EEQ_BCOEXT" ,"001"       ,'BCOAGE(M->EEQ_BCOEXT)'                                                                       ,            ,         ,         ,          ,          ,          ,                                           ,           }  )

   o:TableStruct("SIX",{"INDICE","ORDEM" ,"CHAVE"                                                                    ,"DESCRICAO"                                                           })
   o:TableData("SIX"  ,{"EES"   ,"1"     ,"EES_FILIAL+EES_PREEMB+EES_NRNF+EES_SERIE+EES_PEDIDO+EES_SEQUEN+EES_FATSEQ","Processo + Nota Fiscal + Serie + Pedido + Sequencia + Seq.It.NF.Fa " })

//MCF - 22/12/2015
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID"                             },2)
o:TableData("SX3"  ,{"EEC_CONSIG" ,"AE100CRIT('EEC_CONSIG')"              })
o:TableData("SX3"  ,{"EEC_COLOJA" ,"VAZIO() .OR. AE100CRIT('EEC_COLOJA')" })

o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_ORDEM"  },2)
o:TableData("SX3"  ,{"EEC_FORNDE"  ,"32"        })
o:TableData("SX3"  ,{"EEC_CONSIG"  ,"33"        })
o:TableData("SX3"  ,{"EEC_COLOJA"  ,"34"        })
o:TableData("SX3"  ,{"EEC_CONSDE"  ,"35"        })
o:TableData("SX3"  ,{"EEC_RESPON"  ,"36"        })
o:TableData("SX3"  ,{"EEC_LICIMP"  ,"20"        })//LGS-02/02/2016
o:TableData("SX3"  ,{"EEC_CLIENT"  ,"21"        })
o:TableData("SX3"  ,{"EEC_DTLIMP"  ,"20"        })
o:TableData("SX3"  ,{"EEC_EXPORT"  ,"28"        })
o:TableData("SX3"  ,{"EEC_CLIEDE"  ,"27"        })

o:TableStruct("SX7",{"X7_CAMPO"   ,"X7_SEQUENC","X7_REGRA"       ,"X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC"            },1)
o:TableData("SX7"  ,{"EEC_CONSIG" ,"001"       ,'AE102ConLoja()' ,"N"      ,""        ,          ,""        ,"Empty(M->EEC_COLOJA)" }  )

//MCF - 29/12/2015
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_GRPSXG" },2)
o:TableData("SX3"  ,{"EET_LOJAF" ,"002"       })

//LRS - 20/01/2016
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_WHEN" },2)
o:TableData("SX3"  ,{"EY4_CODBOL" ,"Inclui"  })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_WHEN" },2)
o:TableData("SX3"  ,{"EY4_COD" ,"Inclui"  })

//MCF - 30/12/2015
o:TableStruct("SX3",{"X3_CAMPO" ,"X3_PICTURE" },2)
o:TableData("SX3"  ,{"EXL_EMFR" ,"@!"         })

//MCF - 26/02/2016
o:TableStruct("SX7",{"X7_CAMPO" ,"X7_SEQUENC" ,"X7_REGRA"                           })
o:TableData  ('SX7',{'EEQ_PGT'  ,'001'        ,'BUSCATAXA(M->EEQ_MOEDA,M->EEQ_PGT)' })

//MCF - 17/05/2016
//o:TableStruct("SX7",{"X7_CAMPO" ,"X7_SEQUENC" ,"X7_CONDIC"           })
//o:TableData  ('SX7',{'EEQ_TX'   ,'002'        ,'Type("lIsEmb")=="L"' })

RestOrd(aOrd,.T.)

//LRS - 27/01/2016
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"    ,"XB_DESCSPA"    ,"XB_DESCENG" ,"XB_CONTEM"              ,"XB_WCONTEM"})
o:TableData  ("SXB",{"Y6B"     ,"3"      ,"01"    ,"01"       ,"Cadastra Novo","Incluye Nuevo" ,"Add New"    ,"01#SI101RE('EER',0,3)"  ,            })

   //LRS - 1/6/2016
   o:TableStruct('SXA',{'XA_ALIAS','XA_ORDEM','XA_DESCRIC'            ,'XA_DESCSPA','XA_DESCENG','XA_PROPRI'})
   o:TableData('SXA',  {'EXJ'    ,'7'        ,'Endereço Complementar ',""          ,""          ,'S'})
   /* NÃO PODE EXISTIR CRIAÇÃO DE CAMPO NO AVUPDATE02, A CRIAÇÃO DEVE SER EFETUADA ATRAVES DO SDFBRA.TXT
   o:TableStruct("SX3",{"X3_ARQUIVO","X3_ORDEM","X3_CAMPO"   ,"X3_TIPO","X3_TAMANHO","X3_DECIMAL","X3_TITULO"     ,"X3_TITSPA" ,"X3_TITENG" ,"X3_DESCRIC"               ,"X3_DESCSPA" ,"X3_DESCENG" ,"X3_PICTURE"   ,"X3_VALID"                                                             ,"X3_USADO"    ,"X3_RELACAO","X3_F3" ,"X3_NIVEL","X3_RESERV" ,"X3_CHECK","X3_TRIGGER","X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX","X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN","X3_INIBRW","X3_GRPSXG","X3_FOLDER","X3_PYME","X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"})
   o:TableData("SX3"  ,{"EXJ"       ,"14"      ,"EXJ_END"    ,"C"      ,40          ,0           ,"Endereço"      ,""          ,""          ,"Endereço do cliente"      ,""           ,""           , "@!"          ,""                                                                     ,TODOS_MODULOS ,""          ,""      ,0         ,USO         ,""        ,""          ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })
   o:TableData("SX3"  ,{"EXJ"       ,"15"      ,"EXJ_BAIRRO" ,"C"      ,30          ,0           ,"Bairro"        ,""          ,""          ,"Bairro do cliente"        ,""           ,""           , "@!"          ,""                                                                     ,TODOS_MODULOS ,""          ,""      ,0         ,USO         ,""        ,""          ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })
   o:TableData("SX3"  ,{"EXJ"       ,"16"      ,"EXJ_COD_ES" ,"C"      ,2           ,0           ,"Cd. Estado"    ,""          ,""          ,"Cod Estado do cliente "   ,""           ,""           , "@!"          ,'ExistCpo("SX5","12"+M->EXJ_COD_ES)'                                   ,TODOS_MODULOS ,""          ,"12"    ,0         ,USO         ,""        ,"S"         ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,"010"      ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })
   o:TableData("SX3"  ,{"EXJ"       ,"17"      ,"EXJ_EST"    ,"C"      ,30          ,0           ,"Estado"        ,""          ,""          ,"Estado do cliente "       ,""           ,""           , "@!"          ,""                                                                     ,TODOS_MODULOS ,""          ,""      ,0         ,USO         ,""        ,""          ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })
   o:TableData("SX3"  ,{"EXJ"       ,"18"      ,"EXJ_COD_MU" ,"C"      ,5           ,0           ,"Cd. Municipio" ,""          ,""          ,"Código do Municipio"      ,""           ,""           , "@99999"      ,'ExistCpo("CC2",M->EXJ_COD_ES+M->EXJ_COD_MU)'                          ,TODOS_MODULOS ,""          ,"CC2SA1",0         ,USO         ,""        ,"S"         ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })
   o:TableData("SX3"  ,{"EXJ"       ,"19"      ,"EXJ_MUN"    ,"C"      ,60          ,0           ,"Municipio"     ,""          ,""          ,"Municipio do cliente"     ,""           ,""           , "@!"          ,""                                                                     ,TODOS_MODULOS ,""          ,""      ,0         ,USO         ,""        ,""          ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })
   o:TableData("SX3"  ,{"EXJ"       ,"20"      ,"EXJ_CEP"    ,"C"      ,8           ,0           ,"CEP"           ,""          ,""          ,"Cod Enderecamento Postal ",""           ,""           , "@R 99999-999","A030Cep()"                                                            ,TODOS_MODULOS ,""          ,""      ,0         ,USO         ,""        ,""          ,""         ,"N"        ,""         ,""          ,"N"         ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,""         ,"7"        ,"N"      ,            ,           ,"N"        ,"N"         ,"N"        ,         })

   aAdd(o:aHelpProb,{"EXJ_END",    {"Endereço do cliente."}})
   aAdd(o:aHelpProb,{"EXJ_BAIRRO", {"Bairro do cliente."}})
   aAdd(o:aHelpProb,{"EXJ_COD_MU", {"Código do Municipio."}})
   aAdd(o:aHelpProb,{"EXJ_MUN",    {"Municipio do cliente."}})
   aAdd(o:aHelpProb,{"EXJ_CEP",    {"Código de endereçamento postal do cliente."}})
   aAdd(o:aHelpProb,{"EXJ_COD_ES", {"Código do Estado do cliente."}})
   aAdd(o:aHelpProb,{"EXJ_EST",    {"Estado do cliente."}})
   */
   o:TableStruct("SX7",{"X7_CAMPO"  ,"X7_SEQUENC","X7_REGRA"     ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE"                                   ,"X7_CONDIC" ,"X7_PROPRI"})
   o:TableData("SX7"  ,{"EXJ_COD_MU","001"       ,"CC2->CC2_MUN" ,"EXJ_MUN"   ,"P"      ,"S"      ,"CC2"     ,"1"       ,"xFilial('CC2')+M->EXJ_COD_ES+M->EXJ_COD_MU ",""          ,"S"        })

   o:TableStruct("SX7",{"X7_CAMPO"  ,"X7_SEQUENC","X7_REGRA"   ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE"                           ,"X7_CONDIC" ,"X7_PROPRI"})
   o:TableData("SX7"  ,{"EXJ_COD_ES","001"       ,"X5DESCRI()" ,"EXJ_EST"   ,"P"      ,"S"      ,"SX5"     ,"1"       ,"xFilial('SX5')+'12'+M->EXJ_COD_ES  ",""          ,"S"        })


   o:TableStruct("SX3",{"X3_CAMPO"   , "X3_USADO", "X3_BROWSE"},2) //LGS-10/06/2016
   o:TableData( "SX3", {"EEX_FILIAL" , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_PREEMB" , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_NUM"    , TODOS_AVG , "N"        }  )
   o:TableData( "SX3", {"EEX_DATA"   , TODOS_AVG , "N"        }  )
   o:TableData( "SX3", {"EEX_CNPJ"   , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_CNPJ_R" , TODOS_AVG , "N"        }  )
   o:TableData( "SX3", {"EEX_RLFJ"   , TODOS_AVG , "N"        }  )
   o:TableData( "SX3", {"EEX_VIAINT" , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_DVIAIN" , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_PESLIQ" , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_PESBRU" , TODOS_AVG , "S"        }  )
   o:TableData( "SX3", {"EEX_TOTCV"  , TODOS_AVG , "S"        }  )

// NCF - 29/04/2016 - Verifica se está ativada a integração do SIGAEEC com o ERP Externo via mensagem única
//                    Estas alterações só devem ser existir no dicionário do ambiente, ou seja, não constam no ATUSX.
If EasyGParam("MV_EECI010",,.F.)

   o:TableStruct("SIX",{"INDICE","ORDEM" ,"CHAVE"                ,"DESCRICAO","DESCSPA","DESCENG","PROPRI"})
   o:TableData("SIX"  ,{"SAH"   ,"2"     ,"AH_FILIAL+AH_CODERP"  ,"Cod.ERP"  ,"Cod.ERP","Cod.ERP",""      })

   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"  ,"X3_RESERV"   ,"X3_OBRIGAT"},2)
   o:TableData("SX3"  ,{"SAH"       ,"AH_COD_SIS",TAM           ,"N"})

   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"  ,"X3_WHEN"})
   o:TableData("SX3"  ,{"EEQ"       ,"EEQ_HVCT"  ,".F."})

   o:TableStruct("SX7",{"X7_CAMPO"    , "X7_SEQUENC","X7_CONDIC"})
   o:TableData("SX7"  ,{"EEQ_CODEMP"  ,"001"        ,'!AVFLAGS("EEC_LOGIX")'})
   o:TableData("SX7"  ,{"EEQ_CODEMP"  ,"002"        ,'!AVFLAGS("EEC_LOGIX")'})

   o:TableStruct("SX7",{"X7_CAMPO"   ,"X7_SEQUENC","X7_REGRA"                                                                                    ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC"                                ,"X7_PROPRI"},1)
   //THTS - 21/07/2017 - nopado: a regra adicionada existia no fonte EECAF300, o que matava esta regra que o update adicionava.
   //o:TableData("SX7",{"EEQ_TX"     ,"001"       ,"M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VLFCAM)"                                     ,'EEQ_EQVL'  ,'P'      ,'N'      ,          ,          ,          ,' '                                        ,"S"        }  )
   //o:TableData("SX7"  ,{"EEQ_TX"     ,"001"       ,"M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VL)"                                         ,'EEQ_EQVL'  ,'P'      ,'N'      ,          ,          ,          ,' '                                        ,"S"        }  )
   //--
   o:TableData("SX7"  ,{"EEQ_TX"     ,"002"       ,"0"                                                                                           ,"EEQ_EQVL"  ,"P"      ,"N"      ,""        ,"0"       ,""        ,"Empty(M->EEQ_TX)"                         ,"S"        }  )
   o:TableData("SX7"  ,{"EEQ_TX"     ,"003"       ,"M->EEQ_TX*M->EEQ_VM_REC"                                                                     ,"EEQ_EQVL"  ,"P"      ,"N"      ,''        ,''        ,          ,'IsInCallStack("EECAF500")'                ,"S"        }  )
   o:TableData("SX7"  ,{"EEQ_VL"     ,"001"       ,"M->EEQ_VL-M->EEQ_DESCON"                                                                     ,'EEQ_VM_REC','P'      ,'N'      ,          ,          ,          ,'!lFinanciamento'                          ,"S"        }  )
   o:TableData("SX7"  ,{"EEQ_VL"     ,"002"       ,"M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VLFCAM)"                                     ,'EEQ_EQVL'  ,'P'      ,'N'      ,          ,          ,          ,'Type("lIsEmb")="U" .and. !lFinanciamento' ,"S"        }  )
   o:TableData("SX7"  ,{"EEQ_DESCON" ,"001"       ,"M->EEQ_VL-M->EEQ_DESCON"                                                                     ,'EEQ_VM_REC','P'      ,'N'      ,          ,          ,          ,'Type("lTelaVincula")="U".Or.lTelaVincula' ,"S"        }  )
   
   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"  ,"X3_VALID"},2)
   o:TableData(  "SX3",{"SY5"       ,"Y5_BANCO"  ,""        })

   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"  ,"X3_VALID"                                                                               })
   o:TableData(  "SX3",{"SYE"       ,"YE_MOEDA"  ,"AvgExistCpo('SYF',M->YE_MOEDA) .AND. ExistChav('SYE',DTOS(M->YE_DATA)+M->YE_MOEDA)"     })

   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"   ,"X3_TRIGGER","X3_VALID"                                        })
   o:TableData("SX3"  ,{"EES"       ,"EES_QTDDEV" , "S"        , "If(FindFunction('NF400Valid'),NF400Valid(),.T.)"})

   o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_RESERV", "X3_OBRIGAT" },2)
   o:TableData("SX3"  ,{"EEE_DCRED"  ,           , "N"          })

   o:TableStruct("SX6",{"X6_FIL"       ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                        ,"X6_DESC1"                                                              ,"X6_DESC2"                                              ,"X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"})
   o:TableData("SX6"  ,{xFilial("SX6") ,"MV_EEC0048," ,"L"      ,"Determina se será controlada a geração de eventos" ,"contábeis de embarque em transito para a despesa "                    ,"de comissão em conta gráfica"                          ,""          ,""          ,".T."       ,".T."       ,".T."       ,"S"        ,"N"      })
   o:TableData("SX6"  ,{xFilial("SX6") ,"MV_EEC0049," ,"L"      ,"Indica se serão realizadas integrações contábeis " ,"da comissão conta gráfica via EAI durante a"                          ,"manutenção de embarque e liquidação de câmbio "        ,""          ,""          ,".T."       ,".T."       ,".T."       ,"S"        ,"N"      })

   o:TableStruct("SX7",{"X7_CAMPO"    , "X7_SEQUENC","X7_CONDIC"})
   o:TableData("SX7"  ,{"EE8_COD_I"   ,"002"        ,"Empty(M->EE8_EMBAL1)"})
   o:TableData("SX7"  ,{"EE8_COD_I"   ,"004"        ,"Empty(M->EE8_QE)"    })

   o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_USADO"},2)
   o:TableData(  "SX3",{"EE8_DSCQUA",NAO_USADO})

   //o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_TAMANHO","X3_DECIMAL" ,"X3_PICTURE"        },2)
   //o:TableData("SX3"  ,{"EYH_QTDEMB",14           ,3           ,"@E 99,999,999.999" })
   //o:TableData("SX3"  ,{"EYH_RELSUP",14           ,3           ,"@E 99,999,999.999" })
   //o:TableData("SX3"  ,{"A1_TEL"    ,20           ,0           ,"" })
   //o:TableData("SX3"  ,{"A1_FAX"    ,20           ,0           ,"" })

   //o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_PICTURE", "X3_RESERV" },2)
   //o:TableData("SX3"  ,{"EEM_SERIE" , 3           ,0            ,"@!"        , TAM+DEC     })   //ocasiona erro no UPDSISTR

   //o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO","X3_TAMANHO"})
   //o:TableData(  "SX3",{"SA6"       ,"A6_DVAGE","2"         })
   //o:TableData(  "SX3",{"SA6"       ,"A6_DVCTA","2"         })
   o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_BROWSE"},2)
   o:TableData("SX3"  ,{"EF3_SEQBX" ,"S"        })                     //NCF - 20/06/2016 - EFF x LOGIX

   o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_RESERV"},2)
   o:TableData("SX3"  ,{"EYH_QTDEMB",TAM+DEC    })
   o:TableData("SX3"  ,{"EYH_RELSUP",TAM+DEC    })
   o:TableData("SX3"  ,{"A1_TEL"    ,TAM+DEC    })
   o:TableData("SX3"  ,{"A1_FAX"    ,TAM+DEC    })
   o:TableData("SX3"  ,{"A6_DVAGE"  ,TAM+DEC    })
   o:TableData("SX3"  ,{"A6_DVCTA"  ,TAM+DEC    })

   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO" ,"X3_VISUAL"})
   o:TableData(  "SX3",{"EES"       ,"EES_COD_I","A"        })

   o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"    ,"X3_FOLDER"},2)
   o:TableData(  "SX3",{"EE7"       ,"EE7_DTSLAP"  ,"1"        })
   o:TableData(  "SX3",{"EE7"       ,"EE7_DTAPPE"  ,"1"        })

   o:TableStruct("SX5",{"X5_FILIAL"     ,"X5_TABELA","X5_CHAVE","X5_DESCRI"                           ,"X5_DESCSPA"                        ,"X5_DESCENG"                        })
   o:TableData(  "SX5",{xFilial("SX5")  , "YC"      , "N     " ,"Aguardando Aprovação da Proforma"    ,"Aguardando Aprovação da Proforma"  ,"Aguardando Aprovação da Proforma"  })
   o:TableData(  "SX5",{xFilial("SX5")  , "YC"      , "O     " ,"Proforma Aprovada"                   ,"Proforma Aprovada"                 ,"Proforma Aprovada"                 })
   o:TableData(  "SX5",{xFilial("SX5")  , "YC"      , "P     " ,"Proforma em Edição"                  ,"Proforma em Edição"                ,"Proforma em Edição"                })
   o:TableData(  "SX5",{xFilial("SX5")  , "YC"      , "Q     " ,"Processo devolvido"                  ,"Processo devolvido"                ,"Processo devolvido"                })

   o:TableData("MENU",{"SIGAEFF"  ,"EFFEX103",{"Miscelanea"}    ,""                ,{"Lctos para Contab"      ,"Lctos para Contab"       ,"Lctos para Contab"}      ,"1" ,{"EF1"}       ,"xxxxxxxxxx","0"  })
   o:TableData("MENU",{"SIGAEFF"  ,"EFFEX104",{"Miscelanea"}    ,""                ,{"Cancelam. Contab"       ,"Cancelam. Contab"        ,"Cancelam. Contab"}       ,"1" ,{"EF1","EF3"} ,"xxxxxxxxxx","0"  })
   o:TableData("MENU",{"SIGAEEC"  ,"EECREG85",{"Miscelanea"}    ,""                ,{"Registro 85"            ,"Registro 85"             ,"Registro 85"}            ,"1" ,{"EEC"}       ,"xxxxxxxxxx","0"  })
   o:TableData("MENU",{"SIGAEEC"  ,"EECNF400",{"Atualizações"}  ,""                ,{"Notas Fiscais de Saida" ,"Notas Fiscais de Saida"  ,"Notas Fiscais de Saida"} ,"1" ,{"EEM","EES"} ,"xxxxxxxxxx","0"  })
   o:TableData("MENU",{"SIGAEEC"  ,"EECLC500",{"Miscelanea"}    ,""                ,{"Lanc.Contab.Comissão CG","Lanc.Contab.Comissão CG" ,"Lanc.Contab.Comissão CG"},"1" ,{"ECF"}       ,"xxxxxxxxxx","0"  })
EndIf
//LRS - 06/06/2016
o:TableStruct("SX7",{"X7_CAMPO"  ,"X7_SEQUENC","X7_REGRA"                                                                                 ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE"                   ,"X7_CONDIC"   ,"X7_PROPRI"})
o:TableData("SX7"  ,{"B1_POSIPI" ,"002"       ,"IF (SYD->YD_ANUENTE <> '' .OR. SYD->YD_ANUENTE == '2',SYD->YD_ANUENTE, M->B1_ANUENTE)"    ,"B1_ANUENTE","P"      ,"S"      ,"SYD"     ,"1"       ,'xFilial("SYD")+M->B1_POSIPI',""            ,"S"        })

o:TableStruct("SX1",{"X1_GRUPO"  ,"X1_ORDEM"  ,"X1_PERGUNT","X1_PERSPA","X1_PERENG" ,"X1_TIPO" ,"X1_TAMANHO","X1_VAR01","X1_DECIMAL","X1_GSC", "X1_DEF01", "X1_DEF02", "X1_DEF03"})
o:TableData("SX1"  ,{"EI100A"    ,"02"        ,"Regional?" ,"Regional?","Regional?" ,"C"       ,2           ,"MV_PAR02", 0          ,"C"	 , ""        , ""        , ""        })
o:TableData("SX1"  ,{"EI100A"    ,"03"        ,"Idioma?"   ,"Idioma?"  ,"Idioma?"   ,"C"       ,2           ,"MV_PAR03", 0          ,"C"	 , "EN"      , "PT"      , "ES"      })

//LRS - 01/12/2016
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID" },2)
o:TableData  ("SX3",{"EXL_FINTFR" ,'Vazio() .Or. ExistCpo("SA2",M->EXL_FINTFR+AllTrim(M->EXL_FLOJFR),,,,!EMPTY(M->EXL_FLOJFR)) .AND. DespIntVld()'       })
o:TableData  ("SX3",{"EXL_FINTSE" ,'Vazio() .Or. ExistCpo("SA2",M->EXL_FINTSE+AllTrim(M->EXL_FLOJSE),,,,!EMPTY(M->EXL_FLOJSE)) .AND. DespIntVld()'      })
o:TableData  ("SX3",{"EXL_FINTFA" ,'Vazio() .Or. ExistCpo("SA2",M->EXL_FINTFA+AllTrim(M->EXL_FLOJFA),,,,!EMPTY(M->EXL_FLOJFA)) .AND. DespIntVld()'      })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_TITULO"    },2)
o:TableData  ("SX3",{"EXL_FLOJFR" ,'Loj.Fre.Int.' })
o:TableData  ("SX3",{"EXL_FLOJSE" ,'Loj.Fre.Int.' })
o:TableData  ("SX3",{"EXL_FLOJFA" ,'Loj.Fre.Int.' })

//MFR - 08/02/2017
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_USADO", "X3_RESERV"},2)
o:TableData  ("SX3"  ,{"EE8_TES"   , TODOS_MODULOS, USO+OBRIGAT})
o:TableData  ("SX3"  ,{"EE8_CF"   , TODOS_MODULOS, USO+OBRIGAT})

//THTS - 20/07/2017
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"       	 ,"XB_DESCSPA"      		,"XB_DESCENG"   			,"XB_CONTEM"       ,"XB_WCONTEM"})
o:TableData("SXB"  ,{ "ATOCON" , "1"     ,"01"    ,"RE"       ,"Ato Concessorio"		 ,"Ato Concessorio"		,"Ato Concessorio" 		,""                ,                })
o:TableData("SXB"  ,{ "ATOCON" , "2"     ,"01"    ,"01"       ,""                	 ,""                		,""             			,"XBEECAE100()"    ,            })
o:TableData("SXB"  ,{ "ATOCON" , "5"     ,"01"    ,""         ,""                	 ,""                		,""             			,"cRetorno"        ,            })

o:TableStruct("SX3"  ,{"X3_CAMPO"   ,"X3_F3" },2)
o:TableData  ("SX3"  ,{"EE9_ATOCON" ,"ATOCON"})

//CEO - 02/03/2018
o:TableStruct("SX3",{"X3_CAMPO", "X3_RESERV"},2)
o:TableData  ("SX3",{"EXJ_END", TAM})

//CEO - 08/05/2018
o:TableStruct("SX3",{"X3_CAMPO", "X3_VALID"},2)
o:TableData  ("SX3",{"EE8_RESERV", 'Vazio() .or. EECVLEE8("EE8_RESERV")'})

Return Nil

//WFS - 27/06/2017 - chamado por UPDESS
Function AjustaEEQ(o)  // GFP - 16/10/2015

o:TableStruct("SX7",{'X7_CAMPO'  ,'X7_SEQUENC'  , 'X7_REGRA'               ,'X7_CDOMIN'  ,'X7_TIPO' ,'X7_SEEK'  ,'X7_ALIAS' , 'X7_ORDEM' , 'X7_CHAVE'                       , 'X7_CONDIC'                               ,'X7_PROPRI'},1)
//THTS - 21/07/2017 - nopado: a regra adicionada existia no fonte EECAF300, o que matava esta regra que o update adicionava.
//o:TableData("SX7",{ 'EEQ_TX' , '001' , 'M->EEQ_TX*IF(TYPE("nTOTFFC")="N",nTOTFFC,M->EEQ_VM_REC)' , 'EEQ_EQVL' , 'P' , 'N' , '' , '' ,, '!lFinanciamento' , 'S'})
//o:TableData("SX7"  ,{ "EEQ_TX" , "001" , "M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VL)"                                         ,'EEQ_EQVL'  ,'P'      ,'N'      ,          ,          ,          ,' '                                        ,"S"        }  )
//o:TableData("SX7"  ,{ 'EEQ_TX' , '002' , 'M->EEQ_TX*M->EEQ_VLFCAM' , 'EEQ_EQVL' , 'P' , '' , '' , '' ,, 'Type("lIsEmb")=="U"' , 'S'})
o:TableData("SX7"  ,{ 'EEQ_TX' , '003' , 'M->EEQ_TX*M->EEQ_VM_REC' , 'EEQ_EQVL' , 'P' , 'N' , '' , '' ,, 'IsInCallStack("EECAF500")' , 'S'})

o:TableData("SX7"  ,{"EEQ_PGT" ,"001"  ,'BUSCATAXA(EEC->EEC_MOEDA,M->EEQ_PGT)'                                                        ,'EEQ_TX'    ,'P'      ,'N'      ,          ,          ,          ,'Type("lIsEmb")="L" .And. lIsEmb = .T.'    ,"S"        }  )
o:TableData("SX7"  ,{"EEQ_PGT" ,"002"  ,'BuscaTaxa(Posicione("EXJ",1,xFilial("EXJ")+SA1->A1_COD+SA1->A1_LOJA,"EXJ_MOEDA"),M->EEQ_PGT)','EEQ_TX'    ,'P'      ,'N'      ,          ,          ,          ,'Type("cTipoCad")="C" .AND. cTipoCad="I"'  ,"S"        }  )
o:TableData("SX7"  ,{"EEQ_PGT" ,"003"  ,'BUSCATAXA(EE7->EE7_MOEDA,M->EEQ_PGT)'                                                        ,'EEQ_TX'    ,'P'      ,'N'      ,          ,          ,          ,'Type("lIsPed")="L" .AND. lIsPed = .T.'    ,"S"        }  )
o:TableData("SX7"  ,{"EEQ_PGT" ,"004"  ,"M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VLFCAM)"                                     ,'EEQ_EQVL'  ,'P'      ,'N'      ,          ,          ,          ,'TYPE("LISEMB")="U"'                       ,"S"        }  )
o:TableData("SX7"  ,{"EEQ_PGT" ,"005"  ,"M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VLFCAM)"                                     ,'EEQ_EQVL'  ,'P'      ,'N'      ,          ,          ,          ,'TYPE("LISEMB")<>"U" .AND. LISEMB'         ,"S"        }  )
o:TableData("SX7"  ,{"EEQ_PGT" ,"006"  ,"0"                                                                                           ,"EEQ_TX"    ,"P"      ,"N"      ,""        ,"0"       ,""        ,"Empty(M->EEQ_PGT)"                        ,"S"        }  )
o:TableData("SX7"  ,{"EEQ_PGT" ,"007"  ,"0"                                                                                           ,"EEQ_EQVL"  ,"P"      ,"N"      ,""        ,"0"       ,""        ,"Empty(M->EEQ_PGT)"                        ,"S"        }  )

Return Nil
/*
Funcao                     : UPDEEC014
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      : Lucas Raminelli LRS
Data/Hora   			      : 10/11/2016
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEEC014(o)


Local n0052 := 1

//LRS - 10/11/2016 - NOPADO POR GFP - 30/11/2016 - AvUpdate02 não pode conter criação de campos SX3.
//Update implementa o campo EYJ_CODFIE, para registrar o ID da declaração de origem na integração com o portal ECOOL.
//o:TableStruct('SX3',{'X3_ARQUIVO','X3_ORDEM','X3_CAMPO'    ,'X3_TIPO','X3_TAMANHO','X3_DECIMAL','X3_TITULO' ,'X3_TITSPA'   ,'X3_TITENG','X3_DESCRIC','X3_DESCSPA','X3_DESCENG','X3_PICTURE','X3_VALID','X3_USADO'     ,'X3_RELACAO','X3_F3','X3_NIVEL','X3_RESERV','X3_CHECK','X3_TRIGGER','X3_PROPRI','X3_BROWSE','X3_VISUAL','X3_CONTEXT','X3_OBRIGAT','X3_VLDUSER','X3_CBOX','X3_CBOXSPA','X3_CBOXENG','X3_PICTVAR','X3_WHEN','X3_INIBRW','X3_GRPSXG','X3_FOLDER','X3_PYME','X3_CONDSQL','X3_CHKSQL','X3_IDXSRV','X3_ORTOGRA','X3_IDXFLD'})
//o:TableData("SX3"  ,{"EYJ"       , "99"     , "EYJ_CODFIE" , "C"      , 20         , 0          , "Cod.FIESP" ,"Cod.FIESP" ,"Cod.FIESP","Cod.FIESP" ,"Cod.FIESP" ,"Cod.FIESP" ,            ,          , TODOS_MODULOS ,            ,       ,          ,           ,          ,            ,           ,           ,"A"        ,"R"         ,            ,            ,         ,            ,            ,            ,         ,           ,           ,           ,         ,            ,           ,           ,            ,           })

//LRS - 01/12/2016
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID" },2)
o:TableData  ("SX3",{"EXL_FINTFR" ,'Vazio() .Or. ExistCpo("SA2",M->EXL_FINTFR+AllTrim(M->EXL_FLOJFR),,,,!EMPTY(M->EXL_FLOJFR)) .AND. DespIntVld()'       })
o:TableData  ("SX3",{"EXL_FINTSE" ,'Vazio() .Or. ExistCpo("SA2",M->EXL_FINTSE+AllTrim(M->EXL_FLOJSE),,,,!EMPTY(M->EXL_FLOJSE)) .AND. DespIntVld()'      })
o:TableData  ("SX3",{"EXL_FINTFA" ,'Vazio() .Or. ExistCpo("SA2",M->EXL_FINTFA+AllTrim(M->EXL_FLOJFA),,,,!EMPTY(M->EXL_FLOJFA)) .AND. DespIntVld()'      })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_TITULO"    },2)
o:TableData  ("SX3",{"EXL_FLOJFR" ,'Loj.Fre.Int.' })
o:TableData  ("SX3",{"EXL_FLOJSE" ,'Loj.Fre.Int.' })
o:TableData  ("SX3",{"EXL_FLOJFA" ,'Loj.Fre.Int.' })
/* migrado para avupdate02, para ser executada independente de versão
//MCF - Correção para versão 12.1.14 - Deletando digitação nota fiscal de remessa - Projeto Durli
If !NFRemNewStruct() //NCF - 17/03/2017 - Deve verificar se a utilização da nova rotina está ativada antes de atualizar a consulta(solução temporária até a homologação da nova consulta)
   //Limpa nova consulta
   o:TableStruct("SXB" ,{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"           ,"XB_DESCSPA"          ,"XB_DESCENG"          ,"XB_CONTEM"                 })
   o:DelTableData("SXB",{"EYY"     ,"1"      ,"01"    ,"DB"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"1"      ,"01"    ,"RE"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"2"      ,"01"    ,"01"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"01"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"02"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"03"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"4"      ,"01"    ,"04"       ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"5"      ,"01"    ,""         ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"5"      ,"02"    ,""         ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"5"      ,"03"    ,""         ,""                    ,""                    ,""                    ,""                          })
   o:DelTableData("SXB",{"EYY"     ,"5"      ,"04"    ,""         ,""                    ,""                    ,""                    ,""                          })
   //Restaura a antiga consulta
   o:TableStruct("SXB" ,{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"              ,"XB_DESCSPA"            ,"XB_DESCENG"            ,"XB_CONTEM"                })
   o:TableData("SXB"   ,{"EYY"     ,"1"      ,"01"    ,"DB"       ,"N.F.s de Entrada"       ,"Fact. de Entrada"      ,"Receipt Invoices"      ,"SF1"                      })
   o:TableData("SXB"   ,{"EYY"     ,"2"      ,"01"    ,"01"       ,"Numero + Serie + For"   ,"Numero + Serie + Pro"  ,"Number+Series+Sup."    ,""                         })
   o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"01"       ,"Número"                 ,"Numero"                ,"Number"                ,"F1_DOC"                   })
   o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"02"       ,"Serie"                  ,"Serie"                 ,"Series"                ,"F1_SERIE"                 })
   o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"03"       ,"Fornecedor"             ,"Proveedor"             ,"Supplier"              ,"F1_FORNECE"               })
   o:TableData("SXB"   ,{"EYY"     ,"4"      ,"01"    ,"04"       ,"Loja"                   ,"Tienda"                ,"Unit"                  ,"F1_LOJA"                  })
   o:TableData("SXB"   ,{"EYY"     ,"5"      ,"01"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_DOC"              })
   o:TableData("SXB"   ,{"EYY"     ,"5"      ,"02"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_SERIE"            })
   o:TableData("SXB"   ,{"EYY"     ,"5"      ,"03"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_FORNECE"          })
   o:TableData("SXB"   ,{"EYY"     ,"5"      ,"04"    ,""         ,""                       ,""                      ,""                      ,"SF1->F1_LOJA"             })

Else
   //Limpa a antiga consulta
   o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA"}, 1)
   o:DelTableData("SXB" ,{"EYY"     ,"1"      ,"01"    ,"DB"       })
   o:DelTableData("SXB" ,{"EYY"     ,"2"      ,"01"    ,"01"       })
   o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"01"       })
   o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"02"       })
   o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"03"       })
   o:DelTableData("SXB" ,{"EYY"     ,"4"      ,"01"    ,"04"       })
   o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"01"    ,""         })
   o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"02"    ,""         })
   o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"03"    ,""         })
   o:DelTableData("SXB" ,{"EYY"     ,"5"      ,"04"    ,""         })
   //Implementa a nova consulta
   o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"    ,"XB_DESCSPA"    ,"XB_DESCENG" ,"XB_CONTEM"              ,"XB_WCONTEM"})
   o:TableData(  "SXB",{"EYY"     ,"1"      ,"01"    ,"RE"       ,"N.F.s de Entrada","Fact de entrada" ,"Inbound Invoices","SD1"            ,            })
   o:TableData(  "SXB",{"EYY"     ,"2"      ,"01"    ,"01"       ,""                ,""                ,""                ,"AE110SD1F3()"   ,            })
   o:TableData(  "SXB",{"EYY"     ,"5"      ,"01"    ,""         ,""                ,""                ,""                ,"SD1->D1_DOC"    ,            })
   o:TableData(  "SXB",{"EYY"     ,"5"      ,"02"    ,""         ,""                ,""                ,""                ,"SD1->D1_SERIE"  ,            })
   o:TableData(  "SXB",{"EYY"     ,"5"      ,"03"    ,""         ,""                ,""                ,""                ,"SD1->D1_FORNECE",            })
   o:TableData(  "SXB",{"EYY"     ,"5"      ,"04"    ,""         ,""                ,""                ,""                ,"SD1->D1_LOJA"   ,            })

   o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_USADO"    },2)
   o:TableData  ("SX3",{"EYY_SEQEMB" ,TODOS_MODULOS })
   o:TableData  ("SX3",{"EYY_D1ITEM" ,TODOS_MODULOS })
   o:TableData  ("SX3",{"EYY_D1PROD" ,TODOS_MODULOS })
   o:TableData  ("SX3",{"EYY_QUANT"  ,TODOS_MODULOS })
EndIf */

//WHRS-08/02/17 TE-4717 505045 / MTRADE-503 - Não está gravando os preços por container na tabela do armador.(Prometido 13/02)
o:TableStruct('SX3' ,{'X3_CAMPO'   ,'X3_GRPSXG'},2)
o:TableData  ('SX3' ,{'EWU_ARMADO' ,"001" })
o:TableData  ('SX3' ,{'EWV_ARMADO' ,"001" })

//MFR - 08/02/2017
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_USADO", "X3_RESERV"},2)
o:TableData  ("SX3"  ,{"EE8_TES"   ,TODOS_MODULOS, USO+OBRIGAT})
o:TableData  ("SX3"  ,{"EE8_CF"   , TODOS_MODULOS, USO+OBRIGAT})


o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                     ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                                        ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2"                           ,"X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"},1)
o:TableData("SX6"  ,{"  "       ,"MV_EEC0052" ,"N"      ,"Configura como será calculado peso bruto da NFS",""          ,""          ,"sem considerar quebra por lote 1-Por Item da NF" ,            ,            ,"2-Por Nota Fiscal 3-Por Item pedido",""          ,""          ,"1"          ,            ,            ,"S"        ,"S"      ,""        , ""       , ""         , ""         , ""         })

n0052 := EasyGParam("MV_EEC0052",,1)
if empty(n0052) 
	SetMV("MV_EEC0052","1")
endif    

//WHRS - 31/03/2017 TE-4966 507485 / 506246 / MTRADE-607 - Cotação de moedas
o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                      ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                      ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"},1)
o:TableData("SX6"  ,{"  "       ,"MV_EEC0055" ,"C"      ,"Sincronizar a cotação de moedas entre os módulos",""          ,""          ,"SIGAEEC e SIGAFIN. S=Sim N=Não",            ,            ,""        ,""          ,""          ,""          ,            ,            ,"S"        ,"S"      ,""        , ""       , ""         , ""         , ""         })

//THTS - 20/04/2017 - TE-5386 512356 / MTRADE-781 - Erro ao excluir cotacao de moedas
o:TableStruct("SX9",{"X9_DOM","X9_IDENT"  ,"X9_CDOM" ,"X9_EXPDOM"			,"X9_EXPCDOM"      		,"X9_PROPRI","X9_LIGDOM","X9_LIGCDOM","X9_CONDSQL","X9_USEFIL","X9_ENABLE"	,"X9_VINFIL"	,"X9_CHVFOR"},2)
o:TableData(  "SX9",{"SYE"   ,"004"       ,"SWB"     ,"YE_DATA+YE_MOEDA"	,"WB_DT_CONT+WB_MOEDA"	,"S"        ,"1"        ,"N"         ,""          ,""         ,"S"		  		,"2"		  	,"2"})

o:TableStruct("SX5",{"X5_FILIAL"   ,"X5_TABELA","X5_CHAVE","X5_DESCRI"})
o:TableData(  "SX5",{xFilial("SX5"),"ZY"       ,"EFF"     ,"FINANCING"})

//NCF - 19/06/2017 - TE-5909
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM"    },2)
o:TableData  ("SX3",{"EE7_CONSIG" ,"40"          })
o:TableData  ("SX3",{"EE7_COLOJA" ,"41"          })
o:TableData  ("SX3",{"EE7_CONSDE" ,"42"          })

//THTS - 27/06/2017 - TE6014
o:TableStruct("HELP" ,{"NOME"       ,"PROBLEMA"   ,"SOLUCAO"})
o:TableData  ("HELP" ,{"EECFATCP01" ,"Esta rotina só poderá ser utilizada com ambientes integrados ao faturamento do  Protheus (MV_EECFAT)."    ,"Para utilizar a rotina, habilite o parâmetro MV_EECFAT."  })

//Status da Due
AtuStatusDUE()
Return Nil


/*
Funcao                     : UPDEEC016
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      : Wanderson Reliquias WHRS
Data/Hora   			      : 12/05/2017
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEEC016(o)
Local aOrd := {}

/*WHRS     TE-5406 508979 / MTRADE-674 /1000 - Ao selecionar o item da invoice, não apresenta o preço unitário e número do pedido*/

o:TableStruct( 'SX3',{'X3_CAMPO','X3_RELACAO'                                                                       },2)
//o:TableData('SX3',{cEXRCampo  ,'IF(TYPE("M->"+SX3->X3_CAMPO)<>"U",&("M->"+SX3->X3_CAMPO),SPACE(SX3->X3_TAMANHO))' })
o:TableData('SX3',{"EXR_PEDIDO" ,"IIF(IsMemVar('M->EXR_PEDIDO'),M->EXR_PEDIDO,'')" }) 
o:TableData('SX3',{"EXR_COD_I"  ,"IIF(IsMemVar('M->EXR_COD_I') ,M->EXR_COD_I ,'')" })
o:TableData('SX3',{"EXR_FORN "  ,"IIF(IsMemVar('M->EXR_FORN')  ,M->EXR_FORN  ,'')" })
o:TableData('SX3',{"EXR_FOLOJA" ,"IIF(IsMemVar('M->EXR_FOLOJA'),M->EXR_FOLOJA,'')" })
o:TableData('SX3',{"EXR_FABR"   ,"IIF(IsMemVar('M->EXR_FABR')  ,M->EXR_FABR  ,'')" })
o:TableData('SX3',{"EXR_FALOJA" ,"IIF(IsMemVar('M->EXR_FALOJA'),M->EXR_FALOJA,'')" })
o:TableData('SX3',{"EXR_PRECO"  ,"IIF(IsMemVar('M->EXR_PRECO') ,M->EXR_PRECO ,'')" })
o:TableData('SX3',{"EXR_PSLQUN" ,"IIF(IsMemVar('M->EXR_PSLQUN'),M->EXR_PSLQUN,'')" })
o:TableData('SX3',{"EXR_PSBRUN" ,"IIF(IsMemVar('M->EXR_PSBRUN'),M->EXR_PSBRUN,'')" })
o:TableData('SX3',{"EXR_LC_NUM" ,"IIF(IsMemVar('M->EXR_LC_NUM'),M->EXR_LC_NUM,'')" })

//LRS - 19/05/2017
 o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_USADO"    },2)
 o:TableData  ("SX3",{"EEQ_IMLOJA" ,TODOS_MODULOS })

//Status da Due
AtuStatusDUE()

//LRS - 09/08/2017
o:TableStruct("SX7",{'X7_CAMPO' ,'X7_SEQUENC','X7_REGRA'                                                ,'X7_CDOMIN','X7_CONDIC'          })
o:TableData  ('SX7',{'EEQ_TX'   ,'001'       ,"M->EEQ_TX*IF(Type('nTotFFC')='N',nTotFFC,M->EEQ_VLFCAM)" ,'EEQ_EQVL' ,'TYPE("LISEMB")<>"L" .OR. LISEMB' })
o:DelTableData  ('SX7',{'EEQ_TX'   ,'002'       ,"M->EEQ_TX*M->EEQ_VLFCAM"                                 ,'EEQ_EQVL' ,'' })

// EJA - 09/08/2017
o:TableStruct("SX3",{"X3_CAMPO" ,"X3_PICTURE" },2)
o:TableData("SX3"  ,{"EXL_DPFR" ,"@E 999"     })
o:TableData("SX3"  ,{"EXL_DPSE" ,"@E 999"     })
o:TableData("SX3"  ,{"EXL_DPFA" ,"@E 999"     })
o:TableData("SX3"  ,{"EXL_DPDI" ,"@E 999"     })

o:TableData("SX3"  ,{"EXL_EMFR" ,"@!"         })
o:TableData("SX3"  ,{"EXL_EMSE" ,"@!"         })
o:TableData("SX3"  ,{"EXL_EMFA" ,"@!"         })
o:TableData("SX3"  ,{"EXL_EMDI" ,"@!"         })

Return nil


/*
Funcao                     : UPDEEC017
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			   : Lucas Raminelli
Data/Hora   			   : 28/07/2017
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEEC017(o)

/* THTS 0- 16/10/2017 - NOPADO - TE-7258 - Conforme orientacao da Engenharia Totvs, pois nao pode criar novos grupos SXG via RUP, 
   pois implica em mudanca no modelo de dados, resultando erro na migração de release.

o:TableStruct("SXG",{"XG_GRUPO", "XG_DESCRI"            , "XG_DESSPA", "XG_DESENG", "XG_SIZEMAX", "XG_SIZEMIN", "XG_SIZE", "XG_PICTURE"})
o:TableData  ("SXG",{"128"     , "Parcelas de câmbio"   ,            ,            , "7"         , "1"         , "2"      , "@!"        })
*/

Local aDados := {}

//LRS - 28/07/2017 - Parametros DU-E
o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                        ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                                           ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"})
o:TableData("SX6"  ,{""         ,"MV_EEC0053" ,"L"      ,"Define se utiliza a Declaracao Unica de Exportacao",""          ,""          ,""                                                   ,            ,            ,""        ,""          ,""          ,".T."       ,            ,            ,"S"        ,"S"      ,""        , ""       , ""         , ""         , ""         })
o:TableData("SX6"  ,{""         ,"MV_EEC0054" ,"N"      ,"Integrador deve efetuar integracao com a          ",""          ,""          ,"base de Testes (1) ou com a base de Producao (2)  " ,            ,            ,""        ,""          ,""          ,"1"         ,            ,            ,"S"        ,"S"      ,""        , ""       , ""         , ""         , ""         })

//LRS - 14/09/2017
o:TableStruct('SX2',{'X2_CHAVE','X2_UNICO'                                                                     })
o:TableData  ('SX2',{"EEJ"     ,'EEJ_FILIAL+EEJ_PEDIDO+EEJ_OCORRE+EEJ_TIPOBC+EEJ_CODIGO+EEJ_AGENCI+EEJ_NUMCON' }) //LRS - 14/09/2017

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2) 
o:TableData  ("SX3",{"EE7_BENEF"  ,"43"       })
o:TableData  ("SX3",{"EE7_BELOJA" ,"44"       })

o:TableStruct("SX7",{'X7_CAMPO'   ,'X7_SEQUENC','X7_REGRA'      },1)
o:TableData  ('SX7',{'EE7_BELOJA' ,'002'       ,'IF(!EMPTY(M->EE7_BENEF),EECMEND("SA2",1,M->EE7_BENEF+M->EE7_BELOJA,.T.,AvSx3("EE7_ENDBEN",3),1),"")' })

// MPG - MTRADE-1519-13/12/2017
o:TableStruct("SX7",{'X7_CAMPO'   ,'X7_SEQUENC'  , 'X7_REGRA'              ,'X7_CDOMIN'  ,'X7_TIPO' ,'X7_SEEK'  ,'X7_ALIAS' , 'X7_ORDEM' , 'X7_CHAVE' , 'X7_CONDIC'        ,'X7_PROPRI'},1)
o:TableData  ("SX7",{"EEQ_DESCON" ,"003"         ,"M->EEQ_VL-M->EEQ_DESCON",'EEQ_VLFCAM' ,'P'       ,'N'        ,           ,            ,            ,'!lFinanciamento'   ,"S"        }  )

o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"  ,"X3_TAMANHO"})
o:TableData(  "SX3",{"EEX"       ,"EEX_TIPOPX","2"         })
o:TableData(  "SX3",{"EEX"       ,"EEX_DETOPX","2"         })
o:TableData(  "SX3",{"EEX"       ,"EEX_SDETOP","2"         })

// EJA - 21/09/2017
o:TableStruct("SX3", {"X3_CAMPO",   "X3_USADO"}, 2)
o:TableData(  "SX3" ,{"EEQ_NRINVO", TODOS_MODULOS})
o:TableData(  "SX3" ,{"EE3_SEQ"   , TODOS_AVG})
o:TableData(  "SX3" ,{"A1_NATUREZ", TODOS_MODULOS})
o:TableData(  "SX3" ,{"A2_NATUREZ", TODOS_MODULOS})

//LRS - 06/03/2018
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2) 
o:TableData  ("SX3",{"EE7_FORN"   ,"33"       })
o:TableData  ("SX3",{"EE7_FOLOJA" ,"34"       })

//LRS - 20/10/2017 - Carga Pagrão EYG Retirado do EECAE100
If ChkFile("EYG") .And. !EYG->(DBSeek(xFilial() + "22B0"))
    o:TableStruct('EYG',{'EYG_CODCON','EYG_DESCON','EYG_COMCON','EYG_ALTCON'},1)
    o:TableData('EYG',{'22B0','20 Bulk                                                     ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22P3','20 Collapsible Flat Rack                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22P1','20 Flat Rack                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2510','20 HIGH CUBE                                                ',              20,              9.5},,.F.)
    o:TableData('EYG',{'22UP','20 Hard Top                                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'25GP','20 High Cube                                                ',              20,              9.6},,.F.)
    o:TableData('EYG',{'22H0','20 Insulated (Conair)                                       ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2551','20 OPEN TOP HIGHCUBE                                        ',              20,              9.5},,.F.)
    o:TableData('EYG',{'22U1','20 Open Top                                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'29P0','20 Platform                                                 ',              20,              1},,.F.)
    o:TableData('EYG',{'22R1','20 Reefer                                                   ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22G0','20 Standard Dry                                             ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T0','20 Tank                                                     ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22VH','20 Ventilated                                               ',              20,              8.5},,.F.)
    o:TableData('EYG',{'42P3','40 Collapsible Flat Rack                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P1','40 Flat Rack                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4563','40 Flat Rack                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4205','40 General Purpose (Hanging Garments)                       ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4534','40 HIGHCUBE INTEGRATED REEFER                               ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45G0','40 High Cube                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45GP','40 High Cube                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45U6','40 High Cube Hard Top                                       ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45UP','40 High Cube Hard Top                                       ',              40,              9.5},,.F.)
    o:TableData('EYG',{'42H0','40 Insulated (Conair)                                       ',              40,              8.5},,.F.)
    o:TableData('EYG',{'45U0','40 OPENTOP HIGH CUBE                                        ',              40,              9.6},,.F.)
    o:TableData('EYG',{'49P0','40 Platform                                                 ',              40,              4},,.F.)
    o:TableData('EYG',{'42R1','40 Reefer                                                   ',              40,              8.5},,.F.)
    o:TableData('EYG',{'45R1','40 Reefer High Cube                                         ',              40,              9.5},,.F.)
    o:TableData('EYG',{'42G0','40 Standard Dry                                             ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42VH','40 Ventilated                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'L5G1','45 High Cube                                                ',              45,              9},,.F.)
    o:TableData('EYG',{'L5R1','45 Reefer High Cube                                         ',              45,              9.5},,.F.)
    o:TableData('EYG',{'2994','Air/Surface                                                 ',              20,              4},,.F.)
    o:TableData('EYG',{'4599','Air/Surface                                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'4595','Air/Surface                                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4699','Air/Surface                                                 ',              40,              4.25},,.F.)
    o:TableData('EYG',{'8599','Air/Surface                                                 ',              35,              8.5},,.F.)
    o:TableData('EYG',{'9998','Air/Surface                                                 ',              40,              4},,.F.)
    o:TableData('EYG',{'4096','Air/Surface                                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'2299','Air/Surface                                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'9999','Air/Surface                                                 ',              40,              4},,.F.)
    o:TableData('EYG',{'9995','Air/Surface                                                 ',              40,              4},,.F.)
    o:TableData('EYG',{'4994','Air/Surface                                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4326','Automobile Carrier                                          ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4426','Automobile Carrier                                          ',              40,              9},,.F.)
    o:TableData('EYG',{'4226','Automobile Carrier                                          ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4026','Automobile Carrier                                          ',              40,              8},,.F.)
    o:TableData('EYG',{'4126','Automobile Carrier                                          ',              40,              8},,.F.)
    o:TableData('EYG',{'28U1','BIN HALF HEIGHT (OPEN TOP)                                  ',              20,              4.25},,.F.)
    o:TableData('EYG',{'22V0','Closed Vented                                               ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22V2','Closed Vented                                               ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22V4','Closed Vented                                               ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20VH','Closed Vented                                               ',              20,              8},,.F.)
    o:TableData('EYG',{'20V4','Closed Vented                                               ',              20,              8},,.F.)
    o:TableData('EYG',{'20V2','Closed Vented                                               ',              20,              8},,.F.)
    o:TableData('EYG',{'20V0','Closed Vented                                               ',              20,              8},,.F.)
    o:TableData('EYG',{'2011','Closed Vented                                               ',              20,              8},,.F.)
    o:TableData('EYG',{'2010','Closed Vented                                               ',              20,              8},,.F.)
    o:TableData('EYG',{'4311','Closed Vented                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42V4','Closed Vented                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4211','Closed Vented                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4210','Closed Vented                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'40VH','Closed Vented                                               ',              40,              8},,.F.)
    o:TableData('EYG',{'40V4','Closed Vented                                               ',              40,              8},,.F.)
    o:TableData('EYG',{'40V2','Closed Vented                                               ',              40,              8},,.F.)
    o:TableData('EYG',{'40V0','Closed Vented                                               ',              40,              8},,.F.)
    o:TableData('EYG',{'4011','Closed Vented                                               ',              40,              8},,.F.)
    o:TableData('EYG',{'4010','Closed Vented                                               ',              40,              8},,.F.)
    o:TableData('EYG',{'2211','Closed Vented                                               ',              20,              8.5},,.F.)
    o:TableData('EYG',{'42V2','Closed Vented                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42V0','Closed Vented                                               ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4315','Closed Ventilated                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2013','Closed Ventilated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'2215','Closed Ventilated                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4215','Closed Ventilated                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4015','Closed Ventilated                                           ',              40,              8},,.F.)
    o:TableData('EYG',{'2217','Closed Ventilated                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2216','Closed Ventilated                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2117','Closed Ventilated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'2113','Closed Ventilated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'2017','Closed Ventilated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'2015','Closed Ventilated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'30G0','DRY CARGO/GENERAL PURPOSE                                   ',              30,              8},,.F.)
    o:TableData('EYG',{'10G0','DRY CARGO/GENERAL PURPOSE                                   ',              10,              8},,.F.)
    o:TableData('EYG',{'12G0','DRY CARGO/GENERAL PURPOSE                                   ',              10,              8.5},,.F.)
    o:TableData('EYG',{'32G0','DRY CARGO/GENERAL PURPOSE                                   ',              30,              8.5},,.F.)
    o:TableData('EYG',{'4319','DV Closed containers Ventilated, Spare                      ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2219','DV Closed containers Ventilated, Spare                      ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22B1','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22B3','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22B4','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22B5','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22B6','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22BK','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'40B3','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40B1','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40B0','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4080','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'2281','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2280','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20BU','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20BK','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20B6','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'42BU','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42BK','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42B6','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42B5','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42B4','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42B3','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42B1','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42B0','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4280','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'40BU','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40BK','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40B6','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40B5','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40B4','Dry Bulk                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'22BU','Dry Bulk                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20B5','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20B4','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20B3','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20B1','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20B0','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2080','Dry Bulk                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'4886','Dry Bulk                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'4380','Dry Bulk                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'45P3','FOLDING COMPLETE END STRUCTURE (PLATFORM)                   ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45PC','FOLDING COMPLETE END STRUCTURE (PLATFORM)                   ',              40,              9.5},,.F.)
    o:TableData('EYG',{'4361','Flat                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4363','Flat                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2160','Flat                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2063','Flat                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2260','Flat                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2263','Flat                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4260','Flat                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4360','Flat                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4263','Flat                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4060','Flat                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'2261','Flat                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4999','GOOSENECK CHASSIS                                           ',              40,             0},,.F.)
    o:TableData('EYG',{'42G4','General Purose (Hanging Garments)                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4312','General Purpose (Hanging Garments)                          ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2212','General Purpose (Hanging Garments)                          ',              20,              8.5},,.F.)
    o:TableData('EYG',{'48UI','HALF HEIGHT (OPEN TOP)                                      ',              40,              4.25},,.F.)
    o:TableData('EYG',{'2870','HALF HEIGHT THERMAL TANK                                    ',              20,             0},,.F.)
    o:TableData('EYG',{'4651','HALF HIGH                                                   ',              40,             0},,.F.)
    o:TableData('EYG',{'2851','HALF OPEN TOP                                               ',              20,             0},,.F.)
    o:TableData('EYG',{'2410','HIGH CUBE                                                   ',              20,              9.5},,.F.)
    o:TableData('EYG',{'4410','HIGH CUBE                                                   ',              40,              9.5},,.F.)
    o:TableData('EYG',{'4514','HIGH CUBE                                                   ',              40,              9.5},,.F.)
    o:TableData('EYG',{'L0GP','HL: OPENING(S) AT ONE END OR BOTH ENDS                      ',              45,              8},,.F.)
    o:TableData('EYG',{'2224','Insulated                                                   ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4224','Insulated                                                   ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4325','Livestock Carrier                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4225','Livestock Carrier                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4025','Livestock Carrier                                           ',              40,              8},,.F.)
    o:TableData('EYG',{'2125','Livestock Carrier                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'2225','Livestock Carrier                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2025','Livestock Carrier                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'4551','OPEN TOP HIGHCUBE                                           ',              40,              9.5},,.F.)
    o:TableData('EYG',{'M2G0','OPENING(S) AT ONE END OR BOTH ENDS                          ',              48,              8.5},,.F.)
    o:TableData('EYG',{'4CG0','OPENING(S) AT ONE OR BOTH ENDS                              ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4CGP','OPENING(S) AT ONE OR BOTH ENDS                              ',              40,              8.5},,.F.)
    o:TableData('EYG',{'28U2','OPENING(S) AT ONE OR BOTH ENDS, PLUS REMV TOP MEMB          ',              20,              8.5},,.F.)
    o:TableData('EYG',{'28UT','OPENING(S) AT ONE OR BOTH ENDS, PLUS REMV TOP MEMB          ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22U2','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22U3','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22U4','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2053','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2052','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2051','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2050','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'4750','Open Top                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'4650','Open Top                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'4351','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4350','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U5','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U4','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U3','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U2','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2650','Open Top                                                    ',             0,              4.25},,.F.)
    o:TableData('EYG',{'2253','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2252','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2251','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2250','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2150','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20UT','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20U5','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20U4','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20U3','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'40U2','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40U1','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40U0','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4053','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4052','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4051','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4050','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'22U0','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2259','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22UT','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'42UT','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U0','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P6','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4253','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4252','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4251','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4250','Open Top                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'40UT','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40U5','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40U4','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40U3','Open Top                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'20U2','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20U1','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20U0','Open Top                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'4751','Open Top                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'2750','Open Top                                                    ',              20,              4.25},,.F.)
    o:TableData('EYG',{'2651','Open Top                                                    ',              20,              4.25},,.F.)
    o:TableData('EYG',{'22U5','Open Top                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'48U0','Open top                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'8550','Open top                                                    ',              35,              8.5},,.F.)
    o:TableData('EYG',{'48UT','Open top                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'B2G1','PASSIVE VENTS AT UPPER PART OF CARGO SPACE                  ',              24,              8.5},,.F.)
    o:TableData('EYG',{'4CG1','PASSIVE VENTS AT UPPER PART OF CARGO SPACE                  ',              40,              8.5},,.F.)
    o:TableData('EYG',{'29P1','PLATFORM (CONTAINER)                                        ',              20,              4},,.F.)
    o:TableData('EYG',{'29PL','PLATFORM (CONTAINER)                                        ',              20,              1},,.F.)
    o:TableData('EYG',{'22P7','PLATFORM FIXED                                              ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22P2','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2361','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2363','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4561','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4560','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4367','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P4','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P2','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2761','Platform                                                    ',              20,              4.25},,.F.)
    o:TableData('EYG',{'2661','Platform                                                    ',              20,              4.25},,.F.)
    o:TableData('EYG',{'2367','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2366','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2365','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2364','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2362','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'40P0','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4067','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4066','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4065','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4064','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4063','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4062','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4061','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'2969','Platform                                                    ',              20,              4},,.F.)
    o:TableData('EYG',{'42PF','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'49PL','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'22PC','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'42PC','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'22PF','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4960','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'48P0','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'45P8','Platform                                                    ',              40,              9.5},,.F.)
    o:TableData('EYG',{'42P0','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4267','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4266','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4265','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4264','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4262','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4261','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4167','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4166','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4165','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4164','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4163','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4162','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'4161','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40PS','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40PL','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40PF','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40PC','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40P5','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40P4','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40P3','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40P2','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'40P1','Platform                                                    ',              40,              8},,.F.)
    o:TableData('EYG',{'2960','Platform                                                    ',              20,              4},,.F.)
    o:TableData('EYG',{'2760','Platform                                                    ',              20,              4.25},,.F.)
    o:TableData('EYG',{'22P0','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2267','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2266','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2265','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2264','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2262','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2167','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2166','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2165','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2164','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2163','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2162','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2161','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20P2','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20P1','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20P0','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'49PF','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'49PC','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'49P5','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'49P3','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'49P1','Platform                                                    ',              40,              4},,.F.)
    o:TableData('EYG',{'4366','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'20PS','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20PL','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20PF','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20PC','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20P5','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20P4','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'20P3','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'4365','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4364','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4362','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42PS','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42PL','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P9','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P8','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42P5','Platform                                                    ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2067','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2066','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2065','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2064','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2062','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2061','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'2060','Platform                                                    ',              20,              8},,.F.)
    o:TableData('EYG',{'48PL','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'48PF','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'48PC','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'48P5','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'48P3','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'48P1','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'4761','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'4661','Platform                                                    ',              40,              4.25},,.F.)
    o:TableData('EYG',{'22P4','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22PL','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22PS','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22P9','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22P8','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22P5','Platform                                                    ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2999','SLIDER CHASSIS                                              ',              20,             0},,.F.)
    o:TableData('EYG',{'7999','SLIDER CHASSIS                                              ',              20,             0},,.F.)
    o:TableData('EYG',{'22G1','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'24GP','Standard Dry                                                ',              20,              9},,.F.)
    o:TableData('EYG',{'24G3','Standard Dry                                                ',              20,              9},,.F.)
    o:TableData('EYG',{'24G2','Standard Dry                                                ',              20,              9},,.F.)
    o:TableData('EYG',{'24G1','Standard Dry                                                ',              20,              9},,.F.)
    o:TableData('EYG',{'24G0','Standard Dry                                                ',              20,              9},,.F.)
    o:TableData('EYG',{'2304','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2303','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2302','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2301','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2300','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22V3','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22U6','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'L2GP','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2G9','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2G3','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2G2','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2G1','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2G0','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L0G9','Standard Dry                                                ',              45,              8},,.F.)
    o:TableData('EYG',{'4511','Standard Dry                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'4510','Standard Dry                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'4505','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4500','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4400','Standard Dry                                                ',              40,              9},,.F.)
    o:TableData('EYG',{'4204','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4203','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4202','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4201','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4200','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4104','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4103','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4102','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4101','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'40GP','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'40G3','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'40G2','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'40G1','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'40G0','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4004','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4003','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4002','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4001','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'4000','Standard Dry                                                ',              40,              8},,.F.)
    o:TableData('EYG',{'2213','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2210','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2205','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2204','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2203','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2202','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2201','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2200','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2104','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2103','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2102','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2101','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'20GP','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'20G3','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'20G2','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'20G1','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'20G0','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2004','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2003','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2002','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2001','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'2000','Standard Dry                                                ',              20,              8},,.F.)
    o:TableData('EYG',{'1200','Standard Dry                                                ',              10,              8.5},,.F.)
    o:TableData('EYG',{'1000','Standard Dry                                                ',              10,              8},,.F.)
    o:TableData('EYG',{'L5G9','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5G3','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5G2','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'9510','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'9500','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'9400','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'9200','Standard Dry                                                ',              45,              8.5},,.F.)
    o:TableData('EYG',{'8500','Standard Dry                                                ',              35,              8.5},,.F.)
    o:TableData('EYG',{'45G3','Standard Dry                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45G2','Standard Dry                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45G1','Standard Dry                                                ',              40,              9.5},,.F.)
    o:TableData('EYG',{'44GP','Standard Dry                                                ',              40,              9},,.F.)
    o:TableData('EYG',{'44G3','Standard Dry                                                ',              40,              9},,.F.)
    o:TableData('EYG',{'44G2','Standard Dry                                                ',              40,              9},,.F.)
    o:TableData('EYG',{'44G1','Standard Dry                                                ',              40,              9},,.F.)
    o:TableData('EYG',{'44G0','Standard Dry                                                ',              40,              9},,.F.)
    o:TableData('EYG',{'4310','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4305','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4304','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4303','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4302','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4301','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4300','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U6','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42G3','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42G2','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42G1','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'3200','Standard Dry                                                ',              30,              8.5},,.F.)
    o:TableData('EYG',{'3000','Standard Dry                                                ',              30,              8},,.F.)
    o:TableData('EYG',{'28G0','Standard Dry                                                ',              20,              4.25},,.F.)
    o:TableData('EYG',{'26GP','Standard Dry                                                ',              20,              9.5},,.F.)
    o:TableData('EYG',{'26G3','Standard Dry                                                ',              20,              9.5},,.F.)
    o:TableData('EYG',{'26G2','Standard Dry                                                ',              20,              9.5},,.F.)
    o:TableData('EYG',{'26G1','Standard Dry                                                ',              20,              9.5},,.F.)
    o:TableData('EYG',{'26G0','Standard Dry                                                ',              20,              9.5},,.F.)
    o:TableData('EYG',{'2600','Standard Dry                                                ',              20,              4.25},,.F.)
    o:TableData('EYG',{'2500','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22G2','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'L5GP','Standard Dry                                                ',              45,              9.5},,.F.)
    o:TableData('EYG',{'42GP','Standard Dry                                                ',              40,              8.5},,.F.)
    o:TableData('EYG',{'22GP','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'L5G0','Standard Dry                                                ',              45,              9},,.F.)
    o:TableData('EYG',{'28GP','Standard Dry                                                ',              20,              4.25},,.F.)
    o:TableData('EYG',{'22G3','Standard Dry                                                ',              20,              8.5},,.F.)
    o:TableData('EYG',{'25G0','Standard Dry High Cube                                      ',              20,              9},,.F.)
    o:TableData('EYG',{'2530','THERMAL CNTR,REFRIGERATED,EXPENDABLE REFRIGANT              ',              20,              8.5},,.F.)
    o:TableData('EYG',{'3399','TRIAXLE CHASSIS                                             ',              23,             0},,.F.)
    o:TableData('EYG',{'22T1','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T2','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T4','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T6','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T8','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22TD','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2072','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2071','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2070','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'8770','Tank                                                        ',              35,              4.25},,.F.)
    o:TableData('EYG',{'42TG','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42TD','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T9','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T8','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T7','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'20T1','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T0','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2079','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2078','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2077','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2076','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2075','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2074','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2073','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2275','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2274','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2273','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2272','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2271','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2270','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20TN','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20TG','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20TD','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'40TD','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T9','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T8','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T7','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T6','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T5','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T4','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T3','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T2','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'42TN','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'22TN','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4271','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4270','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4170','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40TN','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40TG','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T1','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40T0','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'4071','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'4070','Tank                                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'2279','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2278','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2277','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2276','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20T9','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T8','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T7','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T6','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T5','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T4','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T3','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20T2','Tank                                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'42T6','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T5','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T4','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T3','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T2','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42T1','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2771','Tank                                                        ',              20,              4.25},,.F.)
    o:TableData('EYG',{'2770','Tank                                                        ',              20,              4.25},,.F.)
    o:TableData('EYG',{'4370','Tank                                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2671','Tank                                                        ',              20,              4.25},,.F.)
    o:TableData('EYG',{'2670','Tank                                                        ',              20,              4.25},,.F.)
    o:TableData('EYG',{'22TG','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T9','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T7','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T5','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22T3','Tank                                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22H5','Thermal Insulated                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4420','Thermal Insulated                                           ',              40,              9},,.F.)
    o:TableData('EYG',{'40H6','Thermal Insulated                                           ',              40,              8},,.F.)
    o:TableData('EYG',{'40H5','Thermal Insulated                                           ',              40,              8},,.F.)
    o:TableData('EYG',{'4020','Thermal Insulated                                           ',              40,              8},,.F.)
    o:TableData('EYG',{'2220','Thermal Insulated                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20H6','Thermal Insulated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'20H5','Thermal Insulated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'2020','Thermal Insulated                                           ',              20,              8},,.F.)
    o:TableData('EYG',{'L5H6','Thermal Insulated                                           ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5H5','Thermal Insulated                                           ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L2H6','Thermal Insulated                                           ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2H5','Thermal Insulated                                           ',              45,              8.5},,.F.)
    o:TableData('EYG',{'44H6','Thermal Insulated                                           ',              40,              9},,.F.)
    o:TableData('EYG',{'44H5','Thermal Insulated                                           ',              40,              9},,.F.)
    o:TableData('EYG',{'4320','Thermal Insulated                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42H6','Thermal Insulated                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42H5','Thermal Insulated                                           ',              40,              8.5},,.F.)
    o:TableData('EYG',{'24H6','Thermal Insulated                                           ',              20,              9},,.F.)
    o:TableData('EYG',{'22H6','Thermal Insulated                                           ',              20,              8.5},,.F.)
    o:TableData('EYG',{'24H5','Thermal Insulated                                           ',              20,              9},,.F.)
    o:TableData('EYG',{'8520','Thermal Insulated                                           ',              35,              8.5},,.F.)
    o:TableData('EYG',{'45H6','Thermal Insulated                                           ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45H5','Thermal Insulated                                           ',              45,              9.5},,.F.)
    o:TableData('EYG',{'22RE','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'24RE','Thermal Refrigerated                                        ',              20,              9},,.F.)
    o:TableData('EYG',{'2331','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2030','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2040','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'4231','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4230','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4131','Thermal Refrigerated                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'4130','Thermal Refrigerated                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'40RE','Thermal Refrigerated                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'4040','Thermal Refrigerated                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'4031','Thermal Refrigerated                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'4030','Thermal Refrigerated                                        ',              40,              8},,.F.)
    o:TableData('EYG',{'2230','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4531','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4530','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'L5R0','Thermal Refrigerated                                        ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L2RE','Thermal Refrigerated                                        ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2R0','Thermal Refrigerated                                        ',              45,              8.5},,.F.)
    o:TableData('EYG',{'45RE','Thermal Refrigerated                                        ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45R9','Thermal Refrigerated                                        ',              40,              9.5},,.F.)
    o:TableData('EYG',{'4243','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4240','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2132','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2131','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2130','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20RE','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'20R0','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2043','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2042','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2041','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'2242','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2240','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2231','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2031','Thermal Refrigerated                                        ',              20,              8},,.F.)
    o:TableData('EYG',{'L5RE','Thermal Refrigerated                                        ',              45,              9.5},,.F.)
    o:TableData('EYG',{'4330','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'44RE','Thermal Refrigerated                                        ',              40,              9},,.F.)
    o:TableData('EYG',{'4340','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42RE','Thermal Refrigerated                                        ',              40,              8.5},,.F.)
    o:TableData('EYG',{'2330','Thermal Refrigerated                                        ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22H1','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'44H1','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44H0','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'4333','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4332','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'24RT','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24RS','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24R3','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24R2','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24R1','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'45H1','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45H0','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'4432','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'42R0','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42HR','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42HI','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42H2','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42H1','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4232','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42RT','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'22RT','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22HR','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'L5RT','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45RT','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45H2','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'4533','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'4532','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'L5HR','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5HI','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5H2','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5H1','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5H0','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L2RT','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2RS','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2R3','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2R2','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2R1','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2HR','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2HI','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2H2','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2H1','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'L2H0','Thermal Refrigerated/Heated                                 ',              45,              8.5},,.F.)
    o:TableData('EYG',{'9532','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45RS','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45RC','Thermal Refrigerated/Heated                                 ',              40,              9.5},,.F.)
    o:TableData('EYG',{'45R3','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45R2','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45R0','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45HR','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'45HI','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'4132','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40RT','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40RS','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40R3','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40R2','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40R1','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40R0','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40HR','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40HI','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40H2','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40H1','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'40H0','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'4032','Thermal Refrigerated/Heated                                 ',              40,              8},,.F.)
    o:TableData('EYG',{'22R0','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2232','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'20R3','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20R2','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20R1','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20HR','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20HI','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20H2','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20H1','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20H0','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'44RT','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'20RT','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'20RS','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'44RS','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44R3','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44R2','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44R1','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44R0','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44HR','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44HI','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'44H2','Thermal Refrigerated/Heated                                 ',              40,              9},,.F.)
    o:TableData('EYG',{'2032','Thermal Refrigerated/Heated                                 ',              20,              8},,.F.)
    o:TableData('EYG',{'L5RS','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5R3','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'L5R2','Thermal Refrigerated/Heated                                 ',              45,              9.5},,.F.)
    o:TableData('EYG',{'8532','Thermal Refrigerated/Heated                                 ',              35,              8.5},,.F.)
    o:TableData('EYG',{'24R0','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24HR','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24HI','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24H2','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24H1','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'24H0','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'2432','Thermal Refrigerated/Heated                                 ',              20,              9},,.F.)
    o:TableData('EYG',{'2332','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'42RS','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42RC','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42R9','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42R3','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42R2','Thermal Refrigerated/Heated                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'22RS','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22RC','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22R9','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22HI','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22R2','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22R3','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'22H2','Thermal Refrigerated/Heated                                 ',              20,              8.5},,.F.)
    o:TableData('EYG',{'2234','Thermal containers, Heated                                  ',              20,              8.5},,.F.)
    o:TableData('EYG',{'4535','Thermal/Heated                                              ',              40,              8.5},,.F.)
    o:TableData('EYG',{'8888','Uncontainerised                                             ',               0,                0},,.F.)
    o:TableData('EYG',{'45G4','Unrecognized container type                                 ',               0,                0},,.F.)
    o:TableData('EYG',{'4313','VENTILATED                                                  ',              40,                0},,.F.)
    o:TableData('EYG',{'28VH','Vented                                                      ',              20,              4.75},,.F.)
    o:TableData('EYG',{'28VO','Vented                                                      ',              20,              4.75},,.F.)
    o:TableData('EYG',{'22G0','20 Standard Dry                                             ',              20,              8.5},,.F.)
    o:TableData('EYG',{'42T0','40 Tank                                                     ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42U1','40 Open Top                                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'42UP','40 Hard Top                                                 ',              40,              8.5},,.F.)
    o:TableData('EYG',{'L5R1','45 Reefer High Cube                                         ',              45,              9.5},,.F.)
    o:TableData('EYG',{'42H0','40 Insulated (Conair)                                       ',              40,              8.5},,.F.)
EndIf

// EJA - 13/11/2017
o:TableStruct("SX3", {"X3_CAMPO", "X3_RELACAO"}, 2)
o:TableData(  "SX3" ,{"EEC_DTREC", "if(TYpe('M->EEC_DTREC')=='D',M->EEC_DTREC,CTOD(' / / '))"})

// NCF - 23/11/2017
o:TableStruct("SX3", {"X3_CAMPO"  ,   "X3_USADO" },2)
o:TableData(  "SX3" ,{"EYY_SEQEMB", TODOS_MODULOS})
o:TableData(  "SX3" ,{"EYY_D1ITEM", TODOS_MODULOS})
o:TableData(  "SX3" ,{"EYY_D1PROD", TODOS_MODULOS})

//THTS - 08/12/2017
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_PICTURE"               },2)
o:TableData("SX3"  ,{"EG0_TEMPO" ,"@E 9,999,999.99999999"   })
o:TableData("SX3"  ,{"EG0_TDISCH","@E 9,999,999.99999999"   })
o:TableData("SX3"  ,{"EG0_TLOAD" ,"@E 9,999,999.99999999"   })

//THTS - 19/12/2017
o:TableStruct("SX3", {"X3_CAMPO", "X3_USADO" },2)
o:TableData(  "SX3" ,{"EE9_NF"  , TODOS_MODULOS})

// MPG - 16/01/2018
o:TableStruct("SX3", {"X3_CAMPO"   ,   "X3_USADO"   }, 2)
o:TableData(  "SX3" ,{"EEU_POSIC"  , TODOS_MODULOS  })

o:TableStruct("SIX",{"INDICE","ORDEM" ,"CHAVE"                                     ,"DESCRICAO"                    })
o:TableData(  "SIX",{"EEU"   ,"1"     ,"EEU_FILIAL+EEU_PREEMB+EEU_DESPES+EEU_POSIC","Embarque + Despesa + Posicao" })

o:TableStruct('SX2',{'X2_CHAVE','X2_UNICO'                                   })
o:TableData(  'SX2',{"EEU"     ,'EEU_FILIAL+EEU_PREEMB+EEU_DESPES+EEU_POSIC' })

// NCF - 15/02/2018 - Ajuste de USADO dos campos da tabela EYY (saldos de fim Específico Export.)
o:TableStruct("SX3", {"X3_CAMPO"   , "X3_USADO"    },2)
o:TableData(  "SX3" ,{"EYY_PREEMB" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_SEQEMB" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_RE"     , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_NFSAI"  , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_SERSAI" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_NFENT"  , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_SERENT" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_FORN"   , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_FOLOJA" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_DESFOR" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_PEDIDO" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_SEQUEN" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_FASE"   , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_QUANT"  , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_NROMEX" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_DTMEX"  , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_D1ITEM" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_CHVNFE" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_SQFNFS" , TODOS_MODULOS })
o:TableData(  "SX3" ,{"EYY_D1PROD" , TODOS_MODULOS })

o:TableData(  "SX3" ,{"EE9_SEQED3" , TODOS_MODULOS })

//LRS - 10/04/2018
o:TableStruct("SX3", {"X3_CAMPO"  , "X3_USADO"    , "X3_RESERV"},2)
o:TableData(  "SX3" ,{"D1_SLDEXP" , TODOS_MODULOS ,  USO })

//LRS - 09/05/2018
o:TableStruct("SX7",{'X7_CAMPO' ,'X7_SEQUENC','X7_CHAVE'})
o:TableData('SX7',{'EE7_IMPORT' ,'001'       ,'xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA' })
o:TableData('SX7',{'EE7_IMPORT' ,'010'       ,'xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA' })

//THTS - 20/06/2018
o:TableStruct("SX3", {"X3_CAMPO"  , "X3_USADO"      ,"X3_VISUAL" ,"X3_WHEN"                                                 },2)
o:TableData(  "SX3" ,{"EXL_DTDSE" , TODOS_MODULOS   ,            ,                                                          })
o:TableData(  "SX3" ,{"EEC_NRODUE",                 ,"A"         ,                                                          })
o:TableData(  "SX3" ,{"EEC_NRORUC",                 ,            ,"!EasyGParam('MV_EEC0053',,.F.) .Or. Empty(M->EEC_NRODUE)"})

//EJA - 11/07/2018
o:TableStruct("SXB",{"XB_ALIAS", "XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"       	    ,"XB_DESCSPA"      		,"XB_DESCENG"   			,"XB_CONTEM"            ,"XB_WCONTEM"})
o:TableData("SXB"  ,{ "EC6EVE" , "1"     ,"01"    ,"DB"       ,"Eventos Imp/Exp"		,""		                ,"" 		                ,"EC6"                  ,            })
o:TableData("SXB"  ,{ "EC6EVE" , "2"     ,"01"    ,"01"       ,"Tipo Modulo + Ident."   ,""                		,""             			,""                     ,            })
o:TableData("SXB"  ,{ "EC6EVE" , "4"     ,"01"    ,"01"       ,"Ident. Campo"           ,""                		,""             			,"EC6_ID_CAM"           ,            })
o:TableData("SXB"  ,{ "EC6EVE" , "4"     ,"01"    ,"02"       ,"Descricao"              ,""                		,""             			,"EC6_DESC"             ,            })
o:TableData("SXB"  ,{ "EC6EVE" , "5"     ,"01"    ,""         ,""                	    ,""                		,""             			,"EC6->EC6_ID_CAM"      ,            })
o:TableData("SXB"  ,{ "EC6EVE" , "6"     ,"01"    ,""         ,""                	    ,""                		,""             			,"EC6ImpExp()"          ,            })

o:TableStruct("SX3"  ,{"X3_CAMPO"   ,"X3_F3" },2)
o:TableData  ("SX3"  ,{"YB_EVENT"   ,"EC6EVE"})

//LRS - 13/07/2018
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2)
o:TableData(  "SX3",{"EE7_CONSIG" , 40        })
o:TableData(  "SX3",{"EE7_COLOJA" , 41        })
o:TableData(  "SX3",{"EE7_CONSDE" , 42        })

//CEO - 18/07/2018
o:TableStruct("SX3",{"X3_CAMPO", "X3_VALID"},2)
o:TableData ("SX3",{"EEM_TIPONF", "Pertence('12345') .And. If(FindFunction('NF400Valid'),NF400Valid(),.T.)"})

//LRS - 21/08/2018
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_RESERV"},2)
o:TableData("SX3"  ,{"D1_SLDEXP" ,TAM+DEC    })

// MPG - 22/08/2018
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_VALID"                                                                                                                        },2)
o:TableData("SX3"   ,{'EE7_FORN'  ,'AP100CRIT("EE7_FORN")   .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_FOLOJA','AP100CRIT("EE7_FOLOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_EXPORT','AP100CRIT("EE7_EXPORT") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_EXLOJA','AP100CRIT("EE7_EXLOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_BENEF' ,'AP100CRIT("EE7_BENEF")  .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_BELOJA','AP100CRIT("EE7_BELOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE8_FORN'  ,'AP100CRIT("EE8_FORN") .AND. AP100Crit("EE7_MARCAC")'                                                                             })
o:TableData("SX3"   ,{'EE8_FOLOJA','AP100CRIT("EE8_FOLOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE8_FABR'  ,'AP100CRIT("EE8_FABR")   .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE8_FALOJA','AP100CRIT("EE8_FALOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_IMPORT','AP100CRIT("EE7_IMPORT") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_IMLOJA','AP100CRIT("EE7_IMLOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_CLIENT','AP100CRIT("EE7_CLIENT") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_CLLOJA','AP100CRIT("EE7_CLLOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_CONSIG','AP100CRIT("EE7_CONSIG") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EE7_COLOJA','AP100CRIT("EE7_COLOJA") .AND. AP100Crit("EE7_MARCAC")'                                                                           })
o:TableData("SX3"   ,{'EEN_IMPORT','AP100CRIT("EEN_IMPORT") .And. AP100NotiExist()'                                                                                  })
o:TableData("SX3"   ,{'EEN_IMLOJA','AP100CRIT("EEN_IMLOJA") .And. AP100NotiExist()'                                                                                  })

o:TableStruct("SX7",{"X7_CAMPO"  ,"X7_SEQUENC","X7_REGRA"                                                                                            ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE"                                                                                            ,"X7_CONDIC"                               ,"X7_PROPRI"},1)
o:TableData("SX7"  ,{'EE7_FORN'  ,'001'       ,'AVGatilho(M->EE7_FORN  ,"SA2","2|3")'                                                                ,'EE7_FOLOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE7_FORN'  ,'002'       ,'SA2->A2_NOME'                                                                                        ,'EE7_FORNDE','P'      ,'S'      ,'SA2'     ,'1'       ,'XFILIAL("SA2")+M->EE7_FORN+M->EE7_FOLOJA'                                                            ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_FOLOJA','001'       ,'IF(!EMPTY(M->EE7_FOLOJA),SA2->A2_NOME,"")'                                                           ,'EE7_FORNDE','P'      ,'S'      ,'SA2'     ,'1'       ,'XFILIAL("SA2")+M->EE7_FORN+M->EE7_FOLOJA'                                                            ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_EXPORT','001'       ,'AVGatilho(M->EE7_EXPORT,"SA2","3|4")'                                                                ,'EE7_EXLOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_EXPORT','002'       ,'IF(!EMPTY(M->EE7_EXPORT),SA2->A2_NOME,"")'                                                           ,'EE7_EXPODE','P'      ,'S'      ,'SA2'     ,'1'       ,'XFILIAL("SA2")+M->EE7_EXPORT+IF(!EMPTY(M->EE7_EXLOJA),M->EE7_EXLOJA,"")'                             ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_EXLOJA','001'       ,'IF(!EMPTY(M->EE7_EXLOJA),SA2->A2_NOME,"")'                                                           ,'EE7_EXPODE','P'      ,'S'      ,'SA2'     ,'1'       ,'XFILIAL("SA2")+M->EE7_EXPORT+M->EE7_EXLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_BENEF' ,'001'       ,'AVGatilho(M->EE7_BENEF ,"SA2","3|5")'                                                                ,'EE7_BELOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE7_BENEF' ,'002'       ,'IF(!EMPTY(M->EE7_BENEF),SA2->A2_NOME,"")'                                                            ,'EE7_BENEDE','P'      ,'S'      ,'SA2'     ,'1'       ,'XFILIAL("SA2")+M->EE7_BENEF+M->EE7_BELOJA'                                                           ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_BENEF' ,'003'       ,'IF(!EMPTY(M->EE7_BENEF),EECMEND("SA2",1,M->EE7_BENEF+M->EE7_BELOJA,.T.,AvSx3("EE7_END2BE",3),2),"")' ,'EE7_END2BE','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_BELOJA','001'       ,'IF(!EMPTY(M->EE7_BELOJA),SA2->A2_NOME,"")'                                                           ,'EE7_BENEDE','P'      ,'S'      ,'SA2'     ,'1'       ,'XFILIAL("SA2")+M->EE7_BENEF+M->EE7_BELOJA'                                                           ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_BELOJA','002'       ,'IF(!EMPTY(M->EE7_BENEF),EECMEND("SA2",1,M->EE7_BENEF+M->EE7_BELOJA,.T.,AvSx3("EE7_ENDBEN",3),1),"")' ,'EE7_ENDBEN','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_BELOJA','003'       ,'IF(!EMPTY(M->EE7_BENEF),EECMEND("SA2",1,M->EE7_BENEF,.T.,AvSx3("EE7_END2BE",3),2),"")'               ,'EE7_END2BE','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE8_FORN'  ,'001'       ,'AVGatilho(M->EE8_FORN  ,"SA2","2|3")'                                                                ,'EE8_FOLOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE8_FABR'  ,'001'       ,'AVGatilho(M->EE8_FABR  ,"SA2","1|3")'                                                                ,'EE8_FALOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','001'       ,'AVGatilho(M->EE7_IMPORT,"SA1","1|4")'                                                                ,'EE7_IMLOJA','P'      ,'N'      ,''        ,'0'       ,'xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA'                                                          ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','002'       ,'AP102ViaTrans()'                                                                                     ,'EE7_VIA'   ,'P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'AP102ViaTrans(.T.)'                      ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','003'       ,'AP100Import()'                                                                                       ,'EE7_VALCOM','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','004'       ,'IF(!EMPTY(SA1->A1_CONDPAG),SA1->A1_CONDPAG,M->EE7_CONDPA)'                                           ,'EE7_CONDPA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','005'       ,'IF(!EMPTY(SA1->A1_CONDPAG),SA1->A1_DIASPAG,M->EE7_DIASPA)'                                           ,'EE7_DIASPA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','006'       ,'EECMEND("SA1",1,M->EE7_IMPORT+M->EE7_IMLOJA,.T.,AvSx3("EE7_ENDIMP",3),1)'                            ,'EE7_ENDIMP','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','007'       ,'EECMEND("SA1",1,M->EE7_IMPORT+M->EE7_IMLOJA,.T.,AvSx3("EE7_END2IM",3),2)'                            ,'EE7_END2IM','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','008'       ,'POSICIONE("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_IDIOMA")'                                          ,'EE7_IDIOMA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'AP102CondGat()'                          ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','009'       ,'AP100FobImport("EE7_INCOTE")'                                                                        ,'EE7_INCOTE','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'Empty(M->EE7_INCOTE)'                    ,'S'        })
o:TableData("SX7"  ,{'EE7_IMPORT','010'       ,'SA1->A1_NOME'                                                                                        ,'EE7_IMPODE','P'      ,'S'      ,'SA1'     ,'1'       ,'xFilial("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','001'       ,'SA1->A1_NOME'                                                                                        ,'EE7_IMPODE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EE7_IMPORT+M->EE7_IMLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','002'       ,'AP100Import()'                                                                                       ,'EE7_VALCOM','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','003'       ,'IF(!EMPTY(SA1->A1_CONDPAG),SA1->A1_CONDPAG,M->EE7_CONDPA)'                                           ,'EE7_CONDPA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','004'       ,'IF(!EMPTY(SA1->A1_CONDPAG),SA1->A1_DIASPAG,M->EE7_DIASPA)'                                           ,'EE7_DIASPA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','005'       ,'EECMEND("SA1",1,M->EE7_IMPORT+M->EE7_IMLOJA,.T.,AvSx3("EE7_ENDIMP",3),1)'                            ,'EE7_ENDIMP','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','006'       ,'EECMEND("SA1",1,M->EE7_IMPORT+M->EE7_IMLOJA,.T.,AvSx3("EE7_END2IM",3),2)'                            ,'EE7_END2IM','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','007'       ,'POSICIONE("SYA",1,xFilial("SYA")+SA1->A1_PAIS,"YA_IDIOMA")'                                          ,'EE7_IDIOMA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!Empty(SA1->A1_PAIS)'                    ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','008'       ,'AP100FobImport("EE7_INCOTE")'                                                                        ,'EE7_INCOTE','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'Empty(M->EE7_INCOTE)'                    ,'S'        })
o:TableData("SX7"  ,{'EE7_IMLOJA','009'       ,'AP100FobImport("EE7_INCOTE")'                                                                        ,'EE7_INCOTE','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'Empty(M->EE7_INCOTE)'                    ,'S'        })
o:TableData("SX7"  ,{'EE7_CLIENT','001'       ,'AVGatilho(M->EE7_CLIENT,"SA1")'                                                                      ,'EE7_CLLOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE7_CLIENT','002'       ,'IF(!EMPTY(M->EE7_CLIENT),SA1->A1_NOME,"")'                                                           ,'EE7_CLIEDE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EE7_CLIENT+M->EE7_CLLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_CLLOJA','001'       ,'IF(!EMPTY(M->EE7_CLLOJA),SA1->A1_NOME,"")'                                                           ,'EE7_CLIEDE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EE7_CLIENT+M->EE7_CLLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_CONSIG','001'       ,'AVGatilho(M->EE7_CONSIG,"SA1","2|4")'                                                                ,'EE7_COLOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EE7_CONSIG','002'       ,'IF(!EMPTY(M->EE7_CONSIG),SA1->A1_NOME,"")'                                                           ,'EE7_CONSDE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EE7_CONSIG+IF(!EMPTY(M->EE7_COLOJA),M->EE7_COLOJA,"")'                             ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EE7_COLOJA','001'       ,'IF(!EMPTY(M->EE7_COLOJA),SA1->A1_NOME,"")'                                                           ,'EE7_CONSDE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EE7_CONSIG+IF(!EMPTY(M->EE7_COLOJA),M->EE7_COLOJA,"")'                             ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EEN_IMPORT','001'       ,'AVGatilho(M->EEN_IMPORT,"SA1","3|4")'                                                                ,'EEN_IMLOJA','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,'!IsInCallStack("CONPAD1")'               ,'S'        })
o:TableData("SX7"  ,{'EEN_IMPORT','002'       ,'SA1->A1_NOME'                                                                                        ,'EEN_IMPODE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EEN_IMPORT+M->EEN_IMLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EEN_IMPORT','003'       ,'EECMEND("SA1",1,M->EEN_IMPORT+M->EEN_IMLOJA,.T.,AvSx3("EEN_ENDIMP",3),1)'                            ,'EEN_ENDIMP','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EEN_IMPORT','004'       ,'EECMEND("SA1",1,M->EEN_IMPORT+M->EEN_IMLOJA,.T.,AvSx3("EEN_END2IM",3),2)'                            ,'EEN_END2IM','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EEN_IMLOJA','001'       ,'SA1->A1_NOME'                                                                                        ,'EEN_IMPODE','P'      ,'S'      ,'SA1'     ,'1'       ,'XFILIAL("SA1")+M->EEN_IMPORT+M->EEN_IMLOJA'                                                          ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EEN_IMLOJA','002'       ,'EECMEND("SA1",1,M->EEN_IMPORT+M->EEN_IMLOJA,.T.,AvSx3("EEN_ENDIMP",3),1)'                            ,'EEN_ENDIMP','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })
o:TableData("SX7"  ,{'EEN_IMLOJA','003'       ,'EECMEND("SA1",1,M->EEN_IMPORT+M->EEN_IMLOJA,.T.,AvSx3("EEN_END2IM",3),2)'                            ,'EEN_END2IM','P'      ,'N'      ,''        ,'0'       ,''                                                                                                    ,''                                        ,'S'        })

//THTS - 21/08/2018 - Gatilhos para os campos de loja do Embarque
o:TableStruct("SX7" ,{"X7_CAMPO"     ,"X7_SEQUENC","X7_REGRA"                            ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC"             ,"X7_PROPRI"})
o:TableData("SX7"   ,{"EEC_IMPORT"   ,"001"       ,"AVGatilho(M->EEC_IMPORT,'SA1','1|4')","EEC_IMLOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EEC_FORN"     ,"001"       ,"AVGatilho(M->EEC_FORN,'SA2','2|3')"  ,"EEC_FOLOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EEC_FORN"     ,"002"       ,"SA2->A2_NOME"                        ,"EEC_FORNDE","P"      ,"N"      ,""        ,""        ,""        ,"!Empty(SA2->A2_NOME)"  ,"S"        })
o:TableData("SX7"   ,{"EEC_CONSIG"   ,"001"       ,"AVGatilho(M->EEC_CONSIG,'SA1','2|4')","EEC_COLOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EEC_BENEF"    ,"001"       ,"AVGatilho(M->EEC_BENEF,'SA2','3|5')" ,"EEC_BELOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EEC_CLIENT"   ,"001"       ,"AVGatilho(M->EEC_CLIENT,'SA1')"      ,"EEC_CLLOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EEC_EXPORT"   ,"001"       ,"AVGatilho(M->EEC_EXPORT,'SA2','3|4')","EEC_EXLOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EE9_FORN"     ,"001"       ,"AVGatilho(M->EE9_FORN,'SA2','2|3')"  ,"EE9_FOLOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EE9_FABR"     ,"001"       ,"AVGatilho(M->EE9_FABR,'SA2','1|3')"  ,"EE9_FALOJA","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EE9_CODUE"    ,"001"       ,"AVGatilho(M->EE9_CODUE,'SA2')"       ,"EE9_LOJUE" ,"P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EYU_FABR"     ,"001"       ,"AVGatilho(M->EYU_FABR,'SA2','1|3')"  ,"EYU_FA_LOJ","P"      ,"N"      ,""        ,""        ,""        ,'!IsInCallStack("CONPAD1")'                      ,"S"        })
o:TableData("SX7"   ,{"EYU_FABR"     ,"004"       ,"SA2->A2_NREDUZ"                      ,"EYU_FA_DES","P"      ,"N"      ,""        ,""        ,""        ,"!Empty(SA2->A2_NREDUZ)","S"        })
o:DelTableData('SX7',{'EE9_COD_I '  ,'007'       ,""                                    ,""          ,""       ,""       ,""        ,""        ,""        ,""                      ,""         })

o:TableStruct("SX3",{"X3_CAMPO"     ,"X3_VALID" },2)
o:TableData('SX3'  ,{'EEC_IMLOJA'   ,'AE100CRIT("EEC_IMLOJA") .And. AE100Crit("EEC_MARCAC")'})
o:TableData('SX3'  ,{'EEC_FOLOJA'   ,'AE100CRIT("EEC_FOLOJA") .And. AE100Crit("EEC_MARCAC")'})
o:TableData('SX3'  ,{'EEC_COLOJA'   ,'AE100CRIT("EEC_COLOJA")'})
o:TableData('SX3'  ,{'EEC_BELOJA'   ,'AE100CRIT("EEC_BELOJA")'})
o:TableData('SX3'  ,{'EEC_CLLOJA'   ,'AE100CRIT("EEC_CLLOJA")'})
o:TableData('SX3'  ,{'EEC_EXPORT'   ,'AE100CRIT("EEC_EXPORT") .AND. AE100Crit("EEC_MARCAC")'})
o:TableData('SX3'  ,{'EEC_EXLOJA'   ,'AE100CRIT("EEC_EXLOJA") .And. AE100Crit("EEC_MARCAC")'})
o:TableData('SX3'  ,{'EE9_FOLOJA'   ,'AE100CRIT("EE9_FOLOJA")'})
o:TableData('SX3'  ,{'EE9_FALOJA'   ,'AE100CRIT("EE9_FALOJA")'})
o:TableData('SX3'  ,{'EE9_CODUE'    ,'AE100CRIT("EE9_CODUE")'})
o:TableData('SX3'  ,{'EE9_LOJUE'    ,'AE100CRIT("EE9_LOJUE")'})
o:TableData('SX3'  ,{'EYU_FABR'     ,'AE100CRIT("EYU_FABR")'})
o:TableData('SX3'  ,{'EYU_FA_LOJ'   ,'AE100CRIT("EYU_FA_LOJ")'})

//LRS - 30/08/208
o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                       ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                                           ,"X6_DSCSPA1" ,"X6_DSCENG1","X6_DESC2"                ,"X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"})
o:TableData("SX6"  ,{""         ,"MV_EEC0056" ,"L"      ,"Parâmetro utilizado para indicar se a comissão   ",""          ,""          ,"conta gráfica será enviada como desconto na baixa " ,            ,             ,"do título a receber  "   ,""          ,""          ,".F."       ,            ,            ,"S"        ,"S"      ,""        , ""       , ""         , ""         , ""         })

//THTS - 28/08/2018
o:TableStruct("SX7" ,{"X7_CAMPO"     ,"X7_SEQUENC","X7_REGRA"   ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC"             ,"X7_PROPRI"})
o:TableData("SX7"   ,{"EE9_COD_I"    ,"005"       ,"SB1->B1_QE" ,"EE9_QE"    ,"P"      ,"N"      ,""        ,""        ,""        ,"Empty(M->EE9_QE)"      ,"S"        })

//CEO - 03/09/2018
o:TableStruct("SXB"  ,{"XB_ALIAS"   , "XB_TIPO" , "XB_SEQ"  , "XB_COLUNA"   ,"XB_CONTEM"})
o:TableData  ("SXB"  ,{"AVE005"     , "6"       , "01"      , ""            ,"(LEFT(SA2->A2_ID_FBFN,1) $ '2/3') .OR. Empty(SA2->A2_ID_FBFN)" })

o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_F3" },2)
o:TableData  ("SX3"  ,{"EE8_FORN" ,"AVE005"})
o:TableData  ("SX3"  ,{"EE9_FORN" ,"AVE005"})
o:TableData  ("SX3"  ,{"EE8_FABR" ,"AVE014"})
o:TableData  ("SX3"  ,{"EE9_FABR" ,"AVE014"})

o:TableStruct("SXB",{"XB_ALIAS" , "XB_TIPO" , "XB_SEQ"  , "XB_COLUNA", "XB_DESCRI"          , "XB_DESCSPA"              , "XB_DESCENG"          , "XB_CONTEM"                                                       , "XB_WCONTEM"})
o:TableData  ("SXB",{ "AVE014"  , "1"       , "01"      , "DB"       , "Fabricantes"        , "Fabricantes"             , "Manufactures"        , "SA2"                                                             , })
o:TableData  ("SXB",{ "AVE014"  , "2"       , "01"      , "01"       , "Código + Loja"      , "Codigo + Tienda"         , "Code + Unit"         , ""                                                                , })
o:TableData  ("SXB",{ "AVE014"  , "2"       , "02"      , "02"       , "Razao Social + Loja", "Razon Social + Tienda"   , "Company Name + Unit" , ""                                                                , })
o:TableData  ("SXB",{ "AVE014"  , "3"       , "01"      , "01"       , "Cadastro Novo"      , "Incluye Nuevo"           , "Add New"             , "01"                                                              , })
o:TableData  ("SXB",{ "AVE014"  , "4"       , "01"      , "01"       , "Código"             , "Codigo"                  , "Code"                , "A2_COD"                                                          , })
o:TableData  ("SXB",{ "AVE014"  , "4"       , "01"      , "02"       , "Loja"               , "Tienda"                  , "Unit"                , "A2_LOJA"                                                         , })
o:TableData  ("SXB",{ "AVE014"  , "4"       , "01"      , "03"       , "Nome"               , "Nombre"                  , "Name"                , "SUBSTR(A2_NOME,1,30)"                                            , })
o:TableData  ("SXB",{ "AVE014"  , "4"       , "02"      , "01"       , "Nome"               , "Nombre"                  , "Name"                , "SUBSTR(A2_NOME,1,30)"                                            , })
o:TableData  ("SXB",{ "AVE014"  , "4"       , "02"      , "02"       , "Codigo"             , "Codigo"                  , "Manufacturer"        , "A2_COD"                                                          , })
o:TableData  ("SXB",{ "AVE014"  , "4"       , "02"      , "03"       , "Loja"               , "Tienda"                  , "Unit"                , "A2_LOJA"                                                         , })
o:TableData  ("SXB",{ "AVE014"  , "5"       , "01"      , ""         , ""                   , ""                        , ""                    , "SA2->A2_COD"                                                     , })
o:TableData  ("SXB",{ "AVE014"  , "5"       , "02"      , ""         , ""                   , ""                        , ""                    , "SA2->A2_LOJA"                                                    , })
o:TableData  ("SXB",{ "AVE014"  , "6"       , "01"      , ""         , ""                   , ""                        , ""                    , "(LEFT(SA2->A2_ID_FBFN,1) $ '1/3') .OR. Empty(SA2->A2_ID_FBFN)"   , })

o:TableStruct("EC6" , {"EC6_FILIAL"     , "EC6_TPMODU"  ,"EC6_ID_CAM"   ,"EC6_RECDES"	,"EC6_DESC"            , "EC6_IDENTC"}, 1)
o:TableData("EC6"   , {xFilial("EC6")   , "EXPORT"      ,"603"          ,"1"	        ,"ADIANTAMENTO POS-EMB", ""          },,.F.)

o:TableStruct("SX3"  ,{"X3_CAMPO"   ,"X3_USADO"    },2)
o:TableData  ("SX3"  ,{"EE7_FREEMB" , TODOS_MODULOS})
o:TableData  ("SX3"  ,{"EEC_FREEMB" , TODOS_MODULOS})

If EE9->(FieldPos("EE9_LPCO")) > 0
    o:TableStruct("SX3"  ,{"X3_CAMPO" , "X3_USADO"     },2)
    o:TableData  ("SX3"  ,{"EE9_LPCO" , TODOS_MODULOS})
EndIf

o:TableStruct("SX3"  ,{"X3_CAMPO" , "X3_VISUAL", "X3_USADO",    "X3_RESERV"   },2)
o:TableData  ("SX3"  ,{"EEC_DTDUE", "A"        , TODOS_MODULOS, USO  })

//CEO - 17/10/2018
o:TableStruct ("SX3",{"X3_CAMPO", "X3_WHEN"},2)
o:TableData ("SX3"  ,{"EEM_NRNF", "AE101WHEN('EEM_NRNF')" })
o:TableData ("SX3"  ,{"EEM_SERIE", "AE101WHEN('EEM_SERIE')" })
o:TableData ("SX3"  ,{"EEM_DTNF",  "AE101WHEN('EEM_DTNF')" })   

// MPG - 26/10/2018 - CORREÇÃO DO CAMPO MOEDAEASY QUE NÃO APARECE NO CADASTRO DE BANCOS
o:TableStruct("SX3"  ,{"X3_CAMPO"  , "X3_USADO"     },2)
o:TableData  ("SX3"  ,{"A6_MOEEASY", TODOS_MODULOS  })

o:TableStruct("SX3"  ,{"X3_CAMPO"  ,"X3_FOLDER"  , "X3_USADO"     },2)
o:TableData  ("SX3"  ,{"EE8_DESCON", "1"         , TODOS_MODULOS  })
o:TableData  ("SX3"  ,{"EE9_DESCON", ""          , TODOS_MODULOS  })

//EJA - 07/11/2018
o:TableStruct("SX3",{"X3_CAMPO", "X3_PICTURE", "X3_RESERV"},2)
o:TableData  ("SX3",{"EL2_RE"  , ""          , TAM        })
o:TableData  ("SX3",{"EL7_RE"  , ""          , TAM        })

//THTS - 10/01/2019
o:TableStruct("SX3", {"X3_CAMPO",   "X3_USADO"}, 2)
o:TableData(  "SX3" ,{"EE8_GRADE", TODOS_MODULOS})

//MPG - 11/04/2019
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_PICTURE"               },2)
o:TableData("SX3"  ,{"YD_DESTAQU" , '@R ###/###/###/###/###/###/###/###/###/###' })

//MFR 01/04/2019 OSSME-1772
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_USADO" },2)
o:TableData("SX3"  ,{"EYO_LOCENT" , NAO_USADO   })

//MFR 11/04/2019 OSSME-2708
AAdd( aDados, { { 'SWB', 'SYE', 'WB_DT_CONT+WB_MOEDA', 'DTOS(YE_DATA)+YE_MOEDA' }, { { 'X9_EXPDOM', 'YE_DATA+YE_MOEDA' } } } ) 
//EngSX9117( aDados ) rotina não é mais executada e esta funcao estava sendo reportada nos débitos técnicos MFR 24/06/2021 OSSME-5986

o:TableStruct("SX3",{"X3_CAMPO"   , "X3_RESERV","X3_TIPO"},2)
o:TableData  ("SX3",{"EYY_VM_DES" , USO+TIPO   ,"C"})

//MPG - 29/05/2019 - OSSME-3046
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_VALID"},2)
o:TableData  ("SX3",{"EEC_RECALF" , 'vazio() .OR. ExistCpo("SJA")' })
o:TableData  ("SX3",{"EEC_RECEMB" , 'vazio() .OR. ExistCpo("SJA")' })

//MPG - 29/05/2019 - OSSME-3046
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_RESERV" },2)
o:TableData  ("SX3",{"EK1_LATDES" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK1_LONDES" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK1_TOTFOB" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK1_VALCOM" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_PERCOM" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_PESNCM" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_PRCINC" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_PRCTOT" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_PSLQUN" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_QTDNCM" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_SLDINI" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK2_VLSCOB" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK4_D2QTD"  , USO+TAM+DEC })
o:TableData  ("SX3",{"EK4_QUANT"  , USO+TAM+DEC })
o:TableData  ("SX3",{"EK6_QTUMIT" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK6_QUANT"  , USO+TAM+DEC })
o:TableData  ("SX3",{"EK7_QTD"    , USO+TAM+DEC })
o:TableData  ("SX3",{"EK7_VALOR"  , USO+TAM+DEC })
o:TableData  ("SX3",{"EK7_VLSCOB" , USO+TAM+DEC })
o:TableData  ("SX3",{"EK8_QTD"    , USO+TAM+DEC })
o:TableData  ("SX3",{"EK8_VLNF"   , USO+TAM+DEC })
o:TableData  ("SX3",{"EWI_QTD"    , USO+TAM+DEC })
o:TableData  ("SX3",{"EWI_VLNF"   , USO+TAM+DEC })
o:TableData  ("SX3",{"EE9_SLDINI" , USO+TAM+DEC })

//THTS - 04/06/2019
o:TableStruct("SX7" ,{"X7_CAMPO"     ,"X7_SEQUENC","X7_REGRA"               ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_CONDIC"       ,"X7_PROPRI"})
o:TableData("SX7"   ,{"EEQ_DESCON"   ,"001"       ,"AF200VLFCam('M','LIQ')" ,"EEQ_VM_REC","P"      ,"N"      ,"!lFinanciamento" ,"S"        })
o:TableData("SX7"   ,{"EEQ_DESCON"   ,"003"       ,"AF200VLFCam('M','LIQ')" ,"EEQ_VLFCAM","P"      ,"N"      ,"!lFinanciamento" ,"S"        })

//MPG - 02/07/2019 - OSSME-3308
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_RESERV" },2)
o:TableData  ("SX3",{"EE8_PSBRTO" , USO+TAM+DEC })

//NCF - 04/07/2019 - OSSME-2546
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_WHEN" },2)
o:TableData  ("SX3",{"EEQ_MODAL" , "AF200W('EEQ_MODAL')" })

//MPG - 16/09/2019 - OSSME-3698
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_RESERV" , "X3_INIBRW"},2)
o:TableData  ("SX3",{"EE7_VM_AMO" , TAM         , "IniBrwAmostra('EE7')" })
o:TableData  ("SX3",{"EEC_VM_AMO" , TAM         , "IniBrwAmostra('EEC')" })

//MFR 30/09/2019 OSSME-3309
o:TableStruct("SX3",{"X3_CAMPO"     ,"X3_VALID" },2)
o:TableData('SX3'  ,{'EE8_DESCON'   ,'(VAZIO() .OR. POSITIVO()) .AND. AP100CRIT("EE8_DESCON")'})

//RNLP - 30/09/2019
o:TableStruct("SX7" ,{"X7_CAMPO"     ,"X7_SEQUENC","X7_REGRA"               ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK",'X7_ALIAS' ,'X7_ORDEM' ,'X7_CHAVE'                    ,'X7_CONDIC' ,'X7_PROPRI'})
o:TableData("SX7"   ,{"EE8_POSIPI"   ,"001"       ,"SYD->YD_DESTAQU"        ,"EE8_DTQNCM","P"      ,"S"      ,"SYD"      ,3          ,'XFILIAL("SYD")+M->EE8_POSIPI','', 'S'    })
o:TableData("SX7"   ,{"EE9_POSIPI"   ,"001"       ,"SYD->YD_DESTAQU"        ,"EE9_DTQNCM","P"      ,"S"      ,"SYD"      ,3          ,'XFILIAL("SYD")+M->EE9_POSIPI','', 'S'    })

//RNLP - 30/09/2019 //ALTERAR TRIGGER SX3 para uso de gatilho
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_TRIGGER"},2)
o:TableData("SX3"  ,{"EE8_POSIPI" , "S"        })
o:TableData("SX3"  ,{"EE9_POSIPI" , "S"        })

//RNLP - 30/10/2019 //ALTERAR INICIALIZADOR PADRAO PARA CHAMADA DA FUNCAO EECIniPad
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_RELACAO"},2)
o:TableData("SX3"  ,{"EYY_COD_I" , "EECIniPad('EYY_COD_I')"        })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID"},2)
o:TableData("SX3"  ,{"EE8_PRECO"  , 'AP100CRIT("EE8_PRECO") .AND. POSITIVO() .AND. EECVLEE8("EE8_PRECO") .AND. AP104GATPRECO(,.T.)'  }) 
o:TableData("SX3"  ,{"EE9_PRECO"  , 'POSITIVO().AND.EECVLEE9("EE9_PRECO") .And. AE100PrecoI() .AND. AP104GATPRECO(,.F.)'             })                                                                                                 
o:TableData("SX3"  ,{"EE9_UNPRC"  , 'Vazio() .Or. ExistCpo("SAH") .AND. AP104GATPRECO(, .F.)'                                        }) //NCF - 11/11/2019 - Compatibilidade com Atusx.

//NCF - 04/03/2020 - //Gatilhar o valor na moeda do banco ao alterar a paridade manualmente.
o:TableStruct("SX7",{'X7_CAMPO'   ,'X7_SEQUENC'  , 'X7_REGRA'                    ,'X7_CDOMIN'  ,'X7_TIPO' ,'X7_SEEK'  ,'X7_ALIAS' , 'X7_ORDEM' , 'X7_CHAVE' , 'X7_CONDIC' ,'X7_PROPRI'},1)
o:TableData("SX7"  ,{"EEQ_PRINBC" ,"001"         ,"M->EEQ_VLFCAM * M->EEQ_PRINBC",'EEQ_VLMBCO' ,'P'       ,'N'        ,           ,            ,            ,             ,"S"        }  )
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_TRIGGER"},2)
o:TableData("SX3"  ,{"EEQ_PRINBC" , "S"        })

Return Nil

/*
Funcao                     : UPDEEC033
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      : Maurício Frison
Data/Hora   			      : 18/03/2021
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEEC033(o)
    o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM" },2)
    o:TableData  ("SX3",{"EEA_TIPCUS" ,"08"       })

Return nil



/*
Função     : AtuStatusDUE()
Objetivo   : Atualização do Status da DUE por filiais do sistema
Retorno    : 
Autor      : WFS - Wilsimar Fabrício da Silva
Data       : 26/05/2017
*/
Static Function AtuStatusDUE()
Local aSM0:= {}
Local nCont, cOldFilial

Begin Sequence

   If !AvFlags("DU-E")
      Break
   EndIf
   
   cOldFilial:= cFilAnt
   aSM0:= FWLoadSM0()
   
   For nCont:= 1 To Len(aSM0)
      If aSm0[nCont][1] == cEmpAnt
         cFilAnt:= aSm0[nCont][2]
         AtuStFilial(cFilAnt)
      EndIf
   Next

   cFilAnt:= cOldFilial
End Sequence
Return

/*
Função     : AtuStFilial()
Objetivo   : Query para atualização, por filial
Retorno    : 
Autor      : WFS - Wilsimar Fabrício da Silva
Data       : 26/05/2017
*/
Static Function AtuStFilial(cFil)
Local cQuery

   cQuery:= "Select R_E_C_N_O_ RECNO From " + RetSqlName("EEC") + " Where EEC_FILIAL = '" + cFil + "' And EEC_STTDUE = ''"
   If TcSrvType() <> "AS/400"
      cQuery += " And D_E_L_E_T_ <> '*'"
   EndIf

   cQuery:= ChangeQuery(cQuery)
   TcQuery cQuery Alias "TMPDUE" New

   TMPDUE->(DBGoTop())
   
   While TMPDUE->(!Eof())
      EEC->(DBGoTo(TMPDUE->(RECNO)))
   
      EEC->(RecLock("EEC", .F.))
      EEC->EEC_STTDUE:= DU400Status()
      EEC->(MsUnlock())
   
      TMPDUE->(DBSkip())      
   EndDo

   TMPDUE->(DBCloseArea())
Return
