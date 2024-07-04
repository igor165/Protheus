#Include 'Protheus.ch'
#Include "Average.ch"
#Include "TOPCONN.CH"
/*
Funcao                     : UPDEFF005
Parametros                 : Objeto de update PAI
Retorno                    : Nenhum
Objetivos                  : Atualização de dicionários e helps
Autor       			      : Lucas Raminelli - LRS
Data/Hora   			      : 03/07/2015 - 09:25
Data/Hora Ultima alteração : LRS - 03/07/2015 - 09:25
Revisao                    :
Obs.                       :
*/
Function UPDEFF005(o)
Local i
Local aCampos := {"EF3_DTOREV","EF1_TITFIN","EF3_TITFIN","EF3_NUMTIT","EF3_PARTIT",;
					"EF7_NATFIN","EF7_NUMERA","EF7_MOTBXI","EF7_MOTBXP","EF7_MOTBXJ"}
//LGS-06/08/2015
For i:=1 To Len(aCampos)
	o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_USADO"   },2)
	o:TableData  ("SX3",{aCampos[i],TODOS_MODULOS})
Next

//LGS - 08/04/2015
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"       ,"XB_DESCSPA"      ,"XB_DESCENG"   ,"XB_CONTEM"           ,"XB_WCONTEM"})
o:TableData("SXB"  ,{ "MOT"    , "1"     ,"01"    ,"RE"       ,"Motivos"         ,"Motivos"         ,"Reasons"      ,'EEQ'                 ,            })
o:TableData("SXB"  ,{ "MOT"    , "2"     ,"01"    ,"01"       ,""                ,""                ,""             ,"AF500MOTBAIXA()"     ,            })
o:TableData("SXB"  ,{ "MOT"    , "5"     ,"01"    ,""         ,""                ,""                ,""             ,"&(ReadVar())"        ,            })

o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_F3" },2)
o:TableData  ("SX3",{"EC6_MOTBX" ,"MOT"   })

Return Nil

Function UPDEFF006(o) //LGS-06/08/2015
Local i
Local aCampos := {"EF1_TITFIN","EF3_TITFIN","EF3_NUMTIT","EF3_PARTIT",;
					"EF7_NATFIN","EF7_NUMERA","EF7_MOTBXI","EF7_MOTBXP","EF7_MOTBXJ"}

For i:=1 To Len(aCampos)
	o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_USADO"   },2)
	o:TableData  ("SX3",{aCampos[i],TODOS_MODULOS})
Next

//LGS - 08/04/2015
o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"       ,"XB_DESCSPA"      ,"XB_DESCENG"   ,"XB_CONTEM"           ,"XB_WCONTEM"})
o:TableData("SXB"  ,{ "MOT"    , "1"     ,"01"    ,"RE"       ,"Motivos"         ,"Motivos"         ,"Reasons"      ,'EEQ'                 ,            })
o:TableData("SXB"  ,{ "MOT"    , "2"     ,"01"    ,"01"       ,""                ,""                ,""             ,"AF500MOTBAIXA()"     ,            })
o:TableData("SXB"  ,{ "MOT"    , "5"     ,"01"    ,""         ,""                ,""                ,""             ,"&(ReadVar())"        ,            })

o:TableStruct("SX3",{"X3_CAMPO"  ,"X3_F3" },2)
o:TableData  ("SX3",{"EC6_MOTBX" ,"MOT"   })

Return Nil

Function UPDEFF007(o)

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID"                          },2)
o:TableData  ("SX3",{"EF7_NATFIN" ,"If(AvFlags('SIGAEFF_SIGAFIN'),ExistCPO('SED',M->EF7_NATFIN),.T.)"     })
o:TableData  ("SX3",{"EF7_NUMERA" ,"ExistCPO('SX5','06'+M->EF7_NUMERA)"})

o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_CONTEM"         },1)
o:TableData("SXB"  ,{"SYT"     ,"3"      ,"01"    ,"01"       ,"01#AxInclui('SYT')"})

o:TableStruct("SX5",{"X5_FILIAL"   ,"X5_TABELA","X5_CHAVE","X5_DESCRI"})
o:TableData("SX5"  ,{xFilial("SX5"),"CG"       ,"05"      ,"FINIMP"   })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID"                                 },2)
o:TableData  ("SX3",{"EF1_TX_MOE" ,"Positivo() .and. EX400Valid('EF1_TX_MOE')"})
o:TableData  ("SX3",{"EF3_FORN"   ,"EX400Valid('EF3_FORN')"                   })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_ORDEM","X3_BROWSE" },2)
o:TableData  ("SX3",{"EF1_IMPORT" ,"11"      ,            })
o:TableData  ("SX3",{"EF1_LOJAIM" ,"12"      ,"N"         })
o:TableData  ("SX3",{"EF1_VM_IMP" ,"13"      ,            })

//MCF - 12/01/2015
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_TITULO"  },2)
o:TableData  ("SX3",{"EF7_NUMERA" ,"Numerário"  })

//THTS - 20/07/2017
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_F3"  },2)
o:TableData  ("SX3",{"EF1_MODPAG" ,"MODPAG"  })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_RELACAO"  },2)
o:TableData  ("SX3",{"EF1_MDPDES" ,"INIFFEX400()"  })

o:TableStruct("SXB",{"XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI"       	 ,"XB_DESCSPA"      		,"XB_DESCENG"   			,"XB_CONTEM"       ,"XB_WCONTEM"})
o:TableData("SXB"  ,{ "MODPAG" , "1"     ,"01"    ,"RE"       ,"Modalidade Pagamento","Modalidade Pagamento","Modalidade Pagamento" ,""                ,            })
o:TableData("SXB"  ,{ "MODPAG" , "2"     ,"01"    ,"01"       ,""                	 ,""                		,""             			,"XBFFEX400()"     ,            })
o:TableData("SXB"  ,{ "MODPAG" , "5"     ,"01"    ,""         ,""                	 ,""                		,""             			,"cRetorno"        ,            })

o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_USADO"   },2)
o:TableData  ("SX3",{"WB_TIPOPAG" ,TODOS_MODULOS})
//--
Return Nil

Function UPDEFF014(o)
AjustaEC6() // WHRS TE-4186 502077 / MTRADE-341 / MTRADE-467 - Fazer um ajusta para acertar a descrição dos eventos 600 e 630

//THTS - 30/05/2017 - TE-5623 / WCC 516234 / MTRADE-932 - Alterar banco no contrato de financiamento
o:TableStruct("SX7",{"X7_CAMPO"   ,"X7_SEQUENC" ,"X7_CONDIC"})
o:TableData	 ("SX7",{"EF3_BANC"   ,"001"        ,"Empty(M->EF3_AGEN)"})
o:TableData	 ("SX7",{"EF3_BANC"   ,"002"        ,"Empty(M->EF3_NCON)"})
   
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID" },2)
o:TableData  ("SX3",{"EF3_BANC"	  ,"Vazio() .Or. ExistCpo('SA6',M->EF3_BANC)"})
o:TableData  ("SX3",{"EF3_AGEN"   ,"Vazio() .Or. ExistCpo('SA6',M->EF3_BANC + M->EF3_AGEN)"})
o:TableData  ("SX3",{"EF3_NCON"   ,"Vazio() .Or. ExistCpo('SA6',M->EF3_BANC + M->EF3_AGEN + M->EF3_NCON)"})

//WHRS TE-6335 526188 / MTRADE-1243 - Erro NAO VALOR na alteração de contrato
o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                   ,"X6_DSCSPA","X6_DSCENG","X6_DESC1"                                    ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2","X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"})
o:TableData("SX6"  ,{"  "       ,"MV_EFF0010" ,"L"      ,"Define se ao alterar parcela do EFF o sistema",""         ,""         ,"deverá excluir e incluir o título novamente.",""          ,""          ,""        ,""          ,""          ,".F."       ,".F."       ,".F."       ,"S"        ,"N"      })

Return Nil

/*
Funcao     : UPDEFF016()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Ajuste dos dicionarios de dados
Autor      : Lucas Raminelli LRS
Data/Hora  : 29/05/2017
*/
Function UPDEFF016(o)

//LRS - 2905/2017
o:TableStruct("SX3",{"X3_CAMPO"   ,"X3_VALID"  },2)
o:TableData  ("SX3",{"YE_MOEDA  " ,"AvgExistCpo('SYF',M->YE_MOEDA) .AND. ExistChav('SYE',DTOS(M->YE_DATA)+M->YE_MOEDA) .AND. At140Val()"  })

Return Nil

/*
Funcao     : UPDEFF017()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Ajuste dos dicionarios de dados
Autor      : Miguel Prado Gontijo
Data/Hora  : 18/12/2017
*/
Function UPDEFF017(o)

//MPG - 18/12/2017
o:TableStruct("SX3"  ,{"X3_CAMPO"  ,"X3_USADO"  },2)
o:TableData  ("SX3"  ,{"EEQ_SEQBX" ,TODOS_AVG 	})

//LRS - 08/02/2018
o:TableStruct('SX3' ,{'X3_CAMPO'   ,'X3_BROWSE' },2)
o:TableData  ('SX3' ,{'EF3_NUMTIT' ,"S"         })

//EJA - 14/09/2018 - Campo específico para invoices de exportação com suporte à multifilial
o:TableStruct("SXB",{"XB_ALIAS" , "XB_TIPO" , "XB_SEQ"  , "XB_COLUNA", "XB_DESCRI"          , "XB_DESCSPA"  , "XB_DESCENG"  , "XB_CONTEM"       , "XB_WCONTEM" })
o:TableData  ("SXB",{ "EEQ_MF"  , "1"       , "01"      , "RE"       , "Invoice multifilial", ""            , ""            , "EEQ"             ,              })
o:TableData  ("SXB",{ "EEQ_MF"  , "2"       , "01"      , "01"       , ""                   , ""            , ""            , "F3EEQ()"         ,              })
o:TableData  ("SXB",{ "EEQ_MF"  , "5"       , "01"      , ""         , ""                   , ""            , ""            , "EEQ->EEQ_NRINVO" ,              })

//EJA - Trigger alterada para funcionamento correto do índice.
o:TableStruct("SX7",{"X7_CAMPO" , "X7_SEQUENC", "X7_REGRA"           , "X7_SEEK", "X7_ALIAS" , "X7_ORDEM", "X7_CHAVE", "X7_CONDIC"})
o:TableData	 ("SX7",{"EF3_BANC" ,"001"        , "BCOAGE(M->EF3_BANC)", "N"      , ""         , "0"		   , "" 		  , ""          })
o:TableData	 ("SX7",{"EF3_BANC" ,"002"        , "SA6->A6_NUMCON"     , "N"      , ""         , "0"       , "" 		  , ""          })

//THTS - 05/02/2019
o:TableStruct("SX3",{"X3_CAMPO"	,"X3_WHEN"              					},2)
o:TableData("SX3"  ,{"EF7_FINPRC","!(M->EF7_FINANC $ '01|02|03|04|05')"	})

//NFC - 12/02/2019 - Inclusão do parâmetro MV_EFF0009 que não entrou no dicionário de dados no pacote do chamado TREKL3 de 16/12/2014
o:TableStruct("SX6",{"X6_FIL"   ,"X6_VAR"     ,"X6_TIPO","X6_DESCRIC"                                         ,"X6_DSCSPA","X6_DSCENG","X6_DESC1"                                         ,"X6_DSCSPA1","X6_DSCENG1","X6_DESC2"                           ,"X6_DSCSPA2","X6_DSCENG2","X6_CONTEUD","X6_CONTSPA","X6_CONTENG","X6_PROPRI","X6_PYME"})
o:TableData("SX6"  ,{"  "       ,"MV_EFF0009" ,"L"      ,"Define se será gerado título integrado ao ERP Exter",""         ,""         ,"no(T) ou apenas contabilizados(F) eventos 180/190",""          ,""          ,"/670 pós-encerramento de contrato." ,""          ,""          ,".F."       ,".F."       ,".F."       ,"S"        ,"N"      })


Return Nil

/*
Funcao     : AjustaEC6()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Ajuste dos dicionarios de dados
Autor      : Wanderson Reliquias - WHRS
Data/Hora  : 25/01/2017 - 14:41
*/
Static Function AjustaEC6()
Local aOrd := SaveOrd("EC6")
Local aKeyEC6 := {}, i := 0

aAdd(aKeyEC6,{"EC6",avKey("FIEX03", "EC6_TPMODU"), avKey("600", "EC6_ID_CAM"), "TRANSF.ACC P/ACE", "Vinculação Invoice"})
aAdd(aKeyEC6,{"EC6",avKey("FIEX03", "EC6_TPMODU"), avKey("630", "EC6_ID_CAM"), "LIQUIDACäO PRINC ACE", "Liquidação Invoice"})
aAdd(aKeyEC6,{"EC6",avKey("FIEX04", "EC6_TPMODU"), avKey("600", "EC6_ID_CAM"), "TRANSF. ACC P/ ACE", "Vinculação Invoice"})
aAdd(aKeyEC6,{"EC6",avKey("FIEX04", "EC6_TPMODU"), avKey("630", "EC6_ID_CAM"), "LIQUIDACAO PRINC ACE", "Liquidação Invoice"})

EC6->(DbSetOrder(1))
For i := 1 To Len(aKeyEC6)
	If EC6->(DbSeek(xFilial(aKeyEC6[i][1])+aKeyEC6[i][2]+aKeyEC6[i][3]))
		if AllTrim(EC6->EC6_DESC) == aKeyEC6[i][4]
			RecLock("EC6",.F.)
			EC6->EC6_DESC := aKeyEC6[i][5]
			EC6->(MsUnlock())
		endIf
	EndIf
Next i

RestOrd(aOrd,.T.)
return