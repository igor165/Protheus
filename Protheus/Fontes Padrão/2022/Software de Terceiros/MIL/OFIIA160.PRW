#include "Ofiia160.ch"
#include "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIIA160 ³ Autor ³  Renata               ³ Data ³ 10/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tabela de Grupos de Parametros (SEGMENTO)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIIA160

Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0006)  //Grupos de Parametros p/ Transmissao/Recepcao de Arquivo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

dbSelectArea("VH0")
mBrowse(06,01,22,75,"VH0")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ IA160    ³ Autor ³  Renata               ³ Data ³ 10/03/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Inclusao, alteracao, visualizacao do VH0/VH1               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function ia160(cAlias,nReg,nOpc)
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {} 
Local aSizeAut := MsAdvSize(.T.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)

Local bCampo   := { |nCPO| Field(nCPO) }
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk 
Local nCntFor := 0 , _ni := 0
Local nPosRec := 0
Private aTELA[0][0],aGETS[0] 
Private aCpoEnchoice  := {} , aCols := {} , aHeader := {} , nLenaCols:=0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VH0",.t.)         // .t. para carregar campos virtuais

if nOpc == 3
   nOpcE := 3
   nOpcG := 3
elseif nOpc == 4
   nOpcE := 4
   nOpcG := 4
elseif nOpc == 2
   nOpcE := 2
   nOpcG := 2
else
   nOpcE := 5
   nOpcG := 5
endif

aCpoEnchoice  :={}
DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VH0")

While !Eof().and.(x3_arquivo=="VH0")

   if X3USO(x3_usado).and.cNivel>=x3_nivel && .And.!(x3_campo $ [/])
      AADD(aCpoEnchoice,x3_campo)
   Endif

   &( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
   
   dbSkip()

EndDo

If !(Inclui)
   DbSelectArea("VH0")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSeek("VH1")
aHeader:={}

While !Eof().And.(x3_arquivo=="VH1")

   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!(x3_campo $ [VH1_CODGRU/VH1_NOMGRU/VH1_CODMAR/VH1_DESMAR/VH1_SEGMEN])
      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )

      &( "M->"+Alltrim(x3_campo) ) := CriaVar(x3_campo)
      
   Endif
   dbSkip()

End

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VH1")
ADHeadRec("VH1",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

aCols:={}
dbSelectArea("VH1")
dbSetOrder(1)
dbSeek( xFilial("VH1") + M->VH0_CODMAR + M->VH0_CODGRU )

If nOpc == 3 .Or. !Found()

   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VH1"
		Else	
			aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
		EndIf	
   Next         
   
Else

   While !eof() .And. M->VH0_CODMAR + M->VH0_CODGRU == VH1->VH1_CODMAR + VH1->VH1_CODGRU .And. VH1->VH1_FILIAL == xFilial("VH1")

       AADD(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VH1->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VH1"
			Else
				aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			EndIf	
       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       dbSkip()

   End

	nLenaCols:=Len(aCols)
   
Endif

If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo       := cCadastro
   cAliasEnchoice:="VH0"
   cAliasGetD    :="VH1"
   cLinOk        :="If(FS_LIA160(nOpcG),FG_OBRIGAT(),.f.)"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR()"

   If !(Inclui)
      DbSelectArea("VH1")
      DbSetOrder(1)
      dbSeek(xFilial("VH1")+M->VH0_CODMAR+M->VH0_CODGRU)
   Endif
   // Configura os tamanhos dos objetos
	aObjects := {}
	AAdd( aObjects, { 05, 130 , .T., .F. } )  //Cabecalho
	AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
	//AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
	//AAdd( aObjects, { 10, 10, .T. , .F. } )  //list box inferior
	//tamanho para resolucao 1024*768
	//aSizeAut[3]:= 508 
	//aSizeAut[5]:= 1016  
	// Fator de reducao de 0.8
	//for nCntFor := 1 to Len(aSizeAut)
	//	aSizeAut[nCntFor] := INT(aSizeAut[nCntFor] * 0.8)
	//next   
	
	aInfo := {aSizeAut[1] , aSizeAut[2] , aSizeAut[3] , aSizeAut[4] , 2 , 2 }
	aPosObj := MsObjSize (aInfo, aObjects,.F.)    
	
   DEFINE MSDIALOG oDlg TITLE cTitulo From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL

   EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},,3,,,,,,.F.)
                                                            
   oGetDados := MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)

   oGetDados:oBrowse:bChange:= {|| FG_AALTER("VH1",nLenaCols,oGetDados) }

   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| If(oGetDados:TudoOk().And.obrigatorio(aGets,aTela).And.FS_GRAGRPAR( nOpc ) ,oDlg:End(),.f.) },{|| oDlg:End() })

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GRAGRPAºAutor  ³Fabio               º Data ³  08/15/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Integracao                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GRAGRPAR( nOpc )

Local lRet := .t. , i := 0 , aVetValid := {}
Private lMsHelpAuto := .t.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Executar processamento                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOpc # 2

   Begin Transaction

      DbSelectArea("VH0")
      DbSetOrder(1)
      DbSeek(xFilial("VH0")+M->VH0_CODMAR+M->VH0_CODGRU)

      If nOpc == 3 .Or. nOpc == 4

         If !RecLock("VH0", !found() )
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf
         
         FG_GRAVAR("VH0")

         ConfirmSX8()
         MsUnlock()

      EndIf

      For i:=1 to Len(aCols)

         DbSelectArea("VH1")
         DbSetOrder(1)
         DbSeek(xFilial("VH1")+M->VH0_CODMAR+M->VH0_CODGRU+aCols[I,FG_POSVAR("VH1_ORDCAM")])

         If ( nOpc == 3 .Or. nOpc == 4 ) .And. !aCols[i,len(aCols[i])]

              If !RecLock("VH1", !found() )
                 Help("  ",1,"REGNLOCK")
                 lRet := .f.
                 DisarmTransaction()
                 Break               
              EndIf
               
              FG_GRAVAR("VH1",aCols,aHeader,i)
              VH1->VH1_FILIAL := xFilial("VH1")
              VH1->VH1_CODGRU := M->VH0_CODGRU
              VH1->VH1_ORDCAM := aCols[I,FG_POSVAR("VH1_ORDCAM")]
              VH1->VH1_CODMAR := M->VH0_CODMAR
        	     VH1->VH1_SEGMEN := M->VH0_SEGMEN
	           MsUnlock()
          
         ElseIf Found() .and. nLenaCols>=i
         
               If !RecLock("VH1",.F.,.T.)
                  Help("  ",1,"REGNLOCK")
                  lRet := .f.
                  DisarmTransaction()
                  Break               
               EndIf
               
               dbdelete()
               MsUnlock()

         EndIf

      Next

      && Deleta
      If nOpc == 5 

         aVetValid := {}
         Aadd(aVetValid,{"VH3" , 2 , VH0->VH0_CODMAR + VH0->VH0_CODGRU , NIL })

         If !FG_DELETA(aVetValid)
            lRet := .f.
            DisarmTransaction()
            Break
         EndIf
           
         If !RecLock("VH0",.F.,.T.)
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break               
         EndIf
               
         dbdelete()
         MsUnlock()
      
      EndIf

   End Transaction

EndIf
            
If !lRet
   MostraErro()
EndIf   

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_LIA160 ºAutor  ³Fabio               º Data ³  10/06/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida registro duplicado                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                    
Function FS_LIA160(nOpc)

Local nValLin:=0
            
FG_MEMVAR()
        
If !aCols[n,Len(aCols[n])]   

	If nOpc==3 .And. !ExistChav("VH1",M->VH0_CODMAR+M->VH0_CODGRU+M->VH1_ORDCAM)
	
		Return(.f.)     
	
	EndIf
	
	For nValLin:=1 to Len(aCols)
	    
		If !aCols[nValLin,Len(aCols[nValLin])] .And. aCols[nValLin,FG_POSVAR("VH1_ORDCAM")] == M->VH1_ORDCAM .and. nValLin#n
           
			Help("  ",1,"EXISTCHAV")
			Return(.f.)

		EndIf
	                           
	Next          

EndIf

Return(.t.)
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_FIA160 ºAutor  ³Fabio               º Data ³  10/15/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida alias                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FIA160() 

If ! FWAliasInDic(M->VH1_ALIASR)
	Help(" ",1,"REGNOIS")
	Return(.f.)
EndIf

M->VH1_DESALI := FWX2Nome(M->VH1_ALIASR)

Return(.t.)

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;  //PESQUISAR
                      { STR0002 ,"ia160", 0 , 2},;  //VISUALIZAR
                      { STR0003 ,"ia160", 0 , 3},;  //INCLUIR
                      { STR0004 ,"ia160", 0 , 4},;  //ALTERAR
                      { STR0005 ,"ia160", 0 , 5}}   //ALTERAR
Return aRotina
