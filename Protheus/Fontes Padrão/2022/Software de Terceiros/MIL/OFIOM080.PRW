#INCLUDE "ofiom080.ch"
#INCLUDE "protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIOM080 ³ Autor ³  Emilton              ³ Data ³ 17/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Agendamento de Clientes para Oficina                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico  (Modelo3)                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OFIOM080
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0006)   //"Agendamento de Clientes - Oficina"
Private cIndex , cChave , cCond , nIndex := 0
Private aMemos  := {{"VSO_OBSMEM","VSO_OBSERV"}}
If !Pergunte("OFM080",.t.)
   Return .t.
EndIf
DbSelectArea("VSO")
cIndex  := CriaTrab(nil,.f.)
cChave  := 'VSO_FILIAL+DtoS(VSO_DATAGE)+VSO_HORAGE'
cCond   := "dtos(VSO_DATAGE) >='"+dtos(MV_PAR01)+"' .and. dtos(VSO_DATAGE) <= '"+dtos(MV_PAR02)+"'"
IndRegua("VSO",cIndex,cChave,,cCond,STR0007) //Selecionando Registros
DbSelectArea("VSO")
nIndex := RetIndex("VSO")
#IFNDEF TOP
   dbSetIndex(cIndex+ordBagExt())
#ENDIF
dbSetOrder(nIndex+1)
mBrowse( 6, 1,22,75,"VSO")
dbSelectArea("VSO")
RetIndex()
DbsetOrder(1)
#IFNDEF TOP
   If File(cIndex+OrdBagExt())
      fErase(cIndex+OrdBagExt())
   Endif
#ENDIF
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OM080     ºAutor  ³Emilton             º Data ³  17/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Monta Tela                                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Oficina                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function OM080(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0 
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk
Local nPosRec  :=0  // Posicao do registro dentro do aCols
Private aTELA[0][0],aGETS[0], nLenaCols := 0
Private aCols := {} , aHeader := {} , aCpoEnchoice := {}, nUsado := 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VSO",.t.)
DbSelectArea("VSO")

aCpoEnchoice  :={}
dbSelectArea("SX3")
DbSetOrder(1)
dbSeek("VSO")
While !Eof().and.(x3_arquivo=="VSO")
   If X3USO(x3_usado).and.cNivel>=x3_nivel .And. !(Alltrim(X3_CAMPO) $ [VSO_NUMIDE/VSO_NUMOSV])
      AADD(aCpoEnchoice,x3_campo)
      If nOpc == 3
         &("M->"+Alltrim(x3_campo)) := Criavar(x3_campo)
      EndIf
   Endif
   dbSkip()
End

DbSelectArea("VSO")
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
dbSeek("VSP")
aHeader:={}
While !Eof().And.(x3_arquivo=="VSP")
  If X3USO(x3_usado).And.cNivel>=x3_nivel .And. !(Alltrim(X3_CAMPO) $ [VSP_NUMIDE])
      nUsado:=nUsado+1
      aAdd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
          x3_tamanho, x3_decimal,x3_valid,;
          x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
      &("M->"+Alltrim(x3_campo)):= Criavar(x3_campo)      
   Endif  
   dbSkip()
EndDo

// Inclui coluna de registro atraves de funcao generica
dbSelectArea("VSP")
ADHeadRec("VSP",aHeader)
// Posicao do registro
nPosRec:=Len(aHeader)
nUsado :=Len(aHeader)

dbSelectArea("VSP")
dbSetOrder(1)
dbSeek(xFilial("VSP")+VSO->VSO_NUMIDE)

If nOpc == 3 .Or. !Found()
   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.
   For _ni:=1 to nUsado
		If IsHeadRec(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := 0
		ElseIf IsHeadAlias(aHeader[_ni,2])
			aCols[Len(aCols),_ni] := "VSP"
		Else	
      	aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
      EndIf
   Next
Else
   aCols:={}              
   While !eof() .And. VSP->VSP_FILIAL == xFilial("VSP") .and. VSP->VSP_NUMIDE == VSO->VSO_NUMIDE
       aAdd(aCols,Array(nUsado+1))
       For _ni:=1 to nUsado
			 && verifica se e a coluna de controle do walk-thru
			 If IsHeadRec(aHeader[_ni,2])
				 aCols[Len(aCols),_ni] := VSP->(RecNo())
			 ElseIf IsHeadAlias(aHeader[_ni,2])
				 aCols[Len(aCols),_ni] := "VSP"
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
   cTitulo       :=STR0006   //Agendamento de Clientes - Oficina
   cAliasEnchoice:="VSO"
   cAliasGetD    :="VSP"
   cLinOk        :="If( FS_VALOA080() , FG_OBRIGAT() , .f. )"
   cTudOk        :="AllwaysTrue()"
   cFieldOk      :="FG_MEMVAR()"
  
   DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 28,80	of oMainWnd
      EnChoice(cAliasEnchoice,nReg,nOpcE,,,,aCpoEnchoice,{15,1,70,315},,3,,,,,,.F.)
      oGetDados := MsGetDados():New(075,001,143,315,nOpcG,cLinOk,cTudOk,"",If(nOpcG > 2 .and. nOpcg < 5,.t.,.f.),,,,,cFieldOk)
      oGetDados:oBrowse:bChange    := {|| FG_AALTER("VSP",nLenaCols,oGetDados) }
   ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| if(oGetDados:TudoOk().And.Obrigatorio(aGets,aTela).And.FS_OA080GRA(nOpc),oDlg:End(),.f.) },{|| oDlg:End() })

Endif
DbSelectArea("VSO")
dbSetOrder(nIndex+1)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³OFIOA080  ºAutor  ºEmilton             º Data º  17/09/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_OA080GRA(nOpc,lGrvCEV)
Local lRet      := .t.
Local ix1       := 0
Local aVetValid := {}
Local cGCAOCEV  := "", cCodVen := ""
Local lOk       := .t.
Local lExistORC := .f. 
Local cNroOrc   := ""
Local aPecOrc   := {}
Local aSrvOrc   := {}
Local cTesPad   := ""
Local cTipTem   := ""
Local cFormPad  := GetMv("MV_FMLPECA") // Formula Padrao de Pecas
Local cCodOpe   := GetNewPar("MV_OPESPGA","61") // Operacao Especial para Garantia
Local nTemPad   := 0
Local nValHor   := 0
Local lVO6_VALSER := VO6->(FieldPos("VO6_VALSER")) > 0
Local lVS3Found := .f.
Local lVS4Found := .f.
Private lMsHelpAuto := .f., lMsFinalAuto := .t.
Private aMemos  := {{"VSO_OBSMEM","VSO_OBSERV"}}
Default lGrvCEV := .f.
If FunName() == "OFIOM350"
   lGrava := .t.
Endif

If "'"$cFormPad .or. '"'$cFormPad
	cFormPad := &cFormPad // Retirar as aspas ' simples
EndIf
If M->VSO_DATAGE < dDataBase
	MSGSTOP( STR0012 ) //Data informada menor que a data atual!
	Return(.f.)
EndIf
If !FS_HORAGE()
	Return(.f.)    
EndIf
//If !FS_VALUSR()
//	Return(.f.)    
//EndIf

&& Grava dados
lMsHelpAuto  := .t.
lMsFinalAuto := .f.
            
If nOpc != 2
                                
   Begin Transaction

      dbSelectArea("VSO")
      dbSetOrder(1)
      dbSeek(xFilial("VSO") + M->VSO_NUMIDE )

      && Grava arquivo pai
      If Inclui .or. Altera

         If !RecLock("VSO", !Found() )
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break
         EndIf

         FG_GRAVAR("VSO")
         If Inclui
            VSO_NUMIDE := GetSXENum("VSO","VSO_NUMIDE")
            ConfirmSx8()
         EndIf

			MSMM(,TamSx3("VSO_OBSERV")[1],,&(aMemos[1][2]),1,,,"VSO","VSO_OBSMEM")

         MsUnlock()

      EndIf

      For ix1:=1 to len(aCols)

         If Empty(aCols[ix1,FG_POSVAR("VSP_CODGRU")]) .and. Empty(aCols[ix1,FG_POSVAR("VSP_CODINC")])
            Loop
         EndIf
         DbSelectArea("VSP")
         DbSetOrder(1)
         DbSeek(xFilial("VSP")+VSO->VSO_NUMIDE+aCols[ix1,FG_POSVAR("VSP_CODGRU")]+aCols[ix1,FG_POSVAR("VSP_CODINC")])

         If (nOpc == 3 .Or. nOpc == 4) .And. !(aCols[ix1,Len(aCols[ix1])])

            If !RecLock("VSP", !Found() )
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break                           
            EndIf
            
            FG_GRAVAR("VSP",aCols,aHeader,ix1)
            VSP->VSP_FILIAL := xFilial("VSP")
            VSP->VSP_NUMIDE := VSO->VSO_NUMIDE
            VSP->VSP_CODGRU := aCols[ix1,FG_POSVAR("VSP_CODGRU")]
            VSP->VSP_CODINC := aCols[ix1,FG_POSVAR("VSP_CODINC")]
            MsUnlock()
              
         ElseIf Found() .And. nLenaCols>=ix1

            If VSO->VSO_NUMOSV != Space(08)
               Help("  ",1,"AGJAATEND")
               lRet := .f.
               DisarmTransaction()
               Break                           
            EndIf
            
            aVetValid := {}
            //aAdd(aVetValid,{"VO3" , "VO3_TIPTEM+VO3_PROREQ" , VOW->VOW_TIPTEM+VOW->VOW_CODPRO  , NIL })

            If !FG_DELETA(aVetValid)
               lRet := .f.
               DisarmTransaction()
               Break
            EndIf
            
            If !RecLock("VSP",.F.,.T.)
               Help("  ",1,"REGNLOCK")
               lRet := .f.
               DisarmTransaction()
               Break               
            EndIf
            
            dbdelete()
            MsUnlock()
            WriteSx2("VSP")
            
         EndIf

      Next          

      If nOpc == 5

			cNroOrc := VSO->VSO_NUMORC
         If !RecLock("VSO",.F.,.T.)
            Help("  ",1,"REGNLOCK")
            lRet := .f.
            DisarmTransaction()
            Break
         EndIf
         dbdelete()
         MsUnlock()
         WriteSx2("VSO")
			
			//////////////////////////////////////////////////////////////////////////
			// EXCLUIR ORCAMENTO, PECAS e SERVICOS // Andre Luis Almeida - 25/05/09 //
			//////////////////////////////////////////////////////////////////////////
			   DbSelectArea("VS1")
			   DbSetOrder(1)
			   If DbSeek(xFilial("VS1")+cNroOrc)
			   	If Empty(VS1->VS1_NUMOSV) .and. Empty(VS1->VS1_NUMNFI)
						DbSelectArea("VS1")
			         If !RecLock("VS1",.F.,.T.)
			            Help("  ",1,"REGNLOCK")
			            lRet := .f.
		   	         DisarmTransaction()
		      	      Break
		         	EndIf
			         dbdelete()
			         MsUnlock()
			         WriteSx2("VS1")
						DbSelectArea("VS3")
						DbSetOrder(1)
						DbSeek(xFilial("VS3")+cNroOrc) // PECAS
						While !Eof() .and. xFilial("VS3")==VS3->VS3_FILIAL .and. cNroOrc==VS3->VS3_NUMORC
				         If !RecLock("VS3",.F.,.T.)
				            Help("  ",1,"REGNLOCK")
				            lRet := .f.
				            DisarmTransaction()
				            Break
				         EndIf
				         dbdelete()
				         MsUnlock()
				         WriteSx2("VS3")
							DbSelectArea("VS3")
							DbSkip()
						EndDo
						DbSelectArea("VS4")
						DbSetOrder(1)
						DbSeek(xFilial("VS4")+cNroOrc) // SERVICOS
						While !Eof() .and. xFilial("VS4")==VS4->VS4_FILIAL .and. cNroOrc==VS4->VS4_NUMORC
				         If !RecLock("VS4",.F.,.T.)
				            Help("  ",1,"REGNLOCK")
				            lRet := .f.
				            DisarmTransaction()
				            Break
				         EndIf
				         dbdelete()
				         MsUnlock()
				         WriteSx2("VS4")
							DbSelectArea("VS4")
							DbSkip()
						EndDo
			    	EndIf
		    	EndIf							
			//////////////////////////////////////////////////////////////////////////

      EndIf
      
		//////////////////////////////////////////////////////////////////////////
      // Cria ORCAMENTO qdo Agendto Garantia // Andre Luis Almeida - 25/05/09 //
		//////////////////////////////////////////////////////////////////////////
      If (nOpc == 3 .Or. nOpc == 4)
	      If VSP->(FieldPos("VSP_GARANT")) > 0 .and. GetNewPar("MV_IOSVORC","1") == "1" // Cria Orcamento somente qdo Importacao for para a OS.
		      If !Empty(VSO->VSO_NUMORC)
      			lExistORC := .t.
				   DbSelectArea("VS1")
				   DbSetOrder(1)
				   If DbSeek(xFilial("VS1")+VSO->VSO_NUMORC)
			   		If !Empty(VS1->VS1_NUMOSV) .or. !Empty(VS1->VS1_NUMNFI)
			            lOk := .f.
				   	EndIf
					EndIf
				EndIf
				If lOk
					lOk := .f.
		      	// Levanta Pecas e Servicos por Inconveniente/Tarefa //
			      For ix1:=1 to len(aCols)
		   	      If Empty(aCols[ix1,FG_POSVAR("VSP_CODGRU")]) .and. Empty(aCols[ix1,FG_POSVAR("VSP_CODINC")])
			            Loop
			         EndIf
			         DbSelectArea("VAJ")
			         DbSetOrder(1)
			         If DbSeek(xFilial("VAJ")+VSO->VSO_CODMAR+aCols[ix1,FG_POSVAR("VSP_CODGRU")]+aCols[ix1,FG_POSVAR("VSP_CODINC")])
						   While !Eof() .and. VAJ->VAJ_FILIAL+VAJ->VAJ_CODMAR+VAJ->VAJ_CODGRU+VAJ->VAJ_CODINC == xFilial("VAJ")+VSO->VSO_CODMAR+aCols[ix1,FG_POSVAR("VSP_CODGRU")]+aCols[ix1,FG_POSVAR("VSP_CODINC")]
						   	If !Empty(VAJ->VAJ_CODPEC)
						   		aadd(aPecOrc,{(aCols[ix1,Len(aCols[ix1])]),aCols[ix1,FG_POSVAR("VSP_GARANT")],VAJ->VAJ_CODMAR,VAJ->VAJ_GRUPEC,VAJ->VAJ_CODPEC,VAJ->VAJ_QTDPEC})
						   	Else
						   		aadd(aSrvOrc,{(aCols[ix1,Len(aCols[ix1])]),aCols[ix1,FG_POSVAR("VSP_GARANT")],VAJ->VAJ_CODMAR,VAJ->VAJ_CODSER,VAJ->VAJ_TIPSER})
						   	EndIf
						   	If Empty(cTipTem)
							   	cTipTem := VAJ->VAJ_TIPTEM
							 	EndIf
							 	If !(aCols[ix1,Len(aCols[ix1])]) .and. aCols[ix1,FG_POSVAR("VSP_GARANT")]=="1"
							 		lOk := .t.							 	
							 	EndIf
					         DbSelectArea("VAJ")
						      DbSkip()
							EndDo
		      	   EndIf	
					Next
					If len(aPecOrc)+len(aSrvOrc) > 0
			      	If lExistORC .or. ( lOk .and. MsgYesNo(STR0019,STR0011) ) // "Deseja incluir um Orcamento de Garantia?" / "Atencao !!"
							DbSelectArea("VV1")
							DbSetOrder(2)
							DbSeek(xFilial("VV1")+VSO->VSO_GETKEY)
			      		If !lExistORC
								// Criar novo VS1 //
								DbSelectArea("VS1")
					         If !RecLock("VS1",.T.)
					            Help("  ",1,"REGNLOCK")
					            lRet := .f.
					            DisarmTransaction()
					            Break
					         EndIf
					         VS1->VS1_FILIAL := xFilial("VS1")
								VS1->VS1_NUMORC := GetSXENum("VS1","VS1_NUMORC")
							  	VS1->VS1_TIPORC := "2" // 2-Oficina
								VS1->VS1_CHAINT := VV1->VV1_CHAINT
								VS1->VS1_CLIFAT := VSO->VSO_PROVEI
								VS1->VS1_LOJA   := VSO->VSO_LOJPRO
								VS1->VS1_NCLIFT := VSO->VSO_NOMPRO
								VS1->VS1_CODMAR := VSO->VSO_CODMAR
								VS1->VS1_DATORC := dDataBase
								VS1->VS1_HORORC := val(subs(time(),1,2)+subs(time(),4,2))
								VS1->VS1_TIPTEM := cTipTem
								VS1->VS1_FORMUL := cFormPad
				            ConfirmSX8()
								MsUnLock()							
							EndIf
							// Atualiza PECAS //
							For ix1 := 1 to len(aPecORC)
								DbSelectArea("VS3")
								DbSetOrder(2)
								DbSeek(xFilial("VS3")+VS1->VS1_NUMORC+aPecORC[ix1,4]+aPecORC[ix1,5]) // Grupo + CodIte
								lVS3Found := Found()
								If aPecORC[ix1,1] .or. aPecORC[ix1,2]=="0"
									If lVS3Found
							         If !RecLock("VS3",.F.,.T.)
							            Help("  ",1,"REGNLOCK")
							            lRet := .f.
							            DisarmTransaction()
							            Break
							         EndIf
							         dbdelete()
							         MsUnlock()
							         WriteSx2("VS3")
									EndIf
								Else
									DbSelectArea("SB1")
									DbSetOrder(7)
						   	   DbSeek( xFilial("SB1") + aPecORC[ix1,4] + aPecORC[ix1,5] )
									DbSelectArea("SB2")
									DbSetOrder(1)
						   	   DbSeek( xFilial("SB2") + SB1->B1_COD + SB1->B1_LOCPAD )
									DbSelectArea("SB5")
									DbSetOrder(1)
						   	   DbSeek( xFilial("SB5") + SB1->B1_COD )
									DbSelectArea("SF4")
									DbSetOrder(1)
						   	   DbSeek( xFilial("SF4") + SB1->B1_TS )
									DbSelectArea("VEB")
									DbSetOrder(1)
									DbSeek( xFilial("VEB") + cCodOpe )
			               	If !Empty(VEB->VEB_FORMUL)
										cFormPad := VEB->VEB_FORMUL
									EndIf
						         cTesPad  := SB1->B1_TS
			               	If !Empty(VEB->VEB_TESPAD)
				               	cTesPad := VEB->VEB_TESPAD
									EndIf															
									DbSelectArea("VEL")
									DbSetOrder(1)
									If DbSeek(xFilial("VEL")+cCodOpe+Left(SB1->B1_ORIGEM,1)+SF4->F4_SITTRIB)
									   cTesPad := VEL->VEL_TESESP
									EndIf
									DbSelectArea("VS3")
						         If !RecLock("VS3",!lVS3Found)
						            Help("  ",1,"REGNLOCK")
						            lRet := .f.
						            DisarmTransaction()
						            Break
						         EndIf
									VS3->VS3_FILIAL := xFilial("VS3")
									VS3->VS3_NUMORC := VS1->VS1_NUMORC
									VS3->VS3_GRUITE := aPecORC[ix1,4]
									VS3->VS3_CODITE := aPecORC[ix1,5]
									VS3->VS3_QTDITE := aPecORC[ix1,6]
									VS3->VS3_CODTES := cTesPad
									VS3->VS3_FORMUL := cFormPad
									VS3->VS3_VALPEC := IIf(!Empty(cFormPad),FG_FORMULA(cFormPad),0)
									VS3->VS3_VALTOT := ( VS3->VS3_VALPEC * VS3->VS3_QTDITE )
									MsUnLock()
								EndIf
	                  Next
	                  lOk := .f.
	                  // Alterar SEQUEN do VS3 //
	                  ix1 := 0
							DbSelectArea("VS3")
							DbSetOrder(1)
							DbSeek(xFilial("VS3")+VS1->VS1_NUMORC)
						   While !Eof() .and. VS3->VS3_FILIAL+VS3->VS3_NUMORC == xFilial("VS3")+VS1->VS1_NUMORC
								ix1++
					         If !RecLock("VS3",.f.)
					            Help("  ",1,"REGNLOCK")
					            lRet := .f.
					            DisarmTransaction()
					            Break
					         EndIf
								VS3->VS3_SEQUEN := strzero(ix1,3)
								MsUnLock()
								lOk := .t.
					         DbSelectArea("VS3")
						      DbSkip()
							EndDo
							// Atualiza SERVICOS //
							For ix1 := 1 to len(aSrvORC)
								DbSelectArea("VS4")
								DbSetOrder(2)
								DbSeek(xFilial("VS4")+VS1->VS1_NUMORC+aSrvORC[ix1,4]) // Servico
								lVS4Found := Found()
								If aSrvORC[ix1,1] .or. aSrvORC[ix1,2]=="0"
									If lVS4Found
							         If !RecLock("VS4",.F.,.T.)
							            Help("  ",1,"REGNLOCK")
							            lRet := .f.
							            DisarmTransaction()
							            Break
							         EndIf
							         dbdelete()
							         MsUnlock()
							         WriteSx2("VS4")
									EndIf
								Else      
									DbSelectArea("VO6")
									DbSetOrder(2)
									DbSeek(xFilial("VO6")+aSrvORC[ix1,3]+aSrvORC[ix1,4]) 
									nTemPad := FG_TemPad(VV1->VV1_CHAINT,aSrvORC[ix1,4],"4",,aSrvORC[ix1,3])
									DbSelectArea("VOK")
									DbSetOrder(1)
									DbSeek(xFilial("VOK")+aSrvORC[ix1,5]) 
									nValHor := If(VOK->VOK_INCMOB$"0/2/5/6",0,FG_VALHOR(cTipTem,dDataBase))
									DbSelectArea("VS4")
						         If !RecLock("VS4",!lVS4Found)
						            Help("  ",1,"REGNLOCK")
						            lRet := .f.
						            DisarmTransaction()
						            Break
						         EndIf
									VS4->VS4_FILIAL := xFilial("VS4")
									VS4->VS4_NUMORC := VS1->VS1_NUMORC
									VS4->VS4_TIPSER := aSrvORC[ix1,5]
									VS4->VS4_GRUSER := VO6->VO6_GRUSER
									VS4->VS4_CODSER := aSrvORC[ix1,4]
									VS4->VS4_TEMPAD := nTemPad
									If lVO6_VALSER
										If VO6->VO6_VALSER > 0 // Valor Fixo para o Servico
											VS4->VS4_VALSER := VO6->VO6_VALSER
											VS4->VS4_VALTOT := VO6->VO6_VALSER
										EndIf
									EndIf
									VS4->VS4_VALHOR := nValHor
									If VS4->VS4_VALSER <= 0
										VS4->VS4_VALSER := VS4->VS4_VALHOR
										VS4->VS4_VALTOT := ( VS4->VS4_TEMPAD / 100 ) * VS4->VS4_VALHOR
									EndIf
									MsUnLock()
								EndIf
	                  Next
	                  // Alterar SEQUEN do VS4 //
							ix1 := 0
							DbSelectArea("VS4")
							DbSetOrder(1)
							DbSeek(xFilial("VS4")+VS1->VS1_NUMORC)
						   While !Eof() .and. VS4->VS4_FILIAL+VS4->VS4_NUMORC == xFilial("VS4")+VS1->VS1_NUMORC
								ix1++
					         If !RecLock("VS4",.f.)
					            Help("  ",1,"REGNLOCK")
					            lRet := .f.
					            DisarmTransaction()
					            Break
					         EndIf
								VS4->VS4_SEQUEN := strzero(ix1,3)
								MsUnLock()
								lOk := .t.
								DbSelectArea("VS4")
						      DbSkip()
							EndDo
							// Deletar VS1 caso nao tenha nenhuma Peca e Servico no Orcamento //
							If !lOk
								DbSelectArea("VS1")
					         If !RecLock("VS1",.F.,.T.)
					            Help("  ",1,"REGNLOCK")
					            lRet := .f.
		   			         DisarmTransaction()
		      			      Break
		         			EndIf
			         		dbdelete()
				         	MsUnlock()
					         WriteSx2("VS1")
								DbSelectArea("VSO")
					         If !RecLock("VSO",.F.)
		   			         Help("  ",1,"REGNLOCK")
		      			      lRet := .f.
			      	   	   DisarmTransaction()
				      	      Break
		   		      	EndIf
								VSO->VSO_NUMORC := ""
								MsUnLock()
						  	EndIf
	                  // Atualiza o Numero do Orcamento (NOVO) no VSO - Agenda Oficina //
							If !lExistORC
								DbSelectArea("VSO")
					         If !RecLock("VSO",.F.)
		   			         Help("  ",1,"REGNLOCK")
		      			      lRet := .f.
			      	   	   DisarmTransaction()
				      	      Break
		   		      	EndIf
								VSO->VSO_NUMORC := VS1->VS1_NUMORC
								MsUnLock()
								MsgInfo(STR0020+" '"+VS1->VS1_NUMORC+"'",STR0011) // "Orcamento gerado com sucesso!" / "Atencao !!"
							EndIf
						EndIf
					EndIf
				EndIf
			EndIf
		EndIf
		//////////////////////////////////////////////////////////////////////////

      If lGrvCEV
			                                     
			cGCAOCEV := GetNewPar("MV_GCAOCEV","")          	
			If !Empty( cGCAOCEV )
				If MsgYesNo(STR0014,STR0011) //Deseja gerar contato de confirmacao? # Atencao

					cCodVen := Substr(cGCAOCEV,5,6)
               DbSelectArea("VAI")
               DbSetOrder(4)
               If DbSeek( xFilial("VAI") + __cUserID ) .And. !Empty(VAI->VAI_CODVEN)
						cCodVen := VAI->VAI_CODVEN
               EndIf
					FS_AGENDA( Left(cGCAOCEV,1) , ( VSO->VSO_DATAGE-Val(Substr(cGCAOCEV,2,3)) ) , cCodVen , VSO->VSO_PROVEI , VSO->VSO_LOJPRO , , VSO->VSO_NUMOSV )

		      EndIf         
	      EndIf         
	      
      EndIf

   End Transaction   

Endif                      

If !lRet
   MostraErro()
EndIf 
lMsHelpAuto := .f. 

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
Function FS_VALOA080()
Local nReg    := 0
Local ix1     := 0   
FG_MEMVAR()
If ReadVar() $ "M->VSP_CODGRU/M->VSP_CODINC"
   If !ExistChav( "VSP" , M->VSO_NUMIDE+M->VSP_CODGRU+M->VSP_CODINC )
      Return(.f.)
   EndIf         
   //If aScan(aCols, { |x| x[FG_POSVAR("VSP_CODGRU")] + x[FG_POSVAR("VSP_CODINC")] == M->VSP_CODGRU+M->VSP_CODINC\ } ) != 0
   //   Help("  ",1,"EXISTCHAV")
   //   Return(.f.)
   //EndIf
EndIf
For ix1 := 1 to len(aCols)
   If len(aCols[ix1]) >= nUsado+1
	   If aCols[ix1,nUsado+1]
	      loop
	   EndIf
	   If FG_POSVAR("VSP_CODGRU") > 0 .and. FG_POSVAR("VSP_CODINC") > 0
		   If aCols[ix1,FG_POSVAR("VSP_CODGRU")] == M->VSP_CODGRU .and. aCols[ix1,FG_POSVAR("VSP_CODINC")] == M->VSP_CODINC
		      nReg ++
	   	   If nReg > 1
	      	   Help("  ",1,"EXISTCHAV")
		         Return( .f. )
		      EndIf
	   	Else 
		      Loop
		   EndIf
	   EndIf
   EndIf
Next              
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FS_GetKey³ Autor ³  Emilton              ³ Data ³ 19/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Apresenta Dados de Veiculos para Orcamento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GETKEYA()
Local lReturn   := .f.
Local cSelect   := Alias()
Local aCampoVO5 := {}
Private aTELA[0][0],aGETS[0]
If Empty(M->VSO_GETKEY)
	Return(.t.)
EndIf
lReturn := FG_POSVEI("M->VSO_GETKEY",)
if !lReturn 
   return(.t.)
endif
/*
If Empty(VV1->VV1_PROATU) .or. Empty(VV1->VV1_LJPATU)
   Help(" ",1,"OM010OBR")
   Return .f.
EndIf
*/
DBSelectArea("VV1")
M->VSO_GETKEY := VV1->VV1_CHASSI
FS_ALINVEI("A")

If FindFunction("OFA1100016_PesquisaCampanha") .And. VOU->(FieldPos("VOU_SERINT")) > 0
	OFA1100016_PesquisaCampanha(VV1->VV1_CHASSI)
EndIf

DBSelectArea("VV1")
M->VSO_CHASSI := VV1->VV1_CHASSI
M->VSO_CHAINT := VV1->VV1_CHAINT
M->VSO_PLAVEI := VV1->VV1_PLAVEI
M->VSO_CODFRO := VV1->VV1_CODFRO
if !FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)
   aCampoVO5 := {}
   dbSelectArea("SX3")
   dbSeek("VO5")
   While !EOF() .And. (X3_ARQUIVO == "VO5")
      IF X3USO(X3_USADO) .and. cNivel >= X3_NIVEL
         AADD(aCampoVO5,X3_CAMPO)
      EndIF
      dbSkip()
   EndDO
   cCadastro := OemToAnsi(STR0006) //Agendamento de Clientes - Oficina
   dbSelectArea("VO5")
   If AxInclui("VO5",0,3,aCampoVO5) != 1
      dbSelectArea("VSO")
      cCadastro := OemToAnsi(STR0006) //Agendamento de Clientes - Oficina
      Return(.f.)
   EndIf
   cCadastro := OemToAnsi(STR0006) //Agendamento de Clientes - Oficina
endif
dbSelectArea("VSO")
if FG_SEEK("VO5","VV1->VV1_CHAINT",1,.f.)
   FG_SEEK("VV2","VV1->VV1_CODMAR+VV1->VV1_MODVEI",1,.f.)
   FG_SEEK("VVC","VV1->VV1_CODMAR+VV1->VV1_CORVEI",1,.f.)
   FG_SEEK("SA1","VV1->VV1_PROATU+VV1->VV1_LJPATU",1,.f.)
   DbSelectArea("VE1")
   DbSetOrder(1)
   DbSeek(xFilial("VE1") + VV1->VV1_CODMAR)
   M->VSO_CODMAR := VE1->VE1_CODMAR
   M->VSO_DESMAR := VE1->VE1_DESMAR
   M->VSO_MODVEI := VV2->VV2_MODVEI
   M->VSO_SEGMOD := VV2->VV2_SEGMOD
   M->VSO_DESMOD := VV2->VV2_DESMOD
   M->VSO_CHASSI := VV1->VV1_CHASSI
   M->VSO_CODFRO := VV1->VV1_CODFRO
   M->VSO_PLAVEI := VV1->VV1_PLAVEI
   M->VSO_DESCOR := VVC->VVC_DESCRI
   M->VSO_PROVEI := SA1->A1_COD
   M->VSO_NOMPRO := SA1->A1_NOME
   M->VSO_FATPAR := SA1->A1_COD
   M->VSO_LOJPRO := SA1->A1_LOJA
   M->VSO_LOJA   := SA1->A1_LOJA
   M->VSO_NOMFAT := SA1->A1_NOME
   M->VSO_ENDPRO := SA1->A1_END
   M->VSO_CIDPRO := SA1->A1_MUN
   M->VSO_ESTPRO := SA1->A1_EST
   M->VSO_FONPRO := SA1->A1_TEL
   M->VSO_EMAIL  := SA1->A1_EMAIL
   M->VSO_CODMAR := VE1->VE1_CODMAR
else
   M->VSO_DESMAR := ""
   M->VSO_DESMOD := ""
   M->VSO_CHASSI := ""
   M->VSO_CODFRO := ""
   M->VSO_PLAVEI := ""
   M->VSO_DESCOR := ""
   M->VSO_PROVEI := ""
   M->VSO_NOMPRO := ""
   M->VSO_ENDPRO := ""
   M->VSO_CIDPRO := ""
   M->VSO_ESTPRO := ""
   M->VSO_FONPRO := ""
   M->VSO_LOJPRO := ""
   return(.f.)
endif
dbSelectArea(cSelect)              
If !FS_VERAGE(M->VSO_DATAGE,M->VSO_GETKEY,If(Altera,VSO->(Recno()),0))
   Return .f.
EndIf
//If Type("aFicha") # "U"
//	FS_CRRFICHA(M->VSO_GETKEY)
//EndIf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FS_VERAGE³ Autor ³  Emilton              ³ Data ³ 19/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Apresenta Dados de Veiculos para Orcamento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_VERAGE(dDatAge,cGetKey,nRecAtu)
Local lReturn   := .t.
Local cSelect   := Alias()
Local nOrdVSO   := VSO->(IndexOrd())
Local nRecVSO   := VSO->(Recno())
Local nRecVV1   := VV1->(Recno())
DbSelectArea("VSO")
DbSetOrder(2)
DbSeek( xFilial("VSO") + DtoS(dDatAge) )
While !Eof() .and. xFilial("VSO") == VSO->VSO_FILIAL .and. VSO->VSO_DATAGE == dDatAge
   If nRecAtu != VSO->(Recno())
		If !( Alltrim(VSO->VSO_STATUS) $ "3/4" )
			DbSelectArea("VV1")
			DbSetOrder(2)
	      If DbSeek( xFilial("VV1") + VSO->VSO_GETKEY )
	         lReturn := .t.
	      Else
				DbSetOrder(6)
		      If DbSeek( xFilial("VV1") + VSO->VSO_GETKEY )
	            lReturn := .t.
	         Else
					DbSetOrder(9)
			      If DbSeek( xFilial("VV1") + VSO->VSO_GETKEY )
	               lReturn := .t.
	            Else
						DbSetOrder(1)
				      If DbSeek( xFilial("VV1") + VSO->VSO_GETKEY )
	                  lReturn := .t.
	               Endif
	            EndIf
	         EndIf
	      EndIf
	      If Alltrim(cGetKey) == Alltrim(VV1->VV1_CHAINT) .or. Alltrim(cGetKey) == Alltrim(VV1->VV1_CODFRO) .or. ;
	      	Alltrim(cGetKey) == Alltrim(VV1->VV1_CHASSI) .or. Alltrim(cGetKey) == Alltrim(VV1->VV1_PLAVEI)
	         Posicione("VAI",4,xFilial("VAI")+__cUserID,"VAI_CODTEC")
	         lReturn := .f.
	         If MsgYesNo(OemToAnsi(STR0008)+transform(VSO->VSO_HORAGE,"@r 99:99")+OemToAnsi(STR0009)+VSO->VSO_GETKEY+OemToAnsi(STR0010)+VAI->VAI_NOMTEC+Chr(10)+Chr(13)+OemToAnsi(STR0015),OemToAnsi(STR0011)) //Deseja fazer novo agendamento?
		         lReturn := .t.
	         EndIf
	         Exit
	      EndIf
	   EndIf
   EndIf
	dbSelectArea("VSO")
   dbSkip()
EndDo
VV1->(dbGoTo(nRecVV1))
VSO->(DbSetOrder(nOrdVSO))
VSO->(dbGoTo(nRecVSO))
dbSelectArea(cSelect)              
Return lReturn

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡Æo    ³ FS_HORAGE³ Autor ³  Emilton              ³ Data ³ 20/09/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡Æo ³ Apresenta Dados de Veiculos para Orcamento                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_HORAGE(nHorAge)
If !( Substr(StrZero(Val(M->VSO_HORAGE),4),3,2) $ "00/15/30/45" )
	MSGSTOP( STR0016 +chr(13)+chr(10)+ STR0017 +chr(13)+chr(10)+ STR0018 )//Hora invalida! # Somente e permitida hora com minutos iguais a 00, 15, 30 e 45! # Ex: 8:00,11:15,13:30 e 17:45. 
   Return .f.
EndIf
If dDataBase == M->VSO_DATAGE
	dbSelectArea("VSO")
	dbSetOrder(1)
	dbSeek(xFilial("VSO") + M->VSO_NUMIDE )
   If ( VSO->(Found()) .And. VSO->VSO_HORAGE # M->VSO_HORAGE .And. Val(M->VSO_HORAGE) < val(left(time(),2)+substr(time(),4,2)) ;
   	.Or. !VSO->(Found()) .And. Val(M->VSO_HORAGE) < val(left(time(),2)+substr(time(),4,2)) )
      Help("  ",1,"HORAGEERR") // Hora do Agendamento Menor que a Hora atual
      Return .f.
   EndIf
EndIf
//If !FS_VALAGE()
//	Return(.f.)
//EndIf
Return .t.

User Function U_OFIOM080()
/*
OA270("VSK",VSK->(Recno()),3)          
GetwndDefault():Refresh()
*/
return .t.

Static Function MenuDef()
Local aRotina := { { STR0001 ,"axPesqui", 0 , 1},;  //Pesquisar
                     { STR0002 ,"OM080", 0 , 2} ,;  //Visualizar
                     { STR0003 ,"OM080", 0 , 3} ,;  //Incluir
                     { STR0004 ,"OM080", 0 , 4} ,;  //Alterar
                     { STR0005 ,"OM080", 0 , 5}}    //Excluir
Return aRotina