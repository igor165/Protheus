
#Include "AVERAGE.CH"
#Include "XMLXFUN.CH"
#Include "TOPCONN.CH"
#Include "EEC.CH"
#Include "AVFRM101.CH"
#INCLUDE "FWBROWSE.CH"

#Define ITRECEBIDOS   "A"
#Define ITENVIADOS    "B"
#Define ITNAOENVIADOS "C"
#Define ITPROCESSADOS "D"
#Define ITBUSCA       "E"

#Define ST_SEM_INT	"0"
#Define ST_BK_GER	"1"
#Define ST_BK_ENV	"2"
#Define ST_BK_REC	"3"
#Define ST_BK_PROC	"4"
#Define ST_SI_GER	"5"
#Define ST_SI_ENV	"6"
#Define ST_SI_REC	"7"
#Define ST_SI_PROC	"8"
#Define ST_BL_REC	"9"
#Define ST_TT_REC	"A"
#Define ST_BK_CNL1	"B"
#Define ST_BK_CNL2 	"C"
#Define ST_BK_CNL3 	"D"

#Define FONTE_PADRAO "Padrão"

#Define DIR_INBOUND		"comex\easylink\inttra\inbound\"
#Define DIR_OUTBOUND	"comex\easylink\inttra\outbound\"
#Define DIR_RESOURCES	"comex\easylink\inttra\resources\"

#Define XML_ISO_8859_1 "<?xml version='1.0' encoding='ISO-8859-1' ?>"

/*
Programa   : AvFrm101.PRW
Objetivo   : Reunir as funções e classes relacionadas à interface IMonitor da integração com o sistema Inttra.
Autor      : Rodrigo Mendes Diaz
Data/Hora  : 10/08/07
Obs        : 
*/

Function AvFrm101()
Local aOrd := SaveOrd("EEC")
Private oIMonitor := AvIMonitor():New()

// *** NCF - 28/08/2012 - Tratamento para criação de diretorios utilizados
//                        na integração SIGAEEC x INTTRA
If FindFunction("AvUpdate01")
   oUpdAtu := AvUpdate01():New()
EndIf

If ValType(oUpdAtu) == "O" .AND. &("MethIsMemberOf(oUpdAtu,'TABLEDATA')") .AND. Type("oUpdAtu:lSimula") == "L"
   oUpdAtu:aChamados := {{nModulo,{|o| EDirImonitor(o)}}}
   oUpdAtu:Init(,.T.)
EndIf

IF EECFLAGS("INTTRA")
   //Se for chamado do EECAE100, filtra os arquivos pelo processo posicionado
   If IsInCallStack("EECAE100")
      oIMonitor:SetProcess(EEC->EEC_PREEMB)
   EndIf
   oIMonitor:Load()
   oIMonitor:Show()
   oIMonitor:EndObj()
ELSE
   MsgInfo(STR0046,STR0047)
ENDIF   

RestOrd(aOrd, .T.)
Return Nil

/*
Classe      : AvIMonitor
Objetivos   : Exibir interface relacionando os serviços de integração com o sistema Inttra.
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/07
Revisao     : 
Obs.        : 
*/
*===============*
Class AvIMonitor
*===============*

//*** Atributos relacionados ao menu superior (Serviços)
Data oSrvTree
Data aSrvMenu
Data aSrvPos
//***

//*** Atributos relacionados ao menu inferior (Ações)
Data oActTree
Data aActMenu
Data aActPos
//***

//*** Atributos relacionados aos browses
Data aServices
Data aControls
Data aBrowsePos
Data aCamposBrw
//***

//*** Atributos relacionados à tela de resumo
Data oResDlg
Data cActiveSrv
Data aResumeObjs
//***

//*** Atributos relacionados à tela
Data oDlg
Data cDlgTit
Data aDlgPos
//***

//*** Fontes utilizadas na interface
Data oInterfPrefs
//***

//*** Processo definido para exibição das informações (se estiver em branco, exibe todos os processos
Data cProcess
//***

Method New() Constructor

//*** Métodos para criação e exibição da interface
Method Load()
Method Show()
Method EndObj()
//***

//*** Métodos para criação e busca de dados nos arquivos de trabalho
Method GetData(cAlias)
Method NewTempFile(cAlias, cAliasWk)
//***

//*** Métodos para criação e troca de browses
Method CreateBrw()
Method ChangeBrw(cCargo)
Method PrcTodos(cAlias, lEnd)
Method ResumeSrv(cService)
Method Refresh()
//***

//*** Métodos para configuração visual da interface
Method SelFont()
Method SetCoord(cOpc, cCord)
//***

//*** Métodos de execução das opções
Method ChangeOpc(cCargo)
//***

//*** Método para informar o processo que será parâmetro na busca das informações
Method SetProcess(cProcess)
//***

End Class

/*
Método      : New
Classe      : AvIMonitor
Parâmetros  : Nenhum
Retorno     : Self
Objetivos   : Gerar nova instância da classe AvIMonitor
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method New() Class AvIMonitor
Local aSemSx3 := {}

   Self:cProcess := ""

   ::cDlgTit    := STR0001//"IMonitor"
   ::aDlgPos    := {}

   ::aSrvMenu   := {}
   ::aSrvPos    := {}
  
   ::aActMenu   := {}
   ::aActPos    := {}

   ::aServices := {{"BK", STR0002},;//"Booking"
                   {"SI", STR0003},;//"Shipping Instructions"
                   {"BL", STR0004},;//"Bill of Lading"
                   {"TT", STR0005}}//"Track and Trace"

   ::aControls   := {}

   ::aBrowsePos  := {}
   ::aResumeObjs := {}
   ::cActiveSrv  := "TR"
   
   //***
   ::oInterfPrefs := AvInterfPrefs():New()
   ::oInterfPrefs:AddFont("Titulo 1", "ARIAL", 18, .T., .F.)
   ::oInterfPrefs:AddFont("Titulo 2",        , 24, .T., .F.)
   ::oInterfPrefs:AddFont("Titulo 3",        , 16, .T., .F.)
   ::oInterfPrefs:AddFont("Texto 1" ,        ,   , .T., .F.)
   //***

   //Booking
   //Browse de itens recebidos
   aAdd(::aControls, AvIMonBrw():New("BKIRC", STR0006))//"Itens Recebidos"
   ::aControls[Len(::aControls)]:DefWork("WKEYM1", "EYM", , ITRECEBIDOS, 2)
   ::aControls[Len(::aControls)]:DefBrowse({"EYM_FILE", "EYM_USER", "EYM_DTREC", "EYM_HRREC"})

   //Browse de itens enviados
   aAdd(::aControls, AvIMonBrw():New("BKIEN", STR0007))//"Itens Enviados"
   ::aControls[Len(::aControls)]:DefWork("WKEYM2", "EYM", , ITENVIADOS, 2)
   ::aControls[Len(::aControls)]:DefBrowse({"EYM_FILE", "EYM_USER", "EYM_PROC", "EYM_NAVIO", "EYM_VIAGEM", "EYM_ETD", "EYM_DATA", "EYM_HORA", "EYM_DTENV", "EYM_HRENV"})

   //Browse de itens não enviados
   aAdd(::aControls, AvIMonBrw():New("BKINE", STR0008))//"Itens Não Enviados"
   ::aControls[Len(::aControls)]:DefWork("WKEYM3", "EYM", , ITNAOENVIADOS, 2)
   ::aControls[Len(::aControls)]:DefBrowse({"EYM_FILE", "EYM_USER", "EYM_PROC", "EYM_NAVIO", "EYM_VIAGEM", "EYM_ETD", "EYM_DATA", "EYM_HORA"})

   //Browse de itens processados
   aAdd(::aControls, AvIMonBrw():New("BKIPC", STR0009))//"Itens Processados"
   ::aControls[Len(::aControls)]:DefWork("WKEYM4", "EYM", , ITPROCESSADOS, 2)
   ::aControls[Len(::aControls)]:DefBrowse({"EYM_FILE", "EYM_USER", "EYM_PROC", "EYM_ALTTRN", "EYM_BOOK", "EYM_NAVIO", "EYM_VIAGEM", "EYM_ETD", "EYM_BKINTT", "EYM_DTREC", "EYM_HRREC", "EYM_DATABK", "EYM_HORABK", "EYM_ID_DOC", "EYM_ST_MES"})

   //Shipping Instructions
   //Browse de itens recebidos
   aAdd(::aControls, AvIMonBrw():New("SIIRC", STR0006))//"Itens Recebidos"
   ::aControls[Len(::aControls)]:DefWork("WKEYN1", "EYN", , ITRECEBIDOS, 2)
   ::aControls[Len(::aControls)]:DefBrowse({"EYN_FILE", "EYN_USER", "EYN_DTREC", "EYN_HRREC"})
   
   //Browse de itens enviados
   aAdd(::aControls, AvIMonBrw():New("SIIEN", STR0007))//"Itens Enviados"
   ::aControls[Len(::aControls)]:DefWork("WKEYN2", "EYN", , ITENVIADOS, 2)
   ::aControls[Len(::aControls)]:DefBrowse({"EYN_FILE", "EYN_USER", "EYN_PROC", "EYN_ID_SI", "EYN_DATA", "EYN_HORA", "EYN_DTENV", "EYN_HRENV"})
   
   //Browse de itens não enviados
   aAdd(::aControls, AvIMonBrw():New("SIINE", STR0008))//"Itens Não Enviados"
   ::aControls[Len(::aControls)]:DefWork("WKEYN3", "EYN", , ITNAOENVIADOS, 2)
   ::aControls[Len(::aControls)]:DefBrowse({"EYN_FILE", "EYN_USER", "EYN_PROC", "EYN_ID_SI", "EYN_DATA", "EYN_HORA"})
   
   //Browse de itens processados
   aAdd(::aControls, AvIMonBrw():New("SIIPC", STR0009))//"Itens Processados"
   ::aControls[Len(::aControls)]:DefWork("WKEYN4", "EYN", , ITPROCESSADOS, 2)
   ::aControls[Len(::aControls)]:DefBrowse({"EYN_FILE", "EYN_USER", "EYN_PROC", "EYN_ID_SI", "EYN_DTREC", "EYN_HRREC", "EYN_DATASI", "EYN_HRSI", "EYN_ID_DOC", "EYN_ST_MES"})

   //BL
   //Itens recebidos
   aAdd(::aControls, AvIMonBrw():New("BLIRC", STR0006))//"Itens Recebidos"
   ::aControls[Len(::aControls)]:DefWork("WKEYP1", "EYP", , ITRECEBIDOS, 2)
   ::aControls[Len(::aControls)]:DefBrowse({"EYP_FILE", "EYP_USER", "EYP_DTREC", "EYP_HRREC"})

   aSemSx3 := {}
   AddNaoUsado(aSemSx3, "EYP_DSCCOM")
   //Itens processados
   aAdd(::aControls, AvIMonBrw():New("BLIPC", STR0009))//"Itens Processados"
   ::aControls[Len(::aControls)]:DefWork("WKEYP2", "EYP", aSemSx3, ITPROCESSADOS, 2, {"EYP_DSCCOM"})
   ::aControls[Len(::aControls)]:DefBrowse({"EYP_FILE", "EYP_USER", "EYP_DTREC", "EYP_HRREC", "EYP_DATABL", "EYP_HRBL", "EYP_TIPO", "EYP_TIPOD", "EYP_SEQUEN", "EYP_PROC", "EYP_PDF", "EYP_XML", "EYP_BLNUM", "EYP_DSCCOM"})

   //Track&Trace
   //Browse de itens recebidos
   aAdd(::aControls, AvIMonBrw():New("TTIRC", STR0006))//"Itens Recebidos"
   ::aControls[Len(::aControls)]:DefWork("WKEYO1", "EYO", , ITRECEBIDOS, 2)
   ::aControls[Len(::aControls)]:DefBrowse({"EYO_FILE", "EYO_USER", "EYO_DTREC", "EYO_HRREC"})

   //Browse de itens processados
   aSemSx3 := {}
   AddNaoUsado(aSemSx3, "EYO_EVENTO")
   AddNaoUsado(aSemSx3, "EYO_DSCCOM")
   AddNaoUsado(aSemSx3, "EYO_CODCOM")

   aAdd(::aControls, AvIMonBrw():New("TTIPC", STR0009))//"Itens Processados"
   ::aControls[Len(::aControls)]:DefWork("WKEYO2", "EYO", aSemSx3, ITPROCESSADOS, 2, {"EYO_DSCCOM"})
   ::aControls[Len(::aControls)]:DefBrowse({"EYO_CONTNR", "EYO_DATATT", "EYO_HRTT", "EYO_DSCEVE", "EYO_LOCAL", "EYO_LOCREC", "EYO_ORIGEM", "EYO_PINTER", "EYO_DEST", "EYO_LOCENT", "EYO_ETD", "EYO_DTREC", "EYO_HRREC", "EYO_PROC", "EYO_USER", "EYO_ID_DOC", "EYO_FILE"})
   ::aControls[Len(::aControls)]:SetFooter(.T., {"EYO_DSCEVE", "EYO_LOCAL", "EYO_DSCCOM", "EYO_CONTNR", "EYO_PROC"})

   //Browse de itens pesquisados
   aAdd(::aControls, AvIMonBrw():New("TTSRC", STR0010))//"Itens Pesquisados"
   ::aControls[Len(::aControls)]:DefWork("WKEYO3", "EYO", aSemSx3, ITBUSCA, 2, {"EYO_DSCCOM"})
   ::aControls[Len(::aControls)]:DefBrowse({"EYO_CONTNR", "EYO_DATATT", "EYO_HRTT", "EYO_DSCEVE", "EYO_LOCAL", "EYO_LOCREC", "EYO_ORIGEM", "EYO_PINTER", "EYO_DEST", "EYO_LOCENT", "EYO_ETD", "EYO_DTREC", "EYO_HRREC", "EYO_PROC", "EYO_USER", "EYO_ID_DOC", "EYO_FILE"})
   ::aControls[Len(::aControls)]:SetFooter(.T., {"EYO_DSCEVE", "EYO_LOCAL", "EYO_DSCCOM", "EYO_CONTNR", "EYO_PROC"})

Return Self

Method SelFont() Class AvIMonitor
::oInterfPrefs:EditPrefs()
::Refresh()
Return Nil

Method SetProcess(cProcess) Class AvIMonitor

   If ValType(cProcess) == "C" .And. !Empty(cProcess)
      Self:cProcess := cProcess
      Self:cDlgTit := StrTran("Embarque '###'", "###", AllTrim(cProcess))
   EndIf

Return Self:cProcess

/*
Método      : Load()
Classe      : AvIMonitor
Parâmetros  : Nenhum
Retorno     : Nenhum
Objetivos   : Cria janela e demais objetos que irão compor a interface
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method Load() Class AvIMonitor
Local nInc
Local oFont := ::oInterfPrefs:RetFont("Titulo 1")

   ::oSrvTree := AvgXml2Tree():New()
   ::oSrvTree:SetFile("imonitorup.xml")
   ::oSrvTree:SetId("IMONITOR")
   ::oSrvTree:SetMode("COMPLETO")
   ::oSrvTree:LoadTree()

   ::oActTree := AvgXml2Tree():New()
   ::oActTree:SetFile("imonitordown.xml")
   ::oActTree:SetId("IMONITOR")
   ::oActTree:SetMode("COMPLETO")
   ::oActTree:SetMenu(::aActMenu)
   ::oActTree:LoadTree()

   For nInc := 1 to Len(::oActTree:aTree)
      aAdd(::aSrvMenu, {::oActTree:aTree[nInc][2], &("{|| oIMonitor:oActTree:Click('" + ::oActTree:aTree[nInc][3] + "') }") })
   Next
   ::oSrvTree:SetMenu(::aSrvMenu)

   DEFINE MSDIALOG ::oDlg TITLE ::cDlgTit FROM DLG_LIN_INI, DLG_COL_INI;
                                            TO DLG_LIN_FIM, DLG_COL_FIM;
                                            OF oMainWnd PIXEL

      //Define as posições dos objetos
      ::aDlgPos := {1,1,(::oDlg:nClientHeight-6)/2,(::oDlg:nClientWidth-4)/2}

      ::SetCoord()
      @  ::aDlgPos[1], AVG_CORD(02) SAY STR0011 SIZE AVG_CORD(89), 16 FONT oFont Of ::oDlg Pixel//"Serviços"
      ::oSrvTree:SetPosition(::aSrvPos)

      @ ::aSrvPos[3] + 1, AVG_CORD(02) SAY STR0012 SIZE AVG_CORD(89), 16 FONT oFont Of ::oDlg Pixel//"Opções"
      ::oActTree:SetPosition(::aActPos)

      //Cria os menus laterais e todos os browses centrais
      ::oSrvTree:CreateTree(::oDlg)
      ::oActTree:CreateTree(::oDlg)

      ::oSrvTree:OpenTree()
      ::oActTree:OpenTree()

      ::CreateBrw()
      ::ResumeSrv()
      
      If Empty(::oActTree:cError) .And. Empty(::oSrvTree:cError)
         ::oActTree:oTree:bChange := {||}
         ::oSrvTree:oTree:SetFocus()
      EndIf

      ::oDlg:lMaximized := .T.

Return Nil

Method SetCoord(cOpc, cCord) Class AvIMonitor

   If SetMdiChild()
      ::aDlgPos[3] -= 10
   EndIf
   ::aSrvPos    := {::aDlgPos[1] + 17, AVG_CORD(02), ::aDlgPos[3] - AVG_CORD(85), AVG_CORD(90)}
   ::aActPos    := {::aSrvPos[3] + 18, AVG_CORD(02), ::aDlgPos[3], AVG_CORD(90)}
   ::aBrowsePos := {::aDlgPos[1], AVG_CORD(92), ::aDlgPos[3], ::aDlgPos[4]}

Return Nil

/*
Método      : CreateBrw()
Classe      : AvIMonitor
Parâmetros  : Nenhum
Retorno     : Nenhum
Objetivos   : Criar os browses que serão exibidos pelo I-Monitor
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     : 
Obs.        : 
*/
Method CreateBrw() Class AvIMonitor
Local nInc1
Private cMarca := GetMark()
Private lInverte := .F.

   For nInc1 := 1 To Len(::aControls)
      If ::aControls[nInc1]:IsType("AVIMONBRW")
         ::aControls[nInc1]:GetData(Self:cProcess)
         ::aControls[nInc1]:SetBrowse(::oDlg, ::aBrowsePos)
         ::aControls[nInc1]:Hide()
      EndIf
   Next

Return Nil

Method Refresh(cCargo, lRefResDlg) Class AvIMonitor
Local nInc
Default cCargo := ""
Default lRefResDlg := .T.

For nInc := 1 To Len(::aControls) 
   If ::aControls[nInc]:IsType("AVIMONBRW") .And. If(Len(cCargo) > 0, ::aControls[nInc]:GetCargo() == cCargo, .T.)
      ::aControls[nInc]:GetData(Self:cProcess)
      ::aControls[nInc]:Refresh()
   EndIf
Next
If lRefResDlg .And. ::oResDlg:lVisible
   ::ResumeSrv(AllTrim(::oSrvTree:oTree:GetCargo()))
EndIf

Return Nil

/*
Método      : ResumeSrv(cService)
Classe      : AvIMonitor
Parâmetros  : cService - Indica o serviço que será listado. Caso não for informado ou for igual a "TR" 
              serão listados todos os serviços do atributo aServices
Retorno     : Nenhum
Objetivos   : Cria tela de resumo de informações dos serviços
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method ResumeSrv(cService) Class AvIMonitor
Local nLin, nColA, nColB, nLinIni := nLinMax := 10,;
      nAddLin := 08, nTab := 5,;
      nCol1 := 10, nCol2 := 50,;
      nCol3 := nCol1 + 180, nCol4 := nCol2 + 180
Local nInc1, nInc2
Local nTotSrv := 1, nTotBrw := 0
Local oFont1 := ::oInterfPrefs:RetFont("Titulo 2")
Local oFont2 := ::oInterfPrefs:RetFont("Titulo 3")
Local oBold  := ::oInterfPrefs:RetFont("Texto 1")

Default cService := ""
   
   If ValType(::oResDlg) <> "O"
      //Objeto principal
      ::oResDlg := TScrollBox():New(::oDlg, ::aBrowsePos[1], ::aBrowsePos[2], ::aBrowsePos[3] - ::aBrowsePos[1], ::aBrowsePos[4] - ::aBrowsePos[2],.T.,.F.,.T. )
      //Cabeçalho
      @ nLinIni,nCol1 SAY STR0013 FONT oFont1 OF ::oResDlg PIXEL//"IMonitor - Painel Gerencial"

      nLinIni += nAddLin + 20
      nLinMax := nLinIni
   
      For nInc1 := 1 To Len(::aServices)

         If Mod(nTotSrv, 2) == 0
            nLin := nLinIni
            nColA := nCol3
            nColB := nCol4
         Else
            nLin := nLinMax
            nColA := nCol1
            nColB := nCol2
         EndIf
         
         If nTotSrv > 2
            nLin += 25
         EndIf
         
         //Descrição do serviço
         aAdd(::aResumeObjs,;
         {"SRV" + StrZero(nInc1, 3) + StrZero(0, 3),;
         TSay():New(nLin, nColA, &("{|| '' }"), ::oResDlg,, oFont2,,,, .T.,,, 150, 15)})
         nLin += nAddLin + 6
         nTotBrw := 0
         For nInc2 := 1 To Len(::aControls)

            If !::aControls[nInc2]:IsType("AvIMonBrw") .Or. ::aControls[nInc2]:GetService() <> ::aServices[nInc1][1]
               Loop
            EndIf
            
            ++nTotBrw
            
            //Título da pasta
            aAdd(::aResumeObjs,;
            {"TIT" + StrZero(nInc1, 3) + StrZero(nTotBrw, 3),;
            TSay():New(nLin, nColA + nTab, &("{|| '' }"), ::oResDlg,, oBold,,,, .T.,,, 100, 10)})

            //"Total de Itens"
            nLin += nAddLin
            aAdd(::aResumeObjs,;
            {"TOT" + StrZero(nInc1, 3) + StrZero(nTotBrw, 3),;
            TSay():New(nLin, nColA + nTab, {|| STR0014 }, ::oResDlg,, oBold,,,, .T.,,, 60, 10)})//"Total de Itens:"

            //Quantidade de itens na pasta
            aAdd(::aResumeObjs,;
            {"VAL" + StrZero(nInc1, 3) + StrZero(nTotBrw, 3),;
            TSay():New(nLin, nColB + nTab, &("{|| '' }"), ::oResDlg,, oBold,,,, .T.,,, 60, 10)})

            nLin += nAddLin + 5
            nLinMax := nLin
            If Mod(nTotSrv, 2) == 0
               nLinIni := nLinMax
            EndIf
         Next
         ++nTotSrv
      Next
      //Rodapé
      @ nLin + nAddLin, 10 SAY STR0015 OF ::oResDlg PIXEL//"Para atualizar o resumo de itens clique em 'Atualizar' no menu lateral."
      ::ResumeSrv(cService)
   Else
      For nInc1 := 1 To Len(::aResumeObjs)
         ::aResumeObjs[nInc1][2]:Hide()
      Next
      nTotSrv := 0
      For nInc1 := 1 To Len(::aServices)
         If Empty(cService) .Or. cService == "TR" .Or. cService == ::aServices[nInc1][1]
            ++nTotSrv
            //Descrição do serviço
            nPos := aScan(::aResumeObjs, {|x| x[1] == "SRV" + StrZero(nTotSrv, 3) + StrZero(0, 3) })
            ::aResumeObjs[nPos][2]:cCaption := ::aServices[nInc1][2]
            ::aResumeObjs[nPos][2]:oFont := oFont2
            ::aResumeObjs[nPos][2]:Show()
            nTotBrw := 0
            For nInc2 := 1 To Len(::aControls)
               If !::aControls[nInc2]:IsType("AvIMonBrw")
                  Loop
               EndIf
               If ::aControls[nInc2]:GetService() == ::aServices[nInc1][1]
                  ++nTotBrw
                  //Titulo da pasta
                  nPos := aScan(::aResumeObjs, {|x| x[1] == "TIT" + StrZero(nTotSrv, 3) + StrZero(nTotBrw, 3) })
                  ::aResumeObjs[nPos][2]:cCaption := ::aControls[nInc2]:GetId()
                  ::aResumeObjs[nPos][2]:oFont := oBold
                  ::aResumeObjs[nPos][2]:Show()
                  //"Total de itens"
                  nPos := aScan(::aResumeObjs, {|x| x[1] == "TOT" + StrZero(nTotSrv, 3) + StrZero(nTotBrw, 3) })
                  ::aResumeObjs[nPos][2]:oFont := oBold
                  ::aResumeObjs[nPos][2]:Show()
                  //Quantidade de itens na pasta
                  nPos := aScan(::aResumeObjs, {|x| x[1] == "VAL" + StrZero(nTotSrv, 3) + StrZero(nTotBrw, 3) })
                  ::aResumeObjs[nPos][2]:cCaption := Str(::aControls[nInc2]:GetTotItens())
                  ::aResumeObjs[nPos][2]:oFont := oBold
                  ::aResumeObjs[nPos][2]:Show()

               EndIf
            Next
         EndIf
      Next
      ::oResDlg:Show()
   EndIf

Return Nil

/*
Método      : ChangeBrw(cCargo)
Classe      : AvIMonitor
Parâmetros  : cCargo - Atributo Cargo do objeto TreeView, indica qual galho/folha foi selecionado pelo usuário
Retorno     : Nenhum
Objetivos   : Alterar o Browse exibido conforme o galho/folha selecionado no Menu de Serviços
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method ChangeBrw(cCargo) Class AvIMonitor
Local nInc, nPos
Default cCargo := ::cActiveSrv

   If Len(cCargo) == 2
      If Len(::cActiveSrv) > 2 .And. (nPos := aScan(::aControls, {|o| o:IsType("AVIMONBRW") .And. o:GetCargo() == ::cActiveSrv })) > 0
         ::aControls[nPos]:Hide()
      EndIf
      If cCargo <> Left(::cActiveSrv, 2)
         ::cActiveSrv := cCargo
         ::oActTree:oTree:SetFocus()
         ::oActTree:Refresh()
         ::oSrvTree:oTree:SetFocus()
         If ::oResDlg:lVisible
            ::oResDlg:Hide()
         EndIf
      Else
         ::cActiveSrv := cCargo
      EndIf
      If !::oResDlg:lVisible
         ::ResumeSrv(cCargo)
      EndIf
   Else
      If Len(::cActiveSrv) > 2 .And. (nPos := aScan(::aControls, {|o| o:IsType("AVIMONBRW") .And. o:GetCargo() == ::cActiveSrv })) > 0
         ::aControls[nPos]:Hide()
      EndIf
      If (nPos := aScan(::aControls, {|o| o:IsType("AVIMONBRW") .And. o:GetCargo() == cCargo })) > 0
         ::aControls[nPos]:Show()
      EndIf
      If Left(cCargo, 2) <> Left(::cActiveSrv, 2)
         ::cActiveSrv := cCargo
         ::oActTree:oTree:SetFocus()
         ::oActTree:Refresh()
         ::oSrvTree:oTree:SetFocus()
      Else
         ::cActiveSrv := cCargo
      EndIf
      If ::oResDlg:lVisible
         ::oResDlg:Hide()
      EndIf
   EndIf

Return Nil

Method ChangeOpc(cCargo, lInterface, oProcess, cSrvCargo) Class AvIMonitor
Local oBrowse
Local aFilter, aFile
Local cFileZIP, cNewDir
Local nPos
Local lRefresh := .T.
Local aRefresh := {}
Local aFRM10401 := {}
Local lFound
Local nInc
Local cHistorico := ""
Default lInterface := .T.
Default cSrvCargo := AllTrim(::oSrvTree:oTree:GetCargo())

Private cNomFileX, cNomFileP

Private lHistDocAuto
Private aHistDocAuto

Private cOpcao := "", cProcesso := "", cNomFile, cID, cSeqSI

Begin Sequence

   Do Case
      ///***
      //Geração de arquivos de integração (Serviços de Booking e Shipment Instructions)
      Case cCargo == "OPNEW"
         If !(SubStr(cSrvCargo, 0, 2) == "BK" .Or. SubStr(cSrvCargo, 0, 2) == "SI")
            MsgInfo(STR0016, STR0017)//"Opção inválida para o serviço selecionado."###"Atenção"
            Break
         EndIf

         cOpcao := "Original"
         cProcesso := Frm103GetEmb(Self)
         If !ValidaEnvio(SubStr(cSrvCargo, 0, 2), cProcesso)
            Break
         EndIf
         If SubStr(cSrvCargo, 0, 2) == "BK" .And. EEC->(FieldPos("EEC_STABKM")) > 0 .And. !(Posicione("EEC", 1, xFilial("EEC")+cProcesso, "EEC_STABKM") $ "1/ ")
            MsgInfo(STR0048,STR0047)
            Break
         EndIf
         cNomFile := NewFileName(,,SubStr(cSrvCargo, 0, 2))
         cId := AllTrim(cProcesso)
         If SubStr(cSrvCargo, 0, 2) == "SI"
            cSeqSi := GetSeqSi(cProcesso)
            cId += "/" + cSeqSI
         EndIf
         If Empty(cProcesso)
            Break
         EndIf
         Do Case
            Case SubStr(cSrvCargo, 0, 2) == "BK"
               Frm104SolInt("300", "BK", cProcesso, INCLUIR)
               aRefresh := {"BKINE"}
            Case SubStr(cSrvCargo, 0, 2) == "SI"
               Frm104SolInt("302", "SI", cProcesso, INCLUIR)
               aRefresh := {"SIINE"}
            Otherwise 
               MsgInfo(STR0018, STR0017)//"Selecione uma das opções válidas de serviços para gerar um novo arquivo."###"Atenção"
               lRefresh := .F.
         End Case
      //***
      
      //***
      //Processamento de arquivos recebidos (Booking, Shipping Instructions, B/L e Track & Trace)
      Case cCargo == "OPPRC"
         Do Case
            Case cSrvCargo == "BKIRC" .Or. cSrvCargo == "BKIPC"
               If cSrvCargo == "BKIRC"
                  cAlias := "WKEYM1"
               ElseIf cSrvCargo == "BKIPC"
                  cAlias := "WKEYM4"
               EndIf
               If IsVazio(cAlias)
                  MsgInfo(STR0049,STR0047)
                  Break
               EndIf
               cNomFile := AllTrim(DIR_INBOUND + (cAlias)->EYM_FILE)
               If Upper(Right(cNomFile, 3)) == ".XM"
                  cNomFile += "l"
               EndIf
               If Upper(Right(cNomFile, 2)) == ".X"
                  cNomFile += "ml"
               EndIf
               //NCF - 17/04/2012
               If Upper(Right(cNomFile, 1)) == "."
                  cNomFile += "xml"
               EndIf
               If !File(cNomFile)
                  MsgInfo(StrTran(STR0050, "XXX", cNomFile), STR0047)
                  Break
               EndIf
               EYM->(DbGoTo((cAlias)->WK_RECNO))
               cRet := Frm104RecInt("301", oProcess)
               If Type("lProcTodos") == "L" .And. lProcTodos
                  If !Empty(cRet)
                     cRetorno += cRet + ENTER
                     aAdd(aProcessos, EYM->EYM_PROC)
                  EndIf
               Else
                  If !Empty(cRet)
                     MsgInfo(cRet, STR0047)
                     cProcesso := EYM->EYM_PROC
                  Else
                     MsgInfo(STR0051, STR0047)
                  EndIf
               EndIf
               aRefresh := {"BKIRC", "BKIPC"}

            Case cSrvCargo == "SIIRC"
               If IsVazio("WKEYN1")
                  MsgInfo(STR0049, STR0047)
                  Break
               EndIf
               cNomFile := DIR_INBOUND + WKEYN1->EYN_FILE
               If Upper(Right(cNomFile, 3)) == ".XM"
                  cNomFile += "l"
               EndIf
               //NCF - 17/04/2012
               If Upper(Right(cNomFile, 2)) == ".X"
                  cNomFile += "ml"
               EndIf 
               If Upper(Right(cNomFile, 1)) == "."
                  cNomFile += "xml"
               EndIf
               If !File(cNomFile)
                  MsgInfo(StrTran(STR0050, "XXX", cNomFile), STR0047)
                  Break
               EndIf
               cRet := Frm104RecInt("303", oProcess)
               If Type("lProcTodos") == "L" .And. lProcTodos
                  If !Empty(cRet)
                     cRetorno += cRet + ENTER
                     aAdd(aProcessos, EYN->EYN_PROC)
                  EndIf
               Else
                  If !Empty(cRet)
                     MsgInfo(cRet, STR0047)
                     cProcesso := EYN->EYN_PROC
                  Else
                     MsgInfo(STR0051, STR0047)
                  EndIf
               EndIf
               aRefresh := {"SIIRC", "SIIPC"}

            Case cSrvCargo == "TTIRC"
               If IsVazio("WKEYO1")
                  MsgInfo(STR0049, STR0047)
                  Break
               EndIf
               cNomFile := DIR_INBOUND + WKEYO1->EYO_FILE
               If Upper(Right(cNomFile, 3)) == ".XM"
                  cNomFile += "l"
               EndIf
               If Upper(Right(cNomFile, 2)) == ".X"
                  cNomFile += "ml"
               EndIf
               //NCF - 17/04/2012
               If Upper(Right(cNomFile, 1)) == "."
                  cNomFile += "xml"
               EndIf
               If !File(cNomFile)
                  MsgInfo(StrTran(STR0050, "XXX", cNomFile), STR0047)
                  Break
               EndIf
               RegToMemory("EEC")
               EXL->(DbSeek(xFilial()+EEC->EEC_PREEMB))
               RegToMemory("EXL")
               
               cRet := Frm104RecInt("304", oProcess)
               If Type("lProcTodos") == "L" .And. lProcTodos
                  If !Empty(cRet)
                     cRetorno += cRet + ENTER
                     aAdd(aProcessos, EYO->EYO_PROC)
                  EndIf
               Else
                  If !Empty(cRet)
                     MsgInfo(cRet, STR0047)
                     cProcesso := EYO->EYO_PROC
                  Else
                     MsgInfo(STR0051, STR0047)
                  EndIf
               EndIf
               
               //RMD - 29/11/09 - Registra o histórico de alterações no processo.
               cHistorico := Ae110MonHistProc("EEC", "EEC", "M")
               cHistorico += Ae110MonHistProc("EXL", "EXL", "M")
               If !Empty(Alltrim(cHistorico))
                  Ae110CadHistProc(OC_EM, EEC->EEC_PREEMB, "", cHistorico)
               EndIf
               
               aRefresh := {"TTIRC", "TTIPC"}
            Case cSrvCargo == "BLIRC"
               If IsVazio("WKEYP1")
                  MsgInfo(STR0049, STR0047)
                  Break
               EndIf
               //Arquivo de B/L (zipado)
               //Faz a abertura do arquivo .zip
               //Deve ser informado o caminho completo do servidor+arquivo
               cFileZIP := AllTrim(WKEYP1->EYP_FILE)
               If Upper(Right(cFileZIP, 3)) == ".ZI"
                  cFileZIP += "p"
               EndIf
               If !File(DIR_INBOUND + cFileZIP)
                  MsgInfo(StrTran(STR0050, "XXX", cFileZIP), STR0047)
                  Break
               EndIf
               //Diretório de destino do conteúdo do arquivo, terá o mesmo nome do zip
               cNewDir  := DIR_INBOUND + Left(cFileZIP, Len(AllTrim(cFileZIP)) - 4)
               //Descompacta o arquivo
               AvUnZip(cFileZIP, DIR_INBOUND, cNewDir, lInterface, 0)
               //Verifica os arquivos que foram descompactados no diretório
               aFile := Directory(cNewDir + "\*.*", "D")
               //Procura pelo arquivo XML de integração
               If (nPos := aScan(aFile, {|a| ".XML" $ Upper(a[1]) })) > 0
                  cNomFileX := aFile[nPos][1]
               EndIf
               //Procura pelo documento PDF do B/L
               If (nPos := aScan(aFile, {|a| ".PDF" $ Upper(a[1]) })) > 0
                  cNomFileP := aFile[nPos][1]
               EndIf
               If (ValType(cNomFileX) <> "C") .Or. (ValType(cNomFileP) <> "C")
                  If lInterface
                     MsgInfo(STR0019, STR0017)//"Não foram encontrados arquivos de integração no .zip"###"Atenção"
                  EndIf
                  Break
               EndIf
               //Processa o arquivo XML de integração
               cNomFile := DIR_INBOUND + Left(cFileZIP, Len(AllTrim(cFileZIP)) - 4) + "\" + cNomFileX

               RegToMemory("EEC")
               EXL->(DbSeek(xFilial()+EEC->EEC_PREEMB))
               RegToMemory("EXL")

               cRet := Frm104RecInt("305", oProcess)
               If Type("lProcTodos") == "L" .And. lProcTodos
                  If !Empty(cRet)
                     cRetorno += cRet + ENTER
                     aAdd(aProcessos, EYP->EYP_PROC)
                  EndIf
               Else
                  If !Empty(cRet)
                     MsgInfo(cRet, STR0047)
                     cProcesso := EYP->EYP_PROC
                  Else
                     MsgInfo(STR0051, STR0047)
                  EndIf
               EndIf

               //RMD - 29/11/09 - Registra o histórico de alterações no processo.
               cHistorico := Ae110MonHistProc("EEC", "EEC", "M")
               cHistorico += Ae110MonHistProc("EXL", "EXL", "M")
               If !Empty(Alltrim(cHistorico))
                  Ae110CadHistProc(OC_EM, EEC->EEC_PREEMB, "", cHistorico)
               EndIf

               //Arquiva o documento PDF do B/L no histórico de documentos, vinculando-o ao processo de embarque correspondente
               cChaveDoc := ""
               lHistDocAuto := .T.
               aHistDocAuto := {{"aSelecao"   , {"3", EYP->EYP_PROC, DIR_INBOUND + Left(cFileZIP, Len(AllTrim(WKEYP1->EYP_FILE)) - 4) + "\" + cNomFileP}},;
                                 {"Y0_DOC"    , STR0004},;//"Bill of Lading"
                                 {"Y0_PAGINAS", 1}}

               If !EECHistDoc()
                  If lInterface
                     MsgInfo(STR0052, STR0047)
                  EndIf
               Else
                  FErase(DIR_INBOUND + Left(WKEYP1->EYP_FILE, Len(AllTrim(cFileZIP)) - 4) + "\" + cNomFileP)
//                  If EYP->(RecLock("EYP", .F.))
//                     EYP->EYP_CHAVE := cChaveDoc
//                     WKEYP1->EYP_CHAVE := cChaveDoc
//                     EYP->(MsUnlock())
//                  EndIf
               EndIf
               aRefresh := {"BLIRC", "BLIPC"}
            Otherwise
               If lInterface
                  MsgInfo(STR0021, STR0017)//"Selecione uma pasta de itens recebidos e um arquivo para processar."###"Atenção"
                  lRefresh := .F.
               EndIf
         EndCase
      //***

      //***
      //Processamento de todos os arquivos do serviço selecionado
      Case cCargo == "OPPTP"
         If SubStr(cSrvCargo, 3, 3) == "IRC"
            Do Case
               Case cSrvCargo == "BKIRC"
                  cAlias :=  "WKEYM1"
               Case cSrvCargo == "SIIRC"
                  cAlias := "WKEYN1"
               Case cSrvCargo == "TTIRC"
                  cAlias := "WKEYO1"
               Case cSrvCargo == "BLIRC"
                  cAlias := "WKEYP1"
            End Case
            If IsVazio(cAlias)
               MsgInfo(STR0049, STR0047)
               Break
            EndIf
            cRet := ""
            aProcessos := {}
            oProcess := MsNewProcess():New({|lEnd| cRet := ::PrcTodos(cAlias, cSrvCargo, @lEnd, oProcess) }, STR0022, STR0023, .T.)//"Aguarde..."###"Processando todos os arquivos"
            oProcess:Activate()
            If !Empty(cRet)
               EECView(cRet, STR0053)
            EndIf
            aRefresh := {cSrvCargo, Left(cSrvCargo, 2) + "PRC"}
         Else
            MsgInfo(STR0024, STR0017)//"Selecione uma pasta de itens recebidos e um arquivo para processar."###"Atenção"
            lRefresh := .F.
         EndIf
      //***
      
      //***
      //Processamento de todos os arquivos de todos os serviços
      Case cCargo == "OPPTS"
         aPastasIn := {"BKIRC", "SIIRC", "TTIRC", "BLIRC"}
         aProcessos := {}
         For nInc := 1 To Len(aPastasIn)
            Do Case
               Case aPastasIn[nInc] == "BKIRC"
                  cAlias :=  "WKEYM1"
               Case aPastasIn[nInc] == "SIIRC"
                  cAlias := "WKEYN1"
               Case aPastasIn[nInc] == "TTIRC"
                  cAlias := "WKEYO1"
               Case aPastasIn[nInc] == "BLIRC"
                  cAlias := "WKEYP1"
            End Case
            cRet := ""
            oProcess := MsNewProcess():New({|lEnd| cRet += ::PrcTodos(cAlias, aPastasIn[nInc], @lEnd, oProcess) }, STR0022, STR0023, .T.)//"Aguarde..."###"Processando todos os arquivos"
            oProcess:Activate()
            If !Empty(cRet)
               EECView(cRet, STR0053)
            EndIf
         Next
      //***

      //*** 
      //Reenvio de arquivos de integração (Serviços de Booking e Shipment Instructions)
      Case cCargo == "OPREE"
         If !(SubStr(cSrvCargo, 0, 2) == "BK" .Or. SubStr(cSrvCargo, 0, 2) == "SI")
            MsgInfo(STR0025, STR0017)//"Opção inválida para o serviço selecionado."###"Atenção"
            lRefresh := .F.
            Break
         EndIf
         
         If "2.0" $ EasyGParam("MV_AVG0217",,"1.0") .And. SubStr(cSrvCargo, 0, 2) == "BK"
            cOpcao := "Change"
         Else 
            cOpcao := "Amendment"
         EndIf         

         Do Case
            Case cSrvCargo == "BKIPC"
               cNomFile := NewFileName(,,SubStr(cSrvCargo, 0, 2))
               cProcesso := WKEYM4->EYM_PROC
               cId := cProcesso
               cInttraRef := AllTrim(WKEYM4->EYM_BKINTT)
               cBooking := AllTrim(WKEYM4->EYM_BOOK)
               If !ValidaEnvio(SubStr(cSrvCargo, 0, 2), cProcesso)
                  Break
               EndIf
               Frm104SolInt("300", "BK", cProcesso, ALTERAR)
               aRefresh := {"BKINE", "BKIEN"}

            Case cSrvCargo == "SIIPC"
               cNomFile := NewFileName(,,SubStr(cSrvCargo, 0, 2))
               cProcesso := WKEYN4->EYN_PROC
               cId := WKEYN4->EYN_ID_SI
               cSeqSI := Right(AllTrim(WKEYN4->EYN_ID_SI), 3)
               Frm104SolInt("302", "SI", cProcesso, ALTERAR)
               aRefresh := {"SIINE", "SIIEN"}

            Otherwise
               MsgInfo(STR0054, STR0047)
               
         End Case
      //***

      //***
      //Geração de arquivo de cancelamento (Serviços de Booking e Shipment Instructions)
      Case cCargo == "OPCNL"
         If !(SubStr(cSrvCargo, 0, 2) == "BK" .Or. SubStr(cSrvCargo, 0, 2) == "SI")
            MsgInfo(STR0025, STR0017)//"Opção inválida para o serviço selecionado."###"Atenção"
            Break
         EndIf
         
         If "2.0" $ EasyGParam("MV_AVG0217",,"1.0") .And. SubStr(cSrvCargo, 0, 2) == "BK"
            cOpcao := "Cancel"
         Else 
            cOpcao := "Cancellation"
         EndIf      

         Do Case
            Case cSrvCargo == "BKINE"
               If WKEYM3->(!Eof())
                  EYM->(DbGoTo(WKEYM3->WK_RECNO))
                  cProcesso := WKEYM3->EYM_PROC
                  EYM->(RecLock("EYM", .F.))
                  If File(DIR_OUTBOUND + EYM->EYM_FILE)
                     FErase(DIR_OUTBOUND + EYM->EYM_FILE)
                  EndIf
                  EYM->(DbDelete())
                  EYM->(MsUnlock())
                  aRefresh := {"BKINE"}
               EndIf
               
            Case cSrvCargo == "BKIPC"
               cNomFile := NewFileName(,,SubStr(cSrvCargo, 0, 2))
               cProcesso := WKEYM4->EYM_PROC
               cId := cProcesso
               If !ValidaEnvio(SubStr(cSrvCargo, 0, 2), cProcesso)
                  Break
               EndIf
               cInttraRef := AllTrim(WKEYM4->EYM_BKINTT)
               cBooking := AllTrim(WKEYM4->EYM_BOOK)
               Frm104SolInt("300", "BK", cProcesso, EXCLUIR)
               aRefresh := {"BKIEN", "BKINE"}
               
            Case cSrvCargo == "SIINE"
               If WKEYN3->(!Eof())            
                  cProcesso := WKEYN3->EYN_PROC
                  EYN->(DbGoTo(WKEYN3->WK_RECNO))
                  EYN->(RecLock("EYN", .F.))
                  If File(DIR_OUTBOUND + EYN->EYN_FILE)
                     FErase(DIR_OUTBOUND + EYN->EYN_FILE)
                  EndIf
                  cSeqSI := Right(AllTrim(WKEYN3->EYN_ID_SI), 3)
                  EX9->(DbSetOrder(1))
                  EX9->(DbSeek(xFilial()+AvKey(cProcesso, "EX9_PREEMB")))
                  While EX9->(!Eof() .And. EX9_FILIAL+EX9_PREEMB == xFilial()+AvKey(cProcesso, "EX9_PREEMB"))
                     If EX9->EX9_SEQSI == cSeqSI
                        EX9->(RecLock("EX9", .F.))
                        EX9->EX9_SEQSI := ""
                        EX9->(MsUnlock())
                     EndIf
                     EX9->(DbSkip())
                  EndDo
                  EYN->(DbDelete())
                  EYN->(MsUnlock())
                  aRefresh := {"SIINE"}                  
               EndIf
               
            Case cSrvCargo == "SIIEN"
               cNomFile := NewFileName(,,SubStr(cSrvCargo, 0, 2))
               cProcesso := WKEYN2->EYN_PROC
               cId := WKEYN2->EYN_ID_SI
               cSeqSI := Right(AllTrim(WKEYN2->EYN_ID_SI), 3)
               Frm104SolInt("302", "SI", cProcesso, EXCLUIR)
               aRefresh := {"BKIEN", "BKINE"}
               
         End Case
      //***

      //*** JVR
      //Visualização dos arquivos XML (Serviços de Booking e Shipment Instructions)
      Case cCargo == "OPVIS"
         If !(SubStr(cSrvCargo, 0, 2) == "BK" .Or. SubStr(cSrvCargo, 0, 2) == "SI")
            MsgInfo(STR0025, STR0017)//"Opção inválida para o serviço selecionado."###"Atenção"
            Break
         EndIf 
         cOpcao := "Preview"
         Do Case
            Case SubStr(cSrvCargo, 0, 2) == "BK"
               Do Case
                  Case cSrvCargo == "BKIRC"
                     cAlias := "WKEYM1"
                  Case cSrvCargo == "BKIEN"
                     cAlias := "WKEYM2"
                  Case cSrvCargo == "BKINE"
                     cAlias := "WKEYM3"
                  Case cSrvCargo == "BKIPC"
                     cAlias := "WKEYM4"
               EndCase
               If !Empty(cAlias)
                  AVVisXML("301", (cAlias)->EYM_FILE, (cAlias)->EYM_STATUS)
               EndIf
            Case SubStr(cSrvCargo, 0, 2) == "SI"
               AVVisXML("303", WKEYN3->EYN_FILE, WKEYN3->EYN_STATUS)
         End Case
         aRefresh := cSrvCargo
      //***
      
      //***
      //Busca de arquivos do Serviço de Track&Trace
      Case cCargo == "OPSRC"
         If (cSrvCargo == "TTIRC") .Or. (cSrvCargo == "TTIPC")
            oBrowse := ::aControls[aScan(::aControls, {|o| o:IsType("AVIMONBRW") .And. o:GetCargo() == cSrvCargo })]
            aFilter := TTGetProc(oBrowse:cChave, Self:cProcess)
            If Len(aFilter) > 0
               MsAguarde({|| lFound := TTSearch(aFilter, "WKEYO3", oBrowse:cChave) }, STR0026)//"Buscando processos"
               If lFound .And. ::oSrvTree:oTree:TreeSeek("TTSRC")
                  Eval(::oSrvTree:oTree:bChange)
               EndIf
            Else
               lRefresh := .F.
            EndIf
         Else
            MsgInfo(STR0027, STR0017)//"Selecione uma pasta válida para pesquisar."###"Atenção"
            lRefresh := .F.
         EndIf
         aRefresh := {cSrvCargo}
      
      //Impressão de relatório
      Case cCargo == "OPIMP"

         If !Empty(Self:cProcess)
            pergunte('FRM10401',.F.,,,,, @aFRM10401)
            MV_PAR01 := Self:cProcess
            MV_PAR02 := Self:cProcess
            __SaveParam("FRM10401", @aFRM10401)
         EndIf
         
         If (Left(cSrvCargo, 2) == "BK")
            LoadReport("\comex\easylink\inttra\resources\booking.xrp")
         elseif (Left(cSrvCargo, 2) == "SI")
            LoadReport("\comex\easylink\inttra\resources\shippinginstructions.xrp")
         elseif (cSrvCargo == "TTIPC") .Or. (cSrvCargo == "TTSRC")
            LoadReport("\comex\easylink\inttra\resources\tracktrace.xrp")
         EndIf

      //Envio e Recebimento de arquivos no servidor de FTP
      Case cCargo == "OPATU"
         cProcesso := Frm103GetEmb(Self)
         AvStAction("306")
      //***

   EndCase
   
   //Atualização dos Browses (Todos ou Somente o selecionado)
   If lInterface .And. lRefresh .And. cCargo <> "OPVIS"
      If cCargo $ "OPATU/OPPTP/OPPTS"
         ::Refresh()
      Else
         aEval(aRefresh, {|x| ::Refresh(x) })
      EndIf
      If Type("aProcessos") == "A" .And. Len(aProcessos) > 0
         aEval(aProcessos, {|x| Frm101SetStatus(x) })
      Else
         If !Empty(cProcesso)
            Frm101SetStatus(cProcesso)
         EndIf
      EndIf
   EndIf

End Sequence

Return Nil

Static Function ValidaEnvio(cSrv, cProcesso)
Local lRet := .T.
Local aOrd := SaveOrd({"EYM", "EYN", "EX9"})

Begin Sequence

   Do Case
      Case cSrv == "BK"
         cStatus := Frm101StBK(cProcesso)
         If cStatus $ (ST_BK_GER + ST_BK_CNL3)
            MsgInfo(STR0055, STR0047)
            lRet := .f.
         EndIf
         If cStatus $ ST_BK_ENV
            If !MsgYesNo(STR0056, STR0047)
               lRet := .f.
            EndIf
         EndIf
         
      Case cSrv == "SI"
         EYN->(DbSetOrder(3))
         If EYN->(DbSeek(xFilial()+AvKey(cProcesso, "EYN_PROC")+ITNAOENVIADOS))
            lRet := .F.
            //Verifica se ainda existem containers disponíveis para envio
            EX9->(DbSetOrder(1))
            EX9->(DbSeek(xFilial()+AvKey(cProcesso, "EX9_PREEMB")))
            While EX9->(!Eof() .And. EX9_FILIAL+EX9_PREEMB == xFilial()+AvKey(cProcesso, "EX9_PREEMB"))
               If Empty(EX9->EX9_SEQSI)
                  lRet := .T.
                  Break
               EndIf
               EX9->(DbSkip())
            EndDo
         EndIf
         If !lRet
            MsgInfo(STR0057, STR0047)
         EndIf

   EndCase
   
End Sequence

RestOrd(aOrd, .T.)
Return lRet

Static Function GetSeqSi(cPreemb)
Local nSeq := 0
Local aOrd := SaveOrd("EX9")

   EX9->(DbSetOrder(1))
   EX9->(DbSeek(xFilial()+cPreemb))
   While EX9->(!Eof() .And. EX9_FILIAL+EX9_PREEMB == xFilial()+cPreemb)
      If !Empty(EX9->EX9_SEQSI) .And. Val(EX9->EX9_SEQSI) > nSeq
         nSeq := Val(EX9->EX9_SEQSI)
      EndIf
      EX9->(DbSkip())
   EndDo

RestOrd(aOrd, .T.)
Return StrZero(nSeq + 1, AvSx3("EX9_SEQSI", AV_TAMANHO))

Method PrcTodos(cAlias, cSrvCargo, lEnd, oProcess) Class AvIMonitor
Local nInc := 0, nLast := (cAlias)->(EasyRecCount(cAlias))
Private lProcTodos := .T., cRetorno := ""
Private cNomFile
ProcRegua(nLast)

   (cAlias)->(DbGoTop())
   oProcess:SetRegua1(nLast)
   While (cAlias)->(!Eof())
      ++nInc
      oProcess:IncRegua1(StrTran(StrTran(STR0028, "XXX", AllTrim(Str(nInc))), "YYY", AllTrim(Str(nLast))))//"Processando arquivo 'XXX' de 'YYY'."
      ::ChangeOpc("OPPRC", .F., oProcess, cSrvCargo)
      (cAlias)->(DbSkip())
      If lEnd
         Exit
      EndIf
   EndDo

Return cRetorno

Static Function TTGetProc(cStatus, cProcesso)
Local aRet := {}
Local oDlg
Local nLin := 15, nInc
Local lOk := .F.
Local bOk := {|| lOk := .T., oDlg:End() }, bCancel := {|| oDlg:End() }
Local aCampos := {"cProc", "cCont", "dDtRecI", "dDtRecF", "dDtProcI", "dDtProcF"}
Local lProc := .T.
Private cProc := Space(AvSx3("EYO_PROC", AV_TAMANHO))
Private cCont := Space(AvSx3("EYO_CONTNR", AV_TAMANHO))
Private dDtRecI  := CToD("  /  /  ")
Private dDtRecF  := CToD("  /  /  ")
Private dDtProcI := CToD("  /  /  ")
Private dDtProcF := CToD("  /  /  ")

   If ValType(cProcesso) == "C" .And. !Empty(cProcesso)
       cProc := cProcesso
       lProc := .F.
   EndIf

   DEFINE MSDIALOG oDlg TITLE STR0029 FROM 0, 0 TO If(cStatus == ITPROCESSADOS, /*240*/280, /*81*/121), 350 OF oMainWnd PIXEL//"Critérios de Pesquisa"

      If cStatus == ITPROCESSADOS
         @ nLin, 02 To nLin+25, 173 Label STR0030 OF oDlg PIXEL//"Processo"
         @ nLin+11, 10 SAY STR0031 OF oDlg PIXEL//"Código"
         @ nLin+10, 35 MSGET cProc F3 "EEC" SIZE 50, 08 When lProc PIXEL OF oDlg
         nLin += 26
         @ nLin, 02 To nLin+25, 173 Label "Container" OF oDlg PIXEL
         @ nLin+11, 10 SAY STR0031 OF oDlg PIXEL//"Código"
         @ nLin+10, 35 MSGET cCont F3 "EX9INT" SIZE 70, 08 PIXEL OF oDlg
         nLin += 26
      EndIf

      @ nLin, 02 To nLin+25, 173 Label STR0032 OF oDlg PIXEL//"Data de Recebimento"
      @ nLin+11, 10 SAY STR0033 OF oDlg PIXEL//"Data Ini."
      @ nLin+10, 35 MSGET dDtRecI PICTURE "@D" SIZE 50, 08 PIXEL OF oDlg
      @ nLin+11, 90 SAY STR0034 OF oDlg PIXEL//"Data Fin."
      @ nLin+10, 115 MSGET dDtRecF PICTURE "@D" SIZE 50, 08 PIXEL OF oDlg
      nLin += 26

      If cStatus == ITPROCESSADOS
         @ nLin, 02 To nLin+25, 173 Label STR0035 OF oDlg PIXEL//"Data do Rastreamento"
         @ nLin+11, 10 SAY STR0033 OF oDlg PIXEL//"Data Ini."
         @ nLin+10, 35 MSGET dDtProcI PICTURE "@D" SIZE 50, 08 PIXEL OF oDlg
         @ nLin+11, 90 SAY STR0034 OF oDlg PIXEL//"Data Fin."
         @ nLin+10, 115 MSGET dDtProcF PICTURE "@D" SIZE 50, 08 PIXEL OF oDlg
         nLin += 26
      EndIf

   ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg, bOk, bCancel)
   
   If lOk
      For nInc := 1 To Len(aCampos)
         If !Empty(&(aCampos[nInc]))
            aAdd(aRet, {aCampos[nInc], &(aCampos[nInc])})
         EndIf
      Next
   EndIf

Return aRet

Static Function TTSearch(aFilter, cWork, cStatus)
Local cProc := ""
Local aOrd := SaveOrd("EYO")
Local nInc, nPos
   
   //Query Pesquisa Track Trace.                     
   cQuery := "SELECT * from "+RetSqlName("EYO") + " EYO WHERE "
   cQuery += "EYO.D_E_L_E_T_ <> '*' And EYO.EYO_FILIAL = '" + xFilial("EYO") + "' "
   cquery += "AND EYO.EYO_STATUS = '" + cStatus + "' "

   //Processo
   If (nPos := aScan(aFilter, {|x| x[1] == "cProc" })) > 0
      cQuery += "AND EYO.EYO_PROC = '" + aFilter[nPos][2] + "' "
   EndIf
   //Container
   If (nPos := aScan(aFilter, {|x| x[1] == "cCont" })) > 0
      cQuery += "AND EYO.EYO_CONTNR = '" + aFilter[nPos][2] + "' "
   EndIf
   //Data Recebimento Inicial
   If (nPos := aScan(aFilter, {|x| x[1] == "dDtRecI" })) > 0
      cQuery += "AND EYO.EYO_DTREC >= '" + DtoS(aFilter[nPos][2]) + "' "
   EndIf
   //Data Recebimento Final
   If (nPos := aScan(aFilter, {|x| x[1] == "dDtRecF" })) > 0
      cQuery += "AND EYO.EYO_DTREC <= '" + DtoS(aFilter[nPos][2]) + "' "
   EndIf                   
   //Data Precessamento Inicial
   If (nPos := aScan(aFilter, {|x| x[1] == "dDtProcI" })) > 0
      cQuery += "AND EYO.EYO_DATATT >= '" + DtoS(aFilter[nPos][2]) + "' "
   EndIf      
   //Data Precessamento Final
   If (nPos := aScan(aFilter, {|x| x[1] == "dDtProcF" })) > 0
      cQuery += "AND EYO.EYO_DATATT <= '" + DtoS(aFilter[nPos][2]) + "' "
   EndIf

   cQuery := ChangeQuery(cQuery) 
   TcQuery cQuery ALIAS "QRY" NEW  

   If IsVazio("QRY")
      MsgInfo(STR0058, STR0047)
      QRY->(DBCloseArea())
      Return .F.
   EndIf
   //acerto de campos do tipo data
   For nInc := 1 To EYO->(FCount())
      If AVSX3(EYO->(FieldName(nInc)), AV_TIPO) == "D"
         TcSetField("QRY", EYO->(FieldName(nInc)), "D", 8, 0)
      EndIf
   Next
   
   (cWork)->(avzap())
   While QRY->(!Eof())
      (cWork)->(DbAppend())
      For nInc := 1 To EYO->(FCount())
         (cWork)->&(EYO->(FieldName(nInc))) := QRY->&(QRY->(FieldName(nInc)))
      Next
      QRY->(DbSkip())
   EndDo                 
   QRY->(DBCloseArea())
   (cWork)->(DbGoTop())

RestOrd(aOrd, .T.)
Return .T.

/*
Método      : Show()
Classe      : AvIMonitor
Parâmetros  : Nenhum
Retorno     : Nenhum
Objetivos   : Exibe a interface gráfica do IMonitor
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     : 
Obs.        : 
*/
Method Show() Class AvIMonitor
Local oDlg := ::oDlg

   ACTIVATE MSDIALOG oDlg ON INIT {||}

Return Nil

/*
Método      : EndObj()
Classe      : AvIMonitor
Parâmetros  : Nenhum
Retorno     : Nenhum
Objetivos   : Finaliza o objeto, removendo os arquivos temporários
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     : 
Obs.        : 
*/
Method EndObj() Class AvIMonitor
Local nInc

   For nInc := 1 To Len(::aControls)
      If ::aControls[nInc]:IsType("AVIMONBRW")
         ::aControls[nInc]:EndObj()
      EndIf
   Next

Return .T.
//*****************************************************************
Class AvIMonBrw

Data cCargo
Data cAlias
Data cAliasBase
Data nOrderBase
Data aSemSx3
Data cFileName
Data aCamposBrw
Data aArrayBrowse
Data oMsSelect
Data oFooter
Data nFooter
Data lFooter
Data aFooter
Data aFtControls
Data oObjPai
Data aPos
Data cId
Data aMemo
Data nTotRec
Data cChave

Method GetType()
Method IsType(cType)
Method New(cCargo, cId) Constructor
Method Show()
Method Hide()
Method Refresh()
Method DefWork(cAlias, cAliasBase, aSemSx3, cChave, nOrderBase, aMemo)
Method DefBrowse(aCamposBrw)
Method SetBrowse(oObjPai, aPos)
Method GetData()
Method GetCargo()
Method GetId()
Method GetService()
Method GetTotItens()
Method EndObj()
Method GetTempFile()
Method SetFooter(lFooter, aFooter)

End Class

Method GetType() Class AvIMonBrw
Return "AVIMONBRW"

Method IsType(cType) Class AvIMonBrw
Local lRet

   If ValType(cType) == "C"
      lRet := ::GetType() == Upper(cType)
   EndIf

Return lRet

Method New(cCargo, cId) Class AvIMonBrw

   ::cCargo      := cCargo
   ::cId         := cId
   ::lFooter     := .F.
   ::nFooter     := 60
   ::aFtControls := {}
   ::aMemo       := {}

Return Self

Method Show() Class AvIMonBrw

   ::oMsSelect:oBrowse:Show()
   If ::lFooter
      ::oFooter:Show()
   EndIf

Return Nil

Method Hide() Class AvIMonBrw

   ::oMsSelect:oBrowse:Hide()
   If ::lFooter
      ::oFooter:Hide()
   EndIf

Return Nil

Method Refresh(cObj) Class AvIMonBrw
Local nInc

   If ValType(::oMsSelect) == "O" .And. (ValType(cObj) <> "C" .Or. Upper(cObj) == "MSSELECT")
      ::oMsSelect:oBrowse:Refresh()
   EndIf
   If ValType(::oFooter) == "O" .And. (ValType(cObj) <> "C" .Or. Upper(cObj) == "FOOTER")
      For nInc := 1 To Len(::aFtControls)
         ::aFtControls[nInc]:Refresh()
      Next
   EndIf
Return Nil

Method DefWork(cAlias, cAliasBase, aSemSx3, cChave, nOrderBase, aMemo) Class AvIMonBrw
Default aSemSx3 := {}

   ::cAlias     := cAlias
   ::cAliasBase := cAliasBase
   ::aSemSx3    := aSemSx3
   ::cChave     := cChave
   ::nOrderBase := nOrderBase
   If ValType(aMemo) == "A"
      ::aMemo      := aMemo
   EndIf

Return Nil

Method DefBrowse(aCamposBrw) Class AvIMonBrw

   ::aCamposBrw   := aCamposBrw

Return Nil

Method SetBrowse(oObjPai, aPos) Class AvIMonBrw
Local lRet := .T.
Local nInc
Local cPic

Private lInverte := .F.
Private cMarca   := "  "
Private aCampos := {}, aHeader := {}

   ::oObjPai   := oObjPai
   If !::lFooter
      ::aPos := aPos
   Else
      ::aPos := {aPos[1], aPos[2], aPos[3] - (::nFooter + 1), aPos[4]}
   EndIf
   
   If Len(::aCamposBrw) > 0
      For nInc := 1 To Len(::aCamposBrw)
         If GetSx3Cache(::aCamposBrw[nInc], "X3_CONTEXT") == "V"
            aAdd(aCampos, {&("{|| " + ::cAlias + "->" + ::aCamposBrw[nInc] + " }"), "", GetSx3Cache(::aCamposBrw[nInc], "X3_TITULO") } )
         Else
            aAdd(aCampos, ColBrw(::aCamposBrw[nInc], ::cAlias))
         EndIf
      Next
   Else
      aCampos := ArrayBrowse(::cAlias, ::cAliasBase)
   EndIf
   ::oMsSelect := MsSelect():New(::cAlias,,, aCampos, @lInverte, @cMarca, ::aPos,,, ::oObjPai)
   If ::cAliasBase == "EYO"
      ::oMsSelect:oBrowse:bChange := &("{|| Self:Refresh('FOOTER') }")
   EndIf
   //::oMsSelect:oFont := TFont():New("ARIAL",,25,, .T.)
  
   If ::lFooter
      ::oFooter := TScrollBox():New(::oObjPai, ::aPos[3] + 1, ::aPos[2], ::nFooter, ::aPos[4] - ::aPos[2],.T.,.F.,.T. )
      
      nLin1 := 04
      nLin2 := 04
      
      nCol1a := 10
      nCol1b := 50

      nCol2a := 180
      nCol2b := 220
      
      nLin := 0
      
      For nInc := 1 To Len(::aFooter)
         If Mod(nInc, 2) <> 0 .And. nLin1 <= nLin2
            nColSay := nCol1a
            nColGet := nCol1b
            nLin := "nLin1"
         Else
            nColSay := nCol2a
            nColGet := nCol2b
            nLin := "nLin2"
         EndIf
         aAdd(::aFtControls, TSay():New(&nLin, nColSay, &("{|| '" + GetSx3Cache(::aFooter[nInc], "X3_TITULO") + "'}"), ::oFooter,,,.F., .F., .F., .T.,,, 35, 08))
         If GetSx3Cache(::aFooter[nInc], "X3_TIPO") <> "M"
            cPic := GetSx3Cache(::aFooter[nInc], "X3_PICTURE")
            aAdd(::aFtControls, TGet():New(&nLin - 1, nColGet, &("{|| " + ::cAlias + "->" + ::aFooter[nInc] + " }"), ::oFooter, 120, 08, If(!Empty(cPic), cPic,),,,,,,,.T.,,,, .F., .F.,, .F., .F.,, ::cAlias + "->" + ::aFooter[nInc]))
            &nLin += 14
         Else
            aAdd(::aFtControls, TMultiGet():New(&nLin - 1, nColGet, &("{|| " + ::cAlias + "->" + ::aFooter[nInc] + " }"), ::oFooter, 120, 35,,.T.,,,,.T.,,,,,,,,,,,))
            &nLin += 42
         EndIf
      Next
      
   EndIf

Return ::oMsSelect

Method GetData(cProcess) Class AvIMonBrw
Local nInc, cQry
Default cProcess := ""

   //Verifica se o arquivo de trabalho já foi criado
   If Select(::cAlias) == 0
      //Cria o arquivo de trabalho
      ::cFileName := ::GetTempFile()
   EndIf

   If !IsVazio(::cAlias)
      (::cAlias)->(avzap())
   EndIf

   #IFDEF TOP
      cQry := "Select * From " + RetSqlName(::cAliasBase) +;
              " Where " + (::cAliasBase + "_STATUS") + " = " + "'" + ::cChave + "'"
      If !Empty(cProcess) .And. ::cChave <> ITRECEBIDOS
         cQry += " AND " + (::cAliasBase+"_PROC") + " = '" + cProcess + "'"
      EndIf
      cQry += " AND " + (::cAliasBase + "_FILIAL") + " = '" + xFilial(::cAliasBase) + "' AND D_E_L_E_T_ <> '*'"

      cQry := ChangeQuery(cQry)
      TcQuery cQry ALIAS "QRY" NEW
      
      For nInc := 1 To (::cAliasBase)->(FCount())
         If AVSX3((::cAliasBase)->(FieldName(nInc)), AV_TIPO) == "D"
            TcSetField("QRY", (::cAliasBase)->(FieldName(nInc)), "D", 8, 0)
         EndIf
      Next   

      While QRY->(!Eof())
         (::cAlias)->(DbAppend())
         For nInc := 1 To (::cAliasBase)->(FCount())
            (::cAlias)->&((::cAliasBase)->(FieldName(nInc))) := QRY->&((::cAliasBase)->(FieldName(nInc)))
         Next
         For nInc := 1 To Len(::aMemo)
            (::cAlias)->&((::cAliasBase)->(::aMemo[nInc])) := CriaVar(::aMemo[nInc])
         Next
         (::cAlias)->WK_RECNO := QRY->R_E_C_N_O_
         QRY->(DbSkip())
      EndDo
      QRY->(DbCloseArea())
      (::cAlias)->(DbGoTop())
   #ELSE
      (::cAliasBase)->(DbSetOrder(::nOrderBase))
      (::cAliasBase)->(DbSeek(xFilial()+::cChave))

      While (::cAliasBase)->(!Eof() .And. &(::cAliasBase + "_STATUS") == ::cChave)
         If (::cChave <> ITRECEBIDOS) .And. !Empty(cProcess) .And. ((::cAliasBase)->&(::cAliasBase+"_PROC") <> cProcess)
            (::cAliasBase)->(DbSkip())
            Loop
         EndIf
         (::cAlias)->(DbAppend())
         For nInc := 1 To (::cAliasBase)->(FCount())
            (::cAlias)->&((::cAliasBase)->(FieldName(nInc))) := (::cAliasBase)->&((::cAliasBase)->(FieldName(nInc)))
         Next
         For nInc := 1 To Len(::aMemo)
            (::cAlias)->&((::cAliasBase)->(::aMemo[nInc])) := CriaVar(::aMemo[nInc])
         Next
         (::cAlias)->WK_RECNO := (::cAliasBase)->(Recno())
         (::cAliasBase)->(DbSkip())
      EndDo
      (::cAlias)->(DbGoTop())
   #ENDIF

Return .T.

Method SetFooter(lFooter, aFooter) Class AvIMonBrw

   If ValType(lFooter) == "L"
      ::lFooter := lFooter
   EndIf
   If ValType(aFooter) == "A"
      ::aFooter := aFooter
   EndIf

Return .T.

Method GetCargo() Class AvIMonBrw
Return ::cCargo

Method GetId() Class AvIMonBrw
Return ::cId

Method GetService() Class AvIMonBrw
Return Left(::GetCargo(), 2)

Method GetTotItens() Class AvIMonBrw
Return (::cAlias)->(EasyRecCount(::cAlias))

Method EndObj() Class AvIMonBrw
   
   If Select(::cAlias) > 0
      (::cAlias)->(E_EraseArq(::cFileName))
   EndIf

Return Nil

/*
Método      : GetTempFile
Classe      : 
Parâmetros  : 
Retorno     : 
Objetivos   : Criar novo arquivo de trabalho
Autor       : Rodrigo Mendes Diaz
Data/Hora   : 10/08/2007
Revisao     :
Obs.        :
*/
Method GetTempFile() Class AvIMonBrw
Local aSemSx3 := aClone(::aSemSx3)
Private aHeader := {}, aCampos := Array((::cAliasBase)->(FCount()))

   If Select(::cAlias) == 0
      AddNaoUsado(aSemSx3, ::cAliasBase + "_STATUS")
      aAdd(aSemSx3, {"WK_RECNO", "N", 7, 0})
      ::cFileName := E_CriaTrab(::cAliasBase, aSemSx3, ::cAlias)
   EndIf

Return ::cFileName

Static Function NewFileName(nSeq, lConfirm, cSrv)
Local cName := "avg_"
Default nSeq  := EasyGParam("MV_AVG0143",, 0)
Default lConfirm := .T.

   Do Case
      Case cSrv == "BK"
         cName += "iftmbf_"
      Case cSrv == "SI"
         cName += "iftmin_"
   EndCase

   If lConfirm
      If nSeq > 9999
         nSeq := 0
      EndIf
      ++nSeq
      cName += StrZero(nSeq, 4)
      SetMv("MV_AVG0143", nSeq)
   Else
      If EasyGParam("MV_AVG0143",, 0) == nSeq
      
      EndIf
   EndIf
   
Return cName

Function Frm101DscSta(cStatus)
Local cRetorno := STR0059
Default cStatus := EXL->EXL_STATUS

   Do Case
      Case cStatus == ST_SEM_INT
         cRetorno := STR0059

      Case cStatus == ST_BK_GER
         cRetorno := STR0060

      Case cStatus == ST_BK_ENV
         cRetorno := STR0061
      
      Case cStatus == ST_BK_REC
         cRetorno := STR0062
      
      Case cStatus == ST_BK_PROC
         cRetorno := STR0063
      
      Case cStatus == ST_BK_CNL1
         cRetorno := STR0064

      Case cStatus == ST_BK_CNL2
         cRetorno := STR0065

      Case cStatus == ST_BK_CNL3
         cRetorno := STR0066

      Case cStatus == ST_SI_GER
         cRetorno := STR0067

      Case cStatus == ST_SI_ENV
         cRetorno := STR0068
      
      Case cStatus == ST_SI_REC
         cRetorno := STR0069
      
      Case cStatus == ST_SI_PROC
         cRetorno := STR0070
      
      Case cStatus == ST_BL_REC
         cRetorno := STR0071

      Case cStatus == ST_TT_REC
         cRetorno := STR0072

   EndCase

Return cRetorno

Function Frm101SetStatus(cProcesso)
Local cStatus := ""

Begin Sequence

   //Verifica primeiro se existe rastreamento do Container
   If Empty(cStatus := Frm101StTT(cProcesso))
      //Caso não existir verifica se tem B/L recebido
      If Empty(cStatus := Frm101StBL(cProcesso))
         //Se não tiver verifica o envio de SI
         If Empty(cStatus := Frm101StSI(cProcesso))
            //Por último verifica o status da comunicação de Booking
            If Empty(cStatus := Frm101StBK(cProcesso))
               //Caso não tenha nenhuma movimentação dos serviços, usa o status default (Processo não Enviado)
               cStatus := "0"
            EndIf
         EndIf
      EndIf
   EndIf
   
   If EXL->(DbSeek(xFilial()+cProcesso))
      EXL->(RecLock("EXL", .F.))
      EXL->EXL_STATUS := cStatus
      EXL->(MsUnlock())
   EndIf

End Sequence

Return cStatus

/*
Função		: Frm101StTT(cProcesso)
Objetivo	: Busca o status do recebimento de Track & Trace para determinado processo
Parâmetros	: cProcesso	-> Código do processo de embarque
Retorno		: cStatus 	-> Código do status do recebimento de Track & Trace (branco se não existir registro)
Autor		: Rodrigo Mendes Diaz
Data		: 17/12/09
Alteração   : NCF - 03/04/2013 - Verificar o status pelo último arquivo recebido.
*/
Function Frm101StTT(cProcesso)
Local aOrd := SaveOrd("EYO")
Local cStatus := ""

Begin Sequence

   If !(ChkFile("EYO") .And. Select("EYO") > 0 .And. SIX->(DbSeek("EYO6")))  // GFP - 11/11/2014
      Break
   EndIf

   EYO->(DbSetOrder(6))
   If EYO->(AvSeekLast(xFilial()+cProcesso))
      cStatus := ST_TT_REC
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return cStatus

/*
Função		: Frm101StBL(cProcesso)
Objetivo	: Busca o status do recebimento de BL para determinado processo
Parâmetros	: cProcesso	-> Código do processo de embarque
Retorno		: cStatus 	-> Código do status do recebimento de BL (branco se não existir registro)
Autor		: Rodrigo Mendes Diaz
Data		: 17/12/09
*/
Function Frm101StBL(cProcesso)
Local aOrd := SaveOrd("EYP")
Local cStatus := ""

Begin Sequence

   If !(ChkFile("EYP") .And. Select("EYP") > 0 .And. SIX->(DbSeek("EYP3")))  // GFP - 11/11/2014
      Break
   EndIf
   EYP->(DbSetOrder(3))
   If EYP->(DbSeek(xFilial()+cProcesso))
      cStatus := ST_BL_REC
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return cStatus

/*
Função		: Frm101StSI(cProcesso)
Objetivo	: Busca o status do envio de SI para determinado processo
Parâmetros	: cProcesso	-> Código do processo de embarque
Retorno		: cStatus 	-> Código do status do envio de SI (branco se não existir registro)
Autor		: Rodrigo Mendes Diaz
Data		: 17/12/09
*/
Function Frm101StSI(cProcesso)
Local aOrd := SaveOrd("EYN")
Local cStatus := ""

Begin Sequence

   If !(ChkFile("EYN") .And. Select("EYN") > 0 .And. SIX->(DbSeek("EYN3")))  // GFP - 11/11/2014
      Break
   EndIf
   EYN->(DbSetOrder(3))
   If EYN->(DbSeek(xFilial()+cProcesso+ITPROCESSADOS))
      cStatus	:= ST_SI_PROC
      Break
   EndIf
   If EYN->(DbSeek(xFilial()+cProcesso+ITRECEBIDOS))
      cStatus	:= ST_SI_REC
      Break
   EndIf
   If EYN->(DbSeek(xFilial()+cProcesso+ITENVIADOS))
      cStatus	:= ST_SI_ENV
      Break
   EndIf
   If EYN->(DbSeek(xFilial()+cProcesso+ITNAOENVIADOS))
      cStatus	:= ST_SI_GER
      Break
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return cStatus

/*
Função		: Frm101StBK(cProcesso)
Objetivo	: Busca o status da solicitação de Booking para determinado processo
Parâmetros	: cProcesso	-> Código do processo de embarque
Retorno		: cStatus 	-> Código do status da solicitação de Booking (branco se não existir registro)
Autor		: Rodrigo Mendes Diaz
Data		: 17/12/09
*/
Function Frm101StBK(cProcesso)
Local aOrd := SaveOrd("EYO")
Local cStatus := "", cDataHora := ""
Local cDtProc := ""
Local cDtRec  := ""
Local cDtEnv  := ""
Local cDtGer  := ""
Local cSitEnv := "", cSitProc := "", cSitGer := ""

Begin Sequence

   If !(ChkFile("EYM") .And. Select("EYM") > 0 .And. SIX->(DbSeek("EYM3")))  // GFP - 11/11/2014
      Break
   EndIf
   EYM->(DbSetOrder(3))
   If EYM->(DbSeek(xFilial()+cProcesso+ITPROCESSADOS))
      //cStatus	:= ST_BK_PROC
      //Break
      While EYM->(!Eof() .And. EYM_FILIAL+EYM_PROC+EYM_STATUS == xFilial()+cProcesso+ITPROCESSADOS)
         cDataHora := Alltrim(DToS(EYM->EYM_DATABK) + StrTran(EYM->EYM_HORABK, ":", ""))
         If cDataHora > cDtProc
            cDtProc := cDataHora
            If "REJECTED" $ Upper(EYM->EYM_ST_MES)
               cSitProc := ST_BK_CNL1//Cancelado pelo Inttra
            Else
               cSitProc := ""
            EndIf
         EndIf
         EYM->(DbSkip())
      EndDo
   EndIf
   If EYM->(DbSeek(xFilial()+cProcesso+ITRECEBIDOS))
      //cStatus	:= ST_BK_REC
      //Break
      While EYM->(!Eof() .And. EYM_FILIAL+EYM_PROC+EYM_STATUS == xFilial()+cProcesso+ITRECEBIDOS)
         cDataHora := Alltrim(DToS(EYM->EYM_DTREC) + StrTran(EYM->EYM_HRREC, ":", ""))
         If cDataHora > cDtRec
            cDtRec := cDataHora
         EndIf
         EYM->(DbSkip())
      EndDo
   EndIf
   If EYM->(DbSeek(xFilial()+cProcesso+ITENVIADOS))
      //cStatus	:= ST_BK_ENV
      //Break
      While EYM->(!Eof() .And. EYM_FILIAL+EYM_PROC+EYM_STATUS == xFilial()+cProcesso+ITENVIADOS)
         cDataHora := Alltrim(DToS(EYM->EYM_DATA) + StrTran(EYM->EYM_HORA, ":", ""))
         If cDataHora > cDtEnv
            cDtEnv := cDataHora
            If (IF("2.0" $ EasyGParam("MV_AVG0217",,"1.0"),"CANCEL","CANCELLATION")) $ Upper(EYM->EYM_ST_MES)        //NCF - 10/05/2013 - Para setar os Status de Booking Cancelado na versão 2.0
               cSitEnv := ST_BK_CNL2//Cancelamento enviado
            Else
               cSitEnv := ""
            EndIf
         EndIf
         EYM->(DbSkip())
      EndDo
   EndIf
   If EYM->(DbSeek(xFilial()+cProcesso+ITNAOENVIADOS))
      //cStatus	:= ST_BK_GER
      //Break
      While EYM->(!Eof() .And. EYM_FILIAL+EYM_PROC+EYM_STATUS == xFilial()+cProcesso+ITNAOENVIADOS)
         cDataHora := Alltrim(DToS(EYM->EYM_DATA) + StrTran(EYM->EYM_HORA, ":", ""))
         If cDataHora > cDtGer
            cDtGer := cDataHora
            If (IF("2.0" $ EasyGParam("MV_AVG0217",,"1.0"),"CANCEL","CANCELLATION")) $ Upper(EYM->EYM_ST_MES)       //NCF - 10/05/2013 - Para setar os Status de Booking Cancelado na versão 2.0
               cSitGer := ST_BK_CNL3//Cancelamento gerado 	
            Else
               cSitGer := ""
            EndIf
         EndIf
         EYM->(DbSkip())
      EndDo
   EndIf
   
   /* Se existir algum registro processado, e não existir nenhum outro registro (outras datas em branco) 
      ou se a data deste processamento for superior a data das outras operações, então o ultimo status é 
      este processamento
   */
   If !Empty(cDtProc) .And. ((Empty(cDtRec) .And. Empty(cDtEnv) .And. Empty(cDtGer)) .Or. ((cDtProc > cDtRec) .And. (cDtProc > cDtEnv) .And. (cDtProc > cDtGer)))
      cStatus	:= ST_BK_PROC
      If !Empty(cSitProc)
         cStatus := cSitProc
      EndIf
      Break
   EndIf
   
   /* Se existir registro recebido, e não existir nenhum outro registro (outras datas em branco) 
      ou se a data deste recebimento for superior a data das outras operações, então o ultimo status é 
      este recebimento.
   */
   If !Empty(cDtRec) .And. ((Empty(cDtProc) .And. Empty(cDtEnv) .And. Empty(cDtGer)) .Or. ((cDtRec > cDtProc) .And. (cDtRec > cDtEnv) .And. (cDtRec > cDtGer)))
      cStatus	:= ST_BK_REC
      Break
   EndIf

   /* Se existir registro enviado, e não existir nenhum outro registro (outras datas em branco) 
      ou se a data deste envio for superior a data das outras operações, então o ultimo status é 
      este envio.
   */
   If !Empty(cDtEnv) .And. ((Empty(cDtProc) .And. Empty(cDtRec) .And. Empty(cDtGer)) .Or. ((cDtEnv > cDtProc) .And. (cDtEnv > cDtRec) .And. (cDtEnv > cDtGer)))
      cStatus	:= ST_BK_ENV
      If !Empty(cSitEnv)
         cStatus := cSitEnv
      EndIf
      Break
   EndIf

   /* Se existir registro gerado, e não existir nenhum outro registro (outras datas em branco) 
      ou se a data desta geração for superior a data das outras operações, então o ultimo status é 
      esta geração.
   */
   If !Empty(cDtGer) .And. ((Empty(cDtProc) .And. Empty(cDtRec) .And. Empty(cDtEnv)) .Or. ((cDtGer > cDtProc) .And. (cDtGer > cDtRec) .And. (cDtGer > cDtEnv)))
      cStatus	:= ST_BK_GER
      If !Empty(cSitGer)
         cStatus := cSitGer
      EndIf
      Break
   EndIf

End Sequence

RestOrd(aOrd, .T.)
Return cStatus

Function Frm101BKFilter(cFilter)
Local lRet := .T.
Default cFilter := ""

Begin Sequence
   
   If cFilter == "EEC"
      If !(lRet := (EEC_FILIAL == xFilial("EEC")))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR01).Or.EEC_PREEMB>=MV_PAR01))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR02).Or.EEC_PREEMB<=MV_PAR02))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR13).Or.EEC_EMBARCAC==MV_PAR13))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR14).Or.EEC_VIAGEM==EEC_PAR14))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR15).Or.EEC_ORIGEM==MV_PAR15))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR16).Or.MV_PAR16==EEC_DESTINO))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR17).Or.MV_PAR17+MV_PAR18==EEC_IMPORT+EEC_IMLOJA))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR19).Or.EEC_CLIENT+EEC_CLLOJA==MV_PAR19+MV_PAR20))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR12) .Or. EEB->(DbSeek(xFilial("EEB")+EEC->EEC_PREEMB+OC_EM+MV_PAR12))))
         Break
      EndIf
   ElseIf cFilter == "EYM"
      If !(lRet := (EYM_FILIAL == xFilial("EYM"))  .And. (If("1"$MV_PAR03, EYM_STATUS==ITNAOENVIADOS, .F.) .Or. If("2"$MV_PAR03, EYM_STATUS==ITENVIADOS, .F.) .Or. If("3"$MV_PAR03, EYM_STATUS==ITRECEBIDOS, .F.) .Or. If("4"$MV_PAR03, EYM_STATUS==ITPROCESSADOS, .F.)))
         Break
      EndIf

      //Data da Geração
      If !(lRet := (Empty(MV_PAR04) .Or. (EYM_STATUS $ ITRECEBIDOS+ITPROCESSADOS)  .Or. EYM_DATA >= MV_PAR04))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR05) .Or. (EYM_STATUS $ ITRECEBIDOS+ITPROCESSADOS)  .Or. EYM_DATA <= MV_PAR05))
         Break
      EndIf

      //Data do Envio
      If !(lRet := (Empty(MV_PAR06) .Or. (EYM_STATUS $ ITRECEBIDOS+ITPROCESSADOS+ITNAOENVIADOS) .Or. EYM_DTENV >= MV_PAR06))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR07) .Or. (EYM_STATUS $ ITRECEBIDOS+ITPROCESSADOS+ITNAOENVIADOS) .Or. EYM_DTENV <= MV_PAR07))
         Break
      EndIf

      //Data do Recebimento
      If !(lRet := (Empty(MV_PAR08) .Or. (EYM_STATUS $ ITNAOENVIADOS+ITENVIADOS) .Or. EYM_DTREC >= MV_PAR08))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR09) .Or. (EYM_STATUS $ ITNAOENVIADOS+ITENVIADOS) .Or. EYM_DTREC <= MV_PAR09))
         Break
      EndIf

      //Data do Processamento
      If !(lRet := (Empty(MV_PAR10) .Or. (EYM_STATUS $ ITNAOENVIADOS+ITENVIADOS+ITRECEBIDOS) .Or. EYM_DATABK >= MV_PAR10))
         Break
      EndIf
      If !(lRet := (Empty(MV_PAR11) .Or. (EYM_STATUS $ ITNAOENVIADOS+ITENVIADOS+ITRECEBIDOS) .Or. EYM_DATABK <= MV_PAR11))
         Break
      EndIf

   EndIf

End Sequence

Return lRet

/*
Funcão     : EDirImonitor
Objetivo   : Retornar os diretórios utilizados na integração SIGAEEC x INTTRA.
Autor      : Nilson César C. Filho
Data/Hora  : 28/08/2012
Obs        : 
*/
Static Function EDirImonitor(o)

   o:TableData("DIRETORIO",{"\comex\Easylink\inttra\resources"})
   o:TableData("DIRETORIO",{"\comex\Easylink\inttra\inbound"})
   o:TableData("DIRETORIO",{"\comex\Easylink\inttra\outbound"})

Return

Function EX9INTSXB()
Local oBrowse
Local oColumn
Local oDlg 
Local cCadastro		:= "Pesquisa de Container"
Local bOK			:= {|| oDlg:Refresh(),oDlg:End() }
Local bCancel		:= {|| oDlg:End() }
Local aCampos		:= {"EX9_CONTNR"}
Local nInc
Local bMarca		:= {|| If(cCont <> EX9_CONTNR,cCont:=EX9_CONTNR,cCont := Space(Len(EX9_CONTNR))) } 



DEFINE MSDIALOG oDlg TITLE cCadastro FROM DLG_LIN_INI,DLG_COL_INI TO DLG_LIN_FIM/2,DLG_COL_FIM/2 STYLE nOR(DS_MODALFRAME, WS_POPUP) OF oMainWnd PIXEL
	
	DEFINE FWBROWSE oBrowse DATA TABLE ALIAS "EX9" OF oDlg

		ADD MARKCOLUMN oColumn DATA { || If( cCont == EX9_CONTNR, 'LBOK', 'LBNO') } DOUBLECLICK bMarca OF oBrowse
	
		For nInc := 1 To Len(aCampos)
			ADD COLUMN oColumn DATA &("{ ||" + aCampos[nInc] + " }") TITLE AvSx3(aCampos[nInc], AV_TITULO) SIZE AvSx3(aCampos[nInc], AV_TAMANHO) OF oBrowse
		Next
		If Type("oIMonitor") == "O" .And. !Empty(oIMonitor:cProcess)
			oBrowse:SetFilter("EX9_FILIAL+EX9_PREEMB", xFilial("EX9")+oIMonitor:cProcess, xFilial("EX9")+oIMonitor:cProcess)
		EndIf

	ACTIVATE FWBROWSE oBrowse
	//oDlg:lMaximized := .T.

ACTIVATE MSDIALOG oDlg On Init EnchoiceBar(oDlg, bOk, bCancel) CENTERED
	
