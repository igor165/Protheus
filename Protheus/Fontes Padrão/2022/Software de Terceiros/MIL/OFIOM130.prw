/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOM130 ³ Autor ³  Emilton              ³ Data ³ 17/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao de Comissoes                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
#INCLUDE "ofiom130.ch"
#INCLUDE "protheus.ch"
FUNCTION OFIOM130

PRIVATE aRotina := MenuDef()
PRIVATE cCadastro := OemToAnsi(STR0006)   //"Agendamento de Clientes - Oficina"
Private cIndex , cChave , cCond , nIndex := 0
Private cMotivo := "000009"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Endereca a funcao de BROWSE                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

DbSelectArea("VSQ")

mBrowse( 6, 1,22,75,"VSQ")

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM130     ºAutor  ³Emilton             º Data ³  17/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta Tela                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM130(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0 
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local nPosRec  :=0  // Posicao do registro dentro do aCols

Private aTELA[0][0],aGETS[0] , nLenaCols := 0
Private aCols := {} , aHeader := {} , aCpoEnchoice := {}, nUsado := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VSQ",.t.)
DbSelectArea("VSQ")

aCpoEnchoice  :={}
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VSQ")
While !Eof().and.(x3_arquivo=="VSQ")
   If X3USO(x3_usado).and.cNivel>=x3_nivel .And. !(Alltrim(X3_CAMPO) $ [VSQ_NUMIDE])
      AADD(aCpoEnchoice,x3_campo)
      If nOpc == 3
         &("M->"+Alltrim(x3_campo)) := Criavar(x3_campo)
      EndIf
   Endif
   dbSkip()
EndDo

dbSelectArea("VSQ")
If nOpc != 3
   For nCntFor := 1 TO FCount()                     
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
EndIf

If nOpc == 3
   nOpcE := 3
   nOpcG := 3
ElseIf nOpc == 4
   nOpcE := 4
   nOpcG := 4
ElseIf nOpc == 5
   nOpcE := 5
   nOpcG := 5
Else
   nOpcE := 2
   nOpcG := 2
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("VSG")
aHeader:={}

While !Eof().And.(x3_arquivo=="VSG")

  If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !(Alltrim(X3_CAMPO) $ [VSG_NOSNUM/VSG_MODFOR/VSG_TIPCOM/VSG_PERCOM])

      nUsado:=nUsado+1
      aAdd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
          x3_tamanho, x3_decimal,x3_valid,;
          x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
      &("M->"+Alltrim(x3_campo)):= Criavar(x3_campo)      

   Endif  
   
   dbSkip()

EndDo

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VSG")
ADHeadRec("VSG",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

dbSelectArea("VSG")
dbSetOrder(1)
dbSeek(xFilial("VSG")+VSQ->VSQ_NUMIDE)

If nOpc == 3 .Or. !Found()
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
   
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VSG"
		Else	
         aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
      EndIf
         
   Next
Else
   aCols:={}              
   While !eof() .And. VSG->VSG_FILIAL == xFilial("VSG") .and. VSG->VSG_NOSNUM == VSQ->VSQ_NUMIDE
       aAdd(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado

			&& verifica se e a coluna de controle do walk-thru
			If IsHeadRec(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := VSG->(RecNo())
			ElseIf IsHeadAlias(aHeader[_ni,2])
				aCols[Len(aCols),_ni] := "VSG"
			Else
            aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
			EndIf
			
       Next
       aCols[Len(aCols),nUsado+1]:=.F.
       dbSkip()
   EndDo
   nLenaCols     := Len(aCols)
Endif

If Len(aCols)>0
   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo       :=STR0006   //"Manutencao de Comissoes"
   cAliasEnchoice:="VSQ"
   cAliasGetD    :="VSG"
   cLinOk        :="If( FS_VALOA130(nOpcG) , FG_OBRIGAT() , .f. )"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR()"
  
   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd

      EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,70,315},,3,,,,,,.F.)
      oGetDados := MsGetDados():New(075,001,143,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
      oGetDados:oBrowse:bChange    := {|| FG_AALTER("VSG",nLenaCols,oGetDados) }
      
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| if(oGetDados:TudoOk().And.Obrigatorio(aGets,aTela).And.FS_OA130GRA(nOpc),oDlg:End(),.f.) },{|| oDlg:End() })

Endif

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIOA130  ºAutor  ºEmilton             º Data º  17/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_OA130GRA(nOpc)
           
Local lRet      := .t.
Local ix1       := 0
Local aVetValid := {}

Private lMsHelpAuto := .t.
            
If nOpc != 2
                                
   Begin Transaction

      dbSelectArea("VSQ")
      dbSetOrder(1)
      dbSeek(xFilial("VSQ") + DtoS(M->VSQ_DATMAN) + M->VSQ_MOTIVO)

      && Grava arquivo pai
      If Inclui .or. Altera

         If !RecLock("VSQ", !Found() )
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break
         EndIf

         FG_GRAVAR("VSQ")
         If Inclui
            VSQ_NUMIDE := GetSXENum("VSQ","VSQ_NUMIDE")
            ConfirmSx8()
         EndIf
         MsUnlock()

      EndIf

      For ix1:=1 to len(aCols)

         DbSelectArea("VSG")
         DbSetOrder(1)
         DbSeek(xFilial("VSG")+VSQ->VSQ_NUMIDE+"A"+aCols[ix1,FG_POSVAR("VSG_CODVEN")])

         If (nOpc == 3 .Or. nOpc == 4) .And. !(aCols[ix1,Len(aCols[ix1])])

            If !RecLock("VSG", !Found() )
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break                           
            EndIf
            
            FG_GRAVAR("VSG",aCols,aHeader,ix1)
            VSG->VSG_FILIAL := xFilial("VSG")
            VSG->VSG_NOSNUM := VSQ->VSQ_NUMIDE
            VSG->VSG_TIPCOM := "A"
            VSG->VSG_VALCOM := aCols[ix1,FG_POSVAR("VSG_VALCOM")]
            VSG->VSG_MODFOR := FG_CALCMF( { {M->VSQ_DATMAN,aCols[ix1,FG_POSVAR("VSG_VALCOM")]} })
            MsUnlock()
              
         ElseIf Found() .And. nLenaCols>=ix1

            aVetValid := {}
            //aAdd(aVetValid,{"VO3" , "VO3_TIPTEM+VO3_PROREQ" , VOW->VOW_TIPTEM+VOW->VOW_CODPRO  , NIL })

            If !FG_DELETA(aVetValid)
               lRet := .f.
               DisarmTransaction()
               Break
            EndIf
            
            If !RecLock("VSG",.F.,.T.)
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break               
            EndIf
            
            dbdelete()
            MsUnlock()
            WriteSx2("VSG")
            
         EndIf

      Next          

      If nOpc == 5

         If !RecLock("VSQ",.F.,.T.)
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break
         EndIf

         dbdelete()
         MsUnlock()
         WriteSx2("VSQ")

      EndIf
      
   End Transaction   

Endif                      

If !lRet
   MostraErro()
EndIf 

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VALOA80ºAutor  ³Emilton             º Data ³  08/30/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida duplicidade                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_FECCOM()

If M->VSQ_DATMAN <= GetMV("MV_FECCOM")
   Help("  ",1,"FECTOCOMIS")
   return .f.
EndIf

Return .t.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VALCOM ºAutor  ³Emilton             º Data ³  08/30/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida duplicidade                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALCOM()
                 
Return Vazio().or.(FG_SEEK("VS0","cMotivo+M->VSQ_MOTIVO",1,.f.,"VSQ_DESMOT","VS0_DESMOT").And.ExistChav("VSQ",DTOS(M->VSQ_DATMAN)+M->VSQ_MOTIVO,1,"EXICOMCAD"))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_VALOA130ºAutor  ³Emilton            º Data ³  08/30/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Valida duplicidade                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VALOA130(nOpc)
            
Local nValLin:=0

FG_MEMVAR()
        
If !aCols[n,Len(aCols[n])]   

	If nOpc==3 .And. !ExistChav("VSG",M->VSQ_NUMIDE+"A"+M->VSG_CODVEN)
	
		Return(.f.)     
	
	EndIf
	
	For nValLin:=1 to Len(aCols)
	    
		If !aCols[nValLin,Len(aCols[nValLin])] .And. aCols[nValLin,FG_POSVAR("VSG_CODVEN")] == M->VSG_CODVEN .and. nValLin#n
           
			Help("  ",1,"EXISTCHAV")
			Return(.f.)

		EndIf
	                           
	Next          

EndIf

Return(.t.)

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},; //Pesquisar
                    { STR0002 ,"OM130", 0 , 2} ,;  //Visualizar
                    { STR0003 ,"OM130", 0 , 3} ,;  //Incluir
                    { STR0004 ,"OM130", 0 , 4} ,;  //Alterar
                    { STR0005 ,"OM130", 0 , 5}}    //Excluir
Return aRotina
