// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 04     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#include "Protheus.ch"
#Include "VEIVC250.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ VEIVC250 ³ Autor ³  Thiago               ³ Data ³ 19/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Consulta tempo de execucao da tarefa.		              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEIVC250()
//variaveis controle de janela
Local aSizeAut   := MsAdvSize(.t.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)    
Private dDtSIni  := ctod("  /  /  ")
Private dDtSFin  := ctod("  /  /  ")
Private dDtEIni  := ctod("  /  /  ")
Private dDtEFin  := ctod("  /  /  ") 
Private oGrafico
Private nQtdTar  := 99               
Private aTarefas := {{"","",0,0,"",0}}
Private cCadastro := (STR0001)

// Configura os tamanhos dos objetos
        
FS_FILTRAR("0")

DEFINE MSDIALOG oDlgCons TITLE STR0002 From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL //Consulta Tempo de execução da tarefa

	oPanFiltr := TPanel():New(0,0,"",oDlgCons,NIL,.T.,.F.,NIL,NIL,0,040,.T.,.F.)
	oPanFiltr:Align := CONTROL_ALIGN_TOP

	oPanGrafi := TPanel():New(0,0,"",oDlgCons,NIL,.T.,.F.,NIL,NIL,0,110,.T.,.F.)
	oPanGrafi:Align := CONTROL_ALIGN_BOTTOM
		

@ 010,010 SAY STR0004 SIZE 100,08 OF oPanFiltr PIXEL COLOR CLR_BLUE  
@ 010,070 MSGET oDtSIni VAR dDtSIni PICTURE "@D" SIZE 60,08 OF oPanFiltr PIXEL COLOR CLR_BLUE

@ 010,137 SAY STR0005 SIZE 80,08 OF oPanFiltr PIXEL COLOR CLR_BLUE  
@ 010,155 MSGET oDtSFin VAR dDtSFin PICTURE "@D" SIZE 60,08 OF oPanFiltr PIXEL COLOR CLR_BLUE

@ 023,010 SAY STR0006 SIZE 100,08 OF oPanFiltr PIXEL COLOR CLR_BLUE  
@ 023,070 MSGET oDtEIni VAR dDtEIni PICTURE "@D" SIZE 60,08 OF oPanFiltr PIXEL COLOR CLR_BLUE

@ 023,137 SAY STR0005 SIZE 80,08 OF oPanFiltr PIXEL COLOR CLR_BLUE  
@ 023,155 MSGET oDtEFin VAR dDtEFin PICTURE "@D" SIZE 60,08 OF oPanFiltr PIXEL COLOR CLR_BLUE

@ 010,240 SAY STR0007 SIZE 110,08 OF oPanFiltr PIXEL COLOR CLR_BLUE  
@ 010,360 MSGET oQtdTar VAR nQtdTar PICTURE "99" SIZE 50,08 OF oPanFiltr PIXEL COLOR CLR_BLUE

@ 010,435 BUTTON oFiltrar  PROMPT  OemToAnsi(STR0008) OF oPanFiltr SIZE 45,10 PIXEL  ACTION (FS_FILTRAR("1")) 
@ 021,435 BUTTON oSair     PROMPT  OemToAnsi(STR0023)  OF oPanFiltr SIZE 45,10 PIXEL  ACTION (oDlgCons:End()) 

@ 030,001 LISTBOX oTarLx FIELDS HEADER STR0009,STR0010,STR0011,STR0012,STR0013 COLSIZES 50,200,60,85 SIZE 10,150 OF oDlgCons PIXEL ON DBLCLICK FS_ATEND(oTarLx:nAt)
oTarLx:SetArray(aTarefas)
oTarLx:aLign := CONTROL_ALIGN_ALLCLIENT
oTarLx:bLine := { || {	aTarefas[oTarLx:nAt,1],;
	aTarefas[oTarLx:nAt,2],;
	transform(aTarefas[oTarLx:nAt,3],"@E 999999"),;
	aTarefas[oTarLx:nAt,5],;
	FG_AlinVlrs(Transform(aTarefas[oTarLx:nAt,6],"@E 999.99")+"%")}}

@ 001,001 SCROLLBOX oGrafico SIZE 150,210 OF oPanGrafi BORDER PIXEL
oGrafico:aLign := CONTROL_ALIGN_ALLCLIENT

FS_GRAFICO()

ACTIVATE MSDIALOG oDlgCons 

                        

Return(.t.)                                                                                                                                     

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_FILTRAR ³ Autor ³ Thiago              ³ Data ³ 19/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Filtrar.										              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILTRAR(cFiltro)  
Local i := 0 
Local cAliasVAY := "SQLVAY"  
aTarefas := {{"","",0,0,"",0}}

cQuery := "SELECT VAY.VAY_CODTAR,VAX.VAX_DESTAR,VAY.VAY_DATSOL,VAY.VAY_HORSOL,VAY.VAY_DATEXE,VAY.VAY_HOREXE "
cQuery += "FROM "
cQuery += RetSqlName( "VAY" ) + " VAY " 
cQuery += "LEFT JOIN "+RetSqlName("VAX")+" VAX ON (VAX.VAX_FILIAL='"+xFilial("VAX")+"' AND VAX.VAX_CODTAR = VAY.VAY_CODTAR AND VAX.D_E_L_E_T_=' ') "
cQuery += "WHERE " 
cQuery += "VAY.VAY_FILIAL='"+ xFilial("VAY")+ "' AND "
if !Empty(dDtSIni)
	cQuery += "VAY.VAY_DATSOL >= '"+dtos(dDtSIni)+"' AND VAY.VAY_DATSOL <= '"+dtos(dDtSFin)+"' AND "
Endif	
if !Empty(dDtEIni)
	cQuery += "VAY.VAY_DATEXE >= '"+dtos(dDtEIni)+"' AND VAY.VAY_DATEXE <= '"+dtos(dDtEFin)+"' AND "
Endif	
cQuery += "VAY.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVAY, .T., .T. )
nQtd   := 0                
nSoma  := 0 
nTotal := 0
Do While !( cAliasVAY )->( Eof() )
	
	dData  := stod(( cAliasVAY )->VAY_DATSOL)
	nHora  := ( cAliasVAY )->VAY_HORSOL
	dDtPx  := stod(( cAliasVAY )->VAY_DATEXE)
	nHrPx  := ( cAliasVAY )->VAY_HOREXE

	if Empty(dDtPx)
		dDtPx   := dDataBase
		nHrPx   := val(substr(Time(),1,2)+substr(Time(),4,2))
	Endif	
	nDias :=  dDtPx-dData
	if nDias == 0
		nTempo := ( int(nHrPx/100) + (nHrPx % 100)/60 ) - ( int(nHora/100) + (nHora % 100)/60 )
		nTempo := round( int(nTempo) * 100 + (nTempo % 1) * 60 , 0 )
	Else
		nTempo := ( int(nHrPx/100) + (nHrPx % 100)/60 ) - ( int(nHora/100) + (nHora % 100)/60 )
		if nTempo < 0
			nDias  -= 1
			nTempo += 24
		Endif                                                                        
		nTempo := round( int(nTempo) * 100 + (nTempo % 1) * 60 , 0 )
	Endif
    nHorT := (((nDias * 24) * 60)*100) + nTempo 
	nTar := aScan(aTarefas,{|x| x[1] == ( cAliasVAY )->VAY_CODTAR}) 
	if nTar == 0  
		if Len(aTarefas) == 1 .and. Empty(aTarefas[1,1])
			aTarefas := {}
		Endif	                                                            
		cQtdD := Alltrim(str(int(((nHorT/100)/60)/24)))+STR0014+transform(strzero(nHorT%100,4),"@R 99:99")
		Aadd(aTarefas,{( cAliasVAY )->VAY_CODTAR,( cAliasVAY )->VAX_DESTAR,1,nHorT,cQtdD,0})
	Else
    	aTarefas[nTar,3] += 1
    	aTarefas[nTar,4] += nHorT       
	Endif   
	dbSelectArea(cAliasVAY)
	( cAliasVAY )->(dbSkip())

Enddo
( cAliasVAY )->( dbCloseArea() )

For i := 1 to Len(aTarefas)
   	nH := (aTarefas[i,4]/aTarefas[i,3])%100
   	if nH > 60                        
   	   nTH := nH - 60   
   	   nTD := int((((aTarefas[i,4]/aTarefas[i,3])/100)/60)/24)+1
   	Else
   	   nTH := nH 
   	   nTD := int((((aTarefas[i,4]/aTarefas[i,3])/100)/60)/24)
   	Endif    
    nTotal += nTD
Next

For i := 1 to Len(aTarefas)
   	nH := (aTarefas[i,4]/aTarefas[i,3])%100
   	if nH > 60                        
   	   nTH := nH - 60   
   	   nTD := int((((aTarefas[i,4]/aTarefas[i,3])/100)/60)/24)+1
   	Else
   	   nTH := nH 
   	   nTD := int((((aTarefas[i,4]/aTarefas[i,3])/100)/60)/24)
   	Endif    
    	   
	cQtdD := Alltrim(str(nTD))+STR0014+transform(strzero(nTH,4),"@R 99:99")
	aTarefas[i,5] := cQtdD
    aTarefas[i,6] := (nTD/nTotal)*100
Next
aSort(aTarefas,,,{|x,y| x[6] > y[6] })
                           
if cFiltro == "1"
	oTarLx:SetArray(aTarefas)
	oTarLx:bLine := { || {	aTarefas[oTarLx:nAt,1],;
	aTarefas[oTarLx:nAt,2],;
	transform(aTarefas[oTarLx:nAt,3],"@E 999999"),;
	aTarefas[oTarLx:nAt,5],;
	FG_AlinVlrs(Transform(aTarefas[oTarLx:nAt,6],"@E 999.99")+"%")}}
	oTarLx:Refresh()
	FS_GRAFICO()
Endif
                       
Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_GRAFICO ³ Autor ³ Thiago              ³ Data ³ 19/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grafico.										              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_GRAFICO()
Local ni := 0     
Local aDadosGraf := {}
Local cTitGrafic := "Tarefas"+" ( % )"

For ni := 1 to len(aTarefas)
	If ni < ( nQtdTar+1 )
		Aadd( aDadosGraf , { aTarefas[ni,06] , aTarefas[ni,02] } )
	ElseIf ni == ( nQtdTar+1 )
		Aadd( aDadosGraf , { aTarefas[ni,06] , "Demais"  } ) // Demais
	Else
		aDadosGraf[len(aDadosGraf),1] += aTarefas[ni,06]
	EndIf
Next
If len(aDadosGraf) <= 0
	aAdd( aDadosGraf , { 0 , ""  } )
EndIf
For ni := 1 to len(aDadosGraf)
	aDadosGraf[ni,02] := left(aDadosGraf[ni,02],20)
	aDadosGraf[ni,01] := round(  aDadosGraf[ni,01],2  )
Next

FG_NEWGRAF(oGrafico,cTitGrafic,aDadosGraf,.f.,"@E 999.9 %")

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_ATEND ³ Autor ³ Thiago                ³ Data ³ 19/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Atendimento. 								              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_ATEND()   
Local aAtend := {{"","",ctod(""),0,ctod(""),0,""}}
Local cAliasVAY := "SQLVAY"  

cQuery := "SELECT VAY.VAY_NUMIDE,VAY.VAY_DATSOL,VAY.VAY_HORSOL,VAY.VAY_DATEXE,VAY.VAY_HOREXE,VAY.VAY_CODTAR "
cQuery += "FROM "
cQuery += RetSqlName( "VAY" ) + " VAY " 
cQuery += "WHERE " 
cQuery += "VAY.VAY_FILIAL='"+ xFilial("VAY")+ "' AND VAY.VAY_CODTAR = '"+aTarefas[oTarLx:nAt,1]+"' AND "
cQuery += "VAY.D_E_L_E_T_=' '"                                             

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasVAY, .T., .T. )

cQtdD := ""
Do While !( cAliasVAY )->( Eof() )  
	           
	if Len(aAtend) == 1 .and. Empty(aAtend[1,2])
   		aAtend := {}
	Endif	

	dData  := stod(( cAliasVAY )->VAY_DATSOL)
	nHora  := ( cAliasVAY )->VAY_HORSOL
	dDtPx  := stod(( cAliasVAY )->VAY_DATEXE)
	nHrPx  := ( cAliasVAY )->VAY_HOREXE

	if Empty(dDtPx)
		dDtPx   := dDataBase
		nHrPx   := val(substr(Time(),1,2)+substr(Time(),4,2))
	Endif	
	nDias :=  dDtPx-dData
	if nDias == 0
		nTempo := ( int(nHrPx/100) + (nHrPx % 100)/60 ) - ( int(nHora/100) + (nHora % 100)/60 )
		nTempo := round( int(nTempo) * 100 + (nTempo % 1) * 60 , 0 )
	Else
		nTempo := ( int(nHrPx/100) + (nHrPx % 100)/60 ) - ( int(nHora/100) + (nHora % 100)/60 )
		if nTempo < 0
			nDias  -= 1
			nTempo += 24
		Endif                                                                        
		nTempo := round( int(nTempo) * 100 + (nTempo % 1) * 60 , 0 )
	Endif
    nHorT := (((nDias * 24) * 60)*100) + nTempo 
	cQtdD := Alltrim(str(int(((nHorT/100)/60)/24)))+STR0014+transform(strzero(nHorT%100,4),"@R 99:99") 
	dbSelectArea("VAY")
	dbSetOrder(2)
	dbSeek(xFilial("VAY")+( cAliasVAY )->VAY_CODTAR+( cAliasVAY )->VAY_NUMIDE)
	aSM0 := FWArrFilAtu(cEmpAnt,VAY->VAY_FILIAL) 
	Aadd(aAtend,{VAY->VAY_FILIAL+" - "+aSm0[6],( cAliasVAY )->VAY_NUMIDE,stod(( cAliasVAY )->VAY_DATSOL),( cAliasVAY )->VAY_HORSOL,stod(( cAliasVAY )->VAY_DATEXE),( cAliasVAY )->VAY_HOREXE,cQtdD})
	
	dbSelectArea(cAliasVAY)
	( cAliasVAY )->(dbSkip())

Enddo	
( cAliasVAY )->( dbCloseArea() )

DEFINE MSDIALOG oDlgAtend TITLE STR0015 From 9,0 to 43,110	of oMainWnd

 @ 032,002 LISTBOX oAtenLx FIELDS HEADER  STR0016,STR0017,STR0018,STR0019,STR0020,STR0021,STR0022 COLSIZES 40,40,40,40,40,40,40 SIZE 433,219 OF oDlgAtend PIXEL PIXEL ON DBLCLICK FS_TELAATEND(aAtend[oAtenLx:nAt,2])
oAtenLx:SetArray(aAtend)
oAtenLx:bLine := { || {	aAtend[oAtenLx:nAt,1],;
aAtend[oAtenLx:nAt,2],;
Transform(aAtend[oAtenLx:nAt,3],"@D"),;
Transform(aAtend[oAtenLx:nAt,4],"@E 999:99"),;
Transform(aAtend[oAtenLx:nAt,5],"@D"),;
Transform(aAtend[oAtenLx:nAt,6],"@E 999:99"),;
aAtend[oAtenLx:nAt,7]}}

ACTIVATE MSDIALOG oDlgAtend ON INIT EnchoiceBar(oDlgAtend,{|| if(FS_TELAATEND(aAtend[oAtenLx:nAt,2]), oDlgAtend:End() , .f. ) },{|| oDlgAtend:End() })CENTER

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ FS_TELAATEND ³ Autor ³ Thiago            ³ Data ³ 19/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Chama tela do atendimento.					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_TELAATEND(cNumero)
if !Empty(cNumero)
	DbSelectArea("VV9")
	DbSetOrder(1)
	If DbSeek( xFilial("VV9") + cNumero )
		If !FM_PILHA("VEIXX002") .and. !FM_PILHA("VEIXX030")
			VEIXX002(NIL,NIL,NIL,2,)
		EndIf
	EndIf
Endif
Return(.t.)