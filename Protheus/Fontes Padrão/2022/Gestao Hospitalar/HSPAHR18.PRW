#INCLUDE "HSPAHR18.ch"
#INCLUDE "RWMAKE.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ HSPAHR18 º Autor ³ Rogerio Faro         º Data ³ 06/05/04  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relacao de Exames confirmados de um Atendimento            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ GESTAO HOSPITALAR                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHR18()
 Private cCODIMP := ""
 Private nMaxLin := 0 // quantidade maxima de linhas p/ impressao

 if !Pergunte("HSPR18",.t.)
  Return(Nil)
 Endif

 nMaxLin := HS_MaxLin(cCODIMP)

 cTitulo  := STR0001 //"Relacao de Exames / Atendimento"

 Private M_Pag    := 1
 Private cTamanho := "P"           // P/M/G
 Private nCaracter:= 18
 Private Limite   := 80            // 80/132/220
 Private aOrdem   := {}           // Ordem do Relatorio
 Private nLastKey := 0
 Private aReturn  := { STR0002, 1,STR0003, 1, 1, 1, "",1 } //"Zebrado"###"Administracao"
 Private cNomProg := "HSPAHR18"
 Private cNomeRel := "HSPAHR18"
 Private cDrive   := "Epson.drv"
 Private cNomeImp := "LPT1"
 Private cAlias   := "GAD"
 Private nLin     := nMaxLin * 2

 cNomeRel := SetPrint(cAlias,cNomeRel,nil ,@cTitulo,"","","",.F.,"",.T.,cTamanho,nil    ,nil    ,nil)

 If nLastKey == 27
  Return(nil)
 Endif

 SetDefault(aReturn,cAlias)

 If nLastKey == 27
  Return
 Endif

 Processa({|| RptProc() } )  //Gera e imprime o relatorio

Return(nil)

////////////////////////////////////////////////////////////////
//   Funcao.:   RptProc                                       //
//   Objetivo.: Enviar o Relatorio para Tela ou Impressora    //
////////////////////////////////////////////////////////////////
Static Function RptProc()
 Local nCt	:= 0, nFUConv := 0

 ///////////////////////////////////////////////////////
 Local aDados := {} // Exames por Paciente
 //  1o Elemento - GAO	03	GAO_REGATE	C	 6 0	Registro de Internacao
 //  2o Elemento - GAO	04	GAO_NOME  	C	45 0	Nome do Paciente
 //  3o Elemento - GAO	07	GAO_CODPRO	C	 9 0	Codigo do Procedimento
 //  4o Elemento - GAO	08	GAO_DESPRO	C	30 0	Descricao do Procedimento
 //  5o Elemento - GAO	09	GAO_QTDPRO	N	10 4	Quantidade Procedimento
 //  6o Elemento - GAO	11	GAO_VALPRO	N	 8 2	Valor em Reais
 //  7o Elemento - GAO	20	GAO_LOGARQ	C	40 0	subs(cUsuario,7,15)+" - "+strzero(day(dDataBase),2)+"/"+StrZero(month(dDataBase),2)+"/"+str(year(dDataBase),4)+" - "+time()+"h"
 //  8o Elemento - GAO	15	GAO_DATDES	D	 8 0	Data de Lancamento

 Local aResumo := {}  //Resumo por paciente
 //  1o Elemento - GAO	03	GAO_REGATE	C	 6 0	Registro de Internacao
 //  2o Elemento - GAO	04	GAO_NOME  	C	45 0	Nome do Paciente	
 //  3o Elemento - GA8	05	GA8_CODPRT	C	 9 0	Cod Procedimento Tabela
 //  4o Elemento - GAO	08	GAO_DESPRO	C	30 0	Descricao do Procedimento
 //  5o Elemento - GAO	09	GAO_QTDPRO	N	10 4	Quantidade Procedimento	
 //  6o Elemento - GAO	11	GAO_VALPRO	N	 8 2	Valor em Reais (R$)
 //  7o Elemento - GAO	11	nStVALPRO	            GAO_VALPRO*GAO_QTDPRO
 //  8o Elemento - GA8	06	GA8_VLRPRO	N	 8 2	Valor R$ / Quantidade CH	

 Set Printer to &cNomeRel
 Set Printer On
 Set Device  to Printer
 
 DbSelectArea("GAO")
 dbsetorder(1)   
 nTReg := RecCount()
 
 if !dbseek(xFilial("GAO") + MV_PAR01)  
  HS_MsgInf(STR0004, STR0005, STR0001)  //"Não existem exames para este Atendimento!"###"Atencao" //"Relacao de Exames / Atendimento"
  Return(.F.)
 endif
 
 ProcRegua(nTReg)

 While !Eof() .and. GAO->GAO_REGATE == MV_PAR01 .And. xFilial("GAO") == GAO->GAO_FILIAL
  IncProc(STR0006 + GAO->GAO_REGATE + STR0007 + DTOC(GAO->GAO_DATDES) ) //"Registro Atendimento No "###"  Data "

  If GAO->GAO_GLODES # "0"
   DbSkip()
   Loop
  Endif
  
  cGAO_DESPRO := Posicione("GA7",1,xFilial("GA7")+GAO->GAO_CODPRO,"GA7_DESC")
  cGAO_NOME   := Posicione("GAD",1,xFilial("GAD")+GAO->GAO_REGATE,"GAD_NOME")
  cTAB_PRO    := Posicione("GAD",1,xFilial("GAD")+GAO->GAO_REGATE,"GAD_TABPRO")
 
  nValpro  := (GAO->GAO_COEDES * GAO->GAO_VALPRO)
    
  DbSelectArea("GA7")
  DbSetOrder(1)
  DbSeek(xFilial("GA7") + GAO->GAO_CODPRO)

  If HS_FUrgDes(MV_PAR01, @nFUConv, GA7->GA7_TIPPRO, GAO->GAO_CODPRO, GAO->GAO_DATDES, GAO->GAO_HORDES, GAO->GAO_URGDES, GAO->GAO_CODCCU)
   nValpro := nValpro * nFUConv // Multiplica pelo fator de Urgencia Médica
  EndIf             

  aAdd(aDados, {GAO->GAO_REGATE, cGAO_NOME, GAO->GAO_CODPRO, cGAO_DESPRO, GAO->GAO_QTDPRO, nValpro, GAO->GAO_LOGARQ, GAO->GAO_DATDES})
	
  //gerando resumo por tipo de exame  
  cGA8_CODPRT := Posicione("GA8", 1, xFilial("GA8") + GAO->GAO_CODPRO, "GA8_CODPRT")
  nGA8_VLRPRO := Posicione("GA8", 1, xFilial("GA8") + GAO->GAO_CODPRO + cTAB_PRO, "GA8_VLRPRO")

  If HS_FUrgDes(MV_PAR01, @nFUConv, GA7->GA7_TIPPRO, GAO->GAO_CODPRO, GAO->GAO_DATDES, GAO->GAO_HORDES, GAO->GAO_URGDES, GAO->GAO_CODCCU)
   nGA8_VLRPRO := nGA8_VLRPRO * nFUConv // Multiplica pelo fator de Urgencia Médica
  EndIf             
  
  nPos := Ascan(aResumo,{|x| Alltrim(x[4]) == Alltrim(cGAO_DESPRO)})
  If nPos > 0
   aResumo[nPos,5] += GAO->GAO_QTDPRO 
   aResumo[nPos,7] += GAO->GAO_QTDPRO * (GAO->GAO_COEDES * GAO->GAO_VALPRO)
   aResumo[nPos,8] += (nGA8_VLRPRO * GAO->GAO_QTDPRO)		
  Else
   aadd(aResumo, {GAO->GAO_REGATE, cGAO_NOME, cGA8_CODPRT, cGAO_DESPRO, GAO->GAO_QTDPRO, nValpro, (GAO->GAO_QTDPRO * nValpro), (nGA8_VLRPRO * GAO->GAO_QTDPRO)})
  Endif
  DbSelectArea("GAO")
  DbSkip()	
 Enddo

 iF len(aDados) > 0
  ASort(aDados ,,,{|x,y| Dtos(X[8])+X[4] < Dtos(Y[8])+Y[4] })
  ASort(aResumo,,,{|x,y| X[4] < Y[4]})
  setprc(0,0)
  cCabec1  := STR0008 + aDados[1,1] + "  " + aDados[1,2] + Space(40) + " - " + Subs(Time(),1,5) + " h"  //"Reg Atendimento.: "
  cCabec2  := STR0009 //"Codigo    Descricao                          Qtd    Valor    LOG        Data"
  //           123456789 123456789012345678901234567 1234567890 12345678 1234567890 12/04/2002
  cCab_    := Repl("-",80)
  nTValor := nTCh := 0
  ProcRegua(Len(aDados))
  For nCt := 1 to Len(aDados)
   IncProc(STR0006 + aDados[nCt,1] + STR0007 + DTOC(aDados[nct,8])) //"Registro Atendimento No "###"  Data "
   if ( nLin > nMaxLin )		
    nLin := cabec(ctitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)		
   endif
   nLin++
   @ nLin,00  PSAY aDados[nCt,3]
   @ nLin,10  PSAY SubStr(aDados[nCt,4],1,26)
   @ nLin,38  PSAY Transform(aDados[nCt,5],"@e 9,999.9999")
   @ nLin,49  PSAY Transform(aDados[nCt,6],"@e 99,999.99")
   @ nLin,59  PSAY SubStr(aDados[nCt,7],1,12)
   @ nLin,72  PSAY aDados[nCt,8]
   nTValor += aDados[nCt,6]
  Next

  nLin += 2
  @ nLin, 00 psay cCab_
  nLin++
  @ nLin,00  pSay STR0010 //"Total Geral de Exames......."
  @ nLin,46  pSay Transform(nTValor,"@E 9,999,999.99")
  
  //Impressao do Resumo por Descricao do Procedimento
  
  cTitulo  := STR0011 //"Resumo dos Exames / Procedimento"
  cCabec1  := STR0008 + aResumo[1,1] + "  " + aResumo[1,2] + Space(47) + Subs(Time(),1,5) + " h"  //"Reg Atendimento.: "
  cCabec2  := STR0012 //"Codigo    Descricao                             Qtd   Vl Uni  Vl Total  Total/CH"
 //           123456789 123456789012345678901234567890 1234567890 12345678 123456789 123456789
  cCab_    := Repl("-",80)
  nTValor := nTCh := 0
  nLin := nMaxLin * 2
  ProcRegua(Len(aResumo))

  For nCt := 1 to Len(aResumo)
   IncProc(STR0006 + aResumo[nCt,1]) //"Registro Atendimento No "
   if ( nLin > nMaxLin )			
    nLin := cabec(ctitulo,cCabec1,cCabec2,cNomProg,cTamanho,nCaracter)				
   endif	
   nLin++
   @ nLin,00  PSAY aResumo[nCt,3]
   @ nLin,10  PSAY SubStr(aResumo[nCt,4],1,30)
   @ nLin,41  PSAY Transform(aResumo[nCt,5],"@e 9,999.9999")
   @ nLin,52  PSAY Transform(aResumo[nCt,6],"@e 9,999.99")
   @ nLin,61  PSAY Transform(aResumo[nCt,7],"@e 99,999.99")	
   @ nLin,71  PSAY Transform(aResumo[nCt,8],"@e 99,999.99")			
   nTValor += aResumo[nCt,7]
   nTCh    += aResumo[nCt,8]
  Next

  nLin += 2
  @ nLin, 00 psay cCab_
  nLin++
  @ nLin,00  pSay STR0013 //"Total de Exames......."
  @ nLin,61  pSay Transform(nTValor,"@E 99,999.99")
  @ nLin,71  pSay Transform(nTCh   ,"@E 99,999.99")
 Else
  HS_MsgInf(STR0014, STR0005, STR0001)  //"Não existem exames confirmados para este Atendimento!"###"Atencao", //"Relacao de Exames / Atendimento"
  Return(.F.)
 Endif

 If aReturn[5]==1
  dbCommitAll()
  SET PRINTER TO
  OurSpool(cNomeRel)
 Endif

 Ms_Flush()

Return(nil)