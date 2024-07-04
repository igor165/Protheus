#INCLUDE "HSPAHR99.ch"
#INCLUDE "RWMAKE.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHR99 º Autor ³ Rogerio Faro      º Data ³ Janeiro/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ LISTAGEM DE PROFISSIONAIS                                  º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Gestao Hospitalar                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHR99()
 Local cDesc1  := STR0001 //"Este programa tem como objetivo imprimir relatorio "
 Local cDesc2  := STR0002 //"de acordo com os parametros informados pelo usuario."
 Local cDesc3  := ""
 Local cPict   := ""
 Local cTitulo := STR0003 //"Credenciamento Médico X Convenio X Plano"
 Local nLin    := 80
 Local cCabec1 := ""
 Local cCabec2 := ""
 Local imprime := .T.
 Local aOrd    := {}
 Local nLinTotal := 60

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Declaracao de Variaveis Privadas                                    ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
 Private lEnd         := .F.
 Private lAbortPrint  := .F.
 Private CbTxt        := "M"
 Private limite       := 132
 Private tamanho      := "M"
 Private nomeprog     := "HSPAHR99"
 Private nTipo        := 18
 Private aReturn      := {STR0004, 1, STR0005, 1, 1, 1, "", 1}   //"Zebrado"###"Administracao"
 Private nLastKey     := 0
 Private cbcont       := 00
 Private CONTFL       := 01
 Private m_pag        := 01
 Private wnrel        := "HSPAHR99"
 Private cString      := ""
 Private aRegistros   := {}

 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

	Private lGFR := HS_LocTab("GFR", .F.) 
 
 cPerg := "HSPR99"
 If !Pergunte(cPerg,.T.)
  return
 EndIf

 nMaxLin := HS_MaxLin(cCODIMP)
 nLin := nMaxLin * 2

 If Mv_Par01 == 1
  cTitulo += " - " + STR0006 //"Corpo Clinico"
 ElseIf Mv_Par01 == 2
  cTitulo += " - " + STR0007 //"Eventuais"
 Endif
 
 If Mv_Par02 == 1
  cTitulo += " - " + STR0008 //"Ativos"
 ElseIf Mv_Par02 == 2
  cTitulo += " - " + STR0009 //"Inativos"
 Endif

 If !Empty(MV_PAR04)			            
  If lGFR
  	cCabec1 	:= STR0010 + Posicione("GFR", 1, xFilial("GFR") + MV_PAR04, "GFR_DSESPE") + Iif(Mv_Par03 == 1, STR0011,"") //"Especialidade --> "###" - Cotistas"
  Else
			cCabec1 	:= STR0010 + Posicione("SX5", 1, xFilial("SX5") + "EM" + MV_PAR04, "X5_DESCRI") + Iif(Mv_Par03 == 1, STR0011,"") //"Especialidade --> "###" - Cotistas"  
  EndIf
 Else
  cCabec1 	:= STR0010 + STR0021 + Iif(Mv_Par03 == 1, STR0011,"") //"Especialidade --> "###" - Cotistas" //"Todas"
 EndIf 
 cCabec2 	:= STR0012 //"Nome do Profissional           CRM    % AMB. %AMB.U % INT. %INT.U Convenio             Plano             % AMB. %AMB.U % INT. %INT.U"
                     //           1         2         3         4         5         6         7         8         9        10        11        12        13
       			           // 012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901
                     // 123456789012345678901234567890 123456 123456 123456 123456 123456 12345678901234567890 12345678901234567 123456 123456 123456 123456

 wnrel := SetPrint(cString,NomeProg,"",@cTitulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.T.,Tamanho,,.F.)
 
 If nLastKey == 27
  Return
 Endif
 
 SetDefault(aReturn,cString)
 
 If nLastKey == 27
  Return
 Endif
 
 RptStatus({|| RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)}, cTitulo)
Return(Nil)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFun‡„o    ³RUNREPREL º Autor ³ ROGERIO FARO       º Data ³Janeiro/2004 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
±±º          ³ monta a janela com a regua de processamento.               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function RunRepRel(cCabec1, cCabec2, cTitulo, nLin, nLinTotal)
 
 Set Printer to &wNRel
 Set Printer On
 Set Device  to Printer

 DbSelectArea("GBJ")
 DbGoTop()
 SetRegua(RecCount())
 
 While !Eof() .And. GBJ->GBJ_FILIAL == xFilial("GBJ")
  IncRegua()
  If MV_PAR01 # 3
   If MV_PAR01 == 1
    IF GBJ->GBJ_TIPPRO # "0"
     DbSkip()
     loop
    Endif
   Elseif MV_PAR01 == 2
    IF GBJ->GBJ_TIPPRO # "1"
     DbSkip()
     loop
    Endif
   Endif
  Endif

  If MV_PAR02 # 3
   If MV_PAR02 == 1
    IF GBJ->GBJ_STATUS # "1"
     DbSkip()
     loop
    Endif
   Elseif MV_PAR02 == 2
    IF GBJ->GBJ_STATUS # "0"
     DbSkip()
     loop
    Endif
   Endif
  Endif

  If MV_PAR03 # 3
   If MV_PAR03 == 1
    IF GBJ->GBJ_COTIST # "1"
     DbSkip()
     loop
    Endif
   Elseif MV_PAR03 == 2
    IF GBJ->GBJ_COTIST # "0"
     DbSkip()
     loop
    Endif
   Endif
  Endif
  
  If !Empty(MV_PAR04)
   IF !(MV_PAR04 $ HS_REspMed(GBJ->GBJ_CRM))
    DbSkip()
    loop
   Endif
  EndIf
  
  If nLin > nMaxLin // Salto de Página. Neste caso o formulario tem 66 linhas...
   nLin := Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo) + 1
  Endif  
  
  @ nlin, 000 PSay PadR(Posicione("SRA", 11, xFilial("SRA") + GBJ->GBJ_CRM, "RA_NOME"), 30)
  @ nlin, 031 PSay PadR(GBJ->GBJ_CRM, 06)              
  @ nlin, 038 PSay Transform(GBJ->GBJ_REPAMB, "@E 999.99")
  @ nlin, 045 PSay Transform(GBJ->GBJ_RAMBUR, "@E 999.99")
  @ nlin, 052 PSay Transform(GBJ->GBJ_REPINT, "@E 999.99")
  @ nlin, 059 PSay Transform(GBJ->GBJ_RINTUR, "@E 999.99")
  
  DbSelectArea("GAY")
  DbSetOrder(2)
  If DbSeek(xFilial("GAY") + GBJ->GBJ_CRM)
   While !Eof() .And. xFilial("GAY") == GAY->GAY_FILIAL .And. GAY->GAY_CODCRM == GBJ->GBJ_CRM
    If nLin > nMaxLin // Salto de Página. Neste caso o formulario tem 66 linhas...
     nLin := Cabec(cTitulo,cCabec1,cCabec2,NomeProg,Tamanho,nTipo) + 1
     @ nlin, 000 PSay PadR(Posicione("SRA", 11, xFilial("SRA") + GBJ->GBJ_CRM, "RA_NOME"), 30)
     @ nlin, 031 PSay PadR(GBJ->GBJ_CRM, 06)              
     @ nlin, 038 PSay Transform(GBJ->GBJ_REPAMB, "@E 999.99")
     @ nlin, 045 PSay Transform(GBJ->GBJ_RAMBUR, "@E 999.99")
     @ nlin, 052 PSay Transform(GBJ->GBJ_REPINT, "@E 999.99")
     @ nlin, 059 PSay Transform(GBJ->GBJ_RINTUR, "@E 999.99")
    Endif                    
   
    @ nlin, 066 PSay PadR(Posicione("GA9", 1, xFilial("GA9") + GAY->GAY_CODCON, "GA9_NREDUZ"), 20)
    If !Empty(GAY->GAY_CODPLA)
     @ nlin, 087 PSay PadR(Posicione("GCM", 1, xFilial("GCM") + GAY->GAY_CODCON + GAY->GAY_CODPLA, "GCM_DESPLA"), 17)
    Else                                                                                                             
     @ nlin, 087 PSay PadR(STR0022, 17) //"Todos os planos"
    EndIf 
//  Proximas 4 linhas comentadas por Antonio Marco em 23/11/05
//  @ nlin, 105 PSay Transform(GAY->GAY_REPAMB, "@E 999.99")
//  @ nlin, 112 PSay Transform(GAY->GAY_RAMBUR, "@E 999.99")
//  @ nlin, 119 PSay Transform(GAY->GAY_REPINT, "@E 999.99")
//  @ nlin, 126 PSay Transform(GAY->GAY_RINTUR, "@E 999.99")
//  Proximas 4 linhas criadas/corrigidas por Antonio Marco em 23/11/05
    @ nlin, 105 PSay Transform(GBJ->GBJ_REPAMB, "@E 999.99")
    @ nlin, 112 PSay Transform(GBJ->GBJ_RAMBUR, "@E 999.99")
    @ nlin, 119 PSay Transform(GBJ->GBJ_REPINT, "@E 999.99")
    @ nlin, 126 PSay Transform(GBJ->GBJ_RINTUR, "@E 999.99")
    
    nLin++  
    DbSkip()                                                                                    
   End
  Else
   @ nLin, 066 PSay STR0023 //"Medico sem credenciamento com conveio x plano."
   nLin++
  EndIf 

  nLin++
                                                    
  DbSelectArea("GBJ")
  DbSkip()
 Enddo
 
 Set Printer to
 Set Device  to Screen
 
 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(wnrel)
 Endif

 MS_FLUSH()
Return(Nil)