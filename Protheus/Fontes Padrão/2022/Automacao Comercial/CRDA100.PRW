#INCLUDE "CRDA100.CH"
#INCLUDE "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ CRDA100  ³ Autor ³Viviane M. Fernandes   ³ Data ³05.07.2003³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³CHAMADA PARA A ROTINA DE BLQ/DESBL DE CARTOES               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³EXIBE OS CARTÕES DO CLIENTE PESQUISADO, PERMITE A ESCOLHA   ³±±
±±³          ³DE UM CARTÃO PARA SER BLOQUEADO/DESBLOQUEADO/CANCELADO      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                Alteracoes desde sua criacao                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                          
Function CRDA100(cEntidade,cChave, nFolder)
Local oDlg					// Objeto da Dialog

Local aSize      := {}		// Size da Dialog - Funcao de calculo para coordenadas de tela.
Local aObjects   := {}		// Array de controle utilizado nos calculos de didmensao da Dialog
Local aInfo      := {}		// Array de controle utilizado nos calculos de didmensao da Dialog

Local lCartao  := .T.     
Local cMsg     := ""
Local cCodCli  := SA1->A1_COD
Local cLoja    := SA1->A1_LOJA

Local oList1
Local _aVenc   := {}
Local oLibera  := LoadBitmap( GetResources(), "BR_VERDE" )
Local oBLoque  := LoadBitmap( GetResources(), "BR_VERMELHO" )
Local oCancel  := LoadBitmap( GetResources(), "BR_PRETO" )     

Local aDadosCli := {}
Local aRet      := {}

PRIVATE cCadastro := STR0001

                                          
If  nfolder <> 1     
     lCartao := .F.
     cMsg    := STR0002
else     
    If !Empty(cEntidade)
       If cEntidade <> "SA1"
            lCartao := .F.
			cMsg    := STR0003
	   Else
            lCartao := .T.
       Endif     
    Else
        lCartao := .F.
		cMsg    := STR0004
	EndIf	
EndIf


If !lcartao
    MsgStop(cMsg)
Else    
    
    DbSelectArea("MA6")
    DbSetOrder(2)
    If dbSeek(xFilial("MA6")+cChave )
    	While !eof() .and. MA6->MA6_FILIAL+MA6->MA6_CODCLI+MA6->MA6_LOJA == xFilial("MA6")+cChave
    	       
    	      
			   aadd(_aVenc,{ Iif(MA6->MA6_SITUA == "1", oBloque,IIf(MA6->MA6_SITUA == "2", oLibera, oCancel)),MA6_NUM})
			   MA6->(dbSkip())
        EndDo

    EndIf
    
	aSize     := MsAdvSize(.T.,.T.)
	aInfo	:= { aSize[1],aSize[2],aSize[3],aSize[4], 0, 0 }
	
    DEFINE MSDIALOG oDlg FROM aSize[2], aSize[1] TO aSize[4], aSize[3]   TITLE STR0005  PIXEL 
    DEFINE FONT oFont NAME "ARIAL"


  	@ aSize[2], aSize[1] LISTBOX oList1 FIELDS HEADER "", STR0001 SIZE aSize[4] + 15, 56 PIXEL OF oDlg
    oList1:bLDblCLick:= {|| aDadosCli :=Telabloque(  cArq:=Alltrim(_aVenc[oList1:nAt, 2])),;
                          aRet := WSCRD070( aDadosCli ),Msgstop (aRet[4][1][3]) }
    oList1:SetArray(_aVenc)
    oList1:bLine := { || {_aVenc[oList1:nAt,1],_aVenc[oList1:nAt,2]}}

	 ACTIVATE MSDIALOG oDlg CENTERED ON INIT  EnchoiceBar(oDlg, { || oDlg:End() },{ || oDlg:End() })
        
EndIf                                         

Return  .T.