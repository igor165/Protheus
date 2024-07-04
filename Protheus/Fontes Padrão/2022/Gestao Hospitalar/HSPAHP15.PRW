#INCLUDE "HSPAHP15.ch"
#include "protheus.CH"
#include "colors.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP15  º Autor ³ Manoel             º Data ³  25/04/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualizacao de Precos Brasindice                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function HSPAHP15(cGCA_CodTab)
 ValidPerg()
 If !Pergunte("HSPP15", .T.)
  Return(Nil)
 Endif     
 
 If MsgYesNo(STR0001, STR0002) //"Confirma início da atualização de Preços da Tabela Brasíndice?"###"Atenção"
  Processa({|| FS_GerArqs(cGCA_CodTab)}, STR0003) //"Processando..."
 Endif
return(Nil)      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_GerArqs ³ Autor ³ Manoel Filho        ³ Data ³ 26/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Arquivos de Integracao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Geral do Sistema Hospitalar                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_GerArqs(cGCA_CodTab)
 Local cArqMat := "\Import\Brasindi\Material.txt"
 Local cArqMed := "\Import\Brasindi\Medicam.txt"
 Local cArqSo1 := "\Import\Brasindi\Soluca1.txt"
 Local cArqSo2 := "\Import\Brasindi\Soluca2.txt"
 Local lOkMat  := .F.
 Local lOkMed  := .F.
 Local lOkSo1  := .F.
 Local lOkSo2  := .F.
 Private nMat  := fOpen(cArqMat,0)
 Private nMed  := fOpen(cArqMed,0)
 Private nSo1  := fOpen(cArqSo1,0)
 Private nSo2  := fOpen(cArqSo2,0)
 
 If nMat # -1
  lOkMat := .T.
 Else
  HS_MsgInf(STR0011 + cArqMat, STR0014, STR0015)   //"Arquivo não encontrado "###"Atenção"###"Geração do(s) Arquivo(s) de Integração"
 EndIf

 If nMed # -1
  lOkMed := .t.                                 
 Else
  HS_MsgInf(STR0011 + cArqMed, STR0014, STR0015)    //"Arquivo não encontrado "###"Atenção"###"Geração do(s) Arquivo(s) de Integração"
 EndIf
 
 If nSo1 # -1
  lOkSo1 := .t.                              
 Else
  HS_msgInf(STR0011 + cArqSo1, STR0014, STR0015)    //"Arquivo não encontrado "###"Atenção"###"Geração do(s) Arquivo(s) de Integração"
 EndIf
  
 If nSo2 # -1
  lOkSo2 := .t.                              
 Else
  HS_MsgInf(STR0011 + cArqSo2, STR0014, STR0015)    //"Arquivo não encontrado "###"Atenção"###"Geração do(s) Arquivo(s) de Integração"
 EndIf

 //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
 //³ Inicializa a regua de processamento                                 ³
 //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
 If lOkMat .And. lOkMed .And. lOkSo1 .And. lokSo2
  Processa({|| FS_RecArqs(cGCA_CodTab)}, STR0004) //"Aguarde..."
 Endif
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FS_RecArqs ³  Manoel                     ³ Data ³ 25/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a leitura dos Arq de Integracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FS_RecArqs(cGCA_CodTab)
 Local nGbi_PrcAnt := 0, nSb1_PrcAnt := 0
 Local lAtualizado := .F.
 Local nHandle, cLinha := ""
 Local aCampos := {{STR0012, "C", 12, 00}, ; //"CHAVE"
                   {STR0013, "N", 12, 02}, ; //"VALOR"
                   {"FATDV", "N", 12, 02}, ;
                   {"VAL_C", "N", 12, 02}, ;
                   {"TIPOP", "C", 03, 00}}
    
 cTabela  := CriaTrab(aCampos, .T.)
 cIndice1 := CriaTrab(Nil    , .F.)
 
 DbUseArea(.T., "DBFCDX", cTabela, "TRAB", .F., .F.)
 DbCreateIndex(cIndice1, "CHAVE + TIPOP", {|| CHAVE + TIPOP})
 DbSelectArea("TRAB")
 DbCloseArea()                                        
 
 DbUseArea(.T., "DBFCDX", cTabela, "TRAB", .T., .F.)
 DbSetIndex(cIndice1)
 DbSetOrder(1)

 // Medicamentos
 nTamFileC := fSeek(nMed, 0, 2)
 fSeek(nMed, 0, 0)
 //nTamLinC  := 202
 nTamLinC  := 332
  
 cBufferC  := Space(nTamLinC) 
 nBtLidosC := FREAD(nMed,@cBufferC,nTamLinC) // Leitura da primeira linha do arquivo texto
 lPriVez   := .t. // Le so a primeira linha do Arquivo Item
 
 ProcRegua(Round(nTamFileC / nTamLinC, 1)) // Numero de registros a processar

 While nBtLidosC + 2 >= nTamLinC
  IncProc(STR0005) //"Medicamentos"
  
  //cChave := Substr(cBufferC, 01, 03) + Substr(cBufferC, 44, 05) + Substr(cBufferC, 89, 04)
  cChave  := Substr(cBufferC, 01, 03) + Substr(cBufferC, 44, 05) + Substr(cBufferC, 129, 04)
  //nValor  := Val(Substr(cBufferC, 155, 13)) //Valor Total                            
  nValor  := Val(Substr(cBufferC, 285, 13)) //Valor Total                            
  //nFatDV  := Val(Substr(cBufferC, 168, 04)) //Fator de Divisão
  nFatDV  := Val(Substr(cBufferC, 298, 04)) //Fator de Divisão
  //nVal_C  := Val(Substr(cBufferC, 177, 13)) //Valor Unitario 
  nVal_C  := Val(Substr(cBufferC, 307, 13)) //Valor Unitario 
  //cTpPre  := Substr(cBufferC, 172, 03)      //Tipo do Preço
  cTpPre  := Substr(cBufferC, 302, 03)      //Tipo do Preço
	
  DbSelectArea("TRAB")
  RecLock("TRAB",.t.)
  TRAB->CHAVE := cChave
  TRAB->VALOR := nValor
  TRAB->FATDV := nFatDV
  TRAB->VAL_C := nVal_C
  TRAB->TIPOP := cTpPre
  MsUnlock()
    
  //Posiciona na proxima linha do cabeçalho
  nBtLidosC := FREAD(nMed, @cBufferC, nTamLinC) // Leitura da primeira linha do arquivo texto
 EndDo

 // Materiais
 nTamFileC := fSeek(nMat, 0, 2)
 fSeek(nMat, 0, 0)
 //nTamLinC  := 201
 nTamLinC  := 331
 cBufferC  := Space(nTamLinC) 
 nBtLidosC := FREAD(nMat, @cBufferC, nTamLinC) // Leitura da primeira linha do arquivo texto
 lPriVez   := .t. // Le so a primeira linha do Arquivo Item

 ProcRegua(Round(nTamFileC / nTamLinC, 1)) // Numero de registros a processar

 While nBtLidosC + 2 >= nTamLinC
  IncProc(STR0006) //"Materiais"

  //cChave := Substr(cBufferC, 01, 03) + Substr(cBufferC, 44, 05) + Substr(cBufferC, 89, 04)
  cChave  := Substr(cBufferC, 01, 03) + Substr(cBufferC, 44, 05) + Substr(cBufferC, 129, 04)
  //nValor  := Val(Substr(cBufferC, 155, 13)) //Valor Total                            
  nValor  := Val(Substr(cBufferC, 285, 13)) //Valor Total                            
  //nFatDV  := Val(Substr(cBufferC, 168, 04)) //Fator de Divisão
  nFatDV  := Val(Substr(cBufferC, 298, 04)) //Fator de Divisão
  //nVal_C  := Val(Substr(cBufferC, 177, 13)) //Valor Unitario 
  nVal_C  := Val(Substr(cBufferC, 307, 13)) //Valor Unitario 
  //cTpPre  := Substr(cBufferC, 172, 03)      //Tipo do Preço
  cTpPre  := Substr(cBufferC, 302, 03)      //Tipo do Preço
  
	
  DbSelectArea("TRAB")
  RecLock("TRAB",.t.)
  TRAB->CHAVE := cChave
  TRAB->VALOR := nValor  
  TRAB->FATDV := nFatDV
  TRAB->VAL_C := nVal_C
  TRAB->TIPOP := cTpPre
  MsUnlock()
    
  //Posiciona na proxima linha do cabeçalho
  nBtLidosC := FREAD(nMat, @cBufferC, nTamLinC) // Leitura da primeira linha do arquivo texto
 EndDo

 // Solucoes 1
 nTamFileC := fSeek(nSo1, 0, 2)
 fSeek(nSo1, 0, 0)
 //nTamLinC  := 202
 nTamLinC  := 332
 cBufferC  := Space(nTamLinC) 
 nBtLidosC := FREAD(nSo1, @cBufferC, nTamLinC) // Leitura da primeira linha do arquivo texto
 lPriVez   := .T. // Le so a primeira linha do Arquivo Item

 ProcRegua(Round(nTamFileC / nTamLinC, 1)) // Numero de registros a processar

 While nBtLidosC + 2 >= nTamLinC
  IncProc(STR0007) //"Solucoes"
  
  //cChave := Substr(cBufferC, 01, 03) + Substr(cBufferC, 44, 05) + Substr(cBufferC, 89, 04)
  cChave  := Substr(cBufferC, 01, 03) + Substr(cBufferC, 44, 05) + Substr(cBufferC, 129, 04)
  //nValor  := Val(Substr(cBufferC, 155, 13)) //Valor Total                            
  nValor  := Val(Substr(cBufferC, 285, 13)) //Valor Total                            
  //nFatDV  := Val(Substr(cBufferC, 168, 04)) //Fator de Divisão
  nFatDV  := Val(Substr(cBufferC, 298, 04)) //Fator de Divisão
  //nVal_C  := Val(Substr(cBufferC, 177, 13)) //Valor Unitario 
  nVal_C  := Val(Substr(cBufferC, 307, 13)) //Valor Unitario 
  //cTpPre  := Substr(cBufferC, 172, 03)      //Tipo do Preço
  cTpPre  := Substr(cBufferC, 302, 03)      //Tipo do Preço
	
  DbSelectArea("TRAB")
  RecLock("TRAB",.t.)
  TRAB->CHAVE := cChave
  TRAB->VALOR := nValor  
  TRAB->FATDV := nFatDV
  TRAB->VAL_C := nVal_C
  TRAB->TIPOP := cTpPre
  MsUnlock()
    
  //Posiciona na proxima linha do cabeçalho
  nBtLidosC := FREAD(nSo1, @cBufferC, nTamLinC) // Leitura da primeira linha do arquivo texto
 EndDo

 // Solucoes 2
 nTamFileC := fSeek(nSo2, 0, 2)
 fSeek(nSo2, 0, 0)
 //nTamLinC  := 202
 nTamLinC  := 332
 cBufferC  := Space(nTamLinC) 
 nBtLidosC := fRead(nSo2, @cBufferC, nTamLinC) // Leitura da primeira linha do arquivo texto
 lPriVez   := .T. // Le so a primeira linha do Arquivo Item

 ProcRegua(Round(nTamFileC / nTamLinC, 1)) // Numero de registros a processar

 While nBtLidosC + 2 >= nTamLinC
  IncProc(STR0007) //"Solucoes"

  //cChave := Substr(cBufferC, 01, 03) + Substr(cBufferC, 44, 05) + Substr(cBufferC, 89, 04)
  cChave  := Substr(cBufferC, 01, 03) + Substr(cBufferC, 44, 05) + Substr(cBufferC, 129, 04)
  //nValor  := Val(Substr(cBufferC, 155, 13)) //Valor Total                            
  nValor  := Val(Substr(cBufferC, 285, 13)) //Valor Total                            
  //nFatDV  := Val(Substr(cBufferC, 168, 04)) //Fator de Divisão
  nFatDV  := Val(Substr(cBufferC, 298, 04)) //Fator de Divisão
  //nVal_C  := Val(Substr(cBufferC, 177, 13)) //Valor Unitario 
  nVal_C  := Val(Substr(cBufferC, 307, 13)) //Valor Unitario 
  //cTpPre  := Substr(cBufferC, 172, 03)      //Tipo do Preço
  cTpPre  := Substr(cBufferC, 302, 03)      //Tipo do Preço
	
  DbSelectArea("TRAB")
  If !DbSeek(cChave + cTpPre)
   RecLock("TRAB",.t.)
   TRAB->CHAVE := cChave
   TRAB->VALOR := nValor
   TRAB->VAL_C := nVal_C
   TRAB->FATDV := nFatDV
   TRAB->TIPOP := cTpPre
   MsUnlock()
  EndIf
    
  //Posiciona na proxima linha do cabeçalho
  nBtLidosC := fRead(nSo2, @cBufferC, nTamLinC) // Leitura da primeira linha do arquivo texto
 EndDo

 nHandle := fCreate("BrasIndi.Log", 0) 
 DbSelectArea("GBI")  
 DbSetorder(4)                                   
 DbSeek(xFilial("GBI") + "000/00000/0000", .T.) // Posiciona no primeiro registro com a chave do Brasindice preenchida.
 ProcRegua(RecCount()) // Numero de registros a processar 
 While !Eof()
  IncProc(STR0008 + GBI->GBI_PRODUT) 
  DbSelectArea("SB1")
  DbSetOrder(1)
  DbSeeK(xFilial("SB1") + GBI->GBI_PRODUT)
  If !Found()
   fWrite(nHandle, STR0009 + GBI->GBI_PRODUT + STR0010 + CHR(13) + CHR(10), Len(STR0009 + GBI->GBI_PRODUT + STR0010 + CHR(13) + CHR(10)))
   DbSelectArea("GBI")
   RecLock("GBI", .F.)
   DbDelete()
   MsUnLock()
   DbSkip()
   Loop
  EndIf
  
  DbSelectArea("GBI")
  If Empty(GBI->GBI_CHVBRA) .Or. StrTran(Alltrim(GBI->GBI_CHVBRA), " ", "") == "//"
   DbSkip()
   Loop
  Endif  
      
  cChave := SubStr(GBI->GBI_CHVBRA, 01, 03) + SubStr(GBI->GBI_CHVBRA, 05, 05) + SubStr(GBI->GBI_CHVBRA, 11, 04)
  cTpPre := IIF(GBI->GBI_TPBRAS $ " 0", "PMC", "PFB")
  DbSelectArea("TRAB")
  If DbSeek(cChave + cTpPre)
  /*
  Não pega o valor unitario do BrasIndice direto pq o mesmo não esta arredondado
  esta truncado, por isso esta sendo dividido o valor total pelo fator de divisão brasindice
  */
   nPrc := (TRAB->VALOR / TRAB->FATDV)
   
   If TRAB->TIPOP == "PFB"
    If GBI->GBI_LUCNEG <> 0                     
     nPreco := nPrc + (nPrc * (GBI->GBI_LUCNEG))
    Else   
     nPreco := nPrc + (nPrc * If(GBI->GBI_TIPO == "1", (Mv_Par02/100), (Mv_Par01/100)))
    Endif   
   ElseIf TRAB->TIPOP == "PMC"
    nPreco := nPrc
   Endif
  
   If GBI->GBI_FMTHSP > 0
    nPreco := nPreco * GBI->GBI_FMTHSP
   EndIf                     
   /*                                                      
   If TRAB->FATDV > 1
    nPreco := HS_CValCmp(GBI->GBI_PRODUT, nPreco, "A")
   EndIf 
   */
   If nPreco > 0
    // Atualiza Cadastro de Dados Adicionais de Produtos
    lAtualizado := .F.
	If MV_PAR03 == 2 .Or. MV_PAR03 == 3 // 2-Preço Base ou 3-Ambos
	 nGbi_PrcAnt := GBI->GBI_PRCVUC
	 nSb1_PrcAnt := SB1->B1_PRV1
	 DbSelectArea("GBI")
	 RecLock("GBI", .F.)
	 GBI->GBI_FDVBRA := TRAB->FATDV
	 GBI->GBI_PRCMXA := TRAB->VALOR
	 GBI->GBI_PRCVUC := HS_CValUC(GBI->GBI_PRODUT, nPreco      , "A")
	 GBI->GBI_PRCUNC := HS_CValUC(GBI->GBI_PRODUT, SB1->B1_UPRC, "A")
	 GBI->GBI_ULTABR := dDataBase
	 MsUnlock()
	 
	 // Atualiza Cadastro de Produtos
	 DbSelectArea("SB1")
	 RecLock("SB1",.f.)
     SB1->B1_PRV1 := nPreco
     MsUnlock()
     lAtualizado := .T.
    EndIf 
    
    If cGca_CodTab # Nil .And. (MV_PAR03 == 1 .Or. MV_PAR03 == 3) // 1-Tabela Selecionada 3-Ambos
     DbSelectArea("GCA")
     DbSetOrder(1)
     DbSeek(xFilial("GCA") + cGca_CodTab)
     RecLock("GCA", .F.)
     GCA->GCA_DATATU := DDataBase
     GCA->GCA_LOGARQ := cUserName + " - " + StrZero(Day(dDataBase), 02) + "/" + StrZero(Month(dDataBase), 02) + "/" + Str(Year(dDataBase), 04) + " - " + Time() + "h"
     MsUnLock()
     
     DbSelectArea("GCB")
     DbSetOrder(1)
     DbSeek(xFilial("GCB") + cGca_CodTab + GBI->GBI_PRODUT)
     If MV_PAR04 == 1 .Or. (MV_PAR04 == 2 .And. Found())
      RecLock("GCB", !Found())
      GCB->GCB_FILIAL := xFilial("GCB")
      GCB->GCB_CODTAB := cGca_CodTab
      GCB->GCB_PRODUT := GBI->GBI_PRODUT
      GCB->GCB_PRCVEN := nPreco
      GCB->GCB_PRCVUC := HS_CValUC(GBI->GBI_PRODUT, nPreco, "A")
      GCB->GCB_FATOR  := IIf(GCB->GCB_FATOR > 0, GCB->GCB_FATOR, 0)
      GCB->GCB_ATIVO  := IIf(GBI->GBI_PRODES == "0", "0", "1")
      GCB->GCB_LOGARQ := cUserName + " - " + StrZero(Day(dDataBase), 02) + "/" + StrZero(Month(dDataBase), 02) + "/" + Str(Year(dDataBase), 04) + " - " + Time() + "h"
      MsUnLock()
     EndIf
    EndIf
    
    // Grava registros atualizados
    If lAtualizado
     DbSelectArea("GCC")
     RecLock("GCC", .T.)
     GCC->GCC_FILIAL := xFilial("GCC") 
     GCC->GCC_CHAVE  := cChave    
     GCC->GCC_TIPO   := "BRA"
     GCC->GCC_ROTINA := "HSPAHP15"
	 GCC->GCC_DESCRI := SB1->B1_DESC
	 GCC->GCC_PRODUT := SB1->B1_COD
	 GCC->GCC_DATATU := dDataBase
	 GCC->GCC_VANTUV := nSb1_PrcAnt
	 GCC->GCC_VATUUV := nPreco
	 GCC->GCC_VANTUC := nGbi_PrcAnt
	 GCC->GCC_VATUUC := HS_CValUC(GBI->GBI_PRODUT, nPreco, "A")
	 MsUnlock()
	EndIf 
   Endif    
  Else
   cLinha := STR0016 + GBI->GBI_PRODUT + "-" + SB1->B1_DESC + STR0017 + cChave + STR0018 + cTpPre + CHR(13) + CHR(10) //"Produto "###" não atualizado. Chave-"###" Tipo-"
   fWrite(nHandle, cLinha, Len(cLinha))
  Endif   
      
  DbSelectArea("GBI")
  DbSkip()
 Enddo

/*
 Os arquivos textos deve ser fechado
*/ 
 DbSelectArea("TRAB")
 DbCloseArea()
 fErase(cTabela)
 fErase(cIndice1)
 
 fClose(nMed)
 fClose(nMat)
 fClose(nSo1)
 fClose(nSo2)
 fClose(nHandle)
Return(.T.)

/*
Função   VALIDPERG    
Descrição Verifica e inclui as perguntas no sx1   
*/
Static Function ValidPerg()
 Local j :=0, i:= 0
 _sAlias := Alias()                                                                                                                                              
 dbSelectArea("SX1")
 dbSetOrder(1)
 aRegs :={}
 
 aAdd(aRegs, {"HSPP15", "01", STR0019, "", "", "mv_ch1", "N", 05, 2, 0, "G", "", "mv_par01","", "", "", "", "","", "", "", "", "","", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "S"}) //"% Lucro Materiais   "
 aAdd(aRegs, {"HSPP15", "02", STR0020, "", "", "mv_ch2", "N", 05, 2, 0, "G", "", "mv_par02","", "", "", "", "","", "", "", "", "","", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "S"}) //"% Lucro Medicamentos"
 aAdd(aRegs, {"HSPP15", "03", STR0021, "", "", "mv_ch3", "N", 01, 0, 0, "C", "", "mv_par03", "Tab.Selec.(GCB)", "", "", "", "", "P.Base(SB1/GBI)", "", "", "", "", "Ambos", "", "", "","","","","","", "", "", "", "", "", "", "S"}) //"Atualiza            "
 aAdd(aRegs, {"HSPP15", "04", STR0022, "", "", "mv_ch4", "N", 01, 0, 0, "C", "", "mv_par04","Sim", "", "", "", "","Nao", "", "", "", "","", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "S"}) //"Inclui Itens Novos "
 
 cPerg := aRegs[1,1]

 For i := 1 to Len(aRegs)
  dbSeek(cPerg+aRegs[i,2])
  If !found()
   RecLock("SX1",.T.)
   For j := 1 to FCount()
	If j <= Len(aRegs[i])
     FieldPut(j,aRegs[i,j])
	Endif
   Next
   MsUnlock()		
  EndIf
 Next
 DbSelectArea(_sAlias)
Return(Nil)
