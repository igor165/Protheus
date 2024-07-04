/*
Programa  : EECIN315.PRW
Objetivo  : Geração dos arquivos texto conforme Instrução Normativa SRF 315.
Autor     : Alexsander Martins dos Santos
Data/Hora : 16/06/2003 às 17:23.
*/

#Include "EEC.cH"
#Include "EECIN315.CH"

#Define aspas  Chr(34)
#Define txteof Chr(26)

Function EECIN315
      
Private lRet      := .T.,;
        cGetMAT   := Space( 07 ),;                   // Váriavel Mês/Ano do Trimestre.
        cGetTpEv  := Space( 14 ),;                   // Váriavel com a seleção do Tipo de Envio.
        aGetTpEv  := { STR0006, STR0007, STR0008 },; // Array com todas as opções de seleção do Tipo de Envio.
        aFiltro   := { "1", "2", "1,2" },;           // Valores de filtro para a opcão selecionada acima.
        dGetRE1   := Ctod( "  /  /  " ),;            // Váriavel Data Inicial da RE.
        dGetRE2   := Ctod( "  /  /  " ),;            // Váriavel Data Final da RE.
        dGetNF1   := Ctod( "  /  /  " ),;            // Váriavel Data Inicial da Nota Fiscal.
        dGetNF2   := Ctod( "  /  /  " ),;            // Váriavel Data Final da Nota Fiscal.
        dGetEB1   := Ctod( "  /  /  " ),;            // Váriavel Data Inicial do Embarque.
        dGetEB2   := Ctod( "  /  /  " ),;            // Váriavel Data Final do Embarque.
        cGetPath  := IncSpace( EasyGParam( "MV_AVG0048",, "C:\" ), 100, .F. )

Private cWorkFile, cFileTXT1, cFileTXT2

Private lCBRE       := .T.,;
        lCBNF       := .F.,;
        lCBEB       := .F.,;
        lIN315Error := .F.,;
        mIN315Log   := ""

Private aOrdem  := SaveOrd( { "EEC", "EEM", "EE9", "SA2", "SYA" } )

Private aValidEEM := { { "WorkNF->EEM_NRNF", "Numero da NF vazio." },;
				       { "WorkNF->EEM_DTNF", "Data da emissao da NF vazia." },;
				       { "WorkNF->EEM_VLNF", "Valor da NF vazio." } }
                                                
Private aValidEE9 := { { "WorkEEC->EEC_IMPODE", "Destinatario nao informado." },;
                       { "WorkEEC->EEC_SISEXP", "Codigo do Pais (SISCOMEX) nao informado no embarque." },;
                       { "WorkEEC->EEC_DTEMBA", "Data do Embarque nao preenchida." },;
                       { "WorkEEC->EEC_COD_GI", "Codigo da Moeda (SISCOMEX) nao informado." } }

Begin Sequence

   If !TelaGets()
      lRet := .F.
      Break
   EndIf

   MSAguarde( { || IN315GeraWork(), "Selecionando Processos" } ) // Selecionando Processos.

End Sequence

/*
Função     : TelaGets
Objetivo   : Apresentar caixa de dialogo, solicitando o preenchimento de informações ao usuário.
Autor      : Alexsander Martins dobs Santos
Parametros :
*/

Static Function TelaGets()
                                                 
Local bOk        := { || nOpc := 1, lRet := .T., If( ValidTelaGet( "ALL" ), oDlg:End(), oDlg:Refresh() ) },;
      bCancel    := { || nOpc := 0, lRet := .F., oDlg:End() }

Local aObjFiltro := { { "oGetRE1", "oSayAte1", "oGetRE2" },; // Objetos da Data de RE.
                      { "oGetNF1", "oSayAte2", "oGetNF2" },; // Objetos da Data da Nota Fiscal.
                      { "oGetEB1", "oSayAte3", "oGetEB2" } } // Objetos da Data de Embarque.

Local cTrimestre
// GFP - 18/11/2015 - Ajuste de tamanho e posicionamento - V12.1.7
Define MsDialog oDlg Title STR0001 From 0, 0 To 458, 355 Of oMainWnd Pixel

  // Informações Complementáres.
   @ 30, 04 To 65, 175 Label STR0002 Of oDlg Pixel
                                                                               
      @ 043, 010 Say   oSayMAT Var STR0004 Of oDlg Pixel                       
      @ 042, 070 MsGet oGetMAT Var cGetMAT Size 35, 08 Picture "99/9999" Valid ValidTelaGet( "MAT" ) Of oDlg Pixel

   // Informações do Filtro.
   @ 68, 04 To 195, 175 Label STR0003 Of oDlg Pixel
   
      @ 081, 010 Say oSayTpEV Var STR0005 Pixel Of oDlg
      @ 080, 060 ComboBox oGetTpEV Var cGetTpEV Size 55, 08 Pixel Of oDlg Items aGetTpEV

      // Intervalo de datas do RE
      @ 096, 009 To 129, 170 Label "" Of oDlg Pixel
      @ 098, 015 CheckBox oCBRE Var lCBRE Prompt STR0009 Size 70,08 On Click ( lCBNF:=.F., oCBNF:Refresh() , lCBEB:=.F., oCBEB:Refresh() ,ObjetoActive( aObjFiltro, 1 ) ) Of oDlg Pixel 
      
         @ 111, 015 MsGet oGetRE1 Var dGetRE1 Valid !Empty( dGetRE1 ) .and. ValidTelaGet( "RE" ) Size 45, 08 Of oDlg Pixel
         @ 112, 068 Say oSayAte1  Var STR0010 Pixel Of oDlg
         @ 111, 085 MsGet oGetRE2 Var dGetRE2 Valid !Empty( dGetRE2 ) .and. ValidTelaGet( "RE" ) Size 45, 08 Of oDlg Pixel
      
	  // Intervalo de datas da emissão da NF
      @ 131, 009 To 159, 170 Label "" Of oDlg Pixel
      @ 133, 015 CheckBox oCBNF Var lCBNF Prompt STR0011 Size 98,08 On Click ( lCBRE:=.F., oCBRE:Refresh() , lCBEB:=.F., oCBEB:Refresh() ,ObjetoActive( aObjFiltro, 2 ) ) Of oDlg Pixel

         @ 143, 015 MsGet oGetNF1 Var dGetNF1 Valid !Empty( dGetNF1 ) .and. ValidTelaGet( "NF" ) Size 45, 08 Of oDlg Pixel
         @ 144, 068 Say oSayAte2  Var STR0010 Pixel Of oDlg
         @ 143, 085 MsGet oGetNF2 Var dGetNF2 Valid !Empty( dGetNF2 ) .and. ValidTelaGet( "NF" ) Size 45, 08 Of oDlg Pixel

      // Intervalo de datas de Embarque
      @ 161, 009 To 191, 170 Label "" Of oDlg Pixel
      @ 163, 015 CheckBox oCBEB Var lCBEB Prompt STR0012 Size 88,08 On Click ( lCBRE:=.F., oCBRE:Refresh() , lCBNF:=.F., oCBNF:Refresh() ,ObjetoActive( aObjFiltro, 3 ) ) Of oDlg Pixel
      
         @ 175, 015 MsGet oGetEB1 Var dGetEB1 Valid !Empty( dGetEB1 ) .and. ValidTelaGet( "EB" ) Size 45, 08 Of oDlg Pixel
         @ 176, 068 Say oSayAte3  Var STR0010 Pixel Of oDlg
         @ 175, 085 MsGet oGetEB2 Var dGetEB2 Valid !Empty( dGetEB2 ) .and. ValidTelaGet( "EB" )  Size 45, 08 Of oDlg Pixel
                               
   // Destino dos arquivos
   @ 198, 04 To 225, 175 Label "Destino dos Arquivos" Of oDlg Pixel
   
      @ 210, 010 MsGet oGetPath Var cGetPath Valid ValidTelaGet( "PATH" ) Size 120, 08 Of oDlg Pixel
   
   ObjetoActive( aObjFiltro, 1 )

Activate MSDialog oDlg On Init EnchoiceBar( oDlg, bOk, bCancel ) Centered

cTrimestre := AllTrim( Str( Int( ( Val( Left( cGetMAT, 2 ) ) * 4 ) / 12 ) + If( ( Val( Left( cGetMAT, 2 ) ) * 4 ) % 12 = 0, 0, 1 ) ) )
cFileTXT1  := "DCP" + Right( cGetMAT, 2 ) + cTrimestre + "A1.TXT"
cFileTXT2  := "DCP" + Right( cGetMAT, 2 ) + cTrimestre + "A2.TXT"

If File( AllTrim( cGetPath ) + "\" + cFileTXT1 ) .and. File( AllTrim( cGetPath ) + "\" + cFileTXT2 ) .and. lRet = .T.
   lRet := MsgYesNo( "Os arquivos a serem gerados já existe ! Deseja Substituilos ?", "Atenção !" )
EndIf

SetMV( "MV_AVG0048", cGetPath )

Return( lRet )

/*
Função     : IN315GeraWork
Objetivo   : Gerar Work com os Embarques conforme o filtro selecionado.
Autor      : Alexsander Martins dos Santos
Parametros :
*/

Static Function IN315GeraWork

Local aWorkEEC := { { "EEC_PREEMB", "C", AVSX3( "EEC_PREEMB", AV_TAMANHO ), 00 },;
                    { "EEC_FORN",   "C", AVSX3( "EEC_FORN",   AV_TAMANHO ), 00 },;
                    { "EEC_IMPODE", "C", AVSX3( "EEC_IMPODE", AV_TAMANHO ), 00 },;
                    { "EEC_FOLOJA", "C", AVSX3( "EEC_FOLOJA", AV_TAMANHO ), 00 },;
                    { "EEC_IN86",   "C", AVSX3( "EEC_IN86",   AV_TAMANHO ), 00 },;
                    { "EEC_SISEXP", "C", AVSX3( "YA_SISEXP",  AV_TAMANHO ), 00 },;
                    { "EEC_DTEMBA", "D", AVSX3( "EEC_DTEMBA", AV_TAMANHO ), 00 },;
                    { "EEC_COD_GI", "C", AVSX3( "YF_COD_GI",  AV_TAMANHO ), 00 } }
                    
Private aCampos := {}

cWorkFile := E_CriaTrab( , aWorkEEC, "WorkEEC" )

IndRegua( "WorkEEC", cWorkFile+TEOrdBagExt(), "EEC_PREEMB" )

EEC->( dbSetOrder( 1 ) )
EEM->( dbSetOrder( 1 ) )
EE9->( dbSetOrder( 2 ) )
SA2->( dbSetOrder( 1 ) )
SYA->( dbSetOrder( 1 ) )
SYF->( dbSetOrder( 1 ) )

Begin Sequence

   Do Case
      // Filtro por Intervalo de datas do RE.
      Case lCBRE = .T.
        
         EE9->( dbSeek( xFilial( "EE9" ) ) )
        
         While EE9->( !Eof() .and. EE9_FILIAL == xFilial( "EE9" ) )

            If EE9->EE9_DTRE >= dGetRE1 .and. EE9->EE9_DTRE <= dGetRE2
			   If EEC->( dbSeek( xFilial( "EEC" ) + EE9->EE9_PREEMB ) )
                  GravaWorkEEC()
               EndIf
            EndIf

            EE9->( dbSkip() )

         End
         
      // Filtro por Intervalo de datas da emissão da NF.
      Case lCBNF = .T.
   
         EEM->( dbSeek( xFilial( "EEM" ) ) )
      
         While EEM->( !Eof() .and. EEM_FILIAL == xFilial( "EEM" ) )

            If EEM->EEM_DTNF >= dGetNF1 .and. EEM->EEM_DTNF <= dGetNF2
			   If EEC->( dbSeek( xFilial( "EEC" ) + EEM->EEM_PREEMB ) )
                  GravaWorkEEC()
               EndIf   
            EndIf

            EEM->( dbSkip() )

         End

      // Filtro por Intervalo de datas de embarque.
      Case lCBEB = .T.
         
         EEC->(dbSetOrder(12)) // EEC_FILIAL+DTOS(EEC_DTEMBA)
         
         EEC->( dbSeek( xFilial( "EEC" ) + DTOS( dGetEB1 ) , .t. ))  // By JPP - 17/11/04 10:20 - Correção do DBSeek()
      
         While EEC->( !Eof() .and. EEC_FILIAL == xFilial( "EEC" ) ) .And. EEC->EEC_DTEMBA <= dGetEB2

            If ( SiglaIN( EEC->EEC_IN86, "IN315", .F. ) $ aFiltro[ Val( Left( cGetTpEV, 1 ) ) ] )
               GravaWorkEEC()
            EndIf

            EEC->( dbSkip() )
         End
      
      // Caso não selecionado o tipo de filtro.
      OtherWise
	
         MsgInfo( "Deve ser selecionado uma das opções de Filtro !", "Atenção" )
	     Break

   EndCase

   If WorkEEC->(EasyRecCount() ) = 0
      MsgInfo( "Não foram encontrados processos com o filtro informado !" )
      Break
   Else
      IN315GeraTXT()
   EndIf
   
End Sequence

WorkEEC->( E_EraseArq( cWorkFile ) )

/*
Função     : IN315GeraTXT  //IN315Sel
Objetivo   : Selecionar os processos conforme os dados informado no filtro e gerar um Work.
Autor      : Alexsander Martins dos Santos
Parametros :
*/

Static Function IN315GeraTXT()

Local aCampos   := {}, nCampos:=0
                                         
Local aWorkNF   := { { "EEM_NRNF",  "C", AVSX3( "EEM_NRNF",   AV_TAMANHO ), 0 },; // Número da Nota Fiscal.
                     { "EEM_SERIE", "C", AVSX3( "EEM_SERIE",  AV_TAMANHO ), 0 },; // Número de Série.
                     { "EEM_DTNF",  "D", AVSX3( "EEM_DTNF",   AV_TAMANHO ), 0 },; // Data da Nota Fiscal.
                     { "EEM_VLNF",  "N", AVSX3( "EEM_VLNF",   AV_TAMANHO ), 4 } } // Valor da Nota Fiscal.

Local aWorkEE9  := { { "EE9_RE",    "C", AVSX3( "EE9_RE",     AV_TAMANHO ), 0 },; // RE do Item.
                     { "EE9_PRCTOT","N", AVSX3( "EE9_PRCTOT", AV_TAMANHO ), 7 },; // Preço total do item em U$.
                     { "EE9_PRCEQU","N", AVSX3( "EEM_VLNF",   AV_TAMANHO ), 7 },; // Preço equivalente ao percentual(ee9_percent) e o valor total da Nota.
                     { "EE9_NRSD",  "C", AVSX3( "EE9_NRSD",   AV_TAMANHO ), 0 } } // Número do Despacho.
                   
Local aWorkTXT1 := { { "TXT_CGC",   "C", AVSX3( "A2_CGC",     AV_TAMANHO ), 0 },; // CNPJ do Fabricante.
                     { "TXT_MAT",   "C", 07, 0 },;                                // Mês/Ano do Trimestre.
                     { "TXT_NRNF",  "C", AVSX3( "EEM_NRNF",   AV_TAMANHO ), 0 },; // Número da Nota Fiscal.
                     { "TXT_SERIE", "C", SerieNfId("EEM",6,"EEM_SERIE")   , 0 },; // { "TXT_SERIE", "C", AVSX3( "EEM_SERIE",  AV_TAMANHO ), 0 },; // Número de Série. //RMD - 24/02/15 - Projeto Chave NF
                     { "TXT_DTNF",  "D", AVSX3( "EEM_DTNF",   AV_TAMANHO ), 0 },; // Data da Nota Fiscal.
                     { "TXT_PRCEQU","N", AVSX3( "EEM_VLNF",   AV_TAMANHO ), 7 },; // Preço equivalente ao percentual(ee9_percent) e o valor total da Nota.
                     { "TXT_RE",    "C", AVSX3( "EE9_RE",     AV_TAMANHO ), 0 } } // RE.

Local aWorkTXT2 := { { "TXT_CGC",   "C", AVSX3( "A2_CGC",     AV_TAMANHO ), 0 },; // CNPJ do Fabricante.
			   	     { "TXT_RE",    "C", AVSX3( "EE9_RE",     AV_TAMANHO ), 0 },; // RE.
				     { "TXT_MAT",   "C", 07, 0 },;                                // Mês/Ano do Trimestre.
				     { "TXT_IMPODE","C", AVSX3( "EEC_IMPODE", AV_TAMANHO ), 0 },; // Importador.
				     { "TXT_SISEXP","C", AVSX3( "YA_SISEXP",  AV_TAMANHO ), 0 },; // Código no Siscomex do País Destino.
				     { "TXT_NRSD",  "C", AVSX3( "EE9_NRSD",   AV_TAMANHO ), 0 },; // Número do Despacho.
				     { "TXT_DTEMBA","D", AVSX3( "EEC_DTEMBA", AV_TAMANHO ), 0 },; // Data do Embarque.
				     { "TXT_PRCTOT","N", AVSX3( "EE9_PRCTOT", AV_TAMANHO ), 7 },; // Preço total do item em U$.
				     { "TXT_COD_GI","C", AVSX3( "YF_COD_GI",  AV_TAMANHO ), 0 } } // Código no Siscomex da Moeda.

Local nTotalNF := 0,;                              // Valor total das Notas relacionado ao Embarque.
      nPrcTot  := 0,;   				           // Preço total dos itens relacionado ao Embarque.
      cTrimestre, nHandle1, nHandle2, nHandle3     // Váriaveis para geração dos arquivos texto.

Local nPN      

cWkFile1 := E_CriaTrab( , aWorkNF,   "WorkNF"   )  // Work de Nota Fiscal.
cWkFile2 := E_CriaTrab( , aWorkEE9,  "WorkEE9"  )  // Work dos Itens.
cWkFile3 := E_CriaTrab( , aWorkTXT1, "WorkTXT1" )  // Work com os dados do arquivos TXT de NF.
cWkFile4 := E_CriaTrab( , aWorkTXT2, "WorkTXT2" )  // Work com os dados do arquivos TXT de NF.

IndRegua( "WorkEE9", cWkFile2+TEOrdBagExt(), "EE9_RE" )

WorkEEC->( dbGoTop() )

While WorkEEC->( !Eof() )
    
   nTotalNF := 0
   nPrcTot  := 0
   nPrcTotR := 0
   
   lIN315Error := .F.

   SA2->( dbSeek( xFilial( "SA2" ) + WorkEEC->EEC_FORN + WorkEEC->EEC_FOLOJA ) )
   
   If Empty(SA2->A2_CGC)
      IN315GeraLog( WorkEEC->EEC_PREEMB, "CGC no cadastro do exportador está vazio." )
      lIN315Error := .T.
   EndIf
   
   EEM->( dbSeek( xFilial( "EEM" ) + WorkEEC->EEC_PREEMB ) )
      
   While EEM->( !Eof() .and. EEM_FILIAL == xFilial( "EEM" ) ) .and. EEM->EEM_PREEMB == WorkEEC->EEC_PREEMB
         
      If EEM->EEM_TIPOCA = "N" .AND. EEM->EEM_TIPONF = "1"
      
         WorkNF->( dbAppend() )
         WorkNF->EEM_NRNF  := EEM->EEM_NRNF
         WorkNF->EEM_SERIE := EEM->EEM_SERIE
         WorkNF->EEM_DTNF  := EEM->EEM_DTNF
         WorkNF->EEM_VLNF  := EEM->EEM_VLNF

         nTotalNF := nTotalNF + EEM->EEM_VLNF     

         //Validação de campos.
         For nCampos := 1 To Len(aValidEEM)
            If Empty(&(aValidEEM[nCampos][1]))
               IN315GeraLog( WorkEEC->EEC_PREEMB, aValidEEM[nCampos][2] )
               lIN315Error := .T.
            EndIf
         Next
         //Fim da validação.
      
      EndIf         

      EEM->( dbSkip() )
         
   End
      
   If WorkNF->(EasyRecCount()) = 0
      IN315GeraLog( WorkEEC->EEC_PREEMB, "arquivo de NF's sem registros p/ este processo" )
      lIN315Error := .T.
   EndIf
   

   EE9->( dbSeek( xFilial( "EE9" ) + WorkEEC->EEC_PREEMB ) )
      
   While EE9->( !Eof() .and. EE9_FILIAL == xFilial( "EE9" ) ) .and. EE9->EE9_PREEMB == WorkEEC->EEC_PREEMB      
      
      // Agrupamento dos Itens por RE.
      If WorkEE9->( dbSeek( EE9->EE9_RE ) )

         WorkEE9->EE9_PRCTOT := WorkEE9->EE9_PRCTOT + EE9->EE9_PRCTOT

      Else

         WorkEE9->( dbAppend() )
         WorkEE9->EE9_RE     := EE9->EE9_RE
         WorkEE9->EE9_PRCTOT := EE9->EE9_PRCTOT
         WorkEE9->EE9_NRSD   := EE9->EE9_NRSD

      EndIf

      nPrcTot := nPrcTot + EE9->EE9_PRCTOT  

      //Validação de campos.
      For nCampos := 1 To Len(aValidEE9)
         If Empty(&(aValidEE9[nCampos][1]))
            IN315GeraLog( WorkEEC->EEC_PREEMB, aValidEE9[nCampos][2] )
            lIN315Error := .T.
         EndIf 
      Next
      
      If Len(AllTrim(WorkEE9->EE9_RE)) < 12
         IN315GeraLog( WorkEEC->EEC_PREEMB, "No. do RE no "+AllTrim(EE9->EE9_SEQUEN)+"º item, nao preenchido ou possui menos que 12 caracters." )
         lIN315Error := .T.
      EndIf
      
      If Len(AllTrim(WorkEE9->EE9_NRSD)) < 11
         IN315GeraLog( WorkEEC->EEC_PREEMB, "No. da DDE no "+AllTrim(EE9->EE9_SEQUEN)+"º item, nao preenchido ou possui menos que 11 caracters." )
         lIN315Error := .T.
      EndIf      
      //Fim da validação de campos.

      EE9->( dbSkip() )

   End

   // Rateio.   
   WorkEE9->( dbGoTop() )

   While !WorkEE9->( Eof() )

      nPN                 := Round( ( WorkEE9->EE9_PRCTOT / nPrcTot ) * 100, 2 )  // Gravando o percentual do preço total do item em relação ao preço total de todos os itens.
      WorkEE9->EE9_PRCEQU := Round( ( nTotalNF * nPN ) / 100, 2 )                 // Gravando o preço do itens em R$.

      nPrcTotR := nPrcTotR + WorkEE9->EE9_PRCEQU

      WorkEE9->( dbSkip() )

   End

   // Verificação se o Preço Total dos RE's é diferente ao Preço Total da NF. Existindo diferença, o resto é acrescentado na ultima RE.
   If nTotalNF <> nPrcTotR
      WorkEE9->( dbGoBottom() )
      If !WorkEE9->( Eof() ) //SVG 27/01/09
         WorkEE9->EE9_PRCEQU := WorkEE9->EE9_PRCEQU + ( nTotalNF - nPrcTotR )
      EndIf
   EndIf

   // Distribuindo valores para as Notas. (Somente se não ocorreu erro.)
   If !lIN315Error
      
      WorkNF->( dbGoTop() )
      WorkEE9->( dbGoTop() )
   
      While !WorkEE9->( Eof() )
   
         //SA2->( dbSeek( xFilial( "SA2" ) + WorkEEC->EEC_FORN + WorkEEC->EEC_FOLOJA ) )

         // Gravação dos dados na WorkTXT1 referente ao arquivo DCPaatA1.TXT.
         WorkTXT1->( dbAppend() )
         WorkTXT1->TXT_CGC    := SA2->A2_CGC
         WorkTXT1->TXT_MAT    := cGetMAT
         WorkTXT1->TXT_NRNF   := WorkNF->EEM_NRNF
         WorkTXT1->TXT_SERIE  := Transform(WorkNF->EEM_SERIE, AvSx3("EEM_SERIE", AV_PICTURE)) //WorkTXT1->TXT_SERIE  := WorkNF->EEM_SERIE //RMD - 24/02/15 - Projeto Chave NF
         WorkTXT1->TXT_DTNF   := WorkNF->EEM_DTNF
         WorkTXT1->TXT_RE     := WorkEE9->EE9_RE

         // Verifica se o valor da Nota Fiscal é suficiente para abater o valor total dos itens da re.
         If WorkNF->EEM_VLNF - WorkEE9->EE9_PRCEQU >= 0

            WorkTXT1->TXT_PRCEQU := WorkEE9->EE9_PRCEQU
            WorkNF->EEM_VLNF     := WorkNF->EEM_VLNF - WorkEE9->EE9_PRCEQU
 
            // Gravação dos dados na WorkTXT2 referente ao arquivo DCPaatA2.TXT.
            WorkTXT2->( dbAppend() )
            WorkTXT2->TXT_CGC    := SA2->A2_CGC
            WorkTXT2->TXT_RE     := WorkEE9->EE9_RE
            WorkTXT2->TXT_MAT    := cGetMAT
            WorkTXT2->TXT_IMPODE := StrTran( WorkEEC->EEC_IMPODE, ";", " " )
            WorkTXT2->TXT_SISEXP := WorkEEC->EEC_SISEXP
            WorkTXT2->TXT_NRSD   := WorkEE9->EE9_NRSD
            WorkTXT2->TXT_DTEMBA := WorkEEC->EEC_DTEMBA
            WorkTXT2->TXT_PRCTOT := WorkEE9->EE9_PRCTOT
            WorkTXT2->TXT_COD_GI := WorkEEC->EEC_COD_GI
 
            WorkEE9->( dbSkip() )
 
         Else
      
            WorkTXT1->TXT_PRCEQU := WorkNF->EEM_VLNF
            WorkEE9->EE9_PRCEQU  := WorkEE9->EE9_PRCEQU - WorkNF->EEM_VLNF
            WorkNF->EEM_VLNF     := 0

            WorkNF->( dbSkip() )
            
            If WorkNF->(EOF())
               WorkEE9->( dbSkip() )
            EndIf

         EndIf

      End

   EndIf

   WorkNF->( avzap() )
   WorkEE9->( avzap() )   

   WorkEEC->( dbSkip() )

End

// Geração do arquivo DCPaatA1.TXT.
nHandle1 := EasyCreateFile( AllTrim( cGetPath ) + "\" + cFileTXT1, 0 )

WorkTXT1->( dbGoTop() )

While !WorkTXT1->( Eof() )
 
   WorkTXT1->( fWrite( nHandle1, AllTrim( TXT_CGC )  			 		              + ";" + ;
       	    				     AllTrim( Right( cGetMAT, 4 ) + Left( cGetMAT, 2 ) )  + ";" + ;
			 			         AllTrim( TXT_NRNF )  							      + ";" + ;
						         AllTrim( TXT_SERIE )							      + ";" + ;
							     AllTrim( StrZero(Day(TXT_DTNF),2)+"/"+StrZero(Month(TXT_DTNF),2)+"/"+StrZero(Year(TXT_DTNF),4) ) + ";" + ;
							     AllTrim( Trans( TXT_PRCEQU, "@E 999999999999.99" ) ) + ";" + ;
							     AllTrim( TXT_RE ) + ENTER ) )

   WorkTXT1->( dbSkip() )

End							             

fWrite( nHandle1, txteof )

// Geração do arquivo DCPaatA2.TXT.
nHandle2 := EasyCreateFile( AllTrim( cGetPath ) + "\" + cFileTXT2, 0 )

WorkTXT2->( dbGoTop() )

While !WorkTXT2->( Eof() )

   WorkTXT2->( fWrite( nHandle2, AllTrim( TXT_CGC )                                   + ";" + ;
   						         AllTrim( TXT_RE )  	      						  + ";" + ;
   						         AllTrim( Right( cGetMAT, 4 ) + Left( cGetMAT, 2 ) )  + ";" + ;
   						         AllTrim( TXT_IMPODE )		  					      + ";" + ;
   						         AllTrim( TXT_SISEXP )		  					      + ";" + ;
   						         AllTrim( TXT_NRSD )  		   					      + ";" + ;
   						         AllTrim( StrZero(Day(TXT_DTEMBA),2)+"/"+StrZero(Month(TXT_DTEMBA),2)+"/"+StrZero(Year(TXT_DTEMBA),4) ) + ";" + ;
							 	 AllTrim( Trans( TXT_PRCTOT, "@E 999999999999.99" ) ) + ";" + ;
   						         AllTrim( TXT_COD_GI ) + ENTER ) )

   WorkTXT2->( dbSkip() )

End

fWrite( nHandle2, txteof )

fClose( nHandle1 )
fClose( nHandle2 )

If !Empty(mIN315Log)

   nHandle3 := EasyCreateFile( AllTrim( cGetPath ) + "\" + "IN315LOG.TXT", 0 )

   fWrite( nHandle3, mIN315Log + txteof )
   fClose( nHandle3 )

   MsgInfo( "Alguns erros foram encontrados, favor verificar IN315LOG.TXT", "Atenção !" )

   WinExec( "NotePad " +AllTrim( cGetPath ) + "\" + "IN315LOG.TXT" )

Else
   MsgInfo( "Arquivos gerados com sucesso !", "Atenção !" )
EndIf

RestOrd( aOrdem )

WorkNF->( E_EraseArq( cWkFile1 ) )
WorkEE9->( E_EraseArq( cWkFile2 ) )
WorkTXT1->( E_EraseArq( cWkFile3 ) )
WorkTXT2->( E_EraseArq( cWkFile4 ) )


/*
Função     : ObjetoActive
Objetivo   : Abilitar ou Desabilitar objetos.
Autor      : Alexsander Martins dos Santos
Parametros : aObjetos -> Parametro array, com o(s) objeto(s) para serem abilitados ou desabilitados,
                         conforme o parametro lActive.
*/

Static Function ObjetoActive( aObjetos, nElemento )
Local c:=0, n:=0

For c:= 1 To 3
   For n := 1 To 3
      &( aObjetos[c][n] + ":Disable()" )
   Next n
Next c

For c := 1 To 3
   &( aObjetos[nElemento][c] + ":Enable()" )
Next c

Return Nil
  
/*
Função     : SiglaIN
Objetivo   : {Sigla da Instrução Normativa}. Retornar o tipo de envio.
Autor      : Alexsander Martins dos Santos
Parametros : cSigla     -> A, B, C, D, 1, 2 e " ".
             cIN        -> IN86, IN315.
             lAction    -> .T. = Leitura e Gravação.
                           .F. = Somente Leitura.
             cTipoEnvio -> "1" = Não Enviado.
                           "2" = Já Enviado.
             Estes parametros serão utilizados, tambem, na geracao dos dados daS instrucões
             normativas IN419/IN432.
Retorno    : Retorna a Sigla, conforme o tipo de envio e Instrução Normativa.
*/

Function SiglaIN( cSigla, cIN, lAction, cTipoEnvio )

Local aCols := {  "Sigla", "IN86", "IN315" }
Local aRows := { { "A",       "2",     "2" },;
                 { "B",       "1",     "1" },;
                 { "C",       "2",     "1" },;
                 { "D",       "1",     "2" },;
                 { "1",       "1",     "1" },;
                 { "2",       "2",     "1" },;
                 { " ",       "1",     "1" } }

Local nCol    := aScan( aCols, cIN ),;
      nRow    := aScan( aRows, { |x| x[1] = cSigla } ),;
      cReturn := If( nRow = 0, "", aRows[nRow][nCol] )

If lAction

   Do Case
      Case cIN = "IN86"
         nRow := aScan( aRows, { |x| x[2] = cTipoEnvio .and. x[3] = aRows[nRow][3] } )
      Case cIN = "IN315"
         nRow := aScan( aRows, { |x| x[2] = aRows[nRow][2] .and. x[3] = cTipoEnvio } )
   EndCase

   EEC->( RecLock( "EEC", .F. ) )
   EEC->EEC_IN86 := If( nRow = 0, "", aRows[nRow][1] )
   EEC->( MsUnlock() )

EndIf

Return( cReturn )

  
/*
Função     : GravaWorkEEC
Objetivo   : Gravar informações do EEC na Work.
Autor      : Alexsander Martins dos Santos
*/

Static Function GravaWorkEEC()

If SiglaIN( EEC->EEC_IN86, "IN315", .F. ) $ aFiltro[ Val( Left( cGetTpEV, 1 ) ) ]

   If !WorkEEC->( dbSeek( EEC->EEC_PREEMB ) )
      
      WorkEEC->( dbAppend() )
      WorkEEC->EEC_PREEMB := EEC->EEC_PREEMB
      WorkEEC->EEC_FORN   := EEC->EEC_FORN
      WorkEEC->EEC_IMPODE := EEC->EEC_IMPODE
      WorkEEC->EEC_FOLOJA := EEC->EEC_FOLOJA
      WorkEEC->EEC_IN86   := EEC->EEC_IN86
      WorkEEC->EEC_DTEMBA := EEC->EEC_DTEMBA

      // Gravando Tipo de Envio como Enviado.
      If SiglaIN( EEC->EEC_IN86, "IN315", .F. ) = "1"
         SiglaIN( EEC->EEC_IN86, "IN315", .T., "2" )
      EndIf

      SYA->( dbSeek( xFilial( "SYA" ) + EEC->EEC_PAISDT ) )
      WorkEEC->EEC_SISEXP := Left(SYA->YA_SISEXP, 3)
               
      SYF->( dbSeek( xFilial( "SYF" ) + EEC->EEC_MOEDA ) )
      WorkEEC->EEC_COD_GI := SYF->YF_COD_GI
      
   EndIf
   
Else

      //Gravando Tipo de Envio como Não Enviado.
      If Empty( EEC->EEC_IN86 ) .or. EEC->EEC_IN86 = "2"
         SiglaIN( EEC->EEC_IN86, "IN315", .T., "1" )
      EndIf

EndIf

Return Nil


/*
Função     : ValidTelaGet
Objetivo   : Validar as opções de entrada de dados da Dialog.
Autor      : Alexsander Martins dos Santos
Parametros : cValid -> Grupo ou Campo a ser validado.
*/

Static Function ValidTelaGet( cValid )

Local lRet2 := .T.

Begin Sequence

If cValid = "MAT" .or. cValid = "ALL" // Mês/Ano do Trimestre.
   If Empty( cGetMAT )
      MsgInfo( "O Mês/Ano do Trimestre não pode estar vazio !", "Atenção" )
      lRet2 := .F.
      Break
   EndIf
   If !( Val( Left( cGetMAT, 2 ) ) > 0 .and.  Val( Left( cGetMAT, 2 ) ) < 13 )
      MsgInfo( "O Mês informado não é valido !", "Atenção" )
      lRet2 := .F.
      Break
   EndIf
   If !( Val( Right( cGetMAT, 4 ) ) > 1900 )
      MsgInfo( "O Ano Informado não é valido !", "Atenção" )
      lRet2 := .F.
      Break
   EndIf 
EndIf

If lCBRE = .T. .and. ( cValid = "RE" .or. cValid = "ALL" )    // Intervalo de datas do RE.
   IF !Empty( dGetRE1 ) .and. !Empty( dGetRE2 ) .and. dGetRE1 > dGetRE2
      MsgInfo( "A Data final do RE não pode ser menor que a data inicial !", "Atenção"  )
      lRet2 := .F.
      Break
   EndIf
EndIf   

If lCBNF = .T. .and. ( cValid = "NF" .or. cValid = "ALL" )    // Intervalo de datas da emissão da NF.
   IF !Empty( dGetNF1 ) .and. !Empty( dGetNF2 ) .and. dGetNF1 > dGetNF2
      MsgInfo( "A Data final da NF não pode ser menor que a data inicial !", "Atenção"  )
      lRet2 := .F.
      Break
   EndIf  
EndIf

If lCBEB = .T. .and. ( cValid = "EB" .or. cValid = "ALL" )    // Intervalo de datas de Embarque.
   IF !Empty( dGetEB1 ) .and. !Empty( dGetEB2 ) .and. dGetEB1 > dGetEB2
      MsgInfo( "A Data final do Embarque não pode ser menor que a data inicial !", "Atenção"  )
      lRet2 := .F.
      Break
   EndIf      
EndIf

If cValid = "PATH" .or. cValid = "ALL"  // Caminho destino para gravação dos arquivos texto.
   If Empty( cGetPath )
      MsgInfo( "O Caminho de destino para geração dos arquivos não pode estar vazio !", "Atenção"  )
      lRet2 := .F.
      Break         
   EndIf
   If !lIsDir( cGetPath )
      MsgInfo( "O Camindo de destino para geração dos arquivos não foi encontrado !", "Atenção"  )
      lRet2 := .F.
      Break
   EndIf
EndIf

End Sequence

Return( lRet2 )

/*
Funcao IN315GeraLog
*/            

Static Function IN315GeraLog( cProcesso, cMensagem )
                                                 
mIN315Log := mIN315Log + "Processo: " +AllTrim(cProcesso)+ ", esta com o " + cMensagem + ENTER

Return Nil
