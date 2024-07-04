//#include "FiveWin.ch"
#include "Average.ch"
#include  "EICTR290.ch"
#COMMAND E_RESET_AREA => DBSELECTAREA(nOldArea) ;
                      ;  SW2->(DBSETORDER(1))
/*
Funcao      : EICTR290
Objetivos   : Ajustar o relatório para a versão 811 - Release 4
Autor       : Juliano Paulino Alves - JPA
Data 	    : 09/08/2006
Obs         :
Revisão     :
*/
*******************
Function EICTR290
*******************
lRet := EICTR290R3(.T.)
RETURN lRet                      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICTR290R3 ³ Autor ³ AVERAGE/MJBARROS    ³ Data ³ 26.08.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ PRAZO MEDIO DE FECHAMENTO DE PO's                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ EICTR290R3()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAEIC                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function EICTR290R3(p_R4)
LOCAL lOk := .T.

LOCAL cSaveMenuh, nCnt, cIndice2, cTitulo, nOldArea:=Select()

LOCAL oDlg, oGet




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a entrada de dados do arquivo                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private aCampos:={"W2_PO_NUM","W2_PO_DT","W0__CC","W0__NUM","W0__DT","W2_FORN","A2_NREDUZ",;
                  "W1_PRAZO"}
PRIVATE aRCampos:={} //igorchiba 06/07/2010 alterar ponto de entrada


PRIVATE aDados :={"TRB",;  //igorchiba 06/07/2010 alterar ponto de entrada
                STR0001,;   //"Este relatorio ir  exibir uma estat¡stica sobre"
                STR0002,;   //"os prazos de fechamento de P.O.s"
                "",;
                "M",;
                 80,;
                "",;
                "",;
                STR0003,;   //"Prazo Medio de Fechto de P.O.s"
                { STR0004, 1,STR0005, 2, 2, 1, "",1 },; //"Zebrado"###"Importa‡Æo"
                "EICTR290",;
                { {|| .T. } , {|| TR_RelMed(110,nPrazoMed) }  }  }

EICAddLoja(aCampos, "W2_FORLOJ", Nil, "W2_FORN") 
PRIVATE nPrazoMed:=0
PRIVATE cCadastro := OemtoAnsi(STR0006)      //"Prazo Medio de Fechamento de PO's"
Private _PictPO   := ALLTRIM(X3Picture("W2_PO_NUM"))

// aRotina declarada apenas para compatibilizar com GetDadDB

PRIVATE aRotina := { { STR0007       , "AxPesqui"  , 0 , 1} ,;      //"Pesquisar"
                     { STR0008        , "C210Impor" , 0 , 2} ,;      //"Atual"
                     { STR0009        , "C210Impor" , 0 , 3} }       //"Todos"

PRIVATE lInverte:=.F., cMarca:=GETMARK()

//PRIVATE cSavScrVT,cSavScrVP,cSavScrHT,cSavScrHP,;
//        CurLen,nPosAtu:=0,nPosAnt:=9999,nColAnt:=9999

Private aHeader[0],nUsado:=0
Private  aCamposTRB:={} //igorchiba 06/07/2010 alterar ponto de entrada

//JPA - 09/08/2006 - Relatório Personalizavel - Release 4
Private oReport
Private lR4   :=If(p_R4 == NIL,.F.,.T.) .AND. FindFunction("TRepInUse") .And. TRepInUse()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa tecla F10 para solicitar intervalo de datas              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
       SetKey( VK_F12,{ || pergunte("EIC010",.T.) } )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01       // Data inicial                               ³
//³ mv_par02      // Data final                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cPergunte := "EIC010"
lPadrao:=.T.
IF EasyEntryPoint("EICTR290")
   Execblock("EICTR290",.F.,.F.,"INIVAR")//igorchiba 06/07/2010 alterar ponto de entrada
ENDIF                          

aCamposTRB:= CriaEstru(aCampos,@aHeader)
AADD(aCamposTRB,{"XX_FLAGWIN","C",02,0})
aHeader[8,1]:=STR0010  //"Prazo"
nOpca:=0

cNomArq := E_CriaTrab(,aCamposTRB,"TRB") //THTS - 05/10/2017 - TE-7085 - Temporario no Banco de Dados

IF ! USED()
   Help(" ",1,"E_NAOHAREA")
   RETURN .F.
ENDIF


INDEX ON  W2_PO_NUM+W0__CC+W0__NUM+DTOS(W2_PO_DT) TO (cNomArq)

WHILE .T.
	  IF ! Pergunte(cPergunte,.T.)
	     Exit
	  ENDIF
	
	  SW2->(DBSETORDER(4))
	  SW2->(DBSEEK(xFilial()+DTOS(mv_par01),.T.))
	  
	  IF SW2->(EOF()) .OR. SW2->W2_PO_DT > mv_par02
	     Help(" ",1,"EICSEMREG")
         lOk := .F.
	  ENDIF
	  // Executa Filtro 
	  SW2->(DbSetFilter({||SUBSTR(SW2->W2_PO_NUM,1,2) <> "DA"}, "SUBSTR(SW2->W2_PO_NUM,1,2) <> 'DA'"))          
      
      If lOk
	     cTitulo:=STR0011+DTOC(mv_par01)+STR0012+DTOC(mv_par02) //"De "###" ate "
	     E_CriaCampos(aRCampos,.T.,1)
	     aRCampos[8,3]:="D"
	     Processa({|lEnd| ProcRegua(SW2->(Easyreccount("SW2"))),;
	                     nPrazoMed:=TR290Grava(),.T.},;
	                     STR0013)      //"Pesquisando P.O.s..."
         IF TRB->(Easyreccount("TRB")) > 0
            // Deixar o arredondamento igual ao do Release 3
            cPrazoMed:= Trans((nPrazoMed/TRB->(Easyreccount("TRB")) * 100)/100,"9999")
            nPrazoMed:= Val(cPrazoMed)
         ELSE
		    nPrazoMed:=0
         ENDIF
	
	     E_CriaCampos(aCamposTRB)
	     npos:=ASCAN(aCamposTRB,{|aTab|aTab[1]=="XX_FLAGWIN"})
	     IF nPos <> 0
	        ADEL(aCamposTRB,nPos)
	        ASIZE(aCamposTRB,LEN(aCamposTRB)-1)
	     ENDIF         
         
         IF lPadrao
            E_SayLeadT(cCadastro+" - "+OemToAnsi(cTitulo),,nPrazoMed,aDados,aRCampos,.T.,aCamposTRB,nil, If(lR4, {|| (oReport := ReportDef(),oReport:PrintDialog())},NIL))  // JPA - 09/09/06
         ELSE
            IF EasyEntryPoint("EICTR290")
               Execblock("EICTR290",.F.,.F.,"SAYLEADT")//igorchiba 06/07/2010 função de tela customizada
            ENDIF       
         ENDIF
         
      EndIf
	  IF nOpcA == 0 .Or. !lOk
	     EXIT
	  ENDIF  
END  
TRB->(E_EraseArq(cNomArq))

E_RESET_AREA
Set Key VK_F12 To               

Set Filter To  //Libera o Filtro

Return 
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³TR290Grava³ Autor ³ AVERAGE-MJBARROS      ³ Data ³ 26.08.96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao do Arquivo de Trabalho                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TR290Grava()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EICTR290                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION TR290Grava(cFile,nOpcao)

PRIVATE nPrazo:=0 //igorchiba 06/07/2010 alterar ponto de entrada

DBSELECTAREA("SW3")

WHILE SW2->W2_PO_DT <= mv_par02 .AND. ! SW2->(EOF()) .AND.;
      SW2->W2_FILIAL = xFilial("SW2")

      IncProc()

      IF ! SW3->(DBSEEK(xFilial()+SW2->W2_PO_NUM))
         Help("", 1, "AVG0003003",,TRAN(SW2->W2_PO_NUM,_PictPO)+STR0015,1,6)//TRAN(SW2->W2_PO_NUM,_PictPO)+STR0015,STR0016) //"P.O. "###" NAO CADASTRADO NO ARQUIVO W3_000"###"Informação"
         SW2->(DBSKIP())
         Loop
      ENDIF

      WHILE ! SW3->(EOF()) .AND. SW3->W3_PO_NUM == SW2->W2_PO_NUM  .AND.;
                                 SW3->W3_FILIAL == xFilial("SW3")

          IF ! SW0->(DBSEEK(xFilial()+SW3->W3_CC+SW3->W3_SI_NUM) )
             Help("", 1, "AVG0003004",,SW3->W3_CC+" / "+SW3->W3_SI_NUM + STR0018,1,6)//+SW3->W3_CC+" / "+SW3->W3_SI_NUM+STR0018,STR0019) //"S.I. "###" NAO CADASTRADO NO SW0"###"Informação"
             SW3->(DBSKIP())
             Loop
          ENDIF
          
          lGrvPadrao :=.T.
          lLoop      :=.F.
          IF EasyEntryPoint("EICTR290")
             Execblock("EICTR290",.F.,.F.,"LOOP")//igorchiba 06/07/2010 validacao customizada
          ENDIF                          

          IF lLoop 
             SW3->(DBSKIP())
             Loop
          ENDIF

          IF ! TRB->(DBSEEK(SW3->W3_PO_NUM+SW3->W3_CC+SW3->W3_SI_NUM))
             IF SW3->W3_FLUXO # "5"
                IF lGrvPadrao//igorchiba 06/07/2010 gravacao padrao
                SA2->(DBSEEK(xFilial()+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")))
                   TRB->(DBAPPEND())
                   TRB->W2_PO_NUM:= SW2->W2_PO_NUM
                   TRB->W2_PO_DT := SW2->W2_PO_DT      
                   TRB->W2_FORN  := SW2->W2_FORN
                If EICLoja()
                   TRB->W2_FORLOJ  := SW2->W2_FORLOJ
                EndIf
                   TRB->A2_NREDUZ:= SA2->A2_NREDUZ
                   TRB->W0__CC   := SW0->W0__CC   
                   TRB->W0__NUM  := SW0->W0__NUM  
                   TRB->W0__DT   := SW0->W0__DT
                   TRB->W1_PRAZO := E_VerPrazo(Dias_Uteis(TRB->W0__DT,TRB->W2_PO_DT))
                   nPrazo+=TRB->W1_PRAZO    
                ELSE
                   IF EasyEntryPoint("EICTR290")
                      Execblock("EICTR290",.F.,.F.,"GRVTRB")//igorchiba 06/07/2010 gravacao customizada
                   ENDIF                          
                ENDIF
             ENDIF
          ENDIF
          SW3->(DBSKIP())
      ENDDO
      SW2->(DBSKIP())
ENDDO

DBSELECTAREA("TRB")
RETURN nPrazo

//JPA - 09/08/2006 - Definições do relatório personalizável
****************************
Static Function ReportDef()
****************************
//Alias que podem ser utilizadas para adicionar campos personalizados no relatório
aTabelas := {"SW2", "SA2", "SW0"}

//Array com o titulo e com a chave das ordens disponiveis para escolha do usuário
aOrdem   := {}

//Parâmetros:            Relatório , Titulo ,  Pergunte , Código de Bloco do Botão OK da tela de impressão.
oReport := TReport():New("EICTR290", STR0003, "EIC010"  , {|oReport| ReportPrint(oReport)}, STR0001 + " " + STR0002)

//ER - 20/10/2006 - Inicia o relatório como paisagem. 
oReport:oPage:lLandScape := .T. 
oReport:oPage:lPortRait := .F. 

//Define o objeto com a seção do relatório
oSecao1 := TRSection():New(oReport,"Pedidos",aTabelas,aOrdem)

//Definição das colunas de impressão da seção 1
TRCell():New(oSecao1, "W2_PO_NUM", "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "W2_PO_DT" , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "W0__CC"   , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "W0__NUM"  , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "W0__DT"   , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "W2_FORN"  , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
If EICLoja()
   TRCell():New(oSecao1, "W2_FORLOJ"  , "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
EndIf
TRCell():New(oSecao1, "A2_NREDUZ", "TRB", /*Titulo*/   , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)
TRCell():New(oSecao1, "W1_PRAZO" , "TRB", "Prazo"      , /*Picture*/   , /*Tamanho*/      , /*lPixel*/, /*{|| code-block de impressao }*/)

oSecao1:SetTotalInLine(.F.)
oSecao1:SetTotalText("Prazo Médio em Dias")

AEVAL(oSecao1:aCell, {|X| X:SetColSpace(3)} ) //JWJ 31/01/2007: Acerto no espaçamento das colunas

oTotal:= TRFunction():New(oSecao1:Cell("W1_PRAZO"),NIL,"AVERAGE",/*oBreak*/,"","@E 99",{|| TRB->W1_PRAZO },.T.,.F.)
oTotal:SetTotalInLine(.F.)

//Necessário para carregar os perguntes mv_par**
Pergunte(oReport:uParam,.F.)

Return oReport


************************************
Static Function ReportPrint(oReport)
************************************
Local oSection := oReport:Section("Pedidos")

//Faz o posicionamento de outros alias para utilização pelo usuário na adição de novas colunas.
TRPosition():New(oReport:Section("Pedidos"),"SW2",4,{|| xFilial()+DTOS(mv_par01)})
TRPosition():New(oReport:Section("Pedidos"),"SA2",1,{|| xFilial()+SW2->W2_FORN+EICRetLoja("SW2","W2_FORLOJ")})
TRPosition():New(oReport:Section("Pedidos"),"SW0",1,{|| xFilial()+SW3->W3_CC+SW3->W3_SI_NUM})

oReport:SetMeter(TRB->(EasyRecCount("TRB")))
TRB->(dbGoTop())

//Inicio da impressão da seção 1. Sempre que se inicia a impressão de uma seção é impresso automaticamente
//o cabeçalho dela.
oReport:Section("Pedidos"):Init()

//Laço principal
Do While TRB->(!EoF()) .And. !oReport:Cancel()
   oReport:Section("Pedidos"):PrintLine() //Impressão da linha
   oReport:IncMeter()                     //Incrementa a barra de progresso
   
   TRB->( dbSkip() )
EndDo

//Fim da impressão da seção 1
oReport:Section("Pedidos"):Finish()                                

return .T.
