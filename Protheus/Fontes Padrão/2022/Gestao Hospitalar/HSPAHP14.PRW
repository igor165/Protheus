#INCLUDE "HSPAHP14.ch"
#include "protheus.CH"
#include "colors.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP14  º Autor ³ Manoel             º Data ³  24/04/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Criacao do Codigo de Barras 333                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function HSPAHP14()

Define  FONT oFont NAME "Arial" BOLD

cAlias := "SB1"
cCadastro:=STR0001 //"Criacao do Codigo de Barras 333"
                            
nOpca     := 0
cSequen   := Space(4)
M->Codigo := "333"
M->Produt := Space(5)
M->Sequen := "0001"
M->CodBar := Space(13)

DEFINE MSDIALOG oDlg TITLE cCadastro From 9,0 to 24,65	of oMainWnd   
@ 029,008 Say OemToAnsi(STR0002) Size 60,0  PIXEL COLOR CLR_BLUE OF oDlg FONT oFont //"Codigo"
@ 029,056 MSGet o01 var M->Codigo Picture "@E 999"  Size 29,9 PIXEL COLOR CLR_BLACK OF oDlg FONT oFont when .f.
@ 047,008 Say OemToAnsi(STR0003) Size 60,0  PIXEL COLOR CLR_BLUE OF oDlg FONT oFont //"Produto"
@ 047,056 MSGet o02 var M->Produt Picture "@!" Valid HS_Valid(1) F3 "SB1" Size  39,9 PIXEL COLOR CLR_BLACK OF oDlg FONT oFont
@ 065,008 Say OemToAnsi(STR0004) Size 60,0  PIXEL COLOR CLR_BLUE OF oDlg FONT oFont //"Sequencia"
@ 065,056 MSGet o03 var M->Sequen Picture "@E 9999" Valid HS_Valid(2) Size  39,9 PIXEL COLOR CLR_BLACK OF oDlg FONT oFont
@ 083,008 Say OemToAnsi(STR0005) Size 60,0  PIXEL COLOR CLR_BLUE OF oDlg FONT oFont //"Cod Barras"
@ 083,056 MSGet o04 var M->CodBar Picture "@R 999999999999-9" Size  59,9 PIXEL COLOR CLR_BLACK OF oDlg FONT oFont when .f.
ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{||nOpca := 1,oDlg:End()},{|| oDlg:End() })

if nOpca == 1
   GrHSPP14()
endif                                                                       

Return

///////////////////////////////////////////////
Static Function GrHSPP14()

DbSelectArea("SB1")
DbSetOrder(1)
If DbSeek(xFilial("SB1")+M->Produt)
   RecLock("SB1",.F.)                 
   SB1->B1_CODBAR := M->CodBar
   MsUnlock()
Endif   

Return


//////////////////////////////
Static Function HS_VALID(nVar)

If nVar == 1 //Codigo do Produto
                                                                             
   cSequen   := "0001"
   DbSelectArea("SB1")
   DbSetOrder(1)
   DbSeek(xFilial("SB1")+M->Produt)
   DbSelectArea("GBI")
   DbSetOrder(1)
   If !DbSeek(xFilial("GBI")+M->Produt)
      HS_MsgInf(STR0006, STR0007, STR0013) //"Código de Produto Inválido!"###"Atenção"###"Validação dos Campos"
      Return .f.
   Else   
      If GBI->GBI_PRODES == '0'
         HS_MsgInf(STR0008 + Alltrim(SB1->B1_COD) + "-" + Alltrim(SB1->B1_DESC) + STR0009, STR0007, STR0013) //"O Produto "###" está DESATIVADO!"###"Atenção"###"Validação dos Campos"
         Return .f.
      Endif         
   Endif
   
   while .t.           
//      M->CodBar := "333" + M->Produt + cSequen 
      M->CodBar := "333" + StrZero(Val(Subs(M->Produt,1,5)),5) + cSequen 
      if !HS_SeekRet("SB1","M->CodBar",5,.f.,,,,,.t.)
             if !HS_SeekRet("GAP","M->CodBar",1,.f.,,,,,.t.)
                if !HS_SeekRet("GAF","M->CodBar",2,.f.,,,,,.t.)
               M->Sequen := cSequen                                      
               M->CodBar := M->CodBar + FS_DigVer()
               exit
            Else   
               HS_MsgInf(STR0010, STR0007, STR0013) //"Já existe Código de Barras deste Produto no cadastro de KIT's!"###"Atenção"###"Validação dos Campos"
               Return .f.
            Endif
         Else   
            HS_MsgInf(STR0011, STR0007, STR0013) //"Já existe Código de Barras deste Produto no cadastro de Códigos de Barras Secundários!"###"Atenção"###"Validação dos Campos"
            Return .f.
         Endif  
      Else   
         HS_MsgInf(STR0012, STR0007, STR0013) //"Já existe Código de Barras deste Produto no cadastro de Produtos!"###"Atenção"###"Validação dos Campos"
         Return .f.
      Endif
   Enddo
   
ElseIf nVar == 2 //Sequencia do Produto
                   
   M->Sequen := cSequen
   
Endif

Return .t.



Static Functio FS_DigVer()
      
Local i := 0
cCodBar := M->CodBar
nValor  := 0
For i := 1 to 12    
    
    If Mod(i,2) == 0
       nValor := nValor + ( val(Substring(m->CodBar,i,1)) * 3 )
    Else
       nValor := nValor + val(Substring(m->CodBar,i,1))
    Endif   
                            
Next   

If right(Alltrim(str(nValor )),1) == "0"
   cDig := "0"
Else
   nValor_ := Val(Substring(Alltrim(str(nvalor)),Len(Alltrim(str(nvalor)))-1,1)) + 1
   cValor_ := Substring(Alltrim(str(nvalor)),1,Len(Alltrim(str(nvalor)))-2) + str(nValor_,Len(Alltrim(Str(nValor_)))) + "0"
   cDig    := STR(Val(cValor_) - nValor,1)
Endif   

Return(cDig)
