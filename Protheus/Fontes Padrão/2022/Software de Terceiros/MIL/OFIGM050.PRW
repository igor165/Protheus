#INCLUDE "Ofigm050.ch"
 /*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIGM050 ³ Autor ³  Renata               ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Libera as OS's VW para Novas Transmissoes                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION OFIGM050

LOCAL cChave, cCond
PRIVATE aCampos := {}
PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0004)   //"Libera OS para Retransmissao //"Libera Dados da Garantia para Retransmissao"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("VGA")
dbSetOrder(1)             

cIndex := CriaTrab(nil,.f.)
cChave  := IndexKey()   //"VO1_FILIAL+VO1_NUMOSV"
cCond   := 'VGA_TRANSM=="S"'
IndRegua("VGA",cIndex,cChave,,cCond,STR0005) //"Aguarde, filtrando registros..."

DbSelectArea("VGA")
nIndex := RetIndex("VGA")
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)


mBrowse( 6, 1,22,75,"VGA",,,,"VGA_TRANSM='S'")

dbSelectArea("VGA")
Set Filter to
RetIndex("VGA")
DbsetOrder(1)
#IFNDEF TOP
   If File(cIndex+OrdBagExt())
      fErase(cIndex+OrdBagExt())
   Endif
#ENDIF

Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM050V    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza os dados do VG6/VG8 - modelo 3                   ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM050V(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/  

Function GM050V(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor  := 0	 
Local _ni	   := 0	

if EMPTY(VGA->VGA_CODGAR) .and. !empty(VGA->VGA_CODREV)

   CPOM050()
   AxVisual(cAlias,nReg,nOpc,aCampos)                  

else

   PRIVATE aRotina := { { "" ,"",0, 1},;
                      { "" ,"", 0 , 2},;    //VIZUALIZAR
                      { "" ,"", 0 , 4},;   	//ALTERAR
                      { "","",  0,  4}}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

   RegToMemory("VGA",.t.)         // .t. para carregar campos virtuais

   aCpoEnchoice:={}

   DbSelectArea("SX3")
   dbgotop()
   DbSetOrder(1)
   DbSeek("VGA02")

   While !Eof().and.(x3_arquivo=="VGA")
      if X3USO(x3_usado).and.cNivel>=x3_nivel.And.!(x3_campo $ [VGA_ESPGAR/VGA_CODREV/VGA_GRUREV/VGA_DNRESP/VGA_IMPOSV/VGA_NUMNFI/VGA_SERIEN/VGA_TRANSM/VGA_ARQFAB/VGA_DATRET/VGA_DATTRA/VGA_DATCRE/VGA_VALCRE/VGA_LANCRE/VGA_DATDEB/VGA_VALDEB/VGA_LANDEB/VGA_CODEST/VGA_DIFPGT/VGA_SITOSV/VGA_TRANSM/VGA_NUMNFI/VGA_SERIEN/VGA_SITUAC/VGA_EXPGAR])
         AADD(aCpoEnchoice,x3_campo)
      Endif
      wVar := "M->"+x3_campo
      &wVar:= CriaVar(x3_campo)
     dbSkip()
   End

   If !(Inclui)
      DbSelectArea("VGA")
      For nCntFor := 1 TO FCount()
         M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
      Next
   Endif

   if nOpc == 3   //ALTERAR
      nOpcE := 4
      nOpcG := 4
   elseif nOpc == 2  //VIZUALIZAR
      nOpcE := 2
      nOpcG := 2
   else
      nOpcE := 5      //EXCLUIR
      nOpcG := 5
   endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   nUsado:=0

   dbSelectArea("SX3")
   dbgotop()
   dbSeek("VG502")

   aHeader:={}
 
   While !Eof().And.(x3_arquivo=="VG5")
      If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(x3_campo $ [VG5_NUMOSV/VG5_CODMAR/VG5_DESMAR/VG5_DESGRU/VG5_TRANSM/VG5_NUMNFI/VG5_SERIEN])
         nUsado:=nUsado+1
         Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
           x3_tamanho, x3_decimal,x3_valid,;
           x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
         wVar := "M->"+x3_campo
         &wVar := CriaVar(x3_campo)
      Endif
      dbSkip()
   End

   If Inclui
      aCols:={Array(nUsado+1)}
      aCols[1,nUsado+1]:=.F.
      For _ni:=1 to nUsado
          aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
      Next

   Else  
    
      aCols:={}

      dbSelectArea("VG5")
      dbgotop()
      
      if !empty(M->VGA_NUMOSV)
         dbSetOrder(1)
         dbSeek(xFilial()+M->VGA_CODMAR+M->VGA_NUMOSV)
   
         While !eof() .and. M->VGA_FILIAL+M->VGA_CODMAR+M->VGA_NUMOSV == VG5->VG5_FILIAL+VG5->VG5_CODMAR+VG5->VG5_NUMOSV
             AADD(aCols,Array(nUsado+1))
             For _ni:=1 to nUsado
                 aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
             Next
             aCols[Len(aCols),nUsado+1]:=.F.
             dbSkip()
         End

      else
         dbSetOrder(2)
         dbSeek(xFilial()+M->VGA_CODMAR+M->VGA_NUMNFI)
   
         While !eof() .and. M->VGA_FILIAL+M->VGA_CODMAR+M->VGA_NUMNFI == XFILIAL("VG5")+VG5->VG5_CODMAR+VG5->VG5_NUMNFI
             AADD(aCols,Array(nUsado+1))
             For _ni:=1 to nUsado
                 aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
             Next
             aCols[Len(aCols),nUsado+1]:=.F.
             dbSkip()
         End
     
      endif        

   Endif

   If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

      cTitulo       :=STR0001    //"Garantia Solicitada"
      cAliasEnchoice:="VGA"
      cAliasGetD    :="VG5"
      cLinOk        :="FG_OBRIGAT()"
      cTudOk        :="FS_TudOk()"   //"FS_OrdGaVw('M->VG5_ORDITE','VGA->VGA_NUMOSV'),FS_GarOk()"
      cFieldOk      :="FG_MEMVAR(),FS_CODINT(),FS_ITEEXT()"

      If !(Inclui)
         DbSelectArea("VGA")
         dbgotop()
         DbSetOrder(1)
         dbSeek(xFilial("VGA")+M->VGA_CODMAR+M->VGA_NUMOSV)
      Endif

      _lRet:=Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

   
   endif
   
endif

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Gm050l    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Muda os campos VGA_TRANSM/VG5_TRANSM p/ "N"                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ Gm050l(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function GM050L(cAlias,nReg,nOpc)

dbselectArea("VGA")

if VGA->VGA_TRANSM = "S"

   Begin Transaction
   
   RecLock("VGA",.F.)
   VGA->VGA_TRANSM := "N"   //LIBERADA PARA RETRANSMISSAO
   VGA->VGA_DATTRA := ctod("  /  /  ")
   MsUnlock()


   dbselectArea("VG5")
   dbgotop()

   if !empty(VGA->VGA_NUMOSV)
      cNumero := VGA->VGA_NUMOSV
      dbsetorder(1)
   else
      cNumero := VGA->VGA_NUMNFI
      dbsetorder(2)
   endif

   dbseek(xFilial("VG5")+VGA->VGA_CODMAR+cNumero)

   do while !eof() .and.  VGA->VGA_FILIAL+VGA->VGA_CODMAR+cNumero == XFILIAL("VG5")+VG5->VG5_CODMAR + if(!empty(VG5->VG5_NUMOSV),VG5->VG5_NUMOSV,VG5->VG5_NUMNFI)

      RecLock("VG5",.F.)
      VG5->VG5_TRANSM := "N"   //LIBERADA PARA RETRANSMISSAO
      MsUnlock()
 
      dbselectArea("VG5")
      dbskip()

   enddo
   
   End Transaction

else
   help(" ",1,"OFIGM05001")
endif

return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CPOM050  ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Pega campos do VGA no SX3                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ CPOM050(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CPOM050()

DbSelectArea("SX3")
dbgotop()
dbseek("VGA02")
aCampos := {}

do While !eof() .and. x3_arquivo == "VGA"
   if X3USO(x3_usado) .And. cNivel>=x3_nivel .And. x3_campo $ [VGA_NUMOSV/VGA_NUMNFI/VGA_SERIEN/VGA_CHASSI/VGA_CODGAR/VGA_DESGAR/VGA_DESMAR/VGA_CODCLI/VGA_NOMCLI/VGA_ABEGAR/VGA_DATFEC]
      aadd(aCampos,x3_campo)
   endif
   dbskip()
Enddo

DbSelectArea("VGA")

Return

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui",0, 1},; //Pesquisar
                   { STR0002 ,"GM050V", 0 , 2},; //Visualizar
                   { STR0003 ,"GM050L", 0 , 4}}  //Liberar
Return aRotina
