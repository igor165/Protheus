// …ÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕÕª
// ∫ Versao ∫ 10     ∫
// »ÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕÕº
#Include "Protheus.ch"
#Include "OFIOC350.CH"

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ OFIOC350 ≥ Autor ≥ Rafael G. da Silva    ≥ Data ≥01/04/2009|±±
±±≥          ≥          ≥ Autor ≥ Andre Luis Almeida    ≥      ≥          ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Consulta Itens Reservados em Orcamentos Aceitos            ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Function OFIOC350()
//variaveis controle de janela
Local aObjects := {} , aPosObj := {} , aPosObjApon := {} , aInfo := {}
Local aSizeAut := MsAdvSize(.f.)  // Tamanho Maximo da Janela (.t.=TOOLBAR,.f.=SEM TOOLBAR)
Local nCntFor := 0
////////////////////////////////////////////////////////////////////////////////////////////
Local nCkPerg1    := 1
Local aComboOrc   :={"1- "+STR0002 , "2- "+STR0003 , "3- "+STR0004 }  //Orcamento Selecionado e Itens ## Somente Orcamentos apenas ## Todos Orcamentos e Itens
Local aComboIte   :={"1- "+STR0005 , "2- "+STR0006 , "3- "+STR0007 }   //Item Selecionado e Orcamentos ### Somente Itens ### Todos Itens e Orcamentos
Local aParambox   := {}
Local nCont       := 0
Local cFilVet     := ""
Private dPerIni   := ctod("  /  /  ")
Private dPerFin   := dDataBase
Private aRet      := {} 
Private aComboFil := {STR0028, xFilial("VS1")}
Private nTotGeral := 0
Private cFilFilial := xFilial("VS1")
Private aOrc      := {}
Private aIte      := {}
Private aOrcAux   := {}
Private cComboIte := ""
Private cComboOrc := ""  
Private aFilAtu   := FWArrFilAtu() // carrega os dados da Filial logada ( Grupo de Empresa / Empresa / Filial ) 
Private aSM0      := FWAllFilial( aFilAtu[3] , aFilAtu[4] , aFilAtu[1] , .f. ) // Levanta todas as Filiais da Empresa logada (vetor utilizado no FOR das Filiais)

For nCont := 1 to Len(aSM0)
	if cFilVet != aSM0[nCont]
		cFilVet := aSM0[nCont]
		if aScan(aComboFil, aSM0[nCont]) == 0
			aAdd(aComboFil, aSM0[nCont])
		endif
	endif
Next
aSort(aComboFil)

If !FS_VERBASE() // Verifica a existencia dos arquivos envolvidos na Consulta
	MsgStop(STR0009 ,STR0008) //Nao existem dados para esta Consulta! # Atencao
	Return
EndIf             

AADD(aParambox,{1,STR0030,dPerIni,"","","",".T.",50,.F.})
AADD(aParambox,{1,STR0031,dPerFin,"","(NaoVazio() .and. MV_PAR02>=MV_PAR01)","",".T.",50,.F.}) 

aAdd(aParamBox,{2,STR0029,"",aComboFil,80,"",.f.}) 

If !ParamBox(aParamBox,STR0034,@aRet,,,,,,,,.f.)
	Return .f.
EndIf
dPerIni		:= aRet[1] 
dPerFin		:= aRet[2] 
cFilFilial  := aRet[3] 

Processa({ || FS_LEVANTA(0) }) //CHAMADA INICIAL POR ORCAMENTO


// Configura os tamanhos dos objetos
aObjects := {}
AAdd( aObjects, { 05, 27 , .T., .F. } )  //Cabecalho
AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box superior
AAdd( aObjects, { 1, 10, .T. , .T. } )  //list box inferior
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

DEFINE MSDIALOG oResOrc TITLE OemToAnsi(STR0001) From aSizeAut[7],000 to aSizeAut[6],aSizeAut[5] of oMainWnd PIXEL //Itens Reservados em OrCamentos Aceitos

nCkPerg1 := 1
@ 005,005 RADIO oRadio1 VAR nCkPerg1 3D SIZE 70,10 PROMPT;
OemToAnsi(STR0010), OemToAnsi(STR0011);//Orcamento # Itens
OF oResOrc PIXEL ON CHANGE ( Processa({ || FS_LEVANTA(nCkPerg1) }) , IIf(nCkPerg1<>2,olBox11:SetFocus(),olBox22:SetFocus()) )
//combo box    
@ 002,047 TO 024,145 LABEL STR0032 OF oResOrc PIXEL   //Periodo
@ 010,052 MSGET oPerIni VAR dPerIni PICTURE "@D" SIZE 40,08 OF oResOrc PIXEL COLOR CLR_BLUE 
@ 010,092 SAY STR0033  SIZE 20,08 					OF oResOrc PIXEL
@ 010,102 MSGET oPerFin VAR dPerFin PICTURE "@D" VALID (NaoVazio() .and. dPerFin >= dPerIni) .and. ( Processa({ || FS_LEVANTA(nCkPerg1) }) , IIf(nCkPerg1<>2,olBox11:SetFocus(),olBox22:SetFocus()) ) SIZE 40,08 OF oResOrc PIXEL COLOR CLR_BLUE 

@ 002,150 TO 024,303 LABEL OemToAnsi(STR0012) OF oResOrc PIXEL   //Tipos de Relatorio
@ 010,155 MSCOMBOBOX oComboOrc VAR cComboOrc ITEMS aComboOrc SIZE 110,07 OF oResOrc PIXEL COLOR CLR_BLUE
@ 010,155 MSCOMBOBOX oComboIte VAR cComboIte ITEMS aComboIte SIZE 110,07 OF oResOrc PIXEL COLOR CLR_BLUE
@ 010,267 BUTTON oImp PROMPT OemToAnsi(STR0013)	OF oResOrc SIZE 30,10 PIXEL ACTION FS_IMPRIMIR(nCkPerg1) //IMPRIMIR
//total geral
@ 002,305 TO 024,369 LABEL (STR0014) OF oResOrc PIXEL COLOR CLR_BLUE   //Total Geral
@ 010,310 MSGET oTotGeral VAR nTotGeral PICTURE "@E 999,999,999.99" SIZE 57,08 OF oResOrc PIXEL COLOR CLR_BLUE WHEN .f.
@ 002,374 TO 024,416 LABEL (STR0029) OF oResOrc PIXEL COLOR CLR_BLUE   //Total Geral
@ 010,377 MSCOMBOBOX oComboFil VAR cFilFilial  ITEMS aComboFil;
 VALID ( Processa({ || FS_LEVANTA(nCkPerg1) }) , IIf(nCkPerg1<>2,olBox11:SetFocus(),olBox22:SetFocus()) ) SIZE 37,08 OF oResOrc PIXEL COLOR CLR_BLUE


/////////////////////////R  A  D  I  O  -  O  R  C  A  M  E  N  T  O   ////////////////////////
@ aPosObj[2,1],aPosObj[2,2] LISTBOX olBox11 FIELDS HEADER OemToAnsi(STR0029),;	
OemToAnsi(STR0010),;	//Orcamento
OemToAnsi(STR0016),;	//Data"
OemToAnsi(STR0017),;	//Vendedor
OemToAnsi(STR0015),;	//Valor Total
OemToAnsi(STR0019);	//Cliente
COLSIZES 20, 35,35,100,60,130 SIZE aPosObj[2,4]-2,aPosObj[2,3]-aPosObj[1,3]-2 OF oResOrc PIXEL ON CHANGE IIF(nCkPerg1==1,(FS_LEVFILHO(nCkPerg1,aOrc[olBox11:nAt,1],aOrc[olBox11:nAt,2]),olBox11:SetFocus()),.t.)
olBox11:SetArray(aOrc)
olBox11:bLine := { || {  aOrc[olBox11:nAt,1] ,;
aOrc[olBox11:nAt,2] ,;
Transform(aOrc[olBox11:nAt,3],"@D") ,;
aOrc[olBox11:nAt,4] ,;
FG_AlinVlrs(Transform(aOrc[olBox11:nAt,5],"@E 99,999,999.99")) ,;
aOrc[olBox11:nAt,6] }}

@ aPosObj[3,1],aPosObj[3,2] LISTBOX olBox12 FIELDS HEADER OemToAnsi(STR0020),;//Grupo
OemToAnsi(STR0021),;//Codigo
OemToAnsi(STR0022),;//Descricao
OemToAnsi(STR0018),;//Quantidade
OemToAnsi(STR0015);//Valor Total
COLSIZES 25,100,150,50,60 SIZE aPosObj[3,4]-2,aPosObj[3,3]-aPosObj[2,3]-2 OF oResOrc PIXEL
olBox12:SetArray(aIte)
olBox12:bLine := { || {  aIte[olBox12:nAt,1] ,;
aIte[olBox12:nAt,2] ,;
aIte[olBox12:nAt,3] ,;
FG_AlinVlrs(Transform(aIte[olBox12:nAt,4],"@E 99999.99")) ,;
FG_AlinVlrs(Transform(aIte[olBox12:nAt,5],"@E 99,999,999.99")) }}


/////////////////////////R  A D  I  O  -  I  T  E  N  S  ////////////////////////

@ aPosObj[2,1],aPosObj[2,2] LISTBOX olBox21 FIELDS HEADER OemToAnsi(STR0020),;//Grupo
OemToAnsi(STR0021),;//Codigo
OemToAnsi(STR0022),;//Descricao
OemToAnsi(STR0018),;//Quantidade
OemToAnsi(STR0015);//Valor Total
COLSIZES 25,100,150,50,60 SIZE aPosObj[2,4]-2,aPosObj[2,3]-aPosObj[1,3]-2 OF oResOrc PIXEL ON CHANGE IIF(nCkPerg1==2,(FS_LEVFILHO(nCkPerg1,"",aIte[olBox21:nAt,1],aIte[olBox21:nAt,2]),olBox21:SetFocus()),.t.)
olBox21:SetArray(aIte)
olBox21:bLine := { || {  aIte[olBox21:nAt,1] ,;
aIte[olBox21:nAt,2] ,;
aIte[olBox21:nAt,3] ,;
FG_AlinVlrs(Transform(aIte[olBox21:nAt,4],"@E 99999.99")) ,;
FG_AlinVlrs(Transform(aIte[olBox21:nAt,5],"@E 99,999,999.99")) }}


@ aPosObj[3,1],aPosObj[3,2] LISTBOX olBox22 FIELDS HEADER OemToAnsi(STR0029),;//Orcamento
OemToAnsi(STR0010),;//Orcamento
OemToAnsi(STR0016),;//Data
OemToAnsi(STR0017),;//Vendedor
OemToAnsi(STR0018),;//Quantidade
OemToAnsi(STR0015),;//Valor Total
OemToAnsi(STR0019);//Cliente
COLSIZES 25,35,35,70,50,50,90 SIZE aPosObj[3,4]-2,aPosObj[3,3]-aPosObj[2,3]-2 OF oResOrc PIXEL
olBox22:SetArray(aOrc)
olBox22:bLine := { || {  aOrc[olBox22:nAt,1] ,;
aOrc[olBox22:nAt,2] ,;
Transform(aOrc[olBox22:nAt,3],"@D") ,;
aOrc[olBox22:nAt,4] ,;
FG_AlinVlrs(Transform(aOrc[olBox22:nAt,7],"@E 99999.99")) ,;
FG_AlinVlrs(Transform(aOrc[olBox22:nAt,5],"@E 99,999,999.99")) ,;
aOrc[olBox22:nAt,6]}}


olBox11:lVisible:=.t.
olBox12:lVisible:=.t.
olBox22:lVisible:=.f.
olBox21:lVisible:=.f.
oComboOrc:lVisible:=.t.
oComboIte:lVisible:=.f.

@ aPosObj[1,1]+010,aPosObj[1,4]-50 BUTTON oSair PROMPT OemToAnsi(STR0023) 	OF oResOrc SIZE 35,10 PIXEL ACTION oResOrc:End()    //SAIR


ACTIVATE MSDIALOG oResOrc

RETURN


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_LEVANTA  ≥ Autor ≥  Andre/Rafael         ≥ Data ≥ 31/03/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Carrega os dados do ListBox                                   ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_LEVANTA(nCkPerg1)
Local cQAlVS1 := "SQLVS1"
Local cQAlVS3 := "SQLVS3"
Local cQuebra := "INICIAL" 			//controla a acumalacao do valor e quantidade no vetor de itens
nTotGeral := 0                               

If nCkPerg1 == 1 .or. nCkPerg1 == 0	//////////////////// O R C A M E N T O ////////////////////
	aOrc := {}
	cQuery := "SELECT VS1.VS1_FILIAL, VS1.VS1_NUMORC, VS1.VS1_DATORC, "
	cQuery += " VS1.VS1_CODVEN, VS1.VS1_CLIFAT, VS1.VS1_LOJA, VS1.VS1_NCLIFT, SA3.A3_NOME"
	cQuery += " FROM "+RetSqlName("VS1")+" VS1, "+RetSqlName("SA3")+" SA3 "
	cQuery += " WHERE "  
	if cFilFilial <> STR0028 
 		cQuery += " VS1.VS1_FILIAL = '"+cFilFilial+"' AND "
 	Endif	
	cQuery += " VS1.VS1_DATORC >= '"+dtos(dPerIni)+"' AND VS1.VS1_DATORC <= '"+dtos(dPerFin)+"' AND "  
	cQuery += " VS1.VS1_NUMOSV='"+space(len(VS1->VS1_NUMOSV))+"' AND"
	cQuery += " VS1.VS1_NUMNFI = '"+space(len(VS1->VS1_NUMNFI))+"' AND"
	cQuery += " VS1.VS1_STATUS NOT IN ('X','C') AND"
	cQuery += " VS1.VS1_CODVEN = SA3.A3_COD AND"
	cQuery += " (VS1.VS1_FILIAL = SA3.A3_FILIAL OR SA3.A3_FILIAL='"+xFilial("SA3")+"') AND "
    cQuery += " VS1.D_E_L_E_T_=' ' AND SA3.D_E_L_E_T_=' ' ORDER BY VS1.VS1_FILIAL, VS1.VS1_NUMORC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS1, .F., .T. )
	ProcRegua(( cQAlVS1 )->(Reccount()))
	While !( cQAlVS1 )->( Eof() )
		//
		Incproc(STR0010+": "+( cQAlVS1 )->( VS1_NUMORC ))
		cQuery := "SELECT COUNT(VS3.VS3_VALTOT) AS QTD , SUM(VS3.VS3_VALTOT) AS VLR"
		cQuery += " FROM "+RetSqlName("VS3")+" VS3"
		cQuery += " JOIN "+RetSqlName("VE6")+" VE6 ON (VE6.VE6_FILIAL='"+( cQAlVS1 )->( VS1_FILIAL )+"' AND VE6.VE6_INDREG='3' AND VE6.VE6_NUMORC = '"+( cQAlVS1 )->( VS1_NUMORC )+"' AND VE6.VE6_GRUITE=VS3.VS3_GRUITE AND VE6.VE6_CODITE=VS3.VS3_CODITE AND VE6.D_E_L_E_T_=' ') "
		cQuery += " WHERE VS3.VS3_FILIAL='"+( cQAlVS1 )->( VS1_FILIAL )+"' AND"
		cQuery += " VS3.VS3_NUMORC='"+( cQAlVS1 )->( VS1_NUMORC )+"' AND"
		cQuery += " VS3.D_E_L_E_T_=' '"
		dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS3, .F., .T. )
		If ( cQAlVS3 )->( QTD ) >0
	   		aAdd(aOrc,{( cQAlVS1 )->( VS1_FILIAL ) , ( cQAlVS1 )->( VS1_NUMORC ) , stod(( cQAlVS1 )->( VS1_DATORC )) , ( cQAlVS1 )->( VS1_CODVEN )+" - "+ ( cQAlVS1 )->( A3_NOME ), ( cQAlVS3 )->( VLR ) , ( cQAlVS1 )->( VS1_CLIFAT  ) +"-"+ ( cQAlVS1 )->( VS1_LOJA ) +" "+( cQAlVS1 )->( VS1_NCLIFT ),0})
				nTotGeral += ( cQAlVS3 )->( VLR )
		Endif
		( cQAlVS3 )->( dbCloseArea() )
		( cQAlVS1 )->( DbSkip() )
	EndDo
	aSort(aComboFil)
	( cQAlVS1 )->( dbCloseArea() )
	If Len(aOrc) <= 0
		Aadd(aOrc,{ "" , "" , ctod("  /  /  ") , "" , 0 , "" , 0 })
	EndIf
	If nCkPerg1 == 1
		olBox11:nAt := 1
		olBox11:SetArray(aOrc)
		olBox11:bLine := { || {  aOrc[olBox11:nAt,1] ,;
		aOrc[olBox11:nAt,2] ,;
		Transform(aOrc[olBox11:nAt,3],"@D") ,;
		aOrc[olBox11:nAt,4] ,;
		FG_AlinVlrs(Transform(aOrc[olBox11:nAt,5],"@E 99,999,999.99")) ,;
		aOrc[olBox11:nAt,6] }}
		olBox11:SetFocus()
		olBox11:Refresh()
	EndIf
	FS_LEVFILHO(nCkPerg1,aOrc[1,1],aOrc[1,2],"")
Else////////////////// I  T  E  N  S  //////////////////
	aOrcAux := {}
	aIte:= {}
	cQuery := "SELECT VS1.VS1_FILIAL , VS1.VS1_NUMORC , VS1.VS1_DATORC , VS1.VS1_CODVEN ,"
	cQuery += " VS1.VS1_CLIFAT , VS1.VS1_LOJA , VS1.VS1_NCLIFT , VS3.VS3_GRUITE , VS3.VS3_CODITE ,"
	cQuery += " VS3.VS3_QTDITE , VS3.VS3_VALTOT , SB1.B1_DESC , SA3.A3_NOME "
	cQuery += "FROM "+RetSqlName("VS1")+" VS1 , "+RetSqlName("VS3")+" VS3 , "+RetSqlName("SB1")+" SB1 , "+RetSqlName("SA3")+" SA3, "+RetSqlName("VE6")+" VE6 "
	cQuery += "WHERE "
	if cFilFilial <> STR0028 
		cQuery += "	VS1.VS1_FILIAL = '"+cFilFilial+"' AND "
	Endif	
	cQuery += " VS1.VS1_DATORC >= '"+dtos(dPerIni)+"' AND VS1.VS1_DATORC <= '"+dtos(dPerFin)+"' AND "  
	cQuery += " VS1.VS1_NUMOSV='"+space(len(VS1->VS1_NUMOSV))+"' AND"
	cQuery += " VS1.VS1_NUMNFI='"+space(len(VS1->VS1_NUMNFI))+"' AND"
	cQuery += " VS1.VS1_STATUS NOT IN ('X','C') AND"
	cQuery += " VS3.VS3_FILIAL=VS1.VS1_FILIAL AND"
	cQuery += " VS3.VS3_NUMORC=VS1.VS1_NUMORC AND"
	cQuery += " SB1.B1_FILIAL='"+xFilial("SB1")+"' AND"
	cQuery += " VS3.VS3_GRUITE=SB1.B1_GRUPO"
	cQuery += " AND VS3.VS3_CODITE=SB1.B1_CODITE"
	cQuery += "	AND VE6.VE6_FILIAL='"+xFilial("VE6")+"' AND VE6.VE6_INDREG='3' AND VE6.VE6_NUMORC = VS1.VS1_NUMORC AND VE6.VE6_GRUITE=VS3.VS3_GRUITE AND VE6.VE6_CODITE=VS3.VS3_CODITE "
	cQuery += " AND VS1.VS1_CODVEN=SA3.A3_COD"
	cQuery += " AND ( VS1.VS1_FILIAL=SA3.A3_FILIAL OR"
	cQuery += "       SA3.A3_FILIAL='"+xFilial("SA3")+"') AND"
	cQuery += " VS1.D_E_L_E_T_=' ' AND SA3.D_E_L_E_T_=' ' AND VS3.D_E_L_E_T_=' ' AND SB1.D_E_L_E_T_=' ' AND  VE6.D_E_L_E_T_=' '"
	cQuery += " ORDER BY VS3.VS3_GRUITE , VS3.VS3_CODITE , VS1.VS1_NUMORC"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS3, .F., .T. )
	ProcRegua(( cQAlVS3 )->(Reccount()))
	While !( cQAlVS3 )->( Eof() )
		Incproc(STR0010+": "+( cQAlVS3 )->( VS1_NUMORC ))   //Orcamento
		aAdd(aOrcAux,{( cQAlVS3 )->( VS1_FILIAL ) , ( cQAlVS3 )->( VS1_NUMORC ) , stod(( cQAlVS3 )->( VS1_DATORC )) , ( cQAlVS3 )->( VS1_CODVEN )+" - "+ ( cQAlVS3 )->( A3_NOME ) , ( cQAlVS3 )->( VS3_VALTOT ) , ( cQAlVS3 )->( VS1_CLIFAT  ) +"-"+ ( cQAlVS3 )->( VS1_LOJA ) +" "+( cQAlVS3 )->( VS1_NCLIFT ) , ( cQAlVS3 )->( VS3_GRUITE ) , ( cQAlVS3 )->( VS3_CODITE ) , ( cQAlVS3 )->( VS3_QTDITE ) })
		nTotGeral += ( cQAlVS3 )->( VS3_VALTOT )
		If cQuebra # ( cQAlVS3 )->( VS3_GRUITE ) + ( cQAlVS3 )->( VS3_CODITE )
			cQuebra := ( cQAlVS3 )->( VS3_GRUITE ) + ( cQAlVS3 )->( VS3_CODITE )
			aAdd(aIte,{( cQAlVS3 )->( VS3_GRUITE ) , ( cQAlVS3 )->( VS3_CODITE ) , ( cQAlVS3 )->( B1_DESC ) , ( cQAlVS3 )->( VS3_QTDITE ) , ( cQAlVS3 )->( VS3_VALTOT ) })
		Else
			aIte[len(aIte),4] += ( cQAlVS3 )->( VS3_QTDITE )
			aIte[len(aIte),5] += ( cQAlVS3 )->( VS3_VALTOT )
		Endif
		( cQAlVS3 )->( DbSkip() )
	EndDo
	( cQAlVS3 )->( dbCloseArea() )
	If Len(aIte) <= 0
		Aadd(aIte,{ "" , "" , "" , 0 , 0 })
	EndIf
	olBox21:nAt := 1
	olBox21:SetArray(aIte)
	olBox21:bLine := { || {  aIte[olBox21:nAt,1] ,;
	aIte[olBox21:nAt,2] ,;
	aIte[olBox21:nAt,3] ,;
	FG_AlinVlrs(Transform(aIte[olBox21:nAt,4],"@E 99999.99")) ,;
	FG_AlinVlrs(Transform(aIte[olBox21:nAt,5],"@E 99,999,999.99")) }}
	olBox21:SetFocus()
	olBox21:Refresh()
	FS_LEVFILHO(nCkPerg1,"",aIte[1,1],aIte[1,2])
EndIf
if nCkPerg1 <> 0
	olBox11:lVisible:=.f.
	olBox22:lVisible:=.f.
	olBox12:lVisible:=.f.
	olBox21:lVisible:=.f.
	oComboOrc:lVisible:=.f.
	oComboIte:lVisible:=.f.
	If nCkPerg1==1
		olBox11:lVisible:=.t.
		olBox12:lVisible:=.t.
		oComboOrc:lVisible:=.t.
		olBox11:Refresh()
		olBox12:Refresh()
		oComboOrc:Refresh()
		oTotGeral:Refresh()
	Else
		olBox22:lVisible:=.t.
		olBox21:lVisible:=.t.
		oComboIte:lVisible:=.t.
		olBox22:Refresh()
		olBox21:Refresh()
		oComboIte:Refresh()
	EndIf
EndIf
Return

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_LEVFILHO ≥ Autor ≥  Andre/Rafael         ≥ Data ≥ 31/03/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Carrega os dados do ListBox Filho                             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function FS_LEVFILHO(nCkPerg1,cFil,cPos1,cPos2)
Local cQAlVS1 := "SQLVS1"
Local cQAlVS3 := "SQLVS3"
Local cQuery  := ""
Local ni 	  := 0
Local nPos    := 0
If nCkPerg1 == 1 .or. nCkPerg1 == 0 // Orcamento
	aIte := {}
	cQuery := "SELECT VS3.VS3_FILIAL, VS3.VS3_GRUITE , VS3.VS3_CODITE , VS3.VS3_QTDITE , VS3.VS3_VALTOT , SB1.B1_DESC"
	cQuery += " FROM "+RetSqlName("VS3")+" VS3 , "+RetSqlName("SB1")+" SB1"
	cQuery += " WHERE VS3.VS3_FILIAL='"+ cFil +"' AND"
	cQuery += " VS3.VS3_NUMORC='"+ cPos1 +"' AND"
	cQuery += " SB1.B1_FILIAL='"+xFIlial("SB1")+"' AND"
	cQuery += " VS3.VS3_GRUITE=SB1.B1_GRUPO"
	cQuery += " AND VS3.VS3_CODITE=SB1.B1_CODITE"
	cQuery += " AND VS3.D_E_L_E_T_=' ' AND SB1.D_E_L_E_T_=' ' ORDER BY VS3.VS3_GRUITE , VS3.VS3_CODITE"
	dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS3, .F., .T. )
	While !( cQAlVS3 )->( Eof() )
		if Alltrim(( cQAlVS3 )->( VS3_FILIAL )) == Alltrim(cFilFilial) .or. cFilFilial == STR0028
			aAdd(aIte,{( cQAlVS3 )->( VS3_GRUITE ) , ( cQAlVS3 )->( VS3_CODITE ) , ( cQAlVS3 )->( B1_DESC ) , ( cQAlVS3 )->( VS3_QTDITE ) , ( cQAlVS3 )->( VS3_VALTOT ) })
		endif
		( cQAlVS3 )->( DbSkip() )
	EndDo
	( cQAlVS3 )->( dbCloseArea() )
	If Len(aIte) <= 0
		Aadd(aIte,{ "" , "" , "" , 0 , 0 })
	EndIf
	If nCkPerg1 == 1
		olBox12:nAt := 1
		olBox12:SetArray(aIte)
		olBox12:bLine := { || {  aIte[olBox12:nAt,1] ,;
		aIte[olBox12:nAt,2] ,;
		aIte[olBox12:nAt,3] ,;
		FG_AlinVlrs(Transform(aIte[olBox12:nAt,4],"@E 99999.99")) ,;
		FG_AlinVlrs(Transform(aIte[olBox12:nAt,5],"@E 99,999,999.99")) }}
		olBox12:SetFocus()
		olBox12:Refresh()
	EndIf
Else
	aOrc:= {}
	nPos := aScan(aOrcAux,{|x| x[7]+x[8] == cPos1 + cPos2 })
	If nPos > 0
		For ni:=nPos to len(aOrcAux)
			If aOrcAux[ni,7]+aOrcAux[ni,8] == cPos1 + cPos2
				Aadd(aOrc,{ aOrcAux[ni,1] , aOrcAux[ni,2] , aOrcAux[ni,3] , aOrcAux[ni,4] , aOrcAux[ni,5] , aOrcAux[ni,6]  , aOrcAux[ni,9] })
			Else
				Exit
			EndIf
		Next
	EndIf
	If Len(aOrc) <= 0
		Aadd(aOrc,{ "" , "" , "", "" , 0 , "", 0 })
	EndIf
	olBox22:nAt := 1
	olBox22:SetArray(aOrc)
	olBox22:bLine := { || {  aOrc[olBox22:nAt,1] ,;
	aOrc[olBox22:nAt,2] ,;
	Transform(aOrc[olBox22:nAt,3],"@D") ,;
	aOrc[olBox22:nAt,4] ,;
	FG_AlinVlrs(Transform(aOrc[olBox22:nAt,7],"@E 99999.99")) ,;
	FG_AlinVlrs(Transform(aOrc[olBox22:nAt,5],"@E 99,999,999.99")) ,;
	aOrc[olBox22:nAt,6]}}
	olBox22:SetFocus()
	olBox22:Refresh()
EndIf
Return


///////////////////////// I  M  P  R  E  S  S  A  O  ///////////////////////////

/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥ FS_IMPRIME  ≥ Autor ≥  Rafael               ≥ Data ≥ 01/04/09 ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Impressao do relatorio                                        ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¥±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function FS_IMPRIMIR(nCkPerg1)

Local cDesc1	:= ""
Local cDesc2	:= ""
Local cDesc3	:= ""
Local cAlias	:= ""
Local nPos 		:= 0
Local nj			:= 0
Local ni       := 0
Local nTotal 	:= 0
Local cFil  	:= ""
Local cPos1	   := ""
Local cQAlVS1 := "SQLVS1"
Local cQAlVS3 := "SQLVS3"
Private nLin    := 1
Private aReturn := { "" , 1 , "" , 1 , 2 , 1 , "" , 1 }
Private cTamanho:= "M"           // P/M/G
Private Limite  := 132           // 80/132/220
Private aOrdem  := {}            // Ordem do Relatorio
Private cTitulo := STR0001   //Itens Reservados em OrÁamentos Aceitos
Private cNomProg:= "OFIOC350"
Private cNomeRel:= "OFIOC350"
Private nLastKey:= 0
Private cabec1  := ""
Private cabec2  := ""
Private nCaracter:=15
Private m_Pag   := 1
cNomeRel := SetPrint(cAlias,cNomeRel,,@cTitulo,cDesc1,cDesc2,cDesc3,.f.,,.t.,cTamanho)
If nLastKey == 27
	Return
EndIf

SetDefault(aReturn,cAlias)
Set Printer to &cNomeRel
Set Printer On
Set Device  to Printer

If nCkPerg1 == 1
	cTitulo += substr(cComboOrc,3)
	//Orcamento selecionado + itens
	If left(cComboOrc,1)=="1"
		cabec1 := left(left(STR0026 +space(10),10)+left(STR0010 + space(11),11)+left(STR0016 +space(10),10)+" "+left(STR0017 +space(30),30)+"  "+ STR0019 +space(120),120) + STR0015 //Filial ## Orcamento ## Data   ## Vendedor ## Cliente ## Valor Total
		nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		//Orcamento
		@ nLin++ , 00 psay left(left(aOrc[olBox11:nAt,1]+space(10),10)+left(aOrc[olBox11:nAt,2]+space(11),11)+left(Transform(aOrc[olBox11:nAt,3],"@D")+space(10),10)+" "+left(aOrc[olBox11:nAt,4]+space(30),30) +"  "+ aOrc[olBox11:nAt,6]+space(118),118)+Transform(aOrc[olBox11:nAt,5],"@E 99,999,999.99")
		nLin++
		//CabeÁalho de itensa
		@ nLin++ , 04 psay left(left(STR0020 +space(10),10) + STR0027 + space(13) + STR0022 + space(100),100) + STR0018+ "      "+ STR0015   //Grupo ## copd. item ## descricao ## quantidade ## valor total
		For ni :=1 to len(aIte)
			If nLin >= 60
				nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
			EndIf
			@ nLin++ , 04 psay left(left(aIte[ni,1]+space(10),10) + aIte[ni,2] + aIte[ni,3]+space(102),102) + Transform(aIte[ni,4],"@E 99999.99")+ "    " +Transform(aIte[ni,5],"@E 99,999,999.99")
		Next
		//todos orcamentos apenas
	ElseIf left(cComboOrc,1)=="2"
		cabec1 := left(left(STR0026 +space(10),10)+left(STR0010 + space(11),11)+left(STR0016 +space(10),10)+" "+left(STR0017 +space(30),30)+"  "+ STR0019 +space(120),120) + STR0015//Filial ## Orcamento ## Data   ## Vendedor ## Cliente ## Valor Total
		nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		For ni:=1 to len(aOrc)
			If nLin >= 60
				nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
			EndIf
			@ nLin++ , 00 psay left(left(aOrc[ni,1]+space(10),10)+left(aOrc[ni,2]+space(11),11)+left(Transform(aOrc[ni,3],"@D")+space(10),10)+" "+left(aOrc[ni,4]+space(30),30) +"  "+ aOrc[ni,6]+space(118),118)+Transform(aOrc[ni,5],"@E 99,999,999.99")
			nTotal += aOrc[ni,5]
		Next
		@ nLin++ , 110 psay repl("_",21)
		@ nLin++ , 97 psay left(STR0015 + space(20),20)+" "+Transform(nTotal,"@E 99,999,999.99") //Valor total
		
	ElseIf left(cComboOrc,1)=="3"
		cFil  := ""
		cPos1 := ""
		cabec1 := left(left(STR0026 +space(10),10)+left(STR0010 + space(11),11)+left(STR0016 +space(10),10)+" "+left(STR0017 +space(30),30)+"  "+ STR0019 +space(120),120) + STR0015		//Filial ## Orcamento ## Data   ## Vendedor ## Cliente ## Valor Total
		cabec2 :=left(left( STR0020 +space(10),10) + STR0027 +space(13) + STR0022 + space(104),104) + STR0018 + "      "+ STR0015		//Grupo ## copd. item ## descricao ## quantidade ## valor total
		nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		For ni:=1 to len(aOrc)
			If nLin >= 60
				nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
			EndIf
			@ nLin++ , 00 psay left(left(aOrc[ni,1]+space(10),10)+left(aOrc[ni,2]+space(11),11)+left(Transform(aOrc[ni,3],"@D")+space(10),10)+" "+left(aOrc[ni,4]+space(30),30) +"  "+ aOrc[ni,6]+space(118),118)+Transform(aOrc[ni,5],"@E 99,999,999.99")
			cFil := aOrc[ni,1]
			cPos1 := aOrc[ni,2]
			cQuery := "SELECT VS3.VS3_GRUITE , VS3.VS3_CODITE , VS3.VS3_QTDITE , VS3.VS3_VALTOT , SB1.B1_DESC FROM "+RetSqlName("VS3")+" VS3 , "+RetSqlName("SB1")+" SB1 WHERE VS3.VS3_FILIAL='"+ cFil +"' AND VS3.VS3_NUMORC='"+ cPos1 +"' AND SB1.B1_FILIAL='"+xFilial("SB1")+"' AND VS3.VS3_GRUITE=SB1.B1_GRUPO AND VS3.VS3_CODITE=SB1.B1_CODITE AND VS3.D_E_L_E_T_=' ' AND SB1.D_E_L_E_T_=' ' ORDER BY VS3.VS3_GRUITE , VS3.VS3_CODITE"
			dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlVS3, .F., .T. )
			While !( cQAlVS3 )->( Eof() )
				@ nLin++ , 00 psay left(left(( cQAlVS3 )->( VS3_GRUITE )+space(10),10) + ( cQAlVS3 )->( VS3_CODITE ) + ( cQAlVS3 )->( B1_DESC )+space(102),102) +"    "+ Transform(( cQAlVS3 )->( VS3_QTDITE ),"@E 99999.99")+ "    " +Transform(( cQAlVS3 )->( VS3_VALTOT ),"@E 99,999,999.99")
				nTotal += ( cQAlVS3 )->( VS3_VALTOT )
				( cQAlVS3 )->( DbSkip() )
			EndDo
			( cQAlVS3 )->( dbCloseArea() )
			nLin++
		Next
		@ nLin++ , 110 psay repl("_",21)
		@ nLin++ , 97 psay left(STR0015 + space(20),20)+" "+Transform(nTotal,"@E 99,999,999.99")   //valor total
	EndIF
	
ElseIf nCkPerg1 == 2  //Itens
	cTitulo += substr(cComboIte,3)
	//Item selecionado + OS
	If left(cComboIte,1)=="1"
		cabec1 := left(left( STR0020 +space(10),10) + STR0027 +space(13) + STR0022 + space(104),104) + STR0018 + "      "+ STR0015		//Grupo ## copd. item ## descricao ## quantidade ## valor total
		nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		//Item
		@ nLin++ , 00 psay left(left(aIte[olBox21:nAt,1]+space(10),10) + aIte[olBox21:nAt,2] + aIte[olBox21:nAt,3]+space(106),106) + Transform(aIte[olBox21:nAt,4],"@E 99999.99")+ "    " +Transform(aIte[olBox21:nAt,5],"@E 99,999,999.99")
		nLin++
		//CabeÁalho de Orcamentos
		@ nLin++ , 04 psay left(left(STR0026 +space(10),10)+left(STR0010 + space(11),11)+left(STR0016 +space(10),10)+" "+left(STR0017 +space(30),30)+"  "+ STR0019 +space(100),100) + STR0018 + "      "+ STR0015//Filial ## Orcamento ## Data   ## Vendedor ## Cliente ## Quantidade ##  Valor Total
		For ni :=1 to len(aOrc)
			If nLin >= 60
				nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
			EndIf
			@ nLin++ , 04 psay left(left(aOrc[ni,1]+space(10),10)+left(aOrc[ni,2]+space(11),11)+left(Transform(aOrc[ni,3],"@D")+space(10),10)+" "+left(aOrc[ni,4]+space(30),30) +"  "+ aOrc[ni,6]+space(100),100) +"  "+ Transform(aOrc[ni,7],"@E 99999.99")+"    "+Transform(aOrc[ni,5],"@E 99,999,999.99")
		Next
	ElseIf left(cComboIte,1)=="2"
		cabec1 := left(left( STR0020 +space(10),10) + STR0027 +space(13) + STR0022 + space(104),104) + STR0018 + "      "+ STR0015		//Grupo ## copd. item ## descricao ## quantidade ## valor total
		nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		//Item
		For ni:=1 to len(aIte)
			If nLin >= 60
				nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
			EndIf
			@ nLin++ , 00 psay left(left(aIte[ni,1]+space(10),10) + aIte[ni,2] + aIte[ni,3]+space(106),106) + Transform(aIte[ni,4],"@E 99999.99")+ "    " +Transform(aIte[ni,5],"@E 99,999,999.99")
		Next
		
	ElseIf left(cComboIte,1)=="3"
		cabec1 := left(left( STR0020 +space(10),10) + STR0027 +space(13) + STR0022 + space(104),104) + STR0018 + "      "+ STR0015		//Grupo ## copd. item ## descricao ## quantidade ## valor total
		cabec2 := space(4)+left(left(STR0026 +space(10),10)+left(STR0010 + space(11),11)+left(STR0016 +space(10),10)+" "+left(STR0017 +space(30),30)+"  "+STR0019 +space(100),100) + STR0018 + "      "+ STR0015
		nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
		//Item
		For ni:=1 to len(aIte)
			If nLin >= 60
				nLin := cabec(ctitulo,cabec1,cabec2,cnomprog,ctamanho,nCaracter) + 1
			EndIf
			@ nLin++ , 00 psay left(left(aIte[ni,1]+space(10),10) + aIte[ni,2] + aIte[ni,3]+space(106),106) + Transform(aIte[ni,4],"@E 99999.99")+ "    " +Transform(aIte[ni,5],"@E 99,999,999.99")
			
			nPos := aScan(aOrcAux,{|x| x[7]+x[8] == aIte[ni,1] + aIte[ni,2] })
			If nPos > 0
				For nj:=nPos to len(aOrcAux)
					If aOrcAux[nj,7]+aOrcAux[nj,8] == aIte[ni,1] + aIte[ni,2]
						@ nLin++ , 04 psay left(left(aOrcAux[nj,1]+space(10),10)+left(aOrcAux[nj,2]+space(11),11)+left(Transform(aOrcAux[nj,3],"@D")+space(10),10)+" "+left(aOrcAux[nj,4]+space(30),30) +"  "+ aOrcAux[nj,6]+space(100),100) +"  "+ Transform(aOrcAux[nj,9],"@E 99999.99")+"    "+Transform(aOrcAux[nj,5],"@E 99,999,999.99")
						nTotal += aOrcAux[nj,5]
					Else
						Exit
					EndIf
				Next
				nLin++
			EndIf
		Next
		@ nLin++ , 110 psay repl("_",21)
		@ nLin++ , 97 psay left(STR0015 + space(20),20)+" "+Transform(nTotal,"@E 99,999,999.99")    //Valor total
	EndIf
EndIf

Ms_Flush()
Set Printer to
Set Device  to Screen
If aReturn[5] == 1
	OurSpool( cNomeRel )
EndIf
Return()

////////// Verifica a Base da Empresa para realizar a Consulta //////////
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Funcao    ≥FS_VERBASE ≥ Autor ≥ Rafael G. da Silva   ≥ Data ≥01/04/2009|±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Verifica a Base da Empresa para realizar a Consulta.        ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
Static Function FS_VERBASE()
Local cQuery  := ""
Local cQAlias := "SQLERRO"
Local lOk     := .t.
Local cEmpSALVA:= cEmpAnt
Local cFilSALVA:= cFilAnt
Local aSM0     := {}
Private bBlock:= ErrorBlock()
Private bErro := ErrorBlock( { |e| lOk := .f. } )
aSM0 := FWArrFilAtu(cEmpAnt,cFilAnt) // Filial Origem (Filial logada)
cEmpAnt := aSM0[1]
cFilAnt := aSM0[2]
cQuery := "SELECT VS1.VS1_NUMORC FROM "+RetSqlName("VS1")+" VS1 WHERE VS1.VS1_NUMORC='1'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
cQuery := "SELECT VS3.VS3_NUMORC FROM "+RetSqlName("VS3")+" VS3 WHERE VS3.VS3_NUMORC='1'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
cQuery := "SELECT SB1.B1_COD FROM "+RetSqlName("SB1")+" SB1 WHERE SB1.B1_COD='1'"
dbUseArea( .T., "TOPCONN", TcGenQry( ,, cQuery ), cQAlias , .F., .T. )
( cQAlias )->( dbCloseArea() )
ErrorBlock(bBlock)
cEmpAnt := cEmpSALVA
cFilAnt := cFilSALVA
Return(lOk)