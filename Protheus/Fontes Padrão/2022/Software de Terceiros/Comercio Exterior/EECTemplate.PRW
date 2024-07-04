#Include 'Protheus.ch'
#Include "Average.ch"
#Include "FWMVCDEF.CH"
#Include "APWizard.CH"
#Include "EEC.CH"

Function ETplExpCafe(oTemplate)

oTemplate:cModulo     := "EEC"

oTemplate:cTitulo     := "Exportador de Café"

oTemplate:cDescription:= "Template para adequacao do menu do sistema para empresas exportadoras de café."

oTemplate:aUpdates    := {"UESDGFWI"}

oTemplate:aParTela    := {"MV_AVG0117","MV_AVG0034"}

oTemplate:aParValues  := {{"MV_AVG0114",".T."},;
                          {"MV_AVG0120",".T."},;
                          {"MV_AVG0029",".T."}}

oTemplate:cCondSucesso:= "EECFlags('CAFE')"

oTemplate:oMenu:TableData("MENU",{"SIGAEEC","EECAT150"  ,{"Atualizações","Cadastros"},               ,{"Cotacao Da Bolsa"           ,"Cotizac. de Bolsa"            ,"Stock Exch. Quote"           },"1" ,{"EX7"},"xxxxxxxxxx","0"  })
oTemplate:oMenu:TableData("MENU",{"SIGAEEC","EECQUAL100",{"Atualizações","Cadastros"},               ,{"Qualidades"                 ,"Qualidades"                   ,"Qualidades"                  },"1" ,{"EXW"},"xxxxxxxxxx","0"  })
oTemplate:oMenu:TableData("MENU",{"SIGAEEC","EECPEN100" ,{"Atualizações","Cadastros"},               ,{"Peneiras"                   ,"Peneiras"                     ,"Peneiras"                    },"1" ,{"EXX"},"xxxxxxxxxx","0"  })
oTemplate:oMenu:TableData("MENU",{"SIGAEEC","EECTIP100" ,{"Atualizações","Cadastros"},               ,{"Tipos de Café"              ,"Tipos de Café"                ,"Tipos de Café"               },"1" ,{"EXY"},"xxxxxxxxxx","0"  })
oTemplate:oMenu:TableData("MENU",{"SIGAEEC","EECBEB100" ,{"Atualizações","Cadastros"},               ,{"Bebidas"                    ,"Bebidas"                      ,"Bebidas"                     },"1" ,{"EY4"},"xxxxxxxxxx","0"  })
oTemplate:oMenu:TableData("MENU",{"SIGAEEC","EECREJ100" ,{"Atualizações","Cadastros"},               ,{"Tipos de Rejeição"          ,"Tipos de Rejeição"            ,"Tipos de Rejeição"           },"1" ,{"EY1"},"xxxxxxxxxx","0"  })
oTemplate:oMenu:TableData("MENU",{"SIGAEEC","EECFIXPRE" ,{"Atualizações","Cadastros"},               ,{"Condições de Fix. de Preço" ,"Condições de Fix. de Preço"   ,"Condições de Fix. de Preço"  },"1" ,{"EY0"},"xxxxxxxxxx","0"  })
oTemplate:oMenu:TableData("MENU",{"SIGAEEC","EECCADFND" ,{"Atualizações","Cadastros"},               ,{"First Notice Day"           ,"First Notice Day"             ,"First Notice Day"            },"1" ,{"EY4"},"xxxxxxxxxx","0"  })

oTemplate:oMenu:TableData("MENU",{"SIGAEEC","EECAM100"  ,{"Atualizações","Pedido Export."},           ,{"Amostras"                   ,"Amostras"                     ,"Amostras"                    },"1" ,{"EXU","EXV"},"xxxxxxxxxx","0"  })

oTemplate:oMenu:TableData("MENU",{"SIGAEEC","AE109WASHOUT"   ,{"Atualizações","Embarque"},             ,{"Wash-Out"                   ,"Wash-Out"                     ,"Wash-Out"                    },"1" ,{"EEC","EE9"},"xxxxxxxxxx","0"  })
oTemplate:oMenu:TableData("MENU",{"SIGAEEC","AE109RvWashOut" ,{"Atualizações","Embarque"},             ,{"Wash-Out RV"                ,"Wash-Out RV"                  ,"Wash-Out RV"                 },"1" ,{"EEC","EE9"},"xxxxxxxxxx","0"  })
                                                                                                

Return

/*
Programa   : ETpImportCSV()
Objetivo   : Templete para importação de dados de arquivo CSV. 
Retorno    : Nil
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 29/06/2012 - 10:00
Parametros :
*/
Function ETpImportCSV(oTemplate)
oTemplate:cModulo     := "EEC"

oTemplate:cTitulo     := "Importação de dados contidos no arquivo no formato CSV(Logix Comex)"

oTemplate:cDescription:= "Template para importar registros de um arquivo CSV para a tabela Protheus."

oTemplate:aUpdates    := {"UETFKUBL"}

oTemplate:aParTela    := {}

oTemplate:aParValues  := {}

oTemplate:aVarTela    := {} 

oTemplate:cCondSucesso:= ""
//vetor do aVarTela: {nome variavel, valor inicial, descrição da tela, tipo do objeto}
//Tipos de objetos permitidos: cGetFile, CheckBox , tGet ou vazio 
aAdd(oTemplate:aVarTela,{"cDWDir"      ,Space(100)  ,"Selecione diretorio CSV:"        ,"cGetFile"     })
aAdd(oTemplate:aVarTela,{"lDWZap"      ,".F."       ,"Deseja limpar dados das tabelas?","CheckBox"     })
oTemplate:oMenu:aChamados := {{17,{|o| ChamaFuncao(o,oTemplate) }}}

Return

/*
Programa   : ChamaFuncao()
Objetivo   : Chamda da função de LogixToProtheus. 
Retorno    : Nil
Autor      : Fabio Satoru Yamamoto
Data/Hora  : 29/06/2012 - 10:00
Parametros : 
*/
Static Function ChamaFuncao(o)
o:lError:= .F.
   If !o:lSimula //Para não executar na verificação do templete
      If Empty (Directory(AllTrim(cDWDir)+"*.CSV") )  
         o:lError:= .T.
         //aTmplObjs[2]:CLOGATU := "Diretorio não contem arquivo CSV."+ENTER
      End If

      If  o:lError == .F.
         LogixToProtheus(o, cDWDir,lDWZap )
      End If
      
   EndIf
Return


Function ETplIntMsgUnica(oTemplate)

oTemplate:cModulo     := "EEC"

oTemplate:cTitulo     := "Integração SIGAEEC via mensagem única"

oTemplate:cDescription:= "Template para configuração da integração do módulo de exportação (SIGAEEC) via mensagem única."

oTemplate:aUpdates    := {"UETEOVLT"}

oTemplate:aParTela    := {"MV_AVG0205","MV_AVG0206","MV_AVG0207","MV_AVG0208","MV_AVG0209","MV_AVG0210","MV_AVG0215","MV_AVG0216","MV_AVG0220"}

oTemplate:aParValues  := {{"MV_EECI010",".T."},;
                          {"MV_AVG0131",".F."}}

oTemplate:cCondSucesso:= "AvFlags('EEC_LOGIX')"


oTemplate:oMenu:TableData("MENU",{"SIGAEEC","EECNF400",{"Atualizações","Embarque"}, "EECNU400"    ,{"Nota Fiscal de Saida","Salida de la factura","Invoice Output"},"1" ,{"EEM","EES"},"xxxxxxxxxx","0"  })

oTemplate:oMenu:TableStruct("XX4",{"XX4_FILIAL"  , "XX4_ROTINA", "XX4_MODEL"                                   , "XX4_DESCRI"                     , "XX4_SENDER", "XX4_RECEIV", "XX4_METODO", "XX4_TPOPER", "XX4_EXPFIL", "XX4_LOADRE", "XX4_LOADSE", "XX4_CHANEL", "XX4_UNMESS", "XX4_XSD"                                            , "XX4_FILEXE", "XX4_CHGXML"},1)
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAC120"  , "ITEM"                                        , "ITEM"                           , "2"         , "1"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\ITEM_1_000"                                  , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAT170"  , "PACKAGING"                                   , "PACKAGING"                      , "2"         , "1"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\PACKAGING_1_000"                             , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAP100"  , "SALESORDER"                                  , "PEDIDO DE EXPORTACAO - LOGIX"   , "2"         , "1"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\SALESORDER_1_000"                            , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAT140"  , "CURRENCYQUOTATION"                           , "CURRENCYQUOTATION"              , "2"         , "1"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\CURRENCYQUOTATION_1_000"                     , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EICTU100"  , "UNITOFMEASURECONVERSION"                     , "UNITOFMEASURECONVERSION"        , "1"         , "1"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\UNITOFMEASURECONVERSION_1_000"               , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAC175"  , "CUSTOMERVENDOR"                              , "CUSTOMERVENDOR"                 , "2"         , "1"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\CUSTOMERVENDOR_1_000"                        , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAC115"  , "COMPANY"                                     , "COMPANY"                        , "2"         , "1"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\COMPANY_1_000"                               , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAS125"  , "UNITOFMEASURE"                               , "UNITOFMEASURE"                  , "2"         , "1"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\UNITOFMEASURE_1_000"                         , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAT171"  , "PACKAGINGRELATIONSHIP"                       , "PACKAGINGRELATIONSHIP"          , "2"         , "1"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\PACKAGINGRELATIONSHIP_1_000"                 , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECNF400"  , "INVOICE"                                     , "Nota fiscal de Saida"           , "2"         , "1"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\INVOICE_1_001"                               , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF210"  , "ACCOUNTRECEIVABLEDOCUMENT"                   , "ACCOUNTRECEIVABLEDOCUMENT"      , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , ""                                                   , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAC110"  , "BANK"                                        , "BANCOS"                         , "2"         , "1"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\BANK_1_000"                                  , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF214"  , "ACCOUNTPAYABLEDOCUMENT"                      , "TITULO A PAGAR (DESPESAS INT.)" , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\ACCOUNTPAYABLEDOCUMENT_1_000"                , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF223"  , "SHIPMENTOFEXPORTINVOICE"                     , "BAIXA DO CPV"                   , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\SHIPMENTOFEXPORTINVOICE_1_000"               , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF213"  , "ACCOUNTRECEIVABLEDOCUMENTDISCHARGE"          , "BAIXA DO CAMBIO PRONTO"         , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "\REQUESTS\ACCOUNTRECEIVABLEDOCUMENTDISCHARGE_1_000" , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF215"  , "ACCOUNTPAYABLEDOCUMENTDISCHARGE"             , "BAIXA DE DESPESAS INTERNAC."    , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , ""                                                   , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF212"  , "ACCOUNTRECEIVABLEDOCUMENT"                   , "ADIANTAMENTO A RECEBER"         , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\ACCOUNTRECEIVABLEDOCUMENT_1_000"             , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF216"  , "ACCOUNTPAYABLEDOCUMENT"                      , "DESPESAS NACIONAIS"             , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\ACCOUNTPAYABLEDOCUMENT_1_000"                , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF224"  , "ACCOUNTINGENTRY"                             , "VARIACAO CAMBIAL DE NF"         , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\ACCOUNTINGENTRY_1_000"                       , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF217"  , "BANKTRANSACTIONS"                            , "MOVIMENTO BANCARIO"             , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\BANKTRANSACTIONS_1_000"                      , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF227"  , "ACCOUNTRECEIVABLEDOCUMENTDISCHARGE"          , "COMPENSACAO DO ADIANTAMENTO"    , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "REQUESTS\ACCOUNTRECEIVABLEDOCUMENTDISCHARGE_1_000"  , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF218"  , "ACCOUNTPAYABLEDOCUMENT"                      , "ACCOUNTPAYABLEDOCUMENT"         , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\ACCOUNTPAYABLEDOCUMENT_1_000"                , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF226"  , "ACCOUNTPAYABLEDOCUMENTDISCHARGE"             , "ACCOUNTPAYABLEDOCUMENTDISCHARG" , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "REQUESTS\ACCOUNTPAYABLEDOCUMENTDISCHARGE_1_000"     , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECREG85"  , "SINTEGRAREGISTER-85-86"                      , "SINTEGRAREGISTER-85-86"         , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\SINTEGRAREGISTER-85-86_1_000"                , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF225"  , "ACCOUNTINGENTRY"                             , "CONTAB. CONTRATOS"              , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\ACCOUNTINGENTRY_1_000"                       , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF229"  , "REVERSALOFACCOUNTPAYABLEDOCUMENTDISCHARGE"   , "ESTORNO FINANCIAMENTO"          , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , ""                                                   , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF230"  , "REVERSALOFACCOUNTRECEIVABLEDOCUMENTDISCHARGE", "ESTORNO DA COMPENSACAO DE ADIA" , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , ""                                                   , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF221"  , "REVERSALOFACCOUNTRECEIVABLEDOCUMENTDISCHARGE", "ESTORNO BAIXA TITULO A RECEBER" , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , ""                                                   , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAF222"  , "REVERSALOFACCOUNTPAYABLEDOCUMENTDISCHARGE"   , "ESTORNO BAIXA TITULO A PAGAR"   , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , ""                                                   , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAT141"  , "CURRENCYQUOTATION"                           , "TAXA FISCAL"                    , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\CURRENCYQUOTATION_1_000"                     , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAT142"  , "CURRENCYQUOTATION"                           , "TAXA COMPRA"                    , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\CURRENCYQUOTATION_1_000"                     , ""         , ""})
oTemplate:oMenu:TableData(  "XX4",{xFilial('XX4'), "EECAT143"  , "CURRENCYQUOTATION"                           , "TAXA VENDA"                     , "1"         , "2"         , "1"         , "1"         , ""          , ""          , ""          , "2"         , "1"         , "EVENTS\CURRENCYQUOTATION_1_000"                     , ""         , ""})                                                                                 

Return