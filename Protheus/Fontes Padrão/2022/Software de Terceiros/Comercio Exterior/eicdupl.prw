//Codigos de retorno da Geracao 
#DEFINE	G_NAO_MOEDA			1
#DEFINE	G_TITULO_EXISTE	2
//Codigos de retorno da delecao
#DEFINE	D_NAO_ORIGEM      	1
#DEFINE	D_BAIXA					2
#DEFINE	D_EM_BORDERO 			3
#DEFINE	D_TITULO_NAO_EXISTE	4
#DEFINE	D_PARCELA_NAO_EXISTE	5
#include "Average.ch"

STATIC nHdlPrv		:=	1
STATIC cLoteEIC	:=	""
STATIC nTotal		:=	0
STATIC cArquivo		:=	""
STATIC lGeraLanc	:=	.F.
STATIC aRecSW6		:=	{}
STATIC aRecSE2		:=	{}
STATIC aRecSW6F		:=	{}
STATIC aRecSW6S		:=	{}
STATIC aRecSW9 		:=	{}
STATIC aRecSWD		:=	{}
STATIC aRecArq      :=  {}
STATIC nLinha 		:=	2 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ EICDUPL  ³ Autor ³ Bruno Sobieski         ³ Data ³ 14.11.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcoes de para Integracao entre SIGAEIC x SIGAFIN/SIGACOM. ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC		                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Bruno        ³14/11/00³      ³Inicio...						               ³±±
±±³ Lucas        ³16/07/01³      ³Alteracao na funcao ContabEIC, definicao ³±±
±±³              ³        ³      ³das chamadas dos lanctos padronizados.   ³±±
±±³              ³        ³      ³arredondamento                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ContabEIC³ Autor ³ Bruno Sobieski         ³ Data ³ 14.11.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcoes de abertura e Fechamento do arquivo de contra-prova,³±±
±±³          ³ chamada da DetProva() com passagem dos lancamentos contabeis³±±
±±³          ³ e cA100Incl() para exibicao e edicao dos Lactos... 			³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cRotina := Defina a funcao a executar considerando a string ³±±
±±³          ³ "Header" para HeadProva,"Detail" para DetProva() e "Footer" ³±±
±±³          ³ para RodaProva() e cA100Incl()...									³±±
±±³          ³ cIdent  := Define "Frete","Seguro","Invoice","Despachante"  ³±±
±±³          ³ lOnLine := Se a chamada e On-Line ou Batch						³±±
±±³          ³ cProcName := Nome do Programa que faz a chamada 				³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGAEIC		                                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function ContabEic(cRotina,cIdent,lOnLine,cProcName)
Local lGerou := .F.
Local nX := 1
Local lLancPad50 := VerPadrao("590")
Local lLancPad51 := VerPadrao("591")
Local lLancPad90 := VerPadrao("990")
Local lLancPad91 := VerPadrao("991")
Local lLancPad92 := VerPadrao("992")
Local lLancPad93 := VerPadrao("993")
Local lLancPad94 := VerPadrao("994")
Local lLancPad95 := VerPadrao("995")
Local lLancPad96 := VerPadrao("996")
Local lLancPad97 := VerPadrao("997")
Local lLancPad98 := VerPadrao("998")
Local lLancPad99 := VerPadrao("999")
Local lExistEZZ  := SX2->(dbSeek("EZZ"))
LOCAL lSigaCON   := IF(GetNewPar("MV_MCONTAB",.T.)== "CON",.T.,.F.)

PRIVATE lGeraEIC := .T. // Usada em rdmakes 

If Type("aRotina")=="U"
	Private aRotina:= {{"","",2,3},{"","",2,3}} 
EndIf

lOnLine := If( lOnLine==NIL,.F.,lOnLine )
cProcName := If( cProcName==NIL,Space(8),cProcName )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega as perguntas selecionadas para saber se deve verificar cotacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ mv_par01 - Lancto Contabil On-Line                           ³
//³ mv_par02 - Se mostra e permite alterar lancamentos contabeis ³
//³ mv_par03 - Se deve aglutinar os lancamentos contabeis        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cProcName <> "EICAXXX" 
	Pergunte("EICFI4",.F.)
EndIf	
lGeraLanc := IIF(mv_par01==1,.T.,.F.)
lDigita   := IIF(mv_par02==1,.T.,.F.)
lAglutina := IIF(mv_par03==1,.T.,.F.)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Chamada foi Off-Line, contabilizar sempre desde que exista   ³
 //³ lancto padronizado no SI5...                                                                                          ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 //independente de como estiver os parametros, clicou no EICDI900, contabiliza
 // isto pq nÆo poderia alterar o parametro sem afetar outros modulos SIga -Regina

If !lOnLine
  lGeraLanc := .T.
EndIf

PRIVATE aRecAux := aRecArq
IF(EasyEntryPoint("EICDUPL"),ExecBlock("EICDUPL",.F.,.F.,"ALT_PARAMETRO"),)

// Este ponto de entrada possibilita ao analista intervir e fazer por exemplo : todos os
// modulos do Siga com contabiliza‡Æo on Line, exceto o Easy. -RHP  pedido por MArcelo Sanches

If lGeraLanc .AND. lGeraEIC

  If Upper(cRotina) == "HEADER"

    nHdlPrv:=1
    //+--------------------------------------------------------------+
    //¦ Posiciona numero do Lote para Lancamentos do Financeiro      ¦
    //+--------------------------------------------------------------+
    dbSelectArea("SX5")
    SX5->(dbSeek(xFilial("SX5")+"09EIC"))
    cLoteEIC:=IIF(Found(),Trim(X5_DESCRI),"EIC")
    nHdlPrv:=HeadProva(cLoteEic,"EIC400",cUserName,@cArquivo,lSigaCON)
    If nHdlPrv <= 0
      Help(" ",1,"A100NOPROV")
    EndIf
    nLinha  := 2
    nTotal  := 0
    aRecSe2 := {}

  ElseIf Upper(cRotina) == "DETAIL"

    If cIdent $ "590" .and. lLancPad50
        nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEIC,@nLinha)
      EndIf

    If cIdent $ "591" .and. !Empty(SE2->E2_LA) .and. lLancPad51
      nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEIC,@nLinha)
    EndIf
					
    If cIdent $ "990" .and. lLancPad90
      nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEIC,@nLinha)
    EndIf
                               
    If cIdent $ "991" .and. lLancPad91
      nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEIC,@nLinha)
    EndIf

    If cIdent $ "992" .and. lLancPad92
      nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEIC,@nLinha)
    EndIf

    If cIdent $ "993" .and. lLancPad93
     nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEIC,@nLinha)
    EndIf

    If cIdent $ "994" .and. lLancPad94
      nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEIC,@nLinha)
    EndIf

    If cIdent $ "995" .and. !Empty(SW9->W9_DTLANC) .and. lLancPad95
      nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEIC,@nLinha)
    EndIf

    If cIdent $ "996" .and. !Empty(SW6->W6_DTLANCF) .and. lLancPad96
      nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEIC,@nLinha)
    EndIf

    If cIdent $ "997" .and. !Empty(SW6->W6_DTLANCS) .and. lLancPad97
       nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEIC,@nLinha)
    EndIf

    If cIdent $ "998" .and. !Empty(SWD->WD_DTLANC) .and. lLancPad98
      nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEIC,@nLinha)
    EndIf

    If cIdent $ "999"  .and. lLancPad99
      nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEIC,@nLinha)
    EndIf

    If cIdent $ "990.999"
      nPos := Ascan(aRecSW6,SW6->(Recno()))
      If nPos == 0 
        AAdd(aRecSW6,SW6->(Recno()))
      EndIf 
    ElseIf cIdent $ "991.995" 
       nPos := Ascan(aRecSW9,SW9->(Recno()))
       If nPos == 0 
         AAdd(aRecSW9,SW9->(Recno()))
       EndIf 
    ElseIf cIdent == "992" .or. cIdent == "996"
      nPos := Ascan(aRecSW6F,SW6->(Recno()))
      If nPos == 0 
        AAdd(aRecSW6F,SW6->(Recno()))
      EndIf 
    ElseIf cIdent == "993" .or. cIdent == "997"
      nPos := Ascan(aRecSW6S,SW6->(Recno()))
      If nPos == 0 
        AAdd(aRecSW6S,SW6->(Recno()))
      EndIf 
    ElseIf cIdent == "994" .or. cIdent == "998"
      nPos := Ascan(aRecSWD,SWD->(Recno()))
      If nPos == 0 
        AAdd(aRecSWD,SWD->(Recno()))
      EndIf 
    EndIF 
               
    // EOS - 06/10/03
    IF cPaisLoc # "BRA" .AND. lExistEZZ
       IF cIdent == "EZI" .OR. cIdent == "EZE"
          IF cIdent == "EZI" // inclusao de lancamento contabil
             bBlocIf := {|| VerPadrao(cIdent)}
          ELSE
             bBlocIf := {|| !Empty(EZZ->EZZ_DTLANC) .and. VerPadrao(cIdent) } 	     
          ENDIF
          IF EVAL(bBlocIf)
             nTotal += DetProva(nHdlPrv,cIdent,"EICFI400",cLoteEic,@nLinha)
          ENDIF

          IF Ascan(aRecArq,EZZ->(Recno())) == 0
             AAdd(aRecArq,EZZ->(Recno()))
          ENDIF 
       ENDIF
    ENDIF
       
    IF EasyEntryPoint("EICDUPL")
       // EOS - criacao de variaveis privates para serem utilizadas no rdmake
       PRIVATE nLinhaArq  := nLinha 
       PRIVATE nHdlProva  := nHdlPrv 
       PRIVATE cCodIdent  := cIdent
       PRIVATE cLotContab := cLoteEic
       PRIVATE nTotalGer  := nTotal  
       Execblock("EICDUPL",.F.,.F.,"CONTAB_DETAIL")
       nLinha  := nLinhaArq
       nTotal  := nTotalGer
       aRecArq := aRecAux
    ENDIF

		
  ElseIf Upper(cRotina) == "FOOTER"
 
     RodaProva(nHdlPrv,nTotal)
     lGerou := cA100Incl(cArquivo,nHdlPrv,3,cLoteEIC,lDigita,lAglutina)
     If lGerou
       For nX := 1 To Len(aRecSW6F)
         If aRecSW6F[nX] > 0
           SW6->(dbGoto(aRecSW6F[nX]))
           SW6->(RecLock("SW6",.F.))
           SW6->W6_DTLANCF := Iif(Empty(SW6->W6_DTLANCF),dDataBase,CTOD(""))
           SW6->(MsUnLock())
         EndIf 
       Next nX
       DbSelectArea("SW6")
       For nX := 1 To Len(aRecSW6S)
          If aRecSW6S[nX] > 0
            SW6->(dbGoto(aRecSW6S[nX]))
            SW6->(RecLock("SW6",.F.))
            SW6->W6_DTLANCS := Iif(Empty(SW6->W6_DTLANCS),dDataBase,CTOD(""))
            SW6->(MsUnLock())
          EndIf
       Next nX  
       For nX := 1 To Len(aRecSW9)
         If aRecSW9[nX] > 0
           SW9->(dbGoto(aRecSW9[nX]))
           SW9->(RecLock("SW9",.F.))
           SW9->W9_DTLANC  := Iif(Empty(SW9->W9_DTLANC),dDataBase,CTOD(""))
           SW9->( MsUnLock())
         EndIf 
       Next nX 
       For nX := 1 To Len(aRecSWD)
         If aRecSWD[nX] > 0
           SWD->(dbGoto(aRecSWD[nX]))
           SWD->(RecLock("SWD",.F.))
           SWD->WD_DTLANC  := Iif(Empty(SWD->WD_DTLANC),dDataBase,CTOD(""))
           SWD->(MsUnLock())
         EndIf 
       Next nX
       For nX := 1 To Len(aRecSE2)
          If aRecSE2[nX] > 0
            SE2->(dbGoto(aRecSE2[nX]))
            SE2->(RecLock("SE2",.F.))
            SE2->E2_LA  := Iif(Empty(SE2->E2_LA),"S","")
            SE2->( MsUnLock())
          EndIf 
       Next nX                                                                    
                     
	   // EOS - 06/10/03                      
       IF cPaisLoc # "BRA" .and. lExistEZZ
          For nX := 1 To Len(aRecArq)
             If aRecArq[nX] > 0
                EZZ->(dbGoto(aRecArq[nX]))
                EZZ->(RecLock("EZZ",.F.))
                EZZ->EZZ_DTLANC  := Iif(Empty(EZZ->EZZ_DTLANC),dDataBase,CTOD(""))
                EZZ->( MsUnLock())
             EndIf 
          Next nX 
       ENDIF

       IF(EasyEntryPoint("EICDUPL"),Execblock("EICDUPL",.F.,.F.,"CONTAB_FOOTER"),)
                                                          
    EndIf 
    aRecSWD  := {} // claudia
    aRecSW6F := {} // claudia
    aRecSW6S := {} // claudia
    aRecSW9  := {} // claudia
    aRecSE2  := {} // claudia
    aRecArq  := {}
  EndIf    
EndIf
Return( lGerou )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Gera DupEicºAutor  ³Bruno Sobieski      º Data ³  11/14/00  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava a Duplicata no SE2.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cNum 		:	Numero das duplicatas                           º±±
±±º          ³ nValDup  : Valor da duplicata                              º±±
±±º          ³ dEmissao : data de emissao                                 º±±
±±º          ³ dDataVenc: Data de vencimento                              º±±
±±º          ³ cSimbMoeda : Simbolo da moeda                              º±±
±±º          ³ cPrefixo : Prefixo do titulo                               º±±
±±º          ³ cTipo    : Tipo do titulo                                  º±±
±±º          ³ nParcela : Numero de parcela.                              º±±
±±º          ³ cFornece : Fornecedor                                      º±±
±±º          ³ cLoja    : Loja                                            º±±
±±º          ³ cOrigem  : Origem da geracao da duplicata (Nome da rotina) º±±
±±º          ³ cHistor  : Historico da geracao                            º±±
±±º          ³ nTaxa    : Taxa da moeda (caso usada uma taxa diferente a  º±±
±±º          ³             cadastrada no SM2.                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Array contendo o codigo de erro segundo definido no inicio º±±
±±º          ³  do programa na posicao 1 (se nao teve erro, retorna 0 )   º±±
±±º          ³  e na segunda posicao um array com os registros gravados noº±±
±±º          ³  SE2.                                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAEIC                                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRevisão   ³ Guilherme Fernandes Pilan                                  º±±
±±º          ³ 20/01/2014 - Ajuste de preenchimento do campo Parcela maiorº±±
±±º          ³            que 1 para sistema respeite o parametro MV_1DUP º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
FUNCTION GeraDupEic(cNum,nValDup,dEmissao,dDtVenc,cSimbMoeda,cPrefixo,cTipo,nParcela,cFornece,cLoja,cOrigem,cHistor,nTaxa,lSWD,cHAWB,cPoNum)
Local nMoedaCor	:=	1
Local lMoedaOk		:=	.F.
Local cMoeda		:=	" "
//Local nChr			:=	Asc(Alltrim(EasyGParam("MV_1DUP"))) - 1
Local cParcela		:=	AVKEY(EasyGetParc(nParcela),"E2_PARCELA")
Local nErrorCode	:=	0
Local nOK           :=	0
Local nTamPref      := TamSX3("E2_PREFIXO")[1]
Private dDataVenc := dDtVenc
Private lAborta := .F.
DEFAULT lSWD := .F.

nTaxa		:=	IIf(nTaxa		==	Nil,0,nTaxa)
dEmissao	:=	Iif(dEmissao	==	Nil,dDataBase,dEmissao)
dDataVenc:=	Iif(dDataVenc	==	Nil,dDataBase,dDataVenc)
nParcela	:=	IIf(nParcela	==	Nil,0,nParcela)
cHistor 	:=	IIf(cHistor		==	Nil,"",cHistor )

//TDF - 19/04/10 - Acertar tamanhos dos STR
cNum		:=  Replicate("0",TamSX3("E2_NUM"		)[1]	- Len(cNum)) + cNum
cPrefixo	:=	AvKey (cPrefixo , "E2_PREFIXO")
cTipo		:=	AvKey (cTipo    , "E2_TIPO"   )		
cFornece    :=	AvKey(cFornece  , "A2_COD"    )
cLoja 	    :=	AvKey(cLoja     , "A2_LOJA"   )
cNatureza   := "" // RAD 01/04

//*** RMD - 18/03/13 - Permite avaliar se a gravação irá prosseguir
If EasyEntryPoint("EICDUPL")
	ExecBlock("EICDUPL", .F., .F., {"GERADUPEIC",cNum,nValDup,dEmissao,dDataVenc,cSimbMoeda,cPrefixo,cTipo,nParcela,cFornece,cLoja,cOrigem,cHistor,nTaxa,lSWD,cHAWB,cPoNum})
EndIf

If lAborta
	Return nErrorCode
EndIf
//***

If cPaisLoc == "ARG" .AND. cTipo # "PR" .AND. cTipo # "PRE"//AWR 06/08/2004
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Se exitir o campo WD_SE_DOC igualar ao campo E2_PREFIXO                     ³
	//³	Caso tipo do titulo "INV" o campo E2_PREFIXO deve ser vazio	  			   ³
	//³ Itens 51, 52 e 53 da planilha de pendentes da Filial Argentina.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPrefixo == "EIC"
       cPrefixo := &(EasyGParam("MV_2DUPREF"))
       IF cPrefixo = NIL // .or. Empty(cPrefixo)        //JVR - 03/08/09 - foi incluido verificação do 'cPrefixo branco' pois está fixado a gravação do prefixo como "EIC" no DI600
          cPrefixo := AvKey ( "" , "E2_PREFIXO")
       ENDIF
	EndIf	
	If SWD->(FieldPos("WD_SE_DOC")) > 0 //EOS
		If !Empty(SWD->WD_SE_DOC)
			cPrefixo := SWD->WD_SE_DOC
		EndIf
	EndIf
    If lSWD .AND. SWD->(FieldPos("WD_NATUREZ")) > 0 //RAD 01/04 ARG
		If !Empty(SWD->WD_NATUREZ)
		   cNatureza := SWD->WD_NATUREZ
		EndIf
	EndIf
	If cTipo == "INV"
       cPrefixo := Space(nTamPref)
	EndIf		

EndIf

DbSelectArea("SA2")
DbSetOrder(1)
DbSeek(xFilial()+cFornece+cLoja)
cNatureza:=IF(EMPTY(cNatureza),SA2->A2_NATUREZ,cNatureza) // RAD 01/04

//Verifica se ja existe o titulo
DbSelectArea("SE2")
DbSetOrder(6)

If !(DbSeek(xFilial()+SA2->A2_COD+SA2->A2_LOJA+cPrefixo+cNum+cParcela+cTipo) )
	If cSimbMoeda	==	Nil
		nMoedaCor	:=	1
		lMoedaok		:=	.T.
	Else              
		nMoedaCor	:= TESimbToMoeda(cSimbMoeda)
		lMoedaOk 	:= (nMoedaCor <> 0 )
	EndIf			
	If lMoedaOk		
     	//Begin Transaction
			SE2->(RecLock("SE2",.T.))
			Replace E2_FILIAL  	With xFilial("SE2")
			Replace E2_EMISSAO 	With dEmissao
			Replace E2_EMIS1	With dEmissao
			Replace E2_FORNECE 	With SA2->A2_COD
			Replace E2_NOMFOR 	With SA2->A2_NREDUZ
			Replace E2_LOJA    	With SA2->A2_LOJA
			Replace E2_PREFIXO 	With cPrefixo
			Replace E2_TIPO    	With cTipo
			Replace E2_MOEDA   	With nMoedaCor
			Replace E2_NUM     	With cNum
			
			Replace E2_PARCELA 	With cParcela //LGS-02/09/2014
			If Empty(SE2->E2_PARCELA)
			   SE2->E2_PARCELA := cParcela
			EndIf
			
			If Alltrim(cTipo) == "PR" .Or. Alltrim(cTipo) == "PRE" //MCF - 07/10/2014
			   Replace E2_FILORIG With cFilAnt
			   Replace E2_FLUXO   With "S"   
			Endif
			
			Replace E2_VENCORI  With dDataVenc
			Replace E2_VENCTO   With dDataVenc
			Replace E2_VENCREA  With DataValida(dDataVenc,.T.)
			Replace E2_VALOR   	With nValDup                       
      // RAD 02/04 - ARG Replace E2_VLCRUZ  	With xMoeda(nValDup,nMoedaCor,1,dEmissao,,nTaxa)
            IF !Empty(nTAXA) 
               Replace SE2->E2_VLCRUZ With (SE2->E2_VALOR * nTaxa)
            ELSE               
               Replace SE2->E2_VLCRUZ With xMoeda(nValDup,nMoedaCor,1,dEmissao,,nTaxa)               
            ENDIF
            Replace E2_TXMOEDA 	With nTaxa								// RAD 01/04
			Replace E2_SALDO   	With nValDup 							
			Replace E2_NATUREZ  With cNatureza                          // RAD 01/04
			Replace E2_OCORREN 	With CriaVar("E2_OCORREN")
			Replace E2_ORIGEM  	With Upper(cOrigem)
			Replace E2_HIST    	With cHistor
			Replace E2_LA		With "S"
			If cPaisLoc == "CHI"
				Replace E2_CGC  With  SA2->A2_CGC
			Endif
            IF cHAWB # NIL .AND. SE2->(FIELDPOS("E2_HAWBEIC")) # 0
               SE2->E2_HAWBEIC:=cHAWB
			Endif
            IF cPoNum # NIL .AND. SE2->(FIELDPOS("E2_PO_EIC")) # 0
               SE2->E2_PO_EIC :=cPoNum
			Endif

            IF(EasyEntryPoint("EICDUPL"),Execblock("EICDUPL",.F.,.F.,"GRAVA_SE2_1"),)//AWR - 22/10/2004

			MsUnLock()                 //MFR 27/09/2021 OSSME-6180
			IF cPaisLoc == "BRA" .And. !(SE2->E2_TIPO $ "PR ,PRE")
   			   a050DupPag("SIGAEIC")
            Endif
		//End Transaction

		If cPaisLoc <> 'BRA' .And. EasyEntryPoint("CHQGFIN")
			ExecBlock("CHQGFIN",.F.,.F.,1)
		EndIf
	Else
		nErrorCode	:=	G_NAO_MOEDA
	Endif	
Else
    SE2->(RecLock("SE2",.F.))
	SE2->E2_VALOR+=nValDup
	SE2->E2_SALDO+=nValDup 							
    IF !Empty(nTAXA) 
       SE2->E2_VLCRUZ := (SE2->E2_VALOR * nTaxa)
    ELSE               
       SE2->E2_VLCRUZ := xMoeda(SE2->E2_VALOR,nMoedaCor,1,dEmissao,,nTaxa)
    ENDIF

    IF(EasyEntryPoint("EICDUPL"),Execblock("EICDUPL",.F.,.F.,"GRAVA_SE2_2"),)//AWR - 22/10/2004

    SE2->(MsUnLock())           //MFR 27/09/2021 OSSME-6180
    IF cPaisLoc == "BRA"  .And. !(SE2->E2_TIPO $ "PR ,PRE")
   	   a050DupPag("SIGAEIC")
    Endif
Endif

Return nErrorCode

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DeleDupEICºAutor  ³Bruno Sobieski      º Data ³  11/14/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta todas as parcelas ou alguma em particular de um      º±±
±±º          ³ titulo no SE2.                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cPrefixo : Prefixo do titulo                               º±± 
±±º          ³ cNum 		: Numero das duplicatas                           º±±
±±º          ³ nParcela : Numero de parcela (-1 para apagar todas)        º±±
±±º          ³ cTipo    : Tipo do titulo                                  º±±
±±º          ³ cFornece : Fornecedor                                      º±±
±±º          ³ cLoja    : Loja                                            º±±
±±º          ³ cOrigem  : Origem da geracao da duplicata (Nome da rotina) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Array com o codigo de retorno de cada parcela              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAEIC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function DeleDupEIC(cPrefixo,cNum,nParcela,cTipo,cFornece,cLoja,cOrigem,lSWD,cParcela)
Local aRet			:=	{}
Local nErrorCode	:=	0
Local nTamPref      := TamSX3("E2_PREFIXO")[1]
DEFAULT lSWD := .F.
Private nAutoNum := 0 // GFP - 08/01/2014
Private cUltParc := ""// THTS - 14/06/2017 - TE-5975

If cPaisLoc == "ARG" .AND. cTipo # "PR" .AND. cTipo # "PRE"//AWR 06/08/2004
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Se exitir o campo WD_SE_DOC igualar ao campo E2_PREFIXO                     ³
	//³	Caso tipo do titulo "INV" o campo E2_PREFIXO deve ser vazio	  			   ³
	//³ Itens 51, 52 e 53 da planilha de pendentes da Filial Argentina.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPrefixo == "EIC"
       cPrefixo := &(EasyGParam("MV_2DUPREF"))
       //JVR - 03/08/09 - foi incluido verificação do 'cPrefixo branco' pois está fixado a gravação do prefixo como "EIC" no DI600
       IF cPrefixo = NIL // .or. Empty(cPrefixo)
          cPrefixo := AvKey ( "" , "E2_PREFIXO")
       ENDIF
	EndIf	
	If lSWD .AND. SWD->(FieldPos("WD_SE_DOC")) > 0 //EOS
		If !Empty(SWD->WD_SE_DOC)
			cPrefixo := SWD->WD_SE_DOC
		EndIf
	EndIf
	If cTipo == "INV"
       cPrefixo := Space(nTamPref)
	EndIf		
EndIf

If nParcela == -1
	//nParcela	:=	0 TDF
	/*BEGINDOC
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³	Se a parcela 0 nao existe continua, pois pode ser que a parcela 0 nao      ³
	//³	exista, mais sim a 1,2,3 etc. O controle acaba quando nao acha uma parcela	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	ENDDOC*/
	While (nErrorCode	<>	D_TITULO_NAO_EXISTE .Or. nParcela == 1) .AND. nParcela < 125
		nErrorCode	:=	DeletaSE2(cPrefixo,cNum,nParcela,cTipo,cFornece,cLoja,cOrigem,cParcela)
		If nErrorCode	<>	D_TITULO_NAO_EXISTE
			AAdd(aRet,{nParcela,nErrorCode})
		Endif
		nParcela++
	Enddo	
Else
	Aadd(aRet,{nParcela,DeletaSE2(cPrefixo,cNum,nParcela,cTipo,cFornece,cLoja,cOrigem,cParcela)}) // GFP - 22/01/2014
Endif

Return aRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DeletaSE2 ºAutor  ³Bruno Sobieski      º Data ³  11/14/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava a Duplicata no SE2.                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cPrefixo : Prefixo do titulo                               º±± 
±±º          ³ cNum 		:	Numero das duplicatas                          º±±
±±º          ³ cParcela : Tipo do titulo                                  º±±
±±º          ³ cTipo    : Tipo do titulo                                  º±±
±±º          ³ cFornece : Fornecedor                                      º±±
±±º          ³ cLoja    : Loja                                            º±±
±±º          ³ cOrigem  : Origem da geracao da duplicata (Nome da rotina) º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ Codigo de erro segundo definido no inicio do programa, se   º±±
±±º          ³  nao teve erro, retorna 0 (zero).                           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGAEIC                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function DeletaSE2(cPrefixo,cNum,nParcela,cTipo,cFornece,cLoja,cOrigem,cParcela)
Local	nMoeda 	:= Int(Val(EasyGParam("MV_MCUSTO")))
//Local nChr		:=	Asc(Alltrim(EasyGParam("MV_1DUP")))-1 TDF
//Local nChr		:=	Asc(Alltrim(EasyGParam("MV_1DUP")))-1
Local nErrorCode:=	0
Local lAchouSE2 := .T. // SVG - 13/05/2010 -

If Empty(cParcela)  // GFP - 22/01/2014
   Default cParcela	:=	EasyGetParc(nParcela)
EndIf

/*If nParcela >= 0 // TDF
	cParcela := FI400TamCpoParc(nChr,nParcela)
Endif*/

DbSelectArea("SA2")
SA2->(DbSetOrder(1))
SA2->(DbSeek(xFilial()+cFornece+cLoja))

DbSelectArea("SE2")
SE2->(DbSetOrder(6))
// SVG - 13/05/2010 -
If !(lAchouSE2:= SE2->(dbSeek(xFilial()+cFornece+cLoja+cPrefixo+cNum+cParcela+cTipo)))
   //TDF - 19/04/10 - Acertar tamanhos dos STR
   cNum2	   :=	Replicate("0",TamSX3("E2_NUM" )[1] - Len(AllTrim(cNum))) + AllTrim(cNum)// SVG - 29/07/2010 - Devido a Titulos gerados com numero inválido.
   cNum		   :=	Replicate("0",TamSX3("E2_NUM" )[1] - Len(cNum)) + cNum
   cPrefixo	   :=	AvKey (cPrefixo , "E2_PREFIXO")
   cParcela	   :=	AvKey (cParcela , "E2_PARCELA")//TDF
   cTipo	   :=	AvKey (cTipo    , "E2_TIPO"   )		 
   cFornece    :=	AvKey (cFornece , "A2_COD"    )
   cLoja 	   :=	AvKey (cLoja    , "A2_LOJA"   )
EndIf

DbSelectArea("SE2")
SE2->(DbSetOrder(6))                                                                         // SVG - 29/07/2010 - Devido a Titulos gerados com numero inválido.
If lAchouSE2 .Or. SE2->(dbSeek(xFilial()+cFornece+cLoja+cPrefixo+cNum+cParcela+cTipo)) .Or. SE2->(dbSeek(xFilial()+cFornece+cLoja+cPrefixo+cNum2+cParcela+cTipo)) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se os dados nao foram gravados por outro modulo			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !cTipo =="NF " //LRS - 26/01/2015 - Se o tipo for NF, a Origem vai ser gravado em Branco.
    //MFR 09/10/2019 OSSME-3823
		If Upper(Trim(SE2->E2_ORIGEM)) != Upper(Trim(cOrigem))
			nErrorCode	:=	D_NAO_ORIGEM
		EndIf
	EndIF
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o titulo nao esta em bordero                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nErrorCode == 0 .And. !Empty(SE2->E2_NUMBOR)
		nErrorCode	:=	D_EM_BORDERO
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se titulo ja foi baixado total ou parcialmente			 	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If nErrorCode == 0 .And. (!Empty(E2_BAIXA) .Or. (E2_VALOR != E2_SALDO))
		nErrorCode	:=	D_BAIXA
	EndIf

	If nErrorCode == 0 
//              Begin Transaction AWR 10/05/2002
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza saldo do fornecedor                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SA2->(RecLock("SA2"))
			If !(SE2->E2_TIPO $"PA /"+MV_CPNEG) .and. SubStr(SE2->E2_TIPO,3,1) != "-"
				SA2->A2_SALDUP -= xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,,SE2->E2_VLCRUZ/SE2->E2_VALOR)
				SA2->A2_SALDUPM-= xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,nMoeda,SE2->E2_EMISSAO,,SE2->E2_VLCRUZ/SE2->E2_VALOR)
			Else
				SA2->A2_SALDUP += xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,1,SE2->E2_EMISSAO,,SE2->E2_VLCRUZ/SE2->E2_VALOR)
				SA2->A2_SALDUPM+= xMoeda(SE2->E2_SALDO,SE2->E2_MOEDA,nMoeda,SE2->E2_EMISSAO,,SE2->E2_VLCRUZ/SE2->E2_VALOR)
			EndIf

			dbSelectArea("SE2")
			If cPaisLoc <> 'BRA' .And. EasyEntryPoint("CHQGFIN")
				ExecBlock("CHQGFIN",.F.,.F.,2)
			EndIf	

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Apagar o registro                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SE2->(Reclock("SE2",.F.))
			SE2->(DbDelete())
			SE2->(MsUnLock())
//              End Transaction AWR 10/05/2002
	Endif
Else
	If !dbSeek(xFilial()+cFornece+cLoja+cPrefixo+cNum)
		nErrorCode	:=	 D_TITULO_NAO_EXISTE
	Else	
		//Conferir se nao existe o Titulo ou a parcela....
		While !EOF() .And. xFilial()+cFornece+cLoja+cPrefixo+cNum ==;
				 E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM
			If cTipo	==	E2_TIPO
				nErrorCode	:=	D_PARCELA_NAO_EXISTE
			Endif
			DbSkip()
		Enddo						 
		If nErrorCode	==	0
			nErrorCode	:=	 D_TITULO_NAO_EXISTE
		Endif		
	Endif
EndIf
Return nErrorCode
