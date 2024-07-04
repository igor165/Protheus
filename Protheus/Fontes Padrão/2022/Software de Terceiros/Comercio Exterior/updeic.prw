#Include 'Protheus.ch'
#Include "Average.ch"
#Include "TOPCONN.CH"

/*
Funcao                     : UPDEIC003
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      : Lucas Raminelli - LRS
Data/Hora   			      : 23/02/2015 - 09:00
Data/Hora Ultima alteração : LRS - 23/02/2015 - 09:15
Revisao                    :
Obs.                       :
*/

Function UPDEIC003(o)

//Ajusta Help - MCF 15/04/2015
Local aHelpPor := {}
Local aHelpSpa := {}
Local aHelpEng := {}

aAdd(aHelpPor,"Não será gerado titulo(s) no módulo ")
aAdd(aHelpPor,"Financeiro(SIGAFIN) pois o parâmetro ")
aAdd(aHelpPor,"MV_1DUP está configurado ")
aAdd(aHelpPor,"incorretamente.")
aAdd(aHelpSpa,"Não será gerado titulo(s) no módulo ")
aAdd(aHelpSpa,"Financeiro(SIGAFIN) pois o parâmetro ")
aAdd(aHelpSpa,"MV_1DUP está configurado ")
aAdd(aHelpSpa,"incorretamente.")
aAdd(aHelpEng,"Não será gerado titulo(s) no módulo ")
aAdd(aHelpEng,"Financeiro(SIGAFIN) pois o parâmetro ")
aAdd(aHelpEng,"MV_1DUP está configurado ")
aAdd(aHelpEng,"incorretamente.")

PutHelp("PAVG0005385",aHelpPor,aHelpSpa,aHelpEng,.T.)

aHelpPor := {}
aHelpSpa := {}
aHelpEng := {}

aAdd(aHelpPor,"Favor verificar a configuração ")
aAdd(aHelpPor,"do parametro MV_1DUP.")
aAdd(aHelpSpa,"Favor verificar a configuração ")
aAdd(aHelpSpa,"do parametro MV_1DUP.")
aAdd(aHelpEng,"Favor verificar a configuração ")
aAdd(aHelpEng,"do parametro MV_1DUP.")

PutHelp("SAVG0005385",aHelpPor,aHelpSpa,aHelpEng,.T.)

//MCF - Alterando campos para usado, para evitar error.log
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_USADO"     },2)
o:TableData  ("SX3"  ,{"WB_DESCO" ,"TODOS_MODULOS" })
o:TableData  ("SX3"  ,{"WB_VLIQ"  ,"TODOS_MODULOS" })
o:TableData  ("SX3"  ,{"EWZ_HAWB" ,"TODOS_MODULOS" })

//LGS-27/03/2015
o:TableStruct("SX7",{ 'X7_CAMPO' , 'X7_SEQUENC' , 'X7_REGRA'                , 'X7_CDOMIN', 'X7_TIPO' , 'X7_SEEK' , 'X7_ALIAS' , 'X7_ORDEM' , 'X7_CHAVE'                   , 'X7_CONDIC' , 'X7_PROPRI'})
o:TableData  ('SX7',{ 'W1_COD_I' , '001'        , 'SI400Gatilho("W1_COD_I")', 'W1_COD_DES','P'        ,'S'        ,'SB1'      , 1          , 'XFILIAL("SB1")+M->W1_COD_I' ,             , 'S'         })

//LRS - 02/04/2015
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_PICTURE"},2)
o:TableData  ("SX3"  ,{"YW_EST"   ,"@!"        })
o:TableData  ("SX3"  ,{"YW_MUN"   ,"@!"        })

//LRS - 06/04/2015
o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                            ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                    ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"},1)
o:TableData("SX6"  ,{"  "       ,"MV_NR_ISUF" ,"N"      ,"Permite ao usuario define a quantidade",""          ,""          ,"máxima de itens por adição." ,            ,            ,""        ,""          ,""          ,"78"        ,            ,            ,"S"        ,"N"      ,""        , ""       , ""        , ""          , ""         })

//MCF - 07/04/2014
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_USADO"    , "X3_RESERV" },2)
o:TableData  ("SX3",{"YT_FORN"   ,TODOS_MODULOS , ORDEM+USO   })
o:TableData  ("SX3",{"YT_LOJA"   ,TODOS_MODULOS , ORDEM+USO   })
o:TableData  ("SX3",{"YT_DESFOR" ,TODOS_MODULOS , ORDEM+USO   })

//MCF - 09/06/2015
o:TableStruct("SX7",{"X7_CAMPO" ,"X7_SEQUENC" ,"X7_CHAVE"                                                                     })
o:TableData  ('SX7',{'WD_FORN'  ,'001'        ,'xFilial("SA2")+M->WD_FORN+If(Empty(EicRetLoja("M","WD_LOJA")),"",M->WD_LOJA)' })


Return Nil

/*
Funcao                     : UPDEIC004
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      : Lucas Raminelli - LRS
Data/Hora   			      : 08/05/2015 - 09:00
Data/Hora Ultima alteração : LRS - 08/05/2015 - 09:15
Revisao                    :
Obs.                       :
*/

Function UPDEIC004(o)
Local aHelp := {}

//LRS - 08/05/2015
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_USADO"    , "X3_RESERV" },2)
o:TableData  ("SX3",{"W0_CONTR"  ,TODOS_MODULOS , ORDEM+USO   })

//LRS- 18/05/2015
o:TableStruct("SX1",{"X1_GRUPO","X1_ORDEM" ,"X1_PERGUNT"      ,"X1_PERSPA","X1_PERENG" ,"X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL" ,"X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02","X1_DEF02","X1_DEFSPA2","X1_DEFENG2","X1_CNT02","X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04","X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3","X1_PYME","X1_GRPSXG","X1_HELP","X1_PICTURE","X1_IDFIL"})
o:TableData("SX1"  ,{"EICCC1"  ,"05"       ,"Verifica D.I.?"  ,""         ,            ,"MV_CH5"    ,"C"       , 1         , 0          , 1          ,"C"     ,""        ,"MV_PAR06","Sim"      ,""          ,""          ,""        ,""        ,"Não"     ,""          ,""          ,""        ,""        ,""        ,""          ,""          ,""        ,""        ,""        ,""          ,""          ,""        ,""        ,""        ,""          ,""          ,""        ,""     ,""       ,""         ,""       ,""          ,""        })

AaDD(aHelp,"Verifica se o processo tem D.I.") //Adicionar Help no SX1
PutHelp("P."+"EICCC1"+"05"+".",aHelp,aHelp,aHelp,.T.)

//MCF - 21/05/2015
o:TableStruct('SX3'  ,{'X3_CAMPO'  ,'X3_ORDEM' },2)
o:TableData  ("SX3"  ,{'WB_AGENCIA','11'       })
o:TableData  ("SX3"  ,{'WB_CONTA'  ,'12'       })
o:TableData  ("SX3"  ,{'WB_DES_BCO','13'       })

//MCF - 23/06/2015
o:TableStruct("SX3",{"X3_ARQUIVO","X3_ORDEM","X3_CAMPO"  ,"X3_TIPO","X3_TAMANHO","X3_DECIMAL","X3_TITULO"    ,"X3_TITSPA","X3_TITENG" ,"X3_DESCRIC"                              ,"X3_DESCSPA","X3_DESCENG","X3_PICTURE"			    ,"X3_VALID","X3_USADO"    ,"X3_RELACAO","X3_F3","X3_NIVEL","X3_RESERV" ,"X3_CHECK","X3_TRIGGER","X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX","X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN","X3_INIBRW","X3_GRPSXG","X3_FOLDER","X3_PYME","X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"},2)
o:TableData  ("SX3",{"SWB"       ,"71"      ,"WB_DESCO"  ,"N"      ,15          ,2           ,"Desconto"     ,"" 		  ,			     ,"Desconto no valor da parcela de câmbio"  ,"" 		    ,""          ,"@E 999,999,999,999.99" ,""        ,TODOS_MODULOS ,""          ,""     ,1         ,""          ,""        ,""          ,"U"        ,"S"        ,"A"        ,"R"         ,""          ,""          ,""	     ,""          ,""          ,""          ,""       ,""         ,""         ,"1"        ,         ,            ,           ,           ,"N"         ,"N"        ,         })
o:TableData  ("SX3",{"SWB"       ,"72"      ,"WB_VLIQ"   ,"N"      ,15          ,2           ,"Valor Liqui." ,"" 		  ,			     ,"Valor Liquido"                           ,"" 	        ,""          ,"@E 999,999,999,999.99" ,""        ,TODOS_MODULOS ,""          ,""     ,1         ,""          ,""        ,""          ,"U"        ,"S"        ,"V"        ,"R"         ,""          ,""          ,""	     ,""          ,""          ,""          ,""       ,""         ,""         ,"1"        ,         ,            ,           ,           ,"N"         ,"N"        ,         })

Return Nil

/*
Funcao                     : UPDEIC005
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			   : Lucas Raminelli - LRS
Data/Hora   			   : 01/07/2015 - 10:30
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEIC005(o)

//LRS - 27/06/2015
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"           ,"XB_DESCSPA"          ,"XB_DESCENG"          ,"XB_CONTEM"                         ,"XB_WCONTEM"})
o:TableData("SXB"  ,{"YR1"     , "4"     ,"01"    ,"03"       ,"Cidade Destino"      ,"Cidade Destino"      ,"Cidade Destino"      ,"YR_CID_DES"                        ,            })
o:TableData("SXB"  ,{"YR1"     , "4"     ,"01"    ,"04"       ,"Origem"              ,"Origem"              ,"Origem"              ,"YR_ORIGEM"                         ,            })
o:TableData("SXB"  ,{"YR1"     , "4"     ,"01"    ,"05"       ,"Cidade Origem"       ,"Cidade Origem"       ,"Cidade Origem"       ,"YR_CID_ORI"                        ,            })
o:TableData("SXB"  ,{"YR1"     , "4"     ,"02"    ,"03"       ,"Origem"              ,"Origem"              ,"Origem"              ,"YR_ORIGEM"                         ,            })
o:TableData("SXB"  ,{"YR1"     , "4"     ,"02"    ,"04"       ,"Cidade Destino"      ,"Cidade Destino"      ,"Cidade Destino"      ,"YR_CID_DES"                        ,            })
o:TableData("SXB"  ,{"YR1"     , "4"     ,"02"    ,"05"       ,"Cidade Origem"       ,"Cidade Origem"       ,"Cidade Origem"       ,"YR_CID_ORI"                        ,            })
o:TableData("SXB"  ,{"YR1"     , "6"     ,"01"    ,""         ,""                    ,""                    ,""                    ,"AC100F3VIA(2)"                     ,            })

o:TableData("SXB"  ,{"YR11"    , "1"     ,"01"    ,"DB"       ,"Cadastro de Fretes"  ,"Cadastro de Fretes"  ,"Cadastro de Fretes"  ,"SYR"                               ,            })
o:TableData("SXB"  ,{"YR11"    , "2"     ,"01"    ,"01"       ,"Via Transporte"      ,"Via Transporte"      ,"Via Transporte"      ,""                                  ,            })
o:TableData("SXB"  ,{"YR11"    , "2"     ,"02"    ,"03"       ,"Origem"              ,"Origem"              ,"Origem"              ,""                                  ,            })
o:TableData("SXB"  ,{"YR11"    , "4"     ,"01"    ,"01"       ,"Via Transporte"      ,"Via Transporte"      ,"Via Transporte"      ,"YR_VIA"                            ,            })
o:TableData("SXB"  ,{"YR11"    , "4"     ,"01"    ,"02"       ,"Origem"              ,"Origem"              ,"Origem"              ,"YR_ORIGEM"                         ,            })
o:TableData("SXB"  ,{"YR11"    , "4"     ,"01"    ,"03"       ,"Cidade Origem"       ,"Cidade Origem"       ,"Cidade Origem"       ,"YR_CID_ORI"                        ,            })
o:TableData("SXB"  ,{"YR11"    , "4"     ,"01"    ,"04"       ,"Destino"             ,"Destino"             ,"Destino"             ,"YR_DESTINO"                        ,            })
o:TableData("SXB"  ,{"YR11"    , "4"     ,"01"    ,"05"       ,"Cidade Destino"      ,"Cidade Destino"      ,"Cidade Destino"      ,"YR_CID_DES"                        ,            })
o:TableData("SXB"  ,{"YR11"    , "4"     ,"02"    ,"01"       ,"Origem"              ,"Origem"              ,"Origem"              ,"YR_ORIGEM"                         ,            })
o:TableData("SXB"  ,{"YR11"    , "4"     ,"02"    ,"02"       ,"Cidade Origem"       ,"Cidade Origem"       ,"Cidade Origem"       ,"YR_CID_ORI"                        ,            })
o:TableData("SXB"  ,{"YR11"    , "4"     ,"02"    ,"03"       ,"Destino"             ,"Destino"             ,"Destino"             ,"YR_DESTINO"                        ,            })
o:TableData("SXB"  ,{"YR11"    , "4"     ,"02"    ,"04"       ,"Cidade Destino"      ,"Cidade Destino"      ,"Cidade Destino"      ,"YR_CID_DES"                        ,            })
o:TableData("SXB"  ,{"YR11"    , "4"     ,"02"    ,"05"       ,"Via Transporte"      ,"Via Transporte"      ,"Via Transporte"      ,"YR_VIA"                            ,            })
o:TableData("SXB"  ,{"YR11"    , "5"     ,"01"    ,""         ,""                    ,""                    ,""                    ,"SYR->YR_ORIGEM"                    ,            })
o:TableData("SXB"  ,{"YR11"    , "6"     ,"01"    ,""         ,""                    ,""                    ,""                    ,"AC100F3VIA(1)"                     ,            })

//LRS - 27/06/2015
o:TableStruct('SX3'  ,{'X3_CAMPO'  ,'X3_F3' },2)
o:TableData  ('SX3'  ,{'WT_ORIGEM' ,'YR11'  })

//MCF - 01/07/2015
o:TableStruct("SX3"  ,{"X3_CAMPO"  ,"X3_VALID" },2)
o:TableData  ("SX3"  ,{"YD_PER_II" ,"POSITIVO(M->YD_PER_II)  .And. EICA130Valid(M->YD_PER_II)"  })
o:TableData  ("SX3"  ,{"YD_PER_IPI","POSITIVO(M->YD_PER_IPI) .And. EICA130Valid(M->YD_PER_IPI)" })
o:TableData  ("SX3"  ,{"YD_ICMS_RE","POSITIVO(M->YD_ICMS_RE) .And. EICA130Valid(M->YD_ICMS_RE)" })
o:TableData  ("SX3"  ,{"YD_PER_PIS","POSITIVO() .And. EICA130Valid(M->YD_PER_PIS)" })
o:TableData  ("SX3"  ,{"YD_RED_PIS","POSITIVO() .And. EICA130Valid(M->YD_RED_PIS)" })
o:TableData  ("SX3"  ,{"YD_PER_COF","POSITIVO() .And. EICA130Valid(M->YD_PER_COF)" })
o:TableData  ("SX3"  ,{"YD_RED_COF","POSITIVO() .And. EICA130Valid(M->YD_RED_COF)" })
o:TableData  ("SX3"  ,{"YD_ICMS_PC","POSITIVO() .And. EICA130Valid(M->YD_ICMS_PC)" })
o:TableData  ("SX3"  ,{"YD_MAJ_COF","POSITIVO() .And. EICA130Valid(M->YD_MAJ_COF)" })

o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"    ,"XB_DESCSPA"    ,"XB_DESCENG" ,"XB_CONTEM"              ,"XB_WCONTEM"})
o:TableData  ("SXB",{"EE6"     ,"3"      ,"01"    ,"01"       ,"Cadastra Novo","Incluye Nuevo" ,"Add New"    ,"01#AC170MAN('EE6',0,3)" ,            })

//MCF - 15/07/2015
o:TableStruct("SX7",{'X7_CAMPO'  ,'X7_SEQUENC','X7_REGRA'                                          ,'X7_CDOMIN' ,'X7_TIPO','X7_SEEK' ,'X7_ALIAS','X7_ORDEM','X7_CHAVE'                                 ,'X7_CONDIC','X7_PROPRI'})
o:TableData  ('SX7',{'Y5_BANCO'  ,'002'        ,'IF(EMPTY(ALLTRIM(M->Y5_BANCO)),"",SA6->A6_NUMCON)','Y5_CONTA'  ,'P'      ,'S'       ,'SA6'     ,1         ,'XFILIAL("SA6")+M->Y5_BANCO+M->Y5_AGENCIA' ,           ,'S'        })
o:TableData  ('SX7',{'W2_CLIENTE','002'        ,'SA1->A1_NOME'                                     ,'W2_CLINOME','P'      ,'S'       ,'SA1'     ,1         ,'xFilial("SA1")+M->W2_CLIENTE+M->W2_CLILOJ',           ,'S'        })

//MCF - 21/07/2015
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_RELACAO"                         },2)
o:TableData  ("SX3",{"Y5_VM_OBS" ,"EasyMSMM(SY5->Y5_OBS,60,,,,,,,,,,)" })

//LGS - 08/04/2015
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"       ,"XB_DESCSPA"      ,"XB_DESCENG"   ,"XB_CONTEM"           ,"XB_WCONTEM"})
o:TableData("SXB"  ,{ "MOT"    , "1"     ,"01"    ,"RE"       ,"Motivos"         ,"Motivos"         ,"Reasons"      ,'EEQ'                 ,            })
o:TableData("SXB"  ,{ "MOT"    , "2"     ,"01"    ,"01"       ,""                ,""                ,""             ,"AF500MOTBAIXA()"     ,            })
o:TableData("SXB"  ,{ "MOT"    , "5"     ,"01"    ,""         ,""                ,""                ,""             ,"&(ReadVar())"        ,            })

o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_F3" },2)
o:TableData  ("SX3",{"EC6_MOTBX" ,"MOT"   })

Return Nil

/*
Funcao                     : UPDEIC006
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      : Marcos Cavini - MCF
Data/Hora   			      : 17/08/2015 - 09:34
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/
Function UPDEIC006(o)

//*************************** SX1
o:TableStruct("SX1",{"X1_GRUPO","X1_ORDEM","X1_PERGUNT","X1_PERSPA","X1_PERENG","X1_VARIAVL","X1_TIPO" ,"X1_TAMANHO","X1_DECIMAL","X1_PRESEL" ,"X1_GSC","X1_VALID","X1_VAR01","X1_DEF01"      ,"X1_DEFSPA1","X1_DEFENG1","X1_CNT01","X1_VAR02","X1_DEF02" ,"X1_DEFSPA2","X1_DEFENG2","X1_CNT02","X1_VAR03","X1_DEF03","X1_DEFSPA3","X1_DEFENG3","X1_CNT03","X1_VAR04","X1_DEF04","X1_DEFSPA4","X1_DEFENG4","X1_CNT04","X1_VAR05","X1_DEF05","X1_DEFSPA5","X1_DEFENG5","X1_CNT05","X1_F3","X1_PYME","X1_GRPSXG","X1_HELP","X1_PICTURE","X1_IDFIL"})
o:TableData("SX1"  ,{"MTA112"  ,"07"      ,"Avaliar ?" ,"Avaliar ?","Avaliar ?","MV_CH7"    ,"N"       , 1          , 0          , 0          ,"C"     ,""        ,"MV_PAR07","Solic. Compras",""          ,""          ,""        ,""        ,"Contratos",""          ,""          ,""        ,""        ,""        ,""          ,""          ,""        ,""        ,""        ,""          ,""          ,""        ,""        ,""        ,""          ,""          ,""        ,""     ,"S"       ,""         ,""       ,""          ,""        })


//*************************** SX3
o:TableStruct("SX3",{"X3_CAMPO" ,"X3_VALID"               },2)
o:TableData  ("SX3",{"WB_DESCO" ,"APE100Crit('DESCONTO')" })

//MCF - 01/09/2015 - Projeto de Estabilização do EIC mas será revisado.
o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_USADO" },2)
o:TableData  ("SX3",{"YA_NOIDIOM" ,TODOS_AVG  })
o:TableData  ("SX3",{"YA_PAIS_I"  ,TODOS_AVG  })
o:TableData  ("SX3",{"YA_IDIOMA"  ,TODOS_AVG  })

o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_WHEN" },2)
o:TableData  ("SX3",{"YG_FABLOJ" ,".F."     })


//*************************** SX6
o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                    ,"X6_DSCSPA","X6_DSCENG","X6_DESC1"                                       ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2"                                           ,"X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"})
o:TableData("SX6"  ,{"  "       ,"MV_EIC0060" ,"C"      ,"Despesas de importação base de ICMS que serão" ,""         ,           ,"rateadas pela quantidade de adições. Informe os",""          ,""          ,"códigos, com separador. Ex.: 401/405/408..."        ,""          ,""          ,""          ,""          ,""          ,""         ,""       })


//*************************** SX7
o:TableStruct("SX7",{'X7_CAMPO' ,'X7_SEQUENC','X7_CDOMIN' })
o:TableData  ('SX7',{'W1_COD_I' ,'001'       ,'W1_COD_DES'})

//LRS - 12/01/2015 - Correção da Picture e tamanho do campo
o:TableStruct("SX3"  ,{"X3_CAMPO"  ,"X3_PICTURE"                                 },2)
o:TableData  ("SX3"  ,{"YD_DESTAQU","@R 999/999/999/999/999/999/999/999/999/999" })
Return Nil

/*
Funcao                     : UPDEIC007
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      : Marcos Cavini - MCF
Data/Hora   			      : 29/10/2015 - 09:34
Data/Hora Ultima alteração :
Revisao                    :
Obs.                       :
*/

Function UPDEIC007(o)
Local cUsado := ""
Local aHelp:= {}

//MCF - 29/10/2015
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_TITULO"   ,"X3_TITSPA"   ,"X3_TITENG"   ,"X3_DESCRIC"     ,"X3_DESCSPA"     ,"X3_DESCENG"     },2)
o:TableData  ("SX3",{"W9_FRETEIN" ,"Intl Freigh" ,"Intl Freigh" ,"Intl Freigh" ,"Intl Freigh"    ,"Intl Freigh"    ,"Intl Freigh"    })

//MCF - 17/11/2015
o:TableStruct('SX2',{'X2_CHAVE','X2_UNICO'                                      })
o:TableData  ('SX2',{"EVJ"     ,'EVJ_FILIAL+EVJ_TEC+EVJ_EX+EVJ_ASSUNT+EVJ_ALIQ' })

//MCF - 24/11/2015
o:TableStruct("SX3",{"X3_CAMPO"      ,"X3_USADO"   },2)
o:TableData("SX3"  ,{"YD_MAJ_COF"    ,TODOS_MODULOS})
//LRS - 23/03/2017
o:TableData("SX3"  ,{"W3_FLUXO"      ,TODOS_MODULOS})

//LRS - 26/11/2015
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_VISUAL" ,"X3_WHEN","X3_F3"   },2)
o:TableData  ("SX3",{"W6_FORNECF" , "A"         ,""       ,"FOR"     })
o:TableData  ("SX3",{"W6_FORNECS" , "A"         ,""       ,"FOR"     })
o:TableData  ("SX3",{"W6_FORNECS" , "A"         ,""       ,"FOR"     })

o:TableStruct("SX3",{"X3_CAMPO"   , "X3_VISUAL" ,"X3_WHEN"   },2)
o:TableData  ("SX3",{"W6_LOJAF"   , "A"         ,""  })
o:TableData  ("SX3",{"W6_LOJAS"   , "A"         ,""  })
o:TableData  ("SX3",{"W6_VMDIOBS" ,             ,"DI400ENC(7)"  })

o:TableStruct("SX3",{"X3_ARQUIVO","X3_ORDEM","X3_CAMPO","X3_TIPO","X3_TAMANHO","X3_DECIMAL","X3_TITULO"  ,"X3_TITSPA"  ,"X3_TITENG" ,"X3_DESCRIC"                ,"X3_DESCSPA"                ,"X3_DESCENG"                ,"X3_PICTURE","X3_VALID"                                                  ,"X3_USADO"   ,"X3_RELACAO","X3_F3","X3_NIVEL","X3_RESERV","X3_CHECK","X3_TRIGGER","X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX","X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN","X3_INIBRW","X3_GRPSXG","X3_FOLDER","X3_PYME","X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"})
o:TableData("SX3"  ,{"SYT"       ,"35"      ,"YT_FORN" ,"C"      ,6           ,0           ,"Fornecedor" ,"Fornecedor" ,"Fornecedor","Fornecedor Por Conta Orde" ,"Fornecedor Por Conta Orde" ,"Fornecedor Por Conta Orde" ,"@!"        ,"IF(M->YT_FORN==SA2->A2_COD,.T.,ExistCPO('SA2',M->YT_FORN))",TODOS_MODULOS,""          ,"SA2A" ,0         ,TAM+DEC    ,""        ,""          ,""         ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,"001"      ,"1"        ,"S"      ,            ,           ,           ,            ,           ,         })
o:TableData("SX3"  ,{"SYT"       ,"36"      ,"YT_LOJA" ,"C"      ,2           ,0           ,"Loja Forn." ,"Loja Forn." ,"Loja Forn.","Loja do Fornecedor Conta"  ,"Loja do Fornecedor Conta"  ,"Loja do Fornecedor Conta"  ,"@!"        ,"ExistCPO('SA2',M->YT_FORN+M->YT_LOJA)"                     ,TODOS_MODULOS,""          ,""     ,0         ,TAM+DEC    ,""        ,""          ,""         ,"S"        ,"A"        ,"R"         ,""          ,""          ,""       ,""          ,""          ,""          ,""       ,""         ,"002"      ,"1"        ,"S"      ,            ,           ,           ,            ,           ,         })

o:TableStruct("SX3",{"X3_ARQUIVO","X3_ORDEM","X3_CAMPO"  ,"X3_TIPO","X3_TAMANHO","X3_DECIMAL","X3_TITULO"    ,"X3_TITSPA"   ,"X3_TITENG"   ,"X3_DESCRIC"          ,"X3_DESCSPA"        ,"X3_DESCENG"           ,"X3_PICTURE"    ,"X3_VALID"  ,"X3_USADO"    ,"X3_RELACAO","X3_F3","X3_NIVEL","X3_RESERV","X3_CHECK","X3_TRIGGER","X3_PROPRI","X3_BROWSE","X3_VISUAL","X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX","X3_CBOXSPA","X3_CBOXENG","X3_PICTVAR","X3_WHEN","X3_INIBRW","X3_GRPSXG","X3_FOLDER","X3_PYME","X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"})
o:TableData("SX3"  ,{"EIW"        ,"29"       ,"EIW_ALCOFM","N"       ,6            ,2       ,"% M. COFINS"  ,"% M. COFINS" ,"% M. COFINS" ,"% Majorado Cofins"   ,"% Majorado Cofins"  ,"% Majorado Cofins"   ,"@E 999.99"     ,"Positivo()",TODOS_MODULOS ,""          ,""       ,0          ,TAM+DEC    ,""          ,""           ,""           ,"N"         ,""          ,""           ,""            ,""           ,""        ,""           ,""            ,""           ,""        ,""          ,""           ,"1"         ,""        ,              ,             ,            ,              ,             ,         })
o:TableData("SX3"  ,{"EIW"        ,"30"       ,"EIW_VLCOFM","N"       ,9            ,2       ,"Vl. M.COFINS" ,"Vl. M.COFINS","Vl. M.COFINS","Vl. Majorado Cofins" ,"Vl. Majorado Cofins","Vl. Majorado Cofins" ,"@E 999,999.99" ,"Positivo()",TODOS_MODULOS ,""          ,""       ,0          ,TAM+DEC    ,""          ,""           ,""           ,"N"         ,""          ,""           ,""            ,""           ,""        ,""           ,""            ,""           ,""        ,""          ,""           ,"1"         ,""        ,              ,             ,            ,              ,             ,         })
o:TableData("SX3"  ,{"EIW"        ,"31"       ,"EIW_ALPISM","N"       ,6            ,2       ,"% M. PIS"     ,"% M. PIS"    ,"% M. PIS"    ,"% Majorado PIS"      ,"% Majorado PIS"     ,"% Majorado PIS"      ,"@E 999.99"     ,"Positivo()",TODOS_MODULOS ,""          ,""       ,0          ,TAM+DEC    ,""          ,""           ,""           ,"N"         ,""          ,""           ,""            ,""           ,""        ,""           ,""            ,""           ,""        ,""          ,""           ,"1"         ,""        ,              ,             ,            ,              ,             ,         })
o:TableData("SX3"  ,{"EIW"        ,"32"       ,"EIW_VLPISM","N"       ,9            ,2       ,"Vl. M.PIS"    ,"Vl. M.PIS"   ,"Vl. M.PIS"   ,"Vl. Majorado PIS"    ,"Vl. Majorado PIS"   ,"Vl. Majorado PIS"    ,"@E 999,999.99" ,"Positivo()",TODOS_MODULOS ,""          ,""       ,0          ,TAM+DEC    ,""          ,""           ,""           ,"N"         ,""          ,""           ,""            ,""           ,""        ,""           ,""            ,""           ,""        ,""          ,""           ,"1"         ,""        ,              ,             ,            ,              ,             ,         })
o:TableData("SX3"  ,{"EIW"        ,"34"       ,"EIW_PERPIS","N"       ,6            ,2       ,"% PIS"        ,"% PIS"       ,"% PIS"       ,"% PIS"               ,"% PIS"              ,"% PIS"               ,"@E 999.99"     ,"Positivo()",TODOS_MODULOS ,""          ,""       ,0          ,TAM+DEC    ,""          ,""           ,""           ,"N"         ,""          ,""           ,""            ,""           ,""        ,""           ,""            ,""           ,""        ,""          ,""           ,"1"         ,""        ,              ,             ,            ,              ,             ,         }) //MCF - 09/02/2015 - Alíquota PIS/COFINS
o:TableData("SX3"  ,{"EIW"        ,"35"       ,"EIW_PERCOF","N"       ,6            ,2       ,"% COFINS"     ,"% COFINS"    ,"% COFINS"    ,"% COFINS"            ,"% COFINS"           ,"% COFINS"            ,"@E 999.99"     ,"Positivo()",TODOS_MODULOS ,""          ,""       ,0          ,TAM+DEC    ,""          ,""           ,""           ,"N"         ,""          ,""           ,""            ,""           ,""        ,""           ,""            ,""           ,""        ,""          ,""           ,"1"         ,""        ,              ,             ,            ,              ,             ,         })

o:TableStruct("HELP" ,{"NOME"      ,"PROBLEMA"                           ,"SOLUCAO"})
o:TableData("HELP"   ,{"YT_FORN"   ,"Fornecedor Por Conta e Ordem"       ,""       })
o:TableData("HELP"   ,{"YT_LOJA"   ,"Loja do Fornecedor Conta e Ordem"   ,""       })
o:TableData("HELP"   ,{"EIW_ALCOFM","Percentual de Majoração de COFINS"  ,""       })
o:TableData("HELP"   ,{"EIW_VLCOFM","Valor Majorado de COFINS"           ,""       })
o:TableData("HELP"   ,{"EIW_ALPISM","Percentual de Majoração de PIS"     ,""       })
o:TableData("HELP"   ,{"EIW_VLPISM","Valor Majorado de PIS"              ,""       })
o:TableData("HELP"   ,{"EIW_PERPIS","Percentual de PIS"                  ,""       })
o:TableData("HELP"   ,{"EIW_PERCOF","Percentual de COFINS"               ,""       })

o:TableStruct('SX3',{'X3_ARQUIVO','X3_ORDEM','X3_CAMPO','X3_TIPO','X3_TAMANHO','X3_DECIMAL','X3_TITULO','X3_TITSPA','X3_TITENG','X3_DESCRIC','X3_DESCSPA','X3_DESCENG','X3_PICTURE','X3_VALID','X3_USADO','X3_RELACAO','X3_F3','X3_NIVEL','X3_RESERV','X3_CHECK','X3_TRIGGER','X3_PROPRI','X3_BROWSE','X3_VISUAL','X3_CONTEXT','X3_OBRIGAT','X3_VLDUSER','X3_CBOX','X3_CBOXSPA','X3_CBOXENG','X3_PICTVAR','X3_WHEN','X3_INIBRW','X3_GRPSXG','X3_FOLDER','X3_PYME','X3_CONDSQL','X3_CHKSQL','X3_IDXSRV','X3_ORTOGRA','X3_IDXFLD','X3_TELA'})
o:TableData('SX3',{'EVF','15','EVF_VLQUN','C',25,0,'V.PLq Un',,,'Valor Peso Liquido Unitario Kg',,,,,,,,,,,,,'S','A','R',,,,,,,,,,,,,,,,,})
o:TableData('SX3',{'EVF','16','EVF_VLQTO','C',25,0,'V.PLq To',,,'Valor Peso Liquido Total Kg',,,,,,,,,,,,,'S','A','R',,,,,,,,,,,,,,,,,})
o:TableData('SX3',{'EVF','17','EVF_VLLEU','C',25,0,'V.Un Loc Emb',,,'Valor Local Embarque Unitario',,,,,,,,,,,,,'S','A','R',,,,,,,,,,,,,,,,,})
o:TableData('SX3',{'EVF','18','EVF_VLTO2','C',25,0,'V.Tot Loc Emb',,,'Valor Local Embarque Total',,,,,,,,,,,,,'S','A','R',,,,,,,,,,,,,,,,,})
o:TableData('SX3',{'EVF','19','EVF_QTUNME','C',20,0,'Qtd Uni Esta',,,'Qtd Unid Estatistica',,,,,,,,,,,,,'S','A','R',,,,,,,,,,,,,,,,,})

//MCF - 28/12/2015
o:TableStruct('SX1',{'X1_GRUPO','X1_ORDEM','X1_VALID'                              })
o:TableData('SX1'  ,{'EICFI5'  ,"02"      ,"Vazio() .OR. ExistCpo('SED',MV_PAR02)" })

//MCF - 30/12/2015
o:TableStruct("SX3",{"X3_CAMPO" ,"X3_VALID"            },2)
o:TableData("SX3"  ,{"WB_MOEDA" ,"APE100Crit('MOEDA')" })

//LRS - 12/01/2016 - Definir campo como todos os Modulos
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_USADO"     },2)
o:TableData  ("SX3"  ,{"EWZ_HAWB" ,"TODOS_MODULO" })

o:TableStruct("SX3"  ,{"X3_CAMPO"  ,"X3_PICTURE"                                 },2)
o:TableData  ("SX3"  ,{"YD_DESTAQU","@R 999/999/999/999/999/999/999/999/999/999" })

//MCF - 26/01/2016
o:TableStruct("SX3"  ,{"X3_CAMPO"   ,"X3_USADO" },2)
o:TableData  ("SX3"  ,{"C1_COTACAO" ,EIC_USADO  })
o:TableData  ("SX3"  ,{"C1_NUM_SI"  ,EIC_USADO  })

o:TableStruct("SX3",{"X3_CAMPO"		,"X3_USADO"   ,"X3_TAMANHO" },2)
o:TableData("SX3"  ,{"EIC_HAWB"      ,TODOS_AVG ,             })
o:TableData("SX3"  ,{"EIC_DT_DES"    ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_DESPES"    ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_DESCDE"    ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_VALOR"     ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_BASEAD"    ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_DT_EFE"    ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_DOCTO"     ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_ARQ"       ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_USER"      ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_PAGOPO"    ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_CODINT"    ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_FORN"      ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_LOJA"      ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_GERFIN"    ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_LIBERA"    ,TODOS_AVG, 50          })
o:TableData("SX3"  ,{"EIC_ID"        ,TODOS_AVG,             })
o:TableData("SX3"  ,{"EIC_ID_APR"    ,TODOS_AVG,             })

o:TableStruct("SX3",{"X3_ARQUIVO" ,"X3_ORDEM" ,"X3_CAMPO"   ,"X3_TIPO" ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_TITULO"     ,"X3_TITSPA"     ,"X3_TITENG"           ,"X3_DESCRIC"           ,"X3_DESCSPA"              ,"X3_DESCENG"                ,"X3_PICTURE" ,"X3_VALID"  ,"X3_USADO"      ,"X3_RELACAO"     ,"X3_F3" ,"X3_NIVEL" ,"X3_RESERV"     ,"X3_CHECK","X3_TRIGGER" ,"X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX"                    ,"X3_CBOXSPA"   ,"X3_CBOXENG"  ,"X3_PICTVAR" ,"X3_WHEN" ,"X3_INIBRW" ,"X3_GRPSXG"   ,"X3_FOLDER"    ,"X3_PYME"  ,"X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"})
o:TableData("SX3"  ,{"EIC"        ,"20"       ,"EIC_ID_APR" ,"C"       ,10           ,0            ,"ID WF APR"     ,"ID WF"       ,"ID WF"             , "ID WorkFlow Aprovacao"             ,"ID WorkFlow Aprovacao"             ,"ID WorkFlow Aprovacao"               , ""          ,""          ,TODOS_MODULOS   ,""               ,""      ,0          ,TAM+DEC         ,""         ,""           ,""         ,"N"         ,"V"          ,""          ,""          ,""          ,""                           ,""             ,""            ,""           ,""        ,""          ,""            ,"1"            ,""         ,            ,           ,           ,            ,           ,         })

o:TableStruct("HELP" ,{"NOME"         ,"PROBLEMA"       })
o:TableData("HELP"   ,{"EIC_ID_APR"   ,"ID WorkFlow Aprovação de Despesas"})

o:TableStruct("WF2",{"WF2_PROC","WF2_STATUS" ,"WF2_DESCR"},1)
o:TableData("WF2"  ,{"SI"      ,"10001"      ,"EMAIL ENVIADO"    })
o:TableData("WF2"  ,{"SI"      ,"10002"      ,"EMAIL RESPONDIDO" })
o:TableData("WF2"  ,{"SI"      ,"10003"      ,"TIME OUT"         })
o:TableData("WF2"  ,{"PO"      ,"10001"      ,"EMAIL ENVIADO"    })
o:TableData("WF2"  ,{"PO"      ,"10002"      ,"EMAIL RESPONDIDO" })
o:TableData("WF2"  ,{"PO"      ,"10003"      ,"TIME OUT"         })
o:TableData("WF2"  ,{"PU"      ,"10001"      ,"EMAIL ENVIADO"    })
o:TableData("WF2"  ,{"PU"      ,"10002"      ,"EMAIL RESPONDIDO" })
o:TableData("WF2"  ,{"PU"      ,"10003"      ,"TIME OUT"         })
o:TableData("WF2"  ,{"PLI"     ,"10001"      ,"EMAIL ENVIADO"    })
o:TableData("WF2"  ,{"PLI"     ,"10002"      ,"EMAIL RESPONDIDO" })
o:TableData("WF2"  ,{"PLI"     ,"10003"      ,"TIME OUT"         })
o:TableData("WF2"  ,{"EMB"     ,"10001"      ,"EMAIL ENVIADO"    })
o:TableData("WF2"  ,{"EMB"     ,"10002"      ,"EMAIL RESPONDIDO" })
o:TableData("WF2"  ,{"EMB"     ,"10003"      ,"TIME OUT"         })
o:TableData("WF2"  ,{"DES"     ,"10001"      ,"EMAIL ENVIADO"    })
o:TableData("WF2"  ,{"DES"     ,"10002"      ,"EMAIL RESPONDIDO" })
o:TableData("WF2"  ,{"DES"     ,"10003"      ,"TIME OUT"         })
o:TableData("WF2"  ,{"PRV"     ,"10001"      ,"EMAIL ENVIADO"    })
o:TableData("WF2"  ,{"PRV"     ,"10002"      ,"EMAIL RESPONDIDO" })
o:TableData("WF2"  ,{"PRV"     ,"10003"      ,"TIME OUT"         })
o:TableData("WF2"  ,{"NF"      ,"10001"      ,"EMAIL ENVIADO"    })
o:TableData("WF2"  ,{"NF"      ,"10002"      ,"EMAIL RESPONDIDO" })
o:TableData("WF2"  ,{"NF"      ,"10003"      ,"TIME OUT"         })
o:TableData("WF2"  ,{"NM"      ,"10001"      ,"EMAIL ENVIADO"    })
o:TableData("WF2"  ,{"NM"      ,"10002"      ,"EMAIL RESPONDIDO" })
o:TableData("WF2"  ,{"NM"      ,"10003"      ,"TIME OUT"         })
o:TableData("WF2"  ,{"NM2"     ,"10001"      ,"EMAIL ENVIADO"    })
o:TableData("WF2"  ,{"NM2"     ,"10002"      ,"EMAIL RESPONDIDO" })
o:TableData("WF2"  ,{"NM2"     ,"10003"      ,"TIME OUT"         })
o:TableData("WF2"  ,{"CB"      ,"10001"      ,"EMAIL ENVIADO"    })
o:TableData("WF2"  ,{"CB"      ,"10002"      ,"EMAIL RESPONDIDO" })
o:TableData("WF2"  ,{"CB"      ,"10003"      ,"TIME OUT"         })
o:TableData("WF2"  ,{"LQ"      ,"10001"      ,"EMAIL ENVIADO"    })
o:TableData("WF2"  ,{"LQ"      ,"10002"      ,"EMAIL RESPONDIDO" })
o:TableData("WF2"  ,{"LQ"      ,"10003"      ,"TIME OUT"         })

o:TableStruct("EJ7",{"EJ7_COD"     ,"EJ7_DESC"                               ,"EJ7_ATIVO","EJ7_HTML"    ,"EJ7_HTMLI"    ,"EJ7_HTMAN"     ,"EJ7_VMDEST","EJ7_COPIA" ,"EJ7_COPOC","EJ7_ASSUNT"                                     ,"EJ7_TIMEOU" ,"EJ7_TIMEHR" ,"EJ7_TIMEMI" ,"EJ7_FUNCRE" ,"EJ7_FUNCEN" ,"EJ7_TIPO" ,"EJ7_FUNCVA" ,"EJ7_TIPORE","EJ7_TIPSRV","EJ7_CHAVES"                                         ,"EJ7_FASE"       ,"EJ7_MODULO"},1)
o:TableData("EJ7"  ,{"SI"          ,"SOLICITAÇÃO DE IMPORTAÇÃO"              ,"2"        ,"EasyExecWF('EASYWFSI')"  ,"H_EASYWFLINK" ,"H_EASYWFANEXO" ,""        ,""          ,""         ,"WorkFlow - Solicitação de Importação"           ,0          ,0          ,0          ,""           ,"EICWFSIENV" ,"1"        ,"EICWFSIVAR" ,"1"         ,"1"         ,"If(Inclui,xFilial('SW0')+M->(W0__CC+W0__NUM),)" ,"SOLIC IMPORT"   ,"EIC"       })
o:TableData("EJ7"  ,{"PO"          ,"ITENS ANUENTES DO PURCHASE ORDER"       ,"2"        ,"EasyExecWF('EASYWFPO')"  ,"H_EASYWFLINK" ,"H_EASYWFANEXO" ,""        ,""          ,""         ,"WorkFlow - Purchase Order"                      ,0          ,0          ,0          ,""           ,"EICWFPOENV" ,"1"        ,"EICWFPOVAR" ,"1"         ,"1"         ,"EICWFPOCOND()"                                  ,"PURCHASE ORDER" ,"EIC"       })
o:TableData("EJ7"  ,{"PU"          ,"PREVISAO DE EMBARQUE DO PURCHASE ORDER" ,"2"        ,"EasyExecWF('EASYWFPU')"  ,"H_EASYWFLINK" ,"H_EASYWFANEXO" ,""        ,""          ,""         ,"WorkFlow - Purchase Order"                      ,0          ,0          ,0          ,""           ,"EICWFPUENV" ,"1"        ,"EICWFPUVAR" ,"1"         ,"1"         ,"EICWFPUCOND()"                                  ,"PURCHASE ORDER" ,"EIC"       })
o:TableData("EJ7"  ,{"PLI"         ,"PREPARAÇÃO DE LICENÇA DE IMPORTAÇÃO"    ,"2"        ,"EasyExecWF('EASYWFPLI')" ,"H_EASYWFLINK" ,"H_EASYWFANEXO" ,""        ,""          ,""         ,"WorkFlow - Preparação de Licença de Importação" ,0          ,0          ,0          ,""           ,"EICWFLIENV" ,"1"        ,"EICWFLIVAR" ,"1"         ,"1"         ,"If(Inclui,xFilial('SW4')+M->W4_PGI_NUM,)"       ,"LICENCA IMPORT" ,"EIC"       })
o:TableData("EJ7"  ,{"EMB"         ,"EMBARQUE"                               ,"2"        ,"EasyExecWF('EASYWFEMB')" ,"H_EASYWFLINK" ,"H_EASYWFANEXO" ,""        ,""          ,""         ,"WorkFlow - Embarque"                            ,0          ,0          ,0          ,""           ,"EICWFEBENV" ,"1"        ,"EICWFEBVAR" ,"1"         ,"1"         ,"EICWFEBCOND()"                                  ,"EMBARQUE_EIC"   ,"EIC"       })
o:TableData("EJ7"  ,{"DES"         ,"ENCERRAMENTO"                           ,"2"        ,"EasyExecWF('EASYWFDES')" ,"H_EASYWFLINK" ,"H_EASYWFANEXO" ,""        ,""          ,""         ,"WorkFlow - Processo encerrado"                  ,0          ,0          ,0          ,""           ,"EICWFDSENV" ,"1"        ,"EICWFDSVAR" ,"1"         ,"1"         ,"EICWFDSCOND()"                                  ,"EMBARQUE_EIC"   ,"EIC"       })
o:TableData("EJ7"  ,{"PRV"         ,"PREVISAO DE ENTREGA"                    ,"2"        ,"EasyExecWF('EASYWFPRV')" ,"H_EASYWFLINK" ,"H_EASYWFANEXO" ,""        ,""          ,""         ,"WorkFlow - Previsão de Entrega"                 ,0          ,0          ,0          ,""           ,"EICWFPVENV" ,"1"        ,"EICWFPVVAR" ,"1"         ,"1"         ,"EICWFPVCOND()"                                  ,"EMBARQUE_SCH_EIC","EIC"      })  // GFP - 26/08/2012
o:TableData("EJ7"  ,{"NF"          ,"NOTA FISCAL"                            ,"2"        ,"EasyExecWF('EASYWFNF')"  ,"H_EASYWFLINK" ,"H_EASYWFANEXO" ,""        ,""          ,""         ,"WorkFlow - Nota Fiscal"                         ,0          ,0          ,0          ,""           ,"EICWFNFENV" ,"1"        ,"EICWFNFVAR" ,"1"         ,"1"         ,"xFilial('SW6')+SW6->W6_HAWB"                    ,"NOTA FISCAL"    ,"EIC"       })
o:TableData("EJ7"  ,{"NM"          ,"ADIANTAMENTO NUMERARIO"                 ,"2"        ,"EasyExecWF('EASYWFNM')"  ,"H_EASYWFLINK" ,"H_EASYWFANEXO" ,""        ,""          ,""         ,"WorkFlow - Numerario"                           ,0          ,0          ,0          ,""           ,"EICWFNMENV" ,"1"        ,"EICWFNMVAR" ,"1"         ,"1"         ,"EICWFNM2COND(1)"       ,"NUMERARIO_EIC"  ,"EIC"       })  // GFP - 14/08/2012
o:TableData("EJ7"  ,{"CB"          ,"CAMBIO"                                 ,"2"        ,"EasyExecWF('EASYWFCB')"  ,"H_EASYWFLINK" ,"H_EASYWFANEXO" ,""        ,""          ,""         ,"WorkFlow - Câmbio"                              ,0          ,0          ,0          ,""           ,"EICWFCBENV" ,"1"        ,"EICWFCBVAR" ,"1"         ,"1"         ,"EICWFCBCOND()"                                  ,"CAMBIO_SCH_EIC" ,"EIC"       })  // GFP - 26/08/2012
o:TableData("EJ7"  ,{"LQ"          ,"LIQUIDACAO DE CAMBIO"                   ,"2"        ,"EasyExecWF('EASYWFLQ')"  ,"H_EASYWFLINK" ,"H_EASYWFANEXO" ,""        ,""          ,""         ,"WorkFlow - Liquidação de Parcela de Câmbio"     ,0          ,0          ,0          ,""           ,"EICWFLQENV" ,"1"        ,"EICWFLQVAR" ,"1"         ,"1"         ,"EICWFLQCOND()"                                  ,"CAMBIO_EIC"     ,"EIC"       })
o:TableData("EJ7"  ,{'NM2'         ,'APROVACAO DE NUMERARIO'                 ,'2'        ,"EasyExecWF('EASYWFN2M')" ,'H_EASYWFLINK' ,'H_EASYWFANEXO' ,''        ,''          ,''         ,'WorkFlow - Aprovacao de Numerario'              ,0          ,0          ,0          ,"EICWFNM2RET",'EICWFNM2ENV','1'        ,'EICWFNM2VAR','1'         ,'1'         ,'EICWFNM2COND(2)'       ,'NUMERARIO_EIC'  ,"EIC"       })  // GFP - 18/01/2016

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID"              ,"X3_WHEN"                 },2)
o:TableData("SX3"  ,{"W2_FREINC"  ,                        ,"PO400When('W2_FREINC')"  })
o:TableData("SX3"  ,{"W2_FRETEIN" ,                        ,"PO400When('W2_FRETEIN')" })
o:TableData("SX3"  ,{"W2_INLAND"  ,"PO420VAL('W2_INLAND')" ,"PO400When('W2_INLAND')"  })
o:TableData("SX3"  ,{"W2_DESCONT" ,"PO420VAL('W2_DESCONT')","PO400When('W2_DESCONT')" })
o:TableData("SX3"  ,{"W2_PACKING" ,"PO420VAL('W2_PACKING')","PO400When('W2_PACKING')" })
o:TableData("SX3"  ,{"W4_FREINC"  ,                        ,"GI400When('W4_FREINC')"  })
o:TableData("SX3"  ,{"W4_FRETEIN" ,                        ,"GI400When('W4_FRETEIN')" })
o:TableData("SX3"  ,{"W4_INLAND"  ,                        ,"GI400When('W4_INLAND')"  })
o:TableData("SX3"  ,{"W4_DESCONT" ,                        ,"GI400When('W4_DESCONT')" })
o:TableData("SX3"  ,{"W4_PACKING" ,                        ,"GI400When('W4_PACKING')" })

//Alterado para .T. MFR MTRADE-1011 TE-5740 20/06/2017, REFEITO NA 14
/*
o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_WHEN" },2)
o:TableData("SX3"  ,{"EW4_FRETEI"  ,".F."     })
o:TableData("SX3"  ,{"EW4_SEGURO"  ,".F."     })
o:TableData("SX3"  ,{"EW4_INLAND"  ,".F."     })
o:TableData("SX3"  ,{"EW4_PACKIN"  ,".F."     })
o:TableData("SX3"  ,{"EW4_DESCON"  ,".F."     })
*/

o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_WHEN" },2)
o:TableData("SX3"  ,{"EW4_FREINC"  ,".F."     })
o:TableData("SX3"  ,{"EW4_SEGINC"  ,".F."     })
o:TableData("SX3"  ,{"EW4_RATPOR"  ,".F."     })

o:TableStruct("SX3",{"X3_CAMPO" ,"X3_VALID"},2)
o:TableData("SX3"  ,{"B1_POSIPI","Vazio() .Or. If(cModulo$'EEC/EDC/EIC/ESS',AC120Valid('B1_POSIPI'),.T.)"})

o:TableStruct("SX7",{"X7_CAMPO"  ,"X7_SEQUENC","X7_REGRA"         ,"X7_CDOMIN","X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE","X7_CONDIC","X7_PROPRI"})
o:TableData("SX7"  ,{"W2_SEGINC" ,"001"       ,"PO400REL('TOTAL')","W2_FOB_GER","P"      ,"N"      ,""       ,""        ,""        ,""         ,"S"        })
o:TableData("SX7"  ,{"W2_SEGURIN","001"       ,"PO400REL('TOTAL')","W2_FOB_GER","P"      ,"N"      ,""       ,""        ,""        ,""         ,"S"        })

o:TableStruct("HELP" ,{"NOME"      ,"PROBLEMA"                     })
o:TableData("HELP"   ,{"PO400SGNEG","Valor do Seguro não pode ser negativo."  })

//MCF - 30/03/2016
o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_TITULO"     ,"X3_DESCRICAO" },2)
o:TableData("SX3"  ,{"W6_FOB_GER"  ,"Total Invoic"  ,"Total Invoice"})

o:TableStruct("SX3",{"X3_ARQUIVO" ,"X3_ORDEM" ,"X3_CAMPO"    ,"X3_TIPO" ,"X3_TAMANHO" ,"X3_DECIMAL" ,"X3_TITULO"      ,"X3_TITSPA"      ,"X3_TITENG"         ,"X3_DESCRIC"           ,"X3_DESCSPA"         ,"X3_DESCENG"        ,"X3_PICTURE"             ,"X3_VALID"  ,"X3_USADO"    ,"X3_RELACAO"                                                                        ,"X3_F3" ,"X3_NIVEL" ,"X3_RESERV"     ,"X3_CHECK" ,"X3_TRIGGER" ,"X3_PROPRI" ,"X3_BROWSE" ,"X3_VISUAL" ,"X3_CONTEXT","X3_OBRIGAT","X3_VLDUSER","X3_CBOX","X3_CBOXSPA" ,"X3_CBOXENG","X3_PICTVAR","X3_WHEN","X3_INIBRW" ,"X3_GRPSXG","X3_FOLDER","X3_PYME","X3_CONDSQL","X3_CHKSQL","X3_IDXSRV","X3_ORTOGRA","X3_IDXFLD","X3_TELA"})
o:TableData("SX3"  ,{"SW6"        ,""         ,"W6_TOT_PRO"  ,"N"       ,15           ,2            ,"Total Processo" ,"Total Processo" ,"Total Processo"    ,"Total do Processo"    ,"Total do Processo"  ,"Total do Processo" ,"@E 999,999,999,999.99"  ,""          ,TODOS_MODULOS ,"M->(W6_VLMLEMN+W6_INLAND+W6_PACKING+W6_FRETEIN+W6_VLSEGMN+W6_OUTDESP-W6_DESCONT)"  ,""      ,1          ,""              ,""         ,""           ,""          ,"N"         ,"V"         ,"V"         ,""          ,""          ,""       ,""           ,""          ,""          ,""       ,""          ,""         ,"4"        ,""       ,            ,           ,           ,            ,           ,         })

o:TableData("HELP"   ,{"W6_TOT_PRO","Total invoice + Despesas Internacionais",""})

//MCF - 31/03/2016
o:TableStruct('SX1',{'X1_GRUPO','X1_ORDEM','X1_F3' })
o:TableData('SX1'  ,{'EICTMB'  ,"01"      ,"MOT"   })

o:TableStruct("SX3",{"X3_CAMPO"      ,"X3_USADO"   },2)
o:TableData("SX3"  ,{"EYI_FILEXE"    ,TODOS_MODULOS})

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_TRIGGER"  },2)
o:TableData("SX3"  ,{"W6_DI_NUM"  ,"S"           })

//LGS-25/04/2016
o:TableStruct("SX3",{"X3_CAMPO"      ,"X3_USADO"   },2)
o:TableData("SX3"  ,{"D3_ITEMSWN"    ,EIC_USADO    })

//LRS - 17/05/2016
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"    ,"XB_DESCSPA" ,"XB_DESCENG" ,"XB_CONTEM"      })
o:TableData('SXB',  {'BCOEIC'  ,'1'      ,'01'    ,'DB'       ,'Banco'        ,""           ,""           ,'SA6'            })
o:TableData('SXB',  {'BCOEIC'  ,'2'      ,'01'    ,'01'       ,'Código'       ,""           ,""           ,""               })
o:TableData('SXB',  {'BCOEIC'  ,'2'      ,'02'    ,'02'       ,'Nome'         ,""           ,""           ,""               })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'01'    ,'01'       ,'Código'       ,""           ,""           ,"A6_COD"         })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'01'    ,'02'       ,'Agência'      ,""           ,""           ,"A6_AGENCIA"     })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'01'    ,'03'       ,'Conta'        ,""           ,""           ,"A6_NUMCON"      })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'01'    ,'04'       ,'Nome'         ,""           ,""           ,"A6_NREDUZ"      })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'02'    ,'01'       ,'Código'       ,""           ,""           ,"A6_COD"         })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'02'    ,'02'       ,'Agência'      ,""           ,""           ,"A6_AGENCIA"     })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'02'    ,'03'       ,'Conta'        ,""           ,""           ,"A6_NUMCON"      })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'02'    ,'04'       ,'Nome'         ,""           ,""           ,"A6_NREDUZ"      })
o:TableData('SXB',  {'BCOEIC'  ,'5'      ,'01'    ,""         ,""             ,""           ,""           ,"SA6->A6_COD"    })
o:TableData('SXB',  {'BCOEIC'  ,'5'      ,'02'    ,""         ,""             ,""           ,""           ,"SA6->A6_AGENCIA"})
o:TableData('SXB',  {'BCOEIC'  ,'5'      ,'03'    ,""         ,""             ,""           ,""           ,"SA6->A6_NUMCON" })
o:TableData('SXB',  {'BCOEIC'  ,'5'      ,'04'    ,""         ,""             ,""           ,""           ,"SA6->A6_NREDUZ" })

//Vias de transporte
o:TableData('SXB',  {'EOD'     ,'6'      ,'01'    ,""         ,""             ,""           ,""           ,"#CV100Filtro('W2_ORIGEM')" })
o:TableData('SXB',  {'EDE'     ,'6'      ,'01'    ,""         ,""             ,""           ,""           ,"#CV100Filtro('W2_DEST')" })

o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_F3"     },2)
o:TableData("SX3"  ,{"WB_BANCO"    ,"BCOEIC"    })

o:TableStruct("SIX",{"INDICE","ORDEM" ,"CHAVE"                                                                    ,"DESCRICAO"                                                           })
o:TableData("SIX"  ,{"SWT"   ,"6"     ,"WT_FILIAL+WT_NUMERP+WT_FORN+WT_FORLOJ+WT_COD_I","Numero ERP + Fornecedor + Loja + Cod. Item " })

//LGS-16/06/2016
o:TableStruct("SX3",{"X3_ARQUIVO" ,"X3_ORDEM", "X3_CAMPO"  },2)
o:TableData("SX3"  ,{"SW6"        ,"C7"      , "W6_VERSAO" } )
o:TableData("SX3"  ,{"SW6"        ,"K7"      , "W6_DI_OBS" } )
o:TableData("SX3"  ,{"SW6"        ,"K9"      , "W6_VWDIOBS"} )

//LGS-28/06/2016
o:TableStruct("SX3",{"X3_ARQUIVO" ,"X3_CAMPO"  ,"X3_VALID"                   },2)
o:TableData("SX3"  ,{"SWP"        ,"WP_REGIST" ,'GI400LSIVALID("WP_REGIST")' } )

//LRS - 30/06/2016
o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_TITULO"   ,"X3_DESCRIC"   },2)
o:TableData("SX3"  ,{"EE6_ETSORI"  ,"ETD Origem"  ,"ETD Origem"   })

o:TableStruct("HELP",{"NOME"         ,"PROBLEMA"                                             })
o:TableData("HELP"  ,{"EE6_ETSORI"   ,"Data estimada ou prevista da saída do navio no porto" })

//LRS - 06/06/2016
o:TableStruct("SX7",{"X7_CAMPO"  ,"X7_SEQUENC","X7_REGRA"                                                                                 ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE"                   ,"X7_CONDIC"            ,"X7_PROPRI"})
o:TableData("SX7"  ,{"B1_POSIPI" ,"002"       ,"IF (SYD->YD_ANUENTE <> '' .OR. SYD->YD_ANUENTE == '2',SYD->YD_ANUENTE, M->B1_ANUENTE)"    ,"B1_ANUENTE","P"      ,"S"      ,"SYD"     ,"1"       ,'xFilial("SYD")+M->B1_POSIPI',""                     ,"S"        })
//Revisão da regra de gatilhos do versionamento da DI
o:TableData  ('SX7',{'W6_DI_NUM','003'       ,"DI501Gatilho('W6_VMDIOBS_PREENCHER')"                                                       ,            ,         ,         ,          ,          ,                             ,"!EMPTY(M->W6_DI_NUM)",           })
o:TableData  ('SX7',{'W6_DI_NUM','004'       ,"DI501Gatilho('W6_VMDIOBS_LIMPAR')"                                                          ,            ,         ,         ,          ,          ,                             ,                      ,           })


//LRS - 18/07/2016
o:TableStruct("SX7",{'X7_CAMPO' ,'X7_SEQUENC','X7_CDOMIN'  ,'X7_CONDIC'            })
o:TableData  ('SX7',{'W2_FORN'  ,'001'       ,"W2_FORLOJ " ,"SA2->A2_MSBLQL <> '1'"})

o:TableStruct("SX3",{"X3_CAMPO" ,"X3_VALID"             },2)
o:TableData("SX3"  ,{"W2_FORN"  ,"PO420VAL('W2_FORN')" })

//LRS - 12/12/2016
o:TableStruct("SX7",{'X7_CAMPO' ,'X7_SEQUENC','X7_CDOMIN'  ,'X7_CONDIC'            })
o:TableData  ('SX7',{'W3_FABR'  ,'001'       ,"W3_FABLOJ " ,"SA2->A2_MSBLQL <> '1'"})

//GFP - 19/07/2016 - Melhoria Despesas por Container
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_VALID"                                                        ,"X3_CBOX"                                             ,"X3_WHEN"                },2)
o:TableData("SX3"  ,{"YB_IDVL"   ,"Pertence('12345') .and. EA110Valid()"                            ,"1=Valor;2=Percentual;3=Quantidade;4=Peso;5=Container",                         })
o:TableData("SX3"  ,{"YB_DESPBAS","EA110Valid()"                                                    ,                                                      ,"EA110WHEN('YB_DESPBAS')"})
o:TableData("SX3"  ,{"YB_MOEDA"  ,"EA110Valid()"                                                    ,                                                      ,"EA110WHEN('YB_MOEDA')"  })
o:TableData("SX3"  ,{"YB_QTDEDIA","EA110Valid()"                                                    ,                                                      ,"EA110WHEN('YB_QTDEDIA')"})
o:TableData("SX3"  ,{"YB_VAL_MAX","EA110Valid()"                                                    ,                                                      ,"EA110WHEN('YB_VAL_MAX')"})
o:TableData("SX3"  ,{"YB_VAL_MIN","EA110Valid()"                                                    ,                                                      ,"EA110WHEN('YB_VAL_MIN')"})
o:TableData("SX3"  ,{"YB_BASECUS","Pertence('12') .AND. EA110Valid()"                               ,                                                      ,"EA110WHEN('YB_BASECUS')"})
o:TableData("SX3"  ,{"YB_BASEIMP","Pertence('12') .AND. EA110Valid()"                               ,                                                      ,"EA110WHEN('YB_BASEIMP')"})
o:TableData("SX3"  ,{"YB_BASEICM","Pertence('12') .AND. A040valid('DESPESA') .AND. EA110Valid()"    ,                                                      ,"EA110WHEN('YB_BASEICM')"})
o:TableData("SX3"  ,{"YB_RATPESO","Pertence('12') .AND. EA110Valid()"                               ,                                                      ,"EA110WHEN('YB_RATPESO')"})
o:TableData("SX3"  ,{"YB_ICMSNFC","Pertence('12') .AND. EA110Valid()"                               ,                                                      ,"EA110WHEN('YB_ICMSNFC')"})
o:TableData("SX3"  ,{"WI_IDVL"   ,"Pertence('12345') .and. TC210Valid('WI_IDVL')"                   ,"1=Valor;2=Percentual;3=Quantidade;4=Peso;5=Container",                         })
o:TableData("SX3"  ,{"WI_DESPBAS",                                                                  ,                                                      ,"TC210WHEN('WI_DESPBAS')"})
o:TableData("SX3"  ,{"WI_PERCAPL",                                                                  ,                                                      ,"TC210WHEN('WI_PERCAPL')"})
o:TableData("SX3"  ,{"WI_VALOR"  ,                                                                  ,                                                      ,"TC210WHEN('WI_VALOR')"  })
o:TableData("SX3"  ,{"YB_PERCAPL",                                                                  ,                                                      ,"EA110WHEN('YB_PERCAPL')"})
o:TableData("SX3"  ,{"YB_KILO1"  ,                                                                  ,                                                      ,"EA110WHEN('YB_KILO1')"  })
o:TableData("SX3"  ,{"YB_KILO2"  ,                                                                  ,                                                      ,"EA110WHEN('YB_KILO2')"  })
o:TableData("SX3"  ,{"YB_KILO3"  ,                                                                  ,                                                      ,"EA110WHEN('YB_KILO3')"  })
o:TableData("SX3"  ,{"YB_KILO4"  ,                                                                  ,                                                      ,"EA110WHEN('YB_KILO4')"  })
o:TableData("SX3"  ,{"YB_KILO5"  ,                                                                  ,                                                      ,"EA110WHEN('YB_KILO5')"  })
o:TableData("SX3"  ,{"YB_KILO6"  ,                                                                  ,                                                      ,"EA110WHEN('YB_KILO6')"  })
o:TableData("SX3"  ,{"YB_VALOR"  ,                                                                  ,                                                      ,"EA110WHEN('YB_VALOR')"  })
o:TableData("SX3"  ,{"YB_VALOR1" ,                                                                  ,                                                      ,"EA110WHEN('YB_VALOR1')" })
o:TableData("SX3"  ,{"YB_VALOR2" ,                                                                  ,                                                      ,"EA110WHEN('YB_VALOR2')" })
o:TableData("SX3"  ,{"YB_VALOR3" ,                                                                  ,                                                      ,"EA110WHEN('YB_VALOR3')" })
o:TableData("SX3"  ,{"YB_VALOR4" ,                                                                  ,                                                      ,"EA110WHEN('YB_VALOR4')" })
o:TableData("SX3"  ,{"YB_VALOR5" ,                                                                  ,                                                      ,"EA110WHEN('YB_VALOR5')" })
o:TableData("SX3"  ,{"YB_VALOR6" ,                                                                  ,                                                      ,"EA110WHEN('YB_VALOR6')" })

o:TableStruct("HELP" ,{"NOME"     ,"PROBLEMA"                                                                                     ,"SOLUCAO"                                                          })
o:TableData("HELP"   ,{"W6_OUT_CTN","Descreve outros tipos de container, diferentes de 20 ou 40 pés.",""  })
o:TableData("HELP"   ,{"W6_OUTROS","Quantidade deste tipo de container diferente de 20' e 40'." ,""       })
o:TableData("HELP"   ,{"YB_CON20" ,"Valor de Container 20'"    ,""       })
o:TableData("HELP"   ,{"YB_CON40" ,"Valor de Container 40'"    ,""       })
o:TableData("HELP"   ,{"YB_CON40H","Valor de Container 40' HC" ,""       })
o:TableData("HELP"   ,{"YB_CONOUT","Valor de Container Outros" ,""       })
o:TableData("HELP"   ,{"WI_CON20" ,"Valor de Container 20'"    ,""       })
o:TableData("HELP"   ,{"WI_CON40" ,"Valor de Container 40'"    ,""       })
o:TableData("HELP"   ,{"WI_CON40H","Valor de Container 40' HC" ,""       })
o:TableData("HELP"   ,{"WI_CONOUT","Valor de Container Outros" ,""       })
o:TableData("HELP"   ,{"WF_IDMOEDA","Deseja gerar títulos provisórios em Reais ou na Moeda da Despesa?",""       })
o:TableData("HELP"   ,{"YB_GERPRO" ,"Deseja gerar títulos provisórios para esta despesa?",""       })
o:TableData("HELP"   ,{"EICA11001" ,"Não é possível utilizar a opção para geração de títulos PR pois o parâmetro MV_EASYFPO = N."  ,"Ajustar a opção selecionada ou habilitar o parâmetro MV_EASYFPO."  })
o:TableData("HELP"   ,{"EICA11002" ,"Não é possível utilizar a opção para geração de títulos PRE pois o parâmetro MV_EASYFDI = N." ,"Ajustar a opção selecionada ou habilitar o parâmetro MV_EASYFDI."  })
//LGS-27/07/2016
o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO", "X3_RESERV"},2)
o:TableData(  "SX3",{"SWH"       ,"WH_VALOR", TAM+DEC})

// GFP - 01/09/2016
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_TITULO"  ,"X3_DESCRIC"       ,"X3_WHEN"},2)
o:TableData("SX3"  ,{"WZ_PCREPRE","%Cred.Pres.","% Cred. Presumido",".F."    })
o:TableData("SX3"  ,{"WZ_ICMS_CP","%Cred.Pres.","% Cred. Presumido",         })

o:TableStruct("HELP" ,{"NOME"      ,"PROBLEMA"                                                                                                                          ,"SOLUCAO"})
o:TableData("HELP"   ,{"WZ_ICMS_CP","Percentual de Credito Presumido. O valor de crédito presumido será obtido a partir desta alíquota sobre a base de calculo do ICMS.",""       })

//LRS - 15/09/2016
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI" ,"XB_DESCSPA" ,"XB_DESCENG" ,"XB_CONTEM"                              ,"XB_WCONTEM"})
o:TableData("SXB"  ,{"YR11"    , "6"     ,"01"    ,""         ,""          ,""           ,""           ,'AC100F3VIA(1) .AND. SYR->YR_PAIS_OR <> "105"',            })

//GFP - 26/09/2016
o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                        ,"X6_DSCSPA","X6_DSCENG","X6_DESC1"                                        ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2"                       ,"X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"})
o:TableData("SX6"  ,{"  "       ,"MV_EIC0051" ,"L"      ,"Desconsidera o valor da despesa quando configurado",""         ,""         ,"Base Imposto=SIM e Base ICMS=NÃO da Base de ICMS",""          ,""          ,"ao Gerar a NF, Valores.T. ou.F.",""          ,""          ,".F."       ,".F."       ,".F."       ,".T."      ,".T."    })

//wReliquias 05/12/2016 - Alterado o tamanho do campo descrição do pais da tela de agentes transpo de 15 para 25
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_TAMANHO", "X3_RESERV" },2)
o:TableData  ("SX3",{"Y4_DESCPAI",			  25, TAM+DEC})

//WHRS 13/12/2016 - 499074 / MTRADE-172 - Campos obrigatórios na adição
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_RESERV" },2)
o:TableData  ("SX3",{"EIJ_PO_NUM", ORDEM})
o:TableData  ("SX3",{"EIJ_CALCII", ORDEM})
o:TableData  ("SX3",{"EIJ_ALU_II", ORDEM})
o:TableData  ("SX3",{"EIJ_QTU_II", ORDEM})

//MCF - 19/01/2017
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_FOLDER" },2)
o:TableData  ("SX3",{"WB_VLIQ "  ,"1"         })

//THTS - 31/07/2017
o:TableStruct('SX3',{'X3_CAMPO'   ,'X3_USADO'    },2)
o:TableData("SX3"  ,{"YA_NOIDIOM" ,TODOS_MODULOS + CAMPO_NAO_CHAVE })
o:TableData("SX3"  ,{"YA_PAIS_I"  ,TODOS_MODULOS + CAMPO_NAO_CHAVE })
o:TableData("SX3"  ,{"YA_IDIOMA"  ,TODOS_MODULOS + CAMPO_NAO_CHAVE })

//LRS - 17/01/2017
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_USADO"     ,"X3_RESERV"},2)
o:TableData  ("SX3"  ,{"W2_IMPENC" ,"TODOS_MODULO",USO+ORDEM })

//MFR - 26/01/2017
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_PICTURE", "X3_F3"},2)
o:TableData  ("SX3"  ,{"EJ9_PAISEM"   ,"99",""})

//Tabela de despesas do desembaraço
o:TableStruct("SX3",{"X3_CAMPO"  , "X3_RESERV"              },2)
o:TableData("SX3"  ,{"WD_HAWB"   , ORDEM})
o:TableData("SX3"  ,{"WD_DESPESA", ORDEM+OBRIGAT})
o:TableData("SX3"  ,{"WD_DES_ADI", ORDEM+OBRIGAT})
o:TableData("SX3"  ,{"WD_VALOR_R", ORDEM})
o:TableData("SX3"  ,{"WD_BASEADI", ORDEM+OBRIGAT})
o:TableData("SX3"  ,{"WD_DOCTO"  , ORDEM})
o:TableData("SX3"  ,{"WD_NF_COMP", ORDEM})
o:TableData("SX3"  ,{"WD_SE_NFC" , ORDEM})
o:TableData("SX3"  ,{"WD_VL_NFC" , ORDEM})
o:TableData("SX3"  ,{"WD_DT_NFC" , ORDEM})
o:TableData("SX3"  ,{"WD_INTEGRA", ORDEM})
o:TableData("SX3"  ,{"WD_RECEBE" , ORDEM})
o:TableData("SX3"  ,{"WD_REFREC" , ORDEM})
o:TableData("SX3"  ,{"WD_DA"     , ORDEM})
o:TableData("SX3"  ,{"WD_FORN"   , ORDEM})
o:TableData("SX3"  ,{"WD_LOJA"   , ORDEM})
o:TableData("SX3"  ,{"WD_OCORREN", ORDEM})
o:TableData("SX3"  ,{"WD_DTENVF" , ORDEM})
o:TableData("SX3"  ,{"WD_NUMERA" , ORDEM})
o:TableData("SX3"  ,{"WD_MOEDA"  , ORDEM})
o:TableData("SX3"  ,{"WD_CODACR" , ORDEM})
o:TableData("SX3"  ,{"WD_DESCACR", ORDEM})
o:TableData("SX3"  ,{"WD_B1_COD" , ORDEM})
o:TableData("SX3"  ,{"WD_DOC"    , ORDEM})
o:TableData("SX3"  ,{"WD_SERIE"  , ORDEM})
o:TableData("SX3"  ,{"WD_ESPECIE", ORDEM})
o:TableData("SX3"  ,{"WD_EMISSAO", ORDEM})
o:TableData("SX3"  ,{"WD_B1_QTDE", ORDEM})
o:TableData("SX3"  ,{"WD_TIPONFD", ORDEM})
o:TableData("SX3"  ,{"WD_VL_MOE" , ORDEM})
o:TableData("SX3"  ,{"WD_TX_MOE" , ORDEM})
o:TableData("SX3"  ,{"WD_PRDSIS" , ORDEM})
o:TableData("SX3"  ,{"W3_PART_N" , ORDEM+TAM+DEC})
o:TableData("SX3"  ,{"WO_DESC"   , TAM+DEC})

//THTS - 07/06/2017 - carga do campo WZ_BASENFT
If SWZ->(FieldPos("WZ_BASENFT")) > 0
	AtuTE1101(o)
EndIf

// EJA - 06/07/2017
// Alteração MEMOS do NCM
o:TableStruct("SX3", {"X3_ARQUIVO", "X3_CAMPO", "X3_RELACAO"})
o:TableData("SX3", {"SYD", "YD_MOII_VM", "IF(INCLUI,'',MSMM(SYD->YD_MOT_II))"})
o:TableData("SX3", {"SYD", "YD_MOIPIVM", "IF(INCLUI,'',MSMM(SYD->YD_MOT_IPI))"})

// EJA - 18/07/2017
// Habilitar o campo Contrato no P.O para todos os módulos
/* duplicado
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_BROWSE","X3_VALID","X3_FOLDER","X3_USADO"   ,"X3_WHEN"                },2)
o:TableData  ("SX3"  ,{"W2_CONTR" ,           ,          ,"1"        ,TODOS_MODULOS,                         })*/

o:TableStruct ('SX1',{'X1_GRUPO'  ,'X1_ORDEM','X1_PERGUNT'                   ,' X1_PERSPA'        ,'X1_PERENG'         ,'X1_VARIAVL','X1_TIPO','X1_TAMANHO'                                 ,'X1_DECIMAL','X1_PRESEL','X1_GSC ','X1_VALID'                                                    ,'X1_VAR01','X1_DEF01'           ,'X1_DEFSPA1','X1_DEFENG1','X1_CNT01'  ,'X1_VAR02','X1_DEF02'    ,'X1_DEFSPA2','X1_DEFENG2','X1_CNT02','X1_VAR03','X1_DEF03','X1_DEFSPA3','X1_DEFENG3','X1_CNT03','X1_VAR04','X1_DEF04','X1_DEFSPA4','X1_DEFENG4','X1_CNT04','X1_VAR05','X1_DEF05','X1_DEFSPA5','X1_DEFENG5','X1_CNT05','X1_F3','X1_PYME','X1_GRPSXG','X1_HELP','X1_PICTURE','X1_IDFIL'},1)
//cotação Easy Import
o:TableData   ('SX1',{'EICEAI0001','01'      ,'Cotação de Referência?'       ,                    ,                    ,'mv_ch1'    ,'C'      ,6                                            ,            ,           ,'G'      ,'SI410VALID("COTACAO")'                                       ,'mv_par01',''                   ,            ,            ,            ,          ,''            ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SWT'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','02'      ,'Fornecedor?'                  ,                    ,                    ,'mv_ch2'    ,'C'      ,6                                            ,0           ,           ,'S'      ,'Vazio() .Or. SI410VALID("FORNECEDOR")'                       ,'mv_par02',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SA2A' ,'S'      ,'001'      ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','03'      ,'Loja?'                        ,                    ,                    ,'mv_ch3'    ,'C'      ,2                                            ,            ,           ,'S'      ,'Vazio() .Or. ExistCPO("SA2", mv_par02 + mv_par03)'           ,'mv_par03',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,''     ,'S'      ,'002'      ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','04'      ,'Nome do Fornecedor'           ,                    ,                    ,'mv_ch4'    ,'C'      ,20                                           ,            ,           ,'S'      , ""                                                           ,'mv_par04',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,''     ,'S'      ,''         ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','05'      ,'Moeda?'                       ,                    ,                    ,'mv_ch5'    ,'C'      ,3                                            ,            ,           ,'S'      ,'Vazio() .Or. ExistCPO("SYF",mv_par05)'                       ,'mv_par05',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SYF'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','06'      ,'Importador?'                  ,                    ,                    ,'mv_ch6'    ,'C'      ,2                                            ,            ,           ,'S'      ,'Vazio() .Or. ExistCPO("SYT",mv_par06)'                       ,'mv_par06',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SYT'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','07'      ,'Comprador?'                   ,                    ,                    ,'mv_ch7'    ,'C'      ,3                                            ,            ,           ,'S'      ,'Vazio() .Or. ExistCPO("SY1",mv_par07)'                       ,'mv_par07',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SY1'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','08'      ,'Agente?'                      ,                    ,                    ,'mv_ch8'    ,'C'      ,3                                            ,            ,           ,'G'      ,'Vazio() .Or. ExistCPO("SY4",mv_par08)'                       ,'mv_par08',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SY41' ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','09'      ,'Via de Transporte?'           ,                    ,                    ,'mv_ch9'    ,'C'      ,2                                            ,            ,           ,'S'      ,'Vazio() .Or. ExistCpo("SYQ",mv_par09)'                       ,'mv_par09',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SYQ'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','10'      ,'Origem?'                      ,                    ,                    ,'mv_chA'    ,'C'      ,3                                            ,            ,           ,'S'      ,'Vazio() .Or. ExistCpo("SYR",mv_par09+mv_par10)'              ,'mv_par10',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'EOD'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','11'      ,'Destino?'                     ,                    ,                    ,'mv_chB'    ,'C'      ,3                                            ,            ,           ,'S'      ,'Vazio() .Or. ExistCpo("SYR",mv_par09+mv_par10+mv_par11)'     ,'mv_par11',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'EDE'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','12'      ,'Incoterm?'                    ,                    ,                    ,'mv_chC'    ,'C'      ,3                                            ,            ,           ,'S'      ,'Vazio() .Or. ExistCPO("SYJ",mv_par12)'                       ,'mv_par12',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SYJ'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','13'      ,'Condição de Pagamento?'       ,                    ,                    ,'mv_chD'    ,'C'      ,3                                            ,            ,           ,'S'      ,'Vazio() .Or. ExistCPO("SY6",mv_par13)'                       ,'mv_par13',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SY6'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0001','14'      ,'No. Purchase Order?'          ,                    ,                    ,'mv_chE'    ,'C'      ,15                                           ,            ,           ,'G'      ,'SI410VALID("PO")'                                            ,'mv_par14',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,''     ,'S'      ,           ,         ,            ,          })

//contratos
o:TableData   ('SX1',{'EICEAI0002','01'      ,'Contrato/ Cotação Referência?',                    ,                    ,'mv_ch1'    ,'C'      ,99                                           ,            ,           ,'G'      ,'SI410VALID("CONTRATO")'                                      ,'mv_par01',''                   ,            ,            ,            ,          ,''            ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SW10' ,'S'      , ''        ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0002','02'      ,'Fornecedor?'                  ,                    ,                    ,'mv_ch2'    ,'C'      ,6                                            ,0           ,           ,'S'      ,'Vazio() .Or. SI410VALID("FORNECEDOR")'                       ,'mv_par02',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SA2A' ,'S'      ,'001'      ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0002','03'      ,'Loja?'                        ,                    ,                    ,'mv_ch3'    ,'C'      ,2                                            ,            ,           ,'S'      ,'Vazio() .Or. ExistCPO("SA2", mv_par02 + mv_par03)'           ,'mv_par03',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,''     ,'S'      ,'002'      ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0002','04'      ,'Nome Fornecedor'              ,                    ,                    ,'mv_ch4'    ,'C'      ,20                                           ,            ,           ,'S'      ,""                                                            ,'mv_par04',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,''     ,'S'      ,''         ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0002','05'      ,'Moeda?'                       ,                    ,                    ,'mv_ch5'    ,'C'      ,3                                            ,            ,           ,'G'      ,'Vazio() .Or. ExistCPO("SYF",mv_par05)'                       ,'mv_par05',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SYF'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0002','06'      ,'Importador?'                  ,                    ,                    ,'mv_ch6'    ,'C'      ,2                                            ,            ,           ,'G'      ,'Vazio() .Or. ExistCPO("SYT",mv_par06)'                       ,'mv_par06',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SYT'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0002','07'      ,'Comprador?'                   ,                    ,                    ,'mv_ch7'    ,'C'      ,3                                            ,            ,           ,'G'      ,'Vazio() .Or. ExistCPO("SY1",mv_par07)'                       ,'mv_par07',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SY1'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0002','08'      ,'Agente?'                      ,                    ,                    ,'mv_ch8'    ,'C'      ,3                                            ,            ,           ,'G'      ,'Vazio() .Or. ExistCPO("SY4",mv_par08)'                       ,'mv_par08',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SY41' ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0002','09'      ,'Via de Transporte?'           ,                    ,                    ,'mv_ch9'    ,'C'      ,2                                            ,            ,           ,'G'      ,'Vazio() .Or. ExistCpo("SYQ",mv_par09)'                       ,'mv_par09',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SYQ'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0002','10'      ,'Origem?'                      ,                    ,                    ,'mv_chA'    ,'C'      ,3                                            ,            ,           ,'G'      ,'Vazio() .Or. ExistCpo("SYR",mv_par09+mv_par10)'              ,'mv_par10',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'EOD'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0002','11'      ,'Destino?'                     ,                    ,                    ,'mv_chB'    ,'C'      ,3                                            ,            ,           ,'G'      ,'Vazio() .Or. ExistCpo("SYR",mv_par09+mv_par10+mv_par11)'     ,'mv_par11',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'EDE'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0002','12'      ,'Incoterm?'                    ,                    ,                    ,'mv_chC'    ,'C'      ,3                                            ,            ,           ,'G'      ,'Vazio() .Or. ExistCPO("SYJ",mv_par12)'                       ,'mv_par12',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SYJ'  ,'S'      ,           ,         ,            ,          })
o:TableData   ('SX1',{'EICEAI0002','13'      ,'Condição de Pagamento?'       ,                    ,                    ,'mv_chD'    ,'C'      ,3                                            ,            ,           ,'G'      ,'Vazio() .Or. ExistCPO("SY6",mv_par13)'                       ,'mv_par13',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SY6'  ,'S'      ,           ,         ,            ,          })

//THTS - 27/07/2017
o:TableStruct("SX3",{"X3_CAMPO","X3_VALID"                           },2)
o:TableData("SX3"  ,{"Y5_COD"  ,"VALIDAC175() .and. EXISTCHAV('SY5')"})

o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"          ,"XB_DESCSPA" ,"XB_DESCENG" ,"XB_CONTEM"            })
o:TableData('SXB',  {'FFC'     ,'6'      ,'01'    ,""         ,""                   ,""           ,""           ,"Left(SWB->WB_TIPOREG,1)<>'P'" })
o:TableData('SXB',  {'SJL'     ,'6'      ,'01'    ,""         ,""                   ,""           ,""           ,"EasyNVESXB('SJL')"    })
o:TableData('SXB',  {'BRWFIL'  ,'1'      ,'01'    ,"RE"       ,"Processo p/ Filial" ,""           ,""           ,"SX5"                  })
o:TableData('SXB',  {'BRWFIL'  ,'2'      ,'01'    ,"01"       ,""                   ,""           ,""           ,"EICTR350FIL()"        })
o:TableData('SXB',  {'BRWFIL'  ,'5'      ,'01'    ,""         ,""                   ,""           ,""           ,".T."                  })
o:TableData("SXB",  {"E6_"     ,'3'      ,'01'    ,'01'       ,                     ,             ,             ,"01#EECAC170A(.T.,0,3)"})

o:TableStruct('SX1',{'X1_GRUPO','X1_ORDEM','X1_VAR01','X1_F3'   })
o:TableData('SX1'  ,{'EIC350'  ,"01"      ,"MV_PAR01", "BRWFIL" })
o:TableData('SX1'  ,{'EIC350'  ,"02"      ,"MV_PAR02", "BRWFIL" })
o:TableData('SX1'  ,{'EIC350'  ,"03"      ,"MV_PAR03", "BRWFIL" })
o:TableData('SX1'  ,{'EIC350'  ,"04"      ,"MV_PAR04", ""       })
o:TableData('SX1'  ,{'EIC350'  ,"05"      ,"MV_PAR05", "Y7"     })
o:TableData('SX1'  ,{'EIC350'  ,"06"      ,"MV_PAR06", ""       })
o:TableData('SX1'  ,{'EIC350'  ,"07"      ,"MV_PAR07", ""       })
o:TableData('SX1'  ,{'EIC350'  ,"08"      ,"MV_PAR08", "Y6"     })
o:TableData('SX1'  ,{'EIC350'  ,"09"      ,"MV_PAR09", ""       })
o:TableData('SX1'  ,{'EIC350'  ,"10"      ,"MV_PAR10", ""       })
o:TableData('SX1'  ,{'EIC350'  ,"11"      ,"MV_PAR11", "BRWFIL" })
o:TableData('SX1'  ,{'EIC350'  ,"12"      ,"MV_PAR12", ""       })
o:TableData('SX1'  ,{'EIC350'  ,"13"      ,"MV_PAR13", ""       })

o:TableStruct('SX1' ,{'X1_GRUPO','X1_ORDEM','X1_PERGUNT'              ,' X1_PERSPA'        ,'X1_PERENG'         ,'X1_VARIAVL','X1_TIPO','X1_TAMANHO' ,'X1_DECIMAL','X1_PRESEL','X1_GSC ','X1_VALID'       ,'X1_VAR01','X1_DEF01'           ,'X1_DEFSPA1','X1_DEFENG1','X1_CNT01'  ,'X1_VAR02','X1_DEF02'    ,'X1_DEFSPA2','X1_DEFENG2','X1_CNT02','X1_VAR03','X1_DEF03','X1_DEFSPA3','X1_DEFENG3','X1_CNT03','X1_VAR04','X1_DEF04','X1_DEFSPA4','X1_DEFENG4','X1_CNT04','X1_VAR05','X1_DEF05','X1_DEFSPA5','X1_DEFENG5','X1_CNT05','X1_F3'  ,'X1_PYME','X1_GRPSXG','X1_HELP','X1_PICTURE','X1_IDFIL'},1)
o:TableData('SX1'   ,{'EIC285'  ,'01'      ,'Código do Fornecedor'    ,                    ,                    ,'mv_ch1'    ,'C'      ,6            ,            ,           ,'G'      ,'TR285ValForn()' ,'mv_par01',''                   ,            ,            ,            ,          ,''            ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,'SA2A'   ,'N'      ,           ,         ,            ,          })
o:TableData('SX1'   ,{'EIC285'  ,'02'      ,'Loja ?'                  ,                    ,                    ,'mv_ch2'    ,'C'      ,2            ,            ,           ,'G'      ,' '              ,'mv_par01',''                   ,            ,            ,            ,          ,''            ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,''       ,'N'      ,           ,         ,            ,          })
o:TableData('SX1'   ,{'EIC285'  ,'03'      ,'Data Inicial'            ,                    ,                    ,'mv_ch3'    ,'D'      ,8            ,            ,           ,'G'      ,' '              ,'mv_par01',''                   ,            ,            ,            ,          ,''            ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,''       ,'N'      ,           ,         ,            ,          })
o:TableData('SX1'   ,{'EIC285'  ,'04'      ,'Data Final'              ,                    ,                    ,'mv_ch4'    ,'D'      ,8            ,            ,           ,'G'      ,' '              ,'mv_par01',''                   ,            ,            ,            ,          ,''            ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,''       ,'N'      ,           ,         ,            ,          })
o:TableData('SX1'   ,{'EIC285'  ,'05'      ,'Considerar dias úteis ?' ,                    ,                    ,'mv_ch5'    ,'C'      ,1            ,            ,'1'        ,'C'      ,' '              ,'mv_par01','Sim'                ,            ,            ,            ,          ,'Não'         ,            ,            ,          ,          ,''        ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,''       ,'N'      ,           ,         ,            ,          })

o:TableStruct('SX1',{'X1_GRUPO','X1_ORDEM','X1_F3'  })
o:TableData('SX1'  ,{'EIC154'  ,"02"      ,"FABLOJ" })

//pergunta do item no P.O.
o:TableStruct('SX1' ,{'X1_GRUPO'  ,'X1_ORDEM','X1_PERGUNT'                   ,' X1_PERSPA'        ,'X1_PERENG'         ,'X1_VARIAVL','X1_TIPO','X1_TAMANHO'                                 ,'X1_DECIMAL','X1_PRESEL','X1_GSC ','X1_VALID'                                                  ,'X1_VAR01','X1_DEF01'           ,'X1_DEFSPA1','X1_DEFENG1','X1_CNT01'  ,'X1_VAR02','X1_DEF02'    ,'X1_DEFSPA2','X1_DEFENG2','X1_CNT02','X1_VAR03','X1_DEF03','X1_DEFSPA3','X1_DEFENG3','X1_CNT03','X1_VAR04','X1_DEF04','X1_DEFSPA4','X1_DEFENG4','X1_CNT04','X1_VAR05','X1_DEF05','X1_DEFSPA5','X1_DEFENG5','X1_CNT05','X1_F3'  ,'X1_PYME','X1_GRPSXG','X1_HELP','X1_PICTURE','X1_IDFIL'},1)
o:TableData   ('SX1',{'PO400FIL'  ,'03'      ,                               ,                    ,                    ,            ,         ,                                             ,            ,           ,         ,'Vazio() .Or. SI410VALID("PO400FILSIAGRP")'                 ,          ,                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,          })
o:TableData   ('SX1',{'PO400FIL'  ,'10'      ,'Agrupador?'                   ,                    ,                    ,'mv_chA'    ,'C'      ,99                                           ,            ,           ,'G'      ,""                                                          ,'mv_par10',                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,          })

//Cadastro errado no AtuSX
o:DelTableData   ('SX1',{'PO400FIL','1'      ,                               ,                    ,                    ,            ,         ,                                             ,            ,           ,         ,                                                             ,          ,                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,          })
o:DelTableData   ('SX1',{'PO400FIL','2'      ,                               ,                    ,                    ,            ,         ,                                             ,            ,           ,         ,                                                             ,          ,                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,          })
o:DelTableData   ('SX1',{'PO400FIL','3'      ,                               ,                    ,                    ,            ,         ,                                             ,            ,           ,         ,                                                             ,          ,                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,          })
o:DelTableData   ('SX1',{'PO400FIL','4'      ,                               ,                    ,                    ,            ,         ,                                             ,            ,           ,         ,                                                             ,          ,                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,          })
o:DelTableData   ('SX1',{'PO400FIL','5'      ,                               ,                    ,                    ,            ,         ,                                             ,            ,           ,         ,                                                             ,          ,                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,          })
o:DelTableData   ('SX1',{'PO400FIL','6'      ,                               ,                    ,                    ,            ,         ,                                             ,            ,           ,         ,                                                             ,          ,                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,          })
o:DelTableData   ('SX1',{'PO400FIL','7'      ,                               ,                    ,                    ,            ,         ,                                             ,            ,           ,         ,                                                             ,          ,                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,          })
o:DelTableData   ('SX1',{'PO400FIL','8'      ,                               ,                    ,                    ,            ,         ,                                             ,            ,           ,         ,                                                             ,          ,                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,          })
o:DelTableData   ('SX1',{'PO400FIL','9'      ,                               ,                    ,                    ,            ,         ,                                             ,            ,           ,         ,                                                             ,          ,                     ,            ,            ,            ,          ,              ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,          ,          ,            ,            ,          ,       ,         ,           ,         ,            ,          })

//**Em caso de Help de campo (F1) somente usar o aHelpProb com o Nome do campo**
Aadd(o:aHelpProb,{"W1_PEDERP",{"W1_PEDERP","Número do P.O. e número do pedido do ERP. Quando não houver P.O. gerada e a S.I. for originada por contrato, será sugerido o número do pedido do ERP existente para o mesmo agrupador."}})

//wfs - 02/08/2017 - movidos do avupdate02, retirada da função específica para integração EAI.
//****
   o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_BROWSE","X3_VALID","X3_FOLDER","X3_USADO"   ,"X3_WHEN"                },2)
   o:TableData  ("SX3"  ,{"W1_CC"    ,"S"        ,          ,           ,             ,                         })
   o:TableData  ("SX3"  ,{"W1_SI_NUM","S"        ,          ,           ,             ,                         })
   o:TableData  ("SX3"  ,{"Y6_CODERP","S"        ,""        ,           ,             ,                         })
   o:TableData  ("SX3"  ,{"W2_CONTR" ,           ,          ,"1"        ,TODOS_MODULOS,                         })
   o:TableData  ("SX3"  ,{"W2_MOEDA" ,           ,          ,           ,             ,"PO400WHEN('W2_MOEDA')"  })
   o:TableData  ("SX3"  ,{"W2_COND_PA",          ,          ,           ,             ,"PO400WHEN('W2_COND_PA')"})
   o:TableData  ("SX3"  ,{"W2_DIAS_PA",          ,          ,           ,             ,"PO400WHEN('W2_DIAS_PA')"})
   o:TableData  ("SX3"  ,{"WB_SEQBX"  ,          ,          ,           ,TODOS_MODULOS,                         })

   o:TableStruct("SX3"  ,{"X3_CAMPO"     ,"X3_TITULO" ,"X3_TAMANHO","X3_BROWSE","X3_RESERV"},2)
   o:TableData  ("SX3"  ,{"W1_C3_NUM"    ,            ,6           ,"S"        ,           })
   o:TableData  ("SX3"  ,{"W0_REFER1"    ,"Agrupador" ,            ,           ,TAM        })
   o:TableData  ("SX3"  ,{"W1_REFER1"    ,"Agrupador" ,            ,           ,TAM        })
   o:TableData  ("SX3"  ,{"W1_PEDERP"    ,"PO/Ped.ERP",20          ,"N"        ,           })
   o:TableData  ("SX3"  ,{"W1_DT_SI"     ,            ,            ,"N"        ,           })

   o:TableStruct("SX3"  ,{"X3_CAMPO"     ,"X3_VISUAL"},2)
   o:TableData  ("SX3"  ,{"WD_VL_COMP"   ,"A"        })

   /* confirmar se consta na carga padrão; se não constar, solicitar a inclusão */
   o:TableStruct("EC6",{"EC6_FILIAL"   ,"EC6_TPMODU" ,"EC6_ID_CAM" ,"EC6_IDENTC"          })
   o:TableData('EC6'  ,{xFilial('EC6') ,"IMPORT"     ,"150"        ,"DESPESAS PROVISORIAS"})
   o:TableData('EC6'  ,{xFilial('EC6') ,"IMPORT"     ,"151"        ,"ADIANTAMENTO DE DESPESAS"})

   o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"           ,"XB_DESCSPA"          ,"XB_DESCENG"          ,"XB_CONTEM"       ,"XB_WCONTEM"})
   o:TableData("SXB"  ,{"SY41"    , "1"     ,"01"    ,"DB"       ,"Agentes"             ,"Agentes"             ,"Agentes"             ,"SY4"             ,            })
   o:TableData("SXB"  ,{"SY41"    , "2"     ,"01"    ,"01"       ,"Codigo"              ,"Codigo"              ,"Codigo"              ,""                ,            })
   o:TableData("SXB"  ,{"SY41"    , "2"     ,"02"    ,"01"       ,"Nome"                ,"Nome"                ,"Nome"                ,""                ,            })
   o:TableData("SXB"  ,{"SY41"    , "3"     ,"01"    ,"01"       ,"Cadastra Novo"       ,"Cadastra Novo"       ,"Cadastra Novo"       ,"01"              ,            })
   o:TableData("SXB"  ,{"SY41"    , "4"     ,"01"    ,"01"       ,"Codigo"              ,"Codigo"              ,"Codigo"              ,"Y4_COD"          ,            })
   o:TableData("SXB"  ,{"SY41"    , "4"     ,"01"    ,"02"       ,"Nome"                ,"Nome"                ,"Nome"                ,"Y4_NOME"         ,            })
   o:TableData("SXB"  ,{"SY41"    , "5"     ,"01"    ,""         ,""                    ,""                    ,""                    ,"SY4->Y4_COD"     ,            })

   o:TableData("SXB"   ,{"SW10"    , "1"     ,"01"    ,"RE"       ,"Itens SI"            ,"Itens SI"            ,"Itens SI"            ,"SW1"             ,            })
   o:TableData("SXB"   ,{"SW10"    , "2"     ,"01"    ,"01"       ,"No. Contrato"        ,"No. Contrato"        ,"No. Contrato"        ,"SI410F3()"       ,            })
   o:DelTableData("SXB",{"SW10"    , "2"     ,"01"    ,"02"       ,"Fornecedor"          ,"Fornecedor"          ,"Fornecedor"          ,""                ,            })
   o:DelTableData("SXB",{"SW10"    , "4"     ,"01"    ,"01"       ,"No. Contrato"        ,"No. Contrato"        ,"No. Contrato"        ,"W1_C3_NUM"       ,            })
   o:DelTableData("SXB",{"SW10"    , "4"     ,"01"    ,"02"       ,"Fornecedor"          ,"Fornecedor"          ,"Fornecedor"          ,"W1_FORN"         ,            })
   o:TableData("SXB"   ,{"SW10"    , "5"     ,"01"    ,""         ,""                    ,""                    ,""                    ,"SW1->W1_C3_NUM"  ,            })
   o:DelTableData("SXB",{"SW10"    , "6"     ,"01"    ,""         ,""                    ,""                    ,""                    ,"SW1->W1_STATUS == 'G' .AND. SW1->W1_C3_NUM <> ''",        })

   o:TableData("SXB"  ,{"SWT"    , "1"     ,"01"    ,"DB"       ,"Cotações"            ,"Cotações"            ,"Cotações"            ,"SWT"             ,            })
   o:TableData("SXB"  ,{"SWT"    , "2"     ,"01"    ,"01"       ,"No. Cotação"         ,"No. Cotação"         ,"No. Cotação"         ,""                ,            })
   o:TableData("SXB"  ,{"SWT"    , "2"     ,"02"    ,"01"       ,"Item"                ,"Item"                ,"Item"                ,""                ,            })
   o:TableData("SXB"  ,{"SWT"    , "2"     ,"03"    ,"01"       ,"Fornecedor"          ,"Fornecedor"          ,"Fornecedor"          ,""                ,            })
   o:TableData("SXB"  ,{"SWT"    , "2"     ,"04"    ,"01"       ,"Loja"                ,"Loja"                ,"Loja"                ,""                ,            })
   o:TableData("SXB"  ,{"SWT"    , "2"     ,"05"    ,"01"       ,"Moeda"               ,"Moeda"               ,"Moeda"               ,""                ,            })
   o:TableData("SXB"  ,{"SWT"    , "2"     ,"06"    ,"01"       ,"Valor Total"         ,"Valor Total"         ,"Valor Total"         ,""                ,            })

   o:TableData("SXB"  ,{"SWT"    , "4"     ,"01"    ,"01"       ,"No. Cotação"         ,"No. Cotação"         ,"No. Cotação"         ,"WT_NUMERP"       ,            })
   o:TableData("SXB"  ,{"SWT"    , "4"     ,"01"    ,"02"       ,"Item"                ,"Item"                ,"Item"                ,"WT_COD_I"        ,            })
   o:TableData("SXB"  ,{"SWT"    , "4"     ,"01"    ,"03"       ,"Fornecedor"          ,"Fornecedor"          ,"Fornecedor"          ,"WT_FORN"         ,            })
   o:TableData("SXB"  ,{"SWT"    , "4"     ,"01"    ,"04"       ,"Loja"                ,"Loja"                ,"Loja"                ,"WT_FORLOJ"       ,            })
   o:TableData("SXB"  ,{"SWT"    , "4"     ,"01"    ,"05"       ,"Moeda"               ,"Moeda"               ,"Moeda"               ,"WT_MOEDA"        ,            })
   o:TableData("SXB"  ,{"SWT"    , "4"     ,"01"    ,"06"       ,"Valor Total"         ,"Valor Total"         ,"Valor Total"         ,"WT_TOTRS"        ,            })
   o:TableData("SXB"  ,{"SWT"    , "5"     ,"01"    ,""         ,""                    ,""                    ,""                    ,"SWT->WT_NUMERP"  ,            })
   o:TableData("SXB"  ,{"SWT"    , "6"     ,"01"    ,""         ,""                    ,""                    ,""                    ,"SWT->WT_NUMERP <> '' .AND. SWT->WT_STATUS == '3'",})

   o:TableStruct('SX1',{'X1_GRUPO','X1_ORDEM','X1_CNT01','X1_VAR02'    },1) //NCF - 13/09/2016 - Reajuste
   o:TableData(  'SX1',{'PO400FIL','04'       ,''        ,'W2_INCOTER'  })
   o:TableData(  'SX1',{'PO400FIL','05'       ,''        ,'W2_FORN'     })
   o:TableData(  'SX1',{'PO400FIL','06'       ,''        ,'W2_FORLOJ'   })
   o:TableData(  'SX1',{'PO400FIL','07'       ,''        ,'W2_COND_PA'  })
   o:TableData(  'SX1',{'PO400FIL','08'       ,''        ,'W2_DIAS_PA'  })
   o:TableData(  'SX1',{'PO400FIL','09'       ,''        ,'W2_MOEDA'    })
   //NCF - 08/11/2017 - Atusx gera dicionario como X1_ORDEM = '7'
   o:TableStruct("SX1",{"X1_GRUPO" ,"X1_ORDEM"  ,"X1_PERGUNT"                     ,"X1_VARIAVL","X1_TIPO"  ,"X1_TAMANHO" ,"X1_DECIMAL" ,"X1_PRESEL" ,"X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_VAR02"  ,"X1_DEF02","X1_F3","X3_HELP"     ,"X1_PICTURE" })
   o:TableData("SX1"  ,{"EICLC500" ,/*"07"*/"7" ,'Utilizar Dt.Cont. p/ Eventos ?' ,"MV_CH0"    ,"C"        ,1            ,0            ,2           ,"C"     ,""        ,"MV_PAR07","Sim"     ,""          ,"Nao"     ,""     ,".EICLC50007.",             })
   AaDD(aHelp,"Informe se a data utilizada na contabilizaçao dos eventos marcados será a data base da contabilização (SIM) ou a data de efetiva ocorrência do evento (NÃO-Default) ") //Adicionar Help no SX1
   PutHelp("P."+"EICLC500"+"7"/*"07"*/+".",aHelp,aHelp,aHelp,.T.)

   o:TableStruct("SIX",{"INDICE","ORDEM" ,"CHAVE"                                         ,"DESCRICAO"                                   })
   o:TableData("SIX"  ,{"SWT"   ,"6"     ,"WT_FILIAL+WT_NUMERP+WT_FORN+WT_FORLOJ+WT_COD_I","Numero ERP + Fornecedor + Loja + Cod. Item " })

//****
Return Nil

/*
Funcao                     : UPDEIC014
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			   : Guilherme Fernandes Pilan - GFP
Data/Hora   			   : 21/11/2016
*/
Function UPDEIC014(o)
Local cUsado := ""
Local aUF := {"AC","AL","AM","AP","BA","CE","DF","ES","GO","MA","MG","MS","MT","PA","PB","PE","PI",;
	          "PR","RJ","RN","RO","RR","RS","SC","SE","SP","TO"}
Local i,cUF := ""

o:TableStruct('SX3',{'X3_CAMPO'   ,'X3_USADO'    },2)
o:TableData("SX3"  ,{"B1_MONO"    ,TODOS_MODULOS })

o:TableStruct("SX2",{"X2_CHAVE","X2_NOME"               },1)
o:TableData("SX2"  ,{"SJK"     ,"Atributo para NVE"     })
o:TableData("SX2"  ,{"SJL"     ,"Especificação para NVE"})

//wReliquias 05/12/2016 - Alterado o tamanho do campo descrição do pais da tela de agentes transpo de 15 para 25
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_TAMANHO", "X3_RESERV" },2)
o:TableData  ("SX3",{"Y4_DESCPAI",			  25, TAM+DEC})

//wReliquias 13/12/2016 - 499074 / MTRADE-172 - Campos obrigatórios na adição
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_RESERV" },2)
o:TableData  ("SX3",{"EIJ_PO_NUM", ORDEM})
o:TableData  ("SX3",{"EIJ_CALCII", ORDEM})
o:TableData  ("SX3",{"EIJ_ALU_II", ORDEM})
o:TableData  ("SX3",{"EIJ_QTU_II", ORDEM})

o:TableStruct("SX7",{'X7_CAMPO' ,'X7_SEQUENC','X7_CDOMIN'  ,'X7_CONDIC'            })
o:TableData  ('SX7',{'W2_FORN'  ,'001'       ,"W2_FORLOJ " ,"SA2->A2_MSBLQL <> '1'"})

o:TableStruct("SX7",{'X7_CAMPO' ,'X7_SEQUENC','X7_CDOMIN'  ,'X7_CONDIC'            })
o:TableData  ('SX7',{'W3_FABR'  ,'001'       ,"W3_FABLOJ " ,"SA2->A2_MSBLQL <> '1'"})

o:TableStruct("SX3",{"X3_CAMPO" ,"X3_VALID"             },2)
o:TableData("SX3"  ,{"W2_FORN"  ,"PO420VAL('W2_FORN')" })

//LRS - 03/01/2017 - Ajuste no gatilho B1_POSIPI
o:TableStruct("SX7",{"X7_CAMPO"  ,"X7_SEQUENC","X7_REGRA"                                                                                 ,"X7_CDOMIN" ,"X7_TIPO","X7_SEEK","X7_ALIAS","X7_ORDEM","X7_CHAVE"                   ,"X7_CONDIC"   ,"X7_PROPRI"})
o:TableData("SX7"  ,{"B1_POSIPI" ,"002"       ,"IF (!Empty(SYD->YD_ANUENTE) .OR. SYD->YD_ANUENTE == '2',SYD->YD_ANUENTE, M->B1_ANUENTE)"  ,"B1_ANUENTE","P"      ,"S"      ,"SYD"     ,"1"       ,'xFilial("SYD")+M->B1_POSIPI',""            ,"S"        })

//LRS - 17/01/2017
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_USADO"     ,"X3_RESERV"},2)
o:TableData  ("SX3"  ,{"W2_IMPENC",TODOS_MODULOS  ,USO+ORDEM })    //NCF - 23/02/2016

//MCF - 19/01/2017
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_FOLDER" },2)
o:TableData  ("SX3",{"WB_VLIQ "  ,"1"         })

//MFR - 26/01/2017
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_PICTURE", "X3_F3"},2)
o:TableData  ("SX3"  ,{"EJ9_PAISEM"   ,"99",""})

//LRS - 31/01/2017
o:TableStruct("SX3"  ,{"X3_CAMPO"     ,"X3_GRPSXG","X3_RESERV", "X3_VALID"                                          ,"X3_CBOX"                                       },2)
o:TableData  ("SX3"  ,{"Y5_COD"       ,"001"      ,           ,                                                     ,                                                })
o:TableData  ("SX3"  ,{"YU_DESP"      ,"001"      ,           ,                                                     ,                                                })
o:TableData  ("SX3"  ,{"W2_DESP"      ,"001"      ,           ,                                                     ,                                                })
o:TableData  ("SX3"  ,{"W6_DESP"      ,"001"      ,           ,                                                     ,                                                })
o:TableData  ("SX3"  ,{"YU_EASY"      ,"001"      ,TAM+DEC    ,                                                     ,                                                })
o:TableData  ("SX3"  ,{"YU_GIP_1"     ,           ,TAM+DEC    ,                                                     ,                                                })
o:TableData  ("SX3"  ,{"YU_TIP_CAD"   ,           ,           , 'Pertence("1235") .AND. EICTE110Tipo(M->YU_TIP_CAD)','1=Importador;2=Fab/For;3=Agentes;5=Despachante'})
o:TableData  ("SX3"  ,{"EWZ_CODDES"   ,           ,TAM+DEC    ,                                                     ,                                                })
o:TableData  ("SX3"  ,{"WW_FORNECE"   ,"001"      ,           ,                                                     ,                                                })

//LRS - 08/02/2017
o:TableStruct ('SX1',{'X1_GRUPO','X1_ORDEM','X1_PERGUNT'              ,' X1_PERSPA','X1_PERENG','X1_VARIAVL','X1_TIPO','X1_TAMANHO','X1_DECIMAL','X1_PRESEL','X1_GSC ','X1_VALID'                             ,'X1_VAR01'   ,'X1_DEF01' ,'X1_DEFSPA1' ,'X1_DEFENG1','X1_CNT01' ,'X1_VAR02','X1_DEF02'          ,'X1_DEFSPA2','X1_DEFENG2','X1_CNT02','X1_VAR03'  ,'X1_DEF03'      ,'X1_DEFSPA3'  ,'X1_DEFENG3','X1_CNT03','X1_VAR04' ,'X1_DEF04'     ,'X1_DEFSPA4','X1_DEFENG4','X1_CNT04','X1_VAR05','X1_DEF05','X1_DEFSPA5','X1_DEFENG5','X1_CNT05','X1_F3','X1_PYME','X1_GRPSXG','X1_HELP','X1_PICTURE','X1_IDFIL'})
o:TableData   ('SX1',{'KZR014'  ,"01"      ,"Tipo de Relatório"       ,""          ,""         ,"mv_ch1"    ,"N"      ,1           ,0           ,0          ,"C"      ,""                                     ,"MV_PAR01"   ,"Analítico",""           ,""          ,""         ,""        ,"Sintético"         ,""          ,""          ,""        ,""          ,""              ,""            ,""          ,""        ,""          ,""            ,""          ,            ,          ,          ,          ,            ,            ,          ,''     ,''       ,           ,         ,            ,          })
o:TableData   ('SX1',{'KZR014'  ,"02"      ,"Processo de Importação"  ,""          ,""         ,"mv_ch2"    ,"C"      ,17          ,0           ,0          ,"G"      ,"ExistCpo('EWG')"                      ,"MV_PAR02"   ,""         ,""           ,""          ,""         ,""        ,""                  ,""          ,""          ,""        ,""          ,""              ,""            ,""          ,""        ,""          ,""            ,""          ,            ,          ,          ,          ,            ,            ,          ,"EWG"  ,''       ,           ,         ,            ,          })
o:TableData   ('SX1',{'KZR014'  ,"03"      ,"Código do Armazem"       ,""          ,""         ,"mv_ch3"    ,"C"      ,6           ,0           ,0          ,"G"      ,"ExistCpo('SA2')"                      ,"MV_PAR03"   ,""         ,""           ,""          ,""         ,""        ,""                  ,""          ,""          ,""        ,""          ,""              ,""            ,""          ,""        ,""          ,""            ,""          ,            ,          ,          ,          ,            ,            ,          ,"SA2"  ,''       ,           ,         ,            ,          })
o:TableData   ('SX1',{'KZR014'  ,"04"      ,"Loja do Armazem"         ,""          ,""         ,"mv_ch4"    ,"C"      ,2           ,0           ,0          ,"G"      ,"ExistCpo('SA2', mv_par03 + mv_par04)" ,"MV_PAR04"   ,""         ,""           ,""          ,""         ,""        ,""                  ,""          ,""          ,""        ,""          ,""              ,""            ,""          ,""        ,""          ,""            ,""          ,            ,          ,          ,          ,            ,            ,          ,"SA22" ,''       ,           ,         ,            ,          })
o:TableData   ('SX1',{'KZR014'  ,"05"      ,"Filtro por Situação"     ,""          ,""         ,"mv_ch5"    ,"N"      ,1           ,0           ,0          ,"C"      ,""                                     ,"MV_PAR05"   ,"Previsto" ,""           ,""          ,""         ,""        ,"Realizado"         ,""          ,""          ,          ,""          ,"Ambos"         ,""            ,""          ,""        ,""          ,""            ,""          ,            ,          ,          ,          ,            ,            ,          ,''     ,''       ,           ,         ,            ,          })
o:TableData   ('SX1',{'KZR014'  ,"06"      ,"Ordenar por"             ,""          ,""         ,"mv_ch6"    ,"N"      ,1           ,0           ,0          ,"C"      ,""                                     ,"MV_PAR06"   ,"Armazém"  ,""           ,""          ,""         ,""        ,"Data inicio Armaz.",""          ,""          ,          ,""          ,"Vlr. Realizado",""            ,""          ,""        ,""          ,"Vlr Previsto",""          ,            ,          ,          ,          ,            ,            ,          ,''     ,''       ,           ,         ,            ,          })

//LRS - 16/02/2017 *** THTS - 03/08/2017
SX3->(DbSetOrder(2))
o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_WHEN"                                    },2)
FOR I:=1 TO LEN(aUF)
    cUf := "YB_ICMS_" + aUF[i]
    o:TableData('SX3',{cUf        ,'M->YB_BASEICM=="1" .OR. M->YB_ICMSNFC=="1"' })
Next i

//MFR 07/03/2017 TE-4890 MTRADE-698 WCC-506595
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_TITULO"  ,"X3_DESCRIC"       ,"X3_WHEN", "X3_USADO"},2)
o:TableData("SX3"  ,{"WZ_PCREPRE","%Cred.Pres.","% Cred. Presumido",".F.", "NAO_USADO"    })

//LRS - 06/03/2017
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"    ,"XB_DESCSPA" ,"XB_DESCENG" ,"XB_CONTEM"      })
o:TableData('SXB',  {'BCOEIC'  ,'1'      ,'01'    ,'DB'       ,'Banco'        ,""           ,""           ,'SA6'            })
o:TableData('SXB',  {'BCOEIC'  ,'2'      ,'01'    ,'01'       ,'Código'       ,""           ,""           ,""               })
o:TableData('SXB',  {'BCOEIC'  ,'2'      ,'02'    ,'02'       ,'Nome'         ,""           ,""           ,""               })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'01'    ,'01'       ,'Código'       ,""           ,""           ,"A6_COD"         })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'01'    ,'02'       ,'Agência'      ,""           ,""           ,"A6_AGENCIA"     })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'01'    ,'03'       ,'Conta'        ,""           ,""           ,"A6_NUMCON"      })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'01'    ,'04'       ,'Nome'         ,""           ,""           ,"A6_NREDUZ"      })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'02'    ,'01'       ,'Código'       ,""           ,""           ,"A6_COD"         })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'02'    ,'02'       ,'Agência'      ,""           ,""           ,"A6_AGENCIA"     })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'02'    ,'03'       ,'Conta'        ,""           ,""           ,"A6_NUMCON"      })
o:TableData('SXB',  {'BCOEIC'  ,'4'      ,'02'    ,'04'       ,'Nome'         ,""           ,""           ,"A6_NREDUZ"      })
o:TableData('SXB',  {'BCOEIC'  ,'5'      ,'01'    ,""         ,""             ,""           ,""           ,"SA6->A6_COD"    })
o:TableData('SXB',  {'BCOEIC'  ,'5'      ,'02'    ,""         ,""             ,""           ,""           ,"SA6->A6_AGENCIA"})
o:TableData('SXB',  {'BCOEIC'  ,'5'      ,'03'    ,""         ,""             ,""           ,""           ,"SA6->A6_NUMCON" })
o:TableData('SXB',  {'BCOEIC'  ,'5'      ,'04'    ,""         ,""             ,""           ,""           ,"SA6->A6_NREDUZ" })

o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_F3"     },2)
o:TableData("SX3"  ,{"WB_BANCO"    ,"BCOEIC"    })

//LRS - 16/03/2017
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_CBOX"    ,"X3_RELACAO","X3_USADO"    ,"X3_RESERV" },2)
o:TableData("SX3"  ,{'W3_SOFTWAR' , '1=Sim;2=Não','"2"'       ,TODOS_MODULOS ,USO           })

//LRS - 23/03/2017
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_USADO"   },2)
o:TableData("SX3"  ,{"W3_FLUXO"   ,TODOS_MODULOS})

//LRS - 28/03/2017
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_RELACAO"   },2)
o:TableData("SX3"  ,{"EXJ_MOTNIF" ,""})

//WHRS - 31/03/2017 TE-4966 507485 / 506246 / MTRADE-607 - Cotação de moedas
o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                      ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                       ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"},1)
o:TableData("SX6"  ,{"  "       ,"MV_EIC0067" ,"C"      ,"Sincronizar a cotação de moedas entre os módulos",""          ,""          ,"SIGAEIC e SIGAFIN. S=Sim N=Não" ,            ,            ,""        ,""          ,""          ,""          ,            ,            ,"S"        ,"N"      ,""        , ""       , ""         , ""         , ""         })

//LRS - 25/04/2017
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_VISUAL"   },2)
o:TableData("SX3"  ,{"WT_FORN"   ,"A"})
o:TableData("SX3"  ,{"WT_FORLOJ" ,"A"})


//Alterado para .T. MFR MTRADE-1011 TE-5740 20/06/2017
o:TableStruct("SX3",{"X3_CAMPO"    ,"X3_WHEN" },2)
o:TableData("SX3"  ,{"EW4_FRETEI"  ,".T."     })
o:TableData("SX3"  ,{"EW4_SEGURO"  ,".T."     })
o:TableData("SX3"  ,{"EW4_INLAND"  ,".T."     })
o:TableData("SX3"  ,{"EW4_PACKIN"  ,".T."     })
o:TableData("SX3"  ,{"EW4_DESCON"  ,".T."     })

o:TableStruct("SIX",{"INDICE","ORDEM" ,"SHOWPESQ"})
o:TableData("SIX"  ,{"EW4"   ,"1"     ,"S" })
o:TableData("SIX"  ,{"EW4"   ,"2"     ,"S" })

//NCF - 22/06/2017
o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_FOLDER"   },2)
o:TableData("SX3"  ,{"EIJ_ALPISM","7"})


// EJA - 06/09/2017
o:TableStruct("SX3" ,{"X3_CAMPO"    ,"X3_GRPSXG"},2)
o:TableData  ("SX3" ,{"EIJ_FORN"    ,"001"      })
o:TableData  ("SX3" ,{"EIJ_FABR"    ,"001"      })
o:TableData  ("SX3" ,{"EIJ_FORLOJ"  ,"002"      })
o:TableData  ("SX3" ,{"EIJ_FABLOJ"  ,"002"      })

Return nil


/*
Funcao                     : UPDEIC016
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      :
Data/Hora   			      :
*/
Function UPDEIC016(o)

   //Dicionário de Campos
   o:TableStruct("SX3", {"X3_ARQUIVO", "X3_CAMPO"  , "X3_VALID"                                  , "X3_F3"}, 2)
   o:TableData("SX3"  , {"SW4"       , "W4_INCOTER", 'Vazio() .Or. ExistCpo("SYJ",M->W4_INCOTER)', "SYJ"  }) //wfs - digitado na 12.1.18

   //Dicionário de Consultas
   o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"    ,"XB_DESCSPA" ,"XB_DESCENG" ,"XB_CONTEM"      })
   //Vias de transporte
   o:TableData('SXB',  {'EOD'     ,'6'      ,'01'    ,""         ,""             ,""           ,""           ,"#CV100Filtro('W2_ORIGEM')" }) //wfs - digitado na 12.1.18
   o:TableData('SXB',  {'EDE'     ,'6'      ,'01'    ,""         ,""             ,""           ,""           ,"#CV100Filtro('W2_DEST')" }) //wfs - digitado na 12.1.18

   //WHRS TE-6065 522314 / MTRADE-1111 - Descrição do banco posiciona incorretamente na parcela no contrato de cambio
    o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_RELACAO"   },2)
    o:TableData("SX3"  ,{"WB_DES_BCO" ,'POSICIONE("SA6",1,XFILIAL("SA6")+M->WB_BANCO+M->WB_AGENCIA+M->WB_CONTA,"A6_NREDUZ")'})

    // EJA - 20/07/2017
    o:TableStruct("SX1", {"X1_GRUPO", "X1_ORDEM", "X1_PERGUNT", "X1_DEF02", "X1_DEF03", "X1_DEF04", "X1_DEF05"})
    o:TableData("SX1", {"EIC350", "12", "Tipo de Contrato ?", "1-Cambio de Imp", "2-Remessa      ", "               ", "               "})

    // EJA - 20/07/2017
    o:TableStruct("SX1", {"X1_GRUPO", "X1_ORDEM", "X1_TIPO", "X1_TAMANHO", "X1_GSC", "X1_CNT01"})
    o:TableData("SX1", {"EIC350", "13", "C", 10, "S", "A Pagar"})

    //THTS - 17/08/2017 - MTRADE-1402 - Devolucao do Despachante
    o:TableStruct("SX3"  ,{"X3_CAMPO"   ,"X3_USADO"     ,"X3_WHEN"                },2)
    o:TableData  ("SX3"  ,{"WD_BANCO"   ,TODOS_MODULOS, "DI501WHEN('WD_BANCO')"   })
    o:TableData  ("SX3"  ,{"WD_AGENCIA" ,TODOS_MODULOS, "DI501WHEN('WD_AGENCIA')" })
    o:TableData  ("SX3"  ,{"WD_CONTA"   ,TODOS_MODULOS, "DI501WHEN('WD_CONTA')"   })

    //LRS - 15/09/2017
    o:TableStruct("SX3"  ,{"X3_CAMPO"   ,"X3_USADO"     },2)
    o:TableData  ("SX3"  ,{"WZ_PCREPRE" ,TODOS_MODULOS })

    //LRS - 24/10/2017
    o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_VALID"     },2)
    o:TableData  ("SX3"  ,{"WB_CONTA" ,"APE100Crit('CONTA')" })

Return

/*
Funcao                     : UPDEIC017
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			   :
Data/Hora   			   : 14/09/2017
*/
Function UPDEIC017(o)
Local nTamSA2
Local cHelp

   // EJA - 14/09/2017
   o:TableStruct("SX3", {"X3_CAMPO" ,  "X3_BROWSE"}, 2)
   o:TableData  ("SX3", {"YD_MAJ_PIS", "S"        })
   o:TableData  ("SX3", {"YD_MAJ_COF", "S"        })

    // EJA - 21/09/2017
    o:TableStruct("SX3", {"X3_CAMPO"    , "X3_USADO"}, 2)
    o:TableData(  "SX3" ,{"EIC_DESPES"  , TODOS_MODULOS})
    o:TableData(  "SX3" ,{"W3_FLUXO"    , TODOS_MODULOS})
    o:TableData(  "SX3" ,{"EWZ_HAWB"    , TODOS_MODULOS})
    o:TableData(  "SX3" ,{"A1_NATUREZ"  , TODOS_MODULOS})
    o:TableData(  "SX3" ,{"A2_NATUREZ"  , TODOS_MODULOS})

    o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_PICTURE"},2)
    o:TableData  ("SX3"  ,{"W5_PESO"  ,AvFormPict("W5_PESO")        })
    o:TableData  ("SX3"  ,{"W7_PESO"  ,AvFormPict("W7_PESO")        })

	//LRS - 15/09/2017
    o:TableStruct("SX3"  ,{"X3_CAMPO"   ,"X3_RELACAO"                },2)
    o:TableData  ("SX3"  ,{"EWU_DES_SI" , "POSICIONE('SYF',1,XFILIAL('SYF')+M->EWU_MOEDA,'YF_DESC_SI')"   })

    //LRS - 29/09/2017
    o:TableStruct("SX3"  ,{"X3_CAMPO"  ,"X3_USADO"     },2)
    o:TableData  ("SX3"  ,{"W9_SEGINC" ,TODOS_MODULOS })

    //LRS - 24/10/2017
    o:TableStruct("SX3"  ,{"X3_CAMPO"   ,"X3_WHEN"               },2)
    o:TableData  ("SX3"  ,{"W2_NR_PRO"  ,"PO400WHEN('W2_NR_PRO')"})
    o:TableData  ("SX3"  ,{"W2_DT_PRO"  ,"PO400WHEN('W2_DT_PRO')"})

    //NCF - 08/11/2017
    o:TableStruct( "SX1",{"X1_GRUPO" ,"X1_ORDEM","X1_PERGUNT"                     ,"X1_VARIAVL","X1_TIPO"  ,"X1_TAMANHO" ,"X1_DECIMAL" ,"X1_PRESEL" ,"X1_GSC","X1_VALID","X1_VAR01","X1_DEF01","X1_VAR02"  ,"X1_DEF02","X1_F3","X3_HELP"     ,"X1_PICTURE" })
    o:DelTableData("SX1",{"EICLC500" ,"07"      ,'Utilizar Dt.Cont. p/ Eventos ?' ,"MV_CH0"    ,"C"        ,1            ,0            ,2           ,"C"     ,""        ,"MV_PAR07","Sim"     ,""          ,"Nao"     ,""     ,".EICLC50007.",             })

    //THTS - 11/11/2017
    o:TableStruct("SX3",{"X3_CAMPO" , "X3_RESERV"},2)
    o:TableData(  "SX3",{"EV2_NOME1", TAM})
    o:TableData(  "SX3",{"EV2_NOME2", TAM})

    //EJA - 04/12/2017
    o:TableStruct("SX3",{"X3_CAMPO" , "X3_RELACAO"},2)
    o:TableData(  "SX3",{"EI4_FORNDE", "AvField('EI4_FORN+EI4_FORLOJ','A2_NREDUZ')"})
    o:TableData(  "SX3",{"EI4_CLINOM", "AvField('EI4_CLIENT+EI4_CLILOJ','A2_NREDUZ')"})
    o:TableData(  "SX3",{"EI4_EXPNOM", "AvField('EI4_EXPORT+EI4_EXPLOJ','A2_NREDUZ')"})
    o:TableData(  "SX3",{"A5_NOMERED", "AvField('A5_FORNECE+A5_LOJA','A2_NREDUZ')"})
    o:TableData(  "SX3",{"A5_FABRRED", "AvField('A5_FABR+A5_FALOJA','A2_NREDUZ')"})
    o:TableData(  "SX3",{"W0_FORNDES", "AvField('W0_FORN+W0_FORLOJ','A2_NREDUZ')"})
    o:TableData(  "SX3",{"W2_FORNDES", "AvField('W2_FORN+W2_FORLOJ','A2_NREDUZ')"})
    o:TableData(  "SX3",{"W2_CLINOME", "AvField('W2_CLIENTE+W2_CLILOJ','A2_NREDUZ')"})
    o:TableData(  "SX3",{"W2_EXPNOME", "AvField('W2_EXPORTA+W2_EXPLOJ','A2_NREDUZ')"})
    o:TableData(  "SX3",{"WB_FORNDES", "AvField('WB_FORN+WB_LOJA','A2_NREDUZ')"})
    o:TableData(  "SX3",{"WP_FABRDES", "AvField('WP_FABR+WP_FABLOJ','A2_NREDUZ')"})
    o:TableData(  "SX3",{"YG_NOMFABR", "AvField('YG_FABRICA+YG_FABLOJ','A2_NREDUZ')"})

    o:TableStruct("SX3",{"X3_CAMPO" , "X3_INIBRW"},2)
    o:TableData(  "SX3",{"EI4_FORNDE", "AvField('EI4_FORN+EI4_FORLOJ','A2_NREDUZ',,.T.)"})
    o:TableData(  "SX3",{"EI4_CLINOM", "AvField('EI4_CLIENT+EI4_CLILOJ','A2_NREDUZ',,.T.)"})
    o:TableData(  "SX3",{"EI4_EXPNOM", "AvField('EI4_EXPORT+EI4_EXPLOJ','A2_NREDUZ',,.T.)"})
    o:TableData(  "SX3",{"A5_FABRRED", "AvField('A5_FABR+A5_FALOJA','A2_NREDUZ',,.T.)"})
    o:TableData(  "SX3",{"W0_FORNDES", "AvField('W0_FORN+W0_FORLOJ','A2_NREDUZ',,.T.)"})
    o:TableData(  "SX3",{"W2_FORNDES", "AvField('W2_FORN+W2_FORLOJ','A2_NREDUZ',,.T.)"})
    o:TableData(  "SX3",{"W2_CLINOME", "AvField('W2_CLIENTE+W2_CLILOJ','A2_NREDUZ',,.T.)"})
    o:TableData(  "SX3",{"W2_EXPNOME", "AvField('W2_EXPORTA+W2_EXPLOJ','A2_NREDUZ',,.T.)"})
    o:TableData(  "SX3",{"WB_FORNDES", "AvField('WB_FORN+WB_LOJA','A2_NREDUZ',,.T.)"})
    o:TableData(  "SX3",{"WP_FABRDES", "AvField('WP_FABR+WP_FABLOJ','A2_NREDUZ',,.T.)"})
    o:TableData(  "SX3",{"YG_NOMFABR", "AvField('YG_FABRICA+YG_FABLOJ','A2_NREDUZ',,.T.)"})

    //THTS - 08/12/2017
    o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_PICTURE"              },2)
    o:TableData("SX3"  ,{"EG0_TEMPO" ,"@E 9,999,999.99999999"   })
    o:TableData("SX3"  ,{"EG0_TDISCH","@E 9,999,999.99999999"   })
    o:TableData("SX3"  ,{"EG0_TLOAD" ,"@E 9,999,999.99999999"   })

    //MPG - 14/12/2017
    o:TableStruct("SXB" ,{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM" })
    o:DelTableData("SXB",{"SJK" ,"5" ,"02" ,"" ,"" ,"" ,"" ,"" })
    o:DelTableData("SXB",{"SJK" ,"5" ,"03" ,"" ,"" ,"" ,"" ,"" })
    o:DelTableData("SXB",{"SJK" ,"5" ,"04" ,"" ,"" ,"" ,"" ,"" })

    //THTS - 12/12/2017
    nTamSA2 := AVSX3("A2_COD",3)
    o:TableStruct('SX1',{'X1_GRUPO','X1_ORDEM','X1_TAMANHO' ,'X1_GRPSXG'})
    o:TableData('SX1'  ,{'EIC152'  ,'04'      ,nTamSA2      ,'001'      })
    o:TableData('SX1'  ,{'EIC275'  ,'03'      ,nTamSA2      ,'001'      })
    o:TableData('SX1'  ,{'EICC21'  ,'01'      ,nTamSA2      ,'001'      })
    o:TableData('SX1'  ,{'EIOR02'  ,'03'      ,nTamSA2      ,'001'      })
    o:TableData('SX1'  ,{'EIOR03'  ,'03'      ,nTamSA2      ,'001'      })
    o:TableData('SX1'  ,{'EIOR06'  ,'03'      ,nTamSA2      ,'001'      })
    o:TableData('SX1'  ,{'EIOR07'  ,'01'      ,nTamSA2      ,'001'      })

    //NCF - 14/12/2017
    o:TableStruct("SX3"  ,{"X3_CAMPO"   , "X3_VALID"     , "X3_WHEN"   },2)
    o:TableData  ("SX3"  ,{"A5_FALOJA"  , "A060VldCpo()" , "" })

    //THTS - 16/01/2018
    o:TableStruct("SX3",{"X3_ARQUIVO","X3_CAMPO"    , "X3_RESERV"},2)    
    o:TableData(  "SX3",{"EIW"       ,"EIW_FOB_R"   , DEC    })
    o:TableData(  "SX3",{"EIW"       ,"EIW_VALMER"  , DEC    })

    //LRS - 19/01/2018
    o:TableStruct("SX3",{"X3_CAMPO" , "X3_TITULO"},2)
    o:TableData(  "SX3",{"WP_DESTAQ", "Destaque Imp"})

    //LRS - 02/02/2018
    cHelp := "Rel. por Empresa: Será apresentado todos os câmbios em aberto ou liquidados dentro do período informado" +CHR(13)+CHR(10) +;
               "Previsão Diaria: Será apresentado todos os câmbios em aberto dentro do período informado."

    o:TableStruct("HELP" ,{"NOME"        ,"PROBLEMA" ,"SOLUCAO"})
    o:TableData("HELP"   ,{"P.EIC15002." ,cHelp      ,""       })

    o:TableStruct('SX1',{'X1_GRUPO','X1_ORDEM','X1_HELP'})
    o:TableData('SX1'  ,{'EIC150'  ,'02'      ,'P.EIC15002.' })


   //CEO - 27/02/2018 - Ajuste no gatilho W1_FORN
   o:TableStruct ("SX7",{"X7_CAMPO", "X7_SEQUENC", "X7_REGRA",                   "X7_CDOMIN", "X7_TIPO", "X7_SEEK",  "X7_ALIAS", "X7_ORDEM", "X7_CHAVE", "X7_CONDIC",   "X7_PROPRI"})
   o:TableData   ("SX7",{"W1_FORN" , "003",        "SI400Gatilho('W1_FORN_03')", "W1_PRECO",  "P",       "N",        "",         "0",        "",         "",            ""})

   //CEO - 13/06/2018
   o:TableStruct("SX3",{"X3_CAMPO", "X3_GRPSXG", "X3_USADO"},2)
   o:TableData  ("SX3",{"EW5_FABR", "001", "TODOS_MODULOS" })

   //CEO - 23/05/2018
   o:TableStruct("SX3",{"X3_CAMPO", "X3_RESERV"},2)
   o:TableData  ("SX3",{"EI5_PART_N", TAM})

   o:TableStruct("SX3",{"X3_CAMPO", "X3_GRPSXG"},2)
   o:TableData  ("SX3",{"EI5_FABR ", "001"})

    //MPG - 15/02/2018
    o:TableStruct(  "SX3"   ,{"X3_CAMPO"  ,"X3_VISUAL"  , "X3_USADO"         },2)
    o:TableData(    "SX3"   ,{"C1_NUM_SI" , "V"         , "TODOS_MODULOS"    })

    //LRS - 02/03/2018
    o:TableStruct("SX3",{"X3_CAMPO" , "X3_RESERV"},2)
    o:TableData(  "SX3",{"WN_LOCAL ", TAM})

    //LRS - 09/03/2018
    o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                              ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                                          ,"X6_DSCSPA1" ,"X6_DSCENG1"  ,"X6_DESC2"                                      ,"X6_DSCSPA2" ,"X6_DSCENG2" ,"X6_CONTEUD"  ,"X6_CONTSPA" ,"X6_CONTENG" ,"X6_PROPRI","X6_PYME"},1)
    o:TableData("SX6"  ,{"  "       ,"MV_EIC0033" ,"L"      ,"Permite ao usuario imprimir o cabeçalho ",""          ,""          ,"completo na impressão por data (.T.) ou não (.F.) ",""           ,""            ,"na rotina de Prev. Desembolso"                 ,""           ,""           ,".F."         ,".F."        ,".F."        ,".F."      ,".F."    })
    o:TableData("SX6"  ,{"  "       ,"MV_EIC0034" ,"C"      ,"Permite ao usuario definir a não "       ,""          ,""          ,"impressão de despesas iniciadas por estes códigos ",""           ,""            ,"na rotina de Prev. Desembolso (Ex.: 1;2;...)"  ,""           ,""           ,""            ,""           ,""           ,""         ,".F."    })
    o:TableData("SX6"  ,{"  "       ,"MV_EIC0035" ,"C"      ,"Permite ao usuario definir o campo data ",""          ,""          ,"base para calculo do desembolso na rotina de "     ,""           ,""            ,"Prev. Desembolso"                              ,""           ,""           ,""            ,""           ,""           ,""         ,".F."    })

    //LRS - 19/03/2018
    o:TableStruct("SX3",{"X3_CAMPO"   , "X3_WHEN"},2)
    o:TableData(  "SX3",{"W6_VLFREPP ", "DI400ENC(3)"})
    o:TableData(  "SX3",{"W6_VLFRECC ", "DI400ENC(3)"})
    o:TableData(  "SX3",{"W6_VLFRETN ", "DI400ENC(3)"})
    o:TableData(  "SX3",{"W6_CONDP_F ", "DI400ENC(3)"})
    o:TableData(  "SX3",{"W6_DIASP_F ", "DI400ENC(1)"})
    o:TableData(  "SX3",{"W6_TX_SEG " , "DI400ENC(3)"})
    o:TableData(  "SX3",{"W6_CONDP_S ", "DI400ENC(1)"})
    o:TableData(  "SX3",{"W6_DIASP_S ", "DI400ENC(1)"})
    o:TableData(  "SX3",{"W6_VL_USSE ", "DI400ENC(3)"})
    o:TableData(  "SX3",{"W6_SEGMOED ", "DI400ENC(3)"})

    //LRS  - 27/03/2018
    o:TableStruct(  "SX3"   ,{"X3_CAMPO", "X3_USADO"         },2)
    o:TableData(    "SX3"   ,{"W0_MOEDA", "TODOS_MODULOS"    })
    o:TableData(    "SX3"   ,{"W0_SIKIT", "TODOS_MODULOS"    })
    o:TableData(    "SX3"   ,{"W0_KITSERI", "TODOS_MODULOS"  })
    o:TableData(    "SX3"   ,{"W0_FORN", "TODOS_MODULOS"     })
    o:TableData(    "SX3"   ,{"W0_QTDE", "TODOS_MODULOS"     })
    o:TableData(    "SX3"   ,{"W0_DT_NEC", "TODOS_MODULOS"   })
    o:TableData(    "SX3"   ,{"W0_DT_EMB", "TODOS_MODULOS"   })
    o:TableData(    "SX3"   ,{"W0_CLASKIT", "TODOS_MODULOS"  })
    o:TableData(    "SX3"   ,{"W0_SOLIC", "TODOS_MODULOS"    })
    //o:TableData(    "SX3"   ,{"W0_REFER1", "TODOS_MODULOS"   })// LRS - 28/03/2018 - Campos nopados pois está como não usado no ATUSX
    //o:TableData(    "SX3"   ,{"W0_HAWB_DA", "TODOS_MODULOS"  })
    //o:TableData(    "SX3"   ,{"W0_ID", "TODOS_MODULOS"       })
    //o:TableData(    "SX3"   ,{"W0_CONTR", "TODOS_MODULOS"    })
    //o:TableData(    "SX3"   ,{"W0_C3_NUM", "TODOS_MODULOS"   })

    o:TableStruct(  "SX3"   ,{"X3_CAMPO", "X3_USADO"         },2)
    o:TableData(    "SX3"   ,{"W1_PRECO", "TODOS_MODULOS"    })
    o:TableData(    "SX3"   ,{"W1_COD_DES", "TODOS_MODULOS"  })
    o:TableData(    "SX3"   ,{"W1_FAB_NOM", "TODOS_MODULOS"  })
    o:TableData(    "SX3"   ,{"W1_FOR_NOM", "TODOS_MODULOS"  })
    o:TableData(    "SX3"   ,{"W1_VMCLASS", "TODOS_MODULOS"  })
    o:TableData(    "SX3"   ,{"W1_UM", "TODOS_MODULOS"       })
    o:TableData(    "SX3"   ,{"W1_PO_NUM", "TODOS_MODULOS"   })
    o:TableData(    "SX3"   ,{"W1_SEQ", "TODOS_MODULOS"      })
    o:TableData(    "SX3"   ,{"W1_CC", "TODOS_MODULOS"       })
    o:TableData(    "SX3"   ,{"W1_SI_NUM", "TODOS_MODULOS"   })
    o:TableData(    "SX3"   ,{"W1_PRAZO", "TODOS_MODULOS"    })
    o:TableData(    "SX3"   ,{"W1_QTSEGUM", "TODOS_MODULOS"  })
    o:TableData(    "SX3"   ,{"W1_SEGUM", "TODOS_MODULOS"    })
    o:TableData(    "SX3"   ,{"W1_CODMAT", "TODOS_MODULOS"   })
    //o:TableData(    "SX3"   ,{"W1_STATUS", "TODOS_MODULOS"   })
    o:TableData(    "SX3"   ,{"W1_NR_CONC", "TODOS_MODULOS"  })
    o:TableData(    "SX3"   ,{"W1_DT_CANC", "TODOS_MODULOS"  })
    o:TableData(    "SX3"   ,{"W1_MOTCANC", "TODOS_MODULOS"  })
    o:TableData(    "SX3"   ,{"W1_COMPLEM", "TODOS_MODULOS"  })
    o:TableData(    "SX3"   ,{"W1_DT_SI", "TODOS_MODULOS"    })

    //LRS - 22/05/2018
    cHelp := "Serão impressas as previsões das despesas do processo, conforme a tabela de pré-calculo vinculada." +CHR(13)+CHR(10) +;
               "As previsões serão geradas apenas para os processos que não possuem notas fiscais."

    o:TableStruct("HELP" ,{"NOME"       ,"PROBLEMA" ,"SOLUCAO"})
    o:TableData("HELP"   ,{"EICRCUST05" ,cHelp      ,""       })

    o:TableStruct('SX1',{'X1_GRUPO','X1_ORDEM','X1_HELP'       })
    o:TableData('SX1'  ,{'EICRCUST','05'      ,'EICRCUST05' })

     //NCF - 30/05/2018
    o:TableStruct("SX3"  ,{"X3_CAMPO"    , "X3_VALID"                                                                                               },2)
    o:TableData  ("SX3"  ,{"EIC_DESPES"  , '(ExistCpo("SYB",M->EIC_DESPES).OR.VAZIO()).And.If(FindFunction("NU400Vld"),NU400Vld("EIC_DESPES"),.T.)' })

    //LRS- 05/06/2018
    o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_PICTURE"           },2)
    o:TableData  ("SX3",{"W6_PESO_BR",AvFormPict("W6_PESO_BR") })

    o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_PICTURE"           },2)
    o:TableData  ("SX3",{"W2_PESO_B" ,AvFormPict("W2_PESO_B")  })

    o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                        ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                                    ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"},1)
    o:TableData("SX6"  ,{"  "       ,"MV_EIC0069" ,"L"      ,"Habilita (T) o controle de importação via SUFRAMA" ,""          ,""          ,"(Superintendência da Zona Franca de Manaus)" ,            ,            ,""        ,""          ,""          ,".T."        ,            ,           ,"S"        ,"N"      ,""        , ""       , ""        , ""          , ""         })

    //NCF - 12/06/2018
    o:TableStruct("SX3"  ,{"X3_CAMPO"    , "X3_TRIGGER" },2)
    o:TableData  ("SX3"  ,{"W3_FABLOJ"   , "S"          })

    o:TableStruct("SX7",{ 'X7_CAMPO' , 'X7_SEQUENC' , 'X7_REGRA'                     , 'X7_CDOMIN', 'X7_TIPO' , 'X7_SEEK' , 'X7_ALIAS' , 'X7_ORDEM' , 'X7_CHAVE'  , 'X7_CONDIC'               , 'X7_PROPRI'})
    o:TableData  ('SX7',{ 'W3_FABR'  , '001'        , 'PO400Gatlh("W3_FABR001")'     ,            ,           ,           ,            ,            ,             ,                           ,            })
    o:TableData  ('SX7',{ 'W3_FABR'  , '002'        , 'PO400Gatlh("W3_FABR002",.T.)' , 'W3_PRECO' ,'P'        ,           ,            ,            ,             , 'Po400CdGat("W3_FABR")'   , 'S'        })
    o:TableData  ('SX7',{ 'W3_FABLOJ', '001'        , 'PO400Gatlh("W3_FABLOJ",.T.)'  , 'W3_PRECO' ,'P'        ,           ,            ,            ,             , 'Po400CdGat("W3_FABLOJ")' , 'S'        })

    //NCF - 11/06/2018
    o:TableStruct("SX3"  ,{"X3_CAMPO"   , "X3_USADO"    , "X3_VALID"                                                                                        },2)
    o:TableData  ("SX3"  ,{"EIM_HAWB"   , TODOS_MODULOS ,                                                                                                   })
    o:TableData  ("SX3"  ,{"B1_POSIPI"  ,               ,'If(cModulo$"EEC/EDC/EIC/ESS",AC120Valid("B1_POSIPI"),Vazio() .Or. ExistCpo("SYD",M->B1_POSIPI))'  })

    o:TableStruct("SX7",{'X7_CAMPO' ,'X7_SEQUENC','X7_REGRA' })
    o:TableData  ('SX7',{'W6_DI_NUM','001'       ,'GeraVersaoDI()'})

    //LRS - 10/07/2018
    o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                         ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                                          ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2"                                           ,"X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"},1)
    o:TableData("SX6"  ,{"  "       ,"MV_NFFILHA" ,"C"      ,"Valores que serão considerados na nota filha.  0: " ,""          ,""          ,"Mercadoria+(FOB+FRETE+SEGURO+CIF+II) 1:Tipo “0”+  ",            ,            ,"todas despesas 2: Valor FOB 3:MV_NFFILHA + ICMS   " ,""          ,""          ,"0"         ,            ,           ,"S"        ,"N"      ,""        , ""       , ""        , ""          , ""         })

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

    //THTS - 01/08/2018
    o:TableStruct("SX3"  ,{"X3_CAMPO" ,"X3_USADO" },2)
    o:TableData  ("SX3"  ,{"YR_KILO2" ,EIC_USADO+EDC_USADO  })

    //EJA - 21/08/2018
    o:TableStruct("SX3"   ,{"X3_CAMPO"  , "X3_RELACAO"                                 , "X3_INIBRW"}                                      , 2)
    o:TableData(  "SX3"   ,{"W2_CLINOME", "AVFIELD('W2_CLIENTE+W2_CLILOJ','A1_NREDUZ')", "AvField('W2_CLIENTE+W2_CLILOJ','A1_NREDUZ',,.T.)"})

    //CEO - 26/09/2018
    o:TableStruct("SX3",{"X3_CAMPO"  , "X3_RESERV"}, 2)
    o:TableData("SX3"  ,{"WZ_RED_ICM", TAM+DEC    })

    //CEO - 01/10/2018
    o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                       ,"X6_DSCSPA" ,"X6_DSCENG"   ,;
                        "X6_DESC1"                  ,"X6_DSCSPA1"   ,"X6_DSCENG1"   ,"X6_DESC2"                                 ,"X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME","X6_VALID", "X6_INIT", "X6_DEFPOR", "X6_DEFSPA", "X6_DEFENG"},1)

    o:TableData("SX6"  ,{"  "       ,"MV_EIC0070" ,"L"      ,"Desconsiderar despesas base de imposto SIM e base",""          ,""            ,;
                        "de custo NAO do valor da mercadoria da" ,""              ,""             ,"nota fiscal de importação." ,""          ,""          ,".F."        ,            ,            ,"S"        ,"N"      ,""        , ""       , ""        , ""          , ""         })

    o:TableStruct("SX3",{"X3_CAMPO"  , "X3_RESERV"}, 2)
    o:TableData("SX3"  ,{"W2_NR_PRO", ORDEM+USO+TAM})
    o:TableData("SX3"  ,{"EYZ_NR_PRO", TAM    })        //VERIFICAR O OBRIGATORIO
    o:TableData("SX3"  ,{"EI4_NR_PRO ", ORDEM+USO+TAM })

    //NCF - 25/10/2018
    o:TableStruct("SX6",{"X6_FIL","X6_VAR"     ,"X6_DESCRIC","X6_DESC1" ,"X6_DESC2","X6_CONTEUD" },1)
    o:TableData("SX6"  ,{"  "    ,"MV_EASYTMP" ,"OBSOLETO"  ,"OBSOLETO" ,"OBSOLETO",".T."        })

    o:TableStruct( "SX1",{"X1_GRUPO" ,"X1_ORDEM","X1_PERGUNT"              ,"X1_VARIAVL","X1_TIPO"  ,"X1_TAMANHO" ,"X1_DECIMAL" ,"X1_PRESEL" ,"X1_GSC","X1_VALID"                             ,"X1_VAR01","X1_DEF01"   ,"X1_VAR02"  ,"X1_DEF02"           ,"X1_DEF03"      ,"X1_DEF04"      ,"X1_F3","X3_HELP"     ,"X1_PICTURE" })
    o:DelTableData("SX1",{"AM10401"  ,"01"      ,'Tipo de relatório'       ,"mv_ch1"    ,"N"        ,1            ,0            ,0           ,"C"     ,""                                     ,"MV_PAR01","Analítico"  ,""          ,"Sintético"          ,""              ,""              ,""     ,""            ,             })
    o:DelTableData("SX1",{"AM10401"  ,"02"      ,'Processo de Importação'  ,"mv_ch2"    ,"C"        ,17           ,0            ,0           ,"G"     ,"ExistCpo(‘EWG’)"                      ,"MV_PAR02",             ,""          ,""                   ,""              ,""              ,"EWG"  ,""            ,             })
    o:DelTableData("SX1",{"AM10401"  ,"03"      ,'Código do Armazem'       ,"mv_ch3"    ,"C"        ,6            ,0            ,0           ,"G"     ,"ExistCpo(‘SA2’)"                      ,"MV_PAR03",             ,""          ,""                   ,""              ,""              ,"SA2"  ,""            ,             })
    o:DelTableData("SX1",{"AM10401"  ,"04"      ,'Loja do Armazem'         ,"mv_ch4"    ,"C"        ,2            ,0            ,0           ,"G"     ,"ExistCpo(‘SA2’, mv_par03 + mv_par04)" ,"MV_PAR04",             ,""          ,""                   ,""              ,""              ,"SA22" ,""            ,             })
    o:DelTableData("SX1",{"AM10401"  ,"05"      ,'Filtro por situação'     ,"mv_ch5"    ,"N"        ,1            ,0            ,0           ,"C"     ,""                                     ,"MV_PAR05","Previsto"   ,""          ,"Realizado"          ,""              ,""              ,       ,""            ,             })
    o:DelTableData("SX1",{"AM10401"  ,"06"      ,'Ordenar por'             ,"mv_ch6"    ,"N"        ,1            ,0            ,0           ,"C"     ,""                                     ,"MV_PAR06","Armazem"    ,""          ,"Data Início Armaz." ,"Vlr. Realizado","Vlr. Previsto" ,       ,""            ,             })

    //NCF - 26/12/2018
    o:TableStruct("SX3",{"X3_CAMPO"  , "X3_F3"},2)
    o:TableData("SX3"  ,{"WB_CHVASS" , "SWBF3"}  )

    o:TableStruct("SXB",{"XB_ALIAS", "XB_TIPO","XB_SEQ","XB_CONTEM"     })
    o:TableData("SXB"  ,{ "SWBF3"  , "5"      ,"01"    ,"AP100F3PgRet()"})

    //THTS - 04/01/2019 - Movido do Release 12.1.07 para o 12.1.17, pois nao tinha sido digitado no AtuSX
   o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"           ,"XB_DESCSPA"          ,"XB_DESCENG"          ,"XB_CONTEM"                                       ,"XB_WCONTEM"})
   o:TableData("SXB"  ,{"AVI002"  , "3"     ,"01"    ,"01"       ,                      ,                      ,                      ,"01#CadFabSxb()#AxVisual('SA5',SA5->(Recno()),2)" ,            })

   o:TableStruct("HELP" ,{"NOME"       , "PROBLEMA"                                              , "SOLUCAO"})
   o:TableData  ("HELP" ,{"YK_TXGUEIM" , "Taxa de imposto aplicado sobre os impostos do processo", ""       })

   // MPG - 20/03/2019
   o:TableStruct("SX3", {"X3_CAMPO" , "X3_BROWSE"},2)
   o:TableData  ("SX3", {"WP_MICRO" , "N"        })
   o:TableData  ("SX3", {"WP_NR_MAQ", "N"        })

   //EJA - 29/03/2019
    o:TableStruct("SX3",{"X3_CAMPO"  , "X3_TITULO"   , "X3_DESCRIC"},2)
    o:TableData(  "SX3",{"EIC_CODINT", "Lote de Lib.", "Lote de Liberação"})
    o:TableData(  "SX3",{"WD_CODINT" , "Lote de Lib.", "Lote de Liberação"})

    //EJA - 18/04/2019
    o:TableStruct("SX3",{"X3_CAMPO" , "X3_USADO"},2)
    o:TableData  ("SX3",{"W6_IMPENC", TODOS_MODULOS})

    //EJA - 10/05/2019
    o:TableStruct("SX7",{"X7_CAMPO"  , "X7_SEQUENC",  "X7_REGRA"       , "X7_CDOMIN" , "X7_TIPO","X7_SEEK","X7_ALIAS", "X7_ORDEM", "X7_CHAVE"                               , "X7_CONDIC","X7_PROPRI"})
    o:TableData("SX7"  ,{"W9_FORN"   , "001"       ,  "SA2->A2_LOJA"   , "W9_FORLOJ" , "P"      ,"S"      ,"SA2"     , "1"       , "xFILIAL('SA2')+M->W9_FORN"              , ""         ,"S"        })
    o:TableData("SX7"  ,{"W9_FORLOJ",  "001"       ,  "SA2->A2_NREDUZ" , "W9_NOM_FOR", "P"      ,"S"      ,"SA2"     , "1"       , "xFILIAL('SA2')+M->W9_FORN+M->W9_FORLOJ" , ""         ,"S"        })

    //EJA - 29/05/2019
    o:TableStruct("SX6",{"X6_FIL","X6_VAR"     , "X6_DESC1"                                        , "X6_DESC2"                                  },1)
    o:TableData("SX6"  ,{"  "    ,"MV_NR_ISUF" , "máxima de itens por adição. Se o valor for menor", "ou igual a zero, será assumido o valor 78."})

    //EJA - 30/05/2019
    o:TableStruct("SX3"  ,{"X3_CAMPO"  , "X3_PICTVAR"          },2)
    o:TableData  ("SX3"  ,{"EIJ_AGENID", "EICPAg(M->EIJ_TPAGE)"})

    //MFR - 13/06/2019 OSSME-3156
    o:TableStruct("SX6",{"X6_VAR"     ,"X6_DESCRIC"                                        ,"X6_DSCSPA" ,"X6_DSCENG" ,"X6_DESC1"                                           ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2"                                      ,"X6_DSCSPA2","X6_DSCENG2"},1)
    o:TableData("SX6"  ,{"MV_NRPO"    ,"Define se a numeração do Purchase Order será seque",""          ,""          ,"ncial com base na tabela SC7. Valores: S para habi" ,            ,            ,"litar e N para desabilitar."                   ,""          ,""          })

    //EJA - 23/07/2019
    o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_USADO"    , "X3_RESERV"   },2)
    o:TableData  ("SX3",{"WB_CA_TX"  ,TODOS_MODULOS , ORDEM+USO+TAM+DEC })

Return

/*
Funcao                     : UPDEIC033
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização do SX5 por empresa filial
Autor       			   :
Data/Hora   			   : 27/07/2021
*/
Function UPDEIC033Fil(o)

    //Alterando a tabela C5 da SX5 com os novos valores relacionados a DI de acordo com nova PORTARIA ME Nº 4131/2021
    o:TableStruct('SX5'  ,{'X5_TABELA','X5_CHAVE','X5_DESCRI' ,'X5_DESCSPA','X5_DESCENG'})
    o:TableData  ("SX5"  ,{ 'C5'      , '00'     , '115.67'   , '115.67'   , '115.67'   })
    o:TableData  ("SX5"  ,{ 'C5'      , '02'     , '38.56'    , '38.56'    , '38.56'    })
    o:TableData  ("SX5"  ,{ 'C5'      , '05'     , '30.85'    , '30.85'    , '30.85'    })
    o:TableData  ("SX5"  ,{ 'C5'      , '10'     , '23.14'    , '23.14'    , '23.14'    })
    o:TableData  ("SX5"  ,{ 'C5'      , '20'     , '15.42'    , '15.42'    , '15.42'    })
    o:TableData  ("SX5"  ,{ 'C5'      , '50'     , '7.71'     , '7.71'     , '7.71'     })
    o:TableData  ("SX5"  ,{ 'C5'      , '99'     , '3.86'     , '3.86'     , '3.86'     })

Return

/*
Funcao            : UPDEIC033V
Parametros        : Objeto de update PAI
Objetivos         : Ajustar no dicionario SX5 a tabela Y3
Revisao           : -
Autor             : Nilson César
Obs.              : O Ajuste foi digitado no ATUSX em Agosto/2021
*/
Function UPDEIC033V(o)

    o:TableStruct('SX5' ,{'X5_TABELA','X5_CHAVE','X5_DESCRI'                ,'X5_DESCSPA'               ,'X5_DESCENG'           })
    o:TableData(   "SX5",{"Y3"       ,"1"        ,"Marítima"                ,"Marítimo"                 ,"By Sea"               })
    o:TableData(   "SX5",{"Y3"       ,"4"        ,"Aérea"                   ,"Aéreo"                    ,"By Airmail"           })
    o:TableData(   "SX5",{"Y3"       ,"6"        ,"Ferroviária"             ,"FERROVIA"                 ,"By Railroad"          })
    o:TableData(   "SX5",{"Y3"       ,"7"        ,"Rodoviária"              ,"CARRETERA"                ,"By Road"              })
    o:TableData(   "SX5",{"Y3"       ,"8"        ,"Conduto/Rede Transmissão","TUBO CONDUCTO"            ,"Duct Tube"            })
    o:TableData(   "SX5",{"Y3"       ,"9"        ,"Meios Próprios"          ,"Medios Propios"           ,"Own Means"            })
    o:TableData(   "SX5",{"Y3"       ,"A"        ,"Entrada/Saída Ficta"     ,"Entrada/Salida FICTA"     ,"Ficta Inflow/Outflow" })

Return

/*
Funcao            : UPDEIC033W
Parametros        : Objeto de update PAI
Objetivos         : Ajustar no dicionario para DUIMP
Revisao           : -
Autor             : Nilson César
Obs.              : O Ajuste foi digitado no ATUSX em Outubro/2021
*/
Function UPDEIC033W(o)

    //Alterar Ordem do campo na tela
    o:TableStruct('SX3'  ,{'X3_CAMPO'  ,'X3_ORDEM'},2)
    o:TableData  ("SX3"  ,{'W6_TIPOREG','9Y'      })

    o:TableStruct("SXB", {"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM"                               ,"XB_WCONTEM"})
    o:DelTableData("SXB",{"EKL"     ,"5"      ,"02"    ,""         ,""         ,""          ,""          ,'If(LEFT(EKL->EKL_CODFOR,1)=="I","1","2")',""          })

Return

/*
Funcao                     : UPDEIC033
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			   :
Data/Hora   			   : 14/09/2017
*/
Function UPDEIC033(o)

    //Alteração de Título
    o:TableStruct("SX3",{"X3_CAMPO" , "X3_TITULO"},2)
    o:TableData(  "SX3",{"EK9_MSBLQL", "Bloqueado?"})
    o:TableData(  "SX3",{"EK9_MODALI", "Modalidade"})
    o:TableData(  "SX3",{"EK9_ULTALT", "Alterado Por"})
    o:TableData(  "SX3",{"EKB_OPERFB", "TIN"})
    o:TableData(  "SX3",{"EKD_MODALI", "Modalidade"})

    //mudança de campos de um folder para outro - EK9
    o:TableStruct("SX3",{"X3_CAMPO"     ,"X3_FOLDER" },2)
    o:TableData  ("SX3",{"EK9_DSCNCM"   ,"3"         })
    o:TableData  ("SX3",{"EK9_UNIEST"   ,"3"         })
    o:TableData  ("SX3",{"EK9_MSBLQL"   ,"3"         })
    o:TableData  ("SX3",{"EK9_DSCCOM"   ,"3"         })
    o:TableData  ("SX3",{"EK9_OBSINT"   ,"3"         })
    o:TableData  ("SX3",{"EK9_ULTALT"   ,"3"         })
    o:TableData  ("SX3",{"EK9_RETINT"   ,"2"         })

    //Mudança de campos de um folder para outro - EKD
    //Diversos campos da EK9 não estão presentes na EKD
    o:TableData  ("SX3",{"EKD_UNIEST"   ,"3"         })
    o:TableData  ("SX3",{"EKD_OBSINT"   ,"3"         })
    o:TableData  ("SX3",{"EKD_RETINT"   ,"2"         })

    //Ordenação de campos
    o:TableStruct('SX3'  ,{'X3_CAMPO'  ,'X3_ORDEM'},2)
    o:TableData  ("SX3"  ,{'EKB_PAIS'  ,'05'        })
    o:TableData  ("SX3"  ,{'EKB_PAISDS','06'      })
    o:TableData  ("SX3"  ,{'EKB_OESTAT','07'      })
    o:TableData  ("SX3"  ,{'EKB_OPERFB','08'      })
    o:TableData  ("SX3"  ,{'EKB_OENOME','09'      })
    o:TableData  ("SX3"  ,{'EKB_OEEND' ,'10'       })
    o:TableData  ("SX3"  ,{'EKF_PAIS'  ,'05'       })
    o:TableData  ("SX3"  ,{'EKF_PAISDS','06'      })

    //alterar campo para Visual
    o:TableStruct('SX3'  ,{'X3_CAMPO'  ,'X3_VISUAL'},2)
    o:TableData  ("SX3"  ,{'EK9_IDPORT','V'      })
    o:TableData  ("SX3"  ,{'EK9_VATUAL','V'      })

Return

/*
Função     : AtuTE1101()
Objetivo   : Atualização do Status do campo WZ_BASENFT
Retorno    :
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data       : 07/06/2017
*/
Static Function AtuTE1101()
Local aSM0:= {}
Local nCont, cOldFilial

Begin Sequence

    cOldFilial:= cFilAnt
    aSM0:= FWLoadSM0()

    For nCont:= 1 To Len(aSM0)
        If aSm0[nCont][1] == cEmpAnt
            cFilAnt:= aSm0[nCont][2]
            updTE1101(cFilAnt)
        EndIf
    Next

    cFilAnt:= cOldFilial

End Sequence

Return

/*
Função     : updTE1101()
Objetivo   : Query para atualização, por filial
Retorno    :
Autor      : Tiago Henrique Tudisco dos Santos - THTS
Data       : 07/06/2017
*/
Static Function updTE1101(cFil)
Local cQuery

   cQuery:= "Select R_E_C_N_O_ RECNO From " + RetSqlName("SWZ") + " WHERE WZ_BASENFT = ' ' "
   If TcSrvType() <> "AS/400"
      cQuery += " AND D_E_L_E_T_ <> '*'"
   EndIf

   cQuery:= ChangeQuery(cQuery)
   TcQuery cQuery Alias "TMPSZW" New

    While TMPSZW->(!Eof())
        SWZ->(dbGoTo(TMPSZW->(RECNO)))
        SWZ->(RecLock("SWZ", .F.))
        SWZ->WZ_BASENFT := '3' //Nao Configurado
        SWZ->(MsUnlock())

        TMPSZW->(DBSkip())
   EndDo

   TMPSZW->(DBCloseArea())
Return
