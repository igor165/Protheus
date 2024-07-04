#INCLUDE "PROTHEUS.CH"
#INCLUDE "MATA821.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ MATA821  ³ Autor ³ Gpe Santacruz         ³ Data ³05/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Clientes vs Grupo opcionales						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGAPCP                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Function MATA821()
Local cAliasSA1	:= "SA1"
Local lShowProc	:= .T.
Local cFiltro	:= ""
Local aQuery	:= {}

Private aRotina	  := MenuDef()              
Private cCadastro := OemToAnsi(STR0001) //-- Clientes X Grupo de Opcionais
				
dbSelectArea(cAliasSA1)
dbSetOrder(1)
MsSeek(xFilial(cAliasSA1))
FilBrowse(cAliasSA1, aQuery, cFiltro, lShowProc)
mBrowse( 6 , 1 , 22 , 75 , cAliasSA1) 

Return        

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³M821Mtto  ³ Autor ³ Gpe Santacruz         ³ Data ³05/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Enchoice y Getdados de Clientes vs Grupo opcionales	      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M821Mtto                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATA821                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function M821Mtto(cAlias,nReg,nOpc)
Local aArea     := GetArea()
Local aSvKeys	:= GetKeys()
Local aPosObj   := {}
Local aObjects  := {}
Local aSize     := {}
Local aInfo     := {}
Local aSDJRecnos:= {}
Local nOpcAcc1	:= 0
Local nx		:= 0
Local nMaxLin	:= 999
Local cCte		:= ''
Local cTda		:= ''
Local cLinOk	:= {||if (nopc==2 ,M821LINOK(),)}
Local cTodoOk	:= {||if (nopc==2 ,M821TODOOK(),)}
Local cfieldOk	:= "AllwaysTrue"
Local lSigue	:= .T.
Local lLocks	:= .F.
Local bGraba	:= {|| If(M821TODOOK(),(M821Graba(nOpc,cCte,cTda),oDlg:End()),)}
Local bCancela	:= {|| oDlg:End()}
Local oDlg 		:= NIL

Private oEnchSA1 
Private aTELA[0][0]
Private aGETS[0] 

Private oGetSHS 	:={}
Private aHeaderSHS 	:={}
Private nUsado		:=0

Private nPosGpo	:=0
Private nPosFam	:=0


dbSelectArea("SA1")
dbSelectArea("SDJ")

//Selecciona el tipo de acceso que habra en los getdados de acuerdo a la opcion seleccionada
If nOpc == 2  //actualizar
   nOpcAcc1 := 7   
   INCLUI := .T.
Else          
   nOpcAcc1 := 4
EndIf          

cCte := SA1->A1_COD
cTda := SA1->A1_LOJA  

If nOpc <> 2 //No es Actualizar
	If !ExistCpo("SDJ",cCte,1)
	   lSigue:= .f.
	EndIf
EndIf
If !lSigue  
	RestArea(aArea)
	RestKeys(aSvKeys,.T.)
	Return
EndIf

//-- Prepara botones de la barra de herramientas
CURSORWAIT()
	
//--Prepara información para los GetDados
dbSelectArea("SX3")
dbsetorder(1)
dbSeek("SDJ")
aHeaderSDJ := {}
nUsado := 0
Do While !EOF() .And. X3_ARQUIVO == "SDJ"
	If X3USO(X3_USADO) .And. cNivel >= X3_NIVEL  .And. !(ALLTrim(SX3->X3_CAMPO) $ "DJ_CLIENTE/DJ_TIENDA")
    	nUsado++
		aAdd(aHeaderSDJ,{ 	TRIM(X3Titulo()),X3_CAMPO, X3_PICTURE,X3_TAMANHO,;
							X3_DECIMAL,X3_VALID,X3_USADO,X3_TIPO,X3_F3,X3_CONTEXT,X3Cbox(),X3_RELACAO})
	Endif 
	dbskip()
EndDo

nPosGpo := GdFieldPos("DJ_GPOOPC",aHeaderSDJ)   //POSICION DEL GRUPO PARA USAR EN LA COSLTA STD  	
nPosFam := GdFieldPos("DJ_FAMILIA",aHeaderSDJ)   //POSICION DEL GRUPO PARA USAR EN LA COSLTA STD  	

//genera informacion del getdados 
aCols := {} 
SDJ->(dBSetOrder(1)) 
If SDJ->(dbSeek(xFilial("SDJ")+PadR(cCte,TamSX3("DJ_CLIENTE")[1])+cTda))
	Do While !SDJ->(EOF()) .And. SDJ->(DJ_FILIAL+DJ_CLIENTE+DJ_TIENDA) == xFilial("SDJ")+cCte+cTda
		aAdd(aCols,Array(nUsado+1))
		M->DJ_FAMILIA := SDJ->DJ_FAMILIA 
		M->DJ_GPOOPC := SDJ->DJ_GPOOPC
		M->DJ_ITEOPC := SDJ->DJ_ITEOPC

		For nX := 1 To nUsado
			If aHeaderSDJ[NX][10]<>'V' 
				aCols[Len(aCols)][nX] := &("SDJ->"+aHeaderSDJ[nX,2])
			Else
				aCols[Len(aCols)][nX] := Eval(&( "{ || " + AllTrim( aHeaderSDJ[nX,12] ) + " }" ))
			EndIf
		Next nX
		aCols[Len(aCols)][nUsado+1] := .F.
			
		//guardar numero de registro para bloqueo
	    aAdd(aSDJRecnos,SDJ->(Recno()))

	 	SDJ->(dbSkip())
	 EndDo
Else
	aAdd(aCols,Array(nUsado+1))
	M->DJ_FAMILIA := SPACE(TAMSX3("DJ_FAMILIA")[2])
	M->DJ_GPOOPC := SPACE(TAMSX3("DJ_GPOOPC")[2])
	M->DJ_ITEOPC := SPACE(TAMSX3("DJ_ITEOPC")[2])		

	For nX := 1 To nUsado  
		If aHeaderSDJ[NX][10]<>'V' 
			aCols[Len(aCols)][nX] := CriaVar("SDJ->"+aHeaderSDJ[nX,2],.T.)
		Else
			aCols[Len(aCols)][nX] := Eval(&( "{ || " + AllTrim( aHeaderSDJ[nX,12] ) + " }" ))
		EndIf
	Next nX
	aCols[Len(aCols)][nUsado+1] := .F. 
EndIf
			
//-- Bloquea los registros s Modificar o a Borrar
If !(lLocks := WhileNoLock("SDJ",aSDJRecnos,NIL,1,1,NIL,1))
	RestArea(aArea)
	RestKeys(aSvKeys,.T.) // Restaura as Teclas de Atalho                				   
	Return
EndIf

//-- Faz o  calculo automatico das dimensoes dos objetos 
aSize := MsAdvSize()
aAdd(aObjects,{10,10,.T.,.T.})   //VENTANA DEL ENCABEZADO     
aAdd(aObjects,{100,100,.T.,.T.}) //VENTANA DEL GETDADOS 

aInfo := {aSize[1],aSize[2],aSize[3],aSize[4],5,5}
aPosObj := MsObjSize(aInfo,aObjects,.T.)

CURSORARROW()	                      

DEFINE FONT oFont NAME "Arial" SIZE 0,-12 BOLD
DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 To aSize[6],aSize[5] of oMainWnd PIXEL
     	
oGroup:= tGroup():New(aPosObj[1,1],aPosObj[1,2],aPosObj[2,1]-5,aPosObj[2,4],,oDlg,,CLR_WHITE,.T.)   	
@aPosObj[1,1]+6,aPosObj[1,2]+10 SAY STR0002 +AllTrim(SA1->A1_COD) +" " +AllTrim(SA1->A1_LOJA) +" - " +AllTrim(SA1->A1_NOME) SIZE aPosObj[2,4]-10,07 OF oGroup PIXEL FONT oFont  //"Cliente: "
oGetSDJ := MsNewGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nopcacc1,cLinOk ,cTodoOk ,nil,NIL, 0, nMaxLin,cFieldOk ,; 
        		                             "","AllwaysTrue",  oDlg, aHeaderSDJ, aCols)        		                             

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,bGraba,bCancela)

//-- Libera registros bloqueados
For nX := 1 to Len(aSDJRecnos)
    FreeLocks("SDJ",aSDJRecnos[nX],.T.)
Next nX

RestArea(aArea)
RestKeys( aSvKeys , .T. ) // Restaura as Teclas de Atalho                				   
	
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³M821Graba ³ Autor ³ Gpe Santacruz         ³ Data ³24/08/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Graba, Modifica o Elimina los datos, segun opcion seleccio-³±±
±±³          ³ nada.                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M821Graba(aAlterEnch,nOpc,cLinea)                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1:Opcion de aRotina                                    ³±±
±±³          ³ ExpC1:Numero de orden de produccion                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ M821Mtto                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M821Graba(nOpc,cCte,cTda)
Local nx 	  := 0
Local ny	  := 0 
Local nPosDel := GdFieldPos("GDDELETED",oGetSDJ:aHeader)     

SDJ->(DBsetorder(1))

//-- Elimina encabezado y detalle
If NOPC==3 //Borrar
	If MsgYesNo(STR0008) //"Estas seguro de Eliminar?"
    	CURSORWAIT()	     
		Do While .T.
			If SDJ->(dbSeek(xFilial("SDJ")+PadR(cCte,TamSX3("DJ_CLIENTE")[1])+cTda))
		   		RecLock("SDJ",.f.)           
				SDJ->(DBDelete()) 
			 	SDJ->(MsUnLock())
			Else
		        Exit
		    EndIf
		EndDo
		CURSORARROW()	
	EndIf
EndIf

//-- Modifica Encabezado y Detalle
If nOpc == 2 //Actualizar
	CURSORWAIT()

	//Borra Detalle
	Do While .T.
		If SDJ->(dbSeek(xFilial("SDJ")+PadR(cCte,TamSX3("DJ_CLIENTE")[1])+cTda) )
			RecLock("SDJ",.F.)           
			SDJ->(DBDelete())
			SDJ->(MsUnLock())
	    Else
			Exit
		EndIf
	EndDo	  

  	//Graba Detalle
	For nX := 1 to Len(oGetSDJ:aCols)      
		If !oGetSDJ:aCols[nx,nPosDel]
			RecLock("SDJ",.T.)           
			SDJ->DJ_FILIAL := xFilial("SDJ")
			SDJ->DJ_CLIENTE := cCte
			SDJ->DJ_TIENDA := cTda
			For nY := 1 to Len(oGetSDJ:aHeader)
				If oGetSDJ:AHEADER[NY][10] <> 'V' //Excluye los campos virtuales        
					&("SDJ->"+oGetSDJ:aHeader[NY,2]) := oGetSDJ:aCols[nx,ny]
				EndIf
			Next nY
			SDJ->(MsUnLock())
		EndIf
	Next nX
	CURSORARROW()
EndIf

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³M821LINOK ³ Autor ³ Gpe Santacruz         ³ Data ³05/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida la linea del GetDados								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M821LINOK()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MsNewGetDados                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M821LINOK()                                
Local lRet		:= .T.
Local nPosDel	:= GdFieldPos("GDDELETED",oGetSDJ:aHeader)     
Local nPosPe	:= GdFieldPos("DJ_FAMILIA",oGetSDJ:aHeader)     
Local nPosOp	:= GdFieldPos("DJ_GPOOPC",oGetSDJ:aHeader)     
Local nPosIt	:= GdFieldPos("DJ_ITEOPC",oGetSDJ:aHeader)     
Local nx		:= 0

SBU->(dbsetorder(2))
SGA->(dbsetorder(1))
If !oGetSDJ:aCols[oGetSDJ:Nat,nPosDel]
	CURSORWAIT()
	If Empty(AllTrim(oGetSDJ:aCols[oGetSDJ:Nat,nPospe])) .And. Empty(AllTrim(oGetSDJ:aCols[oGetSDJ:Nat,nPosOp])) .Or. Empty(AllTrim(oGetSDJ:aCols[oGetSDJ:Nat,nPosIt]))
	    Aviso(STR0015,STR0010,{"Ok"}) //"Todos los datos son requeridos"
	    lRet := .F. 
	Else
		//Verifica que no est repetido el codigo de operador
		For nX := 1 to Len(oGetSDJ:aCols)
			If !(oGetSDJ:aCols[nx,nPosDel]) .and. nx <> oGetSDJ:Nat
				If !Empty(oGetSDJ:aCols[nx,nPosPe]) .And. oGetSDJ:aCols[nx,nPosPe]+oGetSDJ:aCols[nx,nPosOp] == oGetSDJ:aCols[oGetSDJ:Nat,nPosPe]+oGetSDJ:aCols[oGetSDJ:Nat,nPosOp]
				    Aviso(STR0015,STR0007,{"Ok"})    //"Chave do registro duplicado!"
				    lRet := .F.
				    Exit
				ElseIf oGetSDJ:aCols[nx,nPosOp]+oGetSDJ:aCols[nx,nPosIt] == oGetSDJ:aCols[oGetSDJ:Nat,nPosOp]+oGetSDJ:aCols[oGetSDJ:Nat,nPosIt]
				    Aviso(STR0015,STR0007,{"Ok"})    //"Chave do registro duplicado!"
				    lRet := .F.
				    Exit				
				EndIf
			EndIf
			If !(oGetSDJ:aCols[nx,nPosDel]) .And. !Empty(oGetSDJ:aCols[nx,nPosPe])
				If !SBU->(dbSeek(xFilial("SBU")+PadR(oGetSDJ:aCols[oGetSDJ:Nat,nPosPe],TamSX3("BU_BASE")[1]) + PadR(oGetSDJ:aCols[oGetSDJ:Nat,nPosOp],TamSX3("BU_GROPC")[1]) ) )
			
					Aviso(STR0015,STR0019,{"Ok"})    //"Cod de Familia no correcponde al grupo de opcional seleccionado."	
				    lRet := .F.
				    Exit
				EndIf
				If !SGA->(dbSeek(xFilial("SGA")+PadR(oGetSDJ:aCols[oGetSDJ:Nat,nPosOp],TamSX3("GA_GROPC")[1]) + PadR(oGetSDJ:aCols[oGetSDJ:Nat,nPosIt],TamSX3("GA_OPC")[1]) ) )
					Aviso(STR0015,STR0020,{"Ok"})    //"Opcional o item no existen"	
				    lRet := .F.
				    Exit
				EndIf
			EndIf
		Next nX
	EndIf
	CURSORARROW()                        
EndIf

M->DJ_FAMILIA := SPACE(TAMSX3("DJ_FAMILIA")[2])
M->DJ_GPOOPC := SPACE(TAMSX3("DJ_GPOOPC")[2])
M->DJ_ITEOPC := SPACE(TAMSX3("DJ_ITEOPC")[2])

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³M821TODOOK³ Autor ³ Gpe Santacruz         ³ Data ³05/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Valida la linea todo el getdados         				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ M821TODOOK()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MsNewGetDados                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M821TODOOK()
Local lRet		:= .T.
Local nPosDel	:= GdFieldPos("GDDELETED",oGetSDJ:aHeader)     
Local nPosPe	:= GdFieldPos("DJ_FAMILIA",oGetSDJ:aHeader)     
Local nPosOp	:= GdFieldPos("DJ_GPOOPC",oGetSDJ:aHeader)     
Local nPosIt	:= GdFieldPos("DJ_ITEOPC",oGetSDJ:aHeader)     
Local nx		:= 0  
Local nPos		:= 0

SBU->(dbsetorder(2))
SGA->(dbsetorder(1))

CURSORWAIT()

For nx := 1 to Len(oGetSDJ:aCols)          
	If !oGetSDJ:aCols[nx,nPosDel] 
		nPos := aScan(oGetSDJ:aCols,{|x| x[npospe]+x[nPosOp] == oGetSDJ:aCols[nx,npospe]+oGetSDJ:aCols[nx,nPosOp] .And. x[nPosDel] == .F.})
		If nPos > 0  				
			If !(oGetSDJ:aCols[oGetSDJ:Nat,nPosDel]) .And. nX <> oGetSDJ:Nat
				If !Empty(oGetSDJ:aCols[nx,nPosPe]) .And. oGetSDJ:aCols[nx,nPosPe]+oGetSDJ:aCols[nx,nPosOp] == oGetSDJ:aCols[oGetSDJ:Nat,nPosPe]+oGetSDJ:aCols[oGetSDJ:Nat,nPosOp]
				    Aviso(STR0015,STR0007,{"Ok"})    //"Chave do registro duplicado!"
				    lRet := .F.
				    Exit
				ElseIf oGetSDJ:aCols[nx,nPosOp]+oGetSDJ:aCols[nx,nPosIt] == oGetSDJ:aCols[oGetSDJ:Nat,nPosOp]+oGetSDJ:aCols[oGetSDJ:Nat,nPosIt]
				    Aviso(STR0015,STR0007,{"Ok"})    //"Chave do registro duplicado!"
				    lRet := .F.
				    Exit				
				EndIf
			EndIf
			If !(oGetSDJ:aCols[nx,nPosDel]) .And. !Empty(oGetSDJ:aCols[nx,nPosPe])
				If !SBU->(dbSeek(xFilial("SBU")+PadR(oGetSDJ:aCols[oGetSDJ:Nat,nPosPe],TamSX3("BU_BASE")[1]) + PadR(oGetSDJ:aCols[oGetSDJ:Nat,nPosOp],TamSX3("BU_GROPC")[1]) ) )
					
					Aviso(STR0015,STR0019,{"Ok"})    //"Cod de Familia no correcponde al grupo de opcional seleccionado."	
				    lRet := .F.
				    Exit
				EndIf
				If !SGA->(dbSeek(xFilial("SGA")+PadR(oGetSDJ:aCols[oGetSDJ:Nat,nPosOp],TamSX3("GA_GROPC")[1]) + PadR(oGetSDJ:aCols[oGetSDJ:Nat,nPosIt],TamSX3("GA_OPC")[1]) ) )
					Aviso(STR0015,STR0020,{"Ok"})    //"Opcional o item no existen"	
				    lRet := .F.
				    Exit
				EndIf
			EndIf
		EndIf
		If lRet .And. Empty(AllTrim(oGetSDJ:aCols[nx,nPospe])) .And. Empty(AllTrim(oGetSDJ:aCols[nx,nPosOp])) .Or. Empty(AllTrim(oGetSDJ:aCols[NX,nPosIt]))
		    Aviso(STR0015,STR0010,{"Ok"}) //"Todos los datos son requeridos"
		    lRet := .F.
		    Exit
		EndIf
		If lRet .And. (!Empty(oGetSDJ:aCols[nx,nPosPe]) .And. ;
		!SBU->(dbSeek(xFilial("SBU")+PadR(oGetSDJ:aCols[oGetSDJ:Nat,nPosPe],TamSX3("BU_BASE")[1]) + PadR(oGetSDJ:aCols[oGetSDJ:Nat,nPosOp],TamSX3("BU_GROPC")[1]) ) ))
			Aviso(STR0015,STR0019,{"Ok"})    //"Cod de Familia no correcponde al grupo de opcional seleccionado."	
		    lRet := .F.
		    Exit
		EndIf
		If lRet .And. !SGA->(dbSeek(xFilial("SGA")+PadR(oGetSDJ:aCols[oGetSDJ:Nat,nPosOp],TamSX3("GA_GROPC")[1]) + PadR(oGetSDJ:aCols[oGetSDJ:Nat,nPosIt],TamSX3("GA_OPC")[1]) ) )
			Aviso(STR0015,STR0020,{"Ok"})    //"Opcional o item no existen"	
		    lRet:= .f.
		    Exit
		EndIf
	EndIf
Next nX

CURSORARROW()

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³SB1SUB    ³ Autor ³ Gpe Santacruz         ³ Data ³21/10/2009³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Consulta especial SB1SUB de SB1 por B1_BASE2         	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ SB1SUB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Ninguno                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ mata821                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/                                      
Function SB1SUB()
Local lRet      := .F.
Local aOrdenes	:= {1,2}
Local aIndx		:= {}
Local aItems    := {}
Local aControl  := {}
Local oDlgRec	:= NIL
Local oIndx		:= NIL
Local oBoton	:= NIL
Local oBusca	:= NIL
Local oLbx1		:= NIL
Local cIndx		:= "1"
Local cQuery	:= ""
Local cTitLin	:= ""
Local cTitDesc	:= ""
Local cAliasQuery := GetNextAlias()
Local cBusca	:= Space(80)
Local cCampo	:= ReadVar()
Local cClave	:= Upper(Trim(&(cCampo)))
Local nOrd		:= 1
Local nPosLbx	:= 0
Local nPos      := 0
Local nRegSb1	:= 0

Private bLinea	:= {||Nil}

CursorWait()

//-- Campos por los que hara las busquedas
SX3->(dbSetOrder(2))
SX3->(dbSeek("B1_BASE2"))
cTitLin := X3Titulo()
aAdd(aindx,cTitLin)        
	
SX3->(dbSeek("B1_DESBSE2"))
cTitDesc := X3Titulo()
aAdd(aindx,cTitDesc)

//-- Filtra la información
        
cQuery := "SELECT distinct B1_BASE2,B1_DESBSE2 "
cQuery += "FROM " +RetSQLName("SB1") + " SB1 "
cQuery += "WHERE B1_FILIAL = '" +xFilial("SB1") +"' "
cQuery += "AND   B1_MSBLQL<>'1' AND   B1_BASE2 <>' ' "
cQuery += " AND  SB1.D_E_L_E_T_ <> '*' "
cQuery += "ORDER BY B1_BASE2"
cQuery := ChangeQuery(cQuery)
dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQuery,.T.,.T.) 

(cAliasQuery)->(dbGoTop())
            
//-- Genera arreglo con los registros filtrados
Do While (cAliasQuery)->(!EOF())
	If !Empty((cAliasQuery)->B1_BASE2)
		aAdd(aItems,{(cAliasQuery)->B1_BASE2,(cAliasQuery)->B1_DESBSE2})
		aAdd(aControl,{(cAliasQuery)->B1_BASE2,(cAliasQuery)->B1_DESBSE2})
	EndIf
	(cAliasQuery)->(DbSkip())
Enddo       
dbClearFilter()
(cAliasQuery)->(dbCloseArea())
	
CursorArrow()

If Len(aItems) == 0
	Aviso(STR0017,STR0016,{'Ok'})//"No hay informaci¢n para consultar."
	Return lRet
Endif

bLinea := {|| {	aItems[oLbx1:nAt,1],aItems[oLbx1:nAt,2]}}

//-- Posicion en el arreglo donde esta la actual clave de producto
If !Empty(cClave)
	nPos := aScan(aItems,{|x| x[1] = cClave}) //posiciona en el producto contenid en el campo ReadVar
EndIf

//-- Despliega consulta
DEFINE MSDIALOG oDlgRec FROM 50,003 TO 295,730 TITLE OEMTOANSI(STR0003) PIXEL //"Productos Activos"

@ 02,05 MSCOMBOBOX oIndx VAR cIndx ITEMS aIndx SIZE 80,10 PIXEL OF oDlgRec
oIndx:bChange := {|| (nOrd:=oIndx:nAt, Reordena(@oLbx1, aItems, nOrd)) }

@ 02,118 BUTTON oBoton PROMPT OEMTOANSI(STR0004) SIZE 35,10 ; //"Buscar"
		ACTION (oLbx1:nAT := BuscaCve(oLbx1, aItems, nOrd, aOrdenes, cBusca), ;
				oLbx1:bLine := bLinea, ;
				oLbx1:SetFocus());
		PIXEL OF oDlgRec
@ 14,05 MSGET oBusca VAR cBusca PICTURE "@!" SIZE 150,10 PIXEL OF oDlgRec
  

@ 28,05 LISTBOX oLbx1 VAR nPosLbx FIELDS HEADER OemToAnsi(ctitlin),OemToAnsi(ctitdesc),;
		SIZE 355,80 OF oDlgRec PIXEL NOSCROLL 

oLbx1:SetArray(aItems)
If nPos > 0
	oLbx1:nAt := nPos
Endif

oLbx1:bLine:= bLinea
oLbx1:BlDblClick := {||(lRet:= .T.,nPos:= oLbx1:nAt, oDlgRec:End())}
oLbx1:Refresh()

DEFINE SBUTTON FROM 110,300 TYPE 1 ENABLE OF oDlgRec ACTION (lRet:=.T.,nPos:=oLbx1:nAt,oDlgRec:End())
DEFINE SBUTTON FROM 110,335 TYPE 2 ENABLE OF oDlgRec ACTION (lRet:= .F.,oDlgRec:End())

ACTIVATE MSDIALOG oDlgRec CENTERED

//-- Posiciona a Sb1 en el numero de registro seleccionado
If lRet                         
    SB1->(dbSetOrder(9))
   	SB1->(dbSeek(xFilial("SB1")+aControl[nPos,1]))
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³BuscaCve  ³ Autor ³ Alberto Rodriguez     ³ Data ³ 03/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Busca en arreglo de consulta especifica					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA821													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BuscaCve(oLbx1, aItems, nOrd, aOrdenes, cBusca)
Local nPos := 0
Local nCol := aOrdenes[nOrd]

cBusca := Upper(Trim(cBusca))
nPos := ASCAN(aItems, {|aVal| aVal[nCol]=cBusca} ) // valor corto de lado derecho del '=' puede coincidir; es como softseek

If nPos == 0
	nPos := oLbx1:nAt
EndIf

Return nPos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Reordena  ³ Autor ³ Alberto Rodriguez     ³ Data ³ 07/10/08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Clasifica arreglo de consulta especifica					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA821													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Reordena(oLbx1,aItems,nOrd)

CursorWait()

If nOrd == 1
	aItems := aSort(aItems,,,{|x,y| x[1]+x[2] <= y[1]+y[2] }) 
ElseIf nOrd == 2
	aItems := aSort(aItems,,,{|x,y| x[2]+x[1] <= y[2]+y[1] }) 
Endif

oLbx1:SetArray(aItems)
oLbx1:nAt := 1
oLbx1:bLine := bLinea
oLbx1:Refresh()

CursorArrow()

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MenuDef  ºAutor  ³ Andre Anjos		 º Data ³  20/03/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Funcao de criacao das opcoes de menu                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MATA821                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Private aRotina	:= {	{ STR0005, "AxPesqui" , 0 , 01},; //"Pesquisar"
						{ STR0021, "M821Mtto" , 0 , 04},; //"Atualizar"
						{ STR0006, "M821Mtto" , 0 , 05},; //"Excluir"	
						{ STR0022, "M821Mtto" , 0 , 02}}  //"Visualizar"						
Return aRotina