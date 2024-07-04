#include "Protheus.ch"
#include "HSPAHP35.CH"
#include "TopConn.ch" 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ"±±
±±ºPrograma  ³ HSPAHP35 º Autor ³ José Orfeu         º Data ³ 30/10/2003  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Atualizacao das tabelas de precos.                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP35(cGca_CodTab)
 ValidPerg()
 If !Pergunte("HSPP35", .T.)
  Return(.F.)
 Endif     

 If MsgYesNo(STR0001 + cGca_CodTab, STR0002) //"Confirma início da atualização de Preços da Tabela "###"Atenção"
  Processa({|| FS_GerArqs(cGCA_CodTab)}, STR0003 + cGca_CodTab) //"Processando tabela "
 Endif
Return(.T.)

Static Function FS_GerArqs(cGca_CodTab)
 Local nSb1_PrcAnt := 0, nGbi_PrcVUC := 0, nGbi_PrcUUC := 0, lAtualizado := .F.
 Local nHandle := fCreate("BrasIndi.Log", 0) 
 Local nPrcAtu := 0 
 DbSelectArea("GBI")
 DbSetOrder(1)
 DbGoTop()   
 ProcRegua(RecCount())
 While !Eof()         
  IncProc(STR0004 + GBI->GBI_PRODUT)
 
  DbSelectArea("SB1")
  DbSetOrder(1)
  DbSeek(xFilial("SB1") + GBI->GBI_PRODUT)
  If !Found()
   fWrite(nHandle, STR0005 + GBI->GBI_PRODUT + STR0006 + CHR(13) + CHR(10), Len(STR0005 + GBI->GBI_PRODUT + STR0006 + CHR(13) + CHR(10)))
   DbSelectArea("GBI")
   RecLock("GBI", .F.)
   DbDelete()
   MsUnLock()
   DbSkip()
   Loop
  EndIf
  
  If MV_PAR03 == 2 .Or. MV_PAR03 == 3 // 2-Preço Base ou 3-Ambos
   nGbi_PrcVUC := GBI->GBI_PRCVUC
   nGbi_PrcUUC := GBI->GBI_PRCUUC
   nSb1_PrcAnt := SB1->B1_PRV1
   DbSelectArea("GBI")
   RecLock("GBI", .F.)                                                                
   If MV_PAR04 == 1 .Or. MV_PAR04 == 3 // 1-BrasIndice ou 3-Ambos
    GBI->GBI_PRCVUC := GBI->GBI_PRCVUC + ((GBI->GBI_PRCVUC * MV_PAR01) / 100) // BrasIndice
   EndIf                            
   
   If MV_PAR04 == 2 .Or. MV_PAR04 == 3 // 1-Unimed ou 3-Ambos
    GBI->GBI_PRCUUC := GBI->GBI_PRCUUC + ((GBI->GBI_PRCUUC * MV_PAR01) / 100) // Unimed
   EndIf 
   MsUnlock()
	 
   // Atualiza Cadastro de Produtos
   DbSelectArea("SB1")
   RecLock("SB1",.f.)
   SB1->B1_PRV1 := SB1->B1_PRV1 + ((SB1->B1_PRV1 * MV_PAR01) / 100) // Preço Base
   MsUnlock()

   lAtualizado := .T.
  EndIf 
    
  If MV_PAR03 == 1 .Or. MV_PAR03 == 3 // 1-Tabela Selecionada 3-Ambos
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
   If MV_PAR05 == 1 .Or. (MV_PAR05 == 2 .And. Found())
    RecLock("GCB", !Found())
    GCB->GCB_FILIAL := xFilial("GCB")
    GCB->GCB_CODTAB := cGca_CodTab
    GCB->GCB_PRODUT := GBI->GBI_PRODUT
    GCB->GCB_PRCVEN := GCB->GCB_PRCVEN + ((GCB->GCB_PRCVEN * MV_PAR01) / 100)
    GCB->GCB_PRCVUC := GCB->GCB_PRCVUC + ((GCB->GCB_PRCVUC * MV_PAR01) / 100)
    GCB->GCB_FATOR  := IIf(GCB->GCB_FATOR > 0, GCB->GCB_FATOR, 0)
    GCB->GCB_ATIVO  := IIf(GBI->GBI_PRODES == "0", "0", "1")
    GCB->GCB_LOGARQ := cUserName + " - " + StrZero(Day(dDataBase), 02) + "/" + StrZero(Month(dDataBase), 02) + "/" + Str(Year(dDataBase), 04) + " - " + Time() + "h"
    MsUnLock()
   EndIf
  EndIf
    
  // Grava registros atualizados
  If lAtualizado                                                
   For nPrcAtu := 1 To IIf(MV_PAR04 == 3, 2, 1)
    DbSelectArea("GCC")
    RecLock("GCC", .T.)
    GCC->GCC_FILIAL := xFilial("GCC") 
    GCC->GCC_CHAVE  := IIf(MV_PAR04 == 3, IIf(nPrcAtu == 1, GBI->GBI_CODUNI, GBI->GBI_CHVBRA), IIf(MV_PAR04 == 2, GBI->GBI_CODUNI, GBI->GBI_CHVBRA))
    GCC->GCC_TIPO   := IIf(MV_PAR04 == 3, IIf(nPrcAtu == 1,           "UNI",           "BRA"), IIf(MV_PAR04 == 2,           "UNI",           "BRA"))
    GCC->GCC_ROTINA := "HSPAHP35"
    GCC->GCC_DESCRI := SB1->B1_DESC
    GCC->GCC_PRODUT := SB1->B1_COD
    GCC->GCC_DATATU := dDataBase
    GCC->GCC_VANTUV := nSb1_PrcAnt
    GCC->GCC_VATUUV := SB1->B1_PRV1
    GCC->GCC_VANTUC := IIf(nPrcAtu == 1,     nGbi_PrcUUC,     nGbi_PrcVUC)
    GCC->GCC_VATUUC := IIf(nPrcAtu == 1, GBI->GBI_PRCUUC, GBI->GBI_PRCUUC)
    MsUnlock()
   Next 
  EndIf 
  
  DbSelectArea("GBI")
  DbSkip()
 End
 
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
 
 aAdd(aRegs, {"HSPP35", "01", STR0007, "", "", "mv_ch1", "N", 05, 2, 0, "G", "", "mv_par01", "", "", "", "", "",              "", "", "", "", "",      "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "N"}) //"% Lucro Materiais"
 aAdd(aRegs, {"HSPP35", "02", STR0008, "", "", "mv_ch2", "N", 05, 2, 0, "G", "", "mv_par02", "", "", "", "", "",              "", "", "", "", "",      "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "N"}) //"% Lucro Medicamentos"
 aAdd(aRegs, {"HSPP35", "03", STR0009, "", "", "mv_ch3", "N", 01, 0, 0, "C", "", "mv_par03",STR0010, "", "", "", "", STR0011, "", "", "", "", STR0012, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "N"}) //"Atualiza "###"Tab.Selec.(GCB)"###"P.Base(SB1/GBI)"###"Ambos"
 aAdd(aRegs, {"HSPP35", "04", STR0013, "", "", "mv_ch4", "N", 01, 0, 0, "C", "", "mv_par04",STR0014, "", "", "", "", STR0015, "", "", "", "", STR0012, "", "", "", "", "", "", "", "", "", "", "", "", "", "", "N"}) //"Preço Base"###"BrasIndice"###"Unimed"###"Ambos"
 aAdd(aRegs, {"HSPP35", "05", STR0016, "", "", "mv_ch5", "N", 01, 0, 0, "C", "", "mv_par05",STR0017, "", "", "", "", STR0018, "", "", "", "",      "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "N"}) //"Inclui Intens Novos "###"Sim"###"Nao"
 
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
