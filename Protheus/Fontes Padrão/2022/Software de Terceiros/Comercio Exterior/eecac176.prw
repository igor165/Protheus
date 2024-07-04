#INCLUDE "AVERAGE.CH"
#INCLUDE "EECAC176.CH"
 
/*============================================================* 
Funcao    : EasyTarArm()
Parametro : 
Retorno   : .T.
Objetivo  : Executar manutenção de tarifas de conteiners do 
            armador
By        : Felipe S. Martinez
Data      : 18/02/2011 15:39
Obs       : -
*=============================================================*/
Function EasyTarArm()
Local cAlias := "EWU"

Private oTarifa
Private aRotina := MenuDef()

mBrowse(6,1,22,75, cAlias)

Return .T.


Function Manutencao(cAlias,nReg,nOpc)
Local lRet := .T.
Local cEsconde := Space(0)
Local oDlg
Local bOk     := { || If(!Empty(AllTrim(M->Y5_COD)),(lRet := .T.,oDlg:End()),(lRet := .F.,MsgInfo("Preencher o código."))) },;
      bCancel := { || If(MsgYesNo(STR0010,STR0009), (lRet := .F. ,oDlg:End(), oTarifa:SetnBotao(0)),Nil) } //#"Deseja realmente sair?" ##"Atenção"

Private oTarifa := EasyTarArm():New(/*TITULO*/ ,/*ALIASCAPA*/ ,/*ALIASDET*/ , nOpc ,nReg )

DbSelectArea("SY5")

M->Y5_COD := CriaVar("Y5_COD")


If nOpc == INCLUIR


   DEFINE MSDIALOG oDlg TITLE "Armador" FROM 12,05 TO 20,55 OF oMainWnd


   @002, 002 SAY AVSX3("Y5_COD",5) SIZE 50,8
   @002, 007 MSGET M->Y5_COD F3 "EIA" VALID ExistCpo("SY5",M->Y5_COD) SIZE 80,8
   @003, 002 SAY AVSX3("Y5_NOME",5) SIZE 50,8
   @003, 007 MSGET Posicione('SY5',1,xFilial('SY5') + M->Y5_COD ,'Y5_NOME') WHEN .F. SIZE 80,8

   @050, 007 MSGET cEsconde SIZE 80,8 //apenas para tirar o foco do campo e fazer o gatilho

   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,bOk,bCancel)
   
Else

  M->Y5_COD := EWU->EWU_ARMADO

EndIf   

If lRet

   oTarifa:CriaWork() //Criação das Works

   oTarifa:CarregaWork( nOpc ,EWU->EWU_CODTAB ) //Carregando Works

   oTarifa:Manut( nOpc ) //Manutenção de telas
   
   If oTarifa:nBotao == 1 .And. nOpc <> VISUALIZAR
      oTarifa:GravaTarifas( nOpc ) //Gravação de registros
   EndIf

   oTarifa:ExcluiWork() //apaga works
   
EndIf

Return lRet

/*
Funcao     : MenuDef()
Parametros : cFuncao
Retorno    : aRotina
Objetivos  : Menu Funcional
Autor      : Felipe S. Martinez
Data/Hora  : 10/03/2011 15:39
*/
Static Function MenuDef()
Local aRotina := {}

Aadd(aRotina, { STR0001 ,   "AxPesqui"   , 0 , 1})      //"Pesquisar"
Aadd(aRotina, { STR0002 ,   "Manutencao" , 0 , 2})      //"Visualizar"
Aadd(aRotina, { STR0003 ,   "Manutencao" , 0 , 3})      //"Incluir"
Aadd(aRotina, { STR0004 ,   "Manutencao" , 0 , 4})      //"Alterar"
Aadd(aRotina, { STR0005 ,   "Manutencao" , 0 , 5,3})    //"Excluir"

Return aRotina


/*============================================================* 
Classe    : EasyTarArm
Parametro : -
Retorno   : -
Objetivo  : Efetuar manutenção de tarifas de conteiners do 
            Armador
By        : Felipe S. Martinez
Data      : 18/02/2011 15:39
Revisão   :
Obs       : -
*=============================================================*/
****=======****
Class EasyTarArm
****=======****

    //Atributos
    Data aDelEWU
    Data cTitulo
    Data cCapAlias
    Data cDetAlias
    Data cWorkEWU
    Data cWorkEWU2
    Data cWorkEWV
    Data cWorkEWV2
    Data nOpc
    Data nReg
    Data nBotao
    Data nOpcAdd
    Data lCopia

    //Métodos
    Method New( cTitulo ,cCapAlias ,cDetAlias ,nOpc ,nReg ) CONSTRUCTOR
    
    Method AtualizaArray( cCod, cDesc, nPosic, nTipo )
    Method AtuGetDados( lCapa )
    Method AlteraColuna(cCod ,cDesc ,nPosic )

    Method CriaWork()
    Method CarregaWork( nOpc ,cCodTab )
    Method CarregaDados()
  
    Method ExcluiWork()
    Method VerifContainUtil(cTabTarifa,aTipoCon,aPeriodo,nOperacao,lCapa,lPeriodo,nTarifa)
    Method ExcluiColuna( cCod ,cDesc ,nPosic )

    Method GravaWork()
    Method GravaTabela( nOpc )
    Method GravaTarifas( nOpc )

    Method IncluiColuna( cCod ,cDesc ,nPosic )

    Method Manut( nOpc )
    Method MontaEstru()
    Method MontaTela()
    Method MontaArray()

    Method ValidOK()
    Method ValidBotao()

    //Setters:
    Method SetnBotao( nBotao )
    Method SetnOpc( nOpc )
    Method SetnReg( nReg )


End Class


*=====================================================================*
Method New(cTitulo, cCapAlias, cDetAlias, nOpc, nReg) Class EasyTarArm
*=====================================================================*

Default cTitulo   := STR0039 //#"Tarifas do Armardor"
Default cCapAlias := "EWU"
Default cDetAlias := "EWV"

Self:cTitulo   := AllTrim(cTitulo)
Self:cCapAlias := AllTrim(cCapAlias)
Self:cDetAlias := AllTrim(cDetAlias)
Self:SetnOpc(nOpc)
Self:SetnReg(nReg)
Self:SetnBotao(0)
Self:nOpcAdd := 0
Self:aDelEWU := {}

Return Self

*===========================*
Method Manut(nOpc) Class EasyTarArm
*===========================*
Local lRet := .T.
             
Private aAlterDet  := {},;
        aHeaderDet := {},;
        aColsDet   := {}

Private aAlterCap  := {},;
        aHeaderCap := {},;
        aColsCap   := {}

Private oGetD,;
        oGetC 
        
Private lInclui := .F. , lAltera := .F.
        
        
Self:SetnOpc(nOpc)

//Variveis utilizada no When no Dicionario dos Campos do EWV
If Self:nOpc == INCLUIR .Or. Self:lCopia
   lInclui := .T. 
ElseIf Self:nOpc == ALTERAR
   lAltera := .T.
EndIf

Begin Sequence
   
   /*
   Verifica se o armador está preenchido, e no caso de alteração/exclusão
   verifica se possui registro na capa de tarifas do armador.
   */
   If !Self:ValidBotao()
      Break
   EndIf
   
   //Carrega a memória da capa de tarifas do armador 
   If Self:MontaEstru()
      
      //Tela principal de Tarifas
      Self:MontaTela()

      If Self:nBotao == 1 //botão OK == 1
         If Self:lCopia
            Self:SetnOpc( 3 )
         EndIf 
         Self:GravaWork()
      EndIf

   EndIf


End Sequence

WorkEWU->(DBSetOrder(1)) // EWU_ARMADO+EWU_CODTAB
Self:lCopia := .F.

If Self:nOpc == EXCLUIR
   WorkEWU->(DBGoTop())
EndIf

Return lRet

*===============================*
Method CriaWork() Class EasyTarArm
*===============================*
Local lRet := .T.

Begin Sequence

   If Select("WorkEWU") == 0

      //Work da Capa:
      aCampos := Array(EWU->(FCount()))
      aSemSX3:= {}
      
      aAdd(aSemSX3,{"EWU_ARMADO","C",AvSX3("EWU_ARMADO",AV_TAMANHO),AvSX3("EWU_ARMADO",AV_DECIMAL)})
      aAdd(aSemSX3,{"EWU_DESPOR","C",AvSX3("EWU_DESPOR",AV_TAMANHO),AvSX3("EWU_DESPOR",AV_DECIMAL)})
            
      Self:cWorkEWU  := E_CriaTrab(Self:cCapAlias,aSemSX3,"WorkEWU")
      Self:cWorkEWU2 := CriaTrab(,.F.) 
      
      IndRegua("WorkEWU", Self:cWorkEWU+TEOrdBagExt() ,"EWU_ARMADO+EWU_CODTAB",,, STR0006) //#"Processando arquivo temporário..."
      IndRegua("WorkEWU", Self:cWorkEWU2+TEOrdBagExt(),"EWU_ARMADO+EWU_Y9COD" ,,, STR0006) //#"Processando arquivo temporário..."

      Set Index To (Self:cWorkEWU + TEOrdBagExt()),(Self:cWorkEWU2 + TEOrdBagExt()) 
   
   Else
      WorkEWU->( avzap() )
   EndIf

   If Select("WorkEWV") == 0

      //Work do Detalhe:
      aCampos := Array(EWV->(FCount()))
      aSemSX3:= {}  

      aAdd(aSemSX3,{"EWV_ARMADO","C",AvSX3("EWV_ARMADO",AV_TAMANHO),AvSX3("EWV_ARMADO",AV_DECIMAL)})
      aAdd(aSemSX3,{"EWV_CODTAB","C",AvSX3("EWV_CODTAB",AV_TAMANHO),AvSX3("EWV_CODTAB",AV_DECIMAL)})
      aAdd(aSemSX3,{"EWV_CODCON","C",AvSX3("EWV_CODCON",AV_TAMANHO),AvSX3("EWV_CODCON",AV_DECIMAL)})
      
      Self:cWorkEWV  := E_CriaTrab(Self:cDetAlias,aSemSX3,"WorkEWV")
	  Self:cWorkEWV2 := CriaTrab(,.F.)   
   
      IndRegua("WorkEWV", Self:cWorkEWV+ TEOrdBagExt(),"EWV_ARMADO+EWV_CODTAB+EWV_CODCON+EWV_PERINI",,, STR0006) //#"Processando arquivo temporário..."
	  IndRegua("WorkEWV", Self:cWorkEWV2+TEOrdBagExt(),"EWV_ARMADO+EWV_CODTAB",,, STR0006) //#"Processando arquivo temporário..."
	   
      Set Index To (Self:cWorkEWV + TEOrdBagExt()),(Self:cWorkEWV2 + TEOrdBagExt())
   
   Else
      WorkEWV->( avzap() )
   EndIf

End Sequence

Return lRet

*========================================*
Method CarregaWork(nOpc,cCodTab) Class EasyTarArm
*========================================*
Local lRet := .T. 

Default cCodTab := Space(0) //Quando a rotina é a principal.

Begin Sequence

   If nOpc <> INCLUIR
       
      //Carregando Work de capa
      EWU->( DBSetOrder(1) )
      If EWU->( DBSeek(xFilial("EWU") + AvKey(M->Y5_COD,"EWU_ARMADO") + IIF(!EMPTY(cCodTab),AvKey(cCodTab,"EWU_CODTAB"),cCodTab)) )
      
         Do While EWU->( !EOF() ).And.;
                  EWU->EWU_FILIAL == xFilial("EWU").And.;
                  EWU->EWU_ARMADO == AvKey(M->Y5_COD,"EWU_ARMADO").And.;
                  IIF(!Empty(cCodTab), AllTrim(EWU->EWU_CODTAB) == AllTrim(cCodTab),.T.)
            WorkEWU->(DBAppend())
            AvReplace("EWU","WorkEWU")
            WorkEWU->EWU_DESPOR := Posicione('SY9',1,xFilial('SY9') + WorkEWU->EWU_Y9COD ,'Y9_DESCR') //para mostrar a informação na MsSelect
               
            EWU->( DBSkip() )
         EndDo
         
      EndIf
         
      //Carregando Work de detalhe
      EWV->( DBSetOrder(1) )
      If EWV->( DBSeek( xFilial("EWV") +  AvKey(M->Y5_COD,"EWV_ARMADO") + IIF(!EMPTY(cCodTab),AvKey(cCodTab,"EWU_CODTAB"),cCodTab)) )
            
         Do While EWV->( !EOF() ) .And.;
                  EWV->EWV_FILIAL == xFilial("EWV") .And.;
                  EWV->EWV_ARMADO == AvKey(M->Y5_COD,"EWV_ARMADO") .And.;
                  IIF(!Empty(cCodTab), AllTrim(EWV->EWV_CODTAB) == AllTrim(cCodTab),.T.)

            WorkEWV->( DBAppend() )
            AvReplace("EWV","WorkEWV")
            EWV->(DBSkip())
         EndDo
         
      EndIf
             
   EndIf
      
   WorkEWU->( DBGoTop() )
   WorkEWV->( DBGoTop() )


End Sequence

Return lRet


*========================================*
Method GravaWork() Class EasyTarArm
*========================================*
Local lRet := .T.
Local i := 0,;
      j := 0,;
      nContDel := 0
Local aGrvWKDet := {}

Begin Sequence


      //Tratamento de persistência em Area de Trabalho para os Detalhes(EWV):      
      WorkEWV->( DBSetOrder(2) )//"EWV_ARMADO+EWV_CODTAB"
      WorkEWV->( DBSeek(M->EWU_ARMADO + M->EWU_CODTAB) )


      /************************/
      //   CAPA DE TARIFAS    //
      /************************/
      
      //Tratamento de persistência em Area de trabalho para a Capa(EWU):
      If Self:nOpc == EXCLUIR
         aAdd( Self:aDelEWU ,WorkEWU->EWU_CODTAB )
         WorkEWU->(DBDelete())

      ElseIf Self:nOpc <> VISUALIZAR
             
         IIf( Self:nOpc == INCLUIR ,WorkEWU->( DBAppend() ) ,Nil )
         AvReplace("M" ,"WorkEWU")
         //Link da tabela de Capa(EWU) com a Detalhe(EWV)
         WorkEWU->EWU_ARMADO := M->EWU_ARMADO
         WorkEWU->EWU_DESPOR := Posicione('SY9',1,xFilial('SY9') + WorkEWU->EWU_Y9COD ,'Y9_DESCR') //para mostrar na msselect


         /************************/
         // DETALHES DE TARIFAS  //
         /************************/
         //Containeres 
         For i := 1 To Len(oGetC:aCols)

             //Verifando se esta deletado o container
             If oGetC:aCols[i][Len(oGetC:aCols[i])]
                nContDel++
                Loop
             EndIf
          
             //Verificando se a linha do Container esta em branco:
             If !Empty(oGetC:aCols[i][1])
   
                //Tafifas dos Containeres
                For j := 1 To Len(oGetD:aCols)

                    //Verifando se esta deletado o container ou se a alinha da tarifa esta em branco
                    If oGetD:aCols[j][Len(oGetD:aCols[j])] .Or. Empty(oGetD:aCols[j][1])
                       Loop
                    EndIf

                                     /*Codig Container  ,Periodo Inicial  ,  Periodo Final    ,  Tarifa                        */
                   aAdd( aGrvWKDet , { oGetC:aCols[i][1],oGetD:aCols[j][1],  oGetD:aCols[j][2],  oGetD:aCols[j][(i-nContDel)+2] } )

                Next
              
             EndIf
          
         Next

         //Ordenando o array por cod. container + periodo inicial :
         aGrvWKDet := aSort( aGrvWKDet,,,{|x,y| x[1] + x[2] < y[1] + y[2] }  )

         //Containeres 
         For i := 1 To Len(aGrvWKDet)

             //Caso nao encontre os dados na work, é feita a inclusão
             If !( WorkEWV->( !EOF() ) .And. WorkEWV->EWV_ARMADO == M->EWU_ARMADO .And. ;
                   WorkEWV->EWV_CODTAB == M->EWU_CODTAB )
                   WorkEWV->( DBAppend() )
                   WorkEWV->EWV_ARMADO := M->EWU_ARMADO
                   WorkEWV->EWV_CODTAB := M->EWU_CODTAB
             EndIf

             WorkEWV->EWV_CODCON := aGrvWKDet[i][1] //Codigo do container
             WorkEWV->EWV_PERINI := aGrvWKDet[i][2] //Periodo Inicial
             WorkEWV->EWV_PERFIN := aGrvWKDet[i][3] //Periodo Final
             WorkEWV->EWV_TARIFA := aGrvWKDet[i][4] //Tarifa
               
             WorkEWV->( DBSkip() )          
         Next

      EndIf

      //Exclui o restante dos registros que ainda pertencem as tarifas
      Do While WorkEWV->(!EOF()) .And. WorkEWV->EWV_ARMADO == M->EWU_ARMADO .And. ;
               WorkEWV->EWV_CODTAB == M->EWU_CODTAB
         WorkEWV->( dbDelete() )
         WorkEWV->( dbSkip() )
      EndDo

End Sequence

Return lRet

*===================================*
Method ExcluiWork() Class EasyTarArm
*===================================*
Local lRet := .T.

Begin Sequence
      
   If Select("WorkEWU") > 0
      //THTS - 06/11/2017 - Temporario no Banco de Dados - Ao fechar a area e executar o e_erasearq, o sistema fechava uma outra area que nao era pra fechar
      WorkEWU->(E_EraseArq(Self:cWorkEWU,Self:cWorkEWU + TEOrdBagExt(),Self:cWorkEWU2 + TEOrdBagExt()))

   EndIf

   If Select("WorkEWV") > 0
      //THTS - 06/11/2017 - Temporario no Banco de Dados - Ao fechar a area e executar o e_erasearq, o sistema fechava uma outra area que nao era pra fechar
      WorkEWV->(E_EraseArq(Self:cWorkEWV,Self:cWorkEWV  + TEOrdBagExt(),Self:cWorkEWV2 + TEOrdBagExt()))
   EndIf
   
End Sequence

Return lRet

*=====================================*
Method GravaTarifas(nOpc) Class EasyTarArm
*=====================================*
Local lRet := .T.

Begin Sequence
  Processa({ || Self:GravaTabela(nOpc) } )
End Sequence

Return lRet

*=====================================*
Method GravaTabela(nOpc) Class EasyTarArm
*=====================================*
Local lRet := .T.
Local i := 1

Self:SetnOpc(nOpc)

Begin Sequence 

      ProcRegua(WorkEWU->(LastRec()))

      *---------------------------------------------------*
      //Tratamento para gravação da tabela de Capa EWU
      *---------------------------------------------------* 

      EWU->( DBSetOrder(1) ) //

      If Self:nOpc == EXCLUIR
         
         //Se o array estiver vazio é deletado todos os registros do armador
         If Empty(Self:aDelEWU)

            WorkEWU->(DbGoTop())
            While WorkEWU->(!EOF())
                  If EWU->( DBSeek( xFilial("EWU") + M->Y5_COD + WorkEWU->EWU_CODTAB ) )
                     If EWU->(RecLock("EWU",.F.))
                        EWU->(DbDelete())
                        EWU->(MsUnLock())   
                     EndIf
                  EndIf
                  WorkEWU->(DbSkip())
            EndDo
            
         EndIf
         
      ElseIf Self:nOpc <> VISUALIZAR
    
          For i := 1 To Len(Self:aDelEWU)
              If EWU->( DBSeek( xFilial("EWU") + M->Y5_COD + Self:aDelEWU[i] ) )  
                 If RecLock( "EWU", .F. )
                    EWU->( DBDelete() )
                    EWU->(MSUnlock())
                 EndIf
              EndIf
         Next         

         WorkEWU->( DBGoTop() )

         Do While WorkEWU->( !EOF() )
                             
            If RecLock( "EWU", !(EWU->( DBSeek( xFilial("EWU") + M->Y5_COD + WorkEWU->EWU_CODTAB ))  ) )
               AvReplace("WorkEWU","EWU")
               EWU->EWU_FILIAL := xFilial("EWU")
               EWU->(MSUnlock())
            EndIf

            WorkEWU->( DBSkip() )
         EndDo

      EndIf

      //CursorWait() //comentado por wfs

  
      *---------------------------------------------------*
      //Tratamento para gravação da tabela de detalhes EWV
      *---------------------------------------------------* 
      ProcRegua(WorkEWV->(LastRec()))
      CursorWait()
      If Self:nOpc == EXCLUIR
         
         //Se o array estiver vazio é deletado todos os registros do armador
         If Empty(Self:aDelEWU)

            WorkEWV->( DBGoTop() )
            EWV->( DBSetOrder(1) )
            While WorkEWV->(!EOF())

               IncProc( STR0007 + AllTrim(WorkEWV->EWV_CODTAB) ) //#"Excluindo Tabelas do porto: "

               If EWV->( DBSeek( xFilial("EWV") + M->Y5_COD + WorkEWV->EWV_CODTAB + WorkEWV->EWV_CODCON + WorkEWV->EWV_PERINI) )
                  If EWV->(RecLock("EWV",.F.))
                     EWV->(DbDelete())
                     EWV->(MsUnLock())   
                  EndIf
               EndIf

               WorkEWV->(DbSkip())

            EndDo
         EndIf

      EndIf
      
      WorkEWV->( DBGoTop() )
      WorkEWV->( DBSetOrder(2) )//"EWV_ARMADO+EWV_CODTAB"
      EWV->( DBSetOrder(1) )//"EWV_FILIAL+EWV_ARMADO+EWV_CODTAB+EWV_CODCON+EWV_PERINI"
      EWV->( DBSeek( xFilial("EWV") + M->Y5_COD ) )

      If Self:nOpc <> VISUALIZAR
      
         //Containeres 
         //Do While WorkEWV->( !EoF()).And. xFilial("EWV") == EWV->EWV_FILIAL .And. M->Y5_COD == WorkEWV->EWV_ARMADO
         Do While WorkEWV->( !EoF()).And. M->Y5_COD == WorkEWV->EWV_ARMADO //WHRS 06/2017  TE-5993 522706 - MTRADE-1123 - Tabela do armador
             
            IncProc( STR0008 + AllTrim(WorkEWV->EWV_CODTAB) ) //#"Gravando Tabelas do porto: "

             //Caso nao encontre os dados na work, é feita a inclusão
             If EWV->(!EOF()) .And. xFilial("EWV") == EWV->EWV_FILIAL .And. EWV->EWV_ARMADO == M->Y5_COD
                EWV->(RecLock("EWV",.F.))
             Else
                EWV->(RecLock("EWV",.T.))
             Endif    
             AvReplace("WorkEWV","EWV")
             EWV->EWV_FILIAL := xFilial("EWV")
             EWV->(MsUnLock())  

             WorkEWV->( DBSkip() )
             EWV->( DBSkip() )
         EndDo

      EndIf

      //Exclui o restante dos registros que ainda pertencem as tarifas
      Do While EWV->(!EOF()) .And. EWV->EWV_ARMADO == M->Y5_COD .And. ;
               EWV->EWV_FILIAL == xFilial("EWV")
         If EWV->(RecLock( "EWV", .F. ))
            EWV->( dbDelete() )
            EWV->( MSUnlock() )
         EndIf
         EWV->( dbSkip() )
      EndDo

      CursorArrow() //wfs

End Sequence

Return lRet


*===============================*
Method MontaTela() Class EasyTarArm
*===============================*
Local i := 1

Private bOk     := { || If(Self:ValidOK(),(Self:SetnBotao(1),oMsDlg:End()), Nil) },;
        bCancel := { || If(MsgYesNo(STR0010,STR0009), (Self:SetnBotao(0), oMsDlg:End()),Nil) } //#"Deseja realmente sair?" ##"Atenção"

Private aPosEnc,;   // Posicionamento da MsMGet
        aPosDados

Private nLimiteEnc := 0

Private oEnch,;  //Obeto de recuperacao do retorno da funcao MsMGet (Enchoice)
        oMsDlg,;  //Objeto da MSDIALOG
        oPanelEnc,; //Painel da Enchoice e da GeDados supeiror
        oPanelDados //Painel da GeDados

Private aTela[0][0],;
        aGets[0]

Begin Sequence

   Self:MontaArray()

   DEFINE MSDIALOG oMsDlg TITLE Self:cTitulo FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM,DLG_COL_FIM OF oMainWnd PIXEL

       nAltura  := int((oMsDlg:nBottom-oMsDlg:nTop)/2)
       nLargura := int((oMsDlg:nRight-oMsDlg:nLeft)/2)

       //Separação da tela em dois paineis com 50 % cada
       oPanelEnc   := TPanel():New(0, 0, "",oMsDlg, , .F., .F.,,, nLargura, (5*nAltura/10), , )
       oPanelDados := TPanel():New(0, 0, "",oMsDlg, , .F., .F.,,, nLargura, (5*nAltura/10), , )   

       //Posicionamento dos Paineis
       oPanelEnc:Align   := CONTROL_ALIGN_TOP
       oPanelDados:Align := CONTROL_ALIGN_ALLCLIENT

       //Separação da enchoice (ao lado esquerdo) com a GetDados (lado direito)
       aPosEnc := PosDlgUp(OpanelEnc)//Posicionamento da enchoice no painel
       aPosDados := PosDlgUp(OPanelDados)
       
       //limites entre o fim da enchoice e o começo da getdados
       nLimiteEnc := aPosEnc[4]-150	
       oEnch   := MsMGet():New(Self:cCapAlias,Self:nReg, If(Self:nOpc == EXCLUIR .or. Self:nOpc == VISUALIZAR,4,Self:nOpc) ,,,,,{aPosEnc[1],aPosEnc[2],aPosEnc[3],nLimiteEnc},,,,,,oPanelEnc) //Enchoice
      
       //GetDados da Capa
       oGetC := Self:AtuGetDados() 
       oGetC:lEditLine := .F. //apenas edição por celula
       oGetC:oBrowse:bHeaderClick := {||}//para nunca habilitar a edição por linha da MSNewGetDados

       //GetDados dos Detalhes
       oGetD := Self:AtuGetDados(.F.)

       //Posicionamento da Enchoice no Painel     	
       oEnch:oBox:Align := CONTROL_ALIGN_LEFT  

       //Carregadados da WK para a NewGetDados
       Self:CarregaDados()

       oGetC:Refresh(.T.)
       oGetD:Refresh(.T.)
       
       If Self:lCopia
          M->EWU_CODTAB := Space(AVSX3("EWU_CODTAB",AV_TAMANHO))
       EndIf
       

   ACTIVATE MSDIALOG oMsDlg ON INIT EnchoiceBar(oMsDlg,bOk,bCancel)

End Sequence

Return 

*====================================*
Method MontaEstru() Class EasyTarArm
*====================================*
Local lRet := .F.

//Carrega Capa da tabela EWU - Tarifas do Armador Capa
RegToMemory( If( Self:nOpc == INCLUIR.And.!Self:lCopia ,"EWU" ,"WorkEWU" ) , Self:nOpc == INCLUIR , /*.F. - RMD-16/11/12 - Cria os campos virtuais na inclusão*/Self:nOpc == INCLUIR ,, "Manut" )
M->EWU_ARMADO := M->Y5_COD 

lRet := .T.

Return lRet

*=================================*
Method CarregaDados() Class EasyTarArm
*=================================*
Local lRet := .T.
Local i:=1,;
      j:=1
Local lFlag := .F.
Local aCodCon := {}

Begin Sequence
     
      //Filtra Detalhes da tabela EWV - Tarifas do Armador Detalhes
      If Self:nOpc <> INCLUIR
         WorkEWV->(DBSetOrder(1))//indice: "EWV_ARMADO+EWV_CODTAB+EWV_CODCON+EWV_PERINI"
              
         If WorkEWV->(DBSeek(AVKEY(M->EWU_ARMADO,"EWU_ARMADO") + AVKEY(M->EWU_CODTAB,"EWU_CODTAB") ))
                 
            Do While !WorkEWV->(EOF()) .And.;
                        M->EWU_ARMADO == WorkEWV->EWV_ARMADO .And.;
                        M->EWU_CODTAB == WorkEWV->EWV_CODTAB
           
                If (nPosic := aScan(aCodCon,AllTrim(WorkEWV->EWV_CODCON))) == 0
                   nPosic := i
                       
                   If lFlag
                      aAdd(oGetC:aCols,{"","",Nil})
                   EndIf
                   oGetC:aCols[i][1] := AllTrim(WorkEWV->EWV_CODCON)
                   oGetC:aCols[i][2] := Posicione("SX5",1,xFilial("SX5")+"C3"+AvKey(WorkEWV->EWV_CODCON,"EWV_CODCON"),"X5_DESCRI")
                   oGetC:aCols[i][3] := .F.

                   //Incluindo a tabela na getdados de detalhes:
                   Self:IncluiColuna(oGetC:aCols[i][1],oGetC:aCols[i][2],nPosic)

                   aAdd(aCodCon,AllTrim(WorkEWV->EWV_CODCON))
                   i++
                EndIf
                   
                If (nLin := aScan(oGetD:aCols,{|X| AllTrim(X[1]) == AllTrim(WorkEWV->EWV_PERINI)})) == 0
                   If lFlag
                      Eval(oGetD:oBrowse:bAdd)//inclui uma linha no oGetD:aCols
                   EndIf
                   nLin := Len(oGetD:aCols)
                EndIf

                oGetD:aCols[nLin][1] := WorkEWV->EWV_PERINI
                oGetD:aCols[nLin][2] := WorkEWV->EWV_PERFIN
                oGetD:aCols[nLin][nPosic+2] := WorkEWV->EWV_TARIFA
                lFlag := .T.
                    
                WorkEWV->(DBSkip())
            EndDo

         EndIf
              
      EndIf
      
End Sequence

Return lRet




*====================================*
Method MontaArray() Class EasyTarArm
*====================================*
Local lRet    := .T.
Local nUsado  := 0,;
      nX      := 0

Begin Sequence

   DbSelectArea("SX3")
   SX3->(DbSetOrder(1))

   If SX3->(DbSeek(Self:cDetAlias))


         nUsado := 2
         IIf(Self:nOpc == VISUALIZAR .Or. Self:nOpc == EXCLUIR, Nil, aAlterCap  := {"EWV_CODCON","EWV_CONTAI"})
         aHeaderCap := {{STR0011, "EWV_CODCON", AVSX3("EWV_CODCON",AV_PICTURE), AVSX3("EWV_CODCON",AV_TAMANHO),; //#"Código"
                         AVSX3("EWV_CODCON",AV_DECIMAL),Nil, Nil, AVSX3("EWV_CODCON",AV_TIPO), Nil, Nil },;
                        {STR0012, "EWV_CONTAI", AVSX3("EWV_CONTAI",AV_PICTURE), AVSX3("EWV_CONTAI",AV_TAMANHO),; //#"Container"
                         AVSX3("EWV_CONTAI",AV_DECIMAL),Nil, Nil, AVSX3("EWV_CONTAI",AV_TIPO), Nil, Nil}}

         aCols := {Array(nUsado+1)}
         aCols[1,nUsado+1] := .F.

         For nX:=1 to nUsado
             aCols[1,nX] := CriaVar(aHeaderCap[nX,2])
         Next


         IIf(Self:nOpc == VISUALIZAR .Or. Self:nOpc == EXCLUIR, Nil, aAlterDet := {"EWV_PERINI","EWV_PERFIN","EWV_TARIFA"}) //campos alteraveis
         
         aHeaderDet := {{STR0013, "EWV_PERINI", AVSX3("EWV_PERINI",AV_PICTURE), AVSX3("EWV_PERINI",AV_TAMANHO),; //#"Per. Inicial"
                         AVSX3("EWV_PERINI",AV_DECIMAL),"AC176ValCampo('EWV_PERINI')", Nil, AVSX3("EWV_PERINI",AV_TIPO), nil, nil },;
                        {STR0014, "EWV_PERFIN",AVSX3("EWV_PERINI",AV_PICTURE), AVSX3("EWV_PERFIN",AV_TAMANHO),; //#"Per. Final"
                         AVSX3("EWV_PERFIN",AV_DECIMAL),"AC176ValCampo('EWV_PERFIN')", Nil, AVSX3("EWV_PERFIN",AV_TIPO), Nil, Nil}}
         
         nUsado := 2
         
         aCols := {Array(nUsado+1)}
         aCols[1,nUsado+1] := .F.

         For nX:=1 to nUsado
             aCols[1,nX] := CriaVar(aHeaderDet[nX,2])
         Next

   Else
      MsgInfo(STR0015,STR0009)//#"Seu Ambiente nao esta preparado para esta rotina" ## "Atenção"
   EndIf

End Sequence

Return lRet


*=========================================================*
Method AtualizaArray(cCod,cDesc,nPosic,nTipo) Class EasyTarArm
*=========================================================*
Local lRet := .T.
Local nI := 1
Local nPosicOri := nPosic

Begin Sequence

    If nTipo == 5 .And. oGetC:aCols[nPosic][Len(oGetC:aCols[nPosic])] //quando Deletado uma linha ja deletada
       nTipo := 3 //incluir a linha que estava deletada
    EndIf

    For nI := 1 To Len(oGetC:aCols)
        If oGetC:aCols[nI][Len(oGetC:aCols[nI])] .And. nI < nPosicOri
           nPosic--
        EndIf
        If nI == nPosicOri
           Exit
        EndIf
    Next

    If nPosic+2 < 2 //Trata a deleção das 2 primeiras colunas fixa
       Break
    EndIf

       Do Case
          Case nTipo = 3//Inclusão de uma coluna
               lRet := Self:IncluiColuna(cCod,cDesc,nPosic)

          Case nTipo = 4 //Alteração de uma coluna
               If Len(aHeaderDet) > 2 //quando se tenta alterar uma coluna que ainda nao existe
                  lRet := Self:AlteraColuna(cCod,cDesc,nPosic)
               Else 
                  lRet := Self:IncluiColuna(cCod,cDesc,nPosic)
               EndIf
          Case nTipo = 5 //Exclusão de uma coluna
               lRet := Self:ExcluiColuna(cCod,cDesc,nPosic)
       End Case

End Sequence

Return lRet


*======================================*
Method AtuGetDados(lCapa) Class EasyTarArm
*======================================*
Local oObRet
Default LCapa := .T.


If lCapa
   oObRet := MsNewGetDados():New(000,nLimiteEnc,aPosEnc[3]+72,aPosEnc[4]-2,GD_INSERT + GD_UPDATE + GD_DELETE ,"AllwaysTrue",;
                                 "AllwaysTrue", "" , aAlterCap, 000 , 999,"AC176PreCad",;
                                 "","AC176PreExclu", oPanelEnc, aHeaderCap, aColsCap,,)
Else
   oGetD  := Nil
   oObRet :=  MsNewGetDados():New(000, 000,aPosDados[3]+46, aPosDados[4]-2, GD_INSERT + GD_UPDATE + GD_DELETE ,"AllwaysTrue",;
                                  "AllwaysTrue", "" , aAlterDet, 000 , 999,"AllwaysTrue",;
                                  "","AC176ExcluiDet", oPanelDados, aHeaderDet, aColsDet,,)
EndIf

Return oObRet


*===================================================*
Method IncluiColuna(cCod,cDesc,nPosic) Class EasyTarArm
*===================================================*
Local lRet := .T.
Local i := 0

Private oCol

Begin Sequence
    
    nPosic := nPosic+2 //+2 devido as duas colunas fixas na getDados de detalhes.
    
    aCol := {cDesc, "EWV_TARIFA", AVSX3("EWV_TARIFA",AV_PICTURE), AVSX3("EWV_TARIFA",AV_TAMANHO),;
             AVSX3("EWV_TARIFA",AV_DECIMAL),"AC176ValCampo('EWV_TARIFA').And.Positivo()", Nil, AVSX3("EWV_TARIFA",AV_TIPO), Nil, Nil,"","","","","","",.F.}

    aAdd(aHeaderDet,Nil)
    aIns(aHeaderDet,nPosic)
    aHeaderDet[nPosic] := aClone(aCol)
    
    For i := 1 To Len(oGetD:aCols)
        aAdd(oGetD:aCols[i],Nil)
        aIns(oGetD:aCols[i],nposic)
        oGetD:aCols[i,nposic] := CriaVar("EWV_TARIFA")
    Next
       
    aColsDet := aClone(oGetD:aCols)

    oGetD := Self:AtuGetDados(.F.)

    
End Sequence

Return lRet


*==================================================*
Method AlteraColuna(cCod,cDesc,nPosic) Class EasyTarArm 
*==================================================*
Local lRet := .T.

Begin Sequence
   nPosic := nPosic+2 //+2 devido as duas colunas fixas na getDados de detalhes.
   
   aHeaderDet[nPosic] := {cDesc, "EWV_TARIFA", AVSX3("EWV_TARIFA",AV_PICTURE), AVSX3("EWV_TARIFA",AV_TAMANHO),;
                          AVSX3("EWV_TARIFA",AV_DECIMAL),"Positivo()", Nil, AVSX3("EWV_TARIFA",AV_TIPO), Nil, Nil,"","","","","","",.F.}
   
   aColsDet := aClone(oGetD:aCols)
   
   oGetD := Self:AtuGetDados(.F.)
   
End Sequence

Return lRet

*==================================================*
Method ExcluiColuna(cCod,cDesc,nPosic) Class EasyTarArm
*==================================================*
Local i := 0
Local lRet := .T.

Begin Sequence
   nPosic := nPosic+2 //+2 devido as duas colunas fixas na getDados de detalhes.
   aDel(aHeaderDet,nPosic)
   ASize(aHeaderDet,Len(aHeaderDet)-1)

   For i := 1 To Len(oGetD:aCols)
       aDel(oGetD:aCols[i],nPosic)
       ASize(oGetD:aCols[i],Len(oGetD:aCols[i])-1)
   Next

End Sequence

aColsDet := aClone(oGetD:aCols)
   
oGetD := Self:AtuGetDados(.F.)

Return lRet


*============================*
Method ValidOK() Class EasyTarArm        
*============================*
Local lRet := .F.
Local cMsg := Space(0)
Local i := 0
Local lFinalBranco := .F. //FSM - 30/03/2012
Local lInconsistente := .F.

Begin Sequence

   //Antes de deletar,verifica se o container não esta sendo usado na rotina de controle de demurrage:
   cTabTarifa := M->EWU_CODTAB
   If Self:nOpc == EXCLUIR .And. Self:VerifContainUtil(cTabTarifa, , ,Self:nOpc)
      lRet := .F.
      Break
   EndIf

   lRet := Obrigatorio(aGets,aTela)
   
   If !lRet 
      Break
   EndIf
  
   //verificando se existe ao menos uma linha na getdados de capa:
   For i:= 1 to Len(oGetC:aCols)
      If !(oGetC:aCols[i][Len(oGetC:aCols[i])]) .And. !Empty(oGetC:aCols[i][1])
        lRet := .T.
        Exit
      Else
         lRet := .F.   
      EndIf   
   Next i
   

   If !lRet
      cMsg += STR0016 + ENTER //#"Preencher ao menos um container para tabela de tarifas." 
   Else
      //verificando se existe ao menos uma linha na getdados de detalhe:
      lFinalBranco := .F.
      For i:= 1 to Len(oGetD:aCols)
          If !(oGetD:aCols[i][Len(oGetD:aCols[i])]) .And. !Empty(oGetD:aCols[i][1])
             lRet := .T.
          EndIf
          
          If !(oGetD:aCols[i][Len(oGetD:aCols[i])]) .And. Empty(oGetD:aCols[i][2])
             If !lFinalBranco
                lFinalBranco := .T.
             Else
                lInconsistente := .T.
                Exit
             EndIf
          EndIf
          
       Next i 
   
       If !lRet
          cMsg += STR0017 + Replic(ENTER,2) //#"Preencher ao menos um período para a(s) tarífa(s) do(s) container(es)."

       ElseIf lInconsistente
          cMsg += STR0048 + Replic(ENTER,2) //#"A tabela de Tarifas do Armador está inconsistente, favor efetuar os devidos ajustes."
       EndIf

   EndIf
   
   //verificando se o ultimo periodo possui o periodo final em branco.
   For i:= Len(oGetD:aCols) To 1 Step(-1)

          //A ultima linha nao pode ser vazia, e nem possuir o ultimo periodo final preenchido:
       If !Empty(oGetD:aCols[i][2] ) .And. !(oGetD:aCols[i][Len(oGetD:aCols[i])]) .Or. ( Empty(oGetD:aCols[i][1] ) .And. Empty(oGetD:aCols[i][2] ) )
          cMsg += STR0041 //##"Para confirmar a gravção é preciso informar um periodo com o final em branco."
          Exit
       ElseIf !(oGetD:aCols[i][Len(oGetD:aCols[i])])
          Exit //sai do loop, pois o ultimo ja foi verificado e o registro esta ok
       EndIf

   Next i 
   
   If !Empty(cMsg)
      EECView(cMsg,STR0009)//#"Atenção"
      lRet := .F.
      Break   
   EndIf
   
   If Self:nOpc == INCLUIR .And. !AC176ValCampo("EWU_Y9COD")
      lRet := .F.
      Break
   EndIf
  
   lRet := MsgYesNo(STR0018,STR0009) //#"Deseja confirmar a operação?" ##"Atenção"

End Sequence

Return lRet

*===============================*
Method ValidBotao() Class EasyTarArm
*===============================*
Local lRet := .F.

Begin Sequence

   If Empty(AllTrim(M->Y5_COD)) //Quando o campo codigo do armador nao esta preenchido
      MsgInfo(STR0019,STR0009)//#"Informe o codigo do armador." ##"Atenção"
      Break
   EndIf
   
   If Self:nOpc <> INCLUIR  .And. WorkEWU->(EoF()) .And. WorkEWU->(BoF())
      MsgInfo(STR0020,STR0009)//#"Não ha Registros cadastrado." ##"Atenção"
      Break
   EndIf
   
   lRet := .T.

End Sequence

Return lRet

*====================================================================================*
Method VerifContainUtil(cTabTarifa,aTipoCon,aPeriodo,nOperacao,lCapa,lPeriodo,nTarifa) Class EasyTarArm
*====================================================================================*
Local lRet := .F. //Falso -  nao esta sendo utilizado
Local i := 0
Local cMsg := IIf(nOperacao==5,"Exclusão","Alteração") +" não efetuada. " + ENTER
Default lPeriodo:= .F.

DBSelectArea( "EJ5" )
DBSelectArea( "EJ6" )

Begin Sequence
      
   EJ5->( DBSetOrder(2) )//"EJ5_FILIAL+EJ5_TABPRE"
   EJ6->( DBSetOrder(3) )//"EJ6_FILIAL+EJ6_CODDEM+EJ6_CODCON"
   
   If EJ5->( DBSeek( xFilial( "EJ5" ) + AvKey(cTabTarifa,"EJ5_TABPRE")  ) )
      
      If nOperacao == 5 //caso a deleção seja da tabela inteira.
         lRet := .T.; cMsg += STR0042 + "'" + AllTrim(EJ5->EJ5_CODDEM) + "'" + STR0047 //#"Algum(ns) container(es) desta tabela de tarifas esta(ão) sendo usado(s) como base de cálculo no processo " ##" na rotina de Controle de Demurrage / Detention."
         Break
      EndIf
      
      
      Do While EJ5->( !EoF() ) .And. xFilial("EJ5") == EJ5->EJ5_FILIAL .And.;
               AllTrim(cTabTarifa) == AllTrim(EJ5->EJ5_TABPRE) 
         
         For i := 1 To Len(aTipoCon)
             If EJ6->( DBseek( xFilial("EJ6") + AvKey(EJ5->EJ5_CODDEM,"EJ6_CODDEM") + AvKey(aTipoCon[i],"EJ6_CODCON") ) )
           
                If lCapa //caso a deleção seja da capa da MsNewGetDados
                   lRet := .T.; cMsg += STR0043 + "'" + AllTrim(EJ5->EJ5_CODDEM) + "'" + STR0047  //#"Este container está sendo usado como base de cálculo do processo " ##" na rotina de Controle de Demurrage / Detention."
                   Break
                EndIf
            
                Do While EJ6->( !EoF() ) .And. xFilial("EJ6") == EJ6->EJ6_FILIAL .And.;
                         AllTrim(EJ5->EJ5_CODDEM) == AllTrim(EJ6->EJ6_CODDEM) .And. AllTrim(aTipoCon[i]) == AllTrim(EJ6->EJ6_CODCON)

                    If EJ6->EJ6_QTDFIN <> 0 //quando zero o processo ainda esta em aberto
               
                       If Val(AllTrim(aPeriodo[1])) <= EJ6->EJ6_QTDFIN .And. Val(AllTrim(aPeriodo[2])) >= EJ6->EJ6_QTDFIN//quantidade de dias do processo finalizado
                          
                          If lPeriodo
                             lRet := .T.; cMsg += STR0044 + "'" + AllTrim(EJ5->EJ5_CODDEM) + "'" + STR0047//#"Este periodo está sendo usado como base de cálculo do processo " ##" na rotina de Controle de Demurrage / Detention."
                             Break
                          EndIf
                          
                          If ValType(nTarifa) == "N" .And. EJ6->EJ6_VTARFI == nTarifa
                             lRet := .T.; cMsg += STR0045 + "'" + AllTrim(EJ5->EJ5_CODDEM) + "'" +  STR0047//#"Este tarifa está sendo usado como base de cálculo do processo " ##" na rotina de Controle de Demurrage / Detention."
                             Break
                          EndIf
          
                       EndIf
                  
                    EndIf
               
                    EJ6->( DBSkip() )
                EndDo
            
             EndIf
         Next   
         
         EJ5->( DBSkip() )
      EndDo
    
   EndIf
  

End Sequence

If lRet
   MsgInfo(cMsg,"Atenção")
EndIf

Return lRet


//////////////////////
//***** SETTERS ****//
//////////////////////
*====================================*
Method SetnOpc(nOpc) Class EasyTarArm
*====================================*
If ValType(nOpc) <> "N"
   nOpc := 3
EndIf
Self:nOpc := nOpc
Return

*=================================*
Method SetnReg(nReg) Class EasyTarArm
*=================================*
If ValType(nReg) <> "N"
   nReg := 0
EndIf
Self:nReg := nReg
Return

*====================================*
Method SetnBotao(nBotao) Class EasyTarArm
*====================================*
If ValType(nBotao) <> "N"
   nBotao := 0
EndIf
Self:nBotao := nBotao
Return 


//***/////////////***//
////// FUNCTIONs //////
//***/////////////***//
*===================*
Function AC176PreCad()
*===================*
Local aCols   := {}
Local lRet    := .F.,;
      lExiste := .F.
Local nPosic  := 0,;
      nI      := 0
Local cCod    := Space(0)
Local cDesc   := Space(0)

aCols  := oGetC:aCols
nPosic := oGetC:nAt //nº da linha do aCols
cCod   := AllTrim(M->EWV_CODCON)
oTarifa:nOpcAdd := 0

Begin Sequence

   If aCols[nPosic][Len(aCols[nPosic])]  //se o acols esta deletado
      MsgInfo(STR0021 + Replic(ENTER,2) +; //#"Não é possivel incluir um registro em uma celula deletada!"
              STR0022,STR0009)//#"Solução: Delete a linha novamente e será possivel incluir o registro." ##"Atenção"
      Break
   EndIf

   If Empty(cCod)
      MsgInfo(STR0023,STR0009) //#"O código do conteiner não pode estar vazio." ##"Atenção"
      Break
   EndIf
   
   If ExistCpo("SX5","C3"+M->EWV_CODCON)

      For nI := 1 To Len(aCols)
          If cCod == AllTrim(aCols[nI,1])
             lExiste := .T.
             MsgInfo(STR0024 + Replic(ENTER,2) +; //#"Este container ja foi informado anteriormente"
                     STR0025,STR0009)//#"Solução: Cancele a operação apertando 'ESC' ou informe outro container." ##"Atenção"
             Break
          EndIf
      Next

      If !lExiste .And. (AllTrim(aCols[nPosic][1]) == "")
         oTarifa:nOpcAdd := 3
         lRet := .T.

      ElseIf !lExiste .And. !(AllTrim(aCols[nPosic][1]) == "")
             oTarifa:nOpcAdd := 4
             lRet := .T.
      EndIf

   EndIf

   If lRet
      If nPosic == 1 .And. AllTrim(M->EWV_CODCON) == ""
         lRet := .F.
         Break
      EndIf

      If oTarifa:nOpcAdd > 0
         cDesc := Posicione("SX5",1,xFilial("SX5")+"C3"+AvKey(M->EWV_CODCON,"EWV_CODCON"),"X5_DESCRI")
         lRet := oTarifa:AtualizaArray(M->EWV_CODCON,cDesc,nPosic,oTarifa:nOpcAdd)
         oTarifa:nOpcAdd := 0
      EndIf
   EndIf


End Sequence

oGetD:Refresh(.T.)

Return lRet


*=====================*
Function AC176PreExclu()
*=====================*
Local aCols := {},;
      aCod := {}
Local lRet  := .T.,;
      lCapa := .T.
Local nOpcV := 5,;
      nOperacao := 4
Local cTabTarifa := M->EWU_CODTAB

Begin Sequence

   If oTarifa:nOpc == EXCLUIR
      lRet := .F. 
      Break
   EndIf

   aCols := oGetC:aCols
   cCod  := AllTrim(aCols[n,1])
   cDesc := AllTrim(aCols[n,2])
   nPosic := N //nº da linha do aCols
  
   //Varifica se o container nao esta sendo usado na rotina de controle de demurrage
   lCapa := .T.
   nOperacao := 5
   aAdd(aCod,cCod)
   If oTarifa:VerifContainUtil(cTabTarifa,aCod,,nOperacao,lCapa)
      lRet := .F.
      Break
   EndIf
      
   If !(Alltrim(oGetC:aCols[nPosic][1]) == "") .And. !(oTarifa:nOpcAdd == 3)
      lRet := oTarifa:AtualizaArray(cCod,cDesc,nPosic,nOpcV)
   EndIf

End Sequence

oGetD:Refresh(.T.)

Return lRet

*===========================*
Function AC176ValCampo(cCampo)
*===========================*
Local lRet := .F.
Local nPerIni := 0,;
      i := 0

Begin Sequence
 
   cCampo := Upper(AllTrim(cCampo))
 
   Do case
      
      Case cCampo == "EWV_PERINI" //Periodo Inicial

           nValor := Val(&(cCampo)) 

           M->EWV_PERINI := STRZero(nValor,3)
           nPerFin := nValor+1
           nPerFinAnt := -1
           
           If !(N == 1)//não é a primeira linha do aCols da getdados
              
              If !(AllTrim(oGetD:aCols[N-1][2]) == "")
                 nPerFinAnt := Val(AllTrim(oGetD:aCols[N-1][2]))
              Else
                 MsgInfo(STR0026 + Replic(ENTER,2) +; //#"O período final anterior está em branco. Impossível acrescentar mais uma tarífa."
                         STR0027,STR0009)//#"Solução: Informar o período final anterior." ##"Atenção"
                 Break
              EndIf
              
              nPerFin := If(!(AllTrim(oGetD:aCols[N][2]) == ""),Val(AllTrim(oGetD:aCols[N][2])),nValor+1)
   
              If (nValor - nPerFinAnt) > 1 .And. MsgYesNo(STR0028 +ENTER+; //#"Há um intervalo entre os dois periodos (data final anterior e data inicial atual)"
                                                          STR0029 ,STR0009) //#"Deseja corrtigir este intervalo?" ##"Atenção"
                 M->EWV_PERINI := STRZero(nPerFinAnt+1,3)
              EndIf

           EndIf

           If nValor > 0 //FSM - 12/03/2012
              If (nValor > nPerFinAnt).And.(nValor < nPerFin)
                 lRet := .T.                 
              Else
                 MsgInfo( STR0030 +ENTER+; //#"O período inicial deve ser maior que o período final anterior "
                          STR0031,STR0009) //#"e menor que o período final a seguir." ## "Atenção"
              EndIf
           Else
              MsgInfo(STR0032,STR0009) //#"O valor informado deve ser positivo e maior que Zero." ##"Atenção" //FSM - 12/03/2012
           EndIf
      
      Case cCampo == "EWV_PERFIN" //periodo final
           
              nValor := Val(&(cCampo))
           
              nPerIni := If(!(AllTrim(oGetD:aCols[N][1]) == ""),Val(AllTrim(oGetD:aCols[N][1])),-1) 
              nPerIniPro := nValor+1
           
              If Len(oGetD:aCols) >= N+1
                 If !(AllTrim(oGetD:aCols[N+1][1]) == "")
                    nPerIniPro := Val(oGetD:aCols[N+1][1])
                 EndIf
              EndIf

              If nValor > 0
                 If (nValor >= nPerIni) .And. (nValor < nPerIniPro)
                    lRet := .T.
                    M->EWV_PERFIN := STRZero(nValor,3)
                 Else
                    MsgInfo(STR0033 +ENTER+;//#"O período final deve ser maior que o período inícial"
                            STR0034 ,STR0009) //#"e menor que o príodo inicial do próximo registro." ##"Atenção"
                 EndIf
              
              ElseIf !Empty(&(cCampo)) .And. nValor <= 0
                     MsgInfo(STR0035,STR0009) //#"O valor informado deve ser positivo." ##"Atenção"

              ElseIf Empty(&(cCampo))
                  lRet := .T.
              EndIf

      Case cCampo == "EWU_DTFINV" //Data final
           
           If !Empty(M->EWU_DTINIV) .And. M->EWU_DTFINV < M->EWU_DTINIV
              MsgInfo(STR0036,STR0009) //#"A data de término de validade deve ser maior ou igual à data de início da validade." ##"Atenção"
           Else
              lRet := .T.
           EndIf

      Case cCampo == "EWU_CODTAB" //Codigo da tabela.

           WorkEWU->( DBSetOrder(1))
           If !(WorkEWU->( DBSeek(M->EWU_ARMADO + M->EWU_CODTAB)))
              lRet := .T.
           Else
              lRet := .F.
              MsgInfo(STR0037,STR0009) //#"O código da tabela informado ja existe para este armador." ##"Atenção"
           EndIf

      Case cCampo == "EWU_Y9COD" //Código do Porto

           DBSelectArea( "EJ5" )
           EJ5->( DBSetOrder(2) )//"EJ5_FILIAL+EJ5_TABPRE"
           
           //verificando se porto ja esta sendo usado em algum processo de Controle de Demurrage
           If EJ5->( DBSeek( xFilial("EJ5") + AvKey(M->EWU_CODTAB,"EJ5_TABPRE") ) ) .And. !oTarifa:lCopia
              MsgInfo(STR0046 + STR0047 ,STR0009) ; Break //##"Existe um processo com o porto que esta sendo usado no Controle de Demurrage."##"Existe um processo com este porto, que está sendo utilizado" ###"Atenção"

           ElseIf !Empty(M->EWU_Y9COD)
              lRet := ExistCpo('SY9',M->EWU_Y9COD)

           Else
              lRet := .T.
           EndIf
            
           
      Case cCampo == "EWV_TARIFA"
           aCod := {}
           aPeriodo := {}
           nTarifa := 0
           
           //add cod containeres
           nColuna := (oGetD:oBrowse:ColPos)
           //posicionamento da coluna de detalhes na coluna de capa -> (-2)
           aAdd(aCod, oGetC:aCols[nColuna-2][1] )
           
           //add a tarifa:
           nTarifa := oGetD:aCols[N][nColuna]
           
           //add periodos (inicial/ final)
           aAdd(aPeriodo, oGetD:aCols[N][1] )
           aAdd(aPeriodo, oGetD:aCols[N][2] )

           lRet := !oTarifa:VerifContainUtil(M->EWU_CODTAB,aCod,aPeriodo,4,.F.,.F.,nTarifa)
           
   End Case

End Sequence

Return lRet

*========================*
Function AC176ExcluiDet()
*========================*
Local lRet := .T.
Local i := 0
Local aPeriodo := {},;
      aCod := {}
Local cTabTarifa := M->EWU_CODTAB

Begin Sequence

   If oTarifa:nOpc == EXCLUIR
      lRet := .F.
      Break
   EndIf
   
   //atribuindo os codigos dos containeres
   For i := 1 To Len(oGetC:aCols)
       If !oGetC:aCols[i,Len(oGetC:aCols[i])] //apenas os nao deletados
          aAdd(aCod, oGetC:aCols[i,1])
       EndIf
   Next   
   
   aAdd(aPeriodo,oGetD:aCols[N,1])
   aAdd(aPeriodo,oGetD:aCols[N,2])
   
   //Antes de deletar,verifica se o container não esta sendo usado na rotina de controle de demurrage:
   If oTarifa:VerifContainUtil(cTabTarifa,aCod,aPeriodo,4,.T.,.T.)
      lRet := .F.
      Break
   EndIf

End Sequence

Return lRet