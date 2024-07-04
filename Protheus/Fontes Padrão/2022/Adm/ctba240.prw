#INCLUDE "CTBA240.CH"
#INCLUDE "PROTHEUS.CH"
#Include  "FONT.CH"
#Include  "COLORS.CH"

STATIC __lCusto := .F.             
STATIC __lItem	:= .F.
STATIC __lClVL  := .F.
STATIC __lEC05  := .F. //Entidade 05
STATIC __lEC06  := .F. //Entidade 06
STATIC __lEC07  := .F. //Entidade 07
STATIC __lEC08  := .F. //Entidade 08
STATIC __lEC09  := .F. //Entidade 09
Static __cLastEmp
Static __cEmpAnt
Static __cFilAnt
Static __cFil
Static __cArqTab
Static lFWCodFil := .T.
Static _lCpoEnt05 //Campo Entidade 05
Static _lCpoEnt06 //Campo Entidade 06
Static _lCpoEnt07 //Campo Entidade 07
Static _lCpoEnt08 //Campo Entidade 08
Static _lCpoEnt09 //Campo Entidade 09
Static __cAlias05
Static __cAlias06
Static __cAlias07
Static __cAlias08
Static __cAlias09
Static __cF3Ent05
Static __cF3Ent06
Static __cF3Ent07
Static __cF3Ent08
Static __cF3Ent09

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTBA240  ³ Autor ³ Simone Mie Sato       ³ Data ³ 04/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastramento Roteiro de Consolidacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBA240()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CTBA240()

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

If CTB240Emp() //Se a empresa/filial aberta estah de acordo com a empresa/filia informada.

	PRIVATE aRotina := MenuDef()
				
	PRIVATE cCadastro := STR0007  // "Cadastro Roteiro de Consolidacao"
	
	Private lCTB240Ori := .T.
	Private aIndexes
	
	aIndexes := CTBEntGtIn()

	Ctb240IniVar()

	__lCusto  := CtbMovSaldo("CTT")
	__lItem	  := CtbMovSaldo("CTD")
	__lCLVL	  := CtbMovSaldo("CTH")
	If(_lCpoEnt05,__lEC05 := CtbMovSaldo("CT0",,"05"),Nil)
	If(_lCpoEnt05,__lEC06 := CtbMovSaldo("CT0",,"06"),Nil)
	If(_lCpoEnt05,__lEC07 := CtbMovSaldo("CT0",,"07"),Nil)
	If(_lCpoEnt05,__lEC08 := CtbMovSaldo("CT0",,"08"),Nil)
	If(_lCpoEnt05,__lEC09 := CtbMovSaldo("CT0",,"09"),Nil)	
	__cArqTab := cArqTab			//Inicializa Variaveis Estaticas
	__cLastEmp:= cEmpAnt + IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	__cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	__cEmpAnt := cEmpAnt

	dbSelectArea("CTB")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endereca a funcao de BROWSE                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"CTB")	

	cArqTab := __cArqTab    //Devolve por Variaveis Estaticas
	cFilAnt := __cFilAnt
	cEmpAnt := __cEmpAnt
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB240Cad ³ Autor ³ Simone Mie Sato       ³ Data ³ 04.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cadastro do Roteiro de Consolidacao                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb240Cad(cAlias,nReg,nOpc)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGACTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                   ³±±
±±³          ³ ExpN1 = Numero do Registro                                 ³±±
±±³          ³ ExpN2 = Numero da Opcao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb240Cad(cAlias,nReg,nOpc)

Local cEmpDes       //Codigo da Empresa Destino
Local cFilDes       //Codigo da Filial Destino
Local cCtb240Cod	//Codigo do Roteiro
Local cCtb240Ord    //Ordem
Local c240CtDest    //Conta Destino
Local c240CCDest    //C.Custo Destino
Local c240ItDest    //Item Destino
Local c240CvDest    //Classe de Valor Destino
Local c240SlDest    //Tipo de Saldo Destino
Local c240E05Des    //Entidade 05 Destino
Local c240E06Des	//Entidade 06 Destino
Local c240E07Des    //Entidade 07 Destino
Local c240E08Des    //Entidade 08 Destino
Local c240E09Des    //Entidade 09 Destino
Local cSayCusto     := CtbSayApro("CTT")
Local cSayItem      := CtbSayApro("CTD")
Local cSayClVL      := CtbSayApro("CTH")
Local cSayEnt05     := CtbSayApro("","05") //Descrição Resumida Entidade 05
Local cSayEnt06     := CtbSayApro("","06") //Descrição Resumida Entidade 06
Local cSayEnt07     := CtbSayApro("","07") //Descrição Resumida Entidade 07
Local cSayEnt08     := CtbSayApro("","08") //Descrição Resumida Entidade 08
Local cSayEnt09     := CtbSayApro("","09") //Descrição Resumida Entidade 09
Local oGet
Local oDlg
Local oCtaDest
Local oCCDest
Local oItemDest
Local oClVlDes
Local oTpSlDest
Local oEnt05Des
Local oEnt06Des
Local oEnt07Des
Local oEnt08Des
Local oEnt09Des
Local oHistAg
Local lDigOk    := (nOpc == 3 .Or. nOpc == 4)
Local lHasAglut := .T.
Local lRet      := .F.
Local nPosic01  := 0
Local nPosic02  := 0
Local aArea     := GetArea()
Local aAlias	:= {}
Local oSize

Private c240HistAg	:= '' //Historico Aglutinado


If nOpc == 3				// Inclusao
	cEmpDes		:=	CriaVar("CTB_EMPDES") //Codigo da Empresa Destino
	cFilDes		:=	CriaVar("CTB_FILDES") //Codigo da Filial Destino
	cCtb240Cod	:=	CriaVar("CTB_CODIGO") //Codigo do Roteiro
	cCtb240Ord	:=	CriaVar("CTB_ORDEM")  //Ordem
	c240CtDest	:=	CriaVar("CTB_CTADES") //Conta Destino
	c240CCDest	:=	CriaVar("CTB_CCDES")  //C.Custo Destino
	c240ItDest	:=	CriaVar("CTB_ITEMDE") //Item Destino
	c240CvDest	:=	CriaVar("CTB_CLVLDE") //Classe de Valor Destino
	c240SlDest	:=	CriaVar("CTB_TPSLDE") //Tipo de Saldo Destino
    
    If(_lCpoEnt05,c240E05Des := CriaVar("CTB_E05DES"),Nil) //Entidade 05 Destino
    If(_lCpoEnt06,c240E06Des := CriaVar("CTB_E06DES"),Nil) //Entidade 06 Destino
    If(_lCpoEnt07,c240E07Des := CriaVar("CTB_E07DES"),Nil) //Entidade 07 Destino
    If(_lCpoEnt08,c240E08Des := CriaVar("CTB_E08DES"),Nil) //Entidade 08 Destino
    If(_lCpoEnt09,c240E09Des := CriaVar("CTB_E09DES"),Nil) //Entidade 09 Destino
     
	If lHasAglut
		c240HistAg	:=	CriaVar("CTB_HAGLUT")   //Historico Aglutinado
	EndIf
	lDigita		:= .T.
Else							// Visualizacao / Alteracao / Exlusao
	cEmpDes		:=	CTB_EMPDES		//Codigo da Empresa Destino
	cFilDes		:=	CTB_FILDES		//Codigo da Filial Destino
	cCtb240Cod	:=	CTB_CODIGO	  	//Codigo do Roteiro
	cCtb240Ord	:=	CTB_ORDEM	    //Ordem
	c240CtDest	:=	CTB_CTADES		//Conta Destino
	c240CCDest	:=	CTB_CCDES	    //C.Custo Destino
	c240ItDest	:=	CTB_ITEMDE    	//Item Destino
	c240CvDest	:=	CTB_CLVLDE		//Classe de Valor Destino
	c240SlDest	:=	CTB_TPSLDE		//Tipo de Saldo Destino
	
	If(_lCpoEnt05,c240E05Des := CTB_E05DES,Nil) //Entidade 05 Destino
	If(_lCpoEnt06,c240E06Des := CTB_E06DES,Nil) //Entidade 06 Destino
	If(_lCpoEnt07,c240E07Des := CTB_E07DES,Nil) //Entidade 07 Destino
	If(_lCpoEnt08,c240E08Des := CTB_E08DES,Nil) //Entidade 08 Destino
	If(_lCpoEnt09,c240E09Des := CTB_E09DES,Nil) //Entidade 09 Destino
    
	If lHasAglut
		c240HistAg	:=	CTB_HAGLUT		//Historico Aglutinado
	EndIf
	lDigita		:= .F.
EndIf

Private aTELA[0][0],aGETS[0],aHeader[0],aCols[0],Continua := .F.,nUsado:=0

Ctb240Getd(nOpc)

nOpca 	:= 0



DEFINE MSDIALOG oDlg TITLE cCadastro From 000,000 To 720,1000 OF oMainWnd PIXEL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Calcula dimensões                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSize := FwDefSize():New(.T.,,,oDlg)
oSize:AddObject( "CABECALHO",  100, 100, .T., .T. ) // Totalmente dimensionavel

oSize:lProp 	:= .T. // Proporcional             
oSize:aMargins 	:= { 3, 3, 3, 3 } // Espaco ao lado dos objetos 0, entre eles 3 x

oSize:Process() 	   // Dispara os calculos  

	
	nLinIni := oSize:GetDimension("CABECALHO","LININI")
	
	@ nLinIni + 15 , 05  Say STR0008 SIZE 070,8	OF oDlg PIXEL	// Empresa Destino:
	@ nLinIni + 13 , 60 	MsGet oEmpDes VAR cEmpDes /*F3 "YM0"*/ Picture "!!" SIZE 015,8 OF oDlg PIXEL
	oEmpDes:lReadOnly := .T.
		
	@ nLinIni + 30 , 05	Say STR0009 SIZE 070,8	OF oDlg PIXEL		// Filial Destino:
	@ nLinIni + 28 , 60	MsGet oFilDes VAR cFilDes /*F3 "SM0"*/ Picture Replicate( "!!", IIf( lFWCodFil, FWGETTAMFILIAL, 2 ) ) ;
	OF oDlg PIXEL	//SIZE 015,8
	oFilDes:lReadOnly := .T.
	
  	@ nLinIni + 45 , 05 	Say STR0010	SIZE 070,8	 OF oDlg PIXEL		// Codigo do Roteiro:
	@ nLinIni + 43 , 60	MsGet oCodigo Var cCtb240Cod Picture "@!" When lDigita ;
	Valid !Empty(cCtb240Cod) .And. FreeForUse("CTB",cCtb240Cod) .And.;
	Ctb240Ord(cCtb240Cod,@cCtb240Ord,nOpc,oOrdem) SIZE 020,8   OF oDlg PIXEL	
	
	@ nLinIni + 60 , 05	Say STR0011 SIZE 070,8	OF oDlg PIXEL		// Ordem:
	@ nLinIni + 58 , 60	MsGet oOrdem Var cCtb240Ord Picture "@!" When lDigita ;
	Valid !Empty(cCtb240Ord).And.;
	Ctb240Ord(cCtb240Cod,@cCtb240Ord,nOpc,oOrdem) .And.;
	Ctb240Key(cCtb240Cod,cCtb240Ord,nOpc);
	SIZE 040,8  OF oDlg PIXEL			      					
	
	@ nLinIni + 75 , 05	Say STR0014 SIZE 070,8	OF oDlg PIXEL		// Tipo de Saldo Destino:
	@ nLinIni + 73 , 60	MSGET oTpSlDest VAR c240SlDest F3 "SL";
	Valid (!Empty(c240SlDest) .And. ExistCpo("SX5", "SL" + c240SlDest));
	SIZE 20,8	OF oDlg PIXEL	
	oTpSlDest:lReadOnly:= !lDigOk
	
	@ nLinIni + 15 , 166	Say STR0012 SIZE 070,8	OF oDlg PIXEL		//Conta Destino:
	@ nLinIni + 13 , 215	MsGet oCtaDest VAR c240CtDest F3 "CT1" Picture "@!" ;
	Valid Ctb240Cta(c240CtDest,"CT1",__cFilAnt) SIZE 070,8 OF oDlg PIXEL	 					
	oCtaDest:lReadOnly:= !(lDigOk .and. CT240F3CT("CT1",__cEmpAnt,__cFilAnt))
					
	@ nLinIni + 30 , 166	Say Alltrim(cSayCusto) + " " + STR0013 SIZE 070,8	OF oDlg PIXEL		// C.Custo Destino:
	@ nLinIni + 28 , 215	MsGet oCCDest VAR c240CCDest F3 "CTT" Picture "@!" ;
	Valid Ctb240CC(c240CCDest,"CTT",__cFilAnt) 	SIZE 070,8		OF oDlg PIXEL	
	oCCDest:lReadOnly:= !(lDigOk .and. __lCusto .And. CT240F3CT("CTT",__cEmpAnt,__cFilAnt))				
	
	@ nLinIni + 45 , 166  Say Alltrim(cSayItem) + " " + STR0013 SIZE 070,8	 OF oDlg PIXEL	// Item Destino:
	@ nLinIni + 43 , 215  MsGet oItemDest VAR c240ItDest F3 "CTD" Picture "@!" ;
	Valid Ctb240Item(c240ItDest,"CTD",__cFilAnt)	SIZE 070,8		OF oDlg PIXEL	
	oItemDest:lReadOnly:= !(lDigOk .and. __lItem .And. CT240F3CT("CTD",__cEmpAnt,__cFilAnt))				
	
	@ nLinIni + 60 , 166  Say Alltrim(cSayClVl) + " " + STR0013 SIZE 070,8	 OF oDlg PIXEL	// Classe de Valor Destino:
	@ nLinIni + 58 , 215  MsGet oClVlDes VAR c240CvDest F3 "CTH" Picture "@!" ;
   	Valid Ctb240ClVl(c240CvDest,"CTH",__cFilAnt)	SIZE 070,8		OF oDlg PIXEL	
	oClVlDes:lReadOnly:= !(lDigOk .and. __lClVl .And. CT240F3CT("CTH",__cEmpAnt,__cFilAnt))
	
	If lHasAglut
		@ nLinIni + 75, 166	Say STR0029 SIZE 050,8	OF oDlg PIXEL	// Hist. Aglutinado
		@ nLinIni + 73, 215	MSGET oHistAg VAR c240HistAg Picture "@S40" Valid empty(c240HistAg) ;
		.Or. Ctb240Form('C',c240HistAg)	SIZE 70,8 OF oDlg PIXEL
	EndIf
	
	
	nPosic01 := 6.1 //posição 1 para alinhamento dos campos adicionais
	nPosic02 := 6.1 //posição 2 para alinhamento dos campos adicionais
    
	aAdd(aAlias,"CT1")
	aAdd(aAlias,"CTT")
	aAdd(aAlias,"CTD")
	aAdd(aAlias,"CTH")
	aAdd(aAlias,"CT0")	
                      
    If _lCpoEnt05
		@ nLinIni + 75, 05	Say Alltrim(cSayEnt05) + " " + STR0013 SIZE 030,8 // Entidade 05###"Destino:"
		@ nLinIni + 73, 60	MsGet oEnt05Des VAR c240E05Des F3 __cF3Ent05 Picture "@!" ;
  						Valid Ctb240Ent(c240E05Des, __cAlias05, __cFilAnt, "05") SIZE 070,8
        oEnt05Des:lReadOnly:= !(lDigOk .And. __lEC05 .And. CT240F3CT(__cAlias05, __cEmpAnt, __cFilAnt))
        oEnt05Des:bGotFocus := {|| lCTB240Ori := .F. }
		nPosic01 += 0.81
		nPosic02 += 0.81
		
		aAdd(aAlias,__cAlias05)
			
	EndIf	    
	
    If _lCpoEnt06
		@ nLinIni + 90, 05 	Say Alltrim(cSayEnt06) + " " + STR0013 SIZE 030,8 // Entidade 06###"Destino:"
		@ nLinIni + 88, 60 	MsGet oEnt06Des VAR c240E06Des F3 __cF3Ent06 Picture "@!" ;
  						Valid Ctb240Ent(c240E06Des, __cAlias06, __cFilAnt, "06") SIZE 070,8
        oEnt06Des:lReadOnly:= !(lDigOk .And. __lEC06 .And. CT240F3CT(__cAlias06, __cEmpAnt, __cFilAnt))   						
        oEnt06Des:bGotFocus := {|| lCTB240Ori := .F. }
		nPosic01 += 0.81
		nPosic02 += 0.81
		aAdd(aAlias,__cAlias06)	
	EndIf	    

    If _lCpoEnt07
		@ nLinIni + 105, 05 	Say Alltrim(cSayEnt07) + " " + STR0013 SIZE 030,8 // Entidade 07###"Destino:"
		@ nLinIni + 103, 60 	MsGet oEnt07Des VAR c240E07Des F3 __cF3Ent07 Picture "@!" ;
  						Valid Ctb240Ent(c240E07Des, __cAlias07, __cFilAnt, "07") SIZE 070,8
        oEnt07Des:lReadOnly:= !(lDigOk .And. __lEC07 .And. CT240F3CT(__cAlias07, __cEmpAnt, __cFilAnt))   						
        oEnt07Des:bGotFocus := {|| lCTB240Ori := .F. }
		nPosic01 += 0.81
		nPosic02 += 0.81
		aAdd(aAlias,__cAlias07)	
	EndIf	        
                    
    If _lCpoEnt08
		@ nLinIni + 75, 166 	Say Alltrim(cSayEnt08) + " " + STR0013 SIZE 030,8 // Entidade 08###"Destino:"
		@ nLinIni + 73, 215 	MsGet oEnt08Des VAR c240E08Des F3 __cF3Ent08 Picture "@!" ;
  						Valid Ctb240Ent(c240E08Des, __cAlias08, __cFilAnt, "08") SIZE 070,8
        oEnt08Des:lReadOnly:= !(lDigOk .And. __lEC08 .And. CT240F3CT(__cAlias08, __cEmpAnt, __cFilAnt))   						
        oEnt08Des:bGotFocus := {|| lCTB240Ori := .F. }
		nPosic01 += 0.81
		nPosic02 += 0.81 
		aAdd(aAlias,__cAlias08)	
	EndIf	        
                    
    If _lCpoEnt09
		@ nLinIni + 90, 166 	Say Alltrim(cSayEnt09) + " " + STR0013 SIZE 030,8 // Entidade 09###"Destino:"
		@ nLinIni + 88, 215 	MsGet oEnt09Des VAR c240E09Des F3 __cF3Ent09 Picture "@!" ;
  						Valid Ctb240Ent(c240E09Des, __cAlias09, __cFilAnt, "09") SIZE 070,8
        oEnt09Des:lReadOnly:= !(lDigOk .And. __lEC09 .And. CT240F3CT(__cAlias09, __cEmpAnt, __cFilAnt))   						
        oEnt09Des:bGotFocus := {|| lCTB240Ori := .F. }
		nPosic01 += 0.81
		nPosic02 += 0.81	
		aAdd(aAlias,__cAlias09)
	EndIf	        
    
	

	
	oGet := MSGetDados():New(nLinIni + 130, oSize:GetDimension("CABECALHO","COLINI") ,;
								oSize:GetDimension("CABECALHO","LINEND"), oSize:GetDimension("CABECALHO","COLEND"),;
								3,"Ctb240LOK","Ctb240TOK","+CTB_LINHA",.T.)
								
	oGet:oBrowse:bGotFocus := {||lRet := Ctb240Key(cCtb240Cod,cCtb240Ord,nOpc) .And. ;
									CTB240BOk(c240CtDest,c240CCDest,c240ItDest,c240CvDest,c240E05Des,c240E06Des,c240E07Des,c240E08Des,c240E09Des), ;
									lCTB240Ori := .T., ;
									If(lRet, ;
										( 	oCtaDest :lReadOnly := .T.,;
											oCCDest  :lReadOnly := .T.,;
											oItemDest:lReadOnly := .T.,;
											oClVlDes :lReadOnly := .T.,;
											If(_lCpoEnt05,oEnt05Des:lReadOnly := .T.,Nil),;
											If(_lCpoEnt06,oEnt06Des:lReadOnly := .T.,Nil),;
											If(_lCpoEnt07,oEnt07Des:lReadOnly := .T.,Nil),;
											If(_lCpoEnt08,oEnt08Des:lReadOnly := .T.,Nil),;
											If(_lCpoEnt09,oEnt09Des:lReadOnly := .T.,NIl);
										), ;
									oCtaDest:SetFocus())}
		
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||nopca:=1,;		
			Iif(Ctb240Key(cCtb240Cod,cCtb240Ord,nOpc) .And. CTB240BOk(c240CtDest,c240CCDest,c240ItDest,c240CvDest,c240E05Des,c240E06Des,c240E07Des,c240E08Des,c240E09Des),;
			oDlg:End(),nOpca:=0)},{||CT240Canc(oDlg)})

	
IF nOpcA == 1
	Begin Transaction
		Ctb240Grv(nOpc,cEmpDes,cFilDes,cCtb240Cod,cCtb240Ord,c240CtDest,c240CCDest,c240ItDest,c240CvDest,c240SlDest,c240HistAg,c240E05Des,c240E06Des,c240E07Des,c240E08Des,c240E09Des)
	End Transaction	
ENDIF

cEmpAnt	:= __cEmpAnt
cFilAnt	:= __cFilAnt
//posiciona novamente na tabela SM0 para inicializador padrão empresa destino e filial destino funcionar
dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilAnt)

//Restaura os arquivos abertos em outras empresas
CT240ResEmp(aAlias)

RestArea(aArea)

Return nOpca

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB240Getd³ Autor ³ Simone Mie Sato       ³ Data ³ 04.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta Getdados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb240Getd(nOpc)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da Opcao                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb240Getd(nOpc)

Local aSaveArea  := GetArea()
Local nCont		 := 0
Local nPosEmpOri 	

FillGetDados(nOpc,"CTB",1,,,,,,,,{||MontaaCols(nOpc)},.T.)
nPosEmpOri := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_EMPORI"})

If nPosEmpOri > 0
	aHeader[nPosEmpOri, 6] :=  If(Empty(aHeader[nPosEmpOri, 6]), "Ctb240PEmp()", Alltrim(aHeader[nPosEmpOri, 6]) + ".And. Ctb240PEmp()")
EndIf

RestArea(aSaveArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CTB240KEY ³ Autor ³ Simone Mie Sato       ³ Data ³ 04.07.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida se o Codigo do Roteiro+Ordem ja existem.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb240Key(cCtb240Cod,cCtb240Ord,nOpc)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³SIGACTB                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo do Roteiro de Consolidacao                  ³±±
±±³          ³ ExpN1 = Ordem no Roteiro		                              ³±±
±±³          ³ ExpN2 = Opcao do Menu                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb240Key(cCtb240Cod,cCtb240Ord,nOpc)

Local lRet		:= .T.

If nOpc == 3
	dbSelectArea("CTB")
	dbSetOrder(1)
	If dbSeek(xFilial()+cCtb240Cod+cCtb240Ord)
		Help("  ", 1, "ROTJAEXIS")
		lRet := .F.
	EndIf
EndIf	
Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb240Cta ³ Autor ³ Simone Mie Sato       ³ Data ³ 04/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a conta existe e se eh analitica.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Ctb240Cta(c240CtDest,cAlias,cFilx)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³.T./.F.                            				    	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Valida‡„o da conta. 									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERV.	 ³ Essa funcao foi criada porque preciso procurar no arquivo  ³±±
±±³       	 ³ antes de validar,senao poderia usar a funcao VALIDACONTA	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Conta Destino									      ³±±
±±³          ³ExpC2 = Alias         								      ³±±
±±³          ³ExpC3 = Filial        								      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb240Cta(c240CtDest,cAlias,cFilX)

Local aSaveArea := GetArea()
Local lRet 		:= .T.
Local cFilB    	:= Ctb240Fil(cAlias, cFilX)

If !Empty(c240CtDest)
	dbSelectArea(cAlias)
	dbSetOrder(1)  
	dbSeek(cFilB+c240CtDest)
	If Found() .And. !Eof()
		If &(cAlias+"->CT1_CLASSE") != '2' // Se nao for analitico
			lRet := .F.
			Help("  ", 1, "NOCLASSE")
		Endif
	Else
		lRet := .F.                 
		Help(" ",1,"NOENTCAD") //Entidade nao existe no cadastro.	
	Endif
Endif    

RestArea(aSaveArea)

Return(lRet)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb240CC  ³ Autor ³ Simone Mie Sato       ³ Data ³ 04/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o centro de custo existe e se eh analitica.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb240CC(c240CCDest,cAlias,cFilx)						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                       						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Valida‡„o do centro de custo 						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERV.	 ³ Essa funcao foi criada porque preciso procurar no arquivo  ³±±
±±³       	 ³ antes de validar,senao poderia usar a funcao VALIDACUSTO	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Centro de Custo Destino							  ³±±
±±³          ³ExpC2 = Alias         								      ³±±
±±³          ³ExpC3 = Filial        								      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb240CC(c240CCDest,cAlias,cFilX)

Local aSaveArea := GetArea()
Local lRet 		:= .T.
Local cFilB    	:= Ctb240Fil(cAlias, cFilX)

If !Empty(c240CCDest)
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbSeek(cFilB+c240CCDest)
	If Found() .And. !Eof()
		If &(cAlias+"->CTT_CLASSE") != '2' // Se nao for analitico
			lRet := .F.
			Help("  ", 1, "NOCLASSE")
		Endif
	Else
		lRet := .F.                 
		Help(" ",1,"NOENTCAD") //Entidade nao existe no cadastro.	
	Endif    
Endif    

RestArea(aSaveArea)

Return(lRet)


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb240Item³ Autor ³ Simone Mie Sato       ³ Data ³ 04/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se o item  existe e se eh analitica.              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Ctb240Item(c240ItDest,cAlias,cFilx)  					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.             									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Valida‡ao do item   									      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERV.	 ³ Essa funcao foi criada porque preciso procurar no arquivo  ³±±
±±³       	 ³ antes de validar,senao poderia usar a funcao VALIDAITEM 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Item Destino									      ³±±
±±³          ³ExpC2 = Alias         								      ³±±
±±³          ³ExpC3 = Filial        								      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb240Item(c240ItDest,cAlias,cFilX)

Local aSaveArea := GetArea()
Local lRet 		:= .T.
Local cFilB    	:= Ctb240Fil(cAlias, cFilX)

If !Empty(c240ItDest)
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbSeek(cFilB+c240ItDest)
	If Found() .And. !Eof()
		If &(cAlias+"->CTD_CLASSE") != '2' // Se nao for analitico
			lRet := .F.
			Help("  ", 1, "NOCLASSE")
		Endif
	Else
		lRet := .F.                 
		Help(" ",1,"NOENTCAD") //Entidade nao existe no cadastro.	
	Endif   
Endif    

RestArea(aSaveArea)

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb240ClVl³ Autor ³ Simone Mie Sato       ³ Data ³ 04/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a classe de valor existe e se eh analitica.    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb240Clvl(c240CvDest,cAlias,cFilX)					      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T./.F.                       						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                       						      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³OBSERV.	 ³ Essa funcao foi criada porque preciso procurar no arquivo  ³±±
±±³       	 ³ antes de validar,senao poderia usar a funcao VALIDACLVL 	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Classe de Valor destino						      ³±±
±±³          ³ExpC2 = Alias         								      ³±±
±±³          ³ExpC3 = Filial        								      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb240ClVl(c240CvDest,cAlias,cFilX)

Local aSaveArea := GetArea()
Local lRet      := .T.
Local cFilB    	:= Ctb240Fil(cAlias, cFilX)

If !Empty(c240CvDest)
	dbSelectArea(cAlias)
	dbSetOrder(1)
	dbSeek(cFilB+c240CvDest)

	If Found() .And. !Eof()
		If &(cAlias+"->CTH_CLASSE") != '2' // Se nao for analitico
			lRet := .F.
			Help("  ", 1, "NOCLASSE")
		Endif
	Else
		lRet := .F.                 
		Help(" ",1,"NOENTCAD") //Entidade nao existe no cadastro.	
	Endif
Endif
RestArea(aSaveArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA240Ent ºAutor  ³Microsiga          º Data ³  04/13/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a conta existe e se eh analitica.              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb240Ent(c240EntDest,cAlias,cFilX, cIdEntid)

Local aSaveArea := GetArea()
Local lRet 		:= .T.
Local cFilB    	:= Ctb240Fil(cAlias, cFilX)
Local cPlanoEnt := ""

Default cAlias   := "CV0"
Default cIdEntid := ""

If !Empty(c240EntDest)
	dbSelectArea("CT0")
	dbSetOrder(1)
	If dbSeek(xFilial("CT0")+cIdEntid)

		cPlanoEnt := CT0->CT0_ENTIDA
		
		dbSelectArea(cAlias)
		dbSetOrder(aIndexes[Val(CT0->CT0_ID)][1])
		If !("CV0" $ cAlias )
			dbSeek(cFilB+c240EntDest)
		Else
			dbSeek(cFilB+cPlanoEnt+c240EntDest)
		EndIf

		If Found() .And. !Eof()
			If cAlias$"CT1/CTT/CTD/CTH/CV0" .And. &(cAlias+"->"+cAlias+"_CLASSE") != '2' // Se nao for analitico
				lRet := .F.
				Help("  ", 1, "NOCLASSE")
			Endif
		Else
			lRet := .F.                 
			Help(" ",1,"NOENTCAD") //Entidade nao existe no cadastro.	
		Endif
    EndIf
Endif    

RestArea(aSaveArea)

Return(lRet)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb240LOK ³ Autor ³ Simone Mie Sato       ³ Data ³ 04/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da linha da Getdados                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Ctb240Lok()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CTBA240                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb240LOK()

Local aSaveArea		:= GetArea()
Local lRet			:= .T.
Local nPosEmpOri    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_EMPORI"})
Local nPosFilOri    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_FILORI"})
Local nPosCtaIni	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_CT1INI"})
Local nPosCtaFim	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_CT1FIM"})
Local nPosCCIni		:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_CTTINI"})
Local nPosCCFim		:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_CTTFIM"})
Local nPosItemIni	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_CTDINI"})
Local nPosItemFim	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_CTDFIM"})
Local nPosCLVLIni	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_CTHINI"})
Local nPosCLVLFim	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_CTHFIM"})
Local nPosIdent		:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_IDENT"})

Local nPosE05Ini    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_E05INI"})
Local nPosE05Fim    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_E05FIM"})
Local nPosE06Ini    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_E06INI"})
Local nPosE06Fim    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_E06FIM"})
Local nPosE07Ini    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_E07INI"})
Local nPosE07Fim    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_E07FIM"})
Local nPosE08Ini    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_E08INI"})
Local nPosE08Fim    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_E08FIM"})
Local nPosE09Ini    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_E09INI"})
Local nPosE09Fim    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_E09FIM"})

Local bPosE05Ini    := {|| If(nPosE05Ini==0, .T., Empty(aCols[n][nPosE05Ini]) ) }
Local bPosE05Fim    := {|| If(nPosE05Fim==0, .T., Empty(aCols[n][nPosE05Fim]) ) }
Local bPosE06Ini    := {|| If(nPosE06Ini==0, .T., Empty(aCols[n][nPosE06Ini]) ) }
Local bPosE06Fim    := {|| If(nPosE06Fim==0, .T., Empty(aCols[n][nPosE06Fim]) ) }
Local bPosE07Ini    := {|| If(nPosE07Ini==0, .T., Empty(aCols[n][nPosE07Ini]) ) }
Local bPosE07Fim    := {|| If(nPosE07Fim==0, .T., Empty(aCols[n][nPosE07Fim]) ) }
Local bPosE08Ini    := {|| If(nPosE08Ini==0, .T., Empty(aCols[n][nPosE08Ini]) ) }
Local bPosE08Fim    := {|| If(nPosE08Fim==0, .T., Empty(aCols[n][nPosE08Fim]) ) }
Local bPosE09Ini    := {|| If(nPosE09Ini==0, .T., Empty(aCols[n][nPosE09Ini]) ) }
Local bPosE09Fim    := {|| If(nPosE09Fim==0, .T., Empty(aCols[n][nPosE09Fim]) ) }

If !aCols[n][Len(aHeader)+1]
	If Empty(aCols[n][nPosCtaIni])   .And. Empty(aCols[n][nPosCCIni])   .And.;
		Empty(aCols[n][nPosItemIni]) .And. Empty(aCols[n][nPosCLVLIni]) .And.;
		Empty(aCols[n][nPosCtaFim])  .And. Empty(aCols[n][nPosCCFim])   .And.;
		Empty(aCols[n][nPosItemFim]) .And. Empty(aCols[n][nPosCLVLFim]) .And.;
		(aCols[n][nPosIdent] == "1"  .Or. aCols[n][nPosIdent] == "2") .And.;
		Eval(bPosE05Ini)  .And. Eval(bPosE06Ini) .And.;
		Eval(bPosE07Ini)  .And. Eval(bPosE08Ini)  .And.;		
		Eval(bPosE09Ini)  .And.;
	 	Eval(bPosE05Fim)   .And. Eval(bPosE06Fim)  .And.;
		Eval(bPosE07Fim)  .And. Eval(bPosE08Fim)  .And.;
		Eval(bPosE09Fim)
		Help(" ",1,"C240NOENTI")
		lRet := .F.
	EndIf	
		
	If lRet
		If (!Empty(aCols[n][nPosCtaIni]) .And. Empty(aCols[n][nPosCtaFim])) .Or. ;
			(Empty(aCols[n][nPosCtaIni]) .And. !Empty(aCols[n][nPosCtaFim]))
			Help(" ",1,"C240NOCTA")
			lRet := .F.
		EndIf
	EndIf
   	
	If lRet
		If (!Empty(aCols[n][nPosCCIni]) .And. Empty(aCols[n][nPosCCFim])) .Or.    ;
			(Empty(aCols[n][nPosCCIni]) .And. !Empty(aCols[n][nPosCCFim]))
			Help(" ",1,"C240NOCC")
			lRet := .F.
		EndIf
	EndIf
   	
	If lRet
		If (!Empty(aCols[n][nPosItemIni]) .And. Empty(aCols[n][nPosItemFim])) .Or. ;
			(Empty(aCols[n][nPosItemIni]) .And. !Empty(aCols[n][nPosItemFim]))
			Help(" ",1,"C240NOITEM")
			lRet := .F.
		EndIf
	EndIf
   	
	If lRet
		If (!Empty(aCols[n][nPosCLVLIni]) .And. Empty(aCols[n][nPosCLVLFim])) .Or.  ;
			(Empty(aCols[n][nPosCLVLIni]) .And. !Empty(aCols[n][nPosCLVLFim]))
			Help(" ",1,"C240NOCLVL")
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If (! Eval(bPosE05Ini) .And. Eval(bPosE05Fim)) .Or.  ;
			(Eval(bPosE05Ini) .And. !Eval(bPosE05Fim))
			Help(" ",1,"C240NOENT5",,STR0033,1,0) //"Entidade Origem Inicial e/ou Entidade Origem Final não preenchido(s)"
			lRet := .F.
		EndIf
	EndIf
	        		
	If lRet
		If (!Eval(bPosE06Ini) .And. Eval(bPosE06Fim)) .Or.  ;
			(Eval(bPosE06Ini) .And. !Eval(bPosE06Fim))
			Help(" ",1,"C240NOENT6",,STR0033,1,0) //"Entidade Origem Inicial e/ou Entidade Origem Final não preenchido(s)"
			lRet := .F.
		EndIf
	EndIf
	    
	If lRet
		If (!Eval(bPosE07Ini) .And. Eval(bPosE07Fim)) .Or.  ;
			(Eval(bPosE07Ini) .And. !Eval(bPosE07Fim))
			Help(" ",1,"C240NOENT7",,STR0033,1,0) //"Entidade Origem Inicial e/ou Entidade Origem Final não preenchido(s)"
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If (!Eval(bPosE08Ini) .And. Eval(bPosE08Fim)) .Or.  ;
			(Eval(bPosE08Ini) .And. !Eval(bPosE08Fim))
			Help(" ",1,"C240NOENT8",,STR0033,1,0) //"Entidade Origem Inicial e/ou Entidade Origem Final não preenchido(s)"
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If (!Eval(bPosE09Ini) .And. Eval(bPosE09Fim)) .Or.  ;
			(Eval(bPosE09Ini) .And. !Eval(bPosE09Fim))
			Help(" ",1,"C240NOENT9",,STR0033,1,0) //"Entidade Origem Inicial e/ou Entidade Origem Final não preenchido(s)"
			lRet := .F.
		EndIf
	EndIf

	If lRet
		If Empty(aCols[n][nPosIdent])
			Help(" ",1,"C240NOSIN")
			lRet := .F.
		EndIf
	EndIf
	
	// Valida se Conta Existe
	If !Empty(aCols[n][nPosCtaIni]) .And. !Empty(aCols[n][nPosCtaFim])
		IF fAbrEmpCTB("CT1",1,aCols[n][nPosEmpOri],aCols[n][nPosFilOri])
			If lRet                      
				lRet := Ctb240Cta(aCols[n][nPosCtaIni],"CTBCT1",aCols[n][nPosFilOri])
			EndIf	
			If lRet
				lRet := Ctb240Cta(aCols[n][nPosCtaFim],"CTBCT1",aCols[n][nPosFilOri])
			EndIf		                                      		
		Endif
	EndIf	

	// Valida se Centro de Custo Existe
	If !Empty(aCols[n][nPosCCIni]) .And. !Empty(aCols[n][nPosCCFim])
		IF fAbrEmpCTB("CTT",1,aCols[n][nPosEmpOri],aCols[n][nPosFilOri])
			If lRet
				lRet := Ctb240CC(aCols[n][nPosCCIni],"CTBCTT",aCols[n][nPosFilOri])
			EndIf	
			If lRet
				lRet := Ctb240CC(aCols[n][nPosCCFim],"CTBCTT",aCols[n][nPosFilOri])
			EndIf		
		EndIf		
	Endif
		
	// Valida se Item Contabil Existe
	If !Empty(aCols[n][nPosItemIni]) .And. !Empty(aCols[n][nPosItemFim])
		IF fAbrEmpCTB("CTD",1,aCols[n][nPosEmpOri],aCols[n][nPosFilOri])
			If lRet
				lRet := Ctb240Item(aCols[n][nPosItemIni],"CTBCTD",aCols[n][nPosFilOri])
			EndIf	
			If lRet
				lRet := Ctb240Item(aCols[n][nPosItemFim],"CTBCTD",aCols[n][nPosFilOri])
			EndIf		
		EndIf
	Endif
		
	// Valida se Classe de VALOR Existe
	If !Empty(aCols[n][nPosCLVLIni]) .And. !Empty(aCols[n][nPosCLVLFim])
		IF fAbrEmpCTB("CTH",1,aCols[n][nPosEmpOri],aCols[n][nPosFilOri])
			If lRet
				lRet := Ctb240CLVL(aCols[n][nPosCLVLIni],"CTBCTH",aCols[n][nPosFilOri])
			EndIf	
			If lRet
				lRet := Ctb240CLVL(aCols[n][nPosCLVLFim],"CTBCTH",aCols[n][nPosFilOri])
			EndIf		
		EndIf
	Endif
	
	//Entidade 05
	If _lCpoEnt05 .And. !Empty(aCols[n][nPosE05Ini]) .And. !Empty(aCols[n][nPosE05Fim])
		If fAbrEmpCTB(__cAlias05,1,aCols[n][nPosEmpOri],aCols[n][nPosFilOri])
			If lRet
				lRet := Ctb240Ent(aCols[n][nPosE05Ini],"CTB"+__cAlias05,aCols[n][nPosFilOri],"05")
			EndIf	
			If lRet
				lRet := Ctb240Ent(aCols[n][nPosE05Fim],"CTB"+__cAlias05,aCols[n][nPosFilOri],"05")
			EndIf		
		EndIf
	Endif
         
	//Entidade 06
	If _lCpoEnt06 .And. !Empty(aCols[n][nPosE06Ini]) .And. !Empty(aCols[n][nPosE06Fim])
		If fAbrEmpCTB(__cAlias06,1,aCols[n][nPosEmpOri],aCols[n][nPosFilOri])
			If lRet
				lRet := Ctb240Ent(aCols[n][nPosE06Ini],"CTB"+__cAlias06,aCols[n][nPosFilOri],"06")
			EndIf	
			If lRet
				lRet := Ctb240Ent(aCols[n][nPosE06Fim],"CTB"+__cAlias06,aCols[n][nPosFilOri],"06")
			EndIf		
		EndIf
	Endif
    
	//Entidade 07
	If _lCpoEnt07 .And. !Empty(aCols[n][nPosE07Ini]) .And. !Empty(aCols[n][nPosE07Fim])
		If fAbrEmpCTB(__cAlias07,1,aCols[n][nPosEmpOri],aCols[n][nPosFilOri])
			If lRet
				lRet := Ctb240Ent(aCols[n][nPosE07Ini],"CTB"+__cAlias07,aCols[n][nPosFilOri],"07")
			EndIf	
			If lRet
				lRet := Ctb240Ent(aCols[n][nPosE07Fim],"CTB"+__cAlias07,aCols[n][nPosFilOri],"07")
			EndIf		
		EndIf
	Endif

	//Entidade 08
	If _lCpoEnt08 .And.!Empty(aCols[n][nPosE08Ini]) .And. !Empty(aCols[n][nPosE08Fim])
		If fAbrEmpCTB(__cAlias08,1,aCols[n][nPosEmpOri],aCols[n][nPosFilOri])
			If lRet
				lRet := Ctb240Ent(aCols[n][nPosE08Ini],"CTB"+__cAlias08,aCols[n][nPosFilOri],"08")
			EndIf	
			If lRet
				lRet := Ctb240Ent(aCols[n][nPosE08Fim],"CTB"+__cAlias08,aCols[n][nPosFilOri],"08")
			EndIf		
		EndIf
	Endif
    
	//Entidade 09
	If _lCpoEnt09 .And. !Empty(aCols[n][nPosE09Ini]) .And. !Empty(aCols[n][nPosE09Fim])
		If fAbrEmpCTB(__cAlias09,1,aCols[n][nPosEmpOri],aCols[n][nPosFilOri])
			If lRet
				lRet := Ctb240Ent(aCols[n][nPosE09Ini],"CTB"+__cAlias09,aCols[n][nPosFilOri],"09")
			EndIf	
			If lRet
				lRet := Ctb240Ent(aCols[n][nPosE09Fim],"CTB"+__cAlias09,aCols[n][nPosFilOri],"09")
			EndIf		
		EndIf
	Endif

Endif

RestArea(aSaveArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb240TOK ³ Autor ³ Simone Mie Sato       ³ Data ³ 04/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao da Getdados - TudoOK                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb240TOk()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CTBA240                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb240TOK()

Local aSaveArea:= GetAREA()
Local lRet		:=	.T.
Local nCont

For nCont := 1 To Len(aCols)
	If !Ctb240LOK()
		lRet := .F.
		Exit
	EndIf
Next nCont

cEmpAnt	:= __cEmpAnt
cFilAnt	:= __cFilAnt

RestArea(aSaveArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb240BOK ³ Autor ³ Simone Mie Sato       ³ Data ³ 04/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao no Botao Ok.                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTB240BOK(c240CtDest,c240CCDest,c240ItDest,c240CvDest,      ³±±
±±³          ³c240E05Des,c240E06Des,c240E07Des,c240E08Des,c240E09Des)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CTBA240                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Conta Destino                                      ³±±
±±³          ³ ExpC2 = Centro de Custo Destino                            ³±±
±±³          ³ ExpC3 = Item  Destino                                      ³±±
±±³          ³ ExpC4 = Classe de Valor Destino                            ³±±
±±³          ³ ExpC5 = Entidade 05 Destino                                ³±±
±±³          ³ ExpC6 = Entidade 06 Destino                                ³±±
±±³          ³ ExpC7 = Entidade 07 Destino                                ³±±
±±³          ³ ExpC8 = Entidade 08 Destino                                ³±±
±±³          ³ ExpC9 = Entidade 09 Destino                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb240BOK(c240CtDest,c240CCDest,c240ItDest,c240CvDest,c240E05Des,c240E06Des,c240E07Des,c240E08Des,c240E09Des)

Local aSaveArea:= GetAREA()
Local lRet		:=	.T.

If Empty(c240CtDest) .And. Empty(c240CCDest) .And. Empty(c240ItDest) .And. Empty(c240CvDest) .And.;
   Empty(c240E05Des) .And. Empty(c240E06Des) .And. Empty(c240E07Des) .And. Empty(c240E08Des) .And. Empty(c240E09Des)
	Help("  ", 1, "CT240VAZ")
    lRet := .F.
Endif

RestArea(aSaveArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ct240Canc ³ Autor ³ Simone Mie Sato       ³ Data ³ 04/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Validacao no Botao Cancelar                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct240Canc(oDlg)                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CTBA240                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Expo1 = Objeto oDlg                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct240Canc(oDlg)

Local aSaveArea:= GetAREA()
Local lRet		:=	.T.

cEmpAnt	:= __cEmpAnt
cFilAnt	:= __cFilAnt

oDlg:End()

RestArea(aSaveArea)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb240Grv ³ Autor ³ Simone Mie Sato       ³ Data ³ 04/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Gravacao dos dados digitados                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ctb240Grv(nOpc,cEmpDes,cFildes,cCtb240Cod,cCtb240Ord,		  ³±±
±±³          ³c240CtDest,c240CCDest,c240ItDest,c240CvDest,cTpSlDes)       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ CTBA240                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Numero da opcao escolhida                          ³±±
±±³          ³ ExpC1 = Codigo da Empresa Destino                          ³±±
±±³          ³ ExpC2 = Codigo da Filial Destino                           ³±±
±±³          ³ ExpC3 = Codigo do Roteiro de Consolidacao                  ³±±
±±³          ³ ExpC4 = Ordem do Roteiro de Consolidacao                   ³±±
±±³          ³ ExpC5 = Conta Destino                                      ³±±
±±³          ³ ExpC6 = Centro de Custo Destino                            ³±±
±±³          ³ ExpC7 = Item Destino                                       ³±±
±±³          ³ ExpC8 = Classe de Valor Destino                            ³±±
±±³          ³ ExpC9 = Tipo de Saldo Destino                              ³±±
±±³          ³ ExpCA = Historico Aglutinado                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb240Grv(nOpc,cEmpDes,cFilDes,cCtb240Cod,cCtb240Ord,c240CtDest,c240CCDest,c240ItDest,c240CvDest,c240SlDest,c240HistAg,c240E05Des,c240E06Des,c240E07Des,c240E08Des,c240E09Des)

Local aSaveArea := GetArea()
Local cPos		:= ""
Local nCont
Local nCont1
Local nCont2
Local nPosLinha := ASCAN(aHeader,{|x| Alltrim(x[2]) == "CTB_LINHA"})
Local lHasAglut	:= .T.
Local nPosEmpOri := ASCAN(aHeader,{|x| Alltrim(x[2]) == "CTB_EMPORI"})
Local nPosFilOri := ASCAN(aHeader,{|x| Alltrim(x[2]) == "CTB_FILORI"})
Local nPosCT2FIL := ASCAN(aHeader,{|x| Alltrim(x[2]) == "CTB_CT2FIL"})
Local cEmpOri	:= ""
Local cFilOri	:= ""
Local cModoEmp	:= ""
Local cModoUn	:= ""
Local cModoFil	:= ""

cEmpAnt	:= __cEmpAnt
cFilAnt	:= __cFilAnt

For nCont1 := 1 To Len(aCols)

	//----------------------------------------------------------------------------
	// Grava a Filial da CT2 de Origem conforme seu compartilhamento.
	// O campo CTB_CT2FIL é usado ao processar a consolidação configurada, em que
	// o compartilhamento do Grupo de Empresa Origem é diferente do Destino
	//----------------------------------------------------------------------------
	If nOpc != 5 .And. !aCOLS[nCont1][Len(aHeader)+1] //Se nao for exclusao e a linha nao estiver deletada

		//-------------------------------------------------------------------------
		// Obtem a estrutura de compartilhamento da CT2 no Grupo de Empresa origem
		//-------------------------------------------------------------------------
		If cEmpOri != aCols[nCont1][nPosEmpOri]

			cEmpOri	:= aCols[nCont1][nPosEmpOri]

			cModoEmp	:= FWModeAccess("CT2",1,cEmpOri) //Empresa
			cModoUn		:= FWModeAccess("CT2",2,cEmpOri) //Unidade de Negocio
			cModoFil	:= FWModeAccess("CT2",3,cEmpOri) //Filial
		EndIf

		//-----------------------------------------------------------------------
		// Obtem a filial da empresa origem já tratada conforme compartilhamento
		//-----------------------------------------------------------------------
		If cFilOri != aCols[nCont1][nPosFilOri]
			cFilOri	:= FWXFilial("CT2",aCols[nCont1][nPosFilOri],cModoEmp,cModoUn,cModoFil)
		EndIf

		//-----------------------------
		// Atualiza o campo CTB_CT2FIL
		//-----------------------------
		aCols[nCont1][nPosCT2FIL] := cFilOri

	EndIf

	dbSelectArea("CTB")
	CTB->(dbSetOrder(1))
 	If CTB->(!dbSeek(xFilial("CTB")+cCtb240Cod+cCtb240Ord+aCols[nCont1][nPosLinha]))
		RecLock("CTB",.T.)
		CTB->CTB_LINHA  := aCols[nCont1][nPosLinha]
		CTB->CTB_FILIAL := xFilial("CTB")
		CTB->CTB_EMPDES := cEmpDes
		CTB->CTB_FILDES := cFilDes
		CTB->CTB_CODIGO := cCtb240Cod
		CTB->CTB_ORDEM  := cCtb240Ord
		CTB->CTB_CTADES := c240CtDest
		CTB->CTB_CCDES  := c240CCDest
		CTB->CTB_ITEMDE := c240ItDest
		CTB->CTB_CLVLDE := c240CvDest
		CTB->CTB_TPSLDE := c240SlDest
		If _lCpoEnt05
			CTB->CTB_E05DES := c240E05Des
		EndIf
		If _lCpoEnt06
			CTB->CTB_E06DES := c240E06Des		
        EndIf
		If _lCpoEnt07
			CTB->CTB_E07DES := c240E07Des
		EndIf
		If _lCpoEnt08
			CTB->CTB_E08DES := c240E08Des				
        EndIf
        If _lCpoEnt09
			CTB->CTB_E09DES := c240E09Des		
		EndIf
		If lHasAglut
			CTB->CTB_HAGLUT	:= c240HistAg
		EndIf
	Else
		If nOpc != 5					// Alteracao
			RecLock("CTB")
			CTB->CTB_CTADES := c240CtDest
			CTB->CTB_CCDES  := c240CCDest
			CTB->CTB_ITEMDE := c240ItDest
			CTB->CTB_CLVLDE := c240CvDest
			CTB->CTB_TPSLDE := c240SlDest  
            If _lCpoEnt05
            	CTB->CTB_E05DES := c240E05Des
            EndIf                             
            If _lCpoEnt06
            	CTB->CTB_E06DES := c240E06Des		
            EndIf
            If _lCpoEnt07
            	CTB->CTB_E07DES := c240E07Des
            EndIf
            If _lCpoEnt08
            	CTB->CTB_E08DES := c240E08Des				
            EndIf
            If _lCpoEnt09
            	CTB->CTB_E09DES := c240E09Des
			EndIf
			If lHasAglut
				CTB->CTB_HAGLUT	:= c240HistAg
			EndIf
		Else								// Exclusao
			RecLock("CTB",.F.,.T.)
			CTB->(dbDelete())
			CTB->(MsUnlock())
			Loop
		EndIf
	EndIf

		For nCont := 1 to Len(aHeader)
			cPos += StrZero(CTB->(FieldPos(aHeader[nCont,2])),2,0)
		Next
   	
		IF !aCOLS[nCont1][Len(aHeader)+1]

			//-----------------------
			// Grava os dados na CTB
			//-----------------------
			For nCont2 := 1 To Len(aHeader)
				If aHeader[nCont2][10] # "V" .And. !aHeader[nCont2][2] $ "CTB_ALI_WT|CTB_REC_WT"
					cVar := Trim(aHeader[nCont2][2])
					CTB->(FieldPut(Val(Subs(cPos,(nCont2*2-1),2)),aCOLS[nCont1][nCont2]))
				EndIf
			Next nCont2
			CTB->(MsUnlock())
			cVar := ""
		Else
			RecLock("CTB",.F.,.T.)
			CTB->(dbDelete())
			CTB->(MsUnlock())
		EndIf

Next nCont1

dbSelectArea("CTB")
CTB->(dbSetOrder(1))


RestArea(aSaveArea)

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ctb240TpSd³ Autor ³ Simone Mie Sato       ³ Data ³ 05/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Retorna Tipo de Saldo   -> do Combo Box                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb240TpSd(c240SlDest,aTpSld)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T.                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Valida‡„o do SX3 do Campo CTB_TPSLDE                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Tipo de Saldo Destino                              ³±±
±±³          ³ ExpA1 = Array contendo o tipo de saldo                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ctb240TpSd(c240SlDest,aTpSld)

c240SlDest := Str(Ascan(aTpSld,c240SlDest),1)

Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³Ct240Troca³ Autor ³ Simone Mie Sato       ³ Data ³ 05/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Troca marcador entre x e branco                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ct240Troca(nIt,aArray)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aArray                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Par„metros³ ExpN1 = Numero da posicao                                  ³±±
±±³          ³ ExpA1 = Array contendo as empresas a serem consolidadas    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct240Troca(nIt,aArray)
aArray[nIt,1] := !aArray[nIt,1]
Return aArray

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ CTB240EMP³ Autor ³ Simone Mie Sato       ³ Data ³ 04/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Abre tela p/ checagem da empresa/filial destino			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  CTB240EMP()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T. / .F.                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function  CTB240EMP()
Local cMensagem
Local cConsEmp  := Getmv("MV_CONSOLD")
Local lOk 		:= .T.
Local nTotEmp  	:= 0
Local cEmpAtu 	:= ""
Local aSM0 		:= AdmAbreSM0()

nTotEmp := Len(aSM0)
cEmpAtu := FWGRPCompany() + AllTrim( IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) )

IF nTotEmp < 2
	lOk := .F.
	Help(" ",1,"UNIFILIAL")
	Return(lOk)
Endif

If Empty(cConsEmp)
	lOk := .F.
	cMensagem := STR0015+chr(13)//"Favor preencher o parametro MV_CONSOLD que indica qual ou quais "
	cMensagem += STR0016+chr(13)//"as empresas/filiais destino. Ex: Supondo que as empresas/fiiais "
	cMensagem += STR0017+chr(13)//"02/01 e 03/01 sao consolidadoras preencher 0201/0301"
	IF IsBlind() .Or. !MsgYesNo(cMensagem,STR0021)	//"ATEN€ŽO"
		Return(lOk)
	Endif
Else
	If !(cEmpatu $ cConsEmp)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mostra tela de aviso que a empresa aberta nao corresponde a empresa destino ³
		//³ informada pelo usuario. Soh serah permitido cadastrar o roteiro de 	 		³
		//³ consolidacao  na empresa destino.											³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		lOk := .F.
		cMensagem := STR0018+chr(13)//"A Empresa/Filial aberta nao corresponde a Empresa/Filial Destino"
		cMensagem += STR0019+chr(13)//"informada nos parametro MV_CONSOLD. So sera permitido o cadastro"
		cMensagem += STR0020+chr(13)//"do Roteiro de Consolidacao na Empresa/Filial Destino."
		IF IsBlind() .Or. !MsgYesNo(cMensagem,STR0021)	//"ATEN€ŽO"
			Return(lOk)
		Endif
	Endif
Endif

Return(lOk) 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CT240GCAD ³ Autor ³ Simone Mie Sato       ³ Data ³ 05/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Abre tela p/ escolher arquivos e empresas a serem importadas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CT240GCAD()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function  CT240GCAD()
Local aEmp		:= {}		// Matriz com todas as empresas do Sistema
Local aQuais	:= {}		// Matriz com Arquivos a serem importados
Local aEmpresas := {}		// Matriz somente com as empresas a serem importadas
Local cTitImpCad:= STR0022	// Importacao dos Cadastros		
Local cEmpAnt	:= "  "                                                      
Local cVarQ 	:= "  "
Local cVarE 	:= "  "
Local cSayCusto := CtbSayApro("CTT")
Local cSayItem	:= CtbSayApro("CTD")
Local cSayClVL	:= CtbSayApro("CTH")
Local nCont
Local nOpca
Local oDlg
Local oEmp
Local oQual
Local oOk := LoadBitmap( GetResources(), "LBOK")
Local oNo := LoadBitmap( GetResources(), "LBNO")		
Local nCFil := 0
Local aSM0 := AdmAbreSM0()	
// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Matriz com arquivos a serem consolidados			 ³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aQuais := {	{.t.,STR0025},;   //"Plano de Contas"
			{.t.,cSayCusto},; //"Centros de Custos"
			{.t.,cSayItem},;  //"Item Contabil"
			{.t.,cSayCLVL}}  //"Classe de Valor"

For nCFil := 1 to Len(aSM0)
	If aSM0[nCFil][SM0_GRPEMP] == __cEmpAnt .And. aSM0[nCFil][SM0_CODFIL] == __cFilAnt  
		Loop
	Endif
	If cEmpAnt != aSM0[nCFil][SM0_GRPEMP]
		aAdd(aEmp, {.t.,aSM0[nCFil][SM0_GRPEMP], aSM0[nCFil][SM0_CODFIL] + " " + aSM0[nCFil][SM0_NOME] ,"- "+ aSM0[nCFil][SM0_NOMRED]})
		cEmpAnt := aSM0[nCFil][SM0_GRPEMP]
	Else
		// Isto garante que a empresa seja aberta somente uma vez!!
		aAdd(aEmp ,{.t., "  ",aSM0[nCFil][SM0_CODFIL] + " " + aSM0[nCFil][SM0_NOME],"- "+ aSM0[nCFil][SM0_NOMRED]})
		cEmpAnt := aSM0[nCFil][SM0_GRPEMP]
	End
Next nCFil

aEmp := Ct220Ajust(aEmp)

IF Len(aEmp) == 0
	Help(" ",1,"UNIFILIAL")
	DeleteObject(oOk)
	DeleteObject(oNo)
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros      	                 ³
//³ mv_par01     // Apaga Cadastros? Sim/Nao                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("CTB240",.f.)
nOpca := 0
DEFINE MSDIALOG oDlg TITLE cTitImpCad From 9,0 To 28,80 OF oMainWnd

	DEFINE FONT oFnt1	NAME "Arial" 			Size 10,12 BOLD  	
	@ 1.3,10 Say STR0022 FONT oFnt1 COLOR CLR_RED	  //"Importacao dos Cadastros"
	@ 2.5,.5 LISTBOX oQual VAR cVarQ Fields HEADER "",STR0023  ;
				SIZE 150,82 ON DBLCLICK ;
				(aQuais:=CT240Troca(oQual:nAt,aQuais),oQual:Refresh()) NOSCROLL	//"Arquivos a Consolidar"
	oQual:SetArray(aQuais)
	oQual:bLine := { || {if(aQuais[oQual:nAt,1],oOk,oNo),aQuais[oQual:nAt,2]}}
	@ 2.5,20 LISTBOX oEmp VAR cVarE Fields HEADER "","",STR0024 ;
				SIZE 150,82 ON DBLCLICK ;                  
				(aEmp:=CT240Troca(oEmp:nAt,aEmp),oEmp:Refresh())  						//"Empresas a Importar"
	oEmp:SetArray(aEmp)
	oEmp:bLine := { || {if(aEmp[oEmp:nAt,1],oOk,oNo),aEmp[oEmp:nAt,2],aEmp[oEmp:nAt,3]}}
	DEFINE SBUTTON FROM 130,233.8	TYPE 5 ACTION (Pergunte("CTB240",.t.)) ENABLE OF oDlg
	DEFINE SBUTTON FROM 130,260.9	TYPE 1 ACTION (nOpca := 1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 130,288	TYPE 2 ACTION oDlg:End() ENABLE OF oDlg
ACTIVATE MSDIALOG oDlg 

IF nOpca == 1
	For nCont := 1 To Len(aEmp)
		If aEmp[nCont][1]
			AADD(aEmpresas,{aEmp[nCont][2],Substr(aEmp[nCont][3],1,2)})
		EndIf	
	Next nCont	

	Processa({|lEnd| CT240ImpC(aEmpresas,aQuais)})	
	DeleteObject(oOk)
	DeleteObject(oNo)			
Endif
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CT240ImpC ³ Autor ³ Simone Mie Sato       ³ Data ³ 05/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Importacao dos cadastros de acordo c/a config. usuario.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CT240Impc()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpA1 = Array contendo as empresas                          ³±±
±±³          ³ExpA2 = Array contendo as empresas a serem consolidadas     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function  CT240ImpC(aEmpresas,aQuais)
Local cChave
Local nCont
Local lRet := .T.

If mv_par01 == 1
	If	!(	MA280FLock("CT1") .And.;
			MA280FLock("CTD") .And.;
			MA280FLock("CTH") .And.;
			MA280FLock("CTT"))
      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
      //³ Fecha todos os arquivos e reabre-os de forma compartilhada   ³
      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
      dbCloseAll()
      OpenFile(SubStr(cNumEmp,1,2))
      Return .T.
	Else
	  dbSelectArea("CT1")
	  RetIndex("CT1")
      Zap
	  dbSelectArea("CTD")
	  RetIndex("CTD")
   	  Zap
	  dbSelectArea("CTH")
	  RetIndex("CTH")
	  Zap
  	  dbSelectArea("CTT")
	  RetIndex("CTT")
	  Zap
	  DbCloseAll()
	 OpenFile(SubStr(cNumEmp,1,2))
	EndIf			
Endif

ProcRegua(Len(aEmpresas)*Len(aQuais))
	
For nCont := 1 To Len(aEmpresas)

	// Abre SX2 das Empresas Selecionadas - Se elemento em bco -> empresa ja foi aberta
	// anteriormente                         
	If !Empty(aEmpresas[nCont][1])
		Ct220Open(aEmpresas[nCont][1])
	EndIf	
	cFilX		:= aEmpresas[nCont][2] 	
	
	// Cadastro Plano de Contas
	If aQuais[1][1]     
		cChave	:= "Aglutina->CT1_CONTA"    
		If lRet
			lRet := Ct220Cad("CT1",1,cChave,cFilX)
		EndIf	
	EndIf	

	// Cadastro Centro de Custo
	If aQuais[2][1]     
		cChave	:= "Aglutina->CTT_CUSTO"
			If lRet
			lRet := Ct220Cad("CTT",1,cChave,cFilX)
		EndIf		    
	EndIf	
	
	// Cadastro Itens Contabeis
	If aQuais[3][1]     
		cChave	:= "Aglutina->CTD_ITEM"
		If lRet
			lRet := Ct220Cad("CTD",1,cChave,cFilX)
		EndIf	
	EndIf	

	// Cadastro Classe de Valor
	If aQuais[4][1]     
		cChave	:= "Aglutina->CTH_CLVL"
		If lRet
			lRet := Ct220Cad("CTH",1,cChave,cFilX)
		EndIf	
	EndIf	

	If !lRet
		Exit
	EndIf	

Next nCont

DbSelectArea("CT1")

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³TROCAF3   ³ Autor ³ Simone Mie Sato       ³ Data ³ 06/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Chamar a funcao para trocar de empresa e verificar se atual ³±±
±±³          ³iza saldo.-chamado do X3_WHEN                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³TROCAF3(cAlias)                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±± 
±±³Parametros³ cAlias - Alias do arquivo                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function TROCAF3(cAlias,cIdEntid,lEmp)
Local lRet := .F.     
Local nPosEmpOri    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_EMPORI"})
Local nPosFilOri    := Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_FILORI"})
Local nPosCT1Ini 	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_CT1INI"})
Local nPosCT1Fim 	:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_CT1FIM"})
Local cEmp := aCols[n][nPosEmpOri]
Local cFil := aCols[n][nPosFilOri]

Default cIdEntid 	:= ""
Default lEmp		:= .F.

If Empty(cEmp)
	cEmp := cEmpAnt
	cFil := cFilAnt
EndIf

cAlias := Alltrim(cAlias)

If !Empty(cEmp)
	If cEmp != __cEmpAnt .Or. cFil != cFilAnt
		If !fAbrEmpCTB(cAlias,1,cEmp,cFil)
			Return( .F. )
		EndIf
		If !cAlias$"CT1,CTT,CTD,CTH"
			If !fAbrEmpCTB("CT0",1,cEmp,cFil)
				Return( .F. )
			EndIf
		EndIf
	EndIf

	If cAlias <> "CT1"
		If CtbMovSaldo(If(cAlias$"CTT,CTD,CTH", cAlias, "CT0"),,cIdEntid,"CTBCT0")
			//Chamo a funcao para abrir o cadastro da empresa/filial destino.
			lRet := CT240F3CT(cAlias,cEmp,cFil)
			If !cAlias$"CT1,CTT,CTD,CTH"
				lRet := CT240F3CT("CT0",cEmp,cFil)
			EndIf
		Endif
	Else    
		If lEmp
			aCols[n][nPosCT1Ini] := Space(Len(CT1->CT1_CONTA))
			aCols[n][nPosCT1Fim] := Space(Len(CT1->CT1_CONTA))
			lEmp := .F.
		EndIf

		lRet :=CT240F3CT(cAlias,cEmp,cFil)
	Endif

Else
	Help("  ", 1, "VAZEMPOR")
	lRet := .F.
Endif

//cAlias := cAliasAnt
Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CT240F3CT ³ Autor ³ Simone Mie Sato       ³ Data ³ 06/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Abrir CT  para Consulta via F3.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CT240F3CT()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cEmp - Empresa de Destino                                  ³±±
±±³          ³ cFil - Filial  de Destino                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function CT240F3CT(cAlias,cEmp,cFil)
Local cModo := IIF(Empty(xFilial(cAlias)),"C","E") 
Local nAT          

OpenCTBFil(cAlias,cAlias,1,.t.,cEmp,@cModo)	
cEmpAnt := cEmp
cFilAnt := cFil   
nAT := AT(cAlias,cArqTab)

IF nAT > 0
	cArqTab := Subs(cArqTab,1,nAT+2)+cModo+Subs(cArqTab,nAT+4)
Else
	cArqTaB += cAlias+cModo+"/"
EndIF


Return( .T. )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³OPENCTBFIL³ Autor ³ Simone Mie Sato       ³ Data ³ 06/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Abre Arquivo de Outra Empresa.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³OPENCTBFIL()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³xRet                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³x1 - Alias com o Qual o Arquivo Sera Aberto                 ³±±
±±³          ³x2 - Alias do Arquivo Para Pesquisa e Comparacao            ³±±
±±³          ³x3 - Ordem do Arquivo a Ser Aberto                          ³±± 
±±³          ³x4 - .T. Abre e .F. Fecha                                   ³±± 
±±³          ³x5 - Empresa                                                ³±± 
±±³          ³x6 - Modo de Acesso (Passar por Referencia)                 ³±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function OpenCtbFil(x1,x2,x3,x4,x5,x6)
Local cSavE := cEmpAnt, cSavF := cFilAnt, xRet
cEmpAnt := __cEmpAnt
cFilAnt := __cFilAnt

If Select("__SX2") > 0
	__SX2->(DbCloseArea())
Endif

xRet	:= EmpOpenFile(@x1,@x2,@x3,@x4,@x5,@x6)
cEmpAnt := cSavE
cFilAnt := cSavF

Return( xRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FABREMPCTB³ Autor ³ Simone Mie Sato       ³ Data ³ 06/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Abre Arquivo de Outra Empresa.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FABREMPCTB()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T./.F.                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias - Alias do Arquivo a ser aberto                      ³±±
±±³          ³nOrdem - Ordem do Indice                                    ³±±
±±³          ³cEmp   - Codigo da Empresa                                  ³±±
±±³          ³cFil   - Codigo da Filial                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fAbrEmpCTB(cAlias,nOrdem,cEmp,cfil,lRestaura)
Local cModo := IIF(Empty(xFilial(cAlias)),"C","E") 
Local lRet  := .T.
Local cAuxAlias := ""
Default lRestaura := .F.        

cAuxAlias := IIF(!lRestaura,"CTB","")+cAlias

IF ( lRet := OpenCTBFil(cAuxAlias,cAlias,nOrdem,.t.,cEmp,@cModo) )
	cEmpAnt := cEmp
	cFilAnt := cFil   
	__cFil := IIF( cModo == "E", cFil , Space(IIf( lFWCodFil, FWGETTAMFILIAL, 2 )) )
	dbSelectArea(cAuxAlias)
Else
	MsgAlert( STR0026 + cAlias ) //"Não foi possivel abrir o arquivo da Empresa Destino: "
EndIF	

Return( lRet )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FFECEMPCTB³ Autor ³ Simone Mie Sato       ³ Data ³ 06/07/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Fecha Arquivo de Outra Empresa.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³FFECEMCTB(cAlias)                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias - Alias do Arquivo a ser fechado                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function fFecEmpCTB(cAlias)

IF Select("CTB"+cAlias) > 0
	("CTB"+cAlias)->(dbCloseArea())
EndIF

Return( .T. )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ct240Emp  ³ Autor ³ Simone Mie Sato       ³ Data ³ 20/11/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Valida se o cod. empresa origem eh igual a empresa destino  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct240Emp(cEmpOrig,cFilOrig)                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cEmpOrig - Codigo da Empresa Origem                         ³±±
±±³          ³cFilOrig - Codigo da Filial  Origem                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Ct240Emp(cEmpOrig,cFilOrig,cIdent)

Local cRetorno	:= ""

If (cEmpOrig == __cEmpAnt .And. cFilOrig == __cFilAnt)
	MsgAlert(STR0028)	 //"Nao eh permitido preencher com o codigo da empresa destino na empresa origem.."
Else                 
	If cIdent == "E"
		cRetorno	:= FWGRPCompany()
	ElseIf cIdent == "F"
		cRetorno	:= IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	EndIf
EndIf     

Return(cRetorno)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Ctb240Fil ³ Autor ³ Wagner Mobile Costa   ³ Data ³ 10/04/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna o modo de compartilhamento do alias da empresa atual³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct240Fil(cAlias, cFilX)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.                                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAliasSX2 - Alias para verificacao do modo SX2              ³±±
±±³          ³cFilX     - Codigo da Empresa Origem                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function Ctb240Fil(cAliasSX2, cFilX)
Local aAreaSM0 := SM0->(GetArea())
Local cFilRet  := ""

cAliasSx2 := Right(cAliasSx2, 3)
SM0->(dbSeek(cEmpAnt))
cFilRet := xFilial(cAliasSx2,cFilX) 

RestArea(aAreaSM0)
Return cFilRet 
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³01/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados         ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()       
Local nX		:= 0
Local aCT240BUT := {}
Local aRotina   :=	{ 	{ STR0001,"AxPesqui", 0 , 1,,.F.},; //"Pesquisar"
						{ STR0003,"Ctb240Cad", 0 , 2},;     //"Visualizar"						
						{ STR0004,"Ctb240Cad", 0 , 3},;     //"Incluir"
						{ STR0005,"Ctb240Cad", 0 , 4},;     //"Alterar"
						{ STR0006,"Ctb240Cad", 0 , 5},;     //"Excluir"
						{ STR0002,"Ct240GCad", 0 , 3}}	     //"Gerar Cadastros"}  
						
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ P.E. Utilizado para adicionar botoes ao Menu Principal       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "CT240BUT" )
	aCT240BUT := ExecBlock( "CT240BUT", .F., .F., aRotina )
	IF ValType( aCT240BUT ) == "A" .AND. Len( aCT240BUT ) > 0
		For nX := 1 To Len( aCT240BUT )
			aAdd( aRotina, aCT240BUT[ nX ] )
		Next
	ENDIF
Endif						

Return(aRotina)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MontaaCols³ Autor ³ ToTvs				     ³ Data ³01/12/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta aCols				                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³							                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³								                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MontaaCols(nOpc)
Local nPosRec  := 0
Local nPosAli  := 0
Local nUsado   := 0
Local nCont	   := 0

If nOpc == 3
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("CTB") 
	Aadd(aCols,Array(Len(aHeader)+1))
	nUsado:=0
	While !EOF() .And. (x3_arquivo == "CTB")
		IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
			nUsado++
	   	
				IF x3_tipo == "C"
					aCOLS[1][nUsado] := SPACE(x3_tamanho)
				ELSEIF x3_tipo == "N"
					aCOLS[1][nUsado] := 0
				ELSEIF x3_tipo == "D"
					aCOLS[1][nUsado] := dDataBase
				ELSEIF x3_tipo == "M"
					aCOLS[1][nUsado] := ""
		 		ELSE
		  			aCOLS[1][nUsado] := .F.
				ENDIF
				If x3_context == "V"
			 		aCols[1][nUsado] := CriaVar(allTrim(x3_campo))
			 	Endif
		     EndIf
		
	        
		dbSkip()
	EndDo    

	nPosRec:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_REC_WT"})
	nPosAli:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_ALI_WT"})

	If nPosRec > 0
		aCOLS[1][nPosRec]:= 0
	EndIf
	If nPosAli > 0 	
		aCOLS[1][nPosAli]:= "CTB"
	EndIf
	nUsado:= nUsado+2		
	aCOLS[1][nUsado+1] := .F.
	aCols[1][1]			 := "001"
Else				// Alteracao / Exclusao / Visualizacao
	dbSelectArea("CTB")
	dbSetOrder(1)
	cCtb240Cod      	:= CTB->CTB_CODIGO
	cCtb240Ord     		:= CTB->CTB_ORDEM

	// Posiciona no primeiro registro
	dbSeek(xFilial("CTB")+cCtb240Cod+cCtb240Ord)
	While !EOF() .And. CTB->CTB_FILIAL == xFilial("CTB") .And.;
		CTB->CTB_CODIGO == cCtb240Cod .And. CTB->CTB_ORDEM == cCtb240Ord 
			nCont++
			Aadd(aCols,Array(Len(aHeader)+1))
			nUsado:=0
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbseek("CTB")
			While !EOF() .And. x3_arquivo == "CTB"
				IF X3USO(x3_usado) .AND. cNivel >= x3_nivel
					nUsado++
					If SX3->X3_CONTEXT != "V"
						aCOLS[nCont][nUsado] := &("CTB->"+x3_campo)
					ElseIf SX3->X3_context == "V"
						aCols[nCont][nUsado] := CriaVar(AllTrim(x3_campo))
					EndIf
				EndIf
				dbSkip()
			EndDo           

			nPosRec:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_REC_WT"})
			nPosAli:= Ascan(aHeader,{|x|Alltrim(x[2]) == "CTB_ALI_WT"})
		
			If nPosRec > 0
				aCOLS[1][nPosRec]:= CTB->(Recno())
			EndIf
			If nPosAli > 0 	
				aCOLS[1][nPosAli]:= "CTB"
			EndIf
			nUsado:= nUsado+2		
			aCOLS[nCont][nUsado+1]:= .F.
			dbSelectArea("CTB")
			dbSkip()
	EndDo
EndIf
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTBA240   ºAutor  ³Acacio Egas         º Data ³  04/14/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Preenche a ordem.                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ctb240Ord(cCtb_Cod,cCtb_Ord,nOpc,oOrdem)

Local lRet	:= .T., aArea, cAlias := Alias()
Local cFilCTB := xFilial("CTB")

If nOpc == 3                     
	dbSelectArea("CTB")
	aArea := GetArea()
	dbSetOrder(1)
	
	//**************************
	// valida a Ordem digitada *
	//**************************	
	If !Empty(cCtb_Ord) .and. !MsSeek(cFilCTB+cCTB_Cod+cCtb_Ord)
		cCtb_Ord	:= 	StrZero(Val(cCTB_Ord),Len(CTB->CTB_ORDEM))
	//********************************
	// localiza a sequencia da ordem *
	//********************************
	ElseIf MsSeek(cFilCTB+cCTB_Cod, .F.)
		While CTB->(!Eof()) .and. CTB->CTB_FILIAL == cFilCTB .and. CTB->CTB_CODIGO == cCTB_Cod
			CTB->(dbSkip())                                 
			If CTB->CTB_FILIAL <> cFilCTB .or. CTB->CTB_CODIGO <> cCTB_Cod
				dbSkip(-1)
				cCTB_Ord := StrZero(Val(CTB->CTB_ORDEM) + 1,Len(cCTB_Ord))
				dbSkip()
			EndIf
		EndDo
	//*******************************
	// Cria a primeira ordem quando *
	//*******************************
	Else                                                       
		cCTB_Ord := StrZero(1,Len(cCTB_Ord))
	Endif

	RestArea(aArea)
	DbSelectArea(cAlias)
	oOrdem:Refresh()
EndIf	

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³Ctb240Form³ Autor ³ Marcelo Akama         ³ Data ³ 21/05/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se a formula digitada esta OK                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctb240Form() / BASEADA NA CTB277FORM()                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ CTBA240 / VALIDACAO DO CADASTRO DE ROTEIRO DE CONSOLIDACAO ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Tipo do retorno desejado                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Ctb240Form(cTipoRet,cForm)

LOCAL lRet 		:= .T.
LOCAL xResult
LOCAL bBlock

DEFAULT cTipoRet := ""
DEFAULT cForm	 :=&(ReadVar())

lRet := Ctb080Form()

If lRet

	bBlock := ErrorBlock( { |e| ChecErro(e) } )
	BEGIN SEQUENCE
		xResult := &cForm
	RECOVER
		lRet := .F.
	END SEQUENCE
	ErrorBlock(bBlock)

	IF lRet .And. Valtype(xResult) <> cTipoRet
		HELP("CTBA240",1,"HELP","TIPO_INCORRETO",STR0030+CRLF+STR0031+"("+Valtype(xResult)+")"+CRLF+STR0032+"("+cTipoRet+")"+CRLF,1,0)
		    //"Retorno da fórmula incoerente."#"Retorno da fórmula: "#"Retorno válido: "
		 lRet := .F.
	ENDIF
Endif

RETURN lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb240PEmpºAutor  ³Microsiga           º Data ³  09/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Posicionar na SM0 se digitado a empresa de origem sem a     º±±
±±º          ³utilizacao da consulta padrao (F3)                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Ctb240PEmp()
Local lRet := .T. 
Local aAreaSM0 := SM0->(GetArea())
Local lTeclouF3 := .F.
Local aRetProc := Ctb240Proc()
Local nX

For nX := 1 TO Len(aRetProc)
	If AT("CONPAD1",UPPER(aRetProc[nX]) ) > 0
		lTeclouF3 := .T.
	EndIf
Next

If ! lTeclouF3 //se foi digitado empresa de origem e nao pressionado F3
	dbSelectArea("SM0")
	dbSetOrder(1)
	lRet := dbSeek(M->CTB_EMPORI)
    If ! lRet
    	RestArea(aAreaSM0)
    EndIf
EndIf

If Alltrim(SM0->M0_CODIGO) == Alltrim(__cEmpAnt) .And. Alltrim(SM0->M0_CODFIL) == Alltrim(__cFilAnt)
	MsgAlert(STR0034)	 //"Favor preencher com uma empresa\filial valida diferente da empresa\filial de Origem"
	lRet := .F.

EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb240PEmpºAutor  ³Microsiga           º Data ³  09/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Coloca em array a pilha de chamada da funcao chamadora atualº±±
±±º          ³no momento da validacao do get da empresa de origem         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Ctb240Proc()
Local aRetProc := {}
Local cProc := Alltrim( FunName() )
Local cExec := ""
Local nX := 0

While .T.
	
	cExec := Alltrim( ProcName(nX) )
	aAdd(aRetProc, cExec)
	nX++
	
	If cExec == cProc
		Exit
	EndIf

EndDo 
Return(aRetProc)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ctb240IniVar ºAutor  ³Microsiga        º Data ³  06/05/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Analise da existência dos campos das novas entidades       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Ctb240IniVar()

dbSelectArea("CTB")

If _lCpoEnt05 == Nil
	_lCpoEnt05 := CTB->(FieldPos("CTB_E05INI")>0 .And. FieldPos("CTB_E05FIM")>0)
EndIf
     
If _lCpoEnt06 == Nil
	_lCpoEnt06 := CTB->(FieldPos("CTB_E06INI")>0 .And. FieldPos("CTB_E06FIM")>0)
EndIf

If _lCpoEnt07 == Nil
	_lCpoEnt07 := CTB->(FieldPos("CTB_E07INI")>0 .And. FieldPos("CTB_E07FIM")>0)
EndIf

If _lCpoEnt08 == Nil
	_lCpoEnt08 := CTB->(FieldPos("CTB_E08INI")>0 .And. FieldPos("CTB_E08FIM")>0)
EndIf

If _lCpoEnt09 == Nil
	_lCpoEnt09 := CTB->(FieldPos("CTB_E09INI")>0 .And. FieldPos("CTB_E09FIM")>0)
EndIf

dbSelectArea("CT0")
dbSetOrder(1)
dbSeek(xFilial("CT0"))

Do While !CT0->(Eof()) .And. CT0->CT0_FILIAL==xFilial("CT0")
	If CT0->CT0_ID=="05" .And. _lCpoEnt05
		__cAlias05 := CT0->CT0_ALIAS
		__cF3Ent05 := CT0->CT0_F3ENTI
	EndIf
     
	If CT0->CT0_ID=="06" .And. _lCpoEnt06
		__cAlias06 := CT0->CT0_ALIAS
		__cF3Ent06 := CT0->CT0_F3ENTI
	EndIf

	If CT0->CT0_ID=="07" .And. _lCpoEnt07
		__cAlias07 := CT0->CT0_ALIAS
		__cF3Ent07 := CT0->CT0_F3ENTI
	EndIf

	If CT0->CT0_ID=="08" .And. _lCpoEnt08
		__cAlias08 := CT0->CT0_ALIAS
		__cF3Ent08 := CT0->CT0_F3ENTI
	EndIf

	If CT0->CT0_ID=="09" .And. _lCpoEnt09
		__cAlias09 := CT0->CT0_ALIAS
		__cF3Ent09 := CT0->CT0_F3ENTI
	EndIf

	CT0->(dbSkip())
EndDo

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CT240ResEmpºAutor  ³Alvaro Camillo Neto º Data ³  04/13/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Restaura as tabelas                                         º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function CT240ResEmp(aAlias)
Local nX := 0

For nX := 1 to Len(aAlias)
	fAbrEmpCTB(aAlias[nX],1,cEmpAnt,cFilAnt,.T.)
Next nX
	
Return
