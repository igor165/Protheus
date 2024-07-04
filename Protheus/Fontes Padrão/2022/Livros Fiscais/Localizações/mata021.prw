#INCLUDE "MATA021.ch"
#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ MATA021  ³ Autor ³                      ³ Data ³09/07/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Función para crear Condominios a partir de Proveedores    ³±±
±±³           ³                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ MATA021()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³29/06/17³MMI-6110  ³Replica de 12.1.16 Existan proveedores³±±
±±³            ³        ³          ³cuando Sit. Persona = Persona Jurídica³±±
±±³            ³        ³          ³(A2_CONDO == '1') en func VldExReg    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MATA021 
Local aCombo := {}
Local oDlg   := Nil
Local oCombo
Private cCombo := ""

aAdd( aCombo, STR0034 ) // "Proveedores"
aAdd( aCombo, STR0006 ) // "Clientes"


DEFINE MSDIALOG oDlg TITLE STR0025 FROM 0,0 TO 150,450 OF oDlg PIXEL //STR0025 "Condominios"
	 
	@ 006,010 TO 60,170 LABEL STR0036 OF oDlg PIXEL //"Selecciona la opción: "  
	@ 020,015 COMBOBOX oCombo VAR cCombo ITEMS aCombo SIZE 65,8 PIXEL OF oDlg 
	
	//| Boton de MSDialog
	//+-------------------
	@ 015,178 BUTTON STR0008 SIZE 036,016 PIXEL ACTION Iif(Substr(cCombo,1,1)=="P",IIf(MATA021P(),oDlg:End(),oDlg:End()),IIf(MATA021C(),oDlg:End(),oDlg:End())) //"Confirmar"
	@ 035,178 BUTTON STR0007 SIZE 036,016 PIXEL ACTION oDlg:End() //"Salir"
	

ACTIVATE MSDIALOG oDlg CENTER
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ MATA021P  ³ Autor ³                     ³ Data ³09/07/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Función para crear Condominios a partir de Proveedores    ³±±
±±³           ³                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ MATA021()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Alf. Medrano³29/06/17³MMI-6110  ³Replica de 12.1.16 Existan proveedores³±±
±±³            ³        ³          ³cuando Sit. Persona = Persona Jurídica³±±
±±³            ³        ³          ³(A2_CONDO == '1') en func VldExReg    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
Function MATA021P

Local aIndexSA1  := {}
Local cFiltraSA1 := ""
Local cFiltra	  := ""	//Variavel para filtro
PRIVATE aRotina := { 	{STR0001,"PesqBrw"    , 0 , 1},;     // "Pesquisar"
    							{STR0002,"MT021Cond" , 0 , 2},;    // "Visualizar"
			   				{STR0014,"Mt021Cond" , 0 , 3}}   //"Mant. Condominos" //"Mant.Condominos"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0034  //"Proveedores" 
PRIVATE aMemos    := {}
PRIVATE nOpc
PRIVATE xRotAuto
Private aRecSA2 := {}
Private bFiltraBrw 	:= {|| Nil}	//Variavel para Filtro
Private aIndexSA2	:= {}			//Variavel Para Filtro

nOpc := if (nOpc == Nil, 3, nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis para rotina de inclusao automatica    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private l030Auto := ( xRotAuto <> NIL )  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SA2")
dbSetOrder(1)

If SA2->(FieldPos("A2_CODCOND")*FieldPos("A2_CONDO")*FieldPos("A2_PERCCON")) == 0 
	MsgAlert(STR0024,STR0025)   // "Existe Inconsistencia no tratamento de Personas Plurais. Favor verificar os procedimentos de implantacao no boletim de Personas Plurais disponivel no FTP" ## "Condominios"
	Return(.F.)
EndIf		


cFiltra 	  := "A2_FILIAL=='"+xFilial('SA2')+"' .And. A2_CONDO == '1'"
bFiltraBrw 	:= {|| FilBrowse("SA2",@aIndexSA2,@cFiltra) }
Eval(bFiltraBrw)

dbSelectArea("SA2")
dbGotop()

mBrowse( 6, 1,22,75,"SA2")


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("SA2",aIndexSA2)

dbSelectArea("SA2")
dbSetOrder(1)

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinaCondVis³ Autor ³ Rafael Rizzatto       ³ Data ³09/07/04  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Programa de atualizacao de Condominios                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ FinaCondVis(ExpC1,ExpN1,ExpN2)                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Alias do arquivo                                    ³±±
±±³          ³ ExpN1 = Numero do registro                                  ³±±
±±³          ³ ExpN2 = Opcao selecionada                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
FUNCTION MT021Vis(cAlias,nReg,nOpc)

Local aUsrBut   := {} 
Local aButtons  := {{"POSCLI",{|| a450F4Con()},STR0012 }}

nOpcA:=AxVisual( cAlias, nReg, nOpc,,,,,aButtons)

dbSelectArea(cAlias)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FinCondomi    ³ Autor ³  Rafael Rizzatto      ³ Data ³ 09/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao das informacoes cadastrais do Condomino             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mt021Cond(cAlias,nReg,nOpcx)
Local ni,nX, oDlg
Local aG1	 := {"A2_COD","A2_LOJA","A2_NOME","A2_NREDUZ","A2_PERCCON","A2_EST","A2_CGC","A2_END","A2_BAIRRO","A2_MUN","A2_EST","A2_CEP","A2_TIPO"}
Local aSavSA2 := SA2->(GetArea())
Local aObjects := {} 
Local aPosObj  := {} 
Local aSizeAut := {} 
Local lDel		:=	(nOpcx<>2)
Private aRotina := { {""  	,""		, 0 , 1},;
                      {STR0010	,""	, 0 , 2},; // //"Vizualizar"
                      {STR0011  	,""	, 0 , 3}} // //"Alterar"
                      
Private nOpcao			:= If(nOpcx#2,3,nOpcx)
Private oGet01			:= NIL
Private aCols        := {}
Private aHeader      := {}
Private aSvAtela		:= {{},{},{}}
Private aTela			:= {}
Private aGets			:= {}
Private oEnc01			:= NIL
Private lOk				:= .F.
Private nColsOri		:=	0
Private lAutomato := isBlind()

If !VldExReg()
	Return
EndIf
aSizeAut := MsAdvSize()
aObjects := {} 
//AAdd( aObjects, { 68, 312, .T., .t. } )
//AAdd( aObjects, { 105,309, .t., .t. } )

AAdd( aObjects, {  68,130, .T., .T. } )
AAdd( aObjects, { 105,510, .T., .T. } )

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 

aPosObj := MsObjSize( aInfo, aObjects,.T. ) 

   dbSelectArea("SA2")
   DbSetOrder(1)
  
   If !lAutomato
   	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
   Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enchoice 							            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	dbSelectArea("SA2")                 

	aGets := {}                                            
	aTela := {}

 	RegToMemory("SA2",.F.,.F.)
 	If !lAutomato
		oEnc01:= MsMGet():New("SA2" ,nReg ,2 ,,,,,aPosObj[1],,,,,,oDlg,,.T.,.F.,"aSvATela[1]",.T.)
		oEnc01:Refresh()
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ getDados 			                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader 	:= aClone(CriaHeader('SA2',aG1))
	If !lAutomato
		aCols		:= CriaCols('SA2',1,nOpcao,IndexOrd(),"A2_FILIAL+A2_CODCOND",xFilial("SA2")+SA2->A2_CODCOND,aG1,"A2_CONDO == '2'",@nColsOri)
	Else
		If FindFunction("GetParAuto")
			aRetAuto 	:= GetParAuto("MATA021TESTCASE")
			aCols 		:= aRetAuto[1]
		Endif
	EndIf
	n        := 1
	For nX:= 1 To Len(aHeader)		
		aHeader[nX][2] := "_"+aHeader[nX][2]
	Next   
	If !lAutomato 
		oGet01 	:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcao,"Mt021LinOk()","Mt021Tudok()";
		,,lDel,,,,,"Mt021FieldOk()",,,'(n>nColsOri)',oDlg)				
		 		
		oGet01:oBrowse:Default()	
		oGet01:oBrowse:Refresh()
	                     
		ACTIVATE DIALOG oDlg ON ;
		INIT ( EnchoiceBar(oDlg, {|| lOk:=.T.,If(oGet01:TudoOk(),(If(Str(nOpcao,1) $ "345",Mt021Grv(),.t.),oDlg:End()),.F.)  },{|| lOk := .F.,oDlg:End()} ))
	Else
		lOk:=.T.
		Mt021LinOk()	
		Mt021Grv()
	EndIf
	RestArea(aSavSA2)
  
Return
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CondoGrava ³Autor ³ Rafael Rizzatto       ³ Data ³ 09/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de gravacao dos dados.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Mt021Grv()
Local nI := 0,nJ               
Local nPosCli	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_A2_COD"})
Local nPosLoja	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_A2_LOJA"})
Local cFilter
Local aArea	:=	SA2->(GetArea())
DbSelectArea("SA2")
DbSetOrder(1)
#IFDEF TOP 
	cFilter	:=	DbFilter()
	Set Filter To
#ENDIF	          
Begin Transaction
For nI := 1 To Len(aCols)
 	If	!aCols[nI][Len(aCols[nI])] 
	 	If !DbSeek(xFilial()+aCols[nI][nPosCli]+aCols[nI][nPosLoja])
		 	RecLock("SA2",.T.)
			A2_FILIAL   := xFilial("SA2")
			A2_CODCOND  := M->A2_CODCOND
			A2_NREDUZ   := M->A2_NREDUZ
			A2_NOME     := M->A2_NOME  
			A2_BAIRRO   := M->A2_BAIRRO
			A2_MUN      := M->A2_MUN
			A2_END      := M->A2_END
			A2_EST      := M->A2_EST
			A2_TIPO     := M->A2_TIPO
			A2_AGENRET  := M->A2_AGENRET
			A2_PORIVA   := M->A2_PORIVA
			A2_PORGAN   := M->A2_PORGAN
			A2_PERCIVA  := M->A2_PERCIVA
			A2_INSCGAN  := M->A2_INSCGAN
			A2_PERCIB   := M->A2_PERCIB
			A2_AGREGAN  := M->A2_AGREGAN
			A2_RETIB    := M->A2_RETIB
			A2_CONDO    := "2"
			MsUnLock()
		Endif	
	 	RecLock("SA2",.F.)
		For nJ := 1 To Len(aHeader)  //laco dos campos (colunas)
			If !Empty(aCols[nI,nJ]) .Or. SubStr(aHeader[nJ,2],2) == "A2_PERCCON" 
				Replace &(SubStr(aHeader[nJ,2],2)) With aCols[nI,nJ]
			Endif
		Next         
		//Para los proveedores que ya existen
		If  SA2->A2_CONDO != "2" //Significa que ya se habia dado de alta como parte del condominio
			SA2->A2_CONDO	:= "2"   //Proveedor existente se va a convertir en Participante del Condominio        
			SA2->A2_CODCOND	:= M->A2_CODCOND
			If  VldProvSA2()
				SA2->A2_TIPO  	:= M->A2_TIPO
				SA2->A2_AGENRET := M->A2_AGENRET
				SA2->A2_PORIVA  := M->A2_PORIVA
				SA2->A2_PORGAN  := M->A2_PORGAN
				SA2->A2_PERCIVA := M->A2_PERCIVA
				SA2->A2_INSCGAN := M->A2_INSCGAN
				SA2->A2_PERCIB  := M->A2_PERCIB
				SA2->A2_AGREGAN := M->A2_AGREGAN
				SA2->A2_RETIB   := M->A2_RETIB 
			Endif
		Endif
  		MsUnlock()         
 		
	Endif
Next                             
End Transaction      
#IFDEF TOP            
	DbSelectArea("SA2")
	DbSetOrder(aArea[2])	
	If !lAutomato				
		Eval(bFiltraBrw)
	EndIf
#ELSE
	RestArea(aArea)
#ENDIF

Return .T.
      
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriaHeader ³Autor ³ Rafael Rizzatto       ³ Data ³ 09/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de criacao do aHeader.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CriaHeader(cAlias,aCampos)
Local aTmpheader := {}
dbSelectArea("SX3")
dbSetOrder(1)
dbSeek(cAlias)
nUsado := 0
While !EOF() .And. (x3_arquivo == cAlias)
	IF X3USO(x3_usado) .AND. cNivel >= x3_nivel .And. !Empty( AScan( aCampos, { |x| x == AllTrim(SX3->X3_CAMPO) } ) )
		nUsado++
		cValid	:=	X3_VALID
		If  cAlias == "SA2" .And. Alltrim(X3_CAMPO) == "A2_COD" .Or. Alltrim(X3_CAMPO) == "A2_LOJA"
			cValid	:=	"Mt021VldCod()"
		Elseif cAlias== "AI0" .And. (Alltrim(X3_CAMPO) == "AI0_CODCLI" .Or. Alltrim(X3_CAMPO) == "AI0_LOJA")
			cValid	:=	"Mt021CVldC()"
		Endif
		AADD(aTmpHeader,{ TRIM(x3titulo()), x3_campo, x3_picture,x3_tamanho, x3_decimal, cValid,x3_usado, x3_tipo, x3_arquivo , x3_context } )
	EndIf
	dbSkip()
End    
Return aTmpheader

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CriaCols   ³Autor ³ Rafael Rizzatto       ³ Data ³ 09/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de criacao do aCols de acordo com o aHeader         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/                                       
Static Function CriaCols(cAlias,nF,nOpcao,nOrdem,cKey,cConteudo,aCampos,cFiltro,nLenCols)
Local nUsado:= 0
Local aTmpCols:= {}
Local nCnt		:=0
Local nHeader 	:= 0
Local cFiltraTmp:= ''
Local bFiltraTmp:= {|| Nil}	//Variavel para Filtro
Local aIndexTmp	:= {}			//Variavel Para Filtro
Private cFilter	:= ''

If  cAlias == "AI0"
	cPrefixo    := "AI0_"	
Else
	cPrefixo    := "A2_"	
Endif

nOrdem 		:= if(nOrdem==NIL,1,nOrdem)
cKey   		:= if(cKey==NIL,'',cKey)
cConteudo	:= if(cConteudo=NIL,'',cConteudo)
aCampos  	:= if(aCampos=NIL,{},aCampos)

SX3->(DbSetOrder(2))
nCnt := 0
aRecSA2:={}
aTmpCols:={}
dbSelectArea(cAlias)
#IFDEF TOP 
	cFilter	:=	DbFilter()
	Set Filter To
	If  cAlias == "AI0" 
		cFiltraTmp	  := "AI0_FILIAL=='"+xFilial('AI0')+"' .And. AI0_CONDO == '2' "
		bFiltraTmp 	:= {|| FilBrowse("AI0",@aIndexTmp,@cFiltraTmp) }
		If !lAutomato
			Eval(bFiltraTmp)
		Endif
	Endif
#ENDIF


dbSetOrder(1)
If  cAlias == "AI0" 
	MsSeek(xFilial(cAlias))
Else
	MsSeek(cConteudo)
Endif

While !EOF() .AND. xFilial(cAlias) == &(cAlias+"->"+cPrefixo+"FILIAL") 
	If (Iif(cKey=='',.t.,(&cKey == cConteudo) ))
		If &cFiltro
			nCnt++
			nUsado:=0
			Aadd(aRecSA2,&(cAlias+"->(RECNO())"))
			Aadd(aTmpCols,Array(Len(aHeader)+1))
			For nHeader := 1 To Len(aHeader)
				SX3->(MsSeek(aHeader[nHeader][2]))
				If X3USO(SX3->X3_USADO) .AND. cNivel >= SX3->x3_nivel .And. !Empty( AScan( aCampos, { |x| x == AllTrim(SX3->X3_CAMPO) } ) )
					If SX3->X3_CONTEXT # "V"
						aTmpCols[nCnt][nHeader] := &(cAlias+"->"+Trim(SX3->x3_campo))
					Else
						aTmpCols[nCnt][nHeader] := CriaVar(AllTrim(SX3->x3_campo))
					EndIf
				EndIf
			Next
		   aTmpCols[nCnt][Len(aHeader)+1] := .F.
		Endif  
	Endif
	dbSkip()
EndDo

nLenCols	:=	Len(aTmpCols)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Array de 1 elemento ³
//³ vazio. Se inclus†o.       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Len(aTmpCols) == 0
	aTmpCols := Array(1, Len(aHeader) + 1)
	aTmpCols[1,Len(aHeader)+1] := .F.
	For nHeader := 1 To Len(aHeader)
		SX3->(MsSeek(aHeader[nHeader][2]))
		If X3USO(SX3->x3_usado) .AND. cNivel >= SX3->x3_nivel .And. !Empty( AScan( aCampos, { |x| x == AllTrim(SX3->X3_CAMPO) } ) )
			nUsado++
			If SX3->x3_tipo == "C"
				aTmpCols[1][nHeader] := SPACE(SX3->x3_tamanho)
			ElseIf SX3->x3_tipo == "N"
				aTmpCols[1][nHeader] := 0
			ElseIf SX3->x3_tipo == "D"
				aTmpCols[1][nHeader] := CTOD("  /  /  ")
			ElseIf SX3->x3_tipo == "M"
				aTmpCols[1][nHeader] := ""
			Else
				aTmpCols[1][nHeader] := .F.
			EndIf
			If SX3->x3_context == "V"
				aTmpCols[1][nHeader] := CriaVar(allTrim(SX3->x3_campo))
			EndIf
		EndIf
	Next
EndIf

If  cAlias == "AI0"
	EndFilBrw("AI0",aIndexTmp)
Endif

#IFDEF TOP              
	Eval(bFiltraBrw)
#ELSE
	DbSetOrder(nOrdem)
#ENDIF

Return aClone(aTmpCols)        

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CondoTudok³ Autor ³ Rafael Rizzatto      ³ Data ³ 09/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se os campos estao OK                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS   ³           Motivo da Alteracao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Laura Medina³19/04/17³MMI-5484³Se agrego validacion del Codigo y Tienda³±±
±±³            ³        ³        ³para que no permita dar de alta un regis³±±
±±³            ³        ³        ³tro o con el mismo dato que el del enca-³±±
±±³            ³        ³        ³bezado que se está dando mantenimiento. ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mt021Tudok()
Local lRet := .T.
Local nX
Local nTotal	:=	0
Local nPosCli	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_A2_COD"})
Local nPosLoja	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_A2_LOJA"})
Local nPosPerc	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_A2_PERCCON"})
Local aArea	:= GetArea()
Local cCodFor := ""
Local lNoGrab := .T.
DbSelectArea("SA2")
DbSetOrder(1)
For nX:= 1 To Len(aCols)
	If !aCols[nX][Len(aCols[nX])] 
		nTotal	+=	aCols[nX][nPosPerc]	
	Endif
	If  SA2->(DbSeek(xFilial("SA2")+aCols[nX][nPosCli]+aCols[nX][nPosLoja]))
    	cCodFor+=  STR0021 + aCols[nX][nPosCli]+ STR0022 +aCols[nX][nPosLoja] + Chr(13) + Chr(10)//    " Codigo: " ### " Sucursal: "
    	If  aCols[nX][nPosCli]+aCols[nX][nPosLoja] == M->A2_COD + M->A2_LOJA 
			Msgalert( STR0031 +Chr(13) + Chr(10)+ Chr(13) + Chr(10)+ ;
						STR0021 + aCols[nX][nPosCli]+ STR0022 +aCols[nX][nPosLoja] + Chr(13) + Chr(10))
			lNoGrab:=.F.
			lRet	:=.F.
		Endif
    EndIf
Next
RestArea(aArea)
If	lNoGrab
	If nTotal <> 100
		Help('1',0,'NO100%')
		lRet	:=	.F.
	Endif
	If  lRet .AND. Len(cCodFor) > 0
		lRet:=.F.
		DEFINE FONT oFont NAME "Courier New" SIZE 9,14   //6,15
		DEFINE MSDIALOG oDlg TITLE STR0023 From 3,0 to 240,450 PIXEL    // "Proveedor ya existe. Confirma modificación de datos."
		@ 5,5 GET oMemo  VAR cCodFor MEMO SIZE 215,090 OF oDlg PIXEL 
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		DEFINE SBUTTON  FROM 100,150 TYPE 1 ACTION (If(!lRet,lRet:= .T.,oDlg:End()),)ENABLE OF oDlg PIXEL //Apaga
		DEFINE SBUTTON  FROM 100,180 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL 
		
		ACTIVATE MSDIALOG oDlg CENTER
	EndIf
EndIf

Return lRet
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt021LinOk ³Autor ³ Rafael Rizzatto       ³ Data ³ 09/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checagem de linha na getdados.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mt021LinOk()
Local lRet	:=	.T.
Local nPosCli	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_A2_COD"})
Local nPosLoja	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_A2_LOJA"})
If !aCols[n,Len(aHeader)+1]
	If Empty(aCols[n,nPosCli]).Or. Empty(aCols[n,nPosLoja])
		Help('1',0,"Obrigat")
		lRet	:=	.F.
	EndIf
Endif	   
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt021VldCod³Autor ³ Rafael Rizzatto       ³ Data ³ 09/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checagem de linha na getdados.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mt021VldCod()
Local lRet	:=	.T.            
Local nPosCli	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_A2_COD"})
Local nPosLoja	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_A2_LOJA"})  
Local cCod 	:=	IIf("M->_A2_COD" == Alltrim(ReadVar()),&(ReadVar()),aCols[n][nPosCli])
Local cLoja	:=	IIf("M->_A2_LOJA" == Alltrim(ReadVar()),&(ReadVar()),aCols[n][nPosLoja])
Local nX	:=	0
If  n>nColsOri              
	If !aCols[n,Len(aHeader)+1]
		If "M->_A2_COD" == Alltrim(ReadVar())
			If Substr(cCod,1,3)<>M->A2_CODCOND
				Aviso("Atencion",STR0015+M->A2_CODCOND+')',{STR0016}) //'El codigo de proveedor debe comenzar con el codigo de condominio ('###'Ok'
				lRet	:=	.F.
			EndIf
		Endif
		If lRet    
			nX	:=	1
			While nX <= Len(aCols) .And. lRet
				If nX <> n
					If aCols[nX][nPosCli]+aCols[nX][nPosLoja] == cCod+cLoja  .And.  !aCols[3][len(aHeader)+1] //No debe considerar los registros marcados como borrados
						Aviso("Atencion",STR0017+Alltrim(Str(nX)),{STR0016}) //'El codigo de proveedor+sucursal informado ya esta registrado en la linea '###'Ok'
						lRet	:=	.F.					
					Endif 
				Endif
				nX++
			Enddo
		Endif
	Endif	        
Endif	 
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt021FielOk³Autor ³ Rafael Rizzatto       ³ Data ³ 09/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checagem de cada campo da GEtdados                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mt021FieldOk()
Local lRet	:=	.T.
If !("A2_PERCCON"$ReadVar()) .And. n<=nColsOri
	Aviso(STR0018,STR0019,{STR0020}) //"Atencion"###"Este campo no puede ser editado, por favor modifiquelo a traves de la rutina de mantenimiento de proveedores"###"Ok"
	lRet	:=	.F.
Endif	 
Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VldProvSA2³ Autor ³ Laura Medina         ³ Data ³ 01/09/16 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica si el Proveedor ya existe en la tabla SA2         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldProvSA2()
Local lRet := .T.
Local nPosCli	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_A2_COD"})
Local nPosLoja	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_A2_LOJA"})
Local aArea	:= GetArea()
Local cCodFor := ""
DbSelectArea("SA2")
DbSetOrder(1)

If  SA2->(DbSeek(xFilial("SA2")+aCols[n][nPosCli]+aCols[n][nPosLoja]))
   	cCodFor+=  STR0021 + aCols[n][nPosCli]+ STR0022 +aCols[n][nPosLoja] + Chr(13) + Chr(10)//    " Codigo: " ### " Sucursal: "
   	cCodFor+=  Chr(13) + Chr(10) 					
   	cCodFor+=  STR0027 + Chr(13) + Chr(10)
  	cCodFor+=  STR0028 + Chr(13) + Chr(10)
   	cCodFor+=  STR0029 + Alltrim(M->A2_COD)+" "+ Alltrim(M->A2_LOJA) +", "+ STR0030+ Chr(13) + Chr(10)
   	cCodFor+=  " "+POSICIONE("SX3",2,"A2_TIPO","X3_TITSPA") 	+" (A2_TIPO)" 	+ Chr(13) + Chr(10)
	cCodFor+=  " "+POSICIONE("SX3",2,"A2_AGENRET","X3_TITSPA")+" (A2_AGENRET)"	+ Chr(13) + Chr(10)
	cCodFor+=  " "+POSICIONE("SX3",2,"A2_PORIVA","X3_TITSPA") +" (A2_PORIVA)" 	+ Chr(13) + Chr(10)
	cCodFor+=  " "+POSICIONE("SX3",2,"A2_PORGAN","X3_TITSPA") +" (A2_PORGAN)"	+ Chr(13) + Chr(10)
	cCodFor+=  " "+POSICIONE("SX3",2,"A2_PERCIVA","X3_TITSPA")+" (A2_PERCIVA)"	+ Chr(13) + Chr(10)
	cCodFor+=  " "+POSICIONE("SX3",2,"A2_INSCGAN","X3_TITSPA")+" (A2_INSCGAN)"	+ Chr(13) + Chr(10)
	cCodFor+=  " "+POSICIONE("SX3",2,"A2_PERCIB","X3_TITSPA") +" (A2_PERCIB)"	+ Chr(13) + Chr(10)
	cCodFor+=  " "+POSICIONE("SX3",2,"A2_AGREGAN","X3_TITSPA")+" (A2_AGREGAN)"	+ Chr(13) + Chr(10)
	cCodFor+=  " "+POSICIONE("SX3",2,"A2_RETIB","X3_TITSPA")  +" (A2_RETIB)"	+ Chr(13) + Chr(10)  	
EndIf     

RestArea(aArea)

If  lRet .AND. Len(cCodFor) > 0
	lRet:=.F.
	DEFINE FONT oFont NAME "Courier New" SIZE 9,14   //6,15
	DEFINE MSDIALOG oDlg TITLE STR0026 From 3,0 to 240,450 PIXEL    // "Proveedor ya existe. ¿Confirma modificación de datos.?"
	@ 5,5 GET oMemo  VAR cCodFor MEMO SIZE 215,090 OF oDlg PIXEL 
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont
	DEFINE SBUTTON  FROM 100,150 TYPE 1 ACTION (If(!lRet,lRet:= .T.,oDlg:End()),)ENABLE OF oDlg PIXEL //Apaga
	DEFINE SBUTTON  FROM 100,180 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg PIXEL 
	
	ACTIVATE MSDIALOG oDlg CENTER
EndIf

Return lRet
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VldExReg  ³ Autor  ³ Alf Medrano         ³ Data ³ 14/16/17 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica si existe Proveedor en SA2 como Persona Jurídica  ³±±
±±³          ³ para configurar condominios                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldExReg()
Local aArea	:= GetArea()
Local cQuery 	:= ""
Local nCnt 	:= 0
Local lRet 	:= .T. 
cQuery := " SELECT COUNT(*) TOTAL "
cQuery += " FROM "+	RetSqlName("SA2")
cQuery += " WHERE A2_FILIAL = '" + xFilial("SA2") + "' AND "
cQuery += " A2_CONDO = '1' AND  D_E_L_E_T_ = ' ' "
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'TmpSA2', .F., .T.)
dbSelectArea("TmpSA2")
nCnt := TmpSA2->TOTAL

If  nCnt <= 0
	MsgInfo( STR0033 , STR0032 )	// No existen Proveedores configurados con Sit. Persona = Persona Jurídica. ### "Atención"
	lRet := .F.
EndIf

dbCloseArea()
RestArea( aArea )
Return lRet




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Función    ³ MATA021C  ³ Autor ³                     ³ Data ³13/08/21  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descripción³ Función para crear Condominios a partir de Clientes       ³±±
±±³           ³                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³ MATA021()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³          ³                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function MATA021C

Local cFiltra	  := ""	//Variavel para filtro

   
PRIVATE aRotina := { 	{STR0001,"PesqBrw"    , 0 , 1},;  //"Pesquisar"
    					{STR0002,"MT021CCond" , 0 , 2},;  //"Visualizar"
			   			{STR0014,"Mt021CCond" , 0 , 3}}   //"Mant. Condominos" //"Mant.Condominos"


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabecalho da tela de atualizacoes                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0006  //"Clientes" 
PRIVATE aMemos    := {}
PRIVATE nOpc
PRIVATE xRotAuto
Private aRecSA2 	:= {}
Private bFiltraBrw 	:= {|| Nil}	//Variavel para Filtro
Private aIndexAI0	:= {}			//Variavel Para Filtro
Private aBrowseAI0	:= {}

dbSelectArea("SX3")
SX3->(dbSetOrder(2))
If  SX3->(MsSeek("AI0_FILIAL"))
	AAdd(aBrowseAI0,{X3Titulo(),"AI0_FILIAL"})
EndIf
If  SX3->(MsSeek("AI0_CODCLI"))
	AAdd(aBrowseAI0,{X3Titulo(),"AI0_CODCLI"})
EndIf
If  SX3->(MsSeek("AI0_LOJA"))
	AAdd(aBrowseAI0,{X3Titulo(),"AI0_LOJA"})
EndIf
If  SX3->(MsSeek("AI0_CODCON"))
	AAdd(aBrowseAI0,{X3Titulo(),"AI0_CODCON"})
EndIf
If  SX3->(MsSeek("AI0_PERCCO"))
	AAdd(aBrowseAI0,{X3Titulo(),"AI0_PERCCO"})
EndIf

nOpc := if (nOpc == Nil, 3, nOpc)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao de variaveis para rotina de inclusao automatica    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Private l030Auto := ( xRotAuto <> NIL )  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa o filtro utilizando a funcao FilBrowse                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("AI0")
dbSetOrder(1)

If  AI0->(ColumnPos("AI0_CODCON")*ColumnPos("AI0_CONDO")*ColumnPos("AI0_PERCCO")) == 0 
	MsgAlert(STR0037,STR0025)   // "Existe Inconsistencia en el tratamiento de Condominios (campos: AI0_CONDO, AI0_CODCON y AI0_PERCCO). Por favor verificar las condiguraciones en el Documento Técnico."
	Return(.F.)
EndIf		


cFiltra 	  := "AI0_FILIAL=='"+xFilial('AI0')+"' .And. AI0_CONDO == '1' .And. AI0_CODCON <> '' "
bFiltraBrw 	:= {|| FilBrowse("AI0",@aIndexAI0,@cFiltra) }
Eval(bFiltraBrw)

dbSelectArea("AI0")
dbGotop()

mBrowse( 6,1,22,75,"AI0",aBrowseAI0)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta o filtro utilizando a funcao FilBrowse                     	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
EndFilBrw("AI0",aIndexAI0)

dbSelectArea("AI0")
dbSetOrder(1)
         
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Mt021CCond    ³ Autor ³                       ³ Data ³ 13/08/21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao das informacoes cadastrais do Condomino -Cliente    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mt021CCond(cAlias,nReg,nOpcx)
Local nX, oDlg
Local aG1	 		:= {"AI0_CODCLI","AI0_LOJA","AI0_PERCCO"}              
Local aSavAI0  		:= AI0->(GetArea())
Local aObjects 		:= {} 
Local aPosObj  		:= {} 
Local aSizeAut 		:= {}
Local lDel			:=	(nOpcx<>2)                     
Private nOpcao		:= If(nOpcx#2,3,nOpcx)
Private oGet01		:= NIL
Private aCols       := {}
Private aHeader     := {}
Private aSvAtela	:= {{},{},{}}
Private aTela		:= {}
Private aGets		:= {}
Private oEnc01		:= NIL
Private lOk			:= .F.
Private nColsOri	:=	0
Private lAutomato 	:= isBlind()

If !VldExCte()
	Return
EndIf
aSizeAut := MsAdvSize()
aObjects := {} 

AAdd( aObjects, {  68,130, .T., .T. } )
AAdd( aObjects, { 105,510, .T., .T. } )

aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 } 

aPosObj := MsObjSize( aInfo, aObjects,.T. ) 

   dbSelectArea("AI0")
   DbSetOrder(1)
  
   If !lAutomato
   	DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
   Endif	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enchoice 							            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
	dbSelectArea("AI0")                 

	aGets := {}                                            
	aTela := {}

 	RegToMemory("AI0",.F.,.F.)
 	If !lAutomato
		oEnc01:= MsMGet():New("AI0" ,nReg ,2 ,,,,,aPosObj[1],,,,,,oDlg,,.T.,.F.,"aSvATela[1]",.T.)
		oEnc01:Refresh()
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ getDados 			                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aHeader 	:= aClone(CriaHeader('AI0',aG1))
	If !lAutomato
		aCols		:= CriaCols('AI0',1,nOpcao,IndexOrd(),"AI0_FILIAL+AI0_CODCON",xFilial("AI0")+M->AI0_CODCON,aG1,"AI0_CONDO == '2'",@nColsOri)
	Else
		If  FindFunction("GetParAuto")
			aRetAuto 	:= GetParAuto("MATA021TESTCASE")
			aCols 		:= aRetAuto[1]
		Endif
	EndIf
	n        := 1
	For nX:= 1 To Len(aHeader)		
		aHeader[nX][2] := "_"+aHeader[nX][2]
	Next   
	If !lAutomato 
		oGet01 	:= MSGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcao,"Mt021CLinOk()","Mt021CTudok()";
		,,lDel,,,,, ,,,'(n>nColsOri)',oDlg)				
		 		
		oGet01:oBrowse:Default()	
		oGet01:oBrowse:Refresh()
	                     
		ACTIVATE DIALOG oDlg ON ;
		INIT ( EnchoiceBar(oDlg, {|| lOk:=.T.,If(oGet01:TudoOk(),(If(Str(nOpcao,1) $ "345",Mt021CGrv(),.t.),oDlg:End()),.F.)  },{|| lOk := .F.,oDlg:End()} ))
	Else
		lOk:=.T.
		Mt021CLinOk()	
		Mt021CGrv()
	EndIf
	RestArea(aSavAI0)
  
Return

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³CondoGrava ³Autor ³ Rafael Rizzatto       ³ Data ³ 09/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Funcao de gravacao dos dados.                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Mt021CGrv()
Local nI 		:= 0              
Local nPosCli	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_AI0_CODCLI"})
Local nPosLoja	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_AI0_LOJA"})
Local nPosPerc	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_AI0_PERCCO"})
Local aArea		:=	AI0->(GetArea())
Local cFilter
DbSelectArea("AI0")
DbSetOrder(1)
#IFDEF TOP 
	cFilter	:=	DbFilter()
	Set Filter To
#ENDIF	          
Begin Transaction
If  Len(aCols) > 0
	BorraCfg(M->AI0_CODCOND)  //Borra configuraciones previas antes de grabar
	For nI := 1 To Len(aCols)
	 	If	!aCols[nI][Len(aCols[nI])] 
		 	If  MsSeek(xFilial("AI0")+aCols[nI][nPosCli]+aCols[nI][nPosLoja])
				RecLock("AI0",.F.)         
				//Para los CLIENTES que ya existen
				AI0->AI0_CONDO	:= "2"   //Cliente existente se va a convertir en Participante del Condominio        
				AI0->AI0_CODCON := M->AI0_CODCOND
				AI0->AI0_PERCCO := aCols[nI,nPosPerc]				
		  		AI0->(MsUnlock())         
	 		Endif
		Endif
	Next       
Endif                      
End Transaction      
#IFDEF TOP            
	DbSelectArea("AI0")
	DbSetOrder(aArea[2])	
	If !lAutomato				
		Eval(bFiltraBrw)
	EndIf
#ELSE
	RestArea(aArea)
#ENDIF

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt021CLinOk³Autor ³ Rafael Rizzatto       ³ Data ³ 09/07/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checagem de linha na getdados.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mt021CLinOk()
Local lRet		:=	.T.
Local aArea		:= GetArea()
Local nPosCli	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_AI0_CODCLI"})
Local nPosLoja	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_AI0_LOJA"})
Local nPosPerc	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_AI0_PERCCO"})

If  M->AI0_PERCCO <= 0
	MsgAlert(STR0038+ M->AI0_CODCLI +" - "+ M->AI0_LOJA + STR0039,STR0025)  //"No fue informado el porcentaje del cliente receptor del comprobante: "+M->AI0_CODCLI+" - " M->AI0_LOJA+ ", debe ser informado desde la rutina de Clientes."
	lRet  :=  .F.
Else 
	If !aCols[n,Len(aHeader)+1]
		If Empty(aCols[n,nPosCli]) .Or. Empty(aCols[n,nPosLoja]) .Or. Empty(aCols[n,nPosPerc]) 
			Help('1',0,"Obrigat")
			lRet	:=	.F.
		ElseIf aCols[n,nPosPerc]<=0 
			MsgAlert(STR0040,STR0025)  //El porcentaje debe ser mayor a 0.
			lRet  :=  .F.
		ElseIf 	M->AI0_PERCCO < aCols[n][nPosPerc] 	
			MsgAlert(STR0045,STR0025)  //El porcentaje debe ser menor al del receptor del comprobante (encabezado).
			lRet  :=  .F.
		Else
			DbSelectArea("AI0")
			DbSetOrder(1)
			#IFDEF TOP 
				cFilter	:=	DbFilter()
				Set Filter To
			#ENDIF
			If  !AI0->(MsSeek(xFilial("AI0")+aCols[n][nPosCli]+aCols[n][nPosLoja]))
				 MsgAlert(STR0041,STR0025)  //"Cliente no existe, Verifique! "
				 lRet	:=.F.
			EndIf
			#IFDEF TOP      
			    If !lAutomato
			    	Eval(bFiltraBrw)
			    Endif
			#ELSE
				DbSetOrder(nOrdem)
			#ENDIF
		EndIf
	Endif	   
Endif

RestArea(aArea)
Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Mt021CTudok³ Autor ³                     ³ Data ³ 16/08/21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica se os campos estao OK                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS   ³           Motivo da Alteracao          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³        ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mt021CTudok()
Local lRet 		:= .T.
Local nX
Local nTotal	:=	0
Local nPosCli	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_AI0_CODCLI"})
Local nPosLoja	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_AI0_LOJA"})
Local nPosPerc	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_AI0_PERCCO"})
Local aArea		:= GetArea()
Local cCodFor 	:= ""
Local lNoGrab 	:= .T.

DbSelectArea("AI0")
DbSetOrder(1)

nTotal := M->AI0_PERCCO

For nX:= 1 To Len(aCols)
	If !aCols[nX][Len(aCols[nX])] 
		nTotal	+=	aCols[nX][nPosPerc]	
		If  AI0->(MsSeek(xFilial("AI0")+aCols[nX][nPosCli]+aCols[nX][nPosLoja]))
	    	cCodFor+=  STR0021 + aCols[nX][nPosCli]+ STR0022 +aCols[nX][nPosLoja] + Chr(13) + Chr(10)//    " Codigo: " ### " Sucursal: "
	    	If  aCols[nX][nPosCli]+aCols[nX][nPosLoja] == M->AI0_CODCLI + M->AI0_LOJA 
				Msgalert( STR0031 +Chr(13) + Chr(10)+ Chr(13) + Chr(10)+ ;
							STR0021 + aCols[nX][nPosCli]+ STR0022 +aCols[nX][nPosLoja] + Chr(13) + Chr(10))
				lRet  := .F.
			ElseIf AI0->AI0_CONDO == '1' .And. (AI0->AI0_CODCLI + AI0->AI0_LOJA <> M->AI0_CODCLI + M->AI0_LOJA)  //"El cliente ya existe como Sit. Persona igual a Persona Jurídica (AI0_CONDO), ¿desea grabarlo como participante?"
				lRet:= MsgYesNo(STR0044 +Chr(13) + Chr(10)+ Chr(13) + Chr(10)+ ;
							STR0021 + aCols[nX][nPosCli]+ STR0022 +aCols[nX][nPosLoja] + Chr(13) + Chr(10),STR0025)
			Endif
	    EndIf
    Endif
Next
RestArea(aArea)
If	lNoGrab
	If  nTotal <> 100
		MsgAlert(STR0035,STR0025)  //La suma de los porcentajes debe ser del 100% (considerando el condominio encabezado).
		lRet	:=	.F.
	Endif
EndIf

RestArea( aArea )
Return lRet


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt021CVldC ³Autor ³                       ³ Data ³ 16/08/21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Checagem de linha na getdados.                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Mt021CVldC()
Local lRet		:=	.T.   
Local aArea		:= GetArea()         
Local nPosCli	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_AI0_CODCLI"})
Local nPosLoja	:=	Ascan(aHeader,{|x| Alltrim(x[2])=="_AI0_LOJA"})  
Local cCod 		:=	IIf("M->_AI0_CODCLI" == Alltrim(ReadVar()),&(ReadVar()),aCols[n][nPosCli])
Local cLoja		:=	IIf("M->_AI0_LOJA" == Alltrim(ReadVar()),&(ReadVar()),aCols[n][nPosLoja])
Local nX		:=	1

If n>nColsOri              
	If !aCols[n,Len(aHeader)+1]
		While nX <= Len(aCols) .And. lRet
			If  nX <> n
				If  aCols[nX][nPosCli]+aCols[nX][nPosLoja] == cCod+cLoja  .And.  !aCols[nX][len(aHeader)+1] //No debe considerar los registros marcados como borrados
					Aviso(STR0018,STR0042+Alltrim(Str(nX)),{STR0016}) //'El codigo de cliente+sucursal informado ya esta registrado en la linea '###'Ok'
					lRet	:=	.F.					
				Endif 
			Endif
		nX++
		Enddo
	Endif	        
Endif	 

RestArea( aArea )
Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ VldExCte  ³ Autor  ³                     ³ Data ³ 16/08/21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Verifica si existe Proveedor en SA2 como Persona Jurídica  ³±±
±±³          ³ para configurar condominios                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VldExCte()
Local aArea	:= GetArea()
Local cQuery := ""
Local nCnt 	:= 0
Local lRet 	:= .T. 
Local cAliasQry	:= GetNextAlias()

cQuery := " SELECT COUNT(*) TOTAL "
cQuery += " FROM "+	RetSqlName("AI0")
cQuery += " WHERE AI0_FILIAL = '" + xFilial("AI0") + "' AND "
cQuery += " AI0_CONDO = '1' AND  D_E_L_E_T_ = ' ' AND AI0_CODCON <> ''"

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
DbSelectArea(cAliasQry)

nCnt := (cAliasQry)->TOTAL

If  nCnt <= 0
	MsgInfo( STR0043 , STR0032 )	// No existen Clientes configurados con Sit. Persona = Persona Jurídica. ### "Atención"
	lRet := .F.
EndIf

(cAliasQry)->(DbCloseArea())
RestArea( aArea )

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ BorraCfg  ³ Autor  ³ Laura M.            ³ Data ³ 18/08/21 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Borra las configuraciones existentes antes de grabar las   ³±±
±±³          ³ nuevas.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Financeiro                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BorraCfg(cCodRec)
Local aArea	 := GetArea()
Local cQuery := ""
Local nCnt 	 := 0
Local lRet 	 := .T. 
Local cAliasQry	:= GetNextAlias()

Default cCodRec := ""

cQuery := " SELECT * "
cQuery += " FROM "+	RetSqlName("AI0")
cQuery += " WHERE AI0_FILIAL = '" + xFilial("AI0") + "' AND "
cQuery += " AI0_CONDO = '2' AND  D_E_L_E_T_ = ' '  AND AI0_CODCON = '"+cCodRec+"' "

cQuery := ChangeQuery(cQuery)
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cAliasQry, .F., .T.)
DbSelectArea(cAliasQry)

While (cAliasQry)->(!Eof())
		dbSelectArea("AI0")
		AI0->(dbSetOrder(1))
		If  MsSeek(xFilial("AI0")+(cAliasQry)->AI0_CODCLI+(cAliasQry)->AI0_LOJA)
	 		RecLock("AI0",.F.) 
	 		AI0->AI0_CONDO	:= ""          
			AI0->AI0_CODCON := ""
			AI0->AI0_PERCCO := 0	
			AI0->(MsUnlock())
		Endif		
	(cAliasQry)->(DbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

RestArea( aArea )
Return lRet

