/******************************************************************************************
ROTINA     : EICDI158()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Rotina de geração de Notas Fiscais de Despesas dos processos
Autor      : Nilson César C. Filho
Data/Hora  : 04/08/2010
Revisão    : 23/12/2010 - Permitir acesso via Menu/ Permitir despesas de vários processos
*******************************************************************************************/
#INCLUDE "Average.ch"
#INCLUDE "eicdi158.ch"
#INCLUDE "TOPCONN.CH"

FUNCTION EICDI158()


  #xTranslate AVPic(<Cpo>) => AllTrim(X3Picture(<Cpo>))
  Local nLinha := 0, nColFim := 0
  Local aButtons1    := {}
  Local bOk1, bCancel1, lCloseOdlg1
  Local aOrdWD := aOrdWorkWD := aOrdWorkNF := {}
  Local cFiltroWD   := ""
  Local cKeyNF,cKeyWD,cKeyWD1
  Local cPergunta
  
  IF EasyGParam("MV_EASY",,"N") == "N"
     Help(" ",1,"AVG0005378")
     Return .F.
  ENDIF

  Private lCposNFDesp := (SWD->(FIELDPOS("WD_B1_COD")) # 0 .And. SWD->(FIELDPOS("WD_DOC")) # 0 .And. SWD->(FIELDPOS("WD_SERIE")) # 0;
                    .And. SWD->(FIELDPOS("WD_ESPECIE")) # 0 .And. SWD->(FIELDPOS("WD_EMISSAO")) # 0 .AND. SWD->(FIELDPOS("WD_B1_QTDE")) # 0;
                    .And. SWD->(FIELDPOS("WD_TIPONFD")) # 0)
  If !lCposNFDesp
     Help(" ",1,"AVG0005379")
     Return .F.
  EndIf

  Private cHawbNFD  := cImptNFD := ""
  Private oDlgTela1 := oDlgTela2 := NIL
  Private oMark1    := oMark2  :=  oMark3  := NIL
  Private cMarca1   := cMarca2 :=  cMarca3 := GetMark()
  Private lInverte1 := lInverte2 := lInverte3 := NIL
  Private cDlgTit1  := STR0001 //STR0001 "ITENS DAS NOTAS FISCAIS"
  Private cDlgTit2  := STR0002 //STR0002 "NOTAS FISCAIS"
  Private aAltura   := {oMainWnd:nTop+125,  oMainWnd:nLeft+5    } //{0,0}
  Private aLargura  := {oMainWnd:nBottom-60,oMainWnd:nRight - 10} //{700,1250}
  Private cCancelMsg:= cOKMsg := ""
  Private aSelCposWD:= {}
  Private aSelCpsWD1:= {}
  Private aSelCposNF:= {}
  Private aWorkNF   := {}
  Private aWorkWD   := {}
  Private aWorkWD1  := {}
  Private aOrdAll_NF:= {}
  Private cFileWork1:= cFileWork2:= cFileWork3 := ""
  Private nRec_SWD  := 0
  Private cKeyNF_SWD:= cKeyNF_QRY := ""
  Private aHeaderNFD := {}
  Private aCamposNFD := {}
  Private cTipo_NFD,dEmis_NFD
  Private cNF_NFD:=cSerie_NFD:=cForn_NFD:=cLoja_NFD:= ""
  Private cProd_NFD,cEspe_NFD,nQtde_NFD
  Private lGerou_NFD := .F.
  Private lLimpaNF_C := lLimpaNF_D := .F.
  Private dDtInic := dDtFinal := AVCTOD("  /  /  ")
  Private cProcesso := cDespesa := cDespesaAt := cFornece := "", nAgrupa:=1
  Private cFilialSWD := xFilial("SWD")
  Private nLenSDoc := SerieNfId("SWD",6,"WD_SERIE") //AAF 12/02/2015 - Tratamento da nova chave única.
  //aHeaderNFD := aClone(aHeader) := {}
  //aCamposNFD := aClone(aCampos) := {}
  //aHeader := {}
  //aCampos := {}

  IF EasyGParam("MV_EIC_EAI",,.F.) //IGOR CHIBA REQ 5.8 14/07/14
     MSGALERT(STR0070) //"Funcionalidade não disponível para este cenário de negócio."
     RETURN
  ENDIF

  BEGIN SEQUENCE
   
   cPergunta := if(SX1->(DbSeek('DI158PERG')),'DI158PERG','EICDI158')
   While .T.
      If Pergunte(cPergunta,.T.)
         IF EMPTY(MV_PAR01) .And. EMPTY(MV_PAR02) .And. EMPTY(MV_PAR03) ;
            .And. EMPTY(MV_PAR04) .And. EMPTY(MV_PAR05) .And. EMPTY(MV_PAR06)
            MSGALert(STR0003) //STR0003 "Informe pelo ao menos uma condição de Filtro !"
         ELSE
            EXIT
         ENDIF
      Else
        BREAK
      EndIf
   EndDo

   IF(!EMPTY(MV_PAR07), nAgrupa    := MV_PAR07 ,)  //Agrupa despesa por fornecedor:

   aAdd(aWorkNF,{"NF_FLAG"   ,"C"                  ,2                    ,0                    })
   aAdd(aWorkNF,{"NF_FILIAL" ,AVSX3("WD_FILIAL",2) ,AVSX3("WD_FILIAL",3) ,AVSX3("WD_FILIAL",4)} )
   aAdd(aWorkNF,{"NF_DOC"    ,AVSX3("WD_DOC",2)    ,AVSX3("WD_DOC",3)    ,AVSX3("WD_DOC",4)}    )
   aAdd(aWorkNF,{"NF_SERIE"  ,AVSX3("WD_SERIE",2)  ,AVSX3("WD_SERIE",3)  ,AVSX3("WD_SERIE",4)}  )
   aAdd(aWorkNF,{"NF_FORN"   ,AVSX3("WD_FORN",2)   ,AVSX3("WD_FORN",3)   ,AVSX3("WD_FORN",4)}   )

   aAdd(aWorkNF,{"NF_LOJA"   ,AVSX3("WD_LOJA",2)   ,AVSX3("WD_LOJA",3)   ,AVSX3("WD_LOJA",4)}   )
   aAdd(aWorkNF,{"NF_ESPECIE",AVSX3("WD_ESPECIE",2),AVSX3("WD_ESPECIE",3),AVSX3("WD_ESPECIE",4)})
   aAdd(aWorkNF,{"NF_TIPONFD",AVSX3("WD_TIPONFD",2),AVSX3("WD_TIPONFD",3),AVSX3("WD_TIPONFD",4)})
   aAdd(aWorkNF,{"NF_EMISSAO",AVSX3("WD_EMISSAO",2),AVSX3("WD_EMISSAO",3),AVSX3("WD_EMISSAO",4)})
   aAdd(aWorkNF,{"NF_VALOR_R",AVSX3("WD_VALOR_R",2),AVSX3("WD_VALOR_R",3),AVSX3("WD_VALOR_R",4)})
   If nAgrupa == 2
      aAdd(aWorkNF,{"NF_DESPESA",AVSX3("WD_DESPESA",2),AVSX3("WD_DESPESA",3),AVSX3("WD_DESPESA",4)})
   EndIf   
   aAdd(aWorkNF,{"NF_NOTAGER","C"                  ,1                    ,0                    })

   aAdd(aWorkWD,{"WD_FLAG"   ,"C"                  ,2                    ,0                    })
   aAdd(aWorkWD,{"WD_FILIAL" ,AVSX3("WD_FILIAL",2) ,AVSX3("WD_FILIAL",3) ,AVSX3("WD_FILIAL",4)} )
   aAdd(aWorkWD,{"WD_HAWB"   ,AVSX3("WD_HAWB",2)   ,AVSX3("WD_HAWB",3)   ,AVSX3("WD_HAWB",4)}   )
   aAdd(aWorkWD,{"WD_DOC"    ,AVSX3("WD_DOC",2)    ,AVSX3("WD_DOC",3)    ,AVSX3("WD_DOC",4)}    )
   aAdd(aWorkWD,{"WD_SERIE"  ,AVSX3("WD_SERIE",2)  ,AVSX3("WD_SERIE",3)  ,AVSX3("WD_SERIE",4)}  )
   aAdd(aWorkWD,{"WD_FORN"   ,AVSX3("WD_FORN",2)   ,AVSX3("WD_FORN",3)   ,AVSX3("WD_FORN",4)}   )
   aAdd(aWorkWD,{"WD_LOJA"   ,AVSX3("WD_LOJA",2)   ,AVSX3("WD_LOJA",3)   ,AVSX3("WD_LOJA",4)}   )
   aAdd(aWorkWD,{"WD_TIPONFD",AVSX3("WD_TIPONFD",2),AVSX3("WD_TIPONFD",3),AVSX3("WD_TIPONFD",4)})
   aAdd(aWorkWD,{"WD_ESPECIE",AVSX3("WD_ESPECIE",2),AVSX3("WD_ESPECIE",3),AVSX3("WD_ESPECIE",4)})
   aAdd(aWorkWD,{"WD_EMISSAO",AVSX3("WD_EMISSAO",2),AVSX3("WD_EMISSAO",3),AVSX3("WD_EMISSAO",4)})
   aAdd(aWorkWD,{"WD_VALOR_R",AVSX3("WD_VALOR_R",2),AVSX3("WD_VALOR_R",3),AVSX3("WD_VALOR_R",4)})
   aAdd(aWorkWD,{"WD_DESPESA",AVSX3("WD_DESPESA",2),AVSX3("WD_DESPESA",3),AVSX3("WD_DESPESA",4)})
   aAdd(aWorkWD,{"WD_DESCDES",AVSX3("WD_DESCDES",2),AVSX3("WD_DESCDES",3),AVSX3("WD_DESCDES",4)})
   aAdd(aWorkWD,{"WD_DES_ADI",AVSX3("WD_DES_ADI",2),AVSX3("WD_DES_ADI",3),AVSX3("WD_DES_ADI",4)})
   aAdd(aWorkWD,{"WD_FOB_R"  ,AVSX3("WD_VALOR_R",2),AVSX3("WD_VALOR_R",3),AVSX3("WD_VALOR_R",4)})
   aAdd(aWorkWD,{"WD_BASEADI",AVSX3("WD_BASEADI",2),AVSX3("WD_BASEADI",3),AVSX3("WD_BASEADI",4)})
   aAdd(aWorkWD,{"WD_GERFIN" ,AVSX3("WD_GERFIN" ,2),AVSX3("WD_GERFIN" ,3),AVSX3("WD_GERFIN" ,4)})
   aAdd(aWorkWD,{"WD_NF_COMP",AVSX3("WD_NF_COMP",2),AVSX3("WD_NF_COMP",3),AVSX3("WD_NF_COMP",4)})
   aAdd(aWorkWD,{"WD_SE_NFC" ,AVSX3("WD_SE_NFC",2) ,AVSX3("WD_SE_NFC",3) ,AVSX3("WD_SE_NFC",4)} )
   aAdd(aWorkWD,{"WD_DOCTO"  ,AVSX3("WD_DOCTO",2)  ,AVSX3("WD_DOCTO",3)  ,AVSX3("WD_DOCTO",4)}  )
   aAdd(aWorkWD,{"WD_DA"     ,AVSX3("WD_DA",2)     ,AVSX3("WD_DA",3)     ,AVSX3("WD_DA",4)}     )
   aAdd(aWorkWD,{"WD_B1_COD" ,AVSX3("WD_B1_COD",2) ,AVSX3("WD_B1_COD",3) ,AVSX3("WD_B1_COD",4)} )
   aAdd(aWorkWD,{"WD_B1_PRC" ,AVSX3("WD_VALOR_R",2),AVSX3("WD_VALOR_R",3),AVSX3("WD_VALOR_R",4)})
   aAdd(aWorkWD,{"WD_B1_QTDE",AVSX3("WD_B1_QTDE",2),AVSX3("WD_B1_QTDE",3),AVSX3("WD_B1_QTDE",4)})
   aAdd(aWorkWD,{"WD_QTDE"   ,"N"                  ,12                   ,2                    })
   aAdd(aWorkWD,{"WD_NOTAGER","C"                  ,1                    ,0                    })
   aAdd(aWorkWD,{"WD_RECNO"  ,"N"                  ,10                   ,0                    })

   aAdd(aWorkWD1,{"WD1_FLAG"   ,"C"                  ,2                    ,0                    })
   aAdd(aWorkWD1,{"WD1_FILIAL" ,AVSX3("WD_FILIAL",2) ,AVSX3("WD_FILIAL",3) ,AVSX3("WD_FILIAL",4)} )
   aAdd(aWorkWD1,{"WD1_HAWB"   ,AVSX3("WD_HAWB",2)   ,AVSX3("WD_HAWB",3)   ,AVSX3("WD_HAWB",4)}   )
   aAdd(aWorkWD1,{"WD1_DESPE"  ,AVSX3("WD_DESPESA",2),AVSX3("WD_DESPESA",3),AVSX3("WD_DESPESA",4)})
   aAdd(aWorkWD1,{"WD1_DESC"   ,AVSX3("WD_DESCDES",2),AVSX3("WD_DESCDES",3),AVSX3("WD_DESCDES",4)})
   aAdd(aWorkWD1,{"WD1_DOC"    ,AVSX3("WD_DOC",2)    ,AVSX3("WD_DOC",3)    ,AVSX3("WD_DOC",4)}    )
   aAdd(aWorkWD1,{"WD1_SERIE"  ,AVSX3("WD_SERIE",2)  ,AVSX3("WD_SERIE",3)  ,AVSX3("WD_SERIE",4)}  )
   aAdd(aWorkWD1,{"WD1_ESPEC"  ,AVSX3("WD_ESPECIE",2),AVSX3("WD_ESPECIE",3),AVSX3("WD_ESPECIE",4)})
   aAdd(aWorkWD1,{"WD1_FORN"   ,AVSX3("WD_FORN",2)   ,AVSX3("WD_FORN",3)   ,AVSX3("WD_FORN",4)}   )
   aAdd(aWorkWD1,{"WD1_LOJA"   ,AVSX3("WD_LOJA",2)   ,AVSX3("WD_LOJA",3)   ,AVSX3("WD_LOJA",4)}   )
   aAdd(aWorkWD1,{"WD1_TIPONF" ,AVSX3("WD_TIPONFD",2),AVSX3("WD_TIPONFD",3),AVSX3("WD_TIPONFD",4)})
   aAdd(aWorkWD1,{"WD1_EMISS"  ,AVSX3("WD_EMISSAO",2),AVSX3("WD_EMISSAO",3),AVSX3("WD_EMISSAO",4)})
   aAdd(aWorkWD1,{"WD1_B1_COD" ,AVSX3("WD_B1_COD",2) ,AVSX3("WD_B1_COD",3) ,AVSX3("WD_B1_COD",4)} )
   aAdd(aWorkWD1,{"WD1_B1_QTD" ,AVSX3("WD_B1_QTDE",2),AVSX3("WD_B1_QTDE",3),AVSX3("WD_B1_QTDE",4)})
   aAdd(aWorkWD1,{"WD1_QTDE"   ,"N"                  ,12                   ,2                    })
   aAdd(aWorkWD1,{"WD1_VALOR"  ,AVSX3("WD_VALOR_R",2),AVSX3("WD_VALOR_R",3),AVSX3("WD_VALOR_R",4)})
   aAdd(aWorkWD1,{"WD1_RECNO"  ,"N"                  ,10                   ,0                    })

   /*aAdd(aWorkWD1,{"WD1_DES_AD" ,AVSX3("WD_DES_ADI",2),AVSX3("WD_DES_ADI",3),AVSX3("WD_DES_ADI",4)})
   aAdd(aWorkWD1,{"WD1_FOB_R"  ,AVSX3("WD_VALOR_R",2),AVSX3("WD_VALOR_R",3),AVSX3("WD_VALOR_R",4)})
   aAdd(aWorkWD1,{"WD1_BASEAD" ,AVSX3("WD_BASEADI",2),AVSX3("WD_BASEADI",3),AVSX3("WD_BASEADI",4)})
   aAdd(aWorkWD1,{"WD1_GERFIN" ,AVSX3("WD_GERFIN" ,2),AVSX3("WD_GERFIN" ,3),AVSX3("WD_GERFIN" ,4)})
   aAdd(aWorkWD1,{"WD1_NF_COM" ,AVSX3("WD_NF_COMP",2),AVSX3("WD_NF_COMP",3),AVSX3("WD_NF_COMP",4)})
   aAdd(aWorkWD1,{"WD1_SE_NFC" ,AVSX3("WD_SE_NFC",2) ,AVSX3("WD_SE_NFC",3) ,AVSX3("WD_SE_NFC",4)} )
   aAdd(aWorkWD1,{"WD1_DOCTO"  ,AVSX3("WD_DOCTO",2)  ,AVSX3("WD_DOCTO",3)  ,AVSX3("WD_DOCTO",4)}  )
   aAdd(aWorkWD1,{"WD1_DA"     ,AVSX3("WD_DA",2)     ,AVSX3("WD_DA",3)     ,AVSX3("WD_DA",4)}     )*/
 
   If !(Select("WorkWD") <> 0)
      cFileWork1:=E_CriaTrab(,aWorkWD,"WorkWD")
   Else
      WorkWD->(avzap())
   EndIf

   If !(Select("WorkWD1") <> 0)
      cFileWork2:=E_CriaTrab(,aWorkWD1,"WorkWD1")
   Else
      WorkWD1->(avzap())
   EndIf

   If !(Select("WorkNF") <> 0)
      cFileWork3:=E_CriaTrab(,aWorkNF,"WorkNF")
   Else
      WorkNF->(avzap())
   EndIf

   aAdd(aSelCposNF,{"NF_FLAG"   ,"","  "                 })
   aAdd(aSelCposNF,{"NF_DOC"    ,"",AVSX3("WD_DOC",5)    })
   aAdd(aSelCposNF,{"NF_SERIE"  ,"",AVSX3("WD_SERIE",5)  })
   aAdd(aSelCposNF,{"NF_FORN"   ,"",AVSX3("WD_FORN",5)   })
   aAdd(aSelCposNF,{"NF_LOJA"   ,"",AVSX3("WD_LOJA",5)   })
   aAdd(aSelCposNF,{"NF_ESPECIE","",AVSX3("WD_ESPECIE",5)})
   aAdd(aSelCposNF,{"NF_TIPONFD","",AVSX3("WD_TIPONFD",5)})
   aAdd(aSelCposNF,{"NF_EMISSAO","",AVSX3("WD_EMISSAO",5)})
   If nAgrupa == 2
      aAdd(aSelCposNF,{"NF_DESPESA","",AVSX3("WD_DESPESA",5)})   
   EndIf 
   aAdd(aSelCposNF,{"NF_VALOR_R","",AVSX3("WD_VALOR_R",5),AVSX3("WD_VALOR_R",6)})

   aAdd(aSelCposWD,{"WD_HAWB",""   ,AVSX3("WD_HAWB",5)   })
   aAdd(aSelCposWD,{"WD_DESPESA","",AVSX3("WD_DESPESA",5)})
   aAdd(aSelCposWD,{"WD_DESCDES","",AVSX3("WD_DESCDES",5)})
   aAdd(aSelCposWD,{"WD_B1_QTDE","",AVSX3("WD_B1_QTDE",5)})
   aAdd(aSelCposWD,{"WD_VALOR_R","",AVSX3("WD_VALOR_R",5),AVSX3("WD_VALOR_R",6)})
   aAdd(aSelCposWD,{"WD_FORN"   ,"",AVSX3("WD_FORN",5)   })
   aAdd(aSelCposWD,{"WD_LOJA"   ,"",AVSX3("WD_LOJA",5)   })
   aAdd(aSelCposWD,{"WD_NOTAGER","","Possui NF?"         })
   aAdd(aSelCposWD,{"WD_DOC"    ,"",AVSX3("WD_DOC",5)    })
   aAdd(aSelCposWD,{"WD_SERIE"  ,"",AVSX3("WD_SERIE",5)  })
   aAdd(aSelCposWD,{"WD_ESPECIE","",AVSX3("WD_ESPECIE",5)})
   aAdd(aSelCposWD,{"WD_TIPONFD","",AVSX3("WD_TIPONFD",5)})
   aAdd(aSelCposWD,{"WD_EMISSAO","",AVSX3("WD_EMISSAO",5)})
   aAdd(aSelCposWD,{"WD_B1_COD" ,"",AVSX3("WD_B1_COD",5) })
   aAdd(aSelCposWD,{"WD_DES_ADI","",AVSX3("WD_DES_ADI",5)})
   aAdd(aSelCposWD,{{|| If(WorkWD->WD_BASEADI $ cSim,"Sim","Não")},,AVSX3("WD_BASEADI",5)})
   aAdd(aSelCposWD,{{|| If(WorkWD->WD_GERFIN $ cSim,"Sim","Não")},,AVSX3("WD_GERFIN",5)})
   aAdd(aSelCposWD,{"WD_NF_COMP","",AVSX3("WD_NF_COMP",5)})
   aAdd(aSelCposWD,{"WD_SE_NFC" ,"",AVSX3("WD_SE_NFC",5) })
   aAdd(aSelCposWD,{"WD_DOCTO"  ,"",AVSX3("WD_DOCTO",5)  })
   aAdd(aSelCposWD,{{|| If(WorkWD->WD_DA $ cSim,"Sim","Não")},,AVSX3("WD_DA",5)})

   aAdd(aSelCpsWD1,{"WD1_HAWB"  ,"",AVSX3("WD_HAWB",5)   })
   aAdd(aSelCpsWD1,{"WD1_DESPE" ,"",AVSX3("WD_DESPESA",5)})
   aAdd(aSelCpsWD1,{"WD1_DESC"  ,"",AVSX3("WD_DESCDES",5)})
   aAdd(aSelCpsWD1,{"WD1_DOC"   ,"",AVSX3("WD_DOC",5)    })
   aAdd(aSelCpsWD1,{"WD1_SERIE" ,"",AVSX3("WD_SERIE",5)  })
   aAdd(aSelCpsWD1,{"WD1_ESPEC" ,"",AVSX3("WD_ESPECIE",5)})
   aAdd(aSelCpsWD1,{"WD1_FORN"  ,"",AVSX3("WD_FORN",5)   })
   aAdd(aSelCpsWD1,{"WD1_LOJA"  ,"",AVSX3("WD_LOJA",5)   })
   aAdd(aSelCpsWD1,{"WD1_TIPONF","",AVSX3("WD_TIPONFD",5)})
   aAdd(aSelCpsWD1,{"WD1_EMISS" ,"",AVSX3("WD_EMISSAO",5)})
   aAdd(aSelCpsWD1,{"WD1_B1_COD","",AVSX3("WD_B1_COD",5) })
   aAdd(aSelCpsWD1,{"WD1_B1_QTD","",AVSX3("WD_B1_QTDE",5)})
   aAdd(aSelCpsWD1,{"WD1_VALOR" ,"",AVSX3("WD_VALOR_R",5),AVSX3("WD_VALOR_R",6)})         //NCF - 30/06/2011 - Adicionada a picture para o campo
  /* aAdd(aSelCposWD1,{"WD1_DES_AD","",AVSX3("WD_DES_ADI",5)})
   aAdd(aSelCposWD1,{"WD1_BASEAD","",AVSX3("WD_BASEADI",5)})
   aAdd(aSelCposWD1,{"WD1_GERFIN","",AVSX3("WD_GERFIN",5) })
   aAdd(aSelCposWD1,{"WD1_NF_COM","",AVSX3("WD_NF_COMP",5)})
   aAdd(aSelCposWD1,{"WD1_SE_NFC","",AVSX3("WD_SE_NFC",5) })
   aAdd(aSelCposWD1,{"WD1_DOCTO" ,"",AVSX3("WD_DOCTO",5)  })
   aAdd(aSelCposWD1,{"WD1_DA"    ,"",AVSX3("WD_DA",5)     })*/

   FileWkNF1:= E_Create(,.F.)
   
   cKeyNF := 'NF_FILIAL+NF_DOC+NF_SERIE+NF_FORN+NF_LOJA+NF_ESPECIE'
   cKeyWD := "WD_FILIAL+WD_DOC+WD_SERIE+WD_FORN+WD_LOJA+WD_ESPECIE" //na linha 870 foi comentado o campo tiponfd
   cKeyWD1 := "WD1_FILIAL+WD1_DOC+WD1_SERIE+WD1_FORN+WD1_LOJA+WD1_ESPEC" //retirado o campo wd1_tiponf na linha 1304
   If nAgrupa == 2
      cKeyNF += '+NF_DESPESA'
      cKeyWD += '+WD_DESPESA'
      cKeyWD1 += '+WD1_DESPE' 
   EndIf
   IndRegua("WorkNF",FileWkNF1+TEOrdBagExt(),cKeyNF) 

   SET INDEX TO (FileWkNF1+TEOrdBagExt())

   FileWkWD1:= E_Create(,.F.)
   IndRegua("WorkWD",FileWkWD1+TEOrdBagExt(),"WD_FILIAL+WD_FORN+WD_LOJA+DTOS(WD_EMISSAO)")

   FileWkWD2:= E_Create(,.F.)
   IndRegua("WorkWD",FileWkWD2+TEOrdBagExt(),"WD_FILIAL+WD_FORN+WD_LOJA+WD_ESPECIE+DTOS(WD_EMISSAO)")

   FileWkWD3:= E_Create(,.F.)
   IndRegua("WorkWD",FileWkWD3+TEOrdBagExt(),"WD_FILIAL+WD_DOC+WD_SERIE+WD_ESPECIE+DTOS(WD_EMISSAO)")

   FileWkWD4:= E_Create(,.F.)
   IndRegua("WorkWD",FileWkWD4+TEOrdBagExt(),cKeyWD)

   SET INDEX TO (FileWkWD1+TEOrdBagExt()),(FileWkWD2+TEOrdBagExt()),(FileWkWD3+TEOrdBagExt()),(FileWkWD4+TEOrdBagExt())

   FileWkWD9:= E_Create(,.F.)
   IndRegua("WorkWD1",FileWkWD9+TEOrdBagExt(),cKeyWD1) 

   SET INDEX TO (FileWkWD9+TEOrdBagExt())

   aOrdAll_NF := SaveOrd({"SB1","SA2","SF1","SD1","SWD","SYB"})
   cHawbNFD := SW6->W6_HAWB
   cImptNFD := SW6->W6_IMPORT
   aOrdWD := SaveOrd({"SWD"})
   SWD->(DBGOTOP())
   SWD->(DBSEEK(xFilial("SWD")+cHawbNFD))
   WorkNF->(DbClearFilter())

   IF(!EMPTY(MV_PAR01), cProcesso  := MV_PAR01 ,)  //Processo
   IF(!EMPTY(MV_PAR02), dDtInic    := MV_PAR02 ,)  //De:
   IF(!EMPTY(MV_PAR03), dDtFinal   := MV_PAR03 ,)  //Ate:
   IF(!EMPTY(MV_PAR04), cDespesa   := MV_PAR04 ,)  //Despesa
   IF(!EMPTY(MV_PAR05), cDespesaAt := MV_PAR05 ,)  //Desp. Ate:
   IF(!EMPTY(MV_PAR06), cFornece   := MV_PAR06 ,)  //Fornecedor:

   
      Private cQuery := cQuery2 := ""
      Private cCond  := cCond2  := ""

   DI158GetDados()
      

   aAdd(aButtons1, {"IC_17"    ,{|| DI158NFDItem()   ,oDlgTela1, oMark1:oBrowse:Refresh() }, STR0004 }) //STR0004 "Alt. Item"
   aAdd(aButtons1, {"SDURECALL",{|| DI158NFDAltera(1),oDlgTela1, oMark1:oBrowse:Refresh() }, STR0005 }) //STR0005 "Gerar NFs"
   aAdd(aButtons1, {"SDUAPPEND",{|| DI158NFDAltera(2),oDlgTela1, oMark1:oBrowse:Refresh() }, STR0006}) //STR0006 "Estor. NFs"
//   aAdd(aButtons1, {"FILTRO1"  ,{|| DI158NFDFil()    ,oDlgTela1 }, "Itens s/NF"})

   cOkMsg     := STR0007  //STR0007 "Deseja prosseguir com a geração?"
   cCancelMsg := STR0008+CHR(13)+CHR(10)+STR0009 //STR0008 "Todos os dados não salvos serão perdidos!" //STR0009 "Deseja mesmo sair ?"
   bOk1     := {|| Iif((lCloseDlg1 := MsgYesNo(cOkMsg,STR0010 )),lCloseDlg1 := .T., lCloseDlg1 := .F. ),Iif(lCloseDlg1,DI158NFDAltera(1),oMark1:oBrowse:Refresh())} //STR0010	 "Aviso"
   bCancel1 := {|| IF(!lGerou_NFD , IF(MsgYesNo(cCancelMsg,STR0011),(oMark1:oBrowse:Refresh(), OdlgTela1:End()),(oMark1:oBrowse:Refresh())) , OdlgTela1:End()) }  //STR0011 := "Atenção"
   WorkWD->(DbSetOrder(4))
   WorkWD->(DbCommit())
   WorkWD->(DbGoTop())
   Define MSDIALOG oDlgTela1 From aAltura[1],aAltura[2] To aLargura[1],aLargura[2] Title cDlgTit1 PIXEL

      nColFim      := (oDlgTela1:nClientWidth-4)
      nLinha       := (oDlgTela1:nClientHeight-4)

      oMark1:= MsSelect():New("WorkWD","WD_FLAG",,aSelCposWD,@lInverte1,@cMarca1,{30,1,nLinha,nColFim},,,)
      oMark1:bAval:={|x| x:= GetFocus(),DI158NFDItem(), SetFocus(x), oMark1:oBrowse:Refresh()}
      oDlgTela1:lMaximized:=.T.
      WorkWD->(dbGoTop())
      oMark1:oBrowse:Refresh()
      oMark1:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT
   ACTIVATE MSDIALOG oDlgTela1 CENTERED ON INIT (EnchoiceBar(oDlgTela1,bOk1,bCancel1,,aButtons1),oMark1:oBrowse:Refresh())  //BCO 12/12/11 - Tratamento para acesso via ActiveX alterando o align para antes do INIT

   RestOrd(aOrdAll_NF)
   aHeader := aClone(aHeaderNFD) := {}
   aCampos := aClone(aCamposNFD) := {}

   //MFR 22/11/2019 OSSME-4018
   WorkWD->(E_EraseArq(cFileWork1))
   WorkWD1->(E_EraseArq(cFileWork2))
   WorkNF->(E_EraseArq(cFileWork3))  

END SEQUENCE



Return .T.

/**************************************************
Funcao     : DI158NFDAltera()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Permitir alteração dos itens da nota
Autor      : Nilson César C. Filho
Data/Hora  : 09/08/2010
***************************************************/
FUNCTION DI158NFDAltera(nOpca)

Local aButtons2 := {}
Local bOk2, bCancel2, lCloseOdlg2
Local nOrdWKWD_I := WorkWD->(INDEXORD())
Local cFilNFD_NG := 'WorkNF->NF_NOTAGER # "S" .AND. !EMPTY(WorkNF->NF_FORN) .AND. !EMPTY(WorkNF->NF_LOJA) .AND. !EMPTY(WorkNF->NF_ESPECIE)'
Local cFilNFD_G  := 'WorkNF->NF_NOTAGER == "S"'
Local cFilNota   := IF(nOpca == 1,cFilNFD_NG,cFilNFD_G)

IF nOpca == 1
   aAdd(aButtons2, {"SDUREPL"  ,{|| DI158NFDNota()  ,oDlgTela2, oMark2:oBrowse:refresh() }, STR0012  }) //STR0012 "Altera Nota"
   //MFR 14/05/2019 OSSME-2808
   aAdd(aButtons2, {"SDURECALL",{|| IF(DI158NFDVal("cOK_NFs",nOpca),IF(MsgYesNo(STR0013),( Processa({||DI158NFDGera(1),oMark2:oBrowse:refresh()},STR0014,STR0015,.T.),oDlgTela2:End() ),( oMark2:oBrowse:Refresh() )),oMark2:oBrowse:Refresh()),oDlgTela2},STR0016}) //STR0013 "Deseja Concluir a geração ?" //STR0014 "NOTA FISCAL" //STR0015 "Geração de Nota" //STR0016 "Gerar"
ELSE
   //MFR 14/05/2019 OSSME-2808
   aAdd(aButtons2, {"SDUAPPEND",{|| IF(DI158NFDVal("cOK_NFs",nOpca),IF(MsgYesNo(STR0017),( Processa({||DI158NFDGera(2), oMark2:oBrowse:refresh()},STR0014,STR0018,.T.),oDlgTela2:End() ),( oMark2:oBrowse:Refresh() )),oMark2:oBrowse:Refresh()),oDlgTela2}, STR0019  }) //STR0017 "Deseja concluir o estorno ?" //STR0014 "NOTA FISCAL" //STR0018 "Estorno de Nota" //STR0019 "Estornar"
   aAdd(aButtons2, {"SDUSEEK"  ,{|| DI158TelaDsp()    ,oDlgTela2, oMark2:oBrowse:refresh() }, STR0020})  //STR0020 "Desp.Assoc"
ENDIF

bOk2     := IF (nOpca == 1,aButtons2[2][2],aButtons2[1][2]) //{|| oMark2:oBrowse:Refresh(),oDlgTela2:End()}
bCancel2 := {|| oMark2:oBrowse:Refresh(),OdlgTela2:End()}
WorkWD->(DbClearFilter())

   Define MSDIALOG oDlgTela2 From aAltura[1],aAltura[2] To aLargura[1],aLargura[2] Title cDlgTit2+IF(nOpca == 1,STR0021,STR0022 ) PIXEL  //STR0021 " - Geração" //STR0022 " - Estorno"

      nColFim      := (oDlgTela2:nClientWidth-4)/2
      nLinha       := (oDlgTela2:nClientHeight-4)/2

      oMark2:= MsSelect():New("WorkNF", "NF_FLAG" ,,aSelCposNF ,@lInverte2,@cMarca2,{30,1,nLinha/2,nColFim},,,)
      oMark2:bAval:= {|x| x:= GetFocus(), DI158NFDNota() , SetFocus(x) }
      oDlgTela2:lMaximized:=.T.
      SET FILTER TO &cFilNota
      WorkNF->(DbGoTop())
      oMark2:oBrowse:refresh()
	  oMark2:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT

   ACTIVATE MSDIALOG oDlgTela2 CENTERED ON INIT (EnchoiceBar(oDlgTela2,bOk2,bCancel2,,aButtons2))

WorkWD->(DbSetOrder(nOrdWKWD_I))

Return .T.


/****************************************************
Funcao     : DI158NFDItem()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Permitir alteração dos itens da nota
Autor      : Nilson César C. Filho
Data/Hora  : 09/08/2010
*****************************************************/
FUNCTION DI158NFDItem()

Local oDlgSel,oEspecie,oProduto,oQuantidade,oBtn1,oBtn2
Local nOk := 0
Local nRegItem := 0
Local lAlterouIT
Local cSeekNF,cSeekNF2

cProd_NFD  := WorkWD->WD_B1_COD
nQtde_NFD  := WorkWD->WD_B1_QTDE
cEspe_NFD  := WorkWD->WD_ESPECIE
cForn_NFD  := WorkWD->WD_FORN
cLoja_NFD  := WorkWD->WD_LOJA
dEmis_NFD  := WorkWD->WD_EMISSAO

IF WorkWD->WD_NOTAGER == "N"

   DEFINE MSDIALOG oDlgSel TITLE STR0023 From 50,46 To 73,88 OF oMainWnd//STR0023 "Itens da Nota"

   @ 01,08 TO 37,160 LABEL STR0024 OF oDlgSel PIXEL //STR0024 'DESPESA'
   @ 10,10 SAY STR0025 OF oDlgSel PIXEL  //STR0025 "Processo: "
   @ 18,10 SAY STR0026 OF oDlgSel PIXEL  //STR0026 "Despesa:  "
   @ 26,10 SAY STR0027 OF oDlgSel PIXEL //STR0027 "Valor(R$):"
   @ 10,45 SAY WorkWD->WD_HAWB OF oDlgSel PIXEL
   @ 18,45 SAY WorkWD->WD_DESPESA+" - "+WorkWD->WD_DESCDES OF oDlgSel PIXEL
   @ 26,45 SAY STR(WorkWD->WD_VALOR_R,AVSX3("WD_VALOR_R",3),AVSX3("WD_VALOR_R",4)) OF oDlgSel PIXEL

   @ 40,08 TO 83,160 LABEL 'ITEM' OF oDlgSel PIXEL
   @ 50,10 SAY AVSX3("WD_B1_COD" ,5) OF oDlgSel PIXEL
   @ 63,10 SAY AVSX3("WD_B1_QTDE",5) OF oDlgSel PIXEL

   @ 50,45 MSGET oProduto VAR cProd_NFD PICT AVPic("B1_COD")     F3 "SB1" VALID DI158NFDVal("cProd_NFD") SIZE 114,9 OF oDlgSel PIXEL HASBUTTON
   oProduto:Enable()
   @ 63,45 MSGET oQuantidade VAR nQtde_NFD PICT "@E 999,999,999,999" VALID DI158NFDVal("nQtde_NFD") SIZE 114,9 OF oDlgSel PIXEL
   oQuantidade:Enable()

   @ 085,08  TO 141,160 LABEL STR0028  OF oDlgSel PIXEL //STR0028 "NOTA"
   @ 095,10 SAY AVSX3("WD_ESPECIE",5) OF oDlgSel PIXEL
   @ 108,10 SAY AVSX3("WD_FORN" ,5)   OF oDlgSel PIXEL
   @ 121,10 SAY AVSX3("WD_LOJA" ,5)   OF oDlgSel PIXEL

   @ 095,45 MSGET oEspecie VAR cEspe_NFD PICT AVPic("WD_ESPECIE") F3 "42"  VALID DI158NFDVal("cEspe_NFD") SIZE 114,9 OF oDlgSel PIXEL HASBUTTON
   oEspecie:Enable()
   @ 108,45 MSGET oForn    VAR cForn_NFD PICT AVPic("WD_FORN")    F3 "FOR" VALID DI158NFDVal("cForn_NFD") SIZE 050,9 OF oDlgSel PIXEL HASBUTTON
   oForn:Enable()
   @ 121,45 MSGET oLoja    VAR cLoja_NFD PICT AVPic("WD_LOJA")             VALID DI158NFDVal("cLoja_NFD") SIZE 009,9 OF oDlgSel PIXEL
   oLoja:Disable()

   @ 145,70 BUTTON oBtn3 PROMPT STR0029  SIZE 30,10 ; //STR0029 "LIMPA"
            ACTION (DI158NFDVal("cLimpa_NFD"),oMark1:oBrowse:Refresh()) OF oDlgSel PIXEL
   @ 161,50 BUTTON oBtn1 PROMPT "OK"     SIZE 30,10 ;
            ACTION (IF(DI158NFDVal("cOK_IT"),(nOk:=1,oMark1:oBrowse:Refresh(),oDlgSel:End()),(nOk:=0,oMark1:oBrowse:Refresh()))) OF oDlgSel PIXEL
   @ 161,90 BUTTON oBtn2 PROMPT "CANCEL" SIZE 30,10 ;
            ACTION (nOk := 0,oMark1:oBrowse:Refresh(),oDlgSel:End() ) OF oDlgSel PIXEL

   ACTIVATE MSDIALOG oDlgSel CENTERED

   cSeekNF := WorkWD->WD_FILIAL + WorkWD->WD_DOC + WorkWD->WD_SERIE + WorkWD->WD_FORN + WorkWD->WD_LOJA + WorkWD->WD_ESPECIE
   cSeekNF2 := WorkWD->WD_FILIAL + WorkWD->WD_DOC + WorkWD->WD_SERIE + cForn_NFD + cLoja_NFD + cEspe_NFD
   If nAgrupa == 2
      cSeekNF += WorkWD->WD_DESPESA
      cSeekNF2 += WorkWD->WD_DESPESA
   EndIf   

   If nOk == 1
      If WorkWD->WD_FORN # cForn_NFD .Or. WorkWD->WD_LOJA # cLoja_NFD .Or. WorkWD->WD_ESPECIE # cEspe_NFD //.Or. WorkWD->WD_EMISSAO # dEmis_NFD
         lAlterouIT := .T.
      EndIf
      If lAlterouIT
         nRegItem := WorkWD->WD_RECNO
         If WorkNF->(DbSeek(cSeekNF))
            WorkNF->NF_VALOR_R -= WorkWD->WD_VALOR_R
            If WorkNF->NF_VALOR_R <= 0
               WorkNF->(RecLock("WorkNF",.F.))
               WorkNF->(DbDelete())
               WorkNF->(MsUnlock())
            EndIf
         EndIf
         If WorkNF->(DbSeek(cSeekNF2))
            WorkNF->NF_VALOR_R += WorkWD->WD_VALOR_R
         Else
            WorkNF->(RecLock("WorkNF",.T.))
            WorkNF->NF_FILIAL := WorkWD->WD_FILIAL
            WorkNF->NF_DOC    := WorkWD->WD_DOC
         	WorkNF->NF_SERIE  := WorkWD->WD_SERIE
         	WorkNF->NF_FORN   := AvKey(cForn_NFD,"WD_FORN")
         	WorkNF->NF_LOJA   := AvKey(cLoja_NFD,"WD_LOJA")
         	WorkNF->NF_ESPECIE:= AvKey(cEspe_NFD,"WD_ESPECIE")
            If nAgrupa == 2
               WorkNF->NF_DESPESA:= WorkWd->WD_DESPESA
            EndIf   
         	WorkNF->NF_VALOR_R:= WorkWD->WD_VALOR_R
         	WorkNF->NF_FLAG   := Space(2)
         	WorkNF->(MsUnlock())
      	 EndIf
      	 WorkWD->(RecLock("WorkWD",.F.))
      	 WorkWD->WD_ESPECIE := AvKey(cEspe_NFD,"WD_ESPECIE")
      	 WorkWD->WD_FORN    := AvKey(cForn_NFD,"WD_FORN")
      	 WorkWD->WD_LOJA    := AvKey(cLoja_NFD,"WD_LOJA")
      	 WorkWD->WD_EMISSAO := dEmis_NFD
      	 WorkWD->WD_B1_COD  := AvKey(cProd_NFD,"WD_B1_COD")
      	 WorkWD->WD_B1_QTDE := nQtde_NFD
      	 WorkWD->WD_B1_PRC  := WorkWD->WD_VALOR_R/nQtde_NFD
      	 WorkWD->WD_NOTAGER := "N"
      	 WorkWD->(MsUnlock())
      	 lGerou_NFD := .F.
      Else
         WorkWD->(RecLock("WorkWD",.F.))
      	 WorkWD->WD_B1_COD  := cProd_NFD
         WorkWD->WD_B1_QTDE := nQtde_NFD
         WorkWD->WD_B1_PRC  := WorkWD->WD_VALOR_R/nQtde_NFD
         WorkWD->(MsUnlock())
      EndIf
   EndIf
   WorkWD->(DbGoTop())
ELSE
   MsgInfo(STR0030+CHR(13)+CHR(10)+STR0031,STR0010) // STR0030 "Este item já possui nota!" //STR0031 " É necessário o estorno da Nota Fiscal para alteração do item." //STR0010 "Aviso"
ENDIF

return .T.

/****************************************************
Funcao     : DI158NFD_NF()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Permitir alteração das notas não geradas
Autor      : Nilson César C. Filho
Data/Hora  : 09/08/2010
*****************************************************/
FUNCTION DI158NFDNota()

Local lAlterouNF := .F.
Local lOk        := .T.
Local nOk        := 0
Local aOrdNFDNota:= {}
Local cChaveNF   := ""
Local nDocTam := AVSX3("F1_DOC", AV_TAMANHO)
Local nSerTam := AVSX3("F1_SERIE", AV_TAMANHO)

Private oDlgNota,oNF,oSerie,oForn,oLoja,oDtEmiss,oBtn3,oBtn4,oCboTipoNF
Private aTesteNF := {}
Private aTiposNFD := {}

cNF_NFD    := WorkNF->NF_DOC
cSerie_NFD := WorkNF->NF_SERIE
dEmis_NFD  := IF(EMPTY(WorkNF->NF_EMISSAO),dDataBase,WorkNF->NF_EMISSAO)

aTiposNFD := {"N-Normal","C-Compl. Preço/Frete"}

IF WorkNF->(!EOF())
   IF WorkNF->NF_NOTAGER <> "S"

      DEFINE MSDIALOG oDlgSel TITLE STR0014 From 50,46 To 70,88 OF oMainWnd  //STR0014 "NOTA FISCAL"

         @ 20,08 TO 90,160 LABEL STR0014 OF oDlgSel PIXEL //STR0014 "NOTA FISCAL"
         @ 30,10 SAY AVSX3("WD_DOC" ,5)    OF oDlgSel PIXEL
         @ 43,10 SAY AVSX3("WD_SERIE",5)   OF oDlgSel PIXEL
         @ 56,10 SAY AVSX3("WD_EMISSAO",5) OF oDlgSel PIXEL
         @ 69,10 SAY AVSX3("WD_TIPONFD",5) OF oDlgSel PIXEL
         @ 30,45 MSGET oNF      VAR cNF_NFD     PICT Replicate("N",nDocTam)     VALID DI158NFDVal("cNF_NFD")    SIZE 114,9 OF oDlgSel PIXEL
         oNF:Enable()
         @ 43,45 MSGET oSerie   VAR cSerie_NFD  PICT Replicate("N",nSerTam)   VALID DI158NFDVal("cSerie_NFD") SIZE 114,9 OF oDlgSel PIXEL
         oSerie:Enable()
         @ 56,45 MSGET oDtEmiss VAR dEmis_NFD PICT AVPic("WD_EMISSAO")   VALID DI158NFDVal("dEmis_NFD")  SIZE 070,9 OF oDlgSel PIXEL HASBUTTON
         oDtEmiss:Enable()
         @ 69,45 COMBOBOX oCboTipoNF VAR cTipo_NFD ITEMS  aTiposNFD   SIZE 070,9 PIXEL

         //TDF - 08/10/12 - ACERTO DE STR PARA O BOTÃO "LIMPA"
         @ 090,70 BUTTON oBtn3 PROMPT STR0029  SIZE 30,10 ACTION (DI158NFDVal("cLimpa_NFC"),oMark2:oBrowse:Refresh()) OF oDlgSel PIXEL //STR0031 "LIMPA"
         @ 120,50 BUTTON oBtn4 PROMPT "OK"     SIZE 30,10 ACTION (IF(DI158NFDVal("cOK_NF"),(nOk:=1,oMark2:oBrowse:Refresh(),oDlgSel:End()),(nOk:=0,oMark2:oBrowse:Refresh()))) OF oDlgSel PIXEL
         @ 120,90 BUTTON oBtn5 PROMPT "CANCEL" SIZE 30,10 ACTION (nOk := 0,oMark2:oBrowse:Refresh(),oDlgSel:End()) OF oDlgSel PIXEL


      ACTIVATE MSDIALOG oDlgSel CENTERED

      IF nOk <> 0
         aOrdNFDNota := SaveOrd({"WorkNF","WorkWD"})
         IF WorkNF->NF_DOC # cNF_NFD .Or. WorkNF->NF_SERIE # cSerie_NFD .Or. WorkNF->NF_EMISSAO # dEmis_NFD .Or. WorkNF->NF_TIPONFD # SUBSTR(cTipo_NFD,1,1)
            lAlterouNF := .T.
         ENDIF
         IF lAlterouNF
            cChaveNF := WorkNF->NF_FILIAL + WorkNF->NF_DOC + WorkNF->NF_SERIE + WorkNF->NF_FORN + WorkNF->NF_LOJA + WorkNF->NF_ESPECIE /*+ WorkNF->NF_TIPONFD + DTOS(WorkNF->NF_EMISSAO)*/ //THTS - 19/06/2017 - TE-5912 - Comentado o campo NF_TIPONFD
            if nAgrupa == 2
               cChaveNF += WorkNF->NF_DESPESA
            EndIf
            WorkNF->NF_DOC     := AvKey(cNF_NFD,"WD_DOC")
            WorkNF->NF_SERIE   := AvKEy(cSerie_NFD,"WD_SERIE")
            WorkNF->NF_EMISSAO := dEmis_NFD
            WorkNF->NF_TIPONFD := SUBSTR(cTipo_NFD,1,1)
            WorkNF->NF_FLAG    := cMarca2
            WorkWD->(DbSetOrder(4))
            WorkWD->(DbClearFilter())
            WorkWD->(DbCommit())
            WorkWD->(DbGoTop())
            WHILE WorkWD->(DbSeek(cChaveNF))
               WorkWD->(RecLock("WorkWD",.F.))
               WorkWD->WD_DOC     :=  WorkNF->NF_DOC
               WorkWD->WD_SERIE   :=  WorkNF->NF_SERIE
               WorkWD->WD_EMISSAO :=  WorkNF->NF_EMISSAO
               WorkWD->WD_TIPONFD :=  WorkNF->NF_TIPONFD
               WorkWD->(MsUnlock())
            ENDDO
            lGerou_NFD := .F.
         ENDIF
         //TDF - 08/10/12 - Retirada obrigatoriedade de informar o número de série
         IF EMPTY(WorkNF->NF_DOC) /*.OR. EMPTY(WorkNF->NF_SERIE)*/ .OR. EMPTY(WorkNF->NF_EMISSAO)
            WorkNF->NF_FLAG := Space(2)
         ENDIF
         RestOrd(aOrdNFDNota)
      ENDIF
   ELSE
      IF EMPTY(WorkNF->NF_FLAG)
         If MsgYesNo(STR0032,STR0011) //STR0032 "Deseja selecionar esta nota para estorno ?" //STR0011 := "Atenção"
            WorkNF->NF_FLAG := cMarca2
         EndIf
      ELSE
         If MsgYesNo(STR0067,STR0011)  //STR0011 := "Atenção"  //STR0067 "Deseja desmarcar esta nota ?"
            WorkNF->NF_FLAG := Space(2)
         EndIf
      ENDIF
      Return
   ENDIF
ELSE
   MsgAlert(STR0068) //STR0068 "Não existem notas disponíveis para alteração!"
ENDIF
oMark2:oBrowse:refresh()
return .T.
/******************************************************************************
Funcao     : DI158NFDVal()
Parametros : cCampo - Variavel que contem o valor do campo/botão a ser validado
             nOpcao - 1=Gera nota, 2=Estorno
Retorno    : Nenhum
Objetivos  : Validar os campos das despesas
Autor      : Nilson César C. Filho
Data/Hora  : 16/08/2010
*******************************************************************************/
FUNCTION DI158NFDVal(cCampo,nOpcao)
//MFR 13/05/2019 OSSME-2808
Local lRet := .T.
Private lRetDI158Val := .T.
Private cCampoDI158Val := cCampo
Private nTipoOperacao := nOpcao
If ExistBlock("EICDI158")
   ExecBlock("EICDI158",.F.,.F.,"DI158_NFVAL_INI")
   lRet := lRetDI158Val
EndIf

IF lRet == .T.
  DO CASE
     CASE cCampo == "cProd_NFD"
         lRet := Vazio() .Or. ExistCpo("SB1",cProd_NFD,1)
     
     CASE cCampo == "cForn_NFD" .Or. cCampo == "cLoja_NFD"
        lRet := TEVlCliFor(cForn_NFD,cLoja_NFD,"SA2","1|2|3|4|5| ")

     CASE cCampo == "cEspe_NFD"
         lRet := Vazio() .Or. ExistCpo("SX5","42"+AvKey(cEspe_NFD,"F1_COD"))

     CASE cCampo == "cOK_NF"

      //TDF - 08/10/12 - Retirada obrigatoriedade de informar o número de série
      IF (EMPTY(cNF_NFD) /*.OR. EMPTY(cSerie_NFD)*/ .OR. EMPTY(dEmis_NFD) .OR. EMPTY(cTipo_NFD)) .AND. !lLimpaNF_C /*.OR. EMPTY(cForn_NFD) .OR. EMPTY(cLoja_NFD)*/
         MsGStop(STR0033,STR0010) //STR0033 "Há campos não preenchidos" //STR0010 "Aviso"
         Return .F.
         lRet := .F.
      ENDIF
      IF SF1->(DbSeek(xFilial("SF1")+AvKey(cNF_NFD,"F1_DOC")+AvKey(cSerie_NFD,"F1_SERIE")+AvKey(cForn_NFD,"F1_FORN")+AvKey(cLoja_NFD,"F1_LOJA")+SUBSTR(AvKey(cTipo_NFD,"F1_TIPO"),1,1)))
         Help(" ",1,"AVG0000810")
         lRet := .F.
         Return .F.
      ENDIF
      //ENDIF
      //IF lLimpaNF_C
      //   lRet := .F.
      //ENDIF
      lLimpaNF_C := .F.

     CASE cCampo == "cOK_IT"

      IF !lLimpaNF_D .AND. (EMPTY(cEspe_NFD) .OR. EMPTY(cProd_NFD) .OR. EMPTY(cForn_NFD) .OR. EMPTY(cLoja_NFD))
         MsGStop(STR0033,STR0010) //STR0033 "Há campos não preenchidos" //STR0010 "Aviso"
         Return .F.
         lRet := .F.
      ENDIF

      IF !lLimpaNF_D .AND. nQtde_NFD <= 0
         MsGStop(STR0034,STR0010) //STR0034 "Quantidade deve ser maior que Zero ou o valor "  //STR0010 "Aviso"
         Return .F.
         lRet := .F.
      ENDIF

      IF (WorkWD->WD_VALOR_R/(IF(nQtde_NFD<>0,nQtde_NFD,1)) < 0.01)

         MsgStop(STR0035+WorkWD->WD_DESPESA+" - "+WorkWD->WD_DESCDES+CHR(13)+CHR(10)+; //STR0035 "Valor Unitário da Despesa "
                  STR0036+CHR(13)+CHR(10)+; //STR0036 "resulta em valor inferior à  R$ 0.01 . Modifique a quantidade "
                  STR0037+CHR(13)+CHR(10)+; //STR0037 "de forma que a divisão pelo valor da despesa resulte em um valor"
                  STR0038,STR0011) //STR0038 "maior que 0.01 !"  //STR0011 := "Atenção"
         Return .F.
         lRet := .F.
      ENDIF

      SB1->(DbSetOrder(1))
      IF !lLimpaNF_D .AND. !SB1->(DbSeek(xFilial("SB1")+AvKey(cProd_NFD,"WD_B1_COD")))
         Help(" ",1,"REGNOIS")
         lRet := .F.
         Return .F.
      ENDIF

      IF !lLimpaNF_D .AND. !ExistCpo("SX5","42"+AvKey(cEspe_NFD,"F1_COD"))
         lRet := .F.
         Return .F.
      ENDIF

      SA2->(DbSetOrder(1))
      IF !lLimpaNF_D .AND. !SA2->(DbSeek(xFilial("SA2")+AvKey(cForn_NFD,"WD_FORN")))
         Help("", 1, "AVG0000491")
         lRet := .F.
         Return .F.
      ENDIF

      lLimpaNF_D := .F.


     CASE cCampo == "cOK_NFs"
      lRet := .F.
      WorkNF->(DbGotop())
      WHILE !WorkNF->(EOF())
         IF !EMPTY(WorkNF->NF_FLAG)
            lRet := .T.
            EXIT
         ENDIF
         WorkNF->(DbSkip())
      ENDDO
      IF !lRet
         MsgAlert(STR0039) //STR0039 "Não existem notas marcadas para processamento!"
      ENDIf

     CASE cCampo == "cLimpa_NFC"
      lLimpaNF_C      := .T.
      cNF_NFD         := Space(LEN(WorkNF->NF_DOC))
      cSerie_NFD      := Space(LEN(WorkNF->NF_SERIE))
      dEmis_NFD       := CTOD("  /  /  ")
      WorkNF->NF_FLAG := Space(2)
      lRet            := .T.

     CASE cCampo == "cLimpa_NFD"
      lLimpaNF_D := .T.
      cProd_NFD  := Space(LEN(SB1->B1_COD))
      nQtde_NFD  := 0

      cEspe_NFD  := Space(LEN(WorkWD->WD_ESPECIE))
      cForn_NFD  := Space(LEN(WorkWD->WD_FORN))
      cLoja_NFD  := Space(LEN(WorkWD->WD_LOJA))

  END CASE
EndIf 

//MFR 13/05/2019 OSSME-2808
If ExistBlock("EICDI158")
   ExecBlock("EICDI158",.F.,.F.,"DI158_NFVAL_FIM")
   lRet := lRetDI158Val
EndIf

Return lRet

/**********************************************
Funcao     : DI158NFDFil()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Filtrar Despesas sem nota
Autor      : Nilson César C. Filho
Data/Hora  : 23/12/2010
***********************************************/
FUNCTION DI158NFDFil()

Local oFil01
Local nFil01
Local oDlg
Local cTitulo := STR0040 //STR0040 "FILTRO DOS ITENS"
Local aOpcoes := {STR0041,STR0042} //STR0041 "Itens sem Nota" //STR0042 "Processo"
Local nOpcao := 0
Local nOpca
Local oHawb
Local cHawb := Space(Len(SW6->W6_HAWB))


DEFINE MSDIALOG oDlg TITLE cTitulo FROM  0,0 TO 150,400 OF  oDlgTela1 PIXEL

   @ 05,15 TO 60,185 LABEL STR0043 OF oDlg PIXEL //"Escolha a Opcao p/ Alterar" //STR0043 "Escolha o Filtro"

   @ 15,25 RADIO oFil01 VAR nFil01 ITEMS aOpcoes[1], aOpcoes[2] 3D SIZE 65,13 PIXEL OF oDlg ON CHANGE (Eval( {|| IF( nFil01 == 2,oHawb:Enable(),oHawb:Disable()) }))

   @ 23,95 MSGET oHawb VAR cHawb PICT AVPic("W6_HAWB") F3 "SW6" VALID !Empty(cHawb) SIZE 80,6 WHEN {||nFil01==2 } OF oDlg PIXEL

   DEFINE SBUTTON FROM 65,70 TYPE 1 ACTION (nOpca:=1,oDlg:End()) VALID IF(nFil01==2,!Empty(cHawb),.T.)  ENABLE OF oDlg PIXEL

   DEFINE SBUTTON FROM 65,100 TYPE 2 ACTION (nOpca:=0,oDlg:End()) ENABLE OF oDlg PIXEL

ACTIVATE MSDIALOG oDlg CENTERED

If nOpca == 0
   WorkWD->(DbClearFilter())
ElseIf nOpca == 1
   If nFil01 == 1
      WorkWD->(DbClearFilter())
      WorkWD->(DbSetFilter({|| WorkWD->WD_NOTAGER == "N" },'WorkWD->WD_NOTAGER == "N"'))
      WorkWD->(DbGoTop())
      IF ValType(oMark1) <> "U"
         oMark1:oBrowse:Refresh()
      ENDIF
   Else
      If !Empty(cHawb)
         WorkWD->(DbClearFilter())
         WorkWD->(DbSetFilter({|| WorkWD->WD_HAWB == AvKey(cHawb,"WD_HAWB") },'WorkWD->WD_HAWB == AvKey(cHawb,"WD_HAWB")'))
         WorkWD->(DbGoTop())
        WorkWD->(DbGoTop())
      IF ValType(oMark1) <> "U"
         oMark1:oBrowse:Refresh()
      ENDIF
      Else
         MsgAlert(STR0044) //STR0044 "Informe o Processo!"
         Return .F.
      EndIf
   EndIf
EndIf

Return

/**********************************************
Funcao     : DI158TelaDesp()
Parametros : Nenhum
Retorno    : Nenhum
Objetivos  : Visualizar despesas de outros processos
             relacionados a Nota a ser estornada
Autor      : Nilson César C. Filho
Data/Hora  : 19/01/2011
***********************************************/
FUNCTION DI158TelaDsp()

Private oDlgTela3
Private cDlgTit3 := STR0045 //STR0045 "Itens da Nota"
Private bOk3, bCancel3
Private oPanelBTN

oMainWnd:ReadClientCoords()
   DEFINE MSDIALOG oDlgTela3 TITLE STR0046; //STR0046 "Despesas Associadas"
      FROM oMainWnd:nTop+070,oMainWnd:nLeft+5 TO oMainWnd:nBottom-70,oMainWnd:nRight-10;
      OF oMainWnd PIXEL

      nColFim      := (oDlgTela3:nClientWidth-4)/2
      nLinha       := (oDlgTela3:nClientHeight-4)/2
      oMark3:= MsSelect():New("WorkWD1","WD1_FLAG",,aSelCpsWD1,@lInverte3,@cMarca3,{002,002,(oDlgTela3:nClientHeight-50)/2,(oDlgTela3:nClientWidth-4)/2},,,)

      @00,00 MsPanel oPanelBTN Prompt "" Size 60,24 of oDlgTela3
      DEFINE SBUTTON FROM 5,oMainWnd:nLeft+10 TYPE 01 ACTION oDlgTela3:End() ENABLE  of oPanelBtn Pixel
      oDlgTela3:lMaximized:=.T.

      WorkWD1->(DbSetFilter({|| WorkNF->NF_FILIAL == WorkWD1->WD1_FILIAL .AND. WorkNF->NF_DOC == WorkWD1->WD1_DOC .AND. WorkNF->NF_SERIE == WorkWD1->WD1_SERIE .AND.;
                                WorkNF->NF_FORN == WorkWD1->WD1_FORN .AND. WorkNF->NF_LOJA == WorkWD1->WD1_LOJA .AND. WorkNF->NF_ESPECIE == WorkWD1->WD1_ESPEC },;
                               "WorkNF->NF_FILIAL == WorkWD1->WD1_FILIAL .AND. WorkNF->NF_DOC == WorkWD1->WD1_DOC .AND. WorkNF->NF_SERIE == WorkWD1->WD1_SERIE .AND. "+;
                               "WorkNF->NF_FORN == WorkWD1->WD1_FORN .AND. WorkNF->NF_LOJA == WorkWD1->WD1_LOJA .AND. WorkNF->NF_ESPECIE == WorkWD1->WD1_ESPEC"))
      WorkWD1->(DbGoTop())
      oMark3:oBrowse:refresh()

	  oPanelBtn:Align:=CONTROL_ALIGN_BOTTOM
	  oMark3:oBrowse:Align:=CONTROL_ALIGN_ALLCLIENT

   ACTIVATE MSDIALOG oDlgTela3 CENTERED ON INIT (oMark3:oBrowse:Refresh())

Return .T.

/**********************************************
Funcao     : DI158NFDGera()
Parametros : nOpc_NFD (1=Inclusão; 2=Estorno)
Retorno    : Nenhum
Objetivos  : Geração Das Notas Fiscais
Autor      : Nilson César C. Filho
Data/Hora  : 19/08/2010
***********************************************/
FUNCTION DI158NFDGera(nOpc_NFD)

Local nRecWK       := 0
Local nIndWK       := 0
Local i            := 0
Local cTexto       := ''
Local cFile        := ""
Local cMask        := "Arquivos Texto (*.TXT) |*.txt|"
Local cLogNF       := ""
Local aOrdSWD      := SaveOrd({"SWD"})
Local aChaveSF1    := {}
Local cChaveSf1
//Local cChave_SF1   := "" não é mais utilizada
Local cKeyWD       :=""
Private aNFDCapa   := {}
Private aNFDItem   := {}
Private aNFDDetail := {}
Private aNFDLog    := {}
Private aRecsWD    := {}
Private aRecsWD1   := {}
Private aRecsNF    := {}
Private aRecsNFEst := {}
Private lMSErroAuto := .F.
Private lMSHelpAuto := .F.
Private lNFDClassif := .F.
Private nItemNFD := nValTotNFD := 0
Private lCanDelF1 := .T.
Private cKeyNFD_NF := cKeyNFD_WD := cKeyNFD_F1 := cKeyNFD_D1 := ""

WorkNF->(DbSetOrder(1))
WorkWD->(DbSetOrder(4))
SF1->(DbSetOrder(1))
SD1->(DbSetOrder(1))
WorkNF->(DbGoTop())
WorkWD->(DbGoTop())
WorkWD->(DbClearFilter())
WorkWD1->(DbClearFilter())

BEGIN TRANSACTION
IF nOpc_NFD == 1

   ProcRegua(WorkNF->(EasyRecCount()))
   WHILE !WorkNF->(EOF())

      IF EMPTY(WorkNF->NF_FLAG)
         WorkNF->(DbSkip())
         LOOP
      ENDIF

      IF SF1->(DbSeek(xFilial("SF1")+WorkNF->NF_DOC+WorkNF->NF_SERIE+WorkNF->NF_FORN+WorkNF->NF_LOJA/*+WorkNF->NF_TIPONFD*/))
         cLogNF += (STR0047+WorkNF->NF_DOC+STR0048+Left(WorkNF->NF_SERIE,nLenSDoc)+STR0049) //STR0047 "Nota Fiscal No. " //STR0048 " Série: " //STR0049 " já existente no módulo de compras"
         cLogNF += (CHR(13)+CHR(10))
         WorkNF->(DbSkip())
         LOOP
      ENDIF

      IncProc(STR0050+WorkNF->NF_DOC+STR0048+Left(WorkNF->NF_SERIE,nLenSDoc)) //STR0050 "Processando geração da nota: " //STR0048 " série: "

      AADD(aNFDCapa,{"F1_TIPO"        ,WorkNF->NF_TIPONFD           ,NIL})   // N-NORMAL/ C-COMPL. PREÇO/FRETE
      AADD(aNFDCapa,{"F1_FORMUL"      ,"N"                          ,NIL})   // N - NÃO UTILIZA FORM. PROPRIO
      AADD(aNFDCapa,{"F1_EMISSAO"     ,WorkNF->NF_EMISSAO           ,NIL})   // DATA DA EMISSAO DA NOTA
      AADD(aNFDCapa,{"F1_FORNECE"     ,WorkNF->NF_FORN              ,NIL})   // FORNECEDOR
      AADD(aNFDCapa,{"F1_LOJA"        ,WorkNF->NF_LOJA              ,NIL})   // LOJA DO FORNECEDOR
      AADD(aNFDCapa,{"F1_DOC"         ,WorkNF->NF_DOC               ,NIL})   // NUMERO DA NOTA
      AADD(aNFDCapa,{"F1_SERIE"       ,WorkNF->NF_SERIE             ,NIL})   // SERIE DA NOTA
      AADD(aNFDCapa,{"F1_ESPECIE"     ,WorkNF->NF_ESPECIE           ,NIL})   // ESPECIE DA NOTA FISCAL
      AADD(aNFDCapa,{"F1_FOB_R"       ,WorkNF->NF_VALOR_R           ,NIL})   // VALOR TOTAL DA NOTA
      AADD(aNFDCapa,{"F1_TIPO_NF"   ,'0',NIL}) //LRS - 21/03/2018 - Passando zero no F1_TIPO_NF para não ser possivel deletar o registro pelo compras depois de classificar
      IF SF1->(FieldPos("F1_CIMPORT")) # 0
         AADD(aNFDCapa,{"F1_CIMPORT"  ,AvKey(SW6->W6_IMPORT,"F1_CIMPORT") ,NIL})   //
      ENDIF
      IF(EasyEntryPoint("EICDI158"),Execblock("EICDI158",.F.,.F.,"DI158NFDGera_aNFDCapa"),) //SVG - 13/12/2010
      //cChave_SF1 := xFilial("SF1")+AvKey(WorkNF->NF_DOC,"F1_DOC")+AvKey(WorkNF->NF_SERIE,"F1_SERIE")+AvKey(WorkNF->NF_FORN,"F1_FORNECE")+AvKey(WorkNF->NF_LOJA,"F1_LOJA")/*+AvKey(WorkNF->NF_TIPONFD,"F1_TIPO")*/
      cKeyNFD_NF := WorkNF->NF_FILIAL+WorkNF->NF_DOC+WorkNF->NF_SERIE+WorkNF->NF_FORN+WorkNF->NF_LOJA+WorkNF->NF_ESPECIE/*+WorkNF->NF_TIPONFD*/
      If nAgrupa == 2
         //cChave_SF1 += AvKey(WorkNF->NF_DESPESA,"WD_DESPESA") 
         cKeyNFD_NF += WorkNF->NF_DESPESA
      EndIf   


      WorkWD->(DbSeek(cKeyNFD_NF))

      WHILE !WorkWD->(EOF()) 
         cKeyWD     := WorkWD->WD_FILIAL + WorkWD->WD_DOC + WorkWD->WD_SERIE + WorkWD->WD_FORN + WorkWD->WD_LOJA + WorkWD->WD_ESPECIE
         If nAgrupa == 2         
            cKeyWD     += WorkWD->WD_DESPESA
         EndIf            
         If cKeyNFD_NF != cKeyWD
            exit
         EndIF   

         //LOOP DOS ITENS...
         //cLogNF := ("Nota Fiscal No. "+WorkNF->NF_DOC+" Série: "+WorkNF->NF_SERIE+" já existente no módulo de compras")
         IF EMPTY(WorkWD->WD_B1_COD)
            cLogNF += (STR0051+WorkWD->WD_DESPESA+STR0053+WorkWD->WD_DOC)  //STR0051 "Despesa " //STR0053 " com item não informado na Nota "
            cLogNF += (CHR(13)+CHR(10))
            WorkWD->(DbSkip())
            LOOP
         ENDIF

         IF EMPTY(WorkWD->WD_ESPECIE)
            cLogNF += (STR0051+WorkWD->WD_DESPESA+STR0053+WorkWD->WD_DOC) //STR0051 "Despesa " //STR0053 " com espécie não informada na Nota "
            cLogNF += (CHR(13)+CHR(10))
            WorkWD->(DbSkip())
            LOOP
         ENDIF

         IF WorkWD->WD_B1_QTDE <= 0
            cLogNF += (STR0051+WorkWD->WD_DESPESA+STR0054+WorkWD->WD_DOC)//STR0051 "Despesa " //STR0054 " com quantidade não informada na Nota "
            cLogNF += (CHR(13)+CHR(10))
            WorkWD->(DbSkip())
            LOOP
         ENDIF

         aNFDItem := {}
         nItemNFD++

         AADD(aNFDItem,{"D1_CONHEC" ,WorkWD->WD_HAWB    ,NIL})
         AADD(aNFDItem,{"D1_DOC"    ,WorkWD->WD_DOC     ,NIL})
         AADD(aNFDItem,{"D1_SERIE"  ,WorkWD->WD_SERIE   ,NIL})
         AADD(aNFDItem,{"D1_FORNECE",WorkWD->WD_FORN    ,NIL})
         AADD(aNFDItem,{"D1_LOJA"   ,WorkWD->WD_LOJA    ,NIL})
         AADD(aNFDItem,{"D1_TIPO"   ,WorkWD->WD_TIPONFD ,NIL})
         AADD(aNFDItem,{"D1_ITEM"   ,STRZERO(nItemNFD,4),NIL})
         AADD(aNFDItem,{"D1_COD"    ,WorkWD->WD_B1_COD  ,NIL})
         AADD(aNFDItem,{"D1_UM"     ,"UN"               ,NIL})
         AADD(aNFDItem,{"D1_QUANT"  ,WorkWD->WD_B1_QTDE ,".T."})
         AADD(aNFDItem,{"D1_VUNIT"  ,WorkWD->WD_B1_PRC  ,NIL})
         AADD(aNFDItem,{"D1_TOTAL"  ,WorkWD->WD_VALOR_R ,NIL})
         AADD(aNFDItem,{"D1_TIPO_NF","A",Nil})

         //FDR - 12/04/12
         SB1->(DbSetOrder(1))
         SB1->(dbSeek(xFilial("SB1")+WorkWD->WD_B1_COD))
         AADD(aNFDItem,{"D1_LOCAL"  ,SB1->B1_LOCPAD     ,NIL})

         aAdd(aRecsWD, {WorkWD->WD_RECNO,WorkWD->(Recno())} )
         IF(EasyEntryPoint("EICDI158"),Execblock("EICDI158",.F.,.F.,"DI158NFDGera_aNFDItem"),) //SVG - 13/12/2010
         AADD(aNFDDetail,aClone(aNFDItem))

         WorkWD->(DbSkip())
      ENDDO // FIM DO LOOP DOS ITENS
/*    Não conseguimos fazer entrar neste trecho do código OSSME-6063 DTRADE-6613 MFR 08/02/2022
      WorkWD1->(DbSeek(cKeyNFD_NF))       
      WHILE !WorkWD1->(EOF())
         cKeyWD1 := WorkWD1->WD1_FILIAL + WorkWD1->WD1_DOC + WorkWD1->WD1_SERIE + WorkWD1->WD1_FORN + WorkWD1->WD1_LOJA + WorkWD1->WD1_ESPEC 
         If nAgrupa == 2
            cKeyWD1    += WorkWD1->WD1_DESPE
         EndIf   
         If cKeyNFD_NF != cKeyWD1
            Exit 
         EndIF
         aAdd(aRecsWD1, WorkWD1->(Recno()) )
         WorkWD1->(DbSkip())         
      ENDDO
      */
      aNFDItem   := {}
      nItemNFD   := 0
      nValTotNFD := 0


      //GERAÇÃO DA NOTA NO COMPRAS
      MSExecAuto({|x,y| MATA140(x,y)},aNFDCapa,aNFDDetail)
      IF lMSErroAuto
         MostraErro()
         cLogNF += (STR0055+WorkNF->NF_DOC+STR0056+Left(WorkNF->NF_SERIE,nLenSDoc)) //STR0055 "Não foi possível a geração da Nota: "  //STR0056 " série: "
         cLogNF += (CHR(13)+CHR(10))
         WorkNF->(DbSkip())
         LOOP
      ENDIF
      /* //NCF - [Nopado]- 19/01/2011 - Deixou de gravar o Hawb na capa devido a nota conter despesas de vários processos
      IF (nPosF1:=SF1->(FIELDPOS("F1_HAWB"))) # 0 .And. (nPosNF:=ASCAN(aNFDCapa,{ |A| A[1] == "F1_HAWB" } )) # 0
         SF1->(DBSETORDER(1))
         IF SF1->(DBSEEK(cChave_SF1))
            IF EMPTY(SF1->F1_HAWB)
               SF1->(RecLock("SF1",.F.))
               SF1->F1_HAWB := aNFDCapa[nPosNF][2]
               SF1->(MsUnlock())
            ENDIF
         ELSE
            MSGALERT("Os tamanhos dos campos da nota estão diferentes dos campos de nota das despesas!"+CRH(13)+CHR(10)+"Verifique os campos no configurador")
         ENDIF
      ELSE
         MSGALERT("Não foi possível a gravação do Número de Conhecimento (F1_HAWB) na capa da Nota Fiscal")
      ENDIF
      */
      FOR i := 1 To LEN(aRecsWD)
         SWD->(DbGoto(aRecsWD[i][1]))
         WorkWD->(DbGoto(aRecsWD[i][2]))
         SWD->(RecLock("SWD",.F.))
            IF AvKey(WorkWD->WD_FORN,"WD_FORN") <>  SWD->WD_FORN
               SWD->WD_FORN    := WorkWD->WD_FORN
               SWD->WD_LOJA    := WorkWD->WD_LOJA
            ENDIF
            IF AvKey(WorkWD->WD_B1_COD,"WD_B1_COD") <>  SWD->WD_B1_COD
               SWD->WD_B1_COD    := WorkWD->WD_B1_COD
            ENDIF
            SWD->WD_DOC     := WorkWD->WD_DOC
            SWD->WD_SERIE   := WorkWD->WD_SERIE
            SWD->WD_ESPECIE := WorkWD->WD_ESPECIE
            SWD->WD_TIPONFD := WorkNF->NF_TIPONFD
            SWD->WD_EMISSAO := WorkWD->WD_EMISSAO
            SWD->WD_B1_QTDE := WorkWD->WD_B1_QTDE
         SWD->(MsUnlock())

         WorkWD1->(RecLock("WorkWD1",.T.))
         WorkWD1->WD1_FILIAL := SWD->WD_FILIAL
         WorkWD1->WD1_HAWB   := SWD->WD_HAWB
         WorkWD1->WD1_DESPE  := SWD->WD_DESPESA
         WorkWD1->WD1_DOC    := SWD->WD_DOC
         WorkWD1->WD1_SERIE  := SWD->WD_SERIE
         WorkWD1->WD1_ESPEC  := SWD->WD_ESPECIE
         WorkWD1->WD1_FORN   := SWD->WD_FORN
         WorkWD1->WD1_LOJA   := SWD->WD_LOJA
         WorkWD1->WD1_EMISS  := SWD->WD_EMISSAO
         WorkWD1->WD1_B1_COD := SWD->WD_B1_COD
         WorkWD1->WD1_B1_QTD := SWD->WD_B1_QTDE
         WorkWD1->WD1_VALOR  := SWD->WD_VALOR_R
         SYB->(dbSeek(xFilial("SYB")+SWD->WD_DESPESA))
         WorkWD1->WD1_DESC   := SYB->YB_DESCR
         WorkWD1->WD1_RECNO  := SWD->(RECNO())
         WorkWD1->(MsUnlock())

         WorkWD->(DbGoto(aRecsWD[i][2]))
         WorkWD->WD_NOTAGER := "S"
         WorkNF->NF_NOTAGER := "S"
         WorkNF->NF_FLAG := Space(2)
      NEXT i

      IncProc(STR0028+WorkNF->NF_DOC+STR0056+Left(WorkNF->NF_SERIE,nLenSDoc)+STR0057) //STR0028 "Nota: " //STR0056 " série: " //STR0057 " gerada"
      cLogNF += (STR0058+WorkNF->NF_DOC+STR0056+WorkNF->NF_SERIE+STR0059) //STR0058 "Nota Fiscal No. " //STR0056 " série: " //STR0059 " foi gerada!"
      cLogNF += (CHR(13)+CHR(10))

      aRecsWD    := {}
      aRecsWD1   := {}
      aNFDCapa   := {}
      aNFDDetail := {}
      WorkNF->(DbSkip())

   ENDDO //FIM DO LOOP DAS NOTAS
   lGerou_NFD := .T.

ELSEIF nOpc_NFD == 2   
   ProcRegua(WorkNF->(EasyRecCount()))
   SF1->(DbSetOrder(1))
   WHILE !WorkNF->(EOF())

      //GUARDAR OS RECNOS DOS ARQUIVOS TEMPORARIOS SWD
      aRecsWD := {}
      aRecsWD1:= {}

      cKeyNFD_NF := WorkNF->NF_FILIAL+WorkNF->NF_DOC+WorkNF->NF_SERIE+WorkNF->NF_FORN+WorkNF->NF_LOJA+WorkNF->NF_ESPECIE/*+WorkNF->NF_TIPONFD*/

      WorkWD->(DbSeek(cKeyNFD_NF))
      WHILE !WorkWD->(EOF()) 
         cKeyWD := WorkWD->WD_FILIAL + WorkWD->WD_DOC + WorkWD->WD_SERIE + WorkWD->WD_FORN + WorkWD->WD_LOJA + WorkWD->WD_ESPECIE
         If cKeyNFD_NF != cKeyWD
            exit
         EndIF   

         aAdd(aRecsWD,{WorkWD->WD_RECNO,WorkWD->(Recno())})
         WorkWD->(DbSkip())
      ENDDO
      WorkWD1->(DbSeek(cKeyNFD_NF))
      WHILE !WorkWD1->(EOF()) 
         cKeyWD1 := WorkWD1->WD1_FILIAL + WorkWD1->WD1_DOC + WorkWD1->WD1_SERIE + WorkWD1->WD1_FORN + WorkWD1->WD1_LOJA + WorkWD1->WD1_ESPEC 
         If cKeyNFD_NF != cKeyWD1
            Exit 
         EndIF
         aAdd( aRecsWD1, {WorkWD1->WD1_Recno, WorkWD1->(Recno())} )
         WorkWD1->(DbSkip())
      ENDDO

      //NOTA MARCADA PARA ESTORNO?
      IF EMPTY(WorkNF->NF_FLAG)
         WorkNF->(DbSkip())
         LOOP
      ENDIF

      //NOTA NÃO EXISTE NO COMPRAS?
      cChaveSf1:=xFilial("SF1")+AvKey(WorkNF->NF_DOC,"F1_DOC")+AvKey(WorkNF->NF_SERIE,"F1_SERIE")+AvKey(WorkNF->NF_FORN,"F1_FORNECE")+AvKey(WorkNF->NF_LOJA,"F1_LOJA")
      if aScan(aChaveSF1,cChaveSf1) > 0
         WorkNF->(DbSkip())
         LOOP
      EndIf   

      IF !SF1->(DbSeek(cChaveSF1))
         cLogNF += (STR0058+WorkNF->NF_DOC+STR0056+Left(WorkNF->NF_SERIE,nLenSDoc)+STR0060) //STR0058 "Nota Fiscal No. " //STR0056 " série: "  //STR0060 "não existe no módulo de compras"
         cLogNF += (CHR(13)+CHR(10))
         WorkNF->(DbSkip())
         LOOP
      ELSE //CASO EXISTA,VERIFICA SE ESTÁ CLASSIFICADA
         IF EMPTY(SF1->F1_STATUS)
            lNFDClassif := .F.
         ELSE
            lNFDClassif := .T.
         ENDIF
         aadd(aChaveSF1,cChaveSf1)
      ENDIF


      //VERIFICA POSSIBILIDADE DE ESTORNO NO COMPRAS
      IF lNFDClassif
         lCanDelF1 := MACanDelF1(SF1->( RecNo() ),,,,,,.F.,,.T.)
         IF !lCanDelF1
            cLogNF += (STR0058+SF1->F1_DOC+STR0056+Left(SF1->F1_SERIE,nLenSDoc)+STR0061) //STR0058 "Nota Fiscal No. " //STR0056 " série: " //STR0061 "não pôde ser estornada. Favor Verificar."
            cLogNF += (CHR(13)+CHR(10))
            WorkNF->(DbSkip())
            LOOP
         ENDIF
      ENDIF

      IncProc(STR0062+SF1->F1_DOC+STR0056+Left(SF1->F1_SERIE,nLenSDoc)) //STR0062 "Processando estorno da nota: " //STR0056 " série: "

      AADD(aNFDCapa,{"F1_DOC"         ,SF1->F1_DOC           ,NIL})   // NUMERO DA NOTA
      AADD(aNFDCapa,{"F1_SERIE"       ,SF1->F1_SERIE         ,NIL})   // SERIE DA NOTA
      AADD(aNFDCapa,{"F1_FORNECE"     ,SF1->F1_FORNECE       ,NIL})   // FORNECEDOR
      AADD(aNFDCapa,{"F1_LOJA"        ,SF1->F1_LOJA          ,NIL})   // LOJA DO FORNECEDOR
      AADD(aNFDCapa,{"F1_TIPO"        ,SF1->F1_TIPO          ,NIL})   // N - NORMAL
      IF(EasyEntryPoint("EICDI158"),Execblock("EICDI158",.F.,.F.,"DI158NFDGera_AddSF1"),) //SVG - 13/12/2010
      cKeyNFD_F1 := xFilial("SD1") + SF1->F1_DOC + SF1->F1_SERIE + SF1->F1_FORNECE + SF1->F1_LOJA

      SD1->(DbSeek(cKeyNFD_F1))
      WHILE !SD1->(EOF()) .AND. cKeyNFD_F1 == SD1->D1_FILIAL + SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA

         aNFDItem := {}

         AADD(aNFDItem,{"D1_DOC"    ,SD1->D1_DOC     ,NIL})
         AADD(aNFDItem,{"D1_SERIE"  ,SD1->D1_SERIE   ,NIL})
         AADD(aNFDItem,{"D1_FORNECE",SD1->D1_FORNECE ,NIL})
         AADD(aNFDItem,{"D1_LOJA"   ,SD1->D1_LOJA    ,NIL})
         IF(EasyEntryPoint("EICDI158"),Execblock("EICDI158",.F.,.F.,"DI158NFDGera_WhileSD1"),) //SVG - 13/12/2010
         AADD(aNFDDetail,aClone(aNFDItem))
         SD1->(DbSkip())

      ENDDO // FIM DO LOOP DOS ITENS

      aNFDItem   := {}

      //GERAÇÃO DA NOTA NO COMPRAS
      IF lNFDClassif
         MSExecAuto({|x,y,z| MATA103(x,y,z)},aNFDCapa,aNFDDetail,20)
      ELSE
         MSExecAuto({|x,y,z| MATA140(x,y,z)},aNFDCapa,aNFDDetail,5)
      ENDIF

      IF lMSErroAuto
         MostraErro()
         WorkNF->(DbSkip())
         LOOP
      ENDIF

      aAdd(aRecsNFEst,WorkNF->(Recno()))

      FOR i := 1 To LEN(aRecsWD)

         WorkWD->(DbGoTo(aRecsWD[i][2]))
         WorkWD->WD_B1_COD  := ""
         WorkWD->WD_DOC     := ""
         WorkWD->WD_SERIE   := ""
         WorkWD->WD_ESPECIE := ""
         WorkWD->WD_TIPONFD := ""
         WorkWD->WD_EMISSAO := CTOD("  /  /  ")
         WorkWD->WD_B1_QTDE := 0
         WorkWD->WD_NOTAGER := "N"

      NEXT i

      // NCF - 19/01/2010
      FOR i := 1 TO LEN(aRecsWD1)
         SWD->(DbGoto(aRecsWD1[i][1]))         
         SWD->(RecLock("SWD",.F.))
            SWD->WD_B1_COD  := ""
            SWD->WD_DOC     := ""
            SWD->WD_SERIE   := ""
            SWD->WD_ESPECIE := ""
            SWD->WD_TIPONFD := ""
            SWD->WD_EMISSAO := CTOD("  /  /  ")
            SWD->WD_B1_QTDE := 0
         SWD->(MsUnlock())

         WorkWD1->(DbGoto(aRecsWD1[i][2])) // NCF - 19/01/2010
         WorkWD1->(RecLock("WorkWD1",.F.))
         WorkWD1->(DbDelete())
         WorkWD1->(MsUnLock())
      NEXT i

      WorkNF->NF_NOTAGER := "N"
      WorkNF->NF_FLAG    := Space(2)

      IncProc(STR0028+WorkNF->NF_DOC+STR0056+Left(WorkNF->NF_SERIE,nLenSDoc)+STR0063) //STR0028 "Nota" //STR0056 " série: " //STR0063 " estornada "
      cLogNF += (STR0057+WorkNF->NF_DOC+STR0056+Left(WorkNF->NF_SERIE,nLenSDoc)+STR0064)  //STR0058 "Nota Fiscal No. "  //STR0056 " série: " //STR0064 " foi estornada!"
      cLogNF += (CHR(13)+CHR(10))

      aRecsWD    := {}
      aRecsWD1   := {}
      aNFDCapa   := {}
      aNFDDetail := {}
      WorkNF->(DbSkip())

   ENDDO //FIM DO LOOP DAS NOTAS

   FOR i := 1 TO LEN(aRecsNFEst)
      WorkNF->(DbGoTo(aRecsNFEst[i]))
      WorkNF->(DbDelete())
   NEXT i
   
   lGerou_NFD := .T.
ENDIF

END TRANSACTION

SWD->(DBCommit())
RestOrd(aORdSWD)
if nOpc_NFD == 2
   DI158GetDados()
EndIf   
cTexto := STR0065+CHR(13)+CHR(10)+cTexto //STR0065 "Log da Geração"
__cFileLog := MemoWrite(Criatrab(,.f.)+".LOG",cTexto)

Define FONT oFont NAME "Mono AS" Size 5,12   //6,15
   Define MsDialog oDlg Title STR0066 From 3,0 to 340,417 Pixel //STR0066 "Geração concluida."

   @ 5,5 Get oMemo  Var cLogNF MEMO Size 200,145 Of oDlg Pixel
   oMemo:bRClicked := {||AllwaysTrue()}
   oMemo:oFont:=oFont

   Define SButton  From 153,175 Type 1 Action oDlg:End() Enable Of oDlg Pixel //Apaga
   Define SButton  From 153,145 Type 13 Action (cFile:=cGetFile(cMask,""),If(cFile="",.t.,MemoWrite(cFile,cTexto))) ENABLE OF oDlg PIXEL //Salva e Apaga //"Salvar Como..."
Activate MsDialog oDlg Center

Return .T.

Function DI158GetDados()

WorkWD->(avzap())
WorkWD1->(avzap())
WorkNF->(avzap())

         cQuery := "SELECT WD.WD_FILIAL,  WD.WD_HAWB,    WD.WD_DOC,     WD.WD_SERIE,   WD.WD_FORN,    WD.WD_LOJA,   WD.WD_ESPECIE, WD.WD_TIPONFD, "+;
                          "WD.WD_EMISSAO, WD.WD_VALOR_R, WD.WD_DESPESA, WD.WD_DES_ADI, WD.WD_VALOR_R, WD.WD_VALOR_R,WD.WD_BASEADI,"+;
                          "WD.WD_GERFIN,  WD.WD_NF_COMP, WD.WD_SE_NFC,  WD.WD_DOCTO,   WD.WD_DA,      WD.WD_B1_COD, WD.WD_B1_QTDE, WD.R_E_C_N_O_"


         IF !EMPTY(cProcesso) .OR. !EMPTY(dDtInic) .OR.  !EMPTY(dDtFinal)

            cCond := " FROM (SELECT W6_FILIAL, W6_HAWB FROM "+RetSqlName("SW6")+" W6"+;
                     " WHERE W6.D_E_L_E_T_ = ' ' "

            IF !EMPTY(cProcesso)
               cCond += " AND W6_FILIAL = '"+ xFilial("SW6") +"' AND W6_HAWB = '"+ AVKEY(cProcesso,"W6_HAWB")+"'"
            ENDIF

            IF !EMPTY(dDtInic)
               cCond += " AND W6_DT_HAWB >= '"+ DTOS(dDtInic) +"'"
            ENDIF

            IF !EMPTY(dDtFinal)
               cCond += " AND W6_DT_HAWB <= '"+ DTOS(dDtFinal) +"'"
            ENDIF

            cCond += " GROUP BY W6_FILIAL,W6_HAWB) W6 "
            cCond += " INNER JOIN "+RetSqlName("SWD")+" WD"
            cCond += " ON W6.W6_FILIAL = WD_FILIAL AND W6.W6_HAWB = WD_HAWB"
            cCond += " WHERE WD.D_E_L_E_T_ = ' ' "
            cCond += " AND (WD_DESPESA = '102' OR WD_DESPESA = '103' OR ""
            cCond += " (WD_DESPESA >= '200'"     //Despesas 1 e 9 são reservadas para uso interno no sistema ### THTS - 14/06/2017 - TE-5981 - Liberado despesas 2 para geração de NF
            cCond += " AND WD_DESPESA <= '899'))"

         ELSE
            cCond := " FROM "+RetSqlName("SWD")+" WD WHERE WD.WD_FILIAL = '"+xFilial("SWD")+"'"
            cCond += " AND WD.D_E_L_E_T_ = ' ' "
             cCond += " AND (WD_DESPESA = '102' OR WD_DESPESA = '103' OR ""
            cCond += " (WD_DESPESA >= '200'"     //Despesas 1 e 9 são reservadas para uso interno no sistema ### THTS - 14/06/2017 - TE-5981 - Liberado despesas 2 para geração de NF
            cCond += " AND WD_DESPESA <= '899'))"
         ENDIF

         IF !EMPTY(cFornece)
            cCond += " AND WD.WD_FORN = '"+ AVKEY(cFornece,"WD_FORN") +"'"
         ENDIF

         IF !EMPTY(cDespesa) .And. EMPTY(cDespesaAt)
            cCond += " AND WD_DESPESA = '"+cDespesa+"'"
         ENDIF

         IF !EMPTY(cDespesaAt) .AND. EMPTY(cDespesa)//LRS- 11/08/2014
            MSGALert(STR0069) //LRS- 11/08/2014 - Insira o campo Despesa de:
            Break
         ENDIF

         IF !EMPTY(cDespesaAt) .AND. !EMPTY(cDespesa)//LRS- 11/08/2014
            cCond += " AND WD_DESPESA  >= "+cDespesa
            cCond += " AND WD_DESPESA  <= "+cDespesaAt
         ENDIF

         cQuery:=ChangeQuery(cQuery+cCond)

         TcQuery cQuery ALIAS "QRY" NEW

         TcSetField("QRY","WD_EMISSAO","D", AVSX3("WD_EMISSAO",3), AVSX3("WD_EMISSAO",4)) //Data de Emissao
         TcSetField("QRY","WD_DES_ADI","D", AVSX3("WD_DES_ADI",3), AVSX3("WD_DES_ADI",4)) //Data

         QRY->(DbGoTop())

         WHILE QRY->(!EOF())

            //nRec_SWD  := SWD->(Recno())
            cKeyNF_QRY:= QRY->WD_FILIAL + QRY->WD_DOC + QRY->WD_SERIE + QRY->WD_FORN + QRY->WD_LOJA + QRY->WD_ESPECIE //
            If nAgrupa == 2
               cKeyNF_QRY += QRY->WD_DESPESA
            EndIF
            WorkNF->(DbGoTop())

            IF !WorkNF->(DBSeek(cKeyNF_QRY))

               WorkNF->(RecLock("WorkNF",.T.))
               WorkNF->NF_FILIAL := QRY->WD_FILIAL
               WorkNF->NF_DOC    := QRY->WD_DOC
               WorkNF->NF_SERIE  := QRY->WD_SERIE
               WorkNF->NF_FORN   := QRY->WD_FORN
               WorkNF->NF_LOJA   := QRY->WD_LOJA
               WorkNF->NF_ESPECIE:= QRY->WD_ESPECIE
               WorkNF->NF_TIPONFD:= QRY->WD_TIPONFD
               WorkNF->NF_DOC    := QRY->WD_DOC
               WorkNF->NF_EMISSAO:= QRY->WD_EMISSAO
               WorkNF->NF_VALOR_R:= QRY->WD_VALOR_R
               WorkNF->NF_FLAG   := Space(2)
               If nAgrupa == 2
                  WorkNF->NF_DESPESA := QRY->WD_DESPESA
               endIf   
               WorkNF->NF_NOTAGER:= IF(EMPTY(QRY->WD_DOC),"N","S")
               WorkNF->(MsUnlock())

               WorkWD->(RecLock("WorkWD",.T.))
               AvReplace("QRY","WorkWD")
               WorkWD->WD_NOTAGER:= IF(EMPTY(QRY->WD_DOC),"N","S")
               WorkWD->WD_RECNO := QRY->R_E_C_N_O_
               SYB->(dbSeek(xFilial("SYB")+WorkWD->WD_DESPESA))
               WorkWD->WD_DESCDES := SYB->YB_DESCR
               WorkWD->(MsUnlock())

            ELSE
               WorkNF->NF_VALOR_R += QRY->WD_VALOR_R
               WorkWD->(RecLock("WorkWD",.T.))
               AvReplace("QRY","WorkWD")
               WorkWD->WD_NOTAGER:= IF(EMPTY(QRY->WD_DOC),"N","S")
               SYB->(dbSeek(xFilial("SYB")+WorkWD->WD_DESPESA))
               WorkWD->WD_DESCDES := SYB->YB_DESCR
               WorkWD->WD_RECNO  := QRY->R_E_C_N_O_
               WorkWD->(MsUnlock())
            ENDIF

            IF !EMPTY(WorkWD->WD_DOC) .AND. !EMPTY(WorkWD->WD_SERIE) .AND. ;
               !WorkWD1->(DbSeek(xFilial("SWD") + WorkWD->WD_DOC + WorkWD->WD_SERIE + WorkWD->WD_FORN + WorkWD->WD_LOJA + WorkWD->WD_ESPECIE))

               cQuery2 := "SELECT WD.WD_FILIAL,  WD.WD_HAWB,    WD.WD_DOC,     WD.WD_SERIE,   WD.WD_FORN,    WD.WD_LOJA,   WD.WD_ESPECIE, WD.WD_TIPONFD, "+;
                                 "WD.WD_EMISSAO, WD.WD_VALOR_R, WD.WD_DESPESA, WD.WD_DES_ADI, WD.WD_VALOR_R, WD.WD_VALOR_R,WD.WD_BASEADI,"+;
                                 "WD.WD_GERFIN,  WD.WD_NF_COMP, WD.WD_SE_NFC,  WD.WD_DOCTO,   WD.WD_DA,      WD.WD_B1_COD, WD.WD_B1_QTDE, WD.R_E_C_N_O_"

               cCond2 := " FROM "+RetSqlName("SWD")+" WD WHERE WD.WD_FILIAL = '"+xFilial("SWD")+"'"
               cCond2 += " AND WD_DOC = '"+WorkWD->WD_DOC+"'"
               cCond2 += " AND WD_SERIE = '"+WorkWD->WD_SERIE+"'"
               cCond2 += " AND WD_FORN = '"+WorkWD->WD_FORN+"'"
               cCond2 += " AND WD_LOJA = '"+WorkWD->WD_LOJA+"'"
               cCond2 += " AND WD_ESPECIE = '"+WorkWD->WD_ESPECIE+"'"
               cCond2 += " AND WD.D_E_L_E_T_ = ' ' "

               cQuery2:=ChangeQuery(cQuery2+cCond2)

               TcQuery cQuery2 ALIAS "QRY2" NEW

               TcSetField("QRY2","WD_EMISSAO","D", AVSX3("WD_EMISSAO",3), AVSX3("WD_EMISSAO",4)) //Data de Emissao
               TcSetField("QRY2","WD_DES_ADI","D", AVSX3("WD_DES_ADI",3), AVSX3("WD_DES_ADI",4)) //Data

               QRY2->(DbGoTop())

               WHILE QRY2->(!EOF())
                  WorkWD1->(RecLock("WorkWD1",.T.))
                  WorkWD1->WD1_FILIAL := QRY2->WD_FILIAL
                  WorkWD1->WD1_HAWB   := QRY2->WD_HAWB
                  WorkWD1->WD1_DESPE  := QRY2->WD_DESPESA
                  WorkWD1->WD1_DOC    := QRY2->WD_DOC
                  WorkWD1->WD1_SERIE  := QRY2->WD_SERIE
                  WorkWD1->WD1_ESPEC  := QRY2->WD_ESPECIE
                  WorkWD1->WD1_FORN   := QRY2->WD_FORN
                  WorkWD1->WD1_LOJA   := QRY2->WD_LOJA
                  WorkWD1->WD1_TIPONF := QRY2->WD_TIPONFD
                  WorkWD1->WD1_EMISS  := QRY2->WD_EMISSAO
                  WorkWD1->WD1_B1_COD := QRY2->WD_B1_COD
                  WorkWD1->WD1_B1_QTD := QRY2->WD_B1_QTDE
                  WorkWD1->WD1_VALOR  := QRY2->WD_VALOR_R
                  WorkWD1->WD1_RECNO  := QRY2->R_E_C_N_O_
                  SYB->(dbSeek(xFilial("SYB")+QRY2->WD_DESPESA))
                  WorkWD1->WD1_DESC   := SYB->YB_DESCR
                  WorkWD1->(MsUnlock())
                  QRY2->(DbSkip())
               ENDDO
               QRY2->(DbCloseArea())
            ENDIF

            QRY->(DBSkip())
         ENDDO

         QRY->(DbCloseArea())

Return .t.      
//------------------------------------------------------------------------------------//
//                     FIM DO PROGRAMA EICDI158.PRW
//------------------------------------------------------------------------------------//
