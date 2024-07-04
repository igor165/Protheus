#INCLUDE "PROTHEUS.CH"
#Include "AVERAGE.CH"
/*
Programa        : AVRETBC.PRW
Objetivo        : Integrar taxa de moeda do site banco central do Brasil
Autor           : Allan Oliveira Monteiro
Revisão         : Thiago Rinaldi Pinto - 02/12/2011 - Atualização das Taxas Fiscais.
Data/Hora       : 22/07/2010 
Obs.            :
*/


Class AvRetBC From AvImport

   Data aAltura
   Data aLargura
   Data aSelCpos
   Data aArqsCsv
   Data oDlgTela
   Data oBmp
   Data oMark1
   Data cDlgTit
   Data cFileWork1
   Data cDir 
   Data cGetFile        
   Data cCount
   Data cMvDirRet
   Data cMarca 
   Data oImport

   Method New()          // Instancia Objeto
   Method Init()         // Inicializa variáveis
   Method LerArquivo()   // Efetua Leitura do Arquivo (.CSV)
   Method CriaWork()     // Estrutura da Work 
   Method MarcaItem()    // Marcar flag no item
   Method MarcaTodos()   // Marcar/Desmarcar flag em todos os itens
   Method Integra()      // Gravação dos itens na tabela
   Method ValidInteg()   // Valida a itegração
   Method SetcMVTxEnvio()// Retorno do Parametro 
   
End Class   

//////////////////////////////////////////
//           Instanciador               //
//////////////////////////////////////////
Function AvRetBC
   Return AvRetBC():New() 

//////////////////////////////////////////
//           Método Construtor          //
//////////////////////////////////////////
Method New() Class AvRetBC 

oMainWnd:ReadClientCoords()

   ::aArqsCsv  := {}
   ::aAltura   := {oMainWnd:nTop+125,  oMainWnd:nLeft+5    } //{0,0}
   ::aLargura  := {oMainWnd:nBottom-60,oMainWnd:nRight - 10} //{700,1250} 
   ::aSelCpos  := {}
   ::oDlgTela  := NIL
   ::oMark1    := NIL
   ::cDlgTit   := "Retorno Banco Central do Brasil"
   ::cCount    := "5"
   ::cDir      := Space(200)
   ::cGetFile  := Space(200) 
   ::cFileWork1:= ""
   ::cMvDirRet := ""
   ::cMarca    := GetMark() 
   
   ::oImport   := AvImport():New()
   ::oImport:SetType("CSV")
   ::oImport:SetSeparador(";")
   ::oImport:SetDecSimb(",")

   
   

//////////////////////////////////////////
//           Método Init                //
////////////////////////////////////////// 
Method Init() Class AvRetBC 
  
   Local COLUNA_FINAL,nLinha
   Local aButtons := {}, aPos:= {}
   Local bOk, bCancel, lCloseOdlg 
   Private lInverte1 := .F.
    
   //Criação da Estrutura do Arquivo de Trabalho
   ::CriaWork()
   
   //Estrutura do objeto MsSelect 
   aAdd(::aSelCpos,{"WK_FLAG"     ,"",""                 }) 
   aAdd(::aSelCpos,{"WK_DTCTMOE"  ,"","Dt Cotacao Moeda" }) 
   aAdd(::aSelCpos,{"WK_CODISC"   ,"","Cod. Siscomex"    })  
   aAdd(::aSelCpos,{"WK_MOEDA"    ,"","Moeda"            }) 
   aAdd(::aSelCpos,{"WK_VLCOMP"   ,"","Vl. Compra"       }) 
   aAdd(::aSelCpos,{"WK_VLVEND"   ,"","Vl. Venda"        })
   aAdd(::aSelCpos,{"WK_VLFISC"   ,"","Vl. Fiscal"        })
   aAdd(::aSelCpos,{"WK_MSG"      ,"","Mensagem"         })                   
   
   
   //Botões da Tela de Manutenção
   aAdd(aButtons, {"OPEN",     {|| chosenFile(::oImport, Self) }, "Selecionar Arquivo"}) 
//   aAdd(aButtons, {"SDUSEEK",  {|| Processa({||::LerArquivo()},"","Processando",.T.) }, "Ler arquivo" }) // SVG - 06/08/2010 - Leitura efetuada ao Selecionar o Arquivo.
   aAdd(aButtons, {"LBTIK",    {|| ::MarcaTodos(::cMarca), ::oMark1:oBrowse:Refresh()                       ,::oDlgTela },"Marca/Desmarca Todos"})//FSY - 13/05/2013
   
   bOk     := {||Iif( lCloseOdlg := MsgYesNo("Deseja executar a integração ?","Aviso"),;
                 IIF(lCloseOdlg := ::ValidInteg(), (Processa({||::Integra()},"","Processando",.F.)),::oMark1:oBrowse:Refresh());//FSY - 13/05/2013
                 , lCloseOdlg := .F. ),Iif(lCloseOdlg,::OdlgTela:End(),)}
   bCancel := {||::OdlgTela:End()}
   
   Define MSDIALOG ::oDlgTela From ::aAltura[1],::aAltura[2] To ::aLargura[1],::aLargura[2] Title ::cDlgTit PIXEL    
   
      ::oDlgTela:lMaximized := .T.//FSY - 13/05/2013
   
      aPos := PosDlg(::oDlgTela)
      aPos[1] := 13

      ::oMark1       := MsSelect():New("WKESTR","WK_FLAG",,::aSelCpos,@lInverte1,@Self:cMarca,aPos)
      ::oMark1:oBrowse:Align := CONTROL_ALIGN_ALLCLIENT
      
      ::oMark1:bAval := {|| ::MarcaItem(::cMarca), ::oMark1:oBrowse:Refresh()} 
                          
   ACTIVATE MSDIALOG ::oDlgTela CENTERED ON INIT EnchoiceBar(oRetBC:oDlgTela,bOk,bCancel,,aButtons) 

	If Select("WKESTR") > 0
		WKESTR->(E_EraseArq(::cFileWork1,::cFileWork1+TEOrdBagExt()))
	EndIf

Return 

Static Function chosenFile(oImport, oAvRetBc)
    If !Empty(oImport:ChooseFile())
        Processa({||oAvRetBc:LerArquivo()},"","Processando",.T.)
    EndIf
Return 

//////////////////////////////////////////
//           Método CriaWork            //
//////////////////////////////////////////
Method CriaWork() Class AvRetBC
Local aEstruWork := {{"WK_FLAG"    ,"C",02,0}}
Local nInc := 0

   ::oImport:AddField("WK_DTCTMOE" ,"D",08,0) 
   ::oImport:AddField("WK_CODISC"  ,"C",03,0)
   ::oImport:AddField("WK_TIPO"    ,"C",01,0)
   ::oImport:AddField("WK_MOEDA"   ,"C",03,0)
   ::oImport:AddField("WK_VLCOMP"  ,"N",AVSX3("YE_TX_COMP",3),AVSX3("YE_TX_COMP",4))
   ::oImport:AddField("WK_VLVEND"  ,"N",AVSX3("YE_VLCON_C",3),AVSX3("YE_VLCON_C",4))
   ::oImport:AddField("WK_VLFISC"  ,"N",AVSX3("YE_VLFISCA",3),AVSX3("YE_VLFISCA",4))
   ::oImport:AddField("WK_PRCOMP"  ,"N",13,5)
   ::oImport:AddField("WK_PRVEND"  ,"N",13,5) 
      
   aEval(::oImport:aHeader, {|x| aAdd(aEstruWork, x) })
   
    aAdd(aEsTruWork,{"WK_MSG"    ,"C",55,0})
   
   If !(Select("WKESTR") <> 0)
      ::cFileWork1:=E_CriaTrab(,aEstruWork,"WKESTR")
      E_IndRegua("WKESTR",::cFileWork1+TEOrdBagExt(),"WK_DTCTMOE")
   Else
      WKESTR->(avzap())
   EndIf
   
Return Nil  



//////////////////////////////////////////
//           Método LerArquivo          //
//////////////////////////////////////////
Method LerArquivo() Class AvRetBC
Local nInc
Local cMsg := "Moeda não cadastrada", cMoeda := "", cMoeda2 := ""   // GFP - 10/08/2012 - Tratamento para integração de diversas Moedas
Local lDiversos := .T.   // GFP - 10/08/2012 - Tratamento para integração de diversas Moedas
Private lTrataTxFiscal := .T.//RMD - 17/01/19 - Possibilita definir via ponto de entrada se será feito o ajuste da taxa fiscal
   
    DbSelectArea("SYF")
    SYF->(DbSetOrder(1))

    If ::oImport:Import()
        WKESTR->(avzap())
        ProcRegua(Len(::oImport:aDados))   
        For nInc := 1 To Len(::oImport:aDados)
            cpyTax(::oImport, nInc)
            IncProc("Carregando os itens...")  
            ////RMD - 17/01/19 - Ponto de entrada para possibilitar ajustar as informações que foram recebidas no arquivo antes de gravar na base de dados
            If ExistBlock("AVRETBC")
                ExecBlock("AVRETBC",.F.,.F.,"CARREGA_TAXAS")
            EndIf 
        Next nInc
    EndIf

   WKESTR->(DBGOTOP())

   // GFP - 10/08/2012 - Tratamento para integração de diversas Moedas
    Begin Sequence
        cMoeda := WKESTR->WK_MOEDA
        WKESTR->(DbSkip())
        cMoeda2 := WKESTR->WK_MOEDA
        WKESTR->(DbSkip(-1))
        If cMoeda == cMoeda2
            lDiversos := .F.
        EndIf
    End Sequence

    nInc:= 1
    If lTrataTxFiscal//RMD - 17/01/19 - Possibilita definir via ponto de entrada se será feito o ajuste da taxa fiscal
        If lDiversos
            Do While WKESTR->(!EOF())
                WKESTR->WK_VLFISC := TaxAntDB(WKESTR->WK_DTCTMOE, WKESTR->WK_MOEDA)
                nInc++
                WKESTR->(DbSkip())
            Enddo
        EndIf
   EndIf

   WKESTR->(DBGOTOP())
   
   //WHRS TE-5918 521174 / MTRADE-1075 - Ponto de entrada Integração de Taxas Banco Central
	IF EasyEntryPoint('AVRETBC')
	   ExecBlock("AVRETBC",.F.,.F.,"APOS_LEITURA_CSV")
	ENDIF
	
   //RMD - 07/02/13
   Self:oMark1:oBrowse:Refresh()

Return Nil

// EJA - 02/05/2019 - Copia uma taxa do objeto 'oImport' com o index 'nIndex' para um novo registro da work 'WKESTR'
Static Function cpyTax(oImport, nIndex, nIndexFisc, nDayIndex)
    Local cMoeda
    Local cMsg := "Moeda não cadastrada"
    Default nIndexFisc := nIndex - 1
    Default nDayIndex := 0

    WKESTR->(DbAppend())                                      
    WKESTR->WK_FLAG    := Space(2)
    WKESTR->WK_DTCTMOE := DaySum(oImport:RetField("WK_DTCTMOE", nIndex), nDayIndex)
    WKESTR->WK_CODISC  := StrZero(Val(oImport:RetField("WK_CODISC"  , nIndex)),3)
    WKESTR->WK_MOEDA   := cMoeda := Posicione("SYF", 3, xFilial("SYF")+WKESTR->WK_CODISC, "YF_MOEDA")
    WKESTR->WK_VLCOMP  := oImport:RetField("WK_VLCOMP" , nIndex)
    WKESTR->WK_VLVEND  := oImport:RetField("WK_VLVEND" , nIndex)
    SYF->(DbSetOrder(1))
    If !(SYF->(DbSeek(xFilial("SYF")+ AvKey(WKESTR->WK_MOEDA,"YF_MOEDA"))))
        WKESTR->WK_MSG := cMsg
    EndIf
    WKESTR->WK_VLFISC  := txDbOrWk(oImport, nIndexFisc, cMoeda)
Return

/*
 * EJA - 02/05/2019 - Se o nIndex for negativo, a taxa fiscal será a última cotação do SYE, senão, será a cotação do registro anterior do CSV
 */
Static Function txDbOrWk(oImport, nIndex, cMoeda)
    Local dDate
    If nIndex < 1
        dDate := oImport:RetField("WK_DTCTMOE", 1)
        Return TaxAntDB(dDate, cMoeda)
    EndIf
Return txComVdObj(oImport, nIndex)

/*
 * EJA - 02/05/2019 - Se o parâmetro MV_INTTX for igual a 'VENDA' irá retornar a taxa de venda do 'oImport' do index 'nIndex'.
 * Se o parâmetro for 'COMPRA', retornará a taxa de compra
 */
Static Function txComVdObj(oImport, nIndex)
    If EasyGParam("MV_INTTX",,"VENDA") == "VENDA"
        Return oImport:RetField("WK_VLVEND" , nIndex)
    EndIf
Return oImport:RetField("WK_VLCOMP" , nIndex)

// EJA - 02/05/2019 - Obtem a taxa do registro mais recente, anterior ao dDate do cadastro de cotação de moedas.
Static Function TaxAntDB(dDate, cMoeda)
    Local dDateAnt := DaySub(dDate, 1)
//  MFR 18/08/2020 OSSME-5037 
If buscTaxVeri(dDateAnt, cMoeda)
        WKESTR->WK_MSG := "Taxa fiscal recuperada do fechamento do dia: " + DtoC(SYE->YE_DATA)
        Return txComVenDB()
    EndIf
Return 0

// EJA - 03/05/2019 - Retorna .T., se existir a taxa da data e moeda do dia anterior, e posiciona no SYE, senão, retorna .F.
Static Function buscTaxVeri(dDate, cMoeda)
Return BuscaTaxa(cMoeda, dDate, .T., .F., .T.) != Nil .And. SYE->YE_DATA <= dDate .And. SYE->YE_MOEDA == cMoeda

// EJA - 02/05/2019 - Se o parâmetro 'MV_INTTX' estiver igual a 'VENDA', retornará SYE->YE_VLCON_C, senão, SYE->YE_TX_COMP
Static Function txComVenDB()
    If EasyGParam("MV_INTTX",,"VENDA") == "VENDA"
        Return SYE->YE_VLCON_C
    Else
        Return SYE->YE_TX_COMP
    EndIf
Return

//////////////////////////////////////////
//           Método MarcaTodos            //
//////////////////////////////////////////
Method MarcaTodos(cMarca) Class AvRetBC
   Local nRec
   Local lCond := .F. 

   Begin Sequence
   
      nRec    := WKESTR->(RecNo())
      cMarca  := IF(!Empty(WKESTR->WK_FLAG),Space(2),cMarca)
      
      WKESTR->(dbGotop())
      While WKESTR->(!Eof())
         If Empty(WKESTR->WK_MOEDA) .and. !Empty(cMarca)
             lCond := .T.
         Else
            WKESTR->WK_FLAG := cMarca
         EndIf
         WKESTR->(DbSkip())
      EndDo
      
      If lCond
         MsgInfo("Existe(m) item(ns) que possui(em) a moeda não cadastrada. Para que possa(m) ser(em) selecionado(s) efetue o(s) cadastro(s) da(s) moeda(s).","Aviso" )
      EndIf
     
   End Sequence
   
   WKESTR->(DbGoTo(nRec)) 
   Self:oMark1:oBrowse:Refresh()//FSY - 13/05/2013

Return Nil


//////////////////////////////////////////
//           Método MarcaItem             //
//////////////////////////////////////////
Method MarcaItem(cMarca) Class AvRetBC

   cMarca  := IF(!Empty(WKESTR->WK_FLAG),Space(2),cMarca)
   
   
   If Empty(WKESTR->WK_MOEDA) .And. !Empty(cMarca)
      MsgInfo("O item não pode ser selecionado, pois a moeda não está cadastrada. Efetue o cadastro da moeda para selecionar o item.", "Aviso")
   Else       
      WKESTR->WK_FLAG := cMarca
   EndIf

Return Nil
 

//////////////////////////////////////////
//           Método Integra             //
////////////////////////////////////////// 
Method Integra() Class AvRetBc 

Local nOpc, aCab := {}
Local nInc:= 0
Local lRet:= .T.
Private lMsErroAuto := .F. //MCF - 20/01/2017

   WKESTR->(DbGoTop()) 
   ProcRegua(WKESTR->(EasyRecCount()))
       
   nInc:= 1
   
   While WKESTR->(!Eof()) .And. WKESTR->(!Bof())
   
      IF Empty(WKESTR->WK_FLAG)
         WKESTR->(DbSkip()) 
         IncProc("Integrando...")
         LOOP
      Else
         aAdd(aCab, {"YE_DATA"    , WKESTR->WK_DTCTMOE  , Nil})
         aAdd(aCab, {"YE_MOEDA"   , WKESTR->WK_MOEDA    , Nil})
         aAdd(aCab, {"YE_VLCON_C" , WKESTR->WK_VLVEND   , Nil})
         aAdd(aCab, {"YE_VLFISCA" , WKESTR->WK_VLFISC /*::SetcMVTxEnvio()*/   , Nil})
         aAdd(aCab, {"YE_TX_COMP" , WKESTR->WK_VLCOMP   , Nil})
         
         SYE->(DbSetOrder(1))
         If SYE->(DbSeek(xFilial("SYE")+AvKey(WKESTR->WK_DTCTMOE,"YE_DATA")+AvKey(WKESTR->WK_MOEDA,"YE_MOEDA")))
            nOpc := 4
         Else
            nOpc := 3
         EndIf
         
         lMsErroAuto := .F.
         
          MsExecAuto({|x,y,z| EICA140(x, y, z) },aCab, Nil, nOpc)
         
         If lMsErroAuto //MCF - 20/01/2017
            MostraErro()
            lRet := .F.
            Exit
         EndIf
         
          IncProc("Integrando...")
          aCab := {}	         
      EndIf
      
      nInc ++
      
      WKESTR->(DbSkip())
   EndDo
   
   If lRet //MCF - 20/01/2017
      MsgInfo("Integração efetuada com Sucesso", "Aviso")
   EndIf

Return lRet

//////////////////////////////////////////
//           Método ValidInteg          //
//////////////////////////////////////////
Method ValidInteg() Class AvRetBC

lRet := .T. 

If WKESTR->(EOF()) .AND. WKESTR->(BOF())
   MsgInfo("Não existem dados no arquivo a serem integrados","Aviso")
   lRet := .F. 
EndIf
   
Return lRet
                                              
//////////////////////////////////////////
//           Método SetcMVTxEnvio       //
//////////////////////////////////////////
Method SetcMVTxEnvio() Class AvRetBC
Local nReturn := 0

If EasyGParam("MV_INTTX",,"VENDA") == "VENDA"
   nReturn := WKESTR->WK_VLVEND
Else
   nReturn := WKESTR->WK_VLCOMP   
EndIf

Return nReturn
