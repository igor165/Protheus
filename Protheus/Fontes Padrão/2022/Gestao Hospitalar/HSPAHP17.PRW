#INCLUDE "HSPAHP17.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP17  º Autor ³ Jose Orfeu         º Data ³  29/10/2003 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualizacao de Precos Unimed-SDS                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP17(cGca_CodTab)
 ValidPerg()
 If !Pergunte("HSPP17", .T.)
  Return(Nil)
 Endif     
 
 If MsgYesNo(STR0001 + " ?", STR0002) //"Confirma início da atualização de Preços "###"Atenção"
  Processa({|| FS_GerArqs(cGca_CodTab)}, STR0003) //"Processando..."
 Endif
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_GerArqs³ Autor ³ Jose Orfeu            ³ Data ³ 29/10/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gera Arquivos de Integracao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Geral do Sistema Hospitalar                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function FS_GerArqs(cGca_CodTab)
 Processa({|| FS_RecArqs(cGca_CodTab)}, STR0004) //"Aguarde..."
Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³FS_RecArqs³    Manoel                     ³ Data ³ 25/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Faz a leitura dos Arq de Integracao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_RecArqs(cGca_CodTab)
 Local cArqMat := "\Import\Unimed\Material.dbf"
 Local cArqSol := "\Import\Unimed\Solucoes.dbf"
 Local lMaterial := .F., lSolucao := .F., nPreco := 0
 Local nHandle := fCreate("Unimed.Log", 0)
 Local nGbi_PrcAnt := 0, nSb1_PrcAnt := 0
 Local lAtualizado := .F.
                
 If !File(cArqMat)
  HS_MsgInf(STR0008 + cArqMat + STR0009, STR0023, STR0024) //"Arquivo "###", não encontrado"###Atenção"###"Leitura dos Arquivos de Integração"
  Return(.F.)
 EndIf
 
 If !File(cArqSol)
  HS_MsgInf(STR0008 + cArqSol + STR0009, STR0023, STR0024) //"Arquivo "###", não encontrado"###Atenção"###"Leitura dos Arquivos de Integração"
  Return(.F.)
 EndIf
  
 DbUseArea(.T., "DBFCDX", cArqMat, "MATERIAL", .F., .F.)    //"MATERIAL"
 DbCreateIndex("MATERIAL", "CODUNI", {|| CODUNI}) //"MATERIAL"
 DbCloseArea()                                        
 
 DbUseArea(.T., "DBFCDX", cArqMat, "MATERIAL", .T., .F.) //"MATERIAL"
 DbSetIndex("MATERIAL") //"MATERIAL"
 DbSetOrder(1)

 DbUseArea(.T., "DBFCDX", cArqSol, "SOLUCOES", .F., .F.)
 DbCreateIndex("SOLUCOES", "CODUNI", {|| CODUNI})
 DbCloseArea()                                        
 
 DbUseArea(.T., "DBFCDX", cArqSol, "SOLUCOES", .T., .F.) //"SOLUCOES"
 DbSetIndex("SOLUCOES") //"SOLUCOES"
 DbSetOrder(1)

 DbSelectArea("GBI")
 DBSetOrder(1)
 DBGoTop()

 While !Eof() 
  IncProc(STR0005) //"Aguarde... Atualizando Medicamentos e Soluções..."
  
  DbSelectArea("SB1")
  DbSetOrder(1)
  DbSeeK(xFilial("SB1") + GBI->GBI_PRODUT)
  If !Found()
   fWrite(nHandle, STR0006 + GBI->GBI_PRODUT + STR0007 + CHR(13) + CHR(10), Len(STR0006 + GBI->GBI_PRODUT + STR0007 + CHR(13) + CHR(10)))
   DbSelectArea("GBI")
   RecLock("GBI", .F.)
   DbDelete()
   MsUnLock()
   DbSkip()
   Loop
  EndIf
  
  If Empty(GBI->GBI_CODUNI) .or. GBI->GBI_CODUNI == '99999999999999' //Preço Informado Pelo Usuário , Pois na Lista de Preços UNIMED Tem Preço, mas não tem Código
   DbSelectArea("GBI")
   DBSkip()
   Loop
  Endif
   
  DbSelectArea("MATERIAL") //"MATERIAL"
  DBSetOrder(1)
  lMaterial := DbSeek(GBI->GBI_CODUNI) 
  If !lMaterial     
   DbSelectArea("SOLUCOES") //"SOLUCOES"
   lSolucao := DbSeek(GBI->GBI_CODUNI)
  EndIf
                                      
  If !lMaterial .And. !lSolucao
   DbSelectArea("GBI")
   DbSkip()
   Loop
  EndIf 
  
  nPreco := IIf(lMaterial, MATERIAL->PRECO + ((MATERIAL->PRECO * MV_PAR01) / 100), ;
                           SOLUCOES->PRECO + ((SOLUCOES->PRECO * MV_PAR02) / 100))
   
  lAtualizado := .F.
  If MV_PAR03 == 2 .Or. MV_PAR03 == 3 // 2-Preço Base ou 3-Ambos
   nGbi_PrcAnt := GBI->GBI_PRCUUC
   nSb1_PrcAnt := SB1->B1_PRV1
   DbSelectArea("GBI")
   RecLock("GBI", .F.)
   GBI->GBI_PRCUUC := HS_CValUC(GBI->GBI_PRODUT, nPreco, "A")
   GBI->GBI_DATAUN := DATE()
   MsUnlock()
   
   DbSelectArea("SB1")   
   RecLock("SB1", .F.)
   SB1->B1_PRV1 := nPreco
   MsUnLock() 
   
   lAtualizado := .T.
  EndIf
  
  If MV_PAR03 == 1 .Or. MV_PAR03 == 3 // 1-Tabela Selecionada ou 3-Ambos
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
   GCC->GCC_CHAVE  := GBI->GBI_CODUNI  
   GCC->GCC_TIPO   := "UNI"
   GCC->GCC_ROTINA := "HSPAHP17"
   GCC->GCC_DESCRI := SB1->B1_DESC
   GCC->GCC_PRODUT := SB1->B1_COD
   GCC->GCC_DATATU := dDataBase
   GCC->GCC_VANTUV := nSb1_PrcAnt
   GCC->GCC_VATUUV := nPreco
   GCC->GCC_VANTUC := nGbi_PrcAnt
   GCC->GCC_VATUUC := HS_CValUC(GBI->GBI_PRODUT, nPreco, "A")
   MsUnlock()
  EndIf 
     
  DbSelectArea("GBI")
  DbSkip()                                               
 Enddo

 DbSelectArea("GBI")
 DBSetOrder(1)
 DbGoTop()
 While !Eof() 
  IncProc(STR0005) //"Aguarde... Atualizando Medicamentos e Soluções..."
  DbSelectArea("SB1")
  DBSetOrder(1)
  If !DbSeek(xFilial("SB1") + GBI->GBI_PRODUT)
   fWrite(nHandle, STR0006 + GBI->GBI_PRODUT + STR0007 + CHR(13) + CHR(10), Len(STR0006 + GBI->GBI_PRODUT + STR0007 + CHR(13) + CHR(10)))
   DbSelectArea("GBI")
   RecLock("GBI", .F.)
   DbDelete()
   MsUnLock()
   DbSkip()
   Loop
  EndIf
        
  If !Empty(GBI->GBI_CODUNI)
   DbSelectArea("GBI")
   DBSkip()
   Loop
  Endif
                             
  nSb1_PrcAnt := SB1->B1_PRV1
  nGbi_PRCUUC := GBI->GBI_PRCUUC
  DbSelectArea("GBI")
  RecLock("GBI",.f.)
  GBI->GBI_PRCUUC := HS_CValUC(GBI->GBI_PRODUT, SB1->B1_PRV1, "A")
  GBI->GBI_DATAUN := DATE()
  MsUnlock() 
  
  DbSelectArea("GCC")
  RecLock("GCC", .T.)
  GCC->GCC_FILIAL := xFilial("GCC") 
  GCC->GCC_CHAVE  := STR0012 //"UNIMED S/PRC"
  GCC->GCC_TIPO   := STR0013 //"UNI"
  GCC->GCC_ROTINA := "HSPAHP17"
  GCC->GCC_DESCRI := SB1->B1_DESC
  GCC->GCC_PRODUT := SB1->B1_COD
  GCC->GCC_DATATU := dDataBase
  GCC->GCC_VANTUV := nSb1_PrcAnt
  GCC->GCC_VATUUV := SB1->B1_PRV1
  GCC->GCC_VANTUC := nGbi_PrcAnt
  GCC->GCC_VATUUC := HS_CValUC(GBI->GBI_PRODUT, SB1->B1_PRV1, "A")
  MsUnlock()
     
  DbSelectArea("GBI")
  DbSkip()
 Enddo
 
 fClose(nHandle)
Return(.T.)

/*-----------------------------------------------------------------------------
	 Função   VALIDPERG    
   Descrição Verifica e inclui as perguntas no sx1   
------------------------------------------------------------------------------*/
Static Function ValidPerg()
 Local j :=0, i:= 0
 _sAlias := Alias()                                                                                                                                              
 dbSelectArea("SX1")
 dbSetOrder(1)
 aRegs :={}
 
 aAdd(aRegs, {"HSPP17", "01", STR0014, "", "", "mv_ch1", "N", 05, 2, 0, "G", "", "mv_par01",                         "", "", "", "", "",       "", "", "", "", "",      "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "S"}) //"% Lucro Materiais   "
 aAdd(aRegs, {"HSPP17", "02", STR0015, "", "", "mv_ch2", "N", 05, 2, 0, "G", "", "mv_par02",                         "", "", "", "", "",       "", "", "", "", "",      "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "S"}) //"% Lucro Solucoes    "
 aAdd(aRegs, {"HSPP17", "03", STR0016, "", "", "mv_ch3", "N", 01, 0, 0, "C", "", "mv_par03", STR0017, "", "", "", "", STR0018, "", "", "", "", STR0019, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "S"}) //"Atualiza            "###"Tab.Selec.(GCB)"###"P.Base(SB1/GBI)"###"Ambos"
 aAdd(aRegs, {"HSPP17", "04", STR0020, "", "", "mv_ch4", "N", 01, 0, 0, "C", "", "mv_par04",             STR0021, "", "", "", "",             STR0022, "", "", "", "",      "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "S"}) //"Inclui Intens Novos "###"Sim"###"Nao"
 
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
