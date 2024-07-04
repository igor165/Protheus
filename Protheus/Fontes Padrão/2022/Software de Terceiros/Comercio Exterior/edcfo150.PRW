#INCLUDE "EDCFO150.CH"  
#INCLUDE "AVERAGE.CH"
#INCLUDE "TOPCONN.CH"

#define MEIO_DIALOG    Int(((oMainWnd:nBottom-60)-(oMainWnd:nTop+125))/4)
#define COLUNA_FINAL   (oDlg:nClientWidth-4)/2
#xTranslate :COURIER_10         => \[1\]
#xTranslate :COURIER_10_NEGRITO => \[2\]
#xTranslate :COURIER_12_NEGRITO => \[3\]

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ EDCFO150 ³ Autor ³ Emerson Dib          ³ Data ³ 04.02.2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Follow-Up de Validade do Ato concessorio                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observação³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

*------------------------*
Function EDCFO150()
*------------------------*
Local   cAlias   := "ED0", nOpca := 1
Local bOk:={||(nOpca:=1, oDlg:End())}
Local bCancel:={||(nOpca:=0,oDlg:End())}

Private cTit    := STR0016 //"Follow-Up de Validade Ato Concessorio"
Private cTipo, lRet, dDtVenc, lTop, cNomWork, aHeader[0],aCampos:={}
Private cFilSB1:=xFilial("SB1"), cFilSB1Aux:=cFilSB1, cAliasSB1:="SB1" //Para utilizar produtos de outra Empresa/Filial
Private dDtIni, dDtFim  //BHF - 21/05/09

If Select("SB1EXP") = 0
   lAbriuExp := AbreArqExp("SB1",ALLTRIM(EasyGParam("MV_EMPEXP",,"")),ALLTRIM(EasyGParam("MV_FILEXP",,"")),cFilSB1,"SB1EXP") // Abre arq. produtos de outra Empresa/Filial de acordo com os parametros.
Else
   lAbriuExp := .T.
Endif
If lAbriuExp
   cAliasSB1  := "SB1EXP"
   cFilSB1Aux := EasyGParam("MV_FILEXP",,Space(FWSizeFilial()))
   If(Empty(Alltrim(cFilSB1Aux)),cFilSB1Aux:=Space(FWSizeFilial()),) //Devido ao parâmetro vir com um espaço apenas
Endif

#IFDEF TOP
   lTop := .T.
#ElSE
   lTop := .F.
#ENDIF

While .T.

   cTipo   := ""
   dDtVenc := CtoD("")
   dDtIni  := CtoD("")
   dDtFim  := CtoD("")
      
   dbselectarea("ED4") // AAF 25/05/04 - É necessario haver um alias aberto antes da chamada ao pergunte.
   If ! Pergunte("EDCFO1",.T.)
      Return .F.
   EndIf

   dDtVenc := mv_par01
   cTipo   := mv_par02

   If nOpca == 1
      Processa({|| FO150IMP() })
   ElseIf nOpca == 0
      Exit
   EndIf
EndDo

dbSelectArea(cAlias)

ED3->(dbSetOrder(1))
ED4->(dbSetOrder(1))

Return
*-----------------------------*
STATIC FUNCTION FO150IMP()
*-----------------------------*
Local cDesc1         := STR0005 //"Este programa tem como objetivo imprimir relatorio "
Local cDesc2         := STR0006 //"de Follow-Up de Validade do  Ato Concessorio."
Local cDesc3         := ""
Local lImprime       := .F.
Private titulo       := STR0007 //"Follow-Up de Validade do Ato Concessorio"
Private nLin         := 80
Private Cabec1       := ""
Private Cabec2       := ""
Private cString      := "ED0"
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 220
Private tamanho      := "G"
Private nomeprog     := "EDCFO150"
Private nTipo        := 18
Private aReturn      := { STR0008, 1, STR0009, 2, 2, 1, "", 1} //"Zebrado"###"Administracao"
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "EDCFO150" // Coloque aqui o nome do arquivo usado para impressao em disco
PRIVATE nPagina      := 0
Private TituloRel
Private FileWork1    := E_Create(,.F.)
Private cFilED0      := xFilial("ED0")
Private cFilED3      := xFilial("ED3")
Private cFilED4      := xFilial("ED4")
Private cAliasED3    := "ED3"
Private cAliasED4    := "ED4"
cbtxt := Space(10)
ED3->(dbSetOrder(2))
ED4->(dbSetOrder(2))

If lTop
   cAliasED3 := "ED3QUERY"
   cAliasED4 := "ED4QUERY"
   Processa({|| GeraQuery()},STR0018)  //"Aguarde Pesquisando Dados"
Endif

wnrel := SetPrint(cString,Nomeprog,"",titulo,cDesc1,cDesc2,cDesc3,.F.,"",.T.,Tamanho)

If nLastKey = 27
   If Select(cAliasED3) <> 0
      (cAliasED3)->(DbCloseArea())
   Endif
   If Select(cAliasED4) <> 0
      (cAliasED4)->(DbCloseArea())
   Endif
   Return
Endif

SetDefault(aReturn,cString)

nTipo := If(aReturn[4]==1,15,18)

CriaWorkDbf()

If Select(cAliasED3) <> 0 .Or. Select(cAliasED4) <> 0
   RptStatus({|lEnd| lImprime:= Imprime(wnRel,cString)})
   If(lImprime, EDCFOGERADBF(), )
Else
   Help(" ",1,"AVG0005190") //MsgInfo(STR0019) //"Nao ha Dados para Impressao !!!"
Endif

If lTop
  If Select(cAliasED3) <> 0
     (cAliasED3)->(DbCloseArea())
  Endif
  If Select(cAliasED4) <> 0
     (cAliasED4)->(DbCloseArea())
  Endif
Endif

WORK->(E_EraseArq(cNomWork))

Return .T.
*--------------------------------------*
STATIC FUNCTION Imprime(wnrel,cString)
*--------------------------------------*
Local lImp   := .F., cAtoAtual, lPrim := .F., cPictDt := "99999"
Local cPictDt_V := AVSX3("ED4_DT_VAL",6), cPictPed := AVSX3("ED0_PD",6)
Local cPictQt_Li:= AVSX3("ED4_QT_LI",6), cPictS_Nli:= AVSX3("ED4_SNCMLI",6)
Local cPictVl_Li:= AVSX3("ED4_VL_LI",6), cPictQt_Di:= AVSX3("ED4_QT_DI",6)
Local cPictQt_N := AVSX3("ED4_QTDNCM",6), cPictVl_Di:= AVSX3("ED4_VL_DI",6)
Local cPictData := AVSX3("ED3_DT_VAL",6), cPictEd3_N:= AVSX3("ED3_NCM",6)
Local cPictSaldo:= AVSX3("ED3_SALDO",6), cPictS_Ncm:= AVSX3("ED3_SALNCM",6)
Local cPictSl_Co:= AVSX3("ED3_SAL_CO",6), cPictSl_Se:= AVSX3("ED3_SAL_SE",6)
Local cPictAC   := "", cPictNcm:= AVSX3("ED4_NCM",6), lPrVez := .T.
Local lRet:= .T.
Local ni
Private nLin := 99, aCab := {}, aDet := {}, nTotVlDI := nTotVlCa := 0, nTotVl := nTotSl := 0

ED0->(DbsetOrder(2))
// Imprime Importacao ED4
If Select(cAliasED4) <> 0  .And. Str(cTipo,1) $ ("1/3")
   If lTop
      (cAliasED4)->(DbGotop())
   Else
      (cAliasED4)->(DbSeek(cFilED4+"1            ",.T.))
   Endif
   cAtoAtual := Space(Len((cAliasED4)->ED4_AC))
   nTotVlDI := 0
   nTotVlCa := 0
   lPrim := .T.

   DO While !(cAliasED4)->(EOF()) .And. (cAliasED4)->ED4_FILIAL==cFilED4

      ED0->(Dbseek(cFilED0+(cAliasED4)->ED4_AC))

	  If !Empty(ED0->ED0_DT_ENCE)
	     (cAliasED4)->(DbSkip())
   	     Loop
	  Endif

	  If !Empty(dDtVenc)
         If (cAliasED4)->ED4_DT_VAL > dDtVenc .Or. Empty((cAliasED4)->ED4_DT_VAL) .Or. Empty((cAliasED4)->ED4_AC)
      	     (cAliasED4)->(DbSkip())
   	         Loop
         EndIf
	  Endif

      If (Alltrim((cAliasED4)->ED4_NCM)<>"99999999" .and. (cAliasED4)->ED4_QT_DI <= 0) .or.;
      (Alltrim((cAliasED4)->ED4_NCM) == "99999999" .and. (cAliasED4)->ED4_VL_DI <= 0)
	     (cAliasED4)->(DbSkip())
   	     Loop
	  EndIf
	  
	  //BHF - 21/05/09
	  If !Empty(dDtIni)
	     If AC400ApDtValid("ED0") < dDtIni
	        (cAliasED4)->(DbSkip())
	        Loop
	     EndIf
	  EndIf
	  
      //BHF - 21/05/09
	  If !Empty(dDtFim)
	     If AC400ApDtValid("ED0") > dDtFim
	        (cAliasED4)->(DbSkip())
	        Loop
	     EndIf
	  EndIf

      If ED0->ED0_MODAL == "2"
         cPictAC := "@R 9999-99/999999-9"
      Else
         cPictAC := AVSX3("ED4_AC",6)
      Endif

   	  If lPrVez
   	     cAtoAtual := (cAliasED4)->ED4_AC
   	     lPrVez := .F.
   	     lPrim := .T.
   	  Endif

	  SysRefresh()
  	  lImp := .T.
  	  If cAtoAtual # (cAliasED4)->ED4_AC
	     nLin ++
         Impr_ED4()
         cAtoAtual := (cAliasED4)->ED4_AC
   	     lPrim     := .T.
   	     nTotVlDI := nTotVlCa := 0
   	     aCab := {}
   	     aDet := {}
   	  Endif
   	  
   	  nTotVlDI += (cAliasED4)->ED4_VL_DI
   	  nTotVlCa += (cAliasED4)->ED4_VALCAL
   	  If lPrim
   	      cRest := If(!Empty((cAliasED4)->ED4_DT_VAL), Transf((cAliasED4)->ED4_DT_VAL - dDataBase, cPictDt), Space(05))
          aAdd(aCab,{ Transf((cAliasED4)->ED4_AC, cPictAC),;
                      If(ED0->ED0_MODAL == "1", "Suspensao", "Isencao"),;
    	              Tabela("CD",ED0->ED0_TIPOAC),;
    	              Transf((cAliasED4)->ED4_PD, cPictPed),;
    	              Transf((cAliasED4)->ED4_DT_VAL, cPictDt_V),;
    	              cRest,;
    	              Transf( ( (dDataBase - ED0->ED0_DT_REG ) / ((cAliasED4)->ED4_DT_VAL - ED0->ED0_DT_REG)) * 100 ,"@E 999.99"),;
    	              DTOC(ED0->ED0_DT_REG) } )
         lPrim := .F.
   	  Endif
      nValDi := (cAliasED4)->ED4_QT_DI
   	  nValCal := (cAliasED4)->ED4_QTDCAL
   	  aAdd( aDet, {Alltrim(If(Empty((cAliasED4)->ED4_ITEM), STR0025, (cAliasED4)->ED4_ITEM)) +"/"+Posicione("SB1",1,xFilial()+(cAliasED4)->ED4_ITEM,"B1_DESC")+"/"+Alltrim((cAliasED4)->ED4_UMITEM),;
   	               Transf(Alltrim((cAliasED4)->ED4_NCM), cPictNcm),;
   	               Alltrim((cAliasED4)->ED4_UMNCM),;
   	               Transf((cAliasED4)->ED4_QT_LI , cPictQt_Li),;
                   Transf((cAliasED4)->ED4_SNCMLI, cPictS_Nli),;
                   Transf((cAliasED4)->ED4_VL_LI , cPictVl_Li),;
                   Transf((cAliasED4)->ED4_QT_DI , cPictQt_Di),;
                   Transf((cAliasED4)->ED4_SNCMDI, cPictQt_N),;
                   Transf((cAliasED4)->ED4_VL_DI , cPictVl_Di),;
                   If((cAliasED4)->ED4_CAMB = "1", "Sim", "Nao"),;
                   If((nValCal - nValDi) / nValCal > 0, Transf(((nValCal - nValDi) / nValCal) * 100,"@E 999.99"), Transf(0,"@E 999.99")) } )
                   //Transf( ((nValCal - nValDi) / nValCal) * 100,"@E 999.99") } )

      //TRP-17/11- Lista os produtos alternativos de cada item importado
      If ED7->( FieldPos("ED7_TPITEM") > 0  .And.  FieldPos("ED7_PD") > 0 )
         If !Empty((cAliasED4)->ED4_ITEM) .and. mv_par03 == 1  // "1-Sim"
            aAlternativos := IG400AllItens("I",(cAliasED4)->ED4_ITEM,(cAliasED4)->ED4_PD,.T.)
            aAltAux := {}
            for ni := 1 To Len(aAlternativos)
               If AScan(aAltAux,{ |x| x==aAlternativos[ni,1] }) == 0
                  (cAliasSB1)->(dbSeek(cFilSB1Aux+aAlternativos[ni,1]))
                  aAdd(aDet,{STR0041+Alltrim(aAlternativos[ni,1] )+"/"+(cAliasSB1)->B1_DESC,"","","","","","","","","",""})//"Alternativo: "
                  AAdd(aAltAux,aAlternativos[ni,1])
               EndIf
            next                           
         Endif
	  EndIf
	  (cAliasED4)->(DbSkip())
   Enddo
   If Len(aCab) <> 0 .or. Len(aDet) <> 0
      nLin ++
      Impr_ED4()
      cAtoAtual := (cAliasED4)->ED4_AC
      lPrim     := .T.
      nTotVlDI := nTotVlCa := 0
      aCab := {}
      aDet := {}
   EndIf
Endif

// Imprime Exportacao ED3
aCab :={}
aDet :={}
nLin := 99

If Select(cAliasED3) <> 0 .And. Str(cTipo,1) $ ("2/3")
   If lTop
      (cAliasED3)->(DbGotop())
   Else
      (cAliasED3)->(DbSeek(cFilED3+"1            ",.T.))
   Endif
   cAtoAtual := Space(Len((cAliasED3)->ED3_AC))
   lPrVez := .T.
   DO While (cAliasED3)->(!EOF()) .And. (cAliasED3)->ED3_FILIAL==cFilED3

      ED0->(Dbseek(cFilED0+(cAliasED3)->ED3_AC))

	  If !Empty(ED0->ED0_DT_ENCE)
	     (cAliasED3)->(DbSkip())
   	     Loop
	  Endif

      If !Empty(dDtVenc)
         If (cAliasED3)->ED3_DT_VAL > dDtVenc .Or. Empty((cAliasED3)->ED3_DT_VAL) .Or. Empty((cAliasED3)->ED3_AC)
	        (cAliasED3)->(DbSkip())
    	    Loop
   	     EndIf
   	  Endif

   	  If ED0->ED0_MODAL == "2"
   	     (cAliasED3)->( dbSkip() )
   	     LOOP
   	  Endif

      If (cAliasED3)->ED3_SALDO <= 0
         (cAliasED3)->(DbSkip())
   	     Loop
   	  EndIf

      If ED0->ED0_MODAL == "2"
         cPictAC := "@R 9999-99/999999-9"
      Else
         cPictAC := AVSX3("ED3_AC",6)
      Endif

   	  SysRefresh()
   	  lImp := .T.
   	  if lPrVez
   	     cAtoAtual := (cAliasED3)->ED3_AC
   	     lPrVez := .F.
   	     lPrim := .T.
   	  Endif
	  If cAtoAtual # (cAliasED3)->ED3_AC
   	     nLin ++
         Impr_ED3()
         nTotVl := nTotSl := 0
         //aCab := aDet := {} //ER - 11/12/2006 - Declaração separada de variáveis para não permitir replicação de Dados.
         aCab := {}
         aDet := {}
   	     cAtoAtual := (cAliasED3)->ED3_AC
   	     lPrim     := .T.
   	  EndIf
   	  
         nTotVl += (cAliasED3)->(ED3_VAL_SE+ED3_VAL_CO)
         nTotSl += (cAliasED3)->(ED3_SAL_SE+ED3_SAL_CO)
         cRest := If(!Empty((cAliasED3)->ED3_DT_VAL), Transf((cAliasED3)->ED3_DT_VAL - dDataBase, cPictDt), Space(05))
         If lPrim
             aAdd( aCab,{ Transf((cAliasED3)->ED3_AC, cPictAC),;
                          If(ED0->ED0_MODAL == "1", "Suspensao", "Isencao"),;
    	                  Tabela("CD",ED0->ED0_TIPOAC),;
    	                  Transf((cAliasED3)->ED3_PD, cPictPed),;
     	                  Transf((cAliasED3)->ED3_DT_VAL, cPictData),;
    	                  cRest,;
         	              Transf( ( (dDataBase - ED0->ED0_DT_REG ) / ( (cAliasED3)->ED3_DT_VAL - ED0->ED0_DT_REG) ) * 100,"@E 999.99"),;
         	              DTOC(ED0->ED0_DT_REG) } )
         	              lPrim := .F.
         Endif
         nSaldo := (cAliasED3)->(ED3_SAL_CO+ED3_SAL_SE)
         nValor := (cAliasED3)->(ED3_VAL_CO+ED3_VAL_SE)
         (cAliasSB1)->(dbSeek(cFilSB1Aux+(cAliasED3)->ED3_PROD))
         aAdd( aDet, {Alltrim(If(Empty((cAliasED3)->ED3_PROD), STR0025, (cAliasED3)->ED3_PROD )) +"/"+(cAliasSB1)->B1_DESC+"/"+Alltrim((cAliasED3)->ED3_UMPROD),;
                       Transf(Alltrim((cAliasED3)->ED3_NCM),cPictEd3_N),;
                       Alltrim((cAliasED3)->ED3_UMNCM),;
                       Transf((cAliasED3)->ED3_SALDO, cPictSaldo),;
                       Transf((cAliasED3)->ED3_SALNCM, cPictS_Ncm),;
                       Transf((cAliasED3)->ED3_SAL_CO, cPictSl_Co),;
                       Transf((cAliasED3)->ED3_SAL_SE, cPictSl_Se),;
                       Transf( (( nValor - nSaldo) / nValor)*100, "@E 999.99") } )
         
         //TRP-17/11- Lista os produtos alternativos de cada produto exportado 
         If ED7->( FieldPos("ED7_TPITEM") > 0  .And.  FieldPos("ED7_PD") > 0 )
            If !Empty((cAliasED3)->ED3_PROD) .and. mv_par03 == 1  // "1-Sim"
               aAlternativos := IG400AllItens("E",(cAliasED3)->ED3_PROD,(cAliasED3)->ED3_PD,.T.)
               aAltAux := {}
               for ni := 1 To Len(aAlternativos)
                  If AScan(aAltAux,{ |x| x==aAlternativos[ni,1] }) == 0
                     (cAliasSB1)->(dbSeek(cFilSB1Aux+aAlternativos[ni,1]))
                     aAdd(aDet,{STR0041+Alltrim(aAlternativos[ni,1] )+"/"+(cAliasSB1)->B1_DESC,"","","","","","",""})//"Alternativo: "
                     AAdd(aAltAux,aAlternativos[ni,1])
                  EndIf
               next                           
            Endif
         EndIf
      
      (cAliasED3)->(DbSkip())
   Enddo
   If Len(aCab) <> 0 .or. Len(aDet) <> 0
      nLin ++
      Impr_ED3()
      nTotVl := nTotSl := 0
      aCab := {}
      aDet := {}
   	  cAtoAtual := (cAliasED3)->ED3_AC
   	  lPrim     := .T.
   EndIf
Endif

If lImp
   If aReturn[5] = 1
      Set Printer To
	  Commit
	  Ourspool(wnrel)
   EndIf
Else
   Help(" ",1,"AVG0005190") //MsgInfo(STR0019) //"Nao Ha Dados para Impressao !!!"
   lRet:= .F.
Endif

MS_FLUSH()

Return lRet
*----------------------------------*
STATIC FUNCTION FO150CAB(cModulo)
*----------------------------------*
TituloRel := Titulo
nLin := 08

Cabec1 := If(cModulo == "I", STR0020, STR0021)  //"Importacao"###"Exportacao"
Cabec2 := STR0022+ Dtoc(dDtVenc)  //"Data do Vencimento: "

Cabec(TituloRel,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
nLin ++

If cModulo  == "I"
    @ nLin,089 Psay STR0010 //"              Saldo LI                                              Saldo DI"
    nLin++
//                                      1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1
//                             123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                             "Ato Concessório: XXXXXXXXXXXXXXXXXXX  Modalidade: XXXXXXXXX  Tipo: XXXXXXXXXXXXXXX  Pedido: XXXXXXXXXXXXXXX  Dt. Registro: XXXXXXXX   Dt.Valid.: XXXXXXXX  Rest.: XXXXX   %PRAZO: XXXXX   %Realizado: XXXXX  
    @ nLin,065 Psay STR0011 //"              -------------------------------------------------------  -------------------------------------------------------" 
    nLin++

	@ nLin,001 PSAY STR0035 // "Item/Descricao/UM                                    NCM/UM          Qtd.Item           Qtde.NCM           Valor US$          Qtde.Item         Qtde.NCM           Valor US$      Com Cobertura   Realizado(%)" ### "Item/Descricao/UM                                    NCM        UM NCM/Compra      Qtd.Item         Qtde.NCM/Compra         Valor US$          Qtde.Item         Qtde.NCM/Compra         Valor US$      Com Cobertura   Realizado(%)"
    nLin++
    @ nLin,001 Psay STR0037 // "==============================================   =============  =================  =================  =================  =================  =================  =================  =============   ============" ### "==============================================   =============  ========= =================  =================  =================  =================  =================  =================  =============   ============"
    nLin++
 ElseIf cModulo  == "E"
    @ nLin,118 Psay STR0013 //"                Saldo US$"
    nLin++
    @ nLin,103 Psay STR0038 //"                -----------------------------------" 
    nLin++
//                                      1         2         3         4         5         6         7         8         9         0         1         2         3         4         5         6         7         8         9         0         1
//                             123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

	@ nLin,001 Psay STR0014 // "Item/Descricao/UM                                   NCM         UM NCM/Venda       Qtde.Item        Qtde.NCM/Venda     Valor Com Cob.     Valor Sem Cob.     Realizado(%)" 
	nLin++
    @ nLin,001 Psay STR0036 //"==============================================   =============  ==============  =================  =================  =================  =================   ============"
    nLin++
Endif

RETURN .T.

*------------------------------------*
Static Function GeraQuery()
*------------------------------------*
Local cQuery1, cQuery2, cCondDel:="AND D_E_L_E_T_ <> '*' "

cQuery1:= "SELECT ED4_FILIAL, ED4_AC, ED4_DT_VAL, ED4_PD, ED4_ITEM, ED4_UMITEM, ED4_NCM, "+;
          "ED4_UMNCM, ED4_QT_LI, ED4_SNCMLI, ED4_VL_LI, ED4_QT_DI, ED4_QTDNCM, ED4_SNCMDI, "+;
		  "ED4_VL_DI, ED4_CAMB, ED4_VALCAL, ED4_QTDCAL FROM " + RetSqlName('ED4') + " WHERE ED4_FILIAL='" + cFilED4+ "' "+;
		  "AND (ED4_QT_DI > 0 OR (ED4_NCM='99999999  ' AND ED4_VL_DI > 0)) AND (ED4_AC <> '' OR ED4_AC <> ' ') "+;
		  If(TcSrvType()<>"AS/400",cCondDel,"")+"ORDER BY ED4_AC, ED4_PD, ED4_ITEM"


cQuery2:= "SELECT ED3_FILIAL, ED3_AC, ED3_DT_VAL, ED3_PD, ED3_PROD, ED3_UMPROD, ED3_NCM, "+;
          "ED3_UMNCM, ED3_SALDO, ED3_SALNCM, ED3_SAL_CO, ED3_SAL_SE, ED3_VAL_CO, ED3_VAL_SE "+;
		  "FROM "+ RetSqlName('ED3') +" WHERE ED3_FILIAL='" + cFilED3+ "' "+;
		  "AND ED3_SALDO > 0 AND (ED3_AC <> '' OR ED3_AC <> ' ') "+;
		  If(TcSrvType()<>"AS/400",cCondDel,"")+"ORDER BY ED3_AC, ED3_PD, ED3_PROD"

cQuery1:=ChangeQuery(cQuery1)
TcQuery cQuery1 ALIAS (cAliasED4) NEW

If Select(cAliasED4) <> 0
   TCSETFIELD(cAliasED4,"ED4_DT_VAL","D")
Endif

cQuery2:=ChangeQuery(cQuery2)
TcQuery cQuery2 ALIAS (cAliasED3) NEW

If Select(cAliasED3) <> 0
   TCSETFIELD(cAliasED3,"ED3_DT_VAL","D")
Endif

Return .T.

*****************************
Static Function Impr_ED4()
*****************************
LOCAL lPVez := .T.
*--------------------------------------------------------------------------------
LOCAL nInd    //LRL 20/04/04 - Na Build de 08/04/04 variavel do for não pode ser
PRIVATE i     //privada , mas é usada na função EDCFOGRVDBF ()
*--------------------------------------------------------------------------------
For nInd:= 1 to Len(aDet)
    i:=nInd
    If nLin >= 55
       FO150CAB("I")
       lPVez := .T.
    EndIf
    If lPVez
       nLin++
       @ nLin,001 PSAY STR0026+aCab[1,1] //"Ato Concessório: "
       @ nLin,039 PSAY STR0027+aCab[1,2] //"Modalidade: "
       @ nLin,062 PSAY STR0028+aCab[1,3] //"Tipo : "
       @ nLin,085 PSAY STR0029+aCab[1,4] //"Pedido : "
       @ nLin,108 PSAY STR0030+aCab[1,8] //"Data do Regis.:"
       @ nLin,136 PSAY STR0031+aCab[1,5] //"Dt. Valid.: "
       @ nLin,157 PSAY STR0032+aCab[1,6] //"Rest.: "
       @ nLin,172 PSAY STR0033+aCab[1,7] //"% Prazo: "
       @ nLin,191 PSAY STR0034+Transform( ((nTotVlCa - nTotVlDi) / nTotVlCa) * 100, "@E 999.99") //"% Realizado: "
       nLin++
       nLin++
       lPVez := .F.
    Endif

    If Len(Alltrim(aDet[i,1])) > 50 //BHF - 04/02/09
    @ nLin,001 PSAY aDet[i,1]
       nLin++
    Else
       @ nLin,001 PSAY aDet[i,1]
    EndIf
    @ nLin,050 PSAY aDet[i,2]
    @ nLin,065 PSAY aDet[i,3]
    @ nLin,079 PSAY aDet[i,4]
    @ nLin,098 PSAY aDet[i,5]
	@ nLin,116 PSAY aDet[i,6]
	@ nLin,136 PSAY aDet[i,7]
	@ nLin,155 PSAY aDet[i,8]
	@ nLin,173 PSAY aDet[i,9]
	@ nLin,194 PSAY aDet[i,10]
	@ nLin,214 PSAY aDet[i,11]

    nLin++
    
    EDCFOGRVDBF("ED4")

Next

Return .T.

*****************************
Static Function Impr_ED3()
*****************************
LOCAL lPVez := .T. 

*--------------------------------------------------------------------------------
LOCAL nInd    //LRL 20/04/04 - Na Build de 08/04/04 variavel do for não pode ser
Private i     //privada , mas é usada na função EDCFOGRVDBF ()
*--------------------------------------------------------------------------------

For nInd:= 1 to Len(aDet)
    i:=nInd 
    If nLin >= 55
       FO150CAB("E")
       lPVez := .T.
    EndIf
    If lPVez
       nLin++
       @ nLin,001 PSAY STR0026+aCab[1,1] //"Ato Concessório: "
       @ nLin,039 PSAY STR0027+aCab[1,2] //"Modalidade: "
       @ nLin,062 PSAY STR0028+aCab[1,3] //"Tipo : "
       @ nLin,085 PSAY STR0029+aCab[1,4] //"Pedido : "
       @ nLin,108 PSAY STR0030+aCab[1,8] //"Data do Regis. :"
       @ nLin,136 PSAY STR0031+aCab[1,5] //"Dt. Valid.: "
       @ nLin,157 PSAY STR0032+aCab[1,6] //"Rest.: "
       @ nLin,172 PSAY STR0033+aCab[1,7] //"Prazo(%): "
       @ nLin,191 PSAY STR0034+Transform(((nTotVl - nTotSl) / nTotVl)*100, "@E 999.99") //"Realizado(%): "
       nLin++
       nLin++
       lPVez := .F.
    Endif
    If Len(Alltrim(aDet[i,1])) > 50 //BHF - 04/02/09
    @ nLin,001 PSAY aDet[i,1]
       nLin++                   
    Else
       @ nLin,001 PSAY aDet[i,1]
    EndIf
    @ nLin,051 PSAY aDet[i,2]
    @ nLin,066 PSAY aDet[i,3]
    @ nLin,081 PSAY aDet[i,4]
    @ nLin,100 PSAY aDet[i,5]
	@ nLin,118 PSAY aDet[i,6]
	@ nLin,137 PSAY aDet[i,7]
	@ nLin,164 PSAY aDet[i,8]
    nLin++
    
    EDCFOGRVDBF("ED3")

Next

Return .T.

*-----------------------------*
Static Function EDCFOGERADBF()
*-----------------------------*
Local oDlg, nOp:=0, oCbx, lRet:= .T.
Private cGera:=Space(1), aGera:={"1 - Sim","2 - Não"}

DEFINE MSDIALOG oDlg TITLE STR0039; //"Geração de Arquivo DBF/TXT"
       FROM 12,05 To 20,45 OF GetwndDefault()

   @01,04 SAY STR0040 of oDlg //"Gera Arquivo"
   cGera := "1"
   @01,09 ComboBox oCbx Var cGera Items aGera Valid (!Empty(cGera)) SIZE 52,08 of oDlg

   DEFINE SBUTTON FROM 40,45 TYPE 13 ACTION (nOp:=1,oDlg:End()) ENABLE OF oDlg //Salvar Arq.
   DEFINE SBUTTON FROM 40,80 TYPE 2 ACTION (nOp:=0,oDlg:End()) ENABLE OF oDlg  //Cancelar

ACTIVATE MSDIALOG oDlg CENTERED

If nOp = 1 .And. Left(cGera,1)=="1"
   TR350ARQUIVO("Work")
Else
   lRet:= .F.
EndIf

Return lRet

*-----------------------------*
Static Function CriaWorkDbf()
*-----------------------------*
Private aWork:={;
               {"ATOCON"   ,"C",16 ,0},;
               {"MODALID"  ,"C",9  ,0},;
               {"TIPOAC"   ,"C",32 ,0},;
               {"PEDIDO"   ,"C",AVSX3("ED0_PD",3)     ,0},;
               {"DT_REG"   ,"D",8 ,0},;
               {"DT_VALID" ,"D",8 ,0},;
               {"DIASREST" ,"N",10 ,2},;
               {"PRAZO"    ,"N",6 ,2},;
               {"REALIZAC" ,"N",6 ,2},;
               {"ITEM"     ,"C",50,0},;
               {"NCM"      ,"C",AVSX3("ED4_NCM",3)    ,0},;
               {"UMCOM"    ,"C",AVSX3("ED4_UMNCM",3)  ,0},;
               {"QTITLI"   ,"N",AVSX3("ED4_QT_LI",3)  ,AVSX3("ED4_QT_LI",4)},;
               {"QTNCMLI"  ,"N",AVSX3("ED4_SNCMLI",3) ,AVSX3("ED4_SNCMLI",4)},;
               {"VALORLI"  ,"N",AVSX3("ED4_VL_LI",3)  ,AVSX3("ED4_VL_LI",4)},;
               {"QTITDI"   ,"N",AVSX3("ED4_QT_DI",3)  ,AVSX3("ED4_QT_DI",4)},;
               {"QTNCMDI"  ,"N",AVSX3("ED4_SNCMDI",3) ,AVSX3("ED4_SNCMDI",4)},;
               {"VALORDI"  ,"N",AVSX3("ED4_VL_DI",3)  ,AVSX3("ED4_VL_DI",4)},;
               {"COBERT"   ,"C",3 ,0},;
               {"REALIZIT" ,"N",6 ,2},;
               {"TIPO"     ,"C",1 ,0}}

cNomWork:=E_CriaTrab(,aWork,"Work")

If !USED()
   Help(" ",1,"E_NAOHAREA")
   Return .F.
Endif

IndRegua("Work",cNomWork+TEOrdBagExt(),"ATOCON")

Return .T.

*-----------------------------------*
Static Function EDCFOGRVDBF(cAlias)
*-----------------------------------*
Work->(dbAppend())

Work->ATOCON   :=aCab[1,1]  //A.C.
Work->MODALID  :=aCab[1,2]  //Modalidade
Work->TIPOAC   :=aCab[1,3]  //Tipo
Work->PEDIDO   :=aCab[1,4]  //Pedido
Work->DT_REG   :=CTOD(aCab[1,8]) //Dt. Reg.
Work->DT_VALID :=CTOD(aCab[1,5]) //Dt. Validade
cDiasRest:= StrTran(aCab[1,6],".","")
Work->DIASREST :=Val(StrTran(cDiasRest,",",".")) //Dias Restantes
cPrazo:= StrTran(aCab[1,7],".","")
Work->PRAZO    :=Val(StrTran(cPrazo,",",".")) //Prazo

Work->REALIZAC :=Val(Transform(((nTotVlCa - nTotVlDi) / nTotVlCa) * 100,"@E 999,999.99")) //Realizado
//Work->REALIZAC :=Round((((nTotVlCa - nTotVlDi) / nTotVlCa) * 100),2) //Realizado

Work->ITEM     :=aDet[i,1] //Item/Descrição- U.M.
Work->NCM      :=aDet[i,2] //Ncm
Work->UMCOM    :=aDet[i,3] //Ncm Compra/Venda
cQtdeLi:= StrTran(aDet[i,4],".","")
Work->QTITLI   :=Val(StrTran(cQtdeLi,",",".")) //Qtd. Item/LI
cQtdNcLi:= StrTran(aDet[i,5],".","")
Work->QTNCMLI  :=Val(StrTran(cQtdNcLi,",",".")) //Qtd. Ncm/LI
cValorLi:= StrTran(aDet[i,6],".","")
Work->VALORLI  :=Val(StrTran(cValorLi,",",".")) //Valor LI ou Valor com Cobertura

If cAlias == "ED4"
   cQtdeDi:= StrTran(aDet[i,7],".","")
   Work->QTITDI   :=Val(StrTran(cQtdeDi,",",".")) //Qtd. Item/DI
   
   cQtdNcDi:= StrTran(aDet[i,8],".","")
   Work->QTNCMDI  :=Val(StrTran(cQtdNcDi,",",".")) //Qtd. Ncm/DI
   
   cValorDi:= StrTran(aDet[i,9],".","")
   Work->VALORDI  :=Val(StrTran(cValorDi,",",".")) //Valor DI
   
   Work->COBERT   :=aDet[i,10] //Cobertura Cambial
   
   cRealIte:= StrTran(aDet[i,11],".","")
   Work->REALIZIT :=Val(StrTran(cRealIte,",",".")) //Realizado Imp.
Else
   cValorDi:= StrTran(aDet[i,7],".","")
   Work->VALORDI  :=Val(StrTran(cValorDi,",",".")) //Valor sem Cobertura

   cRealIte:= StrTran(aDet[i,8],".","")
   Work->REALIZIT :=Val(StrTran(cRealIte,",","."))  //Realizado Exp.
Endif

Work->TIPO     :=If(cAlias=="ED4", "I", "E")

Return .T.
