
#include "Protheus.ch"
#include "HSPAHM21.CH"
#include "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHM21  º Autor ³ José Orfeu         º Data ³  01/05/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Resumo de Atendimento, Consulta Movimentação das Recepções º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                                                 
Function HSPAHM21()

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define variaveis                                                      ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Private aPos      := { 15, 1, 70, 315 }
 Private cCadastro := OemToAnsi(STR0001)	//"Resumo de Atendimento"   
 Private lAteRpd   := .F., lBolFec := .F.
  
 Private aRotina:= {{OemToAnsi(STR0002), "AxPesqui" , 0, 1}, ; //"Pesquisar"
                    {OemToAnsi(STR0003), "HspM21Res", 0, 2}, ; //"Visualizar"
					               {OemToAnsi(STR0004), "HspM21Res", 0, 3}, ; //"Fechar"
					               {OemToAnsi(STR0005), "HspM21Res", 0, 4}, ; //"Reimpressao"
					               {OemToAnsi(STR0031), "HspM21Res", 0, 5}, ; //"Exclui"
					               {OemToAnsi(STR0032), "HspM21Res", 0, 4}}   //"Acerta"
					
					
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Resumo de Atendimento
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DbSelectArea("GBN")
 DbSetOrder(1)

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Endereca a funcao de BROWSE                                           ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 mBrowse(06, 01, 22, 75, "GBN")
 
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Devolve os indices padroes do SIGA.                                   ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 RetIndex("GBN")
Return NIL

Function HspM21Res(cAliasM21, nRegM21, nOpcM21)
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Define as variaveis locais                                            ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 Local bCampo := {|nCPO| Field(nCPO)}
 Local cCampo       := ""
 Local oDlgRes, oGetDados, oBtn01
 Local aCpoEnchoice := {}
 Local nOpcA := 0
 Local cX3_Usado := ""
 Local nCntFor := 0, nCnt := 0
  
 Private aTela[0][0]
 Private aGets[0]
 Private aCols     := {}
 Private aHeader   := {}
 Private nUsadoDic := 0, nUsadoGcz := 0, nGczNrSeqG := 0, nGczRegAte := 0, nGczNome := 0, nGczNumOrc := 0
 Private nTotCaixa := 0, nTotCance := 0
 Private M_Pag     := 01
 
 aAdd(aHeader, {" ", "cLegenda", "@BMP",  1 , 0, ".F.", "", "C", "xxx", "V", "", ""})
 nUsadoGcz++
 nUsadoDic++
 
 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("GCZ")           
 While !Eof() .and. SX3->X3_ARQUIVO == "GCZ"
  If AllTrim(SX3->X3_CAMPO) $ "GCZ_REGATE/GCZ_NRSEQG/GCZ_REGGER/GCZ_NOME  /GCZ_CODCON/GCZ_CODPLA/GCZ_DESPLA/GCZ_DATSTA/GCZ_DATFAT/GCZ_ATENDI/GCZ_NUMORC"
   cX3_Usado  := SX3->X3_USADO
   cX3_Reserv := SX3->X3_RESERV
   nUsadoGcz++
   nUsadoDic++
   aAdd(aHeader, {Trim(X3Titulo()),;
                  SX3->X3_CAMPO,;
                  SX3->X3_PICTURE,;
                  SX3->X3_TAMANHO,;
                  SX3->X3_DECIMAL,;           
                  SX3->X3_VALID,;
                  SX3->X3_USADO,;
                  SX3->X3_TIPO,;
                  SX3->X3_ARQUIVO,;
                  SX3->X3_CONTEXT,;
                  SX3->X3_RELACAO,;
                  SX3->X3_RESERV})
  EndIf
  DbSkip()
 End                               
 
 aAdd(aHeader, {STR0011, "nTotDir" , "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Hon.Direto"
 nTmpTotDir := Len(aHeader) // 1
 nUsadoGcz++
 aAdd(aHeader, {STR0012, "nTotRep" , "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Hon.Repasse"
 nTmpTotRep := Len(aHeader) // 2
 nUsadoGcz++
 aAdd(aHeader, {STR0013, "nTotFil" , "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Filme RX"
 nTmpTotFil := Len(aHeader) // 3
 nUsadoGcz++
 aAdd(aHeader, {STR0014, "nTotRX" , "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Raio X"
 nTmpTotRX  := Len(aHeader) // 4
 nUsadoGcz++
 aAdd(aHeader, {STR0015, "nTotSan", "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Sangue"
 nTmpTotSan := Len(aHeader) // 5
 nUsadoGcz++
 aAdd(aHeader, {STR0016, "nTotExa", "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Exames"
 nTmpTotExa := Len(aHeader) // 6
 nUsadoGcz++
 aAdd(aHeader, {STR0017, "nTotMat", "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Mat/Med"
 nTmpTotMat := Len(aHeader) // 7
 nUsadoGcz++
 aAdd(aHeader, {STR0018, "nTotTax", "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Tax/Dia"
 nTmpTotTax := Len(aHeader) // 8
 nUsadoGcz++
 aAdd(aHeader, {STR0019, "nTotGer", "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Conta"
 nTmpTotGer := Len(aHeader) // 9
 nUsadoGcz++
 aAdd(aHeader, {STR0020, "nTotDes", "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Desconto"
 nTmpTotDes := Len(aHeader) // 10
 nUsadoGcz++
 aAdd(aHeader, {STR0021, "nTotLiq", "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Liquido"
 nTmpTotLiq := Len(aHeader) // 11
 nUsadoGcz++
 aAdd(aHeader, {STR0022, "nTotDev", "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Devedor"
 nTmpTotDev := Len(aHeader) // 12
 nUsadoGcz++
 aAdd(aHeader, {STR0023, "nTotHon", "@E 999,999,999.99", 12, 2, ".F.", cX3_Usado, "N", "xxx", "V", "", cX3_Reserv}) //"Tot.Honorario"
 nTmpTotHon := Len(aHeader) // 13
 nUsadoGcz++
 
 nGczRegAte := aScan(aHeader, {|aVet| AllTrim(Upper(aVet[2])) == "GCZ_REGATE"})
 nGczNrSeqG := aScan(aHeader, {|aVet| AllTrim(Upper(aVet[2])) == "GCZ_NRSEQG"})
 nGczNome   := aScan(aHeader, {|aVet| AllTrim(Upper(aVet[2])) == "GCZ_NOME"  })
 nGczCodCon := aScan(aHeader, {|aVet| AllTrim(Upper(aVet[2])) == "GCZ_CODCON"})
 nGczCodPla := aScan(aHeader, {|aVet| AllTrim(Upper(aVet[2])) == "GCZ_CODPLA"})
 nGczDesPla := aScan(aHeader, {|aVet| AllTrim(Upper(aVet[2])) == "GCZ_DESPLA"})
 nGczNumOrc := aScan(aHeader, {|aVet| AllTrim(Upper(aVet[2])) == "GCZ_NUMORC"})
  
 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Cria Variaveis de Memoria da Enchoice                                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 DbSelectArea("SX3")
 DbSetOrder(1)
 DbSeek("GBN")
 While !Eof() .And. (x3_arquivo == "GBN")
  If X3USO(SX3->X3_USADO) .And. cNivel >= SX3->X3_NIVEL .And. IIf(Inclui, !(SX3->X3_CAMPO $ "GBN_NRORES"), .T.)
   AADD(aCpoEnchoice, SX3->X3_CAMPO)
  Endif
  cCampo  := "M->" + SX3->X3_CAMPO
  &cCampo := CriaVar(SX3->X3_CAMPO) // executa x3_relacao
  dbSkip()
 End        
 
 DbSelectArea("GBN")
 If !Inclui // se nao for inclusao
  For nCntFor := 1 TO FCount()
   M->&(EVAL(bCampo, nCntFor)) := FieldGet(nCntFor)
  Next
  
  FS_BuscaCnt(M->GBN_NRORES, M->GBN_CODLOC, M->GBN_DATRES, M->GBN_ATENDE, Inclui)
 EndIf
    
 If nOpcM21 <> 4
  DEFINE MSDIALOG oDlgRes TITLE cCadastro FROM 0,0 TO 600,850 PIXEL
   EnChoice("GBN",,  nOpcM21,,,, aCpoEnchoice, {015, 000, 070, 426},, 3,,,,,, Inclui)
   oBtn01 := tButton():New(074, 002, STR0008, oDlgRes, {||FS_BuscaCnt(M->GBN_NRORES, M->GBN_CODLOC, M->GBN_DATRES, M->GBN_ATENDE, Inclui)}, 050, 014,,,, .T.)  // "Filtrar"
   If !Inclui
    oBtn01:Disable()
   EndIf 
   @ 078, 058 Say OemToAnsi(STR0009) of oDlgRes Pixel  //"Total do Caixa"
   @ 075, 098 MSGET oTotCaixa VAR nTotCaixa PICTURE "@E 999,999,999.99" SIZE 50, 10 OF oDlgRes PIXEL COLOR CLR_BLACK WHEN .F.
   oGetDados := HS_MultiL(092, 0, 302, 426, .F., .T., /*cLinhaOk*/, 2, /*cFieldOk*/)
   If Inclui
    aCols := {}
   EndIf                          
   
   @ 078, 154 BitMap NAME "BR_AMARELO"   SIZE 8, 8 NOBORDER Of oDlgRes PIXEL
   @ 078, 164 Say "Conta sem orçamento"  Of oDlgRes PIXEL                                                      
   
   @ 078, 224 BitMap NAME "BR_VERMELHO"  SIZE 8, 8 NOBORDER Of oDlgRes PIXEL
   @ 078, 234 Say "Venda não finalizada" Of oDlgRes PIXEL
   
   @ 078, 294 BitMap NAME "BR_VERDE"     SIZE 8, 8 NOBORDER Of oDlgRes PIXEL
   @ 078, 304 Say "Venda finalizada"     Of oDlgRes PIXEL
   
   @ 078, 364 BitMap NAME "BR_PRETO"     SIZE 8, 8 NOBORDER Of oDlgRes PIXEL
   @ 078, 374 Say "Venda cancelada"      Of oDlgRes PIXEL
  ACTIVATE MSDIALOG oDlgRes CENTERED ON INIT EnchoiceBar(oDlgRes, {|| nOpcA := 1, IIf(nOpcM21 == 5 .Or. Obrigatorio(aGets, aTela), oDlgRes:End(), nOpcA := 0)}, ;
                                                                  {|| nOpcA := 0, oDlgRes:End()})
 
  If nOpcA == 1
   Begin Transaction
    If nOpcM21 == 3 // Fechamento
     DbSelectArea("GBN")   
     If Inclui
      M->GBN_NRORES := HS_VSxeNum("GBN", "M->GBN_NRORES", 1)
      ConfirmSx8()
     EndIf        
      
     RecLock("GBN", Inclui)
      HS_GrvCpo("GBN")
      GBN->GBN_NRORES := M->GBN_NRORES
      GBN->GBN_FILIAL := xFilial("GBN")
      GBN->GBN_LOGARQ := HS_LogArq()
     MsUnLock()     
      
     For nCnt := 1 To Len(aCols)
      DbSelectArea("GCZ") 
      DbSetOrder(1)
      DbSeek(xFilial("GCZ") + aCols[nCnt, nGczNrSeqG])
      If Found()                       
       RecLock("GCZ", .F.)
       GCZ->GCZ_NRORES := M->GBN_NRORES
       MsUnLock()
      EndIf
     Next        
     DbSelectArea("GBN") 
     HspM21Imp() 
    ElseIf nOpcM21 == 5 // Exclusão
     DbSelectArea("GBN")
     RecLock("GBN", .F.)
     DbDelete()
     MsUnLock()
     
     For nCnt := 1 To Len(aCols)
      DbSelectArea("GCZ") 
      DbSetOrder(1)
      DbSeek(xFilial("GCZ") + aCols[nCnt, nGczNrSeqG])
      If Found()
       RecLock("GCZ", .F.)
        GCZ->GCZ_NRORES := Space(Len(GCZ->GCZ_NRORES))
       MsUnLock()
      EndIf
     Next    
     DbSelectArea("GBN")
    ElseIf nOpcM21 == 6 // Acerto
     For nCnt := 1 To Len(aCols)
      If aCols[nCnt, nUsadoGcz + 1]
       DbSelectArea("GCZ") 
       DbSetOrder(1)
       DbSeek(xFilial("GCZ") + aCols[nCnt, nGczNrSeqG])
       If Found()
        RecLock("GCZ", .F.)
        GCZ->GCZ_NRORES := Space(Len(GCZ->GCZ_NRORES))
        MsUnLock()
       EndIf
      EndIf 
     Next    
     DbSelectArea("GBN") 
     HspM21Imp() 
    EndIf 
   End Transaction
  EndIf
 Else
  HspM21Imp() 
 EndIf 
Return(.T.)                                                      

Function HspM21Imp()
 Local cAliasOld  := Alias()
 Local cTamanho   := "P"     // P/M/G
 Local cTitulo    := STR0010 + M->GBN_NRORES //"Fechamento de Caixa Nro."
 Local cNomeRel   := "HSPAHM21"
 Local cDrive     := "Epson.drv"
 Local cNomeImp   := "LPT1"
 Local cAlias     := "GBN"
 Local LServer    := .t.
 Local cNaoMostra := .f.
 Local tValBruto  := 0
 Local tValDesco  := 0
 Local tValLiqui  := 0
 Local tValDeved  := 0
 Local tValHonor  := 0
 Local gValBruto  := 0
 Local gValDesco  := 0
 Local gValLiqui  := 0
 Local gValDeved  := 0
 Local gValHonor  := 0
 Local tVCaBruto  := 0
 Local tVCaDesco  := 0
 Local tVCaLiqui  := 0
 Local tVCaDeved  := 0
 Local tVCaHonor  := 0
 Local gVCaBruto  := 0
 Local gVCaDesco  := 0
 Local gVCaLiqui  := 0
 Local gVCaDeved  := 0
 Local gVCaHonor  := 0
 Local nAtend 	   := 0
 Local cCodPla    := 0
 
 // Parametros da SetPrint
 // 15 cDrive
 // 16 passa .t. p/ nao chamar tela
 // 17 lserver = .t., imprime no servidor
 // 18 LPT1
 Local nLin := 0
  
 Private aReturn   := {STR0002, 2, STR0003, 1, 4, "LPT1", "", 1} //"Zebrado"###"Administracao"
 Private nCaracter := 18
 Private Limite    := 80      // 80/132/220
 Private aOrdem    := {}      // Ordem do Relatorio
 Private cNomProg  := "HSPAHM21"
 Private cString1  := ""
 Private nLastKey  := 0
 
 DbSelectArea("GBN")
                        
 cNomeRel := SetPrint(cAlias, cNomeRel, nil, @cTitulo, "", "", "", .F., "", .F., cTamanho, nil, nil, nil /*, cDRive, cNaoMostra, LServer, cNomeImp*/)

 If nLastKey == 27
  DbClearFilter()
  Return(Nil)
 Endif
  
 SetDefault(aReturn, cAlias)

 Set Printer to &cNomeRel
 Set Printer On
 Set Device  to Printer          
                         
 nLin := 60
 SETPRC(0,0)
 //@ 0000, 0000 PSAY CHR(18)
 
 cCodPla := "XXXXXX"
 gValBruto  := 0
 gValDesco  := 0
 gValLiqui  := 0
 gValDeved  := 0
 gValHonor  := 0
 
 aSort(aCols,,, {|X, Y| X[nGczCodPla] + X[nGczNrSeqG] < Y[nGczCodPla] + Y[nGczNrSeqG]}) 
 
 For nAtend :=  1 To Len(aCols)
  If nLin >= 60
    nLin := 0
    nLin := Cabec(cTitulo, "", "", cNomProg, cTamanho, nCaracter) + 1
    @ nLin, 000 PSay STR0024 + DToC(M->GBN_DATRES) + STR0025 + M->GBN_HORRES + ; //"Fechamento "###"   Horas "
                     STR0026 + M->GBN_ATENDE //"   Caixa "
                     
    nLin++
    @ nLin, 000 PSay STR0027 + M->GBN_NOMLOC //"Recepcao "
    nLin++
    @ nLin, 000 PSay Replicate("-", Limite)
    nLin++           
                              // 123456 123456789012345678 999,999.99 999,999.99 999,999.99 999,999.99 999,999.99                                                 
                              //          1         2         3         4         5         6         7         8
                              // 12345678901234567890123456789012345678901234567890123456789012345678901234567890
    @ nLin, 000 PSay STR0028  //"NrGuia Orcam. Paciente    Val. Bruto Val. Desc. Val. Liqu. Val.Deved. Val. Honor"
    nLin++
    @ nLin, 000 PSay Replicate("-", Limite)
  EndIf                                      
  
  If aCols[nAtend, nGczCodPla] # cCodPla
   cCodPla := aCols[nAtend, nGczCodPla]
   tValBruto := 0
   tValDesco := 0
   tValLiqui := 0
   tValDeved := 0
   tValHonor := 0
   
   tVCaBruto := 0
   tVCaDesco := 0
   tVCaLiqui := 0
   tVCaDeved := 0
   tVCaHonor := 0
   nLin++
   nLin++
   @ nLin, 000 PSay Chr(15) + Chr(14) + aCols[nAtend, nGczCodPla] + " - " + aCols[nAtend, nGczDesPla] + Chr(20) + Chr(18) 
   nLin++
  EndIf                                                                        
  
  DbSelectArea("GCZ")
  DbSetOrder(1)
  DbSeek(xFilial("GCZ") + aCols[nAtend, nGczNrSeqG])   
  
  nLin++
  @ nLin, 000 PSay PadR     (aCols[nAtend, nGczNrSeqG   ], 06)              + " " + ;
                   PadR     (aCols[nAtend, nGczNumOrc   ], 06)              + " " + ;
                   PadR     (IIf(aCols[nAtend, 1] == "BR_PRETO", "@", IIf(aCols[nAtend, 1] == "BR_VERMELHO", "*", "")) + aCols[nAtend, nGczNome], 11) + " " + ;
                   Transform(aCols[nAtend, nTmpTotGer], "@E 999,999.99") + " " + ;
                   Transform(aCols[nAtend, nTmpTotDes], "@E 999,999.99") + " " + ;
                   Transform(aCols[nAtend, nTmpTotLiq], "@E 999,999.99") + " " + ;
                   Transform(aCols[nAtend, nTmpTotDev], "@E 999,999.99") + " " + ;
                   Transform(aCols[nAtend, nTmpTotHon], "@E 999,999.99")
  
  If aCols[nAtend, 1] == "BR_PRETO"       
   tVCaBruto += aCols[nAtend, nTmpTotGer] 
   tVCaDesco += aCols[nAtend, nTmpTotDes] 
   tVCaLiqui += aCols[nAtend, nTmpTotLiq] 
   tVCaDeved += aCols[nAtend, nTmpTotDev] 
   tVCaHonor += aCols[nAtend, nTmpTotHon] 
  
   gVCaBruto += aCols[nAtend, nTmpTotGer] 
   gVCaDesco += aCols[nAtend, nTmpTotDes] 
   gVCaLiqui += aCols[nAtend, nTmpTotLiq] 
   gVCaDeved += aCols[nAtend, nTmpTotDev] 
   gVCaHonor += aCols[nAtend, nTmpTotHon] 
  Else
   tValBruto += aCols[nAtend, nTmpTotGer] 
   tValDesco += aCols[nAtend, nTmpTotDes] 
   tValLiqui += aCols[nAtend, nTmpTotLiq] 
   tValDeved += aCols[nAtend, nTmpTotDev] 
   tValHonor += aCols[nAtend, nTmpTotHon] 
  
   gValBruto += aCols[nAtend, nTmpTotGer] 
   gValDesco += aCols[nAtend, nTmpTotDes] 
   gValLiqui += aCols[nAtend, nTmpTotLiq] 
   gValDeved += aCols[nAtend, nTmpTotDev] 
   gValHonor += aCols[nAtend, nTmpTotHon] 
  EndIf 
  
  If nAtend == Len(aCols) .Or. aCols[nAtend + 1, nGczCodPla] # cCodPla
   nLin++
   @ nLin, 000 PSay Replicate("-", Limite)                                
   nLin++
   @ nLin, 000 PSay PadR(STR0029, 25)         + " " + ; //"Total do plano"
                    Transform(tValBruto, "@E 999,999.99") + " " + ;
                    Transform(tValDesco, "@E 999,999.99") + " " + ;
                    Transform(tValLiqui, "@E 999,999.99") + " " + ;
                    Transform(tValDeved, "@E 999,999.99") + " " + ;
                    Transform(tValHonor, "@E 999,999.99")
   nLin++
   @ nLin, 000 PSay PadR(STR0029 + " cancelado", 25)      + " " + ;
                    Transform(tVCaBruto, "@E 999,999.99") + " " + ;
                    Transform(tVCaDesco, "@E 999,999.99") + " " + ;
                    Transform(tVCaLiqui, "@E 999,999.99") + " " + ;
                    Transform(tVCaDeved, "@E 999,999.99") + " " + ;
                    Transform(tVCaHonor, "@E 999,999.99")
   nLin++
   @ nLin, 000 PSay Replicate("-", Limite)  
   nLin++
  EndIf 
 Next    
 
 nLin++
 @ nLin, 000 PSay Replicate("-", Limite)                                
 nLin++
 @ nLin, 000 PSay PadR(STR0030, 25)            + " " + ; //"Total Geral"
                  Transform(gValBruto, "@E 999,999.99") + " " + ;
                  Transform(gValDesco, "@E 999,999.99") + " " + ;
                  Transform(gValLiqui, "@E 999,999.99") + " " + ;
                  Transform(gValDeved, "@E 999,999.99") + " " + ;
                  Transform(gValHonor, "@E 999,999.99")
 nLin++
 @ nLin, 000 PSay PadR(STR0030 + " cancelado", 25)      + " " + ;
                  Transform(gVCaBruto, "@E 999,999.99") + " " + ;
                  Transform(gVCaDesco, "@E 999,999.99") + " " + ;
                  Transform(gVCaLiqui, "@E 999,999.99") + " " + ;
                  Transform(gVCaDeved, "@E 999,999.99") + " " + ;
                  Transform(gVCaHonor, "@E 999,999.99")                  
 nLin++
 @ nLin, 000 PSay Replicate("-", Limite)  
 nLin++                                  
  
 Ms_Flush()              
  
 Set Printer to
 Set Device  to Screen

 If aReturn[5] == 1
  OurSpool(cNomeRel)
 EndIf
 
 DbSelectArea(cAliasOld)
Return(.T.)                                                      

Function HS_VldM21(nVld)
 Local lRet := .T.
 If nVld == 1 // GBN_CodLoc
  lRet := HS_SeekRet("GCS","M->GBN_CODLOC",1,.f.,"GBN_NOMLOC","GCS_NOMLOC", STR0006, .F.)
 EndIf 
Return(lRet)

Static Function FS_BuscaCnt(cNroRes, cCodLoc, cDatRes, cAtende, lInc)
 Local cAliasOld := Alias()
 Local nField := 0, lRet := .T.
 Local aTotAte := {}       
 Local IncluiOld := Inclui
 Local AlteraOld := Altera
 Local cSqlRes := ""
 
 cSqlRes := "SELECT "
 cSqlRes += "GCY.GCY_DATATE, GCY.GCY_CODLOC, GCY.GCY_ATENDE, GCY.GCY_TPALTA, "
 cSqlRes += "GCZ.GCZ_REGATE, GCZ.GCZ_REGGER, GCZ.GCZ_NOME, GCZ.GCZ_CODCON, GCZ.GCZ_DATSTA, GCZ.GCZ_DATFAT, GCZ.GCZ_ATENDI, "
 cSqlRes += "GCZ.GCZ_NUMORC, GCZ.GCZ_NRORES, GCZ.GCZ_NRNOTA, GCZ.GCZ_CODPLA, GCZ.GCZ_VALPAG, GCZ.GCZ_NRSEQG, GCZ.GCZ_STATUS, "
 cSqlRes += "GCZ.GCZ_VLGUIA, GCM.GCM_DESPLA GCZ_DESPLA, "
 cSqlRes += "GA9.GA9_TIPCON " 
 cSqlRes += "FROM " + RetSqlName("GCZ") + " GCZ "
 cSqlRes += "JOIN " + RetSqlName("GCY") + " GCY "
 cSqlRes +=   "ON GCY.GCY_FILIAL = '" + xFilial("GCY") + "' AND GCY.D_E_L_E_T_ <> '*' AND GCY.GCY_REGATE = GCZ.GCZ_REGATE AND "
 cSqlRes +=      "GCY.GCY_CODLOC = '" + cCodLoc + "' AND GCY.GCY_DATATE = '" + DToS(cDatRes) + "' AND UPPER(GCY.GCY_ATENDE) = '" + UPPER(cAtende) + "' "
 cSqlRes += "JOIN " + RetSqlName("GCM") + " GCM "
 cSqlRes +=   "ON GCM.GCM_FILIAL = '" + xFilial("GCM") + "' AND GCM.D_E_L_E_T_ <> '*' AND GCM.GCM_CODCON = GCZ.GCZ_CODCON AND GCM.GCM_CODPLA = GCZ.GCZ_CODPLA "
 cSqlRes += "JOIN " + RetSqlName("GA9") + " GA9 "
 cSqlRes +=   "ON GA9.GA9_FILIAL = '" + xFilial("GA9") + "' AND GA9.D_E_L_E_T_ <> '*' AND GA9.GA9_CODCON = GCZ.GCZ_CODCON "
 cSqlRes += "WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND "
  
 If !lInc
  cSqlRes += "GCZ.GCZ_NRORES = '" + cNroRes + "' "
 Else
  cSqlRes += "GCZ.GCZ_NRORES = '" + Space(Len(cNroRes)) + "' "
 EndIf
                                   
 cSqlRes := ChangeQuery(cSqlRes)
 
 TCQuery cSqlRes New Alias "TMPGCZ"
 
 For nField := 1 To Len(aHeader)
  If aHeader[nField, 10] <> "V" .And. aHeader[nField, 08] $ "D/N"
  	TCSetField("TMPGCZ", aHeader[nField, 02], aHeader[nField, 08], aHeader[nField, 04], aHeader[nField, 05])
  EndIf
 Next
 
 Inclui := .F.
 Altera := .T.
 
 aCols     := {}
 nTotCaixa := 0
 
 While !Eof()
 
  DbSelectArea("TMPGCZ")
                      
  AADD(aCols, Array(nUsadoGcz + 1))
  For nField := 1 to nUsadoDic
   If nField == 1 
    If TMPGCZ->GCY_TPALTA == "99"                  
     aCols[Len(aCols), nField] := "BR_PRETO"
    Else
     If !Empty(TMPGCZ->GCZ_NUMORC) .And. !Empty(TMPGCZ->GCZ_NRNOTA)
      aCols[Len(aCols), nField] := "BR_VERDE"
     ElseIf !Empty(TMPGCZ->GCZ_NUMORC) .And. Empty(TMPGCZ->GCZ_NRNOTA)     
      aCols[Len(aCols), nField] := "BR_VERMELHO"
     Else                                       
      aCols[Len(aCols), nField] := "BR_AMARELO"
     EndIf
    EndIf 
   Else
    aCols[Len(aCols), nField] := FieldGet(FieldPos(aHeader[nField, 2]))//If(aHeader[nField, 10] # "V", FieldGet(FieldPos(aHeader[nField, 2])), CriaVar(aHeader[nField, 2]))
   EndIf 
  Next          
   
  aTotAte := HS_RValAte(TMPGCZ->GCZ_REGATE, TMPGCZ->GCZ_NRSEQG, IIf(TMPGCZ->GCZ_STATUS <= "1", "P", "F"))
                                   
  aCols[Len(aCols), nTmpTotDir] := aTotAte[01]
  aCols[Len(aCols), nTmpTotRep] := aTotAte[02]
  aCols[Len(aCols), nTmpTotFil] := aTotAte[03]
  aCols[Len(aCols), nTmpTotRX ] := aTotAte[04]
  aCols[Len(aCols), nTmpTotSan] := aTotAte[05]
  aCols[Len(aCols), nTmpTotExa] := aTotAte[06]
  aCols[Len(aCols), nTmpTotMat] := aTotAte[07]
  aCols[Len(aCols), nTmpTotTax] := aTotAte[08]                                 
  aCols[Len(aCols), nTmpTotGer] := aTotAte[09] //+ aTotAte[10] Verificar porque o valor do desconto esta sendo retirado do total geral
  aCols[Len(aCols), nTmpTotDes] := aTotAte[10]
  
  If TMPGCZ->GA9_TIPCON == "1"
   aCols[Len(aCols), nTmpTotLiq] := TMPGCZ->GCZ_VLGUIA
  Else
   aCols[Len(aCols), nTmpTotLiq] := 0 
  EndIf
    
  If TMPGCZ->GCY_TPALTA # "99"
   nTotCaixa += aCols[Len(aCols), nTmpTotLiq]
  Else 
   nTotCance += aCols[Len(aCols), nTmpTotLiq]
  EndIf 
  
  If TMPGCZ->GA9_TIPCON == "0"
   aCols[Len(aCols), nTmpTotDev] := (aTotAte[09] - aTotAte[10])
  Else
   aCols[Len(aCols), nTmpTotDev] := 0
  EndIf                                            
  
  aCols[Len(aCols), nTmpTotHon] := aTotAte[11]
                                                                     
  aCols[Len(aCols), nUsadoGcz + 1] := .F.
  
  DbSelectArea("TMPGCZ")
  DbSkip()                    
 End
 
 DbSelectArea("TMPGCZ")
 DbCloseArea()
 DbSelectArea(cAliasOld)
 
 If Len(aCols) == 0
  MsgStop(STR0007 + " - " + POSICIONE("GCS", 1, XFILIAL("GCS") + cCodLoc, "GCS_NOMLOC"))
  lRet := .F.
 EndIf
  
 Inclui := IncluiOld
 Altera := AlteraOld
Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³  HS_RValAte   ³ Autor ³ José Orfeu       ³ Data ³03/02/02  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³  Calcula Total da Conta do Paciente                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³  Gestao Hospitalar                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±± Retorno   ³ aTotAten := {0, ; // 1-Total de Honorarios Direto           ±±
±±           ³              0, ; // 2-Total de Honorarios Repasse          ±±
±±           ³              0, ; // 3-Total de Filmes para Raio X          ±±
±±           ³              0, ; // 4-Total de Raio X                      ±±
±±           ³              0, ; // 5-Total de Sangue                      ±±
±±           ³              0, ; // 6-Total de Procedimentos / Exames      ±±
±±           ³              0, ; // 7-Total de Mat/Med                     ±±
±±           ³              0, ; // 8-Total de Taxas e Diarias             ±±
±±           ³              0, ; // 9-Total Geral                          ±±
±±           ³              0, ; // 10-Desconto                            ±±
±±           ³              0}   // 11-Pgto Medico                         ±±
±±           ³                                                             ±±
±±           ³ Honorarios, Filmes, Raio X, Sangue e Exames                 ±±
±±           ³ aIProced := {"", ; // 1-Tipo do Procedimento                ±±
±±           ³              "", ; // 2-Codigo do Procedimento              ±±
±±           ³              "", ; // 3-Descrição do Procedimento           ±±
±±           ³               0, ; // 4-Valor do Procedimento com desconto  ±±
±±           ³               0, ; // 5-Valor do Procedimento sem desconto  ±±
±±           ³               0, ; // 6-Quantidade do Procedimento          ±±
±±           ³               0, ; // 7-Valor do Desconto                   ±±
±±           ³               0,}  // 8-Coeficiente de Despesa              ±±
±±           ³                                                             ±±
±±           ³ Materiais e Medicamentos                                    ±±
±±           ³ aIMatMed := {"", ; // 1-Codigo do Material / Medicamento    ±±
±±           ³              "", ; // 2-Descrição do Material / Medicamento ±±
±±           ³               0, ; // 3-Valor do Mat/Med com desconto       ±±
±±           ³               0, ; // 4-Valor do Mat/Med sem desconto       ±±
±±           ³               0, ; // 5-Quantidade do Material / Medicamento±±
±±           ³               0} ; // 6-Valor do Desconto                   ±±
±±           ³                                                             ±±
±±           ³ Taxas e Diarias                                             ±±
±±           ³ aITaxDia := {"", ; // 1-Codigo da Taxa / Diaria             ±±
±±           ³              "", ; // 2-Descrição da Taxa / Diaria          ±±
±±           ³               0, ; // 3-Valor da Taxa / Diaria com desconto ±±
±±           ³               0, ; // 4-Valor da Taxa / Diaria sem desconto ±±
±±           ³               0, ; // 5-Quantidade da Taxa / Diaria         ±±
±±           ³               0} ; // 6-Valor do Desconto                   ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function HS_RValAte(cRegAte, cNrSeqG, cModo, lPDirMed, cStatus)
 Local lStatus	 := ( Valtype(cStatus) == "C" .And. !Empty(cStatus) )
 Local cPArq			 := ""
 Local cAArq	   := ""
 Local tPDirMed	:= 0
 Local aArea	   := GetArea()
 Local cSqlDesp := ""
 Local aTotAten := {0, ; // 01-Total de Honorarios Medicos
                    0, ; // 02-Total de Serviços Hospitalares
                    0, ; // 03-Total de Filmes para Raio X
                    0, ; // 04-Total de Raio X
                    0, ; // 05-Total de Sangue
                    0, ; // 06-Total de Procedimentos / Exames
                    0, ; // 07-Total de Mat/Med
                    0, ; // 08-Total de Taxas e Diarias
                    0, ; // 09-Total Geral
                    0, ; // 10-Total de desconto
                    0}   // 11-Total Pgto Med.
 
 Default cModo    := "P"
 Default lPDirMed := .T.
 
 cPArq := IIf(cModo == "P", "GD5.GD5", "GE5.GE5")
 cAArq := IIf(cModo == "P", "GD5"    , "GE5"    )
 
 cSqlDesp := "SELECT GCZ.GCZ_STATUS, "
 cSqlDesp += cPArq + "_QTDDES QTDDES, " + cPArq + "_DESVAL DESVAL, " + HS_FValDes(cAArq) + " VALTOT "
 cSqlDesp += "FROM " + RetSqlName("GCZ") + " GCZ "
 cSqlDesp += "JOIN " + RetSqlName(cAArq) + " " + cAArq + " "
 cSqlDesp +=   "ON " + cPArq + "_FILIAL = '" + xFilial(cAArq) + "' AND " + cAArq + ".D_E_L_E_T_ <> '*' AND "
 cSqlDesp +=           cPArq + "_NRSEQG = GCZ.GCZ_NRSEQG AND " + cPArq + "_GLODES = '0' "
 cSqlDesp += "WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND "
 cSqlDesp += "GCZ.GCZ_REGATE = '" + cRegAte + "' AND GCZ.GCZ_NRSEQG = '" + cNrSeqG + "' "
 
 If lStatus
  cSqlDesp += "GCZ.GCZ_STATUS IN (" + HS_InSql(cStatus) + ")
 EndIf
 
 cSqlDesp := ChangeQuery(cSqlDesp)
 
 TCQuery cSqlDesp New Alias "TMPDESP"
 
 While !Eof() 	

  aTotAten[07] += TMPDESP->VALTOT
 		
  aTotAten[10] += TMPDESP->QTDDES * TMPDESP->DESVAL
 		
 	DbSkip()
 End
 
 DbCloseArea()
 	
 cPArq := IIf(cModo == "P", "GD6.GD6", "GE6.GE6")
 cAArq := IIf(cModo == "P", "GD6"    , "GE6"    )
 	
 cSqlDesp := "SELECT GCZ.GCZ_STATUS, "
 cSqlDesp += cPArq + "_QTDDES QTDDES, " + cPArq + "_DESVAL DESVAL, " + HS_FValDes(cAArq) + " VALTOT "
 cSqlDesp += "FROM " + RetSqlName("GCZ") + " GCZ "
 cSqlDesp += "JOIN " + RetSqlName(cAArq) + " " + cAArq + " "
 cSqlDesp +=   "ON " + cPArq + "_FILIAL = '" + xFilial(cAArq) + "' AND " + cAArq + ".D_E_L_E_T_ <> '*' AND "
 cSqlDesp +=           cPArq + "_NRSEQG = GCZ.GCZ_NRSEQG AND " + cPArq + "_GLODES = '0' "
 cSqlDesp += "WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND "
 cSqlDesp += "GCZ.GCZ_REGATE = '" + cRegAte + "' AND GCZ.GCZ_NRSEQG = '" + cNrSeqG + "' "
 
 If lStatus
  cSqlDesp += "GCZ.GCZ_STATUS IN (" + HS_InSql(cStatus) + ")
 EndIf
 
 cSqlDesp := ChangeQuery(cSqlDesp)
 
 TCQuery cSqlDesp New Alias "TMPDESP"
  
 While !Eof()
  aTotAten[8] += TMPDESP->VALTOT
 		
  aTotAten[10] += TMPDESP->QTDDES * TMPDESP->DESVAL
 		
		DbSkip()
	End

 DbCloseArea()
 
 cPArq := IIf(cModo == "P", "GD7.GD7", "GE7.GE7")
	cAArq := IIf(cModo == "P", "GD7"    , "GE7"    )
 
 cSqlDesp := "SELECT GCZ.GCZ_STATUS, "
 cSqlDesp += "GA7.GA7_HONORA, GA7.GA7_TIPPRO, "
 cSqlDesp += cPArq + "_QTDDES QTDDES, " + cPArq + "_VFILME VFILME, " + cPArq + "_DESVAL DESVAL, " + HS_FValDes(cAArq) + " VALTOT, "
 cSqlDesp += cPArq + "_VALREP VALREP, " + cPArq + "_PGTMED PGTMED "
 cSqlDesp += "FROM " + RetSqlName("GCZ") + " GCZ "
 cSqlDesp += "JOIN " + RetSqlName(cAArq) + " " + cAArq + " "
 cSqlDesp +=   "ON " + cPArq + "_FILIAL = '" + xFilial(cAArq) + "' AND " + cAArq + ".D_E_L_E_T_ <> '*' AND "
 cSqlDesp +=           cPArq + "_NRSEQG = GCZ.GCZ_NRSEQG AND " + cPArq + "_GLODES = '0' "
 cSqlDesp += "JOIN " + RetSqlName("GA7") + " GA7 "
 cSqlDesp +=   "ON GA7.GA7_FILIAL = '" + xFilial("GA7") + "' AND GA7.D_E_L_E_T_ <> '*' AND GA7.GA7_CODPRO = " + cPArq + "_CODDES "
 cSqlDesp += "WHERE GCZ.GCZ_FILIAL = '" + xFilial("GCZ") + "' AND GCZ.D_E_L_E_T_ <> '*' AND "
 cSqlDesp += "GCZ.GCZ_REGATE = '" + cRegAte + "' AND GCZ.GCZ_NRSEQG = '" + cNrSeqG + "' "
 
 If lStatus
  cSqlDesp += "GCZ.GCZ_STATUS IN (" + HS_InSql(cStatus) + ")
 EndIf
 
 cSqlDesp := ChangeQuery(cSqlDesp)
 
 TCQuery cSqlDesp New Alias "TMPDESP"
  
 While !Eof()
 	
 	If TMPDESP->GA7_HONORA == "1" // Honorarios Médicos
 		aTotAten[1] += TMPDESP->VALTOT
 	Else                      // Serviços Hospitalares
 		aTotAten[2] += TMPDESP->VALTOT
 	Endif
 	
		aTotAten[3] += TMPDESP->QTDDES * TMPDESP->VFILME
 	
 	If     TMPDESP->GA7_TIPPRO == "3" // Raio X e Filme
 		aTotAten[4] += TMPDESP->VALTOT
 	ElseIf TMPDESP->GA7_TIPPRO == "6" // Banco de Sangue
 		aTotAten[5] += TMPDESP->VALTOT
 	Else                          // Procedimentos / Exames
 		aTotAten[6] += TMPDESP->VALTOT
 	Endif
 	
  aTotAten[10] += TMPDESP->QTDDES * TMPDESP->DESVAL
 
 	If TMPDESP->GA7_HONORA == "1"
 		aTotAten[11] += TMPDESP->VALREP         
 			
 		//Acumula pagamento direto 0-Direto
 		tPDirMed += IIf(TMPDESP->PGTMED == "0", TMPDESP->VALREP, 0)
 	EndIf
 	
 	DbSkip()
 End
 
 aTotAten[9] := aTotAten[3] + aTotAten[4] + aTotAten[5] + aTotAten[6] + aTotAten[7] + aTotAten[8]
 
 If !lPDirMed
 	aTotAten[9] -= tPDirMed
 EndIf
 
 DbCloseArea()
 
 RestArea(aArea)
Return(aTotAten)