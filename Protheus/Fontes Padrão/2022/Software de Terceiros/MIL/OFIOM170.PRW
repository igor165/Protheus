#include "Ofiom170.ch"
#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ OFIOM170 ³ Autor ³ Andre                 ³ Data ³ 18/01/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Liberacao de Venda                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM170

Local aIndVO1   := {} // Claudia 
Local aArea     := GetArea() // Claudia             
Private bFiltraBrw := {|| Nil} // claudia
Private cTipAva := "1/2/4"
Private aErrAva  := {}   //Array de formulas incorretas
Private cGruFor  := ""
Private aMemos   := {{"VS6_OBSMEM","VS6_OBSERV"}}
Private aIteRece := {}
Private aIteDesp := {}   
Private aRotina  := MenuDef()
Private cAuxCond := "" // Claudia

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private cCadastro := OemToAnsi(STR0004) //"Liberacao de Venda"
aTipLib  := {OemToAnsi(STR0005),OemToAnsi(STR0006),OemToAnsi(STR0007)} //"Pecas"###"Oficina"###"Veiculo"
cTipLib  := ""
nOpca    := 0

DEFINE FONT oFnt3 NAME "Arial" BOLD

DEFINE MSDIALOG oDlg TITLE OemtoAnsi(STR0008) FROM  02,04 TO 08,28 OF oMainWnd && Tipo de Faturamento //"Tipo de Liberacao"

   @  02, 02 TO 22,091 LABEL OemtoAnsi("") OF oDlg PIXEL
   @  07, 04 MSCOMBOBOX oTipLib VAR cTipLib SIZE 83,50 FONT oFnt3 ITEMS aTipLib OF oDlg PIXEL

   DEFINE SBUTTON FROM 27,26 TYPE 1 ACTION (nOpca := 1,oDlg:End());
   ENABLE OF oDlg
   DEFINE SBUTTON FROM 27,57 TYPE 2 ACTION (nOpca := 2,oDlg:End());
   ENABLE OF oDlg

ACTIVATE MSDIALOG oDlg CENTER

If nOpca == 1
   Do Case
      Case cTipLib == STR0005 //"Pecas"
           cTipLib := "1"
           cGruFor := "04"
      Case cTipLib == STR0006 //"Oficina"
           cTipLib := "2" 
           cGruFor := "06" 
      Case cTipLib == STR0007    //"Veiculo"
           cTipLib := "3"
           cGruFor := "01"  
   EndCase   
Else
  Return .t.
EndIf
   
// Filtro da mBrowse, so deixando aparecer registros nao liberados
cTipLib := Subs(cTipLib,1,1)
//cIndVO1 := CriaTrab(Nil, .F.)
//cChave  := "VS6_FILIAL+VS6_NUMIDE"
cAuxCond   := 'Empty(VS6_DATAUT) .and. VS6_TIPAUT == "' + cTipLib + '"'

//IndRegua("VS6",cIndVO1,cChave,,cCond,OemToAnsi(STR0009) ) //"Liberacao"
//bFiltraBrw := {|| FilBrowse("VS6",@aIndVO1,@cCond) } // claudia
//Eval(bFiltraBrw) // claudia
FilBrowse("VS6",{},cAuxCond)

mBrowse( 6, 1,22,75,"VS6",,,,,,,)
  
dbSelectArea("VS6")       // CLAUDIA
//RetIndex("VS6")           // CLAUDIA
dbClearFilter()           // CLAUDIA
//aEval(aIndVO1,{|x| Ferase(x[1]+OrdBagExt())}) // CLAUDIA
RestArea(aArea)   // CLAUDIA

//RetIndex()
//#IFNDEF TOP
//   If File(cIndVO1+OrdBagExt())
//      fErase(cIndVO1+OrdBagExt())
//   Endif
//#ENDIF

Return


/////////////////////////////////////
Function FS_OFI170(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor := 0
Local i		  := 0	

Private aTELA[0][0], aGETS[0], aHeader[0]

aRotina := {{ " " ," " , 0, 1},;    //Pesquisar
             { " " ," " , 0, 2},;   //Visualizar
             { " " ," " , 0, 3},;   //Incluir
             { " " ," " , 0, 4},;   //Alterar
             { " " ," " , 0, 5} }   //Excluir

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Opcoes de acesso para a Modelo 3                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cTitulo       :=STR0007
cAliasEnchoice:="VS6"
cAliasGetD    :="VS7"
cLinOk        :="AllwaysTrue()"
cTudoOk       :="AllwaysTrue()"
cFieldOk      :="FG_MEMVAR()"

nOpcE:=4
nOpcG:=4
nOpca:=0

lRefresh := .t.
Inclui   := .f.
lVirtual := .f.
nLinhas  := 99

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VS6",.T.)
aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VS6")
While !Eof().and.(x3_arquivo=="VS6")
        If X3USO(x3_usado) .and. cNivel >=x3_nivel .and. !(X3_CAMPO $ "VS6_DATOCO/VS6_HOROCO/VS6_LIBPRO/VS6_DATAUT/VS6_HORAUT/VS6_NUMORC/VS6_TIPAUT/VS6_OBSMEM")
       aAdd(aCpoEnchoice,x3_campo)
	Endif
	wVar := "M->"+x3_campo
	&wVar:= CriaVar(x3_campo)
	DbSkip()
End

If !(Inclui)
	DbSelectArea("VS6")
	For nCntFor := 1 TO FCount()
            M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
	Next
Endif

Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )

If cTipLib == "1" // Pecas

   aColsP:={}
   DbSelectArea("VS7")
   DbSetOrder(1)
   DbSeek(xFilial()+M->VS6_NUMIDE)
   While !eof() .and. M->VS6_NUMIDE == VS7_NUMIDE .and. xFilial("VS7") == VS7_FILIAL
      If VS7_TIPAUT == "1"
         If nOpc == 2
            aAdd(aColsP,{if(VS7_ITELIB=="S",.t.,.f.),VS7_SEQUEN,VS7_GRUITE,VS7_CODITE,Transform(VS7_VALORI,"@E 999,999,999.99"),Transform(VS7_DESPER,"@E 999,999,999.99"),Transform(VS7_VALPER,"@E 999,999,999.99"),Transform(VS7_DESDES,"@E 999,999,999.99"),Transform(VS7_VALDES,"@E 999,999,999.99")})
         Else
            aAdd(aColsP,{.T.,VS7_SEQUEN,VS7_GRUITE,VS7_CODITE,Transform(VS7_VALORI,"@E 999,999,999.99"),Transform(VS7_DESPER,"@E 999,999,999.99"),Transform(VS7_VALPER,"@E 999,999,999.99"),Transform(VS7_DESDES,"@E 999,999,999.99"),Transform(VS7_VALDES,"@E 999,999,999.99")})
         Endif
      Endif
      DbSkip()
   EndDo

   If Len(aColsP) == 0
      aAdd(aColsP,{.F.," "," "," "," "," "," "," "," "})
   Endif

ElseIf cTipLib == "2" // Oficina

    // Pecas
    aColsP := {}
    DbSelectArea("VS7")
    DbSetOrder(1)
    DbSeek(xFilial()+M->VS6_NUMIDE)
    While !eof() .and. M->VS6_NUMIDE == VS7_NUMIDE .and. xFilial("VS7") == VS7_FILIAL
       If VS7_TIPAUT == "1"
          If nOpc == 2
             aAdd(aColsP,{if(VS7_ITELIB=="S",.t.,.f.),VS7_SEQUEN,VS7_GRUITE,VS7_CODITE,Transform(VS7_VALORI,"@E 999,999,999.99"),Transform(VS7_DESPER,"@E 999,999,999.99"),Transform(VS7_VALPER,"@E 999,999,999.99"),Transform(VS7_DESDES,"@E 999,999,999.99"),Transform(VS7_VALDES,"@E 999,999,999.99")})
          Else
             aAdd(aColsP,{.T.,VS7_SEQUEN,VS7_GRUITE,VS7_CODITE,Transform(VS7_VALORI,"@E 999,999,999.99"),Transform(VS7_DESPER,"@E 999,999,999.99"),Transform(VS7_VALPER,"@E 999,999,999.99"),Transform(VS7_DESDES,"@E 999,999,999.99"),Transform(VS7_VALDES,"@E 999,999,999.99")})
          Endif
       EndIf
       DbSkip()
    EndDo

    If Len(aColsP) == 0
       aAdd(aColsP,{.F.," "," "," "," "," "," "," "," "})
    Endif

    aColsS := {}
    DbSelectArea("VS7")
    DbSetOrder(1)
    DbSeek(xFilial()+M->VS6_NUMIDE)
    While !eof() .and. M->VS6_NUMIDE == VS7_NUMIDE .and. xFilial("VS7") == VS7_FILIAL
       If VS7_TIPAUT == "2"
          If nOpc == 2
             aAdd(aColsS,{if(VS7_ITELIB=="S",.t.,.f.),VS7_SEQUEN,VS7_GRUSER,VS7_CODSER,VS7_TIPSER,Transform(VS7_VALORI,"@E 999,999,999.99"),Transform(VS7_DESPER,"@E 999,999,999.99"),Transform(VS7_VALPER,"@E 999,999,999.99"),Transform(VS7_DESDES,"@E 999,999,999.99"),Transform(VS7_VALDES,"@E 999,999,999.99")})
          Else
             aAdd(aColsS,{.T.,VS7_SEQUEN,VS7_GRUSER,VS7_CODSER,VS7_TIPSER,Transform(VS7_VALORI,"@E 999,999,999.99"),Transform(VS7_DESPER,"@E 999,999,999.99"),Transform(VS7_VALPER,"@E 999,999,999.99"),Transform(VS7_DESDES,"@E 999,999,999.99"),Transform(VS7_VALDES,"@E 999,999,999.99")})
         Endif
        Endif
       DbSkip()
    EndDo
    If Len(aColsS) == 0
       aAdd(aColsS,{.F.," "," "," "," "," "," "," "," "," "," "})
    Endif

Elseif cTipLib == "3" // Veiculos

   aColsV:={}
   DbSelectArea("VS7")
   DbSetOrder(1)
   DbSeek(xFilial()+M->VS6_NUMIDE)
   While !eof() .and. M->VS6_NUMIDE == VS7_NUMIDE .and. xFilial("VS7") == VS7_FILIAL
      If VS7_TIPAUT == "3"
         If nOpc == 2
            aAdd(aColsV,{if(VS7_ITELIB=="S",.t.,.f.),VS7_CODITE,Transform(VS7_VALORI,"@E 999,999,999.99"),Transform(VS7_VALPER,"@E 999,999,999.99"),Transform(VS7_VALDES,"@E 999,999,999.99")})
         Else
            aAdd(aColsV,{.T.,VS7_CODITE,Transform(VS7_VALORI,"@E 999,999,999.99"),Transform(VS7_VALPER,"@E 999,999,999.99"),Transform(VS7_VALDES,"@E 999,999,999.99")})
         Endif
      Endif
      DbSkip()
   EndDo

   If Len(aColsV) == 0
      aAdd(aColsV,{.F.," "," "," "," "})
   Endif

Endif

DEFINE MSDIALOG oDlg TITLE cTitulo From 06,15 to 38,105    of oMainWnd

&&nopc:=2
EnChoice("VS6",0,nOpcE,,,,aCpoEnchoice,{13,1,100,355},{"VS6_OBSERV","VS6_OBSMEM"},3,,,,,,lVirtual)

If cTipLib == "1" // Pecas

   //Pecas

   @ 100,001 LISTBOX oLbItens FIELDS HEADER OemToAnsi(""),;
   Alltrim(OemToAnsi(STR0010)),; //"Seq            "
   OemToAnsi("Marca"),; //"Marca          "
   OemToAnsi(STR0011),; //"Grupo          "
   OemToAnsi(STR0012),; //"Codigo da Peca "
   OemToAnsi(STR0013),; //"Valor Original "
   OemToAnsi(STR0014),; //"% Dsc Permitido"
   OemToAnsi(STR0015),; //"Valor Permitido"
   OemToAnsi(STR0016),; //"% Dsc Desejado "
   OemToAnsi(STR0017); //"Valor Desejado "
   COLSIZES 10,10,20,20,55,40,40,40,45,45,45 ;
   SIZE 354,140 OF oDlg ON DBLCLICK((If(nOpc#2,If(aColsP[oLbItens:nAt,1],aColsP[oLbItens:nAt,1]:=.F.,aColsP[oLbItens:nAt,1]:=.T.),IIF(aColsP[oLbItens:nAt,1],oOk,oNo)),.f.)) PIXEL

   oLbItens:SetArray(aColsP)
   oLbItens:bLine := { || {  IIF(aColsP[oLbItens:nAt,1],oOk,oNo) ,;
   Alltrim(aColsP[oLbItens:nAt,2]) ,;
   Posicione("SBM",1,xFilial("SBM")+aColsP[oLbItens:nAt,3],"BM_CODMAR") ,;
   aColsP[oLbItens:nAt,3] ,;
   aColsP[oLbItens:nAt,4] ,;
   aColsP[oLbItens:nAt,5] ,;
   aColsP[oLbItens:nAt,6] ,;
   aColsP[oLbItens:nAt,7] ,;
   aColsP[oLbItens:nAt,8] ,;
   aColsP[oLbItens:nAt,9] }}
	
Elseif cTipLib == "2" // Oficina

   //Pecas

   @ 100,001 LISTBOX oLbItens FIELDS HEADER OemToAnsi(""),;
   Alltrim(OemToAnsi(STR0010)),; //"Seq            "
   OemToAnsi("Marca"),; //"Marca          "
   OemToAnsi(STR0011),; //"Grupo          "
   OemToAnsi(STR0012),; //"Codigo da Peca "
   OemToAnsi(STR0013),; //"Valor Original "
   OemToAnsi(STR0014),; //"% Dsc Permitido"
   OemToAnsi(STR0015),; //"Valor Permitido"
   OemToAnsi(STR0016),; //"% Dsc Desejado "
   OemToAnsi(STR0017); //"Valor Desejado "
   COLSIZES 10,10,20,20,55,40,40,40,45,45,45 ;
   SIZE 354,070 OF oDlg ON DBLCLICK((If(nOpc#2,If(aColsP[oLbItens:nAt,1],aColsP[oLbItens:nAt,1]:=.F.,aColsP[oLbItens:nAt,1]:=.T.),IIF(aColsP[oLbItens:nAt,1],oOk,oNo)),.f.)) PIXEL

   oLbItens:SetArray(aColsP)
   oLbItens:bLine := { || {  IIF(aColsP[oLbItens:nAt,1],oOk,oNo) ,;
   Alltrim(aColsP[oLbItens:nAt,2]) ,;
   Posicione("SBM",1,xFilial("SBM")+aColsP[oLbItens:nAt,3],"BM_CODMAR") ,;
   aColsP[oLbItens:nAt,3] ,;
   aColsP[oLbItens:nAt,4] ,;
   aColsP[oLbItens:nAt,5] ,;
   aColsP[oLbItens:nAt,6] ,;
   aColsP[oLbItens:nAt,7] ,;
   aColsP[oLbItens:nAt,8] ,;
   aColsP[oLbItens:nAt,9] }}

   // Servicos

   @ 171,001 LISTBOX oLbIten2 FIELDS HEADER OemToAnsi(""),;
   Alltrim(OemToAnsi(STR0010)),; //"Seq            "
   OemToAnsi(STR0011),; //"Grupo          "
   OemToAnsi(STR0018),; //"Codigo Servico "
   OemToAnsi(STR0019),; //"Tipo           "
   OemToAnsi(STR0013),; //"Valor Original "
   OemToAnsi(STR0014),; //"% Dsc Permitido"
   OemToAnsi(STR0015),; //"Valor Permitido"
   OemToAnsi(STR0016),; //"% Dsc Desejado "
   OemToAnsi(STR0017); //"Valor Desejado "
   COLSIZES 10,10,20,50,15,40,40,45,45,45 ;
   SIZE 354,070 OF oDlg ON DBLCLICK((If(nOpc#2,If(aColsS[oLbIten2:nAt,1],aColsS[oLbIten2:nAt,1]:=.F.,aColsS[oLbIten2:nAt,1]:=.T.),IIF(aColsS[oLbIten2:nAt,1],oOk,oNo)),.f.)) PIXEL

   oLbIten2:SetArray(aColsS)
   oLbIten2:bLine := { || {  IIF(aColsS[oLbIten2:nAt,1],oOk,oNo) ,;
   aColsS[oLbIten2:nAt,2] ,;
   aColsS[oLbIten2:nAt,3] ,;
   aColsS[oLbIten2:nAt,4] ,;
   aColsS[oLbIten2:nAt,5] ,;
   aColsS[oLbIten2:nAt,6] ,;
   aColsS[oLbIten2:nAt,7] ,;
   aColsS[oLbIten2:nAt,8] ,;
   aColsS[oLbIten2:nAt,9] ,;
   aColsS[oLbIten2:nAt,10]}}

Elseif cTipLib == "3" // Veiculos

   //Veiculos

   @ 100,001 LISTBOX oLbItens FIELDS HEADER OemToAnsi(""),;
   OemToAnsi(STR0020),; //"Chassi         "
   OemToAnsi(STR0013),; //"Valor Original "
   OemToAnsi(STR0015),; //"Valor Permitido"
   OemToAnsi(STR0017); //"Valor Desejado "
   COLSIZES 10,92,40,40,50 ;
   SIZE 354,140 OF oDlg ON DBLCLICK((If(nOpc#2,If(aColsV[oLbItens:nAt,1],aColsV[oLbItens:nAt,1]:=.F.,aColsV[oLbItens:nAt,1]:=.T.),IIF(aColsV[oLbItens:nAt,1],oOk,oNo)),.f.)) PIXEL

   oLbItens:SetArray(aColsV)
   oLbItens:bLine := { || {  IIF(aColsV[oLbItens:nAt,1],oOk,oNo) ,;
   aColsV[oLbItens:nAt,2] ,;
   aColsV[oLbItens:nAt,3] ,;
   aColsV[oLbItens:nAt,4] ,;
   aColsV[oLbItens:nAt,5] }}
	
Endif

ACTIVATE MSDIALOG oDlg CENTER ON INIT FS_ChBar170(oDlg,{||nOpca:=1,If(!obrigatorio(aGets,aTela),nOpca := 0,oDlg:End())},{||oDlg:End()})

If nOpca == 1 .and. nopc == 3
   RecLock("VS6",.f.)
   VS6->VS6_LIBPRO := substr(cUsuario,7,15)
   VS6->VS6_DATAUT := dDataBase
   VS6->VS6_HORAUT := val(substr(time(),1,2)+substr(time(),4,2))
   cVar := aMemos[1][2]
   MSMM(,TamSx3("VS6_OBSERV")[1],,&cVar,1,,,"VS6","VS6_OBSMEM")
   MsUnlock()

   If cTipLib  $ [12]
      DbSelectArea("VS7")
      For i:=1 to Len(aColsP)
          If DbSeek(xFilial("VS7")+VS6->VS6_NUMIDE+aColsP[i,2])
             RecLock("VS7",.f.)
             If aColsP[i,1] == .t.
                VS7->VS7_ITELIB := "S"
             Else
                VS7->VS7_ITELIB := "N"
             Endif
             MsUnlock()
          Endif
      Next
   
      If cTipLib == "2"
         For i:=1 to Len(aColsS)
             If DbSeek(xFilial("VS7")+VS6->VS6_NUMIDE+aColsS[i,2])
                RecLock("VS7",.f.)
                If aColsS[i,1] == .t.
                   VS7->VS7_ITELIB := "S"
                Else
                   VS7->VS7_ITELIB := "N"
                Endif
                MsUnlock()
             Endif
         Next
      Endif
   Else
      DbSelectArea("VS7")
      For i:=1 to Len(aColsV)
          if DbSeek(xFilial("VS7")+VS6->VS6_NUMIDE+"00013")
             RecLock("VS7",.f.)
             if aColsV[i,1] == .t.
                VS7->VS7_ITELIB := "S"
             Else
                VS7->VS7_ITELIB := "N"
             Endif
             MsUnlock()
          Endif
      Next
   Endif
	if VS1->(FieldPos("VS1_STATUS")) # 0
		dbSelectArea("VS6")       // CLAUDIA
		dbClearFilter()           // CLAUDIA

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Retirada para homologacao da M11                              ³
		//³Verificar se é preciso chamar alguma funcao do Orcamento Fases³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		//		OFIXA012(VS6->VS6_NUMORC)
		
		//Eval(bFiltraBrw) // claudia
		FilBrowse("VS6",{},cAuxCond)
	endif

	dbSelectArea("VS6")       // CLAUDIA
	dbClearFilter()           // CLAUDIA
	FilBrowse("VS6",{},cAuxCond)

Endif


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_CHBAR890 ³ Autor ³ Andre                 ³ Data ³03/01/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Poe a enchoicebar na tela                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FS_CHBAR170(oDlg,bOk,bCancel)

Local bSet6, bSet15, bSet24, lOk, oBtOk, oBtCan, oBtFab
Local lVolta :=.f.
Private oBar

DEFINE BUTTONBAR oBar SIZE 25,25 3D TOP OF oDlg

DEFINE BUTTON RESOURCE "S4WB005N" OF oBar ACTION NaoDisp() TOOLTIP STR0021 //"Recortar"
DEFINE BUTTON RESOURCE "S4WB006N" OF oBar ACTION NaoDisp() TOOLTIP STR0022 //"Copiar"
DEFINE BUTTON RESOURCE "S4WB007N" OF oBar ACTION NaoDisp() TOOLTIP STR0023 //"Colar"
DEFINE BUTTON RESOURCE "S4WB008N" OF oBar GROUP ACTION Calculadora() TOOLTIP STR0024 //"Calculadora..."
DEFINE BUTTON RESOURCE "S4WB009N" OF oBar ACTION Agenda() TOOLTIP STR0025 //"Agenda..."
DEFINE BUTTON RESOURCE "S4WB010N" OF oBar ACTION OurSpool() TOOLTIP STR0026 //"Gerenciador de ImpressÆo..."
DEFINE BUTTON RESOURCE "S4WB016N" OF oBar ACTION HelProg() TOOLTIP STR0027 //"Help de Programa..."
DEFINE BUTTON RESOURCE "PRECO"    OF oBar ACTION FS_AVRESGER() TOOLTIP STR0028 //"Avaliacao de Resultado"

If ExistBlock("POOM170ENC") // Ponto de Entrada para criacao de Botao na Enchoicebar
	ExecBlock("POOM170ENC")
Endif

oBar:nGroups += 6
DEFINE BUTTON oBtOk RESOURCE "Ok" OF oBar GROUP ACTION ( cTudoOk, lLoop:=lVolta,lOk:=Eval(bOk)) TOOLTIP STR0029 //"Ok - <Ctrl-O>"
SetKEY(15,oBtOk:bAction)
oDlg:bSet15 := oBtOk:bAction

DEFINE BUTTON oBtCan RESOURCE "CANCEL" OF oBar ACTION ( lLoop:=.f.,Eval(bCancel),ButtOff(bSet6,bSet15,bSet24,.T.)) TOOLTIP STR0030 //"Cancelar - <Ctrl-X>"
SetKEY(24,oBtCan:bAction)
oDlg:bSet24 := oBtCan:bAction
oBar:bRClicked := {|| AllwaysTrue()}

Return nil


Static Function ButtOff(bSet6,bSet15,bSet24,lOk)

Default lOk := .t.

If lOk
   SetKey(6,bSet6)
   SetKey(15,bSet15)
   SetKey(24,bSet24)
Endif

Return .t.


//////////////////////
Function FS_AVRESGER()

Local nCont     := 0
Local bCampo    := { |nCPO| Field(nCPO) }
Local aVetVal   := {}
Local aSomaStru := {}
Local x			:= 0
Local _ni		:= 0
Local n_		:= 0
Local nCnt		:= 0
Private cSimVda := " "

If cTipLib == "1"  //Pecas 

   Private aColsP
   Private aHeaderP
   Private nUsadoP
   Private cCodVen
   Private nTotNot,nTotDes, nTotOrc
   Private aColsc,aIteParc
	cSimVda := "P" // Pecas

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Posiciona no VS1 p/ pegar o Vendedor                         ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   DbSelectArea("VS1")
   DbSeek(xFilial("VS1")+VS6->VS6_NUMORC)
   For x:=1 to FCount()
       &("M->"+FieldName(x)) := &(FieldName(x))
   Next

   DbSelectArea("SA3")
   DbSetOrder(1)
   DbSeek(xFilial("SA3")+VS1->VS1_CODVEN)
   cCodVen := SA3->A3_COD
   nTotDes := VS1->VS1_VALDES
   nTotNot := VS1->VS1_VTOTNF
   nTotOrc := VS1->VS1_VTOTNF
   
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Cria o aCols Pecas                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   nUsadoP:=0
   DbSelectArea("SX3")
   DbSeek("VS3")
   aHeaderP:={}
   While !Eof().And.(x3_arquivo=="VS3")
      If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( ! Trim(SX3->X3_CAMPO) $ "VS3_NUMORC" )
         nUsadoP++
         Aadd(aHeaderP,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
         wVar := "M->"+x3_campo
         &wVar := CriaVar(x3_campo)
      Endif
      DbSkip()
   EndDo

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta o aCols Pecas                                          ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   aColsP := {}
   DbSelectArea("VS3")
   DbSetOrder(1)
   DbGotop()
   Fg_Seek("VS3","VS1->VS1_NUMORC",1,.F.)
   While VS3->VS3_FILIAL == xFilial("VS3") .and. VS3->VS3_NUMORC == VS1->VS1_NUMORC .and. !eof()
      aAdd(aColsP,Array(nUsadoP+1))
      For _ni:=1 to nUsadoP
          aColsP[Len(aColsP),_ni]:=If(aHeaderP[_ni,10] # "V",FieldGet(FieldPos(aHeaderP[_ni,2])),CriaVar(aHeaderP[_ni,2]))
      Next
      DbSkip()
   Enddo   

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta o aCols da Entrada                                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   nUsadoC:=0
   DbSelectArea("SX3")
   DbSeek("VS9")
   aHeaderC:={}
   While !Eof().And.(x3_arquivo=="VS9")
      If X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. ( Trim(SX3->X3_CAMPO) $ "VS9_TIPPAG#VS9_DESPAG#VS9_DATPAG#VS9_VALPAG#VS9_REFPAG")
         nUsadoC++
         Aadd(aHeaderC,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
         wVar := "M->"+x3_campo
         &wVar := CriaVar(x3_campo)
      Endif
      DbSkip()
   EndDo
 	
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Monta o aCols da Entrada                                     ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   aColsC:={Array(nUsadoC+1)}
   aColsC[1,nUsadoC+1]:=.F.
   For _ni:=1 to nUsadoC
        aColsC[1,_ni]:=CriaVar(aHeaderC[_ni,2])
   Next


   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Itens do Parcelamento                                        ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
   aIteParc := {{cTod(""),0}}

   cTipAva  := "2"
   cOpeMov2 := if(VS1->VS1_NOROUT=="0","1","2")

   FS_AVALIARES()
	 
Elseif cTipLib == "2"

   Private aStruP  := {}
   Private aStruS  := {}
   Private aStruO  := {}
   Private cCodMap
   Private cOutMoed
   Private cSimOMoe
   Private lCalcTot:= .f.
   Private cCpoDiv := "    1"
   Private cNumIde
   cSimVda := "S"
   cTipAva := "4"

   If !PERGUNTE("ATDOFI")
       return .t.
   EndIf

   cMapPecas := Mv_Par01
   cMapSrvcs := Mv_Par02
   cMapOdSrv := Mv_Par03

   cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
   cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))
   cNumLib := VS6->VS6_NUMIDE
*******************************************************************************
   nNumero := VS6->VS6_NUMIDE
   cParPro := "1"
   cContChv:= "VEC_NUMORC"
   cParTem := ""
   &&cArqPes := ""

*** Avaliacao de Pecas ********************************************************

   aSomaStru := {}
   cCpoDiv := "    1"
   lCalcTot := .f.

   If FG_SEEK("VSY","VS6->VS6_NUMIDE",1,.f.)

      DbSelectArea("VSY")

      While VS6->VS6_NUMIDE == VSY_NUMIDE .and. VSY->VSY_FILIAL == xFilial("VSY") .and. !eof()

         DbSelectArea("VOQ")
         FG_Seek("VOQ","cMapPecas",1,.f.)
         FG_SEEK("SB1","VSY->VSY_GRUITE+VSY->VSY_CODITE",7,.f.)
         nPosVet := aScan(aStruP,{|x| x[3]+x[7] == SB1->B1_COD+VOQ_CODIGO})
         ncont := nPosVet
         while cMapPecas == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

            If VOQ_INDATI != "1" && Sim
               DbSkip()
               Loop
            Endif

            cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)

            If nPosVet == 0
               aadd(aStruP,{ VSY->VSY_NUMOSV,,SB1->B1_COD,;
                              VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_GRUPO+" "+SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
               aadd(aSomaStru,{0,0,0,0,0,0})
            Else

               aStruP[nCont,1]  := VSY->VSY_NUMOSV
               aStruP[nCont,2]  := Nil
               aStruP[nCont,3]  := SB1->B1_COD
               aStruP[nCont,4]  := VOQ_CLAAVA
               aStruP[nCont,5]  := cDescVOQ
               aStruP[nCont,6]  := VOQ_ANASIN
               aStruP[nCont,7]  := VOQ_CODIGO
               aStruP[nCont,8]  := VOQ_SINFOR
               aStruP[nCont,9]  := 0
               aStruP[nCont,10] := 0
               aStruP[nCont,11] := SB1->B1_GRUPO+" "+SB1->B1_CODITE
               aStruP[nCont,12] := 0
               aStruP[nCont,13] := 0
               aStruP[nCont,14] := .f.
               aStruP[nCont,15] := VOQ->VOQ_PRIFAI
               aStruP[nCont,16] := VOQ->VOQ_SEGFAI
               aStruP[nCont,17] := VOQ_FUNADI
               aStruP[nCont,18] := VOQ_CODIMF
               aStruP[nCont,19] := dDataBase
               aStruP[nCont,20] := 0
               aStruP[nCont,21] := 0

            Endif

            nCont++

            DbSkip()

         Enddo

         DbSelectArea("VSY")

         cNumero := VS6->VS6_NUMIDE
         aStruP := FG_CalcVlrs(aStruP,SB1->B1_COD,cCpoDiv)

         If nPosVet == 0
            cCpoDiv := cCpoDiv + "#" + str(len(aStruP)+1,5)
         Endif

         FG_Seek("VOQ","cMapPecas",1,.f.)
         FG_SEEK("SB1","VSY->VSY_GRUITE+VSY->VSY_CODITE",7,.f.)
         nPosVet := aScan(aStruP,{|x| x[3]+x[7] == SB1->B1_COD+VOQ->VOQ_CODIGO})
         If nPosVet == 0
            nPosVet := 1
         Endif

         For n_:=nPosVet to Len(aSomaStru)
             aSomaStru[n_,1] += aStruP[n_,9]
                     aSomaStru[n_,3] += aStruP[n_,12]
             aSomaStru[n_,5] += aStruP[n_,20]
         Next

         For n_:=1 to Len(aSomaStru)
             aStruP[n_,9]  := aSomaStru[n_,1]
                 aStruP[n_,12] := aSomaStru[n_,3]
             aStruP[n_,20] := aSomaStru[n_,5]
         Next

         dbSkip()

      EndDo

      lCalcTot:= .t.

      DbSelectArea("VOQ")
      FG_Seek("VOQ","cMapPecas",1,.f.)

      While cMapPecas == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

         If VOQ_INDATI != "1" && Sim
            DbSkip()
            Loop
         Endif

         cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
         aadd(aStruP,{ VSY->VSY_NUMOSV,,STR0031,; //"Total da Venda"
         VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_GRUPO+" "+SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})

         DbSkip()

      EndDo

   
   
      cNumero := VS6->VS6_NUMIDE
      aStruP := FG_CalcVlrs(aStruP,STR0031,cCpoDiv) //"Total da Venda"

   EndIf

   *** Avaliacao de Servicos ********************************************

   aSomaStru := {}
   cCpoDiv := "    1"
   lCalcTot := .f.

   If FG_SEEK("VSZ","VS6->VS6_NUMIDE",1,.f.)

      DbSelectArea("VSZ")
      While  VS6->VS6_NUMIDE == VSZ_NUMIDE .and. VSZ->VSZ_FILIAL == xFilial("VSZ") .and. !eof()

         DbSelectArea("VOQ")
         FG_Seek("VOQ","cMapSrvcs",1,.f.)
         nPosVet := aScan(aStruS,{|x| x[3]+x[7] == VSZ->VSZ_CODSER+VOQ_CODIGO})
         nCont := nPosVet

         While cMapSrvcs == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

            If VOQ_INDATI != "1" && Sim
               DbSkip()
               Loop
            Endif

            cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)

            If nPosVet == 0
               aAdd(aStruS,{ VSZ->VSZ_NUMOSV,,VSZ->VSZ_CODSER,;
                    VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VSZ->VSZ_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
               aAdd(aSomaStru,{0,0,0,0,0,0})
            Else
               aStruS[nCont,1]  := VSZ->VSZ_NUMOSV
               aStruS[nCont,2]  := Nil
               aStruS[nCont,3]  := VSZ->VSZ_CODSER
               aStruS[nCont,4]  := VOQ_CLAAVA
               aStruS[nCont,5]  := cDescVOQ
               aStruS[nCont,6]  := VOQ_ANASIN
               aStruS[nCont,7]  := VOQ_CODIGO
               aStruS[nCont,8]  := VOQ_SINFOR
               aStruS[nCont,9]  := 0
               aStruS[nCont,10] := 0
               aStruS[nCont,11] := VSZ->VSZ_CODSER
               aStruS[nCont,12] := 0
               aStruS[nCont,13] := 0
               aStruS[nCont,14] := .f.
               aStruS[nCont,15] := VOQ->VOQ_PRIFAI
               aStruS[nCont,16] := VOQ->VOQ_SEGFAI
               aStruS[nCont,17] := VOQ_FUNADI
               aStruS[nCont,18] := VOQ_CODIMF
               aStruS[nCont,19] := dDataBase
               aStruS[nCont,20] := 0
               aStruS[nCont,21] := 0
            Endif

            nCont ++

            DbSkip()

         EndDo

         DbSelectArea("VSZ")
         nArea := GetArea()

         cNumero := VS6->VS6_NUMIDE + VSZ->VSZ_CODSER + VSZ->VSZ_NUMOSV
         aStruS := FG_CalcVlrs(aStruS,VSZ->VSZ_CODSER,cCpoDiv)

         If nPosVet == 0
            cCpoDiv := cCpoDiv + "#" + str(len(aStruS)+1,5)
         Endif

         FG_Seek("VOQ","cMapSrvcs",1,.f.)
         nPosVet := aScan(aStruS,{|x| x[3]+x[7] == VSZ->VSZ_CODSER+VOQ->VOQ_CODIGO})
         If nPosVet == 0
            nPosVet := 1
         Endif

         For n_:=nPosVet to Len(aSomaStru)
             aSomaStru[n_,1] += aStruS[n_,9]
                     aSomaStru[n_,3] += aStruS[n_,12]
             aSomaStru[n_,5] += aStruS[n_,20]
         Next

         For n_:=1 to Len(aSomaStru)
             aStruS[n_,9]  := aSomaStru[n_,1]
                 aStruS[n_,12] := aSomaStru[n_,3]
             aStruS[n_,20] := aSomaStru[n_,5]
         Next

         DbSelectArea("VSZ")
         RestArea(nArea)
         dbSkip()

      EndDo

      lCalcTot:= .t.

      DbSelectArea("VOQ")
      FG_SEEK("VOQ","cMapSrvcs",1,.f.)

      while cMapSrvcs == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

         If VOQ_INDATI != "1" && Sim
            DbSkip()
            Loop
         Endif

         cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
         aadd(aStruS,{ VSZ->VSZ_NUMOSV,,STR0031,; //"Total da Venda"
         VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VSZ->VSZ_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})
         DbSkip()

      EndDo

      cNumero := VS6->VS6_NUMIDE
      aStruS := FG_CalcVlrs(aStruS,STR0031,cCpoDiv) //"Total da Venda"

   EndIf

   *** Avaliacao da Ordem de Servico *********************************************

   aSomaStru := {}
   cCpoDiv := "    1"

   If FG_SEEK("VSY","VS6->VS6_NUMIDE",1,.f.)

      DbSelectArea("VSY")

      While VS6->VS6_NUMIDE == VSY_NUMIDE .and. VSY->VSY_FILIAL == xFilial("VSY") .and. !eof()

         DbSelectArea("VOQ")
         FG_Seek("VOQ","cMapOdSrv",1,.f.)

         while cMapPecas == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

            If VOQ_INDATI != "1" && Sim
               DbSkip()
               Loop
            Endif

            FG_SEEK("SB1","VO3->VO3_GRUITE+VO3->VO3_CODITE",7,.f.)

            cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
            aadd(aStruO,{ VSY->VSY_NUMOSV,,SB1->B1_COD,;
            VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,SB1->B1_GRUPO+" "+SB1->B1_CODITE,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})

            DbSkip()

         Enddo

         DbSelectArea("VSY")

         cNumero := VS6->VS6_NUMIDE
         aStruO := FG_CalcVlrs(aStruO,SB1->B1_GRUPO+" "+SB1->B1_CODITE,cCpoDiv)
         cCpoDiv := cCpoDiv + "#" + str(len(aStruO)+1,5)
         DbSkip()

      EndDo

   EndIf

   If FG_SEEK("VSZ","VS6->VS6_NUMIDE",1,.f.)

      DbSelectArea("VSZ")

      While VS6->VS6_NUMIDE == VSZ_NUMIDE .and. VSZ->VSZ_FILIAL == xFilial("VSZ") .and. !eof()

         DbSelectArea("VOQ")
         FG_Seek("VOQ","cMapOdSrv",1,.f.)

         While cMapOdSrv == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

            If VOQ_INDATI != "1" && Sim
               DbSkip()
               Loop
            Endif

            cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
            aadd(aStruO,{ VSZ->VSZ_NUMOSV,,VSZ->VSZ_CODSER,;
            VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VSZ->VSZ_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})

            DbSkip()

         Enddo

         DbSelectArea("VSZ")

         cNumero := VS6->VS6_NUMIDE
         aStruO := FG_CalcVlrs(aStruO,VSZ->VSZ_CODSER,cCpoDiv)
         cCpoDiv := cCpoDiv + "#" + str(len(aStruO)+1,5)
         DbSkip()

      EndDo                                                                       

   EndIf

   lCalcTot:= .t.

   DbSelectArea("VOQ")
   FG_SEEK("VOQ","cMapOdSrv",1,.f.)

   While cMapOdSrv == VOQ->VOQ_CODMAP .and. VOQ->VOQ_FILIAL == xFilial("VOQ") .and. !eof()

      If VOQ_INDATI != "1" && Sim
         DbSkip()
         Loop
      Endif

      cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
      aadd(aStruO,{ VSZ->VSZ_NUMOSV,,STR0031,; //"Total da Venda"
      VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VSZ->VSZ_CODSER,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,dDataBase,0,0,VOQ_CTATOT})

      DbSkip()

   EndDo

   cNumero := VS6->VS6_NUMIDE
   aStruO := FG_CalcVlrs(aStruO,STR0031,cCpoDiv) //"Total da Venda"

   FG_ResAva(cOutMoed,3,"S","","OFIOM160",{aStruP,aStruS,aStruO})

Else

   // Veiculos

   PERGUNTE("LIBVEI")

   cCodMap  := Mv_Par01
   cOutMoed := GetMv("MV_SIMB"+Alltrim(GetMv("MV_INDMFT")))
   cSimOMoe := Val(Alltrim(GetMv("MV_INDMFT")))

   DbSelectArea("VV0")
   DbSetOrder(1)
   DbGotop()
   DbSeek(xFilial("VV0")+"00"+VS6->VS6_NUMORC)

   DbSelectArea("VVA")
   DbSetOrder(1)
   DbGotop()
   DbSeek(xFilial("VVA")+"00"+VS6->VS6_NUMORC)

   DbSelectArea("VV1")
   DbSetOrder(2)
   DbGotop()
   DbSeek(xFilial("VV1")+VVA->VVA_CHASSI)

	FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,"D")
	FG_DesVei(VV1->VV1_TRACPA,VV1->VV1_CHAINT,"R")

   aStru   := {}
   cTipAva := "1" 
   cCpoDiv := "    1"
   cTipFat := VV0->VV0_TIPFAT
   lCarBott:= .t.
   cSimVda := "V"

   DbSelectArea("VS5")
   FG_Seek("VS5","cCodMap",1,.f.)

   DbSelectArea("VOQ")
   FG_Seek("VOQ","cCodMap",1,.f.)

   while !eof() .and. VOQ->VOQ_FILIAL == xFilial("VOQ")

      If !(cTipFat $ VOQ_TIPFAT)
         DbSkip()
         Loop
      Endif

      If VOQ_INDATI # "1" && Sim
         DbSkip()
         Loop
      Endif

      If VOQ_CODMAP # cCodMap
         Exit
      Endif

      cDescVOQ :=if(VOQ->VOQ_ANASIN#"0",Space(7)+VOQ_DESAVA,VOQ_DESAVA)
      aadd(aStru,{ VV0->VV0_NUMTRA,VV1->VV1_TRACPA,VV1->VV1_CHAINT,;
      VOQ_CLAAVA,cDescVOQ,VOQ_ANASIN,VOQ_CODIGO,VOQ_SINFOR,0,0,VV1->VV1_CHASSI,0,0,.f.,VOQ->VOQ_PRIFAI,VOQ->VOQ_SEGFAI,VOQ_FUNADI,VOQ_CODIMF,VV0->VV0_DATMOV,0,0,VOQ_CTATOT})

      DbSkip()

   Enddo

   DbSelectArea("VV0")
   For nCnt := 1 TO FCount()
       cNome := Substr(FieldName(nCnt),5)
       M->&(EVAL(bCampo,nCnt)) := &("VV0->VV0_"+cNome)
   Next

   DbSelectArea("VVA")
   For nCnt := 1 TO FCount()
       cNome := Substr(FieldName(nCnt),5)
       M->&(EVAL(bCampo,nCnt)) := &("VVA->VVA_"+cNome)
   Next

   FG_CalcVlrs(aStru,VV1->VV1_CHAINT)
   FG_RESAVA(cOutMoed,3,"V","","OFIOM170")

Endif

Return

Static Function MenuDef()
Local aRotina := {{ STR0001  ,"axPesqui",    0, 1},;      //"Pesquisar"
                    { STR0002  ,"FS_OFI170"  , 0, 2},;    //"Visualizar"
                    { STR0003,"FS_OFI170"  , 0, 4} }      //"Liberar"
Return aRotina
