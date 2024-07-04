#Include "EEC.cH"
#Include "EECREG85.CH"
#Include "TOTVS.CH"
/*
Programa  : EECIREG85.PRW
Objetivo  : Gerar arquivo do convênio ICMS 015/2005.
Autor     : Rodrigo Mendes Diaz
Data/Hora : 11/07/05
*/

Function EECREG85

Local aYK := {{"01","AWB"},{"02","MAWB"},{"03","HAWB"},;    // By JPP - 18/07/2005 - 11:00
              {"04","COMAT"},{"06","R. EXPRESSAS"},{"07","ETIQ. REXPRESSAS"},;
              {"08","HR.EXPRESSAS"},{"09","AV7"},{"10","BL"},;
              {"11","MBL"},{"12","HBL"},{"13","CRT"},;
              {"14","DSIC"},{"16","COMAT BL"},{"17","RWB"},;
              {"18","HRWB"},{"19","TIF/DTA"},{"20","CP2"},;
              {"91","NÃO IATA"},{"92","NNAO IATA"},{"93","HNAO IATA"},;
              {"99","OUTROS"}},;
      aYM := {{"24","Autorização de Carregamento e Transporte, modelo 24"},;
              {"14","Bilhete de Passagem Aquaviário, modelo 14"},;
              {"15","Bilhete de Passagem e Nota de Bagagem, modelo 15"},;
              {"16","Bilhete de Passagem Ferroviario, modelo 16"},;
              {"13","Bilhete de Passagem Rodoviário, modelo 13"},;
              {"10","Conhecimento Aéreo, modelo 10"},;
              {"11","Conhecimento de Transporte Ferroviário de Cargas, modelo 11"},;
              {"09","Conhecimento de Transporte Aquaviário de Cargas, modelo 9"},;
              {"08","Conhecimento de Transporte Rodoviário de Cargas, modelo 8"},;
              {"17","Despacho de Transporte, modelo 17"},;
              {"25","Manifesto de Carga, modelo 25"},;
              {"01","Nota Fiscal, modelo 1"},;
              {"06","Nota Fiscal/Conta de Energia Elétrica, modelo 6"},;
              {"03","Nota Fiscal de Entrada, modelo 3"},;
              {"21","Nota Fiscal de Serviço de Comunicação, modelo 21"},;
              {"04","Nota Fiscal de Produtor, modelo 4"},;
              {"22","Nota Fiscal de Serviço de Telecomunicações, modelo 22"},;
              {"07","Nota Fiscal de Serviço de Transporte, modelo 7"},;
              {"02","Nota Fiscal de Venda a Consumidor, modelo 02"},;
              {"20","Ordem de Coleta de Carga, modelo 20"},;
              {"18","Resumo Movimento Diário, modelo 18"}},;
      nInd



Local lProc := .F.

Private dGetAVRB1  := Ctod( "  /  /  " ),;            // Váriavel Data Inicial da Averbacao.
        dGetAVRB2  := Ctod( "  /  /  " ),;            // Váriavel Data Final da Averbacao.
        dGetNF1    := Ctod( "  /  /  " ),;            // Váriavel Data Inicial da Nota Fiscal.
        dGetNF2    := Ctod( "  /  /  " ),;            // Váriavel Data Final da Nota Fiscal.
        dGetEMB1   := Ctod( "  /  /  " ),;            // Váriavel Data Inicial do Embarque.
        dGetEMB2   := Ctod( "  /  /  " ),;            // Váriavel Data Final do Embarque.
        cGetFile   := IncSpace( EasyGParam( "MV_AVG0098",, "C:\Registro85.txt" ), 100, .F. )

Private lAVRB   := .F.,;
        lNF     := .F.,;
        lEMB    := .F.,;
        lFILTRO := .T.

Private aEEC    := {}

Private cPaisDt := "" //ER - 04/09/2007

Private lLogix := AVFlags("EEC_LOGIX") //FSM - 17/01/2012 - Tratamento para Integração com LOGIX
Private nOpRad := 0 //opção do Botão tipo Radio
Private aRotina   := MenuDef() // GFP - 27/01/2012 - Integração Logix

Begin Sequence
   If TelaGets()
      MSAguarde( {|| If( FiltraDados(), MSAguarde( {|| GeraTxt() }, STR0032 ), )  }, STR0031 )
   EndIf
End Sequence

Return Nil

/*
Função     : TelaGets
Objetivo   : Apresentar caixa de dialogo, solicitando o preenchimento de informações ao usuário.
Autor      : Rodrigo Mendes Diaz
Parametros : Nenhum.
Retorno    : .T. ou .F.
*/

Static Function TelaGets()

Local bOk        := { || If  ( ValidaDados( .F. ), ( lRet := .T., oDlg:End() ), ) } ,;
      bCancel    := { || lRet := .F., oDlg:End() } ,;
      lRet       := .F.

Local aObjFiltro := { { "oGetAVRB1", "oSayAte1", "oGetAVRB2", "oCBAVRB", "dGetAVRB1", "dGetAVRB2" },; // Objetos e campos da Data de Averbação.
                      { "oGetNF1",   "oSayAte2", "oGetNF2",   "oCBNF",   "dGetNF1",   "dGetNF2"   },; // Objetos e campos da Data da Nota Fiscal.
                      { "oGetEMB1",  "oSayAte3", "oGetEMB2",  "oCBEMB",  "dGetEMB1",  "dGetEMB2"  } } // Objetos e campos da Data de Embarque.


Local nLinha := 1

nOpRad := If(ValType("nOpRad")=="N",nOpRad ,0)

// BAK - Ajuste do tamanho de tela
Define MsDialog oDlg Title STR0001 From 0, 0 To 430, 380 Of oMainWnd Pixel

      oPanel:= TPanel():New(0, 0, "", oDlg,, .F., .F.,,, 90, 165) //MCF - 15/07/2015 - Ajustes Tela P12.
      oPanel:Align:= CONTROL_ALIGN_ALLCLIENT

      //Sem Filtro
      @ nLinha+020, 015 CheckBox oCBFILTRO Var lFILTRO Prompt STR0034 Size 040,08 On Click ObjetoChange( aObjFiltro, 0, lFILTRO ) Of oPanel Pixel

      // Intervalo de datas de Averbação
      @ nLinha+030, 009 To nLinha+062, 170 Label "" Of oPanel Pixel
      @ nLinha+034, 015 CheckBox oCBAVRB Var lAVRB Prompt STR0002 Size 090,08 On Click ObjetoChange( aObjFiltro, 1, lAVRB ) Of oPanel Pixel

      @ nLinha+045, 015 MsGet oGetAVRB1 Var dGetAVRB1 Valid ValidaDados() Size 40, 08 Of oPanel Pixel
      @ nLinha+046, 062 Say oSayAte1  Var STR0033 Pixel Of oPanel
      @ nLinha+045, 085 MsGet oGetAVRB2 Var dGetAVRB2 Valid ValidaDados() Size 40, 08 Of oPanel Pixel

	  // Intervalo de datas da emissão da NF
      @ nLinha+066, 009 To nLinha+98, 170 Label "" Of oPanel Pixel
      @ nLinha+070, 015 CheckBox oCBNF Var lNF Prompt STR0003 Size 100,08 On Click ObjetoChange( aObjFiltro, 2, lNF ) Of oPanel Pixel

      @ nLinha+081, 015 MsGet oGetNF1 Var dGetNF1 Valid ValidaDados() Size 40, 08 Of oPanel Pixel
      @ nLinha+082, 062 Say oSayAte2  Var STR0033 Pixel Of oPanel
      @ nLinha+081, 085 MsGet oGetNF2 Var dGetNF2 Valid ValidaDados() Size 40, 08 Of oPanel Pixel

      // Intervalo de datas de Embarque
      @ nLinha+103, 009 To nLinha+135, 170 Label "" Of oPanel Pixel
      @ nLinha+105, 015 CheckBox oCBEMB Var lEMB Prompt STR0004 Size 88,08 On Click ObjetoChange( aObjFiltro, 3, lEMB ) Of oPanel Pixel

      @ nLinha+118, 015 MsGet oGetEMB1 Var dGetEMB1 Valid ValidaDados() Size 40, 08 Of oPanel Pixel
      @ nLinha+119, 062 Say oSayAte3  Var STR0033 Pixel Of oPanel
      @ nLinha+118, 085 MsGet oGetEMB2 Var dGetEMB2 Valid ValidaDados()  Size 40, 08 Of oPanel Pixel


      @ nLinha+137, 009 To nLinha+169, 170 Label If(!lLogix,STR0005,"Operacao Logix") Of oPanel Pixel

      If !lLogix //FSM - 17/01/2012 - Tratamento para Integração com LOGIX

         // Destino dos arquivos
         @ nLinha+148, 015 MsGet oGetPath Var cGetFile Size 120, 08 Of oPanel Pixel
         @ nLinha+148, 138 Button "..." Size 10,10 Pixel Action ( oGetPath:Refresh(), cGetFile := ChooseFile() ) Of oPanel

      Else

         @ nLinha+148, 015 RADIO oRadio VAR nOpRad ITEMS "Inclusao","Estorno" 3D Size 68,10 Of oPanel Pixel

      EndIf

   ObjetoChange( aObjFiltro )

Activate MSDialog oDlg On Init EnchoiceBar( oDlg, bOk, bCancel ) Centered


Return( lRet )

/*
Função     : ObjetoChange
Objetivo   : Habilitar ou Desabilitar objetos.
Autor      : Rodrigo Mendes Diaz
Parametros : aObjetos -> Array com o(s) objeto(s) a serem habilitados ou desabilitados,
                         conforme o parametro nPos
             lCHBOX   -> Indica se os objetos serão habilitados ou não.
             nPos     -> Indica quais objetos serão habilitados.
Retorno    : Nenhum.
*/

Static Function ObjetoChange( aObjetos, nPos, lCHBOX )
Local x := 0, y := 0
Default nPos := 0, lCHBOX := .F.


If nPos > 0  //Verifica se a função foi chamada por algum filtro
   If lCHBOX //Verifica se o filtro foi marcado ou desmarcado
      For x := 1 To 3
         &( aObjetos[nPos][x] + ":Enable()"  )
         &( aObjetos[nPos][4] + ":Refresh()" )
      Next x
      //Desmarca a opção "Sem Filtro"
      lFILTRO := .F.
      oCBFILTRO:Refresh()
   Else
      //Desabilita os objetos e reinicia as variáveis referentes aos mesmos
      &( aObjetos[nPos][5] ) := Ctod( "  /  /  " )
      &( aObjetos[nPos][6] ) := Ctod( "  /  /  " )
      &( aObjetos[nPos][4]    + ":Refresh()" )
      For x := 1 To 3
         &( aObjetos[nPos][x] + ":Disable()"  )
         &( aObjetos[nPos][x] + ":Refresh()" )
      Next x
   EndIf

ElseIf lFILTRO //Desabilita todos os filtros e reinicia todas as variáveis referentes a filtros
   lNF := lEMB := lAVRB := .F.
   For x:= 1 To 3
      &( aObjetos[x][5] ) := Ctod( "  /  /  " )
      &( aObjetos[x][6] ) := Ctod( "  /  /  " )
      &( aObjetos[x][4]  + ":Refresh()" )
      For y := 1 To 3
         &( aObjetos[x][y]  + ":Disable()" )
         &( aObjetos[x][y]  + ":Refresh()" )
      Next y
   Next x

End If

Return Nil

/*
Funcao     : ChooseFile()
Objetivos  : Abrir janela para escolha do diretório e do arquivo a ser gravado.
Autor      : Rodrigo Mendes Diaz
Parametros : Nenhum.
Retorno    : cFile - Arquivo selecionado
*/

Static Function ChooseFile()

Local cTitle:= STR0006
Local cMask := STR0007 + "|*.txt |" + STR0030 + "|*.*"
Local cFile := ""
Local nDefaultMask := 0
Local cDefaultDir  := "C:\"
Local nOptions:= GETF_OVERWRITEPROMPT+GETF_LOCALHARD+GETF_NETWORKDRIVE

cFile := cGetFile(cMask,cTitle,nDefaultMask,cDefaultDir,,nOptions)

If Empty(cFile)
   Return cGetFile
EndIf

Return IncSpace( cFile, 100, .f.)

/*
Função     : ValidaDados
Objetivo   : Validar os dados informados na tela.
Autor      : Rodrigo Mendes Diaz
Parametros : lGet -> Indica se a função foi chamada por uma Get
Retorno    : .T. ou .F.
*/

Static Function ValidaDados( lGet )
Local lRet := .T.
Default lGet := .T.

   If lAVRB    // Intervalo de datas de Averbação.
      If !Empty( dGetAVRB1 ) .and. !Empty( dGetAVRB2 ) .and. dGetAVRB1 > dGetAVRB2
         MsgAlert( STR0008, STR0025  )
         lRet := .F.
      EndIf
      If !lGet .And. Empty( dGetAVRB1 ) .And. Empty( dGetAVRB2 )
         MsgAlert( STR0009, STR0025 )
         lRet := .F.
      EndIf
   EndIf

   If lNF    // Intervalo de datas da emissão da NF.
      If !Empty( dGetNF1 ) .and. !Empty( dGetNF2 ) .and. dGetNF1 > dGetNF2
         MsgAlert( STR0010, STR0025  )
         lRet := .F.
      EndIf
      If !lGet .And. Empty( dGetNF1 ) .And. Empty( dGetNF2 )
         MsgAlert( STR0011, STR0025 )
         lRet := .F.
      EndIf
   EndIf

   If lEMB    // Intervalo de datas de Embarque.
      If !Empty( dGetEMB1 ) .and. !Empty( dGetEMB2 ) .and. dGetEMB1 > dGetEMB2
         MsgAlert( STR0012, STR0025  )
         lRet := .F.
      EndIf
      If !lGet .And. Empty( dGetEMB1 ) .And. Empty( dGetEMB2 )
         MsgAlert( STR0013, STR0025 )
         lRet := .F.
      EndIf
   EndIf

   If lRet .And. !lGet
      Begin Sequence

         //FSM - 19/01/2012 - Tratamento para Integração Protheus X Logix
         If lLogix .And. nOpRad == 0
            MsgInfo("Informar o tipo de operação da integração.", STR0025 )
            lRet := .F.
            Break
         EndIf

         If !lLogix  // GFP - 30/01/2012
	         cGetFile := AllTrim( cGetFile )
	         nPos := Rat( "\", cGetFile )
	         If nPos = Len( cGetFile ) .Or. nPos = 0 .Or. Empty( cGetFile )
	            MsgAlert( STR0014, STR0025 )
	            cGetFile := Space( 100 )
	            lRet := .F.
	            Break
	         EndIf
	         If Right( cGetFile, 4 ) <> ".txt" .And. Right( cGetFile, 4 ) <> ".TXT"
	            cGetFile += ".txt"
	         Else
	            If ( nPos = Len( cGetFile ) - 4 )
	               MsgAlert( STR0015, STR0025 )
	               lRet := .F.
	               Break
	            EndIf
	         EndIf
	         If File( cGetFile )
	            If !lLogix
	               If !(MsgYesNo( STR0016 + cGetFile + STR0017 + ENTER + STR0018, STR0025 ))
	                  lRet := .F.
	               EndIf
	            EndIf
	         EndIf
	         If !lIsDir( SubStr( cGetFile, 1, nPos ) )
	            If MsgYesNo( STR0019 + ENTER + STR0020, STR0024  )
	               If MakeDir( SubStr( cGetFile, 1, nPos ) ) = 0
	                  MsgInfo( STR0021, STR0023 )
	               Else
	                  MsgAlert( STR0022, STR0023 )
	                  cGetFile := IncSpace( cGetFile, 100, .F. )
	                  lRet := .F.
	                  Break
	               EndIf
	            Else
	               lRet := .F.
	               Break
	            EndIf
	         EndIf

	         cGetFile := IncSpace( cGetFile, 100, .F. )
	         SetMV( "MV_AVG0098", cGetFile )

	      EndIf

      End Sequence
   EndIf

Return( lRet )

/*
Função     : FiltraDados()
Objetivo   : Gerar o Array aEEC com os embarques que se enquadram nas condições de filtro.
Autor      : Rodrigo Mendes Diaz
Parametros : Nenhum.
Retorno    : .T. ou .F.
*/

Static Function FiltraDados()

Local lRet := .T.
Local cQry
Local cDTAVBR := ""
Local cDUEAVR := ""
Local cDTDUE  := ""
Local cDTAVBR2:= ""
Local cDUEAVR2:= ""
Local cDTDUE2 := ""
Local cQryAVRB:= ""
Local cCmpDUE := ""

Begin Sequence

#IFDEF TOP

      // cQry := "Select EEC_PREEMB , EEC_NRCE, EEC_DTCE, EEC_NRCONH, EEC_DTCONH, EEC_PAISDT, EEC_TOTPED, EE9_PREEMB, EEM_PREEMB, YQ_TDC "  // By JPP - 28/04/2006 - 17:30
      cQry := "Select EEC_PREEMB ,EEC_NRCONH, EEC_DTCONH, EEC_DTEMBA, EEC_PAISDT, EEC_TOTPED, EE9_PREEMB, EE9_PEDIDO, EE9_SEQUEN, EEM_PREEMB, YQ_TDC "
      If EEC->(FieldPos("EEC_NRODUE")) > 0 //THTS - 06/12/2017
         cQry += ", EEC_NRODUE"
      EndIf
      If EEC->(FieldPos("EEC_DTDUE")) > 0
         cQry += ", EEC_DTDUE"
      EndIf
      If EEC->(FieldPos("EEC_DUEAVR")) > 0
         cQry += ", EEC_DUEAVR"
      EndIf
      cQry += "From " + RetSqlName("EEC") + " EEC, " + RetSqlName("EE9") + " EE9, " + RetSqlName("EEM") + " EEM, " + RetSqlName("SYQ") + " SYQ "
      
      cQry += "Where EEC.D_E_L_E_T_ <> '*' and EEC_FILIAL = '" + xFilial("EEC") + "' "
      cQry += "and EE9.D_E_L_E_T_ <> '*' and EE9_FILIAL = '" + xFilial("EE9") + "'       "
      cQry += "and EEM.D_E_L_E_T_ <> '*' and EEM_FILIAL = '" + xFilial("EEM") + "'       "
      cQry += "and SYQ.D_E_L_E_T_ <> '*' and YQ_FILIAL = '" + xFilial("SYQ") + "'        "
      cQry += "and EE9_PREEMB = EEC_PREEMB and EEM_PREEMB = EEC_PREEMB  and YQ_VIA = EEC_VIA "

      If EEC->(FieldPos("EEC_DUEAVR")) > 0
         cQry += "and (EE9_DTAVRB <> ' ' or EEC_DUEAVR <> ' ') " //" + SPACE( AVSX3( "EE9_DTAVRB", AV_TAMANHO ) ) + "
      elseIf EEC->(FieldPos("EEC_DTDUE")) > 0
         cQry += "and (EE9_DTAVRB <> ' ' or EEC_DTDUE <> ' ') "
      Else
         cQry += "and EE9_DTAVRB <> ' ' " //" + SPACE( AVSX3( "EE9_DTAVRB", AV_TAMANHO ) ) + "
      EndIf

      cQry += "and EEM_DTNF <> '" + SPACE( AVSX3( "EEM_DTNF", AV_TAMANHO ) ) + "' "

      If AVFLAGS("EEC_LOGIX")
         cQry += "and EEM_TIPONF IN ('1','2') " //NCF - 20/02/2014 - Contempla envio da NF Complementar para registro no SINTEGRA 85
      Else
         cQry += "and EEM_TIPONF <> '2' " // By JPP - 23/03/2006 - 14:25 - Nota fiscal complementar
      EndIf

      cQry += "and EEC_DTEMBA <> '" + SPACE( AVSX3( "EEC_DTEMBA", AV_TAMANHO ) ) +"' "
      cQry += "and EE9_NF <> ' ' "
      
      Do Case
         Case lAVRB
            If !Empty( dGetAVRB1 )
                  cDTAVBR += " EE9_DTAVRB >= '" + DTOS( dGetAVRB1 ) + "' ""
                  If EEC->(FieldPos("EEC_DUEAVR")) > 0
                     cDUEAVR += " EEC_DUEAVR >= '" + DTOS( dGetAVRB1 ) + "' "
                     cCmpDUE := " EEC_DUEAVR = ' ' "
                  ElseIf EEC->(FieldPos("EEC_DTDUE")) > 0
                     cDTDUE  += " EEC_DTDUE  >= '" + DTOS( dGetAVRB1 ) + "' "
                     cCmpDUE := " EEC_DTDUE = ' ' "
                  Endif
            EndIf
            If !Empty( dGetAVRB2 )
                  cDTAVBR2 += " EE9_DTAVRB <= '" + DTOS( dGetAVRB2 ) + "' "
                  If EEC->(FieldPos("EEC_DUEAVR")) > 0
                     cDUEAVR2 += " EEC_DUEAVR <= '" + DTOS( dGetAVRB2 ) + "' "
                     cCmpDUE := " EEC_DUEAVR = ' ' "
                  ElseIf EEC->(FieldPos("EEC_DTDUE")) > 0
                     cDTDUE2 += " EEC_DTDUE <= '" + DTOS( dGetAVRB2 ) + "' "
                     cCmpDUE := " EEC_DTDUE = ' ' "
                  Endif
            EndIf
            cDTAVBR := cDTAVBR + IIF(!Empty(cDTAVBR) .And. !Empty(cDTAVBR2),"AND","") + cDTAVBR2 + " AND " + cCmpDUE
            cDUEAVR := cDUEAVR + IIF(!Empty(cDUEAVR) .And. !Empty(cDUEAVR2),"AND","") + cDUEAVR2
            cDTDUE  := cDTDUE  + IIF(!Empty(cDTDUE)  .And. !Empty(cDTDUE2),"AND","")  + cDTDUE2

            If !Empty(cDTAVBR)
                  cQryAVRB += " (EE9_DTAVRB <> ' ' AND " + cDTAVBR + ") "
            EndIf
            If !Empty(cDUEAVR)
                  cQryAVRB += IIF(!Empty(cQryAVRB)," OR ","") + "(EEC_DUEAVR <> ' ' AND " + cDUEAVR + ") "
            EndIf
            If !Empty(cDTDUE)
                  cQryAVRB += IIF(!Empty(cQryAVRB)," OR ","") + "(EEC_DTDUE <> ' ' AND " + cDTDUE + ") "
            EndIf
            cQry += "and ( " + cQryAVRB + " )"

         Case lNF
            If !Empty( dGetNF1 )
               cQry += "and EEM_DTNF >= '" + DTOS( dGetNF1 ) + "' "
            EndIf
            If !Empty( dGetNF2 )
               cQry += "and EEM_DTNF <= '" + DTOS( dGetNF2 ) + "' "
            EndIf

         Case lEMB
            If !Empty( dGetEMB1 )
               cQry += "and EEC_DTEMBA >= '" + DTOS( dGetEMB1 ) + "' "
            EndIf
            If !Empty( dGetEMB2 )
               cQry += "and EEC_DTEMBA <= '" + DTOS( dGetEMB2 ) + "' "
            EndIf

      EndCase

      cQry := ChangeQuery(cQry)

      If Select("QEEC") > 0  // GFP - 30/01/2012
         QEEC->(DbCloseArea())
      EndIf

      dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry), "QEEC", .F., .T.)
      EasyTCFields("QEEC")

      If IsVazio( "QEEC" )
         MsgInfo( STR0026, STR0024 )
         lRet := .F.
         QEEC->(DbCloseArea())
         Break
      EndIf

      Do While QEEC->( !EOF() )
         If ASCAN( aEEC,{|x| x[2] == QEEC->EEC_PREEMB } ) == 0

            //ER - 04/09/2007 - Novo Layout (Alteração no país)
            SYA->(DbSetOrder(1))
            If SYA->(DbSeek(xFilial("SYA")+AvKey(QEEC->EEC_PAISDT,"YA_CODGI")))
               If  SYA->(FieldPos("YA_SISEXP")) > 0
                  If !Empty(SYA->YA_SISEXP)
                     cPaisDt := Substr(SYA->YA_SISEXP,1,3) //IncSpace(SYA->YA_SISEXP,4)  NCF - 10/03/2014 - O código com 4 dig. ocasiona rejeição do SPED
                  EndIf
               EndIf
            EndIf

            If Empty(cPaisDt)
               cPaisDt := IncSpace(QEEC->EEC_PAISDT,4)
            EndIf

            EXL->(DBSeek(xFilial() + QEEC->EEC_PREEMB))

            AADD( aEEC,{ QEEC->( RecNo() )									                     ,; // 01 - 
                        QEEC->EEC_PREEMB 										                     ,; // 02 - 
                        Nil 												                           ,; // 03 - 
                        Nil 												                           ,; // 04 - 
                        QEEC->EEC_NRCONH										                     ,; // 05 - 
                        If(AVFLAGS("EEC_LOGIX"),dtos(QEEC->EEC_DTEMBA),dtos(QEEC->EEC_DTCONH)),; // 06 - 
                        cPaisDt											                           ,; // 07 - 
                        QEEC->EEC_TOTPED									                        ,; // 08 - 
                        QEEC->YQ_TDC										                        ,; // 09 - NCF - 16/05/2014 - Enviar data de embarque quando integrado ao Logix
                        IIf(EEC->(FieldPos("EEC_NRODUE")) > 0 ,QEEC->EEC_NRODUE,"")			,; // 10 - THTS - 06/12/2017 - Passa o numero DUE quando existir ou branco
                        IIf(EEC->(FieldPos("EEC_DTDUE")) > 0, dtos(QEEC->EEC_DTDUE),dtos(EXL->EXL_DTDSE)) ,; // 11 - 
                        QEEC->EE9_PEDIDO										                     ,; // 12 - 
                        QEEC->EE9_SEQUEN										                     }) // 13 - 
         EndIf
         QEEC->( dbSkip() )
      End
      QEEC->(DbCloseArea())
#Else

   EEC->( dbSetOrder( 1 ) )
   EEM->( dbSetOrder( 1 ) )
   EE9->( dbSetOrder( 2 ) )//EE9_FILIAL+EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN

      Do Case
         // Filtro por Intervalo de datas de averbação.
         Case lAVRB
            EE9->( dbSeek( xFilial( "EE9" ) ) )
            While EE9->( !Eof() .and. EE9_FILIAL == xFilial( "EE9" ) )
               //Posiciona a Tabela EEC no embarque encontrado.
               If EEC->( dbSeek( xFilial( "EEC" ) + EE9->EE9_PREEMB ) )

                  //Filtra os dados conforme datas informadas
                  If ( !Empty( dGetAVRB1 ) .And. !Empty( dGetAVRB2 ) )

                     If (EE9->EE9_DTAVRB >= dGetAVRB1 .And. EE9->EE9_DTAVRB <= dGetAVRB2)
                        lFiltro := .T.
                     EndIf

                     If EEC->(FieldPos("EEC_DUEAVR")) > 0 .and. !lFiltro
                        If (EEC->EEC_DUEAVR >= dGetAVRB1 .And. EEC->EEC_DUEAVR <= dGetAVRB2)
                           lFiltro := .T.
                        EndIf
                     ElseIf EEC->(FieldPos("EEC_DTDUE")) > 0 .and. !lFiltro
                        If (EEC->EEC_DTDUE >= dGetAVRB1 .And. EEC->EEC_DTDUE <= dGetAVRB2)
                           lFiltro := .T.
                        EndIf
                     Endif

                  ElseIf !Empty( dGetAVRB1 ) 
                  
                     If ( EE9->EE9_DTAVRB >= dGetAVRB1 )
                        lFiltro := .T.
                     EndIf

                     If EEC->(FieldPos("EEC_DUEAVR")) > 0 .and. !lFiltro
                        If ( EEC->EEC_DUEAVR >= dGetAVRB1 )
                           lFiltro := .T.
                        EndIf
                     ElseIf EEC->(FieldPos("EEC_DTDUE")) > 0 .and. !lFiltro
                        If ( EEC->EEC_DTDUE >= dGetAVRB1 )
                           lFiltro := .T.
                        EndIf
                     Endif

                  ElseIf !Empty(dGetAVRB2) // .And. EE9->EE9_DTAVRB <= dGetAVRB2 

                     If ( EE9->EE9_DTAVRB <= dGetAVRB2 )
                        lFiltro := .T.
                     EndIf

                     If EEC->(FieldPos("EEC_DUEAVR")) > 0  .and. !lFiltro
                        If ( EEC->EEC_DUEAVR <= dGetAVRB2 )
                           lFiltro := .T.
                        EndIf
                     ElseIf EEC->(FieldPos("EEC_DTDUE")) > 0 .and. !lFiltro
                        If ( EEC->EEC_DTDUE <= dGetAVRB2 )
                           lFiltro := .T.
                        EndIf
                     Endif
                  EndIf

                  //Verifica se existe uma Nota Fiscal relacionada ao embarque.
                  If EEM->( dbSeek( xFilial( "EEM" ) + EEC->EEC_PREEMB ) )
                     //Localiza o tipo de documento de carga, conforme via de transporte ref. ao embarque
                     SYQ->( dbSeek( xFilial( "SYQ" ) + EEC->EEC_VIA ) )
                     //Inclui o embarque no array aEEC caso isto já não tenha sido feito
                     If ASCAN( aEEC,{|x| x[2] = EEC->EEC_PREEMB } ) = 0

                        //ER - 04/09/2007 - Novo Layout (Alteração no país)
                        SYA->(DbSetOrder(1))
                        If SYA->(DbSeek(xFilial("SYA")+AvKey(EEC->EEC_PAISDT,"YA_CODGI")))
                           If  SYA->(FieldPos("YA_SISEXP")) > 0
                              If !Empty(SYA->YA_SISEXP)
                                 cPaisDt := Substr(SYA->YA_SISEXP,1,3) //IncSpace(SYA->YA_SISEXP,4)  NCF - 10/03/2014 - O código com 4 dig. ocasiona rejeição do SPED
                              EndIf
                           EndIf
                        EndIf

                        If Empty(cPaisDt)
                           cPaisDt := IncSpace(EEC->EEC_PAISDT,4)
                        EndIf

                        EXL->(DBSeek(xFilial() + EEC->EEC_PREEMB))
                        AADD( aEEC,{ EEC->( RecNo() ), EEC->EEC_PREEMB, Nil,Nil ,;
                        EEC->EEC_NRCONH, If(AVFLAGS("EEC_LOGIX"),DTOS( EEC->EEC_DTEMBA ),DTOS( EEC->EEC_DTCONH )), cPaisDt, EEC->EEC_TOTPED, SYQ->YQ_TDC,; //NCF - 16/05/2014 - Enviar data de embarque quando integrado ao Logix
                        IIf(EEC->(FieldPos("EEC_NRODUE")) > 0 ,EEC->EEC_NRODUE,""),; //THTS - 06/12/2017 - Envia o numero DUE quando existir ou branco
                        IIf(EEC->(FieldPos("EEC_DTDUE")) > 0, dtos(EEC->EEC_DTDUE), dtos(EXL->EXL_DTDSE)) ,;
                        EE9->EE9_PEDIDO, EE9->EE9_SEQUEN })

                     EndIf
                  EndIf
               EndIf
               EE9->( dbSkip() )
            End

         // Filtro por Intervalo de datas da emissão da NF.
         Case lNF
            EEM->( dbSeek( xFilial( "EEM" ) ) )
            While EEM->( !Eof() .and. EEM_FILIAL == xFilial( "EEM" ) )
               If AVFLAGS("EEC_LOGIX")
                  If EEM->EEM_TIPONF <> EEM_SD .And. EEM->EEM_TIPONF <> EEM_CP //NCF - 20/02/2014 - Contempla envio da NF Complementar para registro no SINTEGRA 85 quando integrado ao LOGIX
                     EEM->(DbSkip())
                     Loop
                  EndIf
               Else
                  If EEM->EEM_TIPONF == EEM_CP // By JPP 23/06/2006 - 11:30 - Nota fiscal complementar
                     EEM->(DbSkip())
                     Loop
                  EndIf
               EndIf
               //Filtra os dados conforme datas informadas
               If ( !Empty( dGetNF1 ) .And. !Empty( dGetNF2 ) )
                  If ( EEM->EEM_DTNF >= dGetNF1 .And. EEM->EEM_DTNF <= dGetNF2 )
                     lFiltro := .T.
                  EndIf
               ElseIf ( !Empty( dGetNF1 ) .And. EEM->EEM_DTNF >= dGetNF1 )
                  lFiltro := .T.
               ElseIf ( !Empty( dGetNF2 ) .And. EEM->EEM_DTNF <= dGetNF2 )
                  lFiltro := .T.
                  //Posiciona a Tabela EEC no embarque encontrado.
                  If EEC->( dbSeek( xFilial( "EEC" ) + EEM->EEM_PREEMB ) )
                     //Verifica se o embarque possui uma Data de Averbação.
                     If EE9->( dbSeek( xFilial( "EE9" ) + EEC->EEC_PREEMB) ) .And. (!Empty(EE9->EE9_DTAVRB) .or. iif( EEC->(FieldPos("EEC_DUEAVR")) > 0 , !Empty(EEC->EEC_DUEAVR) , iif( EEC->(FieldPos("EEC_DTDUE")) > 0 , !Empty(EEC->EEC_DTDUE) , .F. ) ))
                        //Localiza o tipo de documento de carga, conforme via de transporte ref. ao embarque
                        SYQ->( dbSeek( xFilial( "SYQ" ) + EEC->EEC_VIA ) )
                        //Inclui o embarque no array aEEC caso isto já não tenha sido feito
                        If ASCAN( aEEC,{|x| x[2] = EEC->EEC_PREEMB } ) = 0

                           //ER - 04/09/2007 - Novo Layout (Alteração no país)
                           SYA->(DbSetOrder(1))
                           If SYA->(DbSeek(xFilial("SYA")+AvKey(EEC->EEC_PAISDT,"YA_CODGI")))
                              If  SYA->(FieldPos("YA_SISEXP")) > 0
                                 If !Empty(SYA->YA_SISEXP)
                                    cPaisDt := Substr(SYA->YA_SISEXP,1,3) //IncSpace(SYA->YA_SISEXP,4)  NCF - 10/03/2014 - O código com 4 dig. ocasiona rejeição do SPED
                                 EndIf
                              EndIf
                           EndIf

                           If Empty(cPaisDt)
                              cPaisDt := IncSpace(EEC->EEC_PAISDT,4)
                           EndIf

                           EXL->(DBSeek(xFilial() + EEC->EEC_PREEMB))
                           AADD( aEEC,{ EEC->( RecNo() ), EEC->EEC_PREEMB, Nil, Nil,;
                           EEC->EEC_NRCONH, If(AVFLAGS("EEC_LOGIX"),DTOS( EEC->EEC_DTEMBA ),DTOS( EEC->EEC_DTCONH )) , cPaisDt, EEC->EEC_TOTPED, SYQ->YQ_TDC,; //NCF - 16/05/2014 - Enviar data de embarque quando integrado ao Logix
                           If(EEC->(FieldPos("EEC_NRODUE")) > 0 ,EEC->EEC_NRODUE,""),; //THTS - 06/12/2017 - Envia o numero DUE quando existir ou branco
                           IIf(EEC->(FieldPos("EEC_DTDUE")) > 0, dtos(EEC->EEC_DTDUE), dtos(EXL->EXL_DTDSE)) ,;
                           EE9->EE9_PEDIDO, EE9->EE9_SEQUEN })

                        EndIf
                     EndIf
                  EndIf
               EndIf
               EEM->( dbSkip() )
            End

         // Filtro por Intervalo de datas de embarque.
         Case lEMB
            EEC->( dbSeek( xFilial( "EEC" ) ) )
            While EEC->( !Eof() .and. EEC_FILIAL == xFilial( "EEC" ) )
               //Filtra os dados conforme datas informadas
               If ( !Empty( dGetEMB1 ) .And. !Empty( dGetEMB2 ) )
                  If EEC->EEC_DTEMBA >= dGetEMB1 .And. EEC->EEC_DTEMBA <= dGetEMB2
                     lFiltro := .T.
                  EndIf
               ElseIf ( !Empty( dGetEMB1 ) .And. EEC->EEC_DTEMBA >= dGetEMB1 )
                  lFiltro := .T.
               ElseIf ( !Empty( dGetEMB2 ) .And. EEC->EEC_DTEMBA <= dGetEMB2 )
    		         lFiltro := .T.
    		      EndIf
    		      //Verifica se o embarque possui uma Data de Averbação.
               If lFiltro .And. EE9->( dbSeek( xFilial( "EE9" ) + EEC->EEC_PREEMB ) ) .And. (!Empty(EE9->EE9_DTAVRB) .or. iif( EEC->(FieldPos("EEC_DUEAVR")) > 0 , !Empty(EEC->EEC_DUEAVR) , iif( EEC->(FieldPos("EEC_DTDUE")) > 0 , !Empty(EEC->EEC_DTDUE) , .F. ) ))
                  //Verifica se existe uma Nota Fiscal relacionada ao embarque.
                  If EEM->( dbSeek( xFilial( "EEM" ) + EEC->EEC_PREEMB ) )
                     //Localiza o tipo de documento de carga, conforme via de transporte ref. ao embarque
                     SYQ->( dbSeek( xFilial( "SYQ" ) + EEC->EEC_VIA ) )
                     //Inclui o embarque no array aEEC caso isto já não tenha sido feito
                     If ASCAN( aEEC,{|x| x[2] = EEC->EEC_PREEMB } ) = 0

                        //ER - 04/09/2007 - Novo Layout (Alteração no país)
                        SYA->(DbSetOrder(1))
                        If SYA->(DbSeek(xFilial("SYA")+AvKey(EEC->EEC_PAISDT,"YA_CODGI")))
                           If  SYA->(FieldPos("YA_SISEXP")) > 0
                              If !Empty(SYA->YA_SISEXP)
                                 cPaisDt := Substr(SYA->YA_SISEXP,1,3) //IncSpace(SYA->YA_SISEXP,4)  NCF - 10/03/2014 - O código com 4 dig. ocasiona rejeição do SPED
                              EndIf
                           EndIf
                        EndIf

                        If Empty(cPaisDt)
                           cPaisDt := IncSpace(EEC->EEC_PAISDT,4)
                        EndIf

                        EXL->(DBSeek(xFilial() + EEC->EEC_PREEMB))
                        AADD( aEEC,{ EEC->( RecNo() ), EEC->EEC_PREEMB, Nil, Nil,;
                                    EEC->EEC_NRCONH, If(AVFLAGS("EEC_LOGIX"),DTOS( EEC->EEC_DTEMBA ),DTOS( EEC->EEC_DTCONH )) , cPaisDt, EEC->EEC_TOTPED, SYQ->YQ_TDC,; //NCF - 16/05/2014 - Enviar data de embarque quando integrado ao Logix
                                    IIf(EEC->(FieldPos("EEC_NRODUE")) > 0 ,EEC->EEC_NRODUE,""),; //THTS - 06/12/2017 - Envia o numero DUE quando existir ou branco
                                    IIf(EEC->(FieldPos("EEC_DTDUE")) > 0, dtos(EEC->EEC_DTDUE), dtos(EXL->EXL_DTDSE)) ,;
                                    EE9->EE9_PEDIDO, EE9->EE9_SEQUEN })

                     EndIf
                  EndIf
               EndIf
               EEC->( dbSkip() )
            End

         // Caso não selecionado o tipo de filtro.
         OtherWise
	        EEC->( dbSeek( xFilial( "EEC" ) ) )
            While EEC->( !Eof() .and. EEC_FILIAL == xFilial( "EEC" ) )
              If !Empty( EEC->EEC_DTEMBA )
    		      //Verifica se o embarque possui uma Data de Averbação.
                  If EE9->( dbSeek( xFilial( "EE9" ) + EEC->EEC_PREEMB ) )
                       //( EEC->(FieldPos("EEC_DUEAVR")) > 0 .and. !Empty(EEC->EEC_DUEAVR) ) .or. ( EEC->(FieldPos("EEC_DTDUE")) > 0 .and. !Empty(EEC->EEC_DTDUE) ) )
                     If (!Empty(EE9->EE9_DTAVRB) .or. iif( EEC->(FieldPos("EEC_DUEAVR")) > 0 , !Empty(EEC->EEC_DUEAVR) , iif( EEC->(FieldPos("EEC_DTDUE")) > 0 , !Empty(EEC->EEC_DTDUE) , .F. ) ))
                        //Verifica se existe uma Nota Fiscal relacionada ao embarque.
                        If EEM->( dbSeek( xFilial( "EEM" ) + EEC->EEC_PREEMB ) )
                           //Localiza o tipo de documento de carga, conforme via de transporte ref. ao embarque
                           SYQ->( dbSeek( xFilial( "SYQ" ) + EEC->EEC_VIA ) )
                           //Inclui o embarque no array aEEC caso isto já não tenha sido feito
                           If ASCAN( aEEC,{|x| x[2] = EEC->EEC_PREEMB } ) = 0

                              //ER - 04/09/2007 - Novo Layout (Alteração no país)
                              SYA->(DbSetOrder(1))
                              If SYA->(DbSeek(xFilial("SYA")+AvKey(EEC->EEC_PAISDT,"YA_CODGI")))
                                 If SYA->(FieldPos("YA_SISEXP")) > 0
                                    If !Empty(SYA->YA_SISEXP)
                                       cPaisDt := Substr(SYA->YA_SISEXP,1,3) //IncSpace(SYA->YA_SISEXP,4)  NCF - 10/03/2014 - O código com 4 dig. ocasiona rejeição do SPED
                                    EndIf
                                 EndIf
                              EndIf

                              If Empty(cPaisDt)
                                 cPaisDt := IncSpace(EEC->EEC_PAISDT,4)
                              EndIf

                              EXL->(DBSeek(xFilial() + EEC->EEC_PREEMB))
                              AADD( aEEC,{ EEC->( RecNo() ), EEC->EEC_PREEMB, Nil, Nil,;
                              EEC->EEC_NRCONH, If(AVFLAGS("EEC_LOGIX"),DTOS( EEC->EEC_DTEMBA ),DTOS( EEC->EEC_DTCONH )) , cPaisDt, EEC->EEC_TOTPED, SYQ->YQ_TDC,; //NCF - 16/05/2014 - Enviar data de embarque quando integrado ao Logix
                              IIf(EEC->(FieldPos("EEC_NRODUE")) > 0, EEC->EEC_NRODUE, ""),;  //THTS - 06/12/2017 - Envia o numero DUE quando existir ou branco
                              IIf(EEC->(FieldPos("EEC_DTDUE")) > 0, dtos(EEC->EEC_DTDUE), dtos(EXL->EXL_DTDSE)) ,;
                              EE9->EE9_PEDIDO, EE9->EE9_SEQUEN })

                          EndIf
                       EndIf
                    EndIf
                 EndIf
              EndIf
              EEC->( dbSkip() )
            End

      EndCase

      If Empty(aEEC)
         MsgInfo( STR0026, STR0024 )
         lRet := .F.
      EndIf

 #EndIf
End Sequence

Return ( lRet )

/*
Função     : GeraTxt()
Objetivo   :
Autor      : Rodrigo Mendes Diaz
Parametros : Nenhum.
Retorno    : Nenhum.
*/

Static Function GeraTxt()

Local nInc, nInc2, nInc3, nPos, nSomaNF
Local cStr01, cQry, ArqTxt
Local lNatExport:= .F.
Local lNroDUE  := .F.
Local aREL     := {}
Local dDtDue   := stod("")

Private cQry1, cQry2
Private aLogix := {}

Begin Sequence

   //FSM - 17/01/2012 - Tratamento para Integração com LOGIX
   If !lLogix
      If File( cGetFile ) .And. FERASE( cGetFile ) <> 0
         MsgAlert( STR0027 + ENTER + cGetFile, STR0025 )
         Break
      EndIf
      ArqTxt := EasyCreateFile( cGetFile )
   EndIf

      For nInc := 1 To Len( aEEC )

            aEE9 := {}
            aEEM := {}
            nSomaNF := 0
            lNroDUE := EEC->(FieldPos("EEC_NRODUE")) > 0 .And. !Empty(aEEC[nInc][10]) //THTS - 06/12/2017 - Determina o DocumentType
            #IFDEF TOP

                  If EE9->(FieldPos("EE9_DTDDE")) > 0
                        cQry1 := "Select EE9_PREEMB, EE9_RE, EE9_DTRE, EE9_DTAVRB, EE9_PRCTOT, EE9_NRSD, EE9_COD_I, EE9_SEQEMB, EE9_NF, EE9_SERIE, EE9_DTDDE, EE9_PEDIDO, EE9_SEQUEN "
                  Else
                        cQry1 := "Select EE9_PREEMB, EE9_RE, EE9_DTRE, EE9_DTAVRB, EE9_PRCTOT, EE9_NRSD, EE9_COD_I, EE9_SEQEMB, EE9_NF, EE9_SERIE, EE9_PEDIDO, EE9_SEQUEN "
                  EndIf
                  cQry1 += "From " + RetSqlName("EE9") + " EE9 "
                  cQry1 += "Where EE9.D_E_L_E_T_ <> '*' and EE9_FILIAL = '" + xFilial("EE9") + "' and "
                  cQry1 += "EE9_PREEMB = '" + aEEC[nInc][2] + "' "

                  If EEM->(FieldPos("EEM_MODNF")) > 0 // By JPP - 28/04/2006 - 14:00
                        cQry2 := "Select EEM_PREEMB, EEM_NRNF, EEM_VLNF, EEM_DTNF, EEM_MODNF, EEM_SERIE, EEM_TIPONF "
                  Else
                        cQry2 := "Select EEM_PREEMB, EEM_NRNF, EEM_VLNF, EEM_DTNF, EEM_SERIE, EEM_TIPONF "
                  EndIf
                  cQry2 += "From " + RetSqlName("EEM") + " EEM "
                  cQry2 += "Where EEM.D_E_L_E_T_ <> '*' and EEM_FILIAL = '" + xFilial("EEM") + "' and "
                  cQry2 += "EEM_PREEMB = '" + aEEC[nInc][2] + "' And "

                  If AVFLAGS("EEC_LOGIX")
                        cQry2 += "EEM_TIPONF IN ('1','2')" //NCF - 20/02/2014 - Contempla envio da NF Complementar para registro no SINTEGRA 85 quando integrado ao LOGIX
                  Else
                        cQry2 += "EEM_TIPONF <> '2'" // By JPP - 23/03/2006 - 14:25 - Nota fiscal complementar
                  EndIf

                  If EasyEntryPoint("EECREG85")// RMD - 14/11/05
                        ExecBlock("EECREG85",.F.,.F.,{"PE_QRYITENS",aEEC[nInc][2]})
                  EndIf

                  If Select("QEE9") > 0  // GFP - 31/01/2012
                        QEE9->(DbCloseArea())
                  EndIf

                  cQry1 := ChangeQuery(cQry1)
                  dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry1), "QEE9", .F., .T.)
                  EasyTCFields("QEE9")

                  If Select("QEEM") > 0  // GFP - 31/01/2012
                        QEEM->(DbCloseArea())
                  EndIf

                  cQry2 := ChangeQuery(cQry2)
                  dbUseArea(.T., "TOPCONN", TCGENQRY(,,cQry2), "QEEM", .F., .T.)
                  EasyTCFields("QEEM")

                  Do While QEE9->( !Eof() )
                     EEC->( dbSetOrder(1) , dbSeek( xFilial( "EEC" ) + QEE9->EE9_PREEMB ) )
                        If !Empty( QEE9->EE9_RE ) .Or. lNroDUE
                              If lNroDUE
                                    nPos := ASCAN( aEE9,{|x| x[2] = QEE9->EE9_NF } )
                                    If EEC->(FieldPos("EEC_DUEAVR")) > 0
                                       dDtDue :=  EEC->EEC_DUEAVR
                                    ElseIf EEC->(FieldPos("EEC_DTDUE")) > 0
                                       dDtDue :=  EEC->EEC_DTDUE
                                    Endif
                              Else
                                    nPos := ASCAN( aEE9,{|x| x[2] = QEE9->EE9_RE } )
                                    dDtDue := QEE9->EE9_DTAVRB
                              EndIf
                              If nPos = 0

                                 //Adiciona a R.E. ao array aEE9 se isto não tiver sido feito
                                 AADD( aEE9,{ QEE9->EE9_PREEMB															,; // 01
                                             IIF(lNroDUE, QEE9->EE9_NF, QEE9->EE9_RE)							      ,; // 02
                                             dtos(QEE9->EE9_DTRE)													,; // 03
                                             dtos(dDtDue)															,; // 04 QEE9->EE9_DTAVRB
                                             QEE9->EE9_PRCTOT															,; // 05
                                             IIf(lLogix .And. lNroDUE, aEEC[nInc][10], StrTran(QEE9->EE9_NRSD,"/",""))					,; // 06
                                             IIf(lLogix .And. lNroDUE, aEEC[nInc][11], IIf(EE9->(FieldPos("EE9_DTDDE")) > 0,dtos(QEE9->EE9_DTDDE),Nil))	,; // 07
                                             QEE9->EE9_COD_I															,; // 08
                                             xFilial("EYY") + avkey(QEE9->EE9_PREEMB,"EYY_PREEMB") + avkey(QEE9->EE9_SEQEMB,"EYY_SEQEMB") + avkey(QEE9->EE9_NF,"EYY_NFSAI") + avkey(QEE9->EE9_SERIE,"EYY_SERSAI") ,; // 09
                                             xFilial("EYY") + avkey(QEE9->EE9_PREEMB,"EYY_PREEMB") + avkey(QEE9->EE9_PEDIDO,"EYY_PEDIDO") + avkey(QEE9->EE9_SEQUEN,"EYY_SEQUEN") + avkey(QEE9->EE9_NF,"EYY_NFSAI") + avkey(QEE9->EE9_SERIE,"EYY_SERSAI") }) // 10 
                              Else // NCF - 12/04/2017 - Adicionado código do Item
                                    //Caso a R.E. já tenha sido adicionada, soma o seu valor à R.E. já existente
                                    aEE9[nPos][5] += QEE9->EE9_PRCTOT
                              EndIf
                        EndIf
                        QEE9->( dbSkip() )
                  End

                  Do While QEEM->( !Eof() )
                        If EEM->(FieldPos("EEM_MODNF")) > 0 // By JPP - 28/04/2006 - 14:00
                              AADD( aEEM,{QEEM->EEM_PREEMB, QEEM->EEM_NRNF, QEEM->EEM_VLNF, dtos(QEEM->EEM_DTNF), QEEM->EEM_MODNF,;
                              QEEM->EEM_SERIE, Nil, Nil,QEEM->EEM_TIPONF} )
                        Else
                              AADD( aEEM,{QEEM->EEM_PREEMB, QEEM->EEM_NRNF, QEEM->EEM_VLNF, dtos(QEEM->EEM_DTNF), Nil,;
                              QEEM->EEM_SERIE, Nil, Nil,QEEM->EEM_TIPONF} )
                        EndIf
                        nSomaNF += QEEM->EEM_VLNF
                        QEEM->( dbSkip() )
                  End

                  ASort( aEEM,,, {|x,y| x[2] < y[2]} )

                  aRel := CalcRel( aEE9, aEEM, nSomaNF, aEEC[nInc][8] ,lNroDUE)

                  /*If Len( aREL ) == 0
                        MsgInfo( "Não foi encontrada nenhuma R.E. que satisfaça as condições de filtro.", "Alerta" )
                        Break
                  EndIf*/

                  /*
                  Nopado por ER - Essas linhas foram passadas para o fim da função.

                  QEE9->(DbCloseArea())
                  QEEM->(DbCloseArea())
                  */
            #Else
                  EEC->( dbSetOrder( 1 ) )
                  EEM->( dbSetOrder( 1 ) )
                  EE9->( dbSetOrder( 2 ) )//EE9_FILIAL+EE9_PREEMB+EE9_PEDIDO+EE9_SEQUEN

                  //Posiciona a tabela EEC no embarque correspondente ao RECNO
                  EEC->(dbGoTo( aEEC[nInc][1] ))
                  EEM->( dbSeek( xFilial( "EEM" ) + EEC->EEC_PREEMB ) )

                  EE9->( dbSeek( xFilial( "EE9" ) + EEC->EEC_PREEMB ) )
                  While EE9->( !Eof() .and. EE9_FILIAL == xFilial( "EE9" ) )
                        //Verifica se o pedido esta relacionado ao embarque e possui uma R.E.
                        If EE9->EE9_PREEMB == EEC->EEC_PREEMB .And. (!Empty( EE9->EE9_RE )  .Or. lNroDUE)
                        
                              If lNroDUE
                                    nPos := ASCAN( aEE9,{|x| x[2] = EE9->EE9_NF } )
                                    If EEC->(FieldPos("EEC_DUEAVR")) > 0
                                       dDtDue :=  EEC->EEC_DUEAVR
                                    ElseIf EEC->(FieldPos("EEC_DTDUE")) > 0
                                       dDtDue :=  EEC->EEC_DTDUE
                                    Endif
                              Else
                                    nPos := ASCAN( aEE9,{|x| x[2] = EE9->EE9_RE } )
                                    dDtDue := EE9->EE9_DTAVRB
                              EndIf

                              nPos := ASCAN( aEE9,{|x| x[2] = EE9->EE9_RE } )
                              If nPos = 0
                                    //Adiciona a R.E. ao array aEE9 se isto não tiver sido feito
                                    AADD( aEE9,{EE9->EE9_PREEMB,;
                                    IIF(lNroDUE, EE9->EE9_NF, EE9->EE9_RE),;
                                    DTOS( EE9->EE9_DTRE ),;
                                    dtos(dDtDue) ,; // 04
                                    EE9->EE9_PRCTOT,;
                                    If(lLogix .And. EEC->(FieldPos("EEC_NRODUE")) > 0 .And. !Empty(EEC->EEC_NRODUE),EEC->EEC_NRODUE,StrTran(EE9->EE9_NRSD,"/","")),; //THTS - 06/12/2017
                                    IIf(lLogix .And. lNroDUE, aEEC[nInc][11], IIf(EE9->(FieldPos("EE9_DTDDE")) > 0,DtoS(EE9->EE9_DTDDE),Nil)) ,;
                                    xFilial("EYY") + avkey(EE9->EE9_PREEMB,"EYY_PREEMB") + avkey(EE9->EE9_SEQEMB,"EYY_SEQEMB") + avkey(EE9->EE9_NF,"EYY_NFSAI") + avkey(EE9->EE9_SERIE,"EYY_SERSAI") ,; // 09
                                    xFilial("EYY") + avkey(EE9->EE9_PREEMB,"EYY_PREEMB") + avkey(EE9->EE9_PEDIDO,"EYY_PEDIDO") + avkey(EE9->EE9_SEQUEN,"EYY_SEQUEN") + avkey(EE9->EE9_NF,"EYY_NFSAI") + avkey(EE9->EE9_SERIE,"EYY_SERSAI") }) // 10 

                              Else  // NCF - 12/04/2017 - Adicionado código do Item
                                    //Caso a R.E. já tenha sido adicionada, soma o seu valor à R.E. já existente
                                    aEE9[nPos][5] += EE9->EE9_PRCTOT
                              EndIf
                        EndIf
                        EE9->( dbSkip() )
                  End

                  While EEM->( !Eof() .and. EEM_FILIAL == xFilial( "EEM" ) )
                        //Adiciona ao array aEEM todas as notas referentes ao embarque
                        If EEM->EEM_PREEMB == EEC->EEC_PREEMB .And. If( AVFLAGS("EEC_LOGIX"), EEM->EEM_TIPONF == EEM_SD .Or. EEM->EEM_TIPONF == EEM_CP , EEM->EEM_TIPONF <> EEM_CP )  // By JPP - 23/03/2006 - 14:25 -EEM_CP = Nota fiscal complementar
                              If EEM->(FieldPos("EEM_MODNF")) > 0 // By JPP - 28/04/2006 - 14:00                                                                                         //    NCF - 20/02/2014 - Contempla envio da NF Complementar para registro no SINTEGRA 85 quando integrado ao LOGIX
                                    AADD( aEEM,{EEM->EEM_PREEMB, EEM->EEM_NRNF, EEM->EEM_VLNF, DTOS( EEM->EEM_DTNF ), EEM->EEM_MODNF,;
                                    EEM->EEM_SERIE, Nil, Nil} )
                              Else
                                    AADD( aEEM,{EEM->EEM_PREEMB, EEM->EEM_NRNF, EEM->EEM_VLNF, DTOS( EEM->EEM_DTNF ), Nil,;
                                    EEM->EEM_SERIE, Nil, Nil} )
                              Endif
                        nSomaNF += EEM->EEM_VLNF
                        EndIf
                        EEM->( dbSkip() )
                  End

                  ASort( aEEM,,, {|x,y| x[2] < y[2]} ) // By JPP - 23/03/2006 - 16:15 - Correção da instrução ASort

                  aRel := CalcRel( aEE9, aEEM, nSomaNF, aEEC[nInc][8] ,lNroDUE)

                  If Len( aREL ) == 0
                        MsgInfo( STR0028, STR0025 )
                        Break
                  EndIf

            #ENDIF

            //Grava o arquivo texto conforme dados obtidos
            //EYY->(DbSetOrder(1))  //EYY_FILIAL, EYY_PREEMB, EYY_SEQEMB, EYY_NFSAI, EYY_SERSAI, EYY_D1ITEM
            //EYY->(DbSetOrder(3))  //EYY_FILIAL+EYY_PREEMB+EYY_PEDIDO+EYY_SEQUEN+EYY_NFSAI+EYY_SERSAI
            For nInc2 := 1 to Len( aREL )
                  nEE9 := 0
                  nEEM := 0

                  nEEM := ASCAN( aEEM,{|x| Alltrim(x[2]) = Alltrim(aREL[nInc2][2]) })
                  If lNroDUE
                        nEE9 := ASCAN( aEE9,{|x| IIF(aEEM[nEEM][9] == "1", Alltrim(x[2]) = Alltrim(aREL[nInc2][2]) ,Alltrim(x[1]) = Alltrim(aREL[nInc2][1]) ) } ) //Se nota normal, procura no aEE9 pelo numero da nota/re, se nota complementar, busca aEE9 pelo embarque
                  Else
                        nEE9 := ASCAN( aEE9,{|x| Alltrim(x[2]) = Alltrim(aREL[nInc2][1]) } )
                  EndIf

                  lNatExport:= EYY->( DbSetOrder(1) , MSSEEK(aEE9[nEE9][09]) ) //.or. EYY->( DbSetOrder(3) , MSSEEK(aEE9[nEE9][10]) )
                        
                  //FSM - 17/01/2012 - Tratamento para Integração com LOGIX
                  If !lLogix

                        cSTR01 := "85" +;                                                                         // Tipo  //  By JPP - 28/04/2006 - 14:00 - Novo LayOut
                              IncSpace( aEE9[nEE9][6], 11, .F. ) +;                                               // Declaração de Exportação
                              If(EE9->(FieldPos("EE9_DTDDE")) > 0,aEE9[nEE9][7],aEE9[nEE9][3]) +;                 // Data da declaração
                              IIf(lNatExport, "1", "0") +;                                                        // Natureza da Exportação
                              IncSpace( aEE9[nEE9][2], 12, .F. ) +;                                               // Registro de Exportação
                              aEE9[nEE9][3] +;                                                                    // Data registro de Exportação
                              IncSpace( aEEC[nInc][5], 16, .F. ) +;                                               // conhecimento de embarque
                              aEEC[nInc][6] +;                                                                    // Data Conhecimento
                              IncSpace( aEEC[nInc][9], 02, .F. ) +;                                               // Tipo Conhecimento
                              IncSpace( aEEC[nInc][7], 04, .F. ) +;                                               // País de destino
                              Replicate( "0", 08 ) +;                                                             // Reservado
                              aEE9[nEE9][4] +;                                                                    // Data averbação
                              IncSpace( aEEM[nEEM][2], 06, .F. ) +;                                               // Nota Fiscal
                              aEEM[nEEM][4] +;                                                                    // Data Emissão
                              If(!Empty(aEEM[nEEM][5]),IncSpace( aEEM[nEEM][5], 02, .F. ),"01") +;                // Modelo NF - Se o campo EEM_MODNF estiver vazio ou não existir, o modelo da nota fiscal passará a ser "01" por default.
                              IncSpace( Transform(aEEM[nEEM][6], AvSx3("EEM_SERIE", AV_PICTURE)), 03, .F. ) +;    // IncSpace( aEEM[nEEM][6], 03, .F. ) +;       // Serie //RMD - 25/02/15 - Projeto Chave NF
                              Space(19) + ENTER                                                                   // Brancos

                        FWrite(ArqTxt,cStr01)

                  Else

                        aLogix := {{"85","Tipo"},;
                                          {Left(aEE9[nEE9][6], 14), "Declaracao de Exportacao",},;                                                    // Declaração de Exportação / Nro DUE quando existir
                                          {If(EE9->(FieldPos("EE9_DTDDE")) > 0 .Or. lNroDUE,stod(aEE9[nEE9][7]),stod(aEE9[nEE9][3])), "Data da declaracao"},;
                                                {IIf(lNatExport, "1", "0"), "Natureza da Exportacao"},;                                               //exportação 0-direta; 1-indireta
                                                {IIf(lNroDUE, Nil, aEE9[nEE9][2]), "Registro de Exportacao"},;
                                                {IIf(lNroDUE, Nil, stod(aEE9[nEE9][3])), "Data registro de Exportacao"},;
                                                {aEEC[nInc][5], "conhecimento de embarque"},;
                                                {stod(aEEC[nInc][6]), "Data Conhecimento"},;
                                                {aEEC[nInc][9], "Tipo Conhecimento"},;
                                                {aEEC[nInc][7], "Pais de destino"},;
                                                {stod(aEE9[nEE9][4]), "Data averbacao"},;
                                                {aEEM[nEEM][2], "Nota Fiscal"},;
                                                {stod(aEEM[nEEM][4]), "Data Emissao"},;
                                                {aEE9[nEE9][8], "Codigo do Item"},;
                                                {If(!Empty(aEEM[nEEM][5]),aEEM[nEEM][5],"01"), "Modelo NF" },;                                        // - Se o campo EEM_MODNF estiver vazio ou não existir, o modelo da nota fiscal passará a ser "01" por default.
                                                {Transform(aEEM[nEEM][6], AvSx3("EEM_SERIE", AV_PICTURE)), "Serie"},;                                 // {aEEM[nEEM][6], "Serie"} } //RMD - 24/02/15 - Projeto Chave NF
                                                {If(lNroDUE,"2","0"),"Tipo de Documento"} }                                                           //THTS - 06/12/2017 - 0=Declaração de Exportação / 1=Declaração Simplificada / 2=Declaração Única (DUE)

                        //Tratamento para o Logix
                        If nOpRad == 2  //Estorno/Exclusao -> Delete
                              EasyEnvEAI('EECREG85',5)
                        Else //Inclusao/Alteracao -> Upsert
                              EasyEnvEAI('EECREG85',3)
                        EndIf

                  EndIf
            Next

            //ER - 24/01/2007
            If Select("QEE9") > 0
                  QEE9->(DbCloseArea())
            EndIf

            If Select("QEEM") > 0
                  QEEM->(DbCloseArea())
            EndIf
      Next

   //FSM - 17/01/2012 - Tratamento para Integração com LOGIX
   FClose( Arqtxt )
   If !lLogix
	   MsgInfo( STR0029, STR0023 )
   EndIf

End Sequence

Return Nil


/*
Função     : CalcRel()
Objetivo   : Calcula a porcentagem do valor de cada R.E. em relação às notas fiscais.
Autor      : Rodrigo Mendes Diaz
Parametros : aEEM -> Array com as notas fiscais vinculadas ao embarque.
             aEE9 -> Array com as R.E.s vincuculadas ao embarque.
Retorno    : aRel -> Array com a relação Nota Fiscal/R.E.
*/

Static Function CalcRel( aEE9, aEEM, nSomaNF, nTotPed, lNroDUE )

Local nRe, nNF, nTotNf := 0
Local aREL := {}, nInc2, nInc3

If !lNroDUE
   //Calcula a porcentagem de cada nota fiscal em relação à soma das notas fiscais
   For nInc2 := 1 To Len( aEEM )
      aEEM[nInc2][7] := ( aEEM[nInc2][3] * 100 ) / nSomaNF
      aEEM[nInc2][8] := nTotPed * ( aEEM[nInc2][7] / 100 )
      nTotNf += aEEM[nInc2][8]
   Next
   aEEM[nInc2 - 1][8] += ( nTotPed - nTotNf )

   //Relaciona cada R.E. com uma nota fiscal
   For nInc2 := 1 To Len( aEE9 )
      For nInc3 := 1 To Len( aEEM )
         nRE  := aEE9[nInc2][5]
         nNF := aEEM[nInc3][8]
         If nRe <> 0
            If nRe <= nNF
               aEEM[nInc3][8] -= nRe
               aEE9[nInc2][5] := 0
               AADD( aREL,{ aEE9[nInc2][2],aEEM[nInc3][2] } ) //Relação R.E./Nota
            ElseIf nRE > nNF .And. nNf > 0
               aEE9[nInc2][5] -= nNF
               aEEM[nInc3][8] := 0
               AADD( aREL,{ aEE9[nInc2][2],aEEM[nInc3][2] } ) //Relação R.E./Nota
            EndIf
         EndIf
      Next
   Next

Else
      For nInc2 := 1 To Len(aEEM)
            aAdd(aRel,{aEEM[nInc2][1],aEEM[nInc2][2]})
      Next
EndIf

Return aREL

/* ====================================================*
* Função:		MenuDef
* Parametros:	-
* Objetivo:	Menu da Rotina
* Obs: 		Integração Logix
* Autor:		Guilherme Fernandes Pilan - GFP
* Data:		27/01/2012 - 16:52
* =====================================================*/
*----------------------------*
Static Function MenuDef()
*----------------------------*

Local aRotina :=  {{ "Pesquisar", "AxPesqui" , 0 , 1},; //"Pesquisar"
                     { "Visualizar","REG85MAN" , 0 , 2},; //"Visualizar"
                     { "Incluir",   "REG85MAN" , 0 , 3},; //"Incluir"
                     { "Alterar",   "REG85MAN" , 0 , 4},; //"Alterar"
                     { "Excluir",   "REG85MAN" , 0 , 5} } //"Excluir"

Return aRotina

*----------------------------*
Static Function REG85MAN()
*----------------------------*
Return Nil

/* ====================================================*
* Função: IntegDef
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix
* Obs:
* Autor: Felipe Sales Martinez
* Data:
* =====================================================*/
Static Function IntegDef(cXML, nTypeTrans, cTypeMessage)
Local oEasyIntEAI
/*
  Variavel privada da funcao GeraTxt():
  aLogix
*/

	oEasyIntEAI := EasyIntEAI():New(cXML, nTypeTrans, cTypeMessage)

	oEasyIntEAI:oMessage:SetVersion("1.0")
	oEasyIntEAI:oMessage:SetMainAlias("EEC")
	oEasyIntEAI:SetModule("EEC",29)


	// *** Envio
	oEasyIntEAI:SetAdapter("SEND"   , "MESSAGE",  "REG85ASENB") //ENVIO DE BUSINESS MESSAGE           (<-Business)
	// ***

	oEasyIntEAI:Execute()

Return oEasyIntEAI:GetResult()


/* ====================================================*
* Função: REG85ASENB
* Parametros: cXML, nTypeTrans, cTypeMessage
* Objetivo: Efetua integração com Logix
* Obs:
* Autor: Felipe Sales Martinez
* Data:
* =====================================================*/
Function REG85ASENB(oEasyMessage)
Local oXml      := EXml():New()
Local oBusiness := ENode():New()
Local oEvent    := ENode():New()
Local oIdent    := ENode():New()
Local oRec      := ENode():New()
Local oAddInf := ENode():New()
Local oInf    := ENode():New()
Local oKeyNode
Local aOrd := SaveOrd({"EEC"})
Local cInfo := ""


   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","CompanyId"))
   oKeyNode:SetField(ETag():New("" ,SM0->M0_CODIGO))
   oIdent:SetField(ETag():New("key",oKeyNode))

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","BranchId"))
   oKeyNode:SetField(ETag():New("" ,AvGetM0Fil()))
   oIdent:SetField(ETag():New("key",oKeyNode))

   oKeyNode   := ENode():New()
   oKeyNode:SetField(EAtt():New("name","ExportDeclaration"))
   oKeyNode:SetField(ETag():New("" , GetArrInfo("Declaracao de Exportacao")))
   oIdent:SetField(ETag():New("key",oKeyNode))

   /* Tratamento para data */
   cInfo := GetArrInfo("Data da declaracao")
   If !Empty(cInfo)

      //cInfo := EasyTimeStamp(cInfo, .F.)
      cInfo := EasyTimeStamp(cInfo, .T.,.T.)

      oKeyNode   := ENode():New()
      oKeyNode:SetField(EAtt():New("name","ExportDeclarationDate"))
      oKeyNode:SetField(ETag():New("" , cInfo ))
      oIdent:SetField(ETag():New("key",oKeyNode))

   EndIf

   oEvent:SetField("Entity", "EECREG85")

   If Type("nOpRad") <> "U" .And. nOpRad == 2 //Exclusao
      oEvent:SetField("Event" , "delete")
   Else //Inclusao/Alteracao
      oEvent:SetField("Event" , "upsert")
   EndIf
   oEvent:SetField("Identification",oIdent)

   oBusiness:SetField("CompanyId" , SM0->M0_CODIGO)
   oBusiness:SetField("BranchId"  , AvGetM0Fil())

   AddInXml(oBusiness, "ExportDeclaration"       , "Declaracao de Exportacao")
   AddInXml(oBusiness, "ExportDeclarationDate"  , "Data da declaracao", "D")
   AddInXml(oBusiness, "ExportRegistration"      , "Registro de Exportacao")
   AddInXml(oBusiness, "ExportRegistrationDate" , "Data registro de Exportacao", "D")
   AddInXml(oBusiness, "ShippingKnowledge"       , "conhecimento de embarque")
   AddInXml(oBusiness, "ShippingKnowledgeDate"  ,  "Data Conhecimento", "D")
   AddInXml(oBusiness, "ExportNature"            , "Natureza da Exportacao")
   AddInXml(oBusiness, "DocumentType"            , "Tipo de Documento") //THTS - 06/12/2017 - 0=Declaração de Exportação / 1=Declaração Simplificada / 2=Declaração Única (DUE)
   cInfo := GetArrInfo("Tipo Conhecimento")
   If !Empty(cInfo)
      AddInXml(oBusiness, "KnowledgeTransportType", "Tipo Conhecimento")
   EndIf

   AddInXml(oBusiness, "CountryCode"              , "Pais de destino") //THTS - 05/12/2017 - Alterada a Tag Country para CountryCode
   AddInXml(oBusiness, "AnnotationDate"      , "Data averbacao", "D")
   AddInXml(oBusiness, "ExportInvoice"       , "Nota Fiscal")
   AddInXml(oBusiness, "ExportInvoiceModel" , "Modelo NF")
   AddInXml(oBusiness, "ExportInvoiceSerie" , "Serie")

   AddInXml(oInf, "IssueDate" , "Data Emissao")
   AddInXml(oInf, "ItemCode"  , "Codigo do Item")
   oAddInf:SetField("Information", oInf)
   oBusiness:SetField("AdditionalInformation",oAddInf)


   oRec:SetField("BusinessEvent"  ,oEvent)
   oRec:SetField("BusinessContent",oBusiness)
   oXml:AddRec(oRec)

   RestOrd(aOrd,.T.)

Return oXml



/* ====================================================*
* Função: GetArrInfo
* Parametros: cTag
* Objetivo: Retorna a informação do Array
* Obs:
* Autor: Felipe Sales Martinez
* Data: 18/01/2012
* =====================================================*/
Static Function GetArrInfo(cTag)
Local xInfo

cTag := UPPER(AllTrim(cTag))

If (nPos := aScan( aLogix, {|X| Upper(AllTrim(X[2])) == cTag })) > 0
    xInfo := aLogix[nPos][1]

    If ValType(xInfo) == "C"
       xInfo := AllTrim(xInfo)
    EndIf
EndIf

Return xInfo



/* ====================================================*
* Função: AddInXml
* Parametros: oXml, cNode , cInfo, cType
* Objetivo:
* Obs:
* Autor: Felipe Sales Martinez
* Data: 19/01/2012
* =====================================================*/
Static Function AddInXml(oXml, cNode , cInfo, cType)
Local xInfo :=  GetArrInfo(cInfo)
Default cType := ValType(xInfo)

If !Empty(xInfo) .Or. !(Upper(cType) == "D")

   If Upper(cType) == "D"
      //xInfo := EasyTimeStamp(xInfo, .F.)
      xInfo := EasyTimeStamp(xInfo, .T.,.T.)
   EndIf

   oXml:SetField(cNode, xInfo )

EndIf

Return oXml
