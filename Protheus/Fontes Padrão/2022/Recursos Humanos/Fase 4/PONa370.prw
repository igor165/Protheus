#INCLUDE "PONA370.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "PONCALE2.CH"
#INCLUDE "PONCALEN.CH"

#DEFINE CONFIRMA 1


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ Pona370  ³ Autor ³ Mauricio MR           ³ Data ³ 02.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Manutencao de Programação de Horarios                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³MauricioMR  ³02/10/07³      ³ Idealizacao							  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pona370()
Pona370Atu()
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³Pona370Atu³ Autor ³ Mauricio MR           ³ Data ³ 02.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Programa de Vis.,Inc.,Alt. e Del. de  Exce‡”es Diarias      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Pona370Atu(ExpC1,ExpN1,ExpN2)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1 = Alias do arquivo                                    ³±±
±±³          ³ExpN1 = Numero do registro                                  ³±±
±±³          ³ExpN2 = Numero da opcao selecionada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³Pona370                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pona370Atu(cAlias,nReg,nOpcx)
Local dDataIni
Local dDataFim
	If Upper( AllTrim( GetMv("MV_PAPEXCE") ) ) == "P"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o Parƒmetro MV_PAPONTA                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !PerAponta(@dDataIni,@dDataFim )
			Return Nil
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define datas Inicial e Final                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dDataIni := CtoD('01'+Right(DtoC(dDataBase),Len(DtoC(MsDate()))-2),'ddmmyy')
		dDataFim := CtoD(StrZero(f_UltDia(dDataBase),2)+Right(DtoC(dDataBase),Len(DtoC(MsDate()))-2),'ddmmyy')
	Endif


Tela(cAlias,nReg,nOpcx)

Return(Nil)


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³Tela			³Autor³Mauricio MR         ³ Data ³10/10/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Tela para Digitacao da Programacao							 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL		                                               	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PONA370                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/	
Static Function Tela(cAlias,nReg,nOpcx)
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGdAltera		:= {}
Local nOpcNewGd		:= IF( ( nOpcx == 2 ) , 0 , GD_INSERT + GD_UPDATE + GD_DELETE )
Local oDlg, oGet , oFont , oGroup , oDatas, oBtnLoadDados, oFolders, oMenu 


Local aButtons		:= {}
Local aSeleFolders	:= SeleFolder("RF2")
Local aFolders		:= {}
Local cFolder		:= ""

Local oPanelTop, oPanelBottom
Local oDepto, oPeriodo, oBarra  
Local oTopDepto
Local oTopPeriodo

Local cDepto 		:= ""   

Local aDatas	:= {} 
Local adDatas	:= {}
Local aButtons	:= {} 
Local nOpca		:= 1  
Local bSetDatas
Local bCargaDados  
Local bSetDados 
                  

Local a370Field  	:= { 'RF2_FILIAL', 'RF2_CC', 'RF2_TIPODIA','RF2_DATAATE' }

Local aMatriculas	:= {}

Private aVirtual  	:= {}
Private aTabCalend  := {}
Private aItensCalend:= {}
Private aTurnos		:= {}
Private aExcePer	:= {}

Private lGatForceGd	:= .T.
Private lHrsTrbGat	:= .F.

Private aHeaderAll := {} 
Private aColsAll	:= {}
Private aColsRec	:= {}  
Private aColsAnt
Private aCposFolder	:= {}

Private dDataIni  := Ctod('')
Private dDataFim  := Ctod('')

Private dDataFolder := Ctod('')

dDataIni:= (dDataBase + 1) -(Dow(dDataBase))
dDataFim:= dDataIni + 6   


SRA->(DbGoto(3)) 

/*
	If Upper( AllTrim( GetMv("MV_PAPEXCE") ) ) == "P"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica o Parƒmetro MV_PAPONTA                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !PerAponta(@dDataIni,@dDataFim )
			Return Nil
		EndIf
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Define datas Inicial e Final                                 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dDataIni := CtoD('01'+Right(DtoC(dDataBase),Len(DtoC(MsDate()))-2),'ddmmyy')
		dDataFim := CtoD(StrZero(f_UltDia(dDataBase),2)+Right(DtoC(dDataBase),Len(DtoC(MsDate()))-2),'ddmmyy')
	Endif
*/


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem os Titulos das abas de Datas do Periodo				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CriaDataFolder(	dDataIni, dDataFim, @aDatas, @adDatas)                 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Obtem os Titulos das abas da Get Dados						 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
CriaGetFolder(aSeleFolders, @aFolders, @aCposFolder)  
              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o cabecalho                                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pona370aHead( a370field , @aCposFolder , @aFolders )


	/*        
	
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Monta as Dimensoes dos Objetos         					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aAdvSize		:= MsAdvSize()

	DEFINE FONT oFont NAME "Arial" SIZE 0,-10 BOLD
	DEFINE MSDIALOG oDlg FONT oFont TITLE OemToAnsi(STR0143) From aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] OF oMainWnd PIXEL // 'Programação de Horarios' 
	
	@ 000,000 MSPANEL oPanelTop SIZE __DlgWidth(oDlg)*.70,__DlgWidth(oDlg)*.07  OF oDlg  
	@ 000,000 MSPANEL oTopDepto SIZE __DlgWidth(oPanelTop),__DlgWidth(oPanelTop)*.80  OF oPanelTop 
	@ 000,000 MSPANEL oTopPeriodo SIZE __DlgWidth(oPanelTop),__DlgWidth(oPanelTop) OF oPanelTop 

	@ 000,000 MSPANEL oPanelBottom SIZE __DlgWidth(oDlg),__DlgWidth(oDlg) OF oDlg  
	oPanelBottom:Align 	:= CONTROL_ALIGN_ALLCLIENT

	@ 000 , 001	GROUP oDepto TO __DlgWidth(oTopDepto)/15,__DlgWidth(oTopDepto) LABEL OemToAnsi(STR0140) OF oTopDepto PIXEL	//'Departamento'  
	oDepto:oFont:=oFont
	
	@ 000 , 001	GROUP oPeriodo TO __DlgWidth(oTopPeriodo)/15,__DlgWidth(oTopPeriodo)/2.3 LABEL OemToAnsi(STR0141) OF oTopPeriodo PIXEL	// 'Periodo'
	oPeriodo:oFont:=oFont
		
	@ 010 ,010 MSGET cDepto  	F3 "SQB" SIZE 050,10 OF oTopDepto PIXEL FONT oFont	 
 	oDepto			:= tSay():New(012,__DlgWidth(oTopDepto)*0.30,{||OemToAnsi('Descricao do Depto')}, oTopDepto,,,,,,.T.,,,50,10) 

	@ 010 ,010 MSGET dDataIni 	F3 "RCH" SIZE 050,10 OF oTopPeriodo PIXEL FONT oFont	
	oBarra	:= tSay():New(012,070,{||OemToAnsi(STR0142)}, oTopPeriodo,,,,,,.T.,,,50,10) 
	@ 010 ,080 MSGET dDataFim 	F3 "RCH" SIZE 050,10 OF oTopPeriodo PIXEL FONT oFont  Valid ( (dDataFim - dDataIni) <=	7 )	
	
	@ 015 ,270 BTNBMP oBtnLoadDados   RESOURCE "TK_REFRESH"  SIZE 25, 25   OF oTopPeriodo PIXEL MESSAGE STR0139 ;//"Refresh"
	ACTION 	Refresh(@oGet, dDataIni, dDataFim, @aDatas, @oDatas, @adDatas, oPanelBottom, oFolders, bSetDatas, bCargaDados, bSetDados)   				

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega o Objeto Folder               					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   
		
	oDatas := TFolder():New(	000						,;
								001						,;
								aDatas					,;
								aDatas					,;
								oPanelBottom			,;
								NIL						,;
								NIL						,;
								NIL						,;
								.T.						,;
								.F.						,;
								__DlgWidth(oPanelBottom),;			
								__DlgWidth(oPanelBottom)/2.3;
							 )


		oDatas:bSetOption := { |nNewFolder| If( Empty(nNewFolder), nNewFolder:=1,nNewFolder)	,;
								P370SetDatas(		nOpcNewGd 									,;  //01
													@oDatas										,;  //02
													@oGet			 							,;  //03
													@oDatas										,;  //04
													__DlgWidth(oDatas:aDialogs[nNewFolder])		,;  //05
													nNewFolder									,;  //06
													oDatas:nOption								,;  //07
													@oFolders									,;  //08
													aCposFolder									,;  //09
													aFolders									,;  //10
													aGdAltera									,;  //11
													adDatas										,; 	//13
													@bSetDados										;   //14 -> Bloco para apresentacao da GetDados													
											) 													;
							 }   
							 
							  

    bSetDatas		:= oDatas:bSetOption 
    bCargaDados	:= {||CargaDados(cAlias,nOpcx, @aGdAltera, cDepto ,dDataIni, dDataFim ) }
    
    
    
	oPanelTop:Align 	:= CONTROL_ALIGN_TOP
	oTopDepto:Align 	:= CONTROL_ALIGN_LEFT
	oTopPeriodo:Align 	:= CONTROL_ALIGN_ALLCLIENT	
		    	
	bSet15		:= { ||nOpca:=0, ;
								Transf370(	aColsAll    		,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
											oGet:aCols			,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
											oGet:aHeader		,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
											aHeaderAll			,;	//04 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
											.T.					,;	//05 -> Se deve Transferir do aCols para o aColsAll
											.T.					;	//06 -> Se deve Transferir do aColsAll para o aCols
								  		 )  ,;
						aCols:=aClone(aColsAll),;
						aHeader:=aClone(aHeaderAll),;		  		 
						IF( ( oGet:TudoOk()  )	,;
								(;
									nOpca := 1 ,;
									oDlg:End() ;
								),;
								(;
									nOpca := 0 ,;
									.F.;
								);	
							);
					}
	bSet24		:= { || nOpcA:= 0, oDlg:End() } 
	


   /*	ACTIVATE MSDIALOG oDlg  ON INIT ( Eval(bCargaDados), Eval(	bSetDatas ) ,  Eval(	bSetDados ), ;
 	                                 EnchoiceBar( oDlg , bSet15 , bSet24 , NIL  ) )  CENTERED
   */
 	ACTIVATE MSDIALOG oDlg  ON INIT ( Eval(bCargaDados), Eval(	bSetDatas ) ,;
 	                                 EnchoiceBar( oDlg , bSet15 , bSet24 , NIL  ) )  CENTERED

 	If nOpcA == CONFIRMA .And. nOpcx # 2
		//--Gravacao
		Begin Transaction
			Pona370Grava(cAlias)
			//--Processa Gatilhos
			EvalTrigger()
		End Transaction	
	Endif                                                             
Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³CriaDataFolder	³Autor³Mauricio MR         ³ Data ³10/10/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Determina os titulos das Abas do folder de Datas			 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL		                                               	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PONA370                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/	
Static Function CriaDataFolder(dDataIni, dDataFim, aAbaDatas, adDatas )
Local nFolder
Local nAba  
Local aSemana	:= {STR0020 , STR0021 , STR0022 , STR0023 , STR0024 , STR0025 , STR0026 } //"Dom...Sab"
Local dData

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Cria Abas dos Dias da Semana								   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/                                                
nFolder := (dDataFim-dDataIni)+1
aAbaDatas:= {} 
aDatas	:= {}
For nAba := 0 to Min(nFolder-1,6) 
    dData  := dDataIni+nAba
    aAdd(adDatas, dData)
	aAdd(aAbaDatas		, aSemana[ Dow(dData) ]+ "-" + Dtoc(dData)  )  
Next nAba

Return  Nil          

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³CriaGetFolder	³Autor³Mauricio MR         ³ Data ³10/10/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Determina os titulos das Abas do folder de Programacao		 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL		                                               	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PONA370                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/	
Static Function CriaGetFolder(aSeleFolders, aFolders, aCposFolder)
Local nElementos

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Monta os Folders											   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
For nElementos := 1 To Len( aSeleFolders )
	cFolder	:= SubStr( aSeleFolders[ nElementos ] , 5 )
	IF !Empty( cFolder )
		aAdd( aFolders , "&"+cFolder )  
		aAdd( aCposFolder , { SubStr( aSeleFolders[ nElementos ] , 1 , 1 ) , {} 				, {} , cFolder ,{} } ) 
	EndIF
Next nElementos

Return (Nil)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³CargaDados		³Autor³Mauricio MR         ³ Data ³10/10/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Bloqueia/Desbloqueia a Carga de Dados 						 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL		                                               	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PONA370                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function CargaDados(cAlias,nOpcx, aGdAltera, cDepto ,dDataIni, dDataFim, aCposFolder , aFolders )
Local lRet			:= .T.
Local aMatriculas   := {}

Begin Sequence
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Bloqueia Chaves Logicas de Excecoes do Funcionario Antes da   ³
	³montagem do Calendario. Temos que realizar nesse momento pois ³
	³se deixarmos no 2o bloqueio abaixo, o Calendario podera ser di³
	³ferente em virtude de novas excecoes de outra sessao dessa ro ³
	³rotina.                                                       ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If !Pona370Locks( nOpcX , 'RF2', {}, ProcName() )
       lRet:= .F.
       Break
    Endif

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega Array de Campos Alteraveis                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAlias := 'RF2'
    

	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Obter o calendario para o periodo de todos os funcionarios    ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	GetCalendTop( cFilAnt		,; //01 -> Filial
				  cDepto		,; //02 -> Depto
				  dDataIni		,; //03 -> Periodo Inicial
				  dDataFim		,; //04 -> Periodo Final
				  aTabCalend 	,;  //05 -> Array a ser carregado com os Calendarios
				  aGdAltera      ;  //06 -> Campos editaveis
				)
			
	
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Salva o Conteudo do aCols                                   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	aColsAnt	:= aClone( aColsAll )

   	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³Bloqueia Chaves Logicas e Registros de Excecoes do Funcionario³
	³Depois da Montagem do Calendario.							   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	If !Pona370Locks( nOpcX , 'RF2', aColsRec, ProcName() )
       lRet:= .F.
       Break
    Endif
 End      

Return (lRet)

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³Refresh			³Autor³Mauricio MR         ³ Data ³10/10/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Realiza o Refresh das Programacao de um periodo informado	 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL		                                               	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PONA370                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function Refresh(oGet, dDataIni, dDataFim, aDatas, oDatas, adDatas, oPanelBottom, oFolders, bSetDatas, bCarga, bSetDados)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Salva Dados antes de Nova Carga de Dados					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   
If MsgYesNo( OemToAnsi( STR0149) , STR0148 )	//Atencao# Gravar Programacao do Periodo"
	Eval(bSetDatas)
	Pona370Grava('RF2')
Endif


/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Recria ambiente (objetos e faz nova carga de dados		   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/   
oGet := NIL  
aDatas:= {}
adDatas:= {}

oFolders:Hide()
oFolders:= Nil

CriaDataFolder(	dDataIni, dDataFim, @aDatas, @adDatas)                 
oDatas:Hide()
oDatas:=Nil

oDatas := TFolder():New(	000						,;
							001						,;
							aDatas					,;
							aDatas					,;
							oPanelBottom			,;
							NIL						,;
							NIL						,;
							NIL						,;
							.T.						,;
							.F.						,;
							__DlgWidth(oPanelBottom),;			
							__DlgWidth(oPanelBottom)/2.3;
						 )
oDatas:bSetOption := bSetDatas

oDatas:Show()

Eval(bCarga)
Eval(bSetDatas)
//Eval(bSetDados )

Return (Nil)		


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡„o   ³Pona370aHead³Autor³Mauricio MR          	³ Data ³ 02.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡„o³ Criar o Arrays Aheader 								      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Pona370                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Pona370aHead( a370field , aCposFolder , aFolders )

Local aArea			:= GetArea()
Local aAreaSX3		:= SX3->( GetArea() )
Local aOutros		:= {}
Local cCpo			:= ""
Local cP2TrabaVld	:= ""
Local nPosFolder	:= 0.00   
Local nElem			:= 0



//-- Adiciona o 1 elemento ( Posto)
SX3->( dbSetOrder(2))
SX3->( dbSeek( "RF2_POSTO " , .F. ) ) 
aAdd( aHeaderAll,  Array(__ELEMENTOS_AHEADER__) )
nElem := Len(aHeaderAll)         
aHeaderAll[ nElem, __AHEADER_TITLE__	]:= X3TITULO()			//01 -> Titulo // 'Posto'
aHeaderAll[ nElem, __AHEADER_FIELD__ 	]:=	"RF2_POSTO"			//02 -> Campo
aHeaderAll[ nElem, __AHEADER_PICTURE__	]:=	SX3->X3_PICTURE		//03 -> Picture
aHeaderAll[ nElem, __AHEADER_WIDTH__   	]:=	SX3->X3_TAMANHO		//04 -> Tamanho
aHeaderAll[ nElem, __AHEADER_DEC__		]:=	SX3->X3_DECIMAL 	//05 -> Decimal
aHeaderAll[ nElem, __AHEADER_VALID__	]:=	SX3->X3_VALID		//06 -> Validacao
aHeaderAll[ nElem, __AHEADER_USE__		]:=	SX3->X3_USADO		//07 -> Usado
aHeaderAll[ nElem, __AHEADER_TYPE__		]:=	SX3->X3_TIPO		//08 -> Tipo
aHeaderAll[ nElem, __AHEADER_F3__		]:=	SX3->X3_F3			//09 -> Consulta Padrao
aHeaderAll[ nElem, __AHEADER_CBOX__		]:=	X3Cbox()			//11 -> Box
aHeaderAll[ nElem, __AHEADER_INITPAD__	]:=	SX3->X3_RELACAO		//12 -> Inicializador Padrao
aHeaderAll[ nElem, __AHEADER_WHEN__		]:= ".T."				//13 -> When
aHeaderAll[ nElem, __AHEADER_VISUAL__	]:=	SX3->X3_VISUAL		//14 -> Visual
aHeaderAll[ nElem, __AHEADER_VLDUSR__	]:=	SX3->X3_VLDUSER		//15 -> Validacao do Usuario  


//-- Adiciona o 1 elemento ( Descricao)
SX3->( dbSetOrder(2))
SX3->( dbSeek( "RCL_DFUNC" , .F. ) ) 

aAdd( aHeaderAll,  Array(__ELEMENTOS_AHEADER__) )
nElem := Len(aHeaderAll)         

aHeaderAll[ nElem, __AHEADER_TITLE__	]:= OemToAnsi(STR0146)	//01 -> Titulo // 'Descricao'
aHeaderAll[ nElem, __AHEADER_FIELD__ 	]:=	"M_DESC"			//02 -> Campo
aHeaderAll[ nElem, __AHEADER_PICTURE__	]:=	SX3->X3_PICTURE		//03 -> Picture
aHeaderAll[ nElem, __AHEADER_WIDTH__   	]:=	SX3->X3_TAMANHO		//04 -> Tamanho
aHeaderAll[ nElem, __AHEADER_DEC__		]:=	SX3->X3_DECIMAL 	//05 -> Decimal
aHeaderAll[ nElem, __AHEADER_VALID__	]:=	SX3->X3_VALID		//06 -> Validacao
aHeaderAll[ nElem, __AHEADER_USE__		]:=	SX3->X3_USADO		//07 -> Usado
aHeaderAll[ nElem, __AHEADER_TYPE__		]:=	SX3->X3_TIPO		//08 -> Tipo
aHeaderAll[ nElem, __AHEADER_F3__		]:=	SX3->X3_F3			//09 -> Consulta Padrao
aHeaderAll[ nElem, __AHEADER_CBOX__		]:=	X3Cbox()			//11 -> Box
aHeaderAll[ nElem, __AHEADER_INITPAD__	]:=	SX3->X3_RELACAO		//12 -> Inicializador Padrao
aHeaderAll[ nElem, __AHEADER_WHEN__		]:= ".F."				//13 -> When
aHeaderAll[ nElem, __AHEADER_VISUAL__	]:=	SX3->X3_VISUAL		//14 -> Visual
aHeaderAll[ nElem, __AHEADER_VLDUSR__	]:=	SX3->X3_VLDUSER		//15 -> Validacao do Usuario  
 


//-- Adiciona o 1 elemento ( Matricula)  
SX3->( dbSetOrder(2))
SX3->( dbSeek( "RF2_MAT" , .F. ) ) 

aAdd( aHeaderAll,  Array(__ELEMENTOS_AHEADER__) )
nElem := Len(aHeaderAll)
aHeaderAll[ nElem, __AHEADER_TITLE__	]:= X3TITULO()			//01 -> Titulo
aHeaderAll[ nElem, __AHEADER_FIELD__ 	]:=	SX3->X3_CAMPO		//02 -> Campo
aHeaderAll[ nElem, __AHEADER_PICTURE__	]:=	SX3->X3_PICTURE		//03 -> Picture
aHeaderAll[ nElem, __AHEADER_WIDTH__   	]:=	SX3->X3_TAMANHO		//04 -> Tamanho
aHeaderAll[ nElem, __AHEADER_DEC__		]:=	SX3->X3_DECIMAL 	//05 -> Decimal
aHeaderAll[ nElem, __AHEADER_VALID__	]:=	SX3->X3_VALID		//06 -> Validacao
aHeaderAll[ nElem, __AHEADER_USE__		]:=	SX3->X3_USADO		//07 -> Usado
aHeaderAll[ nElem, __AHEADER_TYPE__		]:=	SX3->X3_TIPO		//08 -> Tipo
aHeaderAll[ nElem, __AHEADER_F3__		]:=	SX3->X3_F3			//09 -> Consulta Padrao
aHeaderAll[ nElem, __AHEADER_CBOX__		]:=	X3Cbox()			//11 -> Box
aHeaderAll[ nElem, __AHEADER_INITPAD__	]:=	SX3->X3_RELACAO		//12 -> Inicializador Padrao
aHeaderAll[ nElem, __AHEADER_WHEN__		]:=	SX3->X3_WHEN		//13 -> When
aHeaderAll[ nElem, __AHEADER_VISUAL__	]:=	SX3->X3_VISUAL		//14 -> Visual
aHeaderAll[ nElem, __AHEADER_VLDUSR__	]:=	SX3->X3_VLDUSER		//15 -> Validacao do Usuario


//-- Adiciona o 1 elemento ( Nome)   
SX3->( dbSetOrder(2))
SX3->( dbSeek( "RA_NOME" , .F. ) ) 

aAdd( aHeaderAll,  Array(__ELEMENTOS_AHEADER__) )
nElem := Len(aHeaderAll)         

aHeaderAll[ nElem, __AHEADER_TITLE__	]:= X3TITULO()			//01 -> Titulo // 'Nome'
aHeaderAll[ nElem, __AHEADER_FIELD__ 	]:=	"M_NOME"			//02 -> Campo
aHeaderAll[ nElem, __AHEADER_PICTURE__	]:=	SX3->X3_PICTURE		//03 -> Picture
aHeaderAll[ nElem, __AHEADER_WIDTH__   	]:=	SX3->X3_TAMANHO		//04 -> Tamanho
aHeaderAll[ nElem, __AHEADER_DEC__		]:=	SX3->X3_DECIMAL 	//05 -> Decimal
aHeaderAll[ nElem, __AHEADER_VALID__	]:=	SX3->X3_VALID		//06 -> Validacao
aHeaderAll[ nElem, __AHEADER_USE__		]:=	SX3->X3_USADO		//07 -> Usado
aHeaderAll[ nElem, __AHEADER_TYPE__		]:=	SX3->X3_TIPO		//08 -> Tipo
aHeaderAll[ nElem, __AHEADER_F3__		]:=	SX3->X3_F3			//09 -> Consulta Padrao
aHeaderAll[ nElem, __AHEADER_CBOX__		]:=	X3Cbox()			//11 -> Box
aHeaderAll[ nElem, __AHEADER_INITPAD__	]:=	SX3->X3_RELACAO		//12 -> Inicializador Padrao
aHeaderAll[ nElem, __AHEADER_WHEN__		]:=	".F."				//13 -> When
aHeaderAll[ nElem, __AHEADER_VISUAL__	]:=	SX3->X3_VISUAL		//14 -> Visual
aHeaderAll[ nElem, __AHEADER_VLDUSR__	]:=	SX3->X3_VLDUSER		//15 -> Validacao do Usuario

aAdd( aVirtual , "M_SEQ")
aAdd( aVirtual , "M_DESC")
aAdd( aVirtual , "M_NOME")

//-- Adiciona o 3 elemento ( Trabalhado )
SX3->( dbSetOrder(2))
IF SX3->( dbSeek( "RF2_TRABA" , .F. ) )
	cP2TrabaVld := SX3->X3_VALID
Else
	cP2TrabaVld := "P2TrabaVld()"
EndIF

aAdd( aHeaderAll,  Array(__ELEMENTOS_AHEADER__) )
nElem := Len(aHeaderAll)    

aHeaderAll[ nElem, __AHEADER_TITLE__	]:= X3TITULO()			//01 -> Titulo // 
aHeaderAll[ nElem, __AHEADER_FIELD__ 	]:=	SX3->X3_CAMPO		//02 -> Campo
aHeaderAll[ nElem, __AHEADER_PICTURE__	]:=	SX3->X3_PICTURE		//03 -> Picture
aHeaderAll[ nElem, __AHEADER_WIDTH__   	]:=	SX3->X3_TAMANHO		//04 -> Tamanho
aHeaderAll[ nElem, __AHEADER_DEC__		]:=	SX3->X3_DECIMAL 	//05 -> Decimal
aHeaderAll[ nElem, __AHEADER_VALID__	]:=	cP2TrabaVld			//06 -> Validacao
aHeaderAll[ nElem, __AHEADER_USE__		]:=	SX3->X3_USADO		//07 -> Usado
aHeaderAll[ nElem, __AHEADER_TYPE__		]:=	SX3->X3_TIPO		//08 -> Tipo
aHeaderAll[ nElem, __AHEADER_F3__		]:=	SX3->X3_F3			//09 -> Consulta Padrao
aHeaderAll[ nElem, __AHEADER_CBOX__		]:=	X3Cbox()			//11 -> Box
aHeaderAll[ nElem, __AHEADER_INITPAD__	]:=	SX3->X3_RELACAO		//12 -> Inicializador Padrao
aHeaderAll[ nElem, __AHEADER_WHEN__		]:=	".T."				//13 -> When
aHeaderAll[ nElem, __AHEADER_VISUAL__	]:=	SX3->X3_VISUAL		//14 -> Visual
aHeaderAll[ nElem, __AHEADER_VLDUSR__	]:=	SX3->X3_VLDUSER		//15 -> Validacao do Usuario

dbSelectArea('Sx3')
SX3->( dbSetOrder( 01 ) )
SX3->( dbseek('RF2') )
While SX3->( !Eof() .And. (X3_ARQUIVO == 'RF2') )
	cCpo := Upper( AllTrim( SX3->X3_CAMPO ) )
	IF (;
			x3uso(SX3->X3_USADO) .And. ;
			cNivel >= SX3->X3_NIVEL .And. ;
			aScan(a370field,{|x| x == cCpo} ) == 0 .And. ;
			!cCpo $ "RF2_TRABA.RF2_MAT.RF2_POSTO";
		)	
		SX3->(;
					aAdd(aHeaderAll,{	AllTrim(X3Titulo() ),;
										cCpo,;
										X3_PICTURE,;
										X3_TAMANHO,;
										X3_DECIMAL,;
										IF( fContemStr( X3_CAMPO , "RF2_TIPODIA" , .T. ) , "Pn140TipoDia(M->RF2_TIPODIA)", X3_VALID	),;
										"",;
										X3_TIPO	,;
										"";
								 };
						 );
				)			 
		IF ( ( nPosFolder := aScan( aCposFolder , { |x| x[1] == SX3->X3_FOLDER } ) ) > 0.00 )
			aAdd( aCposFolder[ nPosFolder , 02 ] , cCpo )
		Else
			aAdd( aOutros , cCpo )
		EndIF
		IF ( SX3->X3_ConText == 'V' ) 
			Aadd( aVirtual , cCpo )
		EndIF
	EndIF
	SX3->( dbSkip() )
End While   

//-- Adiciona o 1 elemento ( Sequencia ) 

aAdd( aHeaderAll,  Array(__ELEMENTOS_AHEADER__) )
nElem := Len(aHeaderAll)                            

aHeaderAll[ nElem, __AHEADER_TITLE__	]:= OemToAnsi(STR0144)		//01 -> Titulo // 'Sequencia'
aHeaderAll[ nElem, __AHEADER_FIELD__ 	]:=	"M_SEQ"		   			//02 -> Campo
aHeaderAll[ nElem, __AHEADER_PICTURE__	]:=	'999999'				//03 -> Picture
aHeaderAll[ nElem, __AHEADER_WIDTH__   	]:=	6						//04 -> Tamanho
aHeaderAll[ nElem, __AHEADER_DEC__		]:=	0		 				//05 -> Decimal
aHeaderAll[ nElem, __AHEADER_VALID__	]:=	SX3->X3_VALID			//06 -> Validacao
aHeaderAll[ nElem, __AHEADER_USE__		]:=	CHR(251)				//07 -> Usado
aHeaderAll[ nElem, __AHEADER_TYPE__		]:= "N"						//08 -> Tipo
aHeaderAll[ nElem, __AHEADER_F3__		]:=	NIL						//09 -> Consulta Padrao
aHeaderAll[ nElem, __AHEADER_CBOX__		]:=	" "						//11 -> Box
aHeaderAll[ nElem, __AHEADER_INITPAD__	]:=	" "						//12 -> Inicializador Padrao
aHeaderAll[ nElem, __AHEADER_WHEN__		]:=	".F."					//13 -> When
aHeaderAll[ nElem, __AHEADER_VISUAL__	]:=	" "						//14 -> Visual
aHeaderAll[ nElem, __AHEADER_VLDUSR__	]:=	" "						//15 -> Validacao do Usuario


//Ghost
aAdd( aHeaderAll,  Array(__ELEMENTOS_AHEADER__) )
nElem := Len(aHeaderAll)    

aHeaderAll[ nElem, __AHEADER_TITLE__	]:= ""						//01 -> Titulo // 'Nome'
aHeaderAll[ nElem, __AHEADER_FIELD__ 	]:= "GHOSTCOL"				//02 -> Campo
aHeaderAll[ nElem, __AHEADER_PICTURE__	]:=	""						//03 -> Picture
aHeaderAll[ nElem, __AHEADER_WIDTH__   	]:=	GHOSTCOLSIZE			//04 -> Tamanho
aHeaderAll[ nElem, __AHEADER_DEC__		]:=	0				 		//05 -> Decimal
aHeaderAll[ nElem, __AHEADER_VALID__	]:=	""						//06 -> Validacao
aHeaderAll[ nElem, __AHEADER_USE__		]:=	Chr(251)				//07 -> Usado
aHeaderAll[ nElem, __AHEADER_TYPE__		]:=	"C"						//08 -> Tipo
aHeaderAll[ nElem, __AHEADER_F3__		]:=	""						//09 -> Consulta Padrao
aHeaderAll[ nElem, __AHEADER_CBOX__		]:=	""						//11 -> Box
aHeaderAll[ nElem, __AHEADER_INITPAD__	]:=	"GdNumItem('GHOSTCOL')"	//12 -> Inicializador Padrao
aHeaderAll[ nElem, __AHEADER_WHEN__		]:=	""						//13 -> When
aHeaderAll[ nElem, __AHEADER_VISUAL__	]:=	"V"						//14 -> Visual
aHeaderAll[ nElem, __AHEADER_VLDUSR__	]:=	""						//15 -> Validacao do Usuario

aAdd( aVirtual , "GHOSTCOL" )


//Inclusao das duas colunas para o uso WalkThru
// Inclui coluna de registro atraves de funcao generica
ADHeadRec("RF2",aHeaderAll)


IF !Empty( aOutros )
	aAdd( aFolders , "&"+STR0048 )
	aAdd( aCposFolder , { "" , aClone( aOutros ) , {} , STR0048,{} } )
EndIF

For nPosFolder := 1 To Len( aCposFolder )
	aAdd( aCposFolder[ nPosFolder , 02 ] , "M_SEQ" )
	aAdd( aCposFolder[ nPosFolder , 02 ] , "RF2_POSTO" )
	aAdd( aCposFolder[ nPosFolder , 02 ] , "M_DESC" )
	aAdd( aCposFolder[ nPosFolder , 02 ] , "RF2_MAT" )	
	aAdd( aCposFolder[ nPosFolder , 02 ] , "M_NOME" )	

	aAdd( aCposFolder[ nPosFolder , 02 ] , "RF2_TRABA"  )
  //	aAdd( aCposFolder[ nPosFolder , 02 ] , "RF2_TIPODIA"	)

	//aAdd( aCposFolder[ nPosFolder , 02 ] , "RF2_ALI_WT" )
	//aAdd( aCposFolder[ nPosFolder , 02 ] , "RF2_REC_WT" )     

    //Nao alteraveis                                          
    aAdd( aCposFolder[ nPosFolder , 03 ] , "M_SEQ" )
//	aAdd( aCposFolder[ nPosFolder , 03 ] , "RF2_POSTO" )
	aAdd( aCposFolder[ nPosFolder , 03 ] , "M_NOME" )	
	aAdd( aCposFolder[ nPosFolder , 03 ] , "M_DESC" )
	aAdd( aCposFolder[ nPosFolder , 03 ] , "RF2_ALI_WT" )
	aAdd( aCposFolder[ nPosFolder , 03 ] , "RF2_REC_WT" ) 
//	aAdd( aCposFolder[ nPosFolder , 03 ] , "RF2_DATA" ) 
//	aAdd( aCposFolder[ nPosFolder , 03 ] , "RF2_DATAATE" ) 
		
	//Colunas Congeladas
 //	aAdd( aCposFolder[ nPosFolder , 05 ] , "M_SEQ" )
	aAdd( aCposFolder[ nPosFolder , 05 ] , "RF2_POSTO" )
	aAdd( aCposFolder[ nPosFolder , 05 ] , "M_DESC" )
	aAdd( aCposFolder[ nPosFolder , 05 ] , "RF2_MAT" )	
	aAdd( aCposFolder[ nPosFolder , 05 ] , "M_NOME" )	
	aAdd( aCposFolder[ nPosFolder , 05 ] , "RF2_TRABA"  )
   //	aAdd( aCposFolder[ nPosFolder , 05 ] , "RF2_TIPODIA"	)  
	aAdd( aCposFolder[ nPosFolder , 05 ] , "RF2_ALI_WT" )
	aAdd( aCposFolder[ nPosFolder , 05 ] , "RF2_REC_WT" ) 

  

Next

RestArea( aAreaSX3 )
RestArea( aArea )

Return( NIL )

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³Pona370aCols	³Autor³Mauricio MR         ³ Data ³10/10/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Monta o aCols da Progamacao 								 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL		                                               	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PONA370                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

Static Function Pona370aCols( cAlias, nSeq, nRecno, aAlter, cNumGhostCol )

Local aArea			:= GetArea()

Local aCols			:= {}
Local cCpo			:= ""
Local nLoop			:= 0.00  
Local nLoops		:= Len(aHeaderAll)
Local lTemReg		:= !Empty(nRecno)  
Local nPosCpo		:= 0 
Local nPosMat

Local nX

aCols				:= Array( nLoops +  1 )   

//Predefine posicao FIXAS (Colunas CONGELADAS) para alguns elementos 
If !Empty(nPosCpo:=GDFIELDPOS("M_SEQ", aHeaderAll ))
	aCols[ nPosCpo ] := nSeq   
Endif
	
If Empty(nRecno)      
	If !Empty(nPosCpo:=GDFIELDPOS("RF2_POSTO", aHeaderAll ))
		aCols[ nPosCpo ] := PAD(Posicione("SRA",1,xFilial("SRA")+RF2->RF2_MAT,"RA_POSTO"),9)
    Endif
Else 
	If !Empty(nPosCpo:=GDFIELDPOS("RF2_POSTO", aHeaderAll ))
		aCols[ nPosCpo ] := RF2->RF2_POSTO
	Endif	
Endif	

If !Empty(nPosCpo:=GDFIELDPOS("M_DESC", aHeaderAll ))
	aCols[nPosCpo ] := SPACE(30) //RCL->(Posicione("RCL",2,xFilial("RCL")+aCols[ 02 ],"RCL_DFUNC"))
Endif
If !Empty(nPosMat:=GDFIELDPOS("RF2_MAT", aHeaderAll ))
	aCols[ nPosMat ] := If (lTemReg,(cAlias)->RF2_MAT,  Space( TamSx3("RF2_MAT")[1] ))
	If !Empty(nPosCpo:=GDFIELDPOS("M_NOME", aHeaderAll ))
		aCols[nPosCpo ] := Posicione("SRA",1,xFilial("SRA")+aCols[ nPosMat ],"RA_NOME")
	Endif
Endif


//Corre Todos os campos do aHeader do Calendario
For nLoop := 1 To nLoops
	cCpo := aHeaderAll[ nLoop , 02 ]
	If cCpo $ "M_SEQ/M_DESC//M_NOME"
               Loop
	Endif

	If cCpo $ "RF2_ALI_WT" 
		// Gravando o Alias e Recno para o uso no WalkThru
		aCols[ nLoop ] 	:= cAlias
        Loop
	Endif
	
	If cCpo $ "RF2_REC_WT"
		// Gravando o Alias e Recno para o uso no WalkThru
		aCols[ nLoop ] 	:= nRecno
        Loop
	Endif

	IF ( cCpo $ "GHOSTCOL" )
		cNumGhostCol := GdNumItem( "GHOSTCOL" , cNumGhostCol , nSeq , aHeaderAll , aCols , nLoop , .F. )
		
		aCols[ nLoop ] := cNumGhostCol
		Loop
	EndIF

	//Para campo virtual alimenta com inicializador padrao
	IF ( aScan( aVirtual , cCpo ) > 0.00 )
		aCols[ nLoop ] := CriaVar( cCpo , NIL , NIL , .F. )
	Else
	    // Campos reais sao alimentados com o conteudo da base de dados
		aCols[ nLoop ] := &( cAlias + "->" + cCpo )
	EndIF
Next nLoop

aCols[ nLoop ] 		:=  .F.

//-- Adiciona informacoes sobre os registros
aAdd( aColsRec , nRecno )

For nX := 1 To nLoops
//	IF ( aScan( aVirtual , aHeaderAll[ nX , 02 ] ) == 0.00 )
		aAdd( aAlter , Alltrim(aHeaderAll[ nX , 02 ] ))
//	EndIF	
Next nX

//-- Restaura Integridade do Sistema
RestArea( aArea )

Return( aCols )



/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³Pona370Locks    ³Autor³Mauricio MR         ³ Data ³09/03/2004³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Bloqueia Lancamentos de Excecoes do Funcionario              ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL		                                               	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PONA370                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function Pona370Locks( nOpc , cAlias , aRecnos , cProcName )


Local lLocks	:= .T.
Local aRecAux

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Se nao For Visualizacao nem Inclusao	 					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
IF ( nOpc <> 2 ) 

	Begin Sequence

		aRecAux := {}
		aEval( aRecnos , { |x| IF( !Empty(x) , aAdd( aRecAux , x ) , NIL ) } )

		IF !( lLocks := WhileNoLock( cAlias , aRecAux , { xFilial(cAlias) + SRA->RA_MAT + cProcName} , 1 , 1 , .T. , NIL ) )
			Break
		EndIF

	End Sequence
	
EndIF

Return( lLocks )      

/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³P370SetDatas	³Autor³Mauricio MR		   ³ Data ³08/10/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Monta Folder de Datas de Programacao de Horarios             ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³.T.                                                 	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³            												 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function P370SetDatas(		nOpcNewGd 		,;
									oDatas			,;
									oGet	 		,;
									oDlg			,;
									nGdCoords		,;
									nNewDataFolder	,;
									nOption			,;
									oFolders		,;
									aCposFolder		,;
									aFolders		,;
									aGdAltera		,;
									adDatas			,;
									bSetDados			;
								) 
								


Local lRet			:= .T.
Local nAt			:= 1.00  

dDataFolder		:= adDatas[nOption]	 
 
IF ( ValType( oGet ) == "O" )             
   
    nAt		:= oGet:oBrowse:nAt  

	Private aCols	:= aClone( oGet:aCols )
	Private aHeader	:= aClone( oGet:aHeader )
	Private n		:= nAt 

   	If Pona370LinOk( oGet:oBrowse , .F. ) 
	    Transf370(	aColsAll    		,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
					oGet:aCols			,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
					oGet:aHeader		,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
					aHeaderAll			,;	//04 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
					.T.					,;	//05 -> Se deve Transferir do aCols para o aColsAll
					.F.					;	//06 -> Se deve Transferir do aColsAll para o aCols
		  		 )  
		
	
		
	 	  		    		
	    
		oGet:Hide()
		oGet:= NIL 
		oFolders:= Nil
		lRet:= .T.
	Else 
	   lRet:= .F.
	Endif	
EndIF



If lRet

 /*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Carrega o Objeto Folder               					   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/   
	
	oFolders := TFolder():New(	000								,;
								001								,;        
								aFolders						,;
								aFolders						,;
								oDatas:aDialogs[nNewDataFolder]	,;
								NIL								,;
								NIL								,;
								NIL								,;
								.T.								,;
								.F.								,;
								__DlgWidth(oDatas)				,;
								__DlgWidth(oDatas)				;								
							 )



	bSetDados := { |nNewFolder| If( Empty(nNewFolder), nNewFolder:=1,nNewFolder)						,;
							    (	dDataFolder:= adDatas[nNewDataFolder ]							,; 
									P370SetOption( 	nOpcNewGd 										,;
									 				@oGet 											,;
													oFolders:aDialogs[nNewFolder]					,;
									   				__DlgWidth(oFolders)							,;
									    			nNewFolder 										,;
									     			oFolders:nOption 								,;
									      			oFolders					 					,;
									       			aCposFolder 									,;
								        			aGdAltera										; 
												  )  ; 
								);			  
							} 
 	oFolders:bSetOption := bSetDados 
 	Eval(oFolders:bSetOption )
 	
Endif

Return( lRet )


/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³P370SetOption   ³Autor³Mauricio MR		   ³ Data ³17/10/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Monta GetDados Conforme Folder                               ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³.T.                                                 	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PONA370														 ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function P370SetOption(		nOpcNewGd 	,;
									oGetDados 	,;
									oDlg		,;
									nGdCoords	,;
									nNewFolder	,;
									nOption		,;
									oFolders	,;
									aCposFolder	,;
									aGdAltera	; 
								)   
								
			
Local aFolderCpos	:= aClone( aCposFolder[ nNewFolder , 02 ] )
Local aGdNoAlter	:= aClone( aCposFolder[ nNewFolder , 03 ] )
Local aCongeladas	:= aClone( aCposFolder[ nNewFolder , 05 ] )
Local aNewHeader 	:= {}
Local aNewCols	 	:= {}
Local aNewGdAltera	:= {}
Local cCpo			:= ""  
Local nPosCpo
Local lSetOption	:= .T.
Local nHeader		:= 0.00
Local nHeaders		:= Len( aHeaderAll )
Local nLoop			:= 0.00
Local nLoops		:= Len( aColsAll )
Local nAt			:= 1.00     

Local oMenu

IF ( ValType( oGetDados ) == "O" )
	
	nAt := oGetDados:oBrowse:nAt
	Transf370(	aColsAll    		,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
				oGetDados:aCols		,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
				oGetDados:aHeader	,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
				aHeaderAll			,;	//04 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
				.T.					,;	//05 -> Se deve Transferir do aCols para o aColsAll
				.F.					,;	//06 -> Se deve Transferir do aColsAll para o aCols
	  		 )  
	Transf370(	aColsAll    		,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
				oGetDados:aCols		,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
				oGetDados:aHeader	,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
				aHeaderAll			,;	//04 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
				.F.					,;	//05 -> Se deve Transferir do aCols para o aColsAll
				.T.					,;	//06 -> Se deve Transferir do aColsAll para o aCols
	  		 )   		    					   
	
	Private aCols	:= aClone( oGetDados:aCols )
	Private aHeader	:= aClone( oGetDados:aHeader )
	Private n		:= 1 

	//oGetDados:Refresh()
	
	//Pona370LinOk( oGetDados:oBrowse , .F. )

	oGetDados:Hide()
	oGetDados := NIL
EndIF

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta aHeader Especifico               					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/  
//Torna Fixas (irao aparecer em todos os Folders as primeiras colunas 
For nHeader := 1 To Len(aCongeladas)-2
	cCpo := aCongeladas[ nHeader ]  
	If !Empty(nPosCpo:=GDFIELDPOS(cCpo, aHeaderAll ))
		aAdd( aNewHeader , aClone( aHeaderAll[ GdFieldPos(cCpo,aHeaderAll) ] ) )
	Endif	
Next nHeader

//Complementa com os campos alocados ao folder (SXA).
For nHeader := 1 To nHeaders
	cCpo := aHeaderAll[ nHeader , 02 ]
	IF ( aScan( aFolderCpos , { |x| x == cCpo } ) > 0.00 )	.and. ;
	   Empty( aScan( aNewHeader , { |x| x[2] == cCpo } ) )
		aAdd( aNewHeader , aClone( aHeaderAll[ nHeader ] ) )
	EndIF
Next nHeader                                                    

//Os restantes dos campos da tabela ficarao ao final da getdados
For nHeader := 1 To nHeaders
	cCpo := aHeaderAll[ nHeader , 02 ]
	If !Empty(nPosCpo:=GDFIELDPOS(cCpo, aHeaderAll ))
		IF  Empty( aScan( aNewHeader , { |x| x[2] == cCpo } ) )
			aAdd( aNewHeader , aClone( aHeaderAll[ nHeader ] ) )
		EndIF
	Endif	
Next nHeader

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Carrega o aCols com as informacoes da Data a partir do aColsAll    ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/   
Transf370(	aColsAll    		,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
			aNewCols			,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
			aNewHeader			,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
			aHeaderAll			,;	//04 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
			.F.					,;	//05 -> Se deve Transferir do aCols para o aColsAll
			.T.					,;	//06 -> Se deve Transferir do aColsAll para o aCols
  		 ) 
		
/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Identifica os campos Editaveis.									 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/ 
nLoops := Len( aGdAltera )
For nLoop := 1 To nLoops
	cCpo := aGdAltera[ nLoop ]
	IF (;
		( aScan( aGdNoAlter  , { |x| x == cCpo } ) == 0.00 ) ;
		)	
		aAdd( aNewGdAltera , cCpo )
	EndIF
Next nLoop

oGetDados := MsNewGetDados():New(	000						,;
									0000					,;
									nGdCoords*.38			,;
									nGdCoords		    	,;
									nOpcNewGd				,;
									"Pona370LinOk"			,;
									NIL						,;
									""						,;
									aNewGdAltera			,;
									0						,;
									NIL						,;
									NIL						,;
									NIL						,;
									{ || .F. }				,;
									oDlg					,;
									aNewHeader		 		,;
									aNewCols				 ;
					 )  
	 

/*/
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta menu para uso FUTURO.										 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/       
oGetDados:oBrowse:bRClicked := {|o,x,y|  oMenu:Activate(x,y,o) }
			
MENU oMenu POPUP of oGetDados:oBrowse
	MENUITEM STR0151  ACTION aLERTA("eXCECAO" )//ACTION msUsrDlg(@oTree,nOpcx,cRevisao,1,cArquivo),PMSTreeEDT(@oTree, cRevisa,,"AFC/AF9/USR",Nil,.T.,cRevisao,@aConfig),PmsUsrCtrMenu(@oMenu,@oTree,nOpcx,cArquivo)) //"Incluir Usuario"
ENDMENU


oGetDados:oBrowse:nAt := nAt  
oGetDados:Show()
oGetDados:oBrowse:SetFocus()
oGetDados:oBrowse:Refresh()
oGetDados:oBrowse:nAt := nAt
Return( lSetOption ) 



/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³Transf370		³Autor³Mauricio MR         ³ Data ³10/10/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Transfere dados entre aColss								 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL		                                               	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PONA370                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/	
Static function Transf370(	aColsAll    		,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
		 					aNewCols			,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
							aNewHeader			,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
							aHeaderAll			,;	//08 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
							lColsToAll			,;	//10 -> Se deve Transferir do aCols para o aColsAll
							lAllToCols			,;	//11 -> Se deve Transferir do aColsAll para o aCols
							bColsToAll			,;	//14 -> Condicao para a Transferencia do aCols para o aColsAll
							bAllToCols			 ;	//15 -> Condicao para a Transferencia do aColsAll para o aCols
					   )                  

Local cKeyFindAll	:= Dtos(dDataFolder)
Local nPosDatAll	:= GdFieldPos("RF2_DATA"	,aHeaderAll)
Local nPosPtoAll    := GdFieldPos("RF2_POSTO",aHeaderAll)
Local nPosMatAll  	:= GdFieldPos("RF2_MAT"	,aHeaderAll)
Local nPosGhstAll  	:= GdFieldPos("GHOSTCOL",aHeaderAll)

Local aPosSortAll   := {nPosDatAll, nPosMatAll, nPosPtoAll}
		
Local		aPosKeyAll  := { ;
								 { nPosDatAll, dDataFolder 	};							 
							 }
		
DEFAULT		bAllToCols	 	:= Nil
DEFAULT 	bColsToAll		:= { | aCols , aHeader , nItem | !Empty( aCols[ nItem, GDFieldPos("RF2_MAT", aHeader) ]  ) } 

If lAllToCols
	bAllToCols := __ExecMacro( "{| aCols , aHeader , nItem | aCols[ nItem, GDFieldPos('RF2_DATA', aHeader) ] == Stod('" + Dtos(dDataFolder) + "')" + "}" )
Endif	

GdColsExChange(		aColsAll    		,;	//01 -> Array com a Estrutura do aCols Contendo todos os Dados
					aNewCols			,;	//02 -> Array com a Estrutura do aCols Contendo Dados Especificos
					aNewHeader			,;	//03 -> Array com a Estrutura do aHeader Contendo Informacoes dos Campos
					NIL					,;	//04 -> Array com as Posicoes dos Campos para Pesquisa
					cKeyFindAll			,;	//05 -> Chave para Busca no aColsAll para Carga do aCols
					aPosSortAll			,;	//06 -> Array com as Posicoes dos Campos para Ordenacao
					aPosKeyAll   		,;	//07 -> Array com as Posicoes dos Campos e Chaves para Pesquisa
					aHeaderAll			,;	//08 -> Array com a Estrutura do aHeaderAll Contendo Informacoes dos Campos
					.F.					,;	//09 -> Conteudo do Elemento "Deleted" ( para uso na GdRmkaCols() )
					lColsToAll			,;	//10 -> Se deve Transferir do aCols para o aColsAll
					lAllToCols	    	,;	//11 -> Se deve Transferir do aColsAll para o aCols
					/*lExistDelet*/		,;	//12 -> Se Existe o Elemento de Delecao no aCols ( para uso na GdRmkaCols() )
					/*lInitPad*/		,;	//13 -> Se deve Carregar os Inicializadores padroes ( para uso na GdRmkaCols() )
					bColsToAll			,;	//14 -> Condicao para a Transferencia do aCols para o aColsAll
					bAllToCols			 ;	//15 -> Condicao para a Transferencia do aColsAll para o aCols
			   )
Return(Nil)



/*
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³Pona370FldRetPos³Autor³Marinaldo de Jesus  ³ Data ³21/10/2003³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Retorna Informacoes do Folder de campos                      ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parametros³<Vide parametros formais>									 ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Retorno   ³NIL		                                               	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Observa‡„o³                                                      	     ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³PONA370                                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Static Function Pona370FldRetPos( cCpo , lDesc )

Local aCpos1
Local aCpos2
Local nLoop
Local nLoops
Local nPosFolder
Local uRet

DEFAULT lDesc := .T.

cCpo := Upper( AllTrim( cCpo ) )
nLoops := Len( aCposFolder )
For nLoop := 1 To nLoops
	aCpos1 := aClone( aCposFolder[ nLoop , 02 ] )
	aCpos2 := aClone( aCposFolder[ nLoop , 03 ] )
	IF ( ( nPosFolder := aScan( aCpos1 , { |x| x == cCpo } ) ) > 0.00 )
		IF ( aScan( aCpos2 , { |x| x == cCpo } ) == 0.00 )
			Exit
		Else
			nPosFolder := 0.00
		EndIF
	EndIF
Next nLoop

IF ( nPosFolder > 0.00 ) .and. ( nLoop <= nLoops )
	IF ( lDesc )
		uRet := aCposFolder[ nLoop , 04 ]
	Else
		uRet := { nLoop , nPosFolder }
	EndIF
Else
	IF ( lDesc )
		uRet := ""
	Else
		uRet := { 0 , 0 }
	EndIF
EndIF

Return( uRet )



/*/
ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿
³Fun‡„o    ³GetCalendTop  ³Autor ³ Mauricio MR		  ³ Data ³07/10/2007³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´
³Descri‡„o ³Carrega os Calendarios de um Periodo           	            ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Sintaxe   ³GetCalendTop()												³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Parƒmetros³< Vide Parametros Formais >							        ³
ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´
³Uso       ³Ponto Eletronico RDD TOPCONNECT                             ³
ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
Static Function GetCalendTop( cFil		,; //01 -> Filial
							 cDepto		,; //02 -> Depto
							 dPerIni	,; //03 -> Periodo Inicial
							 dPerFim	,; //04 -> Periodo Final
							 aCalend  	,; //05 -> Array a ser carregado com os Calendarios
							 aGdAltera   ; //06 -> Campos editaveis
							)

Local cSvAlias		:= Alias()
Local lRet			:= .F.  
Local cFilRF2		:= xFilial("RF2")
Local cFilSRA		:= xFilial("SRA") 
Local cNumGhostCol 	:= Replicate( "0" , GHOSTCOLSIZE )

#IFDEF TOP

	Local cPerIni		:= Dtos( dPerIni )
	Local cPerFim		:= Dtos( dPerFim )
	Local cFilRF2Cond
	Local cFilSRACond
	Local cDeptoCond
	Local nX			:= 0
	Local nSeq	
	Local nSvOrder		:= RF2->( IndexOrd() )   

	
	Static aStruRF2
	Static cIndKey
	Static cQryRF2Fields
	Static nOrder
	Static nFieldsRF2
	
	DEFAULT cIndKey		:= "RF2_FILIAL+RF2_MAT+RF2_CC+RF2_TURNO+DtoS(RF2_DATA)"
	DEFAULT nOrder		:= RetOrdem( "RF2" , cIndKey )

	IF ( aStruRF2	== NIL )
		aStruRF2	:= RF2->( dbStruct() )
		nFieldsRF2	:= Len( aStruRF2 )
	EndIF	

 	IF ( cQryRF2Fields == NIL )
		cQryRF2Fields := "%"
		For nX := 1 To nFieldsRF2
			cQryRF2Fields += 'RF2.'+aStruRF2[ nX , 01 ] + ", "
		Next nX 
		cQryRF2Fields +=" RF2.R_E_C_N_O_ RF2RECNO %"   		
    EndIF

	aArray := {}
	
	IF ( nOrder == nSvOrder )
		RF2->( dbSetOrder( nOrder ) )
	EndIF    

/*/
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Obtem os Eventos de Horas Extras							   ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/*/
	
	cFilRF2Cond	:= "% RF2.RF2_FILIAL = '" + cFilRF2 + "' AND RF2.RF2_MAT <> '" + Space( TamSx3("RF2_MAT")[1] ) +"' %"	
	cPeriodo    := "% RF2.RF2_DATA BETWEEN '" + cPerIni + "' AND '" + cPerFim + "'"  + " %"
	cFilSRACond	:= "% SRA.RA_FILIAL = '"+cFilSRA+"' %"	
	cDeptoCond	:= "% SRA.RA_DEPTO = '" +cDepto+"' %"
	cOrdem		:= '% '+SqlOrder( RF2->( IndexKey(1) ) )+' %'
			    
	cAliasQry 	:= GetNextAlias()
		
	BeginSql Alias cAliasQry 
		COLUMN RF2_DATA	as Date
		COLUMN RF2_DATAATE as Date
			
		SELECT 	
		%Exp:cQryRF2Fields%
		FROM %table:RF2% RF2 
		INNER JOIN %table:SRA% SRA 
		ON  (		( RF2.RF2_FILIAL = SRA.RA_FILIAL  )  AND ( RF2.RF2_MAT = SRA.RA_MAT  ) 	 )    AND %Exp:cDeptoCond%
		WHERE   %exp:cFilSRACond% AND %exp:cFilRF2Cond% AND
				%exp:cPeriodo% AND
				SRA.%NotDel% AND 
				RF2.%NotDel% 
 		ORDER BY %exp:cOrdem%					 					  
			 
	EndSql 
	
	aColsAll	:= {}
	aGdAltera	:= {}
	nSeq:=0
	While ( cAliasQry )->( !Eof() )
        nSeq++
	
		aAdd(aColsAll, aClone( ( cAliasQry )->(Pona370aCols( cAliasQry , nSeq, RF2RECNO, aGdAltera, @cNumGhostCol) ) ) )			
			
		( cAliasQry )->( dbSkip() )
		
	    lRet:= .T.
	    
	End While
	
	//-- Se nao houve calendario
	If !lRet  .and. ( nSeq == 0 )  
   	  
	   RF2->(dbGoBoTTom())
   	   RF2->(dbGoTo(Recno()+1))
 	    aAdd(aColsAll,  aClone(  RF2->(Pona370aCols( "RF2", nSeq, 0, aGdAltera, @cNumGhostCol) ) ) )		
    Endif
    
	
	( cAliasQry )->( dbCloseArea() )
	
	IF ( nOrder == nSvOrder )
		RF2->( dbSetOrder( nSvOrder ) )
	EndIF

#ENDIF

IF ( Select( cSvAlias ) > 0 )
	dbSelectArea( cSvAlias )
EndIF
	
Return( lRet )



FUNCTION P2POSTOINIT()

RETURN(" ")

FUNCTION P2DEPTOINIT()

RETURN(" ")




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pona370Grava³Autor³ Mauricio MR           ³ Data ³ 08.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Grava Programacao de Horarios		                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ 				                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Pona370Grava(cAlias)

Local aArea			:= GetArea()
Local cCampo		:= '' 
Local cFil			:= xFilial( 'RF2' , SRA->RA_FILIAL )
Local cTraba		:= ''
Local cMsgErr		:= ''
Local dData			:= Ctod("//")
Local lAddNew		:= .F.
Local nX			:= 0.00
Local nY			:= 0.00
Local nFornX		:= 0.00
Local nFornY		:= 0.00
Local nPosData		:= GdFieldPos('RF2_DATA',aHeaderAll)
Local nPosTrab		:= GdFieldPos('RF2_TRABA',aHeaderAll)
Local nPosRecno		:= GdFieldPos("RF2_REC_WT",aHeaderAll)

dbSelectArea(cAlias)

nFornX	:= Len( aColsAll )
For nX := 1 To nFornX //-- Linhas

	dData	:= CtoD( Left( Dtoc(aColsAll[ nX , nPosData ]) , Len( DTOC( MsDate() ) ) ) ,'ddmmyy' )
	cTraba	:= aColsAll[ nX ,nPosTrab ]
	nReg	:= aColsAll[ nX ,nPosRecno ]
	
	//-- Grava somente registros Com Recno Zerados ou que foram Alterados
	IF ( ( lAddNew := Empty( nReg ) ) .or. !fCompArray( aColsAnt[ nX ] , aColsAll[ nX ] ) )

		//-- Inclui ou Altera registro
		IF !( lAddNew )
			RF2->( dbGoto( nReg ) )
		EndIF

		IF RecLock( "RF2" , lAddNew )

			//-- Campos n„o mostrados na Tela ( a370field )
			RF2->RF2_FILIAL	:= cFil
			RF2->RF2_CC		:= Space( Len(SRA->RA_CC) )
			RF2->RF2_TURNO	:= Space( Len(SRA->RA_TNOTRAB) )
				
			nFornY := ( Len( aColsAll[nX] ) -1 )
			For nY := 1 To nFornY  //-- Colunas
				cCampo    := aHeaderAll[nY,2]
				xConteudo := aColsAll[ nX , nY ]
				IF ( aScan( aVirtual , cCampo ) == 0 )
					RF2->( &cCampo ) := xConteudo
				EndIF
			Next nY
		
			RF2->( MsUnLock() )
		
		EndIF	

	EndIF

Next nX

//-- Restaura Integridade do Sistema
RestArea( aArea )

Return( NIL )





/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³                   ROTINAS DE CRITICA DE CAMPOS                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pona370LinOk³Autor³Mauricio MR           	³ Data ³ 02.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica linha digitada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pona370LinOk( o , lShowMsg )

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis de Inicializacao Obrigatoria					  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local aHorarios	:= Array( 8 )
Local lRet		:= .T.
Local nTotHoras	:= 0.00

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Variaveis que serao inicializadas no Corpo da Funcao		  ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
Local cCodHExt
Local cCodHNot
Local cHerdHor
Local cTraba
Local cMotivo
Local cMsgInfo
Local nPosE1
Local nPosS1
Local nPosE2
Local nPosS2
Local nPosE3
Local nPosS3
Local nPosE4
Local nPosS4
Local nPosHExt
Local nPosHNot
Local nPosTraba
Local nPosMotiv
Local nPosHrt
Local nPosHr2
Local nPosHr3
Local nPosHr4
Local nPosTot
Local nPosHi1
Local nPosHi2
Local nPosHi3
Local nPosHerd
Local nHorMeno
Local nHorMais

DEFAULT lShowMsg := .T.

IF !aCols[n, GdFieldPos( "GDDELETED" , aHeader )]
	/*
	ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	³ Obtem o posicionamento dos Campos							  ³
	ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
	nPosE1		:= GdFieldPos( "RF2_ENTRA1"	)
	nPosS1		:= GdFieldPos( "RF2_SAIDA1"	) 
	nPosE2		:= GdFieldPos( "RF2_ENTRA2"	)
	nPosS2		:= GdFieldPos( "RF2_SAIDA2"	)
	nPosE3		:= GdFieldPos( "RF2_ENTRA3"	)
	nPosS3		:= GdFieldPos( "RF2_SAIDA3"	)
	nPosE4		:= GdFieldPos( "RF2_ENTRA4"	)
	nPosS4		:= GdFieldPos( "RF2_SAIDA4"	)
	nPosHExt	:= GdFieldPos( "RF2_CODHEXT" )
	nPosHNot	:= GdFieldPos( "RF2_CODHNOT" )
	nPosTraba	:= GdFieldPos( "RF2_TRABA"   )
	nPosMotiv	:= GdFieldPos( "RF2_MOTIVO"  )
	nPosHrt		:= GdFieldPos( "RF2_HRSTRAB" ) 
	nPosHr2		:= GdFieldPos( "RF2_HRSTRA2" )
	nPosHr3		:= GdFieldPos( "RF2_HRSTRA3" )
	nPosHr4		:= GdFieldPos( "RF2_HRSTRA4" )
	nPosTot		:= GdFieldPos( "RF2_TOTHORA" ) 
	nPosHi1		:= GdFieldPos( "RF2_HRINTV1" ) 
	nPosHi2		:= GdFieldPos( "RF2_HRINTV2" ) 
	nPosHi3		:= GdFieldPos( "RF2_HRINTV3" )  
	nPosHerd	:= GdFieldPos( "RF2_HERDHOR" )
	
	lHrsTrbGat := .T.
	
	//Grava Horas Trabalhadas 1a. Jornada
	IF !Empty( nPosHrt )
		aCols[ n , nPosHrt ] := fHrsTrabGat("H","RF2","GD","1")
	EndIF
	
	//Grava Horas Trabalhadas 2a. Jornada
	IF !Empty( nPosHr2 )
		aCols[ n , nPosHr2 ] := fHrsTrabGat("H","RF2","GD","2")
	EndIF
	
	//Grava Horas Trabalhadas 3a. Jornada
	IF !Empty( nPosHr3 )
		aCols[ n , nPosHr3 ] := fHrsTrabGat("H","RF2","GD","3")
	EndIF
	
	//Grava Horas Trabalhadas 4a. Jornada
	IF !Empty( nPosHr4 )
		aCols[ n , nPosHr4 ] := fHrsTrabGat("H","RF2","GD","4")
	EndIF
	
	//Grava Horas 1o. Intervalo
	IF !Empty( nPosHi1 )
		aCols[ n , nPosHi1 ] := fHrsTrabGat("I","RF2","GD","1")
	EndIF
	
	//Grava Horas 2o. Intervalo
	IF !Empty( nPosHi2 )
		aCols[ n , nPosHi2 ] := fHrsTrabGat("I","RF2","GD","2")
	EndIF
	
	//Grava Horas 3o. Intervalo
	IF !Empty( nPosHi3 )
		aCols[ n , nPosHi3 ] := fHrsTrabGat("I","RF2","GD","3")
	EndIF
	
	//Grava Total de Horas ( Trabalhadas + Intervalo )
	IF !Empty( nPosTot )
		aCols[ n , nPosTot ] := fHrsTrabGat( "T" , "RF2" , "GD" )
	EndIF
	
	aFill( aHorarios , 0 )
		
	//-- Campos da Exce‡„o
	aHorarios[ 1 ]	:= aCols[ n , nPosE1	]
	aHorarios[ 2 ]	:= aCols[ n , nPosS1	]
	aHorarios[ 3 ]	:= aCols[ n , nPosE2	]
	aHorarios[ 4 ]	:= aCols[ n , nPosS2	] 
	aHorarios[ 5 ]	:= aCols[ n , nPosE3	]
	aHorarios[ 6 ]	:= aCols[ n , nPosS3	]
	aHorarios[ 7 ]	:= aCols[ n , nPosE4	]
	aHorarios[ 8 ]	:= aCols[ n , nPosS4	]
	cCodHExt		:= aCols[ n , nPosHExt	]
	cCodHNot		:= aCols[ n , nPosHNot	]
	cTraba			:= aCols[ n , nPosTraba	]
	cMotivo			:= aCols[ n , nPosMotiv	]
	cHerdHor		:= If( !EMPTY(nPosHerd), aCols[n, nPosHerd], 'N' )
	
	Begin Sequence
		//-- Consiste Programacoes
		If Empty(aCols[n, GdFieldPos("RF2_MAT")])
			cMsgInfo := STR0150  //"Matricula Invalida"
			lRet := .F.
		Endif
		
		IF !Empty(cTraba)
			IF ( ( cTraba == "S" ) .and. ( aEval( aHorarios , { |x| nTotHoras += x } ) , nTotHoras ) == 0.00 .and. cHerdHor <> 'S' ) 
				cMsgInfo := STR0045  //"Para Dias Trabalhados sera necessario o preenchimento dos horarios"
				lRet := .F.
				Break
			EndIf
			/*
			IF Empty(cMotivo)
				cMsgInfo := STR0046	//"O campo: "
				cMsgInfo += aHeader[ nPosMotiv , 01 ] 
				cMsgInfo += STR0047	//" ‚ de preenchimento obrigat¢rio." 
				cMsgInfo += CRLF
				cMsgInfo += CRLF
				cMsgInfo += STR0049	//"Folder: "
				cMsgInfo += Pona370FldRetPos( aHeader[ nPosMotiv , 02 ]  )
				lRet := .F.
				Break
			EndIF
			*/
			IF Empty(cCodHExt)
				cMsgInfo := STR0046	//"O campo: "
				cMsgInfo += aHeader[ nPosHExt , 01 ] 
				cMsgInfo += STR0047	//" ‚ de preenchimento obrigat¢rio." 
				cMsgInfo += CRLF
				cMsgInfo += CRLF
				cMsgInfo += STR0049	//"Folder: "
				cMsgInfo += Pona370FldRetPos( aHeader[ nPosHExt , 02 ]  )
				lRet := .F.
				Break
			EndIF
			IF Empty( cCodHNot )
				cMsgInfo := STR0046	//"O campo: "
				cMsgInfo += aHeader[ nPosHNot , 01 ] 
				cMsgInfo += STR0047	//" ‚ de preenchimento obrigat¢rio." 
				cMsgInfo += CRLF
				cMsgInfo += CRLF
				cMsgInfo += STR0049	//"Folder: "
				cMsgInfo += Pona370FldRetPos( aHeader[ nPosHNot , 02 ]  )
				lRet := .F.
				Break
			EndIF
			//Verifica se Existe Saida de Intervalo sem Entrada correspondente
			IF ( ( ( aCols[ n , nPosHi1 ] <> 0 ) .or. ( GdFieldGet( 'RF2_INTERV1' ) == "S" ) ) .and. ( aCols[ n , nPosHr2 ] == 0.00 ) )
				lRet		:= .F.
				cMsgInfo	:= STR0040  //"Os Horarios n„o podem terminar com uma saida de intervalo"
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= STR0041	//"O intervalo: "
				cMsgInfo	+= " 1 "
				cMsgInfo	+= STR0042  //"Nao possui a entrada correspondente"
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= STR0043  //"Altere o conteudo do campo: "
				cMsgInfo	+= aHeader[ GdFieldPos( 'RF2_INTERV1' ) , 01 ]
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= STR0049	//"Folder: "
				cMsgInfo 	+= Pona370FldRetPos( 'RF2_INTERV1' )
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo    += STR0044	//"ou informe Hor rio nos campos: "
				cMsgInfo	+= aHeader[ GdFieldPos( 'RF2_ENTRA2' ) , 01 ]
				cMsginfo	+= " / " 
				cMsgInfo	+= aHeader[ GdFieldPos( 'RF2_SAIDA2' ) , 01 ]
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= STR0049	//"Folder: "
				cMsgInfo 	+= Pona370FldRetPos( 'RF2_ENTRA2' )
				Break		
			EndIF
			//Verifica se Existe Saida de Intervalo sem Entrada correspondente
			IF ( ( ( aCols[ n , nPosHi2 ] <> 0 ) .or. ( GdFieldGet( 'RF2_INTERV2' ) == "S" ) ) .and. ( aCols[ n , nPosHr3 ] == 0.00 ) )
				lRet		:= .F.
				cMsgInfo	:= STR0040  //"Os Horarios n„o podem terminar com uma saida de intervalo"
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= STR0041	//"O intervalo: "
				cMsgInfo	+= " 2 "
				cMsgInfo	+= STR0042  //"Nao possui a entrada correspondente"
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= STR0043  //"Altere o conteudo do campo: "
				cMsgInfo	+= aHeader[ GdFieldPos( 'RF2_INTERV2' ) , 01 ]
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= STR0049	//"Folder: "
				cMsgInfo 	+= Pona370FldRetPos( 'RF2_INTERV2' )
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo    += STR0044	//"ou informe Hor rio nos campos: "
				cMsgInfo	+= aHeader[ GdFieldPos( 'RF2_ENTRA3' ) , 01 ]
				cMsginfo	+= " / " 
				cMsgInfo	+= aHeader[ GdFieldPos( 'RF2_SAIDA3' ) , 01 ]
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= STR0049	//"Folder: "
				cMsgInfo 	+= Pona370FldRetPos( 'RF2_SAIDA3' )
				Break		
			EndIF
			//Verifica se Existe Saida de Intervalo sem Entrada correspondente
			IF ( ( ( aCols[ n , nPosHi3 ] <> 0 ) .or. ( GdFieldGet( 'RF2_INTERV3' ) == "S" ) ) .and. ( aCols[ n , nPosHr4 ] == 0.00 ) )
				lRet		:= .F.
				cMsgInfo	:= STR0040  //"Os Horarios n„o podem terminar com uma saida de intervalo"
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= STR0041	//"O intervalo: "
				cMsgInfo	+= " 3 "
				cMsgInfo	+= STR0042  //"Nao possui a entrada correspondente"
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo	+= STR0043  //"Altere o conteudo do campo: "
				cMsgInfo	+= aHeader[ GdFieldPos( 'RF2_INTERV3' ) , 01 ]
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= STR0049	//"Folder: "
				cMsgInfo 	+= Pona370FldRetPos( 'RF2_INTERV3' )
				cMsgInfo	+= CRLF
				cMsgInfo	+= CRLF
				cMsgInfo    += STR0044	//"ou informe Hor rio nos campos: "
				cMsgInfo	+= aHeader[ GdFieldPos( 'RF2_ENTRA4' ) , 01 ]
				cMsginfo	+= " / " 
				cMsgInfo	+= aHeader[ GdFieldPos( 'RF2_SAIDA4' ) , 01 ]
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= STR0049	//"Folder: "
				cMsgInfo 	+= Pona370FldRetPos( 'RF2_SAIDA4' )
				Break		
			EndIF
			//Consiste HorMeno
			IF ( ( nHorMeno := GdFieldGet("RF2_HORMENO") ) <= 0.00 )
				lRet := .F.
				cMsgInfo	:= STR0046  //"O Campo: "
				cMsgInfo	+= aHeader[ GdFieldPos( "RF2_HORMENO" ) , 01 ]
				cMsgInfo    += STR0047	//" ‚ de preenchimento obrigat¢rio."
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= STR0049	//"Folder: "
				cMsgInfo 	+= Pona370FldRetPos( "RF2_HORMENO" )
				Break
			EndIF
			//Consiste HorMais
			IF ( ( nHorMais := GdFieldGet("RF2_HORMAIS") ) <= 0.00 )
				lRet := .F.
				cMsgInfo	:= STR0046  //"O Campo: "
				cMsgInfo	+= aHeader[ GdFieldPos( "RF2_HORMAIS" ) , 01 ]
				cMsgInfo    += STR0047	//" ‚ de preenchimento obrigat¢rio."
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= CRLF
				cMsgInfo 	+= STR0049	//"Folder: "
				cMsgInfo 	+= Pona370FldRetPos( "RF2_HORMAIS" )
				Break
			EndIF
		EndIF
	End Sequence
	
	IF !( lRet)
		IF ( lShowMsg )
			IF !Empty( cMsgInfo )
				//"Existe inconsistˆncias na Exce‡„o"
				MsgInfo( OemToAnsi( cMsgInfo ) , OemToAnsi( STR0039 ) )
			Else
				Help(' ',1,'PONA140OBR')
			EndIF
		EndIF
	
	EndIF

	lHrsTrbGat := .F.
Endif	

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Pona370TudOk³Autor³Mauricio MR            ³ Data ³ 02.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Critica tudo antes de salvar                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Pona370TudOk(o)

Local lRet		:= .T.
Local nI		:= 0.00
Local nItera	:= Len( aCols )
Local nSvn		:= n

For nI := 1 To nItera
	n := nI
	IF !( lRet := Pona370LinOk( o ) )
		Exit
	EndIF
Next nI

n := nSvn

Return( lRet )




Function Pn370WData()  
Local lRet		:= .T.
Local nPosRecno	:= 0
If aCols<> Nil      
   nPosRecno:=GdFieldPos("RF2_REC_WT", aHeaderAll)
   If aCols[n, nPosRecno] > 0   
      lRet:= .F.
   endif 
Endif       

Return(lRet)
