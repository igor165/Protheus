#INCLUDE "PROTHEUS.CH"
#INCLUDE "AVERAGE.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "shell.ch"
#Include "fileio.ch"

#DEFINE EXT_XML	".xml"
#DEFINE EXT_INI	".ini"
#DEFINE EXT_RET	".ret"

#DEFINE GERADO     "N"
#DEFINE ENVIADO    "E"
#DEFINE RECEBIDO   "R"
#DEFINE PROCESSADO "P"
#DEFINE CANCELADO  "C"

#Define INC_REG    "1" //1=Inclusão Registro
#Define RET_REG	   "2" //2=Retificação de Registro
#Define INC_ADI    "3" //3=Inclusão Aditivo
#Define RET_ADI    "4" //4=Retificação Aditivo
#Define INC_PAG    "5" //5=Inclusão Pagamento
#Define CAN_PAG    "6" //6=Cancel. Pagamento
#Define RET_PAG    "7" //7=Retificação Pagamento
*-----------------------------------------------------*
Function ESSCI103(cTipoOpe,cNumLote,oError)
*-----------------------------------------------------*
Local aRet := {}
Local i
Local cSeq := "" , cNameINI := "", cNameSrv := "",cNameRet := "", cSeqXML := ""
Local oINI, oConexao, oModulo, oArquivo, oSrv
Local aServices := {}
Local aProcsAdt := {}
Local aOrd_EL
Local oINIServ
Local cRetINI
Local cPrefixExe
Local cTipoProc := ""
Local lIntJava := CI100IsJava()
Private cLoteAtual := cNumLote

oConexao := Erec():New()
oModulo  := Erec():New()
oArquivo := Erec():New()
oSrv     := Erec():New()

oConexao:AddField("pag_login","http://www.siscoserv.mdic.gov.br/g33159SCS/jsp/logon.jsp")

If cTipoOpe == INC_REG .Or. cTipoOpe == RET_REG

   EL3->(dbSetOrder(2))
   EL3->(dbSeek(xFilial()+cNumLote))
   cTipoProc := EL3->EL3_TPPROC
   aOrd_EL := SaveOrd({"EL3","EL4","EL5","EL6"})
   i := 1
   Do While EL3->( !Eof() .AND. EL3_FILIAL+EL3_IDLOTE == xFilial()+cNumLote)
      aAdd(aServices,SS103GerIni( cTipoOpe,EL3->EL3_TPPROC,EL3->EL3_REGIST,EL3->EL3_SQEVCP,,,Alltrim(Str(i))) )
      i++
      EL3->(dbSkip())
   EndDo

   RestOrd(aOrd_EL,.T.)

   IF cTipoProc == "A"

      oSrv:AddField("quant_ras",Len(aServices))
      oSrv:AddField("","")//PULAR LINHA

      For i:=1 To Len(aServices)
         oSrv:AddField("RAS_"+Alltrim(Str(i)),aServices[i][1][2])
      Next i

   ELSEIF cTipoProc == "V"

      oSrv:AddField("quant_rvs",Len(aServices))
      oSrv:AddField("","")//PULAR LINHA

      For i:=1 To Len(aServices)
         oSrv:AddField("RVS_"+Alltrim(Str(i)),aServices[i][1][2])
      Next i

   ENDIF

   oIniserv := Einfo():New("QUANTIDADE",oSrv)

   cNameRet   := cNumLote
   cNameSrv   := cNumLote

   If cTipoProc == "V"
      cNameINI := "RVS_CS_WEB"
      cPrefixExe := "EASY_RVS"//"RVS_CS"
   Else
      cNameINI := "RAS_CS_WEB"
      cPrefixExe := "EASY_RAS"//"RAS_CS"
   EndIf

   cNameRet += /*"RETORNO"+*/EXT_RET

   IF cTipoProc == "V"
      IF cTipoOpe == INC_REG
         oConexao:AddField("pag_reg_inc","https://wwwc.siscoserv.mdic.gov.br/Siscoserv/registroIncluir.do")
         oArquivo:AddField("rvs_cs_cad","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("rvs_cs_ret"    ,"")
         oArquivo:AddField("rvs_cs_adt_cad","")
         oArquivo:AddField("rvs_cs_adt_ret","")
         oArquivo:AddField("rvs_cs_fat_cad","")
         oArquivo:AddField("rvs_cs_fat_can","")
         oArquivo:AddField("rvs_retorno","/"+cNameRet)
      ELSEIF cTipoOpe == RET_REG
         oConexao:AddField("pag_reg_ret","https://wwwc.siscoserv.mdic.gov.br/Siscoserv/registroRetificar.do")
         oArquivo:AddField("rvs_cs_cad"    ,"")
         oArquivo:AddField("rvs_cs_ret","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("rvs_cs_adt_cad","")
         oArquivo:AddField("rvs_cs_adt_ret","")
         oArquivo:AddField("rvs_cs_fat_cad","")
         oArquivo:AddField("rvs_cs_fat_can","")
         oArquivo:AddField("rvs_retorno","/"+cNameRet)
      ENDIF
   ELSE
      IF cTipoOpe == INC_REG
         oConexao:AddField("pag_reg_inc","https://wwwc.siscoserv.mdic.gov.br/SiscoservAqui/registroIncluir.do")
         oArquivo:AddField("ras_cs_cad","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("ras_cs_ret"    ,"")
         oArquivo:AddField("ras_cs_adt_cad","")
         oArquivo:AddField("ras_cs_adt_ret","")
         oArquivo:AddField("ras_cs_fat_cad","")
         oArquivo:AddField("ras_cs_fat_can","")
         oArquivo:AddField("ras_retorno","/"+cNameRet)
      ELSEIF cTipoOpe == RET_REG
         oConexao:AddField("pag_reg_ret","https://wwwc.siscoserv.mdic.gov.br/SiscoservAqui/registroRetificar.do")
         oArquivo:AddField("ras_cs_cad"    ,"")
         oArquivo:AddField("ras_cs_ret","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("ras_cs_adt_cad","")
         oArquivo:AddField("ras_cs_adt_ret","")
         oArquivo:AddField("ras_cs_fat_cad","")
         oArquivo:AddField("ras_cs_fat_can","")
         oArquivo:AddField("ras_retorno","/"+cNameRet)
      ENDIF
   ENDIF

ElseIf cTipoOpe == INC_ADI .Or. cTipoOpe == RET_ADI
   EL4->(dbSetOrder(2))
   If EL4->(dbSeek(xFilial()+cNumLote))
      cTipoProc := EL4->EL4_TPPROC
      aOrd_EL := SaveOrd({"EL3","EL4","EL5","EL6"})
      i := 0
      Do While EL4->( !Eof() .AND. EL4_FILIAL+EL4_IDLOTE == xFilial()+cNumLote)
         //RRC - 09/09/2013 - Faz o envio de todos os serviços de aditivo do mesmo processo dentro do lote:
         //Incrementa a cada sequência de aditivo
         If !(aScan(aProcsAdt,{|x|x == EL4->EL4_REGIST+EL4->EL4_SEQAD}) > 0)
            aAdd(aProcsAdt,EL4->EL4_REGIST+EL4->EL4_SEQAD)
            i++
            //oINIServ    := SS103GerIni( cTipoOpe,EL4->EL4_TPPROC,EL4->EL4_REGIST,EL4->EL4_SQEVCP,,,Alltrim(Str(i)) )
            aAdd(aServices,SS103GerIni( cTipoOpe,EL4->EL4_TPPROC,EL4->EL4_REGIST,EL4->EL4_SQEVCP,EL4->EL4_SEQAD,,Alltrim(Str(i))) )
         EndIf
         EL4->(dbSkip())
      EndDo
   Else
      oError:Error("Processo não localizado neste lote.")
   EndIf
   IF cTipoProc == "A"  //RRC - 09/09/2013

      oSrv:AddField("quant_adt",Len(aProcsAdt))
      oSrv:AddField("","")//PULAR LINHA

      For i:=1 To Len(aProcsAdt)
         oSrv:AddField("ADT_"+Alltrim(Str(i)),aServices[i][1][2])
      Next i

   ELSEIF cTipoProc == "V"  //RRC - 09/09/2013

      oSrv:AddField("quant_adt",Len(aProcsAdt))
      oSrv:AddField("","")//PULAR LINHA

      For i:=1 To Len(aProcsAdt)
         oSrv:AddField("ADT_"+Alltrim(Str(i)),aServices[i][1][2])
      Next i

   ENDIF

   oIniserv := Einfo():New("QUANTIDADE",oSrv)

   //RRC - 08/11/2012
   cNameRet   := cNumLote
   cNameSrv   := cNumLote

   If cTipoProc == "V"
      cNameINI   := "RVS_CS_WEB"    //RRC - 08/11/2012
      cPrefixExe := "EASY_RVS"//"RVS_CS"
   Else
      cNameINI   := "RAS_CS_WEB"      //RRC - 08/11/2012
      cPrefixExe := "EASY_RAS"//"RAS_CS"
   EndIf

   cNameRet += /*"RETORNO"+*/EXT_RET

   IF cTipoProc == "V"
      IF cTipoOpe == INC_ADI
         oConexao:AddField("pag_adt_inc","https://wwwc.siscoserv.mdic.gov.br/Siscoserv/aditivoIncluir.do")
         oArquivo:AddField("rvs_cs_cad"    ,"")
         oArquivo:AddField("rvs_cs_ret"    ,"")
         oArquivo:AddField("rvs_cs_adt_cad","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("rvs_cs_adt_ret","")
         oArquivo:AddField("rvs_cs_fat_cad","")
         oArquivo:AddField("rvs_cs_fat_can","")
         oArquivo:AddField("rvs_retorno","/"+cNameRet)
      ELSEIF cTipoOpe == RET_ADI
         oConexao:AddField("pag_adt_ret","https://wwwc.siscoserv.mdic.gov.br/Siscoserv/aditivoRetificar.do")
         oArquivo:AddField("rvs_cs_cad"    ,"")
         oArquivo:AddField("rvs_cs_ret"    ,"")
         oArquivo:AddField("rvs_cs_adt_cad","")
         oArquivo:AddField("rvs_cs_adt_ret","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("rvs_cs_fat_cad","")
         oArquivo:AddField("rvs_cs_fat_can","")
         oArquivo:AddField("rvs_retorno","/"+cNameRet)
      ENDIF
   ELSE
      IF cTipoOpe == INC_ADI
         oConexao:AddField("pag_adt_inc","https://wwwc.siscoserv.mdic.gov.br/SiscoservAqui/aditivoIncluir.do")
         oArquivo:AddField("ras_cs_cad"    ,"")
         oArquivo:AddField("ras_cs_ret"    ,"")
         oArquivo:AddField("ras_cs_adt_cad","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("ras_cs_adt_ret","")
         oArquivo:AddField("ras_cs_fat_cad","")
         oArquivo:AddField("ras_cs_fat_can","")
         oArquivo:AddField("ras_retorno","/"+cNameRet)
      ELSEIF cTipoOpe == RET_ADI
         oConexao:AddField("pag_adt_ret","https://wwwc.siscoserv.mdic.gov.br/SiscoservAqui/aditivoRetificar.do")
         oArquivo:AddField("ras_cs_cad"    ,"")
         oArquivo:AddField("ras_cs_ret"    ,"")
         oArquivo:AddField("ras_cs_adt_cad","")
         oArquivo:AddField("ras_cs_adt_ret","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("ras_cs_fat_cad","")
         oArquivo:AddField("ras_cs_fat_can","")
         oArquivo:AddField("ras_retorno","/"+cNameRet)
      ENDIF
   ENDIF

ElseIf cTipoOpe == INC_PAG .Or. cTipoOpe == CAN_PAG .Or. cTipoOpe == RET_PAG

   EL5->(dbSetOrder(2))
   EL5->(dbSeek(xFilial()+cNumLote))
   cTipoProc := EL5->EL5_TPPROC
   aOrd_EL := SaveOrd({"EL3","EL4","EL5","EL6"})
   i := 1
   Do While EL5->( !Eof() .AND. EL5_FILIAL+EL5_IDLOTE == xFilial()+cNumLote)
//      oINIServ    := SS103GerIni(cTipoOpe,EL5->EL5_TPPROC,EL5->EL5_REGIST,EL5->EL5_SQEVCP,,EL5->EL5_SEQPAG,Alltrim(Str(i)))
//      aAdd(aServices,SS103GerIni( cTipoOpe,EL3->EL3_TPPROC,EL3->EL3_REGIST,EL3->EL3_SQEVCP,,,Alltrim(Str(i))) )
      aAdd(aServices, SS103GerIni(cTipoOpe,EL5->EL5_TPPROC,EL5->EL5_REGIST,EL5->EL5_SQEVPG,,EL5->EL5_SEQPAG,Alltrim(Str(i))) )
      i++
      EL5->(dbSkip())
   EndDo

   RestOrd(aOrd_EL,.T.)

   IF cTipoProc == "A"

      oSrv:AddField("quant_fat",Len(aServices))
      oSrv:AddField("","")//PULAR LINHA

      For i:=1 To Len(aServices)
         oSrv:AddField("FAT_"+Alltrim(Str(i)),aServices[i][1][2])
      Next i

   ELSEIF cTipoProc == "V"

      oSrv:AddField("quant_fat",Len(aServices))
      oSrv:AddField("","")//PULAR LINHA

      For i:=1 To Len(aServices)
         oSrv:AddField("FAT_"+Alltrim(Str(i)),aServices[i][1][2])
      Next i

   ENDIF

   oIniserv := Einfo():New("QUANTIDADE",oSrv)

   cNameRet   := cNumLote
   cNameSrv   := cNumLote

   If cTipoProc == "V"
      cNameINI   := "RVS_CS_WEB"
      cPrefixExe := "EASY_RVS"
   Else
      cNameINI   := "RAS_CS_WEB"
      cPrefixExe := "EASY_RAS"
   EndIf

   cNameRet += EXT_RET

   IF cTipoProc == "V"
      IF cTipoOpe == INC_PAG
         oConexao:AddField("pag_fat_inc","https://wwwc.siscoserv.mdic.gov.br/Siscoserv/faturamentoIncluir.do")
         oArquivo:AddField("rvs_cs_cad"    ,"")
         oArquivo:AddField("rvs_cs_ret"    ,"")
         oArquivo:AddField("rvs_cs_adt_cad","")
         oArquivo:AddField("rvs_cs_adt_ret","")
         oArquivo:AddField("rvs_cs_fat_cad","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("rvs_cs_fat_can","")
         oArquivo:AddField("rvs_cs_fat_ret","")
         oArquivo:AddField("rvs_retorno","/"+cNameRet)
      ELSEIF cTipoOpe == CAN_PAG
         oConexao:AddField("pag_fat_can","https://wwwc.siscoserv.mdic.gov.br/Siscoserv/faturamentoCancelar.do")
         oArquivo:AddField("rvs_cs_cad"    ,"")
         oArquivo:AddField("rvs_cs_ret"    ,"")
         oArquivo:AddField("rvs_cs_adt_cad","")
         oArquivo:AddField("rvs_cs_adt_ret","")
         oArquivo:AddField("rvs_cs_fat_cad","")
         oArquivo:AddField("rvs_cs_fat_can","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("rvs_cs_fat_ret","")
         oArquivo:AddField("rvs_retorno","/"+cNameRet)
      ELSEIF cTipoOpe == RET_PAG
         oConexao:AddField("pag_fat_ret","https://wwwc.siscoserv.mdic.gov.br/Siscoserv/faturamentoRetificar.do")
         oArquivo:AddField("rvs_cs_cad"    ,"")
         oArquivo:AddField("rvs_cs_ret"    ,"")
         oArquivo:AddField("rvs_cs_adt_cad","")
         oArquivo:AddField("rvs_cs_adt_ret","")
         oArquivo:AddField("rvs_cs_fat_cad","")
         oArquivo:AddField("rvs_cs_fat_can","")
         oArquivo:AddField("rvs_cs_fat_ret","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("rvs_retorno","/"+cNameRet)
      ENDIF
   ELSE
      IF cTipoOpe == INC_PAG
         oConexao:AddField("pag_pag_inc","https://wwwc.siscoserv.mdic.gov.br/SiscoservAqui/faturamentoIncluir.do") //FSM
         oArquivo:AddField("ras_cs_cad"    ,"")
         oArquivo:AddField("ras_cs_ret"    ,"")
         oArquivo:AddField("ras_cs_adt_cad","")
         oArquivo:AddField("ras_cs_adt_ret","")
         oArquivo:AddField("ras_cs_fat_cad","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("ras_cs_fat_can","")
         oArquivo:AddField("ras_cs_fat_ret","")
         oArquivo:AddField("ras_retorno","/"+cNameRet)
      ELSEIF cTipoOpe == CAN_PAG
         oConexao:AddField("pag_pag_can","https://wwwc.siscoserv.mdic.gov.br/SiscoservAqui/faturamentoCancelar.do") //FSM
         oArquivo:AddField("ras_cs_cad"    ,"")
         oArquivo:AddField("ras_cs_ret"    ,"")
         oArquivo:AddField("ras_cs_adt_cad","")
         oArquivo:AddField("ras_cs_adt_ret","")
         oArquivo:AddField("ras_cs_fat_cad","")
         oArquivo:AddField("ras_cs_fat_can","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("ras_cs_fat_ret","")
         oArquivo:AddField("ras_retorno","/"+cNameRet)
      ELSEIF cTipoOpe == RET_PAG
         oConexao:AddField("pag_pag_ret","https://wwwc.siscoserv.mdic.gov.br/SiscoservAqui/faturamentoRetificar.do") //FSM
         oArquivo:AddField("ras_cs_cad"    ,"")
         oArquivo:AddField("ras_cs_ret"    ,"")
         oArquivo:AddField("ras_cs_adt_cad","")
         oArquivo:AddField("ras_cs_adt_ret","")
         oArquivo:AddField("ras_cs_fat_cad","")
         oArquivo:AddField("ras_cs_fat_can","")
         oArquivo:AddField("ras_cs_fat_ret","/"+cNameSrv+EXT_INI)
         oArquivo:AddField("ras_retorno","/"+cNameRet)
      ENDIF
   ENDIF

EndIf

If lIntJava
   If cTipoProc == "V"
      oModulo:AddField("nome_mod_rvs","Easy Siscoserv")
   ELSE
      oModulo:AddField("nome_mod_ras","Easy Siscoserv.jar")
   ENDIF
Else
   If cTipoProc == "V"
      oModulo:AddField("nome_mod_rvs","Easy Siscoserv")
   ELSE
      oModulo:AddField("nome_mod_ras","Easy Siscoserv")
   ENDIF
EndIf

//RRC - 08/03/2013 - Verifica parâmetro para realizar a confirmação automática do envio dos dados ou não, se sim, não exibirá mensagem
oModulo:AddField("conf_autom"  ,EasyGParam("MV_ESS0001",,"N"))
//AAF 28/12/2015
If lIntJava
   oModulo:AddField("tam_processo",100)
   oModulo:AddField("tam_fatura"  ,100)
EndIf

If EasyGParam("MV_ESS0027",,9) >= 10
   oModulo:AddField("versao"  , "2.0.5")
   oModulo:AddField("tipo"  , If(EasyGParam("MV_ESS0028",,2) == 1,"teste","prod"))
EndIf

oModulo:AddField( "ARQUIVO",oArquivo)
oConexao:AddField("MODULO" ,oModulo )
oINI := Einfo():New("CONEXAO",oConexao)

//AAF 28/12/2015
If lIntJava
   cPrefixExe := "tr-sw-web-solution-siscoserv.jar"
Else
   If EasyIsClient64()
      cPrefixExe += "_64.exe"
   Else
      cPrefixExe += "_32.exe"
   EndIf
EndIf

aRet := {.T.,oINI,oINIServ,cNameINI,cNameSrv,cNameRet,cPrefixExe}

Return aRet

*-------------------------------*
Function SS103Integ(aInteg,oError)
*-------------------------------*
Local lRet := .T.
Local cPathO_AutoIT, cPathD_AutoIT, cDirRet
Local nHandle,nTamRet
Local cBuffer := "", cCompl := ""
Local aArquivos := {}, i
Private cExecAutoIT := ""

//RRC - 15/01/2013 - Busca o diretório do arquivo de retorno pelo parâmetro MV_AVG0222, se estiver vazio, busca o diretório temporário do SmartClient
//RRC - 17/12/2013 - NOPADO a verificação co conteúdo \System\ porque deve ser informado o diretório completo no parâmetro
cDirRet := If(!Empty(EasyGParam("MV_AVG0222",,""))/* .And. !EasyGParam("MV_AVG0222") == "\SYSTEM\"*/,EasyGParam("MV_AVG0222"),GetTempPath(.T.))

//Verifica se o Objeto tem Erros caso nao gera o INI
If aInteg[3]:HasErrors()
   //aInteg[3]:ShowErrors()
   oError:Error( aInteg[3]:GetStrErrors(aInteg[3]:aError) )
ElseIf aInteg[2]:HasErrors()
   oError:Error( aInteg[2]:GetStrErrors(aInteg[2]:aError) )
   aInteg[2]:ShowErrors()
Else
   lRet := SS103GerArq(aInteg[2]:GetINI(),aInteg[3]:GetINI(),aInteg[4],aInteg[5],aInteg[6],oError)
   If !lRet
      oError:Error("Não foi possível efetuar a geração dos Arquivos!",.F.)
   EndIf
EndIf
//Efetua a cópia dos arquivos no Client para a pasta Temporária
If !oError:HasErrors()
   cPathO_AutoIT := GetClientDir()
   //cPathD_AutoIT := EasyGParam("MV_AVG0222",,If(IsSrvUnix(),"/SYSTEM/","\SYSTEM\"))
   cPathD_AutoIT := cDirRet+"SISCOSERV\"
   cCompl := "SISCOSERV\ARQUIVO"
   If File(cPathO_AutoIT+"Smartclient.exe")//FSY - 28/01/2014 - GetClientDir() - se o ambiente for iniciada por atalho sem o conteudo "Inciar em" retornara com o diretorio errado.
      cBat   := CriaBat(cPathO_AutoIT,cPathD_AutoIT,aInteg[7],"MOV",oError)
   Else
      cBat   := ""
      oError:Error("Atalho configurado incorretamente! Verifique o atalho do smartclient em propriedade o parametro 'Iniciar em: '(Digite o diretório do smartclient)")
   EndIf
   //nFound := WaitRun(cBat)

   If Empty(cBat)
      oError:Error("ERRO: Não foi possível mover os arquivos de inicialização",.F.)
   Else
      //nFound := WaitRun(cBat,SW_MINIMIZE)
      FErase(cPathD_AutoIT + "IntegSiscoserv.txt")
      Sleep(1000)
      If File(cPathD_AutoIT + "IntegSiscoserv.txt")
         oError:Error("ERRO: Não foi possível apagar o arquivo de configuração.",.F.)
      EndIF
      shellExecute("Open", "cmd.exe", cBat, cPathD_AutoIT, 0 )
      Processa({|lEnd| lRet := TEWaitFile((cPathD_AutoIT + "IntegSiscoserv.txt"),@lEnd,,,.F.) }, "Executando integrador...")
      nFound := 0
      If SubStr(MemoRead(cPathD_AutoIT + "IntegSiscoserv.txt"),1,1) == "2"
         nFound := 2
      EndIf
      FErase(cPathD_AutoIT + "IntegSiscoserv.txt")
   EndIf

   If nFound <> 0
      oError:Error("ERRO: Erro ao executar o aplicativo "+aInteg[7]+" no diretório: " + cPathO_AutoIT,.F.)
      lRet := .F.
   EndIf

   If !ExistDir(cPathD_AutoIT) .And. (!Empty(EasyGParam("MV_AVG0222",,"")) .AND. !ExistDir(EasyGParam("MV_AVG0222",,"")))  // GFP - 20/02/2014
      oError:Error("ERRO: Diretório inválido verifique o parâmetro MV_AVG0222. Exemplo: C:\Ambiente\M11.5\Protheus_data\comex\siscoserv_retorno(Diretório por extenso)",.F.)
      lRet := .F.
   EndIf

   If File(cDirRet+"SISCOSERV\ARQUIVO\"+aInteg[6])                                                     //Verifica se existe o arquivo de retorno
      If ( nHandle := EasyOpenFile(cDirRet+"SISCOSERV\ARQUIVO\"+aInteg[6]) ) < 0                                  //Tenta abrir o arquivo de retorno para leitura
         oError:Error( "ERRO: Não foi possível abrir o arquivo de Retorno "+aInteg[6]+" no diretório: "+cDirRet+cCompl,.F.)
         lRet := .F.
      Else                                                                                                         //Lê o arquivo e verifica se o arquivo não está em branco
         If ( nTamRet := FRead(nHandle,@cBuffer,50*1024) ) <= 0
            oError:Error( "ERRO: Não foi obtido nenhum dado de Retorno no arquivo: "+aInteg[6]+" no diretório: "+cDirRet+cCompl,.F.)
            lRet := .F.
         EndIf
         FClose(nHandle)
      EndIf
   Else
      oError:Error( "ATENÇÃO: Não foi obtido o arquivo de Retorno: "+aInteg[6]+ENTER+" no diretório: "+cDirRet+cCompl,.F.)
      lRet := .F.
   EndIf
   aArquivos := {}
   aDir(cDirRet+"SISCOSERV\ARQUIVO\*.INI",aArquivos)
   If EasyGParam("MV_ESS0027",,9) >= 10 .AND. Len(aArquivos) # 0
      For i := 1 To Len(aArquivos)
         FRename(cDirRet+"SISCOSERV\ARQUIVO\"+aArquivos[i],cDirRet+"SISCOSERV\ARQUIVO\"+StrTran(aArquivos[i],".INI",".ok"))
      Next i
   EndIf
EndIf

//cBat   := CriaBat(cPathO_AutoIT,cPathD_AutoIT,aInteg[7],"DEL")
//nFound := WinExec(cBat)

Return lRet

*---------------------------------------------------------------------------*
Function SS103GerArq(cINI,cINISrv,cNameINI,cNameINISRV,cNameINIRet,oError)
*---------------------------------------------------------------------------*
Local lRet       := .T.
Local nHandler   := 0, i
//RRC - 15/01/2013 - Busca o diretório do arquivo de retorno pelo parâmetro MV_AVG0222, se estiver vazio, busca o diretório temporário do SmartClient
Local cDirINI    := If(!Empty(EasyGParam("MV_AVG0222",,"")) .And. !EasyGParam("MV_AVG0222") == "\SYSTEM\",EasyGParam("MV_AVG0222"),GetTempPath(.T.))
Local cDirINISrv := ""
Local cArqINI    := "" ,cArqINISrv := ""//, cDateHr := ""
Local aArqs      := {}
Local lIntJava := CI100IsJava()

Begin Sequence

   cDirINI    += "SISCOSERV\"
   cDirINISrv += cDirINI+"ARQUIVO\"                                //NCF - Diretório dos arquivos .ini de serviços

   If !lIsDir(cDirINI) .And. !(MakeDir(cDirINI) == 0)
      oError:Error( (StrTran("Erro ao criar o diretório '###'. Não será possível executar a rotina de envio.", "###", cDirINI), "Atenção"), .F.)
      lRet := .F.
      Break
   EndIf

   If !lIsDir(cDirINISrv) .And. !(MakeDir(cDirINISrv) == 0)
      oError:Error( (StrTran("Erro ao criar o diretório '###'. Não será possível executar a rotina de envio.", "###", cDirINISrv), "Atenção"), .F.)
      lRet := .F.
      Break
   EndIf

   cArqINI    := cNameINI + EXT_INI
   cArqINISrv := cNameINISRV + EXT_INI

   If EasyGParam("MV_ESS0027",,9) >= 10
      For i := 1 To 100
         If File(cDirINI+"RAS_CS_WEB.ini")
            FErase(cDirINI+"RAS_CS_WEB.ini")
            Exit
         EndIf
         If File(cDirINI+"RVS_CS_WEB.ini")
            FErase(cDirINI+"RVS_CS_WEB.ini")
            Exit
         EndIf
      Next

      If File(cDirINI+"RAS_CS_WEB.ini") .OR. File(cDirINI+"RVS_CS_WEB.ini")  // GFP - 05/09/2016
         oError:Error("Não é possível efetuar a integração. Necessário excluir os arquivos da pasta '" + AllTrim(cDirINI) + "'",.F.)
         lRet := .F.
      EndIf
   EndIf

   //Cria arquivo .ini de conexão                                                                //RRC - 14/03/2013
   If (nHandler := EasyCreateFile(cDirINI + UPPER(cArqINI))) == -1
      oError:Error( (StrTran("O arquivo ### não pode ser criado. Foi gerado o erro de código " + Alltrim(Str(FERROR())), "###",cNameINI), "Atenção"), .F.)
      lRet := .F.
   Else
      FWrite(nHandler,cINI)
      FClose(nHandler)
   EndIf

   //Cria o arquivo .ini dos serviços
   If (nHandler := EasyCreateFile(cDirINISrv + UPPER(cArqINISrv))) == -1
      oError:Error( (StrTran("O arquivo ### não pode ser criado. Foi gerado o erro de código " + Alltrim(Str(FERROR())), "###",cNameINISrv), "Atenção"), .F.)
      lRet := .F.
   Else
      FWrite(nHandler,cINISrv)
      FClose(nHandler)
   EndIf

   //AAF 20/01/2016 - Cria ini com as configurações de proxy
   If lIntJava
       cArqIniProxy := "WebNavigation.ini"

	   If (nHandler := EasyCreateFile(cDirINI + UPPER(cArqIniProxy))) == -1
	      oError:Error( (StrTran("O arquivo ### não pode ser criado. Foi gerado o erro de código " + Alltrim(Str(FERROR())), "###",cArqIniProxy), "Atenção"), .F.)
	      lRet := .F.
	   Else
	      FWrite(nHandler,INIProxy())
	      FClose(nHandler)
	   EndIf
   EndIf

End Sequence

Return lRet

*--------------------------------*
Static Function SS103FormatDate()
*--------------------------------*
Local cDateHora := ""
Local cAno := "",  cMes := "", cDia := "", cHora := "" , cMin := ""

cAno := YEAR(Date())
cMes := MONTH(Date())
cDia := DAY(Date())
cHora:= SUBSTR(Time(),1,2)
cMin := SUBSTR(Time(),4,2)

//cDateHora := cAno + StrZero( cMes,2 ) + cDia + cHora + cMin
cDateHora := AllTrim(Str(cAno)) + StrZero( cMes,2 ) +StrZero(cDia,2) + cHora + cMin
Return cDateHora

/*
Funcao      : SS103GerIni().
Objetivos   : Criação do arquivo INI.
Sintaxe     : SS103GerIni()
Parametros  : cServico,cTipo,cProcesso,cSeqEnv,cSeqAdi,cSeqPag
Autor       : Nilson César C. Filho (Adaptado do Original SisServXML - Fabio Satoru Yamamoto)
Data/Hora   : 29/10/12 - 10:00.

cServico : 1,2,3,4,5,6
cTipo    : A = Aquisição, V = Venda
cProcesso: Nº do processo
cSeqEnv  : Nº da sequencia de envio capa. Usado no cServico 2,4
cSeqAdi  : Nº da sequencia do aditivo. Usado no cServico 3,4
cSeqPag  : Nº da sequencia do pagamento. Usado no cServico 5,6
*/
Function SS103GerIni(cServico,cTipo,cProcesso,cSeqEnv,cSeqAdi,cSeqPag,cSeqServ)
Local oINI
Local oRecSrv := ERec():New()
Local cChaveEL3
Local cChaveEL4
Local cChaveEL4Ant := ""
Local cChaveEL3Ant := ""
Local cLote_EL3
Local cStatus_EL3
Local aServices := {}
Local aOrdEL    := SaveOrd({"EL3","EL4","EL5","EL6","EL7","EL8"})
Local nRecEL3
Default cSeqEnv := ""
Default cSeqAdi := ""
Default cSeqPag := ""

cTipo := Upper(cTipo)
EL3->(dbSetOrder(1))
Do Case//Case para setar seek e a chave usada no seek da função.

   Case cServico == INC_REG
      EL3->(dbSeek(xFilial("EL3")+cTipo+cProcesso+cSeqEnv))
      cChaveEL4 := xFilial("EL4")+cTipo+cProcesso+cSeqEnv
      cChaveEL4Ant := cChaveEL4

   Case cServico == RET_REG
      EL3->(dbSeek(xFilial("EL3")+cTipo+cProcesso+cSeqEnv))
      cChaveEL4    := xFilial("EL4")+cTipo+cProcesso+cSeqEnv

      cLote_EL3   := EL3->EL3_IDLOTE
      cStatus_EL3 := PROCESSADO
      //Posiciona na Sequencia de Envio anterior que está em lote processado                                                               //RRC - 25/06/2013
      If SS101PosSeqAnt( "EL3", xFilial("EL3")+cTipo+cProcesso,{|| EL8->EL8_IDLOTE <> cLote_EL3 .And. EL8->EL8_STATUS == cStatus_EL3 .And. !Empty(EL3->EL3_NROREG)})
         cChaveEL4Ant := EL3->EL3_FILIAL+EL3->EL3_TPPROC+EL3->EL3_REGIST+EL3->EL3_SQEVCP
      EndIf

   Case cServico == INC_ADI .Or. cServico == RET_ADI //RRC - 11/01/2013
      cChaveEL4 := xFilial("EL4")+cTipo+cProcesso+cSeqAdi+cSeqEnv
      cStatus_EL3 := PROCESSADO
      //Posiciona na Sequencia de Envio do Registro anterior que está em lote processado
      //Este posicionamento é necessário para que na função GET_SV_AD(), sejam passados os valores corretos que farão parte do arquivo de retorno
      If SS101PosSeqAnt( "EL3", xFilial("EL3")+cTipo+cProcesso,{|| EL8->EL8_STATUS == cStatus_EL3 .And. !Empty(EL3->EL3_NROREG)})
         cChaveEL3Ant := EL3->EL3_FILIAL+EL3->EL3_TPPROC+EL3->EL3_REGIST+EL3->EL3_SQEVCP
      EndIf


   Case cServico == INC_PAG .Or. cServico == CAN_PAG .Or. cServico == RET_PAG
      EL3->(dbSeek(xFilial("EL3")+cTipo+cProcesso))
      cChaveEL3 := xFilial("EL5")+cTipo+cProcesso+cSeqPag+cSeqEnv //RRC - 14/01/2013 - Alteração da chave

End Case

//   oRecSrv     := ERec():New()

   If cTipo == "A"

      Do Case//Setando nome da tag e chamando função pelo tipo do serviço.
         Case cServico == INC_REG
//            oRecSrv:AddField("quant_ras" ,"")
//            oRecSrv:AddField("RAS_"+cSeqServ ,Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,"",cSeqServ))
            aAdd(aServices,{"RAS",Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,"",cSeqServ)})

         Case cServico == RET_REG
//            oRecSrv:AddField("quant_ras" ,"")
//            oRecSrv:AddField("RAS_"+cSeqServ ,Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ))
            aAdd(aServices,{"RAS",Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ)})

         Case cServico == INC_ADI
//            oRecSrv:AddField("quant_adt" ,"")
//            oRecSrv:AddField("ADT_"+cSeqServ ,Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ))
            aAdd(aServices,{"ADT",Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL3Ant,cSeqServ)})

         Case cServico == RET_ADI
//            oRecSrv:AddField("quant_adt" ,"")
//            oRecSrv:AddField("ADT_"+cSeqServ ,Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ))
            aAdd(aServices,{"ADT",Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL3Ant,cSeqServ)})

         Case cServico == INC_PAG
//            oRecSrv:AddField("quant_fat" ,"")
//            oRecSrv:AddField("FAT_"+cSeqServ ,Get_FAT(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ))
            aAdd(aServices,{"FAT",Get_FAT(cServico,oRecSrv,cTipo,cChaveEL3,cSeqServ)}) //RRC - 14/01/2013

         Case cServico == CAN_PAG
//            oRecSrv:AddField("quant_fat" ,"")
//            oRecSrv:AddField("FAT_"+cSeqServ ,Get_FAT(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ))
            aAdd(aServices,{"FAT",Get_FAT(cServico,oRecSrv,cTipo,cChaveEL3,cSeqServ)}) //RRC - 14/01/2013

         Case cServico == RET_PAG
            aAdd(aServices,{"RET",Get_FAT(cServico,oRecSrv,cTipo,cChaveEL3,cSeqServ)})
      End Case

   ElseIf cTipo == "V"

      Do Case
         Case cServico == INC_REG
//            oRecSrv:AddField("quant_rvs" ,"")
//            oRecSrv:AddField("RVS_"+cSeqServ ,Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ))
            aAdd(aServices,{"RVS",Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,"",cSeqServ)})

         Case cServico == RET_REG
//            oRecSrv:AddField("quant_rvs" ,"")
//            oRecSrv:AddField("RVS_"+cSeqServ ,Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ))
            aAdd(aServices,{"RVS",Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ)})

         Case cServico == INC_ADI
//            oRecSrv:AddField("quant_adt" ,"")
//            oRecSrv:AddField("ADT_"+cSeqServ ,Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ))
            aAdd(aServices,{"ADT",Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL3Ant,cSeqServ)})

         Case cServico == RET_ADI
//            oRecSrv:AddField("quant_adt" ,"")
//            oRecSrv:AddField("ADT_"+cSeqServ ,Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ))
            aAdd(aServices,{"ADT",Get_SV_AD(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL3Ant,cSeqServ)})

         Case cServico == INC_PAG
//            oRecSrv:AddField("quant_fat" ,"")
//            oRecSrv:AddField("FAT_"+cSeqServ ,Get_FAT(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ))
            aAdd(aServices,{"FAT",Get_FAT(cServico,oRecSrv,cTipo,cChaveEL3,cSeqServ)}) //RRC - 14/01/2013

         Case cServico == CAN_PAG
//            oRecSrv:AddField("quant_fat" ,"")
//            oRecSrv:AddField("FAT_"+cSeqServ ,Get_FAT(cServico,oRecSrv,cTipo,cChaveEL4,cChaveEL4Ant,cSeqServ))
            aAdd(aServices,{"FAT",Get_FAT(cServico,oRecSrv,cTipo,cChaveEL3,cSeqServ)}) //RRC - 14/01/2013

         Case cServico == RET_PAG
            aAdd(aServices,{"RET",Get_FAT(cServico,oRecSrv,cTipo,cChaveEL3,cSeqServ)})
      End Case

   EndIf

//   oINI := Einfo():New("QUANTIDADE",oRecSrv)
RestOrd(aOrdEL,.T.)

Return aServices

/*
Funcao      : Get_SV_AD().
Objetivos   : Montar tag principal dos serviços cServico = 1,2,3,4.
Sintaxe     : Get_SV_AD()
Parametros  : cServico,oTag,cTipo,cChave
Retorno     : oRec
Autor       : Nilson César C. Filho (Adaptado do Original SisServXML - Fabio Satoru Yamamoto)
Data/Hora   : 30/08/12 - 10:00.
*/
Static Function Get_SV_AD(cServico,oRec,cTipo,cChave,cChaveAnt,cSeqServ)
Local i, nInd
Local aRE := {}
Local aDI := {}
Local aOrd := SaveOrd({"EJZ"})
Local oServ,oDIs,oREs
Local nRecno
Local nRegAnt

   oServ := ERec():New()
   //RRC - 07/11/2012
   If cServico == INC_REG .Or. cServico == RET_REG
      If cServico == INC_REG
         oServ:AddField("id"           ,";"+EL3->EL3_REGIST+";")
         If EasyGParam("MV_ESS0021",,.F.) .And. EL3->(FieldPos("EL3_CGC"))>0
            oServ:AddField("cnpj_vend"    ,EL3->EL3_CGC           )
         Else
            oServ:AddField("cnpj_vend"    ,SM0->M0_CGC           )
         End If
         oServ:AddField("nome_adqu"    ,EL3->EL3_NOME          )
         oServ:AddField("end_adqu"     ,EL3->EL3_END           )
         oServ:AddField("nif_adqu"     ,EL3->EL3_NIF           )
         oServ:AddField("cod_pais_adqu",EL3->EL3_PAIS          )
      EndIf
      If cServico == RET_REG
         //RRC - 30/04/2013 - Guarda o número de registro anterior e volta ao lote atual
         nRegAnt :=  Transform(EL3->EL3_NROREG,AvSx3("EL3_NROREG",AV_PICTURE))
         //EL3->(DbSeek(xFilial("EL3")+SubStr(cChave,3)))
         EL3->(DbSeek(xFilial("EL3") + SubStr(cChave, FWSizeFilial() + 1 )))
         oServ:AddField("id"           ,";"+EL3->EL3_REGIST+";")
         oServ:AddField("num"          ,nRegAnt                )
         If EasyGParam("MV_ESS0021",,.F.) .And. EL3->(FieldPos("EL3_CGC"))>0
            oServ:AddField("cnpj_vend"    ,EL3->EL3_CGC           )
         Else
            oServ:AddField("cnpj_vend"    ,SM0->M0_CGC           )
         End If
         oServ:AddField("nome_adqu"    ,EL3->EL3_NOME          )
         oServ:AddField("end_adqu"     ,EL3->EL3_END           )
         oServ:AddField("nif_adqu"     ,EL3->EL3_NIF           )
         oServ:AddField("cod_pais_adqu",EL3->EL3_PAIS          )
      EndIf
      EL4->(dbSetOrder(3))//EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SQEVCP+EL4_SEQAD
   EndIf

   If cServico == INC_ADI .Or. cServico == RET_ADI
      oServ:AddField("id"           ,";"+EL3->EL3_REGIST+";")
      oServ:AddField("id_adt"       ,EL4->EL4_SEQAD)
      //RRC - 30/04/2013 - Alteração para considerar o símbolo "/" no conteúdo
      oServ:AddField("num"          ,Transform(EL3->EL3_NROREG,AvSx3("EL3_NROREG",AV_PICTURE)))
      If EasyGParam("MV_ESS0021",,.F.) .And. EL3->(FieldPos("EL3_CGC"))>0
         oServ:AddField("cnpj_vend"    ,EL3->EL3_CGC           )
      Else
         oServ:AddField("cnpj_vend"    ,SM0->M0_CGC           )
      End If
      EL4->(dbSetOrder(4))//EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQAD+EL4_SQEVCP
   EndIf

   nInd := 1
   oRecOper := Erec():New()
   //oRecOper:lUniqueField := .T.

   EL4->(dbSeek(cChave))
   cLote := If(Type("cLoteAtual")=="C",cLoteAtual,"")
   //RRC - 12/11/2012 - Verifica se é o mesmo lote, para não considerar uma sequência já cancelada ou de tipos de envio diferentes: Ex: Retificação RAS e Aditivo RAS
   Do While EL4->( !Eof() .AND. cChave == Left(&(IndexKey()),Len(cChave)))
      If EL4->EL4_IDLOTE == cLote
         oRecOper:AddField("",Get_OP_NBS(cServico,cTipo,Alltrim(Str(nInd)),cChaveAnt))                                 //Monta o objeto das Operações [nbs]
         nInd++
      EndIf
      EL4->(dbSkip())
   EndDo

   If cServico == INC_ADI .Or. cServico == RET_ADI
      oServ:AddField("qtde_nbs" ,Alltrim(Str(oRecOper:FCount())))
      oServ:AddField("ADT_"+cSeqServ+"_NBS",oRecOper)           //Adiciona as operações
   ElseIf cServico == INC_REG .Or. cServico == RET_REG

      EL7->(dbSetOrder(3))//EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVCP
      EL7->(dbSeek(cChave))
      nRecno := EL7->(Recno())
      Do While EL7->( !Eof() .AND. cChave == Left(&(IndexKey()),Len(cChave)))
         If Empty(EL7->EL7_SEQREG) .And. Empty(EL7->EL7_SEQPAG) //Não deve considerar os documentos dos pagamentos/faturamentos
            If EL7->EL7_EXCL == "1"
               If cTipo == "A"
                  If !(EasyGParam("MV_ESS0027",,9) >= 10) .AND. !Empty(EL7->EL7_DI)
                     aAdd(aDI,GetVincula(cTipo,Alltrim(Str(Len(aDI)+1))))                                                                 //Monta array de Objetos das DI`s vinculadas
                  EndIf
               ElseIf cTipo == "V"
                  If !(EasyGParam("MV_ESS0027",,9) >= 10) .AND. !Empty(EL7->EL7_RE)
                     aAdd(aRE,GetVincula(cTipo,Alltrim(Str(Len(aRE)+1))))                                                                  //Monta array de Objetos dos RE`s vinculados
                  EndIf
               EndIf
            EndIf
         EndIf
         EL7->(dbSkip())
      EndDo
      //RRC 14/11/2012 - Retorna para o Recno da EL7 antes do Loop, pois saía no fim de arquivo e o próximo dbseek() não funcionava
      EL7->(DbGoTo(nRecno))
      //RRC - 04/12/2013 - Alteração devido a inclusão do código da moeda no layout do arquivo de retificação
      If cServico == INC_REG .Or. cServico == RET_REG
         oServ:AddField("cod_moeda"    ,EL3->EL3_MOEDA)
      EndIf

      oServ:AddField("qtde_nbs"     ,Alltrim(Str(oRecOper:FCount())))

      If !(EasyGParam("MV_ESS0027",,9) >= 10) .AND. cTipo == "A"
         oServ:AddField("qtde_di"   ,Alltrim(Str(Len(aDI))))
      ElseIf !(EasyGParam("MV_ESS0027",,9) >= 10) .AND. cTipo == "V"
         oServ:AddField("qtde_re"   ,Alltrim(Str(Len(aRE))))
      EndIf

      If cServico == RET_REG
         //NOPADO por RRC - 05/11/2012
         //i          := 0
         nQtdeREAnt := nQtdeDIAnt := 0
         aOrdEL := SaveOrd("EL7")
         EL7->(dbSeek(cChaveAnt))
         Do While EL7->( !Eof() .AND. cChaveAnt == Left(&(IndexKey()),Len(cChaveAnt)) )
            //RRC - 28/08/2013 - Não deve considerar os documentos dos pagamentos/faturamentos
            If Empty(EL7->EL7_SEQREG) .And. Empty(EL7->EL7_SEQPAG)
               //i++
               //cExcl := EL7->(&("EL7_EXCL"+AllTrim(Str(i))))
               cExcl := EL7->EL7_EXCL
               If cExcl == "1" //RRC - 14/08/2013 - "1" - para Documentos registrados e "2" para cancelados
                  If cTipo == "A"
                     If !Empty(EL7->EL7_DI)
                        nQtdeDIAnt++
                     EndIf
                  ElseIf cTipo == "V"
                     If !Empty(EL7->EL7_RE)
                        nQtdeREAnt++
                     EndIf
                  EndIf
               EndIf
            EndIf
            EL7->(dbSkip())
         EndDo
         RestOrd(aOrdEL,.T.)
         If cTipo == "A"
            oServ:AddField("qtde_di_ant"   ,Alltrim(Str(nQtdeDIAnt)))
         ElseIf cTipo == "V"
            oServ:AddField("qtde_re_ant"   ,Alltrim(Str(nQtdeREAnt)))
         EndIf
      EndIf

      //If !Empty(EL3->EL3_COMPL) - RRC - 30/01/2013 - Caso as Informações Complementares (Campo Memo) esteja em branco, deve incluir mesmo assim, porém, com conteúdo em branco
         oServ:AddField("txt_comp"     ,If(!Empty(EL3->EL3_COMPL),StrTran(EL3->EL3_COMPL,Chr(13)+Chr(10),"||CHR(10)||"),"")) //
      //EndIf

      If EasyGParam("MV_ESS0027",,9) >= 10
         oServ:AddField("nif_motivo"  , EL3->EL3_MOTNIF)
         oServ:AddField("tipo_vinc"   , If(EL3->EL3_TIPVIN <> "0",EL3->EL3_TIPVIN,"")) //EL3->EL3_TIPVIN)
      EndIf

      oServ:AddField(IF(cTipo=="A","RAS_","RVS_")+cSeqServ+"_NBS",oRecOper)           //Adiciona as operações

      If !EasyGParam("MV_ESS0027",,9) >= 10
         oDIs := Erec():New()
         oREs := Erec():New()
         If cTipo == "A"
            If Len(aDI) > 0
               For i:=1 To Len(aDI)
                  oDIs:AddField(aDI[i])
               Next i
            EndIf
            oServ:AddField("RAS_"+cSeqServ+"_DI",oDIs)                                   //Adiciona as DI`s
         ElseIf cTipo == "V"
            If Len(aRE) > 0
               For i:=1 To Len(aRE)
                  oREs:AddField(aRE[i])
               Next i
            EndIf
            oServ:AddField("RVS_"+cSeqServ+"_RE",oREs)                                   //Adiciona os RE`s
         EndIf
      EndIf

   EndIf

Return oServ

/*
Funcao      : Get_OP_NBS().
Objetivos   : Retornar o objeto contendo as Operações (NBS).
Sintaxe     : Get_OP_NBS()
Parametros  : cServico => INC_REG / RET_REG / INC_ADI / RET_ADI / INC_PAG / CAN_PAG
              cTipo    => "A" - Aquisição / "V" - Vendas
              cSeqServ => Sequencia do Serviço no Lote
Retorno     : oOperacao - tag Operação em formato xml montada.
Autor       : Nilson César C. Filho (Adaptado do Original SisServXML - Fabio Satoru Yamamoto)
Revisão     : abr/2017 - alteração do id_nbs_? para retificação do aditivo
Data/Hora   : 29/09/2012 - 10:00.
*/
Static Function Get_OP_NBS(cServico,cTipo,cSeqServ,cChaveAnt)
Local oOperacao := ERec():New()
Local oEnquadramento, oDI, oRE
Local i, cEnq, cRc, cExcl, nQtdeEnq
Local aEnquad  := {}
Local aOrdEL   := {}
Local aDI := {}, aRE := {}
Local aOrd := {}
Local cField := ""
Default cChaveAnt := cChave

   oOperacao:AddField("id_nbs"+"_"+cSeqServ    , cSeqServ)//Alltrim(Str(Val(EL4->EL4_SEQREG))))
   oOperacao:AddField("nbs"+"_"+cSeqServ         ,Transform(EL4->EL4_NBS,AvSX3("EL4_NBS",AV_PICTURE)))
   oOperacao:AddField("cod_pais"+"_"+cSeqServ    ,EL4->EL4_PAIS)
   oOperacao:AddField("modo_prest"+"_"+cSeqServ  ,EL4->EL4_MODO)

   //If !Empty(EL4->EL4_DTINI) - RRC - 30/01/2013 - Caso a Data de Início esteja em branco, deve incluir mesmo assim, porém, com conteúdo em branco
      oOperacao:AddField("dt_ini"+"_"+cSeqServ   ,If(!Empty(EL4->EL4_DTINI),TransPicture(EL4->EL4_DTINI,"date"),""))
   //EndIf
   //If !Empty(EL4->EL4_DTFIM) - RRC - 30/01/2013 - Caso a Data Final esteja em branco, deve incluir mesmo assim, porém, com conteúdo em branco
      oOperacao:AddField("dt_conc"+"_"+cSeqServ  ,If(!Empty(EL4->EL4_DTFIM),TransPicture(EL4->EL4_DTFIM,"date"),""))
   //EndIf

   oOperacao:AddField("valor"+"_"+cSeqServ       ,If(!Empty(EL4->EL4_VALOR),TransPicture(EL4->EL4_VALOR,"VALOR"),"0")) //MCF - 09/11/2015

   For i := 1 To 3                                              //Monta o objeto dos Enquadramentos
      cEnq := EL4->(&("EL4_ENQ0"+AllTrim(Str(i))))
      If !Empty(cEnq)
         cField := "EL4_RC0" + AllTrim(Str(i))
         cRc   := EL4->(&(cField))
         cExcl := EL4->(&("EL4_EXCL"+AllTrim(Str(i))))

         If cExcl == "1" //RRC - 14/08/2013 - "1" - para Documentos registrados e "2" para cancelados
            oEnquadramento := ERec():New()
            oEnquadramento:AddField("enq_"+cSeqServ+"_"+Alltrim(Str(i)),cEnq)
            oEnquadramento:AddField("rc_"+cSeqServ+"_"+Alltrim(Str(i)),TransPicture(cRc,"rc", cField))
            aAdd(aEnquad,oEnquadramento)
         EndIf

      EndIf
   Next i

   oOperacao:AddField("qtde_enq"+"_"+cSeqServ,Alltrim(Str(Len(aEnquad))))

   If EasyGParam("MV_ESS0027",,9) >= 10
      aOrd := SaveOrd("EL7")
      i := 0
      EL7->(DbSetOrder(3))  //EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVCP+EL7_NBS
      If EL7->(DbSeek(xFilial("EL7")+EL4->(EL4_TPPROC+EL4_REGIST+EL4_SQEVCP+EL4_NBS)))
         Do While EL7->(!Eof()) .AND. EL7->(EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVCP+EL7_NBS) == xFilial("EL7")+EL4->(EL4_TPPROC+EL4_REGIST+EL4_SQEVCP+EL4_NBS)
            If !Empty(EL7->EL7_RE)
               i++
               oRE := ERec():New()
               oRE:AddField("mt_num_re_"+cSeqServ+"_"+Alltrim(Str(i)),TransPicture(EL7->EL7_RE,"RE", "EL7_RE"))
               aAdd(aRE,oRE)
            EndIf
            EL7->(DbSkip())
         EndDo
      EndIf

      i := 0
      EL7->(DbSetOrder(3))  //EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVCP+EL7_NBS
      If EL7->(DbSeek(xFilial("EL7")+EL4->(EL4_TPPROC+EL4_REGIST+EL4_SQEVCP+EL4_NBS)))
         Do While EL7->(!Eof()) .AND. EL7->(EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SQEVCP+EL7_NBS) == xFilial("EL7")+EL4->(EL4_TPPROC+EL4_REGIST+EL4_SQEVCP+EL4_NBS)
            If !Empty(EL7->EL7_DI)
               i++
               oDI := ERec():New()
               oDI:AddField("mt_num_di_"+cSeqServ+"_"+Alltrim(Str(i)),TransPicture(EL7->EL7_DI,"DI", "EL7_DI"))
               aAdd(aDI,oDI)
            EndIf
            EL7->(DbSkip())
         EndDo
      EndIf

      oOperacao:AddField("quant_mt_re"+"_"+cSeqServ,Alltrim(Str(Len(aRE))))
      oOperacao:AddField("quant_mt_di"+"_"+cSeqServ,Alltrim(Str(Len(aDI))))
      RestOrd(aOrd,.T.)
   EndIf

   If cServico == RET_REG .Or. cServico == RET_ADI
      i           := 0
      nQtdeEnqAnt := 0
      aOrdEL  := SaveOrd("EL4")
      cStatus := PROCESSADO
      //NOPADO por RRC - 05/11/2012
      //cChaveAnt := SS101PosSeqAnt( "EL4" , EL4->EL4_FILIAL+EL4->EL4_TPPROC+EL4->EL4_REGIST+EL4->EL4_SEQREG , {|cStatus|EL8->EL8_STATUS == cStatus} )
      //EL4->(dbSeek(cChaveAnt))
      If SS101PosSeqAnt( "EL4" , EL4->EL4_FILIAL+EL4->EL4_TPPROC+EL4->EL4_REGIST+EL4->EL4_SEQREG , {||EL8->EL8_STATUS == cStatus .And. !Empty(EL4->EL4_NROREG)} )
         cChaveAnt := EL4->EL4_FILIAL+EL4->EL4_TPPROC+EL4->EL4_REGIST+EL4->EL4_SEQREG+EL4->EL4_SQEVIT
         //Do While EL4->( !Eof() .AND. cChaveAnt == Left(&(IndexKey()),Len(cChaveAnt)) )
         //Do While EL4->(!Eof()) .And. EL4->(EL4_FILIAL+EL4_TPPROC+EL4_REGIST+EL4_SEQREG+EL4_SQEVIT) == cChaveAnt)
            For i := 1 To 3
               cEnq  := EL4->(&("EL4_ENQ0"+AllTrim(Str(i))))
               cExcl := EL4->(&("EL4_EXCL"+AllTrim(Str(i))))
               If !Empty(cEnq) .And. cExcl == "1" //RRC - 14/08/2013 - "1" - para Documentos registrados e "2" para cancelados
                  nQtdeEnqAnt++
               EndIf
            Next
            //EL4->(dbSkip())
         //EndDo
         RestOrd(aOrdEL,.T.)
         oOperacao:AddField("qtde_enq_ant"+"_"+cSeqServ,Alltrim(Str(nQtdeEnqAnt)))
      EndIf
   EndIf

   For i:=1 To Len(aEnquad)
      oOperacao:AddField("",aEnquad[i])                 //Coloca o enquadramento na operação
   Next i
   For i:=1 To Len(aRE)
      oOperacao:AddField("",aRE[i])                 //Coloca os REs na operação
   Next i
   For i:=1 To Len(aDI)
      oOperacao:AddField("",aDI[i])                 //Coloca as DIs na operação
   Next i

Return oOperacao

/*
Funcao      : GetVincula().
Objetivos   : Monta a tag Vincular aquisição - VincImportacaoBens/ venda - VincExportacaoBens.
Sintaxe     : GetVincula()
Parametros  : cTipo - Aquisição/venda
Retorno     : oTag - tag Vinculação em formato xml montada.
Autor       : Nilson César C. Filho (Adaptado do Original SisServXML - Fabio Satoru Yamamoto)
Data/Hora   : 29/09/2012 - 10:00.
*/
Static Function GetVincula(cTipo,cSeqVinc,cVar)//VincImportacaoBens,VincExportacaoBens
Local oVincula
Default cVar := ""
/*NOPADO por RRC - 14/01/2013 - No caso dos documentos vinculados a pagamentos, é possível haver RE ou DI independentemente do tipo de processo
Foi passado também um terceiro parâmetro para o caso de possuir tanto RE quanto DI e retornar um de cada vez */
      //If cTipo == "A"
      If (Empty(cVar) .Or. cVar == "DI") .And. !Empty(EL7->EL7_DI)
         oVincula := EInfo():New("num_di_"+cSeqVinc,TransPicture(EL7->EL7_DI,"DI", "EL7_DI"))
      EndIf
      //ElseIf cTipo == "V"

      If (Empty(cVar) .Or. cVar == "RE") .And. !Empty(EL7->EL7_RE)
         oVincula := EInfo():New("num_re_"+cSeqVinc,TransPicture(EL7->EL7_RE,"RE", "EL7_RE"))
      EndIf

Return oVincula

/*
Funcao      : Get_FAT().
Objetivos   : Montar tag para os serviços de Inclução pagamento/fatura, cancelamento pagamento/fatura.
Sintaxe     : Get_FAT()
Parametros  : cServico,oTag, cTipo,cChave
Retorno     : oTag
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 30/08/12 - 10:00.
*/
Static Function Get_FAT(cServico,oRec,cTipo,cChave,cSeqServ)
Local i
Local aRE := {}
Local aDI := {}
Local aOrd := SaveOrd({"EJY","EJZ","EL3","EL5","EL6","EL7"})
Local cLoteEL5, cPagId := ""
Local oDIs, oREs, oRecOper
//Local nSeq := 1 Usado para definir a posição do item dentro do aditivo//NOPADO por RRC - 16/09/2013 - Vide comentário abaixo sobre envio de aditivo

EL3->(dbSetOrder(1))
EL5->(dbSetOrder(1))
EL5->(dbSeek(cChave))//EL5_FILIAL+EL5_TPPROC+EL5_REGIST+EL5_SEQPAG+EL5_SQEVPG
cLoteEL5 := If(Type("cLoteAtual")=="C",cLoteAtual,"")

If cServico == CAN_PAG//Serviço de cancelamento
   cPagId := EL5->EL5_PAGID
   If SS101PosSeqAnt( "EL3", EL3->(EL3_FILIAL+EL3_TPPROC+EL3_REGIST),{|| !Empty(EL3->EL3_NROREG)  }) .And. SS101PosSeqAnt( "EL5", EL5->(EL5_FILIAL+EL5_TPPROC+EL5_REGIST+EL5_SEQPAG),{|| !Empty(EL5->EL5_NROREG)  })

      If cTipo == "A"

         oRec:AddField("id_ras"          ,";"+EL5->EL5_REGIST+";")
         oRec:AddField("num_ras"         ,Transform(EL3->EL3_NROREG,AvSx3("EL3_NROREG",AV_PICTURE)))
         oRec:AddField("id_fat"          ,cPagId)
         oRec:AddField("cod_fat_cambio"  ,"")
         oRec:AddField("cod_fat_sisc"    ,Transform(EL5->EL5_NROREG,AvSx3("EL5_NROREG",AV_PICTURE)))

      ElseIf cTipo == "V"

         oRec:AddField("id_rvs"          ,";"+EL5->EL5_REGIST+";")
         oRec:AddField("num_rvs"         ,Transform(EL3->EL3_NROREG,AvSx3("EL3_NROREG",AV_PICTURE)))
         oRec:AddField("id_fat"          ,cPagId)
         oRec:AddField("cod_fat_cambio"  ,"")
         oRec:AddField("cod_fat_sisc"    ,Transform(EL5->EL5_NROREG,AvSx3("EL5_NROREG",AV_PICTURE)))

      EndIf

   EndIf
   RestOrd(aOrd,.T.)
   Return oRec

EndIf

   //RRC - 16/09/2013 - Envio de Aditivo: Antecipado o Seek na EL6 para cenários de RP ou RF:
   /*No envio do Aditivo, SISCOSERV pode reiniciar o valor da Seq. Registro. Ex: No SIGAESS o item pode ter o campo EJZ_SEQREG = "004" e ser aditivo, mas seu id no
   SISCOSERV pode ser "1", o que afeta retificação e pagamento, uma vez que existe o campo "id_adt" no layout, é importante a ordem para identificar o serviço correto.
   Caso necessário, deverá buscar a sequência correta (EJZ_SEQAD) para refenciá-lo.
   Obs: A informação acima ainda não é garantida, uma vez que não existe uma ferramenta de testes no site do SISCOSERV, porém, a antecipação do seek visa facilitar esse
   tratamento caso haja necessidade.
   */

   EL6->(dbSetOrder(1))//EL6_FILIAL+EL6_TPPROC+EL6_REGIST+EL6_SEQPAG+EL6_SQEVPG+EL6_SEQREG
   EL6->(dbSeek(cChave))
   //RRC - 16/09/2013 - Busca a EJZ (Detalhes do RAS/RVS) para ter acesso a Seq. Aditivo. Vide descrição acima.
   //EJZ->(DbSetOrder(1)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_PROCES+EJZ_SEQREG
   //EJZ->(DbSeek(xFilial("EJZ")+EL6->EL6_TPPROC+EL6->EL6_REGIST+EL6->EL6_SEQREG))

   If cTipo == "A"

      oRec:AddField("id_ras"          ,";"+EL5->EL5_REGIST+";")
      oRec:AddField("id_adt"          ,""/*EJZ->EJZ_SEQAD*/)//NOPADO por RRC - 16/09/2013 - Vide comentário acima
      oRec:AddField("num_ras"         ,Transform(Posicione("EJY",1,xFilial("EJY")+EL5->EL5_TPPROC+EL5->EL5_REGIST,"EJY_NROREG"),AvSx3("EJY_NROREG",AV_PICTURE)))
      oRec:AddField("data_fat"        ,TransPicture(EL5->EL5_DTPAG,"DATE"))
      oRec:AddField("id_fat"          ,EL5->EL5_PAGID)
      oRec:AddField("cod_fat"         ,EL5->EL5_DOC)
      If EasyGParam("MV_ESS0027",,9) >= 10
         cPagId := EL5->EL5_PAGID
         aOrd := SaveOrd({"EL3","EL5"})
         If SS101PosSeqAnt( "EL3", EL3->(EL3_FILIAL+EL3_TPPROC+EL3_REGIST),{|| !Empty(EL3->EL3_NROREG)  }) .And. SS101PosSeqAnt( "EL5", EL5->(EL5_FILIAL+EL5_TPPROC+EL5_REGIST+EL5_SEQPAG),{|| !Empty(EL5->EL5_NROREG)  })
            oRec:AddField("cod_fat_sisc"    ,Transform(EL5->EL5_NROREG,AvSx3("EL5_NROREG",AV_PICTURE)))
         EndIf
         RestOrd(aOrd,.T.)
      EndIf
   ElseIf cTipo == "V"

      oRec:AddField("id_rvs"          ,";"+EL5->EL5_REGIST+";")
      oRec:AddField("id_adt"          ,""/*EJZ->EJZ_SEQAD*/)//NOPADO por RRC - 16/09/2013 - Vide comentário acima
      oRec:AddField("num_rvs"         ,Transform(Posicione("EJY",1,xFilial("EJY")+EL5->EL5_TPPROC+EL5->EL5_REGIST,"EJY_NROREG"),AvSx3("EJY_NROREG",AV_PICTURE)))
      oRec:AddField("data_fat"        ,TransPicture(EL5->EL5_DTPAG,"DATE"))
      oRec:AddField("id_fat"          ,EL5->EL5_PAGID)
      oRec:AddField("cod_fat"         ,EL5->EL5_DOC)
      If EasyGParam("MV_ESS0027",,9) >= 10
         cPagId := EL5->EL5_PAGID
         aOrd := SaveOrd({"EL3","EL5"})
         If SS101PosSeqAnt( "EL3", EL3->(EL3_FILIAL+EL3_TPPROC+EL3_REGIST),{|| !Empty(EL3->EL3_NROREG)  }) .And. SS101PosSeqAnt( "EL5", EL5->(EL5_FILIAL+EL5_TPPROC+EL5_REGIST+EL5_SEQPAG),{|| !Empty(EL5->EL5_NROREG)  })
            oRec:AddField("cod_fat_sisc"    ,Transform(EL5->EL5_NROREG,AvSx3("EL5_NROREG",AV_PICTURE)))
         EndIf
         RestOrd(aOrd,.T.)
      EndIf
   EndIf

   nInd := 1
   aOper := {}

   Do While EL6->( !Eof() .AND. cChave == Left(&(IndexKey()),Len(cChave)) )
      //oRec:AddField("",ItemPagame(nInd))

	  EJZ->(DbSetOrder(1)) //EJZ_FILIAL+EJZ_TPPROC+EJZ_PROCES+EJZ_SEQREG

	  //AAF 18/01/2017 - Movido trecho que estava correto mas estava nopado e fora do loop, para numerar o item conforme a sequencia do siscoserv.
	  nSeq := 0
     If EJZ->(DbSeek(xFilial("EJZ")+EL6->EL6_TPPROC+EL6->EL6_REGIST))
         Do While !EJZ->(Eof()) .And. EJZ->(EJZ_FILIAL+EJZ_TPPROC+EJZ_REGIST) == EL6->(EL6_FILIAL+EL6_TPPROC+EL6_REGIST)
            nSeq++
			If EJZ->EJZ_SEQREG == EL6->EL6_SEQREG
               Exit
            EndIf

            EJZ->(DbSkip())
         EndDo
      EndIf

      IF cServico == RET_PAG //LRS - WSF - 30/03/2017
	      aAdd(aOper,ItemPagame(nInd,nInd))
      Else
         aAdd(aOper,ItemPagame(nInd,nSeq))
      EndIF

      EL6->(dbSkip())
      nInd++
      //nSeq++
   End Do

   If cServico == INC_PAG .Or. cServico == RET_PAG
      EL7->(dbSetOrder(2))//EL7_FILIAL+EL7_TPPROC+EL7_REGIST+EL7_SEQPAG
      EL7->(dbSeek(cChave))
      Do While EL7->( !Eof() .AND. &(IndexKey()) == Left(cChave,Len(&(IndexKey())))) //RRC - 14/01/2013
         If EL7->EL7_IDLOTE == cLoteEL5 .And. EL7->EL7_EXCL == "1"
            If !Empty(EL7->EL7_DI)
               aAdd( aDI,GetVincula(cTipo,Alltrim(Str(Len(aDI)+1)),"DI"))                                                                  //Monta Objetos das DI`s vinculadas
            EndIf
            If !Empty(EL7->EL7_RE)
               aAdd(aRE,GetVincula(cTipo,AllTrim(Str(Len(aRE)+1)),"RE"))                                                                  //Monta Objetos dos RE`s vinculados
            EndIf
         EndIf
         EL7->(dbSkip())
      EndDo
      //oRec:AddField(,oRE)
   EndIf

   oRec:AddField("quant_nbs",Alltrim(Str(Len(aOper))))
   If !(EasyGParam("MV_ESS0027",,9) >= 10)
      oRec:AddField("quant_re" ,Alltrim(Str(Len(aRE  ))))
      oRec:AddField("quant_di" ,Alltrim(Str(Len(aDI  ))))
   EndIf

   //RRC - 14/01/2013
   If Len(aOper) > 0
      oRecOper := Erec():New()
      For i := 1 To Len(aOper)
         //oRec:AddField(,aOper[i])
         oRecOper:AddField(aOper[i])
      Next i
      oRec:AddField("",oRecOper)
   EndIf

   If Len(aRE) > 0
      oREs := Erec():New()
      For i := 1 To Len(aRE)
         //oRec:AddField(,aRE[i])
         oREs:AddField(aRE[i])
      Next i
      oRec:AddField("",oREs)
   EndIf

   If Len(aDI) > 0
      oDIs := Erec():New()
      For i := 1 To Len(aDI)
      	 //oRec:AddField(,aDI[i])
         oDIs:AddField(aDI[i])
      Next i
      oRec:AddField("",oDIs)
   EndIf

RestOrd(aOrd)

Return oRec

/*
Funcao      : ItemPagame().
Objetivos   : Criação da tag Operação.
Sintaxe     : ItemPagame()
Parametros  : cTipo
Retorno     : oOperacao
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 30/08/12 - 10:00.
*/
Static Function ItemPagame(nInd,nSeq)
Local oOperacao := ERec():New()
Local aOrdEJZ := SaveOrd("EJZ")
//Local cModal  := "1"
Default nSeq  := 0
   //LGS-28/07/2015 - Posiciona na parcela e verifica a modalidade que foi baixado a parcela (1=Contrato Cambio;2=Movimento Exterior)
   //If EEQ->(DbSeek(xFilial("EEQ")+AvKey("A"+EL9->EL9_PROCES,"EEQ_PREEMB")+AvKey(EL9->EL9_PARC,"EEQ_PARC")))
     // cModal := EEQ->EEQ_MODAL
   //EndIf

   oOperacao:AddField("id_nbs"+"_"+Alltrim(STR(nInd))    , Alltrim(Str(If(nSeq>0,nSeq,Val(EL6->EL6_SEQREG))))) //RRC - 16/09/2013 - Trata caso o SISCOSERV considere que a ordem do serviço no aditivo seja diferente do EJZ_SEQREG
   oOperacao:AddField("nbs"+"_"+Alltrim(STR(nInd))       ,Transform(Posicione("EJZ",1,xFilial("EJZ") + EL6->EL6_TPPROC + EL6->EL6_REGIST + EL6->EL6_SEQREG,"EJZ_NBS"),AvSX3("EL4_NBS",AV_PICTURE)))

   //If cModal == "1" //LGS-28/07/2015
     // oOperacao:AddField("valor_fat"+"_"+Alltrim(STR(nInd)) ,TransPicture(EL6->EL6_VLCAMB,"VALOR"))
   //Else
      oOperacao:AddField("valor_fat"+"_"+Alltrim(STR(nInd)) ,TransPicture(EL6->EL6_VLCAMB+EL6->EL6_VLEXT,"VALOR")) //TRP - 05/04/2016
   //EndIf

   //If !Empty(EL6->EL6_VLEXT) RRC - 30/01/2013 - Caso esteja vazio estejam em branco, deve incluir mesmo assim, porém, com conteúdo em branco
      oOperacao:AddField("valor_ext"+"_"+Alltrim(STR(nInd)),If(!Empty(EL6->EL6_VLEXT),TransPicture(EL6->EL6_VLEXT,"VALOR"),""))
   //End If
   RestOrd(aOrdEJZ,.T.)
Return oOperacao

/*
Funcao      : TransPicture().
Objetivos   : Aplicar picture numa string.
Parametros  : cString: String a ser aplicada a picture/ cTipo: tipo de picture a ser aplicada.
Retorno     : cRet: String com a picture.
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 30/08/12 - 10:00.
*/
Static Function TransPicture(cString, cTipo, cField)
Local cRet := ""  
Local cPicture := ""
Default cField := ""

If !Empty(cField)
      cPicture := AvSX3(cField, AV_PICTURE)
EndIf
cTipo := Upper(cTipo)
If !Empty(cString) .And. !Empty(cTipo)

   Do Case
      Case cTipo == "DATE" .Or. cTipo == "DATA"
         //RRC - 06/03/2013
         //cRet := Transform(Val(DToS(cString)),"9999-99-99")
         cRet := StrZero(Day(cString),2)+"/"+StrZero(Month(cString),2)+"/"+StrZero(Year(cString),4)//Transform(cString,"@D DD/MM/YYYY")

      Case cTipo == "DI"
         cRet := Transform(cString        , cPicture)

      Case cTipo == "RC"
         cRet := Transform(cString        , cPicture)

      Case cTipo == "RE"
         cRet := Transform(cString        , cPicture)

      Case cTipo == "VALOR"
         cRet := StrTran(Str(cString),".",",")

   End Case

EndIf

Return cRet

/*
======================================================================================================================================
Funcao      : CriaBat().
Objetivos   : Aplicar picture numa string.
Parametros  : cString: String a ser aplicada a picture/ cTipo: tipo de picture a ser aplicada.
Retorno     : cRet: String com a picture.
Autor       : Fabio Satoru Yamamoto
Data/Hora   : 30/08/12 - 10:00.
*/

/*
 - O executável AutoIT estará na pasta Smartclient
 - Os Arquivos ".ini" estarão gerados no Servidor (lote)
 - Procedimento:
   -> Copiar os arquivos ".ini" de <SmartClient> para <Temp> montando um batch com os comandos de transferência rodando pelo WinExec
   -> O batch já deverá conter o comando para executar o AutoIT.exe
=======================================================================================================================================
*/

Static Function CriaBat(cPath_Orig,cPath_Dest,cName_Srv,cTipoExe,oError)
Local lRet := .T.
Local cCmd
Local fHandle
Local cBat := ""
local cClient := ""
Local lIntJava    := CI100IsJava()
Local oUserParams := EASYUSERCFG():New("ESSCI100")
Local cDirJava    := oUserParams:LoadParam("JAVA","","ESSCI100")

Begin Sequence

   IF !lIsDir(cPath_Dest)
      If !MakeDir(cPath_Dest)
         oError:Error("Não foi possível criar a pasta de destino dos arquivos de inicialização do integrador!"+ENTER+;
                      "Verifique as permissões de gravação na pasta Temporária do SmartClient")
         lRet := .F.
      EndIf
   Endif

  /* IF FILE(cPath_Dest+"CPYT2Temp.bat")
      If(nErase := Ferase(cPath_Dest+"CPYT2Temp.bat")) < 0
         oError:Error( "Não foi possível apagar os arquivo de script na pasta temporária do SmartClient."+ENTER+;
                       "Foi gerado o erro de código ["+ Alltrim(Str(FError()))+"] Para mais detalhes do "+ENTER+;
                       "erro, vide o endereço http://tdn.totvs.com/display/tec/FError"  )
         lRet := .F.
      EndIf
   ENDIF
   */
   //fHandle:=EasyCreateFile(cPath_Dest+"CPYT2Temp.bat")

   IF cTipoExe == "MOV"/*
      cCmd := '@echo off'+ENTER
      cCmd += 'cd ' + cPath_Dest +ENTER
     // If File(cPath_Orig+cName_Srv)
         cCmd += 'copy "'+cPath_Orig+cName_Srv+'" "'+cPath_Dest+'"'+ENTER
         If !lIntJava
            cCmd += 'copy "'+cPath_Orig+"OK_MSG" +'.exe" '+'"'+cPath_Dest+'"'+ENTER
         EndIf
     // EndIf*/

     //THTS - 10/06/2020 - OSSME-4709 - Nao deve mais executar bat e sim mover o arquivo direto pra pasta informada
     If !AvCpyFile( cPath_Orig + cName_Srv , cPath_Dest + cName_Srv ,,.F.,,.F. )//Nao conseguiu copiar
         cBat := ""
         lRet := .F.
         Break
     EndIf
   ELSE
      cCmd := '@echo off"+ENTER
      cCmd += 'cd "' + cPath_Dest+'"'+ENTER
      cCmd += 'del "' + cPath_Dest +'*.ini"'        +ENTER
      If lIntJava
      	 cCmd += 'del "' + cPath_Dest +'*.jar"'        +ENTER
      Else
      	 cCmd += 'del "' + cPath_Dest +'*.exe"'        +ENTER
      EndIf
      cCmd += 'del "' + cPath_Dest +'Arquivo\*.ini"'+ENTER
   ENDIF

   If lIntJava
      //cExecAutoIT := cPath_Dest+"IntegJava.bat"
      cBat := '/c "'
	  //cBat := "Echo Executando Integrador "+ chr(13)+chr(10)
	  //cBat += "cd " + cPath_Dest + chr(13)+chr(10)

	  cBat += If(!Empty(cDirJava),'"'+AllTrim(cDirJava)+'Java.exe"',"Java.exe")		// Chamada do executavel 'Java.exe'
	  cBat += " -jar "+ cName_Srv + " NoChooseFile"									// Chamada do integrador
     cBat += ' && echo 1 > IntegSiscoserv.txt || echo 2 > IntegSiscoserv.txt"'

     // nHandler := EasyCreateFile(cPath_Dest+"IntegJava.bat")
	  //FWrite(nHandler, cBat)
	  //FClose(nHandler)
   Else
      //cCmd += "start "+cPath_Dest+cName_Srv+".exe"
      cExecAutoIT := cPath_Dest+cName_Srv
   EndIf

   //FWRITE(fHandle,cCmd)
   //FCLOSE(fHandle)

   //cBat := cPath_Dest+"CPYT2Temp.bat"

End Sequence

Return cBat

*--------------------------------------------------------*
Function SS103IntFim(cTpServ,cTpOpe,cNroLote,cDir,oError)
*--------------------------------------------------------*
Local lRet := .T.
//RRC - 15/01/2013 - Busca o diretório do arquivo de retorno pelo parâmetro MV_AVG0222, se estiver vazio, busca o diretório temporário do SmartClient
Local cDirRet := If(!Empty(EasyGParam("MV_AVG0222",,"")) .And. !EasyGParam("MV_AVG0222") == "\SYSTEM\",EasyGParam("MV_AVG0222"),GetTempPath(.T.))

If !oError:HasErrors()
   //Grava o status do Lote caso seja validado o envio
   If !SS101GrvEL8(ENVIADO,cTpServ,cTpOpe,cNroLote,,oError) .OR. !SS101GrvEL8(RECEBIDO,cTpServ,cTpOpe,cNroLote,,oError)
      lRet := .F.
   Else
      //Copia o arquivo de retorno para a pasta do servidor
      If !CpyT2S( cDirRet+"SISCOSERV\ARQUIVO\"+cNroLote+EXT_RET , cDir , .F. )
         oError:Error( "ERRO: Não foi possível copiar o arquivo de Retorno "+cNroLote+EXT_RET+" para o diretório: "+cDir,.F.)
         lRet := .F.
      EndIf
      //Copia o arquivo ini para a pasta do servidor
      If !CpyT2S( cDirRet+"SISCOSERV\ARQUIVO\"+cNroLote+If(EasyGParam("MV_ESS0027",,9) >= 10,".OK",EXT_INI) , cDir , .F. )
         oError:Error( "ERRO: Não foi possível copiar o arquivo ini"+cNroLote+If(EasyGParam("MV_ESS0027",,9) >= 10,".OK",EXT_INI)+" para o diretório: "+cDir,.F.)
         lRet := .F.
      EndIf
   EndIf
      // Atualiza o Status do Lote de Serviços
   /*
   EL8->(DbSetOrder(2))
      EL8->(DbSeek(xFilial("EL8")+AvKey(cNroLote,"EL8_IDLOTE")))
      EL8->(RecLock("EL8",.F.))
      EL8->EL8_STATUS := "E"
      EL8->(MsUnlock())
   */
EndIf

Return lRet

Function SS103ProcRet(cNomeArq,cNumLote, oErros)
Local lRet     := .T., lRetVazio := .F.
Local aLayout
Local cErros   := ""
Local nPosProc := 0
Local nTamProc := 0
Local lProcRegua:= .F.
Default oErros := AvObject():New()

Begin Sequence

   EL8->(dbSetOrder(2))//EL8_FILIAL+EL8_IDLOTE+EL8_TPPROC+EL8_TIPENV+EL8_STATUS
   If !EL8->(dbSeek(xFilial()+cNumLote))
      oErros:Error("Lote " + AllTrim(cNumLote) + " não localizado.")
      BREAK
   EndIf

   nHandle := FT_FUse(cNomeArq)

   If nHandle == -1
      oErros:Error("Não foi possível abrir o arquivo de retorno do lote " + AllTrim(cNumLote))
      BREAK
   EndIf

   Begin Transaction

   FT_FGoTop()
   //RRC - 14/11/2013 - Foi adicionado um novo campo no layout do arquivo de retorno para Data do Processo, este não deve ser considerado para a busca pelo número do registro
   If "DAT_PRC" $ FT_FReadLn()
      FT_FSKIP()
   EndIf
   /*RRC - 02/10/2013 - No layout inicial do arquivo de retorno, o tamanho do campo do Processo era 20, porém, ocorreram atualizações e o novo padrão é 100.
   Devido a essa alteração, o layout dos arquivos foi modificado, mas é possível que existam arquivos de retorno gravados no ambiente com o layout antigo, sendo
   necessário identificar qual foi utilizado para sua criação, para não afetar em casos de uso da fucionalidade de "Reprocessamento".
   Como os campos de Processos são gravados sempre entre ";", busca a segunda posição deste caractere e posteriormente subtrai pelo tamanho do campo
   "Identificador" (Primeiro campo do arquivo cujo tamanho é 7), para que assim considere o tamanho do espaço reservado ao Processo.
   */
   nPosProc := At(";",FT_FReadLn())
   nTamProc := nPosProc + At(";",SubStr(FT_FReadLn(),nPosProc+1))-7
   aLayout  := GetLayout(nTamProc)
   lRetVazio := .T.

   If Type("oProgress") == "O"
      lProcRegua:= .T.
   EndIf

   Do While !FT_FEOF()
      oLinha := RetDados(FT_FReadLn(), "", aLayout)
      oDados := RetDados(oLinha:GetValue("Conteudo"),oLinha:GetValue("Identificador"), aLayout)

      //O numero do processo está entre os caracteres de ";"
      If oLinha:GetValue("Identificador") != "FIM" .AND. oDados:GetValue("PROC") <> NIL
         cProc := oDados:GetValue("PROC")
         nPos1 := At(";",cProc)
         nPos2 := Rat(";",cProc)
         oDados:SetField("PROC",SubStr(cProc,nPos1+1,nPos2-nPos1-1))
         lRetVazio := .F.
         If oDados:GetValue("NROREG") <> NIL
            //RRC - 30/04/2013
            If !Empty(oDados:GetValue("NROREG")) //MCF - 27/01/2015
            	 //cNroReg := LimpaHtml(oDados:GetValue("NROREG")) //MCF - 22/02/2016
               oDados:SetField("NROREG",StrTran(oDados:GetValue("NROREG"),"/",""))
            EndIf
         EndIf

         //RRC - 30/04/2013 - Tratamento para retirar a "/" no momento da geração do arquivo de retorno
         If oDados:GetValue("PAG_NROREG") <> NIL
            If !Empty(oDados:GetValue("PAG_NROREG"))
               oDados:SetField("PAG_NROREG",StrTran(oDados:GetValue("PAG_NROREG"),"/",""))
            EndIf
         EndIf

         cTipoReg := ""
         If oLinha:GetValue("Identificador") $ "REG_RVS/RET_RVS/REG_RAS/RET_RAS"
            cTipoReg := "REGISTRO"
         ElseIf oLinha:GetValue("Identificador") $ "REG_ADT/RET_ADT"
            cTipoReg := "ADITIVO"
         ElseIf oLinha:GetValue("Identificador") $ "REG_FAT/CAN_FAT/RET_FAT"
            cTipoReg := "PAGAMENTO"
         EndIf
         If !Empty(cErros)
            cErros += ENTER
         EndIf

         cErros += oDados:GetValue("ERROS")

         If oDados:GetValue("NROREG") == StrTran(cErros,"/","") //MCF - 22/02/2016 - Tag do Skype.
            oDados:SetField("ERROS","")
            cErros := ""
         EndIf

         //RRC - 26/09/2013 - Não efetua o processamento caso número de registro e número de pagamento em branco
         //MCF - 18/01/2016 - Adicionado validação para caso o site retorne o número do registro 000000000000 devido a instabilidade
         If Empty(oDados:GetValue("ERROS"))
            If !(oDados:GetValue("NROREG") <> NIL .And. Empty(StrTran(oDados:GetValue("NROREG"),"0",""))) .And. !(cTipoReg == "PAGAMENTO" .And. Empty(StrTran(oDados:GetValue("PAG_NROREG"),"0","")))
                SS101DadosRet(cTipoReg, oDados)
            Else
               oErros:Error("Não foi possível processar o lote devido a problemas no retorno do site SISCOSERV.")
               cErros := oErros:GetStrErrors()
            EndIf
         Else
            oErros:Error(oDados:GetValue("ERROS"))
         Endif
         If lProcRegua
            oProgress:IncRegua()
         EndIf
      Else
         If lRetVazio
            oErros:Error("Não foi possível processar o lote devido a problemas no retorno do site SISCOSERV.")
         EndIf
      EndIf
      oErros:Error(oDados:aError)
      oErros:Warning(oDados:aWarning)
      FT_FSKIP()
   EndDo

   End Transaction

   FT_FUse()

   //RRC - 24/10/2012
   SS101GrvEL8(PROCESSADO,EL8->EL8_TPPROC,EL8->EL8_TIPENV,EL8->EL8_IDLOTE,cErros)

End Sequence

Return !oErros:HasErrors()

Static Function RetDados(cConteudo, cTipoReg, aLayout)
Local oDados := ERec():New()
Local aLayReg, i
Local xDado

If cTipoReg <> NIL .AND. (nPosLay := aScan(aLayOut,{|X| cTipoReg == X[1] .OR. cTipoReg $ X[1]})) > 0
   aLayReg := aLayout[nPosLay][2]

   nInicio := 1
   nFim    := 0

   cConteudo := LimpaHtml(cConteudo) //MCF - 22/02/2016 - Realiza tratamento para a tag do skype.

   For i := 1 To Len(aLayReg)
      If ValType(aLayReg[i][3]) == "N"
         nFim += aLayReg[i][3]
      Else
         nFim := Nil
      EndIf

      If aLayReg[i][2] == "C"
         xDado := SubStr(cConteudo,nInicio,(If(nFim <> NIL, Min(nFim,Len(cConteudo)) ,Len(cConteudo))- If(nInicio<>1,(nInicio-1),0) ))
      EndIf
      oDados:AddField(aLayReg[i][1],xDado)

      If nFim == NIL
         EXIT
      Else
         nInicio := nFim+1
      EndIf
   Next i

EndIf

Return oDados

Static Function GetLayout(nTamProc)
Local aReg
Local aLayouts := {}
Local nTam
/*RRC - 02/10/2013 - O layout do arquivo sofreu alteração (Processo tinha tamanho 20 e passou a ter 100) e se faz necessário identificar qual layout foi utilizado na criação do arquivo.*/

//Layout Registro Principal
aReg := {}
aAdd(aReg,{'Identificador','C',7    ,0})
aAdd(aReg,{'Conteudo'     ,'C','MAX',0})
aAdd(aLayouts,{"",aClone(aReg)})

nTam := if(nTamProc >= 100, 100, 20)

//Layout da Linha do Registro
aReg := {}
aAdd(aReg,{'PROC'  ,'C',nTamProc,0})
aAdd(aReg,{'NROREG','C',11,0}) //MCF - 27/01/2015
aAdd(aReg,{'ERROS' ,'C', ,0})

aAdd(aLayouts,{"REG_RVS/RET_RVS/REG_RAS/RET_RAS",aClone(aReg)})

//Layout da Linha do Aditivo
aReg := {}
aAdd(aReg,{'PROC'       ,'C',nTamProc,0})
aAdd(aReg,{'PROC_NROREG','C',11,0})
aAdd(aReg,{'SEQAD'      ,'C',3 ,0})
aAdd(aReg,{'AD_NROREG'  ,'C',3 ,0})
aAdd(aReg,{'ERROS'      ,'C',  ,0})

aAdd(aLayouts,{"REG_ADT/RET_ADT",aClone(aReg)})

//Layout da Linha do Pagamento
aReg := {}
aAdd(aReg,{'PROC'       ,'C',nTamProc,0})
aAdd(aReg,{'PROC_NROREG','C',11,0})
aAdd(aReg,{'PAGID'      ,'C',nTam,0})
aAdd(aReg,{'DOC'        ,'C',nTam,0})
aAdd(aReg,{'PAG_NROREG' ,'C',nTam,0})
aAdd(aReg,{'ERROS'      ,'C',  ,0})

aAdd(aLayouts,{"REG_FAT/CAN_FAT/RET_FAT",aClone(aReg)})

Return aClone(aLayouts)

Static Function LimpaHtml(cConteudo) //Remove tags HTML da string de retorno.
Local nIni, nFim

While (nIni := At("<", cConteudo)) > 0 .And. (nFim := At(">", SubStr(cConteudo, nIni))) > 0
cConteudo := StrTran(cConteudo, SubStr(cConteudo, nIni, nFim), "")
EndDo

Return cConteudo

Static Function INIProxy()
Local oUserParams := EASYUSERCFG():New("ESSCI100")
Local cProxyURL   := oUserParams:LoadParam("PROXYURL","","ESSCI100")
Local cProxyPort  := oUserParams:LoadParam("PROXYPRT","","ESSCI100")
Local cProxyUser  := oUserParams:LoadParam("PROXYUSR","","ESSCI100")
Local cProxyPass  := oUserParams:LoadParam("PROXYPSS","","ESSCI100")
Local cINI        := ""

	cINI += "[WebClientOptions]"		 				+ ENTER
	If !Empty(cProxyURL)
	   cINI += "proxy.enabled=TRUE"		 				+ ENTER
	   cINI += "proxy.type=DEFAULT"		 				+ ENTER
	   cINI += "proxy.host="+AllTrim(cProxyURL)			+ ENTER
	   cINI += "proxy.port="+AllTrim(cProxyPort)		+ ENTER
	   cINI += "proxy.user="+AllTrim(cProxyUser)		+ ENTER
	   cINI += "proxy.pass="+AllTrim(cProxyPass)		+ ENTER
	Else
	   cINI += "proxy.enabled=FALSE"		 			+ ENTER
	EndIf
	If EasyGParam("MV_ESS0027",,9) >= 10
	   cINI += "connectionTimeout=90"					+ ENTER
       cINI += "socketTimeout=90"						+ ENTER
	   cINI += "connectionRequestTimeout=90"			+ ENTER
	EndIf

Return cINI
