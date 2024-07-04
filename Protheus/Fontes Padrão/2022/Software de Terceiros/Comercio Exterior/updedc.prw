#Include 'Protheus.ch'
#Include "Average.ch"
#Include "TOPCONN.CH"

/*
Funcao                     : UPDEDC007
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Revisao                    :
Obs.                       :
*/
Function UPDEDC007(o)

//LGS-09/12/2015
o:TableStruct('SX3' ,{'X3_CAMPO' ,'X3_F3' },2)
o:TableData  ('SX3' ,{'ED9_AC'   ,'ED3'   })

o:TableStruct("SX3",{"X3_CAMPO"   , "X3_USADO"},2)
o:TableData("SX3"  ,{'A5_VLCOTUS' , EIC_USADO+EDC_USADO})        //NCF - 26/07/2018 - O AvUpdate01 não entende a concatenação de módulos específicos.
o:TableData("SX3"  ,{'B1_VLREFUS' , EIC_USADO+EDC_USADO})

o:TableStruct("SX3",{"X3_CAMPO"   , "X3_ORDEM"},2)
o:TableData("SX3"  ,{'ED0_ELETRO' , "06"      })
o:TableData("SX3"  ,{'ED0_DEFERI' , "13"      })

o:TableStruct("SX3",{"X3_CAMPO"   , "X3_RELACAO"                                 },2)
o:TableData("SX3"  ,{'ED0_ENQCOD' , 'If(left(cModal,1) == "1","81101","80000")'  })

o:TableStruct("SX3",{"X3_CAMPO"   , "X3_CBOX"     , "X3_CBOXSPA"  , "X3_CBOXENG"   },2)
o:TableData("SX3"  ,{'ED0_INTEGR' , 'S=Sim;N=Não' , 'S=Sim;N=Não' , 'S=Sim;N=Não'  })

o:TableStruct("SX3",{"X3_CAMPO"   , "X3_RESERV" },2)
o:TableData("SX3"  ,{'ED2_FILORI' , TAM+DEC     })

o:TableStruct("SX3",{"X3_CAMPO"   , "X3_FOLDER" },2)
o:TableData("SX3"  ,{'ED9_PEDIDO' , "1"     })
o:TableData("SX3"  ,{'ED9_CODEXP' , "1"     })
o:TableData("SX3"  ,{'ED9_EXPLOJ' , "1"     })
o:TableData("SX3"  ,{'ED9_QTD'    , "1"     })
o:TableData("SX3"  ,{'ED9_DESEXP' , "1"     })
o:TableData("SX3"  ,{'ED9_MOD_NF' , "2"     })

Return NIL

/*
Funcao                     : UPDEDC016
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Revisao                    :
Obs.                       :
*/
Function UPDEDC016(o)

//LRS - 04/12/2017
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_USADO"},2)
o:TableData('SX3'  ,{'ED0_PERCPE' ,TODOS_MODULOS})

Return NIL

/*
Funcao                     : UPDEDC017
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Revisao                    :
Obs.                       :
*/
Function UPDEDC017(o)

//NCF - 04/05/2018
o:TableStruct("SX3",{"X3_CAMPO"   , "X3_PICTURE"                          , "X3_VALID"                                                , "X3_F3"}, 2)
o:TableData('SX3'  ,{'ED1_AC'     , Replicate( "9" , TamSX3("ED1_AC")[1] ),                                                           ,})
o:TableData('SX3'  ,{'ED2_AC'     , Replicate( "9" , TamSX3("ED2_AC")[1] ),                                                           ,})
o:TableData('SX3'  ,{'ED3_AC'     , Replicate( "9" , TamSX3("ED3_AC")[1] ),                                                           ,})
o:TableData('SX3'  ,{'ED4_AC'     , Replicate( "9" , TamSX3("ED4_AC")[1] ),                                                           ,})
o:TableData('SX3'  ,{"ED8_FORN"   ,                                       , 'Vazio() .Or. ExistCpo("SA2", M->ED8_FORN)'               , "SA2A"})
o:TableData('SX3'  ,{"ED8_LOJA"   ,                                       , 'Vazio() .Or. ExistCpo("SA2", M->ED8_FORN + M->ED8_LOJA)' ,})

//Consulta padrão da manutenção de compras nacionais
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"       	 ,"XB_DESCSPA"      		,"XB_DESCENG"   			,"XB_CONTEM"       ,"XB_WCONTEM"})
o:TableData("SXB"  ,{ "ED4A"   , "5"     ,"02"    ,""         ,""                	 ,""                		,""             			,"ED4->ED4_SEQMI"  ,            })

//MPG - 26/03/2019
o:TableStruct("SX3",{"X3_CAMPO"	, "X3_RESERV"	,"X3_TITULO"	,"X3_PICTURE","X3_USADO"    , "X3_DESCRIC" },2)
o:TableData(  "SX3",{"ED1_RE"	, USO+TAM		,"DUE/ R.E."	, "@!"       ,TODOS_MODULOS , "Registro DUE/ R.E."        })
o:TableData(  "SX3",{"ED1_DTRE"	, USO+TAM		,"Data DUE/RE"	,            ,TODOS_MODULOS , "Data registro DUE/ R.E."   })
o:TableData(  "SX3",{"ED2_RE"	, USO+TAM		,"DUE/ R.E."	, "@!"       ,TODOS_MODULOS , "Registro DUE/ R.E."        })
o:TableData(  "SX3",{"ED2_DTRE"	, USO+TAM		,"Data DUE/RE"	,            ,TODOS_MODULOS , "Data registro DUE/ R.E."   })
o:TableData(  "SX3",{"ED9_RE"	, USO+TAM		,"DUE/ R.E."	, "@!"       ,TODOS_MODULOS , "Registro DUE/ R.E."        })
o:TableData(  "SX3",{"ED9_DTRE"	, USO+TAM		,"Data DUE/RE"	,            ,TODOS_MODULOS , "Data registro DUE/ R.E."   })
o:TableData(  "SX3",{"EDC_RE"	, USO+TAM		,"DUE/ R.E."	, "@!"       ,TODOS_MODULOS , "Registro DUE/ R.E."        })
o:TableData(  "SX3",{"EDD_DTRE"	, USO+TAM		,"Data DUE/RE"	,            ,TODOS_MODULOS , "Data registro DUE/ R.E."   })
o:TableData(  "SX3",{"EDE_RE"	, USO+TAM		,"DUE/ R.E."	, "@!"       ,TODOS_MODULOS , "Registro DUE/ R.E."        })
o:TableData(  "SX3",{"EDF_RE"	, USO+TAM		,"DUE/ R.E."	, "@!"       ,TODOS_MODULOS , "Registro DUE/ R.E."        })
o:TableData(  "SX3",{"EDH_RE"	, USO+TAM		,"DUE/ R.E."	, "@!"       ,TODOS_MODULOS , "Registro DUE/ R.E."        })

o:TableStruct("SX3",{"X3_CAMPO"   , "X3_USADO"    ,"X3_VISUAL" },2)
o:TableData("SX3"  ,{'ED9_CODEXP' , TODOS_MODULOS , "A"        })
o:TableData("SX3"  ,{'ED9_EXPLOJ' , TODOS_MODULOS , "A"        })
o:TableData("SX3"  ,{'ED9_PEDIDO' , TODOS_MODULOS , "A"        })
o:TableData("SX3"  ,{'ED9_EXPORT' , TODOS_MODULOS , "V"        })

Return NIL